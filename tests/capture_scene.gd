extends SceneTree

func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 4:
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
		scene.context = context
	root.add_child(scene)
	await process_frame
	if scene is GameModule:
		if args[0].contains("first_entry"):
			scene.load_state({"phase": "editor", "keys": ["first_entry_up", "first_entry_down", "first_entry_left", "first_entry_right", "first_entry_confirm", "first_entry_cancel"], "shape": 1, "color": 1, "language": "ko"})
		else:
			scene.load_state({})
		scene.enter(scene.context)
	await process_frame
	await process_frame
	var image: Image = root.get_texture().get_image()
	var result: Error = image.save_png(args[3])
	print("CAPTURE %dx%d -> %s (%s)" % [image.get_width(), image.get_height(), args[3], error_string(result)])
	quit(result)
