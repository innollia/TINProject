extends GutTest

const ACTION_SUFFIXES: Array[String] = [
	"left", "right", "up", "down", "confirm", "cancel", "undo", "reset", "forward",
	"turn_left", "turn_right", "toggle_view", "cycle_3d_subject", "open_inventory", "cycle_metrix", "place",
	"hotbar_1", "hotbar_2", "hotbar_3", "hotbar_4", "hotbar_5", "hotbar_6", "hotbar_7", "hotbar_8", "hotbar_9"
]
const ACTION_KEYS: Dictionary = {
	"rule_rewriting_left": KEY_LEFT, "rule_rewriting_right": KEY_RIGHT,
	"rule_rewriting_up": KEY_UP, "rule_rewriting_down": KEY_DOWN,
	"rule_rewriting_confirm": KEY_ENTER, "rule_rewriting_cancel": KEY_BACKSPACE,
	"rule_rewriting_undo": KEY_Z, "rule_rewriting_reset": KEY_R,
	"rule_rewriting_forward": KEY_W, "rule_rewriting_turn_left": KEY_A,
	"rule_rewriting_turn_right": KEY_D, "rule_rewriting_toggle_view": KEY_V
}
const _CUE_ROUTE: Array[Vector2i] = [
	Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.UP,
	Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
	Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN,
	Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT,
	Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
	Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT
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
			if ACTION_KEYS.has(String(action)):
				var key := InputEventKey.new()
				key.physical_keycode = int(ACTION_KEYS[String(action)])
				InputMap.action_add_event(action, key)
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


func _load_board(game: GameModule, board_id: StringName) -> void:
	var level := RuleLevelLoader.load_level(board_id)
	assert_true(level.get("ok", false), "Could not load %s" % board_id)
	var state: Dictionary = game.save_state()
	state["board_id"] = String(board_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	state["solved"] = false
	state["failed"] = false
	state["turn_index"] = 0
	state["completed_board_ids"] = []
	state["undo_stack"] = []
	game.load_state(state)
	await get_tree().process_frame


func _tap_action(game: GameModule, action: StringName) -> void:
	Input.action_press(action)
	game.call("_process", 0.1)
	Input.action_release(action)
	game.call("_process", 0.0)


func _real_tap(game: GameModule, action: StringName) -> void:
	var keycode := int(ACTION_KEYS.get(String(action), 0))
	_press_key_event(game, keycode, true)
	_press_key_event(game, keycode, false)
	game.call("_process", 0.016)


func _press_key_event(game: GameModule, keycode: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = pressed
	game.call("_input", event)

func _object(id: String, kind: String, cell: Vector2i, tags: Array[StringName]) -> RuleGridEntity:
	var entity := RuleGridEntity.new()
	entity.id = id
	entity.kind = StringName(kind)
	entity.position = cell
	entity.base_tags.assign(tags)
	return entity


func _load_grid(game: GameModule, state: RuleGridState) -> void:
	game.set("grid_state", state)
	game.set("solved", false)
	game.set("failed", false)
	game.set("turn_index", 0)
	game.set("_solved_cue_remaining", 0.0)
	(game.get("_solved_cue_cells") as Array).clear()
	(game.get("_undo_stack") as Array).clear()
	game.call("_rebuild_derived")
	game.call("_refresh")


func _has_spawn_micro_state(mode_3d: bool) -> RuleGridState:
	var state := RuleGridState.new()
	state.width = 7
	state.height = 3
	state.entities.append(_word("w_moth", &"MOTH", Vector2i(0, 0), &"noun"))
	state.entities.append(_word("w_has", &"HAS", Vector2i(1, 0), &"operator"))
	state.entities.append(_word("w_key", &"KEY", Vector2i(2, 0), &"noun"))
	state.entities.append(_word("w_key2", &"KEY", Vector2i(4, 0), &"noun"))
	state.entities.append(_word("w_is", &"IS", Vector2i(5, 0), &"operator"))
	state.entities.append(_word("w_win", &"WIN", Vector2i(6, 0), &"property"))
	state.entities.append(_object("wall", "WALL", Vector2i(2, 1), [&"STOP"] as Array[StringName]))
	var actor_tags: Array[StringName] = [&"YOU"] as Array[StringName]
	if mode_3d:
		actor_tags.append(&"3D")
	state.entities.append(_object("actor", "BABA", Vector2i(2, 2), actor_tags))
	state.entities.append(_object("blast", "MOTH", Vector2i(2, 2), [&"WEAK"] as Array[StringName]))
	return state


func _word(id: String, value: StringName, cell: Vector2i, role: StringName) -> RuleGridEntity:
	var entity := RuleGridEntity.new()
	entity.id = id
	entity.kind = &"TEXT"
	entity.position = cell
	entity.creation_serial = cell.x + 1
	entity.is_word = true
	entity.word_role = role
	entity.word_value = value
	return entity


func _select_subject(game: GameModule, entity_id: String) -> void:
	for _attempt: int in range(4):
		if String(game.get("selected_3d_subject_id")) == entity_id:
			return
		game.execute_command(&"cycle_3d_subject")
	assert_eq(String(game.get("selected_3d_subject_id")), entity_id)


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
	assert_eq(progression.size(), 15)
	assert_eq(RuleLevelLoader.list_level_ids().size(), 17)
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


func test_3d_view_toggle_is_first_person_and_does_not_change_physical_state() -> void:
	var game := _spawn()
	var level := RuleLevelLoader.load_level(&"rule_14_owner_focus")
	var state: Dictionary = game.save_state()
	state["board_id"] = String(&"rule_14_owner_focus")
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	game.load_state(state)
	var view := game.get("_view") as RuleBoardView
	assert_true(game.call("_is_3d_mode"))
	assert_true(bool(view.get("_first_person_3d")))
	var before: Dictionary = game.save_state()
	var undo_size := (game.get("_undo_stack") as Array).size()
	assert_true(game.execute_command(&"toggle_view"))
	assert_false(bool(view.get("_first_person_3d")))
	assert_eq(game.save_state(), before)
	assert_eq((game.get("_undo_stack") as Array).size(), undo_size)
	assert_true(game.execute_command(&"toggle_view"))
	assert_true(bool(view.get("_first_person_3d")))


func test_3d_forward_moves_the_selected_subject_one_grid_turn() -> void:
	var game := _spawn()
	var level := RuleLevelLoader.load_level(&"rule_14_owner_focus")
	var state: Dictionary = game.save_state()
	state["board_id"] = String(&"rule_14_owner_focus")
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	game.load_state(state)
	while String(game.get("selected_3d_subject_id")) != "lark":
		game.execute_command(&"cycle_3d_subject")
	var subject := game.call("_find_entity", "lark") as RuleGridEntity
	var before := subject.position
	var before_turn := int(game.save_state()["turn_index"])
	assert_true(game.execute_command(&"forward"))
	subject = game.call("_find_entity", "lark") as RuleGridEntity
	assert_not_null(subject)
	assert_ne(subject.position, before)
	assert_eq(int(game.save_state()["turn_index"]), before_turn + 1)


func test_physical_arrows_use_2d_route_and_programmatic_move_remains_3d_compatible() -> void:
	var game := _spawn()
	var actor := _first_you(game)
	assert_not_null(actor)
	var actor_id := actor.id
	var initial_position := actor.position
	_tap_action(game, &"rule_rewriting_right")
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_not_null(actor)
	assert_eq(actor.position, initial_position + Vector2i.RIGHT)
	assert_eq(int(game.save_state()["turn_index"]), 1)
	assert_eq((game.get("_undo_stack") as Array).size(), 1)

	await _load_board(game, &"rule_14_owner_focus")
	_select_subject(game, "lark")
	var subject_before := game.call("_find_entity", "lark") as RuleGridEntity
	var grid_before := (game.get("grid_state") as RuleGridState).to_dictionary()
	var turn_before := int(game.save_state()["turn_index"])
	var undo_before := (game.get("_undo_stack") as Array).duplicate(true)
	_tap_action(game, &"rule_rewriting_right")
	var subject_after := game.call("_find_entity", "lark") as RuleGridEntity
	assert_not_null(subject_before)
	assert_not_null(subject_after)
	assert_eq(subject_after.position, subject_before.position)
	assert_eq((game.get("grid_state") as RuleGridState).to_dictionary(), grid_before)
	assert_eq(int(game.save_state()["turn_index"]), turn_before)
	assert_eq((game.get("_undo_stack") as Array).duplicate(true), undo_before)
	var lark_before_move := subject_after.position
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	var lark_after_move := game.call("_find_entity", "lark") as RuleGridEntity
	assert_not_null(lark_after_move)
	assert_ne(lark_after_move.position, lark_before_move)
	await get_tree().process_frame


func test_3d_forward_and_view_intents_keep_physical_contracts() -> void:
	var game := _spawn()
	await _load_board(game, &"rule_14_owner_focus")
	_select_subject(game, "lark")
	var subject_before := game.call("_find_entity", "lark") as RuleGridEntity
	var position_before := subject_before.position
	var turn_before := int(game.save_state()["turn_index"])
	var undo_before := (game.get("_undo_stack") as Array).size()
	_tap_action(game, &"rule_rewriting_forward")
	var subject_after := game.call("_find_entity", "lark") as RuleGridEntity
	assert_not_null(subject_after)
	assert_ne(subject_after.position, position_before)
	assert_eq(int(game.save_state()["turn_index"]), turn_before + 1)
	assert_eq((game.get("_undo_stack") as Array).size(), undo_before + 1)
	var grid_after_forward := (game.get("grid_state") as RuleGridState).to_dictionary()
	var turn_after_forward := int(game.save_state()["turn_index"])
	var undo_after_forward := (game.get("_undo_stack") as Array).duplicate(true)
	_tap_action(game, &"rule_rewriting_turn_left")
	_tap_action(game, &"rule_rewriting_turn_right")
	_tap_action(game, &"rule_rewriting_toggle_view")
	_tap_action(game, &"rule_rewriting_cycle_3d_subject")
	assert_eq((game.get("grid_state") as RuleGridState).to_dictionary(), grid_after_forward)
	assert_eq(int(game.save_state()["turn_index"]), turn_after_forward)
	assert_eq((game.get("_undo_stack") as Array).duplicate(true), undo_after_forward)
	assert_false(bool((game.get("_view") as RuleBoardView).get("_first_person_3d")))
	assert_true(game.execute_command(&"open_inventory"))
	assert_true(bool(game.get("_inventory_open")))
	var inventory_grid := (game.get("grid_state") as RuleGridState).to_dictionary()
	var inventory_turn := int(game.save_state()["turn_index"])
	var inventory_undo := (game.get("_undo_stack") as Array).duplicate(true)
	var focus_before := int(game.get("_focused_slot"))
	_tap_action(game, &"rule_rewriting_right")
	assert_eq((game.get("grid_state") as RuleGridState).to_dictionary(), inventory_grid)
	assert_eq(int(game.save_state()["turn_index"]), inventory_turn)
	assert_eq((game.get("_undo_stack") as Array).duplicate(true), inventory_undo)
	assert_ne(int(game.get("_focused_slot")), focus_before)
	await get_tree().process_frame


func test_toggle_view_uses_context_input_enabled_for_the_real_v_action() -> void:
	var game := _spawn()
	await _load_board(game, &"rule_14_owner_focus")
	var view := game.get("_view") as RuleBoardView
	var grid_before := (game.get("grid_state") as RuleGridState).to_dictionary()
	var undo_before := (game.get("_undo_stack") as Array).duplicate(true)
	_tap_action(game, &"rule_rewriting_toggle_view")
	assert_false(bool(view.get("_first_person_3d")))
	assert_eq((game.get("grid_state") as RuleGridState).to_dictionary(), grid_before)
	assert_eq((game.get("_undo_stack") as Array).duplicate(true), undo_before)
	game.context.input_enabled = false
	_tap_action(game, &"rule_rewriting_toggle_view")
	assert_false(bool(view.get("_first_person_3d")))
	game.context.input_enabled = true
	_tap_action(game, &"rule_rewriting_toggle_view")
	assert_true(bool(view.get("_first_person_3d")))
	await get_tree().process_frame


func test_first_person_defaults_on_load_reset_advance_and_2d_to_3d_entry() -> void:
	var game := _spawn()
	await _load_board(game, &"rule_13_hotbar_phrase")
	assert_false(game.call("_is_3d_mode"))
	game.set("_first_person_3d", false)
	game.set("_camera_quadrant", 2)
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	assert_true(game.call("_is_3d_mode"))
	var view := game.get("_view") as RuleBoardView
	assert_true(bool(view.get("_first_person_3d")))
	assert_eq(int(game.get("_camera_quadrant")), 0)
	var restored_state: Dictionary = game.save_state()
	game.execute_command(&"toggle_view")
	game.execute_command(&"turn_right")
	game.load_state(restored_state)
	assert_true(bool(view.get("_first_person_3d")))
	assert_eq(int(game.get("_camera_quadrant")), 0)
	game.execute_command(&"toggle_view")
	assert_true(game.execute_command(&"reset"))
	assert_true(bool(view.get("_first_person_3d")))
	assert_eq(int(game.get("_camera_quadrant")), 0)

	await _load_board(game, &"rule_13_hotbar_phrase")
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	game.set("solved", true)
	game.execute_command(&"toggle_view")
	assert_true(game.execute_command(&"confirm"))
	assert_eq(String(game.save_state()["board_id"]), "rule_14_owner_focus")
	assert_true(bool(view.get("_first_person_3d")))
	assert_eq(int(game.get("_camera_quadrant")), 0)
	await get_tree().process_frame


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


func test_undo_command_reports_empty_history_and_restores_after_real_short_presses() -> void:
	var game := _spawn()
	var actor := _first_you(game)
	assert_not_null(actor)
	var actor_id := actor.id
	var start_cell := actor.position
	assert_false(game.execute_command(&"undo"), "empty history reports undo failure")
	assert_true(game.execute_command(&"move", {"direction": Vector2i.RIGHT}))
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_not_null(actor)
	assert_ne(actor.position, start_cell)
	_real_tap(game, &"rule_rewriting_undo")
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_eq(actor.position, start_cell, "a short press that starts and ends between frames still undoes")
	assert_eq(int(game.save_state()["turn_index"]), 0)
	assert_eq((game.get("_undo_stack") as Array).size(), 0)
	for direction: Vector2i in [Vector2i.UP, Vector2i.UP, Vector2i.DOWN, Vector2i.UP]:
		game.execute_command(&"move", {"direction": direction})
	assert_eq(int(game.save_state()["turn_index"]), 4)
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_eq(actor.position, start_cell + Vector2i(0, -2))
	_real_tap(game, &"rule_rewriting_undo")
	assert_eq(int(game.save_state()["turn_index"]), 3, "the second real undo still reaches history")
	assert_eq((game.get("_undo_stack") as Array).size(), 3)
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_eq(actor.position, start_cell + Vector2i(0, -1))
	_real_tap(game, &"rule_rewriting_undo")
	assert_eq(int(game.save_state()["turn_index"]), 2)
	assert_eq((game.get("_undo_stack") as Array).size(), 2)
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_eq(actor.position, start_cell + Vector2i(0, -2))
	while game.execute_command(&"undo"):
		pass
	assert_false(game.execute_command(&"undo"), "drained history reports undo failure")
	assert_eq(int(game.save_state()["turn_index"]), 0)
	assert_eq((game.get("_undo_stack") as Array).size(), 0)
	actor = game.call("_find_entity", actor_id) as RuleGridEntity
	assert_eq(actor.position, start_cell)


func test_solved_cue_enter_skips_and_undo_cancels_with_state_restored() -> void:
	var skip_game := _spawn()
	await _load_board(skip_game, &"rule_06_key_from_risk")
	_play_cue_route(skip_game)
	assert_true(skip_game.solved, "the authored route reaches the BEACON")
	assert_gt(float(skip_game.get("_solved_cue_remaining")), 0.0)
	var solved_grid := (skip_game.get("grid_state") as RuleGridState).to_dictionary()
	assert_false(skip_game.execute_command(&"move", {"direction": Vector2i.RIGHT}), "the cue blocks movement")
	assert_eq((skip_game.get("grid_state") as RuleGridState).to_dictionary(), solved_grid)
	assert_true(skip_game.execute_command(&"confirm"))
	assert_false(skip_game.solved)
	assert_eq(String(skip_game.save_state()["board_id"]), "rule_07_moving_gate")
	assert_eq(int(skip_game.save_state()["turn_index"]), 0)
	assert_eq((skip_game.get("_undo_stack") as Array).size(), 0)

	var undo_game := _spawn()
	await _load_board(undo_game, &"rule_06_key_from_risk")
	for index: int in range(_CUE_ROUTE.size() - 1):
		undo_game.execute_command(&"move", {"direction": _CUE_ROUTE[index]})
	assert_false(undo_game.solved)
	var pre_solve_grid := (undo_game.get("grid_state") as RuleGridState).to_dictionary()
	var pre_solve_turn := int(undo_game.save_state()["turn_index"])
	var pre_solve_undo := (undo_game.get("_undo_stack") as Array).size()
	undo_game.execute_command(&"move", {"direction": _CUE_ROUTE.back()})
	assert_true(undo_game.solved)
	assert_gt(float(undo_game.get("_solved_cue_remaining")), 0.0)
	assert_true(undo_game.execute_command(&"undo"), "undo cancels the success cue")
	assert_false(undo_game.solved)
	assert_eq(float(undo_game.get("_solved_cue_remaining")), 0.0)
	assert_eq((undo_game.get("_solved_cue_cells") as Array).size(), 0)
	assert_eq((undo_game.get("grid_state") as RuleGridState).to_dictionary(), pre_solve_grid)
	assert_eq(int(undo_game.save_state()["turn_index"]), pre_solve_turn)
	assert_eq((undo_game.get("_undo_stack") as Array).size(), pre_solve_undo)
	await get_tree().process_frame


func test_last_board_solved_cue_ends_with_the_existing_forward_request() -> void:
	var game := _spawn()
	var requests: Array[Dictionary] = []
	game.requested.connect(func(kind: StringName, payload: Dictionary) -> void:
		requests.append({"kind": kind, "payload": payload})
	)
	var last_id: StringName = (game.call("_progression_board_ids") as Array[StringName]).back()
	var level := RuleLevelLoader.load_level(last_id)
	var state: Dictionary = game.save_state()
	state["board_id"] = String(last_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	game.load_state(state)
	game.set("solved", true)
	game.call("_begin_solved_cue")
	game.call("_refresh")
	assert_eq(requests.size(), 0)
	game.call("_process", 0.05)
	assert_eq(requests.size(), 0, "the last board keeps its solved state through the cue")
	game.call("_process", 5.0)
	assert_eq(requests.size(), 1)
	assert_eq(requests[0], {"kind": &"portal", "payload": {"exit": "forward"}})
	assert_eq(String(game.save_state()["board_id"]), String(last_id))
	assert_true(bool(game.get("_request_sent")), "the last board leaves through the existing forward request")
	await get_tree().process_frame


func test_blocked_direct_move_still_runs_auto_shift_contact_and_commits_one_turn() -> void:
	var game := _spawn()
	var state := RuleGridState.new()
	state.width = 5
	state.height = 3
	state.entities.append(_object("wall", "WALL", Vector2i(2, 1), [&"STOP"] as Array[StringName]))
	state.entities.append(_object("actor", "BABA", Vector2i(2, 2), [&"YOU"] as Array[StringName]))
	state.entities.append(_object("pad", "PAD", Vector2i(2, 2), [&"SHIFT"] as Array[StringName]))
	state.entities.append(_object("flag", "FLAG", Vector2i(3, 2), [&"WIN"] as Array[StringName]))
	_load_grid(game, state)
	var blocked := RuleMovementSolver.plan_move_many(state, game.get("rule_set") as RuleSet, ["actor"] as Array[String], Vector2i.UP)
	assert_false(bool(blocked.get("can_move", false)), "the direct YOU step is blocked")
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	assert_eq((game.call("_find_entity", "actor") as RuleGridEntity).position, Vector2i(3, 2))
	assert_eq((game.call("_find_entity", "pad") as RuleGridEntity).position, Vector2i(2, 2))
	assert_true(game.solved, "the SHIFT stage still reaches the WIN contact")
	assert_eq(int(game.save_state()["turn_index"]), 1)
	assert_eq((game.get("_undo_stack") as Array).size(), 1)
	assert_gt(float(game.get("_solved_cue_remaining")), 0.0)
	assert_eq((game.get("_solved_cue_cells") as Array).size(), 1)
	assert_eq((game.get("_solved_cue_cells") as Array)[0], Vector2i(3, 2))
	await get_tree().process_frame


func test_no_op_blocked_turn_keeps_turn_and_undo_history() -> void:
	var game := _spawn()
	var state := RuleGridState.new()
	state.width = 4
	state.height = 3
	state.entities.append(_object("wall", "WALL", Vector2i(1, 1), [&"STOP"] as Array[StringName]))
	state.entities.append(_object("actor", "BABA", Vector2i(1, 2), [&"YOU"] as Array[StringName]))
	_load_grid(game, state)
	var before: Dictionary = game.save_state()
	for _step: int in range(3):
		assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	assert_eq((game.call("_find_entity", "actor") as RuleGridEntity).position, Vector2i(1, 2))
	assert_eq(game.save_state(), before, "a blocked no-op keeps the physical board and flags")
	assert_eq(int(game.save_state()["turn_index"]), 0)
	assert_eq((game.get("_undo_stack") as Array).size(), 0)
	assert_false(game.execute_command(&"undo"), "a no-op blocked turn leaves nothing to undo")
	await get_tree().process_frame


func test_has_removal_is_reevaluated_until_the_final_contact_settles() -> void:
	var game := _spawn()
	_load_grid(game, _has_spawn_micro_state(false))
	assert_true((game.get("rule_set") as RuleSet).has_property(&"KEY", &"WIN"))
	assert_false(game.solved)
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}), "the direct YOU step stays blocked")
	assert_null(game.call("_find_entity", "blast"), "the WEAK source resolves on the blocked turn")
	var spawned := game.call("_find_entity", "has::blast::1::KEY") as RuleGridEntity
	assert_not_null(spawned)
	assert_eq(spawned.position, Vector2i(2, 2))
	assert_true(game.solved, "the spawned WIN contact is resolved on the final physical state")
	assert_eq((game.get("_solved_cue_cells") as Array).size(), 1)
	assert_eq((game.get("_solved_cue_cells") as Array)[0], Vector2i(2, 2))
	assert_eq(int(game.save_state()["turn_index"]), 1)
	assert_eq((game.get("_undo_stack") as Array).size(), 1)
	assert_eq((game.call("_find_entity", "actor") as RuleGridEntity).position, Vector2i(2, 2))
	await get_tree().process_frame


func _play_cue_route(game: GameModule) -> void:
	for index: int in range(_CUE_ROUTE.size()):
		game.execute_command(&"move", {"direction": _CUE_ROUTE[index]})

