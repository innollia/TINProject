# 계획 02 — 추리/사건 재구성 게임형 모듈

공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스: **The Case of the Golden Idol**  
목표: 사건 하나를 만드는 것이 아니라 **여러 사건을 데이터만 교체해 작성할 수 있는 조사·증거·어휘·추론·검증 시스템**을 만든다.

> 작업 ID 미정. 구현 경로는 `modules/<DEDUCTION_MODULE_ID>/`.

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
