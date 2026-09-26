class_name DeductionAuthoredCaseScene
extends Control

signal intent_requested(intent: StringName, payload: Dictionary)

const KIND_TARGET: StringName = &"target"
const KIND_EXIT: StringName = &"exit"
const INTENT_INTERACT: StringName = &"interact"

const STAGE_FILL: Color = Color("0d1016")
const STAGE_BORDER: Color = Color("4a5058")
const BAND_FILL: Color = Color("2b1c1c")
const BAND_BORDER: Color = Color("d58f84")
const BOX_FILL: Color = Color("191d25")
const BOX_SELECTED_FILL: Color = Color("25242a")
const BOX_BORDER: Color = Color("5b6270")
const BOX_DISABLED_FILL: Color = Color("121419")
const BOX_DISABLED_BORDER: Color = Color("3a3d45")
const TEXT: Color = Color("e8e3d8")
const MUTED: Color = Color("9aa1ab")
const FOCUS: Color = Color("d6b56c")
const SELECTED: Color = Color("8fb7a5")
const ERROR: Color = Color("d58f84")

@onready var _stage_panel: PanelContainer = get_node_or_null("%StagePanel")
@onready var _stage_index: Label = get_node_or_null("%StageIndex")
@onready var _surface_state: Label = get_node_or_null("%SurfaceState")
@onready var _reject_band: PanelContainer = get_node_or_null("%RejectBand")
@onready var _target_heading: Label = get_node_or_null("%TargetHeading")
@onready var _target_scroll: ScrollContainer = get_node_or_null("%TargetScroll")
@onready var _target_grid: GridContainer = get_node_or_null("%TargetGrid")
@onready var _exit_heading: Label = get_node_or_null("%ExitHeading")
@onready var _exit_scroll: ScrollContainer = get_node_or_null("%ExitScroll")
@onready var _exit_grid: GridContainer = get_node_or_null("%ExitGrid")
@onready var _empty_state: Label = get_node_or_null("%EmptyState")

var _snapshot: Dictionary = {}
var _content: Dictionary = {}
var _stage_key: String = ""
var _boxes: Array[Control] = []
var _rejected: bool = false


func _ready() -> void:
	_apply_styles()
	_sync()


func apply_snapshot(snapshot: Dictionary, content: Variant = null) -> void:
	_snapshot = snapshot.duplicate(true)
	if content is Dictionary:
		_content = (content as Dictionary).duplicate(true)
	_sync()


func present_reaction(rejected: bool) -> void:
	_rejected = rejected
	_update_bar()


func _sync() -> void:
	var key := "%s|%s" % [
		String(_snapshot.get("scene_id", "")),
		String(_snapshot.get("surface_id", ""))
	]
	if key != _stage_key:
		_stage_key = key
		_rebuild()
	_update_bar()
	_update_boxes()


func _rebuild() -> void:
	_clear_boxes()
	if _target_grid != null:
		for value: Variant in _array(_hotspot_entries()):
			var entry := _dictionary(value)
			_add_box(KIND_TARGET, _id(entry.get("id", "")), _id(entry.get("focus_id", "")), _target_grid)
	if _exit_grid != null:
		for value: Variant in _array(_dictionary(_scene_entry()).get("transitions", [])):
			var entry := _dictionary(value)
			_add_box(KIND_EXIT, _id(entry.get("id", "")), &"", _exit_grid)
	var has_targets := _target_grid != null and _target_grid.get_child_count() > 0
	var has_exits := _exit_grid != null and _exit_grid.get_child_count() > 0
	if _target_heading != null:
		_target_heading.visible = has_targets
	if _target_scroll != null:
		_target_scroll.visible = has_targets
	if _exit_heading != null:
		_exit_heading.visible = has_exits
	if _exit_scroll != null:
		_exit_scroll.visible = has_exits
	if _empty_state != null:
		_empty_state.visible = not has_targets and not has_exits


func _add_box(kind: StringName, box_id: StringName, focus_target: StringName, grid: GridContainer) -> void:
	if box_id.is_empty():
		return
	var box := Control.new()
	box.custom_minimum_size = Vector2(160.0, 96.0)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.focus_mode = Control.FOCUS_ALL
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	box.tooltip_text = String(box_id)
	box.set_meta(&"kind", kind)
	box.set_meta(&"box_id", box_id)
	box.set_meta(&"focus_target", focus_target)
	box.set_meta(&"order", _boxes.size())
	box.set_meta(&"enabled", true)
	box.set_meta(&"selected", false)
	box.set_meta(&"hovered", false)
	box.draw.connect(_draw_box.bind(box))
	box.gui_input.connect(_on_box_gui_input.bind(box))
	box.focus_entered.connect(_on_box_visual_changed.bind(box))
	box.focus_exited.connect(_on_box_visual_changed.bind(box))
	box.mouse_entered.connect(_on_box_hover_changed.bind(box, true))
	box.mouse_exited.connect(_on_box_hover_changed.bind(box, false))
	box.resized.connect(_on_box_visual_changed.bind(box))
	grid.add_child(box)
	_boxes.append(box)


func _update_bar() -> void:
	var scenes := _array(_content.get("scenes", []))
	if _stage_index != null:
		_stage_index.text = "STAGE %d/%d" % [_stage_position() + 1, maxi(1, scenes.size())]
	if _surface_state != null:
		_surface_state.text = _surface_label()
	if _reject_band != null:
		_reject_band.visible = _rejected or not String(_snapshot.get("feedback_reason", "")).is_empty()


func _update_boxes() -> void:
	var enabled := not _blocking()
	var focus_id := String(_snapshot.get("focus_id", ""))
	var selected := _selected_targets()
	var grabbed := false
	for box: Control in _boxes:
		var box_id := String(_meta_id(box, &"box_id"))
		var focus_target := _meta_id(box, &"focus_target")
		box.set_meta(&"enabled", enabled)
		box.set_meta(&"selected", not focus_target.is_empty() and selected.has(focus_target))
		box.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
		box.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
		box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
		if not enabled:
			box.set_meta(&"hovered", false)
		if enabled and not grabbed and box_id == focus_id \
			and box.is_inside_tree() and box.is_visible_in_tree():
			box.grab_focus()
			grabbed = true
		box.queue_redraw()


func _on_box_gui_input(event: InputEvent, box: Control) -> void:
	if not bool(box.get_meta(&"enabled", true)) or not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	accept_event()
	box.grab_focus()
	intent_requested.emit(INTENT_INTERACT, {"target_id": String(_meta_id(box, &"box_id"))})


func _on_box_hover_changed(box: Control, hovered: bool) -> void:
	box.set_meta(&"hovered", hovered)
	box.queue_redraw()


func _on_box_visual_changed(box: Control) -> void:
	box.queue_redraw()


func _draw_box(box: Control) -> void:
	var size := box.size
	if size.x < 8.0 or size.y < 8.0:
		return
	var enabled := bool(box.get_meta(&"enabled", true))
	var selected := bool(box.get_meta(&"selected", false))
	var hovered := bool(box.get_meta(&"hovered", false))
	var focused := box.has_focus()
	var order := int(box.get_meta(&"order", 0))
	var kind: StringName = box.get_meta(&"kind", KIND_TARGET)
	var rect := Rect2(Vector2.ZERO, size)
	var fill := BOX_FILL
	var ink := BOX_BORDER
	var width := 1.0
	if not enabled:
		fill = BOX_DISABLED_FILL
		ink = BOX_DISABLED_BORDER
	elif selected:
		fill = BOX_SELECTED_FILL
		ink = SELECTED
		width = 2.0
	if enabled and (focused or hovered):
		ink = FOCUS
		width = 3.0
	box.draw_rect(rect, fill, true)
	_draw_hatch(box, size, Color(ink.r, ink.g, ink.b, 0.22 if enabled else 0.1))
	box.draw_rect(rect, ink, false, width)
	_draw_marker(box, size, kind, ink)
	box.draw_string(
		_font(),
		Vector2(9.0, 22.0),
		str(order + 1),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		13,
		TEXT if enabled else MUTED
	)


func _draw_hatch(box: Control, size: Vector2, color: Color) -> void:
	var step := 14.0
	var offset := -size.y
	while offset < size.x:
		box.draw_line(Vector2(offset, size.y), Vector2(offset + size.y, 0.0), color, 1.0)
		offset += step


func _draw_marker(box: Control, size: Vector2, kind: StringName, color: Color) -> void:
	var origin := Vector2(size.x - 15.0, 9.0)
	if kind == KIND_EXIT:
		box.draw_line(origin, origin + Vector2(9.0, 6.0), color, 2.0)
		box.draw_line(origin + Vector2(9.0, 6.0), origin + Vector2(0.0, 12.0), color, 2.0)
	else:
		box.draw_rect(Rect2(origin, Vector2(9.0, 9.0)), color, true)


func _hotspot_entries() -> Array:
	var surface_id := _id(_snapshot.get("surface_id", ""))
	if not surface_id.is_empty():
		var closeup := _find_entry(_content.get("closeups", []), surface_id)
		if not closeup.is_empty():
			return _array(closeup.get("hotspots", []))
	return _array(_scene_entry().get("hotspots", []))


func _scene_entry() -> Dictionary:
	return _find_entry(_content.get("scenes", []), _id(_snapshot.get("scene_id", "")))


func _surface_id() -> StringName:
	return _id(_snapshot.get("surface_id", ""))


func _blocking() -> bool:
	var surface_id := _surface_id()
	return not surface_id.is_empty() and _find_entry(_content.get("closeups", []), surface_id).is_empty()


func _surface_label() -> String:
	var surface_id := _surface_id()
	if surface_id.is_empty():
		return "STAGE"
	if not _find_entry(_content.get("closeups", []), surface_id).is_empty():
		return "CLOSEUP"
	if not _find_entry(_content.get("messages", []), surface_id).is_empty():
		return "MESSAGE"
	if not _find_entry(_content.get("panels", []), surface_id).is_empty():
		return "PANEL"
	return "SURFACE"


func _stage_position() -> int:
	var scene_id := _id(_snapshot.get("scene_id", ""))
	var scenes := _array(_content.get("scenes", []))
	for index: int in range(scenes.size()):
		if String(_dictionary(scenes[index]).get("id", "")) == String(scene_id):
			return index
	return 0


func _selected_targets() -> Array[StringName]:
	var result: Array[StringName] = []
	var selected := _id(_snapshot.get("selected_entity_id", ""))
	var dragged := _id(_snapshot.get("dragged_entity_id", ""))
	if not selected.is_empty():
		result.append(selected)
	if not dragged.is_empty() and not result.has(dragged):
		result.append(dragged)
	return result


func _find_entry(entries: Variant, entry_id: StringName) -> Dictionary:
	if entry_id.is_empty():
		return {}
	for value: Variant in _array(entries):
		var entry := _dictionary(value)
		if String(entry.get("id", "")) == String(entry_id):
			return entry
	return {}


func _clear_boxes() -> void:
	for box: Control in _boxes:
		if is_instance_valid(box) and box.get_parent() != null:
			box.get_parent().remove_child(box)
		if is_instance_valid(box):
			box.queue_free()
	_boxes.clear()


func _meta_id(box: Control, key: StringName) -> StringName:
	return StringName(String(box.get_meta(key, "")))


func _font() -> Font:
	var font := get_theme_default_font()
	return font if font != null else ThemeDB.fallback_font


func _dictionary(value: Variant) -> Dictionary:
	return value as Dictionary if value is Dictionary else {}


func _array(value: Variant) -> Array:
	return value as Array if value is Array else []


func _id(value: Variant) -> StringName:
	return StringName(String(value)) if DeductionContentValidator.is_stable_id(value) else &""


func _apply_styles() -> void:
	if _stage_panel != null:
		_stage_panel.add_theme_stylebox_override("panel", _style(STAGE_FILL, STAGE_BORDER, 12.0, 8.0))
	if _reject_band != null:
		_reject_band.add_theme_stylebox_override("panel", _style(BAND_FILL, BAND_BORDER, 10.0, 4.0))
	if _stage_index != null:
		_stage_index.add_theme_color_override("font_color", TEXT)
		_stage_index.add_theme_font_size_override("font_size", 13)
	if _surface_state != null:
		_surface_state.add_theme_color_override("font_color", MUTED)
		_surface_state.add_theme_font_size_override("font_size", 12)
	for label: Variant in [_target_heading, _exit_heading]:
		if label is Label:
			(label as Label).add_theme_color_override("font_color", MUTED)
			(label as Label).add_theme_font_size_override("font_size", 12)
	if _empty_state != null:
		_empty_state.add_theme_color_override("font_color", MUTED)
		_empty_state.add_theme_font_size_override("font_size", 13)


func _style(fill: Color, border: Color, margin_x: float, margin_y: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = margin_x
	style.content_margin_right = margin_x
	style.content_margin_top = margin_y
	style.content_margin_bottom = margin_y
	return style
