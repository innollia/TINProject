extends SceneTree

const ENTRY_SCENE: PackedScene = preload("res://modules/rule_rewriting/entry.tscn")
const CAPTURE_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)
]
const CAPTURE_STATES: Array[String] = [
	"2d", "first_person", "third_person", "inventory", "failure", "success"
]
const FAILURE_ROUTE: Array[Vector2i] = [
	Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
	Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
	Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT
]
const SUCCESS_ROUTE: Array[Vector2i] = [
	Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT
]
const SETTLE_FRAME_COUNT: int = 4

var _module: GameModule
var _module_context: ModuleContext
var _output_directory: String = ""


func _initialize() -> void:
	var output_directory := _parse_output_directory(OS.get_cmdline_user_args())
	if output_directory.is_empty():
		return
	_output_directory = _validate_output_directory(output_directory)
	if _output_directory.is_empty():
		return
	var error := DirAccess.make_dir_recursive_absolute(_output_directory)
	if error != OK:
		_fail("Could not create output directory %s: %s" % [_output_directory, error_string(error)])
		return
	if not DirAccess.dir_exists_absolute(_output_directory):
		_fail("Output directory was not created: %s" % _output_directory)
		return
	call_deferred("_capture_screens")


func _capture_screens() -> void:
	_module = ENTRY_SCENE.instantiate() as GameModule
	_module_context = ModuleContext.new()
	_module_context.module_id = &"rule_rewriting"
	_module_context.input_enabled = true
	_module.context = _module_context
	root.add_child(_module)
	_module.enter(_module_context)
	for requested_size: Vector2i in CAPTURE_SIZES:
		root.size = requested_size
		DisplayServer.window_set_size(requested_size)
		await _wait_for_settle()
		for state_name: String in CAPTURE_STATES:
			if not await _prepare_fixture(state_name):
				return
			if not await _capture(state_name, requested_size):
				return
	_module.queue_free()
	await process_frame
	quit()


func _prepare_fixture(state_name: String) -> bool:
	match state_name:
		"2d":
			if not await _load_board(&"rule_01_open_gate"):
				return false
			if bool(_module.call("_is_3d_mode")):
				return _fail("Fixture %s entered 3D mode" % state_name)
			return true
		"first_person":
			if not await _load_board(&"rule_14_owner_focus"):
				return false
			if not _execute_required(&"toggle_view") or not _execute_required(&"toggle_view"):
				return false
			var first_person_view := _module.get("_view") as RuleBoardView
			if first_person_view == null or not bool(first_person_view.get("_first_person_3d")):
				return _fail("Fixture %s did not enter first person" % state_name)
			return true
		"third_person":
			if not await _load_board(&"rule_14_owner_focus"):
				return false
			if not _execute_required(&"toggle_view"):
				return false
			var third_person_view := _module.get("_view") as RuleBoardView
			if third_person_view == null or bool(third_person_view.get("_first_person_3d")):
				return _fail("Fixture %s did not enter third person" % state_name)
			return true
		"inventory":
			if not await _load_board(&"rule_14_owner_focus"):
				return false
			if not _execute_required(&"open_inventory"):
				return false
			if not bool(_module.get("_inventory_open")):
				return _fail("Fixture %s did not open inventory" % state_name)
			return true
		"failure":
			if not await _load_board(&"rule_08_safe_crossing"):
				return false
			for _step: int in range(FAILURE_ROUTE.size()):
				if not _execute_required(&"move", {"direction": FAILURE_ROUTE[_step]}):
					return false
			if not bool(_module.get("failed")):
				return _fail("Fixture %s did not reach failure" % state_name)
			return true
		"success":
			if not await _load_board(&"rule_10_shared_frames"):
				return false
			for _step: int in range(SUCCESS_ROUTE.size()):
				if not _execute_required(&"move", {"direction": SUCCESS_ROUTE[_step]}):
					return false
			if not bool(_module.get("solved")):
				return _fail("Fixture %s did not reach success" % state_name)
			return true
	return _fail("Unknown capture state: %s" % state_name)


func _load_board(board_id: StringName) -> bool:
	var level := RuleLevelLoader.load_level(board_id)
	if not bool(level.get("ok", false)):
		return _fail("Could not load capture board %s" % String(board_id))
	var state := _module.save_state()
	state["board_id"] = String(board_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	state["solved"] = false
	state["failed"] = false
	state["turn_index"] = 0
	state["selected_3d_subject_id"] = ""
	state["selected_metrix_id"] = ""
	state["hotbar_slot"] = 0
	state["completed_board_ids"] = []
	state["undo_stack"] = []
	_module.load_state(state)
	if String(_module.get("board_id")) != String(board_id):
		return _fail("Capture board %s was not loaded" % String(board_id))
	return true


func _execute_required(command: StringName, payload: Dictionary = {}) -> bool:
	if not _module.execute_command(command, payload):
		return _fail("Capture command was rejected: %s" % String(command))
	return true


func _capture(state_name: String, requested_size: Vector2i) -> bool:
	await _wait_for_settle()
	var root_size := root.size
	var image := root.get_texture().get_image()
	var actual_size := Vector2i(image.get_width(), image.get_height())
	var filename := "rule_rewrite_%dx%d_%s.png" % [requested_size.x, requested_size.y, state_name]
	var path := _output_directory.path_join(filename)
	print("CAPTURE state=%s requested=%dx%d root=%dx%d image=%dx%d path=%s" % [
		state_name, requested_size.x, requested_size.y, root_size.x, root_size.y,
		actual_size.x, actual_size.y, path
	])
	if root_size != requested_size or actual_size != requested_size:
		return _fail("Capture dimensions do not match request: %s" % state_name)
	if FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(path):
		return _fail("Refusing to overwrite capture path: %s" % path)
	var error := image.save_png(path)
	if error != OK:
		return _fail("Could not save visual capture %s: %s" % [path, error_string(error)])
	return true


func _wait_for_settle() -> void:
	for _frame: int in range(SETTLE_FRAME_COUNT):
		await process_frame
		await RenderingServer.frame_post_draw


func _parse_output_directory(args: PackedStringArray) -> String:
	var value := ""
	if args.size() == 2 and args[0] == "--output-dir":
		value = args[1]
	elif args.size() == 1 and args[0].begins_with("--output-dir="):
		value = args[0].trim_prefix("--output-dir=")
	else:
		push_error("Usage: --output-dir <absolute temp directory>")
		quit(2)
		return ""
	value = value.strip_edges()
	if value.is_empty() or value.begins_with("--"):
		push_error("A non-empty --output-dir value is required")
		quit(2)
		return ""
	return value


func _validate_output_directory(value: String) -> String:
	if not value.is_absolute_path():
		_fail("--output-dir must be an absolute path: %s" % value)
		return ""
	var output_path := value.replace("\\", "/").simplify_path().trim_suffix("/")
	var workspace_path := ProjectSettings.globalize_path("res://").replace("\\", "/").simplify_path().trim_suffix("/")
	if _path_is_within(output_path, workspace_path):
		_fail("Refusing output directory inside workspace: %s" % output_path)
		return ""
	var temp_path := OS.get_temp_dir().replace("\\", "/").simplify_path().trim_suffix("/")
	if not _path_is_within(output_path, temp_path):
		_fail("Refusing output directory outside the system temp directory: %s" % output_path)
		return ""
	if FileAccess.file_exists(output_path) or DirAccess.dir_exists_absolute(output_path):
		_fail("Refusing existing output path: %s" % output_path)
		return ""
	if _path_contains_link(output_path):
		_fail("Refusing output path containing a link: %s" % output_path)
		return ""
	return output_path


func _path_is_within(path: String, root: String) -> bool:
	var normalized_path := path.trim_suffix("/")
	var normalized_root := root.trim_suffix("/")
	if OS.get_name() == "Windows":
		normalized_path = normalized_path.to_lower()
		normalized_root = normalized_root.to_lower()
	return normalized_path == normalized_root or normalized_path.begins_with(normalized_root + "/")


func _path_contains_link(path: String) -> bool:
	var current := path
	while not current.is_empty():
		var parent_path := current.get_base_dir()
		if parent_path.is_empty() or parent_path == current:
			break
		var parent := DirAccess.open(parent_path)
		if parent == null:
			break
		if parent.is_link(current):
			return true
		current = parent_path
	return false


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
