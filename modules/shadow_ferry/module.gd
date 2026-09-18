extends GameModule

const ACTIONS: Array[StringName] = [&"shadow_ferry_left", &"shadow_ferry_right", &"shadow_ferry_up", &"shadow_ferry_down", &"shadow_ferry_confirm", &"shadow_ferry_cancel"]

var dock: int = 1
var crossings: int = 0
var _held: Dictionary = {}
var _request_sent: bool = false
var _boat: Node3D
var _status: Label
var _world: Node3D

func _ready() -> void:
	_world = Node3D.new()
	_world.name = "World"
	add_child(_world)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 7.5, 11)
	_world.add_child(camera)
	camera.look_at(Vector3(0, 0.5, 0))
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("101925")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("8ba8bd")
	environment.ambient_light_energy = 0.55
	world_environment.environment = environment
	_world.add_child(world_environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-52, -28, 0)
	light.shadow_enabled = true
	_world.add_child(light)
	_box("Water", Vector3(0, -0.6, 0), Vector3(16, 0.25, 8), Color("18364a"), true)
	for index: int in range(3):
		var x: float = float(index - 1) * 4.0
		_box("Dock%d" % index, Vector3(x, 0, -1.5), Vector3(2.7, 0.35, 4.5), Color("594a3a"), false)
		_box("Lantern%d" % index, Vector3(x, 1.2, -2.2), Vector3(0.35, 2.4, 0.35), Color("f4c675"), true)
		_box("Shadow%d" % index, Vector3(x, -0.35, 1.1), Vector3([0.8, 2.3, 1.5][index], 0.08, 1.3), Color("080b12"), false)
		_sign(["짧은 그림자", "긴 그림자", "중간 그림자"][index], Vector3(x, 2.7, -2.2))
	_boat = Node3D.new()
	_boat.name = "Boat"
	_world.add_child(_boat)
	_box("Hull", Vector3.ZERO, Vector3(2.2, 0.5, 1.3), Color("d36b55"), true, _boat)
	var hud := ColorRect.new()
	hud.color = Color("0a111bd9")
	hud.position = Vector2(24, 24)
	hud.size = Vector2(1104, 126)
	add_child(hud)
	_label("그림자 나룻배", Vector2(44, 42), 30, Color("ffe1a3"))
	_label("밤 사공은 가장 긴 그림자가 물에 닿은 곳만 건넌다.", Vector2(44, 84), 20, Color("bfd5e4"))
	_status = _label("←→ 선착장 선택   Z 건너기   X 시계방", Vector2(44, 116), 18, Color("86a7bb"))
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
			if index == 0: execute_command(&"move", {"step": -1})
			elif index == 1: execute_command(&"move", {"step": 1})
			elif index == 4: execute_command(&"cross")
			elif index == 5: execute_command(&"back")

func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	if not _can_input(): return false
	match command:
		&"reset": load_state({})
		&"move":
			var step: Variant = payload.get("step")
			if step != -1 and step != 1: return false
			dock = clampi(dock + int(step), 0, 2)
		&"cross":
			crossings = mini(crossings + 1, 9999)
			if dock == 1:
				requested.emit(&"observation", {"id": "shadow_ferry.longest", "text": "가장 긴 그림자가 닿은 가운데 선착장에서 밤 사공이 배를 띄웠다."})
				_request_sent = true
				requested.emit(&"portal", {"exit": "forward"})
			else:
				_status.text = "사공이 그림자 끝을 재고 고개를 젓는다."
		&"back":
			_request_sent = true
			requested.emit(&"portal", {"exit": "back"})
		_:
			return false
	_refresh()
	return true

func save_state() -> Dictionary:
	return {"dock": dock, "crossings": crossings}

func load_state(state: Dictionary) -> void:
	dock = _integer(state.get("dock"), 1, 0, 2)
	crossings = _integer(state.get("crossings"), 0, 0, 9999)
	_request_sent = false
	_held.clear()
	_refresh()

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return {"dock": _integer(data.get("dock"), 1, 0, 2), "crossings": _integer(data.get("crossings"), 0, 0, 9999)}

func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not value is int and not value is float or not is_finite(float(value)): return fallback
	return clampi(int(value), minimum, maximum)

func _can_input() -> bool:
	return context != null and context.input_enabled and not _request_sent

func _refresh() -> void:
	if _boat == null: return
	_boat.position = Vector3(float(dock - 1) * 4.0, 0.35, 1.4)
	if _status != null and not _status.text.begins_with("사공이"):
		_status.text = "선착장 %d · 건너기 시도 %d   ←→ 선택   Z 건너기   X 시계방" % [dock + 1, crossings]

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
	label.font_size = 32
	label.pixel_size = 0.008
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	_world.add_child(label)
	label.position = point

func _label(words: String, at: Vector2, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.position = at
	label.size = Vector2(1050, 40)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	add_child(label)
	return label
