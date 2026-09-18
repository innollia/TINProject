class_name GameModule
extends Node

signal finished(result: ModuleResult)
signal requested(kind: StringName, payload: Dictionary)

var context: ModuleContext

func enter(value: ModuleContext) -> void:
	context = value

func exit() -> void:
	if context != null:
		context.input_enabled = false
	context = null

func save_state() -> Dictionary:
	return {}

func load_state(_state: Dictionary) -> void:
	pass

func migrate_save(_old_version: int, data: Dictionary) -> Dictionary:
	return data.duplicate(true)

func execute_command(_command: StringName, _payload: Dictionary = {}) -> bool:
	return false
