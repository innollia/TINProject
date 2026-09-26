class_name StoneStoryInk
extends RefCounted


static func area(pts: PackedVector2Array) -> float:
	var n: int = pts.size()
	if n < 3:
		return 0.0
	var s: float = 0.0
	for i in n:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[(i + 1) % n]
		s += a.x * b.y - b.x * a.y
	return absf(s) * 0.5


static func bounds(pts: PackedVector2Array) -> Rect2:
	if pts.is_empty():
		return Rect2()
	var r := Rect2(pts[0], Vector2.ZERO)
	for p in pts:
		r = r.expand(p)
	return r


static func to_points(raw: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for q in raw:
		var a: Array = q
		if a.size() >= 2:
			out.append(Vector2(float(a[0]), float(a[1])))
	return out


static func place(pts: PackedVector2Array, origin: Vector2, scale: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(pts.size())
	for i in pts.size():
		out[i] = origin + pts[i] * scale
	return out


static func fill(ci: CanvasItem, pts: PackedVector2Array, col: Color,
		stats: StoneStoryDrawStats = null, height_ratio: float = 0.0) -> bool:
	if pts.size() < 3:
		return false
	if Geometry2D.triangulate_polygon(pts).is_empty():
		return false
	ci.draw_colored_polygon(pts, col)
	if stats != null:
		stats.note_shape(int(area(pts)), col, height_ratio)
	return true


static func edge(ci: CanvasItem, pts: PackedVector2Array, col: Color, width: float = 1.2) -> void:
	if pts.size() < 2:
		return
	var loop := pts.duplicate()
	loop.append(pts[0])
	ci.draw_polyline(loop, col, width, true)


static func beam(ci: CanvasItem, a: Vector2, b: Vector2, wa: float, wb: float, col: Color,
		stats: StoneStoryDrawStats = null) -> void:
	var d: Vector2 = b - a
	if d.length_squared() < 0.0001:
		return
	var n: Vector2 = Vector2(-d.y, d.x).normalized()
	var quad := PackedVector2Array([a + n * wa * 0.5, b + n * wb * 0.5, b - n * wb * 0.5, a - n * wa * 0.5])
	ci.draw_colored_polygon(quad, col)
	if stats != null:
		stats.note_shape(int(d.length() * (wa + wb) * 0.5), col)


static func disc(ci: CanvasItem, c: Vector2, r: float, col: Color, stats: StoneStoryDrawStats = null) -> void:
	if r <= 0.05:
		return
	ci.draw_circle(c, r, col, true, -1.0, true)
	if stats != null:
		stats.note_shape(int(PI * r * r), col)


static func ellipse(c: Vector2, rx: float, ry: float, n: int = 20, rot: float = 0.0) -> PackedVector2Array:
	var out := PackedVector2Array()
	var cr: float = cos(rot)
	var sr: float = sin(rot)
	for i in n:
		var t: float = TAU * float(i) / float(n)
		var x: float = cos(t) * rx
		var y: float = sin(t) * ry
		out.append(c + Vector2(x * cr - y * sr, x * sr + y * cr))
	return out


static func chaikin(pts: PackedVector2Array, iterations: int, amount: float = 0.25) -> PackedVector2Array:
	var cur := pts
	var q: float = clampf(amount, 0.05, 0.45)
	for it in iterations:
		var nxt := PackedVector2Array()
		var n: int = cur.size()
		for i in n:
			var a: Vector2 = cur[i]
			var b: Vector2 = cur[(i + 1) % n]
			nxt.append(a.lerp(b, q))
			nxt.append(a.lerp(b, 1.0 - q))
		cur = nxt
	return cur


static func layers(ci: CanvasItem, layer_list: Array, pal: ProceduralPalette, origin: Vector2,
		scale: Vector2, stats: StoneStoryDrawStats = null, tint: Color = Color(1, 1, 1, 1),
		height_ratio: float = 0.0) -> void:
	var sx: float = absf(scale.x)
	for layer in layer_list:
		var l: Dictionary = layer
		var col: Color = StoneStoryPalette.role(pal, str(l.get("role", "wall"))) * tint
		if l.has("fill"):
			var pts: PackedVector2Array = place(to_points(l["fill"]), origin, scale)
			fill(ci, pts, col, stats, height_ratio)
		elif l.has("beams"):
			for b in l["beams"]:
				var v: Array = b
				beam(ci, origin + Vector2(float(v[0]), float(v[1])) * scale,
						origin + Vector2(float(v[2]), float(v[3])) * scale,
						float(v[4]) * sx, float(v[5]) * sx, col, stats)
		elif l.has("joints"):
			for j in l["joints"]:
				var v: Array = j
				disc(ci, origin + Vector2(float(v[0]), float(v[1])) * scale, float(v[2]) * sx, col, stats)


static func layer_bounds(layer_list: Array) -> Rect2:
	var r := Rect2()
	var first: bool = true
	for layer in layer_list:
		var l: Dictionary = layer
		var pts := PackedVector2Array()
		if l.has("fill"):
			pts = to_points(l["fill"])
		elif l.has("beams"):
			for b in l["beams"]:
				var v: Array = b
				pts.append(Vector2(float(v[0]), float(v[1])))
				pts.append(Vector2(float(v[2]), float(v[3])))
		elif l.has("joints"):
			for j in l["joints"]:
				var v: Array = j
				pts.append(Vector2(float(v[0]), float(v[1])))
		for p in pts:
			if first:
				r = Rect2(p, Vector2.ZERO)
				first = false
			else:
				r = r.expand(p)
	return r
