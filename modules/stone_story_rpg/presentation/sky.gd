class_name StoneStorySky
extends RefCounted

const BANDS: int = 16


static func draw(ci: CanvasItem, pal: ProceduralPalette, region: Dictionary, w: float, horizon: float,
		t: float, stats: StoneStoryDrawStats, ox: float, seed_value: int) -> void:
	for i in BANDS:
		var t0: float = float(i) / float(BANDS)
		var t1: float = float(i + 1) / float(BANDS)
		var y0: float = horizon * t0
		var y1: float = horizon * t1 + 0.6
		var c0: Color = StoneStoryPalette.sky_at(pal, t0)
		var c1: Color = StoneStoryPalette.sky_at(pal, t1)
		var quad := PackedVector2Array([Vector2(0.0, y0), Vector2(w, y0), Vector2(w, y1), Vector2(0.0, y1)])
		ci.draw_polygon(quad, PackedColorArray([c0, c0, c1, c1]))
		if stats != null:
			stats.note_rect(Rect2i(0, int(y0), int(w), int(y1 - y0) + 1), c0, true)
			stats.note_sky_band()
	var sky_def: Dictionary = region.get("sky", {})
	var sun: Dictionary = sky_def.get("sun", {})
	if not sun.is_empty():
		var at := Vector2(ox + float(sun.get("x", 700)), float(sun.get("y", 60)))
		var r: float = float(sun.get("r", 10))
		var col: Color = StoneStoryPalette.role(pal, str(sun.get("role", "trim")))
		for k in 3:
			var g: Color = col
			g.a = 0.10 + 0.08 * float(k)
			StoneStoryInk.disc(ci, at, r * (3.4 - float(k) * 0.9), g, stats)
		StoneStoryInk.disc(ci, at, r, col, stats)
		StoneStoryInk.disc(ci, at + Vector2(-r * 0.3, -r * 0.3), r * 0.38, StoneStoryPalette.sclera(pal), stats)
	var n: int = int(sky_def.get("clouds", 0))
	var s: StoneStoryRng = StoneStoryCore.stream(seed_value, StoneStoryCore.TAG_TEXTURE + ".sky.cloud")
	var span: float = w + 260.0
	for i in n:
		var cw: float = 54.0 + s.unit(i + 80) * 80.0
		var base_x: float = s.unit(i) * span
		var speed: float = 3.0 + 4.0 * s.unit(i + 120)
		var x: float = fposmod(base_x + t * speed, span) - 130.0
		var y: float = 26.0 + s.unit(i + 40) * horizon * 0.48
		cloud(ci, Vector2(x, y), cw, pal, stats)


static func cloud(ci: CanvasItem, at: Vector2, cw: float, pal: ProceduralPalette, stats: StoneStoryDrawStats) -> void:
	var main: Color = StoneStoryPalette.cloud(pal)
	var shade: Color = StoneStoryPalette.cloud_shade(pal)
	var puffs: Array = [
		[Vector2(-0.30, 0.02), 0.26], [Vector2(-0.05, -0.12), 0.34], [Vector2(0.24, -0.02), 0.27], [Vector2(0.42, 0.06), 0.17],
	]
	for p in puffs:
		StoneStoryInk.disc(ci, at + (p[0] as Vector2) * cw + Vector2(0.0, cw * 0.07), float(p[1]) * cw, shade, stats)
	for p in puffs:
		StoneStoryInk.disc(ci, at + (p[0] as Vector2) * cw, float(p[1]) * cw, main, stats)
	var base := PackedVector2Array([
		at + Vector2(-0.52, 0.02) * cw, at + Vector2(0.56, 0.02) * cw,
		at + Vector2(0.50, 0.14) * cw, at + Vector2(-0.46, 0.14) * cw])
	StoneStoryInk.fill(ci, base, shade, stats)
	var top := PackedVector2Array([
		at + Vector2(-0.52, -0.02) * cw, at + Vector2(0.56, -0.02) * cw,
		at + Vector2(0.52, 0.09) * cw, at + Vector2(-0.48, 0.09) * cw])
	StoneStoryInk.fill(ci, top, main, stats)
