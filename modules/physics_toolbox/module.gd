extends GameModule

const ACTIONS: Array[StringName] = [&"physics_toolbox_left", &"physics_toolbox_right", &"physics_toolbox_up", &"physics_toolbox_down", &"physics_toolbox_confirm", &"physics_toolbox_cancel"]
const TOOL_NAMES: Array[String] = ["밀대", "고정자", "되튐 스프링"]
const OBJECT_NAMES: Array[String] = ["무거운 상자", "회전판", "빈 신호통"]
const OBJECT_HINTS: Array[String] = [
	"무거운 상자는 한 방향으로만 밀린다. 반대편에 빈 공간이 있다.",
	"회전판은 고정한 뒤에야 다른 물체의 힘을 받아 방향을 바꾼다.",
	"빈 신호통은 튕겨 나온 힘을 받아야 도착선까지 굴러간다."
]
const ROUTE_SOLUTIONS: Array[Array] = [[0, 1, 2], [2, 1, 0]]
const ASSIGNMENT_SOLUTIONS: Array[Array] = [[0, 1, 2], [2, 1, 0]]
const SOLVED_TEXT: Array[String] = [
	"밀대·고정자·되튐 스프링이 차례로 힘을 넘겨 신호통을 도착선까지 보냈다.",
	"멀리 있는 신호통을 먼저 밀어 틈을 만들고, 고정한 회전판을 거쳐 되튐 스프링이 마지막 물체를 보냈다."
]
const BASE_POSITIONS: Array[Vector2] = [Vector2(190, 390), Vector2(370, 390), Vector2(550, 390)]
const GOAL_X: float = 596.0
const TOOL_TRAVEL: Array[float] = [180.0, 0.0, 120.0]

var mode: int = 0
var focus: int = 0
var tool: int = 0
var activated: Array[bool] = [false, false, false]
var assignments: Array[int] = [-1, -1, -1]
var impulses: Array[float] = [0.0, 0.0, 0.0]
var positions: Array[Vector2] = [Vector2(190, 390), Vector2(370, 390), Vector2(550, 390)]
var velocities: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var contact_flags: Array[bool] = [false, false, false]
var placement_order: Array[int] = []
var uses: int = 0
var evaluations: int = 0
var mistakes: int = 0
var solved: bool = false
var goal_reached: bool = false
var evaluation_status: String = ""
var solution_route: int = -1
var _message: String = ""
var _held: Dictionary = {}
var _request_sent: bool = false
var _background: ColorRect
var _mode_label: Label
var _tool_label: Label
var _target_label: Label
var _hint_label: Label
var _status: Label
var _object_cards: Array[ColorRect] = []
var _object_marks: Array[Label] = []
var _bodies: Array[RigidBody2D] = []

func _ready() -> void:
	_background = ColorRect.new()
	_background.color = Color("17222b")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_label("물리 도구 작업대", Vector2(60, 40), 40, Color("f2dfac"))
	_label("힘을 빌려 장면을 바꾸고, 도구의 순서를 다시 시험한다", Vector2(64, 96), 20, Color("b4c8ca"))
	_mode_label = _label("작업대", Vector2(64, 132), 18, Color("e3b86e"))
	var room := ColorRect.new()
	room.color = Color("29404a")
	room.position = Vector2(60, 178)
	room.size = Vector2(610, 350)
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(room)
	_label("실험 바닥", Vector2(88, 204), 24, Color("f2dfac"))
	var floor := ColorRect.new()
	floor.color = Color("526d6b")
	floor.position = Vector2(86, 482)
	floor.size = Vector2(560, 22)
	floor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(floor)
	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(366, 493)
	var floor_shape := CollisionShape2D.new()
	var floor_rectangle := RectangleShape2D.new()
	floor_rectangle.size = Vector2(560, 22)
	floor_shape.shape = floor_rectangle
	floor_body.add_child(floor_shape)
	_background.add_child(floor_body)
	var finish := ColorRect.new()
	finish.color = Color("d6a958")
	finish.position = Vector2(596, 350)
	finish.size = Vector2(8, 132)
	finish.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(finish)
	_label("도착선", Vector2(570, 320), 15, Color("f2dfac"))
	for index: int in range(3):
		var card := ColorRect.new()
		card.position = Vector2(92, 550 + index * 0)
		card.size = Vector2(0, 0)
		card.visible = false
		_background.add_child(card)
		_object_cards.append(card)
		var mark := _label(OBJECT_NAMES[index], BASE_POSITIONS[index] + Vector2(-48, -50), 15, Color("f2dfac"))
		mark.size = Vector2(120, 28)
		_object_marks.append(mark)
	_create_physics_objects()
	var tool_panel := ColorRect.new()
	tool_panel.color = Color("332c3e")
	tool_panel.position = Vector2(700, 178)
	tool_panel.size = Vector2(390, 350)
	tool_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.add_child(tool_panel)
	_label("도구 상자", Vector2(730, 204), 24, Color("f2dfac"))
	_tool_label = _label("", Vector2(732, 250), 21, Color("e7d3ed"))
	_tool_label.size = Vector2(326, 42)
	_target_label = _label("", Vector2(732, 316), 18, Color("e7d3ed"))
	_target_label.size = Vector2(326, 34)
	_hint_label = _label("", Vector2(732, 352), 16, Color("c6b9cf"))
	_hint_label.size = Vector2(326, 82)
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label("←→ 대상   ↑↓ 도구   Z 사용/판정   X 뒤로", Vector2(732, 448), 16, Color("c6b9cf"))
	_label("세 물체의 힘 전달을 완성하세요.", Vector2(732, 482), 16, Color("e3b86e"))
	_label("←→ 대상 선택   ↑↓ 도구 선택   Z 사용/시험   X 뒤로", Vector2(64, 568), 18, Color("e3c88d"))
	_status = _label("세 물체에 맞는 도구를 실험해 보세요.", Vector2(64, 624), 18, Color("b4c8ca"))
	_status.size = Vector2(1030, 54)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_refresh()

func _create_physics_objects() -> void:
	for index: int in range(3):
		var body := RigidBody2D.new()
		body.name = "PhysicsObject%d" % index
		body.position = BASE_POSITIONS[index]
		body.mass = 1.0 + index
		body.gravity_scale = 0.0
		body.lock_rotation = true
		var shape_node := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(74, 48)
		shape_node.shape = shape
		body.add_child(shape_node)
		var polygon := Polygon2D.new()
		polygon.polygon = PackedVector2Array([Vector2(-37, -24), Vector2(37, -24), Vector2(37, 24), Vector2(-37, 24)])
		polygon.color = [Color("d57e57"), Color("7ba2a3"), Color("c39c5c")][index]
		body.add_child(polygon)
		_background.add_child(body)
		_bodies.append(body)

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
			if index == 0: execute_command(&"move", {"step": -1})
			elif index == 1: execute_command(&"move", {"step": 1})
			elif index == 2: execute_command(&"tool", {"step": -1})
			elif index == 3: execute_command(&"tool", {"step": 1})
			elif index == 4: execute_command(&"confirm")
			else: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input():
		return false
	match command:
		&"reset":
			load_state({})
		&"move":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1 or mode != 0:
				return false
			focus = posmod(focus + int(step), 3)
		&"tool":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1 or mode != 0:
				return false
			tool = posmod(tool + int(step), 3)
		&"confirm":
			if mode == 0:
				if activated.all(func(value: bool) -> bool: return value) and assignments[focus] == tool:
					_evaluate()
				else:
					_use_tool()
			else:
				_finish()
		&"back":
			if mode == 1:
				mode = 0
				focus = 0
				_message = "도구 상자로 돌아가 다른 힘을 시험할 수 있다."
			else:
				_request_sent = true
				requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func _use_tool() -> void:
	activated[focus] = true
	assignments[focus] = tool
	if not placement_order.has(focus):
		placement_order.append(focus)
	uses = mini(uses + 1, 9999)
	match tool:
		0:
			impulses[focus] = clampf(impulses[focus] + 24.0, -60.0, 60.0)
			positions[focus].x = clampf(positions[focus].x + TOOL_TRAVEL[tool], 86.0, 700.0)
			velocities[focus] = Vector2(36.0, 0.0)
			contact_flags[focus] = true
			_bodies[focus].freeze = false
			_bodies[focus].apply_central_impulse(Vector2(24, 0))
		1:
			velocities[focus] = Vector2.ZERO
			contact_flags[focus] = true
			_bodies[focus].freeze = true
		2:
			impulses[focus] = clampf(impulses[focus] - 16.0, -60.0, 60.0)
			positions[focus].x = clampf(positions[focus].x + TOOL_TRAVEL[tool], 86.0, 700.0)
			velocities[focus] = Vector2(-24.0, 0.0)
			contact_flags[focus] = true
			_bodies[focus].freeze = false
			_bodies[focus].apply_central_impulse(Vector2(-16, 0))
	_sync_bodies()
	_message = "%s에 %s를 사용했다. 다시 움직여 결과를 확인할 수 있다." % [OBJECT_NAMES[focus], TOOL_NAMES[tool]]

func _evaluate() -> void:
	evaluations = mini(evaluations + 1, 9999)
	_update_goal_state()
	if goal_reached:
		solved = true
		mode = 1
		focus = 0
		_message = "세 물체가 힘을 넘겨 도착선에 닿았다. Z로 작업을 닫자."
	else:
		mistakes = mini(mistakes + 1, 9999)
		if solution_route < 0:
			evaluation_status = "mapping_wrong"
			_message = "도구의 힘이 맞물리지 않는다. 다른 물체에 도구를 써 보고 경로를 다시 구성하자."
		else:
			evaluation_status = "goal_unreached"
			_message = "도구 배치는 맞지만 목표 영역에 닿지 않았다. 물리 상태를 되돌려 다른 과정을 시험하자."

func _finish() -> void:
	if not solved:
		return
	_request_sent = true
	requested.emit(&"observation", {"id": "physics_toolbox.route_%d.solved" % solution_route, "text": SOLVED_TEXT[solution_route]})
	requested.emit(&"portal", {"exit": "forward"})

func save_state() -> Dictionary:
	return {
		"mode": mode,
		"focus": focus,
		"tool": tool,
		"activated": activated.duplicate(),
		"assignments": assignments.duplicate(),
		"impulses": impulses.duplicate(),
		"positions": _vectors_to_data(positions),
		"velocities": _vectors_to_data(velocities),
		"contact_flags": contact_flags.duplicate(),
		"placement_order": placement_order.duplicate(),
		"uses": uses,
		"evaluations": evaluations,
		"mistakes": mistakes,
		"solved": solved,
		"goal_reached": goal_reached,
		"evaluation_status": evaluation_status,
		"solution_route": solution_route
	}

func load_state(state: Dictionary) -> void:
	var clean := _normalize(state)
	mode = int(clean["mode"])
	focus = int(clean["focus"])
	tool = int(clean["tool"])
	activated.assign(clean["activated"])
	assignments.assign(clean["assignments"])
	impulses.assign(clean["impulses"])
	positions.assign(_data_to_vectors(clean["positions"], BASE_POSITIONS))
	velocities.assign(_data_to_vectors(clean["velocities"], [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]))
	contact_flags.assign(clean["contact_flags"])
	placement_order.assign(clean["placement_order"])
	uses = int(clean["uses"])
	evaluations = int(clean["evaluations"])
	mistakes = int(clean["mistakes"])
	solved = bool(clean["solved"])
	goal_reached = bool(clean["goal_reached"])
	evaluation_status = String(clean["evaluation_status"])
	solution_route = int(clean["solution_route"])
	_message = ""
	_request_sent = false
	_held.clear()
	_sync_bodies()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)

func _normalize(data: Dictionary) -> Dictionary:
	var clean_activated: Array[bool] = [false, false, false]
	if data.get("activated") is Array and data["activated"].size() == 3:
		var candidate: Array[bool] = []
		for value: Variant in data["activated"]:
			if not value is bool:
				candidate.clear()
				break
			candidate.append(value)
		if candidate.size() == 3: clean_activated = candidate
	var clean_assignments: Array[int] = _normalize_ints(data.get("assignments"), -1, 2)
	var clean_impulses: Array[float] = _normalize_floats(data.get("impulses"))
	var clean_positions: Array[Vector2] = _normalize_vectors(data.get("positions"), BASE_POSITIONS)
	var clean_velocities: Array[Vector2] = _normalize_vectors(data.get("velocities"), [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
	var clean_contacts: Array[bool] = _normalize_bools(data.get("contact_flags"))
	var clean_order: Array[int] = _normalize_order(data.get("placement_order"))
	var clean_solved: bool = data.get("solved") if data.get("solved") is bool else false
	var clean_route: int = _integer(data.get("solution_route"), -1, -1, 1)
	return {
		"mode": _integer(data.get("mode"), 0, 0, 1),
		"focus": _integer(data.get("focus"), 0, 0, 2),
		"tool": _integer(data.get("tool"), 0, 0, 2),
		"activated": clean_activated,
		"assignments": clean_assignments,
		"impulses": clean_impulses,
		"positions": _vectors_to_data(clean_positions),
		"velocities": _vectors_to_data(clean_velocities),
		"contact_flags": clean_contacts,
		"placement_order": clean_order,
		"uses": _integer(data.get("uses"), 0, 0, 9999),
		"evaluations": _integer(data.get("evaluations"), 0, 0, 9999),
		"mistakes": _integer(data.get("mistakes"), 0, 0, 9999),
		"solved": clean_solved,
		"goal_reached": data.get("goal_reached") if data.get("goal_reached") is bool else false,
		"evaluation_status": data.get("evaluation_status") if data.get("evaluation_status") is String else "",
		"solution_route": clean_route
	}

func _normalize_bools(value: Variant) -> Array[bool]:
	var values: Array[bool] = [false, false, false]
	if not value is Array or value.size() != 3:
		return values
	var candidate: Array[bool] = []
	for item: Variant in value:
		if not item is bool:
			return values
		candidate.append(item)
	return candidate

func _normalize_order(value: Variant) -> Array[int]:
	var order: Array[int] = []
	if not value is Array:
		return order
	for item: Variant in value:
		if not item is int and not item is float or not is_finite(float(item)):
			return []
		var index := clampi(int(item), 0, 2)
		if not order.has(index):
			order.append(index)
	return order

func _normalize_vectors(value: Variant, fallback: Array[Vector2]) -> Array[Vector2]:
	var values: Array[Vector2] = fallback.duplicate()
	if not value is Array or value.size() != 3:
		return values
	var candidate: Array[Vector2] = []
	for item: Variant in value:
		if not item is Dictionary:
			return values
		var x: Variant = item.get("x")
		var y: Variant = item.get("y")
		if (not x is int and not x is float) or (not y is int and not y is float) or not is_finite(float(x)) or not is_finite(float(y)):
			return values
		candidate.append(Vector2(float(x), float(y)))
	return candidate

func _data_to_vectors(value: Variant, fallback: Array[Vector2]) -> Array[Vector2]:
	return _normalize_vectors(value, fallback)

func _vectors_to_data(values: Array[Vector2]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Vector2 in values:
		result.append({"x": value.x, "y": value.y})
	return result

func _normalize_ints(value: Variant, minimum: int, maximum: int) -> Array[int]:
	var values: Array[int] = [minimum, minimum, minimum]
	if not value is Array or value.size() != 3:
		return values
	var candidate: Array[int] = []
	for item: Variant in value:
		if not item is int and not item is float or not is_finite(float(item)):
			return values
		candidate.append(clampi(int(item), minimum, maximum))
	return candidate if candidate.size() == 3 else values

func _normalize_floats(value: Variant) -> Array[float]:
	var values: Array[float] = [0.0, 0.0, 0.0]
	if not value is Array or value.size() != 3:
		return values
	var candidate: Array[float] = []
	for item: Variant in value:
		if not item is int and not item is float or not is_finite(float(item)):
			return values
		candidate.append(clampf(float(item), -60.0, 60.0))
	return candidate if candidate.size() == 3 else values

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)):
		return fallback
	return clampi(int(value), minimum, maximum)

func _update_goal_state() -> void:
	solution_route = -1
	for index: int in range(ROUTE_SOLUTIONS.size()):
		if placement_order == ROUTE_SOLUTIONS[index] and assignments == ASSIGNMENT_SOLUTIONS[index]:
			solution_route = index
			break
	goal_reached = solution_route >= 0 and contact_flags.all(func(value: bool) -> bool: return value) and positions.any(func(value: Vector2) -> bool: return value.x >= GOAL_X)
	if goal_reached:
		evaluation_status = "goal_reached"

func _sync_bodies() -> void:
	if _bodies.size() != 3:
		return
	for index: int in range(3):
		_bodies[index].position = positions[index]
		_bodies[index].linear_velocity = velocities[index]
		_bodies[index].freeze = assignments[index] == 1 and activated[index]

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _status == null:
		return
	_mode_label.text = "작업대" if mode == 0 else "작동 증명"
	_tool_label.text = "선택한 도구  ·  %s" % TOOL_NAMES[tool]
	_target_label.text = "대상  ·  %s" % OBJECT_NAMES[focus]
	_hint_label.text = OBJECT_HINTS[focus]
	for index: int in range(3):
		_object_marks[index].position = positions[index] + Vector2(-48, -50)
		_object_marks[index].text = "%s · %s" % [OBJECT_NAMES[index], TOOL_NAMES[assignments[index]]] if activated[index] else OBJECT_NAMES[index]
		_object_marks[index].add_theme_color_override("font_color", Color("f2dfac") if activated[index] else Color("b4c8ca"))
	if _message.is_empty():
		_status.text = "사용 %d회 · 판정 %d회 · 오답 %d회 · 목표 %s" % [uses, evaluations, mistakes, "도달" if goal_reached else "미도달"]
	else:
		_status.text = _message

func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 60)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label
