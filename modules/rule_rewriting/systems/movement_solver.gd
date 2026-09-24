class_name RuleMovementSolver
extends RefCounted

const PROPERTY_PUSH: StringName = &"PUSH"
const PROPERTY_PULL: StringName = &"PULL"
const PROPERTY_STOP: StringName = &"STOP"
const PROPERTY_SHIFT: StringName = &"SHIFT"
const PROPERTY_SWAP: StringName = &"SWAP"
const PROPERTY_METRIX: StringName = &"METRIX"
const PROPERTY_MOVE: StringName = &"MOVE"
const OPERATOR_INSIDE_IS: StringName = &"INSIDE_IS"


static func plan_move(
	state: RuleGridState,
	rules: RuleSet,
	entity_id: String,
	direction: Vector2i
) -> Dictionary:
	var context := _build_context(state, rules)
	if not bool(context.get("valid", false)) or not _is_cardinal(direction):
		return _blocked_plan()
	var entities_by_id: Dictionary = context["entities_by_id"]
	if not entities_by_id.has(entity_id):
		return _blocked_plan()
	var actor: RuleGridEntity = entities_by_id[entity_id]
	var destinations: Dictionary = {}
	var visiting: Dictionary = {}
	if not _collect_move(actor, actor.position + direction, direction, false, context, destinations, visiting):
		return _blocked_plan()
	return _moves_for(context["ordered"], destinations)


static func plan_move_many(
	state: RuleGridState,
	rules: RuleSet,
	entity_ids: Array[String],
	direction: Vector2i
) -> Dictionary:
	if entity_ids.is_empty() or not _is_cardinal(direction):
		return _blocked_plan()
	var simulation := _copy_state(state)
	if simulation == null:
		return _blocked_plan()
	var requested: Dictionary = {}
	for entity_id: String in entity_ids:
		requested[entity_id] = true
	var actors: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in simulation.entities:
		if requested.has(entity.id):
			actors.append(entity)
	actors.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return _priority_less(a, b)
	)
	var moved_any := false
	for actor: RuleGridEntity in actors:
		var current_actor := _find_entity(simulation, actor.id)
		if current_actor == null:
			continue
		var plan := plan_move(simulation, rules, current_actor.id, direction)
		if not bool(plan["can_move"]):
			continue
		_apply_position_moves(simulation, plan["moves"])
		moved_any = true
	if not moved_any:
		return _blocked_plan()
	return _moves_between_states(state, simulation)


static func plan_move_auto(state: RuleGridState, rules: RuleSet) -> Dictionary:
	if state == null or rules == null or state.width <= 0 or state.height <= 0:
		return {"valid": false, "moves": [], "word_moved": false}
	var simulation := _copy_state(state)
	if simulation == null:
		return {"valid": false, "moves": [], "word_moved": false}
	var original_by_id: Dictionary = {}
	var initial_order: Array[RuleGridEntity] = []
	var scheduled: Array[RuleGridEntity] = []
	var move_stages := 0
	for entity: RuleGridEntity in simulation.entities:
		original_by_id[entity.id] = entity.to_dictionary()
		initial_order.append(entity)
		var stack := RuleEvaluator.property_stack(entity, PROPERTY_MOVE, rules, simulation)
		if not entity.is_word and stack > 0:
			scheduled.append(entity)
			move_stages = maxi(move_stages, stack)
	initial_order.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return _priority_less(a, b)
	)
	var priority_index_by_id: Dictionary = {}
	for index: int in range(initial_order.size()):
		priority_index_by_id[initial_order[index].id] = index
	scheduled.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return int(priority_index_by_id[a.id]) < int(priority_index_by_id[b.id])
	)
	for stage: int in range(move_stages):
		var stage_actors: Array[RuleGridEntity] = []
		for scheduled_entity: RuleGridEntity in scheduled:
			var actor := _find_entity(simulation, scheduled_entity.id)
			if actor != null and RuleEvaluator.property_stack(actor, PROPERTY_MOVE, rules, simulation) > stage:
				stage_actors.append(actor)
		var already_displaced: Dictionary = {}
		for stage_actor: RuleGridEntity in stage_actors:
			if already_displaced.has(stage_actor.id):
				continue
			var actor := _find_entity(simulation, stage_actor.id)
			if actor == null:
				return {"valid": false, "moves": [], "word_moved": false}
			var direction := actor.facing
			if not _is_cardinal(direction):
				return {"valid": false, "moves": [], "word_moved": false}
			var plan := plan_move(simulation, rules, actor.id, direction)
			if bool(plan["can_move"]):
				_apply_position_moves(simulation, plan["moves"])
				for move: Dictionary in plan["moves"]:
					already_displaced[String(move["entity_id"])] = true
			else:
				actor.facing = -direction
				already_displaced[actor.id] = true

	var shift_actors: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in simulation.entities:
		if _has_property(entity, PROPERTY_SHIFT, rules, simulation):
			shift_actors.append(entity)
	shift_actors.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return int(priority_index_by_id[a.id]) < int(priority_index_by_id[b.id])
	)
	var shifted_ids: Dictionary = {}
	for shift_actor_snapshot: RuleGridEntity in shift_actors:
		var shift_actor := _find_entity(simulation, shift_actor_snapshot.id)
		if shift_actor == null or not _has_property(shift_actor, PROPERTY_SHIFT, rules, simulation):
			continue
		var occupants := _entities_at(simulation, shift_actor.position)
		for target: RuleGridEntity in occupants:
			if target.id == shift_actor.id or shifted_ids.has(target.id) \
				or not RuleEvaluator.entities_interact(shift_actor, target, rules, simulation):
				continue
			var plan := plan_move(simulation, rules, target.id, shift_actor.facing)
			if not bool(plan["can_move"]):
				continue
			_apply_position_moves(simulation, plan["moves"])
			for move: Dictionary in plan["moves"]:
				shifted_ids[String(move["entity_id"])] = true

	var result_moves: Array[Dictionary] = []
	var word_moved := false
	var result_entities: Array[RuleGridEntity] = []
	result_entities.assign(simulation.entities)
	result_entities.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return _priority_less(a, b)
	)
	for entity: RuleGridEntity in result_entities:
		var original: Dictionary = original_by_id[entity.id]
		var from := Vector2i(int(original["x"]), int(original["y"]))
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
	pulled: bool,
	context: Dictionary,
	destinations: Dictionary,
	visiting: Dictionary
) -> bool:
	if destinations.has(entity.id):
		return destinations[entity.id] == destination
	if visiting.has(entity.id) or not _inside_board(destination, int(context["width"]), int(context["height"])):
		return false
	visiting[entity.id] = true
	var entities_by_cell: Dictionary = context["entities_by_cell"]
	for obstacle_value: Variant in entities_by_cell.get(destination, []):
		if not obstacle_value is RuleGridEntity:
			visiting.erase(entity.id)
			return false
		var obstacle: RuleGridEntity = obstacle_value
		if obstacle.id == entity.id:
			continue
		if not RuleEvaluator.entities_interact(entity, obstacle, context["rules"], context["state"]):
			continue
		if destinations.has(obstacle.id) and destinations[obstacle.id] != destination:
			continue
		if _can_move_metrix(obstacle, context, destinations, visiting):
			if not _collect_metrix_component(
				String(context["boundary_component_by_id"][obstacle.id]),
				direction,
				context,
				destinations,
				visiting
			):
				visiting.erase(entity.id)
				return false
			continue
		if _can_open_shut_contact(entity, obstacle, context):
			continue
		var should_swap := _has_property(entity, PROPERTY_SWAP, context["rules"], context["state"]) \
			or _has_property(obstacle, PROPERTY_SWAP, context["rules"], context["state"])
		if should_swap and not pulled:
			if not destinations.has(entity.id):
				destinations[entity.id] = destination
			if not _collect_move(
				obstacle,
				entity.position,
				direction,
				false,
				context,
				destinations,
				visiting
			):
				visiting.erase(entity.id)
				return false
			continue
		if _has_property(obstacle, PROPERTY_PUSH, context["rules"], context["state"]):
			if not _collect_move(
				obstacle,
				obstacle.position + direction,
				direction,
				false,
				context,
				destinations,
				visiting
			):
				visiting.erase(entity.id)
				return false
		elif not pulled and _is_solid(obstacle, context):
			visiting.erase(entity.id)
			return false

	if not destinations.has(entity.id):
		destinations[entity.id] = destination
	if not pulled and not _collect_pullers(entity, direction, context, destinations, visiting):
		visiting.erase(entity.id)
		return false
	visiting.erase(entity.id)
	return true


static func _collect_pullers(
	entity: RuleGridEntity,
	direction: Vector2i,
	context: Dictionary,
	destinations: Dictionary,
	visiting: Dictionary
) -> bool:
	var behind: Vector2i = entity.position - direction
	var candidates := _entities_at(context["state"], behind)
	for candidate: RuleGridEntity in candidates:
		if candidate.id == entity.id or destinations.has(candidate.id) \
			or not RuleEvaluator.entities_interact(candidate, entity, context["rules"], context["state"]) \
			or not _has_property(candidate, PROPERTY_PULL, context["rules"], context["state"]):
			continue
		if not _collect_move(candidate, entity.position, direction, true, context, destinations, visiting):
			return false
	return true


static func _can_move_metrix(
	entity: RuleGridEntity,
	context: Dictionary,
	_destinations: Dictionary,
	_visiting: Dictionary
) -> bool:
	if not bool(context["metrix_active"]):
		return false
	if not context["boundary_component_by_id"].has(entity.id):
		return false
	var rules: RuleSet = context["rules"]
	return _has_property(entity, PROPERTY_PUSH, rules, context["state"]) \
		or _has_property(&"METRIX", PROPERTY_PUSH, rules, context["state"])


static func _collect_metrix_component(
	component_id: String,
	direction: Vector2i,
	context: Dictionary,
	destinations: Dictionary,
	visiting: Dictionary
) -> bool:
	var component_ids: Dictionary = {component_id: true}
	var changed := true
	while changed:
		changed = false
		var current_shapes := _shapes_for_components(context["metrix_shapes"], component_ids)
		var all_content_ids: Dictionary = {}
		for shape: Dictionary in current_shapes:
			for content_id_value: Variant in shape["contents"]:
				var content_id := String(content_id_value)
				all_content_ids[content_id] = true
				var nested_component: String = context["boundary_component_by_id"].get(content_id, "")
				if not nested_component.is_empty() and not component_ids.has(nested_component):
					component_ids[nested_component] = true
					changed = true
	var shapes := _shapes_for_components(context["metrix_shapes"], component_ids)
	var boundary_ids: Dictionary = {}
	var content_ids: Dictionary = {}
	for shape: Dictionary in shapes:
		for entity_id_value: Variant in shape["boundary_entity_ids"]:
			boundary_ids[String(entity_id_value)] = true
		for entity_id_value: Variant in shape["contents"]:
			content_ids[String(entity_id_value)] = true
	var entities_by_id: Dictionary = context["entities_by_id"]
	for entity_id_value: Variant in boundary_ids.keys():
		var entity_id := String(entity_id_value)
		if not entities_by_id.has(entity_id):
			return false
		if visiting.has(entity_id):
			return false
	var rigid_ids: Dictionary = boundary_ids.duplicate()
	var loose_content: Dictionary = {}
	for entity_id_value: Variant in content_ids.keys():
		var entity_id := String(entity_id_value)
		if not boundary_ids.has(entity_id):
			loose_content[entity_id] = true
	for entity_id_value: Variant in boundary_ids.keys():
		var entity_id := String(entity_id_value)
		var entity: RuleGridEntity = entities_by_id[entity_id]
		if destinations.has(entity_id):
			if destinations[entity_id] != entity.position + direction:
				return false
		else:
			visiting[entity_id] = true

	for entity_id_value: Variant in boundary_ids.keys():
		var entity_id := String(entity_id_value)
		var entity: RuleGridEntity = entities_by_id[entity_id]
		var destination: Vector2i = entity.position + direction
		if not _inside_board(destination, int(context["width"]), int(context["height"])):
			return false
		for obstacle_value: Variant in context["entities_by_cell"].get(destination, []):
			if not obstacle_value is RuleGridEntity:
				return false
			var obstacle: RuleGridEntity = obstacle_value
			if rigid_ids.has(obstacle.id) or content_ids.has(obstacle.id):
				continue
			if not RuleEvaluator.entities_interact(entity, obstacle, context["rules"], context["state"]):
				continue
			if destinations.has(obstacle.id) and destinations[obstacle.id] != destination:
				continue
			if _can_move_metrix(obstacle, context, destinations, visiting):
				if not _collect_metrix_component(
					String(context["boundary_component_by_id"][obstacle.id]),
					direction,
					context,
					destinations,
					visiting
				):
					return false
			elif _has_property(obstacle, PROPERTY_PUSH, context["rules"], context["state"]):
				if not _collect_move(
					obstacle,
					obstacle.position + direction,
					direction,
					false,
					context,
					destinations,
					visiting
				):
					return false
			elif _is_solid(obstacle, context):
				return false

	for entity_id_value: Variant in boundary_ids.keys():
		var entity_id := String(entity_id_value)
		var entity: RuleGridEntity = entities_by_id[entity_id]
		destinations[entity_id] = entity.position + direction
		visiting.erase(entity_id)
	var snapped_content := _snap_metrix_contents(shapes, loose_content, context, direction)
	for entity_id_value: Variant in snapped_content.keys():
		var entity_id := String(entity_id_value)
		if destinations.has(entity_id) and destinations[entity_id] != snapped_content[entity_id]:
			return false
		destinations[entity_id] = snapped_content[entity_id]
	return true


static func _snap_metrix_contents(
	shapes: Array[Dictionary],
	content_ids: Dictionary,
	context: Dictionary,
	direction: Vector2i
) -> Dictionary:
	var entities_by_id: Dictionary = context["entities_by_id"]
	var assigned_by_shape: Dictionary = {}
	for entity_id_value: Variant in content_ids.keys():
		var entity_id := String(entity_id_value)
		if not entities_by_id.has(entity_id):
			continue
		var entity: RuleGridEntity = entities_by_id[entity_id]
		var best_shape: Dictionary = {}
		var best_area := 2147483647
		for shape: Dictionary in shapes:
			if not shape["interior_cells"].has(entity.position):
				continue
			var bounds: Rect2i = shape["bounds"]
			var area: int = bounds.size.x * bounds.size.y
			if area < best_area or (area == best_area and String(shape["id"]) < String(best_shape.get("id", "~"))):
				best_shape = shape
				best_area = area
		if best_shape.is_empty():
			continue
		var shape_id := String(best_shape["id"])
		if not assigned_by_shape.has(shape_id):
			assigned_by_shape[shape_id] = {"shape": best_shape, "lines": {}}
		var line_coordinate: int = entity.position.y if direction.x != 0 else entity.position.x
		var line_key := str(line_coordinate)
		var line_map: Dictionary = assigned_by_shape[shape_id]["lines"]
		if not line_map.has(line_key):
			line_map[line_key] = {}
		var axis_coordinate: int = entity.position.x if direction.x != 0 else entity.position.y
		var cell_key := str(axis_coordinate)
		var cell_map: Dictionary = line_map[line_key]
		var cell_ids: Array[String] = []
		var current_cell_ids: Variant = cell_map.get(cell_key, [])
		if current_cell_ids is Array:
			for current_cell_id: Variant in current_cell_ids:
				cell_ids.append(String(current_cell_id))
		cell_ids.append(entity_id)
		cell_map[cell_key] = cell_ids
		line_map[line_key] = cell_map
		assigned_by_shape[shape_id]["lines"] = line_map

	var result: Dictionary = {}
	var shape_ids: Array[String] = []
	for shape_id_value: Variant in assigned_by_shape.keys():
		shape_ids.append(String(shape_id_value))
	shape_ids.sort()
	for shape_id: String in shape_ids:
		var assignment: Dictionary = assigned_by_shape[shape_id]
		var shape: Dictionary = assignment["shape"]
		var bounds: Rect2i = shape["bounds"]
		var lines: Dictionary = assignment["lines"]
		var line_keys: Array[String] = []
		for line_key_value: Variant in lines.keys():
			line_keys.append(String(line_key_value))
		line_keys.sort()
		for line_key: String in line_keys:
			var cell_map: Dictionary = lines[line_key]
			var axis_values: Array[int] = []
			for cell_key_value: Variant in cell_map.keys():
				axis_values.append(int(cell_key_value))
			axis_values.sort()
			if direction.x > 0 or direction.y > 0:
				axis_values.reverse()
			var axis_target: int
			if direction.x > 0:
				axis_target = bounds.position.x + bounds.size.x - 2 + direction.x
			elif direction.x < 0:
				axis_target = bounds.position.x + 1 + direction.x
			elif direction.y > 0:
				axis_target = bounds.position.y + bounds.size.y - 2 + direction.y
			else:
				axis_target = bounds.position.y + 1 + direction.y
			for source_axis: int in axis_values:
				var source_ids: Array[String] = cell_map[str(source_axis)]
				source_ids.sort_custom(func(a: String, b: String) -> bool:
					return _priority_less(entities_by_id[a], entities_by_id[b])
				)
				for entity_id: String in source_ids:
					var entity: RuleGridEntity = entities_by_id[entity_id]
					var target := entity.position + direction
					if direction.x != 0:
						target.x = axis_target
					else:
						target.y = axis_target
					result[entity_id] = target
				if direction.x > 0 or direction.y > 0:
					axis_target -= 1
				else:
					axis_target += 1
	return result


static func _build_context(state: RuleGridState, rules: RuleSet) -> Dictionary:
	if state == null or rules == null or state.width <= 0 or state.height <= 0:
		return {"valid": false}
	var ordered: Array[RuleGridEntity] = []
	var entities_by_id: Dictionary = {}
	var entities_by_cell: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		if entity == null or entity.id.is_empty() or entities_by_id.has(entity.id) \
			or not _inside_board(entity.position, state.width, state.height):
			return {"valid": false}
		ordered.append(entity)
		entities_by_id[entity.id] = entity
		var cell_entities: Array = entities_by_cell.get(entity.position, [])
		cell_entities.append(entity)
		entities_by_cell[entity.position] = cell_entities
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return _priority_less(a, b)
	)
	for cell: Vector2i in entities_by_cell.keys():
		var cell_entities: Array = entities_by_cell[cell]
		cell_entities.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
			return _priority_less(a, b)
		)
		entities_by_cell[cell] = cell_entities
	var metrix_active := _has_inside_is_metrix_rule(rules)
	var metrix_shapes: Array[Dictionary] = RuleMetrixResolver.resolve(state, metrix_active)
	metrix_shapes = _filter_conditioned_metrix_shapes(metrix_shapes, entities_by_id, rules, state)
	var boundary_component_by_id: Dictionary = {}
	for shape: Dictionary in metrix_shapes:
		for entity_id_value: Variant in shape["boundary_entity_ids"]:
			boundary_component_by_id[String(entity_id_value)] = String(shape["component_id"])
	return {
		"valid": true,
		"state": state,
		"rules": rules,
		"width": state.width,
		"height": state.height,
		"ordered": ordered,
		"entities_by_id": entities_by_id,
		"entities_by_cell": entities_by_cell,
		"metrix_active": metrix_active,
		"metrix_shapes": metrix_shapes,
		"boundary_component_by_id": boundary_component_by_id
	}


static func _has_inside_is_metrix_rule(rules: RuleSet) -> bool:
	for sentence: RuleSentence in rules.sentences:
		if sentence.operator == OPERATOR_INSIDE_IS and sentence.subject == &"BOX" \
			and sentence.predicate == PROPERTY_METRIX and sentence.predicate_role == &"noun" \
			and not sentence.subject_is_negated and not sentence.is_negated:
			return true
	return false


static func _filter_conditioned_metrix_shapes(
	shapes: Array[Dictionary],
	entities_by_id: Dictionary,
	rules: RuleSet,
	state: RuleGridState
) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	for shape: Dictionary in shapes:
		var shape_matches := false
		var has_boundary_box := false
		for sentence: RuleSentence in rules.sentences:
			if sentence.operator != OPERATOR_INSIDE_IS or sentence.subject != &"BOX" \
				or sentence.predicate != PROPERTY_METRIX or sentence.predicate_role != &"noun" \
				or sentence.subject_is_negated or sentence.is_negated:
				continue
			var sentence_matches := true
			has_boundary_box = false
			for entity_id_value: Variant in shape["boundary_entity_ids"]:
				var entity_id := String(entity_id_value)
				if not entities_by_id.has(entity_id):
					sentence_matches = false
					break
				var boundary_entity: RuleGridEntity = entities_by_id[entity_id]
				if boundary_entity.is_word or boundary_entity.kind != &"BOX":
					continue
				has_boundary_box = true
				if not RuleEvaluator.conditions_match(boundary_entity, sentence.conditions, state):
					sentence_matches = false
					break
			if sentence_matches and has_boundary_box:
				shape_matches = true
				break
		if shape_matches:
			filtered.append(shape)
	_assign_filtered_metrix_components(filtered)
	return filtered


static func _assign_filtered_metrix_components(shapes: Array[Dictionary]) -> void:
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
			for entity_id_value: Variant in shapes[current]["boundary_entity_ids"]:
				current_ids[String(entity_id_value)] = true
			var candidates: Array[int] = []
			for index_value: Variant in remaining.keys():
				var index := int(index_value)
				for entity_id_value: Variant in shapes[index]["boundary_entity_ids"]:
					if current_ids.has(String(entity_id_value)):
						candidates.append(index)
						break
			candidates.sort()
			for index: int in candidates:
				remaining.erase(index)
				component.append(index)
				queue.append(index)
		var ids: Array[String] = []
		for index: int in component:
			ids.append(String(shapes[index]["id"]))
		ids.sort()
		var component_id := "metrix-group:" + JSON.stringify(ids).sha256_text()
		for index: int in component:
			shapes[index]["component_id"] = component_id
			shapes[index]["component_metrix_ids"] = ids.duplicate()


static func _shapes_for_components(shapes: Array[Dictionary], component_ids: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for shape: Dictionary in shapes:
		if component_ids.has(String(shape["component_id"])):
			result.append(shape)
	return result


static func _is_solid(entity: RuleGridEntity, context: Dictionary) -> bool:
	return _has_property(entity, PROPERTY_STOP, context["rules"], context["state"]) \
		or _has_property(entity, PROPERTY_PUSH, context["rules"], context["state"]) \
		or _has_property(entity, PROPERTY_PULL, context["rules"], context["state"])


static func _can_open_shut_contact(
	actor: RuleGridEntity,
	target: RuleGridEntity,
	context: Dictionary
) -> bool:
	var rules: RuleSet = context["rules"]
	var state: RuleGridState = context["state"]
	if not RuleEvaluator.entities_interact(actor, target, rules, state) \
		or _has_property(actor, &"SAFE", rules, state) \
		or _has_property(target, &"SAFE", rules, state):
		return false
	return (_has_property(actor, &"OPEN", rules, state) \
		and _has_property(target, &"SHUT", rules, state)) \
		or (_has_property(actor, &"SHUT", rules, state) \
		and _has_property(target, &"OPEN", rules, state))


static func _has_property(
	entity_or_kind: Variant,
	property: StringName,
	rules: RuleSet,
	state: RuleGridState
) -> bool:
	if entity_or_kind is RuleGridEntity:
		return RuleEvaluator.has_property(entity_or_kind, property, rules, state)
	var query := RuleGridEntity.new()
	query.id = "__rule_query__"
	query.kind = StringName(entity_or_kind)
	return RuleEvaluator.has_property(query, property, rules, state)


static func _moves_for(ordered: Array[RuleGridEntity], destinations: Dictionary) -> Dictionary:
	var moves: Array[Dictionary] = []
	for entity: RuleGridEntity in ordered:
		if destinations.has(entity.id) and destinations[entity.id] != entity.position:
			moves.append({"entity_id": entity.id, "from": entity.position, "to": destinations[entity.id]})
	if moves.is_empty():
		return _blocked_plan()
	return {"can_move": true, "moves": moves}


static func _moves_between_states(original: RuleGridState, result: RuleGridState) -> Dictionary:
	if original == null or result == null:
		return _blocked_plan()
	var original_by_id: Dictionary = {}
	for entity: RuleGridEntity in original.entities:
		original_by_id[entity.id] = entity
	var ordered: Array[RuleGridEntity] = []
	ordered.assign(result.entities)
	ordered.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return _priority_less(a, b)
	)
	var moves: Array[Dictionary] = []
	for entity: RuleGridEntity in ordered:
		if not original_by_id.has(entity.id):
			continue
		var source: RuleGridEntity = original_by_id[entity.id]
		if source.position == entity.position:
			continue
		moves.append({"entity_id": entity.id, "from": source.position, "to": entity.position})
	if moves.is_empty():
		return _blocked_plan()
	return {"can_move": true, "moves": moves}


static func _apply_position_moves(state: RuleGridState, moves: Array[Dictionary]) -> void:
	for move: Dictionary in moves:
		var entity := _find_entity(state, String(move["entity_id"]))
		if entity != null:
			entity.position = move["to"]


static func _copy_state(state: RuleGridState) -> RuleGridState:
	if state == null:
		return null
	return RuleGridState.from_dictionary(state.to_dictionary())


static func _entities_at(state: RuleGridState, cell: Vector2i) -> Array[RuleGridEntity]:
	var result: Array[RuleGridEntity] = []
	if state == null:
		return result
	for entity: RuleGridEntity in state.entities:
		if entity.position == cell:
			result.append(entity)
	result.sort_custom(func(a: RuleGridEntity, b: RuleGridEntity) -> bool:
		return _priority_less(a, b)
	)
	return result


static func _find_entity(state: RuleGridState, entity_id: String) -> RuleGridEntity:
	for entity: RuleGridEntity in state.entities:
		if entity.id == entity_id:
			return entity
	return null


static func _priority_less(a: RuleGridEntity, b: RuleGridEntity) -> bool:
	if a.position.x != b.position.x:
		return a.position.x < b.position.x
	if a.position.y != b.position.y:
		return a.position.y < b.position.y
	if a.layer != b.layer:
		return a.layer < b.layer
	if a.creation_serial != b.creation_serial:
		return a.creation_serial < b.creation_serial
	return a.id < b.id


static func _inside_board(cell: Vector2i, width: int, height: int) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


static func _is_cardinal(direction: Vector2i) -> bool:
	return absi(direction.x) + absi(direction.y) == 1


static func _blocked_plan() -> Dictionary:
	return {"can_move": false, "moves": []}
