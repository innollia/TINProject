# 분할 계획 중앙 해석 — 2026-09-25

이 파일은 `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/` 문서 간 충돌을 해결하는 canonical resolution이다. 각 문서와 구현은 이 해석을 따른다.

## 1. World

- canonical world: `02_WORLD_STATE_AND_ROUTES.md`의 **The Undersign Basin**
- canonical nodes: `H0` hub + `R1`~`R7`
- canonical Crown: `Crownwell Archive`의 `Crown of Continuance` object와 `Crown Protocol`
- `Marrowglass`, `Terminal Ledger Hall`, `Lower Switchyard`, `Crown Alignment Office`는 구버전/독립 초안으로 사용하지 않는다. 다른 문서의 예시 ID는 canonical world로 재키한다.
- `PLAYER_BRIDGE_0`는 canonical NPC/role ID로 재키한다.

## 2. NPCs

- canonical stateful core NPC roster: `04_CHARACTERS_AND_RELATIONSHIPS.md`의 14명.
- `02`의 나머지 named residents는 support residents다. dialogue/resource/state port를 가질 수 있지만 canonical core roster 수에는 넣지 않는다.
- `03`, `06`, `07`의 NPC 이름/ID는 14명 core roster로 re-key한다.
- relationship canonical model: `06_AUTHORED_CONTENT_AND_DATA.md`의 `states[]` + discrete relationship state.
- `04`의 trust/fear/debt/recognition/attachment/agency 값은 state transition의 입력/auxiliary axes다. `04`의 `stance`는 presentation label이며 canonical state를 대체하지 않는다.

## 3. Combat vocabulary

`01_SYSTEM_UX.md`가 닫은 enum의 owner다.

```text
SELF
ONE_ENEMY
ONE_ALLY
ALL_ENEMIES
ALL_ALLIES
RANDOM_ENEMY
```

- `linked_actor`는 target mode가 아니다. actor roster의 linked-death/target-priority role이다.
- `record`, `route`, `resource_node`는 encounter-level target role이다.
- `05`, `06`, `10`은 위 enum을 사용한다.
- `turn_cost`는 정수 `0..5`다.
  - `0`: no-turn, no action slot consumed
  - `1`: normal command, one action slot and scheduler progress
  - `2..5`: committed action, one slot, locked window, additional scheduler cost
- A~H에서 AP label의 의미는 미확정이므로 `AP` resource를 만들지 않는다.
- combat player band는 HP/MP/authored status/action-slot text만 표시한다.
- B 화면의 별도 red bar는 `target_hp_or_condition`로 보존한다. generic red bar와 AP label은 만들지 않는다.

## 4. Save

- `08_SAVE_DEATH_AND_RECOVERY.md`가 root envelope와 death/recovery UX owner다.
- `06_AUTHORED_CONTENT_AND_DATA.md`는 root section 내부의 per-kind allowlist와 JSON projection owner다.
- combat mid-state 저장은 허용하지 않는다. `01`의 charge/reaction restore 요구는 전투 내부 상태가 아니라 pre-command intent와 encounter-level checkpoint로 재정의한다.
- recovery canonical enum은 7개다.

```text
checkpoint
respawn
clone
reincarnation
loop
immortality
institutional_reentry
```

- `crown_alignment`는 recovery type이 아니라 world write다.

## 5. Axes

- named axis token과 integer mapping의 owner는 `02_WORLD_STATE_AND_ROUTES.md`다.
- `06`는 integer `-3..3`을 저장하고 `02`의 mapping table을 참조한다.
- `03`의 별도 3-value ladder는 삭제한다.
- initial matrix의 모든 값은 `02`의 canonical ladder 안에 있어야 한다.

## 6. Seed usage

- core ledger: 120 units, gate 72
- magic supplement: 40 units, gate 24
- total: 160 units, gate 96 distinct `PLANNED_RETAINED` transforms
- preferred target: 120 planned transforms
- `used`와 `transformed`는 구현/검수 뒤에만 기록한다.
- planning 단계의 모든 seed 상태는 `PLANNED_RETAINED`다.
- `USED/TRANSFORMED` planning claim은 금지한다.

## 7. Magic supplement

- magic is a local implementation of the same meta-protocol world, not a separate universe.
- canonical magic is **concentration-mediated craft** (`마나 밀도`) with authored material/medium constraints.
- magic has three authored forms: weave/scroll craft, rigid-fold craft, void-cut portal craft. The name for the broad theory remains a candidate label until story content uses it.
- mana is not a magic-only stat: it has concentration, body accumulation, emission, circulation, injury, and environmental failure.
- magic failure can create environmental/pressure consequences; a spell is not an instant effect.
- new magic-era region/era is an authored module inside the Undersign world and must have a canonical `H0`/`R1`~`R7` or later `R8` entry path.
- magic theory terms are authored in `06` data and must not be hardcoded in module scripts.
- combat textile, portal, and ritual actions are candidate authored action families; they are not guaranteed Reference Game floors.
- body-horror and political absurdism rules apply to magic exactly as they apply to other protocols.

## 8. Relationship, focus, content

- cluster size는 6~12 NPC다.
- `presentation_class`는 content/presentation 공통 enum이다: `neutral`, `official`, `confidential`, `hostile`, `extreme`, `narration`, `unavailable`, `result`. choice는 `neutral|extreme|unavailable|result`만 사용하고, document/verb는 나머지 category를 사용한다. `disabled`는 `availability` 상태다.
- `01`의 focus rule을 owner로 한다: disabled/unavailable도 focusable이며 자동 skip하지 않는다. focus와 disabled state를 별도 표시한다.
- document page cap은 9 lines다. overflow는 validation error다.
- major branch는 6~12 NPC, 2~4 institutions, 2~3 clocks, minimum 2 cross-links per retained seed.
- content runtime은 JSON catalog + module-local loader다. Godot Resource는 presentation reference/optional authoring wrapper일 뿐 canonical identity가 아니다.
- equipment/items는 `06`에 실제 schema와 allowlist를 둔다. `01`이 prose로만 소유하지 않는다.

## 9. Clock and route

- canonical pressure clock은 6개다: institutional response, contamination, public record, resource collapse, personal collapse, crown alignment.
- 각 clock의 stage vocabulary는 `02`가 닫힌 list와 integer mapping을 소유한다.
- 모든 conditional edge는 unlock condition을 가져야 한다.
- 모든 route loop는 실제 adjacency path를 검증한다.
- route gate/resource key vocabulary는 `02`와 `06`이 공유한다.
- `05`의 `region_role`은 `06` RegionDefinition에 field로 추가한다.

## 10. Implementation gate

위 resolution이 문서 간에 반영되기 전에는 구현 파일을 만들지 않는다. 파일별 수정이 끝난 뒤 재검토를 통과해야 한다.
