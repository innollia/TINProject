extends GameModule

const ACTIONS: Array[StringName] = [&"return_cradle_left", &"return_cradle_right", &"return_cradle_up", &"return_cradle_down", &"return_cradle_confirm", &"return_cradle_cancel"]
const SPOTS: Array[Vector2] = [Vector2(240, 431), Vector2(562, 431), Vector2(887, 431)]
const FRIEND_LINES: Array[String] = [
	"준호: 닻 옆에 앉아. 물 좀 가져올게.",
	"준호: 네 자리 그대로 비워 뒀어. 천천히 숨부터 골라.",
	"준호: 아까 얘기 계속할까, 아니면 잠깐 물소리만 들을까?",
]

var berth: int = 1
var frequency: int = 100
var inspections: int = 0
var friend_visits: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _font: SystemFont
var _screen: Node2D
var _body: Polygon2D
var _readout: Label
var _message: Label
var _pads: Array[ColorRect] = []

func _ready() -> void:
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "Noto Sans KR", "Apple SD Gothic Neo"])
	_font.allow_system_fallback = true
	_screen = Node2D.new()
	add_child(_screen)
	_box(Vector2(0, 150), Vector2(1152, 570), Color("173c49"))
	_label("물결 우체선", Vector2(64, 174), 38, Color("f5e2b6"))
	_label("귀환 정박지 · 닻 곁에서 쉬었다 가세요", Vector2(66, 226), 20)
	for row: int in range(6):
		for column: int in range(10):
			_box(Vector2(45 + column * 118 + (row % 2) * 18, 290 + row * 39), Vector2(37, 3), Color("2e626c"))
	_box(Vector2(135, 408), Vector2(860, 68), Color("776d58"))
	for index: int in range(3):
		var at: Vector2 = SPOTS[index]
		_pads.append(_box(at + Vector2(-100, -41), Vector2(200, 95), Color("9d9472")))
		_box(at + Vector2(-95, 58), Vector2(190, 8), Color("494c42"))
		_label(["왼쪽 · 접힌 수로", "정박 닻 · 준호", "오른쪽 · 출항"][index], at + Vector2(-100, 93), 21, Color("f5e2b6"))
	_box(Vector2(514, 317), Vector2(8, 56), Color("c4d7c7"))
	_box(Vector2(493, 351), Vector2(50, 8), Color("c4d7c7"))
	_box(Vector2(502, 371), Vector2(32, 8), Color("c4d7c7"))
	_build_friend(Vector2(603, 371))
	_label("준호", Vector2(600, 306), 17, Color("e3c797"))
	_body = Polygon2D.new()
	_body.visible = false
	_screen.add_child(_body)
	_readout = _label("", Vector2(65, 270), 22, Color("9fe2d5"))
	_label("←→ 부두 걷기   ↑↓ 주파수   Z 확인·대화   X 정박 안내 읽기", Vector2(64, 568), 19)
	_label("정박 안내: 오른쪽 + Z는 출항. 주파수 90 + 왼쪽 + Z는 접힌 수로.", Vector2(64, 606), 18, Color("f5e2b6"))
	_message = _label("준호: 돌아왔구나. 아까 하던 얘기, 쉬면서 마저 하자.", Vector2(64, 652), 18)
	_refresh(true)

func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	_request_sent = false
	_apply_identity()
	_refresh(true)

func exit() -> void:
	_held.clear()
	super.exit()

func _process(delta: float) -> void:
	if not _can_input():
		_held.clear()
		return
	_body.position = _body.position.move_toward(SPOTS[berth], 560.0 * maxf(delta, 0.0))
	for index: int in range(ACTIONS.size()):
		var action: StringName = ACTIONS[index]
		var pressed: bool = context.is_action_pressed(action)
		var previous: bool = bool(_held.get(action, false))
		_held[action] = pressed
		if pressed and not previous:
			if index < 4:
				execute_command(&"move", {"direction": ["left", "right", "up", "down"][index]})
			elif index == 4:
				execute_command(&"confirm")
			else:
				execute_command(&"inspect")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset":
			load_state({})
		&"move":
			var direction: Variant = payload.get("direction", "")
			if not direction is String and not direction is StringName:
				return false
			match String(direction):
				"left": berth = maxi(0, berth - 1)
				"right": berth = mini(2, berth + 1)
				"up": frequency = mini(110, frequency + 10)
				"down": frequency = maxi(90, frequency - 10)
				_: return false
		&"tune":
			var amount: Variant = payload.get("frequency")
			if not _valid_frequency(amount):
				return false
			frequency = int(amount)
		&"inspect", &"cancel":
			_observe(false)
		&"confirm":
			if berth == 2:
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			elif berth == 0 and frequency == 90:
				_request_sent = true
				requested.emit(&"portal", {"exit": "hidden"})
			elif berth == 0:
				_message.text = "수로 표찰: 주파수 90. 왼쪽 부두에서 확인하면 접힌 수문이 열립니다."
			else:
				_observe(true)
		_:
			return false
	_refresh(false)
	return true

func _observe(talk: bool) -> void:
	if not _can_input():
		return
	inspections = mini(inspections + 1, 9999)
	var observation_id: String = "return_cradle.anchor_plate"
	var words: String = "정박 안내판: 오른쪽에서 확인하면 출항. 주파수 90, 왼쪽, 확인으로 접힌 수로의 수문이 열립니다."
	if talk:
		var line_index: int = friend_visits % FRIEND_LINES.size()
		friend_visits = mini(friend_visits + 1, 9999)
		observation_id = "return_cradle.friend"
		words = FRIEND_LINES[line_index]
	_message.text = words
	requested.emit(&"observation", {"id": observation_id, "text": words})

func save_state() -> Dictionary:
	return {"berth": berth, "frequency": frequency, "inspections": inspections, "friend_visits": friend_visits}

func load_state(state: Dictionary) -> void:
	var clean: Dictionary = _normalize(state)
	berth = int(clean["berth"])
	frequency = int(clean["frequency"])
	inspections = int(clean["inspections"])
	friend_visits = int(clean["friend_visits"])
	_request_sent = false
	_held.clear()
	if _message != null:
		_message.text = "준호: 돌아왔구나. 아까 하던 얘기, 쉬면서 마저 하자."
	_refresh(true)

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var value: Variant = data.get("frequency", 100)
	return {"berth": _integer(data.get("berth"), 1, 0, 2), "frequency": int(value) if _valid_frequency(value) else 100, "inspections": _integer(data.get("inspections"), 0, 0, 9999), "friend_visits": _integer(data.get("friend_visits"), 0, 0, 9999)}

func _valid_frequency(value: Variant) -> bool:
	if not value is int and not value is float:
		return false
	return is_finite(float(value)) and float(value) in [90.0, 100.0, 110.0]

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float:
		return fallback
	if not is_finite(float(value)):
		return fallback
	return int(clampf(float(value), float(minimum), float(maximum)))

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh(snap: bool) -> void:
	if _readout == null:
		return
	_readout.text = "수로 주파수  %d   ·   %s" % [frequency, ["왼쪽 수로", "귀환 닻", "출항 부두"][berth]]
	if snap:
		_body.position = SPOTS[berth]
	for index: int in range(_pads.size()):
		_pads[index].color = Color("c3b98b") if index == berth else Color("9d9472")

func _build_friend(at: Vector2) -> void:
	_box(at + Vector2(-12, 0), Vector2(24, 37), Color("9d7856"))
	_box(at + Vector2(-10, -20), Vector2(20, 22), Color("deb894"))
	_box(at + Vector2(-10, -22), Vector2(20, 7), Color("504235"))
	_box(at + Vector2(-8, -5), Vector2(16, 7), Color("665041"))
	_box(at + Vector2(-11, 37), Vector2(8, 13), Color("606a77"))
	_box(at + Vector2(3, 37), Vector2(8, 13), Color("606a77"))

func _apply_identity() -> void:
	if _body == null or context == null:
		return
	var shape: int = _appearance_index(context.identity_view.get("shape"))
	var tint: int = _appearance_index(context.identity_view.get("color"))
	_body.visible = false
	if shape < 0 or tint < 0:
		return
	for child: Node in _body.get_children():
		_body.remove_child(child)
		child.free()
	_body.polygon = PackedVector2Array()
	var palette: Array[Color] = [Color("de8657"), Color("ddd4bf"), Color("839baf")]
	var hair: Color = palette[tint]
	var skin: Color = Color("dfb99b")
	_body_part("LeftLeg", Rect2(-10, -4, 8, 26), Color("364654"))
	_body_part("RightLeg", Rect2(2, -4, 8, 26), Color("364654"))
	_body_part("LeftShoe", Rect2(-12, 20, 11, 5), Color("202c38"))
	_body_part("RightShoe", Rect2(2, 20, 11, 5), Color("202c38"))
	_body_part("Torso", Rect2(-13, -36, 26, 34), Color("729987"))
	_body_part("LeftArm", Rect2(-19, -34, 6, 25), Color("729987"))
	_body_part("RightArm", Rect2(13, -34, 6, 25), Color("729987"))
	_body_part("LeftHand", Rect2(-19, -9, 6, 7), skin)
	_body_part("RightHand", Rect2(13, -9, 6, 7), skin)
	_body_part("Neck", Rect2(-4, -42, 8, 8), skin)
	if shape == 1:
		_body_part("BobBack", Rect2(-11, -60, 22, 24), hair)
	elif shape == 2:
		_body_part("TiedTail", Rect2(9, -53, 8, 23), hair)
		_body_part("HairTie", Rect2(8, -51, 10, 4), Color("46505a"))
	_body_part("Head", Rect2(-8, -58, 16, 17), skin)
	_body_part("HairTop", Rect2(-9, -61, 18, 7), hair)
	if shape == 0:
		_body_part("ShortSide", Rect2(-9, -55, 3, 7), hair)
	elif shape == 1:
		_body_part("BobLeft", Rect2(-11, -55, 5, 18), hair)
		_body_part("BobRight", Rect2(6, -55, 5, 18), hair)
	else:
		_body_part("SweptHair", Rect2(-9, -55, 5, 6), hair)
	_body_part("LeftEye", Rect2(-5, -50, 2, 2), Color("38404a"))
	_body_part("RightEye", Rect2(3, -50, 2, 2), Color("38404a"))
	_body.visible = true

func _appearance_index(value: Variant) -> int:
	if not value is int and not value is float:
		return -1
	if not is_finite(float(value)) or not float(value) in [0.0, 1.0, 2.0]:
		return -1
	return int(value)

func _body_part(part_name: String, bounds: Rect2, tint: Color) -> void:
	var part: Polygon2D = Polygon2D.new()
	part.name = part_name
	part.position = bounds.position
	part.polygon = PackedVector2Array([Vector2.ZERO, Vector2(bounds.size.x, 0), bounds.size, Vector2(0, bounds.size.y)])
	part.color = tint
	_body.add_child(part)

func _box(at: Vector2, dimensions: Vector2, tint: Color) -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	rect.position = at
	rect.size = dimensions
	rect.color = tint
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_screen.add_child(rect)
	return rect

func _label(words: String, at: Vector2, font_size: int, tint: Color = Color("dce8dc")) -> Label:
	var label: Label = Label.new()
	label.text = words
	label.position = at
	label.size.x = maxf(80.0, 1090.0 - at.x)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_screen.add_child(label)
	return label
