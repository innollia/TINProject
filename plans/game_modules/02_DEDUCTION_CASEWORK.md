# 계획 02 — 추리/사건 재구성 게임형 모듈

레퍼런스: **The Case of the Golden Idol**  
목표: 사건 하나를 만드는 것이 아니라 **여러 사건을 데이터만 교체해 작성할 수 있는 조사·증거·어휘·추론·검증 시스템**을 만든다.

> 작업 ID 미정. 구현 경로는 `modules/<DEDUCTION_MODULE_ID>/`.

---

## 0. 기존 베이스 우선 사용

### TIN 내부에서 이미 존재하는 기능

`TinIntegrationKit`에 이미 다음 기능이 있다.

- `evidence_add`
- `evidence_has_all`
- `hotspot_visit`
- `dialogue_begin/current/next/choose/history`
- `timeline_mark/has`
- `checkpoint_save/load`
- `capture/restore`

따라서 이 기능을 다시 범용 시스템으로 구현하지 않는다.

단, 현재 evidence 기능은 **id→payload 저장** 수준이므로 Golden Idol형 추론 엔진을 대신하지 않는다.

### 외부 후보

Dialogue Manager:
- repository: `nathanhoad/godot_dialogue_manager`
- MIT
- 현재 main은 Godot 4.6+
- 조사 시점 HEAD: `934ff537cee96e1484a2430066b685283999d40c`

TIN에는 이미 Dialogue Manager류 기능을 내부 경량 어댑터로 이식한 상태다. **이번 모듈 때문에 외부 addon을 추가하지 않는 것을 기본값**으로 한다.

구현 시작 시 deduction/case-board 전용 permissive 프로젝트를 최소 3개 더 조사한다.
적합한 데이터 모델이나 UI component가 있으면 모듈 내부에만 도입한다.

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
