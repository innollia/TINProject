class_name ProceduralPalette
extends RefCounted

# PURPOSE: colour ROLES, not fixed RGB. A Kit asks for "body" or "rim" and gets
# whatever colour the scheme derived for that role this run. This is the only
# place a Kit is allowed to name a colour, and it never names a literal RGB.
# OWNER: W2 (core/procedural). PUBLIC SIGNATURES ARE FROZEN.

const ROLE_KEY_LIGHT: StringName = &"key_light"
const ROLE_SHADE: StringName = &"shade"
const ROLE_RIM: StringName = &"rim"
const ROLE_BODY: StringName = &"body"
const ROLE_BODY_DARK: StringName = &"body_dark"
const ROLE_BELLY: StringName = &"belly"
const ROLE_ACCENT: StringName = &"accent"
const ROLE_INK: StringName = &"ink"
const ROLE_GROUND: StringName = &"ground"
const ROLE_SKY_NEAR: StringName = &"sky_near"
const ROLE_SKY_FAR: StringName = &"sky_far"
const ROLE_FOG: StringName = &"fog"
const ROLE_DANGER: StringName = &"danger"

const DEFAULT_COLOR: Color = Color(0.0, 0.0, 0.0, 0.0)

## role (StringName) -> Color. Insertion order is the scheme's own order.
var roles: Dictionary = {}


func _init(p_roles: Dictionary = {}) -> void:
	for key: Variant in p_roles:
		var value: Variant = p_roles[key]
		if value is Color:
			roles[StringName(key)] = value


func has_role(role: StringName) -> bool:
	return roles.has(role)


func get_color(role: StringName) -> Color:
	if not roles.has(role):
		push_error("ProceduralPalette: unknown role '%s'" % role)
		return DEFAULT_COLOR
	var value: Variant = roles[role]
	if value is Color:
		return value
	push_error("ProceduralPalette: role '%s' does not hold a Color" % role)
	return DEFAULT_COLOR


func get_role_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for key: Variant in roles:
		names.append(StringName(key))
	return names


func set_role(role: StringName, color: Color) -> void:
	roles[role] = color


func mix_roles(from_role: StringName, to_role: StringName, weight: float) -> Color:
	return get_color(from_role).lerp(get_color(to_role), clampf(weight, 0.0, 1.0))


## Shifts one role in HSV. Use instead of writing new colours in a Kit.
func shifted(role: StringName, value_scale: float, saturation_scale: float = 1.0) -> Color:
	var color: Color = get_color(role)
	return Color.from_hsv(
		fposmod(color.h, 1.0),
		clampf(color.s * saturation_scale, 0.0, 1.0),
		clampf(color.v * value_scale, 0.0, 1.0),
		color.a
	)


## JSON safe: role -> [r, g, b, a].
func to_dictionary() -> Dictionary:
	var data: Dictionary = {}
	for key: Variant in roles:
		var color: Color = roles[key]
		data[String(key)] = [color.r, color.g, color.b, color.a]
	return data


## Authoring friendly: role -> "#RRGGBBAA".
func to_html_dictionary() -> Dictionary:
	var data: Dictionary = {}
	for key: Variant in roles:
		var color: Color = roles[key]
		data[String(key)] = color.to_html(true)
	return data


## Copies every role into a new palette. RefCounted.duplicate() would share the
## same Dictionary, so Kits must use this instead.
func duplicate_palette() -> ProceduralPalette:
	var copy: ProceduralPalette = ProceduralPalette.new()
	for key: Variant in roles:
		copy.roles[StringName(key)] = roles[key]
	return copy


## Accepts both array form of to_dictionary() and html form of
## to_html_dictionary(). Unknown entries are skipped.
static func from_dictionary(data: Dictionary) -> ProceduralPalette:
	var palette: ProceduralPalette = ProceduralPalette.new()
	for key: Variant in data:
		var raw: Variant = data[key]
		if raw is Array:
			var parts: Array = raw
			if parts.size() < 3:
				continue
			var alpha: float = float(parts[3]) if parts.size() > 3 else 1.0
			palette.set_role(StringName(key), Color(float(parts[0]), float(parts[1]), float(parts[2]), alpha))
		elif raw is String:
			palette.set_role(StringName(key), Color(String(raw)))
	return palette
