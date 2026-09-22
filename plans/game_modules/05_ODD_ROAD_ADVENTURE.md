# 계획 05 — 기묘한 로드 어드벤처 게임형 모듈

공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스 방향: **West of Loathing 계열**  
작업명: **ODD_ROAD_ADVENTURE**  
정식 작품명 / 모듈 ID: 미정

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
