# TINProject — 현재 핸드오버

갱신: 2026-09-25

## 1. 방향 재설정

TINProject는 여러 미니게임/모듈을 많이 만드는 프로젝트가 아니다.

**한 게임 내부에서 장르가 자유롭게 바뀔 수 있도록 장르별 Kit를 미리 구축하는 프로젝트**다.

새 작업자는 다음 순서로 읽는다:
1. `CONTEXT.md`
2. `PROJECT_DECISIONS.md`
3. `docs/GRILLING_STATE.md`
4. `docs/DESIGN_PHILOSOPHY.md`
5. `docs/KIT_WORKFLOW.md`
6. `AGENTS.md`
7. `plans/kits/INDEX.md`
8. 작업 대상 `plans/kits/*.md`

현재 `docs/GRILLING_STATE.md`는 project-wide 및 Rule Rewrite grilling을 **COMPLETE**로 기록한다. 새 채팅은 settled root 질문을 반복하지 말고, 구현 현황과 남은 검증의 `docs/research/rule_rewrite/IMPLEMENTATION_STATUS_2026-09-24.md`에서 시작한다.

## 2. 현재 코드 whitelist

새 방향에서 기반 후보로 인정:
- `modules/first_entry/` — 시작/입력 학습 로직
- `modules/rule_rewriting/` — parser/evaluator/movement/undo/save
- `modules/odd_road_adventure/` — location/inventory/NPC/event/save
- `modules/game_library/` — 개발/탐색용 목록 UI

주의:
- whitelist = 완성품이라는 뜻이 아니다.
- presentation/UI는 새 기준으로 다시 검수한다.
- `first_entry`의 현재 설명문은 보존 대상이 아니다. 시작 로직과 Input Bubble 방향만 이어간다.
- `odd_road_adventure`의 현재 하드코딩된 location/target/content는 새 Reference Game content로 보존하지 않는다.

## 3. Retired Prototype

위 whitelist 외 기존 플레이 모듈은 전부 Retired Prototype이다.

현재 **문서/계획 작업만 수행했으며 실제 게임모듈 코드는 삭제하거나 수정하지 않았다.**

후속 구현 작업에서 별도 범위로:
- catalog 제거
- obsolete route/test 정리
- module code 삭제
를 수행한다.

Retired Prototype의 아이디어·대사·UI는 새 Kit 계획에 재사용하지 않는다.

## 4. 계획 체계

옛 계획 파일은 2026-09-23 저장소에서 삭제했다.

삭제:
- `plans/game_modules/`
- `plans/content_expansion/`
- `plans/visual_overhaul/`
- `plans/implementation_improvements/`
- `PLAN_CYCLE4.md`
- 옛 `docs/odd_road_base_audit.md`

Git 이력에는 남지만 새 구현 입력으로 복구하지 않는다.

새 진입점:
- `plans/kits/INDEX.md`
- `plans/kits/TEMPLATE.md`
- `plans/kits/01_RULE_REWRITE_KIT.md`
- `plans/kits/02_ODD_ROAD_KIT.md`

Kit 수량 목표는 없다.

## 5. Reference Game 계약

각 Kit:
- Primary Reference 하나
- 실제 화면/플레이 조사
- 시스템/UX를 강하게 따라감
- 원작 고유 자산/문구/캐릭터는 복제하지 않음 (레벨 배치는 검증 목적 복사만 허용)
- 최소 10분+ 플레이
- 여러 authored content가 동일 core를 사용
- 전용 editor 없이 agent가 content 추가 가능
- 720p/FHD/QHD 검수
- 사용자 플레이 검토 준비

## 6. UI/입력

상시 Shell HUD는 잘못된 구현으로 판정한다.

플레이 중:
- 좌상단 상태 뭉치 없음
- 우상단 Menu/Journal 없음
- 키설명 문장 없음

Esc 메뉴는 Esc를 눌렀을 때만 보인다.

새 장르 구간의 키 학습은 Input Bubble:
- 움직이는 무늬 배경
- 키별 가상 grid cell
- 새 키는 아래에서 상승
- 다음 장르에서도 필요한 기존 키는 복구
- 필요 없는 키는 popped 흔적 유지
- 실제 키를 눌러 bubble pop

## 7. 시각

2026-09-25 사용자 지시에 따라 at-icons 기반 제작 문서·규칙·실험은 `archive/icon_based_image_assets/`로 보존한다. 기존 이미지 파일은 그대로 둔다. 대체 이미지 자산 기반은 아직 정해지지 않았다.

Primary Reference의:
- camera
- hierarchy
- density
- cell/object ratio
- focus
- feedback
를 실제 화면에서 확인하고 따라간다.

## 8. 해상도

새 기준:
- 1280×720
- 1920×1080
- 2560×1440

현재 `project.godot`의 1280×720 설정과 세 해상도 외부 캡처 harness를 사용한다.

## 9. 현재 테스트 수치

2026-09-25 기준선:
- editor import: exit 0
- `tests/run_tests.gd`: 644/644
- 기존 프로젝트 범위 GUT `tests/core`: 241/241, 7771 assertions
- 180-frame headless smoke: exit 0
- 외부 temp visual harness: 1280×720 / 1920×1080 / 2560×1440, 18개 상태 캡처 생성
- 현재 전체 GUT의 추가 3 실패는 사용자 신규 `deduction_casework` 스켈레톤과 game_library catalog 변경에서 발생했으며 이 작업 범위 밖이다.

이 수치는 자동 검증과 외부 캡처 생성까지의 기록이며, Kit 최종 완료 선언이나 사용자 직접 플레이 검토를 의미하지 않는다. 현재 남은 검증은 `docs/research/rule_rewrite/IMPLEMENTATION_STATUS_2026-09-24.md`를 따른다.

## 10. 다음 구현 작업 후보

- Rule Rewrite 01→15 실제 연속 플레이와 10분 실측
- Rule Rewrite 15번째 authored board는 데이터 확장만으로 추가했고, core 무수정 추가 증거를 남긴다.
- 실제 창 성능과 W/A/D/V 입력 체감 재측정
- 새 이미지 자산 기반이 정해진 뒤 해당 기준에 따른 자산 출처·화면 검수
- Input Bubble의 App 전환 hook은 별도 계획/소유권 계약이 필요

Odd Road는 reference evidence gate가 닫히지 않아 구현하지 않는다.

## 11. Kit 04 Top-down Action-RPG — 2026-09-27

**새 대화가 시작되면 이 항목을 먼저 읽는다.**

- 현황 정본: **`docs/research/top_down_action_rpg/IMPLEMENTATION_STATUS_2026-09-27.md`**
- 계획: `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/README.md` (01–13)
- Primary Reference: **BLACK SOULS 2 하나**

판정: **자동 게이트 전부 통과. 사용자 플레이 검토 전 단계다.**

2026-09-27 기준선:
- editor import: exit 0
- `tests/run_tests.gd`: 644/644
- Kit 04 core GUT `test_top_down_action_rpg_core.gd`: 19/19, 7076 asserts
- Kit 04 module GUT `test_top_down_action_rpg_module.gd`: 20/20, 4966 asserts
- 180-frame headless smoke: exit 0
- `top_down_action_rpg_playthrough_probe.gd`: **exit 0**, canonical coverage 14/14, budget 7223s/required 3418s, surfaces 23/22
- `top_down_action_rpg_visual_capture.gd`: **exit 1 — 미완** (필수 16 state 중 14 미도달). 정적 감사는 통과(placeholder/ap/standin/red 0, bars 2/2)
- catalog: **313 files / 19 kinds** · region 9 · edge 18 · gate 9 · cluster 9 · NPC 21 · enemy 19 · encounter 37 · recovery 7 · group 5 · variant 6 · npc_conversion 5

`tests/core` 전체 GUT의 무관 실패 5건(`test_rule_*` 4건, `test_stone_story_rpg_core` 4 script error)은 Kit 04 소유 밖이라 손대지 않았다.

### 미결 9건

`IMPLEMENTATION_STATUS_2026-09-27` §6의 A–I. 특히 다음 3건이 다음 작업자를 막는다:
- **A** encounter roster 구성을 계획 `05` §2 FAM 배정까지 복원할 것인가 — 계획의 FAM 이름과 content의 enemy 이름 사이에 대응표가 정본에 없다
- **B** ending의 catalog 착지와 런타임 구동 — 현재 vocabulary만 있고 commit 경로가 없다
- **C** 이번 세션의 테스트/harness 변경 5건 승인

### 픽셀 증거

720p/FHD/QHD 캡처는 **headless가 구조적으로 생성하지 못한다**(harness가 design상 거부). 창 있는 실행 또는 사용자 플레이가 필요하다.

### 이미지 자산

프로젝트 이미지 파이프라인은 `docs/art/projects/top_down_action_rpg/`에 있고 H0 background candidate 1장이 있으나 **승인되지 않았다**. approved/와 Gold Standard는 없다. 현재 화면은 vector presentation이다.

