extends GutTest

const NAMES: Array[String] = ["speck", "hand", "doll"]
const TARGETS: Dictionary = {"speck": 96.0, "hand": 240.0, "doll": 384.0}
const GAP_MAX_STEP: Dictionary = {"SEAL": -9, "HAIRLINE": -2, "TIGHT": -1, "FIT": 0, "WIDE": 1}
const GAP_SQUEEZE_STEP: Dictionary = {"SEAL": 99, "HAIRLINE": -2, "TIGHT": -1, "FIT": 99, "WIDE": 1}
const STEP_OPENS: Dictionary = {40.0: ["speck", "hand", "doll"], 200.0: ["hand", "doll"], 290.0: ["doll"]}
const BREAK_OPENS: Dictionary = {1: ["hand", "doll"], 2: ["hand", "doll"], 3: ["doll"], 4: ["doll"]}
const PRESS_OPENS: Dictionary = {0.10: ["speck", "hand", "doll"], 0.80: ["hand", "doll"], 12.00: ["doll"]}

var _table: EcoRungTable


func before_all() -> void:
	var loaded: Dictionary = EcoLadder.load_or_fallback(AxisBody.SCALE_RUNGS)
	assert_true(loaded["ok"])
	var made: Dictionary = EcoRungTable.make(loaded["value"])
	assert_true(made["ok"])
	_table = made["value"]


func _spec(d: Dictionary) -> EcoPassageSpec:
	var base: Dictionary = {"id": "p_test", "cell": [1, 1], "span": [4, 4]}
	base.merge(d, true)
	var result: Dictionary = EcoPassageSpec.from_dictionary(base, "test")
	assert_true(result["ok"], "fixture parses: " + str(result))
	return result["value"]


func _reason(d: Dictionary) -> String:
	var base: Dictionary = {"id": "p_test", "cell": [1, 1], "span": [4, 4]}
	base.merge(d, true)
	return str(EcoPassageSpec.from_dictionary(base, "test")["reason"])


func _opens(spec: EcoPassageSpec, band_name: String) -> Array[String]:
	var opened: Array[String] = []
	for rung_name: String in NAMES:
		if EcoPassageResolver.passable(spec, _table.by_name(rung_name), _table.band_value(band_name), TARGETS[band_name]):
			opened.append(rung_name)
	return opened


func test_eco_passage_schema_closed() -> void:
	assert_eq(EcoPassageKind.NAMES, ["GAP", "STEP", "DROP", "BREAK", "PRESS"])
	assert_eq(EcoPassageKind.from_name("FLOOD"), -1)
	assert_eq(_reason({"kind": "FLOOD"}), "passage_kind_unknown")
	assert_eq(_reason({"kind": "gap", "width_class": "FIT"}), "passage_kind_unknown")
	assert_eq(_reason({"kind": ""}), "passage_kind_unknown")
	assert_eq(_reason({"kind": "GAP", "width_class": "FIT", "hp": 2}), "key_unknown")
	assert_eq(_reason({"kind": "GAP", "width_class": "FIT", "requires": ["SHELL"]}), "key_unknown")
	assert_eq(_reason({"kind": "GAP"}), "value_invalid")
	assert_eq(_reason({"kind": "GAP", "width_class": "NARROW"}), "value_invalid")
	assert_eq(_reason({"kind": "STEP", "height_px": 100.0}), "value_invalid")
	assert_eq(_reason({"kind": "DROP", "fall_px": 1500.0}), "value_invalid")
	assert_eq(_reason({"kind": "BREAK", "hp": 5}), "value_invalid")
	assert_eq(_reason({"kind": "BREAK", "hp": 1.5}), "value_invalid")
	assert_eq(_reason({"kind": "GAP", "width_class": "FIT", "span": [0, 1]}), "value_invalid")
	var gap: EcoPassageSpec = _spec({"kind": "GAP", "width_class": "WIDE", "drift": true})
	assert_eq(gap.kind, EcoPassageKind.GAP)
	assert_true(gap.drift)
	assert_eq(gap.cell, Vector2i(1, 1))
	assert_eq(gap.span, Vector2i(4, 4))
	for prop: Dictionary in gap.get_property_list():
		assert_ne(str(prop["name"]), "requires", "EcoPassageSpec has no requires field")


func test_eco_gap_class_table() -> void:
	assert_eq(EcoGapClass.ORDER, ["SEAL", "HAIRLINE", "TIGHT", "FIT", "WIDE"])
	var expected: Array[float] = [0.20, 0.35, 0.85, 2.60, 4.20]
	for i: int in 5:
		assert_almost_eq(EcoGapClass.multiplier(EcoGapClass.ORDER[i]), expected[i], 0.000001)
	assert_eq(EcoGapClass.multiplier("NARROW"), 0.0)
	assert_eq(EcoGapClass.narrower("WIDE"), "FIT")
	assert_eq(EcoGapClass.narrower("SEAL"), "SEAL")


func test_eco_passable_matches_spec() -> void:
	for band_name: String in NAMES:
		var band_index: int = NAMES.find(band_name)
		for width_class: String in EcoGapClass.ORDER:
			var spec: EcoPassageSpec = _spec({"kind": "GAP", "width_class": width_class})
			for rung_name: String in NAMES:
				var step: int = NAMES.find(rung_name) - band_index
				var rung: EcoBodyRung = _table.by_name(rung_name)
				var band_value: float = _table.band_value(band_name)
				var label: String = "%s %s in %s" % [width_class, rung_name, band_name]
				var passes: bool = step <= int(GAP_MAX_STEP[width_class])
				assert_eq(EcoPassageResolver.passable(spec, rung, band_value, TARGETS[band_name]), passes, label)
				var state: int = EcoPassageResolver.gap_state(spec, rung, band_value, TARGETS[band_name])
				if not passes:
					assert_eq(state, EcoPassageResolver.GAP_BLOCK, label + " blocks")
				elif step == int(GAP_SQUEEZE_STEP[width_class]):
					assert_eq(state, EcoPassageResolver.GAP_SQUEEZE, label + " squeezes")
				else:
					assert_eq(state, EcoPassageResolver.GAP_PASS, label + " passes freely")
		for height: float in STEP_OPENS.keys():
			var step_spec: EcoPassageSpec = _spec({"kind": "STEP", "height_px": height})
			assert_eq(_opens(step_spec, band_name), Array(STEP_OPENS[height], TYPE_STRING, "", null), "STEP %d in %s" % [int(height), band_name])
		for hp: int in BREAK_OPENS.keys():
			var wall: EcoPassageSpec = _spec({"kind": "BREAK", "hp": hp})
			assert_eq(_opens(wall, band_name), Array(BREAK_OPENS[hp], TYPE_STRING, "", null), "BREAK hp %d in %s" % [hp, band_name])


func test_eco_press_classes() -> void:
	assert_eq(_reason({"kind": "PRESS", "mass_required": 160.0}), "value_invalid")
	assert_eq(EcoPassageKind.PRESS_MASSES.size(), 3)
	for mass: float in PRESS_OPENS.keys():
		var plate: EcoPassageSpec = _spec({"kind": "PRESS", "mass_required": mass})
		for band_name: String in NAMES:
			assert_eq(_opens(plate, band_name), Array(PRESS_OPENS[mass], TYPE_STRING, "", null), "PRESS %s in %s" % [mass, band_name])


func test_eco_break_needs_power() -> void:
	for hp: int in range(1, 5):
		for rung_name: String in NAMES:
			var rung: EcoBodyRung = _table.by_name(rung_name)
			assert_eq(EcoPassageResolver.breaks_in_one_strike(rung, hp), rung.break_power >= hp, "%s vs hp %d" % [rung_name, hp])
