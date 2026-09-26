extends RefCounted

const MATERIALS: Dictionary = {
	"paper": {"friction": 0.62, "bounce": 0.02, "density": 0.30, "damage_scale": 1.0, "debris": 6, "breakable": true},
	"glass": {"friction": 0.30, "bounce": 0.28, "density": 0.70, "damage_scale": 0.7, "debris": 14, "breakable": true},
	"wood": {"friction": 0.74, "bounce": 0.10, "density": 0.55, "damage_scale": 1.2, "debris": 9, "breakable": true},
	"stone": {"friction": 0.86, "bounce": 0.04, "density": 1.80, "damage_scale": 1.6, "debris": 12, "breakable": true},
	"iron": {"friction": 0.52, "bounce": 0.06, "density": 3.20, "damage_scale": 2.2, "debris": 7, "breakable": false},
	"clockwork": {"friction": 0.66, "bounce": 0.16, "density": 1.10, "damage_scale": 0.9, "debris": 16, "breakable": true},
	"wax": {"friction": 0.94, "bounce": 0.01, "density": 0.45, "damage_scale": 0.6, "debris": 5, "breakable": true},
	"void": {"friction": 0.02, "bounce": 0.00, "density": 0.10, "damage_scale": 0.4, "debris": 3, "breakable": false},
	"goal": {"friction": 0.40, "bounce": 0.00, "density": 1.00, "damage_scale": 0.0, "debris": 0, "breakable": false},
}

const NAMES: Array[String] = ["paper", "glass", "wood", "stone", "iron", "clockwork", "wax", "void", "goal"]
const SWAP_CHOICES: Array[String] = ["paper", "glass", "wood", "stone", "iron", "clockwork", "wax"]
const FRICTION_OVERRIDE_MAX: float = 1.6
const BOUNCE_OVERRIDE_MAX: float = 0.6


static func has_material(name: String) -> bool:
	return MATERIALS.has(name)


static func get_value(name: String, key: String) -> Variant:
	return (MATERIALS.get(name, MATERIALS["stone"]) as Dictionary)[key]


static func friction(name: String) -> float:
	return float(get_value(name, "friction"))


static func bounce(name: String) -> float:
	return float(get_value(name, "bounce"))


static func density(name: String) -> float:
	return float(get_value(name, "density"))


static func damage_scale(name: String) -> float:
	return float(get_value(name, "damage_scale"))


static func debris_count(name: String) -> int:
	return int(get_value(name, "debris"))


static func is_breakable(name: String) -> bool:
	return bool(get_value(name, "breakable"))


static func make_physics_material(name: String, friction_override: float = -1.0, bounce_override: float = -1.0) -> PhysicsMaterial:
	var material := PhysicsMaterial.new()
	material.friction = friction_override if friction_override >= 0.0 else friction(name)
	material.bounce = bounce_override if bounce_override >= 0.0 else bounce(name)
	material.rough = false
	material.absorbent = false
	return material


static func swap_target(current: String, choice: int) -> String:
	var count: int = SWAP_CHOICES.size()
	var index: int = posmod(choice, count)
	if SWAP_CHOICES[index] == current:
		index = (index + 1) % count
	return SWAP_CHOICES[index]
