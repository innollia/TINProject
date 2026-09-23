class_name DeductionCaseLoader
extends RefCounted

static func load_directory(directory_path: String) -> Dictionary:
	var directory: DirAccess = DirAccess.open(directory_path)
	if directory == null:
		return {"ok": false, "cases": [], "errors": ["case directory could not be opened: %s" % directory_path]}
	var paths: Array[String] = []
	for file_name: String in directory.get_files():
		if file_name.get_extension().to_lower() == "tres":
			paths.append(directory_path.path_join(file_name))
	paths.sort()
	return load_paths(paths)

static func load_paths(paths: Array[String]) -> Dictionary:
	var definitions: Array[DeductionCaseDefinition] = []
	var errors: Array[String] = []
	for path: String in paths:
		var loaded: Resource = load(path)
		if not loaded is DeductionCaseDefinition:
			errors.append("%s is not a DeductionCaseDefinition" % path)
			continue
		definitions.append(loaded)
	var validation_errors := validate_cases(definitions)
	errors.append_array(validation_errors)
	return {"ok": errors.is_empty(), "cases": definitions if errors.is_empty() else [], "errors": errors}

static func validate_cases(definitions: Array[DeductionCaseDefinition]) -> Array[String]:
	var errors: Array[String] = []
	var case_ids: Dictionary = {}
	if definitions.is_empty():
		errors.append("case catalog is empty")
		return errors
	for definition: DeductionCaseDefinition in definitions:
		if definition == null:
			errors.append("case resource is null")
			continue
		var prefix: String = String(definition.case_id)
		if prefix.is_empty() or case_ids.has(prefix):
			errors.append("case id is empty or duplicated: %s" % prefix)
		case_ids[prefix] = true
		if definition.title.is_empty() or definition.solved_text.is_empty():
			errors.append("%s is missing its title or solved text" % prefix)
		if definition.minimum_rechecks < 0 or definition.minimum_rechecks > definition.scene_ids.size():
			errors.append("%s has an invalid minimum recheck count" % prefix)
		var scene_ids: Dictionary = {}
		var scene_count: int = definition.scene_ids.size()
		if scene_count == 0 or definition.scene_names.size() != scene_count or definition.findings.size() != scene_count or definition.details.size() != scene_count:
			errors.append("%s scene arrays must have the same nonzero size" % prefix)
		for index: int in range(scene_count):
			var scene_id: String = String(definition.scene_ids[index])
			var scene_name: String = definition.scene_names[index] if index < definition.scene_names.size() else ""
			var finding: String = definition.findings[index] if index < definition.findings.size() else ""
			var detail: String = definition.details[index] if index < definition.details.size() else ""
			if scene_id.is_empty() or scene_ids.has(scene_id) or scene_name.is_empty() or finding.is_empty() or detail.is_empty():
				errors.append("%s has an invalid scene at index %d" % [prefix, index])
			scene_ids[scene_id] = true
		var event_ids: Dictionary = {}
		var event_count: int = definition.event_ids.size()
		if event_count == 0 or definition.event_names.size() != event_count or definition.timeline_solution.size() != event_count:
			errors.append("%s event and timeline arrays must have the same nonzero size" % prefix)
		for index: int in range(event_count):
			var event_id: String = String(definition.event_ids[index])
			var event_name: String = definition.event_names[index] if index < definition.event_names.size() else ""
			if event_id.is_empty() or event_ids.has(event_id) or event_name.is_empty():
				errors.append("%s has an invalid event at index %d" % [prefix, index])
			event_ids[event_id] = true
		var timeline_ids: Dictionary = {}
		for event_id: StringName in definition.timeline_solution:
			if not event_ids.has(String(event_id)) or timeline_ids.has(String(event_id)):
				errors.append("%s timeline references an unknown or repeated event: %s" % [prefix, event_id])
			timeline_ids[String(event_id)] = true
		if timeline_ids.size() != event_ids.size():
			errors.append("%s timeline must order every event exactly once" % prefix)
		var slot_ids: Dictionary = {}
		if definition.answer_slots.is_empty():
			errors.append("%s has no answer slots" % prefix)
		for slot: DeductionSlotDefinition in definition.answer_slots:
			if slot == null:
				errors.append("%s contains a null answer slot" % prefix)
				continue
			var slot_id: String = String(slot.slot_id)
			if slot_id.is_empty() or slot_ids.has(slot_id) or slot.label.is_empty() or slot.options.is_empty():
				errors.append("%s has an invalid answer slot: %s" % [prefix, slot_id])
			slot_ids[slot_id] = slot
			var term_ids: Dictionary = {}
			for term: DeductionTermDefinition in slot.options:
				if term == null or String(term.term_id).is_empty() or term.display_name.is_empty() or term_ids.has(String(term.term_id)):
					errors.append("%s.%s has an invalid or duplicate term" % [prefix, slot_id])
					continue
				term_ids[String(term.term_id)] = true
			if not term_ids.has(String(slot.solution_id)):
				errors.append("%s.%s solution references an unknown term" % [prefix, slot_id])
		if slot_ids.size() != definition.answer_slots.size():
			continue
		for slot: DeductionSlotDefinition in definition.answer_slots:
			for term: DeductionTermDefinition in slot.options:
				if term.conflict_slot_id.is_empty() != term.conflict_term_id.is_empty():
					errors.append("%s.%s.%s has a partial conflict reference" % [prefix, slot.slot_id, term.term_id])
				elif not term.conflict_slot_id.is_empty():
					var conflict_slot: DeductionSlotDefinition = slot_ids.get(String(term.conflict_slot_id))
					if conflict_slot == null or conflict_slot.slot_id == slot.slot_id or not _has_term(conflict_slot, term.conflict_term_id):
						errors.append("%s.%s.%s conflict references an unknown slot or term" % [prefix, slot.slot_id, term.term_id])
	return errors

static func _has_term(slot: DeductionSlotDefinition, term_id: StringName) -> bool:
	for term: DeductionTermDefinition in slot.options:
		if term.term_id == term_id:
			return true
	return false
