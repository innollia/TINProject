extends GutTest

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


func test_board_10_shared_frame_push_translates_both_shapes_and_wins_at_shared_wall() -> void:
	var bypass := _spawn_board(&"rule_10_shared_frames")
	_move_n(bypass, Vector2i.LEFT, 2)
	_move_n(bypass, Vector2i.UP, 8)
	_move_n(bypass, Vector2i.RIGHT, 14)
	_move_n(bypass, Vector2i.DOWN, 8)
	assert_false(bypass.solved, "The former perimeter walk must not reach the shared-wall FLAG")
	assert_eq(_entity_position(bypass, "flag"), Vector2i(10, 8), "The bypass may translate content, but it must not solve by walking around the frame")

	var game := _spawn_board(&"rule_10_shared_frames")
	var shapes: Array = game.get("metrix_shapes")
	assert_eq(shapes.size(), 2)
	assert_eq(shapes[0]["component_id"], shapes[1]["component_id"])
	var initial_bounds: Array[Vector2i] = []
	var initial_boundary_positions: Dictionary = {}
	for shape_value: Variant in shapes:
		var shape: Dictionary = shape_value
		var bounds: Rect2i = shape["bounds"]
		initial_bounds.append(bounds.position)
		for entity_id_value: Variant in shape["boundary_entity_ids"]:
			var entity_id := String(entity_id_value)
			initial_boundary_positions[entity_id] = _entity_position(game, entity_id)
	initial_bounds.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	assert_eq(initial_bounds, [Vector2i(3, 5), Vector2i(7, 7)])
	assert_eq(_entity_position(game, "moth"), Vector2i(2, 8))
	assert_eq(_entity_position(game, "flag"), Vector2i(7, 8))
	for step: int in range(4):
		_move(game, Vector2i.RIGHT)
		assert_false(game.solved, "Moth reaches the shared wall only after the connected frame moves")
		assert_eq(_entity_position(game, "moth"), Vector2i(3 + step, 8))
	_move(game, Vector2i.RIGHT)
	assert_true(game.solved)
	assert_eq(_entity_position(game, "moth"), Vector2i(7, 8))
	assert_eq(_entity_position(game, "flag"), Vector2i(7, 8))
	var after_shapes: Array = game.get("metrix_shapes")
	assert_eq(after_shapes.size(), 2)
	var after_bounds: Array[Vector2i] = []
	for shape_value: Variant in after_shapes:
		var shape: Dictionary = shape_value
		var bounds: Rect2i = shape["bounds"]
		after_bounds.append(bounds.position)
	after_bounds.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	assert_eq(after_bounds, [Vector2i(4, 5), Vector2i(8, 7)])
	for entity_id_value: Variant in initial_boundary_positions.keys():
		var entity_id := String(entity_id_value)
		assert_eq(_entity_position(game, entity_id), initial_boundary_positions[entity_id] + Vector2i.RIGHT)


func test_board_11_forms_inv_then_moves_the_same_rock_through_the_two_dimensional_metrix() -> void:
	var bypass := _spawn_board(&"rule_11_metrix_storage")
	assert_false(bypass.call("_is_3d_mode"))
	assert_false(_rules(bypass).has_property(&"METRIX", &"INV"))
	assert_eq(_available_inventories(bypass).size(), 0)
	var bypass_rock_before := _entity_position(bypass, "rock")
	_move_n(bypass, Vector2i.RIGHT, 5)
	assert_false(bypass.solved, "The old direct rightward win route must not bypass the INV/ROCK task")
	assert_eq(_entity_position(bypass, "rock"), bypass_rock_before)
	assert_false(_rules(bypass).has_property(&"METRIX", &"INV"))

	var game := _spawn_board(&"rule_11_metrix_storage")
	assert_false(game.call("_is_3d_mode"))
	assert_false(_rules(game).has_property(&"METRIX", &"INV"))
	_move(game, Vector2i.LEFT)
	assert_true(_rules(game).has_property(&"METRIX", &"INV"))
	assert_eq(_entity_position(game, "inv_3"), Vector2i(3, 2))
	assert_eq(_entity_position(game, "moth"), Vector2i(4, 2))
	var shape := _only_shape(game)
	assert_true(bool(shape.get("inventory", false)))
	assert_false(bool(game.get("_inventory_open")), "2D INV derives slots but does not open a 3D inventory UI")
	game.execute_command(&"open_inventory")
	assert_false(bool(game.get("_inventory_open")))
	assert_eq(_available_inventories(game).size(), 1)

	_move(game, Vector2i.DOWN)
	_move_n(game, Vector2i.RIGHT, 5)
	assert_eq(_entity_position(game, "moth"), Vector2i(9, 3))
	for step: int in range(9):
		_move(game, Vector2i.DOWN)
		var rock_cell := _entity_position(game, "rock")
		if step == 0:
			assert_eq(rock_cell, Vector2i(9, 5))
			assert_eq(_slot_cell(_only_shape(game), "rock"), Vector2i(-1, -1))
		elif step == 1:
			assert_eq(rock_cell, Vector2i(9, 6))
			assert_eq(_slot_cell(_only_shape(game), "rock"), Vector2i(9, 6))
		elif step == 5:
			assert_eq(rock_cell, Vector2i(9, 10))
			assert_eq(_slot_cell(_only_shape(game), "rock"), Vector2i(-1, -1))
		elif step == 6:
			assert_eq(rock_cell, Vector2i(9, 11))
			assert_eq(_slot_cell(_only_shape(game), "rock"), Vector2i(-1, -1))
	assert_true(game.solved)
	assert_eq(_entity_position(game, "moth"), Vector2i(9, 12))
	assert_eq(_entity_position(game, "rock"), Vector2i(9, 13))
	assert_false(game.call("_is_3d_mode"))


func test_board_12_cannot_take_the_old_perimeter_route_and_core_snaps_with_frame() -> void:
	var bypass := _spawn_board(&"rule_12_wall_alignment")
	var original_bounds: Rect2i = _only_shape(bypass)["bounds"]
	_move_n(bypass, Vector2i.LEFT, 2)
	_move_n(bypass, Vector2i.UP, 8)
	_move_n(bypass, Vector2i.RIGHT, 14)
	_move_n(bypass, Vector2i.DOWN, 8)
	assert_false(bypass.solved, "The former perimeter walk must stop at authored WALL boundaries")
	var bypass_bounds: Rect2i = _only_shape(bypass)["bounds"]
	assert_eq(bypass_bounds.position, Vector2i(8, 6), "The walk pushes the frame along its top edge and still cannot reach Beacon")
	assert_ne(bypass_bounds, original_bounds)

	var game := _spawn_board(&"rule_12_wall_alignment")
	assert_eq(_entity_position(game, "moth"), Vector2i(4, 8))
	assert_eq(_entity_position(game, "core"), Vector2i(6, 7))
	_move(game, Vector2i.RIGHT)
	assert_eq(_entity_position(game, "moth"), Vector2i(5, 8), "Moth enters through the west Door")
	_move_n(game, Vector2i.RIGHT, 3)
	assert_eq(_entity_position(game, "moth"), Vector2i(8, 8))
	_move(game, Vector2i.RIGHT)
	assert_eq(_entity_position(game, "core"), Vector2i(9, 7))
	var moved_bounds: Rect2i = _only_shape(game)["bounds"]
	assert_eq(moved_bounds.position, Vector2i(6, 6))
	_move(game, Vector2i.RIGHT)
	assert_eq(_entity_position(game, "moth"), Vector2i(10, 8))
	assert_eq(_entity_position(game, "core"), Vector2i(10, 7))
	assert_true(game.solved)

	var blocked := _spawn_board(&"rule_12_wall_alignment")
	var moved_beacon := _entity(blocked, "beacon")
	moved_beacon.position = Vector2i(14, 2)
	_move(blocked, Vector2i.RIGHT)
	_move_n(blocked, Vector2i.RIGHT, 3)
	_move_n(blocked, Vector2i.RIGHT, 3)
	var before_blocked_push: Dictionary = blocked.save_state()
	_move(blocked, Vector2i.RIGHT)
	assert_false(blocked.solved)
	assert_eq(blocked.save_state(), before_blocked_push, "Outer WALL collision must reject the frame and content atomically")


func test_board_13_requires_moth_is_3d_before_hotbar_rock_completes_win_phrase() -> void:
	var game := _spawn_board(&"rule_13_hotbar_phrase")
	assert_false(game.call("_is_3d_mode"))
	assert_false(_rules(game).has_property(&"MOTH", &"3D"))
	var initial_rock := _entity_position(game, "rock_inventory")
	game.execute_command(&"open_inventory")
	assert_false(bool(game.get("_inventory_open")))
	game.execute_command(&"hotbar", {"slot": 5})
	game.execute_command(&"place", {"cell": Vector2i(4, 8)})
	assert_eq(_entity_position(game, "rock_inventory"), initial_rock)
	assert_false(game.solved)

	_move(game, Vector2i.UP)
	assert_true(game.call("_is_3d_mode"))
	assert_true(_rules(game).has_property(&"MOTH", &"3D"))
	assert_eq(_entity_position(game, "vertical_3d"), Vector2i(1, 3))
	assert_eq(_entity_position(game, "moth"), Vector2i(1, 4))
	assert_eq(_available_inventories(game).size(), 1)
	var shape := _only_shape(game)
	assert_eq(_slot_cell(shape, "rock_inventory"), Vector2i(11, 8))
	game.execute_command(&"open_inventory")
	assert_true(bool(game.get("_inventory_open")))
	game.execute_command(&"hotbar", {"slot": 5})
	game.execute_command(&"open_inventory")
	assert_false(bool(game.get("_inventory_open")))
	game.execute_command(&"place", {"cell": Vector2i(4, 8)})
	assert_eq(_entity_position(game, "rock_inventory"), Vector2i(4, 8))
	assert_true(_rules(game).has_property(&"ROCK", &"WIN"))
	assert_false(game.solved)
	_move(game, Vector2i.DOWN)
	_move_n(game, Vector2i.RIGHT, 3)
	_move_n(game, Vector2i.DOWN, 3)
	assert_true(game.solved)
	assert_eq(_entity_position(game, "moth"), Vector2i(4, 8))


func test_board_14_lark_must_activate_glass_inventory_to_place_key_win() -> void:
	var bypass := _spawn_board(&"rule_14_owner_focus")
	for shape_value: Variant in bypass.get("metrix_shapes"):
		var shape: Dictionary = shape_value
		print("BOARD14_START bounds=", shape.get("bounds"), " owners=", shape.get("owner_ids"), " inventory=", shape.get("inventory"))
	print("BOARD14_SUBJECT ", bypass.get("selected_3d_subject_id"))
	assert_true(bypass.call("_is_3d_mode"))
	assert_false(_rules(bypass).has_property(&"BEACON", &"WIN"))
	assert_false(_rules(bypass).has_property(&"KEY", &"WIN"))
	assert_eq(_available_inventories(bypass).size(), 1)
	_move_n(bypass, Vector2i.UP, 3)
	_move(bypass, Vector2i.UP)
	_move_n(bypass, Vector2i.RIGHT, 3)
	_move(bypass, Vector2i.UP)
	assert_false(bypass.solved, "Touching the former Beacon target no longer bypasses owner/ACTIVE inventory play")
	assert_eq(_entity_position(bypass, "moth"), Vector2i(9, 6))

	var game := _spawn_board(&"rule_14_owner_focus")
	assert_true(_rules(game).has_property(&"MOTH", &"3D"))
	assert_true(_rules(game).has_property(&"LARK", &"3D"))
	assert_false(_rules(game).has_property(&"KEY", &"WIN"))
	assert_eq(_available_inventories(game).size(), 1, "Only the Ember inventory starts active")

	# Place Moth on the eventual KEY cell so the required item placement is the winning contact.
	_move_n(game, Vector2i.UP, 3)
	_move(game, Vector2i.UP)
	_move(game, Vector2i.LEFT)
	_move(game, Vector2i.UP)
	assert_eq(_entity_position(game, "moth"), Vector2i(5, 6))
	assert_eq(_available_inventories(game).size(), 1, "Moth still owns only the active Ember inventory")
	_select_subject(game, "lark")
	assert_eq(_available_inventories(game).size(), 0, "Lark's Glass-owned inventory is inactive before the missing word is moved")
	_move(game, Vector2i.RIGHT)
	_move_n(game, Vector2i.UP, 3)
	_move(game, Vector2i.UP)
	_move_n(game, Vector2i.LEFT, 7)
	_move_n(game, Vector2i.UP, 2)
	_move_n(game, Vector2i.LEFT, 2)
	assert_eq(_entity_position(game, "glass_target"), Vector2i(5, 5))
	assert_eq(_available_inventories(game).size(), 1, "Lark can select only its Glass-owned inventory")
	assert_false(game.solved)
	var glass_shape := _only_available_shape(game)
	var glass_owners: Array = glass_shape.get("owner_ids", [])
	assert_true(glass_owners.has("lark"))
	assert_eq(_slot_cell(glass_shape, "key_second"), Vector2i(15, 10))
	game.execute_command(&"open_inventory")
	assert_true(bool(game.get("_inventory_open")))
	game.execute_command(&"hotbar", {"slot": 6})
	game.execute_command(&"open_inventory")
	assert_false(bool(game.get("_inventory_open")))
	game.execute_command(&"place", {"cell": Vector2i(5, 6)})
	assert_eq(_entity_position(game, "key_second"), Vector2i(5, 6))
	assert_true(_rules(game).has_property(&"KEY", &"WIN"))
	assert_true(game.solved)


func test_board_10_route_cue_holds_then_advances_to_the_next_board() -> void:
	var game := _spawn_board(&"rule_10_shared_frames")
	for step: int in range(4):
		_move(game, Vector2i.RIGHT)
		assert_false(game.solved, "the connected frame has to move before the contact wins")
	_move(game, Vector2i.RIGHT)
	assert_true(game.solved, "the real route reaches the shared-wall WIN contact")
	var cue_cells: Array = game.get("_solved_cue_cells")
	assert_eq(cue_cells.size(), 1)
	assert_eq(cue_cells[0], Vector2i(7, 8))
	assert_gt(float(game.get("_solved_cue_remaining")), 0.0)
	var solved_turn := int(game.save_state()["turn_index"])
	assert_eq(solved_turn, 5)
	game.call("_process", 0.05)
	assert_true(game.solved, "the cue keeps the solved board on screen")
	assert_eq(String(game.save_state()["board_id"]), "rule_10_shared_frames")
	game.call("_process", 5.0)
	assert_false(game.solved, "the cue expires and advances by itself")
	assert_eq(String(game.save_state()["board_id"]), "rule_11_metrix_storage")
	assert_eq(int(game.save_state()["turn_index"]), 0)
	assert_eq((game.get("_undo_stack") as Array).size(), 0)
	assert_eq(float(game.get("_solved_cue_remaining")), 0.0)


func _spawn_board(board_id: StringName) -> GameModule:
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
	var loaded := RuleLevelLoader.load_level(board_id)
	assert_true(loaded.get("ok", false), "Could not load %s" % board_id)
	var saved: Dictionary = game.save_state()
	saved["board_id"] = String(board_id)
	saved["grid"] = (loaded["state"] as RuleGridState).to_dictionary()
	saved["solved"] = false
	game.load_state(saved)
	return game


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


func _only_shape(game: GameModule) -> Dictionary:
	var shapes: Array = game.get("metrix_shapes")
	assert_eq(shapes.size(), 1)
	return shapes[0] if not shapes.is_empty() else {}


func _available_inventories(game: GameModule) -> Array:
	var available: Array = game.call("_available_inventories")
	return available


func _only_available_shape(game: GameModule) -> Dictionary:
	var available := _available_inventories(game)
	assert_eq(available.size(), 1)
	return available[0] if not available.is_empty() else {}


func _slot_cell(shape: Dictionary, entity_id: String) -> Vector2i:
	for slot_value: Variant in shape.get("slots", []):
		if not slot_value is Dictionary:
			continue
		var slot: Dictionary = slot_value
		var entity_ids: Array = slot.get("entity_ids", [])
		if entity_ids.has(entity_id):
			return slot.get("cell", Vector2i(-1, -1))
	return Vector2i(-1, -1)


func _select_subject(game: GameModule, entity_id: String) -> void:
	for _attempt: int in range(3):
		if String(game.get("selected_3d_subject_id")) == entity_id:
			return
		game.execute_command(&"cycle_3d_subject")
	assert_eq(String(game.get("selected_3d_subject_id")), entity_id)
