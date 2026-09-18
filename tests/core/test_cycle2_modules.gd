extends GutTest

const IDS: Array[StringName] = [&"glyph_gallery", &"switchboard_choir", &"rain_lift", &"borrowed_title", &"glasshouse_return", &"teacup_orbit"]
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
	injected.identity_view = {"shape": 0, "color": 0}
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

func _same_json(left: Variant, right: Variant) -> bool:
	return JSON.stringify(left) == JSON.stringify(right)

func _tap(game: GameModule, action: StringName) -> void:
	Input.action_press(action)
	game.call("_process", 0.1)
	Input.action_release(action)
	game.call("_process", 0.0)

func test_manifests_roundtrip_and_module_contracts() -> void:
	for id: StringName in IDS:
		var manifest := load("res://modules/%s/module_manifest.tres" % id) as ModuleManifest
		assert_eq(manifest.id, id)
		assert_eq(manifest.save_version, 1)
		assert_eq(manifest.input_actions.size(), 6)
		var game := _spawn(id)
		var defaults: Dictionary = game.save_state()
		assert_true(SaveService.is_json_safe(defaults), String(id))
		var decoded: Variant = JSON.parse_string(JSON.stringify(defaults))
		assert_true(decoded is Dictionary)
		game.load_state(decoded)
		assert_true(_same_json(game.save_state(), defaults), String(id))
		assert_true(_same_json(game.migrate_save(0, defaults), defaults), String(id))
		assert_false(game.execute_command(&"unknown"))

func test_gallery_teaches_three_rules_then_opens_forward() -> void:
	var game := _spawn(&"glyph_gallery")
	assert_true(game.execute_command(&"observe"))
	assert_true(String(_requests.back()["payload"]["text"]).contains("아래"))
	assert_true(game.execute_command(&"move", {"direction": "right"}))
	assert_true(game.execute_command(&"observe"))
	assert_true(String(_requests.back()["payload"]["text"]).contains("왼쪽"))
	assert_true(game.execute_command(&"move", {"direction": "right"}))
	assert_true(game.execute_command(&"observe"))
	assert_true(String(_requests[-2]["payload"]["text"]).contains("위"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})
	assert_false(game.save_state()["seen"].has(false))

func test_switchboard_solution_works_from_fresh_state_without_flags() -> void:
	var game := _spawn(&"switchboard_choir")
	assert_eq(game.save_state()["attempts"], 0)
	for value: String in ["down", "left", "up"]:
		assert_true(game.execute_command(&"symbol", {"value": value}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})
	assert_false(game.save_state().has("unlocked"))

func test_switchboard_real_input_is_edge_triggered() -> void:
	var game := _spawn(&"switchboard_choir")
	Input.action_press(&"switchboard_choir_down")
	game.call("_process", 0.1)
	game.call("_process", 0.1)
	assert_eq(game.save_state()["entered"], ["down"])
	Input.action_release(&"switchboard_choir_down")
	game.call("_process", 0.0)
	_tap(game, &"switchboard_choir_left")
	_tap(game, &"switchboard_choir_up")
	_tap(game, &"switchboard_choir_confirm")
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_rain_lift_is_real_3d_and_has_two_local_exits() -> void:
	var game := _spawn(&"rain_lift")
	assert_true(game.get_node("World") is Node3D)
	assert_true(game.get_node("World/Platform") is Node3D)
	assert_true(game.execute_command(&"back"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})
	game = _spawn(&"rain_lift")
	assert_true(game.execute_command(&"move", {"direction": "up"}))
	assert_true(game.execute_command(&"move", {"direction": "up"}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_rain_lift_real_input_moves_one_floor_per_press() -> void:
	var game := _spawn(&"rain_lift")
	Input.action_press(&"rain_lift_up")
	game.call("_process", 0.1)
	game.call("_process", 0.1)
	assert_eq(game.save_state()["floor"], 1)
	Input.action_release(&"rain_lift_up")
	game.call("_process", 0.0)
	_tap(game, &"rain_lift_up")
	_tap(game, &"rain_lift_confirm")
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_borrowed_title_is_walkable_and_leaves_postcard_knowledge() -> void:
	var game := _spawn(&"borrowed_title")
	assert_true(game.execute_command(&"move", {"direction": "right"}))
	assert_true(game.execute_command(&"move", {"direction": "right"}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(String(_requests.back()["payload"]["text"]).contains("○ △ ○"))
	assert_true(game.execute_command(&"move", {"direction": "right"}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_glasshouse_shortcut_works_fresh_by_knowledge_alone() -> void:
	var game := _spawn(&"glasshouse_return")
	assert_false(game.save_state().has("unlocked"))
	for value: String in ["down", "up", "down"]:
		assert_true(game.execute_command(&"symbol", {"value": value}))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "hidden"}})

func test_teacup_orbit_is_short_repeat_without_reward_currency() -> void:
	var game := _spawn(&"teacup_orbit")
	for turn: int in range(7):
		assert_true(game.execute_command(&"turn"))
		assert_eq(game.save_state()["turns"], turn + 1)
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})
	assert_false(game.save_state().has("coins"))
	assert_false(game.save_state().has("reward"))

func test_disabled_modules_reject_commands_without_state_changes() -> void:
	for id: StringName in IDS:
		var game := _spawn(id)
		var before: Dictionary = game.save_state()
		game.context.input_enabled = false
		assert_false(game.execute_command(&"confirm"), String(id))
		assert_false(game.execute_command(&"move", {"direction": "right"}), String(id))
		assert_true(_same_json(game.save_state(), before), String(id))
