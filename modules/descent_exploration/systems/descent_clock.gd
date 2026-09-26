class_name DescentClock
extends RefCounted

const FIXED_HZ: float = 120.0
const STEP: float = 1.0 / FIXED_HZ
const MAX_SUBSTEPS: int = 4

var _accumulator: float = 0.0


func begin_frame(delta: float) -> int:
	if not is_finite(delta) or delta <= 0.0:
		return 0
	_accumulator += delta
	var steps: int = int(floor(_accumulator / STEP + 0.000001))
	if steps > MAX_SUBSTEPS:
		_accumulator = 0.0
		return MAX_SUBSTEPS
	_accumulator = maxf(0.0, _accumulator - float(steps) * STEP)
	return steps


func reset() -> void:
	_accumulator = 0.0
