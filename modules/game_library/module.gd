extends GameModule

const PAPER := Color("f4f4f4")
const INK := Color("363636")
const MUTED := Color("777777")
const CYAN := Color("00c6df")
const RED := Color("e60012")
const COVERS: Array[String] = ["d34b42", "244c72", "56816a", "765383", "c17949", "276e75", "9a5b51", "334362"]

var _buttons: Array[Button] = []
var _grid_buttons: Array[Button] = []
var _home: VBoxContainer
var _all: VBoxContainer
var _selection: Label
var _held_confirm: bool = false
var _held_cancel: bool = false
var _korean: bool = true


func enter(value: ModuleContext) -> void:
	super.enter(value)
	_korean = context.arrival.get("language", "ko") == "ko"
	_build()
	if not _buttons.is_empty():
		_buttons[0].grab_focus()


func _process(_delta: float) -> void:
	if context == null or not context.input_enabled:
		_held_confirm = false
		_held_cancel = false
		return
	var confirm: bool = context.is_action_pressed(&"game_library_confirm")
	var cancel: bool = context.is_action_pressed(&"game_library_cancel")
	if confirm and not _held_confirm:
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused is Button and is_ancestor_of(focused):
			(focused as Button).pressed.emit()
	if cancel and not _held_cancel:
		_back()
	_held_confirm = confirm
	_held_cancel = cancel


func _build() -> void:
	var canvas := Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(canvas)
	var background := ColorRect.new()
	background.color = PAPER
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(background)
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.offset_left = 48
	layout.offset_right = -48
	layout.offset_top = 30
	layout.offset_bottom = -22
	canvas.add_child(layout)
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 64
	layout.add_child(header)
	var avatar := _label(header, "●", 40, RED)
	var brand := _label(header, "  TIN", 23, INK)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var count: int = (context.arrival.get("games", []) as Array).size()
	_label(header, ("전체 %d개" if _korean else "%d games") % count, 17, MUTED)
	var space := Control.new()
	space.custom_minimum_size.x = 24
	header.add_child(space)
	_label(header, Time.get_time_string_from_system().substr(0, 5) + "   ◖▰", 18, INK)
	var body := Control.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(body)
	_home = VBoxContainer.new()
	_home.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.add_child(_home)
	_all = VBoxContainer.new()
	_all.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.add_child(_all)
	_all.hide()
	_build_home(count)
	_build_all(count)


func _build_home(count: int) -> void:
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_home.add_child(spacer)
	_label(_home, "HOME", 17, MUTED)
	var rail := ScrollContainer.new()
	rail.custom_minimum_size.y = 236
	rail.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rail.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rail.follow_focus = true
	_home.add_child(rail)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	rail.add_child(row)
	var games: Array = context.arrival.get("games", [])
	for index: int in range(games.size()):
		var game: Dictionary = games[index]
		var tile: Button = _cover(row, game, index, 218)
		tile.focus_entered.connect(_focus_game.bind(rail, tile, String(game.get("name", "")), String(game.get("id", "")), index, count))
		_buttons.append(tile)
	var all_tile := Button.new()
	all_tile.custom_minimum_size = Vector2(218, 218)
	all_tile.text = "▦\n\n모든 소프트웨어" if _korean else "▦\n\nAll Software"
	all_tile.add_theme_font_size_override("font_size", 22)
	all_tile.add_theme_color_override("font_color", INK)
	all_tile.add_theme_stylebox_override("normal", _box(Color("e1e1e1"), Color.TRANSPARENT, 0))
	all_tile.add_theme_stylebox_override("hover", _box(Color("d8d8d8"), CYAN, 3))
	all_tile.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, CYAN, 5))
	all_tile.focus_entered.connect(_focus_all.bind(rail, all_tile, count))
	all_tile.pressed.connect(_show_all)
	row.add_child(all_tile)
	_selection = _label(_home, "", 23, INK)
	_selection.custom_minimum_size.y = 42
	var middle := Control.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_home.add_child(middle)
	var dock := HBoxContainer.new()
	dock.alignment = BoxContainer.ALIGNMENT_CENTER
	dock.add_theme_constant_override("separation", 34)
	dock.custom_minimum_size.y = 90
	_home.add_child(dock)
	_dock_button(dock, "▦", "모든 소프트웨어" if _korean else "All Software", _show_all)
	_dock_button(dock, "▶", "현재 게임" if _korean else "Current game", _resume)
	_dock_button(dock, "⚙", "설정으로" if _korean else "Settings", _settings)
	_footer(_home, "방향키 이동     Z 선택     X / Esc 설정으로" if _korean else "Arrows move     Z select     X / Esc settings")


func _build_all(count: int) -> void:
	var title := HBoxContainer.new()
	title.custom_minimum_size.y = 56
	_all.add_child(title)
	var heading := _label(title, "모든 소프트웨어" if _korean else "All Software", 28, INK)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(title, "%02d" % count, 20, MUTED)
	var line := ColorRect.new()
	line.color = Color("d2d2d2")
	line.custom_minimum_size.y = 2
	_all.add_child(line)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	_all.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	scroll.add_child(grid)
	var games: Array = context.arrival.get("games", [])
	for index: int in range(games.size()):
		var game: Dictionary = games[index]
		var tile: Button = _cover(grid, game, index, 160)
		tile.focus_entered.connect(_ensure_visible.bind(scroll, tile))
		_grid_buttons.append(tile)
	_footer(_all, "방향키 이동     Z 선택     X 홈으로     Esc 설정으로" if _korean else "Arrows move     Z select     X home     Esc settings")


func _cover(parent: Control, game: Dictionary, index: int, size: int) -> Button:
	var id: String = String(game.get("id", ""))
	var name: String = String(game.get("name", id))
	var tile := Button.new()
	tile.custom_minimum_size = Vector2(size, size)
	tile.text = "TIN  /  %02d\n\n◆\n\n%s" % [index + 1, name]
	tile.add_theme_font_size_override("font_size", 20 if size > 200 else 15)
	tile.add_theme_color_override("font_color", Color.WHITE)
	tile.add_theme_color_override("font_hover_color", Color.WHITE)
	tile.add_theme_color_override("font_focus_color", Color.WHITE)
	var cover := Color(COVERS[index % COVERS.size()])
	tile.add_theme_stylebox_override("normal", _box(cover, Color.TRANSPARENT, 0))
	tile.add_theme_stylebox_override("hover", _box(cover, CYAN, 4))
	tile.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, CYAN, 5))
	tile.pressed.connect(_choose.bind(id))
	parent.add_child(tile)
	return tile


func _dock_button(parent: HBoxContainer, icon: String, caption: String, action: Callable) -> void:
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(column)
	var button := Button.new()
	button.text = icon
	button.custom_minimum_size = Vector2(58, 58)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 27)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _box(Color("5c5c5c"), Color.TRANSPARENT, 0, 36))
	button.add_theme_stylebox_override("hover", _box(Color("484848"), CYAN, 3, 36))
	button.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, CYAN, 4, 36))
	button.pressed.connect(action)
	column.add_child(button)
	var label := _label(column, caption, 14, MUTED)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _footer(parent: VBoxContainer, hint: String) -> void:
	var line := ColorRect.new()
	line.color = Color("d2d2d2")
	line.custom_minimum_size.y = 2
	parent.add_child(line)
	var bottom := HBoxContainer.new()
	bottom.custom_minimum_size.y = 40
	parent.add_child(bottom)
	var identity := _label(bottom, "TIN  ·  HOME", 15, MUTED)
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(bottom, hint, 15, INK)


func _label(parent: Node, value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _box(color: Color, border: Color, width: int, radius: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	return style


func _focus_game(rail: ScrollContainer, tile: Button, name: String, id: String, index: int, count: int) -> void:
	_ensure_visible(rail, tile)
	var current: bool = id == String(context.arrival.get("current", ""))
	_selection.text = "%s     %02d / %02d%s" % [name, index + 1, count, "     ▶ PLAYING" if current else ""]


func _focus_all(rail: ScrollContainer, tile: Button, count: int) -> void:
	_ensure_visible(rail, tile)
	_selection.text = ("모든 소프트웨어   ·   %d개" if _korean else "All Software   ·   %d games") % count


func _ensure_visible(scroll: ScrollContainer, tile: Button) -> void:
	scroll.ensure_control_visible.call_deferred(tile)


func _show_all() -> void:
	if context == null or not context.input_enabled:
		return
	_home.hide()
	_all.show()
	if not _grid_buttons.is_empty():
		_grid_buttons[0].grab_focus()


func _show_home() -> void:
	_all.hide()
	_home.show()
	if not _buttons.is_empty():
		_buttons[0].grab_focus()


func _resume() -> void:
	_choose(String(context.arrival.get("current", "")))


func _choose(id: String) -> void:
	if context != null and context.input_enabled:
		requested.emit(&"library_select", {"id": id})


func _settings() -> void:
	if context != null and context.input_enabled:
		requested.emit(&"library_back", {})


func _back() -> void:
	if _all.visible:
		_show_home()
	else:
		_settings()
