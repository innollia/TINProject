class_name EcoPassageSpec
extends RefCounted

var id: String = ""
var kind: int = -1
var cell: Vector2i = Vector2i.ZERO
var span: Vector2i = Vector2i.ONE
var width_class: String = ""
var drift: bool = false
var height_px: float = 0.0
var fall_px: float = 0.0
var hp: int = 0
var mass_required: float = 0.0


static func from_dictionary(d: Dictionary, where: String) -> Dictionary:
	var kind_name: Variant = d.get("kind")
	var spec_kind: int = EcoPassageKind.from_name(kind_name) if kind_name is String else -1
	if spec_kind < 0:
		return _fail("passage_kind_unknown", "%s/%s" % [where, d.get("id", "?")])
	var allowed: Array[String] = EcoPassageKind.allowed_keys(spec_kind)
	for key: Variant in d.keys():
		if not allowed.has(str(key)):
			return _fail("key_unknown", "%s/%s.%s" % [where, d.get("id", "?"), key])
	var spec: EcoPassageSpec = EcoPassageSpec.new()
	var id_value: Variant = d.get("id")
	if not id_value is String or (id_value as String).is_empty():
		return _fail("value_invalid", "%s id" % where)
	spec.id = id_value
	spec.kind = spec_kind
	var label: String = "%s/%s" % [where, spec.id]
	var cell_value: Variant = _pair(d.get("cell"), 0)
	var span_value: Variant = _pair(d.get("span"), 1)
	if cell_value == null or span_value == null:
		return _fail("value_invalid", label + " cell/span")
	spec.cell = cell_value
	spec.span = span_value
	for key: Variant in EcoPassageKind.REQUIRED_KEYS[spec_kind]:
		if not d.has(key):
			return _fail("value_invalid", "%s missing %s" % [label, key])
	match spec_kind:
		EcoPassageKind.GAP:
			var wc: Variant = d.get("width_class")
			if not wc is String or not EcoGapClass.is_valid(wc):
				return _fail("value_invalid", label + " width_class")
			spec.width_class = wc
			var drift_value: Variant = d.get("drift", false)
			if not drift_value is bool:
				return _fail("value_invalid", label + " drift")
			spec.drift = drift_value
		EcoPassageKind.STEP:
			var h: Variant = d.get("height_px")
			if not _is_number(h) or not EcoPassageKind.is_class_value(EcoPassageKind.STEP_HEIGHTS, float(h)):
				return _fail("value_invalid", label + " height_px")
			spec.height_px = float(h)
		EcoPassageKind.DROP:
			var f: Variant = d.get("fall_px")
			if not _is_number(f) or not EcoPassageKind.is_class_value(EcoPassageKind.DROP_FALLS, float(f)):
				return _fail("value_invalid", label + " fall_px")
			spec.fall_px = float(f)
		EcoPassageKind.BREAK:
			var hp_value: Variant = d.get("hp")
			if not _is_whole(hp_value) or int(hp_value) < EcoPassageKind.BREAK_HP_MIN or int(hp_value) > EcoPassageKind.BREAK_HP_MAX:
				return _fail("value_invalid", label + " hp")
			spec.hp = int(hp_value)
		EcoPassageKind.PRESS:
			var m: Variant = d.get("mass_required")
			if not _is_number(m) or not EcoPassageKind.is_class_value(EcoPassageKind.PRESS_MASSES, float(m)):
				return _fail("value_invalid", label + " mass_required")
			spec.mass_required = float(m)
	return {"ok": true, "reason": "", "detail": "", "value": spec}


static func _fail(reason: String, detail: String) -> Dictionary:
	return {"ok": false, "reason": reason, "detail": detail, "value": null}


static func _is_number(v: Variant) -> bool:
	return (v is float or v is int) and is_finite(float(v))


static func _is_whole(v: Variant) -> bool:
	return _is_number(v) and float(v) == floorf(float(v))


static func _pair(v: Variant, minimum: int) -> Variant:
	if not v is Array or (v as Array).size() != 2:
		return null
	if not _is_whole(v[0]) or not _is_whole(v[1]):
		return null
	var p: Vector2i = Vector2i(int(v[0]), int(v[1]))
	if p.x < minimum or p.y < minimum:
		return null
	return p


func rect_tiles() -> Rect2i:
	return Rect2i(cell, span)


func rect_px() -> Rect2:
	return Rect2(Vector2(cell) * EcoBodyRung.TILE, Vector2(span) * EcoBodyRung.TILE)
