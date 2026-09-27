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

const AudioManifestData = preload("res://modules/physics_puzzle_platformer/audio_manifest.gd")


func test_manifest_shape() -> void:
	var data: Dictionary = AudioManifestData.audio_manifest
	assert_eq(data["id_prefix"], "ppp")
	assert_true(data["events"] is Array and not (data["events"] as Array).is_empty())
	for event: Dictionary in data["events"]:
		for key: String in ["id", "file", "bus", "max_polyphony", "volume_db"]:
			assert_true(event.has(key), "%s has %s" % [event.get("id"), key])


func test_all_ids_prefixed_and_files_under_kit_audio() -> void:
	for event: Dictionary in AudioManifestData.audio_manifest["events"]:
		assert_true(String(event["id"]).begins_with("ppp_"))
		assert_true(String(event["file"]).begins_with(KIT + "audio/"))


func test_buses_and_ranges() -> void:
	for event: Dictionary in AudioManifestData.audio_manifest["events"]:
		assert_true(["Music", "SFX", "UI"].has(String(event["bus"])), "no Voice bus")
		assert_between(int(event["max_polyphony"]), 1, 8)
		assert_between(float(event["volume_db"]), -24.0, 0.0)


func test_events_fire_without_audio_files() -> void:
	var module: Node = _spawn()
	var world: RefCounted = module.get_world_state()
	var egg: RefCounted = world.bodies[world.find("egg_low")]
	for _i: int in 40:
		if egg.destroyed:
			break
		module.get_director().place_rigid(module.get_director().player_node(), egg.position())
		await wait_physics_frames(1)
	assert_true(int(module.event_counts.get(&"ppp_egg_take", 0)) >= 1, "egg event counted with no wav on disk")