extends GutTest

const ACTION_SUFFIXES: Array[String] = ["left", "right", "up", "down", "confirm", "cancel", "inventory", "notes"]

var _owned_actions: Array[StringName] = []
var _requests: Array[Dictionary] = []

func after_each() -> void:
	for action: StringName in _owned_actions:
		Input.action_release(action)
		InputMap.erase_action(action)
	_owned_actions.clear()
	_requests.clear()

func _spawn() -> GameModule:
	var packed := load("res://modules/odd_road_adventure/entry.tscn") as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = &"odd_road_adventure"
	injected.input_enabled = true
	for suffix: String in ACTION_SUFFIXES:
		var action := StringName("odd_road_adventure_%s" % suffix)
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			_owned_actions.append(action)
		injected.allowed_actions.append(action)
	game.context = injected
	add_child_autofree(game)
	game.load_state({})
	game.enter(injected)
	game.requested.connect(func(kind: StringName, payload: Dictionary) -> void:
		_requests.append({"kind": kind, "payload": payload.duplicate(true)})
	)
	return game

func _tap(game: GameModule, action: StringName) -> void:
	Input.action_press(action)
	game.call("_process", 0.1)
	Input.action_release(action)
	game.call("_process", 0.0)

func _confirm(game: GameModule) -> void:
	assert_true(game.execute_command(&"confirm"))

func _pick_bug(game: GameModule) -> void:
	assert_true(game.execute_command(&"select", {"step": 1}))
	_confirm(game)

func _open_needle(game: GameModule) -> void:
	assert_true(game.execute_command(&"travel", {"step": 1}))
	_confirm(game)
	assert_true(game.execute_command(&"inventory"))
	_confirm(game)
	assert_true(game.execute_command(&"inventory"))

func _open_shrine(game: GameModule) -> void:
	assert_true(game.execute_command(&"travel", {"step": 1}))
	_confirm(game)
	assert_true(game.execute_command(&"inventory"))
	_confirm(game)
	assert_true(game.execute_command(&"inventory"))

func test_manifest_state_and_stale_id_migration() -> void:
	var manifest := load("res://modules/odd_road_adventure/module_manifest.tres") as ModuleManifest
	assert_eq(manifest.id, &"odd_road_adventure")
	assert_eq(manifest.save_version, 1)
	assert_eq(manifest.input_actions.size(), 8)
	var game := _spawn()
	var defaults: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(defaults))
	assert_eq(game.migrate_save(0, defaults), defaults)
	var encoded: Variant = JSON.parse_string(JSON.stringify(defaults))
	game.load_state(encoded as Dictionary)
	assert_eq(game.save_state(), defaults)
	var stale := game.migrate_save(0, {
		"current_location": INF,
		"inventory": ["not_an_item", "red_luck_bug"],
		"knowledge": ["not_knowledge"],
		"mode": "inventory",
		"world_flags": {"needle_open": "yes"},
	})
	assert_eq(stale["current_location"], 0)
	assert_eq(stale["inventory"], ["red_luck_bug"])
	assert_eq(stale["knowledge"], [])
	assert_false(stale["world_flags"]["needle_open"])
	assert_true(SaveService.is_json_safe(stale))

func test_same_item_reuse_parallel_events_and_forward() -> void:
	var game := _spawn()
	_pick_bug(game)
	assert_eq(game.save_state()["inventory"], ["red_luck_bug"])
	_open_needle(game)
	assert_true(game.save_state()["event_states"]["needle_open"])
	assert_eq(game.save_state()["used_contexts"], ["needle:hole"])
	_open_shrine(game)
	assert_true(game.save_state()["event_states"]["shrine_fed"])
	assert_eq(game.save_state()["used_contexts"], ["needle:hole", "shrine:altar"])
	assert_eq(game.save_state()["inventory"], ["red_luck_bug"])
	assert_true(game.save_state()["route_states"]["shrine_station"])
	assert_true(game.execute_command(&"travel", {"step": 1}))
	_confirm(game)
	assert_false(game.save_state()["solved"])
	assert_true(game.execute_command(&"travel", {"step": -1}))
	assert_true(game.execute_command(&"travel", {"step": -1}))
	assert_true(game.execute_command(&"select", {"step": 1}))
	_confirm(game)
	assert_eq(game.save_state()["npc_states"]["guide"]["relationship"], "trusted")
	assert_true(game.save_state()["knowledge"].has("station_rule"))
	assert_true(game.execute_command(&"travel", {"step": 1}))
	assert_true(game.execute_command(&"travel", {"step": 1}))
	_confirm(game)
	assert_true(game.save_state()["solved"])
	assert_eq(game.save_state()["mode"], 3)
	_confirm(game)
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func test_npc_reappears_and_location_state_is_persistent() -> void:
	var game := _spawn()
	assert_true(game.execute_command(&"select", {"step": 1}))
	assert_true(game.execute_command(&"select", {"step": 1}))
	_confirm(game)
	assert_true(game.save_state()["location_states"]["village"]["seen"].has("guide"))
	assert_true(game.execute_command(&"travel", {"step": 1}))
	assert_true(game.execute_command(&"select", {"step": 1}))
	_confirm(game)
	assert_true(game.save_state()["location_states"]["needle"]["seen"].has("guide"))
	assert_eq(game.save_state()["npc_states"]["guide"]["visits"], 2)
	assert_eq(game.save_state()["npc_states"]["guide"]["location"], "needle")
	assert_eq(game.save_state()["npc_states"]["guide"]["relationship"], "trusted")

func test_reset_back_unknown_and_disabled_input() -> void:
	var game := _spawn()
	_pick_bug(game)
	var progressed: Dictionary = game.save_state()
	assert_false(progressed["inventory"].is_empty())
	assert_false(game.execute_command(&"unknown"))
	assert_eq(game.save_state(), progressed)
	game.context.input_enabled = false
	assert_false(game.execute_command(&"confirm"))
	assert_eq(game.save_state(), progressed)
	game.context.input_enabled = true
	assert_true(game.execute_command(&"reset"))
	assert_eq(game.save_state()["inventory"], [])
	assert_eq(game.save_state()["current_location"], 0)
	assert_true(game.execute_command(&"back"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "back"}})

func test_real_input_edge_triggers_shared_contract() -> void:
	var game := _spawn()
	_tap(game, &"odd_road_adventure_right")
	assert_eq(game.save_state()["focus"], 1)
	_tap(game, &"odd_road_adventure_inventory")
	assert_eq(game.save_state()["mode"], 1)
	_tap(game, &"odd_road_adventure_inventory")
	assert_eq(game.save_state()["mode"], 0)
	game.context.input_enabled = false
	_tap(game, &"odd_road_adventure_right")
	assert_eq(game.save_state()["focus"], 1)
