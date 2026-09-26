# PRESENCE SENTINEL — Kit 05

이 파일은 **삭제 감시용**입니다. 내용이 아니라 **존재**가 중요합니다.

- 이 파일이 사라지면 `modules/stone_story_rpg/` 주변에 파일을 지우는 외부 주체가 있다는 뜻입니다.
- 2026-09-26 한 차례 `modules/stone_story_rpg/` 전체와
  `tests/core/test_stone_story_rpg_core.gd` 가 사라진 적이 있습니다.
  같은 시각에 `docs/research/stone_story_rpg/` 와 `plans/kits/05_STONE_STORY_RPG_KIT/` 는 살아남았습니다.
- 2026-09-26 기준 이 저장소에서 **제가 소유하지 않은 파일**이 동시 수정 중입니다:
  `tests/core/test_rule_level_loader.gd` `test_rule_module.gd`
  `test_rule_reference_content.gd` `test_rule_route_15.gd`
  `test_top_down_action_rpg_core.gd` `test_top_down_action_rpg_module.gd`
  (Rule Rewrite route 16 추가, Kit 04 카탈로그 floor 정정으로 보이는 변경)

원인은 확정하지 않았습니다. 추측으로 기록하지 않습니다.

## 확인 절차

작업을 재개할 때 이 순서로 확인합니다.

1. 이 파일이 있는지 본다.
2. `git status --porcelain` 으로 내가 소유하지 않은 파일의 변경을 본다.
3. 없을 때까지 **20개 파일을 한 번에 쓰지 않는다.** 작은 묶음으로 쓰고 매번 존재를 재확인한다.
