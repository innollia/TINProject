class_name StoneStoryStructure
extends RefCounted


static func draw(ci: CanvasItem, def: Dictionary, pal: ProceduralPalette, ox: float,
		stats: StoneStoryDrawStats, view_h: float = 640.0) -> void:
	var layer_list: Array = def.get("layers", [])
	if layer_list.is_empty():
		return
	StoneStoryInk.layers(ci, layer_list, pal, Vector2(ox, 0.0), Vector2.ONE, stats)
	if stats != null:
		stats.note_structure(visible_height_ratio(def, view_h))


static func visible_height_ratio(def: Dictionary, view_h: float = 640.0) -> float:
	var bb: Rect2 = StoneStoryInk.layer_bounds(def.get("layers", []))
	var top: float = clampf(bb.position.y, 0.0, view_h)
	var bottom: float = clampf(bb.end.y, 0.0, view_h)
	return maxf(0.0, bottom - top) / view_h
