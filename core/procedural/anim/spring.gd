class_name ProceduralSpring
extends RefCounted

# PURPOSE: physics integration for every soft motion in TIN. This is the engine
# behind squishy / 말랑말랑 movement: nothing animates by tween when it should
# wobble. Supports critically damped (no overshoot) and under damped
# (bouncy) behaviour.
# OWNER: W2 (core/procedural). PUBLIC SIGNATURES ARE FROZEN.
#
# Model: a = stiffness * (target - value) - 2 * damping_ratio * sqrt(stiffness) * velocity
# `stiffness` is omega squared, so it is a rate, not a mass. Integration is
# semi-implicit Euler with a fixed substep, which keeps the result identical at
# any frame rate and independent of the host's delta jitter.

const CRITICAL_DAMPING: float = 1.0
const DEFAULT_STIFFNESS: float = 90.0
const UNDER_DAMPED_RATIO: float = 0.45
const MAX_SUBSTEP: float = 1.0 / 240.0
const MAX_SUBSTEPS: int = 8

var value: float = 0.0
var velocity: float = 0.0
var target: float = 0.0
var stiffness: float = DEFAULT_STIFFNESS
var damping_ratio: float = CRITICAL_DAMPING


func _init(p_value: float = 0.0, p_stiffness: float = DEFAULT_STIFFNESS, p_damping_ratio: float = CRITICAL_DAMPING) -> void:
	value = p_value
	target = p_value
	stiffness = p_stiffness
	damping_ratio = p_damping_ratio


func configure(p_stiffness: float, p_damping_ratio: float) -> void:
	stiffness = maxf(p_stiffness, 0.0001)
	damping_ratio = maxf(p_damping_ratio, 0.0)


func set_target(target_value: float) -> void:
	target = target_value


## Adds velocity without moving the value. Use for impacts and gusts.
func kick(impulse: float) -> void:
	velocity += impulse


## Teleports value and target, clearing velocity.
func snap(value_now: float) -> void:
	value = value_now
	target = value_now
	velocity = 0.0


func reset() -> void:
	snap(value)


func step(delta: float) -> float:
	if delta <= 0.0:
		return value
	var damping: float = 2.0 * damping_ratio * sqrt(maxf(stiffness, 0.0001))
	var steps: int = clampi(int(ceil(delta / MAX_SUBSTEP)), 1, MAX_SUBSTEPS)
	var sub_delta: float = delta / float(steps)
	for _step: int in steps:
		velocity += (stiffness * (target - value) - damping * velocity) * sub_delta
		value += velocity * sub_delta
	return value


func is_settled(epsilon: float = 0.001) -> bool:
	return absf(target - value) <= epsilon and absf(velocity) <= epsilon


static func critical(p_value: float, p_stiffness: float = DEFAULT_STIFFNESS) -> ProceduralSpring:
	return ProceduralSpring.new(p_value, p_stiffness, CRITICAL_DAMPING)


static func under_damped(p_value: float, p_stiffness: float = DEFAULT_STIFFNESS, p_damping_ratio: float = UNDER_DAMPED_RATIO) -> ProceduralSpring:
	return ProceduralSpring.new(p_value, p_stiffness, clampf(p_damping_ratio, 0.0, 1.0))


## Two axis counterpart of ProceduralSpring, same maths per axis.
class Spring2D:
	var value: Vector2 = Vector2.ZERO
	var velocity: Vector2 = Vector2.ZERO
	var target: Vector2 = Vector2.ZERO
	var stiffness: float = ProceduralSpring.DEFAULT_STIFFNESS
	var damping_ratio: float = ProceduralSpring.CRITICAL_DAMPING

	func _init(p_value: Vector2 = Vector2.ZERO, p_stiffness: float = ProceduralSpring.DEFAULT_STIFFNESS, p_damping_ratio: float = ProceduralSpring.CRITICAL_DAMPING) -> void:
		value = p_value
		target = p_value
		stiffness = p_stiffness
		damping_ratio = p_damping_ratio

	func configure(p_stiffness: float, p_damping_ratio: float) -> void:
		stiffness = maxf(p_stiffness, 0.0001)
		damping_ratio = maxf(p_damping_ratio, 0.0)

	func set_target(target_value: Vector2) -> void:
		target = target_value

	func kick(impulse: Vector2) -> void:
		velocity += impulse

	func snap(value_now: Vector2) -> void:
		value = value_now
		target = value_now
		velocity = Vector2.ZERO

	func step(delta: float) -> Vector2:
		if delta <= 0.0:
			return value
		var damping: float = 2.0 * damping_ratio * sqrt(maxf(stiffness, 0.0001))
		var steps: int = clampi(int(ceil(delta / ProceduralSpring.MAX_SUBSTEP)), 1, ProceduralSpring.MAX_SUBSTEPS)
		var sub_delta: float = delta / float(steps)
		for _step: int in steps:
			velocity += (stiffness * (target - value) - damping * velocity) * sub_delta
			value += velocity * sub_delta
		return value

	func is_settled(epsilon: float = 0.001) -> bool:
		return (target - value).length() <= epsilon and velocity.length() <= epsilon
