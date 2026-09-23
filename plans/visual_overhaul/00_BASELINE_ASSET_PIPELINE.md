# 배치 00 — Baseline / at-icons 투입 준비

UI 작업 계약: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). UI 변경이 있는 실행 계획은 화면별 계약과 검수 증거를 구체화한다. 후보/아이디어는 구현 계획 승격 시 적용한다.

## 목적
시각 개편 전에 현재 화면과 에셋 사용 경계를 고정한다.

## A. baseline
AppRoot, records overlay, settings/pause, catalog의 34개 모듈 첫 화면을 1152×720로 캡처한다. first_entry는 `manifest.tres`를 사용하므로 `module_manifest.tres` 검색에서 누락하지 않는다. game_library HOME/전체목록과 게임형 5종의 결과/실패/복원 상태를 포함한다.

## B. at-icons 확인
- res://addons/at-icons/ 존재 확인
- LICENSE와 MIT 고지 확인/보존
- 파일 형식 구조 파악
- 원본 에셋 직접 수정 금지

경로/라이선스가 없으면 다른 아이콘 라이브러리를 임의로 대체하지 않고 visual asset pass를 중단한다.

## C. collage proof
게임 로직과 무관한 module-local test scene에서:
1. 사람형 실루엣
2. 작은 집/방 오브젝트
3. 기계/가구 오브젝트

를 만든다.

조건:
- 주요 오브젝트는 최소 2종 원본 조각
- 원본 의미 그대로 사용 금지
- UI icon 없음
- 1152×720에서 읽힘

proof는 공용 runtime으로 승격하지 않는다.

## 완료
asset path/license 확인, baseline, 3종 collage proof가 모두 있어야 한다.
