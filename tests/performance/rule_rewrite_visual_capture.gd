extends SceneTree

const ENTRY_SCENE: PackedScene = preload("res://modules/rule_rewriting/entry.tscn")
const CAPTURE_DIRECTORY: String = "C:/projects/TINProject/tests/performance/captures"

var _module: GameModule
var _module_context: ModuleContext


func _initialize() -> void:
	call_deferred("_capture_screens")


func _capture_screens() -> void:
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DirAccess.make_dir_recursive_absolute(CAPTURE_DIRECTORY)
	_module = ENTRY_SCENE.instantiate() as GameModule
	_module_context = ModuleContext.new()
	_module_context.module_id = &"rule_rewriting"
	_module_context.input_enabled = true
	_module.context = _module_context
	root.add_child(_module)
	_module.enter(_module_context)
	await _capture_board(&"rule_01_open_gate", "rule_rewrite_2d.png")
	await _capture_board(&"rule_14_owner_focus", "rule_rewrite_3d.png")
	_module.execute_command(&"open_inventory")
	await _capture("rule_rewrite_inventory.png")
	await _capture_board(&"rule_01_open_gate", "rule_rewrite_2d_base.png")
	var feedback_ids: Array[String] = []
	var rules := _module.get("rule_set") as RuleSet
	for sentence: RuleSentence in rules.sentences:
		feedback_ids.append_array(sentence.source_entity_ids)
		if not feedback_ids.is_empty():
			break
	var you_ids := _module.call("_you_ids") as Array[String]
	if not you_ids.is_empty():
		feedback_ids.append(you_ids[0])
	(_module.get("_view") as RuleBoardView).show_rule_change_feedback(feedback_ids)
	await _capture("rule_rewrite_local_feedback.png")
	_module.set("failed", true)
	_module.call("_refresh")
	await _capture("rule_rewrite_failure_recovery.png")
	_module.queue_free()
	await process_frame
	quit()


func _capture_board(board_id: StringName, filename: String) -> void:
	var level := RuleLevelLoader.load_level(board_id)
	if not bool(level.get("ok", false)):
		push_error("Could not load capture board %s" % String(board_id))
		quit(1)
		return
	var state := _module.save_state()
	state["board_id"] = String(board_id)
	state["grid"] = (level["state"] as RuleGridState).to_dictionary()
	_module.load_state(state)
	await process_frame
	await RenderingServer.frame_post_draw
	await _capture(filename)


func _capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s" % [CAPTURE_DIRECTORY, filename]
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save visual capture %s: %d" % [path, error])
		quit(1)
