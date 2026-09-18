extends GameModule

const ACTIONS: Array[StringName] = [&"borrowed_title_left", &"borrowed_title_right", &"borrowed_title_up", &"borrowed_title_down", &"borrowed_title_confirm", &"borrowed_title_cancel"]
const NAMES: Array[String] = ["새 게임", "이어하기", "엽서함", "나가기"]

var spot: int = 0
var inspections: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _body: ColorRect
var _status: Label
var _buttons: Array[ColorRect] = []

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("f0cfa8")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("우리가 빌린 오후", Vector2(576, 72), 50, Color("533d4b"), true)
	_label("다른 누군가의 저장 화면", Vector2(576, 138), 18, Color("8c6471"), true)
	for index: int in range(4):
		var button := ColorRect.new()
		button.position = Vector2(145 + index * 245, 330 + (index % 2) * 35)
		button.size = Vector2(190, 72)
		button.color = Color("c88782")
		background.add_child(button)
		_buttons.append(button)
		_label(NAMES[index], button.position + Vector2(95, 20), 22, Color("fff4df"), true)
	_body = ColorRect.new()
	_body.size = Vector2(24, 62)
	_body.color = Color("4b6573")
	background.add_child(_body)
	_label("←→ 메뉴 글자 위 걷기   Z 선택   X 살펴보기", Vector2(64, 560), 20, Color("533d4b"))
	_status = _label("메뉴 버튼 위에 작은 발자국이 남아 있다.", Vector2(64, 620), 19, Color("8c6471"))
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
			if index == 0: execute_command(&"move", {"direction": "left"})
			elif index == 1: execute_command(&"move", {"direction": "right"})
			elif index == 4: execute_command(&"confirm")
			elif index == 5: execute_command(&"inspect")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"move":
			var direction: Variant = payload.get("direction")
			if direction == "left": spot = maxi(0, spot - 1)
			elif direction == "right": spot = mini(3, spot + 1)
			else: return false
		&"inspect": _observe()
		&"confirm":
			if spot == 2:
				inspections = mini(inspections + 1, 9999)
				_status.text = "엽서 뒤에는 ○ △ ○, 그리고 '비가 그친 온실'이라고 쓰여 있었다."
				requested.emit(&"observation", {"id": "borrowed_title.postcard", "text": "빌린 오후의 엽서 뒤에서 ○ △ ○ 순서와 비가 그친 온실이라는 문구를 읽었다."})
			elif spot == 3:
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			else: _observe()
		_:
			return false
	_refresh()
	return true

func _observe() -> void:
	inspections = mini(inspections + 1, 9999)
	var words: String = "%s 버튼은 눌리지 않았지만 발판처럼 단단했다." % NAMES[spot]
	_status.text = words
	requested.emit(&"observation", {"id": "borrowed_title.menu_%d" % spot, "text": words})

func save_state() -> Dictionary:
	return {"spot": spot, "inspections": inspections}

func load_state(state: Dictionary) -> void:
	spot = _integer(state.get("spot"), 0, 0, 3)
	inspections = _integer(state.get("inspections"), 0, 0, 9999)
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return {"spot": _integer(data.get("spot"), 0, 0, 3), "inspections": _integer(data.get("inspections"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _body == null: return
	_body.position = _buttons[spot].position + Vector2(83, -67)
	for index: int in range(_buttons.size()): _buttons[index].color = Color("8c5f73") if index == spot else Color("c88782")

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
