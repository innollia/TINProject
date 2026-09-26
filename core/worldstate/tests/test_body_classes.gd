extends GutTest

const OWNER: StringName = &"sideview_ecosystem"
const STAIR: String = "place.tea_stair"

## 닫힌 6단 사다리. 이 테스트 파일은 스토어 사다리와 같은 숫자를 요구한다.
## (core/worldstate/DESIGN_DECISION.md §2.1.2)
const LADDER: Array[float] = [0.05, 0.12, 0.28, 0.65, 1.5, 3.6]


func _store() -> WorldState:
	var store: WorldState = WorldState.new()
	store.declare_owner(WorldState.AXIS_BODY, OWNER)
	return store


func _wound(part: String, kind: String, severity: Variant, permanent: bool) -> Dictionary:
	return {"part": part, "kind": kind, "severity": severity, "permanent": permanent}


# ── 사다리 ──────────────────────────────────────────────────────────────────
func test_every_one_of_the_six_rungs_is_a_legal_body_scale() -> void:
	assert_eq(AxisBody.SCALE_RUNGS, LADDER, "the ladder is closed and holds exactly these six")
	assert_eq(AxisBody.SCALE_RUNGS.size(), 6)
	for rung: float in AxisBody.SCALE_RUNGS:
		var body: AxisBody = AxisBody.new()
		var result: Dictionary = body.apply({"scale": rung})
		assert_true(result["ok"], str(rung))
		assert_eq(float(body.get_scale()), rung, "a rung is stored as it was written")
		assert_true(body.has_scale())
		assert_eq(result["reason"], WorldState.REASON_OK)


func test_a_value_between_two_rungs_is_refused_and_never_snapped() -> void:
	var body: AxisBody = AxisBody.new()
	assert_true(body.apply({"scale": 0.65})["ok"])
	for between: Variant in [0.065, 0.13, 0.2, 0.3, 0.7, 0.9, 1.49, 2.0, 2.5, 3.59, 199.7, 0.0, -1.0]:
		var result: Dictionary = body.apply({"scale": between})
		assert_false(result["ok"], str(between))
		assert_eq(result["reason"], WorldState.REASON_SCALE_NOT_RUNG, str(between))
		assert_false(String(result["detail"]).is_empty(), str(between))
	assert_eq(float(body.get_scale()), 0.65, "no refused value moved the stored rung")
	assert_eq(body.to_dictionary(), {"scale": 0.65})


func test_one_point_zero_is_refused_with_its_own_reason() -> void:
	var body: AxisBody = AxisBody.new()
	for forbidden: Variant in [1.0, 1]:
		var result: Dictionary = body.apply({"scale": forbidden})
		assert_false(result["ok"], str(forbidden))
		assert_eq(result["reason"], WorldState.REASON_SCALE_RUNG_FORBIDDEN, str(forbidden))
	assert_false(body.has_scale(), "a refused ladder write leaves the body with no scale at all")
	assert_null(body.get_scale())
	assert_eq(body.to_dictionary(), {})
	var store: WorldState = _store()
	assert_eq(store.request_mutation(WorldState.AXIS_BODY, {"scale": 1.0}, OWNER)["reason"], WorldState.REASON_SCALE_RUNG_FORBIDDEN)
	assert_eq(store.request_mutation(WorldState.AXIS_BODY, {"scale": 0.9}, OWNER)["reason"], WorldState.REASON_SCALE_NOT_RUNG)
	assert_false(store.to_dictionary().has("body"), "a refused first write created nothing")
	## 1.0 금지는 몸 축의 최상위 scale 에만 걸린다. 상처의 severity, 관측값, 요구조건의
	## 임계값은 다른 문제다. (§2.1.2)
	assert_true(body.apply({"wounds": [_wound("leg", "cut", 1.0, false)]})["ok"])
	assert_true(body.apply({"facts": {"reach": 1.0}})["ok"])
	assert_true(AxisBody.validate_requirement({"scale_min": 1.0})["ok"])


func test_absence_of_a_scale_stays_absence_and_reads_as_unmet() -> void:
	var body: AxisBody = AxisBody.new()
	assert_false(body.has_scale())
	assert_null(body.get_scale())
	assert_eq(body.to_dictionary(), {})
	var blind: Dictionary = body.satisfies({"scale_min": 0.7})
	assert_true(blind["ok"])
	assert_false(blind["satisfied"])
	assert_eq(blind["unmet"], ["scale_absent"] as Array[String])
	assert_false(body.apply({"scale": 1.0})["ok"])
	assert_null(body.get_scale(), "a refusal did not leave a default behind")
	assert_eq(body.satisfies({"scale_min": 0.7})["unmet"], ["scale_absent"] as Array[String])
	var store: WorldState = _store()
	assert_true(store.load_snapshot({
		"ax": 1,
		"body": {"missing": ["left_arm"]},
		"places": {STAIR: {"region_id": "region.hall", "requires_body": {"scale_min": 0.7}}},
	})["ok"])
	assert_false((store.to_dictionary()["body"] as Dictionary).has("scale"))
	assert_eq(store.body_satisfies(STAIR)["unmet"], ["scale_absent"] as Array[String])
	assert_null((store.issue_view().get_body() as AxisBody).get_scale())


func test_a_snapshot_off_the_ladder_fails_honestly_and_overwrites_nothing() -> void:
	var store: WorldState = _store()
	assert_true(store.load_snapshot({"ax": 1, "body": {"scale": 0.65}})["ok"])
	var before: Dictionary = store.to_dictionary()
	var between: Dictionary = store.load_snapshot({"ax": 1, "body": {"scale": 0.9, "missing": ["left_arm"]}})
	assert_false(between["ok"])
	assert_eq(between["reason"], WorldState.REASON_SCALE_NOT_RUNG, "a nested record reports the field rule, not a guess")
	assert_eq(store.to_dictionary(), before, "a refused restore overwrites nothing")
	var forbidden: Dictionary = store.load_snapshot({"ax": 1, "body": {"scale": 1.0}})
	assert_false(forbidden["ok"])
	assert_eq(forbidden["reason"], WorldState.REASON_SCALE_RUNG_FORBIDDEN)
	assert_eq(store.to_dictionary(), before)
	var inside: Dictionary = store.load_snapshot({
		"ax": 1,
		"body": {
			"scale": 0.65,
			"wounds": [_wound("leg", "cut", 1.0, false)],
			"facts": {"ratio": 1.0},
		},
	})
	assert_true(inside["ok"], "1.0 is forbidden only as the top level body scale")


## 계단이 생기기 전에 이 저장소가 쓰던 실수들. 이제는 전부 거절 대상이다. 1.0 은 사다리
## 값이 아니라서 거절 사유가 따로 있고, 나머지는 사다리 밖이라 scale_not_rung 이다.
## 어느 것도 가까운 rung 으로 눌러 맞추지 않는다.
func test_every_retired_float_is_now_refused_with_its_own_reason() -> void:
	const RETIRED: Array[float] = [0.9, 0.5, 0.2, 0.1, 199.7]
	for retired: float in RETIRED:
		var body: AxisBody = AxisBody.new()
		assert_true(body.apply({"scale": 3.6})["ok"], "a rung first, so a refusal can be seen to change nothing")
		var dry: Dictionary = body.check_mutation({"scale": retired})
		assert_false(dry["ok"], str(retired))
		assert_eq(dry["reason"], WorldState.REASON_SCALE_NOT_RUNG, str(retired))
		assert_false(String(dry["detail"]).is_empty(), str(retired))
		assert_false(dry.has(AxisBody.KEY_VALUE), str(retired))
		var wet: Dictionary = body.apply({"scale": retired})
		assert_false(wet["ok"], str(retired))
		assert_eq(wet["reason"], WorldState.REASON_SCALE_NOT_RUNG, str(retired))
		assert_eq(float(body.get_scale()), 3.6, "%s was not snapped onto a rung" % str(retired))
		assert_eq(body.to_dictionary(), {"scale": 3.6}, str(retired))
		var store: WorldState = _store()
		var refused: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"scale": retired}, OWNER)
		assert_false(refused["ok"], str(retired))
		assert_eq(refused["reason"], WorldState.REASON_SCALE_NOT_RUNG, str(retired))
		assert_false(store.to_dictionary().has("body"), "%s created nothing" % str(retired))
	for gone: Variant in [1.0, 1]:
		var plain: AxisBody = AxisBody.new()
		var result: Dictionary = plain.apply({"scale": gone})
		assert_false(result["ok"], str(gone))
		assert_eq(result["reason"], WorldState.REASON_SCALE_RUNG_FORBIDDEN, str(gone))
		assert_false(plain.has_scale(), str(gone))
		var store: WorldState = _store()
		assert_eq(store.request_mutation(WorldState.AXIS_BODY, {"scale": gone}, OWNER)["reason"], WorldState.REASON_SCALE_RUNG_FORBIDDEN, str(gone))
	## 사다리 밖의 값은 거절되지만, 없음은 여전히 없음이다. 거절이 기본값을 남기지 않는다.
	var blind: AxisBody = AxisBody.new()
	assert_eq(blind.check_mutation({"scale": 0.9})["reason"], WorldState.REASON_SCALE_NOT_RUNG)
	assert_false(blind.has_scale())
	assert_null(blind.get_scale())
	assert_eq(blind.to_dictionary(), {})
	assert_eq(blind.satisfies({"scale_min": 0.7})["unmet"], ["scale_absent"] as Array[String])


# ── 두 부류 ────────────────────────────────────────────────────────────────
func test_a_permanent_fact_cannot_be_cleared_or_reverted() -> void:
	var store: WorldState = _store()
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {"missing": ["left_arm"]}, OWNER)["ok"])
	var before: Dictionary = store.to_dictionary()
	for attempt: Dictionary in [{"missing": []}, {"missing": ["right_arm"]}]:
		var cleared: Dictionary = store.request_mutation(WorldState.AXIS_BODY, attempt, OWNER)
		assert_false(cleared["ok"], str(attempt))
		assert_eq(cleared["reason"], WorldState.REASON_FACT_PERMANENT, str(attempt))
		assert_false(String(cleared["detail"]).is_empty(), str(attempt))
	assert_eq(store.to_dictionary(), before, "a refused clear changed nothing")
	var joined: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"missing": ["left_arm", "right_arm"]}, OWNER)
	assert_true(joined["ok"], "a permanent fact may still be joined by another one")
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {"wounds": [_wound("face", "scar", 2, true)]}, OWNER)["ok"])
	var emptied: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"wounds": []}, OWNER)
	assert_false(emptied["ok"])
	assert_eq(emptied["reason"], WorldState.REASON_FACT_PERMANENT)
	var swapped: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"wounds": [_wound("leg", "cut", 1, true)]}, OWNER)
	assert_false(swapped["ok"], "replacing the list would un-record the scar")
	assert_eq(swapped["reason"], WorldState.REASON_FACT_PERMANENT)
	assert_eq(
		(store.to_dictionary()["body"] as Dictionary)["wounds"],
		[_wound("face", "scar", 2, true)] as Array,
		"the scar is still the only thing recorded",
	)
	var remeasured: Dictionary = store.request_mutation(WorldState.AXIS_BODY, {"wounds": [_wound("face", "scar", 1, true)]}, OWNER)
	assert_true(remeasured["ok"], "the same wound measured again is the same fact, not a new one")
	assert_eq(float(((store.to_dictionary()["body"] as Dictionary)["wounds"] as Array)[0]["severity"]), 1.0)


func test_a_mutable_capability_can_be_changed_and_changed_back() -> void:
	var store: WorldState = _store()
	var there: float = 0.05
	for pair: Array in [[0.05, 0.12], [0.12, 3.6], [3.6, 1.5], [1.5, 0.28], [0.28, 0.28]]:
		assert_true(store.request_mutation(WorldState.AXIS_BODY, {"scale": pair[0]}, OWNER)["ok"], str(pair[0]))
		there = float(pair[0])
		assert_true(store.request_mutation(WorldState.AXIS_BODY, {"scale": pair[1]}, OWNER)["ok"], str(pair[1]))
		there = float(pair[1])
		assert_eq(float((store.issue_view().get_body() as AxisBody).get_scale()), there, "a capability came back")
	## 되돌릴 수 있다는 것과 저장하지 않아도 된다는 것은 다른 문제다. 세이브/로드가
	## 현재 크기를 복원해야 한다.
	var restored: WorldState = _store()
	assert_true(restored.load_snapshot(store.to_dictionary().duplicate(true))["ok"])
	assert_eq(float((restored.issue_view().get_body() as AxisBody).get_scale()), there, "the rung survived a save and a load")
	var text: String = store.to_json()
	var from_text: WorldState = _store()
	assert_true(from_text.load_json(text)["ok"])
	assert_eq(from_text.to_json(), text)
	assert_eq(float((from_text.issue_view().get_body() as AxisBody).get_scale()), there)


func test_a_rejected_mutation_changes_nothing_and_returns_a_reason() -> void:
	var body: AxisBody = AxisBody.new()
	assert_true(body.apply({"scale": 0.65, "missing": ["left_arm"], "facts": {"lift": 200}})["ok"])
	var before: Dictionary = body.to_dictionary()
	for attempt: Dictionary in [
		{"scale": 0.9},
		{"scale": 1.0},
		{"missing": []},
		{"scale": 0.05, "missing": []},
		{"scale": 0.05, "unknown_field": 1},
	]:
		var dry: Dictionary = body.check_mutation(attempt)
		assert_false(dry["ok"], str(attempt))
		assert_false(String(dry["detail"]).is_empty(), str(attempt))
		assert_false(dry.has(AxisBody.KEY_VALUE), "a dry run hands out nothing to commit")
		assert_eq(body.to_dictionary(), before, "check_mutation changed nothing")
		var wet: Dictionary = body.apply(attempt)
		assert_eq(wet["reason"], dry["reason"], "the dry run and the write agree on %s" % str(attempt))
		assert_false(wet["ok"], str(attempt))
		assert_eq(body.to_dictionary(), before, str(attempt))
	assert_true(body.check_mutation({"scale": 3.6, "missing": ["left_arm", "tail"]})["ok"])


func test_the_class_of_every_body_field_is_discoverable_and_the_two_classes_are_disjoint() -> void:
	var body: AxisBody = AxisBody.new()
	var expected: Dictionary = {
		String(AxisBody.FIELD_MISSING): AxisBody.CLASS_PERMANENT_FACT,
		String(AxisBody.FIELD_WOUNDS): AxisBody.CLASS_PERMANENT_FACT,
		String(AxisBody.FIELD_SCALE): AxisBody.CLASS_MUTABLE_CAPABILITY,
		String(AxisBody.FIELD_FACTS): AxisBody.CLASS_UNCLASSED,
	}
	assert_eq(AxisBody.FIELD_CLASSES, expected, "the class table is closed and holds one answer per field")
	var permanent: Array[String] = []
	var capability: Array[String] = []
	for name: StringName in AxisBody.FIELDS:
		var found: Dictionary = body.field_class(name)
		assert_true(found["ok"], String(name))
		assert_eq(found["value"], String(expected[String(name)]), String(name))
		if found["value"] == AxisBody.CLASS_PERMANENT_FACT:
			permanent.append(String(name))
		elif found["value"] == AxisBody.CLASS_MUTABLE_CAPABILITY:
			capability.append(String(name))
	assert_eq(permanent, ["missing", "wounds"] as Array[String], "the progression axis is the recorded facts")
	assert_eq(capability, ["scale"], "the capability axis is scale alone")
	for name: String in permanent:
		assert_false(capability.has(name), "%s is on one axis only" % name)
	var unknown: Dictionary = body.field_class(&"resource")
	assert_false(unknown["ok"])
	assert_eq(unknown["reason"], WorldState.REASON_KEY_UNKNOWN)
	assert_false(unknown.has(AxisBody.KEY_VALUE), "a field that does not exist has no class")


func test_a_capability_is_never_recorded_as_a_fact_and_a_fact_is_never_a_capability() -> void:
	var body: AxisBody = AxisBody.new()
	assert_true(body.apply({"scale": 0.65, "missing": ["left_arm"], "facts": {"lift": 200}})["ok"])
	assert_false(body.has_fact(AxisBody.FIELD_SCALE), "the ladder has one home and facts is not it")
	assert_eq(body.field_class(AxisBody.FIELD_SCALE)["value"], AxisBody.CLASS_MUTABLE_CAPABILITY)
	## 요구조건은 능력 조건만 받는다. 누적값·권한 계열 이름으로 진행 게이트를 위장할
	## 수 없다. (§2.1.1, §2.3)
	for gate: String in ["karma", "karma_min", "progress", "level", "deaths", "clearance"]:
		assert_eq(AxisBody.validate_requirement({gate: 1})["reason"], WorldState.REASON_NOT_CAPABILITY, gate)
	## 가변 능력은 통과 조건이 될 수는 있다(§5-B). 누적값이 되지는 못한다.
	assert_true(AxisBody.validate_requirement({"scale_min": 0.4, "scale_max": 1.4})["ok"])


# ── 정규화 금지 회귀 ───────────────────────────────────────────────────────
func test_the_store_still_refuses_to_normalise_anything() -> void:
	var store: WorldState = _store()
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {
		"scale": 3.6,
		"facts": {"lift": 200, "ratio": 12.5, "reach": 199.7},
	}, OWNER)["ok"])
	assert_true(store.request_mutation(WorldState.AXIS_BODY, {
		"facts": {"lift": 199, "ratio": 12.5, "reach": 199.7},
	}, OWNER)["ok"])
	var body: Dictionary = store.to_dictionary()["body"] as Dictionary
	assert_eq(float(body["scale"]), 3.6, "a neighbouring value was not moved")
	assert_eq(int(body["facts"]["lift"]), 199, "a value drops by exactly what was patched")
	assert_eq(float(body["facts"]["ratio"]), 12.5, "an untouched value is not moved")
	assert_eq(float(body["facts"]["reach"]), 199.7, "a continuous float is still a legal observation")
	var text: String = store.to_json()
	var restored: WorldState = _store()
	assert_true(restored.load_json(text)["ok"], "wire type restoration is unchanged")
	var reread: Dictionary = restored.to_dictionary()["body"] as Dictionary
	assert_eq(restored.to_json(), text, "the text round trip is stable")
	assert_true(reread["scale"] is float, "a rung is written with a decimal point and comes back a float")
	assert_true(reread["facts"]["reach"] is float)
	assert_true(reread["facts"]["lift"] is int, "an int is not quietly turned into a float on the way back")
	assert_eq(float(reread["facts"]["reach"]), 199.7, "a value came back bit for bit")
	assert_eq(reread, body)
