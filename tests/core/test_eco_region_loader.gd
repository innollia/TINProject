extends GutTest

var _table: EcoRungTable


func before_all() -> void:
	var loaded: Dictionary = EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)
	assert_true(loaded["ok"])
	var made: Dictionary = EcoRungTable.make(loaded["value"])
	assert_true(made["ok"])
	_table = made["value"]


func test_eco_authored_content_loads_clean() -> void:
	var result: Dictionary = EcoRegionLoader.load_all(_table)
	assert_true(result["ok"], "authored content loads: " + ", ".join(result["errors"]))
	assert_eq((result["errors"] as PackedStringArray).size(), 0, ", ".join(result["errors"]))
	var index: EcoContentIndex = result["value"]
	if index == null:
		return
	assert_eq(index.regions.size(), 4)
	assert_eq(index.room_count(), 25)
	assert_eq(index.archetypes.size(), 5)
	assert_eq(index.start_room, "filter_bed_00")
	assert_eq(index.start_rung, "speck")


func _fixture_room(id: String, exit_side: String, other: String) -> Dictionary:
	var rows: Array = []
	for y: int in 12:
		if y == 0 or y == 11:
			rows.append("################")
		elif exit_side == "right":
			rows.append("#...............")
		else:
			rows.append("...............#")
	return {
		"id": id, "band": "speck", "target_body_px": 96.0, "place_id": "", "tiles": rows,
		"exits": [{"id": "x", "side": exit_side, "from": 9, "to": 10, "to_room": other, "to_exit": "x"}],
		"passages": [], "triggers": [], "shelters": [], "dens": [], "tethered": [],
	}


func _fixture() -> Dictionary:
	var texts: Dictionary = EcoRegionLoader.read_content_texts(EcoRegionLoader.CONTENT_ROOT)
	for k: String in texts.keys():
		if k.begins_with("regions/"):
			texts.erase(k)
	var a: Dictionary = _fixture_room("fx_a", "right", "fx_b")
	a["shelters"] = [{"id": "shelter_fx_a", "cell": [3, 10]}]
	var b: Dictionary = _fixture_room("fx_b", "left", "fx_a")
	return {
		"texts": texts,
		"index": {"schema": 1, "regions": ["reg_fx"], "start_room": "fx_a", "start_shelter": "shelter_fx_a", "start_rung": "speck"},
		"region": {"schema": 1, "id": "reg_fx", "display_name": "x", "rooms": [a, b], "links": [{"from": "fx_a", "to": "fx_b", "via": ""}, {"from": "fx_b", "to": "fx_a", "via": ""}]},
	}


func _run(fx: Dictionary) -> Dictionary:
	var texts: Dictionary = fx["texts"]
	if not texts.has("regions/index.json"):
		texts["regions/index.json"] = JSON.stringify(fx["index"])
	if not texts.has("regions/reg_fx.json"):
		texts["regions/reg_fx.json"] = JSON.stringify(fx["region"])
	return EcoRegionLoader.load_from_texts(texts, _table)


func _set_char(row: String, x: int, c: String) -> String:
	return row.substr(0, x) + c + row.substr(x + 1)


func _arc(fx: Dictionary, name: String) -> Dictionary:
	return JSON.parse_string(fx["texts"]["archetypes/%s.json" % name])


const REASONS: Array[String] = [
	"json_invalid", "schema_unsupported", "key_unknown", "value_invalid", "id_duplicate", "band_not_in_table",
	"band_not_used", "tile_char_unknown", "tiles_ragged", "exit_blocked", "exit_unpaired", "link_without_exit",
	"via_unknown", "via_impassable", "passage_kind_unknown", "passage_over_solid", "gap_rect_too_narrow",
	"drop_height_mismatch", "salt_outside_bed", "trigger_object_unknown", "creature_above_band",
	"den_slots_exceeded", "lineage_last_stage_nonzero", "variant_not_adjacent", "start_invalid",
]


func _room_a(fx: Dictionary) -> Dictionary:
	return fx["region"]["rooms"][0]


func _m_json_invalid(fx: Dictionary) -> void:
	fx["texts"]["regions/reg_fx.json"] = "{broken"


func _m_schema_unsupported(fx: Dictionary) -> void:
	fx["region"]["schema"] = 2


func _m_key_unknown(fx: Dictionary) -> void:
	_room_a(fx)["flavor"] = 1


func _m_value_invalid(fx: Dictionary) -> void:
	_room_a(fx)["target_body_px"] = 9999.0


func _m_id_duplicate(fx: Dictionary) -> void:
	fx["region"]["rooms"][1]["shelters"] = [{"id": "shelter_fx_a", "cell": [3, 10]}]


func _m_band_not_in_table(fx: Dictionary) -> void:
	_room_a(fx)["band"] = "giant"


func _m_band_not_used(fx: Dictionary) -> void:
	_room_a(fx)["band"] = "common"


func _m_tile_char_unknown(fx: Dictionary) -> void:
	_room_a(fx)["tiles"][5] = _set_char(_room_a(fx)["tiles"][5], 4, "X")


func _m_tiles_ragged(fx: Dictionary) -> void:
	_room_a(fx)["tiles"][5] = str(_room_a(fx)["tiles"][5]) + "."


func _m_exit_blocked(fx: Dictionary) -> void:
	_room_a(fx)["tiles"][9] = _set_char(_room_a(fx)["tiles"][9], 15, "#")


func _m_exit_unpaired(fx: Dictionary) -> void:
	fx["region"]["rooms"][1]["exits"][0]["to_exit"] = "nope"


func _m_link_without_exit(fx: Dictionary) -> void:
	fx["region"]["links"].append({"from": "fx_a", "to": "fx_a", "via": ""})


func _m_via_unknown(fx: Dictionary) -> void:
	fx["region"]["links"][0]["via"] = "ghost"


func _m_via_impassable(fx: Dictionary) -> void:
	_room_a(fx)["passages"] = [{"id": "gap_fx_seal", "kind": "GAP", "cell": [5, 3], "span": [4, 2], "width_class": "SEAL"}]
	fx["region"]["links"][0]["via"] = "gap_fx_seal"


func _m_passage_kind_unknown(fx: Dictionary) -> void:
	_room_a(fx)["passages"] = [{"id": "p_fx", "kind": "FLOOD", "cell": [5, 3], "span": [2, 2]}]


func _m_passage_over_solid(fx: Dictionary) -> void:
	_room_a(fx)["passages"] = [{"id": "p_fx", "kind": "GAP", "cell": [0, 0], "span": [6, 2], "width_class": "FIT"}]


func _m_gap_rect_too_narrow(fx: Dictionary) -> void:
	_room_a(fx)["passages"] = [{"id": "p_fx", "kind": "GAP", "cell": [5, 3], "span": [3, 2], "width_class": "WIDE"}]


func _m_drop_height_mismatch(fx: Dictionary) -> void:
	_room_a(fx)["passages"] = [{"id": "p_fx", "kind": "DROP", "cell": [5, 3], "span": [2, 3], "fall_px": 1600}]


func _m_salt_outside_bed(fx: Dictionary) -> void:
	_room_a(fx)["tiles"][10] = _set_char(_room_a(fx)["tiles"][10], 8, "s")


func _m_trigger_object_unknown(fx: Dictionary) -> void:
	_room_a(fx)["triggers"] = [{"id": "t_fx", "object": "mystery_bed", "cell": [5, 5], "span": [2, 2]}]


func _m_creature_above_band(fx: Dictionary) -> void:
	_room_a(fx)["tethered"] = [{"axis_id": "fix.probe", "archetype": "arc_anchor", "cell": [4, 10], "rung": "doll"}]


func _m_den_slots_exceeded(fx: Dictionary) -> void:
	var dens: Array = []
	for i: int in 10:
		dens.append({"id": "den_fx_%d" % i, "cell": [3 + i, 10], "lineage_of": "arc_skitter", "stage": 0})
	_room_a(fx)["dens"] = dens


func _m_lineage_last_stage_nonzero(fx: Dictionary) -> void:
	var arc: Dictionary = _arc(fx, "arc_skitter")
	arc["lineage"][arc["lineage"].size() - 1]["advance_chance"] = 0.1
	fx["texts"]["archetypes/arc_skitter.json"] = JSON.stringify(arc)


func _m_variant_not_adjacent(fx: Dictionary) -> void:
	var arc: Dictionary = _arc(fx, "arc_skitter")
	arc["variant_rungs"] = ["speck", "doll"]
	fx["texts"]["archetypes/arc_skitter.json"] = JSON.stringify(arc)


func _m_start_invalid(fx: Dictionary) -> void:
	fx["index"]["start_rung"] = "tall"


func test_eco_loader_rejects_each_reason() -> void:
	var clean: Dictionary = _run(_fixture())
	assert_true(clean["ok"], "fixture is clean: " + ", ".join(clean["errors"]))
	for reason: String in REASONS:
		var fx: Dictionary = _fixture()
		call("_m_" + reason, fx)
		var result: Dictionary = _run(fx)
		assert_false(result["ok"], reason + " must fail")
		var found: bool = false
		for e: String in result["errors"]:
			if e.get_slice(" ", 0) == reason:
				found = true
		assert_true(found, "%s reported (got: %s)" % [reason, ", ".join(result["errors"])])

func _annex_room(id: String, tiles_top_open: bool, exits: Array) -> Dictionary:
	var rows: Array = []
	for y: int in 16:
		if y == 0:
			rows.append("########################################")
		elif y == 15:
			rows.append("##########......########################" if tiles_top_open else "########################################")
		else:
			rows.append("........................................")
	return {"id": id, "band": "hand", "target_body_px": 240.0, "place_id": "", "tiles": rows, "exits": exits, "passages": [], "triggers": [], "shelters": [], "dens": [], "tethered": []}


func extension_texts() -> Dictionary:
	var texts: Dictionary = EcoRegionLoader.read_content_texts(EcoRegionLoader.CONTENT_ROOT)
	var index_file: Dictionary = JSON.parse_string(texts["regions/index.json"])
	index_file["regions"].append("reg_probe_annex")
	texts["regions/index.json"] = JSON.stringify(index_file)
	var vault: Dictionary = JSON.parse_string(texts["regions/reg_seed_vault.json"])
	for room: Dictionary in vault["rooms"]:
		if room["id"] == "seed_vault_03":
			var top: String = room["tiles"][0]
			room["tiles"][0] = top.substr(0, 10) + "......" + top.substr(16)
			room["exits"].append({"id": "n", "side": "top", "from": 10, "to": 15, "to_room": "probe_annex_00", "to_exit": "s"})
	vault["links"].append({"from": "seed_vault_03", "to": "probe_annex_00", "via": ""})
	texts["regions/reg_seed_vault.json"] = JSON.stringify(vault)
	var annex_00: Dictionary = _annex_room("probe_annex_00", true, [
		{"id": "s", "side": "bottom", "from": 10, "to": 15, "to_room": "seed_vault_03", "to_exit": "n"},
		{"id": "e", "side": "right", "from": 3, "to": 14, "to_room": "probe_annex_01", "to_exit": "w"},
	])
	annex_00["shelters"] = [{"id": "shelter_probe_00", "cell": [30, 14]}]
	var annex_01: Dictionary = _annex_room("probe_annex_01", false, [
		{"id": "w", "side": "left", "from": 3, "to": 14, "to_room": "probe_annex_00", "to_exit": "e"},
	])
	texts["regions/reg_probe_annex.json"] = JSON.stringify({
		"schema": 1, "id": "reg_probe_annex", "display_name": "x", "rooms": [annex_00, annex_01],
		"links": [
			{"from": "probe_annex_00", "to": "seed_vault_03", "via": ""},
			{"from": "probe_annex_00", "to": "probe_annex_01", "via": ""},
			{"from": "probe_annex_01", "to": "probe_annex_00", "via": ""},
		],
	})
	return texts


func test_eco_content_extension_without_core_change() -> void:
	var result: Dictionary = EcoRegionLoader.load_from_texts(extension_texts(), _table)
	assert_true(result["ok"], "annex loads: " + ", ".join(result["errors"]))
	if not result["ok"]:
		return
	var index: EcoContentIndex = result["value"]
	assert_eq(index.room_count(), 27)
	var graph: EcoRegionGraph = EcoRegionGraph.build(index, _table)
	assert_eq(graph.unreached_rooms().size(), 0, "G1 with annex: " + ", ".join(graph.unreached_rooms()))
	assert_eq(graph.dead_ends().size(), 0, "G2 with annex: " + ", ".join(graph.dead_ends()))
	var director: EcoStepDirector = EcoStepDirector.make(index, _table)
	director.world.body_rung = "hand"
	director.enter_room("probe_annex_00", Vector2(30 * 24 + 12, 15 * 24))
	for i: int in 600:
		director.step_frame({"move_axis": 1.0 if (i / 120) % 2 == 0 else -1.0, "jump_held": i % 50 < 10, "curl_held": false, "use_pressed": false, "any_input": true})
	assert_eq(director.errors.size(), 0, "600 frames in the annex: " + ", ".join(director.errors))
	assert_true(["probe_annex_00", "probe_annex_01", "seed_vault_03"].has(director.world.current_room_id))


func test_eco_room_order_is_authored_order() -> void:
	var result: Dictionary = EcoRegionLoader.load_all(_table)
	var index: EcoContentIndex = result["value"]
	if index == null:
		fail_test("content did not load: " + ", ".join(result["errors"]))
		return
	var index_file: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(EcoRegionLoader.CONTENT_ROOT.path_join("regions/index.json")))
	for i: int in index.regions.size():
		var region: EcoRegionSpec = index.regions[i]
		assert_eq(region.id, str(index_file["regions"][i]))
		assert_eq(region.index, i)
		for j: int in region.rooms.size():
			assert_eq(region.rooms[j].index, j)
			assert_eq(region.rooms[j].region_id, region.id)
