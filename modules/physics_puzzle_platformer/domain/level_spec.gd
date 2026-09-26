extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const BodySpec = preload("res://modules/physics_puzzle_platformer/domain/body_spec.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const SCHEMA: int = 1
const ID_PATTERN: String = "^[a-z0-9_]{3,32}$"
const REQUIRED_KEYS: Array[String] = ["schema", "id", "name", "parallax_seed", "spawn", "rift", "bounds", "bodies", "kinematics", "shuffled", "mutable", "mutable_hazards", "objective_needed"]
const OPTIONAL_KEYS: Array[String] = ["camera_y"]
const MUTATION_OPS: Array[String] = ["gravity_scale", "material_swap", "prop_size", "prop_offset", "wind", "hazard_shift"]
const LOOPS: Array[String] = ["once", "pingpong"]
const MAX_BODIES: int = 64
const MAX_KINEMATICS: int = 4
const MIN_WIDTH: float = 1600.0
const MIN_HEIGHT: float = 640.0
const NAME_MAX: int = 24

var id: String = ""
var name: String = ""
var parallax_seed: int = 1
var spawn: Vector2 = Vector2.ZERO
var rift_pos: Vector2 = Vector2.ZERO
var rift_radius: float = 28.0
var bounds: Rect2 = Rect2()
var camera_y: float = Tuning.CAM_Y
var objective_needed: int = 1
var mutable: Array[String] = []
var mutable_hazards: Array[int] = []
var shuffled: Array[int] = []
var kinematics: Array[Dictionary] = []
var bodies: Array = []
var gravity_mul: float = 1.0
var wind_x: float = 0.0


func objective_total() -> int:
	var count: int = 0
	for body: RefCounted in bodies:
		if body.kind == BodyKind.OBJECTIVE:
			count += 1
	return count


func body_by_id(body_id: String) -> RefCounted:
	for body: RefCounted in bodies:
		if body.id == body_id:
			return body
	return null


func kinematic_for(body_id: String) -> Dictionary:
	for entry: Dictionary in kinematics:
		if String(entry["id"]) == body_id:
			return entry
	return {}


func duplicate_spec() -> RefCounted:
	var copy: RefCounted = get_script().new()
	copy.id = id
	copy.name = name
	copy.parallax_seed = parallax_seed
	copy.spawn = spawn
	copy.rift_pos = rift_pos
	copy.rift_radius = rift_radius
	copy.bounds = bounds
	copy.camera_y = camera_y
	copy.objective_needed = objective_needed
	copy.mutable = mutable.duplicate()
	copy.mutable_hazards = mutable_hazards.duplicate()
	copy.shuffled = shuffled.duplicate()
	for entry: Dictionary in kinematics:
		copy.kinematics.append(entry.duplicate(true))
	for body: RefCounted in bodies:
		copy.bodies.append(body.duplicate_spec())
	copy.gravity_mul = gravity_mul
	copy.wind_x = wind_x
	return copy


static func parse(data: Variant, expected_id: String, known_tools: Array) -> Dictionary:
	var errors: Array[String] = []
	var spec: RefCounted = load("res://modules/physics_puzzle_platformer/domain/level_spec.gd").new()
	if not data is Dictionary:
		return {"ok": false, "errors": ["level: not an object"], "spec": null}
	var raw: Dictionary = data
	for key: String in REQUIRED_KEYS:
		if not raw.has(key):
			errors.append("level: missing key '%s'" % key)
	for key: Variant in raw:
		if not key is String or (not REQUIRED_KEYS.has(String(key)) and not OPTIONAL_KEYS.has(String(key))):
			errors.append("level: unknown key '%s'" % str(key))
	if not errors.is_empty():
		return {"ok": false, "errors": errors, "spec": null}
	if not _is_int(raw["schema"]) or int(raw["schema"]) != SCHEMA:
		errors.append("level: schema must be %d" % SCHEMA)
	var regex := RegEx.new()
	regex.compile(ID_PATTERN)
	if not raw["id"] is String or regex.search(String(raw["id"])) == null:
		errors.append("level: bad id")
	elif not expected_id.is_empty() and String(raw["id"]) != expected_id:
		errors.append("level: id '%s' does not match index '%s'" % [str(raw["id"]), expected_id])
	else:
		spec.id = String(raw["id"])
	if not raw["name"] is String or String(raw["name"]).strip_edges().is_empty() or String(raw["name"]).length() > NAME_MAX:
		errors.append("level: name must be 1..%d chars" % NAME_MAX)
	else:
		spec.name = String(raw["name"])
	if not _is_int(raw["parallax_seed"]) or int(raw["parallax_seed"]) < 1 or int(raw["parallax_seed"]) > 999999:
		errors.append("level: parallax_seed out of range")
	else:
		spec.parallax_seed = int(raw["parallax_seed"])
	var bounds_raw: Variant = raw["bounds"]
	if not bounds_raw is Dictionary or not _has_numbers(bounds_raw, ["min_x", "max_x", "min_y", "max_y"]):
		errors.append("level: bad bounds")
		return {"ok": false, "errors": errors, "spec": null}
	var min_x: float = float(bounds_raw["min_x"])
	var max_x: float = float(bounds_raw["max_x"])
	var min_y: float = float(bounds_raw["min_y"])
	var max_y: float = float(bounds_raw["max_y"])
	if max_x - min_x < MIN_WIDTH or max_y - min_y < MIN_HEIGHT:
		errors.append("level: bounds must be at least %dx%d" % [int(MIN_WIDTH), int(MIN_HEIGHT)])
	spec.bounds = Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
	var spawn_raw: Variant = raw["spawn"]
	if not spawn_raw is Dictionary or not _has_numbers(spawn_raw, ["x", "y"]):
		errors.append("level: bad spawn")
	else:
		spec.spawn = Vector2(float(spawn_raw["x"]), float(spawn_raw["y"]))
		if not spec.bounds.has_point(spec.spawn):
			errors.append("level: spawn outside bounds")
	var rift_raw: Variant = raw["rift"]
	if not rift_raw is Dictionary or not _has_numbers(rift_raw, ["x", "y", "radius"]):
		errors.append("level: bad rift")
	else:
		spec.rift_pos = Vector2(float(rift_raw["x"]), float(rift_raw["y"]))
		spec.rift_radius = float(rift_raw["radius"])
		if not spec.bounds.has_point(spec.rift_pos):
			errors.append("level: rift outside bounds")
		if spec.rift_radius < 20.0 or spec.rift_radius > 48.0:
			errors.append("level: rift radius must be 20..48")
	if raw.has("camera_y"):
		if not _is_number(raw["camera_y"]):
			errors.append("level: bad camera_y")
		else:
			spec.camera_y = float(raw["camera_y"])
	if not raw["bodies"] is Array or (raw["bodies"] as Array).is_empty() or (raw["bodies"] as Array).size() > MAX_BODIES:
		errors.append("level: bodies must hold 1..%d entries" % MAX_BODIES)
		return {"ok": false, "errors": errors, "spec": null}
	var seen_ids: Dictionary = {}
	var body_errors: Array[String] = []
	for index: int in (raw["bodies"] as Array).size():
		var entry: Variant = raw["bodies"][index]
		if entry is Dictionary and String((entry as Dictionary).get("kind", "")) == "rift":
			errors.append("level: rift must not be a body")
			continue
		var body: RefCounted = BodySpec.parse(entry, body_errors, "body[%d]" % index)
		if body == null:
			continue
		body.index = index
		if seen_ids.has(body.id):
			errors.append("level: duplicate body id '%s'" % body.id)
			continue
		seen_ids[body.id] = true
		if body.kind == BodyKind.TOOL_PLACEMENT and not known_tools.has(body.tool):
			errors.append("level: body '%s' names unknown tool" % body.id)
		spec.bodies.append(body)
	errors.append_array(body_errors)
	if spec.bodies.size() != (raw["bodies"] as Array).size():
		errors.append("level: some bodies failed to load")
	var kinematics_raw: Variant = raw["kinematics"]
	if not kinematics_raw is Array or (kinematics_raw as Array).size() > MAX_KINEMATICS:
		errors.append("level: kinematics must hold 0..%d entries" % MAX_KINEMATICS)
	else:
		for entry: Variant in kinematics_raw:
			var parsed: Dictionary = _parse_kinematic(entry, spec, errors)
			if not parsed.is_empty():
				spec.kinematics.append(parsed)
	for body: RefCounted in spec.bodies:
		if body.kind == BodyKind.TILE_KINEMATIC and spec.kinematic_for(body.id).is_empty():
			errors.append("level: tile_kinematic '%s' has no path" % body.id)
	for entry: Dictionary in spec.kinematics:
		var target: RefCounted = spec.body_by_id(String(entry["id"]))
		if target == null or target.kind != BodyKind.TILE_KINEMATIC:
			errors.append("level: kinematic path '%s' names no tile_kinematic" % str(entry["id"]))
	spec.shuffled = _parse_indices(raw["shuffled"], 2, spec.bodies.size(), "shuffled", errors)
	spec.mutable_hazards = _parse_indices(raw["mutable_hazards"], 4, spec.bodies.size(), "mutable_hazards", errors)
	for index: int in spec.mutable_hazards:
		if index < spec.bodies.size() and not BodyKind.is_hazard(spec.bodies[index].kind):
			errors.append("level: mutable_hazards[%d] is not a hazard" % index)
	for index: int in spec.shuffled:
		if index < spec.bodies.size() and not BodyKind.is_rigid(spec.bodies[index].kind):
			errors.append("level: shuffled[%d] is not a dynamic body" % index)
	if not raw["mutable"] is Array:
		errors.append("level: mutable must be an array")
	else:
		for op: Variant in raw["mutable"]:
			if not op is String or not MUTATION_OPS.has(String(op)):
				errors.append("level: unknown mutable op '%s'" % str(op))
			elif spec.mutable.has(String(op)):
				errors.append("level: duplicate mutable op '%s'" % str(op))
			else:
				spec.mutable.append(String(op))
		_check_mutation_targets(spec, errors)
	if not _is_int(raw["objective_needed"]):
		errors.append("level: objective_needed must be an integer")
	else:
		spec.objective_needed = int(raw["objective_needed"])
		if spec.objective_needed < Tuning.OBJECTIVE_MIN or spec.objective_needed > Tuning.OBJECTIVE_MAX:
			errors.append("level: objective_needed out of range")
		if spec.objective_needed > spec.objective_total():
			errors.append("level: objective_needed exceeds objective bodies")
	return {"ok": errors.is_empty(), "errors": errors, "spec": spec if errors.is_empty() else null}


static func _check_mutation_targets(spec: RefCounted, errors: Array[String]) -> void:
	var props: int = 0
	var kinematic_count: int = spec.kinematics.size()
	for body: RefCounted in spec.bodies:
		if BodyKind.is_mutation_prop(body.kind):
			props += 1
	for op: String in spec.mutable:
		match op:
			"material_swap":
				if spec.shuffled.is_empty():
					errors.append("level: material_swap needs shuffled")
			"prop_size", "prop_offset":
				if props == 0:
					errors.append("level: %s needs a prop" % op)
			"wind":
				if kinematic_count == 0:
					errors.append("level: wind needs a kinematic")
			"hazard_shift":
				if spec.mutable_hazards.size() < 2:
					errors.append("level: hazard_shift needs two mutable_hazards")


static func _parse_kinematic(entry: Variant, spec: RefCounted, errors: Array[String]) -> Dictionary:
	if not entry is Dictionary:
		errors.append("level: kinematic entry is not an object")
		return {}
	var raw: Dictionary = entry
	for key: Variant in raw:
		if not key is String or not ["id", "from", "to", "duration", "loop"].has(String(key)):
			errors.append("level: kinematic unknown key '%s'" % str(key))
	var start: Variant = BodySpec.read_vector(raw.get("from"))
	var finish: Variant = BodySpec.read_vector(raw.get("to"))
	if not raw.get("id") is String or start == null or finish == null or not _is_number(raw.get("duration")) or float(raw.get("duration")) <= 0.0:
		errors.append("level: bad kinematic entry")
		return {}
	if not raw.get("loop") is String or not LOOPS.has(String(raw["loop"])):
		errors.append("level: kinematic loop must be once or pingpong")
		return {}
	if not spec.bounds.has_point(start) or not spec.bounds.has_point(finish):
		errors.append("level: kinematic '%s' path outside bounds" % str(raw["id"]))
		return {}
	return {"id": String(raw["id"]), "from": start, "to": finish, "duration": float(raw["duration"]), "loop": String(raw["loop"])}


static func _parse_indices(value: Variant, maximum: int, body_count: int, label: String, errors: Array[String]) -> Array[int]:
	var result: Array[int] = []
	if not value is Array or (value as Array).size() > maximum:
		errors.append("level: %s must hold 0..%d indices" % [label, maximum])
		return result
	for item: Variant in value:
		if not _is_int(item) or int(item) < 0 or int(item) >= body_count:
			errors.append("level: %s index out of range" % label)
			continue
		if result.has(int(item)):
			errors.append("level: %s duplicate index" % label)
			continue
		result.append(int(item))
	return result


static func _has_numbers(data: Dictionary, keys: Array) -> bool:
	for key: Variant in keys:
		if not data.has(key) or not _is_number(data[key]):
			return false
	return true


static func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


static func _is_int(value: Variant) -> bool:
	return _is_number(value) and is_equal_approx(float(value), roundf(float(value)))
