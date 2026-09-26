class_name DeductionDiscovery
extends RefCounted

const REASON_OK: StringName = &""
const REASON_UNKNOWN_HOTSPOT: StringName = &"unknown_hotspot"
const REASON_UNKNOWN_TARGET: StringName = &"unknown_target"
const REASON_ALREADY_DISCOVERED: StringName = &"already_discovered"
const REASON_ALREADY_REVEALED: StringName = &"already_revealed"

const KIND_FOCUS: StringName = &"focus"
const KIND_UNKNOWN: StringName = &"unknown"
const KIND_ENTITY: StringName = &"entity"
const KIND_MESSAGE: StringName = &"message"
const KIND_PANEL: StringName = &"panel"
const KIND_CLOSEUP: StringName = &"closeup"
const KIND_TRANSITION: StringName = &"transition"


static func classify(
	definition: DeductionCaseworkCaseDefinition,
	target_id: StringName,
	transitions: Array = []
) -> StringName:
	if definition == null or target_id.is_empty():
		return KIND_UNKNOWN
	if definition.has_closeup(target_id):
		return KIND_CLOSEUP
	if definition.has_panel(target_id):
		return KIND_PANEL
	if definition.has_message(target_id):
		return KIND_MESSAGE
	if definition.has_entity(target_id):
		return KIND_ENTITY
	for transition: DeductionCaseworkCaseDefinition.TransitionDefinition in transitions:
		if transition.id == target_id:
			return KIND_TRANSITION
	return KIND_UNKNOWN


static func resolve_hotspot(
	definition: DeductionCaseworkCaseDefinition,
	hotspots: Array,
	hotspot_id: StringName
) -> Dictionary:
	var hotspot: DeductionCaseworkCaseDefinition.HotspotDefinition = null
	for candidate: DeductionCaseworkCaseDefinition.HotspotDefinition in hotspots:
		if candidate.id == hotspot_id:
			hotspot = candidate
			break
	if hotspot == null:
		return {"accepted": false, "reason": REASON_UNKNOWN_HOTSPOT, "changed": false}
	if hotspot.focus_id.is_empty():
		return {
			"accepted": true, "reason": REASON_OK, "changed": false,
			"kind": KIND_FOCUS, "target_id": String(hotspot_id)
		}
	return {
		"accepted": true, "reason": REASON_OK, "changed": false,
		"kind": classify(definition, hotspot.focus_id, _scene_transitions(definition, hotspot.focus_id)),
		"target_id": String(hotspot.focus_id)
	}


static func discover_entity(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	entity_id: StringName
) -> Dictionary:
	if definition == null or progress == null or not definition.has_entity(entity_id):
		return {"accepted": false, "reason": REASON_UNKNOWN_TARGET, "changed": false}
	if progress.discovered_entity_ids.has(entity_id):
		return _result(entity_id, false, REASON_ALREADY_DISCOVERED)
	progress.discovered_entity_ids.append(entity_id)
	return _result(entity_id, true, REASON_OK)


static func reveal_panel(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	panel_id: StringName
) -> Dictionary:
	if definition == null or progress == null or not definition.has_panel(panel_id):
		return {"accepted": false, "reason": REASON_UNKNOWN_TARGET, "changed": false}
	if progress.revealed_panel_ids.has(panel_id):
		return {"accepted": true, "reason": REASON_ALREADY_REVEALED, "changed": false, "panel_id": String(panel_id)}
	progress.revealed_panel_ids.append(panel_id)
	return {"accepted": true, "reason": REASON_OK, "changed": true, "panel_id": String(panel_id)}


static func record_visit(progress: DeductionCaseProgress, scene_id: StringName) -> void:
	if progress == null or scene_id.is_empty():
		return
	progress.current_scene_id = scene_id
	if not progress.visited_scene_ids.has(scene_id):
		progress.visited_scene_ids.append(scene_id)


static func _scene_transitions(definition: DeductionCaseworkCaseDefinition, target_id: StringName) -> Array:
	for scene: DeductionCaseworkCaseDefinition.SceneDefinition in definition.scenes:
		for transition: DeductionCaseworkCaseDefinition.TransitionDefinition in scene.transitions:
			if transition.id == target_id:
				return scene.transitions
	return []


static func _result(entity_id: StringName, changed: bool, reason: StringName) -> Dictionary:
	return {
		"accepted": true, "reason": reason, "changed": changed, "entity_id": String(entity_id)
	}
