extends GutTest

const OWNER: StringName = &"sideview_ecosystem"
const VISITOR: StringName = &"descent_exploration"
const GARDENER: String = "fix.gardener"
const BUTLER: String = "fix.butler"
const GARDEN: String = "place.ruined_garden"
const STAIR: String = "place.tea_stair"
const MASK: String = "place.mirror_march"


func _places() -> Dictionary:
	return {
		GARDEN: {"region_id": "region.waste", "tags": ["outdoor", "wet"], "requires_body": {}},
		STAIR: {"region_id": "region.hall", "tags": ["indoor"], "requires_body": {"scale_min": 0.7}},
		MASK: {
			"region_id": "region.hall",
			"tags": ["indoor", "threshold"],
			"requires_body": {"has_wound": {"part": "face", "kind": "scar", "permanent": true}},
		},
	}


func _snapshot() -> Dictionary:
	return {
		"ax": 1,
		"owners": {"body": String(OWNER), "creature": String(OWNER)},
		"body": {"scale": 1.5, "missing": ["left_arm"], "facts": {"carry_load": 200}},
		"creatures": {
			GARDENER: {
				"id": GARDENER,
				"archetype": "gardener",
				"state": "alive",
				"traits": {"patience": 2},
				"memory": [{"kind": "planted", "seed": "ash"}],
				"den": GARDEN,
			},
			BUTLER: {
				"id": BUTLER,
				"archetype": "butler",
				"state": "alive",
				"memory": [{"kind": "served", "place": STAIR}],
				"den": STAIR,
			},
		},
		"places": _places(),
		"focus_place_id": STAIR,
	}


func _store() -> WorldState:
	var store: WorldState = WorldState.new()
	store.declare_owner(WorldState.AXIS_BODY, OWNER)
	store.declare_owner(WorldState.AXIS_CREATURE, OWNER)
	return store


func _world() -> WorldState:
	var store: WorldState = _store()
	store.load_snapshot(_snapshot())
	return store


# ── 결정론과 왕복 ──────────────────────────────────────────────────────────
func test_snapshot_restores_to_exactly_itself() -> void:
	var source: Dictionary = _snapshot()
	var store: WorldState = WorldState.new()
	assert_true(store.load_snapshot(source.duplicate(true))["ok"])
	assert_eq(store.to_dictionary(), source)
	assert_true(store.to_dictionary().has("body"))
	assert_eq((store.to_dictionary()["body"] as Dictionary).keys(), ["missing", "scale", "facts"])


func test_json_text_round_trip_is_deterministic() -> void:
	var store: WorldState = _world()
	var text: String = store.to_json()
	var first: WorldState = WorldState.new()
	var second: WorldState = WorldState.new()
	assert_true(first.load_json(text)["ok"])
	assert_true(second.load_json(text)["ok"])
	assert_eq(first.to_dictionary(), _snapshot())
	assert_eq(first.to_dictionary(), second.to_dictionary())
	assert_eq(first.to_json(), text)
	assert_eq(second.to_json(), text)


## 저장 왕복은 값을 바꾸지 않고 타입도 바꾸지 않는다. Godot 의 JSON 파서는 모든 숫자를
## float 로 돌려주므로, int 와 정수 부분뿐인 float 의 구분은 파싱 결과가 아니라 원문
## 텍스트에서 복원해야 한다. 이 테스트는 그 성질을 우연이 아니라 직접 단언한다.
func test_a_json_text_round_trip_preserves_the_type_of_every_number() -> void:
	var store: WorldState = WorldState.new()
	store.declare_owner(WorldState.AXIS_BODY, OWNER)
	store.declare_owner(WorldState.AXIS_CREATURE, OWNER)
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {
		"scale": 1.5,
		"facts": {"whole": 200, "part": 0.5, "whole_float": 1.0, "note": "1.0 and 200 are words here"},
	}, OWNER)["ok"])
	assert_true(store.request_mutation(WorldState.AXIS_CREATURE, {"id": GARDENER, "archetype": "gardener", "stage": 3}, OWNER)["ok"])

	var written: Dictionary = store.to_dictionary()
	assert_true((written["body"] as Dictionary)["facts"]["whole_float"] is float, "a whole float is not quietly turned into an int on the way in")
	assert_true((written["body"] as Dictionary)["scale"] is float, "a rung is not quietly turned into an int on the way in")
	assert_true((written["body"] as Dictionary)["facts"]["whole"] is int, "an int is not quietly turned into a float on the way in")

	var text: String = store.to_json()
	var restored: WorldState = WorldState.new()
	assert_true(restored.load_json(text)["ok"])

	var body: Dictionary = (restored.to_dictionary()["body"] as Dictionary)
	assert_true(body["scale"] is float, "a rung comes back a float, not JSON's one number type")
	assert_true(body["facts"]["whole_float"] is float, "1.0 comes back a float, not JSON's one number type")
	assert_true(body["facts"]["whole"] is int, "200 comes back an int, not JSON's one number type")
	assert_true(body["facts"]["part"] is float, "0.5 comes back a float")
	assert_eq(body["facts"]["whole"], 200)
	assert_eq(body["scale"], 1.5)
	assert_eq(body["facts"]["note"], "1.0 and 200 are words here", "digits inside a string are not number tokens")
	assert_true((restored.to_dictionary()["creatures"][GARDENER] as Dictionary)["stage"] is int)
	assert_eq(restored.to_dictionary(), written, "the round trip changed no value and no type")
	assert_eq(restored.to_json(), text, "and the text is stable, so a second round trip is a no-op")
	var twice: WorldState = WorldState.new()
	assert_true(twice.load_json(restored.to_json())["ok"])
	assert_eq(twice.to_dictionary(), written)


## 텍스트의 숫자 토큰과 파싱된 값의 숫자 개수가 다르면, 어느 숫자에 어느 표시를 붙일지
## 신뢰할 수 없다. 조용히 맞추지 않고 정직하게 실패한다. (§7)
func test_a_snapshot_text_whose_numbers_do_not_line_up_is_refused() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	var refused: Dictionary = store.load_json('{"ax":1,"focus_place_id":"","scale":1.0,"scale":2.0}')
	assert_false(refused["ok"], "a duplicated number key is refused, not guessed")
	assert_eq(refused["reason"], &"snapshot_malformed")
	assert_eq(store.to_dictionary(), before)


func test_absent_keys_stay_absent_and_no_default_is_fabricated() -> void:
	var store: WorldState = _world()
	var exported: Dictionary = store.to_dictionary()
	assert_false((exported["creatures"][GARDENER] as Dictionary).has("stage"), "no stage was authored, so none is invented")
	assert_false((exported["body"] as Dictionary).has("wounds"), "no wound was authored, so none is invented")
	var body: Variant = store.issue_view().get_body()
	assert_null(body.get_wounds())
	assert_null(body.get_fact(&"swim_draft"))
	assert_true(body.has_scale())
	assert_null((body.get_facts() as Dictionary).get("max_load"))
	assert_false(body.has_fact(&"max_load"))
	assert_true(body.has_missing_part("left_arm"))
	assert_false(body.has_missing_part("tail"))


func test_an_empty_store_keeps_the_body_axis_absent() -> void:
	var store: WorldState = _store()
	var exported: Dictionary = store.to_dictionary()
	assert_false(exported.has("body"))
	assert_false(exported.has("creatures"))
	assert_false(exported.has("places"))
	assert_eq(exported["focus_place_id"], "")
	assert_false(store.issue_view().has_body())
	assert_null(store.issue_view().get_body())
	assert_eq(store.issue_view().get_creature_ids(), [] as Array[String])
	assert_eq(store.issue_view().get_place_ids(), [] as Array[String])


func test_a_json_unsafe_snapshot_is_refused_without_a_partial_restore() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	var unsafe: Dictionary = _snapshot()
	unsafe["creatures"][GARDENER]["memory"] = [{"kind": "planted", "at": Vector2.ONE}]
	var refused: Dictionary = store.load_snapshot(unsafe)
	assert_false(refused["ok"])
	assert_eq(refused["reason"], &"value_not_json_safe")
	assert_eq(store.to_dictionary(), before)
	var nonfinite: Dictionary = _snapshot()
	nonfinite["creatures"][BUTLER]["stage"] = INF
	assert_eq(store.load_snapshot(nonfinite)["reason"], &"value_not_finite")
	assert_eq(store.to_dictionary(), before)
	var mismatched: Dictionary = _snapshot()
	mismatched["creatures"]["fix.lie"] = {"id": GARDENER, "archetype": "liar"}
	assert_false(store.load_snapshot(mismatched)["ok"])
	assert_eq(store.load_snapshot(mismatched)["reason"], &"snapshot_malformed", "the record key and the id must agree")
	assert_eq(store.to_dictionary(), before)


func test_snapshot_version_is_checked_and_never_guessed() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	for bad: Variant in [{}, {"ax": 0}, {"ax": 2}, {"ax": "1"}, {"ax": 1.5}, {"ax": NAN}]:
		var result: Dictionary = store.load_snapshot(bad)
		assert_false(result["ok"], "snapshot %s refused" % str(bad))
		assert_eq(result["reason"], &"snapshot_version_unsupported")
		assert_eq(store.to_dictionary(), before)
	assert_eq(store.load_snapshot("not a dictionary")["reason"], &"snapshot_malformed")
	assert_eq(store.load_json("{not json")["reason"], &"snapshot_malformed")
	assert_eq(store.to_dictionary(), before)


func test_snapshot_owners_are_asserted_not_overwritten() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	var foreign: Dictionary = _snapshot()
	foreign["owners"]["body"] = "somewhere_else"
	var refused: Dictionary = store.load_snapshot(foreign)
	assert_false(refused["ok"])
	assert_eq(refused["reason"], &"owner_already_declared")
	assert_eq(store.to_dictionary(), before)
	var read_only_axis: Dictionary = _snapshot()
	read_only_axis["owners"] = {"place": String(OWNER)}
	assert_eq(store.load_snapshot(read_only_axis)["reason"], &"owners_malformed")
	var unknown_axis: Dictionary = _snapshot()
	unknown_axis["owners"] = {"resource": "anybody"}
	assert_eq(store.load_snapshot(unknown_axis)["reason"], &"owners_malformed")
	assert_eq(store.to_dictionary(), before)


# ── 정규화 금지 ────────────────────────────────────────────────────────────
func test_a_value_drops_by_exactly_what_was_patched_and_is_never_rescaled() -> void:
	var store: WorldState = _store()
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {"facts": {"carry_load": 200}}, OWNER)["ok"])
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {"facts": {"carry_load": 199}}, OWNER)["ok"])
	var body: Variant = store.issue_view().get_body()
	assert_eq(int(body.get_fact(&"carry_load")), 199)
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {"scale": 3.6}, OWNER)["ok"])
	body = store.issue_view().get_body()
	assert_eq(float(body.get_scale()), 3.6)
	assert_true(float(body.get_scale()) > 1.0, "a 1..3 grammar never clamps the top rung")
	assert_false(store.request_mutation(WorldState.AXIS_BODY, {"scale": 3.6}, VISITOR)["ok"])
	assert_eq(float((store.issue_view().get_body() as Variant).get_scale()), 3.6)
	## 옛 입력값들은 이제 거절 사유를 갖는다. 가까운 rung 으로 눌러 맞추는 일은 없다.
	for off_ladder: Variant in [199.7, 0.9, 0.5, 0.2, 0.1]:
		var refused: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"scale": off_ladder}, OWNER)
		assert_eq(refused["reason"], WorldState.REASON_SCALE_NOT_RUNG, str(off_ladder))
		assert_false(String(refused["detail"]).is_empty(), str(off_ladder))
		assert_eq(float((store.issue_view().get_body() as Variant).get_scale()), 3.6, "no refused float moved the rung")
	var forbidden: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"scale": 1.0}, OWNER)
	assert_eq(forbidden["reason"], WorldState.REASON_SCALE_RUNG_FORBIDDEN)
	assert_eq(float((store.issue_view().get_body() as Variant).get_scale()), 3.6, "the forbidden rung moved nothing either")


func test_no_derived_summary_is_stored_under_any_key() -> void:
	var store: WorldState = _store()
	for key: String in ["health", "hp", "health_fraction", "condition", "vitality", "wound_count"]:
		var flat: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {key: 0.5}, OWNER)
		assert_false(flat["ok"], key)
		assert_eq(flat["reason"], &"derived_value_forbidden")
		var nested: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"facts": {key: 0.5}}, OWNER)
		assert_false(nested["ok"], key)
		assert_eq(nested["reason"], &"derived_value_forbidden")
	assert_false(store.to_dictionary().has("body"))


# ── 중재와 거부 ────────────────────────────────────────────────────────────
func test_a_refused_mutation_returns_a_reason_and_changes_nothing() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	var cases: Array = [
		[WorldState.AXIS_BODY, {"unknown_field": 1}, &"key_unknown"],
		[WorldState.AXIS_BODY, {"scale": "big"}, &"value_type_invalid"],
		[WorldState.AXIS_BODY, {"scale": INF}, &"value_not_finite"],
		[WorldState.AXIS_BODY, {"scale": NAN}, &"value_not_finite"],
		[WorldState.AXIS_BODY, {"scale": 0.9}, &"scale_not_rung"],
		[WorldState.AXIS_BODY, {"scale": 0.5}, &"scale_not_rung"],
		[WorldState.AXIS_BODY, {"scale": 0.2}, &"scale_not_rung"],
		[WorldState.AXIS_BODY, {"scale": 0.1}, &"scale_not_rung"],
		[WorldState.AXIS_BODY, {"scale": 199.7}, &"scale_not_rung"],
		[WorldState.AXIS_BODY, {"scale": 1.0}, &"scale_rung_forbidden"],
		[WorldState.AXIS_BODY, {"missing": "left_arm"}, &"value_type_invalid"],
		[WorldState.AXIS_BODY, {"missing": ["", ""]}, &"value_type_invalid"],
		[WorldState.AXIS_BODY, {"missing": ["hand", "hand"]}, &"value_type_invalid"],
		[WorldState.AXIS_BODY, {"wounds": [{"part": "leg"}]}, &"wound_malformed"],
		[WorldState.AXIS_BODY, {"wounds": [{"part": "leg", "kind": "cut", "severity": 1, "permanent": false, "extra": 1}]}, &"wound_malformed"],
		[WorldState.AXIS_BODY, {"wounds": [{"part": "leg", "kind": "cut", "severity": "deep", "permanent": false}]}, &"wound_malformed"],
		[WorldState.AXIS_BODY, {"facts": {"here": Vector2.ONE}}, &"value_not_json_safe"],
		[WorldState.AXIS_BODY, {"facts": {1: "int key"}}, &"value_type_invalid"],
		[WorldState.AXIS_BODY, "not a patch", &"patch_not_dictionary"],
		[WorldState.AXIS_BODY, {}, &"patch_empty"],
		[WorldState.AXIS_CREATURE, {"stage": 2}, &"creature_id_invalid"],
		[WorldState.AXIS_CREATURE, {"id": "", "archetype": "x"}, &"creature_id_invalid"],
		[WorldState.AXIS_CREATURE, {"id": "fix.stranger", "stage": 1}, &"creature_unknown"],
		[WorldState.AXIS_CREATURE, {"id": GARDENER, "memory": 3}, &"memory_is_event_list"],
		[WorldState.AXIS_CREATURE, {"id": GARDENER, "memory": ["died"]}, &"memory_is_event_list"],
		[WorldState.AXIS_CREATURE, {"id": GARDENER, "memory": [{}]}, &"memory_entry_empty"],
		[WorldState.AXIS_CREATURE, {"id": GARDENER, "traits": {"mood": Callable()}}, &"value_not_json_safe"],
		[WorldState.AXIS_CREATURE, {"id": GARDENER, "stage": 1.5}, &"value_type_invalid"],
	]
	for case: Array in cases:
		var result: Dictionary = store.request_mutation(case[0], case[1], OWNER)
		assert_false(result["ok"], "refused %s" % str(case[1]))
		assert_eq(result["reason"], case[2], "reason for %s" % str(case[1]))
		assert_false(String(result["detail"]).is_empty(), "detail for %s" % str(case[1]))
		assert_eq(store.to_dictionary(), before, "state held after %s" % str(case[1]))


func test_only_the_declared_owner_may_write() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	assert_eq(store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.65}, VISITOR)["reason"], &"requester_not_owner")
	assert_eq(store.request_mutation(WorldState.AXIS_CREATURE, {"id": GARDENER, "state": "dead"}, VISITOR)["reason"], &"requester_not_owner")
	assert_eq(store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.65}, &"")["reason"], &"requester_not_owner")
	assert_eq(store.to_dictionary(), before)
	var undeclared: WorldState = WorldState.new()
	assert_eq(undeclared.request_mutation(WorldState.AXIS_BODY, {"scale": 0.65}, OWNER)["reason"], &"axis_owner_undeclared")
	assert_eq(undeclared.declare_owner(&"resource", OWNER)["reason"], &"axis_unknown")
	assert_eq(undeclared.declare_owner(WorldState.AXIS_BODY, &"")["reason"], &"value_type_invalid")
	assert_true(undeclared.declare_owner(WorldState.AXIS_BODY, &"first")["ok"])
	assert_true(undeclared.declare_owner(WorldState.AXIS_BODY, &"first")["ok"], "declaring the same id twice is a no-op")
	assert_eq(undeclared.declare_owner(WorldState.AXIS_BODY, &"second")["reason"], &"owner_already_declared")
	assert_eq(undeclared.get_owner(WorldState.AXIS_BODY), "first")


func test_arbitration_holds_while_the_owning_kit_is_not_loaded() -> void:
	var store: WorldState = WorldState.new()
	store.declare_owner(WorldState.AXIS_BODY, OWNER)
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.65}, OWNER)["ok"])
	assert_eq(store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.65}, VISITOR)["reason"], &"requester_not_owner")
	assert_eq(store.get_owner(WorldState.AXIS_BODY), String(OWNER))


# ── place 읽기 전용 ────────────────────────────────────────────────────────
func test_place_writes_are_refused_unconditionally() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	var attempts: Array = [
		{"region_id": "region.elsewhere"},
		{"tags": ["new"]},
		{"requires_body": {"scale_min": 0.1}},
		{"requires_body": {"karma_min": 3}},
		{},
	]
	for patch: Dictionary in attempts:
		for requester: StringName in [OWNER, VISITOR, &""]:
			var result: Dictionary = store.request_mutation(WorldState.AXIS_PLACE, patch, requester)
			assert_false(result["ok"], "%s by %s" % [str(patch), String(requester)])
			assert_eq(result["reason"], &"axis_read_only")
	assert_eq(store.to_dictionary(), before)
	assert_false(store.declare_owner(WorldState.AXIS_PLACE, OWNER)["ok"])


# ── 세 장면 ────────────────────────────────────────────────────────────────
func test_scene_a_one_missing_arm_survives_being_read_unchanged() -> void:
	var view: WorldStateView = _world().issue_view()
	var body: Variant = view.get_body()
	assert_eq(body.get_missing(), ["left_arm"] as Array[String])
	assert_true(body.has_missing_part("left_arm"))
	assert_true(view.body_satisfies(GARDEN)["satisfied"])
	assert_true(view.body_satisfies(STAIR)["satisfied"])
	assert_eq(view.body_satisfies(GARDEN)["unmet"], [] as Array[String])
	var mask: Dictionary = view.body_satisfies(MASK)
	assert_false(mask["satisfied"])
	assert_eq(mask["unmet"], ["wounds_absent"] as Array[String])
	var gardener: AxisCreature = view.get_creature(GARDENER)
	assert_eq(gardener.get_state(), "alive")
	assert_true(gardener.remembers({"kind": "planted"}))
	assert_false(gardener.remembers({"kind": "killed"}))


func test_scene_c_requires_a_named_wound_stored_as_a_fact() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {
		"wounds": [{"part": "face", "kind": "scar", "severity": 2, "permanent": true}],
	}, OWNER)["ok"])
	assert_true(store.issue_view().body_satisfies(MASK)["satisfied"])
	assert_eq(store.to_dictionary()["body"]["wounds"], [{"part": "face", "kind": "scar", "severity": 2, "permanent": true}])
	assert_ne(store.to_dictionary(), before)
	assert_false(store.request_mutation(WorldState.AXIS_BODY, {
		"wounds": [{"part": "face", "kind": "scar", "severity": 2}],
	}, OWNER)["ok"])
	assert_eq(store.to_dictionary()["body"]["wounds"], [{"part": "face", "kind": "scar", "severity": 2, "permanent": true}])


func test_scene_b_absence_never_becomes_a_default_scale() -> void:
	var blank: WorldState = WorldState.new()
	blank.load_snapshot({"ax": 1, "body": {"missing": ["left_arm"]}, "places": _places()})
	var unmet: Dictionary = blank.body_satisfies(STAIR)
	assert_true(unmet["ok"])
	assert_false(unmet["satisfied"])
	assert_eq(unmet["unmet"], ["scale_absent"] as Array[String])
	assert_false((blank.to_dictionary()["body"] as Dictionary).has("scale"), "a body with no scale has no scale key")
	assert_null((blank.issue_view().get_body() as AxisBody).get_scale(), "and no accessor invents one")
	blank.declare_owner(WorldState.AXIS_BODY, OWNER)
	assert_true(blank.request_mutation(WorldState.AXIS_BODY, {"scale": 0.28}, OWNER)["ok"])
	assert_eq(blank.body_satisfies(STAIR)["unmet"], ["scale_below_min"] as Array[String])
	var headless: WorldState = WorldState.new()
	assert_eq(headless.body_satisfies(STAIR)["reason"], &"place_unknown")
	headless.load_snapshot({"ax": 1})
	assert_eq(headless.body_satisfies(STAIR)["reason"], &"place_unknown")
	headless.load_snapshot({"ax": 1, "places": _places()})
	assert_eq(headless.body_satisfies(STAIR)["reason"], &"axis_absent")
	assert_false(headless.body_satisfies(STAIR)["satisfied"])


func test_creature_memory_accumulates_events_and_exposes_no_total() -> void:
	var store: WorldState = _world()
	var memory: Array = (_snapshot()["creatures"][GARDENER]["memory"] as Array).duplicate(true)
	for round_index: int in range(3):
		var events: Array = memory.duplicate(true)
		events.append({"kind": "withered", "round": round_index})
		memory = events
		assert_true(store.request_mutation(WorldState.AXIS_CREATURE, {"id": GARDENER, "memory": events}, OWNER)["ok"])
	var gardener: AxisCreature = store.issue_view().get_creature(GARDENER)
	assert_eq((gardener.get_memory() as Array).size(), 4)
	assert_true(gardener.remembers({"kind": "withered", "round": 2}))
	assert_false(gardener.remembers({"kind": "withered", "round": 3}))
	var exported: Dictionary = store.to_dictionary()["creatures"][GARDENER]
	assert_eq(exported.keys(), ["id", "archetype", "state", "traits", "memory", "den"] as Array)
	assert_false(exported.has("memory_count"))
	assert_false(exported.has("deaths"))


func test_creature_identity_and_archetype_are_fixed_after_birth() -> void:
	var store: WorldState = _world()
	var before: Dictionary = store.to_dictionary()
	assert_eq(store.request_mutation(WorldState.AXIS_CREATURE, {"id": GARDENER, "archetype": "thief"}, OWNER)["reason"], &"creature_archetype_fixed")
	assert_eq(store.to_dictionary(), before)
	assert_true(store.request_mutation(WorldState.AXIS_CREATURE, {"id": GARDENER, "archetype": "gardener", "state": "dead"}, OWNER)["ok"])
	assert_eq(store.to_dictionary()["creatures"][GARDENER]["state"], "dead")
	assert_true(store.request_mutation(WorldState.AXIS_CREATURE, {"id": "fix.newcomer", "archetype": "gardener"}, OWNER)["ok"])
	assert_eq(store.issue_view().get_creature_ids(), [BUTLER, GARDENER, "fix.newcomer"] as Array[String], "ids are listed in one deterministic order")


func test_creature_state_survives_a_kit_handover_without_reinterpretation() -> void:
	var store: WorldState = _world()
	assert_true(store.request_mutation(WorldState.AXIS_CREATURE, {"id": GARDENER, "state": "dead"}, OWNER)["ok"])
	var view: WorldStateView = store.issue_view()
	var read: AxisCreature = view.get_creature(GARDENER)
	assert_eq(read.get_state(), "dead")
	assert_eq(read.get_archetype(), "gardener")
	assert_eq(read.get_den(), GARDEN)
	assert_true(read.remembers({"kind": "planted"}))
	assert_eq(view.get_creature_ids(), [BUTLER, GARDENER] as Array[String])
	assert_null(view.get_creature("fix.nobody"))
	assert_true(view.has_creature(BUTLER))
	assert_false(view.has_creature("fix.nobody"))


func test_focus_cursor_moves_and_is_refused_for_an_unknown_place() -> void:
	var store: WorldState = _world()
	assert_eq(store.get_focus_place_id(), STAIR)
	assert_eq(store.focus_place("place.elsewhere")["reason"], &"place_unknown")
	assert_eq(store.get_focus_place_id(), STAIR)
	assert_true(store.focus_place(MASK)["ok"])
	assert_eq(store.issue_view().get_focus_place_id(), MASK)
	assert_true(store.focus_place("")["ok"])
	assert_eq(store.get_focus_place_id(), "")
