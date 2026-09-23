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
