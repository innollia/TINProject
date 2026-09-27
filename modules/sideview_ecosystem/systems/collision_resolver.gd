class_name EcoCollisionResolver
extends RefCounted

const EPS: float = 0.01

var room: EcoRoomSpec
var world: EcoWorldState
var plates_open: Dictionary = {}
var _consumed_rows: Dictionary = {}
var _colliders: Array[Rect2] = []
var _gap_holes: Array[Dictionary] = []


func setup(p_room: EcoRoomSpec, p_world: EcoWorldState) -> void:
	room = p_room
	world = p_world
	rebuild()


func rebuild() -> void:
	_consumed_rows.clear()
	_colliders.clear()
	_gap_holes.clear()
	if room == null:
		return
	for t: Dictionary in room.triggers:
		if world != null and world.is_consumed(str(t["id"])):
			var c: Vector2i = t["cell"]
			var s: Vector2i = t["span"]
			for x: int in range(c.x, c.x + s.x):
				_consumed_rows[Vector2i(x, c.y + s.y - 1)] = true
	for p: EcoPassageSpec in room.passages:
		var r: Rect2 = p.rect_px()
		match p.kind:
			EcoPassageKind.GAP:
				var drops: int = int(world.drift_drops.get(p.id, 0)) if world != null else 0
				var w_gap: float = EcoPassageResolver.gap_width_px(p, room.target_body_px, drops)
				var mid: float = r.position.x + r.size.x * 0.5
				var left: Rect2 = Rect2(r.position.x, r.position.y, maxf(0.0, mid - w_gap * 0.5 - r.position.x), EcoBodyRung.TILE)
				var right_x: float = mid + w_gap * 0.5
				var right: Rect2 = Rect2(right_x, r.position.y, maxf(0.0, r.end.x - right_x), EcoBodyRung.TILE)
				if left.size.x > 0.0:
					_colliders.append(left)
				if right.size.x > 0.0:
					_colliders.append(right)
				_gap_holes.append({"id": p.id, "rect": Rect2(mid - w_gap * 0.5, r.position.y, w_gap, r.size.y), "w_gap": w_gap})
			EcoPassageKind.STEP:
				_colliders.append(Rect2(r.position.x, r.end.y - p.height_px, r.size.x, p.height_px))
			EcoPassageKind.BREAK:
				if world == null or not world.is_wall_broken(p.id):
					_colliders.append(r)
			EcoPassageKind.PRESS:
				if not bool(plates_open.get(p.id, false)):
					_colliders.append(Rect2(r.position.x, r.position.y, r.size.x, EcoBodyRung.TILE))


func tile_kind(x: int, y: int) -> int:
	var k: int = room.tile_at(x, y)
	if k < 0:
		return EcoTileKind.EMPTY
	if _consumed_rows.has(Vector2i(x, y)):
		return EcoTileKind.EMPTY
	return k


func _tile_blocks(x: int, y: int, down: bool, prev_bottom: float, drop_through: bool) -> bool:
	var k: int = tile_kind(x, y)
	if EcoTileKind.is_solid(k):
		return true
	if EcoTileKind.is_one_way(k):
		return down and not drop_through and prev_bottom <= y * EcoBodyRung.TILE + EPS
	return false


func overlaps(aabb: Rect2, down: bool = false, prev_bottom: float = INF, drop_through: bool = false) -> Array[Rect2]:
	var hits: Array[Rect2] = []
	var t: float = EcoBodyRung.TILE
	var x0: int = floori((aabb.position.x + EPS) / t)
	var x1: int = floori((aabb.end.x - EPS) / t)
	var y0: int = floori((aabb.position.y + EPS) / t)
	var y1: int = floori((aabb.end.y - EPS) / t)
	for y: int in range(y0, y1 + 1):
		for x: int in range(x0, x1 + 1):
			if _tile_blocks(x, y, down, prev_bottom, drop_through):
				hits.append(Rect2(x * t, y * t, t, t))
	for c: Rect2 in _colliders:
		if c.grow(-EPS).intersects(aabb):
			hits.append(c)
	return hits


func is_free(aabb: Rect2) -> bool:
	return overlaps(aabb).is_empty()


func move_x(aabb: Rect2, dx: float) -> Dictionary:
	var moved: Rect2 = Rect2(aabb.position + Vector2(dx, 0.0), aabb.size)
	var hits: Array[Rect2] = overlaps(moved)
	if hits.is_empty():
		return {"aabb": moved, "blocked": false}
	var x: float = moved.position.x
	for h: Rect2 in hits:
		if dx > 0.0:
			x = minf(x, h.position.x - aabb.size.x)
		elif dx < 0.0:
			x = maxf(x, h.end.x)
	if dx == 0.0:
		x = aabb.position.x
	return {"aabb": Rect2(Vector2(x, aabb.position.y), aabb.size), "blocked": true}


func move_y(aabb: Rect2, dy: float, drop_through: bool) -> Dictionary:
	var moved: Rect2 = Rect2(aabb.position + Vector2(0.0, dy), aabb.size)
	var down: bool = dy > 0.0
	var hits: Array[Rect2] = overlaps(moved, down, aabb.end.y, drop_through)
	if hits.is_empty():
		return {"aabb": moved, "blocked": false, "grounded": false}
	var y: float = moved.position.y
	for h: Rect2 in hits:
		if down:
			y = minf(y, h.position.y - aabb.size.y)
		else:
			y = maxf(y, h.end.y)
	return {"aabb": Rect2(Vector2(aabb.position.x, y), aabb.size), "blocked": true, "grounded": down}


func ground_below(aabb: Rect2) -> bool:
	var probe: Rect2 = Rect2(aabb.position.x, aabb.end.y, aabb.size.x, 1)
	return not overlaps(probe, true, aabb.end.y, false).is_empty()


func tile_under(aabb: Rect2) -> int:
	var t: float = EcoBodyRung.TILE
	return tile_kind(floori((aabb.position.x + aabb.size.x * 0.5) / t), floori((aabb.end.y + 1) / t))


func in_soil(aabb: Rect2) -> bool:
	var t: float = EcoBodyRung.TILE
	var c: Vector2 = aabb.get_center()
	return tile_kind(floori(c.x / t), floori(c.y / t)) == EcoTileKind.SOIL


func gap_hole_at(aabb: Rect2) -> Dictionary:
	for g: Dictionary in _gap_holes:
		if (g["rect"] as Rect2).intersects(aabb):
			return g
	return {}


func plate_under(aabb: Rect2) -> String:
	var probe: Rect2 = Rect2(aabb.position.x, aabb.end.y, aabb.size.x, 2.0)
	for p: EcoPassageSpec in room.passages:
		if p.kind == EcoPassageKind.PRESS and not bool(plates_open.get(p.id, false)):
			var r: Rect2 = p.rect_px()
			if Rect2(r.position.x, r.position.y, r.size.x, EcoBodyRung.TILE).intersects(probe):
				return p.id
	return ""


func break_wall_near(aabb: Rect2, facing: int, reach: float) -> EcoPassageSpec:
	var probe: Rect2 = Rect2(aabb.end.x if facing > 0 else aabb.position.x - reach, aabb.position.y, reach, aabb.size.y)
	for p: EcoPassageSpec in room.passages:
		if p.kind == EcoPassageKind.BREAK and (world == null or not world.is_wall_broken(p.id)):
			if p.rect_px().intersects(probe):
				return p
	return null
