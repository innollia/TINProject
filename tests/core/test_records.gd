extends GutTest

const RecordsStore = preload("res://meta/records/records_store.gd")
const RecordsOverlay = preload("res://meta/records/records_overlay.gd")


func test_empty_store_allows_notes_without_visits_or_observations() -> void:
	var store := RecordsStore.new()
	watch_signals(store)
	assert_eq(store.entries.size(), 0)
	assert_eq(store.notes.size(), 0)
	assert_eq(store.collected_themes.size(), 0)
	assert_eq(store.active_theme, "")
	assert_eq(store.current_theme, "")
	store.add_note("처음부터 적는 메모\n두 번째 줄", "친구, 약속")
	assert_eq(store.notes, [{"text": "처음부터 적는 메모\n두 번째 줄", "tags": "친구, 약속"}])
	assert_eq(store.entries.size(), 0)
	assert_eq(store.collected_themes.size(), 0)
	assert_signal_emit_count(store, "changed", 1)
	store.add_note(" \n\t", "태그만")
	assert_eq(store.notes.size(), 1)
	assert_signal_emit_count(store, "changed", 1)
	store.add_note("태그 없는 메모", "")
	assert_eq(store.notes.size(), 2)


func test_note_mutations_validate_bounds_and_emit_only_for_real_changes() -> void:
	var store := RecordsStore.new()
	store.add_note("첫 메모", "처음")
	store.add_note("둘 메모", "")
	watch_signals(store)
	assert_false(store.edit_note(-1, "수정", "태그"))
	assert_false(store.edit_note(store.notes.size(), "수정", "태그"))
	assert_false(store.edit_note(0, " \n", "태그"))
	assert_signal_not_emitted(store, "changed")
	assert_true(store.edit_note(0, "수정한 메모", "새 태그"))
	assert_eq(store.notes[0], {"text": "수정한 메모", "tags": "새 태그"})
	assert_signal_emit_count(store, "changed", 1)
	assert_true(store.edit_note(0, "수정한 메모", "새 태그"))
	assert_signal_emit_count(store, "changed", 1)
	assert_false(store.remove_note(-1))
	assert_false(store.remove_note(store.notes.size()))
	assert_signal_emit_count(store, "changed", 1)
	assert_true(store.remove_note(1))
	assert_eq(store.notes, [{"text": "수정한 메모", "tags": "새 태그"}])
	assert_signal_emit_count(store, "changed", 2)


func test_overlay_edits_deletes_and_protects_a_stale_selection() -> void:
	var store := RecordsStore.new()
	var overlay := RecordsOverlay.new()
	add_child_autofree(overlay)
	overlay.setup(store)
	overlay.note_text.text = "첫 메모"
	overlay.note_tags.text = "처음"
	overlay.save_note_button.pressed.emit()
	overlay.note_text.text = "둘 메모"
	overlay.save_note_button.pressed.emit()
	assert_eq(store.notes.size(), 2)

	overlay.note_selector.item_selected.emit(1)
	assert_eq(overlay.selected_note_index, 0)
	assert_eq(overlay.note_text.text, "첫 메모")
	overlay.note_text.text = "첫 메모 수정"
	overlay.note_tags.text = "수정"
	overlay.save_note_button.pressed.emit()
	assert_eq(store.notes[0], {"text": "첫 메모 수정", "tags": "수정"})
	assert_true(overlay.notes_list.text.contains("첫 메모 수정"))

	overlay.note_selector.item_selected.emit(1)
	overlay.note_text.text = "작성 중인 초안"
	assert_true(store.edit_note(0, "외부에서 바뀐 메모", "외부 태그"))
	assert_true(bool(overlay.get("_selection_lost")))
	assert_true(overlay.save_note_button.disabled)
	assert_true(overlay.delete_note_button.disabled)
	assert_eq(overlay.note_text.text, "작성 중인 초안")

	overlay.new_note_button.pressed.emit()
	assert_false(overlay.save_note_button.disabled)
	assert_true(overlay.delete_note_button.disabled)
	overlay.note_selector.item_selected.emit(1)
	overlay.delete_note_button.pressed.emit()
	assert_eq(store.notes.size(), 1)
	assert_eq(overlay.selected_note_index, -1)
	assert_eq(overlay.note_text.text, "")
	assert_true(overlay.delete_note_button.disabled)


func test_observations_deduplicate_by_source_and_id_and_copy_payload() -> void:
	var store := RecordsStore.new()
	watch_signals(store)
	var payload: Dictionary = {"id": "friend", "text": "친구가 부두에서 기다린다."}
	store.observe(&"fixture_a", payload)
	payload["text"] = "바뀐 원본"
	store.observe(&"fixture_a", {"id": "friend", "text": "중복 내용"})
	store.observe(&"fixture_b", {"id": "friend", "text": "다른 장소의 같은 식별자"})
	store.observe(&"fixture_a", {"id": "fact", "text": "신호는 세 번 울린다."})
	assert_eq(store.entries.size(), 3)
	assert_eq(store.entries[0], {"module_id": "fixture_a", "id": "friend", "text": "친구가 부두에서 기다린다."})
	assert_eq(store.collected_themes.size(), 0)
	assert_signal_emit_count(store, "changed", 3)


func test_observations_from_known_places_never_collect_or_select_themes() -> void:
	var store := RecordsStore.new()
	for id: String in RecordsStore.THEMES:
		store.observe(StringName(id), {"id": "fact", "text": "장소에서 발견한 사실"})
	assert_eq(store.entries.size(), 22)
	assert_eq(store.collected_themes.size(), 0)
	assert_eq(store.active_theme, "")
	assert_eq(store.current_theme, "")
	store.visit(&"signal_desk")
	store.observe(&"relay_quay", {"id": "friend", "text": "친구가 남긴 말"})
	assert_eq(store.collected_themes, ["signal_desk"])
	assert_eq(store.active_theme, "signal_desk")
	assert_eq(store.current_theme, "signal_desk")


func test_observation_payload_rejects_missing_extra_and_wrong_types() -> void:
	var store := RecordsStore.new()
	watch_signals(store)
	var invalid: Array[Dictionary] = [
		{}, {"id": "x"}, {"text": "본문"},
		{"id": "", "text": "본문"}, {"id": "x", "text": " \n"},
		{"id": 1, "text": "본문"}, {"id": "x", "text": []},
		{"id": "x", "text": "본문", "currency": 10},
		{"id": "x", "text": "본문", "learned": true},
		{"id": &"not_json_string", "text": "본문"},
	]
	for payload: Dictionary in invalid:
		store.observe(&"fixture", payload)
	store.observe(&"", {"id": "x", "text": "본문"})
	store.observe(&"  ", {"id": "x", "text": "본문"})
	assert_eq(store.entries.size(), 0)
	assert_signal_not_emitted(store, "changed")


func test_visits_collect_only_aesthetic_themes_and_manual_choice_ends_on_visit() -> void:
	var store := RecordsStore.new()
	watch_signals(store)
	assert_eq(RecordsStore.THEMES.size(), 22)
	assert_false(store.select_theme("signal_desk"))
	store.visit(&"signal_desk")
	assert_eq(store.active_theme, "signal_desk")
	assert_eq(store.current_theme, "signal_desk")
	store.visit(&"relay_quay")
	assert_true(store.select_theme("signal_desk"))
	assert_eq(store.active_theme, "signal_desk")
	assert_eq(store.current_theme, "relay_quay")
	store.visit(&"relay_quay")
	assert_eq(store.active_theme, "relay_quay")
	assert_eq(store.collected_themes, ["signal_desk", "relay_quay"])
	assert_eq(store.entries.size(), 0)
	assert_eq(store.notes.size(), 0)
	assert_signal_emit_count(store, "changed", 4)
	store.visit(&"relay_quay")
	assert_true(store.select_theme("relay_quay"))
	assert_false(store.select_theme("unknown"))
	store.visit(&"unknown")
	assert_signal_emit_count(store, "changed", 4)
	for id: String in RecordsStore.THEMES:
		store.visit(StringName(id))
	assert_eq(store.collected_themes.size(), 22)
	assert_eq(store.entries.size(), 0)
	assert_eq(store.notes.size(), 0)
	assert_eq(store.capture().size(), 6, "Only journal state exists; no gameplay counters, locks, inventory, or learnt flags")


func test_json_roundtrip_normalizes_version_and_preserves_manual_choice() -> void:
	var source := _populated_store()
	var encoded: String = JSON.stringify(source.capture())
	var decoded: Dictionary = JSON.parse_string(encoded)
	decoded["schema_version"] = 1.0
	var restored := RecordsStore.new()
	watch_signals(restored)
	assert_true(restored.restore(decoded))
	assert_eq(restored.capture(), source.capture())
	assert_typeof(restored.capture()["schema_version"], TYPE_INT)
	assert_eq(restored.active_theme, "signal_desk")
	assert_eq(restored.current_theme, "relay_quay")
	assert_signal_not_emitted(restored, "changed")
	restored.observe(&"fixture", {"id": "fact", "text": "重複"})
	assert_eq(restored.entries.size(), 1)
	assert_signal_not_emitted(restored, "changed")
	assert_true(restored.restore(RecordsStore.new().capture()))
	assert_eq(restored.notes.size(), 0)
	assert_eq(restored.collected_themes.size(), 0)
	assert_signal_not_emitted(restored, "changed")


func test_capture_and_restore_are_fully_detached() -> void:
	var source := _populated_store()
	var snapshot: Dictionary = source.capture()
	var restored := RecordsStore.new()
	assert_true(restored.restore(snapshot))
	var expected: Dictionary = restored.capture()
	snapshot["entries"][0]["text"] = "変更"
	snapshot["notes"][0]["tags"] = "変更"
	snapshot["collected_themes"].clear()
	assert_eq(source.capture(), expected)
	assert_eq(restored.capture(), expected)
	var outgoing: Dictionary = restored.capture()
	outgoing["entries"].clear()
	outgoing["notes"][0]["text"] = "変更"
	outgoing["collected_themes"].append("unknown")
	assert_eq(restored.capture(), expected)
	var details: Dictionary = restored.theme_details()
	details["name"] = "変更"
	assert_ne(restored.theme_details()["name"], "変更")


func test_malformed_restore_is_atomic_and_silent_even_after_valid_prefix() -> void:
	var store := _populated_store()
	watch_signals(store)
	var expected: Dictionary = store.capture()
	var candidates: Array[Dictionary] = [{}]
	var wrong_entries: Array = [null, {}, [null], [{"module_id": "a", "id": "x", "text": "ok"}, {"module_id": "a", "id": "y", "text": 7}], [{"module_id": "a", "id": "x", "text": "ok", "extra": true}], [{"module_id": "", "id": "x", "text": "ok"}]]
	for value: Variant in wrong_entries:
		var data: Dictionary = expected.duplicate(true)
		data["entries"] = value
		candidates.append(data)
	var duplicate: Dictionary = expected.duplicate(true)
	duplicate["entries"].append(duplicate["entries"][0].duplicate(true))
	candidates.append(duplicate)
	var wrong_notes: Array = [null, {}, [7], [{"text": "ok", "tags": "valid"}, {"text": "bad", "tags": []}], [{"text": "  ", "tags": ""}], [{"text": "ok", "tags": "", "extra": true}]]
	for value: Variant in wrong_notes:
		var data: Dictionary = expected.duplicate(true)
		data["notes"] = value
		candidates.append(data)
	for key: String in ["active_theme", "current_theme"]:
		for value: Variant in [null, 1, "", "unknown", "last_echo"]:
			var data: Dictionary = expected.duplicate(true)
			data[key] = value
			candidates.append(data)
	for value: Variant in [null, {}, [], ["unknown"], ["signal_desk", "signal_desk"], ["signal_desk", 7]]:
		var data: Dictionary = expected.duplicate(true)
		data["collected_themes"] = value
		candidates.append(data)
	var extra: Dictionary = expected.duplicate(true)
	extra["extra"] = Vector2.ONE
	candidates.append(extra)
	var missing: Dictionary = expected.duplicate(true)
	missing.erase("notes")
	candidates.append(missing)
	for data: Dictionary in candidates:
		assert_false(store.restore(data))
		assert_eq(store.capture(), expected)
	assert_signal_not_emitted(store, "changed")


func test_wrong_and_extra_keys_reject_without_mutating_input_or_live_arrays() -> void:
	var store := _populated_store()
	watch_signals(store)
	var expected: Dictionary = store.capture()
	var retained_entries: Array[Dictionary] = store.entries
	var retained_notes: Array[Dictionary] = store.notes
	var retained_themes: Array[String] = store.collected_themes
	var candidates: Array[Dictionary] = []
	for level: String in ["root", "entry", "note"]:
		for extra_key: Variant in ["unexpected", 7]:
			for replace_key: bool in [false, true]:
				var data: Dictionary = expected.duplicate(true)
				var target: Dictionary = data
				var required_key: String = "notes"
				if level == "entry":
					target = data["entries"][0]
					required_key = "text"
				elif level == "note":
					target = data["notes"][0]
					required_key = "tags"
				if replace_key:
					target.erase(required_key)
				target[extra_key] = "otherwise JSON-safe"
				candidates.append(data)
	for data: Dictionary in candidates:
		var before_input: Dictionary = data.duplicate(true)
		assert_false(store.restore(data))
		assert_eq(data, before_input)
		assert_eq(store.capture(), expected)
		assert_true(is_same(store.entries, retained_entries))
		assert_true(is_same(store.notes, retained_notes))
		assert_true(is_same(store.collected_themes, retained_themes))
	assert_signal_not_emitted(store, "changed")


func test_future_fractional_nonfinite_and_wrong_schema_versions_rejected() -> void:
	var store := _populated_store()
	watch_signals(store)
	var expected: Dictionary = store.capture()
	for version: Variant in [2, 999999, 0, -1, 1.5, NAN, INF, -INF, "1", true, null]:
		var data: Dictionary = expected.duplicate(true)
		data["schema_version"] = version
		var retained_entries: Array[Dictionary] = store.entries
		var retained_notes: Array[Dictionary] = store.notes
		var retained_themes: Array[String] = store.collected_themes
		assert_false(store.restore(data))
		assert_eq(store.capture(), expected)
		assert_true(is_same(store.entries, retained_entries))
		assert_true(is_same(store.notes, retained_notes))
		assert_true(is_same(store.collected_themes, retained_themes))
	assert_signal_not_emitted(store, "changed")


func test_overlay_fields_are_available_accessible_and_save_without_visit() -> void:
	var store := RecordsStore.new()
	var overlay := RecordsOverlay.new()
	overlay.setup(store)
	add_child_autofree(overlay)
	assert_true(overlay.note_text.editable)
	assert_true(overlay.note_tags.editable)
	assert_false(overlay.save_note_button.disabled)
	for control: Control in [overlay.note_text, overlay.note_tags, overlay.save_note_button, overlay.theme_selector, overlay.close_button, overlay.observation_list, overlay.notes_list]:
		assert_eq(control.focus_mode, Control.FOCUS_ALL)
		assert_false(control.accessibility_name.is_empty())
		assert_false(control.focus_next.is_empty())
	assert_eq(overlay.theme_selector.item_count, 1)
	assert_true(overlay.theme_selector.is_item_disabled(0))
	overlay.note_text.text = "여기서 바로 메모를 쓸 수 있다.\n[태그도 본문 그대로]"
	overlay.note_tags.text = "친구, 기록"
	overlay.save_note_button.pressed.emit()
	assert_eq(store.notes.size(), 1)
	assert_true(overlay.notes_list.text.contains("여기서 바로 메모를 쓸 수 있다."))
	assert_true(overlay.notes_list.text.contains("친구, 기록"))
	assert_eq(overlay.note_text.text, "")
	assert_eq(overlay.note_tags.text, "")
	assert_false(overlay.notes_list.bbcode_enabled)
	assert_eq(store.collected_themes.size(), 0)
	watch_signals(overlay)
	overlay.close_button.pressed.emit()
	assert_signal_emitted(overlay, "close_requested")


func test_overlay_refresh_preserves_draft_and_displays_observations_and_theme_choices() -> void:
	var store := _populated_store()
	var overlay := RecordsOverlay.new()
	add_child_autofree(overlay)
	overlay.setup(store)
	overlay.setup(store)
	overlay.note_text.text = "작성 중인 메모"
	overlay.note_tags.text = "작성 중인 태그"
	store.observe(&"fixture", {"id": "friend", "text": "친구가 돌아오겠다고 말했다."})
	assert_true(overlay.observation_list.text.contains("친구가 돌아오겠다고 말했다."))
	assert_false(overlay.observation_list.text.contains("fixture"))
	assert_eq(overlay.theme_selector.item_count, 2)
	overlay.theme_selector.item_selected.emit(1)
	assert_eq(store.active_theme, "relay_quay")
	assert_eq(overlay.note_text.text, "작성 중인 메모")
	assert_eq(overlay.note_tags.text, "작성 중인 태그")
	store.visit(&"last_echo")
	assert_eq(store.active_theme, "last_echo")
	assert_eq(overlay.note_text.text, "작성 중인 메모")
	assert_eq(overlay.note_tags.text, "작성 중인 태그")
	assert_true(store.restore(RecordsStore.new().capture()))
	overlay.refresh()
	assert_eq(overlay.note_text.text, "작성 중인 메모")
	assert_eq(overlay.note_tags.text, "작성 중인 태그")
	assert_true(overlay.note_text.editable)
	assert_true(overlay.note_tags.editable)
	assert_false(overlay.save_note_button.disabled)
	assert_true(overlay.theme_selector.is_item_disabled(0))
	assert_null(overlay.theme, "Styles are local overrides, not a shared Theme change")
	assert_false(_player_text(overlay).to_lower().contains("module"))
	assert_false(_player_text(overlay).contains("모듈"))
	var replacement := RecordsStore.new()
	overlay.setup(replacement)
	store.add_note("이전 저장소", "")
	assert_false(overlay.notes_list.text.contains("이전 저장소"))


func test_each_palette_is_distinct_and_high_contrast() -> void:
	var store := RecordsStore.new()
	var backgrounds: Array[String] = []
	for id: String in RecordsStore.THEMES:
		var details: Dictionary = store.theme_details(id)
		assert_false(backgrounds.has(details["background"]))
		backgrounds.append(details["background"])
		var foreground := Color(String(details["text"]))
		var accent := Color(String(details["accent"]))
		for key: String in ["background", "surface"]:
			var background := Color(String(details[key]))
			assert_gt((_luminance(foreground) + 0.05) / (_luminance(background) + 0.05), 4.5)
			assert_gt((_luminance(accent) + 0.05) / (_luminance(background) + 0.05), 3.0)


func test_theme_overrides_are_local_and_keep_controls_and_popup_readable() -> void:
	var store := RecordsStore.new()
	var overlay := RecordsOverlay.new()
	add_child_autofree(overlay)
	overlay.setup(store)
	var sibling := Label.new()
	add_child_autofree(sibling)
	sibling.text = "다른 화면"
	var sibling_color: Color = sibling.get_theme_color("font_color")
	for id: String in RecordsStore.THEMES:
		store.visit(StringName(id))
		var details: Dictionary = store.theme_details()
		var foreground := Color(String(details["text"]))
		var surface := Color(String(details["surface"]))
		for control: Control in [overlay.note_text, overlay.note_tags, overlay.save_note_button, overlay.theme_selector, overlay.close_button]:
			assert_true(control.has_theme_color_override("font_color"))
			assert_eq(control.get_theme_color("font_color"), foreground)
			for state: String in ["normal", "hover", "pressed", "disabled"]:
				var style: StyleBoxFlat = control.get_theme_stylebox(state) as StyleBoxFlat
				assert_not_null(style)
				if style != null:
					assert_eq(style.bg_color, surface)
					assert_gt((_luminance(foreground) + 0.05) / (_luminance(style.bg_color) + 0.05), 4.5)
			assert_gt((_luminance(foreground) + 0.05) / (_luminance(control.get_theme_color("selection_color")) + 0.05), 4.5)
		for reading: RichTextLabel in [overlay.observation_list, overlay.notes_list]:
			assert_eq(reading.get_theme_color("default_color"), foreground)
			assert_true(reading.has_theme_font_override("normal_font"))
		var popup: PopupMenu = overlay.theme_selector.get_popup()
		assert_eq(popup.get_theme_color("font_color"), foreground)
		assert_eq(popup.get_theme_color("font_hover_color"), foreground)
		assert_eq(popup.get_theme_color("font_disabled_color"), foreground)
		assert_null(overlay.theme)
		assert_null(sibling.theme)
		assert_eq(sibling.get_theme_color("font_color"), sibling_color)
		assert_false(sibling.has_theme_color_override("font_color"))


func _populated_store() -> RecordsStore:
	var store := RecordsStore.new()
	store.observe(&"fixture", {"id": "fact", "text": "오래된 표지판이 남아 있다."})
	store.add_note("돌아올 때 다시 읽기", "약속")
	store.visit(&"signal_desk")
	store.visit(&"relay_quay")
	store.select_theme("signal_desk")
	return store


func _player_text(node: Node) -> String:
	var text: String = ""
	if node is Label or node is BaseButton or node is RichTextLabel:
		text += String(node.get("text"))
	for child: Node in node.get_children():
		text += _player_text(child)
	return text


func _luminance(color: Color) -> float:
	var linear: Color = color.srgb_to_linear()
	return 0.2126 * linear.r + 0.7152 * linear.g + 0.0722 * linear.b
