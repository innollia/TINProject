extends SceneTree

const ENTRY_SCENE: PackedScene = preload("res://modules/rule_rewriting/entry.tscn")
const SAMPLE_COUNT: int = 12
const WARMUP_COUNT: int = 3
const BOARDS: Array[StringName] = [&"rule_01_open_gate", &"rule_14_owner_focus"]

var _module: GameModule
var _module_context: ModuleContext
var _interactive: bool = false
var _monitor_action: StringName = &""
var _pending_input_usec: int = 0
var _interactive_stage: int = 0


func _initialize() -> void:
	_interactive = OS.get_cmdline_user_args().has("--interactive")
	print("Rule rewrite benchmark starting")
	call_deferred("_run")


func _process(_delta: float) -> bool:
	if not _interactive or _monitor_action.is_empty() or _pending_input_usec > 0:
		return false
	if Input.is_action_just_pressed(_monitor_action):
		_pending_input_usec = Time.get_ticks_usec()
		RenderingServer.frame_post_draw.connect(_on_monitored_frame_drawn, CONNECT_ONE_SHOT)
	return false


func _run() -> void:
	_module = ENTRY_SCENE.instantiate() as GameModule
	_module_context = ModuleContext.new()
	_module_context.module_id = &"rule_rewriting"
	_module_context.input_enabled = true
	_module.context = _module_context
	root.add_child(_module)
	_module.enter(_module_context)
	await process_frame
	await process_frame
	if _interactive:
		await _show_interactive_board(&"rule_01_open_gate", &"rule_rewriting_right", KEY_RIGHT)
		return

	for board_id: StringName in BOARDS:
		var level := RuleLevelLoader.load_level(board_id)
		if not bool(level.get("ok", false)):
			push_error("Could not load benchmark board %s" % String(board_id))
			quit(1)
			return
		var initial_state := _module.save_state()
		initial_state["board_id"] = String(board_id)
		initial_state["grid"] = (level["state"] as RuleGridState).to_dictionary()
		_module.load_state(initial_state)
		await process_frame
		await process_frame
		await _measure_board(board_id, initial_state)

	_module.queue_free()
	await process_frame
	quit()


func _measure_board(board_id: StringName, initial_state: Dictionary) -> void:
	var is_3d := bool(_module.call("_is_3d_mode"))
	var actor_id := String(_module.get("selected_3d_subject_id")) if is_3d else ""
	if actor_id.is_empty():
		var you_ids := _module.call("_you_ids") as Array[String]
		if not you_ids.is_empty():
			actor_id = you_ids[0]
	if actor_id.is_empty():
		push_error("Benchmark board %s has no YOU entity" % String(board_id))
		quit(1)
		return
	var direction := _find_open_direction(actor_id)
	if direction == Vector2i.ZERO:
		push_error("Benchmark board %s has no valid YOU move" % String(board_id))
		quit(1)
		return

	var domain_samples: Array[float] = []
	var parser_samples: Array[float] = []
	var word_resolution_samples: Array[float] = []
	var metrix_samples: Array[float] = []
	var derived_samples: Array[float] = []
	var view_samples: Array[float] = []
	var frame_samples: Array[float] = []
	var movement_view_samples: Array[float] = []
	var movement_frame_samples: Array[float] = []
	var waits_for_render := DisplayServer.get_name() != "headless"
	var ids: Array[String] = [actor_id]
	var start_usec: int = 0
	var state := _module.get("grid_state") as RuleGridState
	var metrix_enabled := bool(_module.call("_has_metrix_rule"))
	for sample_index: int in range(SAMPLE_COUNT + WARMUP_COUNT):
		_module.load_state(initial_state)
		start_usec = Time.get_ticks_usec()
		_module.call("_apply_player_intent", ids, direction)
		var domain_usec := Time.get_ticks_usec() - start_usec
		if sample_index >= WARMUP_COUNT:
			domain_samples.append(float(domain_usec) / 1000.0)
	print("  measured turn-domain samples")

	for sample_index: int in range(SAMPLE_COUNT + WARMUP_COUNT):
		start_usec = Time.get_ticks_usec()
		RuleParser.parse(state.width, state.height, state.entities)
		var parser_usec := Time.get_ticks_usec() - start_usec
		if sample_index >= WARMUP_COUNT:
			parser_samples.append(float(parser_usec) / 1000.0)
	print("  measured parser samples")

	for sample_index: int in range(SAMPLE_COUNT + WARMUP_COUNT):
		start_usec = Time.get_ticks_usec()
		_module.call("_resolve_word_rules")
		var word_usec := Time.get_ticks_usec() - start_usec
		if sample_index >= WARMUP_COUNT:
			word_resolution_samples.append(float(word_usec) / 1000.0)
	print("  measured word-resolution samples")

	for sample_index: int in range(SAMPLE_COUNT + WARMUP_COUNT):
		start_usec = Time.get_ticks_usec()
		RuleMetrixResolver.resolve(state, metrix_enabled)
		var metrix_usec := Time.get_ticks_usec() - start_usec
		if sample_index >= WARMUP_COUNT:
			metrix_samples.append(float(metrix_usec) / 1000.0)
	print("  measured METRIX samples")

	for sample_index: int in range(SAMPLE_COUNT + WARMUP_COUNT):
		start_usec = Time.get_ticks_usec()
		_module.call("_rebuild_derived")
		var derived_usec := Time.get_ticks_usec() - start_usec
		if sample_index >= WARMUP_COUNT:
			derived_samples.append(float(derived_usec) / 1000.0)
	print("  measured derived-state samples")

	_module.load_state(initial_state)
	for warmup_index: int in range(WARMUP_COUNT):
		_module.call("_refresh")
	for sample_index: int in range(SAMPLE_COUNT):
		start_usec = Time.get_ticks_usec()
		_module.call("_refresh")
		var view_usec := Time.get_ticks_usec() - start_usec
		view_samples.append(float(view_usec) / 1000.0)
	print("  measured presentation-rebuild samples")

	_module.load_state(initial_state)
	await process_frame
	for warmup_index: int in range(WARMUP_COUNT):
		await _dispatch_and_measure(is_3d, direction)
	for sample_index: int in range(SAMPLE_COUNT):
		_module.load_state(initial_state)
		if is_3d:
			_set_camera_for_direction(direction)
		await process_frame
		var frame_usec: int = await _dispatch_and_measure(is_3d, direction)
		frame_samples.append(float(frame_usec) / 1000.0)
	if is_3d:
		print("  measured camera-command-to-draw samples")
		for sample_index: int in range(SAMPLE_COUNT + WARMUP_COUNT):
			_module.load_state(initial_state)
			_set_camera_for_direction(direction)
			await process_frame
			if DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
			else:
				await process_frame
			_module.call("_apply_player_intent", ids, direction)
			start_usec = Time.get_ticks_usec()
			_module.call("_refresh")
			var movement_view_usec := Time.get_ticks_usec() - start_usec
			if sample_index >= WARMUP_COUNT:
				movement_view_samples.append(float(movement_view_usec) / 1000.0)
			var movement_frame_usec: int = await _dispatch_movement_and_measure(is_3d, direction)
			if sample_index >= WARMUP_COUNT:
				movement_frame_samples.append(float(movement_frame_usec) / 1000.0)
		print("  measured dirty movement-view and forward-command samples")

	print("BENCH board=%s mode=%s cells=%d entities=%d samples=%d" % [
		String(board_id), "3D" if is_3d else "2D", _module.grid_state.width * _module.grid_state.height,
		_module.grid_state.entities.size(), SAMPLE_COUNT
	])
	_print_summary("rule_parser_ms", parser_samples)
	_print_summary("word_resolution_ms", word_resolution_samples)
	_print_summary("metrix_resolver_ms", metrix_samples)
	_print_summary("derived_rebuild_ms", derived_samples)
	_print_summary("turn_domain_ms", domain_samples)
	_print_summary("presentation_rebuild_ms", view_samples)
	_print_summary("command_to_%s_ms" % ("frame_drawn" if waits_for_render else "next_process_frame"), frame_samples)
	if is_3d:
		_print_summary("dirty_movement_view_ms", movement_view_samples)
		_print_summary("forward_command_to_frame_drawn_ms" if waits_for_render else "forward_command_to_next_process_frame_ms", movement_frame_samples)


func _dispatch_and_measure(is_3d: bool, direction: Vector2i) -> int:
	var start_usec := Time.get_ticks_usec()
	if is_3d:
		_module.execute_command(&"turn_left")
	else:
		_module.execute_command(&"move", {"direction": direction})
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	else:
		await process_frame
	var frame_usec := Time.get_ticks_usec() - start_usec
	return frame_usec


func _dispatch_movement_and_measure(is_3d: bool, direction: Vector2i) -> int:
	var start_usec := Time.get_ticks_usec()
	if is_3d:
		_module.execute_command(&"forward")
	else:
		_module.execute_command(&"move", {"direction": direction})
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	else:
		await process_frame
	return Time.get_ticks_usec() - start_usec


func _set_camera_for_direction(direction: Vector2i) -> void:
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	var quadrant := directions.find(direction)
	if quadrant >= 0:
		_module.set("_camera_quadrant", quadrant)
		_module.call("_refresh")


func _input_action(is_3d: bool, direction: Vector2i) -> StringName:
	if is_3d:
		return &"rule_rewriting_turn_left"
	match direction:
		Vector2i.LEFT: return &"rule_rewriting_left"
		Vector2i.RIGHT: return &"rule_rewriting_right"
		Vector2i.UP: return &"rule_rewriting_up"
		Vector2i.DOWN: return &"rule_rewriting_down"
	return &""


func _show_interactive_board(board_id: StringName, action: StringName, keycode: Key) -> void:
	var level := RuleLevelLoader.load_level(board_id)
	if not bool(level.get("ok", false)):
		push_error("Could not load interactive board %s" % String(board_id))
		quit(1)
		return
	var state := _module.save_state()
	state["board_id"] = String(board_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	_module.load_state(state)
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	if InputMap.action_get_events(action).is_empty():
		var event := InputEventKey.new()
		event.keycode = keycode
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)
	if not _module_context.allowed_actions.has(action):
		_module_context.allowed_actions.append(action)
	_monitor_action = action
	_pending_input_usec = 0
	await process_frame
	await RenderingServer.frame_post_draw
	print("INPUT_PROBE_READY board=%s action=%s" % [String(board_id), String(action)])


func _on_monitored_frame_drawn() -> void:
	var elapsed_usec := Time.get_ticks_usec() - _pending_input_usec
	print("INPUT_TO_DRAW_MS stage=%d action=%s elapsed=%.3f" % [
		_interactive_stage + 1, String(_monitor_action), float(elapsed_usec) / 1000.0
	])
	_pending_input_usec = 0
	_interactive_stage += 1
	_monitor_action = &""
	if _interactive_stage == 1:
		call_deferred("_show_interactive_board", &"rule_14_owner_focus", &"rule_rewriting_forward", KEY_W)
	else:
		quit()


func _find_open_direction(entity_id: String) -> Vector2i:
	var entity := _module.call("_find_entity", entity_id) as RuleGridEntity
	if entity == null:
		return Vector2i.ZERO
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
		var plan := RuleMovementSolver.plan_move_many(
			_module.get("grid_state") as RuleGridState,
			_module.get("rule_set") as RuleSet,
			[entity_id],
			direction
		)
		if bool(plan.get("can_move", false)):
			return direction
	return Vector2i.ZERO


func _print_summary(label: String, samples: Array[float]) -> void:
	samples.sort()
	var median := samples[samples.size() / 2]
	var p95 := samples[mini(samples.size() - 1, ceili(float(samples.size()) * 0.95) - 1)]
	print("  %s median=%.3f p95=%.3f max=%.3f" % [label, median, p95, samples.back()])
