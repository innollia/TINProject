class_name DeductionConditionEvaluator
extends RefCounted

const MAX_DEPTH: int = 8


static func evaluate(
	condition: DeductionCaseworkCaseDefinition.ConditionDefinition,
	progress: DeductionCaseProgress,
	solved_case_ids: Array = []
) -> bool:
	if condition == null:
		return true
	return _evaluate(condition, progress, solved_case_ids, 0)


static func evaluate_all(
	conditions: Array,
	progress: DeductionCaseProgress,
	solved_case_ids: Array = []
) -> bool:
	for condition: Variant in conditions:
		if not evaluate(condition, progress, solved_case_ids):
			return false
	return true


static func assignment_satisfied(progress: DeductionCaseProgress, slot_id: StringName, entity_id: StringName) -> bool:
	if progress == null or slot_id.is_empty() or entity_id.is_empty():
		return false
	for panel_id: Variant in progress.panel_drafts:
		var draft: Variant = progress.panel_drafts[panel_id]
		if not draft is Dictionary:
			continue
		for draft_slot_id: Variant in draft:
			if String(draft_slot_id) == String(slot_id) and String(draft[draft_slot_id]) == String(entity_id):
				return true
	return false


static func _evaluate(
	condition: DeductionCaseworkCaseDefinition.ConditionDefinition,
	progress: DeductionCaseProgress,
	solved_case_ids: Array,
	depth: int
) -> bool:
	if progress == null or depth > MAX_DEPTH:
		return false
	for child: DeductionCaseworkCaseDefinition.ConditionDefinition in condition.all_of:
		if not _evaluate(child, progress, solved_case_ids, depth + 1):
			return false
	if not condition.any_of.is_empty():
		var any_satisfied := false
		for child: DeductionCaseworkCaseDefinition.ConditionDefinition in condition.any_of:
			if _evaluate(child, progress, solved_case_ids, depth + 1):
				any_satisfied = true
				break
		if not any_satisfied:
			return false
	if condition.negated != null and _evaluate(condition.negated, progress, solved_case_ids, depth + 1):
		return false
	if not condition.requires_discovered_entity_id.is_empty() \
			and not progress.discovered_entity_ids.has(condition.requires_discovered_entity_id):
		return false
	if not condition.requires_resolved_message_id.is_empty() \
			and not progress.resolved_message_ids.has(condition.requires_resolved_message_id):
		return false
	if not condition.requires_solved_case_id.is_empty() and not solved_case_ids.has(condition.requires_solved_case_id):
		return false
	if not condition.requires_assignment_id.is_empty():
		return assignment_satisfied(
			progress, condition.requires_assignment_id, condition.requires_assignment_entity_id
		)
	return true
