> 상태: **초안 — 사용자 승인 대기**

# TINProject 세계관 문서 (`docs/world/`)

이 폴더는 **TINProject 설정의 세계관 정본**이다.
앨리스의 이상한 나라를 **척도 붕괴(크기를 잃은 세계) 후의 포스트아포칼립스로 재해석한** 하나의 세계를 정의한다.
세 Kit — `sideview_ecosystem`, `physics_puzzle_platformer`, `descent_exploration` — 이 **같은 세계, 같은 지역, 같은 규칙 안에** 산다.

이 폴더는 **문서만** 다룬다. 이미지·오디오·코드를 만들지 않는다.
코드 계약을 소유하지 않는다. 런타임 계약을 바꾸지 않는다.
`docs/MODULE_CONTRACT.md`, `docs/ARCHITECTURE.md`, `docs/KIT_WORKFLOW.md`를 바꾸지 않는다.

**이 폴더의 기초는 2026-09-26에 바뀌었다**
이전 판은 **물이 없는 세상**이 아니었다. 침수·빗물·눈물 웅덩이·강·해자가 그 판의 기초였고, 사용자가 그것을 한 문장으로 기각했다.
현재 판은 **척도 붕괴** 위에 서 있다. 이 폴더에서 이전 판의 판정 근거는 **물리적으로 무효**이며, 그 판이 남긴 좋은 구조( unauthored 규칙 문서 하나, 네 권력, 20개 구역, 재질 서술 규칙, "플레이어에게 설명하지 않는다"는 방향)는 **새 기초 위에서 다시 쓰였다.**

---

## 0. 이 폴더의 권한 한계

사용자 결정으로 이 폴더는 **초안**이다. 아래 중 어떤 것도 확정된 사실이 아니다.

- 세계의 이름
- **단계 사다리의 비율과 허용 오차** (12가 수치를 제시했으나 확정되지 않음)
- 모든 구역의 요구치 `d` / 개구부 `p`·`q` / 자세 면적 `f`
- 세 권력의 존재 여부와 이름과 각자의 기준 선언
- 구역 이름과 경계
- 생물 종류와 실루엣
- 재질의 밀도 배율·반사율
- 연대 기조

모든 이런 항목은 본문 안에서 `(초안)`으로 표시되며, 전부 [10_OPEN_QUESTIONS.md](./10_OPEN_QUESTIONS.md)에 질문으로 다시 나열된다.
문서 안에서 확정한 것처럼 읽히는 문장은 **문법과 금지 규칙처럼 모든 세대·모든 구역에서 예외가 없는 것**뿐이다. 그건 [00_CONSTITUTION.md](./00_CONSTITUTION.md)의 제0부와 [13_REFERENCE_EXCLUSIONS.md](./13_REFERENCE_EXCLUSIONS.md)에만 있다.

**확정된 것이 하나 있다. 그리고 그 하나는 덮어쓸 수 없다.**
`00_CONSTITUTION.md` **제0부**는 사용자 확정 사항이다.
1. 이 세계의 상태는 **척도 붕괴**다.
2. **물은 이 세계에 존재하지 않는다.**
3. 레퍼런스 게임의 **고유 형질은 0개**다.
4. 이 폴더는 **플레이어에게 아무것도 설명하지 않는다.**
이 네 항목에 `(초안)`을 붙이는 것은 그 자체가 규칙 위반이다.

Kit 구현자는 이 폴더를 **읽어도 되고 읽지 않아도 된다.**
`plans/kits/08_DESCENT_EXPLORATION_KIT.md` §0.3이 이미 정한 것처럼, Kit은 `loc.*` / `thing.*` 같은 **ID 문자열**로 세계를 참조한다.
모듈이 `docs/world/**`를 직접 읽게 하면 세계관과 구현이 결합된다. 금지다.
**예외 하나:** [12_SCALE_RULES.md](./12_SCALE_RULES.md)는 Kit이 알아야 하는 **세계관 물리**다. 그래도 Kit이 이 파일을 읽는 것이 아니라 **`core/worldstate`를 통해 값을 읽는다**(12-8절).

---

## 1. 문서 목록

| ID | 파일 | 소유 질문 |
|---|---|---|
| — | [README.md](./README.md) | 이 폴더가 무엇이고 무엇이 아닌가 |
| 00 | [00_CONSTITUTION.md](./00_CONSTITUTION.md) | **제0부 6항목 + 불변식 27개.** 위반하면 구현이 실패한다 |
| 01 | [01_POST_APOCALYPSE.md](./01_POST_APOCALYPSE.md) | 무너진 것, 무너진 순서 0~9단계, 물리적으로 남은 것 |
| 02 | [02_ALICE_REINTERPRETATION.md](./02_ALICE_REINTERPRETATION.md) | 원작 요소 16개와 금지 요소 2개가 각각 무엇이 되었는지 |
| 03 | [03_AUTHORITIES.md](./03_AUTHORITIES.md) | 아직 척도를 부과하는 권력 4개, 그 압력, **살아남는 모순 4개** |
| 04 | [04_DISTRICTS.md](./04_DISTRICTS.md) | 이름 있는 장소 20곳, 요구치, 어느 Kit이 쓰는지 |
| 05 | [05_POPULATION.md](./05_POPULATION.md) | 사람·생물·기계처럼 사는 것 20종의 실루엣과 **단계** |
| 06 | [06_MATERIALS.md](./06_MATERIALS.md) | 재질 17종과 밀도 단계. 절차 비주얼 시스템의 직접 입력 |
| 07 | [07_LANGUAGE_AND_SIGNS.md](./07_LANGUAGE_AND_SIGNS.md) | 표지, 각인, 경고, 장부, **경고 네 종류** |
| 08 | [08_CHRONOLOGY.md](./08_CHRONOLOGY.md) | 연대. 제0기부터 현재까지, **9개 기** |
| 09 | [09_GLOSSARY.md](./09_GLOSSARY.md) | 용어집. `CONTEXT.md`를 연장하며 절대 덮어쓰지 않는다 |
| 10 | [10_OPEN_QUESTIONS.md](./10_OPEN_QUESTIONS.md) | 확정한 것처럼 쓰지 않은 **36개** 선택 |
| 11 | [11_CONFLICTS_WITH_PLANS.md](./11_CONFLICTS_WITH_PLANS.md) | Kit 계획과의 충돌. **치명 2건** 포함 |
| **12** | **[12_SCALE_RULES.md](./12_SCALE_RULES.md)** | **척도 규칙. 세 Kit이 공유하는 유일한 수치** |
| **13** | **[13_REFERENCE_EXCLUSIONS.md](./13_REFERENCE_EXCLUSIONS.md)** | **레퍼런스 3작의 고유 형질 금지 목록** |

읽는 순서는 00 → 12 → 01 → 03 → 04 순이 가장 빠르다.
**12가 이 폴더의 규칙집이다.** 00이 말하는 "척도 붕괴"가 무엇인지 12가 정의한다.
02가 이 세계관의 서사 문서다. 01이 그 서사의 순서다.

---

## 2. 세 Kit이 이 세계를 공유하는 방식

`docs/research/round_2026_09_26/ROUND_PLAN.md` §7은 세 Kit의 진행 축을 서로 다르게 못 박는다.
이 세계관은 그 세 축을 **하나의 세계의 세 관측**으로 만든다. 같은 대상을 다른 거리에서 보는 것이다.

| Kit | 진행 축 | 이 세계에서 무엇을 보는가 | 공유하는 것 |
|---|---|---|---|
| A `sideview_ecosystem` | **신체(몸).** 누적 없음. 그 자리가 요구하는 단계로만 통과 | 그 구역에 산 존재들이 실제로 먹는 것, 피하는 것, 그리고 **몸이 몇 단계여야 그 틈을 지나는가** | 구역, 개체, 개구부, 재질 |
| B `physics_puzzle_platformer` | **조합.** handmade 도구와 레벨의 무작위 선택, 자물쇠-열쇠 금지 | 그 구역에 남아 있는 **물건과 잔해**가 물리 법칙 위에서 어떻게 조합되는가 | 구역, 재질, 도구, 권력의 무기 |
| C `descent_exploration` | **지식과 선택.** 수집·소모·분기 종료, 세기 반복 금지 | 그 층을 내려가며 **알아야만** 열리는 경로 | 구역, 사실(fact), 권력의 기록 |

세 Kit이 **같은 구역 ID 문자열**을 공유하는 곳은 [04_DISTRICTS.md](./04_DISTRICTS.md)에 공유 목록으로 있다.
두 Kit 이상이 쓸 수 있는 구역이 최소 3곳이라는 설계 목표는 현재 **열세 곳**으로 채워져 있다(초안).
**셋 이상이 Kit A·B·C 전부에게 열려 있는 곳도 세 곳**(`loc.halls`, `loc.teeth`, `loc.floor`)이다.

공유는 **경로가 아니라 규칙**이다.

- 두 Kit의 구역이 겹치면 **진입 조건이 같은 문장**이어야 한다. `loc.teeth`는 A에게 "몸이 좁아야 하는 자리"로 읽히고 B에게 "도구가 무거워야 하는 자리"로 읽힌다. 둘 다 **같은 공간의 다른 성질**이다. 서로 다른 방이어서는 안 된다.
- 두 Kit이 같은 재질을 만나면 **같은 마찰과 같은 밀도**여야 한다. 06의 물리는 12의 밀도 배율과 한 장으로 맞는다.
- 세 Kit이 같은 권위체를 만나면 **다른 압력**을 받지만 **같은 근거**를 원한다. A는 신분표를, B는 값표를, C는 사실 정정을 각자 원한다. 권위체는 셋 다 거절할 수 있다.

---

## 3. 이 세계관이 정하지 않는 것

- 게임 밸런스 수치
- 레벨 배치 좌표
- 도구 목록과 질량
- 화면비와 UI 문구
- 사운드 이벤트 이름
- 저장 스키마
- **12_SCALE_RULES.md의 수치를 Kit 코드에 복사하는 방법.** Kit은 `core/worldstate`를 통해 읽는다.

위 항목은 각 Kit 계획서가 소유한다.
이 폴더가 그걸 정하거나, 그걸 정한 척하지 않는다.

---

## 4. 외부 참조

- 공통 용어 원본: [`CONTEXT.md`](../../CONTEXT.md) — 이 폴더는 이를 연장한다
- 설계 철학: [`docs/DESIGN_PHILOSOPHY.md`](../DESIGN_PHILOSOPHY.md)
- 이번 라운드 크로스킷 정본: [`docs/research/round_2026_09_26/ROUND_PLAN.md`](../research/round_2026_09_26/ROUND_PLAN.md)
- Kit A 계획: [`plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md`](../../plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md)
- Kit B 계획: [`plans/kits/07_PHYSICS_PUZZLE_PLATFORMER_KIT.md`](../../plans/kits/07_PHYSICS_PUZZLE_PLATFORMER_KIT.md)
- Kit C 계획: [`plans/kits/08_DESCENT_EXPLORATION_KIT.md`](../../plans/kits/08_DESCENT_EXPLORATION_KIT.md)
- Kit A 조사: [`docs/research/rain_world/RAIN_WORLD_RESEARCH.md`](../research/rain_world/RAIN_WORLD_RESEARCH.md)

`plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/`와 `05_STONE_STORY_RPG_KIT/`에도 세계관급 내용이 있다.
이 폴더는 그 둘을 **읽지 않았다.** 따라서 그 둘과 충돌하지 않는다고 **주장하지 않는다.**
관련 항목은 [11_CONFLICTS_WITH_PLANS.md](./11_CONFLICTS_WITH_PLANS.md)에 기록한다.

---

## 5. 관리 규칙

1. 이 폴더는 한 작성자만 쓴다. 병렬 라운드에서는 소유자를 라운드 시작 시 지정한다.
2. `CONTEXT.md`, `PROJECT_DECISIONS.md`, `plans/`, `core/`, `modules/`, `app/`, `docs/`의 다른 하위 폴더는 쓰지 않는다.
3. `(초안)` 표시를 지우는 것은 사용자 승인이 있을 때만 한다.
4. 규칙을 추가할 때는 `00_CONSTITUTION.md`에만 추가한다. 다른 파일에 규칙을 흩뿌리지 않는다.
5. **수치는 `12_SCALE_RULES.md`에만 쓴다.** 다른 파일이 12의 수치를 다시 적으면 그것은 중복이고, 중복이 두 번 생기면 규칙이 두 개가 된다.
6. 원작 요소를 도입할 때는 반드시 `02_ALICE_REINTERPRETATION.md`의 4항목(원소 / 원래 의미 / 이쪽 의미 / 버린 것)을 채운다. 빈칸으로 새 원소를 추가하지 않는다.
7. **금지된 형질을 도입하고 싶을 때는 13-5절의 다섯 질문을 순서대로 통과해야 한다.** 하나라도 "예"이면 넣지 않는다.
8. 이 폴더를 쓴다고 게임 실행·시각 검수가 완료된 것이 아니다. 자동 검증과 수동 플레이는 별개다.

---

# 6. 이 폴더를 빠르게 확인하는 법

사용자가 이 세상관을 처음 볼 때, 아래 순서로 읽으면 30분 안에 이 세상의 성격을 파악할 수 있다. Kit 구현자는 이 순서를 따를 필요가 없다. 필요한 문서만 읽으면 된다.

## 6.1 세 Kit을 위한 최소 경로 (30분)

1. [00_CONSTITUTION.md](./00_CONSTITUTION.md) **제0부만** — 이것만 읽어도 무엇이 금지인지 안다. 5분이면 된다.
2. [12_SCALE_RULES.md](./12_SCALE_RULES.md) 1~3절 — 단계가 무엇이고 통과가 어떻게 판정되는지 안다. 10분.
3. [04_DISTRICTS.md](./04_DISTRICTS.md) 공유 목록 — 이 세상에서 어디가 어디인지 안다. 5분.
4. [11_CONFLICTS_WITH_PLANS.md](./11_CONFLICTS_WITH_PLANS.md) 1부 앞 두 항목 — **무엇이 막혀 있는지** 안다. 5분.

## 6.2 이 세상관을 이해하려는 사람의 경로 (2시간)

1. [01_POST_APOCALYPSE.md](./01_POST_APOCALYPSE.md) — 무너진 순서 10단계를 안다. 20분.
2. [03_AUTHORITIES.md](./03_AUTHORITIES.md) — 권력 넷이 어떻게 다른지, 살아남는 모순 4개가 무엇인지 안다. 20분.
3. [02_ALICE_REINTERPRETATION.md](./02_ALICE_REINTERPRETATION.md) — 원작 요소 16개와 금지 요소 2개가 각각 무엇이 되었는지 안다. 25분.
4. [13_REFERENCE_EXCLUSIONS.md](./13_REFERENCE_EXCLUSIONS.md) — 이 세상이 **무엇을 일부러 닮지 않았는지** 안다. 15분.
5. [07_LANGUAGE_AND_SIGNS.md](./07_LANGUAGE_AND_SIGNS.md) — 이 세상에 글이 어떻게 남았는지 안다. 10분.
6. [05_POPULATION.md](./05_POPULATION.md) — 무엇이 살아 있는지 안다. 15분.
7. [06_MATERIALS.md](./06_MATERIALS.md) — 무엇으로 지어졌는지 안다. 15분.
8. [08_CHRONOLOGY.md](./08_CHRONOLOGY.md) — 지금이 언제인지 안다. 10분.
9. [09_GLOSSARY.md](./09_GLOSSARY.md) — 말이 어떻게 쓰이는지 안다. 10분.

## 6.3 통합 담당을 위한 경로 (1시간)

1. [11_CONFLICTS_WITH_PLANS.md](./11_CONFLICTS_WITH_PLANS.md) 1부 — **N1과 N2는 사용자 결정이다.** 그 둘이 목록 앞 두 칸이다.
2. [10_OPEN_QUESTIONS.md](./10_OPEN_QUESTIONS.md) — 결정이 필요한 36개와 권장안을 한 번에 본다. 난이도 `A` 15개를 먼저 본다.
3. [13_REFERENCE_EXCLUSIONS.md](./13_REFERENCE_EXCLUSIONS.md) 5절 — 애매한 형질이 들어왔을 때의 판정 절차. 기계 검사 요청도 이 파일 말미에 있다.

---

# 7. 다른 문서가 이 폴더에 던질 질문

다른 문서가 이 폴더에 던질 질문과, 여기에서의 답을 미리 적는다. **답이 없는 질문은 10으로 간다.**

## "이 구역의 규칙이 뭐지?"
→ [04_DISTRICTS.md](./04_DISTRICTS.md)의 그 구역 항목의 **요구치** 칸. 세 Kit이 있는 구역이면 요구치·개구부·자세 면적이 전부 있다.
값을 계산해야 하면 [12_SCALE_RULES.md](./12_SCALE_RULES.md) 2절의 세 게이트를 쓴다.

## "몸이 몇 단계여야 통과하지?"
→ [12_SCALE_RULES.md](./12_SCALE_RULES.md) 1절의 표와 2절의 세 게이트. **수치판은 12에만 있다.**

## "이 재질이 어떻게 움직이지?"
→ [06_MATERIALS.md](./06_MATERIALS.md)의 **물리** 칸. 세 Kit이 공유하므로 그 답이 세 곳에서 같다. 밀도 배율은 06-0절.

## "이 권력이 뭘 원해?"
→ [03_AUTHORITIES.md](./03_AUTHORITIES.md)의 네 권력 항목. 권력들이 모순하는 지점은 5-1절의 네 항목이다.

## "이 원작 요소를 써도 되나?"
→ [02_ALICE_REINTERPRETATION.md](./02_ALICE_REINTERPRETATION.md)에 네 칸이 다 채워져 있으면 쓸 수 있다. **0-1과 0-2는 금지 목록**이므로 쓰지 않는다. 네 번째 칸이 비면 쓸 수 없다.

## "이 문장이 이 세상 규칙을 깨나?"
→ 순서대로 본다. ① 물이 들었나 ② 00 제0부의 네 항목을 위반했나 ③ 13의 금지 형질인가 ④ 00-14~20의 금지인가 ⑤ 12의 다섯 표현으로 바꾸었나.
깨면 그 문장을 고치지 말고 규칙부터 본다.

## "이 이름은 이 세상에 있는 이름이야?"
→ [09_GLOSSARY.md](./09_GLOSSARY.md) 제2부에 있으면 있다. 없으면 [10_OPEN_QUESTIONS.md](./10_OPEN_QUESTIONS.md)에 추가해야 한다.

## "이 숫자는 이 세상에서 왜 나와?"
→ 12_SCALE_RULES.md에만 숫자가 있다. **다른 파일에 숫자가 보이면 그건 중복이고 중복은 오류다.** 다만 그 숫자가 04의 요구치라면 04가 그 자리의 초안이고, 그 값이 12의 공식값을 바꾸지는 않는다.

## "이걸 유저에게 알려줘도 되나?"
→ **안 된다.** 00 불변식 0-4. 이 폴더는 제작 전용 정본이다. 예외 절차는 없다.
