extends GutTest

const MODULE_SOURCE_FILES: Array[String] = [
	"res://modules/top_down_action_rpg/domain/game_state.gd",
	"res://modules/top_down_action_rpg/domain/combat_state.gd",
	"res://modules/top_down_action_rpg/systems/content_loader.gd",
	"res://modules/top_down_action_rpg/systems/action_scheduler.gd",
	"res://modules/top_down_action_rpg/systems/combat_controller.gd",
	"res://modules/top_down_action_rpg/systems/field_controller.gd",
	"res://modules/top_down_action_rpg/systems/conversation_controller.gd",
	"res://modules/top_down_action_rpg/systems/recovery_controller.gd",
]
const FORBIDDEN_RUNTIME_TOKENS: Array[String] = [
	"randi(", "randf(", "randi_range", "randf_range", "randomize(",
	"Time.get_unix_time_from_system", "Time.get_ticks_usec",
	"get_process_delta_time", "Engine.get_process_frames", "pick_random", ".shuffle(",
]
const IDENTITY_EXEMPT_IDS: Array[String] = ["seed_ledger"]
const IDENTITY_SCAN_KINDS: Array[String] = [
	"actions", "regions", "npcs", "encounters", "enemies", "statuses", "effects",
	"equipment", "items", "recovery", "props", "documents", "conversations",
	"phases", "relationships", "seeds",
]
const SAVE_ROOT_KEYS: Array[String] = [
	"state_format", "save_version", "run_id", "content_revision",
	"field", "combat", "player", "world", "recovery", "progression", "transaction", "commit_log",
]
const EXPECTED_FILE_COUNT: int = 64
const PROBE_ENCOUNTER_ID: String = "enc_core_probe"
const PROBE_DOCUMENT_ID: String = "doc_core_probe"
const PROBE_CONVERSATION_ID: String = "conv_core_probe"
const PROBE_NO_TURN_ID: String = "act_core_probe_no_turn"
const PROBE_HIT_ID: String = "act_core_probe_hit"
const PROBE_AOE_ID: String = "act_core_probe_aoe"
const PROBE_ALLY_AOE_ID: String = "act_core_probe_ally_aoe"
const PROBE_RANDOM_ID: String = "act_core_probe_random"
const PROBE_STATUS_SELF_ID: String = "act_core_probe_status_self"
const PROBE_STATUS_TARGET_ID: String = "act_core_probe_status_target"
const PROBE_COST_ID: String = "act_core_probe_cost"

var _result: TopDownActionRpgContentLoader.CatalogResult
var _catalog: TopDownActionRpgContentLoader.Catalog
var _overlay: TopDownActionRpgContentLoader.Catalog


func before_all() -> void:
	_result = TopDownActionRpgContentLoader.load_default()
	_catalog = _result.catalog
	_overlay = _overlay_catalog()


func _probe_records() -> Dictionary:
	return {
		PROBE_NO_TURN_ID: {
			"__kind": "actions",
			"schema_version": 1,
			"id": PROBE_NO_TURN_ID,
			"display_name": "probe no turn",
			"order": 1,
			"owner": "player",
			"category": "unique",
			"defense_mode": "none",
			"lifecycle": "instant",
			"intent": {"target_mode": "SELF", "requires_target_cursor": false, "target_eligibility": "living"},
			"cost": {"turn_cost": 0, "action_slot_cost": 0, "resource_costs": {}, "cooldown_windows": 0},
			"telegraph": {"channels": ["pose"], "windows_before_active": 0, "tell_key": "tell_probe_no_turn"},
			"counters": {"valid": ["noncombat"], "forbidden": ["break"], "breakable": false},
			"presentation": {"icon_key": "probe_no_turn"},
			"seed_ids": ["seed_s001"],
		},
		PROBE_HIT_ID: {
			"__kind": "actions",
			"schema_version": 1,
			"id": PROBE_HIT_ID,
			"display_name": "probe hit",
			"order": 2,
			"owner": "player",
			"category": "attack",
			"defense_mode": "none",
			"lifecycle": "instant",
			"intent": {"target_mode": "ONE_ENEMY", "requires_target_cursor": true, "target_eligibility": "living"},
			"cost": {"turn_cost": 1, "action_slot_cost": 1, "resource_costs": {}, "cooldown_windows": 0},
			"telegraph": {"channels": ["pose"], "windows_before_active": 0, "tell_key": "tell_probe_hit"},
			"counters": {"valid": ["guard", "dodge", "break"], "forbidden": [], "breakable": true},
			"damage_payload": {
				"delivery": "physical", "shape": "guaranteed", "base_value": 20, "affinity": "none",
				"hit_policy": "guaranteed", "hit_modifier": 0, "evasion_policy": "roll",
				"critical_policy": "never", "dodge_pressure": 0, "guard_ignore": false,
				"breaks_guard": false, "break_damage": 0, "dodgeable": true,
			},
			"presentation": {"icon_key": "probe_hit"},
			"seed_ids": ["seed_s001"],
		},
		PROBE_AOE_ID: {
			"__kind": "actions",
			"schema_version": 1,
			"id": PROBE_AOE_ID,
			"display_name": "probe sweep",
			"order": 3,
			"owner": "player",
			"category": "attack",
			"defense_mode": "none",
			"lifecycle": "instant",
			"intent": {"target_mode": "ALL_ENEMIES", "requires_target_cursor": false, "target_eligibility": "living"},
			"cost": {"turn_cost": 1, "action_slot_cost": 1, "resource_costs": {}, "cooldown_windows": 0},
			"telegraph": {"channels": ["pose"], "windows_before_active": 0, "tell_key": "tell_probe_sweep"},
			"counters": {"valid": ["guard", "break"], "forbidden": [], "breakable": true},
			"damage_payload": {
				"delivery": "physical", "shape": "guaranteed", "base_value": 7, "affinity": "none",
				"hit_policy": "guaranteed", "hit_modifier": 0, "evasion_policy": "roll",
				"critical_policy": "never", "dodge_pressure": 0, "guard_ignore": true,
				"breaks_guard": false, "break_damage": 0, "dodgeable": false,
			},
			"presentation": {"icon_key": "probe_sweep"},
			"seed_ids": ["seed_s001"],
		},
		PROBE_ALLY_AOE_ID: {
			"__kind": "actions",
			"schema_version": 1,
			"id": PROBE_ALLY_AOE_ID,
			"display_name": "probe rally",
			"order": 4,
			"owner": "player",
			"category": "skill",
			"defense_mode": "none",
			"lifecycle": "instant",
			"intent": {"target_mode": "ALL_ALLIES", "requires_target_cursor": false, "target_eligibility": "living"},
			"cost": {"turn_cost": 1, "action_slot_cost": 1, "resource_costs": {}, "cooldown_windows": 0},
			"telegraph": {"channels": ["pose"], "windows_before_active": 0, "tell_key": "tell_probe_rally"},
			"counters": {"valid": ["status_counter"], "forbidden": [], "breakable": true},
			"damage_payload": {
				"delivery": "physical", "shape": "guaranteed", "base_value": 3, "affinity": "none",
				"hit_policy": "guaranteed", "hit_modifier": 0, "evasion_policy": "roll",
				"critical_policy": "never", "dodge_pressure": 0, "guard_ignore": true,
				"breaks_guard": false, "break_damage": 0, "dodgeable": false,
			},
			"presentation": {"icon_key": "probe_rally"},
			"seed_ids": ["seed_s001"],
		},
		PROBE_RANDOM_ID: {
			"__kind": "actions",
			"schema_version": 1,
			"id": PROBE_RANDOM_ID,
			"display_name": "probe random",
			"order": 5,
			"owner": "player",
			"category": "attack",
			"defense_mode": "none",
			"lifecycle": "instant",
			"intent": {"target_mode": "RANDOM_ENEMY", "requires_target_cursor": false, "target_eligibility": "living"},
			"cost": {"turn_cost": 1, "action_slot_cost": 1, "resource_costs": {}, "cooldown_windows": 0},
			"telegraph": {"channels": ["pose"], "windows_before_active": 0, "tell_key": "tell_probe_random"},
			"counters": {"valid": ["guard", "break"], "forbidden": [], "breakable": true},
			"damage_payload": {
				"delivery": "physical", "shape": "guaranteed", "base_value": 5, "affinity": "none",
				"hit_policy": "guaranteed", "hit_modifier": 0, "evasion_policy": "roll",
				"critical_policy": "never", "dodge_pressure": 0, "guard_ignore": true,
				"breaks_guard": false, "break_damage": 0, "dodgeable": false,
			},
			"presentation": {"icon_key": "probe_random"},
			"seed_ids": ["seed_s001"],
		},
		PROBE_STATUS_TARGET_ID: {
			"__kind": "actions",
			"schema_version": 1,
			"id": PROBE_STATUS_TARGET_ID,
			"display_name": "probe mark",
			"order": 6,
			"owner": "player",
			"category": "attack",
			"defense_mode": "none",
			"lifecycle": "instant",
			"intent": {"target_mode": "ONE_ENEMY", "requires_target_cursor": true, "target_eligibility": "living"},
			"cost": {"turn_cost": 1, "action_slot_cost": 1, "resource_costs": {}, "cooldown_windows": 0},
			"telegraph": {"channels": ["pose"], "windows_before_active": 0, "tell_key": "tell_probe_mark"},
			"counters": {"valid": ["status_counter"], "forbidden": [], "breakable": true},
			"status_payloads": [{"status_id": "st_recorded", "chance_permille": 1000, "target": "target"}],
			"presentation": {"icon_key": "probe_mark"},
			"seed_ids": ["seed_s001"],
		},
		PROBE_STATUS_SELF_ID: {
			"__kind": "actions",
			"schema_version": 1,
			"id": PROBE_STATUS_SELF_ID,
			"display_name": "probe self load",
			"order": 7,
			"owner": "player",
			"category": "magic",
			"defense_mode": "none",
			"lifecycle": "instant",
			"intent": {"target_mode": "SELF", "requires_target_cursor": false, "target_eligibility": "living"},
			"cost": {"turn_cost": 0, "action_slot_cost": 0, "resource_costs": {}, "cooldown_windows": 0},
			"telegraph": {"channels": ["pose"], "windows_before_active": 0, "tell_key": "tell_probe_self_load"},
			"counters": {"valid": ["noncombat"], "forbidden": ["break"], "breakable": false},
			"status_payloads": [{"status_id": "st_concentration_load", "chance_permille": 1000, "target": "self"}],
			"presentation": {"icon_key": "probe_self_load"},
			"seed_ids": ["seed_s001"],
		},
		PROBE_COST_ID: {
			"__kind": "actions",
			"schema_version": 1,
			"id": PROBE_COST_ID,
			"display_name": "probe cost",
			"order": 8,
			"owner": "player",
			"category": "attack",
			"defense_mode": "none",
			"lifecycle": "instant",
			"intent": {"target_mode": "ONE_ENEMY", "requires_target_cursor": true, "target_eligibility": "living"},
			"cost": {"turn_cost": 1, "action_slot_cost": 1, "resource_costs": {"mp": 3}, "cooldown_windows": 0},
			"telegraph": {"channels": ["pose"], "windows_before_active": 0, "tell_key": "tell_probe_cost"},
			"counters": {"valid": ["guard", "break"], "forbidden": [], "breakable": true},
			"damage_payload": {
				"delivery": "magical", "shape": "guaranteed", "base_value": 6, "affinity": "none",
				"hit_policy": "guaranteed", "hit_modifier": 0, "evasion_policy": "roll",
				"critical_policy": "never", "dodge_pressure": 0, "guard_ignore": true,
				"breaks_guard": false, "break_damage": 0, "dodgeable": false,
			},
			"presentation": {"icon_key": "probe_cost"},
			"seed_ids": ["seed_s001"],
		},
		PROBE_DOCUMENT_ID: {
			"__kind": "documents",
			"schema_version": 1,
			"id": PROBE_DOCUMENT_ID,
			"display_name": "Probe Ledger",
			"owner_npc_id": "npc_01_ilyra_senn",
			"region_id": "region_h0_undersign_exchange",
			"availability": {"condition": {}, "reached_by": "prop"},
			"reached_by_ref": "prop_h0_counterweight_map",
			"pages": [
				{
					"page_id": "pg_probe_wide",
					"lines": ["l1", "l2", "l3", "l4", "l5", "l6", "l7", "l8", "l9", "l10", "l11"],
					"presentation": "plain",
					"corruption_rules": [],
				},
				{
					"page_id": "pg_probe_corrupt",
					"lines": ["c1", "c2", "c3"],
					"presentation": "corrupted",
					"corruption_rules": [
						{
							"rule_id": "cr_probe_word",
							"mode": "replace_token",
							"line_index": 1,
							"token_index": 0,
							"trigger": {"clock_at_least": {"clock_id": "clock_public_record", "stage_index": 2}},
							"severity": 2,
							"replacement_seed_id": "seed_s001",
							"text_note": "the word itself is swapped, not only the ink",
						},
					],
				},
			],
			"reading": {
				"background_mode": "dim_world", "world_visible_ratio": 0.35, "advance": "page",
				"max_lines_per_page": 9, "min_font_size": 22, "requires_advance_affordance": true,
			},
			"post_read": {"effect_ids": [], "once": false},
			"revisit": "allowed",
			"seed_ids": ["seed_s001"],
		},
		PROBE_CONVERSATION_ID: {
			"__kind": "conversations",
			"schema_version": 1,
			"id": PROBE_CONVERSATION_ID,
			"display_name": "Probe Choice Gate",
			"region_id": "region_h0_undersign_exchange",
			"speaker_npc_id": "npc_01_ilyra_senn",
			"entry_condition": {},
			"priority": 99,
			"pages": [
				{"page_id": "pg_probe", "speaker": "npc", "presentation_class": "neutral", "text": "probe line", "advance": "auto"},
			],
			"choices": [
				{
					"choice_id": "ch_probe_open", "text": "open probe",
					"semantic_tags": ["cooperative"], "presentation_class": "neutral",
					"availability": {}, "unavailable_reason": "", "irreversibility": "reversible",
					"return_focus": "field", "one_shot": false, "hint_surface": "none",
				},
				{
					"choice_id": "ch_probe_blocked", "text": "blocked probe",
					"semantic_tags": ["evasive"], "presentation_class": "extreme",
					"availability": {"axis_at_least": {"axis": "protocol_legitimacy", "value": 3}},
					"unavailable_reason": "not_filed_yet", "irreversibility": "irreversible",
					"return_focus": "field", "one_shot": false, "hint_surface": "none",
				},
			],
			"on_complete": {"effect_ids": []},
			"on_abort": {"effect_ids": []},
			"revisit": "repeatable",
			"alt_conversation_ids": [],
			"seed_ids": ["seed_s001"],
		},
	}


func _overlay_catalog() -> TopDownActionRpgContentLoader.Catalog:
	var overlay := TopDownActionRpgContentLoader.Catalog.new()
	overlay.entry_region_id = _catalog.entry_region_id
	overlay.content_signature = _catalog.content_signature
	overlay.file_count = _catalog.file_count
	overlay.kind_prefix = _catalog.kind_prefix.duplicate(true)
	overlay.kind_records = _catalog.kind_records.duplicate(true)
	overlay.by_id = _catalog.by_id.duplicate(true)
	overlay.id_kind = _catalog.id_kind.duplicate(true)
	var additions: Dictionary = _probe_records()
	for record_id: String in additions:
		var record: Dictionary = additions[record_id]
		var kind_name: String = String(record.get("__kind", "actions"))
		record.erase("__kind")
		overlay.by_id[record_id] = record
		overlay.id_kind[record_id] = kind_name
		var list: Array = overlay.kind_records.get(kind_name, [])
		list.append(record_id)
		overlay.kind_records[kind_name] = list
	return overlay


func _new_game_state(region_id: String = "region_h0_undersign_exchange") -> TopDownActionRpgGameState:
	var state := TopDownActionRpgGameState.create_default(region_id, "anchor_core_probe")
	state.content_revision = String(_catalog.content_signature)
	state.set_field_actor(0.25, -0.5, 3)
	return state


func _make_actor(actor_id: String, side: String, rank: int, hp: int, max_hp: int, agility: int, extra: Dictionary = {}) -> TopDownActionRpgCombatState.ActorState:
	var actor := TopDownActionRpgCombatState.ActorState.new()
	actor.actor_id = StringName(actor_id)
	actor.display_name = actor_id
	actor.side = side
	actor.tie_break_rank = rank
	actor.hp = hp
	actor.max_hp = max_hp
	actor.mp = int(extra.get("mp", 0))
	actor.max_mp = int(extra.get("max_mp", 0))
	actor.base_stats = {
		"agility": agility,
		"evasion": int(extra.get("evasion", 0)),
		"defense": int(extra.get("defense", 0)),
		"guard_efficiency": int(extra.get("guard_efficiency", 0)),
	}
	if extra.has("break_policy"):
		actor.break_policy = String(extra["break_policy"])
	if extra.has("break_resistance"):
		actor.break_resistance = int(extra["break_resistance"])
	if extra.has("action_slots"):
		actor.action_slot_snapshot = int(extra["action_slots"])
	return actor


func _new_combat_state(attempt: int = 1, seed_override: int = -1) -> TopDownActionRpgCombatState:
	var seed_value: int = seed_override
	if seed_value < 0:
		seed_value = TopDownActionRpgGameState.stable_seed(PROBE_ENCOUNTER_ID, attempt)
	return TopDownActionRpgCombatState.create_encounter(PROBE_ENCOUNTER_ID, attempt, seed_value)


func _build_roster(state: TopDownActionRpgCombatState, player_extra: Dictionary = {}, enemy_extra: Dictionary = {}) -> Array:
	var player := _make_actor("act_player_one", "player_side", 1, 60, 60, 10, player_extra)
	var ally := _make_actor("act_ally_two", "player_side", 2, 40, 40, 8, {})
	var enemy_a := _make_actor("act_enemy_one", "enemy_side", 1, 50, 50, 9, enemy_extra)
	var enemy_b := _make_actor("act_enemy_two", "enemy_side", 2, 50, 50, 9, {})
	state.add_actor(player)
	state.add_actor(ally)
	state.add_actor(enemy_a)
	state.add_actor(enemy_b)
	return [player, ally, enemy_a, enemy_b]


func _new_controller(state: TopDownActionRpgCombatState, definition: Dictionary = {}) -> TopDownActionRpgCombatController:
	var controller := TopDownActionRpgCombatController.new()
	var record: Dictionary = definition
	if record.is_empty():
		record = {"id": PROBE_ENCOUNTER_ID, "allow": {"escape": true}}
	assert_true(controller.setup(state, _overlay, record))
	return controller


func _intent(actor: TopDownActionRpgCombatState.ActorState, action_id: String, target_mode: String, target_id: StringName, turn_cost: int, command_index: int) -> TopDownActionRpgCombatState.QueuedIntent:
	var queued := TopDownActionRpgCombatState.QueuedIntent.new()
	queued.intent_id = PROBE_ENCOUNTER_ID + "|" + String(actor.actor_id) + "|1|" + str(command_index)
	queued.actor_id = actor.actor_id
	queued.action_id = StringName(action_id)
	queued.target_mode = target_mode
	queued.target_actor_id = target_id
	queued.turn_cost = turn_cost
	queued.no_turn = turn_cost == 0
	queued.command_index = command_index
	queued.ready_tick = 0
	queued.tie_break_rank = actor.tie_break_rank
	return queued


func _run_now(controller: TopDownActionRpgCombatController, actor: TopDownActionRpgCombatState.ActorState, action_id: String, targets: Array, command_index: int = 0) -> TopDownActionRpgCombatState.ResolutionOutcome:
	var action: Dictionary = _overlay.record(action_id)
	return controller.resolve_intent(_intent(actor, action_id, String((action.get("intent", {}) as Dictionary).get("target_mode", "SELF")), &"", 1, command_index), actor, action, targets)


func _canonical_ledger(outcomes: Array) -> Array:
	var ledger: Array = []
	for outcome: TopDownActionRpgCombatState.ResolutionOutcome in outcomes:
		ledger.append(JSON.stringify({
			"actor_id": String(outcome.actor_id),
			"action_id": String(outcome.action_id),
			"result_code": String(outcome.result_code),
			"intent_id": String(outcome.intent_id),
			"target_ids": outcome.target_ids,
			"damage_by_actor": outcome.damage_by_actor,
			"stance_keys": outcome.stance_changes.keys(),
			"stance_values": outcome.stance_changes.values(),
			"charge_transition": String(outcome.charge_transition),
			"outcome_id": String(outcome.outcome_id),
		}))
	return ledger


func _roll_stream(seed_value: int, count: int) -> Array:
	var probe := TopDownActionRpgCombatState.create_encounter(PROBE_ENCOUNTER_ID, 0, seed_value)
	var values: Array = []
	for _step: int in range(count):
		values.append(probe.roll_permille())
	return values


func _seed_with_permille(ordinal: int, upper_bound: int) -> int:
	var candidate: int = 1
	while candidate < 2000000:
		if int(_roll_stream(candidate, ordinal + 1)[ordinal]) < upper_bound:
			return candidate
		candidate += 1
	return 0


func _run_scripted_scenario(attempt: int) -> Array:
	var state: TopDownActionRpgCombatState = _new_combat_state(attempt)
	_build_roster(state)
	var controller: TopDownActionRpgCombatController = _new_controller(state)
	var collected: Array = []
	for actor_id: StringName in [&"act_player_one", &"act_enemy_one", &"act_ally_two", &"act_enemy_two"]:
		if controller.begin_actor_window(actor_id) != "window_open":
			continue
		if actor_id == &"act_player_one":
			collected.append(controller.queue_action(StringName(PROBE_HIT_ID), &"act_enemy_one"))
		elif actor_id == &"act_enemy_one":
			collected.append(controller.queue_action(&"act_ash_hound_snap", &"act_player_one"))
		else:
			collected.append(controller.queue_action(&"act_ash_sweep", &"act_enemy_one"))
		controller.end_actor_window()
	collected.append_array(controller.advance())
	return collected


func _is_whole_number(value: Variant) -> bool:
	if not (value is int or value is float):
		return false
	return is_finite(float(value)) and float(value) == floorf(float(value))


func _collect_float_paths(value: Variant, path: String, found: Array) -> void:
	match typeof(value):
		TYPE_FLOAT:
			found.append(path)
		TYPE_ARRAY:
			var list: Array = value
			for index: int in range(list.size()):
				_collect_float_paths(list[index], path + "[" + str(index) + "]", found)
		TYPE_DICTIONARY:
			var dictionary: Dictionary = value
			for key: String in dictionary:
				_collect_float_paths(dictionary[key], path + "." + key, found)


func _module_source() -> String:
	var joined: String = ""
	for path: String in MODULE_SOURCE_FILES:
		var file := FileAccess.open(path, FileAccess.READ)
		assert_true(file != null, path)
		if file != null:
			joined += file.get_as_text()
			file.close()
	return joined


func test_catalog_loads_with_zero_errors_and_first_slice_content() -> void:
	assert_false(_result.has_error())
	assert_eq(_result.errors().size(), 0)
	assert_eq(_result.outcome, TopDownActionRpgContentLoader.OUTCOME_READY_WITH_DEFECTS)
	assert_true(_result.is_playable())
	var deferred: Dictionary = {}
	for entry: TopDownActionRpgContentLoader.Diagnostic in _result.diagnostics:
		assert_false(entry.is_error(), entry.to_line())
		if entry.code == TopDownActionRpgContentLoader.DEFERRED_FLOOR_CODE:
			deferred[entry.detail] = true
	for floor_code: String in TopDownActionRpgContentLoader.DEFERRED_FLOORS:
		assert_true(deferred.has(floor_code), floor_code)
	var expected_counts: Dictionary = {
		"ledger": 1, "seeds": 1, "effects": 7, "statuses": 2, "actions": 13,
		"equipment": 2, "items": 2, "clocks": 6, "relationships": 4, "recovery": 2,
		"props": 6, "regions": 3, "npcs": 4, "conversations": 3, "documents": 1,
		"phases": 1, "enemies": 3, "encounters": 3,
	}
	var counts: Dictionary = _catalog.to_dict()["counts"]
	assert_eq(counts.size(), TopDownActionRpgContentLoader.KIND_ORDER.size())
	for kind_name: String in expected_counts:
		assert_eq(int(counts[kind_name]), int(expected_counts[kind_name]), kind_name)
	assert_eq(_catalog.file_count, EXPECTED_FILE_COUNT)
	var required_ids: Array[String] = [
		"region_h0_undersign_exchange", "region_r1_returning_kiln", "region_r8_folding_school",
		"clock_institutional_response", "clock_contamination", "clock_public_record",
		"clock_resource_collapse", "clock_personal_collapse", "clock_crown_alignment",
		"npc_01_ilyra_senn", "npc_05_nera_voss", "npc_11_cael_ren", "npc_20_mira_vask",
		"enemy_ash_hound", "enemy_ember_clerk", "enemy_fold_wall",
		"enc_r1_ash_choir", "enc_r1_door_role_test", "enc_r8_fold_that_refuses_the_hand",
		"act_ash_sweep", "act_weave_lash", "act_file_return_form", "act_guard_set",
		"act_dodge_shift", "act_break_poise", "act_ash_hound_lunge", "act_fold_wall_verdict",
		"doc_r1_wrong_return_log", "equipment_ash_bound_stick", "equipment_kiln_ledger_seal",
		"item_ash_thread_spool", "item_blank_return_form",
		"rec_r1_kiln_reentry", "rec_r8_course_repeat", "phase_fold_wall_second_hearing",
		"conv_h0_return_desk", "conv_r1_wrong_return_hearing", "conv_r8_course_index_desk",
	]
	for record_id: String in required_ids:
		assert_true(_catalog.has(record_id), record_id)
	assert_eq(String(_catalog.record(_catalog.entry_region_id).get("region_role", "")), TopDownActionRpgContentLoader.HUB_REGION_ROLE)
	assert_eq(_catalog.kind_of("act_ash_sweep"), "actions")
	assert_eq(_catalog.kind_of("seed_ledger"), "ledger")
	assert_eq(_catalog.record("rec_missing_probe").size(), 0)
	assert_eq(_catalog.ids_of_kind("regions"), ["region_h0_undersign_exchange", "region_r1_returning_kiln", "region_r8_folding_school"])


func test_catalog_ids_and_vocabularies_are_closed() -> void:
	var seen: Dictionary = {}
	for kind_name: String in TopDownActionRpgContentLoader.KIND_ORDER:
		for record_id: String in _catalog.ids_of_kind(kind_name):
			assert_false(seen.has(record_id), record_id)
			seen[record_id] = true
			assert_true(TopDownActionRpgContentLoader.is_stable_id(record_id), record_id)
			assert_true(record_id.begins_with(TopDownActionRpgContentLoader._prefix_of(kind_name)), record_id)
			assert_true(TopDownActionRpgContentLoader.is_json_safe(_catalog.record(record_id)), record_id)
	for action_id: String in _catalog.ids_of_kind("actions"):
		var action: Dictionary = _catalog.record(action_id)
		var intent: Dictionary = action.get("intent", {}) as Dictionary
		var target_mode: String = String(intent.get("target_mode", ""))
		assert_true(TopDownActionRpgContentLoader.TARGET_MODES.has(target_mode), action_id + " " + target_mode)
		assert_false(TopDownActionRpgContentLoader.TARGET_ROLES.has(target_mode), action_id)
		assert_true(TopDownActionRpgContentLoader.TARGET_ELIGIBILITY.has(String(intent.get("target_eligibility", ""))), action_id)
		var cost: Dictionary = action.get("cost", {}) as Dictionary
		var turn_cost: Variant = cost.get("turn_cost", -1)
		assert_true(_is_whole_number(turn_cost), action_id)
		assert_true(int(turn_cost) >= TopDownActionRpgContentLoader.TURN_COST_MIN and int(turn_cost) <= TopDownActionRpgContentLoader.TURN_COST_MAX, action_id)
		var slot_cost: int = int(cost.get("action_slot_cost", 0))
		if int(turn_cost) == 0:
			assert_eq(slot_cost, 0, action_id)
		if int(turn_cost) >= 2:
			assert_eq(slot_cost, 1, action_id)
			assert_true(["instant", "committed"].has(String(action.get("lifecycle", ""))), action_id)
		var telegraph: Dictionary = action.get("telegraph", {}) as Dictionary
		var channels: Array = telegraph.get("channels", [])
		assert_gt(channels.size(), 0, action_id)
		assert_true(TopDownActionRpgContentLoader.TELEGRAPH_CHANNELS.has(String(channels[0])), action_id)
	for recovery_id: String in _catalog.ids_of_kind("recovery"):
		var recovery_kind: String = String(_catalog.record(recovery_id).get("kind", ""))
		assert_true(TopDownActionRpgRecoveryController.RECOVERY_KINDS.has(recovery_kind), recovery_id)
		assert_true(recovery_kind != "crown_alignment", recovery_id)
	for region_id: String in _catalog.ids_of_kind("regions"):
		assert_true(TopDownActionRpgContentLoader.REGION_ROLES.has(String(_catalog.record(region_id).get("region_role", ""))), region_id)
	for npc_id: String in _catalog.ids_of_kind("npcs"):
		assert_true(TopDownActionRpgContentLoader.MANA_PROFILES.has(String(_catalog.record(npc_id).get("mana_profile", ""))), npc_id)
		assert_true(TopDownActionRpgContentLoader.ROSTER_KINDS.has(String(_catalog.record(npc_id).get("roster_kind", ""))), npc_id)
	for equipment_id: String in _catalog.ids_of_kind("equipment"):
		assert_true(TopDownActionRpgContentLoader.EQUIPMENT_SLOTS.has(String(_catalog.record(equipment_id).get("slot", ""))), equipment_id)
	for item_id: String in _catalog.ids_of_kind("items"):
		assert_true(TopDownActionRpgContentLoader.ITEM_CLASSES.has(String(_catalog.record(item_id).get("item_class", ""))), item_id)
	for clock_id: String in _catalog.ids_of_kind("clocks"):
		assert_true(TopDownActionRpgContentLoader.CLOCK_KINDS.has(clock_id), clock_id)
		assert_eq(String(_catalog.record(clock_id).get("kind", "")), String(TopDownActionRpgContentLoader.CLOCK_KINDS[clock_id]), clock_id)
		assert_eq((_catalog.record(clock_id).get("stages", []) as Array).size(), TopDownActionRpgGameState.CLOCK_STAGE_COUNT, clock_id)


func test_target_mode_enum_is_closed_and_encounter_roles_stay_separate() -> void:
	assert_eq(TopDownActionRpgCombatState.TARGET_MODES, [
		"SELF", "ONE_ENEMY", "ONE_ALLY", "ALL_ENEMIES", "ALL_ALLIES", "RANDOM_ENEMY",
	] as Array)
	assert_eq(TopDownActionRpgContentLoader.TARGET_MODES, TopDownActionRpgCombatState.TARGET_MODES)
	assert_eq(TopDownActionRpgContentLoader.TARGET_ROLES, ["record", "route", "resource_node"] as Array)
	var legacy: Array[String] = [
		"linked_actor", "record", "route", "resource_node",
		"positionless", "single_enemy", "all_enemies", "random_enemy",
	]
	for token: String in legacy:
		assert_false(TopDownActionRpgCombatState.TARGET_MODES.has(token), token)
		assert_false(TopDownActionRpgCombatState.TARGET_ELIGIBILITY.has(token), token)
		var rejected: Variant = TopDownActionRpgCombatState.QueuedIntent.from_dict({
			"intent_id": "probe", "actor_id": "act_player_one", "action_id": "act_probe",
			"target_mode": token, "turn_cost": 1,
		})
		assert_eq(rejected, null, token)
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	for token: String in legacy:
		assert_eq(state.valid_targets_for(player, token, "living"), [], token)
	assert_eq(TopDownActionRpgActionScheduler.can_queue(player, _intent(player, "act_probe", "record", &"", 1, 0), 0), "skipped_action_unavailable")
	assert_eq(TopDownActionRpgActionScheduler.can_queue(player, _intent(player, "act_probe", "ONE_ENEMY", &"", 0, 0), 99), "")
	var encounter: Dictionary = _catalog.record("enc_r1_ash_choir")
	_new_controller(state, encounter)
	assert_eq(state.encounter_target_roles.size(), 2)
	assert_eq(state.encounter_role_surface("record").size(), 1)
	assert_eq(String((state.encounter_role_surface("record")[0] as Dictionary).get("surface_id", "")), "doc_r1_wrong_return_log")
	assert_eq(state.encounter_role_surface("resource_node").size(), 1)
	assert_eq(state.encounter_role_surface("route").size(), 0)
	assert_eq(state.encounter_role_surface("actor").size(), 0)
	assert_eq(state.encounter_role_surface("true_actor").size(), 0)
	for entry: Dictionary in state.encounter_target_roles:
		var role: String = String(entry.get("role", ""))
		assert_true(TopDownActionRpgCombatState.TARGET_ROLES.has(role), role)
		assert_false(TopDownActionRpgCombatState.TARGET_MODES.has(role), role)
	var door_state: TopDownActionRpgCombatState = _new_combat_state(2)
	_build_roster(door_state)
	_new_controller(door_state, _catalog.record("enc_r1_door_role_test"))
	assert_eq(door_state.encounter_role_surface("route").size(), 1)
	assert_eq(String((door_state.encounter_role_surface("route")[0] as Dictionary).get("surface_id", "")), "gate_g1_ash_debt")
	var priority_roles: Dictionary = {}
	for entry: Variant in encounter.get("target_priority", []):
		priority_roles[String((entry as Dictionary).get("role", ""))] = true
	assert_true(priority_roles.has("true_actor"))
	assert_false(priority_roles.has("record"))
	assert_false(priority_roles.has("route"))
	assert_false(priority_roles.has("resource_node"))
	assert_true(TopDownActionRpgContentLoader.TARGET_PRIORITY_ROLES.is_empty() == false)
	assert_eq(TopDownActionRpgCombatState.TARGET_ROLES, TopDownActionRpgContentLoader.TARGET_ROLES)


func test_scheduler_rate_slots_and_turn_cost_are_independent() -> void:
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	assert_eq(TopDownActionRpgCombatState.TURN_COST_MIN, 0)
	assert_eq(TopDownActionRpgCombatState.TURN_COST_MAX, 5)
	assert_eq(TopDownActionRpgActionScheduler.NO_TURN, 0)
	assert_eq(TopDownActionRpgActionScheduler.PASS_TURN_COST, 1)
	assert_eq(TopDownActionRpgActionScheduler.schedule_rate(player, {}, {}), 10)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(0, 10), 0)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(1, 10), 1)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(2, 10), 2)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(3, 10), 2)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(5, 10), 3)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(1, 1), 6)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(5, 1), 30)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(-4, 10), 0)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(9, 10), 3)
	var one_slot := _make_actor("act_slot_one", "player_side", 1, 20, 20, 10, {"action_slots": 1})
	var three_slots := _make_actor("act_slot_three", "player_side", 1, 20, 20, 10, {"action_slots": 3})
	assert_eq(TopDownActionRpgCombatState.effective_action_slots(one_slot), 1)
	assert_eq(TopDownActionRpgCombatState.effective_action_slots(three_slots), 3)
	assert_eq(TopDownActionRpgActionScheduler.schedule_rate(one_slot, {}, {}), 10)
	assert_eq(TopDownActionRpgActionScheduler.schedule_rate(three_slots, {}, {}), 10)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(1, TopDownActionRpgActionScheduler.schedule_rate(one_slot, {}, {})), 1)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(1, TopDownActionRpgActionScheduler.schedule_rate(three_slots, {}, {})), 1)
	assert_eq(TopDownActionRpgActionScheduler.free_slots(one_slot, 0), 1)
	assert_eq(TopDownActionRpgActionScheduler.free_slots(three_slots, 2), 1)
	assert_eq(TopDownActionRpgActionScheduler.free_slots(one_slot, 5), 0)
	assert_eq(TopDownActionRpgActionScheduler.next_window_tick(0, 3, 10), 2)
	assert_eq(TopDownActionRpgActionScheduler.next_window_tick(0, 1, 10), 1)
	assert_eq(TopDownActionRpgActionScheduler.next_window_tick(7, 0, 10), 7)
	var slow := _make_actor("act_slow_one", "player_side", 1, 20, 20, 4, {"action_slots": 3})
	assert_eq(TopDownActionRpgActionScheduler.schedule_rate(slow, {}, {}), 4)
	assert_eq(TopDownActionRpgCombatState.effective_action_slots(slow), 3)
	assert_eq(TopDownActionRpgActionScheduler.delay_ticks(3, 4), 5)
	assert_eq(TopDownActionRpgCombatState.effective_stat(player, "agility", {"agility": 2}, {"agility": 3}), 15)
	assert_eq(TopDownActionRpgCombatState.effective_stat(player, "not_a_stat", {}, {}), 0)
	var tick_state: TopDownActionRpgCombatState = _new_combat_state()
	assert_true(TopDownActionRpgActionScheduler.advance_cycle(tick_state))
	assert_eq(tick_state.scheduler_tick, 1)
	assert_eq(tick_state.cycle_index, 0)
	for _step: int in range(5):
		TopDownActionRpgActionScheduler.advance_cycle(tick_state)
	assert_eq(tick_state.scheduler_tick, 6)
	assert_eq(tick_state.cycle_index, 1)


func test_turn_cost_zero_one_and_committed_have_three_semantics() -> void:
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	var controller: TopDownActionRpgCombatController = _new_controller(state)
	assert_eq(controller.begin_actor_window(player.actor_id), "window_open")
	assert_eq(int(controller.consumed_slots.get(player.actor_id, -1)), 0)
	var tick_before: int = state.scheduler_tick
	var next_before: int = player.next_window_tick
	var no_turn: TopDownActionRpgCombatState.ResolutionOutcome = controller.queue_action(StringName(PROBE_NO_TURN_ID), &"")
	assert_eq(no_turn.result_code, "resolved")
	assert_eq(no_turn.consumed_resources.size(), 0)
	assert_eq(state.queue.size(), 0)
	assert_eq(int(controller.consumed_slots.get(player.actor_id, -1)), 0)
	assert_eq(state.scheduler_tick, tick_before)
	assert_eq(player.next_window_tick, next_before)
	assert_eq(controller.current_actor_id, player.actor_id)
	assert_eq(int(TopDownActionRpgCombatState.effective_action_slots(player)), 1)
	var normal: TopDownActionRpgCombatState.ResolutionOutcome = controller.queue_action(&"act_ash_sweep", &"act_enemy_one")
	assert_eq(normal.result_code, "queued")
	assert_eq(state.queue.size(), 1)
	assert_eq(int((state.queue[0] as TopDownActionRpgCombatState.QueuedIntent).turn_cost), 1)
	assert_eq(int(controller.consumed_slots.get(player.actor_id, -1)), 1)
	assert_eq(controller.current_actor_id, &"")
	assert_eq(player.next_window_tick, tick_before + TopDownActionRpgActionScheduler.delay_ticks(1, 10))
	var multi_state: TopDownActionRpgCombatState = _new_combat_state(2)
	var multi_roster: Array = _build_roster(multi_state, {}, {})
	var multi_player: TopDownActionRpgCombatState.ActorState = multi_roster[0]
	multi_player.action_slot_snapshot = 3
	var multi_controller: TopDownActionRpgCombatController = _new_controller(multi_state)
	assert_eq(multi_controller.begin_actor_window(multi_player.actor_id), "window_open")
	assert_eq(int(multi_controller.consumed_slots.get(multi_player.actor_id, -1)), 0)
	multi_controller.queue_action(&"act_ash_sweep", &"act_enemy_one")
	assert_eq(multi_controller.current_actor_id, multi_player.actor_id)
	multi_controller.queue_action(&"act_guard_set", &"")
	assert_eq(int(state.queue.size()), 1)
	assert_eq(multi_state.queue.size(), 2)
	assert_eq(int(multi_controller.consumed_slots.get(multi_player.actor_id, -1)), 2)
	multi_controller.end_actor_window()
	assert_eq(multi_player.next_window_tick, TopDownActionRpgActionScheduler.delay_ticks(2, 10))
	var committed_state: TopDownActionRpgCombatState = _new_combat_state(3)
	var committed_roster: Array = _build_roster(committed_state)
	var committed_player: TopDownActionRpgCombatState.ActorState = committed_roster[0]
	var committed_controller: TopDownActionRpgCombatController = _new_controller(committed_state)
	assert_eq(committed_controller.begin_actor_window(committed_player.actor_id), "window_open")
	var committed: TopDownActionRpgCombatState.ResolutionOutcome = committed_controller.queue_action(&"act_fold_wall_verdict", &"act_enemy_one")
	assert_eq(committed.result_code, "queued")
	assert_eq(int((committed_state.queue[0] as TopDownActionRpgCombatState.QueuedIntent).turn_cost), 3)
	assert_eq(int(committed_controller.consumed_slots.get(committed_player.actor_id, -1)), 1)
	assert_eq(committed_controller.current_actor_id, &"")
	assert_eq(committed_player.next_window_tick, TopDownActionRpgActionScheduler.delay_ticks(3, 10))
	assert_true(committed_player.next_window_tick > TopDownActionRpgActionScheduler.delay_ticks(1, 10))
	var locked: TopDownActionRpgCombatState.ResolutionOutcome = committed_controller.queue_action(&"act_guard_set", &"")
	assert_eq(locked.result_code, "skipped_dead_actor")
	assert_true(TopDownActionRpgCombatState.RESULT_CODES.has(locked.result_code))
	assert_eq(committed_state.queue.size(), 1)
	var authored_costs: Dictionary = {}
	for action_id: String in _catalog.ids_of_kind("actions"):
		authored_costs[action_id] = int((_catalog.record(action_id).get("cost", {}) as Dictionary).get("turn_cost", -1))
	assert_eq(int(authored_costs["act_file_return_form"]), 0)
	assert_eq(int(authored_costs["act_fold_wall_measure"]), 0)
	assert_eq(int(authored_costs["act_ash_sweep"]), 1)
	assert_eq(int(authored_costs["act_guard_set"]), 1)
	assert_eq(int(authored_costs["act_fold_wall_verdict"]), 3)
	assert_eq(int((_catalog.record("act_fold_wall_verdict").get("commitment", {}) as Dictionary).get("spans_windows", 0)), 3)


func test_queue_order_applies_the_declared_total_tie_break() -> void:
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	player.tie_break_rank = 1
	var late_tick := _intent(player, "act_probe_a", "ONE_ENEMY", &"act_enemy_one", 1, 0)
	late_tick.ready_tick = 5
	var early_tick := _intent(player, "act_probe_b", "ONE_ENEMY", &"act_enemy_one", 1, 1)
	early_tick.ready_tick = 1
	var low_rank := _intent(player, "act_probe_c", "ONE_ENEMY", &"act_enemy_one", 1, 2)
	low_rank.ready_tick = 2
	low_rank.tie_break_rank = 0
	var high_rank := _intent(player, "act_probe_d", "ONE_ENEMY", &"act_enemy_one", 1, 3)
	high_rank.ready_tick = 2
	high_rank.tie_break_rank = 4
	var early_command := _intent(player, "act_probe_e", "ONE_ENEMY", &"act_enemy_one", 1, 1)
	early_command.ready_tick = 2
	var late_command := _intent(player, "act_probe_f", "ONE_ENEMY", &"act_enemy_one", 1, 2)
	late_command.ready_tick = 2
	var order: Array = TopDownActionRpgActionScheduler.sort_ready_queue([late_tick, early_tick, high_rank, low_rank, late_command, early_command])
	var order_ids: Array = []
	for entry: TopDownActionRpgCombatState.QueuedIntent in order:
		order_ids.append(String(entry.action_id))
	assert_eq(order_ids, ["act_probe_b", "act_probe_c", "act_probe_e", "act_probe_f", "act_probe_d", "act_probe_a"])
	assert_eq(TopDownActionRpgActionScheduler.sort_ready_queue([late_command, early_command]), TopDownActionRpgActionScheduler.sort_ready_queue([early_command, late_command]))
	assert_eq(String(TopDownActionRpgActionScheduler.build_intent(state, player, _catalog.record("act_ash_sweep"), &"act_enemy_one", 7).intent_id), PROBE_ENCOUNTER_ID + "|act_player_one|" + str(player.window_serial) + "|7")


func test_same_seed_and_commands_replay_identically_without_frame_entropy() -> void:
	var first: Array = _canonical_ledger(_run_scripted_scenario(4))
	var second: Array = _canonical_ledger(_run_scripted_scenario(4))
	assert_gt(first.size(), 4)
	assert_eq(first, second)
	var seed_four: int = TopDownActionRpgGameState.stable_seed(PROBE_ENCOUNTER_ID, 4)
	assert_eq(seed_four, TopDownActionRpgGameState.stable_seed(PROBE_ENCOUNTER_ID, 4))
	assert_ne(seed_four, TopDownActionRpgGameState.stable_seed(PROBE_ENCOUNTER_ID, 5))
	assert_ne(TopDownActionRpgGameState.stable_seed("enc_alpha_probe", 1), TopDownActionRpgGameState.stable_seed("enc_beta_probe", 1))
	assert_true(TopDownActionRpgGameState.stable_seed("enc_zero_probe", 0) != 0)
	assert_eq(_roll_stream(seed_four, 64), _roll_stream(seed_four, 64))
	assert_ne(_roll_stream(seed_four, 64), _roll_stream(TopDownActionRpgGameState.stable_seed(PROBE_ENCOUNTER_ID, 5), 64))
	var joined: String = _module_source()
	assert_gt(joined.length(), 0)
	for token: String in FORBIDDEN_RUNTIME_TOKENS:
		assert_false(joined.contains(token), token)


func test_target_modes_resolve_to_stable_actor_ids() -> void:
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	var ally: TopDownActionRpgCombatState.ActorState = roster[1]
	var enemy_a: TopDownActionRpgCombatState.ActorState = roster[2]
	var enemy_b: TopDownActionRpgCombatState.ActorState = roster[3]
	var controller: TopDownActionRpgCombatController = _new_controller(state)
	assert_eq(state.valid_targets_for(player, "SELF", "living"), [player.actor_id])
	assert_eq(state.valid_targets_for(player, "ONE_ALLY", "living"), [player.actor_id, ally.actor_id])
	assert_eq(state.valid_targets_for(player, "ONE_ENEMY", "living"), [enemy_a.actor_id, enemy_b.actor_id])
	assert_eq(state.valid_targets_for(player, "ALL_ENEMIES", "living"), [enemy_a.actor_id, enemy_b.actor_id])
	assert_eq(state.valid_targets_for(player, "ALL_ALLIES", "living"), [player.actor_id, ally.actor_id])
	assert_eq(state.valid_targets_for(player, "RANDOM_ENEMY", "living"), [enemy_a.actor_id, enemy_b.actor_id])
	assert_eq(state.target_focus_sequence(player, "ONE_ENEMY", "living"), [enemy_a.actor_id, enemy_b.actor_id])
	assert_eq(state.target_focus_sequence(player, "ONE_ALLY", "living"), [player.actor_id, ally.actor_id])
	controller.begin_actor_window(player.actor_id)
	controller.set_pending_action(&"act_guard_set")
	assert_eq(controller.enter_target_select(&"act_guard_set"), "no_target_required")
	assert_eq(state.submode, "command_action")
	controller.set_pending_action(&"act_ash_sweep")
	assert_eq(controller.enter_target_select(&"act_ash_sweep"), "target_select")
	assert_eq(controller.target_focus_actor_id, enemy_a.actor_id)
	assert_eq(state.submode, "target_select")
	assert_true(controller.move_target_focus(1))
	assert_eq(controller.target_focus_actor_id, enemy_b.actor_id)
	assert_true(controller.move_target_focus(1))
	assert_eq(controller.target_focus_actor_id, enemy_b.actor_id)
	assert_true(controller.move_target_focus(-1))
	assert_eq(controller.target_focus_actor_id, enemy_a.actor_id)
	assert_true(controller.cancel_target_select())
	assert_eq(state.submode, "command_action")
	assert_eq(controller.target_focus_actor_id, &"")
	var sweep: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(controller, player, PROBE_AOE_ID, state.valid_targets_for(player, "ALL_ENEMIES", "living"))
	assert_eq(sweep.result_code, "resolved")
	assert_eq(sweep.target_ids, ["act_enemy_one", "act_enemy_two"])
	assert_eq(int(sweep.damage_by_actor.get("act_enemy_one", 0)), 7)
	assert_eq(int(sweep.damage_by_actor.get("act_enemy_two", 0)), 7)
	assert_false(sweep.damage_by_actor.has("act_player_one"))
	assert_false(sweep.damage_by_actor.has("act_ally_two"))
	enemy_b.alive = false
	assert_eq(state.valid_targets_for(player, "ALL_ENEMIES", "living"), [enemy_a.actor_id])
	var partial: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(controller, player, PROBE_AOE_ID, state.valid_targets_for(player, "ALL_ENEMIES", "living"), 1)
	assert_eq(partial.result_code, "resolved")
	assert_eq(partial.target_ids, ["act_enemy_one"])
	enemy_b.removed = true
	enemy_a.alive = false
	var none_left: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(controller, player, PROBE_AOE_ID, state.valid_targets_for(player, "ALL_ENEMIES", "living"), 2)
	assert_eq(none_left.result_code, "skipped_no_valid_target")
	assert_eq(none_left.target_ids, [])
	assert_eq(int(sweep.damage_by_actor.get("act_enemy_one", 0)), 7)
	var random_hits: Array = []
	var repeat: Array = []
	for attempt: int in [3, 3, 7, 7]:
		var fresh: TopDownActionRpgCombatState = _new_combat_state(attempt)
		var fresh_roster: Array = _build_roster(fresh)
		var fresh_controller: TopDownActionRpgCombatController = _new_controller(fresh)
		fresh_controller.begin_actor_window(fresh_roster[0].actor_id)
		var queued: TopDownActionRpgCombatState.ResolutionOutcome = fresh_controller.queue_action(StringName(PROBE_RANDOM_ID), &"")
		assert_eq(queued.result_code, "queued")
		var drawn: String = ""
		for outcome: TopDownActionRpgCombatState.ResolutionOutcome in fresh_controller.advance():
			if not outcome.damage_by_actor.is_empty():
				drawn = String(outcome.damage_by_actor.keys()[0])
		random_hits.append(drawn)
		repeat.append(drawn)
	assert_eq(random_hits.size(), 4)
	for drawn: String in random_hits:
		assert_true(["act_enemy_one", "act_enemy_two"].has(drawn), drawn)
	assert_eq(repeat[0], repeat[1])
	assert_eq(repeat[2], repeat[3])
	var same_seed: TopDownActionRpgCombatState = _new_combat_state(3)
	_build_roster(same_seed)
	var same_controller: TopDownActionRpgCombatController = _new_controller(same_seed)
	same_controller.begin_actor_window(same_seed.find_actor(&"act_player_one").actor_id)
	same_controller.queue_action(StringName(PROBE_RANDOM_ID), &"")
	var other_seed: TopDownActionRpgCombatState = _new_combat_state(8)
	_build_roster(other_seed)
	var other_controller: TopDownActionRpgCombatController = _new_controller(other_seed)
	other_controller.begin_actor_window(other_seed.find_actor(&"act_player_one").actor_id)
	other_controller.queue_action(StringName(PROBE_RANDOM_ID), &"")
	assert_ne(same_seed.rng_state, other_seed.rng_state)
	var ally_state: TopDownActionRpgCombatState = _new_combat_state()
	var ally_roster: Array = _build_roster(ally_state)
	var ally_controller: TopDownActionRpgCombatController = _new_controller(ally_state)
	ally_controller.begin_actor_window(ally_roster[0].actor_id)
	var rally: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(ally_controller, ally_roster[0], PROBE_ALLY_AOE_ID, ally_state.valid_targets_for(ally_roster[0], "ALL_ALLIES", "living"))
	assert_eq(rally.result_code, "resolved")
	assert_eq(rally.target_ids, ["act_player_one", "act_ally_two"])
	assert_false(rally.damage_by_actor.has("act_enemy_one"))
	assert_eq(int(rally.damage_by_actor.get("act_player_one", 0)), 3)
	assert_eq(int(rally.damage_by_actor.get("act_ally_two", 0)), 3)


func test_attack_guard_dodge_and_break_produce_distinct_results() -> void:
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state, {}, {"defense": 10, "guard_efficiency": 500})
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	var enemy: TopDownActionRpgCombatState.ActorState = roster[2]
	var controller: TopDownActionRpgCombatController = _new_controller(state)
	controller.begin_actor_window(player.actor_id)
	var plain: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(controller, player, PROBE_HIT_ID, [enemy.actor_id])
	assert_eq(plain.result_code, "resolved")
	assert_eq(int(plain.damage_by_actor.get("act_enemy_one", 0)), 20)
	assert_eq(plain.stance_changes.size(), 0)
	assert_false(plain.dodged)
	assert_false(plain.break_applied)
	assert_false(plain.guard_broken)
	var guard_state: TopDownActionRpgCombatState = _new_combat_state()
	var guard_roster: Array = _build_roster(guard_state, {}, {"defense": 10, "guard_efficiency": 500})
	var guard_player: TopDownActionRpgCombatState.ActorState = guard_roster[0]
	var guard_target: TopDownActionRpgCombatState.ActorState = guard_roster[2]
	var guard_controller: TopDownActionRpgCombatController = _new_controller(guard_state)
	guard_controller.begin_actor_window(guard_target.actor_id)
	var guard_outcome: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(guard_controller, guard_target, "act_guard_set", [guard_target.actor_id])
	assert_eq(guard_outcome.result_code, "resolved")
	assert_eq(String(guard_outcome.stance_changes.get("act_enemy_one", "")), "guard")
	assert_true(guard_outcome.damage_by_actor.is_empty())
	assert_eq(guard_target.stance_state, "guard")
	assert_eq(guard_target.guard_window_budget, TopDownActionRpgCombatState.GUARD_WINDOW_BUDGET)
	assert_eq(TopDownActionRpgCombatState.GUARD_WINDOW_BUDGET, 2)
	guard_controller.begin_actor_window(guard_player.actor_id)
	var guarded: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(guard_controller, guard_player, PROBE_HIT_ID, [guard_target.actor_id])
	assert_eq(guarded.result_code, "resolved")
	assert_eq(int(guarded.damage_by_actor.get("act_enemy_one", 0)), 15)
	assert_lt(int(guarded.damage_by_actor.get("act_enemy_one", 0)), int(plain.damage_by_actor.get("act_enemy_one", 0)))
	assert_eq(guard_target.stance_state, "guard")
	assert_eq(guarded.stance_changes.size(), 0)
	assert_false(guarded.dodged)
	var pierce: Dictionary = (_overlay.record(PROBE_HIT_ID) as Dictionary).duplicate(true)
	(pierce.get("damage_payload", {}) as Dictionary)["guard_ignore"] = true
	guard_controller.begin_actor_window(guard_player.actor_id)
	var pierced: TopDownActionRpgCombatState.ResolutionOutcome = guard_controller.resolve_intent(
		_intent(guard_player, PROBE_HIT_ID, "ONE_ENEMY", guard_target.actor_id, 1, 1), guard_player, pierce, [guard_target.actor_id]
	)
	assert_eq(int(pierced.damage_by_actor.get("act_enemy_one", 0)), 20)
	var dodge_seed: int = _seed_with_permille(1, 1)
	assert_gt(dodge_seed, 0)
	var dodge_state: TopDownActionRpgCombatState = _new_combat_state(1, dodge_seed)
	var dodge_roster: Array = _build_roster(dodge_state)
	var dodge_player: TopDownActionRpgCombatState.ActorState = dodge_roster[0]
	var dodge_target: TopDownActionRpgCombatState.ActorState = dodge_roster[2]
	var dodge_controller: TopDownActionRpgCombatController = _new_controller(dodge_state)
	dodge_controller.begin_actor_window(dodge_target.actor_id)
	var dodge_outcome: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(dodge_controller, dodge_target, "act_dodge_shift", [dodge_target.actor_id])
	assert_eq(dodge_outcome.result_code, "resolved")
	assert_eq(String(dodge_outcome.stance_changes.get("act_enemy_one", "")), "dodge")
	assert_eq(dodge_target.stance_state, "dodge")
	dodge_controller.begin_actor_window(dodge_player.actor_id)
	var dodged: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(dodge_controller, dodge_player, PROBE_HIT_ID, [dodge_target.actor_id])
	assert_eq(dodged.result_code, "dodged")
	assert_true(dodged.dodged)
	assert_false(dodged.damage_by_actor.has("act_enemy_one"))
	assert_eq(dodge_target.hp, 50)
	var no_evade_attack: Dictionary = (_overlay.record(PROBE_HIT_ID) as Dictionary).duplicate(true)
	(no_evade_attack.get("damage_payload", {}) as Dictionary)["evasion_policy"] = "disabled"
	var not_dodged: TopDownActionRpgCombatState.ResolutionOutcome = dodge_controller.resolve_intent(
		_intent(dodge_player, PROBE_HIT_ID, "ONE_ENEMY", dodge_target.actor_id, 1, 2), dodge_player, no_evade_attack, [dodge_target.actor_id]
	)
	assert_false(not_dodged.dodged)
	assert_eq(int(not_dodged.damage_by_actor.get("act_enemy_one", 0)), 20)
	var break_state: TopDownActionRpgCombatState = _new_combat_state()
	var break_roster: Array = _build_roster(break_state, {}, {"break_resistance": 0})
	var break_player: TopDownActionRpgCombatState.ActorState = break_roster[0]
	var break_target: TopDownActionRpgCombatState.ActorState = break_roster[2]
	var break_controller: TopDownActionRpgCombatController = _new_controller(break_state)
	break_controller.begin_actor_window(break_player.actor_id)
	var broken: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(break_controller, break_player, "act_break_poise", [break_target.actor_id])
	assert_true(broken.break_applied)
	assert_eq(String(broken.stance_changes.get("act_enemy_one", "")), "broken")
	assert_eq(break_target.stance_state, "broken")
	assert_eq(break_target.broken_skip_budget, TopDownActionRpgCombatState.BROKEN_SKIP_BUDGET)
	assert_eq(TopDownActionRpgCombatState.BROKEN_SKIP_BUDGET, 2)
	assert_eq(int(broken.damage_by_actor.get("act_enemy_one", 0)), 0)
	assert_false(broken.dodged)
	break_controller.begin_actor_window(break_player.actor_id)
	var already: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(break_controller, break_player, "act_break_poise", [break_target.actor_id], 1)
	assert_eq(already.result_code, "skipped_already_broken")
	assert_false(already.break_applied)
	var immune_state: TopDownActionRpgCombatState = _new_combat_state()
	var immune_roster: Array = _build_roster(immune_state, {}, {"break_policy": "immune"})
	var immune_target: TopDownActionRpgCombatState.ActorState = immune_roster[2]
	var immune_controller: TopDownActionRpgCombatController = _new_controller(immune_state)
	immune_controller.begin_actor_window(immune_roster[0].actor_id)
	var immune: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(immune_controller, immune_roster[0], "act_break_poise", [immune_target.actor_id])
	assert_eq(immune.result_code, "skipped_break_immune")
	assert_eq(immune_target.stance_state, "normal")
	assert_eq(bool(TopDownActionRpgActionScheduler.apply_break(immune_state, immune_roster[0], immune_target, 99, true)), false)
	var resisted_state: TopDownActionRpgCombatState = _new_combat_state()
	var resisted_roster: Array = _build_roster(resisted_state, {}, {"break_resistance": 100})
	var resisted_target: TopDownActionRpgCombatState.ActorState = resisted_roster[2]
	var resisted_controller: TopDownActionRpgCombatController = _new_controller(resisted_state)
	resisted_controller.begin_actor_window(resisted_roster[0].actor_id)
	var resisted: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(resisted_controller, resisted_roster[0], "act_break_poise", [resisted_target.actor_id])
	assert_false(resisted.break_applied)
	assert_eq(resisted_target.stance_state, "normal")
	assert_ne(int(plain.damage_by_actor.get("act_enemy_one", 0)), int(guarded.damage_by_actor.get("act_enemy_one", 0)))
	assert_ne(int(guarded.damage_by_actor.get("act_enemy_one", 0)), int(dodged.damage_by_actor.get("act_enemy_one", -1)))
	assert_ne(String(guard_outcome.stance_changes.get("act_enemy_one", "")), String(broken.stance_changes.get("act_enemy_one", "")))
	assert_ne(String(guard_outcome.stance_changes.get("act_enemy_one", "")), String(dodge_outcome.stance_changes.get("act_enemy_one", "")))
	assert_eq(plain.stance_changes.size(), 0)
	assert_eq(guarded.stance_changes.size(), 0)
	assert_eq(broken.stance_changes.size(), 1)
	assert_eq(TopDownActionRpgCombatState.STANCE_STATES, ["normal", "guard", "dodge", "broken", "guard_broken"] as Array)


func test_guard_budget_break_skip_and_late_invalidation_are_atomic() -> void:
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	var enemy: TopDownActionRpgCombatState.ActorState = roster[2]
	player.stance_state = "guard"
	player.guard_window_budget = 2
	TopDownActionRpgActionScheduler.begin_window(state, player)
	assert_eq(player.stance_state, "guard")
	assert_eq(player.guard_window_budget, 1)
	TopDownActionRpgActionScheduler.begin_window(state, player)
	assert_eq(player.stance_state, "normal")
	assert_eq(player.guard_window_budget, 0)
	player.stance_state = "guard_broken"
	player.guard_broken_windows = 1
	TopDownActionRpgActionScheduler.begin_window(state, player)
	assert_eq(player.stance_state, "normal")
	assert_eq(bool(TopDownActionRpgActionScheduler.break_guard(state, enemy, 30, 5)), false)
	enemy.stance_state = "guard"
	assert_eq(bool(TopDownActionRpgActionScheduler.break_guard(state, enemy, 30, 5)), true)
	assert_eq(enemy.stance_state, "guard_broken")
	assert_eq(bool(TopDownActionRpgActionScheduler.break_guard(state, enemy, 1, 5)), false)
	assert_eq(enemy.stance_state, "guard_broken")
	assert_eq(bool(TopDownActionRpgActionScheduler.apply_break(state, player, enemy, 30, false)), true)
	assert_eq(enemy.stance_state, "broken")
	assert_eq(bool(TopDownActionRpgActionScheduler.consume_broken_budget(enemy)), true)
	assert_eq(enemy.broken_skip_budget, 1)
	assert_eq(enemy.stance_state, "broken")
	assert_eq(bool(TopDownActionRpgActionScheduler.consume_broken_budget(enemy)), true)
	assert_eq(enemy.broken_skip_budget, 0)
	assert_eq(enemy.stance_state, "normal")
	assert_eq(bool(TopDownActionRpgActionScheduler.consume_broken_budget(enemy)), false)
	var skip_state: TopDownActionRpgCombatState = _new_combat_state()
	var skip_roster: Array = _build_roster(skip_state)
	var skip_controller: TopDownActionRpgCombatController = _new_controller(skip_state)
	TopDownActionRpgActionScheduler.apply_break(skip_state, skip_roster[0], skip_roster[2], 30, false)
	assert_eq(skip_controller.begin_actor_window(skip_roster[2].actor_id), "skipped_broken_window")
	assert_eq(skip_roster[2].broken_skip_budget, 1)
	assert_eq(skip_controller.state.submode, "resolution_feedback")
	var invalid_state: TopDownActionRpgCombatState = _new_combat_state()
	var invalid_roster: Array = _build_roster(invalid_state, {"mp": 10, "max_mp": 10})
	var invalid_player: TopDownActionRpgCombatState.ActorState = invalid_roster[0]
	var invalid_enemy: TopDownActionRpgCombatState.ActorState = invalid_roster[2]
	var invalid_controller: TopDownActionRpgCombatController = _new_controller(invalid_state)
	assert_eq(invalid_controller.begin_actor_window(invalid_player.actor_id), "window_open")
	var queued: TopDownActionRpgCombatState.ResolutionOutcome = invalid_controller.queue_action(StringName(PROBE_COST_ID), &"act_enemy_one")
	assert_eq(queued.result_code, "queued")
	assert_eq(queued.action_id, PROBE_COST_ID)
	var pending_intent: TopDownActionRpgCombatState.QueuedIntent = invalid_state.queue[0]
	assert_eq(String(pending_intent.intent_id), String(queued.intent_id))
	var locked_tick: int = invalid_player.next_window_tick
	var before_hp: int = invalid_enemy.hp
	invalid_enemy.removed = true
	var invalidated: Array = []
	for outcome: TopDownActionRpgCombatState.ResolutionOutcome in invalid_controller.advance():
		if String(outcome.intent_id) == String(pending_intent.intent_id):
			invalidated.append(outcome)
	assert_eq(invalidated.size(), 1)
	var invalidated_code: String = String((invalidated[0] as TopDownActionRpgCombatState.ResolutionOutcome).result_code)
	assert_true(TopDownActionRpgCombatState.RESULT_CODES.has(invalidated_code))
	assert_eq(invalidated_code, "skipped_no_valid_target")
	assert_eq(invalid_player.mp, 10)
	assert_eq(invalid_enemy.hp, before_hp)
	assert_eq(invalid_player.next_window_tick, locked_tick)
	var dead_state: TopDownActionRpgCombatState = _new_combat_state()
	var dead_roster: Array = _build_roster(dead_state, {"mp": 10, "max_mp": 10})
	var dead_controller: TopDownActionRpgCombatController = _new_controller(dead_state)
	dead_controller.begin_actor_window(dead_roster[0].actor_id)
	dead_controller.queue_action(StringName(PROBE_COST_ID), &"act_enemy_one")
	var dead_intent: TopDownActionRpgCombatState.QueuedIntent = dead_state.queue[0]
	dead_roster[0].alive = false
	var dead_codes: Array = []
	for outcome: TopDownActionRpgCombatState.ResolutionOutcome in dead_controller.advance():
		if String(outcome.intent_id) == String(dead_intent.intent_id):
			dead_codes.append(String(outcome.result_code))
	assert_eq(dead_codes, ["skipped_dead_actor"])
	assert_eq(dead_roster[0].mp, 10)
	var stale_controller: TopDownActionRpgCombatController = _new_controller(_new_combat_state())
	var stale_state: TopDownActionRpgCombatState = _new_combat_state()
	var stale_roster: Array = _build_roster(stale_state, {"mp": 10, "max_mp": 10})
	stale_controller = _new_controller(stale_state)
	stale_controller.begin_actor_window(stale_roster[0].actor_id)
	var stale: TopDownActionRpgCombatState.ResolutionOutcome = stale_controller.resolve_intent(
		_intent(stale_roster[0], "act_break_poise", "ONE_ENEMY", &"act_enemy_ghost", 1, 0),
		stale_roster[0], _overlay.record("act_break_poise"), [&"act_enemy_ghost"]
	)
	assert_eq(stale.result_code, "skipped_target_invalidated")
	assert_eq(stale_roster[0].mp, 10)
	var death_state: TopDownActionRpgCombatState = _new_combat_state()
	var death_roster: Array = _build_roster(death_state)
	var death_controller: TopDownActionRpgCombatController = _new_controller(death_state)
	var doomed: TopDownActionRpgCombatState.ActorState = death_roster[3]
	var doomed_intent: TopDownActionRpgCombatState.QueuedIntent = _intent(doomed, "act_ash_sweep", "ONE_ENEMY", &"act_player_one", 1, 0)
	death_state.queue.append(doomed_intent)
	var aimed: TopDownActionRpgCombatState.QueuedIntent = _intent(death_roster[0], "act_ash_sweep", "ONE_ENEMY", doomed.actor_id, 1, 0)
	aimed.locked_target_ids = [doomed.actor_id]
	death_state.queue.append(aimed)
	assert_eq(death_state.queue.size(), 2)
	death_controller.begin_actor_window(death_roster[0].actor_id)
	var lethal: Dictionary = (_overlay.record(PROBE_HIT_ID) as Dictionary).duplicate(true)
	(lethal.get("damage_payload", {}) as Dictionary)["base_value"] = 999
	var death_outcome: TopDownActionRpgCombatState.ResolutionOutcome = death_controller.resolve_intent(
		_intent(death_roster[0], PROBE_HIT_ID, "ONE_ENEMY", doomed.actor_id, 1, 0), death_roster[0], lethal, [doomed.actor_id]
	)
	assert_eq(death_outcome.lethal_actor_ids, ["act_enemy_two"])
	assert_false(doomed.alive)
	assert_eq(doomed.stance_state, "normal")
	assert_null(doomed.charge_state)
	assert_eq(death_state.queue.has(doomed_intent), false)
	assert_eq(death_state.queue.has(aimed), true)
	assert_eq(aimed.locked_target_ids, [])
	assert_true(death_state.presentation_queue.has("actor_down"))


func test_charge_lifecycle_is_ordered_and_reaction_gated() -> void:
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	var enemy: TopDownActionRpgCombatState.ActorState = roster[2]
	var controller: TopDownActionRpgCombatController = _new_controller(state)
	assert_eq(TopDownActionRpgCombatState.CHARGE_STAGES, [
		"telegraph", "reaction", "strike", "recovery", "cancelled", "completed",
	] as Array)
	var charge_record: Dictionary = _catalog.record("act_ash_hound_lunge")
	assert_eq(String(charge_record.get("lifecycle", "")), "charge")
	assert_true((charge_record.get("telegraph", {}) as Dictionary).get("channels", [] as Array).size() >= 2)
	assert_true(int((charge_record.get("cost", {}) as Dictionary).get("turn_cost", 0)) >= 1)
	controller.begin_actor_window(player.actor_id)
	var started: TopDownActionRpgCombatState.ResolutionOutcome = controller.resolve_intent(
		_intent(player, "act_ash_hound_lunge", "ONE_ENEMY", enemy.actor_id, 1, 0), player, charge_record, [enemy.actor_id]
	)
	assert_eq(String(started.charge_transition), "telegraph")
	assert_not_null(player.charge_state)
	assert_eq(String(player.charge_state.stage), "telegraph")
	assert_eq(int(player.charge_state.stage_ordinal), 0)
	assert_true(player.charge_state.is_active())
	assert_eq(player.charge_state.valid_reaction_ids, ["act_dodge_shift"])
	assert_eq(player.charge_state.forbidden_response_ids, ["act_guard_set"])
	assert_eq(String(player.charge_state.strike_action_id), "act_ash_hound_lunge")
	assert_eq(String(player.charge_state.target_actor_id), String(enemy.actor_id))
	assert_eq(controller.begin_actor_window(player.actor_id), "charge_forced")
	assert_eq(state.submode, "reaction_select")
	assert_eq(TopDownActionRpgActionScheduler.resolve_charge_stage(state, player, &""), "reaction")
	assert_eq(int(player.charge_state.stage_ordinal), 1)
	assert_eq(int(player.charge_state.window_budget), 1)
	assert_eq(TopDownActionRpgActionScheduler.resolve_charge_stage(state, player, &"act_guard_set"), "strike")
	assert_eq(String(player.charge_state.stage), "strike")
	assert_eq(int(player.charge_state.stage_ordinal), 2)
	var cancel_state: TopDownActionRpgCombatState = _new_combat_state()
	var cancel_roster: Array = _build_roster(cancel_state)
	var cancel_actor: TopDownActionRpgCombatState.ActorState = cancel_roster[0]
	var cancel_controller: TopDownActionRpgCombatController = _new_controller(cancel_state)
	cancel_controller.begin_actor_window(cancel_actor.actor_id)
	cancel_controller.resolve_intent(
		_intent(cancel_actor, "act_ash_hound_lunge", "ONE_ENEMY", cancel_roster[2].actor_id, 1, 0),
		cancel_actor, charge_record, [cancel_roster[2].actor_id]
	)
	assert_eq(TopDownActionRpgActionScheduler.resolve_charge_stage(cancel_state, cancel_actor, &""), "reaction")
	assert_eq(TopDownActionRpgActionScheduler.resolve_charge_stage(cancel_state, cancel_actor, &"act_dodge_shift"), "cancelled")
	assert_eq(String(cancel_actor.charge_state.stage), "cancelled")
	assert_false(cancel_actor.charge_state.is_active())
	assert_eq(cancel_actor.stance_state, "normal")
	var strike_state: TopDownActionRpgCombatState = _new_combat_state()
	var strike_roster: Array = _build_roster(strike_state)
	var strike_actor: TopDownActionRpgCombatState.ActorState = strike_roster[0]
	var strike_controller: TopDownActionRpgCombatController = _new_controller(strike_state)
	strike_controller.begin_actor_window(strike_actor.actor_id)
	strike_controller.resolve_intent(
		_intent(strike_actor, "act_ash_hound_lunge", "ONE_ENEMY", strike_roster[2].actor_id, 1, 0),
		strike_actor, charge_record, [strike_roster[2].actor_id]
	)
	TopDownActionRpgActionScheduler.resolve_charge_stage(strike_state, strike_actor, &"")
	assert_eq(TopDownActionRpgActionScheduler.resolve_charge_stage(strike_state, strike_actor, &""), "strike")
	assert_eq(TopDownActionRpgActionScheduler.resolve_charge_stage(strike_state, strike_actor, &""), "recovery")
	assert_eq(int(strike_actor.charge_state.stage_ordinal), 3)
	assert_eq(TopDownActionRpgActionScheduler.resolve_charge_stage(strike_state, strike_actor, &""), "completed")
	assert_null(strike_actor.charge_state)
	var gate_state: TopDownActionRpgCombatState = _new_combat_state()
	var gate_roster: Array = _build_roster(gate_state)
	var gate_controller: TopDownActionRpgCombatController = _new_controller(gate_state)
	gate_controller.begin_actor_window(gate_roster[0].actor_id)
	gate_controller.resolve_intent(
		_intent(gate_roster[0], "act_ash_hound_lunge", "ONE_ENEMY", gate_roster[2].actor_id, 1, 0),
		gate_roster[0], charge_record, [gate_roster[2].actor_id]
	)
	assert_eq(gate_controller.offer_reaction(&"act_dodge_shift"), "skipped_action_unavailable")
	assert_not_null(gate_roster[0].charge_state)
	gate_controller.pending_charge = gate_roster[0].charge_state
	gate_controller.state.submode = "reaction_select"
	assert_eq(gate_controller.offer_reaction(&"act_guard_set"), "skipped_action_unavailable")
	assert_not_null(gate_roster[0].charge_state)
	assert_eq(String(gate_roster[0].charge_state.stage), "telegraph")
	assert_eq(gate_controller.offer_reaction(&"act_dodge_shift"), "charge_cancelled")
	assert_null(gate_roster[0].charge_state)
	assert_null(gate_controller.pending_charge)
	assert_eq(gate_controller.state.submode, "command_category")
	assert_true(gate_state.presentation_queue.has("charge_cancelled"))
	var fresh: TopDownActionRpgCombatState = _new_combat_state()
	var fresh_roster: Array = _build_roster(fresh)
	var started_charge: TopDownActionRpgCombatState.ChargeState = TopDownActionRpgActionScheduler.start_charge(
		fresh, fresh_roster[2], &"act_ash_hound_lunge", &"act_player_one", 0
	)
	assert_eq(int(started_charge.window_budget), 1)
	assert_eq(String(started_charge.stage), "telegraph")
	assert_eq(String(fresh_roster[2].charge_state.stage), "telegraph")


func test_status_apply_stack_block_and_cure_are_data_driven() -> void:
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	var enemy: TopDownActionRpgCombatState.ActorState = roster[2]
	var controller: TopDownActionRpgCombatController = _new_controller(state)
	assert_eq(int(TopDownActionRpgCombatState.effective_agility(enemy, {}, {})), 9)
	controller.begin_actor_window(player.actor_id)
	var applied: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(controller, player, PROBE_STATUS_TARGET_ID, [enemy.actor_id])
	assert_eq(applied.status_applied, ["st_recorded"])
	assert_eq(enemy.status_count(&"st_recorded"), 1)
	assert_not_null(enemy.find_status(&"st_recorded"))
	assert_eq(int(TopDownActionRpgCombatState.effective_agility(enemy, {}, {})), 8)
	controller.begin_actor_window(player.actor_id)
	var stacked: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(controller, player, PROBE_STATUS_TARGET_ID, [enemy.actor_id], 1)
	assert_eq(stacked.status_applied, ["st_recorded"])
	assert_eq(enemy.status_count(&"st_recorded"), 2)
	assert_eq(enemy.status_instances.size(), 1)
	var recorded_definition: Dictionary = _catalog.record("st_recorded")
	assert_eq(int(recorded_definition.get("max_stacks", 0)), 3)
	assert_eq(recorded_definition.get("stack_policy", ""), "stack")
	var instance: TopDownActionRpgCombatState.StatusInstance = enemy.status_instances[0]
	instance.remaining_windows = 1
	instance.active = false
	assert_null(enemy.find_status(&"st_recorded"))
	assert_eq(enemy.status_count(&"st_recorded"), 0)
	assert_eq(int(TopDownActionRpgCombatState.effective_agility(enemy, {}, {})), 9)
	var cured_state: TopDownActionRpgCombatState = _new_combat_state()
	var cured_roster: Array = _build_roster(cured_state)
	var cured_player: TopDownActionRpgCombatState.ActorState = cured_roster[0]
	var cured_controller: TopDownActionRpgCombatController = _new_controller(cured_state)
	cured_controller.begin_actor_window(cured_player.actor_id)
	var self_load: TopDownActionRpgCombatState.ResolutionOutcome = _run_now(cured_controller, cured_player, PROBE_STATUS_SELF_ID, [cured_player.actor_id])
	assert_eq(self_load.status_applied, ["st_concentration_load"])
	assert_eq(cured_player.status_count(&"st_concentration_load"), 1)
	var block_record: Dictionary = (_catalog.record("act_weave_lash") as Dictionary).duplicate(true)
	(block_record.get("cost", {}) as Dictionary)["resource_costs"] = {}
	assert_eq(int((block_record.get("cost", {}) as Dictionary).get("turn_cost", -1)), 1)
	assert_eq(cured_controller.command_unavailable_reason(cured_player, block_record), "skipped_blocked_by_status")
	assert_eq(cured_controller.command_is_available(cured_player, block_record), false)
	assert_gt(cured_controller.available_commands(cured_player.actor_id).size(), 0)
	var cure_instance: TopDownActionRpgCombatState.StatusInstance = cured_player.status_instances[0]
	assert_eq(cure_instance.payload.get("blocked_action_categories", []), ["magic"])
	cure_instance.active = false
	assert_eq(cured_controller.command_unavailable_reason(cured_player, block_record), "")
	assert_eq(cured_controller.command_is_available(cured_player, block_record), true)
	assert_eq(cured_player.status_count(&"st_concentration_load"), 0)
	assert_eq(cured_player.status_count(&"st_recorded"), 0)
	var poored_state: TopDownActionRpgCombatState = _new_combat_state()
	var poored_roster: Array = _build_roster(poored_state)
	var poored_controller: TopDownActionRpgCombatController = _new_controller(poored_state)
	poored_controller.begin_actor_window(poored_roster[0].actor_id)
	var poor: TopDownActionRpgCombatState.ResolutionOutcome = poored_controller.queue_action(&"act_weave_lash", &"act_enemy_one")
	assert_eq(poor.result_code, "skipped_insufficient_resource")
	assert_eq(poored_roster[0].mp, 0)
	assert_eq(poored_controller.queue_action(&"act_missing_probe", &"act_enemy_one").result_code, "skipped_action_unavailable")
	var cooldown_state: TopDownActionRpgCombatState = _new_combat_state()
	var cooldown_roster: Array = _build_roster(cooldown_state)
	var cooldown_controller: TopDownActionRpgCombatController = _new_controller(cooldown_state)
	cooldown_controller.begin_actor_window(cooldown_roster[0].actor_id)
	cooldown_controller.queue_action(&"act_break_poise", &"act_enemy_one")
	cooldown_controller.advance()
	cooldown_controller.begin_actor_window(cooldown_roster[0].actor_id)
	assert_eq(cooldown_controller.command_unavailable_reason(cooldown_roster[0], _overlay.record("act_break_poise")), "skipped_cooldown")
	assert_eq(int(cooldown_roster[0].action_cooldowns.get("act_break_poise", 0)), 1)
	var snapshot: Dictionary = state.to_dict()
	assert_true(TopDownActionRpgContentLoader.is_json_safe(snapshot))
	assert_true(TopDownActionRpgContentLoader.is_json_safe(instance.to_dict()))
	var restored: TopDownActionRpgCombatState = TopDownActionRpgCombatState.new()
	assert_true(restored.from_dict(snapshot))
	assert_eq(restored.to_dict(), snapshot)
	assert_eq((restored.find_actor(&"act_enemy_one") as TopDownActionRpgCombatState.ActorState).stance_state, enemy.stance_state)
	var rebuilt: TopDownActionRpgCombatState.StatusInstance = TopDownActionRpgCombatState.StatusInstance.from_dict(instance.to_dict())
	assert_not_null(rebuilt)
	assert_eq(rebuilt.definition_id, instance.definition_id)
	assert_eq(rebuilt.active, false)
	assert_null(TopDownActionRpgCombatState.StatusInstance.from_dict({"definition_id": "ST_RECORDED"}))
	assert_null(TopDownActionRpgCombatState.StatusInstance.from_dict({}))


func test_field_focus_interact_and_route_traversal() -> void:
	var game_state: TopDownActionRpgGameState = _new_game_state()
	var field := TopDownActionRpgFieldController.new()
	assert_true(field.setup(game_state, _catalog))
	assert_eq(StringName(game_state.region_id()), &"region_h0_undersign_exchange")
	assert_eq(field.interactables.size(), 4)
	assert_eq(field.clusters.size(), 1)
	assert_eq(String(field.clusters[0].starting_conversation_id), "conv_h0_return_desk")
	assert_eq((field.clusters[0].npc_ids as Array).size(), 4)
	assert_eq((field.clusters[0].thread_ids as Array).size(), 2)
	assert_eq(bool(field.active_cluster().fired), false)
	assert_eq(field.move(Vector2.ZERO, false), false)
	var start_x: float = float(game_state.field_actor().get("x", 0.0))
	assert_eq(field.move(Vector2(1.0, 0.0), false), true)
	assert_almost_eq(float(game_state.field_actor().get("x", 0.0)), start_x + TopDownActionRpgFieldController.MAX_TRAVEL_PER_STEP, 0.00001)
	assert_eq(int(game_state.field_actor().get("facing", -1)), 3)
	assert_eq(field.move(Vector2(0.0, -1.0), false), true)
	assert_eq(int(game_state.field_actor().get("facing", -1)), 0)
	assert_eq(field.move(Vector2(1.0, 1.0), true), true)
	assert_eq(String(game_state.region_id()), "region_h0_undersign_exchange")
	field.rebuild_region()
	field.game_state.set_field_actor(field.interactables[0].position.x, field.interactables[0].position.y, 0)
	assert_eq(field.interactables_in_reach().size(), 1)
	var focused: TopDownActionRpgFieldController.Interactable = field.focused_interactable()
	assert_not_null(focused)
	assert_eq(String(focused.interactable_id), "prop_h0_counterweight_map")
	assert_eq(focused.kind, "chest")
	assert_eq(String(focused.opens), "conv_h0_return_desk")
	assert_eq(focused.focusable, true)
	assert_eq(focused.enabled, true)
	assert_eq(focused.activation, "confirm")
	assert_eq(focused.repeat_policy, "resettable")
	assert_eq(field.move_focus(1), true)
	assert_eq(int(field.focus_index), 1)
	assert_eq(String(field.focused_interactable().interactable_id), "prop_h0_ration_counter")
	assert_eq(field.move_focus(-1), true)
	assert_eq(String(field.focused_interactable().interactable_id), "prop_h0_counterweight_map")
	assert_eq(field.focused_interactable().presentation_class, "neutral")
	var npc_entry: TopDownActionRpgFieldController.Interactable = field.interactables[2]
	assert_eq(npc_entry.kind, "npc")
	assert_eq(String(npc_entry.interactable_id), "npc_01_ilyra_senn")
	assert_eq(npc_entry.presentation_class, "official")
	assert_eq(String(npc_entry.opens), "conv_h0_return_desk")
	var passage: TopDownActionRpgFieldController.Interactable = field.interactables[3]
	assert_eq(passage.kind, "passage")
	assert_eq(String(passage.interactable_id), "route_e01_ash_stair")
	assert_eq(passage.repeat_policy, "persistent")
	var out_of_reach: Dictionary = field.interact()
	assert_eq(String(out_of_reach.get("result", "")), "interacted")
	field.game_state.set_field_actor(0.0, 0.0, 0)
	var blocked: Dictionary = field.interact()
	assert_eq(String(blocked.get("result", "")), "skipped_out_of_reach")
	field.game_state.set_field_actor(focused.position.x, focused.position.y, 0)
	var interacted: Dictionary = field.interact()
	assert_eq(String(interacted.get("result", "")), "interacted")
	assert_eq(String(interacted.get("interactable_id", "")), "prop_h0_counterweight_map")
	assert_eq(String(interacted.get("opens", "")), "conv_h0_return_desk")
	assert_eq(String(game_state.field.get("active_interaction_id", "")), "prop_h0_counterweight_map")
	assert_eq(String(field.active_interaction_id), "prop_h0_counterweight_map")
	assert_eq(int(focused.used_count), 2)
	focused.repeat_policy = "once"
	var already: Dictionary = field.interact()
	assert_eq(String(already.get("result", "")), "skipped_already_used")
	assert_eq(field.blocked_reason, "skipped_already_used")
	assert_eq(String(field.traverse("route_missing_probe").get("result", "")), "skipped_no_route")
	var edges: Array = field.available_edges()
	assert_eq(edges.size(), 1)
	assert_eq(String((edges[0] as Dictionary).get("edge_id", "")), "route_e01_ash_stair")
	assert_eq(String((edges[0] as Dictionary).get("route_state", "")), "open")
	assert_eq(field.route_state("route_e01_ash_stair"), "open")
	assert_eq(game_state.route_state("route_e01_ash_stair"), "locked")
	var traversed: Dictionary = field.traverse("route_e01_ash_stair")
	assert_eq(String(traversed.get("result", "")), "traversed")
	assert_eq(String(traversed.get("region_id", "")), "region_r1_returning_kiln")
	assert_eq(String(game_state.region_id()), "region_r1_returning_kiln")
	assert_eq(String(game_state.field.get("anchor_id", "")), "route_e01_ash_stair_return")
	assert_eq(int((game_state.world["regions"]["region_r1_returning_kiln"] as Dictionary).get("visit_count", 0)), 1)
	assert_eq(String(game_state.field.get("active_interaction_id", "!")), "")
	assert_eq(field.interactables.size(), 6)
	assert_eq(field.route_state("route_e02_folding_school_dispatch"), "conditional")
	var locked_route: Dictionary = field.traverse("route_e02_folding_school_dispatch")
	assert_eq(String(locked_route.get("result", "")), "route_locked")
	assert_eq(String(locked_route.get("gate_id", "")), "gate_g1_ash_debt")
	assert_eq(String(game_state.region_id()), "region_r1_returning_kiln")
	assert_eq(game_state.set_prop_state("prop_r1_ash_garden_thread", "ps_spent"), true)
	var unlocked: Dictionary = field.traverse("route_e02_folding_school_dispatch")
	assert_eq(String(unlocked.get("result", "")), "traversed")
	assert_eq(String(unlocked.get("region_id", "")), "region_r8_folding_school")
	assert_eq(String(game_state.region_id()), "region_r8_folding_school")
	assert_eq(TopDownActionRpgContentLoader.gate_is_declared(_catalog, "gate_g1_ash_debt"), true)
	assert_eq(TopDownActionRpgContentLoader.gate_is_declared(_catalog, "gate_g9_missing"), false)
	assert_eq(game_state.set_route_state("route_e01_ash_stair", "not_a_state", "ev"), false)
	assert_eq(game_state.route_state("route_e01_ash_stair"), "locked")
	assert_eq(game_state.route_state("route_missing_probe"), "locked")
	var snapshot: Dictionary = field.field_snapshot()
	assert_true(TopDownActionRpgContentLoader.is_json_safe(snapshot))
	assert_eq(String(snapshot.get("region_id", "")), "region_r8_folding_school")
	assert_eq((snapshot["clusters"] as Array).size(), 1)


func test_disabled_focusable_and_presentation_class_are_separate_from_focus() -> void:
	var game_state: TopDownActionRpgGameState = _new_game_state()
	var field := TopDownActionRpgFieldController.new()
	assert_true(field.setup(game_state, _catalog))
	var disabled := TopDownActionRpgFieldController.Interactable.new()
	disabled.interactable_id = &"prop_core_probe_disabled"
	disabled.kind = "chest"
	disabled.enabled = false
	disabled.focusable = true
	disabled.priority = 99
	disabled.position = field.interactables[0].position
	field.interactables.append(disabled)
	var unfocusable := TopDownActionRpgFieldController.Interactable.new()
	unfocusable.interactable_id = &"prop_core_probe_unfocusable"
	unfocusable.enabled = true
	unfocusable.focusable = false
	unfocusable.priority = 98
	unfocusable.position = field.interactables[0].position
	field.interactables.append(unfocusable)
	field.game_state.set_field_actor(field.interactables[0].position.x, field.interactables[0].position.y, 0)
	var reported: Dictionary = {}
	for entry: Dictionary in (field.field_snapshot() as Dictionary)["interactables"]:
		if String(entry.get("interactable_id", "")).begins_with("prop_core_probe_"):
			reported[String(entry["interactable_id"])] = entry
	assert_eq(reported.size(), 2)
	var disabled_row: Dictionary = reported["prop_core_probe_disabled"]
	assert_eq(disabled_row["enabled"], false)
	assert_eq(disabled_row["focusable"], true)
	assert_eq(disabled_row.has("disabled"), false)
	var unfocusable_row: Dictionary = reported["prop_core_probe_unfocusable"]
	assert_eq(unfocusable_row["enabled"], true)
	assert_eq(unfocusable_row["focusable"], false)
	assert_eq(field.interactables_in_reach().size(), 1)
	assert_eq(field.interactables_in_reach().has(disabled), false)
	assert_eq(field.interactables_in_reach().has(unfocusable), false)
	assert_eq(field.focus_candidates().has(disabled), false)
	assert_eq(field.focus_candidates().has(unfocusable), false)
	assert_eq(field.focus_candidates().size(), field.interactables.size() - 2)
	var conversation := TopDownActionRpgConversationController.new()
	assert_true(conversation.setup(game_state, _overlay))
	assert_eq(conversation.open_conversation(StringName(PROBE_CONVERSATION_ID), &"prop_h0_counterweight_map"), "opened")
	assert_eq(game_state.mode, "dialogue")
	assert_eq(String(game_state.field.get("active_interaction_id", "")), "prop_h0_counterweight_map")
	assert_eq(conversation.focus_kind(), "page_advance")
	assert_eq(conversation.page_presentation_class(), "neutral")
	assert_eq(conversation.page_is_red(), false)
	assert_eq(conversation.page_focus_channel(), "text_and_bracket")
	assert_eq(conversation.advance_page(), "page_advanced")
	assert_eq(conversation.at_choice_set(), true)
	assert_eq(conversation.focus_kind(), "choice")
	var rows: Array = conversation.choice_rows()
	assert_eq(rows.size(), 2)
	assert_eq(String((rows[0] as Dictionary)["choice_id"]), "ch_probe_open")
	assert_eq(bool((rows[0] as Dictionary)["available"]), true)
	assert_eq(bool((rows[0] as Dictionary)["disabled"]), false)
	assert_eq(bool((rows[0] as Dictionary)["focusable"]), true)
	assert_eq(bool((rows[0] as Dictionary)["is_red"]), false)
	assert_eq(bool((rows[1] as Dictionary)["available"]), false)
	assert_eq(bool((rows[1] as Dictionary)["disabled"]), true)
	assert_eq(bool((rows[1] as Dictionary)["visible"]), true)
	assert_eq(bool((rows[1] as Dictionary)["focusable"]), true)
	assert_eq(String((rows[1] as Dictionary)["unavailable_reason"]), "not_filed_yet")
	assert_eq(String((rows[1] as Dictionary)["presentation_class"]), "extreme")
	assert_eq(bool((rows[1] as Dictionary)["is_red"]), true)
	assert_eq(conversation.visible_choice_count(), 2)
	assert_eq(conversation.move_choice_focus(1), true)
	assert_eq(String(conversation.focused_choice().get("choice_id", "")), "ch_probe_blocked")
	assert_eq(conversation.move_choice_focus(1), true)
	assert_eq(String(conversation.focused_choice().get("choice_id", "")), "ch_probe_open")
	assert_eq(conversation.move_choice_focus(-1), true)
	assert_eq(String(conversation.focused_choice().get("choice_id", "")), "ch_probe_blocked")
	var before: Dictionary = game_state.to_dict()
	var blocked: Dictionary = conversation.confirm_choice()
	assert_eq(String(blocked.get("result", "")), "skipped_blocked_by_status")
	assert_eq(String(blocked.get("reason", "")), "not_filed_yet")
	assert_eq(bool(conversation.committed), false)
	assert_eq(game_state.to_dict(), before)
	assert_eq(game_state.set_axis_value("protocol_legitimacy", 3, "ev_probe"), true)
	var rows_after: Array = conversation.choice_rows()
	assert_eq(bool((rows_after[1] as Dictionary)["available"]), true)
	assert_eq(bool((rows_after[1] as Dictionary)["disabled"]), false)
	assert_eq(bool((rows_after[1] as Dictionary)["is_red"]), true)
	assert_eq(String(conversation.focused_choice().get("presentation_class", "")), "extreme")
	var committed: Dictionary = conversation.confirm_choice()
	assert_eq(String(committed.get("result", "")), "committed")
	assert_eq(String(committed.get("choice_id", "")), "ch_probe_blocked")
	assert_eq(String(committed.get("closed", "")), "closed")
	assert_eq(bool(conversation.committed), false)
	assert_eq(String(conversation.conversation_id), "")
	assert_eq(conversation.cancel(), "already_closed")
	assert_eq(str(conversation.focus_kind()), "choice")
	var authored := TopDownActionRpgConversationController.new()
	assert_true(authored.setup(_new_game_state(), _catalog))
	assert_eq(authored.open_conversation(&"conv_h0_return_desk", &"npc_01_ilyra_senn"), "opened")
	authored.page_index = authored.pages().size()
	assert_eq(authored.at_choice_set(), true)
	var authored_rows: Array = authored.choice_rows()
	assert_eq(authored_rows.size(), 3)
	var classes: Array = []
	for row: Dictionary in authored_rows:
		classes.append(String(row["presentation_class"]))
		assert_eq(bool(row["focusable"]), true)
		assert_eq(bool(row["available"]), true)
	assert_true(classes.has("extreme"))
	assert_true(classes.has("neutral"))
	assert_true(TopDownActionRpgConversationController.CHOICE_PRESENTATION_CLASSES.has("extreme"))
	assert_eq(TopDownActionRpgConversationController.CHOICE_PRESENTATION_CLASSES.has("official"), false)
	assert_eq(TopDownActionRpgConversationController.RETURN_FOCUS_VALUES, ["field", "choice", "conversation"] as Array)
	assert_eq(TopDownActionRpgConversationController.RED_PRESENTATION_CLASSES.has("official"), false)


func test_document_pages_respect_nine_line_cap_and_authored_corruption() -> void:
	assert_eq(TopDownActionRpgContentLoader.DOCUMENT_PAGE_LINE_CAP, 9)
	assert_eq(TopDownActionRpgConversationController.MAX_LINES_PER_PAGE, 9)
	assert_eq(TopDownActionRpgGameState.DOCUMENT_PAGE_LINE_CAP, 9)
	assert_eq(TopDownActionRpgContentLoader.DOCUMENT_PRESENTATIONS, ["plain", "redacted", "corrupted"] as Array)
	assert_eq(TopDownActionRpgConversationController.DOCUMENT_PRESENTATIONS, ["plain", "redacted", "corrupted"] as Array)
	assert_eq(TopDownActionRpgContentLoader.CORRUPTION_MODES, ["recolor", "replace_token", "shatter_line", "drop_glyph"] as Array)
	var index_text: String = FileAccess.get_file_as_string(TopDownActionRpgContentLoader.INDEX_PATH)
	assert_gt(index_text.length(), 0)
	var index_document: Dictionary = JSON.parse_string(index_text)
	var index_options: Dictionary = index_document.get("options", {})
	assert_eq(int(index_options.get("document_page_line_cap", 0)), 9)
	for document_id: String in _catalog.ids_of_kind("documents"):
		var record: Dictionary = _catalog.record(document_id)
		var reading: Dictionary = record.get("reading", {}) as Dictionary
		assert_true(int(reading.get("max_lines_per_page", 99)) <= 9, document_id)
		assert_true(int(reading.get("min_font_size", 0)) >= TopDownActionRpgContentLoader.DOCUMENT_MIN_FONT_SIZE, document_id)
		var pages: Array = record.get("pages", [])
		for page: Dictionary in pages:
			var lines: Array = page.get("lines", [])
			assert_gt(lines.size(), 0, document_id)
			assert_true(lines.size() <= 9, document_id)
			for line: Variant in lines:
				assert_true(String(line).length() <= TopDownActionRpgContentLoader.MAX_DOCUMENT_LINE_LENGTH, document_id)
			var rules: Array = page.get("corruption_rules", [])
			if String(page.get("presentation", "")) == "corrupted":
				assert_gt(rules.size(), 0, document_id)
			else:
				assert_eq(rules.size(), 0, document_id)
			for rule: Dictionary in rules:
				assert_true(TopDownActionRpgContentLoader.CORRUPTION_MODES.has(String(rule.get("mode", ""))), document_id)
				assert_true(not String(rule.get("text_note", "")).is_empty(), document_id)
				assert_eq(rule.has("rng_state"), false, document_id)
				assert_eq(rule.has("random_seed"), false, document_id)
	var game_state: TopDownActionRpgGameState = _new_game_state("region_r1_returning_kiln")
	var conversation := TopDownActionRpgConversationController.new()
	assert_true(conversation.setup(game_state, _catalog))
	assert_eq(conversation.open_document(&"doc_r1_wrong_return_log"), "opened")
	assert_eq(game_state.mode, "dialogue")
	assert_eq(conversation.document_page_count(), 2)
	assert_eq(conversation.document_lines().size(), 4)
	assert_eq(conversation.document_presentation(), "plain")
	assert_eq(conversation.advance_document(), "document_advanced")
	var first_read: Array = conversation.document_lines().duplicate()
	assert_eq(first_read.size(), 4)
	assert_eq(conversation.document_presentation(), "corrupted")
	var corrupt_page: Dictionary = (_catalog.record("doc_r1_wrong_return_log").get("pages", []) as Array)[1] as Dictionary
	var rules: Array = corrupt_page.get("corruption_rules", [])
	assert_eq(rules.size(), 1)
	var rule: Dictionary = rules[0] as Dictionary
	assert_eq(String(rule.get("rule_id", "")), "cr_category_line")
	assert_eq(String(rule.get("mode", "")), "recolor")
	assert_true(int(rule.get("line_index", -1)) < first_read.size())
	var trigger: Dictionary = rule.get("trigger", {})
	assert_eq(String((trigger.get("clock_at_least", {}) as Dictionary).get("clock_id", "")), "clock_public_record")
	assert_eq(int(game_state.clock_stage(game_state.region_id(), "clock_public_record")), 0)
	assert_eq(TopDownActionRpgContentLoader.evaluate_condition(trigger, game_state, _catalog), false)
	game_state.set_clock_stage(game_state.region_id(), "clock_public_record", 3, "ev_probe")
	assert_eq(TopDownActionRpgContentLoader.evaluate_condition(trigger, game_state, _catalog), true)
	assert_eq(TopDownActionRpgContentLoader.evaluate_condition(trigger, game_state, _catalog), TopDownActionRpgContentLoader.evaluate_condition(trigger, game_state, _catalog))
	assert_eq(conversation.document_lines(), first_read)
	assert_eq(conversation.advance_document(), "document_closed")
	assert_eq(int(game_state.document_read_count("doc_r1_wrong_return_log")), 1)
	assert_eq(String(conversation.document_id), "")
	assert_eq(conversation.open_document(&"doc_missing_probe"), "unknown_reference")
	var wide := TopDownActionRpgConversationController.new()
	assert_true(wide.setup(_new_game_state(), _overlay))
	assert_eq(wide.open_document(StringName(PROBE_DOCUMENT_ID)), "opened")
	assert_eq(wide.document_page_count(), 2)
	assert_eq(wide.document_lines().size(), 9)
	assert_eq(wide.advance_document(), "document_advanced")
	assert_eq(wide.document_presentation(), "corrupted")
	var probe_pages: Array = _overlay.record(PROBE_DOCUMENT_ID).get("pages", [])
	var probe_rule: Dictionary = (probe_pages[1] as Dictionary).get("corruption_rules", [])[0] as Dictionary
	assert_eq(String(probe_rule.get("mode", "")), "replace_token")
	assert_eq(String(probe_rule.get("replacement_seed_id", "")), "seed_s001")
	assert_true(not String(probe_rule.get("text_note", "")).is_empty())
	assert_eq(wide.document_lines().size(), 3)


func test_game_state_save_root_json_safety_and_stale_handling() -> void:
	var game_state: TopDownActionRpgGameState = _new_game_state()
	var payload: Dictionary = game_state.to_dict()
	var root_keys: Array = payload.keys()
	root_keys.sort()
	var expected_root: Array = SAVE_ROOT_KEYS.duplicate()
	expected_root.sort()
	assert_eq(root_keys, expected_root)
	assert_eq(payload.size(), 12)
	assert_eq(String(payload["state_format"]), TopDownActionRpgGameState.STATE_FORMAT)
	assert_eq(String(payload["state_format"]), "top_down_action_rpg.save.v1")
	assert_eq(int(payload["save_version"]), 1)
	assert_eq(String(payload["run_id"]), "run_region_h0_undersign_exchange")
	assert_eq(String(payload["content_revision"]), String(_catalog.content_signature))
	assert_true(TopDownActionRpgContentLoader.is_json_safe(payload))
	var floats: Array = []
	_collect_float_paths(payload, "root", floats)
	floats.sort()
	assert_eq(floats, ["root.field.actor.x", "root.field.actor.y"])
	var canonical: String = JSON.stringify(JSON.parse_string(JSON.stringify(payload)))
	var decoded: Variant = JSON.parse_string(JSON.stringify(payload))
	assert_true(decoded is Dictionary)
	assert_eq(JSON.stringify(decoded), canonical)
	var decoded_root: Dictionary = decoded
	assert_eq(String(decoded_root["state_format"]), "top_down_action_rpg.save.v1")
	assert_eq(int(decoded_root["save_version"]), 1)
	assert_eq(int((decoded_root["field"] as Dictionary)["actor"]["x"]), 0)
	var decoded_field: Dictionary = decoded_root["field"]
	assert_eq(float((decoded_field["actor"] as Dictionary)["x"]), 0.25)
	assert_eq(float((decoded_field["actor"] as Dictionary)["y"]), -0.5)
	assert_eq(int((decoded_root["combat"] as Dictionary)["attempt_serial"]), 0)
	var world: Dictionary = payload["world"]
	assert_eq(world.size(), TopDownActionRpgGameState.WORLD_KEYS.size())
	for world_key: String in TopDownActionRpgGameState.WORLD_KEYS:
		assert_true(world.has(world_key), world_key)
	var magic_keys: Array = (world["magic"] as Dictionary).keys()
	magic_keys.sort()
	var expected_magic: Array = TopDownActionRpgGameState.MAGIC_CHILDREN.duplicate()
	expected_magic.sort()
	assert_eq(magic_keys, expected_magic)
	for child: String in TopDownActionRpgGameState.MAGIC_CHILDREN:
		assert_eq((world["magic"] as Dictionary)[child].size(), 0)
	assert_eq(game_state.magic_child("contracts").size(), 0)
	assert_eq(game_state.magic_child("not_a_child").size(), 0)
	assert_eq(int(game_state.open_contract_count()), 0)
	var player_keys: Array = (payload["player"] as Dictionary).keys()
	for layer: String in TopDownActionRpgGameState.SELF_LAYERS:
		assert_true(player_keys.has(layer), layer)
	assert_eq(game_state.grant_equipment("equipment_ash_bound_stick", 1), true)
	assert_eq(game_state.equip("equipment_ash_bound_stick", "weapon"), true)
	assert_eq(String(game_state.equipped_id("weapon")), "equipment_ash_bound_stick")
	assert_eq(String(game_state.equipped_id("offhand")), "")
	assert_eq(game_state.equip("equipment_ash_bound_stick", "not_a_slot"), false)
	assert_eq(game_state.equip("equipment_absent_probe", "weapon"), false)
	assert_eq((game_state.to_dict()["progression"] as Dictionary)["equipment_slots"].size(), 1)
	var mutated: Dictionary = game_state.to_dict()
	(mutated["world"] as Dictionary)["axes"]["protocol_legitimacy"] = {"value": 2, "last_write_event_id": "ev_probe"}
	(mutated["progression"] as Dictionary)["equipment"] = {}
	var restored: TopDownActionRpgGameState = TopDownActionRpgGameState.new()
	assert_true(restored.from_dict(mutated))
	assert_eq(int(restored.axis_value("protocol_legitimacy")), 2)
	assert_eq(String(restored.equipped_id("weapon")), "equipment_ash_bound_stick")
	assert_eq((restored.to_dict()["progression"] as Dictionary)["equipment_slots"], {"weapon": "equipment_ash_bound_stick"})
	assert_eq(int((mutated["progression"] as Dictionary)["equipment"].size()), 0)
	assert_true(TopDownActionRpgContentLoader.is_json_safe(restored.to_dict()))
	var unknown_world: Dictionary = (game_state.to_dict() as Dictionary).duplicate(true)
	(unknown_world["world"] as Dictionary)["not_a_world_key"] = {}
	assert_eq(TopDownActionRpgGameState.new().from_dict(unknown_world), false)
	var wrong_format: Dictionary = (game_state.to_dict() as Dictionary).duplicate(true)
	wrong_format["state_format"] = "not_the_format"
	assert_eq(TopDownActionRpgGameState.new().from_dict(wrong_format), false)
	var wrong_version: Dictionary = (game_state.to_dict() as Dictionary).duplicate(true)
	wrong_version["save_version"] = "one"
	assert_eq(TopDownActionRpgGameState.new().from_dict(wrong_version), false)
	var missing_section: Dictionary = (game_state.to_dict() as Dictionary).duplicate(true)
	missing_section.erase("commit_log")
	assert_eq(TopDownActionRpgGameState.new().from_dict(missing_section), false)
	assert_eq(TopDownActionRpgGameState.new().from_dict("not_a_dictionary"), false)
	var stable: TopDownActionRpgGameState = _new_game_state()
	assert_eq(stable.set_route_state("route_e01_ash_stair", "closed", "ev_probe"), true)
	assert_eq(String(stable.route_state("route_e01_ash_stair")), "closed")
	assert_eq(String(stable.route_state("route_gone_probe")), "locked")
	assert_eq(stable.set_route_state("route_e01_ash_stair", "not_a_state", "ev_probe"), false)
	assert_eq(String(stable.route_state("route_e01_ash_stair")), "closed")
	assert_eq(stable.set_flag("not_prefixed", true), false)
	assert_eq(stable.set_flag("world_probe_flag", true), true)
	assert_eq(bool(stable.flag_is("world_probe_flag")), true)
	assert_eq(stable.mark_effect_fired("eff_probe"), true)
	assert_eq(stable.mark_effect_fired("eff_probe"), false)
	assert_eq(bool(stable.effect_has_fired("eff_probe")), true)
	assert_eq(stable.mark_effect_fired(""), false)
	assert_eq(stable.grant_resource("res_labor_pledge", 1), false)
	assert_eq(int(stable.resource_amount("res_labor_pledge")), -1)
	assert_eq(stable.consume_resource("res_care_token", 1), false)
	assert_eq(stable.grant_resource("res_care_token", 2), true)
	assert_eq(int(stable.resource_amount("res_care_token")), 2)
	assert_eq(stable.consume_resource("res_care_token", 5), false)
	assert_eq(stable.consume_resource("res_care_token", 1), true)
	assert_eq(int(stable.resource_amount("res_care_token")), 1)
	assert_eq(int(stable.npc_state("npc_gone_probe").size()), 0)
	assert_eq(String(stable.npc_state("npc_gone_probe").get("presence", "")), "")
	assert_eq(String(stable.relationship_state("rel_gone_probe")), "")
	assert_eq(String(stable.prop_state("prop_gone_probe")), "")
	assert_eq(String(stable.encounter_resolution("enc_gone_probe")), "")
	assert_eq(stable.set_relationship_state("rel_01_ilyra_record", "rs_probe"), true)
	assert_eq(String(stable.relationship_state("rel_01_ilyra_record")), "rs_probe")
	assert_eq(stable.set_npc_state("npc_01_ilyra_senn", "presence", "resident"), true)
	assert_eq(stable.set_npc_state("npc_01_ilyra_senn", "not_a_key", "resident"), false)
	(stable.world["magic"] as Dictionary)["contracts"] = {"c_probe": {"obligation_state": "open"}, "c_done": {"obligation_state": "closed"}}
	assert_eq(int(stable.open_contract_count()), 1)
	var reopened: TopDownActionRpgGameState = TopDownActionRpgGameState.new()
	assert_true(reopened.from_dict(stable.to_dict()))
	assert_eq(int(reopened.open_contract_count()), 1)
	assert_eq(String(reopened.mode), "field")
	assert_eq(reopened.set_mode("combat"), true)
	assert_eq(String(reopened.combat.get("resume_boundary", "")), "combat")
	assert_eq(reopened.set_mode("not_a_mode"), false)
	assert_eq(TopDownActionRpgGameState.derive_mode({"combat": {"resume_boundary": "not_a_mode"}}), "field")
	assert_eq(TopDownActionRpgGameState.derive_mode({"combat": {"resume_boundary": "encounter_prepare"}}), "encounter_prepare")
	assert_eq(TopDownActionRpgGameState.derive_mode({"combat": {"resume_boundary": ""}, "recovery": {"pending_outcome_id": "rec_probe"}}), "recovery")
	assert_eq(TopDownActionRpgGameState.derive_mode({"combat": {"resume_boundary": "", "active_encounter_id": "enc_probe"}}), "combat")
	assert_eq(TopDownActionRpgGameState.derive_mode({"combat": {"resume_boundary": ""}}), "field")
	var derived: TopDownActionRpgGameState = TopDownActionRpgGameState.new()
	var boundary_payload: Dictionary = (game_state.to_dict() as Dictionary).duplicate(true)
	(boundary_payload["combat"] as Dictionary)["resume_boundary"] = "recovery"
	assert_true(derived.from_dict(boundary_payload))
	assert_eq(String(derived.mode), "recovery")
	assert_eq(TopDownActionRpgGameState.MODES.size(), 9)
	assert_eq(TopDownActionRpgGameState.ROUTE_STATES.size(), 6)
	assert_eq(TopDownActionRpgGameState.EQUIPMENT_SLOTS, ["weapon", "offhand", "armor", "accessory"] as Array)


func test_axes_and_clocks_are_canonical_and_move_independently() -> void:
	assert_eq(TopDownActionRpgGameState.AXES, [
		"protocol_legitimacy", "recognition_drift", "continuity_pressure", "resource_scarcity",
	] as Array)
	assert_eq(TopDownActionRpgContentLoader.WORLD_AXES, TopDownActionRpgGameState.AXES)
	assert_eq(TopDownActionRpgGameState.CLOCK_IDS, [
		"clock_institutional_response", "clock_contamination", "clock_public_record",
		"clock_resource_collapse", "clock_personal_collapse", "clock_crown_alignment",
	] as Array)
	assert_eq(TopDownActionRpgGameState.AXIS_MIN, -3)
	assert_eq(TopDownActionRpgGameState.AXIS_MAX, 3)
	assert_eq(TopDownActionRpgGameState.CLOCK_STAGE_COUNT, 6)
	assert_eq(TopDownActionRpgGameState.IRREVERSIBLE_STAGE, 4)
	assert_eq(TopDownActionRpgGameState.TERMINAL_STAGE, 5)
	assert_eq(TopDownActionRpgGameState.CLOCK_STAGE_TOKENS.size(), 6)
	for clock_id: String in TopDownActionRpgGameState.CLOCK_IDS:
		assert_true(TopDownActionRpgGameState.is_valid_clock(clock_id), clock_id)
		var ladder: Array = TopDownActionRpgGameState.CLOCK_STAGE_TOKENS[clock_id]
		assert_eq(ladder.size(), TopDownActionRpgGameState.CLOCK_STAGE_COUNT, clock_id)
		for stage: int in range(TopDownActionRpgGameState.CLOCK_STAGE_COUNT):
			assert_true(not String(TopDownActionRpgGameState.clock_stage_token(clock_id, stage)).is_empty(), clock_id)
	assert_eq(TopDownActionRpgGameState.is_valid_clock("clock_extra_probe"), false)
	var game_state: TopDownActionRpgGameState = _new_game_state()
	var axes: Dictionary = game_state.world["axes"]
	assert_eq(axes.size(), 4)
	for axis: String in TopDownActionRpgGameState.AXES:
		assert_true(axes.has(axis), axis)
		assert_true(TopDownActionRpgGameState.is_valid_axis(axis), axis)
		assert_eq(int(game_state.axis_value(axis)), 0)
	assert_eq(TopDownActionRpgGameState.is_valid_axis_value(4), false)
	assert_eq(TopDownActionRpgGameState.is_valid_axis_value(-4), false)
	assert_eq(TopDownActionRpgGameState.is_valid_axis_value(3), true)
	assert_eq(game_state.set_axis_value("protocol_legitimacy", 4, "ev"), false)
	assert_eq(game_state.set_axis_value("protocol_legitimacy", -4, "ev"), false)
	assert_eq(game_state.set_axis_value("not_an_axis", 1, "ev"), false)
	assert_eq(game_state.set_axis_value("protocol_legitimacy", 3, "ev_one"), true)
	assert_eq(int(game_state.axis_value("protocol_legitimacy")), 3)
	assert_eq(int(game_state.axis_value("recognition_drift")), 0)
	assert_eq(int(game_state.axis_value("continuity_pressure")), 0)
	assert_eq(int(game_state.axis_value("resource_scarcity")), 0)
	assert_eq(String(TopDownActionRpgGameState.axis_token("protocol_legitimacy", 3)), "successor_peak")
	assert_eq(String(TopDownActionRpgGameState.axis_token("protocol_legitimacy", 0)), "sanctioned")
	assert_eq(String(TopDownActionRpgGameState.axis_token("protocol_legitimacy", -3)), "unlicensed_floor")
	assert_eq(int(TopDownActionRpgGameState.axis_value_of_token("protocol_legitimacy", "successor_peak")), 3)
	assert_eq(int(TopDownActionRpgGameState.axis_value_of_token("protocol_legitimacy", "sanctioned")), 0)
	assert_eq(int(TopDownActionRpgGameState.axis_value_of_token("protocol_legitimacy", "unlicensed_floor")), -3)
	assert_eq(int(TopDownActionRpgGameState.axis_value_of_token("protocol_legitimacy", "not_a_token")), 0)
	assert_eq(String(TopDownActionRpgGameState.axis_token("not_an_axis", 1)), "")
	assert_eq((TopDownActionRpgGameState.AXIS_TOKENS["continuity_pressure"] as Array).size(), 7)
	game_state.axis_claim("region_h0_undersign_exchange", "claim_one", "artifact")
	game_state.axis_claim("region_h0_undersign_exchange", "claim_two", "patient")
	var claims: Array = (game_state.world["axes"]["recognition_drift"] as Dictionary)["disputed_claims"]
	assert_eq(claims.size(), 2)
	assert_eq(int(game_state.axis_value("recognition_drift")), 0)
	game_state.axis_claim("region_h0_undersign_exchange", "claim_two", "operator")
	assert_eq(((game_state.world["axes"]["recognition_drift"] as Dictionary)["disputed_claims"] as Array).size(), 2)
	game_state.ensure_clocks("region_r1_returning_kiln")
	var region_clocks: Dictionary = (game_state.world["clocks"] as Dictionary)["region_r1_returning_kiln"]
	assert_eq(region_clocks.size(), 6)
	for clock_id: String in TopDownActionRpgGameState.CLOCK_IDS:
		assert_eq(int(game_state.clock_stage("region_r1_returning_kiln", clock_id)), 0, clock_id)
		assert_eq(bool(game_state.clock_is_irreversible("region_r1_returning_kiln", clock_id)), false)
	assert_eq(int(game_state.advance_clock("region_r1_returning_kiln", "not_a_clock", 1, "ev")), -1)
	assert_eq(int(game_state.advance_clock("region_r1_returning_kiln", "clock_contamination", -1, "ev")), -1)
	assert_eq(int(game_state.advance_clock("region_r1_returning_kiln", "clock_contamination", 9, "ev")), 5)
	for clock_id: String in TopDownActionRpgGameState.CLOCK_IDS:
		if clock_id == "clock_contamination":
			continue
		assert_eq(int(game_state.clock_stage("region_r1_returning_kiln", clock_id)), 0, clock_id)
	assert_eq(bool(game_state.clock_is_irreversible("region_r1_returning_kiln", "clock_contamination")), true)
	assert_eq(String(TopDownActionRpgGameState.clock_stage_token("clock_contamination", 4)), "irreversible")
	assert_eq(String(TopDownActionRpgGameState.clock_stage_token("clock_contamination", 5)), "collapsed")
	assert_eq(int(TopDownActionRpgGameState.clock_stage_of_token("clock_contamination", "collapsed")), 5)
	assert_eq(int(game_state.advance_clock("region_r1_returning_kiln", "clock_contamination", 3, "ev_two")), 5)
	assert_eq(int(game_state.set_clock_stage("region_r1_returning_kiln", "clock_contamination", 2, "ev_three")), 2)
	assert_eq(bool(game_state.clock_is_irreversible("region_r1_returning_kiln", "clock_contamination")), false)
	assert_eq(int(game_state.clock_stage("region_missing_probe", "clock_contamination")), 0)
	assert_eq(int(game_state.advance_clock("region_r1_returning_kiln", "clock_public_record", 1, "ev_four")), 1)
	for clock_id: String in TopDownActionRpgGameState.CLOCK_IDS:
		if clock_id == "clock_public_record" or clock_id == "clock_contamination":
			continue
		assert_eq(int(game_state.clock_stage("region_r1_returning_kiln", clock_id)), 0, clock_id)
	assert_eq(int(game_state.clock_stage("region_r1_returning_kiln", "clock_public_record")), 1)
	assert_eq(int(game_state.clock_stage("region_r1_returning_kiln", "clock_contamination")), 2)


func test_recovery_kinds_are_closed_and_crown_alignment_is_a_world_write() -> void:
	assert_eq(TopDownActionRpgRecoveryController.RECOVERY_KINDS, [
		"checkpoint", "respawn", "clone", "reincarnation", "loop", "immortality", "institutional_reentry",
	] as Array)
	assert_eq(TopDownActionRpgRecoveryController.RECOVERY_KINDS.size(), 7)
	assert_eq(TopDownActionRpgContentLoader.RECOVERY_KINDS, TopDownActionRpgRecoveryController.RECOVERY_KINDS)
	assert_eq(TopDownActionRpgRecoveryController.RETIRED_TOKENS, [
		"checkpoint_return", "clone_branch", "loop_rehearsal", "immortal_continuation",
	] as Array)
	assert_eq(TopDownActionRpgRecoveryController.SELF_LAYERS.size(), 7)
	for kind: String in TopDownActionRpgRecoveryController.RECOVERY_KINDS:
		assert_eq(bool(TopDownActionRpgRecoveryController.is_recovery_kind(kind)), true, kind)
	for token: String in TopDownActionRpgRecoveryController.RETIRED_TOKENS:
		assert_eq(bool(TopDownActionRpgRecoveryController.is_recovery_kind(token)), false, token)
	for token: String in ["crown_alignment", "game_over", "recoverable", "continuity-changing", "terminal"]:
		assert_eq(bool(TopDownActionRpgRecoveryController.is_recovery_kind(token)), false, token)
	var game_state: TopDownActionRpgGameState = _new_game_state()
	var recovery := TopDownActionRpgRecoveryController.new()
	assert_true(recovery.setup(game_state, _catalog))
	var definition: Dictionary = {
		"id": "rec_core_probe", "kind": "clone",
		"preserves": TopDownActionRpgRecoveryController.STATE_TOKENS.duplicate(),
		"discards": TopDownActionRpgRecoveryController.DISCARD_TOKENS.duplicate(),
		"respawn": {
			"region_id": "region_r1_returning_kiln", "prop_id": "prop_r1_ash_garden_thread",
			"encounter_id": "enc_r1_ash_choir", "reset_prop_ids": [],
		},
		"cost": {"continuity_pressure_delta": 0, "resource_costs": {}, "axis_deltas": {}, "world_effect_ids": []},
		"entry_effect_ids": [],
		"self_layers_restored": TopDownActionRpgRecoveryController.SELF_LAYERS.duplicate(),
		"self_layers_not_restored": [],
	}
	var partition: Dictionary = TopDownActionRpgRecoveryController.layer_partition(definition)
	assert_eq(bool(partition["complete"]), true)
	assert_eq((partition["restored"] as Array).size(), 7)
	assert_eq((partition["not_restored"] as Array).size(), 0)
	var gapped: Dictionary = (definition as Dictionary).duplicate(true)
	gapped["self_layers_not_restored"] = ["desire"]
	assert_eq(bool(TopDownActionRpgRecoveryController.layer_partition(gapped)["complete"]), false)
	assert_eq(recovery.request_recovery(gapped), "recovery_layer_gap")
	assert_eq(int(game_state.recovery.get("continuity", {}).get("recovery_count", 0)), 0)
	assert_eq(recovery.request_recovery(definition), "requested")
	assert_eq(String(game_state.mode), "recovery")
	assert_eq(String(game_state.recovery.get("pending_outcome_id", "")), "rec_core_probe")
	var result: Dictionary = recovery.apply_recovery()
	assert_eq(String(result.get("result", "")), "recovered")
	assert_eq(String(result.get("kind", "")), "clone")
	assert_eq(String(result.get("respawn_region_id", "")), "region_r1_returning_kiln")
	assert_eq(String(result.get("respawn_encounter_id", "")), "enc_r1_ash_choir")
	assert_eq(String(game_state.mode), "field")
	assert_eq(String(game_state.region_id()), "region_r1_returning_kiln")
	assert_eq(String((game_state.recovery["continuity"] as Dictionary).get("continuity_pressure", "")), "branched")
	assert_eq(int((game_state.recovery["continuity"] as Dictionary).get("recovery_count", 0)), 1)
	assert_eq(recovery.recovery_history().size(), 1)
	assert_eq(String((recovery.recovery_history()[0] as Dictionary)["kind"]), "clone")
	for token: String in TopDownActionRpgRecoveryController.STATE_TOKENS:
		assert_eq((definition["preserves"] as Array).has(token), true, token)
	for token: String in TopDownActionRpgRecoveryController.DISCARD_TOKENS:
		assert_eq((definition["discards"] as Array).has(token), true, token)
		assert_eq((definition["preserves"] as Array).has(token), false, token)
	assert_eq(recovery.request_recovery({"id": "rec_core_violation", "kind": "crown_alignment"}), "recovery_kind_violation")
	assert_eq(recovery.request_recovery({"id": "rec_core_violation", "kind": "game_over"}), "recovery_kind_violation")
	assert_eq(recovery.request_recovery({"id": "rec_core_violation", "kind": "recoverable"}), "recovery_kind_violation")
	assert_eq(recovery.request_recovery({"id": "rec_core_violation", "kind": "clone_branch"}), "recovery_kind_token_mismatch")
	assert_eq(recovery.request_recovery({}), "recovery_unavailable")
	assert_eq(String(recovery.apply_recovery({}).get("result", "")), "recovery_unavailable")
	var stale: Dictionary = (definition as Dictionary).duplicate(true)
	stale["id"] = "rec_gone_probe"
	assert_eq(String(recovery.apply_recovery(stale).get("result", "")), "recovered")
	assert_eq(recovery.recovery_history().size(), 2)
	var authored_partition: Dictionary = TopDownActionRpgRecoveryController.layer_partition(_catalog.record("rec_r8_course_repeat"))
	assert_eq(bool(authored_partition["complete"]), true)
	assert_eq(String(_catalog.record("rec_r8_course_repeat").get("kind", "")), "checkpoint")
	assert_eq(String(_catalog.record("rec_r1_kiln_reentry").get("kind", "")), "institutional_reentry")
	var by_kind: Dictionary = recovery.recovery_definitions_by_kind()
	assert_eq(by_kind.size(), 2)
	assert_eq(bool(by_kind.has("checkpoint")), true)
	assert_eq(bool(by_kind.has("institutional_reentry")), true)
	assert_eq(bool(by_kind.has("crown_alignment")), false)
	var crown_game: TopDownActionRpgGameState = _new_game_state()
	var crown_recovery := TopDownActionRpgRecoveryController.new()
	assert_true(crown_recovery.setup(crown_game, _catalog))
	var crown: Dictionary = crown_recovery.apply_crown_alignment("inherited_claim", "npc_01_ilyra_senn", 2, "ev_crown")
	assert_eq(String(crown.get("result", "")), "world_write_committed")
	assert_eq(String(crown.get("kind", "")), "crown_alignment")
	assert_eq(String((crown_game.world["crown"] as Dictionary)["precedence"]), "inherited_claim")
	assert_eq(String((crown_game.world["crown"] as Dictionary)["operator_id"]), "npc_01_ilyra_senn")
	assert_eq(int((crown_game.world["crown"] as Dictionary)["object_phase"]), 2)
	assert_eq(int(crown_game.axis_value("continuity_pressure")), int(TopDownActionRpgGameState.axis_value_of_token("continuity_pressure", "crown-debt")))
	assert_eq(int(crown_game.clock_stage(crown_game.region_id(), "clock_crown_alignment")), TopDownActionRpgGameState.IRREVERSIBLE_STAGE)
	assert_eq(int(crown.get("crown_clock_stage", 0)), TopDownActionRpgGameState.IRREVERSIBLE_STAGE)
	assert_eq((crown_game.recovery.get("history", []) as Array).size(), 0)
	assert_eq(String(crown_game.recovery.get("pending_outcome_id", "!")), "")
	assert_eq(int((crown_game.recovery.get("continuity", {}) as Dictionary).get("recovery_count", 0)), 0)
	assert_eq(bool((crown_game.recovery.get("continuity", {}) as Dictionary).has("operator")), false)
	assert_eq(bool(crown_game.world["crown"].has("precedence")), true)
	assert_eq(crown_game.commit_log.size(), 1)
	assert_eq(String((crown_game.commit_log[0] as Dictionary)["kind"]), "crown_alignment")
	assert_eq(crown_game.transaction["delayed_writes"].size(), 1)
	var blocked: Dictionary = crown_recovery.apply_crown_alignment("  ", "npc_05_nera_voss", 0, "ev_crown_three")
	assert_eq(String(blocked.get("result", "")), "world_write_rejected")
	assert_eq(String((crown_game.world["crown"] as Dictionary)["precedence"]), "inherited_claim")
	var second: Dictionary = crown_recovery.apply_crown_alignment("second_claim", "npc_05_nera_voss", 3, "ev_crown_four")
	assert_eq(String(second.get("result", "")), "world_write_rejected")
	assert_eq(String(second.get("reason", "")), "crown_alignment_is_not_a_recovery_type")
	assert_eq(String((crown_game.world["crown"] as Dictionary)["precedence"]), "inherited_claim")
	assert_eq(String((crown_game.world["crown"] as Dictionary)["operator_id"]), "npc_01_ilyra_senn")
	assert_eq(int((crown_game.world["crown"] as Dictionary)["object_phase"]), 2)
	assert_eq(crown_game.commit_log.size(), 1)
	assert_eq(crown_game.transaction["delayed_writes"].size(), 1)
	crown_game.recovery["history"] = [{"recovery_event_id": "rec_stale_probe", "kind": "crown_alignment"}]
	var refused: Dictionary = crown_recovery.apply_crown_alignment("third_claim", "npc_11_cael_ren", 1, "ev_crown_five")
	assert_eq(String(refused.get("result", "")), "world_write_rejected")
	assert_eq(String(refused.get("reason", "")), "crown_alignment_is_not_a_recovery_type")
	assert_eq(String((crown_game.world["crown"] as Dictionary)["precedence"]), "inherited_claim")
	assert_eq(String((crown_game.world["crown"] as Dictionary)["operator_id"]), "npc_01_ilyra_senn")
	assert_eq(crown_game.commit_log.size(), 1)
	assert_eq(bool(TopDownActionRpgRecoveryController.layer_partition(_catalog.record("rec_r1_kiln_reentry"))["complete"]), true)
	assert_eq(crown_recovery.request_recovery(_catalog.record("rec_r8_course_repeat")), "requested")
	assert_eq(String(crown_game.mode), "recovery")
	var checkpoint: Dictionary = recovery.snapshot_for_checkpoint()
	assert_eq(checkpoint.size(), 12)
	assert_eq(recovery.restore_checkpoint(checkpoint), true)
	assert_eq(bool(recovery.restore_checkpoint({})), false)


func test_data_only_authored_change_needs_no_core_modification() -> void:
	assert_eq(bool(_catalog.has(PROBE_HIT_ID)), false)
	var joined: String = _module_source()
	assert_gt(joined.length(), 0)
	for kind_name: String in IDENTITY_SCAN_KINDS:
		for record_id: String in _catalog.ids_of_kind(kind_name):
			if IDENTITY_EXEMPT_IDS.has(record_id):
				continue
			assert_eq(joined.contains(record_id), false, record_id)
	for token: String in FORBIDDEN_RUNTIME_TOKENS:
		assert_eq(joined.contains(token), false, token)
	assert_eq(_catalog.file_count, EXPECTED_FILE_COUNT)
	var base_actions: int = _catalog.count_of_kind("actions")
	assert_eq(base_actions, 13)
	var new_id: String = "act_core_probe_data_only"
	assert_eq(TopDownActionRpgContentLoader.is_stable_id(new_id), true)
	assert_eq(bool(_catalog.has(new_id)), false)
	var authored: Dictionary = (_overlay.record(PROBE_HIT_ID) as Dictionary).duplicate(true)
	authored["id"] = new_id
	authored["display_name"] = "data only probe"
	authored["cost"]["turn_cost"] = 5
	assert_true(TopDownActionRpgContentLoader.is_json_safe(authored))
	var overlay := _overlay_catalog()
	var overlay_base_actions: int = overlay.count_of_kind("actions")
	overlay.by_id[new_id] = authored
	overlay.id_kind[new_id] = "actions"
	overlay.kind_records["actions"] = (overlay.kind_records["actions"] as Array) + [new_id]
	assert_eq(overlay.count_of_kind("actions"), overlay_base_actions + 1)
	assert_eq(overlay.kind_of(new_id), "actions")
	assert_eq(_catalog.count_of_kind("actions"), base_actions)
	assert_eq(bool(_catalog.has(new_id)), false)
	assert_eq(_catalog.file_count, EXPECTED_FILE_COUNT)
	var state: TopDownActionRpgCombatState = _new_combat_state()
	var roster: Array = _build_roster(state)
	var player: TopDownActionRpgCombatState.ActorState = roster[0]
	var enemy: TopDownActionRpgCombatState.ActorState = roster[2]
	var controller := TopDownActionRpgCombatController.new()
	assert_true(controller.setup(state, overlay, {"id": PROBE_ENCOUNTER_ID, "allow": {"escape": true}}))
	assert_eq(controller.begin_actor_window(player.actor_id), "window_open")
	var queued: TopDownActionRpgCombatState.ResolutionOutcome = controller.queue_action(StringName(new_id), &"act_enemy_one")
	assert_eq(queued.result_code, "queued")
	var data_only_intent: TopDownActionRpgCombatState.QueuedIntent = state.queue[0]
	assert_eq(int(data_only_intent.turn_cost), 5)
	assert_eq(int(player.next_window_tick), TopDownActionRpgActionScheduler.delay_ticks(5, 10))
	assert_eq(int(controller.consumed_slots.get(player.actor_id, 0)), 1)
	var hits: Array = []
	for outcome: TopDownActionRpgCombatState.ResolutionOutcome in controller.advance():
		if String(outcome.intent_id) == String(data_only_intent.intent_id):
			hits.append(outcome)
	assert_eq(hits.size(), 1)
	assert_eq(int((hits[0] as TopDownActionRpgCombatState.ResolutionOutcome).damage_by_actor.get("act_enemy_one", 0)), 20)
	assert_eq(int(enemy.hp), 30)
	assert_eq(_catalog.count_of_kind("actions"), base_actions)
	assert_eq(TopDownActionRpgContentLoader.is_stable_id(PROBE_DOCUMENT_ID), true)
	assert_eq(TopDownActionRpgContentLoader.is_stable_id(PROBE_CONVERSATION_ID), true)
	assert_eq(_overlay.kind_of(PROBE_DOCUMENT_ID), "documents")
	assert_eq(_overlay.kind_of(PROBE_CONVERSATION_ID), "conversations")
	assert_eq(_overlay.kind_of(PROBE_HIT_ID), "actions")
