extends GameModule

const ACTIONS: Array[StringName] = [&"paper_lighthouse_left", &"paper_lighthouse_right", &"paper_lighthouse_up", &"paper_lighthouse_down", &"paper_lighthouse_confirm", &"paper_lighthouse_cancel"]
const LIGHTHOUSE_NAMES: Array[String] = ["왼쪽 등대", "가운데 등대", "오른쪽 등대"]

var selected: int = 0
var attempts: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _lighthouses: Array[ColorRect] = []
var _status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("25202e")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_label("종이등대", Vector2(62, 44), 42, Color("fff0ce"))
	_label("세 빛 중 하나만 자기 그림자를 비춘다. 빛보다 그림자를 먼저 보세요.", Vector2(64, 106), 20, Color("d8c8d5"))
	var horizon := ColorRect.new()
	horizon.color = Color("584456")
	horizon.position = Vector2(72, 438)
	horizon.size = Vector2(1008, 3)
	background.add_child(horizon)
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(85 + index * 345, 178)
		card.size = Vector2(300, 245)
		card.color = Color("3b3048")
		background.add_child(card)
		_lighthouses.append(card)
		_label(LIGHTHOUSE_NAMES[index], card.position + Vector2(0, 18), 21, Color("fff0ce"), true)
		var tower := ColorRect.new()
		tower.color = Color("ead9bb")
		tower.position = card.position + Vector2(133, 86)
		tower.size = Vector2(34, 112)
		background.add_child(tower)
		var lamp := ColorRect.new()
		lamp.color = Color("ffd36e")
		lamp.position = card.position + Vector2(124, 70)
		lamp.size = Vector2(52, 22)
		background.add_child(lamp)
		var beam := ColorRect.new()
		beam.color = Color("ffd36e80")
		beam.position = card.position + Vector2(174, 78)
		beam.size = Vector2(105, 16)
		background.add_child(beam)
		var shadow := ColorRect.new()
		shadow.color = Color("171522")
		shadow.position = card.position + Vector2(60, 203)
		shadow.size = Vector2(92, 13)
		background.add_child(shadow)
		if index == 0:
			var own_light := ColorRect.new()
			own_light.color = Color("ffe7a060")
			own_light.position = card.position + Vector2(65, 198)
			own_light.size = Vector2(84, 23)
			background.add_child(own_light)
		elif index == 1:
			beam.position = card.position + Vector2(22, 78)
		elif index == 2:
			var detached_shadow := ColorRect.new()
			detached_shadow.color = Color("171522")
			detached_shadow.position = card.position + Vector2(204, 203)
			detached_shadow.size = Vector2(55, 13)
			background.add_child(detached_shadow)
	_label("←→ 등대 선택   Z 빛 확인   X 수족관", Vector2(64, 538), 20, Color("fff0ce"))
	_status = _label("종이 바닥의 그림자는 어느 등대 아래에 머물까?", Vector2(64, 604), 19, Color("d8c8d5"))
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
			if index == 0: execute_command(&"select", {"step": -1})
			elif index == 1: execute_command(&"select", {"step": 1})
			elif index == 4: execute_command(&"confirm")
			elif index == 5: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset": load_state({})
		&"select":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1:
				return false
			selected = posmod(selected + int(step), 3)
		&"confirm":
			attempts = mini(attempts + 1, 9999)
			if selected == 0:
				_status.text = "왼쪽 등대의 빛이 자기 그림자에 닿았다."
				requested.emit(&"observation", {"id": "paper_lighthouse.self_light", "text": "왼쪽 등대만 자기 그림자를 비추고 있었다. 종이 바닥이 잠깐 따뜻해졌다."})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			else:
				_status.text = "빛은 바다를 향했지만 자기 그림자는 어두운 채였다."
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
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null:
		return
	for index: int in range(3):
		_lighthouses[index].color = Color("66516f") if index == selected else Color("3b3048")
	if not _status.text.begins_with("왼쪽 등대") and not _status.text.begins_with("빛은"):
		_status.text = "선택: %s · 확인 %d회" % [LIGHTHOUSE_NAMES[selected], attempts]

func _label(words: String, at: Vector2, font_size: int, tint: Color, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	if centered:
		label.size.x = 300
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
