class_name RuleLevelLoader
extends RefCounted

const CONTENT_DIRECTORY: String = "res://modules/rule_rewriting/content"
const INDEX_PATH: String = "res://modules/rule_rewriting/content/index.json"
const INDEX_SCHEMA_VERSION: int = 1
const BOARD_SCHEMA_VERSION: int = 1
const COMPLETION_WIN_CONTACT: String = "win_contact"
const DOOR_BOUNDARIES: Array[String] = ["north", "east", "south", "west"]
const NOUN_CATALOG: Array[StringName] = [
	&"BABA", &"BASIN", &"BEACON", &"BELL", &"BOX", &"CORE", &"DOOR",
	&"EMBER", &"FLAG", &"GATE", &"GLASS", &"INK", &"KEY", &"LAMP",
	&"LANTERN", &"LARK", &"LAVA", &"METRIX", &"MOTH", &"PAD", &"PANEL",
	&"PEARL", &"POOL", &"ROCK", &"RUNE", &"STAR", &"TEXT", &"TOKEN",
	&"TURNER", &"VINE", &"WALL"
]
const OPERATOR_CATALOG: Array[StringName] = [
	&"AND", &"FACING", &"HAS", &"INSIDE", &"IS", &"NEAR", &"NOT", &"ON", &"OWNS"
]
const PROPERTY_CATALOG: Array[StringName] = [
	&"3D", &"ACTIVE", &"DEFEAT", &"FLOAT", &"HOT", &"INV", &"MELT", &"MOVE",
	&"OPEN", &"PULL", &"PUSH", &"SAFE", &"SHIFT", &"SHUT", &"SINK", &"STOP",
	&"SWAP", &"WEAK", &"WIN", &"WORD", &"YOU", &"YOU2"
]
const OBJECT_CATALOG: Array[StringName] = [
	&"BABA", &"BASIN", &"BEACON", &"BELL", &"BOX", &"CORE", &"DOOR", &"EMBER",
	&"FLAG", &"GATE", &"GLASS", &"INK", &"KEY", &"LAMP", &"LANTERN", &"LARK",
	&"LAVA", &"METRIX", &"MOTH", &"PAD", &"PANEL", &"PEARL", &"POOL", &"ROCK",
	&"RUNE", &"STAR", &"TEXT", &"TOKEN", &"TURNER", &"VINE", &"WALL"
]

const INDEX_KEYS: Array[String] = ["schema_version", "boards"]
const INDEX_ENTRY_KEYS: Array[String] = ["id", "path"]
const LEGACY_BOARD_KEYS: Array[String] = [
	"version", "id", "title", "width", "height", "entities",
	"starts_in_3d", "completion_condition", "art_recipe_id"
]
const BOARD_KEYS: Array[String] = [
	"schema_version", "id", "title", "width", "height", "entities",
	"starts_in_3d", "completion_condition", "art_recipe_id"
]
const ENTITY_KEYS: Array[String] = [
	"id", "kind", "x", "y", "facing", "facing_x", "facing_y",
	"is_word", "word_role", "word_value", "layer", "creation_serial",
	"base_tags", "runtime_tags", "module_metadata"
]


static func list_level_ids() -> Array[StringName]:
	var index_result := _load_index()
	var result: Array[StringName] = []
	if not bool(index_result.get("ok", false)):
		return result
	for entry: Dictionary in index_result["entries"]:
		result.append(StringName(entry["id"]))
	return result


static func load_level(level_id: StringName) -> Dictionary:
	var requested_id := String(level_id)
	if not _is_content_id(requested_id):
		return {"ok": false, "error": "invalid_id"}
	var index_result := _load_index()
	if not bool(index_result.get("ok", false)):
		return index_result
	for entry: Dictionary in index_result["entries"]:
		if entry["id"] != requested_id:
			continue
		var path := CONTENT_DIRECTORY.path_join(String(entry["path"]))
		var parsed := _read_json(path)
		if not bool(parsed.get("ok", false)):
			return parsed
		return parse_definition(parsed["value"], StringName(requested_id))
	return {"ok": false, "error": "unknown_level"}


static func parse_index(value: Variant) -> Dictionary:
	if not value is Dictionary or not _has_only_keys(value, INDEX_KEYS):
		return {"ok": false, "error": "invalid_index_root"}
	var version: Variant = value.get("schema_version")
	var board_values: Variant = value.get("boards")
	if not RuleGridEntity._is_integer(version) or int(version) != INDEX_SCHEMA_VERSION \
		or not board_values is Array or board_values.is_empty():
		return {"ok": false, "error": "invalid_index_schema"}
	var entries: Array[Dictionary] = []
	var seen_ids: Dictionary = {}
	var seen_paths: Dictionary = {}
	for entry_value: Variant in board_values:
		if not entry_value is Dictionary or not _has_only_keys(entry_value, INDEX_ENTRY_KEYS) \
			or entry_value.size() != INDEX_ENTRY_KEYS.size():
			return {"ok": false, "error": "invalid_index_entry"}
		var id_value: Variant = entry_value.get("id")
		var path_value: Variant = entry_value.get("path")
		if not id_value is String or not _is_content_id(id_value) \
			or not path_value is String or not _is_content_path(path_value) \
			or seen_ids.has(id_value) or seen_paths.has(path_value):
			return {"ok": false, "error": "invalid_index_entry"}
		seen_ids[id_value] = true
		seen_paths[path_value] = true
		entries.append({"id": id_value, "path": path_value})
	return {"ok": true, "entries": entries}


static func parse_definition(value: Variant, expected_id: StringName = &"") -> Dictionary:
	if not value is Dictionary:
		return {"ok": false, "error": "invalid_root"}
	var is_new_schema: bool = value.has("schema_version")
	var allowed_keys := BOARD_KEYS if is_new_schema else LEGACY_BOARD_KEYS
	if not _has_only_keys(value, allowed_keys):
		return {"ok": false, "error": "invalid_schema"}
	if is_new_schema and value.has("version"):
		return {"ok": false, "error": "invalid_schema"}
	if not is_new_schema and value.has("schema_version"):
		return {"ok": false, "error": "invalid_schema"}
	var version: Variant = value.get("schema_version") if is_new_schema else value.get("version")
	var id_value: Variant = value.get("id")
	var title_value: Variant = value.get("title")
	if not RuleGridEntity._is_integer(version) or int(version) != BOARD_SCHEMA_VERSION \
		or not id_value is String or not _is_content_id(id_value) \
		or not title_value is String or title_value.strip_edges().is_empty():
		return {"ok": false, "error": "invalid_header"}
	var level_id := StringName(id_value)
	if not expected_id.is_empty() and expected_id != level_id:
		return {"ok": false, "error": "id_mismatch"}
	if is_new_schema:
		for key: String in ["starts_in_3d", "completion_condition", "art_recipe_id"]:
			if not value.has(key):
				return {"ok": false, "error": "invalid_schema"}
	var starts_in_3d: Variant = value.get("starts_in_3d", false)
	var completion_condition: Variant = value.get("completion_condition", COMPLETION_WIN_CONTACT)
	var art_recipe_id: Variant = value.get("art_recipe_id", "")
	if not starts_in_3d is bool \
		or not completion_condition is String \
		or completion_condition != COMPLETION_WIN_CONTACT \
		or not art_recipe_id is String \
		or (not art_recipe_id.is_empty() and not _is_content_id(art_recipe_id)):
		return {"ok": false, "error": "invalid_schema"}
	var entity_values: Variant = value.get("entities")
	if not _is_board_dimension(value.get("width")) \
		or not _is_board_dimension(value.get("height")) \
		or not entity_values is Array:
		return {"ok": false, "error": "invalid_grid"}
	for entity_value: Variant in entity_values:
		if not entity_value is Dictionary or not _has_only_keys(entity_value, ENTITY_KEYS):
			return {"ok": false, "error": "invalid_grid"}
		if not entity_value.has("id") or not entity_value.has("kind") \
			or not entity_value.has("x") or not entity_value.has("y") \
			or not entity_value.has("is_word"):
			return {"ok": false, "error": "invalid_grid"}
	var grid_data := {
		"schema_version": RuleGridState.SERIALIZATION_SCHEMA_VERSION,
		"width": value["width"],
		"height": value["height"],
		"entities": entity_values
	}
	var state := RuleGridState.from_dictionary(grid_data)
	if state == null:
		return {"ok": false, "error": "invalid_grid"}
	var used_creation_serials: Dictionary = {}
	for index: int in range(state.entities.size()):
		var entity: RuleGridEntity = state.entities[index]
		var entity_source: Dictionary = entity_values[index]
		if entity.is_word and entity.kind != entity.word_value:
			return {"ok": false, "error": "word_kind_mismatch"}
		if entity.is_word and not _is_registered_word(entity.word_role, entity.word_value):
			return {"ok": false, "error": "unregistered_word"}
		if not entity.is_word and not OBJECT_CATALOG.has(entity.kind):
			return {"ok": false, "error": "unknown_entity_kind"}
		if entity_source.has("creation_serial"):
			if used_creation_serials.has(entity.creation_serial):
				return {"ok": false, "error": "invalid_grid"}
			used_creation_serials[entity.creation_serial] = true
	for index: int in range(state.entities.size()):
		var entity: RuleGridEntity = state.entities[index]
		var entity_source: Dictionary = entity_values[index]
		if entity_source.has("creation_serial"):
			continue
		var serial := index
		while used_creation_serials.has(serial):
			serial += 1
		entity.creation_serial = serial
		used_creation_serials[serial] = true
	if not _doors_have_valid_boundaries(state):
		return {"ok": false, "error": "invalid_door_boundary"}
	return {
		"ok": true,
		"id": level_id,
		"title": title_value,
		"schema_version": int(version),
		"starts_in_3d": starts_in_3d,
		"completion_condition": completion_condition,
		"art_recipe_id": art_recipe_id,
		"state": state
	}


static func _load_index() -> Dictionary:
	var parsed := _read_json(INDEX_PATH)
	if not bool(parsed.get("ok", false)):
		return parsed
	return parse_index(parsed["value"])


static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "missing_file"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "unreadable_file"}
	var text := file.get_as_text()
	var json := JSON.new()
	if json.parse(text) != OK:
		return {"ok": false, "error": "invalid_json"}
	return {"ok": true, "value": json.data}


static func _is_board_dimension(value: Variant) -> bool:
	return RuleGridEntity._is_integer(value) and int(value) >= 1 and int(value) <= 32


static func _is_registered_word(role: StringName, value: StringName) -> bool:
	match role:
		&"noun":
			return NOUN_CATALOG.has(value)
		&"operator":
			return OPERATOR_CATALOG.has(value)
		&"property":
			return PROPERTY_CATALOG.has(value)
	return false


static func _doors_have_valid_boundaries(state: RuleGridState) -> bool:
	var doors: Array[RuleGridEntity] = []
	var cells: Dictionary = {}
	for entity: RuleGridEntity in state.entities:
		var cell_entities: Array = cells.get(entity.position, [])
		cell_entities.append(entity)
		cells[entity.position] = cell_entities
		if not entity.is_word and entity.kind == &"DOOR":
			var boundary: Variant = entity.module_metadata.get("boundary")
			if not boundary is String or not DOOR_BOUNDARIES.has(boundary):
				return false
			doors.append(entity)
	if doors.is_empty():
		return true
	var valid_door_ids: Dictionary = {}
	for top: int in range(state.height - 2):
		for bottom: int in range(top + 2, state.height):
			for left: int in range(state.width - 2):
				for right: int in range(left + 2, state.width):
					var frame_doors := _frame_doors(cells, left, top, right, bottom)
					if frame_doors.is_empty():
						continue
					for entity_id: String in frame_doors:
						valid_door_ids[entity_id] = true
	for door: RuleGridEntity in doors:
		if not valid_door_ids.has(door.id):
			return false
	return true


static func _frame_doors(
	cells: Dictionary,
	left: int,
	top: int,
	right: int,
	bottom: int
) -> Array[String]:
	var door_ids: Array[String] = []
	for y: int in range(top, bottom + 1):
		for x: int in range(left, right + 1):
			if x != left and x != right and y != top and y != bottom:
				continue
			var cell := Vector2i(x, y)
			var is_corner: bool = (x == left or x == right) and (y == top or y == bottom)
			var has_box := false
			var cell_doors: Array[RuleGridEntity] = []
			for entity: Variant in cells.get(cell, []):
				if not entity is RuleGridEntity or entity.is_word:
					continue
				if entity.kind == &"BOX":
					has_box = true
				elif entity.kind == &"DOOR":
					cell_doors.append(entity)
			if is_corner:
				if not has_box or not cell_doors.is_empty():
					return []
			elif not has_box and cell_doors.is_empty():
				return []
			elif not cell_doors.is_empty():
				if has_box or cell_doors.size() != 1:
					return []
				var expected_side := _boundary_side(cell, left, top, right, bottom)
				for door: RuleGridEntity in cell_doors:
					if String(door.module_metadata.get("boundary", "")) != expected_side:
						return []
					door_ids.append(door.id)
	return door_ids


static func _boundary_side(cell: Vector2i, left: int, top: int, right: int, bottom: int) -> String:
	if cell.y == top:
		return "north"
	if cell.y == bottom:
		return "south"
	if cell.x == left:
		return "west"
	return "east"


static func _is_content_id(value: Variant) -> bool:
	if not value is String or value.is_empty():
		return false
	var id: String = value
	var first := id.unicode_at(0)
	if first < 97 or first > 122:
		return false
	for index: int in range(1, id.length()):
		var codepoint := id.unicode_at(index)
		if not ((codepoint >= 97 and codepoint <= 122) \
			or (codepoint >= 48 and codepoint <= 57) \
			or codepoint == 95 or codepoint == 45):
			return false
	return true


static func _is_content_path(value: Variant) -> bool:
	if not value is String or value.is_empty() or value.begins_with("/") \
		or value.contains("\\") or value.contains(":") or value.contains("~"):
		return false
	if not value.ends_with(".json"):
		return false
	for segment: String in value.split("/"):
		if segment.is_empty() or segment == "." or segment == "..":
			return false
	return true


static func _has_only_keys(value: Dictionary, allowed: Array[String]) -> bool:
	for key: Variant in value.keys():
		if not key is String or not allowed.has(key):
			return false
	return true
