extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")

const CONTRAST_MIN: float = 0.42
const PALETTE_VARIANTS: int = 8
const BACKDROP_RES: float = 0.25
const BOX_TILE: int = 8
const OUTLINE: float = 1.0
const LAYER_COUNTS: Dictionary = {"far": 7, "near": 9, "fore": 4}
const MOTIFS: Array[StringName] = [&"tower", &"arch", &"cup", &"key", &"stack", &"tooth"]

const MATERIAL_ROLE: Dictionary = {
	"paper": &"paper", "glass": &"glass", "wood": &"wood", "stone": &"stone", "iron": &"iron",
	"clockwork": &"clockwork", "wax": &"wax", "void": &"void", "goal": &"goal",
}


static func contrast(a: Color, b: Color) -> float:
	return absf(a.get_luminance() - b.get_luminance())


static func palette_roles(parallax_seed: int) -> Dictionary:
	var stream: ProceduralSeed = Procedural.derive_seed(parallax_seed, "ppp.palette")
	var palette: ProceduralPalette = null
	for variant: int in PALETTE_VARIANTS:
		var candidate: ProceduralPalette = Procedural.make_palette(stream, variant)
		if contrast(candidate.get_color(ProceduralPalette.ROLE_INK), candidate.get_color(ProceduralPalette.ROLE_SKY_FAR)) >= CONTRAST_MIN:
			palette = candidate
			break
	if palette == null:
		palette = Procedural.make_palette(stream, 0)
	var near: Color = palette.get_color(ProceduralPalette.ROLE_SKY_FAR)
	var scale: float = 1.0
	while contrast(palette.get_color(ProceduralPalette.ROLE_INK), near) < CONTRAST_MIN and scale < 3.0:
		scale += 0.1
		near = palette.shifted(ProceduralPalette.ROLE_SKY_FAR, scale, 0.8)
	var fog: Color = palette.get_color(ProceduralPalette.ROLE_FOG)
	var roles: Dictionary = {
		&"base": fog,
		&"bg_far": fog.lerp(near, 0.5),
		&"bg_near": near,
		&"bg_fore": palette.get_color(ProceduralPalette.ROLE_SKY_NEAR),
		&"ink": palette.get_color(ProceduralPalette.ROLE_INK),
		&"ink_dim": palette.get_color(ProceduralPalette.ROLE_BODY_DARK),
		&"accent": palette.get_color(ProceduralPalette.ROLE_ACCENT),
		&"goal": palette.get_color(ProceduralPalette.ROLE_KEY_LIGHT),
		&"danger": palette.get_color(ProceduralPalette.ROLE_DANGER),
		&"player": palette.get_color(ProceduralPalette.ROLE_RIM),
		&"paper": palette.get_color(ProceduralPalette.ROLE_BELLY),
		&"glass": fog.lerp(palette.get_color(ProceduralPalette.ROLE_RIM), 0.35),
		&"wood": palette.get_color(ProceduralPalette.ROLE_BODY),
		&"stone": palette.get_color(ProceduralPalette.ROLE_GROUND),
		&"iron": palette.get_color(ProceduralPalette.ROLE_SHADE),
		&"clockwork": palette.get_color(ProceduralPalette.ROLE_ACCENT),
		&"wax": palette.shifted(ProceduralPalette.ROLE_BELLY, 0.9, 0.6),
		&"void": palette.get_color(ProceduralPalette.ROLE_INK),
	}
	var glass: Color = roles[&"glass"]
	glass.a = 0.62
	roles[&"glass"] = glass
	var hollow: Color = roles[&"void"]
	hollow.a = 0.4
	roles[&"void"] = hollow
	return roles


static func fill_role(kind: int, material: String) -> StringName:
	match kind:
		BodyKind.TILE_STATIC:
			return &"ink"
		BodyKind.TILE_KINEMATIC:
			return &"ink_dim"
		BodyKind.OBJECTIVE:
			return &"goal"
		BodyKind.HAZARD_STATIC, BodyKind.HAZARD_AREA:
			return &"danger"
		BodyKind.PLAYER:
			return &"player"
		BodyKind.TOOL_PLACEMENT:
			return &"accent"
	return StringName(MATERIAL_ROLE.get(material, &"wood"))


static func box_stylebox(fill: Color, ink: Color) -> StyleBoxTexture:
	var canvas: ProceduralCanvas = Procedural.make_canvas(BOX_TILE, BOX_TILE)
	var half := Vector2(BOX_TILE, BOX_TILE) * 0.5
	var field: Callable = func(point: Vector2) -> float: return ProceduralSdf.box(point, half, half - Vector2(0.5, 0.5))
	var bounds := Rect2i(0, 0, BOX_TILE, BOX_TILE)
	ProceduralSdf.stamp_field(canvas, field, bounds, fill, 0.5)
	ProceduralSdf.stroke_field(canvas, field, bounds, OUTLINE, ink)
	var style := StyleBoxTexture.new()
	style.texture = canvas.to_texture()
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 2.0)
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return style


static func shape_field(shape: String, size: Vector2, points: PackedVector2Array, center: Vector2) -> Callable:
	match shape:
		"circle":
			var radius: float = size.x * 0.5 - 0.5
			return func(point: Vector2) -> float: return ProceduralSdf.circle(point, center, radius)
		"capsule":
			var radius_c: float = size.x * 0.5 - 0.5
			var reach: float = maxf(size.y * 0.5 - size.x * 0.5, 0.0)
			var top := center + Vector2(0.0, -reach)
			var bottom := center + Vector2(0.0, reach)
			return func(point: Vector2) -> float: return ProceduralSdf.capsule(point, top, bottom, radius_c)
		"triangle":
			var a := center + Vector2(-size.x * 0.5 + 0.5, size.y * 0.5 - 0.5)
			var b := center + Vector2(size.x * 0.5 - 0.5, size.y * 0.5 - 0.5)
			var c := center + Vector2(0.0, -size.y * 0.5 + 0.5)
			return func(point: Vector2) -> float: return ProceduralSdf.triangle(point, a, b, c)
		"hull":
			var shifted := PackedVector2Array()
			for p: Vector2 in points:
				shifted.append(p + center)
			return func(point: Vector2) -> float: return _convex_distance(point, shifted)
	var half: Vector2 = size * 0.5 - Vector2(0.5, 0.5)
	return func(point: Vector2) -> float: return ProceduralSdf.box(point, center, half)


static func _convex_distance(point: Vector2, hull: PackedVector2Array) -> float:
	var worst: float = -INF
	for index: int in hull.size():
		var a: Vector2 = hull[index]
		var b: Vector2 = hull[(index + 1) % hull.size()]
		var edge: Vector2 = b - a
		var normal := Vector2(edge.y, -edge.x).normalized()
		worst = maxf(worst, (point - a).dot(normal))
	return worst


static func shape_texture(shape: String, size: Vector2, points: PackedVector2Array, fill: Color, ink: Color) -> ImageTexture:
	var extent: Vector2 = size
	if shape == "hull":
		var rect := Rect2(points[0], Vector2.ZERO)
		for p: Vector2 in points:
			rect = rect.expand(p)
		extent = Vector2(maxf(absf(rect.position.x), absf(rect.end.x)), maxf(absf(rect.position.y), absf(rect.end.y))) * 2.0
	var width: int = maxi(ceili(extent.x) + 2, 2)
	var height: int = maxi(ceili(extent.y) + 2, 2)
	var canvas: ProceduralCanvas = Procedural.make_canvas(width, height)
	var center := Vector2(width, height) * 0.5
	var field: Callable = shape_field(shape, size, points, center)
	var bounds := Rect2i(0, 0, width, height)
	ProceduralSdf.stamp_field(canvas, field, bounds, fill, 1.0)
	ProceduralSdf.stroke_field(canvas, field, bounds, OUTLINE, ink)
	return canvas.to_texture()


static func wedge_texture(radius: float, segments: int, color: Color) -> ImageTexture:
	var size: int = ceili(radius * 2.0) + 4
	var canvas: ProceduralCanvas = Procedural.make_canvas(size, size)
	var center := Vector2(size, size) * 0.5
	var sweep: float = TAU / float(maxi(segments, 1))
	var gap: float = 0.08 if segments > 1 else 0.0
	var outer: float = radius
	var inner: float = radius * 0.72
	var field: Callable = func(point: Vector2) -> float:
		var offset: Vector2 = point - center
		var ring: float = maxf(offset.length() - outer, inner - offset.length())
		if segments <= 1:
			return ring
		var angle: float = fposmod(atan2(offset.y, offset.x) + PI * 0.5, TAU)
		var edge: float = maxf(gap - angle, angle - (sweep - gap)) * offset.length()
		return maxf(ring, edge)
	ProceduralSdf.stamp_field(canvas, field, Rect2i(0, 0, size, size), color, 1.0)
	return canvas.to_texture()


static func ring_texture(radius: float, width: float, color: Color) -> ImageTexture:
	var size: int = ceili(radius * 2.0) + 4
	var canvas: ProceduralCanvas = Procedural.make_canvas(size, size)
	var center := Vector2(size, size) * 0.5
	var field: Callable = func(point: Vector2) -> float: return ProceduralSdf.circle(point, center, radius)
	ProceduralSdf.stroke_field(canvas, field, Rect2i(0, 0, size, size), width, color)
	return canvas.to_texture()


static func dot_texture(radius: float, color: Color) -> ImageTexture:
	var size: int = ceili(radius * 2.0) + 2
	var canvas: ProceduralCanvas = Procedural.make_canvas(size, size)
	var center := Vector2(size, size) * 0.5
	var field: Callable = func(point: Vector2) -> float: return ProceduralSdf.circle(point, center, radius)
	ProceduralSdf.stamp_field(canvas, field, Rect2i(0, 0, size, size), color, 1.0)
	return canvas.to_texture()


static func pattern_tile(tile: int, radius: float, color: Color) -> ImageTexture:
	var canvas: ProceduralCanvas = Procedural.make_canvas(tile, tile)
	var center := Vector2(tile, tile) * 0.5
	var field: Callable = func(point: Vector2) -> float: return ProceduralSdf.circle(point, center, radius)
	ProceduralSdf.stamp_field(canvas, field, Rect2i(0, 0, tile, tile), color, 1.0)
	return canvas.to_texture()


static func frame_texture(size: Vector2i, border: int, color: Color) -> ImageTexture:
	var canvas: ProceduralCanvas = Procedural.make_canvas(size.x, size.y)
	var half := Vector2(size) * 0.5
	var inner: Vector2 = half - Vector2(border, border)
	var field: Callable = func(point: Vector2) -> float: return -ProceduralSdf.box(point, half, inner)
	ProceduralSdf.stamp_field(canvas, field, Rect2i(Vector2i.ZERO, size), color, 1.0)
	return canvas.to_texture()


static func backdrop_elements(parallax_seed: int, layer: String, bounds: Rect2, camera_y: float, apparent: float, view: Vector2, color: Color) -> Array[Dictionary]:
	var stream: ProceduralSeed = Procedural.derive_seed(parallax_seed, "ppp.backdrop." + layer)
	var rng: RandomNumberGenerator = stream.make_rng()
	var count: int = int(LAYER_COUNTS.get(layer, 6))
	var cam_min: float = bounds.position.x + view.x * 0.5
	var cam_max: float = maxf(bounds.end.x - view.x * 0.5, cam_min)
	var span_min: float = cam_min * apparent - view.x * 0.5
	var span_max: float = cam_max * apparent + view.x * 0.5
	var result: Array[Dictionary] = []
	for index: int in count:
		var motif: StringName = MOTIFS[rng.randi_range(0, MOTIFS.size() - 1)]
		var size: Vector2 = _motif_size(layer, rng)
		var slot: float = (float(index) + rng.randf_range(0.15, 0.85)) / float(count)
		var x: float = lerpf(span_min, span_max, slot)
		var screen_bottom: float = _screen_bottom(layer, rng, view)
		var screen_y: float = screen_bottom - size.y * 0.5
		if layer == "fore" and index % 2 == 1:
			screen_y = size.y * 0.5 - rng.randf_range(20.0, 90.0)
		var rest := Vector2(x, screen_y + camera_y * apparent - view.y * 0.5)
		result.append({"rest": rest, "size": size, "motif": motif, "texture": _motif_texture(motif, size, color, rng)})
	return result


static func _motif_size(layer: String, rng: RandomNumberGenerator) -> Vector2:
	match layer:
		"far":
			return Vector2(rng.randf_range(160.0, 340.0), rng.randf_range(240.0, 480.0))
		"near":
			return Vector2(rng.randf_range(80.0, 190.0), rng.randf_range(120.0, 300.0))
	return Vector2(rng.randf_range(50.0, 110.0), rng.randf_range(180.0, 360.0))


static func _screen_bottom(layer: String, rng: RandomNumberGenerator, view: Vector2) -> float:
	match layer:
		"far":
			return view.y * rng.randf_range(0.78, 0.92)
		"near":
			return view.y * rng.randf_range(0.86, 1.0)
	return view.y + rng.randf_range(10.0, 60.0)


static func _motif_texture(motif: StringName, size: Vector2, color: Color, rng: RandomNumberGenerator) -> ImageTexture:
	var width: int = maxi(ceili(size.x * BACKDROP_RES), 4)
	var height: int = maxi(ceili(size.y * BACKDROP_RES), 4)
	var canvas: ProceduralCanvas = Procedural.make_canvas(width, height)
	var w: float = float(width)
	var h: float = float(height)
	var c := Vector2(w, h) * 0.5
	var lean: float = rng.randf_range(-0.12, 0.12) * w
	var field: Callable
	match motif:
		&"tower":
			var face: float = w * rng.randf_range(0.22, 0.32)
			field = func(p: Vector2) -> float:
				var body: float = ProceduralSdf.rounded_box(p, c + Vector2(0.0, h * 0.08), Vector2(w * 0.32, h * 0.42), w * 0.08)
				var head: float = ProceduralSdf.circle(p, Vector2(c.x + lean * 0.3, h * 0.2), face + w * 0.06)
				var hole: float = ProceduralSdf.circle(p, Vector2(c.x + lean * 0.3, h * 0.2), face * 0.55)
				return maxf(ProceduralSdf.smooth_min(body, head, w * 0.08), -hole)
		&"arch":
			field = func(p: Vector2) -> float:
				var block: float = ProceduralSdf.box(p, c + Vector2(0.0, h * 0.1), Vector2(w * 0.46, h * 0.4))
				var bite: float = ProceduralSdf.ellipse(p, Vector2(c.x, h * 0.95), Vector2(w * 0.28, h * 0.5))
				return maxf(block, -bite)
		&"cup":
			field = func(p: Vector2) -> float:
				var bowl: float = maxf(ProceduralSdf.ellipse(p, Vector2(c.x - w * 0.08, h * 0.45), Vector2(w * 0.36, h * 0.4)), h * 0.35 - p.y)
				var handle: float = absf(ProceduralSdf.circle(p, Vector2(c.x + w * 0.3, h * 0.6), w * 0.13)) - w * 0.04
				var foot: float = ProceduralSdf.box(p, Vector2(c.x - w * 0.08, h * 0.92), Vector2(w * 0.22, h * 0.06))
				return minf(minf(bowl, handle), foot)
		&"key":
			field = func(p: Vector2) -> float:
				var bow: float = absf(ProceduralSdf.circle(p, Vector2(c.x, h * 0.2), w * 0.3)) - w * 0.08
				var shaft: float = ProceduralSdf.box(p, Vector2(c.x, h * 0.6), Vector2(w * 0.07, h * 0.36))
				var bit: float = ProceduralSdf.box(p, Vector2(c.x + w * 0.14, h * 0.85), Vector2(w * 0.12, h * 0.05))
				return minf(minf(bow, shaft), bit)
		&"stack":
			var tilt: float = rng.randf_range(-0.1, 0.1)
			field = func(p: Vector2) -> float:
				var best: float = INF
				for level: int in 4:
					var y: float = h * (0.88 - 0.22 * float(level))
					var width_step: float = w * (0.46 - 0.05 * float(level))
					best = minf(best, ProceduralSdf.box(p, Vector2(c.x + tilt * w * float(level), y), Vector2(width_step, h * 0.1)))
				return best
		_:
			field = func(p: Vector2) -> float:
				return ProceduralSdf.triangle(p, Vector2(w * 0.08, h - 1.0), Vector2(w * 0.92, h - 1.0), Vector2(c.x + lean, 1.0))
	ProceduralSdf.stamp_field(canvas, field, Rect2i(0, 0, width, height), color, 1.0)
	return canvas.to_texture()
