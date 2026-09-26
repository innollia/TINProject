class_name TopDownActionRpgRecoveryController
extends RefCounted

const RECOVERY_KINDS: Array[String] = [
	"checkpoint", "respawn", "clone", "reincarnation", "loop", "immortality",
	"institutional_reentry",
]
const RETIRED_TOKENS: Array[String] = [
	"checkpoint_return", "clone_branch", "loop_rehearsal", "immortal_continuation",
]
const CROWN_ALIGNMENT_WRITE: String = "crown_alignment"
const CROWN_ALIGNMENT_FLAG: String = "world_crown_alignment_committed"
const SELF_LAYERS: Array[String] = [
	"body", "memory", "role", "belief", "institution", "desire", "social_recognition",
]
const STATE_TOKENS: Array[String] = [
	"region_id", "region_state", "axis_values", "clock_stages", "npc_states",
	"relationship_states", "prop_states", "conversation_progress", "document_reads",
	"flags", "effects_fired", "encounter_clear_flags", "route_flags", "inventory",
	"equipment_slots", "recoveries", "player_vitals", "concentration_fields",
	"body_load", "circulation", "crafts", "contracts", "glossary",
]
const DISCARD_TOKENS: Array[String] = [
	"encounter_progress", "current_phase", "linked_actor_state", "combat_transient",
	"scheduler_cursor", "pending_effect_queue", "presentation_transient",
]
const SECTION_FOR_TOKEN: Dictionary = {
	"region_id": "field",
	"region_state": "world",
	"axis_values": "world",
	"clock_stages": "world",
	"npc_states": "world",
	"relationship_states": "world",
	"prop_states": "world",
	"conversation_progress": "progression",
	"document_reads": "progression",
	"flags": "world",
	"effects_fired": "world",
	"encounter_clear_flags": "world",
	"route_flags": "world",
	"inventory": "progression",
	"equipment_slots": "progression",
	"recoveries": "recovery",
	"player_vitals": "player",
	"concentration_fields": "world",
	"body_load": "world",
	"circulation": "world",
	"crafts": "world",
	"contracts": "world",
	"glossary": "world",
}
const MAX_HISTORY: int = 64

var game_state: TopDownActionRpgGameState
var catalog: TopDownActionRpgContentLoader.Catalog
var pending_definition: Dictionary = {}


func setup(p_state: TopDownActionRpgGameState, p_catalog: TopDownActionRpgContentLoader.Catalog) -> bool:
	game_state = p_state
	catalog = p_catalog
	pending_definition = {}
	return p_state != null and p_catalog != null


static func is_recovery_kind(kind: String) -> bool:
	return RECOVERY_KINDS.has(kind)


static func layer_partition(definition: Dictionary) -> Dictionary:
	var restored: Array = definition.get("self_layers_restored", []) if definition.get("self_layers_restored", []) is Array else []
	var not_restored: Array = definition.get("self_layers_not_restored", []) if definition.get("self_layers_not_restored", []) is Array else []
	return {"restored": restored.duplicate(), "not_restored": not_restored.duplicate(), "complete": _layers_complete(restored, not_restored)}


static func _layers_complete(restored: Array, not_restored: Array) -> bool:
	if restored.size() + not_restored.size() != SELF_LAYERS.size():
		return false
	for layer: String in SELF_LAYERS:
		if restored.has(layer) and not_restored.has(layer):
			return false
		if not restored.has(layer) and not not_restored.has(layer):
			return false
	return true


func request_recovery(definition: Dictionary) -> String:
	if game_state == null or definition.is_empty():
		return "recovery_unavailable"
	var kind: String = String(definition.get("kind", ""))
	if RETIRED_TOKENS.has(kind):
		return "recovery_kind_token_mismatch"
	if kind == CROWN_ALIGNMENT_WRITE:
		return "recovery_kind_violation"
	if not is_recovery_kind(kind):
		return "recovery_kind_violation"
	if not _layers_complete(definition.get("self_layers_restored", []), definition.get("self_layers_not_restored", [])):
		return "recovery_layer_gap"
	game_state.recovery["pending_outcome_id"] = String(definition.get("id", ""))
	pending_definition = definition
	game_state.set_mode("recovery")
	return "requested"


func apply_recovery(definition: Dictionary = {}) -> Dictionary:
	var source: Dictionary = definition if not definition.is_empty() else pending_definition
	if game_state == null or source.is_empty():
		return {"result": "recovery_unavailable"}
	var kind: String = String(source.get("kind", ""))
	if not is_recovery_kind(kind):
		return {"result": "recovery_kind_violation", "kind": kind}
	var preserves: Array = source.get("preserves", []) if source.get("preserves", []) is Array else []
	var discards: Array = source.get("discards", []) if source.get("discards", []) is Array else []
	var snapshot: Dictionary = game_state.to_dict()
	var working: Dictionary = snapshot.duplicate(true)
	for token: String in discards:
		if token == "encounter_progress":
			working.get("combat", {})["active_encounter_id"] = ""
			working.get("combat", {})["pre_command_intent"] = []
			working.get("combat", {})["result"] = ""
	working.get("recovery", {})["pending_outcome_id"] = ""
	var respawn: Dictionary = source.get("respawn", {}) if source.get("respawn", {}) is Dictionary else {}
	var region_id: String = String(respawn.get("region_id", game_state.region_id()))
	working.get("field", {})["region_id"] = region_id
	working.get("field", {})["anchor_id"] = String(respawn.get("prop_id", region_id))
	working.get("field", {})["active_interaction_id"] = ""
	working.get("combat", {})["resume_boundary"] = "field"
	for prop_id: Variant in respawn.get("reset_prop_ids", []) if respawn.get("reset_prop_ids", []) is Array else []:
		_reset_prop(working, String(prop_id))
	var cost: Dictionary = source.get("cost", {}) if source.get("cost", {}) is Dictionary else {}
	var pressure_delta: int = maxi(0, int(cost.get("continuity_pressure_delta", 0)))
	var applied_effects: Array = []
	for axis: Variant in cost.get("axis_deltas", {}) if cost.get("axis_deltas", {}) is Dictionary else {}:
		var record: Dictionary = working.get("world", {}).get("axes", {}).get(String(axis), {})
		if record.is_empty():
			continue
		record["value"] = clampi(int(record.get("value", 0)) + int(cost["axis_deltas"][axis]), -3, 3)
		record["last_write_event_id"] = String(source.get("id", ""))
		working.get("world", {})["axes"][String(axis)] = record
	for resource: Variant in cost.get("resource_costs", {}) if cost.get("resource_costs", {}) is Dictionary else []:
		_spend_resource(working, String(resource), int(cost["resource_costs"][resource]))
	for effect_id: Variant in source.get("entry_effect_ids", []) if source.get("entry_effect_ids", []) is Array else []:
		applied_effects.append_array(_run_effect(working, String(effect_id)))
	for effect_id: Variant in cost.get("world_effect_ids", []) if cost.get("world_effect_ids", []) is Array else []:
		applied_effects.append_array(_run_effect(working, String(effect_id)))
	var history: Array = working.get("recovery", {}).get("history", []) if working.get("recovery", {}).get("history", []) is Array else []
	history.append({
		"recovery_event_id": String(source.get("id", "")),
		"kind": kind,
		"respawn_region_id": region_id,
		"respawn_encounter_id": String(respawn.get("encounter_id", "")),
		"continuity_pressure_delta": pressure_delta,
		"preserves": preserves.duplicate(),
		"discards": discards.duplicate(),
		"self_layers_restored": (source.get("self_layers_restored", []) as Array).duplicate(),
		"self_layers_not_restored": (source.get("self_layers_not_restored", []) as Array).duplicate(),
	})
	while history.size() > MAX_HISTORY:
		history.remove_at(0)
	working.get("recovery", {})["history"] = history
	var continuity: Dictionary = working.get("recovery", {}).get("continuity", {})
	if continuity.is_empty():
		continuity = {"head_id": TopDownActionRpgGameState.PLAYER_ROLE_ID, "continuity_pressure": TopDownActionRpgGameState.PLAYER_CONTINUITY, "recovery_count": 0}
	continuity["recovery_count"] = int(continuity.get("recovery_count", 0)) + 1
	continuity["last_kind"] = kind
	continuity["continuity_pressure"] = _continuity_token_for(kind, String(continuity.get("continuity_pressure", "single")))
	working.get("recovery", {})["continuity"] = continuity
	working.get("recovery", {})["active_checkpoint_id"] = String(source.get("id", "")) if kind == "checkpoint" else String(working.get("recovery", {}).get("active_checkpoint_id", ""))
	if not game_state.from_dict(working):
		game_state.from_dict(snapshot)
		return {"result": "recovery_rollback", "kind": kind}
	game_state.set_mode("field")
	pending_definition = {}
	return {
		"result": "recovered",
		"kind": kind,
		"respawn_region_id": region_id,
		"respawn_encounter_id": String(respawn.get("encounter_id", "")),
		"preserves": preserves.duplicate(),
		"discards": discards.duplicate(),
		"self_layers": layer_partition(source),
		"effects": applied_effects,
		"queued_encounter_id": TopDownActionRpgContentLoader.take_queued_encounter(game_state, "post_recovery"),
	}


func _continuity_token_for(kind: String, current: String) -> String:
	match kind:
		"clone", "reincarnation":
			return "branched"
		"loop":
			return "loop-bound"
		"immortality":
			return "crown-debt" if current == "crown-debt" else "loop-bound"
		"institutional_reentry":
			return "branched" if current == "single" else current
		_:
			return current


func _reset_prop(working: Dictionary, prop_id: String) -> void:
	var props: Dictionary = working.get("world", {}).get("props", {})
	var record: Dictionary = props.get(prop_id, {}) if props.get(prop_id, {}) is Dictionary else {}
	if record.is_empty():
		return
	record["state_id"] = String(record.get("initial_state_id", ""))
	props[prop_id] = record
	working.get("world", {})["props"] = props


func _spend_resource(working: Dictionary, resource: String, amount: int) -> void:
	if amount <= 0:
		return
	var resources: Dictionary = working.get("world", {}).get("resources", {})
	var record: Dictionary = resources.get(resource, {}) if resources.get(resource, {}) is Dictionary else {}
	record["amount"] = maxi(0, int(record.get("amount", 0)) - amount)
	resources[resource] = record
	working.get("world", {})["resources"] = resources


func _run_effect(working: Dictionary, effect_id: String) -> Array:
	if catalog == null:
		return []
	var effect: Dictionary = catalog.record(effect_id)
	if effect.is_empty():
		return []
	var applied: Array = []
	for operation: Variant in effect.get("operations", []) if effect.get("operations", []) is Array else []:
		if operation is Dictionary:
			applied.append({"effect_id": effect_id, "op": String(operation.get("op", ""))})
	var fired: Dictionary = working.get("world", {}).get("effects_fired", {})
	fired[effect_id] = true
	working.get("world", {})["effects_fired"] = fired
	return applied


func crown_alignment_committed() -> bool:
	if game_state == null:
		return false
	if not String(game_state.crown_record().get("alignment_event_id", "")).is_empty():
		return true
	if game_state.flag_is(CROWN_ALIGNMENT_FLAG):
		return true
	for entry: Variant in recovery_history():
		if entry is Dictionary and String(entry.get("kind", "")) == CROWN_ALIGNMENT_WRITE:
			return true
	return false


func apply_crown_alignment(precedence: String, operator_id: String, object_phase: int, event_id: String) -> Dictionary:
	if game_state == null:
		return {"result": "world_write_unavailable"}
	if is_recovery_kind(CROWN_ALIGNMENT_WRITE):
		return {"result": "recovery_kind_violation"}
	if crown_alignment_committed():
		return {"result": "world_write_rejected", "reason": "crown_alignment_is_not_a_recovery_type"}
	var clock_id: String = "clock_crown_alignment"
	if not game_state.write_crown_alignment(precedence, operator_id, object_phase, event_id):
		return {"result": "world_write_rejected"}
	game_state.set_clock_stage(game_state.region_id(), clock_id, TopDownActionRpgGameState.IRREVERSIBLE_STAGE, event_id)
	game_state.queue_delayed_write(event_id, clock_id, game_state.region_id(), TopDownActionRpgGameState.TERMINAL_STAGE)
	game_state.set_flag(CROWN_ALIGNMENT_FLAG, true)
	game_state.append_commit_log({
		"event_id": event_id,
		"kind": CROWN_ALIGNMENT_WRITE,
		"precedence": precedence,
		"operator_id": operator_id,
		"object_phase": object_phase,
	})
	game_state.recovery["pending_outcome_id"] = ""
	return {
		"result": "world_write_committed",
		"kind": CROWN_ALIGNMENT_WRITE,
		"precedence": precedence,
		"operator_id": operator_id,
		"object_phase": object_phase,
		"continuity_pressure": game_state.axis_value("continuity_pressure"),
		"crown_clock_stage": game_state.clock_stage(game_state.region_id(), clock_id),
	}


func recovery_definitions_by_kind() -> Dictionary:
	var result: Dictionary = {}
	if catalog == null:
		return result
	for record_id: String in catalog.ids_of_kind("recovery"):
		var record: Dictionary = catalog.record(record_id)
		var kind: String = String(record.get("kind", ""))
		if is_recovery_kind(kind):
			result[kind] = record
	return result


func recovery_history() -> Array:
	if game_state == null:
		return []
	return game_state.recovery.get("history", []) if game_state.recovery.get("history", []) is Array else []


func snapshot_for_checkpoint() -> Dictionary:
	if game_state == null:
		return {}
	return game_state.to_dict()


func restore_checkpoint(snapshot: Dictionary) -> bool:
	if game_state == null or snapshot.is_empty():
		return false
	return game_state.from_dict(snapshot)
