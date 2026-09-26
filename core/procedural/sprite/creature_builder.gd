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
# 조용히 구우지 않는다 — 거부하면 push_error 와 함께 1x1 캔버스 / null 이다.
#
# 좌표. 파트의 관절 위치와 방향은 정규 형상(to_shape)의 rest / rest_dir 가 정한다.
# 그림은 그 배열을 읽을 뿐 다른 자리를 계산하지 않는다 — 그래서 bake 결과와
# derive_collider() 가 같은 자리를 가리킨다. (§0)
#   canvas px = shape 좌표 + canvas_origin. canvas_origin 은 실루엣 경계의 중심을
#   캔버스 중심에 두도록 정수로 반올림한 값이다.
#   squash 는 실루엣 아래 가운데를 기준으로 세로 (1 - s), 가로 1 / (1 - s) 이다.
#   발이 같은 픽셀 줄에 남는다. facing < 0 은 캔버스 세로 중심선에 대한 거울이다.
#   빛은 거울·squash 뒤의 캔버스에서 늘 왼쪽 위다.
#
# 칠하는 순서.
#   1. 모든 파트를 smooth_min 으로 녹인 실루엣을 parts[0] 의 역할과 음영 스타일로 칠한다.
#   2. body_role 이 parts[0] 과 다른 파트(눈, 배, 무늬)를 그 위에 자기 역할로 칠한다.
#   3. outline_width > 0 이면 녹인 실루엣 전체에 outline_role 선을 긋는다.

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

## 정규 형상을 만들 때의 파트 값 서명. 파트가 바뀌면 정규 형상을 다시 만든다.
var _shape_key: int = 0
## compose 한 번 동안의 파트별 변환: [캔버스 → 파트 로컬 Transform2D, scale, geometry, 파트 로컬 → 캔버스].
var _frames: Array = []
## squash 기준점(실루엣 아래 가운데)과 facing 거울 축. 캔버스 좌표.
var _pivot: Vector2 = Vector2.ZERO


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
	_shape_key = 0


# ── 정규 형상 (§6.3) ─────────────────────────────────────────────────────

## 파트를 정규 형상 노드로 심는다. 부모는 anchor.parent 가 있으면 그 파트, 없으면
## 직전 파트다. (§4.3, §4.5) 정규 형상은 파트의 실루엣이 아니라 관절을 담는다.
## 실루엣은 field_at() 이 만든다. 파트 값이 바뀌면 다음 호출에서 다시 만든다.
func to_shape() -> ProceduralShape:
	var key: int = _parts_key()
	if shape != null and key == _shape_key:
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
		if index > 0 and part.anchor_parent >= 0:
			if part.anchor_parent >= index:
				push_error("ProceduralCreatureBuilder: part '%s' anchor.parent %d must be an earlier index (< %d)." % [part.id, part.anchor_parent, index])
				return null
			parent = part.anchor_parent
		if not built.add_rig_joint(index, mode, parent, part.anchor_offset, part.angle, part.at, part.id):
			return null
		built.span[index] = part.length * maxf(part.scale, 0.0001)
		built.radius[index] = part.max_radius() * maxf(part.scale, 0.0001)
	if not built.finalize():
		return null
	shape = built
	_shape_key = key
	return shape


## §2.4. bake 판정의 본체. 자료형으로만 한다.
func is_bakeable() -> bool:
	if to_shape() == null:
		return false
	return shape.is_bakeable() and shape.points_match_rest(0.0)


# ── bake 경로 (§2.1) ─────────────────────────────────────────────────────

## Walks the parts in order and fuses their fields. Union comes from
## ProceduralSdf.smooth_min, not from overlapping opaque draws, otherwise the
## silhouette shows seams. Honours canvas_size, squash and facing.
func compose_canvas() -> ProceduralCanvas:
	var canvas: ProceduralCanvas = ProceduralCanvas.new(maxi(canvas_size.x, 1), maxi(canvas_size.y, 1))
	if parts.is_empty():
		return canvas
	if palette == null:
		push_error("ProceduralCreatureBuilder.compose_canvas: bake refused. set_palette() first.")
		return ProceduralCanvas.new(1, 1)
	if not is_bakeable():
		# §2.4. 조용히 구우지 않는다.
		push_error("ProceduralCreatureBuilder.compose_canvas: bake refused. points is not invariant.")
		return ProceduralCanvas.new(1, 1)
	_place_in_canvas()
	var base: ProceduralBodyPart = parts[0]
	var squash_scale: float = _squash_distance_scale()
	var depth: float = ProceduralBodyPart._SHADE_DEPTH * base.max_radius() * maxf(base.scale, 0.0001) * squash_scale
	var reach: int = ceili(depth) + 2
	var region: Rect2i = _clip(_union_extent().grow(float(MARGIN)), canvas, reach)
	if region.size.x <= 0 or region.size.y <= 0:
		return canvas
	var paint: Rect2i = region.intersection(Rect2i(0, 0, canvas.width, canvas.height))
	var union: PackedFloat32Array = PackedFloat32Array()
	union.resize(region.size.x * region.size.y)
	var cursor: int = 0
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			union[cursor] = _fused_distance(Vector2(float(x) + 0.5, float(y) + 0.5))
			cursor += 1
	ProceduralBodyPart._paint_distance(canvas, union, region, paint, ProceduralBodyPart._layers_for(
		palette, base.body_role, base.shade_role, base.rim_role, base.shade, depth, outline_width <= 0.0
	))
	for index: int in range(1, parts.size()):
		var part: ProceduralBodyPart = parts[index]
		if part.body_role == base.body_role:
			continue
		_paint_accent(canvas, index, squash_scale)
	if outline_width > 0.0:
		ProceduralBodyPart._paint_distance(canvas, union, region, paint, [
			[ProceduralBodyPart._LAYER_STROKE, palette.get_color(outline_role), outline_width],
		])
	return canvas


## 정규 형상의 월드 좌표는 그대로 두고, 그리기 자리만 캔버스 한가운데로 옮긴다.
## bake 전용이며 물리를 건드리지 않는다. 파트별 변환도 여기서 한 번 만든다.
func _place_in_canvas() -> void:
	var built: ProceduralShape = to_shape()
	_frames.clear()
	if built == null:
		return
	var extent: Rect2 = _shape_bounds()
	canvas_origin = (Vector2(canvas_size) * 0.5 - extent.get_center()).round()
	_pivot = Vector2(float(canvas_size.x) * 0.5, extent.end.y + canvas_origin.y)
	for index: int in parts.size():
		var part: ProceduralBodyPart = parts[index]
		var forward: Transform2D = Transform2D(0.0, canvas_origin) * _part_transform(built, index)
		_frames.append([forward.affine_inverse(), maxf(part.scale, 0.0001), part._geometry(), forward])


## 파트 실루엣 전체의 정규 형상 좌표 경계. squash / facing 전. bake 전용.
func _shape_bounds() -> Rect2:
	var built: ProceduralShape = to_shape()
	if built == null:
		return Rect2()
	var extent: Rect2 = Rect2()
	for index: int in parts.size():
		var part: ProceduralBodyPart = parts[index]
		var piece: Rect2 = ProceduralBodyPart._transformed_rect(
			_part_transform(built, index), part._silhouette_extent(part._geometry())
		)
		extent = piece if index == 0 else extent.merge(piece)
	return extent


## One closed contour of the fused silhouette, in canvas pixel space, wound
## consistently (clockwise on screen: positive shoelace area with y down).
## Marching squares over the same fused field compose_canvas() paints, so the
## contour follows squash and facing too. Points are never placed by hand.
## When the silhouette falls apart into islands, the largest one is returned.
func outline() -> PackedVector2Array:
	if not is_bakeable():
		push_error("ProceduralCreatureBuilder.outline: bake refused. points is not invariant.")
		return PackedVector2Array()
	_place_in_canvas()
	var extent: Rect2 = _union_extent().grow(float(MARGIN))
	var region: Rect2i = Rect2i(
		floori(extent.position.x), floori(extent.position.y),
		ceili(extent.end.x) - floori(extent.position.x), ceili(extent.end.y) - floori(extent.position.y)
	)
	return _marching_squares(_fused_field(), region, 0.0)


## compose_canvas() then to_texture(). One call, one texture, never again.
func compose() -> ImageTexture:
	if palette == null:
		push_error("ProceduralCreatureBuilder.compose: bake refused. set_palette() first.")
		return null
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

## 파트를 녹인 캔버스 공간 거리장. _place_in_canvas() 뒤에 쓴다. bake 전용.
func _fused_field() -> Callable:
	return func(p: Vector2) -> float:
		return _fused_distance(p)


## 정규 형상의 월드 좌표를 캔버스 픽셀로 옮기는 오프셋. bake 시 1회 계산한다.
## 정규 형상의 rest 는 바꾸지 않는다 — 정규 배열이 하나여야 한다. (§0)
var canvas_origin: Vector2 = Vector2.ZERO


## 최종 캔버스 점을 파트의 로컬 좌표로 되돌린다. facing → squash → 파트 변환 순서의 역.
func _to_local(canvas_point: Vector2, part: ProceduralBodyPart) -> Vector2:
	var index: int = _part_index(part)
	if index < 0 or index >= _frames.size():
		return canvas_point
	var inverse: Transform2D = _frames[index][0]
	return inverse * _unwarp(canvas_point)


## 파트의 노드 인덱스. 정규 형상의 노드는 parts 순서로 만들어진다.
func _part_index(part: ProceduralBodyPart) -> int:
	return parts.find(part)


func _part_origin(part: ProceduralBodyPart) -> Vector2:
	var index: int = _part_index(part)
	var built: ProceduralShape = to_shape()
	if index < 0 or built == null:
		return Vector2.ZERO
	return built.get_rest()[index]


## 파트의 **월드** 회전. part.angle 은 부모 기준 상대값이므로 그대로 쓰면 안 된다.
## 정규 형상의 rest_dir 가 누적 회전을 이미 갖고 있다.
func _part_world_angle(part: ProceduralBodyPart) -> float:
	var index: int = _part_index(part)
	var built: ProceduralShape = to_shape()
	if index < 0 or built == null:
		return deg_to_rad(part.angle)
	return built.get_rest_dir(index).angle()


## 칠하는 영역. 캔버스로 자른 픽셀 사각형.
func _union_rect() -> Rect2i:
	var extent: Rect2 = _union_extent().grow(float(MARGIN))
	var left: int = maxi(floori(extent.position.x), 0)
	var top: int = maxi(floori(extent.position.y), 0)
	var right: int = mini(ceili(extent.end.x), canvas_size.x)
	var bottom: int = mini(ceili(extent.end.y), canvas_size.y)
	return Rect2i(left, top, maxi(right - left, 0), maxi(bottom - top, 0))


## Marching squares over pixel centres of `region`. The border ring of samples is
## forced outside so every contour closes. Returns the largest closed loop,
## clockwise on screen (positive shoelace area, y down), with no repeated point.
func _marching_squares(field: Callable, region: Rect2i, level: float) -> PackedVector2Array:
	var cols: int = region.size.x
	var rows: int = region.size.y
	if cols < 3 or rows < 3:
		return PackedVector2Array()
	var values: PackedFloat32Array = PackedFloat32Array()
	values.resize(cols * rows)
	for gy: int in rows:
		for gx: int in cols:
			var value: float = float(field.call(_grid_point(region, gx, gy))) - level
			if gx == 0 or gy == 0 or gx == cols - 1 or gy == rows - 1:
				value = maxf(value, 0.001)
			values[gy * cols + gx] = value
	var crossing: Dictionary = {}
	var next_of: Dictionary = {}
	for cy: int in rows - 1:
		for cx: int in cols - 1:
			# 모서리 순회: T(TL→TR), R(TR→BR), B(BR→BL), L(BL→TL). 화면 기준 시계 방향.
			var corner_x: PackedInt32Array = PackedInt32Array([cx, cx + 1, cx + 1, cx])
			var corner_y: PackedInt32Array = PackedInt32Array([cy, cy, cy + 1, cy + 1])
			var edge_keys: PackedInt32Array = PackedInt32Array([
				(cy * cols + cx) * 2,
				(cy * cols + cx + 1) * 2 + 1,
				((cy + 1) * cols + cx) * 2,
				(cy * cols + cx) * 2 + 1,
			])
			var inside: Array[bool] = []
			var center: float = 0.0
			for corner: int in 4:
				var value: float = values[corner_y[corner] * cols + corner_x[corner]]
				inside.append(value < 0.0)
				center += value * 0.25
			var roles: PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
			var entries: int = 0
			for edge: int in 4:
				var a_in: bool = inside[edge]
				var b_in: bool = inside[(edge + 1) % 4]
				if a_in and not b_in:
					roles[edge] = -1
				elif b_in and not a_in:
					roles[edge] = 1
					entries += 1
			if entries == 0:
				continue
			for edge: int in 4:
				if roles[edge] == 0:
					continue
				var key: int = edge_keys[edge]
				if not crossing.has(key):
					crossing[key] = _edge_crossing(region, values, cols, key)
			for edge: int in 4:
				if roles[edge] != 1:
					continue
				var partner: int = -1
				if entries == 1:
					for other: int in 4:
						if roles[other] == -1:
							partner = other
				elif center < 0.0:
					partner = (edge + 3) % 4
				else:
					partner = (edge + 1) % 4
				if partner >= 0 and roles[partner] == -1:
					next_of[edge_keys[edge]] = edge_keys[partner]
	var best: PackedVector2Array = PackedVector2Array()
	var best_area: float = 0.0
	var visited: Dictionary = {}
	for start: Variant in next_of.keys():
		if visited.has(start):
			continue
		var loop: PackedVector2Array = PackedVector2Array()
		var key: Variant = start
		while key != null and not visited.has(key):
			visited[key] = true
			var point: Vector2 = crossing[key]
			if loop.is_empty() or loop[loop.size() - 1].distance_squared_to(point) > 0.0000001:
				loop.append(point)
			key = next_of.get(key, null)
		if loop.size() > 1 and loop[0].distance_squared_to(loop[loop.size() - 1]) <= 0.0000001:
			loop.remove_at(loop.size() - 1)
		var area: float = _signed_area(loop)
		if absf(area) > absf(best_area):
			best_area = area
			best = loop
	if best_area < 0.0:
		best.reverse()
	return best


## 파트 로컬 → 정규 형상 좌표. 위치 = rest, 방향 = rest_dir, 크기 = part.scale.
func _part_transform(built: ProceduralShape, index: int) -> Transform2D:
	var part: ProceduralBodyPart = parts[index]
	var size: float = maxf(part.scale, 0.0001)
	return Transform2D(built.get_rest_dir(index).angle(), built.get_rest()[index]) \
		* Transform2D(Vector2(size, 0.0), Vector2(0.0, size), Vector2.ZERO)


## _place_in_canvas() 뒤의 캔버스 거리. facing·squash 를 되돌리고 파트들을 녹인다.
func _fused_distance(canvas_point: Vector2) -> float:
	var local_point: Vector2 = _unwarp(canvas_point)
	var best: float = ProceduralBodyPart._FAR
	for index: int in _frames.size():
		var frame: Array = _frames[index]
		var part: ProceduralBodyPart = parts[index]
		var inverse: Transform2D = frame[0]
		var distance: float = part._distance(frame[2], inverse * local_point) * float(frame[1])
		best = ProceduralSdf.smooth_min(best, distance, part.fusion)
	return best * _squash_distance_scale()


## 한 파트만의 캔버스 거리. 녹이지 않은 자기 모양이다.
func _part_distance(canvas_point: Vector2, index: int) -> float:
	var frame: Array = _frames[index]
	var inverse: Transform2D = frame[0]
	return parts[index]._distance(frame[2], inverse * _unwarp(canvas_point)) * float(frame[1]) * _squash_distance_scale()


## body_role 이 바탕과 다른 파트를 자기 역할과 음영 스타일로 칠한다.
func _paint_accent(canvas: ProceduralCanvas, index: int, squash_scale: float) -> void:
	var part: ProceduralBodyPart = parts[index]
	var frame: Array = _frames[index]
	var depth: float = ProceduralBodyPart._SHADE_DEPTH * part.max_radius() * float(frame[1]) * squash_scale
	var extent: Rect2 = _warp_rect(ProceduralBodyPart._transformed_rect(frame[3], part._silhouette_extent(frame[2])))
	var region: Rect2i = _clip(extent.grow(part._paint_margin() + 1.0), canvas, ceili(depth) + 2)
	if region.size.x <= 0 or region.size.y <= 0:
		return
	var distance: PackedFloat32Array = PackedFloat32Array()
	distance.resize(region.size.x * region.size.y)
	var cursor: int = 0
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			distance[cursor] = _part_distance(Vector2(float(x) + 0.5, float(y) + 0.5), index)
			cursor += 1
	ProceduralBodyPart._paint_distance(
		canvas, distance, region, region.intersection(Rect2i(0, 0, canvas.width, canvas.height)),
		ProceduralBodyPart._layers_for(palette, part.body_role, part.shade_role, part.rim_role, part.shade, depth, true)
	)


## 최종 캔버스 점 → squash·facing 전의 캔버스 점.
func _unwarp(canvas_point: Vector2) -> Vector2:
	var point: Vector2 = canvas_point
	if facing < 0:
		point.x = 2.0 * _pivot.x - point.x
	var along: float = 1.0 - _squash_amount()
	if along != 1.0:
		point = _pivot + Vector2((point.x - _pivot.x) * along, (point.y - _pivot.y) / along)
	return point


## squash·facing 전의 캔버스 사각형 → 최종 캔버스 사각형.
func _warp_rect(rect: Rect2) -> Rect2:
	var along: float = 1.0 - _squash_amount()
	var left: float = _pivot.x + (rect.position.x - _pivot.x) / along
	var right: float = _pivot.x + (rect.end.x - _pivot.x) / along
	var top: float = _pivot.y + (rect.position.y - _pivot.y) * along
	var bottom: float = _pivot.y + (rect.end.y - _pivot.y) * along
	if facing < 0:
		var mirrored_left: float = 2.0 * _pivot.x - right
		right = 2.0 * _pivot.x - left
		left = mirrored_left
	return Rect2(left, top, right - left, bottom - top)


## 녹인 실루엣이 칠해질 수 있는 최종 캔버스 경계. 칠 여백과 윤곽선을 포함한다.
func _union_extent() -> Rect2:
	var extent: Rect2 = Rect2()
	var margin: float = 0.0
	for index: int in _frames.size():
		var part: ProceduralBodyPart = parts[index]
		var frame: Array = _frames[index]
		var piece: Rect2 = ProceduralBodyPart._transformed_rect(frame[3], part._silhouette_extent(frame[2]))
		extent = piece if index == 0 else extent.merge(piece)
		margin = maxf(margin, part._paint_margin())
	if outline_width > 0.0:
		margin = maxf(margin, outline_width * 0.5 + ProceduralBodyPart._EDGE_MARGIN)
	return _warp_rect(extent).grow(margin)


func _squash_amount() -> float:
	return clampf(squash, -ProceduralBodyPart.MAX_SQUASH_LOCAL, ProceduralBodyPart.MAX_SQUASH_LOCAL)


## squash 가 거리를 줄이는 최소 배율. 안티에일리어싱 폭을 픽셀로 맞춘다.
func _squash_distance_scale() -> float:
	var along: float = 1.0 - _squash_amount()
	return minf(along, 1.0 / along)


## 캔버스 밖으로는 음영 오프셋만큼만 넘치게 자른다.
static func _clip(extent: Rect2, canvas: ProceduralCanvas, reach: int) -> Rect2i:
	var left: int = maxi(floori(extent.position.x), -reach)
	var top: int = maxi(floori(extent.position.y), -reach)
	var right: int = mini(ceili(extent.end.x), canvas.width + reach)
	var bottom: int = mini(ceili(extent.end.y), canvas.height + reach)
	return Rect2i(left, top, maxi(right - left, 0), maxi(bottom - top, 0))


static func _grid_point(region: Rect2i, gx: int, gy: int) -> Vector2:
	return Vector2(float(region.position.x + gx) + 0.5, float(region.position.y + gy) + 0.5)


## 모서리 key 의 교차점. key = (격자점 인덱스) * 2 + (0 가로 → / 1 세로 ↓).
## 같은 모서리는 어느 칸에서 계산해도 같은 순서(왼→오, 위→아래)로 계산한다.
static func _edge_crossing(region: Rect2i, values: PackedFloat32Array, cols: int, key: int) -> Vector2:
	var point_index: int = key >> 1
	var gx: int = point_index % cols
	var gy: int = point_index / cols
	var other_index: int = point_index + (cols if (key & 1) == 1 else 1)
	var ox: int = other_index % cols
	var oy: int = other_index / cols
	var fa: float = values[point_index]
	var fb: float = values[other_index]
	var t: float = 0.5
	if fa != fb:
		t = clampf(fa / (fa - fb), 0.0, 1.0)
	return _grid_point(region, gx, gy).lerp(_grid_point(region, ox, oy), t)


static func _signed_area(loop: PackedVector2Array) -> float:
	var total: float = 0.0
	for index: int in loop.size():
		var a: Vector2 = loop[index]
		var b: Vector2 = loop[(index + 1) % loop.size()]
		total += a.x * b.y - b.x * a.y
	return total * 0.5


## 정규 형상을 다시 만들어야 하는지 판정하는 파트 값 서명.
func _parts_key() -> int:
	var key: int = ProceduralSeed.hash_int(parts.size())
	for part: ProceduralBodyPart in parts:
		key = ProceduralSeed.combine(key, ProceduralSeed.hash_text(JSON.stringify(part.to_dictionary(), "", true)))
		key = ProceduralSeed.combine(key, ProceduralSeed.hash_text("%d|%d|%s|%s" % [
			part.anchor_mode, part.anchor_parent, var_to_str(part.anchor_offset), String(part.id),
		]))
	return key
