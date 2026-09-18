extends GameModule

const ROTATE_STEP: float = PI / 2.0

@onready var _cube: MeshInstance3D = $World/Room/Cube
@onready var _rotate_button: Button = $UI/Panel/Rows/RotateButton

var _ctx: ModuleContext = null
var _rotate_held: bool = false


func _ready() -> void:
	_rotate_button.pressed.connect(_on_rotate_pressed)


func enter(ctx: ModuleContext) -> void:
	super.enter(ctx)
	_ctx = ctx


func exit() -> void:
	_ctx = null
	super.exit()


func _process(_delta: float) -> void:
	if _ctx == null:
		return
	var held: bool = _ctx.is_action_pressed(&"room_3d_rotate")
	if held and not _rotate_held:
		_trigger_rotate()
	_rotate_held = held


func save_state() -> Dictionary:
	return {"angle": wrapf(_cube.rotation.y, -PI, PI)}


func load_state(state: Dictionary) -> void:
	_cube.rotation.y = _sanitize_angle(state.get("angle", 0.0))
	_rotate_held = false


func execute_command(command: StringName, _payload: Dictionary = {}) -> bool:
	if command == &"reset":
		_cube.rotation = Vector3.ZERO
		_rotate_held = false
		return true
	return false


func _on_rotate_pressed() -> void:
	_trigger_rotate()


func _trigger_rotate() -> void:
	if _ctx == null or not _ctx.input_enabled:
		return
	_cube.rotation.y = wrapf(_cube.rotation.y + ROTATE_STEP, -PI, PI)


func _sanitize_angle(value: Variant) -> float:
	if value is int:
		var as_int: int = value
		return wrapf(float(as_int), -PI, PI)
	if value is float:
		var as_float: float = value
		if not is_finite(as_float):
			return 0.0
		return wrapf(as_float, -PI, PI)
	return 0.0
