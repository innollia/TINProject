# TINProject — 현재 핸드오버

갱신: 2026-09-23

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

현재 `docs/GRILLING_STATE.md`는 ACTIVE다. 새 채팅에서 project-wide grilling을 이어갈 때 이미 Settled된 루트 질문을 반복하지 말고 Current Frontier에서 시작한다. 기존 `plans/kits/` 파일은 이번 grilling 동안 그대로 둔다.

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
- 원작 고유 자산/문구/레벨/캐릭터는 복제하지 않음
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

`res://addons/at-icons/`를 모든 Kit Reference Game의 월드 아트 재료로 사용한다.

UI icon은 금지. 원래 pictogram 의미 그대로 쓰는 것도 금지.

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

현재 project.godot의 1152×720 설정은 과거 구현 사실일 뿐 새 지원 기준이 아니다.

## 9. 현재 테스트 수치

기존 전체 테스트 통과 기록은 **과거 코드 기준선**으로만 본다.

이번 작업은 문서 방향 재설정이므로 엔진 테스트/시각 검수를 새로 실행했다고 기록하지 않는다.

Retired Prototype 삭제와 Shell/Input Bubble/Kit 코드 구현을 시작하면 새 기준선을 다시 측정한다.

## 10. 다음 구현 작업 후보

순서는 별도 사용자 지시로 확정한다.

- Retired Prototype 코드/catalog/route/test 제거
- 상시 Shell HUD 제거
- Input Bubble 구현 교정
- Rule Rewrite Kit 계획대로 presentation/reference game 재구축
- Odd Road Kit data/registry 분리 + Reference Game 재구축

문서가 먼저다. 구현은 `docs/KIT_WORKFLOW.md`와 각 Kit 계획의 빈칸이 없는 상태에서 시작한다.
