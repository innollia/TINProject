extends GameModule

const AxisView = preload("res://modules/physics_puzzle_platformer/domain/axis_view.gd")
const BodyMass = preload("res://modules/physics_puzzle_platformer/domain/body_mass.gd")
const RunState = preload("res://modules/physics_puzzle_platformer/domain/run_state.gd")
const SaveCodec = preload("res://modules/physics_puzzle_platformer/domain/save_codec.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")
const WorldState = preload("res://modules/physics_puzzle_platformer/domain/world_state.gd")
const ContentIndex = preload("res://modules/physics_puzzle_platformer/systems/content_index.gd")
const InputBubble = preload("res://modules/physics_puzzle_platformer/systems/input_bubble.gd")
const Mutation = preload("res://modules/physics_puzzle_platformer/systems/mutation.gd")
const Selector = preload("res://modules/physics_puzzle_platformer/systems/selector.gd")
const StepDirector = preload("res://modules/physics_puzzle_platformer/systems/step_director.gd")

const MODULE_ID: StringName = &"physics_puzzle_platformer"
const ACTIONS: Array[StringName] = [&"ppp_move_left", &"ppp_move_right", &"ppp_jump", &"ppp_grab", &"ppp_reset_level"]
const KEYS: Dictionary = {
	&"ppp_move_left": [KEY_A, KEY_LEFT],
	&"ppp_move_right": [KEY_D, KEY_RIGHT],
	&"ppp_jump": [KEY_SPACE],
	&"ppp_grab": [KEY_E],
	&"ppp_reset_level": [KEY_R],
}
const EVENT_RESET: StringName = &"ppp_reset"
const EVENT_LEVEL_CLEAR: StringName = &"ppp_level_clear"
const EVENT_RUN_CLEAR: StringName = &"ppp_run_clear"
const EVENT_TOOL_USE: StringName = &"ppp_tool_use"
const PHASE_INTRO: StringName = &"intro"
const PHASE_PLAY: StringName = &"play"
const PHASE_CLEAR: StringName = &"clear"
const PHASE_DEAD: StringName = &"dead"

var content: RefCounted
var run: RefCounted
var director: RefCounted
var bubble: RefCounted = InputBubble.new()
var axis: RefCounted
var last_events: Array[Dictionary] = []
var event_counts: Dictionary = {}

static var _engine_owners: int = 0
static var _prior_ticks: int = 60
static var _prior_jitter: float = 0.5

var _entered: bool = false
var _pending_state: Dictionary = {}
var _pending_observations: Array[Dictionary] = []
var _command_axis: float = 0.0
var _command_jump: bool = false
var _command_tool: bool = false
var _previous: Dictionary = {}
var _screen: Node
var _audio: Node


func _ready() -> void:
	_screen = get_node_or_null("GameScreen")
	_audio = get_node_or_null("AudioSink")


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_ensure_actions()
	if _engine_owners == 0:
		_prior_ticks = Engine.physics_ticks_per_second
		_prior_jitter = Engine.physics_jitter_fix
	_engine_owners += 1
	Engine.physics_ticks_per_second = Tuning.PHYSICS_HZ
	Engine.physics_jitter_fix = 0.0
	content = ContentIndex.load_default()
	axis = AxisView.from_arrival(context.arrival if context != null else {})
	var restored_world: Dictionary = _prepare_run(_pending_state)
	_entered = true
	if _screen != null and _screen.has_method("setup"):
		_screen.call("setup", self)
	_build_level(restored_world)
	if restored_world.is_empty() or get_phase() != PHASE_PLAY:
		get_world_state().set_phase(PHASE_INTRO)
	if not bool(run.bubble.get("done", false)):
		bubble.start(_previous_profile())
	else:
		bubble.restore(run.bubble, _previous_profile())
	if bubble.active:
		get_world_state().set_phase(PHASE_INTRO)
	_refresh_screen()
	for observation: Dictionary in _pending_observations:
		requested.emit(&"observation", observation)
	_pending_observations.clear()


func exit() -> void:
	if director != null:
		director.teardown()
		director = null
	if _screen != null and _screen.has_method("clear_level"):
		_screen.call("clear_level")
	if _entered:
		_engine_owners = maxi(_engine_owners - 1, 0)
		if _engine_owners == 0:
			Engine.physics_ticks_per_second = _prior_ticks
			Engine.physics_jitter_fix = _prior_jitter
	_entered = false
	super.exit()


func save_state() -> Dictionary:
	if not _entered or run == null:
		return _pending_state.duplicate(true)
	run.bubble = bubble.to_save()
	var world: RefCounted = null
	if director != null:
		director.sync_runtime()
		world = director.world
	return SaveCodec.encode(run, world)


func load_state(state: Dictionary) -> void:
	_pending_state = state.duplicate(true)
	if _entered:
		var restored_world: Dictionary = _prepare_run(_pending_state)
		_build_level(restored_world)
		if restored_world.is_empty() or get_phase() != PHASE_PLAY:
			get_world_state().set_phase(PHASE_INTRO)
		bubble.restore(run.bubble, _previous_profile())
		_refresh_screen()


func migrate_save(old_version: int, data: Dictionary) -> Dictionary:
	return SaveCodec.migrate(old_version, data)


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _entered or context == null or not context.input_enabled or bubble.active:
		return false
	var phase: StringName = get_phase()
	match command:
		&"move":
			if phase != PHASE_PLAY:
				return false
			_command_axis = clampf(float(payload.get("axis", 0.0)), -1.0, 1.0) if payload.get("axis", 0.0) is float or payload.get("axis", 0.0) is int else 0.0
			return true
		&"jump":
			if phase != PHASE_PLAY:
				return false
			_command_jump = bool(payload.get("pressed", false))
			return true
		&"tool":
			if phase != PHASE_PLAY:
				return false
			_command_tool = bool(payload.get("pressed", false))
			return true
		&"reset":
			return _reset_level()
		&"menu":
			requested.emit(&"menu", {})
			return true
		&"seed_run":
			var value: Variant = payload.get("seed", 0)
			if not RunState.seed_is_valid(value):
				return false
			_new_run(int(value))
			_build_level({})
			get_world_state().set_phase(PHASE_INTRO)
			_refresh_screen()
			return true
		&"abort":
			requested.emit(&"portal", {"exit": "back", "run_index": run.run_index})
			return true
	return false


func get_input_bubble_state() -> Dictionary:
	return bubble.get_input_bubble_state()


func get_bubble_state(action: Variant = null) -> Variant:
	return bubble.get_bubble_state(action)


func get_bubble_cell(action: Variant) -> Vector2i:
	return bubble.get_bubble_cell(action)


func set_key_profile(profile: Variant, previous_profile: Variant = null) -> bool:
	var accepted: bool = bubble.set_key_profile(profile, previous_profile)
	_refresh_screen()
	return accepted


func get_world_state() -> RefCounted:
	return director.world if director != null else null


func get_run_state() -> RefCounted:
	return run


func get_director() -> RefCounted:
	return director


func get_phase() -> StringName:
	var world: RefCounted = get_world_state()
	return world.phase if world != null else PHASE_INTRO


func get_level_spec() -> RefCounted:
	return director.spec if director != null else null


func _physics_process(delta: float) -> void:
	step(delta)


func step(delta: float) -> void:
	if not _entered or director == null:
		return
	var input: Dictionary = _sample_input()
	var world: RefCounted = director.world
	world.phase_time += delta
	last_events.clear()
	match world.phase:
		PHASE_INTRO:
			if bubble.active:
				bubble.advance(delta, input["pressed_edges"])
				if not bubble.active:
					run.bubble = bubble.to_save()
			elif world.phase_time >= Tuning.INTRO_DURATION:
				world.set_phase(PHASE_PLAY)
		PHASE_PLAY:
			if bool(input["reset_down"]):
				_reset_level()
			else:
				var events: Array[Dictionary] = director.tick(delta, input)
				_handle_events(events)
				if director.level_cleared:
					_on_level_cleared()
				elif director.player_dead:
					_on_player_dead()
		PHASE_DEAD:
			if bool(input["reset_down"]) or world.phase_time >= Tuning.DEAD_RECOVER_DELAY:
				_rebuild_same_slot(false)
		PHASE_CLEAR:
			if world.phase_time >= Tuning.CLEAR_DURATION and not run.run_complete:
				_build_level({})
				get_world_state().set_phase(PHASE_INTRO)
	_refresh_screen()


func _sample_input() -> Dictionary:
	var enabled: bool = context != null and context.input_enabled
	var held: Dictionary = {}
	for action: StringName in ACTIONS:
		held[action] = enabled and context.is_action_pressed(action)
	var edges: Dictionary = {}
	for action: StringName in ACTIONS:
		edges[String(action)] = bool(held[action]) and not bool(_previous.get(action, false))
	var axis_value: float = float(held[&"ppp_move_right"]) - float(held[&"ppp_move_left"])
	if axis_value == 0.0 and enabled:
		axis_value = _command_axis
	var jump: bool = bool(held[&"ppp_jump"]) or (enabled and _command_jump)
	var grab: bool = bool(held[&"ppp_grab"]) or (enabled and _command_tool)
	var reset: bool = bool(held[&"ppp_reset_level"])
	var result: Dictionary = {
		"axis": axis_value,
		"jump_held": jump,
		"jump_down": jump and not bool(_previous.get(&"jump_any", false)),
		"grab_held": grab,
		"grab_down": grab and not bool(_previous.get(&"grab_any", false)),
		"reset_down": reset and not bool(_previous.get(&"ppp_reset_level", false)),
		"pressed_edges": edges,
	}
	for action: StringName in ACTIONS:
		_previous[action] = held[action]
	_previous[&"jump_any"] = jump
	_previous[&"grab_any"] = grab
	if bubble.active:
		result["axis"] = 0.0
		result["jump_held"] = false
		result["jump_down"] = false
		result["grab_held"] = false
		result["grab_down"] = false
		result["reset_down"] = false
	return result


func _prepare_run(state: Dictionary) -> Dictionary:
	_pending_observations.clear()
	var level_ids: Array = content.level_order.duplicate()
	var tool_ids: Array = content.tool_order.duplicate()
	var decoded: Dictionary = SaveCodec.decode(state, level_ids, tool_ids)
	var arrival: Dictionary = context.arrival if context != null else {}
	var restored_world: Dictionary = {}
	var previous_index: int = 0
	if bool(decoded["rejected"]):
		_pending_observations.append({"id": "ppp.save_rejected", "meta": {"found_version": int(decoded["found_version"])}})
	var carried_bubble: Dictionary = {}
	if decoded["run"] != null:
		previous_index = decoded["run"].run_index
		carried_bubble = decoded["run"].bubble
	if _arrival_sequence(arrival, level_ids).size() == Tuning.LEVEL_COUNT:
		_new_fixed_run(arrival, level_ids, tool_ids, previous_index)
		run.bubble = carried_bubble
		return restored_world
	if decoded["run"] != null and not bool(decoded["resequence"]) and not decoded["run"].run_complete:
		run = decoded["run"]
		for slot: Variant in decoded["reassign_slots"]:
			run.sequence[int(slot)] = Selector.reassign_level(run.run_seed, int(slot), level_ids, content.mutable_by_level())
		for slot: Variant in decoded["reassign_tools"]:
			run.tool_ids[int(slot)] = Selector.reassign_tool(run.run_seed, int(slot), tool_ids)
		run.total_objectives = _sum_objectives()
		restored_world = decoded["world"]
		if not restored_world.is_empty() and (int(restored_world.get("slot", -1)) != run.cursor or String(restored_world.get("level_id", "")) != run.current_level_id()):
			restored_world = {}
		return restored_world
	var seed_value: Variant = arrival.get("ppp_seed", 0)
	var chosen: int = int(seed_value) if RunState.seed_is_valid(seed_value) else Selector.new_seed()
	_new_run(chosen, previous_index)
	run.bubble = carried_bubble
	return restored_world


func _new_run(run_seed: int, previous_index: int = -1) -> void:
	var prior_bubble: Dictionary = run.bubble.duplicate(true) if run != null else {}
	var prior_index: int = previous_index if previous_index >= 0 else (run.run_index if run != null else 0)
	run = RunState.new()
	run.run_seed = run_seed
	run.run_index = prior_index + 1
	run.bubble = prior_bubble
	var built: Dictionary = Selector.build(run_seed, content.level_order, content.tool_order, content.mutable_by_level())
	run.sequence = built["sequence"]
	run.tool_ids = built["tool_ids"]
	run.total_objectives = _sum_objectives()


func _new_fixed_run(arrival: Dictionary, level_ids: Array, tool_ids: Array, previous_index: int) -> void:
	var seed_value: Variant = arrival.get("ppp_seed", 0)
	var chosen: int = int(seed_value) if RunState.seed_is_valid(seed_value) else Selector.new_seed()
	_new_run(chosen, previous_index)
	var sequence: Array[String] = _arrival_sequence(arrival, level_ids)
	run.sequence.clear()
	for level_id: String in sequence:
		run.sequence.append({"level_id": level_id, "mutations": []})
	var tools_value: Variant = arrival.get("ppp_tools", [])
	if tools_value is Array and (tools_value as Array).size() == Tuning.TOOL_COUNT:
		var valid: bool = true
		for tool_id: Variant in tools_value:
			if not tool_id is String or not tool_ids.has(String(tool_id)):
				valid = false
		if valid:
			run.tool_ids.clear()
			for tool_id: Variant in tools_value:
				run.tool_ids.append(String(tool_id))
	var cursor_value: Variant = arrival.get("ppp_start_cursor", 0)
	if (cursor_value is int or cursor_value is float) and int(cursor_value) >= 0 and int(cursor_value) < Tuning.LEVEL_COUNT:
		run.cursor = int(cursor_value)
	run.total_objectives = _sum_objectives()


func _arrival_sequence(arrival: Dictionary, level_ids: Array) -> Array[String]:
	var result: Array[String] = []
	var value: Variant = arrival.get("ppp_sequence", [])
	if not value is Array or (value as Array).size() != Tuning.LEVEL_COUNT:
		return result
	for level_id: Variant in value:
		if not level_id is String or not level_ids.has(String(level_id)):
			result.clear()
			return result
		result.append(String(level_id))
	return result


func _sum_objectives() -> int:
	var total: int = 0
	for level_id: String in run.sequence_level_ids():
		var level: RefCounted = content.level(level_id)
		if level != null:
			total += level.objective_needed
	return total


func _previous_profile() -> Array:
	if context == null:
		return []
	var value: Variant = context.arrival.get("previous_key_profile", [])
	return value if value is Array else []


func _world_parent() -> Node:
	if _screen != null and _screen.has_method("get_world_parent"):
		return _screen.call("get_world_parent")
	return self


func _build_level(restored_world: Dictionary) -> void:
	var carried: Dictionary = {}
	if director != null:
		carried = {"slot": director.world.slot, "deaths": director.world.deaths, "resets": director.world.resets, "elapsed": director.world.elapsed, "tools_used": director.world.tools_used}
		director.teardown()
		director = null
	if _screen != null and _screen.has_method("clear_level"):
		_screen.call("clear_level")
	if run.cursor >= Tuning.LEVEL_COUNT:
		run.run_complete = true
		run.cursor = Tuning.LEVEL_COUNT
		return
	var base: RefCounted = content.level(run.current_level_id())
	if base == null:
		run.sequence[run.cursor] = Selector.reassign_level(run.run_seed, run.cursor, content.level_order, content.mutable_by_level())
		base = content.level(run.current_level_id())
	var mutated: Dictionary = Mutation.apply(base, run.current_mutations())
	director = StepDirector.new()
	director.setup(mutated["spec"], content.tools, _world_parent(), run.current_tool_id(), BodyMass.player_params(axis), RunState.cosmetic_seed(run.run_seed))
	director.world.slot = run.cursor
	director.world.applied_mutations = mutated["applied"]
	if not carried.is_empty() and int(carried["slot"]) == run.cursor:
		director.world.deaths = int(carried["deaths"])
		director.world.resets = int(carried["resets"])
		director.world.elapsed = float(carried["elapsed"])
		director.world.tools_used = int(carried["tools_used"])
	elif restored_world.is_empty():
		run.note_entered(run.current_level_id(), run.current_tool_id())
	if not restored_world.is_empty():
		var known: Array = director.known_spec_ids()
		director.restore(SaveCodec.filter_bodies(restored_world, known))
	if _screen != null and _screen.has_method("bind_level"):
		_screen.call("bind_level", director)


func _rebuild_same_slot(count_reset: bool) -> void:
	var was_dead: bool = get_phase() == PHASE_DEAD
	_build_level({})
	var world: RefCounted = get_world_state()
	if world == null:
		return
	if count_reset:
		world.resets += 1
		run.resets += 1
	world.set_phase(PHASE_PLAY)
	if was_dead:
		_command_axis = 0.0


func _reset_level() -> bool:
	var phase: StringName = get_phase()
	if run == null or run.run_complete or (phase != PHASE_PLAY and phase != PHASE_DEAD):
		return false
	_rebuild_same_slot(phase == PHASE_PLAY)
	_emit_audio([{"id": EVENT_RESET, "x": 0.0, "y": 0.0, "strength": 1.0}])
	return true


func _on_player_dead() -> void:
	var world: RefCounted = get_world_state()
	world.set_phase(PHASE_DEAD)
	world.deaths += 1
	run.deaths += 1


func _on_level_cleared() -> void:
	var world: RefCounted = get_world_state()
	world.set_phase(PHASE_CLEAR)
	var level_id: String = world.level_id
	if not run.completed_levels.has(run.cursor):
		run.completed_levels.append(run.cursor)
	requested.emit(&"observation", {"id": "ppp.%s.cleared" % level_id, "meta": {"deaths": world.deaths, "resets": world.resets, "elapsed": snappedf(world.elapsed, 0.01), "tools_used": world.tools_used}})
	run.cursor += 1
	_emit_audio([{"id": EVENT_LEVEL_CLEAR, "x": 0.0, "y": 0.0, "strength": 1.0}])
	if run.cursor >= Tuning.LEVEL_COUNT:
		run.cursor = Tuning.LEVEL_COUNT
		run.run_complete = true
		var unseen: int = content.level_order.size() - run.levels_seen.size()
		requested.emit(&"observation", {"id": "ppp.run.completed", "meta": {"run_index": run.run_index, "levels_cleared": run.completed_levels.size(), "levels_total": Tuning.LEVEL_COUNT, "deaths": run.deaths, "resets": run.resets, "tools_used": run.tools_used, "unseen_levels": unseen}})
		_emit_audio([{"id": EVENT_RUN_CLEAR, "x": 0.0, "y": 0.0, "strength": 1.0}])
		requested.emit(&"portal", {"exit": "forward", "run_index": run.run_index})


func _handle_events(events: Array[Dictionary]) -> void:
	for event: Dictionary in events:
		if event["id"] == EVENT_TOOL_USE:
			run.tools_used += 1
	_emit_audio(events)


func _emit_audio(events: Array) -> void:
	for event: Dictionary in events:
		var id: StringName = StringName(event["id"])
		event_counts[id] = int(event_counts.get(id, 0)) + 1
		last_events.append(event)
	if _audio != null and _audio.has_method("play_events"):
		_audio.call("play_events", events)
	if _screen != null and _screen.has_method("on_events"):
		_screen.call("on_events", events)


func _refresh_screen() -> void:
	if _screen != null and _screen.has_method("refresh"):
		_screen.call("refresh")


func _ensure_actions() -> void:
	for action: StringName in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code: Variant in KEYS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = code
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)
