class_name DeductionSaveAdapter
extends RefCounted


static func new_state() -> DeductionCaseworkCaseState:
	return DeductionCaseworkCaseState.new()


static func encode(state: DeductionCaseworkCaseState) -> String:
	return JSON.stringify(to_payload(state))


static func decode(text: String) -> Variant:
	return _restore_integers(DeductionContentValidator.parse_json_document(text))


static func to_payload(state: DeductionCaseworkCaseState) -> Dictionary:
	return state.to_dict() if state != null else new_state().to_dict()


static func sanitize(catalog: DeductionContentLoader.CaseCatalog, data: Variant) -> DeductionCaseworkCaseState:
	var case_ids: Array[StringName] = []
	if catalog != null:
		case_ids = catalog.list_case_ids()
	var state := sanitize_shape(case_ids, data)
	if catalog == null:
		return state
	var progress_by_id: Dictionary = {}
	for key: Variant in state.case_progress_by_id:
		if not key is String:
			continue
		var progress := sanitize_progress(catalog.get_definition(StringName(String(key))), state.case_progress_by_id[key])
		if progress == null:
			continue
		progress_by_id[String(key)] = progress.to_dict()
	state.case_progress_by_id = progress_by_id
	_fix_selection(case_ids, state)
	return state


static func sanitize_shape(case_ids: Array[StringName], data: Variant) -> DeductionCaseworkCaseState:
	var state := DeductionCaseworkCaseState.from_dict(_normalize(data))
	if state == null:
		return new_state()
	var progress: Dictionary = {}
	for key: Variant in state.case_progress_by_id:
		if key is String and case_ids.has(StringName(String(key))) and state.case_progress_by_id[key] is Dictionary:
			progress[String(key)] = (state.case_progress_by_id[key] as Dictionary).duplicate(true)
	state.case_progress_by_id = progress
	state.route_state = {
		"unlocked_case_ids": _filter_case_ids(case_ids, state.route_state.get("unlocked_case_ids", [])),
		"reviewed_case_ids": _filter_case_ids(case_ids, state.route_state.get("reviewed_case_ids", []))
	}
	_fix_selection(case_ids, state)
	return state


static func sanitize_progress(
	definition: DeductionCaseworkCaseDefinition,
	data: Variant
) -> DeductionCaseProgress:
	var progress := DeductionCaseProgress.from_dict(data)
	if progress == null or definition == null:
		return null
	progress.case_id = definition.id
	if not definition.has_scene(progress.current_scene_id):
		progress.current_scene_id = definition.start_scene_id
	progress.visited_scene_ids = _filter_known(progress.visited_scene_ids, definition.scenes)
	if not progress.visited_scene_ids.has(progress.current_scene_id):
		progress.visited_scene_ids.append(progress.current_scene_id)
	progress.discovered_entity_ids = _filter_known(progress.discovered_entity_ids, definition.entities)
	progress.resolved_message_ids = _filter_known(progress.resolved_message_ids, definition.messages)
	progress.revealed_panel_ids = _filter_known(progress.revealed_panel_ids, definition.panels)
	progress.unlocked_hint_ids = _filter_known(progress.unlocked_hint_ids, definition.hints)
	progress.panel_drafts = _sanitize_drafts(definition, progress)
	progress.accepted_solution_ids = _filter_solutions(definition, progress)
	progress.panel_status = _recompute_status(definition, progress)
	progress.status = DeductionCaseProgress.STATUS_REVIEWED if progress.reviewed \
		else (DeductionCaseProgress.STATUS_SOLVED if not progress.accepted_solution_ids.is_empty() \
			else DeductionCaseProgress.STATUS_OPEN)
	progress.reviewed = progress.status == DeductionCaseProgress.STATUS_REVIEWED
	return progress


static func _restore_integers(value: Variant) -> Variant:
	match typeof(value):
		TYPE_FLOAT:
			return int(value) if is_finite(value) and value == floorf(value) and absf(value) < 9007199254740992.0 else value
		TYPE_ARRAY:
			var items: Array = []
			for item: Variant in value:
				items.append(_restore_integers(item))
			return items
		TYPE_DICTIONARY:
			var entries: Dictionary = {}
			for key: Variant in value:
				entries[key] = _restore_integers(value[key])
			return entries
	return value


static func _normalize(data: Variant) -> Dictionary:
	var source: Dictionary = data if data is Dictionary else {}
	var state := DeductionCaseworkCaseState.from_dict({
		"schema_version": DeductionCaseworkCaseState.SCHEMA_VERSION,
		"active_case_id": _read_id(source.get("active_case_id", "")),
		"last_case_id": _read_id(source.get("last_case_id", "")),
		"case_progress_by_id": source.get("case_progress_by_id", {}),
		"route_state": source.get("route_state", {})
	})
	if state == null:
		return new_state().to_dict()
	return {
		"schema_version": DeductionCaseworkCaseState.SCHEMA_VERSION,
		"active_case_id": String(state.active_case_id),
		"last_case_id": String(state.last_case_id),
		"case_progress_by_id": state.case_progress_by_id.duplicate(true),
		"route_state": {
			"unlocked_case_ids": _string_array(state.route_state.get("unlocked_case_ids", [])),
			"reviewed_case_ids": _string_array(state.route_state.get("reviewed_case_ids", []))
		}
	}


static func _sanitize_drafts(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress
) -> Dictionary:
	var result: Dictionary = {}
	for panel: DeductionCaseworkCaseDefinition.PanelDefinition in definition.panels:
		var draft: Dictionary = DeductionPanelWorkspace.read_draft(progress, panel.id)
		for slot_id: Variant in draft.keys():
			var slot := DeductionPanelWorkspace.find_slot(panel, StringName(String(slot_id)))
			var entity := definition.get_entity(StringName(String(draft[slot_id])))
			if slot == null or not DeductionPanelWorkspace.slot_accepts(panel, slot, entity):
				draft.erase(slot_id)
		if not draft.is_empty():
			result[String(panel.id)] = draft
	return result


static func _filter_solutions(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress
) -> Array[StringName]:
	var result: Array[StringName] = []
	for solution: DeductionCaseworkCaseDefinition.SolutionDefinition in definition.solutions:
		if result.has(solution.id):
			continue
		if DeductionSolutionEvaluator.solution_matches(definition, progress, solution, []):
			result.append(solution.id)
	return result


static func _recompute_status(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress
) -> Dictionary:
	var result: Dictionary = {}
	for panel: DeductionCaseworkCaseDefinition.PanelDefinition in definition.panels:
		result[String(panel.id)] = DeductionSolutionEvaluator.json_name(
			DeductionSolutionEvaluator.panel_status(definition, progress, panel.id, [])
		)
	return result


static func _filter_known(values: Array, entries: Array) -> Array[StringName]:
	var known: Array[StringName] = []
	for entry: Variant in entries:
		var id: Variant = entry.get("id")
		if id is String or id is StringName:
			known.append(StringName(String(id)))
	var result: Array[StringName] = []
	for value: Variant in values:
		var text := String(value) if value is String or value is StringName else ""
		if not text.is_empty() and known.has(StringName(text)) and not result.has(StringName(text)):
			result.append(StringName(text))
	return result


static func _filter_case_ids(case_ids: Array[StringName], value: Variant) -> Array[String]:
	var result: Array[String] = []
	for item: String in _string_array(value):
		if case_ids.has(StringName(item)):
			result.append(item)
	return result


static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if not value is Array:
		return result
	for item: Variant in value:
		var text := String(item) if item is String or item is StringName else ""
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result


static func _fix_selection(case_ids: Array[StringName], state: DeductionCaseworkCaseState) -> void:
	var active := String(state.active_case_id)
	var last := String(state.last_case_id)
	if not case_ids.has(StringName(active)):
		active = String(last) if case_ids.has(StringName(last)) else _first(case_ids)
	if not case_ids.has(StringName(last)):
		last = active
	state.active_case_id = StringName(active)
	state.last_case_id = StringName(last)


static func _first(case_ids: Array[StringName]) -> String:
	return String(case_ids[0]) if not case_ids.is_empty() else ""


static func _read_id(value: Variant) -> String:
	return String(value) if value is String or value is StringName else ""
