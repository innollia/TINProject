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

func _set_solution(game: GameModule) -> void:
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": -1}))

func test_rule_rewriting_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/rule_rewriting/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"rule_rewriting")
	assert_eq(manifest.save_version, 1)
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn()
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	assert_eq(game.migrate_save(0, {"mode": INF, "observed": [true, 1], "rules": [0, INF], "solved": "yes"}), defaults)

func test_rule_rewriting_observes_rewrites_rechecks_and_opens_forward() -> void:
	var game := _spawn()
	_observe_all(game)
	assert_eq(game.save_state()["observed"], [true, true, true])
	assert_eq(_requests.size(), 3)
	_set_solution(game)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["evaluations"], 1)
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["mode"], 2)
	assert_true(game.execute_command(&"confirm"))
	assert_true(String(_requests[-2]["payload"]["text"]).contains("바닥은 밀어내고"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_rule_rewriting_wrong_rule_can_be_reconsidered_after_restore() -> void:
	var game := _spawn()
	_observe_all(game)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["attempts"], 1)
	assert_eq(game.save_state()["evaluations"], 1)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	game.load_state(snapshot)
	assert_eq(game.save_state()["attempts"], 1)
	assert_eq(game.save_state()["evaluations"], 1)
	assert_eq(game.save_state()["rules"], [0, 0])
	_set_solution(game)
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["attempts"], 1)

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
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))
	assert_true(game.execute_command(&"move", {"step": 1}))
	assert_true(game.execute_command(&"cycle", {"step": 1}))

func test_dedution_casework_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/dedution_casework/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"dedution_casework")
	assert_eq(manifest.save_version, 1)
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn_case()
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	assert_eq(game.migrate_save(0, {"mode": INF, "inspected": [true, 1], "timeline": [0, INF], "solved": "yes"}), defaults)

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
	assert_eq(manifest.save_version, 1)
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

func test_time_loop_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/time_loop/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"time_loop")
	assert_eq(manifest.save_version, 1)
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
