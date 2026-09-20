extends GameModule

const ACTIONS: Array[StringName] = [&"violet_case_left", &"violet_case_right", &"violet_case_up", &"violet_case_down", &"violet_case_confirm", &"violet_case_cancel"]
const MODE_NAMES: Array[String] = ["현장 조사", "증거 기록", "추리 입력"]
const HOTSPOTS: Array[String] = ["신호 열쇠", "잠긴 창문", "바닥의 이름표"]
const FINDINGS: Array[String] = [
	"신호 열쇠 왼쪽 홈에 보랏빛 잉크와 가는 쇳가루가 함께 묻어 있다. 시계공 작업대에서 보던 잉크다.",
	"창문 잠금 장치는 안쪽 그대로다. 밖에서 들어온 흔적보다 신호 자체가 복제된 흔적에 가깝다.",
	"바닥의 찢긴 이름표에는 ‘서…’만 남았다. 지워진 이름을 되찾겠다는 문장이 뒤집혀 있다."
]
const SUSPECTS: Array[String] = ["서윤 · 시계공", "마루 · 뱃사공", "연화 · 합창단원"]
const METHODS: Array[String] = ["창문으로 훔치기", "보랏빛 잉크로 신호 복제", "종 바꿔치기"]
const MOTIVES: Array[String] = ["자기 이름을 되찾기", "경주에서 이기기", "비를 멈추기"]
const ANSWER_NAMES: Array[String] = ["범인", "수법", "동기"]
const SOLUTION: Array[int] = [0, 1, 0]

var mode: int = 0
var focus: int = 0
var inspected: Array[bool] = [false, false, false]
var answers: Array[int] = [0, 0, 0]
var mistakes: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _mode_label: Label
var _notebook_title: Label
var _notebook_body: Label
var _status: Label
var _hotspot_cards: Array[ColorRect] = []
var _hotspot_marks: Array[Label] = []
var _answer_cards: Array[ColorRect] = []
var _answer_labels: Array[Label] = []

func _ready() -> void:
	_background = ColorRect.new()
	_background.color = Color("191625")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)
	_label("자정의 보랏빛 사건", Vector2(60, 42), 39, Color("f7e9ff"))
	_label("사라진 첫 신호 · 조사 기록 01", Vector2(64, 100), 20, Color("c3aed2"))
	_mode_label = _label("현장 조사", Vector2(64, 136), 18, Color("e6b6ff"))
	var scene_panel := ColorRect.new()
	scene_panel.color = Color("292238")
	scene_panel.position = Vector2(60, 178)
	scene_panel.size = Vector2(630, 350)
	_background.add_child(scene_panel)
	var window := ColorRect.new()
	window.color = Color("4b3f72")
	window.position = Vector2(416, 213)
	window.size = Vector2(205, 130)
	_background.add_child(window)
	var window_bar := ColorRect.new()
	window_bar.color = Color("211b2f")
	window_bar.position = Vector2(510, 213)
	window_bar.size = Vector2(8, 130)
	_background.add_child(window_bar)
	var desk := ColorRect.new()
	desk.color = Color("5b3d55")
	desk.position = Vector2(100, 385)
	desk.size = Vector2(530, 90)
	_background.add_child(desk)
	var key := ColorRect.new()
	key.color = Color("e5c76b")
	key.position = Vector2(174, 350)
	key.size = Vector2(140, 18)
	_background.add_child(key)
	var key_ring := ColorRect.new()
	key_ring.color = Color("c4a85b")
	key_ring.position = Vector2(160, 343)
	key_ring.size = Vector2(22, 32)
	_background.add_child(key_ring)
	var tag := ColorRect.new()
	tag.color = Color("d9c2df")
	tag.position = Vector2(348, 407)
	tag.size = Vector2(76, 42)
	_background.add_child(tag)
	var moon := ColorRect.new()
	moon.color = Color("e7c9ff35")
	moon.position = Vector2(506, 235)
	moon.size = Vector2(32, 32)
	_background.add_child(moon)
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = [Vector2(112, 306), Vector2(394, 232), Vector2(320, 410)][index]
		card.size = Vector2(174, 62)
		card.color = Color("3b3050")
		card.z_index = 2
		add_child(card)
		_hotspot_cards.append(card)
		var name_label := _label(HOTSPOTS[index], card.position + Vector2(12, 9), 17, Color("f7e9ff"))
		name_label.z_index = 3
		name_label.size.x = 150
		var mark := _label("미확인", card.position + Vector2(12, 34), 14, Color("bca9ca"))
		mark.z_index = 3
		mark.size.x = 150
		_hotspot_marks.append(mark)
	var notebook := ColorRect.new()
	notebook.color = Color("30263e")
	notebook.position = Vector2(720, 178)
	notebook.size = Vector2(372, 350)
	_background.add_child(notebook)
	_notebook_title = _label("사건 메모", Vector2(750, 210), 25, Color("ffd88c"))
	_notebook_title.z_index = 2
	_notebook_body = _label("현장을 훑고 세 단서를 모두 기록한 뒤, 세 칸의 추리를 완성하세요.", Vector2(750, 262), 18, Color("eadff2"))
	_notebook_body.size = Vector2(310, 148)
	_notebook_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notebook_body.z_index = 2
	for index: int in range(3):
		var answer_card := ColorRect.new()
		answer_card.position = Vector2(746, 258 + index * 72)
		answer_card.size = Vector2(320, 58)
		answer_card.color = Color("4c3d61")
		answer_card.z_index = 2
		add_child(answer_card)
		_answer_cards.append(answer_card)
		var answer_label := _label("", answer_card.position + Vector2(14, 10), 16, Color("f7e9ff"))
		answer_label.z_index = 3
		answer_label.size.x = 292
		_answer_labels.append(answer_label)
	_label("←→ 대상/답 선택   ↑↓ 화면·칸 이동   Z 조사/판정   X 뒤로", Vector2(62, 570), 18, Color("e6b6ff"))
	_status = _label("세 단서를 찾아 사건의 문장을 완성하세요.", Vector2(62, 625), 18, Color("c3aed2"))
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
		&"reset": load_state({})
		&"move":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 2:
				answers[focus] = posmod(answers[focus] + int(step), 3)
			else:
				focus = posmod(focus + int(step), 3)
		&"vertical":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if mode == 2:
				focus = posmod(focus + int(step), 3)
			else:
				mode = posmod(mode + int(step), 3)
		&"confirm":
			if mode == 2:
				_submit()
			elif not inspected[focus]:
				inspected[focus] = true
				_status.text = FINDINGS[focus]
				requested.emit(&"observation", {"id": "violet_case.clue_%d" % focus, "text": FINDINGS[focus]})
			elif mode == 1:
				_status.text = "이미 기록한 단서다. 세 문장을 연결해 보세요."
		&"back":
			if mode != 0:
				mode = 0
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func _submit() -> void:
	if not inspected.all(func(value: bool) -> bool: return value):
		_status.text = "아직 읽지 않은 증거가 있다. 현장 조사로 돌아가세요."
		return
	if answers == SOLUTION:
		_status.text = "세 문장이 맞물렸다. 서윤의 이름이 신호 안에서 되돌아왔다."
		requested.emit(&"observation", {"id": "violet_case.solution", "text": "서윤은 보랏빛 잉크로 신호를 복제해 자기 이름을 되찾으려 했다."})
		_request_sent = true
		requested.emit(&"portal", {"exit": "forward"})
	else:
		mistakes = mini(mistakes + 1, 9999)
		_status.text = "추리가 어긋났다. 기록을 다시 읽고 세 칸을 고쳐 쓰세요."

func save_state() -> Dictionary:
	return {"mode": mode, "focus": focus, "inspected": inspected.duplicate(), "answers": answers.duplicate(), "mistakes": mistakes}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	mode = int(clean["mode"])
	focus = int(clean["focus"])
	inspected.assign(clean["inspected"])
	answers.assign(clean["answers"])
	mistakes = int(clean["mistakes"])
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_inspected: Array[bool] = [false, false, false]
	if data.get("inspected") is Array and data["inspected"].size() == 3:
		var candidate: Array[bool] = []
		for value: Variant in data["inspected"]:
			if not value is bool:
				candidate.clear()
				break
			candidate.append(value)
		if candidate.size() == 3:
			clean_inspected = candidate
	var clean_answers: Array[int] = [0, 0, 0]
	if data.get("answers") is Array and data["answers"].size() == 3:
		var candidate_answers: Array[int] = []
		for value: Variant in data["answers"]:
			if not value is int and not value is float or not is_finite(float(value)):
				candidate_answers.clear()
				break
			candidate_answers.append(clampi(int(value), 0, 2))
		if candidate_answers.size() == 3:
			clean_answers = candidate_answers
	return {"mode": _integer(data.get("mode"), 0, 0, 2), "focus": _integer(data.get("focus"), 0, 0, 2), "inspected": clean_inspected, "answers": clean_answers, "mistakes": _integer(data.get("mistakes"), 0, 0, 9999)}

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
		_hotspot_cards[index].color = Color("725d8c") if index == focus and mode != 2 else Color("3b3050")
		_hotspot_marks[index].text = "기록 완료" if inspected[index] else "미확인"
		_hotspot_marks[index].add_theme_color_override("font_color", Color("ffd88c") if inspected[index] else Color("bca9ca"))
	if mode == 0:
		_notebook_title.text = "현장 메모 · " + HOTSPOTS[focus]
		_notebook_body.text = FINDINGS[focus] if inspected[focus] else "Z를 눌러 이 장소를 자세히 기록하세요. 단서는 서로 다른 부분에 흩어져 있다."
	elif mode == 1:
		_notebook_title.text = "증거 기록 · %d/3" % inspected.count(true)
		_notebook_body.text = FINDINGS[focus] if inspected[focus] else "아직 확인하지 않은 흔적이다. 현장 조사로 돌아가 Z를 누르세요."
	else:
		_notebook_title.text = "추리 입력 · " + ANSWER_NAMES[focus]
		_notebook_body.text = "세 단서가 가리키는 범인, 수법, 동기를 한 줄씩 맞춰 보세요. 오답은 기록되지만 사건은 다시 풀 수 있습니다."
	for index: int in range(3):
		_answer_cards[index].visible = mode == 2
		_answer_labels[index].visible = mode == 2
		_answer_cards[index].color = Color("806b9e") if index == focus else Color("4c3d61")
		_answer_labels[index].text = "%s  ·  %s" % [ANSWER_NAMES[index], _answer_text(index, answers[index])]
	if mode == 2:
		_status.text = "칸 %d/3 · ←→ 답 선택 · Z 판정 · 오답 %d회" % [focus + 1, mistakes]

func _answer_text(slot: int, value: int) -> String:
	if slot == 0: return SUSPECTS[value]
	if slot == 1: return METHODS[value]
	return MOTIVES[value]

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered:
		label.size.x = 220
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
