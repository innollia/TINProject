# 계획 01 — 규칙 재작성 게임형 모듈

## 현재 구현에서 이어가는 보완 R1

**구현 기록:** 2026-09-23 R1의 `signal_room_01`은 실제 격자, runtime 문장 파싱, multi-YOU 수동 이동, PUSH/STOP, WIN, undo를 가진다. 현재 작업에서 모듈 로컬 `RuleEvaluator`와 자동 이동 solver를 연결했다. `crossing_02`에서 LAMP→ROCK 변환, ROCK MOVE/PUSH, 움직이는 단어 뒤 재파싱, FLAG의 WIN+DEFEAT 충돌, 실패 undo와 JSON roundtrip을 테스트한다. manifest/state format은 v4이며 entity facing, 변환 종류, 실패 상태를 보존한다. 두 번째 레벨은 테스트에서 명시적으로 로드되며 플레이어용 레벨 선택 경로와 최종 보드 시각화는 아직 없다. **사용자 확정:** 실제 기존 저장은 없으므로 이전 v2 진행의 호환성·보존은 요구하지 않는다. v4 이전 저장은 새 격자 초기 상태를 반환한다.

**AI 구현 제안 — 순서와 파일**
1. **완료:** `systems/level_loader.gd`, `content/level_01_signal_room.json`, `content/level_02_crossing.json`으로 레벨을 검증·복원한다. scene node나 view는 규칙 계산의 입력이 아니다.
2. **완료:** runtime 입력은 `RuleMovementSolver.plan_move_many`를 이용해 현재 YOU 전체의 같은 방향 이동 계획을 만들고 적용한다. 단어 변경 뒤 `RuleParser.parse`를 즉시 다시 실행하며 다음 입력은 갱신된 규칙을 사용한다. 막힌 push는 원자적으로 실패하고 성공한 turn은 격자 snapshot으로 undo된다.
3. **완료:** `RuleEvaluator`가 객체만 변환하고 word token을 보존한다. 다중 결과는 정렬된 출력 중 하나를 원본 ID에 유지하고 나머지는 안정된 `transform::` ID로 생성한다. 객체당 한 턴 한 번만 변환해 A→B→C 연쇄를 막는다. MOVE 대상은 ID 순서로 한 칸 이동하고, 먼저 밀린 MOVE 대상은 같은 phase에서 다시 움직이지 않는다. 막힌 대상은 방향을 반대로 돌린다. 자동 이동이 단어를 밀면 문법을 재평가하고 아직 처리하지 않은 객체 변환을 적용한다. DEFEAT 제거를 WIN보다 먼저 처리하며, 규칙 문장 파괴로 YOU만 사라진 경우는 실패가 아니라 undo 가능한 제어 상실이다.
4. **진행:** `crossing_02`는 module save/load 경로에 직접 주입해 변환·MOVE·DEFEAT·undo를 검사한다. 아직 플레이 중 선택하는 레벨 라우트는 없다. 이후 별도 작업에서 reset과 플레이어 레벨 진입을 연결하고, 두 번째 레벨의 화면을 직접 검수한다. 앱의 기존 back/forward 요청 계약은 유지한다.

**판정 세부:** 수동 YOU 이동은 입력 전 상태에서 계획하고 막힌 push는 일부만 이동하지 않는다. 변환은 실제 object에만 적용하고, 한 turn 안에서 같은 entity ID를 다시 변환하지 않는다. 다중 output은 정렬해 원본 종류와 파생 ID를 안정화한다. auto MOVE 순서는 ID 기준이며 다른 MOVE가 밀어낸 개체는 자기 차례에 추가 한 칸을 더 가지 않는다. auto MOVE가 단어를 밀었을 때 문장과 미처 변환하지 않은 객체만 재평가한다. WIN/DEFEAT 동시 접촉은 DEFEAT 제거 후 살아남은 YOU로 WIN을 판정한다. 모든 YOU가 DEFEAT로 제거된 경우만 failed로 저장하고 undo로 복구한다.

**저장 형식 현재 사실:** manifest v4 / `state_format: 4`는 mode, clue focus/observation, `active_level_id`, JSON-safe grid, `solved`, `failed`, turn/attempt 수치, undo snapshots를 저장한다. 각 entity는 좌표와 cardinal `facing_x/facing_y`를 저장한다. authored word token은 항상 존재하고 역할/종류/base tags가 일치해야 한다. authored object는 DEFEAT로 제거될 수 있고 noun token에 선언된 kind 사이에서 변환될 수 있다. 생성 object는 `transform::` ID와 authored noun 종류만 허용한다. 이전 형식 이관은 하지 않고 새 초기 상태로 시작한다. 알려진 level의 malformed grid는 해당 level의 authored 기본 grid로 복구한다. 손상된 undo entry만 제외하며 unknown level ID는 모듈 전체를 기본 상태로 초기화한다.

**추가 실패 검증:** blocked push 원자성, 입력 entity 순서에 무관한 이동 계획, multi-output 변환 ID 안정성, word token 변환/제어 제외, MOVE blocked turnaround와 밀려난 MOVE의 단일 스텝, 변환/facing→저장→load→undo, rule 파괴로 인한 YOU 상실과 DEFEAT 패배 구분, WIN+DEFEAT에서 DEFEAT 우선, unknown level ID 정규화. 이후 추가 시 history cap과 출구 요청 중복을 계속 검증한다.

**화면 실행 브리프:** 1152×720 중 중앙 약 960×576은 보드, 하단은 텍스트 undo/reset/귀환 안내. 첫 초점은 조작 객체와 같은 보드의 문장이다. 선택 전후·문장 파괴·제어 상실·복원·패배·승리 캡처를 기존 시각 계약에 추가한다. 샘플의 BABA/ROCK/FLAG는 문법 설명용이며 실제 콘텐츠 noun·문구·레벨은 독자적으로 작성한다.

**착수 조건:** 외부 베이스의 미확인 라이선스는 여전히 복사 불가다. 기존 조사 후보에 대한 최신 재확인과 최소 3개 비교를 마친 뒤 채택 파일을 확정한다. 이 문서 보강은 새 베이스 채택 기록이 아니다.


공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스: **Baba Is You**  
목표: 레벨 하나가 아니라 **텍스트/오브젝트가 런타임 규칙을 구성하고 그 규칙이 즉시 세계 동작을 바꾸는 시스템**을 만든다.

> 기존 구현 ID는 `rule_rewriting`이다. 아래 `<RULE_MODULE_ID>`는 이 경로를 뜻하며 정식 작품명 확정과는 별개다.

---

## 0. 외부 베이스 조사

2026-09-23까지 최소 3개 후보를 비교했다. 기준은 Godot에 바로 넣을 수 있는 코드가 있고, 분리 가능한 parser/evaluator/history가 있으며, 현재 Godot 4.7.2·typed GDScript 계약으로 제한된 포팅을 할 수 있는지다. **채택한 외부 파일은 없다.** 현재 parser foundation은 모듈 로컬 typed GDScript로 작성했으며 외부 레벨·문구·자산·코드는 가져오지 않았다.

### 현재 확인 후보

#### A. mkskelet/baba-is-fake
- Godot **3.1.2 Mono**
- C#
- 확인 파일: `Scripts/LevelController.cs`, `Movable.cs`, `Thing.cs`, `Word.cs`
- 장점: Baba형 게임의 핵심 객체/단어/레벨 제어 구조를 직접 볼 수 있음
- 문제: 저장소에 LICENSE가 확인되지 않음
- 판정: **코드 복사 금지. 구조 참고만.**

고정 참고 commit:
`ba96220da581024cd513bac12ce4308d5cf004b2`

#### B. Boyquotes/babaisclone
- 공개 저장소이나 현재 루트에 웹 export 산출물만 확인됨
- 소스 및 명시 라이선스가 확인되지 않음
- 판정: **베이스 사용 부적합**

#### C. Insoumis/laec-est-toi
- 확인 commit: `81b5220bcc830c9a9abd9f8b18f2a376b528c39a`
- README 기준 Godot 3 프로젝트. 게임 코드 라이선스는 WTFPL, 아트는 CC0로 표기되지만 음원은 별도 저작권 표기가 있다.
- 판정: 코드 이용 허용 표기가 있어도 현재 계획이 요구하는 분리형 parser/turn-history 기반으로 검증되지 않았다. 이 저장소의 파일은 가져오지 않는다. Godot 3 프로젝트 구조 전체를 Godot 4.7.2 typed GDScript로 옮기는 비용은 높고, 가져올 파일·autoload 의존성을 특정하지 못했다.
- 출처: [저장소](https://github.com/Insoumis/laec-est-toi/tree/81b5220bcc830c9a9abd9f8b18f2a376b528c39a)

#### D. utilForever/baba-is-auto
- 확인 commit: `24cefb48d47ae6a6f5c0d936310d8bceb9c4279d`; MIT, C++17 중심의 simulator/tooling 프로젝트이며 Godot 버전은 해당 없음.
- 장점: 규칙 상태를 기계적으로 탐색하는 구현 참고로 활용 가능.
- 판정: 렌더러/씬용 Godot 모듈이 아니며 기존 GDScript domain과 바로 맞닿는 파일이 없다. 가져올 파일/autoload는 없음. 필요한 부분을 포팅하는 비용이 높아 코드 베이스로 채택하지 않는다.
- 출처: [저장소](https://github.com/utilForever/baba-is-auto/tree/24cefb48d47ae6a6f5c0d936310d8bceb9c4279d)

#### E. archiloque/babaisyousolver
- 확인 commit: `371a1850f869f6a13e57c32d668a88f936ff95e6`; MIT, Java, Godot 버전은 해당 없음. archived/WIP solver다.
- 판정: 특정 상태의 해법 탐색 참고에는 쓸 수 있지만 플레이 런타임/parser/history의 기반으로는 맞지 않는다. 가져올 파일/autoload는 없으며 Java 코드를 모듈 런타임으로 포팅하는 비용이 높다.
- 출처: [저장소](https://github.com/archiloque/babaisyousolver/tree/371a1850f869f6a13e57c32d668a88f936ff95e6)

### 베이스 판정

비교한 후보에서 **라이선스가 명확하고, Godot에 맞고, parser/evaluator/history를 격리해 가져올 수 있는 조합을 확인하지 못했다.** 현재 규모의 문법은 직접 작성하되, 이후 solver/turn history를 크게 늘리기 전 Adopt → Adapt → Build 조사를 반복한다. 가져올 파일은 없음. parser/evaluator/history는 `modules/rule_rewriting/` 로컬로 두고, 앱 autoload나 전역 의존은 추가하지 않는다.

---

## 1. 완료 정의

다음이 모두 되어야 시스템 1차 완료다.

- 격자 안에 object와 word token을 데이터로 배치 가능
- word token 이동 후 문장을 다시 파싱
- 최소 문법:
  - `NOUN IS PROPERTY`
  - `NOUN IS NOUN`
  - 동일 noun에 복수 property
- 최소 property:
  - YOU
  - PUSH
  - STOP
  - WIN
  - DEFEAT
  - MOVE
- 규칙 변경이 **이미 존재하는 모든 해당 객체에 같은 turn 안에 반영**
- push chain 지원
- 동시에 여러 YOU 지원
- 충돌 결과가 현재 rule set을 사용
- 한 turn undo
- 연속 undo
- reset
- save/load 후 같은 규칙·위치·undo 가능 상태 복원
- 데이터 파일만 바꿔 두 번째 샘플 레벨 생성 가능
- parser/evaluator에 UI/씬 노드 의존 없음

샘플 레벨 2개는 검증용이며 콘텐츠 완료로 계산하지 않는다.

---

## 2. 파일 구조

```
modules/<RULE_MODULE_ID>/
  module_manifest.tres
  entry.tscn
  module.gd

  domain/
    rule_token.gd
    rule_sentence.gd
    rule_set.gd
    grid_entity.gd
    grid_state.gd
    turn_command.gd
    turn_snapshot.gd

  systems/
    rule_parser.gd
    rule_evaluator.gd
    movement_solver.gd
    interaction_solver.gd
    turn_history.gd
    level_loader.gd

  presentation/
    board_view.gd
    entity_view.gd
    hud.gd

  content/
    sample_level_01.tres
    sample_level_02.tres

tests/core/
  test_rule_parser.gd
  test_rule_evaluator.gd
  test_rule_movement.gd
  test_rule_history.gd
  test_rule_module_save.gd
```

shared로 올리지 않는다. 두 번째 실제 모듈에서 재사용이 확인되기 전까지 전부 모듈 로컬이다.

---

## 3. 데이터 모델

### GridEntity

필수 필드:

```text
id: String
kind: StringName
position: Vector2i -> 저장 시 {x:int,y:int}
facing: Vector2i -> cardinal direction, 저장 시 {facing_x:int,facing_y:int}
is_word: bool
word_role: noun | operator | property | none
word_value: StringName
base_tags: Array[StringName]
runtime_tags: Array[StringName]
```

Vector2i 자체는 save_state에 넣지 않는다. JSON dictionary로 encode/decode한다.

### RuleSentence

```text
subject: StringName
operator: StringName
predicate: StringName
source_cells: Array[{x,y}]
```

### RuleSet

파싱 결과만 보유한다.

필수 API:

```text
clear()
add(sentence)
has_property(noun, property) -> bool
transforms_for(noun) -> Array[StringName]
properties_for(noun) -> Array[StringName]
```

씬/UI 참조 금지.

---

## 4. turn 처리 순서

한 입력은 반드시 아래 순서를 따른다.

1. ModuleContext 입력 확인
2. 이동 의도 생성
3. 현재 RuleSet으로 YOU entity 집합 계산
4. MovementSolver가 전체 이동 가능 여부 계산
5. 실제 entity 위치 변경
6. word 배치가 바뀌었으면 RuleParser 전체 재평가
7. NOUN→NOUN transformation 적용
8. 새 RuleSet으로 property 갱신
9. MOVE 등 자동 이동 처리
10. WIN/DEFEAT 등 interaction 평가
11. 최종 state snapshot 확정
12. presentation 갱신

중간 단계마다 scene node를 직접 rule source로 사용하지 않는다. **domain state가 진실이고 화면은 projection**이다.

---

## 5. RuleParser

### 입력
- board width/height
- word entity 목록

### 출력
- RuleSet

### 1차 문법
가로/세로 연속 3-token만 먼저 지원한다.

```
NOUN IS PROPERTY
NOUN IS NOUN
```

parser는:
- 화면 밖 무시
- 빈 칸에서 문장 종료
- 같은 token이 가로·세로 문장에 동시에 사용 가능
- 중복 rule dedupe
- 잘못된 문장은 조용히 무시

### 확장 예약
AND, NOT, HAS, MAKE, ON 등은 1차 범위 밖.
단, parser 내부를 if-chain 하나에 몰아넣지 말고 token stream → sentence validation 단계를 분리해 확장 가능하게 만든다.

---

## 6. MovementSolver

입력:
- GridState
- RuleSet
- entity id
- direction

반환:
```text
can_move: bool
moves: Array[{entity_id, from, to}]
```

규칙:
- PUSH 뒤에 PUSH가 있으면 재귀 chain
- STOP은 push 불가하면 이동 차단
- 여러 entity가 같은 cell을 공유할 수 있음
- YOU가 여러 개면 안정적인 entity id 순서로 처리하되 결과가 iteration order에 의존하지 않도록 테스트
- solver 단계에서 실제 state mutation 금지

---

## 7. Undo

TurnSnapshot은 **입력 직전 상태 전체**를 JSON-safe dictionary로 보관한다.

최소 포함:
- entity positions
- entity kinds
- runtime transform state
- solved/failed
- turn_index

RuleSet은 snapshot에 직접 저장하지 않아도 됨. restore 후 parser로 재생성한다.

history:
- 현재 구현: 64 turn cap
- cap 도달 시 가장 오래된 것 제거
- undo 자체는 새 history를 만들지 않음

---

## 8. module.gd 책임

module.gd만 GameModule 계약을 안다.

책임:
- context 입력을 turn command로 변환
- level loader 호출
- domain/system 조립
- save_state/load_state/migrate_save
- reset
- requested/finished 방출
- presentation에 read-only state 전달

금지:
- rule parsing 직접 구현
- entity마다 노드 검색
- Input singleton 직접 폴링
- AppRoot 참조

---

## 9. 실제 저장 schema v4

```json
{
  "state_format": 4,
  "mode": 1,
  "focus": 0,
  "observed": [true, true, true],
  "active_level_id": "crossing_02",
  "grid": {
    "width": 10,
    "height": 8,
    "entities": [{"id":"...", "kind":"...", "x":1, "y":1,
      "facing_x":1, "facing_y":0, "is_word":false, "base_tags":[], "runtime_tags":[]}]
  },
  "solved": false,
  "failed": false,
  "board_turns": 0,
  "board_attempts": 0,
  "undo_stack": []
}
```

현재 manifest는 `save_version = 4`다. v4 이외 입력은 초기 상태로 돌아간다. 알려진 level 안에서 grid가 깨지면 그 authored level의 기본 grid를 사용하고, entity identity/kind/방향과 clone ID를 검증한다. word token은 빠질 수 없지만 DEFEAT로 제거된 authored object는 없을 수 있다. 변환 상태의 restore 뒤에는 RuleParser를 다시 실행해 RuleSet을 만든다. unknown level ID는 level 진행·grid·history를 섞지 않고 `signal_room_01` 기본 상태로 초기화한다.

---

## 10. 샘플 콘텐츠

### `signal_room_01`
증명 대상:
- BABA IS YOU
- ROCK IS PUSH
- FLAG IS WIN
- word를 밀어 rule을 깨고 복구 가능

### `crossing_02`
증명 대상:
- `LAMP IS ROCK` 변환과 `LAMP IS PUSH`, `ROCK IS MOVE` 연동
- MOVE 순서에서 밀려난 이동 대상의 1회 동작
- 움직이는 단어가 규칙을 바꿀 때의 재파싱
- `FLAG IS WIN`과 `FLAG IS DEFEAT`가 겹칠 때 패배 우선
- 변환 종류·facing·failed 상태의 JSON roundtrip과 undo

이 10×8 레벨은 시스템 증명 fixture다. 현재 `module.gd`는 게임 안에서 레벨을 선택하는 UI를 제공하지 않으며, 테스트가 save state의 `active_level_id`로 진입시킨다.

원작 레벨 복제 금지.

---

## 11. 필수 테스트

### parser
- horizontal/vertical
- invalid sequence
- overlapping sentences
- duplicate
- broken sentence after word movement

### movement
- simple move
- push chain 1/5/20
- blocked chain
- overlapping entities
- multiple YOU
- MOVE 한 칸 이동과 막힘 시 방향 반전
- auto push chain, 밀려난 MOVE 대상은 추가 스텝을 받지 않음
- auto MOVE에 밀린 word token 표시 및 재파싱 신호

### rule transition
- YOU 제거 즉시 제어 상실
- property 추가 즉시 반영
- noun transform
- 복수 transform 출력의 결정성 및 stable ID
- object만 변환하고 word token은 보존
- 한 turn 안의 변환 연쇄 방지
- transform 뒤 parser 안정성
- DEFEAT 제거 후 WIN 평가
- rule 파괴 제어 상실은 실패와 구별

### history
- undo 1
- undo chain
- reset
- save/load 후 undo
- 변환 entity 종류와 facing을 보존하고 failed를 되돌림

### contract
- input disabled일 때 변화 없음
- exit 후 timer/signal 잔존 없음
- save JSON-safe
- 재진입 state restore

---

## 12. 완료 금지 조건

아래면 완료 처리 금지.

- 규칙이 코드에 하드코딩되어 새 noun/property 추가마다 movement code 수정 필요
- word를 움직여도 runtime rule이 재계산되지 않음
- 샘플 레벨 전용 분기 존재
- undo가 위치만 되돌리고 transform/property state를 망침
- 씬 노드 위치가 진실이고 domain state가 없음
- 외부 무라이선스 Baba clone 코드를 복사함
## 시각 구현 계약 — 2026-09-22

### 1차 레퍼런스
Baba Is You의 실제 플레이 화면.

참조:
- 보드가 화면의 절대적인 주인공인 구성
- 규칙 단어와 월드 오브젝트가 같은 공간 규칙 안에 있다는 즉시성
- 작은 수의 색과 강한 실루엣
- 규칙이 바뀐 직후 무엇이 달라졌는지 설명문 없이 읽히는 피드백

복제 금지: 원작 픽셀 자산, 레벨, 캐릭터/단어 디자인.

### 화면 산출물
1. entry
2. normal turn
3. rule rewrite 직후
4. property change 직후
5. win/defeat
6. undo/reset 피드백

보드가 기본 화면 대부분을 차지한다. 개발용 HUD는 두지 않는다.

### at-icons
- noun object, 캐릭터, 장애물은 at-icons 조각을 재조립한 월드 스프라이트
- 원본 아이콘 하나를 그대로 noun 그림으로 쓰지 않음
- word token은 텍스트가 게임 월드 자체이므로 허용
- HUD, undo, reset, win 상태에 icon 사용 금지

### 완료 스크린샷
sample 01 시작 / 규칙 깨짐 / 규칙 재구성 / WIN 직전, sample 02 복수 YOU 상태를 1152×720로 확인한다.

## UI 계약 보완 — 미구현 검수 항목

필수 입력: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). 아래는 보고서 적용을 위한 AI 계획 보완이며 현재 구현 완료 기록이 아니다.

- 소유: 기존 파일 구조의 module/view와 모듈 전용 테스트. parser·movement solver는 UI 노드와 포커스를 참조하지 않는다.
- 표시 입력은 보드 snapshot·평가된 문장·조작 가능한 객체·undo 가능 여부다. 턴/undo/reset/load 뒤 같은 상태에서 같은 보드와 문장 강조를 재구성한다.
- 1차 정보는 조작 객체와 현재 문장, 상세 규칙 설명은 요청 시 표시한다. 미발견 해법·정답 문장을 추천하지 않는다.
- 보드 입력과 undo/reset/귀환 메뉴 입력을 분리한다. 메뉴를 닫으면 기존 보드 조작으로 돌아가고, YOU 소멸 시에도 undo/reset에 접근할 수 있어야 한다.
- 검증: 막힌 이동은 부분 갱신 없음, 문장 파괴→제어 상실→undo 복구, 승리 뒤 undo의 표시 취소, 정지 중 버튼/이동 차단. 긴 noun/확대 시 보드와 하단 안내 충돌을 확인한다.

## 레퍼런스 직접 적용 — 문장이 세계를 바꾸는 시선 경로

[원보고서 분석과 출처](../../docs/UI_REFERENCE_ADAPTATIONS.md)의 Persona 5 시선 유도와 Metaphor 사건별 모션을 Baba Is You 기반 보드에 적용하는 **AI 화면 설계안**이다. UI를 별도 메뉴 게임으로 바꾸지 않는다.

1152×720의 기존 중앙 약 960×576 보드를 유지한다. 평상시 모든 문장과 객체는 읽을 수 있고, 하단에는 undo/reset/귀환의 짧은 텍스트만 남긴다. 문장 성립 피드백을 위한 오른쪽 상태 패널은 추가하지 않는다.

- **선택/이동:** 조작 중인 객체의 발밑 선이나 외곽만 80ms로 강조한다. 메뉴 focus와 월드 조작 강조를 동일한 객체 선택으로 혼동하지 않게 한다.
- **규칙 성립:** Persona 5의 선을 시선 기준으로 삼는 구조를 이용한다. 이번 턴에 새로 성립한 실제 문장 아래에 얇은 기준선이 드러나고, 이어 그 규칙 때문에 바뀐 객체만 짧게 강조한다. 선은 원인인 문장에 붙고 해답 후보·다음 이동 경로를 연결하지 않는다. 기존 문장은 계속 읽히며 화면 전체를 어둡게 하지 않는다.
- **실제 효과:** Metaphor식 강도 차이를 적용해 단순 문장 성립은 140ms, 변환/속성으로 객체가 실제 바뀌면 총 220ms의 원인→결과 강조로 구별한다. 같은 턴의 여러 변화는 순서대로 긴 연출을 쌓지 않고 함께 표시한다.
- **막힘/제어 상실:** 막힌 접촉면에 짧은 정지 피드백. YOU가 없어지면 보드는 그대로 두고 하단 undo 텍스트를 강조한다. 정답 문장은 알려주지 않는다. undo를 실행하면 실제 snapshot 복원 뒤 변경 객체와 문장이 함께 이전 모습으로 돌아오며 성공 표시도 취소된다.
- **reset/성공:** reset 확인은 보드 위 작은 텍스트 확인 면, 초기 focus는 취소. 취소하면 기존 위치로 복귀한다. 승리는 목표 접촉 위치의 반응을 먼저 보이고 귀환 의도를 별도로 받는다. 모션이 끝나야 다음 턴을 허용하는 구조는 금지한다.

시간은 원작 측정값이 아닌 시작 튜닝값이다. 감소 모드에서는 문장 기준선→바뀐 객체 테두리의 정적 상태로 같은 인과를 전달한다. 기준선·객체 강조는 module-local view가 턴 결과에서 계산하며 parser/저장에 장식 상태를 넣지 않는다.

검수 장면: 문장 선택 전 → 단어 밀기 → 새 문장 기준선 → 객체 변환 → 제어 상실 → undo. 구현자는 연속 캡처에서 설명 없이도 “어느 문장이 무엇을 바꿨는지” 추적되는지, 복수 YOU와 연속 입력에서도 강조가 누적되지 않는지 확인한다.
