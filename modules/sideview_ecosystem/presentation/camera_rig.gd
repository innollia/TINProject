class_name EcoCameraRig
extends Node2D

## §5.1, §9.8, §4.3-5. 카메라. 줌은 룸 로드 시 1회 계산하고 그 룸 안에서 고정.
## q 를 읽는 코드 0건. FOLLOW_CLAMP 0.5 module.

const DEADZONE: Vector2 = Vector2(120.0, 70.0)
const FOLLOW_STIFFNESS: float = 90.0
const FOLLOW_CLAMP_MODULES: float = 0.5
const SNAP_QUANTUM: float = 0.05

var camera: Camera2D
var _target_zoom: float = 1.0
var _module_px: float = 1.0
var _room_bounds: Rect2 = Rect2()
var _deadzone_center: Vector2 = Vector2.ZERO


func _ready() -> void:
	camera = Camera2D.new()
	camera.position_smoothing_enabled = false
	add_child(camera)


func enter_room(target_body_px: float, room_w_px: float, room_h_px: float) -> void:
	_module_px = EcoProceduralBridge.module_px(target_body_px)
	_target_zoom = EcoProceduralBridge.cam_zoom(target_body_px)
	camera.zoom = Vector2(_target_zoom, _target_zoom)
	_room_bounds = Rect2(0.0, 0.0, room_w_px, room_h_px)
	_deadzone_center = camera.global_position


func follow(target_position: Vector2, delta: float) -> void:
	var to_target: Vector2 = target_position - _deadzone_center
	var clamp_px: float = FOLLOW_CLAMP_MODULES * _module_px
	var half: Vector2 = DEADZONE * 0.5
	var correction: Vector2 = Vector2.ZERO
	if absf(to_target.x) > half.x:
		correction.x = to_target.x - sign(to_target.x) * half.x
	if absf(to_target.y) > half.y:
		correction.y = to_target.y - sign(to_target.y) * half.y
	correction = correction.limit_length(clamp_px * 4.0)
	_deadzone_center += correction
	if _room_bounds.size.x > 0.0:
		var view_half: Vector2 = Vector2(640.0, 360.0) / maxf(_target_zoom, 0.0001)
		_deadzone_center.x = clampf(_deadzone_center.x, _room_bounds.position.x + view_half.x, _room_bounds.end.x - view_half.x) if _room_bounds.size.x > view_half.x * 2.0 else _room_bounds.get_center().x
		_deadzone_center.y = clampf(_deadzone_center.y, _room_bounds.position.y + view_half.y, _room_bounds.end.y - view_half.y) if _room_bounds.size.y > view_half.y * 2.0 else _room_bounds.get_center().y
	var snapped: Vector2 = (_deadzone_center / SNAP_QUANTUM).round() * SNAP_QUANTUM
	camera.global_position = snapped


func view_offset() -> Vector2:
	return camera.global_position
