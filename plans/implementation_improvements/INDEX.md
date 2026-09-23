# 구현본 보완 계획 — 2026-09-22

UI 작업 계약: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). UI 변경이 있는 실행 계획은 화면별 계약과 검수 증거를 구체화한다. 후보/아이디어는 구현 계획 승격 시 적용한다.

공통 설계 원칙: [DESIGN_PHILOSOPHY](../../docs/DESIGN_PHILOSOPHY.md). 필수 계약: [MODULE_CONTRACT](../../docs/MODULE_CONTRACT.md), [VISUAL_DIRECTION](../../docs/VISUAL_DIRECTION.md), [AGENTS](../../AGENTS.md).

이 문서는 현재 구현에서 다음 작업을 고르는 진입점이다. 상세 시스템 명세는 기존 `game_modules` 계획을 보강해 사용하고, 기존 콘텐츠·시각 계획을 중복 구현하지 않는다. 아래 작업 순서는 **AI 제안**이며 게임 내 라우트나 사용자 확정 설정을 변경하지 않는다.

## 확인한 기준선

- 구현 기록: AppRoot `NORMAL_IDS` 기준 총 34개 = 플레이 29개 + first_entry + game_library + 데모 3개. 게임 목록은 32개다. `first_entry/manifest.tres`는 다른 33개의 `module_manifest.tres`와 파일명이 다르므로 파일명 검색만으로 집계하지 않는다.
- 2026-09-22 작업 전 기준선: import 종료 0, 통합 644/644, GUT 139/139·4,849 assertions, smoke 종료 0. 출력에 SCRIPT ERROR/ERROR 없음.
- 현재 검증: R1 runtime fallback 수정 후 import 종료 0, 통합 644/644, GUT 160/160·5,121 assertions, smoke 종료 0. v3 격자 저장/복원과 알 수 없는 level ID의 초기 상태 fallback을 확인했다. 기존 세이브가 없다는 사용자 결정에 따라 v2 호환 fixture/migration은 두지 않는다.
- 현재 R1 결과: `rule_rewriting`은 JSON 격자 레벨, module-local typed entity/state, runtime parser·다중 YOU 이동 solver, PUSH/STOP 충돌, WIN 접촉, undo와 v3 grid save/load까지 연결했다. 두 authored level 파일이 있으며 두 번째 레벨의 runtime 진입, NOUN 변환/MOVE/DEFEAT, 시각 검수가 남아 있다. 사용자가 기존 저장이 없다고 확인해 v2 호환을 위한 `legacy_state`/fixture 유지 의무는 없다. 외부 코드 4개 후보를 비교했으며 채택 파일은 없다. D1 결과: `dedution_casework`는 두 사건 `.tres` 번들, 유효성 검사 loader, 3/4개 가변 판정 슬롯, 선택지 간 모순, 사건별 저장, ID 기반 이벤트·slot·term 복원과 v2→v3 배열 호환을 구현했다. P1 결과: `physics_toolbox`에 두 배치 경로, 물체 위치·접촉·목표 영역 판정, 목표 밖 실패, 물리 snapshot 저장/복원을 구현했다. T1 결과: `time_loop`에 persistent 기억과 loop-local 관찰/세계 상태 분리, 재관찰 조건부 alternate route, 상태 복원을 구현했다. O1 결과: `odd_road_adventure`에 안내인 재회 후 붉은 실로 사당을 건너뛰는 역 우회 경로와 원자적 아이템 실패 상태를 구현했다. 모든 모듈의 시각 검수는 남아 있다.
- `addons/at-icons/LICENSE.txt`의 MIT 원문과 경로 확인. R1은 1152×720에서 도입/격자 두 상태를 직접 띄워 확인했고 현재 텍스트형 격자가 잘리지 않는 것을 검토했다. 이는 구현 전 baseline이나 레퍼런스 대조가 아니며, 보드 시각화와 입력·실패·성공 상태 검수는 남아 있다. 다른 모듈의 시각 검수도 남아 있다.
- 외부 후보 정보는 기존 계획/`docs/odd_road_base_audit.md`의 조사 기록이다. 이번에는 외부 저장소를 재검증하거나 채택하지 않았다.

## 작업 목록과 선후관계

**최우선 보완:** [게임별 플레이 재설계](03_GAMEPLAY_DEPTH.md). 사용자가 지적한 ‘시답잖은 미니게임’ 문제는 콘텐츠 개수나 화면 교체로 해결된 것으로 판정하지 않는다. 아래 작업과 기존 C1/C2/C3 증설은 이 계획의 게임성 게이트를 먼저 적용한다.

| 작업 | 현 구현 근거 | 다음 산출물 | 상세 계획 |
|---|---|---|---|
| R1 규칙 시스템 | 규칙 선택만 하던 `rule_rewriting` | JSON authored grid + runtime parser/solver + multi-YOU/PUSH/STOP/WIN + undo/save v3 완료; 2nd level runtime, transforms/MOVE/DEFEAT, visual QA 잔여 | [규칙](../game_modules/01_RULE_REWRITE.md) |
| D1 사건 시스템 | Resource 사건 번들과 3/4개 가변 slot | 두 사건 데이터·catalog validation·ID 저장 복원·가변 판정 및 v2 마이그레이션 완료. hotspot/evidence/word-bank와 템플릿 문장 구성은 잔여 | [추리](../game_modules/02_DEDUCTION_CASEWORK.md) |
| P1 물리 결과 | 도구 배치만 `SOLUTION`과 비교 | 두 배치 경로와 물체 위치·접촉·목표 영역 판정, 목표 밖 실패, snapshot 복원 수직 슬라이스 완료. 센서/두 번째 레벨 잔여 | [물리](../game_modules/03_PHYSICS_TOOLBOX.md) |
| T1 루프 상태 | `time_loop/module.gd::_observe_or_rewind`·`_evaluate_route` | persistent/local 분리·재관찰 조건부 alternate route 수직 슬라이스 완료. scheduler/tick 충돌 잔여 | [루프](../game_modules/04_TIME_LOOP.md) |
| O1 어드벤처 확장성 | 대상별 match와 바늘→사당→역 직렬 조건 | 기존 경로와 붉은 실 우회 경로, NPC 재회·사건 history·원자적 실패 수직 슬라이스 완료. data registry/validator 잔여 | [로드](../game_modules/05_ODD_ROAD_ADVENTURE.md) |
| C1 기존 장면 | clinic/locker의 3개 조사 상태 | 환자 상태 모델·선택 사물·재조사 | [콘텐츠 보완](01_CONTENT_AND_CONTINUITY.md) |
| U1 셸·목록 | `test_cycle_app.gd`의 설정→목록→복귀 경로 | 포커스 복귀·차단·복원 실패 검증 및 화면 정리 | [셸](02_SHELL_AND_VISUAL_ACCEPTANCE.md) |

실행 기본 순서: baseline/자산 확인 → R1 → D1 → P1 → T1 → O1. 다섯 시스템의 1차 수직 슬라이스를 마쳤다. D1의 사건 데이터 추출은 완료했다. R1 parser/solver를 실제 board grid와 v3 저장에 연결했으며, v2 저장 migration은 기존 저장이 없다는 사용자 확인에 따라 보존하지 않는다. 다음 경계는 rule transformation·MOVE·DEFEAT의 turn 처리와 두 번째 레벨 플레이 경로다. 뒤이어 P1/T1/O1의 모듈별 데이터 추출과 모든 게임형 모듈의 시각 검수가 남아 있다. 한 번에 한 소유 범위만 수행한다. C1은 clinic→locker→미세 증설 순서이며 새 대형 모듈보다 기존 확장 작업을 우선한다. U1은 해당 화면 변경 직전에 수행한다.

## 작업 단위와 소유

- 모듈 작업: 해당 `modules/<id>/**`, 명시된 전용 테스트만 소유한다. 기존 `tests/core/test_cycle4_modules.gd`는 회귀 기준으로 읽고, 필요한 기대값 변경은 해당 단계에서 이유와 함께 한 작업자가 수행한다.
- 셸 작업: `app/app_root.gd`, `modules/game_library/**`, `meta/records/**`, `tests/core/test_cycle_app.gd`, `tests/core/test_records.gd`. 모듈 시스템 보완과 동시에 수정하지 않는다.
- 기존 ID `dedution_casework`는 오탈자처럼 보여도 저장·라우트 호환 식별자다. 이번 보완에서 이름을 고치지 않는다.
- manifest의 `save_version`을 올리기 전에 실제 구버전 세이브와 보존 요구를 확인한다. 보존할 기존 세이브가 없고 사용자가 호환성 불필요를 확정하면 legacy fixture/migration을 만들지 않고 새 기본 상태로 시작한다. 보존 대상이 있으면 fixture와 모듈 소유 migration을 먼저 고정한다.

## 작업 종료 증거

각 작업은 변경 파일, 이전→새 schema 매핑, 실패 복구 결과, 실제 실행한 테스트 수, 레퍼런스/캡처 경로를 남긴다. 검증 명령은 AGENTS의 import→통합→GUT→smoke 순서 그대로 실행한다. 모듈은 ModuleContext를 주입하는 AppRoot 경로로 직접 열어 입력·정지·저장·재진입·귀환을 확인한다.

시스템/콘텐츠/시각 완료를 각각 판정한다. 시스템 fixture 통과를 30분~8시간 콘텐츠 완성으로 보고하지 않는다. 데모 3종은 이번 구현 보완의 수정 범위에서 제외하고 회귀·시각 현황만 확인한다.
