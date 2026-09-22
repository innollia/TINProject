extends SceneTree

func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 4 and args.size() != 5:
		quit(2)
		return
	var width: int = int(args[1])
	var height: int = int(args[2])
	if width <= 0 or height <= 0:
		quit(2)
		return
	DisplayServer.window_set_size(Vector2i(width, height))
	var packed: PackedScene = load(args[0]) as PackedScene
	if packed == null:
		quit(3)
		return
	var scene: Node = packed.instantiate()
	if scene is GameModule:
		var context := ModuleContext.new()
		context.module_id = &"visual_capture"
		context.input_enabled = true
		context.identity_view = {"shape": 1, "color": 1}
		if args[0].contains("game_library"):
			var games: Array[Dictionary] = []
			for folder: String in DirAccess.get_directories_at("res://modules"):
				if folder == "game_library" or folder == "first_entry":
					continue
				var manifest: ModuleManifest = load("res://modules/%s/module_manifest.tres" % folder)
				if manifest != null:
					games.append({"id": String(manifest.id), "name": manifest.display_name})
			context.arrival = {"language": "ko", "current": "signal_desk", "games": games}
		scene.context = context
	root.add_child(scene)
	await process_frame
	if scene is GameModule:
		if args[0].contains("first_entry"):
			scene.load_state({"phase": "editor", "keys": ["first_entry_up", "first_entry_down", "first_entry_left", "first_entry_right", "first_entry_confirm", "first_entry_cancel"], "shape": 1, "color": 1, "language": "ko"})
		else:
			scene.load_state({})
		scene.enter(scene.context)
		if args.size() == 5 and args[4] == "all" and args[0].contains("game_library"):
			scene.call("_show_all")
		if args.size() == 5 and args[4] == "last" and args[0].contains("game_library"):
			(scene.get("_buttons") as Array)[-1].grab_focus()
		if args.size() == 5 and args[4] == "all_last" and args[0].contains("game_library"):
			scene.call("_show_all")
			(scene.get("_grid_buttons") as Array)[-1].grab_focus()
	await process_frame
	await process_frame
	var image: Image = root.get_texture().get_image()
	var result: Error = image.save_png(args[3])
	print("CAPTURE %dx%d -> %s (%s)" % [image.get_width(), image.get_height(), args[3], error_string(result)])
	quit(result)
