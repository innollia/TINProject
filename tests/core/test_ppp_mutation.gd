extends GutTest

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const LevelSpec = preload("res://modules/physics_puzzle_platformer/domain/level_spec.gd")
const Mutation = preload("res://modules/physics_puzzle_platformer/systems/mutation.gd")
const Selector = preload("res://modules/physics_puzzle_platformer/systems/selector.gd")
const LevelFactory = preload("res://modules/physics_puzzle_platformer/systems/level_factory.gd")
const Kinematics = preload("res://modules/physics_puzzle_platformer/systems/kinematics.gd")

const ALL_OPS: Array[String] = ["gravity_scale", "material_swap", "prop_size", "prop_offset", "wind", "hazard_shift"]

var _viewports: Array[SubViewport] = []


func after_each() -> void:
	for viewport: SubViewport in _viewports:
		if is_instance_valid(viewport):
			remove_child(viewport)
			viewport.free()
	_viewports.clear()


func _level_data() -> Dictionary:
	return {
		"schema": 1, "id": "lvl_mut_probe", "name": "probe", "parallax_seed": 7,
		"spawn": {"x": 100, "y": 400}, "rift": {"x": 1500, "y": 400, "radius": 30},
		"bounds": {"min_x": 0, "max_x": 1700, "min_y": 0, "max_y": 700},
		"objective_needed": 1,
		"mutable": ALL_OPS.duplicate(),
		"mutable_hazards": [5, 6],
		"shuffled": [2],
		"kinematics": [{"id": "lift", "from": [800, 500], "to": [800, 300], "duration": 2.0, "loop": "pingpong"}],
		"bodies": [
			{"id": "floor", "kind": "tile_static", "shape": "box", "material": "stone", "pos": [850, 650], "size": [1700, 40]},
			{"id": "lift", "kind": "tile_kinematic", "shape": "box", "material": "wood", "pos": [800, 500], "size": [120, 20]},
			{"id": "crate", "kind": "prop_dynamic", "shape": "box", "material": "wood", "pos": [1650, 600], "size": [40, 40]},
			{"id": "sleeper", "kind": "prop_sleeping", "shape": "circle", "material": "glass", "pos": [400, 600], "size": [30, 30]},
			{"id": "rock", "kind": "obstacle_dynamic", "shape": "hull", "material": "stone", "pos": [600, 600], "points": [[-20, 20], [20, 20], [0, -20]]},
			{"id": "spike_a", "kind": "hazard_static", "shape": "triangle", "material": "iron", "pos": [300, 620], "size": [40, 20]},
			{"id": "spike_b", "kind": "hazard_static", "shape": "triangle", "material": "iron", "pos": [1200, 620], "size": [40, 20]},
			{"id": "egg", "kind": "objective", "shape": "circle", "material": "clockwork", "pos": [1000, 600], "size": [22, 22]},
			{"id": "leaf", "kind": "decor_dynamic", "shape": "box", "material": "paper", "pos": [30, 600], "size": [16, 8]},
		],
	}


func _spec(data: Dictionary = {}) -> RefCounted:
	var source: Dictionary = data if not data.is_empty() else _level_data()
	var parsed: Dictionary = LevelSpec.new().parse(source, "", [])
	assert_true(bool(parsed["ok"]), "probe level parses: %s" % str(parsed["errors"]))
	return parsed["spec"]


func _parent() -> Node2D:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	add_child(viewport)
	_viewports.append(viewport)
	var parent := Node2D.new()
	viewport.add_child(parent)
	LevelFactory.configure_space(parent.get_world_2d().space)
	return parent


func _geometry(spec: RefCounted) -> String:
	var parts: Array = [spec.spawn, spec.rift_pos, spec.rift_radius, spec.bounds, spec.parallax_seed, spec.objective_needed]
	for body: RefCounted in spec.bodies:
		if body.kind == BodyKind.TILE_STATIC or body.kind == BodyKind.TILE_KINEMATIC or body.kind == BodyKind.TOOL_PLACEMENT:
			parts.append([body.id, body.pos, body.size, body.points, body.angle, body.material])
	for entry: Dictionary in spec.kinematics:
		parts.append([entry["id"], entry["from"], entry["to"], entry["duration"], entry["loop"]])
	return var_to_str(parts)


func test_gravity_scale_changes_only_dynamic_bodies() -> void:
	var base: RefCounted = _spec()
	var mutated: RefCounted = Mutation.apply(base, [{"op": "gravity_scale", "arg": 1.45}])["spec"]
	var plain: Dictionary = LevelFactory.build(base, {}, _parent(), "", {"mass": 1.0, "scale": 1.0})
	var heavy: Dictionary = LevelFactory.build(mutated, {}, _parent(), "", {"mass": 1.0, "scale": 1.0})
	var rigid_count: int = 0
	for index: int in heavy["nodes"].size():
		var node: Node = heavy["nodes"][index]
		var other: Node = plain["nodes"][index]
		if node is RigidBody2D:
			rigid_count += 1
			assert_almost_eq((node as RigidBody2D).gravity_scale, 1.45, 0.0001, "%s scaled" % node.name)
			assert_almost_eq((other as RigidBody2D).gravity_scale, 1.0, 0.0001)
		else:
			assert_eq((node as Node2D).position, (other as Node2D).position, "%s untouched" % node.name)
			assert_false("gravity_scale" in node, "%s has no gravity" % node.name)
	assert_gt(rigid_count, 5)
	assert_eq(_geometry(mutated), _geometry(base))


func test_material_swap_targets_shuffled_only() -> void:
	var base: RefCounted = _spec()
	for choice: int in 7:
		var mutated: RefCounted = Mutation.apply(base, [{"op": "material_swap", "arg": choice}])["spec"]
		for index: int in base.bodies.size():
			if index == base.shuffled[0]:
				assert_ne(mutated.bodies[index].material, base.bodies[index].material, "the shuffled body changes material")
			else:
				assert_eq(mutated.bodies[index].material, base.bodies[index].material, "%s keeps its material" % base.bodies[index].id)
	var none: Dictionary = _level_data()
	none["shuffled"] = []
	none["mutable"] = ["gravity_scale"]
	var empty: RefCounted = _spec(none)
	var result: Dictionary = Mutation.apply(empty, [{"op": "material_swap", "arg": 3}])
	assert_eq(result["applied"].size(), 0, "no shuffled array, nothing to swap")


func test_prop_size_scales_shape_not_mass() -> void:
	var base: RefCounted = _spec()
	var mutated: RefCounted = Mutation.apply(base, [{"op": "prop_size", "arg": 1.3}])["spec"]
	var checked: int = 0
	for index: int in base.bodies.size():
		var before: RefCounted = base.bodies[index]
		var after: RefCounted = mutated.bodies[index]
		if BodyKind.is_mutation_prop(before.kind):
			checked += 1
			assert_almost_eq(after.size.x, before.size.x * 1.3, 0.001, before.id)
			assert_almost_eq(after.size.y, before.size.y * 1.3, 0.001, before.id)
			assert_almost_eq(after.mass(), before.mass(), 0.0001, "%s keeps its mass" % before.id)
		else:
			assert_eq(after.size, before.size, "%s keeps its size" % before.id)
	assert_eq(checked, 4)
	var built: Dictionary = LevelFactory.build(mutated, {}, _parent(), "", {"mass": 1.0, "scale": 1.0})
	for index: int in built["world"].bodies.size():
		var runtime: RefCounted = built["world"].bodies[index]
		if runtime.spec_id == "crate":
			var shape: RectangleShape2D = (built["nodes"][index] as Node).get_node("Shape").shape
			assert_almost_eq(shape.size.x, 52.0, 0.001, "collision shape grows")
			assert_almost_eq((built["nodes"][index] as RigidBody2D).mass, base.body_by_id("crate").mass(), 0.0001, "node mass stays")


func test_prop_offset_reflects_at_bounds() -> void:
	var base: RefCounted = _spec()
	var right: RefCounted = Mutation.apply(base, [{"op": "prop_offset", "arg": 56.0}])["spec"]
	assert_almost_eq(right.body_by_id("crate").pos.x, 1694.0, 0.001, "1650 + 56 reflects off 1700")
	assert_almost_eq(right.body_by_id("sleeper").pos.x, 456.0, 0.001)
	var left: RefCounted = Mutation.apply(base, [{"op": "prop_offset", "arg": -56.0}])["spec"]
	assert_almost_eq(left.body_by_id("leaf").pos.x, 26.0, 0.001, "30 - 56 reflects off 0")
	for spec: RefCounted in [right, left]:
		for body: RefCounted in spec.bodies:
			assert_true(spec.bounds.has_point(body.pos) or body.pos.x == spec.bounds.end.x, "%s stays inside bounds" % body.id)
		assert_eq(spec.body_by_id("egg").pos, base.body_by_id("egg").pos, "objectives never move")
		assert_eq(spec.body_by_id("spike_a").pos, base.body_by_id("spike_a").pos)


func test_wind_only_affects_kinematic() -> void:
	var base: RefCounted = _spec()
	var mutated: RefCounted = Mutation.apply(base, [{"op": "wind", "arg": 190.0}])["spec"]
	assert_almost_eq(mutated.wind_x, 190.0, 0.001)
	assert_eq(_geometry(mutated), _geometry(base), "the authored path itself is unchanged")
	var path: Dictionary = mutated.kinematic_for("lift")
	var calm: Vector2 = Kinematics.position_at(path, 1.0, base.wind_x)
	var windy: Vector2 = Kinematics.position_at(path, 1.0, mutated.wind_x)
	assert_gt(absf(windy.x - calm.x), 1.0, "wind pushes the moving tile sideways mid path")
	assert_almost_eq(Kinematics.position_at(path, 0.0, mutated.wind_x).x, path["from"].x, 0.001, "wind ramps to zero at the ends")
	assert_almost_eq(Kinematics.position_at(path, 2.0, mutated.wind_x).x, path["to"].x, 0.001)
	for index: int in base.bodies.size():
		assert_eq(mutated.bodies[index].pos, base.bodies[index].pos, "%s does not move" % base.bodies[index].id)


func test_hazard_shift_rotates_list() -> void:
	var base: RefCounted = _spec()
	var shifted: RefCounted = Mutation.apply(base, [{"op": "hazard_shift", "arg": 0}])["spec"]
	assert_eq(shifted.body_by_id("spike_a").pos, base.body_by_id("spike_b").pos)
	assert_eq(shifted.body_by_id("spike_b").pos, base.body_by_id("spike_a").pos)
	var single: Dictionary = _level_data()
	single["mutable_hazards"] = [5]
	single["mutable"] = ["gravity_scale"]
	var one: RefCounted = _spec(single)
	var result: Dictionary = Mutation.apply(one, [{"op": "hazard_shift", "arg": 1}])
	assert_eq(result["applied"].size(), 0)
	assert_eq(result["spec"].body_by_id("spike_a").pos, one.body_by_id("spike_a").pos, "one hazard, no change")


func test_mutations_never_touch_geometry() -> void:
	var base: RefCounted = _spec()
	var reference: String = _geometry(base)
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var spec: RefCounted = base
	for round_index: int in 1000:
		var op: String = ALL_OPS[round_index % ALL_OPS.size()]
		spec = Mutation.apply(spec, [{"op": op, "arg": Selector.pick_arg(rng, op)}])["spec"]
	assert_eq(_geometry(spec), reference)


func test_mutations_are_deterministic_given_seed() -> void:
	var first := RandomNumberGenerator.new()
	var second := RandomNumberGenerator.new()
	first.seed = 31337
	second.seed = 31337
	for _draw: int in 200:
		var a: Array = Selector.pick_mutations(first, ALL_OPS)
		var b: Array = Selector.pick_mutations(second, ALL_OPS)
		assert_eq(var_to_str(a), var_to_str(b))
	var base: RefCounted = _spec()
	var list: Array = [{"op": "prop_size", "arg": 0.78}, {"op": "hazard_shift", "arg": 1}]
	var once: RefCounted = Mutation.apply(base, list)["spec"]
	var twice: RefCounted = Mutation.apply(base, list)["spec"]
	for index: int in once.bodies.size():
		assert_eq(once.bodies[index].pos, twice.bodies[index].pos)
		assert_eq(once.bodies[index].size, twice.bodies[index].size)


func test_empty_mutable_produces_no_mutation() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var produced: int = 0
	for _draw: int in 10000:
		produced += Selector.pick_mutations(rng, []).size()
	assert_eq(produced, 0)
	var built: Dictionary = Selector.build(12, ["lvl_plain"], ["tool_x"], {"lvl_plain": []})
	for entry: Dictionary in built["sequence"]:
		assert_eq((entry["mutations"] as Array).size(), 0)


func test_rejects_unknown_mutable_op() -> void:
	var data: Dictionary = _level_data()
	data["mutable"] = ["gravity_scale_mul"]
	var parsed: Dictionary = LevelSpec.new().parse(data, "", [])
	assert_false(bool(parsed["ok"]))
