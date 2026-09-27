class_name QueryWorldState
extends RefCounted

## Query World Kit — 순수 도메인 로직.
##
## 세계는 기본적으로 보이지 않는다. 검색어(능동 질의)와 hover(국소 질의)로만
## 파편(fragment)이 조각조각 드러난다. 이 클래스는 씬/노드에 의존하지 않는
## 순수 상태 + 규칙이며 그대로 자동 테스트 가능하다.
##
## Primary Reference: Her Story — 결과 상한 5, 시드 검색어, 노출 추적.
## 원작 자산/사건은 복제하지 않고 시스템 규칙만 가져온다.

const RESULT_CAP: int = 5  # 확정: 매칭이 몇이든 처음 5개만 반환(Her Story 규칙).

## authored (불변) --------------------------------------------------------
var case_id: StringName = &""
var seed_query: String = ""
## fragment_id(String) -> Fragment dict:
##   { "id", "body", "search_tags":[String], "hover_reveals":[{id,span_from,span_to,hidden}], "relations":[{to,kind}] }
var fragments: Dictionary = {}
## 완료 조건 (authored)
var required_ids: Array = []          # 이 파편들을 모두 열람해야 함
var conclusion_query: String = ""     # 그리고 이 결론 질의에 도달해야 완료

## runtime (진행도) --------------------------------------------------------
var query_history: Array = []          # [{raw, matched:[], count, ts}]
var revealed: Dictionary = {}          # fragment_id -> true (한 번이라도 연 파편)
var hover_seen: Dictionary = {}        # hover_reveal_id -> true
var last_opened: String = ""           # 노랑 표시 대상
var concluded: bool = false


# --- 정규화 -------------------------------------------------------------
static func normalize(text: String) -> String:
	return text.strip_edges().to_lower()


# --- 로드 (authored case dict에서 상태 구성) ------------------------------
func load_case(case: Dictionary) -> void:
	case_id = StringName(String(case.get("id", "")))
	seed_query = String(case.get("seed_query", ""))
	fragments.clear()
	for raw: Variant in (case.get("fragments", []) as Array):
		var frag: Dictionary = raw
		var fid: String = String(frag.get("id", ""))
		if fid.is_empty() or fragments.has(fid):
			continue  # 빈/중복 id는 무시 (validation은 loader가 담당)
		fragments[fid] = _sanitize_fragment(fid, frag)
	var completion: Dictionary = case.get("completion", {})
	required_ids = []
	for rid: Variant in (completion.get("required_ids", []) as Array):
		var s: String = String(rid)
		if fragments.has(s) and not required_ids.has(s):
			required_ids.append(s)
	conclusion_query = String(completion.get("conclusion_query", ""))
	reset_runtime()


func _sanitize_fragment(fid: String, frag: Dictionary) -> Dictionary:
	var tags: Array = []
	for t: Variant in (frag.get("search_tags", []) as Array):
		var tag: String = normalize(String(t))
		if not tag.is_empty() and not tags.has(tag):
			tags.append(tag)
	var hovers: Array = []
	var idx: int = 0
	for raw_h: Variant in (frag.get("hover_reveals", []) as Array):
		var h: Dictionary = raw_h
		hovers.append({
			"id": "%s#h%d" % [fid, idx],
			"span_from": int(h.get("span_from", 0)),
			"span_to": int(h.get("span_to", 0)),
			"hidden": String(h.get("hidden", "")),
		})
		idx += 1
	var relations: Array = []
	for raw_r: Variant in (frag.get("relations", []) as Array):
		var r: Dictionary = raw_r
		relations.append({"to": String(r.get("to", "")), "kind": String(r.get("kind", "mentions"))})
	return {
		"id": fid,
		"body": String(frag.get("body", "")),
		"search_tags": tags,
		"hover_reveals": hovers,
		"relations": relations,
	}


func reset_runtime() -> void:
	query_history = []
	revealed = {}
	hover_seen = {}
	last_opened = ""
	concluded = false


# --- QueryEngine --------------------------------------------------------
## 검색어를 매칭 fragment_id 목록으로. 결과 상한 적용, 이력 기록.
## 반환: { "matched":[fragment_id], "count":int(총 매칭 수), "capped":bool, "empty":bool }
func run_query(raw_query: String, timestamp: int = 0) -> Dictionary:
	var q: String = normalize(raw_query)
	var all_matches: Array = []
	if not q.is_empty():
		for fid: String in fragments:
			if _fragment_matches(fragments[fid], q):
				all_matches.append(fid)
	all_matches.sort()  # 결정적 순서 (테스트 가능)
	var total: int = all_matches.size()
	var shown: Array = all_matches.slice(0, RESULT_CAP)
	query_history.append({
		"raw": raw_query,
		"matched": shown.duplicate(),
		"count": total,
		"ts": timestamp,
	})
	return {
		"matched": shown,
		"count": total,
		"capped": total > RESULT_CAP,
		"empty": total == 0,
	}


func _fragment_matches(frag: Dictionary, normalized_query: String) -> bool:
	for tag: String in (frag.get("search_tags", []) as Array):
		# 부분 일치: 태그가 질의를 포함하거나 질의가 태그를 포함
		if tag == normalized_query or tag.contains(normalized_query) or normalized_query.contains(tag):
			return true
	return false


# --- 열람 (focus/selection) ---------------------------------------------
## 파편을 연다. revealed에 추가하고 last_opened(노랑) 갱신.
func open_fragment(fragment_id: String) -> bool:
	if not fragments.has(fragment_id):
		return false
	revealed[fragment_id] = true
	last_opened = fragment_id
	return true


# --- HoverRevealLayer (국소 질의) ---------------------------------------
## hover span의 hidden_text를 노출. hover_seen 기록.
## 반환: hidden 문자열 또는 "" (없음)
func peek_hover(fragment_id: String, hover_id: String) -> String:
	if not fragments.has(fragment_id):
		return ""
	for h: Variant in (fragments[fragment_id].get("hover_reveals", []) as Array):
		var hover: Dictionary = h
		if String(hover.get("id", "")) == hover_id:
			hover_seen[hover_id] = true
			return String(hover.get("hidden", ""))
	return ""


# --- 노출 추적 색 코드 (초록/빨강/노랑) ----------------------------------
## fragment_id -> "revealed"(초록) / "last"(노랑) / "unrevealed"(빨강)
func reveal_status(fragment_id: String) -> StringName:
	if fragment_id == last_opened:
		return &"last"
	if revealed.has(fragment_id):
		return &"revealed"
	return &"unrevealed"


func revealed_count() -> int:
	return revealed.size()


func total_fragments() -> int:
	return fragments.size()


# --- CompletionEvaluator ------------------------------------------------
## required_ids 모두 열람 + 마지막(또는 임의) 결론 질의가 conclusion_query와 매칭 → 완료.
func evaluate_completion(last_raw_query: String) -> bool:
	if concluded:
		return true
	for rid: String in required_ids:
		if not revealed.has(rid):
			return false
	if conclusion_query.is_empty():
		concluded = true  # 결론 질의 없는 case는 required 열람만으로 완료
		return true
	if normalize(last_raw_query) == normalize(conclusion_query):
		concluded = true
	return concluded


# --- 저장 / 로드 (JSON-safe) --------------------------------------------
func save_runtime() -> Dictionary:
	var revealed_list: Array = []
	for k: String in revealed:
		revealed_list.append(k)
	revealed_list.sort()
	var hover_list: Array = []
	for k: String in hover_seen:
		hover_list.append(k)
	hover_list.sort()
	return {
		"case_id": String(case_id),
		"query_history": query_history.duplicate(true),
		"revealed": revealed_list,
		"hover_seen": hover_list,
		"last_opened": last_opened,
		"concluded": concluded,
	}


## 저장된 runtime을 적용. dangling fragment_id는 drop(로그).
## 반환: drop된 stale id 개수 (테스트/진단용)
func load_runtime(data: Dictionary) -> int:
	reset_runtime()
	var dropped: int = 0
	for raw: Variant in (data.get("query_history", []) as Array):
		if raw is Dictionary:
			query_history.append((raw as Dictionary).duplicate(true))
	for raw: Variant in (data.get("revealed", []) as Array):
		var fid: String = String(raw)
		if fragments.has(fid):
			revealed[fid] = true
		else:
			dropped += 1
	for raw: Variant in (data.get("hover_seen", []) as Array):
		hover_seen[String(raw)] = true
	var lo: String = String(data.get("last_opened", ""))
	last_opened = lo if fragments.has(lo) else ""
	concluded = bool(data.get("concluded", false))
	return dropped
