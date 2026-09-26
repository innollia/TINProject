class_name DeductionCaseScreen
extends Control

signal intent_requested(intent: StringName, payload: Dictionary)

const FocusItem = preload("res://modules/deduction_casework/presentation/focusable_case_control.gd")
const FOUNDATION_FILL: Color = Color("11151c")
const FOUNDATION_BORDER: Color = Color("5e6570")
const SURFACE_FILL: Color = Color("151a22")
const SURFACE_BORDER: Color = Color("737a85")
const TEXT: Color = Color("e8e3d8")
const MUTED: Color = Color("a2a7af")
const FOCUS: Color = Color("d6b56c")
const SUCCESS: Color = Color("8fb7a5")
const ERROR: Color = Color("d58f84")

@export var auto_bind_parent_runtime: bool = true

@onready var _authored_world: Control = get_node_or_null("%AuthoredWorld")
@onready var _foundation_layer: CenterContainer = get_node_or_null("%FoundationLayer")
@onready var _foundation_panel: PanelContainer = get_node_or_null("%FoundationPanel")
@onready var _foundation_title: Label = get_node_or_null("%FoundationTitle")
@onready var _foundation_body: Label = get_node_or_null("%FoundationBody")
@onready var _drawer: DeductionContextualDrawer = get_node_or_null("%ContextualDrawer")
@onready var _detail_surface: PanelContainer = get_node_or_null("%DetailSurface")
@onready var _detail_kind: Label = get_node_or_null("%DetailKind")
@onready var _detail_title: Label = get_node_or_null("%DetailTitle")
@onready var _detail_body: RichTextLabel = get_node_or_null("%DetailBody")
@onready var _detail_actions: VBoxContainer = get_node_or_null("%DetailActions")
@onready var _detail_close: Control = get_node_or_null("%DetailClose")
@onready var _feedback_surface: PanelContainer = get_node_or_null("%FeedbackSurface")
@onready var _feedback_label: Label = get_node_or_null("%FeedbackLabel")

var _runtime: DeductionCaseRuntime = null
var _mounted_scene: Node = null
var _mounted_scene_id: StringName = &""
var _snapshot: Dictionary = {}
var _content: Dictionary = {}
var _detail_data: Dictionary = {}
var _detail_requested: bool = false
var _content_available: bool = false


func _ready() -> void:
	_apply_styles()
	if _drawer != null and not _drawer.intent_requested.is_connected(_on_drawer_intent):
		_drawer.intent_requested.connect(_on_drawer_intent)
	if _detail_close != null and not _detail_close.is_connected(&"activated", _on_detail_item_activated):
		_detail_close.connect(&"activated", _on_detail_item_activated)
	apply_snapshot({"content_available": false})
	if auto_bind_parent_runtime:
		_bind_parent_runtime()


func _exit_tree() -> void:
	unbind_runtime()


func bind_runtime(value: DeductionCaseRuntime) -> void:
	if _runtime == value:
		return
	unbind_runtime()
	_runtime = value
	if _runtime == null:
		apply_snapshot({"content_available": false})
		return
	_runtime.snapshot_changed.connect(apply_snapshot)
	_runtime.intent_resolved.connect(_on_runtime_intent)
	_runtime.case_solved.connect(_on_case_solved)
	_content = _runtime.definition.to_dict() if _runtime.definition != null else {}
	apply_snapshot(_runtime.snapshot())


func unbind_runtime() -> void:
	if not is_instance_valid(_runtime):
		_runtime = null
		return
	if _runtime.snapshot_changed.is_connected(apply_snapshot):
		_runtime.snapshot_changed.disconnect(apply_snapshot)
	if _runtime.intent_resolved.is_connected(_on_runtime_intent):
		_runtime.intent_resolved.disconnect(_on_runtime_intent)
	if _runtime.case_solved.is_connected(_on_case_solved):
		_runtime.case_solved.disconnect(_on_case_solved)
	_runtime = null


func apply_snapshot(snapshot: Dictionary, content: Variant = null) -> void:
	_snapshot = snapshot.duplicate(true)
	if content is Dictionary:
		_content = (content as Dictionary).duplicate(true)
	_content_available = bool(_snapshot.get("content_available", false))
	if not _content_available:
		_detail_requested = false
		_detail_data.clear()
		if _detail_surface != null:
			_detail_surface.hide()
		if _drawer != null:
			_drawer.close()
		unmount_authored_scene()
	else:
		_sync_authored_scene(String(_snapshot.get("scene_id", "")))
		if is_instance_valid(_mounted_scene) and _mounted_scene.has_method(&"apply_snapshot"):
			_mounted_scene.call(&"apply_snapshot", _snapshot, _content)
	_refresh_shell()
	_update_feedback()
	_update_drawer()
	_update_detail()


func mount_authored_scene(scene: Variant, state: Dictionary = {}) -> Node:
	var packed: PackedScene = null
	if scene is PackedScene:
		packed = scene as PackedScene
	elif scene is String or scene is StringName:
		var path := String(scene)
		if ResourceLoader.exists(path, "PackedScene"):
			packed = ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	if packed == null:
		show_feedback("AUTHORED SCENE UNAVAILABLE", &"error")
		return null
	_clear_mounted_scene()
	var instance := packed.instantiate()
	if not instance is Node:
		show_feedback("AUTHORED SCENE UNAVAILABLE", &"error")
		return null
	_mounted_scene = instance
	if _authored_world == null:
		show_feedback("AUTHORED SCENE HOST UNAVAILABLE", &"error")
		_clear_mounted_scene()
		return null
	_authored_world.add_child(_mounted_scene)
	if _mounted_scene.has_signal(&"intent_requested") \
		and not _mounted_scene.is_connected(&"intent_requested", _on_authored_intent):
		_mounted_scene.connect(&"intent_requested", _on_authored_intent)
	if _mounted_scene is Control:
		var control := _mounted_scene as Control
		control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		control.mouse_filter = Control.MOUSE_FILTER_PASS
	if _mounted_scene.has_method(&"apply_snapshot"):
		_mounted_scene.call(&"apply_snapshot", _snapshot, _content)
	elif _mounted_scene.has_method(&"present_snapshot"):
		_mounted_scene.call(&"present_snapshot", _snapshot)
	elif _mounted_scene.has_method(&"update_view"):
		_mounted_scene.call(&"update_view", _snapshot)
	if not state.is_empty():
		if _mounted_scene.has_method(&"restore_state"):
			_mounted_scene.call(&"restore_state", state.duplicate(true))
		elif _mounted_scene.has_method(&"set_state"):
			_mounted_scene.call(&"set_state", state.duplicate(true))
	_refresh_shell()
	return _mounted_scene


func unmount_authored_scene() -> void:
	_clear_mounted_scene()
	_mounted_scene_id = &""
	_refresh_shell()


func _clear_mounted_scene() -> void:
	if is_instance_valid(_mounted_scene):
		var viewport := get_viewport()
		var focus_owner := viewport.gui_get_focus_owner() as Control if viewport != null else null
		if focus_owner != null and _mounted_scene.is_ancestor_of(focus_owner):
			viewport.gui_release_focus()
		if _mounted_scene.is_connected(&"intent_requested", _on_authored_intent):
			_mounted_scene.disconnect(&"intent_requested", _on_authored_intent)
		if _mounted_scene.get_parent() != null:
			_mounted_scene.get_parent().remove_child(_mounted_scene)
		_mounted_scene.queue_free()
	_mounted_scene = null


func _sync_authored_scene(scene_id: String) -> void:
	var next_id := StringName(scene_id)
	if next_id == _mounted_scene_id:
		return
	_mounted_scene_id = next_id
	var path := _authored_scene_path(scene_id)
	if path.is_empty() or not ResourceLoader.exists(path, "PackedScene"):
		_clear_mounted_scene()
		return
	mount_authored_scene(path)


func _authored_scene_path(scene_id: String) -> String:
	if scene_id.is_empty():
		return ""
	for value: Variant in _array(_content.get("scenes", [])):
		var scene := _dictionary(value)
		if String(scene.get("id", "")) == scene_id:
			return String(scene.get("scene_path", ""))
	return ""


func present_detail(data: Dictionary) -> void:
	_detail_data = data.duplicate(true)
	_detail_requested = true
	_update_detail()


func hide_detail() -> void:
	_detail_requested = false
	_detail_data.clear()
	if _detail_surface != null:
		_detail_surface.hide()
	_clear_detail_actions()
	_update_drawer()


func show_feedback(text_value: String, kind: StringName = &"info") -> void:
	if _feedback_label == null or _feedback_surface == null:
		return
	_feedback_label.text = text_value
	_feedback_label.add_theme_color_override("font_color", _feedback_color(kind))
	_feedback_surface.add_theme_stylebox_override("panel", _style(SURFACE_FILL, _feedback_color(kind), 1, 3, 10.0))
	_feedback_surface.visible = not text_value.strip_edges().is_empty()


func hide_feedback() -> void:
	if _feedback_surface != null:
		_feedback_surface.hide()


func _bind_parent_runtime() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var value: Variant = parent.get("runtime")
	if value is DeductionCaseRuntime:
		bind_runtime(value as DeductionCaseRuntime)


func _refresh_shell() -> void:
	var has_world := _content_available and is_instance_valid(_mounted_scene)
	if _authored_world != null:
		_authored_world.visible = has_world
	if _foundation_layer != null:
		_foundation_layer.visible = not has_world
	if not has_world and _foundation_title != null and _foundation_body != null:
		_foundation_title.text = "FOUNDATION"
		_foundation_body.text = "AUTHORED CASE CONTENT IS NOT AVAILABLE." if not _content_available \
			else "AUTHORED SCENE IS NOT MOUNTED."


func _update_drawer() -> void:
	if _drawer == null or not _content_available or _detail_requested:
		if _drawer != null:
			_drawer.close()
		return
	var panel_id := StringName(String(_snapshot.get("surface_id", "")))
	var panels := _dictionary(_snapshot.get("panels", {}))
	var panel := _dictionary(panels.get(String(panel_id), {}))
	if panel.is_empty():
		_drawer.close()
		return
	var authored_panel := _entry_by_id(_content.get("panels", []), panel_id)
	var authored_slots: Dictionary = {}
	var segment_text: Dictionary = {}
	for value: Variant in _array(authored_panel.get("segments", [])):
		var segment := _dictionary(value)
		segment_text[String(segment.get("id", ""))] = String(segment.get("display_text", segment.get("id", "")))
	for value: Variant in _array(authored_panel.get("slots", [])):
		var slot := _dictionary(value)
		authored_slots[String(slot.get("id", ""))] = {
			"text": String(segment_text.get(String(slot.get("segment_id", "")), slot.get("segment_id", "")))
		}
	var selected_entity_id := StringName(String(_snapshot.get("selected_entity_id", "")))
	var phrases: Array = []
	for value: Variant in _array(_snapshot.get("discovered_entity_ids", [])):
		var entity_id := StringName(String(value))
		var entity := _entity_data(entity_id)
		phrases.append({
			"id": String(entity_id),
			"text": String(entity.get("display_text", entity.get("text", entity_id))),
			"selected_entity_id": String(selected_entity_id) if entity_id == selected_entity_id else "",
			"available": true
		})
	var slots: Array = []
	for value: Variant in _array(panel.get("slots", [])):
		var slot := _dictionary(value)
		var slot_id := StringName(String(slot.get("id", "")))
		var entity_id := StringName(String(slot.get("entity_id", "")))
		var slot_data := _dictionary(authored_slots.get(String(slot_id), {}))
		slots.append({
			"id": String(slot_id),
			"text": String(slot_data.get("text", slot_id)),
			"entity_id": String(entity_id),
			"entity_text": String(_entity_data(entity_id).get("display_text", entity_id)) if not entity_id.is_empty() else "",
			"available": true
		})
	_drawer.open(
		panel_id,
		String(authored_panel.get("title", panel_id)),
		String(panel.get("status", "")),
		phrases,
		slots,
		StringName(String(_snapshot.get("focus_id", ""))),
		selected_entity_id
	)


func _update_detail() -> void:
	if not _content_available:
		return
	var data := _detail_data
	if not _detail_requested:
		data = _surface_detail()
	if data.is_empty():
		if _detail_surface != null:
			_detail_surface.hide()
		_clear_detail_actions()
		return
	_render_detail(data)


func _surface_detail() -> Dictionary:
	var surface := _dictionary(_snapshot.get("surface", {}))
	if String(surface.get("kind", "")) == "message":
		var message := _message_data(String(surface.get("id", "")))
		return {
			"kind": "message",
			"title": String(message.get("title", surface.get("title", ""))),
			"body": String(message.get("body", surface.get("body", ""))),
			"focus_id": String(_snapshot.get("focus_id", ""))
		}
	var surfaces := _dictionary(_content.get("surfaces", {}))
	return _dictionary(surfaces.get(String(_snapshot.get("surface_id", "")), {}))


func _render_detail(data: Dictionary) -> void:
	if _drawer != null:
		_drawer.close()
	if _detail_kind != null:
		_detail_kind.text = String(data.get("kind", "DETAIL")).to_upper()
	if _detail_title != null:
		_detail_title.text = String(data.get("title", ""))
	if _detail_body != null:
		_detail_body.text = String(data.get("body", data.get("text", "")))
	_clear_detail_actions()
	var focus_id := StringName(String(data.get("focus_id", "")))
	var focus_set := false
	for value: Variant in _array(data.get("actions", [])):
		var action := _dictionary(value)
		var item: Control = FocusItem.new()
		_detail_actions.add_child(item)
		var target_id := StringName(String(action.get("id", "")))
		var payload: Variant = action.get("payload", {})
		item.call(
			"configure",
			target_id,
			String(action.get("text", target_id)),
			StringName(String(action.get("intent", "interact"))),
			payload if payload is Dictionary else {},
			bool(action.get("selected", false)),
			bool(action.get("available", true)),
			String(action.get("unavailable_reason", ""))
		)
		item.connect(&"activated", _on_detail_item_activated)
		if not focus_set and target_id == focus_id:
			item.call_deferred("grab_focus")
			focus_set = true
	if _detail_close != null:
		_detail_close.call("configure", &"close_detail", "CLOSE", &"cancel", {}, false, true, "")
		_detail_close.call_deferred("grab_focus")
	if _detail_surface != null:
		_detail_surface.visible = true


func _clear_detail_actions() -> void:
	if _detail_actions == null:
		return
	for child: Node in _detail_actions.get_children():
		_detail_actions.remove_child(child)
		child.queue_free()


func _update_feedback() -> void:
	var reason := StringName(String(_snapshot.get("feedback_reason", "")))
	if reason.is_empty():
		hide_feedback()
	else:
		show_feedback(_friendly_feedback(reason), &"error")


func _on_runtime_intent(result: Dictionary) -> void:
	if bool(result.get("accepted", false)):
		hide_feedback()
		_present_reaction(false)
		return
	var reason := StringName(String(result.get("feedback_id", result.get("reason", ""))))
	show_feedback(_friendly_feedback(reason), &"error")
	_present_reaction(true)


func _on_case_solved(_case_id: StringName, _solution_id: StringName) -> void:
	show_feedback("CASE SOLVED", &"success")


func _on_drawer_intent(intent: StringName, payload: Dictionary) -> void:
	intent_requested.emit(intent, payload.duplicate(true))


func _on_authored_intent(intent: StringName, payload: Dictionary) -> void:
	intent_requested.emit(intent, payload.duplicate(true))


func _present_reaction(rejected: bool) -> void:
	if is_instance_valid(_mounted_scene) and _mounted_scene.has_method(&"present_reaction"):
		_mounted_scene.call(&"present_reaction", rejected)


func _on_detail_item_activated(intent: StringName, payload: Dictionary) -> void:
	intent_requested.emit(intent, payload.duplicate(true))


func _entity_data(entity_id: StringName) -> Dictionary:
	return _entry_by_id(_content.get("entities", []), entity_id)


func _entry_by_id(entries: Variant, entry_id: StringName) -> Dictionary:
	if entry_id.is_empty():
		return {}
	for value: Variant in _array(entries):
		var entry := _dictionary(value)
		if StringName(String(entry.get("id", ""))) == entry_id:
			return entry
	return {}


func _message_data(message_id: String) -> Dictionary:
	for value: Variant in _array(_content.get("messages", [])):
		var message := _dictionary(value)
		if String(message.get("id", "")) == message_id:
			return message
	return {}


func _friendly_feedback(reason: StringName) -> String:
	match reason:
		&"rejected_kind":
			return "TARGET KIND REJECTED"
		&"slot_occupied":
			return "SLOT OCCUPIED"
		&"slot_persistent":
			return "SLOT IS PERSISTENT"
		&"almost":
			return "ALMOST"
		&"not_filled":
			return "NOT FILLED"
		&"unsolved":
			return "UNSOLVED"
		&"panel_locked":
			return "PANEL LOCKED"
		&"no_focus":
			return "NO TARGET SELECTED"
		&"content_unavailable":
			return "CONTENT UNAVAILABLE"
	return "INTENT UNAVAILABLE"


func _feedback_color(kind: StringName) -> Color:
	if kind == &"success":
		return SUCCESS
	if kind == &"error":
		return ERROR
	return FOCUS


func _apply_styles() -> void:
	if _foundation_panel != null:
		_foundation_panel.add_theme_stylebox_override("panel", _style(FOUNDATION_FILL, FOUNDATION_BORDER, 1, 3, 22.0))
	if _detail_surface != null:
		_detail_surface.add_theme_stylebox_override("panel", _style(SURFACE_FILL, SURFACE_BORDER, 1, 3, 18.0))
	if _foundation_title != null:
		_foundation_title.add_theme_color_override("font_color", TEXT)
		_foundation_title.add_theme_font_size_override("font_size", 18)
	if _foundation_body != null:
		_foundation_body.add_theme_color_override("font_color", MUTED)
		_foundation_body.add_theme_font_size_override("font_size", 13)
	if _detail_kind != null:
		_detail_kind.add_theme_color_override("font_color", MUTED)
		_detail_kind.add_theme_font_size_override("font_size", 12)
	if _detail_title != null:
		_detail_title.add_theme_color_override("font_color", TEXT)
		_detail_title.add_theme_font_size_override("font_size", 22)
	if _detail_body != null:
		_detail_body.add_theme_color_override("default_color", TEXT)
		_detail_body.add_theme_font_size_override("normal_font_size", 15)
	if _feedback_label != null:
		_feedback_label.add_theme_font_size_override("font_size", 13)


func _style(fill: Color, border: Color, width: int, radius: int, margin: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = margin
	style.content_margin_bottom = margin
	return style


func _dictionary(value: Variant) -> Dictionary:
	return value as Dictionary if value is Dictionary else {}


func _array(value: Variant) -> Array:
	return value as Array if value is Array else []
