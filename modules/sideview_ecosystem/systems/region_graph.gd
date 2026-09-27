class_name EcoRegionGraph
extends RefCounted

const SEP: String = "|"

var index: EcoContentIndex
var table: EcoRungTable
var edges: Dictionary = {}
var trigger_directions: Array[Dictionary] = []
var drift_drops: Dictionary = {}


static func build(p_index: EcoContentIndex, p_table: EcoRungTable, p_drift_drops: Dictionary = {}) -> EcoRegionGraph:
	var graph: EcoRegionGraph = EcoRegionGraph.new()
	graph.index = p_index
	graph.table = p_table
	graph.drift_drops = p_drift_drops
	graph._build()
	return graph


static func key(room_id: String, rung_name: String) -> String:
	return room_id + SEP + rung_name


static func room_of(state: String) -> String:
	return state.get_slice(SEP, 0)


static func rung_of(state: String) -> String:
	return state.get_slice(SEP, 1)


func _add(from_state: String, to_state: String, consume: bool) -> void:
	if not edges.has(from_state):
		edges[from_state] = []
	(edges[from_state] as Array).append({"to": to_state, "consume": consume})


func link_open(link: Dictionary, rung_name: String) -> bool:
	var via: String = str(link.get("via", ""))
	if via.is_empty():
		return true
	var owner_id: String = str(index.passage_room.get(via, ""))
	var owner_room: EcoRoomSpec = index.room(owner_id)
	var spec: EcoPassageSpec = index.passage(via)
	if owner_room == null or spec == null:
		return false
	if spec.kind == EcoPassageKind.GAP and spec.drift:
		return false
	var body: EcoBodyRung = table.by_name(rung_name)
	if spec.kind == EcoPassageKind.GAP and drift_drops.has(via):
		return EcoPassageResolver.gap_state(spec, body, table.band_value(owner_room.band), owner_room.target_body_px, int(drift_drops[via])) != EcoPassageResolver.GAP_BLOCK
	return EcoPassageResolver.passable(spec, body, table.band_value(owner_room.band), owner_room.target_body_px)


func _build() -> void:
	for link: Dictionary in index.links:
		for n: String in table.names():
			if link_open(link, n):
				_add(key(str(link["from"]), n), key(str(link["to"]), n), false)
	for room_id: String in index.all_room_ids():
		var room: EcoRoomSpec = index.room(room_id)
		for t: Dictionary in room.triggers:
			var object_name: String = str(t["object"])
			var from_rung: String = EcoTransitionRule.source_of(object_name)
			var to_rung: String = EcoTransitionRule.target_of(object_name)
			var consume: bool = EcoTransitionRule.kind_of(object_name) == EcoTransitionRule.KIND_CONSUME
			_add(key(room_id, from_rung), key(room_id, to_rung), consume)
			trigger_directions.append({"id": str(t["id"]), "object": object_name, "from": from_rung, "to": to_rung, "room": room_id})


func start_state() -> String:
	return key(index.start_room, index.start_rung)


func reach(from_state: String, use_consume: bool = true) -> Dictionary:
	var seen: Dictionary = {from_state: true}
	var queue: Array[String] = [from_state]
	while not queue.is_empty():
		var s: String = queue.pop_front()
		for e: Dictionary in edges.get(s, []):
			if not use_consume and bool(e["consume"]):
				continue
			var t: String = str(e["to"])
			if not seen.has(t):
				seen[t] = true
				queue.append(t)
	return seen


func reached_rooms(from_state: String = "") -> PackedStringArray:
	var origin: String = start_state() if from_state.is_empty() else from_state
	var rooms: PackedStringArray = []
	for s: String in reach(origin).keys():
		var r: String = room_of(s)
		if not rooms.has(r):
			rooms.append(r)
	return rooms


func unreached_rooms() -> PackedStringArray:
	var reached: PackedStringArray = reached_rooms()
	var missing: PackedStringArray = []
	for r: String in index.all_room_ids():
		if not reached.has(r):
			missing.append(r)
	return missing


func dead_ends() -> PackedStringArray:
	var origin: String = start_state()
	var out: PackedStringArray = []
	for s: String in reach(origin).keys():
		if not reach(s, false).has(origin):
			out.append(s)
	return out


func direction_counts() -> Dictionary:
	var counts: Dictionary = {}
	for d: Dictionary in trigger_directions:
		var k: String = str(d["from"]) + ">" + str(d["to"])
		counts[k] = int(counts.get(k, 0)) + 1
	return counts


func object_count(object_name: String) -> int:
	var n: int = 0
	for d: Dictionary in trigger_directions:
		if str(d["object"]) == object_name:
			n += 1
	return n


func directions_without_new_path() -> PackedStringArray:
	var missing: PackedStringArray = []
	var done: Dictionary = {}
	for d: Dictionary in trigger_directions:
		var a: String = str(d["from"])
		var b: String = str(d["to"])
		var k: String = a + ">" + b
		if done.has(k):
			continue
		done[k] = true
		var opens: bool = false
		for link: Dictionary in index.links:
			if str(link.get("via", "")).is_empty():
				continue
			if link_open(link, b) and not link_open(link, a):
				opens = true
				break
		if not opens:
			missing.append(k)
	return missing


func place_reached_in(place_id: String, allowed_rungs: Array) -> bool:
	var reached: Dictionary = reach(start_state())
	for room_id: String in index.all_room_ids():
		var room: EcoRoomSpec = index.room(room_id)
		if room.place_id != place_id:
			continue
		for n: Variant in allowed_rungs:
			if reached.has(key(room_id, str(n))):
				return true
	return false
