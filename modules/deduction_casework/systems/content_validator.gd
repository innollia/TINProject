class_name DeductionContentValidator
extends RefCounted

const SCHEMA_VERSION: int = 1
const MAX_JSON_DEPTH: int = 64
const MAX_CONDITION_DEPTH: int = 8
const MOVE_POLICIES: Array[String] = ["move", "copy"]

const INDEX_KEYS: Array[String] = ["schema_version", "cases"]
const INDEX_ENTRY_KEYS: Array[String] = ["id", "path"]
const CASE_KEYS: Array[String] = [
	"schema_version", "id", "title", "start_scene_id", "scenes", "closeups", "entities",
	"messages", "panels", "solutions", "hints", "review", "next_case_ids"
]
const SCENE_KEYS: Array[String] = [
	"schema_version", "id", "scene_path", "start_focus_id", "hotspots", "transitions"
]
const CLOSEUP_KEYS: Array[String] = [
	"schema_version", "id", "scene_path", "parent_scene_id", "return_focus_id", "hotspots"
]
const HOTSPOT_KEYS: Array[String] = ["schema_version", "id", "focus_id"]
const TRANSITION_KEYS: Array[String] = ["schema_version", "id", "destination_scene_id", "focus_id"]
const ENTITY_KEYS: Array[String] = [
	"schema_version", "id", "kind", "display_text", "source_text_id", "tags"
]
const MESSAGE_KEYS: Array[String] = [
	"schema_version", "id", "title", "body", "source_refs", "prerequisite_condition",
	"effects", "detail_scene_id"
]
const EFFECT_KEYS: Array[String] = ["schema_version", "type", "params"]
const PANEL_KEYS: Array[String] = [
	"schema_version", "id", "kind", "title", "accepted_entity_kinds", "slots", "segments",
	"almost_threshold", "required_for_completion", "unlock_condition"
]
const PANEL_SLOT_KEYS: Array[String] = [
	"schema_version", "id", "segment_id", "accepted_kinds", "accepted_entity_ids",
	"persistent", "move_policy"
]
const SEGMENT_KEYS: Array[String] = ["schema_version", "id", "display_text"]
const CONDITION_KEYS: Array[String] = [
	"schema_version", "all_of", "any_of", "not",
	"requires_discovered_entity_id", "requires_resolved_message_id", "requires_solved_case_id",
	"requires_assignment_id", "requires_assignment_entity_id"
]
const SOLUTION_KEYS: Array[String] = [
	"schema_version", "id", "panel_id", "required_assignments", "forbidden_assignments",
	"all_of_conditions", "completion_review_id"
]
const ASSIGNMENT_KEYS: Array[String] = ["schema_version", "slot_id", "entity_id"]
const HINT_KEYS: Array[String] = [
	"schema_version", "id", "title", "body", "prerequisite_condition", "one_shot"
]
const REVIEW_KEYS: Array[String] = [
	"schema_version", "id", "conclusion", "referenced_case_ids", "scene_path"
]


static func parse_json_document(text: String) -> Variant:
	if text.is_empty():
		return null
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return null
	return parser.data if is_json_safe(parser.data) else null


static func is_json_safe(value: Variant, depth: int = 0) -> bool:
	if depth > MAX_JSON_DEPTH:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_ARRAY:
			for element: Variant in value:
				if not is_json_safe(element, depth + 1):
					return false
			return true
		TYPE_DICTIONARY:
			for key: Variant in value:
				if not key is String or not is_json_safe(value[key], depth + 1):
					return false
			return true
	return false


static func is_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))


static func is_schema_version(value: Variant) -> bool:
	return is_integer(value) and int(value) == SCHEMA_VERSION


static func is_stable_id(value: Variant) -> bool:
	if not value is String:
		return false
	var text: String = value
	if text.is_empty():
		return false
	var first: int = text.unicode_at(0)
	if first < 97 or first > 122:
		return false
	for index: int in range(1, text.length()):
		var codepoint: int = text.unicode_at(index)
		if not ((codepoint >= 97 and codepoint <= 122) \
			or (codepoint >= 48 and codepoint <= 57) or codepoint == 95):
			return false
	return true


static func is_content_path(value: Variant) -> bool:
	if not value is String:
		return false
	var text: String = value
	if text.is_empty() or text.begins_with("/") or text.contains("\\") \
		or text.contains(":") or text.contains("~") or not text.ends_with(".json"):
		return false
	return _segments_are_safe(text)


static func is_resource_path(value: Variant, suffix: String) -> bool:
	if not value is String:
		return false
	var text: String = value
	if text.is_empty() or text.contains("\\") or text.contains("~") or not text.ends_with(suffix):
		return false
	if text.begins_with("res://"):
		return _segments_are_safe(text.trim_prefix("res://"))
	if text.contains(":") or text.begins_with("/"):
		return false
	return _segments_are_safe(text)


static func has_only_keys(value: Dictionary, allowed: Array[String]) -> bool:
	for key: Variant in value.keys():
		if not key is String or not allowed.has(key):
			return false
	return true


static func is_optional_string(value: Dictionary, key: String) -> bool:
	return not value.has(key) or value[key] is String


static func has_all_keys(value: Dictionary, required: Array[String]) -> bool:
	for key: String in required:
		if not value.has(key):
			return false
	return true


static func read_string(value: Variant) -> String:
	return value if value is String else ""


static func read_id(value: Variant) -> StringName:
	return StringName(value) if is_stable_id(value) else &""


static func read_optional_ids(value: Variant) -> Array[StringName]:
	return to_string_names(value) if value is Array else ([] as Array[StringName])


static func to_string_names(value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if not value is Array:
		return result
	for item: Variant in value:
		if item is String:
			result.append(StringName(item))
	return result


static func json_copy(value: Variant) -> Variant:
	if not is_json_safe(value):
		return null
	return value.duplicate(true) if value is Dictionary or value is Array else value


static func list_is_complete(entries: Array) -> bool:
	for entry: Variant in entries:
		if entry == null:
			return false
	return true


static func list_to_dict(entries: Array) -> Array:
	var result: Array = []
	for entry: Variant in entries:
		result.append(entry.to_dict())
	return result


static func strings_to_dict(values: Array) -> Array:
	var result: Array = []
	for value: Variant in values:
		result.append(String(value))
	return result


static func _segments_are_safe(path: String) -> bool:
	for segment: String in path.split("/"):
		if segment.is_empty() or segment == "." or segment == "..":
			return false
	return true
