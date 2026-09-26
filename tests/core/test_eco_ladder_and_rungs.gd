extends GutTest

const NAMES: Array[String] = ["speck", "hand", "doll"]
const SPEC_ROWS: Dictionary = {
	"speck": {"run_speed": 168.0, "accel": 1100.0, "jump_height": 156.0, "safe_fall_speed": 900.0, "max_climb": 24.0, "break_power": 0, "lethal_fall_px": 1889.0},
	"hand": {"run_speed": 156.0, "accel": 1012.0, "jump_height": 252.0, "safe_fall_speed": 1200.0, "max_climb": 24.0, "break_power": 2, "lethal_fall_px": 2414.0},
	"doll": {"run_speed": 168.0, "accel": 1100.0, "jump_height": 300.0, "safe_fall_speed": 1500.0, "max_climb": 24.0, "break_power": 4, "lethal_fall_px": 3004.0},
}
const TARGETS: Dictionary = {"speck": 96.0, "hand": 240.0, "doll": 384.0}
const SELF_ABILITIES: Dictionary = {
	"speck": [],
	"hand": [&"POISE", &"SHELL"],
	"doll": [&"POISE", &"LEAP", &"SHELL", &"CLAW"],
}
const DROP_OPENS: Dictionary = {1600.0: ["speck", "hand", "doll"], 2000.0: ["hand", "doll"], 2700.0: ["doll"], 4200.0: []}

var _ladder: EcoLadder
var _table: EcoRungTable


func before_all() -> void:
	var loaded: Dictionary = EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)
	assert_true(loaded["ok"], "ladder loads: " + str(loaded))
	_ladder = loaded["value"]
	var made: Dictionary = EcoRungTable.make(_ladder)
	assert_true(made["ok"], "rung table builds: " + str(made))
	_table = made["value"]


func test_eco_ladder_fallback_from_store_constant() -> void:
	var built: Dictionary = EcoLadder.from_store_values(AxisBody.SCALE_RUNGS)
	assert_true(built["ok"], str(built))
	var ladder: EcoLadder = built["value"]
	assert_eq(ladder.source, EcoLadder.SOURCE_STORE_CONSTANT)
	assert_eq(ladder.names, EcoLadder.FALLBACK_NAMES)
	assert_eq(ladder.values.size(), 6)
	for i: int in 6:
		assert_almost_eq(ladder.values[i], float(AxisBody.SCALE_RUNGS[i]), 0.000001)
	for i: int in 5:
		assert_almost_eq(ladder.edges[i], snappedf(sqrt(ladder.values[i] * ladder.values[i + 1]), 0.001), 0.000001)
	assert_eq(ladder.band_min[0], 0.0)
	assert_eq(ladder.band_max[5], 99.0)
	for i: int in range(1, 6):
		assert_almost_eq(ladder.band_min[i], ladder.band_max[i - 1], 0.000001)
	assert_eq(ladder.index_of("doll"), 2)
	assert_almost_eq(ladder.value_of("hand"), float(AxisBody.SCALE_RUNGS[1]), 0.000001)
	assert_eq(ladder.name_of(float(AxisBody.SCALE_RUNGS[2])), "doll")
	assert_eq(ladder.name_of(0.2), "")
	var bounds: Vector2 = ladder.band_bounds("hand")
	assert_almost_eq(bounds.x, ladder.edges[0], 0.000001)
	assert_almost_eq(bounds.y, ladder.edges[1], 0.000001)


func test_eco_ladder_invalid_is_honest_failure() -> void:
	var good: Dictionary = EcoLadder.from_store_values(AxisBody.SCALE_RUNGS)
	assert_true(good["ok"])
	var base: Dictionary = (good["value"] as EcoLadder).to_dictionary()
	var reversed: Dictionary = base.duplicate(true)
	(reversed["values"] as Array).reverse()
	var five_names: Dictionary = base.duplicate(true)
	(five_names["rungs"] as Array).pop_back()
	var non_positive: Dictionary = base.duplicate(true)
	(non_positive["values"] as Array)[0] = 0.0
	var wrong_version: Dictionary = base.duplicate(true)
	wrong_version["version"] = 2
	for broken: Dictionary in [reversed, five_names, non_positive, wrong_version]:
		var result: Dictionary = EcoLadder.from_dictionary(broken, EcoLadder.SOURCE_FILE)
		assert_false(result["ok"], "broken ladder refused: " + str(broken))
		assert_eq(result["reason"], EcoLadder.REASON_INVALID)
		assert_null(result["value"], "no fallback value on failure")


func test_eco_rung_table_matches_spec() -> void:
	assert_eq(_table.names(), NAMES)
	for rung_name: String in NAMES:
		var rung: EcoBodyRung = _table.by_name(rung_name)
		assert_not_null(rung, rung_name)
		var row: Dictionary = SPEC_ROWS[rung_name]
		assert_almost_eq(rung.run_speed, float(row["run_speed"]), 0.0001, rung_name + " run_speed")
		assert_almost_eq(rung.accel, float(row["accel"]), 0.0001, rung_name + " accel")
		assert_almost_eq(rung.jump_height, float(row["jump_height"]), 0.0001, rung_name + " jump_height")
		assert_almost_eq(rung.safe_fall_speed, float(row["safe_fall_speed"]), 0.0001, rung_name + " safe_fall_speed")
		assert_almost_eq(rung.max_climb, float(row["max_climb"]), 0.0001, rung_name + " max_climb")
		assert_eq(rung.break_power, int(row["break_power"]), rung_name + " break_power")
		assert_almost_eq(rung.lethal_fall_px(), float(row["lethal_fall_px"]), 1.0, rung_name + " lethal_fall_px")
		assert_almost_eq(rung.lethal_fall_speed(), rung.safe_fall_speed + EcoBodyRung.FALL_DAMAGE_DIVISOR, 0.0001)
		assert_almost_eq(rung.jump_speed(), sqrt(2.0 * EcoBodyRung.GRAVITY_BASE * rung.jump_height), 0.0001)
		assert_eq(rung.sprite_part_count, 18)
		assert_almost_eq(rung.scale_value, _ladder.value_of(rung_name), 0.000001)
	assert_null(_table.by_name("common"), "rungs outside this kit are refused")
	assert_null(_table.from_axis_value(0.2), "non-rung axis value is refused")
	assert_eq(_table.from_axis_value(_ladder.value_of("hand")).rung, "hand")


func test_eco_body_derive_matches_table() -> void:
	for band_name: String in NAMES:
		var band_value: float = _table.band_value(band_name)
		var target: float = TARGETS[band_name]
		for rung_name: String in NAMES:
			var rung: EcoBodyRung = _table.by_name(rung_name)
			var d: Dictionary = rung.derive(band_value, target)
			var q: float = rung.scale_value / band_value
			var h: float = q * target
			var label: String = "%s in %s" % [rung_name, band_name]
			assert_almost_eq(float(d["q"]), q, 0.000001, label + " q")
			assert_almost_eq(float(d["h_px"]), h, 0.001, label + " h_px")
			assert_almost_eq(float(d["w_px"]), EcoBodyRung.AASPECT_W * h, 0.001, label + " w_px")
			assert_almost_eq(float(d["mass"]), EcoBodyRung.MASS_DENSITY * pow(h / EcoBodyRung.MASS_REF_PX, 3.0), 0.001, label + " mass")
			assert_almost_eq(float(d["module_px"]), target / EcoBodyRung.FIT_TARGET, 0.001, label + " module_px")
			assert_almost_eq(float(d["use_range_px"]), EcoBodyRung.USE_RANGE_RATIO * h, 0.001, label + " use_range_px")
	var hand: EcoBodyRung = _table.by_name("hand")
	assert_true(hand.derive(0.0, 240.0).is_empty(), "band value 0 gives empty derive")
	var self_hand: Dictionary = hand.derive(_table.band_value("hand"), 240.0)
	assert_almost_eq(float(self_hand["w_px"]), 144.0, 0.001)
	assert_almost_eq(float(self_hand["mass"]), 6.5625, 0.001)


func test_eco_abilities_are_derived() -> void:
	assert_eq(EcoTrait.bit(EcoTrait.FLEX), 1)
	assert_eq(EcoTrait.bit(EcoTrait.POISE), 2)
	assert_eq(EcoTrait.bit(EcoTrait.LEAP), 4)
	assert_eq(EcoTrait.bit(EcoTrait.SHELL), 8)
	assert_eq(EcoTrait.bit(EcoTrait.CLAW), 16)
	for rung_name: String in NAMES:
		var mask: int = _table.abilities_of(rung_name, rung_name)
		var expected: int = 0
		for id: StringName in SELF_ABILITIES[rung_name]:
			expected |= EcoTrait.bit(id)
		assert_eq(mask, expected, rung_name + " abilities in own band")
	assert_true(EcoTrait.has(_table.abilities_of("hand", "doll"), EcoTrait.FLEX), "hand is FLEX in a doll room")
	assert_true(EcoTrait.has(_table.abilities_of("speck", "hand"), EcoTrait.FLEX), "speck is FLEX in a hand room")
	assert_false(EcoTrait.has(_table.abilities_of("doll", "speck"), EcoTrait.FLEX), "doll is never FLEX in a speck room")


func test_eco_poise_drop_requirements() -> void:
	for fall: float in DROP_OPENS.keys():
		var opened: Array[String] = []
		for rung_name: String in NAMES:
			if fall < _table.by_name(rung_name).lethal_fall_px():
				opened.append(rung_name)
		assert_eq(opened, Array(DROP_OPENS[fall], TYPE_STRING, "", null), "DROP %d opens" % int(fall))
	assert_eq(EcoPassageKind.DROP_FALLS.size(), 4)
	for fall: float in EcoPassageKind.DROP_FALLS:
		assert_true(DROP_OPENS.has(fall), "authorable DROP class %s is in the spec table" % fall)
