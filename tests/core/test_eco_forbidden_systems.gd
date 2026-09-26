extends GutTest

const MODULE_ROOT: String = "res://modules/sideview_ecosystem"
const FORBIDDEN_FILES: Array[String] = [
	"inventory.gd", "item.gd", "tool.gd", "key.gd", "karma.gd", "reputation.gd", "minimap.gd", "hud.gd",
	"map_generator.gd", "trading.gd", "dialogue.gd", "subtitle.gd", "quest.gd", "objective_tracker.gd",
	"crafting.gd", "shop.gd", "rain_system.gd", "world_state_store.gd", "axis_view.gd", "axis_policy.gd",
]
const FORBIDDEN_FILE_PREFIXES: Array[String] = ["water_", "flood_", "breath_", "drown", "swim", "dredge"]
const INVENTORY_SEGMENTS: Array[String] = [
	"inventory", "item", "items", "tool", "tools", "loot", "pickup", "keyring", "trade", "trading",
	"shop", "vendor", "currency", "coin", "craft",
]
const KARMA_SEGMENTS: Array[String] = ["karma", "reputation", "score", "unlock", "threshold", "progress"]
const KARMA_JSON_KEYS: Array[String] = ["count", "threshold", "progress", "requires", "key", "unlock"]
const IMAGE_EXTS: Array[String] = ["png", "jpg", "jpeg", "webp", "bmp", "svg", "ttf", "otf", "aseprite", "kra"]
const HUD_NODE_TYPES: Array[String] = ["Label", "RichTextLabel", "ProgressBar", "TextureProgressBar", "TextureRect", "ItemList", "Tree"]
const MAP_NOUNS: Array[String] = ["room", "map", "level", "layout", "dungeon"]
const RNG_CALLS: Array[String] = ["randi(", "randf(", "randomize(", "RandomNumberGenerator.new("]
const NODE_LOOKUPS: Array[String] = ["get_node(", "find_child(", "get_tree(", "/root"]
const CONTENT_ID_PATTERNS: Array[String] = [
	"^(filter_bed|ash_terrace|bone_shelf|seed_vault)_[0-9]{2}$",
	"^reg_[a-z_]+$",
	"^arc_[a-z_]+$",
	"^(shelter|den|salt_bed|salt_dust_bed|collapse_floor|narrow_cradle|gap|wall|step|drop|plate)_[a-z]{2}_[0-9]{2}(_[a-z0-9]+)?$",
	"^fix\\.[a-z_]+$",
	"^place\\.[a-z_]+$",
]


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


func _files(root: String, exts: Array[String]) -> Array[String]:
	var all: Array[String] = []
	_collect(root, all)
	var picked: Array[String] = []
	for path: String in all:
		if exts.is_empty() or exts.has(path.get_extension().to_lower()):
			picked.append(path)
	return picked


func _segments(text: String) -> PackedStringArray:
	var out: PackedStringArray = []
	var ident: RegEx = RegEx.create_from_string("[A-Za-z][A-Za-z0-9_]*")
	var camel: RegEx = RegEx.create_from_string("([a-z0-9])([A-Z])")
	for m: RegExMatch in ident.search_all(text):
		var word: String = camel.sub(m.get_string(), "$1_$2", true).to_lower()
		for part: String in word.split("_", false):
			out.append(part)
	return out


func _string_literals(text: String) -> PackedStringArray:
	var out: PackedStringArray = []
	var lit: RegEx = RegEx.create_from_string("\"((?:[^\"\\\\\\n]|\\\\.)*)\"")
	for m: RegExMatch in lit.search_all(text):
		out.append(m.get_string(1))
	return out


func _json_keys(value: Variant, out: PackedStringArray) -> void:
	if value is Dictionary:
		for key: Variant in (value as Dictionary).keys():
			out.append(str(key))
			_json_keys((value as Dictionary)[key], out)
	elif value is Array:
		for item: Variant in value:
			_json_keys(item, out)


func test_eco_no_forbidden_systems() -> void:
	var hits: PackedStringArray = []
	var all: Array[String] = []
	_collect(MODULE_ROOT, all)
	for path: String in all:
		var file_name: String = path.get_file().to_lower()
		if FORBIDDEN_FILES.has(file_name):
			hits.append(path)
		for prefix: String in FORBIDDEN_FILE_PREFIXES:
			if file_name.begins_with(prefix):
				hits.append(path)
	assert_eq(hits.size(), 0, "forbidden files: " + ", ".join(hits))


func test_eco_no_inventory_or_tool_system() -> void:
	var hits: PackedStringArray = []
	for path: String in _files(MODULE_ROOT, ["gd", "tscn", "tres"]):
		for segment: String in _segments(FileAccess.get_file_as_string(path)):
			if INVENTORY_SEGMENTS.has(segment):
				hits.append("%s %s" % [path, segment])
	assert_eq(hits.size(), 0, "inventory/tool identifiers: " + ", ".join(hits))


func test_eco_no_karma_counter() -> void:
	var hits: PackedStringArray = []
	for path: String in _files(MODULE_ROOT, ["gd", "tscn", "tres"]):
		for segment: String in _segments(FileAccess.get_file_as_string(path)):
			if KARMA_SEGMENTS.has(segment):
				hits.append("%s %s" % [path, segment])
	for path: String in _files(MODULE_ROOT.path_join("content"), ["json"]):
		var keys: PackedStringArray = []
		_json_keys(JSON.parse_string(FileAccess.get_file_as_string(path)), keys)
		for key: String in keys:
			if KARMA_JSON_KEYS.has(key):
				hits.append("%s key %s" % [path, key])
	assert_eq(hits.size(), 0, "karma-like counters: " + ", ".join(hits))


func test_eco_no_image_files() -> void:
	var hits: PackedStringArray = []
	var all: Array[String] = []
	_collect(MODULE_ROOT, all)
	for path: String in all:
		if IMAGE_EXTS.has(path.get_extension().to_lower()):
			hits.append(path)
	assert_eq(hits.size(), 0, "image files: " + ", ".join(hits))


func test_eco_no_hud_nodes() -> void:
	var entry_scene: String = MODULE_ROOT.path_join("entry.tscn")
	if not FileAccess.file_exists(entry_scene):
		pending("entry.tscn does not exist yet (presentation gated by plan section 11.0)")
		return
	var hits: PackedStringArray = []
	var scenes: Array[String] = [entry_scene]
	scenes.append_array(_files(MODULE_ROOT.path_join("presentation"), ["tscn"]))
	for path: String in scenes:
		for node_type: String in HUD_NODE_TYPES:
			if FileAccess.get_file_as_string(path).contains("type=\"%s\"" % node_type):
				hits.append("%s %s" % [path, node_type])
	assert_eq(hits.size(), 0, "HUD nodes: " + ", ".join(hits))


func test_eco_no_map_generation() -> void:
	var hits: PackedStringArray = []
	for path: String in _files(MODULE_ROOT, ["gd"]):
		var text: String = FileAccess.get_file_as_string(path)
		var ident: RegEx = RegEx.create_from_string("[A-Za-z][A-Za-z0-9_]*")
		for m: RegExMatch in ident.search_all(text):
			var word: String = m.get_string().to_lower()
			if word.contains("procgen") or word.contains("wfc"):
				hits.append("%s %s" % [path, word])
			if word.contains("generate"):
				for noun: String in MAP_NOUNS:
					if word.contains(noun):
						hits.append("%s %s" % [path, word])
		for call: String in RNG_CALLS:
			if text.contains(call):
				hits.append("%s %s" % [path, call])
	var terrain_write: RegEx = RegEx.create_from_string("terrain(\\[[^\\]]*\\]\\s*=[^=]|\\.(set|append|push_back|resize|fill|insert)\\()")
	for path: String in _files(MODULE_ROOT, ["gd"]):
		if path.ends_with("/systems/region_loader.gd"):
			continue
		if terrain_write.search(FileAccess.get_file_as_string(path)) != null:
			hits.append("%s writes terrain outside the loader" % path)
	assert_eq(hits.size(), 0, "map generation: " + ", ".join(hits))


func test_eco_no_content_id_in_core() -> void:
	var patterns: Array[RegEx] = []
	for source: String in CONTENT_ID_PATTERNS:
		patterns.append(RegEx.create_from_string(source))
	var hits: PackedStringArray = []
	var core_files: Array[String] = _files(MODULE_ROOT.path_join("domain"), ["gd"])
	core_files.append_array(_files(MODULE_ROOT.path_join("systems"), ["gd"]))
	for path: String in core_files:
		var text: String = FileAccess.get_file_as_string(path)
		for literal: String in _string_literals(text):
			for pattern: RegEx in patterns:
				if pattern.search(literal) != null:
					hits.append("%s \"%s\"" % [path, literal])
		for lookup: String in NODE_LOOKUPS:
			if text.contains(lookup):
				hits.append("%s %s" % [path, lookup])
	assert_eq(hits.size(), 0, "content ids or node lookups in core: " + ", ".join(hits))
