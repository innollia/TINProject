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


## PVE 팔레트는 색상(role -> Color) 을 준다. 이 게임은 **무채색 1px** 계약이다.
## 따라서 역할을 읽은 뒤 휘도만 취하고 채도를 버린다.
## 색을 임의로 새로 만들지는 않는다. PVE 가 정한 "값"만 재사용한다.
static func grey(src: Color, v: float) -> Color:
	var l: float = src.get_luminance()
	var g: float = clampf(lerpf(0.0, 1.0, l) * v, 0.0, 1.0)
	return Color(g, g, g, 1.0)


static func role_grey(pal: ProceduralPalette, role: StringName, fallback: Color, v: float = 1.0) -> Color:
	if pal == null or not pal.has_role(role):
		return fallback
	return grey(pal.get_color(role), v)


## 배경은 예외 없이 순수 검정이다.
## 레터박스/필러박스가 화면과 경계가 없어야 정수 스케일 계약이 성립한다.
static func fill(_pal: ProceduralPalette) -> Color:
	return VOID_FALLBACK


static func line(pal: ProceduralPalette) -> Color:
	return role_grey(pal, &"rim", LINE_FALLBACK, 1.0)


static func line_dim(pal: ProceduralPalette) -> Color:
	return role_grey(pal, &"fog", LINE_DIM_FALLBACK, 1.0)


static func line_far(pal: ProceduralPalette) -> Color:
	return role_grey(pal, &"sky_far", LINE_FAR_FALLBACK, 1.0)


static func text(pal: ProceduralPalette) -> Color:
	return role_grey(pal, &"body", LINE_FALLBACK, 1.0)


static func text_dim(pal: ProceduralPalette) -> Color:
	return role_grey(pal, &"body_dark", LINE_DIM_FALLBACK, 1.0)


static func alert(pal: ProceduralPalette) -> Color:
	return role_grey(pal, &"danger", ALERT_FALLBACK, 1.0)


static func accent(pal: ProceduralPalette) -> Color:
	return role_grey(pal, &"accent", ACCENT_FALLBACK, 1.0)


## 밀도 3단계 -> 실루엣 색. (evidence / navigation / mood)
static func density_color(pal: ProceduralPalette, role: int) -> Color:
	match role:
		0: return line(pal)
		1: return line_dim(pal)
		_: return line_far(pal)
