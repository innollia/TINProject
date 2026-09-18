extends GameModule

const FREQUENCIES: Array[int] = [90, 100, 110]
const PARCELS: Array[String] = ["소금 냄새가 밴 파란 봉투", "모서리에 별이 찍힌 엽서", "마른 갈대끈으로 묶은 소포"]
const ACTIONS: Array[StringName] = [&"signal_desk_left", &"signal_desk_right", &"signal_desk_up", &"signal_desk_down", &"signal_desk_confirm", &"signal_desk_cancel"]

var frequency: int = 100
var station: int = 1
var inspections: int = 0
var deliveries: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _font: SystemFont
var _screen: Node2D
var _body: Polygon2D
var _readout: Label
var _message: Label
var _lights: Array[ColorRect] = []

func _ready() -> void:
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "Noto Sans KR", "Apple SD Gothic Neo"])
	_font.allow_system_fallback = true
	_screen = Node2D.new()
	add_child(_screen)
	_box(Vector2(0, 150), Vector2(1152, 570), Color("152d3b"))
	_label("기호 배달국", Vector2(64, 174), 36, Color("ffe7aa"))
	_label("세 개의 주파수, 세 개의 자리. 서두를 필요는 없어요.", Vector2(66, 224), 19)
	_box(Vector2(74, 294), Vector2(1004, 258), Color("315969"))
	var titles: Array[String] = ["○  왼쪽 · 90", "◇  가운데 · 100", "△  오른쪽 · 110"]
	for index: int in range(3):
		var x: float = 126.0 + index * 320.0
		_lights.append(_box(Vector2(x, 350), Vector2(258, 118), Color("437585")))
		_label(titles[index], Vector2(x + 16, 366), 23)
		_label(["접힌 틈", "다음 배달", "우편 보관함"][index], Vector2(x + 20, 412), 17)
	_readout = _label("", Vector2(90, 260), 24, Color("9fe2d5"))
	_body = Polygon2D.new()
	_body.visible = false
	_screen.add_child(_body)
	_label("↑↓ 주파수   ←→ 자리   Z 확인   X 살펴보기", Vector2(80, 566), 20)
	_label("90 + 왼쪽 → 틈  /  100 + 가운데 → 앞으로  /  110 + 오른쪽 → 보관함", Vector2(80, 600), 18, Color("ffe7aa"))
	_message = _label("원하는 기호 앞에 서서 같은 주파수를 맞춰 보세요.", Vector2(80, 641), 18)
	_refresh()

func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	_request_sent = false
	_apply_identity()
	_refresh()

func exit() -> void:
	_held.clear()
	super.exit()

func _process(_delta: float) -> void:
	if not _can_input():
		_held.clear()
		return
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
				"left": station = maxi(0, station - 1)
				"right": station = mini(2, station + 1)
				"up": frequency = mini(110, frequency + 10)
				"down": frequency = maxi(90, frequency - 10)
				_: return false
		&"tune":
			var amount: Variant = payload.get("frequency")
			if not _valid_frequency(amount):
				return false
			frequency = int(amount)
		&"inspect", &"cancel":
			if station == 2 and deliveries >= 3:
				_request_sent = true
				requested.emit(&"portal", {"exit": "side"})
			else:
				inspections = mini(inspections + 1, 9999)
				_message.text = "책상 표찰: 90은 왼쪽 틈, 100은 가운데 배달, 110은 오른쪽 보관함."
				requested.emit(&"observation", {"id": "signal_desk.route_plate", "text": "기호 배달국 표찰에 90·왼쪽·확인은 틈, 100·가운데는 앞으로, 110·오른쪽은 우편 보관함이라고 적혀 있었다."})
		&"confirm":
			if frequency != FREQUENCIES[station]:
				_message.text = "기호가 고개를 갸웃합니다. 자리의 숫자와 주파수를 맞춰 주세요."
			elif station == 2:
				var parcel_index: int = deliveries % PARCELS.size()
				deliveries = mini(deliveries + 1, 9999)
				var parcel: String = PARCELS[parcel_index]
				_message.text = ("배달 %d: %s가 도착했습니다. X를 누르면 뒤편 기호관으로 이어집니다." if deliveries >= 3 else "배달 %d: %s가 오른쪽 보관함에 도착했습니다.") % [deliveries, parcel]
				requested.emit(&"observation", {"id": "signal_desk.delivery_%d" % parcel_index, "text": "110에 맞춰 %s를 보관함에 넣었다. 오늘의 %d번째 배달이었다." % [parcel, deliveries]})
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "hidden" if station == 0 else "forward"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"frequency": frequency, "station": station, "inspections": inspections, "deliveries": deliveries}

func load_state(state: Dictionary) -> void:
	var clean: Dictionary = _normalize(state)
	frequency = int(clean["frequency"])
	station = int(clean["station"])
	inspections = int(clean["inspections"])
	deliveries = int(clean["deliveries"])
	_request_sent = false
	_held.clear()
	if _message != null:
		_message.text = "원하는 기호 앞에 서서 같은 주파수를 맞춰 보세요."
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var value: Variant = data.get("frequency", 100)
	return {"frequency": int(value) if _valid_frequency(value) else 100, "station": _integer(data.get("station"), 1, 0, 2), "inspections": _integer(data.get("inspections"), 0, 0, 9999), "deliveries": _integer(data.get("deliveries"), 0, 0, 9999)}

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

func _refresh() -> void:
	if _readout == null:
		return
	_readout.text = "주파수  %d   ·   선택한 자리  %s" % [frequency, ["왼쪽", "가운데", "오른쪽"][station]]
	_body.position = Vector2(255 + station * 320, 512)
	for index: int in range(_lights.size()):
		_lights[index].color = Color("659a8b") if index == station else Color("437585")

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

func _label(words: String, at: Vector2, font_size: int, tint: Color = Color("e3f2e9")) -> Label:
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
