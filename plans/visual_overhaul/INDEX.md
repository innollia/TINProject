# 기존 작업물 시각 개편 — 인덱스

UI 작업 계약: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). UI 변경이 있는 실행 계획은 화면별 계약과 검수 증거를 구체화한다. 후보/아이디어는 구현 계획 승격 시 적용한다.

공통 기준:
- docs/VISUAL_DIRECTION.md
- PROJECT_DECISIONS.md
- AGENTS.md

현재 AppRoot catalog는 34개 모듈이다(플레이 29 + first_entry + game_library + 데모 3). 이 트랙은 화면을 담당하며, 게임성 보완은 [게임별 플레이 재설계](../implementation_improvements/03_GAMEPLAY_DEPTH.md)와 함께 진행한다. 화면만 교체하고 얕은 정답 입력 구조를 완료품으로 유지하지 않는다.

## 순서
1. 00_BASELINE_ASSET_PIPELINE.md
2. 01_APP_ENTRY.md
3. 02_ROUTE_SETS.md
4. 03_CYCLE3.md
5. 게임형 5종은 각 game_modules 계획의 시스템·화면을 함께 검수
6. game_library와 누락 상태는 [셸·시각 검수 보완](../implementation_improvements/02_SHELL_AND_VISUAL_ACCEPTANCE.md)
7. 04_DEMOS_3D.md는 데모 무수정 회귀/현황 확인만 수행

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
