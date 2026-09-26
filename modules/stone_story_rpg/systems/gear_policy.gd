class_name StoneStoryGearPolicy
extends RefCounted

## 장비가 AI 정책을 바꾼다. 플레이어의 유일한 간접 조종 수단.
##
## 하이브리리 결정: 장비는 policy_delta **데이터**를 갖는다. 저자가 조합을 쓴다.
## 표현이 안 되는 소수만 policy_hook 코드로. hook 은 Kit 로컬이다.
## 이 클래스는 데이터 해석기다. 전투 결과(데미지/명중)를 만들지 않는다.

const KEYS: Array[StringName] = [
	&"guard_min_hp", &"evade_hp_max", &"retreat_hp_below",
	&"focus_priority", &"open_with", &"potion_at_hp", &"potion_on_debuff",
	&"use_ability_below_hp", &"counter_attr", &"never_retreat",
	&"always_guard", &"superarmor_always",
	&"actions_per_turn_mod", &"evade_cooldown_mod",
]

const FOCUS_PRIORITY: Array[String] = ["lowest_hp", "highest_threat", "nearest", "ranged_first", "biggest"]
const OPEN_WITH: Array[String] = ["attack", "evade", "guard", "ability"]


static func base() -> Dictionary:
	return {
		&"guard_min_hp": 0.0,
		&"evade_hp_max": 0.0,
		&"retreat_hp_below": 0.0,
		&"focus_priority": "nearest",
		&"open_with": "attack",
		&"potion_at_hp": 0.0,
		&"potion_on_debuff": "",
		&"use_ability_below_hp": 0.0,
		&"counter_attr": "",
		&"never_retreat": false,
		&"always_guard": false,
		&"superarmor_always": false,
		&"actions_per_turn_mod": 0,
		&"evade_cooldown_mod": 0,
	}


## 수치 키는 max, 불리언 키는 OR, 문자열 키는 뒤 장비 우선.
## 여러 장비를 겹쳐도 정책이 무한히 강해지지 않는다.
static func resolve(gear: Array) -> Dictionary:
	var p: Dictionary = base()
	var add_keys: Array[StringName] = [&"actions_per_turn_mod", &"evade_cooldown_mod"]
	var max_keys: Array[StringName] = [
		&"guard_min_hp", &"evade_hp_max", &"potion_at_hp", &"use_ability_below_hp",
	]
	var or_keys: Array[StringName] = [&"never_retreat", &"always_guard", &"superarmor_always"]
	var set_keys: Array[StringName] = [&"focus_priority", &"open_with", &"counter_attr", &"potion_on_debuff"]
	for item in gear:
		var d: Dictionary = item.get("policy_delta", {})
		for k in add_keys:
			p[k] = int(p[k]) + int(d.get(k, 0))
		for k in max_keys:
			p[k] = maxf(float(p[k]), float(d.get(k, 0.0)))
		for k in or_keys:
			p[k] = bool(p[k]) or bool(d.get(k, false))
		for k in set_keys:
			var v: Variant = d.get(k, null)
			if v != null and not str(v).is_empty():
				p[k] = str(v)
	if bool(p[&"never_retreat"]):
		p[&"retreat_hp_below"] = 0.0
	# 후퇴 임계가 회피 상한보다 높으면 회피가 죽는다. 후퇴를 내린다.
	if float(p[&"retreat_hp_below"]) > float(p[&"evade_hp_max"]) and float(p[&"evade_hp_max"]) > 0.0:
		p[&"retreat_hp_below"] = float(p[&"evade_hp_max"])
	return p


## 데이터로 표현이 안 되는 소수만 여기로 온다. Kit 로컬.
static func policy_hook(policy: Dictionary, slot_id: StringName) -> Dictionary:
	match slot_id:
		&"hook_never_turn_back":
			policy[&"retreat_hp_below"] = 0.0
			policy[&"never_retreat"] = true
		&"hook_body_wall":
			policy[&"always_guard"] = true
			policy[&"guard_min_hp"] = 0.99
			policy[&"evade_hp_max"] = 0.0
			policy[&"actions_per_turn_mod"] = 0
		&"hook_counter_hunt":
			policy[&"counter_attr"] = "weakness"
			policy[&"focus_priority"] = "lowest_hp"
			policy[&"potion_on_debuff"] = "bleed"
		&"hook_counter_shatter":
			policy[&"counter_attr"] = "wrongness"
			policy[&"open_with"] = "evade"
			policy[&"evade_cooldown_mod"] = -2
		&"hook_multi_limb":
			policy[&"actions_per_turn_mod"] = 1
		_:
			pass
	return policy


static func validate_content(policy: Dictionary, where: String) -> Array[String]:
	var errs: Array[String] = []
	for k in KEYS:
		if not policy.has(k):
			continue
		var v: Variant = policy[k]
		if k == &"focus_priority":
			if not FOCUS_PRIORITY.has(str(v)):
				errs.append("bad_focus_priority:%s:%s" % [where, str(v)])
		elif k == &"open_with":
			if not OPEN_WITH.has(str(v)):
				errs.append("bad_open_with:%s:%s" % [where, str(v)])
		elif k == &"counter_attr":
			if not str(v).is_empty() and not StoneStoryAttributes.KEYS.has(StringName(v)):
				errs.append("bad_counter_attr:%s:%s" % [where, str(v)])
		elif k == &"actions_per_turn_mod" or k == &"evade_cooldown_mod":
			if not (v is int) or absi(int(v)) > 3:
				errs.append("mod_out_of_range:%s:%s" % [where, str(v)])
		elif v is bool or v is float or v is int or v is String:
			continue
		else:
			errs.append("bad_type:%s:%s" % [where, String(k)])
	return errs
