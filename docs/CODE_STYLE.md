# 코드 규칙

- 엔진은 Godot **4.7.2**로 고정한다. typed GDScript, 탭 들여쓰기, 명시적 매개변수·반환·변수 타입을 사용한다.
- 파일·함수·변수는 `snake_case`, 공유 계약·서비스의 `class_name`은 `PascalCase`다.
- 요청 없이는 코드 주석을 추가하지 않는다. 결정은 문서에 남긴다.

## 경계

- 노드 소유권을 명확히 한다.
- GameModule은 다른 GameModule/app/meta 구현을 직접 참조하지 않는다.
- core는 구체 Kit/장르/module ID를 알지 않는다.
- `/root` 탐색, 서비스 로케이터, 범용 EventBus, 승인 없는 autoload를 금지한다.
- shared는 두 실제 사용처에서 동일한 의미와 계약이 확인된 뒤에만 추출한다.
- Kit 전체를 공용 framework API로 만들지 않는다.

## Domain / Presentation

- domain state가 게임 상태의 진실이다.
- UI node, Label text, ColorRect 색, Sprite 위치를 장르 규칙 판정의 source of truth로 사용하지 않는다.
- presentation은 state를 표시하고 intent를 방출한다.
- animation/tween/focus/hover는 진행 상태와 분리한다.
- 입력은 InputMap action과 ModuleContext를 통해 해석한다. domain에 물리 키를 하드코딩하지 않는다.

## Authored Content

새 level/location/event/NPC/item 등 authored content는 계획에 정의한 data/Resource/scene 형식으로 추가한다.

장르 공통 core에 다음 냄새가 생기면 중단한다:
- content ID별 `if`/`match`
- 특정 level 이름을 아는 movement/parser/combat
- 새 콘텐츠 하나 때문에 save schema/core algorithm을 반복 수정
- presentation object 이름을 이용한 게임 판정

전용 editor tool은 기본 완료조건이 아니다.

## 저장

- 저장은 버전이 있는 JSON 호환 값만 사용한다.
- core는 module state를 불투명하게 취급한다.
- dictionary 경계를 넘는 snapshot은 깊은 복사한다.
- Node/Resource/Callable/Vector/NaN/Inf를 save payload에 넣지 않는다.
- stale/invalid content ID의 처리 정책을 Kit 계획에 적는다.

## 비동기/수명

- 전환의 `busy`와 입력 잠금을 존중한다.
- exit 시 자신이 만든 timer/signal/reference를 정리한다.
- load/enter 순서를 임의로 바꾸지 않는다.
- module child의 process mode 계약을 깨지 않는다.

## UI 코드

- 상시 Shell HUD를 전제로 코드를 짜지 않는다.
- Control 레이아웃은 anchor/Container 우선.
- grid/board처럼 게임 규칙상 좌표가 중요한 월드는 별도 layout 계산을 사용한다.
- focus는 명시적 상태로 다룬다.
- placeholder ColorRect/Label을 월드 오브젝트의 최종 표현으로 남기지 않는다.
- 새 이미지 자산의 출처와 라이선스 기준은 `docs/VISUAL_DIRECTION.md`에 기록한다.

## 의존성

- 명시적 승인 없이 패키지/플러그인을 추가하지 않는다.
- GUT 9.7.1은 기존 테스트 의존성이다.
- vendor 코드는 임의 수정하지 않는다.
- 외부 코드 채택 전 license/version/global dependency를 확인한다.
- LICENSE가 확인되지 않는 코드는 복사하지 않는다.

## 작업 소유권

- 한 작업자는 한 담당 폴더/소유 범위만 수정한다.
- 다른 작업자의 파일이나 무관한 파일은 수정하지 않는다.
- API 변경은 먼저 조율한다.
- `.godot/`와 build artifact는 제외하되 소스 `.uid`, `.tscn`, `.tres`는 추적한다.
- 비밀값과 사용자 저장 파일을 커밋하지 않는다.

## 검증

검증 명령은 루트 `AGENTS.md`를 따른다.

- 실행하지 않은 테스트를 통과했다고 기록하지 않는다.
- 자동 테스트 통과를 화면/Kit 완료로 번역하지 않는다.
- Kit 완료는 `docs/KIT_WORKFLOW.md`의 수동 Reference Game/해상도/플레이 검수를 별도로 통과해야 한다.
