# Rule Rewrite 작업 현황 — 2026-09-25

이 문서는 현재 커밋에 포함한 작업과 남은 검증을 구분한다. Kit 완료 선언이 아니다. 실행 계약의 정본은 [계획서](../../../plans/kits/01_RULE_REWRITE_KIT.md), 전역 결정은 [PROJECT_DECISIONS.md](../../../PROJECT_DECISIONS.md)다.

## 반영한 작업

- 프로젝트 전체의 `뭉탱이`, 상태 인계, 지식 관문, Reference Game과 UI 조사 방식을 공통 문서에 정리했다. Rule Rewrite의 Primary Reference 조사, 모드 생태계 조사, 사용자 UI 캡처 및 Minecraft 인벤토리 캡처를 `docs/research/`에 보존했다.
- Rule Rewrite 계획에 단어/규칙, 이동·충돌, METRIX·INV·OWNS·ACTIVE, 저장·Undo, 15개 authored 퍼즐, 화면·입력·검증 기준을 기록했다. `modules/rule_rewriting/`에 도메인 로직, JSON 보드, 보드 화면, 2D/3D 인벤토리·핫바와 같은 물리 ID를 쓰는 실행 기반을 추가했다.
- `at-icons` 조각을 조합한 Rule Rewrite용 월드 아트와 크기별 미리보기를 `modules/rule_rewriting/art/`에 두었다. 화면 캡처와 성능 계측 하네스는 `tests/performance/`에 있다. 이 자료는 최종 스타일 합격 판정이 아니다.
- 사용자가 제공한 A·B는 게임 전체의 아트 기준, C는 Rule Rewrite의 DOOM식 1인칭 카메라 기준으로 기록했다. `IS 3D` 진입은 1인칭, 1인칭 이동은 격자 턴, W 전방 한 칸·A/D 90도 회전·V 1인칭/3인칭 전환으로 확정했고, 선택 주체 이동과 view-only intent를 같은 물리 상태에 연결했다. **1인칭/3인칭 전환과 격자 턴 자동 검증은 완료됐지만 실제 창 입력 체감은 별도 확인한다.**
- 반복적인 규칙 변경 상단 문구를 제거하고 변화가 일어난 단어·물체를 현장에서 강조하는 구현과 집중 테스트를 추가했다. 실패 복구 안내는 별도 상태로 유지한다.
- 01→15 authored route를 한 GameModule instance에서 연속 실행해 15개 보드 모두 `solved=true`, `failed=false`를 확인했다. 총 285 command, 259 physical turn이며, 사람의 실측 10분 플레이는 별도 과제로 남긴다.
- 플레이 중 보고된 WIN cue/자동 진행, 짧은 Z 입력 유실과 반복 Undo, blocked direct move에서 auto SHIFT/WIN 접촉이 누락되던 문제를 수정했다. 성공 cue는 2D/3D에서 표시되고 0.9초 후 자동 진행하며, cue 중 Undo가 이전 상태를 복원한다.

## 확인한 성능과 테스트

- 2026-09-25 실제 OpenGL 창 benchmark 12회: 2D 명령→draw 중앙값 15.439 ms(p95 20.881), 3D 명령→draw 중앙값 6.003 ms(p95 12.785), 3D dirty movement view 4.314 ms, 3D forward→draw 중앙값 52.180 ms(p95 70.980). 수정 전 기록보다 크게 개선됐으며, headless 수치와 별도로 보존한다.
- 2026-09-25 자동 게이트: Godot editor import 종료 0, `tests/run_tests.gd` 644/644 통과, Rule/first_entry/기존 core 범위 GUT 19 scripts·241 tests·7771 assertions 전부 통과, 180-frame headless 종료 0. 전체 GUT의 deduction_casework/game_library 사용자 범위 실패는 이 작업에서 수정하지 않았다.

## 완료 전 남은 일

1. 01→15 자동 route는 통과했으므로, 실제 플레이어로 대안 route를 포함해 10분 이상을 실측한다.
2. 720p/FHD/QHD 캡처를 현재 외부 temp harness로 생성했으므로, Primary Reference 비교와 at-icons silhouette audit를 남긴다.
3. 2026-09-25 사용자 지시가 기존 at-icons 제작 기준을 대체했다. 새 이미지 자산 기반이 확정되면 해당 기준으로 자산 출처와 실제 화면을 검수한다.
4. parser/METRIX 최적화와 3D/Input Bubble 회귀를 포함한 전체 자동 게이트를 최종 변경 후 다시 실행한다.
