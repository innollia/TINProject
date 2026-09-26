class_name StoneStoryPalette
extends RefCounted

## 색은 PVE 의 ProceduralPalette 역할로만 온다. 리터럴 RGB 를 여기 박지 않는다.
## 역할 이름은 PVE CONTRACT 의 ROLE_* 을 그대로 쓴다.

const VOID := &"ink"
const LINE := &"rim"
const LINE_DIM := &"fog"
const LINE_FAR := &"sky_far"
const TEXT := &"body"
const TEXT_DIM := &"body_dark"
const ALERT := &"danger"
const KEY := &"key_light"


static func build(region_id: String, world_seed: int) -> ProceduralPalette:
	var s: ProceduralSeed = Procedural.derive_seed(world_seed, "palette." + region_id)
	return Procedural.make_palette(s, 0)


## 빈 화면/여백. 항상 순수 검정이어야 여백이 보이지 않는다.
# 폴백도 색이 있다. 무채색 기본값은 폐기했다. (2026-09-26)
const VOID_FALLBACK := Color(0.06, 0.07, 0.09, 1.0)
const LINE_FALLBACK := Color(0.93, 0.90, 0.82, 1.0)
const LINE_DIM_FALLBACK := Color(0.62, 0.55, 0.46, 1.0)
const LINE_FAR_FALLBACK := Color(0.38, 0.35, 0.34, 1.0)
const ALERT_FALLBACK := Color(0.92, 0.30, 0.26, 1.0)
const ACCENT_FALLBACK := Color(0.36, 0.78, 0.62, 1.0)
const SKY_NEAR_FALLBACK := Color(0.32, 0.62, 0.66, 1.0)
const SKY_FAR_FALLBACK := Color(0.86, 0.72, 0.36, 1.0)
const GROUND_FALLBACK := Color(0.78, 0.46, 0.22, 1.0)
const STRUCTURE_FALLBACK := Color(0.30, 0.42, 0.44, 1.0)
const BODY_FALLBACK := Color(0.20, 0.18, 0.22, 1.0)
const BODY_DARK_FALLBACK := Color(0.12, 0.11, 0.15, 1.0)
const BELLY_FALLBACK := Color(0.52, 0.34, 0.48, 1.0)


## PVE 팔레트는 색상(role -> Color) 을 준다. 그 색을 **그대로 쓴다.**
## 1차 판이 여기에 그레이스케일 변환을 강제했다. 2026-09-26 폐기:
## "저런 미니멀리즘 도트 폰트 아니야" —— Ena 는 고채도다. 채도를 남긴다.
static func role_color(pal: ProceduralPalette, role: StringName, fallback: Color) -> Color:
	if pal == null or not pal.has_role(role):
		return fallback
	return pal.get_color(role)


## 순수 검정 단색 배경은 금지다. (V2)
## 하늘/바닥/구조물이 면으로 존재해야 한다. 여백용 검정은 프레임만 담당한다.
static func void_black() -> Color:
	return Color(0.0, 0.0, 0.0, 1.0)


static func fill(_pal: ProceduralPalette) -> Color:
	return VOID_FALLBACK


static func line(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"rim", LINE_FALLBACK)


static func line_dim(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"fog", LINE_DIM_FALLBACK)


static func line_far(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"sky_far", LINE_FAR_FALLBACK)


static func text(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"key_light", LINE_FALLBACK)


static func text_dim(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"body", LINE_DIM_FALLBACK)


static func alert(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"danger", ALERT_FALLBACK)


static func accent(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"accent", ACCENT_FALLBACK)


## 공간의 3축. (V1) 빈 검정 화면을 만들지 않게 하는 최소 색.
static func sky_near(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"sky_near", SKY_NEAR_FALLBACK)


static func sky_far(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"sky_far", SKY_FAR_FALLBACK)


static func ground(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"ground", GROUND_FALLBACK)


static func structure(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"body_dark", STRUCTURE_FALLBACK)


static func body(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"body", BODY_FALLBACK)


static func body_dark(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"body_dark", BODY_DARK_FALLBACK)


static func belly(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"belly", BELLY_FALLBACK)
