# 기존 콘텐츠와 연속성 보완

UI 작업 계약: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). UI 변경이 있는 실행 계획은 화면별 계약과 검수 증거를 구체화한다. 후보/아이디어는 구현 계획 승격 시 적용한다.

공통 설계 원칙: [DESIGN_PHILOSOPHY](../../docs/DESIGN_PHILOSOPHY.md). 소재 원문과 확장 후보는 [기존 콘텐츠 계획](../content_expansion/01_EXISTING_MODULES.md)을 유지한다. 아래 파일명·schema·배치는 AI 구현 제안이다.

## C0 — violet_case 완료 범위와 후속 작업

현재 `modules/violet_case/module.gd`는 사건 3개와 사건별 상태를 가지며 manifest save_version은 2다. `tests/core/test_cycle3_modules.gd`에 사건 독립 상태 및 Case 02 미확정 이론 검증이 있다. 이를 새로 만드는 작업을 반복하지 않는다.

후속 소유: `modules/violet_case/**`, 신규 `tests/core/test_violet_case_content.gd`.

- Case 03의 관찰·가설 선택·틀린 판정→수정→저장 복원 경로를 명시적으로 검증한다. Case 02 테스트만으로 Case 03까지 검증됐다고 간주하지 않는다.
- 01→02→03→01 왕복에서 조사/선택/완료가 섞이지 않고, 어느 사건에서도 back이 작동하는지 검증한다.
- v1 저장을 v2로 이관할 때 Case 01 진행 유지, 신규 사건 초기화, 알 수 없는 ID 정리를 확인한다.
- 미확정 이론이 solved로 바뀌거나 글로벌 관찰에 확정 사실처럼 실리지 않는지 확인한다.
- 화면은 기존 시각 배치 03의 사건 장면/문서/추론 화면으로 보완한다. 범용 추리 엔진 전환은 D1 소유이며 C0에서 두 모듈을 결합하지 않는다.

## C1 — paper_moon_clinic

현재 구현: `SYMPTOMS/FINDINGS`, `selected`, `inspected[3]`. 현 환자 조사는 보존하되 환자별 검사 결과를 담을 공간이 필요하다.

소유: `modules/paper_moon_clinic/**`, 신규 `tests/core/test_clinic_patients.gd`. 기존 `test_cycle3_modules.gd`의 종이달 회귀는 유지한다.

새 로컬 파일: `content/patients.gd`, `systems/examination_state.gd`. 첫 단계에서 종이달과 순서에 따라 관찰이 달라지는 손 떨림 환자만 fixture로 구현한 후 나머지 환자를 데이터로 추가한다.

데이터: `patient_id`, `examinations[{id, prerequisites, effects, observation_id}]`, `order_reactions`, `optional_questions`, `exit_policy`. 상태: `current_patient_id`, `patients{ id: {examined_ids, examination_order, settings, findings, notes} }`. 검사는 `inspect(patient_id, examination_id)`로 요청하고, 유효성 확인 후 효과를 원자적으로 적용한다. 잘못된 ID·조건 미충족은 상태를 바꾸지 않는다.

전이: 환자 선택→검사→관찰 기록→재검사/다른 환자/나가기. 종이달은 기존 세 증상 완료 경로를 유지한다. 신규 환자는 최소 한 검사 후 나갈 수 있도록 제안하며 전체 환자 완료를 출구 조건으로 두지 않는다. 원인 미확정 결과도 정상 종료다.

저장 v1→v2: `selected/inspected`를 종이달 환자에 매핑하고 신규 환자는 초기화한다. 조사 순서가 옛 저장에 없으면 가상의 순서를 만들지 않고 빈 이력으로 둔다. 중복 observation은 stable ID로 막는다. reset은 모듈 환자 상태만 초기화하고 전역 기록 삭제를 요청하지 않는다.

실패 경로: 검사 순서 역전·반복, 빈 환자 파일, 제거된 검사 ID, 선택 환자 삭제, 저장 후 데이터 순서 변경. 살아 있는 ID의 기록은 유지하고 현재 환자/포커스만 유효한 곳으로 복귀한다.

화면(1152×720): Strange Horticulture의 조사 책상 화면을 확인한다. 왼쪽 720px은 환자·검사 도구, 오른쪽 360px은 펼친 기록, 하단 80px은 짧은 입력 안내를 기본값으로 삼는다. 첫 초점은 환자다. 검사 전/선택/반응/원인 미확정/환자 전환을 캡처한다. 검사 결과는 환자 형태·반응으로 먼저 보이고 기록은 이를 보충한다. 월드 환자/도구는 모듈 로컬 콜라주, UI는 텍스트다.

완료: 환자 A/B의 독립 상태, 순서별 서로 다른 관찰, 부분 검사 저장·재진입, 입력 차단, 초기 상태/중간 상태 reset을 검증한 뒤 5환자 데이터 증설로 진행한다. 15~25분은 기존 AI 분량 제안이며 실제 플레이 확인 전 달성으로 쓰지 않는다.

## C2 — quiet_locker

소유: `modules/quiet_locker/**`, 신규 `tests/core/test_locker_optional.gd`. 현재 `inspected[3]` 필수 흔적을 보존한다.

새 데이터 `content/objects.gd`: `id`, `required`, `first_text`, `repeat_text`, `visible_if`, `pair_reactions`. 상태 v2: 기존 `inspected` + `inspection_counts{id:0..2}`, `last_object_id`, `seen_reactions[]`. 표시 선택은 ID 기준으로 보관한다. `inspect(id)`는 존재/가시성/입력 허용을 먼저 검사한다.

첫 fixture: 필수 3칸 + 손톱깎이 2개 + 모루/도색 가루. 연속 조사는 직전 대상과 현재 대상의 순서쌍으로 판단한다. 다른 조사 끼워넣기는 연속으로 계산하지 않는다. 이후 기존 소재 목록의 8~12개로 확장한다. 엄지용 등장 조건과 문구는 AI 제안으로 유지한다.

v1 이관은 필수 `inspected`만 유지하고 선택 사물 이력은 비운다. 필수 3칸 조사 뒤 명시적인 나가기 동작을 제공해 새 선택 사물을 보기 전에 자동 이탈하지 않게 한다. optional 완료율·보상·다음 라우트 조건은 추가하지 않는다.

화면: Golden Idol 조사 장면의 대상 밀도를 확인한다. 사물함이 중경, 바닥 소품이 전경, 창문 고양이가 배경이다. 하단 조사문 이외의 목록 패널을 상시 두지 않는다. 닫힘→열림→사물 선택→재조사→연속 조사 반응→귀환 상태를 캡처한다.

완료: 선택 사물 0개로 통과, 전부 조사해도 경로 동일, 연속/비연속 반응 구분, 두 번째 관찰 저장 후 재현, 제거된 사물 ID 복구, reset/입력 차단 검증.

## C3 — 소규모 장면 전반

| 대상 | 보완 단위 | 검증 |
|---|---|---|
| wrong_weather | 기존 정답과 귀환을 보존하고 오답 방송별 현상 반응 추가 | 각 오답→재선택 성공, 보상/해금 없음 |
| after_signal | 기존 필수 흔적과 별도인 선택 물건 데이터 | 선택 0개 귀환, 관찰 중복 방지 |
| teacup_orbit | 회전/받침/온도/빈 잔 반응 | 기존 회전 횟수·측면 경로 회귀, 신규 행동이 카운터/보상을 늘리지 않음 |
| numberless_clock / switchboard_choir / glasshouse_return / maintenance_cut | 이미 있는 지식 경로를 시각 개편 후 다시 검증 | fresh-state solve, 기록 없는 상태, 홀드/오답 뒤 복구 |
| shadow_ferry / afterimage_aquarium / paper_lighthouse | 시각 비교가 문구 없이 가능한지 확인 | 같은 정답·무타이밍, 카메라/색 변화에도 판별 가능 |
| receipt_orchard / memory_customs / return_address | 배열·도장·주소 수정 가능성 보존 | 오답→부분 수정→복원→재판정 |
| lost_signal_vn | 분기별 대사/신뢰/저장 검수 | 다른 선택, 중간 복원, 관찰 중복·막힌 귀환 없음 |

각 행은 해당 모듈 폴더와 기존 cycle2/3 테스트 범위만 소유한다. 신규 보완을 한 번에 묶지 않고 한 행씩 끝낸다. 라우트 세트 및 첫 진입 화면은 기존 시각 계획 01/02를 따르며 기능 확장은 요구하지 않는다.

## C1 UI 상세 적용 — 환자에서 검사, 검사에서 기록으로

[보고서 적용 지도](../../docs/UI_REFERENCE_ADAPTATIONS.md)의 전략 SelectionModel→Inspector, 시뮬레이션 값/변화/원인/조치, Destiny 상세 공개를 paper_moon_clinic에 적용한다. 기존 Strange Horticulture 책상 구획(환자·도구 약 720px / 기록 약 360px)을 유지하는 **AI 설계안**이다.

환자 선택 전에는 환자 이름 목록만 펼치고, 선택하면 목록을 접어 환자와 검사 도구를 본다. 환자 자체가 1차 초점이며 검사 도구 focus 시 가능한 검사명과 이미 알려진 전제만 나타난다. 확정 시 먼저 환자의 실제 반응을 보여주고 오른쪽 기록의 해당 행을 갱신한다. 기록의 행은 “검사 / 이전 관찰 / 이번 관찰”로 나란히 읽는다. 수치가 정의되지 않은 증상에는 숫자 게이지/추세 그래프를 만들지 않는다.

원인은 기록 아래 별도 문장으로 “미확정”을 유지할 수 있고, 다음 행동은 재검사/다른 검사/환자 바꾸기다. UI가 정답 검사 순서를 추천하지 않는다. 행 focus는 짧은 요약, 상세 열기는 해당 관찰 전문과 실행 순서를 읽는 면으로 확장한다. 전문 닫기는 같은 검사 행, 검사 면 닫기는 해당 환자로 복귀한다. 환자 A→B→A 시 독립 검사 기록을 표시하고 이전 환자의 tooltip을 즉시 비운다.

선택 밑줄 80ms < 검사 확정 140ms < 새로운 authored 반응 220ms의 강도를 시작값으로 삼는다. 반복 검사는 이미 알려진 반응을 과장하지 않고, 실패는 실행 불가 이유를 선택 도구 옆에 남겨 바로 다른 검사를 고르게 한다. 감소 모드에서도 환자 반응 전후와 기록 갱신을 읽을 수 있어야 한다.

검수 과제: 종이달→검사→전문→닫기, 손 떨림 환자의 검사 순서 반전→전/후 행 비교, 원인 미확정 상태로 이탈, 긴 기록과 환자 삭제 후 focus. C0/C2의 구체 UI는 [시각 배치 03](../visual_overhaul/03_CYCLE3.md)의 violet_case/quiet_locker 절을 함께 사용한다.
