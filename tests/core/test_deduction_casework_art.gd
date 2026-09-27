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
		var scenes: Dictionary = cases[case_id]["scenes"]
		for scene_id: String in scenes:
			assert_true(ResourceLoader.exists(scenes[scene_id]["path"]), "%s %s" % [case_id, scene_id])
		var hotspots: Dictionary = cases[case_id]["hotspots"]
		for entry_id: String in hotspots:
			assert_true(ResourceLoader.exists(hotspots[entry_id]["path"]), "%s %s" % [case_id, entry_id])


func test_every_scene_and_hotspot_of_cases_1_to_3_has_art() -> void:
	for case_id: String in ["case_01_saint_orin", "case_02_morren_empty_chair", "case_03_n153_last_tour"]:
		var data := _case_json(case_id)
		assert_false(data.is_empty(), case_id)
		for scene: Dictionary in data.get("scenes", []):
			assert_not_null(Lookup.scene_texture(case_id, scene["id"]), "%s %s" % [case_id, scene["id"]])
			for hotspot: Dictionary in scene.get("hotspots", []):
				assert_not_null(Lookup.hotspot_texture(case_id, hotspot["id"]), "%s %s" % [case_id, hotspot["id"]])


func test_every_hotspot_has_a_world_box_in_case_1_to_3() -> void:
	for case_id: String in ["case_01_saint_orin", "case_02_morren_empty_chair", "case_03_n153_last_tour"]:
		var data := _case_json(case_id)
		for scene: Dictionary in data.get("scenes", []):
			for hotspot: Dictionary in scene.get("hotspots", []):
				var box := Lookup.hotspot_world_box(case_id, hotspot["id"])
				assert_eq(box.size(), 4, "%s %s box" % [case_id, hotspot["id"]])
				if box.size() == 4:
					assert_true(float(box[2]) > 0.0 and float(box[3]) > 0.0, "%s %s has positive size" % [case_id, hotspot["id"]])


func test_world_layout_boxes_stay_keyboard_and_mouse_reachable() -> void:
	const AuthoredCaseScene = preload("res://modules/deduction_casework/presentation/authored_case_scene.gd")
	assert_eq(AuthoredCaseScene.HOTSPOT_LAYOUT, "world", "사용자 확정: world 배치")
	var scene: Control = (load("res://modules/deduction_casework/presentation/authored_case_scene.tscn") as PackedScene).instantiate()
	add_child_autofree(scene)
	scene.size = Vector2(1280, 720)
	var data := _case_json("case_01_saint_orin")
	scene.apply_snapshot(
		{"case_id": "case_01_saint_orin", "scene_id": "scene_lab", "focus_id": "hotspot_lab_bench"},
		data
	)
	await get_tree().process_frame
	await get_tree().process_frame
	var world_layer: Control = scene.get_node_or_null("%WorldLayer")
	assert_not_null(world_layer)
	if world_layer == null:
		return
	var boxes := world_layer.get_children().filter(func(node: Node) -> bool: return node is Control)
	assert_eq(boxes.size(), 9, "6 hotspot + 3 exit")
	for box: Control in boxes:
		assert_eq(box.focus_mode, Control.FOCUS_ALL, "키보드로 닿아야 한다")
		assert_eq(box.mouse_filter, Control.MOUSE_FILTER_STOP, "마우스로 닿아야 한다")
		assert_true(box.size.x > 0.0 and box.size.y > 0.0, "배치된 실제 크기가 있어야 한다")


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
