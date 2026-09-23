extends GameModule

const ACTIONS: Array[StringName] = [&"dedution_casework_left", &"dedution_casework_right", &"dedution_casework_up", &"dedution_casework_down", &"dedution_casework_confirm", &"dedution_casework_cancel"]
const CASE_DIRECTORY: String = "res://modules/dedution_casework/content"
const MODE_NAMES: Array[String] = ["현장 기록", "사건 순서", "판정표", "사건 종결"]

var case_definitions: Array[DeductionCaseDefinition] = []
var mode: int = 0
var focus: int = 0
var case_index: int = 0
var case_states: Array[Dictionary] = []
var inspected: Array[bool] = []
var rechecked: Array[bool] = []
var timeline: Array[int] = []
var answers: Array[int] = []
var answer_filled: Array[bool] = []
var timeline_attempts: int = 0
var mistakes: int = 0
var solved: bool = false
var validation_status: String = ""
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _catalog_loaded: bool = false
var _background: ColorRect
var _mode_label: Label
var _case_label: Label
var _body: Label
var _status: Label
var _scene_cards: Array[ColorRect] = []
var _scene_titles: Array[Label] = []
var _scene_marks: Array[Label] = []
var _event_rows: Array[ColorRect] = []
var _event_labels: Array[Label] = []
var _answer_rows: Array[ColorRect] = []
var _answer_labels: Array[Label] = []

func _ready() -> void:
	var loaded: Dictionary = DeductionCaseLoader.load_directory(CASE_DIRECTORY)
	if not bool(loaded.get("ok", false)):
		push_error("Deduction case catalog failed validation: %s" % str(loaded.get("errors", [])))
		_label("사건 자료를 읽을 수 없습니다.", Vector2(64, 64), 28, Color("f2dfb0"))
		return
	case_definitions.assign(loaded["cases"])
	_catalog_loaded = true
	_ensure_case_states()
	_load_case_state()
	_build_ui()
	_refresh()

func _build_ui() -> void:
	_background = ColorRect.new()
	_background.color = Color("211b25")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_label("사건기록", Vector2(60, 40), 40, Color("f2dfb0"))
	_label("현장에 남은 순서를 복원하고, 마지막 문장을 판정한다", Vector2(64, 96), 20, Color("c9c0b6"))
	_mode_label = _label("현장 기록", Vector2(64, 132), 18, Color("d8a975"))
	_case_label = _label(_case().title, Vector2(250, 132), 18, Color("e8c993"))
	var scene_panel := ColorRect.new()
	scene_panel.color = Color("39313a")
	scene_panel.position = Vector2(60, 178)
	scene_panel.size = Vector2(610, 350)
	scene_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(scene_panel)
	_label("현장 도면", Vector2(88, 204), 24, Color("f2dfb0"))
	_body = _label("", Vector2(92, 244), 19, Color("e7ddd0"))
	_body.size = Vector2(540, 80)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var scene_capacity: int = _maximum_scene_count()
	var scene_step: float = minf(54.0, 166.0 / float(maxi(scene_capacity, 1)))
	for index: int in range(scene_capacity):
		var card := ColorRect.new()
		card.position = Vector2(92, 342.0 + float(index) * scene_step)
		card.size = Vector2(540, minf(42.0, scene_step - 4.0))
		card.color = Color("4d4046")
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(card)
		_scene_cards.append(card)
		var title := _label("", card.position + Vector2(14, 6), 17, Color("f2dfb0"))
		title.size = Vector2(350, card.size.y - 8.0)
		_scene_titles.append(title)
		var mark := _label("", card.position + Vector2(370, 6), 16, Color("c1b4ad"))
		mark.size = Vector2(150, card.size.y - 8.0)
		mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_scene_marks.append(mark)
	var case_panel := ColorRect.new()
	case_panel.color = Color("302b40")
	case_panel.position = Vector2(700, 178)
	case_panel.size = Vector2(390, 350)
	case_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(case_panel)
	_label("기록 노트", Vector2(730, 204), 24, Color("f2dfb0"))
	_label("순서를 세우고 판정표를 채운다", Vector2(732, 242), 17, Color("c8bbd0"))
	var row_capacity: int = maxi(_maximum_event_count(), _maximum_slot_count())
	var row_step: float = 240.0 / float(maxi(row_capacity, 1))
	var row_height: float = minf(56.0, row_step - 4.0)
	for index: int in range(row_capacity):
		var row_y: float = 274.0 + float(index) * row_step
		var event_row := ColorRect.new()
		event_row.position = Vector2(728, row_y)
		event_row.size = Vector2(334, row_height)
		event_row.color = Color("4b4260")
		event_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(event_row)
		_event_rows.append(event_row)
		var event_label := _label("", event_row.position + Vector2(14, 5), 16, Color("f5e9ff"))
		event_label.size = Vector2(306, row_height - 8.0)
		event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_event_labels.append(event_label)
		var answer_row := ColorRect.new()
		answer_row.position = Vector2(728, row_y)
		answer_row.size = Vector2(334, row_height)
		answer_row.color = Color("5d5068")
		answer_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(answer_row)
		_answer_rows.append(answer_row)
		var answer_label := _label("", answer_row.position + Vector2(14, 5), 16, Color("f5e9ff"))
		answer_label.size = Vector2(306, row_height - 8.0)
		answer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_answer_labels.append(answer_label)
	_label("←→ 대상/칸 선택   ↑↓ 화면 이동·보기   Z 기록/판정   X 뒤로", Vector2(64, 568), 18, Color("e4c78c"))
	_status = _label("", Vector2(64, 624), 18, Color("c9c0b6"))
	_status.size = Vector2(1030, 54)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

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
			if index == 0: execute_command(&"move", {"step": -1})
			elif index == 1: execute_command(&"move", {"step": 1})
			elif index == 2: execute_command(&"vertical", {"step": -1})
			elif index == 3: execute_command(&"vertical", {"step": 1})
			elif index == 4: execute_command(&"confirm")
			else: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset":
			load_state({})
		&"move":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			var limit: int = _focus_limit()
			if limit < 0:
				return false
			focus = posmod(focus + int(step), limit + 1)
		&"cycle":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 0:
				if not _select_case(int(step)):
					return false
			elif mode == 1:
				timeline[focus] = posmod(timeline[focus] + int(step), _case().event_ids.size())
			elif mode == 2:
				var slot: DeductionSlotDefinition = _case().answer_slots[focus]
				answers[focus] = posmod(answers[focus] + int(step), slot.options.size())
				answer_filled[focus] = true
			else:
				return false
		&"vertical":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if step == -1 and mode == 0:
				if focus >= inspected.size() or not inspected[focus]:
					return false
				_recheck_focus()
			elif step == -1 and mode > 0:
				mode -= 1
				focus = 0
			elif step == 1 and mode == 0 and inspected.all(func(value: bool) -> bool: return value):
				if rechecked.count(true) < _case().minimum_rechecks:
					_message = "모든 기록을 한 번 더 대조해야 한다. ↑로 선택한 현장을 재조사하세요."
				else:
					mode = 1
					focus = 0
			else:
				return false
		&"confirm":
			if mode == 0: _inspect_or_open_timeline()
			elif mode == 1: _check_timeline()
			elif mode == 2: _check_answers()
			else: _finish()
		&"back":
			if mode > 0:
				mode -= 1
				focus = 0
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	_store_case_state()
	var case_ids: Array[String] = []
	for definition: DeductionCaseDefinition in case_definitions:
		case_ids.append(String(definition.case_id))
	return {
		"case_index": case_index,
		"case_ids": case_ids,
		"case_states": case_states.duplicate(true),
		"mode": mode,
		"focus": focus,
		"inspected": inspected.duplicate(),
		"rechecked": rechecked.duplicate(),
		"timeline": timeline.duplicate(),
		"timeline_event_ids": _selected_event_ids(_case(), timeline),
		"answers": answers.duplicate(),
		"answer_filled": answer_filled.duplicate(),
		"answers_by_slot": _selected_answers_by_slot(_case(), answers, answer_filled),
		"timeline_attempts": timeline_attempts,
		"mistakes": mistakes,
		"solved": solved,
		"validation_status": validation_status
	}

func load_state(state: Dictionary) -> void:
	if not _catalog_loaded:
		return
	var clean: Dictionary = _normalize(state)
	case_index = int(clean["case_index"])
	case_states.clear()
	for value: Variant in clean["case_states"]:
		case_states.append(value as Dictionary)
	_load_case_state()
	_message = ""
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _inspect_or_open_timeline() -> void:
	if not inspected[focus]:
		inspected[focus] = true
		_message = _case().findings[focus]
		requested.emit(&"observation", {"id": "dedution_casework.%s.clue.%s" % [_case().case_id, _case().scene_ids[focus]], "text": _case().findings[focus]})
	elif inspected.all(func(value: bool) -> bool: return value) and rechecked.count(true) >= _case().minimum_rechecks:
		mode = 1
		focus = 0
		_message = "세 기록을 모았다. 이제 실제로 일어난 순서를 세워 보자."
	elif inspected.all(func(value: bool) -> bool: return value):
		_message = "기록은 모였지만 아직 재조사가 필요하다. 선택한 현장에서 ↑를 눌러 세부 흔적을 확인하세요."
	else:
		_message = "아직 기록하지 않은 장소가 있다."

func _recheck_focus() -> void:
	if rechecked[focus]:
		_message = "이 현장의 세부 흔적은 이미 기록했다. 다른 현장을 대조할 수 있다."
		return
	rechecked[focus] = true
	_message = _case().details[focus]
	requested.emit(&"observation", {"id": "dedution_casework.%s.detail.%s" % [_case().case_id, _case().scene_ids[focus]], "text": _case().details[focus]})

func _check_timeline() -> void:
	var correct: bool = timeline.size() == _case().timeline_solution.size()
	for index: int in range(mini(timeline.size(), _case().timeline_solution.size())):
		if timeline[index] < 0 or timeline[index] >= _case().event_ids.size() or _case().event_ids[timeline[index]] != _case().timeline_solution[index]:
			correct = false
	if correct:
		mode = 2
		focus = 0
		validation_status = "timeline_ready"
		_message = "시간의 순서가 이어졌다. %d칸의 판정표를 완성하자." % _case().answer_slots.size()
	else:
		timeline_attempts = mini(timeline_attempts + 1, 9999)
		mistakes = mini(mistakes + 1, 9999)
		validation_status = "timeline_wrong"
		_message = "기록 두 장이 겹친다. 순서를 다시 배열해 보자."

func _check_answers() -> void:
	if not answer_filled.all(func(value: bool) -> bool: return value):
		validation_status = "incomplete"
		_message = "판정표의 모든 칸을 채운 뒤 대조해야 한다."
		return
	if _is_contradictory_answer():
		mistakes = mini(mistakes + 1, 9999)
		validation_status = "contradiction"
		_message = "두 판정이 같은 기록을 부정한다. 모순이 생긴 칸부터 다시 대조하세요."
		return
	var correct: bool = answers.size() == _case().answer_slots.size()
	for index: int in range(mini(answers.size(), _case().answer_slots.size())):
		var slot: DeductionSlotDefinition = _case().answer_slots[index]
		if answers[index] < 0 or answers[index] >= slot.options.size() or slot.options[answers[index]].term_id != slot.solution_id:
			correct = false
	if correct:
		solved = true
		mode = 3
		focus = 0
		validation_status = "solved"
		_message = "모든 판정이 서로 맞물렸다. Z로 사건을 닫자."
	else:
		mistakes = mini(mistakes + 1, 9999)
		validation_status = "valid_but_wrong"
		_message = "문장이 맞지 않는다. 증거 기록으로 돌아가 다시 대조할 수 있다."

func _finish() -> void:
	if not solved:
		return
	_request_sent = true
	requested.emit(&"observation", {"id": "dedution_casework.%s.solved" % _case().case_id, "text": _case().solved_text})
	requested.emit(&"portal", {"exit": "forward"})

func _normalize(data: Dictionary) -> Dictionary:
	var states: Array[Dictionary] = []
	var raw_states: Variant = data.get("case_states")
	var raw_ids: Variant = data.get("case_ids")
	var states_by_id: Dictionary = {}
	if raw_states is Array:
		for index: int in range(raw_states.size()):
			if raw_ids is Array and index < raw_ids.size():
				states_by_id[String(raw_ids[index])] = raw_states[index]
	for index: int in range(_case_count()):
		var definition: DeductionCaseDefinition = case_definitions[index]
		var raw: Variant = states_by_id.get(String(definition.case_id), null)
		if raw == null and raw_states is Array and raw_ids is not Array and index < raw_states.size():
			raw = raw_states[index]
		if raw == null and raw_states is not Array and index == 0:
			raw = data
		states.append(_normalize_case_state(raw if raw is Dictionary else {}, index))
	var requested_index: int = _integer(data.get("case_index"), 0, 0, _case_count() - 1)
	if raw_ids is Array and requested_index < raw_ids.size():
		var requested_id: String = String(raw_ids[requested_index])
		for index: int in range(_case_count()):
			if String(case_definitions[index].case_id) == requested_id:
				requested_index = index
				break
	var active: Dictionary = states[requested_index].duplicate(true)
	active["case_index"] = requested_index
	active["case_ids"] = _current_case_ids()
	active["case_states"] = states.duplicate(true)
	return active

func _default_case_state(index: int) -> Dictionary:
	var definition: DeductionCaseDefinition = case_definitions[index]
	var seen: Array[bool] = []
	var checked: Array[bool] = []
	var ordered_events: Array[int] = []
	var selected_terms: Array[int] = []
	var filled_slots: Array[bool] = []
	for _scene_id: StringName in definition.scene_ids:
		seen.append(false)
		checked.append(false)
	for _event_id: StringName in definition.event_ids:
		ordered_events.append(0)
	for slot: DeductionSlotDefinition in definition.answer_slots:
		selected_terms.append(0)
		filled_slots.append(false)
	return {
		"mode": 0,
		"focus": 0,
		"inspected": seen,
		"rechecked": checked,
		"timeline": ordered_events,
		"timeline_event_ids": _selected_event_ids(definition, ordered_events),
		"answers": selected_terms,
		"answer_filled": filled_slots,
		"answers_by_slot": _selected_answers_by_slot(definition, selected_terms, filled_slots),
		"timeline_attempts": 0,
		"mistakes": 0,
		"solved": false,
		"validation_status": ""
	}

func _normalize_case_state(data: Dictionary, index: int) -> Dictionary:
	var clean: Dictionary = _default_case_state(index)
	var definition: DeductionCaseDefinition = case_definitions[index]
	clean["mode"] = _integer(data.get("mode"), 0, 0, 3)
	clean["focus"] = _integer(data.get("focus"), 0, 0, _focus_limit_for(int(clean["mode"]), definition))
	clean["inspected"] = _normalize_bools(data.get("inspected"), definition.scene_ids.size())
	clean["rechecked"] = _normalize_bools(data.get("rechecked"), definition.scene_ids.size())
	clean["timeline"] = _normalize_choices(data.get("timeline"), _event_option_counts(definition))
	var raw_event_ids: Variant = data.get("timeline_event_ids")
	if raw_event_ids is Array:
		for event_index: int in range(definition.event_ids.size()):
			if event_index >= raw_event_ids.size() or not raw_event_ids[event_index] is String:
				continue
			var resolved_event: int = definition.event_ids.find(StringName(raw_event_ids[event_index]))
			if resolved_event >= 0:
				clean["timeline"][event_index] = resolved_event
	clean["answers"] = _normalize_choices(data.get("answers"), _answer_option_counts(definition))
	clean["answer_filled"] = _normalize_bools(data.get("answer_filled"), definition.answer_slots.size())
	var raw_answers_by_slot: Variant = data.get("answers_by_slot")
	if raw_answers_by_slot is Dictionary:
		for slot_index: int in range(definition.answer_slots.size()):
			var selected_term: Variant = raw_answers_by_slot.get(String(definition.answer_slots[slot_index].slot_id), "")
			if not selected_term is String or String(selected_term).is_empty():
				clean["answer_filled"][slot_index] = false
				continue
			var resolved_index: int = _term_index(definition.answer_slots[slot_index], StringName(selected_term))
			if resolved_index < 0:
				clean["answer_filled"][slot_index] = false
				continue
			clean["answers"][slot_index] = resolved_index
			clean["answer_filled"][slot_index] = true
	clean["timeline_attempts"] = _integer(data.get("timeline_attempts"), 0, 0, 9999)
	clean["mistakes"] = _integer(data.get("mistakes"), 0, 0, 9999)
	clean["solved"] = data.get("solved") if data.get("solved") is bool else false
	clean["validation_status"] = data.get("validation_status") if data.get("validation_status") is String else ""
	clean["focus"] = mini(int(clean["focus"]), _focus_limit_for(int(clean["mode"]), definition))
	clean["timeline_event_ids"] = _selected_event_ids(definition, clean["timeline"])
	clean["answers_by_slot"] = _selected_answers_by_slot(definition, clean["answers"], clean["answer_filled"])
	return clean

func _normalize_bools(value: Variant, count: int) -> Array[bool]:
	var result: Array[bool] = []
	var valid: bool = value is Array
	if valid:
		for item: Variant in value:
			if not item is bool:
				valid = false
				break
	for index: int in range(count):
		result.append(value[index] if valid and index < value.size() else false)
	return result

func _normalize_choices(value: Variant, option_counts: Array[int]) -> Array[int]:
	var result: Array[int] = []
	var valid: bool = value is Array
	if valid:
		for item: Variant in value:
			if (not item is int and not item is float) or not is_finite(float(item)):
				valid = false
				break
	for index: int in range(option_counts.size()):
		var choice: int = 0
		if valid and index < value.size():
			choice = clampi(int(value[index]), 0, maxi(option_counts[index] - 1, 0))
		result.append(choice)
	return result

func _ensure_case_states() -> void:
	var normalized: Array[Dictionary] = []
	for index: int in range(_case_count()):
		if index < case_states.size():
			normalized.append(_normalize_case_state(case_states[index], index))
		else:
			normalized.append(_default_case_state(index))
	case_states = normalized

func _store_case_state() -> void:
	if not _catalog_loaded:
		return
	_ensure_case_states()
	case_index = clampi(case_index, 0, _case_count() - 1)
	var current: Dictionary = _default_case_state(case_index)
	current["mode"] = mode
	current["focus"] = focus
	current["inspected"] = inspected.duplicate()
	current["rechecked"] = rechecked.duplicate()
	current["timeline"] = timeline.duplicate()
	current["timeline_event_ids"] = _selected_event_ids(_case(), timeline)
	current["answers"] = answers.duplicate()
	current["answer_filled"] = answer_filled.duplicate()
	current["answers_by_slot"] = _selected_answers_by_slot(_case(), answers, answer_filled)
	current["timeline_attempts"] = timeline_attempts
	current["mistakes"] = mistakes
	current["solved"] = solved
	current["validation_status"] = validation_status
	case_states[case_index] = current

func _load_case_state() -> void:
	_ensure_case_states()
	case_index = clampi(case_index, 0, _case_count() - 1)
	var current: Dictionary = _normalize_case_state(case_states[case_index], case_index)
	case_states[case_index] = current
	mode = int(current["mode"])
	focus = int(current["focus"])
	inspected.assign(current["inspected"])
	rechecked.assign(current["rechecked"])
	timeline.assign(current["timeline"])
	answers.assign(current["answers"])
	answer_filled.assign(current["answer_filled"])
	timeline_attempts = int(current["timeline_attempts"])
	mistakes = int(current["mistakes"])
	solved = bool(current["solved"])
	validation_status = String(current["validation_status"])

func _select_case(step: int) -> bool:
	if _case_count() < 2:
		return false
	_store_case_state()
	case_index = posmod(case_index + step, _case_count())
	_load_case_state()
	focus = 0
	_message = "사건 파일을 열었다: %s" % _case().title
	return true

func _is_contradictory_answer() -> bool:
	for index: int in range(_case().answer_slots.size()):
		var slot: DeductionSlotDefinition = _case().answer_slots[index]
		if answers[index] < 0 or answers[index] >= slot.options.size():
			continue
		var selected: DeductionTermDefinition = slot.options[answers[index]]
		if selected.conflict_slot_id.is_empty():
			continue
		var conflict_index: int = _slot_index(selected.conflict_slot_id)
		if conflict_index < 0 or not answer_filled[conflict_index]:
			continue
		var conflict_slot: DeductionSlotDefinition = _case().answer_slots[conflict_index]
		if answers[conflict_index] >= 0 and answers[conflict_index] < conflict_slot.options.size() and conflict_slot.options[answers[conflict_index]].term_id == selected.conflict_term_id:
			return true
	return false

func _selected_answers_by_slot(definition: DeductionCaseDefinition, selected: Array[int], filled: Array[bool]) -> Dictionary:
	var result: Dictionary = {}
	for index: int in range(definition.answer_slots.size()):
		if index < selected.size() and index < filled.size() and filled[index] and selected[index] >= 0 and selected[index] < definition.answer_slots[index].options.size():
			result[String(definition.answer_slots[index].slot_id)] = String(definition.answer_slots[index].options[selected[index]].term_id)
		else:
			result[String(definition.answer_slots[index].slot_id)] = ""
	return result

func _selected_event_ids(definition: DeductionCaseDefinition, selected: Array[int]) -> Array[String]:
	var result: Array[String] = []
	for index: int in range(definition.event_ids.size()):
		if index < selected.size() and selected[index] >= 0 and selected[index] < definition.event_ids.size():
			result.append(String(definition.event_ids[selected[index]]))
		else:
			result.append("")
	return result

func _term_index(slot: DeductionSlotDefinition, term_id: StringName) -> int:
	for index: int in range(slot.options.size()):
		if slot.options[index].term_id == term_id:
			return index
	return -1

func _event_option_counts(definition: DeductionCaseDefinition) -> Array[int]:
	var result: Array[int] = []
	for _event_id: StringName in definition.event_ids:
		result.append(definition.event_ids.size())
	return result

func _answer_option_counts(definition: DeductionCaseDefinition) -> Array[int]:
	var result: Array[int] = []
	for slot: DeductionSlotDefinition in definition.answer_slots:
		result.append(slot.options.size())
	return result

func _current_case_ids() -> Array[String]:
	var result: Array[String] = []
	for definition: DeductionCaseDefinition in case_definitions:
		result.append(String(definition.case_id))
	return result

func _maximum_scene_count() -> int:
	var result: int = 0
	for definition: DeductionCaseDefinition in case_definitions:
		result = maxi(result, definition.scene_ids.size())
	return result

func _maximum_event_count() -> int:
	var result: int = 0
	for definition: DeductionCaseDefinition in case_definitions:
		result = maxi(result, definition.event_ids.size())
	return result

func _maximum_slot_count() -> int:
	var result: int = 0
	for definition: DeductionCaseDefinition in case_definitions:
		result = maxi(result, definition.answer_slots.size())
	return result

func _focus_limit() -> int:
	return _focus_limit_for(mode, _case())

func _focus_limit_for(current_mode: int, definition: DeductionCaseDefinition) -> int:
	if current_mode == 0: return maxi(definition.scene_ids.size() - 1, 0)
	if current_mode == 1: return maxi(definition.event_ids.size() - 1, 0)
	if current_mode == 2: return maxi(definition.answer_slots.size() - 1, 0)
	return 0

func _slot_index(slot_id: StringName) -> int:
	for index: int in range(_case().answer_slots.size()):
		if _case().answer_slots[index].slot_id == slot_id:
			return index
	return -1

func _case_count() -> int:
	return case_definitions.size()

func _case() -> DeductionCaseDefinition:
	return case_definitions[clampi(case_index, 0, case_definitions.size() - 1)]

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent and _catalog_loaded

func _refresh() -> void:
	if _status == null or not _catalog_loaded:
		return
	case_index = clampi(case_index, 0, _case_count() - 1)
	var definition: DeductionCaseDefinition = _case()
	_mode_label.text = MODE_NAMES[mode]
	_case_label.text = definition.title
	for index: int in range(_scene_cards.size()):
		var present: bool = index < definition.scene_ids.size()
		_scene_cards[index].visible = present
		if not present:
			continue
		_scene_cards[index].color = Color("765b4b") if mode == 0 and index == focus else Color("4d4046")
		_scene_titles[index].text = definition.scene_names[index]
		_scene_marks[index].text = "재조사 완료" if rechecked[index] else ("기록 완료" if inspected[index] else "미확인")
		_scene_marks[index].add_theme_color_override("font_color", Color("f0ce8a") if rechecked[index] else (Color("d6c08a") if inspected[index] else Color("c1b4ad")))
	for index: int in range(_event_rows.size()):
		var has_event: bool = index < definition.event_ids.size()
		var has_slot: bool = index < definition.answer_slots.size()
		_event_rows[index].visible = mode == 1 and has_event
		_event_labels[index].visible = mode == 1 and has_event
		_answer_rows[index].visible = mode >= 2 and has_slot
		_answer_labels[index].visible = mode >= 2 and has_slot
		if has_event:
			_event_rows[index].color = Color("806b55") if mode == 1 and index == focus else Color("4b4260")
			_event_labels[index].text = "%d  ·  %s" % [index + 1, definition.event_names[timeline[index]]]
		if has_slot:
			_answer_rows[index].color = Color("806b55") if mode == 2 and index == focus else Color("5d5068")
			var slot: DeductionSlotDefinition = definition.answer_slots[index]
			var selected_name: String = slot.options[answers[index]].display_name if answer_filled[index] else "선택하세요"
			var answer_text: String = "%s  ·  %s%s" % [slot.label, selected_name, "  ✓" if answer_filled[index] else ""]
			_answer_labels[index].text = answer_text
			var answer_font_size: int = 16
			if answer_text.length() > 34 or _answer_rows[index].size.y < 52.0:
				answer_font_size = 14
			if _answer_rows[index].size.y < 42.0:
				answer_font_size = 12
			_answer_labels[index].add_theme_font_size_override("font_size", answer_font_size)
	if mode == 0:
		_body.text = definition.details[focus] if rechecked[focus] else (definition.findings[focus] if inspected[focus] else "Z를 눌러 이 장소의 흔적을 기록하세요. 기록은 서로 다른 순간을 가리킵니다.")
	elif mode == 1:
		_body.text = "사건이 일어난 순서를 위에서부터 다시 배열하세요. 틀려도 기록은 지워지지 않습니다."
	elif mode == 2:
		_body.text = "증거가 가리키는 판단을 한 줄씩 대조하세요. 빈 칸·모순·그럴듯한 오답은 서로 다른 결과로 기록됩니다."
	else:
		_body.text = definition.solved_text
	if _message.is_empty():
		_status.text = "%s · 기록 %d/%d · 재조사 %d/%d · 순서 오답 %d회 · 전체 오답 %d회" % [definition.title, inspected.count(true), inspected.size(), rechecked.count(true), definition.minimum_rechecks, timeline_attempts, mistakes]
	else:
		_status.text = _message

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
