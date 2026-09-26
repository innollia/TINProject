class_name DeductionMessageResolver
extends RefCounted

const REASON_OK: StringName = &""
const REASON_UNKNOWN_MESSAGE: StringName = &"unknown_message"
const REASON_ALREADY_RESOLVED: StringName = &"already_resolved"
const REASON_PREREQUISITE_UNMET: StringName = &"prerequisite_unmet"
const REASON_INVALID_EFFECT: StringName = &"invalid_effect"

const EFFECT_DISCOVER_ENTITY: StringName = &"discover_entity"
const EFFECT_REVEAL_PANEL: StringName = &"reveal_panel"
const EFFECT_RESOLVE_MESSAGE: StringName = &"resolve_message"


static func resolve(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	message_id: StringName,
	solved_case_ids: Array = []
) -> Dictionary:
	var message: DeductionCaseworkCaseDefinition.MessageDefinition = null
	if definition != null:
		message = definition.get_message(message_id)
	if message == null or progress == null:
		return _rejected(REASON_UNKNOWN_MESSAGE)
	if progress.resolved_message_ids.has(message_id):
		return _resolved(message, false, REASON_ALREADY_RESOLVED)
	if not DeductionConditionEvaluator.evaluate(message.prerequisite_condition, progress, solved_case_ids):
		return _rejected(REASON_PREREQUISITE_UNMET)
	for effect: DeductionCaseworkCaseDefinition.EffectDefinition in message.effects:
		if not _apply_effect(definition, progress, effect, solved_case_ids):
			return _rejected(REASON_INVALID_EFFECT)
	progress.resolved_message_ids.append(message_id)
	return _resolved(message, true, REASON_OK)


static func _apply_effect(
	definition: DeductionCaseworkCaseDefinition,
	progress: DeductionCaseProgress,
	effect: DeductionCaseworkCaseDefinition.EffectDefinition,
	solved_case_ids: Array
) -> bool:
	match StringName(effect.type):
		EFFECT_DISCOVER_ENTITY:
			var entity_ids: Array[StringName] = _read_ids(effect.params, "entity_id", "entity_ids")
			if entity_ids.is_empty():
				return false
			for entity_id: StringName in entity_ids:
				if not DeductionDiscovery.discover_entity(definition, progress, entity_id).get("accepted", false):
					return false
			return true
		EFFECT_REVEAL_PANEL:
			var panel_ids: Array[StringName] = _read_ids(effect.params, "panel_id", "panel_ids")
			if panel_ids.is_empty():
				return false
			for panel_id: StringName in panel_ids:
				if not DeductionDiscovery.reveal_panel(definition, progress, panel_id).get("accepted", false):
					return false
			return true
		EFFECT_RESOLVE_MESSAGE:
			var message_ids: Array[StringName] = _read_ids(effect.params, "message_id", "message_ids")
			if message_ids.is_empty():
				return false
			for message_id: StringName in message_ids:
				if not definition.has_message(message_id):
					return false
				if not progress.resolved_message_ids.has(message_id):
					progress.resolved_message_ids.append(message_id)
			return true
		_:
			return false


static func _read_ids(params: Dictionary, single_key: String, plural_key: String) -> Array[StringName]:
	var result: Array[StringName] = []
	var single: Variant = params.get(single_key, null)
	if DeductionContentValidator.is_stable_id(single):
		result.append(StringName(String(single)))
	var plural: Variant = params.get(plural_key, null)
	if plural is Array:
		for item: Variant in plural:
			if DeductionContentValidator.is_stable_id(item) and not result.has(StringName(String(item))):
				result.append(StringName(String(item)))
	return result


static func _resolved(
	message: DeductionCaseworkCaseDefinition.MessageDefinition,
	changed: bool,
	reason: StringName
) -> Dictionary:
	return {
		"accepted": true, "reason": reason, "changed": changed,
		"message_id": String(message.id), "title": message.title, "body": message.body
	}


static func _rejected(reason: StringName) -> Dictionary:
	return {"accepted": false, "reason": reason, "changed": false}
