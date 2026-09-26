class_name DeductionCaseProgress
extends RefCounted

const SCHEMA_VERSION: int = 1
const STATUS_OPEN: StringName = &"open"
const STATUS_SOLVED: StringName = &"solved"
const STATUS_REVIEWED: StringName = &"reviewed"
const STATUS_CONTENT_UNAVAILABLE: StringName = &"content_unavailable"
const STATUSES: Array[StringName] = [
	STATUS_OPEN, STATUS_SOLVED, STATUS_REVIEWED, STATUS_CONTENT_UNAVAILABLE
]
const PROGRESS_KEYS: Array[String] = [
	"schema_version", "case_id", "current_scene_id", "visited_scene_ids",
	"discovered_entity_ids", "resolved_message_ids", "revealed_panel_ids",
	"panel_drafts", "panel_status", "accepted_solution_ids", "unlocked_hint_ids",
	"reviewed", "status"
]

var case_id: StringName = &""
var current_scene_id: StringName = &""
var visited_scene_ids: Array[StringName] = []
var discovered_entity_ids: Array[StringName] = []
var resolved_message_ids: Array[StringName] = []
var revealed_panel_ids: Array[StringName] = []
var panel_drafts: Dictionary = {}
var panel_status: Dictionary = {}
var accepted_solution_ids: Array[StringName] = []
var unlocked_hint_ids: Array[StringName] = []
var reviewed: bool = false
var status: StringName = STATUS_OPEN


func clone() -> DeductionCaseProgress:
	var copy := DeductionCaseProgress.new()
	copy.case_id = case_id
	copy.current_scene_id = current_scene_id
	copy.visited_scene_ids.assign(visited_scene_ids)
	copy.discovered_entity_ids.assign(discovered_entity_ids)
	copy.resolved_message_ids.assign(resolved_message_ids)
	copy.revealed_panel_ids.assign(revealed_panel_ids)
	copy.panel_drafts = _copy_drafts(panel_drafts)
	copy.panel_status = panel_status.duplicate(true)
	copy.accepted_solution_ids.assign(accepted_solution_ids)
	copy.unlocked_hint_ids.assign(unlocked_hint_ids)
	copy.reviewed = reviewed
	copy.status = status
	return copy


func to_dict() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"case_id": String(case_id),
		"current_scene_id": String(current_scene_id),
		"visited_scene_ids": _ids_to_strings(visited_scene_ids),
		"discovered_entity_ids": _ids_to_strings(discovered_entity_ids),
		"resolved_message_ids": _ids_to_strings(resolved_message_ids),
		"revealed_panel_ids": _ids_to_strings(revealed_panel_ids),
		"panel_drafts": _copy_drafts(panel_drafts),
		"panel_status": panel_status.duplicate(true),
		"accepted_solution_ids": _ids_to_strings(accepted_solution_ids),
		"unlocked_hint_ids": _ids_to_strings(unlocked_hint_ids),
		"reviewed": reviewed,
		"status": String(status)
	}


static func from_dict(data: Variant) -> DeductionCaseProgress:
	if not data is Dictionary \
			or not DeductionContentValidator.has_only_keys(data, PROGRESS_KEYS) \
			or not DeductionContentValidator.is_json_safe(data) \
			or not DeductionContentValidator.is_schema_version(data.get("schema_version")) \
			or not data.get("reviewed", false) is bool:
		return null
	var status_value: Variant = data.get("status", String(STATUS_OPEN))
	if not status_value is String or not _is_status(status_value):
		return null
	var progress := DeductionCaseProgress.new()
	progress.case_id = DeductionContentValidator.read_id(data.get("case_id", ""))
	progress.current_scene_id = DeductionContentValidator.read_id(data.get("current_scene_id", ""))
	progress.visited_scene_ids = DeductionContentValidator.to_string_names(data.get("visited_scene_ids", []))
	progress.discovered_entity_ids = DeductionContentValidator.to_string_names(data.get("discovered_entity_ids", []))
	progress.resolved_message_ids = DeductionContentValidator.to_string_names(data.get("resolved_message_ids", []))
	progress.revealed_panel_ids = DeductionContentValidator.to_string_names(data.get("revealed_panel_ids", []))
	progress.panel_drafts = _read_drafts(data.get("panel_drafts", {}))
	progress.panel_status = _read_status_map(data.get("panel_status", {}))
	progress.accepted_solution_ids = DeductionContentValidator.to_string_names(data.get("accepted_solution_ids", []))
	progress.unlocked_hint_ids = DeductionContentValidator.to_string_names(data.get("unlocked_hint_ids", []))
	progress.reviewed = data.get("reviewed", false)
	progress.status = StringName(String(status_value))
	return progress


static func _is_status(value: Variant) -> bool:
	return value is String and STATUSES.has(StringName(String(value)))


static func _ids_to_strings(values: Array[StringName]) -> Array:
	var result: Array = []
	for value: StringName in values:
		if not result.has(String(value)):
			result.append(String(value))
	return result


static func _copy_drafts(drafts: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for panel_id: Variant in drafts:
		if not panel_id is String or not drafts[panel_id] is Dictionary:
			continue
		var draft: Dictionary = {}
		for slot_id: Variant in drafts[panel_id]:
			var entity_id: Variant = drafts[panel_id][slot_id]
			if slot_id is String and DeductionContentValidator.is_stable_id(slot_id) \
					and DeductionContentValidator.is_stable_id(entity_id):
				draft[slot_id] = String(entity_id)
		result[String(panel_id)] = draft
	return result


static func _read_drafts(value: Variant) -> Dictionary:
	return _copy_drafts(value) if value is Dictionary else {}


static func _read_status_map(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not value is Dictionary:
		return result
	for panel_id: Variant in value:
		var status: Variant = value[panel_id]
		if panel_id is String and _is_status(status):
			result[String(panel_id)] = String(status)
	return result
