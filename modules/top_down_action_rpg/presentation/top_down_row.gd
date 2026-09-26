class_name TopDownActionRpgRow
extends Control

signal row_activated(row_id: StringName)

const ROLE_CHOICE: String = "choice"
const ROLE_COMMAND: String = "command"
const ROLE_DOCUMENT: String = "document"
const ROLE_NARRATION: String = "narration"
const ROLE_AFFORDANCE: String = "affordance"

const AFFORDANCE_NONE: String = "none"
const AFFORDANCE_ADVANCE: String = "advance"
const AFFORDANCE_PORTRAIT: String = "portrait"

const CORRUPTION_MODES: Array[String] = ["recolor", "replace_token", "shatter_line", "drop_glyph"]
const FOCUSABLE_ROLES: Array[String] = [ROLE_CHOICE, ROLE_COMMAND]
const WRAPPING_ROLES: Array[String] = [ROLE_CHOICE]
const TEXT_INSET: float = 10.0
const FOCUSABLE_TEXT_INSET: float = 24.0
const CLASS_CHANNEL_INSET: float = 18.0
const ROW_TEXT_PAD: float = 4.0
const WRAP_VERTICAL_PAD: float = 12.0
const TRAILING_FONT_SIZE: int = 12

const CLASS_EXTREME: String = "extreme"
const CLASS_RESULT: String = "result"
const CLASS_OFFICIAL: String = "official"
const CLASS_CONFIDENTIAL: String = "confidential"
const CLASS_HOSTILE: String = "hostile"
const CLASS_NARRATION: String = "narration"

const FILL: Color = Color("0f1319")
const FILL_FOCUS: Color = Color("212a35")
const FILL_DISABLED: Color = Color("0b0e12")
const LINE: Color = Color("39424f")
const LINE_FOCUS: Color = Color("dcd8ce")
const FOCUS_MARK: Color = Color("e8e4da")
const INK: Color = Color("d6d2c7")
const INK_MUTED: Color = Color("9aa1aa")
const INK_DISABLED: Color = Color("6a717a")
const EXTREME: Color = Color("b34c3c")
const RESULT: Color = Color("93a68f")
const STRUCTURE_LINE: float = 1.0
const FOCUS_LINE: float = 2.0
const RULE_THICKNESS: float = 2.0
const CORRUPT_RULE: float = 2.0
const TOKEN_GLYPH: float = 3.0

@export var row_id: StringName = &""
@export var role: String = ROLE_CHOICE
@export var focused: bool = false
@export var disabled: bool = false
@export var selected: bool = false
@export var presentation_class: String = "neutral"
@export var affordance: String = AFFORDANCE_NONE
@export var tone_serial: int = 0
@export var corruption_mode: String = ""
@export var corruption_serial: int = 0
@export var corruption_severity: int = 0

var _text_label: Label = null
var _trailing_label: Label = null
var _label_offset: float = 0.0


func _ready() -> void:
	clip_contents = true
	_text_label = get_node_or_null("Text") as Label
	_trailing_label = get_node_or_null("Trailing") as Label
	if _text_label == null:
		_text_label = Label.new()
		_text_label.name = "Text"
		add_child(_text_label)
		_text_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _trailing_label == null:
		_trailing_label = Label.new()
		_trailing_label.name = "Trailing"
		add_child(_trailing_label)
		_trailing_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_trailing_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_trailing_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_trailing_label.add_theme_font_size_override("font_size", TRAILING_FONT_SIZE)
	_text_label.minimum_size_changed.connect(update_minimum_size)
	_trailing_label.minimum_size_changed.connect(update_minimum_size)
	_sync()


func _get_minimum_size() -> Vector2:
	if _text_label == null or not WRAPPING_ROLES.has(role) or _text_label.size.x <= 1.0:
		return Vector2.ZERO
	var height: float = _text_label.get_minimum_size().y
	if _trailing_label != null and not _trailing_label.text.is_empty():
		height += _trailing_label.get_minimum_size().y + ROW_TEXT_PAD * 2.0
	else:
		height += WRAP_VERTICAL_PAD * 2.0
	return Vector2(0.0, ceilf(height))


func configure(p_row_id: StringName, p_role: String) -> void:
	row_id = p_row_id
	role = p_role
	_sync()


func set_text(value: String) -> void:
	if _text_label == null:
		return
	_text_label.text = value
	queue_redraw()


func text() -> String:
	return _text_label.text if _text_label != null else ""


func trailing() -> String:
	return _trailing_label.text if _trailing_label != null else ""


func set_trailing(value: String) -> void:
	if _trailing_label == null:
		return
	_trailing_label.text = value
	_sync()


func set_focus_state(p_focused: bool) -> void:
	if focused == p_focused:
		return
	focused = p_focused
	_sync()


func set_disabled_state(p_disabled: bool) -> void:
	if disabled == p_disabled:
		return
	disabled = p_disabled
	_sync()


func set_presentation_class(value: String) -> void:
	if presentation_class == value:
		return
	presentation_class = value
	_sync()


func set_selected_state(value: bool) -> void:
	if selected == value:
		return
	selected = value
	_sync()


func set_affordance(value: String) -> void:
	if affordance == value:
		return
	affordance = value
	_sync()


func set_tone_serial(value: int) -> void:
	if tone_serial == value:
		return
	tone_serial = value
	_sync()


func set_corruption(mode: String, serial: int, severity: int) -> void:
	if corruption_mode == mode and corruption_serial == serial and corruption_severity == severity:
		return
	corruption_mode = mode if CORRUPTION_MODES.has(mode) else ""
	corruption_serial = serial
	corruption_severity = severity
	_sync()


func _stable_hash(text: String) -> int:
	var value: int = 2166136261
	for index: int in range(text.length()):
		value = (value ^ text.unicode_at(index)) & 0xFFFFFFFF
		value = (value * 16777619) & 0xFFFFFFFF
	return value


func _gui_input(event: InputEvent) -> void:
	if disabled or not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	accept_event()
	row_activated.emit(row_id)


func _sync() -> void:
	if _text_label == null:
		return
	var body: Color = FILL
	if disabled:
		body = FILL_DISABLED
	elif focused:
		body = FILL_FOCUS
	elif selected:
		body = Color("161d26")
	_label_offset = _corruption_offset()
	var left_inset: float = FOCUSABLE_TEXT_INSET if FOCUSABLE_ROLES.has(role) else TEXT_INSET
	var right_inset: float = CLASS_CHANNEL_INSET if FOCUSABLE_ROLES.has(role) else TEXT_INSET
	_text_label.offset_left = left_inset + _label_offset
	_text_label.offset_right = -right_inset + _label_offset
	_text_label.add_theme_color_override("font_color", INK_DISABLED if disabled else INK)
	var wraps: bool = WRAPPING_ROLES.has(role)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wraps else TextServer.AUTOWRAP_OFF
	var has_trailing: bool = _trailing_label != null and not _trailing_label.text.is_empty()
	_text_label.offset_top = ROW_TEXT_PAD if has_trailing else 0.0
	_text_label.offset_bottom = 0.0
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP if has_trailing else VERTICAL_ALIGNMENT_CENTER
	if _trailing_label != null:
		_trailing_label.offset_left = left_inset + _label_offset
		_trailing_label.offset_right = -right_inset + _label_offset
		_trailing_label.offset_top = 0.0
		_trailing_label.offset_bottom = -ROW_TEXT_PAD
		_trailing_label.add_theme_color_override("font_color", INK_DISABLED if disabled else INK_MUTED)
	var interactive: bool = affordance == AFFORDANCE_NONE and not disabled
	mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	update_minimum_size()
	queue_redraw()


func _corruption_offset() -> float:
	match corruption_mode:
		"replace_token":
			return 4.0 if corruption_serial % 2 == 0 else -4.0
		"shatter_line":
			return 12.0
		"recolor":
			return 3.0
		_:
			return 0.0


func _draw() -> void:
	if affordance == AFFORDANCE_ADVANCE:
		_draw_advance()
		return
	if affordance == AFFORDANCE_PORTRAIT:
		_draw_portrait()
		return
	var bounds: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(bounds, FILL_DISABLED if disabled else (FILL_FOCUS if focused else (Color("161d26") if selected else FILL)), true)
	var outline: Color = LINE_FOCUS if focused else LINE
	draw_rect(bounds, outline, false, FOCUS_LINE if focused else STRUCTURE_LINE)
	_draw_class_channel(bounds)
	if focused:
		_draw_focus_channel(bounds)
	if disabled:
		draw_line(bounds.position + Vector2(6.0, bounds.size.y * 0.5), bounds.position + Vector2(bounds.size.x - 6.0, bounds.size.y * 0.5), INK_DISABLED, STRUCTURE_LINE, true)
	_draw_corruption(bounds)


func _draw_class_channel(bounds: Rect2) -> void:
	match presentation_class:
		CLASS_EXTREME:
			draw_rect(Rect2(bounds.position + Vector2(bounds.size.x - 4.0, 2.0), Vector2(2.0, bounds.size.y - 4.0)), EXTREME, true)
			_draw_corner_tick(bounds, EXTREME)
		CLASS_RESULT:
			draw_line(bounds.position + Vector2(bounds.size.x - 14.0, 4.0), bounds.position + Vector2(bounds.size.x - 4.0, 4.0), RESULT, RULE_THICKNESS, true)
			draw_line(bounds.position + Vector2(bounds.size.x - 14.0, 4.0), bounds.position + Vector2(bounds.size.x - 4.0, bounds.size.y - 4.0), RESULT, STRUCTURE_LINE, true)
		CLASS_OFFICIAL:
			draw_rect(Rect2(bounds.position + Vector2(bounds.size.x - 12.0, 6.0), Vector2(6.0, 6.0)), INK_MUTED, false, STRUCTURE_LINE)
		CLASS_CONFIDENTIAL:
			draw_rect(Rect2(bounds.position + Vector2(bounds.size.x - 12.0, 6.0), Vector2(6.0, 6.0)), INK_MUTED, true)
		CLASS_HOSTILE:
			draw_polyline(PackedVector2Array([bounds.position + Vector2(bounds.size.x - 12.0, bounds.size.y - 6.0), bounds.position + Vector2(bounds.size.x - 6.0, 6.0), bounds.position + Vector2(bounds.size.x - 2.0, bounds.size.y - 6.0)]), INK_MUTED, STRUCTURE_LINE, true)
		CLASS_NARRATION:
			draw_arc(bounds.position + Vector2(bounds.size.x - 9.0, bounds.size.y * 0.5), 4.0, 0.0, TAU, 14, INK_MUTED, STRUCTURE_LINE, true)


func _draw_corner_tick(bounds: Rect2, color: Color) -> void:
	draw_line(bounds.position + Vector2(4.0, 4.0), bounds.position + Vector2(14.0, 4.0), color, STRUCTURE_LINE, true)
	draw_line(bounds.position + Vector2(4.0, 4.0), bounds.position + Vector2(4.0, 14.0), color, STRUCTURE_LINE, true)


func _draw_focus_channel(bounds: Rect2) -> void:
	var tip: Vector2 = bounds.position + Vector2(5.0, bounds.size.y * 0.5)
	draw_colored_polygon(PackedVector2Array([tip + Vector2(0.0, -6.0), tip + Vector2(7.0, 0.0), tip + Vector2(0.0, 6.0)]), FOCUS_MARK)
	draw_line(bounds.position + Vector2(16.0, 2.0), bounds.position + Vector2(16.0, bounds.size.y - 2.0), FOCUS_MARK, STRUCTURE_LINE, true)
	var corner: Vector2 = bounds.position + Vector2(bounds.size.x, bounds.size.y)
	draw_arc(corner, 10.0, PI, PI * 1.5, 14, FOCUS_MARK, FOCUS_LINE, true)


func _draw_advance() -> void:
	var center: Vector2 = size * 0.5
	var half: float = minf(size.x, size.y) * 0.36
	draw_colored_polygon(PackedVector2Array([center + Vector2(-half, -half * 0.6), center + Vector2(half, -half * 0.6), center + Vector2(0.0, half)]), FOCUS_MARK)
	draw_polyline(PackedVector2Array([center + Vector2(-half, -half * 0.6), center + Vector2(half, -half * 0.6), center + Vector2(0.0, half), center + Vector2(-half, -half * 0.6)]), LINE, STRUCTURE_LINE, true)


func _draw_portrait() -> void:
	var bounds: Rect2 = Rect2(Vector2.ZERO, size).grow(-1.0)
	draw_rect(bounds, FILL, true)
	draw_rect(bounds, LINE, false, STRUCTURE_LINE)
	var tone: float = float((_stable_hash(str(tone_serial)) % 100)) / 100.0
	var mass: Color = Color(0.42 + 0.18 * tone, 0.44 + 0.14 * tone, 0.47 + 0.10 * tone, 1.0)
	var head_radius: float = minf(size.x, size.y) * 0.2
	var head: Vector2 = size * Vector2(0.5, 0.38)
	draw_circle(head, head_radius, mass)
	var shoulder: PackedVector2Array = PackedVector2Array([
		head + Vector2(-head_radius * 0.5, head_radius * 0.86),
		size * Vector2(0.16, 0.98),
		size * Vector2(0.84, 0.98),
		head + Vector2(head_radius * 0.5, head_radius * 0.86),
	])
	draw_colored_polygon(shoulder, mass)
	draw_line(head + Vector2(-head_radius * 0.7, head_radius * 0.5), head + Vector2(head_radius * 0.8, head_radius * 0.2), Color(0.06, 0.08, 0.1, 0.85), STRUCTURE_LINE, true)
	draw_line(size * Vector2(0.06, 0.62), size * Vector2(0.94, 0.62), FILL, STRUCTURE_LINE, true)
	var tick: float = 4.0
	draw_line(bounds.position, bounds.position + Vector2(tick * 2.0, 0.0), INK_MUTED, STRUCTURE_LINE, true)
	draw_line(bounds.position, bounds.position + Vector2(0.0, tick * 2.0), INK_MUTED, STRUCTURE_LINE, true)
	var end: Vector2 = bounds.position + bounds.size
	draw_line(end, end - Vector2(tick * 2.0, 0.0), INK_MUTED, STRUCTURE_LINE, true)
	draw_line(end, end - Vector2(0.0, tick * 2.0), INK_MUTED, STRUCTURE_LINE, true)

func _draw_corruption(bounds: Rect2) -> void:
	if corruption_mode.is_empty():
		return
	var rule_y: float = bounds.size.y - 6.0
	var span_start: float = 6.0 + float(corruption_serial % 5) * 12.0
	match corruption_mode:
		"recolor":
			draw_rect(Rect2(Vector2(span_start, rule_y), Vector2(minf(72.0, bounds.size.x - span_start - 6.0), CORRUPT_RULE)), EXTREME, true)
		"replace_token":
			var offset_x: float = span_start
			draw_line(Vector2(offset_x, 4.0), Vector2(offset_x, bounds.size.y - 4.0), INK_MUTED, STRUCTURE_LINE, true)
			draw_rect(Rect2(Vector2(offset_x + 2.0, bounds.size.y * 0.5 - TOKEN_GLYPH), Vector2(TOKEN_GLYPH * 2.0, TOKEN_GLYPH * 2.0)), FILL, true)
			draw_rect(Rect2(Vector2(offset_x + 2.0, bounds.size.y * 0.5 - TOKEN_GLYPH), Vector2(TOKEN_GLYPH * 2.0, TOKEN_GLYPH * 2.0)), INK_MUTED, false, STRUCTURE_LINE)
		"shatter_line":
			draw_polyline(PackedVector2Array([
				Vector2(2.0, rule_y),
				Vector2(bounds.size.x * 0.22, rule_y - 4.0),
				Vector2(bounds.size.x * 0.38, rule_y + 3.0),
				Vector2(bounds.size.x * 0.5, rule_y - 2.0),
			]), INK_MUTED, STRUCTURE_LINE, true)
		"drop_glyph":
			for index: int in range(2):
				var gap_x: float = span_start + float(index) * 26.0
				draw_line(Vector2(gap_x, 5.0), Vector2(gap_x, bounds.size.y - 5.0), INK_MUTED, STRUCTURE_LINE, true)
	if corruption_severity >= 2:
		draw_line(bounds.position + Vector2(2.0, 3.0), bounds.position + Vector2(minf(20.0, bounds.size.x * 0.2), 3.0), EXTREME, STRUCTURE_LINE, true)
