class_name PlayerMotion
extends RefCounted

const SWIM_UP_SPEED: float = 70.0
const SINK_ACCEL: float = 22.0
const SINK_TERMINAL_BASE: float = 30.0
const SINK_PER_MASS: float = 14.0
const DIVE_ACCEL: float = 46.0
const DIVE_TERMINAL_FACTOR: float = 1.25
const HORIZ_MAX_BASE: float = 62.0
const HORIZ_MAX_PER_MASS: float = 3.0
const HORIZ_ACCEL_BASE: float = 240.0
const HORIZ_ACCEL_PER_MASS: float = 28.0
const LINEAR_DRAG: float = 1.6
const FACING_SWITCH_MIN: float = 8.0
const SURGE_SPEED_BASE: float = 168.0
const SURGE_SPEED_PER_MASS: float = 20.0
const SURGE_TIME: float = 0.16
const SURGE_COOLDOWN: float = 0.45
const SURGE_BREAKS_BRITTLE: bool = true


static func sink_terminal(mass: int) -> float:
	return SINK_TERMINAL_BASE + SINK_PER_MASS * float(clampi(mass, 0, DescentState.MAX_CARRY_MASS))


static func dive_terminal(mass: int) -> float:
	return sink_terminal(mass) * DIVE_TERMINAL_FACTOR


static func horiz_max(mass: int) -> float:
	return HORIZ_MAX_BASE - HORIZ_MAX_PER_MASS * float(clampi(mass, 0, DescentState.MAX_CARRY_MASS))


static func horiz_accel(mass: int) -> float:
	return HORIZ_ACCEL_BASE - HORIZ_ACCEL_PER_MASS * float(clampi(mass, 0, DescentState.MAX_CARRY_MASS))


static func surge_speed(mass: int) -> float:
	return SURGE_SPEED_BASE - SURGE_SPEED_PER_MASS * float(clampi(mass, 0, DescentState.MAX_CARRY_MASS))


static func step(state: DescentState, intent: RunIntent, mass: int, delta: float) -> bool:
	var relative: Vector2 = state.velocity - state.flow
	state.surge_cooldown_for = maxf(0.0, state.surge_cooldown_for - delta)
	state.surge_active_for = maxf(0.0, state.surge_active_for - delta)
	var surged: bool = false
	var direction: Vector2 = intent.direction() if intent != null else Vector2.ZERO
	if intent != null and intent.surge and state.surge_cooldown_for <= 0.0 and state.surge_active_for <= 0.0:
		var heading: Vector2 = direction
		if heading == Vector2.ZERO:
			heading = Vector2(float(state.facing), 0.0)
		state.surge_vector = heading.normalized() * surge_speed(mass)
		state.surge_active_for = SURGE_TIME
		state.surge_cooldown_for = SURGE_COOLDOWN
		surged = true
	if state.surge_active_for > 0.0:
		relative = state.surge_vector
	else:
		if direction.x != 0.0:
			relative.x = move_toward(relative.x, direction.x * horiz_max(mass), horiz_accel(mass) * delta)
		else:
			relative.x *= maxf(0.0, 1.0 - LINEAR_DRAG * delta)
		var rising: bool = intent != null and intent.up and not intent.down
		var diving: bool = intent != null and intent.down and not intent.up
		if rising:
			relative.y = move_toward(relative.y, -SWIM_UP_SPEED, horiz_accel(mass) * delta)
		elif diving:
			relative.y = move_toward(relative.y, dive_terminal(mass), DIVE_ACCEL * delta)
		else:
			relative.y = move_toward(relative.y, sink_terminal(mass), SINK_ACCEL * delta)
	state.velocity = relative + state.flow
	if absf(state.velocity.x) >= FACING_SWITCH_MIN:
		state.facing = 1 if state.velocity.x > 0.0 else -1
	return surged
