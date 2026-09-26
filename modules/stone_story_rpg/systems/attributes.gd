class_name StoneStoryAttributes
extends RefCounted

## 개체 속성 4종. 데미지 타입이 아니다.
##
##   다리(limbs)      정수 1..12. 물리적 다리 수. 한 턴 행동 수를 정한다.
##   놀랍다(surprise) 0..10. 미스터리한 수치. 크기가 가장 큰 상관관계지만 약하다.
##   틀림(wrongness)  0..10. 규칙을 어기는 정도.
##   동그라미(round)  0..10. 둥근 정도.
##
## 속성 = 개체 기본값 ⊕ 착용 장비 델타.
## 상성은 4-사이클 하나: 다리 -> 틀림 -> 동그라미 -> 놀랍다 -> 다리

const LIMBS := &"limbs"
const SURPRISE := &"surprise"
const WRONGNESS := &"wrongness"
const ROUND := &"roundness"
const SCALARS: Array[StringName] = [SURPRISE, WRONGNESS, ROUND]
const KEYS: Array[StringName] = [LIMBS, SURPRISE, WRONGNESS, ROUND]

const LIMBS_MIN: int = 1
const LIMBS_MAX: int = 12
const SCALE_MIN: int = 0
const SCALE_MAX: int = 10

const CYCLE: Array[StringName] = [LIMBS, WRONGNESS, ROUND, SURPRISE]
const CYCLE_WIN: float = 1.50
const CYCLE_LOSE: float = 0.75
const CYCLE_TIE: float = 1.00

## size_units 정규화 기준. 이 값보다 크면 size 항이 0 으로 수렴한다.
const SIZE_REFERENCE: float = 220.0
const GOLDEN_RATIO: float = 1.6180339887

## 놀랍다 가중치. 크기가 가장 크지만 절대다수는 아니다.
const W_SIZE: float = 0.34
const W_IRREGULAR: float = 0.21
const W_ASPECT: float = 0.15
const W_MOTION: float = 0.12
const W_MYSTERY: float = 0.18
const SIZE_EXPONENT: float = 0.70
## content 가 줄 수 있는 바이어스의 최대치. 미스터리를 없애지 않기 위한 상한.
const BIAS_LIMIT: float = 6.0


static func blank() -> Dictionary:
	return {LIMBS: 1, SURPRISE: 0.0, WRONGNESS: 0.0, ROUND: 0.0}


static func clamp_scalar(v: float) -> float:
	return clampf(v, float(SCALE_MIN), float(SCALE_MAX))


static func clamp_limbs(v: int) -> int:
	return clampi(v, LIMBS_MIN, LIMBS_MAX)


## -------------------------------------------------- 놀랍다
## 크기가 가장 큰 상관관계지만 **약하다**. 역산 불가.
## 작은 개체가 아주 놀랍게 나올 수 있게 exponent 로 포화를 늦춘다.
## content 의 attributes.surprise 는 **바이어스**다. 값을 그대로 쓰는 게 아니라
## 공식 결과에 더해지는 nudging 이다. 그래서 놀랍다는 미스터리 수치로 남는다.
static func surprise(base: Dictionary, shape: Dictionary, stream: StoneStoryRng) -> float:
	var size_rank: float = inverse_size_term(float(shape.get("size_units", 40.0)))
	var irregular: float = 1.0 - clampf(float(base.get(ROUND, 0.0)) / float(SCALE_MAX), 0.0, 1.0)
	var aspect: float = aspect_term(float(shape.get("width_units", 20.0)), float(shape.get("height_units", 20.0)))
	var motion: float = clampf(float(shape.get("motion_events", 0.0)) / 12.0, 0.0, 1.0)

	var mystery: float = stream.unit(0)
	var mystery_b: float = stream.unit(1)

	var raw: float = W_SIZE * pow(size_rank, SIZE_EXPONENT) \
			+ W_IRREGULAR * irregular \
			+ W_ASPECT * aspect \
			+ W_MOTION * motion \
			+ W_MYSTERY * mystery

	# 폭이 있는 스케일. 단조가 아니어서 역산이 안 된다.
	var spread: float = 0.75 + 0.5 * mystery_b
	# 저자가 건네는 바이어스. 미스터리를 없애지 않는 범위로 제한한다.
	var bias: float = clampf(float(base.get(SURPRISE, 0.0)), -BIAS_LIMIT, BIAS_LIMIT) / BIAS_LIMIT * 1.5
	return clamp_scalar(roundf(raw * spread * float(SCALE_MAX) + bias))


static func inverse_size_term(size_units: float) -> float:
	var s: float = maxf(0.5, size_units)
	return clampf(1.0 - (log(1.0 + s) / log(1.0 + SIZE_REFERENCE)), 0.0, 1.0)


static func aspect_term(w: float, h: float) -> float:
	if w <= 0.001 or h <= 0.001:
		return 0.0
	var ratio: float = w / h
	return clampf(absf(ratio - GOLDEN_RATIO) / GOLDEN_RATIO, 0.0, 1.0)


## -------------------------------------------------- 장비 합산
## 파생 상태이므로 저장하지 않는다.
static func resolve(base: Dictionary, gear: Array) -> Dictionary:
	var out: Dictionary = blank()
	out[LIMBS] = clamp_limbs(int(base.get(LIMBS, 1)))
	for k in SCALARS:
		out[k] = clamp_scalar(float(base.get(k, 0.0)))
	for item in gear:
		var d: Dictionary = item.get("attr_delta", {})
		out[LIMBS] = clamp_limbs(int(out[LIMBS]) + int(d.get(LIMBS, 0)))
		for k in SCALARS:
			out[k] = clamp_scalar(float(out[k]) + float(d.get(k, 0.0)))
	return out


## -------------------------------------------------- 상성

static func beats(attacker_attr: StringName, defender_attr: StringName) -> bool:
	var i: int = CYCLE.find(attacker_attr)
	if i < 0 or not CYCLE.has(defender_attr):
		return false
	return CYCLE[(i + 1) % CYCLE.size()] == defender_attr


static func affinity(attacker: Dictionary, defender: Dictionary) -> Dictionary:
	var atk: StringName = StringName(attacker.get("affinity_attr", "limbs"))
	var def: StringName = StringName(defender.get("affinity_attr", "limbs"))
	var mult: float = CYCLE_TIE
	var relation: String = "tie"
	if atk != def:
		relation = "win" if beats(atk, def) else "lose"
		mult = CYCLE_WIN if relation == "win" else CYCLE_LOSE
	return {"attacker": atk, "defender": def, "mult": mult, "relation": relation}


## -------------------------------------------------- 속성이 주는 전투 행동

## 다리 12 = 1턴 3회. floor 로 계단.
static func actions_per_turn(attrs: Dictionary, policy: Dictionary, tuning: StoneStoryTuning) -> int:
	var n: int = 1 + int(floor(float(attrs.get(LIMBS, 1)) / 5.0))
	return clampi(n + int(policy.get("actions_per_turn_mod", 0)), 1, 4)


static func evade_chance(attrs: Dictionary, tuning: StoneStoryTuning) -> float:
	return clampf(tuning.cf("evade_base") + float(attrs.get(ROUND, 0.0)) * tuning.cf("evade_per_round"),
			0.0, 0.92)


static func crit_chance(attrs: Dictionary, tuning: StoneStoryTuning) -> float:
	return clampf(tuning.cf("crit_base") + float(attrs.get(WRONGNESS, 0.0)) * tuning.cf("crit_per_wrongness"),
			0.0, 0.75)


## 틀림은 경직을 꺾는다. 주기 frames.
static func breaks_stagger(attrs: Dictionary, now_tick: int, tuning: StoneStoryTuning) -> bool:
	if float(attrs.get(WRONGNESS, 0.0)) < 6.0:
		return false
	var period: int = maxi(1, tuning.ci("wrongness_stagger_period"))
	return now_tick % period == 0


## 놀랍다: 다음 행동 예고를 못 읽는다. AI 만 적용.
static func is_unpredictable(attrs: Dictionary, threshold: float) -> bool:
	return float(attrs.get(SURPRISE, 0.0)) >= threshold


## -------------------------------------------------- 검증

static func is_valid(attrs: Dictionary) -> bool:
	if not attrs.has(LIMBS):
		return false
	var l: int = int(attrs[LIMBS])
	if l < LIMBS_MIN or l > LIMBS_MAX:
		return false
	for k in SCALARS:
		if not attrs.has(k):
			return false
		var v: float = float(attrs[k])
		if v < float(SCALE_MIN) or v > float(SCALE_MAX):
			return false
	return true
