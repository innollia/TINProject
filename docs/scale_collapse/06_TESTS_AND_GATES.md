# 06 — 테스트와 게이트

테스트 파일 경로, 각 파일이 단언하는 것, 정확한 명령. **이 문서의 어떤 테스트도
실행하지 않았다.** 여기 적힌 명령을 실행한 것은 아니다. `docs/CODE_STYLE.md`:
"실행하지 않은 테스트를 통과했다고 기록하지 않는다."

> **2026-09-26 가역 판 반영.** T2-13/T2-14(되돌림의 저장), T6-9(reader 중복),
> **T8 전체(rung 그래프), G12, G17~G21**이 이 판에서 추가되거나 바뀌었다.
> 아래 표가 정본이다.

---

## 1. 소유권과 배치

| 경로 | 소유자 | 비고 |
|---|---|---|
| `core/worldstate/tests/test_scale_*.gd` | W7 | 스토어 계약 검증 |
| `core/procedural/scale_fit.gd` + `core/procedural/tests/test_scale_fit.gd` | W2 | 기하 도우미와 분리 증명 |
| `res://content/scale/ladder.json`, `res://content/places/**` | W0 | 공유 authored |
| `tests/core/test_scale_*.gd` | W0 | 통합·텍스트·그래프 |
| `modules/<kit>/content/terrain/*.json`, `modules/<kit>/content/triggers.json` | W4/W5/W6 | Kit별 authored |
| `modules/<kit>/tests/test_scale_geometry.gd` | W4/W5/W6 | Kit별 형상 검증 |

**이 문서는 위 파일들을 만들지 않았다.** `docs/scale_collapse/**`만 만들었다.
아래는 **요청**이다.

---

## 2. 스토어 계약 테스트 (W7)

### T1 — `core/worldstate/tests/test_scale_bands.gd`

| # | 단언 | 근거 |
|---|---|---|
| 1 | `ladder.json`의 `band_min[i] == band_max[i-1]` (`i > 0`) | `01` §2.1 연속성 |
| 2 | `band_min[0] == 0.0` | `01` §2.1 |
| 3 | `band_max[5] == 99.0`이고 유한 | `01` §2.1 |
| 4 | 경계값 `0.183`은 `hand` band와 `doll` band **양쪽**에 대해 `satisfied == true` | `01` §2.1 의도된 중복 |
| 5 | `0.1829`은 `hand`에 대해 `satisfied == true` | §2.1 |
| 6 | `0.1831`은 `doll`에 대해 `satisfied == true` | §2.1 |
| 7 | `body.scale == null`이면 `scale_absent` 1개만 나오고 `scale_below_min`·`scale_above_max`는 나오지 않는다 | `AxisBody._unmet_for()` |
| 8 | `requires_body: {}`는 `scale`가 있어도 없어도 `unmet == []` | `02` §3.3 |
| 9 | `ladder`의 각 rung 값이 자기 band 안에 있다 | `01` §2 |

### T2 — `core/worldstate/tests/test_scale_no_normalise.gd`

**"store가 scale 값을 정규화하지 않는다"의 기계 증명.** 요구 사항의 정확한 항목이다.

| # | 단언 |
|---|---|
| 1 | `scale = 0.05` 쓰고 읽으면 `0.05` |
| 2 | `scale = 3.6` 쓰고 읽으면 `3.6`. `1.0`으로 좁혀지지 않는다 |
| 3 | `scale = 0.123456789` 를 10자리까지 읽어도 같다 |
| 4 | `scale = 200` 쓰고 읽으면 `200`. `01_SCALE_ALGEBRA.md` §4-K1의 Kit 규칙을 스토어가 대신 강제하지 않음을 확인 |
| 5 | `to_json()` → `load_json()` 후 `get_scale()`가 **원본과 같다** (float, `==`) |
| 6 | `to_dictionary()` → `AxisBody.apply()` 후 `get_scale()`가 같다 |
| 7 | `scale`을 쓰지 않은 `apply({"missing": [...]})` 이후 `has_scale()`가 **여전히 false** |
| 8 | `apply({"facts": {...}})` 이후 `has_scale()`가 이전과 같다 |
| 9 | `scale`을 int로 쓰면 int로 읽고, float로 쓰면 float로 읽는다. `CONTRACT.md`의 wire-type 복원 |
| 10 | `request_mutation(AXIS_BODY, {"scale": 0.12}, owner)` 다음 `{"scale": 0.28}`이면 `0.28`. 덮어쓰기는 되지만 **변환은 없다** |
| 11 | `copy()`한 축에 값을 쓰어도 원본이 변하지 않는다 |
| 12 | `get_scale()`가 돌려준 값을 변형해도 내부에 영향이 없다 (`_copy_value`) |
| **13** | **`{"scale": 0.28}`를 쓴 뒤 `to_json()` → `load_json()` → `get_scale()`가 `0.28`이다. `0.05`가 아니다. 시드에서 재계산되지 않는다** |
| **14** | 같은 상태에서 `{"scale": 0.12}`를 다시 쓰고 세이브/로드하면 `0.12`가 복원된다. **왕복이 저장 위에서 대칭이다** |
| **15** | `{"scale": 0.12}` → `{"scale": 0.28}` → `{"scale": 0.12}` 3회 후 세이브/로드 → `0.12`. **3회의 흔적이 남지 않는다** (재방문 기록 0개) |
| **16** | 통행료 `wounds` 1개 추가 후 세이브/로드 → 그 상처가 `part`/`kind`/`severity`/`permanent` 4개 값 **그대로** 복원된다. 스토어는 `severity` 0.34를 다른 값으로 바꾸지 않는다 |

13~15가 `ROUND_PLAN.md` §11.1b의 마지막 문장("세이브/로드가 현재 크기를 복원해야 한다")
을 기계로 만든 것이다. **15가 깨지면 `S-INV-8`(누적 스칼라 0개)이 깨진다.**
재방문이 흔적을 남긴다면 방문 카운터가 존재한다는 뜻이다.

### T3 — `core/worldstate/tests/test_scale_unmet_is_not_denial.gd`

| # | 단언 |
|---|---|
| 1 | `body_satisfies(미충족 장소)`가 `{ok: true, satisfied: false, unmet: [...]}`를 돌려준다. `ok`는 **true**다 |
| 2 | `body_satisfies`의 반환 키 집합이 정확히 5개다 (`ok`, `reason`, `detail`, `satisfied`, `unmet`) |
| 3 | **스토어의 공개 메서드 목록에 `place_id`를 인자로 받고 거부를 돌려주는 메서드가 없다.** `AxisPlace`·`WorldState`·`WorldStateView`의 메서드 목록을 리플렉션으로 뽑아 이름을 비교한다. `memory` 테스트와 같은 방식 |
| 4 | `AxisPlace`에 mutating 메서드가 0개. `CONTRACT.md` "There is no mutating method on this class and none will be added" |
| 5 | `request_mutation(AXIS_PLACE, ...)`가 무조건 `axis_read_only` |
| 6 | `get_requires_body()`를 두 번 부르면 서로 다른 Dictionary 객체다 (방어적 복사) |
| 7 | 반환된 `requires_body`를 변형해도 `to_dictionary()`의 결과가 변하지 않는다 |
| **8** | **가역으로 인해 스토어에 새 refusal가 생기지 않았다.** `AxisBody`·`AxisPlace`·`WorldState`·`WorldStateView`의 `Refusal vocabulary` 목록이 `CONTRACT.md`의 표와 **항목 수까지 동일**하다 |
| **9** | `requires_body`에 `toll`을 넣으면 `requires_body_not_capability` (`NOT_CAPABILITY_KEYS`에 `toll`이 있다) |
| **10** | `requires_body`에 `toll_min`을 넣으면 `requires_body_not_capability` (`THRESHOLD_SUFFIXES`) |

8번이 가역 판의 안전장치다. 통행료를 넣으려고 스토어에 새 refusal를 붙이는 것이
가장 자연스러운 실수이고, 그것이 `00_CONSTITUTION.md` 불변식 4를 깨뜨린다.

### T4 — `core/worldstate/tests/test_scale_no_accumulator.gd`

| # | 단언 |
|---|---|
| 1 | `AxisBody.FIELDS`가 정확히 `["missing","wounds","scale","facts"]` |
| 2 | `facts`에 `scale_delta`, `scale_total`, `scale_count`, `scale_level`, `rung`, `visited`를 넣으면 `value_not_json_safe`가 아니라 저절로 `key_unknown` 계열로 거부되거나 `DERIVED_KEYS`로 거부된다 |
| 3 | `scale_delta`를 필드로 넣으면 `key_unknown` |
| 4 | `requires_body`에 `scale_count`를 넣으면 `requires_body_key_unknown` |
| 5 | `requires_body`에 `karma`를 넣으면 `requires_body_not_capability` |
| 6 | `requires_body`에 `karma_min`을 넣으면 `requires_body_not_capability` (`THRESHOLD_SUFFIXES`) |
| 7 | `requires_body`에 `trust_at_least`를 넣으면 `requires_body_not_capability` |
| 8 | `scale`을 2번 써도 `0.12 + 0.28`이 되지 않는다 (누적 없음) |
| 9 | `AxisBody`의 메서드 목록에 이름에 `total`, `sum`, `count`, `average`가 포함된 것이 없다. `AxisCreature.memory`에 대한 기존 테스트와 같은 방식 |
| **10** | `facts`에 `visited_rungs`, `rung_log`, `scale_history`, `times_changed`, `returns`를 넣으면 거부된다 |
| **11** | `facts`에 `scale`을 넣으면 거부된다 (중복 상태. `01` §7) |
| **12** | **통행료는 누적 스칼라가 아니다.** `wounds` 배열에 같은 `{part:"torso", kind:"stretched", severity:0.34, permanent:true}`가 3번 들어가도 그 안에 `sum`/`total` 필드가 없고 `AxisBody`는 그 배열을 **읽기만** 한다. `AxisBody`에 `wounds`를 순회하는 메서드가 0개 |
| **13** | `missing`에 통행료가 쌓이지 않는다. `04` §0.1. `wounds`만 늘어난다 |

**12번이 이 축에서 가장 위험한 밀도다.** `wounds`가 늘어날수록 "몸이 얼마나
많이 바꿔 왔는가"를 세는 계기가 생긴다. 그것이 `04` §7-가 "저장 상태 0개"로
붙잡고 있는 이유다. `AxisBody`에 `wounds`를 순회하는 메서드가 **0개**여야 한다.

---

## 3. 절차 기하 테스트 (W2)

### T5 — `core/procedural/tests/test_scale_fit.gd`

| # | 단언 |
|---|---|
| 1 | `FIT_TARGET == 2.75` |
| 2 | `module_count(q) == 2.75 * q` |
| 3 | `module_count(1.0) == 2.75` |
| 4 | `is_matched(1.0)`이 true. `is_matched(2.1/2.75)`과 `is_matched(3.4/2.75)`이 **모두 true** (경계 포함) |
| 4b | `is_matched(2.099/2.75)`과 `is_matched(3.401/2.75)`가 **모두 false** |
| 4c | `is_matched(1.0/2.3077)`과 `is_matched(2.3077)`가 **모두 false** — 인접 rung이 matched가 아니다 (`03` §2.2) |
| 4d | `is_matched(0.97)`과 `is_matched(1.03)`이 **모두 true** — 이전 판의 좁은 창 `MATCHED_Q`가 아니다 |
| 5 | `body_frame_fraction(q) == module_count(q) / 6.0` |
| 6 | `relief_ratio(q) == 0.02 / module_count(q)` |
| 7 | `contact_ratio(q) == 0.060 / module_count(q)` |
| 8 | `ripple_ratio(q) == 0.0218 * module_count(q)` |
| 9 | `pitch_scale(q) == q` |
| 10 | `follow_clamp(5.4444) <= 0.5`, `follow_clamp(0.1772) >= -0.5` |
| 11 | `camera_shake(1.0) == 0.0` |
| 12 | `camera_shake(1.6) == 0.2 * 0.6` (`SHAKE_Q_LIMIT` 경계) |
| 13 | `signature(q)`의 반환값에 `TYPE_STRING`/`TYPE_STRING_NAME`이 0개 (§3의 텍스트 금지) |
| 14 | `signature()`이 `Node`, `Label`, `RichTextLabel`을 반환하지 않는다 |
| 15 | `ProceduralScaleFit`가 `Input.`, `InputMap`, `get_tree()`, `/root`, autoload, `randf()`, `randi()`를 쓰지 않는다 (`DESIGN_DECISION.md` §8-3) |
| **16** | `camera_shake(0.5)`는 `0.2 * (0.5 - 1) = -0.1`. **음수 shake가 가능**하다. `\|q-1\| ≤ 0.60` 구간 안에서 선형이라 그렇다. 절댓값 함수가 아니다 |

**16번은 의도된 것이다.** 흔들림은 `q`가 1에서 멀어지는 **방향**을 따라간다.
커진 몸은 위쪽으로 흔들리고 작아진 몸은 아래쪽으로 흔들린다. `q`는 무차원이므로
이 방향은 화면의 상하와 직접 대응한다. 가역 이후 이 방향이 **귀가 방향**과도
일치하므로(`03` §6.1) 눈과 귀가 같은 방향을 가리킨다.

### T6 — `core/procedural/tests/test_scale_fit_separation.gd`

**"어긋남이 글자 없이 판별 가능한가"의 기계 증명.** 요구 사항의 정확한 항목이다.

`ladder.json`의 6×6 = 25개 `(rung, band)` 쌍 전수에 대해:

| # | 단언 |
|---|---|
| 1 | `is_matched(rung_value, band_value) == (2.1 <= module_count(rung_value, band_value) <= 3.4)`. 25개 전부 |
| 2 | 대각선 6개에서 `module_count == 2.75` (± 1e-9) |
| 3 | 경계에 걸치는 칸 0개. 즉 어떤 쌍도 `module_count ∈ {2.1, 3.4}`가 아니다 |
| 4 | `min(대각선 위의 module_count) > 3.4`. 실제 값 `6.346` |
| 5 | `max(대각선 아래의 module_count) < 2.1`. 실제 값 `1.192` |
| 6 | 5개 channel 각각에 대해, `matched` 구간과 `matched` 밖의 최솟값/최댓값 사이에 **2중 간격**이 있다. `SEPARATION = 1.76` |
| 7 | `SEPARATION`을 1.0으로 낮추면 5개 channel 중 최소 하나가 겹친다. 즉 `1.76`은 이 5개 channel에 대한 최댓값이다 (이기면 아님을 증명) |
| 8 | 세 해상도(720p, 1080p, 1440p)에서 25개 쌍의 `module_count`가 **동일**하다 (`03` §3.3) |
| **9** | **`contact_ratio(q) == 3.0 * relief_ratio(q)`** 가 25개 쌍 전수에서 성립한다 (`03` §8.2.2) |
| **10** | `module_count(q) == 2.75 * pitch_scale(q)` 가 25개 쌍 전수에서 성립한다 |
| **11** | `ripple_ratio(q) == 0.05995 * pitch_scale(q)` 가 성립한다 (`0.0218 * 2.75`) |
| **12** | `3.0`을 `0.060 / 0.02`로 계산한 값과 `CONTACT_K / RELIEF_K`가 **비트 동일**하다 (hardcode 금지) |
| **13** | 25개 쌍에서 `module_count` / `relief_ratio` 가 모두 **양수**다. 음수가 되는 `q`는 없다 |
| **14** | **다섯 channel의 분리 배율이 모두 정확히 `1.76`이다.** `min(2.1/1.192, 6.346/3.4) = min(1.762, 1.867) = 1.762` |

**9~14번이 가역 판 + Q5에서 추가된 reader 감사 테스트다.** `03` §8.2는 다섯 reader가
**두 개의 독립 곡선**으로 붕괴한다는 것을 대수적으로 보였지만, 그 보기는
**테스트가 없다면 그대로 믿어진다.** 9~13이 그 것을 막는다. 특히 12번이 중요하다 —
`3.0`을 리터럴로 쓰면 `RELIEF_K`를 바꿀 때 `CONTACT_K`가 따라오지 않아
`03` §8.2.5의 두 번째 위험이 발생한다.

**T6-7과 T6-14의 관계.** T6-7은 "`1.76`은 이 5개 channel에 대한 최댓값"이라고 말하고
T6-14는 "그리고 5개가 모두 그 최댓값에 도달했다"고 말한다. **두 문장은 같이
성립해야 한다.** 이전 판의 좁은 `MATCHED_Q = [0.98, 1.02]` 창에서는 성립하지
않았다 — 그때는 다섯 중 셋이 `2.29`, 하나가 `2.26`이었다. `module_count` 기준
`[2.1, 3.4]`로 바꾼 결과 다섯이 같은 수가 되었고 그 수가 하한이다. `07` Q5, Q19.

**T5-4c가 Q5 결정을 검증하는 항목이다.** 인접 rung(`q = 0.4333`, `q = 2.3077`)이
matched가 아니어야 한다는 것은 `module_count` 기준 창이 rung 간격보다 좁다는 뜻이다.
`MATCHED_Q`를 없앴으므로 이제 이 조건은 **상수 두 개의 관계**로만 성립한다.

---

## 4. 통합 테스트 (W0)

### T7 — `tests/core/test_scale_ladder_shared.gd`

| # | 단언 |
|---|---|
| 1 | 세 Kit의 지형 파일이 **같은 경로** `res://content/scale/ladder.json`만 읽는다. Kit-local 사본 경로가 코드에 없다 |
| 2 | `ladder.json`의 `edges[i] == snapped_sqrt(values[i] * values[i+1], 3)` |
| 3 | `values`가 엄격히 증가하고 전부 `> 0.0` |
| 4 | `values`에 `1.0`이 없다 (`01` §4-K6) |
| 5 | `band_max[5] == 99.0`이고 유한 |
| 6 | `rungs`에 `1.0`에 해당하는 이름이 없다 |
| 7 | 세 Kit의 지형 파일에 로컬 `FIT_TARGET` 선언이 0건 |
| **8** | **세 Kit의 소스/트리거 파일에 로컬 통행료 상수(`0.34`, `"torso"`, `"compressed"`, `"stretched"`) 선언이 0건** (`05` §8) |
| **9** | 세 Kit의 소스/트리거 파일에 `cost` 키가 0건 |
| **10** | `docs/world/12_SCALE_RULES.md`의 본문에 `ladder.json`의 **6개 rung 값**(6개) 또는 **5개 band 경계값**(5개)이 **0건** 등장한다. rung **이름**은 등장해도 된다 | `ROUND_PLAN.md` §11.1a |
| **11** | 같은 파일 본문에 `S1`~`S10` 문자열, `칸`, `H(b)`, `m(b)`, `a(b)`, `D0`~`D4`, `2^(b`가 **0건** 등장한다. `§8`의 제거 로그가 **형태의 이름만** 적는 것도 통과다 | `ROUND_PLAN.md` §11.1a |

**10·11이 이 사양이 `docs/world/12_SCALE_RULES.md`에 내는 요구다.** 그 파일은
**두 번째 숫자 정본이 아니다.** 10번이 깨지면 그 파일이 정본이 되고, 그 순간
`ladder.json`과 그 파일이 서로 다른 값을 말하게 된다. 11번이 깨지면 제거된
사다리 형태가 다른 이름으로 살아 있는 것이다.

**11번이 허용하는 것.** 그 파일의 §8은 "10단계 사다리", "칸 단위", "밀도 단계 5개"처럼
**형태의 이름만** 적는다. 값은 없다. **제거 로그가 제거된 항목의 이름을 다시
나열하는 것은 두 번째 사다리를 세우는 것이 아니다.** 값을 다시 적는 것은 그것이다.

**8번이 없으면 통행료가 Kit마다 다른 단위가 된다.** 저장되는 값
(`body.wounds`의 `severity`)이 Kit마다 다른 meaning을 갖게 되므로
`CONTRACT.md` "What this store cannot police"의 unit conversion 위반이 된다.
스토어는 그 차이를 못 잡는다. **그러므로 W0의 통합 테스트가 잡아야 한다.**

### T8 — `tests/core/test_scale_rung_graph.gd`

`ladder.json` + 세 Kit의 `triggers.json`을 읽는다.
**파일명이 `test_scale_rung_dag.gd`에서 `test_scale_rung_graph.gd`로 바뀐다.**
사이클을 금지하는 테스트가 아니다.

| # | 단언 | 근거 |
|---|---|---|
| 1 | 자기 루프 **0개** (`to_rung == from_rung`) | `04` §7-R1. `scale_step_zero` |
| **2** | **모든 rung의 진출 차수 `≥ 1`** | `04` §7-R3. 나가는 길이 없는 rung이 없어야 한다 |
| **3** | **모든 rung의 진입 차수 `≥ 1`** | `04` §7-R4. 들어가는 길이 없는 rung이 없어야 한다 |
| **4** | **그래프가 강연결이다** — 정점 6개 전체가 하나의 SCC | `04` §7-R5 |
| **5** | **모든 정점 쌍 `(u,v)`, `u != v`에 대해 `u`에서 `v`로 가는 경로가 있다** | 강연결의 정의. DFS 1회로 판정 |
| **6** | 간선 수 `≥ 6` | 강연결 그래프의 최소 간선 수 = 정점 수 |
| **7** | 모든 트리거의 `steps ∈ {1, 2}` | `04` §2 |
| **8** | **어떤 트리거도 `from`/`to`의 방향을 가리지 않는다** — `index(to) < index(from)`인 트리거가 3개 이상 존재 | `04` §5. 되돌림이 실제로 authored 되었는지. 3개는 6 rung 강연결의 최소 조건 |
| **9** | **모든 간선 `{u,v}`에 대해 역방향 `{v,u}` 간선이 `id`가 다르게 존재** | `04` §7-R6. `05` §5.1.1 |
| **10** | `{u,v}`와 `{v,u}`가 같은 `visual.spec_id`를 쓰지 않는다 | `05` §6 `reverse_trigger_shared_object` |
| **11** | `initial: true`인 트리거가 정확히 1개 | `05` §5.4 |
| **12** | 그 트리거의 `at.approach`의 `band`가 `null` | `05` §5.4 |
| **13** | 그 트리거 외에 `band: null` 접근로에 놓인 트리거가 0개 | `trigger_band_unknown` |
| **14** | **저장 스키마에 rung 방문 기록 필드가 없다.** `to_dictionary()`의 키에 `visited`, `history`, `rung_log` 계열이 없다 | `S-INV-8`. `06` T4-10과 중복 단언. 여기서도 확인한다 |
| **15** | 각 Kit의 `triggers.json`에 `from`, `from_rung`, `steps`, `toll`, `cost` 키가 0건 | `05` §7 |
| **16** | `scale` 문자열을 **필드로** 가진 트리거가 0건 | `05` §7 |
| **17** | **통행료 산술이 전수에서 일치한다.** 모든 `(from, to)` 쌍에 대해 `derived_toll_count == steps` 그리고 `derived_toll_kind == ("compressed" if to < from else "stretched")` | `04` §4.1. 방향과 무관하게 1개씩 |

**이전 판의 2개 단언이 사라졌다.** "사이클 0개"와 "각 rung의 진출/진입 차수 ≤ 2"가
그것이다. **둘 다 되돌림과 정반대**이므로 폐기한다. 폐기 사유를 여기에 적는다:
되돌림이 없으면 차수 상한이 `Q_RANGE`를 보존하는 수단이었고, 지금은 `S-INV-6`이
그 수단이다(`03` §11.1).

**8번이 이 판에서 새로 생긴 "가역이 실제로 구현되었나" 단언이다.** 가역이
정본에만 있고 authored 콘텐츠에 역방향 트리거가 하나도 없으면 게임에서는 되돌릴
수 없다. **문서가 가역이고 콘텐츠가 단방향인 상태가 가장 나쁜 상태**이므로 이
단언이 필수다.


### T9 — `tests/core/test_scale_text_free.gd`

**어떤 스케일 시스템도 플레이어에게 텍스트를 내지 않는다.** 요구 사항의 정확한 항목이다.

| # | 단언 |
|---|---|
| 1 | `modules/sideview_ecosystem/**`, `modules/physics_puzzle_platformer/**`, `modules/descent_exploration/**`를 스캔한다 |
| 2 | 스케일 시스템이 **생성한** `Label`/`RichTextLabel`/`AcceptDialog`/`Tooltip`의 `text`가 빈 String이다 |
| 3 | `03` §10의 금지 목록(`q`, `module_count`, rung 이름, "scale", "작다", "크다", "too small", "too big", "size")이 소스 코드 문자열에 0건. `tools/procedural_contract_dump.gd`와 같은 원리 |
| 4 | 스케일 게이지 노드 유형이 0건 (`TextureProgressBar`, `ProgressBar`, `Gauge`) |
| 5 | 스케일 시스템이 `Input` 또는 `InputMap`을 읽지 않는다 (domain/presentation 분리) |
| 6 | 스케일 시스템의 `signa`/`signature` 계열 함수 반환값에 `String`이 0개 |
| **7** | **되돌림이 아무 글자도 내지 않는다.** `ROUND_PLAN.md` §11.1b가 만든 새 사건(귀가)을 알리는 `Label`/`RichTextLabel`/`AcceptDialog`/`Tooltip`이 0개 |
| **8** | **통행료가 아무 글자도 내지 않는다.** 통행료 소모를 알리는 문자열(`"overgrown"`, `"bloated"`, `"price"`, `"cost"`, `"hurt more"`)이 소스에 0건 |
| **9** | **잘못된 rung에 대한 경고가 0건.** `body_satisfies()`의 `unmet` 문자열(`"scale_below_min"`, `"scale_above_max"`)이 `Label.text`에 assigned 되는 경로가 코드에 0개 |
| **10** | **되돌림으로 판단을 바꾸는 상태가 0개.** "되돌아왔다/되돌아가지 못했다"를 저장하거나 비교하는 필드가 `to_dictionary()`에 0개 |

`03` §10의 금지 목록은 "소스에 문자열이 없다"가 아니라 **"플레이어에게 도달하는
문자열이 없다"** 를 검사해야 한다. 2번이 실제 단언이고 3번은 보조 단언이다.
3번이 실패해도 2번이 통과하면 통과로 본다. **3번은 2번의 대리 지표가 아니다.**

**7~10번이 가역 판의 text-free 게이트다.** 가역이 세 가지 새 위험을 만든다:
귀가 안내, 통행료 고지, 잘못된 크기 경고. 셋 다 `AGENTS.md`의 "상시 HUD 금지"와
`ROUND_PLAN.md` §11.3의 "설명문 0개"를 정면으로 건드린다. 그러므로 명시적으로
강제한다. `03` §6.1의 하강 도약이 귀가 신호이므로 **7번의 부재가 해롭지 않다.**

### T10 — `tests/core/test_no_binary_assets.gd` (W0 기존)

`ROUND_PLAN.md` §5. 이미 있는 파일이다. `.png .jpg .jpeg .webp .bmp .svg .ttf .otf
.aseprite .kra` 를 각 Kit 폴더에서 검사한다. 스케일 시스템은 새 예외를 만들지 않는다.

---

## 5. Kit별 형상 테스트 (W4 / W5 / W6)

각 Kit이 `modules/<kit>/tests/test_scale_geometry.gd`를 만든다. **동일한 단언 목록**을
각 Kit이 구현한다. 공통 단언:

| # | 단언 | 근거 |
|---|---|---|
| G1 | 모든 `place.json`이 `05` §6의 로더 거부 목록에 걸리지 않는다 | `05` §6 |
| G2 | 각 장소의 `requires_body`가 파생 결과와 **일치**한다 | S-INV-4 |
| G3 | 각 Kit의 형상이 그 `requires_body`와 일치한다. 접근로의 `module_px`로 만든 콜라이더의 개구리가 해당 band의 `body_px`를 통과시킨다 | S-INV-4 |
| G4 | 한 장소의 band span이 2 rung 이하 | `05` §6 |
| G5 | `requires_body: {}`인 장소가 Kit마다 1개 이상 | S-INV-3 |
| G6 | 그 `{}` 장소의 접근로 중 `band: null`인 것이 1개 | `02` §3.3 |
| G7 | 그 `{}` 장소에 `initial` 트리거가 연결되어 있다 | `05` §5.4 |
| G8 | 모든 트리거의 `at.place`와 `at.approach`가 존재 | `05` §6 |
| G9 | 모든 트리거의 `visual.spec_id`가 이 Kit 지형 파일의 PVE spec 중 하나 | `05` §5.1 |
| G10 | 모든 `requires.wound`에 `severity`가 없다 | `AxisBody._is_wound_match()` |
| **G11** | **모든 트리거에 `cost` 키가 없다** | `04` §4. `05` §5.1 |
| G12 | 접근로의 `target_body_px`가 `[24.0, 420.0]` | `05` §3.1 |
| G13 | `ProceduralScaleFit`의 로컬 복사본이 없다. `FIT_TARGET` 등 상수 선언 0건 | `05` §8 |
| G14 | 스케일 시스템이 `randf()`/`randi()`를 시드 경로 밖에서 쓰지 않는다 | `DESIGN_DECISION.md` §8-3 |
| G15 | **Kit 이미지 파일 0개** | `ROUND_PLAN.md` §5 |
| **G16** | 이 Kit의 모든 트리거의 파생 `steps ∈ {1, 2}`이고 `0`이 아니다 | `04` §2 |
| **G17** | 이 Kit의 트리거 중 `index(to_rung) < index(from_rung)`인 것이 **1개 이상** | `04` §5 |
| **G18** | 이 Kit의 트리거 중 `index(to_rung) > index(from_rung)`인 것이 **1개 이상** | `04` §5 |
| **G19** | 이 Kit의 모든 트리거의 `visual.spec_id`가 역방향 분을 갖는다 (세 Kit 합집합 기준) | `04` §7-R6 |
| **G20** | 이 Kit의 지형 파일에 `0.34`, `"torso"`, `"compressed"`, `"stretched"` 리터럴이 스케일 통행료 맥락에서 0건 | `04` §4.1 |
| **G21** | 이 Kit의 `band: null` 접근로는 `initial` 트리거의 것 1개뿐 | `05` §6 |
| G22 | `kind == "squeeze"`인 트리거도 `consume`/`pressure`와 **똑같이** 통행료를 낸다. `squeeze`에 특별한 비용 분기가 코드에 0개 | `04` §3.2 |

**G17과 G18이 가역 판의 핵심 Kit 단언이다.** 둘 중 하나가 깨지면 사양은 가역인데
그 Kit은 플레이어가 갈 수 있는 방향이 한쪽뿐이다. 한쪽뿐인 Kit에는 dead end가
나오고 S-INV-3이 깨진다.

**G19는 단 Kit 단독으로 판정할 수 없다**는 것을 명시한다. 역방향 쌍이 두 Kit에
걸쳐 있을 수 있다. 단 Kit 테스트는 "이 Kit의 트리거마다 역방향 분이 세 Kit
합집합에 존재하는가"까지만 본다. 최종 판정은 T8-9가 한다.

**이전 판의 G10(`cost.wound`의 `WOUND_FIELDS` 4개)과 G12(`squeeze_requires_cost`)는
삭제됐다.** 첫째는 `cost`가 없어졌으므로, 둘째는 `04` §4가 `squeeze`에도
통일 통행료를 붙였으므로. G22가 그 통일성이 깨지지 않았음을 본다.

### G3의 정확한 판정

Kit 형상 파일이 접근로마다 `aperture_px`를 준다고 하자(없으면 파생).

```
body_px(rung) = target_body_px * rung_value / band_rung_value
aperture_px   = field("aperture_px") or (module_px * 2.0)

for rung in ladder.rungs:
    passes = aperture_px >= body_px(rung)
    assert passes == (rung in band of this approach)
```

즉 **개구리는 정확히 그 band의 rung들을 통과시키고 그 외는 통과시키지 않아야 한다.**
이것이 S-INV-4의 기하 쪽 절반이고, G2가 요구 조건 쪽 절반이다. 둘이 일치해야 한다.

### G3-1 이 판에서 추가된 판정: 개구부는 부대칭이다

가역(`04` §5) 이후에도 G3 판정은 **바뀌지 않는다.** 그리고 그게 핵심이다.

`aperture_px`는 authored 값이고 한 번 정해지면 변하지 않는다. 따라서 통과할 수 있는
rung의 집합은 **항상 같은 방향만 향한다.** 되돌림이 가능하다는 것은 **그 방향이
반복해서 쓰일 수 있다는 뜻이지, 개구부가 양방향으로 열린다는 뜻이 아니다.**

이 비대칭이 세 가지를 만든다.

| # | 결과 | 왜 필요한가 |
|---|---|---|
| 1 | `02` §3.6의 refusal 두 개(approach 없음, edge 없음)가 **의미를 유지한다** | 기하가 양방향이면 잘못된 rung인 체류 상태가 없어지고 `02` §3.4~§3.6의 관찰(W1/W2/W3)이 전부 사라진다 |
| 2 | 통행료가 의미를 갖는다 | 개구부가 양방향이면 "이 크기로 오는 데 돈을 내는"이 없다. 대가는 **크기 변경**에서만 나올 수 있다. `04` §4가 거기 있다 |
| 3 | `requires_body`가 권한이 아니다 | `body.scale`을 바꾸면 통과 집합이 **바뀐다.** 그 통로가 없고, 통행료를 내면 통과 집합이 열린다. 고정된 통과 조건이 아니다 |

**반대 방향의 단언을 추가하지 않는다.** `aperture_px`가 `to_rung` 방향으로도
열려 있음을 요구하는 테스트를 쓰면 S-INV-4가 깨진다. 양방향 개구부는
`target_body_px`가 `band_rung_value`에 관계없이 모든 rung에 대해 성립해야 한다는
뜻이고, 그러면 `module_px`가 `q`와 무관해져 `03` §2가 무효가 된다.

---

## 6. 명령

`AGENTS.md`의 "완료 전 자동 검증" 순서 그대로다. **아무것도 실행하지 않았다.**

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'

$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait -PassThru
$p.ExitCode

$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/run_tests.gd' -NoNewWindow -Wait -PassThru
$p.ExitCode

$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://core/worldstate/tests -gdir=res://core/procedural/tests -gexit' -NoNewWindow -Wait -PassThru
$p.ExitCode

$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --quit-after 180 --fixed-fps 60' -NoNewWindow -Wait -PassThru
$p.ExitCode
```

T1~T6은 3번째 명령에 포함된다. T7~T9는 `tests/core/`를 스캔하는
`res://tests/run_tests.gd`에 포함되어야 한다. G1~G16은 각 Kit의 디렉터리를
`-gdir`로 추가해야 하므로, Kit 구현이 시작되면 3번째 명령이 아래처럼 된다.

```powershell
$gut = 'addons/gut/gut_cmdln.gd -gdir=res://core/worldstate/tests -gdir=res://core/procedural/tests'
foreach ($kit in @('sideview_ecosystem','physics_puzzle_platformer','descent_exploration')) {
    $gut += " -gdir=res://modules/$kit/tests"
}
$p = Start-Process -FilePath $GodotExe -ArgumentList "--headless --path C:\projects\TINProject --script $gut -gexit" -NoNewWindow -Wait -PassThru
$p.ExitCode
```

---

## 7. 해상도 게이트 (수동, 미실행)

`AGENTS.md`의 필수 수동 검수. **아무것도 캡처하지 않았다.**

| 해상도 | 확인할 것 | 스케일 관련 |
|---|---|---|
| 1280×720 | 잘림 없음, focus 유지, 월드 영역 유지 | `module_px`가 24.0일 때 하위 셀 대각선 가시 |
| 1920×1080 | 같은 것 | `module_px`가 420.0일 때 상위 셀 대각선 가시 |
| 2560×1440 | 같은 것 | 같은 |

추가로 이 사양이 요구하는 것:

- `q = 0.1772`와 `q = 5.4444`에서 §3.2의 잘림이 세 해상도에서 **같다** (T6-8).
- `target_body_px` 24.0(하한)과 420.0(상한)에서 `soft_grid`의 `width`/`height` clamp가
  발동하는지와 발동하지 않는지가 세 해상도에서 같다.
- `relief_px = module_px * 0.02`이 `target_body_px` 두 극단에서 보이는 정도가
  세 해상도에서 **비슷**하다. (`module_px`가 8.727이면 `relief_px`가 0.175px라
  1080p에서 0.35px에 불과하다. 이 극단은 읽히지 않을 수 있고, 그것은 계측 대상이다.)

### 7.1 가역 판이 추가한 계측 3종 (미실행)

**이 계측은 수행하지 않았다.** 아래는 요구 사항이지 결과가 아니다.

| # | 계측 | 왜 | 판정 |
|---|---|---|---|
| **M1** | 한 rung에 인접 rung 1개만 있는 장소에서, **의도적으로 2 rung 어긋난 체류 상태**를 세 해상도로 캡처 | `03` §3.2.1. 잘림이 상주 상태가 되었을 때 그것이 불편해 보이는지 | `module_count`가 6.35 근처여서 몸이 잘려 보인다. **이것이 "불편함"이면 S-INV-6이 편안함의 상한으로 작동한다.** 아무 차이도 안 느끼면 `S-INV-6`은 편안함 상한이 아니라 수식 보존 규칙일 뿐이고 그 사실을 기록한다 |
| **M2** | 1 rung 전환과 그 되돌림을 연속으로 재생하고, 두 경우의 `pitch_scale` 도약을 청취 비교 | `03` §6.1. 하강 도약이 귀가 신호인지 | `14.5~15.2` 반음의 도약이 방향만 다른 것을 **구별**할 수 있는지. 구별 불가면 `pitch_scale = q`를 `q`가 아니라 **부호 있는 로그 이동량**으로 바꾼다. 그 경우도 `03` §9 서명은 바뀌어야 하므로 Q5와 함께 결정한다 |
| **M3** | 10분 Reference Game를 한 번 플레이하며 `body.wounds`에 쌓이는 통행료를 세어 본다 | `04` §4.2. `0.34`가 맞는지 | 최소 3개 서로 다른 rung 방문(1 rung 이동만) → 전환 4회, `wounds` 4개, `severity` 합 `1.36`. 2 rung 왕복이면 6개 / `2.04`. **두 번째 값이 Kit의 상처 사다리 "한 번의 큰 상처" 선을 넘는지** 를 본다. 넘으면 `0.25`로 낮추고 `07` Q14를 닫는다 |

**M3의 판정이 이 사양에서 가장 실무적이다.** 통행료는 유일하게 되돌림에 붙는
가격이고, 그 크기가 Kit의 나머지 모든 물리와 어긋나면 스케일 축과 진행 축이
`04` §0.1이 금지한 방식으로 섞인다. **`2.04 > 2.0`은 이미 이 사양 안에서
증명된 모순이다.** `04` §4.2와 §5.3이 그 두 값을 적고 있고 `07` Q14가
`0.25`를 권고한다. **계측 없이 확정하지 않는다.**

---

## 8. 통과 판정

| # | 단언 | 판정 |
|---|---|---|
| P1 | T1~T6 전부 통과 | 필수 |
| P2 | T7~T9 전부 통과 | 필수 |
| P3 | 세 Kit의 G1~G22 전부 통과 | 필수 |
| P4 | T9-2 (플레이어에게 도달하는 문자열 0개) 통과 | 필수. 이 하나가 깨지면 `03` 전체가 무효 |
| **P4b** | **T9-7, T9-8, T9-9 통과** (되돌림·통행료·잘못된 rung에 글자 0개) | 필수. 가역 판이 만든 세 위험 |
| P5 | T6-6 (`SEPARATION = 1.76` 유지) 통과 | 필수. 깨지면 `MATCHED_Q`를 다시 정해야 한다 |
| **P5b** | **T6-9, T6-12 통과** (`contact_ratio == 3.0 * relief_ratio`, `3.0`이 파생값) | 필수. 깨지면 다섯 reader가 독립 5개가 되고 `03` §8.2.5의 위험이 발생 |
| P6 | T2 (정규화 없음) 통과 | 필수. `worldstate/CONTRACT.md`의 대명사 |
| **P6b** | **T2-13, T2-14, T2-15 통과** (저장 위의 왕복 대칭, 재방문 흔적 0개) | 필수. `ROUND_PLAN.md` §11.1b 마지막 문장 |
| **P6c** | **T8-4, T8-5, T8-8, T8-9 통과** (강연결, 하강 트리거 ≥ 3, 역방향 쌍) | 필수. 깨지면 사양만 가역이고 게임은 단방향 |
| P7 | §7의 세 해상도 계측 완료 | 필수. 미실행 |
| **P7b** | **deliberate 2-rung 어긋남 상태에서 세 해상도 캡처를 뜬다** | 필수. `03` §3.2.1의 "잘림의 상주화"가 실제로 어떻게 보이는지 계측 |
| P8 | Kit별 Reference Game 10분+ 플레이에서 **서로 다른 rung 3개 이상** 방문 | 필수. `AGENTS.md`. 왕복은 1개의 방문으로 친다 (`01` §5.1) |
| P9 | `AGENTS.md`의 이미지 0개 게이트 통과 | 필수. T10 |

**P1~P6만으로 "완료"라고 쓰지 않는다.** `docs/CODE_STYLE.md`:
"자동 테스트 통과를 화면/Kit 완료로 번역하지 않는다."
`P7`과 `P8`이 남는다.

**P6b, P6c가 이 판에서 가장 중요한 세 줄이다.** 그 둘이 깨졌을 때의 실패 모드는
**"모든 테스트가 통과했는데 게임에서 되돌릴 수 없다"** 이다. 자동 테스트는 그 상태를
구분하지 못한다. P7b의 수동 계측이 구분한다.

---

## 9. 이 문서가 만들지 않은 것

- 테스트 파일 0개
- authored JSON 0개
- `core/worldstate/**` 수정 0건
- `core/procedural/**` 수정 0건
- `res://content/**` 생성 0건 (경로가 존재하지 않는다)
- `modules/**` 수정 0건
- `plans/**` 수정 0건
- `docs/world/12_SCALE_RULES.md` 쓰기 1건 (12_SCALE_RULES.md 한정)

`docs/scale_collapse/**` 안의 8개 markdown 파일과 `docs/world/12_SCALE_RULES.md`가
이 작업의 전체 산출물이다.
