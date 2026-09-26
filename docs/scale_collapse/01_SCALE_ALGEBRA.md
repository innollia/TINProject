# 01 — 스케일 대수 (scale algebra)

`body.scale`이 가질 수 있는 정확한 값, 그 값이 뜻하는 것, 그리고 그것이 될 수 없는 것.

> **2026-09-26 정합 판 (W1e).** 이 파일의 §2.2, §4-K6, §7은 "`body.scale`은
> 스토어가 있는 그대로 저장하고 사다리 강제는 다른 곳의 몫"이라고 적고 있었다.
> **구현은 반대다.** `core/worldstate`가 사다리 밖의 값을 거절하고, `1.0`은
> `scale_rung_forbidden`으로, 나머지 사다리 밖의 유한값은 `scale_not_rung`으로 거절하며
> **가까운 rung으로 눌러 맞추지 않는다.** 구현이 정본이고 그 세 곳을 고쳤다.
> `DESIGN_DECISION.md` §8이 이 충돌을 미결로 남겼던 항목도 이 판에서 종결되며,
> 근거는 §7.1이다. **K 번호는 바꾸지 않았다** — `05_AUTHORED_FORMAT.md`와
> `06_TESTS_AND_GATES.md`가 K5·K6을 인용한다.

읽기 전제: `core/worldstate/CONTRACT.md`의 `AxisBody.FIELD_SCALE`은 `number`이고
`get_scale() -> Variant`는 없는 필드에서 `null`을 돌려준다. 이 문서는 **값이 어떤
범위에 있는가**와 **그 범위를 무엇이 지킨다**를 정한다. 저장·복원은 스토어의 몫이고,
**값의 영역이 닫혀 있다는 사실의 판정도 스토어의 몫이다** (§7.1).

---

## 1. 사다리 (the ladder)

`body.scale`은 **선형 높이 비율**이다. 비율의 기준은 그 몸이 서 있는 장소가 저절로
선언한 `reference_body_px`다. 세계에 공유되는 기준 높이는 없다. 기준은 장소마다
다르고, 그래서 `0.65`는 구역 A에서 어떤 크기이고 구역 B에서 다른 크기다.
`PROJECT_DECISIONS.md` §14의 "1,000을 쓰다 100을 쓴다"는 **단위 변환**이 아니라
**기준 선택**이다. 저장되는 값은 언제나 비율 하나뿐이고 그것을 다른 축으로 옮기지
않는다.

닫힌 6단 사다리. 인덱스는 `0`부터 `5`까지.

**이 여섯 값은 `core/worldstate`가 상수로 갖고 있는 값과 같다**
(`AxisBody.SCALE_RUNGS`). 이 표는 그 상수의 설명이고, 그 상수가 **판정을 하는 쪽**이다.
여기에 없는 수는 이 축이 받아들이지 않는다. §2.2·§4·§7이 그 판정의 근거다.

**이 사다리는 양방향이다.** `body.scale`은 이 6개 값 중 하나로 되돌아갈 수 있다.
`ROUND_PLAN.md` §11.1b(2026-09-26 사용자 확정). 이 문서는 값의 집합과 순서를
정할 뿐 이동 방향을 정하지 않는다. 이동·가격·되돌림은 `04_TRANSITIONS.md` §2·§4·§5가
정본이다.

| 인덱스 | rung | 값 | 직전 rung 대비 | 몸의 뜻 | 장소의 뜻 |
|---:|---|---:|---:|---|---|
| 0 | `speck` | `0.05` | — | 손톱만하다. 벽 한 줄눈 안에 들어간다. | 석회 줄눈, 바닥 틈, 서랍 안 |
| 1 | `hand` | `0.12` | ×2.40 | 손바닥만 하다. 문을 밀 수 있다. | 열쇠구멍, 배관구, 낮은 아치 |
| 2 | `doll` | `0.28` | ×2.33 | 어린아이 크기. 문을 걷어찬다. | 문짝, 의자, 창틀 |
| 3 | `common` | `0.65` | ×2.32 | 보통 성인 크기. 대다수 구조가 이 크기를 전제한다. | 복도, 계단, 방 |
| 4 | `tall` | `1.50` | ×2.31 | 평균보다 반 이상 크다. 문을 넘어다본다. | 홀, 현관, 가로수 |
| 5 | `colossal` | `3.60` | ×2.40 | 집을 넘는다. 도시 한 블록이 손에 잡힌다. | 거리, 광장, 기둥 |

전체 스팬은 **72배**다. 중간 rung이 없다. 6개보다 많게 만들지 않는 이유는 §5에 있다.

### 1.1 rung은 이름으로만 authored 한다

author는 숫자를 쓰지 않는다. `ladder.json`의 `"rungs": ["speck","hand","doll","common","tall","colossal"]`
순서가 곧 인덱스다. authored 숫자를 요구하는 키(`scale_min`, `scale_max`, `target_rung`)
는 전부 **로더가 이 표에서 파생**한다. 따라서 `scale_min: 0.18` 같은 손으로 쓴 오차는
구조적으로 불가능하다. `05_AUTHORED_FORMAT.md` §3.1.

---

## 2. Band 경계

band 경계는 인접 rung 값의 **기하평균**에서 3자리로 반올림해 파생한다. 임의 수가
아니다.

| 경계 인덱스 | 파생식 | 계산값 | 확정값 |
|---:|---|---:|---:|
| 0 | √(0.05 × 0.12) | 0.077459… | **`0.077`** |
| 1 | √(0.12 × 0.28) | 0.183303… | **`0.183`** |
| 2 | √(0.28 × 0.65) | 0.426508… | **`0.427`** |
| 3 | √(0.65 × 1.50) | 0.987421… | **`0.987`** |
| 4 | √(1.50 × 3.60) | 2.323790… | **`2.324`** |

확정 경계는 실제 기하평균보다 최대 `+0.0005` 크다. 이 반올림 오차는 rung 간 비율
(최소 2.3077)보다 세 orders of magnitude 작으므로 어떤 판정도 뒤집지 않는다.

### 2.1 여섯 개의 band

| band | `scale_min` | `scale_max` | 인덱스 | rung 값 |
|---|---:|---:|---:|---:|
| `speck` | `0.0` | `0.077` | 0 | 0.05 |
| `hand` | `0.077` | `0.183` | 1 | 0.12 |
| `doll` | `0.183` | `0.427` | 2 | 0.28 |
| `common` | `0.427` | `0.987` | 3 | 0.65 |
| `tall` | `0.987` | `2.324` | 4 | 1.50 |
| `colossal` | `2.324` | `99.0` | 5 | 3.60 |

- `speck`의 하한 `0.0`과 `colossal`의 상한 `99.0`은 열린 끝을 표현한다. `0.0`은
  §4-K1 때문에 어떤 몸도 가질 수 없고, `99.0`은 `colossal`의 27.5배로 그 근처에
  authored rung이 없다. 둘 다 유한해야 한다. 스토어는 `Inf`를 거부하므로 무한대를
  쓸 수 없다. **이 두 끝값도 `body.scale`으로 쓸 수 없다.** `0.0`과 `99.0`은
  rung이 아니므로 스토어가 `scale_not_rung`으로 거절한다. 이 표는 **장소가 파생하는
  구간의 끝**이지 저장 가능한 값이 아니다.
- **경계값은 양쪽 band에 동시에 속한다.** `0.183`은 `hand`의 `scale_max`와 `doll`의
  `scale_min`에 모두 걸린다. `AxisBody._unmet_for()`는 `float(v) < float(min)`일 때만
  `scale_below_min`을 내므로, 경계에서 `scale_below_min`도 `scale_above_max`도 나오지
  않는다. **이건 버그가 아니라 의도다.** 양쪽 band에 동시에 성립하는 것이 옳다.
  스토어에 특수 분기가 필요 없으므로 코드도 없다. `06` T1이 이 경계 행동을 단언한다.

### 2.2 band와 저장되는 값은 다르다 — 그리고 그 차이는 스토어가 지킨다

band는 **선택용**이다. 저장되는 값은 band가 아니다. **저장되는 값은 §1의 여섯 rung
중 하나뿐이고, 그 외의 수는 저장되지 않는다.** 몸이 `hand` band에 속한다는 것은
`hand` band 안에 그 몸이 있다는 뜻이지, 그 band 안의 아무 값이나 그 몸의 값이 될 수
 있다는 뜻이 **아니다**.

이 문서의 이전 판은 여기서 "`hand`의 rung 값은 `0.12`이지만 `0.13`도 유효하고
`0.12`로 덮어쓰이지 않는다"고 적었다. **그것은 거짓이고 지금은 불가능하다.**
`0.13`은 유한수이면서 여섯 rung의 어느 것도 아니므로 스토어가 `scale_not_rung`으로
거절한다. 저장되는 값도, `to_dictionary()`에 남는 값도, `module_count`에 들어가는 값도
없다. **반올림도 클램프도 없다.** `0.13`은 `0.12`가 되지 않고, `0.9`는 `common`
(0.65)이 되지 않고, `1.49`는 `tall`(1.50)이 되지 않는다. `DESIGN_DECISION.md` §2.1.2가
"가장 가까운 값으로 눌러 맞추지 않는다"라고 적은 것이 규칙이고, 그것이 구현이다.

**두 가지 규칙이 같은 규칙의 두 면이다.** 정규화 금지(`DESIGN_DECISION.md` §4)는
"이미 있는 값을 움직이지 말라"고 하고, 닫힌 6단 사다리(§2.1.2)는 "이 축이 받아들이는
값은 이 여섯 개뿐이냐"고 묻는다. 거절된 값은 **저장되지 않으므로** 정규화가 아니다.
정규화가 되려면 저장된 값이 한 비트라도 움직여야 하는데, 그 일은 어느 방향으로도
없다. `core/worldstate/CONTRACT.md`가 "A closed set of legal values is not a
normalisation"이라고 적은 것이 이 구분을 코드로 한 것이다.

**이제 두 질문이 실제로 갈라지는 곳은 세 Kit의 읽기다.** 몸이 가질 수 있는 값은
여섯 개이므로 `module_count`는 **여섯 개의 점**에서만 정의된다. 그런데
`03_MISMATCH_VISUALS.md` §2.2와 `02_PLACE_REQUIREMENTS.md` §1.1은 `body.scale`이
rung 사이의 연속값일 때의 `q`를 근거로 문서를 쓰고 있다. **그 선행 조건은 이제 성립하지
않는다.** 그 두 파일은 `docs/scale_collapse/**`의 소유자(W1c)가 다시 봐야 하며,
`07` Q20에 정확한 불일치를 적었다. 이 사양은 두 파일에 쓰지 않았다.

**없음은 여전히 없음이다.** rung을 한 번도 쓰지 않은 몸은 `scale`을 가지지 않는다.
`has_scale()`은 false이고 `get_scale()`은 `null`이고 `to_dictionary()`에 `scale` 키가
없다. 그 상태에서 크기를 요구하는 장소는 `scale_absent`로 미충족이 된다. **어떤 rung도
기본값이 아니다.** 거절도 기본값을 남기지 않는다 — `1.0`을 거절한 직후에도
`has_scale()`은 false다.

---

## 3. 두 개의 다른 판정

이 사양은 band와 `module_count`를 **두 가지 서로 다른 질문에** 쓴다. 섞으면 안 된다.

| | **band** (§2.1) | **반복 수** `module_count` (`03` §2) |
|---|---|---|
| 질문 | 이 장소가 이 몸을 **필요로 하는가** | 이 몸은 이 구조에 **얼마나 어울리는가** |
| 입력 | `body.scale` | `body.scale` |
| 출력 | 불연속 6구간 | 연속 비율 |
| 쓰임 | 그래프에 어떤 접근로를 instanciate할지 | 카메라·형상·소리·자기 실루엣 |
| 어긋나면 | 다른 접근로가 열린다 | 화면이 달라진다 |
| 불연속인가 | **예** (경계 5개에서 불연속) | **아니오** (전 영역 연속) |

`module_count`는 밴드 경계에서 아무것도 바뀌지 않는다. 밴드는 routing용이고
`module_count`는 표현용이다. **경계값은 저장 가능한 몸의 값이 아니다** — 여섯 rung의
어느 것도 `0.427`이 아니므로 그 경계에 서는 몸은 없다. 경계는 **장소가 파생하는 구간의
끝**이지 `body` 축이 받아들이는 값이 아니다. 그러므로 이 절의 대조는 **두 표의 입력
규칙이 다르다는 사실**에 대한 것이지, 경계값인 몸이 존재한다는 말은 아니다.

`module_count`가 연속인 것은 여전히 사실이다. `q = 1`을 포함한 모든 양의 `q`에 대해
정의되고 정의되어 있다(§5.2의 연속 실수 대안 기각 사유와 같은 논리). 다만 그 정의
전체에 걸리는 값은 이제 **여섯 점**이다. `03` §2가 `q`의 정의역을 어디까지 두는지는
`07` Q20이 미결로 남긴다.

---

## 4. 금지되는 값

| ID | 금지 | 이유 | 판정 위치 |
|---|---|---|---|
| **K1** | `0` 이하 | 0 높이의 몸은 비율의 분모가 0이다. 어디에도 맞을 수 없다. | **`core/worldstate`** (`AxisBody.SCALE_RUNGS` 에 `0`이 없다. 유한한 `0` 이하도 `scale_not_rung`으로 거절) |
| **K2** | `NaN`, `Inf` | 스토어가 이미 `value_not_finite`로 거부한다. 재확인만 한다. | `core/worldstate` (기존) |
| **K3** | rung 값이 아닌 수를 **authored 트리거**가 쓰기 | rung이 아닌 값은 되돌릴 rung이 없다. rung 그래프가 정의되지 않는다. | **`core/worldstate`** (스토어가 `scale_not_rung`으로 먼저 거절한다) + `tests/core/test_scale_rung_graph.gd` (그래프 자체의 성질) |
| **K4** | rung 이름이 아닌 것을 **authored 장소**가 `band`로 쓰기 | `ladder.json`에 없는 이름. 로더가 `scale_band_not_in_table`로 거부한다. | 각 Kit 로더 |
| **K5** | `scale_min` 또는 `scale_max` **단독**으로 authored 하기 | 열린 반구간("X 이상이면 무엇이든 통과")은 권한 조건으로degenerates한다. band는 항상 두 키를 함께 낸다. | `05` §3.2 로더 |
| **K6** | `1.0`을 `body.scale`에 쓰기 (rung으로 쓰기) | 1.0을 rung으로 두면 그 값이 "예전 크기"로 읽힌다. 그러면 이 세계에 **정상 크기가 존재한다**는 belief가 생긴다. 그 belief는 이 세계관의 유일한 반대편이다. 1.0은 rung이 될 수 없다. §5.2 | **`core/worldstate`** — `AxisBody.SCALE_RUNG_FORBIDDEN = [1.0]`, 사유 `scale_rung_forbidden`. `float`과 `int` 모두. **`1.0`이 어떤 Kit 로더의 사다리에도 없다는 것을 검사하는 것이 아니다.** |

**K1, K3, K6의 판정 위치가 2026-09-26에 바뀌었다.** 이전 판은 이 셋을 "각 Kit 로더"
와 `tests/core/test_scale_ladder_shared.gd`에 두었다. 그 위치들은 사다리에 없는 값을
**그냥 통과시켰다.** 지금 세 금지 모두 스토어에서 먼저 거절된다. §7.1이 그 이유를
근거로 적는다. K 번호는 세 대 모두 유지했다 — 다른 문서가 이 번호를 인용한다.

K6에 대해 분명히 한다. 사다리 값 중 `tall`의 `1.50`과 `colossal`의 `3.60`은
1.0보다 크다. 그렇다면 1.0은 "rung 사이의 값"이고, 겉보기에는 "예전 크기"가 될 수
있어 보인다. 그러나 그건 서로 다른 두 세계관이다.

- **채택:** 1.0은 rung이 아니다. 시작 몸은 rung 0 `speck`(0.05)이고 거기서
  6개 값 안에서 **위아래로** 간다. 되돌아오는 경로가 있다(`04_TRANSITIONS.md` §5).
- **기각한 대안:** `1.0`을 rung으로 두고 시작을 그 값에 두는 것. 이 경우 플레이어는
  자신을 "원래 모습"으로 되찾는 목표로 읽게 되고, `1.0`이 붕괴 이전 세계의 기준이라는
  서사가 생긴다. 붕괴한 세계에 기준이 있다는 것은 그 서사의 반대다.
- **가역이 이 주장을 더 세게 만든다 (2026-09-26).** 되돌림이 없을 때 `1.0`은
  "도달할 수 없는 값"이었다. 지금은 **도달 가능한 값 중 하나가 된다.** 1.0이 rung이면
  이 세계의 모든 몸이 돌아갈 집을 갖게 되고, 그 집이 정상 크기라고 선언된다.
  어느 rung이 "집"인지 고를 수 있는 이 사다리에는 그런 rung이 없다.
- **1.0이 실제로 나타나면 어떻게 되는가 (2026-09-26 정정).** 이전 판은 "Kit이
  `body.scale = 1.0`을 쓰면 스토어는 그대로 `1.0`을 저장한다. **정직한 실패다**"
  라고 적었다. **이것은 틀렸다.** 지금 구현은 `1.0`을 `scale_rung_forbidden`으로
  거절한다. 저장되는 값은 없고, `to_dictionary()`는 `{}`로 남고, 그 뒤에 쓴 다른 rung은
  그대로 살아 있다. 거절 사유가 `scale_not_rung`과 다른 이름을 갖는 이유도 여기에
  있다: "이 사다리에는 정상 크기가 없다"는 명제는 "그 값이 사다리 위에 없다"는
  명제와 다른 문장이다. `docs/world/12_SCALE_RULES.md` §1.2와 `09_GLOSSARY.md` 제2부가
  이 서사를 정본으로 삼는다.

---

## 5. 왜 6단이고 왜 72배인가

### 5.1 6단인 이유

- rung이 하나 추가될 때마다 3 Kit × 모든 장소의 접근로 authoring 비용이 늘어난다.
  장소당 최대 3 rung(S-INV-6)만 허용하므로, 사다리가 길수록 authoring은 선형으로,
  검증은 사다리 길이의 **제곱**으로 늘어난다(모든 rung 쌍의 band 경계 조합).
- 6단은 3 Kit이 각각 **3개 rung씩** 나눠 가져갈 수 있는 최소 크기다. Kit A가
  0~2, Kit B가 1~3, Kit C가 2~5를 가져가는 식의 분할이 가능하다.
- 각 Kit 계획서가 **서로 다른 3개 rung**을 실제로 방문하면 그 Kit의 Reference Game가
  10분을 채우는 근거가 약해진다. rung 방문은 이동이 아니라 사건이어야 한다.
- **되돌림이 생겼으므로 "방문 3회"가 아니라 "서로 다른 rung 3개"가 기준이다.**
  같은 rung으로 몇 번 왕복하더라도 그것은 1개의 rung을 방문한 것이다. 이전 판에서는
  재방문이 불가능했으므로 두 기준이 같았다. 이제 다르다. `06` P8이 이 구분을 쓴다.

### 5.2 72배 스팬인 이유

72배는 **같은 장소 안에서 두 크기를 동시에 보여 주기에 충분한 최소 비율**이다.
`05_AUTHORED_FORMAT.md` §4 예제 2에서 `hand`(모듈 34.9 px)와 `doll`(모듈 87.3 px)만으로
2.50배를 얻고, `speck`와 `colossal`을 같은 장소에 두면 `target_body_px`의 authoring
범위(24.0~420.0)와 합쳐 17.5배를 더 얻어 **총 43.8배**가 된다. 72배 사다리 스팬이
필요 없었다는 뜻이 아니라, 스팬은 **월드의 물리적 크기 다양성**이고 authored
`target_body_px` 다양성이 그 발현이라는 점을 구분하기 위한 것이다.

거부한 대안:

| 대안 | 왜 거부 |
|---|---|
| 연속 `float` (예: 임의 실수) | `03` §2의 band 경계와 `requires_body`의 `scale_min`/`scale_max`가 경계선처럼 되어 버린다. 경계가 아니면 routing 판정이 연속 함수가 되어 "이 장소를 instanciate할까"가 미분값 문제가 된다. 요구조건은 경계선이어야 한다. **2026-09-26 보강:** 구현도 이 대안을 택했다. `AxisBody.SCALE_RUNGS`가 유한한 닫힌 집합이고, 집합 밖의 유한값은 `scale_not_rung`으로 거절된다. `1.0`만 사유가 다르다(K6). |
| 4단 (0.05, 0.28, 1.50, 8.60) | 각 Kit이 방문할 rung이 2개 이하가 된다. 10분 Reference Game에 사건이 부족하다. |
| 8단 (0.02 … 12.0) | 검증이 사다리 길이의 제곱으로 늘어난다. authoring 비용 대다수 필요 없음. Kit 3개가 방문하는 rung은 여전히 3~4개다. |
| rung 값에 비례하는 단위(`gills` 같은 실제 생물 단위) | `worldstate/CONTRACT.md`가 "단위 변환 금지"를 스토어가 다룰 수 없는 영역으로 명시한다. 실제 단위를 쓰면 Kit마다 그 단위를 다른 축으로 옮기게 되고, `PROJECT_DECISIONS.md` §14가 금지한 그 정규화가 된다. |

**이 표의 거부는 이제 문서 논증이 아니라 구현이 이미 정한 결과다.** rung 수를 바꾸려면
`AxisBody.SCALE_RUNGS`를 고쳐야 하고, 그러면 `core/worldstate/tests/`의 사다리 픽스처가
통째로 다시 써져야 한다. 그건 이 사양의 결정이 아니라 W0 승인의 코드 변경이다.

---

## 6. `scale_min`이 임계값 게이트가 아닌 이유

가장 먼저 나오는 반론이므로 여기서 닫는다. `scale_min`은 숫자 조건이고
`00_CONSTITUTION.md` 불변식 15는 숫자로 통과 조건을 만드는 것을 금지한다. 구분이
있다.

| | 카르마식 누적 게이트 (금지) | `scale_min` (허용) |
|---|---|---|
| 값의 성격 | 시간이 지나면 늘어나는 **누적값** | 몸의 **치수**. 이벤트로 1회 바뀐다 |
| 되돌릴 수 있나 | 안 된다. 가져간 것은 남는다 | **된다.** `04` §5. `wounds`가 남지만 `scale`은 돌아온다 |
| 무엇이 통과를 바꾸나 | 전에 한 선택 | **현재** 몸. 만족해도 고정되지 않는다 |
| 다른 축으로 옮기나 | 통상 옮긴다 (점수 → 등급) | 못 옮긴다. Kit이 자기 물리 규칙에서 해석할 뿐 (§2.2) |
| 정본 근거 | `worldstate/DESIGN_DECISION.md` §2.1 요약값 금지, §4 | `DESIGN_DECISION.md` §2.1 "크기는 상수가 아니라 값", §2.3 "권한 게이트가 아니라 능력 조건" |

정본이 이미 판정했다. `AxisBody.REQ_SCALE_MIN`은 동결 상수이고
`AxisBody.DERIVED_KEYS`에 요약값이 없다. `scale`은 요약값이 아니라 **관측된 사실**의
하나다. `AxisBody`는 `body.scale`을 `facts` 아래가 아니라 **전용 필드**로 가진다. 그
자체가 이 프로젝트가 그것을 누적값이 아니라고 판단했다는 증거다.

`NOT_CAPABILITY_KEYS`에 `scale`이 없는 것도 확인했다. 목록은 `karma, favor, favour,
reputation, trust, standing, title, score, level, rank, tier, grade, deaths, kills,
debt, price, toll, progress, completions, access, clearance`다. `scale`은 없다.
`scale_min`은 `REQUIREMENT_KEYS`에 명시적으로 들어 있다.

**스토어도 같은 구분을 지킨다 (2026-09-26).** `AxisBody`는 이 다섯 capability 키만
`requires_body`로 받고, 누적값·권한 계열 이름(`karma`, `level`, `clearance`, `deaths` …)
은 `requires_body_not_capability`로 거절한다. `test_body_classes.gd`가
`karma / karma_min / progress / level / deaths / clearance` 여섯 개를 열거해 단언한다.
**이 승인은 가변 능력을 통과 조건으로 쓸 수 있다는 것이지 누적값이 될 수 있다는
말이 아니다.** 현재값 판정이지 누적인 정산이 아니다.

### 6.1 `scale`이 능력 축이고 `wounds`가 진행 축인 이유

| | `body.scale` | `body.wounds` |
|---|---|---|
| 부류 | **가변 능력** | **확정 사실** |
| 되돌아오나 | **예.** 6개 rung 값 중 하나로 | **아니오** |
| 전환 비용을 남기나 | 안 된다. | **예.** `04` §4. **단 합이 아니라 최댓값으로 병합된다** |
| 그 비용이 쌓이는가 | — | **안 된다.** 동일 정체는 1개로 병합되고 총량은 `0.68`에서 유계다. `04` §4.2, §4.7 |
| 통과 조건이 되나 | 되나. **현재값** 판정 | 되나. `has_wound`. `severity`는 안 됨 |
| 다른 쪽을 열까 | `wounds`를 요구하는 장소를 통과할 순 없다. `wounds`는 rung을 열지 않는다 | `scale`을 요구하는 장소를 통과할 순 없다 |
| 다른 쪽을 고치나 | `wounds`를 지우지 않는다 | `scale`을 바꾸지 않는다 |

**두 부류는 서로의 진행 게이트가 아니다.** 이것이 `ROUND_PLAN.md` §11.1b의
"진행 축과 능력 축은 섞지 않는다"에 대한 이 사양의 답이다. `04` §0.1이 판정표다.

**이 표는 이제 문서가 아니라 코드가 지킨다.** `AxisBody.FIELD_CLASSES`가
`missing`·`wounds`를 `CLASS_PERMANENT_FACT`로, `scale`을 `CLASS_MUTABLE_CAPABILITY`로
분류하고, `AxisBody.field_class(key)`가 그 답을 돌려준다. 확정 사실을 지우려는 요청은
`body_fact_is_permanent`로 거절되고, `scale`은 몇 번을 오가도 그 값으로 돌아온다.
`test_body_classes.gd`의 `test_a_permanent_fact_cannot_be_cleared_or_reverted`와
`test_a_mutable_capability_can_be_changed_and_changed_back`가 그 양쪽을 단언한다.
**흠터 하나를 다시 재는 것은 새 사실이 아니므로 거절되지 않는다** — 상처의 정체성은
`part` + `kind`이고 `severity`와 `permanent`는 재측정 가능한 사실의 속성이다.

**그래서 통행료의 병합은 스토어가 아니라 Kit의 규약으로 정본을 갖는다.**
`AxisBody._records_same_wound()`도 정체를 `part`+`kind`로 판정하고, 재측정을
거절하지 않는다. 따라서:

- **사라짐은 스토어가 막는다.** 이미 기록된 정체를 담지 않는 `wounds` 배열은
  `body_fact_is_permanent`로 거절된다. `04` §4.9.
- **성장은 Kit의 병합 규칙이 막는다.** `severity`를 **더하는** 배열은 스토어가
  거절하지 않는다. 스토어에 새 refusal를 붙이지 않고(`S-INV-2`) `04` §4.2의
  `max` 병합을 세 Kit이 공유 helper 하나로 쓴다.
- **`0.68`이라는 상한은 스토어가 강제하지 않는다.** 스토어에 `severity` 범위
  판정이 없다. 상한은 규약이 만든다. `06` T4가 그 규약을 단언한다.

`facts`는 **어느 부류에도 들어가지 않는다.** 스토어는 그것을 `CLASS_UNCLASSED`로
분류하고 내용을 다투지 않는다. `{"facts": {"scale": 0.13}}`이 지금도 통과한다는
사실은 §2.2의 사다리 강제와 **두 번째 크기 통로**를 의미한다. 그것을 스토어에서 막을지
Kit 계획서에서 금지할지는 `core/worldstate/DESIGN_DECISION.md` §8이 아직 미결로 남긴
두 번째 구멍이고, 이 사양의 `07` Q21에도 같은 항목이 있다. **그것은 종결된 것으로
쓰지 않는다.**

---

## 7. 이 사양이 `core/worldstate`에 요구하는 것

**새 요구는 0개다.** 이 사양이 쓰는 스토어 API는 전부 이미 존재하고, **이 사양이
요구하는 사다리 강제와 부류 판정도 스토어가 이미 하고 있다.** 이 사양의 요구가 아니라
스토어의 계약이다. 이전 판이 이 절을 "이 사양이 `core/worldstate`에 요구하는 것:
**없다**"로 끝내고 판정 위치를 다른 곳으로 넘겼던 것이 두 에이전트가 서로 다르게
읽게 만든 원인이다. **판정 위치는 스토어다** (§7.1).

| 필요한 것 | 쓰는 API | 존재 여부 |
|---|---|---|
| scale 읽기 | `AxisBody.get_scale()`, `has_scale()` | 있음 |
| scale 쓰기 | `request_mutation(AXIS_BODY, {"scale": 0.12}, requester)` | 있음. **사다리 값만 받는다** |
| **사다리 강제** | `AxisBody.SCALE_RUNGS`, `SCALE_RUNG_FORBIDDEN`. 사유 `scale_not_rung` / `scale_rung_forbidden` | **있음.** 스토어가 판정한다 |
| **실패 없이 미리 보기** | `AxisBody.check_mutation(patch)` | **있음.** `apply`와 같은 사유를 돌려주고 아무것도 commit하지 않는다. `value`를 담지 않는다 |
| 통행료 쓰기 | `request_mutation(AXIS_BODY, {"wounds": merge_max(get_wounds(), toll)}, requester)` | 있음. **병합은 Kit 몫**(§6.1) |
| 요구조건 판정 | `AxisBody.satisfies(requirement)` | 있음. `scale`이 없으면 `scale_absent` |
| 요구조건 검증 | `AxisBody.validate_requirement()` | 있음. 권한 계열 이름은 `requires_body_not_capability` |
| 요구조건 가져오기 | `AxisPlace.get_requires_body()` | 있음 |
| 장소 요구조건 만족 여부 | `WorldState.body_satisfies(place_id)` | 있음 |
| 상처 판정 | `AxisBody.has_wound(part, kind, permanent)` | 있음 |
| 부재 판정 | `AxisBody.has_missing_part(part)` | 있음 |
| rung 이름 조회 | **없다** — Kit이 `ladder.json`을 읽어 `0.12 → "hand"`를 스스로 찾는다 | `07` Q4 |
| **scale의 세이브/로드 복원** | `to_dictionary()` → `load_snapshot()` | **있음.** 사다리 밖 값이 든 스냅샷은 같은 사유로 실패하고 아무것도 덮어쓰지 않는다 |
| **두 부류(확정 사실 / 가변 능력) 판정** | `AxisBody.FIELD_CLASSES`, `CLASS_PERMANENT_FACT` / `CLASS_MUTABLE_CAPABILITY` / `CLASS_UNCLASSED`, `field_class(key)` | **있음.** `07` Q13 종결 |

**통행료의 상처가 `WOUND_FIELDS` 4개(`part, kind, severity, permanent`) 정확히
맞는다는 점이 중요하다.** 스토어가 `wound_malformed`로 검증하고 키가 하나라도
여분이면 거부한다. 그러므로 통행료를 Kit이 조립할 때 실수할 수 없고, 실수하면
정직한 실패가 난다.

**스토어는 이 축의 상한을 강제하지 않는다.** `_check_wound()`는 `severity`에
`_is_number()`만 요구하고 범위를 보지 않는다. `CONTRACT.md`도 "A wound `severity`
of 1.0 … four different questions"라고 명시한다. 따라서 **`0.34`라는 값과
`0.68`이라는 유계는 모두 `04` §4.2~§4.7의 규약이 만든 것이고 스토어가 지키는
것이 아니다.** 지키는 것은 **사라짐 한 가지**뿐이다(`body_fact_is_permanent`).

**`scale`의 세이브/로드 복원에 새 API가 필요 없다.** `CONTRACT.md`는
`FIELD_SCALE: number` 하나를 전유 필드로 갖고 `to_json()`/`load_json()`이 그
토큰을 그대로 되읽는다. "되돌릴 수 있다는 것"과 "저장하지 않아도 된다는 것"은
다른 문제이며 후자는 거짓이다. 현재 크기는 저장되고 복원된다. `06` T2-13이 단언하고
`core/worldstate/tests/test_body_classes.gd`가 구현한다.

**확정 사실과 가변 능력을 스토어가 구분한다는 것은 저장되는 표식이 0개라는 뜻이다.**
`FIELD_CLASSES`는 코드 상수이지 저장 필드가 아니다. `AxisBody.FIELDS`는 여전히 네 개
다. 따라서 "부류 판정을 넣으면 축이 늘어난다"는 논거(`07` Q13의 이전 판)는 성립하지
않는다. **부류는 저장되지 않고 판정된다.**

남는 한 줄은 Kit이 직접 해결하거나 사양이 정본을 정한다. 스토어에 rung **이름**을
저장할 필요가 없다. 값이 진실이고 이름은 사다리 표가 갖는 파생 라벨이기 때문이다.
`body.facts["rung"]` 같은 것은 금지한다(중복 상태).

### 7.1 판정 위치가 스토어인 이유

이 사양은 2026-09-26 이전에 "이 사양이 `core/worldstate`에 요구하는 것: 없다"고
적었다. 그 문장은 세 가지를 한꺼번에 틀리게 했다. **그 요구는 이미 구현되어 있고,
그것은 스토어가 하는 일이다.**

1. **스토어는 세계 묶음 전체의 중재 지점이다.** `core/worldstate`는 세 Kit의 저장을
   소유하며, 모듈은 축을 **읽고** 쓰기는 **요청**한다. 판정은 그 스토어가 한다.
   저장 계약을 한 곳에 두지 않으면 세 Kit이 각각 자기 사다리를 갖게 되고, 그때는
   "3개 게임"이 된다. `PROJECT_DECISIONS.md` §14가 판정한 그 문제가 그대로 돌아온다.
2. **세계 불변식은 소유 Kit이 로드되지 않아도 성립해야 한다.** `DESIGN_DECISION.md`
   §3의 인계 규칙이 그 문장을 그대로 쓴다: "축 소유 Kit이 **로드되어 있지 않아도**
   판정된다." `body` 축의 소유자는 `sideview_ecosystem` 하나뿐이다. 그 Kit 하나만
   사다리를 enforcement하면, 그 Kit을 내리고 다른 Kit으로 들어가는 세션에서
   `body.scale`에 임의의 실수가 저장된다. **한 Kit만 지키는 규칙은 불변식이 아니다.**
   그것은 그 Kit의 구현 디테일이다.
3. **거절 사유는 저자에게 돌아가는 값이다.** `scale_not_rung`과
   `scale_rung_forbidden`은 Kit 개발자에게 **무엇을 고쳐야 하는지**를 말하는 문자열이다.
   `check_mutation()`은 그 사유를 commit 없이 돌려준다. 사다리를 로더마다 복제하면
   그 문자열이 세 벌이고, 그중 하나가 조용히 다른 문장으로 남는다.

**그래서 `1.0`과 사다리 밖 값의 거절은 스토어에서 나오고, `module_count`의 정의는
Kit에서 나온다.** 그 구분은 저장된 값과 파생된 값의 구분이다. 스토어는 저장된 값의
영역만 지킨다. `03` §2가 파생하는 반복 수는 그 값들을 **읽어서** 만든다.

`DESIGN_DECISION.md` §8은 이 항목("사다리 판정의 위치")을 미결로 남겼다.
**이 판에서 종결된다: 스토어가 정본이다.** 그 문서의 첫 줄이
"여기서는 스토어가 사다리 밖의 `scale`을 거절한다"라고 이미 적고 있고, §2.1.2가
"이 사양의 판정 위치는 여기와 다르며, 그 충돌은 §8에 남긴다"라고 이 문서를 지목했다.
`core/worldstate/tests/test_body_classes.gd`가 그 쪽을 단언한다. **모순은
`docs/scale_collapse/01_SCALE_ALGEBRA.md`에 있었다.** 그 문서를 고치는 것이 이 판의
일이다.

---

## 8. 수치 요약

```
RUNGS        0:speck=0.05  1:hand=0.12  2:doll=0.28  3:common=0.65  4:tall=1.50  5:colossal=3.60
EDGES        0.077  0.183  0.427  0.987  2.324
BANDS        speck[0.0,0.077]  hand[0.077,0.183]  doll[0.183,0.427]
             common[0.427,0.987]  tall[0.987,2.324]  colossal[2.324,99.0]
SPAN         3.60 / 0.05 = 72.0
RUNG RATIO   2.4000  2.3333  2.3214  2.3077  2.4000   (min 2.3077, mean 2.3525)
MAX STEP     2 rung, 양방향 (04 §2)
REVERSIBLE   예.  6개 rung 값 중 어느 것으로든.  1.0 은 거절 (K6, scale_rung_forbidden)
ENFORCED BY  core/worldstate.  사다리 밖 유한값 → scale_not_rung.  1.0 → scale_rung_forbidden.
             스냅샷 로드도 같은 사유로 실패하고 아무것도 덮어쓰지 않는다.  절대로 snap/반올림/클램프 없음
OFF-LADDER   0.065 0.13 0.2 0.3 0.5 0.7 0.9 1.49 2.0 2.5 3.59 0.0 -1.0 199.7 → 전부 거절
TOLL         방향당 확정 사실 최대 1개.  동일 정체는 max 병합.  part "torso", permanent true
             kind compressed|stretched, severity 0.34 고정, steps·왕복 횟수와 무관
             기록 수 상한 2,  severity 합 상한 0.68.  04 §4.2, §4.7, §4.8
BANDS/PLACE  ≤ 3 adjacent (S-INV-6)
FIT_TARGET   2.75   (03 §2)
MATCHED      module_count ∈ [2.1, 3.4]   (정본.  q 창 [0.76364, 1.23636] 은 파생)
SEPARATION   1.76   (03 §8.1.  5 channel 모두 정확히 이 값)
STORE API    scale 복원: 있음.  부류 판정: 있음 (field_class / FIELD_CLASSES).
             dry run: 있음 (check_mutation).  둘 다 스토어가 정본 (§7.1, 07 Q13 종결)
```

**`OFF-LADDER` 줄은 사양이 아니라 구현이 단언한 목록이다.** `1.0`은 이 줄에 없다.
`1.0`은 `scale_not_rung`이 아니라 `scale_rung_forbidden`을 받기 때문에 따로 적었다.
이 목록의 어떤 값도 `0.12`나 `0.65`로 눌러 맞추지 않는다. 그 확인은
`core/worldstate/tests/test_body_classes.gd`의
`test_a_value_between_two_rungs_is_refused_and_never_snapped`와
`test_every_retired_float_is_now_refused_with_its_own_reason`가 한다.
