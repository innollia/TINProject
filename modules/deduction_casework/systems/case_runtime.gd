class_name DeductionCaseRuntime
extends RefCounted

signal snapshot_changed(snapshot: Dictionary)
signal intent_resolved(result: Dictionary)
signal case_solved(case_id: StringName, solution_id: StringName)

const INTENT_INTERACT: StringName = &"interact"
const INTENT_FOCUS_MOVE: StringName = &"focus_move"
const INTENT_ASSIGN: StringName = &"assign"
const INTENT_REMOVE_ASSIGNMENT: StringName = &"remove_assignment"
const INTENT_SUBMIT_PANEL: StringName = &"submit_panel"
const INTENT_USE_HINT: StringName = &"use_hint"
const INTENT_CANCEL: StringName = &"cancel"
const INTENT_REVIEW_CONFIRM: StringName = &"review_confirm"
const INTENT_RESET: StringName = &"reset"
const INTENT_RESET_CONFIRM: StringName = &"reset_confirm"
const INTENTS: Array[StringName] = [
	INTENT_INTERACT, INTENT_FOCUS_MOVE, INTENT_ASSIGN, INTENT_REMOVE_ASSIGNMENT,
	INTENT_SUBMIT_PANEL, INTENT_USE_HINT, INTENT_CANCEL, INTENT_REVIEW_CONFIRM,
	INTENT_RESET, INTENT_RESET_CONFIRM
]
const DIRECTIONS: Array[StringName] = [&"left", &"right", &"up", &"down"]
const BACKWARD_DIRECTIONS: Array[StringName] = [&"left", &"up"]

const REASON_OK: StringName = &""
const REASON_CONTENT_UNAVAILABLE: StringName = &"content_unavailable"
const REASON_UNKNOWN_INTENT: StringName = &"unknown_intent"
const REASON_UNKNOWN_TARGET: StringName = &"unknown_target"
const REASON_UNKNOWN_DIRECTION: StringName = &"unknown_direction"
const REASON_NO_FOCUS: StringName = &"no_focus"
const REASON_PANEL_UNSOLVED: StringName = &"panel_unsolved"
const REASON_RESET_NOT_PENDING: StringName = &"reset_not_pending"

var catalog: DeductionContentLoader.CaseCatalog = null
var definition: DeductionCaseworkCaseDefinition = null
var case_state: DeductionCaseworkCaseState = null
var progress: DeductionCaseProgress = null
var open_surface_id: StringName = &""
var return_focus_id: StringName = &""
var focus_id: StringName = &""
var hover_id: StringName = &""
var selected_entity_id: StringName = &""
var dragged_entity_id: StringName = &""
var feedback_reason: StringName = &""
var reset_pending: bool = false


func load(catalog_value: DeductionContentLoader.CaseCatalog, state: DeductionCaseworkCaseState) -> void:
	catalog = catalog_value
	case_state = state if state != null else DeductionSaveAdapter.new_state()
	_clear_transient()
	definition = null
	progress = null
	if catalog != null:
		definition = catalog.get_definition(case_state.active_case_id)
		if definition != null:
			progress = _stored_progress(case_state, definition)
			case_state.last_case_id = definition.id
			case_state.active_case_id = definition.id
			focus_id = _safe_start_focus()
	_emit()


func save_state() -> DeductionCaseworkCaseState:
	return case_state if case_state != null else DeductionSaveAdapter.new_state()


func focusable_ids() -> Array[StringName]:
	return _focusable_ids(progress.current_scene_id if progress != null else &"")


func _focusable_ids(scene_id: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	if definition == null or progress == null:
		return result
	var panel := _surface_panel()
	if panel != null:
		for slot: DeductionCaseworkCaseDefinition.PanelSlotDefinition in panel.slots:
			result.append(slot.id)
		for entity_id: StringName in progress.discovered_entity_ids:
			if not result.has(entity_id):
				result.append(entity_id)
		return result
	for hotspot: DeductionCaseworkCaseDefinition.HotspotDefinition in _hotspots_for(open_surface_id, scene_id):
		result.append(hotspot.id)
	var scene := definition.get_scene(scene_id)
	if scene != null:
		for transition: DeductionCaseworkCaseDefinition.TransitionDefinition in scene.transitions:
			result.append(transition.id)
	return result


func snapshot() -> Dictionary:
	var solved_case_ids: Array = []
	for case_id: StringName in DeductionCaseProgression.solved_case_ids(case_state):
		solved_case_ids.append(String(case_id))
	return {
		"content_available": definition != null and progress != null,
		"case_id": String(progress.case_id) if progress != null else "",
		"case_status": String(progress.status) if progress != null else "",
		"scene_id": String(progress.current_scene_id) if progress != null else "",
		"surface_id": String(open_surface_id),
		"surface": _surface_snapshot(),
		"focus_id": String(focus_id),
		"focusable_ids": _ids_to_strings(focusable_ids()),
		"hover_id": String(hover_id),
		"selected_entity_id": String(selected_entity_id),
		"dragged_entity_id": String(dragged_entity_id),
		"return_focus_id": String(return_focus_id),
		"feedback_reason": String(feedback_reason),
		"reset_pending": reset_pending,
		"discovered_entity_ids": _ids_to_strings(progress.discovered_entity_ids) if progress != null else [],
		"resolved_message_ids": _ids_to_strings(progress.resolved_message_ids) if progress != null else [],
		"revealed_panel_ids": _ids_to_strings(progress.revealed_panel_ids) if progress != null else [],
		"unlocked_hint_ids": _ids_to_strings(progress.unlocked_hint_ids) if progress != null else [],
		"solved_case_ids": solved_case_ids.duplicate(),
		"panels": _panel_snapshot(solved_case_ids),
		"review": _review_snapshot()
	}


func dispatch(intent: StringName, payload: Dictionary = {}) -> Dictionary:
	var result: Dictionary = _apply(intent, payload)
	result["intent"] = String(intent)
	result["snapshot"] = snapshot()
	intent_resolved.emit(result)
	return result


func _apply(intent: StringName, payload: Dictionary) -> Dictionary:
	if not INTENTS.has(intent):
		return _rejected(REASON_UNKNOWN_INTENT)
	if intent == INTENT_CANCEL:
		return _cancel()
	if intent == INTENT_RESET:
		return _request_reset()
	if definition == null or progress == null or case_state == null:
		return _rejected(REASON_CONTENT_UNAVAILABLE)
	if intent == INTENT_FOCUS_MOVE:
		return _focus_move(payload)
	if intent == INTENT_INTERACT:
		return _mutate(func(tx: Dictionary) -> Dictionary: return _interact(tx, payload))
	if intent == INTENT_ASSIGN:
		return _mutate(func(tx: Dictionary) -> Dictionary: return _assign(tx, payload))
	if intent == INTENT_REMOVE_ASSIGNMENT:
		return _mutate(func(tx: Dictionary) -> Dictionary: return _remove_assignment(tx, payload))
	if intent == INTENT_SUBMIT_PANEL:
		return _mutate(func(tx: Dictionary) -> Dictionary: return _submit_panel(tx, payload))
	if intent == INTENT_USE_HINT:
		return _mutate(func(tx: Dictionary) -> Dictionary: return _use_hint(tx, payload))
	if intent == INTENT_REVIEW_CONFIRM:
		return _mutate(func(tx: Dictionary) -> Dictionary: return _review_confirm(tx, payload))
	return _mutate(func(tx: Dictionary) -> Dictionary: return _reset_confirm(tx))


func _mutate(mutator: Callable) -> Dictionary:
	var transaction: Dictionary = {
		"progress": progress.clone(),
		"state": _copy_state(case_state)
	}
	var result: Dictionary = mutator.call(transaction)
	feedback_reason = &"" if bool(result.get("changed", false)) \
		else StringName(String(result.get("feedback_id", result.get("reason", REASON_OK))))
	if not bool(result.get("accepted", false)):
		return result
	progress = transaction["progress"]
	case_state = transaction["state"]
	_store_progress()
	var activate_id := StringName(String(result.get("activate_case_id", "")))
	if not activate_id.is_empty() and _activate_case(activate_id, case_state):
		_store_progress()
	if bool(result.get("clear_transient", false)):
		_clear_transient()
		open_surface_id = StringName(String(result.get("surface_id", "")))
		focus_id = _safe_start_focus()
	_emit()
	if bool(result.get("case_solved", false)):
		case_solved.emit(progress.case_id, StringName(String(result.get("solution_id", ""))))
	return result


func _interact(tx: Dictionary, payload: Dictionary) -> Dictionary:
	var working: DeductionCaseProgress = tx["progress"]
	var target_id := _read_id(payload.get("target_id", ""))
	if target_id.is_empty():
		return _rejected(REASON_NO_FOCUS)
	var panel := _surface_panel()
	if panel != null:
		return _interact_in_panel(tx, panel, target_id)
	var transition := _find_transition(target_id)
	if transition != null:
		return _enter_transition(working, transition)
	var resolved := DeductionDiscovery.resolve_hotspot(definition, _surface_hotspots(), target_id)
	if bool(resolved.get("accepted", false)):
		return _interact_resolved(tx, resolved)
	if definition.has_closeup(target_id):
		return _open_closeup(working, target_id)
	if definition.has_entity(target_id):
		return DeductionDiscovery.discover_entity(definition, working, target_id)
	if definition.has_message(target_id):
		return _open_message(working, target_id)
	if definition.has_panel(target_id):
		return _open_panel(tx, target_id)
	return _rejected(REASON_UNKNOWN_TARGET)


func _interact_in_panel(tx: Dictionary, panel: DeductionCaseworkCaseDefinition.PanelDefinition, target_id: StringName) -> Dictionary:
	var working: DeductionCaseProgress = tx["progress"]
	var slot := DeductionPanelWorkspace.find_slot(panel, target_id)
	if slot != null:
		var entity_id := _held_entity_id()
		if entity_id.is_empty():
			return _rejected(REASON_NO_FOCUS)
		var assigned := DeductionPanelWorkspace.assign(definition, working, panel.id, entity_id, slot.id, _solved_case_ids())
		if bool(assigned.get("accepted", false)):
			selected_entity_id = &""
			dragged_entity_id = &""
		return assigned
	if working.discovered_entity_ids.has(target_id):
		selected_entity_id = target_id
		dragged_entity_id = &""
		return _accepted()
	return _rejected(REASON_UNKNOWN_TARGET)


func _interact_resolved(tx: Dictionary, resolved: Dictionary) -> Dictionary:
	var working: DeductionCaseProgress = tx["progress"]
	var kind := StringName(String(resolved.get("kind", DeductionDiscovery.KIND_UNKNOWN)))
	var target_id := StringName(String(resolved.get("target_id", "")))
	if kind == DeductionDiscovery.KIND_FOCUS:
		focus_id = target_id
		return _accepted()
	if kind == DeductionDiscovery.KIND_CLOSEUP:
		return _open_closeup(working, target_id)
	if kind == DeductionDiscovery.KIND_TRANSITION:
		var transition := _find_transition(target_id)
		return _enter_transition(working, transition) if transition != null else _rejected(REASON_UNKNOWN_TARGET)
	if kind == DeductionDiscovery.KIND_ENTITY:
		return DeductionDiscovery.discover_entity(definition, working, target_id)
	if kind == DeductionDiscovery.KIND_MESSAGE:
		return _open_message(working, target_id)
	if kind == DeductionDiscovery.KIND_PANEL:
		return _open_panel(tx, target_id)
	return _rejected(REASON_UNKNOWN_TARGET)


func _open_message(working: DeductionCaseProgress, message_id: StringName) -> Dictionary:
	var result := DeductionMessageResolver.resolve(definition, working, message_id, _solved_case_ids())
	if not bool(result.get("changed", false)):
		return result
	var message := definition.get_message(message_id)
	if message != null and (not message.title.is_empty() or not message.body.is_empty()):
		return_focus_id = focus_id
		open_surface_id = message_id
	return result


func _open_closeup(working: DeductionCaseProgress, closeup_id: StringName) -> Dictionary:
	var closeup := definition.get_closeup(closeup_id)
	if closeup == null or closeup.parent_scene_id != working.current_scene_id:
		return _rejected(REASON_UNKNOWN_TARGET)
	return_focus_id = focus_id if not focus_id.is_empty() else closeup.return_focus_id
	open_surface_id = closeup.id
	focus_id = _first_focusable()
	return _surface_result()


func _open_panel(tx: Dictionary, panel_id: StringName) -> Dictionary:
	var working: DeductionCaseProgress = tx["progress"]
	if not DeductionPanelWorkspace.is_unlocked(definition, working, panel_id, _solved_case_ids()):
		return _rejected(DeductionPanelWorkspace.REASON_PANEL_LOCKED)
	var revealed := DeductionDiscovery.reveal_panel(definition, working, panel_id)
	if not bool(revealed.get("accepted", false)):
		return revealed
	return_focus_id = focus_id
	open_surface_id = panel_id
	focus_id = _first_focusable()
	return _surface_result()


func _enter_transition(working: DeductionCaseProgress, transition: DeductionCaseworkCaseDefinition.TransitionDefinition) -> Dictionary:
	if transition == null or not definition.has_scene(transition.destination_scene_id):
		return _rejected(REASON_UNKNOWN_TARGET)
	DeductionDiscovery.record_visit(working, transition.destination_scene_id)
	open_surface_id = &""
	return_focus_id = &""
	var ids := _focusable_ids(working.current_scene_id)
	focus_id = transition.focus_id if ids.has(transition.focus_id) else (ids[0] if not ids.is_empty() else &"")
	return {"accepted": true, "reason": REASON_OK, "changed": true, "scene_id": String(working.current_scene_id)}


func _assign(tx: Dictionary, payload: Dictionary) -> Dictionary:
	var working: DeductionCaseProgress = tx["progress"]
	var panel_id := _panel_id(payload)
	var entity_id := _read_id(payload.get("entity_id", ""))
	if entity_id.is_empty():
		entity_id = _held_entity_id()
	return DeductionPanelWorkspace.assign(
		definition, working, panel_id, entity_id, _read_id(payload.get("slot_id", "")), _solved_case_ids()
	)


func _remove_assignment(tx: Dictionary, payload: Dictionary) -> Dictionary:
	var working: DeductionCaseProgress = tx["progress"]
	return DeductionPanelWorkspace.remove_assignment(
		definition, working, _panel_id(payload), _read_id(payload.get("slot_id", ""))
	)


func _submit_panel(tx: Dictionary, payload: Dictionary) -> Dictionary:
	var working: DeductionCaseProgress = tx["progress"]
	var panel_id := _panel_id(payload)
	if not definition.has_panel(panel_id):
		return _rejected(DeductionPanelWorkspace.REASON_UNKNOWN_PANEL)
	var panel_result := DeductionSolutionEvaluator.evaluate_panel(definition, working, panel_id, _solved_case_ids())
	var case_result := DeductionSolutionEvaluator.evaluate_case(definition, working, _solved_case_ids())
	var solved := bool(case_result.get("solved", false))
	if not solved:
		var panel_status := DeductionSolutionEvaluator.json_name(StringName(String(panel_result.get("status", ""))))
		return {
			"accepted": false, "reason": REASON_PANEL_UNSOLVED, "changed": false,
			"feedback_id": panel_status, "panel_id": String(panel_id),
			"panel_status": panel_status,
			"pending_panel_ids": case_result.get("pending_panel_ids", [])
		}
	working.panel_status = case_result.get("panel_status", {})
	DeductionCaseProgression.mark_solved(working, StringName(String(case_result.get("solution_id", ""))))
	return {
		"accepted": true, "reason": REASON_OK, "changed": true, "panel_id": String(panel_id),
		"panel_status": DeductionSolutionEvaluator.json_name(StringName(String(panel_result.get("status", "")))),
		"solved_panel_ids": case_result.get("solved_panel_ids", []),
		"pending_panel_ids": case_result.get("pending_panel_ids", []),
		"solution_id": case_result.get("solution_id", ""),
		"case_solved": true
	}


func _use_hint(tx: Dictionary, payload: Dictionary) -> Dictionary:
	var working: DeductionCaseProgress = tx["progress"]
	var hint := definition.get_hint(_read_id(payload.get("hint_id", "")))
	if hint == null:
		return _rejected(&"unknown_hint")
	if not DeductionConditionEvaluator.evaluate(hint.prerequisite_condition, working, _solved_case_ids()):
		return _rejected(&"hint_prerequisite_unmet")
	var changed := false
	if hint.one_shot and working.unlocked_hint_ids.has(hint.id):
		changed = false
	elif not working.unlocked_hint_ids.has(hint.id):
		working.unlocked_hint_ids.append(hint.id)
		changed = true
	return {
		"accepted": true, "reason": REASON_OK, "changed": changed,
		"hint_id": String(hint.id), "title": hint.title, "body": hint.body
	}


func _review_confirm(tx: Dictionary, payload: Dictionary) -> Dictionary:
	return DeductionCaseProgression.apply_review(
		tx["progress"], definition, tx["state"], _read_id(payload.get("next_case_id", ""))
	)


func _reset_confirm(tx: Dictionary) -> Dictionary:
	if not reset_pending:
		return _rejected(REASON_RESET_NOT_PENDING)
	tx["progress"] = DeductionCaseProgression.initial_progress(definition)
	return {"accepted": true, "reason": REASON_OK, "changed": true, "clear_transient": true}


func _focus_move(payload: Dictionary) -> Dictionary:
	var direction := _read_id(payload.get("direction", ""))
	if not DIRECTIONS.has(direction):
		return _rejected(REASON_UNKNOWN_DIRECTION)
	var ids := focusable_ids()
	if ids.is_empty():
		return _rejected(REASON_NO_FOCUS)
	var step := -1 if BACKWARD_DIRECTIONS.has(direction) else 1
	var index := ids.find(focus_id)
	if index < 0:
		index = 0 if step > 0 else ids.size() - 1
	focus_id = ids[(index + step + ids.size()) % ids.size()]
	_emit()
	return _accepted()


func _cancel() -> Dictionary:
	if not open_surface_id.is_empty():
		open_surface_id = &""
		focus_id = return_focus_id if not return_focus_id.is_empty() else _safe_start_focus()
		return_focus_id = &""
	elif not selected_entity_id.is_empty() or not dragged_entity_id.is_empty():
		selected_entity_id = &""
		dragged_entity_id = &""
	feedback_reason = &""
	_emit()
	return _accepted()


func _request_reset() -> Dictionary:
	reset_pending = true
	_emit()
	return {"accepted": true, "reason": REASON_OK, "changed": false}


func _activate_case(case_id: StringName, state: DeductionCaseworkCaseState) -> bool:
	var next_definition: DeductionCaseworkCaseDefinition = catalog.get_definition(case_id)
	if next_definition == null:
		return false
	definition = next_definition
	progress = _stored_progress(state, next_definition)
	state.active_case_id = next_definition.id
	state.last_case_id = next_definition.id
	_clear_transient()
	focus_id = _safe_start_focus()
	return true


func _stored_progress(state: DeductionCaseworkCaseState, definition_value: DeductionCaseworkCaseDefinition) -> DeductionCaseProgress:
	var stored: Variant = state.case_progress_by_id.get(String(definition_value.id), null)
	var progress := DeductionCaseProgress.from_dict(stored)
	if progress == null:
		progress = DeductionCaseProgression.initial_progress(definition_value)
	state.case_progress_by_id[String(definition_value.id)] = progress.to_dict()
	return progress


func _store_progress() -> void:
	if case_state == null or progress == null:
		return
	case_state.case_progress_by_id[String(progress.case_id)] = progress.to_dict()


func _copy_state(source: DeductionCaseworkCaseState) -> DeductionCaseworkCaseState:
	var copy := DeductionCaseworkCaseState.from_dict(source.to_dict())
	return copy if copy != null else DeductionSaveAdapter.new_state()


func _surface_panel() -> DeductionCaseworkCaseDefinition.PanelDefinition:
	if definition == null or open_surface_id.is_empty():
		return null
	return definition.get_panel(open_surface_id)


func _surface_hotspots() -> Array:
	if definition == null or progress == null:
		return []
	return _hotspots_for(open_surface_id, progress.current_scene_id)


func _hotspots_for(surface_id: StringName, scene_id: StringName) -> Array:
	if definition == null:
		return []
	if not surface_id.is_empty() and definition.has_closeup(surface_id):
		return definition.get_closeup(surface_id).hotspots
	var scene := definition.get_scene(scene_id)
	return scene.hotspots if scene != null else []


func _find_transition(transition_id: StringName) -> DeductionCaseworkCaseDefinition.TransitionDefinition:
	var scene := definition.get_scene(progress.current_scene_id) if definition != null and progress != null else null
	if scene == null:
		return null
	for transition: DeductionCaseworkCaseDefinition.TransitionDefinition in scene.transitions:
		if transition.id == transition_id:
			return transition
	return null


func _panel_id(payload: Dictionary) -> StringName:
	var panel_id := _read_id(payload.get("panel_id", ""))
	if not panel_id.is_empty():
		return panel_id
	var panel := _surface_panel()
	return panel.id if panel != null else &""


func _held_entity_id() -> StringName:
	return dragged_entity_id if not dragged_entity_id.is_empty() else selected_entity_id


func _solved_case_ids() -> Array:
	return DeductionCaseProgression.solved_case_ids(case_state)


func _safe_start_focus() -> StringName:
	var scene := definition.get_scene(progress.current_scene_id) if definition != null and progress != null else null
	if scene != null and focusable_ids().has(scene.start_focus_id):
		return scene.start_focus_id
	return _first_focusable()


func _first_focusable() -> StringName:
	var ids := focusable_ids()
	return ids[0] if not ids.is_empty() else &""


func _panel_snapshot(solved_case_ids: Array) -> Dictionary:
	var result: Dictionary = {}
	if definition == null or progress == null:
		return result
	for panel: DeductionCaseworkCaseDefinition.PanelDefinition in definition.panels:
		var draft: Dictionary = DeductionPanelWorkspace.read_draft(progress, panel.id)
		var slots: Array = []
		for slot: DeductionCaseworkCaseDefinition.PanelSlotDefinition in panel.slots:
			slots.append({
				"id": String(slot.id),
				"segment_id": String(slot.segment_id),
				"entity_id": String(draft.get(String(slot.id), "")),
				"persistent": slot.persistent
			})
		result[String(panel.id)] = {
			"status": DeductionSolutionEvaluator.json_name(
				DeductionSolutionEvaluator.panel_status(definition, progress, panel.id, solved_case_ids)
			),
			"revealed": progress.revealed_panel_ids.has(panel.id),
			"unlocked": DeductionPanelWorkspace.is_unlocked(definition, progress, panel.id, solved_case_ids),
			"slots": slots
		}
	return result


func _review_snapshot() -> Dictionary:
	if definition == null or progress == null or definition.review == null:
		return {}
	return {
		"id": String(definition.review.id),
		"conclusion": definition.review.conclusion,
		"scene_path": definition.review.scene_path,
		"completed": progress.reviewed,
		"next_case_ids": DeductionContentValidator.strings_to_dict(definition.next_case_ids)
	}


func _surface_snapshot() -> Dictionary:
	if definition == null or open_surface_id.is_empty():
		return {}
	var message := definition.get_message(open_surface_id)
	return {
		"id": String(open_surface_id),
		"kind": "message" if message != null else "",
		"title": message.title if message != null else "",
		"body": message.body if message != null else ""
	}


func _surface_result() -> Dictionary:
	return {
		"accepted": true, "reason": REASON_OK, "changed": true,
		"surface_id": String(open_surface_id), "focus_id": String(focus_id)
	}


func _accepted() -> Dictionary:
	return {"accepted": true, "reason": REASON_OK, "changed": false}


func _rejected(reason: StringName) -> Dictionary:
	return {"accepted": false, "reason": reason, "changed": false}


func _clear_transient() -> void:
	open_surface_id = &""
	return_focus_id = &""
	focus_id = &""
	hover_id = &""
	selected_entity_id = &""
	dragged_entity_id = &""
	feedback_reason = &""
	reset_pending = false


func _emit() -> void:
	snapshot_changed.emit(snapshot())


func _ids_to_strings(values: Array[StringName]) -> Array:
	var result: Array = []
	for value: StringName in values:
		if not result.has(String(value)):
			result.append(String(value))
	return result


func _read_id(value: Variant) -> StringName:
	return StringName(String(value)) if DeductionContentValidator.is_stable_id(value) else &""
