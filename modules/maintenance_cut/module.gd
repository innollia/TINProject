extends GameModule

const WALK_SPEED: float = 3.2
const VALVE: Vector2 = Vector2(-1.2, 0.0)

@onready var _world: Node3D = $World
@onready var _camera: Camera3D = $World/Camera3D
@onready var _avatar: Node3D = $World/Walker
@onready var _light: OmniLight3D = $World/InspectionLight
@onready var _hud: Label = $HUD/Panel/Margin/Rows/Status
@onready var _hint: Label = $HUD/Bottom/Margin/Hint

var _position: Vector2 = Vector2(0.0, 4.3)
var _yaw: float = 0.0
var _light_on: bool = false
var _portal_pending: bool = false
var _confirm_held: bool = false
var _corridor_observed: bool = false
var _stride: float = 0.0
var _message: String = "벽의 표면이 차가운 청록색으로 바뀌었습니다. 짧은 정비 통로를 따라 걸으세요."
var _coat: MeshInstance3D
var _hair: Node3D
var _left_leg: MeshInstance3D
var _right_leg: MeshInstance3D
var _valve_wheel: MeshInstance3D
var _strips: Array[MeshInstance3D] = []


func _ready() -> void:
	_build_passage()
	_build_walker()
	_refresh()


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_portal_pending = false
	_confirm_held = false
	_corridor_observed = false
	_apply_identity()
	_refresh()


func exit() -> void:
	_confirm_held = false
	super.exit()


func _can_act() -> bool:
	if context == null or not context.input_enabled or _portal_pending:
		_confirm_held = false
		return false
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_DISABLED:
		_confirm_held = false


func _process(delta: float) -> void:
	if not _can_act():
		return
	if not _corridor_observed:
		_corridor_observed = true
		requested.emit(&"observation", {"id": "maintenance_cut.corridor", "text": "차가운 청록색 유도등이 짧은 정비 통로를 따라 이어져 있었다."})
	var confirm: bool = context.is_action_pressed(&"maintenance_cut_confirm")
	var new_confirm: bool = confirm and not _confirm_held
	_confirm_held = confirm
	if context.is_action_pressed(&"maintenance_cut_cancel"):
		_yaw = wrapf(_yaw + context.get_axis(&"maintenance_cut_left", &"maintenance_cut_right") * delta * 1.5, -PI, PI)
	else:
		var motion: Vector2 = Vector2(context.get_axis(&"maintenance_cut_left", &"maintenance_cut_right"), context.get_axis(&"maintenance_cut_up", &"maintenance_cut_down"))
		if motion.length_squared() > 0.0:
			_walk(motion.normalized().rotated(-_yaw) * WALK_SPEED * minf(delta, 0.1))
		if new_confirm:
			_interact()
	_refresh()


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_act():
		return false
	var accepted: bool = false
	match command:
		&"reset":
			load_state({})
			accepted = true
		&"move":
			if not _valid_number(payload.get("x")) or not _valid_number(payload.get("z")):
				return false
			_walk(Vector2(clampf(float(payload["x"]), -1.0, 1.0), clampf(float(payload["z"]), -1.0, 1.0)).limit_length(1.0))
			accepted = true
		&"look":
			if not _valid_number(payload.get("yaw")):
				return false
			_yaw = wrapf(_yaw + clampf(float(payload["yaw"]), -PI, PI), -PI, PI)
			accepted = true
		&"interact", &"confirm":
			accepted = _interact()
		&"inspect":
			accepted = _inspect()
		&"toggle_light":
			accepted = _toggle_light()
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
		"light_on": _light_on,
	}


func load_state(state: Dictionary) -> void:
	var clean: Dictionary = _normalize(state)
	var point: Dictionary = clean["position"]
	_position = Vector2(float(point["x"]), float(point["z"]))
	_yaw = float(clean["yaw"])
	_light_on = bool(clean["light_on"])
	_portal_pending = false
	_confirm_held = false
	_message = "안쪽 문으로 계속 걸으세요. 왼쪽 점검판에서 점검등을 켜고 끌 수 있습니다."
	if is_node_ready():
		_refresh()


func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return _normalize(data)


func _normalize(data: Dictionary) -> Dictionary:
	var point: Dictionary = {}
	if data.get("position") is Dictionary:
		point = data["position"]
	return {
		"position": {"x": _number(point.get("x"), 0.0, -1.65, 1.65), "z": _number(point.get("z"), 4.3, -5.1, 5.1)},
		"yaw": _number(data.get("yaw"), 0.0, -PI, PI),
		"light_on": _boolean(data.get("light_on")),
	}


func _valid_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


func _number(value: Variant, fallback: float, minimum: float, maximum: float) -> float:
	if not _valid_number(value):
		return fallback
	return clampf(float(value), minimum, maximum)


func _boolean(value: Variant) -> bool:
	return value is bool and value == true


func _walk(motion: Vector2) -> void:
	if not _can_act():
		return
	_position.x = clampf(_position.x + motion.x, -1.65, 1.65)
	_position.y = clampf(_position.y + motion.y, -5.1, 5.1)
	_stride += motion.length() * 5.0
	if motion.length_squared() > 0.0:
		_avatar.rotation.y = atan2(-motion.x, -motion.y)
	_left_leg.rotation.x = sin(_stride) * 0.24
	_right_leg.rotation.x = -sin(_stride) * 0.24


func _interact() -> bool:
	if not _can_act():
		return false
	if _position.y <= -4.4:
		return _request_portal("forward")
	if _position.y >= 4.6:
		return _request_portal("back")
	if _position.distance_to(VALVE) <= 1.7:
		return _toggle_light()
	_message = "중앙 왼쪽 점검판 가까이에서 Z. 문 가까이에서는 Z로 이동합니다."
	return false


func _inspect() -> bool:
	if not _can_act() or _position.distance_to(VALVE) > 1.7:
		return false
	_message = "점검판: 안쪽 문은 지름길 출구입니다. Z로 점검등을 켜고 끄세요."
	return true


func _toggle_light() -> bool:
	if not _can_act() or _position.distance_to(VALVE) > 1.7:
		return false
	_light_on = not _light_on
	_message = "점검등을 켰습니다. 따뜻한 빛이 통로를 밝힙니다." if _light_on else "점검등을 껐습니다. 유도등을 따라 걸으세요."
	return true


func _request_portal(destination: String) -> bool:
	if not _can_act():
		return false
	if destination == "forward":
		if _position.y > -4.4:
			return false
	elif destination == "back":
		if _position.y < 4.6:
			return false
	else:
		return false
	_portal_pending = true
	requested.emit(&"portal", {"exit": destination})
	return true


func _refresh() -> void:
	_avatar.position = Vector3(_position.x, 0.0, _position.y)
	var target: Vector3 = _avatar.position + Vector3(0.0, 0.8, 0.0)
	_camera.position = target + Vector3(sin(_yaw) * 8.0, 7.0, cos(_yaw) * 8.0)
	_camera.look_at(target)
	_light.visible = _light_on
	_valve_wheel.rotation.z = PI / 2.0 if _light_on else 0.0
	for strip: MeshInstance3D in _strips:
		strip.material_override = _warm_strip_material if _light_on else _cold_strip_material
	_hud.text = "점검등  %s\n%s" % ["켜짐" if _light_on else "꺼짐", _message]
	var nearby: String = "중앙 왼쪽: 점검판 / 안쪽: 지름길 출구 / 뒤쪽: 돌아가는 문"
	if _position.y <= -4.4:
		nearby = "Z 지름길 출구로 계속 걷기"
	elif _position.y >= 4.6:
		nearby = "Z 들어온 문으로 돌아가기"
	elif _position.distance_to(VALVE) <= 1.7:
		nearby = "Z 점검등 켜기 / 끄기"
	_hint.text = "방향키 걷기    Z 가까운 대상과 상호작용    X + ←→ 시점 회전\n%s" % nearby


var _warm_strip_material: StandardMaterial3D
var _cold_strip_material: StandardMaterial3D


func _material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	if glow:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 0.9
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


func _sign(text: String, point: Vector3) -> void:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font_size = 42
	label.pixel_size = 0.008
	label.outline_size = 10
	label.modulate = Color("c3f7ec")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	_world.add_child(label)
	label.position = point


func _build_passage() -> void:
	_warm_strip_material = _material(Color("ffc389"), true)
	_cold_strip_material = _material(Color("58e2d4"), true)
	for side: float in [-2.2, 2.2]:
		_box(_world, "LowerWall", Vector3(side, 0.35, 0.0), Vector3(0.3, 0.7, 12.0), Color("17404b"))
		for index: int in range(5):
			var z: float = -4.8 + float(index) * 2.4
			_box(_world, "Rib", Vector3(side, 1.5, z), Vector3(0.24, 3.0, 0.24), Color("397882"))
			var strip: MeshInstance3D = _box(_world, "GuideStrip", Vector3(side * 0.87, 0.09, z), Vector3(0.08, 0.05, 1.5), Color("58e2d4"), true)
			_strips.append(strip)
		var pipe: MeshInstance3D = MeshInstance3D.new()
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.top_radius = 0.12
		cylinder.bottom_radius = 0.12
		cylinder.height = 11.0
		pipe.mesh = cylinder
		pipe.material_override = _material(Color("56868c"))
		_world.add_child(pipe)
		pipe.position = Vector3(side, 2.3, 0.0)
		pipe.rotation_degrees.x = 90.0
	for index: int in range(11):
		_box(_world, "Grating", Vector3(0.0, 0.02, -5.0 + float(index)), Vector3(3.7, 0.04, 0.07), Color("417079"))
	for z: float in [-5.5, 5.5]:
		_box(_world, "DoorLintel", Vector3(0.0, 3.15, z), Vector3(4.6, 0.18, 0.22), Color("58e2d4"), true)
	_box(_world, "InspectionPanel", Vector3(-1.85, 1.1, 0.0), Vector3(0.35, 1.0, 1.0), Color("35535c"))
	_valve_wheel = _box(_world, "SwitchHandle", Vector3(-1.55, 1.35, 0.0), Vector3(0.12, 0.55, 0.12), Color("efb77c"), true)
	_sign("점검판\nZ 확인 / 점검등", Vector3(-1.4, 2.1, 0.0))
	_sign("지름길 출구", Vector3(0.0, 3.6, -5.5))
	_sign("돌아가는 문", Vector3(0.0, 1.0, 5.5))


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
