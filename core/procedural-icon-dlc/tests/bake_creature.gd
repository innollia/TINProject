extends SceneTree

# PURPOSE: the fork's whole point, end to end. Builds a creature whose parts are
# the AUTHORED SVG outlines - not the frozen CAPSULE / TRIANGLE / BOX geometry -
# and writes the PNG, so the claim "a part can be a drawing somebody made" is
# demonstrated rather than asserted.
# OWNER: procedural-icon-dlc.
#
# Two creatures from the same spec structure:
#   shape:  every part names an SVG
#   prim:   every part uses length + radii, i.e. what the frozen system can do
# Baking both and putting them side by side shows exactly what the fork buys.
#
# Run: godot --headless --path <repo> --script res://core/procedural-icon-dlc/tests/bake_creature.gd

const OUT := "user://dlc_bake"


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var made := 0
	for variant: String in ["shape", "prim"]:
		var canvas := _build(variant)
		if canvas == null:
			continue
		var path: String = "%s/creature_%s.png" % [OUT, variant]
		var image: Image = canvas.to_image()
		var err: int = image.save_png(ProjectSettings.globalize_path(path))
		var used: Rect2i = canvas.get_used_rect()
		print("%-6s -> %s  err=%d  %dx%d  used=%s" % [
			variant, path.get_file(), err, canvas.width, canvas.height, str(used)])
		if err == 0:
			made += 1
	print("wrote %d/2 PNGs to %s" % [made, ProjectSettings.globalize_path(OUT)])
	quit(0 if made == 2 else 1)


func _build(variant: String) -> DlcProceduralCanvas:
	var stream := DlcProcedural.derive_seed(7, "dlc.probe." + variant)
	var palette := DlcProcedural.make_palette(stream)
	var builder := DlcProceduralCreatureBuilder.new(Vector2i(340, 230))
	builder.set_palette(palette)
	builder.outline_width = 3.0
	builder.fusion = 3.2
	for part: DlcProceduralBodyPart in _parts(variant):
		builder.add_part(part)
	var built: DlcProceduralShape = builder.to_shape()
	for index: int in builder.parts.size():
		var p: DlcProceduralBodyPart = builder.parts[index]
		print("  %-8s rest=(%7.1f,%7.1f) dir=%6.1f  at=%.2f angle=%6.1f scale=%.2f shape=%s" % [
			p.id, built.get_rest()[index].x, built.get_rest()[index].y,
			rad_to_deg(built.get_rest_dir(index).angle()), p.at, p.angle, p.scale,
			("yes" if p.has_shape() else "no")])
	var canvas: DlcProceduralCanvas = builder.compose_canvas()
	if canvas == null or canvas.width <= 1:
		return null
	return canvas


func _parts(variant: String) -> Array[DlcProceduralBodyPart]:
	var spec: Array = [
		{"id": "torso", "shape": "torso_lizard", "at": 0.0, "angle": 0.0},
		{"id": "head", "shape": "head_blunt", "parent": "torso", "at": 0.02, "angle": -20.0},
		{"id": "jaw", "shape": "head_sharp", "parent": "head", "at": 0.9, "angle": -12.0, "scale": 0.7},
		{"id": "eye", "shape": "eye_lens", "parent": "head", "at": 0.3, "angle": 0.0, "scale": 1.2,
			"body_role": "key_light", "detail": true},
		{"id": "tail", "shape": "tail_taper", "parent": "torso", "at": 1.0, "angle": -4.0},
		{"id": "femur_f", "shape": "limb_femur", "parent": "torso", "at": 0.27, "angle": 96.0,
			"scale": 0.72, "follow": "rigid"},
		{"id": "shin_f", "shape": "limb_shin", "parent": "femur_f", "at": 1.0, "angle": -11.0,
			"scale": 0.70, "follow": "rigid"},
		{"id": "foot_f", "shape": "foot_claw", "parent": "shin_f", "at": 1.0, "angle": -85.0,
			"scale": 0.70, "follow": "rigid"},
		{"id": "femur_b", "shape": "limb_femur", "parent": "torso", "at": 0.72, "angle": 93.0,
			"scale": 0.76, "follow": "rigid"},
		{"id": "shin_b", "shape": "limb_shin", "parent": "femur_b", "at": 1.0, "angle": -9.0,
			"scale": 0.72, "follow": "rigid"},
		{"id": "foot_b", "shape": "foot_claw", "parent": "shin_b", "at": 1.0, "angle": -84.0,
			"scale": 0.74, "follow": "rigid"},
	]
	var prim: Array = [
		{"id": "torso", "kind": "torso", "length": 120.0, "base_radius": 50.0, "tip_radius": 44.0},
		{"id": "head", "kind": "head", "parent": "torso", "at": 0.0, "angle": -20.0,
			"length": 46.0, "base_radius": 34.0, "tip_radius": 26.0},
		{"id": "jaw", "kind": "head", "parent": "head", "at": 0.9, "angle": -12.0, "scale": 0.7,
			"length": 46.0, "base_radius": 34.0, "tip_radius": 26.0},
		{"id": "eye", "kind": "eye", "parent": "head", "at": 0.3, "scale": 1.2, "detail": true,
			"body_role": "key_light", "length": 20.0, "base_radius": 16.0, "tip_radius": 12.0},
		{"id": "tail", "kind": "tail", "parent": "torso", "at": 1.0, "angle": -4.0,
			"length": 96.0, "base_radius": 30.0, "tip_radius": 2.0},
		{"id": "femur_f", "kind": "limb", "parent": "torso", "at": 0.27, "angle": 96.0,
			"scale": 0.72, "follow": "rigid", "length": 62.0, "base_radius": 24.0, "tip_radius": 16.0},
		{"id": "shin_f", "kind": "limb", "parent": "femur_f", "at": 1.0, "angle": -11.0,
			"scale": 0.70, "follow": "rigid", "length": 56.0, "base_radius": 16.0, "tip_radius": 9.0},
		{"id": "foot_f", "kind": "limb", "parent": "shin_f", "at": 1.0, "angle": -85.0,
			"scale": 0.70, "follow": "rigid", "length": 40.0, "base_radius": 16.0, "tip_radius": 12.0},
		{"id": "femur_b", "kind": "limb", "parent": "torso", "at": 0.72, "angle": 93.0,
			"scale": 0.76, "follow": "rigid", "length": 62.0, "base_radius": 24.0, "tip_radius": 16.0},
		{"id": "shin_b", "kind": "limb", "parent": "femur_b", "at": 1.0, "angle": -9.0,
			"scale": 0.72, "follow": "rigid", "length": 56.0, "base_radius": 16.0, "tip_radius": 9.0},
		{"id": "foot_b", "kind": "limb", "parent": "shin_b", "at": 1.0, "angle": -84.0,
			"scale": 0.74, "follow": "rigid", "length": 40.0, "base_radius": 16.0, "tip_radius": 12.0},
	]
	var out: Array[DlcProceduralBodyPart] = []
	for entry: Dictionary in (spec if variant == "shape" else prim):
		var part := DlcProceduralBodyPart.new()
		part.configure(entry)
		if variant == "prim" and entry.has("shape"):
			part.configure({"shape": ""})
		out.append(part)
	return out
