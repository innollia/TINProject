# Kit 계획 인덱스

공통 용어: `CONTEXT.md`  
공통 작업 계약: `docs/KIT_WORKFLOW.md`  
설계 철학: `docs/DESIGN_PHILOSOPHY.md`

## 현재 whitelist

| 계획 | Primary Reference | 현재 코드에서 허용된 출발점 |
|---|---|---|
| [01_RULE_REWRITE_KIT.md](01_RULE_REWRITE_KIT.md) | Baba Is You | parser / evaluator / movement / transform / undo / save 기반만 재검토 |
| [02_ODD_ROAD_KIT.md](02_ODD_ROAD_KIT.md) | West of Loathing | location / inventory / NPC / event / save 상태 기반만 재검토 |

`first_entry`는 Kit가 아니라 TINProject의 시작/입력 학습 흐름이다. 현재 로직은 보존 후보지만 presentation은 새 Input Bubble 계약에 맞춰 별도 개편한다.

## 상태 해석

옛 `plans/game_modules/`, `plans/content_expansion/`, `plans/visual_overhaul/`, `plans/implementation_improvements/`의 계획은 현 방향의 구현 입력으로 사용하지 않는다.

새 Kit 계획을 만들 때는 이 인덱스에 추가하기 전에:
1. Primary Reference 하나를 고른다.
2. 실제 화면/플레이 자료를 조사한다.
3. `docs/KIT_WORKFLOW.md`의 계획서 필수 항목을 채운다.
4. Reference Game이 10분 이상이며 authored content 확장성을 검증하는지 확인한다.

Kit 수량 목표는 없다.
