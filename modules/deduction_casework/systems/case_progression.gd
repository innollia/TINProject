class_name DeductionCaseProgression
extends RefCounted

const REASON_OK: StringName = &""
const REASON_NOT_SOLVED: StringName = &"not_solved"
const REASON_NO_REVIEW: StringName = &"no_review"
const REASON_UNKNOWN_NEXT_CASE: StringName = &"unknown_next_case"


static func initial_progress(definition: DeductionCaseworkCaseDefinition) -> DeductionCaseProgress:
	var progress := DeductionCaseProgress.new()
	if definition == null:
		progress.status = DeductionCaseProgress.STATUS_CONTENT_UNAVAILABLE
		return progress
	progress.case_id = definition.id
	progress.current_scene_id = definition.start_scene_id
	progress.visited_scene_ids.append(definition.start_scene_id)
	progress.status = DeductionCaseProgress.STATUS_OPEN
	return progress


static func mark_solved(progress: DeductionCaseProgress, solution_id: StringName) -> void:
	if progress == null or solution_id.is_empty():
		return
	if not progress.accepted_solution_ids.has(solution_id):
		progress.accepted_solution_ids.append(solution_id)
	progress.reviewed = false
	progress.status = DeductionCaseProgress.STATUS_SOLVED


static func apply_review(
	progress: DeductionCaseProgress,
	definition: DeductionCaseworkCaseDefinition,
	state: DeductionCaseworkCaseState,
	next_case_id: StringName
) -> Dictionary:
	if progress == null or definition == null or state == null:
		return _rejected(REASON_NO_REVIEW)
	if progress.status != DeductionCaseProgress.STATUS_SOLVED or definition.review == null:
		return _rejected(REASON_NOT_SOLVED)
	if not next_case_id.is_empty() and not definition.next_case_ids.has(next_case_id):
		return _rejected(REASON_UNKNOWN_NEXT_CASE)
	var route: Dictionary = state.route_state.duplicate(true)
	var unlocked: Array = _string_array(route.get("unlocked_case_ids", []))
	var reviewed: Array = _string_array(route.get("reviewed_case_ids", []))
	for candidate_id: StringName in definition.next_case_ids:
		if not unlocked.has(String(candidate_id)):
			unlocked.append(String(candidate_id))
	if not reviewed.has(String(definition.id)):
		reviewed.append(String(definition.id))
	route["unlocked_case_ids"] = unlocked
	route["reviewed_case_ids"] = reviewed
	state.route_state = route
	progress.reviewed = true
	progress.status = DeductionCaseProgress.STATUS_REVIEWED
	return {
		"accepted": true, "reason": REASON_OK, "changed": true,
		"review_id": String(definition.review.id),
		"next_case_ids": DeductionContentValidator.strings_to_dict(definition.next_case_ids),
		"activate_case_id": String(next_case_id)
	}


static func solved_case_ids(state: DeductionCaseworkCaseState) -> Array:
	var result: Array = []
	if state == null:
		return result
	for key: Variant in state.case_progress_by_id:
		var progress: Variant = state.case_progress_by_id[key]
		if not key is String or not progress is Dictionary:
			continue
		var status := StringName(DeductionContentValidator.read_string(progress.get("status", "")))
		if status == DeductionCaseProgress.STATUS_SOLVED or status == DeductionCaseProgress.STATUS_REVIEWED:
			if not result.has(String(key)):
				result.append(StringName(String(key)))
	return result


static func _string_array(value: Variant) -> Array:
	var result: Array = []
	if not value is Array:
		return result
	for item: Variant in value:
		var text := DeductionContentValidator.read_string(item)
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result


static func _rejected(reason: StringName) -> Dictionary:
	return {"accepted": false, "reason": reason, "changed": false}
