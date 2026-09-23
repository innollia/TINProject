# 배치 02 — 기존 두 세트 시각 개편

UI 작업 계약: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). UI 변경이 있는 실행 계획은 화면별 계약과 검수 증거를 구체화한다. 후보/아이디어는 구현 계획 승격 시 적용한다.

## 끊어진 항로

| 모듈 | 1차 레퍼런스 | 개편 초점 |
|---|---|---|
| signal_desk | Papers, Please | 작업대/신호 장치를 실제 공간으로. 버튼 목록 대신 물리적 장치와 텍스트 판독. |
| relay_quay | West of Loathing | 부두/인물/사물을 단순하지만 강한 실루엣으로. |
| last_echo | In Stars and Time | 죽음 직전 장면의 캐릭터/공간 초점과 반복 가능한 staging. |
| return_cradle | In Stars and Time | 귀환 공간을 기억 가능한 장소로 만들고 identity 연속성을 같은 캐릭터 collage로 표현. |
| maintenance_cut | Mosa Lina | 통로/장애물/상호작용 대상을 실루엣만으로 읽히게. |

공통:
- 길찾기 화살표 UI 금지
- interact icon 금지
- 오브젝트 자체의 위치/움직임/텍스트로 affordance 제공

## 접힌 오후

| 모듈 | 1차 레퍼런스 | 개편 초점 |
|---|---|---|
| glyph_gallery | Chants of Sennaar | 기호가 벽/사물/공간에 붙어 있는 환경 언어. |
| switchboard_choir | Papers, Please | 조작대 정보 계층. switch icon 대신 실제 장치/텍스트 라벨. |
| rain_lift | There Is No Game: Wrong Dimension | 엘리베이터 화면 자체가 이상 현상의 무대가 되게. |
| borrowed_title | Chants of Sennaar | 글자/제목이 UI가 아니라 월드 오브젝트로 작동. |
| glasshouse_return | Strange Horticulture | 식물/유리/탁자/메모가 한 장면에 밀도 있게 존재. |
| teacup_orbit | There Is No Game: Wrong Dimension | 찻잔 하나가 화면의 물리적 장난감처럼 느껴지게. |

## at-icons 최소선
각 모듈에서 배경/공간 덩어리 1세트, 초점 오브젝트 1개, 선택 소품 2개 이상을 collage로 만든다. 원본 glyph를 의미 그대로 사용하지 않는다.

## 완료
각 모듈마다 idle 1장 + 핵심 interaction 1장 + result/transition 1장을 1152×720로 확인한다.

## 보고서 패턴 적용 — 장치 안의 정보와 요청할 때의 설명

[Dead Space 문맥 UI 분석](../../docs/UI_REFERENCE_ADAPTATIONS.md)을 기존 조작대에 직접 적용한다. 아래는 TIN 설계안이며 실제 원작 장치를 모사하지 않는다.

- **signal_desk:** 평상시는 작업대와 신호 장치만 남긴다. 선택 장치의 실제 판독부에 현재 읽을 신호가 보이고, focus하면 그 판독부 바로 아래에 현재 가능한 행동명만 붙인다. 행동 확정 후 판독부/장치 반응이 바뀌고 이전 안내는 닫힌다. 별도의 우측 상태 대시보드를 두지 않는다. “설명” 요청은 현재 관찰한 판독의 텍스트만 열고 숨은 항로를 해설하지 않는다.
- **switchboard_choir:** 선택 접점은 외곽선, 연결/확정은 실제 조작대 반응으로 구분한다. 여러 장치 상태를 작은 HUD 아이콘에 복제하지 않는다. 행동 불가 이유는 선택 접점 옆, 긴 설명은 하단 읽기 면에만 표시한다. 패드 focus와 마우스가 같은 접점/안내를 선택하고 취소하면 조작대 탐색으로 돌아간다.
- **glasshouse_return:** 식물/메모를 선택하면 이름만, 조사 확정하면 텍스트 요약, 전문 요청 시 메모 읽기로 깊어진다(Destiny식 disclosure). 전문을 닫을 때 원래 식물/메모에 복귀한다. 지식 순서를 올바르게 수행했는지 UI가 미리 정답 추천으로 알려주지 않는다.
- **last_echo → return_cradle:** Metaphor의 사건별 강도는 죽음/귀환을 일상 focus와 구분하는 데 쓴다. 죽음은 캐릭터의 현장 반응, 귀환은 같은 정체성 실루엣의 재등장과 공간 고정으로 연결한다. 승패 알림창을 사이에 삽입하지 않는다. 기존 전환 시점/저장 규칙은 그대로 두고 감소 모드에서도 전후 장소와 캐릭터가 읽히게 한다.

각 적용은 선택 전/이름 표시/설명 열림/행동 후/취소 복귀를 캡처한다. 나머지 세트 장면에는 같은 패턴을 억지로 넣지 않고 기존 월드 중심 계획을 유지한다.
