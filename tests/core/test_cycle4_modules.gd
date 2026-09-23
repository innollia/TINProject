extends GutTest

const SUFFIXES: Array[String] = ["left", "right", "up", "down", "confirm", "cancel"]

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
	for suffix: String in SUFFIXES:
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

func _observe_all(game: GameModule) -> void:
	assert_true(game.execute_command(&"move", {"step": -1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": -1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"move", {"step": -1}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.execute_command(&"confirm"))

func _load_crossing(game: GameModule) -> Dictionary:
	var level := RuleLevelLoader.load_level(&"crossing_02")
	assert_true(level["ok"])
	var state: Dictionary = game.save_state()
	state["active_level_id"] = "crossing_02"
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	state["mode"] = 1
	state["observed"] = [true, true, true]
	state["solved"] = false
	state["failed"] = false
	state["undo_stack"] = []
	game.load_state(state)
	return game.save_state()

func _move_saved_entity(grid: Dictionary, entity_id: String, cell: Vector2i) -> void:
	for entity: Dictionary in grid["entities"]:
		if entity["id"] == entity_id:
			entity["x"] = cell.x
			entity["y"] = cell.y
			return

func _face_saved_entity(grid: Dictionary, entity_id: String, direction: Vector2i) -> void:
	for entity: Dictionary in grid["entities"]:
		if entity["id"] == entity_id:
			entity["facing_x"] = direction.x
			entity["facing_y"] = direction.y
			return

func _entity_value(grid: Dictionary, entity_id: String, key: String) -> Variant:
	for entity: Dictionary in grid["entities"]:
		if entity["id"] == entity_id:
			return entity.get(key)
	return null

func _canonicalize_json_numbers(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		for key: Variant in value:
			result[key] = _canonicalize_json_numbers(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_canonicalize_json_numbers(item))
		return result
	if value is float and is_finite(value) and float(value) == floorf(float(value)):
		return int(value)
	return value

func test_rule_rewriting_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/rule_rewriting/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"rule_rewriting")
	assert_eq(manifest.save_version, 4)
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn()
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(defaults["state_format"], 4)
	assert_eq(defaults["active_level_id"], "signal_room_01")
	assert_eq(game.migrate_save(4, defaults), defaults)
	assert_eq(game.migrate_save(3, defaults), game.migrate_save(0, {}))
	assert_eq(game.migrate_save(2, {"mode": 3, "solved": true, "player_position": 6}), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	game.load_state({"state_format": 4, "mode": INF, "observed": [true, 1], "solved": "yes"})
	assert_eq(game.save_state(), defaults)
	game.load_state({"state_format": 3, "mode": 3, "solved": true})
	assert_eq(game.save_state(), defaults)

func test_rule_rewriting_observes_grid_rules_and_opens_forward_on_win() -> void:
	var game := _spawn()
	_observe_all(game)
	assert_eq(game.save_state()["observed"], [true, true, true])
	assert_eq(_requests.size(), 3)
	assert_eq(game.save_state()["mode"], 1)
	var rules: RuleSet = game.get("rule_set")
	assert_true(rules.has_property(&"BABA", &"YOU"))
	assert_true(rules.has_property(&"ROCK", &"PUSH"))
	assert_true(rules.has_property(&"WALL", &"STOP"))
	assert_true(rules.has_property(&"FLAG", &"WIN"))
	for _step: int in range(6):
		assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["mode"], 2)
	assert_true(game.execute_command(&"confirm"))
	assert_true(String(_requests[-2]["payload"]["text"]).contains("깃발의 WIN"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_rule_rewriting_word_moves_reparse_rules_and_undo_restores_control() -> void:
	var game := _spawn()
	_observe_all(game)
	var initial: Dictionary = game.save_state()
	var grid: Dictionary = initial["grid"]
	_move_saved_entity(grid, "baba", Vector2i(6, 5))
	initial["grid"] = grid
	game.load_state(initial)
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	grid = game.save_state()["grid"]
	assert_eq(_position_of(grid, "baba"), Vector2i(6, 4))
	assert_eq(_position_of(grid, "word_flag"), Vector2i(6, 3))
	assert_eq(_position_of(grid, "word_baba"), Vector2i(1, 1))
	var rules: RuleSet = game.get("rule_set")
	assert_false(rules.has_property(&"FLAG", &"WIN"))
	assert_false(game.save_state()["failed"])
	assert_eq(game.save_state()["mode"], 1)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	assert_true(game.execute_command(&"undo"))
	rules = game.get("rule_set")
	assert_true(rules.has_property(&"FLAG", &"WIN"))
	assert_eq(game.save_state()["board_turns"], 0)
	game.load_state(snapshot)
	rules = game.get("rule_set")
	assert_false(rules.has_property(&"FLAG", &"WIN"))
	assert_true(game.execute_command(&"undo"))
	rules = game.get("rule_set")
	assert_true(rules.has_property(&"FLAG", &"WIN"))

func _position_of(grid: Dictionary, entity_id: String) -> Vector2i:
	for entity: Dictionary in grid["entities"]:
		if entity["id"] == entity_id:
			return Vector2i(int(entity["x"]), int(entity["y"]))
	return Vector2i(-1, -1)

func test_rule_rewriting_save_roundtrip_keeps_grid_and_undo() -> void:
	var game := _spawn()
	_observe_all(game)
	assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	var mid_board: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	assert_true(game.execute_command(&"undo"))
	assert_eq(_position_of(game.save_state()["grid"], "baba"), Vector2i(2, 6))
	game.load_state(mid_board)
	assert_eq(_position_of(game.save_state()["grid"], "baba"), Vector2i(3, 6))
	assert_eq(game.save_state()["undo_stack"].size(), 2)
	var restored: Dictionary = _canonicalize_json_numbers(game.save_state())
	var expected: Dictionary = _canonicalize_json_numbers(mid_board)
	assert_eq(restored, expected)
	var damaged_history: Dictionary = mid_board.duplicate(true)
	damaged_history["undo_stack"][0]["grid"]["entities"][0]["kind"] = "UNAUTHORED"
	game.load_state(damaged_history)
	assert_eq(_position_of(game.save_state()["grid"], "baba"), Vector2i(3, 6))
	assert_eq(game.save_state()["undo_stack"].size(), 1)
	assert_true(game.execute_command(&"undo"))
	assert_eq(_position_of(game.save_state()["grid"], "baba"), Vector2i(2, 6))
	var damaged_grid: Dictionary = mid_board.duplicate(true)
	damaged_grid["active_level_id"] = "unknown_level"
	game.load_state(damaged_grid)
	assert_eq(game.save_state()["active_level_id"], "signal_room_01")
	assert_eq(game.save_state()["grid"], game.migrate_save(0, {})["grid"])

func test_rule_rewriting_back_and_disabled_input() -> void:
	var game := _spawn()
	assert_true(game.execute_command(&"back"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})
	game.load_state({})
	var before: Dictionary = game.save_state()
	game.context.input_enabled = false
	assert_false(game.execute_command(&"move", {"step": 1}))
	assert_false(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), before)

func test_rule_rewriting_crossing_transforms_moves_and_roundtrips_dynamic_state() -> void:
	var game := _spawn()
	var state := _load_crossing(game)
	var grid: Dictionary = state["grid"]
	_move_saved_entity(grid, "baba", Vector2i(3, 5))
	_face_saved_entity(grid, "wall", Vector2i.UP)
	_face_saved_entity(grid, "rock", Vector2i.DOWN)
	state["grid"] = grid
	game.load_state(state)
	var rules: RuleSet = game.get("rule_set")
	assert_eq(rules.transforms_for(&"LAMP"), [&"ROCK"])
	assert_true(rules.has_property(&"LAMP", &"PUSH"))
	assert_true(rules.has_property(&"ROCK", &"MOVE"))
	assert_true(rules.has_property(&"FLAG", &"WIN"))
	assert_true(rules.has_property(&"FLAG", &"DEFEAT"))

	assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	var transformed: Dictionary = game.save_state()
	grid = transformed["grid"]
	assert_eq(_entity_value(grid, "wall", "kind"), "ROCK")
	assert_eq(_position_of(grid, "wall"), Vector2i(6, 5))
	assert_eq(_position_of(grid, "rock"), Vector2i(7, 5))
	assert_eq(_position_of(grid, "baba"), Vector2i(4, 5))
	assert_eq(_entity_value(grid, "wall", "facing_x"), 1)
	assert_eq(_entity_value(grid, "wall", "facing_y"), 0)
	assert_eq(_entity_value(grid, "rock", "facing_x"), 1)
	assert_eq(_position_of(grid, "word_lamp"), Vector2i(1, 4))
	assert_true(SaveService.is_json_safe(transformed))

	var roundtrip: Dictionary = JSON.parse_string(JSON.stringify(transformed))
	game.load_state(roundtrip)
	assert_eq(_entity_value(game.save_state()["grid"], "wall", "kind"), "ROCK")
	assert_eq(_entity_value(game.save_state()["grid"], "wall", "facing_x"), 1)
	assert_true(game.execute_command(&"undo"))
	grid = game.save_state()["grid"]
	assert_eq(_entity_value(grid, "wall", "kind"), "LAMP")
	assert_eq(_position_of(grid, "wall"), Vector2i(4, 5))
	assert_eq(_position_of(grid, "rock"), Vector2i(5, 5))
	assert_eq(_entity_value(grid, "wall", "facing_x"), 0)
	assert_eq(_entity_value(grid, "wall", "facing_y"), -1)
	assert_eq(_entity_value(grid, "rock", "facing_x"), 0)
	assert_eq(_entity_value(grid, "rock", "facing_y"), 1)

func test_rule_rewriting_defeat_precedes_win_and_undo_restores_actor() -> void:
	var game := _spawn()
	var state := _load_crossing(game)
	var grid: Dictionary = state["grid"]
	_move_saved_entity(grid, "flag", Vector2i(2, 6))
	state["grid"] = grid
	game.load_state(state)
	assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	assert_eq(game.save_state()["mode"], 3)
	assert_true(game.save_state()["failed"])
	assert_false(game.save_state()["solved"])
	assert_eq(_position_of(game.save_state()["grid"], "baba"), Vector2i(-1, -1))
	assert_true(game.execute_command(&"undo"))
	assert_eq(game.save_state()["mode"], 1)
	assert_false(game.save_state()["failed"])
	assert_eq(_position_of(game.save_state()["grid"], "baba"), Vector2i(1, 6))
	assert_eq(_position_of(game.save_state()["grid"], "flag"), Vector2i(2, 6))

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
	_tap(rule_game, &"rule_rewriting_right")
	assert_eq(rule_game.save_state()["focus"], 1)

	var case_game := _spawn_case()
	_tap(case_game, &"dedution_casework_confirm")
	assert_eq(case_game.save_state()["inspected"], [true, false, false])

	var physics_game := _spawn_physics()
	_tap(physics_game, &"physics_toolbox_confirm")
	assert_eq(physics_game.save_state()["uses"], 1)

	var loop_game := _spawn_loop()
	_tap(loop_game, &"time_loop_confirm")
	assert_eq(loop_game.save_state()["known"], [true, false, false])
