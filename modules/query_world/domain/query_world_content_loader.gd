class_name QueryWorldContentLoader
extends RefCounted

## case JSON 파일을 읽어 검증하고 목록화한다.
## 새 case는 res://modules/query_world/content/<id>.json 파일 추가만으로 등록된다
## (core 무수정 — 데이터 주도). if/match case 분기를 두지 않는다.

const CONTENT_DIR: String = "res://modules/query_world/content"


static func list_case_files() -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(CONTENT_DIR)
	if dir == null:
		return out
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while not name.is_empty():
		if not dir.current_is_dir() and name.get_extension() == "json":
			out.append("%s/%s" % [CONTENT_DIR, name])
		name = dir.get_next()
	dir.list_dir_end()
	out.sort()  # 결정적 순서
	return out


## 파일 하나를 파싱. 반환: case dict 또는 {} (실패).
static func load_case_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return {}
	var case: Dictionary = parsed
	if not validate_case(case):
		return {}
	return case


## authored case 검증:
## - id 존재
## - fragments 비어있지 않음, 각 fragment id 유일 + search_tags 비어있지 않음
## - completion.required_ids ⊆ fragment ids
## - relations의 to 가 존재하는 fragment
static func validate_case(case: Dictionary) -> bool:
	if String(case.get("id", "")).is_empty():
		return false
	var frags: Array = case.get("fragments", [])
	if frags.is_empty():
		return false
	var ids: Dictionary = {}
	for raw: Variant in frags:
		if not raw is Dictionary:
			return false
		var frag: Dictionary = raw
		var fid: String = String(frag.get("id", ""))
		if fid.is_empty() or ids.has(fid):
			return false  # 빈 id 또는 중복 id
		var tags: Array = frag.get("search_tags", [])
		var has_tag: bool = false
		for t: Variant in tags:
			if not String(t).strip_edges().is_empty():
				has_tag = true
				break
		if not has_tag:
			return false  # search_tags 비어있음
		ids[fid] = true
	# relations dangling ref
	for raw: Variant in frags:
		var frag: Dictionary = raw
		for raw_r: Variant in (frag.get("relations", []) as Array):
			var r: Dictionary = raw_r
			if not ids.has(String(r.get("to", ""))):
				return false
	# required_ids ⊆ fragment ids
	var completion: Dictionary = case.get("completion", {})
	for rid: Variant in (completion.get("required_ids", []) as Array):
		if not ids.has(String(rid)):
			return false
	return true


## 모든 유효 case를 로드. 반환: [case dict], 파일 이름 순.
static func load_all() -> Array:
	var out: Array = []
	for path: String in list_case_files():
		var case: Dictionary = load_case_file(path)
		if not case.is_empty():
			out.append(case)
	return out


## 첫(정렬상 최초) case id. 진입 시 기본 case.
static func first_case_id() -> StringName:
	var all: Array = load_all()
	if all.is_empty():
		return &""
	return StringName(String((all[0] as Dictionary).get("id", "")))
