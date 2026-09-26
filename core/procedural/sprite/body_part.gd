class_name ProceduralBodyPart
extends RefCounted

# PURPOSE: one authored part of a rigid object. A part is a procedural
# silhouette described by data, never by pixels. This class is both the spec
# container and the local geometry source for the bake path.
# OWNER: PVE. EXISTING SIGNATURES ARE FROZEN.
# 정본: core/procedural/DESIGN_DECISION.md §1.2, §6.3
#
# LOCAL POSE CONVENTION
#   origin  파트의 관절(붙는 지점). 정규 형상의 노드 위치와 같다. 로컬 (0, 0).
#   axis    성장 방향 = 로컬 +X. length 는 이 축을 따라 잰다.
#   across  로컬 +Y. base_radius / tip_radius 는 이 방향의 전체 굵기다.
#           radius_at() 과 max_radius() 가 그 절반(반지름)을 돌려준다.
#   bend    끝으로 갈수록 축이 도는 각도(도). wiggle 은 축을 옆으로 S 자로 휜다.
#           둘 다 정지 형상의 모양이다. 시간이 들어가지 않으므로 움직임이 아니다.
#   pose    draw() 의 pose 가 이 로컬 좌표를 캔버스 픽셀로 옮긴다.
#             canvas = origin + squash_along(squash_axis) * R(rotation) * (local * scale)
#           rotation 과 squash_axis 는 라디안이다. squash 는 부피 보존 비균등 축약이다:
#           축 방향 (1 - s), 가로 방향 1 / (1 - s).
#   bounds() 와 draw() 는 같은 기하(_geometry)와 같은 여백을 읽는다. identity pose
#   에서 draw() 가 칠하는 픽셀은 bounds() 밖으로 나가지 않는다.
#
# 형상은 다섯 개의 숫자와 segments 에서만 나온다. Kind 는 기하에 영향이 없는
# 메타데이터이며 추가하지 않는다. (§7-1)
# 색은 팔레트 역할로만 온다. 음영 색은 두 역할을 섞은 것이지 새 RGB 가 아니다.

enum Kind { LIMB, TORSO, HEAD, EYE, TAIL, FIN, FOLD, CAP }
enum Joint { NONE, ROOT, MIDDLE, TIP }
enum Shade { FLAT, VOLUMETRIC, RIM, INK }

## §1.2. 파트 하나가 여러 노드를 가지는 경우. soft_chain 필요분이며 요구사항이다.
enum SegmentKind { CAPSULE, TRIANGLE, BOX }

const KIND_NAMES: Dictionary = {
	Kind.LIMB: &"limb",
	Kind.TORSO: &"torso",
	Kind.HEAD: &"head",
	Kind.EYE: &"eye",
	Kind.TAIL: &"tail",
	Kind.FIN: &"fin",
	Kind.FOLD: &"fold",
	Kind.CAP: &"cap",
}

const JOINT_NAMES: Dictionary = {
	Joint.NONE: &"none",
	Joint.ROOT: &"root",
	Joint.MIDDLE: &"middle",
	Joint.TIP: &"tip",
}

const SHADE_NAMES: Dictionary = {
	Shade.FLAT: &"flat",
	Shade.VOLUMETRIC: &"volumetric",
	Shade.RIM: &"rim",
	Shade.INK: &"ink",
}

const SEGMENT_NAMES: Dictionary = {
	SegmentKind.CAPSULE: &"capsule",
	SegmentKind.TRIANGLE: &"triangle",
	SegmentKind.BOX: &"box",
}

const DEFAULT_LENGTH: float = 12.0
const DEFAULT_BASE_RADIUS: float = 4.0
const DEFAULT_TIP_RADIUS: float = 2.0
## §2.2 bake 시 파트를 잇는 융합 폭. 선 두께 2px 이상 금지는 Kit 층의 규칙이다.
const DEFAULT_FUSION: float = 1.5

## 휜 파트(bend / wiggle)를 캡슐로 접을 때 파트 전체의 분할 수. 곧은 파트는 1.
const _CURVE_STEPS: int = 8
## 캔버스 좌표계에서 빛이 오는 방향. 왼쪽 위. 파트가 돌아도 빛은 돌지 않는다.
const _LIGHT_DIRECTION: Vector2 = Vector2(-0.70710678, -0.70710678)
## 그림자 초승달의 깊이. 파트 반지름(캔버스 px) 대비.
const _SHADE_DEPTH: float = 0.5
## 몸 역할 색과 음영 / 하이라이트 역할 색을 섞는 비율.
const _SHADE_MIX: float = 0.55
const _HIGHLIGHT_MIX: float = 0.45
## ProceduralSdf.coverage(d, 1.0) 이 0 이 되는 바깥 거리. 칠이 실루엣 밖으로 번지는 폭.
const _EDGE_MARGIN: float = 0.5
## INK 선 굵기(px).
const _INK_WIDTH: float = 1.0
## 거리 버퍼 밖을 읽을 때의 값. 충분히 먼 바깥.
const _FAR: float = 1.0e6
## _paint_distance() 의 층 종류.
const _LAYER_FILL: int = 0
const _LAYER_CRESCENT: int = 1
const _LAYER_STROKE: int = 2

var id: StringName = &"part"
var kind: Kind = Kind.LIMB
var joint: Joint = Joint.ROOT
var shade: Shade = Shade.VOLUMETRIC
var length: float = DEFAULT_LENGTH
var base_radius: float = DEFAULT_BASE_RADIUS
var tip_radius: float = DEFAULT_TIP_RADIUS
var bend: float = 0.0
var wiggle: float = 0.0
var body_role: StringName = ProceduralPalette.ROLE_BODY
var shade_role: StringName = ProceduralPalette.ROLE_SHADE
var rim_role: StringName = ProceduralPalette.ROLE_RIM
## Which rig joint drives this part. Empty means the part is static.
var joint_id: StringName = &""

## ── §1.2 핵심 확장. 부착 지점을 3칸에서 연속으로. ────────────────────────
## 부모 길이 대비 부착 지점 0~1. 구형 Joint 3칸의 상위 호환이다. (§7-2)
var at: float = 1.0
## 부모 프레임 기준 회전(도).
var angle: float = 0.0
## 부모 대비 배수.
var scale: float = 1.0
## ProceduralShape.AnchorMode 값. ATTACHED / PINNED / FREE.
var anchor_mode: int = ProceduralShape.AnchorMode.ATTACHED
## 부모 파트의 인덱스. -1 이면 직전 파트. (§4.3, §4.5)
var anchor_parent: int = -1
## 부모 프레임의 로컬 오프셋(px).
var anchor_offset: Vector2 = Vector2.ZERO
## 파트를 여러 세그먼트로 접는다. 항목의 "kind" 가 그 세그먼트의 도형을 고른다.
var segments: Array[Dictionary] = []
var fusion: float = DEFAULT_FUSION

## 기하 캐시. 기하에 영향을 주는 값이 바뀌면 다시 만든다.
var _geo_key: Array = []
var _geo: Array = []


func _init(p_id: StringName = &"part", p_kind: Kind = Kind.LIMB) -> void:
	id = p_id
	kind = p_kind


## Accepts enum ints or the names in KIND_NAMES / JOINT_NAMES / SHADE_NAMES,
## as StringName or as String (JSON). Unknown keys keep the current value, so a
## partial spec is legal.
func configure(spec: Dictionary) -> void:
	if spec.has("id"):
		id = StringName(spec["id"])
	if spec.has("kind"):
		kind = _enum_value(spec["kind"], KIND_NAMES, Kind.LIMB)
	if spec.has("joint"):
		joint = _enum_value(spec["joint"], JOINT_NAMES, Joint.ROOT)
	if spec.has("shade"):
		shade = _enum_value(spec["shade"], SHADE_NAMES, Shade.VOLUMETRIC)
	if spec.has("length"):
		length = float(spec["length"])
	if spec.has("base_radius"):
		base_radius = float(spec["base_radius"])
	if spec.has("tip_radius"):
		tip_radius = float(spec["tip_radius"])
	if spec.has("bend"):
		bend = float(spec["bend"])
	if spec.has("wiggle"):
		wiggle = float(spec["wiggle"])
	if spec.has("body_role"):
		body_role = StringName(spec["body_role"])
	if spec.has("shade_role"):
		shade_role = StringName(spec["shade_role"])
	if spec.has("rim_role"):
		rim_role = StringName(spec["rim_role"])
	if spec.has("joint_id"):
		joint_id = StringName(spec["joint_id"])
	# ── §1.2 추가분 ──
	if spec.has("at"):
		at = clampf(float(spec["at"]), 0.0, 1.0)
	if spec.has("angle"):
		angle = float(spec["angle"])
	if spec.has("scale"):
		scale = maxf(float(spec["scale"]), 0.0001)
	if spec.has("fusion"):
		fusion = maxf(float(spec["fusion"]), 0.0)
	if spec.has("anchor"):
		_configure_anchor(spec["anchor"])
	if spec.has("segments"):
		segments.clear()
		for entry: Variant in (spec["segments"] as Array):
			segments.append(entry as Dictionary)
	# §7-2. 구형 joint 3칸 → at 연속. at 이 명시되면 그것이 우선이다.
	if not spec.has("at") and spec.has("joint"):
		at = joint_to_at(get_joint_name())


## §1.2. anchor 객체. §4.3 과 같은 키를 쓴다.
func _configure_anchor(raw: Variant) -> void:
	if not (raw is Dictionary):
		return
	var anchor: Dictionary = raw
	if anchor.has("mode"):
		anchor_mode = ProceduralShape.mode_from_name(StringName(anchor["mode"]))
	if anchor.has("parent"):
		anchor_parent = int(anchor["parent"])
	if anchor.has("at"):
		at = clampf(float(anchor["at"]), 0.0, 1.0)
	if anchor.has("offset"):
		var pair: Variant = anchor["offset"]
		if pair is Array and (pair as Array).size() >= 2:
			anchor_offset = Vector2(float(pair[0]), float(pair[1]))
		elif pair is Vector2:
			anchor_offset = pair
	if anchor.has("angle"):
		angle = float(anchor["angle"])


## 정지 관절 좌표들. 원점(0, 0)에서 시작해 세그먼트마다 하나씩, 끝점으로 끝난다.
## 로컬 +X 가 성장 방향이다. bend / wiggle 이 있으면 관절도 곡선 위에 놓인다.
func rest_joints() -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	out.append(Vector2.ZERO)
	var steps: int = segment_count()
	for step_index: int in steps:
		out.append(_joint_at(float(step_index + 1) / float(steps)))
	return out


## 축 위 t(0~1) 지점. bend 는 끝으로 갈수록 축을 돌리고, wiggle 은 축을 옆으로
## S 자로 휜다. 둘 다 원점에서 0 이고 정지 형상의 모양일 뿐 시간의 함수가 아니다.
func _joint_at(t: float) -> Vector2:
	var curve: float = clampf(t, 0.0, 1.0)
	var along: float = length * curve
	var turned: float = deg_to_rad(bend) * curve
	var wave: float = sin(curve * TAU) * wiggle * length * 0.25
	var base: Vector2 = Vector2(along, wave)
	return base.rotated(turned)


## 세그먼트 끝점(관절) 목록. 원점을 포함한다. rest_joints() 와 같은 열이다.
func segment_endpoints() -> PackedVector2Array:
	return rest_joints()


func max_radius() -> float:
	return maxf(base_radius, tip_radius) * 0.5


## 로컬 +X 방향. 정규 형상의 rest_dir 와 같은 규약.
func axis() -> Vector2:
	return Vector2.RIGHT


## Segments(구체). 기본은 1개.
func segment_count() -> int:
	return maxi(segments.size(), 1)


func segment_kind(index: int) -> int:
	if index < 0 or index >= segments.size():
		return SegmentKind.CAPSULE
	return segment_kind_from_name(StringName(segments[index].get("kind", "capsule")))


## t 위치에서의 반지름. base_radius → tip_radius 를 선형으로 보간한 굵기의 절반.
func radius_at(t: float) -> float:
	var curve: float = clampf(t, 0.0, 1.0)
	return lerpf(base_radius, tip_radius, curve) * 0.5


## 이 파트의 실루엣 거리장. 로컬 좌표계, 로컬 단위(px). 음수 = 내부.
## ProceduralSdf 도형과 smooth_min 만 쓰므로 bake 결과는 수학의 결과다.
func field_at(point: Vector2) -> float:
	return _distance(_geometry(), point)


## 두 끝 반지름이 다른 캡슐의 정확한 거리. (uneven capsule)
## 한 원이 다른 원을 삼키면 두 원의 합집합으로 떨어진다.
func _tapered_capsule(
	point: Vector2, from_joint: Vector2, to_joint: Vector2, start_radius: float, end_radius: float
) -> float:
	var axis_vector: Vector2 = to_joint - from_joint
	var span: float = axis_vector.length()
	if span < 0.000001:
		return point.distance_to(from_joint) - maxf(start_radius, end_radius)
	if absf(start_radius - end_radius) >= span:
		return minf(point.distance_to(from_joint) - start_radius, point.distance_to(to_joint) - end_radius)
	var direction: Vector2 = axis_vector / span
	var relative: Vector2 = point - from_joint
	var local: Vector2 = Vector2(absf(_cross(direction, relative)), relative.dot(direction))
	var slope: float = (start_radius - end_radius) / span
	var rise: float = sqrt(1.0 - slope * slope)
	var side: float = local.dot(Vector2(-slope, rise))
	if side < 0.0:
		return local.length() - start_radius
	if side > rise * span:
		return (local - Vector2(0.0, span)).length() - end_radius
	return local.dot(Vector2(rise, slope)) - start_radius


func _fuse(current: float, incoming: float, blend: float) -> float:
	if blend <= 0.0:
		return minf(current, incoming)
	return ProceduralSdf.smooth_min(current, incoming, blend)


static func _cross(a: Vector2, b: Vector2) -> float:
	return a.x * b.y - a.y * b.x


## Local bounds that agree with draw() exactly: the rect, in this part's local
## pixels, that draw() paints into at the identity pose. Silhouette extent plus
## the smooth_min bulge plus the antialias (and INK line) margin.
func bounds() -> Rect2:
	var extent: Rect2 = _silhouette_extent(_geometry())
	return extent.grow(_paint_margin())


## Paints the part into `canvas`. `pose` carries the transform for this draw:
##   "origin": Vector2   canvas px of the part's joint (local 0, 0)
##   "rotation": float   radians, local +X → canvas
##   "scale": float      uniform scale
##   "squash": float     -MAX_SQUASH_LOCAL..MAX_SQUASH_LOCAL. + = squashed along the axis
##   "squash_axis": float  radians, canvas direction of the squash. Default = rotation
##   "deform": ProceduralDeformField  optional. Its bounds are read in this part's
##                        local frame; the silhouette is displaced by its offsets.
## Origin is the part's own joint, axis is local +X. Same convention as bounds().
## Shading is cel style from palette roles only: fill (body_role), a shade
## crescent away from the light (body_role mixed toward shade_role), a lit edge
## (key light or rim_role), or a 1 px ink line, depending on `shade`.
func draw(canvas: ProceduralCanvas, palette: ProceduralPalette, pose: Dictionary = {}) -> void:
	if canvas == null or palette == null:
		push_error("ProceduralBodyPart.draw: canvas and palette are required.")
		return
	var origin: Vector2 = _pose_vector(pose.get("origin", Vector2.ZERO))
	var rotation: float = float(pose.get("rotation", 0.0))
	var scale_factor: float = maxf(float(pose.get("scale", 1.0)), 0.0001)
	var squash: float = clampf(float(pose.get("squash", 0.0)), -MAX_SQUASH_LOCAL, MAX_SQUASH_LOCAL)
	var squash_axis: float = float(pose.get("squash_axis", rotation))
	var deform: ProceduralDeformField = pose.get("deform", null) as ProceduralDeformField
	var along_scale: float = 1.0 - squash
	var across_scale: float = 1.0 / along_scale
	var forward: Transform2D = Transform2D(0.0, origin) \
		* _squash_basis(squash_axis, along_scale, across_scale) \
		* Transform2D(rotation, Vector2.ZERO) \
		* Transform2D(Vector2(scale_factor, 0.0), Vector2(0.0, scale_factor), Vector2.ZERO)
	var inverse: Transform2D = forward.affine_inverse()
	var distance_scale: float = scale_factor * minf(along_scale, across_scale)
	var geometry: Array = _geometry()
	var extent: Rect2 = _silhouette_extent(geometry)
	if deform != null:
		extent = extent.merge(_deform_extent(deform, extent))
	var depth: float = _SHADE_DEPTH * max_radius() * distance_scale
	var region: Rect2i = _buffer_region(forward, extent, _paint_margin(), depth, canvas)
	if region.size.x <= 0 or region.size.y <= 0:
		return
	var distance: PackedFloat32Array = PackedFloat32Array()
	distance.resize(region.size.x * region.size.y)
	var cursor: int = 0
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			var local: Vector2 = inverse * Vector2(float(x) + 0.5, float(y) + 0.5)
			if deform != null:
				local = _warp(local, deform)
			distance[cursor] = _distance(geometry, local) * distance_scale
			cursor += 1
	var layers: Array = _layers_for(palette, body_role, shade_role, rim_role, shade, depth, true)
	_paint_distance(canvas, distance, region, region.intersection(Rect2i(0, 0, canvas.width, canvas.height)), layers)


const MAX_SQUASH_LOCAL: float = 0.6


## identity 를 제외한 pose 를 캔버스 → 로컬 거리장으로 감싼다. 한 점씩 부를 때 쓴다.
## draw() 는 같은 변환을 버퍼에 한 번에 푼다.
func _field_transformed(origin: Vector2, rotation: float, along_scale: float, across_scale: float) -> Callable:
	var forward: Transform2D = Transform2D(0.0, origin) \
		* _squash_basis(rotation, along_scale, across_scale) \
		* Transform2D(rotation, Vector2.ZERO)
	var inverse: Transform2D = forward.affine_inverse()
	var distance_scale: float = minf(along_scale, across_scale)
	var geometry: Array = _geometry()
	return func(p: Vector2) -> float:
		return _distance(geometry, inverse * p) * distance_scale


## 로컬 사각형 span 을 origin / rotation 으로 옮긴 캔버스 픽셀 사각형. 캔버스로 자른다.
func _to_canvas_rect(span: Rect2, origin: Vector2, rotation: float, canvas: ProceduralCanvas) -> Rect2i:
	var turn: Transform2D = Transform2D(rotation, origin)
	var box: Rect2 = _transformed_rect(turn, span)
	var left: int = maxi(floori(box.position.x), 0)
	var top: int = maxi(floori(box.position.y), 0)
	var right: int = mini(ceili(box.end.x), canvas.width)
	var bottom: int = mini(ceili(box.end.y), canvas.height)
	return Rect2i(left, top, maxi(right - left, 0), maxi(bottom - top, 0))


## 이 파트를 정규 형상 노드 한 개로 본다. (§6.3)
func joint_anchor_spec() -> Dictionary:
	return {
		"at": at,
		"angle": angle,
		"offset": [anchor_offset.x, anchor_offset.y],
	}


func get_kind_name() -> StringName:
	return StringName(KIND_NAMES.get(kind, &"limb"))


func get_joint_name() -> StringName:
	return StringName(JOINT_NAMES.get(joint, &"root"))


func get_shade_name() -> StringName:
	return StringName(SHADE_NAMES.get(shade, &"volumetric"))


func to_dictionary() -> Dictionary:
	return {
		"id": String(id),
		"kind": String(get_kind_name()),
		"joint": String(get_joint_name()),
		"shade": String(get_shade_name()),
		"length": length,
		"base_radius": base_radius,
		"tip_radius": tip_radius,
		"bend": bend,
		"wiggle": wiggle,
		"body_role": String(body_role),
		"shade_role": String(shade_role),
		"rim_role": String(rim_role),
		"joint_id": String(joint_id),
		"at": at,
		"angle": angle,
		"scale": scale,
		"fusion": fusion,
		"segments": segments.duplicate(true),
	}


func duplicate_part() -> ProceduralBodyPart:
	var copy: ProceduralBodyPart = ProceduralBodyPart.new(id, kind)
	copy.joint = joint
	copy.shade = shade
	copy.length = length
	copy.base_radius = base_radius
	copy.tip_radius = tip_radius
	copy.bend = bend
	copy.wiggle = wiggle
	copy.body_role = body_role
	copy.shade_role = shade_role
	copy.rim_role = rim_role
	copy.joint_id = joint_id
	copy.at = at
	copy.angle = angle
	copy.scale = scale
	copy.fusion = fusion
	copy.anchor_mode = anchor_mode
	copy.anchor_parent = anchor_parent
	copy.anchor_offset = anchor_offset
	copy.segments = segments.duplicate(true)
	return copy


## 리터럴 색을 절대 쓰지 않는다. 역할명으로만 칠한다.
func body_color(palette: ProceduralPalette) -> Color:
	return palette.get_color(body_role)


func shade_color(palette: ProceduralPalette) -> Color:
	return palette.get_color(shade_role)


func rim_color(palette: ProceduralPalette) -> Color:
	return palette.get_color(rim_role)


static func kind_from_name(name: StringName) -> Kind:
	return _lookup(KIND_NAMES, name, Kind.LIMB)


static func joint_from_name(name: StringName) -> Joint:
	return _lookup(JOINT_NAMES, name, Joint.ROOT)


static func shade_from_name(name: StringName) -> Shade:
	return _lookup(SHADE_NAMES, name, Shade.VOLUMETRIC)


static func segment_kind_from_name(name: StringName) -> int:
	return _lookup(SEGMENT_NAMES, name, SegmentKind.CAPSULE)


## §7-2. 구형 joint 3칸을 연속 at 으로 환산.
static func joint_to_at(joint_name: StringName) -> float:
	match joint_name:
		&"middle":
			return 0.5
		&"tip":
			return 1.0
		&"none":
			return 0.0
		_:
			return 0.0


static func _lookup(table: Dictionary, name: StringName, fallback: int) -> int:
	for key: Variant in table:
		if StringName(table[key]) == name:
			return int(key)
	return fallback


# ── 기하 ─────────────────────────────────────────────────────────────────

## 이 파트의 도형 목록. [kinds, groups, from, to, from_radius, to_radius].
## groups 는 도형이 속한 세그먼트다. 한 세그먼트 안은 min 으로, 세그먼트끼리는
## fusion 폭의 smooth_min 으로 잇는다. field_at / bounds / draw 가 같은 것을 읽는다.
func _geometry() -> Array:
	var key: Array = [length, base_radius, tip_radius, bend, wiggle, fusion, segments.hash()]
	if key == _geo_key and not _geo.is_empty():
		return _geo
	var kinds: PackedInt32Array = PackedInt32Array()
	var groups: PackedInt32Array = PackedInt32Array()
	var from_points: PackedVector2Array = PackedVector2Array()
	var to_points: PackedVector2Array = PackedVector2Array()
	var from_radii: PackedFloat32Array = PackedFloat32Array()
	var to_radii: PackedFloat32Array = PackedFloat32Array()
	var count: int = segment_count()
	var curved: bool = bend != 0.0 or wiggle != 0.0
	for segment_index: int in count:
		var start_t: float = float(segment_index) / float(count)
		var end_t: float = float(segment_index + 1) / float(count)
		var shape_kind: int = segment_kind(segment_index)
		var pieces: int = 1
		if curved and shape_kind == SegmentKind.CAPSULE:
			pieces = maxi(2, ceili(float(_CURVE_STEPS) / float(count)))
		for piece: int in pieces:
			var a_t: float = lerpf(start_t, end_t, float(piece) / float(pieces))
			var b_t: float = lerpf(start_t, end_t, float(piece + 1) / float(pieces))
			kinds.append(shape_kind)
			groups.append(segment_index)
			from_points.append(_joint_at(a_t))
			to_points.append(_joint_at(b_t))
			from_radii.append(maxf(radius_at(a_t), 0.0))
			to_radii.append(maxf(radius_at(b_t), 0.0))
	_geo = [kinds, groups, from_points, to_points, from_radii, to_radii]
	_geo_key = key
	return _geo


## _geometry() 의 거리장. 로컬 좌표, 로컬 단위.
func _distance(geometry: Array, point: Vector2) -> float:
	var kinds: PackedInt32Array = geometry[0]
	var groups: PackedInt32Array = geometry[1]
	var from_points: PackedVector2Array = geometry[2]
	var to_points: PackedVector2Array = geometry[3]
	var from_radii: PackedFloat32Array = geometry[4]
	var to_radii: PackedFloat32Array = geometry[5]
	var best: float = _FAR
	var group: int = -1
	var group_best: float = _FAR
	for index: int in kinds.size():
		if groups[index] != group:
			if group >= 0:
				best = _fuse(best, group_best, fusion)
			group = groups[index]
			group_best = _FAR
		group_best = minf(group_best, _primitive_distance(
			kinds[index], point, from_points[index], to_points[index], from_radii[index], to_radii[index]
		))
	if group >= 0:
		best = _fuse(best, group_best, fusion)
	return best


func _primitive_distance(
	shape_kind: int, point: Vector2, from_joint: Vector2, to_joint: Vector2,
	start_radius: float, end_radius: float
) -> float:
	match shape_kind:
		SegmentKind.TRIANGLE:
			var direction: Vector2 = to_joint - from_joint
			if direction.length_squared() < 0.000001:
				return ProceduralSdf.circle(point, from_joint, maxf(start_radius, end_radius))
			var normal: Vector2 = direction.normalized().orthogonal()
			var wedge: float = ProceduralSdf.triangle(
				point, from_joint + normal * start_radius, from_joint - normal * start_radius, to_joint
			)
			if end_radius > 0.0:
				wedge = minf(wedge, ProceduralSdf.circle(point, to_joint, end_radius))
			return wedge
		SegmentKind.BOX:
			var span: Vector2 = to_joint - from_joint
			var half: Vector2 = Vector2(span.length() * 0.5, maxf(maxf(start_radius, end_radius), 0.5))
			var corner: float = clampf(minf(start_radius, end_radius) * 0.4, 0.0, minf(half.x, half.y))
			var local: Vector2 = (point - (from_joint + to_joint) * 0.5).rotated(-span.angle())
			return ProceduralSdf.rounded_box(local, Vector2.ZERO, half, corner)
		_:
			return _tapered_capsule(point, from_joint, to_joint, start_radius, end_radius)


## 칠하지 않은 순수 실루엣의 로컬 경계. smooth_min 이 도형을 부풀리는 폭(fusion / 4)을 포함한다.
func _silhouette_extent(geometry: Array) -> Rect2:
	var kinds: PackedInt32Array = geometry[0]
	var from_points: PackedVector2Array = geometry[2]
	var to_points: PackedVector2Array = geometry[3]
	var from_radii: PackedFloat32Array = geometry[4]
	var to_radii: PackedFloat32Array = geometry[5]
	var extent: Rect2 = Rect2()
	var started: bool = false
	for index: int in kinds.size():
		var a: Vector2 = from_points[index]
		var b: Vector2 = to_points[index]
		var ra: float = from_radii[index]
		var rb: float = to_radii[index]
		var piece: Rect2 = Rect2(a - Vector2(ra, ra), Vector2(ra, ra) * 2.0).merge(
			Rect2(b - Vector2(rb, rb), Vector2(rb, rb) * 2.0)
		)
		match kinds[index]:
			SegmentKind.TRIANGLE:
				var direction: Vector2 = b - a
				if direction.length_squared() >= 0.000001:
					var normal: Vector2 = direction.normalized().orthogonal()
					piece = piece.expand(a + normal * ra).expand(a - normal * ra)
			SegmentKind.BOX:
				var span: Vector2 = b - a
				var half: Vector2 = Vector2(span.length() * 0.5, maxf(maxf(ra, rb), 0.5))
				piece = _transformed_rect(Transform2D(span.angle(), (a + b) * 0.5), Rect2(-half, half * 2.0))
		extent = piece if not started else extent.merge(piece)
		started = true
	return extent.grow(fusion * 0.25)


## draw() 가 실루엣 밖으로 칠하는 폭. 안티에일리어싱 반폭, INK 이면 선 바깥쪽까지.
func _paint_margin() -> float:
	if shade == Shade.INK:
		return _INK_WIDTH * 0.5 + _EDGE_MARGIN
	return _EDGE_MARGIN


## deform 필드가 옮길 수 있는 만큼 실루엣 경계를 넓힌다.
func _deform_extent(deform: ProceduralDeformField, extent: Rect2) -> Rect2:
	var reach: float = 0.0
	var rest_points: PackedVector2Array = deform.rest
	var live_points: PackedVector2Array = deform.points
	for index: int in mini(rest_points.size(), live_points.size()):
		reach = maxf(reach, rest_points[index].distance_to(live_points[index]))
	return extent.grow(reach)


## deform 필드의 bounds 는 이 파트의 로컬 프레임이다. 필드가 밀린 만큼 거꾸로 샘플한다.
func _warp(local: Vector2, deform: ProceduralDeformField) -> Vector2:
	var area: Rect2 = deform.bounds
	if area.size.x <= 0.0 or area.size.y <= 0.0:
		return local
	var u: float = (local.x - area.position.x) / area.size.x
	var v: float = (local.y - area.position.y) / area.size.y
	if u < 0.0 or u > 1.0 or v < 0.0 or v > 1.0:
		return local
	return local - deform.get_offset(u, v)


static func _squash_basis(squash_axis: float, along_scale: float, across_scale: float) -> Transform2D:
	var turn: Transform2D = Transform2D(squash_axis, Vector2.ZERO)
	var squeeze: Transform2D = Transform2D(Vector2(along_scale, 0.0), Vector2(0.0, across_scale), Vector2.ZERO)
	return turn * squeeze * turn.affine_inverse()


static func _transformed_rect(transform: Transform2D, rect: Rect2) -> Rect2:
	var corners: Array[Vector2] = [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	]
	var out: Rect2 = Rect2(transform * corners[0], Vector2.ZERO)
	for corner: Vector2 in corners:
		out = out.expand(transform * corner)
	return out


## 거리 버퍼를 채울 캔버스 픽셀 사각형. 칠 여백과 음영 오프셋까지 덮고, 캔버스
## 밖으로는 음영 오프셋만큼만 넘친다. 그 너머를 읽으면 바깥(_FAR)이다.
static func _buffer_region(forward: Transform2D, extent: Rect2, margin: float, depth: float, canvas: ProceduralCanvas) -> Rect2i:
	var box: Rect2 = _transformed_rect(forward, extent).grow(margin)
	var reach: int = ceili(depth) + 2
	var left: int = maxi(floori(box.position.x), -reach)
	var top: int = maxi(floori(box.position.y), -reach)
	var right: int = mini(ceili(box.end.x), canvas.width + reach)
	var bottom: int = mini(ceili(box.end.y), canvas.height + reach)
	return Rect2i(left, top, maxi(right - left, 0), maxi(bottom - top, 0))


## 음영 스타일을 칠할 층 목록으로 푼다. 색은 전부 팔레트 역할과 그 혼합이다.
##   FLAT        채움
##   VOLUMETRIC  채움 + 빛 반대쪽 그림자 초승달 + 빛 쪽 1px 하이라이트(key_light 역할이 있을 때)
##   RIM         채움 + 그림자 초승달 + 빛 쪽 1px rim_role 선
##   INK         채움 + 1px 먹선(ink 역할, 없으면 shade_role). with_ink 가 false 면 생략
static func _layers_for(
	palette: ProceduralPalette, p_body_role: StringName, p_shade_role: StringName, p_rim_role: StringName,
	style: int, depth: float, with_ink: bool
) -> Array:
	var layers: Array = [[_LAYER_FILL, palette.get_color(p_body_role)]]
	var dark: Vector2i = Vector2i(roundi(-_LIGHT_DIRECTION.x * depth), roundi(-_LIGHT_DIRECTION.y * depth))
	var lit: Vector2i = Vector2i(roundi(_LIGHT_DIRECTION.x), roundi(_LIGHT_DIRECTION.y))
	match style:
		Shade.VOLUMETRIC:
			if dark != Vector2i.ZERO:
				layers.append([_LAYER_CRESCENT, palette.mix_roles(p_body_role, p_shade_role, _SHADE_MIX), dark])
			if palette.has_role(ProceduralPalette.ROLE_KEY_LIGHT):
				layers.append([_LAYER_CRESCENT, palette.mix_roles(p_body_role, ProceduralPalette.ROLE_KEY_LIGHT, _HIGHLIGHT_MIX), lit])
		Shade.RIM:
			if dark != Vector2i.ZERO:
				layers.append([_LAYER_CRESCENT, palette.mix_roles(p_body_role, p_shade_role, _SHADE_MIX), dark])
			layers.append([_LAYER_CRESCENT, palette.get_color(p_rim_role), lit])
		Shade.INK:
			if with_ink:
				var ink_role: StringName = ProceduralPalette.ROLE_INK if palette.has_role(ProceduralPalette.ROLE_INK) else p_shade_role
				layers.append([_LAYER_STROKE, palette.get_color(ink_role), _INK_WIDTH])
	return layers


## 캔버스 공간 거리 버퍼(region 의 픽셀 중심마다 한 값)를 층 목록대로 칠한다.
## 덮임률은 ProceduralSdf.coverage 가 정한다. 칠은 paint 안에서만 한다.
##   [_LAYER_FILL, color]              d < 0
##   [_LAYER_CRESCENT, color, offset]  d < 0 이고 d(p + offset) >= 0 — 실루엣을 offset 만큼 민 차집합
##   [_LAYER_STROKE, color, width]     |d| < width / 2
static func _paint_distance(canvas: ProceduralCanvas, distance: PackedFloat32Array, region: Rect2i, paint: Rect2i, layers: Array) -> void:
	var width: int = region.size.x
	var height: int = region.size.y
	for layer: Array in layers:
		var layer_kind: int = int(layer[0])
		var color: Color = layer[1]
		var offset: Vector2i = layer[2] if layer_kind == _LAYER_CRESCENT else Vector2i.ZERO
		var half: float = float(layer[2]) * 0.5 if layer_kind == _LAYER_STROKE else 0.0
		for y: int in range(paint.position.y, paint.end.y):
			var row: int = (y - region.position.y) * width - region.position.x
			for x: int in range(paint.position.x, paint.end.x):
				var value: float = distance[row + x]
				var cov: float = 0.0
				if layer_kind == _LAYER_FILL:
					cov = ProceduralSdf.coverage(value)
				elif layer_kind == _LAYER_CRESCENT:
					if value < _EDGE_MARGIN:
						var sx: int = x + offset.x - region.position.x
						var sy: int = y + offset.y - region.position.y
						var shifted: float = _FAR
						if sx >= 0 and sy >= 0 and sx < width and sy < height:
							shifted = distance[sy * width + sx]
						cov = ProceduralSdf.coverage(maxf(value, -shifted))
				else:
					cov = ProceduralSdf.coverage(absf(value) - half)
				if cov > 0.0:
					canvas.blend_pixel(x, y, color, cov)


## "kind" / "joint" / "shade" 값: enum 정수, 숫자 문자열, 또는 이름(String / StringName).
static func _enum_value(raw: Variant, table: Dictionary, fallback: int) -> int:
	if raw is StringName or raw is String:
		var text: String = String(raw)
		if text.is_valid_int():
			return int(text)
		return _lookup(table, StringName(text), fallback)
	return int(raw)


static func _pose_vector(raw: Variant) -> Vector2:
	if raw is Vector2:
		return raw
	if raw is Vector2i:
		return Vector2(raw)
	if raw is Array and (raw as Array).size() >= 2:
		return Vector2(float(raw[0]), float(raw[1]))
	return Vector2.ZERO
