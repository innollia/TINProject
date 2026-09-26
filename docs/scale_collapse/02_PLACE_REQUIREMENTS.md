# 02 — 장소 요구조건 (place requirements)

장소가 요구하는 스케일이 `AxisPlace.requires_body`로 어떻게 선언되고, 몸이 그 요구를
만족하지 않을 때 **실제로 무엇이 일어나는지**.

읽기 전제: `01_SCALE_ALGEBRA.md` 전부, `core/worldstate/CONTRACT.md` 전부.

---

## 1. 선언은 파생이다

핵심 선언 하나:

> **`requires_body`는 authored가 아니다. 접근로(approach)의 band에서 파생된다.
> authored 진실은 접근로 목록이고, `requires_body`는 그 합의 선언문이다.**

이유는 `docs/world/00_CONSTITUTION.md` 불변식 4다. "진입 조건은 공간의 성질이다."
공간이 저절로 요구하는 크기가 있고, `requires_body`는 그것을 세 Kit이 공유하는 한 문장으로
옮긴 것이다. Kit이 `requires_body`를 따로 authored하면 그건 그것이 아니라 **규칙**이 된다.

### 1.1 파생 규칙

접근로 3개(`hand`, `doll`, `hand`)가 있는 장소의 경우:

```
requires_body = {
  scale_min: min(0.077, 0.183, 0.077) = 0.077,
  scale_max: max(0.183, 0.427, 0.183) = 0.427
}
```

즉 **접근로 band 전체의 합집합 구간**이다. 한 줄이다. 로더가 계산하고 author는 손대지
않는다. 로더는 이 값을 `AxisPlace.create()`에 그대로 넘기며, 스토어는 다시
`AxisBody.validate_requirement()`로 검사한다. 그 검사가 `requires_body_key_unknown`로
실패하면 authored 장소가 잘못된 것이다.

### 1.2 파생이 올바른 이유

접근로 band의 합집합이 곧 그 장소가 스스로 통과할 수 있는 몸의 집합이기 때문이다.
`stair_keyhole`(hand)과 `stair_door`(doll)이 있는 계단에서:

- `hand` 몸: `hand` 접근로 instanciate, `doll` 접근로도 instanciate(안 보임).
- `doll` 몸: `doll` 접근로 instanciate.
- `common` 몸: `0.65 ∉ [0.077, 0.427]`이므로 `body_satisfies()`가
  `unmet: ["scale_above_max"]`를 돌려준다. Kit은 이 값으로 **접근로 instanciate
  결정을 내리지 않는다.** 그건 접근로의 실제 band와 `body.scale`로 따로 한다.
  `body_satisfies()`는 그 결과와 **일치해야 하고**, 일치하지 않으면 콘텐츠가 틀린 것이다
  (S-INV-4, `06` T6).

**`unmet`가 나오는 것은 기분이 아니라 판정이다.** 가역(`04` §5) 이후 이 값은
"이 몸은 지금 이 장소의 접근로에 없다"를 뜻할 뿐 "이 장소는 닫혔다"를 뜻하지 않는다.
통과로 된 길은 `04` §4의 통행료를 내면 항상 열린다. `§3.4`~`§3.6`이 이 지연의
전체 모양이다.

### 1.3 `requires_body`가 하는 일 세 가지

1. **장소 선택.** Kit이 그래프를 만들 때 "이 장소가 지금 이 몸을 위한 곳인가"를 묻는다.
2. **terrain variant 선택.** 같은 place id가 Kit마다 여러 형상을 가지면, 그 중 어느
   변형을 instanciate할지 고른다.
3. **인계 검증.** W0의 통합 테스트가 "같은 place id가 세 Kit에서 같은 `requires_body`를
   갖는가"를 단언한다.

### 1.4 `requires_body`가 하지 않는 일

1. **진입을 막지 않는다.** 코드 경로 0개. `06` T2가 그 사실을 단언한다.
2. **수치를 만들지 않는다.** `AxisBody.satisfies()`는 요구 사전에 있는 키만 본다.
   `requires_nothing()`인 장소는 몸을 보지 않는다.
3. **요구되지 않은 키를 채우지 않는다.** `place.scale_min = 0.5`를 author가 쓰려 해도
   스토어는 그 값을 **저장하지 않는다.** `get_scale()`은 그대로 0.05를 돌려준다.
   `worldstate/CONTRACT.md`는 `get_*`가 항상 새 인스턴스를 만든다고 명시하고,
   `AxisBody.get_scale()`는 `_copy_value`를 거친다. 원본 딕셔너리를 만지면 안 된다.
   **이 요구를 한 Kit은 §1.4의 함정에 빠진 것이다.**
4. **한 번 만족하면 고정하지 않는다.** `scale_min`/`scale_max`는 **현재값** 판정이다.
   통과 조건이 되지 않는다. 그 조건을 만족하는 몸도 언제든 `scale`을 바꾸어 벗어난다.
   **`04_TRANSITIONS.md` §5(가역)가 있기 때문에 이 문장은 성립한다.** 되돌림이
   없으면 이 조건은 통과 후에도 사실상 고정되었고, 고정된 조건은 권한에 가까워진다.

### 1.5 `place`가 `requires_body`를 **가질 수 없는** 경우

- `requires_body: {}` — 허용, 그리고 **시작 장소에 필요하다.** §3.3.
- `requires_body`에 `scale_min`만 — **거부.** `requires_body_key_unknown`는 아니지만
  `validate_requirement`는 단일 키를 허용한다. 그래서 **로더가 거부한다**:
  `05_AUTHORED_FORMAT.md` §3.2의 `scale_band_band_unilateral`. 열린 반구간은
  "X 이상이면 무엇이든 통과"로 퇴화하므로 금지다. K5.
- `requires_body`에 `has_all_parts`까지 함께 — **허용.** 스케일과 부재는 다른 능력
  조건이고 함께 성립한다. `mirror_march` 예시(`05` §4.1).

---

## 2. 밴드가 아니라 개별 접근로가 routing의 단위다

장소의 `requires_body`는 그 장소의 **합집합**이다. 실제 routing은 접근로 단위로
일어난다. 절차:

```
1. Kit이 그래프를 구성한다. 각 장소를 활성 후보로 넣는다.
2. 각 장소의 접근로 목록에서, body.scale ∈ [band.min, band.max]인 접근로만 instanciate한다.
3. instanciate된 접근로의 edge만 그래프에 넣는다.
4. requires_body는 1단계의 필터로만 쓴다. 여기서 걸리면 단계 2가 instanciate할 접근로가
   0개가 되므로, 그 장소는 그래프에서 빠진다. 이것이 "닫힌다"가 아니다.
   "이 몸을 위한 지형이 이 장소에 없다"가 맞다.
```

핵심은 4단계가 **지형 부재**라는 것이다. 문이 잠기는 것이 아니다. 그 장소에 자기
크기의 구조물이 없다는 것이다. 어느 경우든 refusal가 아니라 **다른 곳으로 가는
그래프**다.

### 2.1 모든 몸이 자기 크기의 접근로를 하나 이상 본다

장소 instanciate는 그 장소의 접근로 3개 중 `body.scale`이 들어가는 band의 것만
나타낸다. **instanciate되지 않은 접근로는 존재하지 않는 것처럼 보인다.** 문이 열려
있는데 못 들어가는 것이 아니라, 그 크기의 문이 **스스로는 존재하지 않는** 것이다.

- `tea_stair`에 `hand`, `doll` 접근로가 있다.
- `doll` 몸에게 `doll` 문만 보인다. `hand` 키홀은 12 px짜리 하이라이트로 스쳐 간다.
- `doll` 몸이 키홀을 봤다면 그건 `common` 몸에게 `doll` 문이 보이는 것과 같은 규칙이다.

이것이 `project_decisions.md` §14가 요구하는 "문 앞, 책상 옆" 연대다. 이 세계는
바깥으로 나가지 않고 각 몸에게 스스로 자기 크기의 지형만 보인다.

---

## 3. 밴드에 없는 몸은 어떻게 되나

`q = body.scale / band_rung_value`라고 하자. `q`는 **`01` §3의 연속 변수**이고
`03` §2가 그 표현 규칙을 준다. 밴드와 어긋난 `q`의 값은 다음 세 개뿐이다.

| 위치 | `q` | `module_count = 2.75q` | 화면 |
|---|---:|---:|---|
| 2 rung 위 | 5.19 ~ 5.64 | 14.3 ~ 15.5 | 몸이 화면 밖으로 나간다 |
| 1 rung 위 | 2.29 ~ 2.36 | 6.3 ~ 6.5 | 몸이 화면을 꽉 채운다 |
| **밴드 안** | 0.98 ~ 1.02 | **2.7 ~ 2.8** | 통한다 |
| 1 rung 아래 | 0.43 ~ 0.44 | 1.2 | 몸이 모듈 하나에 들어간다 |
| 2 rung 아래 | 0.18 ~ 0.19 | 0.5 | 몸이 모듈의 절반이다 |

가운데 행만 통과한다. 나머지 네 행은 **`03`이 다루는 표현**이다. 이 사양의 일은
거기서 끝난다. 여기서 더 말하지 않는다.

### 3.1 밴드 밖 몸이 "못 가는" 곳은 정확히 어디인가

**두 군데뿐이고, 둘 다 기하다.**

1. **approach instanciate 없음.** 그 장소에 그 몸 크기의 지형이 없다. 위 §2.
2. **edge instanciate 없음.** 그 간선은 특정 band의 구조물이므로 그 몸에게 없다.
   `01` §2.2의 6개 rung 각각에 대해 그 rung의 edge가 저절로 있어야 하고,
   **`test_scale_rung_graph.gd`가 이걸 단언한다.** 그 단언이 깨지면 S-INV-3 위반이고,
   그 Kit의 Reference Game에서 dead end가 나온다. 이게 소프트락의 유일한 형태다.

거절은 이 두 가지 외에 없다. **세 번째 형태가 없어야 한다.** Kit이
`body_satisfies()`의 `satisfied == false`를 보고 "이 장소는 닫혔습니다"를 표시하거나,
"몸의 크기가 부족합니다" 류의 문자열을 띄우거나, 입력을 잠그면 그것은
**금지된 refusal**이고 `06` T2가 그 코드를 잡는다.

### 3.2 밴드 밖 몸이 갈 수 있는 곳

밴드 밖이어도 갈 수 있는 곳은 저절로 많다. 그 수는 밴드 안일 때보다 **더 많다**.
그리고 **가역(`04` §5) 이후에는 그 사실이 규칙이 아니라 당연해졌다.**

- 그 장소의 다른 접근로가 저절로 열려 있을 수 있다. `q`가 0.43이면
  `module_count` 1.2다. 그것은 통과 불가라는 신호가 아니라 **작다는 신호**이고,
  `03` §3이 그 신호의 시각 규칙을 준다.
- 그 장소의 다른 rung band를 위한 접근로가 저절로 있을 수 있다. 장소당 최대 3 rung
  (S-INV-6)이므로 최소 1개는 있다.
- **통과로 된 트리거는 밴드 조건이 없다.** 트리거는 authored 접근로에 물려 있고
  접근로에 도달해야 발동하지만, 그 트리거가 요구하는 것은 `source` rung이 아니라
  **물리적 도달 가능성**이다. `q = 0.43`이어도 키홀에 손을 넣을 수 있으면 발동한다.
- **`04` §4의 통행료를 내면 그 장소에 맞는 rung으로 갈 수 있다.** 가격은
  `0.34 × steps`이고 언제나 낼 수 있다(`04` §4.5). "언젠가 라 돌아올 수 있다"는
  것이 이 판에서 가능한 이유이며, 그것이 이 판의 기본 상태다.

### 3.3 시작 장소는 `requires_body`가 비어 있다

몸의 `scale`이 `null`인 동안은 어떤 밴드에도 들어가지 않는다.
`AxisBody._unmet_for()`는 `has_scale()`가 false면 `scale_below_min`과
`scale_above_max` **어느 것도 내지 않고** `"scale_absent"` 하나만 낸다. 그러므로
scale 없는 몸은 아무 밴드에도 못 들어간다.

그래서:

- **시작 장소는 `requires_body: {}`다.** `AxisPlace.requires_nothing()`이 true가 되고
  `body_satisfies()`가 `unmet: []`을 돌려준다. 몸이 무엇이든 통과한다.
- **시작 장소의 유일한 간선은 밴드가 없다.** `band: null`. 그 간선은 그래프에 무조건
  존재하고, 무엇을 하는 게 아니라 **트리거가 있는 문으로 이어진다.**
- 그 트리거는 `body.scale`을 쓴다. `source_rung`은 없고 `initial: true`다.
  `05_AUTHORED_FORMAT.md` §5.4. 이 쓰기 이전에 저장을 만들지 않는다 — 그 강제는
  `07_OPEN_QUESTIONS.md` **Q9**에 있다.
- 그 이후부터는 `q`가 정의되고 모든 것이 정상 작동한다.

`requires_body: {}`인 장소는 **시작 장소 외에도 필요하다.** 죽은 뒤 부활하는 지점,
Kit 전환 지점, 저 전이 구간의 중간이 그런 곳이다. **그런 장소가
authored content에 하나도 없으면 S-INV-3이 깨진다.**

`initial` 트리거만 `04` §4의 통행료를 내지 않는다. **크기를 쓰는 것이 아니라 처음
채우는 것**이므로다. 그 이후의 모든 전환은 `steps`만큼 통행료를 낸다.

### 3.4 요구하는 rung이 없으면 무엇을 하나 — 장소는 무엇을 위한 것인가

`body.scale`을 바꿀 수 있으므로, 요구하는 rung을 갖지 않은 몸에게는 **아무것도
막을 수 없다.** 그건 사실이며 받아들인다. 그러면 질문이 바뀐다.

> **잘못된 rung인 몸이 그 장소에 들어가서 무엇을 얻는가?**

답은 세 가지이고, 셋 다 **물건이 아니라 관찰**이다. `05` §3의 스키마가 이 셋을
그대로 표현한다.

| # | 얻는 것 | 어떻게 읽히는가 | 무엇을 하지 않는가 |
|---|---|---|---|
| **W1** | **시야.** 그 장소는 자기 크기로 존재하지 않지만 **보이는** 것은 남는다 | instanciate되지 않은 접근로는 **사라지지 않는다.** 배경 레이어(`soft_grid`, `field = "flow"`, `field_amplitude = module_px * 0.03`)가 그 장소를 통째로 그린다. 그래서 잘못된 rung의 몸은 자기 밴드에서 `q`만큼 작거나 크게 보인다. `03` §3·§4·§5 | 어떤 수치도 말하지 않는다. 숫자도 라벨도 없다. 오직 상대 크기 |
| **W2** | **대조.** 같은 장소의 다른 band 접근로가 나란히 보인다 | `05` §4.2의 `tea_stair`에서 두 접근로의 `target_body_px`가 `96.0 : 240.0 = 1 : 2.50`이므로 `hand` 몸에게 `stair_door`는 `module_count = 1.179`로 작게 보이고, `doll` 몸에게는 `stair_keyhole`이 `6.417`로 크게 보인다. 이 둘이 **동시에** 보일 때 "같은 문이 두 크기로 열린다"가 실제로 일어난다 | band span은 `05` §6의 `scale_span_exceeds_fit`이 2 rung 폭 이내로 막는다. G3은 접근로의 `module_px`와 band rung의 통과 기하 일치를 강제한다 |
| **W3** | **개체 접촉.** 그 장소에 사는 개체는 band로 막히지 않는다 | `DESIGN_DECISION.md` §2.2에 따라 `creature`는 `body`를 **읽고 자기 방식으로 재현**한다. 그 개체의 행동이 `creature.memory`에 사건으로 쌓인다. `memory`는 점수판이 아니다 | 개체의 존재가 `body.scale`을 바꾸지는 않는다. 축을 건너는 전이는 없다 |

### 3.5 그래서 언제 통행료를 내는가

| 시점 | 상황 | 판정 |
|---|---|---|
| **지금** | 그 장소의 **내부 오브젝트**가 필요할 때 | 그 오브젝트를 instanciate하는 것은 특정 band의 접근로다. 내가 그 band가 아니라면 그 오브젝트는 **거기 그대로 있다.** `consume` 트리거는 그 band 접근로 위에 놓인다. `05` §5.1 |
| **나중** | 그 장소의 다른 곳으로 가고 싶을 때 | 다른 band 접근로로 간선이 instanciate된다. S-INV-3이 각 rung에 대한 간선 ≥ 1개를 강제 |
| **왕복** | 안쪽으로 들어갔다가 나오는 경우 | 전환 4회 이하, 확정 사실 4개 이하. `04` §5.3 |

**요구하는 rung이 없는 장소를 들어가는 것이 무의미해 보이지만 실제로는 그렇지 않다.**
이유는 authored content가 **band 접근로의 물건과 `band: null` 접근로의 물건을 같은
장소 파일에 같이 놓기** 때문이다. 그 물건은 그 장소에 **있고** 내가 그 크기로 닿지
못할 뿐이다. 그 물건이 보이는 것 자체가 그 장소가 나중에 쓰일 이유가 된다.

### 3.6 그 답이 "문은 잠기지 않는가"와 다른 이유

`band: null` 접근로 하나만 있는 장소는 `requires_body: {}`가 되므로
**모든 몸이 통과 가능하다**(`05` §3.2). 이것은 문이 잠기지 않는다는 뜻이다.
잠기지 않는 것과 **가치가 없는 것**은 다르다. 잠기지 않는 장소는 그 안에서
`creature`의 사건이 일어나고 `consume` 트리거의 대상 오브젝트가 있고, 그 오브젝트는
band 접근로의 트리거가 기다린다. 그 band에 도달하는 방법이 **통행료를 내는 것**이다.
그런다 그래서 그 장소는 밴드에 맞는 몸에게 반복해서 쓰인다.

**요구하는 rung이 없는 몸이 그 장소를 즉시 쓸 수 있는 것은 아니다. 쓸 수 있는
것은 그 장소가 무엇을 가지고 있는지를 보는 것까지다.** 그것이 `03` §5의
"어긋남의 가장 강한 무언적 신호"가 실제로 의미하는 바이며, 그 때문에
잘못된 rung의 방문이 **벌**이 아니라 **관찰**이다.

### 3.7 밴드 밖 몸이 "못 가는" 곳은 여전히 두 군데다

`§3.1`이 말한 두 가지는 가역 이후에도 그대로다.

1. **approach instanciate 없음.** 그 장소에 그 몸 크기의 지형이 없다.
2. **edge instanciate 없음.** 그 간선은 특정 band의 구조물이므로 그 몸에게 없다.

**여기에 세 번째 refusal는 생기지 않는다.** `body_satisfies()`의
`satisfied == false`를 보고 입력을 잠그거나 문자를 띄우는 코드 경로 0개.
`04` §4.5(차단 불가)가 그것을 강제하고 `06` T2가 단언한다.

---

## 4. 밴드가 아닌 요구: 부재와 상처

`requires_body`의 나머지 세 capability 키는 `01`과 독립적으로 작동한다. 스케일 시스템
은 이 셋을 **건드리지 않는다.** 다만 이 사양이 두 가지를 명시한다.

### 4.1 부재는 밴드를 좁히지 않는다

`has_all_parts: ["hand.left"]`는 `hand.left`가 부재로 기록된 몸을 거절한다. 그 몸의
`scale`은 바뀌지 않는다. `0.12`는 `0.12`로 남는다. 부재는 밴드를 **추가로** 요구할 뿐
스케일 축에 **영향을 주지 않는다.** 두 capability 키는 독립이다.

반대로: 부재 때문에 밴드에 못 들어가면, 그건 밴드 위반이 아니라 부재 위반이다.
`unmet`에 두 개가 같이 들어갈 수 있다. `["part_missing:hand.left", "scale_below_min"]`.
각각 다른 capability 조건이고, 각각 다른 접근로를 막는다.

### 4.2 상처의 `severity`는 요구조건이 아니다

`AxisBody._is_wound_match()`가 `severity`를 **명시적으로 거부**한다
(`_: return false`). 요구조건에 `severity`를 넣으면 `value_type_invalid`. 스토어가
이미 막고 있다. 그러므로 이 사양은 `requires_body`에 상처 **크기** 조건을 두지 않는다.
크기는 그 상처를 authoring한 Kit이 자기 물리에서 해석할 뿐이다. `scale`과 같은
원리다: 사실은 저장하고, 해석은 Kit의 몫이다.

---

## 5. 요구조건이 충돌할 때: 불일치는 콘텐츠 오류다

`requires_body`는 접근로 band의 합집합이고, 접근로는 각자의 `module_px`를 가진다.
두 곳의 사실이 어긋나면 **어느 쪽도 플레이어에게 refusal로 보이지 않는다.** 대신:

1. 콘텐츠 로더가 그 authored 장소를 **거부**한다. `push_error` + 빈 결과.
2. 그 Kit의 `test_scale_geometry.gd`가 **실패**한다.
3. W0 통합 테스트가 그 Kit의 `load` 명령이 **0이 아닌 exit code**를 낸다.
4. 플레이어는 그 장소를 본 적이 없다. 게임이 그 장소를 아예 모른다.

**이것이 유일한 정직한 실패다.** 요청한 content id가 stale이거나 문법이 깨졌을 때
`worldstate/CONTRACT.md`는 조용히 기본값으로 덮지 말고 "정직한 실패"를 낸다. 스케일
시스템도 똑같다. "닫혔다"가 아니라 "없다"가 정직한 실패다.

`requires_body`가 지형의 기하와 **불일치**하는데도 로더가 그 장소를 instanciate하는
경우는 S-INV-4 위반이다. 그 경로를 차단하는 것은 `test_scale_geometry.gd`다.
런타임에 새 refusal를 만들지 않는다. **런타임 refusal를 새로 만드는 순간 그건
S-INV-2 위반이고 S-INV-4의 정직한 실패를 불성실로 바꾼 것이다.**

---

## 6. 구현 시 유의할 세 가지 함정

### 6.1 `get_requires_body()`는 방어적 복사본이다

`AxisPlace.get_requires_body()`는 `(requires_body as Dictionary).duplicate(true)`
를 돌려준다. 원본을 만지지 않는다. 이 사양은 이 축이 읽기 전용이라는 사실
(`CONTRACT.md` "There is no mutating method on this class and none will be added")을
전제로 한다. Kit이 요구조건을 "임시로 풀어준다"는 이유로 원본을 만지면 **런타임
불변식이 깨진다.** 요구조건을 풀어야 하는 유일한 경우는 지형 선택이며, 그건
`requires_body`가 아니라 접근로 band로 한다.

### 6.2 `satisfies()`는 `ok`와 `satisfied`를 동시에 false로 돌려줄 수 있다

```gdscript
AxisBody.satisfies({"scale_min": 0.183, "scale_max": 0.427})
# 요구조건 자체가 잘못되면:
#   {ok: false, reason: &"requires_body_key_unknown", satisfied: false, unmet: []}
```

`satisfied == false`만 보고 "몸이 안 맞는다"고 읽으면 안 된다. **`ok`를 먼저 본다.**
`ok == false`는 **authoring 오류**이고 `ok == true && satisfied == false`는 **몸이 안
맞는 것**이다. 둘을 같은 경로로 묶는 Kit은 `06` T2가 잡는다. 이 distinction이
`CONTRACT.md`가 "어떤 호출도 bare boolean을 돌려주지 않는다"고 말하는 이유다.

### 6.3 `THRESHOLD_SUFFIXES`는 되돌림 위로를 막는다

`AxisBody._is_permission_key()`은 `_min`, `_max`, `_threshold`, `_at_least`,
`_at_most`를 벗겨서 다시 검사한다. `karma_min`은 `karma`로 되돌리고, `trust_at_least`는
`trust`로 되돌린다. 즉 **`scale_at_least`도** 되돌리면 `scale`인데 `scale`은 목록에
없으므로 통과한다. 그러나 `grade_min`은 `grade`로 되돌리고 `grade`는 목록에 있으므로
거부된다. 이 사양은 `scale_*` 계열을 `requires_body`에 쓰지 않는다. `scale_min`과
`scale_max`가 **유일하게** 허용된 이름이다.
