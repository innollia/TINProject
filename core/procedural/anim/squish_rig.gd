class_name ProceduralSquishRig
extends RefCounted

# PURPOSE: cutout joints plus mesh deformation in one rig. Every joint is one
# node of the rig's single canonical shape (ProceduralShape), so its position
# spring lives there. A joint's rotation and squash are READ from how its bone
# moved in that shape; they are not a second set of springs. An optional
# ProceduralDeformField per joint warps the soft part it draws.
# OWNER: PVE. EXISTING SIGNATURES ARE FROZEN.
# 정본: core/procedural/DESIGN_DECISION.md §0, §4.2, §4.8, §6.3
#
# 이 클래스는 관절 그래프다. 리그 전체가 정규 형상 **하나**를 가진다 — 루트가 만들고,
# 어느 관절에서 to_shape() 를 불러도 그 하나가 나온다. 스프링 집합이 둘이면 §0 이 깨진다.
#
# 좌표 규약
#   rest_position  부모 관절 프레임의 로컬 위치(px). 루트는 리그 공간 위치다.
#   rest_rotation  부모 대비 회전, 라디안. get_rotation() 과 같은 단위다.
#   리그 공간 = draw() 가 칠하는 캔버스의 픽셀 공간이다. Kit 이 루트 rest_position 을 정한다.
#
# JointKind (§4.2 의 세 앵커와 대응)
#   SOFT    attached. 부모의 현재 위치를 스프링으로 따라간다. 늦고 출렁인다.
#   RIGID   부모의 현재 위치를 그대로 따라간다. 지연도 변형도 없다.
#   PINNED  리그 공간에 박혀 움직이지 않는다.
#   루트는 부모가 없다. SOFT 루트는 free(자기 rest 로 돌아옴), 그 외는 pinned 이다.
#   §4.8 — soft 자식은 부모의 이동을 상속하고 회전은 상속하지 않는다. RIGID 도 같다.
#
# 읽기
#   관절의 뼈 = 부모 → 관절. 루트는 자식들로 가는 뼈들의 평균이다.
#   get_rotation()  rest_rotation + (내 뼈가 돈 각도 − 부모 뼈가 돈 각도)
#   get_scale()     뼈 길이 / 정지 길이. 1 = 정지. squash 한도(squash, MAX_SQUASH) 안으로 자른다.
#   움직임의 원천은 disturb() 의 임펄스와 정규 형상의 force(바람) 뿐이다. 트윈이 없다.
#
# 한 프레임: disturb(...) → step(delta) → draw(canvas, palette). step() 은 그래프 전체를
# 한 번 적분하므로 프레임마다 한 관절(보통 루트)에서만 부른다.

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
## 이 관절이 찌그러질 수 있는 한도. 0 이면 찌그러지지 않는다. MAX_SQUASH 를 넘지 않는다.
var squash: float = 0.35
var body_part: ProceduralBodyPart = null
var field: ProceduralDeformField = null

var _joints: Array = []
var _joint_index: Dictionary = {}
## 루트만 채운다. 리그 전체의 정규 형상.
var _shape: ProceduralShape = null
## 루트만 채운다. RIGID 관절의 노드 번호. 부모가 먼저 온다.
var _rigid_nodes: PackedInt32Array = PackedInt32Array()


func _init(p_part_id: StringName = &"rig") -> void:
	part_id = p_part_id


func attach(joint: ProceduralSquishRig) -> ProceduralSquishRig:
	if joint == null or joint == self or _joint_index.has(joint.part_id):
		return joint
	var cursor: ProceduralSquishRig = self
	while cursor != null:
		if cursor == joint:
			push_error("ProceduralSquishRig.attach: '%s' is an ancestor of '%s'. A rig is a tree." % [joint.part_id, part_id])
			return joint
		cursor = cursor.parent
	if joint.parent != null:
		push_error("ProceduralSquishRig.attach: '%s' already hangs from '%s'." % [joint.part_id, joint.parent.part_id])
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


## 리그 전체를 정지 자세로 되돌린다. 정규 형상의 reset() 이 points 를 새 배열로 바꾸므로
## 이 뒤에는 get_points() 를 다시 읽는다.
func rest_pose() -> void:
	var root: ProceduralSquishRig = find_root()
	if root._shape != null:
		root._shape.reset()


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


## §6.3. 이 리그의 정규 형상. 복사본이 아니라 그 자체다. 어느 관절에서 불러도
## 루트가 만든 하나가 나온다. 노드 순서는 루트의 ordered_joints() 다.
func to_shape() -> ProceduralShape:
	var root: ProceduralSquishRig = find_root()
	if root != self:
		return root.to_shape()
	if _shape != null:
		return _shape
	var ordered: Array = ordered_joints()
	var built: ProceduralShape = ProceduralShape.new(ProceduralShape.Kind.SOFT_CHAIN)
	if not built.allocate(ordered.size(), ProceduralShape.Kind.SOFT_CHAIN):
		push_error("ProceduralSquishRig.to_shape: capacity refused for %d joints." % ordered.size())
		return null
	var placed: Dictionary = {}
	var rigid: PackedInt32Array = PackedInt32Array()
	for entry: Variant in ordered:
		var joint: ProceduralSquishRig = entry
		var index: int = built.node_count()
		var parent_index: int = int(placed.get(joint.parent, -1)) if joint.parent != null else -1
		var mode: int = _mode_of(joint)
		if parent_index < 0:
			# 부모가 없는 관절은 attached 일 수 없다. (§4.5)
			mode = ProceduralShape.AnchorMode.FREE if joint.joint_kind == JointKind.SOFT else ProceduralShape.AnchorMode.PINNED
		if not built.add_rig_joint(index, mode, parent_index, joint.rest_position, rad_to_deg(joint.rest_rotation), 0.0, joint.part_id):
			return null
		if parent_index >= 0 and mode != ProceduralShape.AnchorMode.ATTACHED:
			# pinned / rigid 관절도 트리 간선은 남긴다. 정지 좌표, links, 하위 트리 판정이 이것을 읽는다.
			built.anchor_parent[index] = parent_index
			if joint.joint_kind == JointKind.RIGID:
				rigid.append(index)
		var part: ProceduralBodyPart = joint.body_part
		built.radius[index] = part.max_radius() * maxf(part.scale, 0.0001) if part != null else 0.0
		placed[joint] = index
	if not built.finalize():
		return null
	built.configure(_root_stiffness(), _root_damping(), 0.0, Vector2.ZERO)
	for index: int in ordered.size():
		var joint: ProceduralSquishRig = ordered[index]
		built.set_node_stiffness(index, joint.stiffness, joint.damping_ratio)
	_shape = built
	_rigid_nodes = rigid
	return _shape


## 부모 체인을 따라 누적 회전(라디안)을 합친다. 관절의 정지 월드 방향이다.
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
	_rigid_nodes = PackedInt32Array()
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


## 이 관절의 현재 위치. 리그 공간.
func get_position() -> Vector2:
	return get_position_at(part_id)


## §4.4. 정규 형상의 현재 좌표가 유일한 정보다. 관절별로 값을 따로 들지 않는다.
func get_position_at(joint_id: StringName) -> Vector2:
	var index: int = node_index_of(joint_id)
	if index < 0:
		return rest_position
	return to_shape().get_points()[index]


## 부모 대비 회전(라디안). rest_rotation 에 뼈가 돈 만큼을 더한다.
func get_rotation() -> float:
	var shape: ProceduralShape = to_shape()
	var node: int = node_index_of(part_id)
	if shape == null or node < 0:
		return rest_rotation
	var turned: float = _bone_reading(shape, node).x
	if parent != null:
		var parent_node: int = node_index_of(parent.part_id)
		if parent_node >= 0:
			turned -= _bone_reading(shape, parent_node).x
	return rest_rotation + turned


## 뼈 방향의 크기 배율. 1 = 정지, 1 보다 작으면 찌그러졌고 크면 늘어났다.
## 가로 방향은 부피 보존으로 1 / get_scale() 이다.
func get_scale() -> float:
	var shape: ProceduralShape = to_shape()
	var node: int = node_index_of(part_id)
	if shape == null or node < 0:
		return 1.0
	return 1.0 - _squash_of(self, _bone_reading(shape, node).y)


## Integrates the whole graph from the root, children inheriting their parent's
## current position (§5 단계 4). The physics lives in the one canonical shape;
## RIGID joints are then placed exactly on their parent.
func step(delta: float) -> void:
	var root: ProceduralSquishRig = find_root()
	var shape: ProceduralShape = root.to_shape()
	if shape == null or delta <= 0.0:
		return
	root._follow_rigid(shape)
	shape.step(delta)
	root._follow_rigid(shape)


## §5 단계 2. 관절 하나와 그 아래 전부에 속도 임펄스를 준다. local_point 는 이
## 관절의 정지 프레임에서 임펄스가 닿은 지점이다. 닿은 곳에 가장 가까운 관절이
## 임펄스를 전부 받고, 멀수록 덜 받는다. 하위 트리 밖은 받지 않는다.
func disturb(impulse: Vector2, local_point: Vector2 = Vector2.ZERO) -> void:
	var shape: ProceduralShape = to_shape()
	if shape == null:
		return
	var start: int = node_index_of(part_id)
	if start < 0:
		return
	var points: PackedVector2Array = shape.get_points()
	var contact: Vector2 = points[start] + local_point.rotated(_accumulated_rotation(self))
	var members: PackedInt32Array = PackedInt32Array()
	var reach: PackedFloat32Array = PackedFloat32Array()
	var nearest: float = INF
	var farthest: float = 0.0
	var pad: float = 1.0
	for index: int in shape.node_count():
		if not _is_descendant_of(index, start):
			continue
		var distance: float = points[index].distance_to(contact)
		members.append(index)
		reach.append(distance)
		nearest = minf(nearest, distance)
		farthest = maxf(farthest, distance)
		pad = maxf(pad, shape.radius[index])
	var spread: float = farthest - nearest + pad
	for slot: int in members.size():
		var weight: float = 1.0 - (reach[slot] - nearest) / spread
		shape.kick_node(members[slot], impulse * weight)


func _is_descendant_of(node_index: int, ancestor_index: int) -> bool:
	var shape: ProceduralShape = to_shape()
	if shape == null:
		return false
	var cursor: int = node_index
	var guard: int = 0
	while cursor >= 0 and guard <= shape.node_count():
		guard += 1
		if cursor == ancestor_index:
			return true
		cursor = shape.anchor_parent[cursor]
	return false


## §2.4. bake 를 요구했을 때 정적이어야 한다. 리그는 soft 라 bake 대상이 아니다.
func is_bakeable() -> bool:
	var shape: ProceduralShape = find_root()._shape
	return shape != null and shape.is_bakeable()


## Draws every joint's body_part through that joint's current transform, parents
## first. The joint transform comes from the canonical shape only:
##   origin  = the joint's current point (+ body_part.anchor_offset in that frame)
##   rotation = rest rotation of the chain + how far the joint's bone turned
##              (+ body_part.angle, degrees)
##   squash  = how much the bone shortened, clamped to the joint's squash limit,
##             applied along the bone's current direction (non uniform, area kept)
## A joint's `field` warps its part (see ProceduralBodyPart.draw "deform").
## Rig space is the canvas pixel space. Cost is one SDF pass per part per call;
## call it when the rig moved, into a canvas no larger than the figure.
func draw(_canvas: ProceduralCanvas, _palette: ProceduralPalette) -> void:
	if _canvas == null or _palette == null:
		push_error("ProceduralSquishRig.draw: canvas and palette are required.")
		return
	var root: ProceduralSquishRig = find_root()
	var shape: ProceduralShape = root.to_shape()
	if shape == null:
		return
	var ordered: Array = root.ordered_joints()
	var points: PackedVector2Array = shape.get_points()
	for node: int in ordered.size():
		var joint: ProceduralSquishRig = ordered[node]
		var part: ProceduralBodyPart = joint.body_part
		if part == null:
			continue
		var reading: Vector3 = _bone_reading(shape, node)
		var rotation: float = _accumulated_rotation(joint) + reading.x
		var pose: Dictionary = {
			"origin": points[node] + part.anchor_offset.rotated(rotation),
			"rotation": rotation + deg_to_rad(part.angle),
			"scale": part.scale,
			"squash": _squash_of(joint, reading.y),
			"squash_axis": reading.z,
		}
		if joint.field != null:
			pose["deform"] = joint.field
		part.draw(_canvas, _palette, pose)


# ── 내부 ─────────────────────────────────────────────────────────────────

## RIGID 관절을 부모의 현재 위치 + 정지 오프셋에 놓는다. 부모가 먼저 오므로 한 번으로 끝난다.
## 정규 배열(shape.points)에 직접 쓴다. 사본에 쓰면 화면과 물리가 갈라진다.
func _follow_rigid(shape: ProceduralShape) -> void:
	for node: int in _rigid_nodes:
		var parent_node: int = shape.anchor_parent[node]
		shape.points[node] = shape.points[parent_node] + shape.anchor_offset[node].rotated(shape.get_rest_dir(parent_node).angle())


## 관절 뼈의 읽기. x = 월드 회전 변화(라디안), y = 찌그러짐(1 − 현재 길이 / 정지 길이),
## z = 찌그러짐 축(현재 뼈 방향, 라디안). 루트는 자식 뼈들의 평균이며, 축은 방향이
## 반대인 뼈끼리 상쇄되지 않도록 두 배 각도로 평균낸다.
func _bone_reading(shape: ProceduralShape, node: int) -> Vector3:
	var rest: PackedVector2Array = shape.get_rest()
	var points: PackedVector2Array = shape.get_points()
	var bones: Array[Vector2i] = []
	var parent_node: int = shape.anchor_parent[node]
	if parent_node >= 0:
		bones.append(Vector2i(parent_node, node))
	else:
		for index: int in shape.node_count():
			if shape.anchor_parent[index] == node:
				bones.append(Vector2i(node, index))
	var turned: float = 0.0
	var squeezed: float = 0.0
	var axis_x: float = 0.0
	var axis_y: float = 0.0
	var counted: int = 0
	for bone: Vector2i in bones:
		var rest_bone: Vector2 = rest[bone.y] - rest[bone.x]
		var live_bone: Vector2 = points[bone.y] - points[bone.x]
		var rest_length: float = rest_bone.length()
		if rest_length < 0.0001:
			continue
		var live_length: float = live_bone.length()
		var amount: float = 1.0 - live_length / rest_length
		var heading: float = live_bone.angle() if live_length > 0.000001 else rest_bone.angle()
		if live_length > 0.000001:
			turned += rest_bone.angle_to(live_bone)
		var weight: float = absf(amount) + 0.000001
		axis_x += cos(heading * 2.0) * weight
		axis_y += sin(heading * 2.0) * weight
		squeezed += amount
		counted += 1
	if counted == 0:
		return Vector3(0.0, 0.0, shape.get_rest_dir(node).angle())
	return Vector3(turned / float(counted), squeezed / float(counted), atan2(axis_y, axis_x) * 0.5)


## 관절의 squash 한도 안으로 자른 찌그러짐.
static func _squash_of(joint: ProceduralSquishRig, amount: float) -> float:
	var limit: float = clampf(joint.squash, 0.0, MAX_SQUASH)
	return clampf(amount, -limit, limit)
