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
