extends SceneTree

## tools/procedural_contract_dump.gd — owner W9.
##
## MODE 1 (introspection) walks the real global class registry and the real
## source files of core/procedural and core/worldstate and prints the actual
## public API. The machine is the source of truth, not CONTRACT.md.
##
## MODE 2 (plan validation) scans Kit plans for Procedural*/WorldState* symbols
## and buckets every one of them. MISSING and SHAPE_MISMATCH are hard failures.
##
## No Input., no InputMap, no /root, no autoload, no service locator, no scene
## tree node. Everything comes from ProjectSettings, DirAccess, FileAccess,
## RegEx and ResourceLoader.

const PLAN_FILES: Array[String] = [
	"res://plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md",
	"res://plans/kits/07_PHYSICS_PUZZLE_PLATFORMER_KIT.md",
	"res://plans/kits/08_DESCENT_EXPLORATION_KIT.md",
]
const CORE_DIRS: Array[String] = ["res://core/procedural", "res://core/worldstate"]
const CONTRACT_FILES: Array[String] = [
	"res://core/procedural/CONTRACT.md",
	"res://core/worldstate/CONTRACT.md",
]
const SYMBOL_PREFIXES: Array[String] = ["Procedural", "WorldState"]

const BUCKET_OK := "OK"
const BUCKET_MISSING := "MISSING"
const BUCKET_SHAPE := "SHAPE_MISMATCH"
const BUCKET_NEGATED := "OK_NEGATED"
const BUCKET_OPEN := "OK_OPEN_QUESTION"

const NEGATION_MARKERS: Array[String] = [
	"없다", "없음", "없는", "없어", "없으", "않", "금지", "폐기", "아니", "오직", "예외",
	"does not exist", "no such", "forbidden", "prohibited", "discarded",
	"never", "not available", "not present",
]
const OPEN_QUESTION_HEADINGS: Array[String] = [
	"open question", "열린 질문", "미결", "미해결", "미정",
]
const FILE_EXTENSIONS: Array[String] = [
	"gd", "uid", "tscn", "tres", "json", "md", "cfg", "godot", "import", "txt",
]
const TYPE_ALIASES: Dictionary = {
	"string": "String", "stringname": "StringName", "node_path": "NodePath",
	"bool": "bool", "int": "int", "float": "float", "vector2": "Vector2",
	"variant": "Variant",
}

var _failures: int = 0
var _plans: Array[String] = []
var _dump_only: bool = false
var _scan_only: bool = false


func _initialize() -> void:
	_read_arguments()
	var classes: Dictionary = _collect_classes()
	if not _scan_only:
		_print_api(classes)
		_print_doc_drift(classes)
	if not _dump_only:
		_validate_plans(classes)
	if _failures > 0:
		print("")
		print("FAILURES: %d" % _failures)
		quit(1)
		return
	print("")
	print("CLEAN: %d plan(s) scanned, 0 MISSING, 0 SHAPE_MISMATCH" % _plans.size())
	quit(0)


func _rule() -> String:
	return "=".repeat(78)


func _read_arguments() -> void:
	_plans = PLAN_FILES.duplicate()
	for raw: String in OS.get_cmdline_args():
		if raw.begins_with("--plan="):
			_plans.append(raw.substr(7))
		elif raw == "--dump":
			_dump_only = true
		elif raw == "--scan":
			_scan_only = true


# ── collection ──────────────────────────────────────────────────────────────

func _collect_classes() -> Dictionary:
	var paths: Dictionary = {}
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		var path: String = String(entry.get("path", ""))
		if _is_core_path(path):
			paths[String(entry.get("class", ""))] = path
	for path: String in _walk_gd(CORE_DIRS):
		var cls: String = _class_name_of(path)
		if cls != "" and not paths.has(cls):
			paths[cls] = path
	var parsed: Dictionary = {}
	for cls: String in paths.keys():
		var data: Dictionary = _parse_script(String(paths[cls]))
		data["loadable"] = ResourceLoader.exists(String(paths[cls]))
		parsed[cls] = data
	return parsed


func _is_core_path(path: String) -> bool:
	for dir: String in CORE_DIRS:
		if path.begins_with(dir):
			return true
	return false


func _walk_gd(roots: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for root: String in roots:
		out.append_array(_walk_gd_in(root))
	out.sort()
	return out


func _walk_gd_in(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		var full: String = dir_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				out.append_array(_walk_gd_in(full))
		elif entry.ends_with(".gd"):
			out.append(full)
		entry = dir.get_next()
	dir.list_dir_end()
	return out


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _class_name_of(path: String) -> String:
	for raw: String in _read_text(path).split("\n"):
		var line: String = raw.strip_edges()
		if line.begins_with("class_name "):
			return line.substr(11).strip_edges().split(" ")[0]
		if line.begins_with("extends ") or line.begins_with("const "):
			break
	return ""


# ── MODE 1: introspection ───────────────────────────────────────────────────

func _parse_script(path: String) -> Dictionary:
	var data: Dictionary = {
		"path": path,
		"class_name": _class_name_of(path),
		"extends": "",
		"consts": {},
		"enums": {},
		"vars": [],
		"methods": [],
		"inner": [],
		"loadable": false,
	}
	var re_const: RegEx = RegEx.new()
	re_const.compile("^const\\s+([A-Za-z_]\\w*)\\s*(?:\\[[^\\]]*\\])?\\s*(?::\\s*([^=]+?))?\\s*=")
	var re_enum: RegEx = RegEx.new()
	re_enum.compile("^enum\\s+([A-Za-z_]\\w*)\\s*\\{([^}]*)\\}")
	var re_var: RegEx = RegEx.new()
	re_var.compile("^var\\s+([A-Za-z_]\\w*)\\s*(\\[[^\\]]*\\])?\\s*(?::\\s*([A-Za-z_][\\w\\.]*))?")
	var re_func: RegEx = RegEx.new()
	re_func.compile("^(static\\s+)?func\\s+([A-Za-z_]\\w*)\\s*\\(([^)]*)\\)\\s*(?:->\\s*([A-Za-z_][\\w\\.\\[\\]]*))?")
	var re_inner: RegEx = RegEx.new()
	re_inner.compile("^class\\s+([A-Za-z_]\\w*)")
	for raw: String in _read_text(path).split("\n"):
		var line: String = raw.strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		if String(data["extends"]) == "" and line.begins_with("extends "):
			data["extends"] = line.substr(8).strip_edges()
		var m: RegExMatch = re_const.search(line)
		if m != null:
			(data["consts"] as Dictionary)[m.get_string(1)] = _clean_type(m.get_string(2))
			continue
		m = re_enum.search(line)
		if m != null:
			var names: Array[String] = []
			for piece: String in m.get_string(2).split(","):
				var key: String = piece.strip_edges().split("=")[0].strip_edges()
				if key != "":
					names.append(key)
			(data["enums"] as Dictionary)[m.get_string(1)] = names
			continue
		m = re_inner.search(line)
		if m != null:
			(data["inner"] as Array).append(String(data["class_name"]) + "." + m.get_string(1))
			continue
		m = re_func.search(line)
		if m != null:
			(data["methods"] as Array).append({
				"name": m.get_string(2),
				"static": m.get_string(1) != "",
				"args": _parse_params(m.get_string(3)),
				"return_type": _clean_type(m.get_string(4)),
			})
			continue
		m = re_var.search(line)
		if m != null:
			if m.get_string(1).begins_with("_"):
				continue
			(data["vars"] as Array).append({"name": m.get_string(1), "type": _clean_type(m.get_string(3))})
	return data


func _parse_params(raw: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var re: RegEx = RegEx.new()
	re.compile("^([A-Za-z_]\\w*)\\s*(?:\\[[^\\]]*\\])?\\s*(?::\\s*([A-Za-z_][\\w\\.]*))?")
	for part: String in _split_top_level(raw):
		var piece: String = part.strip_edges()
		if piece == "":
			continue
		var m: RegExMatch = re.search(piece)
		if m == null:
			continue
		var after: String = piece.substr(m.get_end())
		out.append({
			"name": m.get_string(1),
			"type": _clean_type(m.get_string(2)),
			"has_default": after.contains("="),
		})
	return out


func _split_top_level(raw: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var depth: int = 0
	var current: String = ""
	var index: int = 0
	while index < raw.length():
		var ch: String = raw[index]
		if ch == "[" or ch == "(" or ch == "{":
			depth += 1
		elif ch == "]" or ch == ")" or ch == "}":
			depth = maxi(depth - 1, 0)
		if ch == "," and depth == 0:
			out.append(current)
			current = ""
		else:
			current += ch
		index += 1
	if current.strip_edges() != "":
		out.append(current)
	return out


func _clean_type(raw: String) -> String:
	var text: String = raw.strip_edges()
	if text == "":
		return ""
	return TYPE_ALIASES.get(text.to_lower(), text)


func _count_required(method: Dictionary) -> int:
	var required: int = 0
	for arg: Dictionary in method["args"]:
		if not bool(arg["has_default"]):
			required += 1
	return required


func _print_api(classes: Dictionary) -> void:
	print(_rule())
	print("MODE 1 - AUTHORITATIVE API (read from the engine, not from CONTRACT.md)")
	print(_rule())
	for cls: String in classes.keys():
		var data: Dictionary = classes[cls]
		print("")
		print("-- %s (%s) extends %s%s" % [
			cls, data["path"], data["extends"],
			"" if bool(data["loadable"]) else "  [LOAD FAILED]",
		])
		for enum_name: String in (data["enums"] as Dictionary).keys():
			print("   enum %s { %s }" % [enum_name, ", ".join(data["enums"][enum_name])])
		for const_name: String in (data["consts"] as Dictionary).keys():
			print("   const %s: %s" % [const_name, data["consts"][const_name]])
		for entry: Dictionary in data["vars"]:
			print("   var %s: %s" % [entry["name"], entry["type"]])
		for method: Dictionary in data["methods"]:
			var parts: PackedStringArray = PackedStringArray()
			for arg: Dictionary in method["args"]:
				var text: String = String(arg["name"])
				if String(arg["type"]) != "":
					text += ": " + String(arg["type"])
				if bool(arg["has_default"]):
					text += " = <default>"
				parts.append(text)
			var ret: String = String(method["return_type"])
			print("   %sfunc %s(%s)%s  [min %d, max %d]" % [
				"static " if bool(method["static"]) else "",
				method["name"], ", ".join(parts),
				"" if ret == "" else " -> " + ret,
				_count_required(method),
				(method["args"] as Array).size(),
			])
		for inner: String in data["inner"]:
			print("   inner class %s" % inner)


func _print_doc_drift(classes: Dictionary) -> void:
	var re_section: RegEx = RegEx.new()
	re_section.compile("──\\s*([A-Za-z_]\\w*)\\s*\\(")
	var re_decl: RegEx = RegEx.new()
	re_decl.compile("^(?:static\\s+)?(?:func|const|var)\\s+([A-Za-z_]\\w*)")
	var found: int = 0
	var documented: Dictionary = {}
	for path: String in CONTRACT_FILES:
		var owner_class: String = ""
		for raw: String in _read_text(path).split("\n"):
			var line: String = raw.strip_edges()
			var section: RegExMatch = re_section.search(line)
			if section != null:
				owner_class = section.get_string(1)
				documented[owner_class] = true
				continue
			var is_decl: bool = line.begins_with("func ") or line.begins_with("const ") \
				or line.begins_with("var ") or line.begins_with("static func ")
			if owner_class == "" or not is_decl:
				continue
			var decl: RegExMatch = re_decl.search(line)
			if decl == null or not classes.has(owner_class):
				continue
			if not _symbol_exists(classes[owner_class], decl.get_string(1)):
				found += 1
				print("INFO DOC_DRIFT %s documents %s.%s, engine has no such member" % [
					path.get_file(), owner_class, decl.get_string(1),
				])
	for cls: String in classes.keys():
		if not documented.has(cls):
			found += 1
			print("INFO DOC_DRIFT class %s exists in code but appears in no CONTRACT.md table" % cls)
	if found == 0:
		print("INFO DOC_DRIFT none: the CONTRACT.md tables and the code agree")


func _symbol_exists(data: Dictionary, name: String) -> bool:
	if (data["consts"] as Dictionary).has(name) or _method_of(data, name) != null:
		return true
	for entry: Dictionary in data["vars"]:
		if String(entry["name"]) == name:
			return true
	return false


# ── lookups over the introspected API ───────────────────────────────────────

func _method_of(data: Dictionary, name: String) -> Variant:
	for method: Dictionary in data["methods"]:
		if String(method["name"]) == name:
			return method
	return null


func _has_member_anywhere(classes: Dictionary, name: String) -> bool:
	for cls: String in classes.keys():
		if _symbol_exists(classes[cls], name):
			return true
		for inner: String in classes[cls]["inner"]:
			if inner.ends_with("." + name):
				return true
	return false


func _is_class_name(classes: Dictionary, name: String) -> bool:
	return classes.has(name) or _has_member_anywhere(classes, name)


# ── MODE 2: plan validation ─────────────────────────────────────────────────

func _validate_plans(classes: Dictionary) -> void:
	print("")
	print(_rule())
	print("MODE 2 - PLAN VALIDATION")
	print(_rule())
	var counts: Dictionary = {"ok": 0, "negated": 0, "open": 0}
	for path: String in _plans:
		if not FileAccess.file_exists(path):
			print("FAIL MISSING_PLAN %s does not exist" % path)
			_failures += 1
			continue
		var text: String = _read_text(path)
		var open_from: int = _open_question_from(text)
		var label: String = path.get_file()
		print("")
		print("-- %s" % label)
		var line_number: int = 0
		for raw: String in text.split("\n"):
			line_number += 1
			if raw.strip_edges() == "":
				continue
			for finding: Dictionary in _scan_unit(raw, classes):
				counts = _report(label, finding, classes, open_from, line_number, counts)
	print("")
	print("summary: OK=%d OK_NEGATED=%d OK_OPEN_QUESTION=%d FAIL=%d" % [
		counts["ok"], counts["negated"], counts["open"], _failures,
	])


func _report(
	label: String, finding: Dictionary, classes: Dictionary,
	open_from: int, line_number: int, counts: Dictionary
) -> Dictionary:
	var bucket: String = String(finding["bucket"])
	var detail: String = "%s %s:%d %s" % [bucket, label, line_number, finding["text"]]
	if bucket == BUCKET_MISSING or bucket == BUCKET_SHAPE:
		print("FAIL " + detail)
		_failures += 1
	elif bucket == BUCKET_NEGATED:
		print("NOTE " + detail + "  (plan marks this name as not existing / forbidden)")
		counts["negated"] += 1
	elif bucket == BUCKET_OPEN:
		print("NOTE " + detail + "  (inside the plan's own Open Questions section)")
		counts["open"] += 1
	else:
		counts["ok"] += 1
	return counts


func _open_question_from(text: String) -> int:
	var line_number: int = 0
	for raw: String in text.split("\n"):
		line_number += 1
		var line: String = raw.strip_edges().to_lower()
		if not line.begins_with("#"):
			continue
		for heading: String in OPEN_QUESTION_HEADINGS:
			if line.contains(heading):
				return line_number
	return -1


func _is_negated(unit: String) -> bool:
	var lowered: String = unit.to_lower()
	for marker: String in NEGATION_MARKERS:
		if lowered.contains(marker.to_lower()):
			return true
	return false


func _scan_unit(unit: String, classes: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var negated: bool = _is_negated(unit)
	var seen: Dictionary = {}

	var re_class: RegEx = RegEx.new()
	re_class.compile("(?<![A-Za-z0-9_])(?:%s)[A-Za-z0-9_]*" % "|".join(SYMBOL_PREFIXES))
	var class_hits: Array[RegExMatch] = re_class.search_all(unit)
	if class_hits.is_empty():
		return out

	# A plan states an API as a list of adjacent code spans: `Class.a / b / c`.
	# A bare name only counts as a member claim when its own list run also names
	# a Procedural*/WorldState* class. Without this gate, prose and parameter
	# lists ("`phase_speed 12.0`는 ...", "1.0 /s", "`/root`") read as API calls.
	var trusted: PackedByteArray = _trusted_mask(unit)
	var re_dot_call: RegEx = RegEx.new()
	re_dot_call.compile("(?<=[\\s,·→)])\\.[ \t]*([A-Za-z_]\\w*)[ \t]*\\(")
	var re_slash: RegEx = RegEx.new()
	re_slash.compile("(?<=[ \t])/[ \t]*`?[ \t]*([a-z_]\\w*)")

	for m: RegExMatch in class_hits:
		var token: String = m.get_string()
		var rest: String = unit.substr(m.get_end())
		if not classes.has(token):
			if not seen.has(token):
				seen[token] = true
				out.append({
					"bucket": BUCKET_NEGATED if negated else BUCKET_MISSING,
					"text": "`%s` is not a class in core" % token,
				})
			continue
		var head: Variant = _constructor_call(token, rest, classes)
		if head != null:
			var call: Dictionary = head
			var ctor_key: String = "c" + token + str(call["args"])
			if not seen.has(ctor_key):
				seen[ctor_key] = true
				out.append(_judge(classes, token, "", call, negated))
		var member: Dictionary = _explicit_member(rest)
		if not member.is_empty():
			var key: String = "e" + token + String(member["name"])
			if not seen.has(key):
				seen[key] = true
				out.append(_judge(classes, token, String(member["name"]), member, negated))

	for m: RegExMatch in re_dot_call.search_all(unit):
		var name: String = m.get_string(1)
		if name == "new" or _is_class_name(classes, name) or FILE_EXTENSIONS.has(name):
			continue
		if not _in_code(trusted, m.get_start(1)):
			continue
		var key: String = "d" + name
		if seen.has(key):
			continue
		seen[key] = true
		var arity: Array = _call_args(unit, m.get_end() - name.length())
		out.append(_judge_any(classes, name, arity, negated))

	for m: RegExMatch in re_slash.search_all(unit):
		var name: String = m.get_string(1)
		if FILE_EXTENSIONS.has(name) or _is_class_name(classes, name):
			continue
		if not _in_code(trusted, m.get_start(1)):
			continue
		var key: String = "s" + name
		if seen.has(key):
			continue
		seen[key] = true
		out.append(_judge_any(classes, name, [], negated))

	return out


func _spans(unit: String) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var cursor: int = 0
	while true:
		var open: int = unit.find("`", cursor)
		if open < 0:
			break
		var close: int = unit.find("`", open + 1)
		if close < 0:
			break
		out.append(Vector2i(open + 1, close))
		cursor = close + 1
	return out


func _trusted_mask(unit: String) -> PackedByteArray:
	var mask: PackedByteArray = PackedByteArray()
	mask.resize(unit.length())
	var re_class: RegEx = RegEx.new()
	re_class.compile("(?:%s)[A-Za-z0-9_]*" % "|".join(SYMBOL_PREFIXES))
	var re_gap: RegEx = RegEx.new()
	re_gap.compile("^[ \\t]*,?[ \\t]*/[ \\t]*$")
	var run: Array[Vector2i] = []
	var run_has_class: bool = false
	var previous_end: int = -1
	for span: Vector2i in _spans(unit):
		var continues: bool = previous_end >= 0 \
			and re_gap.search(unit.substr(previous_end, span.x - previous_end)) != null
		if not continues and not run.is_empty():
			if run_has_class:
				_paint(mask, run)
			run = []
			run_has_class = false
		if re_class.search(unit.substr(span.x, span.y - span.x)) != null:
			run_has_class = true
		run.append(span)
		previous_end = span.y
	if run_has_class:
		_paint(mask, run)
	return mask


func _paint(mask: PackedByteArray, run: Array[Vector2i]) -> void:
	for span: Vector2i in run:
		for index: int in range(span.x, mini(span.y, mask.size())):
			mask[index] = 1


func _in_code(mask: PackedByteArray, position: int) -> bool:
	return position >= 0 and position < mask.size() and mask[position] == 1


func _explicit_member(rest: String) -> Dictionary:
	var re: RegEx = RegEx.new()
	re.compile("^[ \t]*\\.([A-Za-z_]\\w*)([ \t]*\\(([^)]*)\\))?")
	var m: RegExMatch = re.search(rest)
	if m == null or m.get_string(1) == "new":
		return {}
	return {
		"name": m.get_string(1),
		"args": _plan_args(m.get_string(3)) if m.get_string(2) != "" else [],
		"has_args": m.get_string(2) != "",
	}


func _constructor_call(token: String, rest: String, classes: Dictionary) -> Variant:
	var trimmed: String = rest.lstrip(" \t")
	if not trimmed.begins_with("(") or _method_of(classes[token], "_init") == null:
		return null
	var re: RegEx = RegEx.new()
	re.compile("^\\(([^)]*)\\)")
	var found: RegExMatch = re.search(trimmed)
	if found == null:
		return null
	return {"name": "_init", "args": _plan_args(found.get_string(1)), "has_args": true}


func _call_args(text: String, from_index: int) -> Array:
	var index: int = text.find("(", from_index)
	if index < 0:
		return []
	var depth: int = 0
	var start: int = index + 1
	var cursor: int = index
	while cursor < text.length():
		var ch: String = text[cursor]
		if ch == "(":
			depth += 1
		elif ch == ")":
			depth -= 1
			if depth == 0:
				return _plan_args(text.substr(start, cursor - start))
		cursor += 1
	return []


func _plan_args(raw: String) -> Array:
	var out: Array = []
	if raw.strip_edges() == "":
		return out
	var re: RegEx = RegEx.new()
	re.compile("^([A-Za-z_]\\w*)\\s*(?:\\[[^\\]]*\\])?\\s*(?::\\s*([A-Za-z_][\\w\\.]*))?")
	for part: String in raw.split(","):
		var piece: String = part.strip_edges()
		if piece == "":
			continue
		var m: RegExMatch = re.search(piece)
		if m == null:
			out.append({"name": "?", "type": "", "has_default": true, "variadic": true})
			continue
		var after: String = piece.substr(m.get_end()).strip_edges()
		out.append({
			"name": m.get_string(1),
			"type": _clean_type(m.get_string(2)),
			"has_default": after.contains("="),
			"variadic": after.begins_with("...") or after.begins_with("…"),
		})
	return out


func _judge(classes: Dictionary, token: String, member: String, call: Dictionary, negated: bool) -> Dictionary:
	var data: Dictionary = classes[token]
	if member == "":
		return {"bucket": BUCKET_OK, "text": "`%s` exists" % token}
	var found: Variant = _method_of(data, member)
	if found == null and (data["consts"] as Dictionary).has(member):
		found = {"name": member, "args": [], "return_type": "", "is_const": true}
	if found == null:
		return {
			"bucket": BUCKET_NEGATED if negated else BUCKET_MISSING,
			"text": "`%s.%s` does not exist" % [token, member],
		}
	var reason: String = _mismatch(found, call)
	if reason == "":
		return {"bucket": BUCKET_OK, "text": "`%s.%s` matches" % [token, member]}
	return {
		"bucket": BUCKET_NEGATED if negated else BUCKET_SHAPE,
		"text": "`%s.%s` %s" % [token, member, reason],
	}


func _judge_any(classes: Dictionary, name: String, args: Array, negated: bool) -> Dictionary:
	for cls: String in classes.keys():
		var data: Dictionary = classes[cls]
		if (data["consts"] as Dictionary).has(name):
			return {"bucket": BUCKET_OK, "text": "`%s` matches a const on %s" % [name, cls]}
		var found: Variant = _method_of(data, name)
		if found == null:
			continue
		var reason: String = _mismatch(found, {"args": args, "has_args": not args.is_empty()})
		if reason == "":
			return {"bucket": BUCKET_OK, "text": "`%s` matches a method on %s" % [name, cls]}
		return {
			"bucket": BUCKET_NEGATED if negated else BUCKET_SHAPE,
			"text": "`%s` %s" % [name, reason],
		}
	return {
		"bucket": BUCKET_NEGATED if negated else BUCKET_MISSING,
		"text": "`%s` does not exist on any core/procedural or core/worldstate class" % name,
	}


func _mismatch(found: Variant, call: Dictionary) -> String:
	if not bool(call.get("has_args", false)) or not (found is Dictionary):
		return ""
	var engine: Dictionary = found
	if engine.has("is_const"):
		return ""
	var plan_args: Array = call["args"]
	if plan_args.is_empty():
		return ""
	for arg: Dictionary in plan_args:
		if bool(arg["variadic"]):
			return ""
	var engine_args: Array = engine["args"]
	var required: int = _count_required(engine)
	var count: int = plan_args.size()
	if count < required or count > engine_args.size():
		return "expects [%d..%d] args, plan passes %d" % [required, engine_args.size(), count]
	for index: int in range(mini(count, engine_args.size())):
		var planned: String = String(plan_args[index]["type"])
		var actual: String = String(engine_args[index]["type"])
		if planned == "" or actual == "" or planned == "Variant" or actual == "Variant":
			continue
		if planned == actual:
			continue
		if (planned == "int" and actual == "float") or (planned == "float" and actual == "int"):
			continue
		if (planned == "String" and actual == "StringName") or (planned == "StringName" and actual == "String"):
			continue
		return "arg %d ('%s') declared '%s' but engine declares '%s'" % [
			index + 1, plan_args[index]["name"], planned, actual,
		]
	return ""
