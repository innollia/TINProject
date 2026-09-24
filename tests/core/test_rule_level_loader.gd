extends GutTest


func test_index_keeps_authored_order_and_load_level_api_compatibility() -> void:
	var ids := RuleLevelLoader.list_level_ids()
	assert_eq(ids.size(), 16)
	assert_eq(ids[0], &"rule_01_open_gate")
	assert_eq(ids[14], &"signal_room_01")
	assert_eq(ids[15], &"crossing_02")

	var first := RuleLevelLoader.load_level(&"signal_room_01")
	var second := RuleLevelLoader.load_level(&"crossing_02")
	assert_true(first["ok"])
	assert_true(second["ok"])
	assert_eq(first["state"].width, 10)
	assert_eq(first["state"].height, 8)
	assert_ne(first["state"].entities.size(), second["state"].entities.size())
	assert_eq(first["schema_version"], 1)
	assert_eq(first["completion_condition"], "win_contact")

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


func test_entity_physical_fields_and_module_metadata_roundtrip_through_json() -> void:
	var state_data := {
		"schema_version": 1,
		"width": 32,
		"height": 32,
		"entities": [{
			"id": "door_north",
			"kind": "DOOR",
			"x": 31,
			"y": 0,
			"facing": [0, -1],
			"layer": -2,
			"creation_serial": 17,
			"is_word": false,
			"module_metadata": {"boundary": "north", "parts": [1, {"locked": false}]}
		}]
	}
	var state := RuleGridState.from_dictionary(state_data)
	assert_not_null(state)
	var entity: RuleGridEntity = state.entities[0]
	assert_eq(entity.position, Vector2i(31, 0))
	assert_eq(entity.facing, Vector2i(0, -1))
	assert_eq(entity.layer, -2)
	assert_eq(entity.creation_serial, 17)
	assert_eq(entity.module_metadata["boundary"], "north")

	var encoded: Dictionary = state.to_dictionary()
	var decoded := RuleGridState.from_dictionary(JSON.parse_string(JSON.stringify(encoded)))
	assert_not_null(decoded)
	assert_eq(decoded.to_dictionary(), encoded)
	assert_eq(decoded.entities[0].module_metadata, entity.module_metadata)


func test_rejects_unknown_ids_bad_schema_and_malformed_entities() -> void:
	assert_false(RuleLevelLoader.load_level(&"missing_level")["ok"])
	assert_false(RuleLevelLoader.load_level(&"../signal_room_01")["ok"])
	assert_false(RuleLevelLoader.parse_definition({"version": 2, "id": "broken", "title": "x", "width": 1, "height": 1, "entities": []})["ok"])
	assert_false(RuleLevelLoader.parse_definition({"schema_version": 1, "id": "bad/id", "title": "x", "width": 1, "height": 1, "entities": [], "starts_in_3d": false, "completion_condition": "win_contact", "art_recipe_id": "basic"})["ok"])
	assert_false(RuleLevelLoader.parse_definition({"schema_version": 1, "version": 1, "id": "mixed", "title": "x", "width": 1, "height": 1, "entities": [], "starts_in_3d": false, "completion_condition": "win_contact", "art_recipe_id": "basic"})["ok"])
	assert_false(RuleLevelLoader.parse_definition(_new_board(1, 1, "x", "wrong_condition"))["ok"])
	assert_null(RuleGridState.from_dictionary({"schema_version": 2, "width": 1, "height": 1, "entities": []}))
	assert_null(RuleGridState.from_dictionary({"width": 1, "height": 1, "entities": [
		{"id": "same", "kind": "BABA", "x": 0, "y": 0, "is_word": false},
		{"id": "same", "kind": "ROCK", "x": 0, "y": 0, "is_word": false}
	]}))
	assert_null(RuleGridEntity.from_dictionary({"id": "bad", "kind": "BABA", "x": 0.5, "y": 0, "is_word": false}))
	assert_null(RuleGridEntity.from_dictionary({"id": "bad/id", "kind": "BABA", "x": 0, "y": 0, "is_word": false}))
	assert_null(RuleGridEntity.from_dictionary({"id": "bad_metadata", "kind": "BABA", "x": 0, "y": 0, "is_word": false, "module_metadata": {"resource": RefCounted.new()}}))


func test_grid_dimensions_allow_32_by_32_and_reject_33() -> void:
	var valid := RuleLevelLoader.parse_definition(_new_board(32, 32))
	assert_true(valid["ok"])
	assert_eq(valid["state"].width, 32)
	assert_eq(valid["state"].height, 32)
	assert_false(RuleLevelLoader.parse_definition(_new_board(33, 32))["ok"])
	assert_false(RuleLevelLoader.parse_definition(_new_board(32, 33))["ok"])
	var duplicate_serials := _new_board(2, 2)
	duplicate_serials["entities"] = [
		{"id": "baba", "kind": "BABA", "x": 0, "y": 0, "is_word": false, "creation_serial": 4},
		{"id": "rock", "kind": "ROCK", "x": 1, "y": 0, "is_word": false, "creation_serial": 4}
	]
	assert_false(RuleLevelLoader.parse_definition(duplicate_serials)["ok"])


func test_authored_words_and_object_kinds_must_be_registered() -> void:
	var unknown_word := _new_board(2, 2)
	unknown_word["entities"] = [{
		"id": "unknown_word",
		"kind": "CUSTOM",
		"x": 0,
		"y": 0,
		"is_word": true,
		"word_role": "noun",
		"word_value": "CUSTOM"
	}]
	assert_false(RuleLevelLoader.parse_definition(unknown_word)["ok"])

	var unknown_object := _new_board(2, 2)
	unknown_object["entities"] = [{"id": "custom_object", "kind": "CUSTOM", "x": 0, "y": 0, "is_word": false}]
	assert_false(RuleLevelLoader.parse_definition(unknown_object)["ok"])

	var registered_condition := _new_board(2, 2)
	registered_condition["entities"] = [{
		"id": "word_facing",
		"kind": "FACING",
		"x": 0,
		"y": 0,
		"is_word": true,
		"word_role": "operator",
		"word_value": "FACING"
	}]
	assert_true(RuleLevelLoader.parse_definition(registered_condition)["ok"])


func test_door_metadata_must_match_a_valid_box_frame_side() -> void:
	assert_true(RuleLevelLoader.parse_definition(_door_frame("north"))["ok"])
	assert_false(RuleLevelLoader.parse_definition(_door_frame("south"))["ok"])
	assert_false(RuleLevelLoader.parse_definition(_door_frame(""))["ok"])

	var broken_frame := _door_frame("north")
	broken_frame["entities"].erase(_entity("box_top_1", "BOX", 1, 0))
	assert_false(RuleLevelLoader.parse_definition(broken_frame)["ok"])


func test_index_rejects_bad_schema_ids_duplicates_and_path_traversal() -> void:
	var valid := RuleLevelLoader.parse_index({
		"schema_version": 1,
		"boards": [
			{"id": "first_board", "path": "boards/first.json"},
			{"id": "second_board", "path": "second.json"}
		]
	})
	assert_true(valid["ok"])
	assert_eq(valid["entries"][0]["id"], "first_board")
	assert_false(RuleLevelLoader.parse_index({"schema_version": 2, "boards": [{"id": "a", "path": "a.json"}]})["ok"])
	assert_false(RuleLevelLoader.parse_index({"schema_version": 1, "boards": [{"id": "Bad ID", "path": "a.json"}]})["ok"])
	assert_false(RuleLevelLoader.parse_index({"schema_version": 1, "boards": [
		{"id": "same", "path": "one.json"},
		{"id": "same", "path": "two.json"}
	]})["ok"])
	assert_false(RuleLevelLoader.parse_index({"schema_version": 1, "boards": [{"id": "unsafe", "path": "../outside.json"}]})["ok"])


func _new_board(width: int, height: int, board_id: String = "test_board", condition: String = "win_contact") -> Dictionary:
	return {
		"schema_version": 1,
		"id": board_id,
		"title": "Test Board",
		"width": width,
		"height": height,
		"entities": [],
		"starts_in_3d": false,
		"completion_condition": condition,
		"art_recipe_id": "test_recipe"
	}


func _door_frame(boundary: String) -> Dictionary:
	var entities: Array[Dictionary] = []
	for x: int in range(5):
		if x == 2:
			var metadata: Dictionary = {} if boundary.is_empty() else {"boundary": boundary}
			entities.append(_entity("door_north", "DOOR", x, 0, metadata))
		else:
			entities.append(_entity("box_top_%d" % x, "BOX", x, 0))
	entities.append(_entity("box_left_mid", "BOX", 0, 1))
	entities.append(_entity("box_right_mid", "BOX", 4, 1))
	for x: int in range(5):
		entities.append(_entity("box_bottom_%d" % x, "BOX", x, 2))
	var board := _new_board(5, 3)
	board["entities"] = entities
	return board


func _entity(id: String, kind: String, x: int, y: int, module_metadata: Dictionary = {}) -> Dictionary:
	var entity := {"id": id, "kind": kind, "x": x, "y": y, "is_word": false}
	if not module_metadata.is_empty():
		entity["module_metadata"] = module_metadata
	return entity
