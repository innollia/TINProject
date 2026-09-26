extends SceneTree

## Kit 05 창 모드 캡처. 장면을 하나씩 고정한 뒤 4개 해상도로 창을 바꿔 찍는다.
## 인자: -- --step=<이름> [--scenes=lobby,hub,cistern,canyon] [--res=1280x720,...]
## 출력: user://kit05_captures/<step>/<scene>_<w>x<h>.png  +  AUDIT 줄(V13 겹침·잘림)

const DEFAULT_RES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(1920, 1280),
]
const SCENES: Array[String] = ["lobby", "hub", "cistern", "canyon"]

var _module: Node = null
var _out: String = ""
var _step: String = "adhoc"
var _scenes: Array[String] = []
var _res: Array[Vector2i] = []
var _saved: int = 0
var _fail: int = 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--step="):
			_step = a.substr(7)
		elif a.begins_with("--scenes="):
			for s in a.substr(9).split(",", false):
				_scenes.append(s)
		elif a.begins_with("--res="):
			for r in a.substr(6).split(",", false):
				var wh: PackedStringArray = r.split("x")
				_res.append(Vector2i(int(wh[0]), int(wh[1])))
	if _scenes.is_empty():
		_scenes = SCENES.duplicate()
	if _res.is_empty():
		_res = DEFAULT_RES.duplicate()
	_out = ProjectSettings.globalize_path("user://kit05_captures/" + _step + "/")
	DirAccess.make_dir_recursive_absolute(_out)
	_run.call_deferred()


func _wait(frames: int) -> void:
	for i in frames:
		await process_frame


func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_module = (load("res://modules/stone_story_rpg/entry.tscn") as PackedScene).instantiate()
	root.add_child(_module)
	await _wait(4)
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = true
	_module.call("enter", ctx)
	await _wait(4)
	for scene in _scenes:
		await _setup(scene)
		for res in _res:
			await _resize(res)
			_capture(scene)
	print("SAVED_COUNT=%d FAIL=%d OUT=%s" % [_saved, _fail, _out])
	_module.call("exit")
	_module.queue_free()
	await _wait(3)
	quit(0)


func _setup(scene: String) -> void:
	_module.set("_started", scene != "canyon")
	match scene:
		"lobby":
			_module.call("_to_lobby", "")
			_module.call("execute_command", &"ssr_equip", {"item_id": "item_board_shield"})
			_module.call("execute_command", &"ssr_equip", {"item_id": "item_ash_spear"})
			_module.call("execute_command", &"ssr_set_star", {"star": 12})
			var st: Dictionary = _module.get("state")
			var unlocked: Array = st["world"]["unlocked_regions"]
			if not unlocked.has("region_hollow_cistern"):
				unlocked.append("region_hollow_cistern")
			var lobby: Object = _module.get("_lobby")
			lobby.call("bind", st, _module.get("content"), _module.get("tuning"))
			lobby.set("focus", 2)
			lobby.set("gear_index", 1)
			lobby.set("report", ["비웠다. 통화 184 · 열림: 빈 기둥 우물", "쓰러졌다. 남은 것: 통화 120"] as Array[String])
			await _wait(20)
		"hub":
			_module.set("_pending_region", "region_under_sign")
			_module.set("_pending_star", 1)
			_module.call("_on_go")
			await _wait(36)
			_module.set("_started", false)
			await _wait(4)
		"cistern":
			_module.set("_pending_region", "region_hollow_cistern")
			_module.set("_pending_star", 12)
			_module.call("_on_go")
			# 적이 다가와 맞붙은 뒤에 멈춘다. (공격 주기 = 무기 attack.frames)
			await _wait(100)
			_module.set("_started", false)
			await _wait(4)
		"canyon":
			var content: StoneStoryContent = _module.get("content")
			var base: Dictionary = content.get_def("region", "region_hollow_cistern").duplicate(true)
			base["palette"] = "pal_canyon_ember"
			base["structure"] = "str_canyon_walls"
			base["sky"] = {"clouds": 2}
			base["ground_layers"] = []
			base["props"] = [{"prop_id": "prop_train", "x": 300, "y": 150, "scale": 1.0, "breaks": "gravity", "shadow_y": 318}]
			base["name"] = "(미사용 구조물 시험)"
			var view: Object = _module.get("_view")
			var st2: Dictionary = _module.get("state")
			view.call("bind", st2, st2.get("encounter", {}), base, content, _module.get("tuning"))
			await _wait(10)
	var alive: int = 0
	var enc: Dictionary = (_module.get("state") as Dictionary).get("encounter", {})
	for f in enc.get("foes", []):
		if bool(f.get("alive", true)):
			alive += 1
	print("SCENE %s mode=%s foes_alive=%d/%d boss=%s" % [scene, str(_module.get("mode")), alive,
			enc.get("foes", []).size(), str(not (enc.get("boss", {}) as Dictionary).is_empty())])


func _resize(res: Vector2i) -> void:
	DisplayServer.window_set_size(res)
	var tries: int = 0
	while DisplayServer.window_get_size() != res and tries < 90:
		await process_frame
		tries += 1
	await _wait(10)


func _capture(scene: String) -> void:
	var tex := root.get_texture()
	if tex == null:
		_fail += 1
		return
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		_fail += 1
		return
	var win: Vector2i = DisplayServer.window_get_size()
	# 이름은 창 크기로 짓는다. 3:2 창은 프로젝트 비율 유지(keep) 때문에 그림이 16:9 로 나온다.
	var path: String = _out + "%s_%dx%d.png" % [scene, win.x, win.y]
	img.save_png(path)
	_saved += 1
	print("CAPTURE %s window=%dx%d image=%dx%d" % [path, win.x, win.y, img.get_width(), img.get_height()])
	_audit(scene, win)


func _audit(scene: String, win: Vector2i) -> void:
	var boxes: Array = []
	var bounds := Rect2(0, 0, StoneStoryFrame.VIEW_W, StoneStoryFrame.VIEW_H)
	if scene == "lobby":
		boxes = (_module.get("_lobby") as Object).get("layout_boxes")
	else:
		var view: Object = _module.get("_view")
		var w: float = (view as Control).size.x
		bounds = Rect2(0, 0, w, StoneStoryFrame.VIEW_H)
		boxes = view.get("hud_boxes")
	var overlaps: int = 0
	var clipped: int = 0
	for i in boxes.size():
		var a: Rect2 = boxes[i]["rect"]
		if not bounds.encloses(a):
			clipped += 1
		for j in range(i + 1, boxes.size()):
			var b: Rect2 = boxes[j]["rect"]
			if a.grow(-1.0).intersects(b.grow(-1.0)):
				overlaps += 1
				print("OVERLAP %s | %s <-> %s" % [scene, str(boxes[i]["text"]), str(boxes[j]["text"])])
	var frame: StoneStoryFrame = null
	for c in _module.get_children():
		if c is StoneStoryFrame:
			frame = c
	var px: Vector2i = frame.pixel_size if frame != null else Vector2i.ZERO
	print("AUDIT %s %dx%d texts=%d overlaps=%d clipped=%d buffer=%dx%d view_w=%d" % [
			scene, win.x, win.y, boxes.size(), overlaps, clipped, px.x, px.y, frame.view_w if frame != null else 0])
