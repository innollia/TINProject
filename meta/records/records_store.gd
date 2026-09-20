extends RefCounted

signal changed

const SCHEMA_VERSION: int = 1
const THEMES: Dictionary = {
	"signal_desk": {"name": "신호 기록실", "background": "101e2c", "surface": "1b3044", "accent": "7ed8ff", "text": "f1f8ff"},
	"relay_quay": {"name": "중계 부두", "background": "102721", "surface": "1c3b32", "accent": "80ebc4", "text": "f0fff7"},
	"last_echo": {"name": "마지막 메아리", "background": "261c35", "surface": "3c2b50", "accent": "dab1ff", "text": "fff5ff"},
	"return_cradle": {"name": "귀환의 요람", "background": "302118", "surface": "493326", "accent": "ffd29c", "text": "fff8e9"},
	"maintenance_cut": {"name": "정비 구역", "background": "292615", "surface": "403b24", "accent": "f5e78b", "text": "fffdeb"},
	"glyph_gallery": {"name": "접힌 기호관", "background": "241b35", "surface": "463557", "accent": "ffd58a", "text": "fff5ff"},
	"switchboard_choir": {"name": "합창 교환대", "background": "132a30", "surface": "25474d", "accent": "71c6b5", "text": "efffff"},
	"rain_lift": {"name": "빗물 승강장", "background": "101b25", "surface": "243640", "accent": "d49a57", "text": "edf8ff"},
	"borrowed_title": {"name": "빌린 오후", "background": "382936", "surface": "593f52", "accent": "ffc7a1", "text": "fff4df"},
	"glasshouse_return": {"name": "비 그친 온실", "background": "173b35", "surface": "37665b", "accent": "d9f4c7", "text": "f3ffed"},
	"teacup_orbit": {"name": "찻잔 궤도", "background": "311f2b", "surface": "503444", "accent": "ffe2a8", "text": "fff8e9"},
	"numberless_clock": {"name": "숫자 없는 시계", "background": "172238", "surface": "2d4263", "accent": "ffd07c", "text": "f4f8ff"},
	"shadow_ferry": {"name": "그림자 나룻배", "background": "101925", "surface": "26394b", "accent": "f4c675", "text": "f3f8ff"},
	"receipt_orchard": {"name": "영수증 과수원", "background": "183126", "surface": "35533d", "accent": "fff3b0", "text": "f3ffe8"},
	"wrong_weather": {"name": "틀린 일기예보", "background": "22233d", "surface": "3b3d62", "accent": "8ed8ff", "text": "f0e9ff"},
	"quiet_locker": {"name": "조용한 사물함", "background": "241f28", "surface": "514454", "accent": "f2cf9b", "text": "f6e8db"},
	"memory_customs": {"name": "기억 세관", "background": "132d31", "surface": "285158", "accent": "ffd18a", "text": "e7fff9"},
	"paper_moon_clinic": {"name": "종이달 진료소", "background": "251f3b", "surface": "44385f", "accent": "ffe6a3", "text": "fff0c7"},
	"afterimage_aquarium": {"name": "잔상 수족관", "background": "102938", "surface": "19516a", "accent": "9cecff", "text": "e4faff"},
	"paper_lighthouse": {"name": "종이등대", "background": "25202e", "surface": "3b3048", "accent": "ffd36e", "text": "fff0ce"},
	"lost_signal_vn": {"name": "분실된 신호", "background": "17263d", "surface": "293a61", "accent": "d9c7ff", "text": "f4f0ff"},
	"violet_case": {"name": "자정의 보랏빛 사건", "background": "191625", "surface": "3b3050", "accent": "e6b6ff", "text": "f7e9ff"},
	"after_signal": {"name": "신호가 지나간 뒤", "background": "211b2a", "surface": "493445", "accent": "f0c9a2", "text": "fff0ce"},
}

var entries: Array[Dictionary] = []
var notes: Array[Dictionary] = []
var collected_themes: Array[String] = []
var active_theme: String = ""
var current_theme: String = ""


func observe(module_id: StringName, payload: Dictionary) -> void:
	if String(module_id).strip_edges().is_empty() or not _has_keys(payload, ["id", "text"]):
		return
	if not _nonempty_string(payload["id"]) or not _nonempty_string(payload["text"]):
		return
	for entry: Dictionary in entries:
		if entry["module_id"] == String(module_id) and entry["id"] == payload["id"]:
			return
	entries.append({"module_id": String(module_id), "id": payload["id"], "text": payload["text"]})
	changed.emit()


func visit(module_id: StringName) -> void:
	var id: String = String(module_id)
	if not THEMES.has(id):
		return
	var needs_change: bool = active_theme != id or current_theme != id or not collected_themes.has(id)
	if not collected_themes.has(id):
		collected_themes.append(id)
	current_theme = id
	active_theme = id
	if needs_change:
		changed.emit()


func add_note(text: String, tags: String) -> void:
	if text.strip_edges().is_empty():
		return
	notes.append({"text": text, "tags": tags})
	changed.emit()


func edit_note(index: int, text: String, tags: String) -> bool:
	if index < 0 or index >= notes.size() or text.strip_edges().is_empty():
		return false
	if notes[index]["text"] != text or notes[index]["tags"] != tags:
		notes[index]["text"] = text
		notes[index]["tags"] = tags
		changed.emit()
	return true


func remove_note(index: int) -> bool:
	if index < 0 or index >= notes.size():
		return false
	notes.remove_at(index)
	changed.emit()
	return true


func select_theme(id: String) -> bool:
	if not THEMES.has(id) or not collected_themes.has(id):
		return false
	if active_theme != id:
		active_theme = id
		changed.emit()
	return true


func capture() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"entries": entries.duplicate(true),
		"notes": notes.duplicate(true),
		"collected_themes": collected_themes.duplicate(),
		"active_theme": active_theme,
		"current_theme": current_theme,
	}


func restore(data: Dictionary) -> bool:
	if not _has_keys(data, ["schema_version", "entries", "notes", "collected_themes", "active_theme", "current_theme"]):
		return false
	var version: Variant = data["schema_version"]
	if not (version is int or version is float):
		return false
	if not is_finite(float(version)) or float(version) != float(SCHEMA_VERSION):
		return false
	if not data["entries"] is Array or not data["notes"] is Array or not data["collected_themes"] is Array:
		return false
	if not data["active_theme"] is String or not data["current_theme"] is String:
		return false
	var next_entries: Array[Dictionary] = []
	var identities: Dictionary = {}
	for value: Variant in data["entries"]:
		if not value is Dictionary or not _has_keys(value, ["module_id", "id", "text"]):
			return false
		if not _nonempty_string(value["module_id"]) or not _nonempty_string(value["id"]) or not _nonempty_string(value["text"]):
			return false
		var source: String = value["module_id"]
		var identity: String = value["id"]
		if not identities.has(source):
			identities[source] = {}
		if identities[source].has(identity):
			return false
		identities[source][identity] = true
		next_entries.append(value.duplicate(true))
	var next_notes: Array[Dictionary] = []
	for value: Variant in data["notes"]:
		if not value is Dictionary or not _has_keys(value, ["text", "tags"]):
			return false
		if not _nonempty_string(value["text"]) or not value["tags"] is String:
			return false
		next_notes.append(value.duplicate(true))
	var next_themes: Array[String] = []
	for value: Variant in data["collected_themes"]:
		if not value is String or not THEMES.has(value) or next_themes.has(value):
			return false
		next_themes.append(value)
	var next_active: String = data["active_theme"]
	var next_current: String = data["current_theme"]
	if next_themes.is_empty():
		if not next_active.is_empty() or not next_current.is_empty():
			return false
	elif not next_themes.has(next_active) or not next_themes.has(next_current):
		return false
	entries = next_entries
	notes = next_notes
	collected_themes = next_themes
	active_theme = next_active
	current_theme = next_current
	return true


func theme_details(id: String = "") -> Dictionary:
	var selected: String = active_theme if id.is_empty() else id
	if not THEMES.has(selected):
		selected = "signal_desk"
	return THEMES[selected].duplicate(true)


func _has_keys(data: Dictionary, keys: Array[String]) -> bool:
	if data.size() != keys.size():
		return false
	for key: Variant in data:
		if not key is String or not keys.has(key):
			return false
	return true


func _nonempty_string(value: Variant) -> bool:
	return value is String and not value.strip_edges().is_empty()
