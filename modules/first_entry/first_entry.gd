extends GameModule

const ACTIONS: Array[StringName] = [
	&"first_entry_up", &"first_entry_down", &"first_entry_left",
	&"first_entry_right", &"first_entry_confirm", &"first_entry_cancel",
]
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
var _held: Dictionary = {}
var _fresh_state: bool = true
var _checkpoint_sent: bool = false
var _start_pending: bool = false
var _start_sent: bool = false
var _presentation: Control


func _ready() -> void:
	_presentation = get_node_or_null("Presentation") as Control
	if _presentation != null:
		_presentation.connect(&"menu_pressed", request_menu)
		_presentation.connect(&"language_pressed", request_language)
		_presentation.connect(&"shape_selected", select_shape)
		_presentation.connect(&"color_selected", select_color)
		_presentation.connect(&"start_pressed", request_start)
	_refresh()


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_held.clear()
	if context != null:
		if _fresh_state:
			shape = _choice(context.identity_view.get("shape", 0))
			color = _choice(context.identity_view.get("color", 0))
		language = _language(context.arrival.get("language", language))
		if context.arrival.get("intro_seen", false) == true and phase != "editor":
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
		_refresh()
		return
	for action: StringName in ACTIONS:
		apply_action(action, context.is_action_pressed(action))
		if not _can_input():
			_refresh()
			return
	var step: float = maxf(delta, 0.0)
	elapsed += step
	_advance(step)
	_refresh()


func apply_action(action: StringName, pressed: bool = true) -> bool:
	if not ACTIONS.has(action):
		return false
	if not pressed:
		var was_held: bool = _held.has(action)
		_held.erase(action)
		return was_held and _can_input()
	if not _can_input() or _held.has(action):
		return false
	_held[action] = true
	if phase == "keys":
		var key: String = String(action)
		if keys.has(key):
			return false
		keys.append(key)
		absorption[key] = 0.0
		_refresh()
		return true
	if phase != "editor":
		return false
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
	}


func load_state(state: Dictionary) -> void:
	phase = "keys"
	keys.clear()
	absorption.clear()
	_held.clear()
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
	var saved_keys: Variant = state.get("keys", [])
	if saved_keys is Array:
		for value: Variant in saved_keys:
			if value is String and ACTIONS.has(StringName(value)) and not keys.has(value):
				keys.append(String(value))
				absorption[String(value)] = 1.0
	if phase != "keys":
		_fill_keys()
	if phase == "collision":
		phase = "editor"
	_checkpoint_sent = phase in ["entry", "editor"]
	_refresh()


func _advance(delta: float) -> void:
	if phase == "keys":
		phase_time += delta
		var remaining: float = 0.0
		for key: String in keys:
			var progress: float = float(absorption.get(key, 0.0))
			remaining = maxf(remaining, (1.0 - progress) * ABSORPTION_DURATION)
			absorption[key] = minf(1.0, progress + delta / ABSORPTION_DURATION)
		if keys.size() != ACTIONS.size() or remaining > delta:
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


func _set_phase(value: String) -> void:
	phase = value
	phase_time = 0.0


func _fill_keys() -> void:
	keys.clear()
	absorption.clear()
	for action: StringName in ACTIONS:
		keys.append(String(action))
		absorption[String(action)] = 1.0


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
	})
