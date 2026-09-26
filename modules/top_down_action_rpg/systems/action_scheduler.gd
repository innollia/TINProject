class_name TopDownActionRpgActionScheduler
extends RefCounted

const BASE_SCHEDULE_TICKS: int = TopDownActionRpgCombatState.BASE_SCHEDULE_TICKS
const MIN_SCHEDULE_RATE: int = TopDownActionRpgCombatState.MIN_SCHEDULE_RATE
const MAX_SCHEDULE_TICKS: int = 9999
const MAX_CYCLES: int = 512
const PASS_TURN_COST: int = 1
const NO_TURN: int = 0
const BROKEN_SKIP_BUDGET: int = TopDownActionRpgCombatState.BROKEN_SKIP_BUDGET
const GUARD_WINDOW_BUDGET: int = TopDownActionRpgCombatState.GUARD_WINDOW_BUDGET


class IntentError:
	extends RefCounted

	var intent_id: String = ""
	var result_code: String = ""
	var detail: String = ""

	func to_dict() -> Dictionary:
		return {"intent_id": intent_id, "result_code": result_code, "detail": detail}


static func schedule_rate(actor: TopDownActionRpgCombatState.ActorState, equipment_stats: Dictionary, temp_stats: Dictionary) -> int:
	if actor == null:
		return MIN_SCHEDULE_RATE
	return TopDownActionRpgCombatState.effective_agility(actor, equipment_stats, temp_stats)


static func delay_ticks(turn_cost: int, rate: int) -> int:
	var safe_cost: int = clampi(turn_cost, 0, TopDownActionRpgCombatState.TURN_COST_MAX)
	var safe_rate: int = maxi(MIN_SCHEDULE_RATE, rate)
	return clampi(int(ceil(float(BASE_SCHEDULE_TICKS * safe_cost) / float(safe_rate))), 0, MAX_SCHEDULE_TICKS)


static func next_window_tick(window_start_tick: int, total_queued_turn_cost: int, rate: int) -> int:
	return clampi(window_start_tick + delay_ticks(total_queued_turn_cost, rate), 0, MAX_SCHEDULE_TICKS)


static func free_slots(actor: TopDownActionRpgCombatState.ActorState, consumed_slots: int) -> int:
	if actor == null:
		return 0
	return maxi(0, TopDownActionRpgCombatState.effective_action_slots(actor) - consumed_slots)


static func can_queue(actor: TopDownActionRpgCombatState.ActorState, intent: TopDownActionRpgCombatState.QueuedIntent, consumed_slots: int) -> String:
	if actor == null or not actor.is_actionable():
		return "skipped_dead_actor"
	if not TopDownActionRpgCombatState.TARGET_MODES.has(intent.target_mode):
		return "skipped_action_unavailable"
	if intent.turn_cost == NO_TURN:
		return ""
	if free_slots(actor, consumed_slots) <= 0:
		return "skipped_action_unavailable"
	return ""


static func reserve_resources(actor: TopDownActionRpgCombatState.ActorState, cost: Dictionary, already_reserved: Dictionary) -> bool:
	for key: Variant in cost:
		var resource: String = String(key)
		if not TopDownActionRpgCombatState.RESOURCE_KEYS.has(resource):
			return false
		var needed: int = int(cost[key])
		var held: int = actor.resource_amount(resource) - int(already_reserved.get(resource, 0))
		if needed < 0 or held < needed:
			return false
	return true


static func build_intent(state: TopDownActionRpgCombatState, actor: TopDownActionRpgCombatState.ActorState, action: Dictionary, target_actor_id: StringName, command_index: int) -> TopDownActionRpgCombatState.QueuedIntent:
	var intent := TopDownActionRpgCombatState.QueuedIntent.new()
	var cost: Dictionary = action.get("cost", {}) if action.get("cost", {}) is Dictionary else {}
	var turn_cost: int = int(cost.get("turn_cost", 1)) if cost.has("turn_cost") else 1
	var intent_definition: Dictionary = action.get("intent", {}) if action.get("intent", {}) is Dictionary else {}
	intent.actor_id = actor.actor_id
	intent.action_id = StringName(String(action.get("id", "")))
	intent.action_version = int(cost.get("action_version", 1))
	intent.target_mode = String(intent_definition.get("target_mode", "SELF"))
	intent.target_actor_id = target_actor_id
	intent.turn_cost = turn_cost
	intent.no_turn = turn_cost == NO_TURN
	intent.command_index = command_index
	intent.tie_break_rank = actor.tie_break_rank
	intent.category = String(action.get("category", "attack"))
	intent.lifecycle = String(action.get("lifecycle", "instant"))
	intent.defense_mode = String(action.get("defense_mode", "none"))
	var resources: Dictionary = cost.get("resource_costs", {}) if cost.get("resource_costs", {}) is Dictionary else {}
	intent.reserved_resources = resources.duplicate(true)
	if target_actor_id.is_empty() and intent.target_mode != "SELF" and intent.target_mode != "RANDOM_ENEMY":
		var candidates: Array = state.valid_targets_for(actor, intent.target_mode, String(intent_definition.get("target_eligibility", "living")))
		if not candidates.is_empty():
			intent.locked_target_ids = candidates.duplicate()
			intent.target_actor_id = StringName(String(candidates[0]))
	intent.ready_tick = state.scheduler_tick
	intent.intent_id = _intent_id(state, actor, command_index)
	return intent


static func _intent_id(state: TopDownActionRpgCombatState, actor: TopDownActionRpgCombatState.ActorState, command_index: int) -> String:
	return String(state.encounter_id) + "|" + String(actor.actor_id) + "|" + str(actor.window_serial) + "|" + str(command_index)


static func sort_ready_queue(intents: Array) -> Array:
	var sorted: Array = intents.duplicate()
	sorted.sort_custom(func(a: TopDownActionRpgCombatState.QueuedIntent, b: TopDownActionRpgCombatState.QueuedIntent) -> bool:
		if a.ready_tick != b.ready_tick:
			return a.ready_tick < b.ready_tick
		if a.tie_break_rank != b.tie_break_rank:
			return a.tie_break_rank < b.tie_break_rank
		if a.actor_id != b.actor_id:
			return String(a.actor_id) < String(b.actor_id)
		if a.command_index != b.command_index:
			return a.command_index < b.command_index
		return a.intent_id < b.intent_id
	)
	return sorted


static func select_next_actor(state: TopDownActionRpgCombatState) -> TopDownActionRpgCombatState.ActorState:
	var best: TopDownActionRpgCombatState.ActorState = null
	for actor: TopDownActionRpgCombatState.ActorState in state.actors:
		if not actor.is_actionable():
			continue
		if actor.charge_state != null and actor.charge_state.is_active():
			continue
		if best == null:
			best = actor
			continue
		if actor.next_window_tick < best.next_window_tick:
			best = actor
		elif actor.next_window_tick == best.next_window_tick:
			if actor.tie_break_rank < best.tie_break_rank:
				best = actor
			elif actor.tie_break_rank == best.tie_break_rank and String(actor.actor_id) < String(best.actor_id):
				best = actor
	return best


static func open_command_window(state: TopDownActionRpgCombatState, actor: TopDownActionRpgCombatState.ActorState) -> int:
	actor.window_serial += 1
	actor.action_slot_snapshot = TopDownActionRpgCombatState.effective_action_slots(actor)
	begin_window(state, actor)
	return actor.action_slot_snapshot


static func begin_window(state: TopDownActionRpgCombatState, actor: TopDownActionRpgCombatState.ActorState) -> void:
	if actor.stance_state == "guard" or actor.stance_state == "guard_broken":
		if actor.stance_state == "guard_broken":
			actor.guard_broken_windows = maxi(0, actor.guard_broken_windows - 1)
			if actor.guard_broken_windows == 0:
				actor.stance_state = "normal"
		else:
			actor.guard_window_budget = maxi(0, actor.guard_window_budget - 1)
			if actor.guard_window_budget == 0:
				actor.stance_state = "normal"
	if actor.stance_state == "dodge" and state.scheduler_tick > actor.next_window_tick:
		actor.stance_state = "normal"


static func end_window(state: TopDownActionRpgCombatState, actor: TopDownActionRpgCombatState.ActorState, queued_turn_cost: int, passed: bool) -> int:
	var rate: int = schedule_rate(actor, {}, {})
	var total_cost: int = PASS_TURN_COST if queued_turn_cost <= 0 and passed else queued_turn_cost
	tick_cooldowns(actor)
	actor.next_window_tick = next_window_tick(state.scheduler_tick, total_cost, rate)
	return actor.next_window_tick


static func tick_cooldowns(actor: TopDownActionRpgCombatState.ActorState) -> void:
	if actor == null or actor.action_cooldowns.is_empty():
		return
	var remaining: Dictionary = {}
	for action_id: Variant in actor.action_cooldowns:
		var left: int = int(actor.action_cooldowns[action_id]) - 1
		if left > 0:
			remaining[String(action_id)] = left
	actor.action_cooldowns = remaining


static func resolve_charge_stage(state: TopDownActionRpgCombatState, actor: TopDownActionRpgCombatState.ActorState, reaction_action_id: StringName) -> String:
	var charge: TopDownActionRpgCombatState.ChargeState = actor.charge_state
	if charge == null or not charge.is_active():
		return ""
	match charge.stage:
		"telegraph":
			if charge.window_budget > 0:
				charge.window_budget -= 1
			if charge.window_budget <= 0:
				charge.stage = "reaction"
				charge.stage_ordinal = 1
				charge.window_budget = 1
			return charge.stage
		"reaction":
			charge.stage_ordinal = 2
			if not reaction_action_id.is_empty() and charge.break_policy != "immune":
				var cancels: bool = reaction_action_id == StringName("") or not charge.forbidden_response_ids.has(String(reaction_action_id))
				if cancels:
					charge.stage = "cancelled"
					actor.stance_state = "normal"
					return charge.stage
			charge.stage = "strike"
			return charge.stage
		"strike":
			charge.stage = "recovery"
			charge.stage_ordinal = 3
			charge.window_budget = 1
			return charge.stage
		"recovery":
			charge.stage = "completed"
			charge.stage_ordinal = 4
			actor.charge_state = null
			return charge.stage
		_:
			return charge.stage


static func start_charge(state: TopDownActionRpgCombatState, actor: TopDownActionRpgCombatState.ActorState, charge_action_id: StringName, target_actor_id: StringName, telegraph_windows: int) -> TopDownActionRpgCombatState.ChargeState:
	var charge := TopDownActionRpgCombatState.ChargeState.new()
	charge.owner_actor_id = actor.actor_id
	charge.charge_action_id = charge_action_id
	charge.stage = "telegraph"
	charge.stage_ordinal = 0
	charge.target_actor_id = target_actor_id
	charge.window_budget = maxi(1, telegraph_windows)
	charge.break_policy = actor.break_policy
	actor.charge_state = charge
	return charge


static func apply_break(state: TopDownActionRpgCombatState, breaker: TopDownActionRpgCombatState.ActorState, target: TopDownActionRpgCombatState.ActorState, break_power: int, cancels_charge: bool) -> bool:
	if target == null or not target.is_actionable():
		return false
	if target.break_policy == "immune":
		return false
	if target.stance_state == "broken":
		return false
	if break_power < target.break_resistance:
		return false
	if target.stance_state == "guard" or target.stance_state == "guard_broken":
		target.stance_state = "broken"
		target.guard_window_budget = 0
		target.guard_broken_windows = 0
	else:
		target.stance_state = "broken"
	target.broken_skip_budget = BROKEN_SKIP_BUDGET
	if cancels_charge and target.charge_state != null and target.charge_state.break_policy != "immune":
		target.charge_state.stage = "cancelled"
		target.charge_state = null
	return true


static func break_guard(state: TopDownActionRpgCombatState, target: TopDownActionRpgCombatState.ActorState, break_damage: int, guard_break_threshold: int) -> bool:
	if target == null or target.stance_state != "guard":
		return false
	if break_damage < guard_break_threshold:
		return false
	target.stance_state = "guard_broken"
	target.guard_window_budget = 0
	target.guard_broken_windows = 1
	return true


static func consume_broken_budget(target: TopDownActionRpgCombatState.ActorState) -> bool:
	if target == null or target.broken_skip_budget <= 0:
		return false
	target.broken_skip_budget -= 1
	if target.broken_skip_budget == 0:
		target.stance_state = "normal"
	return true


static func advance_cycle(state: TopDownActionRpgCombatState) -> bool:
	if state.result != "running":
		return false
	state.scheduler_tick += 1
	if state.scheduler_tick % BASE_SCHEDULE_TICKS == 0:
		state.cycle_index += 1
	return state.cycle_index < MAX_CYCLES
