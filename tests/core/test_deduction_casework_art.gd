extends GutTest

const Lookup = preload("res://modules/deduction_casework/systems/art_candidate_lookup.gd")
const CANDIDATES := "res://modules/deduction_casework/content/art_candidates.json"
const CASES_DIR := "res://modules/deduction_casework/content/cases/"


func before_each() -> void:
	Lookup.reload()


func _catalog() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(CANDIDATES))


func _case_json(case_id: String) -> Dictionary:
	for file_name: String in DirAccess.get_files_at(CASES_DIR):
		if file_name.begins_with(case_id) and file_name.ends_with(".json"):
			return JSON.parse_string(FileAccess.get_file_as_string(CASES_DIR + file_name))
	return {}


func test_every_mapped_candidate_path_loads_as_texture() -> void:
	var cases: Dictionary = _catalog()["cases"]
	assert_eq(cases.size(), 3, "1·2·3번 사건만 그림 후보가 있다")
	for case_id: String in cases:
		for group: String in ["scenes", "hotspots"]:
			var table: Dictionary = cases[case_id][group]
			for entry_id: String in table:
				assert_true(ResourceLoader.exists(table[entry_id]), "%s %s %s" % [case_id, entry_id, table[entry_id]])


func test_every_scene_and_hotspot_of_cases_1_to_3_has_art() -> void:
	for case_id: String in ["case_01_saint_orin", "case_02_morren_empty_chair", "case_03_n153_last_tour"]:
		var data := _case_json(case_id)
		assert_false(data.is_empty(), case_id)
		for scene: Dictionary in data.get("scenes", []):
			assert_not_null(Lookup.scene_texture(case_id, scene["id"]), "%s %s" % [case_id, scene["id"]])
			for hotspot: Dictionary in scene.get("hotspots", []):
				assert_not_null(Lookup.hotspot_texture(case_id, hotspot["id"]), "%s %s" % [case_id, hotspot["id"]])


func test_shared_scene_ids_resolve_per_case() -> void:
	var locker_1 := Lookup.scene_path("case_01_saint_orin", "scene_locker")
	var locker_3 := Lookup.scene_path("case_03_n153_last_tour", "scene_locker")
	assert_ne(locker_1, locker_3)
	assert_string_contains(locker_1, "bg_s01_locker")
	assert_string_contains(locker_3, "bg_s03_locker")
	assert_string_contains(Lookup.scene_path("case_02_morren_empty_chair", "scene_service"), "bg_s02_service")
	assert_string_contains(Lookup.scene_path("case_03_n153_last_tour", "scene_service"), "bg_s03_service")


func test_unmapped_ids_fall_back_to_placeholder() -> void:
	assert_null(Lookup.scene_texture("case_04_bellma_exchange_247", "scene_lab"))
	assert_null(Lookup.hotspot_texture("case_01_saint_orin", "hotspot_does_not_exist"))
	assert_null(Lookup.scene_texture("", ""))
