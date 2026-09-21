# 계획 05 — 기묘한 로드 어드벤처 게임형 모듈

레퍼런스 후보: **West of Loathing**  
작업명: **ODD_ROAD_ADVENTURE**  
정식 작품명 / 모듈 ID: 미정

이 문서는 최근 아이디어 덤프를 하나의 세계로 합치는 계획이 아니다.

사용자가 이미 게임형 모듈 후보로 제시한 `West of Loathing` 계열의 **하나의 지속적인 게임**을 만드는 계획이다.
최근의 "공룡 타고다니고 감자가 주적인 웨스트오브로딩"은 이 게임에 사용할 수 있는 강한 콘텐츠/테마 후보지만,
환생 왕녀·수호신·귀환자·이불 반란 등 주변 아이디어와 자동으로 같은 canon으로 묶지 않는다.

---

# 0. 완료 정의

이 모듈이 성공하면 플레이어는 3분만 보고 다른 TIN 게임으로 나갈 수도 있지만,
남아 있으면 같은 게임 문법으로 최소 30분, 장기적으로 2~8시간의 authored content를 계속 플레이할 수 있다.

**다음은 금지다.**

```text
지역 A = 물리 미니게임
지역 B = 추리 미니게임
지역 C = 타이밍 미니게임
지역 D = VN
```

대신:

```text
같은 캐릭터
같은 이동
같은 조사/상호작용
같은 지역 상태
같은 모듈 로컬 인벤토리
같은 NPC/대화 문법
같은 지식/기록
같은 저장
```

을 계속 유지하면서 장소와 사건이 달라져야 한다.

일회성 변칙은 있어도 된다.
단, 플레이어가 10분마다 새 조작법을 배우면 실패다.

---

# 1. 플레이어가 계속 하는 것

## 1.1 공통 플레이 문법

기본 입력/행동은 게임 전체에서 유지한다.

- 이동
- 조사
- 대화
- 줍기
- 모듈 로컬 인벤토리 열기
- 현재 장소의 대상에 아이템 사용
- 기록/메모 확인
- 장소 이동
- 취소/뒤로

필요하면:
- 탈것 탑승
- 특정 도구 사용
- 간단한 환경 조작

을 추가할 수 있지만 **기본 문법을 대체하지 않는다.**

## 1.2 게임의 반복 구조

```text
지역에 도착
→ 환경/NPC/이상한 문제를 자유롭게 봄
→ 조사·대화·아이템·이미 아는 지식으로 상황 건드림
→ 지역/NPC/경로 상태가 바뀜
→ 다른 지역에서 새 반응/새 접근 가능
→ 돌아다니며 여러 사건을 병렬 진행
```

중요:
- 하나의 "정답 퍼즐"만 풀고 다음 레벨로 넘어가지 않음
- 한 지역을 나중에 다시 방문할 이유가 있음
- 아이템과 지식이 한 번 쓰고 사라지는 열쇠만 되지 않음
- NPC가 일회성 설명문 배출기가 아님

---

# 2. 이 게임이 아이디어 풀을 먹는 방식

아이디어 조각을 **게임플레이 모드**로 바꾸지 않는다.

다음처럼 흡수할 수 있다.

| 아이디어 형태 | 이 게임 안에서의 사용 |
|---|---|
| 이상한 사람 | NPC / 반복 등장 인물 |
| 이상한 물건 | 인벤토리 / 상점 / 조사 대상 |
| 짧은 괴담 | 지역 사건 / rumor / 숨은 장소 |
| 기묘한 사회 규칙 | 마을·시설의 상식 |
| 한 줄 개그 | 아이템 설명 / NPC 반응 / 배경 사건 |
| 큰 세계관 | 별도 게임형 모듈 후보로 남김 |
| 완전히 다른 플레이 규칙 | 억지로 넣지 않음 |

## 2.1 최근 아이디어 중 자연스럽게 들어갈 수 있는 예

**반드시 전부 넣는다는 뜻이 아니다.**

- 뚱뚱한 수호신 종교 → 마을/사당/반복 방문 장소
- 붉은 행운벌레 → 도감·rare encounter·소문
- 소귀에 3년 경 읽기 → NPC side story / 우마왕 관련 사건
- 손가락별 손톱깎이 → 상점/아이템 개그
- +10 성검 깨뜨린 모루 → 대장간의 역사/오브젝트
- 사이보그 비듬 → 아이템/관찰 개그
- 사막의 바늘구멍 안 방 → 숨은 장소
- 창밖 신호 고양이 → 반복 관찰 NPC/동물
- 공룡/감자 → 이 게임의 전면 테마로 채택할 수도 있음

## 2.2 현재 넣지 않는 것

아래는 자체 세계/구조가 너무 커서 이 게임에 자동 흡수하지 않는다.

- 이불 반란 전체 세계
- 환생 왕녀 장기 서사 전체
- 태어나기 전 정책 투표
- 초은화 저작권 관리 협회 전체
- 괴담 인력소 전체

필요한 한 조각만 자연스럽게 맞을 경우 별도 검토.

---

# 3. 세계 구조

## 3.1 한 게임 안의 여러 지역

TIN ModuleDirector가 지역마다 게임을 교체하지 않는다.

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

지역은 같은 런타임 안에서 교체.

## 3.2 지역 유형

예시:

- 작은 마을
- 길가 시설
- 농장
- 사막
- 폐건물
- 사당
- 동굴
- 특이한 상점
- 이상한 기관

지역은 "미니게임의 껍데기"가 아니라
**같은 interaction grammar를 가진 authored space**다.

## 3.3 World Map

장거리 이동은 비어 있는 길을 오래 걷는 대신 지도에서 처리 가능.

지도에는:
- 발견한 장소
- 연결 경로
- 현재 접근 가능 여부

정도만 표시.

quest marker를 무조건 제공하지 않는다.

---

# 4. 모듈 로컬 상태

## AdventureState

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

TIN 전역 성장으로 올리지 않는다.

다른 게임으로 나갈 때 모듈 로컬:
- 돈
- 아이템
- 장비
- 지역 평판
- 퀘스트 상태

등은 이 게임에 남는다.

몸과 기억만 경계를 통과한다는 TIN 원칙 유지.

---

# 5. 인벤토리

이 게임은 module-local inventory를 사용해도 된다.

다만 "열쇠 A를 문 A에 사용"만 반복하면 안 된다.

## ItemDefinition

```text
item_id
display_name
description
tags[]
usable_targets[]
persistent
stack_policy
```

## 아이템 콘텐츠 규칙

하나의 주요 아이템은 가능하면:
- 직접 사용
- NPC에게 보여주기
- 다른 장소에서 재사용
- 정보/대화 변화

중 둘 이상을 가진다.

예:
"이상한 물건을 얻음 → 정확한 전용 자물쇠 하나 → 삭제"
패턴만 계속 반복하지 않는다.

---

# 6. NPC

NPC는 같은 게임 전체에서 반복 등장 가능.

## NPCState

```text
npc_id
location
relationship_state
conversation_state
known_events[]
inventory_refs[]
availability
```

깊은 관계 시뮬레이션은 필요 없음.

중요한 것은:
- 이전 사건을 기억
- 다른 장소로 이동 가능
- 같은 NPC를 다시 만났을 때 변화
- 한 사건의 결과가 다음 대화/행동에 반영

## 대화

TinIntegrationKit의:
- dialogue_begin
- dialogue_next
- dialogue_choose
- dialogue_history

우선 재사용.

새 dialogue engine 금지.

---

# 7. 문제 해결 문법

이 게임의 사건은 전부 같은 기본 자원에서 해결 가능해야 한다.

- 관찰
- 대화
- 아이템
- 이미 배운 지식
- 지역 상태 변화
- 다른 NPC/사건의 결과

## 해결 조건

`ResolutionDefinition`:

```text
requirements[]
effects[]
optional_text
```

하나의 사건에 여러 resolution 허용 가능.

예:

```text
방법 A: 특정 아이템
방법 B: NPC 관계/정보
방법 C: 다른 지역에서 얻은 지식
```

단, 모든 사건에 억지로 3해법을 넣을 필요 없음.

---

# 8. 지식

이 게임은 Golden Idol/Baba처럼 순수 지식 게임은 아니다.

하지만 플레이어가 이전에 본 이상한 세계 규칙을
다른 사건에서 재사용할 수 있어야 한다.

예:
- 특정 생물 습성
- 어떤 기관의 규칙
- 어느 NPC의 버릇
- 이상한 물건의 실제 용도
- 지역 간 인과관계

지식은:
- 자동 observation
- 사용자 메모
- 실제 플레이어 기억

중 혼합.

TIN records와 연결 가능하지만
게임 내부 lore/quest 데이터를 전부 global records로 보내지 않는다.

---

# 9. 전투/위험

PROJECT_DECISIONS의 깊은 전투 금지 유지.

따라서 기본은:
- 대화
- 아이템
- 환경
- 도망/우회
- 간단한 선택

으로 사건을 처리.

전투가 들어가더라도:
- 짧음
- 실행 난도 낮음
- RPG 성장의 중심 아님
- 30분마다 반복하는 주 루프 아님

---

# 10. 첫 authored slice — 45~90분

이 절은 **같은 게임 문법이 충분히 많은 콘텐츠를 받을 수 있는지 증명**하는 용도다.

정식 세계관 세부는 구현 전 확정 가능.

## 10.1 시작 지역 — 작은 마을

필수 시스템을 한 번에 노출:

- 이동
- 조사
- NPC
- 상점 또는 물건 교환
- inventory
- 지역 출구
- 반복 방문 대상
- 기록

마을 안 콘텐츠:
- 반복 방문 NPC 4~6명
- 조사 가능한 장소/오브젝트 12+
- side thread 3+
- 장기적으로 다시 볼 대상 2+

수치는 AI 구현 기본값이며 정본 설정 아님.

## 10.2 근거리 지역 A

목적:
- inventory item을 실제 문제 해결에 사용
- 다시 마을로 결과가 돌아옴

새 조작법 추가 금지.

## 10.3 근거리 지역 B

목적:
- 아이템 없이 지식/NPC 정보로 해결 가능한 사건
- A와 순서 자유

## 10.4 근거리 지역 C

목적:
- A 또는 B의 결과가 있으면 다른 반응
- 없어도 들어갈 수 있음
- "이 게임의 세계가 연결돼 있다" 증명

## 10.5 첫 90분 내 재사용 요구

반드시:
- 같은 아이템을 다른 맥락 2회
- 같은 NPC 재등장 1회+
- 같은 지역 재방문으로 상태 변화 확인
- 이전 지식 재사용 1회+
- 병렬 진행 가능한 사건 2개+
- 처음 15분에 배운 입력만으로 이후 콘텐츠 대부분 플레이

---

# 11. 콘텐츠 후보 배치 예시

이건 canon이 아니라 **이 게임 문법에 아이디어 풀을 어떻게 흡수할지 보여주는 예**다.

## 후보 1 — 수호신 사당

별도 먹이기 미니게임 금지.

기존 inventory/use 문법 그대로:
- 음식 아이템을 사당 대상에 사용
- 외형/주민 대사/지역 상태 변화
- 여러 방문에 걸쳐 누적 가능

즉 기존 게임의 side content.

## 후보 2 — 붉은 행운벌레

별도 도감 미니게임 금지.

- 장소에서 발견 가능
- 조사하면 observation
- 생존 사건과 반복 연관
- NPC/도감/소문에 반응

기존 조사/지식 문법 사용.

## 후보 3 — 사막 바늘

별도 퍼즐 게임 금지.

세계지도에서 발견되는 location.

- 바늘 자체 조사
- 바늘구멍으로 들어가면 숨은 방
- 내부 아이템/NPC/사건

기존 location grammar 사용.

## 후보 4 — 우마왕 탄생

NPC event chain.

- 소에게 경 읽는 아저씨를 여러 시점에 반복해서 만남
- 시간이 지나면서 상황 변화
- 결과가 우마왕으로 이어짐

새 gameplay mode 없음.

## 후보 5 — 공룡/감자

전면 테마로 채택할 경우:
- 공룡 = module-local travel/field affordance
- 감자 = recurring enemy/hazard/faction/object
- 여러 지역에서 같은 규칙 재사용

한 번 쓰고 버리는 미니게임으로 두지 않는다.

---

# 12. 장기 콘텐츠 두께

2~8시간 authored content를 채울 때 새 시스템보다 콘텐츠를 늘린다.

AI 기본 목표치:

- 주요 지역 8~12
- 소규모/숨은 장소 10~20
- 반복 NPC 12+
- 1회성 NPC 20+
- usable item 25+
- 병렬 사건/thread 15+
- 반복해서 적용되는 세계 규칙 6+
- 지역 간 결과 전파 10+

이 수치는 구현 계획용 기본값이며 사용자 정본 아님.

## 분량 증가 규칙

30분 추가할 때:
- 새 미니게임 3개 추가 금지
- 기존 시스템으로 새 지역/사건/NPC/아이템을 먼저 만든다
- 새 시스템은 현재 문법으로 표현하기 어려운 **여러 콘텐츠 요구가 반복 확인될 때만** 추가

---

# 13. 외부 베이스

## 13.1 GDQuest Godot Open RPG

repository:
`gdquest-demos/godot-open-rpg`

tag:
`0.4.0`

commit:
`ff4f907d71385d459e64383f799700e998518153`

license:
MIT

Godot:
4.4+

유용 후보:
- field movement
- gamepiece/player controller
- interaction
- map/area transition

문제:
- Player/Camera/CombatEvents/FieldEvents/Gameboard 전역 구조
- 전투 구조 불필요
- TIN autoload 금지와 충돌

### 채택

전체 import 금지.

Phase 0에서 파일 단위로:
- 이동
- interaction detection
- area transition

만 추출/포팅 가능성 검토.

## 13.2 TinIntegrationKit

이미 있는 것 우선 사용:
- dialogue
- inventory
- quest
- relationship
- timeline
- hotspot
- checkpoint
- capture/restore

단:
- generic kit가 있다고 모든 기능을 켜지 않음
- 이 게임에 실제 필요한 것만 module local에서 사용

## 13.3 추가 조사

구현 시작 전 Godot 4.x permissive adventure/RPG 기반 후보를 최소 2개 더 조사.
없거나 현재 TIN보다 나쁘면 새 의존성 추가하지 않음.

---

# 14. 파일 구조

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

지역별 별도 GameModule 생성 금지.
지역마다 별도 input contract 생성 금지.

---

# 15. 구현 단계

## Phase 0 — 베이스 감사

- TIN contract
- TinIntegrationKit 실제 API
- Open RPG 0.4.0
- 추가 후보 2개

산출:
`docs/odd_road_base_audit.md`

## Phase 1 — AdventureState / save

씬 없이 state/save/content registry.

Gate:
- JSON-safe
- stale ID sanitize
- version migration

## Phase 2 — 동일 플레이 문법

한 테스트 지역에서:
- 이동
- 조사
- NPC 대화
- 줍기
- inventory use
- location exit

Gate:
- 별도 미니게임 없이 10~15분짜리 content fixture 작성 가능

## Phase 3 — Map / 여러 location

3개 지역.
같은 input/UI 유지.

Gate:
- 왕복
- NPC/아이템/지역 상태 유지

## Phase 4 — Event / Resolution / Knowledge

병렬 사건.
여러 해결 조건.
이전 지식 재사용.

Gate:
- A/B 순서 자유
- C 반응 변화
- 같은 아이템 재사용

## Phase 5 — 첫 authored slice

마을 + A/B/C.

여기부터 실제 사용자 아이디어 풀에서 **잘 맞는 것만 선택**.

최근 덤프 반영량을 목표로 잡지 않는다.

## Phase 6 — 콘텐츠 증산

30분 단위로:
- location
- event
- NPC
- item
- knowledge

추가.

새 subsystem은 반복 요구가 확인될 때만.

---

# 16. 테스트

## contract
- input disabled
- exit/re-entry
- save JSON-safe
- no AppRoot/direct other module refs

## state
- location round-trip
- inventory
- NPC state
- event state
- route state
- stale content IDs

## interaction
- inspect
- talk
- pickup
- use item
- invalid use
- repeat interaction variants

## content continuity
- same item used in 2 contexts
- same NPC seen in 2 locations/states
- event A changes location B
- knowledge acquired in A usable in C
- parallel events do not overwrite each other

## anti-minigame regression
테스트/리뷰 체크:

- 새 location이 별도 input map을 만드는가?
- 새 event가 별도 game loop를 요구하는가?
- event 전용 manager가 계속 늘어나는가?
- 동일 시스템으로 두 번째/세 번째 콘텐츠 작성이 가능한가?

YES가 반복되면 설계 재검토.

---

# 17. 플레이테스트 게이트

1. 30분 동안 "게임이 계속 바뀐다"보다 **같은 게임에서 새로운 일이 계속 생긴다**고 느끼는가?
2. 첫 10분에 배운 조작으로 60분 뒤에도 대부분 플레이 가능한가?
3. 이전에 얻은 아이템/지식/NPC 관계를 다시 사용했는가?
4. 장소가 일회성 스테이지가 아니라 다시 돌아갈 세계로 느껴지는가?
5. 아이디어 조각 하나를 빼도 게임의 중심이 유지되는가?
6. 최근 아이디어 덤프를 몰라도 새 콘텐츠를 계속 작성할 수 있는가?
7. 콘텐츠 추가 작업이 새 미니게임 코드보다 data/location/event 작성에 가까운가?

하나라도 크게 NO면 "큰 게임형 모듈"이 아니라 다시 미니게임 묶음으로 가고 있는지 확인한다.
