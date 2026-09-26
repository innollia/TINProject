extends GutTest

const MANIFEST_PATH: String = "res://modules/top_down_action_rpg/module_manifest.tres"
const ENTRY_PATH: String = "res://modules/top_down_action_rpg/entry.tscn"
const MODULE_SCRIPT: String = "res://modules/top_down_action_rpg/module.gd"
const SCREEN_SCENE: String = "res://modules/top_down_action_rpg/presentation/top_down_screen.tscn"
const SCREEN_SCRIPT: String = "res://modules/top_down_action_rpg/presentation/top_down_screen.gd"
const ROW_SCRIPT: String = "res://modules/top_down_action_rpg/presentation/top_down_row.gd"
const VECTOR_SCRIPT: String = "res://modules/top_down_action_rpg/presentation/top_down_vector_layer.gd"
const APP_ROOT_SOURCE: String = "res://app/app_root.gd"
const PROJECT_SOURCE: String = "res://project.godot"
const MODULE_ID: StringName = &"top_down_action_rpg"
const ENTRY_REGION: String = "region_h0_undersign_exchange"
const ENTRY_ANCHOR: String = "route_e01_ash_stair"
const KILN_REGION: String = "region_r1_returning_kiln"
const CHOIR_ENCOUNTER: String = "enc_r1_ash_choir"
const DOOR_ENCOUNTER: String = "enc_r1_door_role_test"
const RETURN_DESK: String = "conv_h0_return_desk"
const RETURN_DESK_CHOICE: String = "ch_file_arrival_category"
const INDEX_RETURN_CHOICE: String = "ch_index_return"
const DESK_NPC: String = "npc_01_ilyra_senn"
const KILN_DOCUMENT: String = "doc_r1_wrong_return_log"
const KILN_DOOR_PROP: String = "prop_r1_wrong_return_door"
const KILN_EFFECT: String = "eff_r1_wrong_return_witnessed"
const REGISTRY_EFFECT: String = "eff_r1_return_registry_logs_name"
const PLAYER_ACTION: String = "act_ash_sweep"
const GUARD_ACTION: String = "act_guard_set"
const REACTION_ACTION: String = "act_dodge_shift"
const CHARGE_ACTION: String = "act_ash_hound_lunge"
const CHARGE_ENEMY: String = "enemy_ash_hound"
const ENEMY_ACTION_OWNER: String = "enemy"
const ENEMY_ACTION_HOLD: int = 4096
const ACTIONS_PREFIX: String = "행동 "

const EXPECTED_ACTIONS: Array[String] = [
	"top_down_action_rpg_left", "top_down_action_rpg_right", "top_down_action_rpg_up",
	"top_down_action_rpg_down", "top_down_action_rpg_confirm", "top_down_action_rpg_cancel",
]
const OPPOSITE_INDEX: Array[int] = [1, 0, 3, 2]
const SAVE_ROOT_KEYS: Array[String] = [
	"state_format", "save_version", "run_id", "content_revision",
	"field", "combat", "player", "world", "recovery", "progression", "transaction", "commit_log",
]
const COMBAT_SAVE_KEYS: Array[String] = [
	"active_encounter_id", "resume_boundary", "pre_command_intent", "attempt_serial", "result",
]
const COMBAT_TRANSIENT_KEYS: Array[String] = [
	"scheduler_tick", "turn_index", "rng_state", "cycle_index", "actors", "queue",
	"presentation_queue", "pending_reactions", "mode", "schema_version", "submode",
]
const FORBIDDEN_RUNTIME_TOKENS: Array[String] = [
	"Input.", "InputMap", "InputEvent", "get_tree()", "/root", "Engine.get_singleton",
	"autoload", "service_locator", "set_process_mode", "get_node_or_null(\"/root",
]
const FORBIDDEN_PRESENTATION_TOKENS: Array[String] = [
	"condition_exposure", "ap_gauge", "ap_label", "action_points", "AP gauge", "generic red",
	"ColorRect", "COLOR_RED",
]
const SHELL_HUD_TOKENS: Array[String] = [
	"Menu", "Journal", "HUD", "Hud", "Debug", "Toolbar", "TopBar", "StatusBar",
	"Minimap", "Objective", "Location", "AutoSave", "Breadcrumb", "Compass", "QuestLog",
]
const FIELD_ONLY_LAYERS: Array[String] = [
	"%DialogueLayer", "%DocumentLayer", "%NarrationLayer",
]
const EXPECTED_STATES: Array[StringName] = [
	TopDownActionRpgScreen.STATE_ESC_MENU,
	TopDownActionRpgScreen.STATE_INPUT_BUBBLE,
	TopDownActionRpgScreen.STATE_FIELD,
	TopDownActionRpgScreen.STATE_DIALOGUE_CHOICE_FOCUS,
	TopDownActionRpgScreen.STATE_NARRATION,
	TopDownActionRpgScreen.STATE_COMBAT_COMMAND,
	TopDownActionRpgScreen.STATE_TARGET_SELECT,
	TopDownActionRpgScreen.STATE_CHARGE_COUNTER,
	TopDownActionRpgScreen.STATE_GUARD_DODGE_BREAK,
	TopDownActionRpgScreen.STATE_EQUIPMENT_NO_TURN,
	TopDownActionRpgScreen.STATE_DOCUMENT_MAX,
	TopDownActionRpgScreen.STATE_DOCUMENT_CORRUPTED,
	TopDownActionRpgScreen.STATE_AFTERMATH_REVISIT,
	TopDownActionRpgScreen.STATE_FAILURE_DEATH,
	TopDownActionRpgScreen.STATE_RECOVERY,
	TopDownActionRpgScreen.STATE_SUCCESS,
]
const LEDGER_STEPS: int = 14
const WALK_STEPS: int = 64
const COMBAT_LIMIT: int = 64

var _owned_actions: Array[StringName] = []
var _owned_modules: Array[Node] = []


func after_each() -> void:
	for action: StringName in _owned_actions:
		Input.action_release(action)
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	_owned_actions.clear()
	for module: Node in _owned_modules:
		if is_instance_valid(module):
			if module.get_parent() != null:
				module.get_parent().remove_child(module)
			module.free()
	_owned_modules.clear()


func _read(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, path)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _sorted(values: Array[String]) -> Array[String]:
	var copy: Array[String] = values.duplicate()
	copy.sort()
	return copy


func _sorted_keys(source: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in source:
		keys.append(String(key))
	keys.sort()
	return keys


func _assert_envelope(actual: Dictionary, expected: Dictionary, label: String) -> void:
	assert_eq(_sorted_keys(actual), _sorted(SAVE_ROOT_KEYS), label)
	for key: String in SAVE_ROOT_KEYS:
		assert_eq(actual.get(key), expected.get(key), "%s/%s" % [label, key])
		if expected.get(key) is Dictionary and actual.get(key) is Dictionary:
			for nested: String in _sorted_keys(expected[key]):
				assert_eq((actual[key] as Dictionary).get(nested), (expected[key] as Dictionary).get(nested), "%s/%s/%s" % [label, key, nested])


func _context() -> ModuleContext:
	var injected := ModuleContext.new()
	injected.module_id = MODULE_ID
	injected.input_enabled = true
	for action: String in EXPECTED_ACTIONS:
		var action_name := StringName(action)
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			_owned_actions.append(action_name)
		injected.allowed_actions.append(action_name)
	return injected


func _make_module() -> GameModule:
	var packed := load(ENTRY_PATH) as PackedScene
	assert_not_null(packed, ENTRY_PATH)
	if packed == null:
		return null
	var game := packed.instantiate() as GameModule
	assert_not_null(game, "entry instantiate")
	add_child_autofree(game)
	_owned_modules.append(game)
	return game


func _spawn(pending: Dictionary = {}) -> GameModule:
	var game := _make_module()
	if game == null:
		return null
	game.load_state(pending.duplicate(true))
	game.enter(_context())
	return game


func _state_of(game: GameModule) -> TopDownActionRpgGameState:
	return game.get("_game_state") as TopDownActionRpgGameState


func _screen_of(game: GameModule) -> TopDownActionRpgScreen:
	return game.get_node_or_null("TopDownScreen") as TopDownActionRpgScreen


func _field_of(game: GameModule) -> TopDownActionRpgFieldController:
	return game.get("_field") as TopDownActionRpgFieldController


func _combat_of(game: GameModule) -> TopDownActionRpgCombatState:
	return game.get("_combat") as TopDownActionRpgCombatState


func _controller_of(game: GameModule) -> TopDownActionRpgCombatController:
	return game.get("_combat_controller") as TopDownActionRpgCombatController


func _conversation_of(game: GameModule) -> TopDownActionRpgConversationController:
	return game.get("_conversation") as TopDownActionRpgConversationController


func _recovery_of(game: GameModule) -> TopDownActionRpgRecoveryController:
	return game.get("_recovery") as TopDownActionRpgRecoveryController


func _player_of(game: GameModule) -> TopDownActionRpgCombatState.ActorState:
	var combat := _combat_of(game)
	return combat.find_actor(StringName(TopDownActionRpgGameState.PLAYER_ROLE_ID)) if combat != null else null


func _mode_of(game: GameModule) -> String:
	var state := _state_of(game)
	return String(state.mode) if state != null else ""


func _position_of(game: GameModule) -> Vector2:
	var snapshot: Dictionary = game.save_state()
	var field: Dictionary = snapshot["field"] if snapshot["field"] is Dictionary else {}
	var actor: Dictionary = field["actor"] if field["actor"] is Dictionary else {}
	return Vector2(float(actor.get("x", 0.0)), float(actor.get("y", 0.0)))


func _visible(game: GameModule, unique_path: String) -> bool:
	return bool((_screen_of(game).get_node(unique_path) as Control).visible)


func _press(game: GameModule, action: StringName) -> void:
	Input.action_press(action)
	game.call("_process", 0.0)
	Input.action_release(action)
	game.call("_process", 0.0)


func _player_window_open(game: GameModule) -> bool:
	var controller := _controller_of(game)
	if controller == null or controller.state == null:
		return false
	if String(controller.current_actor_id) != TopDownActionRpgGameState.PLAYER_ROLE_ID:
		return false
	return ["command_category", "command_action", "target_select", "resolution_feedback"].has(String(controller.state.submode))


func _interactable_of(game: GameModule, target_id: String) -> TopDownActionRpgFieldController.Interactable:
	var field := _field_of(game)
	if field == null:
		return null
	for entry: TopDownActionRpgFieldController.Interactable in field.interactables:
		if String(entry.interactable_id) == target_id:
			return entry
	return null


func _focused_interactable_id(game: GameModule) -> String:
	var focused: TopDownActionRpgFieldController.Interactable = _field_of(game).focused_interactable() if _field_of(game) != null else null
	return String(focused.interactable_id) if focused != null else ""


func _walk_to_interactable(game: GameModule, target_id: String) -> Vector2:
	var target := _interactable_of(game, target_id)
	assert_not_null(target, target_id)
	if target == null:
		return _position_of(game)
	for _step: int in range(WALK_STEPS):
		var delta: Vector2 = target.position - _position_of(game)
		if delta.length() <= 0.4:
			break
		game.execute_command(&"move", {"direction": delta})
	return _position_of(game)


func _focus_interactable(game: GameModule, target_id: String) -> bool:
	var field := _field_of(game)
	if field == null:
		return false
	for _step: int in range(field.focus_candidates().size() + 1):
		if _focused_interactable_id(game) == target_id:
			return true
		if not game.execute_command(&"focus", {"step": 1}):
			break
	return _focused_interactable_id(game) == target_id


func _approach_and_interact(game: GameModule, target_id: String) -> bool:
	var previous_mode: String = _mode_of(game)
	_walk_to_interactable(game, target_id)
	game.execute_command(&"interact", {"interactable_id": target_id})
	return _mode_of(game) != previous_mode


func _fresh_snapshot(encounter_id: String = "", hp: int = 0) -> Dictionary:
	var snapshot: Dictionary = TopDownActionRpgGameState.create_default(ENTRY_REGION, ENTRY_ANCHOR).to_dict()
	snapshot["content_revision"] = "module-test-fixture"
	var body: Dictionary = snapshot["player"]["body"] if snapshot["player"]["body"] is Dictionary else {}
	if hp > 0:
		body["vitals"] = {"hp": hp, "max_hp": 220, "mp": 40, "max_mp": 40}
	snapshot["player"]["body"] = body
	if not encounter_id.is_empty():
		var combat: Dictionary = snapshot["combat"]
		combat["active_encounter_id"] = encounter_id
		combat["attempt_serial"] = 1
		combat["resume_boundary"] = "encounter_prepare"
		combat["pre_command_intent"] = [{"action_id": "stale_fixture_intent", "ready_tick": 4}]
		combat["result"] = "running"
		var field: Dictionary = snapshot["field"]
		field["region_id"] = KILN_REGION
		field["scene_id"] = KILN_REGION
		field["active_interaction_id"] = "stale_fixture_interaction"
		var world: Dictionary = snapshot["world"]
		world["encounters"] = {DOOR_ENCOUNTER: {"resolution": "victory"}}
		_install_region(world, KILN_REGION)
	return snapshot


func _install_region(world: Dictionary, region_id: String) -> void:
	var regions: Dictionary = world["regions"]
	regions[region_id] = {"visit_count": 0, "state": "as_authored", "state_tag": "", "scene_id": region_id}
	var region_clocks: Dictionary = {}
	for clock_id: String in TopDownActionRpgGameState.CLOCK_IDS:
		region_clocks[clock_id] = {"stage_index": 0, "tick": 0, "last_signal": "", "committed_event_id": ""}
	(world["clocks"] as Dictionary)[region_id] = region_clocks


func _document_ready_snapshot() -> Dictionary:
	var snapshot: Dictionary = _fresh_snapshot()
	var field: Dictionary = snapshot["field"]
	field["region_id"] = KILN_REGION
	field["scene_id"] = KILN_REGION
	var world: Dictionary = snapshot["world"]
	world["encounters"] = {DOOR_ENCOUNTER: {"resolution": "victory"}}
	_install_region(world, KILN_REGION)
	return snapshot


func test_manifest_declares_id_display_entry_save_version_and_exactly_six_input_actions() -> void:
	var manifest := load(MANIFEST_PATH) as ModuleManifest
	assert_not_null(manifest, MANIFEST_PATH)
	assert_eq(manifest.id, MODULE_ID)
	assert_eq(manifest.display_name, "탑다운 액션 RPG (수직 슬라이스)")
	assert_eq(manifest.entry_scene, ENTRY_PATH)
	assert_eq(manifest.save_version, 1)
	assert_eq(manifest.input_actions.size(), 6)
	var declared: Array[String] = []
	for action: String in manifest.input_actions:
		declared.append(action)
	assert_eq(declared, EXPECTED_ACTIONS)
	assert_true(ResourceLoader.exists(MANIFEST_PATH))
	assert_true(ResourceLoader.exists(ENTRY_PATH))
	assert_true(FileAccess.file_exists(MODULE_SCRIPT))
	assert_true(FileAccess.file_exists(SCREEN_SCRIPT))
	assert_true(FileAccess.file_exists(ROW_SCRIPT))
	assert_true(FileAccess.file_exists(VECTOR_SCRIPT))
	var module_source: String = _read(MODULE_SCRIPT)
	for action: String in EXPECTED_ACTIONS:
		assert_true(module_source.contains('&"%s"' % action), action)
	var start: int = module_source.find("const ACTIONS")
	var finish: int = module_source.find("const MOVE_VECTORS")
	assert_gt(start, -1)
	assert_gt(finish, start)
	assert_eq(module_source.substr(start, finish - start).count("&\"top_down_action_rpg_"), 6)


func test_entry_scene_mounts_module_script_and_top_down_screen() -> void:
	var entry_source: String = _read(ENTRY_PATH)
	assert_true(entry_source.contains(MODULE_SCRIPT))
	assert_true(entry_source.contains(SCREEN_SCENE))
	assert_true(entry_source.contains("TopDownScreen"))
	var root := (load(ENTRY_PATH) as PackedScene).instantiate()
	assert_true(root is GameModule)
	assert_eq(String((root.get_script() as Script).resource_path), MODULE_SCRIPT)
	var screen := root.get_node_or_null("TopDownScreen")
	assert_not_null(screen)
	assert_true(screen is TopDownActionRpgScreen)
	assert_eq(String((screen.get_script() as Script).resource_path), SCREEN_SCRIPT)
	assert_eq(String(screen.name), "TopDownScreen")
	assert_eq(String(root.name), "TopDownActionRpg")
	assert_eq(root.get_child_count(), 1)
	root.free()


func test_gameplay_does_not_start_before_enter_and_enter_binds_catalog_controllers_and_screen() -> void:
	var game := _make_module()
	assert_not_null(game)
	assert_eq(game.save_state(), {})
	assert_eq(_state_of(game), null)
	assert_eq(_combat_of(game), null)
	assert_eq(_controller_of(game), null)
	assert_eq(_conversation_of(game), null)
	assert_null(_screen_of(game).game_state)
	game.call("_process", 0.016)
	assert_eq(game.save_state(), {})
	var injected := _context()
	game.enter(injected)
	assert_eq(game.context, injected)
	assert_false(String(game.get("content_signature")).is_empty())
	assert_eq(String(game.get("entry_region_id")), ENTRY_REGION)
	assert_not_null(_state_of(game))
	assert_not_null(game.get("_catalog"))
	assert_not_null(game.get("_field"))
	assert_not_null(_recovery_of(game))
	var screen := _screen_of(game)
	assert_not_null(screen.game_state)
	assert_not_null(screen.field_controller)
	assert_not_null(screen.conversation_controller)
	assert_not_null(screen.recovery_controller)
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_FIELD)
	assert_gt(screen.intent_requested.get_connections().size(), 0)
	assert_eq(_mode_of(game), "field")
	assert_eq(_sorted_keys(game.save_state()), _sorted(SAVE_ROOT_KEYS))


func test_exit_unbinds_screen_disconnects_owned_signal_and_blocks_input() -> void:
	var game := _spawn()
	var screen := _screen_of(game)
	assert_not_null(screen.game_state)
	assert_gt(screen.intent_requested.get_connections().size(), 0)
	game.exit()
	assert_null(game.context)
	assert_eq(screen.game_state, null)
	assert_eq(screen.field_controller, null)
	assert_eq(screen.conversation_controller, null)
	assert_eq(screen.recovery_controller, null)
	assert_eq(screen.combat_controller, null)
	assert_eq(screen.combat_state, null)
	assert_eq(screen.catalog, null)
	assert_eq(screen.intent_requested.get_connections().size(), 0)
	assert_eq(String(screen.current_state()), "")
	assert_eq(game.save_state(), {})
	assert_eq(_state_of(game), null)
	assert_false(game.execute_command(&"confirm"))
	assert_false(game.execute_command(&"move", {"direction": Vector2(1.0, 0.0)}))
	assert_false(game.execute_command(&"accept_recovery"))
	game.call("_process", 0.016)
	assert_eq(game.save_state(), {})


func test_save_state_is_twelve_key_json_safe_envelope() -> void:
	var game := _spawn()
	var snapshot: Dictionary = game.save_state()
	assert_eq(_sorted_keys(snapshot), _sorted(SAVE_ROOT_KEYS))
	assert_eq(String(snapshot["state_format"]), TopDownActionRpgGameState.STATE_FORMAT)
	assert_eq(int(snapshot["save_version"]), 1)
	assert_false(String(snapshot["run_id"]).is_empty())
	assert_false(String(snapshot["content_revision"]).is_empty())
	assert_true(snapshot["commit_log"] is Array)
	assert_true(SaveService.is_json_safe(snapshot))
	var round_trip: Variant = JSON.parse_string(JSON.stringify(snapshot))
	assert_true(round_trip is Dictionary)
	assert_eq(String((round_trip as Dictionary)["state_format"]), TopDownActionRpgGameState.STATE_FORMAT)
	_assert_envelope(game.save_state(), snapshot, "immediate")
	game.execute_command(&"focus", {"step": 1})
	var after_focus: Dictionary = game.save_state()
	assert_eq(_sorted_keys(after_focus), _sorted(SAVE_ROOT_KEYS))
	assert_true(SaveService.is_json_safe(after_focus))


func test_load_state_rejects_wrong_format_wrong_version_and_stale_root() -> void:
	var game := _spawn()
	var expected: Dictionary = game.save_state()
	var wrong_format: Dictionary = expected.duplicate(true)
	wrong_format["state_format"] = "other_module.save.v9"
	var wrong_version: Dictionary = expected.duplicate(true)
	wrong_version["save_version"] = "1"
	var missing_section: Dictionary = expected.duplicate(true)
	missing_section.erase("progression")
	var stale_world: Dictionary = expected.duplicate(true)
	(stale_world["world"] as Dictionary)["retired_prototype_root"] = {}
	var rejected: Array[Dictionary] = [
		{},
		wrong_format,
		wrong_version,
		missing_section,
		stale_world,
		{"board_id": "rule_rewriting", "mode": 3, "solved": true},
		{"state_format": TopDownActionRpgGameState.STATE_FORMAT, "save_version": 1, "run_id": "stale"},
	]
	for state: Dictionary in rejected:
		game.load_state(state)
		_assert_envelope(game.save_state(), expected, "rejected")
	assert_eq(game.migrate_save(1, expected), expected)
	assert_eq(game.migrate_save(0, wrong_format), {})
	assert_eq(game.migrate_save(0, wrong_version), {})
	assert_eq(game.migrate_save(0, {}), {})


func test_combat_mid_state_is_stripped_and_reload_resumes_at_encounter_boundary() -> void:
	var game := _spawn(_fresh_snapshot(CHOIR_ENCOUNTER, 220))
	assert_eq(_mode_of(game), "combat")
	assert_true(_player_window_open(game))
	assert_eq(_combat_of(game).queue.size(), 0)
	assert_true(game.execute_command(&"combat_action", {"action_id": GUARD_ACTION}))
	assert_eq(_combat_of(game).queue.size(), 1)
	assert_eq(int((_controller_of(game).consumed_slots as Dictionary)[StringName(TopDownActionRpgGameState.PLAYER_ROLE_ID)]), 1)
	assert_eq(String((_combat_of(game).queue[0] as TopDownActionRpgCombatState.QueuedIntent).action_id), GUARD_ACTION)
	var mid_snapshot: Dictionary = game.save_state()
	assert_eq(_sorted_keys(mid_snapshot), _sorted(SAVE_ROOT_KEYS))
	assert_eq(_sorted_keys(mid_snapshot["combat"]), _sorted(COMBAT_SAVE_KEYS))
	assert_eq(mid_snapshot["combat"]["pre_command_intent"], [])
	assert_eq(String(mid_snapshot["combat"]["active_encounter_id"]), CHOIR_ENCOUNTER)
	for key: String in COMBAT_TRANSIENT_KEYS:
		assert_false(mid_snapshot["combat"].has(key), key)
		assert_false(mid_snapshot["world"].has(key), key)
	var encoded_combat: String = JSON.stringify(mid_snapshot["combat"])
	for key: String in COMBAT_TRANSIENT_KEYS:
		assert_false(encoded_combat.contains('"%s"' % key), key)
	assert_eq(String(mid_snapshot["field"]["active_interaction_id"]), "")
	var resumed := _spawn(mid_snapshot)
	assert_eq(_mode_of(resumed), "combat")
	assert_eq(_combat_of(resumed).scheduler_tick, 0)
	assert_eq(_combat_of(resumed).cycle_index, 0)
	assert_eq(_combat_of(resumed).queue.size(), 0)
	assert_eq((_controller_of(resumed).consumed_slots as Dictionary).size(), 1)
	assert_eq(int((_controller_of(resumed).consumed_slots as Dictionary)[StringName(TopDownActionRpgGameState.PLAYER_ROLE_ID)]), 0)
	assert_eq(_combat_of(resumed).actors.size(), 4)
	assert_eq(_combat_of(resumed).rng_state, TopDownActionRpgGameState.stable_seed(CHOIR_ENCOUNTER, 1))
	assert_eq(String(_player_of(resumed).stance_state), "normal")
	assert_true(_player_window_open(resumed))


func test_pending_state_is_applied_after_enter_with_a_fresh_context() -> void:
	var first := _spawn()
	first.execute_command(&"focus", {"step": 2})
	first.execute_command(&"move", {"direction": Vector2(1.0, 0.0)})
	var pending: Dictionary = first.save_state()
	assert_eq(String(pending["field"]["region_id"]), ENTRY_REGION)
	var second := _make_module()
	var injected := _context()
	assert_eq(second.save_state(), {})
	second.load_state(pending)
	assert_eq(second.save_state(), {})
	second.enter(injected)
	assert_eq(second.context, injected)
	assert_eq(String(_state_of(second).region_id()), ENTRY_REGION)
	assert_eq(_state_of(second).run_id, _state_of(first).run_id)
	assert_eq(String(_state_of(second).content_revision), String(pending["content_revision"]))
	assert_eq(_position_of(second), _position_of(first))
	assert_eq(String(second.save_state()["field"]["active_interaction_id"]), String(pending["field"]["active_interaction_id"]))
	assert_eq(str(second.save_state()["progression"]), str(pending["progression"]))
	var reloaded := _spawn()
	reloaded.load_state(pending)
	_assert_envelope(reloaded.save_state(), second.save_state(), "reload")
	assert_eq(_screen_of(second).current_state(), TopDownActionRpgScreen.STATE_FIELD)


func test_input_disabled_blocks_execute_command_screen_intents_and_held_state() -> void:
	var game := _spawn()
	var before: Dictionary = game.save_state()
	var origin: Vector2 = _position_of(game)
	var screen := _screen_of(game)
	game.context.input_enabled = false
	assert_false(game.execute_command(&"move", {"direction": Vector2(1.0, 0.0)}))
	assert_false(game.execute_command(&"field_move", {"direction": Vector2(0.0, 1.0)}))
	assert_false(game.execute_command(&"focus", {"step": 1}))
	assert_false(game.execute_command(&"interact", {"interactable_id": DESK_NPC}))
	assert_false(game.execute_command(&"confirm"))
	assert_false(game.execute_command(&"cancel"))
	assert_false(game.execute_command(&"reset"))
	assert_false(game.execute_command(&"accept_recovery"))
	screen.submit_move(Vector2(1.0, 0.0))
	screen.submit_focus(1)
	screen.submit_confirm()
	screen.submit_cancel()
	screen.submit_row(StringName(DESK_NPC))
	screen.submit_row(&"End Turn")
	game.call("_process", 0.0)
	_assert_envelope(game.save_state(), before, "input_disabled")
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_FIELD)
	Input.action_press(&"top_down_action_rpg_right")
	game.call("_process", 0.0)
	Input.action_release(&"top_down_action_rpg_right")
	assert_eq(_position_of(game), origin)
	game.context.input_enabled = true
	game.call("_process", 0.0)
	game.call("_process", 0.0)
	assert_eq(_position_of(game), origin)
	assert_true(game.execute_command(&"move", {"direction": Vector2(1.0, 0.0)}))
	assert_ne(_position_of(game), origin)


func test_all_six_allowed_actions_are_edge_dispatched_and_bound_keys_do_not_repeat() -> void:
	var game := _spawn()
	var injected: ModuleContext = game.context
	assert_eq(injected.allowed_actions.size(), 6)
	for action: String in EXPECTED_ACTIONS:
		assert_true(injected.allows_action(StringName(action)), action)
	var origin: Vector2 = _position_of(game)
	for index: int in range(4):
		var action := StringName(EXPECTED_ACTIONS[index])
		var before: Vector2 = _position_of(game)
		_press(game, action)
		var after: Vector2 = _position_of(game)
		assert_ne(after, before, EXPECTED_ACTIONS[index])
		_press(game, StringName(EXPECTED_ACTIONS[OPPOSITE_INDEX[index]]))
		assert_eq(_position_of(game), before, EXPECTED_ACTIONS[index])
	assert_eq(_position_of(game), origin)
	Input.action_press(&"top_down_action_rpg_right")
	game.call("_process", 0.0)
	var held_once: Vector2 = _position_of(game)
	game.call("_process", 0.0)
	game.call("_process", 0.0)
	Input.action_release(&"top_down_action_rpg_right")
	game.call("_process", 0.0)
	assert_ne(held_once, origin)
	assert_eq(_position_of(game), held_once)
	game.call("_process", 0.0)
	assert_eq(_position_of(game), held_once)
	var desk_stand: Vector2 = _walk_to_interactable(game, DESK_NPC)
	assert_true(_focus_interactable(game, DESK_NPC), DESK_NPC)
	assert_eq(_focused_interactable_id(game), DESK_NPC)
	_press(game, &"top_down_action_rpg_confirm")
	assert_eq(_mode_of(game), "dialogue")
	assert_eq(String(_conversation_of(game).conversation_id), RETURN_DESK)
	_press(game, &"top_down_action_rpg_cancel")
	assert_eq(_mode_of(game), "field")
	assert_eq(String(_conversation_of(game).conversation_id), "")
	_press(game, &"top_down_action_rpg_confirm")
	assert_eq(_mode_of(game), "dialogue")
	assert_eq(String(_conversation_of(game).conversation_id), RETURN_DESK)
	assert_eq(int(_conversation_of(game).page_index), 0)
	assert_true(game.execute_command(&"dialogue_focus", {"step": 1}))
	assert_eq(String(_conversation_of(game).active_choice_id), INDEX_RETURN_CHOICE)
	assert_true(game.execute_command(&"choice_confirm", {"choice_id": INDEX_RETURN_CHOICE}))
	assert_true(_conversation_of(game).committed)
	assert_true(_state_of(game).choice_taken(RETURN_DESK, INDEX_RETURN_CHOICE))
	assert_eq(String(_conversation_of(game).active_choice_id), "ch_withhold_category")
	assert_true(game.execute_command(&"choice_confirm", {}))
	assert_false(_conversation_of(game).committed)
	assert_eq(String(_conversation_of(game).conversation_id), "")
	assert_eq(_mode_of(game), "field")
	assert_eq(_screen_of(game).current_state(), TopDownActionRpgScreen.STATE_FIELD)
	assert_eq(_position_of(game), desk_stand)


func test_module_source_has_no_direct_input_polling_root_lookup_or_other_module_reference() -> void:
	var module_source: String = _read(MODULE_SCRIPT)
	for token: String in FORBIDDEN_RUNTIME_TOKENS:
		assert_false(module_source.contains(token), token)
	assert_true(module_source.contains("context.is_action_pressed"))
	assert_true(module_source.contains("for action: StringName in ACTIONS:"))
	assert_true(module_source.contains("context.input_enabled"))
	var screen_source: String = _read(SCREEN_SCRIPT)
	for token: String in ["Input.", "InputMap", "Input.is_action_pressed", "/root"]:
		assert_false(screen_source.contains(token), token)
	for foreign: String in ["rule_rewriting", "deduction_casework", "dedution_casework", "odd_road_adventure", "first_entry"]:
		assert_false(module_source.contains(foreign), foreign)


func test_field_dialogue_choice_and_document_close_all_return_to_field() -> void:
	var game := _spawn()
	assert_eq(_mode_of(game), "field")
	assert_true(_approach_and_interact(game, DESK_NPC))
	assert_eq(_mode_of(game), "dialogue")
	var state := _state_of(game)
	assert_eq(String(state.field.get("active_interaction_id", "")), DESK_NPC)
	assert_true(game.execute_command(&"dialogue_focus", {"step": 1}))
	assert_eq(String(_conversation_of(game).active_choice_id), INDEX_RETURN_CHOICE)
	assert_true(game.execute_command(&"choice_confirm", {"choice_id": RETURN_DESK_CHOICE}))
	assert_true(state.choice_taken(RETURN_DESK, RETURN_DESK_CHOICE))
	assert_true(state.flag_is("world_h0_arrival_filed"))
	assert_eq(String(state.relationship_state("rel_01_ilyra_record")), "rs_candid")
	assert_false(state.conversation_state(RETURN_DESK).is_empty())
	assert_true(_conversation_of(game).committed)
	assert_true(game.execute_command(&"dialogue_cancel"))
	assert_eq(_mode_of(game), "dialogue")

	var second := _spawn()
	assert_true(_approach_and_interact(second, DESK_NPC))
	assert_eq(_mode_of(second), "dialogue")
	assert_true(second.execute_command(&"dialogue_cancel"))
	assert_eq(_mode_of(second), "field")
	assert_eq(String(_state_of(second).field.get("active_interaction_id", "")), DESK_NPC)
	assert_eq(_screen_of(second).current_state(), TopDownActionRpgScreen.STATE_FIELD)

	var reader := _spawn(_document_ready_snapshot())
	assert_eq(String(_state_of(reader).region_id()), KILN_REGION)
	assert_true(_approach_and_interact(reader, KILN_DOOR_PROP))
	assert_eq(_mode_of(reader), "dialogue")
	assert_eq(String(_conversation_of(reader).document_id), KILN_DOCUMENT)
	assert_eq(_screen_of(reader).current_state(), TopDownActionRpgScreen.STATE_DOCUMENT_MAX)
	assert_true(reader.execute_command(&"document_advance"))
	assert_eq(String(_conversation_of(reader).document_id), KILN_DOCUMENT)
	assert_eq(_screen_of(reader).current_state(), TopDownActionRpgScreen.STATE_DOCUMENT_CORRUPTED)
	assert_true(reader.execute_command(&"document_advance"))
	assert_eq(String(_conversation_of(reader).document_id), "")
	assert_eq(_mode_of(reader), "field")
	assert_eq(_screen_of(reader).current_state(), TopDownActionRpgScreen.STATE_FIELD)
	assert_eq(int(_state_of(reader).document_read_count(KILN_DOCUMENT)), 1)
	assert_true(_state_of(reader).effect_has_fired(KILN_EFFECT))
	assert_eq(String(_state_of(reader).region_id()), KILN_REGION)
	assert_eq(String(_state_of(reader).field.get("active_interaction_id", "")), KILN_DOOR_PROP)
	assert_not_null(_interactable_of(reader, KILN_DOOR_PROP))
	assert_true(_field_of(reader).focus_candidates().size() > 0)


func test_screen_confirm_passes_every_authored_page_including_wait_into_the_choice_set() -> void:
	var game := _spawn()
	assert_true(_approach_and_interact(game, DESK_NPC))
	assert_eq(_mode_of(game), "dialogue")
	var conversation := _conversation_of(game)
	var screen := _screen_of(game)
	assert_eq(String(conversation.conversation_id), RETURN_DESK)
	var pages: Array = conversation.pages()
	var wait_pages: int = 0
	for page: Variant in pages:
		if String((page as Dictionary).get("advance", "auto")) == "wait":
			wait_pages += 1
	assert_true(wait_pages > 0, "authored return desk carries a wait page")
	for index: int in range(pages.size()):
		assert_eq(int(conversation.page_index), index)
		assert_false(conversation.at_choice_set())
		assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_DIALOGUE_CHOICE_FOCUS)
		screen.submit_confirm()
	assert_true(conversation.at_choice_set())
	assert_eq(_mode_of(game), "dialogue")
	assert_false(conversation.choice_rows().is_empty())
	assert_eq(String(conversation.focused_choice().get("choice_id", "")), RETURN_DESK_CHOICE)
	screen.submit_confirm()
	assert_true(_state_of(game).choice_taken(RETURN_DESK, RETURN_DESK_CHOICE))


func test_authored_choice_rows_show_their_whole_text_inside_the_choice_panel() -> void:
	var game := _spawn()
	assert_true(_approach_and_interact(game, DESK_NPC))
	var conversation := _conversation_of(game)
	var screen := _screen_of(game)
	for _page: int in range(conversation.pages().size()):
		screen.submit_confirm()
	assert_true(conversation.at_choice_set())
	await wait_process_frames(4)
	var panel := screen.get_node("%ChoicePanel") as Control
	var band := screen.get_node("%DialogueBand") as Control
	var rows := screen.get_node("%ChoiceRows") as VBoxContainer
	assert_true(panel.is_visible_in_tree())
	var checked: int = 0
	for child: Node in rows.get_children():
		var row := child as TopDownActionRpgRow
		if row == null or not row.visible:
			continue
		var label := row.get_node("Text") as Label
		var needed: Vector2 = label.get_minimum_size()
		assert_true(needed.x <= label.size.x + 0.5, "%s needs width %.1f, has %.1f" % [row.row_id, needed.x, label.size.x])
		assert_true(needed.y <= label.size.y + 0.5, "%s needs height %.1f, has %.1f" % [row.row_id, needed.y, label.size.y])
		assert_true(panel.get_global_rect().grow(0.5).encloses(row.get_global_rect()), "%s stays inside the choice panel" % row.row_id)
		checked += 1
	var expected: int = 0
	for choice: Dictionary in conversation.choice_rows():
		if bool(choice.get("visible", false)):
			expected += 1
	assert_true(expected > 0)
	assert_eq(checked, mini(expected, TopDownActionRpgScreen.MAX_CHOICE_ROWS))
	assert_true(screen.get_global_rect().grow(0.5).encloses(panel.get_global_rect()))
	assert_false(panel.get_global_rect().grow(-0.5).intersects(band.get_global_rect().grow(-0.5)))


func test_combat_build_opens_player_window_and_deterministic_enemy_windows() -> void:
	var first := _spawn(_fresh_snapshot(CHOIR_ENCOUNTER, 220))
	var catalog := _catalog_of(first)
	var record: Dictionary = catalog.record(CHOIR_ENCOUNTER)
	var combat := _combat_of(first)
	assert_false(record.is_empty(), CHOIR_ENCOUNTER)
	assert_eq(String(combat.encounter_id), CHOIR_ENCOUNTER)
	assert_eq(int(combat.encounter_attempt_serial), 1)
	assert_eq(combat.rng_state, TopDownActionRpgGameState.stable_seed(CHOIR_ENCOUNTER, 1))
	assert_eq(combat.actors.size(), 4)
	assert_eq(String(combat.submode), "command_category")
	assert_eq(_player_window_open(first), true)
	assert_eq(String(_controller_of(first).current_actor_id), TopDownActionRpgGameState.PLAYER_ROLE_ID)
	var enemy_ids: Array[String] = []
	for actor: TopDownActionRpgCombatState.ActorState in combat.actors:
		if actor.side == "enemy_side":
			enemy_ids.append(String(actor.actor_id))
	assert_eq(enemy_ids, ["enemy_ash_hound", "enemy_ash_hound_2", "enemy_ember_clerk"])
	assert_eq(enemy_ids, _roster_actor_ids(catalog, record))
	assert_eq(String((record.get("context", {}) as Dictionary).get("region_id", "")), KILN_REGION)
	assert_eq(String(_state_of(first).region_id()), KILN_REGION)
	var player := _player_of(first)
	assert_eq(String(player.side), "player_side")
	assert_eq(int(player.max_hp), 220)
	assert_eq(int(player.hp), 220)
	assert_eq(int(player.action_slot_snapshot), 1)
	_lock_actor_onto_action(first, CHARGE_ENEMY, CHARGE_ACTION)
	var ledger: Array = _combat_ledger(first)
	var second := _spawn(_fresh_snapshot(CHOIR_ENCOUNTER, 220))
	_lock_actor_onto_action(second, CHARGE_ENEMY, CHARGE_ACTION)
	assert_eq(_combat_ledger(second), ledger)
	assert_gt(ledger.size(), 3)
	var tick_seen: bool = false
	var reaction_seen: bool = false
	var authored_charge_seen: bool = false
	for entry: Dictionary in ledger:
		if int(entry["tick"]) > 0:
			tick_seen = true
		if bool(entry["awaiting"]):
			reaction_seen = true
		if String(entry["label"]) == "reaction" and String(entry["charge_action"]) == CHARGE_ACTION:
			authored_charge_seen = true
	assert_true(tick_seen)
	assert_true(reaction_seen)
	assert_true(authored_charge_seen, str(ledger))
	var windowed: Array[String] = []
	for key: Variant in (_controller_of(first).consumed_slots as Dictionary):
		windowed.append(String(key))
	assert_true(windowed.has(CHARGE_ENEMY) or windowed.has("enemy_ember_clerk"), str(windowed))
	assert_eq(String(_player_of(first).side), "player_side")


func _roster_actor_ids(catalog: TopDownActionRpgContentLoader.Catalog, record: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for entry: Variant in record.get("roster", []):
		if not entry is Dictionary:
			continue
		var enemy_id: String = String((entry as Dictionary).get("enemy_id", ""))
		for index: int in range(maxi(1, int((entry as Dictionary).get("count", 1)))):
			result.append(enemy_id if index == 0 else "%s_%d" % [enemy_id, index + 1])
	return result


func _catalog_of(game: GameModule) -> TopDownActionRpgContentLoader.Catalog:
	return game.get("_catalog") as TopDownActionRpgContentLoader.Catalog


func _enemy_action_ids(game: GameModule) -> Array[String]:
	var catalog := _catalog_of(game)
	var result: Array[String] = []
	for record_id: String in catalog.ids_of_kind("actions"):
		if String(catalog.record(record_id).get("owner", "")) == ENEMY_ACTION_OWNER:
			result.append(record_id)
	return result


func _actor_of(game: GameModule, actor_id: String) -> TopDownActionRpgCombatState.ActorState:
	var combat := _combat_of(game)
	return combat.find_actor(StringName(actor_id)) if combat != null else null


func _hold_actor_from_actions(game: GameModule, actor_id: String, except_action_id: String = "") -> void:
	var actor := _actor_of(game, actor_id)
	assert_not_null(actor, actor_id)
	if actor == null:
		return
	var cooldowns: Dictionary = actor.action_cooldowns.duplicate()
	for candidate: String in _enemy_action_ids(game):
		if candidate != except_action_id:
			cooldowns[candidate] = ENEMY_ACTION_HOLD
	actor.action_cooldowns = cooldowns


func _lock_actor_onto_action(game: GameModule, actor_id: String, action_id: String) -> void:
	var record: Dictionary = _catalog_of(game).record(action_id)
	assert_false(record.is_empty(), action_id)
	assert_eq(String(record.get("lifecycle", "")), "charge", action_id)
	assert_eq(String(record.get("owner", "")), ENEMY_ACTION_OWNER, action_id)
	assert_true(_enemy_action_ids(game).has(action_id), action_id)
	_hold_actor_from_actions(game, actor_id, action_id)


func _combat_ledger(game: GameModule) -> Array:
	var ledger: Array = []
	assert_true(_player_window_open(game))
	ledger.append(_ledger_row(game, "player_window"))
	for _index: int in range(LEDGER_STEPS):
		if _mode_of(game) != "combat":
			break
		var controller := _controller_of(game)
		if controller != null and controller.awaiting_reaction:
			var charge_action: String = String(controller.pending_charge.charge_action_id) if controller.pending_charge != null else ""
			game.execute_command(&"combat_reaction")
			ledger.append(_ledger_row(game, "reaction", charge_action))
			continue
		if _player_window_open(game):
			game.execute_command(&"combat_end_turn")
		game.call("_process", 0.0)
		ledger.append(_ledger_row(game, ""))
	return ledger


func _ledger_row(game: GameModule, label: String, charge_action: String = "") -> Dictionary:
	var combat := _combat_of(game)
	var controller := _controller_of(game)
	var player := _player_of(game)
	var vitals: Array[int] = []
	if combat != null:
		for actor: TopDownActionRpgCombatState.ActorState in combat.actors:
			vitals.append(actor.hp)
	return {
		"label": label,
		"window": String(controller.current_actor_id) if controller != null else "",
		"submode": String(combat.submode) if combat != null else "",
		"tick": int(combat.scheduler_tick) if combat != null else -1,
		"result": String(combat.result) if combat != null else "",
		"awaiting": bool(controller.awaiting_reaction) if controller != null else false,
		"charge_action": charge_action,
		"hp": vitals,
		"player_hp": int(player.hp) if player != null else -1,
	}


func test_combat_command_target_and_charge_reaction_and_receive_path() -> void:
	var game := _spawn(_fresh_snapshot(CHOIR_ENCOUNTER, 220))
	var screen := _screen_of(game)
	var controller := _controller_of(game)
	var combat := _combat_of(game)
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_COMBAT_COMMAND)
	assert_eq(String((screen.get_node("%ActionSlots") as Label).text), ACTIONS_PREFIX + "1")
	assert_true(game.execute_command(&"combat_category", {"category": "attack"}))
	assert_eq(String(controller.current_category), "attack")
	assert_eq(String(combat.submode), "command_action")
	assert_true(game.execute_command(&"combat_action", {"action_id": PLAYER_ACTION}))
	assert_eq(String(combat.submode), "target_select")
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_TARGET_SELECT)
	assert_eq(String(controller.target_focus_actor_id), "enemy_ash_hound")
	var hound := combat.find_actor(StringName("enemy_ash_hound"))
	var player := _player_of(game)
	var hp_before: int = hound.hp
	var tick_before: int = combat.scheduler_tick
	var mp_before: int = player.mp
	var slots_before: int = player.action_slot_snapshot
	assert_true(game.execute_command(&"combat_target_focus", {"step": 1}))
	assert_eq(String(controller.target_focus_actor_id), "enemy_ash_hound_2")
	assert_true(game.execute_command(&"combat_target_focus", {"step": 1}))
	assert_eq(String(controller.target_focus_actor_id), "enemy_ember_clerk")
	assert_true(game.execute_command(&"combat_target_focus", {"step": 1}))
	assert_eq(String(controller.target_focus_actor_id), "enemy_ember_clerk")
	assert_true(game.execute_command(&"combat_target_focus", {"step": -1}))
	assert_eq(String(controller.target_focus_actor_id), "enemy_ash_hound_2")
	assert_true(game.execute_command(&"combat_target_focus", {"step": -1}))
	assert_eq(String(controller.target_focus_actor_id), "enemy_ash_hound")
	assert_true(game.execute_command(&"combat_cancel"))
	assert_eq(String(combat.submode), "command_action")
	assert_eq(String(controller.current_actor_id), TopDownActionRpgGameState.PLAYER_ROLE_ID)
	assert_eq(combat.queue.size(), 0)
	assert_eq(int(hound.hp), hp_before)
	assert_eq(int(combat.scheduler_tick), tick_before)
	assert_eq(int(player.mp), mp_before)
	assert_eq(int(player.action_slot_snapshot), slots_before)
	assert_true(game.execute_command(&"combat_action", {"action_id": PLAYER_ACTION}))
	assert_true(game.execute_command(&"combat_target", {"target_actor_id": "enemy_ember_clerk"}))
	assert_eq(combat.queue.size(), 1)
	assert_eq(String((combat.queue[0] as TopDownActionRpgCombatState.QueuedIntent).action_id), PLAYER_ACTION)
	assert_eq(String((combat.queue[0] as TopDownActionRpgCombatState.QueuedIntent).target_actor_id), "enemy_ember_clerk")
	assert_eq(String((screen.get_node("%ActionSlots") as Label).text), ACTIONS_PREFIX + "1")
	assert_eq(game.save_state()["combat"]["pre_command_intent"], [])
	var tick_after_commit: int = combat.scheduler_tick
	game.call("_process", 0.0)
	assert_eq(combat.queue.size(), 0)
	assert_gt(int(combat.scheduler_tick), tick_after_commit)
	assert_true(_player_window_open(game))
	_lock_actor_onto_action(game, CHARGE_ENEMY, CHARGE_ACTION)
	for enemy_id: String in _roster_actor_ids(_catalog_of(game), _catalog_of(game).record(CHOIR_ENCOUNTER)):
		if enemy_id != CHARGE_ENEMY:
			_hold_actor_from_actions(game, enemy_id)
	var charging := _await_charge(game)
	assert_not_null(charging)
	assert_eq(String(charging.actor_id), CHARGE_ENEMY)
	assert_eq(String(charging.charge_state.charge_action_id), CHARGE_ACTION)
	assert_eq(String(charging.charge_state.target_actor_id), String(player.actor_id))
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_CHARGE_COUNTER)
	assert_eq(String(charging.charge_state.stage), "reaction")
	assert_true(charging.charge_state.valid_reaction_ids.has(REACTION_ACTION))
	assert_true(charging.charge_state.forbidden_response_ids.has(GUARD_ACTION))
	assert_true(_controller_of(game).awaiting_reaction)
	var pending_charge := _controller_of(game).pending_charge
	game.call("_open_player_window")
	assert_true(_controller_of(game).awaiting_reaction)
	assert_same(_controller_of(game).pending_charge, pending_charge)
	assert_same(charging.charge_state, pending_charge)
	assert_true(charging.charge_state.is_active())
	assert_eq(String(charging.charge_state.stage), "reaction")
	combat.submode = "reaction_select"
	assert_true(game.execute_command(&"combat_reaction"))
	assert_false(_controller_of(game).awaiting_reaction)
	assert_true(charging.charge_state == null or not charging.charge_state.is_active())
	assert_ne(screen.current_state(), TopDownActionRpgScreen.STATE_CHARGE_COUNTER)
	var second_charge := _await_charge(game)
	assert_not_null(second_charge)
	assert_eq(String(second_charge.actor_id), CHARGE_ENEMY)
	assert_eq(String(second_charge.charge_state.charge_action_id), CHARGE_ACTION)
	combat.submode = "reaction_select"
	assert_true(game.execute_command(&"combat_receive"))
	assert_false(_controller_of(game).awaiting_reaction)
	assert_not_null(_controller_of(game).pending_charge)
	assert_eq(String(_controller_of(game).pending_charge.stage), "telegraph")
	assert_eq(String(_controller_of(game).pending_charge.owner_actor_id), String(second_charge.actor_id))
	assert_eq(String(_controller_of(game).pending_charge.charge_action_id), CHARGE_ACTION)


func _await_charge(game: GameModule) -> TopDownActionRpgCombatState.ActorState:
	for _index: int in range(COMBAT_LIMIT):
		if _mode_of(game) != "combat":
			return null
		var controller := _controller_of(game)
		if controller != null and controller.awaiting_reaction and controller.pending_charge != null:
			var charging: TopDownActionRpgCombatState.ActorState = _combat_of(game).find_actor(controller.pending_charge.owner_actor_id)
			if charging != null and charging.charge_state != null and charging.charge_state.is_active():
				return charging
		if _player_window_open(game):
			game.execute_command(&"combat_end_turn")
		game.call("_process", 0.0)
	return null


func test_combat_defeat_requests_recovery_and_returns_to_rebuilt_field() -> void:
	var game := _spawn(_fresh_snapshot(CHOIR_ENCOUNTER, 1))
	assert_eq(_mode_of(game), "combat")
	assert_true(_player_window_open(game))
	assert_true(_controller_of(game).force_result("defeat"))
	game.call("_process", 0.0)
	assert_eq(_mode_of(game), "recovery")
	var recovery := _recovery_of(game)
	var state := _state_of(game)
	assert_false(recovery.pending_definition.is_empty())
	assert_eq(String(recovery.pending_definition.get("id", "")), "rec_r1_kiln_reentry")
	assert_eq(_screen_of(game).current_state(), TopDownActionRpgScreen.STATE_FAILURE_DEATH)
	assert_eq(String(state.encounter_resolution(CHOIR_ENCOUNTER)), "defeat")
	assert_eq(String(state.recovery.get("pending_outcome_id", "")), "rec_r1_kiln_reentry")
	assert_eq((state.recovery.get("history", []) as Array).size(), 0)
	assert_true(game.execute_command(&"accept_recovery"))
	assert_eq(_mode_of(game), "field")
	assert_true(recovery.pending_definition.is_empty())
	assert_eq(String(state.recovery.get("pending_outcome_id", "")), "")
	var history: Array = state.recovery.get("history", []) if state.recovery.get("history", []) is Array else []
	assert_eq(history.size(), 1)
	assert_eq(String((history[0] as Dictionary)["kind"]), "institutional_reentry")
	assert_eq(String((history[0] as Dictionary)["recovery_event_id"]), "rec_r1_kiln_reentry")
	assert_eq(int(state.axis_value("continuity_pressure")), 1)
	var continuity: Dictionary = state.recovery.get("continuity", {}) if state.recovery.get("continuity", {}) is Dictionary else {}
	assert_eq(int(continuity.get("recovery_count", 0)), 1)
	assert_eq(String(continuity.get("continuity_pressure", "")), "branched")
	assert_eq(String(state.field.get("region_id", "")), KILN_REGION)
	assert_eq(String(state.field.get("anchor_id", "")), KILN_DOOR_PROP)
	assert_eq(String(state.encounter_resolution(CHOIR_ENCOUNTER)), "defeat")
	assert_eq(String(state.combat.get("active_encounter_id", "")), "")
	assert_eq(String(state.combat.get("resume_boundary", "")), "field")
	assert_eq(_screen_of(game).current_state(), TopDownActionRpgScreen.STATE_FIELD)
	assert_true(state.effect_has_fired(REGISTRY_EFFECT))
	var snapshot: Dictionary = game.save_state()
	assert_eq(_sorted_keys(snapshot), _sorted(SAVE_ROOT_KEYS))
	assert_true(SaveService.is_json_safe(snapshot))
	assert_eq(String(snapshot["recovery"]["continuity"]["continuity_pressure"]), "branched")


func test_combat_victory_aftermath_stays_visible_until_first_field_intent() -> void:
	var game := _spawn(_fresh_snapshot(CHOIR_ENCOUNTER, 220))
	assert_true(_controller_of(game).force_result("victory"))
	game.call("_process", 0.0)
	assert_eq(_mode_of(game), "field_return")
	assert_eq(String(_state_of(game).encounter_resolution(CHOIR_ENCOUNTER)), "victory")
	assert_eq(_screen_of(game).current_state(), TopDownActionRpgScreen.STATE_AFTERMATH_REVISIT)
	assert_true(_state_of(game).effect_has_fired(KILN_EFFECT))
	var world: Dictionary = _state_of(game).world
	assert_eq(String((world["regions"][KILN_REGION] as Dictionary)["state_tag"]), "r1_choir_cleared")
	assert_false(_state_of(game).prop_state(KILN_DOOR_PROP).is_empty())
	_press(game, &"top_down_action_rpg_right")
	assert_eq(_mode_of(game), "field")
	assert_eq(_screen_of(game).current_state(), TopDownActionRpgScreen.STATE_FIELD)
	var snapshot: Dictionary = game.save_state()
	assert_eq(String(snapshot["combat"]["active_encounter_id"]), "")
	assert_eq(String(snapshot["combat"]["result"]), "")
	assert_eq(snapshot["combat"]["pre_command_intent"], [])
	assert_eq(String((snapshot["world"]["encounters"] as Dictionary)[CHOIR_ENCOUNTER]["resolution"]), "victory")


func test_presentation_exposes_all_sixteen_current_state_values_through_fixture_drives() -> void:
	var game := _spawn(_fresh_snapshot(CHOIR_ENCOUNTER, 220))
	game.set_process(false)
	var screen := _screen_of(game)
	var state := _state_of(game)
	var conversation := _conversation_of(game)
	var combat := _combat_of(game)
	var controller := _controller_of(game)
	var player := _player_of(game)
	var enemy := combat.find_actor(StringName("enemy_ash_hound"))
	var seen: Array[StringName] = []
	_reset_surface(screen, state)
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_FIELD)
	seen.append(screen.current_state())
	screen.set_input_bubble_active(true)
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_INPUT_BUBBLE)
	seen.append(screen.current_state())
	screen.set_input_bubble_active(false)
	screen.set_shell_open(true)
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_ESC_MENU)
	seen.append(screen.current_state())
	screen.set_shell_open(false)
	screen.set_narration_lines(PackedStringArray(["The shadow over the arrival well has no filed owner."]))
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_NARRATION)
	seen.append(screen.current_state())
	screen.set_narration_lines(PackedStringArray())
	screen.set_aftermath_active(true)
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_AFTERMATH_REVISIT)
	seen.append(screen.current_state())
	_reset_surface(screen, state)
	screen.set_recovery_surface(true)
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_RECOVERY)
	seen.append(screen.current_state())
	_reset_surface(screen, state)
	screen.set_success_active(true)
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_SUCCESS)
	seen.append(screen.current_state())
	_reset_surface(screen, state)
	state.set_mode("recovery")
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_FAILURE_DEATH)
	seen.append(screen.current_state())
	_reset_surface(screen, state)
	state.set_mode("field_return")
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_AFTERMATH_REVISIT)
	_reset_surface(screen, state)
	assert_eq(String(conversation.open_conversation(StringName(RETURN_DESK), StringName(DESK_NPC))), "opened")
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_DIALOGUE_CHOICE_FOCUS)
	seen.append(screen.current_state())
	assert_eq(String(conversation.open_document(StringName(KILN_DOCUMENT))), "opened")
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_DOCUMENT_MAX)
	seen.append(screen.current_state())
	assert_eq(String(conversation.advance_document()), "document_advanced")
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_DOCUMENT_CORRUPTED)
	seen.append(screen.current_state())
	assert_eq(String(conversation.advance_document()), "document_closed")
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_FIELD)
	state.set_mode("combat")
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_COMBAT_COMMAND)
	seen.append(screen.current_state())
	controller.current_category = "item"
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_EQUIPMENT_NO_TURN)
	seen.append(screen.current_state())
	controller.current_category = "attack"
	enemy.stance_state = "guard"
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_GUARD_DODGE_BREAK)
	seen.append(screen.current_state())
	enemy.stance_state = "normal"
	combat.submode = "target_select"
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_TARGET_SELECT)
	seen.append(screen.current_state())
	combat.submode = "command_category"
	var charge := TopDownActionRpgCombatState.ChargeState.new()
	charge.owner_actor_id = enemy.actor_id
	charge.charge_action_id = StringName("act_ash_hound_lunge")
	charge.stage = "reaction"
	charge.stage_ordinal = 1
	charge.target_actor_id = player.actor_id
	charge.window_budget = 1
	charge.valid_reaction_ids = [REACTION_ACTION]
	charge.forbidden_response_ids = [GUARD_ACTION]
	charge.strike_action_id = StringName("act_ash_hound_lunge")
	enemy.charge_state = charge
	controller.pending_charge = charge
	controller.awaiting_reaction = true
	combat.submode = "reaction_select"
	screen.refresh()
	assert_eq(screen.current_state(), TopDownActionRpgScreen.STATE_CHARGE_COUNTER)
	seen.append(screen.current_state())
	var unique: Array[StringName] = []
	for value: StringName in seen:
		if not unique.has(value):
			unique.append(value)
	assert_eq(unique.size(), 16)
	var expected: Array[StringName] = EXPECTED_STATES.duplicate()
	var actual: Array[StringName] = unique.duplicate()
	expected.sort()
	actual.sort()
	assert_eq(actual, expected)
	assert_eq(expected.size(), 16)


func _reset_surface(screen: TopDownActionRpgScreen, state: TopDownActionRpgGameState) -> void:
	screen.set_shell_open(false)
	screen.set_input_bubble_active(false)
	screen.set_aftermath_active(false)
	screen.set_recovery_surface(false)
	screen.set_failure_active(false)
	screen.set_success_active(false)
	screen.set_narration_lines(PackedStringArray())
	if screen.conversation_controller != null:
		screen.conversation_controller.document_id = &""
	state.set_mode("field")
	screen.refresh()


func test_presentation_has_no_ap_label_generic_red_bar_placeholder_or_persistent_shell_hud() -> void:
	var game := _spawn(_fresh_snapshot(CHOIR_ENCOUNTER, 220))
	game.set_process(false)
	var screen := _screen_of(game)
	var state := _state_of(game)
	var combat := _combat_of(game)
	var screen_source: String = _read(SCREEN_SCRIPT)
	var vector_source: String = _read(VECTOR_SCRIPT)
	var scene_source: String = _read(SCREEN_SCENE)
	var module_source: String = _read(MODULE_SCRIPT)
	var word_ap := RegEx.create_from_string("\\bAP\\b")
	assert_eq(word_ap.search_all(screen_source).size(), 0)
	assert_eq(word_ap.search_all(module_source).size(), 0)
	assert_eq(word_ap.search_all(vector_source).size(), 0)
	for token: String in FORBIDDEN_PRESENTATION_TOKENS:
		assert_false(screen_source.contains(token), token)
		assert_false(vector_source.contains(token), token)
		assert_false(scene_source.contains(token), token)
	assert_eq(TopDownActionRpgScreen.LABEL_ACTIONS_PREFIX, ACTIONS_PREFIX)
	assert_true(screen_source.contains('const LABEL_ACTIONS_PREFIX: String = "%s"' % ACTIONS_PREFIX))
	assert_false(screen_source.contains("draw_rect"))
	var bar_constants: Array[String] = []
	for found: RegExMatch in RegEx.create_from_string("const\\s+[A-Z_]*BAR[A-Z_]*\\s*:\\s*Rect2").search_all(vector_source):
		bar_constants.append(found.get_string())
	assert_eq(bar_constants.size(), 2)
	assert_eq(vector_source.count("_base_rect_to_local(TIMING_BAR)"), 1)
	assert_eq(vector_source.count("_base_rect_to_local(CONDITION_BAR)"), 1)
	assert_eq(_red_channel_count(vector_source), 0)
	assert_true(screen.is_visible_in_tree())
	var visited: Array[Node] = []
	_collect_nodes(screen, visited)
	for node: Node in visited:
		for token: String in SHELL_HUD_TOKENS:
			assert_false(String(node.name).contains(token), "%s/%s" % [node.name, token])
	state.set_mode("combat")
	screen.refresh()
	assert_eq(String((screen.get_node("%ActionSlots") as Label).text), ACTIONS_PREFIX + "1")
	for label: Label in _labels_of(screen):
		assert_false(String(label.text).begins_with("AP"), String(label.name))
		assert_false(String(label.text).contains(" AP"), String(label.name))
	assert_true(_visible(game, "%CombatUi"))
	assert_true(_visible(game, "%CombatLayer"))
	assert_false(_visible(game, "%FieldLayer"))
	_reset_surface(screen, state)
	assert_false(_visible(game, "%CombatUi"))
	assert_true(_visible(game, "%FieldLayer"))
	for layer: String in FIELD_ONLY_LAYERS:
		assert_false(_visible(game, layer), layer)
	assert_false((screen.get_node("%PlayerBand") as Control).is_visible_in_tree())
	assert_false((screen.get_node("%CommandRail") as Control).is_visible_in_tree())
	assert_eq(int(combat.find_actor(StringName("enemy_ash_hound")).hp), 60)
	assert_eq(int(_player_of(game).hp), 220)


func _red_channel_count(source: String) -> int:
	var found_colors: int = 0
	var hex_pattern := RegEx.create_from_string("Color\\(\"([0-9a-fA-F]{6})\"\\)")
	for found: RegExMatch in hex_pattern.search_all(source):
		var packed := Color(found.get_string(1))
		if packed.r > 0.5 and packed.r - packed.g > 0.15 and packed.r - packed.b > 0.15:
			found_colors += 1
	var float_pattern := RegEx.create_from_string("Color\\(\\s*([01](?:\\.[0-9]+)?)\\s*,\\s*([01](?:\\.[0-9]+)?)\\s*,\\s*([01](?:\\.[0-9]+)?)")
	for found: RegExMatch in float_pattern.search_all(source):
		var red := float(found.get_string(1))
		var green := float(found.get_string(2))
		var blue := float(found.get_string(3))
		if red > 0.5 and red - green > 0.15 and red - blue > 0.15:
			found_colors += 1
	return found_colors


func _collect_nodes(root: Node, out: Array[Node]) -> void:
	out.append(root)
	for child: Node in root.get_children():
		_collect_nodes(child, out)


func _labels_of(root: Node) -> Array[Label]:
	var result: Array[Label] = []
	var visited: Array[Node] = []
	_collect_nodes(root, visited)
	for node: Node in visited:
		if node is Label:
			result.append(node as Label)
	return result


func test_app_root_registers_top_down_action_rpg_once_with_no_route_and_no_autoload() -> void:
	var source: String = _read(APP_ROOT_SOURCE)
	var start: int = source.find("const NORMAL_IDS")
	var finish: int = source.find("const ROUTES")
	var catalog_at: int = source.find("@export var catalog")
	assert_gt(start, -1)
	assert_gt(finish, start)
	assert_gt(catalog_at, finish)
	assert_eq(source.substr(start, finish - start).count("&\"top_down_action_rpg\""), 1)
	assert_eq(source.count("top_down_action_rpg"), 1)
	assert_false(source.substr(finish, catalog_at - finish).contains("top_down_action_rpg"))
	var project: String = _read(PROJECT_SOURCE)
	assert_false(project.contains("top_down_action_rpg"))
	var autoload_at: int = project.find("[autoload]")
	var display_at: int = project.find("[display]")
	assert_gt(autoload_at, -1)
	assert_gt(display_at, autoload_at)
	var autoload_block: String = project.substr(autoload_at, display_at - autoload_at)
	assert_false(autoload_block.contains("top_down"))
	assert_eq(autoload_block.count("_mcp_game_helper"), 1)
	assert_false(project.contains("[input]"))
	assert_true(source.contains("bindings[StringName(\"%s_confirm\" % id)] = [KEY_Z]"))
	assert_true(source.contains("bindings[StringName(\"%s_cancel\" % id)] = [KEY_X]"))


func test_module_rejects_unknown_commands_and_malformed_payloads_atomically() -> void:
	var game := _spawn()
	var before: Dictionary = game.save_state()
	var origin: Vector2 = _position_of(game)
	assert_true(game.execute_command(&"no_such_command"))
	_assert_envelope(game.save_state(), before, "unknown_command")
	assert_true(game.execute_command(&"move", {"direction": "not_a_vector"}))
	assert_eq(_position_of(game), origin)
	assert_true(game.execute_command(&"focus", {"step": "one"}))
	_assert_envelope(game.save_state(), before, "malformed_step")
	assert_true(game.execute_command(&"move", {}))
	assert_eq(_position_of(game), origin)
	_assert_envelope(game.save_state(), before, "empty_direction")
	assert_true(game.execute_command(&"language", {"language": "en"}))
	assert_false(game.execute_command(&"language", {"language": 7}))
	_assert_envelope(game.save_state(), before, "language")
	assert_true(game.execute_command(&"interact", {"interactable_id": "no_such_record"}))
	assert_eq(_state_of(game).conversation_state("no_such_record").size(), 0)
	assert_eq(_state_of(game).prop_state("no_such_record"), "")
	assert_eq(_state_of(game).document_read_count("no_such_record"), 0)
