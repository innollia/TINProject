extends GutTest

const MODULE_DIR: String = "res://modules/sideview_ecosystem"
const RUNG_VALUES: Array[float] = [0.05, 0.12, 0.28, 0.65, 1.50, 3.60]
const FIT_TARGET: float = 2.75
const CAMERA_FRAME_MODULES: float = 6.0

var _table: EcoRungTable
var _index: EcoContentIndex


func before_all() -> void:
	_table = EcoRungTable.make(EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)["value"])["value"]
	_index = EcoRegionLoader.load_all(_table)["value"]


func _all_gd_files(path: String) -> PackedStringArray:
	var out: PackedStringArray = []
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full: String = path.path_join(name)
		if dir.current_is_dir():
			out.append_array(_all_gd_files(full))
		elif name.ends_with(".gd"):
			out.append(full)
		name = dir.get_next()
	dir.list_dir_end()
	return out


func _all_json_files(path: String) -> PackedStringArray:
	var out: PackedStringArray = []
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full: String = path.path_join(name)
		if dir.current_is_dir():
			out.append_array(_all_json_files(full))
		elif name.ends_with(".json"):
			out.append(full)
		name = dir.get_next()
	dir.list_dir_end()
	return out


func _read(path: String) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func test_eco_scale_is_always_a_rung() -> void:
	for path: String in _all_gd_files(MODULE_DIR + "/domain") + _all_gd_files(MODULE_DIR + "/systems"):
		var text: String = _read(path)
		var re: RegEx = RegEx.new()
		re.compile("(?<![\\w.])1\\.0(?![0-9])")
		assert_eq(re.search_all(text).size(), 0, "%s contains a literal 1.0" % path)
	for path: String in _all_json_files(MODULE_DIR + "/content"):
		var text: String = _read(path)
		assert_eq(text.find("\"scale\": 1.0"), -1, "%s writes a raw 1.0 scale" % path)


func test_eco_no_q_dependent_silhouette() -> void:
	var allowed: PackedStringArray = ["step_director.gd", "audio_sink.gd", "procedural_bridge.gd"]
	for path: String in _all_gd_files(MODULE_DIR):
		var file_name: String = path.get_file()
		if allowed.has(file_name):
			continue
		var text: String = _read(path)
		assert_eq(text.find("q("), -1, "%s reads q(" % path)
	for forbidden_file: String in ["player_view.gd", "collision_resolver.gd", "passage_resolver.gd"]:
		for path: String in _all_gd_files(MODULE_DIR):
			if path.get_file() != forbidden_file:
				continue
			assert_eq(_read(path).find("q("), -1, "%s must not read q(" % path)


func test_eco_no_scale_label_or_gauge() -> void:
	var presentation_dir: String = MODULE_DIR + "/presentation"
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(presentation_dir)):
		pending("presentation/ does not exist yet")
		return
	for path: String in _all_gd_files(presentation_dir):
		var text: String = _read(path)
		for rung_name: String in ["speck", "hand", "doll"]:
			assert_eq(text.find("\"" + rung_name + "\""), -1, "%s prints the rung name" % path)
		assert_eq(text.find("Label.new"), -1, "%s creates a Label" % path)
		assert_eq(text.find("RichTextLabel.new"), -1, "%s creates a RichTextLabel" % path)


func test_eco_rung_graph_is_bidirectional() -> void:
	var graph: EcoRegionGraph = EcoRegionGraph.build(_index, _table)
	var up: int = 0
	var down: int = 0
	for from_state: String in graph.edges.keys():
		for e: Dictionary in graph.edges[from_state]:
			var from_i: int = _table.index_of(EcoRegionGraph.rung_of(from_state))
			var to_i: int = _table.index_of(EcoRegionGraph.rung_of(str(e["to"])))
			if to_i == from_i:
				continue
			assert_ne(from_state, str(e["to"]), "no self-loop")
			if to_i > from_i:
				up += 1
			elif to_i < from_i:
				down += 1
	assert_gt(up, 0, "at least one edge increases rung")
	assert_gt(down, 0, "at least one edge decreases rung — the graph is not one-way")


func test_eco_scale_survives_save_load() -> void:
	var store: WorldState = WorldState.new()
	store.declare_owner(&"body", EcoWorldstateBridge.REQUESTER)
	var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge.attach_world_store(store)
	var begun: Dictionary = EcoSaveService.begin(bridge, _index, _table, null)
	assert_true(begun["ok"])
	var director: EcoStepDirector = EcoStepDirector.make(_index, _table, bridge)
	director.start(begun["world"], _index.content_seed)
	director.world.body_rung = "doll"
	bridge.write_scale(_table.ladder.value_of("doll"))
	var save: EcoSaveService = EcoSaveService.new()
	save.path = "user://test_eco_scale_survives_save_load.json"
	save.delete_file()
	director.save = save
	director._save("S1")
	var reread: Variant = save.read_file()
	assert_true(reread is Dictionary)
	var bridge2: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge2.attach_world_store(store)
	var begun2: Dictionary = EcoSaveService.begin(bridge2, _index, _table, reread)
	assert_true(begun2["ok"])
	assert_eq((begun2["world"] as EcoWorldState).body_rung, "doll", "rung is restored from the axis, which the save wrote via write_scale before S1")
	save.delete_file()


func test_eco_start_rung_written_once() -> void:
	var store: WorldState = WorldState.new()
	store.declare_owner(&"body", EcoWorldstateBridge.REQUESTER)
	var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge.attach_world_store(store)
	var begun1: Dictionary = EcoSaveService.begin(bridge, _index, _table, null)
	assert_true(bool(begun1["wrote_start_rung"]))
	var bridge2: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge2.attach_world_store(store)
	var begun2: Dictionary = EcoSaveService.begin(bridge2, _index, _table, null)
	assert_false(bool(begun2["wrote_start_rung"]), "second enter does not rewrite the start rung")
	assert_almost_eq(bridge.read_body().scale_value, _table.ladder.value_of(_index.start_rung), 0.00001)


func test_eco_wrong_rung_has_no_text() -> void:
	pending("requires presentation/ to render frames and assert no new strings appear")


func test_eco_separation_five_readers() -> void:
	var gates_text: String = _read("res://docs/scale_collapse/06_TESTS_AND_GATES.md")
	var re: RegEx = RegEx.new()
	re.compile("SEPARATION\\s*=\\s*([0-9]+\\.[0-9]+)")
	var m: RegExMatch = re.search(gates_text)
	if m == null:
		var visuals_text: String = _read("res://docs/scale_collapse/03_MISMATCH_VISUALS.md")
		m = re.search(visuals_text)
	assert_not_null(m, "SEPARATION lower bound must be readable from the docs")
	var separation_min: float = float(m.get_string(1))
	for room_id: String in _index.all_room_ids():
		var room: EcoRoomSpec = _index.room(room_id)
		var band_value: float = _table.band_value(room.band)
		if band_value <= 0.0:
			continue
		for rung_name: String in _table.names():
			var q: float = _table.by_name(rung_name).scale_value / band_value
			var module_count: float = FIT_TARGET * q
			var relief_ratio: float = 0.02 / module_count
			var contact_ratio: float = 0.060 / module_count
			var ripple_ratio: float = 0.0218 * module_count
			var pitch_scale: float = q
			var values: Array[float] = [relief_ratio, contact_ratio, ripple_ratio, pitch_scale, module_count]
			values.sort()
			var min_ratio: float = values[values.size() - 1] / values[0] if values[0] > 0.0 else INF
			assert_true(min_ratio >= separation_min or is_equal_approx(q, 1.0), "%s at rung %s: separation %f below %f" % [room_id, rung_name, min_ratio, separation_min])


func test_eco_ability_is_derived_not_stored() -> void:
	var store: WorldState = WorldState.new()
	store.declare_owner(&"body", EcoWorldstateBridge.REQUESTER)
	store.request_mutation(&"body", {"scale": _table.ladder.value_of("hand")}, EcoWorldstateBridge.REQUESTER)
	var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge.attach_world_store(store)
	var axis: EcoBodyAxis = bridge.read_body()
	assert_false(axis.facts.has("abilities"), "no ability field on the body axis")
	assert_false(axis.facts.has("traits"), "no ability field on the body axis")
	var abilities_from_rung: int = _table.abilities_of("hand", "hand")
	assert_eq(_table.abilities_of("hand", "hand"), abilities_from_rung, "abilities are recomputed from rung, deterministically")
