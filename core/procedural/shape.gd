class_name ProceduralShape
extends RefCounted

# PURPOSE: 정규 형상. PVE(절차 비주얼 엔진)가 스펙에서 만들어 내는 단 하나의
# 결과물. 보이는 것 · 충돌하는 것 · 닿으면 변형되는 것이 전부 이 구조에서 나온다.
# 정본: core/procedural/DESIGN_DECISION.md
# OWNER: PVE. NEW IN ENGINE_VERSION 2.
#
# 정규 형상은 네 배열이다.
#   rest    정지 좌표. 빌드 시 1회. 불변.
#   points  현재 좌표. 매 프레임 갱신. <- 단 하나의 진실
#   radius  노드당 굵기. points와 같은 인덱스.
#   links   연결 (i, j) 쌍. chain은 순차, grid는 격자.
#
# 렌더 데이터 · 콜라이더 · 변형 핸들이 전부 points를 읽는다. 물리 사본이 없다.
# get_points()는 복사본이 아니라 정규 배열 그 자체를 반환한다. 그래서 화면과 물리가
# 어긋날 코드 경로가 존재할 수 없다. (DESIGN_DECISION §0)
#
# 이 클래스는 Node가 아니다. 씬 트리·Input·InputMap·get_tree()·/root·autoload를
# 전혀 쓰지 않는다. 리터럴 RGB도 없다. 색은 ProceduralPalette 역할로만 온다.

enum Kind { RIGID, SOFT_CHAIN, SOFT_GRID }
enum AnchorMode { ATTACHED, PINNED, FREE }

const KIND_RIGID: StringName = &"rigid"
const KIND_SOFT_CHAIN: StringName = &"soft_chain"
const KIND_SOFT_GRID: StringName = &"soft_grid"
const MODE_ATTACHED: StringName = &"attached"
const MODE_PINNED: StringName = &"pinned"
const MODE_FREE: StringName = &"free"

## §1.4 기본값. 결합에도 전용 상수가 없다.
const DEFAULT_STIFFNESS: float = 140.0
const DEFAULT_DAMPING: float = 0.6
const DEFAULT_COUPLING: float = 0.0
const DEFAULT_SUBSTEP: float = 1.0 / 240.0
## §4.3. 기본값 1.0 = 부모 끝점. 이 기본값 덕분에 chain 스펙은 anchor 를
## 하나도 쓰지 않아도 된다. rigid 의 parts 만 이 값을 덮어쓴다.
const DEFAULT_AT: float = 1.0
## §9 성능 예산.
const MAX_CHAIN_NODES: int = 64
const MAX_GRID_SIDE: int = 32

var kind: int = Kind.RIGID
var spec_id: String = ""
var spec_hash: int = 0
var collider_enabled: bool = false
var has_deform_field: bool = false
## soft_grid 전용. 정점 인덱스를 (gy * grid_columns + gx) 로 되돌리는 데 쓴다.
var grid_columns: int = 0
var grid_rows: int = 0

# ── 정규 형상: 네 배열 ────────────────────────────────────────────────────
var rest: PackedVector2Array = PackedVector2Array()
var points: PackedVector2Array = PackedVector2Array()
var radius: PackedFloat32Array = PackedFloat32Array()
var links: PackedInt32Array = PackedInt32Array()

# ── 앵커 정적 데이터 (§4.3) ───────────────────────────────────────────────
var anchor_mode: PackedInt32Array = PackedInt32Array()
var anchor_parent: PackedInt32Array = PackedInt32Array()
var anchor_at: PackedFloat32Array = PackedFloat32Array()
var anchor_offset: PackedVector2Array = PackedVector2Array()
var anchor_angle: PackedFloat32Array = PackedFloat32Array()

# ── 파생 데이터 ───────────────────────────────────────────────────────────
## 정지 진행 방향. rigid 에서는 파트의 축, chain 에서는 다음 정점 방향.
var rest_dir: PackedVector2Array = PackedVector2Array()
## 현재 진행 방향. 변형에 따라 갱신된다.
var run_dir: PackedVector2Array = PackedVector2Array()
## 노드당 실효 길이. rigid = 파트 자체 길이, chain = 다음 정점까지의 정지 거리.
var span: PackedFloat32Array = PackedFloat32Array()
## 1 = 동적 노드(스프링 존재). 0 = 고정. §2.4.1
var dynamic: PackedByteArray = PackedByteArray()
## soft_grid 전용. (i, j) 쌍의 이웃 목록.
var neighbours: PackedInt32Array = PackedInt32Array()
## neighbour_begin: 노드 i 의 이웃 범위: [neighbour_begin[i], neighbour_begin[i + 1])
var neighbour_begin: PackedInt32Array = PackedInt32Array()
## §5.1. 한 프레임 동안만 살아 있는 노드별 타깃 가산치. step() 이 소비하고 지운다.
## 배경의 카메라 오프셋처럼 "노드마다 다른, 이번 프레임만 유효한 힘" 을 넣는 통로다.
var target_bias: PackedVector2Array = PackedVector2Array()
## 옵셔널 노드 이름. ProceduralSquishRig 이 관절 id 를 여기에 실어 준다.
var node_ids: Array[StringName] = []

# ── 물리 파라미터 (§1.4) ──────────────────────────────────────────────────
var stiffness: float = DEFAULT_STIFFNESS
var damping: float = DEFAULT_DAMPING
var coupling: float = DEFAULT_COUPLING
var force: Vector2 = Vector2.ZERO
var max_substep: float = DEFAULT_SUBSTEP

var _springs: Array = []
var _count: int = 0
var _bake_resolved: bool = false
var _drift_field: ProceduralNoiseField = null
var _drift_amplitude: float = 0.0
## 표류 속도는 엔진에 이미 있는 상수를 재사용한다. 새 튜닝 상수를 만들지 않는다.
var _drift_flow: Vector2 = Vector2(ProceduralBackdropDynamics.DEFAULT_PHASE_SPEED, 0.0)


func _init(p_kind: int = Kind.RIGID) -> void:
	kind = p_kind


# ─────────────────────────────────────────────────────────────────────────
# 스펙 진입점 (§0 axiom)
# ─────────────────────────────────────────────────────────────────────────

## 스펙 §1. JSON-safe Dictionary 하나를 정규 형상 하나로 만든다.
## kind별로 parts / chain / grid 중 정확히 하나가 있어야 한다.
## 성공하면 true. 위반하면 push_error 하고 false — 부분 상태를 남기지 않는다.
func build_from_spec(spec: Dictionary) -> bool:
	if not spec.has("version"):
		push_error("ProceduralShape: spec is missing 'version'.")
		return false
	if int(spec["version"]) != Procedural.ENGINE_VERSION:
		push_error("ProceduralShape: spec version %d != ENGINE_VERSION %d." % [int(spec["version"]), Procedural.ENGINE_VERSION])
		return false
	if not spec.has("id") or not spec.has("kind"):
		push_error("ProceduralShape: spec needs 'id' and 'kind'.")
		return false
	spec_id = String(spec["id"])
	spec_hash = _hash_spec(spec)
	collider_enabled = bool(spec.get("collider", false))
	var physics: Dictionary = spec.get("physics", {})
	stiffness = maxf(float(physics.get("stiffness", DEFAULT_STIFFNESS)), 0.0001)
	damping = maxf(float(physics.get("damping", DEFAULT_DAMPING)), 0.0)
	coupling = clampf(float(physics.get("coupling", DEFAULT_COUPLING)), 0.0, 1.0)
	force = _read_vector(physics.get("force", [0.0, 0.0]), Vector2.ZERO)
	max_substep = clampf(float(physics.get("max_substep", DEFAULT_SUBSTEP)), 0.0001, 1.0 / 30.0)
	has_deform_field = false
	_drift_field = null
	_drift_amplitude = 0.0
	var requested: int = kind_from_name(StringName(spec["kind"]))
	var present: int = 0
	for candidate: int in [Kind.RIGID, Kind.SOFT_CHAIN, Kind.SOFT_GRID]:
		if spec.has(_kind_key(candidate)):
			present += 1
	if present != 1:
		push_error("ProceduralShape: spec needs exactly one of parts / chain / grid. Found %d." % present)
		return false
	# kind 는 dispatch 전에 먼저 세운다. build_grid / add_chain_node 가 자기 종류를
	# 확인하기 전에 값이 들어 있어야 한다.
	kind = requested
	match requested:
		Kind.RIGID:
			return _build_rigid(spec)
		Kind.SOFT_CHAIN:
			return _build_soft_chain(spec)
		_:
			return _build_soft_grid(spec)


static func _kind_key(p_kind: int) -> StringName:
	match p_kind:
		Kind.SOFT_CHAIN:
			return &"chain"
		Kind.SOFT_GRID:
			return &"grid"
		_:
			return &"parts"


## §1.9 예시 A. 풀. chain[0] 만 pinned, 나머지는 기본값 attached.
func _build_soft_chain(spec: Dictionary) -> bool:
	var chain: Array = spec["chain"]
	if chain.size() < 2:
		push_error("ProceduralShape: a chain needs at least 2 nodes.")
		return false
	if chain.size() > MAX_CHAIN_NODES:
		push_error("ProceduralShape: chain %d exceeds MAX_CHAIN_NODES %d." % [chain.size(), MAX_CHAIN_NODES])
		return false
	if not allocate(chain.size(), Kind.SOFT_CHAIN):
		return false
	for entry: Variant in chain:
		var node: Dictionary = entry
		var length: float = maxf(float(node.get("length", 0.0)), 0.0)
		var node_radius: float = maxf(float(node.get("radius", 0.0)), 0.0)
		var angle_degrees: float = float(node.get("angle", 0.0))
		var bend: float = float(node.get("bend", 0.0))
		var index: int = _count
		if not add_chain_node(length, node_radius, angle_degrees, bend):
			return false
		var anchor: Dictionary = node.get("anchor", {})
		if not anchor.is_empty() and not _apply_anchor(index, anchor, Kind.SOFT_CHAIN):
			return false
		_count += 1
	return finalize()


## §1.9 예시 B. 바위. parent = 직전 파트, at = 0~1 이 핵심 확장.
func _build_rigid(spec: Dictionary) -> bool:
	var parts: Array = spec["parts"]
	if parts.is_empty():
		push_error("ProceduralShape: a rigid shape needs at least one part.")
		return false
	if not allocate(parts.size(), Kind.RIGID):
		return false
	for entry: Variant in parts:
		var part: Dictionary = entry
		var length: float = maxf(float(part.get("length", 1.0)), 0.0001)
		var base_radius: float = maxf(float(part.get("base_radius", 0.0)), 0.0)
		var tip_radius: float = maxf(float(part.get("tip_radius", 0.0)), 0.0)
		var at_value: float = float(part.get("at", DEFAULT_AT))
		var angle_degrees: float = float(part.get("angle", 0.0))
		var scale_factor: float = maxf(float(part.get("scale", 1.0)), 0.0001)
		# 구형 호환: joint 3칸 → at 연속. §7-2
		if not part.has("at") and part.has("joint"):
			at_value = _joint_to_at(StringName(part["joint"]))
		if not add_part(length, base_radius, tip_radius, at_value, angle_degrees, scale_factor):
			return false
		_count += 1
	return finalize()


## §1.9 예시 C. 수면.
func _build_soft_grid(spec: Dictionary) -> bool:
	var grid: Dictionary = spec["grid"]
	var grid_width: int = int(grid.get("width", 0))
	var grid_height: int = int(grid.get("height", 0))
	if grid_width < 2 or grid_height < 2:
		push_error("ProceduralShape: grid needs width and height >= 2.")
		return false
	if grid_width > MAX_GRID_SIDE or grid_height > MAX_GRID_SIDE:
		push_error("ProceduralShape: grid %dx%d exceeds MAX_GRID_SIDE %d." % [grid_width, grid_height, MAX_GRID_SIDE])
		return false
	if not grid.has("rect"):
		push_error("ProceduralShape: grid needs 'rect'.")
		return false
	var rect: Rect2 = _read_rect(grid["rect"])
	# drift 는 build_grid (최종화) 보다 먼저 묶어야 한다. 그래야 스프링이 생긴다.
	bind_drift_field(
		Procedural.make_noise(
			Procedural.derive_seed(int(spec.get("seed", 0)), spec_id + "/field"),
			StringName(grid["field"])
		),
		float(grid.get("field_amplitude", 0.0))
	)
	if not build_grid(grid_width, grid_height, rect):
		return false
	for index: int in node_count():
		radius[index] = maxf(float(grid.get("radius", 0.0)), 0.0)
	if grid.has("anchor"):
		var anchor: Dictionary = grid["anchor"]
		for index: int in node_count():
			if not _apply_anchor(index, anchor, Kind.SOFT_GRID):
				return false
	# §1.7 grid.field. 표류는 정지에 굽지 않고 매 프레임 타깃에 더한다.
	# 결합과 같은 스프링을 쓴다. 전용 상수 없다.
	rebuild_springs()
	return true


# ─────────────────────────────────────────────────────────────────────────
# 정적 구축
# ─────────────────────────────────────────────────────────────────────────

## 용량을 잡는다. add_* 가 _count 를 늘린다. build_grid 만 내부에서 한 번 더 부른다.
func allocate(node_count: int, p_kind: int) -> bool:
	var capacity: int = maxi(node_count, 1)
	if p_kind == Kind.SOFT_CHAIN and capacity > MAX_CHAIN_NODES:
		push_error("ProceduralShape: chain capacity %d exceeds MAX_CHAIN_NODES %d." % [capacity, MAX_CHAIN_NODES])
		return false
	kind = p_kind
	rest.resize(capacity)
	points.resize(capacity)
	rest_dir.resize(capacity)
	run_dir.resize(capacity)
	anchor_offset.resize(capacity)
	anchor_mode.resize(capacity)
	anchor_parent.resize(capacity)
	anchor_at.resize(capacity)
	anchor_angle.resize(capacity)
	span.resize(capacity)
	radius.resize(capacity)
	dynamic.resize(capacity)
	target_bias.resize(capacity)
	neighbour_begin.resize(capacity + 1)
	for index: int in capacity:
		rest[index] = Vector2.ZERO
		points[index] = Vector2.ZERO
		rest_dir[index] = Vector2.RIGHT
		run_dir[index] = Vector2.RIGHT
		anchor_offset[index] = Vector2.ZERO
		anchor_mode[index] = AnchorMode.ATTACHED
		anchor_parent[index] = -1
		anchor_at[index] = DEFAULT_AT
		anchor_angle[index] = 0.0
		span[index] = 0.0
		radius[index] = 0.0
		dynamic[index] = 0
		target_bias[index] = Vector2.ZERO
	links = PackedInt32Array()
	neighbours = PackedInt32Array()
	node_ids.clear()
	node_ids.resize(capacity)
	for index: int in capacity:
		node_ids[index] = &""
	_springs.clear()
	_springs.resize(capacity)
	for index: int in capacity:
		neighbour_begin[index] = 0
	neighbour_begin[capacity] = 0
	_count = 0
	_bake_resolved = false
	return true


func node_count() -> int:
	return _count


## §1.3. chain 항목 → 노드 1개. length = 이전 정점까지의 정지 거리.
## index 0 은 부모가 없으므로 기본 모드가 pinned 이다. (§4.5)
func add_chain_node(length: float, node_radius: float, angle_degrees: float, bend: float) -> bool:
	if kind != Kind.SOFT_CHAIN:
		push_error("ProceduralShape.add_chain_node on a non chain shape.")
		return false
	var index: int = _count
	var parent: int = -1 if index == 0 else index - 1
	var mode: int = AnchorMode.PINNED if index == 0 else AnchorMode.ATTACHED
	if not set_anchor(index, mode, parent, 0.0, Vector2.ZERO, angle_degrees + bend):
		return false
	span[index] = length
	radius[index] = node_radius
	return true


## §1.2. parts 항목 → 노드 1개. index 0 은 원점에 직접 선다.
func add_part(length: float, base_radius: float, tip_radius: float, at_value: float, angle_degrees: float, scale_factor: float) -> bool:
	var index: int = _count
	var parent: int = -1 if index == 0 else index - 1
	var mode: int = AnchorMode.FREE if index == 0 else AnchorMode.ATTACHED
	if not set_anchor(index, mode, parent, at_value, Vector2.ZERO, angle_degrees):
		return false
	span[index] = length * scale_factor
	radius[index] = maxf(base_radius, tip_radius) * 0.5
	return true


## §4.3. chain[0] 은 부모가 없으므로 attached 를 쓸 수 없다.
func set_anchor(index: int, mode: int, parent: int, at_value: float, offset: Vector2, angle_degrees: float) -> bool:
	if index < 0 or index >= rest.size():
		push_error("ProceduralShape.set_anchor: index %d out of capacity." % index)
		return false
	if mode == AnchorMode.ATTACHED:
		if index == 0:
			push_error("ProceduralShape: node 0 has no parent. Use pinned or free.")
			return false
		if parent < 0 or parent >= index:
			push_error("ProceduralShape: anchor.parent %d must be an earlier index (< %d)." % [parent, index])
			return false
	anchor_mode[index] = mode
	anchor_parent[index] = parent if mode == AnchorMode.ATTACHED else -1
	anchor_at[index] = clampf(at_value, 0.0, 1.0)
	anchor_offset[index] = offset
	anchor_angle[index] = angle_degrees
	return true


func _apply_anchor(index: int, anchor: Dictionary, owner_kind: int) -> bool:
	if anchor.is_empty():
		return true
	if not anchor.has("mode") and index == 0:
		return true
	var mode: int = AnchorMode.ATTACHED
	if anchor.has("mode"):
		mode = mode_from_name(StringName(anchor["mode"]))
	if owner_kind == Kind.SOFT_GRID and mode == AnchorMode.ATTACHED:
		push_error("ProceduralShape: a grid has no parent. grid.anchor cannot be attached.")
		return false
	var parent: int = index - 1
	if anchor.has("parent"):
		parent = int(anchor["parent"])
	var at_value: float = float(anchor.get("at", DEFAULT_AT))
	if owner_kind == Kind.SOFT_CHAIN:
		at_value = 0.0
	var offset: Vector2 = _read_vector(anchor.get("offset", [0.0, 0.0]), Vector2.ZERO)
	var angle_degrees: float = float(anchor.get("angle", 0.0))
	if not set_anchor(index, mode, parent, at_value, offset, angle_degrees):
		return false
	if anchor_mode[index] != AnchorMode.ATTACHED:
		anchor_angle[index] = angle_degrees
	return true


func build_grid(grid_width: int, grid_height: int, rect: Rect2) -> bool:
	if kind != Kind.SOFT_GRID:
		push_error("ProceduralShape.build_grid on a non grid shape.")
		return false
	var columns: int = maxi(grid_width, 2)
	var rows: int = maxi(grid_height, 2)
	if not allocate(columns * rows, Kind.SOFT_GRID):
		return false
	grid_columns = columns
	grid_rows = rows
	_count = columns * rows
	for gy: int in rows:
		for gx: int in columns:
			var index: int = gy * columns + gx
			var u: float = float(gx) / float(columns - 1)
			var v: float = float(gy) / float(rows - 1)
			rest[index] = Vector2(
				lerpf(rect.position.x, rect.end.x, u),
				lerpf(rect.position.y, rect.end.y, v)
			)
	for gy: int in rows:
		for gx: int in columns:
			var index: int = gy * columns + gx
			if gx + 1 < columns:
				_link(index, index + 1)
			if gy + 1 < rows:
				_link(index, index + columns)
	for gy: int in rows:
		for gx: int in columns:
			var index: int = gy * columns + gx
			neighbour_begin[index] = neighbours.size()
			if gx > 0:
				neighbours.append(index - 1)
			if gx + 1 < columns:
				neighbours.append(index + 1)
			if gy > 0:
				neighbours.append(index - columns)
			if gy + 1 < rows:
				neighbours.append(index + columns)
	neighbour_begin[columns * rows] = neighbours.size()
	# grid 기본값은 전부 free 다. 부모가 없다. (§4.5)
	for index: int in _count:
		anchor_mode[index] = AnchorMode.FREE
		anchor_parent[index] = -1
	# 여기서 확정한다. 직접 호출하는 쪽이 finalize() 를 잊어도 형상이 깨지지 않게.
	return finalize()


func _link(from_index: int, to_index: int) -> void:
	links.append(from_index)
	links.append(to_index)


## 정지 좌표·정지 방향·스프링을 확정한다. build_* 의 마지막에 한 번 부른다.
func finalize() -> bool:
	if _count <= 0:
		push_error("ProceduralShape.finalize: no nodes.")
		return false
	# 정지 진행 방향. 루트는 +X, 이후는 부모 방향에서 angle 만큼 회전.
	for index: int in _count:
		var parent: int = anchor_parent[index]
		var base_dir: Vector2 = Vector2.RIGHT if parent < 0 else rest_dir[parent]
		rest_dir[index] = base_dir.rotated(deg_to_rad(anchor_angle[index]))
		run_dir[index] = rest_dir[index]
	# 정지 좌표. 비순환이어야 한다 — 자식 좌표는 오직 부모의 정지값으로 만든다.
	#
	# soft_grid 는 예외다. build_grid() 가 이미 좌표를 깔았고 부모가 하나도 없다.
	# 여기서 다시 계산하면 전부 원점으로 덮어써진다.
	if kind != Kind.SOFT_GRID:
		for index: int in _count:
			var parent: int = anchor_parent[index]
			if parent < 0:
				rest[index] = anchor_offset[index]
			elif kind == Kind.SOFT_CHAIN:
				# chain 노드 자신이 곧 관절이다. 부모 끝점이 아니라 부모 위치에 붙고,
				# 자신의 span 만큼 진행 방향으로 뻗는다. §5 단계 4 와 정확히 같은 식.
				rest[index] = rest[parent] \
					+ rest_dir[index] * span[index] \
					+ anchor_offset[index].rotated(rest_dir[parent].angle())
			else:
				# rigid 파트는 길이가 있으므로 부모 길이 위의 지점(at)에 붙는다.
				# offset 은 부모 프레임의 로컬 벡터를 그대로 회전시킨다. 성분을 버리지 않는다.
				rest[index] = rest[parent] \
					+ rest_dir[parent] * (anchor_at[index] * span[parent]) \
					+ anchor_offset[index].rotated(rest_dir[parent].angle())
	# 연결은 부모 간선 그 자체다. chain 이면 순차선이 되고, rigid 이면 실제
	# 트리 간선이 되고(분기 가능), grid 는 build_grid 가 이미 만들었다.
	if kind != Kind.SOFT_GRID:
		for index: int in _count:
			if anchor_parent[index] >= 0:
				_link(anchor_parent[index], index)
	points = rest.duplicate()
	_allocate_springs()
	_bake_resolved = false
	return true


## §2.4.1. dynamic 노드만 스프링을 가진다.
func _allocate_springs() -> void:
	_springs.clear()
	_springs.resize(_count)
	for index: int in _count:
		var is_dynamic: bool = false
		if kind != Kind.RIGID:
			is_dynamic = anchor_mode[index] != AnchorMode.PINNED
		if has_deform_field:
			is_dynamic = true
		dynamic[index] = 1 if is_dynamic else 0
		if is_dynamic:
			_springs[index] = ProceduralSpring.Spring2D.new(rest[index], stiffness, damping)
		else:
			_springs[index] = null


func configure(p_stiffness: float, p_damping: float, p_coupling: float, p_force: Vector2) -> void:
	stiffness = maxf(p_stiffness, 0.0001)
	damping = maxf(p_damping, 0.0)
	coupling = clampf(p_coupling, 0.0, 1.0)
	force = p_force
	for index: int in _count:
		var spring: ProceduralSpring.Spring2D = _springs[index]
		if spring != null:
			spring.configure(stiffness, damping)


## §2.4. deform 필드를 바인딩하면 bake 가 금지된다.
## 판정은 rebuild_springs() 가 다시 계산한다. 순서: 바인딩 → rebuild.
func set_deform_field_bound(bound: bool) -> void:
	has_deform_field = bound


## §1.7 grid.field. 표류는 정지에 굽지 않고 매 프레임 타깃에 더한다.
## null 로 넘기면 표류가 꺼진다. 결합과 같은 스프링을 쓴다.
func bind_drift_field(field: ProceduralNoiseField, drift_amplitude: float) -> void:
	_drift_field = field
	_drift_amplitude = maxf(drift_amplitude, 0.0)
	has_deform_field = field != null


func rebuild_springs() -> void:
	_allocate_springs()
	_bake_resolved = false


# ─────────────────────────────────────────────────────────────────────────
# 정규 형상 접근
# ─────────────────────────────────────────────────────────────────────────

## 정규 배열 그 자체. 복사본이 아니다. (§0 axiom 의 구현 지점)
func get_points() -> PackedVector2Array:
	return points


## §5.1. 이번 프레임의 타깃에 더할 가산치. step() 이 소비하고 0 으로 되돌린다.
## 노드마다 다른 값을 줄 수 있다 — 배경의 카메라 오프셋이 이 통로를 쓴다.
## pinned 노드는 스프링이 없으므로 이 값이 통째로 무시된다.
func set_target_bias(index: int, bias: Vector2) -> void:
	if index < 0 or index >= _count:
		return
	target_bias[index] = bias


## 한 노드에 속도 임펄스를 직접 준다. 펄스·충격처럼 국소적인 사건용.
func kick_node(index: int, impulse: Vector2) -> void:
	if index < 0 or index >= _count:
		return
	var spring: ProceduralSpring.Spring2D = _springs[index]
	if spring != null:
		spring.kick(impulse)


## §7-5. 자유 노드 하나를 추가한다. 스프링이 있어서 늦고 요동친다.
## 배경 앵커는 이것이다. 정지 좌표가 곧 그 앵커의 월드 위치다.
func add_free_anchor(rest_world_position: Vector2) -> int:
	if not _grow_capacity(_count + 1):
		return -1
	var index: int = _count
	_count += 1
	rest[index] = rest_world_position
	points[index] = rest_world_position
	rest_dir[index] = Vector2.RIGHT
	run_dir[index] = Vector2.RIGHT
	anchor_mode[index] = AnchorMode.FREE
	anchor_parent[index] = -1
	anchor_at[index] = DEFAULT_AT
	anchor_offset[index] = Vector2.ZERO
	anchor_angle[index] = 0.0
	span[index] = 0.0
	target_bias[index] = Vector2.ZERO
	_springs[index] = ProceduralSpring.Spring2D.new(rest[index], stiffness, damping)
	dynamic[index] = 1
	_bake_resolved = false
	return index


## §6.3. ProceduralSquishRig 이 관절 하나를 노드로 심는다. index 는 이미 순회된
## "부모가 먼저" 순서여야 한다. offset 은 부모 프레임의 로컬 벡터다. (§4.3)
func add_rig_joint(
	index: int, mode: int, parent_index: int, offset: Vector2,
	angle_degrees: float, at_value: float = 0.0, joint_id: StringName = &""
) -> bool:
	if index < 0 or index >= rest.size():
		push_error("ProceduralShape.add_rig_joint: index %d out of capacity." % index)
		return false
	if mode == AnchorMode.ATTACHED and (parent_index < 0 or parent_index >= index):
		push_error("ProceduralShape.add_rig_joint: parent %d must be an earlier index (< %d)." % [parent_index, index])
		return false
	_count = maxi(_count, index + 1)
	anchor_mode[index] = mode
	anchor_parent[index] = parent_index if mode == AnchorMode.ATTACHED else -1
	anchor_offset[index] = offset
	anchor_angle[index] = angle_degrees
	# §1.2. 리그 관절은 0 (명시적 offset 이 위치를 정한다). rigid 파트는 at 을 준다.
	anchor_at[index] = clampf(at_value, 0.0, 1.0)
	span[index] = 0.0
	if index < node_ids.size():
		node_ids[index] = joint_id
	return true


func node_id_at(index: int) -> StringName:
	if index < 0 or index >= node_ids.size():
		return &""
	return node_ids[index]


## 관절마다 다른 감쇠를 허용한다. 리그 전용.
func set_node_stiffness(node: int, node_stiffness: float, node_damping: float) -> void:
	if node < 0 or node >= _springs.size():
		return
	var spring: ProceduralSpring.Spring2D = _springs[node]
	if spring != null:
		spring.configure(maxf(node_stiffness, 0.0001), maxf(node_damping, 0.0))


## 앵커를 개수 세는 만큼 붙일 수 있게 용량을 늘린다. 정규 배열은 늘어난다.
func set_anchor_capacity(capacity: int) -> bool:
	return _grow_capacity(maxi(capacity, _count))


func _grow_capacity(needed: int) -> bool:
	var capacity: int = maxi(needed, rest.size())
	if capacity <= rest.size():
		return true
	if capacity > MAX_CHAIN_NODES:
		push_error("ProceduralShape: capacity %d exceeds MAX_CHAIN_NODES %d." % [capacity, MAX_CHAIN_NODES])
		return false
	var previous: int = rest.size()
	var was_grid: bool = kind == Kind.SOFT_GRID
	for slot: int in range(previous, capacity):
		rest.append(Vector2.ZERO)
		points.append(Vector2.ZERO)
		rest_dir.append(Vector2.RIGHT)
		run_dir.append(Vector2.RIGHT)
		anchor_offset.append(Vector2.ZERO)
		anchor_mode.append(AnchorMode.FREE if was_grid else AnchorMode.ATTACHED)
		anchor_parent.append(-1)
		anchor_at.append(DEFAULT_AT)
		anchor_angle.append(0.0)
		span.append(0.0)
		radius.append(0.0)
		dynamic.append(0)
		target_bias.append(Vector2.ZERO)
		_springs.append(null)
		node_ids.append(&"")
	var grown: int = capacity
	neighbour_begin.resize(grown + 1)
	# chain 에는 이웃이 없다. 늘어난 꼬리는 0 이다. grid 는 build_grid 가 따로 만든다.
	for slot: int in range(previous, grown + 1):
		neighbour_begin[slot] = 0
	return true


func get_rest() -> PackedVector2Array:
	return rest


func get_radius() -> PackedFloat32Array:
	return radius


func get_links() -> PackedInt32Array:
	return links


func get_run_dir(index: int) -> Vector2:
	if index < 0 or index >= _count:
		return Vector2.RIGHT
	return run_dir[index]


## 정지 진행 방향. rigid 에서는 파트 축, chain 에서는 다음 정점 방향.
func get_rest_dir(index: int) -> Vector2:
	if index < 0 or index >= _count:
		return Vector2.RIGHT
	return rest_dir[index]


func get_grid_side_x() -> int:
	return grid_columns


func get_grid_side_y() -> int:
	return grid_rows


func get_neighbours(index: int) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	if index < 0 or index >= _count or index + 1 >= neighbour_begin.size():
		return out
	for slot: int in range(neighbour_begin[index], neighbour_begin[index + 1]):
		out.append(neighbours[slot])
	return out


## §2.2. 콜라이더 파생. 배열을 복사하지 않고 인덱스만 보관한다.
## 그래서 렌더가 읽는 배열과 콜라이더가 참조하는 배열이 물리적으로 같은 객체다.
func derive_collider() -> Dictionary:
	if not collider_enabled:
		push_error("ProceduralShape.derive_collider: the spec disabled the collider.")
		return {}
	var source: String = "rest" if kind == Kind.RIGID else "points"
	var segments: PackedInt32Array = PackedInt32Array()
	var circles: PackedInt32Array = PackedInt32Array()
	var widths: PackedFloat32Array = PackedFloat32Array()
	for slot: int in range(0, links.size(), 2):
		segments.append(links[slot])
		segments.append(links[slot + 1])
	for index: int in _count:
		if radius[index] > 0.0:
			circles.append(index)
			widths.append(radius[index])
	return {
		"kind": "rigid" if kind == Kind.RIGID else "dynamic",
		"source": source,
		"node_count": _count,
		"segments": segments,
		"circles": circles,
		"radius": widths,
	}


## 콜라이더 파생점이 실제로 가리키는 좌표. 정본 배열에서 실시간으로 읽는다.
## (테스트 b 가 이 경로로 "화면과 물리가 같은 배열"을 행동으로 증명한다)
func read_collider_point(collider: Dictionary, node_index: int) -> Vector2:
	if String(collider.get("source", "")) == "rest":
		return rest[node_index]
	return points[node_index]


# ─────────────────────────────────────────────────────────────────────────
# 접촉 → 변형 (§5)
# ─────────────────────────────────────────────────────────────────────────

## §5 단계 1. rest 기준 거리. 거리순 정렬은 하지 않는다 — 재현성.
func collect_contacts(world_point: Vector2, query_radius: float) -> PackedInt32Array:
	var hits: PackedInt32Array = PackedInt32Array()
	var reach: float = maxf(query_radius, 0.0)
	if reach <= 0.0:
		return hits
	var reach_sq: float = reach * reach
	for index: int in _count:
		if rest[index].distance_squared_to(world_point) <= reach_sq:
			hits.append(index)
	return hits


## §5 단계 2. 접선 성분만 준다. 눌린 것이 옆으로 미끄러지지 않는다.
func apply_impulse(world_point: Vector2, query_radius: float, strength: float, direction: Vector2) -> PackedInt32Array:
	var hits: PackedInt32Array = collect_contacts(world_point, query_radius)
	if strength == 0.0 or hits.is_empty():
		return hits
	var reach: float = maxf(query_radius, 0.0001)
	for index: int in hits:
		var spring: ProceduralSpring.Spring2D = _springs[index]
		if spring == null:
			continue
		var falloff: float = 1.0 - clampf(rest[index].distance_to(world_point) / reach, 0.0, 1.0)
		if falloff <= 0.0:
			continue
		var tangent: Vector2 = run_dir[index]
		spring.kick((direction - tangent * direction.dot(tangent)) * strength * falloff)
	return hits


## §5 단계 3 + 4. 물리 → points 갱신. 이 한 함수로 전파가 끝난다.
## caller 규약: 이 함수 이전에 그리는 코드는 금지. (§5.1)
func step(delta: float) -> void:
	if delta <= 0.0 or _count == 0:
		return
	if kind == Kind.SOFT_GRID:
		_step_grid(delta)
	else:
		_step_chain(delta)
	_update_run_dirs()
	_confirm_bake()


## soft_chain / rigid. 인덱스 오름차순 in-place. 부모가 먼저 확정된다.
##
## 타깃은 "위치는 부모의 현재 좌표, 방향은 정지 방향" 이다. 이 조합이 두 가지를
## 동시에 준다.
##   - 부모를 따라간다   위치원이 points[parent] 다.
##   - 형태를 기억한다   방향원이 run_dir 가 아니라 rest_dir 다.
##
## run_dir(휜 방향)를 쓰면 끝단에 형태 기억이 없다. 자식 타겟이 부모의 휜 방향을
## 따라가므로 접힌 방향을 "정지 방향"으로 받아들이고 체인이 접힌 채로 남는다.
## free 가 정지 모양을 못 잡는 것과 같은 종류의 구멍이다. (§12-1)
## rest_dir 를 쓰면 스프링이 수렴할 때마다 각 노드가 저절로 정지 모양으로 돌아오고,
## 새 상수도 필요 없다.
func _step_chain(delta: float) -> void:
	for index: int in _count:
		var spring: ProceduralSpring.Spring2D = _springs[index]
		if spring == null:
			continue
		var parent: int = anchor_parent[index]
		if parent < 0:
			# 루트. pinned 과 free 는 여기서 동일하게 자기 rest 로 돌아간다.
			spring.set_target(rest[index] + force + target_bias[index])
		else:
			# §4.4. 부모의 이번 프레임 위치 + 정지 방향.
			var local: Vector2 = anchor_offset[index].rotated(rest_dir[parent].angle())
			var follow: Vector2 = Vector2.ZERO
			if kind == Kind.RIGID:
				follow = points[parent] + rest_dir[parent] * (anchor_at[index] * span[parent]) + local
			else:
				follow = points[parent] + rest_dir[index] * span[index] + local
			spring.set_target(follow + force + target_bias[index])
		spring.step(delta)
		points[index] = spring.value
		target_bias[index] = Vector2.ZERO


## soft_grid. §5 단계 3. 변위 평균 + 공용 스프링. 전용 상수 없음.
func _step_grid(delta: float) -> void:
	var use_coupling: bool = coupling > 0.0
	var drift: bool = _drift_field != null and _drift_amplitude > 0.0
	if drift:
		_drift_field.advance(delta, _drift_flow)
	for index: int in _count:
		var spring: ProceduralSpring.Spring2D = _springs[index]
		if spring == null:
			continue
		var target: Vector2 = rest[index] + force + target_bias[index]
		if drift:
			target += _drift_at(index)
		if use_coupling:
			var from: int = neighbour_begin[index]
			var to: int = neighbour_begin[index + 1]
			if to > from:
				var displacement: Vector2 = Vector2.ZERO
				for slot: int in range(from, to):
					var other: int = neighbours[slot]
					displacement += points[other] - rest[other]
				target += coupling * displacement / float(to - from)
		spring.set_target(target)
		spring.step(delta)
		points[index] = spring.value
		target_bias[index] = Vector2.ZERO


## grid 전용 노이즈 표류. 결합과 같은 스프링 타깃에 더한다.
func _drift_at(index: int) -> Vector2:
	if _drift_field == null or _drift_amplitude <= 0.0:
		return Vector2.ZERO
	return _drift_field.sample_v(rest[index].x, rest[index].y) * _drift_amplitude


## chain 전용. rigid 의 방향은 정적이며(파트 축), grid 에는 방향이 없다.
## links(부모 간선) 를 따라간다. 인덱스 인접을 가정하지 않는다 — 분기 트리는
## index+1 이 자식이 아닐 수 있다.
func _update_run_dirs() -> void:
	if kind != Kind.SOFT_CHAIN:
		return
	var assigned: PackedByteArray = PackedByteArray()
	assigned.resize(_count)
	for slot: int in range(0, links.size(), 2):
		var from_index: int = links[slot]
		var to_index: int = links[slot + 1]
		if assigned[from_index] != 0:
			continue
		var travel: Vector2 = points[to_index] - points[from_index]
		if travel.length_squared() > 0.000001:
			run_dir[from_index] = travel.normalized()
			assigned[from_index] = 1


## §2.4 2번째 판정. is_bakeable() 가 참인데 실제로 점이 움직였으면 거부한다.
func _confirm_bake() -> void:
	if _bake_resolved:
		return
	if not is_bakeable():
		_bake_resolved = true
		return
	if not points_match_rest(0.0):
		_bake_resolved = true
		push_error("ProceduralShape: '%s' claims bakeable but points moved. Bake refused." % spec_id)


# ─────────────────────────────────────────────────────────────────────────
# bake 판정 (§2.4) — 자료형으로만 한다
# ─────────────────────────────────────────────────────────────────────────

## 판정 입력에 kind 는 들어가지 않는다. 자료형과 바인딩 상태로만 판정한다.
func is_bakeable() -> bool:
	if kind != Kind.RIGID:
		return false
	if has_deform_field:
		return false
	for index: int in _count:
		if dynamic[index] != 0:
			return false
	return true


## bake 를 요구했는데 조건이 안 되면 실패한다. 조용히 구우지 않는다.
func require_bakeable() -> bool:
	if is_bakeable():
		return true
	push_error("ProceduralShape: bake refused for '%s'. points is not invariant." % spec_id)
	return false


func points_match_rest(epsilon: float = 0.0) -> bool:
	if points.size() != rest.size():
		return false
	var limit: float = maxf(epsilon, 0.0)
	var limit_sq: float = limit * limit
	for index: int in _count:
		if points[index].distance_squared_to(rest[index]) > limit_sq:
			return false
	return true


func is_settled(epsilon: float = 0.001) -> bool:
	for index: int in _count:
		var spring: ProceduralSpring.Spring2D = _springs[index]
		if spring != null and not spring.is_settled(epsilon):
			return false
	return true


func reset() -> void:
	points = rest.duplicate()
	for index: int in _count:
		var spring: ProceduralSpring.Spring2D = _springs[index]
		if spring != null:
			spring.snap(rest[index])


# ─────────────────────────────────────────────────────────────────────────
# 오브젝트 간 결합 (§4.6). 씬 그래프를 알지 않는다.
# ─────────────────────────────────────────────────────────────────────────

func get_root_transform() -> Transform2D:
	if _count == 0:
		return Transform2D.IDENTITY
	var turned: float = 0.0
	if run_dir[0].length_squared() > 0.000001:
		turned = rest_dir[0].angle_to(run_dir[0])
	return Transform2D(turned, points[0] - rest[0])


## rigid 전용. soft_* 는 루트를 pinned 로 두어야 한다. rest 를 옮기면
## 스프링의 정지 타깃이 조용히 이동해 버린다.
func set_root_transform(value: Transform2D) -> void:
	if kind != Kind.RIGID:
		push_error("ProceduralShape.set_root_transform on a soft shape. Pin the root node instead.")
		return
	if _count == 0:
		return
	var origin: Vector2 = rest[0]
	var travel: Vector2 = value.get_origin()
	var turned: float = value.get_rotation()
	for index: int in _count:
		var moved: Vector2 = (rest[index] - origin).rotated(turned) + travel
		rest[index] = moved
		points[index] = moved
		rest_dir[index] = rest_dir[index].rotated(turned)
		run_dir[index] = rest_dir[index].rotated(turned)


# ─────────────────────────────────────────────────────────────────────────
# 스펙 읽기 보조
# ─────────────────────────────────────────────────────────────────────────

static func kind_from_name(name: StringName) -> int:
	match name:
		KIND_SOFT_CHAIN:
			return Kind.SOFT_CHAIN
		KIND_SOFT_GRID:
			return Kind.SOFT_GRID
		_:
			return Kind.RIGID


static func mode_from_name(name: StringName) -> int:
	match name:
		MODE_PINNED:
			return AnchorMode.PINNED
		MODE_FREE:
			return AnchorMode.FREE
		_:
			return AnchorMode.ATTACHED


## §7-2. 구형 joint 3칸을 연속 at 으로 환산.
static func _joint_to_at(joint: StringName) -> float:
	match joint:
		&"middle":
			return 0.5
		&"tip":
			return 1.0
		&"none":
			return 0.0
		_:
			return 0.0


static func _read_vector(raw: Variant, fallback: Vector2) -> Vector2:
	if raw is Array and (raw as Array).size() >= 2:
		return Vector2(float(raw[0]), float(raw[1]))
	if raw is Vector2:
		return raw
	return fallback


static func _read_rect(raw: Variant) -> Rect2:
	if raw is Array and (raw as Array).size() >= 4:
		return Rect2(float(raw[0]), float(raw[1]), float(raw[2]), float(raw[3]))
	if raw is Rect2:
		return raw
	return Rect2(0.0, 0.0, 64.0, 64.0)


## §8-2 a. 같은 스펙은 같은 spec_hash 다. 정수 연산만 쓴다.
static func _hash_spec(spec: Dictionary) -> int:
	var parts: Array[String] = []
	for key: Variant in spec.keys():
		parts.append(String(key))
	parts.sort()
	var accumulator: int = ProceduralSeed.hash_int(Procedural.ENGINE_VERSION)
	for key: String in parts:
		accumulator = ProceduralSeed.combine(accumulator, ProceduralSeed.hash_text(key))
		accumulator = ProceduralSeed.combine(accumulator, ProceduralSeed.hash_text(JSON.stringify(spec[key], "", true)))
	return accumulator
