class_name ModuleContext
extends RefCounted

var module_id: StringName = &""
var input_enabled: bool = false
var allowed_actions: Array[StringName] = []
var arrival: Dictionary = {}
var identity_view: Dictionary = {}

func allows_action(action: StringName) -> bool:
	return input_enabled and allowed_actions.has(action) and InputMap.has_action(action)

func is_action_pressed(action: StringName) -> bool:
	return allows_action(action) and Input.is_action_pressed(action)

func get_axis(negative: StringName, positive: StringName) -> float:
	return float(is_action_pressed(positive)) - float(is_action_pressed(negative))
