class_name EcoRoomSpec
extends RefCounted

var id: String = ""
var region_id: String = ""
var index: int = 0
var band: String = ""
var target_body_px: float = 0.0
var place_id: String = ""
var tiles_w: int = 0
var tiles_h: int = 0
var terrain: PackedByteArray = PackedByteArray()
var passages: Array[EcoPassageSpec] = []
var exits: Array[Dictionary] = []
var triggers: Array[Dictionary] = []
var shelters: Array[Dictionary] = []
var dens: Array[Dictionary] = []
var tethered: Array[Dictionary] = []


func tile_at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= tiles_w or y >= tiles_h:
		return -1
	return terrain[y * tiles_w + x]


func contains_cell(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < tiles_w and c.y < tiles_h


func contains_rect(r: Rect2i) -> bool:
	return r.position.x >= 0 and r.position.y >= 0 and r.end.x <= tiles_w and r.end.y <= tiles_h


func size_px() -> Vector2:
	return Vector2(tiles_w, tiles_h) * EcoBodyRung.TILE


func module_px() -> float:
	return target_body_px / EcoBodyRung.FIT_TARGET


func passage(passage_id: String) -> EcoPassageSpec:
	for p: EcoPassageSpec in passages:
		if p.id == passage_id:
			return p
	return null


func exit_by_id(exit_id: String) -> Dictionary:
	for e: Dictionary in exits:
		if str(e["id"]) == exit_id:
			return e
	return {}


func trigger_by_id(trigger_id: String) -> Dictionary:
	for t: Dictionary in triggers:
		if str(t["id"]) == trigger_id:
			return t
	return {}


func shelter_by_id(shelter_id: String) -> Dictionary:
	for s: Dictionary in shelters:
		if str(s["id"]) == shelter_id:
			return s
	return {}
