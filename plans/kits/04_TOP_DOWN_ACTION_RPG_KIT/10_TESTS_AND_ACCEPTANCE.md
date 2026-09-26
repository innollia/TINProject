# 테스트와 완료 판정 — Top-down Action-RPG Kit

Primary Reference: **BLACK SOULS 2 하나**

입력 정본: `docs/research/top_down_action_rpg/PLAN_RESOLUTION.md`, `01_SYSTEM_UX.md`, `02_WORLD_STATE_AND_ROUTES.md`, `03_STORY_AND_ENDINGS.md`, `04_CHARACTERS_AND_RELATIONSHIPS.md`, `05_ENEMIES_AND_ENCOUNTERS.md`, `06_AUTHORED_CONTENT_AND_DATA.md`, `07_REFERENCE_GAME.md`, `08_SAVE_DEATH_AND_RECOVERY.md`, `09_PRESENTATION_ART_AND_AUDIO.md`, `12_MAGIC_THEORY.md`, `docs/KIT_WORKFLOW.md`, `docs/MODULE_CONTRACT.md`.

이 문서는 구현·검증의 실행 계약이다. 자동 테스트 통과만으로 Kit 완료를 선언하지 않는다.
최종 자동 상태: **검토 준비 완료**까지 허용한다. 사용자 직접 플레이 검토 전에는 **최종 완성**을 쓸 수 없다.

문서 간 충돌은 `PLAN_RESOLUTION.md`가 정본이다. 이 문서가 다른 계획 문서와 다르면 그 차이를 기록하고 `PLAN_RESOLUTION` 해석을 따른다.

## 0. 판정 규칙

1. 아래의 모든 필수 테스트, 수동 과제, 캡처, audit가 `PASS`여야 한다.
2. `NOT RUN`, `SKIP`, `PARTIAL`, 실행 로그 없는 구두 확인은 `FAIL`과 같다.
3. 테스트가 한 번 실패하면 원인을 고치고 전체 gate를 처음부터 다시 실행한다. 실패한 실행만 반복해 녹색으로 바꾸지 않는다.
4. 기존 실패와 신규 회귀를 구분해 기록하되, 기존 실패를 완료 판정에서 면제하지 않는다.
5. 수치·간격처럼 구조를 바꾸지 않는 tuning은 이 문서를 먼저 고치지 않고 검수 기록에 남긴다. 시스템·입력·저장·화면 구조 변경은 해당 계획 문서를 먼저 갱신한다.
6. `알아서`, `게임답게`, `레퍼런스 느낌으로`, `적당히`, `필요하면`은 test oracle가 아니다. oracle는 값, 순서, 상태 전이, 화면 차 또는 absence 조건이어야 한다.
7. Reference Game의 10분은 자동 route 실행 시간, sleep, 로딩 시간, 반복 입력 시간으로 증명하지 않는다.
8. **retired 수치와 retired ID를 쓴 test는 그 자체로 `FAIL`이다.** §1.4 표에 없는 수, `06` §3.5에 없는 계획 ID, `08` §7의 canonical 7개가 아닌 recovery 표기, `05` §1.4의 5개가 아닌 target role이 oracle에 나타나면 구현을 고치는 것이 아니라 정본 문서를 먼저 확인한다.
9. 이 문서가 **새 수치를 만들지 않는다.** 모든 수의 정본은 §1.4 표의 "정본" 열에 적힌 문서에 있다. 이 표와 다른 plan 문서가 다르면 그 차이는 §0.8에 따라 report로 남기고, 이 문서만 고쳐 통과시키지 않는다.

## 1. 필수 구현물과 증거 위치

구현 시 아래 파일을 만든다. 지금 문서 작업에서는 이 파일들을 만들지 않는다.

### 1.1 GUT 9.7.1 테스트

```text
tests/core/test_top_down_action_rpg_domain.gd
tests/core/test_top_down_action_rpg_scheduler.gd
tests/core/test_top_down_action_rpg_content.gd
tests/core/test_top_down_action_rpg_content_world.gd
tests/core/test_top_down_action_rpg_content_magic.gd
tests/core/test_top_down_action_rpg_save_recovery.gd
tests/core/test_top_down_action_rpg_presentation.gd
tests/core/test_top_down_action_rpg_module.gd
```

- 모든 테스트는 `extends GutTest`를 사용한다.
- production 코드는 테스트 전용 branch로 동작을 바꾸지 않는다.
- fixture는 authored content index의 test-visible 사본 또는 동일한 validation 결과다. runtime content와 다른 기대값을 테스트 안에 복사하지 않는다.
- 각 test는 독립 실행 가능하다. test 이름 순서, 이전 test의 node, signal, RNG, InputMap, user save에 의존하지 않는다.
- `06`가 별도로 선언한 `tests/core/test_top_down_content.gd`는 schema/enum/range 계열 owned test다. 이 문서가 요구하는 ID는 위 8개 파일에 존재해야 하며, `06` 소유 ID와 이름이 겹치면 `06` 쪽 이름을 정본으로 삼는다.
- `world`/`magic` 분리 파일은 §5.1/§5.4의 test ID를 §5의 거대한 단일 파일에 밀어 넣지 않기 위한 분리다. `06` §11.1 unit 목록과 모순되지 않는다.

### 1.2 Performance/capture harness

```text
tests/performance/top_down_action_rpg_playthrough_probe.gd
tests/performance/top_down_action_rpg_visual_capture.gd
```

- `playthrough_probe`는 authored route와 state/event ledger를 검사한다. 10분 플레이 증거를 대체하지 않는다.
- probe는 §1.4의 canonical 수치(9 region / 18 edge / 9 gate / 9 cluster / 19 family / 25 encounter / 5 group / 6 variant / 5 NPC-conversion / 6 clock / 7 recovery / 6 ending)의 reachable state를 전부 출력한다. 하나라도 unreachable이면 exit code 0이 아니다.
- `visual_capture`는 실제 module runtime을 instantiate하고, 고정된 deterministic fixture로 16개 상태를 3개 해상도에서 캡처한다.
- capture harness는 workspace 밖의 새 directory만 입력받고, 기존 파일을 덮어쓰지 않는다.

### 1.3 완료 증거

```text
docs/research/top_down_action_rpg/acceptance/AUTOMATED_RESULTS.md
docs/research/top_down_action_rpg/acceptance/PLAYTHROUGH.md
docs/research/top_down_action_rpg/acceptance/SEED_AUDIT.md
docs/research/top_down_action_rpg/acceptance/PROVENANCE_AND_ISOLATION_AUDIT.md
docs/research/top_down_action_rpg/acceptance/RESOLUTION_MANIFEST.md
docs/research/top_down_action_rpg/acceptance/A1_NO_CORE_EDIT_MANIFEST.md
docs/research/top_down_action_rpg/acceptance/acceptance_playthrough.json
tests/performance/captures/top_down_action_rpg/<width>x<height>/*.png
```

증거 문서에는 build SHA, dirty-diff 기준 SHA, 실행 시각, Godot `4.7.2 stable`, GL Compatibility, GUT `9.7.1`, 실행 명령, exit code, test count, assertion count, 실패 로그 위치를 기록한다.

### 1.4 Canonical 수치 대조표 (이 문서가 검증하는 모든 수의 단일 source)

아래 값은 **여기서 새로 정하지 않는다.** 각 행의 "정본" 열 문서가 owner다. 다른 plan 문서나 구현이 이 표와 다르면 `PLAN_RESOLUTION.md` §10의 구현 게이트에 걸린다.

| 항목 | 값 | 정본 |
|---|---|---|
| region node | 9 (`H0` + `R1`~`R8`) | `02` §1, `06` §3.5.1 |
| `region_role` | 9개 closed token | `02` §1/§7.0, `06` §3.5.1/§5.10 |
| route edge | 18 (`E01`~`E18`), 전부 양방향 | `02` §5.2, `06` §3.5.2 |
| route state | `02` vocabulary 6개(`locked`/`open`/`conditional`/`redirected`/`closed`/`debt-bearing`), content `exits[].route_state`는 그중 5개(`locked` 제외), registry `initial state`는 3개(`locked`/`open`/`conditional`) | `02` §5.3, `06` §5.10 |
| route gate | 9 (`G0`~`G8`), `G9` 없음 | `02` §6.1, `06` §3.5.2 |
| event cluster | 9 (`HC-00` + `RC-01`~`RC-08`), 9 region과 1:1 | `02` §8, `06` §3.5.7 |
| cluster 규모 | core NPC 6~12, institutions 2~4, clocks 2~3 | `02` §8/§12, `03`, `04` §2.2 |
| canonical core NPC | 14 (`npc_01_ilyra_senn` ~ `npc_14_eda_marrow`) | `04` §2.1, `05` §1.1, `06` §3.5.3 |
| support resident | 7 (`npc_20_mira_vask` ~ `npc_26_cael_orin`), 전부 `roster_kind: support` | `04` §2.4, `07` §4.2, `06` §5.11 |
| 그 밖의 `npc_*` | 0건 (`npc_15`~`npc_19`, `npc_27` 이상 미정의) | `04` §2.3, `05` §1.1, `07` §4.1 |
| NPC conversion `npc_stable_id` | `npc_02`, `npc_04`, `npc_05`, `npc_01`, `npc_14` (모두 core 14 안) | `05` §6.3, `07` §5.1 |
| enemy family | 19 (`FAM-ARPG-01`~`19`), magic 층이 추가하는 것은 `FAM-ARPG-19` 1개 | `05` §1.1/§3, `06` §3.5.4 |
| encounter | 25 = field 11(`ENC-ARPG-01`~`10` + `ENC-ARPG-25`) + boss 14(`ENC-ARPG-11`~`24`) | `05` §1.1/§4/§5, `07` §5 |
| group | 5 (`GRP-ARPG-01`~`05`), 6번째 없음 | `05` §6.1, `06` §3.5.4 |
| variant | 6 (`VAR-ARPG-01`~`06`) | `05` §6.2, `07` §5.1 |
| NPC conversion | 5 (`NPC-CONV-ARPG-01`~`05`) | `05` §6.3 |
| action target mode | 6 (`SELF`/`ONE_ENEMY`/`ONE_ALLY`/`ALL_ENEMIES`/`ALL_ALLIES`/`RANDOM_ENEMY`) | `01` §7.1, `06` §5.5.2 |
| encounter target role | 5 (`actor`/`linked_actor`/`record`/`route`/`resource_node`) | `05` §1.4 |
| `turn_cost` | 정수 `0..5`, 의미 3단계(`0` no-turn / `1` normal / `2..5` committed) | `01` §8.3~§8.4, `06` §5.5.3 |
| combat resource | 3 (`hp`/`mp`/`equipment_charge`), AP 0건 | `01` §3.1/§15.3, `06` §2.7 |
| combat bar | 2 (green timing projection, `target_hp_or_condition`), generic red bar 0건 | `01` §15.3, `09` §4.1/§4.3, `06` §4.4.2 |
| action slot | 기본 1, `turn_cost=0`은 미소비, `turn_cost>=2`는 그 window에서 고정 1 | `01` §8.3, `06` §5.5.3 |
| action hook 순서 | 17단계 | `01` §9.3, `06` §5.5.5 |
| combat category | 6 + `End Turn` control | `01` §6.1, `09` §4.2 |
| orthogonal axis | 4개, 저장값은 integer `-3..3`, `D`는 7칸 | `02` §3/§3.3, `06` §6.1 |
| pressure clock | 6개, stage index `0..5`, irreversible index 4, terminal 5 | `02` §4/§4.1, `06` §5.6 |
| recovery type | 7개(`checkpoint`/`respawn`/`clone`/`reincarnation`/`loop`/`immortality`/`institutional_reentry`) | `08` §7, `06` §3.5.5 |
| crown alignment | recovery type 아님. `world.crown` 3 field + `clock_crown_alignment`에 쓰는 world write | `08` §7.7, `02` §9.3 |
| document page | `reading.max_lines_per_page` 9줄, 64자/줄 | `06` §5.14, `09` §7.1 |
| content kind | 18개(`magic`/`route`/`gate`/`cluster`/`group`은 kind가 아님) | `06` §1.2 |
| equipment `floor_role` | 6개 | `06` §5.18, `01` §13.4 |
| item `floor_role` | 2개(`no_turn_item_source`, `field_pass_key`) | `06` §5.19 |
| field/world resource | 53 = core 43 + magic 10, closed | `02` §5.4/§5.5, `06` §6.3 |
| 비수량 debt key | 2개(`res_labor_pledge`, `res_contract_tally`), `amount` 없음 | `02` §5.5, `06` §6.4 |
| save root | 12 key = envelope 4 + section 8 | `08` §4.2, `06` §10.1 |
| `STATE_TOKEN` | 27개 (closed) | `06` §10.2 |
| `preserves`/`discards` token | 27 / 7 (`preserves`는 `STATE_TOKEN` 27의 부분집합. root `world.*` section에 대응하는 것은 19개) | `08` §4.2.2, `06` §5.8/§10.2 |
| payload float | `field.actor.x`/`field.actor.y` 2개 field만 | `08` §4.1, `06` §10.3-4 |
| combat mid-state resume | 불가. `encounter_start`/`phase_start` 경계 + pre-command intent만 | `08` §2.3/§4.3/§5.5, `06` §10.4-7 |
| seed denominator | 160 = core 120(`S001`~`S120`) + magic 40(`S121`~`S160`) | `02` §11.1, `06` §5.1/§13.1 |
| seed gate | distinct `PLANNED_RETAINED` transform `>= 96` (160 × 600‰), preferred planned `120` | `02` §11.1, `06` §5.1 |
| ending | 6개 | `03` §16, `06` §3.5.6 |
| Reference Game run | 5개(direct / body / resource / craft / full survey) | `07` §10, §15.2 |
| magic `craft_family` | 3 (`weave`/`rigid_fold`/`void_cut`) | `12` §3, `06` §5.5.7 |
| `concentration_source` | 3 (`field`/`body_load`/`social_permission`) | `06` §14.2 |
| `mana_profile` | 8 closed token, catalog distinct 4 이상 | `12` §2.2, `06` §5.11.1 |
| magic status | 5 (`concentration_load`/`medium_residue`/`misfolded`/`overflowed`/`contract_bound`) | `05` §2.2, `06` §5.4.1 |
| magic failure 등급 | 3 (`recoverable`/`continuity-changing`/`terminal`) — recovery type 아님 | `12` §8, `05` §2.8.4 |
| `world.magic` 하위 record | 6 (`concentration_fields`/`body_load`/`circulation`/`crafts`/`contracts`/`glossary`) | `02` §9.1, `06` §10.2 |
| magic institution | 6 branch | `12` §5.2 |
| core 무수정 예외 | 2회 한도, `changed_core_files == []`이 A1 성공 조건 | `06` §12.2/§12.3, `07` §14.2 |
| capture state / 해상도 | 16 state × 3 해상도 = PNG 48개 | `10` §14.2, `09` §14.1 |
| 수동 플레이 과제 | M01~M15 | `10` §13 |

**retired 값 목록(사용하면 `FAIL`):** 8 region / 17 edge / 24 encounter / 18 family / 15 authored family / 12 group / 6 recovery / 5 recovery / 4 clock floor / 120 units 분모 / gate 72 / preferred 90 / `created_content_revision` root key / `progression.inventory` / `progression.quest_state_by_id` / `checkpoint_return` / `clone_branch` / `loop_rehearsal` / `immortal_continuation` / `crown_alignment`를 recovery kind로 사용 / `game_over` / `R-RETURN`·`R-CROWN`·`R-ARCHIVE`·`R-LATENCY`·`R-LEXICON`·`R-VISCERA`·`R-SERVICE`·`R-COMMON`·`R-SEAM` / `CLUSTER_COUNT = 8` / `gate_g9` / `npc_15_*`~`npc_19_*` / `PLAYER_BRIDGE_0`.

## 2. Deterministic test contract

### 2.1 고정값

- scheduler/content corruption RNG seed: `0x54494E41`
- scheduler test horizon: 같은 snapshot에서 `10,000` resolution
- frame-rate smoke: `--fixed-fps 60`
- actor/command/content 동률 순서: `01_SYSTEM_UX.md`가 선언한 **총체적 tie-break**를 사용한다.
- `01_SYSTEM_UX.md`에 actor ID, command sequence, target ID까지 포함된 총 tie-break가 없으면 scheduler test와 Kit 완료 판정은 `FAIL`이다. 테스트가 임의 tie-break를 만들지 않는다.
- JSON/ledger 비교는 dictionary key를 고정 순서로 직렬화한 canonical event ledger를 비교한다.

### 2.2 Event ledger 필수 필드

```text
tick
actor_id
command_id
target_id
resolution_phase
result_code
state_before_hash
state_after_hash
```

- `state_*_hash`는 combat/domain snapshot의 stable ID와 JSON-safe 값만 canonicalize해 만든다.
- presentation node, Node instance ID, wall-clock time, frame delta, dictionary insertion order는 ledger에 넣지 않는다.
- 동일 snapshot·동일 command stream·동일 seed는 10,000 tick 뒤 byte-identical ledger를 낸다.
- actor 배열 순서와 Dictionary insertion order만 바꾼 실행은 같은 ledger를 낸다.
- scheduler/domain은 `randi`, `randf`, `Time.get_unix_time_from_system`, `Time.get_ticks_usec`, frame delta를 읽지 않는다.

### 2.3 Test isolation

각 test teardown은 다음을 복원한다.

- `Input.action_release` 후 test가 만든 `InputMap` action 삭제
- `ModuleContext.input_enabled`와 transient focus 복원
- RNG seed 복원
- AudioServer bus layout 복원
- SceneTree timer, tween, callable, signal 연결 해제
- `user://tin_tests_<pid>_<ticks>_*` fixture 삭제
- `user://`의 일반 `save.json`을 읽거나 쓰지 않음

wall-clock timeout은 test hang 방지용일 뿐 gameplay oracle로 쓰지 않는다.

## 3. Domain/system GUT

`test_top_down_action_rpg_domain.gd`의 아래 test ID가 모두 존재하고 `PASS`여야 한다.

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_command_intent_validates_before_any_mutation` | resource 부족, cooldown, dead actor, invalid target, disabled state에서 각 command intent 제출 | 모든 command가 `false`; HP/MP/equipment_charge/cooldown/scheduler/world state가 pre-intent snapshot과 동일. `ap`/`max_ap` field는 애초에 없다 |
| `test_target_modes_select_stable_actor_ids` | `SELF`/`ONE_ENEMY`/`ONE_ALLY`/`ALL_ENEMIES`/`ALL_ALLIES`/`RANDOM_ENEMY` 6개 전부 실행 | 결과가 stable actor ID로 기록되고, 제거·사망한 actor는 partial resolution 없이 무효 처리. `RANDOM_ENEMY`는 같은 encounter seed에서 같은 actor |
| `test_encounter_target_roles_resolve_without_damage_roll` | `actor`/`linked_actor`/`record`/`route`/`resource_node` 5개 role을 각 encounter target priority로 실행 | 4개 non-body role은 permit/proof/resource/route action으로만 resolve되고 HP roll이 0건. role은 target mode로 promote되지 않음 |
| `test_guard_dodge_break_have_distinct_counter_results` | 같은 authored attack fixture에 Guard, Dodge, Break, commit을 각각 실행 | mitigation/evasion/stance break/counter-cancel 결과가 `01_SYSTEM_UX.md` 표와 일치; 서로 같은 boolean으로 collapse되지 않음 |
| `test_status_hooks_duration_control_and_cure` | damage DoT, stat modifier, control, cure, resistance/immunity, dispel fixture 실행 | 각 hook이 명시된 tick과 query에서만 적용; cure category가 다른 status를 지우지 않음 |
| `test_equipment_modifiers_recompute_without_mutating_base_stats` | weapon, offhand, armor, accessory, active skill, resistance/behavior, no-turn item, action-slot source, key/pass equip/unequip | effective query만 변하고 base definition/runtime base value는 원상 유지. 4 slot만 존재 |
| `test_phase_trigger_and_override_are_data_driven` | encounter start, HP ratio, cumulative loss, tick/window count, external flag, linked actor death, status stack, resource threshold, story/NPC state, relationship state, consent/refusal, clock threshold, phase completion으로 authored phase 진입 | action set/resistance/roster/invulnerability/arena/completion이 data override를 따르고 combat core 분기가 늘지 않음. `06` §5.15의 6개 `trigger.kind` + `completion.kind` 외 값 0건 |
| `test_summon_owner_lifecycle_and_true_target` | encounter-start, HP-step, periodic, owner-death protect/kill/remain, flee, lifetime fixture 실행 | owner/count/max_count/true target/death/escape 결과가 authored lifecycle과 일치. encounter당 true-target role은 1개 |
| `test_pressure_clocks_advance_independently` | 6개 canonical clock(`institutional_response`/`contamination`/`public_record`/`resource_collapse`/`personal_collapse`/`crown_alignment`) 각각에 대해 동일 tick에 다른 clock을 1 tick 진행 | 한 clock의 tick이 다른 clock 값을 변경하지 않음; 6개 모두 `02` §4.1의 6칸 stage ladder를 갖고 `index 4`가 irreversible, `index 5`가 terminal이며 `index 5`에서 시작하는 region 0건. 어떤 clock도 4개 이하 floor로 통과하지 못함 |
| `test_clock_write_transactions_move_one_clock_each` | magic과 비-magic authored event를 각각 실행 | 한 transaction이 6개 중 정확히 1개 clock만 전진시키고 두 번째 clock은 별도 transaction으로 기록됨. 실패한 cast는 `K`(medium residue) 또는 `P`(body load) 중 하나, `R`은 failure document가 Filing될 때만 |
| `test_immediate_and_delayed_consequences_fire_once` | 같은 event를 두 번 submit, reload, revisit, phase transition으로 처리 | immediate effect 1회, delayed effect 1회; duplicate request와 replay는 추가 effect를 만들지 않음 |
| `test_world_change_has_explicit_surface_deltas` | authored irreversible choice와 clock threshold 실행 | dialogue flag가 아니라 명시된 NPC presence, relationship, route, world prop, encounter/reward surface 중 하나 이상이 실제 변함 |
| `test_recovery_operation_preserves_declared_identity_layers` | canonical 7개 전부(`checkpoint`, `respawn`, `clone`, `reincarnation`, `loop`, `immortality`, `institutional_reentry`) fixture 실행 | `08_SAVE_DEATH_AND_RECOVERY.md` §7의 보존/손실 표와 일치; body, memory, role, belief, institution, desire, social recognition 7개 layer가 완전 분할되고 한 lump로 복구되지 않음 |
| `test_player_knowledge_is_not_a_persistence_gate` | discovery flag 없는 clean state와 이미 발견한 state에서 같은 authored solution command 실행 | 두 상태의 command admissibility와 resolution이 동일; knowledge flag는 domain gate가 아님 |
| `test_crown_alignment_is_a_world_write_not_recovery_type` | `G8` 실행과 `rec_*.kind = crown_alignment` 주입 | `G8`는 `world.crown.precedence`/`operator_id`/`object_phase`와 `clock_crown_alignment` irreversible stage만 쓰고 `recovery` section에는 쓰지 않음. `crown_alignment`를 `rec_*.kind`로 넣으면 `recovery_kind_violation` |

## 4. Scheduler determinism GUT

`test_top_down_action_rpg_scheduler.gd`의 아래 test ID가 모두 존재하고 `PASS`여야 한다.

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_same_snapshot_seed_and_commands_repeat_exactly` | 같은 fixture를 fresh domain 두 개에서 10,000 tick 실행 | 두 canonical event ledger가 byte-identical |
| `test_actor_insertion_order_does_not_change_resolution` | 동일 actor set의 insertion order만 다르게 구성 | 두 ledger가 byte-identical |
| `test_dictionary_insertion_order_does_not_change_resolution` | 동일 data의 Dictionary insertion order만 다르게 구성 | 두 ledger가 byte-identical |
| `test_declared_total_tie_break_is_applied` | 모든 scheduling key가 같은 actor/command fixture | `01_SYSTEM_UX.md` §8.5의 총 tie-break 순서와 event ID 순서가 일치 |
| `test_schedule_rate_action_slots_and_turn_cost_are_independent` | rate, slots, turn cost를 한 축씩만 변경 | 각 축이 다른 축의 값을 암묵적으로 변경하지 않음 |
| `test_turn_cost_accepts_only_integer_zero_through_five` | `turn_cost`에 `0`, `1`, `2`, `5`, `-1`, `0.5`, `6`, `"full"`, `"none"`, `"partial"` 주입 | `0..5` 정수만 통과하고 나머지는 `turn_cost_out_of_range` / `turn_cost_not_integer`. 문자열 token은 조용히 default 되지 않음 |
| `test_turn_cost_zero_one_and_committed_have_three_distinct_semantics` | `turn_cost=0` / `1` / `2..5` fixture | `0`은 action pool·action slot·scheduler clock을 소비하지 않지만 resource/cooldown은 1회 소비, `1`은 slot 1개와 progress 1, `2..5`는 그 window의 유일한 normal command이며 `action_slots=1` 고정과 locked window를 만든다 |
| `test_no_turn_command_occupies_selected_slot_without_advancing_schedule` | no-turn heal/buff/equipment/craft command와 turn-cost command 비교 | no-turn command는 선택된 action slot을 소비하고 scheduler tick은 소비하지 않음; cooldown/resource/MP는 선언대로 한 번 처리 |
| `test_extra_action_slot_queues_exact_number_of_commands` | action slot 1/2/3 fixture에서 동일 command stream 실행 | 선택 tick의 command 수가 plan 값과 같고 resolution 순서가 stable. `turn_cost>=2` action은 같은 window의 다른 command를 허용하지 않음 |
| `test_charge_prepare_and_commit_phases_are_separate` | charge action의 prepare, visible tell, commit, recovery 실행 | prepare와 active attack이 서로 다른 tick/phase; cancel 정책 전까지 active attack 발생하지 않음. telegraph channel 2개 이상 |
| `test_break_cancels_only_authored_breakable_charge` | breakable, unbreakable, dodge-only, resource-lock charge에 Break 실행 | authored `break_policy`를 따르고 forbidden response는 charge를 취소하지 않음. `break_policy=immune` 대상은 focusable-disabled이고 resource를 소비하지 않음 |
| `test_late_death_invalidates_pending_action_atomically` | action queue의 target 또는 actor가 먼저 resolution됨 | pending command는 cancelled/retained rule대로 처리되고 partial HP/resource/status/world mutation이 없음 |
| `test_scheduler_resume_replays_identically_from_encounter_boundary` | encounter-level checkpoint(`encounter_start`/`phase_start`)에서 JSON snapshot 후 10,000 tick 재개 | 중지 전까지의 ledger와 같은 suffix가 resume 뒤 생성됨. 전투 내부 진행은 resume 대상이 아님 |
| `test_domain_contains_no_unseeded_entropy_or_frame_dependency` | domain/system source static scan과 60/144/240 FPS simulation 비교 | 금지 entropy/time API direct use 0건; resolution ledger가 모두 동일 |

## 5. Content pipeline GUT

`test_top_down_action_rpg_content.gd`, `test_top_down_action_rpg_content_world.gd`, `test_top_down_action_rpg_content_magic.gd`의 아래 test ID가 모두 존재하고 `PASS`여야 한다.

### 5.1 World / NPC / cluster / ending catalog

`test_top_down_action_rpg_content_world.gd`

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_region_graph_matches_02_canonical_world` | `region_*` 9개, `route_e*` 18개, `gate_g*` 9개 수집 | `H0`+`R1`~`R8` 9개가 `02` §1/§3.5.1과 집합 일치, `E01`~`E18` 18개가 `02` §5.2와 양방향 1:1, `G0`~`G8` 9개가 `02` §6.1과 1:1. `gate_g9` 0건, `edge_endpoints_mismatch` 0건, `edge_not_bidirectional` 0건 |
| `test_region_role_is_closed_to_nine_tokens` | 9개 `region_*.region_role`과 그 region의 모든 enemy/encounter `region_role` 수집 | 9개 token이 `02` §1/§7.0과 문자 단위로 일치. token이 10개 이상이거나 `02`가 바꾸지 않은 이름이면 `region_role_mismatch`. `region_secondary`는 해석되는 canonical `region_id` |
| `test_route_state_vocabulary_is_closed_to_02` | `exits[].route_state`, `internal_routes[].route_state`, `world.routes[<edge>].state`, `02` registry `initial state` 수집 | `02` §5.3의 6개 token 밖 값 0건. content `exits[].route_state`는 `locked`를 쓰지 않고 5개 중 하나, registry `initial state`는 `locked`/`open`/`conditional` 3개 중 하나. `conditional`/`closed`/`redirected`/`debt-bearing` edge에 `requires_condition`이 비면 `conditional_edge_without_condition`. 모든 edge에 실제 adjacency path와 최소 1개 우회 edge, 모든 region에 return affordance 2개(`exits` + `internal_routes`) |
| `test_cluster_registry_has_nine_clusters_each_six_to_twelve` | `region_*.initial_cluster` 9개 수집 | `HC-00` + `RC-01`~`RC-08` 9개가 9 region과 1:1이고 `cluster_id`가 전역 유일. 각 cluster가 core NPC 6..12, institutions 2~4, clocks 2~3, partial truth, resource conflict, immediate write, delayed write를 가짐. cluster participant는 core 14 안에서만 뽑히고 support resident 7명이 participant로 집계되지 않음 |
| `test_fourteen_core_npcs_own_the_canonical_roster` | 14 core NPC record + 5 NPC conversion + 9 cluster participant 수집 | `npc_01_ilyra_senn`~`npc_14_eda_marrow` 정확히 14명. 각 NPC가 23-field core dossier 필드, `interaction_verbs` 4개, system port, survival/death/absence result, relationship state, revisit log를 가짐. `npc_15`~`npc_19` 사용 0건. canonical player role `role_field_investigator`는 NPC가 아니며 `PLAYER_BRIDGE_0` 잔존 0건 |
| `test_seven_support_residents_are_not_core_roster` | `npc_20_mira_vask`~`npc_26_cael_orin` 7명 수집 | 전부 `roster_kind: support`. core roster 14에 포함되지 않고, `id`/`public_role`/`private_role`/`capability.port_ids`/`resource_access`/`knowledge_boundary`/`clock_ids`/`cross_link_ids` 2개 이상/`absence`/`oneoff_dialogue_seed_ids`를 가짐. 학교 측 write field 4개 밖의 field를 쓰지 않음. `npc_27` 이상 0건. `npc_26_cael_orin`과 `npc_11_cael_ren`이 병합되지 않음 |
| `test_major_branch_has_six_to_twelve_npc_cluster` | `03`/`07`의 major branch와 cluster 매니페스트 전수 검사 | 각 major branch가 NPC 6~12, institutions 2~4, clocks 2~3, partial truth, resource conflict, immediate/delayed consequence를 가짐. retained seed 2개 이상 cross-link. NPC가 한 장소에 모두 모이지 않아도 되며 결과는 dialogue 한 줄이 아님. baseline 8개 cluster(`HC-00`+`RC-01`~`RC-07`)와 A1 9번째 `RC-08`가 같은 규칙을 따른다 |
| `test_axis_values_use_02_integer_ladder` | 4개 축의 저장값과 초기 matrix 9 region 전수 검사 | 모든 값이 integer `-3..3`이고 `02` §3.3 mapping의 index와 일치. `*_floor`/`*_peak` 칸 규칙(5칸 축 A/C는 양쪽, 6칸 B는 위쪽, 7칸 D는 확장 없음) 일치. `03`의 별도 3-value ladder token 0건, `resource_scarcity`의 `strained` 칸 누락 0건, token 문자열 저장 0건 |
| `test_four_orthogonal_axes_remain_independent` | protocol legitimacy, recognition drift, continuity pressure, resource scarcity 변경 | 한 axis mutation이 다른 axis 값을 정규화·복사·합산하지 않음. 한 event가 두 축을 건드리면 `commit_log`에 축 write가 2줄 |
| `test_ending_catalog_matches_03_and_rewrites_roster_ids` | ending catalog 6개, route 5개, truth, relationship 원본 | ending 6개(`end_r1_receipt_of_a_life`, `end_g1_law_without_master`, `end_o1_many_mouths_one_person`, `end_a1_empty_seat`, `end_c1_four_anchors`, `end_c2_last_witness`), route 5개, truth·relationship 원본, world/NPC/route/relationship/clock surface 변경 최소 1, ending 전용 NPC 추가 0건, 14 core roster stable ID 외 re-key 0건, ending content ID는 `06` §3.5.6과 1:1 |
| `test_ro_08_has_no_orphan_ending_path` | `RC-08` resolve 후 도달 가능한 모든 ending 경로 검사 | `RC-08`에서 도달 가능한 ending 6개 전부가 `03` §16의 authored ending이다. `G5`가 `refused`로 Filing되어 `E18`이 `closed`인 run에서도 `RC-08`이 authored 우회(`R5` 내부 industrial permit craft, 또는 `END_O1`/`END_C2` fallback)로 종료되며 미작성 상태로 남지 않는다. `RC-08` 전용 NPC/ending이 새로 만들어지지 않음 |
| `test_field_resource_keys_are_closed_to_06_registry` | `res_*` 참조 전수 수집 | `06` §6.3의 53개(core 43 + magic 10) 밖 token 0건. `res_labor_pledge`/`res_contract_tally`는 `amount`가 없고 `surplus_keys`/`traversal_key`로 쓰이지 않음. combat resource(`hp`/`mp`/`equipment_charge`)가 field namespace에 섞인 경우 0건 |

### 5.2 Combat vocabulary / encounter catalog

`test_top_down_action_rpg_content.gd`

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_target_modes_accept_only_closed_enum` | `act_*.intent.target_mode` 전수 수집 | canonical 6개(`SELF`, `ONE_ENEMY`, `ONE_ALLY`, `ALL_ENEMIES`, `ALL_ALLIES`, `RANDOM_ENEMY`)만 통과. legacy 8 token(`linked_actor`, `record`, `route`, `resource_node`, `positionless`, `single_enemy`, `all_enemies`, `random_enemy`)은 전부 validation error이고 runtime에서 조용히 default 되지 않음 |
| `test_encounter_level_target_roles_are_not_action_target_modes` | `enc_*.target_roles[]`, `enc_*.target_priority[].role`, `enemy_*.linked_actors[].role` 수집 | `record`/`route`/`resource_node`은 `enc_*.target_roles[]`에서만, `linked_actor`는 `enemy_*.linked_actors[].role`과 `enc_*.target_priority[].role`에서만 등장. 5개 role(`actor`/`linked_actor`/`record`/`route`/`resource_node`)이 6번째 role이나 7번째 target mode를 만들지 않음 |
| `test_turn_cost_is_bounded_integer_with_three_semantics` | `act_*.cost.turn_cost`에 `0`, `1`, `2`, `5`, `-1`, `0.5`, `6`, `"full"`, `"none"`, `"partial"` 주입 | `0..5` 정수만 통과(`-1`/`0.5`/`6` → `turn_cost_out_of_range`, 문자열 → `turn_cost_not_integer`). `0`이면 `action_slot_cost` 없음, `2..5`이면 `action_slot_cost == 1` + `lifecycle` `instant`/`committed` + `commitment` 존재. `lifecycle == "charge"`이면 `turn_cost >= 1` + telegraph channel 2개 이상 |
| `test_no_ap_resource_or_label_exists` | `hp`/`mp`/`equipment_charge` 외 resource key와 combat band/presentation fixture 전수 검사 | `ap`/`max_ap`/`action_points`/`stamina`/`momentum`/`focus`가 content·save·presentation 어디에도 0건. `player.body.vitals`에 AP field 0건. combat bar는 green timing projection과 `target_hp_or_condition` 2개뿐이고 AP label/gauge/generic red bar 0건. action slot은 command footer의 `행동 n` text로만 표현 |
| `test_encounter_catalog_matches_05_counts_and_region_roles` | `enemy_*` 19개, `enc_*` 25개 수집 | family 19개(`FAM-ARPG-01`~`19`) 모두 최소 1 encounter/variant/group에서 사용. encounter 25개 = field 11 + boss 14. 각 encounter가 `region_id`, `region_role`, roster, target priority, activation, valid/invalid counter, break policy, statuses, phases, linked actors, reward/resource effect, aftermath, clock links, `V`/`E`/`F`/`N` 4 outcome을 가짐. 각 record의 `region_role`이 그 region의 `06` RegionDefinition 값과 일치 |
| `test_five_group_templates_are_closed` | `enc_*.group`가 참조하는 group 5개 수집 | `GRP-ARPG-01`~`GRP-ARPG-05` 5개가 모두 resolve되고, 6번째 이후 `unrekeyed_planning_id`. 각 group이 기존 family/action record의 composition이고 family-specific combat branch 0건 |
| `test_each_encounter_has_counter_and_aftermath` | 25개 encounter와 그 action 전수 검사 | valid counter, forbidden response, telegraph 2개 이상 channel, authored break policy, world/reward aftermath 최소 2 surface가 누락된 encounter 0건. 모든 boss가 2개 이상의 서로 다른 counter 축을 가짐 |
| `test_stable_ids_are_unique_namespaced_and_nonempty` | actor/action/status/equipment/item/region/npc/encounter/event/clock/route/seed ID 수집 | duplicate 0, empty 0, `^[a-z][a-z0-9_]*$` 위반 0, prefix 불일치 0, 길이 3~64 위반 0, display name을 ID로 사용한 entry 0. **점(`.`)과 하이픈(`-`)이 들어간 stable ID 0건** |
| `test_all_authored_assets_load_and_schema_versions_match_manifest` | authored index의 18개 kind 전부 entry load | parse error 0, declared schema와 runtime schema 일치, unreachable entry 0. `route`/`gate`/`cluster`/`group`/`magic`이 kind로 등록된 경우 0건 |
| `test_every_reference_resolves_or_has_explicit_migration` | 모든 `$ref`, owner, true target, route, effect, presentation asset 참조 검사 | unresolved reference 0; 제거된 ID는 explicit migration alias를 가져야 함. `region_secondary` 미해석 0건 |
| `test_duplicate_missing_and_stale_ids_fail_with_stable_diagnostics` | duplicate ID, missing action, removed NPC, stale encounter, `unrekeyed_planning_id`, retired `R-*` key, `gate_g9`, `grp_arpg_06` fixture 주입 | validation 실패, 오류 코드가 `01`/`05`/`06` contract와 일치, diagnostic 순서가 file path→ID→field로 동일 |
| `test_validation_failure_order_is_deterministic` | 같은 broken bundle을 20회 load | 20회 error code, path, field, ID가 동일 |
| `test_content_runtime_is_json_catalog_not_resource_identity` | `content/` tree와 authored identity 검사 | content runtime이 JSON catalog + module-local loader이고 Godot `Resource`는 presentation reference/optional authoring wrapper일 뿐 canonical identity가 아님. save payload에 `Resource`/`Node` 0건. `content/magic/` 디렉터리와 `magic_` prefix ID 0건 |
| `test_remix_reuses_existing_actor_action_and_encounter_core` | `VAR-ARPG-01`~`06` late remix/variant authored entry load 및 resolve | 기존 stable definition에 data override만 적용; 새 combat 구현 class/branch 0. 각 variant가 declared solution을 명시하고 유효 counter를 조용히 제거하지 않음 |
| `test_corruption_rules_are_authored_and_deterministic` | 각 document corruption rule을 seed별로 반복 | random typo/runtime RNG 0; 같은 state/page/seed의 token visibility와 line layout 동일. `mode` enum 4개(`recolor`/`replace_token`/`shatter_line`/`drop_glyph`)와 `text_note` 필수 규칙 준수 |
| `test_document_pages_never_exceed_nine_line_cap` | `doc_*.pages[].lines` 전수 검사 | `reading.max_lines_per_page`가 정확히 9이거나 그보다 엄격한 값. 9보다 크면 `document_cap_overridden`, page가 상한을 넘으면 `document_page_overflow`. 1줄 64자 이내, `min_font_size >= 20`. `index.options.document_page_line_cap`이 9가 아니면 `document_cap_not_nine` |
| `test_no_authored_id_or_dialogue_literal_exists_in_production_gd` | 모든 authored stable ID와 dialogue text를 production `.gd`와 대조 | 교집합 0; system action/enum 이름과 authored content ID는 별도 namespace. **magic 이론의 positive 이름 0개**(`R4` glossary가 Filing되기 전 코드 알 수 없음) |
| `test_content_expansion_fixture_does_not_require_core_change` | §11 A1 package(region 1 + support NPC 7 + encounter 1)을 data로 load하고 hash 비교 | §11의 pre/post SHA-256 manifest가 동일하고 `changed_core_files == []`, `loader_changed`/`validator_changed`가 content 등록 외 사유로 true가 아님. §11.2의 play evidence 요구는 자동 test가 아니라 §11/§12.5에서 판정한다 |

### 5.3 Equipment / items

`test_top_down_action_rpg_content.gd`

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_equipment_and_items_schema_and_allowlist_are_owned_by_06` | `equipment_*`/`item_*`의 `schema_version`, root key allowlist, enum, range, prefix 검사 | 두 kind의 schema가 `06` §5.18/§5.19에 있고 `01`에 prose만 남지 않음. allowlist 밖 key 0건, `unrekeyed_planning_id` 0건, definition이 0개여도 `READY_WITH_DEFECTS`가 되지 않음. 수량이 `max_equipment_definitions`/`max_item_definitions`을 넘지 않음 |
| `test_equipment_floor_reuses_action_economy` | `equipment_*`/`item_*`의 `floor_role`과 연결 action/field key 전수 검사 | 6개 `floor_role`(`weapon_basic_attack`, `granted_active_skill`, `resistance_behavior`, `action_slot_source`, `no_turn_item_source`, `field_pass_key`)이 catalog에 각각 최소 1개 존재. `item_*`의 `floor_role`은 `no_turn_item_source`/`field_pass_key` 2개만. `item.use.action_id`의 action이 `category == "item"`이고 `cost.turn_cost == 0`. `action_slot_source`는 `action_slot_delta != 0`이고 다음 command window부터 적용. `field_pass_key`는 `traversal_key` 또는 `pass_ids`가 존재. 6개 role이 core 수정 없이 combat/field에 연결 |
| `test_equipment_does_not_hold_runtime_or_presentation_values` | `equipment_*`/`item_*`의 stat/base/Color/path 필드 검사 | `base_value`/`current_value` 같은 runtime 값 0건, `Color`/path/`importance` 0건, `max_ap` 0건. derived query는 `base + equipment + status + temporary action modifier` 순서로만 재계산되고 equipment 해제가 base stat을 직접 쓰지 않음 |

### 5.4 Magic 층 / `R8` / `changed_core_files == []`

`test_top_down_action_rpg_content_magic.gd`

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_magic_adds_no_axis_clock_or_recovery_kind` | catalog 전수 검사 | world axis 4개 외 0건, pressure clock 6개 외 0건, `rec_*.kind` 7개 외 0건, target mode 6개 외 0건, lifecycle 3개 외 0건, status op 추가 0건, phase trigger type 추가 0건. `mana`/`mana_pool`/`concentration` 단일 resource와 전역 `concentration` bar 0건 |
| `test_magic_action_schema_is_data_only` | `act_*.craft` 전수 검사 | `craft`는 `06` §5.5.7의 14개 key만 허용. `craft`가 있으면 `category == "magic"` + `damage_payload.delivery == "magical"`. `craft_family` 3개(`weave`/`rigid_fold`/`void_cut`), `concentration_source` 3개(`field`/`body_load`/`social_permission`), `body_profile_requirements`는 `mana_profile` 8개 부분집합, `medium_options`는 `res_*` ID, `turn_cost`는 `01` §8.4 정수 `0..5`의 새 범위가 아님. `craft.environment_effect.clock_id`는 6개 canonical clock 중 하나이고 한 craft에 clock 2개 0건. `craft.social_recording.resource_id`는 `res_craft_credit`/`res_lineage_token`/`res_contract_tally` 3개만 |
| `test_magic_status_set_is_exactly_five` | `st_concentration_load`, `st_medium_residue`, `st_misfolded`, `st_overflowed`, `st_contract_bound` 검사 | magic status가 이 5개뿐이고 전부 존재. `st_overflowed.control.blocked_action_categories`에 `magic`이 있고, `st_concentration_load`/`st_medium_residue`의 `stat_deltas`가 비어 있으며, `st_contract_bound.tick.operations`가 비어 있음. 6번째 magic status 0건. `contamination`/`ink_bloom`을 residue 규칙으로 재사용한 record 0건 |
| `test_magic_failure_writes_status_clock_and_record_atomically` | `recoverable`/`continuity-changing`/`terminal` 3등급 fixture | 각 등급이 `05` §2.8.4의 combat/world 표현과 일치하고, 한 resolution이 status + clock + record를 한 transaction으로 쓴다. 한 write가 6개 clock 중 2개를 전진시키지 않음. terminal 등급이 region에서 사람을 제거하지 않고 authored lock/record만 남김 |
| `test_prepared_craft_and_improvisation_share_action_schema` | `preparation_turns >= 1`인 prepared craft와 `== 0`인 field improvisation | 같은 `act_*.craft` schema를 쓰고 cost/state만 다르다. 준비된 craft가 없으면 실행 action이 `cast_without_prepared_craft`로 resolve되지 않는다 |
| `test_portal_contract_creates_deferred_obligation_and_never_auto_resolves` | `R7-09`/`R8-06` contract 체결 후 `G8` 실행 | `contract_tally`이 증가하고 미해결 obligation이 `world.magic.contracts[].obligation_state == "open"`으로 남는다. 자동 resolve·tick down·combat cost 소모 0건. `clock_crown_alignment`는 contract 하나로 전진하지 않고 `G8`의 interpretation input으로만 동작 |
| `test_magic_theory_label_stays_untranslated_until_r4_glossary_fills` | `world.magic.glossary` slot이 비어 있는 상태에서 craft 이름 Filing | `R4` glossary가 비어 있으면 craft 이름이 `untranslated term`으로 Filing되고 학교 이름과 archive 번역이 두 줄 모두 남는다. `untranslated_theory_label` 0건 |
| `test_mana_profile_diversity_meets_floor` | `npc_*.mana_profile`과 `act_*.craft.body_profile_requirements` 전수 검사 | 8개 closed token만 통과하고, catalog 전체 distinct `mana_profile` 4개 이상(`retention`/`emission`/`overflow`/`blocked` 계열 포함). profile이 도덕 평가어로 옮겨지지 않음 |
| `test_concentration_field_is_not_a_global_bar` | `region_*.concentration`과 combat player band/HUD projection 검사 | `field_level_permille`이 combat player band·world map·상시 HUD에 노출되지 않음. `contaminated` 같은 bool flag를 content가 만들지 않음. `pollution_accumulated`가 0으로 되돌아가지 않음. `safe_band_permille < threshold_permille` |
| `test_r8_lands_with_changed_core_files_empty` | `R8` package(region 1 + support NPC 7 + encounter 1 + variant/conversion/actions/statuses/`res_*`)를 data로 로드 | pre/post SHA-256가 동일해 `changed_core_files == []`. `change_ledger`의 `seed_status_changes == []`. 새 recovery type/axis/clock/target mode/lifecycle/status op/phase trigger 0건. `R8`의 `entry.edge_id`와 `exits[0].edge_id`가 둘 다 `route_e18_folding_school_approach`이고 `exits` 1개 + `internal_routes` 1개로 return affordance 2개. `G9` 0건 |
| `test_magic_records_survive_checkpoint_and_are_json_safe` | checkpoint 전후 `world.magic` 6종 roundtrip | `concentration_fields`의 `provenance`, `body_load`의 injury, `contracts`의 `open` obligation, `glossary`의 채워진 slot이 rollback되지 않는다. `res_contract_tally` 카운터 자체가 payload에 없고 `open` entry 수로 재계산되며, `st_concentration_load`/`st_medium_residue`의 threshold 도달 bool이 저장되지 않고 재계산된다. `world.magic`가 `world.axes`/`world.flags`/`world.clocks`와 섞이지 않음 |

## 6. Anti-generic seed audit

`test_top_down_action_rpg_content.gd`에 아래 test ID가 추가되어야 한다.

| Test ID | oracle |
|---|---|
| `test_seed_usage_counts_distinct_units_not_lines` | denominator는 `06` §5.1 `seed_ledger.json`의 160 고정 = core 120(`S001`~`S120`) + magic supplement 40(`S121`~`S160`). distinct `PLANNED_RETAINED` transforms `>= 96`(= 160 × 600‰), preferred planned `120`. source line count는 denominator가 아님. `extracted_units`를 161 이상으로 올리지 않음 |
| `test_seed_gate_is_96_distinct_planned_retained_transforms` | `quota.minimum_retained == floor(extracted_units * ratio_permille / 1000)` 산술 일치, `ratio_permille == 600`, `gate_status_token == planned_retained`, `post_review_status_token == used`, `post_review_counts_toward_gate == false`, `preferred_planned >= minimum_retained`. `planned_retained`가 96 미만이면 `ledger_quota_unmet` |
| `test_planned_seed_never_claims_used_or_transformed_in_planning` | content와 plan 문서의 모든 seed row가 `PLANNED_RETAINED`. `USED`/`TRANSFORMED`/`used` planning claim 0건, `planning_claim` key 0건 |
| `test_planned_seed_is_not_auto_promoted_to_used` | `planned_retained → used` 승격 경로가 repository에 0개. 승격이 있었다면 `change_ledger`에 별도 entry로 남아 있고 `seed_status_changes`는 `[]` |
| `test_used_seed_counts_only_after_review` | `used`로 집계된 seed마다 허용된 post-review evidence가 존재. `used` 승격이 gate 재집계에 쓰이지 않음 |
| `test_used_promotion_requires_resolved_delayed_effect` | `used` seed의 `delayed_consequence.effect_id`가 전부 해석됨. gate 실패 + `status == planned_retained`이면 `seed_gate_failed_without_rejection` |
| `test_magic_seed_supplement_gate` | `S121`~`S160`이 전부 `ledger_section: "L"`, `S001`~`S120`이 `L`이 아님. 각 planned_retained magic seed가 4개 gate를 통과: `magic_seed_wrong_section` 없음, magic `res_*` 10종 또는 `world.magic` 6종 sub-record를 읽거나 씀, `bindings`가 `region_r8_folding_school`만 아니고 core roster 참조 1개 이상, `delayed_consequence` effect가 `advance_clock`/`set_clock_stage` 1개 이상 |
| `test_used_seed_has_complete_transformation_record` | 모든 used seed가 seed ID, source intent, TIN structural change, local rule, binding, cross-link A/B, immediate consequence, delayed consequence, generic-risk result를 가짐 |
| `test_used_seed_resolves_to_reachable_authored_content` | 모든 used seed가 실제 content ID와 runtime state delta에 연결; 계획 목록만 있고 구현 binding 0건은 미사용 |
| `test_used_seed_has_distinct_crosslinks` | A/B는 서로 다른 system/NPC/region/faction/clock/route 대상이고 `cross_link_a.kind != cross_link_b.kind`이며 `cross_link_a.id != cross_link_b.id`. 동일 대상의 이름 변경 2개는 cross-link 2개가 아님 |
| `test_name_removal_does_not_collapse_seed_to_filler` | seed와 source surface를 가리고 local rule, cause, consequence를 읽었을 때 다른 content와 구분됨; 불가하면 `filler`로 회수 |
| `test_generic_risk_rejects_known_shortcuts` | name-only, duplicate, source-copy-risk, tone-only, unbound, weirdness-only는 used 집합에서 제외. `CANDIDATE`/`DROP`은 `used`가 될 수 없음. `provenance.no_original_wording_copied == false`면 `source_copy_risk`. 단일 section 25% 초과면 `ledger_section_over_share` |

### 6.1 수동 seed review

`SEED_AUDIT.md`는 96개 이상 `PLANNED_RETAINED` seed를 표본이 아닌 전수 검토하고, post-review `used` 승격은 별도 허용된 evidence가 있을 때만 한다. 각 row에 다음을 기록한다.

```text
seed_id
content_id
local_rule
system_npc_region_binding
cross_link_A
cross_link_B
immediate_consequence
delayed_consequence
generic_risk
reviewer_result
```

`PASS` 조건:

- distinct `PLANNED_RETAINED` count가 96 이상이다. preferred 120을 목표로 기록하되 96 미달은 실패, 120 미달은 기록 대상이다.
- 각 planned row의 anti-generic gate가 명시적으로 `PASS`다. `TONE`/`ONEOFF`도 두 cross-link와 immediate/delayed consequence를 가져야 한다.
- `CANDIDATE`, `DROP`, duplicate, source-copy-risk, unbound, tone-only가 retained/used로 세어지지 않는다.
- root/module/system/tone/oneoff는 서로 다른 structural burden이 아니다.
- reviewer가 seed/source surface를 가리고도 content의 인과 규칙을 식별할 수 있다.
- magic seed 40개는 `S121`~`S160` 범위로 별도 표본이 아니라 전수 검토하며, theory의 positive label을 기록하지 않는다.

## 7. Save / recovery GUT

`test_top_down_action_rpg_save_recovery.gd`의 아래 test ID가 모두 존재하고 `PASS`여야 한다. `08` §14이 이 절의 oracle 우선권을 명시한다.

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_save_root_matches_08_twelve_key_envelope` | fresh `save_state()`의 root와 section 검사 | root key 집합이 `08` §4.2의 12개와 정확히 같다(envelope/scalar 4 + section 8). allowlist 밖 key 0건, 빠진 key 0건. `state_format == "top_down_action_rpg.save.v1"`, `save_version == ModuleManifest.save_version`, `run_id` 불투명, `content_revision`이 sha256 hex 64 |
| `test_state_token_allowlist_matches_06_twenty_seven` | 각 section의 child key와 `rec_*.preserves`/`discards` 검사 | child key 집합이 `06` §10.2 표와 문자 단위로 일치. `STATE_TOKEN` 27개가 `rec_*.preserves`의 부분집합이고 `discards`는 7개로 닫힘. `08`에 없는 이름(`progression.inventory`, `progression.quest_state_by_id`, `created_content_revision`) 0건 |
| `test_default_state_is_json_safe` | fresh load 후 `save_state()` | string key, primitive, Array, Dictionary만; Node/Resource/Callable/Vector/NaN/Inf 0건 |
| `test_float_payload_is_limited_to_two_field_actor_fields` | payload recursive float scan | float이 존재하는 field가 `field.actor.x`/`field.actor.y` 2개뿐이고 `JSON.stringify`→`parse`→`==` 비교가 정확히 성립. 그 외 field의 float 0건, `chance` float 0건(`chance_permille` 사용) |
| `test_player_body_vitals_has_no_ap_field` | `player.body.vitals` schema 검사 | `hp`/`max_hp`/`mp`/`max_mp`/`statuses`만 존재. `ap`/`max_ap` 0건. `player.body` 7개 self layer가 `body`/`memory`/`role`/`belief`/`institution`/`desire`/`social_recognition`으로 완전 분할 |
| `test_field_combat_dialogue_document_snapshots_follow_policy` | 각 state에서 snapshot | `08`가 허용/거부한 state가 실제 load result와 일치; presentation-only focus/hover/tween은 저장하지 않음 |
| `test_every_supported_previous_version_migrates_to_current` | manifest가 지원한다고 선언한 모든 이전 version fixture | current schema로 migration되고 deep copy되며 source dictionary 불변. `created_content_revision` → `save_version` + `content_revision`, `progression.inventory`/`quest_state_by_id` → `progression.equipment`/`items`/`conversations`/`documents` |
| `test_future_schema_version_is_rejected_transactionally` | current보다 높은 version load | module/load transaction 거부, 현재 instance와 save envelope 유지 |
| `test_malformed_state_does_not_partially_mutate_runtime` | wrong type, NaN/Inf, missing required field, cyclic-like duplicate reference, oversized bound, root allowlist 밖 key | `08`의 explicit fallback/reject 결과만 발생; HP/resource/scheduler/world partial mutation 0건. root allowlist 밖 key는 제거되고 사실이 module-local load log에만 남음 |
| `test_save_load_roundtrip_is_semantically_exact` | field, combat 경계, dialogue page, document page, aftermath, clock threshold, `world.magic`에서 roundtrip | JSON deep roundtrip 후 canonical domain snapshot 동일; transient presentation만 재구성 |
| `test_saved_state_is_detached` | 반환 Dictionary/Array/nested Dictionary를 호출자가 변형 | 저장 snapshot과 module state 불변 |
| `test_combat_mid_state_is_never_restored` | `mid_combat_v1.json` fixture(`08` §4.3 금지 목록: `turn_index`, `scheduler_cursor`, `next_action_slot`, `phase_id`, `actors`, `statuses`, `stance_state`, `charge_stage`, `charge_stage_costs`, `valid_reaction_ids`, `reaction_selection`, `rng_serial`, `rng_state`, roll 값, `resolution_phase`, `*_event_serial`)를 load | 거부되고 이전 runtime state 유지. load 후 `combat` 안의 scheduler/action slot/actor/status/phase/charge stage/reaction이 전부 비어 있음. 전투 중 저장은 정상 성공하며 거부 사유가 아니다 |
| `test_charge_and_reaction_restore_is_intent_or_checkpoint_only` | charge telegraph/reaction 창 중 강제 종료→재실행 | charge stage/reaction window는 복원되지 않는다. charge를 **시작하기 전** pre-command intent가 복원되고 charge가 그 intent를 다시 resolve한 결과로 새로 시작된다 |
| `test_pre_command_intent_is_revalidated_on_load` | `encounter_start`/`phase_start` 경계에서 저장한 intent 목록 | `resume_boundary`는 3개 닫힌 값 중 하나. 저장된 intent는 `01` §9.1 queue 검증으로 재검증되고 실패 항목은 `01` §9.4 late invalidation 결과로 처리되며 resource를 소비하지 않는다. 순서가 round-trip 후 동일. encounter RNG가 `(run_id, active_encounter_id, attempt_serial)`에서 결정론적으로 재현 |
| `test_no_ledger_resume_across_save_boundary` | `content_revision` 불일치 상태에서 load 후 10,000 tick 재개 | 불일치만으로 거부되지 않고 §10 stale 처리가 실행되며 진행이 보존된다. resume 뒤 ledger는 save 이전 execution과 동일한 prefix/suffix를 만든다 |
| `test_scheduler_resume_replays_identically` | encounter-level checkpoint에서 combat queue 중간 save→load | 저장 전 ledger prefix와 load 후 ledger suffix가 uninterrupted 실행과 동일 |
| `test_reset_restores_declared_default_only` | changed state에서 reset | `reset_encounter`/`reset_interaction`/`reset_current_region`/`reset_run`이 `08` §11.1의 scope만 재생성; 새 `run_id`가 발급되고 이전 run 파일은 남음; 다른 module state 불변 |
| `test_death_recovery_is_single_shot_and_transactional` | fatal result, stale callback, repeated fatal request, `rec_*` 부재/불허용/stale destination | recovery request/transition 1회; `game_over` 경로 0건; failed destination 또는 invalid save면 원 state/envelope 유지. 임의 respawn 0건 |
| `test_seven_recovery_types_match_identity_table` | canonical 7개 전부(`checkpoint`, `respawn`, `clone`, `reincarnation`, `loop`, `immortality`, `institutional_reentry`) | `08` §7 표의 body/memory/role/belief/institution/desire/social recognition 보존·손실 결과와 일치. `respawn`과 `checkpoint`가 서로 다른 authored outcome. `clone`이 source와 다른 individual/body/social ID를 만들고 memory snapshot 이후 source 변화가 자동 전파되지 않음. `loop`이 knowledge/filed debt/record/continuity count를 유지하고 nested loop가 parent branch ID를 보존. `immortality`가 branch debt 또는 실제 resource/consequence write를 commit |
| `test_recovery_type_names_are_canonical_seven` | `rec_*.kind`에 canonical 7개와 retired 이름 주입 | canonical 7개만 통과. `checkpoint_return`/`clone_branch`/`loop_rehearsal`/`immortal_continuation`은 `recovery_kind_token_mismatch`. 8번째 type(`crown_alignment`, `game_over`)은 `recovery_kind_violation`. magic failure 3등급(`recoverable`/`continuity-changing`/`terminal`)이 `kind`로 들어오면 reject |
| `test_self_layer_partition_is_complete_and_disjoint` | 7개 type 각각의 `rec_*.self_layers_restored` ∪ `self_layers_not_restored` 검사 | 7개 layer의 완전 분할. 겹치면 `recovery_layer_overlap`, 빠지면 `recovery_layer_gap`. omitted layer를 "전부 유지"로 해석하지 않음 |
| `test_clone_and_loop_continuity_pressure_persists` | clone social split, loop responsibility shift, immortality branch debt | shared memory와 distinct social continuity가 동시에 유지; death cost는 삭제·reset되지 않음. lineage와 current incarnation이 별도 ID |
| `test_crown_alignment_world_write_preserves_operator_and_precedence` | `G7` 제출 후 `G8` 실행 | `Crown of Continuance` literal object와 `Crown Protocol`이 유지되고 operator만 교체. 이전 operator memory는 archive copy로 읽히고 active world state에서 지워지지 않음. 이전 phase는 revisit archive로만 읽히고 global write는 reset되지 않음. alignment가 recovery UI/flow로 나타나지 않고 `world.magic`/`recovery.continuity`에 operator가 중복 저장되지 않음. alignment 후에도 7개 recovery type이 전부 사용 가능 |
| `test_stale_content_id_uses_declared_recovery` | action/NPC/encounter/route/region/prop/flag/record/contract ID를 제거하거나 alias한 save/event 주입 | `08` §10.2 표의 한 결과만 발생: optional entry drop + load log, `active_checkpoint_id` stale이면 load 거부(임의 checkpoint로 대체 금지), `pending_outcome_id` stale이면 recovery commit 거부, `world.records` stale이면 `recovery_unavailable` surface, `transaction.delayed_writes` target stale이면 invalid content. `orphaned_record_ids` 같은 별도 orphan 목록 0건, historical ID는 `commit_log`/`recovery.history` tombstone 2곳에만 존재 |
| `test_stale_deferred_callback_cannot_mutate_new_instance` | target death/region exit/enemy phase 후 deferred resolution 발화 | generation 또는 stable owner validation이 실패하고 새 state 불변 |
| `test_save_does_not_store_player_knowledge_gate` | discovery flags를 제거한 migration/save fixture | 이미 안다는 해법/입력을 막는 persisted flag 0건(`known_solutions`, `clue_found` 0건); world observation state와 player knowledge 분리. `loop` recovery가 `ready_with_defects` 사유가 아님 |
| `test_revisit_preserves_consequences_without_replaying_oneshot_effects` | same region/event 재진입 | world/NPC/relationship/route state 유지; immediate/delayed one-shot effect 재발동 0건. NPC initial state 재생성 0건 |
| `test_failed_restore_preserves_world_magic_and_progression` | stale `world.magic`/`progression.equipment_slots` ID 주입 | `world.magic` 6종의 stale entry만 drop되고 `provenance`/injury/`open` contract/filled glossary는 유지. slot의 장비가 없으면 그 slot만 빈 문자열. 정상 world state를 placeholder로 지우지 않음 |

## 8. UI/presentation GUT

`test_top_down_action_rpg_presentation.gd`의 아래 test ID가 모두 존재하고 `PASS`여야 한다.

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_field_state_has_no_shell_or_combat_hud` | field normal, dialogue pre-open, document pre-open | Shell, Menu/Journal button, location/autosave/key hint, combat HP/MP/status/행동 n band 모두 hidden; `target_hp_or_condition`도 combat-only. Shell은 Esc 전 visual presence 0 |
| `test_combat_band_exists_only_in_combat` | field→encounter→combat→return | combat 전후 hidden, combat command/target/resolution 중 visible; 값은 domain snapshot projection. field에 `concentration_field`/route map/clock 이름 상시 노출 0건 |
| `test_target_hp_or_condition_bar_is_domain_projected` | combat에서 focused/primary enemy를 바꿔 가며 두 bar 관찰 | `green timing bar`와 `target_hp_or_condition` 2개만 존재. 값은 `CombatState` projection이고 UI가 앞에서 재계산하지 않음. generic red bar/AP label/AP gauge/`condition_exposure` 같은 두 번째 alias 0건. 두 bar 모두 dialogue/document/field/aftermath에 복제되지 않음 |
| `test_dialogue_preserves_world_and_speaker_identity` | Conversation, page advance, ChoiceSet | world/player/NPC 위치 관계 유지, portrait/speaker/text 순서 유지, giant world-removing modal 없음 |
| `test_choice_focus_is_not_color_only` | keyboard/gamepad focus 이동, normal/extreme presentation class | focus가 위치·내부 brush·line/shape 중 둘 이상으로 구분됨; red class와 focus state 독립 |
| `test_unavailable_choice_is_readable_and_blocked` | available/unavailable/irreversible choices | focus는 logical order를 유지하고 focusable disabled도 자동으로 skip하지 않음; unavailable은 semantic 보조 channel과 disabled intent block을 가짐; result 후 defined focus 복귀 |
| `test_target_selection_focus_cancel_and_fallback` | canonical `SELF/ONE_ENEMY/ONE_ALLY/ALL_ENEMIES/ALL_ALLIES/RANDOM_ENEMY` target, encounter-level role(`record`/`route`/`resource_node`), cancel, target 제거 | target identity가 명시되고 cancel은 command pre-intent 상태로 복귀하며 HP/MP/action slot/scheduler를 소비하지 않음; 제거 target은 `01` §7.2 순서로 다음/이전 slot을 찾고, 없으면 target mode 취소 후 action list 복귀. focus 순서는 `encounter_slot` 순서이며 wrap하지 않음. hover-only focus 0건 |
| `test_disabled_during_transition_rejects_intent` | encounter/document/result transition 중 command/button | command `false`, resource/world/scheduler 불변, focus owner가 hidden node에 남지 않음 |
| `test_hit_miss_status_break_result_feedback_projects_domain` | hit/miss/critical/status/guard/dodge/break/charge cancel 결과 | 각 결과의 visible channel이 domain result와 일치; UI가 scheduler를 계산하지 않음. `End Turn`은 action이 아니고 slot/turn cost를 소비하지 않음 |
| `test_document_pages_fit_advance_and_respect_nine_line_cap` | 최소/최대/긴 page(9줄), 마지막 page, revisit | page advance affordance, line wrap, no clipping/overlap, 9줄 초과 content가 화면에서 자동 분할·잘림으로 처리되지 않음, return state가 `09` capture fixture와 일치. `min_font_size` 720p 하한 유지 |
| `test_corruption_is_not_random_or_red_only` | authored corruption 단계와 accessibility state | 같은 state 결과가 결정적; 정보는 shape/placement/authored token 등 non-color channel로도 읽힘 |
| `test_aftermath_projection_matches_revisited_world` | event 전/직후/재방문 | aftermath prop, NPC presence, route/document variant가 실제 world state와 일치. `R8`의 filed grade/dispersed residue/recovered medium/unresolved contract 4개 revisit variant가 서로 다른 화면을 만든다 |
| `test_recovery_surface_projects_changed_world_not_a_summary` | 7개 recovery type 후 화면 | 전용 결과 화면/버튼 목록/타입 이름 요약이 없고, 변경된 같은 world가 projection된다. `recovery_unavailable`은 임의 respawn으로 바뀌지 않는다. safe focus가 정확히 한 번 활성화 |
| `test_esc_open_close_restores_module_focus` | field/combat/dialogue/document 각각에서 Esc open/close | input locked, menu visible, close 후 module input과 이전 유효 focus 복귀 |
| `test_input_bubble_states_follow_binding_contract` | rising→intact→popped, next-gen restoring, unnecessary popped, rebinding | physical key→stable cell, transition 순서, 실제 binding 표시, gameplay description text 0건 |
| `test_ui_never_owns_domain_truth` | domain snapshot을 직접 변경한 뒤 frame settle | visible projection은 새 domain state로 갱신되고 presentation node의 cache가 source of truth가 아님 |
| `test_layout_rects_do_not_overlap_at_target_resolutions` | 1280×720, 1920×1080, 2560×1440에서 16개 fixture | 모든 visible Control가 viewport 안, 상호 blocking UI pair overlap 0, command/bottom band가 enemy focal point를 가리지 않음. green timing bar와 `target_hp_or_condition`이 겹치지 않음 |
| `test_visibility_state_machine_is_complete` | initial/normal/focus/active/disabled/failure/success/return와 empty/loading/maximum/save restored/reset | `09`의 state table에 정의된 visibility와 focus만 나타남; hidden subtree가 input을 가로채지 않음 |

### 8.1 UI 금지 상태의 자동 판정

아래 조건 중 하나라도 true면 실패다.

- field에 combat resource band 표시
- Shell/Menu/Journal/debug label 상시 표시
- `AP` label / AP gauge / AP resource 표시
- combat bar가 green timing + `target_hp_or_condition` 2개를 넘는 경우
- central modal이 world play를 대체
- Label/ColorRect가 authored world object의 최종 표현
- focus가 색 한 채널에만 의존
- red semantic이 unavailable/danger/sexuality를 자동으로 뜻함
- random corruption 문자열
- 장문 조작 설명
- source asset/font/frame/portrait 복제
- UI가 future scheduler tick, enemy action, route availability를 자체 계산
- `concentration_field`/clock 이름/axis 값/cluster 수를 상시 노출

## 9. Module lifecycle / isolation GUT

`test_top_down_action_rpg_module.gd`의 아래 test ID가 모두 존재하고 `PASS`여야 한다.

| Test ID | 실행 | 정확한 oracle |
|---|---|---|
| `test_manifest_is_registered_once_in_app_and_library` | catalog와 game_library 등록 검사 | catalog와 game_library에 `top_down_action_rpg`가 각각 정확히 1회; display name과 stable ID가 manifest와 일치 |
| `test_load_state_precedes_enter_with_fresh_context` | load hook/event 순서 기록 | 새 context가 attach되고 load state 적용 후 enter; `_ready`에서 gameplay 시작 0건 |
| `test_enter_and_exit_call_super` | instrumented fixture | context/input/process_mode가 core contract대로 설정·정리됨 |
| `test_allowed_actions_equal_manifest_allowlist` | manifest actions와 실제 polling/callback 비교 | `01` §16.1의 7개 action allowlist와 누락·추가 0건; 모든 button callback도 input_enabled 확인 |
| `test_foreign_input_cannot_mutate_module` | 다른 module action과 미등록 action 주입 | state hash와 command result 불변 |
| `test_input_disabled_during_pause_and_transition` | pause, encounter transition, document transition, death transition | 모든 gameplay intent blocked; hidden Shell만 동작 가능. held map/queue/reaction/animation을 강제 진행하지 않음 |
| `test_module_host_contains_exactly_one_child` | boot, normal switch, failed switch, restore, unload | child count 1; 실패 rollback 후 이전 instance 유지 |
| `test_repeated_switch_recreates_context_and_frees_old_module` | 12회 다른 module↔target module 전환 | 매번 새 instance/context; 이전 context disabled, node freed, signal/timer 누수 0 |
| `test_exit_disconnects_owned_signals_and_timers` | combat 중 exit, dialogue 중 exit, transition 중 exit | owned callback 0, live Timer/Tween 0, late callback 0, external signal 연결 0 |
| `test_unknown_command_is_rejected_atomically` | 존재하지 않는 command와 malformed payload | `false`; state와 focus 변화 0 |
| `test_requested_signal_emits_payload_only_for_current_instance` | stale instance와 current instance가 동시에 request | stale request 0건; current payload deep copy |
| `test_finished_signal_is_emitted_once` | terminal success를 두 번 trigger | `ModuleResult` 1건, module ID/outcome/data가 contract와 일치 |
| `test_failed_restore_preserves_current_instance_and_save` | future version, stale ID, malformed state로 restore | transaction rollback; current instance, save envelope, world presentation focus 유지 |
| `test_reset_does_not_mutate_other_module_state` | target module reset 전후 SaveService 전체 snapshot 비교 | target module declared default만 변경; 다른 module/global state 불변 |
| `test_app_root_remains_present_across_transition` | load target module 전후 AppRoot/Core/ModuleHost identity 비교 | AppRoot와 core nodes 동일 instance; ModuleHost child만 교체 |
| `test_gameplay_does_not_start_before_enter` | instantiate만 하고 frame 진행 | scheduler/event/clock/content side effect 0건 |

## 10. 자동 실행 gate

PowerShell에서 아래 순서를 그대로 실행한다. 각 단계는 exit code 0이어야 하며, 실패 시 즉시 중단한다.

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "Godot import failed: $($p.ExitCode)" }
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/run_tests.gd' -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "Integration runner failed: $($p.ExitCode)" }
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gexit' -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "GUT failed: $($p.ExitCode)" }
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/performance/top_down_action_rpg_playthrough_probe.gd' -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "Top-down Action-RPG route probe failed: $($p.ExitCode)" }
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --quit-after 180 --fixed-fps 60' -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "180-frame smoke failed: $($p.ExitCode)" }
```

추가 완료 조건:

- GUT orphan/leak/error 0건
- 새 test `SKIP` 0건
- push error, parse error, orphan node, leaked instance 0건
- route probe가 §1.4의 canonical 수치(9 region / 18 edge / 9 gate / 9 cluster / 19 family / 25 encounter / 5 group / 6 variant / 5 NPC-conversion / 6 clock / 7 recovery / 6 ending) 전부의 reachable state를 출력
- `AUTOMATED_RESULTS.md`에 전체 test/assertion count와 exit code가 기록됨
- §1.4의 retired 값 목록이 test oracle·fixture·기록 어디에도 나타나지 않음

## 11. A1 strict no-core-edit 증명 — region + NPC + encounter

Kit 완성의 마지막 content 확장은 `07` §14.1의 A1이다. **새 region 1개 + 새 support NPC 7명 + 새 authored encounter 1개**를 추가하면서 core 파일을 0바이트 바꾸는 data-only 확장을 증명한다. "새 내용이 없다"는 주장이 아니라, 새 authored content가 정확히 무엇인지와 그것이 기존 schema만으로 들어가는지를 함께 증명한다.

sentinel 한 개를 아무 의미 없이 추가하는 것으로 A1을 통과시키지 않는다. **아래 3개 항목은 각각 play evidence가 있어야 하며, 하나라도 없으면 A1 실패다.**

### 11.1 절차

1. baseline 24 encounter(`ENC-ARPG-01`~`24`) / 18 family(`FAM-ARPG-01`~`18`) / 6 clock / 8 baseline cluster / 14 core NPC / 5 group / 6 variant / 5 NPC-conversion / 6 ending이 모두 validation된 상태에서 시작한다. `R8`/`RC-08`/`FAM-ARPG-19`/`ENC-ARPG-25`는 A1 data-only 확장이다.
2. domain, systems, loader/validator algorithm, save codec, input router, presentation controller, combat core, target enum의 pre-add SHA-256 manifest를 `A1_NO_CORE_EDIT_MANIFEST.md`에 기록한다.
3. `modules/top_down_action_rpg/content/` 아래 **아래 package만** 추가한다.
   - region 1개: `region_r8_folding_school` (`region_role: magic_training_craft_labor`, entry/exits 모두 `route_e18_folding_school_approach`, gate `gate_g5`, `internal_routes` 1개)
   - support NPC 7개: `npc_20_mira_vask`, `npc_21_halen_osk`, `npc_22_iven_marrow`, `npc_23_turo_bex`, `npc_24_perri_lowe`, `npc_25_jano_fesk`, `npc_26_cael_orin`
   - encounter 1개: `enc_fold_that_refuses_the_hand` (`ENC-ARPG-25`, field encounter, boss 아님)
   - 함께 오는 data: `FAM-ARPG-19` → `enemy_grading_wall`, `ACT-CGW-GRADE-MARK`/`ACT-CGW-FOLD-VERDICT`/`ACT-CGW-DISPERSE-READING` 3건, magic status 5건, magic `res_*` 10건, `VAR-ARPG-06` → `enc_fold_that_refuses_the_hand_var1`, `NPC-CONV-ARPG-05` → `npc_14_eda_marrow_conversion`, `R8` document 4건, `prop_r8_cut_chamber_failed_fold`, `SERVICE_R8_COURSE_INDEX` service index 1건
4. content validation, route probe, recovery probe를 다시 실행한다.
5. 같은 core file들의 post-add SHA-256를 기록한다.
6. 모든 hash와 file path가 byte-identical이어야 한다 → `changed_core_files == []`.

### 11.2 play evidence (3개 항목 모두)

- **region:** `G5` resolution이 Filing된 뒤 `E18`로 `R8`에 진입하고, `RC-08` conversation/document/commit_log를 실제로 처리하고, `course index return`으로 `R5`에 되돌아온다. `R7-09`의 미완성 cut과 `R8` 잔해가 같은 maker의 증거로 읽힌다.
- **support NPC 7명:** 각각의 `R8` write field port 4종(`course index`/`student status`/`craft credit`, `concentration_field` 측정·배정, `lineage_token`, `contract_tally`+contract 문서)과 absence/filed/remote surface가 실제 플레이에서 확인된다. 7명 중 누구도 cluster participant로 집계되지 않고, `npc_26_cael_orin`과 `npc_11_cael_ren`이 같은 사람으로 취급되지 않는다.
- **encounter 1개:** `enc_fold_that_refuses_the_hand`를 combat으로 resolve하고, noncombat `withdraw and take the labor record`(또는 `R8-05` Filing)로도 resolve한다. `VAR-ARPG-06`의 declared solution 3종(`medium match`, `dispersal action`, `labour-record withdrawal`)을 실제로 실행한다. shape/medium mismatch가 spell rename이 아니라 `record`/`status`/`clock` write로만 표현됨을 확인한다.

### 11.3 추가 확인

- `concentration_field` threshold 초과, failed fold 3등급(`recoverable`/`continuity-changing`/`terminal`), delayed public record, NPC absence를 확인한다.
- `R4` glossary slot이 비어 있으면 craft 이름이 `untranslated term`으로 Filing되고, 학교 이름과 archive 번역이 다르면 두 줄이 남는다.
- `contract_tally`이 자동 해소·tick down·combat cost로 소모되지 않고, `G8`에서 `crown_protocol` 안/밖 위치를 명시하는지 확인한다.
- authored ID/dialogue를 production `.gd`에 추가한 변경 0건.
- `project.godot` diff 0, dependency 추가 0, autoload 추가 0, new shared abstraction 0, `magic` kind/prefix 승격 0.
- `06` §12.3의 예외 2회를 사용했다면 그 사실을 별도 entry로 기록한다. **core hash나 algorithm이 한 줄이라도 바뀌면 A1은 실패다.**

합격 조건:

- 새 authored unit 외 production file 변경 0건
- domain/system/save/input/loader/registry/presentation controller hash 변경 0건
- §11.2의 세 항목 각각에 play evidence 존재
- 기존 모든 content와 새 content가 같은 core로 resolve
- content ID, dialogue, asset path를 production `.gd`에 추가한 변경 0건

## 12. 10분 이상 Reference Game play evidence

자동화는 10분 조건을 증명하지 않는다. 실제 사람이 real input으로 clean start부터 terminal success까지 플레이한다.

### 12.1 유효 시간

- 시작: first playable field frame에서 첫 유효 field intent가 domain에 전달된 시각
- 종료: authored terminal success/ending result가 표시되고 입력 결과를 확인한 시각
- 유효 시간 `>= 600 seconds`
- 다음만 제외한다.
  - Esc menu/pause
  - loading/import/asset compile
  - crash/debugger 수정
  - 사용자 대기와 5초 초과 연속 무입력
  - capture setup와 evidence 정리
- 이동·대화·문서 읽기는 유효 시간에 포함되지만, 이 시간만으로 10분 gate를 통과할 수 없다.
- sleep, 고정 camera, 자동 반복, authored route probe 시간은 유효 시간에서 제외한다.

계산식:

```text
active_seconds = wall_seconds - sum(excluded_intervals)
```

### 12.2 Run R1 — continuous main route

R1은 한 번도 reset/load 없이 clean state에서 시작해 terminal result까지 연속 진행한다.

기록할 항목:

- 실제 시작·종료 시각, wall time, excluded intervals, active seconds
- 방문 region 수와 순서(9 region 중 방문한 것), 통과 edge ID
- 사용 command/action ID와 encounter ID
- 대화·choice·document·aftermath ID
- equipment 변경
- pressure clock이 발동해 바꾼 surface 변화
- failure/death/recovery 발생과 기록된 recovery type
- 첫 meaningful action까지 시간
- 오조작, backtracking, focus loss, 설명 필요 지점
- terminal result(ending ID)와 재방문 가능 surface

R1은 §1.4의 canonical authored content 중 실제 main route가 방문하는 것을 통과해야 하며, long movement/HP inflation/repeated input으로 10분을 채우지 않는다. `RC-08`(`R8`)은 baseline 8개 cluster 경로 밖이므로 R1 필수 항목이 아니고, §12.5의 A1 run으로 분리한다.

### 12.3 Run R2 — alternate route and revisit

R2는 합법적인 clean start 또는 R1의 정상 save checkpoint에서 시작한다.

- R1과 다른 authored route를 선택한다.
- 최소 한 region을 다른 clock/relationship/NPC outcome으로 재방문한다.
- 이전 region의 prop, NPC, dialogue, route, encounter availability 차이를 확인한다.
- direct/alternate route의 entry와 exit state를 event log에 남긴다.
- save를 load한 뒤 같은 run을 이어갈 수 있다.

### 12.4 Play evidence schema

`acceptance_playthrough.json`의 각 run은 다음 field를 가진다.

```text
run_id
build_sha
start_utc
end_utc
wall_seconds
excluded_intervals
active_seconds
input_device
resolution
region_ids
route_edge_ids
cluster_ids
route_ids
encounter_ids
family_ids
command_ids
npc_interactions
document_ids
choice_ids
clock_ids
recovery_events
recovery_type
save_load_events
first_meaningful_action_seconds
misinputs
focus_losses
backtracking_seconds
terminal_result
ending_id
```

`PLAYTHROUGH.md`는 JSON을 요약하되 `active_seconds`, §1.4 canonical content 도달 여부, 두 route 차이, recovery 결과를 생략하지 않는다.

### 12.5 Run A1 — `R8` data-only 증명 (§11과 1:1)

A1 run은 §11.2의 세 항목(진입한 `R8` region, 확인한 support NPC 7명, resolve한 `ENC-ARPG-25` + `VAR-ARPG-06`)에 focused play log를 붙인다. 이 run이 없으면 §11.2는 `FAIL`이다.

## 13. 수동 플레이 과제

플레이어에게 시스템 설명을 주지 않고 과제만 제시한다. 각 run은 성공/실패, 첫 유효 행동, 오조작, backtracking, focus, 설명 필요 여부를 기록한다.

| Task ID | 과제 | PASS 조건 |
|---|---|---|
| `M01` | 새 profile에서 첫 field play와 Input Bubble 완료 | 설명 없이 각 bubble을 실제 physical key로 터뜨리고 field intent를 찾음 |
| `M02` | field에서 passage/object/NPC/service/equipment 상호작용 | world affordance를 통해 각 상호작용을 찾음; 버튼 목록으로 대체되지 않음 |
| `M03` | field encounter를 command→target combat으로 전환 | command와 target을 분리해 선택하고 첫 resolution 결과를 확인. `SELF`/`ONE_ENEMY`/`ALL_*`가 각각 다른 target 문법임을 체감 |
| `M04` | attack/skill/item/defend/equipment command와 target mode 사용 | resource/cooldown/status/result band 변화와 world result가 일치. AP 표시가 없고 `행동 n` text로만 slot이 읽힘 |
| `M05` | authored attack에 Guard, Dodge, Break, non-Break counter 각각 사용 | counter 축을 구분하고 charge cancel 또는 forbidden response를 관찰 |
| `M06` | charge prepare, active hit, break result, punish window 확인 | tell과 결과 feedback이 구분되고 outcome이 domain log와 일치 |
| `M07` | NPC conversation, choice, unavailable choice, irreversible consequence 수행 | focus/choice class를 구분하고 결과가 dialogue뿐 아니라 world/relationship/route에도 나타남 |
| `M08` | 최소/최대 document와 corrupted page 읽기 | page advance, line wrap, 9줄 상한, corruption semantic, return focus가 정상 |
| `M09` | hub service에서 equipment/skill/status behavior 변경 후 combat 재사용 | base와 effective 변화가 combat 결과에 반영되고 base 값이 오염되지 않음 |
| `M10` | authored failure/death를 경험하고 recovery | 원인이 보존되고 recovery 대상, 잃는 state, 다음 선택이 설명 없이 읽힘. `respawn`과 `checkpoint`가 같은 화면이 아님 |
| `M11` | combat/field/dialogue/document state에서 save/load | restored world/focus/result가 같고, presentation-only state가 잘못 복원되지 않음. 전투 중 종료→재실행 시 encounter가 start/phase 경계에서 다시 시작하고 turn이 이어지지 않음 |
| `M12` | direct와 alternate route를 이동하고 이전 region 재방문 | 이전과 다른 NPC/prop/route/clock surface를 확인 |
| `M13` | Esc menu open/close | gameplay input이 lock되고 close 후 이전 module focus로 복귀 |
| `M14` | max data와 긴 문자열 상태 확인 | 세 해상도에서 잘림/겹침/focus 상실이 없음 |
| `M15` | `R8` craft 경로: `E18` 진입, craft action 실행, contract 체결, `G8` 제출 | craft이 MP가 아닌 concentration/medium/tool 결과로 읽히고 실패가 status/clock/record로만 나타나며, `contract_tally`이 자동으로 줄지 않고, craft 이름이 `untranslated term`으로 Filing됨 |

실패한 task는 수정 후 처음부터 다시 실행한다. 수동 task를 생략하거나 “필요하면” 통과로 기록하지 않는다.

## 14. 720p / FHD / QHD capture

### 14.1 캡처 크기

- `1280×720`
- `1920×1080`
- `2560×1440`

각 캡처는 full game frame, native resolution, crop/upscale 없이 저장한다. 파일명은 아래 형식을 따른다.

```text
<state>_<width>x<height>.png
```

### 14.2 필수 state matrix

아래 16개 state를 세 해상도에서 각각 캡처한다. 총 48개 PNG가 필요하다.

| State ID | 캡처할 실제 runtime state |
|---|---|
| `input_bubble` | rising 또는 restoring key와 fixed grid cell이 보이는 전환 |
| `field` | world focal point와 interaction 대상이 보이는 평상시 field |
| `dialogue_choice_focus` | world-preserving dialogue와 choice focus |
| `narration` | world 위에 사건 band가 있는 narration |
| `combat_command` | enemy-centered combat command/action timing/resource band, `행동 n` text, `target_hp_or_condition` |
| `target_select` | target focus와 cancel affordance |
| `charge_counter` | authored charge tell과 counter opportunity |
| `guard_dodge_break_feedback` | counter 결과 또는 break punish state |
| `equipment_no_turn` | equipment/action-slot/no-turn state |
| `document_max` | 9줄 최대 authored page와 next affordance |
| `document_corrupted` | authored corruption state |
| `aftermath_revisit` | event aftermath 또는 재방문 차이 |
| `failure_death` | failure/death input 전 또는 death transition |
| `recovery` | recovery state가 투영된 같은 world와 복귀 대상 |
| `success` | authored success/result state |
| `esc_menu` | Esc 호출 menu와 underlying world focus boundary |

### 14.3 Capture 실행

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'
$CaptureDir = Join-Path $env:TEMP ('tdargp_acceptance_' + [DateTime]::UtcNow.ToString('yyyyMMdd_HHmmss'))
$p = Start-Process -FilePath $GodotExe -ArgumentList '--path C:\projects\TINProject --script res://tests/performance/top_down_action_rpg_visual_capture.gd -- --output-dir "' + $CaptureDir + '"' -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "Visual capture failed: $($p.ExitCode)" }
```

캡처 후 acceptance evidence 디렉터리로 복사한다. source PNG를 resize/crop하지 않는다. `RESOLUTION_MANIFEST.md`에 state, resolution, actual pixel width/height, SHA-256, source/reference mapping을 기록한다.

### 14.4 해상도별 manual checklist

각 state/해상도에서 아래를 `PASS`로 기록한다.

- viewport 밖 UI 0건
- UI overlap/clipping 0건
- focus 표시가 2개 이상의 non-color channel에서 읽힘
- world play area와 enemy/NPC/document focal point가 유지됨
- combat command와 bottom band가 enemy를 가리지 않음
- combat bar가 green timing + `target_hp_or_condition` 2개뿐이고 AP label/red bar 0건
- 16:9 여백에서 dialogue/document line wrap이 정상이고 9줄 page가 잘리지 않음
- field에서 Shell/Menu/Journal/debug/constant HUD 0건
- placeholder world 0건
- unsupported resolution scale distortion 0건
- 이전 화면으로 돌아갔을 때 focus/world state 복귀

## 15. Primary Reference 비교

Primary Reference는 **BLACK SOULS 2 하나**다. 다른 게임을 보조 레퍼런스로 추가하지 않는다.

| Reference evidence | 비교 대상 | 비교할 요소 |
|---|---|---|
| A | dialogue choice capture | world 유지, portrait/speaker/text, 우측 choice, focus와 presentation class 분리 |
| B | combat command capture | enemy-centered focal point, 좌측 command, timing bar, combat-local resource/status band, 별도 bar의 `target_hp_or_condition` 보존 |
| C | world narration | world 위에 사건 band, field 위치 관계 유지 |
| D~F | document pages | dark reading layer, page 정보량, next affordance |
| G | corrupted page | authored corruption, accessibility, deterministic text |
| H | aftermath | world prop/NPC/trace와 narration band, 재방문 state |

- 각 reference row에 TIN capture ID와 차이를 기록한다.
- A~H에 없는 target focus, death/recovery, ending 화면을 원작의 직접 관찰처럼 쓰지 않는다. `09`에 실제 추가 reference evidence가 있으면 그 source와 timestamp를 기록한다.
- 직접 source가 없는 row는 구현이 임의 해석했더라도 `PASS`로 바꾸지 않는다. 필요한 실제 source가 없으면 해당 comparison은 blocked이고 Kit complete가 아니다.
- TIN capture는 원작 frame, font, portrait, icon, sprite, map layout, 문구를 복제하지 않는다.

## 16. Placeholder / HUD / Retired Prototype audit

### 16.1 Static source scans

아래 scan은 `modules/top_down_action_rpg/`의 `.gd`, `.tscn`, `.tres`, `.json`, asset manifest를 대상으로 한다. 모든 forbidden pattern의 hit 수는 0이어야 한다.

```powershell
$Root = 'C:\projects\TINProject\modules\top_down_action_rpg'
rg -n -i --glob '*.gd' --glob '*.tscn' --glob '*.tres' --glob '*.json' 'placeholder|todo|fixme|mock|dummy|debug[_ ]?(label|overlay|hud)|alice|앨리스|가짜 바다거북|그리피|at-icons|res://addons/at-icons' $Root
rg -n -P --glob '*.gd' --glob '*.tscn' --glob '*.tres' 'res://modules/(?!top_down_action_rpg(?:/|$))' $Root
rg -n -P --glob '*.gd' --glob '*.tscn' --glob '*.tres' 'res://app/|res://meta/|res://core/services/|/root|EventBus|ServiceLocator|GameManager|InputManager|res://addons/godot-jrpg' $Root
rg -n -P --glob '*.gd' 'Input\.(is_action|is_action_pressed|is_action_just_pressed|is_action_just_released|get_axis|get_vector)' $Root
rg -n -i --glob '*.gd' --glob '*.tscn' --glob '*.tres' --glob '*.json' '\b(max_ap|action_points|created_content_revision|checkpoint_return|clone_branch|loop_rehearsal|immortal_continuation)\b' $Root
rg -n -P --glob '*.gd' --glob '*.tscn' --glob '*.tres' --glob '*.json' 'FAM-ARPG-|ENC-ARPG-|GRP-ARPG-|VAR-ARPG-|NPC-CONV-ARPG-|CL-INST|CL-CONT|CL-REC|CL-RES|CL-PER|CL-CROWN|HC-00|RC-0[1-8]|R-RETURN|R-CROWN|R-ARCHIVE|R-LATENCY|R-LEXICON|R-VISCERA|R-SERVICE|R-COMMON|R-SEAM|gate_g9|PLAYER_BRIDGE_0' $Root
```

마지막 두 scan은 `06` §3.5의 **plan-level ID re-key 누출**과 `AP`/retired root/recovery 표기 누출을 잡는다. `rg`의 no-match exit code `1`은 성공으로 기록한다. exit code `2` 이상은 scan 실행 실패다.

추가 GUT 검사:

- world layer의 interactive visible authored object가 `ColorRect` 또는 `Label` 0건
- missing `presentation_asset_id` 0건
- missing approved/provenance asset 0건
- field Shell/HUD visible node 0건
- release/test presentation에 debug label 0건
- source `.gd`에 authored ID/dialogue literal 0건
- foreign module/app/meta/core-service import 0건
- `/root`, service locator, 범용 EventBus 0건
- direct global Input polling 0건
- `content/magic/` 디렉터리와 `magic_` prefix ID 0건, `index.json.kinds[]`의 `magic` 0건
- `02` ladder 값이 `TopDownWorldLadder`에 하드코딩되지 않음

### 16.2 Retired Prototype provenance audit

- 새 module의 모든 source/data/asset에 origin을 기록한다.
- 허용 origin은 `original TIN code`, `audited exact-file reuse`, `approved GPT image candidate`뿐이다.
- Retired Prototype의 idea/dialogue/UI/asset/scene을 import하거나 복사하지 않는다.
- `modules/top_down_action_rpg/` 아래 file SHA-256이 Retired Prototype file SHA-256과 같은 경우 provenance를 재감사하지 않고 `FAIL`한다.
- 기존 Retired Prototype이 repository에 남아 있는 것은 이 Kit의 직접 dependency가 아니어야 한다. 남은 prototype 자체의 삭제는 별도 작업이다.
- godot-jrpg 전체 framework, autoload, EventBus, scene-swap, Resource-save는 사용하지 않는다.

### 16.3 Asset/provenance audit

- 모든 production image는 `docs/art/projects/<project_id>/` project art layer와 asset brief를 가진다.
- brief는 실제 game state, size/format/alpha/pivot/layer, focal priority, source, license/provenance를 기록한다.
- GPT candidate가 자동으로 Gold Standard가 되지 않는다.
- 실제 화면에 들어간 candidate는 hard gate와 사용자의 명시적 화면 승인 기록을 가진다.
- at-icons 조립은 현재 기준이 아니다.
- 출처·라이선스가 없는 asset은 acceptance를 통과할 수 없다.

## 17. Placeholder와 HUD의 수동 확인

자동 scan과 별도로 실제 각 state를 플레이해 다음을 확인한다.

- 월드 오브젝트가 사각형/문자로 대체되지 않음
- debug text가 release 화면에 없음
- field에 combat band가 없음
- Shell은 Esc 전 visual presence 0
- 우측 상단 Menu/Journal button 없음
- 좌측 상단 location/autosave/key cluster 없음
- 중앙 장문 설명으로 command/choice를 대신하지 않음
- focus 없는 선택 목록 없음
- combat에 AP label/gauge가 없고 bar가 2개뿐임
- axis·clock·cluster 수·`concentration_field`가 상시 노출되지 않음
- world/character/document/UI의 information hierarchy가 유지됨
- asset의 최종 game-screen 가독성이 개별 asset beauty보다 우선됨

## 18. 금지 shortcut

다음 중 하나라도 사용하면 완료 불가다.

1. 한 boss, 한 map, 한 encounter만으로 Reference Game 완료 선언
2. GUT 통과만으로 완료 선언
3. scripted route의 실행 시간을 사람 플레이타임으로 표기
4. sleep, 긴 이동, idle, 반복 입력, HP inflation, dialogue volume으로 10분 충족
5. authored content floor를 우회하는 debug skip 또는 test-only route
6. content ID별 `if`/`match`, dialogue giant script, core registry의 content-name 분기
7. 새 content마다 parser/evaluator/scheduler/save/input/registry/presentation controller 수정
8. Resource/Node/Callable/Vector 자체를 save payload에 저장
9. stale ID를 빈 값, generic object, 임의 첫 NPC로 조용히 대체
10. Guard, Dodge, Break를 하나의 success/fail boolean으로 합침
11. 모든 encounter를 Break로 해결
12. scheduler를 frame delta, global RNG, Dictionary 순서에 의존
13. charge와 break를 hard-coded pair로 강제
14. NPC-boss를 별도 identity의 새 enemy로 복제
15. dialogue-only NPC, aftermath dialogue-only flag, secret single flag
16. source seed 이름만 바꾸는 generic content
17. planned seed를 used로 세거나 line count를 quota denominator로 사용
18. source surface를 제거하면 구분되지 않는 tone/weirdness seed
19. random typo/uncaptured glitch를 document corruption으로 사용
20. Label/ColorRect/ASCII placeholder를 authored world 완료로 처리
21. 상시 HUD, key instruction overlay, debug label, top-right Menu/Journal button
22. presentation node가 domain truth를 소유하거나 scheduler/route를 계산
23. `/root`, global InputMap polling, service locator, generic EventBus, 승인 없는 autoload
24. 다른 module, Retired Prototype, app/meta 구현의 직접 참조
25. godot-jrpg 또는 무audit 외부 framework import
26. BLACK SOULS 2 고유 character, dialogue, asset, map, UI skin, number 복제
27. 앨리스 요소 또는 원작 고유 skin 재사용
28. at-icons를 현재 제작 기준으로 사용
29. 1280×720만 검증하고 FHD/QHD를 생략
30. placeholder, crop, upscale, mock image를 실제 runtime capture로 제출
31. 추가 reference evidence가 없는 화면을 직접 관찰한 것처럼 기록
32. asset provenance/Gold Standard 승인 없이 placeholder를 ship
33. 사용자가 직접 플레이하기 전에 `최종 완성` 선언
34. §1.4의 retired 값(8 region / 17 edge / 24 encounter / 15 family / 12 group / 6 recovery / 4 clock floor / gate 72 / preferred 90 / `created_content_revision` / `checkpoint_return`·`clone_branch`·`loop_rehearsal`·`immortal_continuation`)을 사용
35. `R8`을 추가하지 않거나 region+NPC+encounter 중 하나라도 play evidence 없이 A1을 통과로 선언
36. `crown_alignment`를 recovery type·recovery screen·recovery flow로 실행
37. combat mid-state(`turn_index`/`scheduler_cursor`/charge stage/reaction window/RNG position)를 저장해 전투 resume을 허용
38. AP resource/label/gauge를 combat band나 save에 추가
39. `record`/`route`/`resource_node`를 target mode로 사용하거나 HP bar로 공격
40. magic을 5번째 축 / 7번째 clock / 8번째 recovery type으로 확장
41. `R8` 진입에 `G9` gate를 새로 만들거나 `E18`을 `R2`/`R4` gate처럼 취급

## 19. 완료 체크리스트

### 19.1 계획과 구현

- [ ] `01`~`09` + `12` 계획 문서가 존재하며 구현-affecting 결정이 빈칸/선택지로 남아 있지 않음
- [ ] `modules/top_down_action_rpg/`가 구현되었고 manifest/entry scene이 Godot 4.7.2에서 parse됨
- [ ] `01`에 scheduler total tie-break와 `turn_cost 0..5` / no-turn semantics가 명시되어 있음
- [ ] `02`에 region 9 / edge 18 / gate 9 / cluster 9 / clock 6 / axis 4(`-3..3`) / route state 6 / resource 53 / seed 160-96-120이 명시되어 있음
- [ ] `04`에 core 14 + support resident 7(`npc_20`~`npc_26`)가 명시되어 있음
- [ ] `05`에 family 19 / encounter 25(11+14) / group 5 / variant 6 / NPC-conversion 5 / target mode 6 / encounter role 5가 명시되어 있음
- [ ] `06`에 kind 18 / `STATE_TOKEN` 27 / `floor_role` 6+2 / document 9줄 / JSON catalog 소유가 명시되어 있음
- [ ] `08`에 root 12 key / section 8 / recovery 7 / `crown_alignment` world write / mid-state resume 금지 / stale-ID 표가 명시되어 있음
- [ ] `09`에 16개 state의 실제 capture fixture와 focus/visibility contract가 명시되어 있음
- [ ] `12`에 craft 3종 / action schema / failure 3등급이 명시되어 있음

### 19.2 자동

- [ ] Section 3~9의 모든 test ID가 존재하고 individually 및 전체 GUT에서 통과
- [ ] import exit 0
- [ ] integration runner exit 0
- [ ] GUT exit 0, failure/error/orphan/skip 0
- [ ] route probe exit 0
- [ ] 180-frame smoke exit 0
- [ ] scheduler 10,000-tick determinism과 insertion-order invariance 통과
- [ ] `turn_cost`가 정수 `0..5`만 통과하고 3단계 semantics가 구분됨
- [ ] 6 target mode / 5 encounter role / 3 combat resource / AP 0건 통과
- [ ] JSON-safe, migration, transactional failure, stale ID, 7 recovery 통과
- [ ] UI state/focus/cancel/return/three-resolution layout 통과
- [ ] lifecycle/context/input/cleanup/isolation 통과

### 19.3 World / NPC / content / seed

- [ ] region 9 / edge 18 / gate 9 / `region_role` 9 / route state closed 통과
- [ ] cluster 9개가 각각 core NPC 6~12, institutions 2~4, clocks 2~3
- [ ] core NPC 14 + support resident 7, `npc_15`~`npc_19` 0건
- [ ] family 19 / encounter 25(field 11 + boss 14) / group 5 / variant 6 / NPC-conversion 5 통과
- [ ] pressure clock 6개가 6칸 stage를 가지며 모두 작동하고, 4-clock floor가 아님
- [ ] equipment `floor_role` 6개와 item `floor_role` 2개 존재
- [ ] `res_*` 53개가 closed, 비수량 debt key 2개가 `amount` 없음
- [ ] document 9줄 cap과 720p font floor 통과
- [ ] ending 6개와 `RC-08` orphan ending path 0건
- [ ] distinct `PLANNED_RETAINED` transform `>=96/160`, preferred 120 기록
- [ ] used seed 전수 anti-generic review 통과 (승격 evidence 별도)
- [ ] cross-link 2개와 immediate/delayed consequence 누락 0건
- [ ] magic seed 40개가 4개 gate 통과
- [ ] production code authored ID/dialogue hardcode 0건

### 19.4 Save/recovery

- [ ] root 12 key / section 8 / `STATE_TOKEN` 27 통과
- [ ] payload float이 `field.actor.x`/`y` 2개뿐이고 `ap` field 0건
- [ ] field/combat/dialogue/document/aftermath snapshot 정책 통과
- [ ] 모든 supported migration 통과
- [ ] future/malformed/stale save가 transactionally 처리됨
- [ ] combat mid-state resume 0건, pre-command intent 재검증 통과
- [ ] death, 7개 recovery 전부, `crown_alignment` world write가 identity table과 일치
- [ ] old recovery 표기와 8번째 type이 reject됨
- [ ] repeated/deferred recovery callback 0건
- [ ] reset와 failed restore가 unrelated state와 `world.magic`를 보존

### 19.5 실제 플레이와 화면

- [ ] R1 active play time `>=600 seconds`
- [ ] R1 clean start→terminal success evidence
- [ ] R2 alternate route와 changed revisit evidence
- [ ] M01~M15 전부 `PASS`
- [ ] 1280×720/FHD/QHD 각각 16개 runtime PNG
- [ ] 48개 PNG actual dimensions와 SHA-256 기록
- [ ] 각 해상도에서 overlap/clipping/focus/world/placeholder/HUD 검사 통과
- [ ] A~H Primary Reference comparison 기록
- [ ] missing reference 상태를 fabricated comparison으로 메우지 않음

### 19.6 A1 / magic

- [ ] pre/post core SHA-256 manifest와 `changed_core_files == []`
- [ ] A1 content-only diff
- [ ] `R8` region play log (`E18` 왕복 + `RC-08` + course index return)
- [ ] `npc_20_*`~`npc_26_*` 7명 각각의 write field port / absence / filed-remote surface log
- [ ] `ENC-ARPG-25` combat + noncombat log와 `VAR-ARPG-06` declared solution 3종 실행 log
- [ ] magic action 14 key / craft_family 3 / concentration_source 3 / mana_profile 8 / magic status 5 통과
- [ ] magic failure가 status+clock+record를 한 transaction으로 쓰고 2개 clock 동시 전진 0건
- [ ] `contract_tally` 자동 해소 0건, glossary `untranslated term` 유지
- [ ] `project.godot` diff 0, autoload 0, dependency 0, `magic` kind 승격 0

### 19.7 Audit와 provenance

- [ ] placeholder/TODO/debug/source-copy static scan 0건
- [ ] retired 값/retired ID/AP static scan 0건
- [ ] world Label/ColorRect placeholder 0건
- [ ] constant Shell/HUD 0건
- [ ] Retired Prototype dependency/hash collision 0건
- [ ] foreign module import, `/root`, global Input, EventBus/autoload 0건
- [ ] 외부 framework/dependency 0건
- [ ] 모든 production asset의 brief, source, license/provenance 기록
- [ ] 실제 game-screen asset user approval 기록

## 20. 최종 상태 선언

위 checklist가 전부 `PASS`인 시점의 선언은 다음 한 문장으로 제한한다.

> **Top-down Action-RPG Kit: 검토 준비 완료 — 자동·수동·캡처·audit 증거를 확인했다. 사용자 직접 플레이 검토를 기다린다.**

사용자가 Reference Game을 직접 플레이하고 시스템·입력·화면 구조에 대한 피드백을 승인한 뒤에만 최종 완성 여부를 결정한다. 피드백이 계획 계약을 바꾸면 해당 계획 문서와 이 acceptance 문서를 먼저 갱신한다.
