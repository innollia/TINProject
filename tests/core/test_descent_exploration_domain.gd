extends GutTest


func _item(id: String, size: int = 1, verb: String = "weigh", tag: String = "bead") -> MatterItem:
	return MatterItem.create(id, size, verb, tag, "stratum_roots")


func _has_forbidden_value(value: Variant, depth: int = 0) -> bool:
	if depth > 6:
		return false
	if value is Vector2 or value is Vector2i or value is Vector3 or value is Rect2 or value is Callable or value is Object:
		return true
	if value is float and not is_finite(value as float):
		return true
	if value is Array:
		for entry: Variant in value as Array:
			if _has_forbidden_value(entry, depth + 1):
				return true
	if value is Dictionary:
		for key: Variant in value as Dictionary:
			if not key is String or _has_forbidden_value((value as Dictionary)[key], depth + 1):
				return true
	return false


func test_new_state_defaults_match_the_field_table() -> void:
	var state: DescentState = DescentState.new_state()
	assert_eq(state.schema, 1)
	assert_eq(state.run_id, "")
	assert_eq(state.world_seed, 0)
	assert_eq(state.phase, "first_frame")
	assert_eq(state.stratum_index, 0)
	assert_eq(state.stratum_id, "stratum_roots")
	assert_true(state.facts.is_empty())
	assert_eq(state.mass, 0)
	assert_true(state.carried.is_empty())
	assert_true(state.consumed.is_empty())
	assert_eq(state.position, Vector2(320.0, 96.0))
	assert_eq(state.velocity, Vector2.ZERO)
	assert_eq(state.facing, 1)
	assert_eq(state.integrity, 3)
	assert_eq(state.invulnerable_for, 0.0)
	assert_eq(state.surge_cooldown_for, 0.0)
	assert_eq(state.surge_active_for, 0.0)
	assert_eq(state.downed_for, 0.0)
	assert_true(state.anchors_taken.is_empty())
	assert_true(state.sites_done.is_empty())
	assert_true(state.routes_opened.is_empty())
	assert_true(state.open_bristles.is_empty())
	assert_true(state.checkpoint.is_empty())
	assert_eq(state.ending_id, "")
	assert_eq(state.elapsed_play, 0.0)
	assert_false(state.transition_pending)
	assert_eq(state.transition_to, "")


func test_add_fact_twice_keeps_one_entry_and_touches_no_site() -> void:
	var state := DescentState.new_state()
	assert_true(state.add_fact("x"))
	assert_false(state.add_fact("x"))
	assert_eq(state.facts.size(), 1)
	assert_true(state.sites_done.is_empty())


func test_fact_ledger_round_trip_keeps_order_and_drops_duplicates() -> void:
	var ledger := FactLedger.new()
	ledger.from_array(["b", "a", "b", "", 7])
	assert_eq(ledger.to_array(), ["b", "a"] as Array[String])
	assert_true(ledger.has("a"))
	assert_false(ledger.has("c"))


func test_fifth_pick_up_is_refused_and_leaves_four_carried() -> void:
	var state := DescentState.new_state()
	for index: int in 4:
		assert_true(state.pick_up(_item("m%d" % index)))
	assert_false(state.pick_up(_item("m4")))
	assert_eq(state.carried.size(), 4)
	assert_eq(state.mass, 4)


func test_pick_up_adds_the_item_size_to_mass() -> void:
	var state := DescentState.new_state()
	assert_true(state.pick_up(_item("plug", 3, "plug", "brine")))
	assert_eq(state.mass, 3)
	assert_false(state.pick_up(_item("second", 2)))
	assert_eq(state.mass, 3)


func test_consume_removes_the_indexed_item_and_records_three_keys() -> void:
	var state := DescentState.new_state()
	state.pick_up(_item("seed", 1, "feed", "seed"))
	state.pick_up(_item("bead"))
	assert_true(state.consume(0, "heart_meld"))
	assert_eq(state.carried.size(), 1)
	assert_eq(state.carried[0].id, "bead")
	assert_eq(state.mass, 1)
	assert_eq(state.consumed.size(), 1)
	var record: Dictionary = state.consumed[0]
	assert_eq(record.keys().size(), 3)
	assert_eq(record["matter"], "seed")
	assert_eq(record["site"], "heart_meld")
	assert_eq(record["stratum"], "stratum_roots")


func test_failed_consume_changes_nothing() -> void:
	var state := DescentState.new_state()
	state.pick_up(_item("bead"))
	var before: Dictionary = state.to_save()
	assert_false(state.consume(5, "anything"))
	assert_false(state.consume(-1, "anything"))
	assert_eq(state.to_save(), before)


func test_three_hits_reach_zero_integrity_with_the_blackout_clock_at_zero() -> void:
	var state := DescentState.new_state()
	for _hit: int in 3:
		assert_true(state.apply_damage(1))
	assert_eq(state.integrity, 0)
	assert_eq(state.downed_for, 0.0)
	assert_true(state.is_downed())


func test_damage_is_ignored_while_invulnerable() -> void:
	var state := DescentState.new_state()
	state.invulnerable_for = 0.5
	assert_false(state.apply_damage(1))
	assert_eq(state.integrity, 3)


func test_save_payload_is_json_safe_to_depth_six() -> void:
	var state := DescentState.new_state()
	state.pick_up(_item("seed", 1, "feed", "seed"))
	state.checkpoint = state.make_checkpoint("a1", Vector2(10.0, 20.0))
	state.consume(0, "heart_meld")
	var saved: Dictionary = state.to_save()
	assert_false(_has_forbidden_value(saved))
	assert_true(SaveService.is_json_safe(saved))


func test_save_payload_has_no_counter_or_blackout_key() -> void:
	var keys: Array = DescentState.new_state().to_save().keys()
	assert_false(keys.has("down_count"))
	for key: Variant in keys:
		assert_false(String(key).begins_with("down"), "key %s starts with down" % key)
	for banned: String in ["open_bristles", "velocity", "elapsed_play", "death_count", "score", "progress", "known_total"]:
		assert_false(keys.has(banned), banned)


func test_from_save_of_to_save_restores_every_saved_field() -> void:
	var state := DescentState.new_state()
	state.run_id = "r-00abcd"
	state.world_seed = 43981
	state.phase = "playing"
	state.stratum_index = 3
	state.stratum_id = "stratum_nursery"
	state.add_fact("current_lies")
	state.add_fact("vent_above")
	state.pick_up(_item("matter_seed_vial", 1, "feed", "seed"))
	state.pick_up(_item("matter_iron_rib", 1, "weigh", "iron"))
	state.consumed.append({"matter": "matter_brine_plug", "site": "tide_main", "stratum": "stratum_teeth"})
	state.position = Vector2(176.0, 402.0)
	state.facing = -1
	state.integrity = 2
	state.anchors_taken.append("stratum_roots#a1")
	state.sites_done.append("site_roots_plaque")
	state.routes_opened.append("exit_roots")
	state.checkpoint = state.make_checkpoint("a1", Vector2(80.0, 300.0))
	state.ending_id = ""
	var copy: DescentState = DescentState.from_save(state.to_save())
	assert_eq(copy.to_save(), state.to_save())
	assert_eq(copy.position, state.position)
	assert_eq(copy.facts.to_array(), state.facts.to_array())
	assert_eq(copy.carried_ids(), state.carried_ids())


func test_matter_item_rejects_unknown_verbs_sizes_and_empty_tags() -> void:
	assert_true(MatterItem.is_valid_dictionary({"id": "a", "size": 1, "verb": "feed", "tag": "seed"}))
	assert_false(MatterItem.is_valid_dictionary({"id": "a", "size": 1, "verb": "nope", "tag": "seed"}))
	assert_false(MatterItem.is_valid_dictionary({"id": "a", "size": 4, "verb": "feed", "tag": "seed"}))
	assert_false(MatterItem.is_valid_dictionary({"id": "a", "size": 1, "verb": "feed", "tag": ""}))
	assert_false(MatterItem.is_valid_dictionary({"id": "", "size": 1, "verb": "feed", "tag": "seed"}))
	var item: MatterItem = MatterItem.from_dictionary({"id": "a", "size": 2.0, "verb": "plug", "tag": "brine", "source_stratum": "stratum_teeth"})
	assert_not_null(item)
	assert_eq(item.size, 2)
	assert_eq(item.to_dictionary(), {"id": "a", "size": 2, "verb": "plug", "tag": "brine", "source_stratum": "stratum_teeth"})


func test_body_box_grows_two_pixels_per_mass() -> void:
	assert_eq(DescentState.box_size(0), Vector2(9.0, 7.0))
	assert_eq(DescentState.box_size(4), Vector2(17.0, 15.0))
	assert_eq(DescentState.box_size(9), Vector2(17.0, 15.0))
