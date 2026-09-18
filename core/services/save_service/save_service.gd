class_name SaveService
extends Node

const FORMAT_VERSION: int = 1
var current_module: StringName = &""
var global_state: Dictionary = {}
var _modules: Dictionary = {}

func get_module_state(id: StringName) -> Dictionary:
	var record: Dictionary = _modules.get(String(id), {})
	return record.duplicate(true)

func set_module_state(id: StringName, version: int, state: Dictionary) -> void:
	_modules[String(id)] = {"schema_version": version, "state": state.duplicate(true)}

func export_data() -> Dictionary:
	return {"format_version": FORMAT_VERSION, "current_module": String(current_module), "global": global_state.duplicate(true), "modules": _modules.duplicate(true)}

func import_data(data: Dictionary) -> Error:
	if not is_json_safe(data):
		return ERR_INVALID_DATA
	if not _is_version(data.get("format_version")) or int(data["format_version"]) != FORMAT_VERSION:
		return ERR_INVALID_DATA
	if not data.get("current_module") is String or not data.get("global") is Dictionary or not data.get("modules") is Dictionary:
		return ERR_INVALID_DATA
	var records: Dictionary = data["modules"]
	for id: String in records:
		var record: Variant = records[id]
		if id.is_empty() or not record is Dictionary:
			return ERR_INVALID_DATA
		if not _is_version(record.get("schema_version")) or not record.get("state") is Dictionary:
			return ERR_INVALID_DATA
	current_module = StringName(data["current_module"])
	global_state = data["global"].duplicate(true)
	_modules = records.duplicate(true)
	return OK

func save_file(path: String = "user://save.json") -> Error:
	var data: Dictionary = export_data()
	if not is_json_safe(data):
		return ERR_INVALID_DATA
	var temporary: String = path + ".tmp"
	var backup: String = path + ".bak"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		return error
	var had_file: bool = FileAccess.file_exists(path)
	if had_file:
		if FileAccess.file_exists(backup):
			error = DirAccess.remove_absolute(backup)
			if error != OK:
				return error
		error = DirAccess.rename_absolute(path, backup)
		if error != OK:
			return error
	error = DirAccess.rename_absolute(temporary, path)
	if error != OK and had_file:
		DirAccess.rename_absolute(backup, path)
	return error

func load_file(path: String = "user://save.json") -> Error:
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var parser := JSON.new()
	var error: Error = parser.parse(file.get_as_text())
	file.close()
	if error != OK:
		return error
	if not parser.data is Dictionary:
		return ERR_INVALID_DATA
	return import_data(parser.data)

static func is_json_safe(value: Variant, depth: int = 0) -> bool:
	if depth > 64:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_ARRAY:
			for element: Variant in value:
				if not is_json_safe(element, depth + 1):
					return false
			return true
		TYPE_DICTIONARY:
			for key: Variant in value:
				if not key is String or not is_json_safe(value[key], depth + 1):
					return false
			return true
	return false

static func _is_version(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) >= 1.0 and float(value) == floorf(float(value))
