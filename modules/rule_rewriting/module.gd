extends GameModule

const ACTIONS: Array[StringName] = [
	&"rule_rewriting_left",
	&"rule_rewriting_right",
	&"rule_rewriting_up",
	&"rule_rewriting_down",
	&"rule_rewriting_confirm",
	&"rule_rewriting_cancel"
]
const DEFAULT_LEVEL_ID: StringName = &"signal_room_01"
const MODE_NAMES: Array[String] = ["관찰실", "격자 실험", "귀환 준비", "실험 실패"]
const CLUES: Array[String] = [
	"바닥 표찰의 명사는 방 안의 같은 이름을 가리킨다.",
	"단어도 밀 수 있다. 문장을 끊으면 그 문장의 규칙은 즉시 사라진다.",
	"세 표찰을 읽고 나면 네 문장이 놓인 시험실로 들어갈 수 있다."
]
const CLUE_NAMES: Array[String] = ["바닥 표찰", "문턱 표찰", "기록판"]
const MAX_HISTORY: int = 64
const MAX_COUNTER: int = 9999
const SOLVED_TEXT: String = "깃발의 WIN 규칙에 닿았다. 이 방의 문법으로 다른 공간도 다시 시험할 수 있다."
const FAILED_TEXT: String = "모든 YOU 대상이 DEFEAT와 겹쳤다. 취소로 이 턴을 되돌릴 수 있다."

var mode: int = 0
var focus: int = 0
var observed: Array[bool] = [false, false, false]
var active_level_id: StringName = DEFAULT_LEVEL_ID
var grid_state: RuleGridState
var rule_set: RuleSet = RuleSet.new()
var solved: bool = false
var failed: bool = false
var board_turns: int = 0
var board_attempts: int = 0
var _undo_stack: Array[Dictionary] = []
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _mode_label: Label
var _world_label: Label
var _status: Label
var _clue_cards: Array[ColorRect] = []
var _clue_marks: Array[Label] = []
var _rule_rows: Array[ColorRect] = []
var _rule_labels: Array[Label] = []


func _ready() -> void:
	var level := RuleLevelLoader.load_level(DEFAULT_LEVEL_ID)
	grid_state = level["state"] as RuleGridState
	_rebuild_rules()
	_background = ColorRect.new()
	_background.color = Color("17252b")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_label("규칙 재작성실", Vector2(60, 40), 40, Color("f4e2ad"))
	_label("문장을 밀면, 방의 규칙과 움직임이 다시 계산된다", Vector2(64, 96), 20, Color("b6d0c5"))
	_mode_label = _label("관찰실", Vector2(64, 132), 18, Color("e5b96c"))
	var room := ColorRect.new()
	room.color = Color("263e45")
	room.position = Vector2(60, 178)
	room.size = Vector2(610, 350)
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(room)
	_label("반응하는 방", Vector2(88, 194), 24, Color("f4e2ad"))
	_world_label = _label("", Vector2(88, 234), 16, Color("d9ebe1"))
	_world_label.size = Vector2(555, 276)
	_world_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(700, 178 + index * 52)
		card.size = Vector2(390, 42)
		card.color = Color("31515a")
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(card)
		_clue_cards.append(card)
		var title := _label(CLUE_NAMES[index], card.position + Vector2(14, 8), 17, Color("f4e2ad"))
		title.size.x = 170
		var mark := _label("미확인", card.position + Vector2(250, 8), 16, Color("a8c4b8"))
		mark.size.x = 124
		mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_clue_marks.append(mark)
	var rules_panel := ColorRect.new()
	rules_panel.color = Color("302c40")
	rules_panel.position = Vector2(700, 350)
	rules_panel.size = Vector2(390, 178)
	rules_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(rules_panel)
	_label("현재 성립한 문장", Vector2(728, 366), 21, Color("f4e2ad"))
	for index: int in range(4):
		var row := ColorRect.new()
		row.position = Vector2(728, 402 + index * 27)
		row.size = Vector2(334, 24)
		row.color = Color("4b4260")
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(row)
		_rule_rows.append(row)
		var rule_label := _label("", row.position + Vector2(8, 2), 15, Color("f5e9ff"))
		rule_label.size = Vector2(318, 22)
		_rule_labels.append(rule_label)
	_label("방향키 이동   확인 현재 문장 조사   취소 되돌리기/귀환", Vector2(64, 568), 18, Color("e5c68b"))
	_status = _label("세 표찰을 읽고, 격자 안의 단어와 대상을 직접 움직여 보세요.", Vector2(64, 624), 18, Color("b6d0c5"))
	_status.size = Vector2(1030, 54)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_refresh()


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	_request_sent = false
	_refresh()


func exit() -> void:
	_held.clear()
	super.exit()


func _process(_delta: float) -> void:
	if not _can_input():
		_held.clear()
		return
	for index: int in range(ACTIONS.size()):
		var pressed: bool = context.is_action_pressed(ACTIONS[index])
		var previous: bool = bool(_held.get(ACTIONS[index], false))
		_held[ACTIONS[index]] = pressed
		if pressed and not previous:
			if index == 0:
				execute_command(&"move", {"direction": Vector2i.LEFT})
			elif index == 1:
				execute_command(&"move", {"direction": Vector2i.RIGHT})
			elif index == 2:
				execute_command(&"move", {"direction": Vector2i.UP})
			elif index == 3:
				execute_command(&"move", {"direction": Vector2i.DOWN})
			elif index == 4:
				execute_command(&"confirm")
			else:
				execute_command(&"back")


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset":
			load_state({})
		&"move":
			var direction := _read_direction(payload)
			if direction == Vector2i.ZERO:
				return false
			if mode == 0:
				focus = posmod(focus + _focus_step(direction), CLUE_NAMES.size())
			elif mode == 1:
				_move_controlled(direction)
			else:
				return false
		&"cycle":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 0:
				focus = posmod(focus + int(step), CLUE_NAMES.size())
			elif mode == 1:
				return false
			else:
				return false
		&"confirm":
			if mode == 0:
				_observe_or_open_board()
			elif mode == 1:
				_inspect_rules()
			elif mode == 2:
				_finish()
			else:
				return false
		&"back":
			if mode == 0:
				_request_exit("back")
			elif not _undo():
				_request_exit("back")
		&"undo":
			if mode == 0 or not _undo():
				return false
		_:
			return false
	_refresh()
	return true


func save_state() -> Dictionary:
	return {
		"state_format": 4,
		"mode": mode,
		"focus": focus,
		"observed": observed.duplicate(),
		"active_level_id": String(active_level_id),
		"grid": grid_state.to_dictionary(),
		"solved": solved,
		"failed": failed,
		"board_turns": board_turns,
		"board_attempts": board_attempts,
		"undo_stack": _undo_stack.duplicate(true)
	}


func load_state(state: Dictionary) -> void:
	var clean := _normalize_state(state)
	mode = int(clean["mode"])
	focus = int(clean["focus"])
	observed.assign(clean["observed"])
	active_level_id = StringName(clean["active_level_id"])
	grid_state = RuleGridState.from_dictionary(clean["grid"])
	solved = bool(clean["solved"])
	failed = bool(clean["failed"])
	board_turns = int(clean["board_turns"])
	board_attempts = int(clean["board_attempts"])
	_undo_stack.clear()
	for snapshot: Variant in clean["undo_stack"]:
		_undo_stack.append(snapshot)
	_message = ""
	_request_sent = false
	_held.clear()
	_rebuild_rules()
	_refresh()


func migrate_save(old_version: int, _data: Dictionary) -> Dictionary:
	if old_version >= 4:
		return _normalize_state(_data)
	return _default_state()


func _observe_or_open_board() -> void:
	if not observed[focus]:
		observed[focus] = true
		_message = CLUES[focus]
		requested.emit(&"observation", {"id": "rule_rewriting.clue_%d" % focus, "text": CLUES[focus]})
	elif observed.all(func(value: bool) -> bool: return value):
		mode = 1
		focus = 0
		_message = "세 표찰을 읽었다. 방향키로 모든 YOU를 움직이고, 단어를 밀어 문장을 바꿔 보자."
	else:
		_message = "아직 읽지 않은 표찰이 있다."


func _move_controlled(direction: Vector2i) -> void:
	var controlled_ids: Array[String] = []
	for entity: RuleGridEntity in grid_state.entities:
		if not entity.is_word and rule_set.has_property(entity.kind, &"YOU"):
			controlled_ids.append(entity.id)
	if controlled_ids.is_empty():
		board_attempts = mini(board_attempts + 1, MAX_COUNTER)
		_message = "현재 성립한 YOU 문장이 없다. X로 되돌려 문장을 복구할 수 있다."
		return
	var before := _board_snapshot()
	var before_rules := _rule_signature()
	var plan := RuleMovementSolver.plan_move_many(grid_state, rule_set, controlled_ids, direction)
	if not bool(plan["can_move"]):
		board_attempts = mini(board_attempts + 1, MAX_COUNTER)
		_message = "이동이 막혔다. 밀어낼 수 없는 대상이나 방의 경계가 있다."
		return
	for move: Dictionary in plan["moves"]:
		var entity := _find_entity(String(move["entity_id"]))
		if entity != null:
			entity.position = move["to"]
			entity.facing = direction
	board_turns = mini(board_turns + 1, MAX_COUNTER)
	_rebuild_rules()
	var processed_transform_ids: Dictionary = {}
	var transform_result := RuleEvaluator.apply_transformations(grid_state, rule_set, processed_transform_ids)
	if not bool(transform_result["valid"]):
		_restore_board(before)
		board_attempts = mini(board_attempts + 1, MAX_COUNTER)
		_message = "변환 상태를 계산할 수 없어 이번 이동을 취소했다."
		return
	_rebuild_rules()
	var auto_plan := RuleMovementSolver.plan_move_auto(grid_state, rule_set)
	if not bool(auto_plan["valid"]):
		_restore_board(before)
		board_attempts = mini(board_attempts + 1, MAX_COUNTER)
		_message = "자동 이동을 계산할 수 없어 이번 이동을 취소했다."
		return
	for move: Dictionary in auto_plan["moves"]:
		var entity := _find_entity(String(move["entity_id"]))
		if entity != null:
			entity.position = move["to"]
			entity.facing = move["facing_to"]
	if bool(auto_plan["word_moved"]):
		_rebuild_rules()
		transform_result = RuleEvaluator.apply_transformations(grid_state, rule_set, processed_transform_ids)
		if not bool(transform_result["valid"]):
			_restore_board(before)
			board_attempts = mini(board_attempts + 1, MAX_COUNTER)
			_message = "변환 상태를 계산할 수 없어 이번 이동을 취소했다."
			return
		_rebuild_rules()
	var outcome := _resolve_interactions()
	_commit_board_action(before)
	if outcome == &"failed":
		_message = FAILED_TEXT
	elif outcome == &"solved":
		_message = SOLVED_TEXT
	elif before_rules != _rule_signature():
		_message = "밀린 단어로 문장이 달라졌다. 방의 규칙이 즉시 다시 계산됐다."
	else:
		_message = "움직일 수 있는 YOU 대상과 밀리는 단어가 함께 이동했다."


func _inspect_rules() -> void:
	board_attempts = mini(board_attempts + 1, MAX_COUNTER)
	if rule_set.sentences.is_empty():
		_message = "현재 성립한 문장이 없다. 밀린 단어의 위치를 살펴보자."
		return
	var rule_text := PackedStringArray()
	for sentence: RuleSentence in rule_set.sentences:
		rule_text.append("%s IS %s" % [String(sentence.subject), String(sentence.predicate)])
	_message = "현재 성립한 문장: %s" % " / ".join(rule_text)


func _resolve_interactions() -> StringName:
	var defeated_ids: Dictionary = {}
	for actor: RuleGridEntity in grid_state.entities:
		if actor.is_word or not rule_set.has_property(actor.kind, &"YOU"):
			continue
		for target: RuleGridEntity in grid_state.entities:
			if target.is_word or target.position != actor.position:
				continue
			if rule_set.has_property(target.kind, &"DEFEAT"):
				defeated_ids[actor.id] = true
				break
	if not defeated_ids.is_empty():
		var survivors: Array[RuleGridEntity] = []
		for entity: RuleGridEntity in grid_state.entities:
			if not defeated_ids.has(entity.id):
				survivors.append(entity)
		grid_state.entities = survivors
		_rebuild_rules()
	var controlled: Array[RuleGridEntity] = []
	for entity: RuleGridEntity in grid_state.entities:
		if not entity.is_word and rule_set.has_property(entity.kind, &"YOU"):
			controlled.append(entity)
	if not defeated_ids.is_empty() and controlled.is_empty():
		_set_failed()
		return &"failed"
	if controlled.is_empty():
		return &"none"
	for actor: RuleGridEntity in controlled:
		if rule_set.has_property(actor.kind, &"WIN"):
			_set_solved()
			return &"solved"
		for target: RuleGridEntity in grid_state.entities:
			if target.is_word or target.position != actor.position:
				continue
			if rule_set.has_property(target.kind, &"WIN"):
				_set_solved()
				return &"solved"
	return &"none"


func _set_solved() -> void:
	if failed:
		return
	solved = true
	mode = 2


func _set_failed() -> void:
	failed = true
	solved = false
	mode = 3


func _request_exit(exit_id: String) -> void:
	_request_sent = true
	requested.emit(&"portal", {"exit": exit_id})


func _finish() -> void:
	if not solved:
		return
	_request_sent = true
	requested.emit(&"observation", {"id": "rule_rewriting.solved", "text": SOLVED_TEXT})
	requested.emit(&"portal", {"exit": "forward"})


func _commit_board_action(before: Dictionary) -> void:
	if _board_snapshot() == before:
		return
	_undo_stack.append(before)
	if _undo_stack.size() > MAX_HISTORY:
		_undo_stack.pop_front()


func _undo() -> bool:
	if _undo_stack.is_empty():
		return false
	var snapshot: Dictionary = _undo_stack.pop_back()
	if not _restore_board(snapshot):
		_undo_stack.clear()
		return false
	_message = "격자와 성립한 문장을 한 턴 전으로 되돌렸다."
	return true


func _board_snapshot() -> Dictionary:
	return {
		"mode": mode,
		"grid": grid_state.to_dictionary(),
		"solved": solved,
		"failed": failed,
		"board_turns": board_turns,
		"board_attempts": board_attempts
	}


func _restore_board(snapshot: Dictionary) -> bool:
	var level := RuleLevelLoader.load_level(active_level_id)
	var restored := _normalize_snapshot(snapshot, level["state"])
	if restored.is_empty():
		return false
	mode = int(restored["mode"])
	grid_state = RuleGridState.from_dictionary(restored["grid"])
	solved = bool(restored["solved"])
	failed = bool(restored["failed"])
	board_turns = int(restored["board_turns"])
	board_attempts = int(restored["board_attempts"])
	_rebuild_rules()
	return true


func _default_state() -> Dictionary:
	var level := RuleLevelLoader.load_level(DEFAULT_LEVEL_ID)
	var default_grid: RuleGridState = level["state"]
	return {
		"state_format": 4,
		"mode": 0,
		"focus": 0,
		"observed": [false, false, false],
		"active_level_id": String(DEFAULT_LEVEL_ID),
		"grid": default_grid.to_dictionary(),
		"solved": false,
		"failed": false,
		"board_turns": 0,
		"board_attempts": 0,
		"undo_stack": []
	}


func _normalize_state(data: Dictionary) -> Dictionary:
	if data.get("state_format") != 4:
		return _default_state()
	var clean_observed: Array[bool] = [false, false, false]
	if data.get("observed") is Array and data["observed"].size() == 3:
		var candidate: Array[bool] = []
		for value: Variant in data["observed"]:
			if not value is bool:
				candidate.clear()
				break
			candidate.append(value)
		if candidate.size() == 3:
			clean_observed = candidate
	var requested_level := StringName(String(data.get("active_level_id", DEFAULT_LEVEL_ID)))
	var level := RuleLevelLoader.load_level(requested_level)
	if not bool(level["ok"]):
		return _default_state()
	var clean_grid := RuleGridState.from_dictionary(data.get("grid"))
	var level_grid: RuleGridState = level["state"]
	if clean_grid == null or not _grid_matches_level(clean_grid, level_grid):
		clean_grid = RuleGridState.from_dictionary(level_grid.to_dictionary())
	var clean_mode := _integer(data.get("mode"), 0, 0, 3)
	var clean_history: Array[Dictionary] = []
	if data.get("undo_stack") is Array:
		for value: Variant in data["undo_stack"]:
			var snapshot := _normalize_snapshot(value, level_grid)
			if not snapshot.is_empty():
				clean_history.append(snapshot)
		if clean_history.size() > MAX_HISTORY:
			clean_history = clean_history.slice(clean_history.size() - MAX_HISTORY)
	var is_solved: bool = data.get("solved") if data.get("solved") is bool else false
	var is_failed: bool = data.get("failed") if data.get("failed") is bool else false
	if is_failed:
		is_solved = false
		clean_mode = 3
	elif is_solved:
		clean_mode = 2
	elif clean_mode == 2 or clean_mode == 3:
		clean_mode = 1
	return {
		"state_format": 4,
		"mode": clean_mode,
		"focus": _integer(data.get("focus"), 0, 0, CLUE_NAMES.size() - 1),
		"observed": clean_observed,
		"active_level_id": String(requested_level),
		"grid": clean_grid.to_dictionary(),
		"solved": is_solved,
		"failed": is_failed,
		"board_turns": _integer(data.get("board_turns"), 0, 0, MAX_COUNTER),
		"board_attempts": _integer(data.get("board_attempts"), 0, 0, MAX_COUNTER),
		"undo_stack": clean_history
	}


func _normalize_snapshot(value: Variant, level_grid: RuleGridState) -> Dictionary:
	if not value is Dictionary:
		return {}
	var raw_grid := RuleGridState.from_dictionary(value.get("grid"))
	if raw_grid == null or not _grid_matches_level(raw_grid, level_grid):
		return {}
	var clean_mode := _integer(value.get("mode"), 1, 1, 3)
	var is_solved: bool = value.get("solved") if value.get("solved") is bool else false
	var is_failed: bool = value.get("failed") if value.get("failed") is bool else false
	if is_failed:
		is_solved = false
		clean_mode = 3
	elif is_solved:
		clean_mode = 2
	elif clean_mode == 2 or clean_mode == 3:
		clean_mode = 1
	return {
		"mode": clean_mode,
		"grid": raw_grid.to_dictionary(),
		"solved": is_solved,
		"failed": is_failed,
		"board_turns": _integer(value.get("board_turns"), 0, 0, MAX_COUNTER),
		"board_attempts": _integer(value.get("board_attempts"), 0, 0, MAX_COUNTER)
	}


func _grid_matches_level(candidate: RuleGridState, authored: RuleGridState) -> bool:
	if candidate.width != authored.width or candidate.height != authored.height:
		return false
	var authored_by_id: Dictionary = {}
	var authored_nouns: Dictionary = {}
	for original: RuleGridEntity in authored.entities:
		authored_by_id[original.id] = original
		if original.is_word and original.word_role == &"noun":
			authored_nouns[original.word_value] = true
	var candidate_by_id: Dictionary = {}
	for entity: RuleGridEntity in candidate.entities:
		if entity == null or entity.id.is_empty() or candidate_by_id.has(entity.id):
			return false
		candidate_by_id[entity.id] = entity
		if authored_by_id.has(entity.id):
			var original: RuleGridEntity = authored_by_id[entity.id]
			if original.is_word:
				if not entity.is_word or entity.kind != original.kind \
					or entity.word_role != original.word_role or entity.word_value != original.word_value \
					or entity.base_tags != original.base_tags:
					return false
			elif entity.is_word or not authored_nouns.has(entity.kind) \
				or entity.base_tags != original.base_tags:
				return false
		elif entity.is_word or not entity.id.begins_with("transform::") \
			or not authored_nouns.has(entity.kind):
			return false
	for original: RuleGridEntity in authored.entities:
		if original.is_word and not candidate_by_id.has(original.id):
			return false
	return true


func _rebuild_rules() -> void:
	if grid_state == null:
		rule_set = RuleSet.new()
		return
	rule_set = RuleParser.parse(grid_state.width, grid_state.height, grid_state.entities)


func _rule_signature() -> Array[String]:
	var signature: Array[String] = []
	for sentence: RuleSentence in rule_set.sentences:
		signature.append("%s IS %s" % [String(sentence.subject), String(sentence.predicate)])
	return signature


func _find_entity(entity_id: String) -> RuleGridEntity:
	return _find_entity_in(grid_state, entity_id)


func _find_entity_in(state: RuleGridState, entity_id: String) -> RuleGridEntity:
	for entity: RuleGridEntity in state.entities:
		if entity.id == entity_id:
			return entity
	return null


func _read_direction(payload: Dictionary) -> Vector2i:
	var value: Variant = payload.get("direction")
	if value is Vector2i:
		if absi(value.x) + absi(value.y) == 1:
			return value
		return Vector2i.ZERO
	var step: Variant = payload.get("step")
	if step == -1:
		return Vector2i.LEFT
	if step == 1:
		return Vector2i.RIGHT
	return Vector2i.ZERO


func _focus_step(direction: Vector2i) -> int:
	return -1 if direction.x < 0 or direction.y < 0 else 1


func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not RuleGridEntity._is_integer(value):
		return fallback
	return clampi(int(value), minimum, maximum)


func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent


func _refresh() -> void:
	if _status == null:
		return
	_mode_label.text = MODE_NAMES[mode]
	for index: int in range(CLUE_NAMES.size()):
		_clue_cards[index].color = Color("725b4a") if mode == 0 and index == focus else Color("31515a")
		_clue_marks[index].text = "기록 완료" if observed[index] else "미확인"
		_clue_marks[index].add_theme_color_override("font_color", Color("f2d28b") if observed[index] else Color("a8c4b8"))
	var shown_count: int = mini(rule_set.sentences.size(), _rule_labels.size())
	for index: int in range(_rule_labels.size()):
		var visible_rule: bool = index < shown_count
		_rule_rows[index].visible = visible_rule
		_rule_labels[index].visible = visible_rule
		if not visible_rule:
			continue
		var sentence: RuleSentence = rule_set.sentences[index]
		_rule_labels[index].text = "%s IS %s" % [String(sentence.subject), String(sentence.predicate)]
		_rule_rows[index].color = Color("4b4260")
	_world_label.text = _board_text() if mode > 0 else "세 표찰을 읽으면 문장이 놓인 격자를 살펴볼 수 있다."
	if not _message.is_empty():
		_status.text = _message
	elif mode == 1:
		_status.text = "문장 %d개 · 이동 %d회 · 되돌리기 %d회" % [rule_set.sentences.size(), board_turns, _undo_stack.size()]
	elif mode == 2:
		_status.text = "격자가 해결됐다. 확인을 눌러 앞으로 가거나 X로 마지막 움직임을 되돌린다."
	elif mode == 3:
		_status.text = FAILED_TEXT
	else:
		_status.text = "표찰 %d/3 · 아래 기록판에서 현재 성립한 문장을 확인하세요." % observed.count(true)


func _board_text() -> String:
	var cells: Dictionary = {}
	for entity: RuleGridEntity in grid_state.entities:
		var key: Vector2i = entity.position
		var priority: int = 3 if entity.is_word else (2 if rule_set.has_property(entity.kind, &"YOU") else 1)
		var current: Dictionary = cells.get(key, {})
		if current.is_empty() or priority > int(current["priority"]):
			cells[key] = {"priority": priority, "text": _cell_text(entity)}
	var lines := PackedStringArray()
	for y: int in range(grid_state.height):
		var row := PackedStringArray()
		for x: int in range(grid_state.width):
			var value: Dictionary = cells.get(Vector2i(x, y), {})
			row.append(String(value.get("text", " · ")))
		lines.append(" ".join(row))
	return "격자: %s\n%s" % [String(active_level_id), "\n".join(lines)]


func _cell_text(entity: RuleGridEntity) -> String:
	if entity.is_word:
		return String(entity.word_value).left(3).rpad(3)
	if rule_set.has_property(entity.kind, &"YOU"):
		return " @ "
	if entity.kind == &"WALL":
		return "###"
	return (" " + String(entity.kind).left(1) + " ")


func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label
