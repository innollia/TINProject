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


func test_open_pusher_enters_stop_shut_cell_then_contact_removes_both() -> void:
	var actor := _entity("actor", "PERSON", Vector2i.ZERO)
	var key := _entity("key", "KEY", Vector2i.RIGHT)
	var gate := _entity("gate", "GATE", Vector2i(2, 0))
	var state := _state(4, [actor, key, gate])
	var rules := RuleSet.new()
	rules.add(_rule("KEY", "OPEN"))
	rules.add(_rule("KEY", "PUSH"))
	rules.add(_rule("GATE", "SHUT"))
	rules.add(_rule("GATE", "STOP"))
	rules.add(_rule("GATE", "PUSH"))

	var plan := RuleMovementSolver.plan_move(state, rules, actor.id, Vector2i.RIGHT)
	assert_true(plan["can_move"])
	assert_eq(plan["moves"].size(), 2)
	for move: Dictionary in plan["moves"]:
		var moved := state.entities.filter(func(entity: RuleGridEntity) -> bool:
			return entity.id == move["entity_id"]
		)[0] as RuleGridEntity
		moved.position = move["to"]
	var contacts := RuleEvaluator.resolve_contacts(state, rules)
	assert_true(contacts["valid"])
	assert_has(contacts["removed_ids"], "key")
	assert_has(contacts["removed_ids"], "gate")

	var safe_rules := RuleSet.new()
	safe_rules.add(_rule("KEY", "OPEN"))
	safe_rules.add(_rule("KEY", "PUSH"))
	safe_rules.add(_rule("GATE", "SHUT"))
	safe_rules.add(_rule("GATE", "STOP"))
	safe_rules.add(_rule("GATE", "SAFE"))
	var safe_gate_state := _state(4, [
		_entity("safe_actor", "PERSON", Vector2i.ZERO),
		_entity("safe_key", "KEY", Vector2i.RIGHT),
		_entity("safe_gate", "GATE", Vector2i(2, 0))
	])
	var blocked := RuleMovementSolver.plan_move(safe_gate_state, safe_rules, "safe_actor", Vector2i.RIGHT)
	assert_false(blocked["can_move"], "SAFE prevents the contact that would clear the STOP cell")
	assert_true(blocked["moves"].is_empty())


func test_float_objects_only_block_objects_at_the_same_float_level() -> void:
	var actor := _entity("actor", "PERSON", Vector2i.ZERO)
	var floating_wall := _entity("floating_wall", "WALL", Vector2i.RIGHT)
	var rules := RuleSet.new()
	rules.add(_rule("WALL", "STOP"))
	rules.add(_rule("WALL", "FLOAT"))
	var state := _state(3, [actor, floating_wall])

	var low_actor_plan := RuleMovementSolver.plan_move(state, rules, actor.id, Vector2i.RIGHT)

	assert_true(low_actor_plan["can_move"])
	assert_eq(low_actor_plan["moves"], [
		{"entity_id": "actor", "from": Vector2i.ZERO, "to": Vector2i.RIGHT}
	])
	rules.add(_rule("PERSON", "FLOAT"))
	var matching_float_plan := RuleMovementSolver.plan_move(state, rules, actor.id, Vector2i.RIGHT)
	assert_false(matching_float_plan["can_move"])


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


func test_move_stacks_add_one_step_per_active_move_word() -> void:
	var mover := _entity("mover", "GLIDER", Vector2i(0, 0))
	var first_move := _entity("move_word_1", "MOVE", Vector2i(0, 1))
	var second_move := _entity("move_word_2", "MOVE", Vector2i(1, 1))
	for move_word: RuleGridEntity in [first_move, second_move]:
		move_word.is_word = true
		move_word.word_role = &"property"
		move_word.word_value = &"MOVE"
	var state := _state(5, [mover, first_move, second_move])
	state.height = 2
	var stacked_move := _rule("GLIDER", "MOVE")
	stacked_move.source_entity_ids = ["move_word_1"]
	var second_stacked_move := _rule("GLIDER", "MOVE")
	second_stacked_move.source_entity_ids = ["move_word_2"]
	var rules := RuleSet.new()
	rules.add(stacked_move)
	rules.add(second_stacked_move)

	var plan := RuleMovementSolver.plan_move_auto(state, rules)

	assert_true(plan["valid"])
	assert_eq(RuleEvaluator.property_stack(mover, &"MOVE", rules, state), 2)
	var mover_moves: Array = plan["moves"].filter(func(move: Dictionary) -> bool: return move["entity_id"] == "mover")
	assert_eq(mover_moves.size(), 1)
	assert_eq(mover_moves[0]["to"], Vector2i(2, 0))


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


func test_multiple_controlled_entities_keep_unblocked_moves_when_one_is_stopped() -> void:
	var blocked_you := _entity("blocked_you", "PERSON", Vector2i(0, 0))
	var moving_you := _entity("moving_you", "PERSON", Vector2i(0, 2))
	var wall := _entity("wall", "WALL", Vector2i(1, 0))
	var rules := RuleSet.new()
	rules.add(_rule("WALL", "STOP"))
	var state := RuleGridState.new()
	state.width = 3
	state.height = 3
	state.entities = [moving_you, wall, blocked_you]

	var plan := RuleMovementSolver.plan_move_many(state, rules, ["blocked_you", "moving_you"], Vector2i.RIGHT)
	assert_true(plan["can_move"])
	assert_eq(plan["moves"], [
		{"entity_id": "moving_you", "from": Vector2i(0, 2), "to": Vector2i(1, 2)}
	])
	assert_eq(blocked_you.position, Vector2i(0, 0))
	assert_eq(moving_you.position, Vector2i(0, 2))


func test_entity_processing_uses_cell_layer_and_creation_order_before_id() -> void:
	var newer := _entity("a_newer", "PERSON", Vector2i(1, 0))
	var older := _entity("z_older", "PERSON", Vector2i(1, 0))
	var lower_layer := _entity("m_lower_layer", "PERSON", Vector2i(1, 0))
	newer.creation_serial = 12
	older.creation_serial = 4
	lower_layer.layer = -1
	lower_layer.creation_serial = 99
	var state := _state(3, [newer, older, lower_layer])
	var plan := RuleMovementSolver.plan_move_many(state, RuleSet.new(), ["a_newer", "z_older", "m_lower_layer"], Vector2i.RIGHT)

	assert_true(plan["can_move"])
	assert_eq(plan["moves"].map(func(move: Dictionary) -> String: return move["entity_id"]), [
		"m_lower_layer", "z_older", "a_newer"
	])


func test_pull_moves_the_adjacent_pull_object_into_the_actors_previous_cell() -> void:
	var actor := _entity("actor", "PERSON", Vector2i(1, 0))
	var rope := _entity("rope", "ROPE", Vector2i(0, 0))
	var rules := RuleSet.new()
	rules.add(_rule("ROPE", "PULL"))
	var plan := RuleMovementSolver.plan_move(_state(4, [actor, rope]), rules, "actor", Vector2i.RIGHT)

	assert_true(plan["can_move"])
	assert_eq(plan["moves"], [
		{"entity_id": "rope", "from": Vector2i(0, 0), "to": Vector2i(1, 0)},
		{"entity_id": "actor", "from": Vector2i(1, 0), "to": Vector2i(2, 0)}
	])


func test_swap_exchanges_the_moving_entity_and_its_target() -> void:
	var actor := _entity("actor", "PERSON", Vector2i.ZERO)
	var gate := _entity("gate", "GATE", Vector2i.RIGHT)
	var rules := RuleSet.new()
	rules.add(_rule("GATE", "SWAP"))
	var plan := RuleMovementSolver.plan_move(_state(3, [actor, gate]), rules, "actor", Vector2i.RIGHT)

	assert_true(plan["can_move"])
	assert_eq(plan["moves"], [
		{"entity_id": "actor", "from": Vector2i.ZERO, "to": Vector2i.RIGHT},
		{"entity_id": "gate", "from": Vector2i.RIGHT, "to": Vector2i.ZERO}
	])


func test_shift_moves_objects_sharing_its_cell_along_its_facing() -> void:
	var platform := _entity("platform", "PLATFORM", Vector2i(1, 0))
	var passenger := _entity("passenger", "PASSENGER", Vector2i(1, 0))
	var rules := RuleSet.new()
	rules.add(_rule("PLATFORM", "SHIFT"))
	var plan := RuleMovementSolver.plan_move_auto(_state(4, [passenger, platform]), rules)

	assert_true(plan["valid"])
	assert_true(plan["moves"].any(func(move: Dictionary) -> bool:
		return move["entity_id"] == "passenger" and move["to"] == Vector2i(2, 0)
	))
	assert_false(plan["moves"].any(func(move: Dictionary) -> bool: return move["entity_id"] == "platform"))


func test_metrix_shared_component_moves_atomically_and_snaps_contents_to_forward_wall() -> void:
	var entities: Array[RuleGridEntity] = []
	for y: int in range(1, 4):
		for x: int in range(1, 6):
			if x == 1 or x == 3 or x == 5 or y == 1 or y == 3:
				entities.append(_entity("box_%d_%d" % [x, y], "BOX", Vector2i(x, y)))
	var first := _entity("first_item", "4096", Vector2i(2, 2))
	var second := _entity("second_item", "ROCK", Vector2i(2, 2))
	var actor := _entity("actor", "PERSON", Vector2i(0, 2))
	entities.append(first)
	entities.append(second)
	entities.append(actor)
	var state := RuleGridState.new()
	state.width = 7
	state.height = 5
	state.entities = entities
	var rules := RuleSet.new()
	rules.add(_inside_metrix_rule())
	rules.add(_rule("BOX", "PUSH"))

	var plan := RuleMovementSolver.plan_move(state, rules, "actor", Vector2i.RIGHT)
	assert_true(plan["can_move"])
	var moved_ids: Dictionary = {}
	for move: Dictionary in plan["moves"]:
		moved_ids[move["entity_id"]] = move["to"]
	assert_eq(moved_ids["box_1_2"], Vector2i(2, 2))
	assert_eq(moved_ids["box_3_2"], Vector2i(4, 2))
	assert_eq(moved_ids["box_5_2"], Vector2i(6, 2))
	assert_eq(moved_ids["first_item"], Vector2i(3, 2))
	assert_eq(moved_ids["second_item"], Vector2i(3, 2))
	assert_eq(moved_ids["actor"], Vector2i(1, 2))


func test_metrix_boundary_collision_blocks_the_entire_shared_component() -> void:
	var entities: Array[RuleGridEntity] = []
	for y: int in range(1, 4):
		for x: int in range(1, 6):
			if x == 1 or x == 3 or x == 5 or y == 1 or y == 3:
				entities.append(_entity("box_%d_%d" % [x, y], "BOX", Vector2i(x, y)))
	var actor := _entity("actor", "PERSON", Vector2i(0, 2))
	var wall := _entity("wall", "WALL", Vector2i(6, 2))
	entities.append(actor)
	entities.append(wall)
	var state := RuleGridState.new()
	state.width = 7
	state.height = 5
	state.entities = entities
	var rules := RuleSet.new()
	rules.add(_inside_metrix_rule())
	rules.add(_rule("BOX", "PUSH"))
	rules.add(_rule("WALL", "STOP"))
	var original := state.to_dictionary()

	var plan := RuleMovementSolver.plan_move(state, rules, "actor", Vector2i.RIGHT)
	assert_false(plan["can_move"])
	assert_true(plan["moves"].is_empty())
	assert_eq(state.to_dictionary(), original)


func test_metrix_contents_keep_row_order_while_packing_against_the_forward_wall() -> void:
	var entities: Array[RuleGridEntity] = []
	for y: int in range(1, 4):
		for x: int in range(1, 6):
			if x == 1 or x == 5 or y == 1 or y == 3:
				entities.append(_entity("box_%d_%d" % [x, y], "BOX", Vector2i(x, y)))
	var left_item := _entity("left_item", "ROCK", Vector2i(2, 2))
	var right_item := _entity("right_item", "4096", Vector2i(4, 2))
	var actor := _entity("actor", "PERSON", Vector2i(0, 2))
	entities.append(left_item)
	entities.append(right_item)
	entities.append(actor)
	var state := RuleGridState.new()
	state.width = 7
	state.height = 5
	state.entities = entities
	var rules := RuleSet.new()
	rules.add(_inside_metrix_rule())
	rules.add(_rule("BOX", "PUSH"))

	var plan := RuleMovementSolver.plan_move(state, rules, "actor", Vector2i.RIGHT)
	assert_true(plan["can_move"])
	var moved_ids: Dictionary = {}
	for move: Dictionary in plan["moves"]:
		moved_ids[move["entity_id"]] = move["to"]
	assert_eq(moved_ids["left_item"], Vector2i(4, 2))
	assert_eq(moved_ids["right_item"], Vector2i(5, 2))


func test_metrix_inside_on_condition_filters_shapes_per_boundary_box() -> void:
	var entities: Array[RuleGridEntity] = []
	for y: int in range(1, 4):
		for x: int in range(1, 4):
			if x == 1 or x == 3 or y == 1 or y == 3:
				entities.append(_entity("box_%d_%d" % [x, y], "BOX", Vector2i(x, y)))
	var actor := _entity("actor", "PERSON", Vector2i(0, 2))
	entities.append(actor)
	var state := RuleGridState.new()
	state.width = 5
	state.height = 5
	state.entities = entities
	var conditional_metrix := _inside_metrix_rule()
	conditional_metrix.conditions.append({
		"kind": &"ON", "target": &"WATER", "negated": false, "position": &"infix"
	})
	var rules := RuleSet.new()
	rules.add(conditional_metrix)
	rules.add(_rule("BOX", "PUSH"))

	var ordinary_box_plan := RuleMovementSolver.plan_move(state, rules, actor.id, Vector2i.RIGHT)

	assert_true(ordinary_box_plan["can_move"])
	assert_eq(ordinary_box_plan["moves"].size(), 2)
	assert_true(ordinary_box_plan["moves"].any(func(move: Dictionary) -> bool: return move["entity_id"] == "box_1_2" and move["to"] == Vector2i(2, 2)))
	assert_false(ordinary_box_plan["moves"].any(func(move: Dictionary) -> bool: return move["entity_id"] == "box_3_2"))

	for entity: RuleGridEntity in state.entities.duplicate():
		if entity.kind == &"BOX":
			var water := _entity("water_%s" % entity.id, "WATER", entity.position)
			state.entities.append(water)
	var metrix_plan := RuleMovementSolver.plan_move(state, rules, actor.id, Vector2i.RIGHT)
	assert_true(metrix_plan["can_move"])
	assert_true(metrix_plan["moves"].any(func(move: Dictionary) -> bool: return move["entity_id"] == "box_3_2" and move["to"] == Vector2i(4, 2)))
	assert_true(metrix_plan["moves"].any(func(move: Dictionary) -> bool: return move["entity_id"] == "box_1_2" and move["to"] == Vector2i(2, 2)))


func test_shift_runs_for_the_auto_stage_when_the_direct_move_is_blocked() -> void:
	var actor := _entity("actor", "BABA", Vector2i(2, 2))
	actor.base_tags.append(&"YOU")
	var wall := _entity("wall", "WALL", Vector2i(2, 1))
	wall.base_tags.append(&"STOP")
	var platform := _entity("platform", "PAD", Vector2i(2, 2))
	platform.base_tags.append(&"SHIFT")
	var flag := _entity("flag", "FLAG", Vector2i(3, 2))
	flag.base_tags.append(&"WIN")
	var state := RuleGridState.new()
	state.width = 5
	state.height = 3
	state.entities = [wall, actor, platform, flag]

	var direct := RuleMovementSolver.plan_move(state, RuleSet.new(), "actor", Vector2i.UP)
	var auto := RuleMovementSolver.plan_move_auto(state, RuleSet.new())

	assert_false(direct["can_move"], "the direct YOU step is blocked by the STOP wall")
	assert_true(auto["valid"])
	assert_eq(auto["moves"], [
		{"entity_id": "actor", "from": Vector2i(2, 2), "to": Vector2i(3, 2),
			"facing_from": Vector2i.RIGHT, "facing_to": Vector2i.RIGHT}
	])
	assert_eq(actor.position, Vector2i(2, 2))
	var contacts := RuleEvaluator.resolve_contacts(state, RuleSet.new())
	assert_true(contacts["valid"])
	assert_false(contacts["won"], "the shifted contact only resolves after the auto moves are applied")


func _inside_metrix_rule() -> RuleSentence:
	return RuleSentence.new("BOX", &"INSIDE_IS", "METRIX", &"noun")
