class_name ProceduralSdf
extends RefCounted

# PURPOSE: signed distance shapes and the rasterisation of a distance field
# into a ProceduralCanvas. Soft unions and smooth outlines come from here, so
# a squishy silhouette is a math fact, not a drawn guess.
# OWNER: W2 (core/procedural). PUBLIC SIGNATURES ARE FROZEN.
#
# Every primitive takes the sample point first and returns the distance in
# pixels: negative inside, zero on the boundary, positive outside.
# The `*_field` helpers take a Callable that receives a Vector2 pixel centre
# and returns that distance, so any composition of primitives can be painted.

const DEFAULT_FEATHER: float = 1.0


static func circle(p: Vector2, center: Vector2, radius: float) -> float:
	return p.distance_to(center) - radius


## Approximate ellipse distance. Scale error grows far from the boundary; use
## it for fills and shadows, not for cutout outlines.
static func ellipse(p: Vector2, center: Vector2, radius: Vector2) -> float:
	var rx: float = maxf(absf(radius.x), 0.0001)
	var ry: float = maxf(absf(radius.y), 0.0001)
	return (((p - center) / Vector2(rx, ry)).length() - 1.0) * minf(rx, ry)


static func segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var pa: Vector2 = p - a
	var ba: Vector2 = b - a
	var denom: float = ba.dot(ba)
	var h: float = clampf(pa.dot(ba) / denom, 0.0, 1.0) if denom > 0.000001 else 0.0
	return (pa - ba * h).length()


static func capsule(p: Vector2, a: Vector2, b: Vector2, radius: float) -> float:
	return segment(p, a, b) - radius


static func box(p: Vector2, center: Vector2, half_size: Vector2) -> float:
	var d: Vector2 = (p - center).abs() - half_size
	return Vector2(maxf(d.x, 0.0), maxf(d.y, 0.0)).length() + minf(maxf(d.x, d.y), 0.0)


static func rounded_box(p: Vector2, center: Vector2, half_size: Vector2, corner: float) -> float:
	return box(p, center, half_size - Vector2(corner, corner)) - corner


## Signed distance to the nearest triangle edge. Exact on the edges and signed
## correctly inside and outside; not the exact Euclidean field in the corner
## regions, which is why it is meant for triangle rigs, not soft blobs.
static func triangle(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> float:
	var nearest: float = minf(minf(segment(p, a, b), segment(p, b, c)), segment(p, a, c))
	var w0: float = _cross(b - a, p - a)
	var w1: float = _cross(c - b, p - b)
	var w2: float = _cross(a - c, p - c)
	var inside: bool = (w0 >= 0.0 and w1 >= 0.0 and w2 >= 0.0) or (w0 <= 0.0 and w1 <= 0.0 and w2 <= 0.0)
	return -nearest if inside else nearest


static func _cross(a: Vector2, b: Vector2) -> float:
	return a.x * b.y - a.y * b.x


## Polynomial smooth minimum: the soft blend that makes blobs breathe.
static func smooth_min(a: float, b: float, blend: float) -> float:
	if blend <= 0.0:
		return minf(a, b)
	var h: float = clampf(0.5 + 0.5 * (b - a) / blend, 0.0, 1.0)
	return lerpf(b, a, h) - blend * h * (1.0 - h)


static func smooth_max(a: float, b: float, blend: float) -> float:
	return -smooth_min(-a, -b, blend)


## Antialiased 0..1 coverage for a distance, `feather` wide.
static func coverage(distance: float, feather: float = DEFAULT_FEATHER) -> float:
	return clampf(0.5 - distance / maxf(feather, 0.0001), 0.0, 1.0)


## Fills every pixel of `bounds` where the field is inside.
static func stamp_field(canvas: ProceduralCanvas, field: Callable, bounds: Rect2i, color: Color, feather: float = DEFAULT_FEATHER) -> void:
	var span: float = maxf(feather, 0.0001)
	for y: int in range(maxi(bounds.position.y, 0), mini(bounds.end.y, canvas.height)):
		for x: int in range(maxi(bounds.position.x, 0), mini(bounds.end.x, canvas.width)):
			var cov: float = coverage(float(field.call(Vector2(x + 0.5, y + 0.5))), span)
			if cov > 0.0:
				canvas.blend_pixel(x, y, color, cov)


## Strokes the field outline with a `width` pixel band.
static func stroke_field(canvas: ProceduralCanvas, field: Callable, bounds: Rect2i, width: float, color: Color) -> void:
	var half: float = maxf(width, 0.1) * 0.5
	for y: int in range(maxi(bounds.position.y, 0), mini(bounds.end.y, canvas.height)):
		for x: int in range(maxi(bounds.position.x, 0), mini(bounds.end.x, canvas.width)):
			var distance: float = float(field.call(Vector2(x + 0.5, y + 0.5)))
			var cov: float = coverage(absf(distance) - half, DEFAULT_FEATHER)
			if cov > 0.0:
				canvas.blend_pixel(x, y, color, cov)


## Offset soft shadow. Fully removed where the shape itself covers the pixel.
static func shadow_field(canvas: ProceduralCanvas, field: Callable, bounds: Rect2i, offset: Vector2, softness: float, color: Color, strength: float = 1.0) -> void:
	var feather: float = maxf(softness, 0.0001)
	for y: int in range(maxi(bounds.position.y, 0), mini(bounds.end.y, canvas.height)):
		for x: int in range(maxi(bounds.position.x, 0), mini(bounds.end.x, canvas.width)):
			var point: Vector2 = Vector2(x + 0.5, y + 0.5)
			var distance: float = float(field.call(point))
			var cov: float = coverage(float(field.call(point - offset)), feather)
			if distance < 0.0:
				cov = maxf(cov - 1.0, 0.0)
			cov = clampf(cov * strength, 0.0, 1.0)
			if cov > 0.0:
				canvas.blend_pixel(x, y, color, cov)
