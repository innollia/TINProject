extends Control

signal close_requested

const RecordsStore = preload("res://meta/records/records_store.gd")

var store: RecordsStore
var note_text: TextEdit
var note_tags: LineEdit
var save_note_button: Button
var new_note_button: Button
var delete_note_button: Button
var note_selector: OptionButton
var selected_note_index: int = -1
var theme_selector: OptionButton
var close_button: Button
var observation_list: RichTextLabel
var notes_list: RichTextLabel
var _panel: PanelContainer
var _rows: VBoxContainer
var _heading: Label
var _status: Label
var _font: SystemFont
var _editor_heading: Label
var _selected_note: Dictionary = {}
var _selected_content: Dictionary = {}
var _listed_notes: Array[Dictionary] = []
var _selection_lost: bool = false


func setup(value: RecordsStore) -> void:
	if store != null and store.changed.is_connected(refresh):
		store.changed.disconnect(refresh)
	if store != value and not _selected_note.is_empty():
		_invalidate_selection()
	store = value
	_build()
	if store != null:
		store.changed.connect(refresh)
	refresh()


func _ready() -> void:
	_build()
	refresh()


func refresh() -> void:
	_build()
	_reconcile_selection()
	_refresh_note_selector()
	_update_editor_mode()
	if store == null:
		observation_list.text = "기록 저장소가 연결되지 않았습니다."
		notes_list.text = "저장한 메모가 없습니다."
		theme_selector.clear()
		_heading.text = "여정의 기록"
		_apply_palette(RecordsStore.new().theme_details())
		return
	var details: Dictionary = store.theme_details()
	_heading.text = "여정의 기록 · " + String(details["name"])
	observation_list.text = "아직 남겨진 관찰이 없습니다. 여행 중 발견한 사실과 대화가 이곳에 쌓입니다."
	if not store.entries.is_empty():
		var observations: PackedStringArray = []
		for index: int in range(store.entries.size()):
			observations.append("%d. %s" % [index + 1, store.entries[index]["text"]])
		observation_list.text = "\n\n".join(observations)
	notes_list.text = "아직 작성한 메모가 없습니다. 지금 바로 아래에 자유롭게 적어 보세요."
	if not store.notes.is_empty():
		var saved_notes: PackedStringArray = []
		for index: int in range(store.notes.size()):
			var note: Dictionary = store.notes[index]
			var text: String = "%d. %s" % [index + 1, note["text"]]
			if not String(note["tags"]).is_empty():
				text += "\n태그: " + String(note["tags"])
			saved_notes.append(text)
		notes_list.text = "\n\n".join(saved_notes)
	theme_selector.clear()
	for id: String in store.collected_themes:
		var item: int = theme_selector.item_count
		theme_selector.add_item(String(store.theme_details(id)["name"]))
		theme_selector.set_item_metadata(item, id)
		if id == store.active_theme:
			theme_selector.select(item)
	if store.collected_themes.is_empty():
		theme_selector.add_item("방문한 장소의 색감이 여기에 모입니다")
		theme_selector.set_item_disabled(0, true)
	_apply_palette(details)


func _build() -> void:
	if _panel != null:
		return
	name = "RecordsOverlay"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	accessibility_name = "여정의 기록"
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "Noto Sans KR", "Apple SD Gothic Neo"])
	_font.allow_system_fallback = true
	_panel = PanelContainer.new()
	_panel.name = "JournalPanel"
	add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 16
	_panel.offset_top = 16
	_panel.offset_right = -16
	_panel.offset_bottom = -16
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	_panel.add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	layout.add_child(header)
	_heading = Label.new()
	_heading.text = "여정의 기록"
	_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(_heading)
	close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "닫기"
	close_button.accessibility_name = "기록 닫기"
	close_button.custom_minimum_size = Vector2(96, 44)
	close_button.pressed.connect(_request_close)
	header.add_child(close_button)
	var scroll := ScrollContainer.new()
	scroll.name = "JournalScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	layout.add_child(scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 14)
	scroll.add_child(_rows)
	_add_label("관찰과 대화")
	observation_list = _add_reading_area("ObservationList", "관찰과 대화 기록")
	_add_label("내가 남긴 메모")
	notes_list = _add_reading_area("NotesList", "저장한 메모와 태그")
	note_selector = OptionButton.new()
	note_selector.name = "NoteSelector"
	note_selector.accessibility_name = "수정할 저장 메모 선택"
	note_selector.custom_minimum_size.y = 44
	note_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note_selector.item_selected.connect(_select_note)
	_rows.add_child(note_selector)
	new_note_button = Button.new()
	new_note_button.name = "NewNoteButton"
	new_note_button.text = "새 메모 작성 · 입력 비우기"
	new_note_button.accessibility_name = "입력을 비우고 새 메모 작성"
	new_note_button.custom_minimum_size.y = 44
	new_note_button.pressed.connect(_new_note)
	_rows.add_child(new_note_button)
	_editor_heading = _add_label("새 메모")
	note_text = TextEdit.new()
	note_text.name = "NoteText"
	note_text.accessibility_name = "새 메모 내용"
	note_text.tooltip_text = "기억하고 싶은 내용을 자유롭게 적으세요."
	note_text.placeholder_text = "기억하고 싶은 내용…"
	note_text.custom_minimum_size = Vector2(0, 132)
	note_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	note_text.editable = true
	_rows.add_child(note_text)
	_add_label("태그 · 쉼표 등으로 자유롭게 구분하세요")
	note_tags = LineEdit.new()
	note_tags.name = "NoteTags"
	note_tags.accessibility_name = "새 메모 태그"
	note_tags.placeholder_text = "예: 친구, 약속, 다시 찾을 곳"
	note_tags.tooltip_text = "태그는 비워 두어도 됩니다."
	note_tags.custom_minimum_size.y = 44
	note_tags.editable = true
	_rows.add_child(note_tags)
	save_note_button = Button.new()
	save_note_button.name = "SaveNoteButton"
	save_note_button.text = "메모 저장"
	save_note_button.accessibility_name = "작성한 메모 저장"
	save_note_button.custom_minimum_size.y = 44
	save_note_button.pressed.connect(_save_note)
	_rows.add_child(save_note_button)
	delete_note_button = Button.new()
	delete_note_button.name = "DeleteNoteButton"
	delete_note_button.text = "선택한 메모 삭제"
	delete_note_button.accessibility_name = "선택한 저장 메모 삭제"
	delete_note_button.custom_minimum_size.y = 44
	delete_note_button.pressed.connect(_delete_note)
	_rows.add_child(delete_note_button)
	_status = _add_label("메모와 태그는 언제든 작성할 수 있습니다.")
	_add_label("모은 색감 · 직접 고른 색감은 다음 장소를 방문할 때까지 유지됩니다")
	theme_selector = OptionButton.new()
	theme_selector.name = "ThemeSelector"
	theme_selector.accessibility_name = "모은 기록 색감 선택"
	theme_selector.tooltip_text = "기록의 색감만 바뀝니다. 여행의 규칙이나 소지품은 바뀌지 않습니다."
	theme_selector.custom_minimum_size.y = 44
	theme_selector.item_selected.connect(_select_theme)
	_rows.add_child(theme_selector)
	var controls: Array[Control] = [close_button, observation_list, notes_list, note_selector, new_note_button, note_text, note_tags, save_note_button, delete_note_button, theme_selector]
	for control: Control in controls:
		control.focus_mode = Control.FOCUS_ALL
	for index: int in range(controls.size()):
		controls[index].focus_next = controls[index].get_path_to(controls[(index + 1) % controls.size()])
		controls[index].focus_previous = controls[index].get_path_to(controls[(index - 1 + controls.size()) % controls.size()])
	_apply_palette(RecordsStore.new().theme_details())


func _add_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rows.add_child(label)
	return label


func _add_reading_area(node_name: String, accessible_name: String) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.name = node_name
	label.accessibility_name = accessible_name
	label.bbcode_enabled = false
	label.fit_content = true
	label.scroll_active = false
	label.selection_enabled = true
	label.custom_minimum_size.y = 52
	_rows.add_child(label)
	return label


func _find_note(note: Dictionary) -> int:
	if store != null:
		for index: int in range(store.notes.size()):
			if is_same(store.notes[index], note):
				return index
	return -1


func _invalidate_selection() -> void:
	selected_note_index = -1
	_selected_note = {}
	_selected_content = {}
	_selection_lost = true


func _reconcile_selection() -> void:
	if _selected_note.is_empty():
		return
	selected_note_index = _find_note(_selected_note)
	if selected_note_index < 0 or _selected_note != _selected_content:
		_invalidate_selection()


func _refresh_note_selector() -> void:
	note_selector.clear()
	_listed_notes.clear()
	note_selector.add_item("저장한 메모를 선택하세요")
	note_selector.set_item_disabled(0, true)
	if store != null:
		for index: int in range(store.notes.size()):
			_listed_notes.append(store.notes[index])
			note_selector.add_item("%d번 메모 수정" % [index + 1])
	note_selector.select(selected_note_index + 1)


func _update_editor_mode() -> void:
	var editing: bool = selected_note_index >= 0
	_editor_heading.text = "%d번 메모 수정" % [selected_note_index + 1] if editing else "새 메모"
	save_note_button.text = "수정한 메모 저장" if editing else "새 메모 저장"
	save_note_button.accessibility_name = save_note_button.text
	note_text.accessibility_name = "수정할 메모 내용" if editing else "새 메모 내용"
	note_tags.accessibility_name = "수정할 메모 태그" if editing else "새 메모 태그"
	delete_note_button.disabled = store == null or not editing
	save_note_button.disabled = store == null or _selection_lost
	if _selection_lost:
		_editor_heading.text = "선택한 메모가 변경되었습니다 · 입력은 보관 중"
		_status.text = "다른 기록에 덮어쓰지 않도록 저장을 멈췄습니다. 입력을 복사한 뒤 메모를 다시 선택하거나 새 메모 작성을 눌러 주세요."


func _select_note(item: int) -> void:
	if store == null or item <= 0 or item > _listed_notes.size():
		return
	var note: Dictionary = _listed_notes[item - 1]
	var index: int = _find_note(note)
	if index < 0:
		refresh()
		return
	selected_note_index = index
	_selected_note = note
	_selected_content = note.duplicate(true)
	_selection_lost = false
	note_text.text = String(note["text"])
	note_tags.text = String(note["tags"])
	_status.text = "선택한 메모를 수정하거나 삭제할 수 있습니다."
	refresh()
	note_text.grab_focus()


func _new_note() -> void:
	selected_note_index = -1
	_selected_note = {}
	_selected_content = {}
	_selection_lost = false
	note_text.text = ""
	note_tags.text = ""
	_status.text = "새 메모를 작성합니다."
	refresh()
	note_text.grab_focus()


func _save_note() -> void:
	refresh()
	if store == null or _selection_lost:
		return
	if note_text.text.strip_edges().is_empty():
		_status.text = "메모 내용을 먼저 적어 주세요."
		note_text.grab_focus()
		return
	if selected_note_index >= 0:
		_selected_content = {"text": note_text.text, "tags": note_tags.text}
		if not store.edit_note(selected_note_index, note_text.text, note_tags.text):
			return
		_status.text = "선택한 메모를 수정했습니다."
	else:
		store.add_note(note_text.text, note_tags.text)
		_new_note()
		_status.text = "메모를 기록에 남겼습니다."
	note_text.grab_focus()


func _delete_note() -> void:
	refresh()
	if store == null or _selection_lost or selected_note_index < 0:
		return
	if store.remove_note(selected_note_index):
		_new_note()
		_status.text = "선택한 메모를 삭제했습니다. 새 메모를 작성하거나 다른 메모를 선택하세요."


func _select_theme(index: int) -> void:
	if store == null or index < 0 or index >= theme_selector.item_count:
		return
	var id: Variant = theme_selector.get_item_metadata(index)
	if id is String:
		store.select_theme(id)


func _request_close() -> void:
	close_requested.emit()


func _apply_palette(details: Dictionary) -> void:
	var background := Color(String(details["background"]))
	var surface := Color(String(details["surface"]))
	var accent := Color(String(details["accent"]))
	var foreground := Color(String(details["text"]))
	_panel.add_theme_stylebox_override("panel", _box(background, accent, 2))
	_style_controls(self, surface, accent, foreground)
	_heading.add_theme_font_size_override("font_size", 24)
	var popup: PopupMenu = theme_selector.get_popup()
	popup.add_theme_font_override("font", _font)
	popup.add_theme_font_size_override("font_size", 18)
	popup.add_theme_stylebox_override("panel", _box(background, accent, 2))
	popup.add_theme_stylebox_override("hover", _box(surface, accent, 2))
	for key: String in ["font_color", "font_hover_color", "font_disabled_color"]:
		popup.add_theme_color_override(key, foreground)


func _style_controls(node: Node, surface: Color, accent: Color, foreground: Color) -> void:
	if node is Control:
		var control: Control = node as Control
		control.add_theme_font_override("font", _font)
		control.add_theme_font_size_override("font_size", 18)
		for key: String in ["font_color", "default_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_placeholder_color", "caret_color"]:
			control.add_theme_color_override(key, foreground)
		control.add_theme_color_override("selection_color", accent.darkened(0.65))
		control.add_theme_color_override("font_selected_color", foreground)
		if control is RichTextLabel:
			control.add_theme_font_override("normal_font", _font)
			control.add_theme_font_size_override("normal_font_size", 18)
		if control is BaseButton or control is TextEdit or control is LineEdit:
			for key: String in ["normal", "hover", "pressed", "disabled", "read_only"]:
				control.add_theme_stylebox_override(key, _box(surface, accent, 1))
			control.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, accent, 3))
	for child: Node in node.get_children():
		_style_controls(child, surface, accent, foreground)


func _box(background: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
