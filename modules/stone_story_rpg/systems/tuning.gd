class_name StoneStoryTuning
extends RefCounted

## 모든 밸런스 수치의 단일 정본. 코드에 리터럴로 남는 튜닝값은 없다.

const PATH := "res://modules/stone_story_rpg/content/tuning/"

var combat: Dictionary = {}
var economy: Dictionary = {}
var generation: Dictionary = {}
var star_bands: Dictionary = {}
var signature: String = ""


func load_all() -> Error:
	combat = _read("combat.json")
	economy = _read("economy.json")
	generation = _read("generation.json")
	star_bands = _read("star_bands.json")
	if combat.is_empty() or economy.is_empty() or generation.is_empty() or star_bands.is_empty():
		return ERR_FILE_CANT_READ
	signature = _signature()
	return OK


func _read(file_name: String) -> Dictionary:
	var path: String = PATH + file_name
	if not FileAccess.file_exists(path):
		push_error("StoneStoryTuning: missing " + path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("StoneStoryTuning: cannot open " + path)
		return {}
	var txt: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("StoneStoryTuning: not a dict " + path)
		return {}
	return parsed


func _signature() -> String:
	return str(StoneStoryCore.mix(
			StoneStoryCore.mix(
					StoneStoryCore.text_hash(JSON.stringify(combat)),
					StoneStoryCore.text_hash(JSON.stringify(economy))),
			StoneStoryCore.mix(
					StoneStoryCore.text_hash(JSON.stringify(generation)),
					StoneStoryCore.text_hash(JSON.stringify(star_bands)))))


func c(key: String) -> Variant:
	if not combat.has(key):
		push_error("StoneStoryTuning: combat key missing -> " + key)
		return 0
	return combat[key]


func cf(key: String) -> float:
	return float(c(key))


func ci(key: String) -> int:
	return int(c(key))


func stat_effective(value: int) -> float:
	return StoneStoryCore.effective(value, cf("knee_a"), cf("knee_b"), cf("slope_b"), cf("slope_c"))


func scaling_normalizer() -> float:
	return StoneStoryCore.normalizer(cf("knee_a"), cf("knee_b"), cf("slope_b"), cf("slope_c"))


func hp_max(vitality: int) -> int:
	return maxi(1, floori(cf("hp_base") + stat_effective(vitality) * cf("hp_per_vitality")))


func focus_max(focus_stat: int) -> int:
	return maxi(1, floori(cf("focus_base") + stat_effective(focus_stat) * cf("focus_per_mind")))


func stamina_max(grit: int) -> int:
	return maxi(1, floori(cf("stamina_base") + stat_effective(grit) * cf("stamina_per_grit")))


func max_weight(toughness: int) -> int:
	return maxi(1, floori(stat_effective(toughness) * cf("weight_per_toughness")))


func focus_slots(focus_stat: int, steps: Array) -> int:
	var n: int = 1
	for s in steps:
		if focus_stat >= int(s):
			n += 1
	return n


func xp_to_next(level: int) -> int:
	return maxi(1, floori(cf("xp_base") * pow(cf("xp_growth"), maxi(0, level - 1))))


func e(key: String) -> Variant:
	if not economy.has(key):
		push_error("StoneStoryTuning: economy key missing -> " + key)
		return 0
	return economy[key]


func boost_cost(times_done: int) -> int:
	return int(e("boost_base")) * (times_done + 1)


func band_of(level: int) -> Dictionary:
	for b in generation["bands"]:
		if level >= int(b["lo"]) and level <= int(b["hi"]):
			return b
	return generation["bands"][0]


func tier_value(base: int, level: int) -> int:
	var b: Dictionary = band_of(level)
	var pair: Array = star_bands["bands"][b["id"]]
	var lo: int = int(b["lo"])
	var hi: int = int(b["hi"])
	if hi <= lo:
		return floori(base * float(pair[0]))
	var t: float = float(level - lo) / float(hi - lo)
	return maxi(1, floori(base * lerpf(float(pair[0]), float(pair[1]), t)))
