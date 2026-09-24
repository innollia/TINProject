extends GutTest


func _entity(id: String, kind: String, cell: Vector2i, is_word: bool = false) -> RuleGridEntity:
	var entity := RuleGridEntity.new()
	entity.id = id
	entity.kind = StringName(kind)
	entity.position = cell
	entity.is_word = is_word
	return entity


func _state(width: int, height: int, entities: Array[RuleGridEntity]) -> RuleGridState:
	var state := RuleGridState.new()
	state.width = width
	state.height = height
	state.entities.assign(entities)
	return state


func _add_box_rectangle(entities: Array[RuleGridEntity], prefix: String, left: int, top: int, right: int, bottom: int) -> void:
	for y: int in range(top, bottom + 1):
		for x: int in range(left, right + 1):
			if x == left or x == right or y == top or y == bottom:
				entities.append(_entity("%s_%d_%d" % [prefix, x - left, y - top], "BOX", Vector2i(x, y)))


func _find_shape(shapes: Array[Dictionary], bounds: Rect2i) -> Dictionary:
	for shape: Dictionary in shapes:
		if shape["bounds"] == bounds:
			return shape
	return {}


func _replace_box_with(entities: Array[RuleGridEntity], cell: Vector2i, replacement: RuleGridEntity) -> void:
	for index: int in range(entities.size() - 1, -1, -1):
		if entities[index].position == cell and entities[index].kind == &"BOX":
			entities.remove_at(index)
	entities.append(replacement)


func test_inactive_rule_and_incomplete_or_too_small_borders_produce_no_shapes() -> void:
	var entities: Array[RuleGridEntity] = []
	_add_box_rectangle(entities, "ring", 0, 0, 2, 2)
	var complete := _state(3, 3, entities)
	assert_true(RuleMetrixResolver.resolve(complete, false).is_empty())
	assert_eq(RuleMetrixResolver.resolve(complete, true).size(), 1)

	var missing_mid_wall := entities.duplicate()
	_replace_box_with(missing_mid_wall, Vector2i(1, 0), _entity("gap", "ROCK", Vector2i(1, 0)))
	assert_true(RuleMetrixResolver.resolve(_state(3, 3, missing_mid_wall), true).is_empty())
	assert_true(RuleMetrixResolver.resolve(_state(2, 3, entities), true).is_empty())


func test_box_ring_accepts_one_bracketed_door_but_not_door_corners_or_adjacent_doors() -> void:
	var ring: Array[RuleGridEntity] = []
	_add_box_rectangle(ring, "door_ring", 0, 0, 2, 2)
	_replace_box_with(ring, Vector2i(1, 0), _entity("entry_door", "DOOR", Vector2i(1, 0)))
	var shapes := RuleMetrixResolver.resolve(_state(3, 3, ring), true)
	assert_eq(shapes.size(), 1)
	assert_true(shapes[0]["boundary_entity_ids"].has("entry_door"))
	assert_eq(shapes[0]["interior_cells"], [Vector2i(1, 1)])

	var door_corner: Array[RuleGridEntity] = []
	_add_box_rectangle(door_corner, "corner_ring", 0, 0, 2, 2)
	_replace_box_with(door_corner, Vector2i(0, 0), _entity("corner_door", "DOOR", Vector2i(0, 0)))
	assert_true(RuleMetrixResolver.resolve(_state(3, 3, door_corner), true).is_empty())

	var adjacent_doors: Array[RuleGridEntity] = []
	_add_box_rectangle(adjacent_doors, "wide_ring", 0, 0, 3, 2)
	_replace_box_with(adjacent_doors, Vector2i(1, 0), _entity("door_a", "DOOR", Vector2i(1, 0)))
	_replace_box_with(adjacent_doors, Vector2i(2, 0), _entity("door_b", "DOOR", Vector2i(2, 0)))
	assert_true(RuleMetrixResolver.resolve(_state(4, 3, adjacent_doors), true).is_empty())

	var word_is_not_a_wall: Array[RuleGridEntity] = []
	_add_box_rectangle(word_is_not_a_wall, "word_ring", 0, 0, 2, 2)
	_replace_box_with(word_is_not_a_wall, Vector2i(1, 0), _entity("text_box", "BOX", Vector2i(1, 0), true))
	assert_true(RuleMetrixResolver.resolve(_state(3, 3, word_is_not_a_wall), true).is_empty())


func test_every_closed_rectangle_candidate_is_returned_and_shared_walls_form_one_component() -> void:
	var entities: Array[RuleGridEntity] = []
	_add_box_rectangle(entities, "left", 0, 0, 2, 2)
	_add_box_rectangle(entities, "right", 2, 0, 4, 2)
	var shapes := RuleMetrixResolver.resolve(_state(5, 3, entities), true)

	assert_eq(shapes.size(), 3)
	var left := _find_shape(shapes, Rect2i(Vector2i(0, 0), Vector2i(3, 3)))
	var right := _find_shape(shapes, Rect2i(Vector2i(2, 0), Vector2i(3, 3)))
	var outer := _find_shape(shapes, Rect2i(Vector2i(0, 0), Vector2i(5, 3)))
	assert_false(left.is_empty())
	assert_false(right.is_empty())
	assert_false(outer.is_empty())
	assert_eq(left["component_id"], right["component_id"])
	assert_eq(right["component_id"], outer["component_id"])
	assert_eq(left["component_metrix_ids"].size(), 3)
	assert_true(left["boundary_entity_ids"].has("left_2_1"))
	assert_true(right["boundary_entity_ids"].has("left_2_1"))


func test_nested_inventory_projections_reference_the_same_physical_entity_ids() -> void:
	var entities: Array[RuleGridEntity] = []
	_add_box_rectangle(entities, "outer", 0, 0, 6, 6)
	_add_box_rectangle(entities, "inner", 2, 2, 4, 4)
	entities.append(_entity("shared_rock", "ROCK", Vector2i(3, 3)))
	entities.append(_entity("shared_text", "IS", Vector2i(3, 3), true))
	var shapes := RuleMetrixResolver.resolve(_state(7, 7, entities), true)
	var outer := _find_shape(shapes, Rect2i(Vector2i.ZERO, Vector2i(7, 7)))
	var inner := _find_shape(shapes, Rect2i(Vector2i(2, 2), Vector2i(3, 3)))

	assert_eq(shapes.size(), 2)
	assert_true(outer["contents"].has("inner_0_0"))
	assert_true(outer["contents"].has("shared_rock"))
	assert_true(inner["contents"].has("shared_rock"))
	assert_true(outer["contents"].has("shared_text"))
	assert_true(inner["contents"].has("shared_text"))
	assert_ne(outer["component_id"], inner["component_id"])

	var outer_center: Dictionary = outer["slots"][12]
	var inner_center: Dictionary = inner["slots"][0]
	assert_eq(outer_center["cell"], Vector2i(3, 3))
	assert_eq(inner_center["cell"], Vector2i(3, 3))
	assert_eq(outer_center["entity_ids"], ["shared_rock", "shared_text"])
	assert_eq(inner_center["entity_ids"], ["shared_rock", "shared_text"])
	assert_eq(outer["interior_cells"].size(), 25)
	assert_eq(inner["interior_cells"].size(), 1)


func test_derived_shape_id_survives_translation_and_changes_with_boundary_membership() -> void:
	var initial_entities: Array[RuleGridEntity] = []
	_add_box_rectangle(initial_entities, "stable", 0, 0, 2, 2)
	var moved_entities: Array[RuleGridEntity] = []
	_add_box_rectangle(moved_entities, "stable", 2, 1, 4, 3)
	var changed_entities: Array[RuleGridEntity] = []
	_add_box_rectangle(changed_entities, "replacement", 0, 0, 2, 2)

	var initial := RuleMetrixResolver.resolve(_state(3, 3, initial_entities), true)[0]
	var moved := RuleMetrixResolver.resolve(_state(5, 4, moved_entities), true)[0]
	var changed := RuleMetrixResolver.resolve(_state(3, 3, changed_entities), true)[0]
	assert_eq(initial["id"], moved["id"])
	assert_ne(initial["id"], changed["id"])


func test_resolution_order_and_slot_entity_order_do_not_depend_on_input_order() -> void:
	var entities: Array[RuleGridEntity] = []
	_add_box_rectangle(entities, "ordered", 0, 0, 4, 4)
	entities.append(_entity("z_rock", "ROCK", Vector2i(2, 2)))
	entities.append(_entity("a_text", "IS", Vector2i(2, 2), true))
	var reversed_entities: Array[RuleGridEntity] = []
	for index: int in range(entities.size() - 1, -1, -1):
		reversed_entities.append(entities[index])

	var shape := RuleMetrixResolver.resolve(_state(5, 5, entities), true)[0]
	var reversed_shape := RuleMetrixResolver.resolve(_state(5, 5, reversed_entities), true)[0]
	assert_eq(shape["id"], reversed_shape["id"])
	assert_eq(shape["boundary_entity_ids"], reversed_shape["boundary_entity_ids"])
	assert_eq(shape["contents"], reversed_shape["contents"])
	assert_eq(shape["slots"][4]["entity_ids"], ["a_text", "z_rock"])
	assert_eq(shape["slots"], reversed_shape["slots"])
