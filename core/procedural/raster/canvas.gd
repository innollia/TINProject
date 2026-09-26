class_name ProceduralCanvas
extends RefCounted

# PURPOSE: the pixel buffer every drawing step writes into. Straight RGBA8,
# top-left origin, no imported image anywhere. Kits never set pixels by hand;
# they call these primitives or ProceduralSdf.
# OWNER: W2 (core/procedural). PUBLIC SIGNATURES ARE FROZEN.
#
# A canvas is cheap to copy: copy_from() and shift() are the intended way to
# reuse a generated layer. blur() is a separable box blur and is meant for
# build time, not for a per frame path.

var width: int = 1
var height: int = 1
var pixels: PackedByteArray = PackedByteArray()


func _init(p_width: int = 1, p_height: int = 1) -> void:
	width = maxi(p_width, 1)
	height = maxi(p_height, 1)
	pixels.resize(width * height * 4)


func fill(color: Color) -> void:
	var r: int = _channel(color.r)
	var g: int = _channel(color.g)
	var b: int = _channel(color.b)
	var a: int = _channel(color.a)
	var index: int = 0
	var total: int = pixels.size()
	while index < total:
		pixels[index] = r
		pixels[index + 1] = g
		pixels[index + 2] = b
		pixels[index + 3] = a
		index += 4


func clear() -> void:
	pixels.fill(0)


func is_inside(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


func set_pixel(x: int, y: int, color: Color) -> void:
	if not is_inside(x, y):
		return
	var index: int = _offset(x, y)
	pixels[index] = _channel(color.r)
	pixels[index + 1] = _channel(color.g)
	pixels[index + 2] = _channel(color.b)
	pixels[index + 3] = _channel(color.a)


func get_pixel(x: int, y: int) -> Color:
	if not is_inside(x, y):
		return Color(0.0, 0.0, 0.0, 0.0)
	var index: int = _offset(x, y)
	return Color(
		float(pixels[index]) / 255.0,
		float(pixels[index + 1]) / 255.0,
		float(pixels[index + 2]) / 255.0,
		float(pixels[index + 3]) / 255.0
	)


## Source-over blend. `alpha` scales the colour's own alpha.
func blend_pixel(x: int, y: int, color: Color, alpha: float = 1.0) -> void:
	if not is_inside(x, y):
		return
	var src_a: float = clampf(color.a * alpha, 0.0, 1.0)
	if src_a <= 0.0:
		return
	var index: int = _offset(x, y)
	if src_a >= 1.0:
		pixels[index] = _channel(color.r)
		pixels[index + 1] = _channel(color.g)
		pixels[index + 2] = _channel(color.b)
		pixels[index + 3] = _channel(color.a)
		return
	var dst_r: float = float(pixels[index]) / 255.0
	var dst_g: float = float(pixels[index + 1]) / 255.0
	var dst_b: float = float(pixels[index + 2]) / 255.0
	var dst_a: float = float(pixels[index + 3]) / 255.0
	var out_a: float = src_a + dst_a * (1.0 - src_a)
	if out_a <= 0.0:
		pixels[index + 3] = 0
		return
	var carry: float = dst_a * (1.0 - src_a)
	pixels[index] = _channel((color.r * src_a + dst_r * carry) / out_a)
	pixels[index + 1] = _channel((color.g * src_a + dst_g * carry) / out_a)
	pixels[index + 2] = _channel((color.b * src_a + dst_b * carry) / out_a)
	pixels[index + 3] = _channel(out_a)


func fill_rect(rect: Rect2i, color: Color, alpha: float = 1.0) -> void:
	var left: int = maxi(rect.position.x, 0)
	var top: int = maxi(rect.position.y, 0)
	var right: int = mini(rect.end.x, width)
	var bottom: int = mini(rect.end.y, height)
	var y: int = top
	while y < bottom:
		var x: int = left
		while x < right:
			blend_pixel(x, y, color, alpha)
			x += 1
		y += 1


func draw_line(from: Vector2, to: Vector2, color: Color, thickness: float = 1.0) -> void:
	var radius: float = maxf(thickness, 0.5) * 0.5
	var steps: int = maxi(int(ceil(from.distance_to(to) * 2.0)), 1)
	for step: int in range(steps + 1):
		var point: Vector2 = from.lerp(to, float(step) / float(steps))
		_stamp_disc(point, radius, color)
		if radius <= 0.5:
			set_pixel(floori(point.x), floori(point.y), color)


## Even-odd scanline fill. Handles concave outlines and holes.
func draw_polygon(points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3:
		return
	var top: int = maxi(floori(_minimum_y(points)), 0)
	var bottom: int = mini(ceili(_maximum_y(points)), height)
	for y: int in range(top, bottom):
		var scan: float = float(y) + 0.5
		var crossings: PackedFloat32Array = PackedFloat32Array()
		var last: int = points.size() - 1
		for index: int in points.size():
			var a: Vector2 = points[index]
			var b: Vector2 = points[last]
			last = index
			if (a.y <= scan and b.y > scan) or (b.y <= scan and a.y > scan):
				var t: float = (scan - a.y) / (b.y - a.y)
				crossings.append(a.x + t * (b.x - a.x))
		crossings.sort()
		var pair: int = 0
		while pair + 1 < crossings.size():
			var x0: int = ceili(crossings[pair] - 0.5)
			var x1: int = floori(crossings[pair + 1] - 0.5)
			if x1 >= x0:
				fill_rect(Rect2i(x0, y, x1 - x0 + 1, 1), color)
			pair += 2


func draw_circle(center: Vector2, radius: float, color: Color) -> void:
	_stamp_disc(center, maxf(radius, 0.0), color)


func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var rx: float = absf(radius.x)
	var ry: float = absf(radius.y)
	if rx <= 0.0 or ry <= 0.0:
		return
	var top: int = maxi(floori(center.y - ry), 0)
	var bottom: int = mini(ceili(center.y + ry) + 1, height)
	for y: int in range(top, bottom):
		var dy: float = (float(y) + 0.5 - center.y) / ry
		if absf(dy) > 1.0:
			continue
		var span: float = rx * sqrt(maxf(1.0 - dy * dy, 0.0))
		var left: int = maxi(ceili(center.x - span - 0.5), 0)
		var right: int = mini(floori(center.x + span - 0.5) + 1, width)
		fill_rect(Rect2i(left, y, maxi(right - left, 0), 1), color)


## Separable box blur over RGBA including alpha, edges clamp. Build time only.
func blur(radius: int) -> void:
	if radius < 1:
		return
	var span: int = mini(radius, maxi(maxi(width, height), 1))
	var scratch: PackedByteArray = pixels.duplicate()
	_blur_axis(scratch, pixels, span, true)
	_blur_axis(pixels, scratch, span, false)


func posterize(levels: int) -> void:
	var steps: int = maxi(levels, 2) - 1
	var index: int = 0
	var total: int = pixels.size()
	while index < total:
		pixels[index] = _quantize(float(pixels[index]), steps)
		pixels[index + 1] = _quantize(float(pixels[index + 1]), steps)
		pixels[index + 2] = _quantize(float(pixels[index + 2]), steps)
		index += 4


func copy_from(source: ProceduralCanvas) -> void:
	width = source.width
	height = source.height
	pixels = source.pixels.duplicate()


## Copies source into this canvas at an offset, clipped to these bounds.
func shift(source: ProceduralCanvas, offset: Vector2i) -> void:
	var start_x: int = maxi(offset.x, 0)
	var start_y: int = maxi(offset.y, 0)
	var from_x: int = maxi(-offset.x, 0)
	var from_y: int = maxi(-offset.y, 0)
	var span_x: int = mini(width - start_x, source.width - from_x)
	var span_y: int = mini(height - start_y, source.height - from_y)
	for row: int in maxi(span_y, 0):
		var from: int = (from_y + row) * source.width * 4
		var to: int = (start_y + row) * width * 4
		for step: int in maxi(span_x, 0) * 4:
			pixels[to + step] = source.pixels[from + step]


## Tightest bounding box of the non transparent pixels, empty when fully clear.
func get_used_rect() -> Rect2i:
	var min_x: int = width
	var min_y: int = height
	var max_x: int = -1
	var max_y: int = -1
	for y: int in height:
		for x: int in width:
			if pixels[_offset(x, y) + 3] == 0:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < 0:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func to_image() -> Image:
	return Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, pixels)


func to_texture() -> ImageTexture:
	return ImageTexture.create_from_image(to_image())


func _offset(x: int, y: int) -> int:
	return (y * width + x) * 4


func _channel(value: float) -> int:
	return clampi(int(roundf(clampf(value, 0.0, 1.0) * 255.0)), 0, 255)


func _quantize(byte_value: float, steps: int) -> int:
	var level: int = int(roundf(byte_value / 255.0 * float(steps)))
	return clampi((level * 255) / steps, 0, 255)


func _minimum_y(points: PackedVector2Array) -> float:
	var lowest: float = points[0].y
	for point: Vector2 in points:
		lowest = minf(lowest, point.y)
	return lowest


func _maximum_y(points: PackedVector2Array) -> float:
	var highest: float = points[0].y
	for point: Vector2 in points:
		highest = maxf(highest, point.y)
	return highest


func _stamp_disc(center: Vector2, radius: float, color: Color) -> void:
	if radius <= 0.0:
		return
	var top: int = maxi(floori(center.y - radius), 0)
	var bottom: int = mini(ceili(center.y + radius) + 1, height)
	for y: int in range(top, bottom):
		var dy: float = float(y) + 0.5 - center.y
		if absf(dy) > radius:
			continue
		var span: float = sqrt(maxf(radius * radius - dy * dy, 0.0))
		var left: int = maxi(ceili(center.x - span - 0.5), 0)
		var right: int = mini(floori(center.x + span - 0.5) + 1, width)
		fill_rect(Rect2i(left, y, maxi(right - left, 0), 1), color)


## One separable box pass. source is read, target is written, both same size.
func _blur_axis(source: PackedByteArray, target: PackedByteArray, span: int, horizontal: bool) -> void:
	var outer: int = height if horizontal else width
	var inner: int = width if horizontal else height
	for outer_index: int in outer:
		for inner_index: int in inner:
			var red: int = 0
			var green: int = 0
			var blue: int = 0
			var alpha: int = 0
			var count: int = 0
			for offset_index: int in range(-span, span + 1):
				var sample: int = inner_index + offset_index
				if sample < 0 or sample >= inner:
					continue
				var x: int = sample if horizontal else outer_index
				var y: int = outer_index if horizontal else sample
				var base: int = (y * width + x) * 4
				red += source[base]
				green += source[base + 1]
				blue += source[base + 2]
				alpha += source[base + 3]
				count += 1
			if count == 0:
				continue
			var divisor: float = float(count)
			var base_out: int = (outer_index * width + inner_index) * 4
			target[base_out] = clampi(int(roundf(float(red) / divisor)), 0, 255)
			target[base_out + 1] = clampi(int(roundf(float(green) / divisor)), 0, 255)
			target[base_out + 2] = clampi(int(roundf(float(blue) / divisor)), 0, 255)
			target[base_out + 3] = clampi(int(roundf(float(alpha) / divisor)), 0, 255)
