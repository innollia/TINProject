extends GutTest

const MODULE_ROOT: String = "res://modules/descent_exploration"
const MANIFEST_PATH: String = "res://modules/descent_exploration/module_manifest.tres"
const ENTRY_PATH: String = "res://modules/descent_exploration/entry.tscn"
const ACTIONS: Array[String] = [
	"descent_exploration_up", "descent_exploration_down", "descent_exploration_left",
	"descent_exploration_right", "descent_exploration_confirm", "descent_exploration_cancel",
]
const SCREEN_NAMES: Array[String] = ["정지", "귀환", "삼키다"]
const SHELL_NAME: String = "하강"
const TEXT_KEYS: Array[String] = ["title", "text", "desc", "description", "caption", "hint", "subtitle", "lore", "note", "memo", "summary"]
const LORE_TOKENS: Array[String] = [
	"codex", "journal", "diary", "lore", "chronicle", "bestiary", "logbook", "encyclopedia", "recap",
	"epilogue", "afterword", "ending_summary", "ending_text", "story", "history", "exposition", "narration",
	"caption", "subtitle", "dialog", "dialogue", "speech", "monologue", "memo", "letter", "read_note",
	"unlock_note", "plaque_text", "tutorial", "hint_text", "explain",
]
const WORLDSTATE_FILES: Array[String] = ["domain/worldstate_view.gd", "systems/body_read.gd", "systems/requires_body.gd"]

var _requests: Array = []
var _persisted: Array = []


func _context(enabled: bool = true, arrival: Dictionary = {}) -> ModuleContext:
	var context := ModuleContext.new()
	context.module_id = &"descent_exploration"
	context.input_enabled = enabled
	for action: String in ACTIONS:
		context.allowed_actions.append(StringName(action))
	context.arrival = arrival
	return context


func _entered(enabled: bool = true, arrival: Dictionary = {}, saved: Dictionary = {}) -> DescentModule:
	var module := DescentModule.new()
	add_child_autofree(module)
	module.load_state(saved)
	module.enter(_context(enabled, arrival))
	module.set_physics_process(false)
	return module


func _advance(module: DescentModule, seconds: float, intent: RunIntent = null) -> void:
	var frames: int = maxi(1, int(round(seconds * 60.0)))
	for _frame: int in frames:
		module.step_frame(1.0 / 60.0, intent)


func _files(root: String, extensions: Array[String]) -> Array[String]:
	var found: Array[String] = []
	var directory := DirAccess.open(root)
	if directory == null:
		return found
	for file_name: String in directory.get_files():
		if extensions.has(file_name.get_extension()):
			found.append(root.path_join(file_name))
	for folder: String in directory.get_directories():
		found.append_array(_files(root.path_join(folder), extensions))
	return found


func _strip(text: String) -> String:
	var out: String = ""
	for line: String in text.split("\n"):
		var kept: String = ""
		var quote: String = ""
		var index: int = 0
		while index < line.length():
			var character: String = line[index]
			if quote.is_empty():
				if character == "#":
					break
				kept += character
				if character == "\"" or character == "'":
					quote = character
			else:
				if character == "\\":
					index += 2
					continue
				if character == quote:
					kept += character
					quote = ""
			index += 1
		out += kept + "\n"
	return out


func _literals(fragment: String) -> Array[String]:
	var found: Array[String] = []
	var pattern := RegEx.create_from_string("\"((?:[^\"\\\\]|\\\\.)*)\"")
	for hit: RegExMatch in pattern.search_all(fragment):
		found.append(hit.get_string(1))
	return found


func _code_files() -> Array[String]:
	var files: Array[String] = []
	for path: String in _files(MODULE_ROOT, ["gd"] as Array[String]):
		var relative: String = path.trim_prefix(MODULE_ROOT + "/")
		if relative == "module.gd" or relative.begins_with("presentation/") or relative.begins_with("domain/") or relative.begins_with("systems/"):
			files.append(path)
	return files


func test_manifest_loads_with_the_module_id_and_six_actions() -> void:
	var manifest := load(MANIFEST_PATH) as ModuleManifest
	assert_not_null(manifest)
	assert_eq(manifest.id, &"descent_exploration")
	assert_eq(manifest.save_version, 1)
	assert_eq(manifest.entry_scene, ENTRY_PATH)
	assert_eq(manifest.input_actions.size(), 6)
	for action: String in ACTIONS:
		assert_true(manifest.input_actions.has(action), action)
	assert_eq(manifest.display_name, SHELL_NAME)


func test_entry_scene_root_is_the_module() -> void:
	var packed := load(ENTRY_PATH) as PackedScene
	assert_not_null(packed)
	var instance: Node = packed.instantiate()
	assert_true(instance is DescentModule)
	instance.free()


func test_enter_keeps_input_and_exit_disables_it() -> void:
	var module := DescentModule.new()
	add_child_autofree(module)
	module.load_state({})
	var context := _context(true)
	module.enter(context)
	module.set_physics_process(false)
	assert_true(context.input_enabled)
	assert_not_null(module.runtime)
	assert_eq(module.runtime.id, "stratum_roots")
	module.exit()
	assert_false(context.input_enabled)
	assert_null(module.context)


func test_reset_command_returns_to_a_new_run() -> void:
	var module := _entered()
	module.state.stratum_index = 3
	module.state.stratum_id = "stratum_nursery"
	module.state.add_fact("vent_above")
	module.state.pick_up(MatterItem.create("x", 2, "weigh", "x"))
	assert_true(module.execute_command(&"reset", {}))
	assert_eq(module.state.stratum_index, 0)
	assert_eq(module.state.mass, 0)
	assert_true(module.state.facts.is_empty())
	assert_ne(module.state.world_seed, 0)


func test_retry_command_returns_to_the_checkpoint() -> void:
	var module := _entered()
	module.state.stratum_id = "stratum_nursery"
	module.state.stratum_index = 3
	module.state.position = Vector2(300.0, 900.0)
	module.state.checkpoint = {"stratum_id": "stratum_nursery", "anchor_id": "a1", "position": [80.0, 300.0], "mass": 0, "facts": [], "carried": []}
	assert_true(module.execute_command(&"retry", {}))
	assert_eq(module.state.stratum_id, "stratum_nursery")
	assert_eq(module.state.position, Vector2(80.0, 300.0))
	assert_eq(module.runtime.id, "stratum_nursery")


func test_input_profile_command_accepts_keys_and_refuses_an_empty_payload() -> void:
	var module := _entered()
	assert_true(module.execute_command(&"input_profile", {"required_keys": ACTIONS.duplicate(), "previous": []}))
	var bubble: Dictionary = module.get_input_bubble_state()
	assert_eq((bubble["slots"] as Array).size(), 6)
	assert_false(bool(bubble["complete"]))
	assert_false(module.execute_command(&"input_profile", {}))
	assert_false(module.execute_command(&"존재하지_않는_명령", {}))


func test_input_profile_marks_restored_and_rising_keys() -> void:
	var module := _entered()
	module.set_key_profile(["descent_exploration_up", "descent_exploration_cancel"], ["descent_exploration_up", "other_left"])
	var bubble: Dictionary = module.get_input_bubble_state()
	var states: Dictionary = {}
	for slot: Dictionary in bubble["slots"] as Array:
		states[slot["action"]] = slot["state"]
	assert_eq(states["descent_exploration_up"], "restoring")
	assert_eq(states["descent_exploration_cancel"], "rising")
	assert_eq(bubble["popped_traces"], ["other_left"] as Array[String])


func test_disabled_input_reaches_no_system() -> void:
	var idle := _entered(false)
	var pushed := _entered(false)
	_advance(idle, 0.5)
	_advance(pushed, 0.5, RunIntent.create(false, true, true, false, true, true))
	assert_eq(pushed.state.position, idle.state.position)
	assert_eq(pushed.state.velocity, idle.state.velocity)
	assert_eq(pushed.state.surge_cooldown_for, 0.0)


func test_first_frame_holds_then_play_begins_and_requests_the_key_profile() -> void:
	var module := _entered()
	watch_signals(module)
	assert_eq(module.state.phase, "first_frame")
	_advance(module, 0.2)
	assert_eq(module.state.phase, "playing")
	assert_signal_emitted(module, "requested")
	var parameters: Array = get_signal_parameters(module, "requested")
	assert_eq(parameters[0], &"input_profile")
	assert_eq((parameters[1] as Dictionary)["required_keys"], ACTIONS)


func test_idle_body_sinks_without_input() -> void:
	var module := _entered()
	_advance(module, 0.2)
	var start: Vector2 = module.state.position
	_advance(module, 1.0)
	assert_gt(module.state.position.y, start.y)


func test_surging_down_breaks_the_roots_throat() -> void:
	var module := _entered()
	_advance(module, 0.2)
	module.state.position = Vector2(320.0, 636.0)
	module.state.velocity = Vector2.ZERO
	_advance(module, 1.0 / 60.0, RunIntent.create(false, true, false, false, true))
	_advance(module, 0.1, RunIntent.create(false, true))
	assert_true(module.state.open_bristles.has("throat_wall"))
	_advance(module, 3.0, RunIntent.create(false, true))
	assert_gt(module.state.position.y, 640.0)


func test_descent_trigger_moves_to_the_next_stratum_through_the_veil() -> void:
	var module := _entered()
	_advance(module, 0.2)
	module.state.position = Vector2(320.0, 960.0)
	_advance(module, 1.0 / 60.0)
	assert_eq(module.state.phase, "transition")
	assert_true(module.state.routes_opened.has("exit_roots"))
	_advance(module, 1.0)
	assert_eq(module.state.phase, "playing")
	assert_eq(module.state.stratum_id, "stratum_halls")
	assert_eq(module.state.stratum_index, 1)
	assert_eq(module.runtime.id, "stratum_halls")
	assert_eq(module.state.position.x, 320.0)


func test_still_mouth_finishes_the_run_with_the_hollow_ending() -> void:
	var saved: Dictionary = {"schema": 1, "stratum_index": 5, "stratum_id": "stratum_floor"}
	var persisted: Array = []
	var arrival: Dictionary = {"persist_checkpoint": func(id: String, data: Dictionary) -> void: persisted.append([id, data])}
	var module := _entered(true, arrival, saved)
	watch_signals(module)
	_advance(module, 0.2)
	module.state.position = Vector2(168.0, 930.0)
	_advance(module, 1.0 / 60.0)
	assert_eq(module.state.phase, "ending")
	assert_eq(module.state.ending_id, "ending.hollow")
	_advance(module, 1.7)
	assert_eq(module.state.phase, "finished")
	assert_signal_emitted(module, "finished")
	var result: ModuleResult = get_signal_parameters(module, "finished")[0]
	assert_eq(result.data["ending_id"], "ending.hollow")
	assert_false(persisted.is_empty())
	assert_eq((persisted[persisted.size() - 1][1] as Dictionary)["ending_id"], "ending.hollow")


func test_heart_mouth_needs_a_fed_body_to_open() -> void:
	var saved: Dictionary = {"schema": 1, "stratum_index": 5, "stratum_id": "stratum_floor", "carried": [{"id": "matter_seed_vial", "size": 1, "verb": "feed", "tag": "seed", "source_stratum": "stratum_teeth"}]}
	var module := _entered(true, {}, saved)
	_advance(module, 0.2)
	module.state.position = Vector2(320.0, 760.0)
	module.state.velocity = Vector2.ZERO
	_advance(module, 1.2)
	assert_true(bool(module.runtime.find_membrane("heart_meld")["open"]))
	_advance(module, 3.0, RunIntent.create(false, true))
	assert_eq(module.state.ending_id, "ending.swallow")


func test_anchor_persists_the_checkpoint_through_the_arrival_hook() -> void:
	var persisted: Array = []
	var arrival: Dictionary = {"persist_checkpoint": func(id: String, data: Dictionary) -> void: persisted.append([id, data])}
	var module := _entered(true, arrival)
	_advance(module, 0.2)
	module.state.position = Vector2(200.0, 600.0)
	_advance(module, 1.0 / 60.0)
	assert_eq(persisted.size(), 1)
	assert_eq(persisted[0][0], "descent_exploration")
	assert_true(((persisted[0][1] as Dictionary)["anchors_taken"] as Array).has("stratum_roots#a1"))
	assert_true(module.frame_events.has(&"desc_anchor"))


func test_missing_persist_hook_never_stops_the_run() -> void:
	var module := _entered(true, {"persist_checkpoint": "not a callable"})
	_advance(module, 0.2)
	module.state.position = Vector2(200.0, 600.0)
	_advance(module, 1.0 / 60.0)
	assert_eq(module.state.anchors_taken, ["stratum_roots#a1"] as Array[String])
	assert_eq(module.state.phase, "playing")


func test_downed_body_returns_to_the_anchor_with_its_knowledge() -> void:
	var module := _entered()
	_advance(module, 0.2)
	module.state.position = Vector2(200.0, 600.0)
	_advance(module, 1.0 / 60.0)
	module.state.add_fact("current_lies")
	module.state.pick_up(MatterItem.create("matter_roots_bead", 1, "weigh", "bead", "stratum_roots"))
	module.runtime.matter[0]["present"] = false
	module.state.position = Vector2(500.0, 900.0)
	module.state.integrity = 0
	module.state.downed_for = 0.0
	_advance(module, 1.4)
	assert_eq(module.state.integrity, 3)
	assert_almost_eq(module.state.position.x, 200.0, 0.01)
	assert_almost_eq(module.state.position.y, 600.0, 0.5)
	assert_true(module.state.carried.is_empty())
	assert_true(module.state.facts.has("current_lies"))
	assert_true(bool(module.runtime.matter[0]["present"]))


func test_module_code_does_not_reach_other_nodes_or_modules() -> void:
	for path: String in _files(MODULE_ROOT, ["gd", "tscn", "tres"] as Array[String]):
		var text: String = FileAccess.get_file_as_string(path)
		var code: String = _strip(text) if path.ends_with(".gd") else text
		for banned: String in ["get_nodes_in_group", "get_tree()", "/root", "Engine.get_singleton", "get_node(\"/"]:
			assert_false(code.contains(banned), "%s uses %s" % [path, banned])
		for reference: String in ["res://app/", "res://meta/", "res://core/worldstate"]:
			assert_false(text.contains(reference), "%s references %s" % [path, reference])
		var modules_ref := RegEx.create_from_string("res://modules/(?!descent_exploration/)")
		assert_null(modules_ref.search(text), "%s references another module" % path)


func test_worldstate_word_lives_only_in_the_three_view_files() -> void:
	for path: String in _files(MODULE_ROOT, ["gd", "tscn", "tres", "json"] as Array[String]):
		var relative: String = path.trim_prefix(MODULE_ROOT + "/")
		if WORLDSTATE_FILES.has(relative):
			continue
		assert_false(FileAccess.get_file_as_string(path).contains("worldstate"), relative)


func test_no_player_text_outside_whitelist() -> void:
	var assignment := RegEx.create_from_string("\\b(text|tooltip_text|title|placeholder_text)\\s*=\\s*(\"(?:[^\"\\\\]|\\\\.)*\")")
	var draw := RegEx.create_from_string("draw_string\\(([^\\n]*)\\)")
	var hangul := RegEx.create_from_string("[가-힣]")
	var draw_calls: int = 0
	for path: String in _code_files():
		var text: String = FileAccess.get_file_as_string(path)
		var relative: String = path.trim_prefix(MODULE_ROOT + "/")
		var lines: PackedStringArray = text.split("\n")
		for number: int in lines.size():
			var line: String = lines[number]
			var code_line: String = _strip(line)
			for hit: RegExMatch in assignment.search_all(line):
				for literal: String in _literals(hit.get_string(2)):
					assert_true(SCREEN_NAMES.has(literal), "%s:%d %s" % [relative, number + 1, literal])
			for hit: RegExMatch in draw.search_all(code_line):
				draw_calls += 1 if relative.begins_with("presentation/") else 0
				for literal: String in _literals(hit.get_string(1)):
					assert_true(false, "%s:%d draws the literal %s" % [relative, number + 1, literal])
			assert_false(line.contains(SHELL_NAME), "%s:%d holds the shell name" % [relative, number + 1])
			if not relative.begins_with("presentation/"):
				for literal: String in _literals(line):
					assert_null(hangul.search(literal), "%s:%d holds player-facing Korean %s" % [relative, number + 1, literal])
	if DirAccess.dir_exists_absolute(MODULE_ROOT.path_join("presentation")):
		assert_eq(draw_calls, 1)
	for path: String in _files(MODULE_ROOT.path_join("authored"), ["json"] as Array[String]):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		assert_eq(_text_keys(parsed), [] as Array[String], path)
	var manifest := load(MANIFEST_PATH) as ModuleManifest
	assert_eq(manifest.display_name, SHELL_NAME)


func _text_keys(value: Variant) -> Array[String]:
	var found: Array[String] = []
	if value is Dictionary:
		for key: Variant in value as Dictionary:
			if TEXT_KEYS.has(String(key).to_lower()):
				found.append(String(key))
			found.append_array(_text_keys((value as Dictionary)[key]))
	elif value is Array:
		for entry: Variant in value as Array:
			found.append_array(_text_keys(entry))
	return found


func test_screen_names_map_only_the_three_endings() -> void:
	var view_path: String = MODULE_ROOT.path_join("presentation/descent_view.gd")
	if not FileAccess.file_exists(view_path):
		pending("presentation is not built yet (OQ-1)")
		return
	var text: String = FileAccess.get_file_as_string(view_path)
	for ending: String in DescentState.ENDING_IDS:
		assert_true(text.contains("\"%s\"" % ending), ending)
	var hangul := RegEx.create_from_string("\"([^\"]*[가-힣][^\"]*)\"")
	for hit: RegExMatch in hangul.search_all(text):
		assert_true(SCREEN_NAMES.has(hit.get_string(1)), hit.get_string(1))


func _identifier_words(text: String) -> Array[String]:
	var words: Array[String] = []
	var identifier := RegEx.create_from_string("[A-Za-z_][A-Za-z0-9_.]*")
	var camel := RegEx.create_from_string("([a-z0-9])([A-Z])")
	for hit: RegExMatch in identifier.search_all(text):
		var snake: String = camel.sub(hit.get_string(), "$1_$2", true).to_lower().replace(".", "_")
		words.append("_%s_" % snake)
	return words


func test_no_refilling_lore_device() -> void:
	for path: String in _files(MODULE_ROOT, ["gd", "tscn", "tres", "json"] as Array[String]):
		var text: String = FileAccess.get_file_as_string(path)
		var checked: String = ""
		if path.ends_with(".json"):
			var parsed: Variant = JSON.parse_string(text)
			checked = " ".join(_all_keys(parsed))
		else:
			checked = _strip(text)
		var words: Array[String] = _identifier_words(checked)
		var hits: Array[String] = []
		for token: String in LORE_TOKENS:
			for word: String in words:
				if word.contains("_%s_" % token) and not hits.has(word):
					hits.append(word)
		assert_eq(hits, [] as Array[String], path)
		assert_false(text.contains("docs/world"), "%s loads docs/world" % path)
	var presentation: String = MODULE_ROOT.path_join("presentation")
	for path: String in _files(presentation, ["gd", "tscn", "tres"] as Array[String]):
		for token: String in LORE_TOKENS:
			assert_false(path.get_file().to_lower().contains(token), path)
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(MODULE_ROOT.path_join("audio_manifest.json")))
	for event: Variant in (manifest as Dictionary)["events"] as Array:
		assert_ne(String((event as Dictionary)["bus"]), "Voice")


func _all_keys(value: Variant) -> Array[String]:
	var keys: Array[String] = []
	if value is Dictionary:
		for key: Variant in value as Dictionary:
			keys.append(String(key))
			keys.append_array(_all_keys((value as Dictionary)[key]))
	elif value is Array:
		for entry: Variant in value as Array:
			keys.append_array(_all_keys(entry))
	return keys


func test_module_folder_holds_no_image_or_font_file() -> void:
	var banned: Array[String] = ["png", "jpg", "jpeg", "webp", "bmp", "svg", "ttf", "otf", "aseprite", "kra"]
	assert_eq(_files(MODULE_ROOT, banned), [] as Array[String])
