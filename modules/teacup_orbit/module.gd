extends GameModule

const ACTIONS: Array[StringName] = [&"teacup_orbit_left", &"teacup_orbit_right", &"teacup_orbit_up", &"teacup_orbit_down", &"teacup_orbit_confirm", &"teacup_orbit_cancel"]

var turns: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _status: Label
var _cup: ColorRect

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("311f2b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("찻잔 궤도", Vector2(576, 62), 44, Color("ffe2a8"), true)
	_label("차가 식기 전에 일곱 바퀴를 돌아야 한다는 규칙은 아무도 정하지 않았다.", Vector2(576, 122), 18, Color("c9a8b9"), true)
	var saucer := ColorRect.new()
	saucer.position = Vector2(426, 300)
	saucer.size = Vector2(300, 18)
	saucer.color = Color("8f6274")
	background.add_child(saucer)
	_cup = ColorRect.new()
	_cup.size = Vector2(70, 55)
	_cup.color = Color("f3be72")
	background.add_child(_cup)
	_label("Z 찻잔 한 바퀴   X 처음부터", Vector2(64, 555), 20, Color("ffe2a8"))
	_status = _label("0바퀴. 차는 아직 뜨겁다.", Vector2(64, 618), 19, Color("c9a8b9"))
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
			if index == 4: execute_command(&"turn")
			elif index == 5: execute_command(&"reset")

func execute_command(command: StringName, _payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"turn":
			turns = mini(turns + 1, 7)
			if turns in [1, 4]:
				requested.emit(&"observation", {"id": "teacup_orbit.turn_%d" % turns, "text": "%d바퀴째, 찻잔은 차보다 진지하게 궤도를 지켰다." % turns})
			if turns == 7:
				_status.text = "일곱 바퀴. 차는 멀쩡했고 문만 열렸다."
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"turns": turns}

func load_state(state: Dictionary) -> void:
	turns = _integer(state.get("turns"))
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return {"turns": _integer(data.get("turns"))}

func _integer(value: Variant) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return 0
	return clampi(int(value), 0, 7)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _cup == null: return
	var angle: float = float(turns) * TAU / 7.0
	_cup.position = Vector2(541, 282) + Vector2(cos(angle) * 180, sin(angle) * 105)
	_status.text = "%d바퀴. %s" % [turns, "차는 아직 뜨겁다." if turns < 7 else "문이 열렸다."]

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
