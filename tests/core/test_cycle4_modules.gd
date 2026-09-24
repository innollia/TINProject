extends GutTest

const SUFFIXES: Array[String] = ["left", "right", "up", "down", "confirm", "cancel"]
const RULE_SUFFIXES: Array[String] = [
	"left", "right", "up", "down", "confirm", "cancel", "undo", "reset", "forward",
	"turn_left", "turn_right", "cycle_3d_subject", "open_inventory", "cycle_metrix", "place",
	"hotbar_1", "hotbar_2", "hotbar_3", "hotbar_4", "hotbar_5", "hotbar_6", "hotbar_7", "hotbar_8", "hotbar_9"
]

var _owned_actions: Array[StringName] = []
var _requests: Array[Dictionary] = []

func after_each() -> void:
	for action: StringName in _owned_actions:
		Input.action_release(action)
		InputMap.erase_action(action)
	_owned_actions.clear()
	_requests.clear()

func _tap(game: GameModule, action: StringName) -> void:
	Input.action_press(action)
	game.call("_process", 0.1)
	Input.action_release(action)
	game.call("_process", 0.0)

func _spawn() -> GameModule:
	var packed := load("res://modules/rule_rewriting/entry.tscn") as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = &"rule_rewriting"
	injected.input_enabled = true
	for suffix: String in RULE_SUFFIXES:
		var action := StringName("rule_rewriting_%s" % suffix)
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			_owned_actions.append(action)
		injected.allowed_actions.append(action)
	game.context = injected
	add_child_autofree(game)
	game.load_state({})
	game.enter(injected)
	game.requested.connect(func(kind: StringName, payload: Dictionary) -> void: _requests.append({"kind": kind, "payload": payload.duplicate(true)}))
	return game

func test_rule_rewriting_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/rule_rewriting/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"rule_rewriting")
	assert_eq(manifest.save_version, 5)
	assert_eq(manifest.input_actions.size(), RULE_SUFFIXES.size())
	var game := _spawn()
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(defaults["state_format"], 5)
	assert_eq(defaults["board_id"], String(RuleLevelLoader.list_level_ids()[0]))
	assert_false(defaults.has("observed"))
	assert_false(defaults.has("mode"))
	assert_eq(game.migrate_save(5, defaults), defaults)
	assert_eq(game.migrate_save(4, defaults), game.migrate_save(0, {}))
	assert_eq(game.migrate_save(3, {"mode": 3, "solved": true, "player_position": 6}), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	game.load_state({"state_format": 5, "board_id": "bogus", "turn_index": INF, "solved": "yes"})
	assert_eq(game.save_state(), defaults)
	game.load_state({"state_format": 4, "mode": 3, "solved": true})
	assert_eq(game.save_state(), defaults)

func _first_you(game: GameModule) -> RuleGridEntity:
	var state := game.get("grid_state") as RuleGridState
	var rules := game.get("rule_set") as RuleSet
	for entity: RuleGridEntity in state.entities:
		if not entity.is_word and rules.has_property(entity.kind, &"YOU"):
			return entity
	return null

func _rule_grid_positions(state: RuleGridState) -> Dictionary:
	var result: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		result[entity.id] = entity.position
	return result

func test_rule_rewriting_starts_on_first_authored_board_and_moves_without_a_gate() -> void:
	var game := _spawn()
	var before: Dictionary = game.save_state()
	assert_eq(before["board_id"], String(RuleLevelLoader.list_level_ids()[0]))
	var you := _first_you(game)
	assert_not_null(you)
	var initial_position := you.position
	var moved := false
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		game.execute_command(&"move", {"direction": direction})
		you = game.call("_find_entity", you.id) as RuleGridEntity
		if you.position != initial_position:
			moved = true
			break
	assert_true(moved, "the first authored board should accept a direct YOU move")
	assert_gt(game.save_state()["turn_index"], 0)

func test_rule_rewriting_undo_and_save_roundtrip_keep_the_physical_board() -> void:
	var game := _spawn()
	var you := _first_you(game)
	assert_not_null(you)
	var you_id := you.id
	var initial_position := you.position
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		game.execute_command(&"move", {"direction": direction})
		you = game.call("_find_entity", you_id) as RuleGridEntity
		if you != null and you.position != initial_position:
			break
	assert_not_null(you)
	assert_ne(you.position, initial_position)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	assert_true(SaveService.is_json_safe(snapshot))
	game.load_state(snapshot)
	var restored_state := RuleGridState.from_dictionary(game.save_state()["grid"])
	assert_eq(_rule_grid_positions(restored_state), _rule_grid_positions(RuleGridState.from_dictionary(snapshot["grid"])))
	assert_eq(int(game.save_state()["turn_index"]), int(snapshot["turn_index"]))
	assert_eq((game.get("_undo_stack") as Array).size(), (snapshot["undo_stack"] as Array).size())
	assert_true(game.execute_command(&"undo"))
	assert_eq(game.save_state()["turn_index"], 0)
	var restored := RuleGridState.from_dictionary(game.save_state()["grid"])
	var restored_you: RuleGridEntity = null
	for entity: RuleGridEntity in restored.entities:
		if entity.id == you_id:
			restored_you = entity
			break
	assert_not_null(restored_you)
	assert_eq(restored_you.position, initial_position)

func test_rule_rewriting_restart_exit_and_disabled_input() -> void:
	var game := _spawn()
	var defaults: Dictionary = game.save_state()
	game.execute_command(&"move", {"direction": Vector2i.RIGHT})
	assert_true(game.execute_command(&"reset"))
	assert_eq(game.save_state()["grid"], defaults["grid"])
	assert_true(game.execute_command(&"cancel"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})
	game.load_state(defaults)
	var before: Dictionary = game.save_state()
	game.context.input_enabled = false
	assert_false(game.execute_command(&"move", {"step": 1}))
	assert_false(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), before)

func test_rule_rewriting_real_input_selects_a_hotbar_slot() -> void:
	var game := _spawn()
	_tap(game, &"rule_rewriting_hotbar_2")
	assert_eq(game.save_state()["hotbar_slot"], 1)
func _spawn_case() -> GameModule:
	var packed := load("res://modules/dedution_casework/entry.tscn") as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = &"dedution_casework"
	injected.input_enabled = true
	for suffix: String in SUFFIXES:
		var action := StringName("dedution_casework_%s" % suffix)
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			_owned_actions.append(action)
		injected.allowed_actions.append(action)
	game.context = injected
	add_child_autofree(game)
	game.load_state({})
	game.enter(injected)
	game.requested.connect(func(kind: StringName, payload: Dictionary) -> void: _requests.append({"kind": kind, "payload": payload.duplicate(true)}))
	return game

func _observe_case(game: GameModule) -> void:
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"confirm"))

func _set_case_timeline(game: GameModule) -> void:
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))

func _set_case_answers(game: GameModule) -> void:
	_set_case_answer_options(game, [1, 1, 1])

func _set_case_answer_options(game: GameModule, targets: Array[int]) -> void:
	var definition := load("res://modules/dedution_casework/content/case_02_clockwork_song.tres") as DeductionCaseDefinition
	var slots: Array[DeductionSlotDefinition] = definition.answer_slots if int(game.save_state()["case_index"]) == 1 else (load("res://modules/dedution_casework/content/case_01_empty_signal.tres") as DeductionCaseDefinition).answer_slots
	for index: int in range(targets.size()):
		var state: Dictionary = game.save_state()
		var focus_steps: int = posmod(index - int(state["focus"]), targets.size())
		for _step: int in range(focus_steps):
			assert_true(game.execute_command(&"move", {"step": 1}))
		state = game.save_state()
		var current: int = int(state["answers"][index])
		var option_count: int = slots[index].options.size()
		var cycle_steps: int = posmod(targets[index] - current, option_count)
		if not bool(state["answer_filled"][index]) and cycle_steps == 0:
			cycle_steps = option_count
		for _step: int in range(cycle_steps):
			assert_true(game.execute_command(&"cycle", {"step": 1}))

func test_dedution_casework_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/dedution_casework/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"dedution_casework")
	assert_eq(manifest.save_version, 3)
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn_case()
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	assert_eq(game.migrate_save(0, {"mode": INF, "inspected": [true, 1], "timeline": [0, INF], "solved": "yes"}), defaults)
	var legacy_v2: Dictionary = defaults.duplicate(true)
	legacy_v2.erase("case_ids")
	for case_state: Dictionary in legacy_v2["case_states"]:
		case_state.erase("answers_by_slot")
		case_state.erase("timeline_event_ids")
	legacy_v2["case_states"][1]["answers"] = [2, 1, 2]
	legacy_v2["case_states"][1]["answer_filled"] = [true, true, true]
	var migrated_v2: Dictionary = game.migrate_save(2, legacy_v2)
	assert_eq(migrated_v2["case_states"][1]["answers"], [2, 1, 2, 0])
	assert_eq(migrated_v2["case_states"][1]["answer_filled"], [true, true, true, false])
	var reordered: Dictionary = defaults.duplicate(true)
	reordered["case_ids"] = ["clockwork_song", "empty_signal"]
	reordered["case_states"] = [defaults["case_states"][1], defaults["case_states"][0]]
	reordered["case_index"] = 1
	assert_eq(game.migrate_save(3, reordered)["case_index"], 0)
	var stable_answer: Dictionary = game.call("_normalize_case_state", {"answers": [0, 0, 0], "answer_filled": [false, false, false], "answers_by_slot": {"culprit": "seoyun"}, "timeline_event_ids": ["signal_moved", "sign_changed", "envelope_hidden"]}, 0)
	assert_eq(stable_answer["answers"][0], 1)
	assert_true(stable_answer["answer_filled"][0])
	assert_eq(stable_answer["timeline"], [2, 0, 1])

func test_dedution_casework_resource_catalog_and_variable_slots() -> void:
	var directory_loaded: Dictionary = DeductionCaseLoader.load_directory("res://modules/dedution_casework/content")
	assert_true(directory_loaded["ok"])
	var loaded: Dictionary = DeductionCaseLoader.load_paths([
		"res://modules/dedution_casework/content/case_01_empty_signal.tres",
		"res://modules/dedution_casework/content/case_02_clockwork_song.tres"
	])
	assert_true(loaded["ok"])
	var cases: Array = loaded["cases"]
	assert_eq(cases[0].answer_slots.size(), 3)
	assert_eq(cases[1].answer_slots.size(), 4)
	assert_true(DeductionCaseLoader.validate_cases([cases[0].duplicate(true)]).is_empty())
	var invalid_case := cases[0].duplicate(true) as DeductionCaseDefinition
	invalid_case.title = ""
	assert_false(DeductionCaseLoader.validate_cases([invalid_case]).is_empty())
	invalid_case.title = "임시 사건"
	invalid_case.scene_names.clear()
	assert_false(DeductionCaseLoader.validate_cases([invalid_case]).is_empty())
	var no_slots := cases[0].duplicate(true) as DeductionCaseDefinition
	no_slots.answer_slots.clear()
	assert_false(DeductionCaseLoader.validate_cases([no_slots]).is_empty())
	var game := _spawn_case()
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_eq(game.save_state()["answers"].size(), 4)
	assert_eq(game.save_state()["answer_filled"], [false, false, false, false])

func test_dedution_casework_reconstructs_order_then_case() -> void:
	var game := _spawn_case()
	_observe_case(game)
	assert_eq(game.save_state()["inspected"], [true, true, true])
	assert_eq(_requests.size(), 3)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["timeline_attempts"], 1)
	_set_case_timeline(game)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["mode"], 2)
	_set_case_answers(game)
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["mode"], 3)
	assert_true(game.execute_command(&"confirm"))
	assert_true(String(_requests[-2]["payload"]["text"]).contains("푸른 가루"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_dedution_casework_restore_keeps_revisable_case() -> void:
	var game := _spawn_case()
	_observe_case(game)
	_set_case_timeline(game)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	game.load_state(snapshot)
	assert_eq(game.save_state()["timeline"], [0, 1, 2])
	assert_true(game.execute_command(&"confirm"))
	_set_case_answers(game)
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["mistakes"], 1)
	assert_false(game.save_state()["solved"])

func test_dedution_casework_keeps_case_files_and_rechecks() -> void:
	var game := _spawn_case()
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_eq(game.save_state()["case_index"], 1)
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"vertical", {"step": -1}))
	assert_true(game.save_state()["rechecked"][0])
	assert_true(game.execute_command(&"cycle", {"step": -1}))
	assert_eq(game.save_state()["case_index"], 0)
	assert_eq(game.save_state()["inspected"], [false, false, false])
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.save_state()["inspected"][0])
	assert_true(game.save_state()["rechecked"][0])

func test_dedution_casework_case_two_requires_recheck_and_supports_contradiction() -> void:
	var game := _spawn_case()
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"vertical", {"step": 1}))
	assert_eq(game.save_state()["mode"], 0)
	assert_true(game.execute_command(&"vertical", {"step": -1}))
	assert_true(game.execute_command(&"vertical", {"step": 1}))
	assert_eq(game.save_state()["mode"], 1)
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": -1}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["mode"], 2)
	_set_case_answer_options(game, [0, 2, 0, 0])
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["validation_status"], "contradiction")
	_set_case_answer_options(game, [1, 1, 1, 1])
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["validation_status"], "solved")

func test_dedution_casework_back_and_disabled_input() -> void:
	var game := _spawn_case()
	assert_true(game.execute_command(&"back"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})
	game.load_state({})
	var before: Dictionary = game.save_state()
	game.context.input_enabled = false
	assert_false(game.execute_command(&"move", {"step": 1}))
	assert_false(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), before)

func _spawn_physics() -> GameModule:
	var packed := load("res://modules/physics_toolbox/entry.tscn") as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = &"physics_toolbox"
	injected.input_enabled = true
	for suffix: String in SUFFIXES:
		var action := StringName("physics_toolbox_%s" % suffix)
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			_owned_actions.append(action)
		injected.allowed_actions.append(action)
	game.context = injected
	add_child_autofree(game)
	game.load_state({})
	game.enter(injected)
	game.requested.connect(func(kind: StringName, payload: Dictionary) -> void: _requests.append({"kind": kind, "payload": payload.duplicate(true)}))
	return game

func _use_physics_solution(game: GameModule) -> void:
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"tool", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"tool", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))

func test_physics_toolbox_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/physics_toolbox/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"physics_toolbox")
	assert_eq(manifest.save_version, 2)
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn_physics()
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	assert_eq(game.migrate_save(0, {"mode": INF, "activated": [true, 1], "assignments": [0, INF], "impulses": [0.0, NAN]}), defaults)

func test_physics_toolbox_applies_three_tools_and_rechecks_mapping() -> void:
	var game := _spawn_physics()
	_use_physics_solution(game)
	assert_eq(game.save_state()["activated"], [true, true, true])
	assert_eq(game.save_state()["assignments"], [0, 1, 2])
	assert_true(game.save_state()["impulses"][0] > 0.0)
	assert_true(game.save_state()["impulses"][2] < 0.0)
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["mode"], 1)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_physics_toolbox_wrong_mapping_can_be_restored_and_corrected() -> void:
	var game := _spawn_physics()
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["mistakes"], 1)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	game.load_state(snapshot)
	assert_eq(game.save_state()["assignments"], [0, 0, 0])
	assert_true(game.execute_command(&"tool", {"step": 1}))
	assert_true(game.execute_command(&"tool", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": -1}))
	assert_true(game.execute_command(&"tool", {"step": -1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])

func test_physics_toolbox_accepts_alternate_route() -> void:
	var game := _spawn_physics()
	assert_true(game.execute_command(&"move", {"step": -1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": -1}))
	assert_true(game.execute_command(&"tool", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": -1}))
	assert_true(game.execute_command(&"tool", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["assignments"], [2, 1, 0])
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["solution_route"], 1)

func test_physics_toolbox_matching_tools_without_goal_stays_incomplete() -> void:
	var game := _spawn_physics()
	_use_physics_solution(game)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	snapshot["positions"] = [{"x": 190.0, "y": 390.0}, {"x": 370.0, "y": 390.0}, {"x": 550.0, "y": 390.0}]
	snapshot["goal_reached"] = false
	game.load_state(snapshot)
	assert_true(game.execute_command(&"confirm"))
	assert_false(game.save_state()["solved"])
	assert_eq(game.save_state()["evaluation_status"], "goal_unreached")

func test_physics_toolbox_back_and_disabled_input() -> void:
	var game := _spawn_physics()
	assert_true(game.execute_command(&"back"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})
	game.load_state({})
	var before: Dictionary = game.save_state()
	game.context.input_enabled = false
	assert_false(game.execute_command(&"confirm"))
	assert_false(game.execute_command(&"tool", {"step": 1}))
	assert_eq(game.save_state(), before)

func _spawn_loop() -> GameModule:
	var packed := load("res://modules/time_loop/entry.tscn") as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = &"time_loop"
	injected.input_enabled = true
	for suffix: String in SUFFIXES:
		var action := StringName("time_loop_%s" % suffix)
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			_owned_actions.append(action)
		injected.allowed_actions.append(action)
	game.context = injected
	add_child_autofree(game)
	game.load_state({})
	game.enter(injected)
	game.requested.connect(func(kind: StringName, payload: Dictionary) -> void: _requests.append({"kind": kind, "payload": payload.duplicate(true)}))
	return game

func _observe_loop(game: GameModule) -> void:
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": 1}))

func _set_loop_route(game: GameModule) -> void:
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))

func _set_alternate_loop_route(game: GameModule) -> void:
	assert_true(game.execute_command(&"cycle", {"step": -1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))

func test_time_loop_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/time_loop/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"time_loop")
	assert_eq(manifest.save_version, 2)
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn_loop()
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	assert_eq(game.migrate_save(0, {"mode": INF, "known": [true, 1], "route": [0, INF], "solved": "yes"}), defaults)

func test_time_loop_persists_observations_through_rewind_and_opens_forward() -> void:
	var game := _spawn_loop()
	_observe_loop(game)
	assert_eq(game.save_state()["known"], [true, true, true])
	assert_eq(_requests.size(), 3)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["resets"], 1)
	assert_eq(game.save_state()["mode"], 1)
	assert_eq(game.save_state()["known"], [true, true, true])
	_set_loop_route(game)
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["mode"], 2)
	assert_true(game.execute_command(&"confirm"))
	assert_true(String(_requests[-2]["payload"]["text"]).contains("창문"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_time_loop_wrong_route_can_be_restored_and_revised() -> void:
	var game := _spawn_loop()
	_observe_loop(game)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	game.load_state(snapshot)
	assert_eq(game.save_state()["known"], [true, true, true])
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["attempts"], 1)
	_set_loop_route(game)
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])

func test_time_loop_revisit_unlocks_alternate_route() -> void:
	var game := _spawn_loop()
	_observe_loop(game)
	assert_true(game.execute_command(&"confirm"))
	_set_alternate_loop_route(game)
	assert_true(game.execute_command(&"confirm"))
	assert_false(game.save_state()["solved"])
	assert_eq(game.save_state()["route_status"], "needs_revisit")
	assert_true(game.execute_command(&"back"))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"cycle", {"step": -1}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["mode"], 1)
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["route_variant"], 1)

func test_time_loop_back_and_disabled_input() -> void:
	var game := _spawn_loop()
	assert_true(game.execute_command(&"back"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})
	game.load_state({})
	var before: Dictionary = game.save_state()
	game.context.input_enabled = false
	assert_false(game.execute_command(&"confirm"))
	assert_false(game.execute_command(&"cycle", {"step": 1}))
	assert_eq(game.save_state(), before)

func test_cycle4_real_input_reaches_each_module_once_per_press() -> void:
	var rule_game := _spawn()
	_tap(rule_game, &"rule_rewriting_hotbar_2")
	assert_eq(rule_game.save_state()["hotbar_slot"], 1)

	var case_game := _spawn_case()
	_tap(case_game, &"dedution_casework_confirm")
	assert_eq(case_game.save_state()["inspected"], [true, false, false])

	var physics_game := _spawn_physics()
	_tap(physics_game, &"physics_toolbox_confirm")
	assert_eq(physics_game.save_state()["uses"], 1)

	var loop_game := _spawn_loop()
	_tap(loop_game, &"time_loop_confirm")
	assert_eq(loop_game.save_state()["known"], [true, false, false])
