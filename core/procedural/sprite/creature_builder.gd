class_name ProceduralCreatureBuilder
extends RefCounted

# PURPOSE: composes a list of ProceduralBodyPart into one rigid silhouette, and
# bakes it once. This is the ONLY bake path in the engine, and it only accepts
# shapes whose points are invariant. (§2.4)
# OWNER: PVE. EXISTING SIGNATURES ARE FROZEN.
# 정본: core/procedural/DESIGN_DECISION.md §2.1, §2.4, §3.1
#
# §2.4. bake 는 kind 가 아니라 자료형으로 판정한다. build 후 points 가 불변이면
# bake 가능하다. soft_* 는 항상 거부되고, rigid 에 deform 필드가 붙으면 거부된다.
# 조용히 구우지 않는다 — require_bakeable() 이 먼저 실패시킨다.

var canvas_size: Vector2i = Vector2i(64, 64)
var outline_role: StringName = ProceduralPalette.ROLE_INK
var outline_width: float = 2.0
var squash: float = 0.0
var facing: int = 1
var palette: ProceduralPalette = null

var parts: Array[ProceduralBodyPart] = []

## §6.3. 이 빌더가 만든 정규 형상. bake 여부를 여기서 판정한다.
var shape: ProceduralShape = null

const MARGIN: int = 2


func _init(p_canvas_size: Vector2i = Vector2i(64, 64)) -> void:
	canvas_size = p_canvas_size


func add_part(part: ProceduralBodyPart) -> void:
	parts.append(part)
	_invalidate()


func remove_part(part_id: StringName) -> bool:
	for index: int in parts.size():
		if parts[index].id == part_id:
			parts.remove_at(index)
			_invalidate()
			return true
	return false


func get_part(part_id: StringName) -> ProceduralBodyPart:
	for part: ProceduralBodyPart in parts:
		if part.id == part_id:
			return part
	return null


func get_part_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for part: ProceduralBodyPart in parts:
		ids.append(part.id)
	return ids


func set_palette(value: ProceduralPalette) -> void:
	palette = value


func _invalidate() -> void:
	shape = null


# ── 정규 형상 (§6.3) ─────────────────────────────────────────────────────

## 파트를 정규 형상 파트로 심는다. parent 는 항상 직전 파트. (§1.2 at = 0~1)
## 정규 형상은 파트의 실루엣이 아니라 **관절**을 담는다. 실루엣은 field_at() 이 만든다.
func to_shape() -> ProceduralShape:
	if shape != null:
		return shape
	if parts.is_empty():
		push_error("ProceduralCreatureBuilder.to_shape: no parts.")
		return null
	var built: ProceduralShape = ProceduralShape.new(ProceduralShape.Kind.RIGID)
	if not built.allocate(parts.size(), ProceduralShape.Kind.RIGID):
		return null
	for index: int in parts.size():
		var part: ProceduralBodyPart = parts[index]
		var mode: int = ProceduralShape.AnchorMode.FREE if index == 0 else ProceduralShape.AnchorMode.ATTACHED
		var parent: int = -1 if index == 0 else index - 1
		if not built.add_rig_joint(index, mode, parent, part.anchor_offset, part.angle, part.at, part.id):
			return null
		built.span[index] = part.length * maxf(part.scale, 0.0001)
		built.radius[index] = part.max_radius()
	if not built.finalize():
		return null
	shape = built
	return shape


## §2.4. bake 판정의 본체. 자료형으로만 한다.
func is_bakeable() -> bool:
	if shape == null and to_shape() == null:
		return false
	return shape.is_bakeable() and shape.points_match_rest(0.0)


# ── bake 경로 (§2.1) ─────────────────────────────────────────────────────

## Walks the parts in order and fuses their fields. Union comes from
## ProceduralSdf.smooth_min, not from overlapping opaque draws, otherwise the
## silhouette shows seams.
func compose_canvas() -> ProceduralCanvas:
	var canvas: ProceduralCanvas = ProceduralCanvas.new(maxi(canvas_size.x, 1), maxi(canvas_size.y, 1))
	if parts.is_empty():
		return canvas
	if not is_bakeable():
		# §2.4. 조용히 구우지 않는다.
		push_error("ProceduralCreatureBuilder.compose_canvas: bake refused. points is not invariant.")
		return ProceduralCanvas.new(1, 1)
	_place_in_canvas()
	var union: Callable = _fused_field()
	var region: Rect2i = _union_rect()
	ProceduralSdf.stamp_field(canvas, union, region, palette.get_color(parts[0].body_role))
	# 안쪽 음영. 중심에서 먼 곳이 어둡다. 수학이지 추측이 아니다.
	var centre: Vector2 = region.get_center()
	var shade_call: Callable = func(p: Vector2) -> float:
		return float(union.call(p)) + p.distance_to(centre) * -0.04
	ProceduralSdf.stamp_field(canvas, shade_call, region, palette.get_color(parts[0].shade_role), 2.0)
	if outline_width > 0.0:
		ProceduralSdf.stroke_field(canvas, union, region, outline_width, palette.get_color(outline_role))
	return canvas


## 정규 형상의 월드 좌표는 그대로 두고, 그리기 자리만 캔버스 한가운데로 옮긴다.
## bake 전용이며 물리를 건드리지 않는다.
func _place_in_canvas() -> void:
	var extent: Rect2 = _shape_bounds()
	var centre: Vector2 = extent.get_center()
	var wanted: Vector2 = Vector2(canvas_size) * 0.5
	canvas_origin = wanted - centre


## 파트 실루엣 전체의 월드 경계. bake 전용.
func _shape_bounds() -> Rect2:
	var minimum: Vector2 = Vector2(1.0e9, 1.0e9)
	var maximum: Vector2 = Vector2(-1.0e9, -1.0e9)
	for part: ProceduralBodyPart in parts:
		var extent: Rect2 = part.bounds()
		var origin: Vector2 = _part_origin(part)
		var world_angle: float = _part_world_angle(part)
		for corner: Vector2 in [extent.position, extent.end]:
			var moved: Vector2 = (corner - origin).rotated(world_angle) + origin
			minimum.x = minf(minimum.x, moved.x)
			minimum.y = minf(minimum.y, moved.y)
			maximum.x = maxf(maximum.x, moved.x)
			maximum.y = maxf(maximum.y, moved.y)
	return Rect2(minimum, maximum - minimum)


## One closed contour of the fused silhouette, in canvas pixel space, wound
## consistently. Marching squares over the fused field. Points are never placed
## by hand.
func outline() -> PackedVector2Array:
	if not is_bakeable():
		push_error("ProceduralCreatureBuilder.outline: bake refused. points is not invariant.")
		return PackedVector2Array()
	_place_in_canvas()
	var union: Callable = _fused_field()
	return _marching_squares(union, _union_rect(), 0.0)


## compose_canvas() then to_texture(). One call, one texture, never again.
func compose() -> ImageTexture:
	if not is_bakeable():
		push_error("ProceduralCreatureBuilder.compose: bake refused. points is not invariant.")
		return null
	return compose_canvas().to_texture()


## §2.2. 콜라이더는 정규 형상의 정지 좌표에서 파생한다. 배열을 복사하지 않는다.
func derive_collider() -> Dictionary:
	if to_shape() == null:
		return {}
	shape.collider_enabled = true
	return shape.derive_collider()


## Authored manifest of the spec. JSON safe, so a Kit can save or diff it.
func describe() -> Dictionary:
	var entries: Array[Dictionary] = []
	for part: ProceduralBodyPart in parts:
		entries.append(part.to_dictionary())
	return {
		"version": Procedural.ENGINE_VERSION,
		"canvas_width": canvas_size.x,
		"canvas_height": canvas_size.y,
		"outline_role": String(outline_role),
		"outline_width": outline_width,
		"squash": squash,
		"facing": facing,
		"parts": entries,
	}


# ── 내부 ─────────────────────────────────────────────────────────────────

## 파트를 rig 변환으로 옮긴 뒤 융합하는 거리장. bake 전용.
func _fused_field() -> Callable:
	return func(p: Vector2) -> float:
		var best: float = 1.0e9
		for part: ProceduralBodyPart in parts:
			var local: Vector2 = _to_local(p, part)
			best = ProceduralSdf.smooth_min(best, part.field_at(local), part.fusion)
		return best


## 정규 형상의 월드 좌표를 캔버스 픽셀로 옮기는 오프셋. bake 시 1회 계산한다.
## 정규 형상의 rest 는 바꾸지 않는다 — 정규 배열이 하나여야 한다. (§0)
var canvas_origin: Vector2 = Vector2.ZERO


func _to_local(canvas_point: Vector2, part: ProceduralBodyPart) -> Vector2:
	var origin: Vector2 = _part_origin(part) + canvas_origin
	var rotated: Vector2 = (canvas_point - origin).rotated(-_part_world_angle(part))
	var across: float = 1.0
	var along: float = 1.0
	if squash != 0.0:
		var clamped: float = clampf(squash, -ProceduralBodyPart.MAX_SQUASH_LOCAL, ProceduralBodyPart.MAX_SQUASH_LOCAL)
		along = 1.0 - clamped
		across = 1.0 + clamped * 0.5
	return Vector2(rotated.x / across, rotated.y / along)


## 파트의 원점은 "직전 파트의 관절" 이다. 정규 형상의 얇은 껍데기.
func _part_index(part: ProceduralBodyPart) -> int:
	var built: ProceduralShape = to_shape()
	if built == null:
		return -1
	for index: int in built.node_count():
		if built.node_id_at(index) == part.id:
			return index
	return -1


func _part_origin(part: ProceduralBodyPart) -> Vector2:
	var index: int = _part_index(part)
	if index < 0:
		return Vector2.ZERO
	return to_shape().get_rest()[index]


## 파트의 **월드** 회전. part.angle 은 부모 기준 상대값이므로 그대로 쓰면 안 된다.
## 정규 형상의 rest_dir 가 누적 회전을 이미 갖고 있다.
func _part_world_angle(part: ProceduralBodyPart) -> float:
	var index: int = _part_index(part)
	if index < 0:
		return part.angle
	return to_shape().get_rest_dir(index).angle()


func _union_rect() -> Rect2i:
	var extent: Rect2 = _shape_bounds()
	extent.position += canvas_origin
	extent.position -= Vector2(MARGIN, MARGIN)
	extent.size += Vector2(MARGIN * 2.0, MARGIN * 2.0)
	var left: int = maxi(floori(extent.position.x), 0)
	var top: int = maxi(floori(extent.position.y), 0)
	var right: int = mini(ceili(extent.end.x), canvas_size.x)
	var bottom: int = mini(ceili(extent.end.y), canvas_size.y)
	return Rect2i(left, top, maxi(right - left, 0), maxi(bottom - top, 0))


## Marching squares. 등값선을 따라 부호가 바뀌는 지점을 선분으로 잇는다.
## 이것이 outline() 의 전부다. 점을 손으로 놓지 않는다.
func _marching_squares(field: Callable, region: Rect2i, level: float) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	if region.size.x < 2 or region.size.y < 2:
		return out
	for row: int in range(region.size.y - 1):
		for column: int in range(region.size.x - 1):
			var origin: Vector2 = Vector2(float(region.position.x + column), float(region.position.y + row))
			var corners: PackedVector2Array = PackedVector2Array([
				origin, origin + Vector2(1.0, 0.0), origin + Vector2(1.0, 1.0), origin + Vector2(0.0, 1.0)
			])
			var values: PackedFloat32Array = PackedFloat32Array()
			for corner: Vector2 in corners:
				values.append(float(field.call(corner)) - level)
			var crossings: PackedVector2Array = PackedVector2Array()
			for edge: int in 4:
				var a: Vector2 = corners[edge]
				var b: Vector2 = corners[(edge + 1) % 4]
				var fa: float = values[edge]
				var fb: float = values[(edge + 1) % 4]
				if (fa <= 0.0) == (fb <= 0.0):
					continue
				var t: float = fa / (fa - fb)
				crossings.append(a.lerp(b, t))
			if crossings.size() >= 2:
				out.append(crossings[0])
				out.append(crossings[1])
			if crossings.size() == 4:
				out.append(crossings[2])
				out.append(crossings[3])
	return out
