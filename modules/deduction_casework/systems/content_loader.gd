class_name DeductionContentLoader
extends RefCounted

const CONTENT_DIRECTORY: String = "res://modules/deduction_casework/content"
const INDEX_PATH: String = "res://modules/deduction_casework/content/index.json"
const INDEX_SCHEMA_VERSION: int = 1
const MAX_CONDITION_DEPTH: int = 8

const DeductionCaseworkCaseState = preload("res://modules/deduction_casework/domain/case_state.gd")


class CaseCatalog:
	extends RefCounted

	var definitions: Array[DeductionCaseworkCaseDefinition] = []
	var unavailable_case_ids: Array[StringName] = []

	func size() -> int:
		return definitions.size()

	func has_case(case_id: StringName) -> bool:
		return get_definition(case_id) != null

	func list_case_ids() -> Array[StringName]:
		var result: Array[StringName] = []
		for definition: DeductionCaseworkCaseDefinition in definitions:
			result.append(definition.id)
		return result

	func get_definition(case_id: StringName) -> DeductionCaseworkCaseDefinition:
		for definition: DeductionCaseworkCaseDefinition in definitions:
			if definition.id == case_id:
				return definition
		return null

	func to_dict() -> Dictionary:
		return {
			"available": _to_strings(list_case_ids()),
			"unavailable": _to_strings(unavailable_case_ids)
		}


	static func _to_strings(values: Array) -> Array:
		var result: Array = []
		for value: Variant in values:
			result.append(String(value))
		return result


static func load_catalog() -> CaseCatalog:
	var catalog := CaseCatalog.new()
	for entry: Dictionary in _read_index_entries():
		var case_id := StringName(entry["id"])
		var definition := validate_case_document(_read_case_document(String(entry["path"])), case_id)
		if definition == null:
			catalog.unavailable_case_ids.append(case_id)
			continue
		catalog.definitions.append(definition)
	return catalog


static func list_case_ids() -> Array[StringName]:
	return load_catalog().list_case_ids()


static func load_case(case_id: StringName) -> DeductionCaseworkCaseDefinition:
	return load_catalog().get_definition(case_id)


static func get_definition(case_id: StringName) -> DeductionCaseworkCaseDefinition:
	return load_case(case_id)


static func validate_case(case_id: StringName) -> bool:
	return load_case(case_id) != null


static func validate_case_document(data: Variant, expected_id: StringName = &"") -> DeductionCaseworkCaseDefinition:
	var definition: DeductionCaseworkCaseDefinition = DeductionCaseworkCaseDefinition.from_dict(data)
	if definition == null:
		return null
	if not expected_id.is_empty() and expected_id != definition.id:
		return null
	for entries: Array in [definition.scenes, definition.closeups, definition.entities,
			definition.messages, definition.panels, definition.solutions, definition.hints]:
		if not _ids_are_unique(entries):
			return null
	if not definition.has_scene(definition.start_scene_id):
		return null
	if not _scenes_are_valid(definition) or not _closeups_are_valid(definition):
		return null
	if not _messages_are_valid(definition) or not _panels_are_valid(definition):
		return null
	if not _solutions_are_valid(definition) or not _hints_are_valid(definition):
		return null
	if not _review_is_valid(definition):
		return null
	return definition


static func new_state() -> DeductionCaseworkCaseState:
	return DeductionCaseworkCaseState.new()


static func _read_index_entries() -> Array:
	var document: Variant = DeductionContentValidator.parse_json_document(_read_text(INDEX_PATH))
	if not document is Dictionary or not DeductionContentValidator.has_only_keys(document, DeductionContentValidator.INDEX_KEYS) \
		or not DeductionContentValidator.has_all_keys(document, DeductionContentValidator.INDEX_KEYS):
		return []
	if not DeductionContentValidator.is_integer(document.get("schema_version")) \
		or int(document["schema_version"]) != INDEX_SCHEMA_VERSION \
		or not document.get("cases") is Array:
		return []
	var entries: Array = []
	var seen_ids: Dictionary = {}
	var seen_paths: Dictionary = {}
	for entry_value: Variant in document["cases"]:
		if not entry_value is Dictionary \
			or not DeductionContentValidator.has_only_keys(entry_value, DeductionContentValidator.INDEX_ENTRY_KEYS) \
			or not DeductionContentValidator.has_all_keys(entry_value, DeductionContentValidator.INDEX_ENTRY_KEYS):
			return []
		var id_value: Variant = entry_value.get("id")
		var path_value: Variant = entry_value.get("path")
		if not DeductionContentValidator.is_stable_id(id_value) \
			or not DeductionContentValidator.is_content_path(path_value) \
			or seen_ids.has(id_value) or seen_paths.has(path_value):
			return []
		seen_ids[id_value] = true
		seen_paths[path_value] = true
		entries.append({"id": id_value, "path": path_value})
	return entries


static func _read_case_document(relative_path: String) -> Variant:
	return DeductionContentValidator.parse_json_document(
		_read_text(CONTENT_DIRECTORY.path_join(relative_path))
	)


static func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


static func _ids_are_unique(entries: Array) -> bool:
	var seen: Dictionary = {}
	for entry: Variant in entries:
		if seen.has(entry.id):
			return false
		seen[entry.id] = true
	return true


static func _scenes_are_valid(definition: DeductionCaseworkCaseDefinition) -> bool:
	for scene: DeductionCaseworkCaseDefinition.SceneDefinition in definition.scenes:
		if not _ids_are_unique(scene.hotspots) or not _ids_are_unique(scene.transitions):
			return false
		for transition: DeductionCaseworkCaseDefinition.TransitionDefinition in scene.transitions:
			if not transition.destination_scene_id.is_empty() \
				and not definition.has_scene(transition.destination_scene_id):
				return false
	return true


static func _closeups_are_valid(definition: DeductionCaseworkCaseDefinition) -> bool:
	var scene_paths: Dictionary = {}
	for scene: DeductionCaseworkCaseDefinition.SceneDefinition in definition.scenes:
		scene_paths[scene.scene_path] = true
	for closeup: DeductionCaseworkCaseDefinition.CloseupDefinition in definition.closeups:
		if not definition.has_scene(closeup.parent_scene_id):
			return false
		if scene_paths.has(closeup.scene_path) or not _ids_are_unique(closeup.hotspots):
			return false
	return true


static func _messages_are_valid(definition: DeductionCaseworkCaseDefinition) -> bool:
	for message: DeductionCaseworkCaseDefinition.MessageDefinition in definition.messages:
		for source_ref: StringName in message.source_refs:
			if not definition.has_entity(source_ref):
				return false
		if not message.detail_scene_id.is_empty() and not definition.has_scene(message.detail_scene_id):
			return false
		if not _condition_is_valid(message.prerequisite_condition, definition):
			return false
	return true


static func _panels_are_valid(definition: DeductionCaseworkCaseDefinition) -> bool:
	for panel: DeductionCaseworkCaseDefinition.PanelDefinition in definition.panels:
		if panel.slots.is_empty() or panel.almost_threshold > panel.slots.size():
			return false
		var segment_ids: Dictionary = {}
		for segment: DeductionCaseworkCaseDefinition.SegmentDefinition in panel.segments:
			segment_ids[segment.id] = true
		var slot_ids: Dictionary = {}
		for slot: DeductionCaseworkCaseDefinition.PanelSlotDefinition in panel.slots:
			if slot_ids.has(slot.id) or not segment_ids.has(slot.segment_id):
				return false
			for entity_id: StringName in slot.accepted_entity_ids:
				if not definition.has_entity(entity_id):
					return false
			slot_ids[slot.id] = true
		if not _condition_is_valid(panel.unlock_condition, definition):
			return false
	return true


static func _solutions_are_valid(definition: DeductionCaseworkCaseDefinition) -> bool:
	for solution: DeductionCaseworkCaseDefinition.SolutionDefinition in definition.solutions:
		var panel: DeductionCaseworkCaseDefinition.PanelDefinition = definition.get_panel(solution.panel_id)
		if panel == null or solution.required_assignments.is_empty():
			return false
		var slot_ids: Dictionary = {}
		for slot: DeductionCaseworkCaseDefinition.PanelSlotDefinition in panel.slots:
			slot_ids[slot.id] = true
		var required: Dictionary = {}
		for assignment: DeductionCaseworkCaseDefinition.AssignmentDefinition in solution.required_assignments:
			if not slot_ids.has(assignment.slot_id) or not definition.has_entity(assignment.entity_id):
				return false
			if required.has(assignment.slot_id) or required.has(assignment.entity_id):
				return false
			required[assignment.slot_id] = assignment.entity_id
		for assignment: DeductionCaseworkCaseDefinition.AssignmentDefinition in solution.forbidden_assignments:
			if not slot_ids.has(assignment.slot_id) or not definition.has_entity(assignment.entity_id):
				return false
			if required.get(assignment.slot_id) == assignment.entity_id:
				return false
		for condition: DeductionCaseworkCaseDefinition.ConditionDefinition in solution.all_of_conditions:
			if not _condition_is_valid(condition, definition):
				return false
		if not solution.completion_review_id.is_empty() \
			and (definition.review == null or definition.review.id != solution.completion_review_id):
			return false
	return true


static func _hints_are_valid(definition: DeductionCaseworkCaseDefinition) -> bool:
	for hint: DeductionCaseworkCaseDefinition.HintDefinition in definition.hints:
		if hint.title.strip_edges().is_empty() or hint.body.strip_edges().is_empty():
			return false
		if not _condition_is_valid(hint.prerequisite_condition, definition):
			return false
	return true


static func _review_is_valid(definition: DeductionCaseworkCaseDefinition) -> bool:
	if definition.review != null:
		if definition.review.conclusion.strip_edges().is_empty():
			return false
		var referenced: Dictionary = {}
		for referenced_id: StringName in definition.review.referenced_case_ids:
			if referenced.has(referenced_id) or referenced_id == definition.id:
				return false
			referenced[referenced_id] = true
	var routed: Dictionary = {}
	for next_id: StringName in definition.next_case_ids:
		if routed.has(next_id) or next_id == definition.id:
			return false
		routed[next_id] = true
	return true


static func _condition_is_valid(condition: DeductionCaseworkCaseDefinition.ConditionDefinition,
		definition: DeductionCaseworkCaseDefinition, depth: int = 0) -> bool:
	if condition == null:
		return true
	if depth > MAX_CONDITION_DEPTH:
		return false
	if not condition.requires_discovered_entity_id.is_empty() \
		and not definition.has_entity(condition.requires_discovered_entity_id):
		return false
	if not condition.requires_resolved_message_id.is_empty() \
		and not definition.has_message(condition.requires_resolved_message_id):
		return false
	if condition.requires_solved_case_id.is_empty() \
		and not condition.requires_assignment_id.is_empty() \
		and not condition.requires_assignment_entity_id.is_empty():
		return false
	if condition.is_leaf():
		return not condition.requires_discovered_entity_id.is_empty() \
			or not condition.requires_resolved_message_id.is_empty() \
			or not condition.requires_solved_case_id.is_empty() \
			or not condition.requires_assignment_id.is_empty() \
			or not condition.requires_assignment_entity_id.is_empty()
	for child: DeductionCaseworkCaseDefinition.ConditionDefinition in condition.all_of:
		if not _condition_is_valid(child, definition, depth + 1):
			return false
	for child: DeductionCaseworkCaseDefinition.ConditionDefinition in condition.any_of:
		if not _condition_is_valid(child, definition, depth + 1):
			return false
	return _condition_is_valid(condition.negated, definition, depth + 1)
