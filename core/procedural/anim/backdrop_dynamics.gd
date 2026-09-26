class_name ProceduralBackdropDynamics
extends RefCounted

# PURPOSE: physics for backdrop elements. Camera motion, wind and noise all
# become spring targets, so a background lags, overshoots and settles instead of
# being pasted at an offset every frame.
# OWNER: PVE. EXISTING SIGNATURES ARE FROZEN.
# 정본: core/procedural/DESIGN_DECISION.md §7-5
#
# §7-5. 이 클래스는 정규 형상 위의 얇은 껍데기다. 자기만의 _springs 루프를 갖지
# 않는다 — 그랬으면 "같은 규칙" 이라는 지시에 어긋나고 정규 배열이 둘이 된다.
# 배경 한 장 = 앵커마다 자유 노드 하나인 체인 + force(바람) + 노드별 가산치(카메라).
#
# The Kit keeps the art (a ProceduralCanvas or a sprite) and calls
# set_view_offset() + step(), then draws each element at
# rest_world_position + get_offset(index). Draw order and visual style stay in
# the Kit; only the motion lives here.

enum Layer { SKY, FAR, MID, NEAR, FOREGROUND }

const DEFAULT_PARALLAX: float = 0.5
const DEFAULT_STIFFNESS: float = 70.0
const DEFAULT_DAMPING_RATIO: float = 0.75
const DEFAULT_PHASE_SPEED: float = 12.0

var layer: Layer = Layer.MID
var parallax: float = DEFAULT_PARALLAX
var wind: Vector2 = Vector2.ZERO
var wind_gain: float = 1.0
var view_offset: Vector2 = Vector2.ZERO
var field: ProceduralNoiseField = null
var field_amplitude: float = 0.0

## 정규 형상. 배경 레이어 하나의 유일한 상태다.
var shape: ProceduralShape = null

var _flow: Vector2 = Vector2(DEFAULT_PHASE_SPEED, 0.0)
var _stiffness: float = DEFAULT_STIFFNESS
var _damping_ratio: float = DEFAULT_DAMPING_RATIO
var _anchors: PackedInt32Array = PackedInt32Array()
var _rest: Array[Vector2] = []


func _init(p_layer: Layer = Layer.MID) -> void:
	layer = p_layer
	shape = ProceduralShape.new(ProceduralShape.Kind.SOFT_CHAIN)
	shape.configure(_stiffness, _damping_ratio, 0.0, Vector2.ZERO)


## 앵커를 노드로 추가한다. 자유 노드라서 늦고 요동친다 — 그게 배경이다.
func add_anchor(rest_world_position: Vector2) -> int:
	var index: int = _rest.size()
	if shape == null:
		shape = ProceduralShape.new(ProceduralShape.Kind.SOFT_CHAIN)
	_rest.append(rest_world_position)
	_anchors.append(shape.add_free_anchor(rest_world_position))
	return index


## 앵커를 한꺼번에 붙일 때 쓴다. add_anchor 를 여러 번 부르기 전에 한 번만.
func set_anchor_capacity(capacity: int) -> bool:
	if shape == null:
		shape = ProceduralShape.new(ProceduralShape.Kind.SOFT_CHAIN)
	return shape.set_anchor_capacity(capacity)


func get_anchor_count() -> int:
	return _rest.size()


func get_rest_position(index: int) -> Vector2:
	if index < 0 or index >= _rest.size():
		return Vector2.ZERO
	return _rest[index]


## 정규 형상의 현재 좌표 − 정지 좌표. 화면이 실제로 그릴 이동량이다.
func get_offset(index: int) -> Vector2:
	if index < 0 or index >= _anchors.size() or shape == null:
		return Vector2.ZERO
	var node: int = _anchors[index]
	if node < 0 or node >= shape.node_count():
		return Vector2.ZERO
	return shape.get_points()[node] - shape.get_rest()[node]


func configure(p_parallax: float, p_field_amplitude: float, stiffness: float, damping_ratio: float) -> void:
	parallax = p_parallax
	field_amplitude = p_field_amplitude
	_stiffness = maxf(stiffness, 0.0001)
	_damping_ratio = maxf(damping_ratio, 0.0)
	if shape != null:
		# force 는 0 이다. 카메라·바람은 step() 이 매 프레임 가산치로 준다.
		# 여기서도 주면 두 번 들어간다.
		shape.configure(_stiffness, _damping_ratio, 0.0, Vector2.ZERO)
		if field != null:
			shape.bind_drift_field(field, field_amplitude)


## Binds a noise field and how fast it scrolls, in pixel units per second.
func attach_field(p_field: ProceduralNoiseField, phase_speed: float = DEFAULT_PHASE_SPEED) -> void:
	field = p_field
	_flow = Vector2(phase_speed, phase_speed * 0.35)
	if shape != null:
		shape.bind_drift_field(p_field, field_amplitude)


## Camera or viewport motion of this layer, in world units.
func set_view_offset(offset: Vector2) -> void:
	view_offset = offset


## Persistent air movement, in world units per second.
func set_wind(p_wind: Vector2, gain: float = 1.0) -> void:
	wind = p_wind
	wind_gain = gain


## One shot gust across every anchor.
func pulse(strength: float) -> void:
	if shape == null:
		return
	for index: int in _anchors.size():
		shape.kick_node(_anchors[index], Vector2(strength, -absf(strength) * 0.25))


func step(delta: float) -> void:
	if shape == null or delta <= 0.0 or _anchors.is_empty():
		return
	if field != null:
		field.advance(delta, _flow)
	# 카메라 × 패럴랙스 + 바람 = 레이어 전체에 같은 힘. 노이즈 표류는 정규 형상이
	# grid 용으로 이미 처리한다. 여기서는 앵커마다 다른 가산치를 준다.
	var shared: Vector2 = view_offset * parallax + wind * wind_gain
	for index: int in _anchors.size():
		shape.set_target_bias(_anchors[index], shared)
	shape.step(delta)


func reset() -> void:
	if shape != null:
		shape.reset()


## §6.3. 배경도 정규 형상이다. 복사본이 아니라 그 자체.
func to_shape() -> ProceduralShape:
	return shape


## 앵커 인덱스 → 정규 형상 노드 인덱스.
func get_node_index(anchor_index: int) -> int:
	if anchor_index < 0 or anchor_index >= _anchors.size():
		return -1
	return _anchors[anchor_index]
