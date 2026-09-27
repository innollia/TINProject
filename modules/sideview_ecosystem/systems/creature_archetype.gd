class_name EcoCreatureArchetype
extends RefCounted

var id: String = ""
var axis_name: String = ""
var rung: String = ""
var variant_rungs: Array[String] = []
var density: float = 0.0
var hp: float = 0.0
var move_speed: float = 0.0
var chase_speed_mult: float = 0.0
var think_period: float = 0.0
var sense_radius_px: float = 0.0
var hearing_radius_px: float = 0.0
var fov_deg: float = 0.0
var reaction_latency: Vector2 = Vector2.ZERO
var aggression: float = 0.0
var courage: float = 0.0
var attack_range_ratio: float = 0.0
var attack_windup: float = 0.0
var attack_damage: float = 0.0
var body_parts: int = 0
var confined_only: bool = false
var graze_radius_px: float = 0.0
var pack_bonus_count: int = 0
var lineage: Array[Dictionary] = []


static func from_dictionary(d: Dictionary) -> EcoCreatureArchetype:
	var a: EcoCreatureArchetype = EcoCreatureArchetype.new()
	a.id = str(d.get("id", ""))
	a.axis_name = str(d.get("axis_name", ""))
	a.rung = str(d.get("rung", ""))
	for v: Variant in d.get("variant_rungs", []):
		a.variant_rungs.append(str(v))
	for key: String in ["density", "hp", "move_speed", "chase_speed_mult", "think_period", "sense_radius_px", "hearing_radius_px", "fov_deg", "aggression", "courage", "attack_range_ratio", "attack_windup", "attack_damage", "graze_radius_px"]:
		a.set(key, float(d.get(key, 0.0)))
	var lat: Array = d.get("reaction_latency", [0.0, 0.0])
	a.reaction_latency = Vector2(float(lat[0]), float(lat[1]))
	a.body_parts = int(d.get("body_parts", 0))
	a.confined_only = bool(d.get("confined_only", false))
	a.pack_bonus_count = int(d.get("pack_bonus_count", 0))
	for s: Variant in d.get("lineage", []):
		a.lineage.append({"archetype": str((s as Dictionary).get("archetype", "")), "advance_chance": float((s as Dictionary).get("advance_chance", 0.0))})
	return a


func rung_for(creature_id: int, band_name: String, ladder: EcoLadder) -> String:
	var band_i: int = ladder.index_of(band_name)
	var candidates: Array[String] = []
	for v: String in variant_rungs:
		if ladder.index_of(v) <= band_i:
			candidates.append(v)
	if candidates.is_empty():
		return ""
	if candidates.size() == 1:
		return candidates[0]
	return candidates[creature_id % 2]


func h_px(rung_value: float, band_value: float, target_body_px: float) -> float:
	if band_value <= 0.0:
		return 0.0
	return rung_value / band_value * target_body_px


func mass_at(h: float) -> float:
	var r: float = h / EcoBodyRung.MASS_REF_PX
	return density * r * r * r
