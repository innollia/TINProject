# Kit 01 — Rule Rewrite

공통 계약: `docs/KIT_WORKFLOW.md`

## 0. Kit 목적

한 게임 안에서 **격자형 규칙 재작성 퍼즐 장르**로 전환해야 할 때 즉시 사용할 기반을 만든다.

이 Kit의 Reference Game은 독립 작품을 늘리기 위한 것이 아니라 parser/evaluator/movement/history/presentation/content pipeline이 실제 플레이에서 함께 작동함을 검증한다.

## 1. Primary Reference — 하나

**Baba Is You — Hempuli Oy**

공식 reference:
- Steam: https://store.steampowered.com/app/736260/Baba_Is_You/

공식 설명에서 확인되는 핵심:
- 규칙 자체가 상호작용 가능한 block으로 존재한다.
- block 조작으로 현재 level의 작동 규칙이 바뀐다.
- 200개가 넘는 level이 같은 중심 문법을 여러 방식으로 변주한다.

이 Kit에서 가져올 것은 바로 이 **공간 안의 규칙 조각 → 즉시 world rule 재평가 → 여러 authored level로 변주** 구조다.

### 1.1 상태별 실제 화면 증거

구현 시작 전에 Steam media/trailer 또는 동일한 공식/신뢰 가능한 실제 플레이 자료에서 아래 상태를 각각 확인하고 작업 메모에 캡처/타임코드를 남긴다.

| 상태 | 확인할 것 | TIN 적용 |
|---|---|---|
| first playable board | board가 화면에서 차지하는 비율, cell 규격 | 보드가 절대적 focal point |
| normal turn | object/word의 cell alignment | 정각 grid |
| word push | 밀기 전후 위치와 한 턴 감각 | 한 입력 = 한 grid step |
| rule broken/reformed | 문장 변화와 world 변화의 거리/순서 | 원인 문장→영향 object |
| multiple controllables | 같은 property가 여러 object에 적용되는 표현 | multi-YOU |
| blocked/failure | 실패가 보드를 덮지 않는 방식 | 작은 현장 feedback |
| undo/reset | 실험을 빨리 되돌리는 흐름 | toolbar 없이 action으로 접근 |
| level transition | 한 level의 규칙과 다음 level의 독립 | data-driven level loader |

이 표의 실제 캡처/타임코드가 없으면 presentation 구현을 시작하지 않는다.

### 1.2 강하게 따라갈 것

- 모든 핵심 플레이가 정각 격자에서 읽히는 보드 구조
- word와 object가 같은 cell 규칙을 공유하는 즉시성
- 한 입력 = 한 턴의 명확한 이동 감각
- 규칙 문장의 공간적 가독성
- PUSH/STOP/YOU/WIN/DEFEAT 등 property 변화가 곧바로 월드에 반영되는 인과
- undo/reset이 퍼즐 실험을 방해하지 않는 접근성
- 플레이 공간이 화면의 주인공이고 HUD가 거의 없는 정보 위계
- 셀 하나의 위치관계가 판단에 중요하므로 ASCII/비정각 텍스트 보드로 축약하지 않음

### 1.3 복제하지 않을 것

- 원작 캐릭터/오브젝트 아트
- 원작 고유 레벨 배치
- 원작 문구/스테이지 이름
- 원작 팔레트와 픽셀 자산의 직접 복제

## 2. 현재 코드 판정

살릴 수 있는 후보:
- `domain/grid_entity.gd`
- `domain/grid_state.gd`
- `domain/rule_sentence.gd`
- `domain/rule_set.gd`
- `systems/level_loader.gd`
- `systems/movement_solver.gd`
- `systems/rule_parser.gd`
- `systems/rule_evaluator.gd`
- 현재 save/undo/transform 동작

재검증 조건:
- sample level ID 전용 분기 없음
- presentation node를 판정에 사용하지 않음
- 새 noun/property를 넣기 위해 movement/evaluator의 장르 공통 코드를 고치지 않음
- JSON level만 바꿔 여러 레벨을 로드할 수 있음

버릴 것으로 간주:
- 현재 `module.gd`의 ColorRect/Label 기반 보드 표현
- 상단/하단 설명문 중심 UI
- 정각 셀로 읽히지 않는 텍스트/ASCII식 표현
- 세 표찰 조사 같은 Reference Game 앞단의 임시 콘텐츠

## 3. Reference Game 분량

최소 **10분 이상**.

콘텐츠 단위는 **level**이다. 최소 8개 authored level을 만든다. 플레이테스트에서 10분을 못 넘으면 레벨을 늘리거나 퍼즐 구성을 보강한다.

레벨군:
1. YOU / PUSH / STOP 소개
2. 문장 끊기와 복구
3. WIN 위치 재해석
4. 복수 YOU
5. NOUN IS NOUN 변환
6. MOVE와 방향 반전
7. DEFEAT와 WIN 우선순위
8. 여러 규칙을 동시에 재작성하는 종합

각 레벨은 같은 loader/parser/evaluator/movement/history를 사용한다. 특정 레벨 때문에 core system에 분기를 추가하면 실패다.

## 4. 데이터 모델

level data:
- stable level id
- width / height
- entities[]
- spawn/facing
- word metadata
- optional presentation metadata

entity:
- stable id
- kind
- integer grid x/y
- facing
- is_word
- word_role
- word_value
- base tags

runtime:
- current level id
- grid state
- evaluated RuleSet
- solved / failed
- turn index
- undo stack

씬 노드 위치는 진실이 아니다.

## 5. 턴 처리

1. ModuleContext에서 action 확인
2. 방향 intent 생성
3. 현재 RuleSet의 YOU 집합 계산
4. 전체 movement plan 계산
5. state mutation
6. word 위치 변화 시 parser 재평가
7. NOUN→NOUN transform
8. property 갱신
9. MOVE 처리
10. DEFEAT
11. 살아남은 YOU의 WIN
12. snapshot 확정
13. presentation 갱신

부분 이동/부분 transform이 남으면 실패다.

## 6. Presentation

보드는 **정각 cell**로 렌더한다.

- cell pixel size는 viewport에서 계산하되 x/y가 같은 크기
- board 전체가 화면의 1차 초점
- object와 word 모두 cell 중심 정렬
- word는 실제 텍스트 타일로 표현 가능
- noun object는 at-icons 조각을 2개 이상 재조립해 sprite로 만든다
- 원본 icon의 픽토그램 의미가 먼저 읽히지 않게 변형
- rule 변화 직후 원인 문장과 영향을 받은 object만 짧게 피드백
- 별도 “현재 규칙 목록” 상시 패널 금지
- 방향키/Z/X 설명문 금지
- debug turn/rule label 금지

undo/reset/나가기는 보드를 가리는 상시 toolbar를 만들지 않는다. 필요한 물리 키는 장르 전환 Input Bubble에서 학습한다.

## 7. Input

Reference Game intent:
- up/down/left/right
- undo
- reset
- pause

물리 키는 앱 InputMap에서 매핑하고 domain에는 전달하지 않는다.

이 Kit로 진입하는 전환에서 이전 장르와 required physical key set이 다르면 Input Bubble이:
- 계속 필요한 기존 키를 복구
- 새 키를 아래에서 올림
- 더 이상 필요 없는 키를 popped 흔적으로 유지
한다.

## 8. 저장/복구

필수:
- active level id
- grid/entity state
- facing
- transform state
- solved/failed
- turn index
- undo snapshots

검증:
- save → load 뒤 같은 입력에 같은 결과
- transform 뒤 save/load
- multi-YOU
- MOVE
- DEFEAT/WIN
- undo chain
- malformed level은 해당 authored default로 안전 복구
- unknown level id는 명시된 초기 level로 복구

## 9. 해상도

실제 캡처:
- 1280×720
- 1920×1080
- 2560×1440

세 해상도에서:
- cell이 정각
- board가 잘리지 않음
- word가 겹치지 않음
- 가장 긴 word token도 cell 규칙을 깨지 않음
- 최소 UI가 보드를 가리지 않음

## 10. 자동 테스트

- parser horizontal/vertical/overlap/invalid
- push chain
- blocked movement atomicity
- multiple YOU
- property add/remove immediate effect
- noun transform
- MOVE
- DEFEAT before WIN
- undo/reset
- save/load
- 8개 level load
- level data 추가만으로 registry가 확장되는지

## 11. 수동 플레이 과제

사용자는 설명문 없이:
1. 조작 가능한 대상을 찾는다.
2. word를 밀어 규칙을 바꾼다.
3. 규칙 변화가 object에 반영됐음을 알아차린다.
4. 실수 후 undo한다.
5. reset한다.
6. 최소 8개 level을 연속 플레이한다.

관찰할 것:
- 셀 위치를 헷갈리는가
- 무엇이 YOU인지 읽히는가
- 규칙 변경 원인/결과가 붙어 보이는가
- UI가 보드보다 먼저 보이는가
- 설명문이 없어도 실험이 가능한가

## 12. 금지 shortcut

- ASCII 보드
- 비정각 grid
- ColorRect+Label을 object 완성 표현으로 사용
- 레벨별 if/match 분기
- 해답/다음 규칙을 HUD가 알려줌
- 상시 키바인드 문장
- “테스트가 통과했으므로 화면 완료” 판정

## 13. 완료 증거

- 상태별 Primary Reference 캡처/타임코드 기록
- 8개+ authored level
- 실측 플레이 10분+
- 720p/FHD/QHD 캡처
- parser/movement/save 테스트 통과
- 새 9번째 level을 data만 추가해 동작시키는 검증
- 사용자 플레이 **검토 준비 완료**

사용자 실제 검토 전에는 최종 완성이라고 쓰지 않는다.
