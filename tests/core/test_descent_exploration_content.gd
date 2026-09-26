extends GutTest

const STRATA_DIR: String = "res://modules/descent_exploration/authored/strata"
const CANON: Array[String] = ["stratum_roots", "stratum_halls", "stratum_teeth", "stratum_nursery", "stratum_gallery", "stratum_floor"]
const PROBE: String = "stratum_extra_probe"
const CONTEXT: Dictionary = {"strata": ["stratum_mini", "stratum_next"], "facts": ["known_fact"], "sites": ["known_site"]}


func _read(id: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("%s/%s.json" % [STRATA_DIR, id]))
	return parsed if parsed is Dictionary else {}


func _loaded() -> DescentContentLoader:
	var loader := DescentContentLoader.new()
	loader.load_dir()
	return loader


func _minimal() -> Dictionary:
	return {
		"schema": 1,
		"id": "stratum_mini",
		"index": 0,
		"location": "loc.mini",
		"display_name": "시험",
		"world_seed": 1,
		"palette": {"scheme": "analogous", "base_hue": 0.5, "saturation": 0.5, "contrast": 1.0, "variant": 0},
		"bounds": {"width": 640, "height": 1024},
		"spawn": {"position": [320, 96], "facing": 1},
		"solids": [{"id": "ground", "rect": [0, 0, 640, 64], "kind": "ground"}],
		"currents": [],
		"membranes": [],
		"routes": [{"id": "exit_mini", "kind": "descent", "trigger": [280, 944, 80, 64], "requires": [{"kind": "always"}], "next": "stratum_next"}],
		"sites": [],
		"matter": [],
		"anchors": [{"id": "a1", "position": [320, 128]}],
		"fauna": [],
		"backdrop": {"wind": [0.0, 1.0], "deform_grid": [[10, 22], [8, 20], [8, 18], [6, 16], [6, 14]], "pulse_on": []},
	}


func _terminal_endings() -> Array:
	return [
		{"id": "mouth.still", "kind": "ending", "trigger": [100, 880, 60, 40], "requires": [{"kind": "always"}], "next": "ending.hollow"},
		{"id": "mouth.above", "kind": "ending", "trigger": [200, 880, 60, 40], "requires": [{"kind": "fact", "fact": "known_fact"}], "next": "ending.return"},
		{"id": "mouth.heart", "kind": "ending", "trigger": [400, 880, 60, 40], "requires": [{"kind": "carrying", "verb": "feed"}], "next": "ending.swallow"},
	]


func _rules(layer: Dictionary, file_id: String = "stratum_mini") -> Array[int]:
	return DescentContentValidator.failed_rules(DescentContentValidator.validate(layer, file_id, CONTEXT))


func test_minimal_layer_is_valid() -> void:
	assert_eq(DescentContentValidator.validate(_minimal(), "stratum_mini", CONTEXT), [] as Array[Dictionary])


func test_every_authored_stratum_validates_without_errors() -> void:
	var loader := _loaded()
	assert_eq(loader.errors, [] as Array[Dictionary])
	assert_true(loader.rejected.is_empty())
	for id: String in CANON:
		assert_true(loader.has_stratum(id), id)
	if FileAccess.file_exists("%s/%s.json" % [STRATA_DIR, PROBE]):
		assert_true(loader.has_stratum(PROBE))


func test_loader_orders_the_strata_by_index() -> void:
	var loader := _loaded()
	var expected: int = CANON.size() + (1 if FileAccess.file_exists("%s/%s.json" % [STRATA_DIR, PROBE]) else 0)
	assert_eq(loader.count(), expected)
	var canon_count: int = 0
	for position: int in loader.count():
		assert_eq(int(loader.strata[position]["index"]), position)
		if CANON.has(String(loader.strata[position]["id"])):
			canon_count += 1
	assert_eq(canon_count, 6)
	assert_eq(loader.ids().slice(0, 6), CANON)


func test_first_and_last_descent_targets() -> void:
	var roots: StratumRuntime = StratumRuntime.build(_read("stratum_roots"))
	var floor_runtime: StratumRuntime = StratumRuntime.build(_read("stratum_floor"))
	assert_eq(roots.find_route("exit_roots")["next"], "stratum_halls")
	assert_eq(floor_runtime.find_route("exit_floor")["next"], "")


func test_teeth_offers_a_mass_route_and_a_route_without_mass() -> void:
	var teeth: StratumRuntime = StratumRuntime.build(_read("stratum_teeth"))
	var sink: Dictionary = teeth.find_route("exit_teeth_sink")
	var plug: Dictionary = teeth.find_route("exit_teeth_plug")
	assert_eq(int((sink["requires"] as Array)[0]["mass"]), 3)
	assert_eq((plug["requires"] as Array)[0]["kind"], "always")


func test_rule_1_schema() -> void:
	var layer := _minimal()
	layer["schema"] = 2
	assert_true(_rules(layer).has(1))


func test_rule_2_id_matches_the_file() -> void:
	var layer := _minimal()
	layer["id"] = "stratum_other"
	assert_true(_rules(layer).has(2))


func test_rule_3_index_is_not_negative() -> void:
	var layer := _minimal()
	layer["index"] = -1
	assert_true(_rules(layer).has(3))


func test_rule_4_bounds() -> void:
	var layer := _minimal()
	layer["bounds"] = {"width": 641, "height": 1024}
	assert_true(_rules(layer).has(4))


func test_rule_5_coordinates_stay_inside() -> void:
	var layer := _minimal()
	(layer["solids"] as Array).append({"id": "overhang", "rect": [600, 100, 64, 64], "kind": "wall"})
	assert_true(_rules(layer).has(5))
	var drifting := _minimal()
	(drifting["anchors"] as Array).append({"id": "a2", "position": [320, 1100]})
	assert_true(_rules(drifting).has(5))


func test_rule_6_ids_are_unique_inside_a_stratum() -> void:
	var layer := _minimal()
	(layer["solids"] as Array).append({"id": "ground", "rect": [0, 300, 100, 24], "kind": "wall"})
	assert_true(_rules(layer).has(6))


func test_rule_7_descent_routes_exist_and_agree() -> void:
	var layer := _minimal()
	layer["routes"] = []
	assert_true(_rules(layer).has(7))
	var split := _minimal()
	(split["routes"] as Array).append({"id": "exit_other", "kind": "descent", "trigger": [40, 944, 80, 64], "requires": [{"kind": "always"}], "next": "stratum_mini"})
	assert_true(_rules(split).has(7))


func test_rule_8_next_names_an_authored_stratum() -> void:
	var layer := _minimal()
	(layer["routes"] as Array)[0]["next"] = "stratum_missing"
	assert_true(_rules(layer).has(8))


func test_rule_9_last_stratum_carries_the_three_mouths() -> void:
	var layer := _minimal()
	(layer["routes"] as Array)[0]["next"] = ""
	assert_true(_rules(layer).has(9))
	var wrong := _minimal()
	(wrong["routes"] as Array)[0]["next"] = ""
	var mouths: Array = _terminal_endings()
	mouths[2]["id"] = "mouth.hearth"
	(wrong["routes"] as Array).append_array(mouths)
	assert_true(_rules(wrong).has(9))
	var right := _minimal()
	(right["routes"] as Array)[0]["next"] = ""
	(right["routes"] as Array).append_array(_terminal_endings())
	assert_false(_rules(right).has(9))
	var early := _minimal()
	(early["routes"] as Array).append_array(_terminal_endings())
	assert_true(_rules(early).has(9))


func test_rule_10_requirements_are_known_and_earlier() -> void:
	var layer := _minimal()
	(layer["routes"] as Array)[0]["requires"] = [{"kind": "fact", "fact": "unknown_fact"}]
	assert_true(_rules(layer).has(10))
	var unknown_kind := _minimal()
	(unknown_kind["routes"] as Array)[0]["requires"] = [{"kind": "counter", "count": 9}]
	assert_true(_rules(unknown_kind).has(10))
	var unknown_site := _minimal()
	(unknown_site["routes"] as Array)[0]["requires"] = [{"kind": "opened", "site_id": "nowhere"}]
	assert_true(_rules(unknown_site).has(10))
	var known := _minimal()
	(known["routes"] as Array)[0]["requires"] = [{"kind": "fact", "fact": "known_fact"}, {"kind": "opened", "site_id": "known_site"}]
	assert_false(_rules(known).has(10))
	var mass_ending := _minimal()
	(mass_ending["routes"] as Array)[0]["next"] = ""
	var mouths: Array = _terminal_endings()
	mouths[0]["requires"] = [{"kind": "clearance", "mass": 2}]
	(mass_ending["routes"] as Array).append_array(mouths)
	assert_true(_rules(mass_ending).has(10))


func test_rule_11_mass_alone_never_opens_a_stratum() -> void:
	var layer := _minimal()
	(layer["routes"] as Array)[0]["requires"] = [{"kind": "clearance", "mass": 3}]
	(layer["routes"] as Array).append({"id": "exit_heavy", "kind": "descent", "trigger": [40, 944, 80, 64], "requires": [{"kind": "clearance", "mass": 2}], "next": "stratum_next"})
	assert_true(_rules(layer).has(11))
	var with_other := _minimal()
	(with_other["routes"] as Array).append({"id": "exit_heavy", "kind": "descent", "trigger": [40, 944, 80, 64], "requires": [{"kind": "clearance", "mass": 3}], "next": "stratum_next"})
	assert_false(_rules(with_other).has(11))


func test_rule_12_warden_line_and_grazer_without_line() -> void:
	var layer := _minimal()
	(layer["fauna"] as Array).append({"id": "warden", "kind": "warden", "position": [320, 480], "patrol": [480, 960]})
	assert_true(_rules(layer).has(12))
	var grazer := _minimal()
	(grazer["fauna"] as Array).append({"id": "grazer", "kind": "grazer", "position": [320, 480], "patrol": [200, 800], "line_y": 240})
	assert_true(_rules(grazer).has(12))


func test_rule_13_membrane_never_covers_an_exit_trigger() -> void:
	var layer := _minimal()
	(layer["membranes"] as Array).append({"id": "seal", "rect": [260, 930, 120, 40], "verb": "feed"})
	assert_true(_rules(layer).has(13))
	var mouth := _minimal()
	(mouth["routes"] as Array)[0]["next"] = ""
	(mouth["routes"] as Array).append_array(_terminal_endings())
	(mouth["membranes"] as Array).append({"id": "seal", "rect": [390, 870, 80, 20], "verb": "feed"})
	assert_true(_rules(mouth).has(13))


func test_probe_layer_skips_only_rule_9() -> void:
	var probe := _read(PROBE)
	if probe.is_empty():
		pending("probe stratum is absent")
		return
	var context: Dictionary = {"strata": CANON + [PROBE], "facts": ["current_lies", "vent_above"], "sites": ["site_roots_plaque", "site_nursery_plaque"]}
	assert_eq(DescentContentValidator.validate(probe, PROBE, context), [] as Array[Dictionary])
	var broken: Dictionary = probe.duplicate(true)
	(broken["membranes"] as Array).append({"id": "probe_cover", "rect": [260, 930, 120, 40], "verb": "feed"})
	assert_true(DescentContentValidator.failed_rules(DescentContentValidator.validate(broken, PROBE, context)).has(13))
	var same_file_elsewhere: Dictionary = probe.duplicate(true)
	same_file_elsewhere["id"] = "stratum_probe_copy"
	assert_true(DescentContentValidator.failed_rules(DescentContentValidator.validate(same_file_elsewhere, "stratum_probe_copy", context)).has(9))


func test_run_wide_ids_are_unique_across_strata() -> void:
	var seen: Dictionary = {}
	for id: String in CANON + [PROBE]:
		var layer := _read(id)
		if layer.is_empty():
			continue
		assert_false(seen.has(id))
		seen[id] = true
		for key: String in ["matter", "sites", "routes"]:
			for entry: Variant in layer[key]:
				var entry_id: String = String((entry as Dictionary)["id"])
				assert_false(seen.has(entry_id), "%s appears twice" % entry_id)
				seen[entry_id] = true


func test_descent_triggers_are_reachable() -> void:
	for id: String in CANON + [PROBE]:
		var layer := _read(id)
		if layer.is_empty():
			continue
		var runtime: StratumRuntime = StratumRuntime.build(layer)
		for route: Dictionary in runtime.routes:
			if not bool(route["has_trigger"]):
				continue
			var trigger: Rect2 = route["trigger"]
			assert_true(Rect2(0, 0, 640, 1024).encloses(trigger), "%s %s" % [id, route["id"]])
			for solid: Dictionary in runtime.solids:
				assert_false((solid["rect"] as Rect2).encloses(trigger), "%s %s sits inside %s" % [id, route["id"], solid["id"]])
				assert_false((solid["rect"] as Rect2).intersects(trigger), "%s %s overlaps %s" % [id, route["id"], solid["id"]])


func test_every_authored_file_parses_as_json() -> void:
	for file_name: String in DirAccess.get_files_at(STRATA_DIR):
		if not file_name.ends_with(".json"):
			continue
		var parser := JSON.new()
		assert_eq(parser.parse(FileAccess.get_file_as_string(STRATA_DIR.path_join(file_name))), OK, file_name)


func test_stratum_ids_are_unique_and_indices_are_unique() -> void:
	var indices: Array[int] = []
	for id: String in CANON + [PROBE]:
		var layer := _read(id)
		if layer.is_empty():
			continue
		assert_false(indices.has(int(layer["index"])))
		indices.append(int(layer["index"]))
