## 전처리 후보 생성기: 작품별로 "남주 발화 → 바로 다음 히로인 발화" 후보쌍과
## 히로인 묘사·평소 서술 후보를 뽑아 서브에이전트 검수용 텍스트로 쓴다.
## 실행: godot --headless --path <proj> -s res://modules/quote_vn/tools/prep.gd -- <출력폴더>
extends SceneTree

const QvnExtract := preload("res://modules/quote_vn/core/extract.gd")

const WORKS := {
	"pride": {"raw": "pride.txt", "hero": "Darcy", "heroine": "Elizabeth|Eliza|Lizzy", "look": "eyes|face|figure|smile|looked|countenance|colour"},
	"jane": {"raw": "jane.txt", "hero": "Rochester", "heroine": "Jane|\\bI (said|replied|answered|asked|returned)|said I", "look": "plain|little|pale|face|eyes|dress|my hair"},
	"persuasion": {"raw": "persuasion.txt", "hero": "Wentworth", "heroine": "Anne", "look": "bloom|faded|face|eyes|looked|complexion|pretty"},
	"chunhyang": {"raw": "chunhyang.wiki", "hero": "도령|도련님|몽룡", "heroine": "춘향", "look": "얼굴|눈|머리|치마|자태|고운|아름|태도"},
	"dongbaek": {"raw": "dongbaek.wiki", "hero": ".", "heroine": "점순", "look": "얼굴|눈|점순이|손|몸"},
	"bombom": {"raw": "bombom.wiki", "hero": ".", "heroine": "점순", "look": "키|얼굴|점순이|눈|몸"},
}


func _rx(p: String) -> RegEx:
	var r := RegEx.new()
	r.compile(p)
	return r


func _init() -> void:
	var out: String = OS.get_cmdline_user_args()[0]
	for id in WORKS:
		var w: Dictionary = WORKS[id]
		var d := QvnExtract.extract("res://modules/quote_vn/corpus/raw/" + w.raw)
		var U: Array = d.utterances
		var hero := _rx(w.hero)
		var her := _rx(w.heroine)
		var look := _rx(w.look)
		var lines: PackedStringArray = ["# 작품 " + id + "  발화 총 " + str(U.size())]
		lines.append("## 후보쌍 (A=남주 추정, B=바로 다음 발화, 히로인 추정)")
		var n := 0
		# 대화 덩어리(문단 간격 2 이하로 이어진 발화들) 단위로 두 사람 이름이 다 나오면 후보
		var runs: Array = []
		var cur: Array = [0]
		for i in range(1, U.size()):
			if U[i].gap_before <= 400:
				cur.append(i)
			else:
				runs.append(cur)
				cur = [i]
		runs.append(cur)
		var good: Array = []
		for r in runs:
			var joined := ""
			for i in r:
				joined += U[i].ctx + " "
			if r.size() >= 2 and (id in ["bombom", "dongbaek"] or (hero.search(joined) and her.search(joined))):
				good.append(r)
		var step := maxi(1, good.size() / 25)
		for gi in range(0, good.size(), step):
			var r2: Array = good[gi]
			for j in range(r2.size() - 1):
				var a: Dictionary = U[r2[j]]
				var b: Dictionary = U[r2[j] + 1]
				if a.text.length() < 6 or a.text.length() > 350 or b.text.length() > 350:
					continue
				lines.append("PAIR %d>%d\n A: %s\n   ctx: %s\n B: %s\n   ctx: %s" % [a.u, b.u, a.text, a.ctx, b.text, b.ctx])
				n += 1
				if j >= 5:
					break
			if n >= 110:
				break
		lines.append("## 히로인 묘사 후보 (서술 문단 p)")
		n = 0
		for nr in d.narration:
			if her.search(nr.text) and look.search(nr.text) and nr.text.length() < 700:
				lines.append("DESC p=%d: %s" % [nr.p, nr.text])
				n += 1
				if n >= 30:
					break
		lines.append("## 평소 서술 후보")
		n = 0
		for k in range(0, d.narration.size(), maxi(1, d.narration.size() / 60)):
			var nr2: Dictionary = d.narration[k]
			if nr2.text.length() < 400:
				lines.append("AMB p=%d: %s" % [nr2.p, nr2.text])
				n += 1
		if id == "pride":
			lines.append("## 첫머리")
			for k in 3:
				lines.append("OPEN p=%d: %s" % [d.narration[k].p, d.narration[k].text])
		var f := FileAccess.open(out.path_join("cand_" + id + ".txt"), FileAccess.WRITE)
		f.store_string("\n".join(lines))
		print(id, " utt=", U.size())
	quit()
