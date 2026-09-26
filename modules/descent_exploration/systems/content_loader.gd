class_name DescentContentLoader
extends RefCounted

const STRATA_DIR: String = "res://modules/descent_exploration/authored/strata"

var strata: Array[Dictionary] = []
var errors: Array[Dictionary] = []
var rejected: Array[String] = []


func load_dir(path: String = STRATA_DIR) -> bool:
	strata.clear()
	errors.clear()
	rejected.clear()
	var files: PackedStringArray = DirAccess.get_files_at(path)
	var parsed: Array[Dictionary] = []
	var all_ids: Array[String] = []
	for file_name: String in files:
		if not file_name.ends_with(".json"):
			continue
		var file_id: String = file_name.get_basename()
		all_ids.append(file_id)
		var text: String = FileAccess.get_file_as_string(path.path_join(file_name))
		var data: Variant = JSON.parse_string(text)
		if not data is Dictionary:
			var broken: Array[Dictionary] = [{"rule": 0, "stratum": file_id, "key": "root", "message": "R0 %s.root: not a JSON object" % file_id}]
			_reject(file_id, broken)
			continue
		parsed.append({"file_id": file_id, "data": data})
	parsed.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return DescentContentLoader.by_index(a, b))
	var facts: Array[String] = []
	var sites: Array[String] = []
	var indices: Array[int] = []
	for entry: Dictionary in parsed:
		var file_id: String = entry["file_id"]
		var data: Dictionary = entry["data"]
		var context: Dictionary = {"strata": all_ids.duplicate(), "facts": facts.duplicate(), "sites": sites.duplicate()}
		var found: Array[Dictionary] = DescentContentValidator.validate(data, file_id, context)
		if found.is_empty() and indices.has(int(data["index"])):
			found.append({"rule": 3, "stratum": file_id, "key": "index", "message": "R3 %s.index: another stratum already uses index %d" % [file_id, int(data["index"])]})
		if not found.is_empty():
			_reject(file_id, found)
			continue
		indices.append(int(data["index"]))
		strata.append(data)
		for site: Variant in data["sites"]:
			var site_entry: Dictionary = site
			sites.append(String(site_entry["id"]))
			var fact: String = String(site_entry.get("grants_fact", ""))
			if not fact.is_empty() and not facts.has(fact):
				facts.append(fact)
	return errors.is_empty()


func count() -> int:
	return strata.size()


func ids() -> Array[String]:
	var out: Array[String] = []
	for data: Dictionary in strata:
		out.append(String(data["id"]))
	return out


func has_stratum(id: String) -> bool:
	return index_of(id) >= 0


func index_of(id: String) -> int:
	for position: int in strata.size():
		if String(strata[position]["id"]) == id:
			return position
	return -1


func get_stratum(id: String) -> Dictionary:
	var position: int = index_of(id)
	return strata[position] if position >= 0 else {}


func first_id() -> String:
	return String(strata[0]["id"]) if not strata.is_empty() else ""


func id_at_or_after(index: int) -> String:
	for data: Dictionary in strata:
		if int(data["index"]) >= index:
			return String(data["id"])
	return String(strata[strata.size() - 1]["id"]) if not strata.is_empty() else ""


func authored_index(id: String) -> int:
	var data: Dictionary = get_stratum(id)
	return int(data.get("index", -1)) if not data.is_empty() else -1


func _reject(file_id: String, found: Array[Dictionary]) -> void:
	rejected.append(file_id)
	for error: Dictionary in found:
		errors.append(error)
		push_warning(String(error["message"]))


static func by_index(a: Dictionary, b: Dictionary) -> bool:
	var left: Variant = (a["data"] as Dictionary).get("index", 0)
	var right: Variant = (b["data"] as Dictionary).get("index", 0)
	var left_index: float = float(left) if (left is int or left is float) else 0.0
	var right_index: float = float(right) if (right is int or right is float) else 0.0
	if left_index == right_index:
		return String(a["file_id"]) < String(b["file_id"])
	return left_index < right_index
