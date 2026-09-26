class_name EcoPassageResolver
extends RefCounted

const GAP_PASS: int = 0
const GAP_SQUEEZE: int = 1
const GAP_BLOCK: int = 2


static func gap_width_px(spec: EcoPassageSpec, target_body_px: float, drift_steps: int = 0) -> float:
	var width_class: String = EcoGapClass.narrowed_by(spec.width_class, drift_steps)
	return EcoGapClass.multiplier(width_class) * target_body_px / EcoBodyRung.FIT_TARGET


static func gap_state(spec: EcoPassageSpec, body: EcoBodyRung, band_value: float, target_body_px: float, drift_steps: int = 0) -> int:
	var d: Dictionary = body.derive(band_value, target_body_px)
	if d.is_empty():
		return GAP_BLOCK
	var w_body: float = float(d["w_px"])
	var w_gap: float = gap_width_px(spec, target_body_px, drift_steps)
	if w_body > w_gap:
		return GAP_BLOCK
	if w_gap < EcoGapClass.SQUEEZE_RATIO * w_body:
		return GAP_SQUEEZE
	return GAP_PASS


static func breaks_in_one_strike(body: EcoBodyRung, hp: int) -> bool:
	return body.break_power >= hp


static func mass_in(body: EcoBodyRung, band_value: float, target_body_px: float) -> float:
	var d: Dictionary = body.derive(band_value, target_body_px)
	if d.is_empty():
		return 0.0
	return float(d["mass"])


static func passable(spec: EcoPassageSpec, body: EcoBodyRung, band_value: float, target_body_px: float) -> bool:
	match spec.kind:
		EcoPassageKind.GAP:
			return gap_state(spec, body, band_value, target_body_px) != GAP_BLOCK
		EcoPassageKind.STEP:
			return spec.height_px <= body.reach_px()
		EcoPassageKind.DROP:
			return spec.fall_px < body.lethal_fall_px()
		EcoPassageKind.BREAK:
			return breaks_in_one_strike(body, spec.hp)
		EcoPassageKind.PRESS:
			return mass_in(body, band_value, target_body_px) >= spec.mass_required
	return false
