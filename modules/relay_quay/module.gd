extends GameModule

const WALK_SPEED: float = 3.0
const STATION_RADIUS: float = 1.65
const NOTICE: Vector2 = Vector2(-3.0, 2.0)
const PARCEL: Vector2 = Vector2(3.0, 2.0)
const RECEIVER: Vector2 = Vector2(-3.0, -2.0)
const RELAY: Vector2 = Vector2(2.5, -2.0)

@onready var _world: Node3D = $World
@onready var _camera: Camera3D = $World/Camera3D
@onready var _avatar: Node3D = $World/Walker
@onready var _gate: MeshInstance3D = $World/Gate
@onready var _hud: Label = $HUD/Panel/Margin/Rows/Status
@onready var _hint: Label = $HUD/Bottom/Margin/Hint

var _position: Vector2 = Vector2(0.0, 4.0)
var _yaw: float = 0.0
var _frequency: int = 100
var _direction: String = "right"
var _has_parcel: bool = false
var _delivered: bool = false
var _passage_open: bool = false
var _panel_active: bool = false
var _portal_pending: bool = false
var _held: Dictionary = {}
var _message: String = "작은 배달 하나. 오른쪽 선반의 부품을 왼쪽 작업대로 옮기세요."
var _coat: MeshInstance3D
var _hair: Node3D
var _carried: MeshInstance3D
var _shelf_parcel: MeshInstance3D
var _receiver_light: MeshInstance3D
var _left_leg: MeshInstance3D
var _right_leg: MeshInstance3D
var _stride: float = 0.0


func _ready() -> void:
	_build_courtyard()
	_build_walker()
	_refresh()


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_portal_pending = false
	_held.clear()
	_apply_identity()
	_refresh()


func exit() -> void:
	_panel_active = false
	_held.clear()
	super.exit()


func _process(delta: float) -> void:
	if not _can_act():
		return
	var left: bool = _pressed(&"relay_quay_left")
	var right: bool = _pressed(&"relay_quay_right")
	var up: bool = _pressed(&"relay_quay_up")
	var down: bool = _pressed(&"relay_quay_down")
	var confirm: bool = _pressed(&"relay_quay_confirm")
	var cancel: bool = context.is_action_pressed(&"relay_quay_cancel")
	if _panel_active:
		if left:
			_direction = "left"
		if right:
			_direction = "right"
		if up:
			_frequency = mini(110, _frequency + 10)
		if down:
			_frequency = maxi(90, _frequency - 10)
		if confirm:
			_confirm_relay()
		if cancel:
			_panel_active = false
	elif cancel:
		_yaw = wrapf(_yaw + context.get_axis(&"relay_quay_left", &"relay_quay_right") * delta * 1.5, -PI, PI)
	else:
		var motion: Vector2 = Vector2(context.get_axis(&"relay_quay_left", &"relay_quay_right"), context.get_axis(&"relay_quay_up", &"relay_quay_down"))
		if motion.length_squared() > 0.0:
			_walk(motion.normalized().rotated(-_yaw) * WALK_SPEED * minf(delta, 0.1))
		if confirm:
			_interact()
	_refresh()


func _can_act() -> bool:
	if context == null or not context.input_enabled or _portal_pending:
		_held.clear()
		return false
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_DISABLED:
		_held.clear()


func _pressed(action: StringName) -> bool:
	var pressed: bool = context.is_action_pressed(action)
	var previous: bool = bool(_held.get(action, false))
	_held[action] = pressed
	return pressed and not previous


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_act():
		return false
	var accepted: bool = false
	match command:
		&"reset":
			load_state({})
			accepted = true
		&"move":
			if not _valid_number(payload.get("x")) or not _valid_number(payload.get("z")) or _panel_active:
				return false
			var motion: Vector2 = Vector2(clampf(float(payload["x"]), -1.0, 1.0), clampf(float(payload["z"]), -1.0, 1.0))
			_walk(motion.limit_length(1.0))
			accepted = true
		&"look":
			if not _valid_number(payload.get("yaw")):
				return false
			_yaw = wrapf(_yaw + clampf(float(payload["yaw"]), -PI, PI), -PI, PI)
			accepted = true
		&"interact":
			accepted = _interact()
		&"read_notice":
			accepted = _read_notice()
		&"pickup":
			accepted = _pickup()
		&"deliver":
			accepted = _deliver()
		&"tune":
			if not _near(RELAY) or not _valid_number(payload.get("frequency")):
				return false
			var frequency: float = float(payload["frequency"])
			var direction: Variant = payload.get("direction")
			if frequency not in [90.0, 100.0, 110.0] or not direction is String or direction not in ["left", "right"]:
				return false
			_frequency = int(frequency)
			_direction = direction
			_panel_active = true
			accepted = true
		&"confirm":
			accepted = _confirm_relay() if _panel_active else _interact()
		&"cancel":
			_panel_active = false
			accepted = true
		&"portal":
			var destination: Variant = payload.get("exit")
			if not destination is String:
				return false
			accepted = _request_portal(destination)
	_refresh()
	return accepted


func save_state() -> Dictionary:
	return {
		"position": {"x": _position.x, "z": _position.y},
		"yaw": _yaw,
		"frequency": _frequency,
		"direction": _direction,
		"has_parcel": _has_parcel,
		"delivered": _delivered,
		"passage_open": _passage_open,
	}


func load_state(state: Dictionary) -> void:
	var clean: Dictionary = _normalize(state)
	var point: Dictionary = clean["position"]
	_position = Vector2(float(point["x"]), float(point["z"]))
	_yaw = float(clean["yaw"])
	_frequency = int(clean["frequency"])
	_direction = String(clean["direction"])
	_has_parcel = bool(clean["has_parcel"])
	_delivered = bool(clean["delivered"])
	_passage_open = bool(clean["passage_open"])
	_panel_active = false
	_portal_pending = false
	_held.clear()
	_message = "통로가 열렸습니다. 안쪽 문에서 Z로 계속 걷습니다." if _passage_open else "오른쪽 선반 → 왼쪽 작업대. 게시판에는 중계기의 규칙이 적혀 있습니다."
	if is_node_ready():
		_refresh()


func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)


func _normalize(data: Dictionary) -> Dictionary:
	var point: Dictionary = {}
	if data.get("position") is Dictionary:
		point = data["position"]
	var delivered: bool = _boolean(data.get("delivered"))
	var opened: bool = delivered and _boolean(data.get("passage_open"))
	var frequency: float = _number(data.get("frequency"), 100.0, 90.0, 110.0)
	if frequency not in [90.0, 100.0, 110.0]:
		frequency = 100.0
	var direction: String = "right"
	if data.get("direction") is String and data["direction"] == "left":
		direction = "left"
	return {
		"position": {"x": _number(point.get("x"), 0.0, -4.5, 4.5), "z": _number(point.get("z"), 4.0, -5.2 if opened else -3.9, 5.2)},
		"yaw": _number(data.get("yaw"), 0.0, -PI, PI),
		"frequency": int(frequency), "direction": direction,
		"has_parcel": _boolean(data.get("has_parcel")) and not delivered,
		"delivered": delivered, "passage_open": opened,
	}


func _valid_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


func _number(value: Variant, fallback: float, minimum: float, maximum: float) -> float:
	if not _valid_number(value):
		return fallback
	return clampf(float(value), minimum, maximum)


func _boolean(value: Variant) -> bool:
	return value is bool and value == true


func _near(point: Vector2) -> bool:
	return _position.distance_to(point) <= STATION_RADIUS


func _walk(motion: Vector2) -> void:
	if not _can_act():
		return
	_position.x = clampf(_position.x + motion.x, -4.5, 4.5)
	_position.y = clampf(_position.y + motion.y, -5.2 if _passage_open else -3.9, 5.2)
	_stride += motion.length() * 5.0
	if motion.length_squared() > 0.0:
		_avatar.rotation.y = atan2(-motion.x, -motion.y)
	_left_leg.rotation.x = sin(_stride) * 0.24
	_right_leg.rotation.x = -sin(_stride) * 0.24


func _interact() -> bool:
	if not _can_act():
		return false
	if _panel_active:
		return _confirm_relay()
	if _near(NOTICE):
		return _read_notice()
	if _near(PARCEL):
		return _pickup()
	if _near(RECEIVER):
		return _deliver()
	if _near(RELAY):
		_panel_active = true
		_message = "수치와 방향을 고른 뒤 Z로 적용하세요."
		return true
	if _position.y <= -4.3 and absf(_position.x) <= 1.6:
		return _request_portal("forward")
	if _position.y >= 4.5 and absf(_position.x) <= 1.6:
		return _request_portal("back")
	_message = "표지 가까이에서 Z. X를 누른 채 좌우로 시점을 돌릴 수 있습니다."
	return false


func _read_notice() -> bool:
	if not _can_act() or not _near(NOTICE):
		return false
	_message = "작업 지침: 90 + 왼쪽(←) + 확인(Z) = 배달 통로 개방. 먼저 부품을 작업대에 놓으세요."
	requested.emit(&"observation", {"id": "quay_relay_rule", "text": "중계 안뜰의 게시판: 90에 맞추고 왼쪽을 선택한 뒤 확인하면 배달 통로가 열린다."})
	return true


func _pickup() -> bool:
	if not _can_act() or not _near(PARCEL) or _has_parcel or _delivered:
		return false
	_has_parcel = true
	_message = "안뜰용 부품을 들었습니다. 왼쪽 안쪽 작업대로 배달하세요."
	return true


func _deliver() -> bool:
	if not _can_act() or not _near(RECEIVER) or not _has_parcel:
		return false
	_has_parcel = false
	_delivered = true
	_message = "배달 완료. 작업대에 전원이 들어왔습니다. 오른쪽 중계기를 조작하세요."
	requested.emit(&"observation", {"id": "quay_delivery", "text": "안뜰 선반의 부품을 작업대에 배달해 중계기에 전원을 공급했다."})
	return true


func _confirm_relay() -> bool:
	if not _can_act() or not _near(RELAY):
		return false
	if not _delivered:
		_message = "전원이 없습니다. 선반의 부품을 왼쪽 작업대에 먼저 배달하세요."
		return false
	if _frequency != 90 or _direction != "left":
		_message = "통로가 응답하지 않습니다. 90 · 왼쪽 · 확인으로 맞춰 보세요."
		return false
	if not _passage_open:
		_passage_open = true
		requested.emit(&"observation", {"id": "quay_passage_open", "text": "90 · 왼쪽 · 확인을 중계기에 적용하자 안뜰의 배달 통로가 열렸다."})
	_panel_active = false
	_message = "통로가 열렸습니다. 안쪽의 밝은 문으로 걸어가 Z를 누르세요."
	return true


func _request_portal(destination: String) -> bool:
	if not _can_act() or absf(_position.x) > 1.6:
		return false
	if destination == "forward":
		if not _passage_open or _position.y > -4.3:
			return false
	elif destination == "back":
		if _position.y < 4.5:
			return false
	else:
		return false
	_portal_pending = true
	requested.emit(&"portal", {"exit": destination})
	return true


func _refresh() -> void:
	_avatar.position = Vector3(_position.x, 0.0, _position.y)
	var target: Vector3 = _avatar.position + Vector3(0.0, 0.8, 0.0)
	_camera.position = target + Vector3(sin(_yaw) * 10.5, 9.0, cos(_yaw) * 10.5)
	_camera.look_at(target)
	_gate.position.y = 4.2 if _passage_open else 1.25
	_carried.visible = _has_parcel
	_shelf_parcel.visible = not _has_parcel and not _delivered
	_receiver_light.visible = _delivered
	var delivery: String = "완료" if _delivered else ("운반 중" if _has_parcel else "선반에서 수령")
	var gate_status: String = "열림" if _passage_open else "닫힘"
	_hud.text = "부품 배달  %s     통로  %s\n%s" % [delivery, gate_status, _message]
	if _panel_active:
		_hint.text = "중계기  [ %d ]  [ %s ]\n↑↓ 90 / 100 / 110    ←→ 방향    Z 적용    X 돌아가기" % [_frequency, "← 왼쪽" if _direction == "left" else "오른쪽 →"]
	else:
		_hint.text = "방향키 걷기    Z 가까운 대상과 상호작용    X + ←→ 시점 회전\n%s" % _nearby_hint()


func _nearby_hint() -> String:
	if _near(NOTICE):
		return "Z 게시판 읽기 · 중계기 사용법"
	if _near(PARCEL):
		return "Z 부품 수령 · 왼쪽 작업대로 배달"
	if _near(RECEIVER):
		return "Z 작업대에 부품 배달"
	if _near(RELAY):
		return "Z 중계기 조작 · 수치를 고르고 확인"
	if _position.y <= -4.3 and absf(_position.x) <= 1.6:
		return "Z 열린 통로로 계속 걷기"
	if _position.y >= 4.5 and absf(_position.x) <= 1.6:
		return "Z 들어온 문으로 돌아가기"
	return "왼쪽 게시판 / 오른쪽 선반 / 안쪽 작업대와 중계기"


func _material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 0.8
	return material


func _box(parent: Node3D, title: String, point: Vector3, size: Vector3, color: Color, glow: bool = false) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = title
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = _material(color, glow)
	parent.add_child(instance)
	instance.position = point
	return instance


func _sign(text: String, point: Vector3, tint: Color = Color(1.0, 0.86, 0.62)) -> void:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font_size = 42
	label.pixel_size = 0.008
	label.outline_size = 10
	label.modulate = tint
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	_world.add_child(label)
	label.position = point


func _build_courtyard() -> void:
	var stone: Color = Color("273039")
	var brass: Color = Color("b77946")
	_box(_world, "WestWall", Vector3(-5.15, 1.1, 0.0), Vector3(0.3, 2.2, 12.0), stone)
	_box(_world, "EastWall", Vector3(5.15, 1.1, 0.0), Vector3(0.3, 2.2, 12.0), stone)
	for side: float in [-3.5, 3.5]:
		_box(_world, "NorthWall", Vector3(side, 1.25, -5.8), Vector3(3.0, 2.5, 0.3), stone)
		_box(_world, "SouthWall", Vector3(side, 1.25, 5.8), Vector3(3.0, 2.5, 0.3), stone)
	for index: int in range(9):
		_box(_world, "Paving", Vector3(0.0, 0.015, -4.8 + float(index) * 1.2), Vector3(1.6, 0.035, 0.75), Color("56616a"))
	for side: float in [-1.8, 1.8]:
		_box(_world, "DoorPillar", Vector3(side, 1.65, -5.4), Vector3(0.24, 3.3, 0.35), brass)
		_box(_world, "DoorLight", Vector3(side, 1.65, -5.18), Vector3(0.08, 2.5, 0.04), Color("ffc578"), true)
	_box(_world, "DoorLintel", Vector3(0.0, 3.25, -5.4), Vector3(3.8, 0.25, 0.35), brass)
	_box(_world, "NoticeBoard", Vector3(-3.0, 1.2, 1.6), Vector3(1.5, 1.3, 0.18), Color("382d29"))
	_box(_world, "Shelf", Vector3(3.0, 0.4, 1.6), Vector3(1.6, 0.8, 0.8), brass)
	_shelf_parcel = _box(_world, "LocalPart", Vector3(3.0, 1.0, 1.6), Vector3(0.48, 0.4, 0.4), Color("e7bd6d"), true)
	_box(_world, "Workbench", Vector3(-3.0, 0.5, -2.5), Vector3(1.8, 1.0, 0.8), Color("785441"))
	_receiver_light = _box(_world, "DeliveredPart", Vector3(-3.0, 1.12, -2.5), Vector3(0.55, 0.2, 0.5), Color("76d6d2"), true)
	_box(_world, "RelayConsole", Vector3(2.5, 0.65, -2.5), Vector3(1.3, 1.3, 0.6), Color("405e69"))
	for index: int in range(3):
		_box(_world, "FrequencyLamp", Vector3(2.08 + float(index) * 0.42, 1.4, -2.5), Vector3(0.2, 0.16, 0.3), Color("79d8dc"), true)
	_sign("작업 지침\n90 · ← · 확인", Vector3(-3.0, 2.3, 1.6))
	_sign("부품 선반", Vector3(3.0, 1.85, 1.6))
	_sign("배달 작업대", Vector3(-3.0, 2.0, -2.5))
	_sign("중계기\n90 / 100 / 110", Vector3(2.5, 2.3, -2.5), Color("a7edee"))
	_sign("안쪽 통로", Vector3(0.0, 3.8, -5.4))
	_sign("돌아가는 문", Vector3(0.0, 1.0, 5.8))


func _build_walker() -> void:
	_coat = _box(_avatar, "Coat", Vector3(0.0, 1.05, 0.0), Vector3(0.52, 0.68, 0.32), Color("303943"))
	var head: MeshInstance3D = MeshInstance3D.new()
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.17
	head_mesh.height = 0.36
	head.mesh = head_mesh
	head.material_override = _material(Color("d4b7a0"))
	_avatar.add_child(head)
	head.position = Vector3(0.0, 1.62, 0.0)
	_left_leg = _box(_avatar, "LeftLeg", Vector3(-0.15, 0.38, 0.0), Vector3(0.18, 0.76, 0.22), Color("26313b"))
	_right_leg = _box(_avatar, "RightLeg", Vector3(0.15, 0.38, 0.0), Vector3(0.18, 0.76, 0.22), Color("26313b"))
	_box(_avatar, "LeftArm", Vector3(-0.36, 1.02, 0.0), Vector3(0.16, 0.64, 0.2), Color("303943"))
	_box(_avatar, "RightArm", Vector3(0.36, 1.02, 0.0), Vector3(0.16, 0.64, 0.2), Color("303943"))
	_hair = Node3D.new()
	_hair.name = "Hair"
	_avatar.add_child(_hair)
	_carried = _box(_avatar, "CarriedLocalPart", Vector3(0.0, 0.93, -0.4), Vector3(0.46, 0.36, 0.36), Color("e7bd6d"), true)


func _apply_identity() -> void:
	var view: Dictionary = context.identity_view
	var shape: int = 0
	var color_index: int = 0
	var shape_value: Variant = view.get("shape", 0)
	var color_value: Variant = view.get("color", 0)
	if shape_value is int and shape_value >= 0 and shape_value <= 2:
		shape = int(shape_value)
	if color_value is int and color_value >= 0 and color_value <= 2:
		color_index = int(color_value)
	var palette: Array[Color] = [Color("de8657"), Color("ddd4bf"), Color("839baf")]
	var hair_color: Color = palette[color_index]
	for child: Node in _hair.get_children():
		_hair.remove_child(child)
		child.queue_free()
	_box(_hair, "Crown", Vector3(0.0, 1.76, 0.015), Vector3(0.35, 0.13, 0.34), hair_color)
	match shape:
		0:
			_box(_hair, "CropBack", Vector3(0.0, 1.67, 0.13), Vector3(0.32, 0.16, 0.1), hair_color)
		1:
			_box(_hair, "BobBack", Vector3(0.0, 1.57, 0.14), Vector3(0.4, 0.4, 0.13), hair_color)
			_box(_hair, "BobLeft", Vector3(-0.17, 1.59, 0.0), Vector3(0.1, 0.36, 0.29), hair_color)
			_box(_hair, "BobRight", Vector3(0.17, 1.59, 0.0), Vector3(0.1, 0.36, 0.29), hair_color)
		2:
			_box(_hair, "SweptBack", Vector3(0.0, 1.67, 0.13), Vector3(0.33, 0.2, 0.12), hair_color)
			_box(_hair, "HairTie", Vector3(0.0, 1.65, 0.23), Vector3(0.14, 0.12, 0.1), Color("26313b"))
			_box(_hair, "TiedTail", Vector3(0.0, 1.47, 0.29), Vector3(0.18, 0.4, 0.18), hair_color)
