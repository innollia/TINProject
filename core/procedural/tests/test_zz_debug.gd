extends GutTest

const OUT: String = "C:/Users/Sherum/.kiro/crew/scratch/runtime-2d7d64d2/"


func _critter() -> ProceduralCreatureBuilder:
	var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://core/procedural/tests/fixtures/sprite_critter.json"))
	var builder: ProceduralCreatureBuilder = ProceduralCreatureBuilder.new(Vector2i(64, 48))
	builder.set_palette(Procedural.make_palette(Procedural.derive_seed(0, "fixture.critter")))
	builder.outline_width = 1.0
	for entry: Variant in (spec["parts"] as Array):
		var part: ProceduralBodyPart = ProceduralBodyPart.new()
		part.configure(entry)
		builder.add_part(part)
	return builder


func _us(start: int) -> int:
	return Time.get_ticks_usec() - start


func test_profile() -> void:
	var builder: ProceduralCreatureBuilder = _critter()
	for round_index: int in 3:
		var t: int = Time.get_ticks_usec()
		builder.is_bakeable()
		var bake_check: int = _us(t)
		t = Time.get_ticks_usec()
		builder._place_in_canvas()
		var place: int = _us(t)
		var region: Rect2i = builder._union_rect()
		t = Time.get_ticks_usec()
		var sink: float = 0.0
		for y: int in range(region.position.y, region.end.y):
			for x: int in range(region.position.x, region.end.x):
				sink += builder._fused_distance(Vector2(float(x) + 0.5, float(y) + 0.5))
		var field: int = _us(t)
		t = Time.get_ticks_usec()
		builder.compose_canvas()
		var compose: int = _us(t)
		t = Time.get_ticks_usec()
		builder.outline()
		var ring: int = _us(t)
		gut.p("round %d: bake_check %d  place %d  field(%dx%d) %d  compose %d  outline %d us" % [
			round_index, bake_check, place, region.size.x, region.size.y, field, compose, ring,
		])
	var palette: ProceduralPalette = Procedural.make_palette(Procedural.derive_seed(0, "fixture.part"))
	for spec: Dictionary in [
		{"length": 26.0, "base_radius": 14.0, "tip_radius": 6.0},
		{"length": 26.0, "base_radius": 14.0, "tip_radius": 6.0, "bend": 25.0, "wiggle": 0.3},
	]:
		var part: ProceduralBodyPart = ProceduralBodyPart.new()
		part.configure(spec)
		for round_index: int in 2:
			var canvas: ProceduralCanvas = ProceduralCanvas.new(48, 40)
			var t: int = Time.get_ticks_usec()
			part.draw(canvas, palette, {"origin": Vector2(10.0, 20.0)})
			gut.p("part %s draw %d us" % [spec.keys(), _us(t)])
	var frame: Dictionary = {"sprite": JSON.parse_string(FileAccess.get_file_as_string("res://core/procedural/tests/fixtures/sprite_critter.json")), "pose": {}, "delta": 0.0}
	var t0: int = Time.get_ticks_usec()
	Procedural.render_frame(frame)
	gut.p("render_frame first (bake) %d us" % _us(t0))
	frame["delta"] = 1.0 / 60.0
	var total: int = 0
	for index: int in 30:
		frame["pose"] = {"impulse": [0.0, 300.0]} if index == 0 else {}
		var t1: int = Time.get_ticks_usec()
		Procedural.render_frame(frame)
		total += _us(t1)
	gut.p("render_frame avg %d us" % (total / 30))
	_save_sheets()
	assert_true(true)


func _sheet(canvases: Array, factor: int, path: String) -> void:
	var width: int = 0
	var height: int = 0
	for canvas: ProceduralCanvas in canvases:
		width += canvas.width * factor + 4
		height = maxi(height, canvas.height * factor)
	var sheet: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.5, 0.5, 0.5, 1.0))
	var x: int = 0
	for canvas: ProceduralCanvas in canvases:
		var image: Image = canvas.to_image()
		image.resize(canvas.width * factor, canvas.height * factor, Image.INTERPOLATE_NEAREST)
		sheet.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(x, 0))
		x += image.get_width() + 4
	sheet.save_png(path)


func _save_sheets() -> void:
	var rig: ProceduralSquishRig = Procedural.make_rig({
		"joints": [
			{"id": "hips", "rest_position": [32.0, 44.0], "part": {"length": 12.0, "base_radius": 12.0, "tip_radius": 10.0, "angle": -90.0}},
			{"id": "chest", "parent": "hips", "rest_position": [0.0, -12.0], "squash": 0.5, "part": {"length": 10.0, "base_radius": 11.0, "tip_radius": 8.0, "angle": -90.0}},
			{"id": "head", "parent": "chest", "rest_position": [0.0, -12.0], "part": {"length": 6.0, "base_radius": 10.0, "tip_radius": 8.0, "angle": -90.0, "shade": "rim"}},
			{"id": "badge", "parent": "chest", "kind": "rigid", "rest_position": [5.0, -4.0], "part": {"length": 1.0, "base_radius": 3.0, "tip_radius": 3.0, "body_role": "accent", "shade": "flat"}},
		],
	})
	var palette: ProceduralPalette = Procedural.make_palette(Procedural.derive_seed(0, "fixture.rig"))
	var frames: Array = []
	var still: ProceduralCanvas = ProceduralCanvas.new(64, 64)
	rig.draw(still, palette)
	frames.append(still)
	rig.disturb(Vector2(0.0, -300.0))
	for index: int in 24:
		rig.step(1.0 / 60.0)
		if index % 4 == 1:
			var canvas: ProceduralCanvas = ProceduralCanvas.new(64, 64)
			rig.draw(canvas, palette)
			frames.append(canvas)
	_sheet(frames, 3, OUT + "rig_sheet.png")
	var text: String = FileAccess.get_file_as_string("res://core/procedural/tests/fixtures/sprite_critter.json")
	var frame: Dictionary = {"sprite": JSON.parse_string(text), "pose": {}, "delta": 0.0}
	var shots: Array = []
	var base_canvas: ProceduralCanvas = ProceduralCanvas.new(64, 48)
	base_canvas.pixels = Procedural.render_frame(frame).get_image().get_data()
	shots.append(base_canvas)
	frame["delta"] = 1.0 / 60.0
	for index: int in 30:
		frame["pose"] = {"impulse": [0.0, 300.0]} if index == 0 else ({"wind": [6.0, 0.0]} if index > 18 else {})
		var texture: ImageTexture = Procedural.render_frame(frame)
		if index % 5 == 3:
			var shot: ProceduralCanvas = ProceduralCanvas.new(64, 48)
			shot.pixels = texture.get_image().get_data()
			shots.append(shot)
	_sheet(shots, 3, OUT + "frames_sheet.png")
	var builder: ProceduralCreatureBuilder = _critter()
	_sheet([builder.compose_canvas()], 4, OUT + "critter.png")
