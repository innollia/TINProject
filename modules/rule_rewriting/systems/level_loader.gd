class_name RuleLevelLoader
extends RefCounted

const LEVEL_PATHS: Dictionary = {
	&"signal_room_01": "res://modules/rule_rewriting/content/level_01_signal_room.json",
	&"crossing_02": "res://modules/rule_rewriting/content/level_02_crossing.json"
}


static func load_level(level_id: StringName) -> Dictionary:
	if not LEVEL_PATHS.has(level_id):
		return {"ok": false, "error": "unknown_level"}
	var path: String = LEVEL_PATHS[level_id]
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "missing_file"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "unreadable_file"}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parse_definition(parsed, level_id)


static func parse_definition(value: Variant, expected_id: StringName = &"") -> Dictionary:
	if not value is Dictionary:
		return {"ok": false, "error": "invalid_root"}
	var version: Variant = value.get("version")
	var id_value: Variant = value.get("id")
	var title_value: Variant = value.get("title")
	if not RuleGridEntity._is_integer(version) or int(version) != 1 \
		or not id_value is String or id_value.is_empty() \
		or not title_value is String or title_value.is_empty():
		return {"ok": false, "error": "invalid_header"}
	var level_id := StringName(id_value)
	if not expected_id.is_empty() and expected_id != level_id:
		return {"ok": false, "error": "id_mismatch"}
	var state := RuleGridState.from_dictionary(value)
	if state == null:
		return {"ok": false, "error": "invalid_grid"}
	for entity: RuleGridEntity in state.entities:
		if entity.is_word and entity.kind != entity.word_value:
			return {"ok": false, "error": "word_kind_mismatch"}
	return {"ok": true, "id": level_id, "title": title_value, "state": state}
