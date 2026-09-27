class_name EcoSettleSystem
extends RefCounted

const UNIT: float = 1
const CYCLE_SECONDS: float = 420.0
const PHASE_QUIET: StringName = &"QUIET"
const PHASE_LOADING: StringName = &"LOADING"
const PHASE_PRESSING: StringName = &"PRESSING"
const PHASE_EASING: StringName = &"EASING"
const PHASE_STILL: StringName = &"STILL"
const BOUNDS: Array[float] = [0.0, 120.0, 210.0, 300.0, 360.0, 420.0]
const PHASES: Array[StringName] = [PHASE_QUIET, PHASE_LOADING, PHASE_PRESSING, PHASE_EASING, PHASE_STILL]
const PRESS_AT: Array[float] = [0.0, 0.0, 0.55, UNIT, 0.0, 0.0]
const GRAVITY_AT: Array[float] = [UNIT, UNIT, 1.14, 1.35, UNIT, UNIT]
const FRICTION_AT: Array[float] = [UNIT, UNIT, 0.93, 0.86, UNIT, UNIT]
const PEAK_GRAVITY_MULT: float = 1.35
const COMPRESS_FRICTION_MULT: float = 0.86
const COMPRESS_FRICTION_PRESS_MIN: float = 0.35
const SALT_COMPRESS_RATE: float = 0.06
const SALT_COMPRESS_PRESS_MIN: float = 0.35
const SALT_BED_TRACE_MAX: float = 0.60
const DRIFT_FLOW_PRESS_MIN: float = 0.55
const AUDIO_CYCLE_ON: float = 0.45
const WIND_BASE_X: float = -38.0

var press: float = 0.0
var gravity_mult: float = 1
var friction_mult: float = 1
var phase: StringName = PHASE_QUIET


static func _segment(t: float) -> int:
	for i: int in PHASES.size():
		if t < BOUNDS[i + 1]:
			return i
	return PHASES.size() - 1


static func _lerp_table(values: Array[float], t: float) -> float:
	var i: int = _segment(t)
	var a: float = BOUNDS[i]
	var b: float = BOUNDS[i + 1]
	var u: float = clampf((t - a) / (b - a), 0.0, 1)
	return lerpf(values[i], values[i + 1], u)


static func press_at(t: float) -> float:
	return _lerp_table(PRESS_AT, fposmod(t, CYCLE_SECONDS))


static func gravity_mult_at(t: float) -> float:
	return _lerp_table(GRAVITY_AT, fposmod(t, CYCLE_SECONDS))


static func friction_table_at(t: float) -> float:
	return _lerp_table(FRICTION_AT, fposmod(t, CYCLE_SECONDS))


static func phase_at(t: float) -> StringName:
	return PHASES[_segment(fposmod(t, CYCLE_SECONDS))]


static func drift_friction_at(t: float) -> float:
	if press_at(t) <= COMPRESS_FRICTION_PRESS_MIN:
		return 1
	return friction_table_at(t)


func sample(t: float) -> void:
	press = press_at(t)
	gravity_mult = gravity_mult_at(t)
	friction_mult = drift_friction_at(t)
	phase = phase_at(t)


func advance(world: EcoWorldState, room: EcoRoomSpec, dt: float) -> Dictionary:
	var before: float = press_at(world.t_settle)
	var before_phase: StringName = phase_at(world.t_settle)
	world.t_settle += dt
	if world.t_settle >= CYCLE_SECONDS:
		world.t_settle = fposmod(world.t_settle, CYCLE_SECONDS)
	sample(world.t_settle)
	var events: Dictionary = {"drift_dropped": PackedStringArray(), "entered_pressing": false, "audio_on": false}
	if room == null:
		return events
	if press > SALT_COMPRESS_PRESS_MIN:
		for t: Dictionary in room.triggers:
			if str(t["object"]) == "salt_bed":
				var id: String = str(t["id"])
				var c: float = float(world.compressed_beds.get(id, 0.0))
				world.compressed_beds[id] = minf(SALT_BED_TRACE_MAX, c + SALT_COMPRESS_RATE * press * dt)
	if before <= DRIFT_FLOW_PRESS_MIN and press > DRIFT_FLOW_PRESS_MIN:
		for p: EcoPassageSpec in room.passages:
			if p.kind == EcoPassageKind.GAP and p.drift:
				var steps: int = int(world.drift_drops.get(p.id, 0))
				if EcoGapClass.narrowed_by(p.width_class, steps) != EcoGapClass.ORDER[0]:
					world.drift_drops[p.id] = steps + 1
					(events["drift_dropped"] as PackedStringArray).append(p.id)
	if before_phase != PHASE_PRESSING and phase == PHASE_PRESSING:
		events["entered_pressing"] = true
	if before < AUDIO_CYCLE_ON and press >= AUDIO_CYCLE_ON:
		events["audio_on"] = true
	return events


func wind() -> Vector2:
	return Vector2(WIND_BASE_X * press, 0.0)
