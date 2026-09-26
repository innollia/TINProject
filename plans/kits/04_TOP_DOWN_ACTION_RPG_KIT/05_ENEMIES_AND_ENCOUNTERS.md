# 05 — Enemies and Encounters

## 환경 레이어와 전투 자산 — 2026-09-26

[13](13_LAYERED_ENVIRONMENT_PRODUCTION.md)의 큰 field 배경은 적 스프라이트나 전투 화면 그 자체가 아니다. field encounter trigger는 gameplay data에 남고, 전투 적/telegraph/phase/break 이미지는 별도 카메라 계약을 유지한다. 적을 배경에 구워 defeat 이후에도 남기지 않는다.

field 복귀 시 same-area clean base와 이미 해석된 aftermath layer를 사용한다. 파손·잔류물·사체·장치 개방이 이 문서에 정의된 경우에만 대응 이미지를 제작하며 새 encounter 의미를 미술에서 발명하지 않는다. NPC 전투 전환은 같은 stable identity의 자산 상태로 연결한다.

Status: authored-content plan for the Top-down Action-RPG Kit.  
Primary Reference: **BLACK SOULS 2 하나**.  
Scope: original TIN enemy families and encounters for the world described in `WORLD_CONSTITUTION.md`.

## 0. Scope and non-negotiable constraints

This file defines 19 original enemy families and 25 authored encounters: 11 field encounters and 14 bosses. Every family is used by at least one encounter. The records are data contracts for the module-local content layer, not a second combat system.

The magic/concentration layer is part of that same content layer, not a second one. `FAM-ARPG-19` and `ENC-ARPG-25` are authored over the existing action, status, phase, group, variant, and encounter schemas; they introduce no new combat system, no fifth axis, no seventh pressure clock, and no eighth recovery type. Section 2.8 is the closed authoring rule set for that layer.

- Enemy names, silhouettes, action concepts, rewards, and consequences below are TIN-original. No imported character, enemy, location, dialogue, icon, effect, or level arrangement is used.
- BLACK SOULS 2 supplies the system and content grammar: command-first combat, positionless target selection, scheduler pressure, status payloads, charge/break exceptions, dense rosters, phase changes, summons, and world aftermath. Exact unobserved timing, gauge values, and source-specific details are not claimed as reference facts.
- Combat targets are selected by authored target mode and priority. There is no implicit adjacency, facing, distance, or positional weakness rule.
- Every attack has a baseline rule, a signature rule, a readable telegraph, valid counters, invalid counters, a break policy, and explicit hit/miss/break reactions.
- Break is an authored counter axis, never a universal answer. Unbreakable, link-break, phase-lock, resource-lock, route, escape, status, and noncombat counters are first-class outcomes.
- A boss phase is data that overrides actions, roster, resistances, arena rules, or completion conditions. Adding a phase must not require a new combat algorithm.
- A linked actor has an owner, true target, count, lifetime, and death/escape rule. A linked actor can be the correct target without being the encounter's apparent main body.
- Every encounter has victory, escape, failure, and noncombat/alternate outcomes. Failure preserves player knowledge but may advance a world clock and uses the encounter's authored checkpoint scope.
- Every authored enemy has a local institutional or resource role, a visible conflict, a signature rule, a cost, and at least one changed world surface after resolution.
- No field HUD is added by this file. Enemy action timing, status, target, and resource state may appear only in the combat-local presentation required by the Primary Reference.

## 1. Stable IDs and data contract

All records use stable, versioned, JSON-safe values. A content addition may add records and referenced actions; it may not add a new core branch for a family name, encounter name, or story flag.

### 1.1 ID rules

- Family ID: `FAM-ARPG-01` through `FAM-ARPG-19`.
- Action ID: `ACT-<FAMILY-CODE>-<BASELINE|SIGNATURE|COUNTER>`. The code is the family's own short code and is not globally unique by design (`FAM-ARPG-05` and `FAM-ARPG-17` both use `SB`); disambiguation is the catalog re-key `act_<family>_<basic|signature|counter>` in `06` §3.5.4, which is unique because the family slug is. A new family uses a code that does not already appear in this file; `CGW` is the Grading Wall code.
- Encounter ID: `ENC-ARPG-01` through `ENC-ARPG-25`. `ENC-ARPG-01`-`10` are the field encounters and `ENC-ARPG-11`-`24` are the bosses; `ENC-ARPG-25` is the eleventh field encounter and the `R8` data-only addition.
- Group ID: `GRP-ARPG-01` through `GRP-ARPG-05`. The group set is closed at the five templates in section 6.1; a sixth group is not planned in this Kit revision. The magic layer adds no group: `ENC-ARPG-25` composes a roster from existing families instead.
- Variant ID: `VAR-ARPG-01` onward.
- NPC conversion ID: `NPC-CONV-ARPG-01` onward.
- Status ID: the stable names in section 2.2.
- Clock ID: the stable names in section 2.4.
- Seed IDs remain the `S001`-`S160` IDs in `IDEA_LEDGER.md`: core `S001`-`S120` and magic supplement `S121`-`S160`. Both ranges are written separately in section 7 and never merged into one list.
- Region ID: the canonical nodes of `02` §1, `H0` plus `R1`-`R8`, in `06` §3.5.1's catalog form (`region_h0_undersign_exchange`, `region_r1_returning_kiln`, ... `region_r8_folding_school`).
- NPC ID: the canonical core roster of `04` §2, `npc_01_ilyra_senn` through `npc_14_eda_marrow`, plus the `R8` support residents `npc_20_mira_vask`-`npc_26_cael_orin`. No other `npc_*` exists.

### 1.2 Required record fields

The following fields are required on every family, action, encounter, variant, and NPC conversion record. A blank field is a validation failure; `none` is an explicit authored value.

| Field | Required meaning |
|---|---|
| `id`, `version` | Stable content identity and authored schema version. |
| `seed_ids` | One or more idea-ledger IDs whose planned structural change is recorded in section 7. A seed is `PLANNED_RETAINED` here, never `used`. |
| `region_role` | The local institution, resource flow, route, or social conflict that gives the actor a reason to exist. Resolved against the region contract in section 2.6. |
| `silhouette_body_class` | Readable body/anchor/size/motion class used by field and combat presentation. |
| `baseline_action` | The repeatable ordinary action and its cost, target mode, and payload. |
| `signature_action` | The family-specific action that makes the actor worth planning against. |
| `telegraph` | Visual, body-motion, sound, resource, document, or position-independent signal before commitment. |
| `valid_counters` | Actions or conditions that cancel, redirect, mitigate, or create a punish window. |
| `invalid_counters` | Actions that do not solve the threat and may reinforce it. |
| `break_policy` | `marked`, `accumulator`, `link`, `resource`, `phase_locked`, `unbreakable`, or `false_break`. |
| `statuses` | Named status payloads, duration/stack rules, resistance, and cure category. |
| `phases` | Trigger, entry override, action/roster/resistance change, completion, and next phase. |
| `summons_linked_actors` | Owner, count, max count, timing, role, true target, lifetime, death, escape, and cleanup. |
| `resource_reward_effect` | Player resource cost, reward, debt, access change, and clock/resource consequence. |
| `aftermath` | At least two changed surfaces: NPC, body, region, route, record, relationship, resource, or clock. |
| `clock_links` | Immediate and delayed effects on the relevant pressure clocks. |
| `encounter_outcomes` | Victory, escape, failure, and noncombat/alternate branches with state changes. |

### 1.3 Action resolution order

This file defines no resolution order of its own. `01_SYSTEM_UX.md` section 9 owns it, and every baseline, signature, and counter action in sections 3, 4, and 5 is authored against that order without exception. Restated as the contract these records are held to:

1. Re-validate target, actor, action, resource, and phase at resolution time on a working copy of the current combat state.
2. A failed validation becomes a named `skipped` result and the working copy is discarded. No partial HP, resource, status, or world effect survives.
3. Consume the action cost and the queue-time reservation inside the working copy.
4. Resolve reaction/counter first. A reaction that cancels the attack skips the hit pipeline.
5. Apply commitment, hit policy, ordinary evasion/Dodge, critical, resistance/immunity lookup, Guard mitigation, and damage in that order.
6. Apply status payloads to a living target only. Damage that kills the target applies no status payload and no on-hit effect; lifesteal/reflect may still resolve.
7. Reflect death removal, phase transition, summon, linked-actor lifecycle, and encounter outcome.
8. Replace the authoritative state only when every hook succeeded, and emit presentation events and module requests only after the commit.
9. On any content or runtime error, roll back to the pre-action state.

The hook order inside one transaction is 01 section 9.3's fixed seventeen steps, and late invalidation of an already-queued action is 01 section 9.4. A telegraph, commitment window, or punish window in this file is a visible slice of those steps, never a second ordering. A reaction and its strike are one outer transaction, so a rolled-back strike also rolls back the reaction cost and state.

A `turn_cost=0` action is the only no-turn action. Per 01 section 8.7 it resolves immediately at selection, ahead of any normal action already queued in the same command window, and every already-queued normal action is re-validated afterwards. A generic player action cannot become no-turn merely because an enemy is present.

### 1.4 Target mode, encounter target role, and cost vocabulary

`01_SYSTEM_UX.md` section 7.1 owns the closed target-mode enum. Only these six values appear in any action record in this file:

`SELF` `ONE_ENEMY` `ONE_ALLY` `ALL_ENEMIES` `ALL_ALLIES` `RANDOM_ENEMY`

`self`, `single_enemy`, `all_enemies`, `random_enemy`, `linked_actor`, `record`, `route`, and `resource_node` are not target modes and may not appear in a `target_mode` field. A target mode never reads physical adjacency, distance, facing, or grid position.

#### Encounter target roles

A target mode addresses an actor. The four non-body things a combat action can also act on are encounter-level target roles, and this is the closed role set:

| Encounter target role | What it addresses |
|---|---|
| `actor` | A rostered living actor. The default role when a priority entry names a body. |
| `linked_actor` | A linked actor with an authored owner, count, lifetime, and death/escape rule. A `linked_actor` entry may be the encounter's true target while never being the apparent main body. |
| `record` | An encounter-level record, claim, writ, contract, name record, source term, gate record, or ledger node. It has no body and no HP. |
| `route` | An authored exit, crossing, or route edge that the encounter closes, opens, or writes. |
| `resource_node` | A named consumable pool, cache, water line, ration route, or supply anchor that the encounter consumes, denies, or verifies. |

Roles are written as `role:entry` inside a `target_priority` list so a record is never mistaken for a body, and an untagged entry is an `actor`. A `record`, `route`, or `resource_node` entry can be the encounter's true target and can be the correct counter target, but it is resolved by a permit, proof, resource, or route action and never by a damage roll against a body. `true_target` in section 2.3 names a role plus an entry, never a target mode.

An action that acts on an encounter role keeps one of the six target modes for its actor and names the role in `status_hooks`. `ACT-SB-BOUNDARY-WRIT` is `ONE_ENEMY` and writes the `route` role; `ACT-LA-NAME-TRANSFER` is `ONE_ENEMY` and redirects into the `record` role.

#### Cost vocabulary

`turn_cost` is 01's integer `0..5`, and the catalog's prose cost is that integer written out: "one turn" and "one tick" are both `turn_cost=1`, "two ticks" is `turn_cost=2`, and a no-turn action is `turn_cost=0` and must be named as such in the action record. A `turn_cost>=2` action is a committed action in 01's sense: it is the only normal command in its actor window and fixes `action_slots=1` for that window. `ACT-AO-AUDIT-CHARGE` is the only committed action in this file; every other action here is `instant` or `charge`.

- Resource costs are paid before commitment. A missing required resource blocks the action and displays a combat-local failure result; it never silently becomes a basic attack.
- Guard, Dodge, and Break remain separate counter axes. A status may resist one axis without changing the other two.
- Encounter target priority is ordered data. When a listed actor is absent, priority moves to the next valid actor; the UI does not choose based on visual size, screen distance, or drawing order.

### 1.5 Break policy vocabulary

- `marked`: Break is valid only during the named telegraph/commitment window; breaking cancels the signature and creates the authored punish window.
- `accumulator`: repeated stagger or authored damage fills a meter; one Break occurs at threshold. The meter is not shared with all enemies.
- `link`: Break or an authored sever action removes the link or marks a clone outlier; the owner is not automatically staggered.
- `resource`: Break is available only after a named resource, status, or actor relation is spent.
- `phase_locked`: the current phase explicitly disallows Break until its trigger, proof, or sever condition is met.
- `unbreakable`: Break never interrupts the action; the record must provide another valid counter.
- `false_break`: Break is a readable trap that triggers retaliation or escalates a clock; it is never presented as a hidden surprise.

## 2. Action, status, clock, and outcome semantics

### 2.1 Action contract

Each baseline and signature action records the following values: `action_id`, `intent`, `target_mode`, `turn_cost`, `resource_cost`, `precondition`, `telegraph_ticks`, `telegraph_channels`, `commitment`, `active_payload`, `recovery`, `punish_window`, `valid_counters`, `invalid_counters`, `break_policy`, `reaction_on_hit`, `reaction_on_miss`, `reaction_on_break`, `phase_hooks`, and `status_hooks`.

`target_mode` takes one of the six values in section 1.4 and nothing else. An action that also acts on a `record`, `route`, `resource_node`, or `linked_actor` names that role in `status_hooks` and keeps its target mode on the actor it was aimed at. `turn_cost` is 01's integer `0..5`; the prose cost in this catalog is that integer written out.

The source documents establish the existence of command categories, target selection, scheduler pressure, statuses, charge tells, and Break exceptions, but do not establish exact gauge numbers. This plan therefore uses scheduler ticks and explicit authored values rather than claiming source measurements.

### 2.2 Status vocabulary

This table is the closed status set for enemy and encounter authoring. A status used by any record in section 3, 4, or 5 is defined here, and a status defined nowhere else in this file is a validation failure. Each row authors 01 section 12.1's `StatusDefinition` fields - `max_stacks`, `duration_windows`, `stacking_mode`, `control_tags`, `cure_tags`, `dispel_tags`, `remove_order` - and adding a status is data-only: it must not add a combat-core branch.

| Status | Resolution behavior | Cure or removal |
|---|---|---|
| `recorded` | The committed action or identity claim enters the encounter's record. It does not change damage by itself. | Expire, erase by an authored counter, or resolve through `verified`. |
| `redaction_mark` | The next command category is invalidated on resolution. | Break marked source, `cleanse_record`, or the mark's duration. |
| `named` | The target is bound to one name/category for targeting and authority checks. | Release the name, retag, break the source link, or expire. |
| `registration_lock` | The target cannot be freely retagged or selected by an authority that lacks the record. | Present a valid permit/identity proof, break the record, or expire. |
| `contamination` | On the next committed action, transfers one `ink_bloom` to the actor selected by the action's target mode. | Quarantine, cleanse, burn, or isolate. |
| `ink_bloom` | Stacks from 0 to 3. At 3, the actor is forced into `recovery_window` or withdraws. | Cleanse one stack, sever the source, or complete quarantine. |
| `grievance_debt` | Stores the next damaging action aimed at the owner and reflects its payload after one scheduler turn. | Do not attack; pay the authored record cost, sever the claim, or Break the claim. |
| `mirrored` | A committed payload is copied to the source or linked actor while the window is open. | Break the mirror, change target, or wait out the window while using a non-damaging counter. |
| `delayed` | The target's next scheduled action moves one tick later. | Silence, no-turn purge, or a source-specific release. |
| `resonant` | The active action accepts only silence, resource payment, or marked Break as a counter. | End resonance, consume the tuning resource, or complete the encounter. |
| `silenced` | Control status. `control_tags: [silence]` and `trait_modifiers: {cannot_act: true}`, so the actor's next command window passes without queueing a command. `max_stacks: 1`, `stacking_mode: replace`; a second source refreshes the remaining windows instead of stacking. Per 01 section 12.3 it never cancels an action already resolving in the current window, and the reaction-window counter action is the one `cannot_act` exception. It removes command windows, not stances, not already-applied statuses, and not a charge stage already past `reaction`. | `clear_channel`, `latency_key`, an authored no-turn purge, source sever, or expiry. Silence is a scheduler counter, never a damage multiplier. |
| `sealed` | One command category is unavailable until a valid permit is presented or the seal is broken. | Permit, sever the contract, or Break a marked lance. |
| `verified` | A permit, source name, or route proof is recognized for this action only. | Expire; it is not a permanent immunity. |
| `translated` | The target's action label resolves to the previous or next authored label until corrected. | Anchor a source glyph, silence the translator, or expose the source. |
| `misnamed` | The target is categorized incorrectly; category-dependent actions lose their intended effect. | Retag, sever the scent, or present a correct name. |
| `scented` | The hound tracks the last committed category rather than physical distance. | Break the scent link, change category at a valid anchor, or evade with an authored route. |
| `amnesia` | The last committed command is removed from the recovery record and cannot be replayed. | `recovered_note`, a linked source, or a clean recovery window. |
| `memory_drain` | The actor has absorbed a committed command or memory fragment; one later action slot may be removed. | `recovered_note`, sever the Sponge, or complete a noncombat recovery decision. |
| `organ_tension` | Each stack changes which linked organ receives target priority. | Silence or satisfy the organ's current demand. |
| `voice_lock` | New commands are blocked until one linked voice is silenced or negotiated. | Consent charter, surgical license, or one-voice silence. |
| `linked` | Damage, status, and phase hooks are shared with the listed actor set. | Sever link, mark an outlier, or destroy the named source. |
| `outlier` | One actor is removed from a group link and can be targeted separately. | Expire or rejoin only after a noncombat repair condition. |
| `consensus` | A linked group gains its signature strength while all listed actors remain linked. | Sever one link or mark an outlier. |
| `consumed` | One named healing, water, attention, or supply resource was removed by an aggregate action. | Restore the resource, deny the source, or let the consuming actor become `exhausted`. |
| `overfed` | Stacks from 0 to 3, one per completed aggregate feast. Each stack raises the swarm's aggregate consumption payload and keeps the anchor fed; it stacks on the swarm, never on the anchor. At 3 the swarm becomes `exhausted` and its signature is disabled, which is the readable payoff of denying the resource instead of attacking. | Deny the named resource, isolate the anchor, `cleanup_token`, or the `exhausted` transition. `overfed` is resource pressure, not a damage multiplier. |
| `scarline` | The target's next recovery effect is redirected to the incision envoy. | Cauterize, sever the line, or complete consent. |
| `recovery_lock` | Healing/recovery is blocked until the line or organ demand is resolved. | Cauterize, cure, or accept a different recovery. |
| `chilled` | Water and heat-based recovery are reduced until thawed. | Heat, a safe-water route, or a heat_token resource. |
| `thirst_locked` | Water-dependent consumables cannot be used. | Verified safe water, thaw, or a noncombat ration decision. |
| `verified_safe` | A named alternate resource is accepted for this encounter. | Expire; it does not make the region generally safe. |
| `audited` | Reward, debt, and target priority are held for an encounter audit. | Present a record, pay an audit cost, or Break the charge. |
| `charge_lock` | One command category is locked until the charge resolves or is Broken. | Dodge, Break, resource lock, or a source-specific route. |
| `noised` | The next scheduler choice gains a visible timing offset. | Silence, clear channel, or consume the noise. |
| `slot_stolen` | One action slot is unavailable for the listed duration. | Clear the signal, silence the tithe, or use a no-turn action. |
| `writ` | A route or identity boundary has been formally marked. | Present proof, revoke the record, or use an alternate route. |
| `boundary_locked` | The authored exit is unavailable while the writ remains. | Revoke the writ, open a second route, or complete the phase. |
| `copied` | Active statuses are copied to a projection or source actor. | Sever the source link, silence the copy, or expose the original. |
| `redirected` | The next committed effect is sent to a named source/target instead. | Retarget, break the link, or destroy the source before commit. |
| `name_transferred` | Authority and recognition follow the transferred name rather than the body. | Restore the original name, kill the false anchor, or accept a route. |
| `recovery_window` | A short punish or consequence window is active. | Resolve the authored punish, then expire. |
| `exhausted` | The actor's resource pool is empty and its signature is disabled. | Recover, leave, or destroy the source. |
| `concentration_load` | The target's committed craft output is still in the body. Stacks 0..3. Each stack adds one to the `concentration_requirement` of the target's authored craft actions and blocks that action's `precondition_ids` at the authored threshold. It is accumulation pressure, not a damage multiplier, and it is never a `mana` pool. | One authored dispersal action, a `disperser`/`circulator` route, a clinic `mana_profile` triage, or expiry. |
| `medium_residue` | Stacks 0..3, one per failed or mis-shaped craft the actor has handled. At 2 the residue source becomes severable; at 3 the next craft action on the actor resolves as `misfolded` instead of executing. The stacks are a record of handling, not a contamination copy - `contamination` keeps its own transfer rule. | Isolate the residue, clean the medium, an authored disposal decision, or `cleanup_token`. |
| `misfolded` | One committed craft action on the target failed against its authored `shape_or_pattern` and paid a documented cost. The action is not renamed, retried, or replaced by a different spell. | Accept an alternate shape, cure the `medium_residue`, or file the failed-fold record. |
| `overflowed` | The target's `body_load` crossed the authored concentration threshold once. `control.blocked_action_categories: ["magic"]`, so every `magic`-category action becomes focusable-disabled with an authored `unavailable_reason` while it runs. It removes command windows only inside the `magic` category and never removes a stance, an already-applied status, or a charge stage past `reaction`. | A `disperser`/`circulator` route, a clinic `mana_profile` triage, one authored dispersal action, or accepting the body load. |
| `contract_bound` | A portal contract's deferred obligation is attached to this actor or encounter. `contract_tally` does not tick down on its own and the obligation is not a combat cost; the attached actor is a `record` holder, and acting on it is a permit/proof action rather than damage. | File the contract document, refuse the shape before commitment, or name where the obligation lives at `G8`. |

`concentration_load`, `medium_residue`, `misfolded`, `overflowed`, and `contract_bound` are the only statuses the magic layer adds, and all five express themselves through 01 §12.1's typed fields - `stacking_mode`, `duration_windows`, `trait_modifiers`, `control_tags`, `cure_tags`, `dispel_tags`, `remove_order`, and the authored tick payload. None of them adds a combat-core branch, a new `StatusDefinition` key, or a new status op; `06` §5.4's `tick.operations` stays limited to `resource_delta` and `apply_status`.

Statuses are combat-local unless an encounter explicitly writes them into a world aftermath record. Status color, icon, and position are presentation data; they never define the status. `recovery_window` and `recovery_lock` are statuses in this table and are not recovery types: the recovery type vocabulary is 08's, and section 2.7 is the only place this file touches it.

### 2.3 Linked actor contract

Every summon or linked actor record contains `owner_id`, `actor_id`, `count`, `max_count`, `timing`, `role`, `true_target`, `spawn_clock_link`, `lifetime`, `death_rule`, `escape_rule`, `phase_rule`, and `cleanup_rule`. The allowed death rules are `owner_death_kills`, `remains_after_owner_death`, `simultaneous_death`, `flee_at_threshold`, `survives_as_npc`, and `revive_changed_form`. No actor is allowed to be both a visual add and an unrecorded damage source.

`role` is a linked-actor role - `guard`, `pressure`, `true_actor`, `support`, `decoy` - while `linked_actor` is the encounter target role from section 1.4, not a target mode. `true_target` is written as `role:entry` against the encounter roles, so "the true target is the gate record" is a role statement about a `record` and "the true target is the central knot" is a role statement about a `linked_actor`. A linked actor can be the correct target without being the encounter's apparent main body, and at most one entry per encounter may carry the true-target role.

### 2.4 Pressure clocks

| Clock ID | Meaning in this file |
|---|---|
| `CL-INST` | Institutional response: how quickly an authority classifies, seals, audits, or intervenes. |
| `CL-CONT` | Contamination: accumulated recovery/recognition failure and transfer between actors. |
| `CL-REC` | Public record: how strongly a category, name, or event becomes accepted as official truth. |
| `CL-RES` | Resource collapse: food, water, heat, attention, medicine, and safe access are consumed or withheld. |
| `CL-PER` | Personal collapse: an NPC, organ, clone, or role loses continuity with its prior self. |
| `CL-CROWN` | Crown alignment: the abstract authority increasingly recognizes one operator, record, or route. |

A clock link names an immediate effect and a delayed effect. A clock never becomes a single global danger bar. It is exposed through encounter behavior, NPC behavior, documents, resource access, or revisit state.

These are the six canonical pressure clocks, one per stage vocabulary owned by 02. `CL-CROWN` is a pressure clock and a world write: an encounter can move the Crown-alignment stage as an immediate or delayed effect, and that write is permanent world state. Crown alignment is not a recovery type, and this file never authors one. `clock_links` records stage movement only and never restates the stage names 02 owns.

### 2.5 Authored resource vocabulary

| Resource ID | Authored use |
|---|---|
| `ink_credit` | Alters or erases one local record category; consumed by noncombat record edits. |
| `entry_token` | Grants one disputed crossing, re-entry, or corrected registration. |
| `harvest_residue` | A trace of a cleaned contamination or ecological source; used for later repair or trade. |
| `petition_seal` | Proves that a grievance was settled or transferred; changes court/service access. |
| `permit_fragment` | Partial proof for a transformation, route, or legally restricted action. |
| `latency_key` | A tuning or maintenance resource that removes one authored scheduler lock. |
| `clear_channel` | A communication resource that silences one signal relay or emergency route. |
| `untranslated_glyph` | Preserves a source term against a local translated rule. |
| `definition_token` | Proves or changes one target category in a registry or school. |
| `recovered_note` | Restores one removed command, memory fragment, or record after a recovery failure. |
| `consent_charter` | Records which body authority or patient voice may authorize a procedure. |
| `surgical_license` | Allows one clinic procedure or changes a service route's permission state. |
| `identity_token` | Separates one clone, role, or legal name from a shared record. |
| `water_manifest` | Verifies one alternate water source and opens a ration route. |
| `audit_credit` | Pays, contests, or reroutes one authored debt/audit charge. |
| `seam_key` | Opens or revokes one authored boundary route. |
| `root_record_fragment` | Proves one Crown truth/authority/continuity axis in a late route. |
| `heat_token` | Supplies one thaw/heat action for a chilled resource route. |
| `cleanup_token` | Removes one ecological residue or separates one aggregate grazer anchor. |
| `medicine_reserve` | Pays one failed surgery/recovery intervention. |
| `party_supply` | Shared supply consumed by a noncombat ration or resource decision. |
| `relationship_token` | Records one explicit NPC/companion trust or separation decision. |
| `ration_packet` | Carries one safe-water ration from a settlement route. |

The magic layer uses `02` §5.5's `res_*` tokens directly and never mints a new one. These are field/world resources; they are not combat `hp`/`mp`/`equipment_charge` and they are not a single `mana` number.

| Resource ID (`02` §5.5 vocabulary) | Authored use in this file |
|---|---|
| `concentration_sample` | One measured concentration reading with a `provenance` that says `R2-09` or `R8-02`. The `R8` encounter files the residue ledger as the provenance of a sample; it never creates a sample out of nothing. |
| `medium_blank` | The consumable input for a weave/scroll craft action. A craft action without the matching medium cannot resolve. |
| `fold_sheet` | The consumable input and fold-count budget for a rigid-fold craft action. |
| `blade_credit` | The use-right for a void-cut tool. `shape_or_pattern` and `tool_variant` are fixed at the moment the credit is granted, not at cast time. |
| `disperser_charge` | The powder that keeps a node's `concentration_field` inside its safe band. Spending it is the readable counter to `concentration_load`. |
| `circulation_slot` | The remaining headroom for moving accumulated concentration into outside air. Spending it lowers the local field and charges a neighbour's `K`/`E`; it is never recorded as a solution. |
| `craft_credit` | School/workplace-recognised craft time. It is what the failed fold costs and what the R8 field court outcome pays or withholds. |
| `lineage_token` | Unformalised craft access preserved by a house. It is a lineage entry, not a school certification, and it does not replace `craft_credit`. |
| `contract_tally` | Non-quantified debt key. Counts the unresolved portal obligations this file's records create. It is an obligation ledger, not a combat balance value, and it has no `amount`. |
| `labor_pledge` | Non-quantified debt key. The signed commitment behind `G5`, which decides whether `E18` and therefore `R8` opens at all. |

`02` §12 assigns the registration of these keys into `06` §6.3's closed `res_*` registry to `06`; this file only consumes them. Until that registration lands, every `res_*` token above is a required `06` addition, and an encounter reward naming one is `unknown_field_resource_key` rather than a new key.

### 2.6 Region contract reference

`region_role` is a field of the region contract, not of this file. `06_AUTHORED_CONTENT_AND_DATA.md` section 5.10 `RegionDefinition` owns the region record and carries `region_role`; `02_WORLD_STATE_AND_ROUTES.md` §1 and §7.0 own the canonical nodes (`H0` hub plus `R1`-`R8`) and the nine `region_role` tokens; `06` §3.5.1 is the ID re-key. Every `region_role` in this file is one of those nine tokens, every family/encounter names one canonical `region_id`, and that region's `06` `RegionDefinition.region_role` must equal the token here. A token that a region does not declare, or a record whose region is not a canonical node, is `region_role_mismatch` / `encounter_region_role_mismatch`.

The nine tokens are closed. This file does not shorten them, pluralise them, or invent an institution/resource/route variant of one.

| `region_role` token (closed 9) | Canonical node | What the role carries for combat authoring |
|---|---|---|
| `hub_registration_ration_appeal` | `H0` The Undersign Exchange | Arrival category, ration counters, appeal, route debt, and the aggressive stamp/queue that turns paperwork into an enforcement process. |
| `recovery_reentry` | `R1` The Returning Kiln | Recovery, re-entry, naming, and classification by a record. `Return Registry` and `Kiln Wardens`. |
| `resource_allocation` | `R2` Siltglass Commons | Water, food, seed, attention, clone census as aggregate consumption, and the dispersed concentration infrastructure. |
| `intervention_scheduling` | `R3` Bellhouse Hospice | Care latency, signal relays, and the faith-as-latency device. Faith Engineering unit. |
| `translation_precedence` | `R4` Crownwell Archive | Names, records, categories, executable local rules, and the vertical projection above the halls. |
| `permission_before_transformation` | `R5` Glasswing Ordinal | Permission, permits, boot/labour status, and the craft that runs inside combat. `Glasswing Ordinal`/`Labor Court`/`Support Registry`. |
| `organ_authority_negotiation` | `R6` Gristmarket Ward | Body authority, surgery, consent, and divergent voices. `Gristmarket Clinic`/`Organ Exchange`. |
| `boundary_crown_precedence` | `R7` The Hollow Orchard | Safety categories, continuity debt, route seals, and the precedence claim. `Boundary Survey`. |
| `magic_training_craft_labor` | `R8` The Folding School | Concentration measurement, craft curriculum, lineage placement, portal contract adjudication, and the conflict over who a learned craft is recorded as labour for. |

Two rules make the old nine shorthand keys illegal from here on:

- `R-RETURN`, `R-CROWN`, `R-ARCHIVE`, `R-LATENCY`, `R-LEXICON`, `R-VISCERA`, `R-SERVICE`, `R-COMMON`, and `R-SEAM` are retired. They were never region IDs, they never resolved one-to-one onto `02`'s nodes, and `R-LATENCY` in particular spanned two different regions with two different roles.
- A record that genuinely spans two regions names the primary region's `region_id`/`region_role` in the record and the second region in `region_secondary`, so the `R-LATENCY` content split is decided per record instead of per key. The resolved split is: faith-as-latency, care latency, and signal relays are `R3` `intervention_scheduling`; boot, permit, and transformation service are `R5` `permission_before_transformation`. A record that leaves the split unstated is `region_role_split_unresolved`.

A family or encounter may be re-keyed to a different node without changing its combat content, but the re-key must be a data change in `06`, not a family branch in this file.

### 2.7 Encounter outcome contract

- `V — victory`: authoritative actor state is resolved and the listed rewards/aftermath are written.
- `E — escape`: the player leaves through an authored route or target priority; rewards are partial and a clock or record may advance.
- `F — failure`: combat-local actors reset at the encounter's authored checkpoint; player knowledge is preserved; only listed clocks/aftermath persist.
- `N — noncombat/alternate`: a valid conversation, proof, resource decision, sacrifice, or route bypass changes the same state surfaces without combat.

`F` resolves to the `checkpoint` recovery kind and to nothing else. The canonical recovery enum is 08's seven values - `checkpoint`, `respawn`, `clone`, `reincarnation`, `loop`, `immortality`, `institutional_reentry` - and no record in this file authors a recovery type other than `checkpoint`; the other six are owned by 08 and reached through 07's route and recovery authoring, not through an encounter outcome. Combat mid-state is never saved, so the only restore points an encounter offers are the pre-command intent and the encounter checkpoint. Crown alignment is a world write, not a recovery type: when an encounter moves `CL-CROWN`, the stage move is written as a world effect in the victory, escape, or failure aftermath and is not undone by the checkpoint.

### 2.8 Magic and concentration layer

This layer is authored over the records above, not beside them. The rules below are the closed contract for `FAM-ARPG-19`, `ENC-ARPG-25`, and every existing record that touches craft.

#### 2.8.1 What the layer may and may not add

| It may | It may not |
|---|---|
| add `ActionDefinition` records in the existing `category: magic` slot with the existing target enum, `turn_cost`, `resource_costs`, `lifecycle`, `precondition_ids`, and `phase_effect_ids` | add a `category` value, a target mode, or a lifecycle value |
| add `StatusDefinition` records expressed in 01 §12.1's existing typed fields | add a status op, a `StatusDefinition` key, or a `if status_id` branch in combat core |
| add an encounter phase whose trigger is a status stack, a resource threshold, a linked-actor death, or an NPC/relationship/clock state | add a phase trigger type; the trigger list in section 8 is closed |
| name `record`, `route`, and `resource_node` as the encounter-level target roles of section 1.4 | treat a `resource_node` or a `route` as a body, a HP pool, or a seventh target mode |
| read and write `02` §5.5's `res_*` keys and `02` §9.1's six `magic` records | create a single `mana` resource, a global `concentration` bar, or a combat `mp` pool labelled as craft |
| write `K`, `P`, `R`, `E`, `I`, `C` under `02` §4.4's one-row-per-transaction rule | add a seventh pressure clock, or advance two of the six in one transaction |
| classify a failure as `recoverable`, `continuity-changing`, or `terminal` | treat those three grades as recovery types, or add an eighth recovery type |
| file an unresolved portal obligation as `contract_tally` | auto-resolve a contract, tick an obligation down, or spend it as combat cost |

#### 2.8.2 Canonical tokens

Only these tokens appear in magic-authored records. Names come from `02` §5.5, `02` §9.1, and `12`; this file does not create new ones.

- `concentration_field` - a node/path/action measurement with a `provenance` of `R2-09` or `R8-02`. It is a field value, not a global bar and not a clock.
- `body_load`, `mana_profile` - per-actor accumulation, emission capacity, injury, and the `12` §2.2 profile class. A profile is a body compatibility/failure class and never a moral judgement.
- `medium`, `tool`, `shape_or_pattern`, `tool_variant` - the authored craft inputs and the authored contract that decides cost and result.
- `disperser`, `circulator` - `R2` civic infrastructure. A disperser holds a node inside its band; a circulator moves accumulated concentration into outside air and charges a neighbour.
- `craft_credit`, `lineage_token`, `contract_tally` - the three things a craft can be recorded as. Exactly one is written per resolution, and the choice is the story content.
- `E4 The Concentration Layer` - the era. `R8 The Folding School` is an authored module inside the Undersign world, entered only through `E18` with gate `G5`.

#### 2.8.3 The untranslated-name rule

The positive name of the craft theory is not authored here, in `06`'s schema, or in any module script. It lives in `R4`'s `glossary` slot as an authored record. While that slot is empty, a craft name is filed as `untranslated term`, and the school name and the archive translation both remain on the record as a `R4-02`-style conflict. `FAM-ARPG-19` and `ENC-ARPG-25` therefore name the family and the encounter after an institution's physical grading surface, never after a theory.

#### 2.8.4 Failure grades and their combat expression

| Grade | Combat expression in this file | World expression |
|---|---|---|
| `recoverable` | one `misfolded` instance, or one `concentration_load` stack that an authored dispersal action removes inside the encounter | a residue or credit record; nothing is filed as a recovery |
| `continuity-changing` | `concentration_load` at its threshold, or `overflowed` on the player side | `C` moves to `branched` and/or `P` moves, each as its own transaction per `02` §4.4 |
| `terminal` | the authored craft action becomes permanently unavailable for that run and the actor's competence action set is locked by an authored precondition | a `course credit`/competence record is withdrawn; the student is not removed from the region |

A terminal grade is a record and a lock, never instant death. `12` §9's rule holds: magic failure is not an automatic exclusion from any affection route, and consent, recovery, and shared choice stay authored data.

#### 2.8.5 Clock discipline for magic encounters

`02` §4.4 forbids one write advancing two clocks. Every magic `clock_links` row in this file therefore names exactly one immediate clock write, and any second clock move is written as a separately recorded transaction or as a delayed effect - never as a second stage of the same write. A failed cast moves `K` (medium residue) or `P` (body load), never both, and `R` moves only when a failure document is filed. Portal contract execution moves `C` as an interpretation input only; it never advances `C` on its own.

## 3. Enemy family catalog

### FAM-ARPG-01 — Tally-Skin

- `seed_ids`: `S009`, `S011`, `S019`, `S044`, `S056`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`).
- `region_role_local`: `E2 Administrative Recovery` Return Bureau boundary clerk at the current `Return Registry`; it turns a body's crossing into a category and protects the category even when the body is wrong.
- `silhouette_body_class`: low, wide, paper-over-metal quadruped with a dragging counterweight.
- `baseline_action`: `ACT-TS-PIN`, `ONE_ENEMY`, one turn; records the target's next command category.
- `signature_action`: `ACT-TS-REDA-SWEEP`, `ONE_ENEMY`, one turn; a marked sweep invalidates one command category and transfers a small `redaction_mark` on hit.
- `telegraph`: three black stitch lines cross the target and a pen-click removes the next sound layer; one scheduler tick.
- `valid_counters`: Dodge the stitch, cleanse the mark, Break a marked sweep, or present a valid seal before the sweep commits.
- `invalid_counters`: raw damage without a counter, repeated attacks after the sweep resolves, or ignoring the marked command category.
- `break_policy`: `marked`; the baseline pin is unbreakable, while a marked sweep creates `recovery_window` on Break.
- `statuses`: `recorded`, `redaction_mark`, `silenced`, `recovery_window`.
- `phases`: intake pins at encounter start; audit pins at the encounter's first recorded-command threshold; empty form at the authored low-health or source-record threshold, where the signature becomes harder but a valid seal remains possible.
- `summons_linked_actors`: the gate record is a linked noncombat source; if the source is exposed, the Tally-Skin loses `redaction_mark` and the Usher's binding falls to the next valid name.
- `resource_reward_effect`: victory grants `ink_credit x1`; accepting a noncombat seal grants `entry_token x1` but advances `CL-REC`; unresolved sweeps add one `CL-CONT` on failure.
- `aftermath`: the record, border, and NPC registrar state visibly disagree; revisit can accept, dispute, or erase the stamp.
- `clock_links`: immediate `CL-INST +1` and `CL-REC +1`; delayed `CL-CROWN +1` if the record outlasts the person.

### FAM-ARPG-02 — Return Usher

- `seed_ids`: `S002`, `S003`, `S051`, `S053`, `S055`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`); `region_secondary: hub_registration_ration_appeal` (`H0 The Undersign Exchange`).
- `region_role_local`: survivor of the `E2 Administrative Recovery` Return Bureau's first registration rule; it carries the office even when the office no longer carries a living clerk.
- `silhouette_body_class`: tall, narrow lantern-biped with a hovering ledger plate and no stable face.
- `baseline_action`: `ACT-RU-STAFF-PULSE`, `ONE_ENEMY`, one turn; applies `named` and `registration_lock` for one scheduler turn.
- `signature_action`: `ACT-RU-NAME-CALL`, `ONE_ENEMY`, one turn; binds the target's command label to the Usher's current record and redirects one category through the gate.
- `telegraph`: the lantern opens, a blank name plate appears, and the target's selection line brightens; one tick.
- `valid_counters`: silence, Break after a successful name call, use `verified` identity evidence, sever the linked record, or accept a noncombat correction.
- `invalid_counters`: attacking an unbound copy, switching targets without an intent, or treating the name plate as a harmless visual.
- `break_policy`: `accumulator`; three successful stagger actions create one Break window, after which the Usher can call again after a phase threshold.
- `statuses`: `named`, `registration_lock`, `silenced`, `recovery_window`.
- `phases`: first call uses the current public name; second call binds a social relationship name; empty-name phase removes the name from the target list but exposes the source record.
- `summons_linked_actors`: the gate record and any appointed registrar remain linked; a surviving record can restore one `named` status after actor death.
- `resource_reward_effect`: victory grants `entry_token x1` and one `recovered_note`; escape preserves the last valid name but spends one `ink_credit`; noncombat correction advances `CL-REC`.
- `aftermath`: a character may be recognized under a different name, employment history, or institutional category on revisit.
- `clock_links`: immediate `CL-INST +1`; delayed `CL-CROWN +1` and `CL-PER +1` when a role persists after the person changes.

### FAM-ARPG-03 — Melted Index

- `seed_ids`: `S009`, `S017`, `S024`, `S031`, `S064`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`).
- `region_role_local`: failed recovery archive that liquefies records and transfers the failure to whoever handles the paper.
- `silhouette_body_class`: amorphous, low mass with a fixed central knot and a spreading paper fringe.
- `baseline_action`: `ACT-MI-SEEP`, `ALL_ENEMIES`, one turn; adds one `contamination` stack to each target that commits an action.
- `signature_action`: `ACT-MI-CONTAGION-BLOOM`, `ALL_ENEMIES`, one turn; spreads `ink_bloom` to the highest-priority target and one linked actor.
- `telegraph`: wax pools under the fringe and the next document line appears on the floor; two ticks.
- `valid_counters`: quarantine, isolate, cleanse/burn, sever the source knot, or Break after two `contamination` stacks.
- `invalid_counters`: chasing the moving edge, consuming healing in the affected area, or waiting for the status to expire.
- `break_policy`: `resource`; two contamination stacks expose the central knot, which can be Broken once; ordinary seeps are unbreakable.
- `statuses`: `contamination`, `ink_bloom`, `recovery_window`, `exhausted`.
- `phases`: seep at start; bloom at `ink_bloom 2`; evacuation at `ink_bloom 3`, with the central knot becoming the true target.
- `summons_linked_actors`: a source node remains after the visible mass dies; the source survives actor death and can seed a later revisit.
- `resource_reward_effect`: victory grants `harvest_residue x1` and lowers one local contamination step; escape grants no material reward and advances `CL-CONT +1`; noncombat quarantine spends one `entry_token`.
- `aftermath`: the room's records, resource flow, and NPC availability gain a contamination state; the state is visible on revisit rather than only in combat text.
- `clock_links`: immediate `CL-CONT +1`; delayed `CL-RES -1` only when the source is quarantined, otherwise `CL-RES +1`.

### FAM-ARPG-04 — Grievance Ward

- `seed_ids`: `S012`, `S039`, `S046`, `S048`, `S056`.
- `region_role`: `hub_registration_ration_appeal`; `region_id: region_h0_undersign_exchange` (`H0 The Undersign Exchange`); `region_secondary: boundary_crown_precedence` (`R7 The Hollow Orchard`).
- `region_role_local`: court-guard for complaints that are legally useful and socially dangerous at the same time. `H0-07 Paper Wardens` is where the stamp and the queue become operational rather than clerical.
- `silhouette_body_class`: broad, shield-fronted biped with a petition box for a torso and a small recorder above it.
- `baseline_action`: `ACT-GW-SLAM`, `ONE_ENEMY`, one turn; applies `grievance_debt` and pushes a target's action priority.
- `signature_action`: `ACT-GW-COUNTERCLAIM`, `ONE_ENEMY`, one turn; records the next damaging payload and reflects it on the next turn unless the claim is resolved.
- `telegraph`: the shield opens like a reception window, a voice asks for a category, and the target's outline gains a claim mark; two ticks.
- `valid_counters`: do not attack, present contrary evidence, apply a non-damaging status, sever the claim, or Break after the grievance meter fills.
- `invalid_counters`: repeated damage, attacking before the intake line closes, or treating the shield as a defensive-only object.
- `break_policy`: `accumulator`; a claim threshold creates a Break window, but a fresh claim after the threshold is protected by `phase_locked`.
- `statuses`: `grievance_debt`, `mirrored`, `audited`, `recovery_window`.
- `phases`: intake; cross-examination after the first stored payload; judgment at the second claim, where the Ward becomes unbreakable until evidence or a permit resolves the case.
- `summons_linked_actors`: claim copies and FAM-ARPG-06 enforcers are linked to the public record; a claim copy can survive the Ward and appear in a later audit.
- `resource_reward_effect`: victory grants `petition_seal x1`; noncombat settlement grants `permit_fragment x1` but raises `CL-REC`; failure adds one unresolved labor claim to `CL-INST`.
- `aftermath`: the player, an NPC, or a faction receives a recorded duty/label that changes access or compensation on revisit.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-INST +1` or `CL-PER +1` depending on whether the claim names a person or a role.

### FAM-ARPG-05 — Stalled Bell

- `seed_ids`: `S013`, `S014`, `S018`, `S022`, `S024`.
- `region_role`: `intervention_scheduling`; `region_id: region_r3_bellhouse_hospice` (`R3 Bellhouse Hospice`); `region_secondary: permission_before_transformation` (`R5 Glasswing Ordinal`, which carries the foundry half of the same signal network).
- `region_role_local`: faith-as-latency device built around the hospice's Faith Engineering unit; it measures belief by how long a response is allowed to arrive.
- `silhouette_body_class`: floating ring-cluster with a suspended clapper and a narrow human-scale shadow.
- `baseline_action`: `ACT-SB-RESONANCE`, `ONE_ENEMY`, one turn; applies `delayed` to the target's next scheduler choice.
- `signature_action`: `ACT-SB-DELAY-LATTICE`, `ALL_ENEMIES`, one turn; holds one command category for one tick and protects the Bell from ordinary Break.
- `telegraph`: rings contract inward, a clock tick drops out of the audio bed, and the target's command line freezes; two ticks.
- `valid_counters`: silence, a no-turn purge, a marked Break at resonance peak, a `latency_key` tuning action, or a noncombat maintenance choice.
- `invalid_counters`: attacking while silent, waiting for the delay to expire, or using a normal action to fill a scheduler slot.
- `break_policy`: `marked`; only the resonance peak is Breakable. After phase 2 the Bell is `phase_locked` until a signal source is disconnected.
- `statuses`: `delayed`, `resonant`, `silenced`, `recovery_window`, `slot_stolen`.
- `phases`: resonance; staggered arrival after the first delayed action; hard lock after a `CL-INST` threshold, with a source-disconnect counter.
- `summons_linked_actors`: the Bell links to the foundry's signal relays; a relay can remain after the Bell dies and continue `noised` effects until cleared.
- `resource_reward_effect`: victory grants `latency_key x1`; a maintenance bypass spends one `clear_channel`; failure raises `CL-PER +1` for the affected NPC schedule.
- `aftermath`: work orders, service availability, and NPC sleep/recovery schedules change; the Bell's absence is not a clean victory if its relay remains.
- `clock_links`: immediate `CL-INST +1`; delayed `CL-PER +1` if delay persists across a revisit, otherwise `CL-RES -1` after maintenance.

### FAM-ARPG-06 — Seal Lancer

- `seed_ids`: `S020`, `S021`, `S023`, `S044`.
- `region_role`: `permission_before_transformation`; `region_id: region_r5_glasswing_ordinal` (`R5 Glasswing Ordinal`).
- `region_role_local`: transformation-service guard that validates permission before a body is allowed to change, even when the body is not the correct body. `Glasswing Ordinal` and `Labor Court` own the permit; `R5-06 Formation Failure` is its escalation.
- `silhouette_body_class`: upright, narrow armored biped with a long legal lance and a visible checklist plate.
- `baseline_action`: `ACT-SL-LANCE-CHECK`, `ONE_ENEMY`, one turn; applies `sealed` to one command category unless `verified` is present.
- `signature_action`: `ACT-SL-CONTRACT-LANCE`, `ONE_ENEMY`, one turn; applies `sealed` plus a body-history mark if the target cannot show a valid permit.
- `telegraph`: the lance draws a license glyph, a checklist line completes, and the target's legal category flashes; one tick.
- `valid_counters`: present `permit_fragment`, Break a marked lance, change target before commitment, revoke the record, or choose a valid noncombat appeal.
- `invalid_counters`: random attack after the checklist completes, using a different permit category, or attacking the lance while the target is still `sealed`.
- `break_policy`: `marked`; a valid permit changes the encounter's action set, and a Break on the signature opens `recovery_window` but does not erase the record.
- `statuses`: `sealed`, `verified`, `registration_lock`, `recovery_window`.
- `phases`: application; audit at the first sealed command; amendment at the source-record threshold, where the lance is `unbreakable` until a permit is accepted or the NPC conversion resolves.
- `summons_linked_actors`: FAM-ARPG-11 incision envoys and the support registry's contract node remain linked to the Lancer; a revoked contract can convert the Lancer into a noncombat actor.
- `resource_reward_effect`: victory grants `permit_fragment x1`; noncombat approval grants `surgical_license x1` but advances `CL-CROWN`; failure consumes one `entry_token` attempt and leaves the category sealed.
- `aftermath`: the player's access category, employment/relationship status, or transformation eligibility changes in the next region.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-CROWN +1` when an authority accepts the permit over a person's objection.

### FAM-ARPG-07 — Script Moth

- `seed_ids`: `S069`, `S070`, `S072`, `S073`, `S078`.
- `region_role`: `translation_precedence`; `region_id: region_r4_crownwell_archive` (`R4 Crownwell Archive`).
- `region_role_local`: `Translation Tribunal` pollinator; it carries partial laws between local languages and makes a wrong translation physically executable.
- `silhouette_body_class`: winged, low-density swarm around one dark glyph-body.
- `baseline_action`: `ACT-SM-LETTER-BITE`, `ONE_ENEMY`, one turn; applies `translated` to one command label.
- `signature_action`: `ACT-SM-TRANSLATION-STORM`, `ALL_ENEMIES`, one turn; swaps one target's action label with the next authored label for one resolution.
- `telegraph`: wings align into a readable but incomplete glyph, a translated syllable overlays the command list, and the target's color relation changes; two ticks.
- `valid_counters`: silence, anchor a source glyph, isolate the swarm, apply `misnamed` correction, or Break the central moth after it commits.
- `invalid_counters`: reading the document again, chasing individual moths, or assuming a translated command is the player's chosen intent.
- `break_policy`: `marked`; only the central moth is Breakable after the storm begins. Breaking it leaves the other moths as non-Breakable residue until cleansed.
- `statuses`: `translated`, `misnamed`, `silenced`, `recovery_window`, `exhausted`.
- `phases`: single syllable; competing translations at two surviving moths; blank page after the source is exposed, where the swarm can no longer create a new legal category.
- `summons_linked_actors`: the source term and the Translation Tribunal record are linked; destroying the visible moths does not erase the source term.
- `resource_reward_effect`: victory grants `untranslated_glyph x1`; escape grants one `recovered_note` only if the player carries a visible source fragment; failure restores the checkpoint label but advances `CL-REC`.
- `aftermath`: a local term, NPC title, or region rule changes meaning and remains on revisit until translated or revoked.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-CROWN +1` if the new local law is accepted by an institution.

### FAM-ARPG-08 — Boundary Hound

- `seed_ids`: `S042`, `S044`, `S045`, `S059`.
- `region_role`: `translation_precedence`; `region_id: region_r4_crownwell_archive` (`R4 Crownwell Archive`); `region_secondary: recovery_reentry` (`R1 The Returning Kiln`, whose Return Registry issues the category it enforces).
- `region_role_local`: registry enforcement animal that hunts categories rather than bodies. The category it enforces is a `R4-02` Contradictory Record, which is why the archive owns it and not the registry that wrote the stamp.
- `silhouette_body_class`: low, long quadruped with a broad ear shelf and a collar made of filing marks.
- `baseline_action`: `ACT-BH-CHASE-MARK`, `ONE_ENEMY`, one turn; applies `scented` to the last committed category.
- `signature_action`: `ACT-BH-CATEGORY-BITE`, `ONE_ENEMY`, one turn; forces `misnamed` and redirects one target priority to the current category.
- `telegraph`: the ear shelf opens, a filing line runs from collar to target, and the target's category mark pulses; one tick.
- `valid_counters`: retag at an anchor, sever the scent link, escape through a noncombat route, cleanse `misnamed`, or Break the collar link.
- `invalid_counters`: brute force while `scented`, attacking a different category without retagging, or following the hound by physical distance alone.
- `break_policy`: `link`; the hound owner is not staggered by a collar Break. The link must be severed before the signature loses priority.
- `statuses`: `scented`, `misnamed`, `registration_lock`, `recovery_window`.
- `phases`: scent; registry chase at the first category change; judgment at the second retag, where the hound becomes `phase_locked` until the source category is exposed.
- `summons_linked_actors`: the filing record and a handler NPC are linked; the hound can survive its handler and continue enforcing a stale category.
- `resource_reward_effect`: victory grants `definition_token x1`; noncombat reclassification grants `entry_token x1` and `CL-REC +1`; failure leaves one category mark on the player until a clinic/registry interaction cures it.
- `aftermath`: a person, clone, or enemy can be treated as the wrong species/role by a school, registry, or service on revisit.
- `clock_links`: immediate `CL-INST +1`; delayed `CL-CROWN +1` if the category becomes a durable title.

### FAM-ARPG-09 — Record Sponge

- `seed_ids`: `S005`, `S031`, `S034`, `S035`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`).
- `region_role_local`: recovery leak that converts a failed recovery into a reversible but socially costly edit of the last action.
- `silhouette_body_class`: small floating parasite with a soft rectangular body and one dark intake fold.
- `baseline_action`: `ACT-RS-DRAIN-NOTE`, `ONE_ENEMY`, one turn; removes one minor resource note and applies `amnesia` on a hit.
- `signature_action`: `ACT-RS-UNDO-BITE`, `ONE_ENEMY`, one turn; removes the target's last committed command and creates a `memory_drain` record.
- `telegraph`: the intake fold opens, a soft click repeats the previous command's sound, and a blank line appears in the combat-local record; one tick.
- `valid_counters`: `recovered_note`, a no-turn purge, silence, feed a decoy memory, or Break while the sponge is exposed.
- `invalid_counters`: attempting to undo an already resolved command, chasing after the action slot is gone, or spending recovery items without a memory anchor.
- `break_policy`: `marked`; the sponge is unbreakable while closed and Breakable for one tick after it commits `Undo Bite`.
- `statuses`: `amnesia`, `memory_drain`, `recorded`, `recovery_window`.
- `phases`: drain; borrowed memory at the first removed command; shifted responsibility at the encounter clock threshold, where the sponge can remove a future command slot.
- `summons_linked_actors`: each sponge links to a recovery record; one sponge can remain after the visible source dies and later drain a different route.
- `resource_reward_effect`: victory grants `recovered_note x1`; escape leaves one `amnesia` mark but no material reward; failure advances `CL-PER +1` for the affected character.
- `aftermath`: a character, NPC, or companion has knowledge of a failure that the institution no longer records as theirs.
- `clock_links`: immediate `CL-CONT +1`; delayed `CL-CROWN +1` when the edited record becomes the official account.

### FAM-ARPG-10 — Organ Chorus

- `seed_ids`: `S004`, `S028`, `S029`, `S030`, `S037`.
- `region_role`: `organ_authority_negotiation`; `region_id: region_r6_gristmarket_ward` (`R6 Gristmarket Ward`).
- `region_role_local`: clinic self-governance body whose organs disagree about what counts as a patient, a worker, and a recoverable self. `R6-05 Organ Chorus Trial` is its court.
- `silhouette_body_class`: multi-lobed vertical mass with several unequal faces/ports around one central pulse.
- `baseline_action`: `ACT-OC-PULSE`, `ALL_ENEMIES`, one turn; distributes `organ_tension` across the player side, and each linked lobe's current priority decides which single target takes the highest stack.
- `signature_action`: `ACT-OC-AUTHORITY-CHORUS`, `ALL_ENEMIES`, one turn; forces competing command priorities and locks the player until one voice is answered.
- `telegraph`: separate lobes pulse in different rhythms, a complaint appears in the lower band, and one lobe turns toward the selected target; two ticks.
- `valid_counters`: silence or satisfy one voice, target the weak lobe, sever the central link, use `consent_charter`, or Break after a voice conflict reaches three stacks.
- `invalid_counters`: all-target healing, ignoring the organ with the highest priority, or attacking every lobe in the same scheduler turn.
- `break_policy`: `link`; one voice can be Broken or negotiated, but the Chorus owner remains active until the central link is cut.
- `statuses`: `organ_tension`, `voice_lock`, `linked`, `recovery_window`.
- `phases`: consultation; disagreement at two tension stacks; organ arbitration at three stacks, where the owner becomes `phase_locked` until one voice is recognized.
- `summons_linked_actors`: four named organ lobes, an Incision Envoy, and the clinic consent record are linked; a severed lobe can survive as a patient state.
- `resource_reward_effect`: victory grants `consent_charter x1`; noncombat compromise grants `surgical_license x1` but raises `CL-PER +1`; failure leaves one organ voice unresolved.
- `aftermath`: the same body can disagree about a treatment, employment, relationship, or player identity on revisit.
- `clock_links`: immediate `CL-PER +1`; delayed `CL-INST +1` if the clinic writes the organ's answer over the person's answer.

### FAM-ARPG-11 — Incision Envoy

- `seed_ids`: `S021`, `S026`, `S038`, `S079`, `S087`.
- `region_role`: `organ_authority_negotiation`; `region_id: region_r6_gristmarket_ward` (`R6 Gristmarket Ward`); `region_secondary: permission_before_transformation` (`R5 Glasswing Ordinal`, whose boot residue arrives here for recovery).
- `region_role_local`: surgical institution that can preserve a body's function while failing to preserve the patient's social identity.
- `silhouette_body_class`: thin, tall limbed construct with a bright incision line and a folded surgical coat.
- `baseline_action`: `ACT-IE-SCALPEL-DRAW`, `ONE_ENEMY`, one turn; applies `scarline` to the next recovery effect.
- `signature_action`: `ACT-IE-SUTURE-LINE`, `ONE_ENEMY`, one turn; targets one patient body on the player side and binds that patient's recovery to the envoy through the `linked_actor` role, redirecting one treatment payload. The patient is not a target mode; it is the actor this action was aimed at.
- `telegraph`: a red-white thread appears between the target and the envoy's hand, and one treatment icon dims; two ticks.
- `valid_counters`: cauterize/cleanse the line, target the envoy instead of the patient, sever the consent record, use a valid surgical license, or Break the line at its marked seam.
- `invalid_counters`: healing through the line, attacking the patient after the thread commits, or treating the envoy's body as a separate person without resolving consent.
- `break_policy`: `marked`; the signature is Breakable, but the phase that follows is `unbreakable` until the patient or NPC conversion chooses a valid resolution.
- `statuses`: `scarline`, `recovery_lock`, `linked`, `recovery_window`.
- `phases`: incision; consent audit at the first redirected recovery; closure at the source-record threshold, where the line cannot be Broken and must be cauterized or accepted.
- `summons_linked_actors`: the envoy links to one organ lobe and one clinic record; cutting the line leaves the envoy alive but unable to redirect treatment.
- `resource_reward_effect`: victory grants `surgical_license x1`; noncombat consent grants `consent_charter x1`; failure consumes one medicine resource and advances `CL-PER`.
- `aftermath`: a healed character can return with a valid body, a different employment/relationship history, or an unrecognized organ voice.
- `clock_links`: immediate `CL-PER +1`; delayed `CL-REC +1` when the surgery record replaces the person's testimony.

### FAM-ARPG-12 — Kinward Mob

- `seed_ids`: `S005`, `S032`, `S033`, `S106`.
- `region_role`: `resource_allocation`; `region_id: region_r2_siltglass_commons` (`R2 Siltglass Commons`), where `R2-02 Clone Meal Plan` and `R2-04 Same Body Census` make identical bodies one consumption and one census line; `region_secondary: permission_before_transformation` (`R5 Glasswing Ordinal`'s Support Registry, which issues the labour role the census counts).
- `region_role_local`: mass-clone deployment unit; identical bodies are treated as one labor category until one is socially distinct.
- `silhouette_body_class`: group of identical small humanoids with a shared arm-angle and one visibly delayed copy.
- `baseline_action`: `ACT-KM-MATCHED-SWIPE`, `ONE_ENEMY`, one turn; applies `linked` and shares a small status pulse across the group.
- `signature_action`: `ACT-KM-QUORUM-STRIKE`, `ALL_ENEMIES`, one turn; stronger while every clone remains linked and one visible copy remains an outlier.
- `telegraph`: all copies raise the same arm, one copy hesitates, and a shared outline shows the link; two ticks.
- `valid_counters`: mark the outlier, sever the link, use `identity_token`, interrupt the shared scheduler, attack only after consensus is broken, or negotiate a noncombat separation.
- `invalid_counters`: hitting every clone in sequence, choosing one target without changing the link, or trying to save all copies with a single blanket action.
- `break_policy`: `link`; the group owner is not Breakable while consensus is intact. Breaking the link exposes a punish window on the outlier.
- `statuses`: `linked`, `outlier`, `consensus`, `recovery_window`.
- `phases`: deployment; divergence when one copy receives a unique status; quorum at the first link break, where the group signature becomes `unbreakable` until a second link is cut.
- `summons_linked_actors`: four clones plus a Record Sponge share the census record; the outlier can survive group death as an NPC or repeated challenge.
- `resource_reward_effect`: victory grants `identity_token x1` and `recovered_note x1`; escape preserves one clone's name but consumes one `entry_token`; noncombat redistribution grants one relationship token and raises `CL-REC`.
- `aftermath`: a clone's legal name, employment, or recognized relationship changes independently of the body group.
- `clock_links`: immediate `CL-PER +1`; delayed `CL-RES -1` only when the group is separated before the next deployment.

### FAM-ARPG-13 — Aggregate Grazer

- `seed_ids`: `S033`, `S061`, `S062`, `S064`, `S066`.
- `region_role`: `resource_allocation`; `region_id: region_r2_siltglass_commons` (`R2 Siltglass Commons`).
- `region_role_local`: ecological consequence of mass recovery; identical small bodies consume the resource base faster than the institution can classify them. `R2-05 Harvest Failure` is where they breed.
- `silhouette_body_class`: low, many-part swarm with repeated jaw silhouettes and one visible resource anchor.
- `baseline_action`: `ACT-AG-CROP-BITE`, `ONE_ENEMY`, one turn; consumes one healing, water, or attention resource and applies `consumed`.
- `signature_action`: `ACT-AG-BLOOM-FEAST`, `ALL_ENEMIES`, one turn; converts available player resources into `overfed` stacks for the swarm.
- `telegraph`: the ground darkens under the swarm, resource icons drain toward the center, and the next recovery pulse is visibly redirected; one tick.
- `valid_counters`: deny the named resource, isolate the anchor, use cleanup_token, force the swarm to split, or Break the anchor after a feast.
- `invalid_counters`: consuming healing while the swarm is linked, chasing the entire swarm, or waiting for ecological recovery during the encounter.
- `break_policy`: `resource`; Break is available only after one feast or after the anchor has consumed a named resource.
- `statuses`: `consumed`, `overfed`, `exhausted`, `recovery_window`.
- `phases`: grazing at start; feast at the first resource loss; scarcity at the third resource loss, where the anchor becomes `unbreakable` until the resource route is changed.
- `summons_linked_actors`: swarm members share an ecological anchor; destroying visible grazers leaves the anchor and one `exhausted` residue actor.
- `resource_reward_effect`: victory grants `harvest_residue x1` and restores one local resource step; escape spends one `CL-RES` step; noncombat rationing spends party supply but preserves the route.
- `aftermath`: the region's food/water/attention economy and NPC settlement schedule change on revisit.
- `clock_links`: immediate `CL-RES +1` for every consumed resource; delayed `CL-RES +1` again if the anchor survives into a second visit.

### FAM-ARPG-14 — Coldwater Pilgrim

- `seed_ids`: `S062`, `S063`, `S064`, `S065`, `S068`.
- `region_role`: `resource_allocation`; `region_id: region_r2_siltglass_commons` (`R2 Siltglass Commons`).
- `region_role_local`: survival guide whose safe-water knowledge is distributed across many people and cannot be replaced by one hero's certainty.
- `silhouette_body_class`: tall wrapped pilgrim with a sealed water jar and a broad, cold shoulder line.
- `baseline_action`: `ACT-CP-CHILL-TOUCH`, `ONE_ENEMY`, one turn; applies `chilled` and reduces one water-dependent recovery.
- `signature_action`: `ACT-CP-SAFE-WATER-DENIAL`, `ALL_ENEMIES`, one turn; applies `thirst_locked` and records the denied route as unsafe.
- `telegraph`: frost travels from the jar to the nearest resource line, a route mark turns blank, and the target's water icon loses focus; two ticks.
- `valid_counters`: present `water_manifest`, use a verified alternate route, use `heat_token`, sever the jar, cleanse `chilled`, or Break the denial after the route is marked.
- `invalid_counters`: using a water item while `thirst_locked`, standing still and defending, or following the pilgrim's claim without checking the route.
- `break_policy`: `marked`; the denial is Breakable only after the unsafe route is recorded. The resulting `recovery_window` is a resource window, not a damage multiplier.
- `statuses`: `chilled`, `thirst_locked`, `verified_safe`, `recovery_window`.
- `phases`: warning; route denial at the first resource lock; survival calculation at the second lock, where the pilgrim becomes `unbreakable` until an alternate source is verified.
- `summons_linked_actors`: the jar, reservoir record, and local guide network are linked; the guide can survive as an NPC or become a `FAM-ARPG-14` boss variant.
- `resource_reward_effect`: victory grants `water_manifest x1`; noncombat verification restores one `CL-RES` step and spends one `clear_channel`; failure consumes one water reserve.
- `aftermath`: a previously safe route is marked unsafe, a settlement changes rationing, or a guide's expertise is recognized in a new role.
- `clock_links`: immediate `CL-RES +1`; delayed `CL-PER +1` if an NPC loses access to care because of the route denial.

### FAM-ARPG-15 — Audit Ox

- `seed_ids`: `S056`, `S058`, `S060`, `S065`.
- `region_role`: `boundary_crown_precedence`; `region_id: region_r7_hollow_orchard` (`R7 The Hollow Orchard`); `region_secondary: hub_registration_ration_appeal` (`H0 The Undersign Exchange`, whose market and counter set the price the wall audits).
- `region_role_local`: vertical tax/audit system that turns passage through a market or an outer boundary into a living debt calculation.
- `silhouette_body_class`: heavy, square-backed quadruped with ledger slabs for flanks and a low horned head.
- `baseline_action`: `ACT-AO-TALLY-TRAMPLE`, `ONE_ENEMY`, one turn; applies `audited` and locks one resource category until resolution.
- `signature_action`: `ACT-AO-AUDIT-CHARGE`, `ONE_ENEMY`, two ticks; locks a command category, then resolves guaranteed hit unless the target changes state.
- `telegraph`: hoof stamps create ledger columns, the chosen category prints above the target, and the Ox lowers its head; one tick before commitment.
- `valid_counters`: Dodge, marked Break, pay/present an `audit_credit`, change target, use a route witness, or escape before the charge locks.
- `invalid_counters`: Guard-only, standing still, chasing after the lock, or using a damage item without an audit counter.
- `break_policy`: `marked`; the charge is Breakable during its marked column, but the baseline trample is unbreakable. Once `audited`, a new charge is `phase_locked` until the record is settled.
- `statuses`: `audited`, `charge_lock`, `recovery_window`, `recorded`.
- `phases`: toll; audit at the first locked category; collection at the second lock, where the Ox is `unbreakable` until a witness or alternate route resolves the debt.
- `summons_linked_actors`: charge columns, a FAM-ARPG-04 claim actor, and a FAM-ARPG-17 boundary writ are linked; a claim can survive the Ox and continue a later audit.
- `resource_reward_effect`: victory grants `audit_credit x1`; noncombat payment grants `entry_token x1` but raises `CL-REC`; failure adds one debt step and does not erase the player's learned route.
- `aftermath`: the market, archive, or region's access price changes; a debt can follow the player or an NPC.
- `clock_links`: immediate `CL-INST +1`; delayed `CL-RES +1` if the debt is not paid before the next region.

### FAM-ARPG-16 — Static Tithe

- `seed_ids`: `S047`, `S048`, `S050`, `S114`.
- `region_role`: `intervention_scheduling`; `region_id: region_r3_bellhouse_hospice` (`R3 Bellhouse Hospice`); `region_secondary: hub_registration_ration_appeal` (`H0 The Undersign Exchange`, whose `Crier Office` is where the forwarded message becomes a public record).
- `region_role_local`: asynchronous emergency signal on the Faith Engineering unit's relay network; it treats every message as a command until the institution can classify it.
- `silhouette_body_class`: airborne spark cluster with a small hanging speaker-shape and a visible slot ring.
- `baseline_action`: `ACT-ST-NOISE-LASH`, `ONE_ENEMY`, one turn; applies `noised` and delays the next command choice.
- `signature_action`: `ACT-ST-SCHEDULER-TITHE`, `ALL_ENEMIES`, one turn; removes one action slot and raises the next attack gauge.
- `telegraph`: the speaker-shape inhales, a group-chat-like pulse crosses the combat band, and one command category dims; one tick.
- `valid_counters`: silence, no-turn action, clear channel, feed a decoy command, change target, or Break after the tithe is paid.
- `invalid_counters`: repeatedly using the same timed command, waiting for the gauge, or attacking the airborne body without a source route.
- `break_policy`: `marked`; the tithe is Breakable only after it has stolen a slot, and the source relay remains active.
- `statuses`: `noised`, `slot_stolen`, `silenced`, `recovery_window`.
- `phases`: notice; broadcast at the first stolen slot; emergency at the second slot, where the relay becomes `phase_locked` until cleared or disconnected.
- `summons_linked_actors`: relay nodes and a Stalled Bell are linked; a relay can remain after the visible cluster dies and continue public-record pressure.
- `resource_reward_effect`: victory grants `clear_channel x1`; escape spends one `latency_key`; noncombat muting grants `latency_key x1` but advances `CL-REC`.
- `aftermath`: NPC communication, emergency service, and the player's command rhythm differ on revisit.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-PER +1` when an NPC cannot interrupt an emergency signal.

### FAM-ARPG-17 — Seam Bailiff

- `seed_ids`: `S010`, `S012`, `S041`, `S111`.
- `region_role`: `boundary_crown_precedence`; `region_id: region_r7_hollow_orchard` (`R7 The Hollow Orchard`).
- `region_role_local`: boundary-wall enforcement process that treats a safety manual as a valid category even when the wall has failed.
- `silhouette_body_class`: wide vertical construct shaped like a braced doorway, with a chalk-white seam and a low moving base.
- `baseline_action`: `ACT-SB-CLAMP`, `ONE_ENEMY`, one turn; applies `writ` and reduces route access.
- `signature_action`: `ACT-SB-BOUNDARY-WRIT`, `ONE_ENEMY`, one turn; writes the crossing party onto the `route` role, marking the current exit and converting a legal route into `boundary_locked`. The writ is a `record` and the chalk anchor is a `linked_actor`; neither is a target mode.
- `telegraph`: chalk lines appear around the route, a safety-manual symbol closes, and the exit's affordance becomes a hard boundary; two ticks.
- `valid_counters`: open an alternate route, present a source proof, evacuate a linked actor, apply a noncombat correction, or complete the required clock condition.
- `invalid_counters`: Break-only solutions, brute force, Guard, or attacking the construct while the route is the true target.
- `break_policy`: `unbreakable`; the body is a legal enforcement layer. A valid counter changes its mandate or route, not its health.
- `statuses`: `writ`, `boundary_locked`, `registration_lock`, `recovery_window`.
- `phases`: local clamp; audit at the first `writ`; outer seam at the route proof threshold, where the construct becomes `phase_locked` until an alternate route or institutional mandate is changed.
- `summons_linked_actors`: chalk anchors and FAM-ARPG-16 signal relays are linked; anchors can remain after the body is destroyed and continue locking routes.
- `resource_reward_effect`: victory grants `seam_key x1`; escape uses one `seam_key` or loses one route option; noncombat correction grants `seam_key x1` and raises `CL-REC`.
- `aftermath`: route availability, border permits, and the local definition of safe passage change on revisit.
- `clock_links`: immediate `CL-INST +1`; delayed `CL-CROWN +1` when the wall's category is accepted as a higher authority.

### FAM-ARPG-18 — Living Ledger Avatar

- `seed_ids`: `S001`, `S002`, `S052`, `S059`, `S060`, `S099`, `S116`.
- `region_role`: `translation_precedence`; `region_id: region_r4_crownwell_archive` (`R4 Crownwell Archive`).
- `region_role_local`: `Record Office` projection above the public halls, representing the Crown of Continuance as a record that can interpret bodies, titles, and operators without explaining itself. `R4-07 Operator Trial` is its court and `G8` is its only precedence input.
- `silhouette_body_class`: tall mirrored composite biped made of offset sheets, a blank face plate, and a floating vertical record spine.
- `baseline_action`: `ACT-LA-COPY-STEP`, `ONE_ENEMY`, one turn; copies one active status or command priority.
- `signature_action`: `ACT-LA-NAME-TRANSFER`, `ONE_ENEMY`, one tick; redirects one committed effect away from the focused projection and into the `record` role, applying `name_transferred`. The source record is the encounter's true target; it is not a target mode.
- `telegraph`: sheets fan into duplicate outlines, the player's name appears on a higher page, and the target line points away from the body; two ticks.
- `valid_counters`: expose the source record, sever the copied link, present root evidence, use a different recognized name, silence the projection, or Break the link after the transfer.
- `invalid_counters`: killing only a projection, using the same source name, or assuming the copied body is the true actor.
- `break_policy`: `link`; the projection is not Breakable while its source record is intact. A source exposure creates a damage/punish window on the copy.
- `statuses`: `copied`, `redirected`, `name_transferred`, `registration_lock`, `recovery_window`.
- `phases`: scan; replication at the first copied status; refusal at the root-record threshold, where the projection is `unbreakable` until the player chooses a truth, authority, or continuity route.
- `summons_linked_actors`: the Crownwell Archive record, Return Usher clerks, Tally-Skin copies, and a delayed Bell are linked; the archive record remains the true target after every visible copy falls.
- `resource_reward_effect`: victory grants `root_record_fragment x1` and one route/relationship axis; escape leaves the current record active and advances `CL-CROWN`; noncombat appeal grants `recovered_note x1` but does not resolve the Crown layer.
- `aftermath`: the player, an NPC, or a region is recognized by a changed name/category; revisit variants reflect the chosen authority, truth, and continuity axes.
- `clock_links`: immediate `CL-CROWN +1`; delayed `CL-REC +1` and `CL-PER +1` according to whether the record or the person is treated as the survivor.

### FAM-ARPG-19 — Grading Wall

- `seed_ids` (magic supplement, written separately from the core range): `S121`, `S133`, `S150`, `S153`, `S155`, `S157`, `S160`.
- `region_role`: `magic_training_craft_labor`; `region_id: region_r8_folding_school` (`R8 The Folding School`); `region_secondary: permission_before_transformation` (`R5 Glasswing Ordinal`, whose `R5-11 Rigid Fold`/`R5-12 Void Cut` supply the medium, the fold count, and the blade structure this wall grades), and `boundary_crown_precedence` (`R7 The Hollow Orchard`, whose unfinished `R7-09` cut is the same maker's evidence).
- `region_role_local`: the `Cut Chamber` grading wall - a curriculum office instrument, not a creature of the craft. It measures what a body still holds after a cast, refuses a shape that does not match the medium it was handed, and files the refusal as a grade. It owns the three pressures the magic layer needs an authored counter for: concentration overflow, failed fold, and portal contract pressure. It is not a school mascot, not a rival mage, and not a spell of its own.
- `silhouette_body_class`: a low, broad, wall-mounted armature of stacked fold trays with one cantilevered clamp arm, a hanging score slate, and a residue basin at its base. No face, no hands, no legs. It reads as furniture that has been grading for longer than anyone can date.
- `baseline_action`: `ACT-CGW-GRADE-MARK`, `ONE_ENEMY`, one turn; adds one `concentration_load` stack and one `medium_residue` stack to the target, and writes the target's last committed craft category into the `record` role `record:residue ledger`.
- `signature_action`: `ACT-CGW-FOLD-VERDICT`, `ALL_ENEMIES`, one turn, `lifecycle: charge`; a marked charge that applies `misfolded` to the highest-priority valid target and files the residue ledger. If that target already holds `medium_residue 2`, the strike instead applies `overflowed` and spends one `disperser_charge` to write the `resource_node` role `resource_node:node disperser stock` - the wall pays for its own mistake out of the node's powder.
- `counter_action`: `ACT-CGW-DISPERSE-READING`, `SELF`, `turn_cost=0`; a no-turn dispersal action that removes one `concentration_load` stack and one `medium_residue` stack from the acting side and records one `concentration_sample` with a `provenance` of the current node. It costs MP, not a slot, and it does not move the scheduler clock. It is the family's no-turn counter axis and the only action in this file that both removes a status and produces a world measurement.
- `telegraph` (four channels, above 01 §11.3's minimum of two): the clamp arm opens and holds a blank fold shape, the score slate flips to an empty line, a visible residue film rises in the basin, and one audio channel drops a single cutting tick. Two ticks before commitment.
- `valid_counters`: Break the marked verdict; run `ACT-CGW-DISPERSE-READING` while `concentration_load` is below its threshold; present the `medium_blank` or `fold_sheet` that matches the named `shape_or_pattern`; accept the alternate shape through a noncombat `R8-05 Fold Failure Hearing`; sever the `record:residue ledger` source; silence the wall; or open a `circulation_slot` route and pay the neighbour's cost. `contract_bound` pressure is answered by filing or refusing the contract, never by damage.
- `invalid_counters`: renaming the spell, renaming the shape, or treating the refusal as a status to grind down; attacking only the clamp arm while the residue ledger is the true target; bringing a medium that does not match the named shape; adding a new action, phase trigger, or status op to solve it; treating `concentration_load` as a damage multiplier.
- `break_policy`: `marked` for the verdict - Breakable only during the marked charge window, and the resulting `recovery_window` is the readable punish. `phase_locked` in the final phase until the residue ledger or the contract document is filed. The clamp arm alone is `unbreakable` and is never the true target. The baseline grade mark is `unbreakable` and the family still supplies four other counter axes.
- `statuses`: `concentration_load`, `medium_residue`, `misfolded`, `overflowed`, `contract_bound`, `silenced`, `recovery_window`. `contamination` and `ink_bloom` are not used here: residue records handling, not transfer, and reusing the contamination transfer rule would make the two indistinguishable.
- `phases`: 
  - P1 Grading - the wall records the last committed craft category and adds the first residue stack.
  - P2 Residue, at `medium_residue 2` - the `Cut Chamber` residue record links to the wall and becomes severable, and the clamp arm is exposed for exactly one Break.
  - P3 Overflow, at `medium_residue 3` or on the first `overflowed` instance - the basin writes `resource_node:node disperser stock` and the wall becomes `phase_locked` until the residue record is filed or a disperser route is opened.
  - P4 Contract Press, reached only when the encounter attaches an unresolved portal obligation - the wall is `unbreakable` and one `contract_bound` instance is applied until the contract is filed, refused before commitment, or named as inside or outside the `Crown Protocol` at `G8`. A contract does not resolve itself and the obligation does not tick down.
- `summons_linked_actors`: the `Cut Chamber` residue record (`role: true_actor`, `survive` after the wall dies), one `FAM-ARPG-02` recording clerk's slate (`role: support`, `die_with` the wall), and one `FAM-ARPG-05` latency relay (`role: pressure`, `survive`) are linked. The residue record may reappear in `R5` as recoverable `R5-03 Repair Bench` stock, and the relay keeps a `noised` route state if the wall falls with it attached.
- `resource_reward_effect`: victory grants `craft_credit x1` and files the residue ledger as the `provenance` of one `concentration_sample`; escape keeps one `medium_residue` stack and spends `lineage_token x1` to reach `E18`; noncombat `R8-05` filing spends `craft_credit x1` and writes the school record without the sample; failure leaves one `overflowed` body-load mark, consumes the student's credit, and advances `CL-PER`. `contract_tally` is written as a debt key with no amount and is never spent here.
- `aftermath`: the `Cut Chamber` wall keeps the failed fold; the student's `craft credit` record, the `R4` glossary slot, and the `R5` labour-hour record then read three different values for the same cast; revisit variants are the filed grade, the dispersed residue, the recovered medium at `R5-03`, and the unresolved contract.
- `clock_links`: immediate `CL-PER +1` and, as a separate transaction only, `CL-RES +1` when the basin spends disperser stock; delayed `CL-INST +1` when the school files the residue as a category, and `CL-CONT +1` only on a separate transaction when the residue is dispersed into a neighbouring node. `CL-CROWN` never moves from this family; a portal contract feeds `CL-CROWN` as interpretation input through `G8` and nothing else.

## 4. Authored encounter catalog

### ENC-ARPG-01 — The Intake Stamp

- `type`: field gate; `seed_ids`: `S009`, `S011`, `S019`, `S044`, `S056`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`); `region_secondary: hub_registration_ration_appeal` (`H0 The Undersign Exchange`, whose Exchange Registrar stamps the arrival the Return Registry then disputes).
- `region_role_local`: the Return Registry decides whether a returning body is a person, a record, or a resource before it can cross.
- `roster`: FAM-ARPG-01 x2, FAM-ARPG-02 x1; `target_priority`: active seal-bearer, marked Tally-Skin, Return Usher.
- `activation`: crossing the gate or selecting the dispute interaction; `escape`: allowed before the first stamp; `noncombat`: a valid seal bypasses combat.
- `baseline_signature_telegraph`: Tally-Skin uses `Tally Pin`; the Usher uses `Name Call`; black stitch lines, a blank name plate, and one scheduler tick announce the signature actions.
- `valid_counters`: present a valid seal, Dodge, cleanse, Break the marked sweep, or sever the gate record.
- `invalid_counters`: raw damage, repeated attacks after the stamp, or attacking while the Usher has `registration_lock`.
- `break_policy`: `marked` for the sweep; `accumulator` for the Usher; baseline pin is unbreakable.
- `statuses`: `recorded`, `redaction_mark`, `named`, `registration_lock`, `recovery_window`.
- `phases`: P1 two Tally-Skins pin; P2 the first successful stamp links the Usher to the gate record; P3 the gate record is exposed or the encounter resolves.
- `summons_linked_actors`: no summons; the gate record is the true linked actor and can be removed by noncombat proof.
- `resource_reward_effect`: victory grants `ink_credit x1` and `entry_token x1`; escape grants no token; noncombat grants `entry_token x1` and advances `CL-REC`.
- `aftermath`: stamp state, registrar relationship, and border access are written to the R1 `Return Registry`; a revisit has accepted, disputed, and erased variants.
- `clock_links`: immediate `CL-INST +1`, `CL-REC +1`; delayed `CL-CROWN +1` if the record outlasts the person.
- `encounter_outcomes`: `V` accepted registration and route; `E` leave with the red mark unresolved; `F` reset at the gate checkpoint and add one `CL-CONT`; `N` valid seal opens the route without combat.

### ENC-ARPG-02 — The Spill Index

- `type`: field contamination gate; `seed_ids`: `S017`, `S018`, `S024`, `S031`, `S064`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`).
- `region_role_local`: a failed recovery archive has flooded the corridor and turns every safe action into a record of who handled the leak.
- `roster`: FAM-ARPG-03 x2, FAM-ARPG-05 x1, FAM-ARPG-16 x2; `target_priority`: linked_actor:source knot, Bell, linked_actor:signal relay, visible bloom.
- `activation`: entering the wet archive or choosing to open the spill record; `escape`: sealed side route; `noncombat`: quarantine decision.
- `baseline_signature_telegraph`: `Seep` and `Resonance` establish the baseline; `Contagion Bloom` and `Delay Lattice` are signature actions. Wax lines, a missing clock tick, and a stolen action slot telegraph commitment.
- `valid_counters`: quarantine, isolate, cleanse/burn, silence, a no-turn purge, or Break the exposed knot after two contamination stacks.
- `invalid_counters`: chasing the moving fringe, healing in the spill, or waiting for `ink_bloom` to expire.
- `break_policy`: `resource` for the knot; the Bell and signal relay are unbreakable until their sources are disconnected.
- `statuses`: `contamination`, `ink_bloom`, `delayed`, `noised`, `slot_stolen`, `recovery_window`.
- `phases`: P1 seep; P2 at `ink_bloom 2`, the Bell adds delay; P3 at `ink_bloom 3`, two Static Tithes are linked and the knot becomes the true target.
- `summons_linked_actors`: two Tithes spawn at P3; the spill source remains after all visible actors die; the Bell relay remains until disconnected.
- `resource_reward_effect`: victory grants `harvest_residue x1` and lowers `CL-CONT` by one; escape spends one `entry_token`; noncombat quarantine spends one `entry_token` and writes a clean-room state.
- `aftermath`: corridor contamination, resource access, and registrar behavior change; revisit can show a quarantined, burning, or normalized archive.
- `clock_links`: immediate `CL-CONT +1`, `CL-INST +1`; delayed `CL-RES +1` if the source survives.
- `encounter_outcomes`: `V` seal the knot and clear the immediate transfer; `E` reach the side route with `ink_bloom 1`; `F` reset the gate and retain the contamination clock; `N` quarantine, spend the token, and avoid the combat reward.

### ENC-ARPG-03 — Complaint Queue

- `type`: field court gate; `seed_ids`: `S012`, `S039`, `S046`, `S048`, `S056`.
- `region_role`: `hub_registration_ration_appeal`; `region_id: region_h0_undersign_exchange` (`H0 The Undersign Exchange`); `region_secondary: boundary_crown_precedence` (`R7 The Hollow Orchard`, where the same writ is a settlement record).
- `region_role_local`: a lower-court intake office treats the player's arrival and every later injury as a claim that can be filed. `H0-07 Paper Wardens` is the same office after it starts stamping operationally.
- `roster`: FAM-ARPG-04 x1, FAM-ARPG-06 x2; `target_priority`: Grievance Ward, active Contract Lance, player carrying a claim.
- `activation`: accepting or refusing the intake form; `escape`: leave before the first claim; `noncombat`: mediation with evidence.
- `baseline_signature_telegraph`: `Counterclaim` and `Contract Lance` are the signatures; the Ward's shield opens as a reception window while the lance completes a checklist line.
- `valid_counters`: do not attack, present evidence, use a non-damaging status, show a permit, sever the claim, or Break the Ward after its grievance meter fills.
- `invalid_counters`: repeated damage, attacking before intake closes, or ignoring the target's sealed category.
- `break_policy`: `accumulator` for the Ward; `marked` for a lance; judgment is `phase_locked`.
- `statuses`: `grievance_debt`, `mirrored`, `sealed`, `verified`, `audited`, `recovery_window`.
- `phases`: P1 intake; P2 cross-examination after the first stored payload; P3 judgment after the second claim, with the Ward unbreakable until evidence or permit resolution.
- `summons_linked_actors`: two Lancer enforcers link to the public claim record; a claim copy survives the Ward and can be encountered in a later audit.
- `resource_reward_effect`: victory grants `petition_seal x1`; noncombat grants `permit_fragment x1`; escape leaves the claim open and advances `CL-REC`; failure adds one labor/debt step to `CL-INST`.
- `aftermath`: the player or an NPC receives a duty, fee, or denied-access record that changes later service and route state.
- `clock_links`: immediate `CL-REC +1`, `CL-INST +1`; delayed `CL-RES +1` if the unpaid claim becomes a recurring cost.
- `encounter_outcomes`: `V` invalidate the claim by making the Ward answer its own record; `E` leave with the claim active; `F` reset to intake with the claim clock retained; `N` settle, pay, or reject the form without combat.

### ENC-ARPG-04 — Translation Drift

- `type`: field research route; `seed_ids`: `S069`, `S070`, `S072`, `S073`, `S078`.
- `region_role`: `translation_precedence`; `region_id: region_r4_crownwell_archive` (`R4 Crownwell Archive`).
- `region_role_local`: the Translation Tribunal permits partial terms to become local rules when staff cannot keep the original and the translated categories separate.
- `roster`: FAM-ARPG-07 x3, FAM-ARPG-08 x1, FAM-ARPG-09 x1; `target_priority`: central moth, category hound, record:source record, sponge.
- `activation`: crossing the untranslated archive; `escape`: carry a visible glyph out; `noncombat`: read the source with an NPC translator.
- `baseline_signature_telegraph`: letter bites, chase marks, and undo bites establish the baseline; Translation Storm, Category Bite, and Undo Bite are signatures. Incomplete glyphs, a filing line, and a repeated prior command form the tell.
- `valid_counters`: silence, source anchor, isolate, retag, sever the scent, `recovered_note`, or Break the central moth after commitment.
- `invalid_counters`: reading the document again, chasing one moth, or replaying a command after the sponge has removed it.
- `break_policy`: `marked` for the central moth; `link` for the hound; the sponge is `marked` only after it commits.
- `statuses`: `translated`, `misnamed`, `scented`, `amnesia`, `recorded`, `recovery_window`.
- `phases`: P1 one syllable; P2 at two surviving moths, a new label displaces the target; P3 at the source exposure, the blank page locks the swarm's authority.
- `summons_linked_actors`: hound scent, source term, and Sponge record link together; the Sponge can remain after the visible route is abandoned.
- `resource_reward_effect`: victory grants `untranslated_glyph x1`; escape grants `recovered_note x1` if a source fragment is carried; noncombat grants `definition_token x1` and changes one local term.
- `aftermath`: a region title, NPC role, or command label has a different local meaning on revisit.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-CROWN +1` if the translated law is accepted by an institution.
- `encounter_outcomes`: `V` capture the source term and restore the correct label; `E` preserve a fragment but leave the route mistranslated; `F` reset labels and retain the public record clock; `N` accept a translated term with a known category cost.

### ENC-ARPG-05 — Triage Conflict

- `type`: field clinic encounter; `seed_ids`: `S004`, `S028`, `S029`, `S030`, `S087`.
- `region_role`: `organ_authority_negotiation`; `region_id: region_r6_gristmarket_ward` (`R6 Gristmarket Ward`).
- `region_role_local`: the Gristmarket Clinic's organs disagree about treatment priority while staff treat the disagreement as a scheduling problem.
- `roster`: FAM-ARPG-10 x1, FAM-ARPG-11 x2; `target_priority`: active organ voice, central pulse, linked_actor:incision seam, envoy.
- `activation`: entering the treatment lane or selecting a body-part request; `escape`: withdraw consent; `noncombat`: negotiate which voice has authority.
- `baseline_signature_telegraph`: Pulse and Scalpel Draw are baselines; Authority Chorus and Suture Line are signatures. Unequal lobe rhythms, a complaint, and a dimming recovery line telegraph them.
- `valid_counters`: silence one voice, target the weak lobe, sever the consent link, use a valid license, cauterize, or Break the marked suture.
- `invalid_counters`: all-target healing, attacking every lobe, or treating the envoy as a separate patient without consent resolution.
- `break_policy`: `link` for the Chorus; `marked` for the Suture Line; the closure phase is unbreakable until the patient chooses a resolution.
- `statuses`: `organ_tension`, `voice_lock`, `linked`, `scarline`, `recovery_lock`, `recovery_window`.
- `phases`: P1 consultation; P2 disagreement at two tension stacks; P3 arbitration at three stacks, with a direct noncombat choice replacing the combat completion check.
- `summons_linked_actors`: four organ lobes and two Envoys link to one consent record; a severed lobe can remain as a patient on revisit.
- `resource_reward_effect`: victory grants `consent_charter x1`; noncombat grants `surgical_license x1` but raises `CL-PER`; escape leaves one organ unresolved; failure consumes one medicine reserve.
- `aftermath`: treatment, relationship, employment, and body authority states can diverge for the same character.
- `clock_links`: immediate `CL-PER +1`; delayed `CL-REC +1` if the clinic's answer overwrites the patient's.
- `encounter_outcomes`: `V` silence or satisfy the dominant organ; `E` withdraw with one unresolved voice; `F` reset the clinic and retain the personal pressure; `N` choose a negotiated treatment without combat.

### ENC-ARPG-06 — The Clone Census

- `type`: field service/registry encounter; `seed_ids`: `S005`, `S032`, `S033`, `S106`.
- `region_role`: `resource_allocation`; `region_id: region_r2_siltglass_commons` (`R2 Siltglass Commons`); `region_secondary: permission_before_transformation` (`R5 Glasswing Ordinal`'s Support Registry, which issues the labour role the census counts).
- `region_role_local`: `R2-04 Same Body Census` counts cloned bodies as labor capacity until one copy receives a unique social history.
- `roster`: FAM-ARPG-12 x3, FAM-ARPG-09 x1, FAM-ARPG-02 x1; `target_priority`: outlier clone, record:census record, sponge, Usher.
- `activation`: entering a deployment queue or challenging a name assignment; `escape`: release one clone before consensus; `noncombat`: redistribute names.
- `baseline_signature_telegraph`: Matched Swipe and Drain Note are baselines; Quorum Strike and Undo Bite are signatures. Shared arm angles, one delayed copy, and a repeated prior sound form the tell.
- `valid_counters`: mark the outlier, sever the link, use `identity_token`, interrupt the shared scheduler, or choose a noncombat name redistribution.
- `invalid_counters`: attacking all clones in sequence, using one blanket heal, or leaving the census without deciding which copy is recognized.
- `break_policy`: `link`; no owner Break while consensus is intact. One link break creates a punish window on the outlier.
- `statuses`: `linked`, `outlier`, `consensus`, `amnesia`, `registration_lock`, `recovery_window`.
- `phases`: P1 deployment; P2 divergence after the first unique status; P3 quorum after one link break, where the second link is the only valid Break target.
- `summons_linked_actors`: three clones, one Sponge, and the census record share a link; the outlier can survive as an NPC or repeat challenger.
- `resource_reward_effect`: victory grants `identity_token x1` and `recovered_note x1`; escape preserves one name but spends one `entry_token`; noncombat grants one relationship token and raises `CL-REC`.
- `aftermath`: one clone has a legal name, employment, or relationship distinct from the original on revisit.
- `clock_links`: immediate `CL-PER +1`; delayed `CL-RES -1` if separation prevents the next deployment, otherwise `CL-RES +1`.
- `encounter_outcomes`: `V` sever the quorum and correct the census; `E` release one copy and leave the group unresolved; `F` reset the queue with the identity clock retained; `N` redistribute roles and names without combat.

### ENC-ARPG-07 — The Siltglass Toll

- `type`: field survival encounter; `seed_ids`: `S061`, `S062`, `S064`, `S065`, `S068`.
- `region_role`: `resource_allocation`; `region_id: region_r2_siltglass_commons` (`R2 Siltglass Commons`).
- `region_role_local`: a settlement's shared water route is consumed by bodies that the census still counts as separate people.
- `roster`: FAM-ARPG-13 x4, FAM-ARPG-14 x1; `target_priority`: linked_actor:ecological anchor, route:water route, Pilgrim, grazer cluster.
- `activation`: entering the ration tunnel or using the common water cache; `escape`: ration exit; `noncombat`: redistribute the cache.
- `baseline_signature_telegraph`: Crop Bite and Chill Touch are baselines; Bloom Feast and Safe-Water Denial are signatures. Dark ground, resource drain, frost lines, and a blank route mark telegraph commitment.
- `valid_counters`: deny a named resource, isolate the anchor, cleanup_token, share water, present a manifest, sever the jar, or Break the anchor after a feast.
- `invalid_counters`: healing in the swarm, standing still, using a denied water item, or waiting for the resource to regenerate.
- `break_policy`: `resource` for the anchor; the Pilgrim is `phase_locked` during the final survival calculation.
- `statuses`: `consumed`, `overfed`, `chilled`, `thirst_locked`, `verified_safe`, `recovery_window`.
- `phases`: P1 grazing; P2 feast after one resource loss; P3 scarcity at the third loss, with the Pilgrim unbreakable until an alternate source is verified.
- `summons_linked_actors`: four grazers share one ecological anchor; the anchor survives visible death and can reappear on a later route; the Pilgrim links to the reservoir record.
- `resource_reward_effect`: victory grants `harvest_residue x1` and `water_manifest x1`; escape spends one party supply; noncombat rations restore one local resource step but costs one `CL-REC` entry.
- `aftermath`: ration schedules, settlement trust, and the safe/unsafe route map change on revisit.
- `clock_links`: immediate `CL-RES +1` per consumed resource; delayed `CL-PER +1` if the Pilgrim denies care to a resident.
- `encounter_outcomes`: `V` separate the anchor and verify a safe source; `E` leave through the ration exit with a water lock; `F` reset the tunnel and retain the collapse clock; `N` redistribute supplies and avoid combat.

### ENC-ARPG-08 — Signal Interference

- `type`: field service-route encounter; `seed_ids`: `S047`, `S048`, `S050`, `S072`, `S114`.
- `region_role`: `intervention_scheduling`; `region_id: region_r3_bellhouse_hospice` (`R3 Bellhouse Hospice`); `region_secondary: hub_registration_ration_appeal` (`H0 The Undersign Exchange`, whose `Crier Office` forwards the message), and `permission_before_transformation` (`R5 Glasswing Ordinal`, whose labour signals share the same relay).
- `region_role_local`: emergency communication has become a command system on the Faith Engineering unit's relay network, so every interruption can steal a scheduler slot.
- `roster`: FAM-ARPG-16 x3, FAM-ARPG-05 x1, FAM-ARPG-07 x1; `target_priority`: linked_actor:signal relay, Bell, central moth, visible tithe.
- `activation`: entering the service lane during an emergency or using the group signal; `escape`: mute the route; `noncombat`: forward a verified message.
- `baseline_signature_telegraph`: Noise Lash, Resonance, and Letter Bite are baselines; Scheduler Tithe, Delay Lattice, and Translation Storm are signatures. Speaker inhale, missing clock tick, and incomplete glyph telegraph each.
- `valid_counters`: silence, clear channel, no-turn purge, latency-key tuning, source anchor, feed a decoy command, or Break after slot theft.
- `invalid_counters`: repeating the same timed command, waiting for the gauge, or attacking the airborne body without a source route.
- `break_policy`: `marked` for paid Tithes; `phase_locked` for the Bell's hard lock; the Moth is `marked` only after translation commits.
- `statuses`: `noised`, `slot_stolen`, `delayed`, `resonant`, `translated`, `silenced`, `recovery_window`.
- `phases`: P1 notice; P2 broadcast at the first stolen slot; P3 emergency at the second slot, requiring a relay disconnect or a noncombat message.
- `summons_linked_actors`: three Tithes link to one relay and one Bell; the relay remains after the visible swarm is gone.
- `resource_reward_effect`: victory grants `clear_channel x1` and `latency_key x1`; escape spends one `latency_key`; noncombat forwarding grants `clear_channel x1` but advances `CL-REC`.
- `aftermath`: emergency service, NPC schedules, and the player's command rhythm change on revisit.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-PER +1` if a delayed person misses care or consent.
- `encounter_outcomes`: `V` disconnect the relay and restore one scheduler tick; `E` mute the route with one slot lost; `F` reset the lane and retain the public-record clock; `N` forward a verified message without combat.

### ENC-ARPG-09 — The Audit Crossing

- `type`: field border encounter; `seed_ids`: `S010`, `S056`, `S058`, `S060`, `S065`, `S111`.
- `region_role`: `boundary_crown_precedence`; `region_id: region_r7_hollow_orchard` (`R7 The Hollow Orchard`); `region_secondary: hub_registration_ration_appeal` (`H0 The Undersign Exchange`, whose market audit sets the price).
- `region_role_local`: a Boundary Survey wall audit charges for crossing and treats a safety category as stronger than a physical route.
- `roster`: FAM-ARPG-15 x1, FAM-ARPG-17 x1, FAM-ARPG-16 x2; `target_priority`: Audit Ox charge, record:active writ, linked_actor:signal relay, Bailiff.
- `activation`: crossing the border or refusing the audit_credit; `escape`: use a witness lane; `noncombat`: present a valid record.
- `baseline_signature_telegraph`: Tally Trample, Boundary Clamp, and Noise Lash are baselines; Audit Charge, Boundary Writ, and Scheduler Tithe are signatures. Ledger columns, chalk route, and signal dimming telegraph them.
- `valid_counters`: Dodge, marked Break, audit_credit, route witness, source proof, silence, or alternate route.
- `invalid_counters`: Guard-only, brute force, Break-spam against the Bailiff, or following the Ox after `charge_lock`.
- `break_policy`: `marked` for the Ox charge; `unbreakable` for the Bailiff; `marked` for a paid Tithe.
- `statuses`: `audited`, `charge_lock`, `writ`, `boundary_locked`, `noised`, `recovery_window`.
- `phases`: P1 toll; P2 audit at the first locked command; P3 collection at the second lock, requiring a witness, alternate route, or mandate change.
- `summons_linked_actors`: Ox columns, Bailiff chalk anchors, and two signal relays share the crossing record; an anchor remains if the Bailiff is bypassed.
- `resource_reward_effect`: victory grants `audit_credit x1` and `seam_key x1`; escape loses one route option; noncombat pays one `audit_credit` or spends `seam_key` and avoids the Ox reward.
- `aftermath`: border toll, local route, and NPC access change; a debt can follow the player into a later market.
- `clock_links`: immediate `CL-INST +1`, `CL-RES +1`; delayed `CL-CROWN +1` if the crossing record is accepted as sovereign.
- `encounter_outcomes`: `V` make the audit answer its own record; `E` use the witness lane with a debt; `F` reset at the border and retain the toll clock; `N` present a valid record or use a seam key.

### ENC-ARPG-10 — Archive Return Protocol

- `type`: field archive gate; `seed_ids`: `S001`, `S002`, `S052`, `S059`, `S060`, `S099`, `S116`.
- `region_role`: `translation_precedence`; `region_id: region_r4_crownwell_archive` (`R4 Crownwell Archive`).
- `region_role_local`: the archive above the public halls treats the player's return as a test of which name, role, or record has authority.
- `roster`: FAM-ARPG-18 x1, FAM-ARPG-02 x2, FAM-ARPG-01 x2; `target_priority`: record:source record, projection, active seal-bearer, Usher, Tally-Skin.
- `activation`: entering the upper archive or submitting a return record; `escape`: file an appeal through the lower route; `noncombat`: challenge the category in the document.
- `baseline_signature_telegraph`: Copy Step, Name Call, and Tally Pin are baselines; Name Transfer and Redaction Sweep are signatures. Duplicate outlines, a higher name page, and a stitch line telegraph commitment.
- `valid_counters`: expose the source record, sever the copied link, present a correct name, cleanse status, Break the copy link, or challenge the category.
- `invalid_counters`: killing only the projection, using the source name again, or accepting a copied command without checking the authority.
- `break_policy`: `link` for the Avatar; `marked` for the sweep; `accumulator` for the Usher.
- `statuses`: `copied`, `redirected`, `name_transferred`, `named`, `registration_lock`, `recovery_window`.
- `phases`: P1 scan; P2 replication after the first copied status; P3 refusal at the root-record threshold, where a truth/authority/continuity choice replaces a mandatory Break.
- `summons_linked_actors`: archive record, Avatar, Usher, and Tally-Skin copies remain linked; the source record is the true target.
- `resource_reward_effect`: victory grants `root_record_fragment x1`; escape leaves one active name claim; noncombat grants `recovered_note x1` and one `CL-REC` step.
- `aftermath`: name, title, region access, and relationship state change on revisit according to the chosen recognition axis.
- `clock_links`: immediate `CL-CROWN +1`; delayed `CL-REC +1` and `CL-PER +1` based on the surviving record.
- `encounter_outcomes`: `V` expose the source and choose a surviving authority; `E` appeal and leave the projection active; `F` reset the archive and retain the crown-alignment clock; `N` challenge the record without destroying the actor.

## 5. Boss encounters

### ENC-ARPG-11 — The Gate With No Name

- `type`: charge-break tutorial boss; `seed_ids`: `S009`, `S011`, `S019`, `S044`, `S056`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`); `region_secondary: boundary_crown_precedence` (`R7 The Hollow Orchard`, whose seam anchor is bolted to the same gate).
- `region_role_local`: the first recovery gate has no accepted name, so it tests whether the player can read a marked sweep rather than memorize a source enemy.
- `silhouette_body_class`: a tall folding gate-body with the Tally-Skin's low counterweight and a vertical seam; a FAM-ARPG-17 route anchor is attached behind it.
- `roster`: FAM-ARPG-01 boss form x1, FAM-ARPG-17 x1 linked anchor; `target_priority`: active seal-bearer, record:marked gate source, linked_actor:anchor, sweep body.
- `activation`: first disputed crossing; `escape`: alternate threshold after one sweep; `noncombat`: valid seal.
- `baseline_signature_telegraph`: `Tally Pin` and `Boundary Clamp` are baselines; `Audit Sweep` is the signature. A three-line stitch, a completed category column, and a redacted target line telegraph it for one tick.
- `valid_counters`: Dodge, cleanse, Break the marked sweep, expose the gate record, or present the valid seal before commitment.
- `invalid_counters`: Guard-only, repeated attacks after the mark, or Break-spamming the unbreakable route anchor.
- `break_policy`: P1/P2 sweep is `marked`; the pin and anchor are unbreakable; P2 sweep becomes `unbreakable` after the second cycle, forcing proof/route resolution.
- `statuses`: `recorded`, `redaction_mark`, `writ`, `boundary_locked`, `recovery_window`.
- `phases`: P1 Registration at 100–60%; P2 Audit at 60%, adds two FAM-ARPG-01 and exposes the source; P3 Empty Form at 25%, sweep and anchor are unbreakable until `entry_token` or record proof resolves the mandate.
- `summons_linked_actors`: two P2 crawlers are owner-linked; the Seam Bailiff is the true route anchor and remains after the gate body falls.
- `resource_reward_effect`: victory grants `entry_token x2` and `ink_credit x1`; noncombat grants `entry_token x1`; failure advances `CL-INST` but keeps the charge/break lesson available.
- `aftermath`: the gate is accepted, disputed, or erased; the R1 `Return Registry`'s later recognition state changes.
- `clock_links`: immediate `CL-INST +1`, `CL-REC +1`; delayed `CL-CROWN +1` if the gate is recorded as a higher authority.
- `encounter_outcomes`: `V` break the marked sweep and resolve the source; `E` leave through the alternate threshold; `F` reset at the gate checkpoint; `N` valid seal opens the route without combat.

### ENC-ARPG-12 — The Usher of Second Registration

- `type`: identity boss; `seed_ids`: `S002`, `S003`, `S005`, `S031`, `S051`, `S055`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`); `region_secondary: hub_registration_ration_appeal` (`H0 The Undersign Exchange`, whose Exchange Registrar issues the second registration).
- `region_role_local`: the Usher persists after its first operator and attempts to register the player's action under a second name.
- `silhouette_body_class`: tall lantern-biped with a second, smaller lantern orbiting at shoulder height.
- `roster`: FAM-ARPG-02 boss form x1, FAM-ARPG-09 x2; `target_priority`: linked_actor:source lantern, linked_actor:orbiting lantern, sponge, record:player name record.
- `activation`: return after the first gate is unresolved or after `CL-CROWN` reaches the authored threshold; `escape`: submit a corrected name; `noncombat`: use the registrar NPC conversion.
- `baseline_signature_telegraph`: `Name Call` and `Drain Note` are baselines; `Second Registration` duplicates the current command label and redirects one action. Lantern plates, a repeated voice, and a blank name page telegraph it.
- `valid_counters`: silence, Break the accumulator, use `verified`, sever the name record, remove the Sponge, or present the correct prior name.
- `invalid_counters`: attacking the projection only, accepting the duplicate label, or replaying the drained command.
- `break_policy`: P1/P2 is `accumulator`; once the second name is recorded, the signature is `phase_locked` until the source name is released.
- `statuses`: `named`, `registration_lock`, `amnesia`, `memory_drain`, `copied`, `recovery_window`.
- `phases`: P1 First Call; P2 Second Registration at the first duplicated command; P3 Empty Name after the source is exposed, with a noncombat release requirement.
- `summons_linked_actors`: two Sponges link to two name records; one Sponge remains after the Usher falls and can drain a later return route.
- `resource_reward_effect`: victory grants `entry_token x1` and `recovered_note x1`; escape preserves the old name but spends one `ink_credit`; noncombat grants `entry_token x1` and advances `CL-REC`.
- `aftermath`: a character is recognized by a changed name, role, or employment history on revisit.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-CROWN +1` and `CL-PER +1` if the second name becomes the official one.
- `encounter_outcomes`: `V` release the original name; `E` leave with a duplicate claim; `F` reset the Usher and retain the record clock; `N` correct the registration through the NPC conversion.

### ENC-ARPG-13 — Bloom at the Bottom of the Form

- `type`: contamination/resource boss; `seed_ids`: `S009`, `S017`, `S024`, `S031`, `S061`, `S064`.
- `region_role`: `recovery_reentry`; `region_id: region_r1_returning_kiln` (`R1 The Returning Kiln`); `region_secondary: resource_allocation` (`R2 Siltglass Commons`, whose grazers the bloom's source feeds).
- `region_role_local`: the failed recovery archive has a living source at the bottom of its official form.
- `silhouette_body_class`: large amorphous mass with a central paper knot and a fringe that exposes small grazer silhouettes when it splits.
- `roster`: FAM-ARPG-03 boss form x1, FAM-ARPG-13 x3 linked grazers; `target_priority`: linked_actor:central knot, linked_actor:active grazer anchor, fringe, record:player source.
- `activation`: opening the lower recovery form or exposing a contaminated record; `escape`: quarantine exit; `noncombat`: seal and report the source.
- `baseline_signature_telegraph`: `Seep` and `Crop Bite` are baselines; `Contagion Bloom` and `Bloom Feast` are signatures. Wax pools, a consuming ground stain, and a resource line moving toward the knot telegraph commitment.
- `valid_counters`: quarantine, isolate, burn/cleanse, sever the source, deny a resource, or Break the knot after `ink_bloom 2`.
- `invalid_counters`: chasing the fringe, healing in the bloom, or waiting for the grazer population to exhaust naturally.
- `break_policy`: `resource`; the knot is Breakable only after two contamination stacks and one feast; the fringe is unbreakable.
- `statuses`: `contamination`, `ink_bloom`, `consumed`, `overfed`, `exhausted`, `recovery_window`.
- `phases`: P1 Seep; P2 Bloom at `ink_bloom 2` and grazer spawn; P3 Empty Form at `ink_bloom 3`, when the knot is exposed and the source can be quarantined or destroyed.
- `summons_linked_actors`: three grazers share the source knot; they remain after the visible mass dies; the knot is the true target.
- `resource_reward_effect`: victory grants `harvest_residue x2` and lowers `CL-CONT` one step; escape grants `harvest_residue x1` with a contamination mark; noncombat spends one `entry_token` and writes a quarantined source.
- `aftermath`: archive access, resource reserves, and NPC handling rules change; a surviving knot creates a later contamination variant.
- `clock_links`: immediate `CL-CONT +1`, `CL-RES +1`; delayed `CL-RES -1` only after quarantine, otherwise `CL-CROWN +1` if the bloom is declared an official category.
- `encounter_outcomes`: `V` destroy or quarantine the source; `E` leave with one contamination stack; `F` reset and retain the contamination/resource clocks; `N` file a quarantine report without combat.

### ENC-ARPG-14 — The Court of Grievances

- `type`: institutional boss; `seed_ids`: `S012`, `S039`, `S046`, `S048`, `S056`.
- `region_role`: `hub_registration_ration_appeal`; `region_id: region_h0_undersign_exchange` (`H0 The Undersign Exchange`); `region_secondary: translation_precedence` (`R4 Crownwell Archive`, whose public copy the judgment becomes).
- `region_role_local`: a court-warden treats every injury, refusal, and failed recovery as a claim that can be cross-examined into authority.
- `silhouette_body_class`: broad shielded biped with a three-part petition box and a suspended judge's record plate.
- `roster`: FAM-ARPG-04 boss form x1, FAM-ARPG-06 x2; `target_priority`: linked_actor:active grievance, Ward, record:Lance contract, record:claim record.
- `activation`: accepting a claim or crossing the public court threshold; `escape`: file an appeal; `noncombat`: settle, reject, or transfer the claim.
- `baseline_signature_telegraph`: `Counterclaim` and `Lance Check` are baselines; `Judgment Counterclaim` is the signature. The shield opens, a voice asks for a category, and a red claim line connects target and judge.
- `valid_counters`: do not attack, present evidence, use a non-damaging status, show a permit, sever the claim, or Break the Ward at its accumulator threshold.
- `invalid_counters`: repeated damage, attacking during intake, or assuming the reflected payload is the only valid response.
- `break_policy`: `accumulator` until the judgment threshold; final judgment is `phase_locked` until evidence/permit/noncombat settlement.
- `statuses`: `grievance_debt`, `mirrored`, `sealed`, `audited`, `recovery_window`.
- `phases`: P1 Intake; P2 Cross-Examination after the first stored payload; P3 Judgment at the second claim, with the Ward unbreakable until a valid resolution is recorded.
- `summons_linked_actors`: two Lancer enforcers and the claim record remain linked; a claim copy can continue an audit after the Ward is gone.
- `resource_reward_effect`: victory grants `petition_seal x1`; noncombat settlement grants `permit_fragment x1`; escape leaves a claim and advances `CL-REC`; failure adds a recurring debt.
- `aftermath`: NPC duty, player compensation, access rights, or faction reputation changes on revisit.
- `clock_links`: immediate `CL-REC +1`, `CL-INST +1`; delayed `CL-RES +1` if the claim becomes a recurring service fee.
- `encounter_outcomes`: `V` make the court answer its own record; `E` appeal and carry the claim; `F` reset at the court checkpoint; `N` settle, reject, or transfer the claim without combat.

### ENC-ARPG-15 — The Bell That Counts Late

- `type`: scheduler boss; `seed_ids`: `S013`, `S014`, `S018`, `S022`, `S024`, `S047`.
- `region_role`: `intervention_scheduling`; `region_id: region_r3_bellhouse_hospice` (`R3 Bellhouse Hospice`); `region_secondary: permission_before_transformation` (`R5 Glasswing Ordinal`, whose foundry relays hang off the same network).
- `region_role_local`: a sanctified device measures belief as response delay and has absorbed the emergency signal network.
- `silhouette_body_class`: suspended ring-cluster with a human-scale shadow and a clapper that occupies one scheduler position.
- `roster`: FAM-ARPG-05 boss form x1, FAM-ARPG-16 x3; `target_priority`: linked_actor:relay, Bell clapper, Bell body, signal cluster.
- `activation`: entering the foundry during a delayed service cycle; `escape`: disconnect the outer relay; `noncombat`: perform maintenance with a latency key.
- `baseline_signature_telegraph`: `Resonance` and `Scheduler Tithe` are baselines; `Delay Lattice` is the signature. Rings contract, the clock tick disappears, and one command line freezes for two ticks.
- `valid_counters`: silence, no-turn purge, marked Break at the resonance peak, use `latency_key`, disconnect the relay, or perform maintenance.
- `invalid_counters`: attacking while silent, waiting for the delay, or using a normal command to fill the stolen slot.
- `break_policy`: `marked` only at resonance peak; P2 is `unbreakable` until a signal source is disconnected.
- `statuses`: `delayed`, `resonant`, `noised`, `slot_stolen`, `recovery_window`.
- `phases`: P1 Resonance; P2 Staggered Arrival after the first delayed action; P3 Hard Lock when two slots are stolen, requiring a relay disconnect or noncombat maintenance.
- `summons_linked_actors`: three Tithes link to the Bell; the relay remains after the Bell body is destroyed and must be handled in the aftermath.
- `resource_reward_effect`: victory grants `latency_key x1` and `clear_channel x1`; escape spends one `latency_key`; noncombat maintenance grants `latency_key x1` and lowers `CL-PER` by one step.
- `aftermath`: service schedules, NPC recovery, and emergency communication change on revisit; an unresolved relay keeps a `noised` route state.
- `clock_links`: immediate `CL-INST +1`; delayed `CL-PER +1` if the delay crosses a revisit, otherwise `CL-RES -1` after maintenance.
- `encounter_outcomes`: `V` disconnect the relay and free the scheduler; `E` leave through the maintenance route with one stolen slot; `F` reset the cycle and retain the personal clock; `N` tune the Bell without combat.

### ENC-ARPG-16 — Licence of the First Body

- `type`: transformation-service boss/NPC-conversion encounter; `seed_ids`: `S020`, `S021`, `S023`, `S026`, `S038`, `S079`.
- `region_role`: `permission_before_transformation`; `region_id: region_r5_glasswing_ordinal` (`R5 Glasswing Ordinal`); `region_secondary: organ_authority_negotiation` (`R6 Gristmarket Ward`, where the redirected recovery ends up).
- `region_role_local`: the Glasswing Ordinal and its Support Registry attempt to validate a transformation whose body, memory, and social identity disagree.
- `silhouette_body_class`: upright armored biped with a checklist torso, a lance that becomes a surgical seam, and a visible support badge.
- `roster`: FAM-ARPG-06 boss form x1, FAM-ARPG-11 x2, FAM-ARPG-10 x1 at P2; `target_priority`: record:contract source, active lance, linked_actor:incision seam, organ voice.
- `activation`: requesting transformation, challenging the service order, or entering the amendment chamber; `escape`: withdraw the application; `noncombat`: accept, refuse, or renegotiate the contract.
- `baseline_signature_telegraph`: `Lance Check` and `Scalpel Draw` are baselines; `Contract Lance` and `Suture Line` are signatures. A license glyph, red-white thread, and dimmed body-category line telegraph them.
- `valid_counters`: present `permit_fragment`, sever the contract, target the Envoy, cauterize the seam, use `surgical_license`, silence the organ voice, or Break the marked lance.
- `invalid_counters`: attacking the application after the checklist completes, healing through the seam, or treating transformation as a costume-only state.
- `break_policy`: P1 lance is `marked`; P2 is `link`; P3 is `unbreakable` until the contract is revoked or the NPC conversion is resolved.
- `statuses`: `sealed`, `verified`, `scarline`, `recovery_lock`, `voice_lock`, `recovery_window`.
- `phases`: P1 Application; P2 Audit at the first sealed command and organ entry; P3 Amendment at the source-record threshold, replacing combat completion with a consent/contract choice.
- `summons_linked_actors`: two Envoys and one Organ Chorus link to the service record; the contract source remains after the visible boss is defeated.
- `resource_reward_effect`: victory grants `surgical_license x1`; noncombat approval grants `consent_charter x1` but advances `CL-CROWN`; escape retains the application and spends one `entry_token`.
- `aftermath`: body function, memory, employment, and relationship recognition may diverge on revisit.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-CROWN +1` and `CL-PER +1` depending on who signs the record.
- `encounter_outcomes`: `V` revoke the wrong contract and preserve the person's authority; `E` withdraw with the application unresolved; `F` reset the chamber and retain the record clock; `N` negotiate a noncombat amendment.

### ENC-ARPG-17 — The Unfinished Sentence

- `type`: language/authority boss; `seed_ids`: `S069`, `S070`, `S072`, `S073`, `S078`, `S001`.
- `region_role`: `translation_precedence`; `region_id: region_r4_crownwell_archive` (`R4 Crownwell Archive`).
- `region_role_local`: the Translation Tribunal's archive and the living `Record Office` projection above it use the same incomplete term to justify different actions.
- `silhouette_body_class`: winged swarm around a mirrored archive projection, with a blank page occupying the center of the silhouette.
- `roster`: FAM-ARPG-07 boss form x1, FAM-ARPG-18 x1 linked projection, FAM-ARPG-02 x1; `target_priority`: record:source term, projection, central moth, record:blank-page source.
- `activation`: entering the translation archive after a term has been used in combat or public record; `escape`: carry a contradictory glyph; `noncombat`: present the source term and accept its recorded category.
- `baseline_signature_telegraph`: `Letter Bite` and `Copy Step` are baselines; `Translation Storm` and `Name Transfer` are signatures. An incomplete glyph, duplicated outline, and higher-page name telegraph commitment.
- `valid_counters`: source anchor, silence, sever the copy link, expose the original term, use a different recognized name, or Break the central moth after it commits.
- `invalid_counters`: killing only the projection, accepting the same source name, or reading the page as if the translated label were player intent.
- `break_policy`: `marked` for the moth; `link` for the projection; final blank-page authority is `unbreakable` until the contradiction is preserved or revoked.
- `statuses`: `translated`, `misnamed`, `copied`, `redirected`, `name_transferred`, `recovery_window`.
- `phases`: P1 Term; P2 Syntax at the first copied label; P3 Blank Page after the source is exposed, requiring a truth/authority/continuity choice.
- `summons_linked_actors`: projection, source term, Usher, and Moth link; the source term remains after the visible projection falls.
- `resource_reward_effect`: victory grants `untranslated_glyph x1` and `root_record_fragment x1`; escape grants one `recovered_note`; noncombat preserves the contradiction without the root fragment.
- `aftermath`: local language, titles, and route terms change meaning on revisit; a translated law can become a permanent institution.
- `clock_links`: immediate `CL-REC +1`; delayed `CL-CROWN +1` if the incomplete term is accepted.
- `encounter_outcomes`: `V` preserve and correct the source; `E` leave with a contradictory glyph; `F` reset the archive and retain the public-record clock; `N` record the contradiction without combat.

### ENC-ARPG-18 — A Name Has Teeth

- `type`: category-priority boss; `seed_ids`: `S042`, `S044`, `S045`, `S059`, `S078`.
- `region_role`: `translation_precedence`; `region_id: region_r4_crownwell_archive` (`R4 Crownwell Archive`); `region_secondary: recovery_reentry` (`R1 The Returning Kiln`, whose Return Registry clerk enforces the archive's category).
- `region_role_local`: a registry hound and a return clerk enforce a guardian category that no longer matches the person or the body.
- `silhouette_body_class`: low long quadruped with a broad ear shelf, paired with a tall lantern-biped whose plates form a filing wall.
- `roster`: FAM-ARPG-08 boss form x1, FAM-ARPG-02 x2, FAM-ARPG-09 x1 optional; `target_priority`: record:category source, linked_actor:hound collar, record:clerk record, sponge.
- `activation`: entering after a guardian-name error or challenging the registry; `escape`: change the category at an anchor; `noncombat`: present a correct guardian record.
- `baseline_signature_telegraph`: `Chase Mark`, `Name Call`, and `Drain Note` are baselines; `Category Bite` is the signature. Filing lines, a collar pulse, and a name plate moving between bodies telegraph it.
- `valid_counters`: retag, sever the scent, expose the source category, use `definition_token`, cleanse `misnamed`, silence the clerk, or Break the collar link.
- `invalid_counters`: attacking by physical distance, focusing only the hound while the record is active, or accepting the guardian name.
- `break_policy`: `link` for the hound; `accumulator` for the clerk; the final bite is `phase_locked` until the category is exposed.
- `statuses`: `scented`, `misnamed`, `named`, `registration_lock`, `amnesia`, `recovery_window`.
- `phases`: P1 Scent; P2 Registry Chase at the first retag; P3 Judgment after the second retag, with a noncombat correction replacing ordinary damage completion.
- `summons_linked_actors`: collar, clerk records, and Sponge link; a collar can remain after the hound is defeated and continue a stale classification.
- `resource_reward_effect`: victory grants `definition_token x1`; escape preserves the stale category and spends one `clear_channel`; noncombat grants `entry_token x1` and advances `CL-REC`.
- `aftermath`: school, registry, service, or family access changes because a different guardian name/category is recognized.
- `clock_links`: immediate `CL-INST +1`; delayed `CL-CROWN +1` if the category becomes a title.
- `encounter_outcomes`: `V` expose and correct the category; `E` leave with the hound still tracking the old name; `F` reset the registry and retain the classification clock; `N` submit a correct record without combat.

### ENC-ARPG-19 — Consent of the Viscera

- `type`: body-authority boss; `seed_ids`: `S004`, `S028`, `S029`, `S030`, `S037`, `S079`, `S087`.
- `region_role`: `organ_authority_negotiation`; `region_id: region_r6_gristmarket_ward` (`R6 Gristmarket Ward`).
- `region_role_local`: the clinic's governing body is not one mind, but its organs are forced to produce one legal decision before treatment can continue.
- `silhouette_body_class`: multi-lobed vertical Chorus with a central consent seam and unequal organ faces arranged around a surgical light.
- `roster`: FAM-ARPG-10 boss form x1, FAM-ARPG-11 x2; `target_priority`: active organ voice, record:central consent seam, Envoy, resource_node:patient resource.
- `activation`: requesting surgery, refusing a procedure, or entering the arbitration chamber; `escape`: withdraw consent; `noncombat`: answer one voice and accept a cost.
- `baseline_signature_telegraph`: `Pulse` and `Scalpel Draw` are baselines; `Authority Chorus` and `Suture Line` are signatures. Different organ rhythms, a complaint, and a red-white thread telegraph the action.
- `valid_counters`: silence or satisfy one voice, target the weak lobe, sever the consent link, use `consent_charter`, cauterize, or Break the marked seam.
- `invalid_counters`: all-target healing, attacking every lobe, or assuming the central body speaks for every organ.
- `break_policy`: `link` for the Chorus; `marked` for the Suture Line; P3 is `phase_locked` until a valid body-authority decision is recorded.
- `statuses`: `organ_tension`, `voice_lock`, `linked`, `scarline`, `recovery_lock`, `recovery_window`.
- `phases`: P1 Consultation; P2 Disagreement at two tension stacks; P3 Arbitration at three stacks, with a consent/sever/retreat choice replacing the final damage check.
- `summons_linked_actors`: four organ lobes, two Envoys, and one patient record share the link; a severed lobe can remain as a distinct NPC/body state.
- `resource_reward_effect`: victory grants `consent_charter x1` and `surgical_license x1`; noncombat compromise grants one of them and raises `CL-PER`; escape leaves one voice unresolved; failure consumes one medicine reserve.
- `aftermath`: treatment, employment, relationship, and body authority are written as separate possible surfaces on revisit.
- `clock_links`: immediate `CL-PER +1`; delayed `CL-REC +1` if the clinic's decision becomes the person's official history.
- `encounter_outcomes`: `V` sever the false authority and preserve the chosen body voice; `E` withdraw with an unresolved organ; `F` reset the chamber and retain the personal clock; `N` negotiate treatment without combat.

### ENC-ARPG-20 — The Many Become One

- `type`: clone/link boss; `seed_ids`: `S005`, `S032`, `S033`, `S061`, `S106`.
- `region_role`: `resource_allocation`; `region_id: region_r2_siltglass_commons` (`R2 Siltglass Commons`); `region_secondary: permission_before_transformation` (`R5 Glasswing Ordinal`'s Support Registry, whose labour roster the group is deployed from).
- `region_role_local`: the census and the deployment hall treat a group of identical bodies as one labor category and read the visible delay as a scheduling error.
- `silhouette_body_class`: five identical small humanoids arranged as one broad silhouette, with one delayed copy visibly outside the shared arm angle.
- `roster`: FAM-ARPG-12 x4, FAM-ARPG-09 x2; `target_priority`: outlier, linked_actor:first link, Sponge, record:quorum source.
- `activation`: entering the deployment hall or challenging a clone's legal name; `escape`: release the outlier; `noncombat`: redistribute names and labor roles.
- `baseline_signature_telegraph`: Matched Swipe and Drain Note are baselines; Quorum Strike and Undo Bite are signatures. Shared arm angles, a delayed copy, and a repeated prior command form the tell.
- `valid_counters`: mark an outlier, sever two links, use `identity_token`, interrupt the shared scheduler, feed a decoy note, or choose name redistribution.
- `invalid_counters`: attacking every clone in sequence, using a single blanket save, or treating the delayed copy as a visual bug.
- `break_policy`: `link`; no owner Break while consensus is intact. The first link exposes an outlier; the second link is required for the punish window.
- `statuses`: `linked`, `outlier`, `consensus`, `amnesia`, `slot_stolen`, `recovery_window`.
- `phases`: P1 Deployment; P2 Divergence at the first unique status; P3 Quorum after one link break, where the group is unbreakable until the second link is cut.
- `summons_linked_actors`: four clones, two Sponges, and the census record link; one Sponge can remain after the quorum source dies.
- `resource_reward_effect`: victory grants `identity_token x1` and `recovered_note x1`; escape preserves the outlier and spends one `entry_token`; noncombat grants one relationship token and `CL-REC +1`.
- `aftermath`: the outlier has a distinct legal and social outcome; the settlement's resource ledger records one fewer or differently classified body.
- `clock_links`: immediate `CL-PER +1`; delayed `CL-RES -1` if separation precedes deployment, otherwise `CL-RES +1`.
- `encounter_outcomes`: `V` break the quorum and recognize the outlier; `E` release one clone and leave consensus active; `F` reset the hall and retain identity/resource clocks; `N` redistribute identities without combat.

### ENC-ARPG-21 — The Last Safe Water

- `type`: ecology/resource boss; `seed_ids`: `S033`, `S061`, `S062`, `S064`, `S066`, `S068`.
- `region_role`: `resource_allocation`; `region_id: region_r2_siltglass_commons` (`R2 Siltglass Commons`).
- `region_role_local`: the last verified water source is being consumed by a mass of individually legal bodies and a single guide who knows the cost.
- `silhouette_body_class`: a low swarm with one large central jaw/anchor, joined to a tall wrapped Pilgrim by a visible water-line.
- `roster`: FAM-ARPG-13 boss swarm x1, FAM-ARPG-14 x1, FAM-ARPG-16 x1 optional relay; `target_priority`: linked_actor:ecological anchor, resource_node:water source, Pilgrim, linked_actor:relay.
- `activation`: using the last safe water route or entering the ration vault; `escape`: take a ration packet; `noncombat`: verify an alternate source.
- `baseline_signature_telegraph`: Crop Bite and Chill Touch are baselines; Bloom Feast and Safe-Water Denial are signatures. A dark resource stain, a blank route mark, and a visible water line telegraph them.
- `valid_counters`: deny a resource, isolate the anchor, cleanup_token, sever the water line, present `water_manifest`, thaw, or Break the anchor after a feast.
- `invalid_counters`: healing, guarding, waiting, or using a denied water item while the final calculation is active.
- `break_policy`: `resource` for the ecological anchor; the Pilgrim is `unbreakable` during P3 until an alternate source is verified.
- `statuses`: `consumed`, `overfed`, `chilled`, `thirst_locked`, `verified_safe`, `recovery_window`.
- `phases`: P1 Grazing; P2 Feast at the first resource loss; P3 Scarcity at the third, requiring a route/resource decision rather than ordinary damage.
- `summons_linked_actors`: swarm anchor, reservoir record, Pilgrim jar, and optional relay are linked; the anchor remains after visible swarm death.
- `resource_reward_effect`: victory grants `water_manifest x1` and `harvest_residue x1`; escape grants one ration packet and keeps `thirst_locked 1`; noncombat shares the cache and lowers `CL-RES` one step.
- `aftermath`: settlement rationing, guide employment, safe-route knowledge, and one NPC's access to care change on revisit.
- `clock_links`: immediate `CL-RES +1` for each loss; delayed `CL-PER +1` if denial persists across a settlement cycle.
- `encounter_outcomes`: `V` separate the anchor and verify a new source; `E` leave with a ration and a water lock; `F` reset the vault and retain the resource clock; `N` redistribute the cache without combat.

### ENC-ARPG-22 — Audit Above the Market

- `type`: debt/charge boss; `seed_ids`: `S012`, `S056`, `S058`, `S060`, `S065`.
- `region_role`: `boundary_crown_precedence`; `region_id: region_r7_hollow_orchard` (`R7 The Hollow Orchard`); `region_secondary: hub_registration_ration_appeal` (`H0 The Undersign Exchange`, whose court and market counter compete for the same debt).
- `region_role_local`: an outer-boundary audit and a grievance court compete to define who owes the cost of crossing.
- `silhouette_body_class`: heavy square-backed quadruped with a raised record slab and a petition shield orbiting its front.
- `roster`: FAM-ARPG-15 boss form x1, FAM-ARPG-04 x1, FAM-ARPG-17 x1 at P2; `target_priority`: active charge, linked_actor:claim shield, linked_actor:writ anchor, Ox body.
- `activation`: crossing the market or refusing a toll; `escape`: use a witness lane; `noncombat`: present an audit record.
- `baseline_signature_telegraph`: Tally Trample, Counterclaim, and Boundary Clamp are baselines; Audit Charge and Judgment Counterclaim are signatures. Ledger columns, an open shield, and chalk route lines telegraph the combined debt.
- `valid_counters`: Dodge, marked Break, audit_credit, witness, permit, non-damaging status, sever the claim, or alternate route.
- `invalid_counters`: Guard-only, brute force, attacking the Bailiff, or continuing to damage after a claim has been stored.
- `break_policy`: `marked` for the Ox; `accumulator` for the Ward; P2 Writ is `unbreakable` until the market mandate changes.
- `statuses`: `audited`, `charge_lock`, `grievance_debt`, `mirrored`, `writ`, `boundary_locked`, `recovery_window`.
- `phases`: P1 Toll; P2 Reclassification at the first claim; P3 Collection at the second charge, requiring payment, witness, or mandate change.
- `summons_linked_actors`: claim shield, Bailiff anchor, and market record link; the record remains after the Ox falls.
- `resource_reward_effect`: victory grants `audit_credit x1` and `petition_seal x1`; escape creates a debt; noncombat pays one credit and grants `entry_token x1`.
- `aftermath`: market prices, service access, and faction claims change on revisit; a debt follows the player or NPC according to target priority.
- `clock_links`: immediate `CL-INST +1`, `CL-REC +1`, `CL-RES +1`; delayed `CL-CROWN +1` if the market accepts the audit's category.
- `encounter_outcomes`: `V` make the charge and claim answer each other; `E` leave with a debt and a route key; `F` reset the crossing and retain the toll; `N` pay, appeal, or change the mandate without combat.

### ENC-ARPG-23 — Bailiff of the Outer Seam

- `type`: route/authority boss; `seed_ids`: `S010`, `S012`, `S041`, `S111`.
- `region_role`: `boundary_crown_precedence`; `region_id: region_r7_hollow_orchard` (`R7 The Hollow Orchard`).
- `region_role_local`: an outer-wall Bailiff treats a failed recovery space as a category that must remain sealed, even when the wall is no longer reliable.
- `silhouette_body_class`: wide vertical door-construct with chalk seams, a low moving base, and a visible safety-manual plate.
- `roster`: FAM-ARPG-17 boss form x1, FAM-ARPG-16 x2, FAM-ARPG-01 x2 optional clerks; `target_priority`: linked_actor:active writ anchor, linked_actor:relay, record:route proof, Bailiff body.
- `activation`: attempting the outer seam or presenting a failed recovery record; `escape`: use an alternate route; `noncombat`: revoke the safety mandate.
- `baseline_signature_telegraph`: Boundary Clamp and Noise Lash are baselines; Boundary Writ is the signature. Chalk lines close around the route, a safety symbol completes, and the signal ring disappears.
- `valid_counters`: alternate route, source proof, evacuate a linked actor, silence the relay, noncombat correction, or the required clock condition.
- `invalid_counters`: Break-only, brute force, Guard, or attacking the body while the route is the true target.
- `break_policy`: `unbreakable`; the Bailiff changes mandate/route, not health. Relays are `marked` after a paid Tithe.
- `statuses`: `writ`, `boundary_locked`, `noised`, `slot_stolen`, `registration_lock`, `recovery_window`.
- `phases`: P1 Local Clamp; P2 Audit after the first `writ`; P3 Outer Seam at the route-proof threshold, requiring a mandate change or alternate route.
- `summons_linked_actors`: chalk anchors and two relays link to the wall record; an anchor remains after the body is bypassed.
- `resource_reward_effect`: victory grants `seam_key x1` and `clear_channel x1`; escape spends one route option; noncombat revoke grants `seam_key x1` and advances `CL-REC`.
- `aftermath`: the outer seam, local safety category, and NPC route knowledge change on revisit.
- `clock_links`: immediate `CL-INST +1`; delayed `CL-CROWN +1` if the wall's mandate persists after the region changes.
- `encounter_outcomes`: `V` revoke or redirect the mandate and open a route; `E` leave through a secondary route; `F` reset at the seam checkpoint; `N` change the mandate through a valid record.

### ENC-ARPG-24 — The Above-Record

- `type`: final archive boss; `seed_ids`: `S001`, `S002`, `S052`, `S053`, `S059`, `S060`, `S099`, `S116`.
- `region_role`: `translation_precedence`; `region_id: region_r4_crownwell_archive` (`R4 Crownwell Archive`).
- `region_role_local`: the Crown of Continuance's literal record, its political institution, and its abstract invariant converge in one projection above every lower hall.
- `silhouette_body_class`: towering mirrored composite with three separated vertical layers: a record spine, a political plate, and a blank invariant face.
- `roster`: FAM-ARPG-18 x1, FAM-ARPG-01 x2, FAM-ARPG-02 x2, FAM-ARPG-05 x1, FAM-ARPG-12 x3; `target_priority`: record:source record, record:copied record nodes, Return clerks, Bell, kin group, projection.
- `activation`: the root-record threshold after at least two resolved region/encounter axes; `escape`: return through the appeal route; `noncombat`: submit a truth/authority/continuity proof.
- `baseline_signature_telegraph`: Copy Step, Tally Pin, Name Call, Resonance, and Matched Swipe are baselines; Name Transfer and Archive Transfer are signatures. The projection duplicates one completed encounter's state, prints a name on a higher page, and exposes the source spine for two ticks.
- `valid_counters`: expose the source record, sever a copy link, free a recognized actor, present root evidence, use a different recognized name, silence the source node, or choose a valid noncombat proof.
- `invalid_counters`: kill only projections, repeat the same source name, use a single global Break, or treat all visible copies as separate true actors.
- `break_policy`: `link` for the projection; copied actors expose their links through Break or sever; the final phase is `unbreakable` until truth, authority, and continuity are each represented by an authored proof.
- `statuses`: `copied`, `redirected`, `name_transferred`, `named`, `registration_lock`, `linked`, `outlier`, `delayed`, `recovery_window`.
- `phases`: P1 Scan; P2 Replication after the first copied encounter state; P3 Refusal at the root threshold, where ordinary damage cannot complete the encounter; P4 Above, after a truth/authority/continuity choice, resolves the surviving record and linked actors.
- `summons_linked_actors`: two Tally-Skins, two Ushers, one Bell, and three Kinward actors link to the archive source. Each has a distinct death rule: Tally/Ushers die with the source phase, the Bell relay remains if disconnected, and one Kinward outlier can survive as an NPC or repeat challenger.
- `resource_reward_effect`: victory grants `root_record_fragment x1`, one route/relationship axis, and a final `CL-CROWN` state; escape leaves the current record active and advances `CL-CROWN +1`; noncombat grants `recovered_note x1` and one truth proof without the final root fragment; failure resets the archive checkpoint and preserves player knowledge.
- `aftermath`: the revisit state records who is recognized as person, role, record, or institution; the three proof axes remain independently visible in later route/NPC/relationship states.
- `clock_links`: immediate `CL-CROWN +1`; delayed `CL-REC +1`, `CL-PER +1`, and `CL-RES +/-1` according to the chosen truth, authority, and continuity outcomes.
- `encounter_outcomes`: `V` resolve the source and write the three-axis aftermath; `E` appeal out with the record intact but a new Crown alignment; `F` reset the archive and retain knowledge; `N` prove a category/role/continuity claim and exit without destroying the projection.

### ENC-ARPG-25 — The Fold That Refuses the Hand

This is the `R8` data-only addition of `07` §14.1. It is a field encounter, not a boss, it composes a roster from existing families, and it adds no new combat system. Its acceptance condition is `changed_core_files == []`.

- `type`: field court encounter; `seed_ids` (magic supplement, separate from the core range): `S121`, `S133`, `S140`, `S150`, `S155`, `S157`, `S160`.
- `region_role`: `magic_training_craft_labor`; `region_id: region_r8_folding_school` (`R8 The Folding School`); `region_secondary: permission_before_transformation` (`R5 Glasswing Ordinal`, which supplied the medium, the fold count, and the blade through `R5-13 Supply Rack`) and `boundary_crown_precedence` (`R7 The Hollow Orchard`, whose unfinished `R7-09` cut is the same maker's evidence).
- `region_role_local`: the `Course Court` grades a student's craft attempt and the grade is filed whether or not anyone fights. The encounter's conflict is not "can magic be learned" but "which labour record the learned craft is written into" - `craft_credit`, `lineage_token`, or a refusal. `02` §8.9 requires this encounter to be completable as a field court encounter or as the noncombat `withdraw and take the labor record`.
- `roster`: FAM-ARPG-19 x1 (Grading Wall, `region_role: magic_training_craft_labor`), FAM-ARPG-02 x1 (`region_role: recovery_reentry`, the curriculum office's recording clerk, which persists after the office changes hands); `target_priority`: `record:residue ledger`, `record:course index row`, `resource_node:node disperser stock`, `linked_actor:residue record`, Grading Wall, recording clerk.
- `activation`: `field_trigger` on the `Course Court` prop after `E18` is `open` and `G5` is filed; `escape`: leave through the `course index return` with `lineage_token x1`; `noncombat`: `R8-05 Fold Failure Hearing` filing or `withdraw and take the labor record`.
- `baseline_signature_telegraph`: `ACT-CGW-GRADE-MARK` and `ACT-RU-STAFF-PULSE` are baselines; `ACT-CGW-FOLD-VERDICT` and `ACT-RU-NAME-CALL` are signatures. The clamp arm opening on a blank shape, the score slate flipping to an empty line, the basin film rising, one dropped cutting tick, and the clerk's blank name plate telegraph commitment - five channels, above the required two.
- `valid_counters`: Break the marked verdict; `ACT-CGW-DISPERSE-READING` below the `concentration_load` threshold; present the `medium_blank` or `fold_sheet` matching the named `shape_or_pattern`; accept the alternate shape through the hearing; sever `record:residue ledger`; silence the wall; open a `circulation_slot` route and pay the neighbour's cost; file or refuse the portal contract before commitment; or take the noncombat withdrawal.
- `invalid_counters`: renaming the spell or the shape; attacking only the clamp arm while the ledger is the true target; bringing a mismatched medium; grinding `medium_residue` down with damage instead of dispersing or isolating it; treating `concentration_load` as a damage multiplier; adding a magic-specific combat rule.
- `break_policy`: `marked` for the verdict; `accumulator` for the clerk; `phase_locked` in P3 until the residue record or a disperser route resolves it; `unbreakable` in P4 until the contract is filed, refused, or named at `G8`. The clamp arm is `unbreakable` throughout and is never the true target.
- `statuses`: `concentration_load`, `medium_residue`, `misfolded`, `overflowed`, `contract_bound`, `named`, `registration_lock`, `silenced`, `recovery_window`. `contamination`/`ink_bloom` are absent by design - residue is a handling record, not a transfer.
- `phases`: P1 Grading (clerk pins, wall marks); P2 Residue at `medium_residue 2`, where the clerk binds the student's name to the ledger and the residue record becomes severable; P3 Overflow at `medium_residue 3` or the first `overflowed`, where the basin writes `resource_node:node disperser stock` and the wall locks until the residue record is filed; P4 Contract Press when the student has an unresolved portal obligation, where ordinary damage cannot complete the encounter and the contract's location inside or outside the `Crown Protocol` must be named.
- `summons_linked_actors`: the `Cut Chamber` residue record is the single true target and `survive`s the wall; the clerk's slate is `support` and `die_with`; one `FAM-ARPG-05` latency relay is `pressure` and `survive`. The residue record may reappear in `R5` as `R5-03 Repair Bench` stock, which is the cross-region consequence rather than a new enemy.
- `resource_reward_effect`: victory grants `craft_credit x1` and files the residue ledger as the `provenance` of one `concentration_sample`; escape keeps one `medium_residue` stack and spends `lineage_token x1`; noncombat `R8-05` filing spends `craft_credit x1` and writes the school record; failure leaves one `overflowed` body-load mark, withdraws the student's credit, and advances `CL-PER`. `contract_tally` is written as a non-quantified debt key and is never auto-resolved.
- `aftermath`: the `Cut Chamber` wall keeps the failed fold; the `R8` course index, the `R4` glossary slot, and the `R5` labour-hour record then read three different values for one cast; revisit variants are the filed grade, the dispersed residue, the recovered medium at `R5-03`, and the unresolved contract. No student is removed from the region.
- `clock_links`: immediate `CL-PER +1` and, separately, `CL-RES +1` when the basin spends disperser stock; the `R8-05` filing moves `CL-REC` on its own transaction; `CL-INST +1` is delayed until the school files the residue as a category; `CL-CONT +1` happens only on a separate transaction when residue is dispersed into a neighbouring node; `CL-CROWN` never moves here - the contract feeds it as `G8` interpretation input only.
- `encounter_outcomes`: `V` file the residue ledger, place the craft in `craft_credit` or `lineage_token`, and keep the student's record; `E` leave through the `course index return` with one residue stack and a spent `lineage_token`; `F` reset at the course court checkpoint with the `CL-PER` stage retained and player knowledge preserved; `N` withdraw and take the labour record, or file the failed fold through the hearing, with no combat at all.

## 6. Group, variant, and NPC-conversion templates

### 6.1 Group template

A group is a roster composition over existing family/action records. It never creates a new enemy implementation.

Required fields: `group_id`, `version`, `seed_ids`, `base_region_id`, `anchor_family_id`, `roster[]`, `link_policy`, `target_priority`, `activation`, `phase_wave`, `status_policy`, `resource_budget`, `reward_policy`, `aftermath_policy`, `clock_links`, `outcomes`, and `valid_base_encounter_ids`.

Each `roster[]` entry contains `family_id`, `count`, `role`, `variant_id`, `linked_actor_id`, `lifetime`, and `spawn_condition`. A group resolves actors in authored order, clamps `max_count`, and uses the encounter's target priority rather than a new visual-priority rule.

The group set is closed at the five templates below, `GRP-ARPG-01` through `GRP-ARPG-05`. A sixth group is not planned in this Kit revision, and the magic layer does not add one: `ENC-ARPG-25` composes its roster from `FAM-ARPG-19` and `FAM-ARPG-02` directly. A later group is a content addition over the same template and the same records: it may change counts, role, link policy, target priority, phase wave, or reward policy, and it may not introduce a family-specific combat branch.

Concrete templates:

- `GRP-ARPG-01` Intake Pair: `FAM-ARPG-01 x2 + FAM-ARPG-02 x1`, `seed_ids S009/S011/S044`, link `redaction_mark -> named`, target priority `seal-bearer -> Tally-Skin -> Usher`, used by `ENC-ARPG-01`; the gate record is the encounter's true target through the `record` role.
- `GRP-ARPG-02` Viscera Quorum: `FAM-ARPG-10 x1 + FAM-ARPG-11 x2 + FAM-ARPG-09 x1`, `seed_ids S004/S028/S087`, link `organ_tension -> scarline`, target priority `active organ -> seam -> sponge`, used by `ENC-ARPG-05` and `ENC-ARPG-19`.
- `GRP-ARPG-03` Archive Reflection: `FAM-ARPG-18 x1 + FAM-ARPG-02 x2 + FAM-ARPG-01 x2`, `seed_ids S001/S052/S059/S060`, link `copied -> recorded`, target priority `record:source record -> projection -> clerk`, used by `ENC-ARPG-10` and `ENC-ARPG-24`.
- `GRP-ARPG-04` Resource Chain: `FAM-ARPG-13 x3 + FAM-ARPG-14 x1 + FAM-ARPG-16 x1`, `seed_ids S061/S062/S064/S066`, link `consumed -> thirst_locked`, target priority `anchor -> resource_node:water source -> Pilgrim`, used by `ENC-ARPG-07` and `ENC-ARPG-21`.
- `GRP-ARPG-05` Boundary Enforcement: `FAM-ARPG-15 x1 + FAM-ARPG-17 x1 + FAM-ARPG-16 x2`, `seed_ids S010/S056/S060/S111`, link `charge_lock -> boundary_locked`, target priority `charge -> record:writ -> linked_actor:relay`, used by `ENC-ARPG-09` and `ENC-ARPG-22`.

Group additions must be data-only, and a `target_priority` entry in a group may only use the roles in section 1.4.

### 6.2 Variant template

A variant is an encounter or family record with a base ID and explicit overrides. It is used for replay, world-state remix, and late content without copying a family implementation.

Required fields: `variant_id`, `version`, `base_family_or_encounter_id`, `eligibility_condition`, `seed_ids`, `stat_delta`, `action_override`, `roster_override`, `phase_override`, `arena_override`, `reward_override`, `aftermath_override`, `clock_override`, `repeat_policy`, and `known_solution_tags`.

Concrete templates:

- `VAR-ARPG-01` `ENC-ARPG-01-DEEP`: base `ENC-ARPG-01`; eligibility `CL-INST >= 2`; adds one Tally-Skin, changes the Usher target priority to the disputed `record`, and grants `ink_credit x2`; `seed_ids S009/S044/S056`; preserves the same valid seal and marked-sweep counters.
- `VAR-ARPG-02` `ENC-ARPG-07-CIVIC`: base `ENC-ARPG-07`; eligibility `CL-REC >= 2`; replaces one generic grazer with a FAM-ARPG-02 claimant, changes the reward to `petition_seal x1`, and adds a noncombat ration hearing; `seed_ids S039/S048/S061`; keeps resource consumption and anchor link data-driven.
- `VAR-ARPG-03` `ENC-ARPG-15-BLACKOUT`: base `ENC-ARPG-15`; eligibility `CL-CONT >= 2`; removes the normal green timing projection, adds a documented signal relay condition, and changes P3 from a damage phase to a relay-disconnect phase; `seed_ids S013/S047/S072`; does not change the underlying status/break rules.
- `VAR-ARPG-04` `ENC-ARPG-20-QUORUM`: base `ENC-ARPG-20`; eligibility `CL-PER >= 2` or an unresolved clone relationship state; adds a third Sponge, makes the outlier a possible ally on failure, and changes the delayed outcome to an identity route; `seed_ids S005/S032/S106`.
- `VAR-ARPG-05` `ENC-ARPG-24-AUTHORITY`: base `ENC-ARPG-24`; eligibility `CL-CROWN >= 3`; the source record uses a political institution category, one Usher becomes a claimant, and the final proof requires authority plus truth rather than continuity alone; `seed_ids S002/S053/S059/S108`.
- `VAR-ARPG-06` `ENC-ARPG-25-WITHDRAWN`: base `ENC-ARPG-25`; eligibility `G5` filed as `refused` or `P >= 2`; the R8 Crafting Wrangler is replaced by two `FAM-ARPG-01` x1 clerks, the `Course Court` prop becomes a `R5` industrial-permit bench with `region_role: permission_before_transformation`, and P4 Contract Press is removed so the encounter ends at P3; `seed_ids S121/S133/S140`; declared solutions are the medium match, the dispersal action, and the labour-record withdrawal. Removing P4 removes a difficulty, never a counter.

Variants must declare whether an existing action, family, or noncombat proof is the intended solution. They cannot silently remove a valid counter or add a hidden one.

### 6.3 NPC-conversion template

An NPC conversion preserves the NPC's stable identity across neutral, hostile, defeated, escaped, and noncombat states. It is not a reskin in which a dialogue actor is replaced by a new enemy entity.

Required fields: `npc_conversion_id`, `version`, `npc_stable_id`, `seed_ids`, `precondition`, `noncombat_port`, `conversion_trigger`, `combat_family_id`, `combat_roster`, `target_priority`, `identity_continuity`, `post_victory`, `post_failure`, `post_escape`, `post_noncombat`, `relationship_effect`, `world_effects`, `clock_links`, `repeat_policy`, and `aftermath_variants`.

Concrete templates:

- `NPC-CONV-ARPG-01` Threshold Registrar: `npc_stable_id npc_02_orrin_kest`; `region_role: recovery_reentry` (`R1 The Returning Kiln`, with `H0` as the secondary node); `seed_ids S011/S044/S055/S019`; noncombat port is record correction; conversion trigger is a disputed stamp or `CL-INST >= 2`; combat family is FAM-ARPG-02 with one Tally-Skin helper; target priority is `record:name record -> Usher -> Tally-Skin`; victory makes the NPC a persistent `recorded` clerk, failure reopens the queue, escape leaves the claim, and noncombat grants a corrected entry without removing the NPC.
- `NPC-CONV-ARPG-02` Latency Engineer: `npc_stable_id npc_04_sable_halm`; `region_role: intervention_scheduling` (`R3 Bellhouse Hospice`, with `R5` as the secondary node); `seed_ids S013/S014/S018/S024`; noncombat port is maintenance and timing; conversion trigger is a missing `latency_key` or failed service cycle; combat family is FAM-ARPG-05 with one Static Tithe relay; target priority is `linked_actor:relay -> clapper -> Bell`; victory opens maintenance, failure delays the NPC's personal schedule, escape saves the relay but leaves the Bell active, and noncombat restores one service step.
- `NPC-CONV-ARPG-03` Consent Broker: `npc_stable_id npc_05_nera_voss`; `region_role: organ_authority_negotiation` (`R6 Gristmarket Ward`); `seed_ids S004/S028/S079/S087`; noncombat port is organ mediation; conversion trigger is a refused surgery or a player-caused scarline; combat family is FAM-ARPG-10 with two FAM-ARPG-11 Envoys; target priority is `active organ -> record:consent seam -> envoy`; victory preserves the NPC with a changed organ authority, failure repeats the arbitration, escape withdraws consent, and noncombat writes a consent charter while advancing `CL-REC`.
- `NPC-CONV-ARPG-04` Registry Avocator: `npc_stable_id npc_01_ilyra_senn`; `region_role: translation_precedence` (`R4 Crownwell Archive`); `seed_ids S001/S052/S059/S060/S116`; noncombat port is an appeal or root-record challenge; conversion trigger is a copied name after a prior encounter; combat family is FAM-ARPG-18; target priority is `record:source record -> projection`; victory leaves the NPC's name unresolved, failure restores the old record, escape preserves the appeal, and noncombat advances truth without granting the root fragment.
- `NPC-CONV-ARPG-05` Crafting Wrangler: `npc_stable_id npc_14_eda_marrow`; `region_role: magic_training_craft_labor` (`R8 The Folding School`, with `R5` as the secondary node); `seed_ids S133/S140/S153`; noncombat port is labour allocation and refusal, executed together with the `npc_22_iven_marrow` weave-yard grading record; conversion trigger is `G5` filed as `refused`, a withdrawn `craft_credit`, or a player-caused `medium_residue 2`; combat family is FAM-ARPG-19 with one `FAM-ARPG-02` recording clerk; target priority is `record:residue ledger -> Grading Wall -> clerk`; victory leaves the labour record unmerged with the course record, failure withdraws the credit and writes one `overflowed` body-load mark on the NPC, escape spends `lineage_token x1` to reach `E18`, and noncombat takes the labour record and opens `R8-08 Field Probation` instead. The same stable ID is used before, during, and after the encounter; no new actor is created and the NPC is not removed from the region.

No conversion may erase an NPC's relationship state, death/absence state, or prior system ports because the combat actor was removed. A converted NPC can die, flee, survive, reappear, or become a boss variant only through an explicit `resolution_state`. A conversion's support resident is referenced by its own `npc_20_*`-`npc_26_*` ID and is not itself a conversion subject unless it is a canonical core roster member.

## 7. Seed transformation ledger

The rows below reserve idea-ledger units for this file and state the structural change each one is planned to make. Every row is `PLANNED_RETAINED`: a reservation against a not-yet-implemented record, not a `used` or `transformed` finding. A seed is not a name-only reskin: each row changes a local rule, binds it to a system/region/NPC, names two cross-links, and gives immediate and delayed consequences.

| Seed IDs | Local rule and structural transformation | System / region / NPC binding | Cross-link A | Cross-link B | Immediate consequence | Delayed consequence | Generic-risk test | Status |
|---|---|---|---|---|---|---|---|---|
| `S009,S011,S044,S056` | A failed recovery threshold is an institution that classifies the body through a record; a wrong category changes combat. | FAM-ARPG-01/FAM-ARPG-02, `recovery_reentry` (R1), `npc_02_orrin_kest` | `recovery_reentry` ↔ `translation_precedence` | player name choice ↔ NPC registration | stamp, name lock, or source exposure | the record can outlive the person and control route/ending access | The family changes when the record category changes, not when a name is reskinned. | PLANNED_RETAINED |
| `S002,S003,S051,S053,S055` | A role survives its operator; the enemy is a persistent office with a changing holder. | FAM-02, `recovery_reentry` (R1), `npc_02_orrin_kest` | title ↔ Crown of Continuance record | operator change ↔ player route | Name Call binds the current target | a title/role can become a Crown-aligned identity | It remains distinct because the office, not a generic humanoid, owns the action. | PLANNED_RETAINED |
| `S017,S024,S031,S064` | Contamination is a transferable recovery failure with a bounded stack and a quarantine counter. | FAM-ARPG-03/FAM-ARPG-13, `recovery_reentry` (R1) ↔ `resource_allocation` (R2), `npc_13_tovan_reed` | contamination ↔ resource collapse | failed recovery ↔ public record | bloom, seal, or quarantine | a surviving source changes later ecology and archive access | The bug is the transfer rule and aftermath, not a color or monster shape. | PLANNED_RETAINED |
| `S012,S039,S046,S048` | A refusal can be helpful to a person and legally dangerous to an institution; the Ward stores that conflict. | FAM-04, `hub_registration_ration_appeal` (H0), `npc_14_eda_marrow` | labor record ↔ resource debt | refusal ↔ public rumor | stored payload and mirrored claim | a duty, fee, or social label changes access | The encounter changes the claimant's legal state, not only its HP. | PLANNED_RETAINED |
| `S013,S014,S018,S022,S024` | Faith is operational latency; the Bell delays actions and maintenance is a real counter. | FAM-05/16, `intervention_scheduling` (R3) with `permission_before_transformation` (R5) as the secondary, `npc_04_sable_halm` | belief ↔ scheduler | maintenance ↔ institutional response | delay, noised slot, tune/disconnect | service schedule and personal recovery change | The family owns a timing protocol and resource cost. | PLANNED_RETAINED |
| `S020,S021,S023,S044` | Transformation is a permissioned boot process whose legal gate and body result can disagree. | FAM-06/11, `permission_before_transformation` (R5) ↔ `organ_authority_negotiation` (R6), `npc_04_sable_halm` | permit ↔ recognition | body change ↔ social category | seal, suture, or permit resolution | access/employment/relationship state diverges | The body change is bound to contract validation and a consent record. | PLANNED_RETAINED |
| `S069,S070,S072,S073,S078` | High-level interpretation discards low-level error; a partial translation becomes executable local law. | FAM-07, `translation_precedence` (R4), `npc_06_tamas_quill` | cognition ↔ command label | source term ↔ local route | Translation Storm changes the next action | the new term can become an institution or trap | The mechanic is a changed local rule, not a language-themed skin. | PLANNED_RETAINED |
| `S042,S044,S045,S059` | A guardian/registry name can misclassify a person across institution and species categories. | FAM-08, `translation_precedence` (R4) with `recovery_reentry` (R1) as the secondary, `npc_09_perrin_lask` | category ↔ title | name protection ↔ public record | scent, bite, or retag | a wrong category persists through services and relationships | Removing the registry role removes the family rule. | PLANNED_RETAINED |
| `S005,S031,S034,S035` | Recovery removes a command or shifts death cost instead of erasing the failure. | FAM-09, `recovery_reentry` (R1), `npc_13_tovan_reed` | memory ↔ continuity pressure | checkpoint ↔ branch debt | Undo Bite and amnesia | later responsibility or identity debt changes | The Sponge changes what can be remembered and replayed. | PLANNED_RETAINED |
| `S004,S028,S029,S030,S037` | The body is a distributed self whose organs can issue conflicting commands. | FAM-10, `organ_authority_negotiation` (R6), `npc_05_nera_voss` | organ authority ↔ player target | body voice ↔ institutional record | voice lock and priority conflict | treatment/relationship can split from the original self | It is not a monster with organs; the organs are the target and authority system. | PLANNED_RETAINED |
| `S021,S026,S038,S079,S087` | Surgery preserves function while social identity and consent can be lost or redirected. | FAM-11, `organ_authority_negotiation` (R6) with `permission_before_transformation` (R5) as the secondary, `npc_05_nera_voss` | recovery ↔ recognition drift | consent ↔ public record | scarline and recovery lock | healed body returns with a different history | The seam changes the player's recovery and aftermath. | PLANNED_RETAINED |
| `S005,S032,S033,S106` | A clone has shared body/memory inputs but a separate social continuity once one name or role diverges. | FAM-12, `resource_allocation` (R2) with `permission_before_transformation` (R5) as the secondary, `npc_09_perrin_lask` | clone ↔ legal name | group link ↔ resource consumption | outlier and consensus states | independent employment/relationship state and ecological cost | The family is organized by link-breaking and social recognition. | PLANNED_RETAINED |
| `S033,S061,S062,S064,S066` | Many individually legal bodies can destroy an ecosystem through aggregate consumption. | FAM-13, `resource_allocation` (R2), `npc_08_meral_dune` | resource ↔ legality | survival ↔ extraction | Crop Bite/Bloom Feast drains a named resource | local collapse and schedule changes on revisit | The encounter is built around aggregate resource pressure, not a bigger HP bar. | PLANNED_RETAINED |
| `S062,S063,S064,S065,S068` | Safe survival depends on distributed expertise and several simultaneous clocks. | FAM-ARPG-14, `resource_allocation` (R2), `npc_08_meral_dune` | water ↔ knowledge network | rationing ↔ social conflict | chill, denial, and route lock | guide expertise and safe-route knowledge change | The Pilgrim controls a verified resource route, not a generic ice monster. | PLANNED_RETAINED |
| `S056,S058,S060,S065` | A record, a vertical institution, and a crown claim can make a debt more dangerous than the event. | FAM-15, `boundary_crown_precedence` (R7) with `hub_registration_ration_appeal` (H0) as the secondary, `npc_12_ravenna_holt` | record ↔ debt | vertical power ↔ route toll | Audit Charge locks a category | the debt follows the player/NPC across regions | The Ox's signature is a financial/recognition rule with a physical charge. | PLANNED_RETAINED |
| `S047,S048,S050,S114` | Emergency group communication becomes a public command and rumor propagation can be a combat clock. | FAM-16, `intervention_scheduling` (R3) with `hub_registration_ration_appeal` (H0) as the secondary, `npc_10_juno_caster` | private panic ↔ public record | emergency message ↔ scheduler | slot theft and noise | service/rumor states change on revisit | The Tithe changes action availability and communication state. | PLANNED_RETAINED |
| `S010,S012,S041,S111` | A safety manual can be followed exactly while the boundary fails; protocol and world can disagree. | FAM-17, `boundary_crown_precedence` (R7), `npc_07_bryn_oskel` | boundary ↔ recovery failure | safety category ↔ authority | writ and route lock | the wall's mandate can outlive the region | The boss is an unbreakable legal route, not a durable-health gate. | PLANNED_RETAINED |
| `S001,S002,S052,S059,S060,S099,S116` | The Crown of Continuance is simultaneously object, institution, and invariant; its record can interpret a person without explaining itself. | FAM-18, `translation_precedence` (R4), `npc_01_ilyra_senn` | literal object ↔ political institution | operator ↔ abstract invariant | Name Transfer and copied recognition | truth/authority/continuity aftermath changes the ending route | Removing the three-layer Crown model removes the boss's phase and outcome meaning. | PLANNED_RETAINED |
| `S121,S133,S150,S153,S155,S157,S160` (magic supplement) | Craft is concentration, medium, tool, and shape bound to a body that can overflow; a grade is filed whether or not anyone fights. `R8-02`/`R8-05`/`R5-11`/`R5-12`/`R7-09`/`R8-06` are the bindings, so this seed is not R8-only. | FAM-ARPG-19, `magic_training_craft_labor` (R8) with `permission_before_transformation` (R5) and `boundary_crown_precedence` (R7) as secondaries, `npc_14_eda_marrow` + `npc_22_iven_marrow` + `npc_04_sable_halm` | concentration field ↔ body load | shape/medium mismatch ↔ `contract_tally` | residue stack, failed fold, or attached contract obligation | a grade filed three ways (course credit / lineage / refusal) plus one `K` or `P` clock write, never both in one transaction | Removing the measurement-and-grade rule leaves a generic wall with a status bar; renaming the shape instead of filing a grade is the failure this row forbids. | PLANNED_RETAINED |
| `S140` (magic supplement) | Craft recorded outside the school splits into a course record and a labor record, and the split is the conflict rather than a gate. | FAM-ARPG-19/ENC-ARPG-25, `magic_training_craft_labor` (R8) with `resource_allocation` (R2) and `permission_before_transformation` (R5) as secondaries, `npc_14_eda_marrow` + `npc_08_meral_dune` | school course credit ↔ foundry labor hour | circulation slot ↔ neighbour `K`/`E` | noncombat `withdraw and take the labor record`, or a filed grade | the labour record follows the student into R5 and R2 and is re-read at `R8-08` | It is not a tutorial dungeon; removing the record split removes the encounter's noncombat resolution. | PLANNED_RETAINED |

The core range and the magic supplement are written as two separate rows and are never merged into one list. Core rows reserve 65 of the 120 core units; the magic rows reserve `S121`, `S133`, `S140`, `S150`, `S153`, `S155`, `S157`, `S160` - 8 of the 40 magic-supplement units. Nothing here claims audit completion. `used` and `transformed` are recorded only after implementation and play verification, and a `USED` or `TRANSFORMED` planning claim is forbidden.

The Kit-wide accounting belongs to `02` §11.1 and `PLAN_RESOLUTION` §6, and this file does not restate a smaller version of it: core 120 + magic supplement 40 = **160 independent units**, hard gate **96 distinct `PLANNED_RETAINED` transforms**, preferred target **120**. The 72/90 figures of earlier revisions are retired and must not be used here, in `06`, `07`, or `10`.

`02` §11.4's magic-supplement gate applies to every magic row above: a magic seed bound only to `R8` is `unbound`, a magic seed that reads or writes neither a `res_*` key nor a `magic` record field is `unbound`, a magic seed with no `02` §4.4 clock write fails audit, and the positive theory label is not recorded anywhere in this ledger. The magic rows above are bound to `R8` plus `R5`/`R7`/`R2`, read or write `concentration_sample`, `medium_blank`, `fold_sheet`, `blade_credit`, `craft_credit`, `lineage_token`, and `contract_tally` alongside `magic.concentration_fields` and `magic.contracts`, and each carries its clock write.

## 8. Content validation and acceptance gates

The enemy/encounter plan is ready for implementation authoring only when all of the following are true:

- All 19 family IDs resolve, and every family appears in at least one encounter or explicit group/variant template.
- All 25 encounter IDs resolve, with a region id, a region role, roster, target priority, activation, valid/invalid counters, break policy, statuses, phases, linked actors, reward/resource effect, aftermath, clock links, and four outcome branches.
- Every baseline and signature action has a telegraph, a target mode from the six-value enum in section 1.4, a `turn_cost` in 0..5, commitment, recovery, punish window, hit/miss/break reaction, and a non-universal counter path.
- No action, encounter, group, variant, or NPC-conversion record uses a non-canonical target mode, and every `target_priority` entry is either untagged (`actor`) or tagged with one of the five roles in section 1.4. A record or route named as a target is a role statement, not a seventh target mode.
- Every status named in a record is defined in the section 2.2 closed vocabulary, and `silenced`, `overfed`, `concentration_load`, `medium_residue`, `misfolded`, `overflowed`, and `contract_bound` behave as written there.
- Every `region_role` is one of the nine tokens in section 2.6, every record names one of `02`'s canonical nodes as its `region_id`, and a record that spans two regions states the split in `region_secondary` instead of relying on a retired role key.
- Group IDs are `GRP-ARPG-01` through `GRP-ARPG-05`, and each of the five resolves. No sixth group exists, and `06`'s `GRP-ARPG-06`-`GRP-ARPG-12` range is retired in favour of these five.
- `F` outcomes name the `checkpoint` recovery kind only, the seven-value recovery enum is restated exactly, and no record treats Crown alignment as a recovery type. The magic failure grades `recoverable`/`continuity-changing`/`terminal` appear only as grades, never as recovery types.
- Every boss has at least two distinct counter axes across its phases; at least one boss per region group must demonstrate an unbreakable, link-break, resource-lock, route, or noncombat solution.
- No enemy has implicit adjacency, hidden distance weakness, or a visual-only counter. Target priority is data and remains stable when the apparent main body changes.
- Every linked actor has a true target, lifecycle, maximum count, death/escape rule, and cleanup rule, and at most one entry per encounter carries the true target.
- Every phase trigger is one of the authored triggers: encounter start, turn count, cumulative loss, HP ratio, status stack, linked actor death, resource threshold, story/NPC state, relationship state, consent/refusal, or clock threshold. A phase cannot require a new combat algorithm. `FAM-ARPG-19`'s four phases use only status stack, encounter start, and authored resource/story thresholds.
- Every victory, escape, failure, and noncombat outcome changes at least two surfaces or explicitly states that it intentionally changes only the listed clock and reward state.
- Every family and every planned-retained seed has at least two cross-links, an immediate consequence, and a delayed consequence. A seed with only a name, silhouette, or atmosphere is rejected.
- Every seed row in section 7 is `PLANNED_RETAINED`. No row, gate, or handoff step claims a seed as `used` or `transformed` before implementation and play verification. The 160/96/120 accounting is `02` §11.1's and is not restated at a lower value.
- Replay and late-game variants use existing family/action records with explicit overrides; no variant creates a new enemy implementation, and `VAR-ARPG-06` declares its solutions.
- NPC conversions retain stable NPC identity and system ports across neutral, hostile, defeated, escaped, and noncombat states, and every `npc_stable_id` is a canonical `04` §2 ID.
- The magic layer adds no new target mode, no new `ActionDefinition` or `StatusDefinition` key, no new status op, no new phase trigger type, no fifth axis, no seventh clock, and no eighth recovery type. `FAM-ARPG-19` and `ENC-ARPG-25` land with `changed_core_files == []`.
- No source-specific enemy names, original characters, Alice elements, source dialogue, source assets, or recognizable source map/encounter arrangement appear in the authored records.
- Field play must show that a valid noncombat route is readable from world behavior and NPC action, not from a long explanation. Combat play must show target priority, telegraph, counter result, phase change, and aftermath without a constant field HUD.
- Reference-Game play must use at least one field encounter, one charge/Break tutorial, one unbreakable counter, one status/phase boss, one linked-actor boss, one NPC conversion, one companion/relationship outcome, and one late variant without editing combat core.
- Reference-Game play of the `R8` addition must additionally show one concentration-overflow counter, one failed-fold grade, one portal contract obligation that does not auto-resolve, and the noncombat labour-record withdrawal, all with the positive craft name still filed as `untranslated term` until `R4` fills its glossary slot.

## 9. Handoff order

1. Validate family/action/encounter IDs and all required fields.
2. Implement the data loader and validator using the records as authored content.
3. Implement the action scheduler, target selection, status hooks, break policies, phase overrides, and linked-actor lifecycle against the field definitions.
4. Add the 10 baseline field encounters (`ENC-ARPG-01`~`10`) and 14 bosses (`ENC-ARPG-11`~`24`) without adding family-specific branches.
5. Add the five groups (`GRP-ARPG-01`-`GRP-ARPG-05`), six variants, and five NPC conversion templates as data records.
6. **Verify** the five magic statuses, the ten `res_*` magic keys, and the `region_role`/`region_id` pair in `06`'s schema, `06` §6.3's resource registry, and `06` §3.5.4's re-key table. `R-*` 9개 role key와 8-region/17-edge 문구는 이미 retired다(`06` §3.5.4/§5.10/§14.3).
7. Add tests for every valid/invalid counter path, phase trigger, linked death rule, outcome branch, save/load round trip, and clock/aftermath write.
8. Add `FAM-ARPG-19`, `ENC-ARPG-25`, `VAR-ARPG-06`, and `NPC-CONV-ARPG-05` as data records, then re-run step 6's verification and prove `changed_core_files == []` with the pre/post SHA-256 manifest of `07` §14.2.
9. Play the field routes and boss routes at 1280×720, 1920×1080, and 2560×1440, then record unresolved presentation or tuning issues without weakening the data contract.
