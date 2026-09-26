class_name StoneStoryCombat
extends RefCounted

## 데미지 타입은 없다. 무기의 데미지는 **단일 정수**이고,
## 개체 간 상호작용은 4-속성(다리/놀랍다/틀림/동그라미) 4-사이클 상성이 만든다.
## 스탯 9개와 요구치/스케일링은 남는다. 그것은 "이 무기를 쓸 자격"의 문제다.

const STATUSES: Array[String] = ["bleed", "poison", "frost"]
const STATUS_DEBUFF: Dictionary = {
	"bleed": "bleed_stagger",
	"poison": "poison_dot",
	"frost": "chill",
}
const STATUS_FRAMES: Dictionary = {"bleed": 22, "poison": 300, "frost": 240}


## 1~2단계. 양손은 요구치 판정에만 쓰인다.
static func requirement_report(weapon: Dictionary, stats: Dictionary, two_hand_divisor: float) -> Dictionary:
	var two_handed: bool = str(weapon.get("handedness", "one")) == "two"
	var unmet: Array[String] = []
	var effective_stats: Dictionary = {}
	for stat in stats:
		var v: int = int(stats[stat])
		effective_stats[stat] = float(v) * two_hand_divisor if two_handed else float(v)
	for stat in weapon.get("requirement", {}):
		var req: int = int(weapon["requirement"][stat])
		if float(effective_stats.get(stat, 0.0)) < float(req):
			unmet.append(str(stat))
	return {"unmet": unmet, "met": unmet.is_empty(), "effective": effective_stats}


## 3단계.
static func scaling_ratio(weapon: Dictionary, eff_stats: Dictionary, tuning: StoneStoryTuning) -> float:
	var sum_w: float = 0.0
	var factor: float = 0.0
	for stat in weapon.get("scaling", {}):
		var w: float = float(weapon["scaling"][stat])
		sum_w += w
		factor += tuning.stat_effective(int(eff_stats.get(stat, 0))) * w
	if sum_w <= 0.0:
		return 0.0
	return factor / (tuning.scaling_normalizer() * sum_w)


## 4단계. 단일 정수.
static func base_damage(weapon: Dictionary) -> float:
	return float(weapon.get("damage", 0))


## 5단계.
static func upgrade_additive(item: Dictionary, tuning: StoneStoryTuning) -> float:
	return tuning.cf("upgrade_additive_per_level") * float(int(item.get("upgrade_level", 0)))


## 6단계. 어펙스는 "강화로 추가된 내용"이다. 속성 델타도 여기서 온다.
static func affix_terms(affix_ids: Array, affix_db: Dictionary) -> Dictionary:
	var add: float = 0.0
	var mult: float = 1.0
	var attrs: Dictionary = {}
	for aid in affix_ids:
		var a: Dictionary = affix_db.get(str(aid), {})
		if a.is_empty():
			continue
		add += float(a.get("damage_additive", 0.0))
		mult *= float(a.get("damage_multiplicative", 1.0))
		for k in a.get("attr_delta", {}):
			attrs[str(k)] = float(attrs.get(str(k), 0.0)) + float(a["attr_delta"][k])
	return {"additive": add, "multiplicative": mult, "attrs": attrs}


## 7단계. 유일한 damage_pre.
static func damage_pre(weapon: Dictionary, item: Dictionary, affix_db: Dictionary,
		req: Dictionary, tuning: StoneStoryTuning) -> Dictionary:
	var base: float = base_damage(weapon)
	if base <= 0.0:
		return {"value": 0.0, "scaling_ratio": 0.0, "affix_attrs": {}}
	var scale: float = scaling_ratio(weapon, req["effective"], tuning)
	var upg: float = upgrade_additive(item, tuning)
	var aff: Dictionary = affix_terms(item.get("affix_ids", []), affix_db)
	var aff_add: float = minf(aff["additive"], tuning.cf("affix_additive_cap"))
	var aff_mult: float = minf(aff["multiplicative"], tuning.cf("affix_multiplicative_product_cap"))
	var pen: float = 1.0 if bool(req["met"]) else tuning.cf("requirement_penalty")
	var value: float = base * (1.0 + scale) * (1.0 + upg) * (1.0 + aff_add) * aff_mult * pen
	return {"value": value, "scaling_ratio": scale, "affix_attrs": aff["attrs"]}


## 전체 판정. 공격자/방어자 4-속성을 쓴다.
static func resolve_attack(weapon: Dictionary, item: Dictionary, affix_db: Dictionary,
		stats: Dictionary, tuning: StoneStoryTuning,
		attacker: Dictionary, defender: Dictionary, serial: int) -> Dictionary:
	var div: float = tuning.cf("two_hand_requirement_divisor")
	var req: Dictionary = requirement_report(weapon, stats, div)
	var pre: Dictionary = damage_pre(weapon, item, affix_db, req, tuning)
	if float(pre["value"]) <= 0.0:
		return {"damage": 0.0, "affinity": {}, "crit": false, "arts_enabled": bool(req["met"]), "affix_attrs": {}}

	var aff: Dictionary = StoneStoryAttributes.affinity(attacker, defender)
	var attrs: Dictionary = attacker.get("attributes", {})
	var crit: bool = false
	if bool(attacker.get("can_crit", true)):
		var roll: int = StoneStoryCore.at(
				StoneStoryCore.stream(int(attacker.get("seed", 1)) + serial, StoneStoryCore.TAG_SIM), 0)
		crit = roll % 100 < int(StoneStoryAttributes.crit_chance(attrs, tuning) * 100.0)
	var raw: float = float(pre["value"]) * float(aff["mult"])
	if crit:
		raw *= tuning.cf("crit_mult")
	return {
		"damage": raw,
		"affinity": aff,
		"crit": crit,
		"arts_enabled": bool(req["met"]),
		"affix_attrs": pre["affix_attrs"],
	}


## -------------------------------------------------- 상태 축적

static func accumulate(target: Dictionary, amount: Dictionary, stats: Dictionary,
		tuning: StoneStoryTuning) -> Array[String]:
	var boost: float = 1.0 + tuning.stat_effective(int(stats.get("instinct", 0))) * tuning.cf("status_instinct_gain")
	var burst: Array[String] = []
	for s in STATUSES:
		var add: float = float(amount.get(s, 0)) * boost
		if add <= 0.0:
			continue
		var resist: float = clampf(float(target.get("status_resist", {}).get(s, 0.0)),
				0.0, tuning.cf("status_resist_max"))
		var cur: float = float(target.get("status_build", {}).get(s, 0.0))
		var nxt: float = clampf(cur + add * (1.0 - resist), 0.0, tuning.cf("status_threshold"))
		target["status_build"][s] = nxt
		if nxt >= tuning.cf("status_threshold"):
			burst.append(s)
			target["status_build"][s] = 0.0
	return burst


static func burst_damage(status: String, kick_damage: float, stats: Dictionary,
		tuning: StoneStoryTuning) -> float:
	var gain: float = 1.0 + tuning.stat_effective(int(stats.get("instinct", 0))) * tuning.cf("status_damage_instinct")
	return kick_damage * tuning.cf("status_damage_ratio") * gain


## 기격. 틀림 속성은 경직을 꺾는다.
static func resolve_poise(poise_damage: float, target: Dictionary, now_tick: int,
		tuning: StoneStoryTuning) -> bool:
	if StoneStoryAttributes.breaks_stagger(target.get("attributes", {}), now_tick, tuning):
		return false
	if poise_damage > float(target.get("poise", 0)):
		target["staggered"] = true
		target["stagger_frames"] = tuning.ci("stagger_frames")
		return true
	return false


## 스탠스 배율
static func apply_stance(damage: float, stance: String, tuning: StoneStoryTuning) -> float:
	if stance == "guard":
		damage *= tuning.cf("guard_mult")
	if stance == "superarmor":
		damage *= tuning.cf("superarmor_damage")
	return damage


static func has_superarmor(weapon: Dictionary, tuning: StoneStoryTuning) -> bool:
	return float(weapon.get("poise", 0)) >= tuning.cf("superarmor_poise_threshold")
