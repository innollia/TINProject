## 원문에서 문단 단위 발화(따옴표 묶음)를 원작 순서대로 뽑는다.
## 전처리와 채점 테스트가 같은 코드를 써서 "원작상 바로 다음 발화"를 보장한다.
extends RefCounted

const QUOTE_RE := "\u201C([^\u201D]+)\u201D|\"([^\"]+)\"|\u300E([^\u300F]+)\u300F"


static func load_raw(path: String) -> String:
	var t := FileAccess.get_file_as_string(path).replace("\r", "")
	if path.ends_with(".txt"):
		var s := t.find("*** START OF")
		s = t.find("\n", s) + 1
		var e := t.find("*** END OF")
		t = t.substr(s, e - s)
	else:
		t = _re_sub(t, "(?s)\\{\\{.*?\\}\\}", "")
		t = _re_sub(t, "\\[\\[(?:[^\\]|]*\\|)?([^\\]]*)\\]\\]", "$1")
		t = _re_sub(t, "'''?|<[^>]+>", "")
		t = _re_sub(t, "(?m)^=+.*?=+\\s*$", "")
	return t


static func _re_sub(t: String, pat: String, rep: String) -> String:
	var r := RegEx.new()
	r.compile(pat)
	return r.sub(t, rep, true)


static func norm(s: String) -> String:
	return _re_sub(s, "\\s+", " ").strip_edges()


## 결과: {utterances:[{u,parts,text,ctx,start,end,gap_before}], narration:[{p,text}]}
## 원문 전체에서 따옴표를 찾고, 같은 문단 안에서 짧은 서술("said she,")로 끊긴 따옴표는
## 한 발화로 묶는다. 발화 번호 u의 순서가 곧 원작 순서다.
static func extract(path: String) -> Dictionary:
	var raw := load_raw(path)
	var q := RegEx.new()
	q.compile(QUOTE_RE)
	var blank := RegEx.new()
	blank.compile("\\n\\s*\\n")
	var merge := path.ends_with(".txt")
	var utt: Array = []
	var prev_end := 0
	for mm in q.search_all(raw):
		var v := mm.get_string(1)
		if v == "":
			v = mm.get_string(2)
		if v == "":
			v = mm.get_string(3)
		v = norm(v)
		var gap := raw.substr(prev_end, mm.get_start() - prev_end)
		if merge and not utt.is_empty() and gap.length() < 90 and blank.search(gap) == null:
			var last: Dictionary = utt[-1]
			last.parts.append(v)
			last.text = " ".join(last.parts)
			last.end = mm.get_end()
		else:
			utt.append({"u": utt.size(), "parts": [v], "text": v, "start": mm.get_start(), "end": mm.get_end(), "gap_before": gap.length(), "pre": norm(gap).right(200)})
		prev_end = mm.get_end()
	for i in utt.size():
		var nxt: int = utt[i + 1].start if i + 1 < utt.size() else raw.length()
		utt[i].ctx = utt[i].pre + " [Q] " + norm(raw.substr(utt[i].end, nxt - utt[i].end)).left(120)
		utt[i].erase("pre")
	# 서술 문단(따옴표 없는 문단)
	var narr: Array = []
	var p := 0
	var last_i := 0
	var pieces: PackedStringArray = []
	for m in blank.search_all(raw):
		pieces.append(raw.substr(last_i, m.get_start() - last_i))
		last_i = m.get_end()
	pieces.append(raw.substr(last_i))
	for piece in pieces:
		var para := norm(piece)
		if para == "":
			continue
		if q.search(para) == null and para.length() >= 30 and para.find("\u300E") < 0 and para.find("\u300F") < 0 and para.find("\u201C") < 0 and para.find("\u201D") < 0:
			narr.append({"p": p, "text": para})
		p += 1
	return {"utterances": utt, "narration": narr}
