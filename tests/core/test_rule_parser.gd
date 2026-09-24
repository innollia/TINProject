extends GutTest


func _word(id: String, value: String, role: String, cell: Vector2i) -> RuleGridEntity:
	var entity := RuleGridEntity.new()
	entity.id = id
	entity.position = cell
	entity.word_value = StringName(value)
	entity.word_role = StringName(role)
	entity.is_word = true
	return entity


func _line(y: int = 0) -> Array[RuleGridEntity]:
	return [
		_word("noun", "LANTERN", "noun", Vector2i(0, y)),
		_word("is", "IS", "operator", Vector2i(1, y)),
		_word("property", "GLOW", "property", Vector2i(2, y))
	]


func test_parses_horizontal_and_vertical_property_sentences() -> void:
	var horizontal := RuleParser.parse(4, 3, _line())
	var vertical_words: Array[RuleGridEntity] = [
		_word("vertical_noun", "LANTERN", "noun", Vector2i(0, 0)),
		_word("vertical_is", "IS", "operator", Vector2i(0, 1)),
		_word("vertical_property", "GLOW", "property", Vector2i(0, 2))
	]
	var vertical := RuleParser.parse(4, 3, vertical_words)

	assert_eq(horizontal.sentences.size(), 1)
	assert_true(horizontal.has_property(&"LANTERN", &"GLOW"))
	assert_eq(horizontal.properties_for(&"LANTERN"), [&"GLOW"])
	assert_eq(vertical.sentences.size(), 1)
	assert_true(vertical.has_property(&"LANTERN", &"GLOW"))
	assert_eq(vertical.sentences[0].source_cells, [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)])


func test_ignores_broken_invalid_and_out_of_bounds_sentences() -> void:
	var broken := _line()
	broken[2].position = Vector2i(3, 0)
	var invalid_operator := _line()
	invalid_operator[1].word_value = &"ARE"
	var out_of_bounds := _line()
	out_of_bounds[2].position = Vector2i(4, 0)
	var with_null := _line()
	with_null.append(null)

	assert_eq(RuleParser.parse(4, 2, broken).sentences.size(), 0)
	assert_eq(RuleParser.parse(4, 2, invalid_operator).sentences.size(), 0)
	assert_eq(RuleParser.parse(4, 2, out_of_bounds).sentences.size(), 0)
	assert_eq(RuleParser.parse(4, 2, with_null).sentences.size(), 1)
	assert_eq(RuleParser.parse(0, 2, _line()).sentences.size(), 0)


func test_parses_noun_transform_and_deduplicates_overlapping_semantics() -> void:
	var words: Array[RuleGridEntity] = [
		_word("horizontal_lantern", "LANTERN", "noun", Vector2i(0, 1)),
		_word("horizontal_is", "IS", "operator", Vector2i(1, 1)),
		_word("horizontal_torch", "TORCH", "noun", Vector2i(2, 1)),
		_word("vertical_is", "IS", "operator", Vector2i(0, 2)),
		_word("vertical_glow", "GLOW", "property", Vector2i(0, 3))
	]
	var rules := RuleParser.parse(4, 4, words)

	assert_eq(rules.sentences.size(), 2)
	assert_eq(rules.transforms_for(&"LANTERN"), [&"TORCH"])
	assert_eq(rules.properties_for(&"LANTERN"), [&"GLOW"])

	words.append(_word("duplicate_lantern", "LANTERN", "noun", Vector2i(1, 0)))
	words.append(_word("duplicate_is", "IS", "operator", Vector2i(2, 0)))
	words.append(_word("duplicate_torch", "TORCH", "noun", Vector2i(3, 0)))
	var duplicated := RuleParser.parse(4, 4, words)
	assert_eq(duplicated.sentences.size(), 2)


func test_entity_order_does_not_change_parsed_rules() -> void:
	var words := _line()
	var forward := RuleParser.parse(4, 2, words)
	words.reverse()
	var reversed := RuleParser.parse(4, 2, words)

	assert_eq(forward.sentences.size(), reversed.sentences.size())
	assert_eq(forward.sentences[0].subject, reversed.sentences[0].subject)
	assert_eq(forward.sentences[0].predicate, reversed.sentences[0].predicate)
	assert_eq(forward.sentences[0].source_cells, reversed.sentences[0].source_cells)
	assert_eq(forward.sentences[0].source_entity_ids, reversed.sentences[0].source_entity_ids)


func test_parses_and_subject_and_predicate_conjunctions_with_not() -> void:
	var subject_words: Array[RuleGridEntity] = [
		_word("lantern", "LANTERN", "noun", Vector2i(0, 0)),
		_word("and", "AND", "operator", Vector2i(1, 0)),
		_word("torch", "TORCH", "noun", Vector2i(2, 0)),
		_word("is", "IS", "operator", Vector2i(3, 0)),
		_word("glow", "GLOW", "property", Vector2i(4, 0))
	]
	var subjects := RuleParser.parse(5, 1, subject_words)

	assert_eq(subjects.sentences.size(), 2)
	assert_true(subjects.has_property(&"LANTERN", &"GLOW"))
	assert_true(subjects.has_property(&"TORCH", &"GLOW"))
	assert_eq(subjects.sentences[0].source_entity_ids, ["lantern", "and", "torch", "is", "glow"])

	var predicate_words: Array[RuleGridEntity] = [
		_word("lantern", "LANTERN", "noun", Vector2i(0, 0)),
		_word("is", "IS", "operator", Vector2i(1, 0)),
		_word("glow", "GLOW", "property", Vector2i(2, 0)),
		_word("and", "AND", "operator", Vector2i(3, 0)),
		_word("not", "NOT", "operator", Vector2i(4, 0)),
		_word("dark", "DARK", "property", Vector2i(5, 0))
	]
	var predicates := RuleParser.parse(6, 1, predicate_words)

	assert_eq(predicates.sentences.size(), 2)
	assert_true(predicates.has_property(&"LANTERN", &"GLOW"))
	assert_false(predicates.has_property(&"LANTERN", &"DARK"))
	assert_true(predicates.sentences[1].is_negated)
	assert_eq(predicates.sentences[0].source_entity_ids.size(), 6)


func test_not_rule_removes_matching_positive_effect() -> void:
	var words: Array[RuleGridEntity] = [
		_word("positive_lantern", "LANTERN", "noun", Vector2i(0, 0)),
		_word("positive_is", "IS", "operator", Vector2i(1, 0)),
		_word("positive_push", "PUSH", "property", Vector2i(2, 0)),
		_word("negative_lantern", "LANTERN", "noun", Vector2i(0, 1)),
		_word("negative_is", "IS", "operator", Vector2i(1, 1)),
		_word("not", "NOT", "operator", Vector2i(2, 1)),
		_word("negative_push", "PUSH", "property", Vector2i(3, 1))
	]
	var rules := RuleParser.parse(4, 2, words)

	assert_eq(rules.sentences.size(), 2)
	assert_false(rules.has_property(&"LANTERN", &"PUSH"))
	assert_eq(rules.properties_for(&"LANTERN"), [])


func test_parses_conditions_and_tin_specific_sentences() -> void:
	var words: Array[RuleGridEntity] = [
		_word("on", "ON", "operator", Vector2i(0, 0)),
		_word("grass", "GRASS", "noun", Vector2i(1, 0)),
		_word("lantern", "LANTERN", "noun", Vector2i(2, 0)),
		_word("is", "IS", "operator", Vector2i(3, 0)),
		_word("glow", "GLOW", "property", Vector2i(4, 0)),
		_word("box", "BOX", "noun", Vector2i(5, 1)),
		_word("inside", "INSIDE", "operator", Vector2i(6, 1)),
		_word("inside_is", "IS", "operator", Vector2i(7, 1)),
		_word("metrix", "METRIX", "noun", Vector2i(8, 1)),
		_word("owner", "LANTERN", "noun", Vector2i(0, 2)),
		_word("owns", "OWNS", "operator", Vector2i(1, 2)),
		_word("owned_metrix", "METRIX", "noun", Vector2i(2, 2)),
		_word("owns_on", "ON", "operator", Vector2i(3, 2)),
		_word("owns_rock", "ROCK", "noun", Vector2i(4, 2))
	]
	var rules := RuleParser.parse(9, 3, words)
	var conditional: RuleSentence = rules.sentences[0]

	assert_eq(rules.sentences.size(), 3)
	assert_eq(conditional.subject, &"LANTERN")
	assert_eq(conditional.conditions, [{"kind": &"ON", "target": &"GRASS", "negated": false, "position": &"prefix"}])
	assert_eq(conditional.source_entity_ids, ["on", "grass", "lantern", "is", "glow"])
	assert_eq(rules.sentences[1].operator, &"INSIDE_IS")
	assert_eq(rules.sentences[1].predicate, &"METRIX")
	assert_eq(rules.sentences[2].operator, &"OWNS")
	assert_eq(rules.sentences[2].conditions, [{"kind": &"ON", "target": &"ROCK", "negated": false, "position": &"suffix"}])
	assert_eq(rules.sentences[2].source_entity_ids, ["owner", "owns", "owned_metrix", "owns_on", "owns_rock"])

	var has_words: Array[RuleGridEntity] = [
		_word("has_owner", "LANTERN", "noun", Vector2i(0, 0)),
		_word("has", "HAS", "operator", Vector2i(1, 0)),
		_word("has_target", "ROCK", "noun", Vector2i(2, 0))
	]
	var has_rules := RuleParser.parse(3, 1, has_words)
	assert_eq(has_rules.sentences.size(), 1)
	assert_eq(has_rules.sentences[0].operator, &"HAS")
	assert_eq(has_rules.sentences[0].predicate_role, &"noun")

	var infix_words: Array[RuleGridEntity] = [
		_word("infix_lantern", "LANTERN", "noun", Vector2i(0, 0)),
		_word("near", "NEAR", "operator", Vector2i(1, 0)),
		_word("infix_rock", "ROCK", "noun", Vector2i(2, 0)),
		_word("infix_is", "IS", "operator", Vector2i(3, 0)),
		_word("infix_glow", "GLOW", "property", Vector2i(4, 0))
	]
	var infix_rules := RuleParser.parse(5, 1, infix_words)
	assert_eq(infix_rules.sentences[0].conditions, [{"kind": &"NEAR", "target": &"ROCK", "negated": false, "position": &"infix"}])

	var facing_words: Array[RuleGridEntity] = [
		_word("facing", "FACING", "operator", Vector2i(0, 0)),
		_word("not_wall", "NOT", "operator", Vector2i(1, 0)),
		_word("wall", "WALL", "noun", Vector2i(2, 0)),
		_word("facing_lantern", "LANTERN", "noun", Vector2i(3, 0)),
		_word("facing_is", "IS", "operator", Vector2i(4, 0)),
		_word("facing_glow", "GLOW", "property", Vector2i(5, 0))
	]
	var facing_rules := RuleParser.parse(6, 1, facing_words)
	assert_eq(facing_rules.sentences.size(), 1)
	assert_eq(facing_rules.sentences[0].conditions, [{"kind": &"FACING", "target": &"WALL", "negated": true, "position": &"prefix"}])


func test_every_stacked_word_combination_is_parsed_and_duplicate_sources_merge() -> void:
	var words: Array[RuleGridEntity] = [
		_word("lantern", "LANTERN", "noun", Vector2i(0, 0)),
		_word("rock", "ROCK", "noun", Vector2i(0, 0)),
		_word("is", "IS", "operator", Vector2i(1, 0)),
		_word("glow", "GLOW", "property", Vector2i(2, 0)),
		_word("push", "PUSH", "property", Vector2i(2, 0)),
		_word("duplicate_lantern", "LANTERN", "noun", Vector2i(0, 1)),
		_word("duplicate_is", "IS", "operator", Vector2i(1, 1)),
		_word("duplicate_glow", "GLOW", "property", Vector2i(2, 1))
	]
	var rules := RuleParser.parse(3, 2, words)

	assert_eq(rules.sentences.size(), 4)
	assert_true(rules.has_property(&"LANTERN", &"GLOW"))
	assert_true(rules.has_property(&"ROCK", &"PUSH"))
	var lantern_glow: RuleSentence = null
	for sentence: RuleSentence in rules.sentences:
		if sentence.subject == &"LANTERN" and sentence.predicate == &"GLOW":
			lantern_glow = sentence
	assert_not_null(lantern_glow)
	assert_true(lantern_glow.source_entity_ids.has("lantern"))
	assert_true(lantern_glow.source_entity_ids.has("duplicate_lantern"))
	assert_true(lantern_glow.source_entity_ids.has("duplicate_glow"))


func test_word_property_objects_are_read_as_noun_tokens() -> void:
	var word_object := RuleGridEntity.new()
	word_object.id = "word_object"
	word_object.kind = &"LANTERN"
	word_object.position = Vector2i(0, 0)
	word_object.runtime_tags = [&"WORD"]
	var words: Array[RuleGridEntity] = [
		word_object,
		_word("is", "IS", "operator", Vector2i(1, 0)),
		_word("glow", "GLOW", "property", Vector2i(2, 0))
	]
	var rules := RuleParser.parse(3, 1, words)

	assert_true(rules.has_property(&"LANTERN", &"GLOW"))
	assert_eq(rules.sentences[0].source_entity_ids, ["word_object", "is", "glow"])
