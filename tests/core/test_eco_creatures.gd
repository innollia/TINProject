extends GutTest

var _table: EcoRungTable
var _index: EcoContentIndex


func before_all() -> void:
	_table = EcoRungTable.make(EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)["value"])["value"]
	_index = EcoRegionLoader.load_all(_table)["value"]


func test_eco_all_ids_are_deterministic() -> void:
	var m1: EcoCreatureManager = EcoCreatureManager.make(_index, _table)
	var m2: EcoCreatureManager = EcoCreatureManager.make(_index, _table)
	assert_eq(m1.all_ids(), m2.all_ids(), "two managers over the same content produce the same id list")


func test_eco_all_ids_are_unique() -> void:
	var m: EcoCreatureManager = EcoCreatureManager.make(_index, _table)
	var ids: Array = m.all_ids()
	var seen: Dictionary = {}
	for id: Variant in ids:
		assert_false(seen.has(id), "duplicate id %s" % str(id))
		seen[id] = true
	assert_gt(ids.size(), 0, "content has at least one den or tethered slot")


func test_eco_den_refill_chance_by_cause() -> void:
	assert_almost_eq(EcoDenSystem.refill_chance("player"), 1.0 / 3.0, 0.0001)
	assert_almost_eq(EcoDenSystem.refill_chance("creature"), 1.0, 0.0001)
	assert_almost_eq(EcoDenSystem.refill_chance("hazard"), 1.0, 0.0001)
	assert_almost_eq(EcoDenSystem.refill_chance("buried"), 1.0, 0.0001)
	assert_almost_eq(EcoDenSystem.refill_chance("crush"), 1.0, 0.0001)
	assert_almost_eq(EcoDenSystem.refill_chance("unknown_cause"), 0.0, 0.0001)


func test_eco_den_roll_is_deterministic_by_seed_and_rolls() -> void:
	var a: bool = EcoDenSystem.roll(12345, "den_x_0", 0, 0.5)
	var b: bool = EcoDenSystem.roll(12345, "den_x_0", 0, 0.5)
	assert_eq(a, b, "same seed/id/rolls/p reproduces the same result")
	var different_rolls: bool = EcoDenSystem.roll(12345, "den_x_0", 1, 0.5)
	# not asserting the value differs (RNG could coincide) — only that the call succeeds deterministically
	assert_eq(EcoDenSystem.roll(12345, "den_x_0", 1, 0.5), different_rolls)


func test_eco_den_roll_probability_bounds() -> void:
	assert_false(EcoDenSystem.roll(1, "den_zero", 0, 0.0), "p=0 never rolls true")
	assert_true(EcoDenSystem.roll(1, "den_one", 0, 1.0), "p=1 always rolls true")


func test_eco_social_table_has_fifteen_cells() -> void:
	assert_eq(EcoSocialTable.cell_count(), 15, "5 archetypes x 3 rung columns")
	assert_eq(EcoSocialTable.TABLE.size(), 5)
	for axis_name: String in EcoSocialTable.TABLE.keys():
		assert_eq((EcoSocialTable.TABLE[axis_name] as Array).size(), 3, "%s row has 3 rung columns" % axis_name)


func test_eco_creature_state_has_eleven_values() -> void:
	assert_eq(EcoCreature.STATE_COUNT, 11)
	var names: Array = ["IDLE", "PATROL", "ALERT", "APPROACH", "STRIKE", "RECOVER", "RETURN", "FLEE", "GRAZE", "SLEEP", "DEAD"]
	assert_eq(names.size(), 11)
	assert_eq(EcoCreature.State.IDLE, 0)
	assert_eq(EcoCreature.State.DEAD, 10)


func test_eco_ai_sense_takes_creature_player_and_environment_args() -> void:
	var c: EcoCreature = EcoCreature.new()
	c.archetype = EcoCreatureArchetype.from_dictionary({"sense_radius_px": 200.0, "hearing_radius_px": 100.0, "fov_deg": 120.0})
	var s: Dictionary = EcoAISense.sense(c, Vector2(50.0, 0.0), 0.0, false, null)
	assert_true(s.has("seen"))
	assert_true(s.has("heard"))
	assert_true(s.has("detected"))
	assert_true(s.has("distance"))
	assert_almost_eq(float(s["distance"]), 50.0, 0.01)
