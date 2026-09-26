# 02 — Domain State

게임 상태가 진실이다. presentation 노드는 이 상태의 표현이며, 이 상태를 소유하지 않는다.

---

## 1. JSON-safe 규칙

`SaveService`가 강제한다. 이 Kit이 지키는 부분:

| 허용 | 금지 |
|---|---|
| string key Dictionary | Node |
| string / int / float / bool / null | Resource |
| Array | Callable |
| 유한 float (`NaN`, `Inf` 금지) | Vector2 그 자체 |

모든 좌표는 `{"x": int, "y": int}` 다. `Vector2i` 를 저장하지 않는다.
모든 프레임 값은 **정수 프레임** 이다. 실수 초를 저장하지 않는다.

---

## 2. 최상위 상태

```gdscript
# domain/run_state.gd
{
  "state_format": "ssr_run_v1",
  "save_version": 1,
  "tuning_signature": "a1b2c3",
  "run_id": "r-000042",
  "run_seed": 123456789,
  "star_level": 5,
  "region_id": "region_unused",
  "tick": 0,
  "respec_used": 0,
  "player": { ... },
  "world": { ... },
  "encounter": { ... } | null,
  "screen": "field",
  "flags": { String: bool },
}
```

- `screen` 은 진행 중 화면(마지막으로 열린 프레임). 진행 의미가 있는 것만 저장.
  커서 위치·스크롤·선택 하이라이트는 저장하지 않는다.
- `tuning_signature` 불일치 시 `load` 거부 → 초기화. → `04` §10.1

---

## 3. player

```gdscript
{
  "level": 7,
  "xp": 240,
  "hp": 86, "hp_max": 137,
  "focus_pool": 38, "focus_max": 56,
  "stamina": 52, "stamina_max": 97,
  "last_stamina_spend_tick": 1840,
  "stats": {
    "vitality": 26, "focus": 18, "grit": 21, "toughness": 15,
    "strength": 24, "dexterity": 12, "intellect": 8, "devotion": 6, "instinct": 14,
  },
  "stat_points": 0,
  "class_id": "class_ashbound",
  "pos": {"x": 0, "y": 0},
  "facing": 0,
  "stones": { "stone_of_sight": {"held": true, "equipped": true} },
  "loadout": {
    "main": "item_rusted_sword",
    "off": "item_board_shield",
    "focus_slot": 2,
  },
  "chests": [ ChestState ],
  "spells": ["spell_ember_bolt", null, null],
  "inventory": {
    "materials": { "mat_ash": 14, "mat_wood": 3 },
    "enchants": [ EnchState ],
    "affixes": [ AffixState ],
  },
  "discovered": { "foe_husk_scrapper": true },
}
```

### 3.0 이름 규칙 (혼동 방지)

| 이름 | 뜻 | 저장 위치 |
|---|---|---|
| `player.focus_pool` | 지금 남은 주문 자원 | `player` 직속 |
| `player.focus_max` | 최대 주문 자원 | `player` 직속 |
| `player.stats.focus` | **스탯** (`정신`) | `player.stats` |
| `focus_slots` | 주문 슬롯 개수 | 파생 (§04 §2.1) |

- `focus` 라는 키는 `stats` 안에만 존재한다. `player` 직속에는 없다.
- 코드는 자원 접근 시 `focus_pool`, 스탯 접근 시 `stats["focus"]`.
  두 곳을 같은 지역 변수로 받지 않는다.

### 3.1 stat_points

- 레벨업 시 +1. `stat_points` 에 쌓는다.
- **스탯 배분 UI는 이 값을 쓰는 화면이다.** 상시 HUD 아니다. 호출형.
- `class_id` 의 시작 스탯은 `13_CONTENT_SCHEMA.md` §9.

### 3.2 spells

- 길이는 `focus` 스탯으로 정해지는 슬롯 수(§04 §2.1). 저장 시 현재 배열 길이.
- `null` 은 빈 슬롯.

### 3.3 loadout

- `main` / `off` 는 아이템 ID 또는 `null`.
- 전투 AI가 §05의 규칙으로 **교체**한다. 플레이어도 개입 가능.
- 장비 중량 `> max_weight` 이면 `loadout` 이 유효하지 않다.
  → 전투 진입 불가, 상태 화면에 `무기 불가` 표시.

---

## 4. ChestState

**`chest` 는 아이템 종류가 아니다.** 인벤토리의 **컨테이너 칸**이다.
`item.kind` 에 `chest` 를 두지 않는다. → `13` §6.

```gdscript
{
  "tier": "giant",               # common | giant | omega | delta  (닫힌 어휘 4개)
  "seed": 555,
  "items": [ ItemState ],
  "materials": { "mat_ash": 3 },
  "opened": false,
}
```

- 인벤토리 상한 `chest_cap = f(level)`. → `07` §5.
- `chest_cap` 은 **저장하지 않는다.** 레벨에서 파생한다.
- `chest_cap` 초과분은 `load` 시 초과분을 잘라낸다 (안전).
- 등급은 4개 고정. → `08` §2 가격표와 1:1.

---

## 5. ItemState

```gdscript
{
  "item_id": "item_rusted_sword",
  "upgrade_level": 3,
  "affix_ids": ["aff_scorch"],
  "enchant_ids": ["ench_keen_edge"],
  "affix_seed": { "upgrade": 111, "left": 222, "right": 333, "boost": 444 },
  "rolled": { "fire": 12, "physical": 44 },
}
```

- `affix_seed` 는 **4개 정수**다. → `04` §11.6
- `rolled` 은 업그레이드 결과를 **확정한 값**으로 저장한다.
  시드로 재계산하지 않는다. (튜닝 변경에도 저장이 깨지지 않도록)
- 스탯 스케일링은 저장하지 않는다. **실행 시 계산**한다.
- 아이템의 **정적 데이터는 콘텐츠에 있다.** 여기에는 인스턴스 값만 저장.
  - `upgrade_level` 이 `state` 의 유일한 진실. 콘텐츠의 `upgrade` 블록은 기본값(0)이다.
  - `is_lost` 와 `base_value` 는 정적. 콘텐츠에서 읽는다.

---

## 6. AffixState / EnchState

```gdscript
# AffixState
{ "id": "aff_scorch", "tier": 2, "seed": 9001 }

# EnchState
{ "id": "ench_keen_edge", "tier": 3, "seed": 77123 }
```

- 어펙스·인챈트는 **ID + 시드**만 저장한다.
- 실제 효과는 `07` §4의 결정론 파생으로 계산한다.
  → `damage_additive` 같은 값을 저장하면 튜닝 변경 시 깨진다.

---

## 7. world

```gdscript
{
  "currency": 340,
  "unlocked_regions": ["region_unused", "region_hollow_cistern"],
  "discovered": { "region_hollow_cistern": true },
  "loop_point": { "region_hollow_cistern": {"x": 0, "y": 0} },
  "last_star_level": 5,
  "legend_state": {
    "legend_first_croak": { "node": "node_0", "choices": ["ch_help"], "ended": false },
  },
  "quest_counters": { "mosquitoes": 12, "snails": 3 },
  "legend_flags": { "flag_frogs_filled_cave": true },
  "reputation": { "shop_hollow": 3 },
  "season": "spring",
  "stone_drops": [ "stone_of_sight" ],   # 획득 기록. 중복 판정용
}
```

- `loop_point` 는 **여기 하나만 있다.** `encounter.cleared_at_tick` 은 쓰지 않는다.
  → `12` §3.4
- `last_star_level` 은 리셋 시 복원용. `12` §4
- `stone_drops` 는 이미 얻은 돌의 목록. 중복 드랍을 화폐로 바꿀 때 쓴다.
- `reputation` 은 상점별 구매 횟수. 가격 증가의 근거.

---

## 8. encounter

```gdscript
{
  "region_id": "region_hollow_cistern",
  "star_level": 11,
  "seed": 24680,
  "state": "active",              # active | cleared | failed
  "foes": [ FoeState ],
  "boss": BossState | null,
  "projectiles": [ ProjState ],
  "obstacles": [ ObstacleState ],
  "player_stance": "neutral",     # neutral | guard | evade | superarmor
  "ai_state": "engage",           # §05
  "cleared_at_tick": 0,
}
```

### 8.1 FoeState

```gdscript
{
  "foe_id": "foe_husk_scrapper",
  "hp": 120, "hp_max": 120,
  "behavior": 2,                  # 1 = 주기 행동, 2 = 이동
  "state_id": "cooldown",
  "state_time": 0,
  "cycle_index": 0,               # 공격 사이클 카운터
  "special_counter": 0,           # "N타 후 특수" 카운터
  "pos": {"x": 240, "y": 0},
  "dist": 18,
  "alive": true,
  "damage": { "physical": 6, "fire": 0, "lightning": 0, "arcane": 0, "shadow": 0 },
  "tags": ["humanoid", "melee"],
  "immunities": [],
  "resistances": { "bleed": 0.0, "poison": 0.3, "frost": 0.0 },
  "defense": { "physical": 0.10, "fire": 0.0, "lightning": 0.0,
               "arcane": 0.0, "shadow": 0.0 },
  "poise": 30,
  "statuses": [ { "id": "poison_dot", "frames": 180, "magnitude": 3 } ],
  "status_build": { "bleed": 0, "poison": 0, "frost": 0 },
  "attacks": ["atk_husk_slash", "atk_husk_sweep"],
  "scale": 1.0,
}
```

- `behavior` / `state_id` / `state_time` 은 원작 `foe.state` / `foe.time` 을 그대로 존. → `03`
- `state_time` 은 `chill` 같은 시간 배율을 **적용한 뒤** 저장한다.
- `status_build` 는 0~100. `statuses` 는 시간제 효과.
- `scale` 은 절차 생성기가 주는 개체 편차. 원작 수치 복제 금지.

### 8.2 BossState

```gdscript
{
  "chain": ["boss_warden_a", "boss_warden_b", "boss_warden_c"],
  "phase_index": 1,
  "adapt_stacks": { "fire": 0, "physical": 0, "arcane": 0,
                    "lightning": 0, "shadow": 0 },
  "cutscene_done": false,
  "foe": FoeState,
}
```

- 페이즈마다 `chain` 의 `foe_id` 로 교체. 별도 스탯은 저장하지 않는다. 데이터에서 읽는다.
- `adapt_stacks` 는 적응형 저항 스택. `04` §? 참조.
- `cutscene_done` 은 1회성. 저장해야 재실행되지 않는다.

### 8.3 ProjState

```gdscript
{
  "id": "prj_a1b2",
  "source": "foe",            # foe | player
  "damage": { "arcane": 12, "physical": 0, "fire": 0, "lightning": 0, "shadow": 0 },
  "pos": {"x": 100, "y": 40},
  "vel": {"x": -2, "y": 0},
  "lifetime": 60,
  "reach": 3,
  "status_build": { "bleed": 0, "poison": 0, "frost": 0 },
  "evadable": true,
}
```

- `vel` 은 프레임당 `distance` 단위 정수 이동.
- `lifetime` 프레임 후 소멸.

### 8.4 ObstacleState

```gdscript
{
  "obstacle_id": "obs_pillar",
  "kind": "pillar",            # pillar | rubble | pit | water | gate
  "pos": {"x": 120, "y": 20},
  "size": {"w": 8, "h": 20},
  "blocks_move": true,
  "blocks_sight": false,
  "tags": [],
}
```

- 시야/이동/타격을 분리한다. 원작과 동일 구조.
- `gate` 는 `world.flags` 의 게이트 상태를 따른다.

---

## 9. 정적 vs 진행 상태

| 분류 | 예 | 저장 |
|---|---|---|
| **진행** | hp, pos, statuses, chests, flags, quest_counters, respec_used | O |
| **정적** | 무기 스탯, 적 스탯, 레시피, 스케일링 가중치, 보정 문법 | X (콘텐츠에서 읽음) |
| **표현** | 커서 위치, 스크롤, 점선 점멸, 패널 열림 여부, 카메라 미세 위치 | X |
| **파생** | 스케일링 배율, 요구치 충족 여부, `chest_cap`, 방어율 | X (실행 시 계산) |

**파생 상태를 저장하지 않는 것이 이 설계의 핵심 규칙이다.**
튜닝을 바꿔도 저장이 깨지지 않는다.

---

## 10. load 규칙

```gdscript
func from_dict(d: Dictionary) -> RunState:
    if d.get("state_format") != "ssr_run_v1":      return fresh()
    if d.get("tuning_signature") != current_signature():  return fresh()
    if not _valid_star_level(d.get("star_level")):  return fresh()
    # 그 외: 명시된 키만 읽고, 없는 키는 기본값
```

- 부분 복구 금지. 반쪽 복구된 상태는 진행을 망친다.
- 실패 시 `fresh()` 로 초기화하고 그 사실을 반환값에 알린다.
  (`load_result: "restored" | "reset_format" | "reset_tuning" | "reset_star"`)
