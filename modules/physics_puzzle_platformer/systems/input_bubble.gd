extends RefCounted

const STATE_INTACT: String = "intact"
const STATE_POPPED: String = "popped"
const STATE_RISING: String = "rising"
const STATE_RESTORING: String = "restoring"
const STATES: Array[String] = [STATE_INTACT, STATE_POPPED, STATE_RISING, STATE_RESTORING]
const GRID_COLUMNS: int = 3
const BUBBLE_DURATION: float = 0.45
const ABSORPTION_DURATION: float = 0.45
const PROFILE: Array[String] = ["ppp_move_left", "ppp_move_right", "ppp_jump", "ppp_grab", "ppp_reset_level"]
const FIXED_CELLS: Dictionary = {
	"ppp_move_left": Vector2i(0, 0),
	"ppp_move_right": Vector2i(1, 0),
	"ppp_jump": Vector2i(2, 0),
	"ppp_grab": Vector2i(0, 1),
	"ppp_reset_level": Vector2i(1, 1),
}

var key_profile: Array[String] = []
var previous_key_profile: Array[String] = []
var bubble_states: Dictionary = {}
var bubble_progress: Dictionary = {}
var bubble_cells: Dictionary = {}
var bubble_slots: Array[String] = []
var absorption: Dictionary = {}
var active: bool = false
var done: bool = false


func start(previous: Array) -> void:
	var previous_profile: Array[String] = _profile(previous)
	_install(PROFILE.duplicate(), previous_profile, true)
	active = true
	done = false


func restore(saved: Dictionary, previous: Array) -> void:
	done = bool(saved.get("done", false))
	if done:
		active = false
		_install(PROFILE.duplicate(), _profile(previous), true)
		for key: String in bubble_slots:
			_set_state(key, STATE_POPPED, 1.0)
			absorption[key] = 1.0
		return
	start(previous)
	var cells: Dictionary = saved.get("cells", {})
	for key: Variant in cells:
		var cell: Variant = cells[key]
		if bubble_cells.has(String(key)) and cell is Vector2i:
			bubble_cells[String(key)] = cell
	var states: Dictionary = saved.get("states", {})
	for key: Variant in states:
		if bubble_states.has(String(key)) and STATES.has(String(states[key])):
			var state: String = String(states[key])
			_set_state(String(key), state, 1.0 if state == STATE_INTACT or state == STATE_POPPED else 0.0)
			if state == STATE_POPPED:
				absorption[String(key)] = 1.0


func advance(delta: float, pressed: Dictionary) -> void:
	if not active:
		return
	for key: String in bubble_slots:
		var state: String = String(bubble_states.get(key, STATE_POPPED))
		if state == STATE_RISING or state == STATE_RESTORING:
			var progress: float = minf(1.0, float(bubble_progress.get(key, 0.0)) + delta / BUBBLE_DURATION)
			if progress >= 1.0:
				_set_state(key, STATE_INTACT, 1.0)
			else:
				bubble_progress[key] = progress
		if absorption.has(key) and float(absorption[key]) < 1.0:
			absorption[key] = minf(1.0, float(absorption[key]) + delta / ABSORPTION_DURATION)
	for key: Variant in pressed:
		if bool(pressed[key]):
			pop(String(key))
	if is_complete():
		active = false
		done = true


func pop(action: String) -> bool:
	if not key_profile.has(action):
		return false
	var state: String = String(bubble_states.get(action, STATE_POPPED))
	if state == STATE_POPPED:
		return false
	_set_state(action, STATE_POPPED, 1.0)
	absorption[action] = 0.0
	return true


func is_complete() -> bool:
	for key: String in key_profile:
		if String(bubble_states.get(key, STATE_POPPED)) != STATE_POPPED:
			return false
		if float(absorption.get(key, 1.0)) < 1.0:
			return false
	return true


func set_key_profile(profile: Variant, previous_profile: Variant = null) -> bool:
	if not profile is Array:
		return false
	var next_profile: Array[String] = _profile(profile)
	for key: String in next_profile:
		if not PROFILE.has(key):
			return false
	var previous: Array[String] = key_profile.duplicate()
	if previous_profile is Array:
		previous = _profile(previous_profile)
	_install(next_profile, previous, false)
	active = not next_profile.is_empty()
	done = false
	return true


func get_input_bubble_state() -> Dictionary:
	var cells: Dictionary = serialized_cells()
	return {
		"profile": key_profile.duplicate(),
		"key_profile": key_profile.duplicate(),
		"previous_profile": previous_key_profile.duplicate(),
		"previous_key_profile": previous_key_profile.duplicate(),
		"states": bubble_states.duplicate(true),
		"bubble_states": bubble_states.duplicate(true),
		"progress": bubble_progress.duplicate(true),
		"bubble_progress": bubble_progress.duplicate(true),
		"cells": cells.duplicate(true),
		"bubble_cells": cells.duplicate(true),
		"slots": bubble_slots.duplicate(),
		"bubble_slots": bubble_slots.duplicate(),
		"active": active,
		"done": done,
	}


func get_bubble_state(action: Variant = null) -> Variant:
	if action == null:
		return get_input_bubble_state()
	return String(bubble_states.get(String(action), STATE_POPPED))


func get_bubble_cell(action: Variant) -> Vector2i:
	var key: String = String(action)
	if bubble_cells.has(key):
		return bubble_cells[key]
	return Vector2i(-1, -1)


func serialized_cells() -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in bubble_cells:
		var cell: Vector2i = bubble_cells[key]
		result[String(key)] = [cell.x, cell.y]
	return result


func to_save() -> Dictionary:
	return {"done": done, "states": bubble_states.duplicate(true), "cells": bubble_cells.duplicate(true)}


func _install(next_profile: Array[String], previous_profile: Array[String], initial: bool) -> void:
	var old_states: Dictionary = bubble_states.duplicate(true)
	for key: String in previous_profile:
		_ensure_slot(key)
	for key: String in next_profile:
		_ensure_slot(key)
	for key: String in bubble_slots:
		if not next_profile.has(key):
			_set_state(key, STATE_POPPED, 1.0)
			absorption[key] = 1.0
			continue
		var old_state: String = String(old_states.get(key, ""))
		if previous_profile.has(key) and (old_state == STATE_POPPED or old_state == STATE_RESTORING or old_state.is_empty()) and not initial:
			_set_state(key, STATE_RESTORING, 0.0)
		elif previous_profile.has(key) and initial:
			_set_state(key, STATE_RESTORING, 0.0)
		else:
			_set_state(key, STATE_RISING, 0.0)
		absorption.erase(key)
	previous_key_profile = previous_profile.duplicate()
	key_profile = next_profile.duplicate()


func _ensure_slot(key: String) -> void:
	if key.is_empty() or bubble_slots.has(key):
		return
	bubble_slots.append(key)
	if FIXED_CELLS.has(key):
		bubble_cells[key] = FIXED_CELLS[key]
		return
	var index: int = FIXED_CELLS.size()
	var cell := Vector2i(index % GRID_COLUMNS, floori(float(index) / float(GRID_COLUMNS)))
	while bubble_cells.values().has(cell):
		index += 1
		cell = Vector2i(index % GRID_COLUMNS, floori(float(index) / float(GRID_COLUMNS)))
	bubble_cells[key] = cell


func _set_state(key: String, state: String, progress: float) -> void:
	bubble_states[key] = state
	bubble_progress[key] = clampf(progress, 0.0, 1.0)


static func _profile(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			var key: String = String(item)
			if not key.is_empty() and not result.has(key):
				result.append(key)
	return result
