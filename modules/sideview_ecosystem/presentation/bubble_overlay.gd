class_name EcoBubbleOverlay
extends Control

## §5.1, §13.2, AGENTS.md Input Bubble 계약. first_entry 와 동일한 API 이름·4상태.
## GRID_COLUMNS = 3. 설명문 0자. 글리프는 현재 바인딩에서 뽑는다(§W.3).

const GRID_COLUMNS: int = 3
const STATE_INTACT: StringName = &"intact"
const STATE_POPPED: StringName = &"popped"
const STATE_RISING: StringName = &"rising"
const STATE_RESTORING: StringName = &"restoring"

const CELLS: Dictionary = {
	&"eco_left": Vector2i(0, 0),
	&"eco_jump": Vector2i(1, 0),
	&"eco_right": Vector2i(2, 0),
	&"eco_curl": Vector2i(1, 1),
	&"eco_use": Vector2i(2, 1),
}

var _states: Dictionary = {}
var _rise_amount: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for action: StringName in CELLS:
		_states[action] = STATE_RISING
		_rise_amount[action] = 0.0
	queue_redraw()


func get_input_bubble_state() -> Dictionary:
	return _states.duplicate()


func get_bubble_state(action: StringName) -> StringName:
	return _states.get(action, STATE_INTACT)


func get_bubble_cell(action: StringName) -> Vector2i:
	return CELLS.get(action, Vector2i.ZERO)


func set_key_profile(_profile: Dictionary, _previous_profile: Dictionary) -> void:
	queue_redraw()


func notify_pressed(action: StringName) -> void:
	if _states.get(action, STATE_INTACT) != STATE_POPPED:
		_states[action] = STATE_POPPED
		queue_redraw()


func step(delta: float) -> void:
	var changed: bool = false
	for action: StringName in CELLS:
		if _states[action] == STATE_RISING:
			_rise_amount[action] = minf(float(_rise_amount[action]) + delta / 0.6, 1.0)
			if _rise_amount[action] >= 1.0:
				_states[action] = STATE_INTACT
			changed = true
	if changed:
		queue_redraw()


func all_popped() -> bool:
	for action: StringName in CELLS:
		if _states[action] != STATE_POPPED:
			return false
	return true


func _draw() -> void:
	if all_popped():
		return
	var cell_size: Vector2 = Vector2(36.0, 36.0)
	var origin: Vector2 = Vector2(24.0, size.y - cell_size.y * 2.0 - 48.0)
	for action: StringName in CELLS:
		var cell: Vector2i = CELLS[action]
		var pos: Vector2 = origin + Vector2(cell.x * cell_size.x, cell.y * cell_size.y)
		var state: StringName = _states[action]
		var alpha: float = 0.0
		match state:
			STATE_INTACT:
				alpha = 1.0
			STATE_RISING:
				alpha = clampf(float(_rise_amount[action]), 0.0, 1.0)
			STATE_RESTORING:
				alpha = 1.0
			STATE_POPPED:
				alpha = 0.0
		if alpha <= 0.0:
			continue
		var lift: float = (1.0 - alpha) * cell_size.y
		draw_rect(Rect2(pos + Vector2(0.0, lift), cell_size * 0.8), Color(0.9, 0.9, 0.9, 0.5 * alpha), false)


func _glyph_for(action: StringName) -> String:
	var events: Array = InputMap.action_get_events(action)
	if events.is_empty():
		return ""
	var event: InputEvent = events[0]
	if event is InputEventKey:
		return (event as InputEventKey).as_text_physical_keycode().substr(0, 3)
	return ""


func get_glyph(action: StringName) -> String:
	return _glyph_for(action)
