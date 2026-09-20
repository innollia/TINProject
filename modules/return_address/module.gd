extends GameModule

const ACTIONS: Array[StringName] = [&"return_address_left", &"return_address_right", &"return_address_up", &"return_address_down", &"return_address_confirm", &"return_address_cancel"]
const SLOT_NAMES: Array[String] = ["받는 이", "찾을 곳", "남은 표식"]
const OPTIONS: Array = [
	["준호", "사공", "시계공"],
	["우편함", "부두", "온실"],
	["창문", "종이달", "낡은 종"]
]
const SOLUTION: Array[int] = [0, 0, 0]
const FINAL_TEXT: String = "세 단어를 주소로 옮겼다. 준호가 기다리는 곳은 창문 뒤 기록실이었다."

var focus: int = 0
var parts: Array[int] = [0, 0, 0]
var attempts: int = 0
var solved: bool = false
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _rows: Array[ColorRect] = []
var _values: Array[Label] = []
var _address: Label
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("1c2630")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("돌아갈 주소", Vector2(62, 44), 42, Color("f6e4bd"))
	_label("답장 안쪽에서 읽은 세 단어를 주소 칸에 옮긴다.", Vector2(64, 106), 20, Color("b9c8c9"))
	var letter := ColorRect.new()
	letter.color = Color("3b4b51")
	letter.position = Vector2(62, 178)
	letter.size = Vector2(520, 340)
	background.add_child(letter)
	_label("주소 조각", Vector2(94, 208), 25, Color("f6e4bd"))
	for index: int in range(3):
		var row := ColorRect.new()
		row.position = Vector2(92, 264 + index * 82)
		row.size = Vector2(460, 62)
		row.color = Color("4c6064")
		background.add_child(row)
		_rows.append(row)
		var slot := _label(SLOT_NAMES[index], row.position + Vector2(18, 17), 18, Color("d8e4df"))
		slot.size.x = 130
		var value := _label("", row.position + Vector2(180, 14), 23, Color("f6e4bd"))
		value.size.x = 250
		_values.append(value)
	var destination := ColorRect.new()
	destination.color = Color("493b46")
	destination.position = Vector2(650, 178)
	destination.size = Vector2(440, 340)
	background.add_child(destination)
	_label("봉투 안쪽에 남은 문장", Vector2(684, 208), 23, Color("f6e4bd"))
	_address = _label("", Vector2(684, 274), 22, Color("f0d5bc"))
	_address.size = Vector2(370, 150)
	_address.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label("←→ 조각 선택   ↑↓ 칸 이동   Z 봉인   X 후일담", Vector2(64, 568), 19, Color("f0d5bc"))
	_status = _label("세 흔적의 첫 단어를 차례로 옮겨 보자.", Vector2(64, 628), 19, Color("b9c8c9"))
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
			if index == 0: execute_command(&"choose", {"step": -1})
			elif index == 1: execute_command(&"choose", {"step": 1})
			elif index == 2: execute_command(&"focus", {"step": -1})
			elif index == 3: execute_command(&"focus", {"step": 1})
			elif index == 4: execute_command(&"seal")
			elif index == 5: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset": load_state({})
		&"choose":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			parts[focus] = posmod(parts[focus] + int(step), 3)
		&"focus":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			focus = posmod(focus + int(step), 3)
		&"seal":
			if parts == SOLUTION:
				solved = true
				_message = FINAL_TEXT
				_request_sent = true
				requested.emit(&"observation", {"id": "return_address.solved", "text": FINAL_TEXT})
				requested.emit(&"portal", {"exit": "forward"})
			else:
				attempts = mini(attempts + 1, 9999)
				_message = "주소가 맞물리지 않는다. 세 흔적에서 처음 들린 말을 다시 떠올려 보자."
		&"back":
			_request_sent = true
			requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"focus": focus, "parts": parts.duplicate(), "attempts": attempts, "solved": solved}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	focus = int(clean["focus"])
	parts.assign(clean["parts"])
	attempts = int(clean["attempts"])
	solved = bool(clean["solved"])
	_message = ""
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_parts: Array[int] = [0, 0, 0]
	if data.get("parts") is Array and data["parts"].size() == 3:
		var candidate: Array[int] = []
		for value: Variant in data["parts"]:
			if not value is int and not value is float or not is_finite(float(value)):
				candidate.clear()
				break
			candidate.append(clampi(int(value), 0, 2))
		if candidate.size() == 3:
			clean_parts = candidate
	return {"focus": _integer(data.get("focus"), 0, 0, 2), "parts": clean_parts, "attempts": _integer(data.get("attempts"), 0, 0, 9999), "solved": data.get("solved") if data.get("solved") is bool else false}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null:
		return
	for index: int in range(3):
		_rows[index].color = Color("78644d") if index == focus else Color("4c6064")
		_values[index].text = str(OPTIONS[index][parts[index]])
	_address.text = "받는 이  ·  %s\n찾을 곳  ·  %s\n남은 표식  ·  %s" % [OPTIONS[0][parts[0]], OPTIONS[1][parts[1]], OPTIONS[2][parts[2]]]
	if _message.is_empty():
		_status.text = "세 흔적의 첫 단어를 차례로 옮겨 보자. · 오답 %d회" % attempts
	else:
		_status.text = _message

func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	add_child(label)
	return label
