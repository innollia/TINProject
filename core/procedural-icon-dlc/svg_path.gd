class_name DlcSvgPath
extends RefCounted

# PURPOSE: parses a body part SVG into flat polygon contours and its spine.
# OWNER: procedural-icon-dlc. This fork's only addition to the shape vocabulary.
#
# Why this exists: the frozen DlcProceduralBodyPart geometry is CAPSULE / TRIANGLE
# / BOX, and that is why a procedurally built animal comes out of it looking like
# a stack of pills. A silhouette has to be a drawn outline, so a part can now name
# an authored SVG instead of a length and two radii, and this turns that file
# into the same thing DlcProceduralSdf consumes: closed contours in part-local
# pixels, +X growth, y downward.
#
# The grammar is the subset a hand-authored part needs - M L H V C S Q T Z and
# their lowercase forms, with implicit repeated commands. Arcs are rejected rather
# than guessed at, because a silently mis-parsed curve becomes a hole in a limb.
#
# Convention shared with tools/proc_bake/procbake/svgpath.py. The two parsers must
# agree or a shape previews differently in the bake tool and in the game.

## Flatness tolerance for curve subdivision, in part-local px.
const TOLERANCE: float = 0.08
const MIN_STEPS: int = 2
const MAX_STEPS: int = 24

## Reads an SVG and returns {"contours": Array[PackedVector2Array], "meta": Dictionary}.
static func read(path: String) -> Dictionary:
	var text: String = FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("DlcSvgPath.read: cannot read '%s'." % path)
		return {"contours": [], "meta": {}}
	var contours: Array[PackedVector2Array] = []
	var meta: Dictionary = {}
	var attribute := RegEx.new()
	attribute.compile("data-([A-Za-z0-9_-]+)=\"([^\"]*)\"")
	for found: RegExMatch in attribute.search_all(text):
		meta[String(found.get_string(1))] = String(found.get_string(2))
	var tag := RegEx.new()
	tag.compile("<path[^>]*\\sd=\"([^\"]*)\"")
	var found_tag: Array[RegExMatch] = tag.search_all(text)
	if found_tag.is_empty():
		push_error("DlcSvgPath.read: '%s' has no <path d=\"...\">." % path)
		return {"contours": [], "meta": meta}
	for hit: RegExMatch in found_tag:
		contours.append_array(parse_path(String(hit.get_string(1))))
	return {"contours": contours, "meta": meta}


## Flattens one `d` attribute into closed contours (the closing point is not repeated).
static func parse_path(d: String) -> Array[PackedVector2Array]:
	var token := RegEx.new()
	token.compile("[MmLlHhVvCcSsQqTtZz]|-?(?:\\d+\\.?\\d*|\\.\\d+)(?:[eE][-+]?\\d+)?")
	var out: Array[PackedVector2Array] = []
	var contour := PackedVector2Array()
	var cursor := Vector2.ZERO
	var start := Vector2.ZERO
	var last_cubic := Vector2.ZERO
	var last_quad := Vector2.ZERO
	var has_cubic := false
	var has_quad := false
	var command := ""
	var index := 0
	var words: Array[String] = []
	for match: RegExMatch in token.search_all(d):
		words.append(match.get_string())
	while index < words.size():
		var piece: String = words[index]
		if piece.length() == 1 and _is_command(piece):
			command = piece
			index += 1
			if command.to_lower() == "z":
				if contour.size() >= 3:
					out.append(contour)
				contour = PackedVector2Array()
				cursor = start
				has_cubic = false
				has_quad = false
				continue
		elif command.is_empty():
			push_error("DlcSvgPath.parse_path: path starts with a number.")
			break
		var relative: bool = command == command.to_lower()
		var upper: String = command.to_upper()
		var values: Array[float] = []
		var needed := _arity(upper)
		while values.size() < needed:
			# Test the character set, not the length: a single digit number is one
			# character long, and "M 0,0" - which is how most parts start - was
			# rejected as a command and reported as a truncated path.
			if index >= words.size() or _is_command(words[index]):
				push_error("DlcSvgPath.parse_path: path ended inside '%s'." % command)
				return out
			values.append(float(words[index]))
			index += 1
		match upper:
			"M":
				cursor = _step(cursor, relative, values[0], values[1])
				if contour.size() >= 3:
					out.append(contour)
				contour = PackedVector2Array([cursor])
				start = cursor
				command = "l" if relative else "L"
				has_cubic = false
				has_quad = false
			"L":
				cursor = _step(cursor, relative, values[0], values[1])
				contour.append(cursor)
				has_cubic = false
				has_quad = false
			"H":
				cursor = Vector2(cursor.x + (values[0] if relative else 0.0), cursor.y)
				contour.append(cursor)
				has_cubic = false
				has_quad = false
			"V":
				cursor = Vector2(cursor.x, cursor.y + (values[0] if relative else 0.0))
				contour.append(cursor)
				has_cubic = false
				has_quad = false
			"C":
				var c1 := _step(cursor, relative, values[0], values[1])
				var c2 := _step(cursor, relative, values[2], values[3])
				var end := _step(cursor, relative, values[4], values[5])
				_append_cubic(contour, cursor, c1, c2, end)
				last_cubic = c2
				has_cubic = true
				has_quad = false
				cursor = end
			"S":
				var c2 := _step(cursor, relative, values[0], values[1])
				var end := _step(cursor, relative, values[2], values[3])
				var c1 := cursor * 2.0 - last_cubic if has_cubic else cursor
				_append_cubic(contour, cursor, c1, c2, end)
				last_cubic = c2
				has_cubic = true
				has_quad = false
				cursor = end
			"Q":
				var c1 := _step(cursor, relative, values[0], values[1])
				var end := _step(cursor, relative, values[2], values[3])
				_append_quad(contour, cursor, c1, end)
				last_quad = c1
				has_quad = true
				has_cubic = false
				cursor = end
			"T":
				var end := _step(cursor, relative, values[0], values[1])
				var c1 := cursor * 2.0 - last_quad if has_quad else cursor
				_append_quad(contour, cursor, c1, end)
				last_quad = c1
				has_quad = true
				has_cubic = false
				cursor = end
			_:
				push_error("DlcSvgPath.parse_path: unsupported command '%s'." % command)
				return out
	if contour.size() >= 3:
		out.append(contour)
	return out


static func _is_command(piece: String) -> bool:
	return "MmLlHhVvCcSsQqTtZz".contains(piece)


static func _arity(upper: String) -> int:
	match upper:
		"M", "L", "T":
			return 2
		"H", "V":
			return 1
		"S", "Q":
			return 4
		"C":
			return 6
	return 2


static func _step(cursor: Vector2, relative: bool, x: float, y: float) -> Vector2:
	return Vector2(cursor.x + x, cursor.y + y) if relative else Vector2(x, y)


static func _steps_for(flatness: float) -> int:
	if flatness <= TOLERANCE:
		return MIN_STEPS
	return mini(MAX_STEPS, maxi(MIN_STEPS, int(ceil(sqrt(flatness / TOLERANCE) * 2.0))))


static func _append_cubic(out: PackedVector2Array, p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2) -> void:
	var flatness: float = 0.75 * maxf(maxf(p0.distance_to(p1), p1.distance_to(p2)), p2.distance_to(p3))
	var steps: int = _steps_for(flatness)
	for i in range(1, steps + 1):
		out.append(_cubic_at(p0, p1, p2, p3, float(i) / float(steps)))


static func _append_quad(out: PackedVector2Array, p0: Vector2, p1: Vector2, p2: Vector2) -> void:
	var flatness: float = 0.5 * maxf(p0.distance_to(p1), p1.distance_to(p2))
	var steps: int = _steps_for(flatness)
	for i in range(1, steps + 1):
		var t := float(i) / float(steps)
		var u := 1.0 - t
		out.append(Vector2(
			u * u * p0.x + 2.0 * u * t * p1.x + t * t * p2.x,
			u * u * p0.y + 2.0 * u * t * p1.y + t * t * p2.y))


static func _cubic_at(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u := 1.0 - t
	var a := u * u * u
	var b := 3.0 * u * u * t
	var c := 3.0 * u * t * t
	var d := t * t * t
	return Vector2(
		a * p0.x + b * p1.x + c * p2.x + d * p3.x,
		a * p0.y + b * p1.y + c * p2.y + d * p3.y)
