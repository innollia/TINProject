extends GutTest

const BOARD_ID: StringName = &"rule_15_relay"
const ACTION_SUFFIXES: Array[String] = [
	"left", "right", "up", "down", "confirm", "cancel", "undo", "reset", "forward",
	"turn_left", "turn_right", "toggle_view", "cycle_3d_subject", "open_inventory", "cycle_metrix", "place",
	"hotbar_1", "hotbar_2", "hotbar_3", "hotbar_4", "hotbar_5", "hotbar_6", "hotbar_7", "hotbar_8", "hotbar_9"
]

var _owned_actions: Array[StringName] = []


func after_each() -> void:
	for action: StringName in _owned_actions:
		Input.action_release(action)
		InputMap.erase_action(action)
	_owned_actions.clear()


func test_index_order_schema_and_ids_include_rule_15() -> void:
	var index_text := FileAccess.get_file_as_string("res://modules/rule_rewriting/content/index.json")
	var index_value: Variant = JSON.parse_string(index_text)
	var parsed_index := RuleLevelLoader.parse_index(index_value)
	assert_true(parsed_index["ok"])
	var entries: Array = parsed_index["entries"]
	assert_eq(entries.size(), 17)
	assert_eq(entries[14]["id"], "rule_15_relay")
	assert_eq(entries[14]["path"], "reference/rule_15_relay.json")
	assert_eq(entries[15]["id"], "signal_room_01")
	assert_eq(entries[16]["id"], "crossing_02")

	var loaded := RuleLevelLoader.load_level(BOARD_ID)
	assert_true(loaded["ok"])
	assert_eq(loaded["id"], "rule_15_relay")
	assert_eq(loaded["schema_version"], 1)
	assert_eq(loaded["completion_condition"], "win_contact")
	assert_eq(loaded["art_recipe_id"], "recipe_rule_15_relay")
	var state := loaded["state"] as RuleGridState
	assert_eq(state.width, 16)
	assert_eq(state.height, 12)
	var seen: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		assert_false(seen.has(entity.id))
		seen[entity.id] = true
	var initial_rules := RuleParser.parse(state.width, state.height, state.entities)
	assert_false(initial_rules.has_property(&"METRIX", &"INV"))
	assert_false(initial_rules.has_property(&"MOTH", &"3D"))
	assert_false(initial_rules.has_property(&"ROCK", &"WIN"))


func test_rule_15_requires_metrix_inventory_and_accepts_two_item_routes() -> void:
	var bypass := _spawn_board()
	assert_false(bypass.call("_is_3d_mode"))
	assert_false(_rules(bypass).has_property(&"METRIX", &"INV"))
	assert_eq(_available_inventories(bypass).size(), 0)
	_move_n(bypass, Vector2i.RIGHT, 2)
	_move_n(bypass, Vector2i.DOWN, 2)
	assert_false(bypass.solved)
	assert_false(_rules(bypass).has_property(&"METRIX", &"INV"))
	assert_eq(_entity_position(bypass, "rock_inventory"), Vector2i(7, 9))

	var rock_game := _spawn_board()
	_prepare_relay(rock_game)
	assert_true(_rules(rock_game).has_property(&"METRIX", &"INV"))
	assert_true(_rules(rock_game).has_property(&"MOTH", &"3D"))
	assert_true(rock_game.call("_is_3d_mode"))
	assert_eq(_available_inventories(rock_game).size(), 1)
	_move_n(rock_game, Vector2i.RIGHT, 7)
	_move_n(rock_game, Vector2i.DOWN, 6)
	_move_n(rock_game, Vector2i.RIGHT, 2)
	assert_eq(_entity_position(rock_game, "moth"), Vector2i(13, 9))
	_place_item(rock_game, 5, Vector2i(13, 9))
	assert_true(rock_game.solved)
	assert_true(_rules(rock_game).has_property(&"ROCK", &"WIN"))
	assert_eq(_entity_position(rock_game, "rock_inventory"), Vector2i(13, 9))
	assert_true(rock_game.save_state()["completed_board_ids"].has("rule_15_relay"))
	assert_gt(rock_game.save_state()["turn_index"], 30)

	var pearl_game := _spawn_board()
	_prepare_relay(pearl_game)
	_move_n(pearl_game, Vector2i.RIGHT, 7)
	_move_n(pearl_game, Vector2i.DOWN, 6)
	_move_n(pearl_game, Vector2i.RIGHT, 2)
	_place_item(pearl_game, 6, Vector2i(13, 9))
	assert_true(pearl_game.solved)
	assert_true(_rules(pearl_game).has_property(&"PEARL", &"WIN"))
	assert_eq(_entity_position(pearl_game, "pearl_inventory"), Vector2i(13, 9))


func _spawn_board() -> GameModule:
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
	var loaded := RuleLevelLoader.load_level(BOARD_ID)
	assert_true(loaded["ok"])
	var saved: Dictionary = game.save_state()
	saved["board_id"] = String(BOARD_ID)
	saved["grid"] = (loaded["state"] as RuleGridState).to_dictionary()
	saved["solved"] = false
	saved["failed"] = false
	saved["turn_index"] = 0
	saved["completed_board_ids"] = []
	saved["undo_stack"] = []
	game.load_state(saved)
	return game


func _prepare_relay(game: GameModule) -> void:
	_move(game, Vector2i.RIGHT)
	_move_n(game, Vector2i.UP, 2)
	_move_n(game, Vector2i.LEFT, 2)
	_move_n(game, Vector2i.UP, 6)
	_move_n(game, Vector2i.RIGHT, 5)
	_move(game, Vector2i.UP)
	_move(game, Vector2i.LEFT)
	_move(game, Vector2i.DOWN)
	_move_n(game, Vector2i.LEFT, 6)
	_move(game, Vector2i.LEFT)
	_move(game, Vector2i.RIGHT)
	_move(game, Vector2i.DOWN)
	_move(game, Vector2i.LEFT)


func _place_item(game: GameModule, slot: int, target: Vector2i) -> void:
	assert_true(game.execute_command(&"open_inventory"))
	assert_true(bool(game.get("_inventory_open")))
	game.execute_command(&"hotbar", {"slot": slot})
	assert_true(game.execute_command(&"open_inventory"))
	assert_false(bool(game.get("_inventory_open")))
	game.execute_command(&"place", {"cell": target})


func _move(game: GameModule, direction: Vector2i) -> void:
	assert_true(game.execute_command(&"move", {"direction": direction}))


func _move_n(game: GameModule, direction: Vector2i, count: int) -> void:
	for _step: int in range(count):
		_move(game, direction)


func _entity(game: GameModule, entity_id: String) -> RuleGridEntity:
	return game.call("_find_entity", entity_id) as RuleGridEntity


func _entity_position(game: GameModule, entity_id: String) -> Vector2i:
	var entity := _entity(game, entity_id)
	assert_not_null(entity, "Missing entity %s" % entity_id)
	return entity.position if entity != null else Vector2i(-1, -1)


func _rules(game: GameModule) -> RuleSet:
	return game.get("rule_set") as RuleSet


func _available_inventories(game: GameModule) -> Array:
	return game.call("_available_inventories") as Array
