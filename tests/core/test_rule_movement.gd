extends GutTest


func _entity(id: String, kind: String, cell: Vector2i) -> RuleGridEntity:
	var entity := RuleGridEntity.new()
	entity.id = id
	entity.kind = StringName(kind)
	entity.position = cell
	return entity


func _state(width: int, entities: Array[RuleGridEntity]) -> RuleGridState:
	var state := RuleGridState.new()
	state.width = width
	state.height = 1
	state.entities.assign(entities)
	return state


func _rule(noun: String, property: String) -> RuleSentence:
	return RuleSentence.new(StringName(noun), &"IS", StringName(property), &"property")


func test_empty_cell_move_returns_plan_without_mutating_state() -> void:
	var actor := _entity("actor", "PERSON", Vector2i(0, 0))
	var state := _state(3, [actor])
	var plan := RuleMovementSolver.plan_move(state, RuleSet.new(), "actor", Vector2i.RIGHT)

	assert_true(plan["can_move"])
	assert_eq(plan["moves"], [{"entity_id": "actor", "from": Vector2i(0, 0), "to": Vector2i(1, 0)}])
	assert_eq(actor.position, Vector2i(0, 0))


func test_push_chains_of_one_five_and_twenty_entities() -> void:
	for chain_length: int in [1, 5, 20]:
		var entities: Array[RuleGridEntity] = [_entity("actor", "PERSON", Vector2i.ZERO)]
		var rules := RuleSet.new()
		rules.add(_rule("CRATE", "PUSH"))
		for index: int in range(chain_length):
			entities.append(_entity("crate_%02d" % index, "CRATE", Vector2i(index + 1, 0)))
		var state := _state(chain_length + 2, entities)
		var plan := RuleMovementSolver.plan_move(state, rules, "actor", Vector2i.RIGHT)

		assert_true(plan["can_move"])
		assert_eq(plan["moves"].size(), chain_length + 1)
		for move: Dictionary in plan["moves"]:
			assert_eq(move["to"], move["from"] + Vector2i.RIGHT)
		assert_eq(state.entities[0].position, Vector2i.ZERO)
		if chain_length == 5:
			var reversed_entities: Array[RuleGridEntity] = []
			for index: int in range(entities.size() - 1, -1, -1):
				reversed_entities.append(entities[index])
			var reversed_plan := RuleMovementSolver.plan_move(_state(chain_length + 2, reversed_entities), rules, "actor", Vector2i.RIGHT)
			assert_eq(reversed_plan["moves"], plan["moves"])


func test_blocked_push_chain_is_atomic() -> void:
	var entities: Array[RuleGridEntity] = [
		_entity("actor", "PERSON", Vector2i(0, 0)),
		_entity("crate_a", "CRATE", Vector2i(1, 0)),
		_entity("crate_b", "CRATE", Vector2i(2, 0)),
		_entity("wall", "WALL", Vector2i(3, 0))
	]
	var state := _state(4, entities)
	var rules := RuleSet.new()
	rules.add(_rule("CRATE", "PUSH"))
	rules.add(_rule("WALL", "STOP"))
	var plan := RuleMovementSolver.plan_move(state, rules, "actor", Vector2i.RIGHT)

	assert_false(plan["can_move"])
	assert_true(plan["moves"].is_empty())
	assert_eq(state.entities.map(func(entity: RuleGridEntity) -> Vector2i: return entity.position), [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


func test_passable_entities_can_share_target_cell_and_stop_blocks() -> void:
	var actor := _entity("actor", "PERSON", Vector2i.ZERO)
	var decoration := _entity("decoration", "DECORATION", Vector2i.RIGHT)
	var shadow := _entity("shadow", "SHADOW", Vector2i.RIGHT)
	var state := _state(3, [actor, decoration, shadow])
	var empty_rules := RuleSet.new()
	var passable := RuleMovementSolver.plan_move(state, empty_rules, "actor", Vector2i.RIGHT)
	assert_true(passable["can_move"])
	assert_eq(passable["moves"].size(), 1)
	assert_eq(passable["moves"][0]["to"], decoration.position)

	var rules := RuleSet.new()
	rules.add(_rule("DECORATION", "STOP"))
	var blocked := RuleMovementSolver.plan_move(state, rules, "actor", Vector2i.RIGHT)
	assert_false(blocked["can_move"])
	assert_true(blocked["moves"].is_empty())


func test_multiple_controlled_entities_share_one_atomic_direction() -> void:
	var actor_a := _entity("actor_a", "PERSON", Vector2i(0, 0))
	var actor_b := _entity("actor_b", "PERSON", Vector2i(0, 1))
	var crate := _entity("crate", "CRATE", Vector2i(1, 0))
	var state := RuleGridState.new()
	state.width = 4
	state.height = 2
	state.entities = [actor_b, crate, actor_a]
	var rules := RuleSet.new()
	rules.add(_rule("CRATE", "PUSH"))

	var plan := RuleMovementSolver.plan_move_many(state, rules, ["actor_b", "actor_a"], Vector2i.RIGHT)
	assert_true(plan["can_move"])
	assert_eq(plan["moves"], [
		{"entity_id": "actor_a", "from": Vector2i(0, 0), "to": Vector2i(1, 0)},
		{"entity_id": "actor_b", "from": Vector2i(0, 1), "to": Vector2i(1, 1)},
		{"entity_id": "crate", "from": Vector2i(1, 0), "to": Vector2i(2, 0)}
	])
	assert_eq(actor_a.position, Vector2i(0, 0))
	assert_eq(crate.position, Vector2i(1, 0))


func test_solver_rejects_invalid_direction_duplicate_ids_and_board_edges() -> void:
	var actor := _entity("actor", "PERSON", Vector2i.ZERO)
	var state := _state(3, [actor])
	assert_false(RuleMovementSolver.plan_move(state, RuleSet.new(), "actor", Vector2i.ZERO)["can_move"])
	assert_false(RuleMovementSolver.plan_move(state, RuleSet.new(), "missing", Vector2i.RIGHT)["can_move"])
	assert_false(RuleMovementSolver.plan_move(_state(1, [actor]), RuleSet.new(), "actor", Vector2i.RIGHT)["can_move"])
	state.entities.append(_entity("actor", "PERSON", Vector2i.RIGHT))
	assert_false(RuleMovementSolver.plan_move(state, RuleSet.new(), "actor", Vector2i.RIGHT)["can_move"])
	state.entities.clear()
	state.entities.append(null)
	assert_false(RuleMovementSolver.plan_move(state, RuleSet.new(), "actor", Vector2i.RIGHT)["can_move"])


func test_move_entities_take_one_step_and_turn_around_when_blocked() -> void:
	var eastbound := _entity("a_move", "GLIDER", Vector2i(0, 0))
	var blocked := _entity("b_move", "GLIDER", Vector2i(3, 0))
	var wall := _entity("wall", "WALL", Vector2i(4, 0))
	eastbound.facing = Vector2i.RIGHT
	blocked.facing = Vector2i.RIGHT
	var state := _state(5, [blocked, wall, eastbound])
	var rules := RuleSet.new()
	rules.add(_rule("GLIDER", "MOVE"))
	rules.add(_rule("WALL", "STOP"))

	var plan := RuleMovementSolver.plan_move_auto(state, rules)

	assert_true(plan["valid"])
	assert_eq(plan["moves"].size(), 2)
	assert_eq(plan["moves"][0]["entity_id"], "a_move")
	assert_eq(plan["moves"][0]["to"], Vector2i(1, 0))
	assert_eq(plan["moves"][1]["entity_id"], "b_move")
	assert_eq(plan["moves"][1]["to"], Vector2i(3, 0))
	assert_eq(plan["moves"][1]["facing_to"], Vector2i.LEFT)
	assert_eq(eastbound.position, Vector2i.ZERO)
	assert_eq(blocked.facing, Vector2i.RIGHT)


func test_auto_push_displaces_a_mover_once_and_reports_pushed_words() -> void:
	var mover := _entity("a_mover", "PERSON", Vector2i(0, 0))
	var crate := _entity("b_crate", "CRATE", Vector2i(1, 0))
	var word := _entity("word", "IS", Vector2i(2, 0))
	word.is_word = true
	word.word_role = &"operator"
	word.word_value = &"IS"
	word.base_tags.append(&"PUSH")
	var state := _state(5, [mover, crate, word])
	var rules := RuleSet.new()
	rules.add(_rule("PERSON", "MOVE"))
	rules.add(_rule("CRATE", "MOVE"))
	rules.add(_rule("CRATE", "PUSH"))
	var plan := RuleMovementSolver.plan_move_auto(state, rules)

	assert_true(plan["valid"])
	assert_true(plan["word_moved"])
	assert_eq(plan["moves"].size(), 3)
	assert_eq(plan["moves"][0]["entity_id"], "a_mover")
	assert_eq(plan["moves"][0]["to"], Vector2i(1, 0))
	assert_eq(plan["moves"][1]["entity_id"], "b_crate")
	assert_eq(plan["moves"][1]["to"], Vector2i(2, 0))
	assert_eq(plan["moves"][2]["entity_id"], "word")
	assert_eq(plan["moves"][2]["to"], Vector2i(3, 0))
