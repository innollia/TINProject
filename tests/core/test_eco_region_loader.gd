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
