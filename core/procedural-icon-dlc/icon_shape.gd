class_name DlcShape
extends RefCounted

# PURPOSE: one authored body part: its closed outline, its spine, and the
# distance field the silhouette is drawn from. OWNER: procedural-icon-dlc.
#
# Convention, shared with tools/proc_bake/procbake/shapes.py:
#   +X  growth direction; a child part attaches at the far end
#   y   downward, the screen convention
#   spine  the centreline a child hangs from, first point at the part's own origin
#
# The field is baked once into a small bitmap because GDScript has no
# vectorisation and an exact polygon distance costs one segment test per segment
# per sample. The bake path uses the exact version so a baked sprite has no
# resampling error in it; the rig path samples the bitmap through the inverse
# transform, which is what the engine already does with its analytic primitives.

var name: String = "shape"
var contours: Array[PackedVector2Array] = []
var spine: PackedVector2Array = PackedVector2Array()
var length: float = 0.0
var detail: bool = false
var bounds: Rect2 = Rect2()

## Padding around the part inside its field bitmap, in part-local px.
const FIELD_PAD: float = 2.0
## Field resolution, px per sample. 1.0 is exact enough; a bilinear read then
## adds well under a tenth of a pixel, and the antialias width is corrected by
## the smallest singular value of the transform anyway.
const FIELD_SCALE: float = 1.0

var _field: PackedFloat32Array = PackedFloat32Array()
var _field_origin: Vector2 = Vector2.ZERO
var _field_size: Vector2i = Vector2i.ZERO
var _field_ready: bool = false


func _init(p_name: String = "shape", p_contours: Array = [], p_meta: Dictionary = {}) -> void:
	name = p_name
	for entry: Variant in p_contours:
		contours.append(entry as PackedVector2Array)
	var raw_spine: String = String(p_meta.get("joints", ""))
	if raw_spine.is_empty():
		push_error("DlcShape '%s' has no data-joints." % p_name)
		return
	spine = _parse_points(raw_spine)
	detail = String(p_meta.get("detail", "0")) not in ["", "0", "false"]
	_rebase()
	_compute_bounds()


## Move everything so spine[0] is the origin, matching the frozen pose convention.
func _rebase() -> void:
	if spine.is_empty():
		return
	var origin: Vector2 = spine[0]
	for i: int in spine.size():
		spine[i] -= origin
	for i: int in contours.size():
		var moved := PackedVector2Array()
		for point: Vector2 in contours[i]:
			moved.append(point - origin)
		contours[i] = moved
	length = 0.0
	for i: int in range(1, spine.size()):
		length += spine[i].distance_to(spine[i - 1])


func _compute_bounds() -> void:
	var first := true
	for contour: PackedVector2Array in contours:
		if contour.is_empty():
			continue
		var r := _contour_bounds(contour)
		bounds = r if first else bounds.merge(r)
		first = false


static func _contour_bounds(contour: PackedVector2Array) -> Rect2:
	var lo: Vector2 = contour[0]
	var hi: Vector2 = contour[0]
	for point: Vector2 in contour:
		lo = Vector2(minf(lo.x, point.x), minf(lo.y, point.y))
		hi = Vector2(maxf(hi.x, point.x), maxf(hi.y, point.y))
	return Rect2(lo, hi - lo)


## Point at normalised arc length `t` along the spine.
func spine_at(t: float) -> Vector2:
	if spine.size() == 1:
		return spine[0]
	var lengths := PackedFloat32Array()
	var total: float = 0.0
	for i: int in range(1, spine.size()):
		var d: float = spine[i].distance_to(spine[i - 1])
		lengths.append(d)
		total += d
	if total <= 0.000001:
		return spine[0]
	var want: float = clampf(t, 0.0, 1.0) * total
	var acc: float = 0.0
	for i: int in lengths.size():
		if acc + lengths[i] >= want or i == lengths.size() - 1:
			var local: float = (want - acc) / maxf(lengths[i], 0.000001)
			return spine[i].lerp(spine[i + 1], local)
		acc += lengths[i]
	return spine[spine.size() - 1]


func spine_dir_at(t: float) -> Vector2:
	var a: Vector2 = spine_at(maxf(t - 0.06, 0.0))
	var b: Vector2 = spine_at(minf(t + 0.06, 1.0))
	var d: Vector2 = b - a
	if d.length() <= 0.000001:
		return Vector2.RIGHT
	return d.normalized()


## Exact signed distance to the outline, part-local px. Negative inside.
## Even-odd fill, so a hole in the outline stays a hole. Build time only.
func _distance_exact(point: Vector2) -> float:
	var best: float = 1.0e6
	var inside := false
	for contour: PackedVector2Array in contours:
		if contour.size() < 3:
			continue
		best = minf(best, _contour_distance(contour, point))
		if _point_in(contour, point):
			inside = not inside
	return -best if inside else best


static func _contour_distance(contour: PackedVector2Array, point: Vector2) -> float:
	var best: float = 1.0e6
	var n: int = contour.size()
	for i: int in n:
		var a: Vector2 = contour[i]
		var b: Vector2 = contour[(i + 1) % n]
		var ab: Vector2 = b - a
		var denom: float = ab.dot(ab)
		var h: float = 0.0
		if denom > 0.000001:
			h = clampf((point - a).dot(ab) / denom, 0.0, 1.0)
		best = minf(best, point.distance_to(a + ab * h))
	return best


static func _point_in(contour: PackedVector2Array, point: Vector2) -> bool:
	var inside := false
	var n: int = contour.size()
	for i: int in n:
		var a: Vector2 = contour[i]
		var b: Vector2 = contour[(i + 1) % n]
		if (a.y > point.y) != (b.y > point.y):
			var x: float = a.x + (point.y - a.y) / (b.y - a.y) * (b.x - a.x)
			if point.x < x:
				inside = not inside
	return inside


## Bake the field once. Bounds plus padding, one sample per pixel at FIELD_SCALE.
func ensure_field() -> void:
	if _field_ready:
		return
	_field_ready = true
	var rect: Rect2 = bounds.grow(FIELD_PAD)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	_field_origin = rect.position
	_field_size = Vector2i(maxi(ceili(rect.size.x / FIELD_SCALE), 1), maxi(ceili(rect.size.y / FIELD_SCALE), 1))
	_field.resize(_field_size.x * _field_size.y)
	for y: int in _field_size.y:
		for x: int in _field_size.x:
			var sample: Vector2 = _field_origin + Vector2(
				(float(x) + 0.5) * FIELD_SCALE, (float(y) + 0.5) * FIELD_SCALE)
			_field[y * _field_size.x + x] = _distance_exact(sample)


## Signed distance, part-local px, from the baked field. ALWAYS O(1).
##
## The creature builder asks every part for a distance at every pixel of the
## canvas, so the overwhelmingly common question is about a point far outside
## the part. Falling back to the exact distance there is O(segments) for a
## question that does not need the answer: at 340x230 with eleven parts it is
## hundreds of millions of segment tests in GDScript and the bake simply dies.
##
## Instead, clamp the point onto the field rect, read the field there, and add
## the distance travelled. That is the standard lower bound on the true distance
## and it is exact wherever the outline is locally flat, which is all the
## antialiasing needs. A union takes the minimum, so a loose value off to the
## side can never eat into a neighbour.
func field_at(point: Vector2) -> float:
	if not _field_ready:
		ensure_field()
	if _field_size == Vector2i.ZERO:
		return 1.0e6
	var fx: float = (point.x - _field_origin.x) / FIELD_SCALE - 0.5
	var fy: float = (point.y - _field_origin.y) / FIELD_SCALE - 0.5
	var cx: float = clampf(fx, 0.0, float(_field_size.x - 1))
	var cy: float = clampf(fy, 0.0, float(_field_size.y - 1))
	var x0: int = int(floorf(cx))
	var y0: int = int(floorf(cy))
	var x1: int = mini(x0 + 1, _field_size.x - 1)
	var y1: int = mini(y0 + 1, _field_size.y - 1)
	var tx: float = cx - float(x0)
	var ty: float = cy - float(y0)
	var w: int = _field_size.x
	var d00: float = _field[y0 * w + x0]
	var d10: float = _field[y0 * w + x1]
	var d01: float = _field[y1 * w + x0]
	var d11: float = _field[y1 * w + x1]
	var base: float = lerpf(lerpf(d00, d10, tx), lerpf(d01, d11, tx), ty)
	# how far outside the field this sample is, in px
	var ox: float = maxf(0.0, maxf(-fx, fx - float(_field_size.x - 1)))
	var oy: float = maxf(0.0, maxf(-fy, fy - float(_field_size.y - 1)))
	return base + sqrt(ox * ox + oy * oy) * FIELD_SCALE


## Contours placed into world space, for the exact bake path.
func transformed(position: Vector2, rotation: float, scale_factor: float, squash: Array = []) -> Array[PackedVector2Array]:
	var basis := Transform2D(rotation, position) * Transform2D(Vector2(scale_factor, 0.0), Vector2(0.0, scale_factor), Vector2.ZERO)
	if squash.size() == 3:
		var along: float = squash[0]
		var across: float = squash[1]
		var axis: float = squash[2]
		if along != 1.0 or across != 1.0:
			var squeeze := Transform2D(Vector2(along, 0.0), Vector2(0.0, across), Vector2.ZERO)
			basis = basis * Transform2D(axis, Vector2.ZERO).affine_inverse() * squeeze * Transform2D(axis, Vector2.ZERO)
	var out: Array[PackedVector2Array] = []
	for contour: PackedVector2Array in contours:
		var moved := PackedVector2Array()
		for point: Vector2 in contour:
			moved.append(basis * point)
		out.append(moved)
	return out


static func _parse_points(text: String) -> PackedVector2Array:
	var numbers := PackedFloat32Array()
	for piece: String in text.replace(",", " ").split(" ", false):
		numbers.append(float(piece))
	var out := PackedVector2Array()
	var i := 0
	while i + 1 < numbers.size():
		out.append(Vector2(numbers[i], numbers[i + 1]))
		i += 2
	return out
