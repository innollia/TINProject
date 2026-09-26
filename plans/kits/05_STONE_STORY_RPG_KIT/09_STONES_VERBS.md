# 09 — 소울스톤 = 동사 10

원작의 진행은 스탯이 아니라 **새 동사의 해금**이다. 이 문서가 그 규칙을 구현한다.

---

## 1. 원칙

- 돌은 **통과)가 아니라 해금**이다.
- 돌을 얻으면 **플레이 화면이 바뀐다.** 버튼·패널·상태 전이가 생긴다.
- 돌 10개를 다 모아도 스탯은 오르지 않는다. **할 수 있는 일이 늘어날 뿐.**
- 돌은 `Equippable` 이고 **착용 중이면 패시브**가 붙는다.
  → 같은 돌이라도착용 여부가 빌드를 바꾼다.

---

## 2. 돌 목록

`id` 와 `verb` 는 **확정**이다 (Phase 1). `name`(표시명) 은 `content/stone/*.json` 의 값이며,
스키마에는 **placeholder 값을 싣지 않는다.** 구현 시 `name` 이 없으면
로더가 error 를 낸다. → `13` §13

| # | id | verb | 하이라이트 | 획득 지역 |
|---|---|---|---|---|
| 1 | `stone_of_sight` | `observe` | 적 정보 패널이 열린다 | 1 |
| 2 | `stone_of_degree` | `choose_difficulty` | 지역 선택에 별 선택 줄이 생긴다 | 2 |
| 3 | `stone_of_ascent` | `level_up` | 레벨업 패널, `chest_cap` 상승 | 3~4 |
| 4 | `stone_of_ledger` | `earn` | 상점 개방, 재료 구매 | 3~4 |
| 5 | `stone_of_asking` | `quest` | 지역 선택에 전설 목록이 생긴다 | 5 |
| 6 | `stone_of_return` | `loop` | 클리어 지점에서 되돌아간다 | 6 |
| 7 | `stone_of_split` | `fissure` | 제작대에 분해 동사가 생긴다 | 7 |
| 8 | `stone_of_knot` | `fuse` | 제작대에 융합 동사가 생긴다 | 8 |
| 9 | `stone_of_thought` | `dash` | 후방 대시 + 회피 | 9 |
| 10 | `stone_of_turn` | `respec` | 재배분 패널 | 10 |

> **표시명(`name`) 10개는 아직 없다.** Phase 4(Ena 톤)에서 확정해 채운다.
> Phase 1 은 `id`/`verb` 로만 동작한다. 임의 이름을 코드에 넣지 않는다.
> 원작 소울스톤 이름은 사용하지 않는다. 대응 관계는 여기 적지 않는다.

---

## 3. 돌별 계약

### 3.1 `stone_of_sight` — 관찰

- 열리면 전투 중 상단 중앙에 `≡` 1개 등장.
- 활성 시 대상 적의 정보 패널이 열린다.
- 정보 내용: hp, 스태시스, 데미지 타입, 요구치 미달 여부, 상태 축적량, 무법(art) 목록.
- **전투 중에 열리는 정보는 성능에 영향을 주지 않는다.** (정적 데이터만)

### 3.2 `stone_of_degree` — 난이도 선택

- 지역 선택 화면에 별(★) 1~20 슬라이더가 생긴다.
- 자원 흡수: 맵에 떨어진 재료를 플레이어 쪽으로 끌어당긴다.
  흡수 반경 `stone_magnet_radius = 18` (distance 단위).
  → `04` §11.1 과 같은 단위계.
- 요구: `1*` 부터 선택 가능. 색 밴드 표시는 `*` 개수로.
- 상한 상한: `max_selectable_star = min(20, 2 + 6 * stone_of_degree.upgrade_level)`
- `stone_of_degree.upgrade_level` 은 `content/stone/stone_of_degree.json` 의
  `upgrade_max` 까지 오른다. 돌 강화는 `07` §3 과 같은 규칙을 쓴다.
  (Phase 1 에서는 `upgrade_max = 0` → 상한 2. Phase 2 에서 연다)

### 3.3 `stone_of_ascent` — 레벨업

- 처치 시 `xp` 획득. `xp` 누적.
- 레벨업 시 `stat_points +1` 과 `chest_cap` 상승.
- 레벨업 패널이 열린다 (스탯 배분). **상시 HUD 아님.**

### 3.4 `stone_of_ledger` — 통화

- 처치 시 `currency` 획득.
- 상점이 처음으로 열린다.
- 제작 재료 구매 가능.
- 패시브(착용): 획득량 +15%.

### 3.5 `stone_of_asking` — 전설

- 지역 선택에 전설 목록이 열린다.
- 전설 노드가 순서대로 해금된다 (`navigation.next`).
- `legend_first_croak` 부터 시작.
- 패시브 없음.

### 3.6 `stone_of_return` — 루프

- 클리어 지점에 도달하면 **자동으로 되돌아간다.**
- 크soul 1 감소하지 않는다. (완주 시 무한 반복)
- 패시브(착용): 턴마다 HP 1 회복.
- 루프 중에도 상자/드랍은 계속 나온다. (원작: "무입력 무한 플레이")

### 3.7 `stone_of_split` — 분해

- 제작대에 `분해` 동사 버튼이 생긴다.
- 분해 결과는 `item.components` authored.
- 인챈트/어펙트가 있으면 **보존된 채** 분리된다. → `04` §5.4
- 패시브 없음.

### 3.8 `stone_of_knot` — 융합

- 제작대에 `융합` 동사 버튼이 생긴다.
- 인챈트 2개 → 1개. 어펙스 2개 → 1개.
- `tier = max(a,b) + 1`, 상한 5. → `04` §5.4
- 패시브(착용): 보행 이동 프레임 -10%.

### 3.9 `stone_of_thought` — 스크립트

- **스크립트 언어를 Phase 2에 넣는다.** (DS3 외에 Stone Story 의 Stonescript 대응물)
- Phase 1에서 확보할 것:
  1. **대시 능력** (후방 이동 + 회피). `05` §6.3.
  2. 스크립트 **입력 슬롯 UI** (실행은 Phase 2).
  3. 스크립트 실행이 전투 AI보다 우선한다는 **경로**만 비워 둔다.
- **Phase 1에서 빈 스크립트 상자를 띄우지 않는다.** 실행 안 되는 UI를 만들지 않는다.
  → 대시 능력만 구현하고, 스크립트 UI는 Phase 2 와 함께.

### 3.10 `stone_of_turn` — 재배분

- 재배분 패널: 스탯 1개를 골라 0으로 되돌릴 수 있다.
- 제한: 런당 **5회**.
- 반환 한도: `태생 기본 + 1`까지만 되돌릴 수 있다. (레벨 자체는 낮출 수 없다)
- 패시브(착용): 공격 프레임 -5%.

---

## 4. 해금 판정

```gdscript
func has_verb(stones: Dictionary, verb: StringName) -> bool:
    return stones.get(VERB_STONE[verb], {}).get("held", false)
```

- `VERB_STONE` 은 `verb` → `stone_id` 1:1 매핑.
- core 는 `stone_of_*` 문자열을 도메인에 쓰지 않는다. **`verb` 를 쓴다.**
  → 셀이/버튼/조건은 `verb` 만 확인. 돌 추가가 UI 를 바꾸지 않는다.

### 4.1 verbs 목록 (닫힌 어휘)

```gdscript
const VERBS: Array[StringName] = [
    &"observe", &"choose_difficulty", &"level_up", &"earn", &"quest",
    &"loop", &"fissure", &"fuse", &"dash", &"respec",
]
```

- 10개가 전부다. 11번째는 추가하지 않는다.
  → 리롤/변이는 `stone_of_turn` 의 **하위 기능**으로 넣지 않는다.
  Phase 1 범위 밖. `17` Q8

---

## 5. 돌 획득

- 각 지역 미니보스/보스 확정 드랍.
  `content/stone/<stone>.json` 의 `drop_from` 필드에
  `{"kind": "boss" | "miniboss", "id": "<foe_id>"}` 를 authored.
  → `13` §10
- 획득 시 **1회성 연출** + 전설 스타일 컷신.
- 이미 보유한 돌은 재획득하지 않는다. 중복 드랍은
  `stone_duplicate_currency` (기본 120) 으로 전환. → `08` §1
- 돌은 **인벤토리 상한에 포함되지 않는다.** 별도 `held` 플래그.

---

## 6. 패시브 합산

```gdscript
func equipped_passives(stones: Dictionary) -> Dictionary:
    var out := {"xp_gain": 0.0, "currency_gain": 0.0,
                "walk_speed": 1.0, "attack_speed": 1.0, "regen_per_turn": 0}
    for id in stones:
        var s: Dictionary = stones[id]
        if not s.get("equipped", false): continue
        for k in STONE_PASSIVES[id]:
            if out[k] is float: out[k] += STONE_PASSIVES[id][k]
            else: out[k] += STONE_PASSIVES[id][k]
    return out
```

- 패시브는 **곱이 아니라 더셈**으로 합산한다. (단 `walk_speed`, `attack_speed` 만 곱)
- 패시브는 `04` §10.1 튜닝 블록에 값을 둔다.

---

## 7. 돌 테스트 항목

1. 돌 미보유 상태에서 해당 verb 를 요구하는 UI 가 **열리지 않는다**.
2. 돌 보유 → UI 가 열린다.
3. 돌을 unequip → 패시브가 빠진다. UI 는 유지 (해금은 유지).
4. 같은 돌 중복 획득 시 화폐로 전환.
5. `respec` 5회 초과 시 버튼이 비활성.
6. `respec` 이 레벨을 낮추지 않는다.
7. `loop` 보유 시 클리어 후 `cleared_at_tick` 이 초기화되지 않는다.
8. `fissure` / `fuse` 미보유 시 제작대에 해당 버튼이 없다.
