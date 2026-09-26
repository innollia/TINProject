class_name StoneStoryPlayerAI
extends RefCounted

## 자동 조종. 플레이어는 직접 조종하지 않는다.
## **장비가 AI 정책을 바꾼다.** 이 클래스는 그 정책만 실행한다.
## 데미지 수치/명중 여부는 만들지 않는다.

enum Goal { SURVIVE, CLEAR, COLLECT, RETURN }

const SURVIVE_HP := 0.35
const GUARD_HP := 0.60


static func hp_ratio(p: Dictionary) -> float:
	return float(p["hp"]) / maxf(1.0, float(p["hp_max"]))


static func active_statuses(p: Dictionary) -> int:
	var n: int = 0
	for k in p.get("status_build", {}):
		if float(p["status_build"][k]) > 0.0:
			n += 1
	return n


static func top_goal(p: Dictionary, enc: Dictionary) -> int:
	if hp_ratio(p) < SURVIVE_HP or active_statuses(p) >= 2 or int(p["stamina"]) <= 0:
		return Goal.SURVIVE
	if alive_foes(enc) > 0:
		return Goal.CLEAR
	return Goal.COLLECT


static func alive_foes(enc: Dictionary) -> int:
	var n: int = 0
	for f in enc.get("foes", []):
		if bool(f["alive"]):
			n += 1
	return n


## 정책만 읽는다. 장비가 정한 것을 그대로 실행한다.
static func decide(state: Dictionary, enc: Dictionary, content: StoneStoryContent,
		tuning: StoneStoryTuning) -> Dictionary:
	var p: Dictionary = state["player"]
	var policy: Dictionary = StoneStoryRunState.resolve_policy(p, content)
	var attrs: Dictionary = StoneStoryRunState.resolve_attributes(p, content)
	var goal: int = top_goal(p, enc)

	var loadout: Dictionary = _best_weapon(p, content, tuning.cf("two_hand_requirement_divisor"))
	var weapon: Dictionary = content.item(str(loadout["main"]))
	var superarmor: bool = StoneStoryCombat.has_superarmor(weapon, tuning) or bool(policy[&"superarmor_always"])

	var stance: String = "neutral"
	if not superarmor:
		# 장비 정책이 스탠스를 정한다. 안전 기본값은 가드를 유지.
		if int(p["stamina"]) >= tuning.ci("guard_cost"):
			if goal == Goal.SURVIVE:
				stance = "evade"
			elif hp_ratio(p) < GUARD_HP:
				stance = "guard"
			elif hp_ratio(p) > float(policy[&"evade_hp_max"]):
				stance = "attack"
			else:
				stance = str(policy[&"open_with"])
		if bool(policy[&"always_guard"]) and stance != "evade":
			stance = "guard"
	if superarmor:
		stance = "superarmor"

	var target: Dictionary = _pick_target(enc, str(policy[&"focus_priority"]), str(policy[&"counter_attr"]))

	return {
		"stance": stance,
		"goal": goal,
		"policy": policy,
		"attributes": attrs,
		"weapon": str(loadout["main"]),
		"actions_per_turn": StoneStoryAttributes.actions_per_turn(attrs, policy, tuning),
		"target_id": str(target.get("foe_id", "")),
		"want_potion": hp_ratio(p) <= float(policy[&"potion_at_hp"]) and float(policy[&"potion_at_hp"]) > 0.0,
		"want_ability": hp_ratio(p) <= float(policy[&"use_ability_below_hp"]) and float(policy[&"use_ability_below_hp"]) > 0.0,
		"retreat": goal == Goal.SURVIVE and float(p["hp"]) / maxf(1.0, float(p["hp_max"])) < float(policy[&"retreat_hp_below"]),
	}


## 요구치를 전부 충족하는 무기 중 스케일링 합이 가장 높은 것.
## 미달이어도 후보로 남는다. 약해진 채로 싸워야 요구치 규칙이 보인다.
static func _best_weapon(p: Dictionary, content: StoneStoryContent, two_hand_divisor: float) -> Dictionary:
	var stats: Dictionary = p["stats"]
	var best_id: String = ""
	var best_score: float = -1.0
	for entry in p.get("gear", []):
		var oid: String = str((entry as Dictionary).get("item_id", ""))
		var it: Dictionary = content.item(oid)
		if it.is_empty() or str(it.get("kind", "")) != "weapon":
			continue
		var req: Dictionary = StoneStoryCombat.requirement_report(it, stats, two_hand_divisor)
		var s: float = 0.0
		for st in it.get("scaling", {}):
			s += float(it["scaling"][st])
		var score: float = s * 1000.0 + StoneStoryCombat.base_damage(it)
		if not bool(req["met"]):
			score *= 0.35
		if score > best_score:
			best_score = score
			best_id = oid
	return {"main": best_id}


static func _pick_target(enc: Dictionary, priority: String, counter_attr: String) -> Dictionary:
	var pool: Array = []
	for f in enc.get("foes", []):
		if bool(f["alive"]):
			pool.append(f)
	if pool.is_empty():
		return {}
	# 다리 12 보스가 세 개에 몰려도 한 번에 하나만 상대한다.
	match priority:
		"lowest_hp":
			pool.sort_custom(func(a, b): return int(a["hp"]) < int(b["hp"]))
		"ranged_first":
			pool.sort_custom(func(a, b): return (a["tags"].has("ranged") as int) > (b["tags"].has("ranged") as int))
		"biggest":
			pool.sort_custom(func(a, b): return int(a["attributes"].get("limbs", 1)) > int(b["attributes"].get("limbs", 1)))
		_:
			pool.sort_custom(func(a, b): return int(a["dist"]) < int(b["dist"]))
	var pick: Dictionary = pool[0]
	if not counter_attr.is_empty() and counter_attr == "wrongness":
		for f in pool:
			if float((f as Dictionary)["attributes"].get("wrongness", 0.0)) >= 6.0:
				return f
	return pick
