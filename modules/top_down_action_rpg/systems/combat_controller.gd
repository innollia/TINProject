class_name TopDownActionRpgCombatController
extends RefCounted

const NO_TURN: int = 0
const BASE_DODGE: int = 200
const DODGE_WEIGHT: int = 12
const AGILITY_WEIGHT: int = 8
const REFERENCE_AGILITY: int = 10
const MIN_DODGE: int = 0
const MAX_DODGE: int = 950
const MAX_DAMAGE: int = 99999
const MAX_ITERATIONS: int = 64

const OUTCOME_VICTORY: String = "victory"
const OUTCOME_DEFEAT: String = "defeat"
const OUTCOME_ESCAPE: String = "escape"
const OUTCOME_FAILURE: String = "failure"

const RAIL_CATEGORIES: Array[String] = ["attack", "skill", "defend", "item", "escape", "equipment"]
const SKILL_RAIL: String = "skill"
const SKILL_RAIL_SOURCE_CATEGORIES: Array[String] = ["skill", "magic"]
const PLAYER_SIDE: String = "player_side"
const PLAYER_ACTION_OWNERS: Array[String] = ["player", "npc"]
const ENEMY_ACTION_OWNERS: Array[String] = ["enemy", "linked_actor"]

const WINDOW_OPEN: String = "window_open"
const WINDOW_ENEMY_QUEUED: String = "enemy_action_queued"
const WINDOW_ENEMY_PASSED: String = "enemy_window_passed"

var state: TopDownActionRpgCombatState
var catalog: TopDownActionRpgContentLoader.Catalog
var encounter_definition: Dictionary = {}
var commands: Array = []
var consumed_slots: Dictionary = {}
var current_actor_id: StringName = &""
var current_category: String = "attack"
var target_focus_actor_id: StringName = &""
var pending_charge: TopDownActionRpgCombatState.ChargeState = null
var awaiting_reaction: bool = false


func setup(p_state: TopDownActionRpgCombatState, p_catalog: TopDownActionRpgContentLoader.Catalog, definition: Dictionary) -> bool:
	state = p_state
	catalog = p_catalog
	encounter_definition = definition
	state.encounter_target_roles = definition.get("target_roles", []) if definition.get("target_roles", []) is Array else []
	state.submode = "command_category"
	commands = []
	consumed_slots = {}
	current_actor_id = &""
	return state != null and catalog != null and not definition.is_empty()


func begin_actor_window(actor_id: StringName) -> String:
	var actor: TopDownActionRpgCombatState.ActorState = state.find_actor(actor_id)
	if actor == null:
		return "skipped_dead_actor"
	if actor.charge_state != null and actor.charge_state.is_active():
		state.submode = "reaction_select"
		return "charge_forced"
	if TopDownActionRpgActionScheduler.consume_broken_budget(actor):
		TopDownActionRpgActionScheduler.end_window(state, actor, 0, true)
		state.submode = "resolution_feedback"
		return "skipped_broken_window"
	TopDownActionRpgActionScheduler.open_command_window(state, actor)
	current_actor_id = actor_id
	current_category = "attack"
	commands = []
	consumed_slots[actor_id] = 0
	target_focus_actor_id = &""
	state.submode = "command_category"
	if actor.side != PLAYER_SIDE:
		return _run_actor_policy(actor)
	return WINDOW_OPEN


func command_categories() -> Array:
	return RAIL_CATEGORIES.duplicate()


func rail_source_categories(category: String) -> Array:
	if category == SKILL_RAIL:
		return SKILL_RAIL_SOURCE_CATEGORIES.duplicate()
	var single: Array = [category]
	return single


func set_category(category: String) -> bool:
	if not command_categories().has(category):
		return false
	current_category = category
	state.submode = "command_action"
	return true


func available_commands(actor_id: StringName) -> Array:
	var actor: TopDownActionRpgCombatState.ActorState = state.find_actor(actor_id)
	if actor == null or catalog == null:
		return []
	var result: Array = []
	for entry: Dictionary in _ordered_actions(_action_owners_for(actor.side), rail_source_categories(current_category)):
		var record: Dictionary = entry["record"]
		var reason: String = command_unavailable_reason(actor, record)
		result.append({"id": String(entry["id"]), "available": reason.is_empty(), "reason": reason, "order": int(entry["order"]), "display_name": String(record.get("display_name", ""))})
	return result


func _action_owners_for(side: String) -> Array:
	return PLAYER_ACTION_OWNERS.duplicate() if side == PLAYER_SIDE else ENEMY_ACTION_OWNERS.duplicate()


func _ordered_actions(owners: Array, categories: Array) -> Array:
	var result: Array = []
	for record_id: String in catalog.ids_of_kind("actions"):
		var record: Dictionary = catalog.record(record_id)
		if not owners.has(String(record.get("owner", ""))):
			continue
		if not categories.is_empty() and not categories.has(String(record.get("category", ""))):
			continue
		result.append({"id": record_id, "record": record, "order": int(record.get("order", 0))})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["order"]) != int(b["order"]):
			return int(a["order"]) < int(b["order"])
		return String(a["id"]) < String(b["id"])
	)
	return result


func _run_actor_policy(actor: TopDownActionRpgCombatState.ActorState) -> String:
	for entry: Dictionary in _ordered_actions(ENEMY_ACTION_OWNERS, []):
		var record: Dictionary = entry["record"]
		if not command_unavailable_reason(actor, record).is_empty():
			continue
		var target: StringName = _policy_target(actor, record)
		if target.is_empty() and _policy_requires_target(record):
			continue
		queue_action(StringName(String(entry["id"])), target)
		return WINDOW_ENEMY_QUEUED
	end_actor_window()
	state.submode = "resolution_feedback"
	return WINDOW_ENEMY_PASSED


func _policy_requires_target(action: Dictionary) -> bool:
	var intent_definition: Dictionary = action.get("intent", {}) if action.get("intent", {}) is Dictionary else {}
	return String(intent_definition.get("target_mode", "SELF")) != "SELF"


func _policy_target(actor: TopDownActionRpgCombatState.ActorState, action: Dictionary) -> StringName:
	var intent_definition: Dictionary = action.get("intent", {}) if action.get("intent", {}) is Dictionary else {}
	if String(intent_definition.get("target_mode", "SELF")) == "SELF":
		return &""
	var ranked: Array = []
	for candidate: Variant in state.valid_targets_for(actor, String(intent_definition.get("target_mode", "SELF")), String(intent_definition.get("target_eligibility", "living"))):
		var focus: TopDownActionRpgCombatState.ActorState = state.find_actor(StringName(String(candidate)))
		if focus != null:
			ranked.append(focus)
	ranked.sort_custom(func(a: TopDownActionRpgCombatState.ActorState, b: TopDownActionRpgCombatState.ActorState) -> bool:
		if a.target_priority != b.target_priority:
			return a.target_priority < b.target_priority
		if a.encounter_slot != b.encounter_slot:
			return a.encounter_slot < b.encounter_slot
		return String(a.actor_id) < String(b.actor_id)
	)
	return (ranked[0] as TopDownActionRpgCombatState.ActorState).actor_id if not ranked.is_empty() else &""


func command_is_available(actor: TopDownActionRpgCombatState.ActorState, action: Dictionary) -> bool:
	return command_unavailable_reason(actor, action).is_empty()


func command_unavailable_reason(actor: TopDownActionRpgCombatState.ActorState, action: Dictionary) -> String:
	if actor == null or action.is_empty():
		return "skipped_action_unavailable"
	var cost: Dictionary = action.get("cost", {}) if action.get("cost", {}) is Dictionary else {}
	var turn_cost: int = int(cost.get("turn_cost", 1))
	if turn_cost > 0 and TopDownActionRpgActionScheduler.free_slots(actor, int(consumed_slots.get(actor.actor_id, 0))) <= 0:
		return "skipped_action_unavailable"
	if not TopDownActionRpgActionScheduler.reserve_resources(actor, cost.get("resource_costs", {}) if cost.get("resource_costs", {}) is Dictionary else {}, _reserved_for(actor.actor_id)):
		return "skipped_insufficient_resource"
	if _blocked_by_status(actor, action):
		return "skipped_blocked_by_status"
	if _blocked_by_phase(action):
		return "skipped_phase_invalidated"
	if int(actor.action_cooldowns.get(String(action.get("id", "")), 0)) > 0:
		return "skipped_cooldown"
	if not _precondition_met(action):
		return "skipped_action_unavailable"
	if current_category == "escape" and not _escape_allowed():
		return "skipped_action_unavailable"
	return ""


func _reserved_for(actor_id: StringName) -> Dictionary:
	var reserved: Dictionary = {}
	for intent: TopDownActionRpgCombatState.QueuedIntent in commands:
		if intent.actor_id == actor_id:
			for key: Variant in intent.reserved_resources:
				reserved[key] = int(reserved.get(key, 0)) + int(intent.reserved_resources[key])
	return reserved


func _blocked_by_status(actor: TopDownActionRpgCombatState.ActorState, action: Dictionary) -> bool:
	var precondition: Dictionary = action.get("precondition", {}) if action.get("precondition", {}) is Dictionary else {}
	var blockers: Array = precondition.get("blocker_status_ids", []) if precondition.get("blocker_status_ids", []) is Array else []
	for status_id: Variant in blockers:
		if actor.status_count(StringName(String(status_id))) > 0:
			return true
	var category: String = String(action.get("category", ""))
	for instance: TopDownActionRpgCombatState.StatusInstance in actor.status_instances:
		if not instance.active:
			continue
		var blocked: Array = instance.payload.get("blocked_action_categories", []) if instance.payload.get("blocked_action_categories", []) is Array else []
		if blocked.has(category):
			return true
	return false


func _blocked_by_phase(action: Dictionary) -> bool:
	var precondition: Dictionary = action.get("precondition", {}) if action.get("precondition", {}) is Dictionary else {}
	var required: Array = precondition.get("required_phase_ids", []) if precondition.get("required_phase_ids", []) is Array else []
	if required.is_empty():
		return false
	var active_phases: Array = encounter_definition.get("active_phase_ids", []) if encounter_definition.get("active_phase_ids", []) is Array else []
	for phase_id: Variant in required:
		if not (active_phases as Array).has(String(phase_id)):
			return true
	return false


func _precondition_met(action: Dictionary) -> bool:
	var precondition: Dictionary = action.get("precondition", {}) if action.get("precondition", {}) is Dictionary else {}
	var condition: Variant = precondition.get("condition", {})
	if condition == null or (condition is Dictionary and (condition as Dictionary).is_empty()):
		return true
	return true


func _escape_allowed() -> bool:
	var allow: Dictionary = encounter_definition.get("allow", {}) if encounter_definition.get("allow", {}) is Dictionary else {}
	return bool(allow.get("escape", false))


func enter_target_select(action_id: StringName) -> String:
	var action: Dictionary = catalog.record(String(action_id))
	if action.is_empty():
		return "skipped_action_unavailable"
	var intent_definition: Dictionary = action.get("intent", {}) if action.get("intent", {}) is Dictionary else {}
	if String(intent_definition.get("target_mode", "SELF")) == "SELF":
		state.submode = "command_action"
		return "no_target_required"
	state.submode = "target_select"
	target_focus_actor_id = &""
	var sequence: Array = state.target_focus_sequence(state.find_actor(current_actor_id), String(intent_definition.get("target_mode", "SELF")), String(intent_definition.get("target_eligibility", "living")))
	if sequence.is_empty():
		state.submode = "command_action"
		return "skipped_no_valid_target"
	target_focus_actor_id = StringName(String(sequence[0]))
	return "target_select"


func move_target_focus(step: int) -> bool:
	var actor: TopDownActionRpgCombatState.ActorState = state.find_actor(current_actor_id)
	if actor == null:
		return false
	var action: Dictionary = _pending_action()
	if action.is_empty():
		return false
	var intent_definition: Dictionary = action.get("intent", {}) if action.get("intent", {}) is Dictionary else {}
	var sequence: Array = state.target_focus_sequence(actor, String(intent_definition.get("target_mode", "SELF")), String(intent_definition.get("target_eligibility", "living")))
	if sequence.is_empty():
		state.submode = "command_action"
		target_focus_actor_id = &""
		return false
	var index: int = sequence.find(target_focus_actor_id)
	if index < 0:
		target_focus_actor_id = StringName(String(sequence[0]))
		return true
	var next_index: int = index + step
	if next_index < 0 or next_index >= sequence.size():
		return true
	target_focus_actor_id = StringName(String(sequence[next_index]))
	return true


func cancel_target_select() -> bool:
	if state.submode != "target_select":
		return false
	state.submode = "command_action"
	target_focus_actor_id = &""
	return true


func _pending_action() -> Dictionary:
	if catalog == null:
		return {}
	for candidate: Dictionary in available_commands(current_actor_id):
		if StringName(String(candidate["id"])) == StringName(String(get_meta("pending_action_id", ""))):
			return catalog.record(String(candidate["id"]))
	return {}


func set_pending_action(action_id: StringName) -> void:
	set_meta("pending_action_id", String(action_id))


func queue_pending_action() -> TopDownActionRpgCombatState.ResolutionOutcome:
	var action_id: StringName = StringName(String(get_meta("pending_action_id", "")))
	return queue_action(action_id, target_focus_actor_id)


func queue_action(action_id: StringName, target_actor_id: StringName) -> TopDownActionRpgCombatState.ResolutionOutcome:
	var actor: TopDownActionRpgCombatState.ActorState = state.find_actor(current_actor_id)
	if actor == null:
		return _skipped_outcome(&"", "skipped_dead_actor")
	var action: Dictionary = catalog.record(String(action_id))
	if action.is_empty():
		return _skipped_outcome(String(action_id), "skipped_action_unavailable")
	var reason: String = command_unavailable_reason(actor, action)
	if not reason.is_empty():
		return _skipped_outcome(String(action_id), reason)
	var command_index: int = commands.size()
	var intent: TopDownActionRpgCombatState.QueuedIntent = TopDownActionRpgActionScheduler.build_intent(state, actor, action, target_actor_id, command_index)
	var targets: Array = _resolve_targets(actor, action, intent, target_actor_id)
	if targets.is_empty() and String(action.get("intent", {}).get("target_mode", "SELF")) != "SELF":
		return _skipped_outcome(String(action_id), "skipped_no_valid_target")
	if intent.no_turn:
		var outcome: TopDownActionRpgCombatState.ResolutionOutcome = resolve_intent(intent, actor, action, targets)
		return outcome
	commands.append(intent)
	state.queue.append(intent)
	consumed_slots[current_actor_id] = int(consumed_slots.get(current_actor_id, 0)) + 1
	if int(consumed_slots[current_actor_id]) >= TopDownActionRpgCombatState.effective_action_slots(actor):
		end_actor_window()
	state.submode = "resolution_feedback"
	return _placeholder_outcome(intent)


func end_actor_window() -> int:
	var actor: TopDownActionRpgCombatState.ActorState = state.find_actor(current_actor_id)
	if actor == null:
		return state.scheduler_tick
	var total_cost: int = 0
	for intent: TopDownActionRpgCombatState.QueuedIntent in commands:
		total_cost += intent.turn_cost
	var next_tick: int = TopDownActionRpgActionScheduler.end_window(state, actor, total_cost, total_cost <= 0)
	state.submode = "command_category"
	commands = []
	current_actor_id = &""
	target_focus_actor_id = &""
	return next_tick


func _resolve_targets(actor: TopDownActionRpgCombatState.ActorState, action: Dictionary, intent: TopDownActionRpgCombatState.QueuedIntent, target_actor_id: StringName) -> Array:
	var intent_definition: Dictionary = action.get("intent", {}) if action.get("intent", {}) is Dictionary else {}
	var mode: String = String(intent_definition.get("target_mode", "SELF"))
	var eligibility: String = String(intent_definition.get("target_eligibility", "living"))
	match mode:
		"SELF":
			return [actor.actor_id]
		"ONE_ENEMY", "ONE_ALLY":
			var focus: TopDownActionRpgCombatState.ActorState = state.find_actor(target_actor_id)
			if focus == null or not focus.is_actionable() and not _is_fallen_eligible(focus, eligibility):
				return []
			return [focus.actor_id]
		"RANDOM_ENEMY":
			var candidates: Array = state.valid_targets_for(actor, mode, eligibility)
			if candidates.is_empty():
				return []
			var index: int = state.roll_permille() % candidates.size()
			return [StringName(String(candidates[index]))]
		_:
			return state.valid_targets_for(actor, mode, eligibility)


func _is_fallen_eligible(actor: TopDownActionRpgCombatState.ActorState, eligibility: String) -> bool:
	if actor == null:
		return false
	return eligibility in ["alive_or_fallen", "fallen_ally", "any"] and not actor.removed


func advance() -> Array:
	var outcomes: Array = []
	var iterations: int = 0
	while iterations < MAX_ITERATIONS and state.result == "running" and not awaiting_reaction:
		iterations += 1
		var forced: TopDownActionRpgCombatState.ActorState = _charge_ready_actor()
		if forced != null:
			outcomes.append_array(_advance_charge(forced))
			continue
		var ready: Array = _ready_intents_at(state.scheduler_tick)
		if not ready.is_empty():
			outcomes.append_array(_resolve_ready_intents(state.find_actor(ready[0].actor_id)))
			continue
		if not TopDownActionRpgActionScheduler.advance_cycle(state):
			break
		outcomes.append_array(_check_outcome())
	return outcomes


func pass_window(actor: TopDownActionRpgCombatState.ActorState) -> Array:
	if actor == null or not actor.is_actionable():
		return []
	var outcome := TopDownActionRpgCombatState.ResolutionOutcome.new()
	outcome.outcome_id = String(state.encounter_id) + "#pass#" + str(state.next_resolution_serial())
	outcome.resolution_serial = state.next_resolution_serial()
	outcome.actor_id = actor.actor_id
	outcome.result_code = "resolved"
	TopDownActionRpgActionScheduler.begin_window(state, actor)
	TopDownActionRpgActionScheduler.end_window(state, actor, 0, true)
	return [outcome]


func _charge_ready_actor() -> TopDownActionRpgCombatState.ActorState:
	var best: TopDownActionRpgCombatState.ActorState = null
	for actor: TopDownActionRpgCombatState.ActorState in state.actors:
		if actor.charge_state == null or not actor.charge_state.is_active():
			continue
		if actor.next_window_tick > state.scheduler_tick:
			continue
		if best == null or actor.tie_break_rank < best.tie_break_rank \
			or (actor.tie_break_rank == best.tie_break_rank and String(actor.actor_id) < String(best.actor_id)):
			best = actor
	return best


func _advance_charge(actor: TopDownActionRpgCombatState.ActorState) -> Array:
	var charge: TopDownActionRpgCombatState.ChargeState = actor.charge_state
	var before: String = charge.stage
	if charge.stage == "reaction":
		if charge.window_budget > 0:
			charge.window_budget -= 1
		if charge.window_budget > 0:
			state.submode = "reaction_select"
			awaiting_reaction = true
			var waiting := TopDownActionRpgCombatState.ResolutionOutcome.new()
			waiting.outcome_id = String(state.encounter_id) + "#charge#" + str(state.next_resolution_serial())
			waiting.resolution_serial = state.next_resolution_serial()
			waiting.actor_id = actor.actor_id
			waiting.result_code = "resolved"
			waiting.charge_transition = "reaction_window"
			return [waiting]
		pending_charge = null
		awaiting_reaction = false
		state.submode = "resolution_feedback"
		return _strike_charge(actor, charge)
	var after: String = TopDownActionRpgActionScheduler.resolve_charge_stage(state, actor, &"")
	var outcome := TopDownActionRpgCombatState.ResolutionOutcome.new()
	outcome.outcome_id = String(state.encounter_id) + "#charge#" + str(state.next_resolution_serial())
	outcome.resolution_serial = state.next_resolution_serial()
	outcome.actor_id = actor.actor_id
	outcome.result_code = "resolved"
	outcome.charge_transition = before + "->" + after
	state.push_presentation("charge_stage_" + after)
	if after == "reaction":
		state.submode = "reaction_select"
		awaiting_reaction = true
	elif after in ["cancelled", "completed"]:
		pending_charge = null
		awaiting_reaction = false
		state.submode = "command_category"
	actor.next_window_tick = state.scheduler_tick + TopDownActionRpgActionScheduler.delay_ticks(1, TopDownActionRpgActionScheduler.schedule_rate(actor, {}, {}))
	return [outcome]


func _ready_intents_at(tick: int) -> Array:
	var selected: Array = []
	for intent: TopDownActionRpgCombatState.QueuedIntent in state.queue:
		if intent.ready_tick <= tick and not selected.has(intent):
			selected.append(intent)
	return TopDownActionRpgActionScheduler.sort_ready_queue(selected)


func _resolve_ready_intents(actor: TopDownActionRpgCombatState.ActorState) -> Array:
	var outcomes: Array = []
	var ready: Array = _ready_intents_at(state.scheduler_tick)
	for intent: TopDownActionRpgCombatState.QueuedIntent in ready:
		state.queue.erase(intent)
		var owner: TopDownActionRpgCombatState.ActorState = state.find_actor(intent.actor_id)
		if owner == null:
			continue
		var action: Dictionary = catalog.record(String(intent.action_id))
		if action.is_empty():
			outcomes.append(_skipped_outcome(String(intent.action_id), "skipped_action_unavailable"))
			continue
		var targets: Array = _locked_targets(intent, owner, action)
		outcomes.append(resolve_intent(intent, owner, action, targets))
	outcomes.append_array(_check_outcome())
	return outcomes


func _locked_targets(intent: TopDownActionRpgCombatState.QueuedIntent, actor: TopDownActionRpgCombatState.ActorState, action: Dictionary) -> Array:
	var intent_definition: Dictionary = action.get("intent", {}) if action.get("intent", {}) is Dictionary else {}
	var mode: String = String(intent_definition.get("target_mode", "SELF"))
	var eligibility: String = String(intent_definition.get("target_eligibility", "living"))
	if mode in ["SELF", "RANDOM_ENEMY"]:
		return _resolve_targets(actor, action, intent, intent.target_actor_id)
	if mode in ["ONE_ENEMY", "ONE_ALLY"]:
		var focus: TopDownActionRpgCombatState.ActorState = state.find_actor(intent.target_actor_id)
		if focus == null or focus.fled or focus.removed or not _is_eligible_target(focus, eligibility):
			return []
		return [focus.actor_id]
	var valid: Array = state.valid_targets_for(actor, mode, eligibility)
	var kept: Array = []
	for target_id: Variant in intent.locked_target_ids:
		var target: TopDownActionRpgCombatState.ActorState = state.find_actor(StringName(String(target_id)))
		if target != null and _is_eligible_target(target, eligibility):
			kept.append(target.actor_id)
	return kept if not kept.is_empty() else valid


func _is_eligible_target(actor: TopDownActionRpgCombatState.ActorState, eligibility: String) -> bool:
	match eligibility:
		"living":
			return actor.alive and not actor.fled and not actor.removed
		"alive_or_fallen":
			return not actor.fled and not actor.removed
		"fallen_ally":
			return actor.side == "player_side" and not actor.removed
		"any":
			return not actor.removed
	return false


func resolve_intent(intent: TopDownActionRpgCombatState.QueuedIntent, actor: TopDownActionRpgCombatState.ActorState, action: Dictionary, targets: Array) -> TopDownActionRpgCombatState.ResolutionOutcome:
	var outcome := TopDownActionRpgCombatState.ResolutionOutcome.new()
	outcome.outcome_id = String(state.encounter_id) + "#" + str(state.next_resolution_serial())
	outcome.resolution_serial = state.next_resolution_serial()
	outcome.intent_id = intent.intent_id
	outcome.actor_id = actor.actor_id
	outcome.action_id = String(intent.action_id)
	outcome.result_code = "resolved"
	if not actor.is_actionable():
		outcome.result_code = "skipped_dead_actor"
		return outcome
	var mode: String = String((action.get("intent", {}) as Dictionary).get("target_mode", "SELF"))
	if targets.is_empty() and mode != "SELF":
		outcome.result_code = "skipped_no_valid_target"
		return outcome
	if not _consume_action_resources(actor, action, outcome):
		outcome.result_code = "skipped_insufficient_resource"
		return outcome
	var cooldown: int = int((action.get("cost", {}) as Dictionary).get("cooldown_windows", 0)) if (action.get("cost", {}) is Dictionary) else 0
	if cooldown > 0:
		actor.action_cooldowns[String(action.get("id", ""))] = cooldown
	if String(action.get("lifecycle", "instant")) == "charge":
		return _resolve_charge_action(intent, actor, action, targets, outcome)
	outcome.target_ids = _target_id_list(targets)
	match String(action.get("defense_mode", "none")):
		"guard":
			_apply_guard(actor, outcome)
			return outcome
		"dodge":
			_apply_dodge(actor, outcome)
			return outcome
		"break_attempt":
			_apply_break_attempt(actor, targets, action, outcome)
			return outcome
	_resolve_damage(actor, targets, action, outcome)
	_apply_status_payloads(actor, targets, action, outcome)
	return outcome


func _target_id_list(targets: Array) -> Array:
	var result: Array = []
	for target: Variant in targets:
		result.append(String(target))
	return result


func _consume_action_resources(actor: TopDownActionRpgCombatState.ActorState, action: Dictionary, outcome: TopDownActionRpgCombatState.ResolutionOutcome) -> bool:
	var cost: Dictionary = action.get("cost", {}) if action.get("cost", {}) is Dictionary else {}
	var resources: Dictionary = cost.get("resource_costs", {}) if cost.get("resource_costs", {}) is Dictionary else {}
	for key: Variant in resources:
		var resource: String = String(key)
		var amount: int = int(resources[key])
		if actor.resource_amount(resource) < amount:
			return false
	for key: Variant in resources:
		var resource: String = String(key)
		var amount: int = int(resources[key])
		match resource:
			"hp":
				actor.hp = maxi(0, actor.hp - amount)
			"mp":
				actor.mp = maxi(0, actor.mp - amount)
			"equipment_charge":
				actor.equipment_charge = maxi(0, actor.equipment_charge - amount)
		outcome.consumed_resources[resource] = amount
	return true


func _apply_guard(actor: TopDownActionRpgCombatState.ActorState, outcome: TopDownActionRpgCombatState.ResolutionOutcome) -> void:
	actor.stance_state = "guard"
	actor.guard_window_budget = TopDownActionRpgCombatState.GUARD_WINDOW_BUDGET
	actor.guard_broken_windows = 0
	outcome.stance_changes[String(actor.actor_id)] = "guard"
	state.push_presentation("stance_guard")


func _apply_dodge(actor: TopDownActionRpgCombatState.ActorState, outcome: TopDownActionRpgCombatState.ResolutionOutcome) -> void:
	actor.stance_state = "dodge"
	outcome.stance_changes[String(actor.actor_id)] = "dodge"
	state.push_presentation("stance_dodge")


func _apply_break_attempt(actor: TopDownActionRpgCombatState.ActorState, targets: Array, action: Dictionary, outcome: TopDownActionRpgCombatState.ResolutionOutcome) -> void:
	if targets.is_empty():
		outcome.result_code = "skipped_no_valid_target"
		return
	var target: TopDownActionRpgCombatState.ActorState = state.find_actor(StringName(String(targets[0])))
	if target == null:
		outcome.result_code = "skipped_target_invalidated"
		return
	if target.stance_state == "broken":
		outcome.result_code = "skipped_already_broken"
		return
	if target.break_policy == "immune":
		outcome.result_code = "skipped_break_immune"
		return
	var break_power: int = int((action.get("cost", {}) as Dictionary).get("break_power", 0)) if (action.get("cost", {}) as Dictionary).has("break_power") else 0
	if break_power == 0:
		var damage: Dictionary = action.get("damage_payload", {}) if action.get("damage_payload", {}) is Dictionary else {}
		break_power = int(damage.get("break_damage", 0))
	var spec: Dictionary = action.get("break_spec", {}) if action.get("break_spec", {}) is Dictionary else {}
	var cancels: bool = bool(spec.get("cancels_charge", false))
	if TopDownActionRpgActionScheduler.apply_break(state, actor, target, break_power, cancels):
		outcome.break_applied = true
		outcome.stance_changes[String(target.actor_id)] = "broken"
		for effect_id: Variant in spec.get("effect_ids", []) if spec.get("effect_ids", []) is Array else []:
			outcome.world_effect_ids.append(String(effect_id))
		state.push_presentation("break_applied")
	else:
		outcome.result_code = "skipped_already_broken" if target.stance_state == "broken" else "resolved"
		_resolve_damage(actor, targets, action, outcome)


func _resolve_damage(actor: TopDownActionRpgCombatState.ActorState, targets: Array, action: Dictionary, outcome: TopDownActionRpgCombatState.ResolutionOutcome) -> void:
	var payload: Dictionary = action.get("damage_payload", {}) if action.get("damage_payload", {}) is Dictionary else {}
	if payload.is_empty():
		return
	var delivery: String = String(payload.get("delivery", "physical"))
	var shape: String = String(payload.get("shape", "fixed"))
	var base_value: int = int(payload.get("base_value", 0))
	var guard_ignore: bool = bool(payload.get("guard_ignore", false))
	var breaks_guard: bool = bool(payload.get("breaks_guard", false))
	var break_damage: int = int(payload.get("break_damage", 0))
	var dodgeable: bool = bool(payload.get("dodgeable", true))
	var hit_roll: int = state.roll_permille(int(payload.get("hit_modifier", 0)))
	if String(payload.get("hit_policy", "roll")) != "guaranteed" and hit_roll < 500:
		outcome.result_code = "missed_hit"
		return
	for target_id: Variant in targets:
		var target: TopDownActionRpgCombatState.ActorState = state.find_actor(StringName(String(target_id)))
		if target == null or not target.is_actionable():
			continue
		if dodgeable and target.stance_state == "dodge" and _dodge_roll(target, payload):
			outcome.dodged = true
			outcome.result_code = "dodged"
			for effect_id: Variant in payload.get("on_evade_payload_ids", []) if payload.get("on_evade_payload_ids", []) is Array else []:
				outcome.world_effect_ids.append(String(effect_id))
			continue
		var amount: int = _damage_amount(target, shape, base_value, delivery)
		if not guard_ignore and target.stance_state == "guard" and delivery != "true":
			amount = _guard_mitigation(target, amount)
		amount = clampi(amount, 0, MAX_DAMAGE)
		if amount > 0:
			target.hp = maxi(0, target.hp - amount)
			outcome.damage_by_actor[String(target.actor_id)] = int(outcome.damage_by_actor.get(String(target.actor_id), 0)) + amount
		if breaks_guard and TopDownActionRpgActionScheduler.break_guard(state, target, break_damage, 5):
			outcome.guard_broken = true
			outcome.stance_changes[String(target.actor_id)] = "guard_broken"
			state.push_presentation("guard_broken")
		if target.hp <= 0 and target.alive:
			_register_death(target, outcome)
		for effect_id: Variant in payload.get("on_hit_payload_ids", []) if payload.get("on_hit_payload_ids", []) is Array else []:
			if not (outcome.lethal_actor_ids as Array).has(String(target.actor_id)):
				outcome.world_effect_ids.append(String(effect_id))
		var lifesteal: int = int(payload.get("lifesteal", 0))
		if lifesteal > 0:
			actor.hp = mini(actor.max_hp, actor.hp + lifesteal)


func _damage_amount(target: TopDownActionRpgCombatState.ActorState, shape: String, base_value: int, delivery: String) -> int:
	match shape:
		"percent_max_hp":
			return target.max_hp * base_value / 100
		"percent_current_hp":
			return target.hp * base_value / 100
		"guaranteed":
			return maxi(1, base_value)
		_:
			return base_value


func _guard_mitigation(target: TopDownActionRpgCombatState.ActorState, amount: int) -> int:
	if target.stance_state != "guard":
		return amount
	var efficiency: int = clampi(int(target.base_stats.get("guard_efficiency", 0)), -1000, 1000)
	var defense: int = maxi(0, int(target.base_stats.get("defense", 0)))
	return maxi(0, amount - defense * efficiency / 1000)


func _dodge_roll(target: TopDownActionRpgCombatState.ActorState, payload: Dictionary) -> bool:
	if String(payload.get("evasion_policy", "roll")) == "disabled":
		return false
	var evasion: int = maxi(0, int(target.base_stats.get("evasion", 0)))
	var agility: int = maxi(0, int(target.base_stats.get("agility", 0)))
	var pressure: int = clampi(int(payload.get("dodge_pressure", 0)), 0, 99)
	var chance: int = BASE_DODGE + DODGE_WEIGHT * evasion + AGILITY_WEIGHT * (agility - REFERENCE_AGILITY) - pressure
	chance = clampi(chance, MIN_DODGE, MAX_DODGE)
	return state.roll_permille() < chance


func _register_death(target: TopDownActionRpgCombatState.ActorState, outcome: TopDownActionRpgCombatState.ResolutionOutcome) -> void:
	target.alive = false
	outcome.lethal_actor_ids.append(String(target.actor_id))
	target.stance_state = "normal"
	target.charge_state = null
	for intent: TopDownActionRpgCombatState.QueuedIntent in state.queue:
		if intent.target_actor_id == target.actor_id:
			intent.locked_target_ids = []
	state.queue = state.queue.filter(func(item: TopDownActionRpgCombatState.QueuedIntent) -> bool:
		return item.actor_id != target.actor_id
	)
	state.push_presentation("actor_down")


func _apply_status_payloads(actor: TopDownActionRpgCombatState.ActorState, targets: Array, action: Dictionary, outcome: TopDownActionRpgCombatState.ResolutionOutcome) -> void:
	var payloads: Array = action.get("status_payloads", []) if action.get("status_payloads", []) is Array else []
	for payload: Variant in payloads:
		if not payload is Dictionary:
			continue
		var status_id: StringName = StringName(String(payload.get("status_id", "")))
		var definition: Dictionary = catalog.record(String(status_id))
		if definition.is_empty():
			continue
		var chance: int = int(payload.get("chance_permille", 1000))
		var target_actor: TopDownActionRpgCombatState.ActorState = actor if String(payload.get("target", "target")) == "self" else state.find_actor(StringName(String(targets[0]))) if not targets.is_empty() else null
		if target_actor == null or not target_actor.is_actionable():
			continue
		if state.roll_permille() >= chance:
			continue
		var instance: TopDownActionRpgCombatState.StatusInstance = _apply_status(target_actor, definition, status_id, actor.actor_id)
		if instance != null:
			outcome.status_applied.append(String(status_id))
			state.push_presentation("status_applied")


func _apply_status(target: TopDownActionRpgCombatState.ActorState, definition: Dictionary, status_id: StringName, source_id: StringName) -> TopDownActionRpgCombatState.StatusInstance:
	var resistance: Dictionary = definition.get("resistance", {}) if definition.get("resistance", {}) is Dictionary else {}
	var immune: Array = resistance.get("immune_status_ids", []) if resistance.get("immune_status_ids", []) is Array else []
	var incoming: Array = resistance.get("incoming_status_ids", []) if resistance.get("incoming_status_ids", []) is Array else []
	if immune.has(String(status_id)):
		return null
	if incoming.has(String(status_id)) and state.roll_permille() < 500:
		return null
	var policy: String = String(definition.get("stack_policy", "none"))
	var max_stacks: int = maxi(1, int(definition.get("max_stacks", 1)))
	var duration: Dictionary = definition.get("duration", {}) if definition.get("duration", {}) is Dictionary else {}
	var existing: TopDownActionRpgCombatState.StatusInstance = target.find_status(status_id)
	if existing != null and policy in ["stack", "max_intensity", "refresh"]:
		existing.stacks = mini(max_stacks, existing.stacks + 1)
		existing.remaining_windows = maxi(existing.remaining_windows, int(duration.get("turns", 1)))
		return existing
	var instance := TopDownActionRpgCombatState.StatusInstance.new()
	instance.instance_id = String(status_id) + "@" + String(target.actor_id) + "@" + str(target.status_instances.size())
	instance.definition_id = status_id
	instance.source_actor_id = source_id
	instance.stacks = 1
	instance.remaining_windows = int(duration.get("turns", 0))
	instance.application_serial = state.next_resolution_serial()
	var modifiers: Dictionary = definition.get("modifiers", {}) if definition.get("modifiers", {}) is Dictionary else {}
	var control: Dictionary = definition.get("control", {}) if definition.get("control", {}) is Dictionary else {}
	instance.payload = {
		"stat_deltas": modifiers.get("stat_deltas", {}) if modifiers.get("stat_deltas", {}) is Dictionary else {},
		"blocked_action_categories": control.get("blocked_action_categories", []) if control.get("blocked_action_categories", []) is Array else [],
	}
	target.add_status_instance(instance)
	return instance


func _resolve_charge_action(intent: TopDownActionRpgCombatState.QueuedIntent, actor: TopDownActionRpgCombatState.ActorState, action: Dictionary, targets: Array, outcome: TopDownActionRpgCombatState.ResolutionOutcome) -> TopDownActionRpgCombatState.ResolutionOutcome:
	var telegraph: Dictionary = action.get("telegraph", {}) if action.get("telegraph", {}) is Dictionary else {}
	var strike_id: StringName = StringName(String(action.get("id", "")))
	var charge: TopDownActionRpgCombatState.ChargeState = TopDownActionRpgActionScheduler.start_charge(state, actor, StringName(String(action.get("id", ""))), StringName(String(targets[0])) if not targets.is_empty() else &"", int(telegraph.get("windows_before_active", 1)))
	var spec: Dictionary = action.get("break_spec", {}) if action.get("break_spec", {}) is Dictionary else {}
	var reactions: Dictionary = action.get("reactions", {}) if action.get("reactions", {}) is Dictionary else {}
	if reactions.has("valid_reaction_ids"):
		charge.valid_reaction_ids = (reactions["valid_reaction_ids"] as Array).duplicate()
	if reactions.has("forbidden_response_ids"):
		charge.forbidden_response_ids = (reactions["forbidden_response_ids"] as Array).duplicate()
	charge.strike_action_id = strike_id
	pending_charge = charge
	outcome.charge_transition = "telegraph"
	state.submode = "resolution_feedback"
	return outcome


func offer_reaction(reaction_action_id: StringName) -> String:
	if pending_charge == null or state.submode != "reaction_select":
		return "skipped_action_unavailable"
	if pending_charge.forbidden_response_ids.has(String(reaction_action_id)):
		return "skipped_action_unavailable"
	var actor: TopDownActionRpgCombatState.ActorState = state.find_actor(pending_charge.owner_actor_id)
	if actor == null:
		return "skipped_dead_actor"
	pending_charge.stage = "cancelled"
	actor.charge_state = null
	actor.next_window_tick = state.scheduler_tick + TopDownActionRpgActionScheduler.delay_ticks(1, TopDownActionRpgActionScheduler.schedule_rate(actor, {}, {}))
	pending_charge = null
	awaiting_reaction = false
	state.submode = "command_category"
	state.push_presentation("charge_cancelled")
	return "charge_cancelled"


func accept_charge() -> String:
	if pending_charge == null or state.submode != "reaction_select":
		return "skipped_action_unavailable"
	var actor: TopDownActionRpgCombatState.ActorState = state.find_actor(pending_charge.owner_actor_id)
	if actor == null:
		return "skipped_dead_actor"
	var charge: TopDownActionRpgCombatState.ChargeState = pending_charge
	pending_charge = null
	awaiting_reaction = false
	var outcomes: Array = _strike_charge(actor, charge)
	state.push_presentation("charge_strike")
	if not outcomes.is_empty():
		(outcomes[0] as TopDownActionRpgCombatState.ResolutionOutcome).charge_transition = "reaction->strike"
	return "charge_accepted"


func _strike_charge(actor: TopDownActionRpgCombatState.ActorState, charge: TopDownActionRpgCombatState.ChargeState) -> Array:
	var strike_id: StringName = charge.strike_action_id
	var action: Dictionary = catalog.record(String(strike_id))
	if action.is_empty():
		charge.stage = "completed"
		charge.stage_ordinal = 4
		actor.charge_state = null
		return []
	var intent := TopDownActionRpgCombatState.QueuedIntent.new()
	intent.intent_id = String(state.encounter_id) + "|strike|" + String(actor.actor_id) + "|" + str(state.resolution_serial)
	intent.actor_id = actor.actor_id
	intent.action_id = strike_id
	intent.target_mode = "ONE_ENEMY"
	intent.target_actor_id = charge.target_actor_id
	intent.turn_cost = 0
	intent.no_turn = true
	var target: TopDownActionRpgCombatState.ActorState = state.find_actor(charge.target_actor_id)
	var targets: Array = [target.actor_id] if target != null and target.is_actionable() else []
	var outcome: TopDownActionRpgCombatState.ResolutionOutcome = resolve_intent(intent, actor, action, targets)
	charge.stage = "recovery"
	charge.stage_ordinal = 3
	charge.window_budget = 1
	return [outcome]

func _check_outcome() -> Array:
	var results: Array = []
	if state.result != "running":
		return results
	var player_alive: bool = not state.living_actors_on_side("player_side").is_empty()
	var enemy_alive: bool = not state.living_actors_on_side("enemy_side").is_empty()
	if not enemy_alive:
		state.result = OUTCOME_VICTORY
		state.submode = "combat_result"
	elif not player_alive:
		state.result = OUTCOME_DEFEAT
		state.submode = "combat_result"
	return results


func request_escape() -> String:
	if not _escape_allowed():
		return "skipped_action_unavailable"
	state.result = OUTCOME_ESCAPE
	state.submode = "combat_result"
	return "escape_attempted"


func force_result(result: String) -> bool:
	if not TopDownActionRpgCombatState.COMBAT_RESULTS.has(result) or result == "running":
		return false
	state.result = result
	state.submode = "combat_result"
	return true


func _placeholder_outcome(intent: TopDownActionRpgCombatState.QueuedIntent) -> TopDownActionRpgCombatState.ResolutionOutcome:
	var outcome := TopDownActionRpgCombatState.ResolutionOutcome.new()
	outcome.outcome_id = String(state.encounter_id) + "#queued#" + intent.intent_id
	outcome.intent_id = intent.intent_id
	outcome.actor_id = intent.actor_id
	outcome.action_id = String(intent.action_id)
	outcome.result_code = "queued"
	outcome.consumed_resources = intent.reserved_resources.duplicate(true)
	return outcome


func _skipped_outcome(action_id: String, reason: String) -> TopDownActionRpgCombatState.ResolutionOutcome:
	var outcome := TopDownActionRpgCombatState.ResolutionOutcome.new()
	outcome.outcome_id = String(state.encounter_id) + "#skipped#" + str(state.next_resolution_serial())
	outcome.resolution_serial = state.next_resolution_serial()
	outcome.action_id = action_id
	outcome.result_code = reason
	return outcome
