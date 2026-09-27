## 조작 검증: 실제 입력 신호만으로 타이틀→결말→타이틀까지 간다.
## 키보드만 1판, 마우스만 1판. 실행: godot --path <proj> -s res://modules/quote_vn/tests/input_test.gd
extends SceneTree

var game: Node
var result: PackedStringArray = []


func _init() -> void:
	root.size = Vector2i(1280, 720)
	_run()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _key(k: int) -> void:
	for pressed in [true, false]:
		var e := InputEventKey.new()
		e.keycode = k
		e.physical_keycode = k
		e.pressed = pressed
		root.push_input(e)
		await process_frame


func _click(pos: Vector2) -> void:
	var mv := InputEventMouseMotion.new()
	mv.position = pos
	root.push_input(mv)
	await process_frame
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.position = pos
		e.global_position = pos
		e.pressed = pressed
		root.push_input(e)
		await process_frame


func _idle() -> void:
	var g := 0
	while game.busy and g < 600:
		g += 1
		await process_frame
	await _wait(2)


func _play(use_mouse: bool) -> bool:
	game = load("res://modules/quote_vn/entry.tscn").instantiate()
	root.add_child(game)
	await _wait(10)
	if use_mouse:
		var sb: Button = game.title_layer.find_child("StartButton", true, false)
		await _click(sb.get_global_rect().get_center())
	else:
		await _key(KEY_ENTER)
	await _wait(5)
	await _idle()
	var saw_ending := false
	var choices := 0
	for step in 2500:
		await _idle()
		if game.on_title:
			break
		if game.ev.get("type", "") == "ending":
			saw_ending = true
		if game.waiting_choice:
			choices += 1
			if use_mouse:
				var b: Button = game.choice_box.get_child(1)
				await _click(b.get_global_rect().get_center())
			else:
				await _key(KEY_1)
		elif use_mouse:
			await _click(Vector2(640, 330))
		else:
			await _key(KEY_SPACE)
	var ok: bool = saw_ending and game.on_title and choices >= 10
	result.append("%s만: 결말 도달 %s, 선택 %d번, 타이틀 복귀 %s → %s" % ["마우스" if use_mouse else "키보드", saw_ending, choices, game.on_title, "통과" if ok else "실패"])
	game.queue_free()
	await _wait(3)
	return ok


func _run() -> void:
	var a := await _play(false)
	var b := await _play(true)
	var f := FileAccess.open("res://modules/quote_vn/reports/input.md", FileAccess.WRITE)
	f.store_string("# 조작 검증\n- " + "\n- ".join(result))
	print("INPUT keyboard=", a, " mouse=", b)
	quit(0 if a and b else 1)
