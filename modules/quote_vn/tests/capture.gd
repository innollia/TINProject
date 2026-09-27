## 연속 캡처: 실제 화면을 띄워 타이틀→서술→선택지→대답→갈림길→결말을 차례로 찍는다.
## 실행(창 모드): godot --path <proj> -s res://modules/quote_vn/tests/capture.gd
extends SceneTree

const DIR := "res://modules/quote_vn/captures/"
var game: Node
var n := 0


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	root.size = Vector2i(1280, 720)
	game = load("res://modules/quote_vn/entry.tscn").instantiate()
	root.add_child(game)
	_run()


func _wait(frames: int) -> void:
	for i in frames:
		await process_frame


func _shot(tag: String) -> void:
	await _wait(3)
	var img := root.get_texture().get_image()
	n += 1
	img.save_png(DIR + "%02d_%s.png" % [n, tag])
	print("캡처 ", n, " ", tag)


func _until_idle() -> void:
	var guard := 0
	while (game.busy) and guard < 400:
		guard += 1
		await process_frame
	await _wait(2)


func _finish_typing() -> void:
	game.ko_label.visible_characters = -1


func _run() -> void:
	await _wait(10)
	await _shot("title")
	game.start_story(20260927)
	await _wait(80)
	await _until_idle()
	var guard := 0
	var got := {}
	var removed := 0
	while guard < 400:
		guard += 1
		await _until_idle()
		var t: String = game.ev.get("type", "")
		if t in ["narration", "hero", "heroine", "title", "desc"] and int(got.get(t, 0)) < 2:
			_finish_typing()
			await _shot(t)
			got[t] = int(got.get(t, 0)) + 1
		if t == "choice" and game.waiting_choice:
			if int(got.get("choice_" + game.ev.kind, 0)) < 2:
				await _shot("choice_" + game.ev.kind)
				got["choice_" + game.ev.kind] = int(got.get("choice_" + game.ev.kind, 0)) + 1
			game._on_choice(guard % game.ev.options.size())
			await _wait(4)
			continue
		if t == "crossroad" and removed < 2:
			await _wait(8)
			await _shot("crossroad")
			removed += 1
		if t == "ending":
			await _wait(30)
			await _shot("ending")
			break
		if t == "heroine" and not got.has("log"):
			game._toggle_log()
			await _wait(4)
			await _shot("log")
			game._toggle_log()
			got["log"] = 1
		if t == "heroine" and not got.has("fx"):
			got["fx"] = 1
			var mat: ShaderMaterial = game.overlay.material
			var names := {6: "잉크", 7: "불타는종이", 8: "물결", 9: "픽셀화", 10: "시계", 11: "하트", 12: "글리치"}
			for m in names:
				mat.set_shader_parameter("mode", m)
				mat.set_shader_parameter("tint", Color("2a0f1c"))
				mat.set_shader_parameter("progress", 0.5)
				await _shot("fx_" + names[m])
			mat.set_shader_parameter("progress", 0.0)
		_finish_typing()
		game._advance()
		await _wait(2)
	quit()
