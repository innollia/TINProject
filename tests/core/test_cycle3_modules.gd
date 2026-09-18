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

func _spawn(id: StringName) -> GameModule:
	var packed := load("res://modules/%s/entry.tscn" % id) as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = id
	injected.input_enabled = true
	for suffix: String in SUFFIXES:
		var action := StringName("%s_%s" % [id, suffix])
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

func _tap(game: GameModule, action: StringName) -> void:
	Input.action_press(action)
	game.call("_process", 0.1)
	Input.action_release(action)
	game.call("_process", 0.0)

func test_numberless_clock_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/numberless_clock/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"numberless_clock")
	assert_eq(manifest.save_version, 1)
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn(&"numberless_clock")
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	assert_eq(game.migrate_save(0, {"hands": ["down", 3], "failures": INF}), defaults)

func test_old_gallery_knowledge_opens_clock_without_unlock_flag() -> void:
	var game := _spawn(&"numberless_clock")
	assert_false(game.save_state().has("unlocked"))
	for direction: String in ["down", "left", "up"]:
		assert_true(game.execute_command(&"hand", {"direction": direction}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(String(_requests[-2]["payload"]["text"]).contains("아래·왼쪽·위"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_wrong_clock_answer_resets_locally_and_persists_failures() -> void:
	var game := _spawn(&"numberless_clock")
	for direction: String in ["up", "up", "up"]:
		assert_true(game.execute_command(&"hand", {"direction": direction}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), {"hands": [], "failures": 1})
	assert_eq(_requests.size(), 0)

func test_clock_real_input_is_edge_triggered() -> void:
	var game := _spawn(&"numberless_clock")
	Input.action_press(&"numberless_clock_down")
	game.call("_process", 0.1)
	game.call("_process", 0.1)
	assert_eq(game.save_state()["hands"], ["down"])
	Input.action_release(&"numberless_clock_down")
	game.call("_process", 0.0)
	_tap(game, &"numberless_clock_left")
	_tap(game, &"numberless_clock_up")
	_tap(game, &"numberless_clock_confirm")
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_teacup_side_route_requires_three_turns() -> void:
	var game := _spawn(&"teacup_orbit")
	assert_false(game.execute_command(&"side"))
	for turn: int in range(3): assert_true(game.execute_command(&"turn"))
	assert_true(game.execute_command(&"side"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "side"}})

func test_disabled_clock_rejects_all_changes() -> void:
	var game := _spawn(&"numberless_clock")
	game.context.input_enabled = false
	assert_false(game.execute_command(&"hand", {"direction": "down"}))
	assert_false(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), {"hands": [], "failures": 0})

func test_clock_empty_cancel_opens_shadow_ferry_side_route() -> void:
	var game := _spawn(&"numberless_clock")
	assert_true(game.execute_command(&"side"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "side"}})

func test_shadow_ferry_manifest_state_and_real_3d() -> void:
	var manifest := load("res://modules/shadow_ferry/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"shadow_ferry")
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn(&"shadow_ferry")
	assert_not_null(game.get_node_or_null("World") as Node3D)
	assert_not_null(game.find_child("Boat", true, false) as Node3D)
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)

func test_shadow_ferry_longest_shadow_crosses_without_timing() -> void:
	var game := _spawn(&"shadow_ferry")
	assert_true(game.execute_command(&"cross"))
	assert_eq(game.save_state(), {"dock": 1, "crossings": 1})
	assert_true(String(_requests[-2]["payload"]["text"]).contains("가장 긴 그림자"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_shadow_ferry_wrong_dock_and_disabled_input_are_local() -> void:
	var game := _spawn(&"shadow_ferry")
	assert_true(game.execute_command(&"move", {"step": -1}))
	assert_true(game.execute_command(&"cross"))
	assert_eq(game.save_state(), {"dock": 0, "crossings": 1})
	assert_eq(_requests.size(), 0)
	game.context.input_enabled = false
	assert_false(game.execute_command(&"move", {"step": 1}))
	assert_false(game.execute_command(&"back"))
	assert_eq(game.save_state(), {"dock": 0, "crossings": 1})

func test_receipt_orchard_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/receipt_orchard/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"receipt_orchard")
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn(&"receipt_orchard")
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	assert_eq(game.migrate_save(0, {"fruits": [INF], "selected": -9}), defaults)

func test_receipt_orchard_order_opens_forward() -> void:
	var game := _spawn(&"receipt_orchard")
	assert_true(game.execute_command(&"change", {"step": 1}))
	assert_true(game.execute_command(&"select", {"step": 1}))
	assert_true(game.execute_command(&"change", {"step": 1}))
	assert_true(game.execute_command(&"select", {"step": 1}))
	assert_true(game.execute_command(&"change", {"step": 1}))
	assert_eq(game.save_state()["fruits"], [0, 1, 2])
	assert_true(game.execute_command(&"confirm"))
	assert_true(String(_requests[-2]["payload"]["text"]).contains("비·차·달"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_receipt_orchard_wrong_order_back_and_disabled_input() -> void:
	var game := _spawn(&"receipt_orchard")
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["failures"], 1)
	assert_eq(_requests.size(), 0)
	assert_true(game.execute_command(&"back"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})
	game.load_state({})
	game.context.input_enabled = false
	assert_false(game.execute_command(&"change", {"step": 1}))
	assert_eq(game.save_state(), {"fruits": [2, 0, 1], "selected": 0, "failures": 0})

func test_wrong_weather_manifest_state_and_migration() -> void:
	var manifest := load("res://modules/wrong_weather/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"wrong_weather")
	assert_eq(manifest.input_actions.size(), 6)
	var game := _spawn(&"wrong_weather")
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	game.load_state(JSON.parse_string(JSON.stringify(defaults)))
	assert_eq(game.save_state(), defaults)
	assert_eq(game.migrate_save(0, {"selected": INF, "reports": -3}), defaults)

func test_wrong_weather_reports_visible_upward_rain() -> void:
	var game := _spawn(&"wrong_weather")
	assert_true(game.execute_command(&"select", {"step": 1}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), {"selected": 1, "reports": 1})
	assert_true(String(_requests[-2]["payload"]["text"]).contains("천장으로 오르는 비"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_wrong_weather_wrong_report_back_and_disabled_input() -> void:
	var game := _spawn(&"wrong_weather")
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), {"selected": 0, "reports": 1})
	assert_eq(_requests.size(), 0)
	assert_true(game.execute_command(&"back"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})
	game.load_state({})
	game.context.input_enabled = false
	assert_false(game.execute_command(&"select", {"step": 1}))
	assert_false(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), {"selected": 0, "reports": 0})
