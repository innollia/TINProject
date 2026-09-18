extends GameModule

const ACTIONS: Array[StringName] = [&"receipt_orchard_left", &"receipt_orchard_right", &"receipt_orchard_up", &"receipt_orchard_down", &"receipt_orchard_confirm", &"receipt_orchard_cancel"]
const WORDS: Array[String] = ["비", "차", "달"]
const SOLUTION: Array[int] = [0, 1, 2]

var fruits: Array[int] = [2, 0, 1]
var selected: int = 0
var failures: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _cards: Array[ColorRect] = []
var _words: Array[Label] = []
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("183126")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("영수증 과수원", Vector2(62, 48), 42, Color("e9ffd1"))
	_label("계산대 종이: 비 먼저, 차 다음, 달은 마지막.", Vector2(64, 108), 21, Color("b8d99e"))
	for index: int in range(3):
		var trunk := ColorRect.new()
		trunk.color = Color("705035")
		trunk.position = Vector2(278 + index * 250, 230)
		trunk.size = Vector2(18, 240)
		background.add_child(trunk)
		var card := ColorRect.new()
		card.position = Vector2(205 + index * 250, 210)
		card.size = Vector2(165, 205)
		card.color = Color("f4edcf")
		background.add_child(card)
		_cards.append(card)
		var word := _label("", card.position + Vector2(0, 50), 64, Color("274132"), true)
		_words.append(word)
	_label("←→ 종이 선택   ↑↓ 글자 바꾸기   Z 계산   X 나룻배", Vector2(64, 558), 20, Color("e9ffd1"))
	_status = _label("종이 열매가 순서를 기다린다.", Vector2(64, 616), 19, Color("b8d99e"))
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
			elif index == 2: execute_command(&"change", {"step": 1})
			elif index == 3: execute_command(&"change", {"step": -1})
			elif index == 4: execute_command(&"confirm")
			else: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"select":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1: return false
			selected = posmod(selected + int(step), 3)
		&"change":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1: return false
			fruits[selected] = posmod(fruits[selected] + int(step), 3)
		&"confirm":
			if fruits == SOLUTION:
				requested.emit(&"observation", {"id": "receipt_orchard.order", "text": "영수증 과수원의 종이 열매를 비·차·달 순서로 계산하자 접힌 출구가 나타났다."})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			else:
				failures = mini(failures + 1, 9999)
				_status.text = "계산대가 종이를 길게 뱉고 다시 조용해졌다."
		&"back":
			_request_sent = true
			requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"fruits": fruits.duplicate(), "selected": selected, "failures": failures}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	fruits.assign(clean["fruits"])
	selected = int(clean["selected"])
	failures = int(clean["failures"])
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_fruits: Array[int] = [2, 0, 1]
	if data.get("fruits") is Array and data["fruits"].size() == 3:
		var candidate: Array[int] = []
		for value: Variant in data["fruits"]:
			if not value is int and not value is float or not is_finite(float(value)): candidate.clear(); break
			candidate.append(clampi(int(value), 0, 2))
		if candidate.size() == 3: clean_fruits = candidate
	return {"fruits": clean_fruits, "selected": _integer(data.get("selected"), 0, 0, 2), "failures": _integer(data.get("failures"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(3):
		_cards[index].color = Color("fff3b0") if index == selected else Color("f4edcf")
		_words[index].text = WORDS[fruits[index]]
	if not _status.text.begins_with("계산대가"):
		_status.text = "현재 순서: %s · %s · %s   틀린 계산 %d회" % [WORDS[fruits[0]], WORDS[fruits[1]], WORDS[fruits[2]], failures]

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 80)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered: label.size.x = 165; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
