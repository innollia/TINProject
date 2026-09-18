extends GameModule

const ACTIONS: Array[StringName] = [&"numberless_clock_left", &"numberless_clock_right", &"numberless_clock_up", &"numberless_clock_down", &"numberless_clock_confirm", &"numberless_clock_cancel"]
const SOLUTION: Array[String] = ["down", "left", "up"]

var hands: Array[String] = []
var failures: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _status: Label
var _clocks: Array[ColorRect] = []

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("172238")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("숫자 없는 시계방", Vector2(64, 58), 42, Color("d5e5ff"))
	_label("세 시계는 시간이 아니라 몸을 기울일 방향을 기다린다.", Vector2(66, 116), 20, Color("91a7c8"))
	for index: int in range(3):
		var clock := ColorRect.new()
		clock.position = Vector2(235 + index * 250, 255)
		clock.size = Vector2(180, 180)
		clock.color = Color("2d4263")
		background.add_child(clock)
		_clocks.append(clock)
		_label(["○", "◇", "△"][index], clock.position + Vector2(90, 48), 54, Color("ffd07c"), true)
	_label("방향키로 세 시곗바늘 기울이기   Z 맞추기   X 지우기", Vector2(64, 552), 20, Color("d5e5ff"))
	_status = _label("시곗바늘이 모두 정오에 멈춰 있다.", Vector2(64, 616), 19, Color("91a7c8"))
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
			if index < 4: execute_command(&"hand", {"direction": ["left", "right", "up", "down"][index]})
			elif index == 4: execute_command(&"confirm")
			else: execute_command(&"clear")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"hand":
			var direction: Variant = payload.get("direction")
			if not direction is String or direction not in ["left", "right", "up", "down"]: return false
			if hands.size() == 3: hands.clear()
			hands.append(direction)
		&"clear": hands.clear()
		&"confirm":
			if hands == SOLUTION:
				_status.text = "세 기호가 오래전 전시관과 같은 방향으로 기울었다."
				requested.emit(&"observation", {"id": "numberless_clock.aligned", "text": "숫자 없는 시계의 ○·◇·△를 아래·왼쪽·위로 기울이자 숨은 문이 열렸다."})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			else:
				failures = mini(failures + 1, 9999)
				hands.clear()
				_status.text = "시계들이 서로 다른 시간을 가리키다 다시 정오로 돌아왔다."
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"hands": hands.duplicate(), "failures": failures}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	hands.assign(clean["hands"])
	failures = int(clean["failures"])
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_hands: Array[String] = []
	if data.get("hands") is Array and data["hands"].size() <= 3:
		for value: Variant in data["hands"]:
			if value is String and value in ["left", "right", "up", "down"]: clean_hands.append(value)
			else: clean_hands.clear(); break
	var value: Variant = data.get("failures")
	var clean_failures: int = clampi(int(value), 0, 9999) if value is int or value is float else 0
	return {"hands": clean_hands, "failures": clean_failures}

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(_clocks.size()):
		_clocks[index].color = Color("5579a6") if index < hands.size() else Color("2d4263")
	if not hands.is_empty(): _status.text = "기울인 방향: %s" % " · ".join(hands)

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 70)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered: label.position.x -= 500; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
