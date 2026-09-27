extends GutTest

const DT: float = 1 / 60.0

var _table: EcoRungTable
var _index: EcoContentIndex


func before_all() -> void:
	_table = EcoRungTable.make(EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)["value"])["value"]
	_index = EcoRegionLoader.load_all(_table)["value"]


func _new_world() -> EcoWorldState:
	return EcoSaveService.new_world(_index)


func test_eco_save_codec_round_trip_matches_the_plan_example() -> void:
	var w: EcoWorldState = EcoWorldState.new()
	w.body_rung = "doll"
	w.integrity = 0.72
	w.position_px = Vector2(624.0, 1416.0)
	w.current_room_id = "bone_shelf_03"
	w.current_band = "doll"
	w.previous_room_id = "bone_shelf_02"
	w.rooms_visited = PackedStringArray(["filter_bed_00", "bone_shelf_03"])
	w.deaths = 4
	w.sleeps = 3
	w.dens = {"den_bs_02_0": {"stage": 2, "occupied": true, "creature_id": 120202}}
	w.creatures = {"120202": {"id": 120202, "axis_id": "120202", "archetype_id": "arc_anchor", "den_id": "den_bs_02_0", "rung": "doll", "lineage_stage": 2, "alive": true, "pos_px": [888.0, 1416.0], "vel_px": [0.0, 0.0], "state": 0, "state_left": 0.18, "hp": 2.6, "killed_by": "none", "think_left": 0.11, "reaction_left": 0.0, "tethered": false, "home_room_id": "bone_shelf_02", "mem": {"last_seen": [], "last_seen_age": [], "last_seen_rung": "doll", "last_damage_source": "none"}}}
	var encoded: Dictionary = EcoSaveCodec.encode(w, 418324771, 418324771)
	assert_true(EcoSaveCodec.is_json_safe(encoded), "encoded save is JSON-safe")
	var decoded: Dictionary = EcoSaveCodec.decode(encoded)
	assert_true(decoded["ok"])
	var w2: EcoWorldState = decoded["value"]
	assert_eq(w2.body_rung, "doll")
	assert_almost_eq(w2.integrity, 0.72, 0.0001)
	assert_eq(w2.current_room_id, "bone_shelf_03")
	assert_eq(w2.previous_room_id, "bone_shelf_02")
	assert_eq(w2.deaths, 4)
	assert_eq(w2.sleeps, 3)
	assert_true(w2.creatures.has("120202"))
	assert_eq(int((w2.creatures["120202"] as Dictionary)["id"]), 120202)
	assert_eq(str(w2.dens["den_bs_02_0"]["stage"]), "2")


func test_eco_save_codec_normalizes_out_of_range_integrity() -> void:
	var d: Dictionary = {"schema": 4, "integrity": 5.0}
	var decoded: Dictionary = EcoSaveCodec.decode(d)
	assert_true(decoded["ok"])
	assert_almost_eq((decoded["value"] as EcoWorldState).integrity, 1.0, 0.0001)
	var d2: Dictionary = {"schema": 4, "integrity": -3.0}
	assert_almost_eq((EcoSaveCodec.decode(d2)["value"] as EcoWorldState).integrity, 0.0, 0.0001)


func test_eco_module_register_actions_is_idempotent() -> void:
	var before_count: int = InputMap.get_actions().size()
	extends_script_register_actions()
	var after_first: int = InputMap.get_actions().size()
	extends_script_register_actions()
	var after_second: int = InputMap.get_actions().size()
	assert_eq(after_first, after_second, "registering twice adds no duplicate actions")
	assert_gte(after_first, before_count)


func extends_script_register_actions() -> void:
	var script: GDScript = load("res://modules/sideview_ecosystem/module.gd")
	script.register_actions()


func test_eco_migrate_save_returns_data_unchanged_at_current_version() -> void:
	var script: GDScript = load("res://modules/sideview_ecosystem/module.gd")
	var mod: Object = script.new()
	var data: Dictionary = {"schema": 4, "body_rung": "hand"}
	var out: Dictionary = mod.migrate_save(4, data)
	assert_eq(out, data)


func test_eco_migrate_save_rejects_older_schema() -> void:
	var script: GDScript = load("res://modules/sideview_ecosystem/module.gd")
	var mod: Object = script.new()
	var out: Dictionary = mod.migrate_save(3, {"schema": 3, "body_rung": "hand"})
	assert_eq(out, {}, "old_version < 4 yields an empty dictionary — no migration chain exists")


func test_eco_step_director_die_then_respawn_after_dying_time() -> void:
	var director: EcoStepDirector = EcoStepDirector.make(_index, _table)
	director.start(_new_world(), _index.content_seed)
	director.world.integrity = 0.0
	director.step_frame({})
	assert_eq(director.mode, EcoStepDirector.MODE_DYING)
	var frames_needed: int = int(ceil(EcoStepDirector.DYING_TIME / EcoStepDirector.FRAME_DT)) + 1
	for i: int in frames_needed:
		director.step_frame({})
	assert_eq(director.mode, EcoStepDirector.MODE_DEAD)
	director.respawn()
	assert_eq(director.mode, EcoStepDirector.MODE_NORMAL)
	assert_almost_eq(director.world.integrity, 1.0, 0.0001)


func test_eco_check_shelter_curls_for_required_time_then_sleeps() -> void:
	var director: EcoStepDirector = EcoStepDirector.make(_index, _table)
	var world: EcoWorldState = _new_world()
	director.start(world, _index.content_seed)
	var shelter: Dictionary = director.room.shelter_by_id(_index.start_shelter)
	assert_false(shelter.is_empty(), "start room has the start shelter")
	director.world.position_px = EcoSaveService.shelter_foot(shelter["cell"])
	director.world.on_ground = true
	var hold_frames: int = int(ceil(EcoPlayerBody.SLEEP_HOLD_S / EcoStepDirector.FRAME_DT)) + 2
	for i: int in hold_frames:
		director.player.curl_held = true
		director.world.on_ground = true
		director._check_shelter()
	assert_eq(director.mode, EcoStepDirector.MODE_ASLEEP, "curling for SLEEP_HOLD_S on a shelter tile sleeps")


func test_eco_save_service_write_log_only_records_s1_to_s5() -> void:
	var save: EcoSaveService = EcoSaveService.new()
	save.enabled = false
	for p: String in ["S1", "S2", "S3", "S4", "S5"]:
		assert_eq(save.write_file({}, p), OK)
	assert_eq(save.write_log, PackedStringArray(["S1", "S2", "S3", "S4", "S5"]))
	var before: int = save.write_log.size()
	save.write_file({}, "S6")
	assert_eq(save.write_log.size(), before, "an out-of-range point is not appended to write_log")


func test_eco_save_service_begin_writes_start_rung_once_when_axis_has_no_scale() -> void:
	var store: WorldState = WorldState.new()
	store.declare_owner(&"body", EcoWorldstateBridge.REQUESTER)
	var bridge: EcoWorldstateBridge = EcoWorldstateBridge.new()
	bridge.attach_world_store(store)
	var begun: Dictionary = EcoSaveService.begin(bridge, _index, _table, null)
	assert_true(begun["ok"])
	assert_true(bool(begun["wrote_start_rung"]))
	assert_eq((begun["world"] as EcoWorldState).body_rung, _index.start_rung)
	var axis: EcoBodyAxis = bridge.read_body()
	assert_true(axis.has_scale)
	assert_almost_eq(axis.scale_value, _table.ladder.value_of(_index.start_rung), 0.00001)
