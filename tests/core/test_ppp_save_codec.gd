extends GutTest

const ENTRY: PackedScene = preload("res://modules/physics_puzzle_platformer/entry.tscn")
const MANIFEST: ModuleManifest = preload("res://modules/physics_puzzle_platformer/module_manifest.tres")
const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const SaveCodec = preload("res://modules/physics_puzzle_platformer/domain/save_codec.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")
const ContentIndex = preload("res://modules/physics_puzzle_platformer/systems/content_index.gd")
const InputBubble = preload("res://modules/physics_puzzle_platformer/systems/input_bubble.gd")

var _modules: Array[Node] = []


func after_each() -> void:
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


func _content() -> RefCounted:
	return ContentIndex.new().read_default()


func _first_level() -> String:
	return String(_content().level_order[0])


func _first_tool() -> String:
	return String(_content().tool_order[0])


func _fixed_arrival(run_seed: int = 777) -> Dictionary:
	var levels: Array = []
	var tools: Array = []
	for _index: int in Tuning.LEVEL_COUNT:
		levels.append(_first_level())
		tools.append(_first_tool())
	return {"ppp_seed": run_seed, "ppp_sequence": levels, "ppp_tools": tools}


func _playing(arrival: Dictionary = {}) -> Node:
	var module: Node = _spawn(arrival if not arrival.is_empty() else _fixed_arrival())
	for action: String in InputBubble.PROFILE:
		module.bubble.pop(action)
	module.step(0.5)
	module.step(1.0)
	assert_eq(module.get_phase(), &"play")
	return module


func _find_type(value: Variant, predicate: Callable, path: String = "") -> Array[String]:
	var hits: Array[String] = []
	if predicate.call(value):
		hits.append(path)
	if value is Dictionary:
		for key: Variant in value:
			if predicate.call(key):
				hits.append(path + "/<key>")
			hits.append_array(_find_type(value[key], predicate, path + "/" + str(key)))
	elif value is Array:
		for index: int in (value as Array).size():
			hits.append_array(_find_type(value[index], predicate, path + "/" + str(index)))
	return hits


func _keys(value: Variant) -> Array[String]:
	var found: Array[String] = []
	if value is Dictionary:
		for key: Variant in value:
			found.append(str(key))
			found.append_array(_keys(value[key]))
	elif value is Array:
		for item: Variant in value:
			found.append_array(_keys(item))
	return found


func test_round_trip_preserves_state() -> void:
	var module: Node = _playing()
	for _tick: int in 30:
		module.step(Tuning.FIXED_DT)
	var first: Dictionary = module.save_state()
	var loaded: Node = _spawn({}, JSON.parse_string(JSON.stringify(first)))
	var second: Dictionary = loaded.save_state()
	assert_eq(JSON.stringify(second), JSON.stringify(first))
	var third: Dictionary = _spawn({}, second).save_state()
	assert_eq(JSON.stringify(third), JSON.stringify(first))


func test_round_trip_preserves_partial_progress() -> void:
	var module: Node = _playing()
	var saved: Dictionary = module.save_state()
	var world: Dictionary = saved["world"]
	world["objective_count"] = 1
	world["player_hp"] = 3.0
	var marked: bool = false
	for body: Dictionary in world["bodies"]:
		if int(body["kind"]) == BodyKind.OBJECTIVE and not marked:
			body["destroyed"] = true
			body["collected"] = true
			marked = true
	assert_true(marked)
	var loaded: Node = _spawn({}, saved)
	var state: RefCounted = loaded.get_world_state()
	assert_eq(state.objective_count, 1)
	assert_almost_eq(state.player_hp, 3.0, 0.0001)
	assert_true(state.held_tool_index() >= 0, "the tool is still in hand")
	var again: Dictionary = loaded.save_state()
	assert_eq(int(again["world"]["objective_count"]), 1)
	assert_almost_eq(float(again["world"]["player_hp"]), 3.0, 0.0001)
	var held: int = 0
	for body: Dictionary in again["world"]["bodies"]:
		if bool(body["held"]):
			held += 1
	assert_eq(held, 1)


func _raw_world(bodies: Array) -> Dictionary:
	return {"slot": 0, "level_id": "lvl_x", "phase": "play", "objective_needed": 2, "objective_count": 0, "bodies": bodies}


func _raw_body(spec_id: String, kind: int, x: Variant) -> Dictionary:
	return {"spec_id": spec_id, "kind": kind, "x": x, "y": 10.0, "angle": 0.0, "vx": 0.0, "vy": 0.0, "av": 0.0, "hp": 3.0, "t": 0.0, "tool_cooldown": 0.0}


func test_drops_non_finite_numbers() -> void:
	for bad: float in [NAN, INF, -INF]:
		var world: Dictionary = SaveCodec.sanitize_world(_raw_world([_raw_body("crate", BodyKind.PROP_DYNAMIC, bad)]))
		var body: Dictionary = world["bodies"][0]
		assert_eq(float(body["x"]), 0.0)
		assert_true(bool(body["destroyed"]), "non finite %s marks the body destroyed" % str(bad))
	var encoded: Dictionary = SaveCodec.sanitize_world(_raw_world([_raw_body("crate", BodyKind.PROP_DYNAMIC, 12.5)]))
	assert_false(bool(encoded["bodies"][0]["destroyed"]))


func test_no_vector_in_payload() -> void:
	var saved: Dictionary = _playing().save_state()
	var vectors: Array[String] = _find_type(saved, func(value: Variant) -> bool: return value is Vector2 or value is Vector2i or value is Vector3 or value is Rect2 or value is Transform2D or value is Color)
	assert_eq(vectors, [] as Array[String])
	assert_true(SaveService.is_json_safe(saved))


func test_no_node_in_payload() -> void:
	var saved: Dictionary = _playing().save_state()
	var objects: Array[String] = _find_type(saved, func(value: Variant) -> bool: return value is Object or value is Callable or value is Signal or value is RID or value is StringName or value is NodePath)
	assert_eq(objects, [] as Array[String])


func test_removes_unknown_body_ids() -> void:
	var module: Node = _playing()
	var saved: Dictionary = module.save_state()
	var count: int = (saved["world"]["bodies"] as Array).size()
	var ghost: Dictionary = (saved["world"]["bodies"][0] as Dictionary).duplicate(true)
	ghost["spec_id"] = "ghost_body"
	ghost["kind"] = BodyKind.PROP_DYNAMIC
	saved["world"]["bodies"].append(ghost)
	var loaded: Node = _spawn({}, saved)
	var again: Dictionary = loaded.save_state()
	assert_eq((again["world"]["bodies"] as Array).size(), count)
	assert_eq(loaded.get_world_state().find("ghost_body"), -1)


func test_deduplicates_players() -> void:
	var world: Dictionary = SaveCodec.sanitize_world(_raw_world([
		_raw_body("player", BodyKind.PLAYER, 10.0),
		_raw_body("player_copy", BodyKind.PLAYER, 20.0),
		_raw_body("crate", BodyKind.PROP_DYNAMIC, 30.0),
	]))
	var players: int = 0
	for body: Dictionary in world["bodies"]:
		if int(body["kind"]) == BodyKind.PLAYER:
			players += 1
	assert_eq(players, 1)
	assert_eq((world["bodies"] as Array).size(), 2)


func test_clamps_objective_count() -> void:
	var raw: Dictionary = _raw_world([])
	raw["objective_count"] = 99
	raw["objective_needed"] = 3
	assert_eq(int(SaveCodec.sanitize_world(raw)["objective_count"]), 3)
	var module: Node = _playing()
	var saved: Dictionary = module.save_state()
	saved["world"]["objective_count"] = 99
	var loaded: Node = _spawn({}, saved)
	assert_eq(loaded.get_world_state().objective_count, loaded.get_world_state().objective_needed)


func test_clamps_hitstop() -> void:
	var raw: Dictionary = _raw_world([])
	raw["hitstop"] = 5.0
	assert_almost_eq(float(SaveCodec.sanitize_world(raw)["hitstop"]), Tuning.HITSTOP, 0.00001)
	assert_almost_eq(Tuning.HITSTOP, 0.055, 0.00001)


func test_unknown_phase_falls_back() -> void:
	var raw: Dictionary = _raw_world([])
	raw["phase"] = "wat"
	assert_eq(String(SaveCodec.sanitize_world(raw)["phase"]), "intro")
	for phase: String in ["clear", "dead"]:
		raw["phase"] = phase
		assert_eq(String(SaveCodec.sanitize_world(raw)["phase"]), "intro", "%s is saved as intro" % phase)


func test_reassigns_missing_tool() -> void:
	var module: Node = _playing()
	var saved: Dictionary = module.save_state()
	saved["run"]["tool_ids"][0] = "tool_removed_long_ago"
	for body: Dictionary in saved["world"]["bodies"]:
		if int(body["kind"]) == BodyKind.TOOL_CARRIED:
			body["tool_id"] = "tool_removed_long_ago"
	var loaded: Node = _spawn({}, saved)
	var run: RefCounted = loaded.get_run_state()
	var registry: Array = _content().tool_order
	assert_true(registry.has(run.tool_ids[0]), "slot 0 now names a registered tool")
	var world: RefCounted = loaded.get_world_state()
	for body: RefCounted in world.bodies:
		if body.kind == BodyKind.TOOL_CARRIED:
			assert_true(registry.has(body.tool_id), "no body keeps the removed tool")
	assert_true(world.held_tool_index() >= 0, "the reassigned tool is dealt into the hand")


func _v1_payload() -> Dictionary:
	return {
		"schema": 1,
		"module": "physics_puzzle_platformer",
		"run": {"run_seed": 5, "run_index": 2, "sequence": [], "tool_ids": []},
		"world": {"level_id": "lvl_a", "objective_target": 3, "phase": "play", "bodies": [{"body_id": "crate", "kind": BodyKind.PROP_DYNAMIC, "x": 1.0, "y": 2.0}]},
	}


func _check_v3(migrated: Dictionary) -> void:
	assert_eq(int(migrated["schema"]), SaveCodec.SCHEMA)
	assert_eq(String(migrated["module"]), "physics_puzzle_platformer")
	assert_true((migrated["run"] as Dictionary).has("cursor"))
	assert_true((migrated["world"] as Dictionary).has("objective_needed"))
	assert_false((migrated["world"] as Dictionary).has("objective_target"))
	for body: Dictionary in migrated["world"]["bodies"]:
		assert_true(body.has("spec_id"))
		assert_false(body.has("body_id"))
	for entry: Dictionary in migrated["run"]["sequence"]:
		assert_true(entry.has("level_id"))
		assert_false(entry.has("level"))


func test_migrate_v1_to_v3() -> void:
	var migrated: Dictionary = SaveCodec.migrate(1, _v1_payload())
	_check_v3(migrated)
	assert_eq(int(migrated["world"]["objective_needed"]), 3)
	var module: Node = ENTRY.instantiate()
	add_child(module)
	_modules.append(module)
	_check_v3(module.migrate_save(1, _v1_payload()))


func test_migrate_v2_to_v3() -> void:
	var payload: Dictionary = _v1_payload()
	payload["schema"] = 2
	payload["world"].erase("objective_target")
	payload["world"]["objective_needed"] = 2
	payload["run"]["sequence"] = [{"level": "lvl_a", "mutations": []}]
	var migrated: Dictionary = SaveCodec.migrate(2, payload)
	_check_v3(migrated)
	assert_eq(String(migrated["run"]["sequence"][0]["level_id"]), "lvl_a")
	assert_eq(String(migrated["world"]["bodies"][0]["spec_id"]), "crate")
	assert_eq(int(migrated["run"]["cursor"]), 0)


func test_rejects_future_version() -> void:
	var saved: Dictionary = _playing().save_state()
	saved["schema"] = 4
	var module: Node = ENTRY.instantiate()
	add_child(module)
	_modules.append(module)
	module.load_state(saved)
	watch_signals(module)
	module.enter(_context({}))
	var rejected: Array[Dictionary] = []
	for index: int in get_signal_emit_count(module, "requested"):
		var params: Array = get_signal_parameters(module, "requested", index)
		if params[0] == &"observation" and String(params[1].get("id", "")) == "ppp.save_rejected":
			rejected.append(params[1])
	assert_eq(rejected.size(), 1, "one save_rejected observation")
	if not rejected.is_empty():
		assert_eq(int(rejected[0]["meta"]["found_version"]), 4)
	assert_eq(module.get_phase(), &"intro", "a fresh run starts")
	assert_eq(module.get_run_state().cursor, 0)
	assert_ne(module.get_run_state().run_seed, int(saved["run"]["run_seed"]), "the rejected run is not resumed")


func test_does_not_store_presentation_state() -> void:
	var module: Node = _playing()
	for _tick: int in 20:
		module.step(Tuning.FIXED_DT)
	var keys: Array[String] = _keys(module.save_state())
	for banned: String in ["phase_time", "contact_flash", "trail", "camera", "frozen_time", "still_time", "squash", "charge_time"]:
		assert_false(keys.has(banned), "no '%s' key" % banned)
	for axis: String in ["body", "creature", "place", "worldstate"]:
		assert_false(keys.has(axis), "no copied axis '%s'" % axis)


func test_restore_keeps_mutations() -> void:
	var content: RefCounted = _content()
	var level_id: String = ""
	for candidate: String in content.level_order:
		if (content.level(candidate).mutable as Array).has("gravity_scale"):
			level_id = candidate
			break
	if level_id.is_empty():
		pending("no shipped level allows gravity_scale yet")
		return
	var module: Node = _playing()
	var saved: Dictionary = module.save_state()
	saved["run"]["sequence"][0] = {"level_id": level_id, "mutations": [{"op": "gravity_scale", "arg": 1.45}]}
	saved["world"] = {}
	var loaded: Node = _spawn({}, saved)
	var world: RefCounted = loaded.get_world_state()
	assert_eq(world.level_id, level_id)
	assert_eq(JSON.stringify(SaveCodec.encode_mutations(world.applied_mutations)), JSON.stringify([{"op": "gravity_scale", "arg": 1.45}]))
	assert_almost_eq(loaded.get_director().player_node().gravity_scale, 1.45, 0.0001)
	loaded.step(1.0)
	assert_eq(loaded.get_phase(), &"play")
	assert_true(loaded.execute_command(&"reset"))
	var reset_world: RefCounted = loaded.get_world_state()
	assert_eq(JSON.stringify(SaveCodec.encode_mutations(reset_world.applied_mutations)), JSON.stringify([{"op": "gravity_scale", "arg": 1.45}]), "reset rebuilds the same mutation")
