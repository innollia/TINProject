class_name InputRouter
extends Node

var locked: bool = false
var _context: ModuleContext

func configure_actions() -> void:
	var keys: Dictionary = {&"meta_accept": KEY_ENTER, &"meta_cancel": KEY_ESCAPE, &"meta_pause": KEY_P}
	for action: StringName in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = keys[action]
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)
	for action: StringName in [&"meta_pointer_primary", &"meta_pointer_secondary"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT if action == &"meta_pointer_primary" else MOUSE_BUTTON_RIGHT
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)

func activate(value: ModuleContext) -> void:
	deactivate()
	_context = value
	_context.input_enabled = not locked

func deactivate() -> void:
	if _context != null:
		_context.input_enabled = false
	_context = null

func set_locked(value: bool) -> void:
	locked = value
	if _context != null:
		_context.input_enabled = not locked
