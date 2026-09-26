class_name DeductionContextualDrawer
extends PanelContainer

signal intent_requested(intent: StringName, payload: Dictionary)

const FocusItem = preload("res://modules/deduction_casework/presentation/focusable_case_control.gd")
const FILL: Color = Color("11151c")
const BORDER: Color = Color("707783")
const MUTED: Color = Color("a2a7af")

@onready var _title_label: Label = get_node_or_null("%DrawerTitle")
@onready var _status_label: Label = get_node_or_null("%DrawerStatus")
@onready var _phrase_list: VBoxContainer = get_node_or_null("%PhraseList")
@onready var _slot_grid: GridContainer = get_node_or_null("%SlotGrid")
@onready var _submit_button: Control = get_node_or_null("%SubmitButton")
@onready var _close_button: Control = get_node_or_null("%CloseButton")

var _panel_id: StringName = &""
var _focus_items: Array[Control] = []
var _footer_connected: bool = false


func _ready() -> void:
	add_theme_stylebox_override("panel", _style())
	_configure_footer()
	visible = false


func open(
	panel_id: StringName,
	title_value: String,
	status_value: String,
	phrases: Array,
	slots: Array,
	focus_id: StringName = &"",
	selected_entity_id: StringName = &""
) -> void:
	if not is_node_ready():
		return
	_panel_id = panel_id
	_clear_dynamic_items()
	if _title_label != null:
		_title_label.text = title_value if not title_value.is_empty() else "SOLVER"
	if _status_label != null:
		_status_label.text = _status_text(status_value)
	for value: Variant in phrases:
		if value is Dictionary:
			_add_phrase(value as Dictionary, focus_id)
	for value: Variant in slots:
		if value is Dictionary:
			_add_slot(value as Dictionary, selected_entity_id, focus_id)
	if _phrase_list != null and _phrase_list.get_child_count() == 0:
		_add_empty(_phrase_list, "NO DISCOVERED PHRASES")
	if _slot_grid != null and _slot_grid.get_child_count() == 0:
		_add_empty(_slot_grid, "NO SOLVER SLOTS")
	_configure_footer()
	visible = true
	focus_first.call_deferred()


func close() -> void:
	_clear_dynamic_items()
	visible = false


func is_drawer_open() -> bool:
	return visible


func focus_first() -> void:
	if not visible:
		return
	for item: Control in _focus_items:
		if item.focus_mode == Control.FOCUS_ALL and item.is_visible_in_tree():
			item.grab_focus()
			return


func _configure_footer() -> void:
	if _submit_button == null or _close_button == null:
		return
	_submit_button.call(
		"configure",
		&"submit_panel",
		"SUBMIT",
		&"submit_panel",
		{"panel_id": String(_panel_id)},
		false,
		not _panel_id.is_empty(),
		"No panel is open"
	)
	_close_button.call("configure", &"close", "CLOSE", &"cancel", {}, false, true, "")
	if not _footer_connected:
		_submit_button.connect(&"activated", _on_item_activated)
		_close_button.connect(&"activated", _on_item_activated)
		_footer_connected = true
		_focus_items.append(_submit_button)
		_focus_items.append(_close_button)


func _add_phrase(data: Dictionary, focus_id: StringName) -> void:
	if _phrase_list == null:
		return
	var item := _new_item()
	var target_id := _id(data.get("id", ""))
	var text_value := String(data.get("text", target_id))
	var selected := target_id == _id(data.get("selected_entity_id", ""))
	var intent := StringName(String(data.get("intent", "interact")))
	var payload: Dictionary = data.get("payload", {"target_id": String(target_id)})
	if not payload is Dictionary:
		payload = {"target_id": String(target_id)}
	_phrase_list.add_child(item)
	item.call(
		"configure", target_id, text_value, intent, payload, selected,
		bool(data.get("available", true)), String(data.get("unavailable_reason", ""))
	)
	_set_focus(item, focus_id)


func _add_slot(data: Dictionary, selected_entity_id: StringName, focus_id: StringName) -> void:
	if _slot_grid == null:
		return
	var item := _new_item()
	var target_id := _id(data.get("id", ""))
	var slot_text := String(data.get("text", target_id))
	var entity_text := String(data.get("entity_text", ""))
	var text_value := slot_text if entity_text.is_empty() else "%s\n%s" % [slot_text, entity_text]
	var entity_id := _id(data.get("entity_id", ""))
	var selected := not entity_id.is_empty() and entity_id == selected_entity_id
	var payload: Dictionary = data.get("payload", {
		"panel_id": String(_panel_id),
		"slot_id": String(target_id),
		"entity_id": String(selected_entity_id)
	})
	if not payload is Dictionary:
		payload = {"panel_id": String(_panel_id), "slot_id": String(target_id)}
	_slot_grid.add_child(item)
	item.call(
		"configure", target_id, text_value, StringName(String(data.get("intent", "assign"))),
		payload, selected, bool(data.get("available", true)), String(data.get("unavailable_reason", ""))
	)
	_set_focus(item, focus_id)


func _new_item() -> Control:
	var item: Control = FocusItem.new()
	item.custom_minimum_size.y = 48.0
	_focus_items.append(item)
	item.connect(&"activated", _on_item_activated)
	return item


func _set_focus(item: Control, focus_id: StringName) -> void:
	if _id(item.get("target_id")) == focus_id:
		item.call_deferred("grab_focus")


func _add_empty(parent: Control, text_value: String) -> void:
	var label := Label.new()
	label.text = text_value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", MUTED)
	label.add_theme_font_size_override("font_size", 12)
	parent.add_child(label)


func _clear_dynamic_items() -> void:
	var retained: Array[Control] = []
	for item: Control in _focus_items:
		if item == _submit_button or item == _close_button:
			retained.append(item)
		elif is_instance_valid(item):
			if item.get_parent() != null:
				item.get_parent().remove_child(item)
			item.queue_free()
	_focus_items = retained
	if _phrase_list != null:
		for child: Node in _phrase_list.get_children():
			_phrase_list.remove_child(child)
			child.queue_free()
	if _slot_grid != null:
		for child: Node in _slot_grid.get_children():
			_slot_grid.remove_child(child)
			child.queue_free()


func _on_item_activated(intent: StringName, payload: Dictionary) -> void:
	intent_requested.emit(intent, payload.duplicate(true))


func _id(value: Variant) -> StringName:
	return StringName(String(value)) if value is String or value is StringName else &""


func _status_text(value: String) -> String:
	match value.to_lower():
		"undiscovered":
			return "UNDISCOVERED"
		"not_filled":
			return "NOT FILLED"
		"almost":
			return "ALMOST"
		"solved":
			return "SOLVED"
		"unsolved":
			return "UNSOLVED"
	return value.to_upper()


func _style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = FILL
	style.border_color = BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style
