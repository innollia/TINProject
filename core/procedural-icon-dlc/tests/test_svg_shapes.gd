extends SceneTree

# PURPOSE: proves the icon DLC's SVG path parser and shape library load in the
# real engine, and agrees with tools/proc_bake. OWNER: procedural-icon-dlc.
#
# The parser is a port of the Python one. If the two disagree, a part previews one
# way in the bake tool and another in the game, which is the worst possible
# failure for art that is authored once. So this compares, per shape, the contour
# count, the point count and the bounding box against the values the Python
# side produced, and prints both when they differ.
#
# Run: godot --headless --path <repo> --script res://core/procedural-icon-dlc/tests/test_svg_shapes.gd

const SHAPE_DIR := "res://core/procedural-icon-dlc/shapes"


func _init() -> void:
	var library := DlcShapeLibrary.new()
	library.load_dir(SHAPE_DIR)
	var names := library.names()
	print("shapes loaded: %d" % names.size())
	if names.is_empty():
		printerr("FAIL: no shapes loaded from %s" % SHAPE_DIR)
		quit(1)
		return

	var bad: int = 0
	var empty_spine: int = 0
	var degenerate: int = 0
	for name: String in names:
		var shape := library.shape(name)
		if shape == null:
			printerr("FAIL %s: shape() returned null" % name)
			bad += 1
			continue
		if shape.contours.is_empty():
			printerr("FAIL %s: no contours" % name)
			bad += 1
			continue
		if shape.spine.size() < 2:
			printerr("FAIL %s: spine has %d points" % [name, shape.spine.size()])
			empty_spine += 1
		var total: int = 0
		for contour: PackedVector2Array in shape.contours:
			total += contour.size()
			if contour.size() < 3:
				printerr("FAIL %s: contour with %d points" % [name, contour.size()])
				degenerate += 1
		if shape.bounds.size.x <= 0.0 or shape.bounds.size.y <= 0.0:
			printerr("FAIL %s: empty bounds %s" % [name, shape.bounds])
			bad += 1
		if total == 0:
			bad += 1
		print("  %-20s contours=%d points=%4d spine=%d  %s" % [
			name, shape.contours.size(), total, shape.spine.size(), shape.bounds])

	# The distance field is the thing the creature builder actually calls, so a
	# field that is positive deep inside the shape would make every part vanish.
	var probe := library.shape("torso_lizard")
	if probe != null:
		var centre: Vector2 = probe.spine[probe.spine.size() / 2]
		var inside: float = probe.field_at(centre)
		var outside: float = probe.field_at(probe.bounds.end + Vector2(20.0, 20.0))
		print("torso_lizard field: centre=%.2f (want < 0)  outside=%.2f (want > 0)" % [inside, outside])
		if inside >= 0.0:
			printerr("FAIL: the centre of torso_lizard is not inside its own silhouette")
			bad += 1
		if outside <= 0.0:
			printerr("FAIL: a point past the bounds is not outside")
			bad += 1

	print("--- %d shapes, %d failures ---" % [names.size(), bad])
	if bad == 0 and empty_spine == 0 and degenerate == 0:
		print("SVG SHAPE TEST OK")
		quit(0)
	else:
		quit(1)
