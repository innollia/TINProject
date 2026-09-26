extends GutTest


func _module() -> DescentModule:
	var module := DescentModule.new()
	autofree(module)
	return module


func _item(id: String, size: int = 1, verb: String = "weigh", tag: String = "bead") -> Dictionary:
	return {"id": id, "size": size, "verb": verb, "tag": tag, "source_stratum": "stratum_roots"}


func _sample() -> Dictionary:
	return {
		"schema": 1,
		"module_id": "descent_exploration",
		"run_id": "r-9f3a1c",
		"world_seed": 90210,
		"phase": "playing",
		"stratum_index": 3,
		"stratum_id": "stratum_nursery",
		"facts": ["current_lies", "vent_above"],
		"mass": 2,
		"carried": [_item("matter_seed_vial", 1, "feed", "seed"), _item("matter_nursery_rib", 1, "weigh", "rib")],
		"consumed": [{"matter": "matter_brine_plug", "site": "tide_main", "stratum": "stratum_teeth"}],
		"position": [176.0, 402.0],
		"facing": 1,
		"integrity": 2,
		"anchors_taken": ["stratum_roots#a1", "stratum_halls#a1", "stratum_teeth#a1", "stratum_nursery#a1"],
		"sites_done": ["site_roots_plaque", "site_nursery_plaque"],
		"routes_opened": ["exit_roots", "exit_halls", "exit_teeth_plug", "exit_nursery"],
		"checkpoint": {
			"stratum_id": "stratum_nursery",
			"anchor_id": "a1",
			"position": [80.0, 300.0],
			"mass": 1,
			"facts": ["current_lies", "vent_above"],
			"carried": [_item("matter_seed_vial", 1, "feed", "seed")],
		},
		"ending_id": "",
	}


func test_save_load_save_is_stable_through_json() -> void:
	var first := _module()
	first.load_state(_sample())
	var saved: Dictionary = first.save_state()
	var second := _module()
	second.load_state(JSON.parse_string(JSON.stringify(saved)) as Dictionary)
	assert_eq(JSON.stringify(second.save_state()), JSON.stringify(saved))
	assert_eq(second.state.stratum_id, "stratum_nursery")
	assert_eq(second.state.facts.to_array(), ["current_lies", "vent_above"] as Array[String])
	assert_eq(second.state.mass, 2)


func test_unknown_schema_resets_to_a_new_run() -> void:
	var module := _module()
	module.load_state({"schema": 999, "stratum_index": 4, "stratum_id": "stratum_gallery", "facts": ["vent_above"]})
	assert_eq(module.state.schema, 1)
	assert_eq(module.state.phase, "first_frame")
	assert_eq(module.state.stratum_index, 0)
	assert_true(module.state.facts.is_empty())


func test_invalid_carried_entry_is_dropped_alone() -> void:
	var data := _sample()
	(data["carried"] as Array).append(_item("broken", 1, "nope", "x"))
	var module := _module()
	module.load_state(data)
	assert_eq(module.state.carried_ids(), ["matter_seed_vial", "matter_nursery_rib"] as Array[String])


func test_overweight_carried_list_is_trimmed_from_the_back() -> void:
	var data := _sample()
	var six: Array = []
	for index: int in 6:
		six.append(_item("m%d" % index))
	data["carried"] = six
	var module := _module()
	module.load_state(data)
	assert_eq(module.state.carried_ids(), ["m0", "m1", "m2", "m3"] as Array[String])
	assert_eq(module.state.mass, 4)


func test_unknown_fact_is_kept() -> void:
	var data := _sample()
	data["facts"] = ["unknown_fact"]
	var module := _module()
	module.load_state(data)
	assert_eq(module.state.facts.to_array(), ["unknown_fact"] as Array[String])


func test_unknown_stratum_falls_forward_to_the_authored_one_at_its_index() -> void:
	var data := _sample()
	data["stratum_index"] = 2
	data["stratum_id"] = "stratum_nope"
	var module := _module()
	module.load_state(data)
	assert_eq(module.state.stratum_id, "stratum_teeth")
	assert_eq(module.state.stratum_index, 2)
	assert_not_null(module.runtime)
	assert_eq(module.runtime.id, "stratum_teeth")
	assert_eq(module.state.position, Vector2(120.0, 96.0))


func test_empty_checkpoint_points_at_the_first_anchor_of_the_stratum() -> void:
	var data := _sample()
	data["stratum_index"] = 0
	data["stratum_id"] = "stratum_roots"
	data["checkpoint"] = {}
	var module := _module()
	module.load_state(data)
	assert_eq(module.state.checkpoint["stratum_id"], "stratum_roots")
	assert_eq(module.state.checkpoint["anchor_id"], "a1")
	assert_eq(StratumRuntime.anchor_key(module.state.checkpoint["stratum_id"], module.state.checkpoint["anchor_id"]), "stratum_roots#a1")


func test_saved_dictionary_leaves_out_transient_and_counter_keys() -> void:
	var module := _module()
	module.load_state(_sample())
	var saved: Dictionary = module.save_state()
	for key: String in ["velocity", "open_bristles", "down_count", "downed_for", "invulnerable_for", "surge_cooldown_for", "surge_active_for", "transition_pending", "transition_to", "elapsed_play"]:
		assert_false(saved.has(key), key)
	for key: Variant in saved.keys():
		assert_false(String(key).begins_with("down"), String(key))


func test_migrate_of_the_current_version_is_an_identity() -> void:
	var module := _module()
	var data := _sample()
	assert_eq(module.migrate_save(1, data), data)


func test_unknown_ending_is_cleared_and_play_resumes() -> void:
	var data := _sample()
	data["phase"] = "ending"
	data["ending_id"] = "ending.elsewhere"
	var module := _module()
	module.load_state(data)
	assert_eq(module.state.ending_id, "")
	assert_eq(module.state.phase, "first_frame")


func test_load_clamps_numbers_into_their_ranges() -> void:
	var data := _sample()
	data["integrity"] = 9
	data["facing"] = -7
	data["mass"] = 99
	data["position"] = [9000.0, -5.0]
	var module := _module()
	module.load_state(data)
	assert_eq(module.state.integrity, 3)
	assert_eq(module.state.facing, -1)
	assert_eq(module.state.mass, 2)
	assert_eq(module.state.position, Vector2(640.0, 0.0))


func test_empty_state_starts_a_new_run() -> void:
	var module := _module()
	module.load_state({})
	assert_eq(module.state.stratum_id, "stratum_roots")
	assert_eq(module.state.mass, 0)
	assert_eq(module.state.checkpoint["anchor_id"], "a1")
