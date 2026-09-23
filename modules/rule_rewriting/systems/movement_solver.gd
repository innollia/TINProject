class_name RuleMovementSolver
extends RefCounted

const PROPERTY_PUSH: StringName = &"PUSH"
const PROPERTY_STOP: StringName = &"STOP"


static func plan_move(
	state: RuleGridState,
	rules: RuleSet,
	entity_id: String,
	direction: Vector2i
) -> Dictionary:
	if state.width <= 0 or state.height <= 0 or absi(direction.x) + absi(direction.y) != 1:
		return _blocked_plan()

	var ordered: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in state.entities:
		if entity == null:
			return _blocked_plan()
		ordered.append(entity)
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return a.id < b.id)
	var entities_by_id: Dictionary = {}
	var entities_by_cell: Dictionary = {}
	for entity: RuleGridEntity in ordered:
		if entity.id.is_empty() \
			or entities_by_id.has(entity.id) \
			or not _inside_board(entity.position, state.width, state.height):
			return _blocked_plan()
		entities_by_id[entity.id] = entity
		var at_cell: Array = entities_by_cell.get(entity.position, [])
		at_cell.append(entity)
		entities_by_cell[entity.position] = at_cell

	if not entities_by_id.has(entity_id):
		return _blocked_plan()

	var destinations: Dictionary = {}
	var visiting: Dictionary = {}
	var mover: RuleGridEntity = entities_by_id[entity_id]
	if not _collect_move(
		mover,
		mover.position + direction,
		direction,
		state,
		rules,
		entities_by_cell,
		destinations,
		visiting
	):
		return _blocked_plan()

	var moves: Array[Dictionary] = []
	for entity: RuleGridEntity in ordered:
		if destinations.has(entity.id):
			moves.append({"entity_id": entity.id, "from": entity.position, "to": destinations[entity.id]})
	return {"can_move": true, "moves": moves}


static func plan_move_many(
	state: RuleGridState,
	rules: RuleSet,
	entity_ids: Array[String],
	direction: Vector2i
) -> Dictionary:
	if entity_ids.is_empty():
		return _blocked_plan()
	var ordered_ids: Array[String] = []
	ordered_ids.assign(entity_ids)
	ordered_ids.sort()
	var moves_by_id: Dictionary = {}
	for entity_id: String in ordered_ids:
		var plan := plan_move(state, rules, entity_id, direction)
		if not bool(plan["can_move"]):
			continue
		for move: Dictionary in plan["moves"]:
			var moved_id: String = move["entity_id"]
			if moves_by_id.has(moved_id) and moves_by_id[moved_id] != move:
				return _blocked_plan()
			moves_by_id[moved_id] = move
	if moves_by_id.is_empty():
		return _blocked_plan()
	var ordered_entities: Array[RuleGridEntity] = []
	ordered_entities.assign(state.entities)
	ordered_entities.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return a.id < b.id)
	var merged_moves: Array[Dictionary] = []
	for entity: RuleGridEntity in ordered_entities:
		if moves_by_id.has(entity.id):
			merged_moves.append(moves_by_id[entity.id])
	return {"can_move": true, "moves": merged_moves}


static func plan_move_auto(state: RuleGridState, rules: RuleSet) -> Dictionary:
	if state == null or rules == null or state.width <= 0 or state.height <= 0:
		return {"valid": false, "moves": [], "word_moved": false}
	var simulation := RuleGridState.from_dictionary(state.to_dictionary())
	if simulation == null:
		return {"valid": false, "moves": [], "word_moved": false}
	var original_by_id: Dictionary = {}
	var scheduled_ids: Array[String] = []
	for entity: RuleGridEntity in simulation.entities:
		original_by_id[entity.id] = entity.to_dictionary()
		if not entity.is_word and _has_property(entity, &"MOVE", rules):
			scheduled_ids.append(entity.id)
	scheduled_ids.sort()
	var already_displaced: Dictionary = {}
	for entity_id: String in scheduled_ids:
		if already_displaced.has(entity_id):
			continue
		var actor := _find_entity(simulation, entity_id)
		if actor == null:
			return {"valid": false, "moves": [], "word_moved": false}
		var direction := actor.facing
		if absi(direction.x) + absi(direction.y) != 1:
			return {"valid": false, "moves": [], "word_moved": false}
		var plan := plan_move(simulation, rules, entity_id, direction)
		if bool(plan["can_move"]):
			for move: Dictionary in plan["moves"]:
				var moved_entity := _find_entity(simulation, String(move["entity_id"]))
				if moved_entity == null:
					return {"valid": false, "moves": [], "word_moved": false}
				moved_entity.position = move["to"]
				already_displaced[moved_entity.id] = true
		else:
			actor.facing = -direction
			already_displaced[actor.id] = true
	var result_moves: Array[Dictionary] = []
	var word_moved := false
	var result_entities: Array[RuleGridEntity] = []
	result_entities.assign(simulation.entities)
	result_entities.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool: return a.id < b.id)
	for entity: RuleGridEntity in result_entities:
		var original: Dictionary = original_by_id[entity.id]
		var from: Vector2i = Vector2i(int(original["x"]), int(original["y"]))
		var facing_from := Vector2i(int(original["facing_x"]), int(original["facing_y"]))
		if entity.position == from and entity.facing == facing_from:
			continue
		result_moves.append({
			"entity_id": entity.id,
			"from": from,
			"to": entity.position,
			"facing_from": facing_from,
			"facing_to": entity.facing
		})
		if entity.is_word and entity.position != from:
			word_moved = true
	return {"valid": true, "moves": result_moves, "word_moved": word_moved}


static func _collect_move(
	entity: RuleGridEntity,
	destination: Vector2i,
	direction: Vector2i,
	state: RuleGridState,
	rules: RuleSet,
	entities_by_cell: Dictionary,
	destinations: Dictionary,
	visiting: Dictionary
) -> bool:
	if destinations.has(entity.id):
		return destinations[entity.id] == destination
	if visiting.has(entity.id) or not _inside_board(destination, state.width, state.height):
		return false

	visiting[entity.id] = true
	for obstacle: Variant in entities_by_cell.get(destination, []):
		if obstacle.id == entity.id:
			continue
		if destinations.has(obstacle.id):
			if destinations[obstacle.id] == destination:
				visiting.erase(entity.id)
				return false
			continue
		if _has_property(obstacle, PROPERTY_PUSH, rules):
			if not _collect_move(
				obstacle,
				obstacle.position + direction,
				direction,
				state,
				rules,
				entities_by_cell,
				destinations,
				visiting
			):
				visiting.erase(entity.id)
				return false
		elif _has_property(obstacle, PROPERTY_STOP, rules):
			visiting.erase(entity.id)
			return false

	destinations[entity.id] = destination
	visiting.erase(entity.id)
	return true


static func _has_property(entity: RuleGridEntity, property: StringName, rules: RuleSet) -> bool:
	return entity.base_tags.has(property) or rules.has_property(entity.kind, property)


static func _inside_board(cell: Vector2i, width: int, height: int) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


static func _find_entity(state: RuleGridState, entity_id: String) -> RuleGridEntity:
	for entity: RuleGridEntity in state.entities:
		if entity.id == entity_id:
			return entity
	return null


static func _blocked_plan() -> Dictionary:
	return {"can_move": false, "moves": []}
