extends GameModule

const ACTIONS: Array[StringName] = [&"last_echo_left", &"last_echo_right", &"last_echo_up", &"last_echo_down", &"last_echo_confirm", &"last_echo_cancel"]
const SPOTS: Array[Vector2] = [Vector2(144, 466), Vector2(350, 430), Vector2(556, 394), Vector2(762, 430), Vector2(968, 466)]
const NAMES: Array[String] = ["처음 자리", "준호와 쉬기", "도움말", "돌아가기", "바닥으로"]

var spot: int = 0
var inspections: int = 0
var friend_visits: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _font: SystemFont
var _screen: Node2D
var _body: Polygon2D
var _prompt: Label
var _message: Label
var _platforms: Array[ColorRect] = []

func _ready() -> void:
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "Noto Sans KR", "Apple SD Gothic Neo"])
	_font.allow_system_fallback = true
	_screen = Node2D.new()
	add_child(_screen)
	_box(Vector2(0, 150), Vector2(1152, 570), Color("171b35"))
	_label("별의 정원", Vector2(64, 174), 44, Color("eee1b9"))
	_label("메인 메뉴", Vector2(68, 230), 23, Color("aabbe8"))
	_label("준호: 발판은 튼튼해. 내가 옆에서 같이 걸을게.", Vector2(64, 278), 19)
	for index: int in range(18):
		_box(Vector2(490 + (index * 73) % 580, 178 + (index * 43) % 160), Vector2(3, 3), Color("c8cbe6"))
	for index: int in range(SPOTS.size()):
		var at: Vector2 = SPOTS[index]
		_platforms.append(_box(at + Vector2(-84, 26), Vector2(168, 18), Color("575c91")))
		_label(NAMES[index], at + Vector2(-76, 48), 21)
		if index < SPOTS.size() - 1:
			for step: int in range(5):
				var along: Vector2 = at.lerp(SPOTS[index + 1], float(step + 1) / 6.0)
				_box(along + Vector2(-12, 29), Vector2(24, 8), Color("373c67"))
	_box(Vector2(875, 553), Vector2(195, 35), Color("050814"))
	_label("의도해서 Z를 누를 때만 떨어짐", Vector2(780, 590), 17, Color("e9b9ae"))
	_build_friend(Vector2(381, 379))
	_label("준호", Vector2(243, 333), 17, Color("e3c797"))
	_body = Polygon2D.new()
	_body.visible = false
	_screen.add_child(_body)
	_prompt = _label("", Vector2(64, 553), 20, Color("eee1b9"))
	_label("←↑ 이전 발판   →↓ 다음 발판   Z 선택   X 살펴보기 · 점프는 필요 없어요", Vector2(64, 627), 18)
	_message = _label("발밑의 별무늬 계단이 이어져 있습니다. 바닥으로 내려가려면 끝 발판에서 Z를 누르세요.", Vector2(64, 665), 17)
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
	_body.position = _body.position.move_toward(SPOTS[spot], 600.0 * maxf(delta, 0.0))
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
				"left", "up": spot = maxi(0, spot - 1)
				"right", "down": spot = mini(4, spot + 1)
				_: return false
		&"inspect", &"cancel":
			_observe()
		&"confirm":
			match spot:
				3:
					_request_sent = true
					requested.emit(&"portal", {"exit": "back"})
				4:
					_request_sent = true
					_message.text = "발판 끝에서 발을 내디뎠습니다. 별빛이 멀어집니다."
					requested.emit(&"died", {})
				_:
					_observe()
		_:
			return false
	_refresh(false)
	return true

func _observe() -> void:
	if not _can_input():
		return
	inspections = mini(inspections + 1, 9999)
	var observation_id: String = "last_echo.menu"
	var words: String = "별의 정원의 메인 메뉴 글자 아래에 별무늬 발판과 낮은 계단이 이어져 있었다."
	match spot:
		1:
			friend_visits = mini(friend_visits + 1, 9999)
			observation_id = "last_echo.friend"
			words = "준호: 난 여기 있을게. 돌아오는 길은 봐 뒀어."
		2:
			observation_id = "last_echo.shortcut"
			words = "도움말에 '주파수 90. 왼쪽에서 확인하면 접힌 길이 열린다'라고 적혀 있었다."
		3:
			observation_id = "last_echo.back_sign"
			words = "돌아가기 발판에는 'Z를 누르면 뒤로'라고 적혀 있었다."
		4:
			observation_id = "last_echo.pit"
			words = "바닥으로 발판 아래 검은 구덩이가 보였다. 안내문에는 '여기서 Z를 눌러야만 떨어짐'이라고 적혀 있었다."
	_message.text = words
	requested.emit(&"observation", {"id": observation_id, "text": words})

func save_state() -> Dictionary:
	return {"spot": spot, "inspections": inspections, "friend_visits": friend_visits}

func load_state(state: Dictionary) -> void:
	var clean: Dictionary = _normalize(state)
	spot = int(clean["spot"])
	inspections = int(clean["inspections"])
	friend_visits = int(clean["friend_visits"])
	_request_sent = false
	_held.clear()
	if _message != null:
		_message.text = "발밑의 별무늬 계단이 이어져 있습니다. 바닥으로 내려가려면 끝 발판에서 Z를 누르세요."
	_refresh(true)

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	return {"spot": _integer(data.get("spot"), 0, 0, 4), "inspections": _integer(data.get("inspections"), 0, 0, 9999), "friend_visits": _integer(data.get("friend_visits"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float:
		return fallback
	if not is_finite(float(value)):
		return fallback
	return int(clampf(float(value), float(minimum), float(maximum)))

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh(snap: bool) -> void:
	if _prompt == null:
		return
	_prompt.text = "지금 선 곳: %s  ·  Z %s" % [NAMES[spot], ["살펴보기", "대화", "읽기", "뒤로", "의도해서 떨어지기"][spot]]
	if snap:
		_body.position = SPOTS[spot]
	for index: int in range(_platforms.size()):
		_platforms[index].color = Color("b4a77b") if index == spot else Color("575c91")

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

func _label(words: String, at: Vector2, font_size: int, tint: Color = Color("d8def5")) -> Label:
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
