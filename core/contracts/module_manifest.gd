class_name ModuleManifest
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export_file("*.tscn") var entry_scene: String = ""
@export var save_version: int = 1
@export var input_actions: PackedStringArray = PackedStringArray()
