class_name RuleGridEntity
extends RefCounted

var id: String
var kind: StringName
var position: Vector2i
var facing: Vector2i = Vector2i.RIGHT
var is_word: bool
var word_role: StringName
var word_value: StringName
var base_tags: Array[StringName] = []
var runtime_tags: Array[StringName] = []


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"kind": String(kind),
		"x": position.x,
		"y": position.y,
		"facing_x": facing.x,
		"facing_y": facing.y,
		"is_word": is_word,
		"word_role": String(word_role),
		"word_value": String(word_value),
		"base_tags": _tags_to_strings(base_tags),
		"runtime_tags": _tags_to_strings(runtime_tags)
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
	var word_value: Variant = data.get("word_value", "")
	var role_value: Variant = data.get("word_role", "")
	if not id_value is String or id_value.is_empty() \
		or not _is_text(kind_value) or String(kind_value).is_empty() \
		or not _is_integer(x_value) or not _is_integer(y_value) \
		or not _is_integer(facing_x_value) or not _is_integer(facing_y_value) \
		or not data.get("is_word", false) is bool \
		or not _is_text(role_value) or not _is_text(word_value):
		return null
	var facing := Vector2i(int(facing_x_value), int(facing_y_value))
	if absi(facing.x) + absi(facing.y) != 1:
		return null
	var entity := RuleGridEntity.new()
	entity.id = id_value
	entity.kind = StringName(kind_value)
	entity.position = Vector2i(int(x_value), int(y_value))
	entity.facing = facing
	entity.is_word = bool(data.get("is_word", false))
	entity.word_role = StringName(role_value)
	entity.word_value = StringName(word_value)
	if entity.is_word and not [StringName("noun"), StringName("operator"), StringName("property")].has(entity.word_role):
		return null
	if not entity.is_word and (not entity.word_role.is_empty() or not entity.word_value.is_empty()):
		return null
	if not _read_tags(data.get("base_tags", []), entity.base_tags) \
		or not _read_tags(data.get("runtime_tags", []), entity.runtime_tags):
		return null
	return entity


static func _is_text(value: Variant) -> bool:
	return value is String or value is StringName


static func _is_integer(value: Variant) -> bool:
	return (value is int or value is float) \
		and is_finite(float(value)) \
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
