extends GameModule

const ACTIONS: Array[StringName] = [&"glasshouse_return_left", &"glasshouse_return_right", &"glasshouse_return_up", &"glasshouse_return_down", &"glasshouse_return_confirm", &"glasshouse_return_cancel"]
const SHORTCUT: Array[String] = ["down", "up", "down"]

var berth: int = 1
var sequence: Array[String] = []
var visits: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _status: Label
var _pads: Array[ColorRect] = []

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("173b35")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("비 그친 온실", Vector2(64, 60), 42, Color("d9f4c7"))
	_label("유리 천장에 남은 물방울이 세 방향으로 흐른다.", Vector2(66, 118), 20, Color("9bc4ac"))
	for index: int in range(3):
		var pad := ColorRect.new()
		pad.position = Vector2(130 + index * 340, 300)
		pad.size = Vector2(210, 120)
		pad.color = Color("37665b")
		background.add_child(pad)
		_pads.append(pad)
		_label(["젖은 벤치", "빗물 홈", "마른 출구"][index], pad.position + Vector2(105, 38), 21, Color("efffe4"), true)
	_label("←→ 자리 이동   중앙에서 ↑↓ 물방울 새기기   Z 확인   X 지우기", Vector2(64, 552), 20, Color("d9f4c7"))
	_status = _label("온실 안쪽은 조용하고 따뜻하다.", Vector2(64, 616), 19, Color("9bc4ac"))
	_refresh()

func enter(value: ModuleContext) -> void:
	super.enter(value)
	visits = mini(visits + 1, 9999)
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
			if index < 2: execute_command(&"move", {"direction": ["left", "right"][index]})
			elif index < 4: execute_command(&"symbol", {"value": ["up", "down"][index - 2]})
			elif index == 4: execute_command(&"confirm")
			else: execute_command(&"clear")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"move":
			var direction: Variant = payload.get("direction")
			if direction == "left": berth = maxi(0, berth - 1)
			elif direction == "right": berth = mini(2, berth + 1)
			else: return false
			sequence.clear()
		&"symbol":
			var value: Variant = payload.get("value")
			if berth != 1 or not value is String or value not in ["up", "down"]: return false
			if sequence.size() == 3: sequence.clear()
			sequence.append(value)
		&"clear": sequence.clear()
		&"confirm":
			if berth == 2:
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			elif berth == 1 and sequence == SHORTCUT:
				_status.text = "물방울이 ○ △ ○ 모양으로 겹치며 유리문 하나가 되었다."
				requested.emit(&"observation", {"id": "glasshouse_return.fold", "text": _status.text})
				_request_sent = true
				requested.emit(&"portal", {"exit": "hidden"})
			else:
				_status.text = "빗물 홈이 입력을 머금었다."
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"berth": berth, "sequence": sequence.duplicate(), "visits": visits}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	berth = int(clean["berth"])
	sequence.assign(clean["sequence"])
	visits = int(clean["visits"])
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_sequence: Array[String] = []
	if data.get("sequence") is Array and data["sequence"].size() <= 3:
		for value: Variant in data["sequence"]:
			if value is String and value in ["up", "down"]: clean_sequence.append(value)
			else: clean_sequence.clear(); break
	return {"berth": _integer(data.get("berth"), 1, 0, 2), "sequence": clean_sequence, "visits": _integer(data.get("visits"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(_pads.size()): _pads[index].color = Color("67a382") if index == berth else Color("37665b")
	if not sequence.is_empty(): _status.text = "빗물 홈: %s" % " · ".join(sequence)

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
