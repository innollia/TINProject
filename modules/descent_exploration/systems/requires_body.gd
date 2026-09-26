class_name RequiresBodyGate
extends RefCounted

const KIT_KEYS: Array[String] = ["hands_min"]
const BODY_KEYS: Array[String] = ["scale_min", "scale_max", "has_all_parts", "has_wound", "has_no_wound"]


static func evaluate(requirement: Variant, body: BodyRead) -> Dictionary:
	var unmet: Array[String] = []
	if not requirement is Dictionary or (requirement as Dictionary).is_empty():
		return {"open": true, "reason": "no_requirement", "unmet": unmet}
	if body == null:
		return {"open": true, "reason": "body_absent", "unmet": unmet}
	var wanted: Dictionary = requirement
	for key: Variant in wanted:
		var name: String = String(key)
		var value: Variant = wanted[key]
		match name:
			"hands_min":
				var hands: Variant = body.hands_free()
				if hands == null:
					continue
				if not (value is int or value is float) or int(hands) < float(value):
					unmet.append("hands_min")
			"scale_min", "scale_max":
				var current: Variant = body.scale()
				if current == null:
					unmet.append("scale_absent")
				elif not (value is int or value is float):
					unmet.append(name)
				elif name == "scale_min" and float(current) < float(value):
					unmet.append("scale_below_min")
				elif name == "scale_max" and float(current) > float(value):
					unmet.append("scale_above_max")
			"has_all_parts":
				if not value is Array:
					unmet.append(name)
					continue
				for part: Variant in value as Array:
					if part is String and body.has_missing_part(part as String):
						unmet.append("part_missing:" + String(part))
			"has_wound":
				if not value is Dictionary:
					unmet.append(name)
				elif not body.has_wounds_field():
					unmet.append("wounds_absent")
				elif not body.has_wound(value as Dictionary):
					unmet.append("wound_missing")
			"has_no_wound":
				if not value is Dictionary:
					unmet.append(name)
				elif body.has_wound(value as Dictionary):
					unmet.append("wound_present")
			_:
				unmet.append("key_unknown:" + name)
	return {"open": unmet.is_empty(), "reason": "ok" if unmet.is_empty() else "unmet", "unmet": unmet}


static func is_open(requirement: Variant, body: BodyRead) -> bool:
	return bool(evaluate(requirement, body)["open"])
