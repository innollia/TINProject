extends GutTest

const GARDENER: String = "fix.gardener"
const STAIR: String = "place.tea_stair"


func _wound(part: String = "face", kind: String = "scar", severity: int = 2, permanent: bool = true) -> Dictionary:
	return {"part": part, "kind": kind, "severity": severity, "permanent": permanent}


# ── AxisBody ───────────────────────────────────────────────────────────────
func test_body_stores_observable_facts_and_nothing_else() -> void:
	var body: AxisBody = AxisBody.new()
	assert_true(body.apply({"missing": ["left_arm"], "wounds": [_wound()], "scale": 0.65})["ok"])
	assert_eq(body.to_dictionary(), {"missing": ["left_arm"] as Array, "wounds": [_wound()] as Array, "scale": 0.65})
	assert_eq(body.get_scale(), 0.65)
	assert_true(body.has_wound("face", "scar"))
	assert_true(body.has_wound("face", "scar", true))
	assert_false(body.has_wound("face", "scar", false))
	assert_false(body.has_wound("leg", "scar"))
	assert_true(body.has_missing_part("left_arm"))
	assert_false(body.has_missing_part("right_arm"))


func test_body_absence_is_absence_and_never_a_default() -> void:
	var body: AxisBody = AxisBody.new()
	assert_null(body.get_missing())
	assert_null(body.get_wounds())
	assert_null(body.get_facts())
	assert_null(body.get_scale())
	assert_null(body.get_fact(&"carry_load"))
	assert_false(body.has_scale())
	assert_false(body.has_field(AxisBody.FIELD_WOUNDS))
	assert_eq(body.to_dictionary(), {})
	var empty_but_present: AxisBody = AxisBody.new()
	assert_true(empty_but_present.apply({"missing": [], "facts": {}})["ok"])
	assert_eq(empty_but_present.get_missing(), [] as Array[String])
	assert_eq(empty_but_present.get_facts(), {})
	assert_ne(empty_but_present.to_dictionary(), {})
	assert_eq(empty_but_present.satisfies({})["satisfied"], true)


func test_body_applies_fields_independently_and_holds_what_it_refuses() -> void:
	var body: AxisBody = AxisBody.new()
	assert_true(body.apply({"scale": 0.65})["ok"])
	assert_false(body.apply({"scale": 0.65, "missing": "left_arm"})["ok"])
	assert_eq(body.to_dictionary(), {"scale": 0.65})
	assert_false(body.apply({"scale": 3.6, "wounds": [_wound("face", "scar", 1, true), {"part": "leg"}]})["ok"])
	assert_eq(body.to_dictionary(), {"scale": 0.65})
	assert_true(body.apply({"scale": 3.6})["ok"])
	assert_eq(body.to_dictionary(), {"scale": 3.6})


func test_body_rejects_a_derived_summary_under_any_key() -> void:
	var body: AxisBody = AxisBody.new()
	for key: StringName in AxisBody.DERIVED_KEYS:
		assert_eq(body.apply({String(key): 1.0})["reason"], &"derived_value_forbidden", String(key))
		assert_eq(body.apply({"facts": {String(key): 1.0}})["reason"], &"derived_value_forbidden", String(key))
	assert_eq(body.to_dictionary(), {})


## 옛 테스트는 "scale 에는 아무 실수나 들어간다" 를 가정했다. 그 가정은 계단 규칙으로
## 사라졌다. 남은 요구는 두 개다. 옆의 값은 옮겨지지 않는다, 그리고 사다리 밖의 실수는
## 거절 사유를 가지고 거절된다. 가장 가까운 rung 으로 눌러 맞추지 않는다.
func test_body_never_rescales_a_value_into_another_grammar() -> void:
	var body: AxisBody = AxisBody.new()
	assert_true(body.apply({"scale": 3.6, "facts": {"lift": 200, "ratio": 12.5}})["ok"])
	assert_eq(float(body.get_scale()), 3.6)
	assert_eq(int(body.get_fact(&"lift")), 200)
	assert_eq(float(body.get_fact(&"ratio")), 12.5)
	assert_true(body.apply({"facts": {"lift": 199, "ratio": 12.5}})["ok"])
	assert_eq(int(body.get_fact(&"lift")), 199)
	assert_eq(float(body.get_fact(&"ratio")), 12.5, "an untouched value is not moved")
	assert_true(body.apply({"scale": 0.12})["ok"])
	assert_eq(int(body.get_fact(&"lift")), 199, "a scale change does not drag other values")
	for off_ladder: Variant in [199.7, 0.1]:
		var dry: Dictionary = body.check_mutation({"scale": off_ladder})
		assert_false(dry["ok"], str(off_ladder))
		assert_eq(dry["reason"], &"scale_not_rung", str(off_ladder))
		var wet: Dictionary = body.apply({"scale": off_ladder})
		assert_false(wet["ok"], str(off_ladder))
		assert_eq(wet["reason"], &"scale_not_rung", str(off_ladder))
		assert_eq(float(body.get_scale()), 0.12, "a refused float moved no rung")
		assert_eq(float(body.get_fact(&"ratio")), 12.5, "a refused float moved no other value")


func test_body_wounds_are_exactly_four_observable_facts() -> void:
	var body: AxisBody = AxisBody.new()
	for bad: Variant in [
		{"part": "face"},
		{"part": "face", "kind": "scar"},
		{"part": "", "kind": "scar", "severity": 1, "permanent": true},
		{"part": "face", "kind": "", "severity": 1, "permanent": true},
		{"part": "face", "kind": "scar", "severity": NAN, "permanent": true},
		{"part": "face", "kind": "scar", "severity": 1, "permanent": "yes"},
		{"part": "face", "kind": "scar", "severity": 1, "permanent": true, "healed": true},
		"cut",
	]:
		assert_eq(body.apply({"wounds": [bad]})["reason"], &"wound_malformed", str(bad))
	assert_eq(body.to_dictionary(), {})
	assert_true(body.apply({"wounds": [_wound("leg", "cut", 1, false)]})["ok"])
	assert_false(body.has_wound("leg", "cut", true))
	assert_true(body.has_wound("leg", "cut", false))


func test_body_copy_is_detached_from_the_original() -> void:
	var body: AxisBody = AxisBody.new()
	body.apply({"missing": ["left_arm"], "facts": {"lift": 200}})
	var clone: AxisBody = body.copy()
	assert_eq(clone.to_dictionary(), body.to_dictionary())
	assert_true(clone.apply({"facts": {"lift": 1}})["ok"])
	assert_eq(int(body.get_fact(&"lift")), 200)
	assert_eq(int(clone.get_fact(&"lift")), 1)


# ── 요구 조건 ──────────────────────────────────────────────────────────────
func test_requires_body_accepts_capability_keys_only() -> void:
	var body: AxisBody = AxisBody.new()
	for good: Dictionary in [
		{},
		{"scale_min": 0.7},
		{"scale_max": 1.4},
		{"scale_min": 0.7, "scale_max": 1.2},
		{"has_all_parts": ["left_arm", "right_arm"]},
		{"has_wound": {"part": "face", "kind": "scar"}},
		{"has_wound": {"part": "face", "kind": "scar", "permanent": true}},
		{"has_no_wound": {"part": "leg", "kind": "cut"}},
	]:
		assert_true(AxisBody.validate_requirement(good)["ok"], str(good))
	for bad: String in ["karma", "karma_min", "favor", "reputation", "trust", "score", "level", "rank", "deaths", "access", "price"]:
		assert_eq(AxisBody.validate_requirement({bad: 3})["reason"], &"requires_body_not_capability", bad)
	for bad: String in ["can_fly", "swim", "carry", "requires_voice"]:
		assert_eq(AxisBody.validate_requirement({bad: 3})["reason"], &"requires_body_key_unknown", bad)
	for bad: Variant in ["scale_min", {"scale_min": "big"}, {"scale_min": INF}, {"has_all_parts": []}, {"has_all_parts": [""]}, {"has_all_parts": "left_arm"}, {"has_wound": {"kind": "scar"}}, {"has_wound": {"part": "face", "kind": "scar", "permanent": "yes"}}, {"has_wound": "face"}, 5]:
		assert_false(AxisBody.validate_requirement(bad)["ok"], str(bad))


func test_satisfies_reports_absence_as_unmet_never_as_a_default() -> void:
	var body: AxisBody = AxisBody.new()
	var blind: Dictionary = body.satisfies({"scale_min": 0.7})
	assert_true(blind["ok"])
	assert_false(blind["satisfied"])
	assert_eq(blind["unmet"], ["scale_absent"] as Array[String])
	assert_null(body.get_scale(), "the unmet report did not invent a scale")
	body.apply({"scale": 0.28})
	assert_eq(body.satisfies({"scale_min": 0.7})["unmet"], ["scale_below_min"] as Array[String])
	body.apply({"scale": 1.5})
	assert_true(body.satisfies({"scale_min": 0.7, "scale_max": 1.8})["satisfied"])
	assert_eq(body.satisfies({"scale_min": 0.7, "scale_max": 0.8})["unmet"], ["scale_above_max"] as Array[String])
	assert_eq(body.satisfies({"has_wound": {"part": "face", "kind": "scar"}})["unmet"], ["wounds_absent"] as Array[String])
	body.apply({"wounds": [_wound("leg", "cut", 1, false)]})
	assert_eq(body.satisfies({"has_wound": {"part": "face", "kind": "scar"}})["unmet"], ["wound_missing"] as Array[String])
	assert_eq(body.satisfies({"has_no_wound": {"part": "leg", "kind": "cut"}})["unmet"], ["wound_present"] as Array[String])
	assert_true(body.satisfies({"has_no_wound": {"part": "face", "kind": "scar"}})["satisfied"])
	## 옛 테스트는 다리 상처 목록을 얼굴 흉터 목록으로 통째로 바꿔 썼다. 그건 확정 사실을
	## 지우는 것이므로 이제 거절된다. 흉터는 목록에서 빼는 게 아니라 옆에 붙는 것이다.
	## 상처의 신원은 part + kind 이므로 같은 흉터의 재측정은 허용된다.
	var replaced: Dictionary = body.apply({"wounds": [_wound("face", "scar", 2, true)]})
	assert_false(replaced["ok"], "a recorded wound is not un-recorded by listing a different one")
	assert_eq(replaced["reason"], &"body_fact_is_permanent")
	assert_false(String(replaced["detail"]).is_empty())
	assert_true((body.get_wounds() as Array).has(_wound("leg", "cut", 1, false)), "the refused write left the list alone")
	assert_true(body.apply({"wounds": [_wound("leg", "cut", 1, false), _wound("face", "scar", 2, true)]})["ok"], "a permanent fact is joined by another one, never replaced by one")
	assert_true(body.satisfies({"has_wound": {"part": "face", "kind": "scar", "permanent": true}})["satisfied"])
	assert_eq(body.satisfies({"has_wound": {"part": "face", "kind": "scar", "permanent": false}})["unmet"], ["wound_missing"] as Array[String])


func test_missing_parts_are_capability_facts_not_health_numbers() -> void:
	var body: AxisBody = AxisBody.new()
	body.apply({"missing": ["left_arm"]})
	var blocked: Dictionary = body.satisfies({"has_all_parts": ["left_arm", "right_arm"]})
	assert_false(blocked["satisfied"])
	assert_eq(blocked["unmet"], ["part_missing:left_arm"] as Array[String])
	assert_true(body.satisfies({"has_all_parts": ["right_arm"]})["satisfied"])
	assert_true(body.satisfies({"has_all_parts": ["tail"]})["satisfied"], "an unrecorded part is not a missing part")


# ── AxisCreature ───────────────────────────────────────────────────────────
func test_creature_requires_an_id_and_refuses_a_malformed_one() -> void:
	var creature: AxisCreature = AxisCreature.new()
	assert_eq(creature.apply({"archetype": "gardener"})["reason"], &"creature_id_invalid")
	assert_eq(creature.apply({"id": "", "archetype": "gardener"})["reason"], &"creature_id_invalid")
	assert_eq(creature.apply({"id": 7, "archetype": "gardener"})["reason"], &"creature_id_invalid")
	assert_eq(creature.to_dictionary(), {})
	assert_true(creature.apply({"id": GARDENER, "archetype": "gardener"})["ok"])
	assert_eq(creature.get_id(), GARDENER)
	assert_true(creature.apply({"id": GARDENER, "state": "dead"})["ok"])
	assert_eq(creature.get_archetype(), "gardener")
	assert_eq(creature.get_state(), "dead")


func test_creature_absent_fields_stay_absent() -> void:
	var creature: AxisCreature = AxisCreature.new()
	creature.apply({"id": GARDENER, "archetype": "gardener"})
	assert_null(creature.get_stage())
	assert_null(creature.get_state())
	assert_null(creature.get_traits())
	assert_null(creature.get_memory())
	assert_null(creature.get_den())
	assert_false(creature.remembers({"kind": "anything"}))
	assert_eq(creature.to_dictionary(), {"id": GARDENER, "archetype": "gardener"})
	assert_false(creature.to_dictionary().has("stage"))


func test_creature_memory_is_an_event_list_and_never_a_number() -> void:
	var creature: AxisCreature = AxisCreature.new()
	creature.apply({"id": GARDENER, "archetype": "gardener", "memory": [{"kind": "planted"}, {"kind": "withered"}]})
	assert_eq((creature.get_memory() as Array).size(), 2)
	assert_true(creature.remembers({"kind": "planted"}))
	for bad: Variant in [3, 0, "deaths", [1, 2], [{}], [{"kind": "x", "at": Vector2.ONE}], [Callable()], [{"kind": "x", "round": INF}]]:
		var result: Dictionary = creature.apply({"id": GARDENER, "memory": bad})
		assert_false(result["ok"], str(bad))
		assert_true(result["reason"] in [&"memory_is_event_list", &"memory_entry_empty", &"value_not_json_safe", &"value_not_finite"], str(bad))
	assert_eq((creature.get_memory() as Array).size(), 2, "a refused memory left the events alone")
	var before: Dictionary = creature.to_dictionary()
	creature.apply({"id": GARDENER, "memory": [{"kind": "planted"}, {"kind": "withered"}, {"kind": "buried"}]})
	var after: Dictionary = creature.to_dictionary()
	before["memory"] = after["memory"]
	assert_eq(after, before, "growing the event list changed nothing but the event list")
	assert_false((after["memory"] as Array).any(func(event: Dictionary) -> bool: return event.has("count")))


func test_creature_traits_are_authored_facts_and_stay_json_safe() -> void:
	var creature: AxisCreature = AxisCreature.new()
	assert_true(creature.apply({"id": GARDENER, "archetype": "gardener", "traits": {"patience": 2, "fear": ["thunder"], "trust": 0.25}})["ok"])
	assert_eq((creature.get_traits() as Dictionary)["patience"], 2)
	assert_eq(float((creature.get_traits() as Dictionary)["trust"]), 0.25)
	for bad: Variant in [Vector2.ONE, NAN, INF, {"node": Callable()}, {1: "int key"}, "traits", ["patience"]]:
		assert_false(creature.apply({"id": GARDENER, "traits": bad})["ok"], str(bad))
	assert_eq((creature.get_traits() as Dictionary).size(), 3)


func test_creature_copy_is_detached() -> void:
	var creature: AxisCreature = AxisCreature.new()
	creature.apply({"id": GARDENER, "archetype": "gardener", "memory": [{"kind": "planted"}]})
	var clone: AxisCreature = creature.copy()
	assert_true(clone.apply({"id": GARDENER, "memory": []})["ok"])
	assert_eq((creature.get_memory() as Array).size(), 1)
	assert_eq((clone.get_memory() as Array).size(), 0)


# ── AxisPlace ──────────────────────────────────────────────────────────────
func test_place_is_authored_and_its_capability_gate_is_not_a_permission_gate() -> void:
	var created: Dictionary = AxisPlace.create(STAIR, {"region_id": "region.hall", "tags": ["indoor"], "requires_body": {"scale_min": 0.7}})
	assert_true(created["ok"])
	var stair: AxisPlace = created[AxisPlace.KEY_VALUE]
	assert_eq(stair.get_id(), STAIR)
	assert_eq(stair.get_region_id(), "region.hall")
	assert_eq(stair.get_tags(), ["indoor"] as Array[String])
	assert_true(stair.has_tag("indoor"))
	assert_false(stair.has_tag("outdoor"))
	assert_eq(stair.get_requires_body(), {"scale_min": 0.7})
	assert_false(stair.requires_nothing())
	assert_eq(stair.to_dictionary(), {"region_id": "region.hall", "tags": ["indoor"] as Array, "requires_body": {"scale_min": 0.7}})


func test_place_refuses_a_karma_style_threshold_at_authoring_time() -> void:
	for key: String in ["karma", "karma_min", "reputation", "trust_min", "level", "rank", "price", "deaths"]:
		var built: Dictionary = AxisPlace.create("place.x", {"region_id": "region.y", "requires_body": {key: 2}})
		assert_false(built["ok"], key)
		assert_eq(built["reason"], &"requires_body_not_capability", key)
	for key: String in ["can_fly", "any_body", "swim"]:
		assert_eq(AxisPlace.create("place.x", {"region_id": "region.y", "requires_body": {key: true}})["reason"], &"requires_body_key_unknown", key)
	assert_true(AxisPlace.create("place.x", {"region_id": "region.y", "requires_body": {"scale_min": 0.7}})["ok"])
	assert_true(AxisPlace.create("place.x", {"region_id": "region.y", "requires_body": {}})["ok"])


func test_place_rejects_a_malformed_authored_record() -> void:
	for record: Variant in [
		"ruined garden",
		{"tags": []},
		{"region_id": ""},
		{"region_id": "region.y", "tags": "indoor"},
		{"region_id": "region.y", "tags": ["", "a"]},
		{"region_id": "region.y", "tags": ["a", "a"]},
		{"region_id": "region.y", "id": "place.override"},
		{"region_id": "region.y", "requires_body": "scale_min"},
		[],
	]:
		assert_false(AxisPlace.create("place.x", record)["ok"], str(record))
	assert_false(AxisPlace.create("", {"region_id": "region.y"})["ok"])


func test_place_defaults_only_what_authoring_always_supplies() -> void:
	var open: AxisPlace = AxisPlace.create("place.open", {"region_id": "region.waste"})[AxisPlace.KEY_VALUE]
	assert_eq(open.get_tags(), [] as Array[String])
	assert_eq(open.get_requires_body(), {})
	assert_true(open.requires_nothing())
	assert_eq(open.to_dictionary(), {"region_id": "region.waste", "tags": [] as Array, "requires_body": {}})
	var clone: AxisPlace = open.copy()
	assert_eq(clone.to_dictionary(), open.to_dictionary())
	assert_eq(clone.get_id(), open.get_id())
