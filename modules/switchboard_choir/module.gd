extends GameModule

const ACTIONS: Array[StringName] = [&"switchboard_choir_left", &"switchboard_choir_right", &"switchboard_choir_up", &"switchboard_choir_down", &"switchboard_choir_confirm", &"switchboard_choir_cancel"]
const SOLUTION: Array[String] = ["down", "left", "up"]

var entered: Array[String] = []
var attempts: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _status: Label
var _lamps: Array[ColorRect] = []

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("132a30")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("합창 교환대", Vector2(64, 58), 42, Color("b9f3e7"))
	_label("세 음을 차례로 연결하면 닫힌 회선이 노래한다.", Vector2(66, 116), 20, Color("83b8b2"))
	for index: int in range(3):
		var lamp := ColorRect.new()
		lamp.position = Vector2(305 + index * 190, 250)
		lamp.size = Vector2(150, 150)
		lamp.color = Color("25474d")
		background.add_child(lamp)
		_lamps.append(lamp)
	_label("방향키로 세 음 입력   Z 연결   X 지우기", Vector2(64, 552), 20, Color("b9f3e7"))
	_status = _label("아직 아무 음도 연결하지 않았다.", Vector2(64, 616), 19, Color("83b8b2"))
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
			if index < 4: execute_command(&"symbol", {"value": ["left", "right", "up", "down"][index]})
			elif index == 4: execute_command(&"confirm")
			else: execute_command(&"clear")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"symbol":
			var value: Variant = payload.get("value")
			if not value is String or value not in ["left", "right", "up", "down"]: return false
			if entered.size() == 3: entered.clear()
			entered.append(value)
		&"clear": entered.clear()
		&"confirm":
			attempts = mini(attempts + 1, 9999)
			if entered == SOLUTION:
				_status.text = "낮은 종, 접힌 거울, 마른 깃발이 한 회선으로 이어졌다."
				requested.emit(&"observation", {"id": "switchboard_choir.open", "text": _status.text})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			else:
				entered.clear()
				_status.text = "회선이 짧게 울리고 다시 잠잠해졌다."
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"entered": entered.duplicate(), "attempts": attempts}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	entered.assign(clean["entered"])
	attempts = int(clean["attempts"])
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_entered: Array[String] = []
	if data.get("entered") is Array and data["entered"].size() <= 3:
		for value: Variant in data["entered"]:
			if value is String and value in ["left", "right", "up", "down"]: clean_entered.append(value)
			else: clean_entered.clear(); break
	var value: Variant = data.get("attempts")
	var clean_attempts: int = clampi(int(value), 0, 9999) if value is int or value is float else 0
	return {"entered": clean_entered, "attempts": clean_attempts}

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(_lamps.size()):
		_lamps[index].color = Color("71c6b5") if index < entered.size() else Color("25474d")
	_status.text = "입력: %s" % [" · ".join(entered)] if not entered.is_empty() else _status.text

func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1020, 70)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	add_child(label)
	return label
