# 07 — 아이템 · 강화 · 어펙스 · 제작

---

## 1. 아이템 종류

| kind | 역할 | 손에 드는가 |
|---|---|---|
| `weapon` | 주무기 (1가.hand) | main |
| `shield` | 방어 (보정 없음) | off |
| `catalyst` | 주문 매체 | focus |
| `armor` | 방어구. stats boost | 미착용(레벨시) |
| `consumable` | 물약 · 재료 | 미착용 |
| `material` | 제작 재료 | 미착용 |
| `spell` | 주문 | focus |
| `chest` | 인벤토리 1칸 | 미착용 |

- `armor` 는 장비 중량과 스탟 보정을 준다. 중량 초과로 전투 불가가 된다.
- `consumable`/`material`/`spell`/`chest` 는 `weight = 0`.

---

## 2. 무기 스키마

```json
{
  "id": "item_rusted_sword",
  "kind": "weapon",
  "handedness": "one",               // one | two
  "weight": 6,
  "damage": { "physical": 44, "fire": 0, "lightning": 0, "arcane": 0, "shadow": 0 },
  "scaling": { "strength": 0.65, "dexterity": 0.30 },
  "requirement": { "strength": 24, "dexterity": 12 },
  "attack": {
    "frames": 34,                    // 1회 공격 전체 프레임
    "cast": 12,                      // 선공 프레임 (이 구간에 캐스팅바)
    "reach": 4,                      // distance 단위
    "knockback": 2,
    "poise_damage": 14,
    "guard_break": 8
  },
  "status_build": { "bleed": 0, "poison": 0, "frost": 6 },
  "arts": [ "art_wide_sweep", "art_rally" ],
  "poise": 22,
  "upgrade_max": 10,
  "value": 40
}
```

### 2.1 스케일링 규칙

- `scaling` 가중치 합 ≤ 1.0.
- 합이 0 인 무기도 허용 (초반용).
- `04` §4.2 의 정규화는 `Σ weight` 를 기준으로 한다.

### 2.2 전투기술 (art)

```json
"art_wide_sweep": {
  "name": "광역 참",
  "requirement": { "strength": 20 },
  "frames": 40,
  "damage_mult": 1.4,
  "reach_mult": 2.0,
  "guard_break_mult": 1.5
}
```

- `requirement` 미달 → 사용 불가. `04` §3.4 의 `arts_enabled` 로 묶인다.
- art 는 데미지 **곱** 계수로만 작동. 별도 판정을 하지 않는다.
  → 예외: `art_unmake` 류는 Phase 1 금지. `06` §4.3

---

## 3. 강화 (upgrade)

```gdscript
# 04 §6
"upgrade": { "level": 0, "max": 10, "material": "mat_ash" }
```

- 강화는 `base_total` 에 **가산 배율**로 들어간다. (`04` §4.4)
- 소비: `cost_curve[현재 level]` 개의 재료. 소모.
  기본 `cost_curve = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]` → **10강 총 143개.**
- 어펙스 게이트: `[5, 7, 8, 9]` — 각 단계에서 어펙스 1개. 최대 4개. → `04` §11.5
- `rolled` 결과를 `02` §5 에 저장. 시드 재계산 안 함.

> 원작의 2^N(1024) 표는 복제하지 않는다. 10강 총 소모는 **143** 이다.

### 3.1 재료

| id | 이름 | 출처 |
|---|---|---|
| `mat_ash` | 잿 | 일반 드랍, 지역 기본 |
| `mat_wood` | 나무 | 전환 지역 |
| `mat_ore` | 광석 | 채굴 지점 (Phase 1 최소 구현) |
| `mat_charm` | 조각 | 미니보스 |
| `mat_relic` | 유물 | 보스 확정 드랍 |

- 채굴은 `Phase 1` 에 "상호작용 지점 1개"로 최소 구현한다.
  → `10` §8 화면 목록.

---

## 4. 어펙스 결정론

```gdscript
func affix_seed(weapon_id: String, upgrade_level: int,
                enchant_ids: PackedStringArray, slot_side: int) -> int:
    return _hash(weapon_id, upgrade_level, ",".join(enchant_ids), slot_side)
```

- 어펙스 풀에서 `tier` 별 가중 추첨.
- **오른쪽 슬롯이 결과를 결정.** (`side` 가 시드에 포함된다)
  → 원작 구조 차용. 수치·표기는 TIN.
- `4` 개의 어펙스 시드: `upgrade` / `left` / `right` / `boost` 를 분리.
  합치면 한쪽 변경이 다른 쪽을 깨뜨린다.

```gdscript
var seed_upgrade := affix_seed(id, level, enchants, 0)
var seed_right   := affix_seed(id, level, enchants, 1)
var seed_left    := affix_seed(id, level, enchants, 2)
var seed_boost   := affix_seed(id, level, enchants, 3)
```

---

## 5. 인벤토리 상한

원작: "레벨이 오르면 최대 chest 수 증가."

```gdscript
func chest_cap(level: int, tuning: Dictionary) -> int:
    var table: Array = tuning["chest_cap_by_level"]   # 길이 = 최대 레벨+1
    return table[mini(level, table.size() - 1)]
```

- 기본 테이블: `[2, 3, 4, 5, 6, 8, 10, 12, 15, 18, 22]` (레벨 1~11).
  Phase 4에서 실측 조정.
- 상한은 **도메인 제약.** 초과 시 `add_chest` 실패 + 로그.
- UI가 아니라 규칙이다. `02` §3.3

---

## 6. 제작 4동사

Workbench (제작대). 슬롯 2개 + 버튼.

| 동사 | 입력 | 결과 |
|---|---|---|
| `upgrade` | 같은 아이템 ×2 (같은 upgrade_level) | level +1 |
| `craft` | 다른 아이템 A + B | 레시피 결과 또는 실패 |
| `enchant` | 아이템 + 인인챈트샌트 | 인챈트 부착 |
| `boost` | Lost Item + 복제본 | boost 횟수 +1 |

### 6.1 레시피

```json
// content/recipe/recipes.json
{
  "id": "rec_war_hammer",
  "verb": "craft",
  "inputs": ["item_sword", "item_board_shield"],
  "inputs_order_matters": false,
  "output": "item_war_hammer",
  "output_upgrade_level": 0,
  "chance": 1.0,
  "requires_unlock": "stone_of_knot"      // null 이면 항상 가능
}
```

- `inputs_order_matters: false` 면 좌우로 세도 같다.
  단 **어펙스 결과는 항상 오른쪽이 우선**한다. → `04` §5.3
- `chance < 1.0` 이면 실패가 있다. 실패는 **재료 소모 없음.**
- 레시피는 **인북(製本)으로 인벤토리에 존재한다.** 화면상 `작업대` 패널 좌측 목록.
  → `10` §5.8
- 인북은 `inventory.recipe_book: true` 로 플레이어가 가지는 ** consumable 하나**다.
  (부팅 시 1개 지급. 돌 10 소모로 잃지 않는다)
- `10` §5.8 화면에 레시피 목록 영역을 추가한다.

### 6.2 업그레이드 수량

```gdscript
func upgrade_cost(level: int) -> int:
    return COST_CURVE[level]     # 04 §6 의 cost_curve
```

### 6.3 인챈트

```gdscript
# content/enchant/enchants.json
{
  "id": "ench_keen_edge",
  "name": "날카로운 끝",
  "tier": 2,
  "damage_additive": { "physical": 0.10 },
  "attack_frames_delta": -3,
  "status_add": { "bleed": 8 },
  "text": "물리 +10%, 공속 3프레임 단축"
}
```

- 같은 어펙스/인챈트는 **아이템에 1개만.** 중복 불가.
- 인챈트 위에 인챈트: `tier` 가 낮은 쪽을 버리고 경고 박스를 띄운다.
  → `10` §7 상태 `warning`
- `ench_` 접두어는 능력 강화형. `aff_` 접두사는 일반 어펙스.
  (원작의 표기법을 쓰지 않기 위해 접두어로 구분)

### 6.4 부스트

```gdscript
func boost_cost(times_done: int) -> int:
    return BOOST_BASE * (times_done + 1)     # BOOST_BASE = 250
```

- 최대 8회.
- 5~7성품은 1회, 8은 2회, 9 이상은 3회까지 허용. (원작 규칙)
- `is_lost: true` 인 무기만 부스트 가능. 플래그 이름은 `is_lost` **하나뿐이다.**

---

## 7. 분해 / 융합 (돌 7, 8)

| 동사 | 돌 | 입력 | 출력 |
|---|---|---|---|
| `fissure` | `stone_of_split` | 아이템 1 | 기본 재료 N + (인챈트/어펙트 보존) |
| `fuse_affix` | `stone_of_knot` | 어펙스 2 | 합성 어펙스 1 (tier = max+1) |
| `fuse_enchant` | `stone_of_knot` | 인챈트 2 | 합성 인챈트 1 |

- 분해는 `item.components` 에 authored.
- 융합의 `damage_additive` 는 **더한다** (곱하지 않는다). `04` §5.4

---

## 8. 가치 (value)

```gdscript
func item_value(item: ItemState, tuning: Dictionary) -> int:
    return int(round(item.base_value * (1.0 + 0.15 * item.upgrade_level)
                     * item.affix_count * 1.0))
```

- 상점 가격 인플레이스, 부스트 재료 가치 판정에 쓴다.
- 부스트 재료 가치 종류별 계수는 `tuning.boost_value_weights`.

---

## 9. 제작 화면의 결정 순서

```text
1. 슬롯 좌/우에 아이템을 놓는다 (플레이어 조작)
2. 가능한 동사 4종의 버튼이 각각 활성/비활성으로 보인다
3. 플레이어가 동사를 고른다
4. 파괴적 동사(fissure/boost/fuse)이면 확인 단계를 한 번 거친다
5. 실행 → 결과 판정 → 애니메이션 없이 결과 상태로 직행
6. 결과는 상단에 1줄로만 표시 (박스 없이)
```

### 9.1 파괴적 동사의 확인 단계 (undo 부재의 대체)

이 Kit에 **undo 가 없다.** `12` 참조. 대신 파괴적 동사 3종은
`confirm` 1회로는 실행되지 않고, **2단계 확인**을 거친다.

| 동사 | 1차 confirm | 2차 confirm | 취소 |
|---|---|---|---|
| `upgrade` | 즉시 실행 (재료 소모만) | — | 슬롯 비우기 |
| `craft` | 즉시 실행 | — | 슬롯 비우기 |
| `enchant` | 즉시 실행 | — | 슬롯 비우기 |
| `fissure` | 미리보기 표시 | 실행 | 1단계에서 자동 취소 |
| `boost` | 비용 표시 | 실행 | 1단계에서 자동 취소 |
| `fuse` | 결과 미리보기 | 실행 | 1단계에서 자동 취소 |

- 미리보기 내용: 사라지는 것 1줄 + 생기는 것 1줄.
- 2단계에서 `cancel` 을 누르면 **아무것도 바뀌지 않는다.**
- `10` §5.8 화면에 `confirm_step` 상태를 추가한다.
  `initial`(빈 슬롯) / `preview`(1단계) / `result`(실행 후) 3단계.

### 9.2 결과 표현

- 실패·성공·부족 3상태를 **모두 사운드/모션 없이 텍스트로** 구분한다.
  구분은 문구로. 색으로 하지 않는다. → `10` §4
- 결과는 상단 1줄. 2줄을 넘기지 않는다.
