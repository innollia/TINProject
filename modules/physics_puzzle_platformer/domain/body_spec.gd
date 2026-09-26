extends RefCounted

const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const MaterialTable = preload("res://modules/physics_puzzle_platformer/domain/material_table.gd")
const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

const SHAPES: Array[String] = ["box", "capsule", "circle", "triangle", "hull", "segment"]
const KEYS: Array[String] = ["id", "kind", "shape", "material", "pos", "size", "points", "angle", "hp", "breakable", "t_max", "friction_override", "bounce_override", "tool"]
const ID_PATTERN: String = "^[a-z0-9_]{1,24}$"

var id: String = ""
var kind: int = BodyKind.PROP_DYNAMIC
var shape: String = "box"
var size: Vector2 = Vector2(32.0, 32.0)
var points: PackedVector2Array = PackedVector2Array()
var material: String = "wood"
var pos: Vector2 = Vector2.ZERO
var angle: float = 0.0
var hp: float = 3.0
var breakable: bool = false
var t_max: float = 0.0
var friction_override: float = -1.0
var bounce_override: float = -1.0
var tool: String = ""
var mass_override: float = -1.0
var index: int = -1


class BodyRuntime:
	extends RefCounted

	var spec_id: String = ""
	var kind: int = 5
	var x: float = 0.0
	var y: float = 0.0
	var angle: float = 0.0
	var vx: float = 0.0
	var vy: float = 0.0
	var av: float = 0.0
	var sleeping: bool = false
	var hp: float = 3.0
	var destroyed: bool = false
	var collected: bool = false
	var t: float = 0.0
	var held: bool = false
	var tool_id: String = ""
	var tool_cooldown: float = 0.0
	var frozen: bool = false
	var frozen_time: float = 0.0
	var material: String = "wood"
	var mass: float = 0.0
	var radius: float = 12.0
	var breakable: bool = false
	var t_max: float = 0.0
	var fire_linger: float = 0.0
	var home_x: float = 0.0
	var home_y: float = 0.0
	var respawn_timer: float = 0.0
	var still_time: float = 0.0
	var knocked: Array[int] = []
	var latched: bool = false
	var contact_flash: float = 0.0
	var trail: Array[Vector2] = []

	func position() -> Vector2:
		return Vector2(x, y)

	func velocity() -> Vector2:
		return Vector2(vx, vy)


static func shape_area(shape_name: String, shape_size: Vector2, shape_points: PackedVector2Array) -> float:
	match shape_name:
		"box":
			return shape_size.x * shape_size.y
		"triangle":
			return shape_size.x * shape_size.y * 0.5
		"circle":
			return PI * pow(shape_size.x * 0.5, 2.0)
		"capsule":
			var radius: float = shape_size.x * 0.5
			return PI * radius * radius + shape_size.x * maxf(shape_size.y - shape_size.x, 0.0)
		"segment":
			return shape_size.x * shape_size.y
		"hull":
			return absf(_signed_area(shape_points))
	return shape_size.x * shape_size.y


static func _signed_area(shape_points: PackedVector2Array) -> float:
	var total: float = 0.0
	for i: int in shape_points.size():
		var p: Vector2 = shape_points[i]
		var q: Vector2 = shape_points[(i + 1) % shape_points.size()]
		total += p.x * q.y - q.x * p.y
	return total * 0.5


static func normalize_hull(shape_points: PackedVector2Array) -> PackedVector2Array:
	var result: PackedVector2Array = shape_points.duplicate()
	if _signed_area(result) < 0.0:
		result.reverse()
	return result


static func hull_is_valid(shape_points: PackedVector2Array) -> bool:
	if shape_points.size() < 3 or shape_points.size() > 6:
		return false
	for i: int in shape_points.size():
		for j: int in range(i + 1, shape_points.size()):
			if shape_points[i].distance_to(shape_points[j]) < 0.5:
				return false
	if absf(_signed_area(shape_points)) < 1.0:
		return false
	var sign_value: float = 0.0
	for i: int in shape_points.size():
		var a: Vector2 = shape_points[i]
		var b: Vector2 = shape_points[(i + 1) % shape_points.size()]
		var c: Vector2 = shape_points[(i + 2) % shape_points.size()]
		var cross: float = (b - a).cross(c - b)
		if absf(cross) < 0.0001:
			return false
		if sign_value == 0.0:
			sign_value = signf(cross)
		elif signf(cross) != sign_value:
			return false
	return true


static func bounding_radius(shape_name: String, shape_size: Vector2, shape_points: PackedVector2Array) -> float:
	if shape_name == "hull":
		var radius: float = 0.0
		for point: Vector2 in shape_points:
			radius = maxf(radius, point.length())
		return radius
	if shape_name == "circle":
		return shape_size.x * 0.5
	return shape_size.length() * 0.5


func area() -> float:
	return shape_area(shape, size, points)


func mass() -> float:
	if mass_override > 0.0:
		return mass_override
	return maxf(area() * MaterialTable.density(material) * Tuning.MASS_PER_AREA, 0.02)


func duplicate_spec() -> RefCounted:
	var copy: RefCounted = get_script().new()
	copy.id = id
	copy.kind = kind
	copy.shape = shape
	copy.size = size
	copy.points = points.duplicate()
	copy.material = material
	copy.pos = pos
	copy.angle = angle
	copy.hp = hp
	copy.breakable = breakable
	copy.t_max = t_max
	copy.friction_override = friction_override
	copy.bounce_override = bounce_override
	copy.tool = tool
	copy.mass_override = mass_override
	copy.index = index
	return copy


func parse(data: Variant, errors: Array[String], label: String) -> RefCounted:
	if not data is Dictionary:
		errors.append("%s: body is not an object" % label)
		return null
	var raw: Dictionary = data
	for key: Variant in raw:
		if not key is String or not KEYS.has(String(key)):
			errors.append("%s: unknown key '%s'" % [label, str(key)])
	var spec: RefCounted = self
	var regex := RegEx.new()
	regex.compile(ID_PATTERN)
	if not raw.get("id") is String or regex.search(String(raw.get("id"))) == null:
		errors.append("%s: bad id" % label)
		return null
	spec.id = String(raw["id"])
	label = "%s(%s)" % [label, spec.id]
	if not raw.get("kind") is String:
		errors.append("%s: missing kind" % label)
		return null
	spec.kind = BodyKind.from_authored_name(String(raw["kind"]))
	if spec.kind == 0:
		errors.append("%s: kind '%s' is not authorable" % [label, str(raw["kind"])])
		return null
	if not raw.get("shape") is String or not SHAPES.has(String(raw["shape"])):
		errors.append("%s: bad shape" % label)
		return null
	spec.shape = String(raw["shape"])
	if not raw.get("material") is String or not MaterialTable.has_material(String(raw["material"])):
		errors.append("%s: bad material" % label)
		return null
	spec.material = String(raw["material"])
	var position: Variant = read_vector(raw.get("pos"))
	if position == null:
		errors.append("%s: bad pos" % label)
		return null
	spec.pos = position
	if spec.shape == "hull":
		if not raw.get("points") is Array:
			errors.append("%s: hull needs points" % label)
			return null
		var hull: PackedVector2Array = PackedVector2Array()
		for point: Variant in raw["points"]:
			var value: Variant = read_vector(point)
			if value == null:
				errors.append("%s: bad hull point" % label)
				return null
			hull.append(value)
		if not hull_is_valid(hull):
			errors.append("%s: hull must be 3..6 distinct convex points" % label)
			return null
		spec.points = normalize_hull(hull)
		var extent: Rect2 = Rect2(spec.points[0], Vector2.ZERO)
		for point: Vector2 in spec.points:
			extent = extent.expand(point)
		spec.size = extent.size
	else:
		if raw.has("points"):
			errors.append("%s: points only allowed for hull" % label)
		var measured: Variant = read_vector(raw.get("size"))
		if measured == null or (measured as Vector2).x <= 0.0 or (measured as Vector2).y <= 0.0:
			errors.append("%s: bad size" % label)
			return null
		spec.size = measured
		if spec.shape == "circle":
			spec.size = Vector2(spec.size.x, spec.size.x)
		if spec.shape == "capsule" and spec.size.y < spec.size.x:
			spec.size = Vector2(spec.size.x, spec.size.x)
	spec.angle = float(raw.get("angle", 0.0)) if _is_number(raw.get("angle", 0.0)) else 0.0
	var base_hp: float = BodyKind.default_hp(spec.kind)
	if spec.shape == "hull" or spec.shape == "triangle":
		base_hp = base_hp * 2.0 if base_hp > 0.0 else base_hp
	spec.hp = base_hp
	if raw.has("hp"):
		if not _is_number(raw["hp"]) or float(raw["hp"]) <= 0.0:
			errors.append("%s: bad hp" % label)
			return null
		spec.hp = float(raw["hp"])
	spec.breakable = BodyKind.is_breakable(spec.kind) and MaterialTable.is_breakable(spec.material)
	if raw.has("breakable"):
		if not raw["breakable"] is bool:
			errors.append("%s: breakable must be bool" % label)
			return null
		spec.breakable = bool(raw["breakable"]) and BodyKind.is_breakable(spec.kind)
	if raw.has("t_max"):
		if not _is_number(raw["t_max"]) or float(raw["t_max"]) < 0.0:
			errors.append("%s: bad t_max" % label)
			return null
		spec.t_max = float(raw["t_max"])
	if raw.has("friction_override"):
		if not _is_number(raw["friction_override"]) or float(raw["friction_override"]) < 0.0 or float(raw["friction_override"]) > MaterialTable.FRICTION_OVERRIDE_MAX:
			errors.append("%s: friction_override out of range" % label)
			return null
		spec.friction_override = float(raw["friction_override"])
	if raw.has("bounce_override"):
		if not _is_number(raw["bounce_override"]) or float(raw["bounce_override"]) < 0.0 or float(raw["bounce_override"]) > MaterialTable.BOUNCE_OVERRIDE_MAX:
			errors.append("%s: bounce_override out of range" % label)
			return null
		spec.bounce_override = float(raw["bounce_override"])
	if spec.kind == BodyKind.TOOL_PLACEMENT:
		if not raw.get("tool") is String or String(raw["tool"]).is_empty():
			errors.append("%s: tool_placement needs tool" % label)
			return null
		spec.tool = String(raw["tool"])
	elif raw.has("tool"):
		errors.append("%s: tool only allowed on tool_placement" % label)
		return null
	return spec


static func read_vector(value: Variant) -> Variant:
	if value is Array and (value as Array).size() == 2 and _is_number(value[0]) and _is_number(value[1]):
		var result := Vector2(float(value[0]), float(value[1]))
		if is_finite(result.x) and is_finite(result.y):
			return result
	return null


static func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))
