# 01 — System / UX 실행 계획

상태: 구현 전 executable plan. 이 문서는 `modules/top_down_action_rpg/`의 field, command/target, scheduler, combat, Guard/Dodge/Break, charge, status, equipment, NPC interaction, presentation, input, atomicity 계약을 확정한다.  
Primary Reference: **BLACK SOULS 2 하나**.  
기준 문서: `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`, `docs/research/top_down_action_rpg/IDEA_LEDGER.md`, `docs/research/top_down_action_rpg/BLACK_SOULS_2_RESEARCH.md`, `docs/research/top_down_action_rpg/USER_PLAY_REFERENCE_2026-09-25.md`, `docs/KIT_WORKFLOW.md`, `docs/MODULE_CONTRACT.md`.

## 0. 규칙과 근거 경계

이 계획의 `반드시`, `금지한다`는 구현 완료 조건이다. 구현에 영향을 주는 선택지를 남기지 않는다. 수치로만 바꿀 수 있는 값은 19절에만 둔다.

Primary Reference에서 직접 확인하거나 사용자 설명으로 확정된 것은 다음이다.

- field와 combat은 서로 다른 문법이다.
- combat은 command category → target intent → scheduled resolution 순서로 진행한다.
- combat target은 위치·인접·후방이 아니라 자기/적 하나/전체/아군/무작위로 선택한다.
- 민첩은 선택 빈도와 순서에 영향을 준다.
- action slot, no-turn action/resource, charge 준비 턴과 실행 턴이 존재한다.
- Guard는 단순 stat이 아니라 지속 state이고 방어효율과 방어 취약성을 함께 만든다.
- Dodge는 확률 회피와 일부 status denial을 결합한다.
- Break는 charge 취소, 행동 불가, 방어 붕괴, damage window를 만들 수 있다.
- A~H에서 combat command는 좌측 list, enemy 중심, 하단 player resource/status band로 확인되었다.
- 사용자가 green bar를 “다음 공격이 올 시간”으로 설명했다.
- NPC dialogue는 world를 유지한 채 하단 portrait/speaker/text와 우측 choice list를 사용한다.
- world narration/document/aftermath는 world 위에 별도 content layer로 존재한다.

아직 원작 동작으로 확인되지 않은 exact 민첩 수식, target focus 외형, charge 모션/사운드, hit·miss 연출은 원작 사실로 취급하지 않는다. 이 계획은 TIN에서 다음처럼 한 번에 확정한다.

- A~H B 화면의 별도 bar는 `target_hp_or_condition`으로 보존한다. 의미는 domain이 가진 focused/primary enemy의 HP 또는 condition projection이다.
- green timing bar는 “다음 scheduler readiness까지의 정규화 progress”로만 사용한다.
- generic red bar와 AP resource/label은 만들지 않는다.
- player band에는 HP, MP, authored status, `행동 n` text만 둔다.
- charge tell은 enemy 고유 posture/silhouette 변화와 world VFX·audio의 최소 두 channel로 만든다.
- animation은 gameplay timer가 아니다. combat domain은 scheduler state로만 진행한다.

## 1. Kit 목적과 경계

이 Kit은 TIN 본편의 한 장르 구간에서 field exploration, authored encounter, positionless command/target combat, NPC choice, equipment, recovery를 함께 사용할 수 있는 module-local 기반이다.

반드시 지킬 경계:

- `AppRoot → ModuleDirector → ModuleHost → GameModule`을 유지한다.
- field와 combat은 같은 `top_down_action_rpg` GameModule 안의 서로 다른 mode다. 전역 scene swap이나 GameModule 교체로 전투하지 않는다.
- combat, player, inventory, equipment, status, event는 전역 shared로 만들지 않는다.
- 다른 module을 import하거나 직접 찾지 않는다.
- `/root`, service locator, 범용 EventBus, 승인 없는 autoload를 사용하지 않는다.
- Retired Prototype의 combat, movement, UI, asset, 대사를 가져오지 않는다.
- 전용 editor를 만들지 않는다. authored content는 `06_AUTHORED_CONTENT_AND_DATA.md`가 정의한 module-local JSON catalog와 loader로 추가한다. Godot Resource는 presentation reference/optional wrapper일 뿐 canonical identity가 아니다.
- player가 직접 조작하는 party, class, auto-battle, real-time combat movement는 범위에서 제외한다. authored ally, summon, companion-support actor는 encounter actor로 지원한다.
- combat은 위치·거리·방향을 판정하지 않는다. 대상 category와 stable actor ID만 사용한다.
- 모든 적을 Break로 푸는 encounter를 금지한다. `dodge`, `guard`, `resource`, `status`, `escape`, `raw survival`, `authored scripted response`를 함께 사용한다.

## 2. 구현 파일 소유 구조

구현 시 아래 구조를 기준 경로로 사용한다. Kit의 두 번째 실제 사용처가 생기기 전에는 shared로 추출하지 않는다.

```text
modules/top_down_action_rpg/
├── module_manifest.tres
├── entry.tscn
├── module.gd
├── domain/
│   ├── game_state.gd
│   ├── combat_state.gd
│   ├── actor_state.gd
│   ├── field_state.gd
│   ├── conversation_state.gd
│   └── action_models.gd
├── systems/
│   ├── atomic_state.gd
│   ├── field_controller.gd
│   ├── encounter_controller.gd
│   ├── command_controller.gd
│   ├── action_scheduler.gd
│   ├── combat_controller.gd
│   ├── stance_controller.gd
│   ├── status_controller.gd
│   ├── equipment_controller.gd
│   └── conversation_controller.gd
├── content/
│   ├── actors/
│   ├── actions/
│   ├── reactions/
│   ├── statuses/
│   ├── equipment/
│   ├── encounters/
│   ├── field/
│   └── story/
├── presentation/
│   ├── field/
│   ├── combat/
│   ├── dialogue/
│   └── transitions/
└── authored/
```

`tests/core/`에 시스템별 GUT test를 둔다. 기존 project convention에 맞춰 새 test framework이나 dependency를 추가하지 않는다.

구현 순서와 파일 소유는 다음을 따른다.

1. `domain/`, `content schema`, `systems/atomic_state.gd`
2. `systems/action_scheduler.gd`, `systems/combat_controller.gd`, `systems/stance_controller.gd`, `systems/status_controller.gd`
3. `systems/field_controller.gd`, `systems/encounter_controller.gd`
4. `systems/equipment_controller.gd`, `systems/conversation_controller.gd`
5. `module.gd`, manifest, host input/Input Bubble 통합
6. presentation
7. authored fixture와 GUT test

동시에 같은 파일을 수정하지 않는다. 특히 `module.gd`, scheduler, combat controller, presentation root, app integration, test runner는 한 작업자가 단독 소유한다.

## 3. Domain state와 mode

### 3.1 authoritative state

`GameState`와 nested state는 typed GDScript runtime record로 두며 presentation Node를 직접 참조하지 않는다. runtime record는 content Resource reference 대신 stable ID를 사용하고, `save_state()` 경계에서 모든 ID와 Vector-like 값을 String 또는 finite number array로 변환해 JSON-safe Dictionary로 직렬화한다. StringName/Vector/Resource를 save payload에 직접 넣지 않는다.

`GameState`의 최상위 영역은 다음으로 고정한다.

- `schema_version`
- `mode`
- `field_state`
- `conversation_state`
- `combat_state`
- `encounter_transition_state`
- `player_state`
- `world_state`
- `recovery_state`
- `rng_state`
- `resolution_serial`

`ActorState`는 combat actor마다 다음을 가진다.

- `actor_id`, `display_name`, `side`, `encounter_slot`
- `hp`, `max_hp`, `mp`, `max_mp`
- `base_agility`, `base_attack`, `base_defense`, `base_evasion`
- `physical_resistance`, `magical_resistance`, `status_resistance`
- `break_resistance`, `break_policy`
- `equipment_ids`
- `status_instances`
- `stance_state`
- `charge_state`
- `ai_state`
- `alive`, `fled`, `removed`

actor와 content definition의 연결은 module-local registry의 stable ID로만 rebuilding한다. save에 Node, Resource, Callable, Vector를 넣지 않는다.

### 3.2 module mode

`mode` 값과 전환은 아래만 사용한다.

| mode | 진입 | 허용 domain 처리 | field 이동 |
|---|---|---|---|
| `FIELD` | module 진입, 전투 복귀, dialogue 종료 | 이동, 상호작용, passage, trigger | 허용 |
| `DIALOGUE` | NPC/object interaction | page advance, choice, document | 금지 |
| `SERVICE` | authored shop/equipment/upgrade terminal | equipment, purchase, upgrade, service choice | 금지 |
| `ENCOUNTER_PREPARE` | encounter trigger 검증 | encounter snapshot과 actor 준비 | 금지 |
| `ENCOUNTER_TRANSITION` | prepare 성공 | module-local field/combat view 전환 | 금지 |
| `COMBAT` | encounter 구성 완료 | command, target, reaction, resolution | 금지 |
| `ENCOUNTER_RESULT` | victory/escape/failure 확정 | outcome과 world effect 적용 | 금지 |
| `FIELD_RETURN` | result 적용 완료 | field snapshot 복원 | 금지 |
| `RECOVERY` | failure policy 요청 | `08_SAVE_DEATH_AND_RECOVERY.md` contract | 금지 |

`DIALOGUE`, `SERVICE`, `ENCOUNTER_TRANSITION`은 `FIELD`의 field interaction state 위에 남지만, authoritative `mode`는 별도 값이다. presentation이 어느 field frame을 유지할지는 mode가 결정한다.

`SERVICE`는 combat full-equipment 화면을 여는 mode가 아니다. authored shop/equipment/upgrade terminal에서만 진입하며, stable service ID, inventory/equipment 상태, focus, pending transaction을 관리한다. service close는 항상 originating interactable ID와 field focus를 복원한다. dialogue에서 service로 들어온 경우 service 종료 뒤 originating dialogue node로 돌아가며, dialogue에서 직접 service를 열 수 없는 content는 validation error다.

### 3.3 combat submode

`COMBAT` 내부 submode는 다음으로 고정한다.

1. `COMMAND_CATEGORY`
2. `COMMAND_ACTION`
3. `TARGET_SELECT`
4. `REACTION_SELECT`
5. `RESOLUTION_FEEDBACK`
6. `COMBAT_RESULT`

`REACTION_SELECT`는 charge의 reaction window에서만 사용한다. `RESOLUTION_FEEDBACK`는 presentation event queue를 재생하는 구간이다. reaction이 없는 한 다음 command 입력을 막는 별도 턴이 아니다.

## 4. Field grammar

### 4.1 camera와 movement

- field는 고정 top-down orthographic camera를 사용한다. camera rotation은 없고 player를 화면 중심에 둔다.
- 이동 입력은 `WASD` 방향을 최대 8 방향 analog vector로 합성한다.
- 대각선 속도는 `sqrt(2)`로 보정해 직선 이동보다 빠르지 않게 한다.
- acceleration, deceleration, stop distance, collision slide는 field tuning 값이다.
- player는 circle collision body와 authored walkable/collision shape를 사용한다.
- camera, collision, trigger 좌표는 world rule이며 presentation 좌표와 섞지 않는다.
- field HUD에는 combat resource band, gauge, 전투 status를 복제하지 않는다.
- field에는 상시 space name, autosave, 조작법, debug label을 두지 않는다.
- interaction result와 authored event 표시는 world 안의 대상 변화, NPC dialogue band, world narration band로만 제공한다.

### 4.2 field interactable

모든 NPC, 문, 다리, 엘리베이터, 상자, 시체, 레버, 상점, terminal, key/pass는 authored `FieldInteractableDefinition`을 가진다. 최소 필드는 다음과 같다.

- stable `interactable_id`
- `kind`: `npc`, `passage`, `pickup`, `chest`, `corpse`, `lever`, `terminal`, `shop`, `key`, `hazard`
- display/presentation key
- interaction radius
- `activation`: `confirm`, `automatic`, `scripted`
- `availability_condition`
- `repeat_policy`: `once`, `resettable`, `persistent`
- `conversation_id` 또는 `encounter_id`
- `world_effect_id`
- authored priority
- enabled/disabled presentation class

`confirm` interactable은 `interact` intent가 들어오면 유효한 대상 중 다음 순서로 하나를 고른다.

1. player interaction radius 안
2. `availability_condition`을 만족
3. authored priority가 높은 대상
4. 동률이면 stable `interactable_id`의 사전순

동일 위치에 여러 대상을 몰아 focus cycling을 만들지 않는다. 플레이어는 위치를 바꿔 대상을 선택한다. NPC dialogue에서 interactable focus를 저장할 때는 stable ID와 focus kind만 저장한다.

### 4.3 field passage와 trigger

`EncounterDefinition`은 다음 field activation을 지원한다.

- `CONTACT`: authored contact zone 진입
- `ZONE`: authored field area 진입
- `INTERACTION`: 문/NPC/object interact
- `STORY_FORCED`: story event가 강제
- `CHASE_THRESHOLD`: chase actor가 activation boundary에 진입

각 trigger는 다음을 가져야 한다.

- encounter stable ID
- activation condition
- one-shot/repeat policy
- authored transition ID
- return anchor ID 또는 field snapshot 정책
- pre-transition warning/cue ID
- encounter failure/aftermath policy

field에서 별도의 전투 이동, 인접, 거리 판정, attack whiff를 만들지 않는다. contact/chase는 encounter activation 조건일 뿐이다.

### 4.4 chase와 field state

chase는 authored chase actor와 field boundary를 사용한다. chase actor는 authored `leash`, `activation_zone`, `escape_condition`, `timeout_condition`, `path_points[]`를 가지며, runtime A* 또는 navmesh 탐색을 새로 만들지 않는다. 직선 경로가 walkable하면 player를 향해 이동하고, authored path가 필요하면 가장 가까운 reached node에서 다음 node로 이동한다. field player를 따라가는 동안 dialogue/equipment/field command를 잠그지 않는다. activation threshold를 넘으면 `CONTACT` 또는 `CHASE_THRESHOLD` encounter로 전환한다.

escape가 성공하면 encounter outcome policy가 field state를 갱신한다. chase timer, actor 위치, route gate, loot는 `FieldState`에 stable ID와 JSON-safe 값으로 저장한다.

## 5. Encounter transition

### 5.1 전환 순서

전투는 다음 authored transition으로만 진입한다.

1. field trigger intent를 만든다.
2. `EncounterDefinition`의 condition, roster, return anchor, failure policy를 검증한다.
3. 검증 중에는 field gameplay state를 바꾸지 않는다.
4. encounter actor state를 새 combat state에서 준비한다.
5. field player position, current region, field interaction focus, relevant trigger state를 return snapshot으로 복사한다.
6. trigger 소비와 encounter start를 하나의 atomic commit으로 적용한다.
7. `ENCOUNTER_TRANSITION`으로 mode를 바꾸고 gameplay input을 잠근다.
8. authored warning/cue를 재생한다. `CONTACT`, `ZONE`, `CHASE_THRESHOLD`는 world VFX/audio cue만 사용하고 modal text를 열지 않는다. `INTERACTION`, `STORY_FORCED`만 짧은 world narration band를 사용할 수 있다.
9. field frame을 authored iris wipe로 닫는다.
10. module-local combat view를 구성하고 `COMBAT` command mode를 연다.
11. field frame을 열고 첫 command focus를 `Attack`으로 둔다.

전환 duration, iris 크기, color, audio는 presentation tuning이다. baseline transition은 authored iris wipe 하나만 사용하며, 별도 full-scene load animation을 동시에 쌓지 않는다. 전환 방식의 구조는 이 순서로 고정한다.

### 5.2 실패와 복귀

- validation/roster/resource 준비 실패: field state와 trigger를 그대로 둔다. error presentation만 갱신하고 encounter를 시작하지 않는다.
- player victory 또는 authored escape: outcome을 commit하고, return snapshot의 player position을 사용한다. snapshot position이 더 이상 walkable이면 trigger의 return anchor를 사용한다.
- forced story encounter: `return_anchor`가 있으면 그 anchor를 우선한다.
- failure: combat을 되감는 UI animation을 실행하지 않고 `recovery` mode에 `recovery_request`를 넘긴다. recovery 결정은 `08_SAVE_DEATH_AND_RECOVERY.md`가 소유한다.
- encounter result world effect는 combat state가 확정된 뒤 한 번만 적용한다. dialogue-only flag를 combat result의 후속으로 남기지 않는다.
- combat으로 복귀할 때 `FieldState`의 NPC, prop, passage, trigger state를 content-defined world effect와 함께 다시 projection한다.

전역 scene을 교체하지 않는다. `ModuleDirector.change_module()`은 field/combat 전환에 사용하지 않는다.

## 6. Combat command grammar

### 6.1 top-level category

Primary Reference screenshot의 상대 순서를 유지한다. top-level category의 순서는 고정이다.

1. `Attack` — 기본 공격과 weapon action
2. `Skill/Magic` — skill/magic action 목록
3. `Defend` — Guard, Dodge, Break
4. `Item` — inventory item action
5. `Escape` — encounter escape policy
6. `Equipment` — combat quick-equip action

`Equipment`는 full inventory screen을 combat에 열지 않는다. combat에서는 left command panel 안의 quick-equip 목록만 열고, field의 `SERVICE` mode에서 상세 장비 상태를 관리한다.

`Defend` submenu의 순서는 고정이다.

1. `Guard`
2. `Dodge`
3. `Break`

`Skill/Magic`는 skill과 magic action을 하나의 authored list에 합쳐 `category order → action order → stable action ID`로 표시한다. 별도 filter mode, 좌우 sub-filter, global tag menu를 만들지 않는다.

### 6.2 category와 action focus

- encounter 시작 focus는 `Attack`이다.
- focus는 command layer마다 저장하며 encounter 안에서만 유지한다. load/re-entry 시 첫 valid action으로 복귀한다.
- up/down은 authored action order를 순환한다.
- disabled action도 focusable이다. `disabled`와 `focus`를 같은 표시로 처리하지 않는다.
- disabled action에서 confirm하면 action validation은 실행하지 않고, authored `unavailable_reason` presentation만 갱신한다.
- HP/MP/item/cooldown/phase 변화 후 action availability를 즉시 다시 계산한다.
- action order는 content의 `order`와 stable action ID로 정한다. 이름 알파벳 순으로 정렬하지 않는다.
- 유효 action이 없는 category도 목록 위치를 유지하고 focusable disabled로 표시한다. focus를 자동으로 건너뛰지 않으며 confirm 시 authored unavailable reason만 표시한다.

### 6.3 End Turn

기본 `action_slots`가 1이면 action 하나를 queue할 때 command window가 자동으로 닫힌다. equipment/status가 `action_slots`를 2 이상으로 만들면 남은 slot 수를 command footer에 표시하고 `End Turn` control을 제공한다.

- `End Turn`은 action이 아니며 slot/turn cost를 소비하지 않는다.
- queued normal action이 하나 이상이면 `End Turn`을 사용할 수 있다.
- queued action이 0개이면 End Turn은 현재 actor의 pass window를 예약한다. pass는 기본 turn cost 1과 같은 scheduling 결과를 가진다.
- End Turn을 누르면 더 이상 command를 추가하지 않고 scheduler에 command window 결과를 전달한다.
- no-turn action은 End Turn 전에 실행할 수 있고, End Turn 후에는 해당 actor의 다음 command window에서 다시 사용할 수 있다.

### 6.4 Escape와 equipment

- `Escape`는 encounter policy가 `allowed=false`이면 focusable disabled category다.
- allowed encounter에서 Escape는 confirm 즉시 authored escape attempt를 queue한다. 별도 confirmation modal은 만들지 않는다.
- escape 성공/실패는 `EncounterDefinition.escape_policy`가 결정한다. UI가 성공 여부를 추측하지 않는다.
- combat `Equipment`는 현재 장비와 inventory의 quick-equip candidate를 보여 준다.
- quick-equip은 기본 `turn_cost=1`, `action_slot` 1개를 소비한다. `EquipmentDefinition`이 명시한 no-turn quick-equip만 예외가 된다.
- full equipment/upgrade/service는 field의 `SERVICE` mode에서 제공한다. combat에서 stat/detail screen을 열지 않는다.

### 6.5 ActionDefinition

모든 player action, enemy action, summon action, service action의 authored vocabulary는 하나의 `ActionDefinition` schema를 사용한다. 최소 필드는 다음과 같다.

- stable `action_id`, `version`, `display/presentation_key`
- `category`: `attack`, `skill`, `magic`, `defend`, `item`, `escape`, `equipment`, `enemy`, `summon`, `service`
- `order`
- `target_mode`, `target_eligibility`
- `turn_cost`
- `resource_costs`: canonical combat key는 `hp`, `mp`, `equipment_charge`만 사용한다. `res_*`는 world/quest/craft progression resource이므로 action cost로 쓰지 않는다.
- `cooldown_windows`
- `precondition_ids`
- `lifecycle`: `instant`, `charge`, `committed`
- `telegraph_id`, `reaction_ids`, `forbidden_response_ids`
- `hit_policy`
- `damage_payload`
- `status_payloads`
- `break_spec`
- `guard_policy`, `evasion_policy`
- `self_damage`, `lifesteal`, `reflect_policy`
- `phase_effect_ids`, `summon_ids`, `linked_actor_ids`, `arena_effect_ids`
- `presentation_event_ids`
- `authored tags`
- `craft` (magic/skill action일 때만, 14 key — `06` §5.5.7 정본): `craft_family`, `concentration_source`, `concentration_requirement`, `body_profile_requirements`, `medium_options`, `tool_options`, `shape_or_pattern`, `fold_count_budget`, `preparation_turns`, `waste`, `failure_status_id`, `environment_effect`, `social_recording`, `contract_ref`

`ActionDefinition`은 arbitrary callback, free-form code string, content ID별 core branch를 허용하지 않는다. 새 behavior가 기존 typed payload와 hook으로 표현되지 않으면 Kit 범위를 재검토한다.

Magic/craft action은 위 `craft` block을 통해 같은 action pipeline을 사용한다. `weave`, `rigid_fold`, `void_cut`는 새 combat system이 아니라 medium/tool/shape에 따른 authored variation이다. concentration이나 medium mismatch는 damage를 임의 생성하지 않고 `failure_status_id` + one clock write + world residue로 resolution된다.

`DamagePayload`는 다음 authored 축만 사용한다.

- `delivery`: `physical`, `magical`, `true`
- `shape`: `fixed`, `percent_max_hp`, `percent_current_hp`, `guaranteed`
- `base_value`, `affinity`
- `hit_policy`, `evasion_policy`, `critical_policy`
- `physical_resistance_policy`, `magical_resistance_policy`
- `guard_ignore`, `dodgeable`, `break_damage_kinds`
- `self_damage`, `lifesteal`, `reflect`
- `on_hit_payload_ids`, `on_evade_payload_ids`

`status_payloads`는 stable status ID, stack 수, authored application data만 가진다. UI label이나 색을 domain payload에 넣지 않는다.

## 7. Target system

### 7.1 target mode

다음 여섯 가지만 authoring vocabulary로 사용한다.

| target mode | 대상 | target selection |
|---|---|---|
| `SELF` | 자신 | selection 없음 |
| `ONE_ENEMY` | living enemy 하나 | stable target focus |
| `ONE_ALLY` | 같은 side의 living actor 하나 | stable target focus |
| `ALL_ENEMIES` | 현재 유효한 enemy 전체 | selection 없음 |
| `ALL_ALLIES` | 현재 유효한 same-side actor 전체 | selection 없음 |
| `RANDOM_ENEMY` | 현재 유효한 enemy 중 하나 | selection 없음, resolution RNG |

추가 규칙:

- `ONE_ALLY`에는 자기 자신과 authored ally가 포함된다. fallen ally revive는 action의 `target_eligibility`이 `fallen_ally`일 때만 표시한다.
- `ALL_ENEMIES`와 `ALL_ALLIES`는 resolution 시점의 유효 actor snapshot을 사용한다. queue 시점 roster를 복사하지 않는다.
- single target은 queue 시점 stable actor ID를 lock한다. 대상이 death/flee/remove가 되면 해당 action은 `target_invalidated`가 된다.
- `RANDOM_ENEMY`는 command selection이 아니라 action resolution 시 encounter RNG로 pick한다. 같은 encounter seed와 action sequence는 같은 결과를 만든다.
- target mode는 physical adjacency, distance, facing, grid position을 읽지 않는다.
- action의 side eligibility와 target mode가 충돌하면 content validation error다.

### 7.2 target focus

- encounter actor `encounter_slot`이 target display order의 원본이다. HP, 화면 거리, UI drawing order로 정렬하지 않는다.
- one-target focus는 target mode 진입 시 previous valid focus를 복원한다. previous actor가 없으면 첫 valid slot으로 간다.
- up/down은 stable slot 순서로 이동한다. wrap하지 않는다.
- target이 제거되면 다음 slot, 이전 slot 순서로 첫 valid actor를 찾는다. valid actor가 없으면 target mode를 취소하고 action list로 돌아간다.
- target mode에서 cancel은 action list로 돌아가며 resource, cooldown, queue, turn cost을 소비하지 않는다.
- target focus는 combat 안의 transient presentation state다. semantic target ID는 queued intent에만 저장한다.
- target focus indicator는 enemy sprite 위치가 아니라 대상 actor의 presentation bounds에 붙는 bracket/cursor geometry다. hover-only focus를 만들지 않는다.

### 7.3 action target preview

- `ALL_*` action은 현재 valid target actor를 시각적으로 preview한다. focus는 별도 target actor가 아니다.
- `RANDOM_ENEMY`는 target stage를 열지 않고 action description에 `무작위` class를 표시한다.
- action detail에는 target mode, turn cost, resource cost, cooldown 여부를 한 줄로 표시한다. 이는 튜토리얼이 아니라 현재 선택의 결과 정보다.
- target detail은 enemy portrait/name와 현재 status만 보여 주며, field world HUD를 복제하지 않는다.

## 8. Scheduler: schedule_rate, action_slots, turn_cost

세 값은 서로 다른 contract다. core에서 하나의 stat으로 합치지 않는다.

### 8.1 정의

- `schedule_rate`: actor가 scheduler에서 얼마나 자주 command window를 받는지 결정한다. 높을수록 자주 선택된다.
- `action_slots`: 한 actor command window에서 queue할 수 있는 normal command의 최대 개수다.
- `turn_cost`: normal command가 actor의 다음 scheduling을 얼마나 오래 지연시키는지 결정한다.

기본 actor의 `action_slots`는 1이다. equipment/status/encounter modifier가 이를 변경할 수 있다.

### 8.2 schedule rate 계산

actor의 effective agility와 authored trait modifier를 합산해 정수 `schedule_rate`를 만든다.

- `schedule_rate = max(MIN_RATE, base_agility + sum(effective_agility_modifier))`
- `MIN_RATE`, base scale, modifier coefficient는 tuning 값이다.
- `schedule_rate`는 animation speed나 hit probability를 바꾸지 않는다.
- agility는 command selection 빈도와 readiness에만 영향을 준다.
- UI는 이 값을 직접 계산하지 않는다. `CombatState`가 계산한 normalized projection을 사용한다.

abstract scheduler clock는 정수 tick으로 저장한다. floating-point tie와 재접속 drift를 피한다.

- normal action의 기본 delay는 `ceil(BASE_SCHEDULE_TICKS * turn_cost / schedule_rate)`다.
- `BASE_SCHEDULE_TICKS`와 `MIN_RATE`은 cheap numeric tuning이다.
- 같은 actor window 안에서 앞서 queue된 command의 cumulative turn cost를 더해 다음 command의 ready tick을 만든다.
- actor의 다음 command window는 `window_start + ceil(BASE_SCHEDULE_TICKS * total_queued_turn_cost / schedule_rate)`에 연다.
- queued action이 resolution에서 무효가 되어도 schedule delay는 환불하지 않는다. selection 시점에 이미 command window를 예약했기 때문이다. resource/cooldown만 실제 resolution에서 소비한다.

### 8.3 action_slots

- `action_slots`는 normal queued command에만 적용된다.
- `turn_cost >= 1`인 action을 queue할 때 slot 하나를 소비한다.
- `turn_cost=0`인 no-turn action은 slot을 소비하지 않는다.
- actor가 slot을 모두 사용하면 command window가 자동으로 닫힌다.
- 사용하지 않은 slot은 자동 복구하지 않는다. 다음 command window의 새 slot으로 계산한다.
- `End Turn`으로 일부 slot을 포기하면 사용하지 않은 slot은 forfeiture된다. queued action이 하나 이상이면 delay는 queued turn cost 합계만 사용한다. queued action이 0개이면 delay는 pass cost 1을 사용한다.
- enemy AI도 같은 slot 제한을 받는다. authored AI가 유효 action을 채우지 못하면 pass window를 닫는다.
- action slot modifier는 command window가 열릴 때 snapshot한다. 같은 window 안에서 장비로 slot을 추가해도 현재 slot은 늘어나지 않는다. 다음 window부터 적용한다.

### 8.4 turn_cost

`turn_cost` 값의 의미는 다음과 같다.

- `0`: no-turn/no-slot action. action pool과 action slot을 소비하지 않고 현재 command selection에서 즉시 resolution한다.
- `1`: normal command. action slot 1개를 소비하고 actor schedule을 한 단계 진행한다.
- `2`~`5`: committed/long action. action slot 1개를 소비하고 actor의 다음 command window를 그만큼 지연시킨다. 중간에 다른 action을 넣지 않는다.
- 허용 범위는 정수 `0..5`이다. 음수, 6 이상, 비정수, 존재하지 않는 cost는 content validation error다.

no-turn action도 resource cost, cooldown, status resistance는 정상 적용한다. “턴을 소비하지 않는다”는 이유만으로 inventory나 MP를 무료로 만들지 않는다.

### 8.5 queue 순서와 deterministic tie-break

모든 AI와 player는 같은 `QueuedAction` vocabulary를 사용한다. action pool 정렬은 다음 순서로 고정한다.

1. `ready_tick` 오름차순
2. encounter-authored `tie_break_rank` 오름차순
3. 같은 actor의 `command_index` 오름차순
4. `intent_id` 사전순

`intent_id`는 encounter ID, actor ID, window serial, command index로 만든 deterministic string이다. wall-clock time, Node instance ID, UI list order를 정렬 기준으로 사용하지 않는다.

### 8.6 scheduler selection

1. `next_window_tick`이 가장 작은 actor를 고른다.
2. 같으면 authored `tie_break_rank`, stable actor ID 순으로 고른다.
3. actor가 charge forced action 상태면 command window를 열지 않고 forced action을 처리한다.
4. actor가 `cannot_act` control 상태면 action을 queue하지 않고 pass window를 처리한다.
5. 정상 actor면 현재 effective `action_slots`만큼 command를 받는다.
6. command window 종료 후 ready action을 global queue에 넣는다.
7. queue에 delayed forced/charge action이 있으면 같은 tick ordering으로 resolution한다.
8. resolution 후 actor의 next window와 RNG serial을 갱신한다.
9. 모든 eligible actor가 현재 cycle을 마치면 다음 cycle로 진행한다.

enemy AI는 actor window가 열릴 때 `EncounterDefinition.ai_policy_id`와 actor state로 command를 만든다. AI가 player의 future action을 읽거나 UI state를 읽지 않는다.

### 8.7 no-turn action의 정확한 계약

no-turn action은 다음 순서를 따른다.

1. target을 확정한다.
2. action precondition, resource, cooldown, status resistance를 검증한다.
3. 같은 atomic transaction으로 resolve한다.
4. resource/cooldown을 한 번 소비한다.
5. action feedback을 presentation queue에 보낸다.
6. command selection은 같은 actor window에 남는다.
7. scheduler clock, action slot, enemy window에는 영향을 주지 않는다.

no-turn action으로 `guard`, `dodge`, `break`, charge 상태를 즉시 바꿀 수 있다. 그 결과는 resolution event 뒤 presentation에 반영한다. no-turn action이 성공해도 target action을 여러 번 resolve하지 않는다.

## 9. Action resolution order

### 9.1 선택과 검증

action 선택 중에는 HP, MP, inventory, cooldown, world flag를 바꾸지 않는다. 선택 상태와 queued intent만 만든다. multiple queued action이 같은 resource를 쓸 수 있으므로 queue 시점에 `reserved_resources`를 별도로 기록한다.

queue 검증은 다음 순서다.

1. actor가 현재 combat side에 존재하고 alive인지
2. action definition/version이 현재 content registry에 존재하는지
3. precondition과 target mode가 유효한지
4. turn cost와 action slot이 유효한지
5. resource가 충분한지
6. cooldown가 없는지
7. status resistance/immunity를 통과하는지
8. encounter phase가 action을 허용하는지

검증 실패는 gameplay state와 resource를 바꾸지 않는다. 오류 reason만 presentation feedback으로 보낸다.

### 9.2 resolution transaction

각 queued action은 `AtomicState`를 통해 다음 순서를 따른다.

1. 현재 combat state의 deep working copy를 만든다.
2. resolution 시점에 target, actor, action, resource, phase를 다시 검증한다.
3. 검증 실패면 `skipped` 결과를 버리고 working copy를 폐기한다.
4. working copy에서 action cost와 reservation을 소비한다.
5. reaction/counter를 먼저 resolution한다.
6. reaction이 attack을 cancel하면 hit pipeline을 건너뛴다.
7. hit, dodge/evasion, critical, guard mitigation, damage를 순서대로 적용한다.
8. 살아 있는 target에게 status payload를 적용한다.
9. death, phase, summon, linked actor, encounter outcome을 반영한다.
10. 모든 hook이 성공하면 working copy를 authoritative state로 교체한다.
11. commit 뒤에만 presentation event와 module request를 내보낸다.

어느 단계에서든 content/runtime error가 나면 pre-action state로 rollback한다. partial HP, partial inventory, partial world effect가 남지 않는다.

### 9.3 action hook 순서

action hook은 content ID별 `if/match`가 아니라 generic engine branch 순서로 고정한다.

1. target/actor liveness 및 phase validation
2. resource/cooldown reservation 소비
3. pre-action status modifier
4. charge reaction 또는 scripted counter
5. action commitment 및 hit policy
6. ordinary evasion/Dodge query
7. critical 및 critical avoidance
8. Guard mitigation
9. HP damage와 self-damage
10. target death 판정
11. 살아 있는 target의 status application
12. lifesteal, reflect, on-hit/on-taken-hit trigger
13. death removal과 linked actor 처리
14. phase transition
15. summon/arena/encounter world effect
16. action result와 presentation event 생성

damage로 target이 죽으면 status payload와 on-hit effect는 적용하지 않는다. lifesteal/reflect는 lethal hit 뒤에도 계산할 수 있다. death 판정 전 actor를 제거하지 않아 한 action 안의 후속 effect가 대상 ID를 잃지 않는다.

### 9.4 late invalidation

- single target이 queue 후 dead/flee/remove: `skipped_target_invalidated`, action resource는 소비하지 않는다.
- all-target의 일부 actor가 dead: 남아 있는 valid actor에게만 적용한다.
- all-target actor가 전부 dead: `skipped_no_valid_target`, resource를 소비하지 않는다.
- action을 unlock한 equipment가 unequip됨: `skipped_action_unavailable`, resource를 소비하지 않는다.
- action phase가 바뀜: `skipped_phase_invalidated`, resource를 소비하지 않는다.
- invalid queued action의 scheduler delay는 환불하지 않는다. actor가 이미 command window를 사용했기 때문이다.
- encounter 결과가 확정된 뒤 남은 queued action은 모두 무효 처리하고 새 encounter/field state로 commit한다.

## 10. Guard, Dodge, Break

Guard/Dodge/Break은 범용 status 이름이 아니라 combat stance와 action resolution으로 모델링한다. 다른 status와 UI에서는 동일한 presentation tag로 projection할 수 있다.

### 10.1 stance state

actor의 `stance_state`는 다음 중 하나의 상태를 가진다.

- `normal`
- `guard`
- `dodge`
- `broken`
- `guard_broken`

- Guard와 Dodge는 동시에 활성화되지 않는다. 새 stance가 기존 stance를 대체한다.
- Break는 target stance를 `broken`으로 바꾸며, charge policy가 허용하면 charge도 취소한다.
- `guard_broken`은 Guard가 깨진 직후의 recovery 상태다. mitigation을 적용하지 않는다.
- stance duration은 actor schedule window 단위로 계산한다. no-turn action은 stance duration을 줄이지 않는다.

### 10.2 Guard

Guard action은 self-target, normal turn cost, action slot 1개를 사용한다.

- Guard 성공 시 `guard` stance를 시작하고 `guard_window_budget=2`를 설정한다.
- actor의 각 activation 끝에서 budget을 1씩 줄인다. 현재 activation과 다음 activation을 보호하고 그다음 activation 전에는 expired가 된다.
- 같은 activation의 여러 action은 Guard를 한 번만 감소시킨다.
- Guard mitigation은 `defense * guard_efficiency`를 incoming HP damage에 대해 `min()`으로 적용한다. `guard_ignore` action은 이 계산을 우회한다.
- Guard는 directed HP damage에 적용한다. self-damage, true damage, reflection, DoT에는 적용하지 않는다.
- Guard 동안 ordinary on-hit counter, ordinary dodge bonus, free counter는 제공하지 않는다.
- `break_damage >= guard_break_threshold`이거나 action policy가 `breaks_guard=true`면 Guard를 제거하고 `guard_broken`으로 전환한다.
- `guard_broken` duration은 authored window 수다. duration 동안 mitigation/counter를 모두 금지한다.

### 10.3 Dodge

Dodge action은 self-target, normal turn cost, action slot 1개를 사용한다.

- Dodge 성공 시 actor는 다음 actor activation 시작 전까지 Dodge state를 가진다.
- 각 유효 hit instance마다 한 번만 deterministic roll을 한다.
- roll은 다음 구조를 사용한다.

  `chance = clamp(BASE_DODGE + EVASION_WEIGHT * effective_evasion + AGILITY_WEIGHT * (effective_agility - REFERENCE_AGILITY) - attack.dodge_pressure, MIN_DODGE, MAX_DODGE)`

- 계수와 clamp 값은 cheap numeric tuning이다. 공격의 `evasion=disabled`이면 roll을 하지 않는다.
- Dodge는 ordinary damage와 `dodgeable=true`인 status application을 피한다.
- true damage, instant death, no-evade, scripted unavoidable attack은 action policy가 명시하지 않는 한 Dodge가 피하지 못한다.
- Dodge 성공 시 `on_evade` trigger는 실행할 수 있지만 `on_hit` trigger는 실행하지 않는다.
- multiple target hit은 target slot 순서로 각각 독립 roll한다. 첫 target의 결과를 다음 target의 RNG 순서에 사용하지 않는다.
- 무효 target에는 roll하지 않는다.

### 10.4 Break

Break action은 `ONE_ENEMY` target, normal turn cost, action slot 1개를 사용한다.

- target의 `break_policy=immune`이면 Break category는 focusable disabled로 남고 confirm은 state를 바꾸지 않는다.
- `break_policy=enabled`이면 action의 `break_power`와 target의 `break_resistance`를 비교한다. 기본 비교는 chance가 아닌 deterministic threshold다.
- `break_power < break_resistance`면 damage/cost만 정상 처리하고 break transition은 발생하지 않는다.
- 성공하면 target을 `broken`으로 변경하고 `broken_skip_budget=2`를 설정한다. 현재 action window가 끝날 때 budget이 1로 감소하고, target의 다음 actor window를 통째로 건너뛴 뒤 다시 0이 된다. budget 값은 authored tuning으로 바꿀 수 있지만 건너뛰는 structural rule은 유지한다.
- charge를 `cancels_charge=true`인 policy에 따라 취소한다.
- Break 성공은 target의 queued action을 무효화하고, target의 next normal command window를 skipped window로 만든다.
- Break 성공이 player에게 별도 무료 action을 자동 제공하지 않는다. 대상의 행동 불가와 다음 scheduler opportunity가 punish window다.
- `broken` 동안 incoming damage는 action/stance의 `break_damage_kinds`에 해당할 때만 authored multiplier를 적용한다. true/self damage에는 적용하지 않는다.
- 이미 broken인 target에 다시 Break를 성공시킬 수 없다. 이미 broken이면 action은 `skipped_already_broken`이 된다.
- Break가 성공해도 encounter 전체를 끝내지 못할 수 있다. signature counter, resource cost, scripted response를 함께 사용한다.

### 10.5 Guard와 Break의 상호작용

- target이 Guard 중이고 Break가 성공하면 Guard 제거 → `broken` transition 순서로 처리한다.
- charge hit이 `breaks_guard=true`이고 mitigation 이후 guard break threshold를 넘으면, damage commit 뒤 guard를 무너뜨리고 recovery를 적용한다.
- guard-break은 charge cancel을 의미하지 않는다. charge cancel 여부는 charge의 `break_policy`가 결정한다.
- Break가 guard를 깨뜨렸더라도 target이 이미 dead이면 `broken` 상태를 만들지 않는다.

## 11. Charge와 reaction

### 11.1 charge state

charge는 독립 action lifecycle로 구현한다. 단순히 긴 animation을 가진 normal action으로 취급하지 않는다.

`ChargeState`는 다음을 가진다.

- owning actor ID
- charge action ID
- current stage: `telegraph`, `reaction`, `strike`, `recovery`, `cancelled`, `completed`
- current stage ordinal
- target actor ID 또는 `SELF`
- telegraph/reaction/recovery window budget
- valid reaction IDs
- forbidden response IDs
- break policy
- control policy
- strike action ID
- recovery action/punish ID
- presentation event serial

charge를 시작하는 action은 정상 resource/turn cost를 소비한다. 시작 action의 resolution 뒤 charge state가 authoritative state에 저장된다.

### 11.2 charge stage 순서

1. actor가 charge를 시작한다.
2. `telegraph` stage가 시작되고 charge tell event가 presentation queue에 들어간다.
3. telegraph가 authored window 수만큼 유지된다.
4. `reaction` stage가 시작되고 현재 valid reaction만 prompt에 표시된다.
5. player가 reaction을 선택하거나 `Receive`를 선택한다.
6. reaction이 charge를 cancel하면 strike를 건너뛴다.
7. cancel되지 않으면 `strike` action을 같은 atomic resolution pipeline으로 실행한다.
8. strike 후 `recovery` 또는 `completed`로 전이한다.
9. recovery 동안 authored punish window와 action pool을 허용한다.

일반 actor의 command window는 charge가 진행 중일 때 열지 않는다. charge가 `cancelled` 또는 `completed`가 되어야 normal window를 다시 열 수 있다.

### 11.3 tell channel

모든 authored charge는 최소 두 개의 독립적인 tell channel을 가져야 한다.

- actor posture/silhouette 변화
- world VFX 변화
- audio cue
- target/arena 변화

색 변화만으로는 tell을 만들지 않는다. tell animation, duration, audio loudness는 cheap tuning이지만 channel 수와 stage 순서는 고정이다. green timing bar는 charge tell을 대신하지 않는다.

### 11.4 reaction vocabulary

reaction은 별도 `ReactionDefinition`으로 authored content다. 모든 reaction은 다음 공통 rule을 가진다.

- player가 한 reaction window에서 한 번만 선택한다.
- target/charge가 이미 유효하지 않으면 reaction을 실행하지 않는다.
- reaction은 `turn_cost=0`으로 현재 charge resolution에 삽입된다.
- reaction action slot을 소비하지 않고 다음 actor window를 바꾸지 않는다.
- reaction resource cost와 cooldown은 정상 검증한다.
- reaction 결과가 commit된 뒤 strike 여부를 검사한다.
- `Receive`는 reaction이 아니며 resource/turn/state를 바꾸지 않고 strike를 진행한다.

`ReactionDefinition`은 최소 다음을 가진다.

- stable reaction ID
- valid charge/attack tags
- forbidden tags
- effect action 또는 scripted response ID
- resource costs
- presentation key
- cancel/counter outcome
- duration/animation tuning fields

기본 counter family은 `evade`, `mitigate`, `break`, `consume_resource`, `authored_scripted`다. `break` reaction이 없는 charge도 허용한다. `valid_counters`와 `forbidden_responses`가 겹치면 content validation error다.

### 11.5 charge 예외

다음은 charge/break의 예외를 고정한다.

- `break_policy=immune`: Break reaction이 prompt에 disabled로 표시될 수 있다.
- `evasion=disabled`: Dodge reaction이 prompt에 disabled로 표시된다.
- `resource_lock`: MP/equipment/resource를 소모하는 reaction만 유효하다.
- `raw_survival`: HP/continuity pressure를 authored cost로 지불해야 한다.
- `scripted_counter`: 특정 dialogue/relationship/event state에서만 reaction ID를 노출한다.
- `death`, `phase_exit`, `remove`, `default_control`: charge를 취소한다.
- charge definition이 `control_policy=persist`를 명시한 경우에만 일반 control이 charge stage를 보존한다.

## 12. Status system

### 12.1 StatusDefinition

status는 이름이나 색이 아니라 resolution hook과 state data다. `StatusDefinition`은 다음 field를 가진다.

- stable `status_id`, `version`
- display/presentation key
- `max_stacks`
- `duration_windows`
- `stacking_mode`: `refresh`, `stack`, `replace`, `independent`
- `refresh_policy`: 새 instance, duration refresh, stack refresh
- `stat_modifiers`: attack, defense, agility, evasion, physical/magical resistance의 명시적 delta 또는 multiplier
- `trait_modifiers`: `cannot_act`, `cannot_target`, `schedule_rate_delta`, `action_slot_delta`, `damage_taken_multiplier`, `damage_dealt_multiplier`, `status_application_delta`, `charge_policy` 중 허용된 typed key
- `control_tags`: stun, silence, disable, root, charge cancel
- `application_mode`: always, deterministic threshold, chance
- `resistance_trait`
- `cure_tags`
- `dispel_tags`
- `dodgeable`
- `presentation_shape`와 `short_label`
- authored tick/periodic payload

status content가 combat core에 새 `if content_id`를 요구하면 구현 실패다. 새 status는 data와 existing hook으로 추가해야 한다.

### 12.2 status instance

runtime status instance는 다음을 가진다.

- stable definition ID
- instance ID
- source actor ID
- stack count
- remaining windows
- payload values
- application serial
- active flag

같은 actor가 같은 status를 여러 번 얻으면 `stacking_mode`와 `refresh_policy`를 따른다. 서로 다른 source는 `independent`가 아니면 같은 application identity로 취급한다. 이 기준은 content schema에서 고정하며 core가 이름 유사성을 추측하지 않는다.

### 12.3 duration과 tick

- actor의 모든 schedule activation 시작 시 status start-of-window pipeline을 한 번 실행한다.
- 시작 pipeline 순서는 `expired 제거 → control 적용 → periodic status tick → action eligibility 계산`이다.
- actor command 또는 forced charge stage가 끝난 뒤 end-of-window pipeline에서 status duration, cooldown, Guard/skip budget을 감소시킨다.
- start-of-window에서 이미 expired가 된 status는 tick하지 않는다. action application 시 instant effect는 application transaction에서 즉시 한 번 적용한다.
- status duration은 actor schedule window 수로 감소한다.
- normal command, no-turn command, forced charge stage는 모두 같은 actor window에서 status/cooldown을 한 번만 감소시킨다.
- no-turn action 자체는 status duration이나 cooldown을 줄이지 않는다.
- actor가 `cannot_act`이면 command를 queue하지 않아도 status와 cooldown window는 시작/끝에 한 번씩 처리한다.
- status로 actor가 죽으면 그 actor의 command window는 소비하지 않고 `dead`로 전이한다.
- DoT/regeneration/payload는 stable application serial 순서로 실행한다.

### 12.4 resistance와 cure

- action이 status를 payload에 포함하면 대상 actor의 resistance/immunity를 먼저 조회한다.
- `always`는 resistance를 거치지 않는다. `threshold`와 `chance`는 encounter RNG stream으로 판정한다.
- immunity는 0/1 query로 먼저 처리하고, resistance percentage는 그 뒤 적용한다.
- cure action은 `cure_tags`를 가진 status만 대상으로 한다. matching instance가 없으면 action은 정상 resource/cost를 소비하고 `no_status_removed` result를 낸다.
- dispel action은 `dispel_tags`를 가진 status만 대상으로 한다. positive stack을 먼저 제거할지 authored `remove_order`를 따른다.
- 여러 status를 동시에 제거하는 action은 stable application order를 사용한다. 같은 시점에 UI가 제거 순서를 바꾸지 않는다.
- status expiry, cure, dispel, death는 모두 atomic commit 후 presentation에 반영한다.

### 12.5 status presentation

- combat player band에는 status의 short label, shape, stack count, urgent state를 표시한다.
- 색은 보조 channel이다. status 이름 또는 shape가 반드시 존재해야 한다.
- 남은 window 수와 내부 timer는 combat band에 표시하지 않는다. 대신 short label, shape, stack count로 현재 상태를 설명한다.
- field에는 combat status icon을 복제하지 않는다.
- status hover나 별도 detail submode를 만들지 않는다. 모든 status information은 위의 combat band text/shape에서 직접 읽혀야 한다.

## 13. Equipment와 inventory

### 13.1 equipment slot

Reference Game의 authored equipment contract는 네 slot으로 고정한다.

- `weapon`
- `offhand`
- `armor`
- `accessory`

각 slot은 빈 상태를 허용할지 equipment definition의 `allow_empty`로 결정한다. weapon slot이 빈 action을 만들지 않는다. 장비 ID는 stable string이며 runtime Resource reference를 저장하지 않는다.

### 13.2 equipment effect

`EquipmentDefinition`은 다음을 지원한다.

- stat modifier
- physical/magical resistance
- status resistance/immunity
- Guard power/effectiveness
- Dodge pressure/evasion
- break resistance/policy
- `basic_attack_action_id`
- `granted_action_ids`
- `action_slot_delta`
- `no_turn_action_ids`
- field traversal key/pass
- equipment-specific behavior flag
- upgrade/unlock service ID
- presentation key

derived combat query는 항상 `base + equipment + status + temporary action modifier` 순서로 재계산한다. 장비 해제로 base stat을 직접 복원하거나 수동으로 되돌리지 않는다.

### 13.3 combat quick-equip

- top-level Equipment는 left command panel의 quick list를 연다.
- quick-equip candidate는 현재 actor가 소유한 inventory equipment만 표시한다.
- 선택 후 target은 `SELF`이고 action은 기본 normal turn/action slot을 소비한다.
- 장비 변경은 authoritative commit 뒤 새 action list와 bottom band에 반영한다.
- 장비 변경으로 이미 queue한 action의 definition이 사라지면 resolution에서 `skipped_action_unavailable`이 된다.
- 장비로 새로 해금한 active action은 장비 action이 resolve된 다음 command window부터 queue할 수 있다. 같은 command window에서 자기 해금 action을 미리 queue하지 않는다.
- action-slot accessory는 다음 command window부터 적용된다.
- combat에서는 full stat/detail/upgrade screen을 열지 않는다. 해당 service는 field의 `SERVICE` mode가 소유한다.

### 13.4 item action

Item는 inventory quantity와 stable item definition을 가진다.

- 기본 attack weapon 1종 이상
- equipment 강화/해금 active skill 1종 이상
- resistance/behavior equipment 1종 이상
- no-turn heal/cure/buff item 1종 이상
- field traversal key/pass 1종 이상
- action-slot accessory 1종 이상 (다음 command window부터 적용)

을 Reference Game authored content에서 반드시 증명한다. item 사용은 target mode, resource cost, cooldown, status payload를 ActionDefinition으로 표현한다. item ID를 core `match`에 추가하지 않는다.

## 14. NPC dialogue와 choice flow

### 14.1 world-preserving dialogue state

NPC interaction은 `FIELD → DIALOGUE`로 전환한다. world frame과 player/NPC 위치 관계를 유지하고 dialogue band와 choice panel만 contextual UI로 추가한다.

dialogue mode는 다음 content type을 순서대로 실행한다.

- `NarrationBeat`
- `ConversationPage`
- `ChoiceSet`
- `Document`
- `AftermathState`
- `NPCStateTransition`

`ConversationDefinition`은 stable ID, entry condition, node/page 순서, speaker, portrait presentation key, choice set, exit policy, revisit policy를 가진다. dialogue text는 world state의 진실이 아니다.

### 14.2 page와 focus

- page는 full text를 한 번에 표시한다. typewriter로 입력을 막지 않는다.
- confirm이 있으면 다음 page로 진행한다.
- 마지막 page에서 choice가 없으면 `End` control로 dialogue 결과를 확정한다.
- up/down은 choice focus를 이동한다.
- cancel은 committed result 이전이면 이전 page/choice focus로 돌아간다.
- dialogue root에서 cancel은 `allow_exit=true`인 경우에만 field로 나간다.
- choice 결과가 이미 commit된 뒤의 cancel은 rollback하지 않는다. 다음 result page를 진행하거나 dialogue를 종료한다.
- closing 시 마지막 field interaction focus와 NPC stable ID를 복원한다.
- focus는 color가 아닌 bracket, brush fill, line/shape와 text 중 최소 두 channel로 표시한다.

### 14.3 ChoiceSet

각 `ChoiceDefinition`은 다음을 반드시 가진다.

- `choice_id`
- `text`
- `semantic_tags`
- `presentation_class`
- `availability_condition`
- `unavailable_reason`
- `irreversibility_class`
- `immediate_effect_id`
- `delayed_effect_id`
- NPC/quest/relationship/world effect
- `return_focus_id`
- 선택적 deterministic outcome table

presentation class는 공통 enum `neutral`, `official`, `confidential`, `hostile`, `extreme`, `narration`, `unavailable`, `result`를 사용한다. choice surface는 `neutral|extreme|unavailable|result`만 사용하고, extreme은 빨간색을 사용할 수 있지만 red-only semantic은 아니다. 문장, 선택 focus, 결과 class가 함께 extreme을 설명한다.

- unavailable choice는 `reveal_when_unavailable`이 true일 때만 표시한다. 표시할 때 focusable이지만 confirm은 state를 바꾸지 않는다.
- focus와 disabled는 별도 state다.
- choice confirm은 두 번째 modal을 요구하지 않는다. 선택 문장과 irreversible class를 authored feedback으로 확인한 뒤 바로 transaction을 실행한다.
- choice confirm 직전 availability를 다시 검증한다. validation 실패는 어떤 world/NPC/relationship state도 바꾸지 않는다.
- transaction은 immediate, delayed 예약, world flag, NPC state, relationship, inventory, route effect를 하나의 commit으로 적용한다.
- dialogue 한 줄은 consequence가 아니다. 실제 state surface가 최소 하나는 있어야 한다.
- weighted outcome은 module-local deterministic RNG를 사용하고, RNG serial을 commit한다.
- choice 결과가 field/NPC/quest/relationship 중 하나를 바꾸지 않는 choice는 content validation warning을 받는다.

### 14.4 NPC combat conversion

NPC dialogue에서 encounter로 이어질 때 `stable NPC ID`를 유지한다.

1. `ConversationState`의 현재 node와 choice 결과를 commit한다.
2. `EncounterDefinition`이 같은 NPC stable ID를 hostile actor로 참조한다.
3. 전투 결과는 새 NPC ID를 만들지 않는다.
4. victory, repeated challenge, ally conversion, removal, persistent survival 중 authored result를 `NPCStateTransition`으로 적용한다.
5. dialogue, presence/absence, shop/service, relationship, region state가 result-specific variant를 읽는다.

NPC combat skin만 갈아입히는 변환은 금지한다.

## 15. Combat presentation state

### 15.1 domain과 presentation 분리

presentation은 `CombatViewState` snapshot만 읽는다. 이 snapshot은 최소 다음을 가진다.

- `mode`
- `version`와 `event_serial`
- `category_focus`
- `action_focus`
- `target_focus`
- `queued_action_count`
- `remaining_action_slots`
- `active_charge_stage`
- `reaction_prompt`
- actor HP/MP/status/stance summaries
- `timing_projection`
- `result_state`
- `input_enabled`
- `unavailable_reason`

`CombatViewState`는 presentation focus를 위한 read model이다. HP, target eligibility, action cost, scheduler 결과를 presentation이 다시 계산하지 않는다.

### 15.2 combat layout

Primary Reference의 정보 우선순위를 16:9로 재구성한다.

- enemy/actor visual focus는 화면 중앙에 둔다.
- command category/action list는 왼쪽 anchor에 둔다.
- target focus는 대상 actor bounds에 둔다.
- player portrait/status/HP/MP band는 bottom anchor에 둔다.
- command list와 bottom band는 enemy silhouette의 핵심 판독 영역을 덮지 않는다.
- field mode에서는 combat band, command list, enemy timing bar를 전부 숨긴다.
- combat mode에서도 field space label, autosave, long control help, debug label을 추가하지 않는다.
- left panel과 bottom band는 Container/anchor로 구성하고 1280×720, 1920×1080, 2560×1440에서 같은 semantic focus를 유지한다.
- long action name, maximum status stack, long NPC name도 panel을 침범하지 않아야 한다.

### 15.3 combat bars

- `green timing bar`: `next_ready_progress`를 focused/primary enemy 아래에 표시한다. `0`은 현재 resolution 가능, `1`은 다음 scheduling window 끝이다.
- `target_hp_or_condition`: focused/primary enemy의 HP 또는 condition projection이다. enemy state를 읽기만 하고, combat domain이 계산한다.
- 두 bar 외 generic red bar, AP resource/label, AP gauge는 만들지 않는다.
- charge tell, target focus, status를 timing bar에 섞지 않는다.

### 15.4 presentation event

combat resolution은 `CombatPresentationEvent` 목록을 만든다. event는 다음 최소 type을 가진다.

- category change
- focus change
- target change
- action queued
- action rejected
- hit/miss
- critical
- guard mitigation
- dodge
- break
- status apply/remove
- charge stage
- reaction prompt
- actor death
- phase change
- encounter result

presentation은 event를 순서대로 재생하되 ordinary hit/motion event가 다음 command 입력을 막지 않게 한다. `REACTION_SELECT`, `COMBAT_RESULT`, field transition은 explicit input gate를 사용한다. motion이 끝났다고 domain state가 변하지 않는다.

## 16. Input action과 ModuleContext

### 16.1 manifest action whitelist

`top_down_action_rpg` manifest는 아래 action을 정확히 허용한다.

| action | keyboard default | gamepad meaning | field | dialogue | combat |
|---|---|---|---|---|---|
| `top_down_action_rpg_up` | W | D-pad/left stick up | move | focus | focus |
| `top_down_action_rpg_down` | S | D-pad/left stick down | move 없음 | focus | focus |
| `top_down_action_rpg_left` | A | D-pad/left stick left | move 없음 | focus | focus |
| `top_down_action_rpg_right` | D | D-pad/left stick right | move 없음 | focus | focus |
| `top_down_action_rpg_confirm` | Z | accept/face button | no-op | advance/select | select/confirm |
| `top_down_action_rpg_cancel` | X | cancel/back button | no-op | back | back |
| `top_down_action_rpg_interact` | E | context face button | interact | no-op | no-op |

기본 keyboard profile은 W/A/S/D/Z/X/E로 고정한다. joypad event는 같은 action에 추가할 수 있지만 Input Bubble profile에는 keyboard physical keycode만 넣는다. mouse hover는 gameplay focus를 제공하지 않는다. pointer click을 지원하더라도 button callback은 동일한 domain intent를 호출하고 context gate를 통과해야 한다.

### 16.2 ModuleContext 규칙

- module은 `context.input_enabled`, `context.allows_action`, `context.is_action_pressed`, `context.get_axis`만 사용한다.
- module-local code가 `Input.is_action_pressed`, `Input.is_action_just_pressed`, `InputMap`를 직접 호출하지 않는다.
- edge action은 module-local held map으로 새 press만 처리한다. held key가 frame마다 repeat command를 만들지 않는다.
- 모든 execute_command와 UI callback은 `context.input_enabled`와 현재 module mode를 확인한다.
- mode가 입력을 허용하지 않으면 `execute_command`는 false를 반환하고 state를 바꾸지 않는다.
- context가 다른 module의 action을 허용하지 않는지 integration test에서 확인한다.
- `context.input_enabled=false`가 되어도 held map, queue, reaction, animation을 강제로 진행하지 않는다. authoritative combat state만 보존한다.
- button callback도 동일 gate를 통과해야 하며, disabled UI를 direct signal로 우회할 수 없다.

### 16.3 Input Bubble

새 genre 전환에서 Input Bubble를 사용한다.

- Input cell identity는 module action 이름이 아니라 physical keyboard keycode로 관리한다.
- Z/X 등 이전 genre에서 사용한 physical key는 restore 후 같은 cell에 남는다.
- W/A/S/D/E처럼 이번 genre가 요구하는 새 key는 rising 후 intact가 된다.
- 이번 genre에서 필요 없는 key는 popped 흔적으로 남는다.
- 실제 key를 누르면 해당 cell이 pop된다.
- 설명문, 조작법 overlay, 상시 glyph은 Input Bubble를 대체하지 않는다.
- app/transition layer는 기존 `first_entry`의 `key_profile` command surface를 통해 profile을 전달한다. top_down module은 first_entry를 import하거나 직접 호출하지 않는다.
- physical keycode가 다른데 action 이름만 같은 두 key를 같은 cell로 취급하지 않는다.
- Input Bubble가 끝나기 전에는 field/combat gameplay input을 활성화하지 않는다.

### 16.4 mode별 input gate

- `FIELD`: up/down/left/right는 movement, interact만 authored object를 활성화한다. confirm과 cancel은 no-op이다. region exit은 반드시 passage interact로만 한다.
- `DIALOGUE`: up/down은 focus, confirm은 page/choice, cancel은 safe back만 처리한다.
- `SERVICE`: up/down은 focus, confirm은 item/equipment/service choice, cancel은 pending transaction을 rollback한 뒤 originating dialogue 또는 field focus로 돌아간다.
- `COMMAND_CATEGORY`/`COMMAND_ACTION`: up/down은 focus, confirm은 선택, cancel은 back만 처리한다.
- `TARGET_SELECT`: up/down은 target focus, confirm은 target commit, cancel은 action list다.
- `REACTION_SELECT`: up/down은 valid reaction과 Receive focus, confirm은 reaction, cancel은 Receive로 닫는다.
- `ENCOUNTER_TRANSITION`, `ENCOUNTER_RESULT`, `FIELD_RETURN`, `RECOVERY`: module gameplay action을 무시한다. Shell이 별도로 pause/menu를 소유한다.

## 17. Atomicity와 rollback

### 17.1 transaction 범위

module-local `AtomicState`는 combat, field interaction, encounter transition, equipment, dialogue choice에 같은 원칙을 적용한다. 전역 transaction service나 EventBus는 만들지 않는다.

- authoritative state의 deep working copy를 만든다.
- stable ID, primitive, array, finite number, dictionary만 복사한다.
- presentation queue, Node, Resource reference는 transaction 밖에 둔다.
- 모든 validation이 끝나기 전에는 source state를 변경하지 않는다.
- commit 성공 전에는 UI event, signal, module request를 내보내지 않는다.
- runtime error가 나면 source state를 그대로 유지한다.
- gameplay mutation과 presentation-only feedback를 분리한다.

### 17.2 rollback 규칙

- target/resource precondition 실패: authoritative state 유지, `rejected` result만 표시
- field trigger encounter 준비 실패: field state/trigger/position 유지
- combat action hook 실패: HP/MP/item/cooldown/status/phase 전부 pre-action state로 rollback
- dialogue choice 일부 effect 실패: choice 자체를 commit하지 않고 모든 effect를 원복
- equipment slot 변경 실패: 이전 equipment와 derived stat을 유지
- encounter result 적용 실패: combat outcome을 pending으로 보존하고 field return을 시작하지 않음

`last_error` 같은 presentation feedback은 gameplay mutation이 아니다. 단, save/load test에서는 gameplay state snapshot과 분리해 검증한다.

### 17.3 signal과 side effect

- `requested`/`finished`는 commit 뒤에만 발생한다.
- combat action이 content hook을 호출해 직접 field state를 바꾸지 못하게 한다. hook은 typed effect data만 반환한다.
- external request가 실패하면 domain state는 이미 commit된 결과를 rollback하지 않는다. request는 후속 module-local presentation 또는 AppRoot route consumer가 처리한다.
- signal 중복 방지를 위해 `resolution_serial`과 `event_serial`을 사용한다.

## 18. 구현 순서와 완료 증거

### 18.1 구현 순서

1. module manifest, entry scene, GameModule lifecycle을 만든다.
2. domain state와 JSON-safe codec를 만든다.
3. content definition과 validation fixture를 만든다.
4. AtomicState와 action intent를 만든다.
5. action scheduler와 combat resolution pipeline을 만든다.
6. Guard/Dodge/Break과 charge reaction을 만든다.
7. status와 equipment를 combat query에 연결한다.
8. field grammar와 encounter transition을 연결한다.
9. dialogue/choice flow를 연결한다.
10. combat presentation과 field/contextual UI를 연결한다.
11. authored fixture 두 개 이상으로 core 수정 없이 action/status/equipment를 추가한다.
12. GUT, import, smoke, 수동 play, 해상도 검증을 실행한다.

각 단계가 끝날 때마다 기존 save/load/reset/re-entry를 다시 확인한다. 새 authored content를 추가하기 위해 scheduler, parser, save codec, input routing, global state model을 반복 수정하면 중단하고 content schema를 고친다.

### 18.2 자동 test 파일과 필수 case

#### `test_top_down_field_grammar.gd`

- `FIELD-F01`: WASD analog 입력에서 대각선 normalized speed가 cardinal보다 크지 않다.
- `FIELD-F02`: collision shape에 blocked된 direction이 actor를 통과시키지 않는다.
- `FIELD-F03`: interaction radius 밖 object는 `interact`로 선택되지 않는다.
- `FIELD-F04`: 같은 radius의 interactable은 priority → stable ID 순서로 선택된다.
- `FIELD-F05`: passage contact/zone/interaction trigger가 조건을 만족할 때 한 번만 encounter를 시작한다.
- `FIELD-F06`: trigger validation failure가 field position, trigger flag, NPC state를 바꾸지 않는다.
- `FIELD-F07`: return snapshot의 position이 walkable이면 복원되고, 아니면 authored return anchor를 사용한다.
- `FIELD-F08`: field state에 combat HUD/gauge가 생기지 않는다.

#### `test_top_down_encounter_transition.gd`

- `ENC-E01`: mode가 `ENCOUNTER_PREPARE → ENCOUNTER_TRANSITION → COMBAT` 순서로 진행된다.
- `ENC-E02`: transition 중 movement/command input이 무시된다.
- `ENC-E03`: encounter roster/action/content validation 실패가 field state를 rollback한다.
- `ENC-E04`: victory/escape가 combat-local world effect를 한 번만 commit한다.
- `ENC-E05`: failure는 combat presentation을 반복하지 않고 recovery mode를 요청한다.
- `ENC-E06`: 전투 후 field의 NPC, prop, passage, trigger state가 expected variant를 읽는다.

#### `test_top_down_commands_targets.gd`

- `CMD-C01`: top-level category가 `Attack, Skill/Magic, Defend, Item, Escape, Equipment` 순서다.
- `CMD-C02`: Defend submenu가 `Guard, Dodge, Break` 순서다.
- `CMD-C03`: disabled action focus와 disabled state가 별도로 projection된다.
- `CMD-C04`: invalid target/resource action이 HP/MP/item/cooldown을 바꾸지 않는다.
- `CMD-C05`: `SELF`와 `ALL_*`는 target selection을 열지 않는다.
- `CMD-C06`: `ONE_ENEMY`, `ONE_ALLY`는 stable target focus를 사용한다.
- `CMD-C07`: dead/fled target은 cancel 없이 invalidation되고 next valid target으로 이동한다.
- `CMD-C08`: valid target이 없으면 target mode가 action list로 돌아간다.
- `CMD-C09`: `RANDOM_ENEMY`가 같은 seed/sequence에서 같은 actor를 선택한다.
- `CMD-C10`: End Turn이 queued action을 제거하지 않고 window만 닫으며, queued action이 있으면 그 cost 합계와 queued action이 없으면 pass cost 1을 예약한다.

#### `test_top_down_scheduler.gd`

- `SCH-S01`: `schedule_rate`이 action cost와 action slot을 변경하지 않는다.
- `SCH-S02`: 높은 schedule rate가 낮은 actor보다 먼저 같은 cycle에 선택된다.
- `SCH-S03`: 동일 ready tick에서 tie rank, command index, intent ID 순서가 유지된다.
- `SCH-S04`: `turn_cost=0` action은 action pool과 action slot을 소비하지 않는다.
- `SCH-S05`: `turn_cost=1` action은 schedule delay를 예약한다.
- `SCH-S06`: `turn_cost>1` action은 추가 command window를 늦춘다.
- `SCH-S07`: action slot 2인 actor는 normal command 두 개를 queue할 수 있다.
- `SCH-S08`: 일부 slot을 End Turn으로 끝내도 사용하지 않은 slot이 다음 window로 자동 이월되지 않으며, queued action이 있으면 추가 pass delay가 없다.
- `SCH-S09`: invalid queued target은 resource를 소비하지 않지만 예약된 schedule delay는 환불하지 않는다.
- `SCH-S10`: enemy AI가 없는 invalid action을 pass로 처리하고 즉시 무한 loop에 들어가지 않는다.
- `SCH-S11`: RNG serial을 save/load한 뒤 같은 action sequence가 같은 결과를 낸다.
- `SCH-S12`: multiple action slots 안에서 status/cooldown은 action마다가 아니라 actor window마다 한 번만 감소한다.

#### `test_top_down_combat_resolution.gd`

- `RES-R01`: 선택 중에는 HP/MP/inventory/cooldown이 바뀌지 않는다.
- `RES-R02`: action transaction hook이 고정 순서로 실행된다.
- `RES-R03`: reaction이 attack을 취소하면 damage/status/phase가 실행되지 않는다.
- `RES-R04`: lethal hit은 target status와 on-hit을 적용하지 않는다.
- `RES-R05`: `ALL_ENEMIES`는 resolution 시점 valid roster에 적용된다.
- `RES-R06`: single target invalidation은 action resource를 소비하지 않는다.
- `RES-R07`: late death가 queued action을 무효화하고 resolution event를 한 번만 만든다.
- `RES-R08`: transaction error가 partial HP/MP/inventory/world state를 남기지 않는다.
- `RES-R09`: commit 전에는 presentation event와 `requested` signal이 발생하지 않는다.
- `RES-R10`: phase transition, summon, linked actor, encounter result가 core 수정 없이 같은 action pipeline에서 실행된다.

#### `test_top_down_stances_charge.gd`

- `STANCE-G01`: Guard가 정확히 두 actor window 동안 mitigation을 적용한다.
- `STANCE-G02`: Guard는 self/true/DoT damage에 적용되지 않는다.
- `STANCE-G03`: Guard 중 ordinary counter가 차단되고 guard break recovery가 시작된다.
- `STANCE-D01`: Dodge는 deterministic roll을 한 번만 사용한다.
- `STANCE-D02`: Dodge는 dodgeable damage/status를 피하고 no-evade damage를 피하지 않는다.
- `STANCE-D03`: Dodge가 trigger하는 `on_evade`와 실행하지 않는 `on_hit`이 구분된다.
- `STANCE-B01`: Break power가 resistance보다 낮으면 damage만 적용되고 stance가 유지된다.
- `STANCE-B02`: Break 성공이 charge cancel, guard removal, skipped window를 만든다.
- `STANCE-B03`: immune target에 Break는 resource를 소비하지 않는다.
- `STANCE-B04`: unbreakable charge도 evade/resource/scripted response를 가질 수 있다.
- `CHARGE-C01`: charge는 telegraph → reaction → strike → recovery/completed 순서를 지킨다.
- `CHARGE-C02`: tell snapshot에 최소 두 channel과 charge stage가 존재한다.
- `CHARGE-C03`: reaction은 한 window에서 하나만 실행되고 turn cost/slot을 소비하지 않는다.
- `CHARGE-C04`: Break cancel은 strike를 막고 recovery/punish state를 남긴다.
- `CHARGE-C05`: control/death/phase policy가 charge를 authored rule대로 취소한다.
- `CHARGE-C06`: encounter-level checkpoint와 pre-command intent를 저장/복원한 뒤, combat 내부 transient charge state를 버리고 encounter를 checkpoint 경계에서 재개한다. combat mid-state resume은 지원하지 않는다.

#### `test_top_down_status_equipment.gd`

- `STATUS-T01`: status add, stack, refresh, expiry가 schema rule대로 동작한다.
- `STATUS-T02`: resistance와 immunity가 application 전에 평가된다.
- `STATUS-T03`: status duration/tick이 actor schedule window 단위로 감소한다.
- `STATUS-T04`: cure와 dispel이 tag와 deterministic order만 제거한다.
- `STATUS-T05`: 새 status fixture를 추가해도 combat core file이 수정되지 않는다.
- `EQUIP-E01`: weapon 변경이 다음 resolution의 basic attack definition을 바꾼다.
- `EQUIP-E02`: offhand/armor/accessory가 derived stat을 바꾸고 base stat을 오염시키지 않는다.
- `EQUIP-E03`: combat quick-equip이 normal turn과 action slot을 소비한다.
- `EQUIP-E04`: action-slot accessory가 다음 actor window부터 적용된다.
- `EQUIP-E05`: no-turn heal/cure/buff item이 resource를 한 번 소비하고 schedule을 바꾸지 않는다.
- `EQUIP-E06`: equipment가 field traversal key/pass와 combat action unlock을 변경한다.

#### `test_top_down_dialogue_atomicity.gd`

- `DLG-D01`: world frame과 NPC position을 유지한 채 dialogue band가 열린다.
- `DLG-D02`: page advance가 text page 순서를 유지한다.
- `DLG-D03`: choice focus, unavailable focus, result focus가 서로 구분된다.
- `DLG-D04`: cancel은 commit 전 이전 focus로 돌아가고 commit 후에는 rollback하지 않는다.
- `DLG-D05`: choice validation failure가 world/NPC/relationship/inventory를 바꾸지 않는다.
- `DLG-D06`: choice commit의 모든 effect가 성공하거나 모두 rollback된다.
- `DLG-D07`: NPC combat conversion이 same stable NPC ID를 유지한다.
- `DLG-D08`: unavailable choice reason이 색이 아닌 text/shape로 읽힌다.
- `DLG-D09`: dialogue, document, aftermath가 서로 다른 content type/state로 복귀 focus를 갖는다.

#### `test_top_down_module_integration.gd`

- `INT-I01`: manifest ID, entry scene, save version, 7개 action allowlist가 정확하다.
- `INT-I02`: context가 이 모듈의 action은 허용하고 다른 모듈의 action은 거부한다.
- `INT-I03`: input disabled 동안 keyboard action과 button callback이 모두 inert하다.
- `INT-I04`: save state가 JSON-safe이고 deep detached snapshot이다.
- `INT-I05`: load_state가 enter 전에 적용되고 reset/re-entry가 같은 default를 만든다.
- `INT-I06`: context/old module input이 retired된 뒤 새 module state를 바꾸지 않는다.
- `INT-I07`: module-local code에 `/root`, 다른 module import, 전역 EventBus가 없다.
- `INT-I08`: module-local code에 직접 `Input.*` polling이 없다.
- `INT-I09`: AppRoot manifest/catalog/InputMap/Input Bubble에 새 action이 반영된다.
- `INT-I10`: old save migration과 stale state rejection이 module 소유다.

#### `test_top_down_presentation.gd`

- `PRES-P01`: 1280×720, 1920×1080, 2560×1440에서 command, target, bottom band가 겹치지 않는다.
- `PRES-P02`: 720p에서 long action/status/NPC 이름이 잘리지 않는다.
- `PRES-P03`: focus는 keyboard와 gamepad 양쪽에서 읽힌다.
- `PRES-P04`: target focus, action focus, choice focus가 서로 다른 visual state다.
- `PRES-P05`: green bar는 domain timing projection과 같은 snapshot에서 갱신된다.
- `PRES-P06`: generic red bar/AP/debug label/field shell HUD가 release 화면에 없고, combat에는 `target_hp_or_condition`과 green bar만 남는다.
- `PRES-P07`: reduced motion에서도 hit, charge, target, focus, result information이 사라지지 않는다.
- `PRES-P08`: dialogue/document/aftermath layer가 world focus를 완전히 가리지 않는다.

### 18.3 검증 명령 순서

구현 후 Godot 4.7.2 stable, typed GDScript, GL Compatibility에서 아래 순서로 실행한다.

1. headless editor import
2. `res://tests/run_tests.gd`
3. `res://addons/gut/gut_cmdln.gd -gdir=res://tests/core -gexit`
4. main scene headless smoke, 180 frames, fixed 60 FPS
5. new top-down action-RPG tests만 먼저 실행해 회귀를 빠르게 분리
6. 실패 시 멈추고 기존 실패와 신규 회귀를 별도 기록

문서 변경만으로 게임 실행/시각 완료를 주장하지 않는다. 이 계획 작성 작업의 검증은 링크, 용어, target 파일 변경 여부만 확인한다.

## 19. 수치 tuning ledger

아래 값만 playtest로 조정할 수 있다. 구조, target mode, mode 순서, input action, transaction, scheduler 의미를 tuning으로 바꾸지 않는다.

- `MIN_RATE`
- `BASE_SCHEDULE_TICKS`
- reference agility와 action rate conversion
- player/enemy base agility
- action slot equipment의 실제 delta 범위
- action `turn_cost>1`의 실제 cost
- MP/item quantity와 cooldown 수치
- damage, healing, resistance, crit 수치
- Guard efficiency, guard break threshold, guard_broken duration
- Dodge base chance, weight, pressure, min/max clamp
- Break power, resistance, damage multiplier, broken window 수
- charge telegraph/reaction/recovery window 수
- reaction action duration과 feedback priority
- status duration, stack, DoT, regen, resistance 수치
- field movement speed, acceleration, interaction radius
- chase speed, leash, warning duration
- transition duration, iris, camera smoothing
- presentation motion duration, VFX intensity, audio volume, spacing

각 tuning 항목은 production data 또는 module-local tuning record에 두고 core branching을 만들지 않는다. 테스트는 production tuning 값에 의존하지 않고 deterministic fixture 값을 사용한다. 수치 조정은 `07_REFERENCE_GAME.md`와 `10_TESTS_AND_ACCEPTANCE.md`의 playtest evidence에 기록한다.

## 20. 금지 shortcut과 hardcoding 탐지

다음은 구현 중 발견 즉시 중단하고 구조를 고친다.

- scheduler를 단순 speed sort로 대체
- `schedule_rate`, `action_slots`, `turn_cost`를 한 stat으로 합치기
- action 또는 status ID를 core `match/if`로 하드코딩
- target을 거리, 인접, grid position으로 판정
- 모든 적을 Break로 해결
- 모든 charge에 동일한 Break/Dodge animation 강제
- field와 combat을 동일 continuous movement로 연결
- 전투 중 위치 이동/회피를 field control로 처리
- red-only focus, color-only status, hover-only detail
- generic red bar/AP 의미를 확인되지 않은 채 복제하지 않는다.
- dialogue result를 텍스트만으로 저장
- 선택/대상 실패 후 HP/MP/inventory를 먼저 소비
- no-turn action을 일반 turn action으로 되돌림
- equipment stat을 base stat에 직접 쓰고 해제 시 수동 복원
- action animation completion을 combat state 변화로 사용
- presentation Node에서 HP/target/cost/scheduler를 계산
- `/root`, 다른 module, global EventBus/autoload 참조
- Retired Prototype 또는 원작 asset/문구/캐릭터/world layout 재사용
- placeholder ColorRect/Label을 실제 field/combat world object로 완료 처리
- 상시 shell HUD, 우상단 menu, space label, 조작법 banner, debug label
- 한 map/한 boss/한 encounter를 Kit 완료로 주장
- image 생성/editing을 문서 계획 작업에서 임의 실행

## 21. 완료 증거와 상태 표기

이 Kit의 system/UX slice는 다음을 모두 제출해야 review-ready로 간주한다.

- 위 GUT test 전체 통과 결과
- headless import와 main scene smoke 통과 결과
- 새 action/status/equipment/encounter fixture를 core 수정 없이 추가한 diff
- module isolation, input allowlist, save/load/reset/re-entry 결과
- pre-command intent 경계 저장과 combat mid-state 미저장 확인 기록
- A~H와 대응하는 실제 화면 비교 기록
- `target_hp_or_condition`과 green bar의 combat 안/밖 화면 캡처
- charge tell, Guard, Dodge, Break, no-turn, equipment, choice focus 수동 기록
- 1280×720, 1920×1080, 2560×1440 캡처
- field→encounter→combat→field 전환 캡처
- target selection, unavailable, result, failure/recovery 화면 캡처
- 10분 이상 Reference Game 플레이 기록은 `07_REFERENCE_GAME.md`에서 별도 증명
- authored content 추가 후 core 파일 변경 없음 기록
- placeholder/상시 HUD/원작 복제 금지 검색 결과

사용자가 직접 플레이 검토 전에는 **검토 준비 완료**까지만 선언한다. 자동 테스트 통과만으로 최종 완료를 선언하지 않는다.

현재 문서 상태는 **계획 작성 대상이며 구현/검수 완료 증거가 아니다.**
