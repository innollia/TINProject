class_name DeductionCaseworkCaseState
extends RefCounted

const SCHEMA_VERSION: int = 1
const MAX_JSON_DEPTH: int = 64

var active_case_id: StringName = &""
var last_case_id: StringName = &""
var case_progress_by_id: Dictionary = {}
var route_state: Dictionary = {}


func to_dict() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"active_case_id": String(active_case_id),
		"last_case_id": String(last_case_id),
		"case_progress_by_id": _sanitize_json(case_progress_by_id),
		"route_state": _sanitize_json(route_state)
	}


static func from_dict(data: Variant) -> DeductionCaseworkCaseState:
	if not data is Dictionary:
		return null
	var version_value: Variant = data.get("schema_version")
	if not _is_number(version_value) or not is_finite(float(version_value)) or float(version_value) != float(SCHEMA_VERSION):
		return null
	var state := DeductionCaseworkCaseState.new()
	state.active_case_id = _read_id(data.get("active_case_id"))
	state.last_case_id = _read_id(data.get("last_case_id"))
	state.case_progress_by_id = _sanitize_dictionary(data.get("case_progress_by_id"))
	state.route_state = _sanitize_dictionary(data.get("route_state"))
	return state


static func _is_number(value: Variant) -> bool:
	return value is int or value is float


static func _read_id(value: Variant) -> StringName:
	if not value is String:
		return &""
	var text: String = value
	return &"" if text.strip_edges().is_empty() else StringName(text)


static func _sanitize_dictionary(value: Variant, depth: int = 0) -> Dictionary:
	var result: Dictionary = {}
	if depth > MAX_JSON_DEPTH or not value is Dictionary:
		return result
	for key: Variant in value:
		if not key is String:
			continue
		result[key] = _sanitize_json(value[key], depth + 1)
	return result


static func _sanitize_json(value: Variant, depth: int = 0) -> Variant:
	if depth > MAX_JSON_DEPTH:
		return null
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return value
		TYPE_FLOAT:
			return value if is_finite(value) else null
		TYPE_ARRAY:
			var result: Array = []
			for element: Variant in value:
				result.append(_sanitize_json(element, depth + 1))
			return result
		TYPE_DICTIONARY:
			return _sanitize_dictionary(value, depth)
		_:
			return null
