# 스케일 붕괴 (scale collapse) — 공통 시스템 사양

Owner **W1c** (이전 판은 W11). 단독 소유 경로
`docs/scale_collapse/**` + `docs/world/12_SCALE_RULES.md`.

> **2026-09-26 가역 판.** `ROUND_PLAN.md` §11.1b로 `body.scale`이 가역이 되었다.
> 이 폴더의 8개 파일과 `docs/world/12_SCALE_RULES.md`가 그 결정에 맞춰 **다시
> 썼다.** 무엇이 바뀌었는지는 각 파일 첫머리의 갱신 표에 있고, 이 사양 전체를
> 관통하는 변경 세 가지가 있다.
>
> 1. **되돌림이 생겼다.** `04_TRANSITIONS.md` §5, `06` T2-13~15, T8
> 2. **되돌림의 가격이 생겼다 — 통행료.** `04_TRANSITIONS.md` §4, `05` §5.1, `06` S-INV-5b
> 3. **`body` 축이 두 부류로 나뉘었다.** 확정 사실 / 가변 능력. `04` §0, `01` §6.1, `README` §0.1
>
> **2026-09-26 통행료 병합 판.** `ROUND_PLAN.md` §11.1d. **상수 조정이 아니라
> 병합 규칙이 정본이 되었다.** 동일 정체(`part`+`kind`)는 **합이 아니라 최댓값**으로
> 병합하고 그 결과는 **`0.68`에서 유계**다. `0.34`/`0.25` 논쟁과 기준선 `2.0`은
> **종결**(`07` Q14). 정본은 `04` §4.1~§4.9, 기계 증명은 `06` T4-14~17.

이 폴더는 **명령이 아니라 사양**이다. 여기 있는 수치와 규칙은 세 Kit이 동시에 코딩을
시작할 수 있도록 확정된 것이고, 구현은 각 Kit과 `core/worldstate`, `core/procedural`의
소유자가 한다. 이 폴더에 `.gd` 파일이 없다. Godot을 실행하지 않았고 화면을 확인하지도
않았다. 확인하지 않은 것을 확인했다고 쓰지 않는다.

---

## 0. 한 문단으로

이 세계는 크기를 잃었다. 붕괴는 하나뿐이며, 그것은 **몸의 크기와 장소의 크기가 서로
물러났다**는 것이다. 몸의 크기는 `core/worldstate`의 `body.scale`이라는 **사실 하나**로
저장되며, 그 값은 `0.05`에서 `3.60`까지의 닫힌 6단 사다리 위에서만 authored event가
쓸 수 있다. 장소는 저절로 요구하는 **능력 조건**을 `AxisPlace.requires_body`의
`scale_min` / `scale_max`로 선언하고, 그 조건은 권한이 아니라 **치수**다. 몸이 크기를
요구하는 장소를 방문하는 것은 언제나 가능하고, 플레이어는 그 장소에 저절로 열린 여러
진입로 중 자기 크기에 맞는 것을 눈으로 골라 통과한다. **어긋남은 글자로 말하지
않는다.** 몸과 구조물 사이의 반복 수, 접촉 자국이 몸 높이에 비해 어느 비율인지,
표면 입자가 몸의 획보다 굵은지, 걸음소리가 몇 옥타브 낮은지 — 이 다섯 개는 전부 같은
무차원 변수에서 나오고, 그 곡선은 **정확히 두 개**다(`∝ q` 하나와 `∝ 1/q` 하나).
참값 구간(`module_count ∈ [2.1, 3.4]`)과 어긋난 값 구간 사이에 **1.76배의 빈틈**이
있어서 숫자·게이지·라벨 없이 판별된다.

**크기 변경은 되돌아온다.** rung 그래프는 DAG가 아니라 **강연결**이고, 모든 rung에서
모든 rung으로 갈 수 있다. 되돌아오는 데 드는 비용은 **통행료** 하나뿐이다: 방향당
확정 사실(`body.wounds`에 남는 흉터) 최대 1개. **그 사실은 이동 거리와 왕복 횟수에
비례하지 않는다. 같은 정체는 최댓값으로 병합되고 총량은 `0.68`에서 유계다.**
되돌아온 몸은 숫자까지 이전과 정확히 같지만 **몸은 같지 않다.** 그래서 세계관 헌법
불변식 5의 "언제든 불완전하게 돌아온다"가 그대로 성립하고 **예외 규칙이 필요 없다.**

### 0.1 `body` 축의 두 부류 (이 폴더 전체가 이 구분을 쓰지 않으면 안 된다)

| 부류 | 정체 | 축 | 담는 필드 | 되돌아오나 |
|---|---|---|---|---|
| **확정 사실** | 잃은 부위, 흉터, 잃은 감각 | **진행 축** | `missing`, `wounds` | **안 된다** |
| **가변 능력** | 현재 크기 | **능력 축** | `scale` | **된다** |

**섞지 않는다.** 가변 능력은 진행 게이트가 될 수 없고, 확정 사실은 장비처럼 다루지
않는다. 통행료는 `wounds`에만 남고 `missing`에는 남지 않는다. `wounds`는 rung을
열어주지 않고 `scale`은 상처를 낫게 하지 않는다. `04_TRANSITIONS.md` §0.1이 판정표다.

**통행료는 존재하면서 유계여야 한다.** 어느 쪽도 빠지면 안 된다. 값이 없으면
능력 축이 침묵하고(`04` §4 서문), 값이 쌓이면 이 축이 세션 축이 된다
(`04` §4.2.3). 그래서 규칙은 **합이 아니라 최댓값**이고 총량 상한은 **`0.68`**이다.

### 0.2 이 사양은 물의 존재 여부에 무관하다

이 폴더는 **크기**의 사양이고 수체의 사양이 아니다. `body.scale`, band, `q`,
`module_count`, 통행료, rung 그래프 중 **어떤 것도 물이 있는지 없는지를 읽지
않는다.** 물이 있는 장소에도 이 규칙은 그대로 성립하고, 물이 없는 장소에도
그렇다. `ROUND_PLAN.md` §11.2는 물을 **금지하지 않는다** — 물이 그 장면의
**조건**이 되면 안 된다는 판정만 있다. 그 판정은
`docs/world/13_REFERENCE_EXCLUSIONS.md` §4.1이 정본이다. **스케일 사양에
"물 없음" 전제가 있는 곳이 있었다면 그 전제가 오류였다.** 2026-09-26 기준
이 폴더에서 그러한 전제는 0건이다.

---

## 1. 읽는 순서

| 순서 | 파일 | 무엇을 주는가 | 읽어야 하는 대상 |
|---:|---|---|---|
| 0 | 이 파일 | 불변식 목록과 소유권 | 전원 |
| 1 | [`01_SCALE_ALGEBRA.md`](./01_SCALE_ALGEBRA.md) | 6단 사다리 표, band 경계 5개, 금지 값, 두 부류의 분리, 몸과 장소에서의 물리적 뜻 | W7, W4, W5, W6, W0 |
| 2 | [`02_PLACE_REQUIREMENTS.md`](./02_PLACE_REQUIREMENTS.md) | `requires_body` 선언법, 미충족 시 실제로 일어나는 일, **잘못된 rung인 몸이 그 장소에서 무엇을 얻는가(관찰 3종)**, "게임이 거절한다"가 답이 될 수 없는 이유 | W7, W4, W5, W6 |
| 3 | [`03_MISMATCH_VISUALS.md`](./03_MISMATCH_VISUALS.md) | 반복 수의 법칙, 1.76배 분리 증명, **다섯 reader가 두 곡선으로 붕괴한다는 감사**, 카메라·인접 형상·자기 실루엣·소리, 무엇을 배우는가 | W2, W3, W4, W5, W6 |
| 4 | [`04_TRANSITIONS.md`](./04_TRANSITIONS.md) | **통행료(모든 rung 전환의 유일한 가격)와 그 최댓값 병합 규칙**, 되돌림의 정의와 왕복 산술, 강연결 rung 그래프, PVE 경유 애니메이션 | W2, W4, W5, W6, W7 |
| 5 | [`05_AUTHORED_FORMAT.md`](./05_AUTHORED_FORMAT.md) | 장소/접근로 JSON 스키마, 스케일 변경 트리거 JSON 스키마(**`cost` 키 없음, 병합 지정 키 없음**), 난이도 증가 worked example 4종 | W0, W4, W5, W6 |
| 6 | [`06_TESTS_AND_GATES.md`](./06_TESTS_AND_GATES.md) | 테스트 파일 경로, 각각이 단언하는 것, 정확한 명령, 텍스트 금지 게이트, **되돌림 게이트, 통행료 병합 게이트** | W0, W2, W7, W4, W5, W6 |
| 7 | [`07_OPEN_QUESTIONS.md`](./07_OPEN_QUESTIONS.md) | 확신하지 못한 결정, 권고안, 대안, 승인자. **Q10·Q14은 종결**, Q13~Q19가 가역 판에서 추가, Q24가 병합 판에서 추가 | W0, W1, W2, W3, W7 |

`03`과 `04`를 `05`보다 먼저 읽는다. JSON 스키마는 `03`의 비율 정의에서 나오고
**가격은 `04`에서만 나온다. 병합 규칙도 `04` §4.2에서만 나온다.**

---

## 2. 이 사양이 지고 있는 상위 문서

충돌 시 위가 아래를 이긴다.

| 순위 | 문서 | 인용하는 조항 |
|---:|---|---|
| 1 | `core/worldstate/CONTRACT.md` | 동결 API. "It will not normalise", "It will not compute a summary" |
| 2 | `core/worldstate/DESIGN_DECISION.md` | §2.1 `scale`는 그냥 값, §2.3 `requires_body`는 능력 조건, §4 정규화 금지 |
| 3 | `core/procedural/DESIGN_DECISION.md` | §0 정규 형상 axiom, §1.3 `chain`, §1.7 `grid`, §1.4 `timeline` 없음, §12-3 bake 판정 |
| 4 | `docs/research/round_2026_09_26/ROUND_PLAN.md` | §7 세 Kit의 서로 다른 축, §8 금지 목록, §11.1 스케일 붕괴 확정, **§11.1a 6단 사다리 확정**, **§11.1b scale 가역 + 두 부류 확정**, **§11.1d 통행료 = 최댓값 병합**, §11.2 레퍼런스 고유 형질 금지(**물은 무대가 될 수 있으나 조건이 되면 안 된다**), §11.3 플레이어 노출 텍스트 3종 |
| 5 | `docs/world/00_CONSTITUTION.md` | 불변식 3, 4, 5, 15, 16, 22, 24 |
| 6 | `docs/world/12_SCALE_RULES.md` | 세계 서사, rung별 인상, 인구와 구역. **수치 사다리는 없다.** §11.1a |
| 7 | `PROJECT_DECISIONS.md` | §14 몸 상태 정규화 금지 (200→199 기준 사례) |
| 8 | `CONTEXT.md` | 정규 형상, 절차 비주얼 엔진 |
| 9 | `docs/CODE_STYLE.md` | 경계, Authored Content, 저장, shared 추출 규칙 |
| 10 | `AGENTS.md` | 이미지 0개, 해상도 3종 검수, 자동 검증 순서 |

`docs/world/12_SCALE_RULES.md`는 이 사양과 **수치를 공유하지 않는다.** 그 파일은
rung **이름**만 쓰고 모든 값은 `01_SCALE_ALGEBRA.md`를 가리킨다. 그 파일이
숫자 사다리를 다시 쓰면 그것이 두 번째 정본이 된다. `06` T7-10이 그 상태를 잡는다.
**`12_SCALE_RULES.md`만 `docs/world/` 안에서 이 사양의 쓰기 소유를 가진다.**

### 2.1 이 폴더의 문장 규칙

> **이 폴더의 어떤 규칙도 "적절히", "게임답게", "레퍼런스 느낌으로"가 될 수 없다.
> 모든 규칙은 수치·경계·비율·조건문으로 적힌다. 그런 형태로 적을 수 없는 규칙은 아직
> 결정되지 않은 규칙이고 `07_OPEN_QUESTIONS.md`에 있어야 한다.**

이것은 `docs/world/00_CONSTITUTION.md` 불변식 22(명령문 없는 접촉)를 문서에도 적용한
것이다. 사양이 설명을 담는다면 그 설명은 나중에 플레이어가 읽게 될 문장이 된다.

---

## 3. 기계 강제 불변식 (S-INV)

각 항목에 `06_TESTS_AND_GATES.md`의 정확한 테스트 경로가 있다. 요구사항이 아니라
**완료 판정 목록**이다.

| ID | 불변식 | 근거 | 테스트 |
|---|---|---|---|
| **S-INV-1** | `body.scale`은 authored event만 쓴다. 항상 정확한 rung 값으로, 한 번에 최대 2 rung. 파생값·기본값·클램프·반올림 0개. | `worldstate/CONTRACT.md`, `DESIGN_DECISION.md` §4 | `core/worldstate/tests/test_scale_no_normalise.gd` |
| **S-INV-2** | 장소·간선·트리거 중 어떤 것도 진입을 거절하지 않는다. `satisfied == false`에서 거절로 가는 코드 경로 0개. | `00_CONSTITUTION.md` 불변식 4 | `core/worldstate/tests/test_scale_unmet_is_not_denial.gd` |
| **S-INV-3** | 도달 가능한 모든 장소와 모든 rung에 대해 그 rung으로 해결되는 authored 간선이 1개 이상 존재한다. | `00_CONSTITUTION.md` 불변식 3·17 | 각 Kit `test_scale_geometry.gd` |
| **S-INV-4** | `requires_body`는 접근로 band에서 파생되고, authored 형상의 기하 통과 가능성과 일치한다. 불일치는 콘텐츠 오류지 플레이어 refusal가 아니다. | `00_CONSTITUTION.md` 불변식 4 | 각 Kit `test_scale_geometry.gd` |
| **S-INV-5** | rung 그래프(정점 = rung, 간선 = authored trigger)는 **강연결**이다. 모든 rung에서 모든 rung으로 도달 가능하다. 자기 루프 0개. 이를 위한 저장 상태 0개. | `00_CONSTITUTION.md` 불변식 3, 5 / `ROUND_PLAN.md` §11.1b | `tests/core/test_scale_rung_graph.gd` |
| **S-INV-5b** | 모든 rung 전환은 **통행료**를 낸다. 통행료가 0인 전환은 `initial` 1개뿐이다. **동일 정체(`part`+`kind`)는 합이 아니라 최댓값으로 병합하며, 그러므로 방향당 기록은 최대 1개이고 스케일 시스템의 기록 수 상한은 2, `severity` 총량 상한은 `0.68`이다.** | `ROUND_PLAN.md` §11.1b, **§11.1d**, `04` §4, §4.2, §4.7 | `core/worldstate/tests/test_scale_no_accumulator.gd`(T4-14~17) + `tests/core/test_scale_rung_graph.gd`(T8-17~19) |
| **S-INV-6** | 한 장소는 최대 3개의 인접 rung만 포함한다 (min↔max Δ ≤ 2). **가역 판에서는 이것이 `q` 범위 보존이 아니라 편안함의 상한이기도 하다.** | `03` §11.1, `§3.2.1` | `tests/core/test_scale_rung_graph.gd` |
| **S-INV-7** | 어긋남 전달에 쓰이는 값은 전부 무차원 비율이다. 플레이어에게 도달하는 값 중 수치로 그려지는 것은 0개. | `ROUND_PLAN.md` §11.3, 불변식 22·24 | `tests/core/test_scale_text_free.gd` |
| **S-INV-8** | 스케일에 대한 누적 스칼라 0개. 카운터·합계·델타·레벨·티어·해금 목록 전부 0개. | `worldstate/CONTRACT.md`, 불변식 15·16 | `core/worldstate/tests/test_scale_no_accumulator.gd` |
| **S-INV-9** | 이미지 파일 0개. 스케일의 모든 시각은 `core/procedural` 스펙이다. | `ROUND_PLAN.md` §5 | `tests/core/test_no_binary_assets.gd` (W0 기존) |

---

## 4. 이 사양이 새 코드/데이터를 요구하는 것

`core/worldstate`의 동결 API는 **변경하지 않는다.** 이 사양이 쓰는 함수는 전부 이미
존재한다. 근거는 `07_OPEN_QUESTIONS.md` Q2에 쓴다.

새로 요청하는 것은 정확히 셋이다. 셋 다 승인 없이는 만들지 않는다.

| 요청 | 대상 | 내용 | 근거 |
|---|---|---|---|
| **R1** | `core/procedural/scale_fit.gd` (W2) | 순수 기하 도우미, 약 20줄. 서명 전문은 `03_MISMATCH_VISUALS.md` §9 | 사용처 15곳(3 Kit × 5 reader)이 동일 의미. `docs/CODE_STYLE.md`의 shared 추출 요건(두 실제 사용처에서 동일 의미·계약 확인)이 충족되므로 preemptive가 아니다 |
| **R1b** | `core/procedural/scale_toll.gd` (W2) | 통행료 상수 4개 **+ `TOLL_MERGE` 1개 + `merge_max` 연산 1개.** **R1과 별개 파일.** §아래 | `04` §4.1, §4.2.2. `Q16`, `Q24` |
| **R2** | `res://content/scale/ladder.json` (W0) | 공유 authored 사다리 표 6행. 데이터이지 코드가 아니다 | `body.scale`은 세계 값 하나이므로 band가 Kit마다 달라질 수 없다. 불변식 13 |
| **R3** | `res://content/places/<place_id>.json` (W0) | 공유 authored 장소 기록 + 접근로 목록 | `target_body_px`가 Kit마다 다르면 같은 구역에 세 크기가 생긴다. 불변식 13 위반 |

**R1b가 R1과 다른 파일인 이유.** `ProceduralScaleFit`는 계약을 `q: float → float`로
정하고 **무차원**이라고 명시한다. 통행료는 **방향**(`to < from`), **거리**(`steps`),
**몸**, 그리고 **이미 기록된 상처들**을 안다. `q`는 그 넷을 알 수 없다.
`severity: 0.34`는 무차원이 아니다. **기하는 크기를 모르고 비용은 크기를 안다.**
그리고 `merge_max`는 배열을 인자로 받는 **상태 의존** 함수이므로 순수 기하 도우미의
성질이 아니다. 그래서 `Q16-1`.

**R1b는 이제 상수 집이 아니라 규칙 집이다.** `max` 병합이 `sum`으로 되돌아가면
`0.68`이 무한이 되고 그때는 상수를 아무리 골라도 답이 없다. `06` T4-15가 연산을,
T8-19가 공유를 단언한다.

`plans/kits/06|07|08_*.md`는 다른 워커 소유다. 이 사양은 거기 쓰지 않고, 각 Kit
계획서가 이 폴더를 **인용**해야 한다.

---

## 5. 기준 장면

`place` = `loc.tea_stair` (다과 계단). 공유 접근로 2개.

| 접근로 | band | `target_body_px` | 파생 `module_px` | 성격 |
|---|---|---:|---:|---|
| `stair_keyhole` | `hand` (0.12) | 96.0 | 34.9 | 열쇠구멍. 창백한 석회 줄눈. |
| `stair_door` | `doll` (0.28) | 240.0 | 87.3 | 문짝. 거푸집 이음새가 보인다. |

- 파생 `requires_body` = `{scale_min: 0.077, scale_max: 0.427}` (두 band의 합집합).
- 같은 벽에 34.9 px짜리 석회와 87.3 px짜리 문짝이 나란히 있다. 비율 **2.50배**.
  이것이 "같은 문이 두 크기로 열린다"의 수치다.
- 몸이 `hand`라면 `stair_keyhole`에서 `module_count = 2.750`(통과). `stair_door`에서는
  `q = 0.12/0.28 = 0.4286` → `module_count = 1.179`. **몸이 문짝 하나보다 작다.**
  키홀만 열린다.
- 몸이 `doll`이면 반대. 두 창 중 하나만 열린다.
- 몸이 `common`(0.65)이면 `q = 2.321` → `module_count = 6.384`. **몸이 6개 창에 걸쳐
  있고 화면 프레임은 6.0개 폭이다.** `CAMERA_FRAME_MODULES = 6.0`이므로 몸이
  화면보다 크다. `03` §3.2. `body_satisfies()`는 `unmet: ["scale_above_max"]`를
  돌려주지만 그 값은 "이 기하를 인스턴스하지 말라"는 뜻이지 "이 장소를 막으라"는
  뜻이 아니다. `02_PLACE_REQUIREMENTS.md` §1.2.
- `common` 몸의 그래프에는 `tea_stair`로 가는 간선이 없다. 간선은 band별로 authored
  되므로 그렇다. 그리고 그 자리에 `common` band의 authored 간선이 열려 있고,
  **다른 곳으로 간다.** 게임은 "닫혔다"가 아니라 "저쪽이다"를 말로 하지 않는다.

### 5.1 이 장면에서의 왕복 (가역 판이 추가)

`common` 몸이 `tea_stair`의 두 접근로를 **둘 다 본다.** 하나는 6.38개, 하나는 0.50개.
`05` §4.4의 왕복 트리거 쌍(`loc.stair_landing`)에서 통행료를 내면 `doll`이 되고
`2.100`~`3.400` 안으로 내려와 `stair_door`가 열린다. **가게는 열리지 않는다.
몸이 그 크기로 왔을 뿐이다.** 되돌아가면 `compressed` 흔적이 하나 더 남고 `common`으로
돌아온다.

```
0.65 → 0.28   (1 rung 아래, torso/compressed 0.34 병합)   module_count 6.384 → 2.750
0.28 → 0.65   (1 rung 위,   torso/stretched  0.34 병합)   module_count 2.750 → 6.384
```

`scale`은 정확히 복원된다. `wounds`는 **2개**가 된다(이미 있으면 변하지 않는다).
**두 방향 흔적의 `severity` 합은 `0.68`이며 그 값이 이 축의 끝이다.** 이 왕복을
몇 번 반복해도 `0.68`이다. **`03` §6.1의 하강 도약이 귀가 확인이다.**

---

## 6. 소유권

| 경로 | 상태 |
|---|---|
| `docs/scale_collapse/**` | **내 단독 소유** |
| `docs/world/12_SCALE_RULES.md` | 이전 패스에서 단독 소유를 받았다 (W1에게서 인계, 2026-09-26). **통행료 병합 패스에서는 쓰지 않았다** |
| `docs/world/13_REFERENCE_EXCLUSIONS.md` | **통행료 병합 패스에서만** 쓰기 허용. 물 항목 하나. 그 밖의 `docs/world/**`는 읽기만 |
| `core/worldstate/**` | W7. **읽기만.** |
| `core/procedural/**` | W2. **읽기만.** |
| `res://content/**` | 없음. W0 승인 필요. `07` Q3 |
| `plans/kits/**` | W0 + Kit 소유. **읽기만.** |
| `docs/world/**` (그 외) | W1. **읽기만.** |
| `modules/**` `app/**` `tools/**` `tests/**` | 타 소유. **읽기만.** |

이 폴더 안의 산출물은 8개 markdown 파일이다. 이전 패스는 여기에
`docs/world/12_SCALE_RULES.md`를 더했다. **통행료 병합 패스는
`docs/scale_collapse/**` 8개 파일 전부와 `docs/world/13_REFERENCE_EXCLUSIONS.md`를
고쳤다.** `docs/world/12_SCALE_RULES.md`는 이 패스에서 손대지 않았다. 다른 파일을
쓰지 않았다. Godot을 실행하지 않았고 테스트를 돌리지 않았다.
