class_name StratumRuntime
extends RefCounted

const DEFAULT_REGROW_SECONDS: float = 0.4
const DEFAULT_HOLD_SECONDS: float = 0.5
const DEFAULT_ANCHOR_RADIUS: float = 12.0

var id: String = ""
var index: int = 0
var location: String = ""
var world_seed: int = 0
var palette: Dictionary = {}
var backdrop: Dictionary = {}
var bounds: Rect2 = Rect2(0.0, 0.0, 640.0, 1024.0)
var spawn_position: Vector2 = Vector2.ZERO
var spawn_facing: int = 1
var solids: Array[Dictionary] = []
var currents: Array[Dictionary] = []
var membranes: Array[Dictionary] = []
var routes: Array[Dictionary] = []
var sites: Array[Dictionary] = []
var matter: Array[Dictionary] = []
var anchors: Array[Dictionary] = []
var fauna: Array[Dictionary] = []
var warnings: Array[String] = []


static func build(data: Dictionary, state: DescentState = null, world: DescentWorldstateView = null) -> StratumRuntime:
	var runtime := StratumRuntime.new()
	runtime.id = String(data.get("id", ""))
	runtime.index = int(data.get("index", 0))
	runtime.location = String(data.get("location", ""))
	runtime.world_seed = int(data.get("world_seed", 0))
	runtime.palette = (data.get("palette", {}) as Dictionary).duplicate(true) if data.get("palette") is Dictionary else {}
	runtime.backdrop = (data.get("backdrop", {}) as Dictionary).duplicate(true) if data.get("backdrop") is Dictionary else {}
	var bounds_source: Dictionary = data.get("bounds", {}) if data.get("bounds") is Dictionary else {}
	runtime.bounds = Rect2(0.0, 0.0, float(bounds_source.get("width", 640)), float(bounds_source.get("height", 1024)))
	var spawn: Dictionary = data.get("spawn", {}) if data.get("spawn") is Dictionary else {}
	runtime.spawn_position = to_point(spawn.get("position"))
	runtime.spawn_facing = -1 if int(spawn.get("facing", 1)) < 0 else 1
	var carried_ids: Array[String] = []
	var consumed_ids: Array[String] = []
	if state != null:
		carried_ids = state.carried_ids()
		consumed_ids = state.consumed_matter_ids()
	for entry: Dictionary in _entries(data, "solids"):
		var kind: String = String(entry.get("kind", "wall"))
		runtime.solids.append({
			"id": String(entry.get("id", "")),
			"rect": to_rect(entry.get("rect")),
			"kind": kind,
			"regrow_seconds": float(entry.get("regrow_seconds", DEFAULT_REGROW_SECONDS)),
			"broken": false,
			"regrow_for": 0.0,
		})
	for entry: Dictionary in _entries(data, "currents"):
		runtime.currents.append({
			"id": String(entry.get("id", "")),
			"rect": to_rect(entry.get("rect")),
			"flow": to_point(entry.get("flow")),
			"stilled": false,
		})
	for entry: Dictionary in _entries(data, "membranes"):
		runtime.membranes.append({
			"id": String(entry.get("id", "")),
			"rect": to_rect(entry.get("rect")),
			"verb": String(entry.get("verb", "")),
			"hold_seconds": float(entry.get("hold_seconds", DEFAULT_HOLD_SECONDS)),
			"requires_body": (entry.get("requires_body", {}) as Dictionary).duplicate(true) if entry.get("requires_body") is Dictionary else {},
			"open": false,
			"progress": 0.0,
		})
	for entry: Dictionary in _entries(data, "routes"):
		var has_trigger: bool = entry.get("trigger") is Array
		var blocks: Array[String] = []
		if entry.get("blocks_verb") is Array:
			for value: Variant in entry["blocks_verb"] as Array:
				blocks.append(String(value))
		var requires: Array[Dictionary] = []
		if entry.get("requires") is Array:
			for value: Variant in entry["requires"] as Array:
				if value is Dictionary:
					requires.append((value as Dictionary).duplicate(true))
		runtime.routes.append({
			"id": String(entry.get("id", "")),
			"kind": String(entry.get("kind", "")),
			"trigger": to_rect(entry.get("trigger")) if has_trigger else Rect2(),
			"has_trigger": has_trigger,
			"requires": requires,
			"blocks_verb": blocks,
			"next": String(entry.get("next", "")),
			"open": false,
			"touching": false,
		})
	for entry: Dictionary in _entries(data, "sites"):
		runtime.sites.append({
			"id": String(entry.get("id", "")),
			"kind": String(entry.get("kind", "plaque")),
			"position": to_point(entry.get("position")),
			"radius": float(entry.get("radius", 14)),
			"grants_fact": String(entry.get("grants_fact", "")),
		})
	for entry: Dictionary in _entries(data, "matter"):
		var matter_id: String = String(entry.get("id", ""))
		var item: MatterItem = MatterItem.create(matter_id, int(entry.get("size", 1)), String(entry.get("verb", "weigh")), String(entry.get("tag", "")), runtime.id)
		runtime.matter.append({
			"id": matter_id,
			"position": to_point(entry.get("position")),
			"item": item,
			"present": not carried_ids.has(matter_id) and not consumed_ids.has(matter_id),
			"touching": false,
		})
	for entry: Dictionary in _entries(data, "anchors"):
		var anchor_id: String = String(entry.get("id", ""))
		var key: String = anchor_key(runtime.id, anchor_id)
		runtime.anchors.append({
			"id": anchor_id,
			"position": to_point(entry.get("position")),
			"radius": float(entry.get("radius", DEFAULT_ANCHOR_RADIUS)),
			"entered": state != null and state.anchors_taken.has(key),
		})
	for entry: Dictionary in _entries(data, "fauna"):
		runtime.fauna.append(runtime._build_fauna(entry, world))
	return runtime


static func anchor_key(stratum: String, anchor_id: String) -> String:
	return "%s#%s" % [stratum, anchor_id]


static func to_rect(source: Variant) -> Rect2:
	if not source is Array or (source as Array).size() != 4:
		return Rect2()
	var values: Array = source
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


static func to_point(source: Variant) -> Vector2:
	if not source is Array or (source as Array).size() != 2:
		return Vector2.ZERO
	var values: Array = source
	return Vector2(float(values[0]), float(values[1]))


static func _entries(data: Dictionary, key: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var source: Variant = data.get(key, [])
	if not source is Array:
		return out
	for entry: Variant in source as Array:
		if entry is Dictionary:
			out.append(entry as Dictionary)
	return out


func _build_fauna(entry: Dictionary, world: DescentWorldstateView) -> Dictionary:
	var kind: String = String(entry.get("kind", ""))
	var fauna_id: String = String(entry.get("id", ""))
	var home: Vector2 = to_point(entry.get("position"))
	var patrol: Vector2 = to_point(entry.get("patrol"))
	var low: float = minf(patrol.x, patrol.y)
	var high: float = maxf(patrol.x, patrol.y)
	var record: Dictionary = {
		"id": fauna_id,
		"kind": kind,
		"home": home,
		"position": home,
		"patrol": Vector2(low, high),
		"patrol_target": high,
		"line_y": float(entry.get("line_y", -1.0)),
		"has_line": entry.has("line_y"),
		"mode": "patrol" if kind == "grazer" else ("absent" if kind == "warden" else "none"),
		"active": kind == "grazer",
		"hostile": false,
		"remains": false,
	}
	var remains_at: Variant = entry.get("remains_at")
	if remains_at is Array and _remains_placed(fauna_id, world):
		record["position"] = to_point(remains_at)
		record["mode"] = "remains"
		record["active"] = false
		record["remains"] = true
	return record


func _remains_placed(fauna_id: String, world: DescentWorldstateView) -> bool:
	if world == null or not world.is_present():
		return false
	if not world.has_creature(fauna_id):
		warnings.append("descent: no creature record for %s in %s; no remains placed" % [fauna_id, id])
		return false
	if world.creature_state(fauna_id) != "dead":
		warnings.append("descent: creature %s is not in the dead state; no remains placed" % fauna_id)
		return false
	var den: Variant = world.creature_den(fauna_id)
	if not den is String:
		return false
	return world.place_region(den as String) == DescentWorldstateView.REGION_ID


func descent_routes() -> Array[Dictionary]:
	return _routes_of("descent")


func ending_routes() -> Array[Dictionary]:
	return _routes_of("ending")


func site_routes() -> Array[Dictionary]:
	return _routes_of("site_route")


func _routes_of(kind: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for route: Dictionary in routes:
		if route["kind"] == kind:
			out.append(route)
	return out


func next_stratum_id() -> String:
	for route: Dictionary in routes:
		if route["kind"] == "descent":
			return String(route["next"])
	return ""


func first_anchor() -> Dictionary:
	return anchors[0] if not anchors.is_empty() else {}


func find_anchor(anchor_id: String) -> Dictionary:
	for anchor: Dictionary in anchors:
		if anchor["id"] == anchor_id:
			return anchor
	return {}


func find_route(route_id: String) -> Dictionary:
	for route: Dictionary in routes:
		if route["id"] == route_id:
			return route
	return {}


func find_membrane(membrane_id: String) -> Dictionary:
	for membrane: Dictionary in membranes:
		if membrane["id"] == membrane_id:
			return membrane
	return {}


func find_current(current_id: String) -> Dictionary:
	for current: Dictionary in currents:
		if current["id"] == current_id:
			return current
	return {}


func find_fauna(fauna_id: String) -> Dictionary:
	for creature: Dictionary in fauna:
		if creature["id"] == fauna_id:
			return creature
	return {}


func blockers() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for solid: Dictionary in solids:
		if not bool(solid["broken"]):
			out.append(solid)
	for membrane: Dictionary in membranes:
		if not bool(membrane["open"]):
			out.append({"id": membrane["id"], "rect": membrane["rect"], "kind": "membrane"})
	return out


func check_exit(state: DescentState) -> Dictionary:
	var box: Rect2 = state.body_box()
	var result: Dictionary = {}
	for route: Dictionary in routes:
		if not bool(route["has_trigger"]):
			continue
		var touching: bool = box.intersects(route["trigger"] as Rect2)
		if touching and not bool(route["touching"]) and not bool(route["open"]):
			result["denied"] = true
		route["touching"] = touching
		if touching and bool(route["open"]) and not result.has("route"):
			result["route"] = route
	return result
