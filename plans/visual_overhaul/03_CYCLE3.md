# 배치 03 — 사이클 3 13모듈 시각 개편

UI 작업 계약: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). UI 변경이 있는 실행 계획은 화면별 계약과 검수 증거를 구체화한다. 후보/아이디어는 구현 계획 승격 시 적용한다.

| 모듈 | 1차 레퍼런스 | 화면 개편 지시 |
|---|---|---|
| numberless_clock | Chants of Sennaar | 기호 규칙이 시계 UI가 아니라 공간/물체 배열로 읽히게. |
| shadow_ferry | The Witness | 세 그림자의 차이를 설명문 없이 형태/길이/배치로 읽게. |
| receipt_orchard | Papers, Please | 종이·영수증·열매 순서가 손에 잡히는 물체처럼 보이게. 슬롯 아이콘 금지. |
| wrong_weather | There Is No Game: Wrong Dimension | 방송 화면과 실제 날씨가 충돌하는 시각 개그를 화면 변화로 표현. |
| quiet_locker | The Case of the Golden Idol | 사물함/잡동사니를 촘촘한 조사 장면으로. 조사 마커 아이콘 금지. |
| memory_customs | Papers, Please | 세관 부스/도장/몸·기억 판정을 서류와 공간 staging으로. |
| paper_moon_clinic | Strange Horticulture | 진찰 오브젝트를 탁자/환자/기록 공간에 배치. 카드 버튼 나열 금지. |
| afterimage_aquarium | The Witness | 물고기와 잔상 방향 차이를 시각 관찰로 해결. 화살표 UI 금지. |
| paper_lighthouse | The Witness | 자기 그림자 비교가 화면 중심. 정답 후보 아이콘 버튼 금지. |
| lost_signal_vn | In Stars and Time | 캐릭터 staging + 텍스트 박스 위계. 초상 아이콘 금지. |
| violet_case | The Case of the Golden Idol | 증거가 실제 장면과 dossier에서 연결. 범인/수법/동기 아이콘화 금지. |
| after_signal | The Case of the Golden Idol | 후일담 흔적을 카드 목록이 아니라 조사 가능한 물건/장면으로. |
| return_address | Papers, Please | 주소 세 칸을 서류/봉투 작업처럼 구성. 각 칸 의미 아이콘 금지. |

## 월드 아트 최소선
모듈마다:
- 화면 초점 오브젝트 1개 이상 at-icons collage
- 장소성을 주는 배경 오브젝트 2개 이상
- 클릭 대상이 Label/ColorRect만으로 존재하지 않음
- hover는 밝기/위치/scale 변화로 표현 가능하나 icon marker 추가 금지

## 기능 보존
deduction, save, route, observation, death/return 규칙은 바꾸지 않는다. presentation state를 추가할 수 있으나 domain truth를 UI node로 옮기지 않는다.

## 완료
13모듈 각각 idle + 핵심 interaction + 결과/전환 화면을 1152×720로 검수한다.

## 보고서 패턴 적용 — 읽기·선택·실패 장면의 실제 구조

[보고서 전체 적용 지도](../../docs/UI_REFERENCE_ADAPTATIONS.md). 아래는 해당 모듈에서 구현할 AI UI 설계안이다. C0/C1/C2 콘텐츠 상태는 [콘텐츠 보완](../implementation_improvements/01_CONTENT_AND_CONTINUITY.md)을 따른다.

**violet_case:** Destiny식 제목→선택 요약→전문 구조를 사건 파일에 적용한다. 파일을 focus하면 제목과 현재 상태만, 열면 그 사건의 현장/추론으로 들어간다. 조사 대상 이름→조사 요약→전문을 단계화하고 “확정 사실”과 “미확정 이론”을 별도 제목 아래에 둔다. 이론 선택에도 정답 완료와 같은 도장/강한 모션을 주지 않는다. Persona 5식 기준선은 현재 범인/수법/동기 선택과 읽는 문장 사이만 연결한다. 사건을 바꿨다가 돌아와도 다른 사건의 전문/선택이 섞이지 않아야 한다.

**quiet_locker / after_signal:** 물건 hover/focus는 이름과 약한 테두리만, 확인하면 기존 하단 조사문 위치에 관찰을 표시한다. 다시 조사하면 같은 면의 재관찰 문장으로 교체한다. Destiny식 선택 상세를 사용하지만 모든 물건의 카드 목록이나 수집률을 만들지 않는다. Metaphor식으로 일상 재조사는 작은 교체, authored 조합 반응은 해당 두 물건의 순차 강조로 구분한다. UI가 아직 모르는 조합 쌍을 선으로 연결하지 않는다.

**lost_signal_vn:** 보고서의 내러티브 dialogue/choices/history를 실제 화면에 적용한다. 상단 약 2/3은 캐릭터와 장소, 하단 약 1/3은 화자·현재 대사·선택지다. focus 중 선택지는 밑줄과 좌측 기준선으로 본문에 연결되며 확정한 선택만 잠깐 고정한 뒤 NPC 반응으로 이동한다(Persona 5/Metaphor). 확인 첫 입력은 현재 글자 표시 완료, 완료 후 다음 입력이 진행이다. 기록 요청은 읽기 전용 면, 닫기는 원래 대사/선택지로 복귀한다. 자동 진행과 글자 속도는 별도 설정이며 선택지는 자동 확정하지 않는다. 기존 저장 상태를 넘어서 history 저장이 필요하면 해당 모듈 작업에서 schema 범위를 먼저 명시한다.

**wrong_weather:** 방송문 선택→확정 140ms→해당 authored 방송 사고/날씨 반응 순서로 표시한다. 오답은 중앙 “실패” 모달 대신 방송면의 짧은 원인/대사와 실제 현상 변화다. 기존 선택 위치를 남겨 바로 수정할 수 있게 한다. 강한 모션을 오답마다 화면 전체에 반복하지 않는다.

**receipt_orchard / memory_customs / return_address:** 보고서의 직접 조작·target indicator·되돌리기를 서류 작업에 적용한다. 손에 든 종이/도장/단어 → 현재 대상 칸의 테두리 → 확인 후 실제 배치/도장 변화로 이어진다. 취소는 대상 선택만 해제하고 이미 확정한 다른 칸을 지우지 않는다. focus는 실제 작업 순서로 이동하며 정답 칸 추천은 하지 않는다. 실패 후 틀린 부분을 사용자가 다시 선택할 수 있고 전체 초기화를 강요하지 않는다.

shadow_ferry/afterimage_aquarium/paper_lighthouse에는 목표 표시나 tooltip으로 관찰 답을 덧씌우지 않는다. 이들은 기존 시각 비교 자체가 주 과제다. 장면별 선택→상세/확정→오답→수정/취소의 연속 캡처와 키보드/패드 실행으로 검수한다.
