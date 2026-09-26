# 05 — 플레이어 자동 조종 AI

Stone Story RPG 정의: *"플레이어 캐릭터를 직접 조종하지 않는다. AI가 탐험·전투·약탈을 모두 한다.
그렇다고 idle 게임은 아니다. 물약과 특수 능력은 좋은 타이밍으로 극대화된다."*

→ 이 문서가 그 계약을 구현한다. **플레이어는 직접 공격하지 않는다.**

---

## 1. AI 가 정하는 것 / 정하지 않는 것

| AI 가 정함 | AI 가 정하지 않음 |
|---|---|
| 스탠스 (가드 / 회피 / 무스탠스) | 데미지 수치 |
| 손패 교체 (main / off) | 명중 여부 |
| 주문 사용 / 버프 유지 | 크리티컬 여부 |
| 능력(돌) 사용 | 넉백 방향 |
| 근접 목표 우선순위 | 상태 축적 결과 |
| 이동 (전투 중 접근/후퇴) | 사망 판정 |
| 드랍 수집 여부 | 보상 내용 |

**금지:** AI 가 `damage` 값을 직접 산출하거나, 판정 결과를 미리 알거나,
무적 프레임을 스스로 결정하는 것. AI 는 `intent` 만 낸다.

---

## 2. 목표 스택

`03` §2의 4단계(의도 결정)에서 이 스택을 평가한다.

```gdscript
func decide(state) -> Intent:
    var goal: int = _top_goal(state)
    match goal:
        GOAL.SURVIVE:   return _intent_survive(state)
        GOAL.CLEAR:     return _intent_clear(state)
        GOAL.COLLECT:   return _intent_collect(state)
        GOAL.RETURN:    return _intent_return(state)
    return _intent_clear(state)
```

| 우선위 | goal | 진입 조건 | 이탈 조건 |
|---|---|---|---|
| 1 | `SURVIVE` | hp/max_hp < 0.35, 또는 축적 상태 2종 이상, 또는 기력 0 근접 | 위 3조건 모두 해소 |
| 2 | `CLEAR` | 적 1체 이상 생존 | 전투 종료 |
| 3 | `COLLECT` | 드랍 수집 상자가 2개 이상, 전투 종료 | 수집 완료 |
| 4 | `RETURN` | 그 외 (지역 탐색) | 지역 클리어 |

- 우선위가 높을수록 **무조건 우선.** 예를 들어 hp 20%면 드랍을 버리고 도망간다.
- 이 때문에 `SURVIVE` 진입이 곧 사망이 아니다. 도망 후 회복 후 복귀한다.

---

## 3. 빌드 판독 (자동 전투의 핵심)

AI 는 스탯 배분을 읽고 **쓸 수 있는 무기만** 손에 든다.

```gdscript
func _usable(item_id: String) -> bool:
    var it := catalog.item(item_id)
    for stat in it.requirement:
        if _effective_stat(stat) < it.requirement[stat]:
            return false        # 요구치 미달 → 사용 불가
    return true

func _effective_stat(stat: String) -> int:
    var v: int = state.player.stats[stat]
    return v * TUNING.two_hand_requirement_divisor if _current_is_two_handed(stat) else v
```

### 3.1 손패 선택 우선순위

```text
1. 요구치를 전부 충족하는 무기 중
2. 스케일링 가중치 총합이 가장 높은 것
3. 동점이면 base_total 데미지가 가장 높은 것
4. 동점이면 공속(attack_frames)이 짧은 것
```

- 손패가 1개뿐이고 요구치 미달 → **그 무기로 싸운다** (페널티).
  → `04` §3.4. 그래야 "스탯을 못 찍으면 약하다"가 화면에서 보인다.
- 손패가 2개 →(main/off) 둘 다 요구치 검사 후 위 순위로 배치.
- 중량 초과 조합은 배제. → `02` §3.3

### 3.2 이게 왜 중요인가

원작: "모르면 못 이기고, 공략을 알면 극단적으로 유리."

자동 전투 AI 는 플레이어의 빌드를 **그대로 쓴다.**
그래서 스탯 배분이 자동 전투의 성능을 직접 결정한다.
플레이어가 개입하지 않아도 자기 빌드 결과를 본다.

---

## 4. 스탠스 결정

```gdscript
func _stance(state) -> StringName:
    # 순서가 중요하다. 가드(저비용)를 먼저 검사한다.
    if state.stamina < TUNING["guard_cost"]:
        return &"neutral"                       # 기력 0 근처: 무방비
    if _wants_evade(state) and state.stamina >= TUNING["evade_cost"] \
            and _evade_ready(state):
        return &"evade"
    if _wants_guard(state):
        return &"guard"
    return &"neutral"
```

- `guard_cost = 12` < `evade_cost = 34` 이므로 **가드를 먼저 검사한다.**
  (반대로 쓰면 기력 12~33 구간에서 가드가 도달 불가 상태가 된다)
- `guard` 는 **홀드를 유지하는 스탠스**다. 매 틱 유지 판정을 한다.
  → `11_INPUT.md` §3A. 1회 소모가 아니다.
- `evade` 는 쿨다운이 있다. `evade_cooldown_frames` 경과 후 가능.
- **대형 무기(superarmor) 보유 시 스탠스를 싹 버리고 밀어붙인다.**
  `weapon.poise >= superarmor_poise_threshold` 이면 `return &"neutral"` 을 강제하고
  `superarmor` 플래그만 켠다. → 가드/회피를 동시에 켜지 않는다.
- `_wants_guard` : HP 비율 < 0.6 이고 off-hand 가 있을 때.
- `_wants_evade` : 근접 예고가 들어왔고 쿨다운이 지났을 때.

---

## 5. 주문 결정

```gdscript
func _spell_decision(state) -> int:
    # 0: 유지, 1: 방어 주문, 2: 공격 주문, 3: 회복 주문
    if state.player.focus < _cheapest_cast_cost:   return 0
    if state.buffs_active:                        return 0
    if _hp_ratio(state) < 0.5 and _has_heal(state): return 3
    if _enemy_count(state) >= 3 and _has_aoe(state): return 1
    if _single_target_weakness_match(state):        return 2
    return 0
```

- 위력이 지혜/신앙으로 스케일링되므로 **AI 도 스탯을 읽는다.**
  주문 데미지 예상 = 주문 base × `04` §4.2의 `scaling_ratio`.
- 주문 슬롯 중 **가장 강한 주문부터** 시도. 빈 슬롯은 건너뛴다.

---

## 6. 개입 창 3종 (플레이어 조작면)

플레이어가 실제로 누를 수 있는 것은 이것뿐이다.

| 창 | 발동 조건 | 화면 신호 | 플레이어 입력 | 성공 시 |
|---|---|---|---|---|
| `swap_window` | 적의 약점 속성이 바뀜 (보스 페이즈 전환 등) | 무기 옆 `≡` 1개 깜빡임 | 손패 교체 | 다음 타격에 약점 적용 |
| `potion_window` | 디버프 직전 12프레임 | 대상 위에 `◊` 1개 | 물약 사용 | 디버프 무효화 |
| `ability_window` | 돌 능력 사용 가능 구간 | 화면 하단 `✶` 1개 | 능력 사용 | 즉시 판정 |

### 6.1 창 규칙

- AI 는 창을 **모른다.** 개입하지 않으면 원래 AI 행동을 한다.
- 개입 성공은 **시각·청각 아닌 화면 신호**로만 알린다.
- AI 가 창을 대신 처리하지 않는다. (그러면 개입의 의미가 없다)
- 창은 **1회 소비.** 여러 번 눌러도 한 번만 효과.
- 창이 겹치면 우선순위: `potion_window` > `swap_window` > `ability_window`.

### 6.2 물약

- 물약은 소모품 인벤토리. `inventory.materials` 와 별도.
- 물약 종류 3: `heal` / `cleanse` / `haste`(공속).
- 개입 없이도 AI 는 **가장 시나리오가 나쁜 시점**에 자동 사용한다.
  (원작: "물약과 특수 능력은 좋은 타이밍으로 극대화된다" → 자동 사용은 최적이 아니다)

### 6.3 능력 (소울스톤)

- 능력은 `09` §3. 돌별 1개.
- 발동 쿨다운 프레임소유.
- `Mind` 계열 돌의 능력(대시·회피)은 AI 도 쓸 수 있다. → 무조건 유리.

---

## 7. 수집 AI

```gdscript
func _collect_order(state) -> Array[String]:
    return chest_ids_sorted_by(state, key = distance_from_player, reverse = false)
```

- 클리어 후 상자를 가까운 순으로 연다.
- 개수는 1개/틱. **동시에 여러 상자를 열지 않는다.** (UI 1개만 열림)
- 상자를 여는 중에도 다음 상자로 이동할 수 있다.

---

## 8. AI 결정 로그 (디버그, release 비노출)

```gdscript
# release 빌드에서 꺼진다
var trace: bool = false
var last_intent: Dictionary = {}
```

- `04` §7 의 강제 규칙: "debug label의 release 노출" 금지.
- 개발 중 판단이 필요할 때만 `trace = true` 로 켠다.
- 로그에는 `goal`, `reason`, `stance`, `target_id` 만. 데미지 수는 넣지 않는다.

---

## 9. AI 테스트 항목

1. 입력 0으로 전투 완전 진행.
2. `SURVIVE` 진입 시 드랍 무시.
3. 요구치 미달 무기만 있으면 **그 무기로** 싸운다.
4. 가드/회피 스탠스가 기력 부족 시 `neutral` 로 떨어진다.
5. superarmor 무기 장착 시 스탠스를 선택하지 않는다.
6. 주문 슬롯 전부 `null` 이면 주문 미사용.
7. `swap_window` 미사용 시 패널이 닫히고 AI 가 원래 무기로 계속 공격한다.
8. 같은 입력 시퀬 + 같은 시드 → 같은 AI 행동 열.
