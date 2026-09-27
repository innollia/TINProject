class_name EcoAIMemory
extends RefCounted

const SLOTS: int = 3
const RECORD_RADIUS_PX: float = 144.0

var last_seen: PackedVector2Array = PackedVector2Array()
var last_seen_age: PackedFloat32Array = PackedFloat32Array()
var last_seen_rung: String = ""
var last_damage_source: String = "none"


func age(dt: float) -> void:
	for i: int in last_seen_age.size():
		last_seen_age[i] += dt


func record(pos: Vector2, distance: float) -> void:
	if distance > RECORD_RADIUS_PX:
		return
	last_seen.insert(0, pos)
	last_seen_age.insert(0, 0.0)
	while last_seen.size() > SLOTS:
		last_seen.remove_at(last_seen.size() - 1)
		last_seen_age.remove_at(last_seen_age.size() - 1)


func to_dictionary() -> Dictionary:
	var pts: Array = []
	for p: Vector2 in last_seen:
		pts.append([p.x, p.y])
	return {"last_seen": pts, "last_seen_age": Array(last_seen_age), "last_seen_rung": last_seen_rung, "last_damage_source": last_damage_source}


static func from_dictionary(d: Dictionary) -> EcoAIMemory:
	var m: EcoAIMemory = EcoAIMemory.new()
	var pts: Variant = d.get("last_seen", [])
	var ages: Variant = d.get("last_seen_age", [])
	if pts is Array and ages is Array and (pts as Array).size() == (ages as Array).size():
		for i: int in mini((pts as Array).size(), SLOTS):
			var p: Variant = pts[i]
			if p is Array and (p as Array).size() == 2 and (ages[i] is float or ages[i] is int):
				m.last_seen.append(Vector2(float(p[0]), float(p[1])))
				m.last_seen_age.append(float(ages[i]))
	m.last_seen_rung = str(d.get("last_seen_rung", ""))
	m.last_damage_source = str(d.get("last_damage_source", "none"))
	return m
