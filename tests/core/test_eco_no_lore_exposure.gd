extends GutTest

const MODULE_ROOT: String = "res://modules/sideview_ecosystem"
const SCAN_EXTS: Array[String] = ["gd", "tscn", "tres", "json"]
const SCREEN_NAME: String = "아래의 것"
const BUTTON_LABELS: Array[String] = ["계속", "다시", "나가다", "일어나다"]
const TEXT_SITES: String = "\\b(text|tooltip_text|title|placeholder_text|draw_string|draw_multiline_string|Label|RichTextLabel|set_text)\\b"
const DISPLAY_KEYS: Array[String] = ["title", "text", "desc", "description", "caption", "hint", "subtitle", "lore", "note", "memo", "summary", "epilogue"]
const SCALE_WORDS: String = "\\b(speck|hand|doll|common|tall|colossal|ladder|rung|module_count|scale|pitch_scale|fit_target)\\b"
const DRAW_SITES: String = "\\b(draw_string|draw_multiline_string|set_text|text)\\b"
const LORE_TOKENS: Array[String] = [
	"codex", "journal", "diary", "lore", "chronicle", "bestiary", "logbook", "encyclopedia", "archive_note",
	"recap", "epilogue", "afterword", "ending_summary", "ending_text", "story", "history", "exposition",
	"narration", "caption", "subtitle", "dialog", "dialogue", "speech", "monologue", "memo", "letter",
	"note_entry", "read_note", "unlock_note", "tutorial", "hint_text", "explain",
	"size_hint", "too_small", "too_big", "need_scale", "scale_up", "scale_down", "mismatch_text", "rung_label", "scale_label",
]
const LINEAGE_TOKENS: Array[String] = ["den_stage", "lineage_stage", "lineage_stage_text"]
const WATER_TOKENS: Array[String] = [
	"water", "rainfall", "rain_system", "t_rain", "flood", "fathom", "grit_pool", "dredge", "drown",
	"breath", "swim", "aquatic", "submerge", "oxygen", "buoyan", "wet_friction", "splash",
	"surface_pool", "pool_",
]
const BANNED_ANYWHERE: Array[float] = [1.0, 1.38, 1.3, 1.12, 1.26]
const RUNG_VALUES: Array[float] = [0.05, 0.12, 0.28, 0.65, 1.5, 3.6]


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


func _without_comments(text: String, ext: String) -> String:
	if ext != "gd":
		return text
	var lines: PackedStringArray = text.split("\n")
	var kept: PackedStringArray = []
	for line: String in lines:
		var in_string: bool = false
		var cut: int = -1
		for i: int in line.length():
			var ch: String = line[i]
			if ch == "\"" and (i == 0 or line[i - 1] != "\\"):
				in_string = not in_string
			elif ch == "#" and not in_string:
				cut = i
				break
		kept.append(line if cut < 0 else line.substr(0, cut))
	return "\n".join(kept)


func _segment_words(text: String) -> Array[PackedStringArray]:
	var words: Array[PackedStringArray] = []
	var ident: RegEx = RegEx.create_from_string("[A-Za-z][A-Za-z0-9_]*")
	var camel: RegEx = RegEx.create_from_string("([a-z0-9])([A-Z])")
	for m: RegExMatch in ident.search_all(text):
		words.append(camel.sub(m.get_string(), "$1_$2", true).to_lower().split("_", false))
	return words


func _has_segments(parts: PackedStringArray, token: String) -> bool:
	var needle: PackedStringArray = token.split("_", false)
	for start: int in parts.size() - needle.size() + 1:
		var same: bool = true
		for k: int in needle.size():
			if parts[start + k] != needle[k]:
				same = false
				break
		if same:
			return true
	return false


func _literals_on(line: String) -> PackedStringArray:
	var out: PackedStringArray = []
	var lit: RegEx = RegEx.create_from_string("\"((?:[^\"\\\\]|\\\\.)*)\"")
	for m: RegExMatch in lit.search_all(line):
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


func _core_and_module_files() -> Array[String]:
	var files: Array[String] = _files(MODULE_ROOT.path_join("presentation"), ["gd", "tscn", "tres"])
	files.append_array(_files(MODULE_ROOT.path_join("systems"), ["gd"]))
	files.append_array(_files(MODULE_ROOT.path_join("domain"), ["gd"]))
	var module_script: String = MODULE_ROOT.path_join("module.gd")
	if FileAccess.file_exists(module_script):
		files.append(module_script)
	return files


func test_eco_no_player_text_outside_whitelist() -> void:
	var hits: PackedStringArray = []
	var presentation: Array[String] = _files(MODULE_ROOT.path_join("presentation"), ["gd", "tscn", "tres"])
	var text_sites: RegEx = RegEx.create_from_string(TEXT_SITES)
	var label_type: RegEx = RegEx.create_from_string("\\b(Label|RichTextLabel)\\b")
	var scale_words: RegEx = RegEx.create_from_string(SCALE_WORDS)
	var draw_sites: RegEx = RegEx.create_from_string(DRAW_SITES)
	for path: String in presentation:
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		for i: int in lines.size():
			var line: String = lines[i]
			if text_sites.search(line) != null:
				for literal: String in _literals_on(line):
					var glyph: bool = literal.length() <= 3 and not literal.contains(" ")
					if not BUTTON_LABELS.has(literal) and literal != SCREEN_NAME and not glyph and not literal.begins_with("res://"):
						hits.append("R1 %s:%d \"%s\"" % [path, i + 1, literal])
			if label_type.search(line) != null:
				hits.append("R4 %s:%d" % [path, i + 1])
			if scale_words.search(line) != null and draw_sites.search(line) != null:
				hits.append("R7 %s:%d" % [path, i + 1])
			if line.contains("display_name"):
				hits.append("R5 %s:%d reads display_name" % [path, i + 1])
	for path: String in _core_and_module_files():
		if FileAccess.get_file_as_string(path).contains(SCREEN_NAME):
			hits.append("R2 %s" % path)
	for path: String in _files(MODULE_ROOT.path_join("content"), ["json"]):
		var keys: PackedStringArray = []
		_json_keys(JSON.parse_string(FileAccess.get_file_as_string(path)), keys)
		for key: String in keys:
			if DISPLAY_KEYS.has(key):
				hits.append("R5 %s key %s" % [path, key])
	assert_eq(hits.size(), 0, "player text outside whitelist: " + ", ".join(hits))


func test_eco_manifest_screen_name() -> void:
	var manifest_path: String = MODULE_ROOT.path_join("module_manifest.tres")
	if not FileAccess.file_exists(manifest_path):
		pending("module_manifest.tres does not exist yet (W.5-1 R3)")
		return
	var manifest: Resource = load(manifest_path)
	assert_eq(str(manifest.get("display_name")), SCREEN_NAME, "W.5-1 R3")


func test_eco_button_labels_present() -> void:
	var presentation: Array[String] = _files(MODULE_ROOT.path_join("presentation"), ["gd", "tscn", "tres"])
	if presentation.is_empty():
		pending("presentation/ does not exist yet (W.5-1 R6, plan section 11.0)")
		return
	var joined: String = ""
	for path: String in presentation:
		joined += FileAccess.get_file_as_string(path)
	for label: String in BUTTON_LABELS:
		assert_true(joined.contains(label), "W.5-1 R6 label present: " + label)


func test_eco_no_refilling_lore_device() -> void:
	var hits: PackedStringArray = []
	for path: String in _files(MODULE_ROOT, SCAN_EXTS):
		var text: String = _without_comments(FileAccess.get_file_as_string(path), path.get_extension())
		for parts: PackedStringArray in _segment_words(text):
			for token: String in LORE_TOKENS:
				if _has_segments(parts, token):
					hits.append("A %s %s" % [path, token])
		if text.contains("docs/world"):
			hits.append("F %s" % path)
		var lower: String = text.to_lower()
		for token: String in WATER_TOKENS:
			if lower.contains(token):
				hits.append("I %s %s" % [path, token])
	for path: String in _files(MODULE_ROOT.path_join("presentation"), []):
		var name_parts: PackedStringArray = path.get_file().get_basename().to_lower().split("_", false)
		for token: String in LORE_TOKENS:
			if _has_segments(name_parts, token):
				hits.append("B %s" % path)
	for path: String in _files(MODULE_ROOT.path_join("presentation"), ["gd", "tscn", "tres"]):
		var text: String = FileAccess.get_file_as_string(path)
		for call: String in ["draw_string", "draw_multiline_string", "draw_string_outline"]:
			if text.contains(call):
				hits.append("C %s %s" % [path, call])
		for token: String in LINEAGE_TOKENS:
			if text.contains(token):
				hits.append("E %s %s" % [path, token])
	var audio_manifest: String = MODULE_ROOT.path_join("audio_events.tres")
	if FileAccess.file_exists(audio_manifest) and FileAccess.get_file_as_string(audio_manifest).contains("Voice"):
		hits.append("D Voice bus in audio_events.tres")
	hits.append_array(_numeric_literal_hits())
	assert_eq(hits.size(), 0, "lore devices: " + ", ".join(hits))


func _numeric_literal_hits() -> PackedStringArray:
	var hits: PackedStringArray = []
	var number: RegEx = RegEx.create_from_string("(?<![\\w.])\\d+\\.\\d+(?![\\w.])")
	var scale_line: RegEx = RegEx.create_from_string("(?i)(scale|rung|band|ladder)")
	var core_files: Array[String] = _files(MODULE_ROOT.path_join("domain"), ["gd"])
	core_files.append_array(_files(MODULE_ROOT.path_join("systems"), ["gd"]))
	for path: String in core_files:
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		for i: int in lines.size():
			for m: RegExMatch in number.search_all(lines[i]):
				var value: float = m.get_string().to_float()
				for banned: float in BANNED_ANYWHERE:
					if is_equal_approx(value, banned):
						hits.append("H %s:%d %s" % [path, i + 1, m.get_string()])
				if scale_line.search(lines[i]) != null:
					for rung_value: float in RUNG_VALUES:
						if is_equal_approx(value, rung_value):
							hits.append("H %s:%d rung value %s" % [path, i + 1, m.get_string()])
	return hits
