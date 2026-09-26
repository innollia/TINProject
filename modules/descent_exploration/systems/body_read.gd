class_name BodyRead
extends RefCounted

const LIMB_PARTS: Array[String] = ["arm_left", "arm_right", "leg_left", "leg_right"]
const HAND_PARTS: Array[String] = ["hand_left", "hand_right"]
const HANDS_TOTAL: int = 2

var _body: Dictionary = {}


static func from_body(source: Variant) -> BodyRead:
	if not source is Dictionary:
		return null
	var read := BodyRead.new()
	read._body = (source as Dictionary).duplicate(true)
	return read


func has_missing_field() -> bool:
	return _body.get("missing") is Array


func limb_deficit() -> Variant:
	var missing: Variant = _body.get("missing")
	if not missing is Array:
		return null
	return _count(missing as Array, LIMB_PARTS)


func hands_free() -> Variant:
	var missing: Variant = _body.get("missing")
	if not missing is Array:
		return null
	return HANDS_TOTAL - _count(missing as Array, HAND_PARTS)


func has_missing_part(part: String) -> bool:
	var missing: Variant = _body.get("missing")
	if not missing is Array:
		return false
	for entry: Variant in missing as Array:
		if entry is String and entry == part:
			return true
	return false


func scale() -> Variant:
	var value: Variant = _body.get("scale")
	if value is int or value is float:
		return value
	return null


func has_wounds_field() -> bool:
	return _body.get("wounds") is Array


func wounds() -> Array:
	var source: Variant = _body.get("wounds")
	if not source is Array:
		return []
	var out: Array = []
	for entry: Variant in source as Array:
		if entry is Dictionary:
			out.append((entry as Dictionary).duplicate(true))
	return out


func has_wound(spec: Dictionary) -> bool:
	var wanted_part: Variant = spec.get("part")
	var wanted_kind: Variant = spec.get("kind")
	if not wanted_part is String or not wanted_kind is String:
		return false
	for wound: Variant in wounds():
		var record: Dictionary = wound
		if record.get("part") != wanted_part or record.get("kind") != wanted_kind:
			continue
		if spec.has("permanent") and record.get("permanent") != spec["permanent"]:
			continue
		if spec.has("severity_min"):
			var severity: Variant = record.get("severity")
			if not (severity is int or severity is float):
				continue
			if float(severity) < float(spec["severity_min"]):
				continue
		return true
	return false


static func _count(missing: Array, parts: Array[String]) -> int:
	var seen: Array[String] = []
	for entry: Variant in missing:
		if entry is String and parts.has(entry as String) and not seen.has(entry as String):
			seen.append(entry as String)
	return seen.size()
