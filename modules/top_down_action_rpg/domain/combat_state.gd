class_name TopDownActionRpgCombatState
extends RefCounted

const SCHEMA_VERSION: int = 1
const MAX_JSON_DEPTH: int = 64
const TURN_COST_MIN: int = 0
const TURN_COST_MAX: int = 5
const MIN_SCHEDULE_RATE: int = 1
const BASE_SCHEDULE_TICKS: int = 6
const MAX_SCHEDULE_TICKS: int = 9999
const GUARD_WINDOW_BUDGET: int = 2
const BROKEN_SKIP_BUDGET: int = 2
const MAX_ACTOR_COUNT: int = 16
const MAX_QUEUE_LENGTH: int = 32

const TARGET_MODES: Array[String] = [
	"SELF", "ONE_ENEMY", "ONE_ALLY", "ALL_ENEMIES", "ALL_ALLIES", "RANDOM_ENEMY",
]
const TARGET_ELIGIBILITY: Array[String] = ["living", "alive_or_fallen", "fallen_ally", "any"]
const TARGET_ROLES: Array[String] = ["record", "route", "resource_node"]
const TARGET_PRIORITY_ROLES: Array[String] = [
	"true_actor", "linked_actor", "support", "decoy", "aggro",
]
const ACTOR_SIDES: Array[String] = ["player_side", "enemy_side"]
const STANCE_STATES: Array[String] = ["normal", "guard", "dodge", "broken", "guard_broken"]
const CHARGE_STAGES: Array[String] = [
	"telegraph", "reaction", "strike", "recovery", "cancelled", "completed",
]
const BREAK_POLICIES: Array[String] = ["enabled", "resistant", "immune"]
const LIFECYCLES: Array[String] = ["instant", "charge", "committed"]
const SUBMODES: Array[String] = [
	"command_category", "command_action", "target_select", "reaction_select",
	"resolution_feedback", "combat_result",
]
const COMBAT_RESULTS: Array[String] = ["running", "victory", "defeat", "escape", "failure"]
const STAT_KEYS: Array[String] = [
	"agility", "max_hp", "max_mp", "hit", "evasion", "critical",
	"critical_avoidance", "guard_efficiency", "break_damage",
]
const RESOURCE_KEYS: Array[String] = ["hp", "mp", "equipment_charge"]
const DELIVERIES: Array[String] = ["physical", "magical", "true"]
const DAMAGE_SHAPES: Array[String] = ["fixed", "percent_max_hp", "percent_current_hp", "guaranteed"]
const COUNTERS: Array[String] = [
	"guard", "dodge", "break", "resource_lock", "status_counter", "scripted_counter",
	"escape", "raw_survive", "noncombat", "phase_advance",
]

const RESULT_CODES: Array[String] = [
	"resolved",
	"queued",
	"mitigated",
	"dodged",
	"missed_hit",
	"skipped_dead_actor",
	"skipped_target_invalidated",
	"skipped_no_valid_target",
	"skipped_action_unavailable",
	"skipped_phase_invalidated",
	"skipped_already_broken",
	"skipped_break_immune",
	"skipped_insufficient_resource",
	"skipped_cooldown",
	"skipped_blocked_by_status",
	"no_status_removed",
]


class ActorState:
	extends RefCounted

	var actor_id: StringName = &""
	var display_name: String = ""
	var side: String = "player_side"
	var encounter_slot: int = 0
	var tie_break_rank: int = 1
	var target_priority: int = 1
	var target_role: String = "true_actor"

	var hp: int = 1
	var max_hp: int = 1
	var mp: int = 0
	var max_mp: int = 0
	var equipment_charge: int = 0
	var max_equipment_charge: int = 0

	var base_stats: Dictionary = {}
	var equipment_ids: Array = []
	var status_instances: Array = []

	var stance_state: String = "normal"
	var guard_window_budget: int = 0
	var guard_broken_windows: int = 0
	var broken_skip_budget: int = 0
	var break_policy: String = "enabled"
	var break_resistance: int = 0

	var charge_state = null
	var ai_policy_id: String = ""
	var window_serial: int = 0
	var next_window_tick: int = 0
	var action_slot_snapshot: int = 1
	var scheduled_temp_stats: Dictionary = {}
	var action_cooldowns: Dictionary = {}

	var alive: bool = true
	var fled: bool = false
	var removed: bool = false
	var can_act: bool = true
	var control_tags: Array = []


	func is_valid() -> bool:
		return not actor_id.is_empty() and ACTOR_SIDES.has(side)


	func is_actionable() -> bool:
		return is_valid() and alive and not fled and not removed and can_act


	func has_control_tag(tag: String) -> bool:
		return control_tags.has(tag)


	func hp_ratio_at() -> int:
		return 0 if max_hp <= 0 else clampi(hp * 100 / max_hp, 0, 100)


	func resource_amount(key: String) -> int:
		match key:
			"hp":
				return hp
			"mp":
				return mp
			"equipment_charge":
				return equipment_charge
		return 0


	func resource_cap(key: String) -> int:
		match key:
			"hp":
				return max_hp
			"mp":
				return max_mp
			"equipment_charge":
				return max_equipment_charge
		return 0


	func add_status_instance(instance: Object) -> void:
		status_instances.append(instance)


	func find_status(definition_id: StringName) -> Object:
		for instance: TopDownActionRpgCombatState.StatusInstance in status_instances:
			if instance.definition_id == definition_id and instance.active:
				return instance
		return null

	func status_count(definition_id: StringName) -> int:
		var total: int = 0
		for instance: TopDownActionRpgCombatState.StatusInstance in status_instances:
			if instance.definition_id == definition_id and instance.active:
				total += instance.stacks
		return total


	func to_dict() -> Dictionary:
		var statuses: Array = []
		for instance: TopDownActionRpgCombatState.StatusInstance in status_instances:
			statuses.append(instance.to_dict())
		return {
			"actor_id": String(actor_id),
			"display_name": display_name,
			"side": side,
			"encounter_slot": encounter_slot,
			"tie_break_rank": tie_break_rank,
			"target_priority": target_priority,
			"target_role": target_role,
			"hp": hp,
			"max_hp": max_hp,
			"mp": mp,
			"max_mp": max_mp,
			"equipment_charge": equipment_charge,
			"max_equipment_charge": max_equipment_charge,
			"base_stats": base_stats.duplicate(true),
			"equipment_ids": equipment_ids.duplicate(),
			"status_instances": statuses,
			"stance_state": stance_state,
			"guard_window_budget": guard_window_budget,
			"guard_broken_windows": guard_broken_windows,
			"broken_skip_budget": broken_skip_budget,
			"break_policy": break_policy,
			"break_resistance": break_resistance,
			"charge_state": charge_state.to_dict() if charge_state != null else null,
			"ai_policy_id": ai_policy_id,
			"window_serial": window_serial,
			"next_window_tick": next_window_tick,
			"action_slot_snapshot": action_slot_snapshot,
			"action_cooldowns": action_cooldowns.duplicate(),
			"alive": alive,
			"fled": fled,
			"removed": removed,
			"can_act": can_act,
			"control_tags": control_tags.duplicate(),
		}

	static func from_dict(data: Variant) -> ActorState:
		if not data is Dictionary or not TopDownActionRpgCombatState.is_stable_id(String(data.get("actor_id", ""))):
			return null
		var actor := ActorState.new()
		actor.actor_id = StringName(data["actor_id"])
		actor.display_name = String(data.get("display_name", ""))
		actor.side = String(data.get("side", "player_side"))
		actor.encounter_slot = int(data.get("encounter_slot", 0))
		actor.tie_break_rank = int(data.get("tie_break_rank", 1))
		actor.target_priority = int(data.get("target_priority", 1))
		actor.target_role = String(data.get("target_role", "true_actor"))
		actor.hp = int(data.get("hp", 1))
		actor.max_hp = maxi(1, int(data.get("max_hp", 1)))
		actor.mp = int(data.get("mp", 0))
		actor.max_mp = int(data.get("max_mp", 0))
		actor.equipment_charge = int(data.get("equipment_charge", 0))
		actor.max_equipment_charge = int(data.get("max_equipment_charge", 0))
		actor.base_stats = data.get("base_stats", {}) if data.get("base_stats", {}) is Dictionary else {}
		actor.equipment_ids = data.get("equipment_ids", []) if data.get("equipment_ids", []) is Array else []
		actor.stance_state = String(data.get("stance_state", "normal"))
		actor.guard_window_budget = int(data.get("guard_window_budget", 0))
		actor.guard_broken_windows = int(data.get("guard_broken_windows", 0))
		actor.broken_skip_budget = int(data.get("broken_skip_budget", 0))
		actor.break_policy = String(data.get("break_policy", "enabled"))
		actor.break_resistance = int(data.get("break_resistance", 0))
		actor.charge_state = ChargeState.from_dict(data.get("charge_state")) if data.get("charge_state") != null else null
		actor.ai_policy_id = String(data.get("ai_policy_id", ""))
		actor.window_serial = int(data.get("window_serial", 0))
		actor.next_window_tick = int(data.get("next_window_tick", 0))
		actor.action_slot_snapshot = maxi(1, int(data.get("action_slot_snapshot", 1)))
		actor.action_cooldowns = data.get("action_cooldowns", {}) if data.get("action_cooldowns", {}) is Dictionary else {}
		actor.alive = bool(data.get("alive", true))
		actor.fled = bool(data.get("fled", false))
		actor.removed = bool(data.get("removed", false))
		actor.can_act = bool(data.get("can_act", true))
		actor.control_tags = data.get("control_tags", []) if data.get("control_tags", []) is Array else []
		var statuses: Array = data.get("status_instances", []) if data.get("status_instances", []) is Array else []
		for entry: Variant in statuses:
			var instance := StatusInstance.from_dict(entry)
			if instance != null:
				actor.status_instances.append(instance)
		if not actor.side_is_valid() or not STANCE_STATES.has(actor.stance_state):
			return null
		return actor

	func side_is_valid() -> bool:
		return ACTOR_SIDES.has(side)


class StatusInstance:
	extends RefCounted

	var instance_id: String = ""
	var definition_id: StringName = &""
	var source_actor_id: StringName = &""
	var stacks: int = 1
	var remaining_windows: int = 0
	var payload: Dictionary = {}
	var application_serial: int = 0
	var active: bool = true

	func to_dict() -> Dictionary:
		return {
			"instance_id": instance_id,
			"definition_id": String(definition_id),
			"source_actor_id": String(source_actor_id),
			"stacks": stacks,
			"remaining_windows": remaining_windows,
			"payload": payload.duplicate(true),
			"application_serial": application_serial,
			"active": active,
		}

	static func from_dict(data: Variant) -> StatusInstance:
		if not data is Dictionary or not TopDownActionRpgCombatState.is_stable_id(String(data.get("definition_id", ""))):
			return null
		var instance := StatusInstance.new()
		instance.instance_id = String(data.get("instance_id", ""))
		instance.definition_id = StringName(data["definition_id"])
		instance.source_actor_id = StringName(String(data.get("source_actor_id", "")))
		instance.stacks = maxi(1, int(data.get("stacks", 1)))
		instance.remaining_windows = maxi(0, int(data.get("remaining_windows", 0)))
		instance.payload = data.get("payload", {}) if data.get("payload", {}) is Dictionary else {}
		instance.application_serial = int(data.get("application_serial", 0))
		instance.active = bool(data.get("active", true))
		return instance


class ChargeState:
	extends RefCounted

	var owner_actor_id: StringName = &""
	var charge_action_id: StringName = &""
	var stage: String = "telegraph"
	var stage_ordinal: int = 0
	var target_actor_id: StringName = &""
	var window_budget: int = 0
	var valid_reaction_ids: Array = []
	var forbidden_response_ids: Array = []
	var break_policy: String = "enabled"
	var control_policy: String = "default_control"
	var strike_action_id: StringName = &""
	var recovery_action_id: StringName = &""
	var presentation_serial: int = 0

	func to_dict() -> Dictionary:
		return {
			"owner_actor_id": String(owner_actor_id),
			"charge_action_id": String(charge_action_id),
			"stage": stage,
			"stage_ordinal": stage_ordinal,
			"target_actor_id": String(target_actor_id),
			"window_budget": window_budget,
			"valid_reaction_ids": valid_reaction_ids.duplicate(),
			"forbidden_response_ids": forbidden_response_ids.duplicate(),
			"break_policy": break_policy,
			"control_policy": control_policy,
			"strike_action_id": String(strike_action_id),
			"recovery_action_id": String(recovery_action_id),
			"presentation_serial": presentation_serial,
		}

	static func from_dict(data: Variant) -> ChargeState:
		if not data is Dictionary:
			return null
		var stage: String = String(data.get("stage", "telegraph"))
		if not CHARGE_STAGES.has(stage):
			return null
		var charge := ChargeState.new()
		charge.owner_actor_id = StringName(String(data.get("owner_actor_id", "")))
		charge.charge_action_id = StringName(String(data.get("charge_action_id", "")))
		charge.stage = stage
		charge.stage_ordinal = maxi(0, int(data.get("stage_ordinal", 0)))
		charge.target_actor_id = StringName(String(data.get("target_actor_id", "")))
		charge.window_budget = maxi(0, int(data.get("window_budget", 0)))
		charge.valid_reaction_ids = data.get("valid_reaction_ids", []) if data.get("valid_reaction_ids", []) is Array else []
		charge.forbidden_response_ids = data.get("forbidden_response_ids", []) if data.get("forbidden_response_ids", []) is Array else []
		charge.break_policy = String(data.get("break_policy", "enabled"))
		charge.control_policy = String(data.get("control_policy", "default_control"))
		charge.strike_action_id = StringName(String(data.get("strike_action_id", "")))
		charge.recovery_action_id = StringName(String(data.get("recovery_action_id", "")))
		charge.presentation_serial = int(data.get("presentation_serial", 0))
		return charge

	func is_active() -> bool:
		return stage != "cancelled" and stage != "completed"


class QueuedIntent:
	extends RefCounted

	var intent_id: String = ""
	var actor_id: StringName = &""
	var action_id: StringName = &""
	var action_version: int = 1
	var target_mode: String = "SELF"
	var target_actor_id: StringName = &""
	var locked_target_ids: Array = []
	var turn_cost: int = 1
	var command_index: int = 0
	var ready_tick: int = 0
	var tie_break_rank: int = 1
	var reserved_resources: Dictionary = {}
	var category: String = "attack"
	var lifecycle: String = "instant"
	var defense_mode: String = "none"
	var no_turn: bool = false

	func to_dict() -> Dictionary:
		return {
			"intent_id": intent_id,
			"actor_id": String(actor_id),
			"action_id": String(action_id),
			"action_version": action_version,
			"target_mode": target_mode,
			"target_actor_id": String(target_actor_id),
			"locked_target_ids": locked_target_ids.duplicate(),
			"turn_cost": turn_cost,
			"command_index": command_index,
			"ready_tick": ready_tick,
			"tie_break_rank": tie_break_rank,
			"reserved_resources": reserved_resources.duplicate(true),
			"category": category,
			"lifecycle": lifecycle,
			"defense_mode": defense_mode,
			"no_turn": no_turn,
		}

	static func from_dict(data: Variant) -> QueuedIntent:
		if not data is Dictionary or not TARGET_MODES.has(String(data.get("target_mode", ""))):
			return null
		var intent := QueuedIntent.new()
		intent.intent_id = String(data.get("intent_id", ""))
		intent.actor_id = StringName(String(data.get("actor_id", "")))
		intent.action_id = StringName(String(data.get("action_id", "")))
		intent.action_version = int(data.get("action_version", 1))
		intent.target_mode = String(data["target_mode"])
		intent.target_actor_id = StringName(String(data.get("target_actor_id", "")))
		intent.locked_target_ids = data.get("locked_target_ids", []) if data.get("locked_target_ids", []) is Array else []
		intent.turn_cost = int(data.get("turn_cost", 1))
		intent.command_index = int(data.get("command_index", 0))
		intent.ready_tick = int(data.get("ready_tick", 0))
		intent.tie_break_rank = int(data.get("tie_break_rank", 1))
		intent.reserved_resources = data.get("reserved_resources", {}) if data.get("reserved_resources", {}) is Dictionary else {}
		intent.category = String(data.get("category", "attack"))
		intent.lifecycle = String(data.get("lifecycle", "instant"))
		intent.defense_mode = String(data.get("defense_mode", "none"))
		intent.no_turn = bool(data.get("no_turn", false))
		return intent


class ResolutionOutcome:
	extends RefCounted

	var outcome_id: String = ""
	var resolution_serial: int = 0
	var intent_id: String = ""
	var actor_id: StringName = &""
	var action_id: String = ""
	var result_code: String = "resolved"
	var target_ids: Array = []
	var damage_by_actor: Dictionary = {}
	var status_applied: Array = []
	var status_removed: Array = []
	var stance_changes: Dictionary = {}
	var break_applied: bool = false
	var guard_broken: bool = false
	var dodged: bool = false
	var lethal_actor_ids: Array = []
	var consumed_resources: Dictionary = {}
	var charge_transition: String = ""
	var presentation_event_ids: Array = []
	var world_effect_ids: Array = []

	func to_dict() -> Dictionary:
		return {
			"outcome_id": outcome_id,
			"resolution_serial": resolution_serial,
			"intent_id": intent_id,
			"actor_id": String(actor_id),
			"action_id": action_id,
			"result_code": result_code,
			"target_ids": target_ids.duplicate(),
			"damage_by_actor": damage_by_actor.duplicate(true),
			"status_applied": status_applied.duplicate(),
			"status_removed": status_removed.duplicate(),
			"stance_changes": stance_changes.duplicate(),
			"break_applied": break_applied,
			"guard_broken": guard_broken,
			"dodged": dodged,
			"lethal_actor_ids": lethal_actor_ids.duplicate(),
			"consumed_resources": consumed_resources.duplicate(true),
			"charge_transition": charge_transition,
			"presentation_event_ids": presentation_event_ids.duplicate(),
			"world_effect_ids": world_effect_ids.duplicate(),
		}


var schema_version: int = SCHEMA_VERSION
var encounter_id: StringName = &""
var encounter_attempt_serial: int = 0
var submode: String = "command_category"
var result: String = "running"
var actors: Array = []
var queue: Array = []
var encounter_target_roles: Array = []
var scheduler_tick: int = 0
var cycle_index: int = 0
var rng_state: int = 0x9E3779B9
var resolution_serial: int = 0
var presentation_queue: Array = []
var pending_reactions: Array = []


static func is_stable_id(value: Variant) -> bool:
	if not value is String:
		return false
	var text: String = value
	if text.length() < 3 or text.length() > 64:
		return false
	var first: int = text.unicode_at(0)
	if first < 97 or first > 122:
		return false
	for index: int in range(1, text.length()):
		var codepoint: int = text.unicode_at(index)
		if not ((codepoint >= 97 and codepoint <= 122) \
			or (codepoint >= 48 and codepoint <= 57) or codepoint == 95):
			return false
	return true


static func create_encounter(encounter: String, attempt_serial: int, seed_value: int) -> TopDownActionRpgCombatState:
	var state := TopDownActionRpgCombatState.new()
	state.encounter_id = StringName(encounter)
	state.encounter_attempt_serial = attempt_serial
	state.rng_state = seed_value if seed_value != 0 else 0x9E3779B9
	state.submode = "command_category"
	state.result = "running"
	return state


func to_dict() -> Dictionary:
	var actor_payloads: Array = []
	for actor: TopDownActionRpgCombatState.ActorState in actors:
		actor_payloads.append(actor.to_dict())
	var intent_payloads: Array = []
	for intent: TopDownActionRpgCombatState.QueuedIntent in queue:
		intent_payloads.append(intent.to_dict())
	return {
		"schema_version": SCHEMA_VERSION,
		"encounter_id": String(encounter_id),
		"encounter_attempt_serial": encounter_attempt_serial,
		"submode": submode,
		"result": result,
		"actors": actor_payloads,
		"queue": intent_payloads,
		"encounter_target_roles": encounter_target_roles.duplicate(true),
		"scheduler_tick": scheduler_tick,
		"cycle_index": cycle_index,
		"rng_state": rng_state,
		"resolution_serial": resolution_serial,
		"presentation_queue": presentation_queue.duplicate(),
		"pending_reactions": pending_reactions.duplicate(true),
	}


func from_dict(data: Variant) -> bool:
	if not data is Dictionary:
		return false
	if not TopDownActionRpgCombatState.is_stable_id(String(data.get("encounter_id", ""))):
		return false
	if not SUBMODES.has(String(data.get("submode", ""))):
		return false
	if not COMBAT_RESULTS.has(String(data.get("result", ""))):
		return false
	var restored: Array = []
	var actor_payloads: Variant = data.get("actors", [])
	if not actor_payloads is Array or actor_payloads.size() > MAX_ACTOR_COUNT:
		return false
	for entry: Variant in actor_payloads:
		var actor := ActorState.from_dict(entry)
		if actor == null:
			return false
		restored.append(actor)
	var restored_queue: Array = []
	var intent_payloads: Variant = data.get("queue", [])
	if not intent_payloads is Array or intent_payloads.size() > MAX_QUEUE_LENGTH:
		return false
	for entry: Variant in intent_payloads:
		var intent := QueuedIntent.from_dict(entry)
		if intent == null:
			return false
		restored_queue.append(intent)
	encounter_id = StringName(data["encounter_id"])
	encounter_attempt_serial = int(data.get("encounter_attempt_serial", 0))
	submode = String(data["submode"])
	result = String(data["result"])
	actors = restored
	queue = restored_queue
	encounter_target_roles = data.get("encounter_target_roles", []) if data.get("encounter_target_roles", []) is Array else []
	scheduler_tick = int(data.get("scheduler_tick", 0))
	cycle_index = int(data.get("cycle_index", 0))
	var seed_value: int = int(data.get("rng_state", 0x9E3779B9))
	rng_state = seed_value if seed_value != 0 else 0x9E3779B9
	resolution_serial = int(data.get("resolution_serial", 0))
	presentation_queue = data.get("presentation_queue", []) if data.get("presentation_queue", []) is Array else []
	pending_reactions = data.get("pending_reactions", []) if data.get("pending_reactions", []) is Array else []
	return true


func add_actor(actor: ActorState) -> bool:
	if actor == null or not actor.is_valid() or actors.size() >= MAX_ACTOR_COUNT:
		return false
	if find_actor(actor.actor_id) != null:
		return false
	actor.encounter_slot = actors.size()
	actor.action_slot_snapshot = effective_action_slots(actor)
	if actor.next_window_tick < scheduler_tick:
		actor.next_window_tick = scheduler_tick
	actors.append(actor)
	actors.sort_custom(func(a: TopDownActionRpgCombatState.ActorState, b: TopDownActionRpgCombatState.ActorState) -> bool:
		return a.encounter_slot < b.encounter_slot
	)
	return true


func find_actor(actor_id: StringName) -> ActorState:
	for actor: TopDownActionRpgCombatState.ActorState in actors:
		if actor.actor_id == actor_id:
			return actor
	return null


func actors_on_side(side: String) -> Array:
	var result: Array = []
	for actor: TopDownActionRpgCombatState.ActorState in actors:
		if actor.side == side:
			result.append(actor)
	return result


func living_actors_on_side(side: String) -> Array:
	var result: Array = []
	for actor: TopDownActionRpgCombatState.ActorState in actors_on_side(side):
		if actor.alive and not actor.fled and not actor.removed:
			result.append(actor)
	return result


func opposing_side(side: String) -> String:
	return "enemy_side" if side == "player_side" else "player_side"


func valid_targets_for(actor: ActorState, target_mode: String, eligibility: String) -> Array:
	var result: Array = []
	match target_mode:
		"SELF":
			if actor != null:
				result.append(actor.actor_id)
		"ONE_ENEMY", "RANDOM_ENEMY":
			for candidate: TopDownActionRpgCombatState.ActorState in living_actors_on_side(opposing_side(actor.side)):
				if _is_eligible(candidate, eligibility):
					result.append(candidate.actor_id)
		"ONE_ALLY":
			for candidate: TopDownActionRpgCombatState.ActorState in actors_on_side(actor.side):
				if _is_eligible(candidate, eligibility):
					result.append(candidate.actor_id)
		"ALL_ENEMIES":
			for candidate: TopDownActionRpgCombatState.ActorState in living_actors_on_side(opposing_side(actor.side)):
				if _is_eligible(candidate, eligibility):
					result.append(candidate.actor_id)
		"ALL_ALLIES":
			for candidate: TopDownActionRpgCombatState.ActorState in living_actors_on_side(actor.side):
				if _is_eligible(candidate, eligibility):
					result.append(candidate.actor_id)
	return result


func _is_eligible(actor: ActorState, eligibility: String) -> bool:
	match eligibility:
		"living":
			return actor.alive and not actor.fled and not actor.removed
		"alive_or_fallen":
			return not actor.fled and not actor.removed
		"fallen_ally":
			return actor.side == "player_side"
		"any":
			return not actor.removed
	return false


func target_focus_sequence(actor: ActorState, target_mode: String, eligibility: String) -> Array:
	var sequence: Array = []
	for candidate: TopDownActionRpgCombatState.ActorState in actors:
		if not _is_eligible(candidate, eligibility):
			continue
		if target_mode in ["ONE_ENEMY", "RANDOM_ENEMY"] and candidate.side == actor.side:
			continue
		if target_mode == "ONE_ALLY" and candidate.side != actor.side:
			continue
		sequence.append(candidate.actor_id)
	sequence.sort_custom(func(a: StringName, b: StringName) -> bool:
		return _slot_of(self, a) < _slot_of(self, b)
	)
	return sequence


static func _slot_of(state: TopDownActionRpgCombatState, actor_id: StringName) -> int:
	for actor: TopDownActionRpgCombatState.ActorState in state.actors:
		if actor.actor_id == actor_id:
			return actor.encounter_slot
	return 9999


func encounter_role_surface(role: String) -> Array:
	var result: Array = []
	if not TARGET_ROLES.has(role):
		return result
	for entry: Variant in encounter_target_roles:
		if entry is Dictionary and String(entry.get("role", "")) == role:
			result.append(entry)
	return result


static func effective_stat(actor: ActorState, key: String, equipment_stats: Dictionary, temp_stats: Dictionary) -> int:
	if actor == null or not STAT_KEYS.has(key):
		return 0
	var total: int = int(actor.base_stats.get(key, 0))
	total += int(equipment_stats.get(key, 0))
	total += int(temp_stats.get(key, 0))
	for instance: TopDownActionRpgCombatState.StatusInstance in actor.status_instances:
		if not instance.active:
			continue
		total += int(instance.payload.get("stat_deltas", {}).get(key, 0))
	return total


static func effective_agility(actor: ActorState, equipment_stats: Dictionary, temp_stats: Dictionary) -> int:
	return maxi(MIN_SCHEDULE_RATE, effective_stat(actor, "agility", equipment_stats, temp_stats))


static func effective_action_slots(actor: ActorState) -> int:
	if actor == null:
		return 1
	return clampi(actor.action_slot_snapshot, 1, 3)


func damage_roll() -> int:
	rng_state = (rng_state ^ (rng_state << 13)) & 0xFFFFFFFF
	rng_state = (rng_state ^ (rng_state >> 17)) & 0xFFFFFFFF
	rng_state = (rng_state ^ (rng_state << 5)) & 0xFFFFFFFF
	return rng_state


func roll_permille(bonus: int = 0) -> int:
	var value: int = (damage_roll() % 1000) + clampi(bonus, -1000, 1000)
	return clampi(value, 0, 1000)


func next_resolution_serial() -> int:
	resolution_serial += 1
	return resolution_serial


func push_presentation(event_id: String) -> void:
	if not event_id.is_empty():
		presentation_queue.append(event_id)


func drain_presentation() -> Array:
	var drained: Array = presentation_queue.duplicate()
	presentation_queue.clear()
	return drained
