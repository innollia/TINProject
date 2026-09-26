# 13 — Content Schema

전부 `modules/stone_story_rpg/content/` 아래 JSON. 전용 에디터는 만들지 않는다.

---

## 1. 디렉터리

```text
content/
  index.json
  tuning/
    combat.json          # 04 §10
    economy.json
    generation.json
    star_bands.json
  class/                 # 9
  region/                # 12
  foe/                   # 12+
  boss/                  # 8
  miniboss/              # 8
  attack/                # 30+
  item/                  # 25+
  enchant/               # 20+
  affix/                 # 20+
  recipe/                # 40+
  spell/                 # 12+
  material/              # 5
  stone/                 # 10
  legend/                # 15
  shop/                  # 5
  prop/                   # 채굴 지점 · 소품
  obstacle/               # 장애물 (obs_)
```

`index.json` 은 각 종류의 파일 목록 + `content_signature`(해시).
로드는 `index.json` → 개별 파일 순서로만. 디렉터리 스캔으로 순서를 만들지 않는다.

---

## 2. 공통 규칙

1. **모든 ID 는 `snake_case` 영문.** 접두어 = 디렉터리 종류.
   `foe_` `boss_` `miniboss_` `item_` `ench_` `aff_` `rec_` `spell_` `mat_`
   `stone_` `legend_` `shop_` `region_` `obs_` `atk_` `class_` `prop_`
2. **ID 는 저장 호환성의 일부다.** rename 금지.
3. 모든 파일에 `id` 가 있다. `index.json` 과 일치해야 한다.
4. 정수만 쓸 수 있는 곳 / 실수를 쓸 수 있는 곳을 아래 표로 구분한다.
   | 종류 | 허용 |
   |---|---|
   | 위치·크기·개수·레벨·프레임·수량 | **정수만** |
   | 스케일링 가중치, 방어율, 배율, 확률, 상태 축적량 | **실수 허용** (0.0~1.0 또는 정수 배) |
   | `tuning/*.json` | 정수·실수 모두 |
   실수는 소수점 3자리까지만. `13_CONTENT_SCHEMA` 의 모든 예시가 이 규칙을 따른다.
5. 참조는 ID 문자열. 중첩 복사 금지 (정규화하지 않는다).
6. 없는 ID 참조는 **로딩 에러**다. 조용히 무시하지 않는다.

---

## 3. `region/*.json`

```json
{
  "id": "region_hollow_cistern",
  "name": "빈 기둥 우물",
  "kind": "combat",              // combat | transition | shop
  "tiles": [
    { "y": 0,   "height": 180, "wall_density": "navigation" },
    { "y": 180, "height": 290, "floor_density": "evidence" },
    { "y": 470, "height": 70,  "ground_density": "mood" }
  ],
  "gates": {
    "miniboss":  { "min_star": 11 },
    "obstacles": { "min_star": 11 },
    "reg_foes":  { "min_star": 16 },
    "boss":      { "min_star": 3 },
    "boss_full": { "min_star": 5 }
  },
  "foe_pools": [ ... ],
  "spawn_cap": { "1": 2, "2": 3, "3": 4, "4": 6, "5": 9 },
  "obstacle_pool": [ { "min_star": 11, "ids": ["obs_pillar", "obs_rubble"] } ],
  "boss_chain": [ ... ],
  "miniboss": { "yellow": "miniboss_hollow_warden", "green": "miniboss_hollow_sprinter" },
  "drops": { "materials": { "mat_ash": [1, 3] }, "currency": [8, 20] },
  "chest_tiers": ["common", "giant"],
  "shop_id": null,
  "loop_point": { "x": 0, "y": 0 },
  "props": [ { "prop_id": "prop_well", "x": 300, "y": 320, "kind": "mine" } ]
}
```

- `wall_density` / `floor_density` 는 `evidence` / `navigation` / `mood` 3값.
  → `01` §4.1. **장면이 명시한다.** 코드가 추론하지 않는다.
- `spawn_cap` 인덱스는 밴드 id. `06` §1.1.

---

## 4. `foe/*.json`

```json
{
  "id": "foe_husk_scrapper",
  "name": "허물 경비",
  "hp": 120,
  "damage": { "physical": 6, "fire": 0, "lightning": 0, "arcane": 0, "shadow": 0 },
  "defense": { "physical": 0.10, "fire": 0.0, "lightning": 0.0, "arcane": 0.0, "shadow": 0.0 },
  "resistances": { "bleed": 0.0, "poison": 0.30, "frost": 0.0 },
  "immunities": [],
  "tags": ["humanoid", "melee"],
  "poise": 30,
  "walk_frames_per_unit": 3,
  "wake_distance": 25,
  "states": { ... },
  "behaviors": { ... },
  "attacks": ["atk_scrapper_slash", "atk_scrapper_sweep"],
  "status_build": { "bleed": 0, "poison": 0, "frost": 0 },
  "death_drops": [ { "kind": "currency", "min": 4, "max": 9 } ],
  "value": 20
}
```

- `states` / `behaviors` 스키마는 `03` §3.1.
- `walk_frames_per_unit` 은 **원작 참고 범위**(3~15) 안에 두되 TIN가 정한다.
- `immunities` 에는 `unmake` 이 들어갈 수 있지만 판정은 비어 있다. → `06` §4.3
- `death_drops` 는 authored. 절차 생성은 **위치와 개수**만 만든다. → `06` §3

---

## 5. `attack/*.json`

```json
{
  "id": "atk_scrapper_slash",
  "name": "베기",
  "handler": "hit_forward",
  "frames": 12,
  "reach": 4,
  "knockback": 2,
  "poise_damage": 14,
  "guard_break": 8,
  "cooldown_after": 0,
  "telegraph_frames": 8,
  "damage_mult": 1.0,
  "status_build": { "bleed": 0, "poison": 0, "frost": 0 }
}
```

- `handler` 는 `03` §3.5 의 5종 + `spawn_projectile`.
- `telegraph_frames` > 0 이면 예고 표시. `06` §4.2 의 원작 charge 구조.
- `cooldown_after` 프레임 동안 다시 고르지 않는다.

---

## 6. `item/*.json`

`07` §2 스키마. 종류별로:

| kind | 추가 필드 |
|---|---|
| `weapon` | `handedness`, `weight`, `scaling`, `requirement`, `attack`, `arts`, `poise`, `upgrade`, `is_lost`, `value`, `components` |
| `shield` | `weight`, `guard_break_resist`, `value` |
| `catalyst` | `spell_cost_mult`, `scaling`, `value` |
| `armor` | `stat_bonus`, `weight`, `damage_reduce`, `value` |
| `consumable` | `effect`, `cooldown`, `value` |
| `material` | `value` |
| `spell` | `damage`, `scaling`, `focus_cost`, `form`, `duration` |
| `chest` | **이 종류는 존재하지 않는다.** → `02` §4 |

- `chest` 는 컨테이너 칸이지 아이템이 아니다.
- `is_lost: true` 인 무기만 `boost` 가능. `07` §6.4.
  (플래그 이름은 `is_lost` 하나뿐이다. `lost_item` 을 쓰지 않는다)
- `value` 는 정적 기본가치. `07` §8.
- `components` (분해 결과) 은 authored.
- `upgrade` 블록은 **기본값**(레벨 0)이다. 실제 값은 `ItemState.upgrade_level`. → `02` §5

---

## 7. `enchant/*.json` / `affix/*.json`

`04` §5.1 스키마. 접두어로 구분:

- `ench_` = 능력 강화형 (`requirement_met: true` 기본)
- `aff_` = 일반 어펙스

- `damage_additive` / `damage_multiplicative` 범위 제한은 `04` §5.2.
- `text` 는 UI 전용. 판정에 쓰지 않는다.

---

## 8. `recipe/*.json`

`07` §6.1 스키마. `verb` 는 `upgrade` / `craft` / `enchant` / `boost` / `fissure` / `fuse`.
- `upgrade` 는 `inputs` 1개(그 아이템 자신) + `require_same_level: true`.
- `fissure` / `fuse` 는 `inputs` 가 아이템 아닌 `ench_`/`aff_` ID.

---

## 9. `class/*.json` (태생)

```json
{
  "id": "class_ashbound",
  "name": "재에 묶인 자",
  "base_stats": {
    "vitality": 20, "focus": 10, "grit": 12, "toughness": 12,
    "strength": 14, "dexterity": 10, "intellect": 6, "devotion": 6, "instinct": 8
  },
  "start_items": ["item_rusted_sword", "item_ash_dagger"],
  "start_stones": [],
  "note": "Phase 4에서 이름/톤 확정"
}
```

- 6 태생. (`04` §1.3 참조, 원작의 7종 구조는 참조만)
- 재배분 반환 상한은 `base_stats + 1`. `09` §3.10.
- `start_items` 는 `index.json` 에서도 검증한다 (존재하는 item 이어야 함).

---

## 10. `stone/*.json`

```json
{
  "id": "stone_of_degree",
  "name": "각도 돌",
  "verb": "choose_difficulty",
  "passives_equipped": { "currency_gain": 0.0 },
  "ability": null
}
```

- `verb` 은 `04` §4.1 의 닫힌 어휘 10개 중 하나.
- `ability` 는 돌 6, 9, 10만 non-null. 스키마는 `05` §6.3.

---

## 11. `legend/*.json`

`08` §4.1 스키마. `text` 는 Phase 4 (원본 미사용, TIN 오리지널).

---

## 12. `shop/*.json`

`08` §2.1 스키마.

---

## 13. 로더 검증

`systems/content_loader.gd` 가 **로딩 시 전수 검사**한다.

| 검사 | 실패 시 |
|---|---|
| `index.json` 과 파일 목록 일치 | error |
| ID 중복 | error |
| ID 접두어 == 디렉터리 종류 | error |
| 없는 ID 참조 | error |
| `scaling` 합 > 1.0 | error |
| `scaling` 에 없는 스탯이 `requirement` 에 있음 | error (허용은 하나 방향) |
| `requirement` 값이 음수 | error |
| `art.requirement` > 무기 요구치 | warning (의도일 수 있음) |
| `states` 전이 대상 없음 | error |
| `states[].next` 가 빈 배열 | error |
| `tuning` 키 누락 | error |
| `min_star` 범위 밖 | error |
| 밴드에 속하지 않는 `star` 값 | error |
| `spawn_cap` 인덱스가 밴드 id 아님 | error |
| 밀도 값이 3단계 밖 | error |
| `chest_tier` 가 `spawn_cap` 밖 | warning |
| 재귀 참조 (A가 B를 B가 A를) | error |

- error 가 1개라도 있으면 **로딩 실패.** 게임 진입 불가.
- warning 은 기록하고 진행.
- `content_signature` 는 모든 파일의 해시 결합. → `02` §2

---

## 14. 금지

- 전용 에디터 툴
- content ID 를 core script 에 하드코딩
- `if content_id ==` 분기
- 로더가 없는 직접 `load()` 호출
- JSON 아닌 콘텐츠 형식 (전부 JSON)
- 이미지 파일
- 대화/문구를 파일에 따로 두지 않기 (레코드 안에 `text` 로)
