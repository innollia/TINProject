extends GutTest

const ENTRY: PackedScene = preload("res://modules/physics_puzzle_platformer/entry.tscn")
const MANIFEST: ModuleManifest = preload("res://modules/physics_puzzle_platformer/module_manifest.tres")
const InputBubble = preload("res://modules/physics_puzzle_platformer/systems/input_bubble.gd")
const BodyKind = preload("res://modules/physics_puzzle_platformer/domain/body_kind.gd")
const KIT: String = "res://modules/physics_puzzle_platformer/"

var _modules: Array[Node] = []


func after_each() -> void:
	for module: Node in _modules:
		if is_instance_valid(module):
			module.exit()
			remove_child(module)
			module.free()
	_modules.clear()


func _spawn(level_id: String = "lvl_chalk_shelf", pop: bool = true, state: Dictionary = {}) -> Node:
	var module: Node = ENTRY.instantiate()
	add_child(module)
	_modules.append(module)
	var context := ModuleContext.new()
	context.module_id = MANIFEST.id
	context.input_enabled = true
	for action: String in MANIFEST.input_actions:
		context.allowed_actions.append(StringName(action))
	var levels: Array = []
	var tools: Array = []
	for _i: int in 8:
		levels.append(level_id)
		tools.append("tool_paper_fan")
	context.arrival = {"ppp_seed": 99, "ppp_sequence": levels, "ppp_tools": tools} if state.is_empty() else {}
	module.load_state(state)
	module.enter(context)
	if pop:
		for action: String in InputBubble.PROFILE:
			module.bubble.pop(action)
		module.step(0.5)
		module.step(1.0)
	return module


func _sources(folders: Array = ["", "domain", "systems", "presentation"]) -> Dictionary:
	var result: Dictionary = {}
	for folder: String in folders:
		var path: String = KIT + folder
		var dir := DirAccess.open(path)
		if dir == null:
			continue
		for file: String in dir.get_files():
			if file.ends_with(".gd") or file.ends_with(".tscn"):
				result[folder + "/" + file] = FileAccess.get_file_as_string(path.path_join(file))
	return result

func _visible_labels(root: Node, found: Array[Label]) -> void:
	for child: Node in root.get_children():
		if child is Label and (child as Label).is_visible_in_tree() and not (child as Label).text.is_empty():
			found.append(child)
		_visible_labels(child, found)


func test_no_text_or_hud_during_play() -> void:
	var module: Node = _spawn()
	for _i: int in 10:
		await wait_physics_frames(1)
	var labels: Array[Label] = []
	_visible_labels(module, labels)
	assert_eq(labels.size(), 0, "no visible Label while playing")
	assert_eq(module.find_children("*", "ProgressBar", true, false).size(), 0)


func test_level_title_shows_only_level_name_in_intro() -> void:
	var module: Node = _spawn("lvl_rolling_coin", false)
	module.bubble.done = true
	var labels: Array[Label] = []
	_visible_labels(module, labels)
	for label: Label in labels:
		assert_true(label.text.length() <= 24)


func test_world_rect_fits_each_resolution() -> void:
	var module: Node = _spawn()
	var screen: Control = module.get_node("GameScreen")
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	for size: Vector2 in [Vector2(1280, 720), Vector2(1920, 1080), Vector2(2560, 1440), Vector2(1280, 1024)]:
		screen.size = size
		await wait_process_frames(1)
		var rect: Rect2 = screen.world_rect()
		assert_true(Rect2(Vector2.ZERO, size).grow(0.5).encloses(rect), "world fits %s" % size)
		assert_almost_eq(rect.size.x / rect.size.y, 16.0 / 9.0, 0.01, "aspect kept %s" % size)


func test_no_player_text_literals_outside_content() -> void:
	var names: Array[String] = []
	var dir := DirAccess.open(KIT + "content/levels")
	for file: String in dir.get_files():
		if file.begins_with("lvl_"):
			names.append(String(JSON.parse_string(FileAccess.get_file_as_string(KIT + "content/levels/" + file))["name"]))
	var sources: Dictionary = _sources()
	for path: String in sources:
		for level_name: String in names:
			assert_false(String(sources[path]).contains(level_name), "%s has %s" % [path, level_name])