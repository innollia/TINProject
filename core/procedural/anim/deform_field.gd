class_name ProceduralDeformField
extends RefCounted

# PURPOSE: per vertex deformation for wide soft surfaces. This is a thin facade
# over ProceduralShape: the field IS a soft_grid 정규 형상, not a second copy of
# one. Two sets of springs would be two truths, and §0 allows exactly one.
# OWNER: PVE. EXISTING SIGNATURES ARE FROZEN.
# 정본: core/procedural/DESIGN_DECISION.md §3.3, §7-4, §7-5
#
# The grid is width x height vertices. Rest positions come from build_grid();
# `points` is the deformed position of every vertex. A Kit draws by sampling
# points, or by using build_triangles() with an ArrayMesh. Nothing here touches
# the scene tree, so it is safe to step from _process() or a fixed tick.
#
# The public members below are kept as declared so the three Kit plans that
# already quote them keep working. They read and write through to the shape.

const DEFAULT_AMPLITUDE: float = 6.0
const DEFAULT_STIFFNESS: float = 120.0
const DEFAULT_DAMPING_RATIO: float = 0.55
const DEFAULT_FLOW: Vector2 = Vector2(7.0, 0.0)

var width: int = 2
var height: int = 2
var bounds: Rect2 = Rect2()
var amplitude: float = DEFAULT_AMPLITUDE
var wind: Vector2 = Vector2.ZERO
var wind_gain: float = 0.0
var flow: Vector2 = DEFAULT_FLOW
var noise: ProceduralNoiseField = null

## 정규 형상. 이 클래스의 유일한 상태다.
var shape: ProceduralShape = null

var _stiffness: float = DEFAULT_STIFFNESS
var _damping_ratio: float = DEFAULT_DAMPING_RATIO


func _init(p_width: int = 2, p_height: int = 2) -> void:
	build_grid(p_width, p_height, Rect2(Vector2.ZERO, Vector2(64.0, 64.0)))


func build_grid(p_width: int, p_height: int, rect: Rect2) -> void:
	var columns: int = maxi(p_width, 2)
	var rows: int = maxi(p_height, 2)
	shape = ProceduralShape.new(ProceduralShape.Kind.SOFT_GRID)
	if not shape.build_grid(columns, rows, rect):
		push_error("ProceduralDeformField.build_grid refused %dx%d." % [columns, rows])
		return
	shape.configure(_stiffness, _damping_ratio, 0.0, Vector2.ZERO)
	width = columns
	height = rows
	bounds = rect
	amplitude = DEFAULT_AMPLITUDE


## 정규 형상의 정지 좌표. 복사본이 아니라 참조다.
var rest: PackedVector2Array:
	get:
		return shape.get_rest() if shape != null else PackedVector2Array()


## 정규 형상의 현재 좌표. 화면이 읽는 바로 그 배열이다. (§0)
var points: PackedVector2Array:
	get:
		return shape.get_points() if shape != null else PackedVector2Array()


func configure(p_amplitude: float, stiffness: float, damping_ratio: float) -> void:
	amplitude = p_amplitude
	_stiffness = maxf(stiffness, 0.0001)
	_damping_ratio = maxf(damping_ratio, 0.0)
	if shape != null:
		shape.configure(_stiffness, _damping_ratio, shape.coupling, wind * wind_gain)


## §3.3. 이웃 결합. 0 이면 정점이 서로 독립이라 표면이 물리지 않는다.
## 전용 상수 없다 — 공용 스프링과 coupling 만 쓴다.
func set_coupling(coupling: float) -> void:
	if shape == null:
		return
	shape.configure(_stiffness, _damping_ratio, coupling, wind * wind_gain)


func get_coupling() -> float:
	return shape.coupling if shape != null else 0.0


func bind_noise(field: ProceduralNoiseField) -> void:
	noise = field
	# 노이즈는 표류로 들어간다. 정지에 굽지 않는다.
	if shape != null:
		shape.bind_drift_field(field, amplitude)


func set_wind(p_wind: Vector2, gain: float = 1.0) -> void:
	wind = p_wind
	wind_gain = gain
	if shape != null:
		shape.configure(_stiffness, _damping_ratio, shape.coupling, wind * wind_gain)


## Local gust. Nodes outside `radius` of `center` are untouched. (§5 단계 1, 2)
func excite(pulse: float, radius: float, center: Vector2 = Vector2.INF) -> void:
	if shape == null:
		return
	var origin: Vector2 = bounds.get_center() if center == Vector2.INF else center
	shape.apply_impulse(origin, maxf(radius, 0.0001), pulse, Vector2.UP)


## §5 단계 3 + 4. 물리 → points 갱신.
func step(delta: float) -> void:
	if shape == null or delta <= 0.0:
		return
	shape.step(delta)


func reset() -> void:
	if shape != null:
		shape.reset()


func get_vertex_count() -> int:
	return shape.node_count() if shape != null else 0


func get_grid_size() -> Vector2i:
	return Vector2i(width, height)


## Bilinear sample of the deformed surface, u and v in 0..1.
func get_point(u: float, v: float) -> Vector2:
	if shape == null:
		return Vector2.ZERO
	return _sample(shape.get_points(), u, v)


## Deformed position minus rest position, for drawing an offset overlay.
func get_offset(u: float, v: float) -> Vector2:
	if shape == null:
		return Vector2.ZERO
	return _sample(shape.get_points(), u, v) - _sample(shape.get_rest(), u, v)


## Triangle indices for build_grid()'s quads, ready for ArrayMesh.
func build_triangles() -> PackedInt32Array:
	var indices: PackedInt32Array = PackedInt32Array()
	for gy: int in range(height - 1):
		for gx: int in range(width - 1):
			var top_left: int = gy * width + gx
			var top_right: int = top_left + 1
			var bottom_left: int = top_left + width
			var bottom_right: int = bottom_left + 1
			indices.append(top_left)
			indices.append(bottom_left)
			indices.append(top_right)
			indices.append(top_right)
			indices.append(bottom_left)
			indices.append(bottom_right)
	return indices


## §6.3. 이 클래스는 이미 정규 형상이므로 그대로 돌려준다. 복사본이 아니다.
func to_shape() -> ProceduralShape:
	return shape


## 접촉 질의를 정규 형상에 직접 내린다. (§5 단계 1)
func collect_contacts(world_point: Vector2, query_radius: float) -> PackedInt32Array:
	if shape == null:
		return PackedInt32Array()
	return shape.collect_contacts(world_point, query_radius)


## §2.4. deform 필드가 켜진 격자는 bake 금지다.
func is_bakeable() -> bool:
	return shape != null and shape.is_bakeable()


func _sample(source: PackedVector2Array, u: float, v: float) -> Vector2:
	if source.is_empty():
		return Vector2.ZERO
	var fx: float = clampf(u, 0.0, 1.0) * float(width - 1)
	var fy: float = clampf(v, 0.0, 1.0) * float(height - 1)
	var x0: int = clampi(floori(fx), 0, width - 1)
	var y0: int = clampi(floori(fy), 0, height - 1)
	var x1: int = clampi(x0 + 1, 0, width - 1)
	var y1: int = clampi(y0 + 1, 0, height - 1)
	var tx: float = fx - float(x0)
	var ty: float = fy - float(y0)
	var top: Vector2 = source[y0 * width + x0].lerp(source[y0 * width + x1], tx)
	var bottom: Vector2 = source[y1 * width + x0].lerp(source[y1 * width + x1], tx)
	return top.lerp(bottom, ty)
