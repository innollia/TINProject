extends GameModule

const ACTIONS: Array[StringName] = [
	&"rule_rewriting_left", &"rule_rewriting_right", &"rule_rewriting_up", &"rule_rewriting_down",
	&"rule_rewriting_confirm", &"rule_rewriting_cancel", &"rule_rewriting_undo", &"rule_rewriting_reset",
	&"rule_rewriting_forward", &"rule_rewriting_turn_left", &"rule_rewriting_turn_right",
	&"rule_rewriting_cycle_3d_subject", &"rule_rewriting_open_inventory", &"rule_rewriting_cycle_metrix",
	&"rule_rewriting_place", &"rule_rewriting_hotbar_1", &"rule_rewriting_hotbar_2",
	&"rule_rewriting_hotbar_3", &"rule_rewriting_hotbar_4", &"rule_rewriting_hotbar_5",
	&"rule_rewriting_hotbar_6", &"rule_rewriting_hotbar_7", &"rule_rewriting_hotbar_8",
	&"rule_rewriting_hotbar_9"
]
const MAX_HISTORY: int = 64
const MAX_COUNTER: int = 999999
const SAVE_VERSION: int = 5
const MAX_WORD_FIXED_POINT_STEPS: int = 128

var board_id: StringName = &""
var grid_state: RuleGridState
var rule_set: RuleSet = RuleSet.new()
var solved: bool = false
var failed: bool = false
var turn_index: int = 0
var selected_3d_subject_id: String = ""
var selected_metrix_id: String = ""
var hotbar_slot: int = 0
var completed_board_ids: Array[String] = []
var metrix_shapes: Array[Dictionary] = []

var _undo_stack: Array[Dictionary] = []
var _held_entity_id: String = ""
var _held_origin: Vector2i = Vector2i(-1, -1)
var _focused_slot: int = 0
var _stack_focus: int = 0
var _camera_quadrant: int = 0
var _inventory_open: bool = false
var _message: String = ""
var _held_actions: Dictionary = {}
var _request_sent: bool = false
var _view: RuleBoardView
var _pending_rule_feedback_ids: Array[String] = []
var _metrix_geometry_cache_key: String = ""
var _cached_metrix_shapes: Array[Dictionary] = []


func _ready() -> void:
	_view = RuleBoardView.new()
	_view.name = "RuleRewritePresentation"
	_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_view.command_requested.connect(_on_view_command)
	add_child(_view)
	load_state({})


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_request_sent = false
	_held_actions.clear()
	_refresh()


func exit() -> void:
	_held_actions.clear()
	_held_entity_id = ""
	_inventory_open = false
	super.exit()


func _process(_delta: float) -> void:
	if not _can_input():
		_held_actions.clear()
		return
	for action: StringName in ACTIONS:
		var pressed := context.is_action_pressed(action)
		var previous: bool = bool(_held_actions.get(action, false))
		_held_actions[action] = pressed
		if pressed and not previous:
			_execute_action(action)


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"move":
			if solved:
				return false
			var direction := _read_direction(payload)
			if direction == Vector2i.ZERO:
				return false
			if _inventory_open:
				_move_inventory_focus(direction)
			else:
				_move_you(direction)
		&"forward":
			if solved:
				return false
			_move_3d_forward()
		&"turn_left":
			_turn_camera(-1)
		&"turn_right":
			_turn_camera(1)
		&"cycle_3d_subject":
			_cycle_3d_subject()
		&"open_inventory":
			_toggle_inventory()
		&"cycle_metrix":
			_cycle_metrix()
		&"hotbar":
			_set_hotbar_slot(int(payload.get("slot", -1)))
		&"inventory_slot":
			_inventory_slot_action(int(payload.get("slot", -1)))
		&"place":
			if solved:
				return false
			_place_hotbar_entity(payload)
		&"undo":
			_undo()
		&"reset":
			_reset_board()
		&"confirm":
			if solved:
				_advance_board()
			elif _inventory_open:
				_inventory_slot_action(_focused_slot)
			else:
				return false
		&"cancel", &"back":
			if _held_entity_id != "":
				_held_entity_id = ""
				_held_origin = Vector2i(-1, -1)
				_message = "물건을 원래 칸에 두었다."
			elif _inventory_open:
				_inventory_open = false
			else:
				_request_exit("back")
		_:
			return false
	_refresh()
	return true


func save_state() -> Dictionary:
	return {
		"state_format": SAVE_VERSION,
		"board_schema_version": RuleLevelLoader.BOARD_SCHEMA_VERSION,
		"board_id": String(board_id),
		"grid": grid_state.to_dictionary() if grid_state != null else {},
		"solved": solved,
		"failed": failed,
		"turn_index": turn_index,
		"selected_3d_subject_id": selected_3d_subject_id,
		"selected_metrix_id": selected_metrix_id,
		"hotbar_slot": hotbar_slot,
		"completed_board_ids": completed_board_ids.duplicate(),
		"undo_stack": _undo_stack.duplicate(true)
	}


func load_state(state: Dictionary) -> void:
	var clean := _normalize_state(state)
	board_id = StringName(clean["board_id"])
	grid_state = RuleGridState.from_dictionary(clean["grid"])
	solved = bool(clean["solved"])
	failed = bool(clean["failed"])
	turn_index = int(clean["turn_index"])
	selected_3d_subject_id = String(clean["selected_3d_subject_id"])
	selected_metrix_id = String(clean["selected_metrix_id"])
	hotbar_slot = int(clean["hotbar_slot"])
	completed_board_ids.assign(clean["completed_board_ids"])
	_undo_stack.clear()
	for snapshot: Variant in clean["undo_stack"]:
		_undo_stack.append(snapshot)
	_held_entity_id = ""
	_held_origin = Vector2i(-1, -1)
	_focused_slot = 0
	_stack_focus = 0
	_camera_quadrant = 0
	_inventory_open = false
	_message = ""
	_request_sent = false
	_rebuild_derived()
	_refresh()


func migrate_save(old_version: int, data: Dictionary) -> Dictionary:
	if old_version < SAVE_VERSION:
		return _default_state()
	return _normalize_state(data)


func _execute_action(action: StringName) -> void:
	match action:
		&"rule_rewriting_left": execute_command(&"move", {"direction": Vector2i.LEFT})
		&"rule_rewriting_right": execute_command(&"move", {"direction": Vector2i.RIGHT})
		&"rule_rewriting_up": execute_command(&"move", {"direction": Vector2i.UP})
		&"rule_rewriting_down": execute_command(&"move", {"direction": Vector2i.DOWN})
		&"rule_rewriting_confirm": execute_command(&"confirm")
		&"rule_rewriting_cancel": execute_command(&"cancel")
		&"rule_rewriting_undo": execute_command(&"undo")
		&"rule_rewriting_reset": execute_command(&"reset")
		&"rule_rewriting_forward": execute_command(&"forward")
		&"rule_rewriting_turn_left": execute_command(&"turn_left")
		&"rule_rewriting_turn_right": execute_command(&"turn_right")
		&"rule_rewriting_cycle_3d_subject": execute_command(&"cycle_3d_subject")
		&"rule_rewriting_open_inventory": execute_command(&"open_inventory")
		&"rule_rewriting_cycle_metrix": execute_command(&"cycle_metrix")
		&"rule_rewriting_place": execute_command(&"place")
		_:
			for index: int in range(9):
				if action == StringName("rule_rewriting_hotbar_%d" % (index + 1)):
					execute_command(&"hotbar", {"slot": index})
					break


func _on_view_command(command: StringName, payload: Dictionary) -> void:
	if not _can_input():
		return
	execute_command(command, payload)


func _move_you(direction: Vector2i) -> void:
	var controlled_ids := _you_ids()
	if controlled_ids.is_empty():
		_message = ""
		return
	_apply_player_intent(controlled_ids, direction)


func _move_3d_forward() -> void:
	var subject := _selected_3d_subject()
	if subject == null:
		return
	if _inventory_open:
		return
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	_apply_player_intent([subject.id], directions[_camera_quadrant])


func _apply_player_intent(controlled_ids: Array[String], direction: Vector2i) -> void:
	var before := _board_snapshot()
	var before_rule_set := rule_set
	var before_rules := _rule_signature()
	var plan := RuleMovementSolver.plan_move_many(grid_state, rule_set, controlled_ids, direction)
	if not bool(plan.get("can_move", false)):
		_message = ""
		return
	_apply_moves(plan.get("moves", []))
	for entity_id: String in controlled_ids:
		var actor := _find_entity(entity_id)
		if actor != null:
			actor.facing = direction
	var processed_transform_ids: Dictionary = {}
	_rebuild_derived()
	var transform_result := RuleEvaluator.apply_transformations(grid_state, rule_set, processed_transform_ids)
	if not bool(transform_result.get("valid", false)):
		_restore_snapshot(before)
		return
	var transformed_ids: Array = transform_result.get("changed_ids", [])
	var created_ids: Array = transform_result.get("created_ids", [])
	if not transformed_ids.is_empty() or not created_ids.is_empty():
		_rebuild_derived()
	var auto_plan := RuleMovementSolver.plan_move_auto(grid_state, rule_set)
	if not bool(auto_plan.get("valid", false)):
		_restore_snapshot(before)
		return
	_apply_moves(auto_plan.get("moves", []))
	if bool(auto_plan.get("word_moved", false)):
		_rebuild_derived()
		transform_result = RuleEvaluator.apply_transformations(grid_state, rule_set, processed_transform_ids)
		if not bool(transform_result.get("valid", false)):
			_restore_snapshot(before)
			return
		transformed_ids = transform_result.get("changed_ids", [])
		created_ids = transform_result.get("created_ids", [])
		if not transformed_ids.is_empty() or not created_ids.is_empty():
			_rebuild_derived()
	_resolve_interactions()
	_commit_intent(before)
	if _rule_signature() != before_rules:
		_pending_rule_feedback_ids = _rule_change_feedback_ids(
			before["grid"], before_rule_set, grid_state, rule_set
		)
		_message = ""
	else:
		_pending_rule_feedback_ids.clear()
		_message = ""


func _apply_moves(moves: Variant) -> void:
	if not moves is Array:
		return
	for move_value: Variant in moves:
		if not move_value is Dictionary:
			continue
		var entity := _find_entity(String(move_value.get("entity_id", "")))
		if entity == null:
			continue
		var destination: Variant = move_value.get("to")
		if destination is Vector2i:
			entity.position = destination
		var facing: Variant = move_value.get("facing_to")
		if facing is Vector2i:
			entity.facing = facing
		elif move_value.get("direction") is Vector2i:
			entity.facing = move_value["direction"]


func _resolve_interactions() -> void:
	var result: Dictionary = RuleEvaluator.resolve_contacts(grid_state, rule_set)
	if not bool(result.get("valid", false)):
		return
	var removed_ids: Dictionary = {}
	for entity_id: String in result.get("removed_ids", []):
		removed_ids[entity_id] = true
	var spawn_result := _append_has_spawns(result.get("has_spawns", []))
	if not removed_ids.is_empty():
		var survivors: Array[RuleGridEntity] = []
		for entity: RuleGridEntity in grid_state.entities:
			if not removed_ids.has(entity.id):
				survivors.append(entity)
		grid_state.entities = survivors
	if not removed_ids.is_empty() or bool(spawn_result.get("changed", false)):
		_rebuild_derived()
	failed = bool(result.get("failed", false)) and _you_ids().is_empty()
	solved = bool(result.get("won", false)) and not failed
	if failed:
		_inventory_open = false
		_held_entity_id = ""
		_held_origin = Vector2i(-1, -1)
	if solved:
		_mark_completed()


func _append_has_spawns(value: Variant) -> Dictionary:
	if not value is Array:
		return {"changed": false}
	var next_serial := 0
	var used_ids: Dictionary = {}
	for entity: RuleGridEntity in grid_state.entities:
		if entity == null:
			continue
		used_ids[entity.id] = true
		next_serial = maxi(next_serial, entity.creation_serial + 1)
	var changed := false
	for descriptor: Variant in value:
		if not descriptor is Dictionary:
			continue
		var source_id := String(descriptor.get("source_id", ""))
		var kind := StringName(String(descriptor.get("kind", "")))
		var position: Variant = descriptor.get("position")
		var facing: Variant = descriptor.get("facing")
		if source_id.is_empty() or not RuleLevelLoader.OBJECT_CATALOG.has(kind) \
			or not position is Vector2i or not facing is Vector2i \
			or not _inside_board(position):
			continue
		var entity := RuleGridEntity.new()
		var id_prefix := "has::%s::%d::%s" % [source_id, mini(turn_index + 1, MAX_COUNTER), String(kind)]
		entity.id = id_prefix
		var suffix := 1
		while used_ids.has(entity.id):
			entity.id = "%s::%d" % [id_prefix, suffix]
			suffix += 1
		entity.kind = kind
		entity.position = position
		entity.facing = facing
		var layer_value: Variant = descriptor.get("layer", 0)
		if RuleGridEntity._is_integer(layer_value):
			entity.layer = int(layer_value)
		entity.creation_serial = next_serial
		next_serial += 1
		used_ids[entity.id] = true
		grid_state.entities.append(entity)
		changed = true
	return {"changed": changed}


func _turn_camera(turns: int) -> void:
	if not _is_3d_mode():
		return
	_camera_quadrant = posmod(_camera_quadrant + turns, 4)
	_message = ""
	_refresh()


func _cycle_3d_subject() -> void:
	var subjects := _three_d_you_entities()
	if subjects.is_empty():
		return
	var current_index := 0
	for index: int in range(subjects.size()):
		if subjects[index].id == selected_3d_subject_id:
			current_index = index
			break
	selected_3d_subject_id = subjects[posmod(current_index + 1, subjects.size())].id
	_message = ""
	_refresh()


func _toggle_inventory() -> void:
	if not _is_3d_mode():
		return
	if _inventory_open:
		_inventory_open = false
		_held_entity_id = ""
		_held_origin = Vector2i(-1, -1)
		_message = ""
		return
	var available := _available_inventories()
	if available.is_empty():
		_message = ""
		return
	_inventory_open = true
	_focused_slot = clampi(_focused_slot, 0, maxi(0, _slot_count(_selected_metrix()) - 1))
	_message = ""


func _cycle_metrix() -> void:
	var available := _available_inventories()
	if available.is_empty():
		return
	var index := 0
	for candidate: Dictionary in available:
		if String(candidate["id"]) == selected_metrix_id:
			index = available.find(candidate)
			break
	selected_metrix_id = String(available[posmod(index + 1, available.size())]["id"])
	_focused_slot = 0
	_held_entity_id = ""
	_message = ""
	_refresh()


func _set_hotbar_slot(slot: int) -> void:
	if slot < 0 or slot > 8:
		return
	hotbar_slot = slot
	_message = ""
	_refresh()


func _move_inventory_focus(direction: Vector2i) -> void:
	var shape := _selected_metrix()
	var slots := _shape_slots(shape)
	if slots.is_empty():
		return
	var width := maxi(1, int(shape["bounds"].size.x) - 2)
	var height := maxi(1, int(shape["bounds"].size.y) - 2)
	var cell := Vector2i(_focused_slot % width, _focused_slot / width)
	cell += direction
	cell.x = posmod(cell.x, width)
	cell.y = posmod(cell.y, height)
	_focused_slot = mini(cell.y * width + cell.x, slots.size() - 1)
	_refresh()


func _inventory_slot_action(slot_index: int) -> void:
	var slots := _shape_slots(_selected_metrix())
	if slot_index < 0 or slot_index >= slots.size():
		return
	_focused_slot = slot_index
	var slot: Dictionary = slots[slot_index]
	var cell_value: Variant = slot.get("cell")
	if not cell_value is Vector2i:
		return
	var contents := _slot_entity_ids(slot)
	if _held_entity_id.is_empty():
		if contents.is_empty():
			_stack_focus = 0
			_message = ""
			_refresh()
			return
		var entity_index := posmod(_stack_focus, contents.size())
		_held_entity_id = contents[entity_index]
		_stack_focus = 0
		var selected := _find_entity(_held_entity_id)
		if selected != null:
			_held_origin = selected.position
		_message = ""
		_refresh()
		return
	var held := _find_entity(_held_entity_id)
	if held == null:
		_held_entity_id = ""
		_held_origin = Vector2i(-1, -1)
		_refresh()
		return
	if held.position == cell_value:
		_stack_focus += 1
		var same_cell := _entities_at(cell_value)
		if not same_cell.is_empty():
			_stack_focus = posmod(_stack_focus, same_cell.size())
			_held_entity_id = same_cell[_stack_focus].id
		_refresh()
		return
	var before := _board_snapshot()
	var target_ids := _slot_entity_ids(slot)
	if target_ids.has(_held_entity_id):
		_held_entity_id = ""
		_held_origin = Vector2i(-1, -1)
		_refresh()
		return
	var occupant_id: String = String(target_ids.front()) if not target_ids.is_empty() else ""
	if not occupant_id.is_empty():
		var occupant: RuleGridEntity = _find_entity(occupant_id)
		if occupant != null:
			occupant.position = _held_origin
	held.position = cell_value
	_held_entity_id = ""
	_held_origin = Vector2i(-1, -1)
	_rebuild_derived()
	_resolve_interactions()
	_commit_intent(before)
	_message = ""
	_refresh()


func _place_hotbar_entity(payload: Dictionary) -> void:
	if not _is_3d_mode() or _inventory_open:
		return
	var slots := _shape_slots(_selected_metrix())
	if hotbar_slot >= slots.size():
		return
	var ids := _slot_entity_ids(slots[hotbar_slot])
	if ids.is_empty():
		return
	var entity := _find_entity(ids.front())
	var subject := _selected_3d_subject()
	if entity == null or subject == null:
		return
	var target: Vector2i = payload.get("cell", Vector2i(-1, -1))
	if target == Vector2i(-1, -1):
		var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
		target = subject.position + directions[_camera_quadrant]
	if not _inside_board(target):
		return
	for other: RuleGridEntity in _entities_at(target):
		if other.id == entity.id:
			continue
		if _has_property(other, &"STOP") or _has_property(other, &"PUSH"):
			return
	var before := _board_snapshot()
	entity.position = target
	_rebuild_derived()
	_resolve_interactions()
	_commit_intent(before)
	_message = ""
	_refresh()


func _undo() -> void:
	if _undo_stack.is_empty():
		return
	var snapshot: Dictionary = _undo_stack.pop_back()
	if not _restore_snapshot(snapshot):
		_undo_stack.clear()
		return
	_message = ""
	_refresh()


func _reset_board() -> void:
	var preserved_completed := completed_board_ids.duplicate()
	preserved_completed.erase(String(board_id))
	var level := RuleLevelLoader.load_level(board_id)
	if not bool(level.get("ok", false)):
		return
	grid_state = level["state"] as RuleGridState
	solved = false
	failed = false
	turn_index = 0
	selected_3d_subject_id = ""
	selected_metrix_id = ""
	hotbar_slot = 0
	completed_board_ids.assign(preserved_completed)
	_undo_stack.clear()
	_inventory_open = false
	_held_entity_id = ""
	_rebuild_derived()
	_message = ""
	_refresh()


func _advance_board() -> void:
	var ids := _progression_board_ids()
	var index := ids.find(board_id)
	if index >= 0 and index + 1 < ids.size():
		var next_id := ids[index + 1]
		var completed := completed_board_ids.duplicate()
		var level := RuleLevelLoader.load_level(next_id)
		if not bool(level.get("ok", false)):
			return
		board_id = next_id
		grid_state = level["state"] as RuleGridState
		solved = false
		failed = false
		turn_index = 0
		selected_3d_subject_id = ""
		selected_metrix_id = ""
		hotbar_slot = 0
		completed_board_ids.assign(completed)
		_undo_stack.clear()
		_rebuild_derived()
		_message = ""
		_refresh()
		return
	_request_exit("forward")


func _progression_board_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for board_id_value: StringName in RuleLevelLoader.list_level_ids():
		if String(board_id_value).begins_with("rule_"):
			result.append(board_id_value)
	return result


func _commit_intent(before: Dictionary) -> void:
	if _board_snapshot() == before:
		return
	turn_index = mini(turn_index + 1, MAX_COUNTER)
	_undo_stack.append(before)
	if _undo_stack.size() > MAX_HISTORY:
		_undo_stack.pop_front()


func _board_snapshot() -> Dictionary:
	return {
		"board_id": String(board_id),
		"grid": grid_state.to_dictionary(),
		"solved": solved,
		"failed": failed,
		"turn_index": turn_index,
		"selected_3d_subject_id": selected_3d_subject_id,
		"selected_metrix_id": selected_metrix_id,
		"hotbar_slot": hotbar_slot,
		"completed_board_ids": completed_board_ids.duplicate()
	}


func _restore_snapshot(snapshot: Dictionary) -> bool:
	var normalized := _normalize_snapshot(snapshot, board_id)
	if normalized.is_empty():
		return false
	board_id = StringName(normalized["board_id"])
	grid_state = RuleGridState.from_dictionary(normalized["grid"])
	solved = bool(normalized["solved"])
	failed = bool(normalized["failed"])
	turn_index = int(normalized["turn_index"])
	selected_3d_subject_id = String(normalized["selected_3d_subject_id"])
	selected_metrix_id = String(normalized["selected_metrix_id"])
	hotbar_slot = int(normalized["hotbar_slot"])
	completed_board_ids.assign(normalized["completed_board_ids"])
	_rebuild_derived()
	return true


func _default_state() -> Dictionary:
	var ids := RuleLevelLoader.list_level_ids()
	if ids.is_empty():
		return {"state_format": SAVE_VERSION}
	var first_id := ids[0]
	var level := RuleLevelLoader.load_level(first_id)
	if not bool(level.get("ok", false)):
		return {"state_format": SAVE_VERSION}
	var initial_grid := level["state"] as RuleGridState
	return {
		"state_format": SAVE_VERSION,
		"board_schema_version": RuleLevelLoader.BOARD_SCHEMA_VERSION,
		"board_id": String(first_id),
		"grid": initial_grid.to_dictionary(),
		"solved": false,
		"failed": false,
		"turn_index": 0,
		"selected_3d_subject_id": "",
		"selected_metrix_id": "",
		"hotbar_slot": 0,
		"completed_board_ids": [],
		"undo_stack": []
	}


func _normalize_state(data: Dictionary) -> Dictionary:
	var defaults := _default_state()
	var format_value: Variant = data.get("state_format")
	var schema_value: Variant = data.get("board_schema_version")
	if not RuleGridEntity._is_integer(format_value) or int(format_value) != SAVE_VERSION \
		or not RuleGridEntity._is_integer(schema_value) or int(schema_value) != RuleLevelLoader.BOARD_SCHEMA_VERSION:
		return defaults
	var ids := RuleLevelLoader.list_level_ids()
	if ids.is_empty():
		return defaults
	var requested_id := StringName(String(data.get("board_id", String(ids[0]))))
	if not ids.has(requested_id):
		requested_id = ids[0]
	var level := RuleLevelLoader.load_level(requested_id)
	if not bool(level.get("ok", false)):
		requested_id = ids[0]
		level = RuleLevelLoader.load_level(requested_id)
	if not bool(level.get("ok", false)):
		return defaults
	var authored := level["state"] as RuleGridState
	var candidate := RuleGridState.from_dictionary(data.get("grid"))
	if candidate == null or not _grid_matches_level(candidate, authored):
		candidate = RuleGridState.from_dictionary(authored.to_dictionary())
	var clean_failed: bool = data.get("failed") if data.get("failed") is bool else false
	var clean_solved: bool = data.get("solved") if data.get("solved") is bool else false
	if clean_failed:
		clean_solved = false
	var completed := _normalize_completed(data.get("completed_board_ids", []), ids)
	var clean_history: Array[Dictionary] = []
	if data.get("undo_stack") is Array:
		for value: Variant in data["undo_stack"]:
			var snapshot := _normalize_snapshot(value, requested_id)
			if not snapshot.is_empty():
				clean_history.append(snapshot)
		if clean_history.size() > MAX_HISTORY:
			clean_history = clean_history.slice(clean_history.size() - MAX_HISTORY)
	var selected_subject := String(data.get("selected_3d_subject_id", ""))
	if _find_entity_in(candidate, selected_subject) == null:
		selected_subject = ""
	var selected_metrix := String(data.get("selected_metrix_id", ""))
	return {
		"state_format": SAVE_VERSION,
		"board_schema_version": RuleLevelLoader.BOARD_SCHEMA_VERSION,
		"board_id": String(requested_id),
		"grid": candidate.to_dictionary(),
		"solved": clean_solved,
		"failed": clean_failed,
		"turn_index": _integer(data.get("turn_index"), 0, 0, MAX_COUNTER),
		"selected_3d_subject_id": selected_subject,
		"selected_metrix_id": selected_metrix,
		"hotbar_slot": _integer(data.get("hotbar_slot"), 0, 0, 8),
		"completed_board_ids": completed,
		"undo_stack": clean_history
	}


func _normalize_snapshot(value: Variant, fallback_board_id: StringName) -> Dictionary:
	if not value is Dictionary:
		return {}
	var snapshot_id := StringName(String(value.get("board_id", String(fallback_board_id))))
	if snapshot_id != fallback_board_id or not RuleLevelLoader.list_level_ids().has(snapshot_id):
		return {}
	var level := RuleLevelLoader.load_level(snapshot_id)
	if not bool(level.get("ok", false)):
		return {}
	var authored := level["state"] as RuleGridState
	var candidate := RuleGridState.from_dictionary(value.get("grid"))
	if candidate == null or not _grid_matches_level(candidate, authored):
		return {}
	var clean_failed: bool = value.get("failed") if value.get("failed") is bool else false
	var clean_solved: bool = value.get("solved") if value.get("solved") is bool else false
	if clean_failed:
		clean_solved = false
	return {
		"board_id": String(snapshot_id),
		"grid": candidate.to_dictionary(),
		"solved": clean_solved,
		"failed": clean_failed,
		"turn_index": _integer(value.get("turn_index"), 0, 0, MAX_COUNTER),
		"selected_3d_subject_id": String(value.get("selected_3d_subject_id", "")),
		"selected_metrix_id": String(value.get("selected_metrix_id", "")),
		"hotbar_slot": _integer(value.get("hotbar_slot"), 0, 0, 8),
		"completed_board_ids": _normalize_completed(value.get("completed_board_ids", []), RuleLevelLoader.list_level_ids())
	}


func _normalize_completed(value: Variant, available: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	if not value is Array:
		return result
	for item: Variant in value:
		if not item is String:
			continue
		var item_id := StringName(item)
		if available.has(item_id) and not result.has(String(item_id)):
			result.append(String(item_id))
	return result


func _grid_matches_level(candidate: RuleGridState, authored: RuleGridState) -> bool:
	if candidate.width != authored.width or candidate.height != authored.height:
		return false
	var original_by_id: Dictionary = {}
	for original: RuleGridEntity in authored.entities:
		original_by_id[original.id] = original
	var seen: Dictionary = {}
	for entity: RuleGridEntity in candidate.entities:
		if entity == null or seen.has(entity.id):
			return false
		seen[entity.id] = true
		if original_by_id.has(entity.id):
			var original: RuleGridEntity = original_by_id[entity.id]
			if original.is_word:
				if not entity.is_word or entity.kind != original.kind \
					or entity.word_role != original.word_role or entity.word_value != original.word_value:
					return false
			elif entity.is_word or not RuleLevelLoader.OBJECT_CATALOG.has(entity.kind):
				return false
		elif entity.is_word or not _is_valid_generated_entity_id(entity.id, entity.kind) \
			or not RuleLevelLoader.OBJECT_CATALOG.has(entity.kind):
			return false
	for original: RuleGridEntity in authored.entities:
		if original.is_word and not seen.has(original.id):
			return false
	return true


func _is_valid_generated_entity_id(entity_id: String, kind: StringName) -> bool:
	if entity_id.begins_with("transform::"):
		return true
	if not entity_id.begins_with("has::"):
		return false
	var kind_suffix := "::" + String(kind)
	var generated_id := entity_id
	if not generated_id.ends_with(kind_suffix):
		var collision_separator := generated_id.rfind("::")
		if collision_separator < 0:
			return false
		var collision_suffix := generated_id.substr(collision_separator + 2)
		if not collision_suffix.is_valid_int() or int(collision_suffix) < 1:
			return false
		generated_id = generated_id.substr(0, collision_separator)
	if not generated_id.ends_with(kind_suffix):
		return false
	generated_id = generated_id.substr(0, generated_id.length() - kind_suffix.length())
	var turn_separator := generated_id.rfind("::")
	if turn_separator < 0:
		return false
	var turn_text := generated_id.substr(turn_separator + 2)
	if not turn_text.is_valid_int() or int(turn_text) < 1 or int(turn_text) > MAX_COUNTER:
		return false
	var source_id := generated_id.substr("has::".length(), turn_separator - "has::".length())
	return not source_id.is_empty()


func _rebuild_derived() -> void:
	if grid_state == null:
		rule_set = RuleSet.new()
		metrix_shapes.clear()
		return
	rule_set = _resolve_word_rules()
	var subjects := _three_d_you_entities()
	if not subjects.is_empty():
		var selected_exists := false
		for subject: RuleGridEntity in subjects:
			if subject.id == selected_3d_subject_id:
				selected_exists = true
		if not selected_exists:
			selected_3d_subject_id = subjects[0].id
	else:
		selected_3d_subject_id = ""
	metrix_shapes.clear()
	var geometry_signature := _metrix_geometry_signature()
	if geometry_signature != _metrix_geometry_cache_key:
		_cached_metrix_shapes = RuleMetrixResolver.resolve(grid_state, _has_metrix_rule())
		_metrix_geometry_cache_key = geometry_signature
	var raw_shapes: Array[Dictionary] = []
	for cached_shape: Dictionary in _cached_metrix_shapes:
		raw_shapes.append(cached_shape.duplicate(true))
	var active_restriction := _has_metrix_property_rule(&"ACTIVE")
	for shape: Dictionary in raw_shapes:
		var probe := _metrix_probe(shape)
		if not _inside_rule_matches(shape, probe):
			continue
		var inv_enabled := _shape_has_property(shape, probe, &"INV")
		var active := not active_restriction or _shape_has_property(shape, probe, &"ACTIVE")
		var owner_ids := _shape_owner_ids(shape, probe)
		shape["inventory"] = inv_enabled and not owner_ids.is_empty() and active
		shape["owner_ids"] = owner_ids
		metrix_shapes.append(shape)
	var available := _available_inventories()
	if available.is_empty():
		_inventory_open = false
		_held_entity_id = ""
		if _selected_3d_subject() != null:
			selected_metrix_id = ""
	else:
		var still_valid := false
		for shape: Dictionary in available:
			if String(shape["id"]) == selected_metrix_id:
				still_valid = true
		if not still_valid:
			selected_metrix_id = String(available[0]["id"])


func _metrix_geometry_signature() -> String:
	var metrix_active := _has_metrix_rule()
	var parts: Array = [grid_state.width, grid_state.height, metrix_active]
	if not metrix_active:
		return JSON.stringify(parts)
	for entity: RuleGridEntity in grid_state.entities:
		if entity == null:
			parts.append(null)
			continue
		parts.append([
			entity.id, String(entity.kind), entity.position.x, entity.position.y, entity.is_word
		])
	return JSON.stringify(parts)


func _resolve_word_rules() -> RuleSet:
	var physical_rules := RuleParser.parse(grid_state.width, grid_state.height, grid_state.entities)
	var disabled_word_sources: Dictionary = {}
	var step_limit := mini(MAX_WORD_FIXED_POINT_STEPS, maxi(1, grid_state.entities.size() + 1))
	for resolve_pass: int in range(maxi(1, grid_state.entities.size() + 1)):
		var current_rules := physical_rules
		var signatures: Array[String] = []
		var promoted_by_state: Array[Dictionary] = []
		var restart_from_physical := false
		for step: int in range(step_limit):
			var current_signature := _rule_resolution_signature(current_rules)
			signatures.append(current_signature)
			var parse_input := _word_parse_input(current_rules, disabled_word_sources)
			promoted_by_state.append(parse_input["promoted_ids"])
			var next_rules := RuleParser.parse(
				grid_state.width,
				grid_state.height,
				parse_input["entities"]
			)
			var next_signature := _rule_resolution_signature(next_rules)
			if next_signature == current_signature:
				return next_rules
			var repeated_at := signatures.find(next_signature)
			if repeated_at >= 0:
				var next_input := _word_parse_input(next_rules, disabled_word_sources)
				var cycle_sources := _varying_word_sources(promoted_by_state, repeated_at, next_input["promoted_ids"])
				if cycle_sources.is_empty():
					return physical_rules
				for source_id: String in cycle_sources.keys():
					disabled_word_sources[source_id] = true
				restart_from_physical = true
				break
			current_rules = next_rules
		if not restart_from_physical:
			return physical_rules
	return physical_rules


func _word_parse_input(rules: RuleSet, disabled_sources: Dictionary) -> Dictionary:
	var entities: Array[RuleGridEntity] = []
	entities.assign(grid_state.entities)
	var promoted_ids: Dictionary = {}
	for entity: RuleGridEntity in grid_state.entities:
		if entity == null or entity.is_word or disabled_sources.has(entity.id) \
			or entity.base_tags.has(&"WORD") or entity.runtime_tags.has(&"WORD") \
			or not RuleEvaluator.has_property(entity, &"WORD", rules, grid_state):
			continue
		var token := RuleGridEntity.new()
		token.id = entity.id
		token.kind = entity.kind
		token.position = entity.position
		token.facing = entity.facing
		token.layer = entity.layer
		token.creation_serial = entity.creation_serial
		token.is_word = true
		token.word_role = &"noun"
		token.word_value = entity.kind
		entities.append(token)
		promoted_ids[entity.id] = true
	return {"entities": entities, "promoted_ids": promoted_ids}


func _varying_word_sources(
	states: Array[Dictionary],
	start_index: int,
	next_state: Dictionary
) -> Dictionary:
	var all_sources: Dictionary = {}
	var common_sources: Dictionary = {}
	var initialized := false
	var state_count := states.size() + 1
	for state_index: int in range(start_index, state_count):
		var sources: Dictionary = next_state if state_index == states.size() else states[state_index]
		for source_id: Variant in sources.keys():
			all_sources[String(source_id)] = true
		if not initialized:
			common_sources = sources.duplicate()
			initialized = true
		else:
			for source_id: Variant in common_sources.keys():
				if not sources.has(source_id):
					common_sources.erase(source_id)
	var varying_sources: Dictionary = {}
	for source_id: Variant in all_sources.keys():
		if not common_sources.has(source_id):
			varying_sources[String(source_id)] = true
	return varying_sources


func _rule_resolution_signature(rules: RuleSet) -> String:
	var signatures: Array[String] = []
	for sentence: RuleSentence in rules.sentences:
		var source_ids := sentence.source_entity_ids.duplicate()
		source_ids.sort()
		var condition_parts: Array[String] = []
		for condition: Dictionary in sentence.conditions:
			condition_parts.append("%s:%s:%s" % [
				String(condition.get("kind", "")),
				String(condition.get("target", "")),
				str(bool(condition.get("negated", false)))
			])
		signatures.append("%s|%s|%s|%s|%s|%s|%s|%s" % [
			String(sentence.subject), str(sentence.subject_is_negated),
			String(sentence.operator), String(sentence.predicate_role),
			String(sentence.predicate), str(sentence.is_negated),
			";".join(condition_parts), ";".join(source_ids)
		])
	signatures.sort()
	return "\n".join(signatures)


func _has_metrix_rule() -> bool:
	for sentence: RuleSentence in rule_set.sentences:
		if sentence.operator == &"INSIDE_IS" and sentence.subject == &"BOX" \
			and sentence.predicate == &"METRIX":
			return true
	return false


func _has_metrix_property_rule(property: StringName) -> bool:
	for sentence: RuleSentence in rule_set.sentences:
		if sentence.operator == &"IS" and sentence.subject == &"METRIX" \
			and sentence.predicate_role == &"property" and sentence.predicate == property:
			return true
	return false


func _inside_rule_matches(shape: Dictionary, probe: RuleGridEntity) -> bool:
	var positive := false
	var negative := false
	for sentence: RuleSentence in rule_set.sentences:
		if sentence.operator != &"INSIDE_IS" or sentence.subject != &"BOX" or sentence.predicate != &"METRIX":
			continue
		if not _shape_conditions_match(shape, probe, sentence.conditions):
			continue
		if sentence.is_negated:
			negative = true
		else:
			positive = true
	return positive and not negative


func _metrix_probe(shape: Dictionary) -> RuleGridEntity:
	var probe := RuleGridEntity.new()
	probe.id = String(shape.get("id", "metrix_probe"))
	probe.kind = &"METRIX"
	var bounds: Variant = shape.get("bounds")
	if bounds is Rect2i:
		probe.position = bounds.position + Vector2i(bounds.size.x / 2, bounds.size.y / 2)
	return probe


func _shape_has_property(shape: Dictionary, probe: RuleGridEntity, property: StringName) -> bool:
	var positive := false
	var negative := false
	for sentence: RuleSentence in rule_set.sentences:
		if sentence.operator != &"IS" or sentence.predicate_role != &"property" \
			or sentence.predicate != property:
			continue
		var subject_matches := sentence.subject == probe.kind
		if sentence.subject_is_negated:
			subject_matches = not subject_matches
		if not subject_matches or not _shape_conditions_match(shape, probe, sentence.conditions):
			continue
		if sentence.is_negated:
			negative = true
		else:
			positive = true
	return positive and not negative


func _shape_owner_ids(shape: Dictionary, probe: RuleGridEntity) -> Array[String]:
	var explicit_rule_applies := false
	var positive_ids: Dictionary = {}
	var negative_ids: Dictionary = {}
	for sentence: RuleSentence in rule_set.sentences:
		if sentence.operator != &"OWNS" or sentence.predicate != &"METRIX":
			continue
		if not _shape_conditions_match(shape, probe, sentence.conditions):
			continue
		explicit_rule_applies = true
		for entity: RuleGridEntity in grid_state.entities:
			if entity == null or entity.is_word:
				continue
			var owner_matches := entity.kind == sentence.subject
			if sentence.subject_is_negated:
				owner_matches = not owner_matches
			if not owner_matches:
				continue
			if sentence.is_negated:
				negative_ids[entity.id] = true
			else:
				positive_ids[entity.id] = true
	var result: Array[String] = []
	if not explicit_rule_applies:
		return _you_ids()
	for owner_id: Variant in positive_ids.keys():
		if not negative_ids.has(owner_id):
			result.append(String(owner_id))
	result.sort()
	return result


func _shape_conditions_match(shape: Dictionary, probe: RuleGridEntity, conditions: Array[Dictionary]) -> bool:
	if conditions.is_empty():
		return true
	var footprint: Array[Vector2i] = []
	for key: String in ["boundary_cells", "interior_cells"]:
		var cells: Variant = shape.get(key, [])
		if not cells is Array:
			continue
		for cell: Variant in cells:
			if cell is Vector2i and not footprint.has(cell):
				footprint.append(cell)
	if footprint.is_empty():
		footprint.append(probe.position)
	for condition: Dictionary in conditions:
		var matched := false
		for cell: Vector2i in footprint:
			var cell_probe := RuleGridEntity.new()
			cell_probe.id = probe.id
			cell_probe.kind = probe.kind
			cell_probe.position = cell
			cell_probe.facing = probe.facing
			if RuleEvaluator._conditions_match(cell_probe, [condition], grid_state):
				matched = true
				break
		if not matched:
			return false
	return true


func _available_inventories() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var selected_subject := _selected_3d_subject()
	for shape: Dictionary in metrix_shapes:
		if not bool(shape.get("inventory", false)):
			continue
		var owner_ids: Variant = shape.get("owner_ids", [])
		if selected_subject != null and (not owner_ids is Array or not owner_ids.has(selected_subject.id)):
			continue
		result.append(shape)
	result.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return String(left["id"]) < String(right["id"]))
	return result


func _selected_metrix() -> Dictionary:
	for shape: Dictionary in metrix_shapes:
		if String(shape.get("id", "")) == selected_metrix_id:
			return shape
	return {}


func _shape_slots(shape: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw: Variant = shape.get("slots", [])
	if not raw is Array:
		return result
	for value: Variant in raw:
		if value is Dictionary:
			result.append(value)
	return result


func _slot_count(shape: Dictionary) -> int:
	return _shape_slots(shape).size()


func _slot_entity_ids(slot: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var value: Variant = slot.get("entity_ids", [])
	if not value is Array:
		return result
	for item: Variant in value:
		if item is String and _find_entity(item) != null:
			result.append(item)
	return result


func _is_3d_mode() -> bool:
	return _selected_3d_subject() != null


func _selected_3d_subject() -> RuleGridEntity:
	for entity: RuleGridEntity in _three_d_you_entities():
		if entity.id == selected_3d_subject_id:
			return entity
	var subjects := _three_d_you_entities()
	return subjects[0] if not subjects.is_empty() else null


func _three_d_you_entities() -> Array[RuleGridEntity]:
	var result: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in _you_entities():
		if _has_property(entity, &"3D"):
			result.append(entity)
	result.sort_custom(_entity_less)
	return result


func _you_entities() -> Array[RuleGridEntity]:
	var result: Array[RuleGridEntity] = []
	if grid_state == null:
		return result
	for entity: RuleGridEntity in grid_state.entities:
		if not entity.is_word and _has_property(entity, &"YOU"):
			result.append(entity)
	result.sort_custom(_entity_less)
	return result


func _you_ids() -> Array[String]:
	var result: Array[String] = []
	for entity: RuleGridEntity in _you_entities():
		result.append(entity.id)
	return result


func _has_property(entity: RuleGridEntity, property: StringName) -> bool:
	return RuleEvaluator.has_property(entity, property, rule_set, grid_state)


func _entity_less(left: RuleGridEntity, right: RuleGridEntity) -> bool:
	if left.position.x != right.position.x:
		return left.position.x < right.position.x
	if left.position.y != right.position.y:
		return left.position.y < right.position.y
	if left.layer != right.layer:
		return left.layer < right.layer
	if left.creation_serial != right.creation_serial:
		return left.creation_serial < right.creation_serial
	return left.id < right.id


func _entities_at(cell: Vector2i) -> Array[RuleGridEntity]:
	var result: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in grid_state.entities:
		if entity.position == cell:
			result.append(entity)
	result.sort_custom(_entity_less)
	return result


func _find_entity(entity_id: String) -> RuleGridEntity:
	return _find_entity_in(grid_state, entity_id)


func _find_entity_in(state: RuleGridState, entity_id: String) -> RuleGridEntity:
	if state == null or entity_id.is_empty():
		return null
	for entity: RuleGridEntity in state.entities:
		if entity.id == entity_id:
			return entity
	return null


func _commit_completed_board() -> void:
	var value := String(board_id)
	if not completed_board_ids.has(value):
		completed_board_ids.append(value)


func _mark_completed() -> void:
	_commit_completed_board()


func _rule_signature() -> Array[String]:
	var signatures: Array[String] = []
	for sentence: RuleSentence in rule_set.sentences:
		signatures.append(_rule_meaning_key(sentence))
	signatures.sort()
	return signatures


func _rule_change_feedback_ids(
	before_grid: Dictionary,
	before_rules: RuleSet,
	after_grid: RuleGridState,
	after_rules: RuleSet
) -> Array[String]:
	var before_state := RuleGridState.from_dictionary(before_grid)
	var changed_ids: Dictionary = {}
	var before_sources := _rule_sources_by_meaning(before_rules)
	var after_sources := _rule_sources_by_meaning(after_rules)
	var meanings: Dictionary = {}
	for meaning: Variant in before_sources.keys():
		meanings[meaning] = true
	for meaning: Variant in after_sources.keys():
		meanings[meaning] = true
	for meaning_value: Variant in meanings.keys():
		var meaning := String(meaning_value)
		var old_ids: Dictionary = before_sources.get(meaning, {})
		var new_ids: Dictionary = after_sources.get(meaning, {})
		if old_ids.is_empty() == new_ids.is_empty():
			continue
		for source_id: Variant in old_ids.keys():
			changed_ids[String(source_id)] = true
		for source_id: Variant in new_ids.keys():
			changed_ids[String(source_id)] = true
	var changed_meanings: Dictionary = {}
	for meaning_value: Variant in meanings.keys():
		var meaning := String(meaning_value)
		if before_sources.has(meaning) != after_sources.has(meaning):
			changed_meanings[meaning] = true
	var changed_properties: Dictionary = {}
	for sentence: RuleSentence in before_rules.sentences:
		if changed_meanings.has(_rule_meaning_key(sentence)) \
			and sentence.predicate_role == &"property":
			changed_properties[sentence.predicate] = true
	for sentence: RuleSentence in after_rules.sentences:
		if changed_meanings.has(_rule_meaning_key(sentence)) \
			and sentence.predicate_role == &"property":
			changed_properties[sentence.predicate] = true
	var changed_property_names: Array[StringName] = []
	for property_value: Variant in changed_properties.keys():
		changed_property_names.append(StringName(property_value))
	var before_by_id: Dictionary = {}
	for entity: RuleGridEntity in before_state.entities:
		if entity != null and not entity.is_word:
			before_by_id[entity.id] = entity
	var after_by_id: Dictionary = {}
	for entity: RuleGridEntity in after_grid.entities:
		if entity != null and not entity.is_word:
			after_by_id[entity.id] = entity
	for entity_id_value: Variant in after_by_id.keys():
		var entity_id := String(entity_id_value)
		var after_entity: RuleGridEntity = after_by_id[entity_id]
		if not before_by_id.has(entity_id):
			changed_ids[entity_id] = true
			continue
		var before_entity: RuleGridEntity = before_by_id[entity_id]
		if before_entity.kind != after_entity.kind:
			changed_ids[entity_id] = true
			continue
		if not changed_property_names.is_empty() \
			and _entity_property_signature(before_entity, before_rules, before_state, changed_property_names) \
			!= _entity_property_signature(after_entity, after_rules, after_grid, changed_property_names):
			changed_ids[entity_id] = true
	var result: Array[String] = []
	for entity_id: Variant in changed_ids.keys():
		if _find_entity(String(entity_id)) != null:
			result.append(String(entity_id))
	result.sort()
	return result


func _rule_sources_by_meaning(rules: RuleSet) -> Dictionary:
	var result: Dictionary = {}
	if rules == null:
		return result
	for sentence: RuleSentence in rules.sentences:
		var meaning := _rule_meaning_key(sentence)
		var sources: Dictionary = result.get(meaning, {})
		for source_id: String in sentence.source_entity_ids:
			sources[source_id] = true
		result[meaning] = sources
	return result


func _rule_meaning_key(sentence: RuleSentence) -> String:
	return JSON.stringify([
		String(sentence.subject), sentence.subject_is_negated,
		String(sentence.operator), String(sentence.predicate_role),
		String(sentence.predicate), sentence.is_negated, sentence.conditions
	])


func _entity_property_signature(
	entity: RuleGridEntity,
	rules: RuleSet,
	state: RuleGridState,
	properties: Array[StringName]
) -> Array[String]:
	var result: Array[String] = []
	for property: StringName in properties:
		if RuleEvaluator.has_property(entity, property, rules, state):
			result.append(String(property))
	return result


func _read_direction(payload: Dictionary) -> Vector2i:
	var direction: Variant = payload.get("direction")
	if direction is Vector2i and absi(direction.x) + absi(direction.y) == 1:
		return direction
	match payload.get("step"):
		-1: return Vector2i.LEFT
		1: return Vector2i.RIGHT
		_: return Vector2i.ZERO


func _inside_board(cell: Vector2i) -> bool:
	return grid_state != null and cell.x >= 0 and cell.y >= 0 and cell.x < grid_state.width and cell.y < grid_state.height


func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not RuleGridEntity._is_integer(value):
		return fallback
	return clampi(int(value), minimum, maximum)


func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent


func _request_exit(exit_id: String) -> void:
	_request_sent = true
	requested.emit(&"portal", {"exit": exit_id})


func _refresh() -> void:
	if _view == null:
		return
	_view.show_state(
		grid_state,
		rule_set,
		metrix_shapes,
		selected_metrix_id,
		selected_3d_subject_id,
		_is_3d_mode(),
		_inventory_open,
		_focused_slot,
		_held_entity_id,
		hotbar_slot,
		_camera_quadrant,
		failed,
		solved,
		_message,
		context == null or context.input_enabled
	)
	if not _pending_rule_feedback_ids.is_empty():
		_view.show_rule_change_feedback(_pending_rule_feedback_ids)
		_pending_rule_feedback_ids.clear()
