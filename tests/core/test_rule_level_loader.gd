extends GutTest


func test_loads_both_authored_levels_and_roundtrips_json_state() -> void:
	var first := RuleLevelLoader.load_level(&"signal_room_01")
	var second := RuleLevelLoader.load_level(&"crossing_02")

	assert_true(first["ok"])
	assert_true(second["ok"])
	assert_eq(first["state"].width, 10)
	assert_eq(first["state"].height, 8)
	assert_ne(first["state"].entities.size(), second["state"].entities.size())
	var encoded: Dictionary = first["state"].to_dictionary()
	assert_true(SaveService.is_json_safe(encoded))
	var decoded := RuleGridState.from_dictionary(JSON.parse_string(JSON.stringify(encoded)))
	assert_not_null(decoded)
	assert_eq(decoded.to_dictionary(), encoded)

	var first_rules := RuleParser.parse(first["state"].width, first["state"].height, first["state"].entities)
	assert_true(first_rules.has_property(&"BABA", &"YOU"))
	assert_true(first_rules.has_property(&"ROCK", &"PUSH"))
	assert_true(first_rules.has_property(&"WALL", &"STOP"))
	assert_true(first_rules.has_property(&"FLAG", &"WIN"))


func test_rejects_unknown_ids_malformed_entities_and_duplicate_ids() -> void:
	assert_false(RuleLevelLoader.load_level(&"missing_level")["ok"])
	assert_false(RuleLevelLoader.parse_definition({"version": 2, "id": "broken", "title": "x", "width": 1, "height": 1, "entities": []})["ok"])
	assert_null(RuleGridState.from_dictionary({"width": 1, "height": 1, "entities": [
		{"id": "same", "kind": "BABA", "x": 0, "y": 0, "is_word": false},
		{"id": "same", "kind": "ROCK", "x": 0, "y": 0, "is_word": false}
	]}))
	assert_null(RuleGridEntity.from_dictionary({"id": "bad", "kind": "BABA", "x": 0.5, "y": 0, "is_word": false}))
