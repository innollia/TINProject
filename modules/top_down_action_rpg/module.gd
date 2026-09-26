extends GameModule

const ACTIONS: Array[StringName] = [
	&"top_down_action_rpg_left", &"top_down_action_rpg_right", &"top_down_action_rpg_up",
	&"top_down_action_rpg_down", &"top_down_action_rpg_confirm", &"top_down_action_rpg_cancel"
]
const MOVE_VECTORS: Dictionary = {
	&"top_down_action_rpg_left": Vector2(-1.0, 0.0),
	&"top_down_action_rpg_right": Vector2(1.0, 0.0),
	&"top_down_action_rpg_up": Vector2(0.0, -1.0),
	&"top_down_action_rpg_down": Vector2(0.0, 1.0),
}
const FOCUS_STEPS: Dictionary = {
	&"top_down_action_rpg_left": -1,
	&"top_down_action_rpg_right": 1,
	&"top_down_action_rpg_up": -1,
	&"top_down_action_rpg_down": 1,
}
const INTENT_FIELD_MOVE: StringName = &"field_move"
const INTENT_FIELD_FOCUS: StringName = &"field_focus"
const INTENT_FIELD_INTERACT: StringName = &"field_interact"
const INTENT_DIALOGUE_FOCUS: StringName = &"dialogue_focus"
const INTENT_CHOICE_CONFIRM: StringName = &"choice_confirm"
const INTENT_COMBAT_CATEGORY_FOCUS: StringName = &"combat_category_focus"
const INTENT_COMBAT_ACTION_FOCUS: StringName = &"combat_action_focus"
const INTENT_COMBAT_TARGET_FOCUS: StringName = &"combat_target_focus"
const INTENT_COMBAT_TARGET: StringName = &"combat_target"
const INTENT_COMBAT_CANCEL: StringName = &"combat_cancel"
const INTENT_COMBAT_END_TURN: StringName = &"combat_end_turn"
const INTENT_COMBAT_REACTION: StringName = &"combat_reaction"
const INTENT_COMBAT_RECEIVE: StringName = &"combat_receive"

const PLAYER_SIDE: String = "player_side"
const PLAYER_DISPLAY_NAME: String = "Continuity Head"
const PLAYER_MAX_HP: int = 220
const PLAYER_MAX_MP: int = 40
const PLAYER_ACTION_SLOTS: int = 1
const PLAYER_BASE_STATS: Dictionary = {
	"agility": 12,
	"max_hp": PLAYER_MAX_HP,
	"max_mp": PLAYER_MAX_MP,
	"hit": 60,
	"evasion": 80,
	"critical": 50,
	"critical_avoidance": 50,
	"guard_efficiency": 300,
	"break_damage": 40,
	"defense": 0,
	"break_resistance": 0,
}
const BASE_STAT_KEYS: Array[String] = [
	"agility", "max_hp", "max_mp", "hit", "evasion", "critical", "critical_avoidance",
	"guard_efficiency", "break_damage", "defense", "break_resistance",
]
const OUTCOME_BLOCK_KEYS: Dictionary = {
	"victory": "on_victory",
	"escape": "on_escape",
	"defeat": "on_failure",
	"failure": "on_failure",
}
const SUCCESS_RESULTS: Array[String] = ["victory", "escape"]
const COMBAT_COMMAND_SUBMODES: Array[String] = [
	"command_category", "command_action", "target_select", "resolution_feedback",
]
const SAVE_ROOT_KEYS: Array[String] = [
	"state_format", "save_version", "run_id", "content_revision",
	"field", "combat", "player", "world", "recovery", "progression", "transaction", "commit_log",
]
const COMBAT_SAVE_KEYS: Array[String] = [
	"active_encounter_id", "resume_boundary", "pre_command_intent", "attempt_serial", "result",
]
const COMBAT_TEXT_KEYS: Array[String] = ["active_encounter_id", "resume_boundary", "result"]

static var _cached_result: TopDownActionRpgContentLoader.CatalogResult = null

var content_signature: String = ""
var entry_region_id: String = ""

var _catalog: TopDownActionRpgContentLoader.Catalog = null
var _game_state: TopDownActionRpgGameState = null
var _field: TopDownActionRpgFieldController = null
var _conversation: TopDownActionRpgConversationController = null
var _recovery: TopDownActionRpgRecoveryController = null
var _combat: TopDownActionRpgCombatState = null
var _combat_controller: TopDownActionRpgCombatController = null
var _actor_definitions: Dictionary = {}
var _pending_state: Dictionary = {}
var _held: Dictionary = {}
var _rail_focus: int = 0
var _aftermath: bool = false
var _dirty: bool = true
var _settled_mode: String = ""
var _bound: bool = false
var _live: bool = false

@onready var _screen: TopDownActionRpgScreen = get_node_or_null("TopDownScreen") as TopDownActionRpgScreen


func _ready() -> void:
	if _screen != null and not _screen.intent_requested.is_connected(_on_screen_intent):
		_screen.intent_requested.connect(_on_screen_intent)


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	_rail_focus = 0
	_aftermath = false
	_catalog = _load_catalog()
	if _catalog != null:
		content_signature = _catalog.content_signature
		entry_region_id = _catalog.entry_region_id
	_boot(_pending_state)
	_pending_state = {}
	_live = true
	_dirty = true
	_settle()


func exit() -> void:
	_held.clear()
	_live = false
	_bound = false
	_pending_state = {}
	if _screen != null:
		_screen.unbind_runtime()
		if _screen.intent_requested.is_connected(_on_screen_intent):
			_screen.intent_requested.disconnect(_on_screen_intent)
	_combat = null
	_combat_controller = null
	_field = null
	_conversation = null
	_recovery = null
	_game_state = null
	_catalog = null
	_actor_definitions = {}
	super.exit()


func _process(_delta: float) -> void:
	if not _can_input():
		_held.clear()
		return
	_poll_input()
	_advance_combat()
	if _dirty or String(_game_state.mode) != _settled_mode:
		_settle()


func _can_input() -> bool:
	return _live and _game_state != null and _screen != null and context != null and context.input_enabled


func save_state() -> Dictionary:
	if _game_state == null:
		return {}
	return _project_save(_game_state.to_dict())


func load_state(state: Dictionary) -> void:
	_pending_state = _sanitize_load(state)
	if _live and _catalog != null:
		_boot(_pending_state)
		_pending_state = {}
		_dirty = true
		_settle()


func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _sanitize_load(data)


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset":
			_boot({})
		&"language":
			return payload.get("language") is String
		&"move", &"field_move":
			if not _field_commands_allowed():
				return false
			_field.move(_direction_from(payload), false)
		&"focus", &"field_focus":
			if not _field_commands_allowed():
				return false
			_field.move_focus(int(payload.get("step", 0)))
		&"interact", &"field_interact":
			if not _field_commands_allowed():
				return false
			_interact(String(payload.get("interactable_id", "")))
		&"accept_recovery":
			_accept_recovery()
		&"confirm":
			_dispatch_action(&"top_down_action_rpg_confirm")
		&"cancel", &"back":
			_dispatch_action(&"top_down_action_rpg_cancel")
		_:
			_on_screen_intent(command, payload)
	_dirty = true
	_settle()
	return true


func _field_commands_allowed() -> bool:
	return _game_state.mode == "field" or _game_state.mode == "field_return"


func _direction_from(payload: Dictionary) -> Vector2:
	var raw: Variant = payload.get("direction", Vector2.ZERO)
	if raw is Vector2:
		return raw
	return Vector2(_axis_from(payload, "x"), _axis_from(payload, "y"))


func _axis_from(payload: Dictionary, axis: String) -> float:
	var raw: Variant = payload.get(axis, 0)
	if raw is int or raw is float:
		return clampf(float(raw), -1.0, 1.0)
	return 0.0


func _poll_input() -> void:
	for action: StringName in ACTIONS:
		var pressed: bool = context.is_action_pressed(action)
		var previous: bool = bool(_held.get(action, false))
		_held[action] = pressed
		if pressed and not previous:
			_dispatch_action(action)


func _dispatch_action(action: StringName) -> void:
	_dirty = true
	if _game_state.mode == "recovery":
		if action == &"top_down_action_rpg_confirm":
			_accept_recovery()
		return
	_aftermath = false
	if MOVE_VECTORS.has(action):
		if _game_state.mode == "field":
			_field.move(MOVE_VECTORS[action], false)
		else:
			_screen.submit_focus(int(FOCUS_STEPS[action]))
		return
	if action == &"top_down_action_rpg_confirm":
		_screen.submit_confirm()
	elif action == &"top_down_action_rpg_cancel":
		_screen.submit_cancel()


func _on_screen_intent(kind: StringName, payload: Dictionary) -> void:
	if not _can_input():
		return
	_dirty = true
	_aftermath = false
	match kind:
		INTENT_FIELD_MOVE:
			_field.move(_direction_from(payload), false)
		INTENT_FIELD_FOCUS:
			_field.move_focus(int(payload.get("step", 0)))
		INTENT_FIELD_INTERACT:
			_interact(String(payload.get("interactable_id", "")))
		&"dialogue_advance":
			_conversation.advance_page()
		INTENT_DIALOGUE_FOCUS:
			_conversation.move_choice_focus(int(payload.get("step", 0)))
		INTENT_CHOICE_CONFIRM:
			_confirm_choice(String(payload.get("choice_id", "")))
		&"dialogue_cancel":
			_conversation.cancel()
		&"document_advance":
			_conversation.advance_document()
		INTENT_COMBAT_CATEGORY_FOCUS:
			_move_rail_focus(int(payload.get("step", 0)), _rail_category_rows())
		INTENT_COMBAT_ACTION_FOCUS:
			_move_rail_focus(int(payload.get("step", 0)), _rail_action_rows())
		INTENT_COMBAT_TARGET_FOCUS:
			_combat_controller.move_target_focus(int(payload.get("step", 0)))
		&"combat_category":
			_combat_controller.set_category(String(payload.get("category", "")))
		&"combat_action":
			_select_action(String(payload.get("action_id", "")))
		INTENT_COMBAT_TARGET:
			_commit_target(String(payload.get("target_actor_id", "")))
		INTENT_COMBAT_CANCEL:
			_cancel_command()
		INTENT_COMBAT_END_TURN:
			_combat_controller.end_actor_window()
		INTENT_COMBAT_REACTION:
			_offer_reaction()
		INTENT_COMBAT_RECEIVE:
			_accept_charge()
	_settle()


func _move_rail_focus(step: int, rows: int) -> void:
	_rail_focus = posmod(_rail_focus + step, maxi(1, rows))
	if _screen != null:
		_screen.set_rail_focus(_rail_focus)


func _rail_category_rows() -> int:
	return TopDownActionRpgScreen.CATEGORY_ROW_TOKENS.size() + 1


func _rail_action_rows() -> int:
	if _combat_controller == null or _catalog == null:
		return 0
	var category: String = String(_combat_controller.current_category)
	var count: int = 0
	for entry: Dictionary in _combat_controller.available_commands(_combat_controller.current_actor_id):
		if String(_catalog.record(String(entry.get("id", ""))).get("category", "")) == category:
			count += 1
	return count


func _interact(interactable_id: String) -> void:
	if not interactable_id.is_empty() and not _focus_interactable(interactable_id):
		return
	var payload: Dictionary = _field.interact()
	if String(payload.get("result", "")) != "interacted":
		return
	if _game_state.mode == "encounter_prepare":
		return
	_open_record(String(payload.get("opens", "")), String(payload.get("interactable_id", "")))


func _focus_interactable(interactable_id: String) -> bool:
	var candidates: Array = _field.focus_candidates()
	for index: int in range(candidates.size()):
		var entry: TopDownActionRpgFieldController.Interactable = candidates[index]
		if String(entry.interactable_id) == interactable_id:
			_field.focus_index = index
			return true
	return false


func _open_record(target_id: String, from_interactable_id: String) -> void:
	if target_id.is_empty() or _catalog == null:
		return
	match _catalog.kind_of(target_id):
		"conversations":
			_conversation.open_conversation(StringName(target_id), StringName(from_interactable_id))
		"documents":
			_conversation.origin_region_id = _game_state.region_id()
			_conversation.origin_interactable_id = StringName(from_interactable_id)
			_conversation.origin_anchor_id = String(_game_state.field.get("anchor_id", ""))
			_conversation.open_document(StringName(target_id))


func _confirm_choice(choice_id: String) -> void:
	if not choice_id.is_empty():
		_conversation.active_choice_id = StringName(choice_id)
	_conversation.confirm_choice()


func _select_action(action_id: String) -> void:
	if _combat_controller == null or _catalog == null or action_id.is_empty():
		return
	var record: Dictionary = _catalog.record(action_id)
	var intent_definition: Dictionary = record.get("intent", {}) if record.get("intent", {}) is Dictionary else {}
	_combat_controller.set_pending_action(StringName(action_id))
	if String(intent_definition.get("target_mode", "SELF")) == "SELF":
		_combat_controller.queue_action(StringName(action_id), &"")
		return
	_combat_controller.enter_target_select(StringName(action_id))


func _commit_target(target_actor_id: String) -> void:
	if _combat_controller == null:
		return
	var pending: String = String(_combat_controller.get_meta("pending_action_id", ""))
	_combat_controller.queue_action(StringName(pending), StringName(target_actor_id))


func _cancel_command() -> void:
	if _combat_controller == null:
		return
	if not _combat_controller.cancel_target_select():
		_combat_controller.set_pending_action(&"")


func _offer_reaction() -> void:
	if _combat_controller == null or _combat_controller.pending_charge == null:
		return
	var reactions: Array = _combat_controller.pending_charge.valid_reaction_ids
	if reactions.is_empty():
		return
	var reaction: String = String(reactions[0])
	if _combat_controller.pending_charge.forbidden_response_ids.has(reaction):
		return
	_combat_controller.offer_reaction(StringName(reaction))


func _accept_charge() -> void:
	if _combat_controller != null:
		_combat_controller.accept_charge()


func _advance_combat() -> void:
	if _combat == null or _combat_controller == null or _game_state.mode != "combat":
		return
	if _combat.result != "running":
		_finish_encounter()
		return
	if _combat_controller.awaiting_reaction or _player_window_open():
		return
	_open_due_enemy_window()
	_apply_world_effects(_combat_controller.advance())
	_dirty = true
	if _combat.result != "running":
		_finish_encounter()
		return
	if _combat_controller.awaiting_reaction:
		return
	_open_player_window()


func _open_due_enemy_window() -> void:
	if _combat_controller == null or _combat_controller.awaiting_reaction:
		return
	var next_actor: TopDownActionRpgCombatState.ActorState = TopDownActionRpgActionScheduler.select_next_actor(_combat)
	if next_actor == null or next_actor.actor_id == _player_actor_id():
		return
	if next_actor.next_window_tick > _combat.scheduler_tick:
		return
	_combat_controller.begin_actor_window(next_actor.actor_id)


func _player_window_open() -> bool:
	return _combat_controller.current_actor_id == _player_actor_id() \
		and COMBAT_COMMAND_SUBMODES.has(String(_combat.submode))


func _player_window_due() -> bool:
	var player: TopDownActionRpgCombatState.ActorState = _player_actor()
	if player == null or not player.is_actionable():
		return false
	return player.next_window_tick <= _combat.scheduler_tick


func _open_player_window() -> void:
	if _combat_controller == null or _combat_controller.awaiting_reaction:
		return
	if _player_window_due() and not _player_window_open():
		_combat_controller.begin_actor_window(_player_actor_id())


func _player_actor_id() -> StringName:
	return StringName(TopDownActionRpgGameState.PLAYER_ROLE_ID)


func _player_actor() -> TopDownActionRpgCombatState.ActorState:
	return _combat.find_actor(_player_actor_id()) if _combat != null else null


func _primary_enemy() -> TopDownActionRpgCombatState.ActorState:
	if _combat == null:
		return null
	var best: TopDownActionRpgCombatState.ActorState = null
	for actor: TopDownActionRpgCombatState.ActorState in _combat.actors:
		if actor.side == PLAYER_SIDE or not actor.is_actionable():
			continue
		if best == null or actor.target_priority < best.target_priority \
			or (actor.target_priority == best.target_priority and actor.encounter_slot < best.encounter_slot):
			best = actor
	return best


func _finish_encounter() -> void:
	var encounter_id: String = String(_combat.encounter_id)
	var result: String = String(_combat.result)
	var record: Dictionary = _catalog.record(encounter_id)
	_game_state.record_encounter_resolution(encounter_id, result)
	var outcome: Dictionary = record.get("outcome", {}) if record.get("outcome", {}) is Dictionary else {}
	var block_key: String = String(OUTCOME_BLOCK_KEYS.get(result, "on_failure"))
	var block: Dictionary = outcome.get(block_key, {}) if outcome.get(block_key, {}) is Dictionary else {}
	_apply_effect_ids(block.get("effect_ids", []))
	if result in SUCCESS_RESULTS:
		_apply_world_effect(record)
		_grant_rewards(record)
		_persist_vitals()
		_aftermath = true
		_game_state.set_mode("field_return")
		return
	var recovery_id: String = String(block.get("recovery_event_id", ""))
	if not recovery_id.is_empty():
		_recovery.request_recovery(_catalog.record(recovery_id))
		if not _recovery.pending_definition.is_empty():
			return
	_aftermath = false
	_game_state.set_mode("field_return")


func _apply_world_effect(record: Dictionary) -> void:
	var world_effect: Dictionary = record.get("world_effect", {}) if record.get("world_effect", {}) is Dictionary else {}
	if world_effect.is_empty():
		return
	var region_tag: String = String(world_effect.get("region_state_tag", ""))
	if not region_tag.is_empty():
		var regions: Dictionary = _game_state.world.get("regions", {}) if _game_state.world.get("regions", {}) is Dictionary else {}
		var region_record: Dictionary = regions.get(_game_state.region_id(), {}) if regions.get(_game_state.region_id(), {}) is Dictionary else {}
		if not region_record.is_empty():
			region_record["state_tag"] = region_tag
			regions[_game_state.region_id()] = region_record
			_game_state.world["regions"] = regions
	var prop_ids: Array = world_effect.get("prop_state_ids", []) if world_effect.get("prop_state_ids", []) is Array else []
	for prop_id: Variant in prop_ids:
		_advance_prop_state(String(prop_id))
	var gate_ids: Array = world_effect.get("unlock_gate_ids", []) if world_effect.get("unlock_gate_ids", []) is Array else []
	for gate_id: Variant in gate_ids:
		var effect_id: String = _unlock_effect_for_gate(String(gate_id))
		if not effect_id.is_empty():
			_apply_effect_ids([effect_id])


func _advance_prop_state(prop_id: String) -> void:
	var record: Dictionary = _catalog.record(prop_id)
	var current: String = _game_state.prop_state(prop_id)
	if current.is_empty():
		current = String(record.get("initial_state_id", ""))
	var states: Array = record.get("states", []) if record.get("states", []) is Array else []
	for entry: Variant in states:
		if not entry is Dictionary:
			continue
		var state: Dictionary = entry
		if String(state.get("state_id", "")) == current:
			continue
		_game_state.set_prop_state(prop_id, String(state.get("state_id", "")))
		_apply_effect_ids(state.get("entry_effect_ids", []))
		return


func _unlock_effect_for_gate(gate_id: String) -> String:
	for region_id: String in _catalog.ids_of_kind("regions"):
		var region: Dictionary = _catalog.record(region_id)
		var exits: Array = region.get("exits", []) if region.get("exits", []) is Array else []
		for exit_entry: Variant in exits:
			if exit_entry is Dictionary and String(exit_entry.get("gate_id", "")) == gate_id:
				return String(exit_entry.get("unlock_effect_id", ""))
	return ""


func _apply_effect_ids(effect_ids: Variant) -> void:
	if not effect_ids is Array:
		return
	for effect_id: Variant in effect_ids:
		var id: String = String(effect_id)
		if not id.is_empty():
			TopDownActionRpgContentLoader.apply_effect(_catalog.record(id), _game_state, _catalog)


func _apply_world_effects(outcomes: Variant) -> void:
	if not outcomes is Array:
		return
	for entry: Variant in outcomes:
		if entry is TopDownActionRpgCombatState.ResolutionOutcome:
			_apply_effect_ids((entry as TopDownActionRpgCombatState.ResolutionOutcome).world_effect_ids)


func _grant_rewards(record: Dictionary) -> void:
	var roster: Array = record.get("roster", []) if record.get("roster", []) is Array else []
	for entry: Variant in roster:
		if not entry is Dictionary:
			continue
		var enemy: Dictionary = _catalog.record(String((entry as Dictionary).get("enemy_id", "")))
		var reward: Dictionary = enemy.get("reward", {}) if enemy.get("reward", {}) is Dictionary else {}
		var item_ids: Array = reward.get("item_ids", []) if reward.get("item_ids", []) is Array else []
		for item_id: Variant in item_ids:
			_game_state.grant_item(String(item_id), 1)
		var equipment_ids: Array = reward.get("equipment_ids", []) if reward.get("equipment_ids", []) is Array else []
		for equipment_id: Variant in equipment_ids:
			_game_state.grant_equipment(String(equipment_id), 1)
		var deltas: Dictionary = reward.get("resource_delta", {}) if reward.get("resource_delta", {}) is Dictionary else {}
		for key: Variant in deltas:
			_game_state.grant_resource(String(key), int(deltas[key]))


func _accept_recovery() -> void:
	if _recovery == null or _recovery.pending_definition.is_empty():
		return
	var outcome: Dictionary = _recovery.apply_recovery(_recovery.pending_definition)
	if String(outcome.get("result", "")) != "recovered":
		return
	_field.rebuild_region()
	_aftermath = false
	var queued: String = String(outcome.get("queued_encounter_id", ""))
	if not queued.is_empty():
		_field.pending_encounter(_catalog.record(queued))


func _return_to_field() -> void:
	_combat = null
	_combat_controller = null
	_rail_focus = 0
	_bound = false
	_game_state.combat["active_encounter_id"] = ""
	_game_state.combat["result"] = ""
	var queued: String = TopDownActionRpgContentLoader.take_queued_encounter(_game_state, "post_recovery")
	if not queued.is_empty():
		_field.pending_encounter(_catalog.record(queued))
		return
	_aftermath = false
	_game_state.set_mode("field")
	_field.rebuild_region()


func _settle() -> void:
	if _screen == null:
		return
	if _game_state == null or _field == null or _conversation == null or _recovery == null:
		_screen.unbind_runtime()
		_bound = false
		_settled_mode = ""
		_dirty = false
		return
	if not _bound:
		_bind_screen()
	_resolve_mode()
	_screen.set_aftermath_active(_aftermath)
	_inject_timing_projection()
	_screen.refresh()
	_settled_mode = _game_state.mode
	_dirty = false


func _resolve_mode() -> void:
	var mode: String = _game_state.mode
	if mode == "encounter_prepare" or mode == "encounter_transition":
		var encounter_id: String = String(_game_state.combat.get("active_encounter_id", ""))
		if encounter_id.is_empty():
			_game_state.set_mode("field_return")
		elif _combat == null or String(_combat.encounter_id) != encounter_id:
			_build_encounter(encounter_id)
		elif mode != "combat":
			_game_state.set_mode("combat")
		return
	if mode == "combat" and _combat == null:
		var armed: String = String(_game_state.combat.get("active_encounter_id", ""))
		if armed.is_empty():
			_game_state.set_mode("field_return")
		else:
			_build_encounter(armed)
		return
	if (mode == "encounter_result" or mode == "field_return") and not _aftermath:
		_return_to_field()


func _boot(state: Dictionary) -> void:
	_combat = null
	_combat_controller = null
	_actor_definitions = {}
	_rail_focus = 0
	_aftermath = false
	_bound = false
	if _catalog == null:
		_game_state = null
		_field = null
		_conversation = null
		_recovery = null
		return
	var candidate: TopDownActionRpgGameState = null
	if not state.is_empty():
		var restored := TopDownActionRpgGameState.new()
		if restored.from_dict(state):
			candidate = restored
	if candidate == null or _catalog.record(candidate.region_id()).is_empty():
		candidate = TopDownActionRpgGameState.create_default(_entry_region(), _entry_anchor())
	_game_state = candidate
	_game_state.content_revision = _catalog.content_signature
	_field = TopDownActionRpgFieldController.new()
	_conversation = TopDownActionRpgConversationController.new()
	_recovery = TopDownActionRpgRecoveryController.new()
	_field.setup(_game_state, _catalog)
	_conversation.setup(_game_state, _catalog)
	_recovery.setup(_game_state, _catalog)
	_seed_authored_prop_states()
	_sync_vitals()


func _seed_authored_prop_states() -> void:
	var props: Dictionary = _game_state.world.get("props", {}) if _game_state.world.get("props", {}) is Dictionary else {}
	for prop_id: String in _catalog.ids_of_kind("props"):
		if props.has(prop_id):
			continue
		var initial: String = String(_catalog.record(prop_id).get("initial_state_id", ""))
		if not initial.is_empty():
			props[prop_id] = {"state_id": initial}
	_game_state.world["props"] = props


func _bind_screen() -> void:
	if _screen == null or _game_state == null:
		return
	_screen.bind_runtime(_game_state, _field, _conversation, _combat_controller, _combat, _recovery)
	_screen.set_actor_definitions(_actor_definitions)
	_inject_condition_projections()
	_bound = true


func _entry_region() -> String:
	return _catalog.entry_region_id if _catalog != null else ""


func _entry_anchor() -> String:
	if _catalog == null:
		return ""
	var region: Dictionary = _catalog.record(_entry_region())
	var entry: Dictionary = region.get("entry", {}) if region.get("entry", {}) is Dictionary else {}
	return String(entry.get("edge_id", _entry_region()))


func _build_encounter(encounter_id: String) -> void:
	var record: Dictionary = _catalog.record(encounter_id)
	if record.is_empty():
		_game_state.set_mode("field_return")
		return
	var attempt: int = maxi(0, int(_game_state.combat.get("attempt_serial", 0)))
	_combat = TopDownActionRpgCombatState.create_encounter(
		encounter_id,
		attempt,
		TopDownActionRpgGameState.stable_seed(encounter_id, attempt)
	)
	_add_player_actor()
	_add_roster_actors(record)
	_combat_controller = TopDownActionRpgCombatController.new()
	_combat_controller.setup(_combat, _catalog, record)
	_rail_focus = 0
	_actor_definitions = _collect_actor_definitions()
	_bound = false
	_game_state.set_mode("combat")
	_open_player_window()
	_bind_screen()


func _add_player_actor() -> void:
	var vitals: Dictionary = _vitals()
	var actor := TopDownActionRpgCombatState.ActorState.new()
	actor.actor_id = _player_actor_id()
	actor.display_name = PLAYER_DISPLAY_NAME
	actor.side = PLAYER_SIDE
	actor.tie_break_rank = 0
	actor.target_priority = 0
	actor.target_role = "true_actor"
	actor.base_stats = PLAYER_BASE_STATS.duplicate(true)
	actor.max_hp = maxi(1, int(vitals.get("max_hp", PLAYER_MAX_HP)))
	actor.hp = clampi(int(vitals.get("hp", actor.max_hp)), 1, actor.max_hp)
	actor.max_mp = maxi(0, int(vitals.get("max_mp", PLAYER_MAX_MP)))
	actor.mp = clampi(int(vitals.get("mp", actor.max_mp)), 0, actor.max_mp)
	actor.action_slot_snapshot = PLAYER_ACTION_SLOTS
	_combat.add_actor(actor)


func _add_roster_actors(record: Dictionary) -> void:
	var roles: Dictionary = {}
	var priority_list: Array = record.get("target_priority", []) if record.get("target_priority", []) is Array else []
	for entry: Variant in priority_list:
		if entry is Dictionary:
			roles[String((entry as Dictionary).get("enemy_id", ""))] = String((entry as Dictionary).get("role", "true_actor"))
	var roster: Array = record.get("roster", []) if record.get("roster", []) is Array else []
	var slot: int = 0
	for entry: Variant in roster:
		if not entry is Dictionary:
			continue
		var roster_entry: Dictionary = entry
		var enemy_id: String = String(roster_entry.get("enemy_id", ""))
		if _catalog.record(enemy_id).is_empty():
			continue
		var count: int = maxi(1, int(roster_entry.get("count", 1)))
		for index: int in range(count):
			var actor: TopDownActionRpgCombatState.ActorState = _build_enemy_actor(enemy_id, index)
			actor.target_priority = maxi(1, int(roster_entry.get("target_priority", 1)))
			actor.target_role = String(roles.get(enemy_id, "true_actor"))
			_combat.add_actor(actor)
			slot += 1


func _build_enemy_actor(enemy_id: String, index: int) -> TopDownActionRpgCombatState.ActorState:
	var enemy: Dictionary = _catalog.record(enemy_id)
	var stats: Dictionary = enemy.get("stats", {}) if enemy.get("stats", {}) is Dictionary else {}
	var pool: Dictionary = stats.get("resource_pool", {}) if stats.get("resource_pool", {}) is Dictionary else {}
	var base: Dictionary = {}
	for key: String in BASE_STAT_KEYS:
		base[key] = 0
	base["agility"] = int(stats.get("agility", 1))
	base["max_hp"] = int(stats.get("max_hp", 1))
	base["max_mp"] = int(pool.get("mp", 0))
	base["break_resistance"] = int(stats.get("break_resistance", 0))
	base["defense"] = int(stats.get("defense", 0))
	var actor := TopDownActionRpgCombatState.ActorState.new()
	actor.actor_id = StringName(enemy_id if index == 0 else "%s_%d" % [enemy_id, index + 1])
	actor.display_name = String(enemy.get("display_name", enemy_id))
	actor.side = "enemy_side"
	actor.tie_break_rank = 1 + index
	actor.target_priority = 1
	actor.target_role = "true_actor"
	actor.base_stats = base
	actor.max_hp = maxi(1, int(stats.get("max_hp", 1)))
	actor.hp = actor.max_hp
	actor.max_mp = maxi(0, int(pool.get("mp", 0)))
	actor.mp = actor.max_mp
	actor.max_equipment_charge = maxi(0, int(pool.get("equipment_charge", 0)))
	actor.equipment_charge = actor.max_equipment_charge
	actor.action_slot_snapshot = clampi(int(stats.get("action_slots", 1)), 1, 3)
	var profile: Dictionary = enemy.get("break_profile", {}) if enemy.get("break_profile", {}) is Dictionary else {}
	actor.break_policy = "enabled" if bool(profile.get("breakable", true)) else "immune"
	_apply_innate_statuses(actor, enemy)
	return actor


func _apply_innate_statuses(actor: TopDownActionRpgCombatState.ActorState, enemy: Dictionary) -> void:
	var profile: Dictionary = enemy.get("status_profile", {}) if enemy.get("status_profile", {}) is Dictionary else {}
	var innate: Array = profile.get("innate_status_ids", []) if profile.get("innate_status_ids", []) is Array else []
	for status_id: Variant in innate:
		var definition: Dictionary = _catalog.record(String(status_id))
		if definition.is_empty():
			continue
		var duration: Dictionary = definition.get("duration", {}) if definition.get("duration", {}) is Dictionary else {}
		var modifiers: Dictionary = definition.get("modifiers", {}) if definition.get("modifiers", {}) is Dictionary else {}
		var control: Dictionary = definition.get("control", {}) if definition.get("control", {}) is Dictionary else {}
		var stat_deltas: Variant = modifiers.get("stat_deltas", {})
		var blocked: Variant = control.get("blocked_action_categories", [])
		var instance := TopDownActionRpgCombatState.StatusInstance.new()
		instance.instance_id = String(status_id) + "@" + String(actor.actor_id) + "@0"
		instance.definition_id = StringName(String(status_id))
		instance.source_actor_id = actor.actor_id
		instance.stacks = 1
		instance.remaining_windows = int(duration.get("turns", 0))
		instance.payload = {
			"stat_deltas": stat_deltas if stat_deltas is Dictionary else {},
			"blocked_action_categories": blocked if blocked is Array else [],
		}
		actor.add_status_instance(instance)


func _collect_actor_definitions() -> Dictionary:
	var definitions: Dictionary = {
		String(_player_actor_id()): {"body": {"scale_class": "human"}}
	}
	for actor: TopDownActionRpgCombatState.ActorState in _combat.actors:
		if actor.side == PLAYER_SIDE:
			continue
		var key: String = String(actor.actor_id)
		var enemy: Dictionary = _catalog.record(key)
		if enemy.is_empty():
			var separator: int = key.rfind("_")
			enemy = _catalog.record(key.substr(0, separator) if separator > 0 else key)
		definitions[key] = enemy
	return definitions


func _inject_condition_projections() -> void:
	if _screen == null or _combat == null:
		return
	for actor: TopDownActionRpgCombatState.ActorState in _combat.actors:
		var record: Variant = _actor_definitions.get(String(actor.actor_id), {})
		if not record is Dictionary:
			continue
		var bar: Variant = (record as Dictionary).get("condition_bar", {})
		if not bar is Dictionary or (bar as Dictionary).is_empty():
			continue
		if String((bar as Dictionary).get("kind", "hp")) == "hp":
			continue
		var maximum: float = maxf(1.0, float((bar as Dictionary).get("max_value", 1)))
		_screen.set_condition_projection(actor.actor_id, float((bar as Dictionary).get("start_value", 0)) / maximum)


func _inject_timing_projection() -> void:
	if _screen == null or _combat == null:
		return
	var primary: TopDownActionRpgCombatState.ActorState = _primary_enemy()
	if primary == null:
		_screen.clear_timing_projection()
		return
	var remaining: int = maxi(0, primary.next_window_tick - _combat.scheduler_tick)
	if remaining <= 0:
		_screen.clear_timing_projection()
		return
	var span: int = maxi(1, TopDownActionRpgCombatState.BASE_SCHEDULE_TICKS)
	_screen.set_timing_projection(1.0 - float(remaining) / float(span))


func _vitals() -> Dictionary:
	var body: Dictionary = _game_state.player.get("body", {}) if _game_state.player.get("body", {}) is Dictionary else {}
	var vitals: Variant = body.get("vitals", {})
	return vitals if vitals is Dictionary else {}


func _sync_vitals() -> void:
	var body: Dictionary = _game_state.player.get("body", {}) if _game_state.player.get("body", {}) is Dictionary else {}
	var vitals: Dictionary = body.get("vitals", {}) if body.get("vitals", {}) is Dictionary else {}
	if int(vitals.get("max_hp", 0)) <= 0:
		vitals["max_hp"] = PLAYER_MAX_HP
		vitals["hp"] = PLAYER_MAX_HP
	if not vitals.has("max_mp"):
		vitals["max_mp"] = PLAYER_MAX_MP
		vitals["mp"] = PLAYER_MAX_MP
	body["vitals"] = vitals
	_game_state.player["body"] = body


func _persist_vitals() -> void:
	var player: TopDownActionRpgCombatState.ActorState = _player_actor()
	if player == null:
		return
	var body: Dictionary = _game_state.player.get("body", {}) if _game_state.player.get("body", {}) is Dictionary else {}
	var vitals: Dictionary = body.get("vitals", {}) if body.get("vitals", {}) is Dictionary else {}
	vitals["hp"] = player.hp
	vitals["max_hp"] = player.max_hp
	vitals["mp"] = player.mp
	vitals["max_mp"] = player.max_mp
	body["vitals"] = vitals
	_game_state.player["body"] = body


func _project_save(payload: Dictionary) -> Dictionary:
	var projected: Dictionary = {}
	for key: String in SAVE_ROOT_KEYS:
		if payload.has(key):
			projected[key] = _json_clone(payload[key])
	projected["combat"] = _project_combat(projected.get("combat", {}))
	return projected


func _project_combat(section: Variant) -> Dictionary:
	var source: Dictionary = section if section is Dictionary else {}
	var projected: Dictionary = {}
	for key: String in COMBAT_SAVE_KEYS:
		if not source.has(key):
			continue
		if key in COMBAT_TEXT_KEYS:
			projected[key] = String(source[key])
		elif key == "pre_command_intent":
			projected[key] = []
		else:
			var value: Variant = source[key]
			projected[key] = maxi(0, int(value)) if (value is int or value is float) and is_finite(float(value)) else 0
	projected["pre_command_intent"] = []
	return projected


func _sanitize_load(state: Dictionary) -> Dictionary:
	if not state is Dictionary or state.is_empty():
		return {}
	var clean: Dictionary = {}
	for key: String in SAVE_ROOT_KEYS:
		if state.has(key):
			clean[key] = _json_clone(state[key])
	if clean.is_empty():
		return {}
	if String(clean.get("state_format", "")) != TopDownActionRpgGameState.STATE_FORMAT:
		return {}
	if not (clean.get("save_version") is int or clean.get("save_version") is float):
		return {}
	var combat: Dictionary = _project_combat(clean.get("combat", {}))
	var field: Dictionary = clean.get("field", {}) if clean.get("field", {}) is Dictionary else {}
	if not String(combat.get("active_encounter_id", "")).is_empty():
		combat["resume_boundary"] = "encounter_prepare"
		combat["result"] = ""
	else:
		combat["resume_boundary"] = "field"
		combat["attempt_serial"] = 0
		combat["result"] = ""
	field["active_interaction_id"] = ""
	clean["combat"] = combat
	clean["field"] = field
	return clean


func _json_clone(value: Variant) -> Variant:
	if value is Dictionary:
		var copied: Dictionary = {}
		for key: Variant in (value as Dictionary):
			if key is String:
				copied[String(key)] = _json_clone((value as Dictionary)[key])
		return copied
	if value is Array:
		var items: Array = []
		for element: Variant in (value as Array):
			items.append(_json_clone(element))
		return items
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return value
		TYPE_FLOAT:
			return value if is_finite(value) else null
	return null


func _load_catalog() -> TopDownActionRpgContentLoader.Catalog:
	if _cached_result == null:
		_cached_result = TopDownActionRpgContentLoader.load_default()
	if _cached_result == null or not _cached_result.is_playable():
		return null
	return _cached_result.catalog
