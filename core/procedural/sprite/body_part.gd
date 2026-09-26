class_name ProceduralBodyPart
extends RefCounted

# PURPOSE: one authored part of a rigid object. A part is a procedural
# silhouette described by data, never by pixels. This class is both the spec
# container and the local geometry source for the bake path.
# OWNER: PVE. EXISTING SIGNATURES ARE FROZEN.
# 정본: core/procedural/DESIGN_DECISION.md §1.2, §6.3
#
# LOCAL POSE CONVENTION — this is what body_part.gd:15-17 refused to invent.
#   origin  파트의 관절(붙는 지점). 정규 형상의 노드 위치와 같다.
#   axis    성장 방향 = 로컬 +X. 길이는 이 축을 따라 측정한다.
#   parts   자식 파트는 rest_position 이 아니라 at(angle 로 잘린 부모 축 위 지점) 에 붙는다.
#   이 규약 덕분에 bounds() 와 draw() 가 언제나 같은 영역을 차지한다.
#
# §1.2. 형상은 다섯 개의 숫자와 segments 에서만 나온다. Kind 는 기하에 영향이
# 없는 메타데이터이며 추가하지 않는다. (§7-1)

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
var anchor_parent: int = -1
## 부모 프레임의 로컬 오프셋(px).
var anchor_offset: Vector2 = Vector2.ZERO
## 파트를 여러 노드로 접는다. entries 는 configure() 와 같은 키를 쓴다.
var segments: Array[Dictionary] = []
var fusion: float = DEFAULT_FUSION


func _init(p_id: StringName = &"part", p_kind: Kind = Kind.LIMB) -> void:
	id = p_id
	kind = p_kind


## Accepts enum ints or the names in KIND_NAMES / JOINT_NAMES / SHADE_NAMES.
## Unknown keys keep the current value, so a partial spec is legal.
func configure(spec: Dictionary) -> void:
	if spec.has("id"):
		id = StringName(spec["id"])
	if spec.has("kind"):
		var raw_kind: Variant = spec["kind"]
		if raw_kind is StringName:
			kind = kind_from_name(raw_kind)
		else:
			kind = int(raw_kind)
	if spec.has("joint"):
		var raw_joint: Variant = spec["joint"]
		if raw_joint is StringName:
			joint = joint_from_name(raw_joint)
		else:
			joint = int(raw_joint)
	if spec.has("shade"):
		var raw_shade: Variant = spec["shade"]
		if raw_shade is StringName:
			shade = shade_from_name(raw_shade)
		else:
			shade = int(raw_shade)
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
		at = joint_to_at(StringName(spec["joint"]))


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


## 정지 자식 관절 좌표들. 로컬 +X 가 성장 방향. (관절 = 정규 형상의 노드)
## 정규 형상의 chain 규칙(rest_dir * span)과 정확히 같은 열이다. (§5 단계 4)
func rest_joints() -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	out.append(Vector2.ZERO)
	var steps: int = maxi(segments.size(), 1)
	for step_index: int in steps:
		out.append(_joint_at(float(step_index + 1) / float(steps)))
	return out


func _joint_at(t: float) -> Vector2:
	var curve: float = clampf(t, 0.0, 1.0)
	var along: float = length * curve
	var turned: float = deg_to_rad(bend) * curve
	var wave: float = sin(curve * PI) * wiggle * length * 0.25
	# bend 는 끝점을 돌리고 wiggle 은 중간을 옆으로 젖힌다. 둘 다 원점에서 시작한다.
	var base: Vector2 = Vector2(along, wave)
	return base.rotated(turned)


## 세그먼트 끝점(관절) 목록. segments 가 있으면 그것이, 없으면 균일 분할이 기준.
func segment_endpoints() -> PackedVector2Array:
	var joints: PackedVector2Array = rest_joints()
	if segments.is_empty():
		return joints
	var out: PackedVector2Array = PackedVector2Array()
	var steps: int = segments.size()
	for step_index: int in steps:
		out.append(_joint_at(float(step_index + 1) / float(steps)))
	return out


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


## t 위치에서의 반지름. base_radius → tip_radius 를 선형으로 보간한다.
func radius_at(t: float) -> float:
	var curve: float = clampf(t, 0.0, 1.0)
	return lerpf(base_radius, tip_radius, curve) * 0.5


## 이 파트의 실루엣 거리장. 로컬 좌표계. 음수 = 내부.
## ProceduralSdf 만 쓰므로 bake 결과는 수학의 결과지 그린 추측이 아니다.
func field_at(point: Vector2) -> float:
	var endpoints: PackedVector2Array = segment_endpoints()
	var count: int = endpoints.size()
	var distance: float = 1.0e9
	for step_index: int in count - 1:
		var from_joint: Vector2 = endpoints[step_index]
		var to_joint: Vector2 = endpoints[step_index + 1]
		var start_t: float = float(step_index) / float(count - 1)
		var end_t: float = float(step_index + 1) / float(count - 1)
		var start_radius: float = radius_at(start_t)
		var end_radius: float = radius_at(end_t)
		distance = _fuse(distance, _segment_distance(
			point, from_joint, to_joint, start_radius, end_radius, step_index
		), fusion)
	return distance


func _segment_distance(
	point: Vector2, from_joint: Vector2, to_joint: Vector2,
	start_radius: float, end_radius: float, step_index: int
) -> float:
	match segment_kind(step_index):
		SegmentKind.TRIANGLE:
			var w0: float = _cross(to_joint - from_joint, point - from_joint)
			var w1: float = _cross(Vector2.ZERO - to_joint, point - to_joint)
			var w2: float = _cross(from_joint - Vector2.ZERO, point)
			var inside: bool = (w0 >= 0.0 and w1 >= 0.0 and w2 >= 0.0) or (w0 <= 0.0 and w1 <= 0.0 and w2 <= 0.0)
			var edge: float = minf(
				minf(ProceduralSdf.segment(point, from_joint, to_joint),
					ProceduralSdf.segment(point, to_joint, Vector2.ZERO)),
				ProceduralSdf.segment(point, Vector2.ZERO, from_joint)
			)
			return -edge if inside else edge
		SegmentKind.BOX:
			return ProceduralSdf.rounded_box(
				point, (from_joint + to_joint) * 0.5,
				Vector2(absf(to_joint.x - from_joint.x) * 0.5, maxf((start_radius + end_radius) * 0.5, 0.5)),
				minf(start_radius, end_radius) * 0.4
			)
		_:
			# 테이퍼 캡슐: 두 끝의 반지름이 다른 캡슐. ProceduralSdf 에 없어서 여기서 만든다.
			return _tapered_capsule(point, from_joint, to_joint, start_radius, end_radius)


func _tapered_capsule(
	point: Vector2, from_joint: Vector2, to_joint: Vector2, start_radius: float, end_radius: float
) -> float:
	var axis: Vector2 = to_joint - from_joint
	var length_sq: float = axis.dot(axis)
	var t: float = 0.0
	if length_sq > 0.000001:
		t = clampf((point - from_joint).dot(axis) / length_sq, 0.0, 1.0)
	var centre: Vector2 = from_joint + axis * t
	var radius: float = lerpf(start_radius, end_radius, t)
	return point.distance_to(centre) - radius


func _fuse(current: float, incoming: float, blend: float) -> float:
	if blend <= 0.0:
		return minf(current, incoming)
	return ProceduralSdf.smooth_min(current, incoming, blend)


static func _cross(a: Vector2, b: Vector2) -> float:
	return a.x * b.y - a.y * b.x


## Local bounds that agree with draw() exactly, because both read field_at().
func bounds() -> Rect2:
	var endpoints: PackedVector2Array = segment_endpoints()
	var extent: float = maxf(max_radius(), 0.0)
	var minimum: Vector2 = Vector2(extent, extent)
	var maximum: Vector2 = endpoints[endpoints.size() - 1] + Vector2(extent, extent)
	for joint: Vector2 in endpoints:
		minimum.x = minf(minimum.x, joint.x - extent)
		minimum.y = minf(minimum.y, joint.y - extent)
		maximum.x = maxf(maximum.x, joint.x + extent)
		maximum.y = maxf(maximum.y, joint.y + extent)
	return Rect2(minimum, maximum - minimum)


## Paints the part into `canvas`. `pose` carries the rig transform for this
## frame: { "origin": Vector2, "rotation": float, "scale": float, "squash": float }.
## Origin is the part's own joint, axis is local +X. Same convention as bounds().
func draw(canvas: ProceduralCanvas, palette: ProceduralPalette, pose: Dictionary = {}) -> void:
	if canvas == null or palette == null:
		push_error("ProceduralBodyPart.draw: canvas and palette are required.")
		return
	var origin: Vector2 = pose.get("origin", Vector2.ZERO)
	var rotation: float = float(pose.get("rotation", 0.0))
	var scale_factor: float = float(pose.get("scale", 1.0))
	var squash: float = clampf(float(pose.get("squash", 0.0)), -MAX_SQUASH_LOCAL, MAX_SQUASH_LOCAL)
	var extent: Rect2 = bounds()
	# squash 는 부피 보존 비균등 축약이다. 축을 (1 - s), 횡을 (1 + s * 0.5) 로.
	var along_scale: float = scale_factor * (1.0 - squash)
	var across_scale: float = scale_factor * (1.0 + squash * 0.5)
	var span: Rect2 = Rect2(
		Vector2(minf(extent.position.x * across_scale, extent.position.x * across_scale), minf(extent.position.y * along_scale, extent.position.y * along_scale)),
		Vector2(extent.size.x * across_scale, extent.size.y * along_scale)
	)
	var bounds_px: Rect2i = _to_canvas_rect(span, origin, rotation, canvas)
	if bounds_px.size.x <= 0 or bounds_px.size.y <= 0:
		return
	var body_color: Color = palette.get_color(body_role)
	var shade_color: Color = palette.get_color(shade_role)
	var field: Callable = _field_transformed(origin, rotation, along_scale, across_scale)
	ProceduralSdf.stamp_field(canvas, field, bounds_px, body_color)
	# 음영. 중심에서 먼 쪽으로 어둡게. 이것도 수학이지 추측이 아니다.
	var centre: Vector2 = _to_canvas_point(Vector2.ZERO, origin, rotation, along_scale, across_scale)
	var shade_field: Callable = func(p: Vector2) -> float:
		return float(field.call(p)) + p.distance_to(centre) * -0.05
	ProceduralSdf.stamp_field(canvas, shade_field, bounds_px, shade_color, 2.0)
	if shade == Shade.INK or shade == Shade.RIM:
		ProceduralSdf.stroke_field(canvas, field, bounds_px, 1.0, palette.get_color(rim_role))


const MAX_SQUASH_LOCAL: float = 0.6


func _field_transformed(origin: Vector2, rotation: float, along_scale: float, across_scale: float) -> Callable:
	return func(p: Vector2) -> float:
		return field_at(_to_local_point(p, origin, rotation, along_scale, across_scale))


func _to_local_point(
	canvas_point: Vector2, origin: Vector2, rotation: float, along_scale: float, across_scale: float
) -> Vector2:
	var moved: Vector2 = canvas_point - origin
	moved = moved.rotated(-rotation)
	return Vector2(moved.x / maxf(across_scale, 0.0001), moved.y / maxf(along_scale, 0.0001))


func _to_canvas_point(
	local: Vector2, origin: Vector2, rotation: float, along_scale: float, across_scale: float
) -> Vector2:
	return origin + Vector2(local.x * across_scale, local.y * along_scale).rotated(rotation)


func _to_canvas_rect(span: Rect2, origin: Vector2, rotation: float, canvas: ProceduralCanvas) -> Rect2i:
	var corners: PackedVector2Array = PackedVector2Array([
		span.position,
		Vector2(span.end.x, span.position.y),
		span.end,
		Vector2(span.position.x, span.end.y),
	])
	var minimum: Vector2 = corners[0]
	var maximum: Vector2 = corners[0]
	for corner: Vector2 in corners:
		minimum.x = minf(minimum.x, corner.x)
		minimum.y = minf(minimum.y, corner.y)
		maximum.x = maxf(maximum.x, corner.x)
		maximum.y = maxf(maximum.y, corner.y)
	var margin: float = 2.0
	var left: int = maxi(floori(minimum.x) - int(margin), 0)
	var top: int = maxi(floori(minimum.y) - int(margin), 0)
	var right: int = mini(ceili(maximum.x) + int(margin), canvas.width)
	var bottom: int = mini(ceili(maximum.y) + int(margin), canvas.height)
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
