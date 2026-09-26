# 06 — 스타 레벨과 절차 생성

Stone Story RPG 의 1급 난이도 축. `run = (region_id, star_level, run_seed)`.

---

## 1. 스타 레벨

- 정수 `1..20`.
- 표기: `1*` `2*` `3*` `4*` `5*` `6*~10*` `11*~15*` `16*~20*`
- 색 구분: white(1~2) / cyan(3~4) / **yellow(5~10)** / green(11~20)
  → 색은 **UI에서도 기호로** 표현한다. `*` 개수로 읽히게 한다.
- 플레이어가 `stone_of_degree` 로 직접 고른다. 강제 상승 없음.

### 1.1 밴드 (5개)

밴드 id 는 **색 이름이 아니다.** `spawn_cap` 인덱스로 쓰이므로 짧은 정수 문자열을 쓴다.

```gdscript
const BANDS: Array[Dictionary] = [
    {"id": "b1", "lo": 1,  "hi": 2,  "label": "1*~2*",   "color": "white"},
    {"id": "b2", "lo": 3,  "hi": 4,  "label": "3*~4*",   "color": "cyan"},
    {"id": "b3", "lo": 5,  "hi": 10, "label": "5*~10*",  "color": "yellow"},
    {"id": "b4", "lo": 11, "hi": 15, "label": "11*~15*", "color": "yellow"},
    {"id": "b5", "lo": 16, "hi": 20, "label": "16*~20*", "color": "green"},
]
func band_of(level: int) -> Dictionary:
    for b in BANDS:
        if level >= b.lo and level <= b.hi: return b
    return BANDS[0]
```

- `color` 는 UI 표시용. 판정에는 쓰지 않는다.
- `id` (`b1`~`b5`) 가 `spawn_cap` 키. → `13` §3.
- 밴드 내 보간: `tuning/star_bands.json` 의
  `{"b1": [v, v], "b2": [v, v], ...}` 배열에서
  `idx = level - lo` 로 **선형 보간**한다. (2점 보간)
  ```gdscript
  func tier_value(base: int, level: int, tuning) -> int:
      var b := band_of(level)
      var pair: Array = tuning["bands"][b.id]
      var span: int = b.hi - b.lo
      if span <= 0: return base * pair[0]
      var t: float = float(level - b.lo) / float(span)
      return floori(base * lerpf(pair[0], pair[1], t))
  ```
- **밴드 경계는 불연속**하다. `b2` 의 4* 값과 `b3` 의 5* 값은
  서로 다른 테이블에서 나온다.
- 밴드 경계 불연속을 만들려면 `b2.pair[1] != b3.pair[0]` 이 되도록 테이블을 쓴다.

### 1.2 밴드 스케일

원작: 밴드마다 hp/damage 표가 통째로 갈린다.

→ **TIN 결정: 밴드 안에서는 선형 보간, 밴드 경계는 계단.** 한쪽만 복제하지 않는다.
구현은 §1.1 의 `tier_value` + `tuning/star_bands.json`.
테이블의 각 밴드는 `[lo_multiplier, hi_multiplier]` 2개 값만 갖는다.

---

## 2. 콘텐츠 게이트

스타 레벨이 무엇을 여는지. **데이터 선언, 코드 판정 없음.**

```json
// content/region/region_hollow_cistern.json
{
  "id": "region_hollow_cistern",
  "gates": {
    "miniboss":   { "min_star": 11 },
    "obstacles":  { "min_star": 11 },
    "reg_foes":   { "min_star": 16 },
    "boss":       { "min_star": 3 },
    "boss_full":  { "min_star": 5 },
    "ascendant":  { "min_star": 12 }
  }
}
```

- 게이트는 지역마다 다르다. (원작: Rocky Plateau 의 일반 적은 16*)
- 게이트는 `star_level` 만 본다. `flags` 는 별도.
- `min_star` 이 region's `gates` 에 없으면 항상 열림.

---

## 3. 절차 생성

원작: "8+ hours of main story gameplay, **in addition to procedurally generated content**."

### 3.1 생성 책임 분할

| 층 | authored | generated |
|---|---|---|
| 지형 골격 | 바닥 대역, 벽 대역, 출입구 위치, 상점 위치 | 장애물 배치 |
| 적 | 스탯 표, 상태 기계, 행동, 태그 | 어떤 풀에서 몇 마리, 어디에 |
| 보스 | 페이즈 체인, 속성, 패턴, 컷씬 | **없음** |
| Miniboss | 스탯, 개벽, 배치 규칙 | 배치 지점(green/yellow 규칙) |
| 드랍 | 등급 확률 테이블 | 개별 드랍 |
| 상점 | 판매 목록, 가격 규칙, 행 | 재고 수량, 계절 |
| 전설 | 전체 | **없음** |

**금지:** 생성기가 authored 콘텐츠 ID 를 하드코딩하지 않는다.
생성기는 `pool_id` 로만 참조한다.

### 3.2 생성 결정론

```gdscript
func build(region: RegionData, star_level: int, seed: int) -> EncounterState:
    var r := _lcg(hash_string(region.id, String(star_level), String(seed)))
    # 1. 지형: authored 골격 복사
    # 2. 적 풀: region.foe_pools 에서 게이트를 통과한 풀만
    # 3. 수량: 밴드별 range 를 r 로 뽑음
    # 4. 배치: 바닥 대역 안에서 r 로 좌표
    # 5. 장애물: gate.obstacles 열렸으면 r 개수/좌표
    # 6. 미니보스: gate.miniboss 열렸으면 yellow/green 규칙
    # 7. 보스: region.boss_chain 그대로
    # 8. 드랍: tier_table 에서 r 로
```

- 시드가 같으면 결과가 **완전히 동일**해야 한다.
- 순회 순서: authored 배열의 **선언 순서**를 따른다. 딕셔너리 순회 금지.
- `r` 을 뽑는 순서도 고정. 뽑는 순서가 바뀌면 결과가 바뀌므로 금지.

### 3.3 적 풀

```json
"foe_pools": [
  { "min_star": 1,  "max_star": 10, "weight": 5, "ids": ["foe_husk_scrapper", "foe_husk_lancer"] },
  { "min_star": 11, "max_star": 20, "weight": 3, "ids": ["foe_ash_sprite", "foe_wall_walker"] },
  { "min_star": 16, "max_star": 20, "weight": 1, "ids": ["foe_warden_elite"] }
]
```

- `weight` 로 가중 추첨. `ids` 안에서 균등 추첨.
- 최대 동시 생성 수를 밴드별로 둔다 (원작은 "적은 16*부터" 처럼 상한이 있다).
  ```json
  "spawn_cap": { "1": 2, "2": 3, "3": 4, "4": 6, "5": 9 }
  ```
  (인덱스 = 밴드 id)

### 3.4 개체 편차

같은 `foe_id` 여도 개체마다 약간 다르다. (`scale`)

```gdscript
var scale: float = 0.90 + r_float(r) * 0.20        # 0.90 ~ 1.10
```

- `scale` 은 hp, damage, poise 에만 적용.
- 스케일링 가중치·상태 기계·공격 패턴은 **바뀌지 않는다.**
  → "같은 적인데 세기가 다르다"가 읽히되, 규칙은 같게 유지된다.

### 3.5 Miniboss 배치 규칙 (원작 구조)

| 색 | 위치 | 함께 있는 적 |
|---|---|---|
| `yellow` (5~10) | 지역 끝 근처, 단독 | 없음 |
| `green` (11~20) | 지역 시작 지점 | 일반 적과 함께 |

- green 밴드에서 miniboss 는 **지역 첫 배치 슬롯**에 고정.
- yellow 밴드에서 miniboss 는 **보스 직전 배치 슬롯**에 고정.
- 두 밴드 모두 열려 있으면 green 먼저.

---

## 4. 보스 페이즈 체인

```gdscript
{
  "chain": [
    { "foe_id": "boss_warden_holder",  "min_star": 3, "hp_threshold": 0.66 },
    { "foe_id": "boss_warden_turned",  "min_star": 4, "hp_threshold": 0.33 },
    { "foe_id": "boss_warden_perfect", "min_star": 5, "hp_threshold": 0.00 }
  ]
}
```

- `phase_index` 는 **0-기반.** 초기값 0.
- 전이 조건: `hp / hp_max <= chain[phase_index].hp_threshold`.
  `threshold == 0.00` 이면 그 페이즈가 마지막(사망 조건이 아님).
  마지막 페이즈의 `threshold` 는 0.00 으로 고정하고, 사망으로 넘어간다.
- 현재 레벨에서 `min_star` 이 큰 페이즈는 **전부 건너뛴다.**
  (원작: 1 phase at 3*, two at 4*, all three at 5*+)
- 페이즈 전환 시 6프레임 정지 + 페이즈 고유 연출. → `10` §5
- 이전 페이즈의 `status_build`, `statuses` 는 **초기화된다.**
- `chain` 의 마지막이 죽으면 전투 종료.

### 4.1 적응형 저항 (원작 Dysangelos Ph3 구조)

```gdscript
func on_shield_up(state) -> void:
    var top: String = _highest_damage_type_this_window(state)
    if top == "physical":                       # Stone 예외
        state.boss.armor_bonus += TUNING.armor_per_shield
        return                                  # 저항을 얻지도 버리지도 않음
    if state.boss.adapt_stacks[top] > 0 and state.boss.last_top == top:
        state.boss.adapt_stacks[top] += 1       # 같은 속성 연속이면 스택 추가
    else:
        state.boss.adapt_stacks = {}            # 다른 속성이었으면 전부 폐기
        state.boss.adapt_stacks[top] = 1
    state.boss.last_top = top
```

- 창: 가드 발동 직전 30프레임 누적 데미지.
- `damage * (1 - stack * TUNING.adapt_per_stack)` 로 감소. 스택 상한 3.
- `physical` 은 예외. 이 예외는 **원작의 규칙을 가져온 것**이다.
  → 구조 차용. 수치는 TIN.

### 4.2 페이즈별 속성/면역

```json
// content/boss/boss_warden_turned.json
"element": "arcane",
"immunities": ["unmake", "push", "stun"],
"resistances": { "physical": 0.20 },
"attack_cycle": ["sweep_low", "sweep_high", "cast_bolt"],
"element_cycle": [ "fire", "ice", "arcane", "shadow", "lightning" ]
```

- `element_cycle` 로 원작 Dysangelos Ph2 의 "무작위 팔" 구조를 재현.
  랜덤이 아니라 **사이클 순회 + 시드로 시작 오프셋.** 결정론 유지.

### 4.3 언메이크(Unmake)

원작에서 boss 전원이 면역. 정의를 아직 못 받았다(`17` Q5).
→ **현재는 `immunities: ["unmake"]` 를 태그로만 저장하고, 판정 로직은 비워 둔다.**
`unmake` 를 사용하는 무기/아빌리티는 Phase 1 에 넣지 않는다.
정의가 오면 판정을 추가한다. **추측으로 구현하지 않는다.**

---

## 5. 오프라인 / 방치

원작: 오프라인 시 주 드랍이 "모든 룬의 혼합".
→ **Phase 1 범위 밖.** 구현하지 않는다. 자동 전투 AI 가 있는 게임에서
오프라인 진행은 별도 설계가 필요하다. `17` Q6.
