extends GutTest

const MODULE_ROOT: String = "res://modules/sideview_ecosystem"
const SCAN_EXTS: Array[String] = ["gd", "tscn", "tres", "json"]
const ID_TOKENS: Array[String] = [
	"water", "rainfall", "rain_system", "t_rain", "flood", "fathom", "grit_pool", "dredge", "drown",
	"breath", "swim", "aquatic", "submerge", "oxygen", "buoyan", "wet_friction", "splash",
	"surface_pool", "pool_",
]
const KO_TOKENS: Array[String] = ["수위", "침수", "익사", "호흡", "잠수", "수중", "강수", "물속", "물기", "수면", "부력"]
const JSON_KEYS: Array[String] = ["flood", "flood_ceiling_px", "flood_floor_px", "max_depth_px", "wet", "drowned", "aquatic_only"]
const STATE_FIELDS: Array[String] = ["breath_left", "head_underwater", "submerge_limit_px"]


func _collect(dir_path: String, out: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if not entry.begins_with("."):
			var path: String = dir_path.path_join(entry)
			if dir.current_is_dir():
				_collect(path, out)
			else:
				out.append(path)
		entry = dir.get_next()
	dir.list_dir_end()


func _module_files(exts: Array[String]) -> Array[String]:
	var all: Array[String] = []
	_collect(MODULE_ROOT, all)
	var picked: Array[String] = []
	for path: String in all:
		if exts.is_empty() or exts.has(path.get_extension()):
			picked.append(path)
	return picked


func _scan(tokens: Array[String], lower: bool) -> PackedStringArray:
	var hits: PackedStringArray = []
	for path: String in _module_files(SCAN_EXTS):
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		for i: int in lines.size():
			var line: String = lines[i].to_lower() if lower else lines[i]
			for token: String in tokens:
				if line.contains(token):
					hits.append("%s:%d %s" % [path, i + 1, token])
	return hits


func _walk_json(value: Variant, path: String, hits: PackedStringArray) -> void:
	if value is Dictionary:
		for key: Variant in (value as Dictionary).keys():
			if JSON_KEYS.has(str(key)):
				hits.append("%s key %s" % [path, key])
			_walk_json((value as Dictionary)[key], path, hits)
	elif value is Array:
		for item: Variant in value:
			_walk_json(item, path, hits)
	elif value is String:
		if (value as String).to_lower().contains("dredge"):
			hits.append("%s value %s" % [path, value])


func test_eco_no_water_systems() -> void:
	var hits: PackedStringArray = _scan(ID_TOKENS, true)
	assert_eq(hits.size(), 0, "water identifiers: " + ", ".join(hits))


func test_eco_no_water_korean_tokens() -> void:
	var hits: PackedStringArray = _scan(KO_TOKENS, false)
	assert_eq(hits.size(), 0, "water words: " + ", ".join(hits))


func test_eco_no_water_file_names() -> void:
	var all: Array[String] = []
	_collect(MODULE_ROOT, all)
	var hits: PackedStringArray = []
	for path: String in all:
		var relative: String = path.trim_prefix(MODULE_ROOT).to_lower()
		for token: String in ID_TOKENS:
			if relative.contains(token):
				hits.append("%s %s" % [path, token])
	assert_eq(hits.size(), 0, "water file names: " + ", ".join(hits))


func test_eco_no_water_content_keys() -> void:
	var hits: PackedStringArray = []
	for path: String in _module_files(["json"]):
		if not path.contains("/content/"):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		_walk_json(parsed, path, hits)
	assert_eq(hits.size(), 0, "water content keys: " + ", ".join(hits))


func test_eco_no_water_state_fields() -> void:
	var objects: Array[Object] = [EcoWorldState.new(), EcoBodyRung.new(), EcoTransitionState.new()]
	var hits: PackedStringArray = []
	for obj: Object in objects:
		for prop: Dictionary in obj.get_property_list():
			if STATE_FIELDS.has(str(prop["name"])):
				hits.append(str(prop["name"]))
	assert_eq(hits.size(), 0, "water state fields: " + ", ".join(hits))
