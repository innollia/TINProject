extends SceneTree

# PURPOSE: writes the DLC's view of every shape so it can be diffed against the
# Python bake tool's view. OWNER: procedural-icon-dlc.
#
# The two parsers are separate implementations of one grammar. If they disagree
# a body part previews one way in the bake tool and another in the game, and the
# art is authored once - so this is a contract test, not a nicety. A one point
# difference on a closed contour is the closing point, which the Python side
# dedupes and PackedVector2Array keeps; the widths and spines must match exactly.
#
# Run: godot --headless --path <repo> --script res://core/procedural-icon-dlc/tests/dump_shapes.gd

const SHAPE_DIR := "res://core/procedural-icon-dlc/shapes"
const OUT := "res://core/procedural-icon-dlc/tests/godot_shapes.json"


func _init() -> void:
	var library := DlcShapeLibrary.new()
	library.load_dir(SHAPE_DIR)
	var rows: Dictionary = {}
	for name: String in library.names():
		var shape := library.shape(name)
		var points: int = 0
		for contour: PackedVector2Array in shape.contours:
			points += contour.size()
		rows[name] = {
			"contours": shape.contours.size(),
			"points": points,
			"spine": shape.spine.size(),
			"w": snappedf(shape.bounds.size.x, 0.01),
			"h": snappedf(shape.bounds.size.y, 0.01),
			"spine_length": snappedf(shape.length, 0.05),
		}
	var file := FileAccess.open(OUT, FileAccess.WRITE)
	if file == null:
		printerr("cannot write %s" % OUT)
		quit(1)
		return
	file.store_string(JSON.stringify(rows, "  "))
	file.close()
	print("wrote %d shapes to %s" % [rows.size(), OUT])
	quit(0)
