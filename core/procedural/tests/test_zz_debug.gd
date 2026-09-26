extends GutTest

const OUT: String = "C:/Users/Sherum/.kiro/crew/scratch/runtime-e9c84b86/"


func _scaled(canvas: ProceduralCanvas, factor: int) -> Image:
	var image: Image = canvas.to_image()
	image.resize(canvas.width * factor, canvas.height * factor, Image.INTERPOLATE_NEAREST)
	return image


func _sheet(canvases: Array, factor: int) -> Image:
	var width: int = 0
	var height: int = 0
	for canvas: ProceduralCanvas in canvases:
		width += canvas.width * factor + 4
		height = maxi(height, canvas.height * factor)
	var sheet: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.5, 0.5, 0.5, 1.0))
	var x: int = 0
	for canvas: ProceduralCanvas in canvases:
		var image: Image = _scaled(canvas, factor)
		sheet.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(x, 0))
		x += image.get_width() + 4
	return sheet


func test_debug_render_sheets() -> void:
	var text: String = FileAccess.get_file_as_string("res://core/procedural/tests/fixtures/sprite_critter.json")
	var spec: Dictionary = JSON.parse_string(text)
	var canvases: Array = []
	for overrides: Dictionary in [{}, {"facing": -1}, {"squash": 0.3}, {"squash": -0.3}]:
		var builder: ProceduralCreatureBuilder = ProceduralCreatureBuilder.new(Vector2i(64, 48))
		builder.set_palette(Procedural.make_palette(Procedural.derive_seed(0, "fixture.critter")))
		builder.outline_width = 1.0
		builder.squash = float(overrides.get("squash", 0.0))
		builder.facing = int(overrides.get("facing", 1))
		for entry: Variant in (spec["parts"] as Array):
			var part: ProceduralBodyPart = ProceduralBodyPart.new()
			part.configure(entry)
			builder.add_part(part)
		var t0: int = Time.get_ticks_usec()
		canvases.append(builder.compose_canvas())
		gut.p("compose %d us" % (Time.get_ticks_usec() - t0))
		var ring: PackedVector2Array = builder.outline()
		var outline_canvas: ProceduralCanvas = ProceduralCanvas.new(64, 48)
		outline_canvas.draw_polygon(ring, builder.palette.get_color(ProceduralPalette.ROLE_ACCENT))
		canvases.append(outline_canvas)
	_sheet(canvases, 4).save_png(OUT + "critter_sheet.png")

	var parts: Array = []
	var palette: ProceduralPalette = Procedural.make_palette(Procedural.derive_seed(0, "fixture.part"))
	for shade_name: String in ["flat", "volumetric", "rim", "ink"]:
		var part: ProceduralBodyPart = ProceduralBodyPart.new()
		part.configure({"length": 26.0, "base_radius": 14.0, "tip_radius": 6.0, "bend": 25.0, "wiggle": 0.3, "shade": shade_name})
		var canvas: ProceduralCanvas = ProceduralCanvas.new(48, 40)
		var t1: int = Time.get_ticks_usec()
		part.draw(canvas, palette, {"origin": Vector2(10.0, 20.0)})
		gut.p("part draw %d us" % (Time.get_ticks_usec() - t1))
		parts.append(canvas)
	var segmented: ProceduralBodyPart = ProceduralBodyPart.new()
	segmented.configure({"length": 30.0, "base_radius": 12.0, "tip_radius": 4.0, "segments": [{"kind": "box"}, {"kind": "capsule"}, {"kind": "triangle"}]})
	var seg_canvas: ProceduralCanvas = ProceduralCanvas.new(48, 40)
	segmented.draw(seg_canvas, palette, {"origin": Vector2(8.0, 20.0), "rotation": 0.3, "squash": 0.3})
	parts.append(seg_canvas)
	_sheet(parts, 4).save_png(OUT + "parts_sheet.png")

	var rig: ProceduralSquishRig = Procedural.make_rig({
		"joints": [
			{"id": "hips", "rest_position": [32.0, 44.0], "part": {"length": 12.0, "base_radius": 12.0, "tip_radius": 10.0, "angle": -90.0}},
			{"id": "chest", "parent": "hips", "rest_position": [0.0, -12.0], "squash": 0.5, "part": {"length": 10.0, "base_radius": 11.0, "tip_radius": 8.0, "angle": -90.0}},
			{"id": "head", "parent": "chest", "rest_position": [0.0, -12.0], "part": {"length": 6.0, "base_radius": 10.0, "tip_radius": 8.0, "angle": -90.0, "shade": "rim"}},
			{"id": "badge", "parent": "chest", "kind": "rigid", "rest_position": [5.0, -4.0], "part": {"length": 1.0, "base_radius": 3.0, "tip_radius": 3.0, "body_role": "accent", "shade": "flat"}},
		],
	})
	var rig_palette: ProceduralPalette = Procedural.make_palette(Procedural.derive_seed(0, "fixture.rig"))
	var frames: Array = []
	var still: ProceduralCanvas = ProceduralCanvas.new(64, 64)
	rig.draw(still, rig_palette)
	frames.append(still)
	rig.disturb(Vector2(0.0, -300.0))
	for index: int in 24:
		rig.step(1.0 / 60.0)
		if index % 4 == 1:
			var canvas: ProceduralCanvas = ProceduralCanvas.new(64, 64)
			var t2: int = Time.get_ticks_usec()
			rig.draw(canvas, rig_palette)
			if index == 1:
				gut.p("rig draw %d us" % (Time.get_ticks_usec() - t2))
			frames.append(canvas)
	_sheet(frames, 3).save_png(OUT + "rig_sheet.png")

	var frame: Dictionary = {"sprite": JSON.parse_string(text), "pose": {}, "delta": 0.0}
	var shots: Array = []
	var first: ImageTexture = Procedural.render_frame(frame)
	var base_canvas: ProceduralCanvas = ProceduralCanvas.new(64, 48)
	base_canvas.pixels = first.get_image().get_data()
	shots.append(base_canvas)
	frame["delta"] = 1.0 / 60.0
	for index: int in 30:
		frame["pose"] = {"impulse": [0.0, 300.0]} if index == 0 else ({"wind": [6.0, 0.0]} if index > 18 else {})
		var t3: int = Time.get_ticks_usec()
		var texture: ImageTexture = Procedural.render_frame(frame)
		if index == 5:
			gut.p("render_frame %d us" % (Time.get_ticks_usec() - t3))
		if index % 5 == 3:
			var shot: ProceduralCanvas = ProceduralCanvas.new(64, 48)
			shot.pixels = texture.get_image().get_data()
			shots.append(shot)
	_sheet(shots, 3).save_png(OUT + "frames_sheet.png")
	assert_true(true)
