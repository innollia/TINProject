extends GameModule

const ACTIONS: Array[StringName] = [&"paper_moon_clinic_left", &"paper_moon_clinic_right", &"paper_moon_clinic_up", &"paper_moon_clinic_down", &"paper_moon_clinic_confirm", &"paper_moon_clinic_cancel"]
const SYMPTOMS: Array[String] = ["빛을 먹음", "그림자가 재채기", "새벽에 접힘"]
const FINDINGS: Array[String] = [
	"종이달은 빛을 먹은 뒤 가장자리부터 은은하게 따뜻해진다.",
	"종이달의 그림자는 먼지가 없는 곳에서도 세 번 재채기한다.",
	"종이달은 새벽마다 반으로 접혔다가 아침에 스스로 펴진다.",
]

var selected: int = 0
var inspected: Array[bool] = [false, false, false]
var _held: Dictionary = {}
var _request_sent: bool = false
var _cards: Array[ColorRect] = []
var _marks: Array[Label] = []
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("251f3b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("종이달 진료소", Vector2(62, 48), 42, Color("fff0c7"))
	_label("창가의 환자는 말 대신 세 장의 증상 카드를 내밀었다.", Vector2(64, 108), 20, Color("cfc3ea"))
	var moon := _label("◐", Vector2(456, 158), 112, Color("ffe6a3"), true)
	moon.size.x = 240
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(100 + index * 345, 350)
		card.size = Vector2(300, 150)
		card.color = Color("44385f")
		background.add_child(card)
		_cards.append(card)
		_label(SYMPTOMS[index], card.position + Vector2(0, 32), 24, Color("fff0c7"), true)
		var mark := _label("미진찰", card.position + Vector2(0, 88), 18, Color("a99fc4"), true)
		_marks.append(mark)
	_label("←→ 증상 선택   Z 진찰/나가기   X 기억 세관", Vector2(64, 552), 20, Color("fff0c7"))
	_status = _label("종이 청진기가 가볍게 바스락거린다.", Vector2(64, 616), 19, Color("cfc3ea"))
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
	if not _can_input(): _held.clear(); return
	for index: int in range(ACTIONS.size()):
		var pressed: bool = context.is_action_pressed(ACTIONS[index])
		var previous: bool = bool(_held.get(ACTIONS[index], false))
		_held[ACTIONS[index]] = pressed
		if pressed and not previous:
			if index == 0: execute_command(&"select", {"step": -1})
			elif index == 1: execute_command(&"select", {"step": 1})
			elif index == 4: execute_command(&"inspect")
			elif index == 5: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"select":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1: return false
			selected = posmod(selected + int(step), 3)
		&"inspect":
			if inspected.all(func(value: bool) -> bool: return value):
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			elif not inspected[selected]:
				inspected[selected] = true
				_status.text = FINDINGS[selected]
				requested.emit(&"observation", {"id": "paper_moon_clinic.%d" % selected, "text": FINDINGS[selected]})
		&"back":
			_request_sent = true
			requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"selected": selected, "inspected": inspected.duplicate()}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	selected = int(clean["selected"])
	inspected.assign(clean["inspected"])
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
			if not value is bool: candidate.clear(); break
			candidate.append(value)
		if candidate.size() == 3: clean_inspected = candidate
	return {"selected": _integer(data.get("selected"), 0, 0, 2), "inspected": clean_inspected}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(3):
		_cards[index].color = Color("76638f") if index == selected else Color("44385f")
		_marks[index].text = "진찰 완료" if inspected[index] else "미진찰"
	if inspected.all(func(value: bool) -> bool: return value):
		_status.text = "세 증상 모두 위급하지 않다. Z로 신호 기록실에 돌아간다."

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 70)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered: label.size.x = 300; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
