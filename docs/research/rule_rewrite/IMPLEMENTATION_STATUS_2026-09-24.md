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

## 2026-09-26 추가

### 반영한 작업

**사용자가 결정해야 하는 항목은 [미결 질문 목록](OPEN_QUESTIONS.md)에 모아 두었다.** 이
섹션은 사실 기록이고, 결정은 그 문서에서 한다.

- **보드 판정기 신설.** `tools/rule_judge/turn_sim.gd`(헤드리스 턴 시뮬레이터)와
  `judge.gd`(깊이층 BFS + 해 개수 곡선)를 추가했다. 씬 트리를 쓰지 않고
  `RuleMovementSolver`/`RuleEvaluator`/`RuleParser`를 직접 호출한다.
- **parity 게이트 신설.** `tests/core/test_rule_judge_parity.gd`가 15개 보드 × 16턴을 실제
  모듈과 lockstep으로 비교한다(1,138 asserts). 이 테스트는 AGENTS.md 검증 순서에 포함되며,
  통과해야 판정기 수치를 신뢰할 수 있다. 게이트가 처음부터 두 가지 실제 버그를 잡았다
  (`turn_index` 무조건 증가, 이미 solved일 때 진행).
- **원작 배치 검증 보드 추가.** `rule_16_overlap_rules`(Baba Is You 15×8 배치, 15×8).
  어휘는 그대로(`WATER`→`BASIN`, `SKULL`→`STAR` 2개만 치환). `BASE(TAG) PUSH` 19개 수동
  선언 없음.
- **원작 로직 대조.** [대조 기록](ORIGINAL_LOGIC_DIVERGENCES.md) 참조. FLOAT, SINK,
  HOT/MELT, OPEN/SHUT, WEAK, WIN, MOVE, SHIFT, DEFEAT/WIN 순서가 원작과 일치함을 확인했다.
- **R1 텍스트 PUSH 기본값 수정.** 원작에서 텍스트는 PUSH가 기본이고 `TEXT IS NOT PUSH`로
  제거한다. `RuleEvaluator._default_has_property`으로 기본값을 시스템으로 옮기고, 18개 보드
  JSON에서 `base_tags: ["PUSH"]` 399개를 제거했다.

### 보드 측정 결과

[판정 기록](BOARD_JUDGE_REPORT_2026-09-26.md) 참조. 요지: 10번과 12번은 규칙을 한 번도 쓰지
않고 각각 `RRRRR`/`RRRRRR`으로 풀린다. 01~08번은 보드의 79~87%가 비어 있다. 16번은 도달
가능 상태 전수 열거 결과 해가 없다.

### 남은 일

1. **R2(파괴 속성 우선순위) 결정이 미결이다.** 원작에 맞춰 `WEAK` > `DEFEAT` 순서로
   `resolve_contacts`를 3단계로 나누는 변경을 적용했고 `test_rule_evaluator` 13/13은 통과한다.
   그러나 이 변경이 **board 06의 저작 루트를 무효화**했다(`VINE IS DEFEAT AND WEAK`에 닿은
   LARK가 원작 규칙에서는 생존하여 `MOTH HAS KEY`가 발동하지 않음). 선택지는 대조 기록 §4에
   남아 있고, 하나는 확정하지 않았다.
2. 판정기의 `declared_rule_required`(초기 규칙 하나를 제거한 변형의 풀림 여부) 미구현.
3. 판정선이 아직 없다. 원작 퍼즐의 수치 기준이 필요하며 대조 기록 §6에 입력 경로를 적어
   두었다.
4. 3D 보드 14는 판정기 미모델링. 11개 보드는 노드 예산 소진 상태로 미해결.
5. 2026-09-26 현재 `tests/core`는 352/362. 실패 10건 중 3건은 위 1번의 board 06 연쇄이고,
   7건은 `modules/stone_story_rpg/`가 컴파일되지 않아 발생하는 것으로 이 Kit와 무관하다.
