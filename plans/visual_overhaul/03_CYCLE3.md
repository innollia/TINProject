# 배치 03 — 사이클 3 13모듈 시각 개편

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
