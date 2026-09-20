class_name TinVisualNovelTemplate
extends Node

signal line_changed(line: Dictionary)
signal choice_made(index: int)

const KitScript = preload("res://addons/tin_integrations/runtime/tin_integration_kit.gd")

var kit: TinIntegrationKit = KitScript.new()
var lines: Array[Dictionary] = []

func begin(script_lines: Array[Dictionary]) -> void:
	lines = script_lines.duplicate(true)
	line_changed.emit(kit.dialogue_begin(lines))

func next() -> void:
	line_changed.emit(kit.dialogue_next())

func choose(index: int) -> bool:
	var accepted: bool = kit.dialogue_choose(index)
	if accepted:
		choice_made.emit(index)
	return accepted
