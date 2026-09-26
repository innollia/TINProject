class_name StoneStoryProps
extends RefCounted


static func placements(content: StoneStoryContent, region: Dictionary) -> Array:
	var out: Array = []
	if content == null:
		return out
	for raw in region.get("props", []):
		var p: Dictionary = raw
		var def: Dictionary = content.get_def("prop", str(p.get("prop_id", "")))
		if def.is_empty():
			continue
		var breaks: String = str(p.get("breaks", ""))
		out.append({
			"prop_id": str(def["id"]), "def": def,
			"x": float(p.get("x", 480)), "y": float(p.get("y", 400)),
			"scale": float(p.get("scale", 1.0)), "breaks": breaks, "twin": false,
			"shadow_y": float(p.get("shadow_y", -1.0)),
		})
		if p.has("twin"):
			var tw: Dictionary = p["twin"]
			out.append({
				"prop_id": str(def["id"]), "def": def,
				"x": float(tw.get("x", 480)), "y": float(tw.get("y", 400)),
				"scale": float(tw.get("scale", 0.5)), "breaks": "placement", "twin": true,
				"shadow_y": -1.0,
			})
	return out


static func is_floating(e: Dictionary) -> bool:
	return str(e.get("breaks", "")) == "gravity"


static func bob(e: Dictionary, t: float) -> float:
	if not is_floating(e):
		return 0.0
	return sin(t * 1.25 + float(e["x"]) * 0.013) * 5.0


static func width_of(e: Dictionary) -> float:
	var bb: Rect2 = StoneStoryInk.layer_bounds(e["def"].get("layers", []))
	return bb.size.x * float(e["scale"])


static func draw_shadow(ci: CanvasItem, e: Dictionary, pal: ProceduralPalette, ox: float, t: float,
		stats: StoneStoryDrawStats) -> void:
	var wd: float = width_of(e)
	var col: Color = StoneStoryPalette.shadow(pal)
	if is_floating(e):
		var sy: float = float(e.get("shadow_y", -1.0))
		if sy <= 0.0:
			return
		var k: float = 0.85 + bob(e, t) * 0.02
		col.a *= 0.55
		StoneStoryInk.fill(ci, StoneStoryInk.ellipse(Vector2(ox + float(e["x"]), sy), wd * 0.32 * k, wd * 0.05 * k, 18), col, stats)
		return
	StoneStoryInk.fill(ci, StoneStoryInk.ellipse(Vector2(ox + float(e["x"]), float(e["y"]) + 1.0), wd * 0.55, maxf(2.0, wd * 0.09), 18), col, stats)


static func draw_one(ci: CanvasItem, e: Dictionary, pal: ProceduralPalette, ox: float, t: float,
		stats: StoneStoryDrawStats) -> void:
	var origin := Vector2(ox + float(e["x"]), float(e["y"]) + bob(e, t))
	var sc: float = float(e["scale"])
	StoneStoryInk.layers(ci, e["def"].get("layers", []), pal, origin, Vector2(sc, sc), stats)
	if stats != null:
		stats.note_prop(str(e.get("breaks", "")))
