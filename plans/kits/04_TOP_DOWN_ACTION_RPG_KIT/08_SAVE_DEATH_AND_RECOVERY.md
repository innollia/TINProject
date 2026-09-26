# Kit 04 — SAVE, DEATH, RECOVERY

상태: 실행 설계 문서. 구현·저장 파일 생성·다른 문서 수정은 이 파일의 범위가 아니다.  
입력 정본: `docs/research/top_down_action_rpg/PLAN_RESOLUTION.md`(Kit 04 문서 간 충돌의 canonical 해석), `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`, `docs/research/top_down_action_rpg/IDEA_LEDGER.md`, `docs/MODULE_CONTRACT.md`, `core/services/save_service/save_service.gd`, `docs/ARCHITECTURE.md`, `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/02_WORLD_STATE_AND_ROUTES.md`  
Primary Reference: **BLACK SOULS 2 하나**. death/checkpoint의 실제 화면·연출은 현재 A~H evidence에 없으므로 원작 동작을 추정하지 않는다.  
사용자 메모 recovery seed(`06` catalog 표기 `seed_sNNN`과 동일 unit, `S005` = `seed_s005`): `S005`, `S008`, `S009`–`S012`, `S017`, `S031`–`S035`, `S038`, `S044`, `S056`, `S079`–`S083`, `S085`, `S106`, `S115`, `S116`, `S119`, `S120`.

## 1. 목표와 비목표

이 문서는 `modules/top_down_action_rpg/`가 사용할 module-local save/death/recovery 계약을 고정한다.

- 실행 가능한 목표: versioned JSON-safe state, 단방향 migration, 명시적 checkpoint commit, authored death outcome, continuity type별 복구 범위, world/NPC 후속성, stale reference repair, reset/re-entry, 정확한 수용 테스트.
- **module state root는 이 문서가 소유한다.** root key 집합, section 이름, `state_format`/`save_version`, section 간 소속, load 적용 순서는 여기서 고정한다. 다른 문서가 root key를 새로 만들면 그 문서가 아니라 이 문서가 틀렸다.
- world continuity는 `02_WORLD_STATE_AND_ROUTES.md`의 H0–R7, 네 axis, 여섯 pressure clock, stable region/family/event ID를 따른다.
- 이 문제는 reference game의 모든 저장을 마지막 순간에 원자적으로 자동 저장한다는 뜻이 아니다. 저장은 **commit 경계**에만 쓴다.
- recovery는 death를 없애거나 모든 self를 하나로 복원하는 기능이 아니다. body, memory, role, belief, institution, desire, social recognition 중 무엇이 남는지를 authored data로 구분한다.
- **recovery type은 정확히 7개**다: `checkpoint`, `respawn`, `clone`, `reincarnation`, `loop`, `immortality`, `institutional_reentry`(§7). `crown_alignment`는 recovery type이 아니라 `world.crown` + `crown_alignment_clock`에 쓰는 **global irreversible world write**다(§7.7).
- player의 실제 지식은 save state가 아니다. 이미 아는 해법·암호·공식을 death, loop, rollback, content revision이 다시 발견하도록 강제하지 않는다.
- 전역 시간 역행, 다른 Kit save의 소거, 전역 NPC 기록 삭제는 범위가 아니다.

### 1.1 정본과 소유권 경계

`06_AUTHORED_CONTENT_AND_DATA.md`는 존재하며, save/death/recovery에 필요한 authored 계약과 payload projection을 이미 고정한다. 이 문서는 `06`을 대체하지도, 두 번째 save schema를 다시 정의하지도 않는다. 소유권은 다음 한 줄로 닫힌다.

| 대상 | 소유자 | 이 문서가 주는 것 |
|---|---|---|
| core save **file** envelope(`format_version`, JSON-safe 검사, deep copy, temp/backup 교체) | `core/services/save_service` | 사용 경계만 참조한다. 이 문서가 core envelope 형식을 바꾸지 않는다 |
| **module state root** envelope(root key 집합, section 이름, `state_format`, `save_version`, load 순서, stale 분류) | **이 문서** | §4.2, §4.4, §10 |
| root section **내부** per-kind key allowlist, 값 clamp/sanitize, JSON projection, `catalog_report`, stale drop 알고리즘 | `06` §10 | root section 이름과 token→위치 매핑만 여기서 준다(§4.2.2) |
| authored recovery/checkpoint/region/encounter content(`rec_*`, `prop_*`, `region_*`, `enc_*`) | `06` §5 | continuity 의미와 복구 순서만 여기서 준다(§5, §6, §7) |
| world state vocabulary, axis/clock/route token | `02` §9.1, §3, §4, §5.3 | 저장 위치만 여기서 정한다 |
| combat grammar, action/charge/reaction, target mode, scheduler | `01` | 전투 중간 저장 금지와 pre-command intent 경계만 여기서 정한다(§2.3, §4.3, §5.5) |
| 자동 테스트 ID, 수동 플레이 과제, 해상도 캡처 | `10` | 여기서 판정 oracle을 명시하고 `10`이 이를 그대로 검증한다 |

`06` §10.1/§10.2의 per-section child token은 **이 문서의 root section 이름 안에서** 사용한다. 27개 token은 폐기되지 않고 소속만 바뀐다(§4.2.2). `06`이 root key를 소유하지 않으므로 `06`과 `08`이 양쪽에서 root를 정의하는 상태는 없다.

## 2. 저장 소유권과 lifecycle

### 2.1 소유권

- `SaveService`는 **file** envelope 포맷, JSON-safe 검사, deep copy, file temp/backup 교체만 소유한다.
- `ModuleDirector`는 현재 module capture, manifest version 선택, `migrate_save()` 호출, 새 instance의 `load_state()`→`enter()` 순서를 소유한다.
- `TopDownActionRpgModule`는 domain snapshot의 의미, schema migration, stale ID sanitize, load 적용 순서를 소유한다.
- **module state root envelope은 이 문서가 소유한다**(§4.2). section 내부 key allowlist과 sanitize 구현은 `06`의 module-local catalog가 소유한다(§4.2.2).
- authored recovery/checkpoint/region/encounter content는 `06` §5가 소유한다. 이 문서는 recovery type의 **의미**와 **복구 순서**만 소유한다.
- module은 `SaveService`, 다른 module, `/root`, service locator를 직접 호출하거나 찾지 않는다.
- `save_state()`는 detached JSON-safe `Dictionary`만 반환한다. 저장은 Director/AppRoot의 명시적 capture 경계에서 수행한다.
- 저장 중 presentation focus, hover, dialogue page cursor, target highlight, tween progress, particle, audio, combat gauge animation은 저장하지 않는다. 이 중 world/choice 진행을 결정하는 cursor는 해당 subsystem의 semantic state로 별도 소유한다.

### 2.2 순서

일반 load/transition 순서는 `docs/MODULE_CONTRACT.md`를 그대로 따른다.

```text
validate envelope
→ select stable module ID
→ read module schema_version
→ reject future version
→ duplicate module state
→ migrate old version to current
→ validate migrated JSON safety
→ instantiate module and attach
→ load_state(migrated state)
→ enter(ModuleContext)
→ enable input
```

death/recovery가 module 내부 state machine이면 scene load 없이 다음 순서를 사용한다.

```text
death intent accepted
→ lock gameplay input
→ finish/abort current atomic intent
→ commit death consequence
→ choose authored recovery profile
→ apply rollback boundary
→ apply persistent continuation state
→ rebuild active field/encounter presentation
→ set safe focus
→ enable input
```

crash, future version, malformed envelope, failed content validation 중 어느 경로에서도 현재 playable module과 이전 SaveService state를 부분 변경하지 않는다.

### 2.3 전투 중 저장은 가능하고, 전투 중간 복구는 불가능하다

이것은 우유부단한 절충이 아니라 **닫힌 결정**이다. combat resolution 순서를 save contract에 넣으면 schema가 `01`의 combat 시스템에 종속되고, content가 늘 때마다 core 수정과 `migrate_save`가 같이 늘어나야 한다. `06` §12.2의 `changed_core_files == []` 조건과 `06` §12.3의 예외 2회 한도와 정면으로 충돌한다.

- **전투 중 저장은 금지하지 않는다.** 저장 파일은 전투 중에도 정상적으로 쓰인다. crash-safe와 동일하다.
- **전투 중간 상태로 복구해 resume하는 것은 불가능하게 만든다.** `load_state()`는 전투 내부 진행을 이어가지 않는다.
- `combat` section이 존재하는 것은 전투 중 저장을 허용하기 때문이다. 그 section이 저장하는 것은 **pre-command intent**와 **encounter-level checkpoint 위치**뿐이다(§4.3).
- 복구 결과는 항상 다음 둘 중 하나다: (a) encounter의 authored start/phase 경계에서 재구축, (b) 그 경계에서 저장된 pre-command intent를 재검증해 재queue.
- charge stage, reaction window, `turn_index`, `scheduler_cursor`, actor/status/stance runtime 값, combat RNG position은 **복원하지 않는다.** 복원하는 쪽은 §4.3 `combat`의 금지 목록이고, save에 넣지 않는다.
- `01` §3.1("save에 Node, Resource, Callable, Vector를 넣지 않는다")과 §9.1/§9.4의 queue 검증·late invalidation, `CHARGE-C06`, `SCH-S11`은 모두 이 절의 pre-command intent + encounter-level checkpoint로 재정의된다. combat mid-state resume은 지원하지 않는다.
- encounter RNG는 resume 경계에서 `(run_id, active_encounter_id, attempt_serial)`로 결정론적으로 다시 seed된다. combat position을 저장하지 않으므로 RNG position을 저장할 수도 없다. `run_id`은 root에, `active_encounter_id`와 `attempt_serial`은 `combat` section에 저장된다(§4.2).

## 3. Version contract

### 3.1 네 version을 분리한다

| version | 소유자 | 의미 |
|---|---|---|
| Save **file** envelope `format_version` | core `SaveService` | 전역 봉투/Storage API 호환성 |
| `top_down_action_rpg` module state `save_version` | module manifest/module | module state root schema |
| authored content `schema_version` | module-local content catalog(`06` §2.2) | authored definition shape(kind별 정수) |
| content revision(`content_revision`) | module-local content catalog(`06` §8.3 `catalog_report.content_signature`) | 현재 authored catalog의 동일성 해시 |

초기 구현은 다음으로 고정한다.

- module ID: `top_down_action_rpg`
- `ModuleManifest.save_version = 1`
- module state root의 `state_format = "top_down_action_rpg.save.v1"`
- module state root의 `save_version = 1` — `ModuleManifest.save_version`과 **정확히 같아야 한다.** 다르면 `load_state()`가 attach 전에 거부한다
- content root의 첫 schema version: `1`(`06` §2.2)
- core `SaveService.FORMAT_VERSION` 값은 이 Kit가 변경하지 않는다

같은 정수라도 file envelope, module state, authored content version으로 사용하지 않는다. content version bump만으로 module save migration을 시작하지 않는다.

`content_revision`은 version이 아니다. 저장 시점의 `06` §8.3 `content_signature` 값(sha256 hex 64자)을 **복사**해서 root에 남긴 provenance다. 비교 대상은 항상 "저장된 값" 대 "현재 catalog의 `content_signature`"이며, 불일치면 refuse가 아니라 stale-state resolution(§10)을 실행한다. 이 필드의 이전 이름 `created_content_revision`은 사용하지 않는다.

`02` §9.1이 `world_id`/`schema_version`으로 부르는 것은 이 root의 `run_id`/`save_version`과 같은 것이다. 두 문서가 다른 이름을 쓰지 않는다.

### 3.2 Migration 규칙

- `old_version == 1`이면 deep duplicate 후 validation/sanitize만 한다.
- `old_version < current`이면 `migrate_save(old_version, data)`가 정확한 version-specific 변환을 수행한다.
- migration 단계는 빠짐없이 연속 실행한다. 예: 현재 v3에서 v1은 `v1→v2→v3` 순서다. index 기반 record 위치나 authored array 순서를 identity로 쓰지 않는다.
- `old_version > current` 또는 `old_version < 1`이면 module instance를 attach하기 전에 `ERR_INVALID_DATA`로 거부한다. 미래 버전을 “최신 defaults”로 바꾸지 않는다.
- migration은 deep-detached input을 수정하지 않는다.
- migration 결과가 JSON-safe가 아니면 load를 거부한다.
- migration은 authored content catalog, presentation node, RNG, clock 시간, 현재 scene tree에 접근하지 않는다.
- Structural rename은 migration fixture로 처리한다. 예: `player_pos`→`field.actor.x`. 호환 alias를 현재 state에 계속 남기지 않는다.
- 의미 변경이나 기본값 변경은 version bump다. 새 optional field 추가는 migration 없이 default 처리할 수 있지만, 기존 field의 의미가 달라지면 bump한다.
- authored content ID를 삭제·재명명할 때는 migration 또는 explicit alias table이 필요하다. 이름·array index로 자동 매칭하지 않는다.

각 version bump는 다음을 함께 추가한다.

1. 이전 version의 최소 fixture와 최대-shape fixture
2. migration expected state
3. deep-copy, JSON round-trip, stale reference test
4. 변경하지 않은 다른 module state 보존 test
5. migration 실패 시 current module/envelope rollback test

추가로, root section 안의 key를 추가·제거·이름 변경하면 §4.2.2 매핑표와 `06` §10의 projection allowlist를 **같은 변경에서** 갱신한다. root 변경인데 `06`이 unaware인 상태를 남기지 않는다. `save_version`이 올라가면 `06` §7.2 규칙 3에 따라 `rec_*.preserves`/`discards` token을 참조하는 `rec_*`도 함께 bump된다.

## 4. JSON-safe module state

### 4.1 허용값

허용값은 `null`, bool, finite int/float, string, array, string-key Dictionary뿐이다. 좌표는 Vector가 아니라 `{ "x": number, "y": number }`로 저장한다. enum은 정수 index가 아니라 versioned string token으로 저장한다.

금지값:

- Node, Resource, Scene, Callable, Signal, Object, RID
- Vector2/Vector3/Transform/Color/Quaternion 등 engine Variant
- NaN, Inf, non-finite float
- 숫자 Dictionary key
- anonymous callable, object path, scene node path
- authored definition 전체 복사
- presentation-only state
- wall-clock timestamp를 게임 규칙 input으로 사용
- player의 실제 머릿속 지식

JSON number의 정수/실수 표기 차이는 canonicalizer가 정규화한다. gameplay에 의미 있는 값은 int 범위 안에서 int로 보관한다.

float은 V1 module state에서 **닫힌 2개 필드에만** 허용한다.

| 필드 | 이유 |
|---|---|
| `field.actor.x` | `01` `FIELD-F07`이 walkable이면 복원, 아니면 authored anchor로 fallback하는 요구 |
| `field.actor.y` | 동일 |

이 외 모든 수치는 int·bool·string·null·Array·Dictionary다. 비율·진행도·시간 비율은 정수 permille(0..1000) 또는 정수 percent로 저장하고, 원시 content field도 int로 표현한다(`06` §4.4의 `chance_permille`/`pct_max_hp_<int>` 규칙과 같은 결정). 위 2개 field도 `finite`이고, `JSON.stringify` → `parse` 후 `==` 비교가 **정확히** 성립해야 한다. 성립하지 않으면 그 값은 payload 밖으로 옮기고, float을 늘리지 않는다.

float이 필요해 보이는 field가 나오면 그건 float 저장이 아니라 authored ID 또는 정수 토큰 저장 문제로 먼저 판단한다.

### 4.2 V1 root schema

**root key 집합은 이 문서만 소유한다.** `save_state()`는 아래 root shape를 항상 반환하고, 없는 key는 default로 채운다. root 밖 key가 하나라도 있으면 defect다.

```text
TopDownActionRpgSaveV1
├─ state_format: String                    # "top_down_action_rpg.save.v1"
├─ save_version: int                       # == ModuleManifest.save_version
├─ run_id: String                          # 02 §9.1 world_id
├─ content_revision: String                # 06 §8.3 content_signature 복사본
├─ field
│  ├─ region_id: String
│  ├─ scene_id: String
│  ├─ anchor_id: String
│  ├─ actor: Dictionary                    # {x, y, facing}
│  └─ active_interaction_id: String
├─ combat
│  ├─ active_encounter_id: String
│  ├─ resume_boundary: String
│  ├─ pre_command_intent: Array[Dictionary]
│  ├─ attempt_serial: int
│  └─ result: String
├─ player
│  ├─ body: Dictionary                     # vitals + organ/limb authority + injury
│  ├─ memory: Dictionary
│  ├─ role: Dictionary
│  ├─ belief: Dictionary
│  ├─ institution: Dictionary
│  ├─ desire: Dictionary
│  └─ social_recognition: Dictionary
├─ world
│  ├─ crown: Dictionary                    # {precedence, operator_id, object_phase}
│  ├─ axes: Dictionary
│  ├─ clocks: Dictionary
│  ├─ regions: Dictionary
│  ├─ routes: Dictionary
│  ├─ props: Dictionary
│  ├─ npcs: Dictionary
│  ├─ relationships: Dictionary
│  ├─ encounters: Dictionary
│  ├─ records: Dictionary
│  ├─ resources: Dictionary
│  ├─ magic: Dictionary                      # concentration_fields/body_load/circulation/crafts/contracts/glossary
│  ├─ flags: Dictionary
│  └─ effects_fired: Dictionary
├─ recovery
│  ├─ active_checkpoint_id: String
│  ├─ checkpoint_state: Dictionary
│  ├─ continuity: Dictionary
│  ├─ pending_outcome_id: String
│  ├─ pending_content_error: String
│  └─ history: Array[Dictionary]
├─ progression
│  ├─ equipment: Dictionary
│  ├─ equipment_slots: Dictionary            # weapon/offhand/armor/accessory slot map
│  ├─ items: Dictionary
│  ├─ conversations: Dictionary
│  ├─ documents: Dictionary
│  └─ unlocked_action_ids: Array[String]
├─ transaction
│  ├─ last_committed_event_id: String
│  ├─ last_commit_sequence: int
│  └─ delayed_writes: Array[Dictionary]
└─ commit_log: Array[Dictionary]
```

root key는 12개다. envelope/scalar key 4개(`state_format`, `save_version`, `run_id`, `content_revision`)와 section 8개(`field`, `combat`, `player`, `world`, `recovery`, `progression`, `transaction`, `commit_log`)로 구성된다. `commit_log`는 section이지만 값이 Array다.

`run_id`는 load 사이에 바뀌지 않는 불투명 string ID다. timestamp를 담지 않는다. `content_revision`은 provenance hint이며, 현재 catalog `content_signature`와 같지 않아도 load를 막지 않는다(§3.1).

`pending_content_error`는 `06` §9.5의 `content_unavailable` catalog outcome을 이 root가 받아 두는 자리다. 값이 비어 있지 않으면 §6.3의 recovery surface가 호출된다. presentation/debug에 노출하지 않는다.

#### 4.2.1 section 안의 값

각 section 내부의 key 집합·값 범위·enum·sanitize는 `06` §10이 소유한다. 이 문서는 그 section이 **무엇을 담는 responsibility를 가지는지**만 선언한다.

- `field`: 현재 field 위치와 진행 중 semantic interaction의 owner.
- `combat`: encounter-level checkpoint와 pre-command intent만(§4.3). 전투 내부 진행 없음.
- `player`: world constitution의 7개 self layer. `body`가 vitals를 포함한다.
- `world`: `02` §9.1의 최소 world state + `06` §10.1의 world-side write 기록. `flags`/`effects_fired`는 world write의 idempotency 기록이다.
- `world.magic`는 `concentration_fields`, `body_load`, `circulation`, `crafts`, `contracts`, `glossary` 6 child만 담는다. `res_contract_tally` counter는 저장하지 않고 open contract 수로 재계산한다.
- `recovery`: rollback boundary, continuity head, recovery lineage, pending outcome. §4.3 참조.
- `progression`: authored content의 진행 기록(equipment/equipment_slots/items/conversation/document). combat HP·world axis를 넣지 않는다.
- `transaction`/`commit_log`: world write의 ordering과 idempotency. presentation log가 아니다.

#### 4.2.2 `06` §10.1/§10.2 child token → 이 root 매핑

`06` §10.1/§10.2의 27개 child token은 폐기되지 않는다. root section 이름 안으로 이동한다. `06`은 이 표를 따라 projection allowlist를 갱신하며, **root 자체를 다시 정의하지 않는다.**

| `06` §10.1 key | 이 root 위치 | `preserves` token |
|---|---|---|
| `schema_version` | root `save_version` | envelope |
| `content_signature` | root `content_revision` | envelope |
| `region_id` | `field.region_id` | `region_id` |
| `region_state` | `world.regions[<current>].state` | `region_state` |
| `axis_values` | `world.axes[<axis>].value` | `axis_values` |
| `clock_stages` | `world.clocks[<region>][<clock>]` | `clock_stages` |
| `npc_states` | `world.npcs[<npc>]` | `npc_states` |
| `relationship_states` | `world.relationships[<rel>]` | `relationship_states` |
| `prop_states` | `world.props[<prop>]` | `prop_states` |
| `conversation_progress` | `progression.conversations[<conv>]` | `conversation_progress` |
| `document_reads` | `progression.documents[<doc>]` | `document_reads` |
| `flags` | `world.flags` | `flags` |
| `effects_fired` | `world.effects_fired` | `effects_fired` |
| `encounter_clear_flags` | `world.encounters[<enc>].resolution` | `encounter_clear_flags` |
| `equipment` | `progression.equipment` | `inventory` |
| `equipment_slots` | `progression.equipment_slots` | `equipment_slots` |
| `crown_state` | `world.crown` | `crown_state` |
| `record_states` | `world.records` | `record_states` |
| `resource_states` | `world.resources` | `resource_states` |
| `unlocked_actions` | `progression.unlocked_action_ids` | `unlocked_actions` |
| `concentration_fields` | `world.magic.concentration_fields` | `concentration_fields` |
| `body_load` | `world.magic.body_load` 또는 `player.body.mana_profile` | `body_load` |
| `circulation` | `world.magic.circulation` | `circulation` |
| `crafts` | `world.magic.crafts` | `crafts` |
| `contracts` | `world.magic.contracts` | `contracts` |
| `glossary` | `world.magic.glossary` | `glossary` |
| `recoveries` | `recovery` per-`rec_*` 기록 | `recoveries` |
| `route_flags` | `world.routes[<edge>].gate` | `route_flags` |
| `player_vitals` | `player.body.vitals` | `player_vitals` |
| `combat` | `combat` (§4.3/§5.5로 의미 축소) | `discards` 쪽 |

`preserves` 27개 token과 `discards` 7개 token은 `06` §5.8이 소유한다. 그 **이름은 바꾸지 않는다.** `08`이 바꾸는 것은 위치다. token 이름과 root 위치가 어긋나면 `06` §5.8의 "recovery가 무엇을 보존하는가"와 "save가 무엇을 담는가" 정합성이 깨지므로, token을 추가하려면 root section을 먼저 추가하고 그 반대도 같다.

`06` §10.1/§10.2는 위 root section 이름 아래의 child key allowlist와 `STATE_TOKEN` 27개를 소유한다. `06`은 `08`의 root 12개 key를 다시 정의하지 않는다. 아래 mapping은 현재 canonical projection이다.

1. `world.magic`는 `concentration_fields`, `body_load`, `circulation`, `crafts`, `contracts`, `glossary` 6 child를 갖는다.
2. `progression.equipment_slots`는 `weapon`, `offhand`, `armor`, `accessory` 네 slot map을 갖고, 수량 map인 `progression.equipment`와 분리한다.
3. `res_contract_tally`은 `world.magic.contracts[].obligation_state == "open"`의 개수에서 재계산하며 별도 counter를 저장하지 않는다.
4. `world.magic`의 현재 concentration/field level은 `02` §3.4의 axis가 아니며, magic이 axis를 건드릴 때만 별도 `axis_rules` transaction을 쓴다.
5. `06`의 per-kind child allowlist와 27개 `STATE_TOKEN`이 이 root projection의 정본이다.

### 4.3 State 경계

#### `field`

- `region_id`, `scene_id`, `anchor_id`는 stable authored ID다.
- `actor`는 `{x, y, facing}`다(`x`/`y`는 §4.1의 float 2개). region schema가 허용하는 authored anchor만 있으면 좌표 대신 `anchor_id`로 복원해도 된다. runtime Node path를 저장하지 않는다.
- `active_interaction_id`가 있으면 dialogue/document/encounter의 semantic owner ID만 저장한다. page number, focus node, text scroll, 선택 highlight는 저장하지 않는다.
- combat 진입은 `combat`이 canonical이고 `field.active_interaction_id`에는 encounter ID를 두지 않는다. combat-owned 여부를 한 owner에만 기록한다.

#### `combat`

§2.3의 결정을 그대로 구현한다. 이 section은 **encounter-level checkpoint**와 **pre-command intent**만 저장한다.

- `active_encounter_id`가 비어 있으면 combat 없음. 비어 있지 않으면 이 encounter가 armed 상태다.
- `resume_boundary`는 `"none"`, `"encounter_start"`, `"phase_start"` 3개로 닫힌다. `"phase_start"`는 그 시점의 `enc_*`/roster가 이미 시작 상태를 알 수 있을 때만 허용한다.
- `pre_command_intent[]`는 순서가 의미를 가지는 queue다. 각 item은 `{intent_id, actor_id, action_id, target_actor_id, reserved_resources, action_slot_index}`만 가진다. `intent_id`는 `01` §8.5의 deterministic ID다.
- `pre_command_intent`는 load 시 `01` §9.1의 queue 검증 순서로 **재검증**된다. 검증 실패는 `01` §9.4의 late invalidation 결과로 처리하고 resource를 소비하지 않는다. 저장된 intent를 그대로 신뢰해 실행하지 않는다.
- `attempt_serial`은 이 encounter에서의 재시도 횟수다. `respawn`/`checkpoint` recovery가 이 값을 올린다. encounter RNG seed는 `(run_id, active_encounter_id, attempt_serial)`로 결정론적으로 만든다.
- `result`는 `"none"`, `"victory"`, `"escape"`, `"failure"`, `"parley"` 5개로 닫힌다. `"victory"`/`"escape"`/`"parley"`는 `world.encounters[<enc>].resolution`에 이미 commit된 상태와 함께만 존재한다.
- combat 중간의 animation pose와 effect instance는 저장하지 않는다.
- encounter-local HP/status/phase/turn state는 checkpoint 또는 death recovery에서 rollback된다. 단, `world.encounters`에 이미 Filing된 permanent resolution은 별도로 유지한다.
- linked/summoned actor는 owner ID, spawn generation, true target, alive state를 가진다. runtime instance ID를 identity로 쓰지 않는다.

**`combat`에 저장하지 않는 field(닫힌 금지 목록).** 이 중 하나라도 `save_state()`에 나타나면 root schema 위반이다.

`turn_index`, `scheduler_cursor`, `next_action_slot`, `phase_id`, `actors`, `statuses`, `stance_state`, `charge_stage`, `charge_stage_costs`, `valid_reaction_ids`, `reaction_selection`, `rng_serial`, `rng_state`, `hit_roll`, `dodge_roll`, `critical_roll`, `resolution_phase`, `presentation_event_serial`, `event_serial`.

charge/reaction은 encounter-local 진행이므로 복원 대상이 아니다. 복원되는 것은 **그 charge를 시작하기 전의 pre-command intent**와 **encounter가 어느 경계에서 시작되었는지**뿐이다.

#### `player`

player는 단일 bool이나 HP가 아니라 세계 헌장의 self layer를 그대로 저장한다.

- `body`: vitals(`hp`, `max_hp`, `mp`, `max_mp`, `statuses[]`), organ/limb authority, injury, transformation capability의 semantic state
- vitals는 `06` §10.1의 `player_vitals`를 재키한 것이며 같은 책임이다. `ap`는 넣지 않는다(`PLAN_RESOLUTION.md` §3)
- `memory`: 기억 source, consent, retained/copy/erased 상태. player 개인의 실제 cognition 자체를 복사하지 않는다.
- `role`: job/title/operator/protocol role과 permission
- `belief`: world-authored belief state. 실제 플레이어 믿음과 별개
- `institution`: affiliation, credential, debt, operator claim
- `desire`: 현재 goal/attachment/obligation state
- `social_recognition`: NPC/faction/institution별 recognition token

7개 layer의 이름과 분할은 `06` §5.8 `self_layers_restored`/`self_layers_not_restored`가 참조하는 constitution R04의 7개 층위와 **정확히 같다.** layer를 합치거나 8번째 층위를 추가하지 않는다. 세 번째 상태(부분 이식 등)가 필요해지면 `06` §12.3의 schema bump 절차를 탄다.

#### `world`

`02_WORLD_STATE_AND_ROUTES.md` §9.1의 최소 state를 그대로 module-local dictionary로 구현한다. definition, dialogue text, authored threshold table은 저장하지 않고 stable ID와 현재 값만 저장한다.

- `crown`: `{precedence, operator_id, object_phase}`. `02` §9.1/§9.3의 flat 3개를 이 object로 묶은 것이며, 쓰기 권한은 `G8`/`crown_alignment_clock`에만 있다(§7.7)
- `axes`: axis ID → `{ value, last_write_event_id }`. 값은 `02` §3의 integer ladder로 정규화한다
- `clocks`: region ID → clock ID → `{ stage, tick, last_signal_event_id, committed_event_ids }`
- `regions`: region ID → mutable state(`tag`, `visits`), revisit variant, unresolved debt
- `routes`: edge ID → state, gate progress, alternative edge, route write revision
- `props`: prop ID → 현재 state ID + 방문/재방문 진행
- `npcs`: NPC ID → role, location, system-port state, knowledge boundary, survival/removal/absence result
- `relationships`: relationship ID → 현재 state ID, 방문한 state ID 목록, visited transition 기록. `06` §5.7이 `start_state_id`에서 복원하는 fallback이 이 위치에 적용된다
- `encounters`: encounter ID → permanent resolution/repeat policy와 encounter-local reference
- `records`: record ID → official/rumor/contradictory copy state, authority, filing stage
- `resources`: resource-pool ID → finite amount/unit and access state
- `flags`: `world_` prefix flag ID → bool. `06` §5.10의 `flag` op과 `world_flag_is` 조건이 읽는 대상이다
- `effects_fired`: effect ID → 발화 여부와 횟수. 한 번만 발화해야 하는 effect의 idempotency 기록이다

`world.npcs[<npc>]` 안의 relationship 요약과 `world.relationships`는 **같은 값을 두 곳에 저장하지 않는다.** NPC 쪽은 load 시 `world.relationships`에서 재구축하는 derived index이며, save 대상이 아니다.

#### `recovery`

- `active_checkpoint_id`는 마지막 **commit된** checkpoint다.
- `checkpoint_state`는 그 checkpoint의 local rollback boundary만 저장한다. world 전체 snapshot을 복제하지 않는다.
- `continuity`는 현재 body/memory/role/belief/institution/desire/social recognition의 연결 관계와 recovery type을 저장한다.
- `pending_outcome_id`는 atomic death/outcome 처리 중 provisional ID다. 정상 save 경계에서는 빈 string이어야 한다.
- `pending_content_error`는 `06` §9.5의 catalog outcome이 `content_unavailable`일 때의 복구 surface ID다(§6.3). 그 외에는 빈 string이다.
- `recoveries[<rec_id>]`는 `06` §10.1의 `recoveries`를 그대로 옮긴 것이며, `used_count`/`cooldown_remaining`/`debt_open`을 `06` §5.8 `RecoveryEventDefinition`의 `cooldown`/`authored_debt`와 대조해 판정한다.
- `history`는 recovery 자체의 수 named log가 아니라 authored recovery lineage/event references의 append-only list다. 각 item은 `{event_id, recovery_type, source_checkpoint_id, preserved_layers, discarded_layers, branch_id, world_commit_sequence}`만 가진다.
- `history`와 `commit_log`가 historical ID의 **유일한 tombstone 저장소**다(§10.3).

`active_checkpoint_id`와 `checkpoint_state`는 `06` §5.8의 `preserves`/`discards` token 27/7에 없다. token이 아니라 **rollback boundary record**이므로 token 목록에 넣지 않는다. rollback boundary가 world write가 아니기 때문이다. token과 root 위치가 어긋나면 안 된다는 규칙(§4.2.2)은 world state section에 대해서만 적용된다.

#### `progression`

- `equipment`/`equipment_slots`/`items`는 `06` §10.1 `equipment`/`items`와 `01` 소유 slot 계약을 재키한 것이다. combat HP나 world axis를 넣지 않는다. `equipment`는 보유 수량, `equipment_slots`는 weapon/offhand/armor/accessory map이다.
- `conversations`/`documents`는 `06` §10.1 `conversation_progress`/`document_reads`를 그대로 옮긴 것이다. page index 같은 pixel/presentation 값은 넣지 않는다.
- `unlocked_action_ids`는 authored unlock이 이미 Filing된 경우에만 채운다. `01` combat의 transient action slot 상태를 넣지 않는다.
- relationship, quest/thread, encounter 진행은 이 section이 아니라 `world`에 있다. 한 값을 두 section에 두지 않는다.

#### `transaction` / `commit_log`

- 각 authored event는 모든 validation이 끝난 뒤 한 번 commit된다.
- `last_commit_sequence`는 world write ordering과 stale delayed write 판정에만 쓴다. UI에 표시하지 않는다.
- `delayed_writes`는 `{event_id, target_kind, target_id, earliest_world_revision, payload_id}`를 저장한다. presentation tween은 저장하지 않는다.
- `commit_log` item은 `{event_id, seed_id, source_region_id, target_region_ids, immediate_write_ids, delayed_write_ids, recovery_origin_event_id}`를 저장한다.
- log는 authored narrative transcript가 아니다. payload definition은 content catalog에 있고 ID만 남긴다.
- `last_committed_event_id`는 `06` §5.3 `effects_fired` 및 §8.4 idempotency 판정과 같은 event serial을 쓴다. 두 곳에 다른 serial을 만들지 않는다.

### 4.4 Canonical load

`load_state()`는 다음 순서로 적용한다.

1. deep duplicate
2. root type/version 확인 — `state_format`과 `save_version`이 현재와 다르면 거부 또는 `migrate_save` 재투영
3. root key 집합 확인 — §4.2의 12개 외 key는 제거하고 제거 사실은 module-local load log에 남긴다(§10.3)
4. 모든 section default 및 type/range normalize — 내부 key allowlist과 clamp는 `06` §10.2/§10.3 규칙을 그대로 쓴다
5. finite number 검사 — §4.1의 float 2개 field 외 float이 있으면 거부
6. `content_revision`을 현재 catalog `content_signature`과 비교하고, 불일치 시 stale-state resolution을 실행한다(§10). **불일치만으로 거부하지 않는다**
7. 현재 content revision의 stable ID registry와 대조
8. FK/reference와 graph integrity 검사
9. orphaned/stale state 제거 또는 deterministic fallback 적용
10. world invariant 재계산
11. checkpoint/recovery graph 검증
12. active scene/encounter를 authored start/phase 경계에서 재구성
13. `combat.pre_command_intent`를 `01` §9.1 queue 검증으로 재검증해, 유효한 것만 `01` §9.2 resolution queue에 넣는다
14. encounter RNG를 `(run_id, active_encounter_id, attempt_serial)`로 seed한다
15. field safe anchor 또는 combat pre-command boundary에서 focus/input 활성화

**전투 내부 진행을 이어그리는 단계는 존재하지 않는다.** 12~15번은 encounter를 authored 경계에서 다시 시작하고, 저장된 pre-command intent를 재검증해 재queue하는 것까지가 전부다. `turn_index`/`scheduler_cursor`/charge stage/RNG position을 복원하는 단계는 넣지 않는다.

Normalization은 잘못된 field 하나 때문에 정상 world/NPC/continuity 전체를 버리지 않는다. 단, core identity인 `state_format`, `save_version`, `run_id`, active continuity head가 손상되면 현재 load 전체를 거부한다.

load는 `06` §10.3의 sanitize 순서(allowlist 제거 → ID 재구성 → clamp/dedupe → region fallback → combat 처리 → 파생 재계산 → 일관성 복원)를 **root 수준에서 감싼다.** `06`은 각 section/map 안에서만 동작하고, root section 이름과 section 간 소속은 이 문서가 판정한다.

## 5. Checkpoint 계약

### 5.1 Checkpoint는 world save가 아니다

Checkpoint는 encounter-local rollback 경계다. 다음만 복원한다.

- player body의 combat-recoverable vital/status
- current combat encounter의 authored start/phase policy가 허용하는 local state
- field scene/anchor와 uncommitted interaction
- current region의 local resource/action reservation이 checkpoint semantics상 `rollback_on_death`일 때
- active route traversal 중이던 uncommitted segment

다음은 checkpoint보다 먼저 commit된 상태이므로 복구하지 않는다.

- Filing된 record와 public/contradictory copy
- NPC death/removal/absence와 relationship resolution
- irreversible axis/clock write
- route permission, closure, redirect, unlock
- inventory/equipment/quest commit
- recovery lineage과 continuity debt
- delayed cross-region write
- authored aftermath/revisit variant

`02_WORLD_STATE_AND_ROUTES.md`의 “checkpoint 뒤에는 미commit encounter만 reset” 규칙이 정본이다.

### 5.2 Authored checkpoint는 `06`의 `rec_*`다

checkpoint의 authored schema를 이 문서에서 다시 정의하지 않는다. **checkpoint는 `kind: "checkpoint"`인 `rec_*` 한 개다**(`06` §5.8 `RecoveryEventDefinition`). 위치·배치·interactable은 `06`의 `region_*`/`prop_*`/`npc_*`가 소유하고, encounter 연결은 `enc_*.outcome.on_failure.recovery_event_id`가 소유한다.

| 책임 | 소유자 |
|---|---|
| checkpoint ID, `respawn.region_id`/`prop_id`/`encounter_id`, `reset_prop_ids`, `cost.world_effect_ids`, `seed_ids` | `06` §5.8 `rec_*` |
| checkpoint를 밟는 world object, gate, NPC service | `06` §5.9/§5.10/§5.11 |
| `kind` 별 continuity 의미(7개) | 이 문서 §7 |
| activation 순서와 commit 경계 | 이 문서 §5.3 |
| encounter-level checkpoint와 pre-command intent | 이 문서 §5.5 |
| rollback 대상과 금지 | 이 문서 §5.1, §9 |
| 화면/transition/focus | `09` |

- checkpoint ID와 region ID를 core에 하드코딩하지 않는다.
- checkpoint는 H0 The Undersign Exchange의 recovery/service, R1 The Returning Kiln의 recovery chamber, authored regional site에 배치할 수 있다. 모든 combat boss가 checkpoint를 자동 생성하지 않는다.
- `06` §5.8의 `respawn.encounter_id`는 `checkpoint`/`respawn` 두 kind에서 필수이므로, checkpoint는 복귀할 encounter를 명시적으로 알고 있어야 한다.
- 한 번만 쓸 수 있는지는 `06` §5.8 `cooldown.kind: "once"`가 담당한다. 별도 boolean을 두지 않는다.
- "이 checkpoint가 world write를 만든다"는 판정은 `06` §5.8의 `cost.world_effect_ids`와 `entry_effect_ids`로 표현한다. world write가 없으면 `persist_on_activation`에 해당하는 capture도 발생하지 않는다. **UI에 "자동 저장" 문구를 띄우지 않는다.** world activation feedback으로 처리한다.
- 첫 activation, explicit service activation, death return 중 어느 경로인지는 `recovery.history[]`의 `event_id`와 §6.2 순서로 판정한다. checkpoint마다 별도 reason field를 두지 않는다.

### 5.3 Activation 순서

1. `06` §5.8 `rec_*(kind == "checkpoint")`의 `trigger`/`precondition`을 평가한다.
2. 현재 atomic action/document/choice가 commit 가능한 경계인지 확인한다.
3. encounter-local snapshot을 만든다. snapshot에는 §5.5의 pre-command 경계만 담는다.
4. 현재 `transaction.last_commit_sequence`와 checkpoint ID를 snapshot에 넣는다.
5. `recovery.active_checkpoint_id`를 candidate로 교체한다.
6. authored activation outcome과 `recovery.recoveries[<rec_id>]`를 local commit한다.
7. 모든 target reference와 invariant를 검증한다.
8. 검증 후 candidate가 canonical state가 된다.
9. 해당 `rec_*`가 world write를 만들면 Director/AppRoot가 현재 module state를 캡처한다. world write가 없으면 capture하지 않는다.
10. presentation은 새 canonical state에서만 checkpoint feedback을 만든다.

checkpoint activation은 combat action queue 중간에 snapshot을 만들지 않는다. queued intent가 있으면 먼저 `06` §5.8 `discards`의 `pending_effect_queue` 정책에 따라 authored cancel/finish를 적용하거나 activation을 거부한다. presentation focus나 animation 완료를 기다리기 위해 checkpoint를 pending queue에 넣지 않는다.

### 5.4 Checkpoint 뒤에도 남는 것

- NPC를 죽인 뒤 checkpoint를 갱신하면 그 death는 active checkpoint보다 먼저 Filing되었으므로 유지된다.
- boss를 이긴 뒤 checkpoint를 갱신하면 boss resolution은 encounter-local combat HP가 아니라 `world.encounters`와 `progression`에 Filing된다. death 후 boss를 다시 자연 반복하지 않는다.
- checkpoint보다 뒤에 Filing된 route closure, record category, clone census, organ contract, `world.crown` write는 rollback되지 않는다.
- consumable을 checkpoint 뒤에 사용했다면 death로 복제되지 않는다. 사용과 보상은 `progression.equipment`/`progression.items` transaction으로 commit한다.
- region을 나갔다가 돌아오는 것은 checkpoint return이 아니다. module state를 유지한 re-entry다.

### 5.5 Encounter-level checkpoint: pre-command intent

§2.3의 "전투 중간 resume 금지"를 실제 snapshot으로 만든다. checkpoint는 두 층위다.

- **world checkpoint**: `06` §5.8의 `rec_*`(`kind` = `checkpoint`/`respawn`). §5.1의 rollback 경계. `recovery.checkpoint_state`가 이것만 담는다.
- **encounter-level checkpoint**: `combat` section. encounter가 어느 authored 경계에서 시작되었는지와 그 경계의 pre-command intent만 담는다.

encounter-level checkpoint가 허용되는 경계는 두 개뿐이다.

| boundary | 조건 | 복원 결과 |
|---|---|---|
| `encounter_start` | encounter 진입 직후, 어떤 action도 resolve되기 전 | roster/phase/status를 `enc_*`/`phase_*`의 start 값으로 재구축. intent 없음 |
| `phase_start` | `phase_*` 진입 직후, 첫 action도 queue되지 않은 tick | 해당 phase의 start 값으로 재구축. 직전 `resume_boundary`의 intent 없음 |

snapshot에 들어가는 것은 `01` §8.5의 `intent_id`를 가진 **pre-command intent**와 `reserved_resources`뿐이다. 이미 resolve된 action, 현재 resolve 중인 action, charge stage, reaction window, scheduler cursor는 어떤 경계에서도 들어가지 않는다.

snapshot이 잡히는 시점은 `01` §9.1의 queue 검증이 끝나고 `01` §9.2의 resolution transaction이 시작되기 **직전**이다. 그 시점의 intent는 검증에 통과했고 비용 예약만 아직 소비되지 않은 상태이므로, 재검증 없이 곧바로 commit할 수 있는 유일한 상태다. 그 밖의 시점 저장은 `resume_boundary`를 `encounter_start` 또는 `phase_start`로 되돌리고 intent를 버린다.

`01` §18.2 `CHARGE-C06`가 요구하는 charge/reaction restore는 이 층위로 표현할 수 없다. charge stage와 reaction window는 encounter-local 진행이므로 복원하지 않는다. 대신 charge를 **시작하기 전**의 pre-command intent가 복원되고, charge는 그 intent를 다시 resolve한 결과로 새로 시작된다.

## 6. Death 처리

### 6.1 Death intent

Death는 combat 결과 또는 authored field consequence가 **authored recovery**를 commit할 때 시작한다. 단순 HP 0을 모든 맥락에서 같은 recovery로 보내지 않는다.

authored recovery의 ID와 조건은 `06`이 소유한다. 이 문서는 `death_outcome_id` 같은 별도 authored ID를 만들지 않고 `06`의 정본을 재키한다.

| `06` §5.17 / §5.8 정본 | 이 문서의 의미 |
|---|---|
| `enc_*.outcome.on_failure.death_policy` | 이 encounter 실패가 recovery를 요구하는가 |
| `death_policy: "respawn_checkpoint"` | `06` §5.8의 `respawn`/`checkpoint` `rec_*`를 쓰고, 별도 recovery ID가 없다 |
| `death_policy: "recover_event"` | `recovery_event_id`가 가리키는 `rec_*`를 쓴다 |
| `rec_*.trigger.kind` | `death`, `encounter_failure`, `phase_complete`, `route_enter`, `scripted` 5개가 death를 부르는 정본 경로다 |
| `rec_*.kind` | 선택된 recovery type 7개 중 하나(§7) |
| `rec_*.entry_effect_ids` | 이 문서 §6.2의 "recovery persistent writes" |
| `rec_*.respawn` | 복귀 region/prop/encounter와 `reset_prop_ids` |

`game_over`는 열거에 없다. `06` §5.17이 이미 이 경로를 금지하고 있고, 이 Kit은 항상 recovery 경로를 갖는다. 이름이 다른 8번째 type을 `respawn`으로 만들지 않는다.

- death intent는 idempotent하다. 같은 `event_id`가 두 번 들어오면 두 번째는 no-op이다(`06` §5.3 `repeat_guard`가 `once`/`never_repeat`인 effect와 같은 ID 체계를 쓴다).
- death 발생 즉시 입력을 잠근다.
- 현재 dialogue/document/choice의 provisional state는 commit하지 않는다.
- trigger action의 damage/status/resource/world writes 중 어느 것이 atomic pre-death write인지 `enc_*.outcome.on_failure`와 `rec_*.cost.world_effect_ids`가 명시한다.
- death 자체는 `recovery.recoveries[<rec_id>].used_count`, `recovery.continuity`, 선택된 recovery source를 commit한다.
- death event의 source sequence는 `transaction.last_commit_sequence`로 기록해 어떤 Filing write가 death보다 먼저 있었는지 판정한다. death 전용 sequence를 두 번째로 만들지 않는다.

### 6.2 Death processing 순서

```text
resolve authored death outcome (06 rec_* trigger)
→ stop combat scheduler
→ cancel noncommittable target/dialogue/document intents
→ commit trigger consequences and death marker
→ select recovery type/profile from rec_*
→ validate profile against active checkpoint and continuity head
→ apply checkpoint rollback boundary (§5.1)
→ apply rec_* persistent writes (entry_effect_ids, cost, debt)
→ rebuild destination scene/encounter from rec_*.respawn
→ focus safe authored anchor
→ input enable
→ persist only if rec_* made a world write
```

death 중 저장 파일을 즉시 덮어쓰지 않는다. recovery transaction이 끝난 뒤, 그 recovery가 `cost.world_effect_ids`/`entry_effect_ids`로 world write를 만들었을 때만 Director/AppRoot에 persist request를 낸다. encounter-local reset은 저장을 유발하지 않는다. 저장 실패는 recovery domain commit을 되돌리지 않으며, 현재 module은 playable 상태를 유지하고 명시적 Save를 다시 시도할 수 있다.

### 6.3 Failure

- active checkpoint 없음: `06` §5.8 `respawn.region_id`가 규정한 surface로 이동하거나 `recovery_unavailable` surface를 제시한다. 임의 region 첫 scene으로 teleport하지 않는다.
- `rec_*` definition 없음/손상: module load 또는 recovery commit을 거부한다. `06` §9.3에 따라 referrer가 격리되므로 이 상황은 content validation 단계에서 이미 잡힌다.
- `rec_*` 없음/불허용: 사망 transaction을 되돌리지 않고 `recovery_unavailable`로 실제 world institution의 실패를 보여 준다. 임의 respawn을 고르지 않는다. `06` §5.8의 `recovery_preserves_nothing`/`recovery_kind_violation`과 같은 결정을 화면에서 재발명하지 않는다.
- destination content stale/invalid: checkpoint와 persistent state는 유지하고, 검증된 institutional fallback surface에서 복구한다. 정상 world state를 placeholder로 지운다.
- 저장 실패: in-memory recovery는 유지한다. 다음 명시적 저장에서 동일한 canonical state를 다시 캡처한다.
- `06` §9.5 catalog outcome이 `content_unavailable`: field/combat을 시작하지 않고 `recovery.pending_content_error`에 surface ID를 기록해 §4.4의 load/migration 결과를 버린다. `requested(&"observation", {id: "top_down_action_rpg.content_unavailable", text: ...})`를 1회만 낸다. player 입력은 무시하고 예외를 던지지 않는다. 이 상태에서 world를 계속 플레이하게 두지 않는다. `ready_with_defects`는 이 surface로 가지 않는다(`06` §9.5).

## 7. Recovery type의 continuity 의미

recovery type은 presentation 이름이나 button variant가 아니다. 각 type은 self layer별 continuity contract이다.

**recovery type은 정확히 7개다.** token은 `06` §5.8 `rec_*.kind`의 닫힌 enum과 **글자까지 같다.** 이전 문서에서 쓰던 `checkpoint_return`/`clone_branch`/`loop_rehearsal`/`immortal_continuation`은 아래 표의 canonical 이름으로 **재키**되었다. 별칭을 두 개 붙이지 않는다. `crown_alignment`는 이 목록에 없다(§7.7).

| type | 새 body | memory continuity | role/belief | institution/social continuity | world consequence | 되감는 범위 |
|---|---|---|---|---|---|---|
| `checkpoint` | checkpoint body baseline | checkpoint 범위만 | checkpoint 범위만 | Filing된 history 유지 | 새 death 아님 | uncommitted encounter |
| `respawn` | 같은 continuity 또는 authored 새 body | 보통 유지 | 유지 | 유지/authored 변경 가능 | death cost와 encounter failure가 Filing | encounter-local combat만 |
| `institutional_reentry` | body 또는 role 선택 보존 가능 | source에 따라 partial/copy/erase | 새 protocol role 가능 | 이전 record 삭제 없이 새 category/contradictory copy | continuity debt 증가 | 원 failure가 아닌 우회 |
| `clone` | 새 body identity | source memory의 copy depth를 명시 | 새 개체가 source와 분기 가능 | 자동 name/recognition 공유 금지 | aggregate resource/social cost | source 개체 자체는 rollback하지 않음 |
| `loop` | 보통 같은 body | knowledge/observation 유지 | 선택에 따라 role responsibility 이동 | NPC는 반복을 잊지만 filing/debt는 유지 | loop count와 branch debt 증가 | 해당 loop scope의 local mechanics/action window만 |
| `reincarnation` | 새 body와 새 social actor | retention/cycle policy를 authored explicit 값으로 | 이전 role은 자동 복구하지 않음 | institution/kinship이 새 continuity를 별도 category로 Filing | cycle debt와 delayed social consequence | 현재 incarnation의 local failure만 |
| `immortality` | continuity head 유지, death를 branch/role/record cost로 전환 | 유지되지만 memory damage는 별도 | immortality의 책임은 자동 면제되지 않음 | social recognition은 immortality를 영원히 보장하지 않음 | branch debt, resource/contamination cost | death 자체가 아니며 authored survival rule 적용 |

`06` §5.8의 kind별 강제 조건이 이 표의 대응 규칙이다: `clone`/`reincarnation` ⇒ `social_recognition`이 `not_restored`, `checkpoint`/`respawn` ⇒ `encounter_progress`가 `discards`, `loop` ⇒ `flags` 보존 + `continuity_pressure_delta >= 1`, `immortality` ⇒ `continuity_pressure_delta >= 1`, `institutional_reentry` ⇒ `npc_states`·`document_reads` 보존 + `entry_effect_ids` 비어 있지 않음, 모든 kind ⇒ `respawn.region_id` 필수, `checkpoint`/`respawn` ⇒ `respawn.encounter_id` 필수.

7개 type 모두 `06` §5.8의 `self_layers_restored` ∪ `self_layers_not_restored`이 constitution R04의 7개 층위를 완전 분할해야 한다. 겹치면 `recovery_layer_overlap`, 빠지면 `recovery_layer_gap`이다.

### 7.1 Respawn과 checkpoint

- `respawn`은 death 뒤 같은 encounter를 다시 시도하는 기본 recovery다. 이미 Filing된 world outcome은 반복 commit하지 않는다.
- `checkpoint`는 명시적 facility/return service로 authored checkpoint를 선택하는 recovery다. 모든 death에 checkpoint selection menu를 띄우지 않는다.
- 둘 다 이전 failure를 원상복구하지 않는다. 이전 encounter attempt, temporary combat status, local reservation만 되감는다.
- 둘 다 전투 중간 상태를 되돌리지 않는다. 복귀는 §5.5의 encounter-level checkpoint 경계에서 시작한다.
- NPC가 “당신이 돌아왔다”고 말해도 social recognition이 자동으로 이전과 같다는 뜻이 아니다. recognition layer는 `rec_*`의 layer 분할 결과를 따른다.

### 7.2 Clone

clone은 source 개체를 resurrect시키거나 source와 같은 NPC가 아니다.

- clone 생성 event는 새 `body_id`, 새 `individual_id`, 새 legal/social recognition 후보를 만든다.
- source memory의 retention, snapshot 시점, consent, omission, corruption를 authored data로 기록한다. “memory 공유” flag 하나로 압축하지 않는다.
- source의 이름, role title, inventory ownership, relationship, legal category를 자동 복제하지 않는다. 각 항목의 clone policy를 명시한다.
- clone은 source 개체의 사망/상태 변화를 실시간으로 자동 따라가지 않는다. link는 authored delayed signal로만 전달한다.
- clone aggregate는 world ecology/resource에 영향을 주며, 이는 clone의 memory copy 여부와 별개다.
- player가 어느 clone을 조작했는지는 current continuity head로 저장한다. 과거 source/branch는 NPC와 world record에서 삭제하지 않는다.

### 7.3 Loop

loop는 generic save reload이 아니다.

- loop scope는 authored ID로 지정한다. scope 밖 world state는 절대 rewinding하지 않는다.
- 되감는 대상은 해당 route mechanics, chamber state, NPC action window, encounter attempt 등이다.
- 유지하는 대상은 player knowledge, observed clue, filed record, debt, relationship consequence, resource aggregate, continuity count다.
- NPC가 같은 행동을 반복해도 player knowledge를 공유하지 않는다. NPC memory reset 범위는 authored NPC-local state다.
- loop count와 책임 이동은 persistent continuity consequence다. loop UI 숫자를 상시 노출하지 않는다.
- nested loop/중첩 route는 branch ID와 parent loop ID를 저장한다. 동일 checkpoint로 합치지 않는다.

### 7.4 Reincarnation

- reincarnation은 현재 body가 종료되고 새 incarnation이 시작되는 별도 recovery다.
- 이전 개체의 memory, role, institution claim, social recognition은 전부 이식되지 않는다.
- 기억 유지가 authored mechanic이면 retention depth와 cost/cycle number를 명시한다. memory flag가 false여도 player의 실제 지식이 지워지지 않는다.
- 이전 cycle의 record/debt는 archive 또는 crown record로 남을 수 있다. NPC가 이전 incarnation을 현재 본인으로 자동 인식하지 않는다.
- death UI와 reincarnation UI를 같은 “respawn” label로 합치지 않는다.

### 7.5 Immortality

- immortality는 death prevention, death cost redirection, post-death continuation 중 하나로 authored definition이 명시해야 한다. “death가 화면에서 안 보임”만이 정의가 아니다.
- branch debt는 resurrection 횟수, memory capacity, organ authority, social suspicion, resource extraction, institutional intervention 중 실제 사용하는 축에 commit한다.
- 숫자가 낮아져도 이전 immortality로 얻은 privilege, title, relationship은 자동 삭제하지 않는다.
- death immunity encounter는 combat rule의 예외이며 recovery type을 `immortality`로 자동 승격하지 않는다.
- continuity pressure와 combat HP/state modifier를 같은 값으로 취급하지 않는다.

### 7.6 Institutional re-entry

- institutional re-entry는 대상의 body/memory/role/social category를 기관이 다시 Filing하는 recovery다. 이전 official/contradictory record를 덮어쓰지 않는다.
- `06` §5.8이 `entry_effect_ids` 비어 있지 않음을 강제하므로, 이 type은 항상 world write를 만든다. 따라서 §6.2에 따라 recovery 뒤 persist가 발생한다.
- agency가Filing하는 대상이 바뀌는 순간이므로 `world.records[<record_id>]`의 contradictory copy와 `world.npcs[<npc>]`의 social recognition token이 같이 움직인다. 둘 중 하나만 바뀌는 것은 dead write다.

### 7.7 Crown alignment는 recovery type이 아니라 world write다

`crown_alignment`는 `06` §5.8 `rec_*.kind`의 7개 enum에 **없다.** 그것은 recovery가 아니다. `G8 Crown Precedence`(`02` §6.1)가 `02` §2.1의 root law를 실행하는 **global irreversible world write**다.

| 항목 | 결정 |
|---|---|
| 쓰기 위치 | `world.crown.precedence` / `world.crown.operator_id` / `world.crown.object_phase` (`02` §9.1) |
| clock | `crown_alignment_clock`(`02` §4, `06` §5.6 `kind: "crown_alignment"`) |
| 되돌림 | 불가. `02` §10과 constitution root law에 따라 이전 phase는 revisit archive로만 읽는다 |
| 대상 | player body/memory/role이 아니다. `Crown of Continuance` literal object와 `Crown Protocol`이 유지되고 operator만 교체된다 |
| 저장 | `world.crown.*` 3개 field와 `world.axes["continuity_pressure"]`의 `crown-debt` 값, `world.clocks`의 irreversible stage |

- operator 교체는 `world.crown`에 쓰는 world event다. `recovery.continuity`에 operator를 쓰지 않는다. `recovery` section에 operator/precedence를 두면 그건 recovery가 아니라 world state의 중복 저장이다.
- 이전 operator의 memory는 `world.records` archive copy로 남는다. active `world.crown`에서 지워지지 않는다.
- alignment 이후에도 7개 recovery type은 전부 사용 가능하다. alignment가 recovery를 막거나 recovery가 alignment를 대신하지 않는다.
- 전체 world reset으로 구현하지 않는다. `02` §10의 "recovery가 world state 전체를 초기화하는 shortcut 금지"가 그대로 적용된다.
- 수용 판정은 recovery type continuity matrix가 아니라 §14.6의 world consequence에 있다.

## 8. Persistent NPC와 world consequence

### 8.1 Commit 분류

각 authored outcome/effect는 recovery 정책 중 하나를 명시한다.

| policy | checkpoint/death 처리 | 예 |
|---|---|---|
| `encounter_local` | encounter reset 가능 | boss HP, queued action, temporary arena state |
| `field_transactional` | activation 전 atomic; commit 후 유지 | 문 열기, NPC에게 evidence 넘기기 |
| `filed_irreversible` | checkpoint/death/load로 되돌리지 않음 | NPC death, Filing, legal category, route closure |
| `resource_persistent` | death로 복제/복원하지 않음 | water, medicine, labor, attention, seed 사용량 |
| `delayed_irreversible` | 예약 sequence에서 Filing | clock intervention, remote NPC role change |
| `continuity_persistent` | recovery type 따라 새 개체 연결; 자동 소거 금지 | clone, reincarnation, immortality debt, loop responsibility |

### 8.2 NPC

- NPC death, removal, permanent injury, role replacement는 `world.npcs[npc_id]`에 stable ID로 남는다.
- NPC combat 결과가 `neutral → hostile → ally/removed`일 때 같은 NPC identity를 유지한다. combat skin만 다른 새 NPC를 만들지 않는다.
- death/recovery는 NPC를 authored initial dialogue/role로 되돌리지 않는다.
- NPC가 player death를 봤는지는 NPC-local memory다. loop 안에서는 reset될 수 있지만 public filing은 남는다.
- NPC가 떠난 region에 빈 initial NPC를 재생성하지 않는다. absence result와 replacement NPC는 별도 stable ID다.
- 관계는 단일 affinity number가 아니라 authored history/action refs와 recognition state로 저장한다. recovery type이 이를 자동 초기화하지 않는다.

### 8.3 World

- 이미 committed된 axis/clock/route/record/resource/continuity write는 checkpoint보다 우선한다.
- recovery 자체도 immediate consequence와 delayed consequence를 모두Filing한다.
- delayed consequence의 target이 stale하면 definition validation 단계에서 content load가 실패한다. 이미 save된 orphan delayed write를 조용히 버려 world rule을 위반하지 않는다.
- revisit variant는 recovery type, source region state, record category, clock threshold, NPC absence, crown precedence를 읽는다. recovery ID만 보고 단일 cutscene을 재생하지 않는다.
- death 횟수, retry count, loop count는 progression telemetry가 아니라 authored consequence input일 때만 persistent state에 둔다.

### 8.4 중복 방지

- event/choice/effect ID는 한 run 안에서 idempotent하다.
- local commit 전에 기존 `commit_log`에 같은 `event_id`가 있으면 동일 결과를 재적용하지 않는다.
- File/Load/Death/Recovery가 같은 state를 반복해도 reward, contamination, relationship, record filing이 중복되지 않는다.
- encounter reward는 world inventory/quest commit과 함께 atomic이다. 일부만 commit되지 않는다.

## 9. Rollback 범위와 금지

### 9.1 허용 rollback

- invalid intent가 만든 provisional target/action/choice selection
- checkpoint 이전의 uncommitted encounter-local combat state
- atomic event validation 실패 중 아직 canonical state에 반영되지 않은 temporary 값
- death recovery가 명시한 field-local resource reservation
- NPC-local loop action window

### 9.2 금지 rollback

- Filing된 NPC death/removal/absence
- player가 이미 발명한 해법/암호를 다시 미발견 상태로 만드는 장치
- canonical/contradictory record 삭제
- irreversible clock/axis/crown write 복구
- route permission 철회
- inventory/resource/equipment/quest의 death 복제
- clone source 개체를 clone outcome으로 덮어쓰기
- reincarnation 전 개체의 archive debt 삭제
- immortality branch debt 감소
- loop 밖 region의 world state 초기화
- 다른 module/AppRoot/meta의 state
- death 후 world 전체 `load_state({})`
- stale ID를 빈 dictionary 조용히 지워 narrative를 완료 처리

### 9.3 Idempotency 경계

파일 저장, load, re-entry, death, loop, recovery가 같은 boundary를 반복해도 authored effect는 한 번만Filing된다. 단, authored repeat policy가 명시한 repeatable encounter/loop action은 새 `event_id` 또는 `iteration_id`로 별도 commit된다.

## 10. Stale ID와 schema/content drift

이 절은 **분류 정책**을 소유한다. 어떤 map에서 어떤 ID를 drop하고 어떻게 clamp하는지는 `06` §10.3이 소유하며, `10` §5.2는 이 표가 있으면 그대로 검증한다. 이 문서와 `06`이 서로 다른 결과를 만들면 `10`의 stale-ID test가 실패한다.

`06` §9.6의 구분을 이 문서도 그대로 쓴다. **content duplicate와 stale save reference는 섞지 않는다.** duplicate는 load 실패(`06` §9.1), stale은 load 성공(`06` §10.3).

### 10.1 Stable ID 규칙

- 모든 region, scene, anchor, event, family, NPC, encounter, record, checkpoint, recovery event, axis, clock, route, resource pool은 authored stable string ID를 가진다.
- ID 문법과 namespace는 `06` §3이 소유한다. 이 문서는 ID를 **migration/save key로만** 쓴다.
- display name, dialogue text, array index, scene node path, runtime instance ID는 migration key가 될 수 없다.
- ID는 삭제 후 재사용하지 않는다(`06` §3.3-3). 삭제 ID는 `commit_log`/`recovery.history`의 tombstone으로 보존한다.
- 참조는 가능하면 ID→state dictionary로 저장한다. 순서가 의미 없는 set을 array로 저장하지 않는다.
- authored 순서가 의미를 가지는 queue만 array를 허용한다. 현재 V1에서 그런 array는 `combat.pre_command_intent`, `transaction.delayed_writes`, `recovery.history`, `commit_log` 4개뿐이다.
- `world.crown`의 `operator_id`는 recovery가 아니라 `G8` world write가 만든다. recovery가 이 ID를 만들지 않는다(§7.7).

### 10.2 Load-time reference classification

| 참조 종류 | 정책 | 실행 위치 |
|---|---|---|
| optional NPC/prop/flag/effect/encounter state | ID가 stale이면 해당 entry를 제거하고 다른 state는 유지 | `06` §10.3 |
| completed historical event/log | `commit_log`/`recovery.history` tombstone으로 보존하고 definition 참조를 끊지 않음 | 이 문서 §4.3 |
| `field.active_interaction_id` | 같은 region의 authored default anchor로 fallback | `06` §10.3 `region_id` fallback |
| `field.anchor_id` | walkable이면 복원, 아니면 authored default anchor | `01` `FIELD-F07` |
| `recovery.active_checkpoint_id` | stale이면 load 거부. 임의 checkpoint로 바꾸지 않는다 | `06` §9.3 referrer 격리 |
| `recovery.pending_outcome_id`의 `rec_*` | stale이면 recovery commit 거부 | `06` §9.3 referrer 격리 |
| `recovery.continuity`의 layer/lineage | stale이면 해당 layer만 `06` §5.8 `start_state_id`로 복원하고 lineage item은 tombstone 처리 | `06` §10.3 step 8 |
| `world.records`/contradictory copy | stale이면 `recovery_unavailable` surface. 이전 Filing을 지우지 않는다 | `06` §10.3 step 8 |
| route target/alternative | content manifest가 route closure/replacement를 명시한 경우에만 fallback; 아니면 invalid content | `02` §5.3 |
| `transaction.delayed_writes` target | stale이면 invalid content; 자동 폐기 금지 | `06` §9.3 |
| `state_format`/`save_version` 불일치 | future면 attach 전 `ERR_INVALID_DATA`, past면 `migrate_save` 재투영 | `docs/MODULE_CONTRACT.md` |
| `content_revision` 불일치 | 거부하지 않는다. 위 stale 처리를 모두 실행하고 module-local load log에 남긴다 | `06` §10.2 규칙 6 |
| `catalog_report`가 `content_unavailable` | `recovery.pending_content_error` surface로 진입, player 입력 무시 | `06` §9.5 |

### 10.3 Orphan과 historical ID

- **tombstone 저장소는 `commit_log`와 `recovery.history` 두 곳뿐이다.** save 안에 별도 `orphaned_record_ids` 목록을 두지 않는다. `06` §8.3의 `catalog_report`도 저장하지 않는다.
- historical ID는 이 두 목록의 `event_id`/`seed_id`로 남으므로, 대응하는 definition이 없어도 과거 사실은 읽을 수 있다.
- optional stale entry의 실제 drop과 그 사실의 기록은 `06` §10.3이 수행한다. 기록 위치는 module-local load log이며 `catalog_report`가 아니다. `catalog_report`는 load 시점의 content 상태이고 load log는 save 상태에 대한 판단이므로 둘을 섞지 않는다.
- `06` §9.3에 따라 production Reference Game에서 unresolved **required** orphan이 하나라도 있으면 catalog outcome이 `content_unavailable`이므로 §6.3 surface로 들어간다. optional orphan은 gameplay gate에 쓰지 않는다.
- `prop_states`/NPC/flag처럼 optional map의 stale entry는 drop한다. `initial_state_id`로 되돌리지 않는다. 존재하지 않는 world state를 발명하지 않는다는 `06` §10.3의 결정을 이 문서도 따른다.
- stale ID를 encounter roster나 region list의 “다음 항목”으로 대체하지 않는다.
- load repair는 headless test와 실제 화면에서 동일 `content_revision`으로 검증한다.

### 10.4 Renaming

- stable ID rename은 `content_revision` change와 module save migration을 요구한다.
- migration은 explicit `old_id → new_id` table만 사용한다.
- 두 ID가 동시에 현재 catalog에 있으면 ambiguous rename으로 실패한다(`06` §3.3-1, ID 재사용 금지).
- historical log는 원 ID를 보존하고 새 active reference만 새 ID를 쓴다.
- rename은 `06` §12.4 순서(참조 제거 → 대상 변경 → index 갱신)를 따른다. `06` §3.3-2에 따라 rename 전까지 옛 ID는 alias가 아니라 stale ID다.

## 11. Reset과 re-entry

### 11.1 Reset 범위

reset은 명시된 scope의 canonical state만 재생성한다. “전부 초기화”는 없다.

| command/surface | scope | 유지 |
|---|---|---|
| `reset_encounter` | active uncommitted combat encounter | world, NPC, record, inventory, relationship, continuity |
| `reset_interaction` | current uncommitted dialogue/document/choice transaction | filed result, inventory/record commit |
| `reset_current_region` | current region의 encounter-local/field-local provisional state | filed region write, NPC permanent state, other regions |
| `reset_run` | destructive confirmation 뒤 authored new run | OS/player meta knowledge; 이전 run 파일; 다른 module state 명시 필요 |
| death recovery | `06` `rec_*.kind`가 지정한 checkpoint/continuity scope | 위 §5–§8의 persistent state |

- `execute_command(&"reset")`는 reset surface/confirmation만 연다.
- 실제 reset은 `reset_confirm` 또는 stable authored command로 실행한다.
- cancel은 byte-equivalent canonical state를 유지한다.
- `reset_run`은 player가 새 world identity를 즉시 시작하게 한다. **새 `run_id`를 발급하고, 이전 run의 저장 파일을 덮어쓰지 않는다.** 저장 파일의 storage key와 교체는 core `SaveService`가 소유하고 이 Kit은 `run_id`와 `content_revision`만 준다. `06`은 content ID/schema를 소유할 뿐 run storage를 소유하지 않으므로, 여기서 storage 구현을 보류할 이유가 없다. 이전 run을 나중에 명시적으로 지우는 surface는 두지 않는다.
- `reset_encounter`는 §5.5의 `resume_boundary: "encounter_start"`와 빈 `pre_command_intent`를 만드는 것과 같다. 전투 내부 snapshot을 되돌리는 경로가 아니다.
- 저장된 progress가 없는 상태에서 reset confirmation을 열면 canonical fresh state와 비교해 “reset할 변화 없음”으로 닫는다.

### 11.2 Re-entry

재진입에는 두 종류가 있다.

1. **module re-entry**: 같은 `top_down_action_rpg` GameModule을 exit/free 후 다시 instance화한다. `load_state()`가 canonical state를 복원하고, presentation은 clean start다. 저장된 combat이 mid-action 경계가 아니면 load가 아니라 §5.5의 encounter-level checkpoint를 적용한다(§2.3).
2. **region/scene re-entry**: module은 유지한 채 field anchor와 authored revisit state를 재구성한다. NPC presence, record, resource, route, encounter permanent result를 definition initial state로 덮어쓰지 않는다.

다음은 re-entry에서 초기화해도 된다.

- transient signals, particles, audio loop
- combat bar animation phase
- hover/focus/selection
- dialogue page pixel 위치
- current target highlight

다음은 유지/재계산해야 한다.

- canonical world/NPC/progression/continuity state
- player body/memory/role/social layers
- current route 및 uncommitted traversal segment
- encounter permanent resolution
- active checkpoint와 source sequence
- semantic active interaction의 source event

## 12. Authored recovery schema의 소유권

core는 recovery type별 special-case script를 쌓지 않는다. **authored recovery schema는 `06` §5.8 `RecoveryEventDefinition`(`rec_*`) 하나이며, 이 문서는 그것을 다시 정의하지 않는다.**

`06`은 이미 `id`, `kind`(7개 closed enum), `trigger`, `preserves`/`discards`, `self_layers_restored`/`self_layers_not_restored`, `respawn`, `cost`, `entry_effect_ids`, `cooldown`, `authored_debt`, `seed_ids`를 확정하고 `TopDownValidateRecovery`로 검증한다. 이전 이 문서의 `RecoveryOutcomeDefinition`/`RecoveryProfileDefinition`은 여기서 **삭제한다.** 같은 의미를 두 파일이 다르게 말하는 상태는 남기지 않는다.

- 이전 이 문서의 `destination_region_id`/`destination_scene_id`/`destination_anchor_id`는 `06` §5.8 `respawn.region_id`/`prop_id`로 흡수된다. `respawn`은 `06` §5.9의 `prop_*` ID를 쓴다.
- 이전 `rollback_scope_ids`/`preserve_scope_ids`는 `06` §5.8 `discards`/`preserves`로 흡수된다.
- 이전 `persist_after_recovery`는 별도 field가 아니다. `rec_*`의 `world_effect_ids`/`entry_effect_ids`가 world write를 만들면 §6.2가 persist한다.
- 이전 `recovery_message_id`는 `recovery` section의 값이 아니다. recovery surface/메시지는 `09`가 소유하고 (§5.2 표), ID 참조만 authored content가 가진다.
- 이전 `memory_policy`/`body_policy` 등 per-layer 다항 정책 token은 **삭제한다.** `06` §5.8의 이진 분할(`self_layers_restored` ∪ `self_layers_not_restored`)이 canonical이다. 부분 이식 같은 세 번째 상태가 필요해지면 `06` §12.3의 예외 절차를 통해 schema bump로 얻는다. 이 문서가 policy token 목록을 만들어 `06`의 validator와 어긋나게 하지 않는다.
- 이전 `clone`/`loop`의 새 individual/lineage ID 정책은 `06` §5.8 `authored_debt.debt_id` + `recovery.history[].branch_id`로 표현된다. lineage 저장 위치는 `recovery` section이다(§4.3).

### 12.1 이 문서가 계속 소유하는 invariant

schema가 아니라 **의미**이므로 `06` schema와 1:1이 아니어도 된다. 이 문서가 판정하고 `10`이 검증하는 invariant는 다음뿐이다.

- 모든 layer는 명시되어야 한다. omitted layer는 “전부 유지”로 해석하지 않는다(`06` §5.8의 `recovery_layer_gap`과 같은 판정이다).
- `clone`은 새 individual ID를 만들거나 source ID를 재사용하지 않는다.
- `loop`는 persistent scope과 nonrollback scope를 각각 하나 이상 명시한다.
- `reincarnation`은 source lineage와 current incarnation을 별도 ID로 둔다.
- `immortality`는 실제 branch debt/resource/consequence write를 하나 이상 만든다.
- `institutional_reentry`는 새 record/category write를 하나 이상 만들고 이전 record 보존 policy를 갖는다.
- destination은 authored physical surface다. hidden teleport로 정의하지 않는다.
- required target/effect가 stale하면 recovery commit이 실패한다.
- recovery type은 7개 밖의 값을 받지 않는다. `crown_alignment`는 `rec_*.kind`로 들어올 수 없다(§7.7).

## 13. 구현 시 owned files

다음 책임만 제안한다. `06_AUTHORED_CONTENT_AND_DATA.md`는 존재하며 그 §11.1 unit 목록과 `10_TESTS_AND_ACCEPTANCE.md`의 test ID가 정본이다. 이 목록은 `08`이 소유하는 save/recovery 쪽 unit만 담고, `06`의 `content/` unit을 다시 선언하지 않는다.

```text
modules/top_down_action_rpg/
├─ module.gd
├─ save/
│  ├─ save_state_v1.gd            # root key 12개 + section 소속 검사
│  ├─ save_migrations.gd
│  ├─ save_validator.gd           # root 수준 JSON-safe/float allowlist/version
│  ├─ stale_reference_repair.gd   # §10.2 분류. ID drop/clamp는 06에 위임
│  └─ recovery_resolver.gd        # §6.2, §7, §5.5 순서
└─ tests/fixtures/save/
   ├─ v1_minimal.json
   ├─ v1_maximal.json
   ├─ stale_ids_v1.json
   └─ mid_combat_v1.json          # §2.3 금지 field가 들어간 거부 fixture

tests/core/
└─ test_top_down_action_rpg_save_recovery.gd
```

- `modules/top_down_action_rpg/authored/`에 recovery definition GDScript를 두지 않는다. authored recovery는 `06`의 `content/recovery/rec_*.json`과 `TopDownValidateRecovery`가 소유한다. `06` §11.2가 `Resource`-based content class를 rejected로 판정한 결정을 이 문서가 뒤집지 않는다.
- save codec와 validator는 authored content ID별 `match`를 갖지 않는다.
- recovery resolver는 `H0`, `R1`, NPC 이름, boss ID, `rec_*` ID를 알지 않는다.
- persistence orchestration은 Director/AppRoot 경계를 유지한다.
- recovery type을 추가하려면 `06` §5.8 schema bump 절차(예외 2회 한도)를 탄다. 이 문서에서 `08`만 고쳐 recovery type을 늘리지 않는다. `PLAN_RESOLUTION.md` §4에 따라 8번째 type은 열지 않는다.

## 14. 자동 수용 기준

모든 테스트는 fake authored catalog 또는 최소 실제 Reference Game content를 명시적으로 로드한다. 빈 scene에서 core helper만 호출하는 테스트를 save/recovery 완료 증거로 세지 않는다.

아래 항목은 `10_TESTS_AND_ACCEPTANCE.md` §7의 `test_top_down_action_rpg_save_recovery.gd` test ID와 1:1로 대응한다. `10`과 이 절의 oracle이 일치하며, `PLAN_RESOLUTION.md` §4가 우선한다.

### 14.0 Root envelope 소유권

- [ ] `save_state()`의 root key 집합이 §4.2의 12개와 **정확히** 같다(allowlist 밖 key 0개, 빠진 key 0개).
- [ ] `state_format == "top_down_action_rpg.save.v1"`, `save_version == ModuleManifest.save_version`가 매 save마다 성립한다.
- [ ] §4.2.2 매핑표의 `06` §10.1 19개 key가 각각 지정된 root 위치에 있고, root에 flat key가 남지 않는다.
- [ ] `06` §10.1의 19개 `preserves` token이 root `world.*` section에 1:1로 대응하고, 나머지 8개는 `field`/`player`/`progression`/`recovery` section에 대응한다(§4.2.2).
- [ ] root key를 `06`과 이 문서가 각자 정의한 상태가 아니다. `save_state_v1.gd`가 §4.2 목록을 단일 보유한다.
- [ ] `content_revision`이 `06` §8.3 `catalog_report.content_signature`와 같은 문자열 규칙(sha256 hex 64)이다.
- [ ] payload의 float은 `field.actor.x`/`field.actor.y` 2개 field에만 존재하고 `JSON.stringify`→`parse`→비교가 정확히 같다.
- [ ] `player.body`에 `ap` resource가 없고, `world.crown` 3개 field 외에 operator/precedence가 다른 section에 중복 저장되지 않는다.
- [ ] `catalog_report.outcome == "content_unavailable"`이면 `recovery.pending_content_error` surface로 들어가 player 입력을 무시하고, `ready_with_defects`는 그 surface로 가지 않는다.
- [ ] `content_revision` 불일치만으로 load가 거부되지 않고 §10의 stale 처리가 실행된다.

### 14.1 Version / JSON / migration

- [ ] manifest ID가 `top_down_action_rpg`, `save_version = 1`, entry scene과 input actions가 유효하다.
- [ ] fresh `save_state()`는 `state_format`, `save_version`, `run_id`, `content_revision`와 8개 section을 반환한다.
- [ ] `SaveService.is_json_safe(save_state())`가 true다.
- [ ] `JSON.parse_string(JSON.stringify(save_state()))` 후 canonical state가 같다.
- [ ] returned snapshot을 변형해도 module/canonical state가 변하지 않는다.
- [ ] Vector/Node/Resource/Callable/number key/NaN/Inf를 포함한 state는 `load_state()` 또는 migration prevalidation에서 거부되고 이전 runtime state가 유지된다.
- [ ] `migrate_save(1, v1_fixture)`는 deep-copy 정규화 후 canonical v1과 같다.
- [ ] v2+로 bump할 때 v1 minimal/maximal fixture가 expected vCurrent로 변환된다.
- [ ] continuous migration이 fixture 순서와 무관하게 같은 결과를 만든다.
- [ ] future version은 current module을 attach/load하지 않고 `ERR_INVALID_DATA`로 거부한다.
- [ ] migration failure는 current GameModule instance, SaveService envelope, global state를 모두 보존한다.
- [ ] migration은 authored content definition을 변경하거나 duplicate하지 않는다.
- [ ] root section 추가가 `save_version` bump 없이 가능한지 확인하고, bump가 필요한 변경이면 §4.2.2 매핑표와 `06` §10 projection allowlist가 같은 변경에서 갱신된다.

### 14.2 Canonical round-trip / transition

- [ ] field에서 dialogue/document/choice를 거쳐도 semantic source event와 choice availability가 round-trip된다.
- [ ] module exit→새 instance→`load_state`→`enter` 후 canonical state와 gameplay outcome이 같다.
- [ ] load 후 focus/hover/animation은 저장되지 않고 authored safe focus가 선택된다.
- [ ] load 중 input은 비활성이고 `enter` 전 gameplay command가 실행되지 않는다.
- [ ] load 후 다른 module/AppRoot/meta state는 바뀌지 않는다.
- [ ] file main corruption은 core backup recovery, backup도 실패하면 current state 보존을 따른다.

### 14.3 전투 중간 resume 금지 / pre-command intent

- [ ] `mid_combat_v1.json` fixture(§4.3 금지 목록 field 포함)를 `load_state()`하면 거부되고 이전 runtime state가 유지된다.
- [ ] 전투 중에도 저장은 정상적으로 성공한다(저장 금지 판정이 아니다).
- [ ] `encounter_start` 경계로 저장→load하면 roster/phase/status가 `enc_*`/`phase_*` start 값으로 재구축된다.
- [ ] `phase_start` 경계로 저장→load하면 해당 phase start 값으로 재구축된다.
- [ ] 저장된 `pre_command_intent`는 `01` §9.1 queue 검증으로 재검증되고, 검증 실패 항목은 `01` §9.4 late invalidation 결과로 처리되며 resource를 소비하지 않는다.
- [ ] `pre_command_intent`의 순서가 round-trip 후 동일하다.
- [ ] load 후 `turn_index`/`scheduler_cursor`/`phase_id`/actor/status/stance/charge stage/reaction/RNG serial이 복원되지 않는다(recursive scan).
- [ ] encounter RNG가 `(run_id, active_encounter_id, attempt_serial)`에서 결정론적으로 재현되고, 같은 입력은 같은 roll 순서를 낸다.
- [ ] `respawn`/`checkpoint` recovery가 `attempt_serial`을 올리고 그 결과로 encounter RNG가 다시 seed된다.
- [ ] charge/reaction 진입 전 intent를 저장→load하면 charge가 복원된 intent를 다시 resolve한 결과로 **새로 시작**된다. charge stage나 reaction window가 복원되지 않는다.

### 14.4 Checkpoint

- [ ] checkpoint activation은 `recovery.active_checkpoint_id`와 encounter-local snapshot을 원자적으로 commit한다.
- [ ] invalid activation은 checkpoint ID, combat, inventory, world, NPC을 바꾸지 않는다.
- [ ] checkpoint가 world write를 만들면 Director/AppRoot capture를 한 번 요청하고, world write가 없으면 capture하지 않는다. 어느 쪽도 auto-save HUD를 띄우지 않는다.
- [ ] checkpoint activation 중 queued intent가 있으면 `06` §5.8 `discards` 정책으로 cancel/finish하거나 activation을 거부한다. presentation animation 완료를 기다려 pending queue에 넣지 않는다.
- [ ] checkpoint 전에Filing된 NPC death/removal, Filing record, route closure, resource use는 death 뒤에도 남는다.
- [ ] checkpoint 뒤 Filing된 cross-region delayed write도 death 뒤 scheduled sequence에서 실행된다.
- [ ] checkpoint 전 boss HP/phase/action queue만 reset되고 이미 Filing된 boss resolution/reward는 유지된다.
- [ ] consumable 사용 후 death로 item이 복제되지 않는다.
- [ ] 동일 checkpoint activation event는 두 번 reward/commit하지 않는다.

### 14.5 Death / rollback

- [ ] authored death outcome은 input을 잠그고 current atomic resolution 경계를 따른다.
- [ ] 같은 death event ID의 중복 입력은 두 번째 death/recovery를 만들지 않는다.
- [ ] death는 encounter-local combat을 되돌리지만 pre-death Filing world write를 지우지 않는다.
- [ ] invalid action의 provisional state는 canonical state에 남지 않는다.
- [ ] death 중 target/dialogue/document focus는 저장되지 않는다.
- [ ] recovery destination은 `rec_*.respawn`이 가리키는 authored physical surface이며 hidden teleport가 아니다.
- [ ] `rec_*` 없음/불허용/stale required destination에서 임의 respawn을 선택하지 않는다.
- [ ] recovery 후 safe focus가 보이고 input이 정확히 한 번 활성화된다.
- [ ] recovery가 world write를 만들지 않으면 persist가 발생하지 않고, world write를 만들면 정확히 한 번 발생한다.
- [ ] persist 저장 실패는 in-memory recovery를 rollback하지 않는다.
- [ ] death/recovery로 player solution knowledge를 잠그지 않는다.
- [ ] death는 `06` §5.8 `trigger.kind` 5개(`death`, `encounter_failure`, `phase_complete`, `route_enter`, `scripted`)로만 시작되고, 별도 authored death ID를 쓰지 않는다.
- [ ] `game_over` 경로가 없고 encounter 실패는 항상 recovery로 귀결된다.

### 14.6 Continuity distinctions — 7개 type

- [ ] §7 표의 7개 type이 각각 서로 다른 authored outcome으로 테스트된다: `checkpoint`, `respawn`, `clone`, `reincarnation`, `loop`, `immortality`, `institutional_reentry`.
- [ ] `rec_*.kind`가 7개 enum 밖의 값이면 `06` validator가 reject한다(`recovery_kind_violation`).
- [ ] 8번째 type으로 `crown_alignment`(또는 `checkpoint_return`/`clone_branch`/`loop_rehearsal`/`immortal_continuation` 구 이름)이 `rec_*.kind`로 들어오면 reject된다.
- [ ] `respawn`과 `checkpoint`가 서로 다른 authored outcome으로 테스트되고 UI/transition이 구분된다.
- [ ] `institutional_reentry`가 이전 record를 덮어쓰지 않고 contradictory/official 새 Filing을 만든다.
- [ ] `clone`이 source와 다른 individual/body/social ID를 만들고 source memory snapshot 이후 source 변화가 자동 전파되지 않는다.
- [ ] `clone`이 name, role, inventory, relationship를 policy 없이 자동 복제하지 않는다.
- [ ] `loop`이 scope-local NPC action window만 되돌리고 knowledge, filed debt, record, continuity count를 유지한다.
- [ ] nested loop가 parent branch ID와 iteration ID를 보존한다.
- [ ] `reincarnation`이 source lineage와 current incarnation을 별도 ID로 저장하고 role/recognition을 자동 복구하지 않는다.
- [ ] `immortality`가 branch debt 또는 actual resource/consequence write를 commit하고 death prevention과 자동 동일시되지 않는다.
- [ ] 각 type이 body/memory/role/belief/institution/desire/social recognition 7개 layer를 빠짐없이 명시하고, `self_layers_restored` ∪ `self_layers_not_restored`이 완전 분할이다.
- [ ] 7개 layer에 대한 `memory_policy = copy_at_event` 같은 별도 policy token을 content가 쓰면 reject된다(`06` strict allowlist).
- [ ] `crown_alignment`가 `rec_*`로 실행되지 않는다: `G8` 실행이 `world.crown.operator_id`와 `crown_alignment_clock` irreversible stage를 쓰고, `recovery` section에는 쓰지 않는다.
- [ ] `G8` 실행 후에도 7개 recovery type이 전부 사용 가능하다.

### 14.7 NPC / world consequences

- [ ] 같은 NPC의 neutral→hostile→dead/removed/ally 전이가 stable NPC ID를 유지한다.
- [ ] NPC death 후 recovery/reset/re-entry가 initial NPC를 재생성하지 않는다.
- [ ] loop로 NPC action window는 reset되지만 NPC가 Filed public record를 player knowledge로 공유하지 않는다.
- [ ] relationship resolution이 `world.relationships`에 남고 `progression`에 두 번째 사본이 생기지 않는다.
- [ ] `world.npcs[<npc>]`의 relationship index가 load 시 `world.relationships`에서 재구축되며 save payload에 없다.
- [ ] `resource_persistent` outcome은 death, loop, region re-entry에서 감소를 복제하거나 초기화하지 않는다.
- [ ] route closure/redirect와 record category는 checkpoint보다 우선한다.
- [ ] recovery outcome의 immediate write와 delayed write가 각각 한 번만 Filing된다.
- [ ] presentation node/Label/animation callback은 NPC/world state를 직접 바꾸지 않는다.

### 14.8 Stale IDs / migration repair

- [ ] stable ID는 display name, array index, scene path로 resolve되지 않는다.
- [ ] optional stale NPC/prop/flag/encounter entry는 `06` §10.3에 따라 drop되고 unrelated valid state가 유지된다.
- [ ] drop 사실은 module-local load log에 남고 `catalog_report`에는 남지 않는다.
- [ ] `orphaned_record_ids` 같은 별도 orphan 목록이 payload에 없다. historical ID는 `commit_log`/`recovery.history` tombstone으로만 보존된다.
- [ ] stale `field.anchor_id`는 authored default anchor로 복구된다.
- [ ] stale `recovery.active_checkpoint_id`/`pending_outcome_id`는 임의 checkpoint로 대체되지 않고 load/commit을 거부한다.
- [ ] stale `world.records` reference는 이전 Filing을 지우지 않고 `recovery_unavailable` surface로 처리된다.
- [ ] `transaction.delayed_writes` target stale는 조용히 삭제되지 않고 content validation을 실패시킨다.
- [ ] unknown historical event는 rename으로 임의 매칭되지 않고 tombstone으로 읽힌다.
- [ ] explicit old ID→new ID migration이 fixture에서 정확한 새 state를 만든다.
- [ ] ambiguous ID가 둘 다 catalog에 있으면 migration/content validation이 실패한다.
- [ ] repaired load 후 canonical `save_state()`에 orphan pointer가 없다.
- [ ] stale repair 결과가 headless와 실제 entry scene에서 동일하다.
- [ ] `content_revision` 불일치 후에도 load가 성공하고 진행이 보존된다.

### 14.9 Reset / re-entry

- [ ] `reset`은 confirmation만 열고 canonical state를 바꾸지 않는다.
- [ ] reset cancel은 byte-equivalent canonical state를 유지한다.
- [ ] `reset_encounter`는 `resume_boundary: "encounter_start"`와 빈 intent를 만들고 NPC/record/inventory/continuity를 유지한다.
- [ ] `reset_interaction`은 uncommitted transaction만 버리고 Filing result를 유지한다.
- [ ] `reset_current_region`은 other regions의 persistent state를 바꾸지 않는다.
- [ ] `reset_run`은 destructive confirmation 없이는 실행되지 않고, 새 `run_id`를 발급하며 이전 run 파일을 덮어쓰지 않는다.
- [ ] module re-entry는 transient presentation을 비우고 canonical state를 복원한다.
- [ ] region re-entry는 revisit variant를 authored state에서 만들고 current definition으로 덮어쓰지 않는다.
- [ ] permanent encounter result는 module unload/load 후에도 repeat policy대로 유지된다.

## 15. 수동 플레이 수용 기준

자동 테스트는 기능 증명일 뿐이다. 아래를 실제 Reference Game에서 처음부터 수행한다. `06`은 schema를 정의했고 `07`/`10`이 나머지 plan을 정본으로 삼는다. 그 세 문서와 `01`의 §2.3 방향 수정(§2.3 주)이 반영되기 전에는 이 절을 통과했다고 표시하지 않는다.

### 15.1 Baseline save/death/recovery

- [ ] 새 run에서 H0 The Undersign Exchange를 시작하고 첫 authored checkpoint를 world interaction으로 활성화한다.
- [ ] 별도 상시 “저장됨” HUD 없이 checkpoint world feedback이 발생한 뒤 강제 종료→재실행해도 checkpoint가 유지된다.
- [ ] checkpoint 전 boss/field encounter에서 의도적으로 death한다.
- [ ] 같은 boss/field encounter가 §5.5의 authored start/phase 경계에서 다시 시작한다. 전투 중간 HP/phase/action queue가 복원되는 것처럼 보이는 일이 없다.
- [ ] 전투 중(중간 turn)에 강제 종료→재실행하면 encounter는 start/phase 경계에서 다시 시작하고, 저장해 둔 pre-command intent만 재검증되어 실행되거나 `01` §9.4로 무효 처리된다. turn index가 이어지지 않음을 확인한다.
- [ ] enemy charge의 telegraph/reaction 창 중에 종료→재실행하면 charge stage가 복원되지 않고, 그 charge를 시작한 intent에서 새로 진행된다.
- [ ] death 전 이미Filing된 NPC/record/resource 변화는 그대로다.
- [ ] death 전 사용 consumable, 이미 beat boss, 이미 open/closed route가 복제되거나 초기화되지 않는다.
- [ ] 저장 파일을 수동으로 load한 뒤 field, combat start boundary, dialogue/document semantic source, region revisit state가 기대한 대로 복원된다.
- [ ] focus, selected, target, page pixel position은 복원되지 않지만 현재 선택/진행 source는 명확하다.

### 15.2 Persistent NPC / world

- [ ] checkpoint 전에 NPC를 실제로 죽이거나 제거한다. checkpoint을 갱신하고 death한 뒤 NPC가 initial state로 돌아오지 않는다.
- [ ] death 전 Filing된 category/route/clock write가 recovery 후 distant region에서 다른 authored variant를 만든다.
- [ ] recovery 자체가 H0/R1–R7의 다른 region world state를 초기화하지 않는다.
- [ ] NPC가 death를 보았는지, institution이 Filing했는지, player가 해법을 아는지를 서로 다른 state로 설명할 수 있다.
- [ ] region re-entry가 NPC presence/absence, resource stock, record, revisit variant를 올바르게 보여 준다.
- [ ] combat result가 dialogue flag가 아니라 NPC/record/route/resource의 실제 후속성을 만든다.

### 15.3 Recovery distinctions — 7개 type

각 type은 Reference Game 안에서 실제 world interaction/choice/transition으로 한 번 이상 확인한다. 버튼 목록이나 debug menu로만 실행하지 않는다.

- [ ] **`checkpoint`**: 선택한 physical recovery facility에서만 explicit return하며, death 기본 흐름과 UI/transition이 구분된다.
- [ ] **`respawn`**: encounter-local failure만 반복되고 world debt/records는 남는다.
- [ ] **`institutional_reentry`**: body/role/record가 서로 다른 continuity 결과를 만들고 이전 record가 visible archive/contradictory copy로 남는다.
- [ ] **`clone`**: clone이 source와 다른 social identity/legal name/resource cost를 갖는다. source는 복원되지 않는다.
- [ ] **`loop`**: local mechanics는 반복되지만 player knowledge/NPC filing/debt/continuity count는 남는다. NPC가 player knowledge를 자동으로 공유하지 않는다.
- [ ] **`reincarnation`**: 이전 cycle과 새 incarnation의 memory/role/social recognition 차이를 gameplay와 NPC reaction에서 확인한다.
- [ ] **`immortality`**: death prevention 또는 redirected death cost가 branch debt/resource/social consequence로 실제 Filing됨을 확인한다.
- [ ] death, loop, reincarnation, immortality가 단순 HP refill이나 같은 “respawn” modal로 합쳐지지 않는다.

### 15.4 Crown alignment는 world write다

`G8`은 recovery가 아니다. recovery type 수에 포함하지 않고 world consequence로 확인한다.

- [ ] R7/R4에서 precedence를 제출하면 operator가 교체되고 `Crown of Continuance` literal object와 `Crown Protocol`은 유지된다.
- [ ] 이전 operator의 memory는 archive copy로 읽히고 active world state에서 지워지지 않는다.
- [ ] alignment 이후 모든 edge의 route state와 revisit variant가 world-wide하게 다시 해석된다.
- [ ] alignment가 `recovery` UI/screen/flow로 나타나지 않고 world/NPC action으로만 확인된다.
- [ ] alignment 후에도 7개 recovery type이 전부 실행 가능하다.

### 15.5 Stale / migration / reset

- [ ] version fixture를 headless뿐 아니라 실제 entry flow에 load해 canonical state와 gameplay route가 일치한다.
- [ ] validation fixture로 optional stale NPC/prop을 제거하고 unrelated route/record/inventory가 유지됨을 확인한다.
- [ ] required stale checkpoint/destination은 임의 region으로 이동하지 않고 명시적 failure/recovery surface를 보여 준다.
- [ ] `catalog_report.outcome == "content_unavailable"` 상태에서 field/combat이 시작되지 않고, 입력 무시 + `content_unavailable` surface가 한 번만 나타난다.
- [ ] reset confirmation의 cancel은 아무 변화도 만들지 않는다.
- [ ] active encounter reset 후 NPC death, Filing, inventory, relationship, continuity가 유지된다.
- [ ] `reset_run` 실행 후 새 `run_id`로 시작하며 이전 run 파일이 남아 있다.
- [ ] module와 region re-entry 후 current scene, NPC absence, record category, active route, checkpoint가 일치한다.
- [ ] old save와 current authored content 사이에 explicit ID rename migration이 있으면 old log와 new active reference가 동시에 읽힌다.

### 15.6 화면 / focus / 해상도

death, checkpoint, recovery, reset confirmation, stale-content failure, save/load 복귀를 실제 입력으로 다음 해상도에서 각각 확인한다.

- 1280×720
- 1920×1080
- 2560×1440

각 해상도에서:

- [ ] world combat/field focal area가 recovery UI에 과도하게 가려지지 않는다.
- [ ] checkpoint/recovery destination과 focus/selected actor가 명확하다.
- [ ] world, dialogue, document, combat 정보 우선순위가 유지된다.
- [ ] 긴 recovery message와 최대 NPC/record consequence 목록이 잘리지 않는다.
- [ ] reset destructive action과 cancel focus가 구분된다.
- [ ] Esc Shell은 호출 전 시각적 존재감 0이며, 호출 후 닫으면 recovery 전 유효 focus로 복귀한다.
- [ ] 상시 autosave label, debug lineage, checkpoint ID, loop count, recovery type 목록이 없다.
- [ ] death/recovery presentation이 placeholder ColorRect/Label이나 버튼 목록으로 world를 대체하지 않는다.
- [ ] keyboard/gamepad와 pointer 경로에서 focus, confirm, cancel, return이 같은 domain 결과를 만든다.
- [ ] animation/tween 중 load·death·module exit을 실행해도 stale callback이 canonical state를 바꾸지 않는다.

### 15.7 Reference 비교 / 증거

- [ ] Primary Reference에서 death 직전, death result, checkpoint/service, return/re-entry 화면을 실제 캡처 또는 직접 플레이로 추가 확인한다. 현재 A~H에 없는 사실을 추정하지 않는다.
- [ ] BLACK SOULS 2의 recovery pacing, world-to-recovery transition, retry information hierarchy를 비교 기록한다.
- [ ] 원작 skin, 지도, 캐릭터, 문구, UI frame, 수치, reward를 복제하지 않는다.
- [ ] 1280×720/FHD/QHD death, checkpoint, recovery, stale failure, reset, module re-entry 캡처를 남긴다.
- [ ] 각 수동 결과에 success/failure, 첫 유효 action까지 시간, 오조작, backtracking, 설명 필요 여부를 기록한다.
- [ ] 자동 테스트, reference comparison, 수동 플레이가 통과한 뒤에만 `검토 준비 완료`를 선언한다. 사용자 직접 플레이 전 `완료/최종 완성`으로 쓰지 않는다.

## 16. 금지 shortcut

- 모든 death/checkpoint/loop/clone/reincarnation/immortality를 `respawn` 한 종류로 구현
- checkpoint에 world 전체 snapshot을 복제해 NPC/record/continuity를 같이 rollback
- death 횟수만 저장하고 recovery type, preserved/discarded self layers, lineage을 생략
- clone을 source NPC skin 변경 또는 source 상태 덮어쓰기로 구현
- loop를 전체 scene reload 또는 모든 world state reset으로 구현
- reincarnation을 사망 후 동일 player sprite/role/name 변경으로 구현
- immortality를 damage immunity만으로 정의하고 branch debt를 생략
- death마다 checkpoint selection list를 기본 표시
- `known_solutions`, `clue_found` 같은 flag로 player knowledge를 통제
- NPC/world permanent result를 dialogue bool 하나로 저장
- uncommitted encounter와 Filed world consequence를 한 dictionary에 섞어 전부 reset
- array index/display name/runtime node path로 continuity나 stale ID 해석
- migration 없이 field 이름이나 기본값만 변경
- future schema를 defaults로 sanitize
- stale required ID를 “가장 가까운 임의 NPC/region”으로 대체
- reset confirmation 없이 run/world state 삭제
- re-entry마다 authored NPC/record/resource를 initial definition으로 덮어쓰기
- core save codec에 H0/R1/NPC/boss/recovery type별 `match` 추가
- autosave/checkpoint/lineage을 상시 HUD 또는 debug label로 노출
- save round-trip 테스트를 death/world consequence 검증으로 대체
- Reference Game death/checkpoint 장면을 Primary Reference 미확인 상태로 기억에서 구현
- `06` §10.1/§10.2 per-section child allowlist과 `08` root를 병행해 두 개의 save schema를 유지
- `08` root key 집합을 `06`이나 `01`에서 다시 선언하거나, root 소유권을 두 문서에 나눠 갖는 것
- root section 안의 per-kind allowlist/sanitize를 `08`에서 다시 만드는 것(`06` §10의 중복 구현)
- `turn_index`/`scheduler_cursor`/charge stage/reaction window/RNG position을 저장해 전투 중 resume을 허용
- 전투 중 저장을 금지한다는 이유로 encounter 자체를 저장하지 않는 것
- 저장된 `pre_command_intent`를 재검증 없이 그대로 commit
- recovery type을 8개로 유지하거나 `crown_alignment`를 `rec_*.kind`로 추가
- `checkpoint_return`/`clone_branch`/`loop_rehearsal`/`immortal_continuation` 같은 구 token을 alias로 동시에 유지
- `crown_alignment`를 recovery screen/flow로 실행하거나 `world.crown` 대신 `recovery.continuity`에 operator를 저장
- `player.body.vitals`에 `ap` resource를 만들거나, world axis/relationship을 `progression`에 중복 저장
- `orphaned_record_ids` 같은 save 안의 별도 orphan 목록을 두는 것(tombstone은 `commit_log`/`recovery.history` 2곳뿐)
- authored recovery schema를 `RecoveryOutcomeDefinition`/`RecoveryProfileDefinition` 같은 두 번째 정본으로 다시 만드는 것
- `per-layer policy token`(`memory_policy = copy_at_event` 등)을 `06` strict allowlist 밖에 두고 content에서 쓰게 하는 것
- `reset_run`을 "다른 문서가 storage key를 정해야 한다"는 이유로 구현 보류 상태로 두기

## 17. 완료 증거

다음이 모두 있어야 이 파일의 save/death/recovery 계획을 구현 완료로 판정한다.

1. v1 canonical root schema(§4.2, 12 key)와 모든 section default/validator
2. `06` §10.1 → `08` root 매핑(§4.2.2) 반영 증거와 §4.2.2의 `06` 후속 6개 항목 처리 기록
3. JSON-safe/deep-copy/round-trip 증거 + float allowlist 2개 field 확인
4. future-version rejection과 atomic rollback 증거
5. 이전 version migration fixture 또는 “현재 이전 version 없음”의 명시적 기록
6. 전투 중간 resume 불가 증거와 pre-command intent 복원/재검증 테스트
7. checkpoint activation/load/death file-flow 증거
8. 7개 recovery type의 continuity matrix 테스트와 8번째 type 거부 테스트
9. `crown_alignment`가 `rec_*`가 아닌 `world.crown` world write로만 실행되는 테스트
10. `06` §9.5 `content_unavailable` recovery surface 진입 증거
11. NPC death/absence와 cross-region persistent consequence 테스트
12. rollback 허용/금지 경계 테스트
13. stale optional/required/historical ID 테스트와 tombstone 2곳 한정 확인
14. `reset_run`의 새 `run_id` 발급/이전 run 보존 증거
15. reset/module re-entry/region re-entry 테스트
16. Reference Game 수동 baseline + continuity + crown alignment + stale/reset 플레이 기록
17. 1280×720/1920×1080/2560×1440 캡처
18. authored content 추가 후 save codec/recovery core 무수정 증명
19. placeholder/상시 HUD/원작 복제 금지 검색 결과
20. 사용자 직접 플레이가 가능한 상태

자동 테스트 실패, root key 소유권 중복, 전투 중간 resume, stale required reference, migration rollback 실패, NPC/world consequence 소실, rollback 범위 위반, focus 복귀 실패가 하나라도 있으면 `검토 준비 완료`보다 앞선다.
