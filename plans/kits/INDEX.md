# Kit 계획 인덱스

공통 용어: `CONTEXT.md`  
공통 작업 계약: `docs/KIT_WORKFLOW.md`  
설계 철학: `docs/DESIGN_PHILOSOPHY.md`  
새 계획 템플릿: [TEMPLATE.md](TEMPLATE.md)

## 현재 whitelist

| 계획 | Primary Reference | 현재 코드에서 허용된 출발점 |
|---|---|---|
| [01_RULE_REWRITE_KIT.md](01_RULE_REWRITE_KIT.md) | Baba Is You | parser / evaluator / movement / transform / undo / save 기반만 재검토 |
| [02_ODD_ROAD_KIT.md](02_ODD_ROAD_KIT.md) | West of Loathing | location / inventory / NPC / event / save 상태 기반만 재검토 |

`first_entry`는 Kit가 아니라 TINProject의 시작/입력 학습 흐름이다. 현재 로직은 보존 후보지만 presentation은 새 Input Bubble 계약에 맞춰 별도 개편한다.

`game_library`는 개발/탐색용 목록 UI다. Kit나 게임 콘텐츠 수에 포함하지 않는다.

## 구현 대기 계획

| 계획 | Primary Reference | 상태 | 비고 |
|---|---|---|---|
| [04_TOP_DOWN_ACTION_RPG_KIT/README.md](04_TOP_DOWN_ACTION_RPG_KIT/README.md) | BLACK SOULS 2 | **PLAN COMPLETE / IMPLEMENTATION READY** | 01~12 split plan, world constitution, magic supplement, seed ledger 160/96/120 reviewed |

## 차단/대기 계획

| 계획 | Primary Reference | 상태 | 현재 whitelist에 올리지 않은 이유 |
|---|---|---|---|
| [03_DEDUCTION_CASEWORK_KIT.md](03_DEDUCTION_CASEWORK_KIT.md) | The Case of the Golden Idol | **12-STAGE AUTHORED PLAYABLE / FINAL ART QA PENDING** | 01~12 placeholder campaign과 자동 route/solve 검증 완료; 최종 art·수동 플레이 검증 대기 |

`03_DEDUCTION_CASEWORK_KIT.md`는 차단 상태의 실행 명세다. 차단 조건이 해소되고 계획 게이트를 통과한 뒤에만 `현재 whitelist`로 이동한다.

## 삭제한 옛 계획 체계

2026-09-23 방향 재설정에서 아래 계획 파일들은 저장소에서 삭제했다.

- `plans/game_modules/`
- `plans/content_expansion/`
- `plans/visual_overhaul/`
- `plans/implementation_improvements/`
- `PLAN_CYCLE4.md`

Git 이력에만 남는다. 새 작업자는 이 과거 계획을 구현 입력이나 아이디어 저장소로 복구하지 않는다.

## 새 Kit 계획 생성 게이트

인덱스에 추가하기 전에:

1. Primary Reference 하나를 고른다.
2. 실제 화면/플레이 자료를 조사한다.
3. [TEMPLATE.md](TEMPLATE.md)를 복사해 빈칸을 모두 채운다.
4. `docs/KIT_WORKFLOW.md`의 금지 shortcut/완료 증거와 충돌하지 않는지 확인한다.
5. 계획 단계에서는 verified Primary Reference runtime evidence를 기록하고, 구현 후 TIN Reference Game이 10분 이상이며 여러 authored content가 같은 core를 재사용하는지 검증한다.

Kit 수량 목표는 없다.
