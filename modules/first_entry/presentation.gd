extends Control

signal shape_selected(index: int)
signal color_selected(index: int)
signal start_pressed()

const MIDNIGHT: Color = Color("10151f")
const INK: Color = Color("070a10")
const CREAM: Color = Color("efe8d7")
const MUTED: Color = Color("9299a6")
const ORANGE: Color = Color("ed9463")
const EDGE: Color = Color("303744")
const HAIR_COLORS: Array[Color] = [Color("de8657"), Color("ddd4bf"), Color("839baf")]

var _data: Dictionary = {}
var _phase: String = "keys"
var _elapsed: float = 0.0
var _phase_time: float = 0.0
var _bubble_states: Dictionary = {}
var _bubble_progress: Dictionary = {}
var _bubble_cells: Dictionary = {}
var _bubble_slots: Array[String] = []
var _binding_labels: Dictionary = {}
var _shape: int = 0
var _color: int = 0
var _english: bool = false
var _font: SystemFont
var _title_font: SystemFont
var _start: Button
var _shapes: Array[Button] = []
var _colors: Array[Button] = []
var _normal_style: StyleBoxFlat
var _selected_style: StyleBoxFlat
var _panel_style: StyleBoxFlat
var _margin: float = 40.0
var _narrow: bool = false
var _panel: Rect2
var _figure_center: Vector2
var _figure_scale: float = 1.0
var _shape_y: float = 0.0
var _color_y: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "Arial"])
	_title_font = SystemFont.new()
	_title_font.font_names = _font.font_names
	_title_font.font_weight = 700
	_normal_style = _style(Color("1a202c"), EDGE, 12)
	_selected_style = _style(Color("352c29"), ORANGE, 12)
	_panel_style = _style(Color("141a25"), EDGE, 20)
	_start = _button("StartButton", "부딪히기")
	_start.add_theme_stylebox_override("normal", _style(ORANGE, ORANGE, 14))
	_start.add_theme_stylebox_override("hover", _style(Color("ffad7d"), CREAM, 14))
	_start.add_theme_stylebox_override("pressed", _style(Color("c97045"), ORANGE, 14))
	_start.add_theme_color_override("font_color", INK)
	_start.add_theme_color_override("font_hover_color", INK)
	_start.add_theme_color_override("font_pressed_color", INK)
	_start.add_theme_font_override("font", _title_font)
	_start.pressed.connect(func() -> void: start_pressed.emit())
	for index: int in range(3):
		var shape_button: Button = _button("ShapeButton%d" % index, "")
		shape_button.pressed.connect(_emit_shape.bind(index))
		_shapes.append(shape_button)
		var color_button: Button = _button("ColorButton%d" % index, "")
		color_button.pressed.connect(_emit_color.bind(index))
		color_button.add_theme_color_override("font_color", HAIR_COLORS[index])
		color_button.add_theme_color_override("font_hover_color", HAIR_COLORS[index])
		_colors.append(color_button)
	get_viewport().size_changed.connect(_resize_view)
	_resize_view()
	update_view(_data)


func update_view(data: Dictionary) -> void:
	_data = data.duplicate(true)
	_phase = String(data.get("phase", "keys"))
	_elapsed = float(data.get("elapsed", 0.0))
	_phase_time = float(data.get("phase_time", 0.0))
	_shape = clampi(int(data.get("shape", 0)), 0, 2)
	_color = clampi(int(data.get("color", 0)), 0, 2)
	_english = String(data.get("language", "ko")) == "en"
	var states: Variant = data.get("bubble_states", {})
	_bubble_states = states.duplicate(true) if states is Dictionary else {}
	var progress: Variant = data.get("bubble_progress", {})
	_bubble_progress = progress.duplicate(true) if progress is Dictionary else {}
	var cells: Variant = data.get("bubble_cells", {})
	_bubble_cells = cells.duplicate(true) if cells is Dictionary else {}
	_bubble_slots.clear()
	var slots: Variant = data.get("bubble_slots", [])
	if slots is Array:
		for slot: Variant in slots:
			if slot is String or slot is StringName:
				_bubble_slots.append(String(slot))
	var labels: Variant = data.get("binding_labels", {})
	_binding_labels = labels.duplicate(true) if labels is Dictionary else {}
	if _start == null:
		return
	var enabled: bool = bool(data.get("enabled", false))
	var editing: bool = _phase == "editor"
	var show_editor: bool = _phase in ["editor", "entry", "collision"]
	_start.text = _tr("부딪히기", "COLLIDE")
	_start.visible = show_editor
	_start.disabled = not enabled or not editing
	var shape_names: Array[String] = [_tr("쇼트", "CROP"), _tr("단발", "BOB"), _tr("묶음", "TIED")]
	var color_names: Array[String] = [_tr("노을", "EMBER"), _tr("진주", "PEARL"), _tr("새벽", "SLATE")]
	for index: int in range(3):
		_shapes[index].visible = show_editor
		_colors[index].visible = show_editor
		_shapes[index].disabled = not enabled or not editing
		_colors[index].disabled = not enabled or not editing
		_shapes[index].text = shape_names[index]
		_colors[index].text = color_names[index]
		_shapes[index].add_theme_stylebox_override("normal", _selected_style if index == _shape else _normal_style)
		_colors[index].add_theme_stylebox_override("normal", _selected_style if index == _color else _normal_style)
		_shapes[index].tooltip_text = _tr("머리 모양: ", "Hair shape: ") + shape_names[index]
		_colors[index].tooltip_text = _tr("머리 색: ", "Hair color: ") + color_names[index]
	queue_redraw()


func _emit_shape(index: int) -> void:
	shape_selected.emit(index)


func _emit_color(index: int) -> void:
	color_selected.emit(index)


func _button(node_name: String, caption: String) -> Button:
	var button: Button = Button.new()
	button.name = node_name
	button.text = caption
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", CREAM)
	button.add_theme_color_override("font_pressed_color", CREAM)
	button.add_theme_color_override("font_disabled_color", Color("69717f"))
	button.add_theme_stylebox_override("normal", _normal_style)
	button.add_theme_stylebox_override("hover", _style(Color("2b303b"), MUTED, 12))
	button.add_theme_stylebox_override("pressed", _selected_style)
	button.add_theme_stylebox_override("disabled", _style(Color("151b25"), Color("252c36"), 12))
	add_child(button)
	return button


func _style(fill: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _resize_view() -> void:
	size = get_viewport_rect().size
	position = Vector2.ZERO
	_narrow = size.x < 760.0
	_margin = clampf(size.x * 0.045, 20.0, 64.0)
	_start.size = Vector2(164.0, 52.0)
	_start.position = Vector2(size.x - _margin - _start.size.x, size.y - 76.0)
	if _narrow:
		_panel = Rect2(_margin, size.y - 262.0, size.x - _margin * 2.0, 170.0)
		_figure_center = Vector2(size.x * 0.5, lerpf(170.0, _panel.position.y, 0.47))
		_figure_scale = clampf((_panel.position.y - 166.0) / 278.0, 0.32, 1.1)
	else:
		_panel = Rect2(_margin, maxf(252.0, size.y * 0.47), minf(360.0, size.x * 0.39), 184.0)
		_panel.position.y = minf(_panel.position.y, size.y - 280.0)
		_figure_center = Vector2(size.x * 0.70, size.y * 0.51)
		_figure_scale = clampf(size.y / 560.0, 0.65, 1.65)
	_shape_y = _panel.position.y + 39.0
	_color_y = _panel.position.y + 112.0
	var gap: float = 8.0
	var width: float = (_panel.size.x - 32.0 - gap * 2.0) / 3.0
	for index: int in range(3):
		_shapes[index].position = Vector2(_panel.position.x + 16.0 + index * (width + gap), _shape_y)
		_shapes[index].size = Vector2(width, 39.0)
		_colors[index].position = Vector2(_shapes[index].position.x, _color_y)
		_colors[index].size = Vector2(width, 39.0)
	queue_redraw()


func _draw() -> void:
	if _font == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), MIDNIGHT)
	_draw_stars()
	if _phase in ["keys", "zoom"]:
		_draw_intro()
	else:
		_draw_editor()
	_draw_header()
	if _phase == "collision":
		_draw_collision()


func _draw_stars() -> void:
	for index: int in range(76):
		var seed_value: float = float(index)
		var point: Vector2 = Vector2(fposmod(seed_value * 173.73 + 39.0, size.x), fposmod(seed_value * 97.37 + 23.0, size.y))
		var alpha: float = 0.14 + 0.20 * (0.5 + 0.5 * sin(_elapsed * 0.5 + seed_value))
		draw_circle(point, 1.3 if index % 9 == 0 else 0.7, Color(CREAM, alpha))
		if index % 19 == 0:
			draw_line(point - Vector2(4.0, 0.0), point + Vector2(4.0, 0.0), Color(CREAM, alpha), 1.0, true)
			draw_line(point - Vector2(0.0, 4.0), point + Vector2(0.0, 4.0), Color(CREAM, alpha), 1.0, true)


func _draw_header() -> void:
	if size.x > 440.0:
		_text(_tr("시작 이전의 이야기", "BEFORE THE BEGINNING"), Vector2(size.x * 0.5, 51.0), 11, MUTED, true)
	draw_line(Vector2(_margin, 86.0), Vector2(size.x - _margin, 86.0), Color(EDGE, 0.7), 1.0, true)


func _draw_intro() -> void:
	var zoom: float = clampf(_phase_time / 0.8, 0.0, 1.0) if _phase == "zoom" else 0.0
	var fade: float = 1.0 - smoothstep(0.0, 0.50, zoom)
	var title_size: int = 34 if _narrow else 52
	_text(_tr("모든 시작은, 낯선 곳에서.", "Every beginning is a leap."), Vector2(size.x * 0.5, 148.0), title_size, Color(CREAM, fade), true, true)
	var center: Vector2 = Vector2(size.x * 0.5, size.y * 0.5 + 40.0)
	_draw_bubble_grid(_bubble_grid_rect(), fade)
	if zoom > 0.0:
		var expansion: float = 1.0 + pow(zoom, 3.0) * 28.0
		var hole_radius: float = 31.0 * expansion
		draw_circle(center, hole_radius, Color(INK, 1.0 - zoom))
		draw_arc(center, hole_radius, 0.0, TAU, 100, Color(ORANGE, (1.0 - zoom) * 0.8), 2.0, true)


func _bubble_grid_rect() -> Rect2:
	var count: int = maxi(1, _bubble_slots.size())
	var rows: int = maxi(1, ceili(float(count) / 3.0))
	var gap: float = 12.0
	var available_width: float = maxf(size.x - _margin * 2.0, 180.0)
	var available_height: float = maxf(size.y - 250.0, 180.0)
	var cell_size: float = minf(104.0, minf((available_width - gap * 2.0) / 3.0, (available_height - gap * float(rows - 1)) / float(rows)))
	cell_size = maxf(44.0, cell_size)
	var grid_size: Vector2 = Vector2(cell_size * 3.0 + gap * 2.0, cell_size * float(rows) + gap * float(rows - 1))
	var origin: Vector2 = Vector2((size.x - grid_size.x) * 0.5, maxf(168.0, (size.y - grid_size.y) * 0.5 + 18.0))
	return Rect2(origin, grid_size)


func _draw_bubble_grid(grid: Rect2, opacity: float) -> void:
	if _bubble_slots.is_empty() or opacity <= 0.0:
		return
	var gap: float = 12.0
	var cell_size: float = (grid.size.x - gap * 2.0) / 3.0
	for index: int in range(_bubble_slots.size()):
		var key: String = _bubble_slots[index]
		var cell: Vector2i = _cell_position(_bubble_cells.get(key, [index % 3, index / 3]))
		cell.x = maxi(0, cell.x)
		cell.y = maxi(0, cell.y)
		var center: Vector2 = grid.position + Vector2(float(cell.x) * (cell_size + gap) + cell_size * 0.5, float(cell.y) * (cell_size + gap) + cell_size * 0.5)
		var cell_rect: Rect2 = Rect2(center - Vector2.ONE * cell_size * 0.5, Vector2.ONE * cell_size)
		draw_rect(cell_rect, Color(INK, 0.32 * opacity), true)
		draw_rect(cell_rect, Color(EDGE, 0.75 * opacity), false, 1.0)
		var state: String = String(_bubble_states.get(key, "popped"))
		if state == "popped":
			draw_arc(center, cell_size * 0.20, 0.0, TAU, 32, Color(ORANGE, 0.30 * opacity), 2.0, true)
			draw_line(center - Vector2(cell_size * 0.20, 0.0), center + Vector2(cell_size * 0.20, 0.0), Color(ORANGE, 0.20 * opacity), 1.0, true)
			draw_line(center - Vector2(0.0, cell_size * 0.20), center + Vector2(0.0, cell_size * 0.20), Color(ORANGE, 0.20 * opacity), 1.0, true)
			continue
		var progress: float = clampf(float(_bubble_progress.get(key, 0.0)), 0.0, 1.0)
		var point: Vector2 = center
		var scale_value: float = 1.0
		var alpha: float = opacity
		if state == "rising":
			point.y += (1.0 - progress) * cell_size * 0.85
			scale_value = 0.55 + progress * 0.45
			alpha *= 0.30 + progress * 0.70
		elif state == "restoring":
			scale_value = 0.45 + progress * 0.55
			alpha *= 0.20 + progress * 0.80
		draw_circle(point, cell_size * 0.37 * scale_value, Color(ORANGE, 0.12 * alpha))
		draw_circle(point, cell_size * 0.29 * scale_value, Color(CREAM, 0.08 * alpha))
		draw_arc(point, cell_size * 0.29 * scale_value, 0.0, TAU, 48, Color(ORANGE, 0.78 * alpha), 2.0, true)
		draw_circle(point - Vector2(cell_size * 0.10, cell_size * 0.11), cell_size * 0.045 * scale_value, Color(CREAM, 0.78 * alpha))
		var label: String = String(_binding_labels.get(key, key))
		_text(label, point + Vector2(0.0, 7.0), int(maxf(14.0, cell_size * 0.18)), Color(CREAM, alpha), true)


func _cell_position(value: Variant) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Array and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO


func _draw_editor() -> void:
	_draw_streaks()
	var entry: float = smoothstep(0.0, 0.6, _phase_time) if _phase == "entry" else 1.0
	var collision: float = clampf(_phase_time / 0.8, 0.0, 1.0) if _phase == "collision" else 0.0
	var center: Vector2 = _figure_center + Vector2(sin(_elapsed * 1.15) * 5.0, cos(_elapsed * 0.85) * 8.0)
	center.y -= (1.0 - entry) * size.y * 0.65
	var figure_scale: float = _figure_scale * (1.0 + collision * collision * 3.0)
	_draw_person(center, figure_scale, -0.19 + sin(_elapsed * 0.60) * 0.045)
	draw_style_box(_panel_style, _panel)
	_text(_tr("머리 모양", "HAIR SHAPE"), Vector2(_panel.position.x + 16.0, _shape_y - 12.0), 11, MUTED)
	_text(_tr("머리 색", "HAIR COLOR"), Vector2(_panel.position.x + 16.0, _color_y - 12.0), 11, MUTED)


func _draw_streaks() -> void:
	for index: int in range(42):
		var depth: float = 0.3 + float(index % 7) * 0.13
		var speed: float = 100.0 + depth * 120.0
		var point: Vector2 = Vector2(fposmod(index * 191.7 + _elapsed * speed * 0.48, size.x + 240.0) - 120.0, fposmod(index * 113.3 - _elapsed * speed, size.y + 240.0) - 120.0)
		var tail: Vector2 = Vector2(-0.48, 1.0) * (22.0 + depth * 72.0)
		draw_line(point, point + tail, Color(CREAM if index % 6 else ORANGE, 0.035 + depth * 0.075), 1.0, true)


func _draw_person(center: Vector2, scale_value: float, rotation_value: float) -> void:
	var hair: Color = HAIR_COLORS[_color]
	var cloth: Color = hair.darkened(0.58)
	var skin: Color = Color("e6c5ad")
	draw_set_transform(center, rotation_value, Vector2.ONE * scale_value)
	draw_arc(Vector2(0.0, 3.0), 149.0, -1.1, 1.0, 50, Color(ORANGE, 0.17), 1.0, true)
	draw_arc(Vector2(0.0, 3.0), 160.0, 2.0, 3.8, 50, Color(CREAM, 0.1), 1.0, true)
	if _shape == 2:
		draw_colored_polygon(PackedVector2Array([Vector2(9, -105), Vector2(30, -130), Vector2(49, -152), Vector2(37, -116), Vector2(43, -89), Vector2(20, -96)]), hair.darkened(0.12))
	elif _shape == 1:
		draw_colored_polygon(PackedVector2Array([Vector2(-19, -100), Vector2(17, -110), Vector2(27, -66), Vector2(10, -56), Vector2(-25, -69)]), hair.darkened(0.2))
	_limb(PackedVector2Array([Vector2(-15, 22), Vector2(-29, 70), Vector2(-18, 121)]), 17.0, cloth)
	_limb(PackedVector2Array([Vector2(13, 24), Vector2(36, 66), Vector2(57, 103)]), 16.0, cloth.lightened(0.09))
	_limb(PackedVector2Array([Vector2(-19, 120), Vector2(-4, 123)]), 12.0, CREAM.darkened(0.12))
	_limb(PackedVector2Array([Vector2(57, 102), Vector2(73, 98)]), 12.0, CREAM.darkened(0.12))
	_limb(PackedVector2Array([Vector2(-25, -55), Vector2(-45, -23), Vector2(-68, -42)]), 12.0, cloth.lightened(0.08))
	_limb(PackedVector2Array([Vector2(24, -54), Vector2(46, -78), Vector2(62, -61)]), 12.0, cloth)
	_limb(PackedVector2Array([Vector2(-69, -42), Vector2(-74, -50)]), 8.0, skin)
	_limb(PackedVector2Array([Vector2(62, -61), Vector2(65, -52)]), 8.0, skin)
	draw_colored_polygon(PackedVector2Array([Vector2(-14, -67), Vector2(-29, -55), Vector2(-25, -10), Vector2(-24, 32), Vector2(22, 35), Vector2(25, -17), Vector2(29, -54), Vector2(12, -67)]), cloth.lightened(0.08))
	draw_line(Vector2(0, -55), Vector2(0, 20), Color(hair, 0.40), 1.5, true)
	draw_line(Vector2(-21, 17), Vector2(21, 20), cloth.darkened(0.4), 3.0, true)
	draw_rect(Rect2(8, -38, 10, 12), Color(hair, 0.60))
	_limb(PackedVector2Array([Vector2(0, -77), Vector2(0, -62)]), 12.0, skin)
	draw_circle(Vector2(0, -94), 18.0, skin)
	draw_circle(Vector2(17, -92), 4.0, skin)
	match _shape:
		0:
			draw_colored_polygon(PackedVector2Array([Vector2(-18, -87), Vector2(-21, -103), Vector2(-10, -116), Vector2(9, -117), Vector2(21, -105), Vector2(17, -96), Vector2(8, -103), Vector2(-5, -99), Vector2(-12, -88)]), hair)
		1:
			draw_colored_polygon(PackedVector2Array([Vector2(-20, -73), Vector2(-22, -104), Vector2(-8, -116), Vector2(12, -112), Vector2(22, -102), Vector2(22, -74), Vector2(13, -82), Vector2(9, -101), Vector2(-9, -95), Vector2(-12, -75)]), hair)
		2:
			draw_colored_polygon(PackedVector2Array([Vector2(-18, -89), Vector2(-20, -106), Vector2(-7, -116), Vector2(9, -116), Vector2(20, -106), Vector2(20, -94), Vector2(8, -104), Vector2(-6, -101)]), hair)
			draw_circle(Vector2(15, -113), 10.0, hair)
			draw_arc(Vector2(15, -113), 9.0, -1.0, 1.5, 16, CREAM.darkened(0.25), 2.0, true)
	draw_line(Vector2(6, -91), Vector2(9, -91), INK, 1.5, true)
	draw_line(Vector2(5, -83), Vector2(10, -83), skin.darkened(0.25), 1.0, true)
	draw_set_transform(Vector2.ZERO)


func _limb(points: PackedVector2Array, width: float, tint: Color) -> void:
	draw_polyline(points, tint, width, true)
	for point: Vector2 in points:
		draw_circle(point, width * 0.5, tint)


func _draw_collision() -> void:
	var progress: float = clampf(_phase_time / 0.8, 0.0, 1.0)
	var center: Vector2 = _figure_center
	var radius: float = progress * size.length() * 0.8
	draw_arc(center, maxf(1.0, radius), 0.0, TAU, 128, Color(ORANGE, 1.0 - progress), 3.0 + 10.0 * progress, true)
	for index: int in range(18):
		var direction: Vector2 = Vector2.from_angle(float(index) * TAU / 18.0 + 0.2)
		draw_line(center + direction * radius * 0.7, center + direction * (radius + 45.0), Color(CREAM, sin(progress * PI) * 0.65), 2.0, true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(CREAM, smoothstep(0.4, 1.0, progress)))


func _tr(korean: String, english: String) -> String:
	return english if _english else korean


func _text(caption: String, point: Vector2, font_size: int, tint: Color, centered: bool = false, bold: bool = false) -> void:
	var font: Font = _title_font if bold else _font
	var available: float = size.x - _margin * 2.0
	var actual_size: int = font_size
	var width: float = font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1.0, actual_size).x
	if width > available:
		actual_size = maxi(10, int(float(font_size) * available / width))
		width = font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1.0, actual_size).x
	var origin: Vector2 = point - Vector2(width * 0.5, 0.0) if centered else point
	draw_string(font, origin, caption, HORIZONTAL_ALIGNMENT_LEFT, -1.0, actual_size, tint)
