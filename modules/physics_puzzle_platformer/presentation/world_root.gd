extends Node2D

const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

var camera: Camera2D
var focus: Vector2 = Vector2.ZERO
var shake_amount: float = 0.0
var _bounds: Rect2 = Rect2()
var _camera_y: float = Tuning.CAM_Y
var _shake_rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	camera = Camera2D.new()
	camera.name = "Camera"
	camera.zoom = Vector2(Tuning.CAM_ZOOM, Tuning.CAM_ZOOM)
	camera.position_smoothing_enabled = false
	add_child(camera)
	camera.make_current()


func setup(bounds: Rect2, camera_y: float, start_x: float, cosmetic_seed: int) -> void:
	_bounds = bounds
	_camera_y = camera_y
	_shake_rng.seed = cosmetic_seed
	shake_amount = 0.0
	focus = Vector2(_clamp_x(start_x), camera_y)
	_apply()


func follow(target_x: float, velocity_x: float, delta: float) -> void:
	var lead: float = clampf(velocity_x / Tuning.MOVE_SPEED, -1.0, 1.0) * Tuning.CAM_LOOKAHEAD
	var desired: float = focus.x
	var ahead: float = target_x + lead
	if ahead > focus.x + Tuning.CAM_DEADZONE_X:
		desired = ahead - Tuning.CAM_DEADZONE_X
	elif ahead < focus.x - Tuning.CAM_DEADZONE_X:
		desired = ahead + Tuning.CAM_DEADZONE_X
	var weight: float = 1.0 - exp(-Tuning.CAM_FOLLOW_SPEED * delta)
	focus = Vector2(_clamp_x(lerpf(focus.x, desired, weight)), _camera_y)
	shake_amount = maxf(shake_amount - Tuning.CAM_SHAKE_DECAY * shake_amount * delta - 0.01, 0.0)
	_apply()


func shake(strength: float) -> void:
	shake_amount = clampf(maxf(shake_amount, strength), 0.0, Tuning.CAM_SHAKE_MAX)


func _clamp_x(x: float) -> float:
	var half: float = Tuning.VIEW_W * 0.5
	var low: float = _bounds.position.x - Tuning.CAM_BOUNDS_PAD + half
	var high: float = _bounds.end.x + Tuning.CAM_BOUNDS_PAD - half
	if high < low:
		return (_bounds.position.x + _bounds.end.x) * 0.5
	return clampf(x, low, high)


func _apply() -> void:
	if camera == null:
		return
	var jitter := Vector2.ZERO
	if shake_amount > 0.05:
		jitter = Vector2(_shake_rng.randf_range(-1.0, 1.0), _shake_rng.randf_range(-1.0, 1.0)) * shake_amount
	camera.position = focus + jitter
