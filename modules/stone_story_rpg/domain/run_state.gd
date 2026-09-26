class_name StoneStoryRunState
extends RefCounted

## domain state. 파생 상태(스케일링/상성/방어율/chest_cap/속성/정책)는 저장하지 않는다.

const FORMAT := "ssr_run_v1"
const VERSION := 1
const STAT_KEYS: Array[String] = [
	"vitality", "focus", "grit", "toughness",
	"strength", "dexterity", "intellect", "devotion", "instinct",
]


static func fresh(tuning: StoneStoryTuning, class_def: Dictionary) -> Dictionary:
	var stats: Dictionary = {}
	for k in STAT_KEYS:
		stats[k] = int(class_def["base_stats"].get(k, 10))
	var p: Dictionary = {
		"level": 1,
		"xp": 0,
		"hp": 0, "hp_max": 0,
		"focus_pool": 0, "focus_max": 0,
		"stamina": 0, "stamina_max": 0,
		"last_stamina_spend_tick": 0,
		"stats": stats,
		"stat_points": 0,
		"class_id": str(class_def["id"]),
		"pos": {"x": 0, "y": 0},
		"facing": 0,
		"stones": {},
		"loadout": {"main": "", "off": "", "focus_slot": 0},
		"gear": [],
		"base_attributes": StoneStoryAttributes.blank(),
		"affinity_attr": "limbs",
		"chests": [],
		"spells": [],
		"inventory": {"materials": {}, "enchants": [], "affixes": []},
		"discovered": {},
	}
	refresh_max(p, tuning)
	p["hp"] = int(p["hp_max"])
	p["focus_pool"] = int(p["focus_max"])
	p["stamina"] = int(p["stamina_max"])
	var slots: int = tuning.focus_slots(int(stats["focus"]), tuning.c("focus_slot_steps"))
	p["spells"] = []
	p["spells"].resize(slots)
	for sid in class_def.get("start_stones", []):
		p["stones"][str(sid)] = {"held": true, "equipped": true}

	var items: Array = class_def.get("start_items", [])
	for i in items.size():
		p["gear"].append(StoneStoryContent.make_item_state(str(items[i])))
	if items.size() > 0:
		p["loadout"]["main"] = str(items[0])
	if items.size() > 1:
		p["loadout"]["off"] = str(items[1])

	var base: Dictionary = StoneStoryAttributes.blank()
	for k in class_def.get("base_attributes", {}):
		base[k] = class_def["base_attributes"][k]
	base[StoneStoryAttributes.LIMBS] = StoneStoryAttributes.clamp_limbs(
			int(base.get(StoneStoryAttributes.LIMBS, 1)))
	for k in StoneStoryAttributes.SCALARS:
		base[k] = StoneStoryAttributes.clamp_scalar(float(base.get(k, 0.0)))
	p["base_attributes"] = base
	p["affinity_attr"] = str(class_def.get("affinity_attr", "limbs"))

	return {
		"state_format": FORMAT,
		"save_version": VERSION,
		"tuning_signature": tuning.signature,
		"content_signature": "",
		"run_id": "r-" + str(absi(tuning.signature.hash())),
		"run_seed": 0,
		"star_level": 1,
		"region_id": "",
		"tick": 0,
		"respec_used": 0,
		"screen": "lobby",
		"player": p,
		"world": {
			"currency": 0,
			"unlocked_regions": [],
			"discovered": {},
			"loop_point": {},
			"last_star_level": 1,
			"legend_state": {},
			"quest_counters": {},
			"legend_flags": {},
			"reputation": {},
			"season": "spring",
			"stone_drops": [],
			"interpretations": {},
		},
		"encounter": null,
		"flags": {},
	}


static func refresh_max(p: Dictionary, tuning: StoneStoryTuning) -> void:
	var s: Dictionary = p["stats"]
	p["hp_max"] = tuning.hp_max(int(s["vitality"]))
	p["focus_max"] = tuning.focus_max(int(s["focus"]))
	p["stamina_max"] = tuning.stamina_max(int(s["grit"]))
	p["hp"] = mini(int(p["hp"]), int(p["hp_max"]))
	p["focus_pool"] = mini(int(p["focus_pool"]), int(p["focus_max"]))
	p["stamina"] = mini(int(p["stamina"]), int(p["stamina_max"]))


## 장비는 인스턴스(진행 값) + 콘텐츠 정의(정적 규칙) 두 곳에 나뉘어 있다.
## attr_delta 와 policy_delta 는 **정의 쪽**에 있다. 그래서 반드시 합쳐야 한다.
static func gear_defs(p: Dictionary, content: StoneStoryContent) -> Array:
	var out: Array = []
	for entry in p.get("gear", []):
		var inst: Dictionary = entry
		var def: Dictionary = content.item(str(inst.get("item_id", "")))
		var merged: Dictionary = def.duplicate(true)
		for k in inst:
			merged[k] = inst[k]
		out.append(merged)
	return out


## 4-속성 = 개체 기본 ⊕ 착용 장비. 파생이라 저장하지 않는다.
static func resolve_attributes(p: Dictionary, content: StoneStoryContent) -> Dictionary:
	return StoneStoryAttributes.resolve(p.get("base_attributes", StoneStoryAttributes.blank()),
			gear_defs(p, content))


## 장비가 AI 정책을 바꾼다. 이것이 플레이어의 유일한 간접 조종 수단이다.
static func resolve_policy(p: Dictionary, content: StoneStoryContent) -> Dictionary:
	return StoneStoryGearPolicy.resolve(gear_defs(p, content))


static func chest_cap(level: int, tuning: StoneStoryTuning) -> int:
	var table: Array = tuning.e("chest_cap_by_level")
	return int(table[clampi(level - 1, 0, table.size() - 1)])


static func add_chest(p: Dictionary, chest: Dictionary, tuning: StoneStoryTuning) -> bool:
	if p["chests"].size() >= chest_cap(int(p["level"]), tuning):
		return false
	p["chests"].append(chest)
	return true


static func make_chest(tier: String, seed_value: int) -> Dictionary:
	return {"tier": tier, "seed": seed_value, "items": [], "materials": {}, "opened": false}


static func has_verb(stones: Dictionary, verb: String, verb_map: Dictionary) -> bool:
	for sid in verb_map:
		if str(verb_map[sid]) == verb:
			var s: Dictionary = stones.get(str(sid), {})
			return bool(s.get("held", false))
	return false


static func equipped_passives(stones: Dictionary, content: StoneStoryContent) -> Dictionary:
	var out: Dictionary = {"currency_gain": 0.0, "xp_gain": 0.0,
			"walk_speed": 1.0, "attack_speed": 1.0, "regen_per_turn": 0}
	for sid in stones:
		var s: Dictionary = stones[str(sid)]
		if not bool(s.get("equipped", false)):
			continue
		var st: Dictionary = content.get_def("stone", str(sid))
		for k in st.get("passives_equipped", {}):
			var v: float = float(st["passives_equipped"][k])
			if k == "walk_speed" or k == "attack_speed":
				out[k] = float(out[k]) * (1.0 + v)
			else:
				out[k] = float(out[k]) + v
	return out


static func gain_xp(p: Dictionary, amount: int, tuning: StoneStoryTuning) -> int:
	var gained: int = 0
	var maxl: int = tuning.ci("max_level")
	p["xp"] = int(p["xp"]) + maxi(0, amount)
	while int(p["level"]) < maxl and int(p["xp"]) >= tuning.xp_to_next(int(p["level"])):
		p["xp"] = int(p["xp"]) - tuning.xp_to_next(int(p["level"]))
		p["level"] = int(p["level"]) + 1
		p["stat_points"] = int(p["stat_points"]) + 1
		gained += 1
	if int(p["level"]) >= maxl:
		p["xp"] = 0
	if gained > 0:
		var want: int = tuning.focus_slots(int(p["stats"]["focus"]), tuning.c("focus_slot_steps"))
		while p["spells"].size() < want:
			p["spells"].append("")
	return gained


static func to_dict(s: Dictionary) -> Dictionary:
	return s.duplicate(true)


static func from_dict(d: Dictionary, tuning: StoneStoryTuning) -> Dictionary:
	if str(d.get("state_format", "")) != FORMAT:
		return {"state": {}, "result": "reset_format"}
	if str(d.get("tuning_signature", "")) != tuning.signature:
		return {"state": {}, "result": "reset_tuning"}
	var sl: int = int(d.get("star_level", 0))
	if sl < 1 or sl > 20:
		return {"state": {}, "result": "reset_star"}
	var out: Dictionary = d.duplicate(true)
	refresh_max(out["player"], tuning)
	return {"state": out, "result": "restored"}
