# 계획 01 — 규칙 재작성 게임형 모듈

공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스: **Baba Is You**  
목표: 레벨 하나가 아니라 **텍스트/오브젝트가 런타임 규칙을 구성하고 그 규칙이 즉시 세계 동작을 바꾸는 시스템**을 만든다.

> 작업 ID는 아직 사용자 확정이 아니다. 코드 경로는 구현 시작 시 `modules/<RULE_MODULE_ID>/`로 결정한다.

---

## 0. 외부 베이스 조사

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

### 구현 시작 전 추가 조사

최소 1개 이상의 **명시적 permissive-license Godot 소스**를 더 찾는다.

선정 기준:
- rule sentence parsing이 데이터와 분리되어 있을 것
- word 이동 후 rule recompute가 있을 것
- undo 또는 turn snapshot 구조가 있을 것
- 원작 자산/레벨/문구를 가져오지 않아도 핵심 엔진만 분리 가능할 것

적합 후보를 찾으면 rule parser/evaluator/state history만 가져오고 UI/레벨/원작 자산은 버린다.

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
- 기본 128 turn cap
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

## 9. 저장 schema v1

```json
{
  "level_id": "sample_01",
  "turn_index": 14,
  "entities": [...],
  "history": [...],
  "solved": false
}
```

load 시:
1. 타입 검증
2. 숫자 int 정규화
3. entity id 중복 검사
4. board 범위 검사
5. history cap 적용
6. parser 재실행
7. presentation 생성

손상 state는 초기 레벨로 fallback하되 SCRIPT ERROR를 내지 않는다.

---

## 10. 샘플 콘텐츠

### sample 01
증명 대상:
- BABA IS YOU
- ROCK IS PUSH
- FLAG IS WIN
- word를 밀어 rule을 깨고 복구 가능

### sample 02
증명 대상:
- 복수 YOU
- NOUN IS NOUN transform
- STOP/PUSH 상호작용
- undo 연속 5회

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

### rule transition
- YOU 제거 즉시 제어 상실
- property 추가 즉시 반영
- noun transform
- transform 뒤 parser 안정성

### history
- undo 1
- undo chain
- reset
- save/load 후 undo

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
