## 자동 채점. 실행:
## godot --headless --path <proj> -s res://modules/quote_vn/tests/grade.gd
## 결과: modules/quote_vn/reports/score.md (점수·실패 목록·100명 플레이 리포트)
extends SceneTree

const X := preload("res://modules/quote_vn/core/extract.gd")
const Story := preload("res://modules/quote_vn/core/story.gd")
const Module := preload("res://modules/quote_vn/module.gd")

var out: PackedStringArray = []
var fails: PackedStringArray = []


func check(ok: bool, what: String) -> bool:
	if not ok:
		fails.append(what)
	return ok


func _init() -> void:
	var corpora: Array = Module.load_corpora()
	out.append("# 인용된 사랑 자동 채점\n")
	out.append("작품 묶음: " + ", ".join(corpora.map(func(c): return "%s %s(쌍 %d·묘사 %d·서술 %d)" % [c.slot, c.title_ko, c.pairs.size(), c.descriptions.size(), c.ambient.size()])))
	var s1 := _test_sources(corpora)
	var s2 := _test_adjacency(corpora)
	var s3 := _test_rules(corpora)
	var s4 := _test_players(corpora, 100)
	var total := (s1 + s2 + s3 + s4) / 4.0
	out.insert(1, "\n## 총점 %.1f / 100\n- 1) 원문 실존 %.1f\n- 2) 바로 다음 대사 %.1f\n- 3) 규칙 단위 테스트 %.1f\n- 4) 자동 플레이어 100명 %.1f\n" % [total, s1, s2, s3, s4])
	if not fails.is_empty():
		out.append("\n## 실패 목록(앞 40개)\n- " + "\n- ".join(fails.slice(0, 40)))
	DirAccess.make_dir_recursive_absolute("res://modules/quote_vn/reports")
	var f := FileAccess.open("res://modules/quote_vn/reports/score.md", FileAccess.WRITE)
	f.store_string("\n".join(out))
	print("SCORE total=%.1f src=%.1f adj=%.1f rules=%.1f play=%.1f fails=%d" % [total, s1, s2, s3, s4, fails.size()])
	quit(0 if total >= 99.9 else 1)


## 1) 모든 원문 문장이 raw 원문에 실제로 있는가
func _test_sources(corpora: Array) -> float:
	var n := 0
	var ok := 0
	for c in corpora:
		var raw := X.norm(X.load_raw("res://modules/quote_vn/corpus/raw/" + c.raw_file))
		var texts: Array = []
		for p in c.pairs:
			texts.append(p.hero)
			texts.append(p.heroine)
		for d in c.descriptions:
			texts.append(d.orig)
		for a in c.ambient:
			texts.append(a.orig)
		for o in c.get("opening", []):
			texts.append(o.orig)
		for t in texts:
			n += 1
			# 영어 발화는 끊긴 따옴표를 ' '로 이었으므로 조각별로 확인
			var all_found := true
			for piece in _pieces(c, str(t)):
				if raw.find(piece) < 0:
					all_found = false
			if check(all_found, "%s 원문에 없음: %s" % [c.id, str(t).left(60)]):
				ok += 1
	out.append("\n## 1) 원문 실존: %d / %d" % [ok, n])
	return 100.0 * ok / maxi(1, n)


func _pieces(c: Dictionary, t: String) -> Array:
	# 추출 때 조각을 이어 붙인 발화는 추출 결과의 parts로 쪼개 확인한다
	return [t] if c.lang == "ko" else Array(_split_parts(c, t))


var _parts_cache := {}


func _split_parts(c: Dictionary, t: String) -> Array:
	if not _parts_cache.has(c.id):
		var m := {}
		for u in X.extract("res://modules/quote_vn/corpus/raw/" + c.raw_file).utterances:
			m[u.text] = u.parts
		_parts_cache[c.id] = m
	return _parts_cache[c.id].get(t, [t])


## 2) 히로인의 대답이 원작 발화 순서상 바로 다음인가(원문을 다시 추출해 대조)
func _test_adjacency(corpora: Array) -> float:
	var n := 0
	var ok := 0
	for c in corpora:
		var U: Array = X.extract("res://modules/quote_vn/corpus/raw/" + c.raw_file).utterances
		for p in c.pairs:
			n += 1
			var a := int(p.hero_u)
			var b := int(p.heroine_u)
			var good: bool = b == a + 1 and b < U.size() and U[a].text == p.hero and U[b].text == p.heroine
			if check(good, "%s 쌍 %d>%d 이 원작상 인접 발화가 아님" % [c.id, a, b]):
				ok += 1
	out.append("## 2) 바로 다음 대사: %d / %d" % [ok, n])
	return 100.0 * ok / maxi(1, n)


## 3) 가중치 규칙·지우기 규칙 단위 테스트
func _test_rules(corpora: Array) -> float:
	var t := 0
	var ok := 0
	var r := RandomNumberGenerator.new()
	r.seed = 7
	# 가중치 = 고른 횟수 + 1
	t += 1
	var w := Story.weights({"a": 3, "b": 0, "c": 1}, ["a", "b", "c"])
	if check(w == {"a": 4, "b": 1, "c": 2}, "가중치 계산 틀림 %s" % str(w)):
		ok += 1
	# 지워진 작품은 가중치에서 빠진다
	t += 1
	if check(not Story.weights({"a": 3, "b": 0}, ["a"]).has("b"), "지워진 작품이 가중치에 남음"):
		ok += 1
	# 뽑기 분포가 가중치 비율을 따른다(4:1:2 → 57%/14%/29%)
	t += 1
	var cnt := {"a": 0, "b": 0, "c": 0}
	for i in 20000:
		cnt[Story.weighted_pick(w, r)] += 1
	var fa: float = cnt.a / 20000.0
	var fb: float = cnt.b / 20000.0
	if check(absf(fa - 4.0 / 7.0) < 0.02 and absf(fb - 1.0 / 7.0) < 0.02, "가중 뽑기 분포 틀림 %s" % str(cnt)):
		ok += 1
	# 가장 덜 고른 작품이 지워진다
	t += 1
	if check(Story.least_picked({"a": 2, "b": 0, "c": 1}, ["a", "b", "c"], r) == "b", "최소 선택 작품 판정 틀림"):
		ok += 1
	# 동률이면 동률 중 하나
	t += 1
	var tie := Story.least_picked({"a": 1, "b": 1, "c": 3}, ["a", "b", "c"], r)
	if check(tie in ["a", "b"], "동률 처리 틀림 %s" % tie):
		ok += 1
	# 하나 남으면 더 지우지 않는다
	t += 1
	if check(Story.least_picked({"a": 0}, ["a"], r) == "", "마지막 작품까지 지움"):
		ok += 1
	# 실제 이야기: 선택 3번마다 가장 덜 고른 작품이 지워지고, 지워진 작품은 다시 나오지 않는다
	if corpora.size() >= 2:
		t += 1
		var st := Story.new()
		st.setup(corpora, 99)
		var target: String = corpora[0].id
		var guard := 0
		var good := true
		while guard < 2000:
			guard += 1
			var e := st.next_event()
			if e.type in ["end", "ending"]:
				break
			if e.type == "crossroad":
				good = good and e.work != target
			if e.type == "choice":
				for o in e.options:
					good = good and o.work in st.alive
				var pick := 0
				for i in e.options.size():
					if e.options[i].work == target:
						pick = i
				st.choose(e, pick)
			if e.type in ["narration", "hero", "heroine"]:
				good = good and e.work in st.alive or e.type != "narration"
		if check(good and target in st.alive, "항상 고른 작품이 지워졌거나 지운 작품이 다시 나옴"):
			ok += 1
		# 선택지는 살아있는 작품마다 하나씩 남주 대사
		t += 1
		var st2 := Story.new()
		st2.setup(corpora, 5)
		var e2 := {}
		for i in 50:
			e2 = st2.next_event()
			if e2.type == "choice" and e2.kind == "talk":
				break
		var ws: Array = e2.options.map(func(o): return o.work)
		if check(ws.size() == st2.alive.size() and ws.size() == corpora.size(), "첫 대화 선택지가 작품마다 하나가 아님 %s" % str(ws)):
			ok += 1
	out.append("## 3) 규칙 단위 테스트: %d / %d" % [ok, t])
	return 100.0 * ok / maxi(1, t)


## 4) 자동 플레이어 N명이 무작위로 고른다
func _test_players(corpora: Array, players: int) -> float:
	var endings := {}
	var paths := {}
	var breaks := 0
	var lengths: Array = []
	var removed_orders := {}
	for pl in players:
		var st := Story.new()
		st.setup(corpora, 1000 + pl)
		var r := RandomNumberGenerator.new()
		r.seed = 5000 + pl
		var sig: PackedStringArray = []
		var seen_lines := {}
		var prev := {}
		var steps := 0
		var broken := ""
		var removed: PackedStringArray = []
		while steps < 3000:
			steps += 1
			var e := st.next_event()
			if e.type == "end":
				break
			if e.type in ["narration", "hero", "heroine", "desc"]:
				if str(e.ko).strip_edges() == "" or str(e.orig).strip_edges() == "":
					broken = "빈 대사(%s)" % e.work
				var key: String = e.type + e.orig
				if e.type != "hero" and seen_lines.has(key):
					broken = "같은 문장 반복(%s)" % e.work
				seen_lines[key] = true
			if e.type == "heroine" and not (prev.get("type", "") == "hero" and prev.get("work", "") == e.work):
				broken = "히로인 대답 앞에 같은 작품 남주 대사가 없음"
			if e.type == "choice":
				if e.options.is_empty():
					broken = "빈 선택지"
					break
				var i := r.randi_range(0, e.options.size() - 1)
				sig.append(e.options[i].slot)
				st.choose(e, i)
			if e.type == "crossroad":
				removed.append(e.title)
			if e.type == "ending":
				endings[e.title] = int(endings.get(e.title, 0)) + 1
			prev = e
		if steps >= 3000:
			broken = "끝나지 않음"
		if not st.ended:
			broken = broken if broken != "" else "결말 없이 끝남"
		if broken != "":
			breaks += 1
			fails.append("플레이어 %d: %s" % [pl, broken])
		paths["".join(sig)] = true
		removed_orders[" > ".join(removed)] = true
		lengths.append(sig.size())
	var lo: int = lengths.min()
	var hi: int = lengths.max()
	out.append("\n## 4) 자동 플레이어 %d명" % players)
	out.append("- 끊김 없이 끝난 플레이: %d / %d" % [players - breaks, players])
	out.append("- 서로 다른 선택 경로: %d / %d" % [paths.size(), players])
	out.append("- 서로 다른 작품 지움 순서: %d" % removed_orders.size())
	out.append("- 선택 횟수: 최소 %d, 최대 %d" % [lo, hi])
	var er: PackedStringArray = []
	for k in endings:
		er.append("「%s」 %d명" % [k, endings[k]])
	out.append("- 결말 분포: " + ", ".join(er))
	# 점수: 끊김 없음 60 + 경로 다양성 20 + 결말 다양성 20
	var ending_goal := mini(corpora.size(), 4)
	check(endings.size() >= ending_goal, "결말 종류가 %d개뿐" % endings.size())
	check(paths.size() >= players * 0.9, "경로 다양성 부족 %d" % paths.size())
	return 60.0 * (players - breaks) / players + 20.0 * minf(1.0, paths.size() / (players * 0.9)) + 20.0 * minf(1.0, float(endings.size()) / ending_goal)
