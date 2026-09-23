# 계획 03 — 물리 도구 샌드박스 게임형 모듈

## 현재 구현에서 이어가는 보완 P1

**구현 기록(2026-09-22 P1 수직 슬라이스):** `modules/physics_toolbox/module.gd`는 RigidBody2D에 impulse/freeze를 적용하고, 별도 JSON 좌표/속도 snapshot으로 물체 상태를 보존한다. 두 배치 순서 `[0,1,2]`/`[2,1,0]`를 허용하되 placement order·접촉·목표 영역(`x >= 596`)을 함께 검사한다. 도구 매핑만 맞고 물체가 목표에 닿지 않은 복원 상태는 `goal_unreached`로 실패한다. 센서 노드/반복 reset/두 번째 레벨은 아직 남아 있다.

**AI 구현 제안 — 우선 산출물**
1. `systems/goal_evaluator.gd`와 `content/sample_level_01.tres`: 목표 물체 ID·goal 영역·필요 접촉·유지 시간으로 성공을 판정한다. 도구 사용 순서/assignments는 정답 조건이 아니다.
2. 기존 세 도구로 서로 다른 두 해결을 만들고, 같은 도구 배치라도 실제 목표 미도달이면 실패하는 fixture를 만든다.
3. 안전 reset과 snapshot codec을 완료한 뒤 아래 4 archetype·잡기/던지기·두 번째 레벨 범위로 넓힌다. 한 번에 모든 도구를 추가하지 않는다.

**저장 전환:** manifest v2. 저장할 body는 stable ID, 위치 {x,y}, 회전, 선속도 {x,y}, 각속도, freeze/sleeping, 파손 상태를 가진다. joint/생성 물체는 definition ID로 복원하며 Node 참조를 저장하지 않는다. v1 assignments/impulses는 legacy 초기 배치로 이관하고 정확한 과거 궤적을 복원했다고 주장하지 않는다. 기존 완료는 legacy completion으로 보존하며 새 레벨의 물리 성공으로 승격하지 않는다.

**reset 순서:** 입력 차단→물리 갱신 경계에서 freeze→생성 물체/신호 정리→정의로 재생성→snapshot 또는 초기값 적용→센서 상태 재계산→다음 물리 경계에서 재개. 초기화 도중 goal 신호는 성공을 발생시키지 않는다. exit/re-entry와 메뉴 pause에서도 물체가 몰래 이동하지 않는지 확인한다.

**실패 검증:** 물체 낙하/영역 이탈, joint 대상 제거, 깨진 저장 body ID, 반복 reset 후 노드·신호 증가 없음, 움직이는 중 저장·복원, 두 물체 접촉 중 복원. 고정 물리 step과 허용 오차로 범위/접촉을 검사하며 exact float 궤적 일치를 요구하지 않는다. 정답 도구 배치만 넣고 목표 밖에 둔 상태는 반드시 미완료다. 전용 테스트 `tests/core/test_physics_goal.gd`, `test_physics_reset.gd`, `test_physics_save.gd`를 추가한다.

**화면 실행 브리프:** Mosa Lina의 플레이 공간·실루엣 화면을 확인한다. 중앙 약 1000×560에 물체/받침/도착 영역, 하단에는 선택 도구의 이름만 둔다. 첫 초점은 물체 사이 힘 전달 경로다. 도구 선택→사용→실제 이동→막힘→다른 해법→목표 도달→reset을 캡처한다.

**레퍼런스 출처:** Human: Fall Flat은 기존 구현 기록, Mosa Lina는 기존 확장 계획의 방향이다. 후자를 새 사용자 확정으로 쓰지 않는다. 새 subsystem 포팅 전 기존 외부 후보/Asset Library를 재조사하며 조사 전 Tiny Crate 채택 완료로 표기하지 않는다.


공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스: **Mosa Lina**  
목표: 스테이지 몇 개보다 먼저 **도구와 물리 오브젝트를 조합하면 예상하지 못한 해결법이 나오는 상호작용 시스템**을 만든다.

> 기존 구현 ID는 `physics_toolbox`다. 아래 `<PHYSICS_MODULE_ID>`는 이 경로를 뜻한다.

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

## UI 계약 보완 — 미구현 검수 항목

필수 입력: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). 아래는 AI 계획 보완이다.

- 소유: 모듈 로컬 도구 선택/피드백 view와 물리 모듈 테스트. 위치·접촉·센서 상태가 결과의 진실이며 도구 버튼의 선택 상태는 성공 판정이 아니다.
- 플레이 공간과 물체 반응이 1차 정보다. 현재 도구명/실행 불가 이유는 짧은 텍스트로, 사용 설명은 선택 시 표시한다. UI 아이콘이나 성공 라벨로 물리 결과를 대체하지 않는다.
- 도구 선택→대상 지정→작용 의도를 명시한다. 선택 메뉴 취소 시 도구를 발동하지 않고 월드 조작으로 복귀한다. soft/hard reset과 저장 복원 후 사라진 대상 참조를 제거한다.
- 검증: 대상 없음/삭제·실패 접촉·목표 밖 결과·정지 중 작용 차단·복원 후 선택 초기화. 메뉴는 세 입력 장치로 확인하고, 월드 조작의 장치별 매핑은 실행 전에 별도 표로 확정한다.
- 물리 상태의 실시간 표시와 이벤트성 안내 갱신을 구분한다. 대표/최대 물체 수의 프레임 예산 실측 없이 UI 또는 물리 성능 완료를 선언하지 않는다.

## 레퍼런스 직접 적용 — Dead Space형 대상 부착 정보와 도구 선택

[보고서 적용 지도](../../docs/UI_REFERENCE_ADAPTATIONS.md)의 Dead Space RIG/무기/인벤토리 문맥, 액션 quick-select, Metaphor 실패/확정 강도를 Mosa Lina형 전 화면 물리 공간에 적용하는 **TIN 설계안**이다.

평상시 플레이 공간을 거의 전 화면으로 두고 현재 도구명은 하단 짧은 텍스트 하나로 남긴다. 대상이 없으면 긴 설명/도구 목록은 닫힌다. 물체를 선택하면 해당 물체 가까이에 도구명과 “사용/대상 변경/취소” 텍스트가 붙는다. 화면 끝에서는 안내가 안쪽으로 이동하며 물체를 덮지 않는 쪽을 택한다. 세계 장치의 작동/비작동은 실제 장치 형태로 먼저 읽힌다.

도구 선택 입력을 누르면 현재 대상 옆에 사용할 도구 이름들을 세로로 펼친다. focus 시 그 도구의 작용 요약 한 줄을 같은 면 아래에 보이고, 확인하면 목록을 접은 뒤 대상 지정 상태가 된다. 취소하면 이전 도구와 대상이 유지된다. 메뉴 조작 중 물체에 힘을 가하지 않는다. 도구 수가 늘어도 전체 화면을 인벤토리로 교체하지 않고 선택 목록만 스크롤한다.

대상 지정 중에는 적용 물체의 외곽과 실제 작용 지점이 먼저 보인다. 실행 불가 시 이미 알 수 있는 이유(대상 없음, 지원하지 않는 물체 등)를 그 위치 옆에 남긴다. 목표까지 정답 궤적을 그리거나 성공 여부를 미리 예측하는 표시는 하지 않는다. 읽기 어려우면 “설명” 동작으로 같은 정보의 정적인 텍스트 면을 열 수 있다. 이는 Dead Space식 세계 결합 표현의 접근 가능한 보충 경로다.

확정은 140ms 대상 테두리, 실패는 짧은 접촉부 반응과 원인 텍스트, 성공은 목표 센서/장치의 실제 상태 변화다. 실패 후 전 화면 팝업을 띄우지 않아 바로 다른 대상/도구/reset을 선택할 수 있게 한다. reset 확인을 닫으면 이전 도구 선택으로, reset 실행 후에는 새 세계의 유효 대상으로 돌아간다. 스냅샷 복원 시 낡은 물체를 향하는 안내가 남으면 실패다.

검수: 대상 없음→선택→도구 변경→취소→작용, 화면 가장자리 물체, 연쇄 충돌 중 안내 위치, 목표 밖 실패→즉시 재시도, 감소 모드. 대상 설명은 로컬 view 하나가 갱신하고 물리 결과는 센서/상태에서만 받는다. HP/탄약/쿨다운 시스템을 이 패턴을 위해 추가하지 않는다.
