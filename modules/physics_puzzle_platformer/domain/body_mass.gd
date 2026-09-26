extends RefCounted

const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const PART_MASS: Dictionary = {"head": 0.10, "torso": 0.30, "arm_left": 0.25, "arm_right": 0.25}
const ARM_PARTS: Array[String] = ["arm_left", "arm_right"]


static func base_player_mass() -> float:
	var radius: float = Tuning.PLAYER_W * 0.5
	var area: float = PI * radius * radius + Tuning.PLAYER_W * maxf(Tuning.PLAYER_H - Tuning.PLAYER_W, 0.0)
	return area * Tuning.PLAYER_DENSITY * Tuning.MASS_PER_AREA


static func missing_mass(missing: Array) -> float:
	var total: float = 0.0
	for part: Variant in missing:
		total += float(PART_MASS.get(String(part), 0.0))
	return total


static func player_mass(missing: Array, scale: float) -> float:
	return (base_player_mass() - missing_mass(missing)) * scale * scale


static func player_reach_radius(missing: Array, scale: float) -> float:
	var arms: int = ARM_PARTS.size()
	for part: Variant in missing:
		if ARM_PARTS.has(String(part)):
			arms -= 1
	return Tuning.GRAB_RADIUS * float(maxi(arms, 0)) / float(ARM_PARTS.size()) * scale


static func player_params(axis: RefCounted) -> Dictionary:
	var params: Dictionary = {"mass": base_player_mass(), "reach": Tuning.GRAB_RADIUS, "scale": 1.0, "from_axis": false}
	if axis == null or not axis.has_body():
		return params
	var body: AxisBody = axis.get_body()
	if body == null:
		return params
	var scale: float = 1.0
	if body.has_scale():
		scale = float(body.get_scale())
	var missing: Array = []
	var missing_value: Variant = body.get_missing()
	if missing_value is Array:
		missing = missing_value
	params["mass"] = player_mass(missing, scale)
	params["reach"] = player_reach_radius(missing, scale)
	params["scale"] = scale
	params["from_axis"] = true
	return params
