class_name DescentContentValidator
extends RefCounted

const PROBE_LAYER_EXEMPT_IDS: PackedStringArray = PackedStringArray(["stratum_extra_probe"])
const SCHEMA: int = 1
const WIDTH: float = 640.0
const HEIGHT: float = 1024.0
const SEED_MAX: int = 2147483647
const TOP_KEYS: Array[String] = ["schema", "id", "index", "location", "display_name", "world_seed", "palette", "bounds", "spawn", "solids", "currents", "membranes", "routes", "sites", "matter", "anchors", "fauna", "backdrop"]
const ARRAY_KEYS: Array[String] = ["solids", "currents", "membranes", "routes", "sites", "matter", "anchors", "fauna"]
const LOCAL_ID_KEYS: Array[String] = ["solids", "matter", "anchors", "fauna", "sites", "currents", "membranes"]
const SOLID_KINDS: Array[String] = ["ground", "wall", "brittle"]
const ROUTE_KINDS: Array[String] = ["descent", "site_route", "ending"]
const SITE_KINDS: Array[String] = ["plaque"]
const FAUNA_KINDS: Array[String] = ["grazer", "warden", "remains"]
const MEMBRANE_VERBS: Array[String] = ["plug", "feed", "strike"]
const ENDING_MOUTHS: Array[String] = ["mouth.still", "mouth.above", "mouth.heart"]
const DEFORM_LAYERS: int = 5
const PALETTE_SCHEMES: Array[String] = ["analogous", "complementary", "split_complementary", "triadic", "tetradic"]


static func validate(data: Variant, file_id: String, context: Dictionary = {}) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	if not data is Dictionary:
		_fail(errors, 0, file_id, "root", "a stratum must be a JSON object")
		return errors
	var layer: Dictionary = data
	for key: String in TOP_KEYS:
		if not layer.has(key):
			_fail(errors, 0, file_id, key, "missing top-level key")
	if not errors.is_empty():
		return errors
	for key: String in ARRAY_KEYS:
		if not layer[key] is Array:
			_fail(errors, 0, file_id, key, "must be an array")
	for key: String in ["palette", "bounds", "spawn", "backdrop"]:
		if not layer[key] is Dictionary:
			_fail(errors, 0, file_id, key, "must be an object")
	if not errors.is_empty():
		return errors
	_rule_schema(layer, file_id, errors)
	_rule_structure(layer, file_id, errors)
	_rule_coordinates(layer, file_id, errors)
	_rule_unique_ids(layer, file_id, errors)
	_rule_descent(layer, file_id, context, errors)
	if not PROBE_LAYER_EXEMPT_IDS.has(file_id):
		_rule_endings(layer, file_id, errors)
	_rule_requires(layer, file_id, context, errors)
	_rule_clearance_alternative(layer, file_id, errors)
	_rule_fauna_lines(layer, file_id, errors)
	_rule_membrane_triggers(layer, file_id, errors)
	return errors


static func failed_rules(errors: Array[Dictionary]) -> Array[int]:
	var rules: Array[int] = []
	for error: Dictionary in errors:
		var rule: int = int(error.get("rule", -1))
		if not rules.has(rule):
			rules.append(rule)
	rules.sort()
	return rules


static func _rule_schema(layer: Dictionary, file_id: String, errors: Array[Dictionary]) -> void:
	if not _is_int(layer["schema"]) or int(layer["schema"]) != SCHEMA:
		_fail(errors, 1, file_id, "schema", "must be 1")
	var id_value: Variant = layer["id"]
	var pattern := RegEx.create_from_string("^stratum_[a-z_]+$")
	if not id_value is String or String(id_value) != file_id or pattern.search(String(id_value)) == null:
		_fail(errors, 2, file_id, "id", "must match the file name and ^stratum_[a-z_]+$")
	if not _is_int(layer["index"]) or int(layer["index"]) < 0:
		_fail(errors, 3, file_id, "index", "must be an integer >= 0")
	var bounds: Dictionary = layer["bounds"]
	if not _is_number(bounds.get("width")) or float(bounds.get("width")) != WIDTH or not _is_number(bounds.get("height")) or float(bounds.get("height")) != HEIGHT:
		_fail(errors, 4, file_id, "bounds", "must be 640 x 1024")


static func _rule_structure(layer: Dictionary, file_id: String, errors: Array[Dictionary]) -> void:
	if not layer["location"] is String or not String(layer["location"]).begins_with("loc."):
		_fail(errors, 0, file_id, "location", "must be a loc.* id")
	if not layer["display_name"] is String or String(layer["display_name"]).strip_edges().is_empty():
		_fail(errors, 0, file_id, "display_name", "must be a non-empty string")
	if not _is_int(layer["world_seed"]) or int(layer["world_seed"]) < 0 or int(layer["world_seed"]) > SEED_MAX:
		_fail(errors, 0, file_id, "world_seed", "must be an integer in 0..2147483647")
	var palette: Dictionary = layer["palette"]
	if not PALETTE_SCHEMES.has(String(palette.get("scheme", ""))):
		_fail(errors, 0, file_id, "palette.scheme", "must name one of the five palette schemes")
	if not _in_range(palette.get("base_hue"), 0.0, 1.0) or not _in_range(palette.get("saturation"), 0.0, 1.0):
		_fail(errors, 0, file_id, "palette", "base_hue and saturation must be in 0..1")
	if not _in_range(palette.get("contrast"), 0.2, 2.0):
		_fail(errors, 0, file_id, "palette.contrast", "must be in 0.2..2.0")
	if not _is_int(palette.get("variant")) or int(palette.get("variant")) < 0 or int(palette.get("variant")) > 15:
		_fail(errors, 0, file_id, "palette.variant", "must be an integer in 0..15")
	var spawn: Dictionary = layer["spawn"]
	if not _is_point(spawn.get("position")):
		_fail(errors, 0, file_id, "spawn.position", "must be [x, y]")
	if not _is_int(spawn.get("facing")) or absi(int(spawn.get("facing"))) != 1:
		_fail(errors, 0, file_id, "spawn.facing", "must be 1 or -1")
	for entry: Variant in layer["solids"]:
		var solid: Dictionary = _entry(entry, errors, file_id, "solids")
		if solid.is_empty():
			continue
		if not _is_rect(solid.get("rect")):
			_fail(errors, 0, file_id, "solids.rect", "must be [x, y, w, h] with w, h > 0")
		if not SOLID_KINDS.has(String(solid.get("kind", ""))):
			_fail(errors, 0, file_id, "solids.kind", "must be ground, wall or brittle")
		if solid.has("regrow_seconds") and (solid.get("kind") != "brittle" or not _is_number(solid["regrow_seconds"]) or float(solid["regrow_seconds"]) <= 0.0):
			_fail(errors, 0, file_id, "solids.regrow_seconds", "only brittle solids regrow, and the time must be positive")
	for entry: Variant in layer["currents"]:
		var current: Dictionary = _entry(entry, errors, file_id, "currents")
		if current.is_empty():
			continue
		if not _is_rect(current.get("rect")):
			_fail(errors, 0, file_id, "currents.rect", "must be [x, y, w, h] with w, h > 0")
		if not _is_point(current.get("flow")) or (float(current["flow"][0]) == 0.0 and float(current["flow"][1]) == 0.0):
			_fail(errors, 0, file_id, "currents.flow", "must be [fx, fy] and not both zero")
	for entry: Variant in layer["membranes"]:
		var membrane: Dictionary = _entry(entry, errors, file_id, "membranes")
		if membrane.is_empty():
			continue
		if not _is_rect(membrane.get("rect")):
			_fail(errors, 0, file_id, "membranes.rect", "must be [x, y, w, h] with w, h > 0")
		if not MEMBRANE_VERBS.has(String(membrane.get("verb", ""))):
			_fail(errors, 0, file_id, "membranes.verb", "must be plug, feed or strike")
		if membrane.has("hold_seconds") and (not _is_number(membrane["hold_seconds"]) or float(membrane["hold_seconds"]) <= 0.0):
			_fail(errors, 0, file_id, "membranes.hold_seconds", "must be positive")
		if membrane.has("requires_body"):
			if not membrane["requires_body"] is Dictionary:
				_fail(errors, 0, file_id, "membranes.requires_body", "must be an object")
			else:
				for key: Variant in membrane["requires_body"] as Dictionary:
					if not RequiresBodyGate.KIT_KEYS.has(String(key)) and not RequiresBodyGate.BODY_KEYS.has(String(key)):
						_fail(errors, 0, file_id, "membranes.requires_body", "unknown capability key " + String(key))
	for entry: Variant in layer["routes"]:
		var route: Dictionary = _entry(entry, errors, file_id, "routes")
		if route.is_empty():
			continue
		var kind: String = String(route.get("kind", ""))
		var route_id: String = String(route.get("id", ""))
		if not ROUTE_KINDS.has(kind):
			_fail(errors, 0, file_id, "routes.kind", "must be descent, site_route or ending")
		if kind == "descent" and not route_id.begins_with("exit_"):
			_fail(errors, 0, file_id, "routes.id", "a descent route id starts with exit_")
		if kind == "ending" and not route_id.begins_with("mouth."):
			_fail(errors, 0, file_id, "routes.id", "an ending route id starts with mouth.")
		if kind in ["descent", "ending"] and not _is_rect(route.get("trigger")):
			_fail(errors, 0, file_id, "routes.trigger", "descent and ending routes need a trigger")
		if kind == "descent" and not route.get("next") is String:
			_fail(errors, 0, file_id, "routes.next", "a descent route names its next stratum or an empty string")
		if kind == "ending" and not DescentState.ENDING_IDS.has(String(route.get("next", ""))):
			_fail(errors, 0, file_id, "routes.next", "an ending route names one of the three endings")
	for entry: Variant in layer["sites"]:
		var site: Dictionary = _entry(entry, errors, file_id, "sites")
		if site.is_empty():
			continue
		if not SITE_KINDS.has(String(site.get("kind", ""))):
			_fail(errors, 0, file_id, "sites.kind", "must be plaque")
		if not _is_point(site.get("position")):
			_fail(errors, 0, file_id, "sites.position", "must be [x, y]")
		if not _is_number(site.get("radius")) or float(site.get("radius")) <= 0.0:
			_fail(errors, 0, file_id, "sites.radius", "must be positive")
		if not site.get("grants_fact") is String:
			_fail(errors, 0, file_id, "sites.grants_fact", "must be a string")
	for entry: Variant in layer["matter"]:
		var matter: Dictionary = _entry(entry, errors, file_id, "matter")
		if matter.is_empty():
			continue
		if not _is_point(matter.get("position")):
			_fail(errors, 0, file_id, "matter.position", "must be [x, y]")
		if not MatterItem.is_valid_dictionary(matter):
			_fail(errors, 0, file_id, "matter", "size 1..3, verb plug/feed/strike/weigh, non-empty tag")
	for entry: Variant in layer["anchors"]:
		var anchor: Dictionary = _entry(entry, errors, file_id, "anchors")
		if anchor.is_empty():
			continue
		if not _is_point(anchor.get("position")):
			_fail(errors, 0, file_id, "anchors.position", "must be [x, y]")
		if anchor.has("radius") and (not _is_number(anchor["radius"]) or float(anchor["radius"]) <= 0.0):
			_fail(errors, 0, file_id, "anchors.radius", "must be positive")
	for entry: Variant in layer["fauna"]:
		var creature: Dictionary = _entry(entry, errors, file_id, "fauna")
		if creature.is_empty():
			continue
		var kind: String = String(creature.get("kind", ""))
		if not FAUNA_KINDS.has(kind):
			_fail(errors, 0, file_id, "fauna.kind", "must be grazer, warden or remains")
		if kind in ["grazer", "warden"]:
			if not _is_point(creature.get("position")):
				_fail(errors, 0, file_id, "fauna.position", "must be [x, y]")
			if not _is_point(creature.get("patrol")):
				_fail(errors, 0, file_id, "fauna.patrol", "must be [y0, y1]")
		if creature.has("remains_at") and not _is_point(creature["remains_at"]):
			_fail(errors, 0, file_id, "fauna.remains_at", "must be [x, y]")
	var backdrop: Dictionary = layer["backdrop"]
	if not _is_point(backdrop.get("wind")):
		_fail(errors, 0, file_id, "backdrop.wind", "must be [x, y]")
	var grid: Variant = backdrop.get("deform_grid")
	var grid_ok: bool = grid is Array and (grid as Array).size() == DEFORM_LAYERS
	if grid_ok:
		for cell: Variant in grid as Array:
			if not _is_point(cell) or not _is_int(cell[0]) or not _is_int(cell[1]) or int(cell[0]) < 2 or int(cell[1]) < 2:
				grid_ok = false
	if not grid_ok:
		_fail(errors, 0, file_id, "backdrop.deform_grid", "must be five [w, h] integer pairs, each at least 2")
	var known: Array[String] = _all_ids(layer)
	var pulse: Variant = backdrop.get("pulse_on", [])
	if not pulse is Array:
		_fail(errors, 0, file_id, "backdrop.pulse_on", "must be an array of ids")
	else:
		for value: Variant in pulse as Array:
			if not value is String or not known.has(String(value)):
				_fail(errors, 0, file_id, "backdrop.pulse_on", "names an id this stratum does not have: " + str(value))


static func _rule_coordinates(layer: Dictionary, file_id: String, errors: Array[Dictionary]) -> void:
	var outside: Array[String] = []
	for key: String in ["solids", "currents", "membranes"]:
		for entry: Variant in layer[key]:
			if entry is Dictionary and _is_rect((entry as Dictionary).get("rect")) and not _rect_inside((entry as Dictionary)["rect"]):
				outside.append("%s.%s" % [key, String((entry as Dictionary).get("id", "?"))])
	for entry: Variant in layer["routes"]:
		if entry is Dictionary and _is_rect((entry as Dictionary).get("trigger")) and not _rect_inside((entry as Dictionary)["trigger"]):
			outside.append("routes.%s" % String((entry as Dictionary).get("id", "?")))
	var spawn: Dictionary = layer["spawn"]
	if _is_point(spawn.get("position")) and not _point_inside(spawn["position"]):
		outside.append("spawn")
	for key: String in ["sites", "matter", "anchors", "fauna"]:
		for entry: Variant in layer[key]:
			if not entry is Dictionary:
				continue
			var item: Dictionary = entry
			if _is_point(item.get("position")) and not _point_inside(item["position"]):
				outside.append("%s.%s" % [key, String(item.get("id", "?"))])
			if _is_point(item.get("remains_at")) and not _point_inside(item["remains_at"]):
				outside.append("%s.%s.remains_at" % [key, String(item.get("id", "?"))])
			if key == "fauna" and _is_point(item.get("patrol")):
				for value: Variant in item["patrol"] as Array:
					if float(value) < 0.0 or float(value) > HEIGHT:
						outside.append("fauna.%s.patrol" % String(item.get("id", "?")))
			if key == "fauna" and item.has("line_y") and (not _is_number(item["line_y"]) or float(item["line_y"]) < 0.0 or float(item["line_y"]) > HEIGHT):
				outside.append("fauna.%s.line_y" % String(item.get("id", "?")))
	for label: String in outside:
		_fail(errors, 5, file_id, label, "lies outside [0, 640] x [0, 1024]")


static func _rule_unique_ids(layer: Dictionary, file_id: String, errors: Array[Dictionary]) -> void:
	var seen: Array[String] = []
	for key: String in LOCAL_ID_KEYS:
		for entry: Variant in layer[key]:
			if not entry is Dictionary:
				continue
			var entry_id: String = String((entry as Dictionary).get("id", ""))
			if seen.has(entry_id):
				_fail(errors, 6, file_id, key, "duplicate id " + entry_id)
			else:
				seen.append(entry_id)
	var routes_seen: Array[String] = []
	for entry: Variant in layer["routes"]:
		if not entry is Dictionary:
			continue
		var route_id: String = String((entry as Dictionary).get("id", ""))
		if routes_seen.has(route_id) or seen.has(route_id):
			_fail(errors, 6, file_id, "routes", "duplicate id " + route_id)
		else:
			routes_seen.append(route_id)


static func _rule_descent(layer: Dictionary, file_id: String, context: Dictionary, errors: Array[Dictionary]) -> void:
	var descents: Array[Dictionary] = _routes(layer, "descent")
	if descents.is_empty():
		_fail(errors, 7, file_id, "routes", "needs at least one descent route")
		return
	var next: String = String(descents[0].get("next", ""))
	for route: Dictionary in descents:
		if String(route.get("next", "")) != next:
			_fail(errors, 7, file_id, "routes", "every descent route of one stratum leads to the same next stratum")
	var known: Variant = context.get("strata")
	if known is Array and not next.is_empty() and not (known as Array).has(next):
		_fail(errors, 8, file_id, "routes.next", "names a stratum that is not authored: " + next)


static func _rule_endings(layer: Dictionary, file_id: String, errors: Array[Dictionary]) -> void:
	var descents: Array[Dictionary] = _routes(layer, "descent")
	var terminal: bool = not descents.is_empty() and String(descents[0].get("next", "")).is_empty()
	var endings: Array[Dictionary] = _routes(layer, "ending")
	if not terminal:
		if not endings.is_empty():
			_fail(errors, 9, file_id, "routes", "only the last stratum carries ending routes")
		return
	var ids: Array[String] = []
	for route: Dictionary in endings:
		ids.append(String(route.get("id", "")))
	ids.sort()
	var wanted: Array[String] = ENDING_MOUTHS.duplicate()
	wanted.sort()
	if ids != wanted:
		_fail(errors, 9, file_id, "routes", "the last stratum carries exactly mouth.still, mouth.above and mouth.heart")


static func _rule_requires(layer: Dictionary, file_id: String, context: Dictionary, errors: Array[Dictionary]) -> void:
	var facts: Variant = context.get("facts")
	var sites: Variant = context.get("sites")
	for entry: Variant in layer["routes"]:
		if not entry is Dictionary:
			continue
		var route: Dictionary = entry
		var kind: String = String(route.get("kind", ""))
		var route_id: String = String(route.get("id", "?"))
		var requires: Variant = route.get("requires")
		if not requires is Array or (requires as Array).is_empty():
			_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "must be a non-empty array")
			continue
		for requirement: Variant in requires as Array:
			if not requirement is Dictionary:
				_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "each entry is an object")
				continue
			var item: Dictionary = requirement
			var requirement_kind: String = String(item.get("kind", ""))
			match requirement_kind:
				"always":
					pass
				"fact":
					var fact: Variant = item.get("fact")
					if not fact is String or String(fact).is_empty():
						_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "fact needs a fact id")
					elif facts is Array and not (facts as Array).has(fact):
						_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "no earlier stratum grants the fact " + String(fact))
				"clearance":
					if kind == "ending":
						_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "an ending never opens on mass")
					elif not _is_int(item.get("mass")) or int(item.get("mass")) < 1 or int(item.get("mass")) > DescentState.MAX_CARRY_MASS:
						_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "clearance mass is 1..4")
				"carrying":
					if not MatterItem.VERBS.has(String(item.get("verb", ""))) or String(item.get("verb", "")) == "weigh":
						_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "carrying names plug, feed or strike")
				"opened":
					var site_id: Variant = item.get("site_id")
					if not site_id is String or String(site_id).is_empty():
						_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "opened needs a site id")
					elif sites is Array and not (sites as Array).has(site_id):
						_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "no earlier stratum has the site " + String(site_id))
				_:
					_fail(errors, 10, file_id, "routes.%s.requires" % route_id, "unknown requirement kind " + requirement_kind)
		if route.has("blocks_verb"):
			var blocks: Variant = route["blocks_verb"]
			if kind != "ending" or not blocks is Array:
				_fail(errors, 10, file_id, "routes.%s.blocks_verb" % route_id, "only ending routes block, with an array of verbs")
			else:
				for verb: Variant in blocks as Array:
					if not MatterItem.VERBS.has(String(verb)):
						_fail(errors, 10, file_id, "routes.%s.blocks_verb" % route_id, "unknown verb " + str(verb))


static func _rule_clearance_alternative(layer: Dictionary, file_id: String, errors: Array[Dictionary]) -> void:
	var descents: Array[Dictionary] = _routes(layer, "descent")
	var uses_clearance: bool = false
	var alternatives: int = 0
	for route: Dictionary in descents:
		var requires: Variant = route.get("requires", [])
		if not requires is Array:
			continue
		var has_other: bool = false
		for requirement: Variant in requires as Array:
			if not requirement is Dictionary:
				continue
			if String((requirement as Dictionary).get("kind", "")) == "clearance":
				uses_clearance = true
			else:
				has_other = true
		if has_other:
			alternatives += 1
	if uses_clearance and alternatives == 0:
		_fail(errors, 11, file_id, "routes", "a clearance descent needs a descent route that opens without mass")


static func _rule_fauna_lines(layer: Dictionary, file_id: String, errors: Array[Dictionary]) -> void:
	for entry: Variant in layer["fauna"]:
		if not entry is Dictionary:
			continue
		var creature: Dictionary = entry
		var kind: String = String(creature.get("kind", ""))
		var creature_id: String = String(creature.get("id", "?"))
		if kind == "warden" and not _is_number(creature.get("line_y")):
			_fail(errors, 12, file_id, "fauna.%s" % creature_id, "a warden needs line_y")
		if kind == "grazer" and creature.has("line_y"):
			_fail(errors, 12, file_id, "fauna.%s" % creature_id, "a grazer has no line_y")
		if kind == "remains" and not _is_point(creature.get("remains_at")):
			_fail(errors, 12, file_id, "fauna.%s" % creature_id, "a remains entry needs remains_at")


static func _rule_membrane_triggers(layer: Dictionary, file_id: String, errors: Array[Dictionary]) -> void:
	var triggers: Array[Rect2] = []
	for entry: Variant in layer["routes"]:
		if entry is Dictionary and String((entry as Dictionary).get("kind", "")) in ["descent", "ending"] and _is_rect((entry as Dictionary).get("trigger")):
			triggers.append(StratumRuntime.to_rect((entry as Dictionary)["trigger"]))
	for entry: Variant in layer["membranes"]:
		if not entry is Dictionary or not _is_rect((entry as Dictionary).get("rect")):
			continue
		var rect: Rect2 = StratumRuntime.to_rect((entry as Dictionary)["rect"])
		for trigger: Rect2 in triggers:
			if rect.intersects(trigger):
				_fail(errors, 13, file_id, "membranes.%s" % String((entry as Dictionary).get("id", "?")), "overlaps a descent or ending trigger")


static func _routes(layer: Dictionary, kind: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry: Variant in layer["routes"]:
		if entry is Dictionary and String((entry as Dictionary).get("kind", "")) == kind:
			out.append(entry as Dictionary)
	return out


static func _all_ids(layer: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for key: String in ARRAY_KEYS:
		var source: Variant = layer.get(key, [])
		if not source is Array:
			continue
		for entry: Variant in source as Array:
			if entry is Dictionary and (entry as Dictionary).get("id") is String:
				ids.append(String((entry as Dictionary)["id"]))
	return ids


static func _entry(entry: Variant, errors: Array[Dictionary], file_id: String, key: String) -> Dictionary:
	if not entry is Dictionary:
		_fail(errors, 0, file_id, key, "each entry is an object")
		return {}
	var item: Dictionary = entry
	if not item.get("id") is String or String(item.get("id")).is_empty():
		_fail(errors, 0, file_id, key, "each entry needs a non-empty id")
		return {}
	return item


static func _fail(errors: Array[Dictionary], rule: int, file_id: String, key: String, message: String) -> void:
	errors.append({"rule": rule, "stratum": file_id, "key": key, "message": "R%d %s.%s: %s" % [rule, file_id, key, message]})


static func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


static func _is_int(value: Variant) -> bool:
	return _is_number(value) and float(value) == floorf(float(value))


static func _in_range(value: Variant, low: float, high: float) -> bool:
	return _is_number(value) and float(value) >= low and float(value) <= high


static func _is_point(value: Variant) -> bool:
	return value is Array and (value as Array).size() == 2 and _is_number((value as Array)[0]) and _is_number((value as Array)[1])


static func _is_rect(value: Variant) -> bool:
	if not value is Array or (value as Array).size() != 4:
		return false
	for part: Variant in value as Array:
		if not _is_number(part):
			return false
	return float((value as Array)[2]) > 0.0 and float((value as Array)[3]) > 0.0


static func _rect_inside(value: Variant) -> bool:
	var values: Array = value
	return float(values[0]) >= 0.0 and float(values[1]) >= 0.0 and float(values[0]) + float(values[2]) <= WIDTH and float(values[1]) + float(values[3]) <= HEIGHT


static func _point_inside(value: Variant) -> bool:
	var values: Array = value
	return float(values[0]) >= 0.0 and float(values[0]) <= WIDTH and float(values[1]) >= 0.0 and float(values[1]) <= HEIGHT
