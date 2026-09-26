# 08 — 경제 · 상점 · 전설

---

## 1. 화폐

- 단일 화폐 `currency` (원작 `ki`).
- 원작 이름 미사용. 표시명만 Phase 4에서 확정.
- **상시 HUD 우상에 2~3 glyph.** → `10` §3
-획득 방법: 적 처치, 상자 해체, 전설 보상, 판매.
- 사용: 상점 구매, 제작, 부스트.

### 1.1 소모 구간

| 용도 | 크기 |
|---|---|
| 기본 아이템 1개 | 20 ~ 60 |
| 상급 아이템 1개 | 80 ~ 200 |
| Chest 등급별 | 200 / 500 / 1200 / 2400 |
| **부스트 n회째 (n=0부터)** | **250 × (n+1)** — 250, 500, 750, … 2500 |
| 재배분 1회 | 400 |

- 부스트는 **증가형.** `07` §6.4 `boost_cost(n) = 250 * (n+1)` 과 동일한 규칙.
- 수치는 `tuning/economy.json` 에서 읽는다. `04` §10.1 규칙 준용.

---

## 2. 상점

### 2.1 스키마

```json
{
  "id": "shop_hollow",
  "name": "재의 시장",
  "open_condition": { "star": null, "flag": "flag_hollow_open" },
  "season": null,                       // spring | summer | halloween | holiday | null
  "layout": { "rows": 3, "cols": 2 },
  "stock": [
    { "item_id": "item_ash_spear",  "stock": 8,  "price": 24, "increase": 2, "max_price": 60, "rows": [1,2] },
    { "item_id": "item_ward_shield","stock": 6,  "price": 30, "increase": 2, "max_price": 66, "rows": [1,2] },
    { "item_id": "item_rune_rod",   "stock": 3,  "price": 90, "increase": 6, "max_price": 150, "rows": [3] }
  ],
  "chests": [
    { "tier": "giant", "price": 300, "rows": [3] }
  ]
}
```

### 2.2 가격 규칙

```gdscript
func current_price(entry: StockEntry, purchases: int) -> int:
    return mini(entry.price + entry.increase * purchases, entry.max_price)
```

- **구매할 때마다 가격이 오른다.** `purchases` 는 `world` 에 저장.
- `max_price` 에 닿으면 고정.
- `rows` 는 원작과 동일: 어느 행에 뜨는지 데이터로 지정.
  `rows: [1,2]` 는 1·2행, `[3]` 은 3행.

### 2.3 재고 리셋

- `open_condition` 을 만족하는 **지역 진입 시 1회** 재고 리셋.
- 같은 재방문으로는 리셋하지 않는다.
  → 원작은 "매일" 리셋이라 하지만, 이 Kit에는 날짜가 없다.
  **지역 재진입 = 새 세션** 으로 정의한다. `17` Q7.

### 2.4 계절 상점

- `season` 이 지정된 상점은 `world.season` 과 일치할 때만 열린다.
- `world.season` 은 지역 클리어 순서에 따라 진행한다. (4단계 고정)
  ```gdscript
  season = SEASONS[mini(cleared_region_count, 3)]
  ```
- 계절 상점은 **3열**을 쓰며 다른 상점과 겹치지 않는다.

### 2.5 상점 상태 (UI)

| 상태 | 조건 | 표시 |
|---|---|---|
| `ok` | 재고 있음, 화폐 충분 | 가격 숫자 |
| `sold_out` | `purchases >= stock` | 가격 자리에 `─` |
| `no_funds` | 화폐 부족 | 가격 숫자 + 아래에 `─` 1줄 (짧은 선) |
| `locked` | `open_condition` 미충족 | 상점 자체가 안 열림 |

- `no_funds` 는 가격을 지우지 않는다. **숫자를 유지한 채 밑줄로만** 부족을 알린다.
  → `10` §3 규칙 (정보를 말줄임으로 숨기지 않는다)

---

## 3. 구매 흐름

```text
1. 상점 패널이 오른쪽 정렬로 열린다
2. 좌측에 얇은 목록 (상점 이름, 통화)
3. 우측 그리드에 상품. 각 칸에 아이콘(절차 드로잉) + 가격
4. 커서가 한 칸에 있다 (흰 칩)
5. confirm → 구매
   - 성공: 재고 -1, 화폐 -가격, purchases +1, 결과 1줄
   - 실패: 아무것도 변하지 않음, 사유 1줄 (부족 / 품절 / 최대)
6. cancel → 패널 닫힘, 이전 focus 복귀
```

- 구매는 **원자적**이다. 실패 시 부분 변경 없음.
- `purchase` 는 `02` §7 의 `reputation` 에 쌓인다.

---

## 4. 전설 (Legend)

원작 15개 (계획 16번째 예정). 구조가특수하다.

### 4.1 스키마

```json
{
  "id": "legend_first_croak",
  "name": "첫 개구리",
  "requires": { "stone": "stone_of_asking" },
  "start_node": "node_intro",
  "nodes": {
    "node_intro": {
      "text": "원본 미사용. TIN 오리지널.",
      "choices": [
        { "id": "ch_later", "goto": "END", "grade": "wrong" },
        { "id": "ch_help",  "goto": "node_a" }
      ]
    },
    "node_a": {
      "check": { "quest_counter": "mosquitoes", "need": 40 },
      "text": "...",
      "choices": [ { "id": "ch_done", "goto": "node_b" } ]
    },
    "node_end_1": { "ending": "ending_leave", "reward": { "affix": "aff_x", "tier": 1 } },
    "node_end_2": { "ending": "ending_chop", "reward": { "affix": "aff_y", "tier": 1 } }
  },
  "unlocks": ["legend_next", "region_hidden"],
  "navigation": { "prev": null, "next": "legend_next" }
}
```

### 4.2 규칙 (원작 구조 차용)

1. **별도 미니게임 금지.** `check` 는 전부 기존 시스템 위의 과제.
   - `quest_counter` (N개 수집)
   - `craft` (특정 아이템 제작)
   - `kill_count` (특정 적 N명)
   - `survive_hits` (5타 생존)
   - `no_death_kill` (죽지 않고 20명 처치)
2. **선택지 3분류**: `right` / `wrong` / `neutral`.
   구현은 `goto` 와 보상으로만. 분류 문자열은 도감 표시에만.
3. **엔딩은 복수.** 마지막 노드에서 갈라진다.
4. **보상은 정확히 1회.** `node.ending` 진입 시 지급 후 `flags` 에 기록.
5. **순서 의존 전설 금지.** 어느 순서로 풀든 각 전설이 성립해야 한다.
   단 `unlocks` 로 해금되는 것은 예외 (원작처럼).
6. **tone**: 전설 서사는 Phase 4. 지금은 스키마와 시스템만.

### 4.3 진행 저장

- `world.legend_state[legend_id] = {"node": String, "choices": [String], "ended": bool}`
- 엔딩 보상 지급 여부는 `flags["legend_done_<id>"]`.
- `17` 에서 미수집 전설 13건.

---

## 5.economy 안전 규칙

- 화폐를 음수로 만들지 않는다. 모든 차감은 `>= 0` 검사 후.
- 오버플로우 방지: 화폐 상한 `int` 범위. 튜닝에 `currency_cap`.
- 구매/판매 원자성: 실패 시 부분 반영 금지.
- 세이브/로드 사이에 화폐가 증발하지 않도록 `reputation` 과 함께 검증.
