class_name StoneStoryPalette
extends RefCounted

## 씬의 5색은 content/palette/*.json 이 정한다. 변형은 PVE ProceduralPalette 의 shifted / mix_roles 로만 만든다.

const SKY := &"sky"
const HORIZON := &"horizon"
const GROUND := &"ground"
const STRUCTURE := &"structure"
const ACCENT := &"accent"
const AUTHORED: Array[StringName] = [SKY, HORIZON, GROUND, STRUCTURE, ACCENT]

const SKY_NEAR_FALLBACK := Color(0.17, 0.70, 0.68, 1.0)
const SKY_FAR_FALLBACK := Color(0.97, 0.79, 0.28, 1.0)
const GROUND_FALLBACK := Color(0.91, 0.51, 0.23, 1.0)
const STRUCTURE_FALLBACK := Color(0.09, 0.28, 0.30, 1.0)
const ACCENT_FALLBACK := Color(1.0, 0.31, 0.58, 1.0)

const FALLBACK: Dictionary = {
	SKY: SKY_NEAR_FALLBACK,
	HORIZON: SKY_FAR_FALLBACK,
	GROUND: GROUND_FALLBACK,
	STRUCTURE: STRUCTURE_FALLBACK,
	ACCENT: ACCENT_FALLBACK,
}


static func from_def(def: Dictionary) -> ProceduralPalette:
	var colors: Dictionary = def.get("colors", {})
	var pal: ProceduralPalette = ProceduralPalette.from_dictionary(colors)
	for role in AUTHORED:
		if not pal.has_role(role):
			pal.set_role(role, FALLBACK[role])
	return pal


static func for_region(content: StoneStoryContent, region_def: Dictionary) -> ProceduralPalette:
	var def: Dictionary = {}
	if content != null:
		def = content.get_def("palette", str(region_def.get("palette", "")))
	return from_def(def)


static func authored_hex(pal: ProceduralPalette) -> Dictionary:
	var out: Dictionary = {}
	for role in AUTHORED:
		out[String(role)] = pal.get_color(role).to_html(false)
	return out


static func sky(pal: ProceduralPalette) -> Color:
	return pal.get_color(SKY)


static func horizon(pal: ProceduralPalette) -> Color:
	return pal.get_color(HORIZON)


static func ground(pal: ProceduralPalette) -> Color:
	return pal.get_color(GROUND)


static func structure(pal: ProceduralPalette) -> Color:
	return pal.get_color(STRUCTURE)


static func accent(pal: ProceduralPalette) -> Color:
	return pal.get_color(ACCENT)


static func sky_at(pal: ProceduralPalette, t: float) -> Color:
	var k: float = clampf(t, 0.0, 1.0)
	if k <= 0.80:
		return pal.mix_roles(SKY, HORIZON, k / 0.80)
	var low: Color = pal.mix_roles(HORIZON, GROUND, 0.42)
	return horizon(pal).lerp(low, (k - 0.80) / 0.20)


static func ground_at(pal: ProceduralPalette, t: float) -> Color:
	var k: float = clampf(t, 0.0, 1.0)
	var far: Color = pal.mix_roles(GROUND, HORIZON, 0.30)
	var near: Color = pal.shifted(GROUND, 1.04, 1.06)
	return far.lerp(near, pow(k, 0.7))


static func cloud(pal: ProceduralPalette) -> Color:
	return pal.shifted(HORIZON, 1.18, 0.20)


static func cloud_shade(pal: ProceduralPalette) -> Color:
	return pal.mix_roles(HORIZON, SKY, 0.35).lightened(0.30)


static func ink(pal: ProceduralPalette) -> Color:
	return pal.shifted(STRUCTURE, 0.42, 1.0)


static func ink_soft(pal: ProceduralPalette) -> Color:
	return pal.shifted(STRUCTURE, 0.62, 0.95)


static func sclera(pal: ProceduralPalette) -> Color:
	return pal.shifted(HORIZON, 1.2, 0.14)


static func shadow(pal: ProceduralPalette) -> Color:
	var c: Color = pal.shifted(GROUND, 0.52, 1.1)
	c.a = 0.42
	return c


static func path(pal: ProceduralPalette) -> Color:
	var c: Color = pal.mix_roles(GROUND, HORIZON, 0.55)
	return Color.from_hsv(c.h, c.s * 0.42, minf(1.0, c.v * 1.02))


static func path_lit(pal: ProceduralPalette) -> Color:
	var c: Color = path(pal)
	return Color.from_hsv(c.h, c.s * 0.8, minf(1.0, c.v * 1.08))


static func text(pal: ProceduralPalette) -> Color:
	return pal.shifted(HORIZON, 1.16, 0.40)


static func text_dim(pal: ProceduralPalette) -> Color:
	return pal.mix_roles(HORIZON, STRUCTURE, 0.38)


static func panel(pal: ProceduralPalette) -> Color:
	return pal.shifted(STRUCTURE, 0.40, 0.95)


static func panel_edge(pal: ProceduralPalette) -> Color:
	return pal.shifted(STRUCTURE, 0.62, 0.9)


static func role(pal: ProceduralPalette, name: String) -> Color:
	match name:
		"wall", "rib":
			return structure(pal)
		"wall_lit":
			return pal.shifted(STRUCTURE, 1.28, 0.85)
		"wall_dark":
			return pal.shifted(STRUCTURE, 0.72, 1.05)
		"rib_far":
			return pal.shifted(STRUCTURE, 1.18, 0.80)
		"rib_lit":
			return pal.shifted(STRUCTURE, 1.55, 0.75)
		"glass":
			var g: Color = pal.shifted(SKY, 1.45, 0.45)
			g.a = 0.30
			return g
		"opening", "ink", "hole":
			return ink(pal)
		"trim":
			return accent(pal)
		"trim_dark":
			return pal.shifted(ACCENT, 0.70, 1.0)
		"gold":
			return pal.shifted(HORIZON, 0.92, 1.12)
		"sun_black":
			return pal.shifted(STRUCTURE, 0.22, 1.0)
		"sky_hole":
			return sky_at(pal, 0.78)
		"stone":
			return pal.shifted(GROUND, 0.74, 0.78)
		"stone_lit":
			return pal.shifted(GROUND, 0.94, 0.62)
		"stone_dark":
			return pal.shifted(GROUND, 0.52, 0.88)
		"wood":
			return pal.shifted(ACCENT, 0.52, 0.85)
		"clay":
			return pal.shifted(STRUCTURE, 1.75, 0.78)
		"clay_lit":
			return pal.shifted(STRUCTURE, 2.3, 0.62)
		"clay_dark":
			return pal.shifted(STRUCTURE, 1.15, 0.9)
		"path":
			return path(pal)
		"path_lit":
			return path_lit(pal)
		"accent":
			return accent(pal)
		"sclera":
			return sclera(pal)
	return structure(pal)


static func line(pal: ProceduralPalette) -> Color:
	return text(pal)


static func line_dim(pal: ProceduralPalette) -> Color:
	return text_dim(pal)


static func sky_near(pal: ProceduralPalette) -> Color:
	return sky(pal)


static func sky_far(pal: ProceduralPalette) -> Color:
	return horizon(pal)


static func alert(pal: ProceduralPalette) -> Color:
	return accent(pal)
