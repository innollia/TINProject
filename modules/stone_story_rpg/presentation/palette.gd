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
const VOID_FALLBACK := Color(0.0, 0.0, 0.0, 1.0)
const LINE_FALLBACK := Color(0.86, 0.86, 0.86, 1.0)
const LINE_DIM_FALLBACK := Color(0.42, 0.42, 0.42, 1.0)
const LINE_FAR_FALLBACK := Color(0.26, 0.26, 0.26, 1.0)
const ALERT_FALLBACK := Color(0.78, 0.24, 0.20, 1.0)
const ACCENT_FALLBACK := Color(0.30, 0.72, 0.52, 1.0)


static func role_color(pal: ProceduralPalette, role: StringName, fallback: Color) -> Color:
	if pal == null or not pal.has_role(role):
		return fallback
	return pal.get_color(role)


## 배경은 예외 없이 순수 검정이다.
## 레터박스/필러박스가 화면과 경계가 없어야 정수 스케일 계약이 성립한다.
static func fill(_pal: ProceduralPalette) -> Color:
	return VOID_FALLBACK


static func line(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"rim", role_color(pal, &"body", LINE_FALLBACK))


static func line_dim(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"fog", role_color(pal, &"body_dark", LINE_DIM_FALLBACK))


static func line_far(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"sky_far", role_color(pal, &"fog", LINE_FAR_FALLBACK))


static func text(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"body", LINE_FALLBACK)


static func text_dim(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"body_dark", LINE_DIM_FALLBACK)


static func alert(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"danger", ALERT_FALLBACK)


static func accent(pal: ProceduralPalette) -> Color:
	return role_color(pal, &"accent", role_color(pal, &"key_light", ACCENT_FALLBACK))


## 밀도 3단계 -> 실루엣 색. (evidence / navigation / mood)
static func density_color(pal: ProceduralPalette, role: int) -> Color:
	match role:
		0: return line(pal)
		1: return line_dim(pal)
		_: return line_far(pal)
