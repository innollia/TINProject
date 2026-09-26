class_name DeductionSolutionEvaluator
extends RefCounted

const STATUS_UNDISCOVERED: StringName = &"UNDISCOVERED"
const STATUS_NOT_FILLED: StringName = &"NOT_FILLED"
const STATUS_UNSOLVED: StringName = &"UNSOLVED"
const STATUS_ALMOST: StringName = &"ALMOST"
const STATUS_SOLVED: StringName = &"SOLVED"
const STATUSES: Array[StringName] = [
	STATUS_UNDISCOVERED, STATUS_NOT_FILLED, STATUS_UNSOLVED, STATUS_ALMOST, STATUS_SOLVED
]
const JSON_NAMES: Array[String] = ["undiscovered", "not_filled", "unsolved", "almost", "solved"]


static func json_name(status: StringName) -> String:
	var index: int = STATUSES.find(status)
	return JSON_NAMES[index] if index >= 0 else JSON_NAMES[2]


static func panel_status(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	panel_id: StringName,
	solved_case_ids: Array = []
) -> StringName:
	var result: Dictionary = evaluate_panel(definition, progress, panel_id, solved_case_ids)
	return StringName(String(result.get("status", STATUS_UNSOLVED)))


static func evaluate_panel(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	panel_id: StringName,
	solved_case_ids: Array = []
) -> Dictionary:
	var panel: DeductionCaseworkCaseDefinition.PanelDefinition = null
	if definition != null:
		panel = definition.get_panel(panel_id)
	if panel == null or progress == null:
		return _result(STATUS_UNSOLVED, &"", 0, 0)
	var draft: Dictionary = DeductionPanelWorkspace.read_draft(progress, panel_id)
	if not progress.revealed_panel_ids.has(panel_id) and draft.is_empty():
		return _result(STATUS_UNDISCOVERED, &"", 0, 0)
	if draft.is_empty():
		return _result(STATUS_NOT_FILLED, &"", 0, 0)
	var best_solution: DeductionCaseworkCaseDefinition.SolutionDefinition = null
	var best_matched := -1
	var best_total := 0
	for solution: DeductionCaseworkCaseDefinition.SolutionDefinition in definition.solutions:
		if solution.panel_id != panel_id:
			continue
		if solution_matches(definition, progress, solution, solved_case_ids):
			return _result(STATUS_SOLVED, solution.id, solution.required_assignments.size(), solution.required_assignments.size())
		var matched: int = _matched_count(draft, solution)
		if matched > best_matched:
			best_solution = solution
			best_matched = matched
			best_total = solution.required_assignments.size()
	if best_solution == null or best_matched <= 0:
		return _result(STATUS_UNSOLVED, &"", maxi(best_matched, 0), best_total)
	if best_total - best_matched <= panel.almost_threshold:
		return _result(STATUS_ALMOST, &"", best_matched, best_total)
	return _result(STATUS_UNSOLVED, &"", best_matched, best_total)


static func solution_matches(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	solution: DeductionCaseworkCaseDefinition.SolutionDefinition,
	solved_case_ids: Array = []
) -> bool:
	if definition == null or progress == null or solution == null:
		return false
	var draft: Dictionary = DeductionPanelWorkspace.read_draft(progress, solution.panel_id)
	for assignment: DeductionCaseworkCaseDefinition.AssignmentDefinition in solution.required_assignments:
		if String(draft.get(String(assignment.slot_id), "")) != String(assignment.entity_id):
			return false
	for assignment: DeductionCaseworkCaseDefinition.AssignmentDefinition in solution.forbidden_assignments:
		if String(draft.get(String(assignment.slot_id), "")) == String(assignment.entity_id):
			return false
	return DeductionConditionEvaluator.evaluate_all(solution.all_of_conditions, progress, solved_case_ids)


static func evaluate_case(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	solved_case_ids: Array = []
) -> Dictionary:
	var statuses: Dictionary = {}
	var solved_panel_ids: Array = []
	var pending_panel_ids: Array = []
	var accepted_solution_id: StringName = &""
	if definition != null and progress != null:
		for panel: DeductionCaseworkCaseDefinition.PanelDefinition in definition.panels:
			var status := panel_status(definition, progress, panel.id, solved_case_ids)
			statuses[String(panel.id)] = json_name(status)
			if status == STATUS_SOLVED:
				solved_panel_ids.append(String(panel.id))
			elif panel.required_for_completion:
				pending_panel_ids.append(String(panel.id))
		for solution: DeductionCaseworkCaseDefinition.SolutionDefinition in definition.solutions:
			if solution_matches(definition, progress, solution, solved_case_ids):
				accepted_solution_id = solution.id
				break
	return {
		"solved": not solved_panel_ids.is_empty() and pending_panel_ids.is_empty(),
		"solution_id": String(accepted_solution_id),
		"panel_status": statuses,
		"solved_panel_ids": solved_panel_ids,
		"pending_panel_ids": pending_panel_ids
	}


static func _matched_count(
	draft: Dictionary,
	solution: DeductionCaseworkCaseDefinition.SolutionDefinition
) -> int:
	var matched := 0
	for assignment: DeductionCaseworkCaseDefinition.AssignmentDefinition in solution.required_assignments:
		if String(draft.get(String(assignment.slot_id), "")) == String(assignment.entity_id):
			matched += 1
	return matched


static func _result(
	status: StringName,
	solution_id: StringName,
	matched: int,
	total: int
) -> Dictionary:
	return {
		"status": status,
		"solution_id": String(solution_id),
		"matched": matched,
		"required": total
	}
