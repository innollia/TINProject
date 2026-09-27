extends GutTest

const DT: float = 1 / 60.0

var _table: EcoRungTable
var _index: EcoContentIndex


func before_all() -> void:
	_table = EcoRungTable.make(EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)["value"])["value"]
	_index = EcoRegionLoader.load_all(_table)["value"]


func _find(object_name: String) -> Dictionary:
	for room_id: String in _index.all_room_ids():
		var room: EcoRoomSpec = _index.room(room_id)
		for t: Dictionary in room.triggers:
			if str(t["object"]) == object_name:
				return {"room": room, "trigger": t}
	return {}


func _world_at(object_name: String, rung: String) -> Dictionary:
	var found: Dictionary = _find(object_name)
	var w: EcoWorldState = EcoWorldState.new()
	w.body_rung = rung
	var r: Rect2 = EcoTransitionSystem.trigger_rect_px(found["trigger"])
	if object_name == "salt_bed" or object_name == "collapse_floor":
		w.position_px = Vector2(r.get_center().x, r.end.y - EcoBodyRung.TILE)
	else:
		w.position_px = r.get_center()
	w.on_ground = true
	return {"world": w, "room": found["room"], "id": str(found["trigger"]["id"])}


func _run(ts: EcoTransitionSystem, s: Dictionary, frames: int, frame: Dictionary) -> String:
	var done: String = ""
	for i: int in frames:
		done = ts.probe(s["world"], s["room"], frame, DT)
		if not done.is_empty():
			return done
	return done


func _store(owner: StringName = EcoWorldstateBridge.REQUESTER) -> WorldState:
	var store: WorldState = WorldState.new()
	store.declare_owner(&"body", owner)
	store.declare_owner(&"creature", owner)
	return store


func test_eco_salt_bed_five_seconds() -> void:
	var s: Dictionary = _world_at("salt_bed", "speck")
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	assert_eq(_run(ts, s, 299, {}), "", "4.98 s is not enough")
	assert_eq(ts.probe(s["world"], s["room"], {}, DT), s["id"], "5.0 s completes")
	var r: Dictionary = ts.commit(s["world"], s["room"], _table, null)
	assert_true(r["ok"])
	assert_eq((s["world"] as EcoWorldState).body_rung, "hand")
	assert_almost_eq(float((s["world"] as EcoWorldState).compressed_beds[s["id"]]), 0.20, 0.0001)
	var s2: Dictionary = _world_at("salt_bed", "speck")
	var ts2: EcoTransitionSystem = EcoTransitionSystem.new()
	_run(ts2, s2, 200, {})
	var back: Vector2 = (s2["world"] as EcoWorldState).position_px
	(s2["world"] as EcoWorldState).position_px = Vector2(-500, -500)
	ts2.probe(s2["world"], s2["room"], {}, DT)
	(s2["world"] as EcoWorldState).position_px = back
	assert_eq(_run(ts2, s2, 299, {}), "", "leaving resets to zero")


func test_eco_collapse_floor_three_landings() -> void:
	var s: Dictionary = _world_at("collapse_floor", "hand")
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	assert_eq(ts.probe(s["world"], s["room"], {"landed": true, "landing_speed": 421.0}, DT), "")
	assert_eq(ts.state.hits, 0, "421 does not count")
	ts.probe(s["world"], s["room"], {"landed": true, "landing_speed": 420.0}, DT)
	ts.probe(s["world"], s["room"], {"landed": true, "landing_speed": 300.0}, DT)
	assert_eq(ts.probe(s["world"], s["room"], {"landed": true, "landing_speed": 10.0}, DT), s["id"])
	ts.commit(s["world"], s["room"], _table, null)
	var w: EcoWorldState = s["world"]
	assert_eq(w.body_rung, "doll")
	assert_true(bool(w.trigger_flags.get(s["id"], false)))
	var col: EcoCollisionResolver = EcoCollisionResolver.new()
	col.setup(s["room"], w)
	var t: Dictionary = (s["room"] as EcoRoomSpec).trigger_by_id(s["id"])
	var c: Vector2i = t["cell"]
	var sp: Vector2i = t["span"]
	for x: int in range(c.x, c.x + sp.x):
		assert_eq(col.tile_kind(x, c.y + sp.y - 1), EcoTileKind.EMPTY, "consumed floor is empty space")


func test_eco_salt_dust_bed_eight_still_seconds() -> void:
	var s: Dictionary = _world_at("salt_dust_bed", "doll")
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	_run(ts, s, 400, {"any_input": false})
	ts.probe(s["world"], s["room"], {"any_input": true}, DT)
	assert_eq(ts.state.still_seconds, 0.0, "one input frame resets")
	assert_eq(_run(ts, s, 479, {"any_input": false}), "")
	assert_eq(ts.probe(s["world"], s["room"], {"any_input": false}, DT), s["id"])
	ts.commit(s["world"], s["room"], _table, null)
	assert_eq((s["world"] as EcoWorldState).body_rung, "hand")


func test_eco_narrow_cradle_needs_three_witnesses() -> void:
	var s: Dictionary = _world_at("narrow_cradle", "hand")
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	assert_eq(_run(ts, s, 900, {"witnesses": 2}), "", "two witnesses are not enough")
	var s2: Dictionary = _world_at("narrow_cradle", "hand")
	var ts2: EcoTransitionSystem = EcoTransitionSystem.new()
	assert_eq(_run(ts2, s2, 719, {"witnesses": 3}), "")
	assert_eq(ts2.probe(s2["world"], s2["room"], {"witnesses": 3}, DT), s2["id"])
	ts2.commit(s2["world"], s2["room"], _table, null)
	assert_eq((s2["world"] as EcoWorldState).body_rung, "speck")


func test_eco_toll_merge_max() -> void:
	var toll: Dictionary = EcoToll.for_step(1, 0)
	var empty: Array = []
	var merged: Array = EcoToll.merge_max(empty, toll)
	assert_eq(empty.size(), 0, "input unchanged")
	assert_eq(merged.size(), 1)
	var existing: Array = [{"part": "torso", "kind": "compressed", "severity": 0.9, "permanent": false}]
	var m2: Array = EcoToll.merge_max(existing, toll)
	assert_eq(m2.size(), 1)
	assert_almost_eq(float(m2[0]["severity"]), 0.9, 0.0001)
	assert_true(bool(m2[0]["permanent"]))
	assert_false(bool(existing[0]["permanent"]), "input unchanged")
	var low: Array = [{"part": "torso", "kind": "compressed", "severity": 0.1, "permanent": true}]
	assert_almost_eq(float(EcoToll.merge_max(low, toll)[0]["severity"]), 0.34, 0.0001)


func test_eco_transition_writes_wounds_then_scale() -> void:
	var s: Dictionary = _world_at("salt_bed", "speck")
	var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge.attach_world_store(_store())
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	_run(ts, s, 300, {})
	var r: Dictionary = ts.commit(s["world"], s["room"], _table, bridge)
	assert_true(r["ok"], str(r))
	assert_eq(bridge.requests.size(), 2)
	assert_eq((bridge.requests[0]["patch"] as Dictionary).keys(), ["wounds"])
	assert_eq((bridge.requests[1]["patch"] as Dictionary).keys(), ["scale"])
	assert_almost_eq(float(bridge.requests[1]["patch"]["scale"]), _table.ladder.value_of("hand"), 0.00001)


func test_eco_transition_failure_is_honest() -> void:
	var s: Dictionary = _world_at("salt_bed", "speck")
	var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge.attach_world_store(_store(&"someone_else"))
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	_run(ts, s, 300, {})
	var r: Dictionary = ts.commit(s["world"], s["room"], _table, bridge)
	assert_false(r["ok"])
	assert_eq(bridge.requests.size(), 1, "second request never sent")
	assert_eq((s["world"] as EcoWorldState).body_rung, "speck")
	var odd: EcoRungTable = EcoRungTable.make(EcoLadder.from_store_values([0.05, 0.13, 0.28, 0.65, 1.5, 3.6])["value"])["value"]
	var store: WorldState = _store()
	var bridge2: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge2.attach_world_store(store)
	var s2: Dictionary = _world_at("salt_bed", "speck")
	var ts2: EcoTransitionSystem = EcoTransitionSystem.new()
	_run(ts2, s2, 300, {})
	var r2: Dictionary = ts2.commit(s2["world"], s2["room"], odd, bridge2)
	assert_false(r2["ok"])
	assert_eq(bridge2.requests.size(), 2)
	assert_eq((s2["world"] as EcoWorldState).body_rung, "speck", "rung unchanged when scale is refused")
	var axis: EcoBodyAxis = bridge2.read_body()
	assert_eq(axis.wounds.size(), 1, "toll stays as a fact")
	assert_false(axis.has_scale)


func test_eco_transition_without_store_is_local() -> void:
	var s: Dictionary = _world_at("salt_bed", "speck")
	var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	_run(ts, s, 300, {})
	ts.commit(s["world"], s["room"], _table, bridge)
	assert_eq(bridge.requests.size(), 0)
	var w: EcoWorldState = s["world"]
	assert_eq(w.body_rung, "hand")
	assert_eq(w.local_wounds.size(), 1)
	assert_eq(str(w.local_wounds[0]["kind"]), "stretched")


func test_eco_death_resets_progress() -> void:
	var s: Dictionary = _world_at("narrow_cradle", "hand")
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	_run(ts, s, 300, {"witnesses": 3})
	assert_gt(ts.state.witness_frames, 0)
	ts.on_death()
	var fresh: EcoTransitionState = EcoTransitionState.new()
	for key: String in ["active", "from_rung", "to_rung", "trigger_kind", "trigger_id", "elapsed", "hits", "still_seconds", "witness_frames"]:
		assert_eq(ts.state.get(key), fresh.get(key), key)


func test_eco_trigger_has_one_direction() -> void:
	var s: Dictionary = _world_at("salt_bed", "hand")
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	assert_eq(_run(ts, s, 600, {}), "")
	assert_false(ts.state.active)
	var s2: Dictionary = _world_at("collapse_floor", "doll")
	var ts2: EcoTransitionSystem = EcoTransitionSystem.new()
	for i: int in 5:
		assert_eq(ts2.probe(s2["world"], s2["room"], {"landed": true, "landing_speed": 10.0}, DT), "")
	assert_false(ts2.state.active)
