# 04 — 스탯 · 데미지 · 전투 판정

사용자 결정:
- `속성은 물불돌 이거 별로임. 다크소울식으로 가자.`
- `대미지 판정 완전복제 아니야. 우리 방식을 어느정도 만들어. 수치도 복제하는거 아니야.`
- `어펙스 기호는 그 무기를 강화했을때 강화된 내용.`

→ **구조는 DS3에서 가져오고, 모든 수치와 판정식은 TIN이 새로 정의한다.**
모든 기본값은 코드 상수가 아니라 `content/tuning/*.json` 에서 읽는다.

---

## 1. 스탯 9개

### 1.1 내구 4 (살아남는 값)

| id | 이름 | 기본 | 1당 성장 | 최대 | 하는 일 |
|---|---|---|---|---|---|
| `vitality` | 체력 | 20 | HP | 99 | 최대 생명력 |
| `focus` | 정신 | 10 | Focus + 기억 슬롯 | 99 | 주문 수, 주문 유지 시간 |
| `grit` | 지구력 | 12 | 지구(스태미나) + 넉백/타격 내성 | 99 | 회피 횟수, 출혈/독 저항 |
| `toughness` | 내구 | 12 | 물리 방어 + 장비 중량 한도 | 99 | 최대 HP 아님, **받는 데미지 감소** |

### 1.2 공격 5 (무기를 여는 값)

| id | 이름 | 기본 | 쓰는 것 |
|---|---|---|---|
| `strength` | 위력 | 10 | 물리 스케일링, 화염 내성 |
| `dexterity` | 민첩 | 10 | 공속(프레임 단축), 낙하 피해 감소 |
| `intellect` | 지혜 | 10 | 마력 스케일링, 마력 방어 |
| `devotion` | 신앙 | 10 | 번개/어둠 스케일링, 어둠 방어 |
| `instinct` | 직감 | 8 | 상태 축적 속도, 아이템 발견율 |

### 1.3 배분 규칙

- 스탯 상한 **99**.
-Lv당 자유 배분 1점.
- 태생(Class)이 시작 스탯을 결정한다. → `13_CONTENT_SCHEMA.md` §9
- **재배분 5회 제한** (DS3의 Rosaria 구조). 횟수는 런마다 리셋.
  재배분 시 반환점은 `태생 기본값 + 1` (레벨을 낮출 수 없다).
  → 재배분 제공 주체는 `stone_of_turn`(돌 10)으로 확정. `17_OPEN_QUESTIONS.md` Q3.

---

## 2. 소프트캡 곡선 (TIN 자체 정의)

DS3 관측: 효율 구간 25/40, 그 뒤 급감. 생명력만 99까지 증가.
→ 부드러운 포화곡선이 아니라 **무릎이 있는 계단형 선형**을 쓴다.

```gdscript
# systems/stat_curve.gd
func effective(value: int, tuning: Dictionary) -> float:
	var knee_a: float = tuning["knee_a"]          # 기본 20
	var knee_b: float = tuning["knee_b"]          # 기본 45
	var slope_b: float = tuning["slope_b"]        # 기본 0.50
	var slope_c: float = tuning["slope_c"]        # 기본 0.15
	if value <= knee_a:
		return float(value)
	var at_knee_b: float = knee_a + (knee_b - knee_a) * slope_b   # 32.5
	if value <= knee_b:
		return knee_a + (value - knee_a) * slope_b
	return at_knee_b + (value - knee_b) * slope_c
```

**세 번째 구간은 `knee_b` 가 아니라 `at_knee_b`(출력값)에서 이어진다.**
`knee_b` 에서 이어 쓰면 1 스텝에 +25 가 들어가는 불연속이 생긴다.

| 구간 | 효율 | `knee_a=20 knee_b=45` 일 때 |
|---|---|---|
| 0 ~ 20 | 1.00 | 0 → 20 |
| 20 ~ 45 | 0.50 | 20 → **32.5** |
| 45 ~ 99 | 0.15 | 32.5 → 40.6 |

- `effective` 는 **연속**이다. `effective(45) == 32.5`, `effective(46) == 32.65`.
- 모든 스탯에 같은 곡선을 쓴다. 스탯별 예외를 두지 않는다.

**장비 강화(§6)는 이 곡선을 우회하지 않는다.** 강화로 얻는 것은
가산 배율(§4.4)뿐이고 소프트캡은 여전히 적용된다. → 원작과 다른 선택.

### 2.1 기억 슬롯 계단 (정신)

`mental` 스탯이 임계점을 지날 때마다 주문 슬롯이 1개 늘어난다.
임계점은 `tuning.focus_slot_steps` 배열. 기본:

```text
[12, 20, 28, 36, 44, 52, 60, 68, 76, 84, 92, 99]
```

`focus_slots = 1 + count(step <= focus)`. 최대 12 + 기본 1 = 13.
카메라/UI는 이 값을 인벤토리 상단에 **숫자로만** 표시한다. 박스·라벨 없음.

---

## 3. 무기 스케일링과 요구치

### 3.1 무기 스케일링

원작의 `S/A/B/C/D/E` 문자열 대신 **0.00~1.00 실수 가중치**를 쓴다.
이유: 절차 생성과 밸런스 조정에 문자열 열거가 불편하다.

```gdscript
"scaling": {"strength": 0.65, "dexterity": 0.30}
```

- 무기 하나의 스케일링 가중치 합은 **1.0을 넘지 않는다.**
- 0 합(스케일링 없음) 무기도 허용한다. 초반 무기용.
- `scaling_total = Σ weight` 를 "보정 총합"으로 디버그/도감 표시에만 쓴다.

### 3.2 무기 요구치

```gdscript
"requirement": {"strength": 24, "dexterity": 12}
```

`requirement`는 `scaling`과 **별개**다. 스케일링이 높은 스탯이 요구치도 높을 필요가 없다.

### 3.3 양손 보정 (TIN 값)

원작은 근력만 양손 시 1.5배. **TIN는 모든 스탯에 적용하고 계수를 2.0으로 둔다.**

```gdscript
# two_handed인 무기일 때
effective_stat = stat_value * TUNING["two_hand_requirement_divisor"]   # 2.0
```

- 양손은 **요구치 충족 판정에만** 적용한다.
- 양손은 **스케일링 계산에는 적용하지 않는다.** (원작과 동일 구조)
- 단손/양손은 무기 데이터에 있다. 플레이어 선택이 아니라 **자동 전투 AI가 고른다.**

### 3.4 요구치 미달 페널티 (핵심 규칙)

```gdscript
unmet = [stat for stat in requirement if effective_stat(stat) < requirement[stat]]

if unmet.is_empty():
    requirement_penalty = 1.0
    arts_enabled = true
else:
    requirement_penalty = TUNING["requirement_penalty"]     # 기본 0.55
    arts_enabled = false
```

- 데미지 배율 `requirement_penalty` 적용.
- **전투기술(art) 전부 비활성.**
- 손패(방어) 시 상대 공격이 튕긴다 → `toughness` 저하와 별도로 처리.
  `04` §7.3 참조.
- 촉매(손패 아님) 계열은 주문 사용 불가.

> 이 규칙이 이 Kit의 빌드 강제 장치다. 스탯을 안 찍으면 무기가 안 열린다.

---

## 4. 데미지 타입 5

원작의 물리/화염/번개/마력/어둠. **TIN은 이 5개를 그대로 쓴다.**

| id | 이름 | 기호 | 성격 |
|---|---|---|---|
| `physical` | 물리 | — | 방어력으로 Mostly 감소..superarmor 무기 예외 |
| `fire` | 화염 | `φ` | 위력 스케일링 가능. 내구로 약화 |
| `lightning` | 번개 | `ϟ` | 위력/신앙 스케일링 |
| `arcane` | 마력 | `✶` | 지혜 스케일링. 주문 사용 시 필요 |
| `shadow` | 어둠 | `☾` | 신앙 스케일링 |

- 모든 타입은 **동시에** 계산한다. `"damage": {"physical": 40, "fire": 12}`.
- 무기는 1~2 타입만 가진다. 5개 전부 갖는 무기는 없다.
- 0이 아닌 타입 합이 `base_total`이 된다.
- 방어는 **타입별로 독립 적용**한다. → §4.5. (합산하지 않는다)

### 4.1 데미지 파이프라인 (10단계, 유일한 정의)

```text
1. effective_stat 계산       §3.3 (양손은 요구치 판정에만)
2. requirement 판정           §3.4  → requirement_penalty, arts_enabled
3. scaling_ratio 계산         §4.2
4. base_total 계산            Σ type damage
5. upgrade_additive 계산      §4.4
6. affix_additive / affix_mult 계산   §5
7. damage_pre = base_total
                 × (1 + scaling_ratio)        # 3
                 × (1 + upgrade_additive)     # 5
                 × (1 + Σ affix_additive)     # 6
                 × Π affix_mult               # 6
                 × requirement_penalty         # 2
8. defense 적용               §4.5
9. stance 적용                §7.2
10. status 축적               §8
```

**이 수식이 유일하다.** 다른 곳에서 `damage_pre` 를 다시 정의하지 않는다.
파이프라인 7단계는 `base_total` 이 0 이면 결과도 0 이다 (0 나눗셈 없음).

### 4.2 scaling_ratio

```gdscript
scaling_factor = Σ ( stat_curve.effective(effective_stat[s], tuning) * scaling[s] )
scaling_sum    = Σ scaling[s]                       # 무기 데이터의 가중치 합
NORMALIZER     = stat_curve.effective(knee_b, tuning)   # 32.5
scaling_ratio  = scaling_factor / (NORMALIZER * maxf(scaling_sum, 0.0001))
```

- `NORMALIZER` 은 **`effective(knee_b)` = 32.5.** `knee_b`(45)가 아니다.
- `scaling` 이 비어 있으면 `scaling_factor = 0` → `scaling_ratio = 0`.
  `maxf(..., 0.0001)` 로 0 나눗셈을 막는다.
- 게이지:
  ```text
  스텟 0                      scaling_ratio 0.00   → 배율 1.00
  스텟 20 (=knee_a)           scaling_ratio 0.62   → 배율 1.62
  스텟 45 (=knee_b)           scaling_ratio 1.00   → 배율 2.00
  스텟 99                     scaling_ratio 1.25   → 배율 2.25
  ```
- 상한이明确的하다: 스케일링만으로 **최대 ×2.25**. 데미지가 66배가 되지 않는다.

### 4.3 어긋남: 스케일링 없는 무기

`scaling_ratio = 0` 이므로 `damage_pre = base_total × (1 + upgrade_additive) × ...`
강화와 어펙스만 반영된다. 초반 무기가 이 경로다.
→ 스텟을 올려도 스케일링 없는 무기는 안 강해진다. **AI가 다른 무기로 바꾼다.** `05` §3

### 4.4 강화 가산 배율 (TIN)

```gdscript
# §6 상세. 무기 upgrade_level 0..10
upgrade_additive = tuning["upgrade_additive_per_level"] * upgrade_level    # 기본 0.08
```

- 무기 강화는 `base_total`에 대한 **가산 배율**로 들어간다.
- 상한 10. 10강이면 `+80%`.
- **스케일링을 우회하지 못한다.** 스텟을 안 찍은 무기를 10강해도 약하다.
  → 원작은 근접 10강이 2배. TIN는 1.8배에 그친다. 다른 선택.

### 4.5 방어 적용 (타입별 독립 곱)

```gdscript
damage_post = 0.0
for t in DAMAGE_TYPES:
    var d: float = clampf(defense_ratio(target, t), 0.0, TUNING["defense_max"])
    damage_post += damage_pre_by_type[t] * (1.0 - d)
```

- `damage_pre_by_type[t]` 는 7단계 결과를 **타입별로 나눠서** 저장한 값.
  (`Σ_t damage_pre_by_type[t] == damage_pre`)
- 타입별 방어를 독립 적용해 더한다. **합산 나눗셈을 하지 않는다.**
  → 0 나눗셈이 발생하지 않는다.
- 예: 물리 100 / 화염 20, 방어 물리 0.30 / 화염 0.00
  → `100*0.7 + 20*1.0 = 90`
- `defense_ratio` 범위 `0.0 ~ defense_max`(기본 0.95). 0.95 초과 불가 → 무적 아님.
- **방어 0 은 "무효"가 아니라 "완전 통과"다.** 상성(속성 상성표)은 Phase 2.
  → `17` Q1. Phase 1 에서 상성 판정은 **존재하지 않는다.**

### 4.6 상성 (Phase 2)

- 상성표는 `content/tuning/affinity.json` 에 둔다.
- `17` Q1 확정 전까지 Phase 1 은 상성 없는 독립 방어만 구현한다.
- 어긋남을 만들려면 무기 `damage_additive` 로 방어 0.95 인 타입을 조합한다.
  → 상성 없이도 타입별 역할이 생긴다.

---

## 5. 어펙스 = 강화로 추가된 내용

사용자 확정: `어펙스 기호는 그 무기를 강화했을때 강화된 내용.`
원작의 `aL` `dL` `D/A` `dX/ax` 표기를 **쓰지 않는다.** 그건 위키 표기법이다.

### 5.1 어펙스 스키마

```gdscript
{
  "id": &"aff_scorch",
  "tier": 2,                              # 1..5
  "damage_additive": {&"fire": 0.15, &"physical": 0.0},
  "damage_multiplicative": 1.0,           # 반지류 전역 배율. 곱으로 쌓임
  "scaling_delta": {&"strength": 0.10},   # 스케일링 가중치 이동
  "requirement_delta": {&"strength": -3}, # 요구치 완화
  "attack_frames_delta": -4,              # 공속(프레임 단축)
  "poise_damage_delta": 6,
  "guard_break_delta": 4,
  "status_add": {&"bleed": 0, &"poison": 12, &"frost": 0},
  "requirement_met": true,                # true면 능력 강화형(전투기술 등)
  "text": "화염 피해 15% 증가",
}
```

### 5.2 어펙스 필드 규칙

- `damage_additive` 는 0.0 ~ 1.0 범위, 타입별.
- `damage_multiplicative` 는 0.5 ~ 3.0 범위. 여러 개는 **곱한다.**
- `scaling_delta` 합은 무기 스케일링 합이 1.0을 넘지 않게 제한한다.
  (합 > 1.0이면 정규화)
- `requirement_delta` 는 요구치를 **완화만** 한다. 강화는 요구치를 올리지 않는다.
- `status_add` 는 한 어펙스에서 1개 타입만. (축적 중복 방지)
- `text` 는 UI 표시용. **도메인 판정에 문자열을 쓰지 않는다.**

### 5.3 어펙스 획득 경로

| 경로 | 조건 |
|---|---|
| 무기 강화 | `upgrade_level`이 `tier`에 도달 |
| 제작 | 레시피 결과에 어펙스 시드 부착 |
| 전설 보상 | 전설 엔딩이 직접 부여 |
| 부스트 | Lost Item 계열 |

**어펙스 시드**: `affix_seed = hash(weapon_id, upgrade_level, enchant_ids, slot_side)`
→ 같은 입력은 항상 같은 어펙스. `07_ITEMS_ABILITIES_CRAFTING.md` §4.

### 5.4 상속 규칙

- 장비 교체로 어펙스는 **옮겨가지 않는다.**
- 분해(돌 7)로 어펙트를 떼어낼 수 있다. 떼면 무기에서 제거되고 인벤토리 보존.
- 융합(돌 8)으로 어펙트 2개를 합칠 수 있다. 결과는 `tier = max(tier_a, tier_b) + 1`,
  최대 5. 두 어펙트의 `damage_additive` 를 **더한다** (곱하지 않는다).

---

## 6. 무기 강화 (upgrade)

```gdscript
"upgrade": {
  "level": 4,               # 0..10
  "max": 10,
  "material": &"mat_ash",   # 분해 산출물
  "cost_curve": [1, 1, 2, 3, 5, 8, 13, 21, 34, 55],   # 다음 단계 필요 개수
}
```

- `cost_curve`는 인덱스가 현재 레벨. `cost_curve[level]`가 다음 단계 필요 수.
- 등급 상한 10.
- 강화는 **재사용 불가** (소모).
- 상위 5강부터 어펙트가 붙는다. `affix_tier_gate = [5, 6, 7, 8, 9, 10]`.

> 원작의 2^N(1024) 표는 복제하지 않는다. 여기서는 선형-피보나치 곡선을 쓴다.

---

## 7. 방어 · 스탠스

### 7.1 스탠스 3종

| id | 이름 | 발동 | 효과 |
|---|---|---|---|
| `guard` | 가드 | 입력 유지 | 데미지 배율 0.35, 기력 소모, 기력 게이지 소모 |
| `evade` | 회피 | 입력, 쿨다운 1.0초 | 0.4초 무적 이동, 기력 1칸 |
| `superarmor` | 슈퍼아머 | 상시(무기 스탯) | 받는 데미지 ×1.15, 넉백 없음, 기격 경직 없음 |

- `superarmor`는 무기 `poise` 값이 임계 이상일 때 자동 발동.
  → 원작의 대형 무기 슈퍼아머 구조. 수치는 TIN.
- 자동 전투 AI가 `guard` / `evade` / `dash` 를 고른다. 플레이어는 개입 가능.

### 7.2 데미지 배율 합성

```gdscript
stance_multiplier = 1.0
if guard and stamina_ok:    stance_multiplier *= TUNING["guard_mult"]          # 0.35
if superarmor:              stance_multiplier *= TUNING["superarmor_damage"]  # 1.15
if target.evading:          damage = 0
```

### 7.3 기력 (stamina)

- `max_stamina = TUNING["stamina_base"] + stat_curve.effective(grit) * TUNING["stamina_per_grit"]`
  기본 `stamina_base = 80`, `stamina_per_grit = 0.9`.
- 스태미나 소모: 가드 기본 12, 회피 34. **일반 공격은 소모하지 않는다.**
- `stamina < required` 인 스탠스는 **발동 불가.** AI는 이를 보고 선택한다.
- 기력 0 상태에서는 가드·회피 불가. **무방비.** → SSR 스타일 위험 구간.

### 7.4 기격 (poise) · 넉백

```gdscript
poise_damage = weapon.poise_damage + affix_total_poise_damage
if poise_damage > target.poise:
    target.stagger_frames = TUNING["stagger_frames"]     # 기본 22
    target.staggered = true
else:
    target.knockback = weapon.knockback
```

- 경직(경직) 중에는 AI 행동 불가. 상태 기계의 `stagger` 상태로 강제 전이.
- 넉백은 `distance` 단위 정수 이동.

### 7.5 사망

```gdscript
if target.hp <= 0:
    target.alive = false
    encounter.on_death(target)   # 드랍 결정은 06의 생성기가 아니라 여기서
```

- 사망은 `tick` 처리 순서 8단계.

---

## 8. 상태 축적 3종

원작의 출혈/독/서리. TIN도 이 3종.

| id | 이름 | 축적 기본 | 축적 스탯 | 디바운스(%) | 디버프 |
|---|---|---|---|---|---|
| `bleed` | 출혈 | 0 | 직감 | 0 | 축적 100 도달 시 터짐, 데미지 후 기력 감소 |
| `poison` | 독 | 0 | 직감 | 20 | 지속 데미지(틱당), 방어력 감소 |
| `frost` | 서리 | 0 | 직감 | 0 | 축적 100 시 공격 프레임 증가(슬로우) |

### 8.1 축적 공식

```gdscript
rate = (weapon.status[t] + affix_total_status[t]) * status_rate(player, t)
status_rate = 1.0 + stat_curve.effective(instinct, tuning) * TUNING["status_instinct_gain"]   # 0.012
target.status[t] = min(100, target.status[t] + rate * (1.0 - target.status_resist[t]))
```

### 8.2 터짐 공식

```gdscript
if target.status[t] >= TUNING["status_threshold"]:     # 100
    damage = kick_damage * TUNING["status_damage_ratio"]   # 기본 0.35, kick_damage는 터뜨린 타격 데미지
    damage = damage * (1.0 + stat_curve.effective(instinct, tuning) * TUNING["status_damage_instinct"])
    target.status[t] = 0
```

→ 원작 "출혈이 터졌을 때 유발시킨 무기의 강화수치에 따라 피해"의 구조는 가져오되
계수·식이 TIN 것이다. `07` 에서 확정.

### 8.3 디버프

| 상태 | 지속 | 효과 |
|---|---|---|
| `chill` | 240프레임 | 공격 프레임 +30% |
| `poison_dot` | 300프레임 | 6프레임마다 `poison` 데미지 |
| `bleed_stagger` | 22프레임 | 기격 무시, 이동 불가 |
| `weaken` | 300프레임 | 받는 데미지 +12% |

- 디버프는 `chill`처럼 **상태 시간 배율**로 작동한다.
  → `03_SIMULATION.md` §4 적 상태 기계의 `state_time` 증가에 반영.
- 축적형(`poison_dot`)과 시간 배율형(`chill`)을 분리한다.

---

## 9. 주문 (arcane)

- 주문은 `focus` 슬롯에 들어간다. 슬롯 수는 `focus` 스텟이 결정 (§2.1).
- 주문은 `arcane` 데미지 타입을 낸다.
- 주문 사용 시 `focus` 소모. 소모량은 주문 데이터.
- `focus`가 0 이하면 주문 사용 불가.
- 주문 스크롤(소모품) → 주문 인벤토리 분리. 상점/드랍으로 획득.
- **마술/주술/기적 3분류는 TIN에서 1분류로 통합한다.** (속성은 5타입으로 통일)
  분류가 늘면 UI 복잡도만 오른다. → `17` Q2에서 사용자 확인 요청.

### 9.1 주문 능력 3형

| 형태 | 대상 | 지속 |
|---|---|---|
| `projectile` | 지정 방향 | 즉시 판정 |
| `buff_self` | 자신 | 600프레임 |
| `heal_other` | 아군 | 즉시 판정 |

- 버프는 `damage_multiplicative`와 같은 방식으로 **곱**한다.
- 같은 이름 버프 중복 적용 금지(가장 강한 것 유지).

---

## 10. 튜닝 블록

**모든 수치는 코드가 아니라 콘텐츠에서 읽는다.**

`content/tuning/combat.json`

```json
{
  "knee_a": 20.0,
  "knee_b": 45.0,
  "slope_b": 0.50,
  "slope_c": 0.15,
  "two_hand_requirement_divisor": 2.0,
  "requirement_penalty": 0.55,
  "upgrade_additive_per_level": 0.08,
  "affix_additive_cap": 3.0,
  "affix_multiplicative_product_cap": 4.0,
  "status_instinct_gain": 0.012,
  "status_threshold": 100.0,
  "status_damage_ratio": 0.35,
  "status_damage_instinct": 0.008,
  "status_resist_max": 1.0,
  "guard_mult": 0.35,
  "guard_cost": 12,
  "evade_cost": 34,
  "superarmor_damage": 1.15,
  "superarmor_poise_threshold": 40,
  "stagger_frames": 22,
  "stamina_base": 80,
  "stamina_per_grit": 0.9,
  "stamina_regen_per_tick": 0.60,
  "stamina_regen_delay": 45,
  "evade_cooldown_frames": 30,
  "evade_iframes": 12,
  "defense_max": 0.95,
  "hp_base": 40,
  "hp_per_vitality": 3.0,
  "focus_base": 20,
  "focus_per_mind": 1.0,
  "weight_per_toughness": 1.2,
  "max_level": 60,
  "xp_base": 100,
  "xp_growth": 1.35,
  "loop_min_hp": 1
}
```

### 10.1 규칙

- 코드에 숫자 리터럴로 남는 튜닝값은 **테스트 전용**이다.
- 세이브에 `tuning_signature`(해시)를 함께 저장한다. 불일치 시 `load` 거부하고 초기화.
- 튜닝을 바꿀 수 있는 위치는 `content/tuning/` 뿐이다.
- 밸런스 수치는 확정하지 않는다. Phase 4에서 실측 후 확정한다.
- **이 블록이 튜닝의 단일 정본이다.** 다른 문서에 숫자를 중복해서 쓰지 않는다.

### 10.2 superarmor 판정

`poise_thresholds` 테이블은 쓰지 않는다. 단일 정수 하나로 판정한다.

```gdscript
if weapon.poise >= TUNING["superarmor_poise_threshold"]:
    stance |= SUPERARMOR
```

---

## 11. 누락 공식 확정

감사에서 "에이전트가 임의로 만들어야 하는" 항목. 전부 TIN 값으로 확정한다.

### 11.1 최대값 공식

```gdscript
hp_max      = floori(TUNING["hp_base"]     + stat_curve.effective(stats["vitality"]) * TUNING["hp_per_vitality"])
focus_max   = floori(TUNING["focus_base"]  + stat_curve.effective(stats["focus"])      * TUNING["focus_per_mind"])
stamina_max = floori(TUNING["stamina_base"]+ stat_curve.effective(stats["grit"])       * TUNING["stamina_per_grit"])
max_weight  = floori(stat_curve.effective(stats["toughness"]) * TUNING["weight_per_toughness"])
```

- `hp_max` 는 레벨에 무관. `vitality` 만으로 결정.
- 소수는 내림. 최소 1.

### 11.2 기력 회복 (이전에는 규칙이 없었다)

```gdscript
# 03_SIMULATION 2단계에서 함께 처리
if tick - last_stamina_spend_tick >= TUNING["stamina_regen_delay"]:
    stamina = mini(stamina_max, stamina + TUNING["stamina_regen_per_tick"])
```

- 틱마다 회복. `0.60` x 30 = 초당 18.
- 지연 45프레임(1.5초).
- **가드는 홀드이지 1회 소모가 아니다.** -> `11_INPUT.md` §3A.
- 기력 0 도 회복된다. 회복되면 AI 가 다시 가드를 고른다.
- `last_stamina_spend_tick` 은 진행 상태. `02` §8 에 저장.

### 11.3 레벨 · 경험치

```gdscript
const MAX_LEVEL: int = 60
func xp_to_next(level: int) -> int:
    return floori(TUNING["xp_base"] * pow(TUNING["xp_growth"], level - 1))
```

```gdscript
func gain_xp(state, amount: int) -> int:
    var gained := 0
    while state.player.level < MAX_LEVEL and state.player.xp >= xp_to_next(state.player.level):
        state.player.xp -= xp_to_next(state.player.level)
        state.player.level += 1
        state.player.stat_points += 1
        gained += 1
    if state.player.level >= MAX_LEVEL:
        state.player.xp = 0
    return gained
```

- `MAX_LEVEL = 60`. 스탯 상한 99 는 그 이후에도 배분한다.
- `chest_cap` 테이블은 60 레벨까지 있어야 한다. -> `07` §5.1

### 11.4 상태 축적 -> 디버프 매핑

| 축적 | 100 도달 시 | 지속 |
|---|---|---|
| `bleed` | `bleed_stagger` 22프레임 | 적 |
| `poison` | `poison_dot` 300프레임 | 적 |
| `frost` | `chill` 240프레임 | 적 |

- 축적은 **적에게만** 쌓인다. 플레이어에게는 쌓이지 않는다.
- `kick_damage` 정의: 축적을 100 이상으로 만든 **그 1회 판정**의
  방어/스탠스 적용 **전** 데미지.
- DoT 와 투사체는 `status_build` 가 0 이다. 축적을 만들지 않는다.

### 11.5 어펙스 수량 · 상한

```gdscript
const AFFIXES_PER_WEAPON: int = 4
const AFFIX_TIER_GATE: Array[int] = [5, 7, 8, 9]
```

- 최대 4개. 강화 5 / 7 / 8 / 9 단계에서 1개씩 확정.
- 10강은 4개를 모두 얻은 상태.
- `Σ damage_additive` 상한 `affix_additive_cap = 3.0`.
- `Π damage_multiplicative` 상한 `affix_multiplicative_product_cap = 4.0`.
  초과 시 잘라낸다. 오버플로 방지.

### 11.6 어펙스 시드 4개 (저장 명세)

`02` §5 의 ItemState 를 다음으로 바꾼다.

```gdscript
"affix_seed": { "upgrade": 0, "left": 0, "right": 0, "boost": 0 }
```

- `slot_side` 는 작업대 슬롯 인덱스가 아니라 **시드 키**다.
  세이브 후에도 좌우 선택이 재현된다. -> `12` §5 D8.

### 11.7 결정론 RNG 계약

```gdscript
# systems/rng.gd  -- 이 Kit 은 이것만 쓴다
const MASK: int = 0x7FFFFFFF
static func mix(a: int, b: int) -> int:
    var x: int = (a ^ (b * 0x9E3779B1)) & MASK
    x = ((x ^ (x >> 15)) * 0x2545F491) & MASK
    x = ((x ^ (x >> 13)) * 0x27220A95) & MASK
    return (x ^ (x >> 16)) & MASK
static func stream(seed_value: int, tag: String) -> PackedInt64Array:
    var s: int = mix(seed_value, hash(tag))
    var out := PackedInt64Array()
    for i in 48:
        s = (s ^ (s << 13)) & MASK
        s = (s >> 17) & MASK
        s = (s ^ (s << 5)) & MASK
        out.append(s)
    return out
static func at(st: PackedInt64Array, index: int) -> int:
    return st[index % st.size()]
```

- `hash()` 는 **시드 조합에만** 쓴다. 판정·드로잉에는 쓰지 않는다.
- `randf()` / `randi()` / `Time.get_ticks_*` 금지.
- 스트림은 **상태가 없다.** 재생성 가능. `14` D7 과 일치.
- 스트림 tag (고정 문자열):
  ```text
  region.terrain   region.obstacle   region.foe_pool
  region.foe_place region.foe_scale region.drop
  shop.stock       affix.upgrade     affix.left
  affix.right      affix.boost       recipe.craft
  texture          sim.roll
  ```
- **뽑는 순서가 고정이다.** 코드 순서를 바꾸면 결과가 바뀐다.
- 48개를 미리 뽑고 순서 소비. 지연 계산 금지.