## 인용 비주얼노벨의 이야기 규칙(화면과 분리된 순수 로직). 테스트와 자동 플레이어가 그대로 쓴다.
## 규칙: 선택지=살아있는 각 작품 남주 대사 / 대답=같은 작품의 바로 다음 발화 /
## 평소 서술=선택 비율(+1) 가중 무작위 / 선택 3번마다 가장 덜 고른 작품 제거 / 히로인 묘사도 선택지.
extends RefCounted

const CHOICES_PER_CROSSROAD := 3
const FINAL_CHOICES := 2

var works: Dictionary = {}      # id -> corpus dict
var order: Array = []           # 작품 순서(가~마)
var alive: Array = []
var picks: Dictionary = {}      # id -> 고른 횟수
var used_pairs: Dictionary = {} # id -> {pair index: true}
var used_amb: Dictionary = {}
var used_desc: Dictionary = {}
var rng := RandomNumberGenerator.new()
var queue: Array = []
var choice_count := 0
var since_crossroad := 0
var final_left := -1
var ended := false
var history: Array = []         # 고른 작품 id 순서


func setup(corpora: Array, seed_value: int) -> void:
	rng.seed = seed_value
	for c in corpora:
		works[c.id] = c
		order.append(c.id)
		alive.append(c.id)
		picks[c.id] = 0
		used_pairs[c.id] = {}
		used_amb[c.id] = {}
		used_desc[c.id] = {}
	var first: Dictionary = works[order[0]]
	var opening: Array = first.get("opening", [])
	for op in opening:
		queue.append(_line("narration", first, op.orig, op.ko))
	queue.append({"type": "title", "text": "인용된 사랑", "sub": "모든 문장은 어느 고전의 한 구절입니다"})


## 가중치: 살아있는 작품마다 (고른 횟수 + 1)
static func weights(p: Dictionary, alive_ids: Array) -> Dictionary:
	var w := {}
	for id in alive_ids:
		w[id] = int(p.get(id, 0)) + 1
	return w


static func weighted_pick(w: Dictionary, r: RandomNumberGenerator) -> String:
	var total := 0
	for k in w:
		total += w[k]
	var x := r.randi_range(1, total)
	for k in w:
		x -= w[k]
		if x <= 0:
			return k
	return w.keys()[-1]


## 제거 대상: 가장 덜 고른 작품(동률이면 무작위). 하나만 남았으면 "".
static func least_picked(p: Dictionary, alive_ids: Array, r: RandomNumberGenerator) -> String:
	if alive_ids.size() <= 1:
		return ""
	var lo := 1 << 30
	for id in alive_ids:
		lo = mini(lo, int(p.get(id, 0)))
	var ties: Array = []
	for id in alive_ids:
		if int(p.get(id, 0)) == lo:
			ties.append(id)
	return ties[r.randi_range(0, ties.size() - 1)]


func _line(kind: String, w: Dictionary, orig: String, ko: String, speaker := "") -> Dictionary:
	return {"type": kind, "work": w.id, "slot": w.slot, "title": w.title_ko, "author": w.author,
		"orig": orig, "ko": ko, "lang": w.lang, "speaker": speaker}


func _free_pairs(id: String) -> Array:
	var out: Array = []
	var ps: Array = works[id].pairs
	for i in ps.size():
		if not used_pairs[id].has(i):
			out.append(i)
	return out


func _ambient() -> Dictionary:
	var id := weighted_pick(weights(picks, alive), rng)
	var w: Dictionary = works[id]
	var pool: Array = []
	for i in w.ambient.size():
		if not used_amb[id].has(i):
			pool.append(i)
	if pool.is_empty():
		return {}
	var i2: int = pool[rng.randi_range(0, pool.size() - 1)]
	used_amb[id][i2] = true
	return _line("narration", w, w.ambient[i2].orig, w.ambient[i2].ko)


func _desc_choice() -> Dictionary:
	var opts: Array = []
	for id in alive:
		var w: Dictionary = works[id]
		var pool: Array = []
		for i in w.descriptions.size():
			if not used_desc[id].has(i):
				pool.append(i)
		if pool.is_empty():
			continue
		var i2: int = pool[rng.randi_range(0, pool.size() - 1)]
		var o := _line("desc", w, w.descriptions[i2].orig, w.descriptions[i2].ko)
		o["index"] = i2
		opts.append(o)
	if opts.size() < 2:
		return {}
	return {"type": "choice", "kind": "desc", "prompt": "그녀는 어떤 모습이었나", "options": opts}


func _talk_choice() -> Dictionary:
	var opts: Array = []
	for id in alive:
		var free := _free_pairs(id)
		if free.is_empty():
			continue
		var i: int = free[rng.randi_range(0, free.size() - 1)]
		var w: Dictionary = works[id]
		var pr: Dictionary = w.pairs[i]
		var o := _line("hero", w, pr.hero, pr.hero_ko, "나")
		o["index"] = i
		opts.append(o)
	if opts.is_empty():
		return {}
	return {"type": "choice", "kind": "talk", "prompt": "무슨 말을 할까", "options": opts}


## 다음 사건. 선택지를 받으면 choose()를 불러야 다음으로 간다.
func next_event() -> Dictionary:
	if not queue.is_empty():
		return queue.pop_front()
	if ended:
		return {"type": "end"}
	if final_left == 0:
		return _ending()
	# 한 라운드: 서술 1~2줄 → (가끔) 묘사 선택 → 대화 선택
	var amb := _ambient()
	if not amb.is_empty():
		queue.append(amb)
	if rng.randf() < 0.4:
		var amb2 := _ambient()
		if not amb2.is_empty():
			queue.append(amb2)
	if choice_count % 3 == 1:
		var dc := _desc_choice()
		if not dc.is_empty():
			queue.append(dc)
	var tc := _talk_choice()
	if tc.is_empty():
		queue.append(_ending())
	else:
		queue.append(tc)
	return queue.pop_front()


func choose(ev: Dictionary, idx: int) -> void:
	var o: Dictionary = ev.options[clampi(idx, 0, ev.options.size() - 1)]
	var id: String = o.work
	picks[id] += 1
	history.append(id)
	var w: Dictionary = works[id]
	if ev.kind == "desc":
		used_desc[id][o.index] = true
		return
	used_pairs[id][o.index] = true
	var pr: Dictionary = w.pairs[o.index]
	queue.append(_line("hero", w, pr.hero, pr.hero_ko, "나"))
	queue.append(_line("heroine", w, pr.heroine, pr.heroine_ko, w.heroine))
	choice_count += 1
	since_crossroad += 1
	if final_left > 0:
		final_left -= 1
	elif since_crossroad >= CHOICES_PER_CROSSROAD:
		since_crossroad = 0
		var gone := least_picked(picks, alive, rng)
		if gone != "":
			alive.erase(gone)
			queue.append({"type": "crossroad", "work": gone, "title": works[gone].title_ko,
				"text": "갈림길. 「%s」의 기억이 이야기에서 지워진다." % works[gone].title_ko,
				"ratio": ratio_text()})
		if alive.size() == 1:
			final_left = FINAL_CHOICES


func ratio_text() -> String:
	var parts: PackedStringArray = []
	for id in order:
		parts.append("%s %d%s" % [works[id].title_ko, picks[id], "" if id in alive else "(지워짐)"])
	return " · ".join(parts)


func _ending() -> Dictionary:
	ended = true
	var id: String = alive[0]
	if alive.size() > 1:
		id = weighted_pick(weights(picks, alive), rng)
	var w: Dictionary = works[id]
	return {"type": "ending", "work": id, "title": w.title_ko, "author": w.author,
		"text": "「%s」의 결말로 이어진 사랑" % w.title_ko, "ratio": ratio_text()}
