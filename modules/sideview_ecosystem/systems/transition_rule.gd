class_name EcoTransitionRule
extends RefCounted

const KIND_PRESSURE: String = "pressure"
const KIND_CONSUME: String = "consume"
const KIND_SQUEEZE: String = "squeeze"
const OBJECTS: Array[String] = ["salt_bed", "collapse_floor", "salt_dust_bed", "narrow_cradle"]
const RULES: Dictionary = {
	"salt_bed": {"kind": KIND_PRESSURE, "from": "speck", "to": "hand", "duration_s": 5.0, "hits_required": 0, "landing_speed_max": 0.0, "still_seconds": 0.0, "witness_count": 0, "witness_frames": 0, "witness_radius_px": 0.0},
	"collapse_floor": {"kind": KIND_CONSUME, "from": "hand", "to": "doll", "duration_s": 0.0, "hits_required": 3, "landing_speed_max": 420.0, "still_seconds": 0.0, "witness_count": 0, "witness_frames": 0, "witness_radius_px": 0.0},
	"salt_dust_bed": {"kind": KIND_SQUEEZE, "from": "doll", "to": "hand", "duration_s": 0.0, "hits_required": 0, "landing_speed_max": 0.0, "still_seconds": 8.0, "witness_count": 0, "witness_frames": 0, "witness_radius_px": 0.0},
	"narrow_cradle": {"kind": KIND_SQUEEZE, "from": "hand", "to": "speck", "duration_s": 0.0, "hits_required": 0, "landing_speed_max": 0.0, "still_seconds": 12.0, "witness_count": 3, "witness_frames": 180, "witness_radius_px": 144.0},
}
const SALT_BED_PRESS_STEP: float = 0.20
const SALT_BED_TRACE_MAX: float = 0.60


static func is_object(object_name: String) -> bool:
	return RULES.has(object_name)


static func rule_of(object_name: String) -> Dictionary:
	return RULES.get(object_name, {})


static func source_of(object_name: String) -> String:
	return str(rule_of(object_name).get("from", ""))


static func target_of(object_name: String) -> String:
	return str(rule_of(object_name).get("to", ""))


static func kind_of(object_name: String) -> String:
	return str(rule_of(object_name).get("kind", ""))
