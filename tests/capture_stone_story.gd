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
	if _step.begins_with("zoo"):
		await _run_zoo()
		quit(0)
		return
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


# --- 개체 방향 후보 비교 (zoo) -------------------------------------------
# --step=zoo : 후보마다 개체 3종을 나란히 걷게 하고 0.1초 간격 6장을 찍는다.

const ZOO_GROUND_Y: float = 470.0
const ZOO_FRAMES: int = 6


static func _zoo_candidates(content: StoneStoryContent) -> Dictionary:
	var crawler: Dictionary = content.get_def("silhouette", "sil_crawler")
	var strider: Dictionary = content.get_def("silhouette", "sil_strider")
	var hauler: Dictionary = content.get_def("silhouette", "sil_hauler")
	var stilt2: Dictionary = {"form": "strider", "vary": 0.12, "spine": {"nodes": [4, 5], "length": 0.7, "tail": 0.1},
			"ride": 0.78, "girth": 0.13, "bulge": [0.4, 0.6], "head": {"size": 1.3, "raise": 0.05, "snout": 0.2},
			"legs": {"span": [0.5, 0.92], "length": 1.15}, "arms": {"at": 0.2, "length": 0.3}}
	var stilt3: Dictionary = {"form": "crawler", "vary": 0.12, "spine": {"nodes": [3, 4], "length": 0.6, "tail": 0.0},
			"ride": 0.75, "girth": 0.16, "bulge": [0.4, 0.6], "head": {"size": 1.2, "raise": 0.05, "snout": 0.3},
			"legs": {"span": [0.1, 0.9], "length": 1.25}}
	return {
		"a": {"title": "A 딛고 걷는 짐승 — 다리가 몸을 떠받치고 머리가 앞서며 꼬리가 끌린다", "members": [
			{"sil": crawler, "attrs": {"limbs": 4, "roundness": 3, "wrongness": 0, "surprise": 2}, "shape": [44, 40]},
			{"sil": crawler, "attrs": {"limbs": 6, "roundness": 7, "wrongness": 6, "surprise": 0}, "shape": [52, 44]},
			{"sil": strider, "attrs": {"limbs": 4, "roundness": 2, "wrongness": 1, "surprise": 1}, "shape": [30, 50], "player": true}]},
		"b": {"title": "B 몸을 끌고 가는 것 — 걷는 다리가 없다. 앞팔을 멀리 박고 몸을 끌어당긴다", "members": [
			{"sil": hauler, "attrs": {"limbs": 2, "roundness": 4, "wrongness": 0, "surprise": 0}, "shape": [50, 36]},
			{"sil": hauler, "attrs": {"limbs": 4, "roundness": 10, "wrongness": 2, "surprise": 0}, "shape": [60, 44]},
			{"sil": hauler, "attrs": {"limbs": 2, "roundness": 5, "wrongness": 8, "surprise": 5}, "shape": [44, 34], "player": true}]},
		"c": {"title": "C 장대 위의 몸 — 바닥의 재를 피해 몸을 높이 든다. 긴 다리 2~3개로 성큼 딛는다", "members": [
			{"sil": stilt2, "attrs": {"limbs": 2, "roundness": 4, "wrongness": 0, "surprise": 1}, "shape": [30, 62]},
			{"sil": stilt3, "attrs": {"limbs": 3, "roundness": 6, "wrongness": 3, "surprise": 0}, "shape": [36, 60]},
			{"sil": stilt2, "attrs": {"limbs": 2, "roundness": 2, "wrongness": 8, "surprise": 4}, "shape": [26, 56], "player": true}]},
	}


func _run_zoo() -> void:
	var content := StoneStoryContent.new()
	content.load_all()
	DisplayServer.window_set_size(Vector2i(1280, 720))
	await _wait(20)
	var cands: Dictionary = _zoo_candidates(content)
	var region: Dictionary = content.get_def("region", "region_hollow_cistern")
	var pal: ProceduralPalette = StoneStoryPalette.for_region(content, region)
	for key in cands:
		var cand: Dictionary = cands[key]
		var zoo := Zoo.new()
		zoo.pal = pal
		zoo.region = region
		zoo.title = str(cand["title"])
		var i: int = 0
		for m in cand["members"]:
			var md: Dictionary = m
			var sh: Array = md["shape"]
			var c := StoneStoryCritter.build(md["sil"], md["attrs"], {"width_units": sh[0], "height_units": sh[1]},
					1000 + i * 77, 1.5)
			zoo.critters.append(c)
			zoo.player.append(bool(md.get("player", false)))
			zoo.xs.append(170.0 + 330.0 * float(i))
			zoo.acc.append(0.0)
			i += 1
		root.add_child(zoo)
		await _wait(90)
		for k in ZOO_FRAMES:
			var img: Image = root.get_texture().get_image()
			var path: String = _out + "%s_f%d.png" % [key, k]
			img.save_png(path)
			_saved += 1
			print("CAPTURE %s" % path)
			await _wait(6)
		zoo.queue_free()
		await _wait(3)
	print("SAVED_COUNT=%d FAIL=%d OUT=%s" % [_saved, _fail, _out])


class Zoo extends Control:
	var pal: ProceduralPalette = null
	var region: Dictionary = {}
	var title: String = ""
	var critters: Array = []
	var player: Array = []
	var xs: Array = []
	var acc: Array = []
	var clock: float = 0.0
	var speed: float = 45.0
	var _font: SystemFont = null

	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_font = SystemFont.new()
		_font.font_names = PackedStringArray(["Malgun Gothic", "Gulim", "sans-serif"])
		_font.font_weight = 700

	func _process(delta: float) -> void:
		clock += delta
		for i in critters.size():
			var c: StoneStoryCritter = critters[i]
			acc[i] = float(acc[i]) + speed * delta
			if float(acc[i]) >= 7.0:
				xs[i] = float(xs[i]) + 7.0
				acc[i] = float(acc[i]) - 7.0
			c.facing = 1.0
			c.look = Vector2(1.0, 0.1)
			c.place(Vector2(float(xs[i]), ZOO_GROUND_Y))
			c.step(delta)
		queue_redraw()

	func _draw() -> void:
		var k: float = size.y / 640.0
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(k, k))
		var w: float = size.x / k
		StoneStorySky.draw(self, pal, region, w, 243.0, clock, null, 0.0, 7)
		StoneStoryGround.draw(self, pal, region, w, 243.0, 640.0, null, 0.0, 7)
		for i in critters.size():
			var c: StoneStoryCritter = critters[i]
			var tones: Array[Color] = StoneStoryCritter.player_tones(pal) if bool(player[i]) else StoneStoryCritter.foe_tones(pal, false)
			c.draw(self, Vector2(float(xs[i]), ZOO_GROUND_Y), pal, null, tones[0], tones[1])
		draw_string_outline(_font, Vector2(24, 44), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, StoneStoryPalette.ink(pal))
		draw_string(_font, Vector2(24, 44), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, StoneStoryPalette.text(pal))