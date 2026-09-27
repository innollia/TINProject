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

func _code_only(text: String) -> String:
	var lines: PackedStringArray = []
	for line: String in text.split("\n"):
		var cut: int = line.find("#")
		lines.append(line if cut < 0 else line.substr(0, cut))
	return "\n".join(lines)


func test_no_image_or_resource_loading() -> void:
	for path: String in _sources():
		var code: String = _code_only(_sources()[path])
		assert_false(code.contains("Image.load") or code.contains("ResourceLoader.load") or code.contains(" load("), path)


func test_no_absolute_root_or_service_locator() -> void:
	var sources: Dictionary = _sources()
	for path: String in sources:
		var code: String = _code_only(sources[path])
		assert_false(code.contains("/root") or code.contains("get_tree().root") or code.contains("Engine.get_singleton"), path)


func test_no_inventory_or_lock_and_key() -> void:
	var sources: Dictionary = _sources()
	var strings := RegEx.new()
	strings.compile("\"[^\"]*\"")
	for path: String in sources:
		var code: String = strings.sub(_code_only(sources[path]), "\"\"", true).to_lower()
		assert_false(code.contains("inventory"), path)
		assert_false(code.contains("unlocks") or code.contains("key_id") or code.contains("required_for"), path)


func test_no_pity_or_duplicate_suppression() -> void:
	var code: String = _code_only(FileAccess.get_file_as_string(KIT + "systems/selector.gd")).to_lower()
	for token: String in ["pity", "weight", "last_level", "levels_seen"]:
		assert_false(code.contains(token), token)


func test_no_refilling_lore_device() -> void:
	var sources: Dictionary = _sources()
	var tokens: Array[String] = ["codex", "journal", "diary", "lore", "bestiary", "logbook", "encyclopedia", "recap", "epilogue", "tutorial", "hint_text", "dialogue", "subtitle", "narration"]
	var strings := RegEx.new()
	strings.compile("\"[^\"]*\"")
	for path: String in sources:
		var code: String = strings.sub(_code_only(sources[path]), "\"\"", true).to_lower()
		for token: String in tokens:
			assert_false(code.contains(token), "%s has %s" % [path, token])


func test_player_is_not_character_body() -> void:
	var sources: Dictionary = _sources()
	for path: String in sources:
		assert_false(_code_only(sources[path]).contains("CharacterBody2D"), path)