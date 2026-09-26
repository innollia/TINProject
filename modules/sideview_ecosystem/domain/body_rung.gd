class_name EcoBodyRung
extends RefCounted

const TILE: float = 24.0
const AASPECT_W: float = 0.60
const MASS_DENSITY: float = 0.42
const MASS_REF_PX: float = 96.0
const USE_RANGE_RATIO: float = 0.32
const FIT_TARGET: float = 2.75
const CAMERA_FRAME_MODULES: float = 6.0
const VIEWPORT_H: float = 720.0
const GRAVITY_BASE: float = 1400.0
const FALL_DAMAGE_DIVISOR: float = 1400.0
const SPRITE_PART_COUNT: int = 18

var rung: String = "speck"
var index: int = 0
var scale_value: float = 0.0
var run_speed: float = 168.0
var accel: float = 1100.0
var jump_height: float = 156.0
var safe_fall_speed: float = 900.0
var max_climb: float = 24.0
var break_power: int = 0
var use_range_ratio: float = USE_RANGE_RATIO
var sprite_part_count: int = SPRITE_PART_COUNT


func jump_speed() -> float:
	return sqrt(2.0 * GRAVITY_BASE * jump_height)


func lethal_fall_speed() -> float:
	return safe_fall_speed + FALL_DAMAGE_DIVISOR


func lethal_fall_px() -> float:
	var v: float = lethal_fall_speed()
	return v * v / (2.0 * GRAVITY_BASE)


func reach_px() -> float:
	return jump_height + max_climb


func q_in(band_value: float) -> float:
	if band_value <= 0.0:
		return 0.0
	return scale_value / band_value


func derive(band_value: float, target_body_px: float) -> Dictionary:
	if band_value <= 0.0 or target_body_px <= 0.0:
		return {}
	var q: float = scale_value / band_value
	var h_px: float = q * target_body_px
	var ratio: float = h_px / MASS_REF_PX
	return {
		"q": q,
		"h_px": h_px,
		"w_px": AASPECT_W * h_px,
		"mass": MASS_DENSITY * ratio * ratio * ratio,
		"use_range_px": use_range_ratio * h_px,
		"module_px": target_body_px / FIT_TARGET,
		"lethal_fall_speed": lethal_fall_speed(),
		"lethal_fall_px": lethal_fall_px(),
	}


func abilities_in(band_value: float) -> int:
	var mask: int = 0
	var q: float = q_in(band_value)
	if q > 0.0 and AASPECT_W * FIT_TARGET * q <= EcoTrait.ABILITY_FLEX_GAP_MULT:
		mask = EcoTrait.add(mask, EcoTrait.FLEX)
	if lethal_fall_px() > EcoTrait.ABILITY_POISE_FALL_PX:
		mask = EcoTrait.add(mask, EcoTrait.POISE)
	if reach_px() >= EcoTrait.ABILITY_LEAP_REACH_PX:
		mask = EcoTrait.add(mask, EcoTrait.LEAP)
	if break_power >= EcoTrait.ABILITY_SHELL_POWER:
		mask = EcoTrait.add(mask, EcoTrait.SHELL)
	if break_power >= EcoTrait.ABILITY_CLAW_POWER:
		mask = EcoTrait.add(mask, EcoTrait.CLAW)
	return mask


func to_dictionary() -> Dictionary:
	return {
		"rung": rung,
		"index": index,
		"run_speed": run_speed,
		"accel": accel,
		"jump_height": jump_height,
		"safe_fall_speed": safe_fall_speed,
		"max_climb": max_climb,
		"break_power": break_power,
	}
