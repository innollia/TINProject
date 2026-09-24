# TINProject — Grilling State

현재 상태: **COMPLETE — Rule Rewrite Kit별 grilling 및 계획서 작성 완료. 구현 중 방향 점검 뒤 재개**
구현 중 발견한 불일치와 재개 조건: [Rule Rewrite 방향 점검](research/rule_rewrite/DIRECTION_REVIEW_2026-09-24.md).
project-wide 상태: **COMPLETE — 사용자 shared understanding 확인 완료**
갱신: 2026-09-24

## Rule Rewrite Kit별 합의와 계획 입력

2026-09-24 사용자가 추가 질문보다 구체 계획서 작성을 선택하고 작업을 지시했다. 현재 설계 질문 frontier는 비어 있다. 아래 확정값을 계획 입력으로 사용한다. 계획 작성 중 확인이 필요한 원작 동작·UI 증거는 조사 항목으로 다루고, 플레이 경험을 실제로 바꾸는 새 갈림길이 발견될 때만 사용자에게 묻는다.

조사 입력: `docs/research/RULE_REWRITE_REFERENCE_REPORT.md`, `docs/research/RULE_REWRITE_MOD_ECOSYSTEM_REPORT.md` 및 `docs/research/rule_rewrite/user_capture_01.jpg`~`user_capture_10.jpg`. 후속 에이전트가 레퍼런스 보고서의 어휘 카탈로그와 사용자 캡처 10장을 읽고 직접 확인했다. 모드 생태계 보고서는 공개 자료의 기능·기술·권리 범위를 정리한 입력이다. 정지 화면으로 모션·음향·입력 반복을 확인했다고 간주하지 않는다.

현재 라운드:
- K1 확정: 인벤토리 문법 확장. 실제 BOX 오브젝트로 속 빈 사각형을 만들고 `BOX INSIDE IS METRIX`를 성립시키면 각 유효 사각형이 복합 오브젝트가 된다. 원작 어휘 전체 목록은 조사 입력으로 유지하며 이번 Reference Game의 실행 범위는 Kit 계획서에 명시했다.
- K2 확정: 인게임 퍼즐에 집중. 지금 지도·챕터·스테이지 구분 체계를 확장하지 않는다.
- K3 확정: 이미 아는 규칙을 빠르게 조합해 시스템을 검증하는 Reference Game. 고난도 퍼즐에서 오래 고민하게 하는 것을 우선 목표로 삼지 않는다.
- K4 확정: BABA IS 3D와 인벤토리·핫바. Minecraft를 해당 확장점에만 Secondary Reference로 허용. 3D에서 핫바를 통해 선택한 오브젝트를 공간에 배치한다. 원작 3D 동작은 레퍼런스 보고서의 사실 조사를 사용하며, 사용자에게 사실을 묻지 않는다.

최근 확정:
- 사용자가 Minecraft 인벤토리 화면 캡처 한 장을 제공했고 추가 캡처는 없다고 밝혔다. 해당 이미지는 docs/research/rule_rewrite/minecraft_inventory_user.png에 보존했다. 인게임 핫바 위치는 원본 관찰이 아니라 Kit 계획의 명시적 화면 결정이다.
- 인벤토리 UI와 보드 내부는 동일 아이템 상태의 두 표현이다. 어느 쪽에서 변경해도 다른 쪽에 즉시 반영된다.
- 테두리에 문을 두면 인벤토리 성립 뒤에도 내부로 들어가 구성 조각과 아이템을 조작할 수 있다.
- 성립한 대형 BOX를 외부에서 밀면 구성 조각 하나가 아니라 전체가 움직인다.
- 인벤토리의 기본 소유자는 현재 YOU 집합이다. YOU가 여러 개면 하나의 공용 인벤토리를 공유한다. 별도 소유 문법으로 소유자를 바꾸거나 분리할 수 있다.
- 복합 오브젝트 명사는 현재 `METRIX`다. 유효한 닫힌 테두리가 둘 이상이면 모두 대형 오브젝트가 된다. 대형 오브젝트 상태에서는 구성 조각을 밀어도 전체가 움직이며, 해체하려면 `BOX INSIDE IS METRIX` 규칙을 깨야 한다.
- 상자 내부 격자와 인벤토리 슬롯은 직접 대응한다.
- 3D 시점에서는 핫바가 보이고 2D로 돌아오면 사라진다. 공용 인벤토리 상태는 유지된다.
- METRIX 이동 시 내부 물건은 함께 운반되어 4096처럼 이동 방향의 안쪽 벽에 붙는다. 외부 충돌은 경계만 검사한다.
- 여러 METRIX 인벤토리는 별도로 유지한다. 현재 활성 인벤토리와 소유 관계는 규칙으로 변경 가능해야 한다.
- 사용자 지적: 단순 확장 아이디어를 맨바닥 질문만으로 구체화하는 데 시간이 과도하게 들었다. Baba Is You 모드 생태계의 유사 기능·새 문법 구현 사례를 조사해 보고서에 정리했으며, 추가 추천안 승인 질문 없이 Kit 계획 작성으로 넘어갔다.

원작의 사실은 에이전트가 조사한다. 기존 확정된 UI 충실도·복구 문법을 임의의 재해석 선택지로 다시 묻지 않는다. 아래 1~22절은 완료된 project-wide grilling 기록이다. Kit별 합의 전에는 기존 Kit 계획을 새 실행 명세로 수정하지 않는다.

`https://github.com/PlasmaFlare/baba-modding-guide`는 Kit별 grilling에서 사용자 결정을 대신하지 않는다. 그릴링 종료 후 초상세 계획서를 작성할 때 파서·규칙표·재평가 순서의 기술 토대를 조사하는 자료로 사용한다. 비공식·불완전 자료이므로 위키와 필요한 실제 사례를 함께 대조한다.

이 파일은 설계 결론 자체의 정본이 아니라 **현재 그릴링의 진행 상태**를 보존한다.

- 용어 정본: `CONTEXT.md`
- 이미 확정된 사용자 결정: `PROJECT_DECISIONS.md`
- 비싸고 장기적인 아키텍처 결정: `docs/decisions/`
- 현재 인터뷰에서 무엇이 끝났고 무엇이 열려 있는지: **이 파일**

## 0. 가장 중요한 운영 규칙

새 채팅/새 에이전트가 grilling을 이어갈 때 루트 질문부터 다시 시작하지 않는다.

반드시:
1. `CONTEXT.md`
2. `PROJECT_DECISIONS.md`
3. 이 파일
을 먼저 읽는다.

그 뒤 **Settled** 항목은 모순이나 새로운 정보가 발견되지 않는 한 다시 묻지 않는다.

질문은 오직 **Current Frontier**에서 시작한다.  
새 결정이 나오면:
- 용어 변화면 `CONTEXT.md`
- 사용자 확정값이면 `PROJECT_DECISIONS.md`
- hard-to-reverse + surprising + trade-off가 큰 결정이면 ADR
- 현재 그릴링 상태면 이 파일
에 즉시 반영한다.

계획서 작성/수정은 project-wide grilling이 끝나고 사용자가 shared understanding을 확인한 뒤 한다.

현재 `plans/kits/` 파일들은 **그대로 둔다**. 이 그릴링 중에는 수정하지 않는다. 이후 Kit별 grilling을 거쳐 훨씬 더 세세하게 다시 작성될 수 있다.

---

# 1. 현재 그릴링 Scope

## Settled

이번 세션의 대상은 **특정 Kit 하나가 아니라 TINProject 전체 개발 방향**이다.

순서:
1. project-wide direction을 끝까지 grilling
2. 사용자와 shared understanding 확인
3. 그 뒤 각 Kit마다 별도 grilling
4. 각 Kit grilling이 끝난 뒤 해당 초상세 계획서 작성
5. 계획서가 닫힌 뒤 구현

project-wide와 Kit-specific 결정을 한 트리에 섞지 않는다.

## 다시 묻지 말 것

- “이번 grilling은 특정 Kit 계획인가, 전체 방향인가?”
  - 답: **전체 방향 먼저. Kit별 grilling은 나중에 별도.**

---

# 2. 문서의 지위

## Settled

`PROJECT_DECISIONS.md`의 현재 항목은 **이미 사용자가 확정한 상위 제약**이다.

`CONTEXT.md`의 용어도 이미 합의된 의미다.

이 둘은 grilling 중 자유롭게 뒤집는 가설이 아니다.

다시 열 수 있는 경우:
- 새 사용자 발언이 명시적으로 바꿈
- 두 확정 문서가 서로 모순됨
- 실제 코드/도메인 사실이 결정의 전제를 깨뜨림

그 경우에도 “처음부터 다시 선택”하지 말고 **충돌한 정확한 항목만** 사용자에게 제시한다.

`plans/kits/`는 downstream 설계 문서다. 현재 project-wide grilling의 source of truth가 아니다.

## 다시 묻지 말 것

- “기존 문서들은 이번 인터뷰에서 뒤집을 수 있는 가설인가?”
  - 답: **아니다. 확정 결정은 상위 제약이고, 충돌이 생긴 항목만 재결정한다.**

---

# 3. 계획서의 성격

## Settled

계획서는 사람이 참고만 하는 요약 문서가 아니다.

**에이전트가 수십~수백 시간 장시간 독립 실행할 수 있는 executable design specification**을 목표로 한다.

계획서에 들어가야 하는 것:
- 실제 Primary Reference 조사 증거
- 화면/상태별 reference mapping
- domain/state/data model
- authored content format
- system processing order
- input
- save/load/reset/undo
- failure/recovery
- visual composition
- at-icons recipe
- file ownership
- automated tests
- manual play tasks
- 720p/FHD/QHD evidence
- forbidden shortcuts
- completion evidence

“알아서”, “게임답게”, “적당히”, “레퍼런스 느낌으로” 같은 문장은 구현 결정을 대신할 수 없다.

## 다시 묻지 말 것

- “계획서는 참고용인가 실행 명세인가?”
  - 답: **실행 명세.**

---

# 4. 모호함을 닫는 규칙

## Settled

구현 결과에 영향을 주는 결정은 grilling/계획 단계에서 **하나로 닫는다**.

계획에 선택지 A/B/C를 남겨 에이전트에게 선택시키지 않는다.

열어둘 수 있는 것:
- 플레이테스트로 값만 조절하면 되는 cheap tuning
- animation duration
- volume
- spacing
- threshold
- 난이도 숫자처럼 구조를 바꾸지 않는 parameter

열어두면 안 되는 것:
- 어떤 시스템을 쓸지
- 데이터가 어디에 사는지
- 어떤 화면 구조인지
- 어떤 입력 문법인지
- 어떤 save semantics인지
- 어떤 Reference를 따르는지
- HUD가 존재하는지
- content 추가가 code인지 data인지

## 다시 묻지 말 것

- “결정이 안 좁혀지면 계획서에 선택지를 남길까?”
  - 답: **구현에 영향을 주면 반드시 하나 선택. cheap tuning만 열어둔다.**

---

# 5. 프로젝트의 정체

## Settled

TINProject는 여러 게임을 모은 컬렉션이 아니다.

**한 게임 안에서 장르가 바뀌는 게임**이다.

의도 예시:
- FPS로 시작
- 같은 게임 진행 중 2D 추리 장르로 바뀜
- 다시 Superliminal 같은 3D 공간 장르로 바뀜
- 그 안에서 클리커 문법을 사용

예시는 canon이나 실제 계획이 아니라 **장르 전환 자유도**를 설명하기 위한 것이다.

Kit를 만드는 이유는 실제 게임 개발 도중 장르가 바뀌었을 때 새로운 장르 시스템을 처음부터 만들지 않고 바로 사용할 수 있게 하기 위해서다.

## Rejected

- 여러 독립 게임을 많이 만들어 컬렉션화
- “30개 모듈”, “34개 공간”, cycle당 개수 같은 수량 목표
- 기술적 GameModule 수를 성과 지표로 사용

---

# 6. Kit / GameModule / Reference Game

## Settled

### Kit
장르 시스템의 개발 단위.

예:
- 규칙 재작성 퍼즐 Kit
- 추리 Kit
- FPS Kit
- 2D 어드벤처 Kit

목적은 실제 TINProject의 한 구간에서 그 장르를 즉시 사용할 기반을 마련하는 것.

### GameModule
AppRoot/ModuleHost에서 교체되는 런타임 기술 단위.

Kit와 동의어가 아니다.

### Reference Game
Kit의 시스템이 실제 게임으로 작동하는지 검증하는 **10분 이상의 샘플 게임**.

작품 컬렉션에 추가하기 위한 독립 상품이 아니다.

## Rejected

- “모듈 완성 = 게임 완성”
- 작은 상태 머신/버튼 화면을 게임 수로 세기
- Kit 전체를 외부 공개 framework/API 제품으로 만드는 방향

---

# 7. Primary Reference 전략

## Settled

Kit 하나당 Primary Reference는 **정확히 하나**다.

가능한 기준:
- 인기 itch.io 게임
- n시간 게임 개발 대회/게임잼 출품작
- 상용/출시 인디게임
- 실제 화면과 플레이를 충분히 확인할 수 있는 완성 게임

AI에게 독창적 해석을 요구하기보다 먼저 **짝퉁 수준으로 핵심 시스템과 UX를 강하게 따라간다.**

실제 TIN 콘텐츠를 만들 때 사용자 취향에 맞게 변형한다.

### 강하게 따라갈 것
- 핵심 system
- interaction grammar
- camera/board/world composition
- input feeling
- information hierarchy
- focus/selection
- failure/success feedback
- retry/undo/reset flow
- content structure

### 복제하지 않을 것
- 원작 고유 asset
- 원작 문구
- 원작 캐릭터
- 원작 고유 level/map 배치

## 실제 자료

작품명만 적으면 안 된다.

계획 전에 실제 화면/플레이를 보고 상태별로:
- first frame
- normal play
- focus/direct manipulation
- core mechanic change
- failure/unavailable
- success
- transition
- menu/detail if core
를 확인한다.

“레퍼런스 확인함” 체크박스만 남기는 것도 불충분하다. 무엇을 가져갈지 구체적으로 기록한다.

## Rejected

- Primary Reference 여러 개 혼합
- “Baba + Golden Idol + Persona 느낌”
- 작품명만 쓰고 기억으로 구현
- reference의 외형만 얼추 흉내내고 interaction을 자의적으로 축약

---

# 8. Kit의 시스템 깊이

## Settled

아이디어 한 줄이나 단일 mechanic prototype만 구현하는 것은 Kit가 아니다.

Primary Reference의 **core play grammar 전체**를 베이스 시스템으로 구현한다.

포함:
- readability
- interaction feel
- combinatorial/depth
- authored content가 들어갈 구조
- fail/retry/recovery
- save/load가 필요한 장르라면 해당 semantics

Reference는 저작물 복제 대상이 아니라 **시스템 깊이와 UX 품질의 floor**다.

---

# 9. Authored Content / 전용 에디터

## Settled

목표는 **에이전트가 새 콘텐츠를 쉽게 추가하는 상태**다.

전용 에디터 도구는 필요 없다.

선호:
- Resource
- JSON/data
- scene
- module-local asset
- 장르상 필요한 작은 content script

새 레벨/사건/NPC/적/아이템 때문에 core algorithm을 반복 수정하면 실패다.

## Rejected

- 비개발자용 전용 authoring editor를 Kit 완료조건으로 만들기
- content ID별 if/match를 core에 계속 쌓기

---

# 10. Reference Game의 분량

## Settled

최소 실제 플레이타임 **10분 이상**.

10분 자체보다 중요한 것은:
- 핵심 시스템 문법을 실제로 전부 사용
- 여러 authored content를 같은 core에 넣어봄
- 새 content 추가가 hardcoding을 요구하지 않음을 증명

10분을 다음으로 채우지 않는다:
- 대기
- 긴 이동
- 같은 입력 반복
- 대사만 늘리기
- HP만 부풀리기

장르별 authored content 단위는 각 Kit grilling에서 결정한다.

---

# 11. 완료와 사용자 검토

## Settled

자동 테스트 통과만으로 완료가 아니다.

에이전트가 만들어야 하는 마지막 상태는:
**사용자가 직접 플레이하고 검토할 수 있는 상태**.

필요:
- 베이스 시스템 구현
- authored content 확장 가능
- 10분+ Reference Game
- reference와 비교 가능한 화면
- save/retry/failure paths
- target resolution 검수

사용자 실제 플레이 검토 전에는 “최종 완성”이 아니라 **검토 준비 완료**다.

---

# 12. 기존 구현의 지위

## Settled whitelist

### 보존 후보
- `modules/first_entry/`
  - 사용자가 요청한 시작 로직 방향은 맞음
  - 현재 presentation/설명문 전체를 승인한 것은 아님
- `modules/rule_rewriting/`
  - parser/evaluator/movement/undo/save 등 실제 시스템 기반 재검토
- `modules/odd_road_adventure/`
  - location/inventory/NPC/event/save 상태 기반 재검토
- `modules/game_library/`
  - Nintendo OS 계열 reference로 만든 직접 module 탐색/실행 UI
  - 기존에 이미 필요한 직접 접근 기능을 제공

### Retired Prototype
그 외 기존 플레이 모듈.

## Settled 처리

Retired Prototype은:
- 아이디어 불필요
- 대사 불필요
- UI 불필요
- 새 설계의 기준으로 사용하지 않음
- 최종적으로 코드도 삭제 대상

현재는 문서 작업만 수행했기 때문에 실제 코드 삭제를 아직 하지 않았다.

Git history가 보존 역할을 한다.

## Rejected

- old module을 salvage-by-default
- 별도 museum/archive 폴더
- “이미 만들었으니 고쳐서 살리자”를 기본 정책으로 사용

---

# 13. Shell / HUD

## Settled

**상시 HUD 자체가 잘못된 기본값**이다.

미니멀 UI가 기본.

플레이 중 Shell은 시각적 존재감 **0**.

금지:
- 좌상단 공간명/진행/자동저장/키 힌트
- 우상단 Menu/Journal 버튼
- 상시 tool bar
- debug status

Esc를 누르면 메뉴가 나타나는 식의 **호출형 UI**는 가능하다.

영속 AppRoot는 기술적 수명 계약이지 영속 HUD 계약이 아니다.

## 다시 묻지 말 것

- “Shell 메뉴 버튼을 항상 보이게 둘까?”
- “global menu/journal 버튼을 유지할까?”
- “HUD는 작게라도 두자?”
  - 답: **아니오. 호출 전까지 보이지 않는다.**

---

# 14. Input Bubble — 정확한 의미

## Settled

키바인드 학습은 텍스트 설명이 아니라 **뽁뽁이 방울을 실제 키 입력으로 터뜨리는 상호작용**이다.

### 화면
- 움직이는 무늬 배경
- 그 위에 가상의 격자
- 물리 키마다 고정 cell
- 해당 키의 bubble은 항상 그 cell과 대응

### 상태
- intact: 온전한 방울
- popped: 터진 흔적
- rising: 새 키가 아래에서 자기 cell로 올라오는 중
- restoring: 이전에 터졌던 키가 다시 온전해지는 중

### 예

- Game A required keys = `W A S D Z`
- Game B required keys = `W A S D Z X`
- Game C required keys = `W`

순서:
```text
시작창 A
→ WASDZ bubble이 올라와 자기 cell에 멈춤
→ 플레이어가 각 실제 키를 눌러 bubble을 터뜨림

A → B 중간창
→ A에서 터졌던 WASDZ bubble이 복구됨
→ 동시에 새 X bubble이 아래에서 올라옴
→ 필요한 키들을 눌러 다시 터뜨림

B → C 중간창
→ W bubble만 복구됨
→ ASDZX는 popped 흔적 상태로 남음
→ W를 눌러 터뜨림
```

중간창은 로딩/장르 전환 화면과 결합할 수 있다.

핵심은 키 이름을 읽히는 것만이 아니라 **그 실제 키를 눌러 bubble을 터뜨리는 것**이다.

장문의 키 기능 설명은 하지 않는다.

리바인딩이 존재하면 표시되는 키는 실제 현재 physical binding을 반영한다.

## first_entry

`first_entry`가 whitelist인 이유는 이 시작/입력 학습 **로직 방향**이 사용자 요청과 맞기 때문이다.

현재의 설명문이나 시각 구현 전체가 보존 대상이라는 뜻은 아니다.

---

# 15. 시각 자산 — at-icons

## Settled

선택지 A 확정: **at-icons를 모든 Kit Reference Game의 기본 월드 아트 재료로 강제한다.**

경로:
`res://addons/at-icons/`

규칙:
- UI icon으로 쓰지 않음
- 원래 pictogram 의미 그대로 쓰지 않음
- 여러 unrelated 조각을 조합
- crop/rotate/mirror/non-uniform scale/overlap/color transform
- 2D/3D 모두 장르에 맞게 사용

Primary Reference의:
- silhouette
- density
- camera
- composition
- readability
는 유지하되 원작 asset은 복제하지 않는다.

---

# 16. 해상도

## Settled

필수 지원/검수:
- 1280×720
- 1920×1080
- 2560×1440

고정 logical viewport를 쓸 수는 있지만 실제 출력은 세 해상도에서 검수한다.

현재 `project.godot`의 과거 1152×720은 지원 완료의 증거가 아니다.

---

# 17. Shared abstraction

## Settled

기존 방향 유지.

**두 실제 사용처에서 동일 의미와 계약이 확인되기 전에는 shared로 올리지 않는다.**

중복 구현을 절대 금지한다는 뜻은 아니다.

두 번째 사용처가 생겼을 때:
- 정말 같은 의미인지 확인
- 계약이 같으면 작은 공통 단위를 추출
- 장르별 차이가 크면 분리 유지

## Rejected

- RPG식 Inventory 하나를 모든 장르에 강제
- 사용처 없는 전역 UI/service framework 선제 구축
- Kit 전체를 외부 복사/포크용 제품으로 설계

---

# 18. game_library / 직접 실행

## Settled

“Kit/Module을 바로 열어 검수할 방법이 필요한가?”는 이미 해결된 문제다.

`modules/game_library/`가 Nintendo OS 계열 화면을 reference로 만든 직접 탐색/실행 UI 역할을 한다.

새로운 per-Kit launcher를 별도 발명하지 않는다.

필요하면 기존 game_library가 새 Kit/Module을 열 수 있게 연결한다.

---

# 19. 계획 수량

## Settled

Kit 개수 자체는 목표가 아니다.

좋은 계획서를 먼저 만들고, 하나의 Kit가 오래 걸리더라도:
- system이 깊고
- content 확장이 쉽고
- 실제 10분+ game으로 검증된다면
올바른 진행이다.

“몇 개를 만들지”는 결과이지 개발 목표가 아니다.

---

# 20. Rejected / Do Not Reopen 목록

아래는 새 정보 없이 다시 제안하지 않는다.

- 여러 게임을 독립 작품 컬렉션으로 만드는 방향
- 수십 개 얕은 module을 성공 지표로 삼기
- Primary Reference 여러 개 혼합
- reference를 이름만 적고 기억으로 구현
- AI에게 “게임답게 알아서” 맡기기
- 전용 content editor를 완료조건으로 만들기
- 상시 Shell HUD
- Menu/Journal 상시 버튼
- 키바인드 설명문
- old prototype 아이디어/대사/UI salvage
- at-icons를 선택사항으로 낮추기
- Kit 전체를 외부 공개 API/framework로 만들기
- implementation-affecting decision을 계획에 선택지로 남기기
- 자동 테스트 통과를 game completion으로 취급
- Kit/module 개수 목표 부활

---

# 21. Current Frontier와 최근 확정

현재 project-wide 질문 frontier는 비어 있다. 아래 F1~F5는 확정한 방향과 Kit별 설계로 넘긴 범위를 보존한다. 2026-09-24 사용자가 전체 방향 합의 요약에 “다 맞아”라고 답하여 shared understanding을 명시적으로 확인했다.

이 라운드 종료 당시 다음 단계는 Rule Rewrite의 Primary Reference 조사와 Kit별 grilling이었다. 이후 해당 조사·Kit 계획을 거쳐 구현에 착수했고 현재는 위 방향 점검으로 일시정지했다. 위 Settled 항목을 다시 질문하거나 Kit별 상세 문법을 project-wide 미결정으로 되돌리지 않는다.

질문은 추천안 승인 요청으로 만들지 않는다. 서로 다른 답이 실제 플레이를 어떻게 바꾸는지 구체 사례와 손실을 제시해 사용자가 자기 기준을 말할 수 있게 한다. 특히 장르 사이의 이질적 물건·신체 상태와 플레이어 머릿속 지식을 일반적인 상태 정리 대상으로 가정하지 않는다.

## F1 — 장르 전환 시 연속성 계약 (project-wide 범위 확정)

이번 라운드 확정: 여러 Kit의 장르 구간이 하나의 **뭉탱이**를 이룰 수 있고, 뭉탱이 안에서는 물건·신체 상태가 공통일 수 있다. 장르에 어울리지 않는 물건·신체 상태의 유입과 충돌은 핵심 경험이다. 뭉탱이 공유 상태는 뭉탱이가 하나의 원본을 소유하며 각 Kit가 필요한 부분을 사용한다. 뭉탱이마다 세부 계약은 다를 수 있다. 용어 정본은 `CONTEXT.md`다.

같은 장소 전환은 의미 있는 장면 위치를 이어받아 새 장르가 표현한다. 숫자 좌표를 그대로 옮기는 계약은 아니다.

플레이어 머릿속의 지식은 되돌릴 수 없으며, 게임 상태의 지식 기록과 혼동하지 않는다.

추가 확정: 뭉탱이 경계를 넘는 물건·신체 상태는 명시적으로 인계한다. 체력 200을 가진 캐릭터가 통상 1~3 체력 문법의 플랫폼 구간에서 피해 1을 받으면 199가 된다. 이미 알고 있는 범인·해법은 플레이어가 즉시 사용할 수 있으며, 순수 지식 관문을 발견 기록이나 플레이 시간으로 잠그지 않는다.

월드 변화의 유지·초기화, 방 재진입, 실패·재시작·체크포인트는 각 Kit의 게임 문법에서 구체화한다. 이를 프로젝트 전체 영속화/롤백 정책으로 묶어 다시 질문하지 않는다. FPS→추리→플랫폼 진행 중 플랫폼에서 실패한 제시 사례는 실패한 플랫폼 구간 시작으로 복귀한다. 다른 Kit의 실패 문법까지 이 사례로 일반화하지 않는다.

거절된 에이전트 가정: 모든 지속적인 세계 변화가 뭉탱이 경계를 넘어 유지돼야 한다는 권고, Kit 문법을 확인하지 않고 뭉탱이 시작/최근 체크포인트/구간 시작을 동등한 선택지로 제시하는 질문. 구체 Kit의 문법은 Primary Reference 조사와 Kit별 grilling에서 다룬다.

## F2 — 장르 전환의 공간적/서사적 형태 (핵심 확정)

같은 장소·장면이 다른 장르 문법으로 바뀌는 경험은 일급 요구사항이다. 내부 ModuleHost 교체 구조와 플레이어가 느끼는 공간·사건 연속성을 함께 만족시킨다. 구체 전환 상태는 F1에서 정한다.

사건·진행에 의한 전환과 플레이어가 필요에 따라 오가는 전환을 모두 허용한다. 자유 전환은 이를 위해 설계한 뭉탱이에서 제공한다. 가져온 물건·능력의 원래 조작 문법까지 함께 작동할 수 있으며, 입력 충돌과 화면 구성은 해당 뭉탱이에서 설계한다.

사용자 지적: 추천을 그대로 승인하게 만드는 질문이 반복되고 있다. 에이전트 판단: 실제 갈림길을 찾지 못한 채 포괄적 허용안을 질문으로 만든 실패이며, 현 project-wide 범위는 합의 검토에 충분히 구체화됐다. 추가 질문을 억지로 만들지 않는다.

## F3 — Kit가 실제 TIN 본편에 들어가는 방식 (핵심 확정)

Reference Game 단계에서는 Primary Reference의 UI·화면 구성을 강하게 따른다. 시스템만 가져와 UI를 임의로 재해석하지 않는다. 모든 Kit 제작 후 실제 TIN 본편을 만들 때 사용자 취향에 맞게 UI를 다시 설계할 수 있다. 구체적으로 어느 표현 규칙을 Kit 계약으로 둘지는 Kit별 grilling에서 정한다.

## F4 — 사용자 플레이 검토 이후의 수정 루프 (확정)

검토 준비 완료 후 다음 Kit의 grilling·계획 논의는 가능하다. 다음 Kit 구현은 앞선 Kit의 사용자 플레이 피드백을 반영한 뒤 시작한다. 시스템·입력·화면 구조가 바뀌면 해당 계획서를 먼저 수정하고, 작은 튜닝은 검수 기록에 남기고 바로 수정한다. 프로젝트 전체에 적용되는 실패 원인은 첫 발생 때 바로 공통 규칙으로 승격한다.

## F5 — Kit roadmap / 우선순위 (확정)

project-wide direction이 끝난 뒤 첫 Kit별 grilling 대상은 Rule Rewrite다. 여러 Kit의 grilling·계획은 겹쳐 진행할 수 있지만 Kit 구현은 한 번에 하나씩 진행한다.

**Kit 개수 목표를 다시 만드는 질문은 아니다.**

---

# 22. Grilling 종료 조건

2026-09-24 project-wide grilling 종료. 사용자 shared-understanding 확인 완료. 이 종료는 Kit별 계획 완성이나 구현 착수를 뜻하지 않는다.

project-wide grilling은 다음 때 끝난다.

- Current Frontier가 비어 있음
- 새로운 root decision이 남지 않음
- 용어가 `CONTEXT.md`와 충돌하지 않음
- 확정값이 `PROJECT_DECISIONS.md`에 반영됨
- 필요한 ADR만 작성됨
- 사용자가 shared understanding을 명시적으로 확인함

그 전에는 새 초상세 Kit 계획 작성/수정을 시작하지 않는다.
