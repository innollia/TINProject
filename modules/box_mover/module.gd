extends GameModule

const MOVE_SPEED: float = 260.0
const START_POSITION: Vector2 = Vector2(56.0, 56.0)
const BOX_SIZE: Vector2 = Vector2(48.0, 48.0)

@onready var _bounds: ColorRect = $UI/Bounds
@onready var _box: ColorRect = $UI/Bounds/Box

var _ctx: ModuleContext = null
var _pending_position: Vector2 = Vector2.ZERO
var _has_pending: bool = false


func _ready() -> void:
	_bounds.resized.connect(_on_bounds_resized)
	_box.size = BOX_SIZE
	_box.position = START_POSITION


func enter(ctx: ModuleContext) -> void:
	super.enter(ctx)
	_ctx = ctx


func exit() -> void:
	_ctx = null
	super.exit()


func _process(delta: float) -> void:
	if _ctx == null:
		return
	if _has_pending:
		_apply_pending()
	if not _ctx.input_enabled:
		return
	var axis_x: float = _ctx.get_axis(&"box_mover_left", &"box_mover_right")
	var axis_y: float = _ctx.get_axis(&"box_mover_up", &"box_mover_down")
	var direction: Vector2 = Vector2(axis_x, axis_y)
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	if direction != Vector2.ZERO:
		_box.position += direction * MOVE_SPEED * delta
		_clamp_box()


func save_state() -> Dictionary:
	if _has_pending:
		_apply_pending()
	var saved_position: Vector2 = _pending_position if _has_pending else _box.position
	return {"x": saved_position.x, "y": saved_position.y}


func load_state(state: Dictionary) -> void:
	var x: float = _sanitize_coordinate(state.get("x", START_POSITION.x))
	var y: float = _sanitize_coordinate(state.get("y", START_POSITION.y))
	_pending_position = Vector2(x, y)
	_has_pending = true


func execute_command(command: StringName, _payload: Dictionary = {}) -> bool:
	if command == &"reset":
		_has_pending = false
		_box.position = _clamp_within(START_POSITION)
		return true
	return false


func _on_bounds_resized() -> void:
	_clamp_box()


func _apply_pending() -> void:
	if _bounds.size.x < BOX_SIZE.x or _bounds.size.y < BOX_SIZE.y:
		return
	_has_pending = false
	_box.position = _clamp_within(_pending_position)


func _clamp_box() -> void:
	_box.position = _clamp_within(_box.position)


func _clamp_within(position_value: Vector2) -> Vector2:
	var max_position: Vector2 = (_bounds.size - _box.size).max(Vector2.ZERO)
	return position_value.clamp(Vector2.ZERO, max_position)


func _sanitize_coordinate(value: Variant) -> float:
	if value is int:
		var as_int: int = value
		return float(as_int)
	if value is float:
		var as_float: float = value
		if not is_finite(as_float):
			return 0.0
		return as_float
	return 0.0
