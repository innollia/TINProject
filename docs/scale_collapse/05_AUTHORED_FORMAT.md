# 05 — Authored 형식 (JSON 스키마)

장소의 스케일 요구와 스케일 변경 트리거의 정확한 JSON. 요구 계약 6개.

읽기 전제: `01_SCALE_ALGEBRA.md`, `02_PLACE_REQUIREMENTS.md`, `03_MISMATCH_VISUALS.md`
§2(반복 수의 법칙), `04_TRANSITIONS.md` 전부.

**이 문서의 모든 스키마는 `core/procedural/DESIGN_DECISION.md` §1의 규칙을 따른다.**
JSON-safe, `float`은 Godot JSON 파서 관점의 실수, 없는 키는 기본값.
전용 editor는 요구하지 않는다(`docs/CODE_STYLE.md`).

---

## 1. 두 개의 파일과 두 개의 소유자

| 파일 | 소유자 | 담는 것 |
|---|---|---|
| `res://content/scale/ladder.json` | W0 | 사다리 6행과 band 경계 5개 |
| `res://content/places/<place_id>.json` | W0 | 장소 기록 + 접근로 목록 |
| `modules/<kit>/content/terrain/<place_id>.json` | 해당 Kit | 그 Kit의 형상(정점, 콜라이더, PVE 스펙 id) |

**나누는 이유:** `target_body_px`는 저절로 절의 절대 크기 선언이고
`docs/world/00_CONSTITUTION.md` 불변식 13은 "구역의 물리 규칙은 하나의 것"이라 한다.
Kit이 자기 `target_body_px`를 가지면 같은 구역에 세 크기가 생긴다. 그래서 크기
선언은 공유하고 형상만 Kit이 가진다.

`ladder.json`도 공유다. `body.scale`은 세계 값 하나이므로 band가 Kit마다 달라지면
`requires_body`가 Kit마다 다른 뜻이 된다.

---

## 2. `res://content/scale/ladder.json`

```json
{
  "version": 1,
  "rungs": ["speck", "hand", "doll", "common", "tall", "colossal"],
  "values": [0.05, 0.12, 0.28, 0.65, 1.50, 3.60],
  "edges": [0.077, 0.183, 0.427, 0.987, 2.324],
  "band_min": [0.0, 0.077, 0.183, 0.427, 0.987, 2.324],
  "band_max": [0.077, 0.183, 0.427, 0.987, 2.324, 99.0]
}
```

| 키 | 타입 | 검증 | 근거 |
|---|---|---|---|
| `version` | int | `== 1` | `worldstate/STORE_VERSION` 관례 |
| `rungs` | Array[String] | 6개. 중복 0. 이름은 소문자 `[a-z_]` | `01` §1 |
| `values` | Array[number] | 6개. **엄격히 증가**. 전부 `> 0.0` | K1 |
| `edges` | Array[number] | 5개. **엄격히 증가** | `01` §2 |
| `band_min` | Array[number] | 6개. `band_min[i] == band_max[i-1]` (`i > 0`), `band_min[0] == 0.0` | 연속성 |
| `band_max` | Array[number] | 6개. **유한**. `band_max[5] == 99.0` | `01` §2.1 |

**`values`와 `edges`는 손으로 쓰지 않는다.** 이 파일은 `01_SCALE_ALGEBRA.md` §1·§2의
표를 옮긴 것이고, 그 표는 파생 규칙(인접 rung의 기하평균, 3자리 반올림)에서 나온다.
`tests/core/test_scale_ladder_shared.gd`(W0)가 세 Kit이 같은 값을 읽는지 **그리고**
`edges[i] == round(sqrt(values[i] * values[i+1]), 3)`인지 단언한다. 반올림 규칙이
바뀌면 그 테스트가 함께 바뀐다. 그러므로 이 파일은 "선언"이 아니라 "확인 가능한
파생물"이다.

---

## 3. `res://content/places/<place_id>.json`

### 3.1 스키마

```json
{
  "version": 1,
  "id": "loc.tea_stair",
  "region_id": "reg.tea",
  "tags": ["interior", "circulation"],
  "approaches": [
    {
      "id": "stair_keyhole",
      "band": "hand",
      "target_body_px": 96.0
    }
  ]
}
```

| 키 | 타입 | 검증 | 근거 |
|---|---|---|---|
| `version` | int | `== 1` | |
| `id` | String | 비어 있지 않음. 전역 유일 | `AxisPlace.create()`의 `p_id` |
| `region_id` | String | 비어 있지 않음 | `AxisPlace.FIELD_REGION_ID` |
| `tags` | Array[String] | 비어 있지 않은 String. 중복 0 | `AxisPlace.create()`가 중복을 `value_type_invalid`로 거부 |
| `approaches` | Array[Dictionary] | **1개 이상, 3개 이하** | S-INV-6 |
| `approaches[].id` | String | 접근로 안에서 유일 | |
| `approaches[].band` | String 또는 `null` | `ladder.json`의 `rungs` 중 하나이거나 `null` | `null`은 `requires_body` 없는 시작 장소 전용. K4 |
| `approaches[].target_body_px` | float | `24.0 ≤ v ≤ 420.0` | `03` §4·§5의 절 안 정수 분할이 이 범위에서 성립 |

**접근로당 authored 숫자는 `target_body_px` 하나뿐이다.** `module_px`, `relief_px`,
`contact_px`는 전부 여기서 파생된다(§3.2). author가 `module_px`를 쓰면
`03` §8의 분리 증명이 깨진다. `q = 1`에서 `module_count`가 `2.75`가 아니라
`2.75 / sub_detail_pixels`가 되기 때문이다. `sub_detail_pixels = 0.25`를 쓰면
matched 구간이 `[0.98, 1.02] → module_count [2.694, 2.806]`이 아니라
`[10.775, 11.225]`가 되고, 대각선 인접 값 `6.346`은 **matched 구간 아래로** 떨어져
여전히 겹침이 없지만 §7의 세 channel 중 `relief_ratio`와 `contact_ratio`의 matched
구간이 `0.02`·`0.060`에서 벗어나 **T6-6이 실패한다.**

author가 쓸 수 있는 다른 축은 저절로 **하나뿐**이다. 그것이 **월드의 크기
다양성**이고, `02` §5의 두 크기 문은 `target_body_px`의 차이로만 만들어진다.
`module_px`의 파종을 author에게 열면 그것은 **크기 다양성이 아니라 판독 불가**가 된다.

`test_scale_geometry.gd`는 `approaches[]`에 `sub_detail_pixels`, `surface_relief`,
`contact_span`, `module_px`, `relief_px`, `contact_px` 키가 하나라도 있으면
`derived_key_authored`로 거부한다. `05` §7.

### 3.2 파생 출력 (저장하지 않는다)

로더는 위 파일에서 **두 가지**를 만들어 스토어와 지형에 나눠 준다.

```
# (a) core/worldstate 로
AxisPlace.create(id, {
    "region_id": region_id,
    "tags": tags,
    "requires_body": { "scale_min": min(approach.band_min), "scale_max": max(approach.band_max) }
})
```

```
# (b) Kit 지형으로 (band = null 접근로는 스킵)
module_px   = target_body_px * 0.3636        # = target_body_px / FIT_TARGET
relief_px   = module_px * 0.02               # 03 §4.1 의 RELIEF_K
contact_px  = module_px * 0.060              # 03 §7 의 CONTACT_K
body_px     = target_body_px
q           = body.scale / band_rung_value
```

`0.3636`은 `1 / 2.75`를 4자리로 쓴 값이고 `ProceduralScaleFit.FIT_TARGET`에서
나온다. **author가 쓰지 않는다. 로더도 쓰지 않는다.** 로더는
`ProceduralScaleFit.module_count(1.0)`의 역수로 계산한다. 그러면 `FIT_TARGET`이
`07` Q8에서 `2.5`나 `3.0`으로 바뀌면 파생값이 저절로 함께 움직인다.

`band_min`/`band_max`는 `ladder.json`에서 band 이름으로 조회한다. `band`가 `null`인
접근로가 하나라도 있으면 `requires_body`는 **`{}`** 가 된다. 즉 그 장소는 아무 몸에도
요구하지 않는다. 그것이 `02` §3.3의 시작 장소다.

**`scale_min` 단독 금지(K5):** 로더는 `min == max`인 경우도 거부한다(`scale_band_degenerate`).
`band_min == band_max`인 단일 값 band는 없다. 구간이 한 점으로 퇴화하면
"이 크기여야 한다"가 되어 `02` §1.4의 함정에 빠진다.

### 3.3 `requires_body`는 공유 파일에 없다

`place.json`에 `requires_body` 키를 쓰면 로더가 `place_key_unknown`으로 거부한다.
`requires_body`는 §3.2(a)의 **결과**이지 입력이 아니다. 이것이 `02` §1의 "선언은
파생이다"가 코드에서 어떻게 강제되는지다.

---

## 4. 장소 요구 worked example 3종

난이도 증가 순. 셋 다 `res://content/places/`에 놓인다.

### 4.1 예제 A — 가장 단순: 단일 접근로, 요구 없음

```json
{
  "version": 1,
  "id": "loc.cold_open",
  "region_id": "reg.hedge",
  "tags": ["outdoor", "threshold"],
  "approaches": [
    {
      "id": "flat_ground",
      "band": null,
      "target_body_px": 180.0
    }
  ]
}
```

- 파생 `requires_body` = `{}`. `AxisPlace.requires_nothing()`이 true.
- `body_satisfies("loc.cold_open")`는 **어떤 `body.scale`에 대해서도**
  `unmet: []`을 돌려준다. `body.scale`이 absent여도 그렇다(`02` §3.3).
- 이것이 모든 Kit이 **반드시 하나씩** authored 해야 하는 장소 유형이다. `S-INV-3`.

### 4.2 예제 B — 보통: 두 접근로, 서로 다른 크기

같은 벽에 두 크기의 문이 있다. `tea_stair`의 실측값.

```json
{
  "version": 1,
  "id": "loc.tea_stair",
  "region_id": "reg.tea",
  "tags": ["interior", "circulation", "two_scale"],
  "approaches": [
    {
      "id": "stair_keyhole",
      "band": "hand",
      "target_body_px": 96.0
    },
    {
      "id": "stair_door",
      "band": "doll",
      "target_body_px": 240.0
    }
  ]
}
```

| 파생값 | 계산 | 결과 |
|---|---|---|
| `stair_keyhole` `module_px` | `96.0 / 2.75` | 34.909 |
| `stair_door` `module_px` | `240.0 / 2.75` | 87.273 |
| `requires_body.scale_min` | `min(0.077, 0.183)` | 0.077 |
| `requires_body.scale_max` | `max(0.183, 0.427)` | 0.427 |
| `q`(`hand` @ keyhole) | `0.12 / 0.12` | 1.000 |
| `q`(`doll` @ keyhole) | `0.28 / 0.12` | 2.333 |
| `q`(`doll` @ door) | `0.28 / 0.28` | 1.000 |
| `q`(`hand` @ door) | `0.12 / 0.28` | 0.429 |

`target_body_px` 비율 `96.0 : 240.0 = 1 : 2.50`. 그래서 `module_px`도 같은 비율이고
**같은 벽에 34.9px짜리 석회와 87.3px짜리 문짝이 나란히 있는 셈이다.** 이것이
`02` §5의 두 크기 문이고, **숫자 2.50 하나가 이 장면 전체를 결정한다.**

`hand` 몸에게 `stair_door`는 `q = 0.429`다. `module_count = 1.179`. 몸이 저절로 절
`module` 하나보다 **작다.** 그 `module`은 87.3px이므로 저절로 87.3px짜리 벽돌
`1.179`개에 저절로 96.0px짜리 몸이 들어간다. **어긋남이 이 한 줄에서 난다.**

`doll` 몸에게 `stair_keyhole`는 `q = 2.333`이다. `module_count = 6.417`.
`CAMERA_FRAME_MODULES = 6.0`이므로 몸이 화면보다 크다. `03` §3.2.

### 4.3 예제 C — 복잡: 세 접근로, 하나가 요구 없음, 한 개소가 두 스케일

`mirror_march`. 바로크 가면. `DESIGN_DECISION.md` §5 장면 C.

```json
{
  "version": 1,
  "id": "loc.mirror_march",
  "region_id": "reg.glass",
  "tags": ["interior", "threshold", "genre_shift", "two_scale"],
  "approaches": [
    {
      "id": "march_under",
      "band": "speck",
      "target_body_px": 60.0
    },
    {
      "id": "march_through",
      "band": "common",
      "target_body_px": 260.0
    },
    {
      "id": "march_ante",
      "band": null,
      "target_body_px": 200.0
    }
  ]
}
```

| 파생값 | 계산 | 결과 |
|---|---|---|
| `march_under` `module_px` | `60.0 / 2.75` | 21.818 |
| `march_through` `module_px` | `260.0 / 2.75` | 94.545 |
| `march_ante` `module_px` | `200.0 / 2.75` | 72.727 |
| `requires_body` | `null` 접근로가 있으므로 | **`{}`** |
| `module_px` 비율 under:ante:through | | **1 : 3.333 : 4.333** |

`requires_body`가 `{}`이므로 이 장소는 **모든 몸이 통과 가능하다.** 그런데 세 접근로의
절대 크기는 4.33배 차이가 난다. `speck` 몸에게 `march_through`는
`q = 0.05/0.65 = 0.0769` → `module_count = 0.212`. `03` §11의 `Q_RANGE` 하한
`0.1772`보다 작다. `colossal` 몸에게 `march_under`는 `q = 3.60/0.05 = 72.0` →
`module_count = 198.0`. `Q_RANGE` 상한 `5.4444`보다 훨씬 크다.

**그래서 `band`가 `null`인 접근로가 있으면 `requires_body`가 `{}`가 되지만, 그
접근로의 `q`는 여전히 정의되지 않는다.** 이 두 가지가 함께 있을 때 그 장소는
`S-INV-6`의 예외 조항을 만들지 않으면서도 `03`의 판독 범위를 벗어난다.
`test_scale_geometry.gd`가 이 조합(`null` band + 3 rung 이상 span)을
`scale_span_exceeds_fit`로 거부한다. **`band: null` 접근로는 저절로 1개만
허용되고, 그것이 있는 장소는 다른 접근로의 rung span이 2 이하여야 한다.**

`mirror_march`가 그 규칙을 어긴다. 그래서 이 예제는 **거부되는 authoring**의
예시로 남긴다. `07` Q6에 이 충돌을 올린다.

### 4.4 예제 D — 왕복 쌍 (가역 판에서 추가)

`tea_stair`에 `hand`와 `doll` 접근로가 있다(`§4.2`). 그 두 접근로 위에는
왕복 트리거 2쌍이 올라간다. **`ladder.json`의 숫자는 한 번도 쓰지 않는다.**

```json
{
  "version": 1,
  "triggers": [
    { "id": "trig.drink_keyhole",
      "kind": "consume",
      "at": { "place": "loc.tea_stair", "approach": "stair_keyhole" },
      "to_rung": "doll",
      "visual": { "spec_id": "prop.tea_keyhole", "act": "consume" },
      "audio": { "event": "body.drink", "bus": "SFX", "max_polyphony": 1, "volume_db": -4.0 } },

    { "id": "trig.stretch_keyhole",
      "kind": "consume",
      "at": { "place": "loc.tea_stair", "approach": "stair_keyhole" },
      "to_rung": "hand",
      "visual": { "spec_id": "prop.tea_keyhole_empty", "act": "consume" },
      "audio": { "event": "body.drink", "bus": "SFX", "max_polyphony": 1, "volume_db": -4.0 } },

    { "id": "trig.eat_door",
      "kind": "consume",
      "at": { "place": "loc.tea_stair", "approach": "stair_door" },
      "to_rung": "tall",
      "visual": { "spec_id": "prop.tea_door", "act": "consume" },
      "audio": { "event": "body.drink", "bus": "SFX", "max_polyphony": 1, "volume_db": -4.0 } },

    { "id": "trig.shrink_door",
      "kind": "consume",
      "at": { "place": "loc.tea_stair", "approach": "stair_door" },
      "to_rung": "doll",
      "visual": { "spec_id": "prop.tea_door_broken", "act": "consume" },
      "audio": { "event": "body.drink", "bus": "SFX", "max_polyphony": 1, "volume_db": -4.0 } }
  ]
}
```

| 트리거 | `from` band | `to_rung` | `steps` | 통행료 | 역방향 |
|---|---|---|---:|---|---|
| `trig.drink_keyhole` | `hand` (0.12) | `doll` (0.28) | 1 | `wounds` +1 `stretched` 0.34 | `trig.stretch_keyhole` |
| `trig.stretch_keyhole` | `hand` (0.12) | `hand` (0.12) | **0 → 거부** | — | — |

**이 예제는 그대로면 거부된다.** `stair_keyhole`의 band는 `hand`이므로
`trig.stretch_keyhole`의 `from`은 `hand`이고 `to_rung`도 `hand`다. `steps == 0`이므로
`scale_step_zero`로 거절된다. **같은 band 위의 트리거는 크기를 바꿀 수 없다.**

그래서 `04` §7-R6의 역방향 쌍은 **다른 band의 접근로**에서 와야 한다. 이 예제의
올바른 형태는 다음과 같다.

```
intermediate place  loc.stair_landing
  stair_landing_under  band = "doll"    to_rung = "hand"   (내려가기)
  stair_landing_over   band = "hand"    to_rung = "doll"   (올라가기)
```

| 트리거 | `from` band | `to_rung` | `steps` | 통행료 |
|---|---|---|---:|---|
| `trig.drop_to_hand` | `doll` (0.28) | `hand` (0.12) | 1 | +1 `compressed` 0.34 |
| `trig.rise_to_doll` | `hand` (0.12) | `doll` (0.28) | 1 | +1 `stretched` 0.34 |

**왕복의 최종 산술 (`04` §5.3).** `0.12`에서 출발해 `0.28`까지 갔다 돌아오면:
전환 2회, 확정 사실 2개, `severity` 합 `0.68`, 최종 `scale` **정확히 0.12**,
`wounds`는 `0.12`일 때보다 2개 많다. **`0.12`는 되돌아왔지만 몸은 같지 않다.**

**이것이 이 사양이 보는 "되돌림의 비용"이다.** 숫자 하나(`0.12`)는 돌아오고
몸은 돌아오지 않는다. 그래서 `04` §5.4가 불변식 5의 "불완전하게 돌아온다"와
정확히 맞는다.

---

## 5. 스케일 변경 트리거

트리거는 Kit이 소유한다. `modules/<kit>/content/triggers.json`에 있다.

### 5.1 스키마

```json
{
  "version": 1,
  "triggers": [
    {
      "id": "trig.keyhole_pass",
      "kind": "squeeze",
      "at": { "place": "loc.mirror_march", "approach": "march_under" },
      "to_rung": "speck",
      "requires": {
        "wound": { "part": "torso", "kind": "cracked", "permanent": true }
      },
      "visual": { "spec_id": "prop.membrane_pinch", "act": "squeeze" },
      "audio": { "event": "body.squeeze", "bus": "SFX", "max_polyphony": 1, "volume_db": -3.0 }
    }
  ]
}
```

| 키 | 타입 | 검증 | 근거 |
|---|---|---|---|
| `id` | String | 전역 유일. `trig.` 접두 | `DESIGN_DECISION.md` §3.1의 "`id`는 요구하지 않지만 권한다" |
| `kind` | String | `consume` \| `squeeze` \| `pressure` **셋만** | `04` §3 |
| `at.place` | String | `content/places/`에 존재하는 id | 존재하지 않으면 `trigger_place_unknown` |
| `at.approach` | String | 그 장소의 접근로 id | 존재하지 않으면 `trigger_approach_unknown` |
| `to_rung` | String | `ladder.json`의 `rungs` 중 하나 | `ladder.json`에 없으면 `scale_band_not_in_table` |
| `requires` | Dictionary, 없으면 `{}` | `wound` 키만. `{part, kind}` 필수, `permanent` 선택 | `AxisBody._is_wound_match()`가 `severity`를 거부 |
| `visual.spec_id` | String | 해당 Kit 지형 파일의 PVE spec 중 하나 | `spec_id`가 없으면 `visual_missing` |
| `visual.act` | String | `consume` \| `squeeze` \| `pressure` | `kind`와 동일해야 함 |
| `audio` | Dictionary, 없으면 `{}` | `audio_manifest`의 키와 동일한 형태 | `ROUND_PLAN.md` §C2 |

**`cost` 키가 없다. (2026-09-26 가역 판.)** 이전 판은 트리거마다 `cost`를
authored 했고 `kind`별 비용이 달랐다. 이제 가격은 `04` §4의 통행료 하나로 통일되고
**전혀 author가 쓰지 않는다.** 통행료는 `from`과 `to`의 방향 및 `steps`에서
파생된다.

```
toll_count = steps
toll_wound = { "part": "torso",
               "kind": ("compressed" if to_index < from_index else "stretched"),
               "severity": 0.34,
               "permanent": true }
```

authored `cost`가 남아 있으면 로더가 `trigger_cost_authored`로 거부한다.
**이유:** authored 비용과 파생 통행료가 겹치면 두 개의 가격이 생기고 어느 것이
적용되는지 모호해진다. `docs/CODE_STYLE.md`의 "중복 상태는 없다" 위반이다.
`missing`을 비용으로 쓸 수 있었던 것도 사라졌다. `missing`은 큰 사실이고 매 전환마다
쌓을 성질이 아니다. 부재를 잃는 것은 Kit이 저만의 authored 결과로 추가한다
(`04` §0.1).

### 5.1.1 역방향 간선은 별도로 authored 된다

`04` §7-R6: 간선 `{u, v}`가 있으면 `{v, u}` 간선이 **다른 trigger id**로 존재한다.
그래야 한다. `consume`는 오브젝트를 소비하고 그 오브젝트는 다시 생기지 않으므로,
같은 오브젝트가 왕복 두 번의 트리거를 겸할 수 없다. 두 방향은 서로 다른 오브젝트를
소비하고 서로 다른 `visual.spec_id`를 가진다.

| 트리거 | `at.approach` band | `to_rung` | `steps` | `id` |
|---|---|---|---:|---|
| 내려가기 | `speck` | `hand` | 1 | `trig.drop_to_hand` |
| 올라가기 | `hand` | `speck` | 1 | `trig.rise_to_speck` |
| 내려가기 | `hand` | `doll` | 1 | `trig.drop_to_doll` |
| 올라가기 | `doll` | `hand` | 1 | `trig.rise_to_hand` |

`steps`는 `|index(to_rung) - index(from_rung)|`이므로 **방향과 무관하게 양수다.**
이전 판은 `from < to`만 허용했으므로 방향을 검사했다. 이제 그 검사는 없다.
`from == to`만 금지한다.

### 5.2 파생: `from`과 `steps`와 `toll`

`from`도 `toll`도 authored가 아니다. `at.approach`의 `band`와 `ladder.json`에서 온다.

```
from_rung   = band(at.approach)                    # null 이면 from_rung 없음
steps       = |index(to_rung) - index(from_rung)|
toll_count  = steps
toll_kind   = "compressed" if index(to_rung) < index(from_rung) else "stretched"
```

| 조건 | 거부 reason |
|---|---|
| `at.approach`의 `band`가 `null` | `trigger_band_unknown`. 크기 변경 트리거는 band 접근로에 저절로 있어야 한다 |
| `steps == 0` | `scale_step_zero` |
| `steps > 2` | `scale_step_too_large` |
| `cost` 키가 있음 | `trigger_cost_authored` |

`steps`는 **저장되지 않는다.** 세션 중에 언제나 저절로 다시 계산된다.
`from`도 저장되지 않는다. `toll`도 저장되지 않는다. 저장되는 것은 `body.scale`
하나와 `body.wounds`에 쌓인 확정 사실뿐이다.

### 5.3 통행료가 쓰는 스토어 API

통행료는 `steps`개의 요청으로, 그 다음 `scale` 1개 요청으로 나간다.
**통행료가 먼저다.** `04` §1.1.

```gdscript
var wounds: Array = []
if body.has_field(AxisBody.FIELD_WOUNDS):
    wounds = (body.get_wounds() as Array).duplicate(true)
for k in steps:
    wounds.append({ "part": "torso", "kind": toll_kind, "severity": 0.34, "permanent": true })
    if request_mutation(&"body", { "wounds": wounds.duplicate(true) }, requester).ok == false:
        return   # honest failure.  04 §1.2
request_mutation(&"body", { "scale": ladder_value(trigger.to_rung) }, requester)
```

`AxisBody`에 `has_wound_any()` 같은 convenience 메서드가 없다. `has_field()`와
`get_wounds()`를 쓴다. `get_wounds()`는 absent면 `null`을 돌려주고 값이 있으면
**복사본**을 돌려준다(`CONTRACT.md` "`Every get_*` returns null for an absent field`").
그러므로 첫 반복 전에 반드시 복사본을 떼고 매번 새 복사본을 보낸다.

- **통행료 요청이 실패하면 `scale` 요청은 나가지 않는다.** 크기를 안 바꾸고
  통행료 일부만 냈다. 이것이 정직한 실패다.
- `scale` 요청이 실패하면 통행료는 이미 냈고 크기는 그대로다. **이 경우도 그대로
  둔다.** 되돌리지 않는다. `AxisBody`에 되돌리기 경로가 없다.
- `wounds`는 전체 배열을 되돌려 보낸다. `CONTRACT.md`가 "Appending is the kit's
  job: send the whole list back"이라고 명시한다.
- `AxisBody.WOUND_FIELDS`가 정확히 4개이므로 이 dict는 `wound_malformed`로
  거부되지 않는다. `severity: 0.34`는 JSON-safe `float`다.



### 5.4 초기 트리거

`02` §3.3의 시작 트리거. **유일하게 `band: null` 접근로에 놓일 수 있다.**

```json
{
  "id": "trig.first_drink",
  "kind": "consume",
  "at": { "place": "loc.cold_open", "approach": "flat_ground" },
  "to_rung": "speck",
  "initial": true,
  "visual": { "spec_id": "prop.membrane_drink", "act": "consume" },
  "audio": { "event": "body.drink", "bus": "SFX", "max_polyphony": 1, "volume_db": -4.0 }
}
```

| 키 | 검증 |
|---|---|
| `initial` | `true`/`false`. `true`인 트리거는 전 세계에서 최대 1개 |
| `initial`과 `band: null` | `at.approach`의 `band`가 `null`이어야 한다. 아니면 `initial_band_not_null` |
| `initial`과 통행료 | **`initial`은 통행료를 내지 않는다.** `from_rung`이 없으므로 `steps`도 없다. `04` §4 |

`initial` 트리거는 `steps` 검사를 건너뛴다(`from_rung`이 없으므로). `to_rung`은
`ladder.json`의 `rungs` 중 하나여야 한다. 그것으로 충분하다. 시작 몸이 `speck`(0.05)
이라는 결정은 `01` §4-K6의 논리와 같다. 정상 크기가 없다.

**`initial`은 통행료 면제다. 최초 한 번뿐이다.** 그것은 크기를 바꾸는 것이 아니라
**처음 채우는 것**이기 때문이다. `initial` 트리거는 1개뿐이고 그 뒤의 모든 전환은
`steps`만큼 통행료를 낸다.

`initial` 트리거는 **저장 전에 반드시 발동한다.** `body.scale`이 `null`인 상태로
저장할 수 있다는 뜻이고, 그 강제는 `07` Q9에 있다.

### 5.4.1 왕복 트리거 저작 체크리스트

트리거 저작할 때 확인할 것 세 가지:

| # | 확인 | 실패하면 |
|---:|---|---|
| 1 | 이 간선 `{u,v}`의 역방향 `{v,u}` 트리거가 세 Kit 어디에나 **있다** | `04` §7-R6. 그 rung에 갇힌 몸이 생긴다. `06` T8-5가 잡는다 |
| 2 | 그 역방향 트리거는 `id`가 다르고 `visual.spec_id`가 다르다 | 같은 오브젝트를 두 번 소비한다. `T8-10`이 잡는다 |
| 3 | 이 트리거는 `from_rung`에서 **나가는 유일한 길을 끊지 않는다** | 그 rung의 진출 차수가 0이 된다. `T8-3`이 잡는다 |

**트리거는 단방향으로 저작한다.** 그래야 되돌림이 사건으로 읽힌다. 그래야
"여기서 무엇을 먹어야 이 크기가 되나"가 장소 파일을 읽는 사람에게 보인다.

---

## 6. 로더가 거부하는 전체 목록

로더는 **authoring 오류만** 거부한다. 플레이어에게 refusal를 만들지 않는다(`02` §5).

| reason | 조건 |
|---|---|
| `place_version_unsupported` | `version != 1` |
| `place_id_invalid` | `id`가 빈 String |
| `place_id_duplicate` | 같은 `id`가 두 번 |
| `place_key_unknown` | 명세에 없는 키 |
| `region_id_invalid` | `region_id`가 빈 String |
| `tag_invalid` | 빈 String 또는 중복 |
| `approach_count_invalid` | 0개 또는 4개 이상 |
| `approach_id_duplicate` | 접근로 id 중복 |
| `band_not_in_table` | `band`가 `ladder.json`에 없음 |
| `null_band_count_invalid` | `band: null` 접근로가 2개 이상 |
| `scale_span_exceeds_fit` | 한 장소의 band span이 3 rung 이상 |
| `target_body_px_invalid` | `24.0` 미만 또는 `420.0` 초과 |
| `derived_key_authored` | `sub_detail_pixels`, `surface_relief`, `contact_span`, `module_px`, `relief_px`, `contact_px` 중 하나가 `approaches[]`에 있음 |
| `scale_band_degenerate` | 파생 `scale_min == scale_max` |
| `trigger_version_unsupported` | `version != 1` |
| `trigger_kind_unknown` | `kind`가 셋 중 하나가 아님 |
| `trigger_id_duplicate` | 트리거 id 중복 |
| `trigger_place_unknown` | `at.place`가 `content/places/`에 없음 |
| `trigger_approach_unknown` | `at.approach`가 그 장소에 없음 |
| `trigger_band_unknown` | `at.approach`의 `band`가 `null` |
| `scale_step_zero` | `steps == 0` |
| `scale_step_too_large` | `steps > 2` |
| `trigger_cost_authored` | 트리거에 `cost` 키가 있음. `04` §4의 통행료는 파생이다 |
| `initial_count_invalid` | `initial: true`가 2개 이상 |
| `initial_band_not_null` | `initial`인데 `at.approach`의 `band`가 `null`이 아님 |
| `wound_malformed` | 통행료 dict가 `WOUND_FIELDS` 4개가 아님 (`AxisBody`가 거부) |
| `requires_severity_forbidden` | `requires.wound`에 `severity` 있음 (`AxisBody`가 거부) |
| `reverse_trigger_missing` | `{u,v}` 간선의 역방향 `{v,u}` 간선이 세 Kit 어디에도 없음 (`04` §7-R6) |
| `reverse_trigger_shared_object` | `{u,v}`와 `{v,u}`가 같은 `visual.spec_id`를 씀 |
| `visual_missing` | `visual` 없음 또는 `spec_id` 없음 |
| `visual_act_mismatch` | `visual.act != kind` |

`scale_span_exceeds_fit`의 판정식:

```
spans = [band_max - band_min for each non-null approach]
if max(spans) > 0.427:  reject        # 0.427 = edges[2] - edges[1] = doll 전체 폭
```

즉 **한 장소의 접근로들이 저절로 band 폭 2개 이상을 덮으면 거부한다.**
`speck`+`doll`은 폭 0.427이라 통과, `hand`+`common`은 0.910이라 거부.
이것이 `03` §11의 `Q_RANGE` 보존을 강제하는 지점이다.

---

## 7. 금지된 키 (명시)

`place.json`에 쓰면 로더가 거부한다. `place_key_unknown`(명세에 없는 키)이거나
`derived_key_authored`(파생값을 author가 직접 쓴 경우)다.

`requires_body`, `scale`, `scale_min`, `scale_max`, `q`, `module_count`, `body_scale`,
`grid`, `chain`, `spec`, `sub_detail_pixels`, `surface_relief`, `contact_span`,
`module_px`, `relief_px`, `contact_px`, `version`이 아닌 모든 `scale_*`

트리거에 쓰면 `trigger_key_unknown`로 거부한다.

`from`, `from_rung`, `steps`, `toll`, `toll_count`, `toll_kind`, `toll_severity`,
`scale_delta`, `scale`, `count`, `index`, `visited`, `history`, `cooldown`, `timer`,
`price`, `cost_points`, `cost`

**이 목록이 왜 존재하는가:** `AxisBody`의 `DERIVED_KEYS`와 `NOT_CAPABILITY_KEYS`는
스토어만 막는다. authored 파일의 키는 스토어에 도달하기 전에 로더가 막아야 한다.
`from`과 `steps`가 특히 중요하다. 둘 다 `§5.2`에서 **파생**된다. authored에
쓰면 파생값과 저절로 중복 상태가 되어 `docs/CODE_STYLE.md`의 "중복 상태는 없다"를
위반한다.

`cost`가 금지된 것도 같은 이유다. `§5.1`에서 파생된다. **`toll`을 authored에 쓰면
통행료를 값으로 조작할 수 있다.** 그것은 `NOT_CAPABILITY_KEYS`에 `toll`이 들어 있는
이유와 같다 — 스토어도 그 이름을 거부한다.

---

## 8. 이 스키마가 세 Kit에게 요구하는 것

| Kit | 저절로 필요한 authored 단위 | 개수 |
|---|---|---|
| A `sideview_ecosystem` | `requires_body: {}`인 장소, 단일 접근로 장소, 두 크기 문 장소 | 각 1 이상 |
| B `physics_puzzle_platformer` | 위와 동일 + `squeeze` 트리거 1개 이상 | 각 1 이상 |
| C `descent_exploration` | 위와 동일 + `pressure` 트리거 1개 이상 | 각 1 이상 |
| 전 Kit | `initial` 트리거 1개 | 1 |
| 전 Kit | **왕복 트리거 쌍** — 각 `(u,v)` 간선마다 `(v,u)` 1개. `05` §5.1.1 | 모든 간선 |

**왕복 쌍이 각 Kit의 최소 요구인 이유:** `04` §7-R5는 rung 그래프 전체가 강연결일
것을 요구한다. 세 Kit이 자기 rung 묶음만 가진 채 서로를 이어 주는 것은 가능하지만,
그 경우 **어떤 Kit의 rung이 다른 Kit의 authored 콘텐츠 없이는 도달 불가**가 된다.
그러면 그 Kit의 Reference Game에 dead end가 생긴다. S-INV-3이 그것을 잡는다.

**두 번째 실제 사용처가 확인되기 전에는 새 shared 추출을 하지 않는다**
(`docs/CODE_STYLE.md`). `module_px`, `body_px`, `q` 계산이 세 Kit에 필요하지만
`ProceduralScaleFit`가 이미 `core/procedural`에 있다(`03` §9). Kit이 자기 것을
사본 만들어 쓰면 상수가 어긋난다. 그러므로 **Kit은 `ProceduralScaleFit`만 쓴다.**
자기 계산본을 만들지 않는다. `test_scale_geometry.gd`가 그걸 검사한다(로컬 상수
`FIT_TARGET` 선언 0건).

**통행료에도 같은 규칙이 적용된다.** `TOLL_SEVERITY = 0.34`, `TOLL_PART = "torso"`,
`TOLL_KIND_DOWN`, `TOLL_KIND_UP`은 Kit 로컬 상수로 선언하면 안 된다. Kit이
`0.34` 대신 자기 숫자를 쓰면 그 Kit의 `wounds`가 다른 Kit과 다른 단위가 된다.
**저장되는 값이 Kit마다 다른 단위**가 되므로 `CONTRACT.md` "What this store
cannot police"의 **unit conversion** 위반이다. `06` T7-8이 Kit 로컬 통행료 상수
선언 0건을 단언한다. 상수의 위치는 `04` §4.1 표가 정본이고 구현 위치는
`07` Q16이 정한다.
