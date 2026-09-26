class_name DeductionPanelWorkspace
extends RefCounted

const MOVE: StringName = &"move"

const REASON_OK: StringName = &""
const REASON_UNKNOWN_PANEL: StringName = &"unknown_panel"
const REASON_UNKNOWN_SLOT: StringName = &"unknown_slot"
const REASON_UNKNOWN_ENTITY: StringName = &"unknown_entity"
const REASON_PANEL_LOCKED: StringName = &"panel_locked"
const REASON_REJECTED_KIND: StringName = &"rejected_kind"
const REASON_OCCUPIED: StringName = &"slot_occupied"
const REASON_SLOT_PERSISTENT: StringName = &"slot_persistent"
const REASON_EMPTY: StringName = &"slot_empty"


static func is_unlocked(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	panel_id: StringName,
	solved_case_ids: Array = []
) -> bool:
	var panel: DeductionCaseworkCaseDefinition.PanelDefinition = null
	if definition != null:
		panel = definition.get_panel(panel_id)
	if panel == null or progress == null:
		return false
	return DeductionConditionEvaluator.evaluate(panel.unlock_condition, progress, solved_case_ids)


static func find_slot(
	panel: DeductionCaseworkCaseDefinition.PanelDefinition,
	slot_id: StringName
) -> DeductionCaseworkCaseDefinition.PanelSlotDefinition:
	if panel == null or slot_id.is_empty():
		return null
	for slot: DeductionCaseworkCaseDefinition.PanelSlotDefinition in panel.slots:
		if slot.id == slot_id:
			return slot
	return null


static func slot_accepts(
	panel: DeductionCaseworkCaseDefinition.PanelDefinition,
	slot: DeductionCaseworkCaseDefinition.PanelSlotDefinition,
	entity: DeductionCaseworkCaseDefinition.EntityDefinition
) -> bool:
	if panel == null or slot == null or entity == null:
		return false
	if not panel.accepted_entity_kinds.is_empty() and not panel.accepted_entity_kinds.has(entity.kind):
		return false
	if not slot.accepted_kinds.is_empty() and not slot.accepted_kinds.has(entity.kind):
		return false
	if not slot.accepted_entity_ids.is_empty() and not slot.accepted_entity_ids.has(entity.id):
		return false
	return true


static func assign(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	panel_id: StringName,
	entity_id: StringName,
	slot_id: StringName,
	solved_case_ids: Array = []
) -> Dictionary:
	var panel: DeductionCaseworkCaseDefinition.PanelDefinition = null
	if definition != null:
		panel = definition.get_panel(panel_id)
	if panel == null or progress == null:
		return _rejected(REASON_UNKNOWN_PANEL)
	if not is_unlocked(definition, progress, panel_id, solved_case_ids):
		return _rejected(REASON_PANEL_LOCKED)
	var entity: DeductionCaseworkCaseDefinition.EntityDefinition = null
	if definition != null:
		entity = definition.get_entity(entity_id)
	if entity == null:
		return _rejected(REASON_UNKNOWN_ENTITY)
	var slot: DeductionCaseworkCaseDefinition.PanelSlotDefinition = find_slot(panel, slot_id)
	if slot == null:
		return _rejected(REASON_UNKNOWN_SLOT)
	if not slot_accepts(panel, slot, entity):
		return _rejected(REASON_REJECTED_KIND)
	var draft := read_draft(progress, panel_id)
	var target_key := String(slot.id)
	var target_entity := String(draft.get(target_key, ""))
	if target_entity == String(entity.id):
		return _result(panel_id, target_key, entity.id, false, REASON_OK, "")
	if not target_entity.is_empty():
		return _rejected(REASON_OCCUPIED)
	var moved_from := ""
	for key: Variant in draft:
		if String(draft[key]) == String(entity.id):
			moved_from = String(key)
			break
	if not moved_from.is_empty() and slot.move_policy == MOVE:
		draft.erase(moved_from)
	draft[target_key] = String(entity.id)
	progress.panel_drafts[String(panel_id)] = draft
	return _result(panel_id, target_key, entity.id, true, REASON_OK, moved_from)


static func remove_assignment(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	panel_id: StringName,
	slot_id: StringName
) -> Dictionary:
	var panel: DeductionCaseworkCaseDefinition.PanelDefinition = null
	if definition != null:
		panel = definition.get_panel(panel_id)
	if panel == null or progress == null:
		return _rejected(REASON_UNKNOWN_PANEL)
	var slot: DeductionCaseworkCaseDefinition.PanelSlotDefinition = find_slot(panel, slot_id)
	if slot == null:
		return _rejected(REASON_UNKNOWN_SLOT)
	var draft := read_draft(progress, panel_id)
	var target_key := String(slot.id)
	if not draft.has(target_key):
		return _result(panel_id, target_key, &"", false, REASON_EMPTY, "")
	if slot.persistent:
		return _rejected(REASON_SLOT_PERSISTENT)
	draft.erase(target_key)
	progress.panel_drafts[String(panel_id)] = draft
	return _result(panel_id, target_key, &"", true, REASON_OK, "")


static func read_draft(progress: DeductionCaseProgress, panel_id: StringName) -> Dictionary:
	if progress == null or not progress.panel_drafts.get(String(panel_id), null) is Dictionary:
		return {}
	var draft: Variant = progress.panel_drafts[String(panel_id)]
	return (draft as Dictionary).duplicate(true)


static func filled_slot_count(progress: DeductionCaseProgress, panel_id: StringName) -> int:
	return read_draft(progress, panel_id).size()


static func _result(
	panel_id: StringName,
	slot_id: String,
	entity_id: StringName,
	changed: bool,
	reason: StringName,
	moved_from: String
) -> Dictionary:
	return {
		"accepted": true, "reason": reason, "changed": changed,
		"panel_id": String(panel_id), "slot_id": slot_id,
		"entity_id": String(entity_id), "moved_from": moved_from
	}


static func _rejected(reason: StringName) -> Dictionary:
	return {"accepted": false, "reason": reason, "changed": false}
