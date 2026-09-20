@tool
extends EditorPlugin

const HOST_SCRIPT = preload("res://addons/tin_integrations/runtime/tin_integration_host.gd")

func _enter_tree() -> void:
	add_custom_type("TinIntegrationHost", "Node", HOST_SCRIPT, null)

func _exit_tree() -> void:
	remove_custom_type("TinIntegrationHost")
