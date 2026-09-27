extends SceneTree
## 03 Deduction Casework 창 모드 캡처 도구. 1·2·3번 사건의 모든 장면을 720p/FHD/QHD로 찍는다.
## 실행: Godot(창 모드) --path <저장소> --script res://docs/research/deduction_casework/tools/capture_scenes.gd
## 출력: user:// 가 아닌 저장소 밖 절대 경로(OUT_DIR). 게임 코드·저장 파일은 건드리지 않는다.

const ENTRY_SCENE := "res://modules/deduction_casework/entry.tscn"
const OUT_DIR := "C:/Users/fixme/workplace/kirocrew-workspace/subagent_68c47786/captures"
const CASES: Array[String] = ["case_01_saint_orin", "case_02_morren_empty_chair", "case_03_n153_last_tour"]
const SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]
const ACTIONS: Array[String] = [
	"deduction_casework_left", "deduction_casework_right", "deduction_casework_up",
	"deduction_casework_down", "deduction_casework_confirm", "deduction_casework_cancel"
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	for action: String in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	var catalog := DeductionContentLoader.load_catalog()
	var written := 0
	for size: Vector2i in SIZES:
		DisplayServer.window_set_size(size)
		for _i in 6:
			await process_frame
		for case_index: int in range(CASES.size()):
			var definition := catalog.get_definition(StringName(CASES[case_index]))
			for scene in definition.scenes:
				var game := _spawn(catalog, case_index, String(scene.id))
				for _i in 8:
					await process_frame
				await RenderingServer.frame_post_draw
				var image := root.get_texture().get_image()
				var path := "%s/%s__%s__%dx%d.png" % [OUT_DIR, CASES[case_index], String(scene.id), image.get_width(), image.get_height()]
				image.save_png(path)
				written += 1
				print("CAPTURE ", path)
				game.exit()
				game.queue_free()
				await process_frame
	print("CAPTURES_WRITTEN ", written)
	quit(0)


func _spawn(catalog: DeductionContentLoader.CaseCatalog, active_index: int, scene_id: String) -> GameModule:
	var game := (load(ENTRY_SCENE) as PackedScene).instantiate() as GameModule
	var context := ModuleContext.new()
	context.module_id = &"deduction_casework"
	context.input_enabled = false
	for action: String in ACTIONS:
		context.allowed_actions.append(StringName(action))
	game.context = context
	root.add_child(game)
	game.load_state(_state(catalog, active_index, scene_id))
	game.enter(context)
	return game


func _state(catalog: DeductionContentLoader.CaseCatalog, active_index: int, scene_id: String) -> Dictionary:
	var case_ids := catalog.list_case_ids()
	var progress_by_id: Dictionary = {}
	var unlocked: Array[String] = []
	var reviewed: Array[String] = []
	for index: int in range(case_ids.size()):
		var definition := catalog.get_definition(case_ids[index])
		var progress := DeductionCaseProgression.initial_progress(definition)
		if index < active_index:
			progress.reviewed = true
			progress.status = DeductionCaseProgress.STATUS_REVIEWED
			reviewed.append(String(case_ids[index]))
			unlocked.append(String(case_ids[index + 1]))
		var data := progress.to_dict()
		if index == active_index:
			data["current_scene_id"] = scene_id
			var visited: Array = data.get("visited_scene_ids", [])
			if not visited.has(scene_id):
				visited.append(scene_id)
			data["visited_scene_ids"] = visited
		progress_by_id[String(case_ids[index])] = data
	return {
		"schema_version": 1,
		"active_case_id": String(case_ids[active_index]),
		"last_case_id": String(case_ids[active_index]),
		"case_progress_by_id": progress_by_id,
		"route_state": {"unlocked_case_ids": unlocked, "reviewed_case_ids": reviewed}
	}
