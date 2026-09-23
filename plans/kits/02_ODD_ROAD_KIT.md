# Kit 02 — Odd Road Adventure

공통 계약: `docs/KIT_WORKFLOW.md`

## 0. Kit 목적

한 게임 안에서 **2D 탐험/대화/아이템 기반 어드벤처 장르**로 전환할 때 즉시 쓸 기반을 만든다.

## 1. Primary Reference — 하나

**West of Loathing — Asymmetric**

공식 reference:
- Steam: https://store.steampowered.com/app/597220/West_of_Loathing/

공식 설명에서 확인되는 핵심:
- 넓은 탐험 공간 안에 quests/puzzles/characters가 섞여 있다.
- 장소를 돌아다니며 인물과 사건을 만나고 조사하는 장르다.
- 하나의 단순한 시각 언어 안에서 많은 authored 상황을 증산한다.

이 Kit에서 가져올 것은 **월드 탐험 → 대상 조사/대화 → 아이템/지식/사건 상태 변화 → 다른 장소/재방문에서 결과 반영** 구조다.

### 1.1 상태별 실제 화면 증거

구현 시작 전에 Steam media/trailer 또는 동일한 공식/신뢰 가능한 실제 플레이 자료에서 아래 상태를 각각 확인하고 작업 메모에 캡처/타임코드를 남긴다.

| 상태 | 확인할 것 | TIN 적용 |
|---|---|---|
| exploration | 플레이어/배경/상호작용물 비율 | 장소가 화면의 주인공 |
| interactable approach | 대상이 월드에서 어떻게 읽히는지 | 버튼 목록 대신 월드 affordance |
| NPC talk | 월드와 대화 UI의 비율 | 필요한 영역만 열기 |
| item/inventory | 탐험과 inventory의 전환 | 호출 시만 표시 |
| location transition | 출구/장소 이동의 피드백 | route state와 scene 교체 분리 |
| revisited place | 상태 변화가 장소에 반영되는 방식 | 재방문 presentation |
| unavailable use | 실패가 월드를 덮지 않는 방식 | 대상 가까이 짧은 feedback |
| return to play | UI 닫은 뒤 조작 복귀 | focus/input 복원 |

이 표의 실제 캡처/타임코드가 없으면 presentation 구현을 시작하지 않는다.

### 1.2 강하게 따라갈 것

- 장소가 화면의 주인공이고 UI가 그 위를 덮지 않는 구성
- 캐릭터/사물/출구가 텍스트 버튼 목록이 아니라 월드에서 읽히는 방식
- 짧고 반복 가능한 이동·조사·대화 문법
- NPC 대화가 월드와 분리된 개발도구 화면처럼 보이지 않는 정보 위계
- 한 장소의 기묘한 시각 요소 자체가 상호작용과 분위기를 전달하는 방식
- 인벤토리는 필요할 때 열고 닫으며 탐험 화면을 상시 잠식하지 않음
- 재방문했을 때 사건/NPC/사물이 실제 화면에서 달라짐

### 1.3 복제하지 않을 것

- 원작 stick-figure 캐릭터 디자인
- 원작 서부 배경/고유 농담/문구
- 원작 퀘스트·지역 배치
- 원작 자산

## 2. 현재 코드 판정

현재 `modules/odd_road_adventure/module.gd`에는 location/target/item/knowledge와 event 상태의 아이디어가 있으나, `LOCATION_IDS`, `TARGETS` 등 콘텐츠가 module script에 직접 하드코딩되어 있다.

보존 후보:
- location 이동 상태
- inventory 상태
- NPC state
- event/resolution state
- knowledge/notes
- save/load 개념

Reference Game 구현 전에 반드시:
1. location/item/NPC/event/route definition을 data/Resource로 분리
2. registry/validator 추가
3. core module script의 콘텐츠별 match/ID 나열 제거
4. presentation 전면 재작성

현재 장소명·대사·사건 아이디어는 보존 대상이 아니다.

## 3. Reference Game 분량

최소 **10분 이상**.

콘텐츠 단위:
- location
- NPC
- interactable
- item
- event
- resolution

최소 구성:
- 서로 왕복 가능한 location 4개 이상
- 반복 등장 NPC 3명 이상
- 획득/사용 가능한 item 4개 이상
- 같은 item 또는 같은 지식을 다른 맥락에서 재사용하는 사례 2개 이상
- 병렬로 진행 가능한 event 2개 이상
- 재방문했을 때 시각적으로 달라지는 location/NPC 상태 3개 이상

수치는 Reference Game의 하드코딩 방지용 최소 검증량이며 TIN 본편 canon이 아니다.

## 4. 데이터 모델

LocationDefinition:
- id
- scene
- exits/routes
- interactables
- spawn points

NPCDefinition:
- id
- presentation scene
- starting location
- dialogue/event hooks

ItemDefinition:
- id
- presentation
- description
- tags

EventDefinition:
- id
- visibility requirements
- resolutions[]
- effects[]

ResolutionDefinition:
- requirements
- atomic effects
- result presentation

AdventureState:
- current location
- inventory
- knowledge
- location states
- npc states
- event states
- route states

## 5. 콘텐츠 추가 규칙

새 location:
- registry data + scene + authored interactables만 추가
- module core 수정 금지

새 NPC/item/event:
- definition + 필요한 authored scene/content만 추가

validator:
- duplicate ID
- missing scene
- broken route
- missing NPC/item/event reference
- invalid resolution effect
- impossible required reference

잘못된 신규 콘텐츠 하나 때문에 기존 registry 전체가 깨지지 않게 한다.

전용 에디터 툴은 만들지 않는다.

## 6. Presentation

at-icons를 월드 아트의 필수 원재료로 사용한다.

- 캐릭터: 여러 unrelated icon 조각을 조합
- 건물/가구/기계/식물: crop/rotation/mirror/overlap/color 변형
- 작은 소품도 원래 pictogram 의미 그대로 두지 않음
- UI icon 사용 금지

화면:
- 탐험 중 대부분은 월드
- 상호작용 가능한 대상은 월드의 배치/실루엣/근접 반응으로 읽힘
- “NPC 1 / 사물 2 / 출구 3” 버튼 목록 금지
- 대화는 필요한 영역만 차지
- 인벤토리는 호출할 때만 나타남
- 상시 quest/status/context HUD 금지
- 키바인드 문장 금지

## 7. 입력

Kit 기본 intent:
- movement
- interact/confirm
- cancel
- inventory
- 필요 시 notes

물리 키는 InputMap/ModuleContext에서 해석한다.

이 Kit로 진입하는 전환에서 required physical key set이 달라지면 Input Bubble이:
- 계속 필요한 기존 키를 복구
- 새 키를 아래에서 올림
- 더 이상 필요 없는 키를 popped 흔적으로 유지
한다.

게임 화면에서 장문 조작 설명을 하지 않는다.

## 8. 상태 변화와 실패

필수 시나리오:
- 없는 item 사용
- 잘못된 target 사용
- 사용 실패 후 item 비소모
- 성공 후 item 소비/유지 정책
- 이미 해결한 event 재접근
- NPC가 다른 location으로 이동
- location 재방문
- 병렬 event A→B / B→A
- save 중간 상태 → load
- stale content ID
- 삭제된 content reference

resolution effects는 먼저 전체 검증한 뒤 atomic하게 적용한다.

## 9. 저장

ID 기반 JSON-safe 상태만 저장한다.

presentation focus, 열린 panel, hover 같은 UI 상태는 저장하지 않는다.

load 뒤:
- 현재 location 복구
- inventory/knowledge 유지
- NPC 위치/대화 상태 유지
- event 결과 유지
- 사라진 content ID는 안전한 fallback으로 정규화
- 다른 정상 상태를 함께 초기화하지 않음

## 10. 해상도

실제 캡처:
- 1280×720
- 1920×1080
- 2560×1440

확인:
- 월드가 UI보다 먼저 보임
- 대화/인벤토리 panel이 핵심 상호작용 대상을 가리지 않음
- 긴 대사/긴 item name
- 좁은 location과 넓은 location
- 재방문 상태 변화가 같은 구도에서 읽힘

## 11. 자동 테스트

- registry/validator
- location round-trip
- item pickup/use/invalid use
- atomic resolution
- NPC 이동/재회
- parallel events
- route unlock
- save/load
- stale ID sanitize
- 새 location/item/event 정의 추가 시 core 무수정

## 12. 수동 플레이 과제

사용자는 설명 없이:
1. 장소에서 이동한다.
2. 조사 가능한 사물을 찾는다.
3. NPC와 대화한다.
4. item을 얻는다.
5. inventory를 열어 item을 고른다.
6. 월드 target에 사용한다.
7. 다른 location으로 이동한다.
8. 이전 location을 재방문해 달라진 상태를 확인한다.
9. 병렬 사건 중 하나를 먼저 해결하고 다른 사건의 반응을 본다.

## 13. 금지 shortcut

- location/target를 Button 목록으로 대체
- module.gd에 콘텐츠 ID 배열/대사/사건을 계속 추가
- ColorRect/Label을 월드 사물로 사용
- 인벤토리를 항상 열어둠
- 상시 Shell HUD
- 조작 설명 overlay
- 10분을 이동거리/대사량만으로 채움
- 하나의 scripted route만 존재하면서 “어드벤처 시스템 완료” 선언

## 14. 완료 증거

- 상태별 Primary Reference 캡처/타임코드 기록
- 4개+ location
- 3명+ 반복 NPC
- 4개+ item
- 병렬 event와 재방문 변화
- 10분+ 실측 플레이
- authored content 추가 시 core 무수정 증거
- 720p/FHD/QHD 캡처
- 사용자 플레이 **검토 준비 완료**

사용자 실제 검토 전에는 최종 완성이라고 쓰지 않는다.
