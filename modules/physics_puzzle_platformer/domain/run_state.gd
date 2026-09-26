extends RefCounted

const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

var run_seed: int = 0
var run_index: int = 0
var sequence: Array[Dictionary] = []
var cursor: int = 0
var tool_ids: Array[String] = []
var levels_seen: Dictionary = {}
var tools_seen: Dictionary = {}
var total_objectives: int = 0
var completed_levels: Array[int] = []
var run_complete: bool = false
var deaths: int = 0
var resets: int = 0
var tools_used: int = 0
var bubble: Dictionary = {}


static func seed_is_valid(value: Variant) -> bool:
	if not (value is int or value is float):
		return false
	if not is_finite(float(value)) or not is_equal_approx(float(value), roundf(float(value))):
		return false
	var number: float = float(value)
	return number >= 1.0 and number <= float(Tuning.RUN_SEED_MAX)


static func cosmetic_seed(value: int) -> int:
	return (value * Tuning.COSMETIC_MUL + Tuning.COSMETIC_ADD) & 0x7FFFFFFF


func current_level_id() -> String:
	if cursor < 0 or cursor >= sequence.size():
		return ""
	return String(sequence[cursor].get("level_id", ""))


func current_tool_id() -> String:
	if cursor < 0 or cursor >= tool_ids.size():
		return ""
	return tool_ids[cursor]


func current_mutations() -> Array:
	if cursor < 0 or cursor >= sequence.size():
		return []
	return (sequence[cursor].get("mutations", []) as Array).duplicate(true)


func note_entered(level_id: String, tool_id: String) -> void:
	levels_seen[level_id] = int(levels_seen.get(level_id, 0)) + 1
	if not tool_id.is_empty():
		tools_seen[tool_id] = int(tools_seen.get(tool_id, 0)) + 1


func sequence_level_ids() -> Array[String]:
	var ids: Array[String] = []
	for entry: Dictionary in sequence:
		ids.append(String(entry.get("level_id", "")))
	return ids
