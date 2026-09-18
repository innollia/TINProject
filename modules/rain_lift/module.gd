extends GameModule

const ACTIONS: Array[StringName] = [&"rain_lift_left", &"rain_lift_right", &"rain_lift_up", &"rain_lift_down", &"rain_lift_confirm", &"rain_lift_cancel"]

var floor_index: int = 0
var rides: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _platform: Node3D
var _camera: Camera3D
var _status: Label
var _world: Node3D

func _ready() -> void:
	_world = Node3D.new()
	_world.name = "World"
	add_child(_world)
	_camera = Camera3D.new()
	_camera.position = Vector3(8, 6, 9)
	_world.add_child(_camera)
	_camera.look_at(Vector3(0, 2, 0))
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("13212b")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("a7c8d4")
	environment.ambient_light_energy = 0.7
	world_environment.environment = environment
	_world.add_child(world_environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.shadow_enabled = true
	_world.add_child(light)
	for x: float in [-2.1, 2.1]:
		for z: float in [-2.1, 2.1]:
			_box("RainRail", Vector3(x, 3, z), Vector3(0.18, 6.5, 0.18), Color("6f8c98"), true)
	for index: int in range(3):
		_box("Landing%d" % index, Vector3(0, float(index) * 2.2 + 0.2, 0), Vector3(4.2, 0.18, 4.2), Color("506975"), false)
		_sign(["교환대 층", "빗소리 층", "빌린 화면 층"][index], Vector3(0, float(index) * 2.2 + 1.1, -2.1))
	_platform = Node3D.new()
	_platform.name = "Platform"
	_world.add_child(_platform)
	_box("Cabin", Vector3.ZERO, Vector3(2.6, 0.28, 2.6), Color("d49a57"), true, _platform)
	var hud := ColorRect.new()
	hud.color = Color("0d1720d9")
	hud.position = Vector2(24, 24)
	hud.size = Vector2(1104, 120)
	add_child(hud)
	_status = _label("빗물이 승강기 줄을 타고 흐른다.", Vector2(44, 45), 24, Color("d6f2ff"))
	_label("↑↓ 층 이동   Z 위쪽 문   X 아래쪽 문", Vector2(44, 95), 19, Color("91b9c7"))
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
			if index == 2: execute_command(&"move", {"direction": "up"})
			elif index == 3: execute_command(&"move", {"direction": "down"})
			elif index == 4: execute_command(&"confirm")
			elif index == 5: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"move":
			var before: int = floor_index
			var direction: Variant = payload.get("direction")
			if direction == "up": floor_index = mini(2, floor_index + 1)
			elif direction == "down": floor_index = maxi(0, floor_index - 1)
			else: return false
			if floor_index != before: rides = mini(rides + 1, 9999)
		&"confirm":
			if floor_index != 2:
				_status.text = "위쪽 문은 가장 높은 층에서만 열린다."
			else:
				requested.emit(&"observation", {"id": "rain_lift.top", "text": "빗물 승강장의 가장 높은 층에서 낯선 타이틀 화면으로 이어지는 문을 찾았다."})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
		&"back":
			if floor_index != 0: return false
			_request_sent = true
			requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"floor": floor_index, "rides": rides}

func load_state(state: Dictionary) -> void:
	floor_index = _integer(state.get("floor"), 0, 0, 2)
	rides = _integer(state.get("rides"), 0, 0, 9999)
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return {"floor": _integer(data.get("floor"), 0, 0, 2), "rides": _integer(data.get("rides"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _platform == null: return
	_platform.position.y = float(floor_index) * 2.2 + 0.4
	_status.text = "현재 %d층 · 이동 %d회" % [floor_index + 1, rides]

func _material(color: Color, glow: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if glow: material.emission_enabled = true; material.emission = color
	return material

func _box(title: String, point: Vector3, dimensions: Vector3, color: Color, glow: bool, parent: Node3D = null) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = title
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	instance.mesh = mesh
	instance.material_override = _material(color, glow)
	(parent if parent != null else _world).add_child(instance)
	instance.position = point
	return instance

func _sign(words: String, point: Vector3) -> void:
	var label := Label3D.new()
	label.text = words
	label.font_size = 36
	label.pixel_size = 0.009
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	_world.add_child(label)
	label.position = point

func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1000, 50)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	add_child(label)
	return label
