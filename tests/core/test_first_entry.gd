extends GutTest

const ENTRY_SCENE: String = "res://modules/first_entry/entry.tscn"
const ACTIONS: Array[StringName] = [
	&"first_entry_up", &"first_entry_down", &"first_entry_left",
	&"first_entry_right", &"first_entry_confirm", &"first_entry_cancel",
]
const KEY_CODES: Array[int] = [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_Z, KEY_X]

var _bindings: Dictionary = {}
var _module: GameModule
var _context: ModuleContext
var _requests: Array[Dictionary] = []
var _layout_viewport: SubViewport


func before_each() -> void:
	_requests.clear()
	_bindings.clear()
	for index: int in range(ACTIONS.size()):
		var action: StringName = ACTIONS[index]
		var existed: bool = InputMap.has_action(action)
		var previous: Dictionary = {"existed": existed}
		if existed:
			previous["events"] = InputMap.action_get_events(action).duplicate()
			previous["deadzone"] = InputMap.action_get_deadzone(action)
			Input.action_release(action)
			InputMap.action_erase_events(action)
		else:
			InputMap.add_action(action)
		_bindings[action] = previous
		InputMap.action_set_deadzone(action, 0.2)
		var event := InputEventKey.new()
		event.physical_keycode = KEY_CODES[index]
		InputMap.action_add_event(action, event)


func after_each() -> void:
	_dispose_module()
	for action: StringName in ACTIONS:
		if InputMap.has_action(action):
			Input.action_release(action)
		var previous: Dictionary = _bindings.get(action, {})
		if previous.get("existed", false):
			if not InputMap.has_action(action):
				InputMap.add_action(action)
			InputMap.action_erase_events(action)
			InputMap.action_set_deadzone(action, float(previous["deadzone"]))
			for event: InputEvent in previous["events"]:
				InputMap.action_add_event(action, event)
		elif InputMap.has_action(action):
			InputMap.erase_action(action)
	_bindings.clear()
	_requests.clear()


func _dispose_module() -> void:
	if is_instance_valid(_module):
		_module.exit()
		_module.free()
	_module = null
	_context = null
	if is_instance_valid(_layout_viewport):
		_layout_viewport.free()
	_layout_viewport = null


func _spawn(state: Dictionary = {}, arrival: Dictionary = {}, identity: Dictionary = {}, viewport_size: Vector2i = Vector2i.ZERO) -> bool:
	_dispose_module()
	_requests.clear()
	var packed: PackedScene = load(ENTRY_SCENE) as PackedScene
	assert_not_null(packed, "First entry scene loads independently of AppRoot")
	if packed == null:
		return false
	var instance: Node = packed.instantiate()
	_module = instance as GameModule
	assert_not_null(_module, "First entry implements GameModule")
	if _module == null:
		instance.free()
		return false
	_context = ModuleContext.new()
	_context.module_id = &"first_entry"
	_context.allowed_actions.assign(ACTIONS)
	_context.set("arrival", arrival.duplicate(true))
	_context.set("identity_view", identity.duplicate(true))
	_module.context = _context
	assert_true(_module.has_signal(&"requested"), "Module request contract is available")
	if not _module.has_signal(&"requested"):
		return false
	_module.connect(&"requested", _on_requested)
	if viewport_size != Vector2i.ZERO:
		_layout_viewport = SubViewport.new()
		_layout_viewport.size = viewport_size
		add_child(_layout_viewport)
		_layout_viewport.add_child(_module)
	else:
		add_child(_module)
	_module.set_process(false)
	_module.load_state(state)
	_module.enter(_context)
	_context.input_enabled = true
	return true


func _on_requested(kind: StringName, payload: Dictionary) -> void:
	_requests.append({"kind": kind, "payload": payload.duplicate(true)})


func _tick(frames: int = 1) -> void:
	for frame: int in range(frames):
		_module.call(&"_process", 0.25)


func _action(action: StringName, pressed: bool = true) -> bool:
	return bool(_module.call(&"apply_action", action, pressed))


func _phase() -> String:
	return String(_module.save_state().get("phase", ""))


func _keys() -> Array:
	return _module.save_state().get("keys", [])


func _requests_of(kind: StringName) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	for request: Dictionary in _requests:
		if request["kind"] == kind:
			matches.append(request)
	return matches


func _editor_state() -> Dictionary:
	var keys: Array[String] = []
	for action: StringName in ACTIONS:
		keys.append(String(action))
	return {"phase": "editor", "keys": keys, "shape": 0, "color": 0, "language": "ko"}


func test_six_distinct_keys_absorb_then_zoom_and_checkpoint_once() -> void:
	if not _spawn():
		return
	assert_eq(_phase(), "keys")
	assert_eq(_keys().size(), 0)
	for index: int in range(ACTIONS.size() - 1):
		assert_true(_action(ACTIONS[index]), "First distinct press is accepted")
		assert_false(_action(ACTIONS[index]), "Held press is deduplicated")
		_action(ACTIONS[index], false)
		assert_false(_action(ACTIONS[index]), "Released and repeated key is not counted twice")
		_action(ACTIONS[index], false)
	assert_eq(_keys().size(), 5)
	_tick(8)
	assert_eq(_phase(), "keys", "Five distinct keys cannot unlock the editor")
	assert_eq(_requests.size(), 0)
	assert_true(_action(ACTIONS[5]))
	_action(ACTIONS[5], false)
	assert_eq(_keys().size(), 6)
	for action: StringName in ACTIONS:
		assert_true(_keys().has(String(action)))
	_tick()
	assert_eq(_phase(), "keys", "The last key must finish absorption")
	_tick()
	assert_eq(_phase(), "zoom")
	assert_eq(_requests_of(&"checkpoint").size(), 0)
	_tick(2)
	assert_eq(_phase(), "zoom", "Zoom does not skip its approximately 0.8 second transition")
	_tick(2)
	assert_eq(_phase(), "editor")
	var checkpoints: Array[Dictionary] = _requests_of(&"checkpoint")
	assert_eq(checkpoints.size(), 1)
	if checkpoints.size() == 1:
		assert_eq(checkpoints[0]["payload"].get("intro_seen"), true)
	_tick(12)
	assert_eq(_requests_of(&"checkpoint").size(), 1, "Editor checkpoint is emitted only once")
	assert_eq(_requests_of(&"start").size(), 0, "Intro confirm does not leak into a start request")


func test_editor_actions_require_a_new_press_edge() -> void:
	if not _spawn(_editor_state()):
		return
	assert_true(_action(&"first_entry_right"))
	var selected: Dictionary = _module.save_state()
	assert_ne(selected["color"], 0)
	assert_false(_action(&"first_entry_right"))
	assert_eq(_module.save_state(), selected)
	_action(&"first_entry_right", false)
	assert_true(_action(&"first_entry_right"))
	assert_ne(_module.save_state()["color"], selected["color"])
	assert_true(_action(&"first_entry_cancel"))
	assert_false(_action(&"first_entry_cancel"))
	assert_eq(_requests_of(&"menu").size(), 1)
	_action(&"first_entry_cancel", false)
	assert_true(_action(&"first_entry_cancel"))
	assert_eq(_requests_of(&"menu").size(), 2)


func test_input_polling_uses_fixture_actions_and_deduplicates_held_input() -> void:
	if not _spawn():
		return
	Input.action_press(&"first_entry_up")
	_tick(4)
	assert_eq(_keys(), ["first_entry_up"])
	Input.action_release(&"first_entry_up")
	_tick()
	Input.action_press(&"first_entry_up")
	_tick(4)
	assert_eq(_keys(), ["first_entry_up"])
	Input.action_release(&"first_entry_up")
	_module.load_state(_editor_state())
	Input.action_press(&"first_entry_right")
	_tick()
	var selected: Dictionary = _module.save_state()
	assert_ne(selected["color"], 0)
	_tick(4)
	assert_eq(_module.save_state(), selected)
	Input.action_release(&"first_entry_right")
	_tick()
	Input.action_press(&"first_entry_right")
	_tick()
	assert_ne(_module.save_state()["color"], selected["color"])


func test_held_confirm_through_absorption_and_zoom_requires_release_before_start() -> void:
	if not _spawn():
		return
	Input.action_press(&"first_entry_confirm")
	_tick()
	assert_eq(_keys(), ["first_entry_confirm"])
	for action: StringName in ACTIONS:
		if action == &"first_entry_confirm":
			continue
		Input.action_press(action)
		_tick()
		Input.action_release(action)
	assert_eq(_keys().size(), 6)
	assert_eq(_phase(), "keys", "The sixth key is still being absorbed")
	assert_true(Input.is_action_pressed(&"first_entry_confirm"))
	assert_eq(_requests_of(&"start").size(), 0)
	_tick()
	assert_eq(_phase(), "zoom")
	assert_eq(_requests_of(&"start").size(), 0)
	_tick(2)
	assert_eq(_phase(), "zoom")
	_tick(2)
	assert_eq(_phase(), "editor")
	assert_eq(_requests_of(&"checkpoint").size(), 1)
	for frame: int in range(12):
		_tick()
		assert_true(Input.is_action_pressed(&"first_entry_confirm"))
		assert_eq(_phase(), "editor", "Held intro confirm must not begin collision")
		assert_eq(_requests_of(&"start").size(), 0)
	assert_eq(_requests_of(&"menu").size(), 0, "Absorbed cancel must not open the menu")
	Input.action_release(&"first_entry_confirm")
	_tick()
	assert_eq(_phase(), "editor", "Release alone must not start")
	assert_eq(_requests_of(&"start").size(), 0)
	Input.action_press(&"first_entry_confirm")
	_tick()
	assert_eq(_phase(), "collision", "A new confirm edge begins collision")
	assert_eq(_requests_of(&"start").size(), 0, "Start still waits for collision")
	_tick(3)
	assert_eq(_requests_of(&"start").size(), 1)
	_tick(8)
	assert_eq(_requests_of(&"start").size(), 1, "Holding the new press cannot start twice")


func test_disabled_actions_and_button_callbacks_are_inert() -> void:
	if not _spawn():
		return
	for state: Dictionary in [{}, _editor_state()]:
		_module.load_state(state)
		_context.input_enabled = false
		var before: Dictionary = _module.save_state()
		var before_time: float = float(_module.get("phase_time"))
		for action: StringName in ACTIONS:
			assert_false(_action(action))
			Input.action_press(action)
		assert_false(bool(_module.call(&"request_menu")))
		assert_false(bool(_module.call(&"request_language")))
		assert_false(bool(_module.call(&"select_shape", 2)))
		assert_false(bool(_module.call(&"select_color", 2)))
		assert_false(bool(_module.call(&"request_start")))
		for button: Node in _module.find_children("*", "BaseButton", true, false):
			button.emit_signal(&"pressed")
		_tick(8)
		assert_eq(_module.save_state(), before)
		assert_eq(float(_module.get("phase_time")), before_time)
		assert_eq(_requests.size(), 0)
		for action: StringName in ACTIONS:
			Input.action_release(action)
			_action(action, false)
	_context.input_enabled = true
	assert_true(bool(_module.call(&"select_shape", 2)), "Re-enabling input restores interaction")


func test_disabled_collision_does_not_advance_or_emit_start() -> void:
	if not _spawn(_editor_state()):
		return
	assert_true(bool(_module.call(&"request_start")))
	_context.input_enabled = false
	var before_time: float = float(_module.get("phase_time"))
	_tick(8)
	assert_eq(_phase(), "collision")
	assert_eq(float(_module.get("phase_time")), before_time)
	assert_eq(_requests_of(&"start").size(), 0)
	_context.input_enabled = true
	_tick(4)
	assert_eq(_requests_of(&"start").size(), 1)


func test_design_selection_survives_json_roundtrip() -> void:
	if not _spawn(_editor_state()):
		return
	for index: int in range(3):
		assert_true(bool(_module.call(&"select_shape", index)))
		assert_true(bool(_module.call(&"select_color", index)))
		assert_eq(_module.save_state()["shape"], index)
		assert_eq(_module.save_state()["color"], index)
	assert_true(_module.execute_command(&"language", {"language": "en"}))
	var saved: Dictionary = _module.save_state()
	assert_true(SaveService.is_json_safe(saved))
	var decoded: Variant = JSON.parse_string(JSON.stringify(saved))
	assert_true(decoded is Dictionary)
	if not decoded is Dictionary:
		return
	if not _spawn(decoded, {"intro_seen": true, "language": "en"}, {"shape": 0, "color": 0}):
		return
	var restored: Dictionary = _module.save_state()
	assert_eq(restored["phase"], saved["phase"])
	assert_eq(restored["keys"], saved["keys"])
	assert_eq(restored["shape"], 2)
	assert_eq(restored["color"], 2)
	assert_eq(restored["language"], "en")
	assert_true(restored["shape"] is int)
	assert_true(restored["color"] is int)
	var detached: Dictionary = _module.save_state()
	detached["keys"].clear()
	detached["shape"] = 0
	assert_eq(_module.save_state(), restored, "Save snapshots are detached")
	_tick(8)
	assert_eq(_phase(), "editor")
	assert_eq(_requests.size(), 0, "Restored editor does not duplicate checkpoint or start")


func test_intro_seen_uses_short_entry_and_injected_identity() -> void:
	if not _spawn({}, {"intro_seen": true, "language": "en"}, {"shape": 1, "color": 2}):
		return
	assert_eq(_phase(), "entry")
	assert_eq(_module.save_state()["shape"], 1)
	assert_eq(_module.save_state()["color"], 2)
	assert_eq(_module.save_state()["language"], "en")
	_tick(2)
	assert_eq(_phase(), "entry", "Returning entry lasts approximately 0.6 seconds")
	_tick()
	assert_eq(_phase(), "editor")
	_tick(8)
	assert_eq(_requests.size(), 0, "Returning entry skips keys and does not repeat the checkpoint")


func test_collision_requests_start_once_and_retry_recovers() -> void:
	if not _spawn(_editor_state()):
		return
	assert_true(bool(_module.call(&"select_shape", 1)))
	assert_true(bool(_module.call(&"select_color", 2)))
	assert_true(bool(_module.call(&"request_start")))
	assert_eq(_phase(), "collision")
	assert_eq(_requests_of(&"start").size(), 0)
	assert_false(bool(_module.call(&"request_start")))
	assert_false(_action(&"first_entry_confirm"))
	_tick()
	assert_eq(_requests_of(&"start").size(), 0, "Start waits for the collision")
	_tick(3)
	var starts: Array[Dictionary] = _requests_of(&"start")
	assert_eq(starts.size(), 1, "Collision finishes within one second")
	if starts.size() == 1:
		assert_eq(starts[0]["payload"].get("shape"), 1)
		assert_eq(starts[0]["payload"].get("color"), 2)
	_tick(12)
	assert_false(bool(_module.call(&"request_start")))
	assert_eq(_requests_of(&"start").size(), 1)
	assert_true(_module.execute_command(&"retry_start"))
	assert_eq(_phase(), "editor")
	assert_true(bool(_module.call(&"select_color", 1)))
	assert_true(bool(_module.call(&"request_start")))
	_tick(4)
	assert_eq(_requests_of(&"start").size(), 2, "Failed navigation can retry without trapping the editor")
	_tick(8)
	assert_eq(_requests_of(&"start").size(), 2)


func test_restored_collision_returns_to_editor_without_duplicate_or_trap() -> void:
	if not _spawn(_editor_state()):
		return
	assert_true(bool(_module.call(&"select_shape", 2)))
	assert_true(bool(_module.call(&"request_start")))
	_tick()
	var decoded: Variant = JSON.parse_string(JSON.stringify(_module.save_state()))
	assert_true(decoded is Dictionary)
	if not decoded is Dictionary:
		return
	if not _spawn(decoded, {"intro_seen": true, "language": "ko"}):
		return
	assert_eq(_phase(), "editor", "Transient collision restores to an interactive editor")
	assert_eq(_module.save_state()["shape"], 2)
	_tick(8)
	assert_eq(_requests.size(), 0)
	assert_true(bool(_module.call(&"select_color", 2)))
	assert_true(bool(_module.call(&"request_start")))
	_tick(4)
	assert_eq(_requests_of(&"start").size(), 1)


func test_presentation_draws_intro_editor_and_collision() -> void:
	if not _spawn():
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var presentation: Control = _module.get_node("Presentation") as Control
	assert_eq(presentation.size, presentation.get_viewport_rect().size)
	_module.load_state(_editor_state())
	for index: int in range(3):
		assert_true(bool(_module.call(&"select_shape", index)))
		assert_true(bool(_module.call(&"select_color", index)))
		assert_eq(int(presentation.get("_shape")), index)
		assert_eq(int(presentation.get("_color")), index)
		await get_tree().process_frame
		await get_tree().process_frame
	assert_true(_module.execute_command(&"language", {"language": "en"}))
	assert_eq(presentation.get_node("StartButton").text, "COLLIDE")
	assert_true(bool(_module.call(&"request_start")))
	_tick()
	await get_tree().process_frame
	await get_tree().process_frame


func test_menu_language_and_command_contracts() -> void:
	if not _spawn(_editor_state()):
		return
	assert_true(bool(_module.call(&"request_menu")))
	assert_eq(_requests_of(&"menu").size(), 1)
	assert_true(bool(_module.call(&"request_language")))
	var language_requests: Array[Dictionary] = _requests_of(&"language")
	assert_eq(language_requests.size(), 1)
	if language_requests.size() == 1:
		assert_eq(language_requests[0]["payload"], {})
	assert_true(_module.execute_command(&"language", {"language": "en"}))
	assert_eq(_module.save_state()["language"], "en")
	var before: Dictionary = _module.save_state()
	var request_count: int = _requests.size()
	assert_false(_module.execute_command(&"unknown_first_entry_test_command", {"shape": 2}))
	assert_false(_action(&"unknown_first_entry_test_action"))
	assert_false(bool(_module.call(&"select_shape", -1)))
	assert_false(bool(_module.call(&"select_shape", 3)))
	assert_false(bool(_module.call(&"select_color", -1)))
	assert_false(bool(_module.call(&"select_color", 3)))
	assert_eq(_module.save_state(), before)
	assert_eq(_requests.size(), request_count)
	assert_true(_module.execute_command(&"reset"))
	assert_eq(_phase(), "keys")
	assert_eq(_keys().size(), 0)
	assert_true(_action(&"first_entry_up"), "Reset re-arms collected keys")
