extends SceneTree

const MODULE_SCENE: String = "res://modules/rule_rewriting/entry.tscn"
const BOARD_ID: StringName = &"rule_09_first_metrix"
const ACTIONS: Array[String] = ["left", "right", "up", "down", "forward", "turn_left", "turn_right", "cycle_3d_subject", "open_inventory", "cycle_metrix", "place", "undo", "reset", "confirm", "cancel"]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(MODULE_SCENE) as PackedScene
	var game := packed.instantiate() as GameModule
	var injected := ModuleContext.new()
	injected.module_id = &"rule_rewriting"
	injected.input_enabled = true
	for action_suffix: String in ACTIONS:
		injected.allowed_actions.append(StringName("rule_rewriting_%s" % action_suffix))
	game.context = injected
	root.add_child(game)
	await process_frame
	game.enter(injected)
	var authored := RuleLevelLoader.load_level(BOARD_ID)
	var initial_state: Dictionary = game.save_state()
	initial_state["board_id"] = String(BOARD_ID)
	initial_state["grid"] = (authored["state"] as RuleGridState).to_dictionary()
	initial_state["solved"] = false
	initial_state["failed"] = false
	initial_state["turn_index"] = 0
	initial_state["completed_board_ids"] = []
	initial_state["undo_stack"] = []
	var scenarios: Array[Dictionary] = []
	var straight_route: Array[Vector2i] = [Vector2i.DOWN]
	scenarios.append({"name": "straight_down_blocked", "route": straight_route})
	var top_route: Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT]
	scenarios.append({"name": "top_detour_blocked", "route": top_route})
	var authored_route: Array[Vector2i] = []
	authored_route.append(Vector2i.LEFT)
	for index: int in range(5): authored_route.append(Vector2i.DOWN)
	authored_route.append(Vector2i.RIGHT)
	scenarios.append({"name": "complete_metrix_then_enter_door", "route": authored_route})
	for scenario: Dictionary in scenarios:
		game.load_state(initial_state.duplicate(true))
		var route: Array[Vector2i] = scenario["route"]
		print("RULE_REFERENCE_SCENARIO name=%s start=%s" % [scenario["name"], _rule_signature(game.get("rule_set"))])
		for index: int in range(route.size()):
			game.execute_command(&"move", {"direction": route[index]})
			var grid: RuleGridState = game.get("grid_state")
			var actor: RuleGridEntity = game.call("_find_entity", "moth")
			var tracked: Array[String] = []
			for entity: RuleGridEntity in grid.entities:
				if entity.kind in [&"KEY", &"GATE", &"LAVA", &"POOL", &"LAMP", &"STAR", &"FLAG", &"ROCK"]:
					tracked.append("%s:%s" % [entity.kind, entity.position])
			print("RULE_REFERENCE_STEP scenario=%s index=%02d dir=%s moth=%s rules=%s tracked=%s solved=%s failed=%s" % [scenario["name"], index + 1, route[index], actor.position if actor != null else "gone", _rule_signature(game.get("rule_set")), tracked, game.get("solved"), game.get("failed")])
			if bool(game.get("solved")) or bool(game.get("failed")):
				break
		print("RULE_REFERENCE_RESULT scenario=%s solved=%s failed=%s turns=%s" % [scenario["name"], game.get("solved"), game.get("failed"), game.get("turn_index")])
	game.exit()
	game.queue_free()
	quit(0 if bool(game.get("solved")) else 1)


func _rule_signature(rules: RuleSet) -> String:
	var values: Array[String] = []
	for sentence: RuleSentence in rules.sentences:
		values.append("%s %s %s" % [sentence.subject, sentence.operator, sentence.predicate])
	values.sort()
	return "[" + ", ".join(values) + "]"
