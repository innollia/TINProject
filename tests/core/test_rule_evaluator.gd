extends GutTest


func _entity(entity_id: String, kind: StringName, cell: Vector2i, is_word: bool = false) -> RuleGridEntity:
	var entity := RuleGridEntity.new()
	entity.id = entity_id
	entity.kind = kind
	entity.position = cell
	entity.is_word = is_word
	if is_word:
		entity.word_role = &"noun"
		entity.word_value = kind
	return entity


func _transform(source: StringName, target: StringName) -> RuleSentence:
	return RuleSentence.new(source, &"IS", target, &"noun")


func _state(entities: Array[RuleGridEntity]) -> RuleGridState:
	var state := RuleGridState.new()
	state.width = 5
	state.height = 3
	state.entities.assign(entities)
	return state


func test_single_transform_changes_objects_but_never_word_tokens_or_chains() -> void:
	var lamp := _entity("lamp", &"LAMP", Vector2i(1, 1))
	var word_lamp := _entity("word_lamp", &"LAMP", Vector2i(0, 0), true)
	var state := _state([lamp, word_lamp])
	var rules := RuleSet.new()
	rules.add(_transform(&"LAMP", &"ROCK"))
	rules.add(_transform(&"ROCK", &"FLAG"))
	var processed: Dictionary = {}

	var result := RuleEvaluator.apply_transformations(state, rules, processed)

	assert_true(result["valid"])
	assert_eq(lamp.kind, &"ROCK")
	assert_eq(word_lamp.kind, &"LAMP")
	assert_eq(state.entities.size(), 2)
	assert_true(processed.has("lamp"))
	result = RuleEvaluator.apply_transformations(state, rules, processed)
	assert_eq(lamp.kind, &"ROCK")
	assert_eq(state.entities.size(), 2)


func test_multiple_outputs_keep_stable_kind_and_create_stable_object_id() -> void:
	var lamp := _entity("lamp", &"LAMP", Vector2i(2, 1))
	var state := _state([lamp])
	var rules := RuleSet.new()
	rules.add(_transform(&"LAMP", &"ROCK"))
	rules.add(_transform(&"LAMP", &"BIRD"))
	var result := RuleEvaluator.apply_transformations(state, rules)

	assert_true(result["valid"])
	assert_eq(lamp.kind, &"BIRD")
	assert_eq(result["created_ids"], ["transform::lamp::ROCK"])
	assert_eq(state.entities.size(), 2)
	var clone: RuleGridEntity = state.entities[1] if state.entities[1].id == "transform::lamp::ROCK" else state.entities[0]
	assert_eq(clone.kind, &"ROCK")
	assert_eq(clone.position, Vector2i(2, 1))
	assert_eq(clone.facing, Vector2i.RIGHT)


func test_multiple_outputs_are_independent_of_rule_insertion_order() -> void:
	var first_state := _state([_entity("lamp", &"LAMP", Vector2i.ZERO)])
	var second_state := _state([_entity("lamp", &"LAMP", Vector2i.ZERO)])
	var first_rules := RuleSet.new()
	first_rules.add(_transform(&"LAMP", &"ROCK"))
	first_rules.add(_transform(&"LAMP", &"BIRD"))
	var second_rules := RuleSet.new()
	second_rules.add(_transform(&"LAMP", &"BIRD"))
	second_rules.add(_transform(&"LAMP", &"ROCK"))

	RuleEvaluator.apply_transformations(first_state, first_rules)
	RuleEvaluator.apply_transformations(second_state, second_rules)

	assert_eq(first_state.to_dictionary(), second_state.to_dictionary())
