class_name DeductionFocusableCaseControl
extends PanelContainer

signal activated(intent: StringName, payload: Dictionary)

const FILL: Color = Color("171b22")
const SELECTED_FILL: Color = Color("25242a")
const BORDER: Color = Color("59616f")
const FOCUS: Color = Color("d6b56c")
const SELECTED: Color = Color("8fb7a5")
const TEXT: Color = Color("e8e3d8")
const MUTED: Color = Color("9aa1ab")
const DISABLED: Color = Color("666b73")

@export var target_id: StringName = &""
@export var intent: StringName = &"interact"
@export var payload: Dictionary = {}
@export var base_text: String = ""
@export var selected: bool = false
@export var available: bool = true
@export var unavailable_reason: String = ""

var _state_label: Label
var _text_label: Label
var _focused: bool = false
var _hovered: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size.y = 44.0
	var row := HBoxContainer.new()
	row.name = "Row"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	add_child(row)
	_state_label = Label.new()
	_state_label.name = "State"
	_state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_state_label.custom_minimum_size.x = 104.0
	_state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_state_label.add_theme_font_size_override("font_size", 11)
	row.add_child(_state_label)
	_text_label = Label.new()
	_text_label.name = "Text"
	_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", 14)
	row.add_child(_text_label)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_sync()


func configure(
	new_target_id: StringName,
	new_text: String,
	new_intent: StringName = &"interact",
	new_payload: Dictionary = {},
	new_selected: bool = false,
	new_available: bool = true,
	new_unavailable_reason: String = ""
) -> void:
	target_id = new_target_id
	base_text = new_text
	intent = new_intent
	payload = new_payload.duplicate(true)
	selected = new_selected
	available = new_available
	unavailable_reason = new_unavailable_reason
	_sync()


func set_selected(value: bool) -> void:
	selected = value
	_sync()


func set_available(value: bool, reason: String = "") -> void:
	available = value
	unavailable_reason = reason
	_sync()


func _gui_input(event: InputEvent) -> void:
	if not available or not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	accept_event()
	grab_focus()
	activated.emit(intent, payload.duplicate(true))


func _on_focus_entered() -> void:
	_focused = true
	_sync()


func _on_focus_exited() -> void:
	_focused = false
	_sync()


func _on_mouse_entered() -> void:
	_hovered = true
	_sync()


func _on_mouse_exited() -> void:
	_hovered = false
	_sync()


func _sync() -> void:
	if _state_label == null or _text_label == null:
		return
	_text_label.text = base_text
	_text_label.add_theme_color_override("font_color", TEXT if available else DISABLED)
	_state_label.add_theme_color_override("font_color", _state_color())
	_state_label.text = _state_text()
	var border := BORDER
	var width := 1
	if available and selected:
		border = SELECTED
		width = 2
	if available and (_focused or _hovered):
		border = FOCUS
		width = 3
	add_theme_stylebox_override("panel", _style(FILL if not selected else SELECTED_FILL, border, width))
	mouse_filter = Control.MOUSE_FILTER_STOP if available else Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_ALL if available else Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if available else Control.CURSOR_ARROW
	tooltip_text = base_text if unavailable_reason.is_empty() else unavailable_reason


func _state_text() -> String:
	if not available:
		return "UNAVAILABLE"
	if selected and (_focused or _hovered):
		return "SELECTED / FOCUS"
	if selected:
		return "SELECTED"
	if _focused or _hovered:
		return "FOCUS"
	return ""


func _state_color() -> Color:
	if not available:
		return DISABLED
	if selected and (_focused or _hovered):
		return FOCUS
	if selected:
		return SELECTED
	if _focused or _hovered:
		return FOCUS
	return MUTED


func _style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(3)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 7.0
	return style
