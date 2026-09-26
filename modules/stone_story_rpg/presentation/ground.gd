class_name StoneStoryGround
extends RefCounted

const BANDS: int = 6
const MARKS: int = 96
const TUFTS: int = 16


static func draw(ci: CanvasItem, pal: ProceduralPalette, region: Dictionary, w: float, horizon: float,
		h: float, stats: StoneStoryDrawStats, ox: float, seed_value: int) -> void:
	for i in BANDS:
		var t0: float = float(i) / float(BANDS)
		var t1: float = float(i + 1) / float(BANDS)
		var y0: float = horizon + (h - horizon) * t0
		var y1: float = horizon + (h - horizon) * t1 + 0.6
		var c0: Color = StoneStoryPalette.ground_at(pal, t0)
		var c1: Color = StoneStoryPalette.ground_at(pal, t1)
		var quad := PackedVector2Array([Vector2(0.0, y0), Vector2(w, y0), Vector2(w, y1), Vector2(0.0, y1)])
		ci.draw_polygon(quad, PackedColorArray([c0, c0, c1, c1]))
		if stats != null:
			stats.note_rect(Rect2i(0, int(y0), int(w), int(y1 - y0) + 1), c0, true)
			stats.note_ground_band()
	var haze: Color = pal.mix_roles(StoneStoryPalette.HORIZON, StoneStoryPalette.GROUND, 0.55)
	var clear: Color = haze
	clear.a = 0.0
	ci.draw_polygon(PackedVector2Array([Vector2(0.0, horizon), Vector2(w, horizon), Vector2(w, horizon + 26.0), Vector2(0.0, horizon + 26.0)]),
			PackedColorArray([haze, haze, clear, clear]))
	StoneStoryInk.layers(ci, region.get("ground_layers", []), pal, Vector2(ox, 0.0), Vector2.ONE, stats)
	_marks(ci, pal, region, w, horizon, h, stats, seed_value)


static func _marks(ci: CanvasItem, pal: ProceduralPalette, region: Dictionary, w: float, horizon: float,
		h: float, stats: StoneStoryDrawStats, seed_value: int) -> void:
	var kind: String = str(region.get("ground_marks", "pebble"))
	var s: StoneStoryRng = StoneStoryCore.stream(seed_value, StoneStoryCore.TAG_TEXTURE + ".ground." + kind)
	var dark: Color = pal.shifted(StoneStoryPalette.GROUND, 0.80, 1.05)
	var lit: Color = pal.shifted(StoneStoryPalette.GROUND, 1.10, 0.72)
	var petal: Color = StoneStoryPalette.sclera(pal)
	for i in MARKS:
		var d: float = s.unit(i)
		var y: float = horizon + 6.0 + (h - horizon - 6.0) * pow(d, 1.45)
		var x: float = s.unit(i + 300) * (w + 40.0) - 20.0
		var size: float = lerpf(1.6, 12.0, pow(d, 1.25))
		if kind == "petal":
			var rot: float = s.unit(i + 600) * PI
			StoneStoryInk.fill(ci, StoneStoryInk.ellipse(Vector2(x, y), size * 0.62, size * 0.26, 10, rot), petal, stats)
			continue
		var col: Color = dark if s.unit(i + 900) < 0.62 else lit
		StoneStoryInk.fill(ci, StoneStoryInk.ellipse(Vector2(x, y), size, size * 0.40, 12), col, stats)
		if size > 6.0:
			StoneStoryInk.fill(ci, StoneStoryInk.ellipse(Vector2(x - size * 0.2, y - size * 0.12), size * 0.45, size * 0.14, 10), lit, stats)


static func draw_near(ci: CanvasItem, pal: ProceduralPalette, w: float, h: float, t: float,
		stats: StoneStoryDrawStats, seed_value: int, sway_field: PackedVector2Array = PackedVector2Array()) -> void:
	var s: StoneStoryRng = StoneStoryCore.stream(seed_value, StoneStoryCore.TAG_TEXTURE + ".ground.near")
	var blade: Color = pal.shifted(StoneStoryPalette.GROUND, 0.62, 1.1)
	var tip: Color = pal.shifted(StoneStoryPalette.GROUND, 0.84, 1.0)
	for i in TUFTS:
		var x: float = s.unit(i) * w
		var y: float = h - 4.0 - s.unit(i + 40) * 22.0
		var tall: float = 16.0 + s.unit(i + 80) * 22.0
		var sway: float = sin(t * 1.4 + float(i) * 0.8) * 2.0
		if not sway_field.is_empty():
			sway += sway_field[i % sway_field.size()].x * 0.9
		for k in 3:
			var off: float = (float(k) - 1.0) * 5.0
			var lean: float = (float(k) - 1.0) * 7.0 + sway
			StoneStoryInk.fill(ci, PackedVector2Array([
				Vector2(x + off - 2.6, y), Vector2(x + off + lean, y - tall * (0.8 + 0.2 * float(k % 2))), Vector2(x + off + 2.6, y)]),
				blade if k != 1 else tip, stats)
	for i in 5:
		var x2: float = s.unit(i + 200) * w
		var y2: float = h - 2.0 - s.unit(i + 240) * 10.0
		var r: float = 12.0 + s.unit(i + 280) * 14.0
		StoneStoryInk.fill(ci, StoneStoryInk.ellipse(Vector2(x2, y2), r, r * 0.48, 16), blade, stats)
		StoneStoryInk.fill(ci, StoneStoryInk.ellipse(Vector2(x2 - r * 0.25, y2 - r * 0.18), r * 0.5, r * 0.18, 12), tip, stats)
