class_name ProceduralSquishRig
extends RefCounted

# PURPOSE: cutout joints plus mesh deformation in one rig. A joint carries a
# position spring, a rotation spring and a squash spring, plus an optional
# ProceduralDeformField for the soft parts.
# OWNER: PVE. EXISTING SIGNATURES ARE FROZEN.
# 정본: core/procedural/DESIGN_DECISION.md §6.3
#
# 이 클래스는 관절 그래프다. 정규 형상(ProceduralShape)을 만든다 —
# 리그가 두 개의 스프링 집합을 들고 있으면 정규 배열이 둘이 되고 §0 이 깨진다.
# to_shape() 가 그 정규 형상이고, step() 은 그것에 위임한다.
#
# 관절 트리는 지수 분기한다. 정규 형상은 노드당 부모 하나를 가지므로
# to_shape() 는 깊이 우선 순회로 "부모가 먼저" 오는 순서를 만든다.

enum JointKind { RIGID, SOFT, PINNED }

const DEFAULT_STIFFNESS: float = 140.0
const DEFAULT_DAMPING_RATIO: float = 0.6
const MAX_SQUASH: float = 0.6

var part_id: StringName = &"rig"
var parent: ProceduralSquishRig = null
var joint_kind: JointKind = JointKind.SOFT
var rest_position: Vector2 = Vector2.ZERO
var rest_rotation: float = 0.0
var stiffness: float = DEFAULT_STIFFNESS
var damping_ratio: float = DEFAULT_DAMPING_RATIO
var squash: float = 0.35
var body_part: ProceduralBodyPart = null
var field: ProceduralDeformField = null

var _rotation_spring: ProceduralSpring = ProceduralSpring.new(0.0, DEFAULT_STIFFNESS, 0.5)
var _squash_spring: ProceduralSpring = ProceduralSpring.new(1.0, DEFAULT_STIFFNESS, 0.5)
var _joints: Array = []
var _joint_index: Dictionary = {}
var _shape: ProceduralShape = null


func _init(p_part_id: StringName = &"rig") -> void:
	part_id = p_part_id
	_rotation_spring.configure(stiffness, 0.5)
	_squash_spring.configure(stiffness, 0.5)


func attach(joint: ProceduralSquishRig) -> ProceduralSquishRig:
	if joint == null or joint == self or _joint_index.has(joint.part_id):
		return joint
	joint.parent = self
	_joints.append(joint)
	_joint_index[joint.part_id] = joint
	_invalidate()
	return joint


func get_joint(joint_id: StringName) -> ProceduralSquishRig:
	if not _joint_index.has(joint_id):
		return null
	return _joint_index[joint_id]


func get_joints() -> Array:
	return _joints.duplicate()


func joint_count() -> int:
	return _joints.size()


func find_root() -> ProceduralSquishRig:
	var node: ProceduralSquishRig = self
	while node.parent != null:
		node = node.parent
	return node


func rest_pose() -> void:
	_rotation_spring.snap(rest_rotation)
	_squash_spring.snap(1.0)
	for entry: Variant in _joints:
		var joint: ProceduralSquishRig = entry
		joint.rest_pose()
	_invalidate()


# ── 정규 형상 (§0) ───────────────────────────────────────────────────────

## 부모가 먼저 오는 깊이 우선 순서. 정규 형상의 노드 순서가 이것이다.
func ordered_joints() -> Array:
	var out: Array = []
	_collect_ordered(out)
	return out


func _collect_ordered(out: Array) -> void:
	out.append(self)
	for entry: Variant in _joints:
		var joint: ProceduralSquishRig = entry
		joint._collect_ordered(out)


## §6.3. 이 리그의 정규 형상. 복사본이 아니라 그 자체다.
func to_shape() -> ProceduralShape:
	if _shape != null:
		return _shape
	var ordered: Array = ordered_joints()
	var shape: ProceduralShape = ProceduralShape.new(ProceduralShape.Kind.SOFT_CHAIN)
	if not shape.allocate(ordered.size(), ProceduralShape.Kind.SOFT_CHAIN):
		push_error("ProceduralSquishRig.to_shape: capacity refused for %d joints." % ordered.size())
		_shape = shape
		return shape
	var placed: Dictionary = {}
	for entry: Variant in ordered:
		var joint: ProceduralSquishRig = entry
		var index: int = shape.node_count()
		var mode: int = _mode_of(joint)
		var parent_index: int = -1
		var angle: float = 0.0
		var offset: Vector2 = joint.rest_position
		if joint.parent != null and placed.has(joint.parent.part_id):
			parent_index = int(placed[joint.parent.part_id])
			# §4.3. offset 은 부모 프레임의 로컬 벡터다.
			offset = joint.rest_position.rotated(-_accumulated_rotation(joint.parent))
			angle = joint.rest_rotation
		else:
			angle = joint.rest_rotation
			# 부모가 없는 관절은 attached 일 수 없다. (§4.5)
			mode = ProceduralShape.AnchorMode.FREE
		if not shape.add_rig_joint(index, mode, parent_index, offset, angle, 0.0, joint.part_id):
			return shape
		shape.span[index] = 0.0
		shape.radius[index] = joint.body_part.max_radius() if joint.body_part != null else 0.0
		placed[joint.part_id] = index
	if not shape.finalize():
		return shape
	shape.configure(_root_stiffness(), _root_damping(), 0.0, Vector2.ZERO)
	for entry: Variant in ordered:
		var joint: ProceduralSquishRig = entry
		var node: int = int(placed[joint.part_id])
		shape.set_node_stiffness(node, joint.stiffness, joint.damping_ratio)
	_shape = shape
	return _shape


## 부모 체인을 따라 누적 회전을 합친다. offset 을 부모 프레임으로 되돌릴 때 쓴다.
func _accumulated_rotation(joint: ProceduralSquishRig) -> float:
	var total: float = 0.0
	var node: ProceduralSquishRig = joint
	while node != null:
		total += node.rest_rotation
		node = node.parent
	return total


func _mode_of(joint: ProceduralSquishRig) -> int:
	match joint.joint_kind:
		JointKind.RIGID:
			return ProceduralShape.AnchorMode.PINNED
		JointKind.PINNED:
			return ProceduralShape.AnchorMode.PINNED
		_:
			return ProceduralShape.AnchorMode.ATTACHED


func _root_stiffness() -> float:
	var node: ProceduralSquishRig = self
	while node.parent != null:
		node = node.parent
	return node.stiffness


func _root_damping() -> float:
	var node: ProceduralSquishRig = self
	while node.parent != null:
		node = node.parent
	return node.damping_ratio


func _invalidate() -> void:
	_shape = null
	if parent != null:
		parent._invalidate()


# ── 정규 형상의 읽기 ─────────────────────────────────────────────────────

func node_index_of(joint_id: StringName) -> int:
	var shape: ProceduralShape = to_shape()
	if shape == null:
		return -1
	for index: int in shape.node_count():
		if shape.node_id_at(index) == joint_id:
			return index
	return -1


func get_position() -> Vector2:
	var found: int = node_index_of(part_id)
	if found < 0 or _shape == null:
		return rest_position
	return _shape.get_points()[found]


## §4.4. 정규 형상의 현재 좌표가 유일한 정보다. 관절별로 값을 따로 들지 않는다.
func get_position_at(joint_id: StringName) -> Vector2:
	var index: int = node_index_of(joint_id)
	if index < 0:
		return rest_position
	return to_shape().get_points()[index]


func get_rotation() -> float:
	return _rotation_spring.value


func get_scale() -> float:
	return _squash_spring.value


## §5 단계 3 + 4. 위임한다. 이 클래스 안에 두 번째 물리 루프가 없다.
func step(delta: float) -> void:
	if _shape == null:
		to_shape()
	if _shape != null:
		_shape.step(delta)
	_rotation_spring.step(delta)
	_squash_spring.step(delta)


## §5 단계 2. 관절 하나와 그 아래 전부에 속도 임펄스를 준다.
func disturb(impulse: Vector2, local_point: Vector2 = Vector2.ZERO) -> void:
	var shape: ProceduralShape = to_shape()
	if shape == null:
		return
	var start: int = node_index_of(part_id)
	if start < 0:
		return
	var root: Vector2 = shape.get_points()[start]
	for index: int in shape.node_count():
		var node: int = index
		if not _is_descendant_of(node, start):
			continue
		var falloff: float = 1.0 - clampf(shape.get_points()[node].distance_to(root + local_point) / maxf(local_point.length(), 1.0), 0.0, 1.0)
		shape.kick_node(node, impulse * maxf(falloff, 0.0))


func _is_descendant_of(node_index: int, ancestor_index: int) -> bool:
	var shape: ProceduralShape = to_shape()
	var cursor: int = node_index
	var guard: int = 0
	while cursor >= 0 and guard <= shape.node_count():
		guard += 1
		if cursor == ancestor_index:
			return true
		cursor = shape.anchor_parent[cursor]
	return false


## §2.4. bake 를 요구했을 때 정적이어야 한다. 리그는 보통 bake 대상이 아니다.
func is_bakeable() -> bool:
	return _shape != null and _shape.is_bakeable()


## 부드러운 파트를 관절 변환으로 그린다. bake 가 아니라 매 프레임 경로다.
func draw(_canvas: ProceduralCanvas, _palette: ProceduralPalette) -> void:
	# 정품 그리기는 Kit 의 presentation 층이 정규 형상에서 직접 한다.
	# (§2.1 — 렌더 데이터는 points 를 그대로 읽는다. 엔진이 대신 그리지 않는다.)
	if _shape != null and not _shape.is_bakeable():
		return
