extends GutTest

const H: float = 1.0 / 120.0
const MODULE_ROOT: String = "res://modules/descent_exploration"
const ACTIONS: Array[String] = [
	"descent_exploration_up", "descent_exploration_down", "descent_exploration_left",
	"descent_exploration_right", "descent_exploration_confirm", "descent_exploration_cancel",
]
const SEED_ITEM: Dictionary = {"id": "matter_seed_vial", "size": 1, "verb": "feed", "tag": "seed", "source_stratum": "stratum_teeth"}
const AXIS_KEYS: Array[String] = ["body", "creature", "creatures", "place", "places", "worldstate", "world_state_view", "limb_deficit", "hands_free", "down_count", "death_count", "known_total"]


func _body(missing: Array = ["arm_left"]) -> Dictionary:
	return {
		"missing": missing,
		"wounds": [{"part": "torso", "kind": "shard", "severity": 7, "permanent": true}],
		"scale": 0.65,
	}


func _store(body: Variant, gardener_state: String = "dead", gardener_den: String = "place.ruined_garden", with_gardener: bool = true) -> WorldState:
	var snapshot: Dictionary = {
		"ax": WorldState.STORE_VERSION,
		"creatures": {},
		"places": {
			"place.ruined_garden": {"region_id": "region_hollow", "tags": [], "requires_body": {}},
			"place.tea_stair": {"region_id": "region_hollow", "tags": [], "requires_body": {"scale_min": 0.7}},
			"place.far_garden": {"region_id": "region_elsewhere", "tags": [], "requires_body": {}},
		},
	}
	if with_gardener:
		(snapshot["creatures"] as Dictionary)["fix.gardener"] = {"id": "fix.gardener", "archetype": "gardener", "stage": 2, "state": gardener_state, "den": gardener_den}
	if body != null:
		snapshot["body"] = body
	var store := WorldState.new()
	var loaded: Dictionary = store.load_snapshot(snapshot)
	assert_true(bool(loaded["ok"]), str(loaded))
	return store


func _context(arrival: Dictionary) -> ModuleContext:
	var context := ModuleContext.new()
	context.module_id = &"descent_exploration"
	context.input_enabled = true
	for action: String in ACTIONS:
		context.allowed_actions.append(StringName(action))
	context.arrival = arrival
	return context


func _module(arrival: Dictionary, saved: Dictionary = {}) -> DescentModule:
	var module := DescentModule.new()
	add_child_autofree(module)
	module.load_state(saved)
	module.enter(_context(arrival))
	module.set_physics_process(false)
	return module


func _advance(module: DescentModule, seconds: float, intent: RunIntent = null) -> void:
	var frames: int = maxi(1, int(round(seconds * 60.0)))
	for _frame: int in frames:
		module.step_frame(1.0 / 60.0, intent)


func _warnings(module: DescentModule, fragment: String) -> int:
	var count: int = 0
	for message: String in module._warned:
		if message.contains(fragment):
			count += 1
	return count


func _layer(extra: Dictionary) -> Dictionary:
	var base: Dictionary = {
		"id": "stratum_test", "index": 0, "bounds": {"width": 640, "height": 1024},
		"spawn": {"position": [320, 96], "facing": 1},
		"solids": [], "currents": [], "membranes": [], "routes": [], "sites": [], "matter": [], "anchors": [], "fauna": [],
	}
	for key: Variant in extra:
		base[key] = extra[key]
	return base


func _limbs(count: int) -> BodyRead:
	var missing: Array = []
	for index: int in count:
		missing.append(BodyRead.LIMB_PARTS[index])
	return BodyRead.from_body({"missing": missing})


func _settle(mass: int, deficit: int, flow_y: float, intent: RunIntent, seconds: float = 1.0) -> DescentState:
	var runtime := StratumRuntime.build(_layer({"currents": [{"id": "tide_main", "rect": [40, 100, 560, 900], "flow": [0.0, flow_y]}]}))
	var state := DescentState.new_state()
	state.position = Vector2(320.0, 500.0)
	for index: int in mass:
		state.pick_up(MatterItem.create("weight_%d" % index, 1, "weigh", "stone"))
	if intent.is_idle():
		state.velocity = Vector2(0.0, PlayerMotion.sink_terminal(mass))
	var body: BodyRead = _limbs(deficit)
	for _step: int in int(round(seconds / H)):
		PlayerMotion.step(state, intent, state.mass, H)
		DescentCollision.resolve(state, runtime, H)
		HazardField.apply(state, runtime, H, body)
	return state


func _floor_save(extra: Dictionary = {}) -> Dictionary:
	var saved: Dictionary = {"schema": 1, "stratum_index": 5, "stratum_id": "stratum_floor", "carried": [SEED_ITEM.duplicate()]}
	for key: Variant in extra:
		saved[key] = extra[key]
	return saved


func _break_throat(module: DescentModule) -> void:
	module.state.position = Vector2(320.0, 636.0)
	module.state.velocity = Vector2.ZERO
	_advance(module, 1.0 / 60.0, RunIntent.create(false, true, false, false, true))
	_advance(module, 0.1, RunIntent.create(false, true))


func _keys_deep(value: Variant) -> Array[String]:
	var keys: Array[String] = []
	if value is Dictionary:
		for key: Variant in value as Dictionary:
			keys.append(String(key))
			keys.append_array(_keys_deep((value as Dictionary)[key]))
	elif value is Array:
		for entry: Variant in value as Array:
			keys.append_array(_keys_deep(entry))
	return keys


func test_the_arrival_view_carries_body_creatures_and_places() -> void:
	var module := _module(_store(_body()).make_arrival())
	assert_true(module.world.is_present())
	assert_true(module.world.has_body())
	assert_true(module.world.has_creature("fix.gardener"))
	assert_true(module.world.has_place("place.ruined_garden"))
	assert_eq(module.world.limb_deficit(), 1)
	assert_eq(module.world.hands_free(), 2)


func test_a_view_without_a_body_applies_no_body_rule_and_warns_once() -> void:
	var arrival: Dictionary = _store(null).make_arrival()
	var view := DescentWorldstateView.from_arrival(arrival)
	assert_true(view.is_present())
	assert_false(view.has_body())
	assert_null(view.limb_deficit())
	assert_null(view.hands_free())
	assert_eq(view.startup_warnings().size(), 1)
	assert_true(RequiresBodyGate.is_open({"hands_min": 1}, view.body()))
	var tide := StratumRuntime.build(_layer({"currents": [{"id": "tide_main", "rect": [40, 100, 560, 900], "flow": [0.0, -62.0]}]}))
	assert_eq(HazardField.flow_at(tide, Vector2(320.0, 500.0), view.body()), Vector2(0.0, -62.0))
	var module := _module(arrival)
	module.enter(_context(arrival))
	module.set_physics_process(false)
	assert_eq(_warnings(module, "no body"), 1)


func test_module_code_has_no_path_to_the_store() -> void:
	var tokens: Array[String] = ["WorldState", "AxisBody", "AxisCreature", "AxisPlace", "get_node(", "get_tree().root", "preload(\"res://core"]
	var directory: Array[String] = [MODULE_ROOT]
	while not directory.is_empty():
		var folder: String = directory.pop_back()
		for sub: String in DirAccess.get_directories_at(folder):
			directory.append(folder.path_join(sub))
		for file_name: String in DirAccess.get_files_at(folder):
			if file_name.get_extension() != "gd":
				continue
			var text: String = FileAccess.get_file_as_string(folder.path_join(file_name))
			for token: String in tokens:
				assert_false(text.contains(token), "%s holds %s" % [file_name, token])


func test_the_save_holds_no_axis_value_or_counter() -> void:
	var module := _module(_store(_body()).make_arrival())
	_advance(module, 0.2)
	module.state.position = Vector2(200.0, 600.0)
	_advance(module, 1.0 / 60.0)
	var keys: Array[String] = _keys_deep(module.save_state())
	for banned: String in AXIS_KEYS:
		assert_false(keys.has(banned), banned)


func test_limb_deficit_counts_parts_and_never_reads_severity() -> void:
	var read := BodyRead.from_body(_body())
	assert_eq(read.limb_deficit(), 1)
	assert_eq(read.hands_free(), 2)


func test_scale_is_compared_with_the_value_it_arrived_with() -> void:
	assert_true(RequiresBodyGate.is_open({"scale_min": 0.7}, BodyRead.from_body({"scale": 1.9})))
	var small: Dictionary = RequiresBodyGate.evaluate({"scale_min": 0.7}, BodyRead.from_body({"scale": 0.62}))
	assert_false(bool(small["open"]))
	assert_eq(small["unmet"], ["scale_below_min"] as Array[String])


func test_missing_entries_of_another_shape_are_not_counted() -> void:
	var odd: Array = [{"part": "arm_left", "kind": "lost", "severity": 4, "permanent": true}, 7, ""]
	assert_eq(BodyRead.from_body({"missing": odd}).limb_deficit(), 0)
	assert_eq(DescentWorldstateView.from_snapshot({"body": {"missing": odd}}).startup_warnings().size(), 0)


func test_an_absent_missing_field_is_not_made_zero() -> void:
	var read := BodyRead.from_body({"scale": 1.5})
	assert_null(read.limb_deficit())
	assert_null(read.hands_free())
	var tide := StratumRuntime.build(_layer({"currents": [{"id": "tide_main", "rect": [40, 100, 560, 900], "flow": [0.0, -62.0]}]}))
	assert_eq(HazardField.flow_at(tide, Vector2(320.0, 500.0), read), Vector2(0.0, -62.0))


func test_the_same_input_gives_byte_identical_output() -> void:
	var first: DescentState = _settle(3, 1, -62.0, RunIntent.create(false, false, true, false))
	var second: DescentState = _settle(3, 1, -62.0, RunIntent.create(false, false, true, false))
	assert_eq(var_to_bytes([first.to_save(), first.velocity, first.position]), var_to_bytes([second.to_save(), second.velocity, second.position]))


func test_going_down_keeps_every_fact() -> void:
	var module := _module({})
	_advance(module, 0.2)
	module.state.position = Vector2(200.0, 600.0)
	_advance(module, 1.0 / 60.0)
	module.state.add_fact("current_lies")
	module.state.add_fact("vent_above")
	var hit: Array[Dictionary] = [{"amount": 1, "source": "test"}]
	for _blow: int in 3:
		module.state.invulnerable_for = 0.0
		Vitality.apply(module.state, hit, H)
	assert_true(module.state.is_downed())
	_advance(module, 1.6)
	assert_eq(module.state.integrity, 3)
	assert_eq(module.state.facts.size(), 2)


func test_a_new_anchor_and_a_reload_keep_both_facts() -> void:
	var state := DescentState.new_state()
	state.stratum_id = "stratum_test"
	state.add_fact("current_lies")
	state.add_fact("vent_above")
	var runtime := StratumRuntime.build(_layer({"anchors": [{"id": "a1", "position": [100, 300]}, {"id": "a2", "position": [500, 800]}]}), state)
	state.position = Vector2(100.0, 300.0)
	AnchorBook.check(state, runtime)
	state.position = Vector2(500.0, 800.0)
	AnchorBook.check(state, runtime)
	assert_eq(state.checkpoint["anchor_id"], "a2")
	assert_eq(state.checkpoint["facts"], ["current_lies", "vent_above"] as Array[String])
	var module := _module({})
	_advance(module, 0.2)
	module.state.add_fact("current_lies")
	module.state.add_fact("vent_above")
	module.state.position = Vector2(200.0, 600.0)
	_advance(module, 1.0 / 60.0)
	var reloaded := _module({}, module.save_state())
	assert_eq(reloaded.state.facts.to_array(), ["current_lies", "vent_above"] as Array[String])
	assert_eq(reloaded.state.checkpoint["facts"], ["current_lies", "vent_above"] as Array[String])


func test_a_dead_gardener_in_the_roots_adds_and_removes_no_fact() -> void:
	var module := _module(_store(_body()).make_arrival())
	assert_true(bool(module.runtime.find_fauna("fix.gardener")["remains"]))
	_advance(module, 1.2)
	assert_true(module.state.facts.is_empty())
	assert_true(module.state.sites_done.is_empty())


func test_a_body_gate_that_passes_writes_no_fact() -> void:
	var state := DescentState.new_state()
	var read := BodyRead.from_body({"wounds": [{"part": "face", "kind": "crack", "severity": 3, "permanent": true}]})
	assert_true(RequiresBodyGate.is_open({"has_wound": {"part": "face", "kind": "crack", "severity_min": 2, "permanent": true}}, read))
	assert_true(state.facts.is_empty())
	assert_false(state.to_save().has("wounds"))


func test_a_refused_body_request_leaves_every_local_value_as_it_was() -> void:
	var calls: Array = []
	var refuse := func(axis: String, patch: Dictionary) -> Dictionary:
		calls.append([axis, patch])
		return {"accepted": false, "reason": "axis owner absent"}
	var module := _module({"request_mutation": refuse})
	_advance(module, 0.2)
	var before: Array = [module.state.integrity, module.state.carried_ids(), module.state.mass, module.state.facts.to_array()]
	_break_throat(module)
	assert_true(module.state.open_bristles.has("throat_wall") or module.state.position.y > 640.0)
	assert_eq(calls.size(), 1)
	assert_eq(calls[0][0], "body")
	assert_eq(((calls[0][1] as Dictionary)["wounds"] as Array).back(), DescentModule.BRITTLE_WOUND)
	assert_eq([module.state.integrity, module.state.carried_ids(), module.state.mass, module.state.facts.to_array()], before)
	assert_eq(_warnings(module, "refused"), 1)


func test_a_second_break_sends_no_second_request() -> void:
	var calls: Array = []
	var refuse := func(axis: String, patch: Dictionary) -> Dictionary:
		calls.append([axis, patch])
		return {"accepted": false, "reason": "axis owner absent"}
	var module := _module({"request_mutation": refuse})
	_advance(module, 0.2)
	_break_throat(module)
	module.state.position = Vector2(320.0, 300.0)
	module.state.velocity = Vector2.ZERO
	_advance(module, 1.0)
	assert_false(bool(module.runtime.solids[6]["broken"]))
	_break_throat(module)
	assert_eq(calls.size(), 1)
	for call: Array in calls:
		assert_ne(call[0], "place")
	assert_eq(_warnings(module, "refused"), 1)


func test_a_request_hook_that_is_not_callable_is_never_called() -> void:
	for value: Variant in [null, "request", 42]:
		var module := _module({"request_mutation": value})
		_advance(module, 0.2)
		_break_throat(module)
		assert_false(module.mutation_requested, str(value))
		assert_eq(module.state.phase, "playing")


func test_a_request_that_answers_nonsense_does_not_stop_the_frame() -> void:
	var module := _module({"request_mutation": func(_axis: String, _patch: Dictionary) -> int: return 42})
	_advance(module, 0.2)
	_break_throat(module)
	var depth: float = module.state.position.y
	_advance(module, 1.0, RunIntent.create(false, true))
	assert_gt(module.state.position.y, depth)
	assert_eq(module.state.phase, "playing")
	assert_eq(_warnings(module, "refused"), 1)


func test_entering_without_any_hook_loads_the_first_stratum() -> void:
	var module := _module({})
	assert_eq(module.runtime.id, "stratum_roots")
	assert_eq(module.state.stratum_index, 0)
	assert_false(module.world.is_present())


func test_tide_d0_mass3_sinks_through() -> void:
	assert_gt(_settle(3, 0, -62.0, RunIntent.new()).velocity.y, 0.0)


func test_tide_d1_mass3_sinks_through() -> void:
	assert_gt(_settle(3, 1, -62.0, RunIntent.new()).velocity.y, 0.0)


func test_tide_d2_mass3_is_held_back() -> void:
	var state: DescentState = _settle(3, 2, -62.0, RunIntent.new())
	assert_lt(state.velocity.y, 0.0)
	assert_lt(state.position.y, 500.0)


func test_tide_d2_mass4_sinks_through() -> void:
	assert_gt(_settle(4, 2, -62.0, RunIntent.new()).velocity.y, 0.0)


func test_tide_d4_mass4_cannot_sink() -> void:
	var state: DescentState = _settle(4, 4, -62.0, RunIntent.new())
	assert_lte(state.velocity.y, 0.0)
	assert_lt(state.position.y - 500.0, 1.0)


func test_free_fall_does_not_see_the_body() -> void:
	var open := StratumRuntime.build(_layer({}))
	var whole := DescentState.new_state()
	var broken := DescentState.new_state()
	for state: DescentState in [whole, broken]:
		state.position = Vector2(320.0, 300.0)
	for _step: int in 120:
		for pair: Array in [[whole, _limbs(0)], [broken, _limbs(4)]]:
			var state: DescentState = pair[0]
			PlayerMotion.step(state, RunIntent.new(), state.mass, H)
			DescentCollision.resolve(state, open, H)
			HazardField.apply(state, open, H, pair[1])
	assert_eq(whole.position, broken.position)
	assert_eq(whole.velocity, broken.velocity)


func test_return_flow_lifts_four_missing_limbs_exactly_24_faster() -> void:
	var whole: DescentState = _settle(0, 0, -26.0, RunIntent.create(true))
	var broken: DescentState = _settle(0, 4, -26.0, RunIntent.create(true))
	assert_almost_eq(whole.velocity.y - broken.velocity.y, 24.0, 0.0001)


func test_dead_gardener_remains_deal_no_damage() -> void:
	var loader := DescentContentLoader.new()
	loader.load_dir()
	var view := DescentWorldstateView.from_arrival(_store(_body()).make_arrival())
	var runtime := StratumRuntime.build(loader.get_stratum("stratum_roots"), null, view)
	var remains: Dictionary = runtime.find_fauna("fix.gardener")
	assert_true(bool(remains["remains"]))
	assert_eq(remains["position"], Vector2(96.0, 872.0))
	var state := DescentState.new_state()
	state.position = Vector2(96.0, 872.0)
	var total: int = 0
	for _step: int in 240:
		total += FaunaAgent.step_all(state, runtime, H).size()
	assert_eq(total, 0)
	assert_true(runtime.warnings.is_empty())


func test_a_fauna_entry_without_remains_at_places_nothing() -> void:
	var view := DescentWorldstateView.from_arrival(_store(_body()).make_arrival())
	var runtime := StratumRuntime.build(_layer({"fauna": [{"id": "fix.gardener", "kind": "remains"}]}), null, view)
	assert_false(bool(runtime.find_fauna("fix.gardener")["remains"]))
	var state := DescentState.new_state()
	assert_true(FaunaAgent.step_all(state, runtime, H).is_empty())
	assert_true(runtime.warnings.is_empty())


func test_a_living_gardener_warns_once_and_leaves_no_remains() -> void:
	var module := _module(_store(_body(), "alive").make_arrival())
	assert_false(bool(module.runtime.find_fauna("fix.gardener")["remains"]))
	module.execute_command(&"retry", {})
	assert_eq(_warnings(module, "not in the dead state"), 1)


func test_a_den_in_another_region_is_silent() -> void:
	var module := _module(_store(_body(), "dead", "place.far_garden").make_arrival())
	assert_false(bool(module.runtime.find_fauna("fix.gardener")["remains"]))
	assert_eq(_warnings(module, "fix.gardener"), 0)


func test_a_missing_creature_record_warns_once() -> void:
	var module := _module(_store(_body(), "dead", "place.ruined_garden", false).make_arrival())
	assert_false(bool(module.runtime.find_fauna("fix.gardener")["remains"]))
	module.execute_command(&"retry", {})
	assert_eq(_warnings(module, "no creature record"), 1)


func test_remains_are_not_solid() -> void:
	var loader := DescentContentLoader.new()
	loader.load_dir()
	var view := DescentWorldstateView.from_arrival(_store(_body()).make_arrival())
	var runtime := StratumRuntime.build(loader.get_stratum("stratum_roots"), null, view)
	var state := DescentState.new_state()
	state.position = Vector2(96.0, 856.0)
	for _step: int in 240:
		PlayerMotion.step(state, RunIntent.create(false, true), state.mass, H)
		DescentCollision.resolve(state, runtime, H)
	assert_gt(state.position.y, 880.0)


func test_the_roots_stay_harmless_with_remains() -> void:
	var module := _module(_store(_body()).make_arrival())
	_advance(module, 0.2)
	module.state.position = Vector2(96.0, 872.0)
	_advance(module, 2.0)
	assert_eq(module.state.integrity, 3)


func test_two_hands_open_the_heart_seat_and_the_swallow_ending() -> void:
	var module := _module(_store(_body([])).make_arrival(), _floor_save())
	_advance(module, 0.2)
	module.state.position = Vector2(320.0, 760.0)
	module.state.velocity = Vector2.ZERO
	_advance(module, 1.2)
	assert_true(bool(module.runtime.find_membrane("heart_meld")["open"]))
	_advance(module, 3.0, RunIntent.create(false, true))
	assert_eq(module.state.ending_id, "ending.swallow")
	assert_eq(module.state.consumed.back()["site"], "mouth.heart")


func test_one_hand_still_opens_the_heart_seat() -> void:
	var module := _module(_store(_body(["hand_left"])).make_arrival(), _floor_save())
	_advance(module, 0.2)
	module.state.position = Vector2(320.0, 760.0)
	module.state.velocity = Vector2.ZERO
	_advance(module, 1.2)
	assert_true(bool(module.runtime.find_membrane("heart_meld")["open"]))
	_advance(module, 3.0, RunIntent.create(false, true))
	assert_eq(module.state.ending_id, "ending.swallow")


func test_no_hands_keep_the_heart_seat_closed_and_change_nothing() -> void:
	var module := _module(_store(_body(["hand_left", "hand_right"])).make_arrival(), _floor_save())
	_advance(module, 0.2)
	module.state.position = Vector2(320.0, 760.0)
	module.state.velocity = Vector2.ZERO
	var before: Array = [module.state.carried_ids(), module.state.mass, module.state.consumed.duplicate(true)]
	_advance(module, 2.0, RunIntent.create(false, true))
	var meld: Dictionary = module.runtime.find_membrane("heart_meld")
	assert_false(bool(meld["open"]))
	assert_eq(float(meld["progress"]), 0.0)
	assert_eq([module.state.carried_ids(), module.state.mass, module.state.consumed], before)
	assert_ne(module.state.ending_id, "ending.swallow")
	assert_false(bool(module.runtime.find_route("mouth.heart")["open"]))


func test_no_hands_leave_another_mouth_open() -> void:
	var loader := DescentContentLoader.new()
	loader.load_dir()
	var floor_runtime := StratumRuntime.build(loader.get_stratum("stratum_floor"))
	var handless := BodyRead.from_body({"missing": ["hand_left", "hand_right"]})
	var carrying := DescentState.new_state()
	carrying.add_fact("vent_above")
	carrying.pick_up(MatterItem.from_dictionary(SEED_ITEM))
	assert_eq(EndingResolver.open_mouth(floor_runtime.ending_routes(), carrying, handless), "mouth.still")
	var empty := DescentState.new_state()
	empty.add_fact("vent_above")
	assert_eq(EndingResolver.open_mouth(floor_runtime.ending_routes(), empty, handless), "mouth.above")
	var knowing_nothing := DescentState.new_state()
	knowing_nothing.pick_up(MatterItem.from_dictionary(SEED_ITEM))
	assert_eq(EndingResolver.open_mouth(floor_runtime.ending_routes(), knowing_nothing, handless), "mouth.still")


func test_the_carry_limit_does_not_depend_on_hands() -> void:
	for missing: Array in [[], ["hand_left", "hand_right"]]:
		var module := _module(_store(_body(missing)).make_arrival())
		for index: int in 4:
			assert_true(module.state.pick_up(MatterItem.create("m%d" % index, 1, "weigh", "stone")))
		assert_false(module.state.pick_up(MatterItem.create("m4", 1, "weigh", "stone")))
		assert_eq(module.state.mass, 4)
	assert_eq(DescentState.MAX_CARRY_MASS, 4)
	assert_eq(MatterLoop.MAX_CARRY_MASS, 4)


func test_the_ruined_garden_never_closes() -> void:
	var view := DescentWorldstateView.from_arrival(_store(_body()).make_arrival())
	var requirement: Variant = view.place_requires_body("place.ruined_garden")
	assert_eq(requirement, {})
	for body: BodyRead in [null, BodyRead.from_body({"missing": ["hand_left", "hand_right"]}), BodyRead.from_body({"scale": 0.05})]:
		assert_true(RequiresBodyGate.is_open(requirement, body))


func test_the_tea_stair_is_no_stratum_of_this_kit() -> void:
	var module := _module({}, {"schema": 1, "stratum_index": 0, "stratum_id": "place.tea_stair"})
	assert_eq(module.state.stratum_id, "stratum_roots")
	assert_eq(_warnings(module, "place.tea_stair"), 1)
	_advance(module, 0.3)
	assert_eq(module.state.phase, "playing")


func test_the_mirror_march_is_no_stratum_of_this_kit() -> void:
	var module := _module({}, {"schema": 1, "stratum_index": 3, "stratum_id": "place.mirror_march"})
	assert_eq(module.state.stratum_id, "stratum_nursery")
	assert_eq(_warnings(module, "place.mirror_march"), 1)
	_advance(module, 0.3)
	assert_eq(module.state.phase, "playing")
