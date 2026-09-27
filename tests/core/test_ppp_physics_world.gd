extends GutTest

const ENTRY: PackedScene = preload("res://modules/physics_puzzle_platformer/entry.tscn")
const MANIFEST: ModuleManifest = preload("res://modules/physics_puzzle_platformer/module_manifest.tres")
const InputBubble = preload("res://modules/physics_puzzle_platformer/systems/input_bubble.gd")
const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const KIT: String = "res://modules/physics_puzzle_platformer/"

var _modules: Array[Node] = []


func after_each() -> void:
	for module: Node in _modules:
		if is_instance_valid(module):
			module.exit()
			remove_child(module)
			module.free()
	_modules.clear()


func _spawn(level_id: String = "lvl_chalk_shelf", pop: bool = true, state: Dictionary = {}) -> Node:
	var module: Node = ENTRY.instantiate()
	add_child(module)
	_modules.append(module)
	var context := ModuleContext.new()
	context.module_id = MANIFEST.id
	context.input_enabled = true
	for action: String in MANIFEST.input_actions:
		context.allowed_actions.append(StringName(action))
	var levels: Array = []
	var tools: Array = []
	for _i: int in 8:
		levels.append(level_id)
		tools.append("tool_paper_fan")
	context.arrival = {"ppp_seed": 99, "ppp_sequence": levels, "ppp_tools": tools} if state.is_empty() else {}
	module.load_state(state)
	module.enter(context)
	if pop:
		for action: String in InputBubble.PROFILE:
			module.bubble.pop(action)
		module.step(0.5)
		module.step(1.0)
	return module


func _sources(folders: Array = ["", "domain", "systems", "presentation"]) -> Dictionary:
	var result: Dictionary = {}
	for folder: String in folders:
		var path: String = KIT + folder
		var dir := DirAccess.open(path)
		if dir == null:
			continue
		for file: String in dir.get_files():
			if file.ends_with(".gd") or file.ends_with(".tscn"):
				result[folder + "/" + file] = FileAccess.get_file_as_string(path.path_join(file))
	return result

const InteractionRules = preload("res://modules/physics_puzzle_platformer/domain/interaction_rules.gd")


func test_player_is_rigid_body() -> void:
	var module: Node = _spawn()
	assert_true(module.get_director().player_node() is RigidBody2D)


func test_interaction_table_is_complete() -> void:
	for a: int in range(1, 14):
		for b: int in range(1, 14):
			assert_ne(String(InteractionRules.rule_for(a, b)), "", "%d x %d" % [a, b])


func test_player_pushes_prop() -> void:
	var module: Node = _spawn()
	var world: RefCounted = module.get_world_state()
	var crate: int = world.find("crate")
	var start_x: float = world.bodies[crate].x
	var node: RigidBody2D = module.get_director().player_node()
	module.get_director().place_rigid(node, Vector2(start_x - 60.0, 470.0))
	module.execute_command(&"move", {"axis": 1.0})
	for _i: int in 90:
		await wait_physics_frames(1)
	module.execute_command(&"move", {"axis": 0.0})
	assert_gt(world.bodies[crate].x, start_x + 4.0, "walking into the paper crate moves it")


func test_offmap_fall_is_death_and_recovers() -> void:
	var module: Node = _spawn()
	var node: RigidBody2D = module.get_director().player_node()
	module.get_director().place_rigid(node, Vector2(600.0, 760.0))
	var died: bool = false
	for _i: int in 20:
		await wait_physics_frames(1)
		if module.get_phase() == &"dead":
			died = true
			break
	assert_true(died, "falling below bounds kills")
	for _i: int in 120:
		await wait_physics_frames(1)
	assert_eq(module.get_phase(), &"play", "auto recovers after the delay")
	assert_eq(module.get_world_state().deaths, 1)


func test_reset_rebuilds_level() -> void:
	var module: Node = _spawn()
	var sequence: String = var_to_str(module.get_run_state().sequence)
	assert_true(module.execute_command(&"reset", {}))
	assert_eq(module.get_world_state().objective_count, 0)
	assert_eq(module.get_world_state().resets, 1)
	assert_eq(var_to_str(module.get_run_state().sequence), sequence)


func test_every_level_builds_all_bodies() -> void:
	for level_id: String in ["lvl_hollow_keyhole", "lvl_lifting_slab", "lvl_wind_ledger"]:
		var module: Node = _spawn(level_id)
		var director: RefCounted = module.get_director()
		for index: int in director.world.bodies.size():
			assert_not_null(director.nodes[index], "%s body %d has a node" % [level_id, index])
		after_each()