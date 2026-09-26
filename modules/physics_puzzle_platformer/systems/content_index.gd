extends RefCounted

const LevelSpec = preload("res://modules/physics_puzzle_platformer/domain/level_spec.gd")
const ToolSpec = preload("res://modules/physics_puzzle_platformer/domain/tool_spec.gd")

const CONTENT_ROOT: String = "res://modules/physics_puzzle_platformer/content"
const INDEX_SCHEMA: int = 1

var levels: Dictionary = {}
var level_order: Array[String] = []
var tools: Dictionary = {}
var tool_order: Array[String] = []
var errors: Array[String] = []


func read_default() -> RefCounted:
	read_from(CONTENT_ROOT)
	return self


func read_from(root: String) -> void:
	levels.clear()
	level_order.clear()
	tools.clear()
	tool_order.clear()
	errors.clear()
	var tool_ids: Array[String] = _read_index(root + "/tools/index.json", "tools")
	for tool_id: String in tool_ids:
		var parsed: Dictionary = ToolSpec.new().parse(read_json(root + "/tools/" + tool_id + ".json"), tool_id)
		if bool(parsed["ok"]):
			tools[tool_id] = parsed["spec"]
			tool_order.append(tool_id)
		else:
			for problem: String in parsed["errors"]:
				errors.append("%s: %s" % [tool_id, problem])
	var level_ids: Array[String] = _read_index(root + "/levels/index.json", "levels")
	for level_id: String in level_ids:
		var parsed: Dictionary = LevelSpec.new().parse(read_json(root + "/levels/" + level_id + ".json"), level_id, tool_order)
		if bool(parsed["ok"]):
			levels[level_id] = parsed["spec"]
			level_order.append(level_id)
		else:
			for problem: String in parsed["errors"]:
				errors.append("%s: %s" % [level_id, problem])


func level(level_id: String) -> RefCounted:
	return levels.get(level_id, null)


func tool(tool_id: String) -> RefCounted:
	return tools.get(tool_id, null)


func mutable_by_level() -> Dictionary:
	var result: Dictionary = {}
	for level_id: String in level_order:
		result[level_id] = (levels[level_id].mutable as Array).duplicate()
	return result


func _read_index(path: String, key: String) -> Array[String]:
	var result: Array[String] = []
	var data: Variant = read_json(path)
	if not data is Dictionary:
		errors.append("%s: index is not an object" % path)
		return result
	var raw: Dictionary = data
	for entry: Variant in raw:
		if not ["schema", key].has(String(entry)):
			errors.append("%s: unknown key '%s'" % [path, str(entry)])
	if not (raw.get("schema") is int or raw.get("schema") is float) or int(raw.get("schema")) != INDEX_SCHEMA:
		errors.append("%s: schema must be %d" % [path, INDEX_SCHEMA])
		return result
	if not raw.get(key) is Array:
		errors.append("%s: '%s' must be an array" % [path, key])
		return result
	for value: Variant in raw[key]:
		if not value is String or String(value).is_empty():
			errors.append("%s: bad id entry" % path)
			continue
		if result.has(String(value)):
			errors.append("%s: duplicate id '%s'" % [path, str(value)])
			continue
		result.append(String(value))
	return result


static func read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var text: String = file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return null
	return parser.data
