extends GameModule

const ACTIONS: Array[StringName] = [&"dedution_casework_left", &"dedution_casework_right", &"dedution_casework_up", &"dedution_casework_down", &"dedution_casework_confirm", &"dedution_casework_cancel"]
const MODE_NAMES: Array[String] = ["현장 기록", "사건 순서", "판정표", "사건 종결"]
const SCENE_NAMES: Array[String] = ["부서진 표지판", "젖은 장갑", "빈 신호병"]
const FINDINGS: Array[String] = [
	"표지판의 나사는 안쪽에서 풀렸다. 누군가 출구를 막으려 한 것이 아니라 방향을 바꾸려 했다.",
	"장갑 안쪽에 푸른 가루가 남았다. 물에 젖기 전부터 봉투를 만진 사람의 흔적이다.",
	"신호병은 비어 있지만 심지는 따뜻하다. 마지막 신호는 병이 아니라 창문 쪽으로 옮겨졌다."
]
const EVENT_NAMES: Array[String] = ["표지판 방향을 바꿈", "봉투를 숨김", "창문으로 신호를 옮김"]
const EVENT_OPTIONS: Array[Array] = [
	["표지판 방향을 바꿈", "봉투를 숨김", "창문으로 신호를 옮김"],
	["표지판 방향을 바꿈", "봉투를 숨김", "창문으로 신호를 옮김"],
	["표지판 방향을 바꿈", "봉투를 숨김", "창문으로 신호를 옮김"]
]
const TIMELINE_SOLUTION: Array[int] = [0, 1, 2]
const SUSPECTS: Array[String] = ["마루 · 뱃사공", "서윤 · 시계공", "연화 · 합창단원"]
const METHODS: Array[String] = ["표지판을 돌려 길을 감춤", "푸른 가루 봉투를 바꿔치기", "빈 신호병을 창문에 걸기"]
const MOTIVES: Array[String] = ["다음 배달을 늦추기", "자기 이름을 지우기", "비밀 합창을 들키지 않기"]
const ANSWER_NAMES: Array[String] = ["누가", "어떻게", "왜"]
const ANSWER_SOLUTION: Array[int] = [1, 1, 1]
const SOLVED_TEXT: String = "서윤은 푸른 가루가 묻은 봉투를 바꿔치기해 자기 이름을 지우려 했다."

var mode: int = 0
var focus: int = 0
var inspected: Array[bool] = [false, false, false]
var timeline: Array[int] = [0, 0, 0]
var answers: Array[int] = [0, 0, 0]
var timeline_attempts: int = 0
var mistakes: int = 0
var solved: bool = false
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _mode_label: Label
var _body: Label
var _status: Label
var _scene_cards: Array[ColorRect] = []
var _scene_marks: Array[Label] = []
var _event_rows: Array[ColorRect] = []
var _event_labels: Array[Label] = []
var _answer_rows: Array[ColorRect] = []
var _answer_labels: Array[Label] = []

func _ready() -> void:
	_background = ColorRect.new()
	_background.color = Color("211b25")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_label("빈 신호 사건기록", Vector2(60, 40), 40, Color("f2dfb0"))
	_label("현장에 남은 순서를 복원하고, 마지막 문장을 판정한다", Vector2(64, 96), 20, Color("c9c0b6"))
	_mode_label = _label("현장 기록", Vector2(64, 132), 18, Color("d8a975"))
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
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(92, 342 + index * 54)
		card.size = Vector2(540, 42)
		card.color = Color("4d4046")
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(card)
		_scene_cards.append(card)
		var title := _label(SCENE_NAMES[index], card.position + Vector2(14, 8), 17, Color("f2dfb0"))
		title.size.x = 220
		var mark := _label("미확인", card.position + Vector2(390, 8), 16, Color("c1b4ad"))
		mark.size.x = 130
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
	for index: int in range(3):
		var event_row := ColorRect.new()
		event_row.position = Vector2(728, 286 + index * 76)
		event_row.size = Vector2(334, 58)
		event_row.color = Color("4b4260")
		event_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(event_row)
		_event_rows.append(event_row)
		var event_label := _label("", event_row.position + Vector2(14, 8), 17, Color("f5e9ff"))
		event_label.size = Vector2(306, 44)
		event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_event_labels.append(event_label)
		var answer_row := ColorRect.new()
		answer_row.position = Vector2(728, 286 + index * 76)
		answer_row.size = Vector2(334, 58)
		answer_row.color = Color("5d5068")
		answer_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_background.add_child(answer_row)
		_answer_rows.append(answer_row)
		var answer_label := _label("", answer_row.position + Vector2(14, 8), 17, Color("f5e9ff"))
		answer_label.size = Vector2(306, 44)
		answer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_answer_labels.append(answer_label)
	_label("←→ 대상/칸 선택   ↑↓ 화면 이동·보기   Z 기록/판정   X 뒤로", Vector2(64, 568), 18, Color("e4c78c"))
	_status = _label("세 장소를 순서와 상관없이 기록하세요.", Vector2(64, 624), 18, Color("c9c0b6"))
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
			var limit: int = 2
			if mode == 2: limit = 2
			elif mode == 3: return false
			focus = posmod(focus + int(step), limit + 1)
		&"cycle":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 1:
				timeline[focus] = posmod(timeline[focus] + int(step), 3)
			elif mode == 2:
				answers[focus] = posmod(answers[focus] + int(step), 3)
			else:
				return false
		&"vertical":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if step == -1 and mode > 0:
				mode -= 1
				focus = 0
			elif step == 1 and mode == 0 and inspected.all(func(value: bool) -> bool: return value):
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
	return {"mode": mode, "focus": focus, "inspected": inspected.duplicate(), "timeline": timeline.duplicate(), "answers": answers.duplicate(), "timeline_attempts": timeline_attempts, "mistakes": mistakes, "solved": solved}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	mode = int(clean["mode"])
	focus = int(clean["focus"])
	inspected.assign(clean["inspected"])
	timeline.assign(clean["timeline"])
	answers.assign(clean["answers"])
	timeline_attempts = int(clean["timeline_attempts"])
	mistakes = int(clean["mistakes"])
	solved = bool(clean["solved"])
	_message = ""
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _inspect_or_open_timeline() -> void:
	if not inspected[focus]:
		inspected[focus] = true
		_message = FINDINGS[focus]
		requested.emit(&"observation", {"id": "dedution_casework.clue_%d" % focus, "text": FINDINGS[focus]})
	elif inspected.all(func(value: bool) -> bool: return value):
		mode = 1
		focus = 0
		_message = "세 기록을 모았다. 이제 실제로 일어난 순서를 세워 보자."
	else:
		_message = "아직 기록하지 않은 장소가 있다."

func _check_timeline() -> void:
	if timeline == TIMELINE_SOLUTION:
		mode = 2
		focus = 0
		_message = "시간의 순서가 이어졌다. 세 칸의 판정표를 완성하자."
	else:
		timeline_attempts = mini(timeline_attempts + 1, 9999)
		mistakes = mini(mistakes + 1, 9999)
		_message = "기록 두 장이 겹친다. 순서를 다시 배열해 보자."

func _check_answers() -> void:
	if answers == ANSWER_SOLUTION:
		solved = true
		mode = 3
		focus = 0
		_message = "세 칸의 인과가 맞물렸다. Z로 사건을 닫자."
	else:
		mistakes = mini(mistakes + 1, 9999)
		_message = "문장이 맞지 않는다. 증거 기록으로 돌아가 다시 대조할 수 있다."

func _finish() -> void:
	if not solved:
		return
	_request_sent = true
	requested.emit(&"observation", {"id": "dedution_casework.solved", "text": SOLVED_TEXT})
	requested.emit(&"portal", {"exit": "forward"})

func _normalize(data: Dictionary) -> Dictionary:
	var clean_inspected: Array[bool] = [false, false, false]
	if data.get("inspected") is Array and data["inspected"].size() == 3:
		var candidate: Array[bool] = []
		for value: Variant in data["inspected"]:
			if not value is bool:
				candidate.clear()
				break
			candidate.append(value)
		if candidate.size() == 3: clean_inspected = candidate
	var clean_timeline: Array[int] = _normalize_choices(data.get("timeline"))
	var clean_answers: Array[int] = _normalize_choices(data.get("answers"))
	var clean_mode: int = _integer(data.get("mode"), 0, 0, 3)
	var focus_max: int = 2
	return {"mode": clean_mode, "focus": _integer(data.get("focus"), 0, 0, focus_max), "inspected": clean_inspected, "timeline": clean_timeline, "answers": clean_answers, "timeline_attempts": _integer(data.get("timeline_attempts"), 0, 0, 9999), "mistakes": _integer(data.get("mistakes"), 0, 0, 9999), "solved": data.get("solved") if data.get("solved") is bool else false}

func _normalize_choices(value: Variant) -> Array[int]:
	var choices: Array[int] = [0, 0, 0]
	if not value is Array or value.size() != 3:
		return choices
	var candidate: Array[int] = []
	for item: Variant in value:
		if not item is int and not item is float or not is_finite(float(item)):
			return choices
		candidate.append(clampi(int(item), 0, 2))
	return candidate if candidate.size() == 3 else choices

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null:
		return
	_mode_label.text = MODE_NAMES[mode]
	for index: int in range(3):
		_scene_cards[index].color = Color("765b4b") if mode == 0 and index == focus else Color("4d4046")
		_scene_marks[index].text = "기록 완료" if inspected[index] else "미확인"
		_scene_marks[index].add_theme_color_override("font_color", Color("f0ce8a") if inspected[index] else Color("c1b4ad"))
		_event_rows[index].visible = mode == 1
		_answer_rows[index].visible = mode >= 2
		_event_labels[index].visible = mode == 1
		_answer_labels[index].visible = mode >= 2
		_event_rows[index].color = Color("806b55") if mode == 1 and index == focus else Color("4b4260")
		_answer_rows[index].color = Color("806b55") if mode == 2 and index == focus else Color("5d5068")
		_event_labels[index].text = "%d  ·  %s" % [index + 1, EVENT_OPTIONS[index][timeline[index]]]
		_answer_labels[index].text = "%s  ·  %s" % [ANSWER_NAMES[index], _answer_text(index, answers[index])]
	if mode == 0:
		_body.text = FINDINGS[focus] if inspected[focus] else "Z를 눌러 이 장소의 흔적을 기록하세요. 세 기록은 서로 다른 순간을 가리킵니다."
	elif mode == 1:
		_body.text = "사건이 일어난 순서를 위에서부터 다시 배열하세요. 틀려도 기록은 지워지지 않습니다."
	elif mode == 2:
		_body.text = "증거가 가리키는 사람·방법·동기를 한 줄씩 대조하세요. 오답 뒤에도 현장으로 돌아갈 수 있습니다."
	else:
		_body.text = "마루가 표지판을 돌린 뒤 서윤이 봉투를 바꿔치기했고, 마지막 신호는 창문으로 옮겨졌다."
	if _message.is_empty():
		_status.text = "기록 %d/3 · 순서 오답 %d회 · 전체 오답 %d회" % [inspected.count(true), timeline_attempts, mistakes]
	else:
		_status.text = _message

func _answer_text(slot: int, value: int) -> String:
	if slot == 0: return SUSPECTS[value]
	if slot == 1: return METHODS[value]
	return MOTIVES[value]

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
