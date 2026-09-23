# 계획 05 — 기묘한 로드 어드벤처 게임형 모듈

## 현재 구현에서 이어가는 보완 O1

**구현 기록(2026-09-22 O1 수직 슬라이스):** `module.gd`의 LOCATION_IDS/TARGETS와 대상별 match가 4지역을 처리한다. 기존 붉은 벌레→바늘→사당→역 경로를 유지하면서, 안내인 재회 뒤 붉은 실을 역 문에 써서 사당을 건너뛰는 `station_threaded` 우회 경로를 추가했다. event history, path variant, resolution status/attempts를 저장하고 사용할 수 없는 아이템 사용은 사건 상태를 바꾸지 않는다. 지역/사건 Resource registry와 validator, authored 지역 증산은 아직 남아 있다.

**AI 구현 제안 — 구현 단계**
1. `content/locations/`, `items/`, `events/`에 현재 4지역을 그대로 추출하고 `systems/content_validator.gd`에서 중복 ID·끊긴 route·없는 NPC/대상·효과 참조를 검사한다. 잘못된 데이터는 기존 registry를 교체하지 않는다.
2. `resolution_system.gd`에 `evaluate(requirements,state)`와 `apply(effects,state)`를 둔다. 효과 전체의 유효성을 확인한 뒤 한 번에 반영한다. 실패한 아이템 사용은 물건을 소모하거나 부분 flag를 남기지 않는다.
3. 같은 초기 상태에서 사건 A/B를 각각 먼저 풀 수 있는 별도 fixture를 추가한다. 현재 라우트를 임의로 철회하지 않고 신규 side event로 증명한다.
4. NPC actor/선택 대상 목록은 npc_states.location/availability로 만든다. NPC가 떠난 장소에는 인물 대신 부재 흔적을 보이고, 재회 시 상태가 이어지게 한다.
5. 이후에만 아래 45~90분 authored slice를 증설한다. 현재 네 지역을 그 분량으로 완료 처리하지 않는다.

**저장 전환:** manifest v1→v2에서 current_location 인덱스를 기존 LOCATION_IDS 순서의 stable ID로 변환한다. inventory/knowledge/notes/NPC/사건 상태를 유지한다. world_flags와 event_states에 중복된 값은 사건 상태를 진실로 삼고 route를 재계산하는 대응표를 먼저 테스트한다. 알 수 없는 지역은 마을로 복귀하되 살아 있는 아이템·다른 지역 기록까지 삭제하지 않는다.

**실패/재검토:** 아이템 없는 사용, 사용할 수 없는 대상, 이미 해결한 사건 반복, NPC 이동 뒤 선택 유지, 지역 데이터 제거 후 load, 같은 아이템의 두 맥락 사용, A→B/B→A 해결, 대화 도중 exit, 잘못된 effect의 원자적 취소를 `tests/core/test_odd_road_content.gd`에 추가한다. 기존 `test_odd_road_adventure.gd`를 회귀 기준으로 유지한다.

**설정 경계:** 현재 사당의 귀환/방문 해석과 각 지역명은 구현 선택이다. 사용자 소재인 먹여서 뚱뚱해지는 수호신을 철회한 결정으로 취급하지 않는다. authored 확장에서는 음식 사용→형태 변화·주민 반응을 해당 기존 소재와 대조하고, 현재 벌레 재사용 fixture를 별도 보존한다. 공룡/감자·환생 왕녀와의 결합은 미정이다.

**화면 실행 브리프:** West of Loathing의 장소 조사/대화 화면을 확인한다. 월드 약 900×540과 하단 텍스트 대화, 필요할 때만 인벤토리/노트 패널을 연다. 첫 장면에서 위치 선택 라벨이 아니라 길·인물·사물이 보이게 한다. 마을/바늘 내부/사당/역 각각 첫 진입과 재방문 변화를 캡처한다. 실제 이동 컨트롤러 도입은 기존 베이스 감사에 없는 새 subsystem이므로 조사 후 별도 단계로 수행한다.


공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스 방향: **West of Loathing 계열**  
작업명: **ODD_ROAD_ADVENTURE**  
정식 작품명: 미정

현재 구현 ID: `odd_road_adventure` (작업명을 사용한 AI 구현 기본값이며, 정식 작품명은 아직 미정)

현재 상태(2026-09-22): 4개 지역에서 동일한 조사·아이템 사용·NPC·사건·지식 문법을 검증한 1차 시스템 슬라이스. 저장 복원과 재방문 테스트는 통과했으나, 아래 30분~8시간 authored content 목표나 플레이테스트 게이트를 완료한 단계는 아니다. 구현 범위와 외부 베이스 검토는 `docs/odd_road_base_audit.md`에 기록했다.

## 1. 목표

하나의 지속적인 어드벤처 문법으로 여러 지역·NPC·아이템·기묘한 사건을 수용하는 게임형 모듈.

최근 아이디어 덤프는 필수 canon이 아니다.  
이 게임에 자연스럽게 맞는 조각만 콘텐츠 후보로 사용한다.

## 2. 지속 플레이 문법

게임 전체에서 유지:

- 이동
- 조사
- 대화
- 줍기
- 모듈 로컬 인벤토리
- 대상에 아이템 사용
- 기록/메모 확인
- 장소 이동
- 취소/뒤로

필요한 경우 탈것·간단한 환경 조작을 추가할 수 있으나 기본 문법을 대체하지 않는다.

기본 흐름:

```text
지역 도착
→ 환경/NPC/사건 조사
→ 대화·아이템·지식·지역 상태로 상황 변화
→ 다른 지역/NPC/경로에 결과 반영
→ 병렬 사건 진행 및 재방문
```

## 3. 세계 구조

모듈 내부:

```text
AdventureModule
  ├─ WorldMap
  ├─ LocationHost
  ├─ AdventureState
  ├─ Inventory
  ├─ Knowledge
  └─ NPC/Event state
```

지역은 동일 모듈 런타임 안에서 교체한다.

지역 후보:
- 작은 마을
- 길가 시설
- 농장
- 사막
- 폐건물
- 사당
- 동굴
- 특이한 상점
- 이상한 기관

장거리 이동은 지도 전환으로 압축 가능.

## 4. 상태

`AdventureState`:

```text
current_location
spawn_id

inventory[]
knowledge[]
notes[]

world_flags{}
location_states{}
npc_states{}
event_states{}
route_states{}
```

모듈 로컬 돈·아이템·장비·지역 평판·사건 상태는 다른 TIN 게임으로 전달하지 않는다.

## 5. 아이템

`ItemDefinition`:

```text
item_id
display_name
description
tags[]
usable_targets[]
persistent
stack_policy
```

주요 아이템은 가능하면 둘 이상의 맥락에서 재사용한다.

예:
- 직접 사용
- NPC에게 보여주기
- 다른 장소에서 재사용
- 정보/대화 변화

## 6. NPC

`NPCState`:

```text
npc_id
location
relationship_state
conversation_state
known_events[]
inventory_refs[]
availability
```

NPC는:
- 이전 사건을 기억
- 다른 장소로 이동 가능
- 재회 시 상태 반영
- 사건 결과에 따라 대화/행동 변화

대화는 기존 `TinIntegrationKit`을 우선 사용한다.

## 7. 사건과 해결

`EventDefinition`:
- event_id
- location_id
- trigger requirements
- visible state
- resolution ids
- result effects

`ResolutionDefinition`:

```text
requirements[]
effects[]
optional_text
```

해결 자원:
- 관찰
- 대화
- 아이템
- 지식
- 지역 상태
- 다른 NPC/사건 결과

하나의 사건에 복수 resolution을 둘 수 있다.

## 8. 지식

`KnowledgeEntry`:
- id
- observation text
- tags
- source
- discovered

재사용 가능한 정보 예:
- 생물 습성
- 기관 규칙
- NPC 버릇
- 물건의 실제 용도
- 지역 간 인과

TIN global records에는 프로젝트 차원에서 남길 가치가 있는 관찰만 보낸다.

## 9. 첫 authored slice — 45~90분

### 시작 지역 — 작은 마을

포함:
- 반복 NPC 4~6명
- 조사 가능한 대상 12+
- 병렬 side thread 3+
- 재방문 시 변하는 대상 2+
- inventory
- 지역 출구
- 기록

수치는 구현용 기본값이며 사용자 canon이 아니다.

### 근거리 지역 A

- 아이템 사용 사건
- 결과가 마을에 반영

### 근거리 지역 B

- 아이템 없이 지식/NPC 정보로 해결 가능한 사건
- A와 순서 자유

### 근거리 지역 C

- A/B 결과에 따라 반응 변화
- 선행 완료 없이도 방문 가능

### slice 검증

첫 90분 안에:
- 같은 아이템을 서로 다른 맥락에서 2회 사용
- 같은 NPC 재등장 1회+
- 같은 지역 재방문 후 상태 변화 확인
- 이전 지식 재사용 1회+
- 병렬 진행 사건 2개+
- 처음 배운 입력으로 이후 콘텐츠 대부분 플레이

## 10. 콘텐츠 후보

아래는 **사용 가능 예시**이며 필수 canon 아님.

### 수호신 사당
기존 inventory/use 문법으로 음식 사용 → 외형/주민/지역 상태 변화.

### 붉은 행운벌레
조사·observation·소문·생존 사건과 연결.

### 사막의 바늘
세계지도에서 발견하는 숨은 location. 바늘구멍 안 방으로 진입.

### 우마왕 사건
소에게 경 읽는 인물을 여러 시점에 반복 방문하는 event chain.

### 공룡/감자
전면 테마로 채택할 경우:
- 공룡 = 반복 사용하는 이동/field 요소
- 감자 = 반복 등장 hazard/faction/object

## 11. 외부 베이스

### GDQuest Godot Open RPG

- repository: `gdquest-demos/godot-open-rpg`
- tag: `0.4.0`
- commit: `ff4f907d71385d459e64383f799700e998518153`
- license: MIT
- Godot: 4.4+

포팅 검토:
- field movement
- interaction detection
- area transition

제외:
- 전역 Player/Camera/CombatEvents/FieldEvents/Gameboard 구조
- 전투 시스템
- 원본 routing

### TinIntegrationKit

우선 재사용 후보:
- dialogue
- inventory
- quest
- relationship
- timeline
- hotspot
- checkpoint
- capture/restore

실제 필요한 API만 사용한다.

### 구현 전 추가 조사

Godot 4.x permissive adventure/RPG 기반 후보 2개 이상 추가 비교.

## 12. 파일 구조

```text
modules/<ODD_ROAD_MODULE_ID>/
  module_manifest.tres
  entry.tscn
  module.gd

  domain/
    adventure_state.gd
    location_definition.gd
    route_definition.gd
    item_definition.gd
    npc_definition.gd
    event_definition.gd
    resolution_definition.gd
    knowledge_entry.gd

  systems/
    location_host.gd
    world_map_system.gd
    interaction_system.gd
    inventory_system.gd
    npc_state_system.gd
    event_system.gd
    resolution_system.gd
    knowledge_system.gd
    save_codec.gd
    content_validator.gd

  field/
    player_controller.gd
    interactable.gd
    npc_actor.gd
    exit_area.gd

  ui/
    inventory_panel.gd
    dialogue_panel.gd
    map_panel.gd
    local_notes_panel.gd

  content/
    locations/
    routes/
    items/
    npcs/
    events/
    knowledge/

  scenes/
    locations/
```

## 13. 구현 단계

### Phase 0 — 베이스 감사
- TIN contract
- TinIntegrationKit 실제 API
- Open RPG 0.4.0
- 추가 후보 2개

산출: `docs/odd_road_base_audit.md`

### Phase 1 — AdventureState / save
- state
- content registry
- JSON-safe save
- stale ID sanitize
- migration

### Phase 2 — 기본 문법
테스트 지역에서:
- 이동
- 조사
- NPC 대화
- 줍기
- inventory use
- exit

### Phase 3 — 여러 location
3개 지역 왕복.
NPC/아이템/지역 상태 유지.

### Phase 4 — Event / Resolution / Knowledge
- 병렬 사건
- 복수 해결 조건
- 이전 지식 재사용

### Phase 5 — 첫 authored slice
마을 + A/B/C.

### Phase 6 — 콘텐츠 증산
location/event/NPC/item/knowledge 데이터 추가.

새 subsystem은 실제 반복 요구가 확인될 때만 추가.

## 14. 테스트

### contract
- input disabled
- exit/re-entry
- save JSON-safe
- AppRoot/다른 모듈 직접 참조 없음

### state
- location round-trip
- inventory
- NPC state
- event state
- route state
- stale content IDs

### interaction
- inspect
- talk
- pickup
- item use
- invalid use
- repeat interaction variants

### continuity
- same item in 2 contexts
- same NPC in 2 locations/states
- event A changes location B
- knowledge from A usable in C
- parallel events preserve state

## 15. 완료 기준

- 첫 45~90분 authored slice 실제 플레이 가능
- 최소 3개 지역이 같은 입력/UI/상태 모델 사용
- 지역 재방문과 상태 변화가 실제로 보임
- 아이템·NPC·지식 중 둘 이상이 재사용됨
- save/load round-trip
- TIN module contract 회귀 없음

## 시각 구현 계약 — 2026-09-22

### 1차 레퍼런스
West of Loathing의 실제 탐험, 대화, 지역 이동 화면.

참조:
- 적은 색과 단순한 선으로도 장소·캐릭터 개성이 강하게 읽히는 구성
- 화면 속 기묘한 사물 자체가 농담이 되는 방식
- 대화 선택지가 월드를 압도하지 않는 단순 text UI
- 같은 게임 문법을 유지하며 장소마다 시각적 농담이 늘어나는 방식

### 화면 산출물
1. road/exploration
2. town/interior
3. NPC talk
4. item/world interaction
5. route transition
6. unusual event

### at-icons
- 이 모듈은 collage를 적극 사용
- 캐릭터와 건물은 기본적으로 2종 이상의 서로 무관한 원본 조각을 조합
- 원본 icon 의미가 그대로 보이는 표지판식 사용 금지
- 대화 선택지, 지역 이동, 상태 UI에는 icon 금지

### 완료 스크린샷
야외 / 실내 / 대화 / 기묘한 이벤트를 각각 1152×720로 검수하고 같은 게임이면서 서로 다른 장소로 읽혀야 한다.

## UI 계약 보완 — 미구현 검수 항목

필수 입력: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). 아래는 AI 계획 보완이다.

- 소유: 기존 파일 구조의 지역/대화/아이템 view와 어드벤처 전용 테스트. 입력은 location·상호작용 대상·인벤토리·NPC/사건 상태이며 각 view는 같은 명령 경로를 사용한다.
- 지역과 대화 상대가 1차 초점이다. 기본 선택에는 행동명, 선택 상세에는 관찰/사용 조건을 표시한다. 실패 이유는 이미 관찰한 사실 범위에서만 설명하고 숨은 해결 경로를 알려주지 않는다.
- 아이템 선택→대상 선택→사용/취소, 대화 열기→선택→지역 복귀를 각각 정의한다. 지역 이동 후 이전 NPC/아이템 포커스가 남지 않으며, 소비/삭제된 항목은 유효한 인접 항목 또는 닫기로 복귀한다.
- 검증: 빈 인벤토리·긴 대사/이름·최대 선택지·사용 실패 원자성·아이템 소비 후 focus·NPC 재회·붉은 실 우회 후 재진입. 상세창이 전체 지역의 탐색 공간을 상시 가리지 않는지 확인한다.

## 레퍼런스 직접 적용 — Destiny식 물건 깊이와 되돌아오는 탐색

[보고서 적용 지도](../../docs/UI_REFERENCE_ADAPTATIONS.md)의 Destiny 아이템 관리·단계별 정보, RPG breadcrumb/비교, 제작 조건 행을 West of Loathing 기반 지역 탐험에 적용하는 **TIN 설계안**이다.

탐험 중에는 지역과 실제 물건/NPC가 화면 중심이다. 인벤토리를 요청할 때만 오른쪽 약 1/3에 텍스트 물건 목록을 펼친다. 각 행의 기본 정보는 이름과 보유 상태, focus는 짧은 관찰 요약과 “사용/상세”, 상세 확인은 같은 면에서 긴 설명·획득 장소·이미 관찰한 성질을 보여준다. “물건 > 붉은 실” 같은 위치 텍스트를 남기고 취소는 상세→같은 목록 행→원래 지역 대상으로 한 단계씩 돌아온다.

비교는 보고서의 StatDelta/RequirementRow를 그대로 공격력 숫자로 만들지 않는다. 이미 알려진 상호작용 조건이 있을 때만 “현재 가진 것 / 알려진 필요 조건”을 같은 행에 나란히 표시한다. 미발견 사용처나 사당 우회 해법을 조건 목록에 드러내지 않는다. 실패가 관찰 가능한 조건을 새로 알려주는지는 domain의 authored 결과에 따른다.

“사용”하면 목록은 좁은 선택 물건 제목으로 접히고 지역의 대상들로 focus가 이동한다. 마우스는 대상을 직접 선택하며 패드는 같은 대상 순서를 탐색한다. 선택 대상 옆에 행동명이 나타나고 확정 뒤 도메인 결과에 따라 물건 소비/유지와 지역 반응이 바뀐다. 취소는 사용하지 않고 원래 물건 행으로 복귀한다. 소비된 물건은 인접한 유효 행, 마지막 물건이면 빈 상태의 닫기로 이동한다.

대화는 NPC를 상단/중앙에 남긴 채 하단 약 1/3에 본문과 선택지를 둔다. 선택지 focus의 짧은 밑줄 → 확정된 문장의 고정 → NPC 반응 순서로 눈을 이끈다. 대사 이력은 요청해서 읽고 닫으면 같은 선택으로 복귀한다. 기록 속 문장은 재선택 가능한 버튼처럼 보이지 않는다. 글자 표시 완료와 다음 대사 진행은 분리하며 자동 진행은 별도 옵션 계획에 연결한다.

Metaphor식으로 일반 focus 80ms, 사용 확정 140ms, NPC/지역이 실제 달라지는 사건 220ms를 시작값으로 둔다. 실패는 사용 대상 옆 원인과 현장 반응으로 남겨 즉시 다른 물건을 선택할 수 있게 한다. 성공 팝업으로 지역을 가리지 않는다. 지역 이동은 현재 선택을 정리하고 새 지역의 첫 유효 대상에 초점을 두며 자동으로 인벤토리를 다시 펼치지 않는다.

검수: 붉은 실 기본→선택→상세→돌아가기→사용 대상→취소, 실패 후 소모 없음, 실제 소비 후 focus, 우회 지역 진입/재방문, 긴 이름/설명, 빈 인벤토리. 이 로컬 상세 면을 공유 서비스나 공통 인벤토리로 옮기는 것은 별도 판단이다.
