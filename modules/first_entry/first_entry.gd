extends GameModule

const ACTIONS: Array[StringName] = [
	&"first_entry_up", &"first_entry_down", &"first_entry_left",
	&"first_entry_right", &"first_entry_confirm", &"first_entry_cancel",
]
const DEFAULT_KEY_PROFILE: Array[String] = [
	"first_entry_up", "first_entry_down", "first_entry_left",
	"first_entry_right", "first_entry_confirm", "first_entry_cancel",
]
const STATE_INTACT: String = "intact"
const STATE_POPPED: String = "popped"
const STATE_RISING: String = "rising"
const STATE_RESTORING: String = "restoring"
const GRID_COLUMNS: int = 3
const BUBBLE_DURATION: float = 0.45
const ABSORPTION_DURATION: float = 0.45
const ZOOM_DURATION: float = 0.8
const ENTRY_DURATION: float = 0.6
const COLLISION_DURATION: float = 0.8

var phase: String = "keys"
var keys: Array[String] = []
var shape: int = 0
var color: int = 0
var language: String = "ko"
var elapsed: float = 0.0
var phase_time: float = 0.0
var absorption: Dictionary = {}
var key_profile: Array[String] = []
var previous_key_profile: Array[String] = []
var bubble_states: Dictionary = {}
var bubble_progress: Dictionary = {}
var bubble_cells: Dictionary = {}
var bubble_slots: Array[String] = []
var _held: Dictionary = {}
var _fresh_state: bool = true
var _checkpoint_sent: bool = false
var _start_pending: bool = false
var _start_sent: bool = false
var _presentation: Control


func _ready() -> void:
	_presentation = get_node_or_null("Presentation") as Control
	if _presentation != null:
		_presentation.connect(&"shape_selected", select_shape)
		_presentation.connect(&"color_selected", select_color)
		_presentation.connect(&"start_pressed", request_start)
	_refresh()


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	if context == null:
		_fresh_state = false
		_refresh()
		return
	if _fresh_state:
		shape = _choice(context.identity_view.get("shape", 0))
		color = _choice(context.identity_view.get("color", 0))
	language = _language(context.arrival.get("language", language))
	if key_profile.is_empty():
		_install_profile(_default_profile(), [], true)
	var arrival_profile: Variant = _profile_from_arrival(context.arrival)
	if arrival_profile != null:
		var next_profile_value: Variant = _normalise_profile(arrival_profile)
		if next_profile_value != null:
			var next_profile: Array[String] = []
			for profile_value: Variant in next_profile_value:
				next_profile.append(String(profile_value))
			if _profile_supported(next_profile) and not _same_profile(next_profile, key_profile):
				var previous_profile: Array[String] = _copy_profile(key_profile)
				var arrival_previous: Variant = _previous_profile_from_arrival(context.arrival)
				if arrival_previous != null:
					var previous_value: Variant = _normalise_profile(arrival_previous)
					if previous_value != null:
						previous_profile.clear()
						for previous_item: Variant in previous_value:
							previous_profile.append(String(previous_item))
				if _fresh_state and arrival_previous == null:
					previous_profile.clear()
				_install_profile(next_profile, previous_profile, false)
	if context.arrival.get("intro_seen", false) == true and phase != "editor" and arrival_profile == null and _fresh_state:
		_fill_keys()
		_checkpoint_sent = true
		_set_phase("entry")
	_fresh_state = false
	_refresh()


func exit() -> void:
	_held.clear()
	_start_pending = false
	super.exit()
	_refresh()


func _process(delta: float) -> void:
	if not _can_input():
		_held.clear()
		_refresh()
		return
	var polled_actions: Array[StringName] = []
	for action: StringName in ACTIONS:
		polled_actions.append(action)
	for key: String in key_profile:
		var action_id: StringName = StringName(key)
		if not polled_actions.has(action_id):
			polled_actions.append(action_id)
	for action: StringName in polled_actions:
		apply_action(action, context.is_action_pressed(action))
		if not _can_input():
			_refresh()
			return
	var step: float = maxf(delta, 0.0)
	elapsed += step
	_advance_bubbles(step)
	_advance(step)
	_refresh()


func apply_action(action: StringName, pressed: bool = true) -> bool:
	if not _can_use_action(action):
		return false
	if not pressed:
		var was_held: bool = _held.has(action)
		_held.erase(action)
		return was_held
	if _held.has(action):
		return false
	if phase == "keys":
		if not key_profile.has(String(action)):
			return false
		_held[action] = true
		var key: String = String(action)
		if keys.has(key):
			return false
		_ensure_slot(key)
		keys.append(key)
		absorption[key] = 0.0
		_set_bubble_state(key, STATE_POPPED, 1.0)
		_refresh()
		return true
	if phase != "editor" or not ACTIONS.has(action):
		return false
	_held[action] = true
	match action:
		&"first_entry_up":
			return select_shape(posmod(shape - 1, 3))
		&"first_entry_down":
			return select_shape(posmod(shape + 1, 3))
		&"first_entry_left":
			return select_color(posmod(color - 1, 3))
		&"first_entry_right":
			return select_color(posmod(color + 1, 3))
		&"first_entry_confirm":
			return request_start()
		&"first_entry_cancel":
			return request_menu()
	return false


func set_key_profile(profile: Variant, previous_profile: Variant = null) -> bool:
	var next_value: Variant = _normalise_profile(profile)
	if next_value == null:
		return false
	var next_profile: Array[String] = []
	for value: Variant in next_value:
		next_profile.append(String(value))
	if not _profile_supported(next_profile):
		return false
	var previous: Array[String] = _copy_profile(key_profile)
	if previous_profile != null:
		var previous_value: Variant = _normalise_profile(previous_profile)
		if previous_value != null:
			previous.clear()
			for value: Variant in previous_value:
				previous.append(String(value))
	if previous_profile == null and _same_profile(next_profile, key_profile):
		return true
	if _same_profile(next_profile, key_profile) and _same_profile(previous, previous_key_profile):
		return true
	_install_profile(next_profile, previous, false)
	_refresh()
	return true


func get_key_profile() -> Array[String]:
	return _copy_profile(key_profile)


func get_input_bubble_state() -> Dictionary:
	var cells: Dictionary = _serialized_cells()
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
	}


func get_bubble_state(action: Variant = null) -> Variant:
	if action == null:
		return get_input_bubble_state()
	var key: String = String(action)
	return String(bubble_states.get(key, STATE_POPPED))


func get_bubble_cell(action: Variant) -> Vector2i:
	var key: String = String(action)
	if bubble_cells.has(key):
		return bubble_cells[key]
	return Vector2i(-1, -1)


func request_menu() -> bool:
	if not _can_input():
		return false
	requested.emit(&"menu", {})
	return true


func request_language() -> bool:
	if not _can_input():
		return false
	requested.emit(&"language", {})
	return true


func select_shape(index: int) -> bool:
	if not _can_input() or phase != "editor" or index < 0 or index > 2:
		return false
	shape = index
	_refresh()
	return true


func select_color(index: int) -> bool:
	if not _can_input() or phase != "editor" or index < 0 or index > 2:
		return false
	color = index
	_refresh()
	return true


func request_start() -> bool:
	if not _can_input() or phase != "editor" or _start_pending or _start_sent:
		return false
	_start_pending = true
	_set_phase("collision")
	_refresh()
	return true


func execute_command(command: StringName, payload: Dictionary = {}) -> bool:
	match command:
		&"language":
			var value: Variant = payload.get("language", null)
			if not value is String or value not in ["ko", "en"]:
				return false
			language = String(value)
			_refresh()
			return true
		&"key_profile", &"input_profile", &"transition_profile":
			var profile: Variant = payload.get("profile", payload.get("keys", null))
			if profile == null:
				profile = payload.get("required_keys", null)
			if profile == null:
				return false
			var previous: Variant = payload.get("previous", payload.get("previous_profile", null))
			return set_key_profile(profile, previous)
		&"retry_start":
			_start_pending = false
			_start_sent = false
			_set_phase("editor")
			_refresh()
			return true
		&"reset":
			load_state({})
			return true
	return false


func save_state() -> Dictionary:
	return {
		"phase": phase,
		"keys": keys.duplicate(),
		"shape": shape,
		"color": color,
		"language": language,
		"absorption": absorption.duplicate(true),
		"key_profile": key_profile.duplicate(),
		"previous_key_profile": previous_key_profile.duplicate(),
		"bubble_slots": bubble_slots.duplicate(),
		"bubble_states": bubble_states.duplicate(true),
		"bubble_progress": bubble_progress.duplicate(true),
		"bubble_cells": _serialized_cells(),
	}


func load_state(state: Dictionary) -> void:
	phase = "keys"
	keys.clear()
	absorption.clear()
	_held.clear()
	bubble_states.clear()
	bubble_progress.clear()
	bubble_cells.clear()
	bubble_slots.clear()
	shape = _choice(state.get("shape", 0))
	color = _choice(state.get("color", 0))
	language = _language(state.get("language", "ko"))
	elapsed = 0.0
	phase_time = 0.0
	_start_pending = false
	_start_sent = false
	_checkpoint_sent = false
	_fresh_state = state.is_empty()
	var saved_phase: Variant = state.get("phase", "keys")
	if saved_phase is String and saved_phase in ["keys", "zoom", "entry", "editor", "collision"]:
		phase = String(saved_phase)
	key_profile = _default_profile()
	var saved_profile: Variant = _normalise_profile(state.get("key_profile", null))
	if saved_profile != null:
		var saved_profile_actions: Array[String] = []
		for value: Variant in saved_profile:
			saved_profile_actions.append(String(value))
		if _profile_supported(saved_profile_actions):
			key_profile = saved_profile_actions
	previous_key_profile.clear()
	var saved_previous: Variant = _normalise_profile(state.get("previous_key_profile", null))
	if saved_previous != null:
		for value: Variant in saved_previous:
			var previous_key: String = String(value)
			if not previous_key_profile.has(previous_key):
				previous_key_profile.append(previous_key)
	var saved_slots: Variant = _normalise_profile(state.get("bubble_slots", null))
	if saved_slots != null:
		for value: Variant in saved_slots:
			_ensure_slot(String(value))
	for key: String in previous_key_profile:
		_ensure_slot(key)
	for key: String in key_profile:
		_ensure_slot(key)
	var saved_cells: Variant = state.get("bubble_cells", {})
	if saved_cells is Dictionary:
		var cell_owners: Dictionary = {}
		for slot: String in bubble_slots:
			var existing_cell: Vector2i = bubble_cells[slot]
			cell_owners[existing_cell] = slot
		var row_count: int = maxi(1, ceili(float(bubble_slots.size()) / float(GRID_COLUMNS)))
		for key: Variant in saved_cells:
			var key_name: String = String(key)
			var value: Variant = saved_cells[key]
			if not bubble_slots.has(key_name) or not value is Array or value.size() < 2:
				continue
			var x: Variant = value[0]
			var y: Variant = value[1]
			if not (x is int or x is float) or not (y is int or y is float):
				continue
			if not is_finite(float(x)) or not is_finite(float(y)):
				continue
			if float(x) != floorf(float(x)) or float(y) != floorf(float(y)):
				continue
			var cell := Vector2i(int(x), int(y))
			if cell.x < 0 or cell.x >= GRID_COLUMNS or cell.y < 0 or cell.y >= row_count:
				continue
			var owner: Variant = cell_owners.get(cell, null)
			if owner != null and String(owner) != key_name:
				continue
			bubble_cells[key_name] = cell
			cell_owners[cell] = key_name
	var saved_keys: Variant = state.get("keys", [])
	if saved_keys is Array:
		for value: Variant in saved_keys:
			if value is String or value is StringName:
				var key: String = String(value)
				if key_profile.has(key) and not keys.has(key):
					keys.append(key)
	var saved_absorption: Variant = state.get("absorption", {})
	if saved_absorption is Dictionary:
		for key: String in keys:
			if not saved_absorption.has(key):
				continue
			var absorption_value: Variant = saved_absorption[key]
			if absorption_value is int or absorption_value is float:
				if is_finite(float(absorption_value)):
					absorption[key] = clampf(float(absorption_value), 0.0, 1.0)
	if phase == "keys":
		_restore_bubble_states(state)
	else:
		if phase == "collision":
			phase = "editor"
		_fill_keys()
	_checkpoint_sent = phase in ["entry", "editor"]
	_refresh()


func _set_phase(value: String) -> void:
	phase = value
	phase_time = 0.0


func _advance(delta: float) -> void:
	if phase == "keys":
		phase_time += delta
		var remaining: float = 0.0
		for key: String in keys:
			var progress: float = float(absorption.get(key, 0.0))
			remaining = maxf(remaining, (1.0 - progress) * ABSORPTION_DURATION)
			absorption[key] = minf(1.0, progress + delta / ABSORPTION_DURATION)
		if keys.size() != key_profile.size() or remaining > delta:
			return
		delta = maxf(0.0, delta - remaining)
		_set_phase("zoom")
	phase_time += delta
	if phase == "zoom" and phase_time >= ZOOM_DURATION:
		_set_phase("editor")
		if not _checkpoint_sent:
			_checkpoint_sent = true
			requested.emit(&"checkpoint", {"intro_seen": true})
	elif phase == "entry" and phase_time >= ENTRY_DURATION:
		_set_phase("editor")
	elif phase == "collision" and phase_time >= COLLISION_DURATION and _start_pending and not _start_sent:
		_start_pending = false
		_start_sent = true
		requested.emit(&"start", {"shape": shape, "color": color})


func _advance_bubbles(delta: float) -> void:
	for key: String in bubble_slots:
		var state: String = String(bubble_states.get(key, STATE_POPPED))
		if state != STATE_RISING and state != STATE_RESTORING:
			continue
		var progress: float = float(bubble_progress.get(key, 0.0))
		progress = minf(1.0, progress + delta / BUBBLE_DURATION)
		if progress >= 1.0:
			_set_bubble_state(key, STATE_INTACT, 1.0)
		else:
			bubble_progress[key] = progress


func _set_bubble_state(key: String, state: String, progress: float) -> void:
	bubble_states[key] = state
	bubble_progress[key] = clampf(progress, 0.0, 1.0)


func _restore_bubble_states(state: Dictionary) -> void:
	var saved_states: Variant = state.get("bubble_states", {})
	var saved_progress: Variant = state.get("bubble_progress", {})
	var saved_absorption: Variant = state.get("absorption", {})
	for key: String in bubble_slots:
		if not key_profile.has(key):
			_set_bubble_state(key, STATE_POPPED, 1.0)
			continue
		var bubble_state: String = STATE_RISING
		if saved_states is Dictionary and saved_states.has(key):
			var candidate: Variant = saved_states[key]
			if candidate is String and candidate in [STATE_INTACT, STATE_POPPED, STATE_RISING, STATE_RESTORING]:
				bubble_state = String(candidate)
		elif keys.has(key):
			bubble_state = STATE_POPPED
		var progress: float = 0.0
		if bubble_state == STATE_INTACT or bubble_state == STATE_POPPED:
			progress = 1.0
		if saved_progress is Dictionary and saved_progress.has(key):
			var progress_value: Variant = saved_progress[key]
			if progress_value is int or progress_value is float:
				if is_finite(float(progress_value)):
					progress = clampf(float(progress_value), 0.0, 1.0)
		if saved_absorption is Dictionary and saved_absorption.has(key) and bubble_state == STATE_POPPED:
			var absorption_value: Variant = saved_absorption[key]
			if absorption_value is int or absorption_value is float:
				if is_finite(float(absorption_value)):
					progress = maxf(progress, clampf(float(absorption_value), 0.0, 1.0))
		_set_bubble_state(key, bubble_state, progress)


func _install_profile(next_profile: Array[String], previous_profile: Array[String], initial: bool) -> void:
	_held.clear()
	keys.clear()
	absorption.clear()
	var known: Dictionary = {}
	for key: String in bubble_slots:
		known[key] = true
	for key: String in previous_profile:
		_ensure_slot(key)
	for key: String in next_profile:
		_ensure_slot(key)
	var old_states: Dictionary = bubble_states.duplicate(true)
	for key: String in bubble_slots:
		if not next_profile.has(key):
			_set_bubble_state(key, STATE_POPPED, 1.0)
			continue
		var old_state: String = String(old_states.get(key, STATE_POPPED))
		if initial or not known.has(key):
			_set_bubble_state(key, STATE_RISING, 0.0)
		elif old_state == STATE_POPPED or old_state == STATE_RESTORING:
			_set_bubble_state(key, STATE_RESTORING, 0.0)
		elif previous_profile.has(key):
			_set_bubble_state(key, old_state, float(bubble_progress.get(key, 1.0 if old_state == STATE_INTACT else 0.0)))
		else:
			_set_bubble_state(key, STATE_RISING, 0.0)
	previous_key_profile = _copy_profile(previous_profile)
	key_profile = _copy_profile(next_profile)
	if not initial:
		phase = "keys"
		phase_time = 0.0
		_start_pending = false
		_start_sent = false


func _fill_keys() -> void:
	keys.clear()
	absorption.clear()
	for key: String in key_profile:
		_ensure_slot(key)
		keys.append(key)
		absorption[key] = 1.0
		_set_bubble_state(key, STATE_POPPED, 1.0)
	for key: String in bubble_slots:
		if not key_profile.has(key):
			_set_bubble_state(key, STATE_POPPED, 1.0)


func _ensure_slot(key: String) -> void:
	if key.is_empty() or bubble_slots.has(key):
		return
	var index: int = bubble_slots.size()
	var cell := Vector2i(index % GRID_COLUMNS, index / GRID_COLUMNS)
	while bubble_cells.values().has(cell):
		index += 1
		cell = Vector2i(index % GRID_COLUMNS, index / GRID_COLUMNS)
	bubble_slots.append(key)
	bubble_cells[key] = cell


func _serialized_cells() -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in bubble_cells:
		var cell: Vector2i = bubble_cells[key]
		result[String(key)] = [cell.x, cell.y]
	return result


func _default_profile() -> Array[String]:
	var result: Array[String] = []
	for action: String in DEFAULT_KEY_PROFILE:
		result.append(String(action))
	return result


func _copy_profile(value: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for key: String in value:
		result.append(String(key))
	return result


func _normalise_profile(value: Variant) -> Variant:
	var raw: Array = []
	if value is Array:
		raw = value
	elif value is PackedStringArray:
		for item: String in value:
			raw.append(item)
	elif value is Dictionary:
		for field: String in ["required", "keys", "actions", "profile"]:
			if value.has(field):
				return _normalise_profile(value[field])
		return null
	else:
		return null
	var result: Array[String] = []
	for item: Variant in raw:
		if item is String or item is StringName:
			var key: String = String(item)
			if not key.is_empty() and not result.has(key):
				result.append(key)
	if result.is_empty():
		return null
	return result


func _profile_from_arrival(arrival: Dictionary) -> Variant:
	for field: String in ["key_profile", "input_profile", "required_keys", "required_actions"]:
		if arrival.has(field):
			return arrival[field]
	if arrival.has("profile"):
		return arrival["profile"]
	return null


func _previous_profile_from_arrival(arrival: Dictionary) -> Variant:
	for field: String in ["previous_key_profile", "previous_profile", "previous_keys"]:
		if arrival.has(field):
			return arrival[field]
	return null


func _same_profile(left: Array[String], right: Array[String]) -> bool:
	if left.size() != right.size():
		return false
	var remaining: Array[String] = _copy_profile(right)
	for key: String in left:
		var index: int = remaining.find(key)
		if index < 0:
			return false
		remaining.remove_at(index)
	return remaining.is_empty()


func _profile_supported(profile: Array[String]) -> bool:
	for key: String in profile:
		if not _context_supports_action(StringName(key)):
			return false
	return true


func _can_use_action(action: StringName) -> bool:
	return context != null and context.allows_action(action)


func _context_supports_action(action: StringName) -> bool:
	if context == null:
		return true
	if not context.allowed_actions.has(action) or not InputMap.has_action(action):
		return false
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			return true
	return false


func _can_input() -> bool:
	return context != null and context.input_enabled


func _choice(value: Variant) -> int:
	if value is int:
		return clampi(int(value), 0, 2)
	if value is float and is_finite(float(value)):
		return int(clampf(float(value), 0.0, 2.0))
	return 0


func _language(value: Variant) -> String:
	return String(value) if value is String and value in ["ko", "en"] else "ko"


func _binding_labels() -> Dictionary:
	var result: Dictionary = {}
	for key: String in bubble_slots:
		result[key] = _binding_label(StringName(key))
	return result


func _binding_label(action: StringName) -> String:
	if InputMap.has_action(action):
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventKey:
				var key_event: InputEventKey = event as InputEventKey
				var code: int = key_event.physical_keycode
				if code == 0:
					code = key_event.keycode
				if code != 0:
					var display_event: InputEventKey = InputEventKey.new()
					display_event.keycode = code
					var text: String = display_event.as_text()
					if not text.is_empty():
						return text
	return String(action)


func _refresh() -> void:
	if not is_instance_valid(_presentation):
		return
	_presentation.call(&"update_view", {
		"phase": phase,
		"elapsed": elapsed,
		"phase_time": phase_time,
		"keys": keys.duplicate(),
		"absorption": absorption.duplicate(),
		"shape": shape,
		"color": color,
		"language": language,
		"enabled": _can_input(),
		"key_profile": key_profile.duplicate(),
		"previous_key_profile": previous_key_profile.duplicate(),
		"bubble_slots": bubble_slots.duplicate(),
		"bubble_states": bubble_states.duplicate(true),
		"bubble_progress": bubble_progress.duplicate(true),
		"bubble_cells": _serialized_cells(),
		"binding_labels": _binding_labels(),
	})
