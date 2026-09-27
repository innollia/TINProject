class_name EcoProceduralBridge
extends RefCounted

## §0.1, §5.1. core/procedural 와 이 Kit 사이의 유일한 어댑터. domain/ 와 systems/
## 는 이 파일을 모른다. ProceduralScaleFit.signature(q) 는 아직 없다(OQ-1) — 그
## 함수가 생기면 여기 한 곳만 고친다. 그동안 5독자 중 2·3·4(시각 신호)는 만들지
## 않고, 1(카메라 프레임)과 5(pitch_scale)만 EcoBodyRung 의 식으로 계산한다.

const FIT_TARGET: float = 2.75
const CAMERA_FRAME_MODULES: float = 6.0


static func module_px(target_body_px: float) -> float:
	return target_body_px / FIT_TARGET


static func cam_zoom(target_body_px: float, viewport_h: float = 720.0) -> float:
	var m: float = module_px(target_body_px)
	if m <= 0.0:
		return 1.0
	return viewport_h / (CAMERA_FRAME_MODULES * m)


static func q_of(rung_scale_value: float, band_value: float) -> float:
	if band_value <= 0.0:
		return 1.0
	return rung_scale_value / band_value


static func pitch_scale(rung_scale_value: float, band_value: float) -> float:
	return q_of(rung_scale_value, band_value)
