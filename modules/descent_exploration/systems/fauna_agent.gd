class_name FaunaAgent
extends RefCounted

const GRAZER_PATROL_SPEED: float = 34.0
const GRAZER_CHASE_SPEED: float = 50.0
const GRAZER_FLEE_MASS: int = 2
const GRAZER_LOSE_RADIUS: float = 140.0
const WARDEN_IGNORE_TOP: float = 240.0
const WARDEN_CHASE_SPEED: float = 56.0
const FAUNA_CONTACT_RADIUS: float = 7.0


static func step_all(state: DescentState, runtime: StratumRuntime, delta: float) -> Array[Dictionary]:
	var pending: Array[Dictionary] = []
	for creature: Dictionary in runtime.fauna:
		if bool(creature["remains"]):
			continue
		match String(creature["kind"]):
			"grazer":
				_step_grazer(creature, state, runtime, delta)
			"warden":
				_step_warden(creature, state, runtime, delta)
			_:
				continue
		if not bool(creature["active"]) or not bool(creature["hostile"]):
			continue
		if DescentCollision.distance_to_point(state.body_box(), creature["position"] as Vector2) <= FAUNA_CONTACT_RADIUS:
			pending.append({"amount": Vitality.DAMAGE_PER_HIT, "source": String(creature["id"])})
	return pending


static func _step_grazer(creature: Dictionary, state: DescentState, runtime: StratumRuntime, delta: float) -> void:
	var here: Vector2 = creature["position"]
	creature["active"] = true
	if here.distance_to(state.position) > GRAZER_LOSE_RADIUS:
		creature["mode"] = "patrol"
		creature["hostile"] = false
		var home: Vector2 = creature["home"]
		var span: Vector2 = creature["patrol"]
		var target := Vector2(home.x, float(creature["patrol_target"]))
		var moved: Vector2 = here.move_toward(target, GRAZER_PATROL_SPEED * delta)
		if moved.distance_to(target) <= 0.5:
			creature["patrol_target"] = span.x if is_equal_approx(float(creature["patrol_target"]), span.y) else span.y
		creature["position"] = _clamp(moved, runtime)
		return
	if state.mass >= GRAZER_FLEE_MASS:
		creature["mode"] = "flee"
		creature["hostile"] = false
		var away: Vector2 = here - state.position
		if away.length() < 0.001:
			away = Vector2(0.0, -1.0)
		creature["position"] = _clamp(here + away.normalized() * GRAZER_CHASE_SPEED * delta, runtime)
		return
	creature["mode"] = "chase"
	creature["hostile"] = true
	creature["position"] = _clamp(here.move_toward(state.position, GRAZER_CHASE_SPEED * delta), runtime)


static func _step_warden(creature: Dictionary, state: DescentState, runtime: StratumRuntime, delta: float) -> void:
	var line: float = float(creature["line_y"]) if bool(creature["has_line"]) else WARDEN_IGNORE_TOP
	if state.position.y < line:
		creature["mode"] = "absent"
		creature["active"] = false
		creature["hostile"] = false
		return
	creature["mode"] = "chase"
	creature["active"] = true
	creature["hostile"] = true
	var here: Vector2 = creature["position"]
	creature["position"] = _clamp(here.move_toward(state.position, WARDEN_CHASE_SPEED * delta), runtime)


static func _clamp(point: Vector2, runtime: StratumRuntime) -> Vector2:
	return Vector2(clampf(point.x, runtime.bounds.position.x, runtime.bounds.end.x), clampf(point.y, runtime.bounds.position.y, runtime.bounds.end.y))
