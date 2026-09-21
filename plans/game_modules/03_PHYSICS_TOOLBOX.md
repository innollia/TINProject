# 계획 03 — 물리 도구 샌드박스 게임형 모듈

공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스: **Mosa Lina**  
목표: 스테이지 몇 개보다 먼저 **도구와 물리 오브젝트를 조합하면 예상하지 못한 해결법이 나오는 상호작용 시스템**을 만든다.

> 작업 ID 미정. 경로 `modules/<PHYSICS_MODULE_ID>/`.

---

## 0. 외부 베이스

### 1차 채택 후보 — HarmonyHoney/tiny_crate2

- Godot **3.5.2**
- GDScript
- MIT
- commit: `ec138031f1a3792d1287f2d4be06e9218e079c87`
- 물리 block-puzzle prototype
- 확인된 구조:
  - `src/actor/Actor.gd`
  - `src/actor/Box.gd`
  - `src/actor/Door.gd`
  - `src/actor/Player.gd`
  - `src/class/ease_mover.gd`
- 원본은 UI/Shared/BG/Cam/Pause/Cutscene/Wipe 등 autoload를 다수 사용

### 채택 원칙

**전체 프로젝트 import 금지.**

Phase 0에서 위 actor/class 코드를 읽고 아래만 판정한다.

가져올 후보:
- actor movement representation
- box interaction
- door/contact logic
- reusable movement helper

버릴 것:
- 모든 autoload
- 원본 UI
- 원본 카메라
- 원본 stage routing
- 원본 assets/content
- input singleton 직접 의존

Godot 3→4 API 차이는 직접 포팅.
MIT 고지를 third-party 문서에 남긴다.

### 추가 조사

Godot 4.x permissive physics-puzzle/toolbox 후보 최소 2개를 더 조사한다.
Godot 4 후보가 Tiny Crate 2보다 좋으면 교체 가능.

---

## 1. 완료 정의

1차 시스템은 다음을 지원.

- player 이동
- rigid/static/trigger object 구분
- pickup 가능 object
- throw
- push/pull
- tool slot
- 최소 4개 tool archetype
- tool과 object 조합
- object damage/break 또는 state change
- pressure/trigger
- door/gate
- goal detection
- soft reset
- hard reset
- 실패 후 deterministic하지 않아도 **안전하게 초기 상태로 복구**
- level definition 교체만으로 두 번째 sandbox 작성 가능
- tool 추가 시 player controller 수정 최소화
- object 종류 추가 시 module.gd 수정 없음

---

## 2. 시스템 철학

Mosa Lina 레퍼런스에서 가져오는 것은 레벨/도구 복제가 아니라:

- 문제보다 도구가 먼저 존재
- 하나의 도구가 여러 물리적 affordance를 가짐
- 설계자가 예상한 유일 정답을 강제하지 않음
- 실패가 빠르고 재시도가 즉각적
- 조합에서 웃긴/창발적 상황 발생

따라서 objective validator는 "정답 행동 순서"를 검사하지 않는다.
**최종 물리 상태/goal condition만 검사**한다.

---

## 3. 파일 구조

```
modules/<PHYSICS_MODULE_ID>/
  module_manifest.tres
  entry.tscn
  module.gd

  domain/
    level_definition.gd
    spawn_definition.gd
    tool_definition.gd
    goal_definition.gd
    object_state.gd

  actors/
    player_controller.gd
    interactable_body.gd
    carryable_body.gd
    breakable_body.gd
    trigger_body.gd
    door_body.gd

  tools/
    tool_base.gd
    tool_context.gd
    impulse_tool.gd
    connector_tool.gd
    placement_tool.gd
    transform_tool.gd

  systems/
    interaction_system.gd
    tool_system.gd
    goal_system.gd
    reset_system.gd
    level_loader.gd
    physics_snapshot.gd

  presentation/
    hud.gd
    tool_view.gd

  content/
    sandbox_01.tres
    sandbox_02.tres

tests/core/
  test_physics_tool_rules.gd
  test_physics_goal.gd
  test_physics_reset.gd
  test_physics_save.gd
```

---

## 4. Tool API

모든 tool은 같은 인터페이스.

```text
can_use(context) -> bool
preview(context) -> ToolPreview
execute(context) -> ToolResult
cancel()
capture_state() -> Dictionary
restore_state(state)
```

ToolContext는:
- origin
- aim direction
- target entity id
- contact point
- world query facade

직접 AppRoot/Input 참조 금지.

### 1차 tool archetype

구체 아트/명칭은 나중에 바꿀 수 있음.

1. **Impulse**
   - target에 힘 적용
   - 물체/플레이어 모두 가능 여부 definition으로 제어

2. **Connector**
   - 두 body 사이 joint/rope류 연결
   - 최대 길이/끊김 조건

3. **Placement**
   - 임시 물체 생성
   - collision-valid 위치만

4. **Transform**
   - 특정 tag object의 physical state 변환
   - 예: solid↔non-solid 등

도구 자체가 퍼즐 정답을 알면 안 됨.

---

## 5. Interactable contract

각 물리 object에 stable entity_id 부여.

공통 메타:
```text
entity_id
tags[]
interaction_flags[]
reset_policy
save_policy
```

interaction은 capability 기반.

예:
- carryable
- pushable
- breakable
- connectable
- tool_target
- trigger_source

class 이름에 의존한 거대한 if chain 금지.

---

## 6. PlayerController

책임:
- 이동
- 점프/낙하가 필요하면 모듈 정의에 따라
- interaction ray/area
- carry anchor
- aim
- held object

금지:
- door 로직
- goal 로직
- tool별 분기
- stage route
- 저장

tool 사용은 ToolSystem에 전달.

---

## 7. ResetSystem

물리 sandbox에서 가장 중요한 기반.

### soft reset
현재 sandbox를 시작 snapshot으로 되돌림.

snapshot에 최소:
- transform
- linear/angular velocity
- enabled
- destroyed/state variant
- spawned runtime objects
- active joints
- player state
- tool state

### hard reset
content definition에서 재생성.

soft reset 실패/불일치 시 hard reset fallback.

Node reference를 snapshot에 저장하지 않는다.
stable entity_id로 복원.

---

## 8. Save 전략

프레임 단위 물리 상태를 무한 저장하지 않는다.

save_state에는:
- level_id
- authored object state 중 persist 대상
- tool inventory/config
- player coarse state
- module-specific progression

현재 chaotic transient physics는 기본적으로 checkpoint/reset 경계에서 정규화해서 저장.

정확한 mid-air restore가 필요해지는 콘텐츠가 생기기 전에는 과설계 금지.

---

## 9. GoalSystem

GoalDefinition 예:

```text
all:
  - entity_in_area(entity/tag, area_id)
  - entity_state(entity, state)
  - trigger_active(trigger_id)
  - player_in_area(area_id)
```

행동 순서 검사 금지.
goal은 최종 상태만 판정.

여러 해법이 같은 condition에 도달하도록 설계 가능해야 함.

---

## 10. 샘플 sandbox

### sandbox 01
목표:
- 상자/문/trigger
- 4 tools 중 2개 제공
- 최소 3개의 실제 해결 경로가 테스트 또는 수동 검수로 가능

### sandbox 02
목표:
- connector + breakable + moving body
- 첫 sandbox와 다른 tool 조합
- reset 중 joint/spawn object cleanup 검증

콘텐츠 양은 최소화.

---

## 11. 테스트

Godot 물리는 headless에서 수치가 흔들릴 수 있으므로 테스트를 나눈다.

### deterministic unit
- tool can_use
- goal predicates
- capability lookup
- snapshot encode/decode
- reset entity matching

### scene integration
- pickup/drop
- impulse
- connector create/remove
- break
- trigger→door
- reset 후 entity count 동일

### stress
- reset 50회
- spawn/remove 200개
- connector 반복 생성/삭제
- exit/re-enter 후 orphan node 없음

### contract
- input disabled
- pause
- transition
- save JSON-safe

---

## 12. 외부 코드 포팅 체크리스트

Tiny Crate 2를 사용할 경우:

1. 대상 파일별 원본 commit 기록
2. LICENSE 고지 추가
3. Godot 3 class API를 Godot 4.7.2로 포팅
4. autoload reference 제거
5. Input 직접 접근 제거
6. scene routing 제거
7. TIN module-local 경로로 이동
8. 원본 art/audio를 기본적으로 가져오지 않음
9. port 직후 원본 동작 parity test
10. 그 다음 TIN capability 구조로 리팩터링

한 번에 포팅+대규모 리팩터링 하지 않는다.

---

## 13. 완료 금지 조건

- tool 4개가 사실상 "정답 버튼"임
- stage별 해결 순서를 코드로 검사
- reset 때 queue_free 누락으로 물체/joint가 쌓임
- player.gd에 모든 object/tool 로직이 몰림
- Tiny Crate 2 전체 autoload 구조를 TIN에 이식
- 물리 콘텐츠 하나만 동작하고 두 번째 level definition이 안 됨
## 시각 구현 계약 — 2026-09-22

### 1차 레퍼런스
Mosa Lina의 실제 플레이 화면.

참조:
- 플레이 공간이 거의 전 화면을 차지
- 도구와 물체가 실루엣만으로 구분
- 작은 HUD 의존도
- 실패 후 빠른 재시도 리듬

### 화면 산출물
1. level entry
2. tool acquire/select
3. tool use
4. chain interaction
5. failure/reset
6. solved

### at-icons
- 플레이어, 물체, 장치, 지형 장식은 collage
- tool icon을 HUD slot에 넣지 않음
- 현재 tool 표시는 짧은 text 또는 실제 월드 오브젝트 표현
- 원래 의미가 도구인 icon을 그대로 같은 도구로 사용 금지

### 완료 스크린샷
각 샘플 레벨 entry / interaction / failure / solved를 1152×720로 확인한다.
