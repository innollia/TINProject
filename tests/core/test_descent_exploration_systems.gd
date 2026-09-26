extends GutTest

const H: float = 1.0 / 120.0


func _layer(extra: Dictionary) -> Dictionary:
	var base: Dictionary = {
		"id": "stratum_test",
		"index": 0,
		"bounds": {"width": 640, "height": 1024},
		"spawn": {"position": [320, 96], "facing": 1},
		"solids": [],
		"currents": [],
		"membranes": [],
		"routes": [],
		"sites": [],
		"matter": [],
		"anchors": [],
		"fauna": [],
	}
	for key: Variant in extra:
		base[key] = extra[key]
	return base


func _runtime(extra: Dictionary = {}, state: DescentState = null) -> StratumRuntime:
	return StratumRuntime.build(_layer(extra), state)


func _state_at(at: Vector2, mass: int = 0) -> DescentState:
	var state := DescentState.new_state()
	state.stratum_id = "stratum_test"
	state.position = at
	for index: int in mass:
		state.pick_up(MatterItem.create("weight_%d" % index, 1, "weigh", "stone", "stratum_test"))
	return state


func _run(state: DescentState, runtime: StratumRuntime, intent: RunIntent, seconds: float, body: BodyRead = null) -> void:
	var steps: int = int(round(seconds / H))
	for _step: int in steps:
		PlayerMotion.step(state, intent, state.mass, H)
		DescentCollision.resolve(state, runtime, H)
		HazardField.apply(state, runtime, H, body)


func _floor_runtime() -> StratumRuntime:
	var loader := DescentContentLoader.new()
	loader.load_dir()
	return StratumRuntime.build(loader.get_stratum("stratum_floor"))


func test_idle_body_sinks_at_the_sink_acceleration() -> void:
	var state := _state_at(Vector2(320, 300))
	var idle := RunIntent.new()
	for _step: int in 120:
		PlayerMotion.step(state, idle, state.mass, H)
	assert_gt(state.velocity.y, 20.0)
	assert_almost_eq(state.velocity.y, PlayerMotion.SINK_ACCEL * 1.0, 0.01)


func test_holding_up_rises_past_sixty_within_half_a_second() -> void:
	var state := _state_at(Vector2(320, 600))
	var rising := RunIntent.create(true)
	for _step: int in 60:
		PlayerMotion.step(state, rising, state.mass, H)
	assert_lt(state.velocity.y, -60.0)


func test_heavier_body_sinks_strictly_farther() -> void:
	var light := _state_at(Vector2(320, 100), 0)
	var heavy := _state_at(Vector2(320, 100), 4)
	var open := _runtime()
	_run(light, open, RunIntent.new(), 3.0)
	_run(heavy, open, RunIntent.new(), 3.0)
	assert_gt(heavy.position.y - 100.0, light.position.y - 100.0)


func test_surge_overwrites_velocity_with_the_mass_speed() -> void:
	var light := _state_at(Vector2(320, 300), 0)
	light.velocity = Vector2(10.0, 40.0)
	assert_true(PlayerMotion.step(light, RunIntent.create(false, false, false, false, true), light.mass, H))
	assert_almost_eq(light.velocity.x, 168.0, 0.001)
	assert_almost_eq(light.velocity.y, 0.0, 0.001)
	var heavy := _state_at(Vector2(320, 300), 4)
	heavy.velocity = Vector2(-5.0, 80.0)
	PlayerMotion.step(heavy, RunIntent.create(false, false, false, false, true), heavy.mass, H)
	assert_almost_eq(heavy.velocity.length(), 88.0, 0.001)


func test_second_surge_inside_the_cooldown_is_ignored() -> void:
	var state := _state_at(Vector2(320, 300))
	assert_true(PlayerMotion.step(state, RunIntent.create(false, false, false, false, true), state.mass, H))
	for _step: int in 24:
		PlayerMotion.step(state, RunIntent.new(), state.mass, H)
	assert_false(PlayerMotion.step(state, RunIntent.create(false, false, false, false, true), state.mass, H))
	for _step: int in 40:
		PlayerMotion.step(state, RunIntent.new(), state.mass, H)
	assert_true(PlayerMotion.step(state, RunIntent.create(false, false, false, false, true), state.mass, H))


func test_falling_body_rests_on_the_top_of_a_wall() -> void:
	var runtime := _runtime({"solids": [{"id": "floor", "rect": [0, 500, 640, 40], "kind": "wall"}]})
	var state := _state_at(Vector2(320, 470))
	state.velocity = Vector2(0.0, 30.0)
	_run(state, runtime, RunIntent.new(), 2.0)
	assert_lte(state.position.y, 500.0 - DescentState.BASE_BOX.y / 2.0 + 0.0001)
	assert_almost_eq(state.position.y, 500.0 - DescentState.BASE_BOX.y / 2.0, 0.0001)


func test_x_axis_resolves_before_y_axis_at_a_corner() -> void:
	var runtime := _runtime({"solids": [{"id": "block", "rect": [100, 100, 50, 50], "kind": "wall"}]})
	var state := _state_at(Vector2(94.5, 96.4))
	state.velocity = Vector2(240.0, 240.0)
	DescentCollision.resolve(state, runtime, H)
	assert_almost_eq(state.position.x, 96.5, 0.0001)
	assert_almost_eq(state.position.y, 100.0 - 3.5, 0.0001)
	assert_eq(state.velocity.y, 0.0)
	assert_eq(state.velocity.x, 240.0)


func test_surging_into_a_brittle_wall_breaks_it() -> void:
	var runtime := _runtime({"solids": [{"id": "crumb", "rect": [300, 520, 40, 40], "kind": "brittle", "regrow_seconds": 0.4}]})
	var state := _state_at(Vector2(320, 517))
	state.velocity = Vector2(0.0, 150.0)
	state.surge_active_for = 0.1
	var events: Dictionary = DescentCollision.resolve(state, runtime, H)
	assert_true(state.open_bristles.has("crumb"))
	assert_true((events["broken"] as Array).has("crumb"))
	assert_true(bool(runtime.solids[0]["broken"]))


func test_brittle_wall_without_a_surge_holds() -> void:
	var runtime := _runtime({"solids": [{"id": "crumb", "rect": [300, 520, 40, 40], "kind": "brittle"}]})
	var state := _state_at(Vector2(320, 516))
	state.velocity = Vector2(0.0, 150.0)
	DescentCollision.resolve(state, runtime, H)
	assert_false(state.open_bristles.has("crumb"))
	assert_almost_eq(state.position.y, 520.0 - 3.5, 0.0001)


func test_broken_wall_regrows_only_after_the_body_has_left_it() -> void:
	var runtime := _runtime({"solids": [{"id": "crumb", "rect": [300, 520, 40, 40], "kind": "brittle", "regrow_seconds": 0.4}]})
	var state := _state_at(Vector2(320, 540))
	var solid: Dictionary = runtime.solids[0]
	solid["broken"] = true
	solid["regrow_for"] = 0.4
	state.open_bristles.append("crumb")
	for _step: int in 60:
		DescentCollision.tick_regrow(state, runtime, H)
	assert_true(bool(solid["broken"]))
	state.position = Vector2(320, 600)
	DescentCollision.tick_regrow(state, runtime, H)
	assert_false(bool(solid["broken"]))
	assert_false(state.open_bristles.has("crumb"))


func _tide_runtime(flow_y: float) -> StratumRuntime:
	return _runtime({"currents": [{"id": "tide_main", "rect": [40, 100, 560, 900], "flow": [0.0, flow_y]}]})


func test_tide_holds_back_a_mass_two_body() -> void:
	var runtime := _tide_runtime(HazardField.TIDE_MAIN_FLOW.y)
	var state := _state_at(Vector2(320, 400), 2)
	state.velocity = Vector2(0.0, PlayerMotion.sink_terminal(2))
	_run(state, runtime, RunIntent.new(), 1.0)
	assert_lt(state.velocity.y, 0.0)
	assert_lt(state.position.y, 400.0)


func test_tide_lets_a_mass_three_body_through() -> void:
	var runtime := _tide_runtime(HazardField.TIDE_MAIN_FLOW.y)
	var state := _state_at(Vector2(320, 400), 3)
	state.velocity = Vector2(0.0, PlayerMotion.sink_terminal(3))
	_run(state, runtime, RunIntent.new(), 0.5)
	assert_gt(state.velocity.y, 0.0)
	assert_gt(state.position.y, 400.0)


func test_return_flow_carries_a_rising_light_body_upward() -> void:
	var runtime := _tide_runtime(HazardField.RETURN_FLOW.y)
	var state := _state_at(Vector2(320, 800), 0)
	_run(state, runtime, RunIntent.create(true), 1.0)
	assert_lt(state.velocity.y, 0.0)
	assert_lt(state.position.y, 800.0)


func _membrane_runtime(verb: String) -> StratumRuntime:
	return _runtime({"membranes": [{"id": "gate", "rect": [300, 520, 80, 16], "verb": verb, "hold_seconds": 0.9}]})


func _plug_runtime() -> StratumRuntime:
	return _runtime({"currents": [{"id": "tide_main", "rect": [300, 520, 80, 60], "flow": [0.0, -62.0]}]})


func test_consume_refuses_a_verb_that_does_not_fit_the_target() -> void:
	var runtime := _plug_runtime()
	var state := _state_at(Vector2(340, 515))
	state.pick_up(MatterItem.create("hammer", 1, "strike", "iron", "stratum_test"))
	var result: Dictionary = MatterLoop.consume(state, runtime, true)
	assert_false(bool(result.get("consumed", false)))
	assert_eq(state.carried.size(), 1)
	assert_false(bool(runtime.currents[0]["stilled"]))


func test_consume_matches_on_verb_and_never_on_tag() -> void:
	var runtime := _plug_runtime()
	var state := _state_at(Vector2(340, 515))
	state.pick_up(MatterItem.create("odd_plug", 1, "plug", "iron", "stratum_test"))
	var result: Dictionary = MatterLoop.consume(state, runtime, true)
	assert_true(bool(result.get("consumed", false)))
	assert_true(bool(runtime.currents[0]["stilled"]))


func test_weigh_matter_is_never_consumed() -> void:
	var runtime := _runtime({
		"membranes": [{"id": "gate", "rect": [300, 520, 80, 16], "verb": "feed"}],
		"currents": [{"id": "flow", "rect": [300, 480, 80, 60], "flow": [0.0, -20.0]}],
	})
	var state := _state_at(Vector2(340, 515), 2)
	var result: Dictionary = MatterLoop.consume(state, runtime, true)
	assert_false(bool(result.get("consumed", false)))
	assert_eq(state.mass, 2)
	assert_true(state.consumed.is_empty())


func test_consume_skips_a_useless_first_item() -> void:
	var runtime := _plug_runtime()
	var state := _state_at(Vector2(340, 515), 1)
	state.pick_up(MatterItem.create("matter_brine_plug", 3, "plug", "brine", "stratum_test"))
	var result: Dictionary = MatterLoop.consume(state, runtime, true)
	assert_true(bool(result.get("consumed", false)))
	assert_eq(result["matter"], "matter_brine_plug")
	assert_eq(state.carried.size(), 1)
	assert_eq(state.carried[0].verb, "weigh")


func test_consume_without_any_target_changes_nothing() -> void:
	var runtime := _runtime()
	var state := _state_at(Vector2(340, 515))
	state.pick_up(MatterItem.create("seed", 1, "feed", "seed", "stratum_test"))
	var before: Dictionary = state.to_save()
	var result: Dictionary = MatterLoop.consume(state, runtime, true)
	assert_true(bool(result.get("denied", false)))
	assert_eq(state.to_save(), before)


func test_feed_matter_is_never_spent_by_the_consume_key() -> void:
	var runtime := _membrane_runtime("feed")
	var state := _state_at(Vector2(340, 515))
	state.pick_up(MatterItem.create("matter_seed_vial", 1, "feed", "seed", "stratum_test"))
	var result: Dictionary = MatterLoop.consume(state, runtime, true)
	assert_true(bool(result.get("denied", false)))
	assert_eq(state.carried_ids(), ["matter_seed_vial"] as Array[String])
	assert_false(bool(runtime.membranes[0]["open"]))


func test_holding_the_verb_opens_a_membrane_without_spending_the_matter() -> void:
	var runtime := _membrane_runtime("feed")
	var state := _state_at(Vector2(340, 515))
	state.pick_up(MatterItem.create("matter_seed_vial", 1, "feed", "seed", "stratum_test"))
	for _step: int in 60:
		HazardField.apply(state, runtime, H)
	assert_false(bool(runtime.membranes[0]["open"]))
	assert_gt(float(runtime.membranes[0]["progress"]), 0.0)
	state.position = Vector2(340, 400)
	HazardField.apply(state, runtime, H)
	assert_eq(float(runtime.membranes[0]["progress"]), 0.0)
	state.position = Vector2(340, 515)
	for _step: int in 108:
		HazardField.apply(state, runtime, H)
	assert_true(bool(runtime.membranes[0]["open"]))
	assert_eq(state.carried_ids(), ["matter_seed_vial"] as Array[String])
	assert_true(state.consumed.is_empty())


func test_a_membrane_is_solid_until_it_opens() -> void:
	var runtime := _membrane_runtime("feed")
	var state := _state_at(Vector2(340, 505))
	state.velocity = Vector2(0.0, 80.0)
	_run(state, runtime, RunIntent.create(false, true), 1.0)
	assert_almost_eq(state.position.y, 520.0 - 3.5, 0.0001)
	runtime.membranes[0]["open"] = true
	_run(state, runtime, RunIntent.create(false, true), 2.0)
	assert_gt(state.position.y, 540.0)


func test_the_heart_mouth_spends_the_feed_matter_it_needs() -> void:
	var state := DescentState.new_state()
	state.stratum_id = "stratum_floor"
	state.pick_up(MatterItem.create("matter_seed_vial", 1, "feed", "seed", "stratum_teeth"))
	state.pick_up(MatterItem.create("matter_roots_bead", 1, "weigh", "bead", "stratum_roots"))
	var heart: Dictionary = _floor_runtime().find_route("mouth.heart")
	assert_eq(MatterLoop.spend_on_route(state, heart), "matter_seed_vial")
	assert_eq(state.carried_ids(), ["matter_roots_bead"] as Array[String])
	assert_eq(state.consumed[0], {"matter": "matter_seed_vial", "site": "mouth.heart", "stratum": "stratum_floor"})
	var still: Dictionary = _floor_runtime().find_route("mouth.still")
	assert_eq(MatterLoop.spend_on_route(state, still), "")
	assert_eq(state.carried.size(), 1)


func test_plug_matter_stills_the_current_it_is_used_in() -> void:
	var runtime := _tide_runtime(-62.0)
	var state := _state_at(Vector2(320, 500))
	state.pick_up(MatterItem.create("matter_brine_plug", 3, "plug", "brine", "stratum_test"))
	var result: Dictionary = MatterLoop.consume(state, runtime, true)
	assert_true(bool(result.get("consumed", false)))
	assert_eq(result["target_kind"], "current")
	assert_true(bool(runtime.currents[0]["stilled"]))
	assert_eq(HazardField.flow_at(runtime, state.position, null), Vector2.ZERO)
	assert_eq(state.mass, 0)


func test_pick_up_over_the_carry_limit_is_refused() -> void:
	var runtime := _runtime({"matter": [{"id": "big", "position": [320, 500], "size": 3, "verb": "plug", "tag": "brine"}]})
	var state := _state_at(Vector2(320, 500), 2)
	var events: Dictionary = MatterLoop.tick_pickup(state, runtime)
	assert_true(bool(events["denied"]))
	assert_eq(state.carried.size(), 2)
	assert_true(bool(runtime.matter[0]["present"]))


func test_pick_up_inside_the_radius_is_automatic() -> void:
	var runtime := _runtime({"matter": [{"id": "bead", "position": [329, 500], "size": 1, "verb": "weigh", "tag": "bead"}]})
	var state := _state_at(Vector2(320, 500))
	var events: Dictionary = MatterLoop.tick_pickup(state, runtime)
	assert_true((events["picked"] as Array).has("bead"))
	assert_eq(state.mass, 1)
	assert_false(bool(runtime.matter[0]["present"]))


func _route(requires: Array, blocks: Array = []) -> Dictionary:
	var route: Dictionary = {"id": "exit_test", "kind": "descent", "requires": requires}
	if not blocks.is_empty():
		route["blocks_verb"] = blocks
	return route


func test_clearance_three_is_closed_at_two_and_open_at_three_and_four() -> void:
	var route := _route([{"kind": "clearance", "mass": 3}])
	assert_false(RouteResolver.is_open(route, _state_at(Vector2.ZERO, 2)))
	assert_true(RouteResolver.is_open(route, _state_at(Vector2.ZERO, 3)))
	assert_true(RouteResolver.is_open(route, _state_at(Vector2.ZERO, 4)))


func test_fact_requirement_opens_after_the_nursery_plaque_is_touched() -> void:
	var loader := DescentContentLoader.new()
	loader.load_dir()
	var state := DescentState.new_state()
	var route := _route([{"kind": "fact", "fact": "vent_above"}])
	assert_false(RouteResolver.is_open(route, state))
	state.stratum_id = "stratum_nursery"
	var nursery := StratumRuntime.build(loader.get_stratum("stratum_nursery"), state)
	state.position = Vector2(540, 488)
	AnchorBook.check(state, nursery)
	assert_true(state.sites_done.has("site_nursery_plaque"))
	assert_true(RouteResolver.is_open(route, state))


func test_carrying_requirement_follows_the_carried_verbs() -> void:
	var route := _route([{"kind": "carrying", "verb": "feed"}])
	var state := DescentState.new_state()
	assert_false(RouteResolver.is_open(route, state))
	state.pick_up(MatterItem.create("matter_seed_vial", 1, "feed", "seed"))
	assert_true(RouteResolver.is_open(route, state))


func test_opened_requirement_reads_the_completed_sites() -> void:
	var route := _route([{"kind": "opened", "site_id": "site_nursery_plaque"}])
	var state := DescentState.new_state()
	assert_false(RouteResolver.is_open(route, state))
	state.sites_done.append("site_nursery_plaque")
	assert_true(RouteResolver.is_open(route, state))


func test_requires_entries_are_alternatives() -> void:
	var route := _route([{"kind": "clearance", "mass": 3}, {"kind": "fact", "fact": "current_lies"}])
	var state := DescentState.new_state()
	assert_false(RouteResolver.is_open(route, state))
	state.add_fact("current_lies")
	assert_true(RouteResolver.is_open(route, state))


func test_blocking_verb_closes_a_route_whose_requirement_holds() -> void:
	var route := _route([{"kind": "always"}], ["feed"])
	var state := DescentState.new_state()
	assert_true(RouteResolver.is_open(route, state))
	state.pick_up(MatterItem.create("matter_seed_vial", 1, "feed", "seed"))
	assert_false(RouteResolver.is_open(route, state))


func test_anchor_updates_the_checkpoint_once() -> void:
	var state := _state_at(Vector2(200, 600))
	var runtime := _runtime({"anchors": [{"id": "a1", "position": [200, 600], "radius": 12}]}, state)
	var first: Dictionary = AnchorBook.check(state, runtime)
	assert_eq(first["anchor"], "a1")
	assert_eq(state.anchors_taken, ["stratum_test#a1"] as Array[String])
	var snapshot: Dictionary = state.checkpoint.duplicate(true)
	state.position = Vector2(400, 900)
	AnchorBook.check(state, runtime)
	state.position = Vector2(200, 600)
	var again: Dictionary = AnchorBook.check(state, runtime)
	assert_eq(again["anchor"], "")
	assert_eq(state.anchors_taken.size(), 1)
	assert_eq(state.checkpoint, snapshot)
	var rebuilt := _runtime({"anchors": [{"id": "a1", "position": [200, 600], "radius": 12}]}, state)
	assert_eq(AnchorBook.check(state, rebuilt)["anchor"], "")
	assert_eq(state.anchors_taken.size(), 1)


func test_anchor_checkpoint_is_a_snapshot_of_the_moment_of_entry() -> void:
	var state := _state_at(Vector2(200, 600), 1)
	state.add_fact("current_lies")
	var runtime := _runtime({"anchors": [{"id": "a1", "position": [200, 600]}]}, state)
	AnchorBook.check(state, runtime)
	state.pick_up(MatterItem.create("late", 1, "feed", "seed"))
	state.add_fact("vent_above")
	assert_eq(state.checkpoint["facts"], ["current_lies"] as Array[String])
	assert_eq((state.checkpoint["carried"] as Array).size(), 1)
	assert_eq(int(state.checkpoint["mass"]), 1)


func test_three_hits_down_the_body_and_the_checkpoint_restores_only_matter() -> void:
	var state := _state_at(Vector2(200, 600), 1)
	state.checkpoint = state.make_checkpoint("a1", Vector2(200, 600))
	state.pick_up(MatterItem.create("late_seed", 1, "feed", "seed"))
	state.add_fact("current_lies")
	state.add_fact("vent_above")
	var hit: Array[Dictionary] = [{"amount": 1, "source": "fauna_test"}]
	var none: Array[Dictionary] = []
	for _blow: int in 3:
		Vitality.apply(state, hit, H)
		Vitality.apply(state, none, Vitality.INVULNERABLE_TIME + 0.01)
	assert_true(state.is_downed())
	var waiting: Dictionary = Vitality.apply(state, none, Vitality.DOWNED_BLACKOUT)
	assert_true(bool(waiting["recover"]))
	assert_true(Vitality.recover(state))
	assert_eq(state.integrity, 3)
	assert_eq(state.carried_ids(), ["weight_0"] as Array[String])
	assert_eq(state.mass, 1)
	assert_eq(state.facts.size(), 2)
	assert_almost_eq(state.invulnerable_for, Vitality.DOWNED_FADE_IN, 0.0001)


func test_strike_matter_takes_one_hit_instead_of_the_body() -> void:
	var state := _state_at(Vector2(200, 600))
	state.pick_up(MatterItem.create("matter_teeth_shard", 1, "strike", "shard"))
	var hit: Array[Dictionary] = [{"amount": 1, "source": "fauna_gallery_warden"}]
	var result: Dictionary = Vitality.apply(state, hit, H)
	assert_eq(state.integrity, 3)
	assert_true(state.carried.is_empty())
	assert_eq((result["absorbed"] as Dictionary).get("matter"), "matter_teeth_shard")
	assert_eq(state.consumed[0]["site"], "fauna_gallery_warden")


func _grazer_runtime() -> StratumRuntime:
	return _runtime({"fauna": [{"id": "grazer", "kind": "grazer", "position": [320, 500], "patrol": [200, 820]}]})


func test_grazer_chases_a_light_body_and_flees_a_heavy_one() -> void:
	var light := _state_at(Vector2(360, 500), 1)
	var runtime := _grazer_runtime()
	FaunaAgent.step_all(light, runtime, H)
	assert_eq(runtime.fauna[0]["mode"], "chase")
	var heavy := _state_at(Vector2(360, 500), 2)
	var other := _grazer_runtime()
	var start: Vector2 = other.fauna[0]["position"]
	FaunaAgent.step_all(heavy, other, H)
	assert_eq(other.fauna[0]["mode"], "flee")
	assert_gt((other.fauna[0]["position"] as Vector2).distance_to(heavy.position), start.distance_to(heavy.position))


func test_grazer_returns_to_patrol_beyond_its_lose_radius() -> void:
	var runtime := _grazer_runtime()
	var state := _state_at(Vector2(320 + 141, 500), 1)
	FaunaAgent.step_all(state, runtime, H)
	assert_eq(runtime.fauna[0]["mode"], "patrol")


func test_warden_does_not_exist_above_its_line() -> void:
	var runtime := _runtime({"fauna": [{"id": "warden", "kind": "warden", "position": [320, 230], "patrol": [960, 480], "line_y": 240}]})
	var state := _state_at(Vector2(320, 232))
	for _step: int in 240:
		var pending: Array[Dictionary] = FaunaAgent.step_all(state, runtime, H)
		assert_true(pending.is_empty())
	assert_eq(runtime.fauna[0]["mode"], "absent")
	state.position = Vector2(320, 300)
	FaunaAgent.step_all(state, runtime, H)
	assert_eq(runtime.fauna[0]["mode"], "chase")


func test_fauna_step_only_reports_pending_damage() -> void:
	var runtime := _grazer_runtime()
	var state := _state_at(Vector2(322, 500), 1)
	var pending: Array[Dictionary] = FaunaAgent.step_all(state, runtime, H)
	assert_eq(pending.size(), 1)
	assert_eq(state.integrity, 3)


func test_ending_with_nothing_known_or_carried_is_the_still_mouth() -> void:
	var floor_runtime := _floor_runtime()
	var state := DescentState.new_state()
	assert_eq(EndingResolver.open_mouth(floor_runtime.ending_routes(), state), "mouth.still")
	assert_eq(EndingResolver.ending_for(floor_runtime.find_route("mouth.still")), "ending.hollow")


func test_known_vent_opens_only_the_upper_mouth() -> void:
	var floor_runtime := _floor_runtime()
	var state := DescentState.new_state()
	state.add_fact("vent_above")
	assert_eq(EndingResolver.open_mouths(floor_runtime.ending_routes(), state), ["mouth.above"] as Array[String])


func test_carried_seed_opens_only_the_heart_mouth() -> void:
	var floor_runtime := _floor_runtime()
	var state := DescentState.new_state()
	state.add_fact("vent_above")
	state.pick_up(MatterItem.create("matter_seed_vial", 1, "feed", "seed"))
	assert_eq(EndingResolver.open_mouths(floor_runtime.ending_routes(), state), ["mouth.heart"] as Array[String])
	assert_true(RouteResolver.blocked(floor_runtime.find_route("mouth.above"), state))


func test_no_combination_opens_two_mouths() -> void:
	var floor_runtime := _floor_runtime()
	var verbs: Array[String] = ["feed", "strike", "weigh", "plug"]
	for fact_mask: int in 4:
		for carry_mask: int in 16:
			var state := DescentState.new_state()
			if fact_mask & 1:
				state.add_fact("vent_above")
			if fact_mask & 2:
				state.add_fact("current_lies")
			for bit: int in 4:
				if carry_mask & (1 << bit):
					state.carried.append(MatterItem.create("m_%d" % bit, 1, verbs[bit], "t"))
			state.recompute_mass()
			RouteResolver.evaluate(state, floor_runtime)
			var open_count: int = 0
			for route: Dictionary in floor_runtime.ending_routes():
				if bool(route["open"]):
					open_count += 1
			assert_eq(open_count, 1, "facts %d carried %d" % [fact_mask, carry_mask])
			var mouth: String = EndingResolver.open_mouth(floor_runtime.ending_routes(), state)
			assert_true(DescentState.ENDING_IDS.has(EndingResolver.ending_for(floor_runtime.find_route(mouth))))


func test_ending_result_names_one_of_three_endings() -> void:
	var state := DescentState.new_state()
	for ending: String in DescentState.ENDING_IDS:
		state.ending_id = ending
		var result: ModuleResult = EndingResolver.make_result(state)
		assert_eq(result.data["ending_id"], ending)
	assert_eq(EndingResolver.fallback_ending(_floor_runtime().ending_routes()), "ending.hollow")


func test_clock_caps_a_long_frame_at_four_substeps() -> void:
	var clock := DescentClock.new()
	assert_eq(clock.begin_frame(0.1), 4)
	assert_eq(clock.begin_frame(1.0 / 60.0), 2)
