extends RefCounted

const LAYER_APPARENT: Dictionary = {"far": 0.28, "near": 0.55, "fore": 1.35}
const LAYER_ALPHA: Dictionary = {"far": 0.55, "near": 0.85, "fore": 0.30}
const LAYER_ORDER: Array[String] = ["far", "near", "fore"]
const STIFFNESS: float = 26.0
const DAMPING_RATIO: float = 0.42
const NEAR_RADIUS: float = 130.0
const NEAR_MAX: float = 26.0
const LAND_RADIUS: float = 200.0
const LAND_MAX: float = 34.0
const IMPACT_RADIUS: float = 160.0
const IMPACT_MAX: float = 30.0
const BREAK_PER_PIECE: float = 2.4
const SLIDE_SPEED: float = 150.0
const ACTIVE_MAX: int = 28

const PULSE_LAND: StringName = &"land"
const PULSE_IMPACT: StringName = &"impact"
const PULSE_BREAK: StringName = &"break"
const PULSE_SLIDE: StringName = &"slide"

var layers: Dictionary = {}
var view: Vector2 = Vector2.ZERO


func _init() -> void:
	for name: String in LAYER_ORDER:
		var dynamics := ProceduralBackdropDynamics.new(_layer_enum(name))
		dynamics.configure(1.0 - float(LAYER_APPARENT[name]), 0.0, STIFFNESS, DAMPING_RATIO)
		layers[name] = dynamics


static func _layer_enum(name: String) -> ProceduralBackdropDynamics.Layer:
	match name:
		"far":
			return ProceduralBackdropDynamics.Layer.FAR
		"near":
			return ProceduralBackdropDynamics.Layer.NEAR
	return ProceduralBackdropDynamics.Layer.FOREGROUND


func add_element(layer: String, rest: Vector2) -> int:
	return (layers[layer] as ProceduralBackdropDynamics).add_anchor(rest)


func count(layer: String) -> int:
	return (layers[layer] as ProceduralBackdropDynamics).get_anchor_count()


func set_view(camera_center: Vector2) -> void:
	view = camera_center
	for name: String in LAYER_ORDER:
		(layers[name] as ProceduralBackdropDynamics).set_view_offset(camera_center)


func world_position(layer: String, index: int) -> Vector2:
	var dynamics: ProceduralBackdropDynamics = layers[layer]
	return dynamics.get_rest_position(index) + dynamics.get_offset(index)


func displacement(layer: String, index: int) -> Vector2:
	var dynamics: ProceduralBackdropDynamics = layers[layer]
	return dynamics.get_offset(index) - view * dynamics.parallax


func _kick(layer: String, index: int, impulse: Vector2) -> void:
	var dynamics: ProceduralBackdropDynamics = layers[layer]
	dynamics.to_shape().kick_node(dynamics.get_node_index(index), impulse)


func push_from(origin: Vector2, delta: float) -> void:
	for name: String in LAYER_ORDER:
		for index: int in count(name):
			var offset: Vector2 = world_position(name, index) - origin
			var distance: float = offset.length()
			if distance >= NEAR_RADIUS:
				continue
			var closeness: float = 1.0 - distance / NEAR_RADIUS
			var direction: Vector2 = offset / distance if distance > 0.001 else Vector2.UP
			var target: float = NEAR_MAX * closeness
			var along: float = displacement(name, index).dot(direction)
			if along < target:
				_kick(name, index, direction * STIFFNESS * target * delta)


func pulse(kind: StringName, origin: Vector2, radius: float, strength: float) -> void:
	var limit: float = IMPACT_MAX
	match kind:
		PULSE_LAND:
			limit = LAND_MAX
		PULSE_BREAK:
			limit = minf(BREAK_PER_PIECE * strength, LAND_MAX)
	var candidates: Array[Dictionary] = []
	for name: String in LAYER_ORDER:
		for index: int in count(name):
			var offset: Vector2 = world_position(name, index) - origin
			var distance: float = offset.length()
			if distance >= radius:
				continue
			var closeness: float = 1.0 - distance / radius
			candidates.append({"layer": name, "index": index, "closeness": closeness, "offset": offset})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["closeness"]) > float(b["closeness"]))
	var velocity_scale: float = sqrt(STIFFNESS)
	for rank: int in mini(candidates.size(), ACTIVE_MAX):
		var item: Dictionary = candidates[rank]
		var amount: float = limit * float(item["closeness"]) * clampf(strength, 0.0, 1.0) if kind != PULSE_BREAK else limit * float(item["closeness"])
		var direction: Vector2
		match kind:
			PULSE_LAND:
				direction = Vector2.UP
			PULSE_SLIDE:
				direction = Vector2(signf((item["offset"] as Vector2).x + 0.001), 0.0).rotated(PI * 0.5)
			_:
				var offset: Vector2 = item["offset"]
				direction = offset.normalized() if offset.length() > 0.001 else Vector2.UP
		_kick(String(item["layer"]), int(item["index"]), direction * amount * velocity_scale)


func step(delta: float) -> void:
	for name: String in LAYER_ORDER:
		(layers[name] as ProceduralBackdropDynamics).step(delta)


func max_displacement() -> float:
	var worst: float = 0.0
	for name: String in LAYER_ORDER:
		for index: int in count(name):
			worst = maxf(worst, displacement(name, index).length())
	return worst
