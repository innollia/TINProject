# 계획 02 — 추리/사건 재구성 게임형 모듈

## 현재 구현에서 이어가는 보완 D1

**구현 기록(2026-09-23 D1 데이터 추출):** 실제 ID/경로는 `dedution_casework`다. 사건은 [`modules/dedution_casework/content/`](../../modules/dedution_casework/content/)의 두 `.tres` 번들로 이동했고, 타입은 `domain/deduction_case.gd`, `deduction_slot.gd`, `deduction_term.gd`에 있다. `systems/case_loader.gd`는 content 폴더의 `.tres`를 파일명 순으로 찾고, 카탈로그 전체를 검증한 뒤 한 건이라도 오류가 있으면 사건 목록 전체를 거부한다. 사건별 장면·발견·세부 기록·행위·시간 순서·판정 슬롯을 데이터로 둔다. 첫 사건은 장면/행위/판정이 3개, 두 번째는 장면/행위 3개에 판정 슬롯 4개(행위자·행동·동기·아직 확인되지 않은 관계)다. 각 선택지는 안정 ID와 표시 문구를 가지며, 행위자 선택지에 선언된 slot/term 참조로 모순을 판정한다. 실행 화면의 장소·순서·판정 행 수는 데이터 수에 따라 만들어진다.

manifest는 save_version 3이다. 저장은 기존 사건별 독립 상태를 유지하면서 `case_ids`, 선택한 이벤트 ID 배열, slot ID→term ID 사전을 저장한다. v2의 숫자 인덱스 상태는 현재 등록된 순서로 읽고, 새 4번째 슬롯은 미선택으로 초기화한다. 이후 리소스 어휘 순서가 바뀌어도 v3 답은 slot/term ID로 복원된다. 기존 모듈 ID는 저장·라우트 호환을 위해 유지한다. `test_cycle4_modules.gd`에서 리소스 검증, 가변 슬롯 수, ID 복원, v2 마이그레이션과 두 사건의 조사→순서→판정을 확인한다.

**남은 구현 제안:** 현재 추출은 두 샘플 사건의 조사·순서·slot 판정을 데이터화한 수직 슬라이스다. Golden Idol형 hotspot/document/word-bank 상호작용, term category·fact model, 조합형 문장 템플릿, 복수 정답 규칙, 선택 취소/직접 배치, 긴 사건 콘텐츠와 세이브 중 삭제된 사건 정책은 아직 완성으로 보지 않는다. 다음 단계에서는 기존 계획과 아래 화면 브리프를 유지하되 현재 Resource 스키마와 코드 계약을 먼저 읽고, 확장 폭을 작은 수직 슬라이스로 정한다.

**API와 원자성:** `validate_case(definition)`은 중복 ID, 없는 scene/hotspot/term 참조, 허용하지 않는 slot category를 오류 목록으로 반환한다. 검증 실패한 사건은 현재 사건을 대체하지 않는다. `submit(case_id, answers)`는 incomplete→contradiction→valid_but_wrong→solved 순으로 분류하고 증거·답을 변경하지 않는다. 사용자 화면에는 틀린 slot이나 정답 개수를 노출하지 않는다.

**저장 후속:** 현재 v3는 case ID와 개별 이벤트/판정 ID를 보존하지만 case-state 본체는 목록 순서 기반 배열이다. 사건을 추가/삭제할 때의 진행 기록 보존 규칙과 v1 이전의 실제 legacy fixture는 별도 검토한다. 삭제된 slot/term은 해당 답만 비우고, 다른 사건 상태는 유지한다. 사건 전환 전 현재 답을 보관하며 reset은 현재 사건만 초기화하는 명시 명령과 모듈 전체 reset을 구분한다.

**화면 검수 상태(2026-09-23):** 가변 행을 수용하도록 현재 Control 화면의 행 용량을 Resource 수에 맞췄다. 네 번째 판정 행의 긴 두 줄 문구가 패널 안에서 잘리지 않도록 행 영역과 장문 글자 크기를 조정했고, 1152×720 실행 캡처에서 표시를 확인했다. 이는 화면 배치 결함 수정이지 화면 완성 판정이 아니다. 사건 조사·첫 focus/선택/실패/성공 상태와 Golden Idol 실제 조사·문서·어휘 화면의 나란한 비교는 시각 게이트에서 남아 있다. 현재 장면은 ColorRect/Label 기반 개발 화면이며 release 표현이 아니다.

**추가 검증:** 미완성·타입 불일치·모순·그럴듯한 오답·복수 유효해·정답 각각, 조사 없이 답 수정, 잘못된 사건 데이터 거부, A 부분 조사→B 풀이→A 복귀, v1 JSON 이관, 제출 연타 관찰 중복 없음. UI drag/drop에만 의존하지 않고 키보드 term 선택→slot 배치→취소를 같은 명령으로 테스트한다.

**화면 실행 브리프:** Golden Idol의 현장과 추론 문서를 실제 확인한다. 조사 화면은 장면 약 800px + 선택 증거 문서 약 300px, 추론 화면은 중앙 문서와 하단 어휘 목록을 기본값으로 둔다. 현장/문서 열림/빈 슬롯/선택 어휘/오답 재검토/사건 전환을 캡처한다. 증거를 모두 조사하기 전에도 추론 화면 접근을 허용하며 UI가 답을 조립하지 않는다.

**외부 베이스 상태:** 아래 tutorial 채택은 기존 계획의 목표이지 현재 vendoring 완료 기록이 아니다. commit/LICENSE/가져올 GUI 파일과 global Controller 대체 방법을 구현 착수 시 재확인한다. 필요한 interaction 부분만 모듈 로컬에 포팅한다.


공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스: **The Case of the Golden Idol**  
목표: 사건 하나를 만드는 것이 아니라 **여러 사건을 데이터만 교체해 작성할 수 있는 조사·증거·어휘·추론·검증 시스템**을 만든다.

> 기존 구현 ID는 `dedution_casework`다. 아래 `<DEDUCTION_MODULE_ID>`는 이 경로를 뜻한다. 저장 ID를 임의로 교정하지 않는다.

---

## 0. 기존 베이스 우선 사용

### 1차 채택 베이스 — YuriSizov/tutorial-gui-of-golden-idol

- repository: `YuriSizov/tutorial-gui-of-golden-idol`
- Godot **4.3**
- GDScript
- MIT
- pinned commit: `1bf788a4f75ff71fb69facbd28a60c29b24380f9`
- 프로젝트 목적 자체가 **The Case of the Golden Idol의 핵심 GUI 메커니즘을 Godot 4에서 재구성하는 것**
- 원작 실제 코드를 리버스 엔지니어링한 구현은 아니며, 플레이어에게 공개된 동작을 바탕으로 재구성한 튜토리얼 프로젝트

확인된 재사용 후보:
- `globals/Controller.gd`
- `gui/components/SourceClueEffect.gd`
- `gui/components/SourceDocument.gd`
- `gui/components/DossierBlankEffect.gd`
- `gui/components/DossierDocument.gd`
- `gui/layout/WordBank.gd`
- 관련 scene/resource

튜토리얼이 이미 다루는 핵심:
- 문서 안에서 clue word 수집
- word bank
- dossier blank
- drag-and-drop
- result validation
- RichTextLabel/RichTextEffect 기반 authoring

### 채택 원칙

이 프로젝트를 **GUI/interaction 베이스로 실제 사용**한다.

가져올 것:
- clue 표시/수집 구조
- word bank entry 흐름
- blank slot interaction
- drag-and-drop interaction
- dossier document rendering
- validation UI 연결 방식

그대로 가져오지 않을 것:
- 원본 프로젝트의 Main/controller 조립 구조
- 원본 theme/font/assets
- 원본 예제 문구/콘텐츠
- TIN과 충돌하는 전역 상태 소유

TIN 쪽에서 새로 보강할 것:
- 사건 데이터 모델
- evidence/fact/term schema
- 여러 사건 교체 가능한 loader
- typed deduction slot
- contradiction/incomplete/valid-wrong/solved 판정
- save/load/migration
- TinIntegrationKit evidence/history/checkpoint 연결
- ModuleContext 입력 및 GameModule lifecycle
- stale content sanitize
- 사건 2개 이상으로 genericity 검증

### 원본 게임 리버스 엔지니어링의 위치

**기본 개발 경로에서 제외한다.**

튜토리얼 베이스로 구현 가능한 범위는 원본 리버스 엔지니어링 자료를 볼 필요가 없다.
다음 중 하나가 실제 blocker로 확인될 때만 원본 동작 분석을 추가한다.

- 튜토리얼에 없는 복잡한 clue grouping/word semantics
- 원작 특유의 다중 dossier 구조가 필요한 경우
- validation feedback 세부 동작이 설계상 반드시 필요한 경우
- drag/drop/focus/selection의 미묘한 UX를 그대로 분석해야 하는 경우

즉 기본 순서는:

`tutorial-gui-of-golden-idol 채택 → TIN 적응 → 부족한 subsystem 직접 구현`

이며, 원본 리버스 엔지니어링은 마지막 참고 수단이다.

### 중복 방지

TIN 내부 `TinIntegrationKit`에 이미 다음이 있다.

- `evidence_add`
- `evidence_has_all`
- `hotspot_visit`
- `dialogue_begin/current/next/choose/history`
- `timeline_mark/has`
- `checkpoint_save/load`
- `capture/restore`

따라서 이 기능을 범용 시스템으로 다시 만들지 않는다.


---

## 1. 완료 정의

아래가 되어야 시스템 완료.

- 사건 데이터를 코드 수정 없이 Resource/Dictionary로 정의
- 조사 가능한 scene/hotspot N개
- 증거 하나가 여러 사실 조각(fact)을 제공 가능
- 발견한 단어/이름/행동을 어휘 bank에 등록
- 추론 문장에 typed slot 배치
- slot별 후보군이 데이터에서 결정
- 답을 자유롭게 수정 가능
- 전체 정답 여부뿐 아니라 **모순/미완성/유효하지만 오답** 구분
- 사건마다 판정식을 데이터로 교체 가능
- UI가 정답을 자동으로 조립하지 않음
- 부분적으로 조사한 상태 저장/복원
- 사건 2개를 같은 엔진으로 실행
- 사건 A 전용 if문 없이 사건 B 추가 가능

---

## 2. 파일 구조

```
modules/<DEDUCTION_MODULE_ID>/
  module_manifest.tres
  entry.tscn
  module.gd

  domain/
    case_definition.gd
    scene_definition.gd
    hotspot_definition.gd
    evidence_definition.gd
    fact_definition.gd
    term_definition.gd
    deduction_template.gd
    deduction_slot.gd
    deduction_answer.gd
    validation_result.gd

  systems/
    investigation_state.gd
    evidence_index.gd
    term_bank.gd
    deduction_engine.gd
    case_loader.gd
    save_codec.gd

  presentation/
    scene_view.gd
    hotspot_view.gd
    evidence_panel.gd
    term_bank_panel.gd
    deduction_panel.gd
    feedback_panel.gd

  content/
    sample_case_01.tres
    sample_case_02.tres

tests/core/
  test_case_loader.gd
  test_evidence_index.gd
  test_term_bank.gd
  test_deduction_engine.gd
  test_deduction_save.gd
```

---

## 3. 사건 데이터

### CaseDefinition

```text
case_id
scenes[]
evidence[]
terms[]
deduction_templates[]
validation_rules[]
start_scene_id
```

### EvidenceDefinition

```text
id
display_key
source_hotspot_id
facts[]
terms_unlocked[]
optional: true/false
```

### FactDefinition

fact는 플레이어에게 자동으로 정답을 알려주는 문장이 아니라 엔진이 증거의 의미를 표현하는 구조화 데이터다.

```text
subject
relation
object
qualifiers{}
```

예:
```
subject=window
relation=state
object=locked_inside
```

### TermDefinition

```text
id
category: person | place | object | action | time | adjective | custom
display_key
aliases[]
```

DeductionSlot은 허용 category를 가진다.

---

## 4. 조사 상태

InvestigationState:

```text
current_scene_id
visited_scenes[]
visited_hotspots[]
discovered_evidence[]
unlocked_terms[]
answers{}
submission_count
case_state
```

case_state:
- exploring
- reconstructing
- solved

presentation state(스크롤 위치, hover)는 저장하지 않는다.

---

## 5. EvidenceIndex

책임:
- evidence id dedupe
- hotspot→evidence lookup
- evidence discovery
- discovered evidence query
- fact query
- optional/required 구분

발견 시:
1. hotspot visit
2. evidence id 검사
3. 처음이면 TinIntegrationKit.evidence_add에도 mirror
4. term unlock
5. observation이 필요한 경우 module.gd가 requested("observation") 방출

Kit은 보조 저장/통합 용도이며 module-specific deduction truth는 InvestigationState가 소유한다.

---

## 6. DeductionTemplate

추론 화면을 데이터로 정의.

예:
```text
template_id: "event"
parts:
  - literal: "At"
  - slot: {id:"place", categories:["place"]}
  - literal: ","
  - slot: {id:"person", categories:["person"]}
  - slot: {id:"action", categories:["action"]}
  - slot: {id:"object", categories:["object"]}
```

UI는 template을 렌더할 뿐 사건 로직을 알지 않는다.

---

## 7. 판정 엔진

DeductionEngine은 UI와 독립.

입력:
- CaseDefinition
- answers

출력 ValidationResult:

```text
status:
  incomplete
  contradiction
  valid_but_wrong
  solved

invalid_slots[]
contradictions[]
progress_signature
```

### 중요

Golden Idol류의 재미를 죽이지 않기 위해:
- "3/4 맞음" 같은 직접 점수는 기본 제공하지 않음
- 어떤 slot이 틀렸는지 자동 표시하지 않음
- validation engine은 내부적으로 정밀 결과를 반환하지만 presentation이 무엇을 공개할지는 case config가 결정
- 후보군을 조사 여부에 따라 지나치게 좁혀 정답을 자동 노출하지 않음

---

## 8. validation rule 표현

1차는 데이터 기반 exact constraint로 충분.

```text
all:
  - equals(slot_a, term_x)
  - equals(slot_b, term_y)
  - one_of(slot_c, [term_z, term_w])
  - not_equals(slot_d, term_q)
```

다음 단계 확장:
- relation fact 기반 조건
- multiple solution
- dependency
- conditional branch

validation rule을 Callable로 저장하지 않는다. JSON/Resource 기반 명세로 유지한다.

---

## 9. 샘플 사건

두 사건 모두 매우 작게 만들되 다른 구조를 사용한다.

### Case 01
- 장면 2
- hotspot 6
- evidence 5
- term 약 12
- deduction sentence 1
- exact solution 1

검증: 기본 조사→어휘→추론.

### Case 02
- 장면 3
- optional evidence 포함
- evidence 하나가 facts 2개 제공
- deduction template 2개
- 한 slot 후보가 여러 category를 허용
- optional evidence 없이도 해결 가능

검증: 엔진이 사건 1에 하드코딩되지 않았는지.

원작 사건·고유명사·문구 복제 금지.

---

## 10. 저장

schema v1:

```json
{
  "case_id":"sample_01",
  "current_scene_id":"room_a",
  "visited_scenes":[],
  "visited_hotspots":[],
  "discovered_evidence":[],
  "unlocked_terms":[],
  "answers":{},
  "submission_count":0,
  "case_state":"exploring"
}
```

CaseDefinition 자체는 저장하지 않는다.
현재 content definition + state를 결합한다.

content update로 삭제된 term/evidence id가 save에 있으면:
- unknown id 제거
- answer가 unknown term이면 해당 slot 비움
- crash 금지

---

## 11. 입력/UI

게임패드/키보드 모두 입력 라우팅 가능하게.

화면 모드:
- investigation
- evidence
- deduction

module.gd가 현재 mode를 소유.

ESC:
- TIN 공통 메뉴 우선
- 모듈 내부 back은 cancel action 사용
- 전역 Escape 직접 가로채지 않음

---

## 12. 테스트

### data
- duplicate ids 거부
- missing hotspot/evidence ref
- invalid term category
- invalid validation slot ref

### investigation
- hotspot 중복 조사
- evidence dedupe
- optional evidence
- term unlock

### deduction
- incomplete
- contradiction
- valid wrong
- solved
- answer 수정
- 두 case definition 교체

### save
- 조사 도중 round-trip
- deduction 도중 round-trip
- solved round-trip
- stale content id 복구

### spoiler
- 조사하지 않은 evidence의 fact가 UI state에 나타나지 않음
- engine의 invalid_slots를 기본 UI가 직접 표시하지 않음

---

## 13. 완료 금지 조건

- 사건 하나의 범인/수법/동기를 if문으로 직접 비교
- UI 버튼 id가 정답 의미를 소유
- evidence 3개를 모으면 자동으로 선택지가 1개만 남음
- 두 번째 사건 추가에 engine 코드 수정 필요
- TinIntegrationKit에 이미 있는 evidence/history/checkpoint를 또 범용 구현
- 외부 addon을 편하다는 이유만으로 autoload와 함께 설치
## 시각 구현 계약 — 2026-09-22

### 1차 레퍼런스
The Case of the Golden Idol의 조사 화면과 deduction/dossier 화면.

참조:
- 조사 장면과 추론 문서가 서로 다른 작업 모드로 명확히 느껴지는 구조
- 과도한 마커 없이 조사 지점을 찾게 하는 화면 밀도
- word bank가 강한 기능을 가지되 장면보다 먼저 보이지 않는 계층
- 문서/슬롯/단어가 텍스트 중심으로 정리되는 방식

### 화면 산출물
1. scene inspection
2. hotspot focus/inspection
3. evidence detail
4. term bank
5. deduction incomplete
6. contradiction/valid-wrong feedback
7. solved transition

### at-icons
- 인물, 가구, 흔적, 배경 소품은 collage
- 돋보기/문서/사람 icon을 hotspot/UI로 사용 금지
- hotspot은 구도, hover 변화, 오브젝트 애니메이션, 커서 반응으로 표시
- word bank/deduction slot은 text UI만 사용

조사 모드에서는 장면이 화면 대부분을 차지하고 필요할 때만 텍스트 패널을 연다. 모든 패널 상시 노출형 에디터 레이아웃은 금지.

### 완료 스크린샷
사건별 조사 장면 1장, evidence 열림 1장, deduction incomplete 1장, solved 직전 1장을 1152×720로 검수한다.

## UI 계약 보완 — 미구현 검수 항목

필수 입력: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). 아래는 AI 계획 보완이다.

- 소유: 위 파일 구조의 조사/추론 view와 해당 모듈 테스트. 입력 데이터는 선택 사건·조사한 증거·플레이어 배치·허용된 판정 메시지이며 정답 데이터는 표시 모델에 넘기지 않는다.
- 현장에서는 선택 조사물이 1차 초점, 추론에서는 빈칸과 현재 배치가 1차 초점이다. 증거 전문은 조사/선택 시 표시하고 전체 단서를 상시 펼치지 않는다.
- 어휘 선택→슬롯 지정→확정/취소는 드래그와 동일한 의도 경로를 사용한다. 취소는 배치 변경 없이 원래 어휘/슬롯으로 돌아간다. 사건 전환 시 다른 사건의 선택/툴팁/초안을 표시하지 않는다.
- 검증: 빈 어휘 목록, 긴 증거 문서, 스크롤 밖 focus, 타입 불일치 배치, 오답→재조사→수정, A→B→A 복귀, 미조사 fact 비노출. 색과 슬롯 강조만으로 정답 위치를 누설하지 않는다.

## 레퍼런스 직접 적용 — 현장·요약·전문, 어휘에서 슬롯으로

[보고서 적용 지도](../../docs/UI_REFERENCE_ADAPTATIONS.md)의 Destiny 3단계 상세 공개, Persona 5의 선택→본문 시선 경로, 카드 focus/tooltip/target 패턴을 Golden Idol 조사/추론 구조에 적용한다. 아래 배치는 **TIN 설계안**이며 Destiny 화면의 복제 수치가 아니다.

**현장 모드:** 기존 약 800px 장면 + 300px 선택 문서 구획을 사용한다. 미선택 때 문서 면은 접어 장면을 우선한다. 대상 hover/focus는 오브젝트 외곽과 이름만 보여준다. 아직 조사하지 않은 증거의 사실을 hover로 노출하지 않는다. 조사 확정 후 오른쪽 면에 제목·관찰 요약·“전문/닫기”가 나타난다. 전문은 같은 면을 확장한 읽기 화면이며 취소 한 번으로 요약, 다시 취소하면 원래 현장 대상에 돌아간다.

**추론 모드:** 중앙 문서의 문장/빈칸이 작업 공간, 하단은 어휘 목록이다. 조사 모드에서 넘어오면 이전에 수정하던 슬롯을 보존하고 첫 진입이면 첫 빈 슬롯으로 간다. 사건명과 “현장/추론” 텍스트는 현재 위치를 드러내되 개발용 탭 바처럼 모든 기능을 늘어놓지 않는다.

어휘에 focus하면 선택 어휘의 밑줄과 위쪽 문서의 현재 슬롯이 같은 정렬축에서 읽히게 한다. 짧은 어휘 설명은 하단 목록 위 로컬 설명 면 하나에 표시한다. “배치”로 대상 선택을 시작하면 선택 어휘는 남고 슬롯 사이로 focus가 이동한다. 슬롯 테두리는 타입상 배치 가능한지만 구별하며 정답 여부는 표시하지 않는다. 확인은 배치, 취소는 변경 없이 원래 어휘로 복귀한다. 드래그도 같은 preview/commit/cancel을 사용하고 놓을 수 없는 곳에 놓으면 기존 배치를 유지한다.

Persona 5의 명도 계층은 현재 슬롯/어휘의 높은 대비 → 문서 본문 → 보조 설명 순서로 적용한다. 사선 장식과 원작 팔레트는 쓰지 않는다. 긴 증거는 본문만 스크롤하고 제목·닫기는 남긴다. 어휘를 바꾸면 tooltip의 이전 텍스트와 스크롤을 초기화한다.

**판정:** 미완성은 비어 있는 슬롯으로 돌아갈 수 있는 짧은 설명, 모순/그럴듯한 오답은 문서 하단 판정문으로 알린다. 틀린 슬롯을 자동 강조하지 않는다. 해결은 220ms 정도 문서 확정 피드백 후 결과를 유지한다. 자동으로 다른 사건에 보내지 않는다. A→B→A는 사건별 진행을 복원하되 상세창을 닫고 해당 사건의 유효 선택으로 돌아간다.

검수 과제: 증거 한 개 조사→전문 읽기→현장 복귀, 어휘 선택→잘못된 대상→취소, 오답→현장 재조사→같은 슬롯 수정, A/B 전환. 마우스와 키보드/패드가 동일한 정보 깊이와 배치 결과를 제공해야 한다. 소유는 이 모듈의 view/테스트이며 전역 tooltip이나 사건 간 공용 엔진은 이 UI 채택의 조건이 아니다.
