class_name EcoPassageKind
extends RefCounted

const GAP: int = 0
const STEP: int = 1
const DROP: int = 2
const BREAK: int = 3
const PRESS: int = 4
const NAMES: Array[String] = ["GAP", "STEP", "DROP", "BREAK", "PRESS"]

const STEP_HEIGHTS: Array[float] = [40.0, 200.0, 290.0]
const DROP_FALLS: Array[float] = [1600.0, 2000.0, 2700.0, 4200.0]
const PRESS_MASSES: Array[float] = [0.10, 0.80, 12.00]
const BREAK_HP_MIN: int = 1
const BREAK_HP_MAX: int = 4

const COMMON_KEYS: Array[String] = ["id", "kind", "cell", "span"]
const KIND_KEYS: Dictionary = {
	GAP: ["width_class", "drift"],
	STEP: ["height_px"],
	DROP: ["fall_px"],
	BREAK: ["hp"],
	PRESS: ["mass_required"],
}
const REQUIRED_KEYS: Dictionary = {
	GAP: ["width_class"],
	STEP: ["height_px"],
	DROP: ["fall_px"],
	BREAK: ["hp"],
	PRESS: ["mass_required"],
}


static func from_name(kind_name: String) -> int:
	return NAMES.find(kind_name)


static func name_of(kind: int) -> String:
	if kind < 0 or kind >= NAMES.size():
		return ""
	return NAMES[kind]


static func allowed_keys(kind: int) -> Array[String]:
	var keys: Array[String] = COMMON_KEYS.duplicate()
	for k: Variant in KIND_KEYS.get(kind, []):
		keys.append(str(k))
	return keys


static func is_class_value(values: Array[float], v: float) -> bool:
	for allowed: float in values:
		if is_equal_approx(allowed, v):
			return true
	return false
