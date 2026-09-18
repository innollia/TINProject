extends GameModule

const ACTIONS: Array[StringName] = [&"quiet_locker_left", &"quiet_locker_right", &"quiet_locker_up", &"quiet_locker_down", &"quiet_locker_confirm", &"quiet_locker_cancel"]
const MESSAGES: Array[String] = [
	"미지근한 찻잔 두 개가 나란히 말라 있다.",
	"접힌 쪽지: 비가 거꾸로 와도 손잡이는 아래로 두자. — 준호",
	"마른 양말 한 짝과 비어 있는 자리가 서로 기대어 있다.",
]

var selected: int = 0
var inspected: Array[bool] = [false, false, false]
var _held: Dictionary = {}
var _request_sent: bool = false
var _doors: Array[ColorRect] = []
var _marks: Array[Label] = []
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("241f28")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("조용한 사물함", Vector2(62, 50), 42, Color("f6e8db"))
	_label("기상 방송실 뒤편. 누군가 급하지 않게 자리를 비웠다.", Vector2(64, 110), 20, Color("cdb9ad"))
	for index: int in range(3):
		var door := ColorRect.new()
		door.position = Vector2(165 + index * 300, 205)
		door.size = Vector2(220, 300)
		door.color = Color("514454")
		background.add_child(door)
		_doors.append(door)
		var slit := ColorRect.new()
		slit.position = door.position + Vector2(45, 55)
		slit.size = Vector2(130, 12)
		slit.color = Color("211c25")
		background.add_child(slit)
		var mark := _label("?", door.position + Vector2(0, 105), 68, Color("f2cf9b"), true)
		_marks.append(mark)
		_label("%d" % (index + 1), door.position + Vector2(0, 238), 24, Color("cdb9ad"), true)
	_label("←→ 사물함 선택   Z 살펴보기/나가기   X 방송실", Vector2(64, 560), 20, Color("f6e8db"))
	_status = _label("문 안쪽에서 빗물이 위로 흐르는 소리가 멀어진다.", Vector2(64, 620), 19, Color("cdb9ad"))
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
			else:
				inspected[selected] = true
				_status.text = MESSAGES[selected]
				requested.emit(&"observation", {"id": "quiet_locker.%d" % selected, "text": MESSAGES[selected]})
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
		_doors[index].color = Color("806a78") if index == selected else Color("514454")
		_marks[index].text = "✓" if inspected[index] else "?"
	if inspected.all(func(value: bool) -> bool: return value):
		_status.text = "세 자리 모두 아직 따뜻하다. Z로 신호 기록실에 돌아간다."

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 80)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered: label.size.x = 220; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
