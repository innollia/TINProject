extends GameModule

const ACTIONS: Array[StringName] = [&"wrong_weather_left", &"wrong_weather_right", &"wrong_weather_up", &"wrong_weather_down", &"wrong_weather_confirm", &"wrong_weather_cancel"]
const FORECASTS: Array[String] = ["맑음", "위로 내리는 비", "실내만 눈"]

var selected: int = 0
var reports: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _cards: Array[ColorRect] = []
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("22233d")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("틀린 일기예보", Vector2(62, 48), 42, Color("f0e9ff"))
	_label("창밖의 현상을 가장 덜 틀리게 보도하세요.", Vector2(64, 108), 21, Color("c3b9e6"))
	var ceiling := ColorRect.new()
	ceiling.color = Color("62598b")
	ceiling.position = Vector2(120, 180)
	ceiling.size = Vector2(912, 18)
	background.add_child(ceiling)
	var puddle := ColorRect.new()
	puddle.color = Color("6bbfe8")
	puddle.position = Vector2(420, 430)
	puddle.size = Vector2(310, 20)
	background.add_child(puddle)
	for index: int in range(9):
		var drop := ColorRect.new()
		drop.color = Color("8ed8ff")
		drop.position = Vector2(445 + index * 31, 380 - (index % 3) * 35)
		drop.size = Vector2(8, 22)
		background.add_child(drop)
	var arrow := _label("↑  ↑  ↑", Vector2(465, 230), 42, Color("8ed8ff"))
	arrow.size.x = 300
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(105 + index * 335, 492)
		card.size = Vector2(270, 76)
		card.color = Color("3b3d62")
		background.add_child(card)
		_cards.append(card)
		_label(FORECASTS[index], card.position + Vector2(0, 20), 23, Color("f0e9ff"), true)
	_label("←→ 예보 선택   Z 송출   X 과수원", Vector2(64, 602), 19, Color("c3b9e6"))
	_status = _label("기상 현상이 방송보다 먼저 도착했다.", Vector2(64, 650), 18, Color("9da6d8"))
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
			elif index == 4: execute_command(&"confirm")
			elif index == 5: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"select":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1: return false
			selected = posmod(selected + int(step), 3)
		&"confirm":
			reports = mini(reports + 1, 9999)
			if selected == 1:
				requested.emit(&"observation", {"id": "wrong_weather.upward_rain", "text": "웅덩이에서 천장으로 오르는 비를 그대로 보도하자 방송실 뒤편 문이 열렸다."})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			else:
				_status.text = "방송 자막이 창밖을 보고 스스로 정정됐다."
		&"back":
			_request_sent = true
			requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"selected": selected, "reports": reports}

func load_state(state: Dictionary) -> void:
	selected = _integer(state.get("selected"), 0, 0, 2)
	reports = _integer(state.get("reports"), 0, 0, 9999)
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return {"selected": _integer(data.get("selected"), 0, 0, 2), "reports": _integer(data.get("reports"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(3): _cards[index].color = Color("716ba3") if index == selected else Color("3b3d62")
	if not _status.text.begins_with("방송 자막"):
		_status.text = "선택: %s · 송출 %d회" % [FORECASTS[selected], reports]

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered: label.size.x = 270; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
