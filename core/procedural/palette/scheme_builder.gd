class_name ProceduralPaletteScheme
extends RefCounted

# PURPOSE: derives one harmonious palette from a single seed and fills every
# ProceduralPalette role. Colour harmony comes from a chosen hue relationship,
# never from hand picked RGB values.
# OWNER: W2 (core/procedural). PUBLIC SIGNATURES ARE FROZEN.

const SCHEME_ANALOGOUS: StringName = &"analogous"
const SCHEME_COMPLEMENTARY: StringName = &"complementary"
const SCHEME_SPLIT_COMPLEMENTARY: StringName = &"split_complementary"
const SCHEME_TRIADIC: StringName = &"triadic"
const SCHEME_TETRADIC: StringName = &"tetradic"

const SCHEMES: Array = [
	SCHEME_ANALOGOUS,
	SCHEME_COMPLEMENTARY,
	SCHEME_SPLIT_COMPLEMENTARY,
	SCHEME_TRIADIC,
	SCHEME_TETRADIC,
]

## body, complement, accent, neighbour as hue offsets from base_hue.
const OFFSETS: Dictionary = {
	SCHEME_ANALOGOUS: [-0.09, 0.5, 0.09, 0.18],
	SCHEME_COMPLEMENTARY: [0.0, 0.5, -0.06, 0.55],
	SCHEME_SPLIT_COMPLEMENTARY: [0.0, 0.416, 0.584, 0.08],
	SCHEME_TRIADIC: [0.0, 0.333, 0.666, 0.05],
	SCHEME_TETRADIC: [0.0, 0.25, 0.5, 0.75],
}

const HUE_DANGER: float = 0.02

var scheme: StringName = SCHEME_ANALOGOUS
var base_hue: float = 0.55
var saturation: float = 0.6
var contrast: float = 1.0


func build(stream: ProceduralSeed, variant: int = 0) -> ProceduralPalette:
	var rng: RandomNumberGenerator = stream.make_rng()
	if variant != 0:
		rng.seed = ProceduralSeed.mix(stream.value, variant) & ProceduralSeed.POSITIVE_MASK_31
	return _assemble(StringName(SCHEMES[rng.randi_range(0, SCHEMES.size() - 1)]), rng)


func build_named(stream: ProceduralSeed, scheme_name: StringName, variant: int = 0) -> ProceduralPalette:
	var rng: RandomNumberGenerator = stream.make_rng()
	if variant != 0:
		rng.seed = ProceduralSeed.mix(stream.value, variant) & ProceduralSeed.POSITIVE_MASK_31
	return _assemble(scheme_name if OFFSETS.has(scheme_name) else SCHEME_ANALOGOUS, rng)


func get_scheme_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for entry: Variant in SCHEMES:
		names.append(StringName(entry))
	return names


func _assemble(scheme_name: StringName, rng: RandomNumberGenerator) -> ProceduralPalette:
	scheme = scheme_name
	base_hue = rng.randf()
	saturation = clampf(rng.randf_range(0.35, 0.78), 0.0, 1.0)
	contrast = clampf(rng.randf_range(0.78, 1.32), 0.2, 2.0)

	var offsets: Array = OFFSETS[scheme]
	var body_hue: float = base_hue + float(offsets[0])
	var complement_hue: float = base_hue + float(offsets[1])
	var accent_hue: float = base_hue + float(offsets[2])
	var neighbour_hue: float = base_hue + float(offsets[3])
	var palette: ProceduralPalette = ProceduralPalette.new()

	palette.set_role(ProceduralPalette.ROLE_BODY, _hsv(body_hue, saturation, 0.60 * contrast))
	palette.set_role(ProceduralPalette.ROLE_BODY_DARK, _hsv(body_hue, saturation * 1.06, 0.33 * contrast))
	palette.set_role(ProceduralPalette.ROLE_BELLY, _hsv(body_hue + 0.03, saturation * 0.78, 0.84 * contrast))
	palette.set_role(ProceduralPalette.ROLE_KEY_LIGHT, _hsv(complement_hue, saturation * 0.62, 0.95 * contrast))
	palette.set_role(ProceduralPalette.ROLE_SHADE, _hsv(body_hue, saturation * 1.12, 0.16 * contrast))
	palette.set_role(ProceduralPalette.ROLE_RIM, _hsv(accent_hue, saturation * 1.15, 1.0))
	palette.set_role(ProceduralPalette.ROLE_ACCENT, _hsv(accent_hue, saturation * 1.2, 0.78 * contrast))
	palette.set_role(ProceduralPalette.ROLE_INK, _hsv(body_hue, saturation * 0.45, 0.07 * contrast))
	palette.set_role(ProceduralPalette.ROLE_GROUND, _hsv(complement_hue, saturation * 0.55, 0.24 * contrast))
	palette.set_role(ProceduralPalette.ROLE_SKY_NEAR, _hsv(body_hue + 0.10, saturation * 0.48, 0.48 * contrast))
	palette.set_role(ProceduralPalette.ROLE_SKY_FAR, _hsv(body_hue + 0.16, saturation * 0.40, 0.78 * contrast))
	palette.set_role(ProceduralPalette.ROLE_FOG, _hsv(body_hue + 0.12, saturation * 0.18, 0.90 * contrast))
	palette.set_role(ProceduralPalette.ROLE_DANGER, _hsv(HUE_DANGER, saturation * 1.3, 0.72 * contrast))
	return palette


func _hsv(hue: float, sat: float, value: float) -> Color:
	return Color.from_hsv(fposmod(hue, 1.0), clampf(sat, 0.0, 1.0), clampf(value, 0.0, 1.0), 1.0)
