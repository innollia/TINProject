extends GutTest

var _table: EcoRungTable
var _index: EcoContentIndex


func before_all() -> void:
	var made: Dictionary = EcoRungTable.make(EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)["value"])
	_table = made["value"]
	var loaded: Dictionary = EcoRegionLoader.load_all(_table)
	_index = loaded["value"]


func _room(id: String, band: String, exit_side: String, shelter: bool) -> Dictionary:
	var rows: Array = []
	for y: int in 12:
		if y == 0 or y == 11:
			rows.append("################")
		elif exit_side == "right":
			rows.append("#...............")
		else:
			rows.append("...............#")
	var other: String = "dead_b" if id == "dead_a" else "dead_a"
	var d: Dictionary = {
		"id": id, "band": band, "target_body_px": 96.0, "place_id": "", "tiles": rows,
		"exits": [{"id": "x", "side": exit_side, "from": 9, "to": 10, "to_room": other, "to_exit": "x"}],
		"passages": [], "triggers": [], "shelters": [], "dens": [], "tethered": [],
	}
	if shelter:
		d["shelters"] = [{"id": "shelter_dead_a", "cell": [3, 10]}]
	return d


func _dead_end_texts() -> Dictionary:
	var texts: Dictionary = EcoRegionLoader.read_content_texts(EcoRegionLoader.CONTENT_ROOT)
	for k: String in texts.keys():
		if k.begins_with("regions/"):
			texts.erase(k)
	texts["regions/index.json"] = JSON.stringify({"schema": 1, "regions": ["reg_dead"], "start_room": "dead_a", "start_shelter": "shelter_dead_a", "start_rung": "speck"})
	texts["regions/reg_dead.json"] = JSON.stringify({
		"schema": 1, "id": "reg_dead", "display_name": "x",
		"rooms": [_room("dead_a", "speck", "right", true), _room("dead_b", "speck", "left", false)],
		"links": [{"from": "dead_a", "to": "dead_b", "via": ""}],
	})
	return texts


func test_eco_region_graph_fully_connected() -> void:
	assert_not_null(_index, "content loads")
	if _index == null:
		return
	var graph: EcoRegionGraph = EcoRegionGraph.build(_index, _table)
	assert_eq(graph.unreached_rooms().size(), 0, "G1 unreached: " + ", ".join(graph.unreached_rooms()))
	assert_eq(graph.dead_ends().size(), 0, "G2 dead ends: " + ", ".join(graph.dead_ends()))
	var salt_outside: int = 0
	for room_id: String in _index.all_room_ids():
		var room: EcoRoomSpec = _index.room(room_id)
		var bed_cells: Dictionary = {}
		for t: Dictionary in room.triggers:
			if str(t["object"]) == "salt_bed":
				var c: Vector2i = t["cell"]
				var s: Vector2i = t["span"]
				for x: int in range(c.x, c.x + s.x):
					bed_cells[Vector2i(x, c.y + s.y - 1)] = true
		for y: int in room.tiles_h:
			for x: int in room.tiles_w:
				if room.tile_at(x, y) == EcoTileKind.SALT and not bed_cells.has(Vector2i(x, y)):
					salt_outside += 1
	assert_eq(salt_outside, 0, "G3 salt outside beds")
	var counts: Dictionary = graph.direction_counts()
	for dir: String in ["speck>hand", "hand>doll", "doll>hand", "hand>speck"]:
		assert_gt(int(counts.get(dir, 0)), 0, "G4 direction " + dir)
	assert_gte(graph.object_count("collapse_floor"), 3, "G4 collapse floors")
	var ids: Dictionary = {}
	for d: Dictionary in graph.trigger_directions:
		assert_false(ids.has(d["id"]), "G4 one direction per trigger id")
		ids[d["id"]] = true
	assert_eq(graph.directions_without_new_path().size(), 0, "G5: " + ", ".join(graph.directions_without_new_path()))
	assert_true(graph.place_reached_in("place.tea_stair", ["doll"]), "G6 tea_stair reached as doll")
	assert_true(graph.place_reached_in("place.ruined_garden", ["speck", "hand", "doll"]), "G6 ruined_garden reached")
	assert_true(graph.place_reached_in("place.mirror_march", ["speck", "hand", "doll"]), "G6 mirror_march reached")


func test_eco_settle_never_gates_progress() -> void:
	if _index == null:
		fail_test("content did not load")
		return
	var drops: Dictionary = {}
	for room_id: String in _index.all_room_ids():
		for p: EcoPassageSpec in _index.room(room_id).passages:
			if p.kind == EcoPassageKind.GAP and p.drift:
				drops[p.id] = EcoGapClass.ORDER.size()
	assert_gt(drops.size(), 0, "authored content has drift gaps")
	var graph: EcoRegionGraph = EcoRegionGraph.build(_index, _table, drops)
	var shelter_rooms: PackedStringArray = []
	for room_id: String in _index.all_room_ids():
		if not _index.room(room_id).shelters.is_empty():
			shelter_rooms.append(room_id)
	assert_eq(shelter_rooms.size(), 4)
	var reached: PackedStringArray = graph.reached_rooms()
	for room_id: String in shelter_rooms:
		assert_true(reached.has(room_id), "G1 shelter room reached with settle fully applied: " + room_id)
	assert_eq(graph.unreached_rooms().size(), 0)
	assert_eq(graph.dead_ends().size(), 0, "G2 with settle fully applied")


func test_eco_graph_detects_dead_end() -> void:
	var result: Dictionary = EcoRegionLoader.load_from_texts(_dead_end_texts(), _table)
	assert_true(result["ok"], "fixture loads: " + ", ".join(result["errors"]))
	if not result["ok"]:
		return
	var graph: EcoRegionGraph = EcoRegionGraph.build(result["value"], _table)
	assert_eq(graph.unreached_rooms().size(), 0)
	assert_true(graph.dead_ends().has(EcoRegionGraph.key("dead_b", "speck")), "G2 is not vacuous")
