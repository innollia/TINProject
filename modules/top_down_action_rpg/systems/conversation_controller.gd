class_name TopDownActionRpgConversationController
extends RefCounted

const MAX_TEXT_LENGTH: int = 1200
const MAX_LINES_PER_PAGE: int = 9
const EXTREME_PRESENTATION_CLASS: String = "extreme"
const RED_PRESENTATION_CLASSES: Array[String] = ["extreme", "hostile", "result", "unavailable"]
const CHOICE_PRESENTATION_CLASSES: Array[String] = ["neutral", "extreme", "unavailable", "result"]
const RETURN_FOCUS_VALUES: Array[String] = ["field", "choice", "conversation"]
const DOCUMENT_PRESENTATIONS: Array[String] = ["plain", "redacted", "corrupted"]
const ADVANCE_AUTO: String = "auto"

const PAGE_ADVANCE_AUTO: String = "page_advanced"
const PAGE_ADVANCE_WAIT: String = "await_input"
const PAGE_ADVANCE_END: String = "page_end"
const DOCUMENT_CLOSED: String = "document_closed"
const DIALOGUE_CLOSED: String = "closed"

var game_state: TopDownActionRpgGameState
var catalog: TopDownActionRpgContentLoader.Catalog
var conversation_id: StringName = &""
var page_index: int = 0
var choice_index: int = 0
var active_choice_id: StringName = &""
var committed: bool = false
var document_id: StringName = &""
var document_page_index: int = 0
var origin_region_id: String = ""
var origin_interactable_id: StringName = &""
var origin_anchor_id: String = ""
var unreadable_reason: String = ""


func setup(p_state: TopDownActionRpgGameState, p_catalog: TopDownActionRpgContentLoader.Catalog) -> bool:
	game_state = p_state
	catalog = p_catalog
	return p_state != null and p_catalog != null


func current_conversation() -> Dictionary:
	if catalog == null or conversation_id.is_empty():
		return {}
	return catalog.record(String(conversation_id))


func open_conversation(target_conversation_id: StringName, from_interactable_id: StringName) -> String:
	if game_state == null or catalog == null:
		return "conversation_unavailable"
	var record: Dictionary = catalog.record(String(target_conversation_id))
	if record.is_empty():
		unreadable_reason = "unknown_reference"
		return "unknown_reference"
	if not TopDownActionRpgContentLoader.evaluate_condition(record.get("entry_condition", {}), game_state, catalog):
		unreadable_reason = "entry_condition"
		return "entry_condition"
	if String(record.get("revisit", "")) == "once" and game_state.conversation_state(String(target_conversation_id)).get("completed", false):
		unreadable_reason = "revisit_once"
		return "revisit_once"
	conversation_id = target_conversation_id
	page_index = 0
	choice_index = 0
	active_choice_id = &""
	committed = false
	document_id = &""
	document_page_index = 0
	origin_region_id = game_state.region_id()
	origin_interactable_id = from_interactable_id
	origin_anchor_id = String(game_state.field.get("anchor_id", ""))
	game_state.set_mode("dialogue")
	game_state.field["active_interaction_id"] = String(from_interactable_id)
	return "opened"


func pages() -> Array:
	var record: Dictionary = current_conversation()
	return record.get("pages", []) if record.get("pages", []) is Array else []


func choices() -> Array:
	var record: Dictionary = current_conversation()
	return record.get("choices", []) if record.get("choices", []) is Array else []


func at_choice_set() -> bool:
	return page_index >= pages().size()


func current_page() -> Dictionary:
	var list: Array = pages()
	if page_index < 0 or page_index >= list.size():
		return {}
	var page: Variant = list[page_index]
	return page if page is Dictionary else {}


func page_text() -> String:
	var page: Dictionary = current_page()
	if page.is_empty():
		return ""
	var text: String = String(page.get("text", ""))
	return text.substr(0, MAX_TEXT_LENGTH)


func page_presentation_class() -> String:
	var page: Dictionary = current_page()
	if page.is_empty():
		return "neutral"
	var value: String = String(page.get("presentation_class", "neutral"))
	return value


func page_is_red() -> bool:
	return RED_PRESENTATION_CLASSES.has(page_presentation_class())


func page_focus_channel() -> String:
	return "text_and_bracket"


func focus_kind() -> String:
	if at_choice_set():
		return "choice"
	if not page_text().is_empty():
		return "page_advance"
	return "page_end"


func advance_page() -> String:
	var page: Dictionary = current_page()
	if page.is_empty():
		return PAGE_ADVANCE_END
	if String(page.get("advance", ADVANCE_AUTO)) != ADVANCE_AUTO:
		return PAGE_ADVANCE_WAIT
	page_index += 1
	if page_index >= pages().size() and choices().is_empty():
		return complete()
	return PAGE_ADVANCE_AUTO


func choice_rows() -> Array:
	var result: Array = []
	for entry: Variant in choices():
		if not entry is Dictionary:
			continue
		var choice: Dictionary = entry
		var available: bool = TopDownActionRpgContentLoader.evaluate_condition(choice.get("availability", {}), game_state, catalog)
		var reveal: bool = available or String(choice.get("unavailable_reason", "")) != ""
		result.append({
			"choice_id": String(choice.get("choice_id", "")),
			"text": String(choice.get("text", "")),
			"presentation_class": String(choice.get("presentation_class", "neutral")),
			"available": available,
			"focusable": true,
			"disabled": not available,
			"unavailable_reason": "" if available else String(choice.get("unavailable_reason", "")),
			"visible": reveal,
			"is_red": String(choice.get("presentation_class", "neutral")) in RED_PRESENTATION_CLASSES,
		})
	return result


func visible_choice_count() -> int:
	var count: int = 0
	for row: Dictionary in choice_rows():
		if bool(row["visible"]):
			count += 1
	return count


func move_choice_focus(step: int) -> bool:
	var rows: Array = choice_rows()
	var visible: Array = []
	for row: Dictionary in rows:
		if bool(row["visible"]):
			visible.append(row)
	if visible.is_empty():
		return false
	var index: int = 0
	for offset: int in range(visible.size()):
		if String(visible[offset]["choice_id"]) == String(active_choice_id):
			index = offset
			break
	index = wrapi(index + step, 0, visible.size())
	active_choice_id = StringName(String(visible[index]["choice_id"]))
	choice_index = index
	return true


func focused_choice() -> Dictionary:
	var visible: Array = []
	for row: Dictionary in choice_rows():
		if bool(row["visible"]):
			visible.append(row)
	if visible.is_empty():
		return {}
	if active_choice_id.is_empty():
		active_choice_id = StringName(String(visible[0]["choice_id"]))
	for row: Dictionary in visible:
		if String(row["choice_id"]) == String(active_choice_id):
			return row
	return visible[0]


func confirm_choice() -> Dictionary:
	var row: Dictionary = focused_choice()
	if row.is_empty():
		return {"result": "skipped_no_valid_target"}
	if not bool(row["available"]):
		return {"result": "skipped_blocked_by_status", "reason": String(row["unavailable_reason"]), "choice_id": String(row["choice_id"])}
	var choice: Dictionary = _choice_by_id(String(row["choice_id"]))
	if choice.is_empty():
		return {"result": "unknown_reference", "choice_id": String(row["choice_id"])}
	if not TopDownActionRpgContentLoader.evaluate_condition(choice.get("availability", {}), game_state, catalog):
		return {"result": "skipped_blocked_by_status", "choice_id": String(row["choice_id"])}
	var applied: Array = _apply_choice(choice)
	committed = true
	var next_page: String = _result_page_after(choice)
	_record_progress(choice)
	if next_page == "close":
		var closed: String = close()
		return {"result": "committed", "choice_id": String(choice.get("choice_id", "")), "applied": applied, "closed": closed}
	return {"result": "committed", "choice_id": String(choice.get("choice_id", "")), "applied": applied, "next": next_page}


func _choice_by_id(choice_id: String) -> Dictionary:
	for entry: Variant in choices():
		if entry is Dictionary and String(entry.get("choice_id", "")) == choice_id:
			return entry
	return {}


func _result_page_after(choice: Dictionary) -> String:
	var index: int = choices().find(choice)
	if index < 0:
		return "close"
	if index + 1 < choices().size():
		choice_index = index + 1
		active_choice_id = StringName(String((choices()[index + 1] as Dictionary).get("choice_id", "")))
		return "choice"
	return "close"


func _apply_choice(choice: Dictionary) -> Array:
	var applied: Array = []
	if game_state == null or catalog == null:
		return applied
	for key: String in ["immediate_effect_id", "delayed_effect_id"]:
		if not choice.has(key):
			continue
		var effect_id: String = String(choice[key])
		var effect: Dictionary = catalog.record(effect_id)
		if effect.is_empty():
			continue
		applied.append_array(TopDownActionRpgContentLoader.apply_effect(effect, game_state, catalog))
		var delay: Dictionary = effect.get("delay_ref", {}) if effect.get("delay_ref", {}) is Dictionary else {}
		if String(effect.get("timing", "immediate")) == "on_clock_stage" and delay.has("id"):
			game_state.queue_delayed_write(effect_id, String(delay["id"]), game_state.region_id(), TopDownActionRpgGameState.CLOCK_STAGE_COUNT - 1)
		elif String(effect.get("timing", "immediate")) == "delayed":
			game_state.append_commit_log({"effect_id": effect_id, "timing": effect.get("timing", "delayed"), "source_region_id": game_state.region_id()})
	return applied


func _record_progress(choice: Dictionary) -> void:
	if game_state == null:
		return
	var state: Dictionary = game_state.conversation_state(String(conversation_id))
	var taken: Array = state.get("taken_choice_ids", []) if state.get("taken_choice_ids", []) is Array else []
	var choice_id: String = String(choice.get("choice_id", ""))
	if not taken.has(choice_id):
		taken.append(choice_id)
	state["taken_choice_ids"] = taken
	state["last_choice_id"] = choice_id
	state["committed"] = true
	game_state.mark_conversation_state(String(conversation_id), state)


func cancel() -> String:
	if not document_id.is_empty():
		return close_document()
	if committed:
		return "cancel_after_commit"
	if page_index > 0:
		page_index -= 1
		return "page_back"
	if not conversation_id.is_empty():
		return close()
	return "already_closed"


func complete() -> String:
	var record: Dictionary = current_conversation()
	if game_state != null and not record.is_empty():
		var state: Dictionary = game_state.conversation_state(String(conversation_id))
		state["completed"] = true
		game_state.mark_conversation_state(String(conversation_id), state)
		_apply_effect_block(record.get("on_complete", {}))
	return close()


func close() -> String:
	if game_state == null:
		return DIALOGUE_CLOSED
	game_state.field["active_interaction_id"] = String(origin_interactable_id)
	if not origin_anchor_id.is_empty():
		game_state.field["anchor_id"] = origin_anchor_id
	game_state.set_mode("field")
	conversation_id = &""
	document_id = &""
	page_index = 0
	choice_index = 0
	active_choice_id = &""
	document_page_index = 0
	committed = false
	return DIALOGUE_CLOSED


func close_document() -> String:
	document_page_index = 0
	document_id = &""
	return close()


func open_document(target_document_id: StringName) -> String:
	if game_state == null or catalog == null:
		return "document_unavailable"
	var record: Dictionary = catalog.record(String(target_document_id))
	if record.is_empty():
		return "unknown_reference"
	var reading: Dictionary = record.get("reading", {}) if record.get("reading", {}) is Dictionary else {}
	if not TopDownActionRpgContentLoader.evaluate_condition((record.get("availability", {}) as Dictionary).get("condition", {}), game_state, catalog):
		return "entry_condition"
	document_id = target_document_id
	document_page_index = 0
	game_state.set_mode("dialogue")
	return "opened"


func document_page() -> Dictionary:
	if catalog == null or document_id.is_empty():
		return {}
	var record: Dictionary = catalog.record(String(document_id))
	var pages: Array = record.get("pages", []) if record.get("pages", []) is Array else []
	if document_page_index < 0 or document_page_index >= pages.size():
		return {}
	var page: Variant = pages[document_page_index]
	return page if page is Dictionary else {}


func document_lines() -> Array:
	var page: Dictionary = document_page()
	var lines: Array = page.get("lines", []) if page.get("lines", []) is Array else []
	return lines.slice(0, MAX_LINES_PER_PAGE)


func document_presentation() -> String:
	return String(document_page().get("presentation", "plain"))


func document_page_count() -> int:
	if catalog == null or document_id.is_empty():
		return 0
	return (catalog.record(String(document_id)).get("pages", []) as Array).size() if catalog.record(String(document_id)).get("pages", []) is Array else 0


func advance_document() -> String:
	var record: Dictionary = catalog.record(String(document_id))
	var pages: Array = record.get("pages", []) if record.get("pages", []) is Array else []
	document_page_index += 1
	if document_page_index >= pages.size():
		var post_read: Dictionary = record.get("post_read", {}) if record.get("post_read", {}) is Dictionary else {}
		_apply_effect_block(post_read)
		if game_state != null:
			game_state.mark_document_read(String(document_id))
		close_document()
		return DOCUMENT_CLOSED
	return "document_advanced"


func _apply_effect_block(block: Variant) -> void:
	if not block is Dictionary or game_state == null or catalog == null:
		return
	for effect_id: Variant in block.get("effect_ids", []) if block.get("effect_ids", []) is Array else []:
		var effect: Dictionary = catalog.record(String(effect_id))
		if not effect.is_empty():
			TopDownActionRpgContentLoader.apply_effect(effect, game_state, catalog)


func dialog_state() -> Dictionary:
	return {
		"conversation_id": String(conversation_id),
		"page_index": page_index,
		"page_count": pages().size(),
		"choice_index": choice_index,
		"focused_choice_id": String(active_choice_id),
		"focus_kind": focus_kind(),
		"committed": committed,
		"document_id": String(document_id),
		"document_page_index": document_page_index,
		"document_presentation": document_presentation(),
		"origin_region_id": origin_region_id,
		"origin_interactable_id": String(origin_interactable_id),
		"unreadable_reason": unreadable_reason,
	}
