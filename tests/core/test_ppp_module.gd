extends GutTest

const ENTRY: PackedScene = preload("res://modules/physics_puzzle_platformer/entry.tscn")
const MANIFEST: ModuleManifest = preload("res://modules/physics_puzzle_platformer/module_manifest.tres")
const InputBubble = preload("res://modules/physics_puzzle_platformer/systems/input_bubble.gd")

const CHALK: String = "lvl_chalk_shelf"
const FAN: String = "tool_paper_fan"

var _modules: Array[Node] = []


func after_each() -> void:
	for action: String in MANIFEST.input_actions:
		if InputMap.has_action(action):
			Input.action_release(action)
	for module: Node in _modules:
		if is_instance_valid(module):
			module.exit()
			if module.get_parent() != null:
				module.get_parent().remove_child(module)
			module.free()
	_modules.clear()


func _context(arrival: Dictionary) -> ModuleContext:
	var context := ModuleContext.new()
	context.module_id = MANIFEST.id
	context.input_enabled = true
	for action: String in MANIFEST.input_actions:
		context.allowed_actions.append(StringName(action))
	context.arrival = arrival
	return context


func _spawn(arrival: Dictionary, state: Dictionary = {}) -> Node:
	var module: Node = ENTRY.instantiate()
	add_child(module)
	_modules.append(module)
	module.load_state(state)
	module.enter(_context(arrival))
	return module


func _fixed_arrival(level_id: String, tool_id: String, run_seed: int = 4242) -> Dictionary:
	var levels: Array = []
	var tools: Array = []
	for _index: int in 8:
		levels.append(level_id)
		tools.append(tool_id)
	return {"ppp_seed": run_seed, "ppp_sequence": levels, "ppp_tools": tools}


func _finish_intro(module: Node) -> void:
	for action: String in InputBubble.PROFILE:
		module.bubble.pop(action)
	module.step(0.5)
	module.step(1.0)


func _player_node(module: Node) -> RigidBody2D:
	return module.get_director().player_node()


func _teleport(module: Node, target: Vector2) -> void:
	var node: RigidBody2D = _player_node(module)
	node.global_position = target
	node.linear_velocity = Vector2.ZERO


func _walk_until(module: Node, axis: float, predicate: Callable, limit: int = 240) -> bool:
	assert_true(module.execute_command(&"move", {"axis": axis}), "move accepted")
	for _frame: int in limit:
		await wait_physics_frames(1)
		if _frame % 20 == 0:
			var world: RefCounted = module.get_world_state()
			var p: RefCounted = world.player()
			var egg: int = world.find("egg_high")
			var egg_text: String = "none"
			if egg >= 0:
				var e: RefCounted = world.bodies[egg]
				egg_text = "%s,%s d=%s s=%s" % [e.x, e.y, e.destroyed, e.sleeping]
			gut.p("DIAG f=%d phase=%s p=(%.1f,%.1f) v=(%.1f,%.1f) grounded=%s count=%d egg=%s" % [_frame, module.get_phase(), p.x, p.y, p.vx, p.vy, module.get_director().grounded, world.objective_count, egg_text])
		if predicate.call():
			module.execute_command(&"move", {"axis": 0.0})
			return true
	module.execute_command(&"move", {"axis": 0.0})
	return false


func test_wave3_chalk_shelf_session_clears_and_reloads() -> void:
	var module: Node = _spawn(_fixed_arrival(CHALK, FAN))
	assert_eq(module.get_phase(), &"intro", "enter starts in intro")
	assert_true(module.bubble.active, "first entry shows the input bubble")
	_finish_intro(module)
	assert_eq(module.get_phase(), &"play", "bubble then intro leads to play")
	var world: RefCounted = module.get_world_state()
	assert_eq(world.level_id, CHALK)
	assert_eq(world.objective_needed, 2)
	assert_true(world.held_tool_index() >= 0, "dealt tool is in hand")
	_teleport(module, Vector2(240.0, 470.0))
	var first: bool = await _walk_until(module, 1.0, func() -> bool: return world.objective_count >= 1)
	assert_true(first, "walking into the low egg collects it")
	_teleport(module, Vector2(650.0, 330.0))
	await wait_physics_frames(20)
	var second: bool = await _walk_until(module, 1.0, func() -> bool: return world.objective_count >= 2)
	assert_true(second, "walking along the shelf collects the high egg")
	assert_true(world.rift_open, "rift opens at the needed count")
	var saved_mid: Dictionary = module.save_state()
	assert_true(SaveService.is_json_safe(saved_mid), "mid level save is JSON safe")
	assert_eq(int(saved_mid["world"]["objective_count"]), 2)
	watch_signals(module)
	_teleport(module, Vector2(1290.0, 470.0))
	var cleared: bool = await _walk_until(module, 1.0, func() -> bool: return module.get_phase() == &"clear")
	assert_true(cleared, "entering the open rift clears the level")
	assert_signal_emitted(module, "requested")
	assert_eq(module.get_run_state().cursor, 1, "cursor advances on clear")
	for _tick: int in 130:
		module.step(1.0 / 120.0)
	assert_eq(module.get_phase(), &"intro", "next slot starts with intro")
	assert_eq(module.get_world_state().slot, 1)
	for _tick: int in 120:
		module.step(1.0 / 120.0)
	assert_eq(module.get_phase(), &"play")
	var saved: Dictionary = module.save_state()
	var reloaded: Node = _spawn({}, saved)
	assert_eq(reloaded.get_run_state().cursor, 1, "reload keeps the cursor")
	assert_eq(reloaded.get_run_state().run_seed, module.get_run_state().run_seed, "reload keeps the seed")
	assert_eq(reloaded.get_world_state().level_id, CHALK)
	assert_false(reloaded.bubble.active, "bubble does not return after it was completed")
	var loaded_mid: Node = _spawn({}, saved_mid)
	assert_eq(loaded_mid.get_world_state().objective_count, 2, "partial progress survives load")
	assert_eq(loaded_mid.get_run_state().cursor, 0)
