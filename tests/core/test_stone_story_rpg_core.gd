extends GutTest

## Kit 05 — 4속성 · 장비 정책 · 결정론 · 모듈 계약

var _tuning: StoneStoryTuning
var _content: StoneStoryContent


func before_all() -> void:
	_tuning = StoneStoryTuning.new()
	assert_eq(_tuning.load_all(), OK, "tuning loads")
	_content = StoneStoryContent.new()
	assert_true(_content.load_all(), "content loads: " + str(_content.errors))
	assert_eq(_content.errors.size(), 0, "no content errors")


func _fresh_run() -> Dictionary:
	return StoneStoryRunState.fresh(_tuning, _content.get_def("class", "class_ashbound"))


func _fresh_p() -> Dictionary:
	return _fresh_run()["player"]


func _full_stats(v: int) -> Dictionary:
	return {
		"vitality": v, "focus": v, "grit": v, "toughness": v,
		"strength": v, "dexterity": v, "intellect": v, "devotion": v, "instinct": v,
	}


# --- A. 4-속성 ---------------------------------------------------

func test_a1_limits() -> void:
	assert_eq(StoneStoryAttributes.clamp_limbs(0), 1, "A1 limbs floor")
	assert_eq(StoneStoryAttributes.clamp_limbs(99), 12, "A1 limbs ceiling")
	assert_eq(StoneStoryAttributes.clamp_scalar(-5.0), 0.0, "A1 scalar floor")
	assert_eq(StoneStoryAttributes.clamp_scalar(50.0), 10.0, "A1 scalar ceiling")


func test_a2_validity_gate() -> void:
	assert_true(StoneStoryAttributes.is_valid(
			{"limbs": 4, "surprise": 3.0, "wrongness": 2.0, "roundness": 5.0}), "A2 valid")
	assert_false(StoneStoryAttributes.is_valid(
			{"limbs": 40, "surprise": 3.0, "wrongness": 2.0, "roundness": 5.0}), "A2 limbs 40 rejected")
	assert_false(StoneStoryAttributes.is_valid(
			{"limbs": 4, "surprise": 33.0, "wrongness": 2.0, "roundness": 5.0}), "A2 surprise 33 rejected")


func test_a3_cycle_is_closed_and_complete() -> void:
	assert_eq(StoneStoryAttributes.CYCLE.size(), 4, "A3 cycle has 4 links")
	assert_true(StoneStoryAttributes.beats(&"limbs", &"wrongness"), "A3 limbs > wrongness")
	assert_true(StoneStoryAttributes.beats(&"wrongness", &"roundness"), "A3 wrongness > roundness")
	assert_true(StoneStoryAttributes.beats(&"roundness", &"surprise"), "A3 roundness > surprise")
	assert_true(StoneStoryAttributes.beats(&"surprise", &"limbs"), "A3 surprise wraps to limbs")
	assert_false(StoneStoryAttributes.beats(&"limbs", &"surprise"), "A3 no shortcut link")


func test_a4_affinity_mult() -> void:
	var atk: Dictionary = {"affinity_attr": "limbs"}
	var win: Dictionary = StoneStoryAttributes.affinity(atk, {"affinity_attr": "wrongness"})
	var lose: Dictionary = StoneStoryAttributes.affinity(atk, {"affinity_attr": "roundness"})
	var tie: Dictionary = StoneStoryAttributes.affinity(atk, {"affinity_attr": "limbs"})
	assert_almost_eq(win["mult"], 1.50, 0.001, "A4 win 1.5x")
	assert_almost_eq(lose["mult"], 0.75, 0.001, "A4 lose 0.75x")
	assert_almost_eq(tie["mult"], 1.00, 0.001, "A4 tie 1.0x")


func test_a5_surprise_in_range_and_deterministic() -> void:
	var stream: StoneStoryRng = StoneStoryCore.stream(42, StoneStoryCore.TAG_SURPRISE)
	for spec in [
		{"size_units": 8.0, "width_units": 8.0, "height_units": 8.0, "motion_events": 2},
		{"size_units": 200.0, "width_units": 90.0, "height_units": 20.0, "motion_events": 9},
		{"size_units": 1.0, "width_units": 1.0, "height_units": 60.0, "motion_events": 0},
	]:
		var base: Dictionary = {"roundness": 3.0}
		var a: float = StoneStoryAttributes.surprise(base, spec, stream)
		var b: float = StoneStoryAttributes.surprise(base, spec, stream)
		assert_true(a >= 0.0 and a <= 10.0, "A5 surprise in 0..10")
		assert_eq(a, b, "A5 deterministic")


func test_a6_tiny_can_still_be_surprising() -> void:
	## 크기가 가장 큰 상관관계지만 약하다. 아주 작은 개체가 아주 놀랍게 나올 수 있어야 한다.
	## 미스터리 값이니 특정 시드를 고정하지 않는다. 분포로 판정한다.
	var wild_shape: Dictionary = {"size_units": 2.0, "width_units": 2.0, "height_units": 2.0,
			"motion_events": 12}
	var calm_shape: Dictionary = {"size_units": 2.0, "width_units": 2.0, "height_units": 2.0,
			"motion_events": 0}
	var wins: int = 0
	var peak: int = 0
	for seed_value in 40:
		var st: StoneStoryRng = StoneStoryCore.stream(seed_value, StoneStoryCore.TAG_SURPRISE)
		var wild: float = StoneStoryAttributes.surprise({"roundness": 0.0}, wild_shape, st)
		var calm: float = StoneStoryAttributes.surprise({"roundness": 10.0}, calm_shape, st)
		if wild > calm:
			wins += 1
		peak = maxi(peak, int(wild))
	assert_gt(wins, 32, "A6 wild tiny beats calm tiny on most seeds")
	assert_gte(peak, 9, "A6 a tiny entity can reach very high surprise")


func test_a7_not_invertible_from_size_alone() -> void:
	## 크기만으로 역산되지 않는다. 같은 크기가 다른 놀랍다를 갖는다.
	var stream: StoneStoryRng = StoneStoryCore.stream(11, StoneStoryCore.TAG_SURPRISE)
	var shape: Dictionary = {"size_units": 20.0, "width_units": 20.0, "height_units": 20.0, "motion_events": 4}
	var a: float = StoneStoryAttributes.surprise({"roundness": 0.0}, shape, stream)
	var b: float = StoneStoryAttributes.surprise({"roundness": 10.0}, shape, stream)
	assert_ne(a, b, "A7 same size, different roundness -> different surprise")


func test_a8_gear_deltas_stack_and_clamp() -> void:
	var gear: Array = [
		{"attr_delta": {"surprise": 3, "roundness": -1}},
		{"attr_delta": {"surprise": 4, "roundness": 4}},
	]
	var out: Dictionary = StoneStoryAttributes.resolve(
			{"limbs": 4, "surprise": 5.0, "wrongness": 1.0, "roundness": 2.0}, gear)
	assert_eq(out["surprise"], 10.0, "A8 surprise 5+3+4 clamped to 10")
	assert_eq(out["roundness"], 5.0, "A8 roundness 2-1+4")
	assert_eq(int(out["limbs"]), 4, "A8 limbs untouched by scalar deltas")


func test_a9_actions_per_turn_from_limbs() -> void:
	var p: Dictionary = StoneStoryGearPolicy.base()
	assert_eq(StoneStoryAttributes.actions_per_turn({"limbs": 1}, p, _tuning), 1, "A9 limbs 1 -> 1 action")
	assert_eq(StoneStoryAttributes.actions_per_turn({"limbs": 12}, p, _tuning), 3, "A9 limbs 12 -> 3 actions")
	var p2: Dictionary = StoneStoryGearPolicy.base()
	p2["actions_per_turn_mod"] = 1
	assert_eq(StoneStoryAttributes.actions_per_turn({"limbs": 12}, p2, _tuning), 4, "A9 gear adds one, clamped to 4")


func test_a10_evade_and_crit_from_attributes() -> void:
	var slow: float = StoneStoryAttributes.evade_chance({"roundness": 0.0}, _tuning)
	var round: float = StoneStoryAttributes.evade_chance({"roundness": 10.0}, _tuning)
	assert_true(round > slow, "A10 roundness raises evade")
	var dull: float = StoneStoryAttributes.crit_chance({"wrongness": 0.0}, _tuning)
	var wrong: float = StoneStoryAttributes.crit_chance({"wrongness": 10.0}, _tuning)
	assert_true(wrong > dull, "A10 wrongness raises crit")


# --- P. 장비 정책 -------------------------------------------------

func test_p1_defaults() -> void:
	var p: Dictionary = StoneStoryGearPolicy.base()
	assert_eq(p["open_with"], "attack", "P1 default open")
	assert_eq(p["focus_priority"], "nearest", "P1 default focus")
	assert_false(bool(p["never_retreat"]), "P1 no retreat by default")


func test_p2_deltas_combine_without_runaway() -> void:
	var gear: Array = [
		{"policy_delta": {"evade_hp_max": 0.5}},
		{"policy_delta": {"evade_hp_max": 0.9}},
		{"policy_delta": {"actions_per_turn_mod": 1}},
		{"policy_delta": {"actions_per_turn_mod": 1}},
		{"policy_delta": {"actions_per_turn_mod": 1}},
	]
	var p: Dictionary = StoneStoryGearPolicy.resolve(gear)
	assert_eq(float(p["evade_hp_max"]), 0.9, "P2 numeric keys take max, not sum")
	assert_eq(int(p["actions_per_turn_mod"]), 3, "P2 additive keys do sum")


func test_p3_booleans_or_and_retreat_guard() -> void:
	var gear: Array = [{"policy_delta": {"always_guard": true}}, {"policy_delta": {"never_retreat": true, "retreat_hp_below": 0.5}}]
	var p: Dictionary = StoneStoryGearPolicy.resolve(gear)
	assert_true(bool(p["always_guard"]), "P3 boolean OR")
	assert_eq(float(p["retreat_hp_below"]), 0.0, "P3 never_retreat zeroes retreat")


func test_p4_retreat_cannot_exceed_evade_cap() -> void:
	var p: Dictionary = StoneStoryGearPolicy.resolve(
			[{"policy_delta": {"retreat_hp_below": 0.9, "evade_hp_max": 0.4}}])
	assert_true(float(p["retreat_hp_below"]) <= float(p["evade_hp_max"]), "P4 retreat clamped down")


func test_p5_hooks() -> void:
	var p: Dictionary = StoneStoryGearPolicy.policy_hook(
			StoneStoryGearPolicy.base(), &"hook_never_turn_back")
	assert_true(bool(p["never_retreat"]), "P5 hook sets never_retreat")
	var p2: Dictionary = StoneStoryGearPolicy.policy_hook(
			StoneStoryGearPolicy.base(), &"hook_body_wall")
	assert_true(bool(p2["always_guard"]), "P5 hook body wall guards")
	assert_eq(float(p2["guard_min_hp"]), 0.99, "P5 hook body wall guard threshold")


func test_p6_every_authored_policy_validates() -> void:
	for id in _content.ids("item"):
		var it: Dictionary = _content.item(str(id))
		var errs: Array[String] = StoneStoryGearPolicy.validate_content(
				it.get("policy_delta", {}), str(id))
		assert_eq(errs, [], "P6 policy valid for " + str(id))


func test_p7_gear_changes_the_ai() -> void:
	## 장비가 AI 를 바꾸는 것이 이 Kit 의 핵심이다. 같은 적을 다른 장비로 보낸다.
	var p: Dictionary = _fresh_p()
	var enc: Dictionary = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 5, 77, p)
	var aggressive: Dictionary = StoneStoryPlayerAI.decide(
			{"player": p, "encounter": enc, "run_seed": 77}, enc, _content, _tuning)
	p["gear"].append({"item_id": "item_board_shield", "attr_delta": {}, "policy_delta": {"always_guard": true}})
	var guarded: Dictionary = StoneStoryPlayerAI.decide(
			{"player": p, "encounter": enc, "run_seed": 77}, enc, _content, _tuning)
	assert_ne(str(aggressive["stance"]), str(guarded["stance"]),
			"P7 equipping a guard shield changes AI stance")


# --- D. 결정론 ----------------------------------------------------

func test_d1_same_inputs_same_encounter() -> void:
	var p: Dictionary = _fresh_p()
	var a: Dictionary = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 5, 12345, p)
	var b: Dictionary = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 5, 12345, p)
	assert_eq(JSON.stringify(a["foes"]), JSON.stringify(b["foes"]), "D1 foes identical")
	assert_eq(a["boss"]["foe_id"], b["boss"]["foe_id"], "D1 boss identical")


func test_d3_seed_changes_layout() -> void:
	var p: Dictionary = _fresh_p()
	var a: Dictionary = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 5, 1, p)
	var b: Dictionary = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 5, 2, p)
	assert_ne(JSON.stringify(a["foes"]), JSON.stringify(b["foes"]), "D3 different seed")


func test_d4_star_changes_numbers() -> void:
	var p: Dictionary = _fresh_p()
	var low: Dictionary = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 1, 9, p)
	var high: Dictionary = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 20, 9, p)
	assert_eq(low["band_id"], "b1", "D4 1* is b1")
	assert_eq(high["band_id"], "b5", "D4 20* is b5")
	assert_true(int(high["foes"][0]["hp_max"]) > int(low["foes"][0]["hp_max"]), "D4 higher star, higher hp")


func test_d7_rng_pure_and_tag_separated() -> void:
	var a: StoneStoryRng = StoneStoryCore.stream(999, StoneStoryCore.TAG_SIM)
	assert_true(a.at(0) >= 0, "D7 stream draws")
	assert_eq(a.at(0), StoneStoryCore.stream(999, StoneStoryCore.TAG_SIM).at(0), "D7 reproducible")
	assert_ne(StoneStoryCore.stream(999, "a").at(0), StoneStoryCore.stream(999, "b").at(0), "D7 tag matters")


# --- C. 전투 ------------------------------------------------------

func test_c1_scalar_damage_only() -> void:
	var it: Dictionary = _content.item("item_rusted_sword")
	assert_true(it["damage"] is int or it["damage"] is float, "C1 damage is a scalar")
	assert_false(it["damage"] is Dictionary, "C1 damage is not per-type")


func test_c2_softcap_continuous() -> void:
	var e45: float = StoneStoryCore.effective(45, _tuning.cf("knee_a"), _tuning.cf("knee_b"),
			_tuning.cf("slope_b"), _tuning.cf("slope_c"))
	var e46: float = StoneStoryCore.effective(46, _tuning.cf("knee_a"), _tuning.cf("knee_b"),
			_tuning.cf("slope_b"), _tuning.cf("slope_c"))
	assert_almost_eq(e46 - e45, _tuning.cf("slope_c"), 0.0001, "C2 no discontinuity at knee_b")


func test_c3_normalizer() -> void:
	var weapon: Dictionary = _content.item("item_rusted_sword")
	var eff: Dictionary = StoneStoryCombat.requirement_report(weapon, _full_stats(45),
			_tuning.cf("two_hand_requirement_divisor"))["effective"]
	assert_almost_eq(StoneStoryCombat.scaling_ratio(weapon, eff, _tuning), 1.0, 0.01, "C3 ratio 1.0 at knee_b")


func test_c6_requirement_gate() -> void:
	var weapon: Dictionary = _content.item("item_ash_spear")
	var weak: Dictionary = StoneStoryCombat.requirement_report(weapon, _full_stats(5), 1.0)
	var strong: Dictionary = StoneStoryCombat.requirement_report(weapon, _full_stats(60), 1.0)
	assert_false(bool(weak["met"]), "C6 fails at low stats")
	assert_true(bool(strong["met"]), "C6 passes at high stats")


func test_c4_two_handed_halves_requirement() -> void:
	var weapon: Dictionary = _content.item("item_ash_spear")
	var stats: Dictionary = _full_stats(12)
	assert_false(bool(StoneStoryCombat.requirement_report(weapon, stats, 1.0)["met"]), "C4 one-handed fails")
	assert_true(bool(StoneStoryCombat.requirement_report(weapon, stats, 2.0)["met"]), "C4 two-handed passes")


func test_c13_upgrade_does_not_bypass_softcap() -> void:
	var weapon: Dictionary = _content.item("item_rusted_sword")
	var a: Dictionary = StoneStoryContent.make_item_state("item_rusted_sword")
	a["upgrade_level"] = 10
	var b: Dictionary = StoneStoryContent.make_item_state("item_rusted_sword")
	var weak: float = StoneStoryCombat.damage_pre(weapon, a, _content.db["affix"],
			StoneStoryCombat.requirement_report(weapon, _full_stats(0), 1.0), _tuning)["value"]
	var strong: float = StoneStoryCombat.damage_pre(weapon, b, _content.db["affix"],
			StoneStoryCombat.requirement_report(weapon, _full_stats(45), 1.0), _tuning)["value"]
	assert_true(weak < strong, "C13 0-stat +10 is weaker than 45-stat +0")


func test_c20_scaling_sum_within_one() -> void:
	for id in _content.ids("item"):
		var it: Dictionary = _content.item(str(id))
		var sum: float = 0.0
		for s in it.get("scaling", {}):
			sum += float(it["scaling"][s])
		assert_true(sum <= 1.0001, "C20 scaling sum <= 1 for " + str(id))


func test_c21_no_damage_type_dicts_anywhere() -> void:
	for kind in ["item", "foe", "boss", "miniboss", "attack"]:
		for id in _content.db[kind]:
			var d: Dictionary = _content.get_def(kind, str(id))
			for key in ["damage", "defense", "resistances", "status_build", "status_add"]:
				assert_false(d.get(key) is Dictionary and (key == "damage" or key == "defense"),
						"C21 no per-type dict for " + str(kind) + "/" + str(id) + "/" + str(key))


# --- S. 상태 기계 -------------------------------------------------

func test_s2_zero_frame_passes_through() -> void:
	var def: Dictionary = _content.get_def("foe", "foe_husk_scrapper")
	var foe: Dictionary = StoneStoryFoeMachine.make_foe(def, _tuning, 5, 1)
	foe["behavior"] = 1
	foe["state_id"] = "cooldown"
	foe["state_time"] = 0
	StoneStoryFoeMachine.step(foe, def, StoneStoryCore.stream(1, StoneStoryCore.TAG_SIM), 1)
	assert_ne(str(foe["state_id"]), "cooldown", "S2 zero-frame state transitioned")


func test_s9_wake_gate() -> void:
	var def: Dictionary = _content.get_def("foe", "foe_husk_scrapper")
	var foe: Dictionary = StoneStoryFoeMachine.make_foe(def, _tuning, 5, 1)
	assert_eq(str(foe["state_id"]), "awaken", "S9 spawns asleep")
	foe["dist"] = 999
	StoneStoryFoeMachine.move_step(foe, {"x": 0, "y": 0})
	assert_eq(str(foe["state_id"]), "awaken", "S9 stays asleep when far")
	foe["dist"] = 1
	StoneStoryFoeMachine.move_step(foe, {"x": 0, "y": 0})
	assert_eq(str(foe["state_id"]), "approach", "S9 wakes when close")


func test_s14_zero_lifetime_projectile_hits() -> void:
	assert_true(StoneStoryFoeMachine.step_projectile(
			{"lifetime": 0, "pos": {"x": 0, "y": 0}, "vel": {"x": 0, "y": 0}}, {"x": 1, "y": 0}, 3), "S14 immediate")


func test_s20_foe_attributes_derived_surprise() -> void:
	var def: Dictionary = _content.get_def("foe", "foe_ash_sprite")
	var a: Dictionary = StoneStoryFoeMachine.make_foe(def, _tuning, 5, 1)
	assert_true(StoneStoryAttributes.is_valid(a["attributes"]), "S20 derived attributes valid")
	assert_eq(int(a["attributes"]["limbs"]), 6, "S20 limbs from content")
	assert_eq(int(a["attributes"]["roundness"]), 7, "S20 roundness authored verbatim")
	# 놀랍다만 미스터리여야 한다. 같은 개체라도 시드로 값이 퍼져야 한다.
	var values: Array[float] = []
	for seed_value in 24:
		values.append(float(StoneStoryFoeMachine.make_foe(def, _tuning, 5, seed_value)["attributes"]["surprise"]))
	var lo: float = values.min()
	var hi: float = values.max()
	assert_true(hi - lo >= 2.0, "S20 surprise spreads across seeds (range %s..%s)" % [lo, hi])


# --- G. 밴드 -----------------------------------------------------

func test_g1_bands() -> void:
	assert_eq(str(_tuning.band_of(1)["id"]), "b1", "G1 1* -> b1")
	assert_eq(str(_tuning.band_of(20)["id"]), "b5", "G1 20* -> b5")


func test_g3_band_boundary_is_a_step() -> void:
	var b2: Array = _tuning.star_bands["bands"]["b2"]
	var b3: Array = _tuning.star_bands["bands"]["b3"]
	assert_ne(float(b2[1]), float(b3[0]), "G3 discontinuity at boundary")


func test_g14_phase_index_zero_based() -> void:
	var enc: Dictionary = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 5, 3, _fresh_p())
	assert_eq(int(enc["phase_index"]), 0, "G14 phase_index starts at 0")
	assert_true(enc["chain"][0].has("hp_threshold"), "G14 thresholds authored")


# --- S2. 세이브 ----------------------------------------------------

func test_s2_round_trip() -> void:
	var s: Dictionary = _fresh_run()
	s["star_level"] = 7
	s["run_seed"] = 4242
	s["region_id"] = "region_hollow_cistern"
	s["encounter"] = StoneStoryEncounter.build(_content, _tuning, "region_hollow_cistern", 7, 4242, s["player"])
	var back: Dictionary = StoneStoryRunState.from_dict(
			StoneStoryRunState.to_dict(s), _tuning)
	assert_eq(str(back["result"]), "restored", "S2 restored")
	assert_eq(JSON.stringify(back["state"]), JSON.stringify(s), "S2 round trip identical")


func test_s2_stale_rejected() -> void:
	var s: Dictionary = _fresh_run()
	var d: Dictionary = StoneStoryRunState.to_dict(s)
	d["tuning_signature"] = "deadbeef"
	assert_eq(str(StoneStoryRunState.from_dict(d, _tuning)["result"]), "reset_tuning", "S2 tuning mismatch")
	d = StoneStoryRunState.to_dict(s)
	d["star_level"] = 99
	assert_eq(str(StoneStoryRunState.from_dict(d, _tuning)["result"]), "reset_star", "S2 bad star")


func test_s3_chest_cap() -> void:
	var p: Dictionary = _fresh_p()
	assert_true(StoneStoryRunState.chest_cap(9, _tuning) > StoneStoryRunState.chest_cap(1, _tuning), "S3 grows")
	for i in 200:
		StoneStoryRunState.add_chest(p, StoneStoryRunState.make_chest("common", i), _tuning)
	assert_eq(p["chests"].size(), StoneStoryRunState.chest_cap(1, _tuning), "S3 cap enforced")


func test_s4_xp_curve() -> void:
	var p: Dictionary = _fresh_p()
	assert_eq(StoneStoryRunState.gain_xp(p, _tuning.xp_to_next(1), _tuning), 1, "S4 level gained")
	assert_eq(int(p["stat_points"]), 1, "S4 stat point granted")


# --- M. 모듈 계약 -------------------------------------------------

func test_m_module_boots_and_ticks() -> void:
	var packed: PackedScene = load("res://modules/stone_story_rpg/entry.tscn") as PackedScene
	assert_ne(packed, null, "M entry scene loads")
	var inst: Node = packed.instantiate()
	add_child_autofree(inst)
	await get_tree().process_frame
	assert_eq((inst.get("content") as StoneStoryContent).errors, [], "M no content errors")
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = true
	inst.call("enter", ctx)
	await get_tree().process_frame
	var st: Dictionary = inst.get("state")
	assert_false(st.is_empty(), "M state built")
	assert_eq(str(st["region_id"]), "region_under_sign", "M starts at hub")
	var t0: int = int(st["tick"])
	for i in 30:
		await get_tree().process_frame
	assert_gt(int((inst.get("state") as Dictionary)["tick"]), t0, "M ticks advance")
	var saved: Dictionary = inst.call("save_state")
	assert_eq(str(saved["state_format"]), "ssr_run_v1", "M save format")
	assert_eq(JSON.stringify(saved), JSON.stringify(inst.call("save_state")), "M save stable")
	inst.call("exit")


func test_m_input_disabled_blocks_commands() -> void:
	var inst: Node = (load("res://modules/stone_story_rpg/entry.tscn") as PackedScene).instantiate()
	add_child_autofree(inst)
	await get_tree().process_frame
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = false
	inst.call("enter", ctx)
	await get_tree().process_frame
	assert_false(bool(inst.call("execute_command", &"ssr_next_region", {})), "M blocked while disabled")
	inst.call("exit")


func test_m_lobby_is_the_only_control_surface() -> void:
	var inst: Node = (load("res://modules/stone_story_rpg/entry.tscn") as PackedScene).instantiate()
	add_child_autofree(inst)
	await get_tree().process_frame
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = true
	inst.call("enter", ctx)
	await get_tree().process_frame
	assert_true(bool(inst.call("execute_command", &"ssr_equip", {"item_id": "item_board_shield"})),
			"M lobby can equip")
	assert_false(bool(inst.call("execute_command", &"ssr_equip", {"item_id": "item_nope"})),
			"M rejects unknown item")
	assert_true(bool(inst.call("execute_command", &"ssr_set_star", {"star": 12})), "M lobby can set star")
	assert_false(bool(inst.call("execute_command", &"ssr_set_star", {"star": 99})), "M rejects out-of-range star")
	inst.call("exit")


func test_m_death_keeps_progress() -> void:
	## 다크소울 2차 자료: 죽음 페널티 0. 자원/레벨/진행이 남아야 한다.
	var inst: Node = (load("res://modules/stone_story_rpg/entry.tscn") as PackedScene).instantiate()
	add_child_autofree(inst)
	await get_tree().process_frame
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = true
	inst.call("enter", ctx)
	await get_tree().process_frame
	var s: Dictionary = inst.get("state")
	s["world"]["currency"] = 500
	s["player"]["level"] = 5
	s["player"]["inventory"]["materials"]["mat_ash"] = 40
	s["player"]["hp"] = 0
	inst.call("_on_death")
	await get_tree().process_frame
	var after: Dictionary = inst.get("state")
	assert_eq(int(after["world"]["currency"]), 500, "M currency survives death")
	assert_eq(int(after["player"]["level"]), 5, "M level survives death")
	assert_eq(int(after["player"]["inventory"]["materials"]["mat_ash"]), 40, "M materials survive death")
	assert_gt(int(after["player"]["hp"]), 0, "M hp restored after death")
	assert_false(after["encounter"].is_empty(), "M encounter rebuilt after death")
	inst.call("exit")


# --- P. 렌더 ------------------------------------------------------

func test_p2_integer_scale_factors_960x640() -> void:
	assert_eq(maxi(1, floori(minf(1280.0 / 960.0, 720.0 / 640.0))), 1, "P 1280x720 is 1x")
	assert_eq(maxi(1, floori(minf(1920.0 / 960.0, 1080.0 / 640.0))), 1, "P 1920x1080 is 1x")
	assert_eq(maxi(1, floori(minf(1920.0 / 960.0, 1280.0 / 640.0))), 2, "P 1920x1280 is 2x")
	assert_eq(maxi(1, floori(minf(2560.0 / 960.0, 1440.0 / 640.0))), 2, "P 2560x1440 is 2x")


func test_p6_no_image_assets() -> void:
	var images: Array[String] = ["png", "jpg", "jpeg", "webp", "bmp", "svg", "tga", "dds", "exr", "ktx"]
	var offenders: Array[String] = []
	for sub in ["", "content/", "content/tuning/", "presentation/", "systems/", "domain/"]:
		var dir := DirAccess.open("res://modules/stone_story_rpg/" + sub)
		if dir == null:
			continue
		for f in dir.get_files():
			var lower: String = f.to_lower()
			for ext in images:
				if lower.ends_with("." + String(ext)):
					offenders.append(sub + f)
	assert_eq(offenders, [], "P no image assets anywhere in the module")
