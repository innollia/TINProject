extends SceneTree

## Kit 05 로비 + 탐험 화면 캡처. 실제 창을 띄워 4개 해상도로 바꾼다.

const OUT := "C:/Users/Sherum/AppData/Local/Temp/opencode/ssr_lobby/"
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(1920, 1280),
]

var _module: Node = null
var _index: int = 0
var _saved: int = 0
var _log: Array[String] = []
var _done: bool = false
var _settle: int = 0
var _step: int = 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	_run.call_deferred()


func _run() -> void:
	_module = (load("res://modules/stone_story_rpg/entry.tscn") as PackedScene).instantiate()
	root.add_child(_module)
	await _wait(6)
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = true
	_module.call("enter", ctx)
	await _wait(4)
	# 로비에 장비를 하나 끼워 본다
	_module.call("execute_command", &"ssr_equip", {"item_id": "item_board_shield"})
	_module.call("execute_command", &"ssr_equip", {"item_id": "item_ash_spear"})
	_module.call("execute_command", &"ssr_set_star", {"star": 12})
	var lobby: Object = _module.get("_lobby")
	if lobby != null:
		lobby.set("focus", 2)
		lobby.set("gear_index", 0)
		lobby.call("bind", _module.get("state"), _module.get("content"), _module.get("tuning"))
	_log.append("mode=" + str(_module.get("mode")))
	_log.append("policy=" + str(lobby.call("_policy_line")))
	_log.append("build=" + str(lobby.call("_build_line")))
	_save.call_deferred()


func _process(_delta: float) -> bool:
	if _done:
		return true
	_settle += 1
	if _settle > 3600:
		_log.append("timeout")
		_done = true
	return _done


func _wait(frames: int) -> void:
	for i in frames:
		await process_frame


func _save() -> void:
	if _index >= RESOLUTIONS.size():
		_finish()
		return
	var res: Vector2i = RESOLUTIONS[_index]
	DisplayServer.window_set_size(res)
	for i in 12:
		await process_frame
	var tex := root.get_texture()
	if tex != null:
		var img: Image = tex.get_image()
		if img != null and not img.is_empty():
			var tag: String = "lobby"
			if _index >= 2:
				tag = "lobby_x2"
			img.save_png(OUT + ("%s_%dx%d.png" % [tag, img.get_width(), img.get_height()]))
			_saved += 1
			_log.append("saved " + tag + " " + str(img.get_width()) + "x" + str(img.get_height()))
	_index += 1
	_save.call_deferred()


func _finish() -> void:
	# 탐험으로 넘어가서 한 장 더
	if _module != null and str(_module.get("mode")) == "lobby":
		_module.call("_on_go")
		for i in 150:
			await process_frame
		var st: Dictionary = _module.get("state")
		var enc: Dictionary = st.get("encounter", {})
		_log.append("mode=" + str(_module.get("mode")))
		_log.append("region=" + str(st.get("region_id", "")))
		_log.append("tick=" + str(st.get("tick", 0)))
		_log.append("foes=" + str(enc.get("foes", []).size()))
		_log.append("stance=" + str(enc.get("player_stance", "")))
		DisplayServer.window_set_size(Vector2i(1280, 720))
		for i in 14:
			await process_frame
		var t2 := root.get_texture()
		if t2 != null:
			var i2: Image = t2.get_image()
			if i2 != null and not i2.is_empty():
				i2.save_png(OUT + "expedition_1280x720.png")
				_saved += 1
				_log.append("saved expedition")
	for l in _log:
		print(l)
	print("SAVED_COUNT=" + str(_saved))
	_done = true
