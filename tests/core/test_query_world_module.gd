extends GutTest

## Query World Kit — GameModule 계약 테스트 (MODULE_CONTRACT §검증).

const ACTIONS: Array[StringName] = [
	&"query_world_left", &"query_world_right", &"query_world_up",
	&"query_world_down", &"query_world_confirm", &"query_world_cancel",
]

var _owned: Array[StringName] = []
var _results: Array[ModuleResult] = []


func after_each() -> void:
	for a: StringName in _owned:
		Input.action_release(a)
		InputMap.erase_action(a)
	_owned.clear()
	_results.clear()


func _spawn(enabled: bool = true, arrival: Dictionary = {}) -> GameModule:
	var packed := load("res://modules/query_world/entry.tscn") as PackedScene
	var game := packed.instantiate() as GameModule
	var ctx := ModuleContext.new()
	ctx.module_id = &"query_world"
	ctx.input_enabled = enabled
	ctx.arrival = arrival
	for a: StringName in ACTIONS:
		if not InputMap.has_action(a):
			InputMap.add_action(a)
			_owned.append(a)
		ctx.allowed_actions.append(a)
	game.context = ctx
	add_child_autofree(game)
	game.load_state({})
	game.enter(ctx)
	game.finished.connect(func(r: ModuleResult) -> void: _results.append(r))
	return game


func test_enter_builds_state_from_content() -> void:
	var game := _spawn()
	assert_not_null(game.get("state"), "enter가 state 구성")
	assert_true((game.get("content_ids") as Array).size() >= 3, "authored case 3개 이상 발견")


func test_query_intent_records_history() -> void:
	var game := _spawn()
	var state: QueryWorldState = game.get("state")
	state.reset_runtime()  # 진입 시드 질의를 제외하고 이 테스트 질의만 측정
	game.call("_on_intent", &"query", {"raw": "등불"})
	assert_eq(state.query_history.size(), 1, "질의 이력 기록")


func test_open_intent_reveals_fragment() -> void:
	var game := _spawn()
	var state: QueryWorldState = game.get("state")
	var first_id: String = ""
	var keys: Array = state.fragments.keys()
	keys.sort()
	first_id = String(keys[0])
	game.call("_on_intent", &"open", {"fragment_id": first_id})
	assert_true(state.revealed.has(first_id), "열람 시 revealed 추가")


func test_disabled_context_blocks_intent() -> void:
	var game := _spawn(false)
	var state: QueryWorldState = game.get("state")
	state.reset_runtime()  # 진입 시드 질의 제거 후, disabled 상태의 intent가 무시되는지 확인
	game.call("_on_intent", &"query", {"raw": "등불"})
	assert_eq(state.query_history.size(), 0, "input disabled면 intent 무시")


func test_save_load_through_module() -> void:
	var game := _spawn()
	game.call("_on_intent", &"query", {"raw": "등불"})
	var saved: Dictionary = game.save_state()
	assert_true(SaveService.is_json_safe(saved), "모듈 저장은 JSON-safe")
	assert_true(saved.has("case_id"), "case_id 포함")


func test_reset_command_clears_runtime() -> void:
	var game := _spawn()
	game.call("_on_intent", &"query", {"raw": "등불"})
	assert_true(game.execute_command(&"reset"), "reset 수락")
	var state: QueryWorldState = game.get("state")
	assert_eq(state.query_history.size(), 0, "reset이 runtime 초기화")


func test_completion_emits_finished_once() -> void:
	var game := _spawn()
	var state: QueryWorldState = game.get("state")
	# 첫 case의 완료 조건을 강제로 채운다
	for rid: Variant in state.required_ids:
		game.call("_on_intent", &"open", {"fragment_id": String(rid)})
	# 결론 질의
	if not state.conclusion_query.is_empty():
		game.call("_on_intent", &"query", {"raw": state.conclusion_query})
	assert_eq(_results.size(), 1, "완료 시 finished 정확히 1회")
	if _results.size() == 1:
		assert_eq(_results[0].outcome, &"completed", "완료 outcome")


func test_unknown_command_rejected() -> void:
	var game := _spawn()
	assert_false(game.execute_command(&"nonsense"), "알 수 없는 명령 거부")


func test_no_duplicate_completion() -> void:
	var game := _spawn()
	var state: QueryWorldState = game.get("state")
	for rid: Variant in state.required_ids:
		game.call("_on_intent", &"open", {"fragment_id": String(rid)})
	if not state.conclusion_query.is_empty():
		game.call("_on_intent", &"query", {"raw": state.conclusion_query})
	var after_first: int = _results.size()
	# 완료 후 추가 행동 — finished 재발화 금지
	game.call("_on_intent", &"query", {"raw": state.conclusion_query})
	var keys: Array = state.fragments.keys()
	keys.sort()
	game.call("_on_intent", &"open", {"fragment_id": String(keys[0])})
	assert_eq(_results.size(), after_first, "완료 후 추가 행동은 finished 재발화 안 함")


func test_exit_clears_state() -> void:
	var game := _spawn()
	game.exit()
	assert_null(game.get("state"), "exit가 state 정리")
