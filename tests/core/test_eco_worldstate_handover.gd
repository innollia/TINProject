extends GutTest

const DT: float = 1 / 60.0

var _table: EcoRungTable
var _index: EcoContentIndex


func before_all() -> void:
	_table = EcoRungTable.make(EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)["value"])["value"]
	_index = EcoRegionLoader.load_all(_table)["value"]


func _store(owner: StringName = EcoWorldstateBridge.REQUESTER) -> WorldState:
	var store: WorldState = WorldState.new()
	store.declare_owner(&"body", owner)
	store.declare_owner(&"creature", owner)
	return store


func _bridge(store: WorldState) -> EcoWorldstateBridge:
	var b: EcoWorldstateBridge = EcoWorldstateBridge.new()
	b.attach_world_store(store)
	return b


func test_eco_bridge_reads_body_axis_via_worldstateview() -> void:
	var store: WorldState = _store()
	store.request_mutation(&"body", {"scale": _table.ladder.value_of("hand")}, EcoWorldstateBridge.REQUESTER)
	var bridge: EcoWorldstateBridge = _bridge(store)
	var axis: EcoBodyAxis = bridge.read_body()
	assert_true(axis.has_scale)
	assert_almost_eq(axis.scale_value, _table.ladder.value_of("hand"), 0.00001)


func test_eco_bridge_declares_owner_body_and_creature() -> void:
	var store: WorldState = _store()
	var bridge: EcoWorldstateBridge = _bridge(store)
	var r1: Dictionary = bridge.write_scale(_table.ladder.value_of("speck"))
	assert_true(bool(r1.get("ok", false)))
	var axis: EcoCreatureAxis = EcoCreatureAxis.new()
	axis.id = "1"
	axis.archetype = "arc_anchor"
	var r2: Dictionary = bridge.write_creature(axis)
	assert_true(bool(r2.get("ok", false)), "declare_owner(&\"body\"/&\"creature\", REQUESTER) lets both axes accept writes")


func test_eco_save_service_begin_performs_steps_3_to_7_of_14_2() -> void:
	var store: WorldState = _store()
	var bridge: EcoWorldstateBridge = _bridge(store)
	var begun: Dictionary = EcoSaveService.begin(bridge, _index, _table, null)
	assert_true(begun["ok"])
	var world: EcoWorldState = begun["world"]
	assert_eq(world.current_room_id, _index.start_room)
	assert_eq(world.current_band, _index.room(_index.start_room).band)
	assert_eq(world.body_rung, _index.start_rung)
	assert_true(bool(begun["wrote_start_rung"]))


func test_eco_save_service_begin_follows_axis_when_axis_has_scale() -> void:
	var store: WorldState = _store()
	store.request_mutation(&"body", {"scale": _table.ladder.value_of("doll")}, EcoWorldstateBridge.REQUESTER)
	var bridge: EcoWorldstateBridge = _bridge(store)
	var begun: Dictionary = EcoSaveService.begin(bridge, _index, _table, null)
	assert_true(begun["ok"])
	assert_eq((begun["world"] as EcoWorldState).body_rung, "doll")
	assert_false(bool(begun["wrote_start_rung"]), "axis already had a scale — the Kit does not overwrite it")


func test_eco_save_service_begin_fails_honestly_on_foreign_rung() -> void:
	var store: WorldState = _store()
	store.request_mutation(&"body", {"scale": 0.65}, EcoWorldstateBridge.REQUESTER)
	var bridge: EcoWorldstateBridge = _bridge(store)
	var begun: Dictionary = EcoSaveService.begin(bridge, _index, _table, null)
	assert_false(begun["ok"])
	assert_eq(begun["reason"], EcoSaveService.REASON_AXIS_RUNG_FOREIGN)


func test_eco_narrow_cradle_transition_needs_720_probe_frames_then_commits() -> void:
	var room: EcoRoomSpec = null
	var trig: Dictionary = {}
	for room_id: String in _index.all_room_ids():
		var r: EcoRoomSpec = _index.room(room_id)
		for t: Dictionary in r.triggers:
			if str(t["object"]) == "narrow_cradle":
				room = r
				trig = t
	assert_false(trig.is_empty(), "content has a narrow_cradle trigger")
	var world: EcoWorldState = EcoWorldState.new()
	world.body_rung = "hand"
	var rect: Rect2 = EcoTransitionSystem.trigger_rect_px(trig)
	world.position_px = rect.get_center()
	world.on_ground = true
	var ts: EcoTransitionSystem = EcoTransitionSystem.new()
	var completed: String = ""
	for i: int in 720:
		completed = ts.probe(world, room, {"witnesses": 3}, DT)
	assert_eq(completed, str(trig["id"]), "720 frames with 3 witnesses completes narrow_cradle")
	var bridge: EcoWorldstateBridge = _bridge(_store())
	var r: Dictionary = ts.commit(world, room, _table, bridge)
	assert_true(r["ok"])
	assert_eq(world.body_rung, "speck")


func test_eco_body_roundtrips_through_the_store_across_a_room_visit() -> void:
	var store: WorldState = _store()
	var bridge: EcoWorldstateBridge = _bridge(store)
	var director: EcoStepDirector = EcoStepDirector.make(_index, _table, bridge)
	var begun: Dictionary = EcoSaveService.begin(bridge, _index, _table, null)
	assert_true(begun["ok"])
	director.start(begun["world"], _index.content_seed)
	for i: int in 30:
		director.step_frame({})
	var axis: EcoBodyAxis = bridge.read_body()
	assert_true(axis.has_scale)
	assert_almost_eq(axis.scale_value, _table.ladder.value_of(director.world.body_rung), 0.00001, "the axis still carries the rung after a room visit")


func test_eco_creature_axis_write_omits_den_key_for_dead_or_tethered() -> void:
	var alive_with_den: EcoCreatureAxis = EcoCreatureAxis.new()
	alive_with_den.id = "1"
	alive_with_den.den = "den_a_0"
	assert_true((alive_with_den.to_patch() as Dictionary).has("den"))
	var no_den: EcoCreatureAxis = EcoCreatureAxis.new()
	no_den.id = "2"
	no_den.den = ""
	assert_false((no_den.to_patch() as Dictionary).has("den"), "empty den is omitted from the patch, not written as an empty string (E-21)")
