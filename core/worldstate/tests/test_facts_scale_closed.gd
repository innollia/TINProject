extends GutTest

# facts["scale"] 은 닫혔다. 몸의 크기는 최상위 scale 필드에 하나만 산다.
# 정본: core/worldstate/DESIGN_DECISION.md §2.1.3.
#
# 이 파일은 세 가지를 붙든다.
#   1. 그 키로 들어가는 모든 입구가 같은 사유로 거절하고 아무것도 바꾸지 않는다.
#   2. 이미 디스크에 있는, 그 키를 담은 스냅샷은 정직하게 실패한다.
#   3. 금지 범위가 "scale" 한 이름뿐이라 정상 관측값은 계속 들어간다.

const OWNER: StringName = &"sideview_ecosystem"
const STAIR: String = "place.tea_stair"


func _store() -> WorldState:
	var store: WorldState = WorldState.new()
	store.declare_owner(WorldState.AXIS_BODY, OWNER)
	store.declare_owner(WorldState.AXIS_CREATURE, OWNER)
	return store


## 관측값 하나를 먼저 넣어 두고, 거절이 그 값을 건드리지 않았음을 보게 한다.
func _stocked() -> AxisBody:
	var body: AxisBody = AxisBody.new()
	assert_true(body.apply({"scale": 0.65, "facts": {"carry_load": 200}})["ok"], "the fixture itself must be legal")
	return body


# ── 금지 목록의 크기 ────────────────────────────────────────────────────────
func test_the_reserved_list_is_closed_and_holds_the_ladder_name_alone() -> void:
	assert_eq(AxisBody.FACTS_RESERVED_KEYS, [&"scale"] as Array[StringName], "one name, and it is the one the ladder already owns")
	assert_false(AxisBody.DERIVED_KEYS.has(&"scale"), "a reserved name is not a derived name, and it is not smuggled in as one")
	assert_true(AxisBody.FIELDS.has(&"scale"), "the size still lives in the body scale field")


# ── apply ───────────────────────────────────────────────────────────────────
func test_apply_refuses_a_facts_scale_with_key_unknown_and_changes_nothing() -> void:
	var body: AxisBody = _stocked()
	var before: Dictionary = body.to_dictionary()
	for bad: Dictionary in [
		{"facts": {"scale": 0.65}},
		{"facts": {"scale": 0.13}},
		{"facts": {"scale": 1.0}},
		{"facts": {"scale": "colossal"}},
		{"facts": {"scale": null}},
		{"facts": {"scale": [0.65, 0.12]}},
		{"facts": {"carry_load": 200, "scale": 0.13}},
	]:
		var result: Dictionary = body.apply(bad)
		assert_false(result["ok"], str(bad))
		assert_eq(result["reason"], WorldState.REASON_KEY_UNKNOWN, str(bad))
		assert_false(String(result["detail"]).is_empty(), str(bad))
		assert_false(result.has(AxisBody.KEY_VALUE), "a refused write hands out nothing")
	assert_eq(body.to_dictionary(), before, "every refused write left the body exactly as it was")
	assert_false(body.has_fact(&"scale"))
	assert_null(body.get_fact(&"scale"))
	assert_eq(int(body.get_fact(&"carry_load")), 200, "the neighbouring observation was not touched")


func test_a_refused_facts_scale_does_not_even_reach_the_emptier_body() -> void:
	var empty: AxisBody = AxisBody.new()
	var result: Dictionary = empty.apply({"facts": {"scale": 0.13}})
	assert_false(result["ok"])
	assert_eq(result["reason"], WorldState.REASON_KEY_UNKNOWN)
	assert_eq(empty.to_dictionary(), {}, "a refusal created no body and no facts")
	assert_null(empty.get_facts())
	assert_false(empty.has_field(AxisBody.FIELD_FACTS), "absence stays absence")


# ── check_mutation ──────────────────────────────────────────────────────────
func test_check_mutation_gives_the_same_reason_and_commits_nothing() -> void:
	var body: AxisBody = _stocked()
	var before: Dictionary = body.to_dictionary()
	var dry: Dictionary = body.check_mutation({"facts": {"scale": 0.13}})
	assert_false(dry["ok"])
	assert_eq(dry["reason"], WorldState.REASON_KEY_UNKNOWN, "a dry run names the field rule, not a guess")
	assert_false(dry.has(AxisBody.KEY_VALUE), "there is nothing to commit by accident")
	var wet: Dictionary = body.apply({"facts": {"scale": 0.13}})
	assert_eq(wet["reason"], dry["reason"], "ask and write agree")
	assert_eq(body.to_dictionary(), before, "asking did not write")
	assert_eq((body.copy() as AxisBody).to_dictionary(), before, "a copy of a body that was asked about carries no such key")


# ── request_mutation ────────────────────────────────────────────────────────
func test_request_mutation_refuses_it_at_the_store_and_the_store_is_untouched() -> void:
	var store: WorldState = _store()
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.65, "facts": {"carry_load": 200}}, OWNER)["ok"])
	var before: Dictionary = store.to_dictionary()
	var result: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"facts": {"scale": 0.13}}, OWNER)
	assert_false(result["ok"])
	assert_eq(result["reason"], WorldState.REASON_KEY_UNKNOWN)
	assert_eq(store.to_dictionary(), before, "the store did not move")
	var read_back: AxisBody = store.issue_view().get_body()
	assert_false(read_back.has_fact(&"scale"))
	assert_eq(float(read_back.get_scale()), 0.65, "the ladder value the body had is still the one it has")
	## 첫 쓰기부터 거절되는 경우에도 몸이 만들어지지 않는다.
	var fresh: WorldState = _store()
	var first: Dictionary = fresh.request_mutation(WorldState.AXIS_BODY, {"facts": {"scale": 0.13}}, OWNER)
	assert_false(first["ok"])
	assert_eq(first["reason"], WorldState.REASON_KEY_UNKNOWN)
	assert_false(fresh.to_dictionary().has("body"), "a refused first write created nothing")
	assert_null(fresh.issue_view().get_body())


# ── 복원 ────────────────────────────────────────────────────────────────────
func test_a_snapshot_that_already_carries_the_banned_key_is_refused_honestly() -> void:
	var store: WorldState = _store()
	assert_true(store.load_snapshot({
		"ax": 1,
		"body": {"scale": 1.5, "missing": ["left_arm"], "facts": {"carry_load": 200}},
		"places": {STAIR: {"region_id": "region.hall", "requires_body": {"scale_min": 0.7}}},
	})["ok"])
	var before: Dictionary = store.to_dictionary()
	var stale: Dictionary = store.load_snapshot({
		"ax": 1,
		"body": {"scale": 0.65, "missing": ["right_arm"], "facts": {"scale": 0.13, "carry_load": 199}},
	})
	assert_false(stale["ok"], "a save from before this rule fails")
	assert_eq(stale["reason"], WorldState.REASON_KEY_UNKNOWN, "it is not normalised away and not reported as a generic malformation")
	assert_false(String(stale["detail"]).is_empty())
	assert_eq(store.to_dictionary(), before, "nothing was overwritten, stripped or half applied")
	var body: AxisBody = store.issue_view().get_body()
	assert_eq((body.get_missing() as Array[String]), ["left_arm"] as Array[String], "the old missing entry is still the recorded one")
	assert_eq(int(body.get_fact(&"carry_load")), 200, "the old observation is still the recorded one")
	assert_eq(float(body.get_scale()), 1.5)
	assert_eq(store.body_satisfies(STAIR)["satisfied"], true, "the store is the one it was before the refused load")


func test_a_json_text_carrying_the_banned_key_fails_the_same_way() -> void:
	var store: WorldState = _store()
	assert_true(store.load_snapshot({"ax": 1, "body": {"scale": 0.65, "facts": {"carry_load": 200}}})["ok"])
	var before: Dictionary = store.to_dictionary()
	var hand_written: String = '{"ax":1,"body":{"scale":0.65,"facts":{"scale":0.13}}}'
	var result: Dictionary = store.load_json(hand_written)
	assert_false(result["ok"])
	assert_eq(result["reason"], WorldState.REASON_KEY_UNKNOWN, "the text path is the same entrance, not a second one")
	assert_eq(store.to_dictionary(), before)
	## 정상적인 본문은 여전히 왕복한다. 거절은 이 키 하나에만 걸린다.
	var text: String = store.to_json()
	var round_tripped: WorldState = _store()
	assert_true(round_tripped.load_json(text)["ok"])
	assert_eq(round_tripped.to_json(), text)


# ── 금지가 좁다는 것 ────────────────────────────────────────────────────────
func test_other_facts_keys_are_untouched_and_the_ban_is_one_name_wide() -> void:
	var body: AxisBody = AxisBody.new()
	var observations: Dictionary = {
		"carry_load": 200,
		"ratio": 12.5,
		"reach": 199.7,
		"whole_float": 1.0,
		"note": "1.0 and 200 are words here",
		"pair": [1, 2.5],
		"nested": {"arm": "left", "seen": false},
		"size_words": "colossal",
	}
	assert_true(body.apply({"facts": observations})["ok"], "a legitimate observation bag is still open")
	for name: String in observations:
		assert_true(body.has_fact(StringName(name)), name)
	assert_eq(int(body.get_fact(&"carry_load")), 200)
	assert_eq(float(body.get_fact(&"reach")), 199.7, "a continuous float is still a legal observation")
	assert_eq(body.get_fact(&"note"), "1.0 and 200 are words here", "the digits in a string are not a size")
	assert_eq(body.get_fact(&"size_words"), "colossal", "a rung name as text is a word, not a rung")
	assert_eq((body.get_fact(&"nested") as Dictionary)["arm"], "left")
	## 1.0 금지는 몸 축의 최상위 scale 에만 걸린다. 관측값 안의 1.0 은 관측값이다.
	assert_true(body.apply({"facts": {"ratio": 1.0}})["ok"])
	assert_eq(float(body.get_fact(&"ratio")), 1.0, "1.0 inside facts is not the top level scale, so it is not this rule")
	## 금지 키가 섞인 요청은 통째로 거절된다. 그 요청의 나머지(합법적인 절반)는
	## 어딘가에도 가지 않는다. 한 키의 금지가 관측값 전체를 얼리지도 않는다.
	var facts_before: Dictionary = body.get_facts()
	var added: Dictionary = body.apply({"facts": {"carry_load": 199, "scale": 0.13}})
	assert_false(added["ok"])
	assert_eq(added["reason"], WorldState.REASON_KEY_UNKNOWN)
	assert_eq(body.get_facts(), facts_before, "the refused patch took its legal half nowhere")
	assert_false(body.has_fact(&"carry_load"), "and it did not land half of itself either")
	## 그래도 관측값 자리는 열려 있다. 한 이름만 닫혔다.
	assert_true(body.apply({"facts": {"carry_load": 199}})["ok"])
	assert_eq(int(body.get_fact(&"carry_load")), 199)
	## 닫힌 이름이 하나뿐이라는 사실은 목록으로 검사된다. 이름이 늘면 이 테스트가 붕괴한다.
	assert_eq(AxisBody.FACTS_RESERVED_KEYS.size(), 1)


func test_a_body_with_a_rung_and_observations_reads_back_completely() -> void:
	var store: WorldState = _store()
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {
		"scale": 3.6,
		"missing": ["left_arm"],
		"wounds": [{"part": "left_arm", "kind": "severed", "severity": 1, "permanent": true}],
		"facts": {"carry_load": 200, "reach": 199.7},
	}, OWNER)["ok"])
	for reader: String in ["apply-then-read", "view", "store dictionary", "json text"]:
		var read: AxisBody = null
		match reader:
			"apply-then-read":
				read = AxisBody.new()
				assert_true(read.apply(store.to_dictionary()["body"])["ok"], reader)
			"view":
				read = store.issue_view().get_body()
			"store dictionary":
				read = AxisBody.new()
				assert_true(read.apply(store.to_dictionary()["body"])["ok"], reader)
			"json text":
				var other: WorldState = _store()
				assert_true(other.load_json(store.to_json())["ok"], reader)
				read = other.issue_view().get_body()
		assert_not_null(read, reader)
		assert_eq(float(read.get_scale()), 3.6, "%s: the rung is intact" % reader)
		assert_eq(int(read.get_fact(&"carry_load")), 200, "%s: the observation is intact" % reader)
		assert_eq(float(read.get_fact(&"reach")), 199.7, "%s: a continuous float came back bit for bit" % reader)
		assert_false(read.has_fact(&"scale"), "%s: facts did not grow a second size channel" % reader)
		assert_true(read.has_wound("left_arm", "severed", true), reader)
		assert_true(read.has_missing_part("left_arm"), reader)


func test_a_body_with_no_facts_at_all_round_trips_untouched() -> void:
	var store: WorldState = WorldState.new()
	store.declare_owner(WorldState.AXIS_BODY, OWNER)
	assert_true(store.load_snapshot({"ax": 1, "body": {"scale": 0.12}})["ok"])
	var text: String = store.to_json()
	assert_eq(text, '{"ax":1,"body":{"scale":0.12},"focus_place_id":"","owners":{"body":"sideview_ecosystem"}}', "no facts key is invented for a body that never had one")
	var restored: WorldState = WorldState.new()
	restored.declare_owner(WorldState.AXIS_BODY, OWNER)
	assert_true(restored.load_json(text)["ok"])
	assert_eq(restored.to_json(), text)
	var body: AxisBody = restored.issue_view().get_body()
	assert_null(body.get_facts(), "absence stayed absence through the round trip")
	assert_false(body.has_field(AxisBody.FIELD_FACTS))
	assert_eq(float(body.get_scale()), 0.12)
	var bare: AxisBody = AxisBody.new()
	assert_true(bare.apply({"facts": {}})["ok"], "an empty bag is present-and-empty, which is not the same as absent")
	assert_eq(bare.get_facts(), {})
	assert_false(bare.has_fact(&"scale"))


# ── 옆 이름은 별개의 문제다 ─────────────────────────────────────────────────
func test_the_ladder_neighbours_are_unaffected_by_this_rule() -> void:
	## 요구조건은 scale_min / scale_max 만 받는다. 키 이름 "scale" 은 요구조건 이름이
	## 아니므로 이 규칙이 아니라 requires_body_key_unknown 으로 닫혀 있다. (§2.3)
	assert_eq(AxisBody.validate_requirement({"scale": 1.0})["reason"], &"requires_body_key_unknown")
	assert_true(AxisBody.validate_requirement({"scale_min": 0.7, "scale_max": 1.4})["ok"])
	## 상처의 severity 도 별개다. 몸의 크기가 아니다.
	var body: AxisBody = AxisBody.new()
	assert_true(body.apply({"wounds": [{"part": "leg", "kind": "cut", "severity": 1.0, "permanent": false}]})["ok"])
	assert_eq(float((body.get_wounds() as Array)[0]["severity"]), 1.0)
	## 상대의 크기는 그 상대의 사실이다. 몸 축의 facts 규칙은 남의 몸까지 다룬다.
	var store: WorldState = _store()
	assert_true(store.request_mutation(WorldState.AXIS_CREATURE, {
		"id": "fix.gardener",
		"archetype": "gardener",
		"traits": {"scale": "colossal"},
	}, OWNER)["ok"], "a creature's own traits are not the body scale channel")
