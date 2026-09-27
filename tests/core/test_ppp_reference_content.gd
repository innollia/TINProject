extends GutTest

const ENTRY: PackedScene = preload("res://modules/physics_puzzle_platformer/entry.tscn")
const MANIFEST: ModuleManifest = preload("res://modules/physics_puzzle_platformer/module_manifest.tres")
const ContentIndex = preload("res://modules/physics_puzzle_platformer/systems/content_index.gd")
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


func _content() -> RefCounted:
	return ContentIndex.new().read_default()


func _spawn_level(level_id: String) -> Node:
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
	context.arrival = {"ppp_seed": 77, "ppp_sequence": levels, "ppp_tools": tools}
	module.load_state({})
	module.enter(context)
	for action: String in InputBubble.PROFILE:
		module.bubble.pop(action)
	module.step(0.5)
	module.step(1.0)
	return module


func _place(module: Node, at: Vector2) -> void:
	var node: RigidBody2D = module.get_director().player_node()
	module.get_director().place_rigid(node, at)
	node.linear_velocity = Vector2.ZERO


func test_every_level_is_collectable_and_clearable() -> void:
	for level_id: String in _content().level_order:
		var module: Node = _spawn_level(level_id)
		assert_eq(module.get_phase(), &"play", "%s reaches play" % level_id)
		var world: RefCounted = module.get_world_state()
		var eggs: Array[String] = []
		for body: RefCounted in world.bodies:
			if body.kind == BodyKind.OBJECTIVE:
				eggs.append(body.spec_id)
		for egg_id: String in eggs:
			var index: int = world.find(egg_id)
			if index < 0 or world.bodies[index].destroyed:
				continue
			var before: int = world.objective_count
			var ok: bool = false
			for _try: int in 40:
				index = world.find(egg_id)
				if world.bodies[index].destroyed:
					ok = true
					break
				_place(module, world.bodies[index].position())
				await wait_physics_frames(1)
			assert_true(ok and world.objective_count == before + 1, "%s: %s is reachable by touch" % [level_id, egg_id])
		assert_true(world.rift_open, "%s: rift opens" % level_id)
		var rift: RefCounted = module.get_director().rift()
		var cleared: bool = false
		for _try: int in 40:
			_place(module, rift.position())
			await wait_physics_frames(1)
			if module.get_phase() == &"clear":
				cleared = true
				break
		assert_true(cleared, "%s: entering the rift clears" % level_id)
		after_each()


func test_eight_levels_have_distinct_geometry() -> void:
	var content: RefCounted = _content()
	var seen: Dictionary = {}
	for level_id: String in content.level_order:
		var key: Array = []
		for body: RefCounted in content.level(level_id).bodies:
			key.append([body.id, body.pos.x, body.pos.y])
		var text: String = var_to_str(key)
		assert_false(seen.has(text), "%s geometry is unique" % level_id)
		seen[text] = true
	assert_true(content.level_order.size() >= 8)


func test_every_level_has_objective_and_rift() -> void:
	var content: RefCounted = _content()
	for level_id: String in content.level_order:
		var spec: RefCounted = content.level(level_id)
		assert_true(spec.objective_needed >= 1)
		assert_true(spec.rift_radius > 0.0, level_id)


func test_every_level_bounds_fit_viewport() -> void:
	var content: RefCounted = _content()
	for level_id: String in content.level_order:
		var bounds: Rect2 = content.level(level_id).bounds
		assert_true(bounds.size.x >= 1600.0 and bounds.size.y >= 640.0, level_id)


func test_tool_index_covers_all_referenced_tools() -> void:
	var content: RefCounted = _content()
	for level_id: String in content.level_order:
		for body: RefCounted in content.level(level_id).bodies:
			if not String(body.tool).is_empty():
				assert_true(content.tool_order.has(String(body.tool)), "%s names %s" % [level_id, body.tool])


func test_no_solution_data_in_content() -> void:
	for text: String in _json_texts():
		for key: String in ["\"solution\"", "\"answer\"", "\"hint\""]:
			assert_false(text.contains(key))


func test_domain_has_no_content_id_literals() -> void:
	var content: RefCounted = _content()
	var ids: Array = content.level_order + content.tool_order
	for folder: String in ["domain", "systems"]:
		var dir := DirAccess.open(KIT + folder)
		for file: String in dir.get_files():
			if not file.ends_with(".gd"):
				continue
			var text: String = FileAccess.get_file_as_string(KIT + folder + "/" + file)
			for id: Variant in ids:
				assert_false(text.contains("\"%s\"" % id), "%s/%s names %s" % [folder, file, id])


func test_all_kinds_appear_across_levels() -> void:
	var content: RefCounted = _content()
	var kinds: Dictionary = {}
	for level_id: String in content.level_order:
		for body: RefCounted in content.level(level_id).bodies:
			kinds[body.kind] = true
	for kind: int in [BodyKind.TILE_STATIC, BodyKind.TILE_KINEMATIC, BodyKind.PROP_DYNAMIC, BodyKind.PROP_SLEEPING, BodyKind.OBSTACLE_DYNAMIC, BodyKind.DECOR_DYNAMIC, BodyKind.OBJECTIVE, BodyKind.HAZARD_STATIC, BodyKind.HAZARD_AREA, BodyKind.TOOL_PLACEMENT]:
		assert_true(kinds.has(kind), "kind %d appears" % kind)


func test_all_mutation_ops_exercised() -> void:
	var content: RefCounted = _content()
	var declared: int = 0
	var ops: Dictionary = {}
	for level_id: String in content.level_order:
		var mutable: Array = content.level(level_id).mutable
		if not mutable.is_empty():
			declared += 1
		for op: Variant in mutable:
			ops[String(op)] = true
	assert_true(declared >= 3)
	assert_eq(ops.size(), 6)


func _json_texts() -> Array[String]:
	var result: Array[String] = []
	for folder: String in ["content/levels", "content/tools"]:
		var dir := DirAccess.open(KIT + folder)
		for file: String in dir.get_files():
			if file.ends_with(".json"):
				result.append(FileAccess.get_file_as_string(KIT + folder + "/" + file))
	return result
