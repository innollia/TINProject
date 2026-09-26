extends SceneTree

## Kit 05 화면 캡처. 모듈만 직접 띄운다 (앱 루트 경유 없이).
## 창을 실제로 띄워 4개 해상도로 바꿔 가며 PNG 를 낸다.

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(1920, 1280),
]
const OUT := "C:/Users/Sherum/AppData/Local/Temp/opencode/ssr_shots/"

var _module: Node = null
var _index: int = 0
var _saved: int = 0
var _log: Array[String] = []
var _launched: bool = false
var _done: bool = false
var _settle: int = 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	_launch.call_deferred()


func _launch() -> void:
	var packed: PackedScene = load("res://modules/stone_story_rpg/entry.tscn") as PackedScene
	if packed == null:
		_log.append("entry scene missing")
		_finish()
		return
	_module = packed.instantiate()
	root.add_child(_module)
	await _wait(6)
	var ctx := ModuleContext.new()
	ctx.module_id = &"stone_story_rpg"
	ctx.input_enabled = true
	_module.call("enter", ctx)
	_module.call("execute_command", &"ssr_next_region", {})
	_module.call("execute_command", &"ssr_set_star", {"star": 12})
	_module.call("execute_command", &"ssr_equip", {"item_id": "item_board_shield"})
	_module.call("execute_command", &"ssr_equip", {"item_id": "item_ember_brand"})
	for i in 150:
		await process_frame
	var st: Dictionary = _module.get("state")
	var enc: Dictionary = st.get("encounter", {})
	_log.append("region=" + str(st.get("region_id", "")))
	_log.append("tick=" + str(st.get("tick", 0)))
	_log.append("foes=" + str(enc.get("foes", []).size()))
	_log.append("boss=" + str(not enc.get("boss", {}).is_empty()))
	if not enc.get("foes", []).is_empty():
		var f: Dictionary = enc["foes"][0]
		_log.append("foe0=" + str(f.get("foe_id", "")) + " attrs=" + JSON.stringify(f.get("attributes", {})))
	_log.append("scale_factors: 720=" + str(StoneStoryFrame.scale_for(Vector2i(1280, 720)))
			+ " 1080=" + str(StoneStoryFrame.scale_for(Vector2i(1920, 1080)))
			+ " 1440=" + str(StoneStoryFrame.scale_for(Vector2i(2560, 1440)))
			+ " 1920x1280=" + str(StoneStoryFrame.scale_for(Vector2i(1920, 1280))))
	_capture.call_deferred()


func _process(_delta: float) -> bool:
	if _done:
		return true
	_settle += 1
	if _settle > 3000:
		_log.append("timeout")
		_finish()
	return _done


func _wait(frames: int) -> void:
	for i in frames:
		await process_frame


func _capture() -> void:
	if _index >= RESOLUTIONS.size():
		_finish()
		return
	var res: Vector2i = RESOLUTIONS[_index]
	DisplayServer.window_set_size(res)
	for i in 12:
		await process_frame
	var tex := root.get_texture()
	if tex == null:
		_log.append("no texture at " + str(res))
		_index += 1
		_capture.call_deferred()
		return
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		_log.append("empty image at " + str(res))
		_index += 1
		_capture.call_deferred()
		return
	var path: String = OUT + ("shot_%dx%d.png" % [img.get_width(), img.get_height()])
	img.save_png(path)
	_saved += 1
	_log.append("saved " + path)
	_index += 1
	_capture.call_deferred()


func _finish() -> void:
	for l in _log:
		print(l)
	print("SAVED_COUNT=" + str(_saved))
	_done = true
