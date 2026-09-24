class_name RuleMetrixResolver
extends RefCounted


static func resolve(state: RuleGridState, active: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not active or not _is_valid_state(state):
		return result

	var cells := _entities_by_cell(state)
	for top: int in range(state.height - 2):
		for bottom: int in range(top + 2, state.height):
			for left: int in range(state.width - 2):
				for right: int in range(left + 2, state.width):
					var boundary := _read_boundary(cells, left, top, right, bottom)
					if boundary.is_empty():
						continue
					result.append(_build_shape(state, cells, left, top, right, bottom, boundary))

	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a["id"]) < String(b["id"])
	)
	_assign_components(result)
	return result


static func _is_valid_state(state: RuleGridState) -> bool:
	if state == null or state.width < 3 or state.height < 3:
		return false
	var seen_ids: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		if entity == null or entity.id.is_empty() or entity.kind.is_empty() \
			or seen_ids.has(entity.id) \
			or entity.position.x < 0 or entity.position.y < 0 \
			or entity.position.x >= state.width or entity.position.y >= state.height:
			return false
		seen_ids[entity.id] = true
	return true


static func _entities_by_cell(state: RuleGridState) -> Dictionary:
	var cells: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		var at_cell: Array = cells.get(entity.position, [])
		at_cell.append(entity)
		cells[entity.position] = at_cell
	return cells


static func _read_boundary(cells: Dictionary, left: int, top: int, right: int, bottom: int) -> Dictionary:
	var selected_ids: Dictionary = {}
	for y: int in range(top, bottom + 1):
		for x: int in range(left, right + 1):
			if x != left and x != right and y != top and y != bottom:
				continue
			var is_corner: bool = (x == left or x == right) and (y == top or y == bottom)
			var boxes := _ids_at(cells, Vector2i(x, y), &"BOX")
			var doors := _ids_at(cells, Vector2i(x, y), &"DOOR")
			if is_corner:
				if boxes.is_empty():
					return {}
				_add_ids(selected_ids, boxes)
			elif not boxes.is_empty():
				_add_ids(selected_ids, boxes)
			elif not doors.is_empty():
				if not _door_has_box_neighbors(cells, x, y, left, top, right, bottom):
					return {}
				_add_ids(selected_ids, doors)
			else:
				return {}

	var sorted_ids: Array[String] = []
	for entity_id: Variant in selected_ids.keys():
		sorted_ids.append(String(entity_id))
	sorted_ids.sort()
	return {"ids": sorted_ids}


static func _door_has_box_neighbors(
	cells: Dictionary,
	x: int,
	y: int,
	left: int,
	top: int,
	right: int,
	bottom: int
) -> bool:
	if y == top or y == bottom:
		return not _ids_at(cells, Vector2i(x - 1, y), &"BOX").is_empty() \
			and not _ids_at(cells, Vector2i(x + 1, y), &"BOX").is_empty()
	if x == left or x == right:
		return not _ids_at(cells, Vector2i(x, y - 1), &"BOX").is_empty() \
			and not _ids_at(cells, Vector2i(x, y + 1), &"BOX").is_empty()
	return false


static func _ids_at(cells: Dictionary, cell: Vector2i, kind: StringName) -> Array[String]:
	var result: Array[String] = []
	for entity: RuleGridEntity in cells.get(cell, []):
		if not entity.is_word and entity.kind == kind:
			result.append(entity.id)
	result.sort()
	return result


static func _add_ids(target: Dictionary, ids: Array[String]) -> void:
	for entity_id: String in ids:
		target[entity_id] = true


static func _build_shape(
	state: RuleGridState,
	cells: Dictionary,
	left: int,
	top: int,
	right: int,
	bottom: int,
	boundary: Dictionary
) -> Dictionary:
	var boundary_ids: Array[String] = boundary["ids"]
	var boundary_cells: Array[Vector2i] = []
	var interior_cells: Array[Vector2i] = []
	var slots: Array[Dictionary] = []
	var contents: Dictionary = {}
	var boundary_set: Dictionary = {}
	for entity_id: String in boundary_ids:
		boundary_set[entity_id] = true

	for y: int in range(top, bottom + 1):
		for x: int in range(left, right + 1):
			var cell := Vector2i(x, y)
			if x == left or x == right or y == top or y == bottom:
				boundary_cells.append(cell)
				continue
			interior_cells.append(cell)
			var ids: Array[String] = []
			for entity: RuleGridEntity in cells.get(cell, []):
				if not boundary_set.has(entity.id):
					ids.append(entity.id)
					contents[entity.id] = true
			ids.sort()
			slots.append({"cell": cell, "entity_ids": ids})

	var content_ids: Array[String] = []
	for entity_id: Variant in contents.keys():
		content_ids.append(String(entity_id))
	content_ids.sort()
	return {
		"id": _derive_id(state, boundary_ids, left, top),
		"bounds": Rect2i(Vector2i(left, top), Vector2i(right - left + 1, bottom - top + 1)),
		"boundary_cells": boundary_cells,
		"boundary_entity_ids": boundary_ids.duplicate(),
		"interior_cells": interior_cells,
		"slots": slots,
		"contents": content_ids,
		"component_id": "",
		"component_metrix_ids": []
	}


static func _derive_id(state: RuleGridState, boundary_ids: Array[String], left: int, top: int) -> String:
	var entities_by_id: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		entities_by_id[entity.id] = entity
	var identity: Array = [1]
	for entity_id: String in boundary_ids:
		var entity: RuleGridEntity = entities_by_id[entity_id]
		identity.append([entity_id, entity.position.x - left, entity.position.y - top])
	return "metrix:" + JSON.stringify(identity).sha256_text()


static func _assign_components(shapes: Array[Dictionary]) -> void:
	var remaining: Dictionary = {}
	for index: int in range(shapes.size()):
		remaining[index] = true
	while not remaining.is_empty():
		var seed: int = remaining.keys().min()
		remaining.erase(seed)
		var component: Array[int] = [seed]
		var queue: Array[int] = [seed]
		while not queue.is_empty():
			var current: int = queue.pop_front()
			var current_ids: Dictionary = {}
			for entity_id: String in shapes[current]["boundary_entity_ids"]:
				current_ids[entity_id] = true
			var newly_connected: Array[int] = []
			for candidate: int in remaining.keys():
				if _shares_boundary(current_ids, shapes[candidate]["boundary_entity_ids"]):
					newly_connected.append(candidate)
			newly_connected.sort()
			for candidate: int in newly_connected:
				remaining.erase(candidate)
				component.append(candidate)
				queue.append(candidate)

		var member_ids: Array[String] = []
		for index: int in component:
			member_ids.append(String(shapes[index]["id"]))
		member_ids.sort()
		var component_id := "metrix-group:" + JSON.stringify(member_ids).sha256_text()
		for index: int in component:
			shapes[index]["component_id"] = component_id
			shapes[index]["component_metrix_ids"] = member_ids.duplicate()


static func _shares_boundary(left_ids: Dictionary, right_ids: Array[String]) -> bool:
	for entity_id: String in right_ids:
		if left_ids.has(entity_id):
			return true
	return false
