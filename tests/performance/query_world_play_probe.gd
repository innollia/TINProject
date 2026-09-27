extends SceneTree

## Query World Kit — 런타임 플레이 프로브.
## 실제 씬을 인스턴스화해 한 사건을 처음부터 완료까지 구동한다.
## 검색 → 파편 열람 → 결론 질의 → finished 발화를 런타임에서 검증.

var _finished_count: int = 0
var _finished_case: String = ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load("res://modules/query_world/entry.tscn") as PackedScene
	var game: GameModule = packed.instantiate() as GameModule
	var ctx := ModuleContext.new()
	ctx.module_id = &"query_world"
	ctx.input_enabled = true
	for a: StringName in [&"query_world_left", &"query_world_right", &"query_world_up", &"query_world_down", &"query_world_confirm", &"query_world_cancel"]:
		if not InputMap.has_action(a):
			InputMap.add_action(a)
		ctx.allowed_actions.append(a)
	game.context = ctx
	root.add_child(game)
	game.finished.connect(func(r: ModuleResult) -> void:
		_finished_count += 1
		_finished_case = String(r.data.get("case_id", ""))
	)
	await process_frame
	game.load_state({})
	game.enter(ctx)
	await process_frame

	var state: Variant = game.get("state")
	var checks: int = 0
	var failed: int = 0

	# 1. 시드 질의가 결과를 냈는가
	checks += 1
	if state.query_history.is_empty():
		failed += 1; printerr("FAIL: seed query produced no history")

	# 2. required 파편을 모두 열람
	for rid: Variant in state.required_ids:
		game.call("_on_intent", &"open", {"fragment_id": String(rid)})
		await process_frame
	checks += 1
	var all_open: bool = true
	for rid: Variant in state.required_ids:
		if not state.revealed.has(String(rid)):
			all_open = false
	if not all_open:
		failed += 1; printerr("FAIL: not all required fragments revealed")

	# 3. 결론 질의 → finished
	if not String(state.conclusion_query).is_empty():
		game.call("_on_intent", &"query", {"raw": String(state.conclusion_query)})
		await process_frame
	checks += 1
	if _finished_count != 1:
		failed += 1; printerr("FAIL: expected exactly 1 finished, got %d" % _finished_count)
	checks += 1
	if _finished_case != String(state.case_id):
		failed += 1; printerr("FAIL: finished case mismatch: %s vs %s" % [_finished_case, state.case_id])

	# 4. 완료 후 추가 행동은 재발화 안 함
	game.call("_on_intent", &"query", {"raw": String(state.conclusion_query)})
	await process_frame
	checks += 1
	if _finished_count != 1:
		failed += 1; printerr("FAIL: duplicate finished after completion (%d)" % _finished_count)

	# 5. reset 후 재플레이 가능
	game.execute_command(&"reset")
	await process_frame
	checks += 1
	if state.revealed_count() != 0:
		failed += 1; printerr("FAIL: reset did not clear runtime")

	game.exit()
	print("QW PLAY PROBE: %d checks, %d passed, %d failed (case=%s)" % [checks, checks - failed, failed, _finished_case])
	quit(1 if failed > 0 else 0)
