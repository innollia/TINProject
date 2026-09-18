extends GutTest

const IDS: Array[StringName] = [&"signal_desk", &"relay_quay", &"last_echo", &"return_cradle", &"maintenance_cut"]
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
	var packed: PackedScene = load("res://modules/%s/entry.tscn" % id) as PackedScene
	var instance: GameModule = packed.instantiate() as GameModule
	var injected: ModuleContext = ModuleContext.new()
	injected.module_id = id
	injected.identity_view = {"shape": 2, "color": 1}
	for suffix: String in SUFFIXES:
		var action: StringName = StringName("%s_%s" % [id, suffix])
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			_owned_actions.append(action)
		injected.allowed_actions.append(action)
	instance.context = injected
	add_child_autofree(instance)
	instance.load_state({})
	instance.enter(injected)
	injected.input_enabled = true
	instance.requested.connect(_on_request)
	return instance

func _on_request(kind: StringName, payload: Dictionary) -> void:
	_requests.append({"kind": kind, "payload": payload.duplicate(true)})

func _terminal_count() -> int:
	var count: int = 0
	for item: Dictionary in _requests:
		if item["kind"] in [&"portal", &"died"]:
			count += 1
	return count

func _inherit_tree(node: Node) -> void:
	for child: Node in node.get_children():
		assert_eq(child.process_mode, Node.PROCESS_MODE_INHERIT, child.name)
		_inherit_tree(child)

func _same_json(left: Variant, right: Variant) -> bool:
	if (left is int or left is float) and (right is int or right is float):
		return is_equal_approx(float(left), float(right))
	if left is Dictionary and right is Dictionary:
		if left.size() != right.size():
			return false
		for key: Variant in left:
			if not right.has(key) or not _same_json(left[key], right[key]):
				return false
		return true
	return left == right

func test_all_five_manifests_state_roundtrip_migration_and_owned_children() -> void:
	for id: StringName in IDS:
		var manifest: ModuleManifest = load("res://modules/%s/module_manifest.tres" % id) as ModuleManifest
		assert_eq(manifest.id, id)
		assert_eq(manifest.save_version, 1)
		assert_eq(manifest.input_actions.size(), 6)
		var game: GameModule = _spawn(id)
		var defaults: Dictionary = game.save_state()
		assert_true(SaveService.is_json_safe(defaults))
		var normalized: Dictionary = game.migrate_save(0, defaults)
		assert_true(_same_json(normalized, defaults))
		var decoded: Dictionary = JSON.parse_string(JSON.stringify(defaults))
		game.load_state(decoded)
		assert_true(_same_json(game.save_state(), defaults))
		assert_false(game.execute_command(&"unrecognized", {"value": 9}))
		assert_true(_same_json(game.save_state(), defaults))
		game.load_state({})
		assert_true(_same_json(game.save_state(), defaults))
		_inherit_tree(game)
		var context_before: ModuleContext = game.context
		game.exit()
		assert_null(game.context)
		assert_false(context_before.input_enabled)

func test_input_disabled_blocks_commands_and_direct_callbacks() -> void:
	for id: StringName in IDS:
		var game: GameModule = _spawn(id)
		var before: Dictionary = game.save_state()
		game.context.input_enabled = false
		for command: StringName in [&"confirm", &"inspect", &"reset", &"read_notice", &"pickup", &"deliver", &"toggle_light"]:
			assert_false(game.execute_command(command))
		assert_false(game.execute_command(&"move", {"direction": "right", "x": 1.0, "z": 0.0}))
		assert_false(game.execute_command(&"tune", {"frequency": 90, "direction": "left"}))
		if id == &"last_echo":
			game.call("_observe")
		elif id == &"return_cradle":
			game.call("_observe", true)
		elif id in [&"relay_quay", &"maintenance_cut"]:
			game.call("_interact")
			game.call("_request_portal", "back")
		game.call("_process", 0.1)
		assert_true(_same_json(game.save_state(), before))
		assert_eq(_requests.size(), 0)

func test_real_input_changes_only_enabled_game() -> void:
	for id: StringName in IDS:
		var game: GameModule = _spawn(id)
		var before: Dictionary = game.save_state()
		var action: StringName = StringName("%s_right" % id)
		Input.action_press(action)
		game.call("_process", 0.1)
		Input.action_release(action)
		game.call("_process", 0.0)
		assert_false(_same_json(game.save_state(), before), String(id))
		before = game.save_state()
		game.context.input_enabled = false
		Input.action_press(action)
		game.call("_process", 0.1)
		Input.action_release(action)
		assert_true(_same_json(game.save_state(), before))

func test_hidden_routes_work_from_fresh_state_without_observations() -> void:
	for id: StringName in [&"signal_desk", &"return_cradle"]:
		_requests.clear()
		var game: GameModule = _spawn(id)
		watch_signals(game)
		assert_true(game.execute_command(&"tune", {"frequency": 90}))
		assert_true(game.execute_command(&"move", {"direction": "left"}))
		assert_eq(game.save_state()["inspections"], 0)
		assert_eq(_requests.size(), 0)
		assert_true(game.execute_command(&"confirm"))
		assert_eq(_requests, [{"kind": &"portal", "payload": {"exit": "hidden"}}])
		assert_false(game.execute_command(&"confirm"))
		assert_signal_not_emitted(game, "finished")

func test_desk_routes_have_only_registered_exits() -> void:
	var game: GameModule = _spawn(&"signal_desk")
	assert_true(game.execute_command(&"tune", {"frequency": 110}))
	assert_true(game.execute_command(&"move", {"direction": "right"}))
	for delivery: int in range(4):
		assert_true(game.execute_command(&"confirm"))
		assert_eq(game.save_state()["deliveries"], delivery + 1)
		assert_true(String(_requests.back()["payload"]["text"]).contains("%d번째" % (delivery + 1)))
	assert_eq(_requests[0]["payload"]["id"], _requests[3]["payload"]["id"])
	assert_eq(_terminal_count(), 0)
	assert_true(game.execute_command(&"inspect"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "side"}})
	assert_false(game.execute_command(&"inspect"))
	_requests.clear()
	game = _spawn(&"signal_desk")
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests, [{"kind": &"portal", "payload": {"exit": "forward"}}])

func test_menu_is_walkable_and_pit_requires_deliberate_confirm() -> void:
	var game: GameModule = _spawn(&"last_echo")
	watch_signals(game)
	var identity: Dictionary = game.context.identity_view.duplicate(true)
	var body: Polygon2D = game.get("_body") as Polygon2D
	assert_true(body.visible)
	assert_true(body.has_node("TiedTail"))
	assert_eq((body.get_node("HairTop") as Polygon2D).color, Color("ddd4bf"))
	for step: int in range(4):
		assert_true(game.execute_command(&"move", {"direction": "right"}))
		game.call("_process", 0.1)
		assert_eq(_terminal_count(), 0)
	assert_eq(game.save_state()["spot"], 4)
	for frame: int in range(12):
		game.call("_process", 1.0)
	assert_eq(_terminal_count(), 0)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests, [{"kind": &"died", "payload": {}}])
	assert_false(game.execute_command(&"confirm"))
	assert_eq(game.get("_body"), body)
	assert_eq(game.context.identity_view, identity)
	assert_signal_not_emitted(game, "finished")

func test_friend_and_shortcut_clues_are_observed_without_unlocks() -> void:
	var game: GameModule = _spawn(&"last_echo")
	assert_true(game.execute_command(&"move", {"direction": "right"}))
	assert_true(game.execute_command(&"inspect"))
	assert_true(String(_requests.back()["payload"]["text"]).contains("준호"))
	assert_true(game.execute_command(&"move", {"direction": "right"}))
	assert_true(game.execute_command(&"inspect"))
	assert_true(String(_requests.back()["payload"]["text"]).contains("90"))
	assert_eq(_terminal_count(), 0)
	var anchor: GameModule = _spawn(&"return_cradle")
	var friend_lines: Array[String] = []
	for visit: int in range(4):
		assert_true(anchor.execute_command(&"confirm"))
		friend_lines.append(String(_requests.back()["payload"]["text"]))
		assert_true(friend_lines.back().contains("준호"))
		assert_eq(anchor.save_state()["friend_visits"], visit + 1)
	assert_ne(friend_lines[0], friend_lines[1])
	assert_ne(friend_lines[1], friend_lines[2])
	assert_eq(friend_lines[0], friend_lines[3])
	assert_true(anchor.execute_command(&"move", {"direction": "right"}))
	assert_true(anchor.execute_command(&"confirm"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})

func _walk(game: GameModule, x: float, z: float, count: int) -> void:
	for step: int in range(count):
		assert_true(game.execute_command(&"move", {"x": x, "z": z}))

func test_courtyard_delivery_and_rule_open_real_3d_passage_without_reading() -> void:
	var game: GameModule = _spawn(&"relay_quay")
	assert_true(game.get_node("World") is Node3D)
	assert_true(game.get_node("World/Camera3D") is Camera3D)
	assert_false(game.save_state().has("rule_read"))
	assert_false(game.execute_command(&"portal", {"exit": "forward"}))
	_walk(game, 1.0, 0.0, 3)
	_walk(game, 0.0, -1.0, 2)
	assert_true(game.execute_command(&"pickup"))
	_walk(game, -1.0, 0.0, 6)
	_walk(game, 0.0, -1.0, 4)
	assert_true(game.execute_command(&"deliver"))
	_walk(game, 1.0, 0.0, 5)
	assert_true(game.execute_command(&"tune", {"frequency": 90, "direction": "left"}))
	assert_true(game.execute_command(&"confirm"))
	assert_true(game.save_state()["passage_open"])
	_walk(game, -1.0, 0.0, 2)
	_walk(game, 0.0, -1.0, 3)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests.back(), {"kind": &"portal", "payload": {"exit": "forward"}})
	for item: Dictionary in _requests:
		assert_ne(item["payload"].get("id", ""), "quay_relay_rule")

func test_courtyard_local_learning_and_viewpoint_are_available() -> void:
	var game: GameModule = _spawn(&"relay_quay")
	var camera: Camera3D = game.get_node("World/Camera3D") as Camera3D
	var before: Vector3 = camera.position
	assert_true(game.execute_command(&"look", {"yaw": 0.5}))
	assert_ne(camera.position, before)
	_walk(game, -1.0, 0.0, 3)
	_walk(game, 0.0, -1.0, 2)
	assert_true(game.execute_command(&"read_notice"))
	assert_true(String(_requests.back()["payload"]["text"]).contains("90"))
	assert_false(game.save_state()["passage_open"])

func test_maintenance_is_real_3d_shortcut_without_inspection_gate() -> void:
	var game: GameModule = _spawn(&"maintenance_cut")
	assert_true(game.get_node("World") is Node3D)
	assert_true(game.get_node("World/Walker") is Node3D)
	var body: Node = game.get_node("World/Walker")
	_walk(game, 0.0, -1.0, 10)
	assert_false(game.save_state().has("inspected"))
	assert_true(game.execute_command(&"confirm"))
	assert_eq(_requests, [{"kind": &"portal", "payload": {"exit": "forward"}}])
	assert_eq(game.get_node("World/Walker"), body)

func test_malformed_local_state_is_normalized_and_migration_is_pure() -> void:
	var malformed: Dictionary = {"frequency": NAN, "station": INF, "berth": "bad", "spot": [], "inspections": {}, "friend_visits": -4, "position": {"x": INF, "z": "bad"}, "yaw": NAN, "delivered": "yes", "has_parcel": 1, "passage_open": true, "inspected": 1, "light_on": []}
	for id: StringName in IDS:
		var script: Script = load("res://modules/%s/module.gd" % id) as Script
		var unentered: GameModule = script.new() as GameModule
		var clean: Dictionary = unentered.migrate_save(0, malformed)
		assert_true(SaveService.is_json_safe(clean))
		unentered.load_state(clean)
		assert_true(_same_json(unentered.save_state(), clean))
		unentered.free()
		var game: GameModule = _spawn(id)
		game.load_state(malformed)
		assert_true(SaveService.is_json_safe(game.save_state()))
		var detached: Dictionary = game.save_state()
		if detached.has("position"):
			detached["position"]["x"] = 999
			assert_ne(float(game.save_state()["position"]["x"]), 999.0)
		assert_false(game.execute_command(&"move", {"direction": "unknown", "x": NAN, "z": 0}))
