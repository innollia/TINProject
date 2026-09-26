class_name EcoToll
extends RefCounted

const PART_TORSO: String = "torso"
const KIND_UP: String = "stretched"
const KIND_DOWN: String = "compressed"
const SEVERITY: float = 0.34


static func for_step(from_index: int, to_index: int) -> Dictionary:
	if to_index == from_index:
		return {}
	var kind: String = KIND_UP if to_index > from_index else KIND_DOWN
	return {"part": PART_TORSO, "kind": kind, "severity": SEVERITY, "permanent": true}


static func merge_max(wounds: Array, toll: Dictionary) -> Array:
	var merged: Array = wounds.duplicate(true)
	if toll.is_empty():
		return merged
	for i: int in merged.size():
		var w: Variant = merged[i]
		if w is Dictionary and str(w.get("part", "")) == str(toll["part"]) and str(w.get("kind", "")) == str(toll["kind"]):
			var recorded: Variant = w.get("severity", 0.0)
			var recorded_value: float = float(recorded) if (recorded is float or recorded is int) else 0.0
			w["severity"] = maxf(recorded_value, float(toll["severity"]))
			w["permanent"] = bool(w.get("permanent", false)) or bool(toll["permanent"])
			return merged
	merged.append(toll.duplicate(true))
	return merged
