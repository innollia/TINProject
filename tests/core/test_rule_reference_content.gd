extends GutTest

const REFERENCE_IDS: Array[StringName] = [&"rule_01_open_gate", &"rule_02_shift_win", &"rule_03_pit_and_chain", &"rule_04_second_runner", &"rule_05_word_seed", &"rule_06_key_from_risk", &"rule_07_moving_gate", &"rule_08_safe_crossing", &"rule_09_first_metrix", &"rule_10_shared_frames", &"rule_11_metrix_storage", &"rule_12_wall_alignment", &"rule_13_hotbar_phrase", &"rule_14_owner_focus"]


func test_reference_sequence_loads_in_authored_order_with_legacy_entries_preserved() -> void:
	var ids := RuleLevelLoader.list_level_ids()
	assert_eq(ids.size(), 16)
	for index: int in range(REFERENCE_IDS.size()):
		assert_eq(ids[index], REFERENCE_IDS[index])
	assert_eq(ids[14], &"signal_room_01")
	assert_eq(ids[15], &"crossing_02")
	for level_id: StringName in REFERENCE_IDS:
		var loaded := RuleLevelLoader.load_level(level_id)
		assert_true(loaded["ok"], "failed to load %s" % level_id)
		assert_eq(loaded["schema_version"], 1)
		assert_eq(loaded["completion_condition"], "win_contact")
		assert_false(String(loaded["art_recipe_id"]).is_empty())
		assert_true(loaded["state"].width <= 18)
		assert_true(loaded["state"].height <= 14)
		_assert_unique_entity_ids(loaded["state"].entities)


func test_authored_rule_words_occupy_the_declared_cells() -> void:
	_assert_line(&"rule_01_open_gate", Vector2i(1, 1), Vector2i.RIGHT, ["MOTH", "IS", "YOU"])
	_assert_line(&"rule_02_shift_win", Vector2i(4, 2), Vector2i.RIGHT, ["LANTERN", "IS"])
	_assert_line(&"rule_02_shift_win", Vector2i(4, 3), Vector2i.RIGHT, ["PEARL", "IS", "WIN"])
	_assert_line(&"rule_02_shift_win", Vector2i(1, 4), Vector2i.RIGHT, ["WALL", "IS", "STOP"])
	_assert_line(&"rule_03_pit_and_chain", Vector2i(1, 1), Vector2i.RIGHT, ["MOTH", "IS", "YOU", "AND", "NOT", "SINK"])
	_assert_line(&"rule_04_second_runner", Vector2i(1, 1), Vector2i.RIGHT, ["MOTH", "IS", "YOU"])
	_assert_line(&"rule_04_second_runner", Vector2i(1, 2), Vector2i.RIGHT, ["LARK", "IS", "YOU"])
	_assert_line(&"rule_04_second_runner", Vector2i(5, 3), Vector2i.RIGHT, ["BELL", "IS"])
	_assert_line(&"rule_04_second_runner", Vector2i(7, 4), Vector2i.RIGHT, ["WIN"])
	_assert_line(&"rule_05_word_seed", Vector2i(1, 1), Vector2i.RIGHT, ["INK", "IS", "MOTH", "AND", "LAMP"])
	_assert_line(&"rule_06_key_from_risk", Vector2i(1, 3), Vector2i.RIGHT, ["MOTH", "HAS", "KEY"])
	_assert_line(&"rule_07_moving_gate", Vector2i(1, 2), Vector2i.RIGHT, ["TURNER", "IS", "MOVE"])
	_assert_line(&"rule_07_moving_gate", Vector2i(1, 3), Vector2i.RIGHT, ["TURNER", "IS", "SHIFT"])
	_assert_line(&"rule_08_safe_crossing", Vector2i(1, 2), Vector2i.RIGHT, ["ON", "PAD", "MOTH", "IS", "SAFE"])
	_assert_line(&"rule_09_first_metrix", Vector2i(5, 2), Vector2i.RIGHT, ["BOX", "INSIDE", "IS"])
	_assert_word_at(&"rule_09_first_metrix", Vector2i(9, 2), "METRIX")
	_assert_line(&"rule_09_first_metrix", Vector2i(1, 4), Vector2i.RIGHT, ["BOX", "IS", "STOP"])
	_assert_word_at(&"rule_11_metrix_storage", Vector2i(1, 2), "METRIX")
	_assert_word_at(&"rule_11_metrix_storage", Vector2i(2, 2), "IS")
	_assert_word_at(&"rule_11_metrix_storage", Vector2i(4, 2), "INV")
	_assert_line(&"rule_12_wall_alignment", Vector2i(1, 3), Vector2i.RIGHT, ["CORE", "IS", "STOP"])
	_assert_line(&"rule_13_hotbar_phrase", Vector2i(4, 3), Vector2i.RIGHT, ["ROCK", "IS", "WORD"])
	_assert_word_at(&"rule_13_hotbar_phrase", Vector2i(1, 1), "MOTH")
	_assert_word_at(&"rule_13_hotbar_phrase", Vector2i(1, 2), "IS")
	_assert_word_at(&"rule_13_hotbar_phrase", Vector2i(1, 4), "3D")
	_assert_line(&"rule_14_owner_focus", Vector2i(1, 2), Vector2i.RIGHT, ["MOTH", "OWNS", "METRIX", "ON", "EMBER"])
	_assert_line(&"rule_14_owner_focus", Vector2i(1, 3), Vector2i.RIGHT, ["LARK", "OWNS", "METRIX", "ON", "GLASS"])
	_assert_line(&"rule_14_owner_focus", Vector2i(1, 4), Vector2i.RIGHT, ["METRIX", "IS", "ACTIVE", "ON", "EMBER"])
	_assert_line(&"rule_14_owner_focus", Vector2i(1, 10), Vector2i.DOWN, ["BOX", "INSIDE", "IS", "METRIX"])


func test_metrix_doors_replace_non_corner_boundary_cells() -> void:
	_assert_door(&"rule_09_first_metrix", Vector2i(9, 4))
	_assert_door(&"rule_11_metrix_storage", Vector2i(9, 5))
	_assert_door(&"rule_11_metrix_storage", Vector2i(9, 10), "south")
	_assert_door(&"rule_12_wall_alignment", Vector2i(5, 8), "west")
	_assert_door(&"rule_10_shared_frames", Vector2i(3, 8), "west")
	_assert_door(&"rule_13_hotbar_phrase", Vector2i(11, 6))
	_assert_door(&"rule_14_owner_focus", Vector2i(6, 8))
	_assert_door(&"rule_14_owner_focus", Vector2i(15, 8))
	_assert_box_frame(&"rule_09_first_metrix", Vector2i(7, 4), Vector2i(12, 9), Vector2i(9, 4))
	_assert_box_frame(&"rule_11_metrix_storage", Vector2i(7, 5), Vector2i(12, 10), Vector2i(9, 5), Vector2i(9, 10))
	_assert_box_frame(&"rule_12_wall_alignment", Vector2i(5, 6), Vector2i(9, 10), Vector2i(5, 8))
	_assert_box_frame(&"rule_13_hotbar_phrase", Vector2i(9, 6), Vector2i(14, 11), Vector2i(11, 6))
	_assert_box_frame(&"rule_14_owner_focus", Vector2i(4, 8), Vector2i(9, 13), Vector2i(6, 8))
	_assert_box_frame(&"rule_14_owner_focus", Vector2i(12, 8), Vector2i(17, 13), Vector2i(15, 8))


func test_shared_wall_cells_are_authored_once() -> void:
	var loaded := RuleLevelLoader.load_level(&"rule_10_shared_frames")
	assert_true(loaded["ok"])
	for cell: Vector2i in [Vector2i(7, 7), Vector2i(7, 8), Vector2i(7, 9)]:
		assert_eq(_at(loaded["state"].entities, cell, &"BOX").size(), 1)
	assert_eq(_at(loaded["state"].entities, Vector2i(3, 5), &"BOX").size(), 1)
	assert_eq(_at(loaded["state"].entities, Vector2i(11, 11), &"BOX").size(), 1)
	_assert_box_frame(&"rule_10_shared_frames", Vector2i(3, 5), Vector2i(7, 9), Vector2i(3, 8))
	_assert_box_frame(&"rule_10_shared_frames", Vector2i(7, 7), Vector2i(11, 11))


func test_owner_active_3d_vocabulary_is_in_reference_data() -> void:
	var loaded := RuleLevelLoader.load_level(&"rule_14_owner_focus")
	assert_true(loaded["ok"])
	assert_true(loaded["starts_in_3d"])
	_assert_line(&"rule_14_owner_focus", Vector2i(1, 8), Vector2i.RIGHT, ["MOTH", "IS", "3D"])
	_assert_line(&"rule_14_owner_focus", Vector2i(1, 9), Vector2i.RIGHT, ["LARK", "IS", "3D"])
	_assert_line(&"rule_14_owner_focus", Vector2i(1, 5), Vector2i.RIGHT, ["METRIX", "IS", "ACTIVE", "ON"])


func _assert_unique_entity_ids(entities: Array[RuleGridEntity]) -> void:
	var seen: Dictionary = {}
	for entity: RuleGridEntity in entities:
		assert_false(entity.id.is_empty())
		assert_false(seen.has(entity.id), "duplicate entity ID: %s" % entity.id)
		seen[entity.id] = true


func _assert_line(level_id: StringName, start: Vector2i, step: Vector2i, tokens: Array) -> void:
	var loaded := RuleLevelLoader.load_level(level_id)
	assert_true(loaded["ok"])
	for index: int in range(tokens.size()):
		var cell: Vector2i = start + step * index
		var found := false
		for entity: RuleGridEntity in loaded["state"].entities:
			if entity.is_word and entity.position == cell and entity.word_value == StringName(tokens[index]):
				found = true
				break
		assert_true(found, "%s missing %s at %s" % [level_id, tokens[index], cell])


func _assert_door(level_id: StringName, cell: Vector2i, boundary: String = "north") -> void:
	var loaded := RuleLevelLoader.load_level(level_id)
	assert_true(loaded["ok"])
	assert_eq(_at(loaded["state"].entities, cell, &"DOOR").size(), 1)
	var edge_neighbors: Array[Vector2i] = []
	if boundary in ["north", "south"]:
		edge_neighbors.append(Vector2i.LEFT)
		edge_neighbors.append(Vector2i.RIGHT)
	else:
		edge_neighbors.append(Vector2i.UP)
		edge_neighbors.append(Vector2i.DOWN)
	for direction: Vector2i in edge_neighbors:
		assert_eq(_at(loaded["state"].entities, cell + direction, &"BOX").size(), 1)
	assert_eq(_at(loaded["state"].entities, cell, &"DOOR")[0].module_metadata.get("boundary", ""), boundary)


func _assert_word_at(level_id: StringName, cell: Vector2i, value: String) -> void:
	var loaded := RuleLevelLoader.load_level(level_id)
	assert_true(loaded["ok"])
	var found := false
	for entity: RuleGridEntity in loaded["state"].entities:
		if entity.is_word and entity.position == cell and entity.word_value == StringName(value):
			found = true
			break
	assert_true(found, "%s missing %s at %s" % [level_id, value, cell])


func _assert_box_frame(level_id: StringName, top_left: Vector2i, bottom_right: Vector2i, door: Vector2i = Vector2i(-1, -1), second_door: Vector2i = Vector2i(-1, -1)) -> void:
	var loaded := RuleLevelLoader.load_level(level_id)
	assert_true(loaded["ok"])
	for y: int in range(top_left.y, bottom_right.y + 1):
		for x: int in range(top_left.x, bottom_right.x + 1):
			var cell := Vector2i(x, y)
			var is_boundary: bool = x == top_left.x or x == bottom_right.x or y == top_left.y or y == bottom_right.y
			if not is_boundary:
				continue
			if cell == door or cell == second_door:
				assert_eq(_at(loaded["state"].entities, cell, &"DOOR").size(), 1)
			else:
				assert_eq(_at(loaded["state"].entities, cell, &"BOX").size(), 1)


func _at(entities: Array[RuleGridEntity], cell: Vector2i, kind: StringName) -> Array[RuleGridEntity]:
	var result: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in entities:
		if entity.position == cell and entity.kind == kind:
			result.append(entity)
	return result
