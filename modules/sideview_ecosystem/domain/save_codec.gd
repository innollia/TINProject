class_name EcoSaveCodec
extends RefCounted

const SAVE_VERSION: int = 4
const REASON_SCHEMA: String = "schema_unsupported"
const REASON_NOT_DICTIONARY: String = "save_not_dictionary"
const SETTLE_CYCLE_SECONDS: float = 420.0
const SALT_BED_TRACE_MAX: float = 0.60


static func _v2(v: Vector2) -> Array:
	return [v.x, v.y]


static func _num(v: Variant, fallback: float) -> float:
	if (v is float or v is int) and is_finite(float(v)):
		return float(v)
	return fallback


static func _int(v: Variant, fallback: int) -> int:
	if (v is float or v is int) and is_finite(float(v)):
		return int(v)
	return fallback


static func _vec(v: Variant, fallback: Vector2) -> Vector2:
	if v is Array and (v as Array).size() == 2 and (v[0] is float or v[0] is int) and (v[1] is float or v[1] is int) and is_finite(float(v[0])) and is_finite(float(v[1])):
		return Vector2(float(v[0]), float(v[1]))
	return fallback


static func _strings(v: Variant) -> PackedStringArray:
	var out: PackedStringArray = []
	if v is Array:
		for s: Variant in v:
			if s is String:
				out.append(s)
	return out


static func _plain(v: Variant) -> Variant:
	if v is Dictionary:
		var d: Dictionary = {}
		for k: Variant in (v as Dictionary).keys():
			d[str(k)] = _plain((v as Dictionary)[k])
		return d
	if v is Array or v is PackedStringArray or v is PackedFloat32Array:
		var a: Array = []
		for x: Variant in v:
			a.append(_plain(x))
		return a
	if v is Vector2:
		return _v2(v)
	if v is float and not is_finite(v):
		return 0.0
	return v


static func encode(world: EcoWorldState, content_seed: int, world_seed: int) -> Dictionary:
	var creatures: Dictionary = {}
	for k: Variant in world.creatures.keys():
		creatures[str(k)] = _plain(world.creatures[k])
	return {
		"schema": SAVE_VERSION,
		"content_seed": content_seed,
		"world_seed": world_seed,
		"body_rung": world.body_rung,
		"integrity": world.integrity,
		"position_px": _v2(world.position_px),
		"velocity_px": _v2(world.velocity_px),
		"facing": world.facing,
		"t_settle": world.t_settle,
		"t_in_room": world.t_in_room,
		"current_room_id": world.current_room_id,
		"current_band": world.current_band,
		"previous_room_id": world.previous_room_id,
		"rooms_visited": Array(world.rooms_visited),
		"broken_walls": Array(world.broken_walls),
		"compressed_beds": _plain(world.compressed_beds),
		"drift_drops": _plain(world.drift_drops),
		"trigger_flags": _plain(world.trigger_flags),
		"local_wounds": _plain(world.local_wounds),
		"shelters_touched": Array(world.shelters_touched),
		"respawn_room": world.respawn_room,
		"respawn_pos_px": _v2(world.respawn_pos_px),
		"deaths": world.deaths,
		"sleeps": world.sleeps,
		"t_since_death": world.t_since_death,
		"dens": _plain(world.dens),
		"creatures": creatures,
	}


static func decode(data: Variant) -> Dictionary:
	if not data is Dictionary:
		return {"ok": false, "reason": REASON_NOT_DICTIONARY, "value": null}
	var d: Dictionary = data
	if not d.has("schema") or _int(d.get("schema"), -1) != SAVE_VERSION or float(_num(d.get("schema"), -1)) != float(SAVE_VERSION):
		return {"ok": false, "reason": REASON_SCHEMA, "value": null}
	var w: EcoWorldState = EcoWorldState.new()
	w.body_rung = str(d.get("body_rung", "")) if d.get("body_rung") is String else ""
	w.integrity = clampf(_num(d.get("integrity"), 1), 0.0, 1)
	w.position_px = _vec(d.get("position_px"), Vector2.ZERO)
	w.velocity_px = _vec(d.get("velocity_px"), Vector2.ZERO)
	w.facing = -1 if _int(d.get("facing"), 1) < 0 else 1
	w.t_settle = fposmod(_num(d.get("t_settle"), 0.0), SETTLE_CYCLE_SECONDS)
	w.t_in_room = maxf(0.0, _num(d.get("t_in_room"), 0.0))
	w.current_room_id = str(d.get("current_room_id", "")) if d.get("current_room_id") is String else ""
	w.current_band = str(d.get("current_band", w.current_band)) if d.get("current_band") is String else w.current_band
	w.previous_room_id = str(d.get("previous_room_id", "")) if d.get("previous_room_id") is String else ""
	w.rooms_visited = _strings(d.get("rooms_visited"))
	w.broken_walls = _strings(d.get("broken_walls"))
	w.shelters_touched = _strings(d.get("shelters_touched"))
	for key: String in ["compressed_beds", "drift_drops", "trigger_flags", "dens"]:
		var src: Variant = d.get(key, {})
		if src is Dictionary:
			w.set(key, (src as Dictionary).duplicate(true))
	for k: Variant in w.compressed_beds.keys():
		w.compressed_beds[k] = clampf(_num(w.compressed_beds[k], 0.0), 0.0, SALT_BED_TRACE_MAX)
	for k: Variant in w.drift_drops.keys():
		w.drift_drops[k] = clampi(_int(w.drift_drops[k], 0), 0, EcoGapClass.ORDER.size() - 1)
	var wounds: Variant = d.get("local_wounds", [])
	w.local_wounds = (wounds as Array).duplicate(true) if wounds is Array else []
	w.respawn_room = str(d.get("respawn_room", "")) if d.get("respawn_room") is String else ""
	w.respawn_pos_px = _vec(d.get("respawn_pos_px"), Vector2.ZERO)
	w.deaths = maxi(0, _int(d.get("deaths"), 0))
	w.sleeps = maxi(0, _int(d.get("sleeps"), 0))
	w.t_since_death = maxf(0.0, _num(d.get("t_since_death"), 0.0))
	var creatures: Variant = d.get("creatures", {})
	if creatures is Dictionary:
		for k: Variant in (creatures as Dictionary).keys():
			var c: Variant = creatures[k]
			if not c is Dictionary:
				continue
			var entry: Dictionary = (c as Dictionary).duplicate(true)
			var key: String = str(k)
			if entry.has("id") and (entry["id"] is float or entry["id"] is int):
				key = str(int(entry["id"]))
				entry["id"] = int(entry["id"])
			w.creatures[key] = entry
	for den_id: Variant in w.dens.keys():
		var den: Variant = w.dens[den_id]
		if not den is Dictionary:
			w.dens.erase(den_id)
			continue
		var cid: int = _int((den as Dictionary).get("creature_id"), -1)
		if cid >= 0 and not w.creatures.has(str(cid)):
			den["occupied"] = false
			den["creature_id"] = -1
	return {
		"ok": true, "reason": "", "value": w,
		"world_seed": _int(d.get("world_seed"), _int(d.get("content_seed"), 0)),
		"content_seed": _int(d.get("content_seed"), 0),
		"has_body_rung": d.get("body_rung") is String,
	}


static func is_json_safe(v: Variant) -> bool:
	if v is Dictionary:
		for k: Variant in (v as Dictionary).keys():
			if not k is String or not is_json_safe((v as Dictionary)[k]):
				return false
		return true
	if v is Array:
		for x: Variant in v:
			if not is_json_safe(x):
				return false
		return true
	if v is float:
		return is_finite(v)
	return v == null or v is bool or v is int or v is String
