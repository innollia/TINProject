class_name RuleGridEntity
extends RefCounted

const MAX_JSON_SAFE_INTEGER: float = 9007199254740991.0

var id: String
var kind: StringName
var position: Vector2i
var facing: Vector2i = Vector2i.RIGHT
var layer: int = 0
var creation_serial: int = 0
var is_word: bool
var word_role: StringName
var word_value: StringName
var base_tags: Array[StringName] = []
var runtime_tags: Array[StringName] = []
var module_metadata: Dictionary = {}


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"kind": String(kind),
		"x": position.x,
		"y": position.y,
		"facing_x": facing.x,
		"facing_y": facing.y,
		"layer": layer,
		"creation_serial": creation_serial,
		"is_word": is_word,
		"word_role": String(word_role),
		"word_value": String(word_value),
		"base_tags": _tags_to_strings(base_tags),
		"runtime_tags": _tags_to_strings(runtime_tags),
		"module_metadata": module_metadata.duplicate(true)
	}


static func from_dictionary(data: Variant) -> RuleGridEntity:
	if not data is Dictionary:
		return null
	var id_value: Variant = data.get("id")
	var kind_value: Variant = data.get("kind")
	var x_value: Variant = data.get("x")
	var y_value: Variant = data.get("y")
	var facing_x_value: Variant = data.get("facing_x", 1)
	var facing_y_value: Variant = data.get("facing_y", 0)
	if data.has("facing"):
		var facing_value: Variant = data["facing"]
		if data.has("facing_x") or data.has("facing_y") \
			or not facing_value is Array or facing_value.size() != 2 \
			or not _is_integer(facing_value[0]) or not _is_integer(facing_value[1]):
			return null
		facing_x_value = facing_value[0]
		facing_y_value = facing_value[1]
	var layer_value: Variant = data.get("layer", 0)
	var serial_value: Variant = data.get("creation_serial", 0)
	var word_value: Variant = data.get("word_value", "")
	var role_value: Variant = data.get("word_role", "")
	var metadata_value: Variant = data.get("module_metadata", {})
	if not id_value is String or id_value.is_empty() \
		or not is_valid_id(id_value) \
		or not _is_text(kind_value) or String(kind_value).is_empty() \
		or not _is_integer(x_value) or not _is_integer(y_value) \
		or not _is_integer(facing_x_value) or not _is_integer(facing_y_value) \
		or not _is_integer(layer_value) or not _is_integer(serial_value) \
		or int(serial_value) < 0 \
		or not data.get("is_word", false) is bool \
		or not _is_text(role_value) or not _is_text(word_value) \
		or not metadata_value is Dictionary \
		or not is_json_safe(metadata_value):
		return null
	var facing := Vector2i(int(facing_x_value), int(facing_y_value))
	if absi(facing.x) + absi(facing.y) != 1:
		return null
	var entity := RuleGridEntity.new()
	entity.id = id_value
	entity.kind = StringName(kind_value)
	entity.position = Vector2i(int(x_value), int(y_value))
	entity.facing = facing
	entity.layer = int(layer_value)
	entity.creation_serial = int(serial_value)
	entity.is_word = bool(data.get("is_word", false))
	entity.word_role = StringName(role_value)
	entity.word_value = StringName(word_value)
	if entity.is_word and (not [StringName("noun"), StringName("operator"), StringName("property")].has(entity.word_role) \
		or entity.word_value.is_empty()):
		return null
	if not entity.is_word and (not entity.word_role.is_empty() or not entity.word_value.is_empty()):
		return null
	if not _read_tags(data.get("base_tags", []), entity.base_tags) \
		or not _read_tags(data.get("runtime_tags", []), entity.runtime_tags):
		return null
	entity.module_metadata = _copy_json_dictionary(metadata_value)
	return entity


static func is_valid_id(value: Variant) -> bool:
	if not value is String or value.is_empty():
		return false
	var text_value: String = value
	for index: int in range(text_value.length()):
		var codepoint := text_value.unicode_at(index)
		var valid := (codepoint >= 48 and codepoint <= 57) \
			or (codepoint >= 65 and codepoint <= 90) \
			or (codepoint >= 97 and codepoint <= 122) \
			or codepoint == 95 or codepoint == 45 or codepoint == 58
		if not valid:
			return false
	return true


static func is_json_safe(value: Variant) -> bool:
	if value == null or value is bool or value is String:
		return true
	if value is int:
		return absf(float(value)) <= MAX_JSON_SAFE_INTEGER
	if value is float:
		return is_finite(value)
	if value is Array:
		for item: Variant in value:
			if not is_json_safe(item):
				return false
		return true
	if value is Dictionary:
		for key: Variant in value.keys():
			if not key is String or not is_json_safe(value[key]):
				return false
		return true
	return false


static func _copy_json_dictionary(value: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in value.keys():
		result[key] = _copy_json_value(value[key])
	return result


static func _copy_json_value(value: Variant) -> Variant:
	if value is float and is_finite(value) and absf(value) <= MAX_JSON_SAFE_INTEGER \
		and value == floorf(value):
		return int(value)
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_copy_json_value(item))
		return result
	if value is Dictionary:
		return _copy_json_dictionary(value)
	return value


static func _is_text(value: Variant) -> bool:
	return value is String or value is StringName


static func _is_integer(value: Variant) -> bool:
	return (value is int or value is float) \
		and is_finite(float(value)) \
		and absf(float(value)) <= MAX_JSON_SAFE_INTEGER \
		and float(value) == floorf(float(value))


static func _read_tags(value: Variant, target: Array[StringName]) -> bool:
	if not value is Array:
		return false
	target.clear()
	for tag: Variant in value:
		if not _is_text(tag) or String(tag).is_empty():
			target.clear()
			return false
		target.append(StringName(tag))
	return true


static func _tags_to_strings(tags: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for tag: StringName in tags:
		result.append(String(tag))
	return result
