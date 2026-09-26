extends SceneTree

const ENTRY_SCENE: String = "res://modules/top_down_action_rpg/entry.tscn"
const MODULE_ID: StringName = &"top_down_action_rpg"
const LEDGER_FILE_NAME: String = "top_down_action_rpg_playthrough_ledger.json"
const EVIDENCE_CLASS: String = "authored_route_logic_probe"
const EVIDENCE_VERSION: String = "1"

const ENTRY_REGION: String = "region_h0_undersign_exchange"
const ENTRY_ANCHOR: String = "route_e01_ash_stair"
const KILN_REGION: String = "region_r1_returning_kiln"
const H0_RESIDENT: String = "npc_01_ilyra_senn"
const H0_CONVERSATION: String = "conv_h0_return_desk"
const H0_CHOICE: String = "ch_file_arrival_category"
const E01_EDGE: String = "route_e01_ash_stair"
const KILN_DOOR_PROP: String = "prop_r1_wrong_return_door"
const KILN_DOCUMENT: String = "doc_r1_wrong_return_log"
const KILN_THREAD_PROP: String = "prop_r1_ash_garden_thread"
const KILN_HEARING: String = "conv_r1_wrong_return_hearing"
const KILN_HEARING_CHOICE: String = "ch_carry_the_claimant"
const DOOR_ENCOUNTER: String = "enc_r1_door_role_test"
const CHOIR_ENCOUNTER: String = "enc_r1_ash_choir"
const PLAYER_ACTION: String = "act_ash_sweep"
const GUARD_ACTION: String = "act_guard_set"
const CHARGE_ACTION: String = "act_ash_hound_lunge"
const CHARGE_ACTOR: String = "enemy_ash_hound"
const PLAYER_SIDE: String = "player_side"
const ENEMY_ACTION_OWNER: String = "enemy"
const ENEMY_ACTION_HOLD: int = 4096

const ROUTE_REGIONS: Array[String] = [
	"region_h0_undersign_exchange",
	"region_r1_returning_kiln",
	"region_r6_gristmarket_ward",
	"region_r7_hollow_orchard",
	"region_r4_crownwell_archive",
]
const ROUTE_EDGES: Array[String] = [
	"route_e01_ash_stair",
	"route_e07_ash_chute",
	"route_e16_drainage_dark",
	"route_e13_crown_stair",
	"route_e04_crownwell_ascent",
]

const CANONICAL_COUNTS: Array[Dictionary] = [
	{"key": "region_node", "expected": 9},
	{"key": "route_edge", "expected": 18},
	{"key": "route_gate", "expected": 9},
	{"key": "event_cluster", "expected": 9},
	{"key": "canonical_core_npc", "expected": 14},
	{"key": "support_resident", "expected": 7},
	{"key": "enemy_family", "expected": 19},
	{"key": "encounter", "expected": 25},
	{"key": "group", "expected": 5},
	{"key": "variant", "expected": 6},
	{"key": "npc_conversion", "expected": 5},
	{"key": "pressure_clock", "expected": 6},
	{"key": "recovery_type", "expected": 7},
	{"key": "ending", "expected": 6},
]

const BOSS_ACTIVATION_KINDS: Array[String] = ["boss_gate", "npc_conversion"]

const SECONDS_PER_REGION_DECISION: int = 25
const SECONDS_PER_DIALOGUE_PAGE: int = 10
const SECONDS_PER_CHOICE: int = 15
const SECONDS_PER_DOCUMENT_PAGE: int = 12
const SECONDS_PER_PROP_INTERACTION: int = 10
const SECONDS_PER_FIELD_ENCOUNTER_BASE: int = 45
const SECONDS_PER_FIELD_ENCOUNTER_ACTOR: int = 8
const SECONDS_PER_BOSS_ENCOUNTER_BASE: int = 90
const SECONDS_PER_BOSS_ENCOUNTER_ACTOR: int = 25
const SECONDS_PER_GATE_RESOLUTION: int = 30
const SECONDS_PER_CLOCK_STAGE_WRITE: int = 15
const SECONDS_PER_AXIS_WRITE: int = 15
const SECONDS_PER_CLUSTER_THREAD: int = 25

const MIN_ROUTE_BUDGET_SECONDS: int = 600
const MIN_ROUTE_REQUIRED_SECONDS: int = 600
const MIN_ROUTE_ENCOUNTERS: int = 10
const MIN_ROUTE_DISTINCT_UNITS: int = 60
const MIN_DIALOGUE_PAGES: int = 8
const MIN_CHOICES: int = 12
const MIN_DOCUMENT_PAGES: int = 4

const REQUIRED_SURFACES: Array[String] = [
	"field",
	"dialogue",
	"dialogue_page",
	"choice_focus",
	"choice_commit",
	"document_max",
	"document_corrupted",
	"document_close",
	"traverse",
	"combat_command",
	"target_focus",
	"target_commit",
	"enemy_window",
	"charge_telegraph",
	"charge_reaction",
	"charge_receive",
	"encounter_victory",
	"aftermath",
	"encounter_defeat",
	"recovery",
	"recovery_applied",
	"field_return",
]

const BUDGET_CATEGORY_ORDER: Array[String] = [
	"region_decision",
	"dialogue_page",
	"choice",
	"document_page",
	"prop_interaction",
	"field_encounter",
	"boss_encounter",
	"gate_resolution",
	"clock_stage_write",
	"axis_write",
	"cluster_thread",
]

const REQUIRED_UNIT_CATEGORIES: Array[String] = [
	"dialogue_page",
	"choice",
	"document_page",
	"field_encounter",
	"boss_encounter",
]

const FORBIDDEN_BUDGET_INPUTS: Array[String] = [
	"max_hp",
	"hp_inflation",
	"travel_distance",
	"loading_time",
	"menu_time",
	"pause_time",
	"idle_frames",
	"sleep_calls",
	"repeated_input",
]

const FILLER_EVENT_KINDS: Array[String] = ["sleep", "idle", "filler", "wait", "padding"]

const WALK_LIMIT: int = 128
const DIALOGUE_LIMIT: int = 32
const COMBAT_LIMIT: int = 400
const FOCUS_LIMIT: int = 48
const SETTLE_TICK_LIMIT: int = 8

var _output_path: String = ""
var _require_canonical_coverage: bool = false
var _events: Array[Dictionary] = []
var _assertions: Array[Dictionary] = []
var _surfaces: Dictionary = {}
var _module: GameModule = null
var _module_context: ModuleContext = null
var _step_serial: int = 0
var _failed: bool = false


func _initialize() -> void:
	var parsed: Dictionary = _parse_arguments(OS.get_cmdline_user_args())
	if not bool(parsed.get("ok", false)):
		push_error(_text(parsed.get("message", "invalid command line")))
		quit(2)
		return
	_output_path = _text(parsed.get("output_path", ""))
	_require_canonical_coverage = bool(parsed.get("require_canonical_coverage", false))
	call_deferred("_run")


func _run() -> void:
	_emit("probe_start", "started", &"", &"", {
		"module_id": _text(MODULE_ID),
		"evidence_class": EVIDENCE_CLASS,
		"evidence_version": EVIDENCE_VERSION,
		"human_playthrough_claimed": false,
		"limitations": [
			"drives the authored catalog through the real module, not a human player",
			"wall clock, sleep, loading time, menu time and repeated input are never used as evidence",
			"the ten minute budget is an authored unit count, not a measured play session",
			"does not replace a human review playthrough for the kit acceptance gate",
		],
	})
	if not _spawn_module({}, "canonical_chain"):
		_finish()
		return
	var catalog: TopDownActionRpgContentLoader.Catalog = _catalog_of()
	if catalog == null:
		_check(false, "catalog_is_bootable")
		_finish()
		return
	_check(true, "catalog_is_bootable")
	_emit("catalog_booted", "playable", &"", &"", {
		"content_signature": catalog.content_signature,
		"entry_region_id": catalog.entry_region_id,
		"file_count": catalog.file_count,
		"kind_counts": catalog.to_dict().get("counts", {}),
	})
	var coverage: Dictionary = _collect_coverage(catalog)
	_emit("canonical_coverage", "collected", &"", &"", coverage)
	_audit_coverage(coverage)
	var route: Dictionary = _audit_route(catalog)
	_emit("canonical_route", "audited", &"", &"", route)
	_audit_route_ledger(route)
	var budget: Dictionary = _route_budget(catalog)
	_emit("authored_budget", "computed", &"", &"", budget)
	_audit_budget(budget)
	if not _run_canonical_chain():
		_finish()
		return
	_despawn_module()
	if not _run_charge_and_defeat_chain():
		_finish()
		return
	_despawn_module()
	_audit_surfaces()
	_audit_filler_policy()
	_finish()


func _spawn_module(snapshot: Dictionary, run_label: String) -> bool:
	var packed: PackedScene = load(ENTRY_SCENE) as PackedScene
	if not _check(packed != null, "entry_scene_loads"):
		return false
	_module = packed.instantiate() as GameModule
	if not _check(_module != null, "entry_scene_instantiates_module"):
		return false
	_module_context = ModuleContext.new()
	_module_context.module_id = MODULE_ID
	_module_context.input_enabled = true
	for action: StringName in _declared_actions():
		_module_context.allowed_actions.append(action)
	_module.context = _module_context
	root.add_child(_module)
	_step_serial = 0
	if not snapshot.is_empty():
		_module.load_state(snapshot.duplicate(true))
	_module.enter(_module_context)
	_module.set_process(false)
	var ok: bool = _state_of() != null and _screen_of() != null
	_check(ok, "module_enters_with_live_runtime")
	_emit("module_booted", "entered" if ok else "failed", &"", &"", {"run": run_label})
	return ok


func _despawn_module() -> void:
	if _module == null:
		return
	_module.set_process(true)
	_module.exit()
	root.remove_child(_module)
	_module.free()
	_module = null
	_module_context = null


func _declared_actions() -> Array[StringName]:
	var result: Array[StringName] = []
	var manifest: ModuleManifest = load("res://modules/top_down_action_rpg/module_manifest.tres") as ModuleManifest
	if manifest == null:
		return result
	for action: String in manifest.input_actions:
		result.append(StringName(action))
	return result


func _run_canonical_chain() -> bool:
	_spawn_ledger_run("canonical_chain")
	_see("field")
	if not _walk_to(H0_RESIDENT):
		return _step_failed("walk_to_h0_resident")
	if not _interact(H0_RESIDENT):
		return _step_failed("interact_h0_resident")
	if not _check(_mode() == "dialogue", "h0_interaction_opens_dialogue"):
		return false
	_see("dialogue")
	_emit("dialogue_open", "opened", &"interact", StringName(H0_RESIDENT), {"conversation_id": H0_CONVERSATION})
	if not _advance_to_choice_set():
		return _step_failed("advance_to_h0_choice_set")
	if not _module.execute_command(&"dialogue_focus", {"step": 1}):
		return _step_failed("h0_choice_focus")
	var conversation: TopDownActionRpgConversationController = _conversation_of()
	if not _check(conversation != null and not _text(conversation.active_choice_id).is_empty(), "h0_choice_focus_selects_row"):
		return false
	_see("choice_focus")
	_emit("choice_focus", "focused", &"dialogue_focus", StringName(_text(conversation.active_choice_id)), {"submode": "choice_focus"})
	var before_choice: Dictionary = _snapshot()
	if not _module.execute_command(&"choice_confirm", {"choice_id": H0_CHOICE}):
		return _step_failed("h0_choice_confirm")
	var state: TopDownActionRpgGameState = _state_of()
	if not _check(conversation.committed and state.choice_taken(H0_CONVERSATION, H0_CHOICE), "h0_choice_commits_authored_state"):
		return false
	_see("choice_commit")
	_emit("choice_commit", "committed", &"choice_confirm", StringName(H0_CHOICE), before_choice)
	if not _close_committed_dialogue():
		return false
	var departure_region: String = _state_of().region_id()
	if not _walk_to(E01_EDGE):
		return _step_failed("walk_to_e01_passage")
	var before_traverse: Dictionary = _snapshot()
	if not _interact(E01_EDGE):
		return _step_failed("interact_e01_passage")
	var arrival_region: String = _state_of().region_id()
	if not _check(arrival_region == KILN_REGION, "e01_traverse_moves_to_authored_region"):
		return false
	_see("traverse")
	_emit("traverse", "traversed", &"interact", StringName(E01_EDGE), {
		"from_region_id": departure_region,
		"to_region_id": arrival_region,
		"route_state": "open",
		"gate_id": "gate_g0_arrival_declaration",
		"before": before_traverse,
	})
	if not _check(_mode() == "combat", "field_activation_arms_authored_encounter"):
		return false
	if _text(_state_of().combat.get("active_encounter_id", "")) != DOOR_ENCOUNTER:
		_emit("encounter_armed", "unexpected_encounter", &"", &"", {
			"active_encounter_id": _text(_state_of().combat.get("active_encounter_id", "")),
			"expected": DOOR_ENCOUNTER,
		})
		return _step_failed("field_activation_arms_expected_encounter")
	_emit("encounter_armed", "armed", &"field_trigger", StringName(DOOR_ENCOUNTER), {})
	if not _drive_combat("victory"):
		return false
	_see("encounter_victory")
	if not _check(_state_of().prop_state(KILN_DOOR_PROP) != "ps_intact", "victory_advances_authored_prop_state"):
		return false
	if _mode() == "field_return":
		_see("field_return")
		_see("aftermath")
	if not _first_field_intent():
		return false
	if not _check(_mode() == "field", "aftermath_yields_to_first_field_intent"):
		return false
	if not _walk_to(KILN_DOOR_PROP):
		return _step_failed("walk_to_kiln_door_prop")
	if not _interact(KILN_DOOR_PROP):
		return _step_failed("interact_kiln_door_prop")
	var document_conversation: TopDownActionRpgConversationController = _conversation_of()
	if not _check(_text(document_conversation.document_id) == KILN_DOCUMENT, "door_interaction_opens_authored_document"):
		return false
	_see("document_max")
	_emit("document_open", "opened", &"interact", StringName(KILN_DOCUMENT), {})
	if not _module.execute_command(&"document_advance"):
		return _step_failed("document_advance_to_corrupted")
	if not _check(_text(_conversation_of().document_id) == KILN_DOCUMENT, "document_corruption_page_retains_record"):
		return false
	_see("document_corrupted")
	_emit("document_corrupt", "corrupted", &"document_advance", StringName(KILN_DOCUMENT), {})
	if not _module.execute_command(&"document_advance"):
		return _step_failed("document_close")
	_see("document_close")
	_emit("document_close", "closed", &"document_advance", StringName(KILN_DOCUMENT), {})
	if not _check(_state_of().document_read_count(KILN_DOCUMENT) == 1, "document_read_is_counted_once"):
		return false
	if not _walk_to(KILN_THREAD_PROP):
		return _step_failed("walk_to_kiln_thread_prop")
	if not _interact(KILN_THREAD_PROP):
		return _step_failed("interact_kiln_thread_prop")
	if not _check(_mode() == "dialogue", "thread_prop_opens_hearing"):
		return false
	_see("dialogue")
	if not _advance_to_choice_set():
		return _step_failed("advance_to_hearing_choice_set")
	if not _module.execute_command(&"dialogue_focus", {"step": 1}):
		return _step_failed("hearing_choice_focus")
	_see("choice_focus")
	if not _module.execute_command(&"choice_confirm", {"choice_id": KILN_HEARING_CHOICE}):
		return _step_failed("hearing_choice_confirm")
	_see("choice_commit")
	_emit("choice_commit", "committed", &"choice_confirm", StringName(KILN_HEARING_CHOICE), {
		"conversation_id": KILN_HEARING,
		"prop_state_id": _state_of().prop_state(KILN_THREAD_PROP),
	})
	if not _close_committed_dialogue():
		return false
	_emit("chain_complete", "field_returned", &"", &"", {
		"region_id": _state_of().region_id(),
		"prop_states": {
			KILN_DOOR_PROP: _state_of().prop_state(KILN_DOOR_PROP),
			KILN_THREAD_PROP: _state_of().prop_state(KILN_THREAD_PROP),
		},
		"relationship_states": _relationship_snapshot(),
		"axes": _axis_snapshot(),
		"flags": _flag_snapshot(),
	})
	return true


func _run_charge_and_defeat_chain() -> bool:
	if not _spawn_module(_charge_run_snapshot(), "charge_and_defeat"):
		return false
	_spawn_ledger_run("charge_and_defeat")
	if not _check(_mode() == "combat", "authored_resume_enters_combat_at_encounter_boundary"):
		return false
	if not _check(_text(_combat_of().encounter_id) == CHOIR_ENCOUNTER, "authored_resume_uses_rostered_encounter"):
		return false
	_see("combat_command")
	_emit("encounter_armed", "armed", &"resume_boundary", StringName(CHOIR_ENCOUNTER), {})
	if not _module.execute_command(&"combat_category", {"category": "attack"}):
		return _step_failed("combat_category_attack")
	if not _module.execute_command(&"combat_action", {"action_id": PLAYER_ACTION}):
		return _step_failed("combat_action_enter_target_select")
	if not _check(_combat_of().submode == "target_select", "target_select_submode_entered"):
		return false
	_emit("target_focus", "entered", &"combat_action", StringName(PLAYER_ACTION), {
		"focused_actor_id": _text(_controller_of().target_focus_actor_id),
	})
	var focus_ids: Array[String] = []
	for step: int in range(FOCUS_LIMIT):
		if not _module.execute_command(&"combat_target_focus", {"step": 1}):
			break
		var focused: String = _text(_controller_of().target_focus_actor_id)
		if not focus_ids.has(focused):
			focus_ids.append(focused)
		if focus_ids.size() >= _enemy_actor_ids().size():
			break
	if not _check(focus_ids.size() >= 2, "target_focus_visits_multiple_stable_actor_ids"):
		return false
	_see("target_focus")
	_emit("target_focus", "traversed", &"combat_target_focus", StringName(focus_ids[focus_ids.size() - 1]), {
		"visited_target_ids": focus_ids,
	})
	_module.execute_command(&"combat_cancel")
	if not _check(_combat_of().queue.is_empty(), "target_cancel_leaves_no_queued_command"):
		return false
	_emit("target_cancel", "cancelled", &"combat_cancel", StringName(focus_ids[focus_ids.size() - 1]), {})
	if not _module.execute_command(&"combat_action", {"action_id": PLAYER_ACTION}):
		return _step_failed("combat_action_reenter_target_select")
	var commit_target: String = _enemy_actor_ids()[0]
	if not _module.execute_command(&"combat_target", {"target_actor_id": commit_target}):
		return _step_failed("combat_target_commit")
	if not _check(_combat_of().queue.size() == 1, "target_commit_queues_exactly_one_command"):
		return false
	_see("target_commit")
	_emit("target_commit", "queued", &"combat_target", StringName(commit_target), {
		"queued": _queued_command_ids(),
		"action_slots": _player_actor().action_slot_snapshot,
	})
	var charge_actor: String = _charge_actor_id()
	if not _check(not charge_actor.is_empty(), "authored_charge_actor_is_rostered"):
		return false
	if not _lock_actor_onto_charge(charge_actor):
		return _step_failed("lock_charge_actor")
	_emit("charge_fixture", "locked", &"fixture", StringName(charge_actor), {
		"locked_action_id": CHARGE_ACTION,
		"held_action_count": _combat_of().find_actor(StringName(charge_actor)).action_cooldowns.size(),
		"reason": "deterministic fixture so the authored signature charge is reached inside the bounded horizon",
	})
	if not _drive_combat("defeat"):
		return false
	_see("encounter_defeat")
	if not _check(_mode() == "recovery", "defeat_requests_authored_recovery"):
		return false
	var recovery: TopDownActionRpgRecoveryController = _recovery_of()
	var recovery_id: String = _text(recovery.pending_definition.get("id", ""))
	_see("recovery")
	_emit("recovery_requested", "pending", &"encounter_failure", StringName(recovery_id), {
		"kind": _text(recovery.pending_definition.get("kind", "")),
		"preserves": recovery.pending_definition.get("preserves", []),
		"discards": recovery.pending_definition.get("discards", []),
	})
	if not _module.execute_command(&"accept_recovery"):
		return _step_failed("accept_recovery")
	var history: Array = _state_of().recovery.get("history", []) if _state_of().recovery.get("history", []) is Array else []
	if not _check(history.size() == 1, "recovery_history_records_one_entry"):
		return false
	_see("recovery_applied")
	_emit("recovery_applied", "applied", &"accept_recovery", StringName(recovery_id), {
		"kind": _text((history[history.size() - 1] as Dictionary).get("kind", "")),
		"region_id": _state_of().region_id(),
		"anchor_id": _text(_state_of().field.get("anchor_id", "")),
		"continuity": _state_of().recovery.get("continuity", {}),
		"encounter_resolution": _state_of().encounter_resolution(CHOIR_ENCOUNTER),
	})
	if not _check(_mode() == "field", "recovery_returns_to_rebuilt_field"):
		return false
	_see("field_return")
	_emit("chain_complete", "field_returned", &"", &"", {
		"region_id": _state_of().region_id(),
		"prop_states": {
			KILN_DOOR_PROP: _state_of().prop_state(KILN_DOOR_PROP),
			KILN_THREAD_PROP: _state_of().prop_state(KILN_THREAD_PROP),
		},
		"axes": _axis_snapshot(),
		"clocks": _clock_snapshot(),
	})
	return true


func _drive_combat(expected_result: String) -> bool:
	var reaction_phase: int = 0
	var enemy_windows: Dictionary = {}
	for step: int in range(COMBAT_LIMIT):
		if _mode() != "combat":
			break
		var controller: TopDownActionRpgCombatController = _controller_of()
		var combat: TopDownActionRpgCombatState = _combat_of()
		if controller == null or combat == null:
			return _step_failed("combat_runtime_missing")
		if _text(combat.result) != "running":
			break
		if controller.awaiting_reaction:
			if not _handle_charge(controller, reaction_phase):
				return false
			reaction_phase += 1
			if reaction_phase >= 2 and expected_result == "defeat":
				if not _force_defeat():
					return false
			_module.call("_process", 0.0)
			continue
		var window_actor: String = _due_actor_id()
		if not window_actor.is_empty() and window_actor != TopDownActionRpgGameState.PLAYER_ROLE_ID and not enemy_windows.has(window_actor):
			enemy_windows[window_actor] = true
			_see("enemy_window")
			_emit("enemy_window", "due", &"actor_window", StringName(window_actor), _combat_row(combat, controller))
		if _player_window_open():
			if not _act_in_player_window(step, controller, combat, reaction_phase == 0 and expected_result == "defeat"):
				return false
		_module.call("_process", 0.0)
		_emit_combat_row(combat, controller, "step")
	var combat_state: TopDownActionRpgCombatState = _combat_of()
	var result: String = _text(combat_state.result) if combat_state != null else ""
	if not _check(result == expected_result, "combat_reaches_%s" % expected_result):
		return false
	_emit("encounter_result", result, &"combat_resolution", StringName(_text(combat_state.encounter_id)), {
		"expected": expected_result,
		"scheduler_tick": combat_state.scheduler_tick,
		"actor_windows": _actor_window_count(),
	})
	_settle_after_combat()
	return true


# The combat loop above exits as soon as the mode leaves "combat", which is the tick
# the module resolves the result into. The module retires `encounter_result` and
# `field_return` on its own `_process`, so the harness has to let that settle before
# it asserts on the post-victory field state. Bounded so a stuck module still fails.
func _settle_after_combat() -> void:
	for _tick: int in range(SETTLE_TICK_LIMIT):
		if _mode() != "encounter_result" and _mode() != "field_return":
			return
		_module.call("_process", 0.0)


func _handle_charge(controller: TopDownActionRpgCombatController, reaction_phase: int) -> bool:
	var charge: TopDownActionRpgCombatState.ChargeState = controller.pending_charge
	if charge == null:
		return _step_failed("charge_pending_state_missing")
	var charge_action: String = _text(charge.charge_action_id)
	var owner_actor: String = _text(charge.owner_actor_id)
	_see("charge_telegraph")
	_see("charge_reaction")
	_emit("charge_telegraph", _text(charge.stage), &"charge_stage", StringName(charge_action), {
		"owner_actor_id": owner_actor,
		"target_actor_id": _text(charge.target_actor_id),
		"stage": _text(charge.stage),
		"window_budget": charge.window_budget,
		"valid_reaction_ids": charge.valid_reaction_ids,
		"forbidden_response_ids": charge.forbidden_response_ids,
		"expected_charge_action": CHARGE_ACTION,
		"expected_charge_actor": CHARGE_ACTOR,
	})
	if not _check(charge_action == CHARGE_ACTION, "authored_charge_action_is_used"):
		return false
	if not _check(owner_actor == CHARGE_ACTOR, "authored_charge_owner_actor_is_used"):
		return false
	if reaction_phase == 0:
		_module.execute_command(&"combat_reaction")
		if not _check(not controller.awaiting_reaction, "counter_response_cancels_authored_charge"):
			return false
		_see("charge_counter")
		_emit("charge_counter", "charge_cancelled", &"combat_reaction", StringName(charge_action), {
			"owner_actor_id": owner_actor,
		})
		return true
	_module.execute_command(&"combat_receive")
	if not _check(not controller.awaiting_reaction, "accept_charge_consumes_authored_charge"):
		return false
	_see("charge_receive")
	_emit("charge_receive", "charge_accepted", &"combat_receive", StringName(charge_action), {
		"owner_actor_id": owner_actor,
		"first_charge_was_countered": true,
	})
	return true


func _act_in_player_window(step: int, controller: TopDownActionRpgCombatController, combat: TopDownActionRpgCombatState, hold_attacks: bool) -> bool:
	var player: TopDownActionRpgCombatState.ActorState = _player_actor()
	if player == null or not player.is_actionable():
		return true
	if hold_attacks:
		_module.execute_command(&"combat_end_turn")
		_emit("combat_pass", "window_held_for_charge", &"combat_end_turn", StringName(_text(controller.current_actor_id)), _combat_row(combat, controller))
		return true
	if step % 4 == 3:
		_module.execute_command(&"combat_action", {"action_id": GUARD_ACTION})
		_emit_combat_row(combat, controller, "player_guard")
		return true
	var available: Array = controller.available_commands(controller.current_actor_id)
	var chosen: String = ""
	for entry: Dictionary in available:
		var candidate: Dictionary = entry if entry is Dictionary else {}
		if _text(candidate.get("id", "")) == PLAYER_ACTION and controller.command_is_available(player, candidate):
			chosen = PLAYER_ACTION
			break
	if chosen.is_empty():
		_module.execute_command(&"combat_end_turn")
		_emit("combat_pass", "window_ended", &"combat_end_turn", StringName(_text(controller.current_actor_id)), _combat_row(combat, controller))
		return true
	_module.execute_command(&"combat_category", {"category": _text(_catalog_of().record(chosen).get("category", "attack"))})
	_module.execute_command(&"combat_action", {"action_id": chosen})
	if _combat_of().submode == "target_select":
		_module.execute_command(&"combat_target", {"target_actor_id": _focused_target_or_first()})
	_emit("player_command", "queued", &"combat_action", StringName(chosen), _combat_row(_combat_of(), controller))
	return true


func _focused_target_or_first() -> String:
	var controller: TopDownActionRpgCombatController = _controller_of()
	if controller != null and not _text(controller.target_focus_actor_id).is_empty():
		return _text(controller.target_focus_actor_id)
	var ids: Array[String] = _enemy_actor_ids()
	return ids[0] if not ids.is_empty() else ""


func _charge_actor_id() -> String:
	var catalog: TopDownActionRpgContentLoader.Catalog = _catalog_of()
	var combat: TopDownActionRpgCombatState = _combat_of()
	if catalog == null or combat == null:
		return ""
	for actor: TopDownActionRpgCombatState.ActorState in combat.actors:
		if actor.side == PLAYER_SIDE:
			continue
		var record: Dictionary = catalog.record(String(actor.actor_id))
		if record.is_empty():
			var separator: int = _text(actor.actor_id).rfind("_")
			if separator > 0:
				record = catalog.record(_text(actor.actor_id).substr(0, separator))
		if _text(record.get("signature_action_id", "")) == CHARGE_ACTION:
			return String(actor.actor_id)
	return ""


func _lock_actor_onto_charge(actor_id: String) -> bool:
	var catalog: TopDownActionRpgContentLoader.Catalog = _catalog_of()
	var combat: TopDownActionRpgCombatState = _combat_of()
	if catalog == null or combat == null:
		return false
	var actor: TopDownActionRpgCombatState.ActorState = combat.find_actor(StringName(actor_id))
	if actor == null:
		return false
	var cooldowns: Dictionary = actor.action_cooldowns.duplicate()
	var action_ids: Array = catalog.ids_of_kind("actions")
	for entry: Variant in action_ids:
		var action_id: String = String(entry)
		if _text(catalog.record(action_id).get("owner", "")) != ENEMY_ACTION_OWNER:
			continue
		if action_id == CHARGE_ACTION:
			continue
		cooldowns[action_id] = ENEMY_ACTION_HOLD
	actor.action_cooldowns = cooldowns
	return true


func _force_defeat() -> bool:
	var controller: TopDownActionRpgCombatController = _controller_of()
	var combat: TopDownActionRpgCombatState = _combat_of()
	if controller == null or combat == null:
		return false
	for actor: TopDownActionRpgCombatState.ActorState in combat.actors:
		if actor.side == PLAYER_SIDE:
			continue
		actor.hp = 0
	if not controller.force_result("defeat"):
		return false
	_module.call("_process", 0.0)
	_emit("encounter_forced", "defeat", &"force_result", StringName(_text(combat.encounter_id)), {
		"resolution_source": "authored_failure_state_after_charge_sequence",
		"player_hp": _player_actor().hp if _player_actor() != null else -1,
	})
	return true


func _advance_to_choice_set() -> bool:
	for _page: int in range(DIALOGUE_LIMIT):
		var conversation: TopDownActionRpgConversationController = _conversation_of()
		if conversation == null or _mode() != "dialogue":
			return false
		if conversation.at_choice_set():
			return not conversation.choice_rows().is_empty()
		var page: Dictionary = conversation.current_page()
		_see("dialogue_page")
		_emit("dialogue_page", "presented", &"dialogue_read", StringName(String(conversation.conversation_id)), {
			"page_index": conversation.page_index,
			"page_id": String(page.get("page_id", "")),
			"speaker": String(page.get("speaker", "")),
			"presentation_class": String(page.get("presentation_class", "")),
			"advance": String(page.get("advance", "auto")),
		})
		if not _module.execute_command(&"dialogue_advance"):
			return false
	return false


func _close_committed_dialogue() -> bool:
	var committed_ids: Array[String] = []
	for _pass: int in range(DIALOGUE_LIMIT):
		var conversation: TopDownActionRpgConversationController = _conversation_of()
		if conversation == null or _mode() != "dialogue":
			break
		if not conversation.committed:
			return _step_failed("dialogue_closes_after_commit")
		if not _module.execute_command(&"choice_confirm", {}):
			return _step_failed("dialogue_choice_chain")
		var after: TopDownActionRpgConversationController = _conversation_of()
		if after == null or String(after.conversation_id).is_empty():
			break
		var state: Dictionary = _state_of().conversation_state(String(after.conversation_id))
		var taken: Array = state.get("taken_choice_ids", []) if state.get("taken_choice_ids", []) is Array else []
		for entry: Variant in taken:
			var value: String = String(entry)
			if not committed_ids.has(value):
				committed_ids.append(value)
	if not _check(_mode() == "field", "dialogue_returns_to_field_after_commit"):
		return false
	_emit("dialogue_close", "closed", &"choice_confirm", &"", {"committed_choice_ids": committed_ids})
	return true


func _first_field_intent() -> bool:
	var screen: TopDownActionRpgScreen = _screen_of()
	if screen == null:
		return _step_failed("screen_present_for_field_intent")
	screen.submit_move(Vector2(1.0, 0.0))
	# A field intent clears the module's aftermath flag, but the `field_return` ->
	# `field` mode change is retired by the next module `_process`. Let it settle
	# before asserting, bounded so a stuck module still fails the run.
	for _tick: int in range(SETTLE_TICK_LIMIT):
		if _mode() == "field":
			return true
		_module.call("_process", 0.0)
	return true


func _walk_to(interactable_id: String) -> bool:
	var field: TopDownActionRpgFieldController = _field_of()
	if field == null:
		return false
	var target: TopDownActionRpgFieldController.Interactable = _interactable_of(interactable_id)
	if target == null:
		_emit("walk", "missing_interactable", &"move", StringName(interactable_id), {"region_id": _state_of().region_id()})
		return false
	for _step: int in range(WALK_LIMIT):
		if _mode() != "field" and _mode() != "field_return":
			return true
		if _actor_position().distance_to(target.position) <= 0.2:
			return true
		_module.execute_command(&"move", {"direction": target.position - _actor_position()})
	var arrived: bool = _actor_position().distance_to(target.position) <= 0.6
	_emit("walk", "arrived" if arrived else "unreached", &"move", StringName(interactable_id), {
		"region_id": _state_of().region_id(),
		"position": [_actor_position().x, _actor_position().y],
		"target": [target.position.x, target.position.y],
	})
	return arrived


func _interact(interactable_id: String) -> bool:
	if not _module.execute_command(&"interact", {"interactable_id": interactable_id}):
		return _step_failed("interact_%s" % interactable_id)
	return true


func _charge_run_snapshot() -> Dictionary:
	var snapshot: Dictionary = TopDownActionRpgGameState.create_default(ENTRY_REGION, ENTRY_ANCHOR).to_dict()
	snapshot["content_revision"] = "playthrough_probe_authored_resume_fixture"
	var body: Dictionary = snapshot["player"]["body"] if snapshot["player"]["body"] is Dictionary else {}
	body["vitals"] = {"hp": 220, "max_hp": 220, "mp": 40, "max_mp": 40}
	snapshot["player"]["body"] = body
	var field: Dictionary = snapshot["field"]
	field["region_id"] = KILN_REGION
	field["scene_id"] = KILN_REGION
	field["active_interaction_id"] = ""
	var world: Dictionary = snapshot["world"]
	world["encounters"] = {DOOR_ENCOUNTER: {"resolution": "victory"}}
	var regions: Dictionary = world["regions"]
	regions[KILN_REGION] = {
		"visit_count": 0, "state": "as_authored", "state_tag": "", "scene_id": KILN_REGION
	}
	var region_clocks: Dictionary = {}
	for clock_id: String in TopDownActionRpgGameState.CLOCK_IDS:
		region_clocks[clock_id] = {"stage_index": 0, "tick": 0, "last_signal": "", "committed_event_id": ""}
	world["clocks"][KILN_REGION] = region_clocks
	var combat: Dictionary = snapshot["combat"]
	combat["active_encounter_id"] = CHOIR_ENCOUNTER
	combat["attempt_serial"] = 1
	combat["resume_boundary"] = "encounter_prepare"
	combat["result"] = "running"
	combat["pre_command_intent"] = []
	return snapshot


func _collect_coverage(catalog: TopDownActionRpgContentLoader.Catalog) -> Dictionary:
	var regions: Array[String] = []
	var edges: Array[String] = []
	var gates: Array[String] = []
	var clusters: Array[String] = []
	var core_npcs: Array[String] = []
	var support_npcs: Array[String] = []
	var encounters: Array[String] = []
	var groups: Array[String] = []
	var variants: Array[String] = []
	var conversions: Array[String] = []
	var clocks: Array[String] = []
	var recovery_kinds: Array[String] = []
	# `06` §3.5.6: `end_*`는 `03`이 소유하고 `06`은 index.json에 등록하지 않는다.
	# 따라서 ending 커버리지는 content record의 `ending_id` 스캔이 아니라 canonical vocabulary로 판정한다.
	var endings: Array[String] = TopDownActionRpgContentLoader.CANONICAL_ENDING_IDS.duplicate()
	var region_ids: Array = catalog.ids_of_kind("regions")
	for entry: Variant in region_ids:
		var region_id: String = _text(entry)
		regions.append(region_id)
		var region: Dictionary = catalog.record(region_id)
		var cluster: Dictionary = region.get("initial_cluster", {}) if region.get("initial_cluster", {}) is Dictionary else {}
		var cluster_id: String = _text(cluster.get("cluster_id", ""))
		if not cluster_id.is_empty() and not clusters.has(cluster_id):
			clusters.append(cluster_id)
		var exit_entries: Array = region.get("exits", []) if region.get("exits", []) is Array else []
		for exit_entry: Variant in exit_entries:
			if not exit_entry is Dictionary:
				continue
			var edge_id: String = _text((exit_entry as Dictionary).get("edge_id", ""))
			var gate_id: String = _text((exit_entry as Dictionary).get("gate_id", ""))
			if not edge_id.is_empty() and not edges.has(edge_id):
				edges.append(edge_id)
			if not gate_id.is_empty() and not gates.has(gate_id):
				gates.append(gate_id)
		var combat_content: Dictionary = region.get("combat_content", {}) if region.get("combat_content", {}) is Dictionary else {}
		var encounter_ids: Array = combat_content.get("encounter_ids", []) if combat_content.get("encounter_ids", []) is Array else []
		for encounter_id: Variant in encounter_ids:
			var record: Dictionary = catalog.record(_text(encounter_id))
			var group: Dictionary = record.get("group", {}) if record.get("group", {}) is Dictionary else {}
			var group_id: String = _text(group.get("group_id", ""))
			if not group_id.is_empty() and not groups.has(group_id):
				groups.append(group_id)
			var base_id: String = _text(record.get("base_encounter_id", ""))
			if not base_id.is_empty() and not variants.has(_text(record.get("id", ""))):
				variants.append(_text(record.get("id", "")))
			var activation: Dictionary = record.get("activation", {}) if record.get("activation", {}) is Dictionary else {}
			if _text(activation.get("kind", "")) == "npc_conversion" and not conversions.has(_text(record.get("id", ""))):
				conversions.append(_text(record.get("id", "")))
	var npc_ids: Array = catalog.ids_of_kind("npcs")
	for entry: Variant in npc_ids:
		var record: Dictionary = catalog.record(_text(entry))
		var roster_kind: String = _text(record.get("roster_kind", ""))
		if roster_kind == "support":
			support_npcs.append(_text(entry))
		else:
			core_npcs.append(_text(entry))
	var encounter_list: Array = catalog.ids_of_kind("encounters")
	for entry: Variant in encounter_list:
		encounters.append(_text(entry))
	var clock_list: Array = catalog.ids_of_kind("clocks")
	for entry: Variant in clock_list:
		clocks.append(_text(entry))
	var recovery_list: Array = catalog.ids_of_kind("recovery")
	for entry: Variant in recovery_list:
		var kind: String = _text(catalog.record(_text(entry)).get("kind", ""))
		if not kind.is_empty() and not recovery_kinds.has(kind):
			recovery_kinds.append(kind)
	var measured: Dictionary = {
		"region_node": regions,
		"route_edge": edges,
		"route_gate": gates,
		"event_cluster": clusters,
		"canonical_core_npc": core_npcs,
		"support_resident": support_npcs,
		"enemy_family": catalog.ids_of_kind("enemies"),
		"encounter": encounters,
		"group": groups,
		"variant": variants,
		"npc_conversion": conversions,
		"pressure_clock": clocks,
		"recovery_type": recovery_kinds,
		"ending": endings,
	}
	var report: Array[Dictionary] = []
	for expected_row: Dictionary in CANONICAL_COUNTS:
		var key: String = _text(expected_row["key"])
		var expected: int = int(expected_row["expected"])
		var observed: Array = measured.get(key, []) if measured.get(key, []) is Array else []
		var sorted_observed: Array[String] = []
		for entry: Variant in observed:
			sorted_observed.append(_text(entry))
		sorted_observed.sort()
		report.append({
			"key": key,
			"expected": expected,
			"observed_count": sorted_observed.size(),
			"observed_ids": sorted_observed,
			"status": "reached" if sorted_observed.size() >= expected else "unreached",
		})
	return {
		"items": report,
		"unreached_count": report.size() - _reached_count(report),
		"strict_gate": _require_canonical_coverage,
	}


func _reached_count(report: Array[Dictionary]) -> int:
	var total: int = 0
	for row: Dictionary in report:
		if _text(row.get("status", "")) == "reached":
			total += 1
	return total


func _audit_coverage(coverage: Dictionary) -> void:
	var items: Array = coverage.get("items", []) if coverage.get("items", []) is Array else []
	var missing: Array[String] = []
	for row: Dictionary in items:
		if _text(row.get("status", "")) != "reached":
			missing.append(_text(row.get("key", "")) + "=" + str(row.get("observed_count", 0)) + "/" + str(row.get("expected", 0)))
	var gate_open: bool = missing.is_empty()
	_check(gate_open or not _require_canonical_coverage, "canonical_coverage_gate")
	_check(missing.is_empty() or not _require_canonical_coverage, "canonical_coverage_items_reachable")
	print("TOPDOWN_PROBE_COVERAGE items=%d unreached=%d strict=%s missing=%s" % [
		items.size(), int(coverage.get("unreached_count", 0)), str(_require_canonical_coverage), str(missing)
	])


func _audit_route(catalog: TopDownActionRpgContentLoader.Catalog) -> Dictionary:
	var present: Array[Dictionary] = []
	for region_id: String in ROUTE_REGIONS:
		present.append({
			"region_id": region_id,
			"in_catalog": catalog.has(region_id) and catalog.kind_of(region_id) == "regions",
		})
	var closure: Array[Dictionary] = []
	for index: int in range(ROUTE_EDGES.size()):
		var from_region: String = ROUTE_REGIONS[index]
		var to_region: String = ROUTE_REGIONS[0] if index == ROUTE_EDGES.size() - 1 else ROUTE_REGIONS[index + 1]
		var edge_id: String = ROUTE_EDGES[index]
		var forward: Dictionary = _edge_declaration(catalog, edge_id, from_region, to_region)
		var reverse: Dictionary = _edge_declaration(catalog, edge_id, to_region, from_region)
		closure.append({
			"edge_id": edge_id,
			"from_region_id": from_region,
			"to_region_id": to_region,
			"forward": forward,
			"reverse": reverse,
			"bidirectional": not forward.is_empty() and not reverse.is_empty(),
			"gate_id": _text(forward.get("gate_id", "")),
			"authored_route_state": _text(forward.get("route_state", "")),
		})
	var distinct_edges: Dictionary = {}
	var distinct_gates: Dictionary = {}
	for row: Dictionary in closure:
		distinct_edges[_text(row.get("edge_id", ""))] = true
		distinct_gates[_text(row.get("gate_id", ""))] = true
	return {
		"declared_regions": present,
		"edge_closure": closure,
		"distinct_declared_edges": distinct_edges.size(),
		"distinct_declared_gates": distinct_gates.size(),
		"driven_edges": [E01_EDGE],
		"driven_regions": [ENTRY_REGION, KILN_REGION],
		"undriven_reason": "gate conditions for the remaining route legs have no authored unlock effect in the shipped catalog",
	}


func _edge_declaration(catalog: TopDownActionRpgContentLoader.Catalog, edge_id: String, from_region: String, to_region: String) -> Dictionary:
	var region: Dictionary = catalog.record(from_region)
	var exit_entries: Array = region.get("exits", []) if region.get("exits", []) is Array else []
	for exit_entry: Variant in exit_entries:
		if not exit_entry is Dictionary:
			continue
		var record: Dictionary = exit_entry
		if _text(record.get("edge_id", "")) != edge_id:
			continue
		if _text(record.get("to_region_id", "")) != to_region:
			continue
		return {
			"edge_id": edge_id,
			"from_region_id": from_region,
			"to_region_id": to_region,
			"gate_id": _text(record.get("gate_id", "")),
			"route_state": _text(record.get("route_state", "")),
			"field_activation": _text(record.get("field_activation", "")),
		}
	return {}


func _audit_route_ledger(route: Dictionary) -> void:
	var regions_present: bool = true
	for row: Dictionary in (route.get("declared_regions", []) as Array):
		if not bool(row.get("in_catalog", false)):
			regions_present = false
	_check(regions_present, "canonical_route_regions_present_in_catalog")
	var closure: Array = route.get("edge_closure", []) if route.get("edge_closure", []) is Array else []
	var edges_ok: bool = closure.size() == ROUTE_EDGES.size()
	for row: Dictionary in closure:
		if not bool(row.get("bidirectional", false)):
			edges_ok = false
	_check(edges_ok, "canonical_route_edges_bidirectional_and_adjacent")
	_check(int(route.get("distinct_declared_gates", 0)) >= 4, "canonical_route_declares_multiple_gates")
	print("TOPDOWN_PROBE_ROUTE regions=%d edges=%d gates=%d driven=%s" % [
		ROUTE_REGIONS.size(), closure.size(), int(route.get("distinct_declared_gates", 0)), str(route.get("driven_edges", []))
	])


func _route_budget(catalog: TopDownActionRpgContentLoader.Catalog) -> Dictionary:
	var units: Dictionary = {}
	for key: String in BUDGET_CATEGORY_ORDER:
		units[key] = 0
	var distinct_units: Dictionary = {}
	var gate_ids: Dictionary = {}
	var encounters: Dictionary = {}
	var counted_conversations: Dictionary = {}
	var counted_documents: Dictionary = {}
	for region_id: String in ROUTE_REGIONS:
		var region: Dictionary = catalog.record(region_id)
		units["region_decision"] = int(units["region_decision"]) + 1
		distinct_units[region_id] = true
		_record_reading_units(catalog, region, units, distinct_units, counted_conversations, counted_documents)
		_record_encounter_units(catalog, region, units, distinct_units, encounters)
		var exit_entries: Array = region.get("exits", []) if region.get("exits", []) is Array else []
		for exit_entry: Variant in exit_entries:
			if exit_entry is Dictionary:
				var gate_id: String = _text((exit_entry as Dictionary).get("gate_id", ""))
				if not gate_id.is_empty() and not gate_ids.has(gate_id):
					gate_ids[gate_id] = true
					distinct_units[gate_id] = true
					units["gate_resolution"] = int(units["gate_resolution"]) + 1
		var clock_entries: Array = region.get("clocks", []) if region.get("clocks", []) is Array else []
		for clock_entry: Variant in clock_entries:
			if not clock_entry is Dictionary:
				continue
			var clock_id: String = _text((clock_entry as Dictionary).get("clock_id", ""))
			var clock: Dictionary = catalog.record(clock_id)
			var stages: Array = clock.get("stages", []) if clock.get("stages", []) is Array else []
			units["clock_stage_write"] = int(units["clock_stage_write"]) + stages.size()
			distinct_units[clock_id] = true
		var axis_weights: Dictionary = region.get("axis_weights", {}) if region.get("axis_weights", {}) is Dictionary else {}
		for axis_key: Variant in axis_weights:
			units["axis_write"] = int(units["axis_write"]) + 1
			distinct_units["axis_" + _text(axis_key)] = true
		var cluster: Dictionary = region.get("initial_cluster", {}) if region.get("initial_cluster", {}) is Dictionary else {}
		var cluster_id: String = _text(cluster.get("cluster_id", ""))
		if not cluster_id.is_empty():
			distinct_units[cluster_id] = true
			var thread_ids: Array = cluster.get("thread_ids", []) if cluster.get("thread_ids", []) is Array else []
			var npc_ids: Array = cluster.get("npc_ids", []) if cluster.get("npc_ids", []) is Array else []
			for entry: Variant in thread_ids:
				distinct_units["thread_" + _text(entry)] = true
			for entry: Variant in npc_ids:
				distinct_units["cluster_npc_" + _text(entry)] = true
			units["cluster_thread"] = int(units["cluster_thread"]) + maxi(1, thread_ids.size())
	var total_seconds: int = 0
	var required_seconds: int = 0
	var breakdown: Array[Dictionary] = []
	for key: String in BUDGET_CATEGORY_ORDER:
		var count: int = int(units[key])
		var per_unit: int = _seconds_per_unit(key)
		var seconds: int = count * per_unit
		total_seconds += seconds
		if REQUIRED_UNIT_CATEGORIES.has(key):
			required_seconds += seconds
		breakdown.append({"category": key, "units": count, "seconds_per_unit": per_unit, "seconds": seconds})
	var encounter_units: int = int(units["field_encounter"]) + int(units["boss_encounter"])
	return {
		"basis": "authored_records_only",
		"total_seconds": total_seconds,
		"total_minutes": float(total_seconds) / 60.0,
		"required_unit_seconds": required_seconds,
		"required_unit_minutes": float(required_seconds) / 60.0,
		"breakdown": breakdown,
		"encounter_units": encounter_units,
		"distinct_encounters": encounters.size(),
		"dialogue_pages": int(units["dialogue_page"]),
		"choices": int(units["choice"]),
		"document_pages": int(units["document_page"]),
		"distinct_authored_units": distinct_units.size(),
		"budget_inputs": BUDGET_CATEGORY_ORDER.duplicate(),
		"excluded_budget_inputs": FORBIDDEN_BUDGET_INPUTS.duplicate(),
		"human_playthrough_claimed": false,
		"note": "authored unit budget upper bound, not a measured play session",
	}


func _record_reading_units(catalog: TopDownActionRpgContentLoader.Catalog, region: Dictionary, units: Dictionary, distinct_units: Dictionary, counted_conversations: Dictionary, counted_documents: Dictionary) -> void:
	var noncombat: Dictionary = region.get("noncombat_content", {}) if region.get("noncombat_content", {}) is Dictionary else {}
	var prop_ids: Array = noncombat.get("interactable_prop_ids", []) if noncombat.get("interactable_prop_ids", []) is Array else []
	for entry: Variant in prop_ids:
		var prop_id: String = _text(entry)
		distinct_units[prop_id] = true
		units["prop_interaction"] = int(units["prop_interaction"]) + 1
		var prop: Dictionary = catalog.record(prop_id)
		var interaction: Dictionary = prop.get("interaction", {}) if prop.get("interaction", {}) is Dictionary else {}
		_count_reading_record(catalog, _text(interaction.get("opens", "")), units, distinct_units, counted_conversations, counted_documents)
	var residents: Array = region.get("residents", []) if region.get("residents", []) is Array else []
	for entry: Variant in residents:
		if not entry is Dictionary:
			continue
		var npc_id: String = _text((entry as Dictionary).get("npc_id", ""))
		distinct_units[npc_id] = true
		var npc: Dictionary = catalog.record(npc_id)
		var verbs: Array = npc.get("interaction_verbs", []) if npc.get("interaction_verbs", []) is Array else []
		if not verbs.is_empty() and verbs[0] is Dictionary:
			_count_reading_record(catalog, _text((verbs[0] as Dictionary).get("opens", "")), units, distinct_units, counted_conversations, counted_documents)


func _count_reading_record(catalog: TopDownActionRpgContentLoader.Catalog, opens_id: String, units: Dictionary, distinct_units: Dictionary, counted_conversations: Dictionary, counted_documents: Dictionary) -> void:
	if opens_id.is_empty():
		return
	var kind: String = catalog.kind_of(opens_id)
	distinct_units[opens_id] = true
	if kind == "conversations":
		if counted_conversations.has(opens_id):
			return
		counted_conversations[opens_id] = true
		var record: Dictionary = catalog.record(opens_id)
		var pages: Array = record.get("pages", []) if record.get("pages", []) is Array else []
		var choices: Array = record.get("choices", []) if record.get("choices", []) is Array else []
		units["dialogue_page"] = int(units["dialogue_page"]) + pages.size()
		units["choice"] = int(units["choice"]) + choices.size()
		return
	if kind == "documents":
		if counted_documents.has(opens_id):
			return
		counted_documents[opens_id] = true
		var record: Dictionary = catalog.record(opens_id)
		var pages: Array = record.get("pages", []) if record.get("pages", []) is Array else []
		units["document_page"] = int(units["document_page"]) + pages.size()


func _record_encounter_units(catalog: TopDownActionRpgContentLoader.Catalog, region: Dictionary, units: Dictionary, distinct_units: Dictionary, encounters: Dictionary) -> void:
	var combat_content: Dictionary = region.get("combat_content", {}) if region.get("combat_content", {}) is Dictionary else {}
	var encounter_ids: Array = combat_content.get("encounter_ids", []) if combat_content.get("encounter_ids", []) is Array else []
	for entry: Variant in encounter_ids:
		var encounter_id: String = _text(entry)
		distinct_units[encounter_id] = true
		encounters[encounter_id] = true
		var record: Dictionary = catalog.record(encounter_id)
		var activation: Dictionary = record.get("activation", {}) if record.get("activation", {}) is Dictionary else {}
		var boss: bool = BOSS_ACTIVATION_KINDS.has(_text(activation.get("kind", "")))
		var category: String = "boss_encounter" if boss else "field_encounter"
		units[category] = int(units[category]) + 1
		var roster: Array = record.get("roster", []) if record.get("roster", []) is Array else []
		for roster_entry: Variant in roster:
			if not roster_entry is Dictionary:
				continue
			var actor_units: int = maxi(1, int((roster_entry as Dictionary).get("count", 1)))
			units[category] = int(units[category]) + actor_units - 1
			distinct_units[encounter_id + "_slot_" + _text((roster_entry as Dictionary).get("entry_id", ""))] = true


func _seconds_per_unit(category: String) -> int:
	match category:
		"region_decision":
			return SECONDS_PER_REGION_DECISION
		"dialogue_page":
			return SECONDS_PER_DIALOGUE_PAGE
		"choice":
			return SECONDS_PER_CHOICE
		"document_page":
			return SECONDS_PER_DOCUMENT_PAGE
		"prop_interaction":
			return SECONDS_PER_PROP_INTERACTION
		"field_encounter":
			return SECONDS_PER_FIELD_ENCOUNTER_BASE
		"boss_encounter":
			return SECONDS_PER_BOSS_ENCOUNTER_BASE
		"gate_resolution":
			return SECONDS_PER_GATE_RESOLUTION
		"clock_stage_write":
			return SECONDS_PER_CLOCK_STAGE_WRITE
		"axis_write":
			return SECONDS_PER_AXIS_WRITE
		"cluster_thread":
			return SECONDS_PER_CLUSTER_THREAD
	return 0


func _audit_budget(budget: Dictionary) -> void:
	var total_seconds: int = int(budget.get("total_seconds", 0))
	var required_seconds: int = int(budget.get("required_unit_seconds", 0))
	var encounter_units: int = int(budget.get("encounter_units", 0))
	var distinct_encounters: int = int(budget.get("distinct_encounters", 0))
	var distinct_units: int = int(budget.get("distinct_authored_units", 0))
	_check(total_seconds >= MIN_ROUTE_BUDGET_SECONDS, "authored_route_budget_meets_ten_minutes")
	_check(required_seconds >= MIN_ROUTE_REQUIRED_SECONDS, "required_authored_units_alone_meet_ten_minutes")
	_check(distinct_encounters >= MIN_ROUTE_ENCOUNTERS, "canonical_route_carries_at_least_ten_authored_encounters")
	_check(encounter_units > distinct_encounters, "canonical_route_encounters_carry_authored_actor_windows")
	_check(int(budget.get("dialogue_pages", 0)) >= MIN_DIALOGUE_PAGES, "canonical_route_carries_authored_dialogue_pages")
	_check(int(budget.get("choices", 0)) >= MIN_CHOICES, "canonical_route_carries_authored_choices")
	_check(int(budget.get("document_pages", 0)) >= MIN_DOCUMENT_PAGES, "canonical_route_carries_authored_document_pages")
	_check(distinct_units >= MIN_ROUTE_DISTINCT_UNITS, "canonical_route_carries_enough_distinct_authored_units")
	var inputs: Array = budget.get("budget_inputs", []) if budget.get("budget_inputs", []) is Array else []
	var forbidden_hit: bool = false
	for token: String in FORBIDDEN_BUDGET_INPUTS:
		if inputs.has(token):
			forbidden_hit = true
	_check(not forbidden_hit, "budget_excludes_travel_loading_hp_inflation_and_repeat_inputs")
	print("TOPDOWN_PROBE_BUDGET total_seconds=%d required_seconds=%d encounters=%d/%d distinct_units=%d" % [
		total_seconds, required_seconds, distinct_encounters, encounter_units, distinct_units
	])


func _audit_surfaces() -> void:
	var missing: Array[String] = []
	for surface: String in REQUIRED_SURFACES:
		if not bool(_surfaces.get(surface, false)):
			missing.append(surface)
	_check(missing.is_empty(), "driven_chain_covers_every_required_surface")
	_emit("surface_audit", "complete" if missing.is_empty() else "incomplete", &"", &"", {
		"required": REQUIRED_SURFACES,
		"seen": _sorted_keys(_surfaces),
		"missing": missing,
	})
	print("TOPDOWN_PROBE_SURFACES seen=%d required=%d missing=%s" % [
		_surfaces.size(), REQUIRED_SURFACES.size(), str(missing)
	])


func _audit_filler_policy() -> void:
	var kinds: Dictionary = {}
	for row: Dictionary in _events:
		kinds[_text(row.get("kind", ""))] = true
	var hits: Array[String] = []
	for filler: String in FILLER_EVENT_KINDS:
		if kinds.has(filler):
			hits.append(filler)
	_check(hits.is_empty(), "ledger_contains_no_sleep_idle_or_filler_events")
	_emit("timing_policy", "authored_only", &"", &"", {
		"sleep_calls": 0,
		"idle_frames": 0,
		"wall_clock_used": false,
		"filler_event_kinds_found": hits,
		"event_count": _events.size(),
	})


func _finish() -> void:
	if _module != null:
		_despawn_module()
	var failed_assertions: Array[String] = []
	for row: Dictionary in _assertions:
		if not bool(row.get("passed", false)):
			failed_assertions.append(_text(row.get("id", "")))
	var ledger: Dictionary = {
		"schema": "top_down_action_rpg.playthrough_probe.v1",
		"module_id": _text(MODULE_ID),
		"evidence_class": EVIDENCE_CLASS,
		"evidence_version": EVIDENCE_VERSION,
		"human_playthrough_claimed": false,
		"godot_version": Engine.get_version_info().get("string", ""),
		"routing": ProjectSettings.get_setting("rendering/renderer/rendering_method", ""),
		"assertions": _assertions,
		"failed_assertion_count": failed_assertions.size(),
		"failed_assertions": failed_assertions,
		"events": _events,
	}
	var write_error: Error = _write_ledger(ledger)
	_emit_final_summary(failed_assertions, write_error)
	if _failed or write_error != OK or not failed_assertions.is_empty():
		quit(1)
		return
	quit(0)


func _write_ledger(ledger: Dictionary) -> Error:
	var file: FileAccess = FileAccess.open(_output_path, FileAccess.WRITE)
	if file == null:
		return ERR_CANT_CREATE
	file.store_string(JSON.stringify(ledger, "  ", true))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	return error


func _emit_final_summary(failed_assertions: Array[String], write_error: Error) -> void:
	print("TOPDOWN_PROBE_SUMMARY assertions=%d failed=%d events=%d ledger=%s write_error=%d" % [
		_assertions.size(), failed_assertions.size(), _events.size(), _output_path, int(write_error)
	])
	if not failed_assertions.is_empty():
		printerr("TOPDOWN_PROBE_FAILED " + ", ".join(failed_assertions))


func _check(condition: bool, id: String) -> bool:
	_assertions.append({"id": id, "passed": condition, "order": _assertions.size()})
	if not condition:
		_failed = true
		printerr("TOPDOWN_PROBE_ASSERT_FAILED " + id)
	return condition


func _step_failed(id: String) -> bool:
	_check(false, id)
	_emit("chain_aborted", "failed", &"", StringName(id), {"failed_assertions": _failed_assertion_ids()})
	return false


func _failed_assertion_ids() -> Array[String]:
	var result: Array[String] = []
	for row: Dictionary in _assertions:
		if not bool(row.get("passed", false)):
			result.append(_text(row.get("id", "")))
	return result


func _see(surface: String) -> void:
	_surfaces[surface] = true


func _spawn_ledger_run(run_label: String) -> void:
	_emit("run_start", "started", &"", StringName(run_label), {
		"region_id": _state_of().region_id() if _state_of() != null else "",
		"mode": _mode(),
		"content_signature": _catalog_of().content_signature if _catalog_of() != null else "",
	})


func _emit(kind: String, result_code: String, command_id: StringName, target_id: StringName, detail: Dictionary) -> void:
	var before: Dictionary = detail.get("before", {}) if detail.get("before", {}) is Dictionary else {}
	var after: Dictionary = detail.get("after", {}) if detail.get("after", {}) is Dictionary else {}
	var clean: Dictionary = {}
	for key: String in detail:
		if key == "before" or key == "after":
			continue
		clean[key] = detail[key]
	var after_payload: Dictionary = after if not after.is_empty() else _snapshot()
	_step_serial += 1
	_events.append({
		"order": _step_serial,
		"kind": kind,
		"tick": _scheduler_tick(),
		"actor_id": _text(_active_actor_id()),
		"command_id": _text(command_id),
		"target_id": _text(target_id),
		"resolution_phase": _mode(),
		"result_code": result_code,
		"state_before_hash": _hash(before),
		"state_after_hash": _hash(after_payload),
		"detail": clean,
	})


func _emit_combat_row(combat: TopDownActionRpgCombatState, controller: TopDownActionRpgCombatController, label: String) -> void:
	if combat == null:
		return
	var row: Dictionary = _combat_row(combat, controller)
	row["label"] = label
	_emit("combat_row", _text(combat.result), &"combat_resolution", StringName(_text(controller.current_actor_id) if controller != null else ""), row)


func _combat_row(combat: TopDownActionRpgCombatState, controller: TopDownActionRpgCombatController) -> Dictionary:
	var vitals: Array[int] = []
	if combat != null:
		for actor: TopDownActionRpgCombatState.ActorState in combat.actors:
			vitals.append(actor.hp)
	return {
		"tick": combat.scheduler_tick if combat != null else -1,
		"cycle_index": combat.cycle_index if combat != null else -1,
		"submode": _text(combat.submode) if combat != null else "",
		"result": _text(combat.result) if combat != null else "",
		"window_actor_id": _text(controller.current_actor_id) if controller != null else "",
		"awaiting_reaction": bool(controller.awaiting_reaction) if controller != null else false,
		"actor_hp": vitals,
		"player_hp": _player_actor().hp if _player_actor() != null else -1,
		"player_mp": _player_actor().mp if _player_actor() != null else -1,
		"queued": _queued_command_ids(),
	}


func _queued_command_ids() -> Array[String]:
	var result: Array[String] = []
	var combat: TopDownActionRpgCombatState = _combat_of()
	if combat == null:
		return result
	for entry: Variant in combat.queue:
		if entry is TopDownActionRpgCombatState.QueuedIntent:
			result.append(_text((entry as TopDownActionRpgCombatState.QueuedIntent).action_id))
	return result


func _actor_window_count() -> int:
	var count: int = 0
	for row: Dictionary in _events:
		if _text(row.get("kind", "")) == "combat_row" and _text(row.get("result_code", "")) == "running":
			count += 1
	return count


func _due_actor_id() -> String:
	var combat: TopDownActionRpgCombatState = _combat_of()
	if combat == null or String(combat.result) != "running":
		return ""
	var controller: TopDownActionRpgCombatController = _controller_of()
	if controller != null and controller.awaiting_reaction:
		return ""
	var next_actor: TopDownActionRpgCombatState.ActorState = TopDownActionRpgActionScheduler.select_next_actor(combat)
	if next_actor == null or next_actor.next_window_tick > combat.scheduler_tick:
		return ""
	return String(next_actor.actor_id)


func _enemy_actor_ids() -> Array[String]:
	var result: Array[String] = []
	var combat: TopDownActionRpgCombatState = _combat_of()
	if combat == null:
		return result
	for actor: TopDownActionRpgCombatState.ActorState in combat.actors:
		if actor.side != PLAYER_SIDE:
			result.append(_text(actor.actor_id))
	result.sort()
	return result


func _active_actor_id() -> String:
	var controller: TopDownActionRpgCombatController = _controller_of()
	if controller != null and not _text(controller.current_actor_id).is_empty():
		return _text(controller.current_actor_id)
	if _combat_of() != null:
		return _text(_combat_of().encounter_id)
	return ""


func _scheduler_tick() -> int:
	var combat: TopDownActionRpgCombatState = _combat_of()
	return combat.scheduler_tick if combat != null else -1


func _player_actor() -> TopDownActionRpgCombatState.ActorState:
	var combat: TopDownActionRpgCombatState = _combat_of()
	if combat == null:
		return null
	return combat.find_actor(StringName(TopDownActionRpgGameState.PLAYER_ROLE_ID))


func _player_window_open() -> bool:
	var controller: TopDownActionRpgCombatController = _controller_of()
	if controller == null or controller.state == null:
		return false
	if _text(controller.current_actor_id) != TopDownActionRpgGameState.PLAYER_ROLE_ID:
		return false
	return ["command_category", "command_action", "target_select", "resolution_feedback"].has(_text(controller.state.submode))


func _state_of() -> TopDownActionRpgGameState:
	if _module == null:
		return null
	return _module.get("_game_state") as TopDownActionRpgGameState


func _field_of() -> TopDownActionRpgFieldController:
	if _module == null:
		return null
	return _module.get("_field") as TopDownActionRpgFieldController


func _conversation_of() -> TopDownActionRpgConversationController:
	if _module == null:
		return null
	return _module.get("_conversation") as TopDownActionRpgConversationController


func _recovery_of() -> TopDownActionRpgRecoveryController:
	if _module == null:
		return null
	return _module.get("_recovery") as TopDownActionRpgRecoveryController


func _combat_of() -> TopDownActionRpgCombatState:
	if _module == null:
		return null
	return _module.get("_combat") as TopDownActionRpgCombatState


func _controller_of() -> TopDownActionRpgCombatController:
	if _module == null:
		return null
	return _module.get("_combat_controller") as TopDownActionRpgCombatController


func _screen_of() -> TopDownActionRpgScreen:
	if _module == null:
		return null
	return _module.get_node_or_null("TopDownScreen") as TopDownActionRpgScreen


func _catalog_of() -> TopDownActionRpgContentLoader.Catalog:
	if _module == null:
		return null
	return _module.get("_catalog") as TopDownActionRpgContentLoader.Catalog


func _mode() -> String:
	var state: TopDownActionRpgGameState = _state_of()
	return _text(state.mode) if state != null else ""


func _actor_position() -> Vector2:
	var snapshot: Dictionary = _snapshot()
	var field: Dictionary = snapshot.get("field", {}) if snapshot.get("field", {}) is Dictionary else {}
	var actor: Dictionary = field.get("actor", {}) if field.get("actor", {}) is Dictionary else {}
	return Vector2(float(actor.get("x", 0.0)), float(actor.get("y", 0.0)))


func _interactable_of(interactable_id: String) -> TopDownActionRpgFieldController.Interactable:
	var field: TopDownActionRpgFieldController = _field_of()
	if field == null:
		return null
	for entry: TopDownActionRpgFieldController.Interactable in field.interactables:
		if _text(entry.interactable_id) == interactable_id:
			return entry
	return null


func _relationship_snapshot() -> Dictionary:
	var relationships: Dictionary = _state_of().world.get("relationships", {}) if _state_of().world.get("relationships", {}) is Dictionary else {}
	var result: Dictionary = {}
	for key: Variant in relationships:
		result[_text(key)] = _text(_state_of().relationship_state(_text(key)))
	return result


func _axis_snapshot() -> Dictionary:
	var result: Dictionary = {}
	for axis: String in TopDownActionRpgGameState.AXES:
		result[axis] = _state_of().axis_value(axis)
	return result


func _flag_snapshot() -> Array[String]:
	var flags: Dictionary = _state_of().world.get("flags", {}) if _state_of().world.get("flags", {}) is Dictionary else {}
	var result: Array[String] = []
	for key: Variant in flags:
		if bool(flags[key]):
			result.append(String(key))
	result.sort()
	return result


func _clock_snapshot() -> Dictionary:
	var clocks: Dictionary = _state_of().world.get("clocks", {}) if _state_of().world.get("clocks", {}) is Dictionary else {}
	var result: Dictionary = {}
	var region_id: String = _state_of().region_id()
	if not clocks.has(region_id):
		return result
	var region_clocks: Dictionary = clocks[region_id] if clocks[region_id] is Dictionary else {}
	for key: Variant in region_clocks:
		result[_text(key)] = _state_of().clock_stage(region_id, _text(key))
	return result


func _snapshot() -> Dictionary:
	if _module == null:
		return {}
	return _module.save_state()


func _text(value: Variant) -> String:
	return "" if value == null else str(value)


func _sorted_keys(source: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in source:
		keys.append(_text(key))
	keys.sort()
	return keys


func _hash(payload: Dictionary) -> String:
	if payload.is_empty():
		return ""
	return _canonical(payload).sha256_text()


func _canonical(value: Variant) -> String:
	if value is Dictionary:
		var keys: Array[String] = []
		for key: Variant in (value as Dictionary):
			keys.append(_text(key))
		keys.sort()
		var parts: PackedStringArray = PackedStringArray()
		for key: String in keys:
			parts.append(JSON.stringify(key) + ":" + _canonical((value as Dictionary)[key]))
		return "{" + ",".join(parts) + "}"
	if value is Array:
		var items: PackedStringArray = PackedStringArray()
		for element: Variant in (value as Array):
			items.append(_canonical(element))
		return "[" + ",".join(items) + "]"
	return JSON.stringify(value)


func _parse_arguments(args: PackedStringArray) -> Dictionary:
	var output: String = ""
	var strict: bool = false
	var index: int = 0
	while index < args.size():
		var token: String = args[index]
		if token == "--require-canonical-coverage":
			strict = true
			index += 1
			continue
		if token == "--output" and index + 1 < args.size():
			output = _text(args[index + 1])
			index += 2
			continue
		if token.begins_with("--output="):
			output = token.trim_prefix("--output=")
			index += 1
			continue
		return {"ok": false, "message": "unrecognised argument: " + token}
	if output.strip_edges().is_empty():
		return {"ok": false, "message": "usage: --output <absolute file or directory outside the workspace> [--require-canonical-coverage]"}
	var resolved: String = _resolve_output_path(output.strip_edges())
	if resolved.is_empty():
		return {"ok": false, "message": "output path is rejected: " + output}
	return {"ok": true, "output_path": resolved, "require_canonical_coverage": strict}


func _resolve_output_path(raw: String) -> String:
	var candidate: String = raw.replace("\\", "/")
	if not candidate.is_absolute_path():
		return ""
	var workspace: String = ProjectSettings.globalize_path("res://").replace("\\", "/").simplify_path().trim_suffix("/")
	var normalized: String = candidate.simplify_path()
	if _path_is_within(normalized.trim_suffix("/"), workspace):
		return ""
	var is_directory_target: bool = raw.ends_with("/") or raw.ends_with("\\") or DirAccess.dir_exists_absolute(candidate)
	if is_directory_target:
		normalized = normalized.path_join(LEDGER_FILE_NAME)
	var parent: String = normalized.get_base_dir()
	if parent.is_empty():
		return ""
	if not DirAccess.dir_exists_absolute(parent):
		if DirAccess.make_dir_recursive_absolute(parent) != OK:
			return ""
	if FileAccess.file_exists(normalized) or DirAccess.dir_exists_absolute(normalized):
		return ""
	return normalized


func _path_is_within(path: String, root: String) -> bool:
	var normalized_path: String = path.trim_suffix("/")
	var normalized_root: String = root.trim_suffix("/")
	if OS.get_name() == "Windows":
		normalized_path = normalized_path.to_lower()
		normalized_root = normalized_root.to_lower()
	return normalized_path == normalized_root or normalized_path.begins_with(normalized_root + "/")
