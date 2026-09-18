extends GameModule

const ACTIONS: Array[StringName] = [&"afterimage_aquarium_left", &"afterimage_aquarium_right", &"afterimage_aquarium_up", &"afterimage_aquarium_down", &"afterimage_aquarium_confirm", &"afterimage_aquarium_cancel"]

var selected: int = 0
var attempts: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _tanks: Array[ColorRect] = []
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("102938")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("잔상 수족관", Vector2(62, 48), 42, Color("e4faff"))
	_label("한 수조에서만 물고기와 뒤늦은 그림자가 서로 반대로 헤엄친다.", Vector2(64, 108), 20, Color("a9d6df"))
	for index: int in range(3):
		var tank := ColorRect.new()
		tank.position = Vector2(95 + index * 350, 220)
		tank.size = Vector2(310, 250)
		tank.color = Color("19516a")
		background.add_child(tank)
		_tanks.append(tank)
		_label("▶", tank.position + Vector2(65, 70), 55, Color("9cecff"))
		_label("◀" if index == 1 else "▶", tank.position + Vector2(180, 120), 45, Color("628fa8"))
		_label(["같은 물결", "엇갈린 물결", "같은 물결"][index], tank.position + Vector2(0, 195), 18, Color("c0e4ea"), true)
	_label("←→ 수조 선택   Z 관찰 확인   X 진료소", Vector2(64, 548), 20, Color("e4faff"))
	_status = _label("잔상이 물고기보다 반 박자 늦게 움직인다.", Vector2(64, 612), 19, Color("a9d6df"))
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
			attempts = mini(attempts + 1, 9999)
			if selected == 1:
				requested.emit(&"observation", {"id": "afterimage_aquarium.opposite", "text": "가운데 수조의 물고기와 잔상은 서로 반대 방향으로 헤엄쳤다."})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			else:
				_status.text = "물고기와 잔상이 같은 쪽 유리에 나란히 닿았다."
		&"back":
			_request_sent = true
			requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"selected": selected, "attempts": attempts}

func load_state(state: Dictionary) -> void:
	selected = _integer(state.get("selected"), 0, 0, 2)
	attempts = _integer(state.get("attempts"), 0, 0, 9999)
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return {"selected": _integer(data.get("selected"), 0, 0, 2), "attempts": _integer(data.get("attempts"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null: return
	for index: int in range(3): _tanks[index].color = Color("247a91") if index == selected else Color("19516a")
	if not _status.text.begins_with("물고기와"):
		_status.text = "선택 수조 %d · 확인 %d회" % [selected + 1, attempts]

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 70)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered: label.size.x = 310; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
