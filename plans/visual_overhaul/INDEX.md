# 기존 작업물 시각 개편 — 인덱스

공통 기준:
- docs/VISUAL_DIRECTION.md
- PROJECT_DECISIONS.md
- AGENTS.md

목표는 기존 게임 로직을 갈아엎는 것이 아니라 기능이 이미 있는 28개 모듈과 AppRoot를 "기능 데모 화면"에서 "게임 화면"으로 끌어올리는 것이다.

## 순서
1. 00_BASELINE_ASSET_PIPELINE.md
2. 01_APP_ENTRY.md
3. 02_ROUTE_SETS.md
4. 03_CYCLE3.md
5. 04_DEMOS_3D.md

같은 shared/app 파일을 여러 작업자가 동시에 수정하지 않는다.

## 공통 완료 조건
- 변경 전 1152×720 baseline 캡처
- 지정된 상용 게임 실제 화면 확인
- 월드 placeholder 제거
- at-icons 콜라주 적용
- UI icon 0개
- 원래 뜻 그대로 쓴 icon 0개
- input/save/state 계약 유지
- import → integration → GUT → smoke
- 영향 장면 idle / interaction / result 스크린샷 확인

## 범위 금지
시각 개편 중 범용 UI framework, 범용 sprite composer, 전역 theme engine, 새 autoload, 전체 모듈 공용 EventBus를 만들지 않는다. 두 번째 실제 재사용 사례가 확인될 때만 작은 공용화를 검토한다.
