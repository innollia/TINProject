class_name DlcShapeLibrary
extends RefCounted

# PURPOSE: the body part library, loaded from authored SVGs. OWNER: procedural-icon-dlc.
# 정본: tools/proc_bake/procbake/shapes.py 는 같은 규약을 읽는다.
#
# A shape is a drawing, not a number. The frozen DlcProceduralBodyPart derives its
# silhouette from a length and two radii, which is why a procedural animal built
# from it reads as a stack of pills; a part instead names one of these and gets
# the outline that was actually drawn.
#
# The field. `field_at()` is an exact polygon distance, but GDScript has no
# vectorisation: one contour of 140 segments means 140 segment tests per sample,
# and the creature builder samples every pixel of every part. That is fine for a
# one-shot bake and useless per frame. So each shape bakes its distance into a
# small bitmap ONCE, on first use, and `field_at()` samples that; an exact
# `_distance_exact()` stays available for the bake path and for tests. A Kit that
# animates a part with squash gets the bitmap sampled through the inverse
# transform, which is what the engine already does with its analytic primitives -
# the antialias width is then corrected by the smallest singular value.

const BAKES_DIR := "res://core/procedural-icon-dlc/shapes"

var shapes: Dictionary = {}
var sources: Dictionary = {}

## The one instance a part reaches for when a spec only names a shape. Loading
## 44 SVGs is a load-time cost a Kit should not have to pay per part, and passing
## a library through every spec would change the frozen configure() signature.
static var shared: DlcShapeLibrary = null


## Lazily built default library, loaded from BAKES_DIR. Names: `default_library()`.
static func default_library() -> DlcShapeLibrary:
	if shared == null:
		shared = DlcShapeLibrary.new()
		shared.load_dir(BAKES_DIR)
	return shared


func load_dir(dir_path: String) -> int:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("DlcShapeLibrary.load_dir: cannot open '%s'." % dir_path)
		return 0
	var loaded: int = 0
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".svg"):
			continue
		var shape := load_file(dir_path.path_join(file_name))
		if shape != null:
			loaded += 1
	return loaded


func load_file(path: String) -> DlcShape:
	var parsed := DlcSvgPath.read(path)
	var contours: Array = parsed.get("contours", [])
	if contours.is_empty():
		push_error("DlcShapeLibrary.load_file: '%s' produced no contours." % path)
		return null
	var meta: Dictionary = parsed.get("meta", {})
	var name := String(meta.get("name", path.get_file().get_basename()))
	var shape := DlcShape.new(name, contours, meta)
	shapes[name] = shape
	sources[name] = path
	return shape


## Named `shape`, not `get`: GDScript cannot resolve an override of Object.get()
## (it is a built-in property accessor with a different signature) and the
## script fails to parse with "Could not resolve external class member get".
func shape(shape_name: String) -> DlcShape:
	if not shapes.has(shape_name):
		var near: Array[String] = []
		for key: String in shapes:
			if shape_name in key:
				near.append(key)
		var hint := ""
		if not near.is_empty():
			hint = "; did you mean %s?" % [near]
		push_error("DlcShapeLibrary.shape: unknown shape '%s'%s" % [shape_name, hint])
		return null
	return shapes[shape_name]


func has(shape_name: String) -> bool:
	return shapes.has(shape_name)


func names() -> Array[String]:
	var out: Array[String] = []
	for key: String in shapes:
		out.append(key)
	out.sort()
	return out
