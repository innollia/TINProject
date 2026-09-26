class_name EcoGapClass
extends RefCounted

const ORDER: Array[String] = ["SEAL", "HAIRLINE", "TIGHT", "FIT", "WIDE"]
const MULTIPLIERS: Dictionary = {
	"SEAL": 0.20,
	"HAIRLINE": 0.35,
	"TIGHT": 0.85,
	"FIT": 2.60,
	"WIDE": 4.20,
}
const SQUEEZE_RATIO: float = 1.42


static func is_valid(width_class: String) -> bool:
	return MULTIPLIERS.has(width_class)


static func multiplier(width_class: String) -> float:
	return float(MULTIPLIERS.get(width_class, 0.0))


static func narrower(width_class: String) -> String:
	var i: int = ORDER.find(width_class)
	if i <= 0:
		return ORDER[0] if i == 0 else width_class
	return ORDER[i - 1]


static func narrowed_by(width_class: String, steps: int) -> String:
	var current: String = width_class
	for _i: int in maxi(steps, 0):
		current = narrower(current)
	return current
