extends GutTest

const ACTION_SUFFIXES: Array[String] = [
	"left", "right", "up", "down", "confirm", "cancel", "undo", "reset", "forward",
	"turn_left", "turn_right", "cycle_3d_subject", "open_inventory", "cycle_metrix", "place",
	"hotbar_1", "hotbar_2", "hotbar_3", "hotbar_4", "hotbar_5", "hotbar_6", "hotbar_7", "hotbar_8", "hotbar_9"
]

var _owned_actions: Array[StringName] = []


func after_each() -> void:
	for action: StringName in _owned_actions:
		Input.action_release(action)
		InputMap.erase_action(action)
	_owned_actions.clear()


func _spawn() -> GameModule:
	var packed := load("res://modules/rule_rewriting/entry.tscn") as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = &"rule_rewriting"
	injected.input_enabled = true
	for suffix: String in ACTION_SUFFIXES:
		var action := StringName("rule_rewriting_%s" % suffix)
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			_owned_actions.append(action)
		injected.allowed_actions.append(action)
	game.context = injected
	add_child_autofree(game)
	game.load_state({})
	game.enter(injected)
	return game


func _first_you(game: GameModule) -> RuleGridEntity:
	var state := game.get("grid_state") as RuleGridState
	var rules := game.get("rule_set") as RuleSet
	for entity: RuleGridEntity in state.entities:
		if not entity.is_word and rules.has_property(entity.kind, &"YOU"):
			return entity
	return null


func _entity_positions(state: RuleGridState) -> Dictionary:
	var positions: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		positions[entity.id] = entity.position
	return positions


func test_default_board_comes_from_content_index_and_save_is_json_safe() -> void:
	var game := _spawn()
	var state: Dictionary = game.save_state()
	assert_eq(state["board_id"], String(RuleLevelLoader.list_level_ids()[0]))
	assert_eq(state["state_format"], 5)
	assert_true(SaveService.is_json_safe(state))
	assert_false(state.has("observed"))
	assert_false(state.has("mode"))
	assert_eq(game.migrate_save(4, {"state_format": 4}), game.migrate_save(0, {}))
	game.load_state(JSON.parse_string(JSON.stringify(state)))
	assert_eq(game.save_state(), state)


func test_malformed_or_unknown_state_recovers_to_first_authored_board() -> void:
	var game := _spawn()
	var expected: Dictionary = game.save_state()
	game.load_state({"state_format": 5, "board_id": "does_not_exist", "grid": {"bad": INF}, "turn_index": INF})
	assert_eq(game.save_state(), expected)
	game.load_state({"state_format": 5, "board_id": String(expected["board_id"]), "grid": {"schema_version": 1, "width": 999, "height": 1, "entities": []}})
	assert_eq(game.save_state()["grid"], expected["grid"])


func test_first_authored_board_accepts_a_move_and_undo_restores_it() -> void:
	var game := _spawn()
	var actor := _first_you(game)
	assert_not_null(actor)
	var actor_id := actor.id
	var initial_cell := actor.position
	var moved := false
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		game.execute_command(&"move", {"direction": direction})
		actor = game.call("_find_entity", actor_id) as RuleGridEntity
		if actor != null and actor.position != initial_cell:
			moved = true
			break
	assert_true(moved)
	assert_eq(game.save_state()["turn_index"], 1)
	assert_true(game.execute_command(&"undo"))
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_not_null(actor)
	assert_eq(actor.position, initial_cell)
	assert_eq(game.save_state()["turn_index"], 0)


func test_input_context_gates_hotbar_and_world_commands() -> void:
	var game := _spawn()
	assert_true(game.execute_command(&"hotbar", {"slot": 4}))
	assert_eq(game.save_state()["hotbar_slot"], 4)
	var before: Dictionary = game.save_state()
	game.context.input_enabled = false
	assert_false(game.execute_command(&"hotbar", {"slot": 1}))
	assert_false(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	assert_eq(game.save_state(), before)


func test_undo_history_survives_a_json_safe_save_roundtrip() -> void:
	var game := _spawn()
	var actor := _first_you(game)
	assert_not_null(actor)
	var actor_id := actor.id
	var initial_position := actor.position
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		game.execute_command(&"move", {"direction": direction})
		actor = game.call("_find_entity", actor_id) as RuleGridEntity
		if actor != null and actor.position != initial_position:
			break
	assert_not_null(actor)
	assert_ne(actor.position, initial_position)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.save_state()))
	assert_true(SaveService.is_json_safe(snapshot))
	game.load_state(snapshot)
	var restored: Dictionary = game.save_state()
	var loaded_state := RuleGridState.from_dictionary(restored["grid"])
	assert_eq(_entity_positions(loaded_state), _entity_positions(RuleGridState.from_dictionary(snapshot["grid"])))
	assert_eq(int(restored["turn_index"]), int(snapshot["turn_index"]))
	assert_eq((game.get("_undo_stack") as Array).size(), (snapshot["undo_stack"] as Array).size())
	assert_true(game.execute_command(&"undo"))
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_not_null(actor)
	assert_eq(actor.position, initial_position)


func test_reference_progression_stops_before_legacy_compatibility_boards() -> void:
	var game := _spawn()
	var progression := game.call("_progression_board_ids") as Array[StringName]
	assert_eq(progression.size(), 14)
	assert_eq(RuleLevelLoader.list_level_ids().size(), 16)
	var last_id: StringName = progression.back()
	var last_level: Dictionary = RuleLevelLoader.load_level(last_id)
	var state: Dictionary = game.save_state()
	state["board_id"] = String(last_id)
	state["grid"] = (last_level["state"] as RuleGridState).to_dictionary()
	state["solved"] = true
	game.load_state(state)
	assert_true(game.execute_command(&"confirm"))
	assert_eq(game.save_state()["board_id"], String(last_id))


func test_3d_view_is_derived_from_an_active_you_is_3d_rule() -> void:
	var selected_board := StringName()
	var selected_state: RuleGridState
	for candidate_id: StringName in RuleLevelLoader.list_level_ids():
		var loaded := RuleLevelLoader.load_level(candidate_id)
		if not bool(loaded.get("ok", false)):
			continue
		var candidate_state := loaded["state"] as RuleGridState
		var candidate_rules := RuleParser.parse(candidate_state.width, candidate_state.height, candidate_state.entities)
		for entity: RuleGridEntity in candidate_state.entities:
			if not entity.is_word and candidate_rules.has_property(entity.kind, &"YOU") \
				and candidate_rules.has_property(entity.kind, &"3D"):
				selected_board = candidate_id
				selected_state = candidate_state
				break
		if not selected_board.is_empty():
			break
	assert_false(selected_board.is_empty(), "authored content must exercise its promised IS 3D transition")
	var game := _spawn()
	var state: Dictionary = game.save_state()
	state["board_id"] = String(selected_board)
	state["grid"] = selected_state.to_dictionary()
	game.load_state(state)
	assert_true(game.call("_is_3d_mode"))
	assert_eq(game.save_state()["board_id"], String(selected_board))


func test_has_spawn_survives_save_and_undo_restores_its_removal_as_one_intent() -> void:
	var game := _spawn()
	var board_id := &"rule_06_key_from_risk"
	var level := RuleLevelLoader.load_level(board_id)
	assert_true(level["ok"])
	var state: Dictionary = game.save_state()
	state["board_id"] = String(board_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	game.load_state(state)
	var original_state := game.get("grid_state") as RuleGridState
	var original_grid: Dictionary = original_state.to_dictionary()
	var original_max_serial := -1
	for entity: RuleGridEntity in original_state.entities:
		original_max_serial = maxi(original_max_serial, entity.creation_serial)

	assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	var spawned_state: Dictionary = game.save_state()
	var spawn_id := "has::moth::1::KEY"
	var spawned_key := game.call("_find_entity", spawn_id) as RuleGridEntity
	assert_not_null(spawned_key)
	assert_eq(spawned_key.kind, &"KEY")
	assert_eq(spawned_key.position, Vector2i(5, 8))
	assert_gt(spawned_key.creation_serial, original_max_serial)
	assert_false(spawned_state["failed"], "The other YOU survives the MOTH’s DEFEAT contact")
	assert_null(game.call("_find_entity", "moth"))
	assert_not_null(game.call("_find_entity", "lark"))
	assert_true(SaveService.is_json_safe(spawned_state))
	assert_eq((game.get("_undo_stack") as Array).size(), 1)

	game.load_state(spawned_state)
	assert_eq(game.save_state()["grid"], spawned_state["grid"])
	assert_not_null(game.call("_find_entity", spawn_id))
	assert_true(game.execute_command(&"undo"))
	assert_eq((game.get("grid_state") as RuleGridState).to_dictionary(), original_grid)
	assert_false(game.save_state()["failed"])
	assert_eq(game.save_state()["turn_index"], 0)
	assert_eq((game.get("_undo_stack") as Array).size(), 0)


func test_stop_shut_gate_blocks_direct_route_and_key_opens_it_for_win() -> void:
	var game := _spawn()
	var board_id := &"rule_06_key_from_risk"
	var level := RuleLevelLoader.load_level(board_id)
	assert_true(level["ok"])
	var state: Dictionary = game.save_state()
	state["board_id"] = String(board_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	game.load_state(state)

	for _step: int in range(12):
		game.execute_command(&"move", {"direction": Vector2i.RIGHT})
	assert_not_null(game.call("_find_entity", "gate"), "STOP keeps the direct R×12 route from reaching the beacon")
	assert_false(game.get("solved"))
	game.execute_command(&"reset")

	var open_route: Array[Vector2i] = [
		Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.UP,
		Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
		Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN,
		Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT
	]
	for direction: Vector2i in open_route:
		game.execute_command(&"move", {"direction": direction})
	assert_null(game.call("_find_entity", "gate"), "OPEN key contact removes the SHUT+STOP gate")
	assert_null(game.call("_find_entity", "has::moth::1::KEY"))
	assert_false(game.get("solved"))

	assert_true(game.execute_command(&"undo"))
	assert_not_null(game.call("_find_entity", "gate"))
	assert_not_null(game.call("_find_entity", "has::moth::1::KEY"))
	assert_eq(game.save_state()["turn_index"], 11)

	assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	for _step: int in range(6):
		game.execute_command(&"move", {"direction": Vector2i.RIGHT})
	assert_true(game.get("solved"), "The route reaches BEACON after opening the gate")


func test_board_08_requires_lamp_and_open_key_contact_to_reach_star() -> void:
	var game := _spawn()
	var board_id := &"rule_08_safe_crossing"
	var level := RuleLevelLoader.load_level(board_id)
	assert_true(level["ok"])
	var initial_state: Dictionary = game.save_state()
	initial_state["board_id"] = String(board_id)
	initial_state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	initial_state["solved"] = false
	initial_state["failed"] = false
	initial_state["turn_index"] = 0
	initial_state["completed_board_ids"] = []
	initial_state["undo_stack"] = []

	game.load_state(initial_state.duplicate(true))
	for _step: int in range(13):
		game.execute_command(&"move", {"direction": Vector2i.RIGHT})
	assert_true(game.get("failed"), "Without moving LAMP, MOTH melts before reaching STAR")
	assert_false(game.get("solved"))
	assert_not_null(game.call("_find_entity", "key"))
	assert_not_null(game.call("_find_entity", "gate"))

	game.load_state(initial_state.duplicate(true))
	var bypass_route: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.UP]
	for _step: int in range(9):
		bypass_route.append(Vector2i.RIGHT)
	bypass_route.append(Vector2i.DOWN)
	for direction: Vector2i in bypass_route:
		game.execute_command(&"move", {"direction": direction})
	assert_false(game.get("solved"), "The side route reaches the STOP+SHUT gate from above")
	assert_not_null(game.call("_find_entity", "key"))
	assert_not_null(game.call("_find_entity", "gate"))

	game.load_state(initial_state.duplicate(true))
	var authored_route: Array[Vector2i] = [
		Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
		Vector2i.UP, Vector2i.UP, Vector2i.UP,
		Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
		Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
		Vector2i.DOWN,
		Vector2i.LEFT, Vector2i.LEFT, Vector2i.LEFT, Vector2i.LEFT,
		Vector2i.DOWN, Vector2i.DOWN,
		Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
		Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT
	]
	for index: int in range(authored_route.size()):
		game.execute_command(&"move", {"direction": authored_route[index]})
		if index == 23:
			assert_null(game.call("_find_entity", "key"), "KEY opens GATE on the same movement intent")
			assert_null(game.call("_find_entity", "gate"), "OPEN+SHUT removes the STOP gate")
			assert_false(game.get("solved"), "The next step reaches STAR")
	assert_true(game.get("solved"), "The route uses SAFE, FLOAT, and OPEN+SHUT to reach STAR")
	assert_eq(game.save_state()["turn_index"], 25)
