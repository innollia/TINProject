extends GutTest

const LevelSpec = preload("res://modules/physics_puzzle_platformer/domain/level_spec.gd")
const ToolSpec = preload("res://modules/physics_puzzle_platformer/domain/tool_spec.gd")
const ContentIndex = preload("res://modules/physics_puzzle_platformer/systems/content_index.gd")

const KIT_ROOT: String = "res://modules/physics_puzzle_platformer"
const BINARY_EXTENSIONS: Array[String] = ["png", "jpg", "jpeg", "webp", "bmp", "svg", "ttf", "otf", "aseprite", "kra"]
const AUDIO_ALLOWED: Array[String] = ["wav", "md", "import", "gitkeep"]


func _level() -> Dictionary:
	return {
		"schema": 1, "id": "lvl_schema_probe", "name": "probe", "parallax_seed": 11,
		"spawn": {"x": 100, "y": 400}, "rift": {"x": 1500, "y": 400, "radius": 30},
		"bounds": {"min_x": 0, "max_x": 1700, "min_y": 0, "max_y": 700},
		"objective_needed": 1, "mutable": [], "mutable_hazards": [], "shuffled": [],
		"kinematics": [{"id": "lift", "from": [800, 500], "to": [800, 300], "duration": 2.0, "loop": "pingpong"}],
		"bodies": [
			{"id": "floor", "kind": "tile_static", "shape": "box", "material": "stone", "pos": [850, 650], "size": [1700, 40]},
			{"id": "lift", "kind": "tile_kinematic", "shape": "box", "material": "wood", "pos": [800, 500], "size": [120, 20]},
			{"id": "egg", "kind": "objective", "shape": "circle", "material": "clockwork", "pos": [1000, 600], "size": [22, 22]},
		],
	}


func _tool() -> Dictionary:
	return {
		"schema": 1, "id": "tool_schema_probe", "name": "probe", "use": "throw",
		"body": {"kind": "prop_dynamic", "shape": "box", "material": "glass", "size": [12, 40]},
		"mass": 1.6, "friction": 0.3, "bounce": 0.2, "cooldown": 0.22, "trail": "short", "impulse_scale": 1.0,
	}


func _parse_level(data: Dictionary) -> Dictionary:
	return LevelSpec.new().parse(data, "", [])


func _parse_tool(data: Dictionary) -> Dictionary:
	return ToolSpec.new().parse(data, "")


func _index_ids(path: String, key: String) -> Array:
	var data: Variant = ContentIndex.read_json(path)
	assert_true(data is Dictionary, "%s is readable JSON" % path)
	return (data as Dictionary).get(key, []) if data is Dictionary else []


func test_probe_fixtures_are_valid() -> void:
	assert_true(bool(_parse_level(_level())["ok"]), str(_parse_level(_level())["errors"]))
	assert_true(bool(_parse_tool(_tool())["ok"]), str(_parse_tool(_tool())["errors"]))


func test_all_indexed_levels_load() -> void:
	var content: RefCounted = ContentIndex.new().read_default()
	var ids: Array = _index_ids(KIT_ROOT + "/content/levels/index.json", "levels")
	assert_gt(ids.size(), 0)
	assert_eq(content.level_order.size(), ids.size(), "every indexed level loads: %s" % str(content.errors))
	for level_id: Variant in ids:
		assert_not_null(content.level(String(level_id)), String(level_id))


func test_all_indexed_tools_load() -> void:
	var content: RefCounted = ContentIndex.new().read_default()
	var ids: Array = _index_ids(KIT_ROOT + "/content/tools/index.json", "tools")
	assert_gt(ids.size(), 0)
	assert_eq(content.tool_order.size(), ids.size(), "every indexed tool loads: %s" % str(content.errors))


func test_rejects_missing_required_key() -> void:
	for key: String in LevelSpec.REQUIRED_KEYS:
		var data: Dictionary = _level()
		data.erase(key)
		assert_false(bool(_parse_level(data)["ok"]), "level without '%s' fails" % key)
	for key: String in ToolSpec.REQUIRED_KEYS:
		var data: Dictionary = _tool()
		data.erase(key)
		assert_false(bool(_parse_tool(data)["ok"]), "tool without '%s' fails" % key)


func test_rejects_bad_id_pattern() -> void:
	for bad: Variant in ["LVL_UPPER", "ab", "has space", "x".repeat(33), 12, ""]:
		var data: Dictionary = _level()
		data["id"] = bad
		assert_false(bool(_parse_level(data)["ok"]), "level id %s fails" % str(bad))
		var tool: Dictionary = _tool()
		tool["id"] = bad
		assert_false(bool(_parse_tool(tool)["ok"]), "tool id %s fails" % str(bad))
	var body_level: Dictionary = _level()
	body_level["bodies"][0]["id"] = "Bad-Id"
	assert_false(bool(_parse_level(body_level)["ok"]))


func test_rejects_unknown_mutable_op() -> void:
	var data: Dictionary = _level()
	data["mutable"] = ["gravity_scale_mul"]
	assert_false(bool(_parse_level(data)["ok"]))
	data["mutable"] = ["gravity_scale", "gravity_scale"]
	assert_false(bool(_parse_level(data)["ok"]), "duplicate ops fail")
	data["mutable"] = ["gravity_scale", "wind"]
	assert_true(bool(_parse_level(data)["ok"]))


func test_rejects_objective_needed_above_core_count() -> void:
	var data: Dictionary = _level()
	data["objective_needed"] = 2
	assert_false(bool(_parse_level(data)["ok"]))
	data["objective_needed"] = 0
	assert_false(bool(_parse_level(data)["ok"]))


func test_rejects_spawn_outside_bounds() -> void:
	var data: Dictionary = _level()
	data["spawn"] = {"x": 1800, "y": 400}
	assert_false(bool(_parse_level(data)["ok"]))
	data = _level()
	data["rift"] = {"x": 100, "y": 900, "radius": 30}
	assert_false(bool(_parse_level(data)["ok"]), "rift outside bounds fails too")


func test_rejects_rift_body_duplicate() -> void:
	var data: Dictionary = _level()
	data["bodies"].append({"id": "rift_copy", "kind": "rift", "shape": "circle", "material": "goal", "pos": [300, 300], "size": [40, 40]})
	assert_false(bool(_parse_level(data)["ok"]))
	data = _level()
	data["bodies"].append({"id": "me", "kind": "player", "shape": "capsule", "material": "wax", "pos": [300, 300], "size": [32, 46]})
	assert_false(bool(_parse_level(data)["ok"]), "the player is not authored")


func test_rejects_hull_with_two_points() -> void:
	var data: Dictionary = _level()
	data["bodies"].append({"id": "shard", "kind": "tile_static", "shape": "hull", "material": "stone", "pos": [300, 300], "points": [[0, 0], [10, 0]]})
	assert_false(bool(_parse_level(data)["ok"]))
	data = _level()
	data["bodies"].append({"id": "dent", "kind": "tile_static", "shape": "hull", "material": "stone", "pos": [300, 300], "points": [[0, 0], [40, 0], [20, 5], [40, 40], [0, 40]]})
	assert_false(bool(_parse_level(data)["ok"]), "concave hull fails")


func test_rejects_kinematic_outside_bounds() -> void:
	var data: Dictionary = _level()
	data["kinematics"][0]["to"] = [800, -300]
	assert_false(bool(_parse_level(data)["ok"]))
	data = _level()
	data["kinematics"] = []
	assert_false(bool(_parse_level(data)["ok"]), "a moving tile needs its path")


func test_rejects_tool_field_pickable() -> void:
	var data: Dictionary = _tool()
	data["pickable"] = true
	assert_false(bool(_parse_tool(data)["ok"]))
	data = _tool()
	data["body"]["pickable"] = true
	assert_false(bool(_parse_tool(data)["ok"]))


func test_rejects_lock_field() -> void:
	for key: String in ["unlocks", "opens", "required_for", "key_id", "solution", "answer", "hint"]:
		var tool: Dictionary = _tool()
		tool[key] = "lvl_schema_probe"
		assert_false(bool(_parse_tool(tool)["ok"]), "tool with '%s' fails" % key)
		var level: Dictionary = _level()
		level[key] = "tool_schema_probe"
		assert_false(bool(_parse_level(level)["ok"]), "level with '%s' fails" % key)
		var body_level: Dictionary = _level()
		body_level["bodies"][2][key] = "x"
		assert_false(bool(_parse_level(body_level)["ok"]), "body with '%s' fails" % key)


func test_accepts_all_shipped_content() -> void:
	var content: RefCounted = ContentIndex.new().read_default()
	assert_eq(content.errors, [] as Array[String])
	assert_gte(content.level_order.size(), 8, "at least eight shipped levels")
	assert_gte(content.tool_order.size(), 6, "at least six shipped tools")


func _walk(path: String, found: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.include_hidden = true
	for file: String in dir.get_files():
		found.append(path + "/" + file)
	for sub: String in dir.get_directories():
		_walk(path + "/" + sub, found)


func test_no_binary_assets_in_kit_folder() -> void:
	var files: Array[String] = []
	_walk(KIT_ROOT, files)
	assert_gt(files.size(), 10)
	var binaries: Array[String] = []
	for file: String in files:
		if BINARY_EXTENSIONS.has(file.get_extension().to_lower()):
			binaries.append(file)
	assert_eq(binaries, [] as Array[String])


func test_audio_folder_only_wav() -> void:
	var files: Array[String] = []
	_walk(KIT_ROOT + "/audio", files)
	var odd: Array[String] = []
	for file: String in files:
		var extension: String = file.get_extension().to_lower()
		if file.get_file() == ".gitkeep":
			continue
		if not AUDIO_ALLOWED.has(extension):
			odd.append(file)
	assert_eq(odd, [] as Array[String])
