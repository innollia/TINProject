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
	game.enter(injected)
	return game


func _word(id: String, value: StringName, position: Vector2i, role: StringName) -> RuleGridEntity:
	var entity := RuleGridEntity.new()
	entity.id = id
	entity.kind = &"TEXT"
	entity.position = position
	entity.creation_serial = position.x + 1
	entity.is_word = true
	entity.word_role = role
	entity.word_value = value
	entity.base_tags.append(&"PUSH")
	return entity


func _object(id: String, kind: String, cell: Vector2i, tags: Array[StringName]) -> RuleGridEntity:
	var entity := RuleGridEntity.new()
	entity.id = id
	entity.kind = StringName(kind)
	entity.position = cell
	entity.base_tags.assign(tags)
	return entity


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


func _load_board(game: GameModule, board_id: StringName) -> void:
	var level := RuleLevelLoader.load_level(board_id)
	assert_true(level.get("ok", false), "Could not load %s" % board_id)
	var state: Dictionary = game.save_state()
	state["board_id"] = String(board_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	state["solved"] = false
	state["failed"] = false
	state["turn_index"] = 0
	state["selected_3d_subject_id"] = ""
	state["selected_metrix_id"] = ""
	state["hotbar_slot"] = 0
	state["completed_board_ids"] = []
	state["undo_stack"] = []
	game.load_state(state)
	await get_tree().process_frame


func test_first_person_camera_is_offset_and_inventory_has_no_key_hint() -> void:
	var game := _spawn()
	await _load_board(game, &"rule_14_owner_focus")
	var view := game.get("_view") as RuleBoardView
	var subject := game.call("_find_entity", "moth") as RuleGridEntity
	var camera := view.get("_camera") as Camera3D
	assert_not_null(subject)
	assert_not_null(camera)
	if subject == null or camera == null:
		return
	var subject_center := Vector3(float(subject.position.x), 0.72, float(subject.position.y))
	var forward := view.call("_camera_forward") as Vector3
	var backward_distance := (camera.position - subject_center).dot(-forward)
	assert_true(backward_distance >= 0.5)
	assert_true(backward_distance <= 0.8)
	var state := game.get("grid_state") as RuleGridState
	assert_true(camera.position.x >= 0.0)
	assert_true(camera.position.x <= float(state.width - 1))
	assert_true(camera.position.z >= 0.0)
	assert_true(camera.position.z <= float(state.height - 1))
	var first_position := camera.position
	var first_subject_node := (view.get("_world_entity_nodes") as Dictionary).get("moth") as Node3D
	assert_not_null(first_subject_node)
	assert_eq(first_subject_node.get_child_count(), 0)
	assert_true(game.execute_command(&"toggle_view"))
	camera = view.get("_camera") as Camera3D
	var third_subject_node := (view.get("_world_entity_nodes") as Dictionary).get("moth") as Node3D
	assert_not_null(third_subject_node)
	assert_gt(third_subject_node.get_child_count(), 0)
	assert_false(bool(view.get("_first_person_3d")))
	assert_gt(camera.position.distance_to(subject_center), 1.0)
	assert_true(game.execute_command(&"toggle_view"))
	camera = view.get("_camera") as Camera3D
	var restored_subject_node := (view.get("_world_entity_nodes") as Dictionary).get("moth") as Node3D
	assert_not_null(restored_subject_node)
	assert_eq(restored_subject_node.get_child_count(), 0)
	assert_eq(camera.position, first_position)
	assert_true(game.execute_command(&"open_inventory"))
	var inventory_panel := view.get("_inventory_panel") as Control
	for child: Node in inventory_panel.find_children("*", "Label", true, false):
		var text := String((child as Label).text)
		assert_false(text.contains("Enter"))
		assert_false(text.contains("Backspace"))
	subject.position = Vector2i(0, 0)
	view.call("_sync_world_camera")
	assert_true(camera.position.x >= 0.0)
	assert_true(camera.position.z >= 0.0)
	view.set("_selected_you_id", "missing")
	view.call("_sync_world_camera")
	assert_eq(camera.fov, 46.0)


func test_rule_change_highlights_source_words_and_changed_object_without_banner() -> void:
	var game := _spawn()
	var state := RuleGridState.new()
	state.width = 6
	state.height = 3
	var actor := RuleGridEntity.new()
	actor.id = "actor"
	actor.kind = &"BABA"
	actor.position = Vector2i(1, 0)
	actor.base_tags.append(&"YOU")
	state.entities.append(actor)
	state.entities.append(_word("word_baba", &"BABA", Vector2i(1, 1), &"noun"))
	state.entities.append(_word("word_is", &"IS", Vector2i(2, 1), &"operator"))
	state.entities.append(_word("word_push", &"PUSH", Vector2i(3, 1), &"property"))
	game.set("grid_state", state)
	game.call("_rebuild_derived")
	game.call("_refresh")
	var view := game.get("_view") as RuleBoardView
	assert_true((view.get("_world_entity_nodes") as Dictionary).is_empty(), "2D refresh must not build 3D world nodes")
	var controlled_ids: Array[String] = ["actor"]
	game.call("_apply_player_intent", controlled_ids, Vector2i.DOWN)
	assert_false((game.get("rule_set") as RuleSet).has_property(&"BABA", &"PUSH"))
	game.call("_refresh")
	var feedback: Dictionary = view.get("_feedback_ids")
	assert_true(feedback.has("word_baba"))
	assert_true(feedback.has("word_is"))
	assert_true(feedback.has("word_push"))
	assert_true(feedback.has("actor"), "the physical entity whose property changed receives local feedback")
	assert_eq(String(game.get("_message")), "")
	assert_false((view.get("_message_panel") as Control).visible, "rule changes do not show an explanatory banner")

	game.set("failed", true)
	game.call("_refresh")
	assert_true((view.get("_recovery_panel") as Control).visible, "failure recovery stays visible")
	assert_true(String((view.get("_recovery_text") as Label).text).contains("되돌리기"))
	assert_false((view.get("_message_panel") as Control).visible)


func test_success_cue_is_visible_in_2d_and_3d_without_inventory_hints() -> void:
	var game := _spawn()
	_load_grid(game, _has_spawn_micro_state(false))
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	assert_true(game.solved)
	var view := game.get("_view") as RuleBoardView
	var cue_root := view.get("_world_cue_root") as Node3D
	assert_not_null(cue_root)
	assert_gt(float(view.get("_solved_cue")), 0.0)
	var cells: Array = view.get("_solved_cue_cells")
	assert_eq(cells.size(), 1)
	assert_eq(cells[0], Vector2i(2, 2))
	assert_eq(cue_root.get_child_count(), 0, "a 2D board keeps the 3D cue markers empty")
	game.set("solved", false)
	game.set("_solved_cue_remaining", 0.0)
	(game.get("_solved_cue_cells") as Array).clear()
	game.call("_refresh")
	assert_eq(float(view.get("_solved_cue")), 0.0)
	assert_true((view.get("_solved_cue_cells") as Array).is_empty())

	_load_grid(game, _has_spawn_micro_state(true))
	assert_true(game.execute_command(&"move", {"direction": Vector2i.UP}))
	assert_true(game.solved)
	assert_true(game.call("_is_3d_mode"))
	assert_gt(float(view.get("_solved_cue")), 0.0)
	assert_eq(cue_root.get_child_count(), 1, "a 3D board marks the solved contact in world space")
	var cue_node := cue_root.get_child(0) as Node3D
	assert_not_null(cue_node)
	assert_eq(cue_node.get_child_count(), 2)
	assert_eq(cue_node.position, Vector3(2.0, 0.0, 2.0))
	var beam := cue_node.get_child(0) as MeshInstance3D
	assert_not_null(beam)
	var beam_material := beam.material_override as StandardMaterial3D
	assert_not_null(beam_material)
	assert_eq(beam_material.shading_mode, BaseMaterial3D.SHADING_MODE_UNSHADED)
	assert_gt(beam_material.albedo_color.a, 0.0)
	var inventory_panel := view.get("_inventory_panel") as Control
	for child: Node in inventory_panel.find_children("*", "Label", true, false):
		var text := String((child as Label).text)
		assert_false(text.contains("Enter"))
		assert_false(text.contains("Backspace"))
	game.set("solved", false)
	game.set("_solved_cue_remaining", 0.0)
	(game.get("_solved_cue_cells") as Array).clear()
	game.call("_refresh")
	assert_eq(cue_root.get_child_count(), 0, "a cancelled cue clears the 3D markers")
