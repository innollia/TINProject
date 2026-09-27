## 서브에이전트 라벨(label_<id>.json)과 원문 추출 결과를 합쳐 corpus/<id>.json을 만든다.
## 원문에 없는 묘사, 바로 다음 발화가 아닌 쌍은 여기서 버린다.
## 실행: godot --headless --path <proj> -s res://modules/quote_vn/tools/build_corpus.gd -- <라벨폴더>
extends SceneTree

const X := preload("res://modules/quote_vn/core/extract.gd")
const META := {
	"pride": {"slot": "가", "title_ko": "오만과 편견", "title_orig": "Pride and Prejudice", "author": "제인 오스틴", "lang": "en", "hero": "다아시", "heroine": "엘리자베스", "raw": "pride.txt", "url": "https://www.gutenberg.org/ebooks/1342"},
	"jane": {"slot": "나", "title_ko": "제인 에어", "title_orig": "Jane Eyre", "author": "샬럿 브론테", "lang": "en", "hero": "로체스터", "heroine": "제인", "raw": "jane.txt", "url": "https://www.gutenberg.org/ebooks/1260"},
	"persuasion": {"slot": "다", "title_ko": "설득", "title_orig": "Persuasion", "author": "제인 오스틴", "lang": "en", "hero": "웬트워스", "heroine": "앤", "raw": "persuasion.txt", "url": "https://www.gutenberg.org/ebooks/105"},
	"chunhyang": {"slot": "라", "title_ko": "일설 춘향전", "title_orig": "일설 춘향전", "author": "이광수", "lang": "ko", "hero": "이몽룡", "heroine": "춘향", "raw": "chunhyang.wiki", "url": "https://ko.wikisource.org/wiki/일설_춘향전"},
	"dongbaek": {"slot": "마", "title_ko": "동백꽃", "title_orig": "동백꽃", "author": "김유정", "lang": "ko", "hero": "나", "heroine": "점순", "raw": "dongbaek.wiki", "url": "https://ko.wikisource.org/wiki/동백꽃"},
	"bombom": {"slot": "마", "title_ko": "봄봄", "title_orig": "봄·봄", "author": "김유정", "lang": "ko", "hero": "나", "heroine": "점순", "raw": "bombom.wiki", "url": "https://ko.wikisource.org/wiki/봄봄"},
}


func _init() -> void:
	var src: String = OS.get_cmdline_user_args()[0]
	for id in META:
		var lp := src.path_join("label_%s.json" % id)
		if not FileAccess.file_exists(lp):
			continue
		var lab = JSON.parse_string(FileAccess.get_file_as_string(lp))
		if typeof(lab) != TYPE_DICTIONARY:
			print(id, " 라벨 JSON 오류")
			continue
		var m: Dictionary = META[id]
		var raw_path: String = "res://modules/quote_vn/corpus/raw/" + m.raw
		var d := X.extract(raw_path)
		var U: Array = d.utterances
		var rawn := X.norm(X.load_raw(raw_path))
		var narr := {}
		for nr in d.narration:
			narr[int(nr.p)] = nr.text
		var ko: bool = m.lang == "ko"
		var pairs: Array = []
		var seen := {}
		for pr in lab.get("pairs", []):
			var a := int(pr.a)
			var b := int(pr.b)
			if b != a + 1 or a < 0 or b >= U.size() or seen.has(a):
				continue
			seen[a] = true
			pairs.append({"hero_u": a, "hero": U[a].text, "hero_ko": U[a].text if ko else str(pr.get("a_ko", "")),
				"heroine_u": b, "heroine": U[b].text, "heroine_ko": U[b].text if ko else str(pr.get("b_ko", ""))})
		var descs: Array = []
		for ds in lab.get("descriptions", []):
			var o := X.norm(str(ds.get("orig", "")))
			if o.length() >= 8 and rawn.find(o) >= 0:
				descs.append({"orig": o, "ko": o if ko else str(ds.get("ko", ""))})
		var amb: Array = []
		for am in lab.get("ambient", []):
			var p := int(am.get("p", -1))
			if narr.has(p):
				amb.append({"p": p, "orig": narr[p], "ko": narr[p] if ko else str(am.get("ko", ""))})
		var opening: Array = []
		for op in lab.get("opening", []):
			var p2 := int(op.get("p", -1))
			if narr.has(p2):
				opening.append({"p": p2, "orig": narr[p2], "ko": str(op.get("ko", ""))})
		var lab_open: Array = lab.get("opening", [])
		if opening.is_empty() and id == "pride":
			var keys := narr.keys()
			keys.sort()
			for k in keys:
				if str(narr[k]).begins_with("It is a truth universally acknowledged"):
					for j in 2:
						var kk: int = keys[keys.find(k) + j]
						var ko_txt: String = str(lab_open[j].get("ko", "")) if j < lab_open.size() else ""
						opening.append({"p": kk, "orig": narr[kk], "ko": ko_txt})
					break
		var out := m.duplicate()
		out.erase("raw")
		out["id"] = id
		out["raw_file"] = m.raw
		out["pairs"] = pairs
		out["descriptions"] = descs
		out["ambient"] = amb
		out["opening"] = opening
		var f := FileAccess.open("res://modules/quote_vn/corpus/%s.json" % id, FileAccess.WRITE)
		f.store_string(JSON.stringify(out, "\t"))
		print("%s pairs=%d desc=%d amb=%d open=%d" % [id, pairs.size(), descs.size(), amb.size(), opening.size()])
	quit()
