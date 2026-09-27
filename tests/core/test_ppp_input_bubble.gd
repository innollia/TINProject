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

func test_profile_is_five_fixed_actions() -> void:
	assert_eq(Array(InputBubble.PROFILE), ["ppp_move_left", "ppp_move_right", "ppp_jump", "ppp_grab", "ppp_reset_level"])


func test_bubble_appears_on_first_entry_and_blocks_input() -> void:
	var module: Node = _spawn("lvl_chalk_shelf", false)
	assert_true(module.bubble.active)
	assert_false(module.execute_command(&"move", {"axis": 1.0}), "bubble blocks commands")


func test_key_press_pops_only_its_bubble() -> void:
	var bubble: RefCounted = InputBubble.new()
	bubble.start([])
	bubble.advance(1.0, {})
	bubble.pop("ppp_jump")
	assert_eq(bubble.get_bubble_state("ppp_jump"), "popped")
	assert_eq(bubble.get_bubble_state("ppp_grab"), "intact")


func test_completion_requires_all_popped() -> void:
	var bubble: RefCounted = InputBubble.new()
	bubble.start([])
	bubble.advance(1.0, {})
	for action: String in InputBubble.PROFILE.slice(0, 4):
		bubble.pop(action)
	bubble.advance(1.0, {})
	assert_false(bubble.is_complete())
	bubble.pop("ppp_reset_level")
	bubble.advance(1.0, {})
	assert_true(bubble.is_complete())


func test_cells_are_stable_across_save() -> void:
	var bubble: RefCounted = InputBubble.new()
	bubble.start([])
	var cells: Dictionary = bubble.serialized_cells()
	var again: RefCounted = InputBubble.new()
	again.restore(bubble.to_save(), [])
	assert_eq(again.serialized_cells(), cells)


func test_bubble_does_not_return_after_completion() -> void:
	var module: Node = _spawn()
	var saved: Dictionary = module.save_state()
	var reloaded: Node = _spawn("", false, saved)
	assert_false(reloaded.bubble.active)


func test_no_instruction_text_in_overlay() -> void:
	var text: String = FileAccess.get_file_as_string(KIT + "presentation/bubble_overlay.gd")
	var regex := RegEx.new()
	regex.compile("\\.text\\s*=\\s*\"([^\"]*)\"")
	for found: RegExMatch in regex.search_all(text):
		assert_true(found.get_string(1).length() <= 6, "overlay literal '%s' is a key caption" % found.get_string(1))