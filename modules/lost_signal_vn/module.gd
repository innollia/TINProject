extends GameModule

const ACTIONS: Array[StringName] = [&"lost_signal_vn_left", &"lost_signal_vn_right", &"lost_signal_vn_up", &"lost_signal_vn_down", &"lost_signal_vn_confirm", &"lost_signal_vn_cancel"]
const SCENE_TINTS: Array[Color] = [Color("17263d"), Color("282343"), Color("3a2540"), Color("452538")]
const SPEAKERS: Array[String] = ["기록", "준호", "선택", "준호", "선택", "기록", "준호", "기록"]
const LINES: Array[String] = [
	"새벽 세 시, 끊어진 신호가 네 이름으로 도착했다.",
	"...네가 보낸 거라면, 왜 수신자가 나일까?",
	"",
	"",
	"",
	"",
	"",
	""
]
const CHOICES: Array[String] = ["신호를 먼저 되짚는다", "준호에게 바로 묻는다"]
const FOLLOW_UP_CHOICES: Array[String] = ["이름을 끝까지 읽는다", "답장만 남기고 문을 닫는다"]

var line: int = 0
var choice: int = 0
var second_choice: int = 0
var trust: int = 0
var chapter_done: bool = false
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _chapter: Label
var _speaker: Label
var _dialogue: Label
var _status: Label
var _choice_cards: Array[ColorRect] = []
var _choice_labels: Array[Label] = []
var _characters: Array[ColorRect] = []

func _ready() -> void:
	_background = ColorRect.new()
	_background.color = SCENE_TINTS[0]
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)
	var moon := ColorRect.new()
	moon.color = Color("d9c7ff30")
	moon.position = Vector2(875, 65)
	moon.size = Vector2(150, 150)
	_background.add_child(moon)
	var desk := ColorRect.new()
	desk.color = Color("0d1728")
	desk.position = Vector2(0, 438)
	desk.size = Vector2(1152, 282)
	_background.add_child(desk)
	_chapter = _label("분실된 신호  ·  01", Vector2(62, 42), 20, Color("b4c8eb"))
	_label("새벽에 도착한 한 통의 답장", Vector2(62, 76), 39, Color("f4f0ff"))
	_characters.append(_character(Vector2(98, 168), "기록", Color("5e70b4")))
	_characters.append(_character(Vector2(834, 168), "준호", Color("a96786")))
	_speaker = _label("기록", Vector2(102, 486), 21, Color("ffd48a"))
	var dialogue_box := ColorRect.new()
	dialogue_box.color = Color("101828e8")
	dialogue_box.position = Vector2(82, 474)
	dialogue_box.size = Vector2(988, 184)
	_background.add_child(dialogue_box)
	_speaker.z_index = 2
	_speaker.position = Vector2(110, 494)
	_dialogue = _label("", Vector2(110, 535), 25, Color("f4f0ff"))
	_dialogue.size = Vector2(920, 68)
	_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue.z_index = 2
	for index: int in range(2):
		var card := ColorRect.new()
		card.position = Vector2(112 + index * 470, 590)
		card.size = Vector2(430, 50)
		card.color = Color("293a61")
		card.z_index = 2
		add_child(card)
		_choice_cards.append(card)
		var text := _label(CHOICES[index], card.position + Vector2(18, 10), 19, Color("e9ecff"))
		text.z_index = 3
		text.size.x = 390
		_choice_labels.append(text)
	_status = _label("Z 다음 장면   ↑↓ 선택   X 이전", Vector2(82, 680), 18, Color("b4c8eb"))
	_status.z_index = 2
	_refresh()

func _character(at: Vector2, title: String, tint: Color) -> ColorRect:
	var card := ColorRect.new()
	card.position = at
	card.size = Vector2(220, 240)
	card.color = Color("101828b0")
	_background.add_child(card)
	var face := ColorRect.new()
	face.color = tint
	face.position = at + Vector2(78, 44)
	face.size = Vector2(64, 64)
	_background.add_child(face)
	var body := ColorRect.new()
	body.color = tint.darkened(0.35)
	body.position = at + Vector2(45, 130)
	body.size = Vector2(130, 110)
	_background.add_child(body)
	var name_label := _label(title, at + Vector2(0, 16), 20, Color("f4f0ff"), true)
	name_label.size.x = 220
	return card

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
			if index == 0 or index == 2: execute_command(&"choose", {"step": -1})
			elif index == 1 or index == 3: execute_command(&"choose", {"step": 1})
			elif index == 4: execute_command(&"advance")
			else: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset": load_state({})
		&"choose":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			if line == 2:
				choice = posmod(choice + int(step), CHOICES.size())
			elif line == 4:
				second_choice = posmod(second_choice + int(step), FOLLOW_UP_CHOICES.size())
			else:
				return false
		&"advance":
			if line == 2:
				trust += 1 if choice == 0 else 0
				line = 3
			elif line == 4:
				trust += 1 if second_choice == 0 else 0
				line = 5
			elif chapter_done:
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			elif line < LINES.size() - 1:
				line += 1
				if line == LINES.size() - 1:
					chapter_done = true
					requested.emit(&"observation", {"id": "lost_signal_vn.reply", "text": _line_text()})
			else:
				return false
		&"back":
			if line > 0 and not chapter_done:
				line -= 1
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"line": line, "choice": choice, "second_choice": second_choice, "trust": trust, "finished": chapter_done}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	line = int(clean["line"])
	choice = int(clean["choice"])
	second_choice = int(clean["second_choice"])
	trust = int(clean["trust"])
	chapter_done = bool(clean["finished"])
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	return {
		"line": _integer(data.get("line"), 0, 0, LINES.size() - 1),
		"choice": _integer(data.get("choice"), 0, 0, CHOICES.size() - 1),
		"second_choice": _integer(data.get("second_choice"), 0, 0, FOLLOW_UP_CHOICES.size() - 1),
		"trust": _integer(data.get("trust"), 0, 0, 2),
		"finished": data.get("finished") if data.get("finished") is bool else false,
	}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _dialogue == null:
		return
	_background.color = SCENE_TINTS[mini(line / 2, SCENE_TINTS.size() - 1)]
	_chapter.text = "분실된 신호  ·  %02d" % (line + 1)
	_speaker.text = SPEAKERS[line]
	if line == 2 or line == 4:
		_dialogue.text = "이 답장을 어떻게 이어 갈까?" if line == 4 else "이 답장을 어떻게 시작할까?"
		var options: Array[String] = CHOICES if line == 2 else FOLLOW_UP_CHOICES
		var selected: int = choice if line == 2 else second_choice
		for index: int in range(_choice_cards.size()):
			_choice_cards[index].visible = true
			_choice_labels[index].visible = true
			_choice_labels[index].text = options[index]
			_choice_cards[index].color = Color("806b9e") if index == selected else Color("293a61")
			_choice_labels[index].add_theme_color_override("font_color", Color("fff2ce") if index == selected else Color("e9ecff"))
		_status.text = "↑↓ 선택   Z 답장   X 이전"
	else:
		_dialogue.text = _line_text()
		for index: int in range(_choice_cards.size()):
			_choice_cards[index].visible = false
			_choice_labels[index].visible = false
	if line != 2 and line != 4:
		_status.text = "Z 다음 장면   X 이전" if not chapter_done else "Z 기록하고 다음 공간으로"
	_characters[0].color = Color("24375d") if line % 2 == 0 else Color("101828b0")
	_characters[1].color = Color("57354d") if line >= 3 else Color("101828b0")

func _line_text() -> String:
	match line:
		3:
			return "신호를 되짚어 보자. 네가 앞에 서면 나는 뒤를 볼게." if choice == 0 else "좋아. 이번에는 네가 먼저 물어. 나는 대답할 준비를 할게."
		5:
			return "보라색 잡음 사이로, 누군가의 이름이 한 글자씩 되돌아왔다." if second_choice == 0 else "답장을 접으려는 순간, 잉크가 종이 안쪽에서 다시 번졌다."
		6:
			return "네가 끝까지 읽어 줘서 다행이야. 이번에는 내가 먼저 받을게." if trust >= 2 else "괜찮아. 다음에는 한 글자만 와도 네가 알아볼게."
		7:
			return "끊어진 신호에 답장을 보냈고, 준호가 다음 신호를 먼저 받겠다고 약속했다." if trust >= 1 else "답장은 짧았지만 도착했다. 준호는 다음 신호를 기다리겠다고 했다."
		_:
			return LINES[line]

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
