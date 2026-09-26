# Top-down Action-RPG — module-local vertical slice

This directory holds the first module-local vertical slice of Kit 04.
Nothing here is wired to `AppRoot`, `module.gd`, `entry.tscn` or
`module_manifest.tres`; those are owned by a different work item.

## Files

```text
domain/game_state.gd        TopDownActionRpgGameState
domain/combat_state.gd      TopDownActionRpgCombatState
systems/content_loader.gd   TopDownActionRpgContentLoader
systems/action_scheduler.gd TopDownActionRpgActionScheduler
systems/combat_controller.gd   TopDownActionRpgCombatController
systems/field_controller.gd    TopDownActionRpgFieldController
systems/conversation_controller.gd TopDownActionRpgConversationController
systems/recovery_controller.gd    TopDownActionRpgRecoveryController
content/index.json + 18 kind directories
```

Every class name is prefixed `TopDownActionRpg` so nothing collides with
`DeductionCasework*` or `RuleRewriting*`.

## Ownership boundaries

- No autoload, no `/root` lookup, no service locator, no generic event bus.
- No `core` reference, no other-module reference, no `presentation` Node reference.
- Production logic contains no authored content ID. The only closed vocabularies
  hardcoded in `systems/content_loader.gd` are grammar/vocabulary sets:
  the 18 kind names and their prefixes, the 6 target modes, the 3 encounter
  target roles, the 7 recovery kinds, the 4 world axes, the 6 canonical clock
  IDs and their `02` stage ladders, the 9 region roles, the 53 `res_*` field
  resource keys, the 3 combat resource keys, the 8 `mana_profile` values, and
  the presentation-class / irreversibility / stance / break-policy enums.
  The entry region is validated by its `region_role` being the hub role, not by
  its ID.

## Data flow

```text
content_loader.load_default()  -> CatalogResult { catalog, diagnostics, outcome }
TopDownActionRpgGameState.create_default(entry_region, anchor)
field_controller.setup(state, catalog)        # region/route/focus/interact/cluster
conversation_controller.setup(state, catalog) # conversation / choice / document pages
combat_state.create_encounter(id, attempt, seed) + combat_controller.setup(...)
action_scheduler                              # schedule_rate / action_slots / turn_cost
recovery_controller                           # 7 recovery kinds + crown alignment world write
```

`mode` is authoritative state and is persisted in `combat.resume_boundary`
(`01` §3.2 modes, `08` §4.2 root), so `TopDownActionRpgGameState.from_dict()`
re-derives it without widening the closed save root.

## Determinism

- Scheduler clock is an integer tick. No frame index, no wall clock, no
  `randf()`.
- Encounter RNG is a stored xorshift32 seed. `TopDownActionRpgGameState.stable_seed(encounter_id, attempt_serial)`
  derives it, so the same encounter + attempt + command sequence reproduces the
  same run.
- Queue order is `ready_tick` -> authored `tie_break_rank` -> actor ID ->
  `command_index` -> `intent_id`, and `intent_id` is built from encounter ID,
  actor ID, window serial and command index.
- `RANDOM_ENEMY` is resolved at resolution time from the encounter RNG stream.

## Combat contract implemented

- 6 target modes only (`SELF`, `ONE_ENEMY`, `ONE_ALLY`, `ALL_ENEMIES`,
  `ALL_ALLIES`, `RANDOM_ENEMY`). `record` / `route` / `resource_node` are
  encounter-level target roles, kept in a separate vocabulary and never usable
  as an action target mode.
- `turn_cost` integer `0..5`. `0` resolves immediately in the same command
  window and consumes no action slot and no scheduler delay; `1` is a normal
  command; `2..5` lock the window with one slot.
- `action_slots` are snapshotted when the window opens and are not refunded.
- `schedule_rate = max(MIN_RATE, effective_agility)`; delay is
  `ceil(BASE_SCHEDULE_TICKS * turn_cost / schedule_rate)`.
- Guard (`guard_window_budget = 2`), Dodge (per-hit deterministic roll, clamped
  chance), Break (deterministic `break_power` vs `break_resistance`,
  `broken_skip_budget = 2`, cancels a charge when the policy allows).
- Charge is a lifecycle with the stage order `telegraph -> reaction -> strike ->
  recovery` plus `cancelled` / `completed`, a mandatory reaction window, and
  `Receive` as a non-reaction.
- Late invalidation returns the `skipped_*` result codes without consuming
  resources; the scheduler delay is never refunded.
- Authored `cooldown_windows` are tracked in actor schedule windows.

## Recovery contract implemented

Exactly 7 kinds, and `crown_alignment` is not one of them:

```text
checkpoint  respawn  clone  reincarnation  loop  immortality  institutional_reentry
```

`TopDownActionRpgRecoveryController.apply_crown_alignment()` writes only
`world.crown`, the `continuity_pressure` axis and the `clock_crown_alignment`
irreversible stage, and refuses a second alignment. Requesting a recovery whose
`kind` is `crown_alignment` returns `recovery_kind_violation`.

## Catalog state

`content/index.json` loads as `ready_with_defects` with **zero errors**.
Remaining diagnostics are all catalog-completeness floors that are out of scope
for this slice and are reported explicitly as `catalog_floor_deferred` warnings:
9-region completeness, 9-cluster completeness, encounter/enemy family counts,
the 5 magic statuses, the 6 equipment floor roles, 160-seed denominator
completeness, the 14-name core roster, and magic resource flow coverage.

`remix_always_on` and `equipment_floor_role_missing` are warnings, not errors,
for the same reason.

## Authored content in this slice

- Regions: `region_h0_undersign_exchange` (hub), `region_r1_returning_kiln`,
  `region_r8_folding_school` (magic training/craft/labor, with the
  concentration block).
- Routes: `route_e01_ash_stair` (H0<->R1) and
  `route_e02_folding_school_dispatch` (R1<->R8), with
  `gate_g0_arrival_declaration` and `gate_g1_ash_debt`.
- Clocks: all 6 canonical clock definitions with the `02` six-stage ladders.
- NPCs: `npc_01_ilyra_senn`, `npc_05_nera_voss`, `npc_11_cael_ren` (core) and
  `npc_20_mira_vask` (support), with 4 distinct `mana_profile` values and one
  system port each.
- Enemies: `enemy_ash_hound`, `enemy_ember_clerk`, `enemy_fold_wall`.
- Encounters: `enc_r1_ash_choir`, `enc_r1_door_role_test`,
  `enc_r8_fold_that_refuses_the_hand`.
- Actions: `act_ash_sweep` (attack), `act_weave_lash` (concentration-mediated
  weave craft with a single clock write and `st_concentration_load` failure),
  `act_file_return_form` (no-turn), `act_guard_set`, `act_dodge_shift`,
  `act_break_poise`, plus 6 enemy actions including a charge and a committed
  turn-cost-3 action.
- Documents: `doc_r1_wrong_return_log` with authored, non-random corruption.
- Equipment: `equipment_ash_bound_stick`, `equipment_kiln_ledger_seal`.
- Items: `item_ash_thread_spool`, `item_blank_return_form`.
- Recovery: `rec_r1_kiln_reentry` (institutional re-entry),
  `rec_r8_course_repeat` (checkpoint).
- Seeds: `seed_ledger` plus one `planned_retained` seed record with two
  cross-links, an immediate consequence and a delayed consequence.

All text is original TIN content. No source-game names, quotes or characters.

## Not done in this slice

- No `presentation/` Node work, no combat or field view, no input mapping.
- No enemy AI policy beyond "authored action list by side"; `ai_policy_id` is
  stored but no policy content ships yet.
- No Reference Game run. Nothing here has been played for 10 minutes, and the
  8-cluster baseline path does not exist yet.
- Catalog completeness floors listed above are not enforced.
- No GUT tests. `tests/` is owned by another work item.
