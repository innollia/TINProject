extends GameModule

const ACTIONS: Array[StringName] = [&"after_signal_left", &"after_signal_right", &"after_signal_up", &"after_signal_down", &"after_signal_confirm", &"after_signal_cancel"]
const POSTSCRIPTS: Array[String] = ["접힌 답장", "비어 있는 우편함", "새벽 창문"]
const FINDINGS: Array[String] = [
	"준호가 답장을 접어 두었지만, 봉투 안쪽에는 다음 신호를 받을 시간만 적혀 있었다.",
	"우편함은 비어 있었고, 대신 안쪽 벽에 보랏빛 잉크 한 줄이 남아 있었다.",
	"창문은 닫혀 있었지만, 유리에는 누군가 먼저 기다렸다는 손바닥 자국이 남았다.",
]
const FINAL_TEXT: String = "신호가 지나간 뒤에도 답장은 남아 있었다. 다음 신호에는 돌아갈 주소가 적혀 있었다."

var selected: int = 0
var inspected: Array[bool] = [false, false, false]
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _cards: Array[ColorRect] = []
var _marks: Array[Label] = []
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("211b2a")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("신호가 지나간 뒤", Vector2(62, 46), 42, Color("fff0ce"))
	_label("사건을 닫았지만, 기다림은 아직 세 곳에 남아 있다.", Vector2(64, 108), 20, Color("d8c6cf"))
	var desk := ColorRect.new()
	desk.color = Color("493445")
	desk.position = Vector2(78, 178)
	desk.size = Vector2(996, 106)
	background.add_child(desk)
	var envelope := ColorRect.new()
	envelope.color = Color("e8cf9e")
	envelope.position = Vector2(490, 199)
	envelope.size = Vector2(168, 64)
	background.add_child(envelope)
	var seal := ColorRect.new()
	seal.color = Color("a874a6")
	seal.position = Vector2(560, 218)
	seal.size = Vector2(28, 28)
	background.add_child(seal)
	_label("답장 봉투", Vector2(704, 211), 24, Color("fff0ce"))
	_label("남은 흔적을 모두 읽으면 다음 주소를 확인할 수 있다.", Vector2(704, 247), 16, Color("d8c6cf"))
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(86 + index * 336, 350)
		card.size = Vector2(300, 154)
		card.color = Color("493445")
		background.add_child(card)
		_cards.append(card)
		var title := _label(POSTSCRIPTS[index], card.position + Vector2(18, 22), 23, Color("fff0ce"))
		title.size.x = 264
		var mark := _label("아직 읽지 않음", card.position + Vector2(18, 88), 17, Color("b9aab6"))
		mark.size.x = 264
		_marks.append(mark)
	_label("←→ 흔적 선택   Z 읽기/다음 신호   X 사건 재구성", Vector2(64, 566), 19, Color("f0c9a2"))
	_status = _label("세 흔적은 아직 조용히 접혀 있다.", Vector2(64, 628), 19, Color("d8c6cf"))
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
			if index == 0: execute_command(&"select", {"step": -1})
			elif index == 1: execute_command(&"select", {"step": 1})
			elif index == 4: execute_command(&"confirm")
			elif index == 5: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset": load_state({})
		&"select":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			selected = posmod(selected + int(step), 3)
		&"confirm":
			if inspected.all(func(value: bool) -> bool: return value):
				_request_sent = true
				requested.emit(&"observation", {"id": "after_signal.final", "text": FINAL_TEXT})
				requested.emit(&"portal", {"exit": "forward"})
			elif not inspected[selected]:
				inspected[selected] = true
				_message = FINDINGS[selected]
				requested.emit(&"observation", {"id": "after_signal.%d" % selected, "text": FINDINGS[selected]})
			else:
				_message = "이미 읽은 흔적이다. 다른 자리를 확인해 보자."
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
	_message = ""
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
	return {"selected": _integer(data.get("selected"), 0, 0, 2), "inspected": clean_inspected}

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
		_cards[index].color = Color("76536b") if index == selected else Color("493445")
		_marks[index].text = "읽음" if inspected[index] else "아직 읽지 않음"
		_marks[index].add_theme_color_override("font_color", Color("f0c9a2") if inspected[index] else Color("b9aab6"))
	if _message.is_empty():
		_status.text = "세 흔적을 모두 읽으면 다음 주소가 나타난다." if inspected.all(func(value: bool) -> bool: return value) else "세 흔적은 아직 조용히 접혀 있다."
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
