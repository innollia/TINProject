# 04 — 4속성 · 데미지 · 장비 정책

> **2026-09-26 전면 개정.** 1차 판은 "데미지 타입 5종(물리/화염/번개/마력/어둠)"이었다.
> 사용자가 폐기했다: *"데미지 타입은 물리 화염 번개 마력 어둠이네. 문제임.
> 초현실주의 세계관인데 그런게 나오는건 불가능하지."*
> → 데미지 타입은 **삭제**했다. 개체를 정의하는 것은 **속성 4종**이고,
> 개체 간 상호작용은 **4-사이클 상성**이며, 데미지는 **단일 정수**다.

이 문서는 **실제로 구현된 것**을 기술한다. 구현과 어긋나면 여기가 틀렸다.

---

## 0. 왜 데미지 타입이 아니다

Stone Story RPG 에는 원소 상성이 있다. 그러나 이 게임의 세계관은 초현실주의다.
"불에 강하다" 같은 문장을 그 세계에 놓으면 규칙이 아니라 장식이 된다.

대신 **개체 그 자체를 4개의 수로 정의**한다. 이 수치가 성격과 외형을 동시에 만든다.
→ `systems/attributes.gd`

---

## 1. 속성 4종

| id | 이름 | 범위 | 뜻 | combat 에서 |
|---|---|---|---|---|
| `limbs` | 다리 | 정수 1..12 | 물리적 다리 개수 | 한 턴 행동 수 |
| `surprise` | 놀랍다 | 0..10 | 예측 불가 정도 | 크리티컬 확률, AI 예측 실패 |
| `wrongness` | 틀림 | 0..10 | 규칙을 어기는 정도 | 크리티컬 확률, 경직 무시 |
| `roundness` | 동그라미 | 0..10 | 둥근 정도 | 회피 확률 |

**속성 = 개체 기본값 ⊕ 착용 장비 델타.** (`run_state.gd::gear_defs`)

- `limbs` 는 장비로 **올리기만** 한다 (장비 `attr_delta` 에 limbs 없음, 로더가 error).
- 나머지 3개는 장비로 ± 가능. 음수도 허용.
- 범위 밖 값은 `clamp` 된다.

### 1.1 상성축

각 개체는 `affinity_attr` 하나를 가진다 (`content` authored).
`limbs` / `wrongness` / `roundness` / `surprise` 중 하나.

---

## 2. 놀랍다 — 미스터리한 수치

사용자 결정: *"놀랍다는 약한 상관관계를 지닐 뿐 다른 자잘한 요소들에 따라 달라져.
그중에 가장 큰 상관관계가 크기라서, 미스터리인 수치인데 그나마 크기기준이 있구나 라고
알 수 있는 그런거야. 크기가 엄청 작은 개체도 놀라움 정도가 높을 수 있도록 해.
괴하고 복잡한 식을 정의하자."*

→ **5항 가산 + 폭 스케일 + 시드 미스터리 2층.**

```gdscript
surprise = clamp(round((
      0.34 * pow(inverse_size(size_units), 0.70)   # 크기. 최대 가중치지만 지배적이지 않다
    + 0.21 * (1 - roundness/10)                    # 둥글수록 놀랍지 않다
    + 0.15 * aspect_deviation(w, h)                # 황금비에서 얼마나 벗어났나
    + 0.12 * clamp(motion_events/12, 0, 1)         # 움직임 빈도
    + 0.18 * mystery_a                             # 시드 1
) * (0.75 + 0.5 * mystery_b)                        # 시드 2 = 폭. 단조를 깨서 역산을 막는다
  * 10 + authored_bias), 0, 10)
```

설계상 성질 (테스트가 검증):

| 성질 | 검증 |
|---|---|
| 크기가 최대 상관관계지만 절대다수는 아니다 | `test_a7_not_invertible_from_size_alone` |
| 같은 크기 → 다른 놀랍다 | `test_a7` |
| 극히 작은 개체도 높게 나올 수 있다 | `test_a6` (분포 판정, 시드 고정 금지) |
| 역산 불가 (시드로 흔들림) | `test_s20` (분포 폭 ≥ 2) |
| 결정론 | `test_a5` |

`size_units` / `width_units` / `height_units` / `motion_events` 는 `content` 의
`shape` 블록. **형상 기하의 스케일로 재 쓰지 않는다.** (`critter.gd::_spec` 주의)

---

## 3. 상성 — 4-사이클 하나

```
다리 ──▶ 틀림 ──▶ 동그라미 ──▶ 놀랍다 ──▶ 다리
```

- `beats(a, b)`: a 가 b 를 이기면 배율 **×1.50**
- 지면 배율 **×0.75**
- 같은 축이면 **×1.00**
- 4×4 표(16 조합)는 저작 부담이 커서 **닫지 않는다.** 사이클 1개로 충분.

`attributes.gd::affinity` — 단일 함수.

---

## 4. 데미지 — 단일 정수

무기 `damage` 는 **정수 하나**다. 타입별 딕셔너리는 없다 (로더가 error).

```text
damage_pre = base
           × (1 + scaling_ratio)        # 스탯 스케일링
           × (1 + upgrade_additive)     # 강화
           × (1 + Σ affix_additive)     # 어펙스
           × Π affix_multiplicative     # 어펙스
           × requirement_penalty        # 요구치 미달 시 0.55
→ 방어(타입 없음, 단일 비율) → 스탠스 → 확정
```

`combat.gd::damage_pre` / `resolve_attack` — 이것이 유일한 정의.

### 4.1 스탯 소프트캡

요구치 미달 = 데미지 ×0.55 + 무법 비활성. **약해진 채로 싸운다.**
그래야 "스탯을 못 찍으면 무기를 못 쓴다"가 화면에서 보인다.

`requirement_report(weapon, stats, two_hand_divisor)`
- 양손은 **요구치 판정에만** 2배. 스케일링엔 영향 없음.
- `two_hand_divisor` 는 `combat.json` 값. 2.0.

### 4.2 스탯 소프트캡 곡선

`core.gd::effective` — 무릎 2개, `knee_b` 이후는 **출력값**에서 이어진다 (불연속 방지).
값은 `combat.json`: `knee_a 20 / knee_b 45 / slope_b 0.50 / slope_c 0.15`.
`NORMALIZER = effective(45) = 32.5`.

---

## 5. 상태 축적 3종

`bleed` / `poison` / `frost` — 축적 100 도달 시:
`bleed`→`bleed_stagger` 22프레임 / `poison`→`poison_dot` 300 / `frost`→`chill` 240

- 축적은 **적에게만.** 플레이어에게는 쌓이지 않는다.
- 축적 속도 = 무기 `status_build` × (1 + `instinct` 효과).
- 터짐 데미지 = `kick_damage` × 0.35 × (1 + `instinct` 효과).
- `kick_damage` 는 축적을 100 이상으로 만든 **그 1회 판정**의 방어 적용 전 데미지.
  DoT 틱과 투사체는 `status_build` 가 0 이므로 축적을 만들지 못한다.

> 상태 3종의 **이름**은 아직 확정 아니다. (§G of 17_OPEN_QUESTIONS, B2)

---

## 6. 스탠스

| id | 발동 | 효과 |
|---|---|---|
| `guard` | **홀드 유지** | 데미지 ×0.35, 기력 12/틱 소모 |
| `evade` | 쿨다운 | 0.4초 무적, 기력 34 |
| `superarmor` | 무기 `poise` ≥ 40 | 데미지 ×1.15, 넉백·경직 없음 |

- `guard` 는 **입력 홀드**다. 유일한 홀드 예외. (`11_INPUT.md` §3A)
- 기력 회복: 45프레임 지연 후 틱당 +0.6.
- **기력 0 = 무방비.** 가드·회피 불가. (`superarmor` 는 무시 가능)
- AI 가 스탠스를 고른다. 플레이어는 아니다. → `05_PLAYER_AI.md`

---

## 7. 장비 = 유일한 간접 조종

사용자 결정: *"AI의 움직임을 장비를 통해 간접적으로 조종할 더 많은 방법이
확보될 필요 있음."* (Stone Story 의 짝퉁 방지)

### 7.1 데이터 — `policy_delta` 14키

| 키 | 종류 | 합성 |
|---|---|---|
| `guard_min_hp` | 수치 | max |
| `evade_hp_max` | 수치 | max |
| `retreat_hp_below` | 수치 | max |
| `potion_at_hp` | 수치 | max |
| `use_ability_below_hp` | 수치 | max |
| `actions_turn_mod` (`actions_per_turn_mod`) | 정수 −3..3 | **합** |
| `evade_cooldown_mod` | 정수 −3..3 | **합** |
| `focus_priority` | `lowest_hp`/`highest_threat`/`nearest`/`ranged_first`/`biggest` | 뒤 장비 우선 |
| `open_with` | `attack`/`evade`/`guard`/`ability` | 뒤 장비 우선 |
| `counter_attr` | 속성 4 id | 뒤 장비 우선 |
| `potion_on_debuff` | 상태 id | 뒤 장비 우선 |
| `never_retreat` | bool | OR |
| `always_guard` | bool | OR |
| `superarmor_always` | bool | OR |

- 수치 키는 **max** (겹쳐도 무한 강해지지 않는다). 수정 키만 **합**.
- `never_retreat` 이면 `retreat_hp_below` = 0.
- `retreat_hp_below > evade_hp_max` 이면 후퇴를 내린다 (회피가 죽지 않게).

### 7.2 코드 예외 — `policy_hook` 5종

데이터로 표현이 안 되는 소수. `gear_policy.gd::policy_hook`
`hook_never_turn_back` / `hook_body_wall` / `hook_counter_hunt` /
`hook_counter_shatter` / `hook_multi_limb`

**Kit 로컬이다.** `core/` 를 건드리지 않는다.

### 7.3 어펙스 = 강화로 추가된 내용

사용자 결정: *"어펙스 기호는 그 무기를 강화했을때 강화된 내용."*

→ 원작의 `aL` `dL` `D/A` `dX/ax` 표기는 **쓰지 않는다.** 그건 위키 표기법이다.
어펙스 하나가 실제로 추가하는 것:

```json
{ "id": "aff_keen", "damage_additive": 0.12, "attr_delta": { "surprise": 2 },
  "scaling_delta": { "dexterity": 0.08 }, "attack_frames_delta": -3,
  "text": "피해 12%, 놀랍다 +2, 공속 3프레임 단축" }
```

- 같은 어펙스/인챈트는 아이템당 1개. 중복 불가.
- 어펙스 시드는 4개: `upgrade` `left` `right` `boost`. `slot_side` 는 시드 키.
- 어펙스는 **인스턴스가 아니라 콘텐츠 정의**에 있다. `gear_defs()` 가 병합한다.
  (2026-09-26에 이를 빠뜨려 "장착해도 아무것도 안 바뀌는" 버그가 났었다)

---

## 8. 튜닝 단일 정본

`content/tuning/combat.json` — 50개 키. 코드에 숫자 리터럴로 남는 튜닝값은 **없다.**
세이브에 `tuning_signature` 저장. 불일치 시 로드 거부 + 초기화.

---

## 9. 구현 위치

| 책임 | 파일 |
|---|---|
| 4속성 · 놀랍다 · 상성 · 행동 도출 | `systems/attributes.gd` |
| 장비 → AI 정책 | `systems/gear_policy.gd` |
| 데미지 파이프라인 · 상태 축적 · 스탠스 | `systems/combat.gd` |
| 소프트캡 곡선 | `systems/core.gd::effective` |
| 파생값 공식 (hp/focus/stamina/weight) | `systems/tuning.gd` |
| 인스턴스+정의 병합 | `domain/run_state.gd::gear_defs` |

## 10. 테스트

`tests/core/test_stone_story_rpg_core.gd`
A(속성 10) · P(장비 정책 7) · C(전투 12) · B(상태 축적 4) · S(상태기계 4) ·
G(밴드 3) · S2(세이브/인벤토리/XP 4) · V(돌 2) · M(모듈 4) · P(렌더 2)

## 11. 금지

- 데미지 타입 재도입
- 어펙스 표기법(`aL` 등) 사용
- 튜닝값의 코드 리터럴화
- `damage` 를 딕셔너리로 되돌리기
- `attr_delta` 에 `limbs` 허용
- 어펙스/정책을 인스턴스에 저장
