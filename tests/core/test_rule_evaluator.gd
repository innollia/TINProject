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


func test_conditioned_property_is_evaluated_per_entity_and_applies_negation() -> void:
	var on_water := _entity("on_water", &"PERSON", Vector2i(1, 1))
	var dry := _entity("dry", &"PERSON", Vector2i(3, 1))
	var water := _entity("water", &"WATER", Vector2i(1, 1))
	var state := _state([on_water, dry, water])
	var rules := RuleSet.new()
	rules.add(_property_rule(&"PERSON", &"YOU"))
	var negated_when_wet := _property_rule(&"PERSON", &"YOU")
	negated_when_wet.conditions.append({
		"kind": &"ON", "target": &"WATER", "negated": false, "position": &"infix"
	})
	negated_when_wet.is_negated = true
	rules.add(negated_when_wet)

	assert_false(RuleEvaluator.has_property(on_water, &"YOU", rules, state))
	assert_true(RuleEvaluator.has_property(dry, &"YOU", rules, state))


func test_near_and_facing_conditions_use_per_entity_position_and_direction() -> void:
	var person := _entity("person", &"PERSON", Vector2i(1, 1))
	person.facing = Vector2i.RIGHT
	var diagonal_wall := _entity("diagonal_wall", &"WALL", Vector2i(2, 2))
	var front_rock := _entity("front_rock", &"ROCK", Vector2i(2, 1))
	var state := _state([person, diagonal_wall, front_rock])
	var near_rule := _property_rule(&"PERSON", &"YOU")
	near_rule.conditions.append({
		"kind": &"NEAR", "target": &"WALL", "negated": false, "position": &"infix"
	})
	var facing_rule := _property_rule(&"PERSON", &"PUSH")
	facing_rule.conditions.append({
		"kind": &"FACING", "target": &"ROCK", "negated": false, "position": &"infix"
	})
	var rules := RuleSet.new()
	rules.add(near_rule)
	rules.add(facing_rule)

	assert_true(RuleEvaluator.has_property(person, &"YOU", rules, state))
	assert_true(RuleEvaluator.has_property(person, &"PUSH", rules, state))
	front_rock.position = Vector2i(4, 1)
	assert_false(RuleEvaluator.has_property(person, &"PUSH", rules, state))
	person.facing = Vector2i.UP
	assert_false(RuleEvaluator.has_property(person, &"PUSH", rules, state))


func test_conditioned_transformation_only_changes_matching_physical_entities() -> void:
	var wet_lamp := _entity("wet_lamp", &"LAMP", Vector2i(1, 1))
	var dry_lamp := _entity("dry_lamp", &"LAMP", Vector2i(3, 1))
	var water := _entity("water", &"WATER", Vector2i(1, 1))
	var state := _state([wet_lamp, dry_lamp, water])
	var conditional_transform := _transform(&"LAMP", &"ROCK")
	conditional_transform.conditions.append({
		"kind": &"ON", "target": &"WATER", "negated": false, "position": &"infix"
	})
	var rules := RuleSet.new()
	rules.add(conditional_transform)

	var result := RuleEvaluator.apply_transformations(state, rules)
	assert_true(result["valid"])
	assert_eq(wet_lamp.kind, &"ROCK")
	assert_eq(dry_lamp.kind, &"LAMP")
	assert_eq(result["created_ids"], [])


func test_transformed_clones_preserve_layer_tags_and_metadata_with_new_creation_order() -> void:
	var lamp := _entity("lamp", &"LAMP", Vector2i(2, 1))
	lamp.layer = 3
	lamp.creation_serial = 20
	lamp.base_tags = [&"BASE"]
	lamp.runtime_tags = [&"WORD"]
	lamp.module_metadata = {"nested": {"count": 4}, "flags": ["kept"]}
	var other := _entity("other", &"OTHER", Vector2i.ZERO)
	other.creation_serial = 30
	var state := _state([other, lamp])
	var rules := RuleSet.new()
	rules.add(_transform(&"LAMP", &"BIRD"))
	rules.add(_transform(&"LAMP", &"ROCK"))

	var result := RuleEvaluator.apply_transformations(state, rules)
	assert_true(result["valid"])
	assert_eq(result["created_ids"], ["transform::lamp::ROCK"])
	var clone: RuleGridEntity = null
	for entity: RuleGridEntity in state.entities:
		if entity.id == "transform::lamp::ROCK":
			clone = entity
	assert_not_null(clone)
	assert_eq(clone.layer, 3)
	assert_eq(clone.creation_serial, 31)
	assert_eq(clone.base_tags, [&"BASE"])
	assert_eq(clone.runtime_tags, [&"WORD"])
	assert_eq(clone.module_metadata, lamp.module_metadata)
	clone.module_metadata["nested"]["count"] = 9
	assert_eq(lamp.module_metadata["nested"]["count"], 4)


func test_contact_removals_cover_sink_hot_melt_open_shut_weak_and_safe() -> void:
	var entities: Array[RuleGridEntity] = [
		_entity("melt", &"MELT_ITEM", Vector2i(0, 0)),
		_entity("hot", &"HOT_ITEM", Vector2i(0, 0)),
		_entity("safe_melt", &"SAFE_MELT", Vector2i(1, 0)),
		_entity("safe_hot", &"SAFE_HOT", Vector2i(1, 0)),
		_entity("open", &"OPEN_ITEM", Vector2i(2, 0)),
		_entity("shut", &"SHUT_ITEM", Vector2i(2, 0)),
		_entity("sinker", &"SINKER", Vector2i(3, 0)),
		_entity("safe_rock", &"SAFE_ROCK", Vector2i(3, 0)),
		_entity("safe_sinker", &"SAFE_SINKER", Vector2i(4, 0)),
		_entity("rock", &"ROCK", Vector2i(4, 0)),
		_entity("weak", &"WEAK_ITEM", Vector2i(0, 1)),
		_entity("decoration", &"DECORATION", Vector2i(0, 1))
	]
	var state := _state(entities)
	var rules := RuleSet.new()
	rules.add(_property_rule(&"MELT_ITEM", &"MELT"))
	rules.add(_property_rule(&"HOT_ITEM", &"HOT"))
	rules.add(_property_rule(&"SAFE_MELT", &"MELT"))
	rules.add(_property_rule(&"SAFE_MELT", &"SAFE"))
	rules.add(_property_rule(&"SAFE_HOT", &"HOT"))
	rules.add(_property_rule(&"OPEN_ITEM", &"OPEN"))
	rules.add(_property_rule(&"SHUT_ITEM", &"SHUT"))
	rules.add(_property_rule(&"SHUT_ITEM", &"SAFE"))
	rules.add(_property_rule(&"SINKER", &"SINK"))
	rules.add(_property_rule(&"SAFE_ROCK", &"SAFE"))
	rules.add(_property_rule(&"SAFE_SINKER", &"SINK"))
	rules.add(_property_rule(&"SAFE_SINKER", &"SAFE"))
	rules.add(_property_rule(&"WEAK_ITEM", &"WEAK"))

	var result := RuleEvaluator.resolve_contacts(state, rules)
	var removed: Array = result["removed_ids"]

	assert_true(result["valid"])
	assert_has(removed, "melt")
	assert_does_not_have(removed, "safe_melt")
	assert_has(removed, "open")
	assert_does_not_have(removed, "shut")
	assert_true(removed.has("sinker"))
	assert_false(removed.has("safe_rock"))
	assert_false(removed.has("safe_sinker"))
	assert_true(removed.has("rock"))
	assert_has(removed, "weak")
	assert_does_not_have(removed, "decoration")


func test_float_separates_contact_layers() -> void:
	var melt := _entity("melt", &"MELT_ITEM", Vector2i(1, 1))
	var hot := _entity("hot", &"HOT_ITEM", Vector2i(1, 1))
	var state := _state([melt, hot])
	var rules := RuleSet.new()
	rules.add(_property_rule(&"MELT_ITEM", &"MELT"))
	rules.add(_property_rule(&"HOT_ITEM", &"HOT"))
	rules.add(_property_rule(&"HOT_ITEM", &"FLOAT"))

	assert_false(RuleEvaluator.entities_interact(melt, hot, rules, state))
	assert_eq(RuleEvaluator.resolve_contacts(state, rules)["removed_ids"], [])
	rules.add(_property_rule(&"MELT_ITEM", &"FLOAT"))
	assert_true(RuleEvaluator.entities_interact(melt, hot, rules, state))
	assert_has(RuleEvaluator.resolve_contacts(state, rules)["removed_ids"], "melt")


func test_defeat_precedes_win_and_failure_requires_losing_every_you() -> void:
	var defeated_you := _entity("you_a", &"PERSON", Vector2i(0, 1))
	var skull := _entity("skull", &"SKULL", Vector2i(0, 1))
	var surviving_you := _entity("you_b", &"PERSON", Vector2i(2, 1))
	var flag := _entity("flag", &"FLAG", Vector2i(2, 1))
	var state := _state([flag, surviving_you, skull, defeated_you])
	var rules := RuleSet.new()
	rules.add(_property_rule(&"PERSON", &"YOU"))
	rules.add(_property_rule(&"SKULL", &"DEFEAT"))
	rules.add(_property_rule(&"FLAG", &"WIN"))

	var partial := RuleEvaluator.resolve_contacts(state, rules)
	assert_eq(partial["defeated_ids"], ["you_a"])
	assert_eq(partial["surviving_you_ids"], ["you_b"])
	assert_true(partial["won"])
	assert_false(partial["failed"])

	surviving_you.position = skull.position
	flag.position = skull.position
	var last_you := RuleEvaluator.resolve_contacts(state, rules)
	assert_eq(last_you["defeated_ids"], ["you_a", "you_b"])
	assert_true(last_you["surviving_you_ids"].is_empty())
	assert_false(last_you["won"])
	assert_true(last_you["failed"])


func test_losing_the_final_you_to_sink_enters_failure_state() -> void:
	var you := _entity("you", &"PERSON", Vector2i(1, 1))
	var sink := _entity("sink", &"WATER", Vector2i(1, 1))
	var state := _state([you, sink])
	var rules := RuleSet.new()
	rules.add(_property_rule(&"PERSON", &"YOU"))
	rules.add(_property_rule(&"WATER", &"SINK"))

	var result := RuleEvaluator.resolve_contacts(state, rules)

	assert_true(result["valid"])
	assert_has(result["removed_ids"], "you")
	assert_true(result["surviving_you_ids"].is_empty())
	assert_true(result["failed"])


func test_matching_noun_word_does_not_survive_as_a_physical_you() -> void:
	var you := _entity("you", &"PERSON", Vector2i(1, 1))
	var sink := _entity("sink", &"WATER", Vector2i(1, 1))
	var person_word := _entity("person_word", &"PERSON", Vector2i(0, 0), true)
	var state := _state([you, sink, person_word])
	var rules := RuleSet.new()
	rules.add(_property_rule(&"PERSON", &"YOU"))
	rules.add(_property_rule(&"WATER", &"SINK"))

	var result := RuleEvaluator.resolve_contacts(state, rules)

	assert_has(result["removed_ids"], "you")
	assert_false(result["removed_ids"].has("person_word"))
	assert_true(result["surviving_you_ids"].is_empty())
	assert_true(result["failed"])


func test_removed_has_owner_returns_sorted_spawn_descriptors() -> void:
	var moth := _entity("moth", &"MOTH", Vector2i(1, 1))
	moth.facing = Vector2i.LEFT
	moth.layer = 2
	var other_moth := _entity("other_moth", &"MOTH", Vector2i(3, 1))
	var sink := _entity("sink", &"WATER", Vector2i(1, 1))
	var pool := _entity("pool", &"POOL", Vector2i(1, 1))
	var state := _state([other_moth, pool, sink, moth])
	var rules := RuleSet.new()
	rules.add(_property_rule(&"WATER", &"SINK"))
	rules.add(_has_rule(&"MOTH", &"ROCK"))
	rules.add(_has_rule(&"MOTH", &"KEY"))
	rules.add(_has_rule(&"MOTH", &"GLASS"))
	var suppress_glass := _has_rule(&"MOTH", &"GLASS")
	suppress_glass.is_negated = true
	rules.add(suppress_glass)
	var has_lamp_on_pool := _has_rule(&"MOTH", &"LAMP")
	has_lamp_on_pool.conditions.append({
		"kind": &"ON", "target": &"POOL", "negated": false, "position": &"suffix"
	})
	rules.add(has_lamp_on_pool)

	var result := RuleEvaluator.resolve_contacts(state, rules)
	var spawns: Array[Dictionary] = result["has_spawns"]

	assert_true(result["valid"])
	assert_eq(spawns.size(), 3)
	assert_eq(spawns.map(func(spawn: Dictionary) -> String: return spawn["kind"]), ["KEY", "LAMP", "ROCK"])
	for spawn: Dictionary in spawns:
		assert_eq(spawn["source_id"], moth.id)
		assert_eq(spawn["position"], moth.position)
		assert_eq(spawn["facing"], moth.facing)
		assert_eq(spawn["layer"], moth.layer)


func _has_rule(subject: StringName, noun: StringName) -> RuleSentence:
	return RuleSentence.new(subject, &"HAS", noun, &"noun")


func _property_rule(subject: StringName, property: StringName) -> RuleSentence:
	return RuleSentence.new(subject, &"IS", property, &"property")
