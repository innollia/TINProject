extends Control

const Tuning = preload("res://modules/physics_puzzle_platformer/domain/tuning.gd")

var label: Label
var remaining: float = 0.0
var _duration: float = Tuning.INTRO_DURATION


func _ready() -> void:
	name = "LevelTitle"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	label = Label.new()
	label.name = "Name"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	add_child(label)
	visible = false
	resized.connect(_layout)
	_layout()


func show_name(level_name: String, ink: Color, duration: float) -> void:
	label.text = level_name
	label.add_theme_color_override("font_color", ink)
	_duration = maxf(duration, 0.01)
	remaining = _duration
	visible = not level_name.is_empty()
	modulate.a = 1.0
	_layout()


func hide_now() -> void:
	remaining = 0.0
	visible = false


func advance(delta: float) -> void:
	if not visible:
		return
	remaining -= delta
	modulate.a = clampf(remaining / (_duration * 0.35), 0.0, 1.0)
	if remaining <= 0.0:
		visible = false


func _layout() -> void:
	if label == null:
		return
	var height: float = size.y if size.y > 0.0 else Tuning.VIEW_H
	label.add_theme_font_size_override("font_size", maxi(int(height * 0.055), 12))
	label.position = Vector2(0.0, size.y * 0.30)
	label.size = Vector2(size.x, height * 0.12)
