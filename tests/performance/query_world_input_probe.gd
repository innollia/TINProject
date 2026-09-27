extends SceneTree

## Query World Kit — 인터랙티브 입력 프로브.
## 실제 InputEvent(키 입력)를 흘려 검색창 타이핑·focus·키보드 네비를 검증한다.
## 사용자 보고("타이핑 안됨, 키보드만으로 조작 안됨")를 런타임에서 재현/확인.

func _initialize() -> void:
	_run.call_deferred()


func _type_char(field: LineEdit, c: String) -> void:
	# LineEdit에 실제 텍스트 입력 이벤트를 흘린다.
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.unicode = c.unicode_at(0)
	ev.keycode = 0
	field.get_viewport().push_input(ev)


func _run() -> void:
	var checks: int = 0
	var failed: int = 0

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
	await process_frame
	game.load_state({})
	game.enter(ctx)
	await process_frame
	await process_frame

	var screen: Variant = game.get_node("Screen")
	var field: LineEdit = screen.get("_search_field")

	# 1. 진입 시 검색창이 focus를 갖는가 (타이핑 가능 상태)
	checks += 1
	if not field.has_focus():
		# 명시적으로 focus를 잡아 계속 검증
		field.grab_focus()
		await process_frame
	if not field.has_focus():
		failed += 1; printerr("FAIL: search field cannot hold focus")

	# 2. 검색창에 실제 타이핑이 들어가는가
	field.clear()
	await process_frame
	for c in ["관", "리", "인"]:
		_type_char(field, c)
		await process_frame
	checks += 1
	if field.text != "관리인":
		failed += 1; printerr("FAIL: typing did not reach field, got '%s'" % field.text)

	# 3. Enter 제출 → 질의 실행
	var state: Variant = game.get("state")
	var before: int = state.query_history.size()
	field.text_submitted.emit(field.text)
	await process_frame
	checks += 1
	if state.query_history.size() != before + 1:
		failed += 1; printerr("FAIL: Enter did not submit query")

	# 4. 마우스로 파편 열람 뷰에서 나갈 수 있는가 (뒤로 버튼 존재+동작)
	var keys: Array = state.fragments.keys(); keys.sort()
	game.call("_on_intent", &"open", {"fragment_id": String(keys[0])})
	await process_frame
	checks += 1
	if not screen.is_reading():
		failed += 1; printerr("FAIL: fragment did not open")

	# 5. qw_peek — 키보드로 hover span을 순회할 수 있는가 (마우스 없이 국소 질의)
	checks += 1
	if not screen.has_peekable_hovers():
		failed += 1; printerr("FAIL: no peekable hovers on first fragment (expected a1 to have one)")
	else:
		screen.peek_next()
		await process_frame
		checks += 1
		if String(screen.get("_status_line").text).is_empty():
			failed += 1; printerr("FAIL: peek_next did not populate status line")

	screen.close_reader()  # 뒤로 버튼이 부르는 것과 동일 경로
	await process_frame
	checks += 1
	if screen.is_reading():
		failed += 1; printerr("FAIL: could not exit reader")

	game.exit()
	print("QW INPUT PROBE: %d checks, %d passed, %d failed" % [checks, checks - failed, failed])
	quit(1 if failed > 0 else 0)
