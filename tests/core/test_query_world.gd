extends GutTest

## Query World Kit — 도메인/시스템 자동 테스트 (계획서 §13).

const StateScript = preload("res://modules/query_world/domain/query_world_state.gd")
const LoaderScript = preload("res://modules/query_world/domain/query_world_content_loader.gd")


func _fixture() -> Dictionary:
	# 결정적 픽스처. 태그 부분일치와 결과 상한을 검증하기 위해 6개 파편.
	var frags: Array = []
	for i: int in range(6):
		frags.append({
			"id": "f%d" % i,
			"body": "본문 %d 여기에 hover 조각이 있다" % i,
			"search_tags": ["공통", "고유%d" % i],
			"hover_reveals": [{"span_from": 6, "span_to": 8, "hidden": "숨은 %d" % i}],
			"relations": [],
		})
	return {
		"id": "fixture",
		"seed_query": "공통",
		"fragments": frags,
		"completion": {"required_ids": ["f0", "f1"], "conclusion_query": "고유0"},
	}


func _state() -> QueryWorldState:
	var s := StateScript.new()
	s.load_case(_fixture())
	return s


# --- QueryEngine --------------------------------------------------------
func test_query_is_deterministic() -> void:
	var a := _state()
	var b := _state()
	var ra: Dictionary = a.run_query("공통", 1)
	var rb: Dictionary = b.run_query("공통", 2)
	assert_eq(ra["matched"], rb["matched"], "같은 case+query는 같은 결과")


func test_result_cap_is_five() -> void:
	var s := _state()
	var r: Dictionary = s.run_query("공통", 0)
	assert_eq(int(r["count"]), 6, "총 6건 매칭")
	assert_eq((r["matched"] as Array).size(), 5, "표시는 5건 상한")
	assert_true(bool(r["capped"]), "상한 초과 신호")


func test_empty_query_is_recorded_not_error() -> void:
	var s := _state()
	var r: Dictionary = s.run_query("존재하지않는단어", 0)
	assert_true(bool(r["empty"]), "매칭 0")
	assert_eq(s.query_history.size(), 1, "실패도 이력에 남는다")


func test_partial_match() -> void:
	var s := _state()
	var r: Dictionary = s.run_query("고유3", 0)
	assert_true((r["matched"] as Array).has("f3"), "고유 태그 매칭")


# --- HoverRevealLayer ---------------------------------------------------
func test_hover_reveals_hidden_text() -> void:
	var s := _state()
	var hidden: String = s.peek_hover("f2", "f2#h0")
	assert_eq(hidden, "숨은 2", "정확한 hidden 노출")
	assert_true(s.hover_seen.has("f2#h0"), "hover_seen 기록")


func test_hover_unknown_returns_empty() -> void:
	var s := _state()
	assert_eq(s.peek_hover("f2", "nope"), "", "없는 hover는 빈 문자열")


# --- 노출 추적 색 코드 ---------------------------------------------------
func test_reveal_status_colors() -> void:
	var s := _state()
	assert_eq(s.reveal_status("f0"), &"unrevealed", "미열람=빨강")
	s.open_fragment("f0")
	s.open_fragment("f1")
	assert_eq(s.reveal_status("f0"), &"revealed", "열람함=초록")
	assert_eq(s.reveal_status("f1"), &"last", "마지막=노랑")


# --- CompletionEvaluator ------------------------------------------------
func test_completion_requires_all_and_conclusion() -> void:
	var s := _state()
	s.open_fragment("f0")
	assert_false(s.evaluate_completion("고유0"), "required 미충족이면 미완료")
	s.open_fragment("f1")
	assert_false(s.evaluate_completion("틀린질의"), "결론 질의 불일치면 미완료")
	assert_true(s.evaluate_completion("고유0"), "required 충족 + 결론 질의 일치 → 완료")


func test_completion_without_conclusion_query() -> void:
	var case: Dictionary = _fixture()
	case["completion"] = {"required_ids": ["f0"], "conclusion_query": ""}
	var s := StateScript.new()
	s.load_case(case)
	s.open_fragment("f0")
	assert_true(s.evaluate_completion(""), "결론 질의 없으면 required 열람만으로 완료")


# --- 저장 / 로드 --------------------------------------------------------
func test_save_load_roundtrip() -> void:
	var s := _state()
	s.run_query("공통", 5)
	s.open_fragment("f0")
	s.peek_hover("f0", "f0#h0")
	var saved: Dictionary = s.save_runtime()
	var s2 := _state()
	s2.load_runtime(saved)
	assert_eq(s2.revealed_count(), 1, "revealed 복원")
	assert_eq(s2.last_opened, "f0", "last_opened 복원")
	assert_true(s2.hover_seen.has("f0#h0"), "hover_seen 복원")
	assert_eq(s2.query_history.size(), 1, "query_history 복원")


func test_stale_fragment_id_dropped() -> void:
	var s := _state()
	var dropped: int = s.load_runtime({"revealed": ["f0", "ghost", "f1"], "case_id": "fixture"})
	assert_eq(dropped, 1, "존재하지 않는 fragment_id drop")
	assert_eq(s.revealed_count(), 2, "유효한 것만 복원")


func test_save_is_json_safe() -> void:
	var s := _state()
	s.run_query("공통", 1)
	s.open_fragment("f0")
	assert_true(SaveService.is_json_safe(s.save_runtime()), "저장 상태는 JSON-safe")


func test_reset_clears_runtime_keeps_fragments() -> void:
	var s := _state()
	s.run_query("공통", 1)
	s.open_fragment("f0")
	s.reset_runtime()
	assert_eq(s.revealed_count(), 0, "runtime 초기화")
	assert_eq(s.query_history.size(), 0, "이력 초기화")
	assert_eq(s.total_fragments(), 6, "authored 파편은 보존")


# --- Content loader / validation ----------------------------------------
func test_authored_cases_load_and_validate() -> void:
	var all: Array = LoaderScript.load_all()
	assert_true(all.size() >= 3, "authored case 3개 이상 로드")
	for c: Variant in all:
		assert_true(LoaderScript.validate_case(c), "각 case 검증 통과")


func test_validation_rejects_empty_tags() -> void:
	var bad: Dictionary = {
		"id": "bad",
		"fragments": [{"id": "x", "body": "b", "search_tags": [], "relations": []}],
		"completion": {"required_ids": [], "conclusion_query": ""},
	}
	assert_false(LoaderScript.validate_case(bad), "빈 search_tags 거부")


func test_validation_rejects_duplicate_ids() -> void:
	var bad: Dictionary = {
		"id": "bad",
		"fragments": [
			{"id": "x", "body": "b", "search_tags": ["t"], "relations": []},
			{"id": "x", "body": "c", "search_tags": ["u"], "relations": []},
		],
		"completion": {"required_ids": [], "conclusion_query": ""},
	}
	assert_false(LoaderScript.validate_case(bad), "중복 fragment_id 거부")


func test_validation_rejects_dangling_relation() -> void:
	var bad: Dictionary = {
		"id": "bad",
		"fragments": [{"id": "x", "body": "b", "search_tags": ["t"], "relations": [{"to": "ghost", "kind": "mentions"}]}],
		"completion": {"required_ids": [], "conclusion_query": ""},
	}
	assert_false(LoaderScript.validate_case(bad), "dangling relation 거부")


func test_validation_rejects_bad_required_id() -> void:
	var bad: Dictionary = {
		"id": "bad",
		"fragments": [{"id": "x", "body": "b", "search_tags": ["t"], "relations": []}],
		"completion": {"required_ids": ["ghost"], "conclusion_query": ""},
	}
	assert_false(LoaderScript.validate_case(bad), "존재하지 않는 required_id 거부")
