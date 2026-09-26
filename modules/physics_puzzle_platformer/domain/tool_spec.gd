extends RefCounted

const BodySpec = preload("res://modules/physics_puzzle_platformer/domain/body_spec.gd")
const MaterialTable = preload("res://modules/physics_puzzle_platformer/domain/material_table.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const SCHEMA: int = 1
const ID_PATTERN: String = "^[a-z0-9_]{3,32}$"
const USES: Array[String] = ["throw", "shove", "anchor_line", "cool_field"]
const TRAILS: Array[String] = ["none", "short", "long"]
const BODY_SHAPES: Array[String] = ["box", "capsule", "circle", "triangle"]
const REQUIRED_KEYS: Array[String] = ["schema", "id", "name", "use", "body", "mass", "friction", "bounce", "cooldown", "trail"]
const USE_KEYS: Dictionary = {
	"throw": ["impulse_scale", "fire_linger"],
	"shove": ["reach", "arc_deg"],
	"anchor_line": ["impulse_scale"],
	"cool_field": ["radius", "duration"],
}
const OPTIONAL_KEYS: Array[String] = ["hp"]
const FORBIDDEN_KEYS: Array[String] = ["pickable", "opens", "unlocks", "required_for", "key_id", "solution", "answer", "hint"]

var id: String = ""
var name: String = ""
var use: String = "throw"
var shape: String = "box"
var material: String = "wood"
var size: Vector2 = Vector2(24.0, 24.0)
var mass: float = 1.4
var friction: float = 0.5
var bounce: float = 0.1
var impulse_scale: float = 1.0
var reach: float = 42.0
var arc_deg: float = 90.0
var radius: float = 96.0
var duration: float = 0.7
var cooldown: float = Tuning.TOOL_COOLDOWN
var trail: String = "none"
var fire_linger: float = 0.0
var hp: float = 3.0
var breakable: bool = false


func is_charge_tool() -> bool:
	return use == "throw" or use == "anchor_line"


static func parse(data: Variant, expected_id: String) -> Dictionary:
	var errors: Array[String] = []
	if not data is Dictionary:
		return {"ok": false, "errors": ["tool: not an object"], "spec": null}
	var raw: Dictionary = data
	var spec: RefCounted = load("res://modules/physics_puzzle_platformer/domain/tool_spec.gd").new()
	for key: String in FORBIDDEN_KEYS:
		if raw.has(key):
			errors.append("tool: forbidden key '%s'" % key)
	for key: String in REQUIRED_KEYS:
		if not raw.has(key):
			errors.append("tool: missing key '%s'" % key)
	if not errors.is_empty():
		return {"ok": false, "errors": errors, "spec": null}
	if not raw["use"] is String or not USES.has(String(raw["use"])):
		return {"ok": false, "errors": ["tool: bad use"], "spec": null}
	spec.use = String(raw["use"])
	var allowed: Array = REQUIRED_KEYS.duplicate()
	allowed.append_array(USE_KEYS[spec.use])
	allowed.append_array(OPTIONAL_KEYS)
	for key: Variant in raw:
		if not key is String or not allowed.has(String(key)):
			errors.append("tool: unknown key '%s'" % str(key))
	if not _is_int(raw["schema"]) or int(raw["schema"]) != SCHEMA:
		errors.append("tool: schema must be %d" % SCHEMA)
	var regex := RegEx.new()
	regex.compile(ID_PATTERN)
	if not raw["id"] is String or regex.search(String(raw["id"])) == null:
		errors.append("tool: bad id")
	elif not expected_id.is_empty() and String(raw["id"]) != expected_id:
		errors.append("tool: id does not match index")
	else:
		spec.id = String(raw["id"])
	if not raw["name"] is String or String(raw["name"]).strip_edges().is_empty():
		errors.append("tool: bad name")
	else:
		spec.name = String(raw["name"])
	var body: Variant = raw["body"]
	if not body is Dictionary:
		errors.append("tool: body must be an object")
	else:
		for key: Variant in body:
			if not key is String or not ["kind", "shape", "material", "size"].has(String(key)):
				errors.append("tool: body unknown key '%s'" % str(key))
		if String((body as Dictionary).get("kind", "")) != "prop_dynamic":
			errors.append("tool: body kind must be prop_dynamic")
		var shape_name: String = String((body as Dictionary).get("shape", ""))
		if not BODY_SHAPES.has(shape_name):
			errors.append("tool: bad body shape")
		spec.shape = shape_name
		var material_name: String = String((body as Dictionary).get("material", ""))
		if not MaterialTable.has_material(material_name):
			errors.append("tool: bad body material")
		spec.material = material_name
		var measured: Variant = BodySpec.read_vector((body as Dictionary).get("size"))
		if measured == null or (measured as Vector2).x <= 0.0 or (measured as Vector2).y <= 0.0:
			errors.append("tool: bad body size")
		else:
			spec.size = measured
			if spec.shape == "capsule" and spec.size.y < spec.size.x:
				spec.size = Vector2(spec.size.x, spec.size.x)
			if spec.shape == "circle":
				spec.size = Vector2(spec.size.x, spec.size.x)
	spec.mass = _ranged(raw, "mass", 0.35, 6.0, errors)
	spec.friction = _ranged(raw, "friction", 0.05, 1.2, errors)
	spec.bounce = _ranged(raw, "bounce", 0.0, 0.45, errors)
	spec.cooldown = _ranged(raw, "cooldown", 0.05, 2.0, errors)
	if not raw["trail"] is String or not TRAILS.has(String(raw["trail"])):
		errors.append("tool: bad trail")
	else:
		spec.trail = String(raw["trail"])
	match spec.use:
		"throw":
			if not raw.has("impulse_scale"):
				errors.append("tool: throw needs impulse_scale")
			else:
				spec.impulse_scale = _ranged(raw, "impulse_scale", 0.2, 3.0, errors)
			if raw.has("fire_linger"):
				spec.fire_linger = _ranged(raw, "fire_linger", 0.1, 6.0, errors)
		"anchor_line":
			if raw.has("impulse_scale"):
				spec.impulse_scale = _ranged(raw, "impulse_scale", 0.2, 3.0, errors)
		"shove":
			for key: String in ["reach", "arc_deg"]:
				if not raw.has(key):
					errors.append("tool: shove needs %s" % key)
			if raw.has("reach"):
				spec.reach = _ranged(raw, "reach", 18.0, 90.0, errors)
			if raw.has("arc_deg"):
				spec.arc_deg = _ranged(raw, "arc_deg", 30.0, 180.0, errors)
		"cool_field":
			for key: String in ["radius", "duration"]:
				if not raw.has(key):
					errors.append("tool: cool_field needs %s" % key)
			if raw.has("radius"):
				spec.radius = _ranged(raw, "radius", 40.0, 140.0, errors)
			if raw.has("duration"):
				spec.duration = _ranged(raw, "duration", 0.2, 1.5, errors)
	if raw.has("hp"):
		spec.hp = _ranged(raw, "hp", 2.0, 6.0, errors)
	spec.breakable = MaterialTable.is_breakable(spec.material)
	return {"ok": errors.is_empty(), "errors": errors, "spec": spec if errors.is_empty() else null}


static func _ranged(raw: Dictionary, key: String, low: float, high: float, errors: Array[String]) -> float:
	var value: Variant = raw.get(key)
	if not (value is int or value is float) or not is_finite(float(value)) or float(value) < low or float(value) > high:
		errors.append("tool: %s must be %s..%s" % [key, str(low), str(high)])
		return low
	return float(value)


static func _is_int(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and is_equal_approx(float(value), roundf(float(value)))
