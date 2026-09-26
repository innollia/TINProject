# 06 — Authored Content and Data

## 환경 presentation 데이터 보충 — 2026-09-26

큰 배경과 분리 레이어의 제작 계약은 [13](13_LAYERED_ENVIRONMENT_PRODUCTION.md) §7이다. 기존 content kind·stable ID·region/prop state와 art key는 유지한다. 이미지 bundle을 domain kind로 추가하거나 현행 JSON에 미구현 key를 일괄 삽입하지 않는다.

module-local presentation manifest가 area bounds, source density, PNG 경로, crop, world origin, pivot, depth, 기존 prop/state와의 연결을 소유한다. `art_world_*`는 단일 image가 아니라 region bundle을 찾는다. domain은 image path나 색을 읽지 않고, resolved state를 presentation이 기존 variant와 연결한다. 그림의 alpha/밝기에서 collision을 생성하지 않는다.

후속 presentation 검증에는 manifest version·중복 layer ID·실재 경로·source rect 범위·양의 density·anchor 범위·foreign prop/state 참조·variant 누락·state 우선순위 충돌을 포함한다. 이는 이 문서의 domain catalog_report와 구분하는 자산 보고서다. 이 보충은 **계획**이며 현재 loader에 위 검증이 구현됐다는 뜻이 아니다.

공통 계약: `docs/KIT_WORKFLOW.md`  
세계 헌장: `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`  
아이디어 원장: `docs/research/top_down_action_rpg/IDEA_LEDGER.md`  
분할 계획 중앙 해석: `docs/research/top_down_action_rpg/PLAN_RESOLUTION.md`  
Primary Reference: BLACK SOULS 2 하나

이 문서는 `PLAN_RESOLUTION.md`(2026-09-25)를 **적용한** canonical catalog/loader 규격이다. 해석과 충돌하면 해석이 우선한다. 해석이 지시한 항목은 이 문서에 반영되었고, 반영 위치는 각 절의 "resolution 적용" 표시에 남긴다.

## 0bis. magic / concentration 층의 통합 계약

`12_MAGIC_THEORY.md`의 magic은 별도 우주가 아니라 `02` §2.2의 `E4 The Concentration Layer`이고, **이 Kit의 기존 18개 kind 위에 data로 얹힌다.** 이 문서가 그 층에 대해 고정하는 것은 다음뿐이다.

1. `act_*.craft` optional sub-record — `craft_family`, `concentration_source`/`concentration_requirement`, `medium_options`/`tool_options`/`shape_or_pattern`, `waste`, `failure_status_id`, `environment_effect`, `social_recording`, `contract_ref` (§5.5.7)
2. magic status 5종의 등록 floor와 표현 규칙 (§5.4.1)
3. `mana_profile` closed 8 enum과 NPC binding·diversity floor (§5.11.1)
4. `region_*.concentration` — environmental concentration, disperser, circulator (§5.10.1)
5. `res_*` magic 10종의 등록과 비수량 debt key(`res_labor_pledge`, `res_contract_tally`) 처리 (§6.3, §6.4)
6. `magic` world-state sub-record 6종의 save projection allowlist (§10.2)
7. `R8 The Folding School` / `E18` / `RC-08` / `FAM-ARPG-19` / `ENC-ARPG-25` / 5 magic status / 10 magic `res_*`의 re-key (§3.5)
8. `S121`–`S160`의 magic-specific audit gate (§13.2.1)

**magic 층은 19번째 kind를 만들지 않는다.** `magic`은 save section의 이름이지 kind가 아니며, content 단위는 `act_*`/`st_*`/`region_*`/`npc_*`/`res_*`/`eff_*`/`prop_*`/`doc_*`/`enc_*`/`enemy_*`/`clock_*`/`seed_*`다. `05` §2.8.1이 금지한 새 `category`·새 target mode·새 lifecycle·새 status op·새 phase trigger·제7 clock·제8 recovery type을 추가하지 않는다. `changed_core_files == []`가 `R8`/`FAM-ARPG-19`/`ENC-ARPG-25`의 성공 조건이다(`07` §14.1 A1, `02` §12).

**지금 반영하지 않는 것**: `magic.glossary`가 비어 있을 때 craft 이론의 positive label. `R4`의 `glossary` slot이Filing한 뒤에만 기록되며, 그 전에는 `untranslated term`으로 Filing된다(`02` §9.1/§13, `05` §2.8.3). 이 문서는 그 규칙을 `untranslated_theory_label` error로 강제할 뿐 이름을 만들지 않는다.

---

## 0. 이 문서의 책임과 경계

### 0.1 이 문서가 소유하는 것

이 파일은 Kit 04의 authored content 전체를 **module-local JSON catalog**으로 고정하고 그것을 읽는 **module-local loader**의 계약을 함께 고정한다. 구체적으로 다음을 소유한다.

1. content root, kind 목록, index 구조, load order
2. stable ID 문법, namespace(flat), 안정성 계약, 그리고 다른 plan 파일의 계획 ID → catalog ID **re-key 표**
3. 18개 kind의 concrete schema, 허용 key allowlist, enum, 범위, validation rule (`equipment`/`items` 포함)
4. 공통 문법 두 개: `Condition` leaf catalogue, `Effect` operation catalogue
5. combat resource / damage payload / action hook / target vocabulary가 `01`과 맞물리는 지점의 **content 쪽 필드 모양** (`01`이 실행 순서와 의미를 소유)
6. duplicate / missing reference 처리 규칙과 error code 전체
7. `08` root envelope **내부**의 per-section key allowlist, sanitize, stale 처리, schema bump 정책
8. loader/registry unit 경계와 재사용 허용 사다리
9. authored content 추가 절차와 core-modification ledger
10. 160분모(core 120 + magic supplement 40) → 96 planned-transform gate의 계산식, gate, report
11. magic / concentration 층의 data 모양 — `act_*.craft`, magic status floor, `mana_profile`, `region_*.concentration`, `res_*` magic 10종, `magic` save sub-record 6종 (kind는 늘리지 않는다)

**content runtime = JSON catalog + module-local loader.** Godot `Resource`는 presentation reference 또는 선택적 authoring wrapper일 뿐 canonical identity가 아니다(`10`의 `test_content_runtime_is_json_catalog_not_resource_identity`). save payload는 어떤 Resource도 담지 않는다.

### 0.2 이 문서가 소유하지 않는 것

| 담당 | 파일 | 이 문서가 주는 것 |
|---|---|---|
| combat/field/input grammar, action 실행 순서, scheduler 의미, resolution hook **순서**, target mode의 실행 semantics | `01_SYSTEM_UX.md` | `act_*`가 표현해야 하는 필드 이름·enum·범위. 단 `target mode` 6개 enum과 `turn_cost 0..5` 정수 의미는 `01`이 owner이고 이 문서는 같은 값을 쓴다 |
| region 지형/경로/world state 변화 규칙, pressure clock 진행 의미, **named axis token과 integer mapping**, **clock stage vocabulary와 integer mapping**, route state 5개, gate registry, **`res_*` magic vocabulary(§5.5)**, **`magic` world-state 6종(§9.1)**, axis↔integer mapping(§3.3), clock stage ladder(§4.1) | `02_WORLD_STATE_AND_ROUTES.md` | `region_*`, `clock_*`, `magic*` schema와 저장 token. `02`의 ladder 밖 값은 error. **`02` §3.3/§4.1/§3.2가 이제 ladder를 publish했으므로 이전의 "미공개" 결함은 해소되었다** |
| story cluster 흐름, ending 축, event cluster composition (`HC-00` + `RC-01`–`RC-08`) | `03_STORY_AND_ENDINGS.md` | `conv_*`, `prop_*`, effect로 표현되는 사건 단위, `initial_cluster` schema |
| NPC 성격/relationship arc의 서사적 의도, 14 core roster, `R8` support resident 7명(`npc_20_*`–`npc_26_*`), NPC의 magic craft role | `04_CHARACTERS_AND_RELATIONSHIPS.md` | `npc_*`, `rel_*` schema와 state machine 계약. canonical relationship state는 이 문서 §5.7의 `states[]` |
| 적군 구성의 플레이 밸런스, boss encounter 설계 의도, magic layer의 closed authoring rule set(§2.8), legacy 계획 ID | `05_ENEMIES_AND_ENCOUNTERS.md` | `enemy_*`, `phase_*`, `enc_*` schema, `region_role`/`region_secondary` field, group 5개/variant/NPC-conversion 매핑, magic status 5종 |
| Reference Game 10분 흐름, authored content floor 배정, `R8` A1 data-only 조건 | `07_REFERENCE_GAME.md` | authored content 단위의 schema |
| **root save envelope**, death/checkpoint/recovery UX, clone/loop 재생성 | `08_SAVE_DEATH_AND_RECOVERY.md` | `rec_*` schema와 root section **내부** per-kind allowlist. root 12개 key와 8개 section 이름은 `08`이 소유 |
| 화면/자산/audio, `art_key` 해석, Gold Standard manifest, `target_hp_or_condition` bar의 화면 위치, document page 9줄 cap의 화면 물리 예산 | `09_PRESENTATION_ART_AND_AUDIO.md` | content가 `art_key`/`silhouette_key`/`tint_key`/`target_hp_or_condition` **값과 전진 규칙만** 들고 path·색을 들지 않는 규칙. authored cap 9는 `10`/`09`와 함께 이 문서가 강제한다 |
| 테스트 명령, 수동 플레이, 해상도 캡처 | `10_TESTS_AND_ACCEPTANCE.md` | 이 문서가 열거한 자동 테스트 항목 |
| magic 이론·모델·실패 등급·institution 분기·content floor의 서술 | `12_MAGIC_THEORY.md` | `craft_family` 3종, `mana_profile` 8종, `concentration_source` 3종, `medium`/`tool`/`shape_or_pattern`의 authored 계약, failure 3등급을 **data 모양으로** 옮긴 것. 이론의 positive 이름은 §0bis대로 glossary slot에만 존재한다 |
| 외부 코드/의존성 | `11_EXTERNAL_CODE_DECISIONS.md` | 없음 |

`art_key` 해석과 Gold Standard manifest는 `09`가 소유한다. 이 문서는 content가 **키 문자열만** 보유한다는 규칙과 미등록 키를 error로 보고한다는 규칙만 준다.

### 0.3 `equipment`/`items` kind 소유권

`PLAN_RESOLUTION` §7에 따라 **`equipment`와 `items` schema는 이 문서가 소유한다.** `01`은 combat 진행 의미와 장비 효과의 의미를 prose로 설명할 뿐 schema owner가 아니다.

| 순번 | kind | prefix | schema owner | validator | 상태 |
|---:|---|---|---|---|---|
| 5 | `equipment` | `equipment_` | `06` §5.18 | `content/validate/validate_equipment.gd` | **DEFINED** |
| 6 | `items` | `item_` | `06` §5.19 | `content/validate/validate_item.gd` | **DEFINED** |

- 두 kind는 §1.2 kind 표에 **정상 kind**로 등록된다. `index.json`에서는 `registered_slots`로 선언하고 loader는 slot 등록으로 읽는다(§11.1). catalog에 `if kind == "equipment"` 분기를 새로 만들지 않는다.
- 두 kind가 비어 있어도(작성된 파일 0개) catalog은 `READY`가 될 수 있고 `READY_WITH_DEFECTS`가 되지 않는다. schema가 정의되어 있으므로 "정의 대기" 결함이 없다.
- 반대로 `act_*.cost`·`effect.operations`·`npc.resource_access`가 `equipment_`/`item_` ID를 참조하는데 그 정의가 없으면 그 참조는 unresolved다 → referrer 격리(§9.3). 빈 slot과 dangling reference는 다른 상태다.
- 이 interlocking은 의도적이다: schema는 항상 존재하고, **작성 여부**만 authored content의 책임이다.
- **`magic`은 kind가 아니다.** `equipment`/`items`와 달리 `content/magic/` 디렉터리도 `magic` prefix도 `registered_slots` 항목도 없다. magic data는 `act_*.craft`, `st_*`, `region_*.concentration`, `npc_*.mana_profile`, §6.3의 `res_*` registry, `world.magic` save sub-record 안에 산다. `magic`이라는 이름의 kind/directory/prefix를 만들면 `unknown_canonical_id` + `slot_unexpected`이고, `02` §12가 요구한 A1(`changed_core_files == []`)이 깨진다.

### 0.4 이 문서가 남겨 두지 않는 결정

이 문서의 모든 schema는 구현에 영향을 주는 선택지를 닫았다. 아래 항목은 **closed**다.

- ID 문법(점·하이픈 금지), prefix 요구, flat namespace, rename 금지, 재사용 금지
- re-key 표(§3.5). 계획 문서의 예시 ID는 이 표를 통해서만 catalog ID가 된다
- kind 별 root key allowlist
- enum 값 전체: target mode 6개, `turn_cost` 정수 `0..5`, recovery kind 7개, clock kind 6개, clock stage(=`02` ladder), `region_role` 9개, `region` 9개, route edge 18개, gate 9개, cluster 9개, group 5개, combat resource 3개, `craft_family` 3개, `mana_profile` 8개, `concentration_source` 3개, magic status 5개
- 수치 범위 전체
- load order와 참조 순서 제약
- error/warning code와 severity
- duplicate/missing 처리
- save root는 `08`이 소유하고, `06`은 section 내부 per-kind allowlist만 소유
- audit 분모(160)와 gate(96)와 계산식
- **action-point resource는 존재하지 않는다** (`ap` key·`max_ap` stat·AP label·AP gauge 전부 금지)
- **단일 `mana` resource·전역 `concentration` 막대·craft 라벨 `mp` pool은 존재하지 않는다** (`mana`/`concentration`/`mana_pool`은 §2.7의 금지 resource key)
- **magic은 제7 clock·제8 recovery type·제5 축·새 target mode·새 lifecycle·새 status op·새 phase trigger를 만들지 않는다**

열어 둔 것은 cheap tuning뿐이다: cooldown window 수, clock tick 주기, telegraph window 수, document page 여유(상한 9는 고정), roster count cap(§5.17의 12), save payload 크기 상한(§10.5), combat band font·row 수.

---

## 1. Authored Content 단위와 파일 배치

### 1.1 content root

```text
res://modules/top_down_action_rpg/content/
├── index.json
├── ledger/
│   └── seed_ledger.json
├── seeds/
│   ├── seed_a.json … seed_k.json
├── effects/
│   └── eff_<id>.json
├── statuses/
│   └── st_<id>.json
├── actions/
│   └── act_<id>.json
├── equipment/
│   └── equipment_<id>.json
├── items/
│   └── item_<id>.json
├── clocks/
│   └── clock_<id>.json
├── relationships/
│   └── rel_<id>.json
├── recovery/
│   └── rec_<id>.json
├── props/
│   └── prop_<id>.json
├── regions/
│   └── region_<id>.json
├── npcs/
│   └── npc_<id>.json
├── conversations/
│   └── conv_<id>.json
├── documents/
│   └── doc_<id>.json
├── phases/
│   └── phase_<id>.json
├── enemies/
│   └── enemy_<id>.json
└── encounters/
    └── enc_<id>.json
```

`authored/`와 `tests/`의 최종 위치는 `GODOT_JRPG_AUDIT.md` §7이 미정으로 남겼으므로 여기서 확정한다.

`GODOT_JRPG_AUDIT.md` §7은 content 아래에 `actors/`, `actions/`, `phases/`, `encounters/`, `items/`, `regions/`, `story/`를 스케치했다. 여기서는 **kind 이름을 그대로 directory 이름으로 쓴다.** 이유는 (a) directory가 곧 kind 목록이라 `index.json`과 1:1로 대조된다, (b) `actions/`, `encounters/`, `regions/`는 그대로지만 그 밖의 이름이 `actors/`, `story/` 같은 **역할 기준**이라 schema가 바뀌면 directory 이름도 따라 바뀌어야 한다. `document`와 `conversation`을 같은 `story/`에 넣으면 §1.2의 kind 경계가 파일 단위에서 사라진다. `phases/`도 독립 kind로 분리한다(§5.15가 §5.16과 다른 schema다).

`content/`에는 JSON만 있는 게 아니다. §11.1의 GDScript unit도 같은 디렉터리 아래 `content/*.gd`와 `content/validate/*.gd`로 둔다. `content`는 "authored content와 그것을 다루는 module-local 코드"라는 뜻이고, core/나 다른 모듈은 이 디렉터리를 모른다.

```text
modules/top_down_action_rpg/authored/change_ledger.json     # §12.2, append-only
tests/core/fixtures/top_down_action_rpg/**.json             # §14, test-owned negative/boundary content
```

fixture는 두 번째 content source가 아니다. live content ID와 fixture ID namespace를 다르게 강제한다(§3.3).

### 1.2 kind와 prefix 표

`kind`는 catalog 등록 단위이자 validator 파일 단위다. prefix는 **필수**이며, kind↔prefix 불일치는 즉시 error다. prefix 요구는 subagent가 병렬 작성할 때 파일을 잘못 넘긴 경우를 validator 단계에서 잡기 위한 것이다.

| 순번 | kind | prefix | root 형태 | id 범위 | 주요 필드 |
|---:|---|---|---|---|---|
| 0 | `ledger` | `seed_` | 단일 | `seed_ledger` 1개 | denominator, quota |
| 1 | `seeds` | `seed_s` | `records[]` | `seed_s001`–`seed_s160` | core 120 + magic supplement 40 idea seed binding |
| 2 | `effects` | `eff_` | 단일 | 무제한 | op 목록 |
| 3 | `statuses` | `st_` | 단일 | 무제한 | status lifecycle |
| 4 | `actions` | `act_` | 단일 | 무제한 | action grammar |
| 5 | `equipment` | `equipment_` | 단일 | 무제한 | 장비 효과 (§5.18) |
| 6 | `items` | `item_` | 단일 | 무제한 | 소모품/패스 (§5.19) |
| 7 | `clocks` | `clock_` | 단일 | **6개 고정** | pressure clock |
| 8 | `relationships` | `rel_` | 단일 | 무제한 | relationship state machine |
| 9 | `recovery` | `rec_` | 단일 | 무제한 | recovery event |
| 10 | `props` | `prop_` | 단일 | 무제한 | world prop state |
| 11 | `regions` | `region_` | 단일 | **9개 고정** (`R8` 포함) | region contract |
| 12 | `npcs` | `npc_` | 단일 | 무제한 | character contract |
| 13 | `conversations` | `conv_` | 단일 | 무제한 | conversation |
| 14 | `documents` | `doc_` | 단일 | 무제한 | document |
| 15 | `phases` | `phase_` | 단일 | 무제한 | enemy phase |
| 16 | `enemies` | `enemy_` | 단일 | 무제한 | enemy contract |
| 17 | `encounters` | `enc_` | 단일 | 무제한 | encounter contract |

`clocks`는 `02` §4의 6개 pressure clock과 1:1, `regions`는 `02` §1의 9개 node(H0, R1~R8)와 1:1이다(§3.5.1, §3.5.4). content가 새 clock이나 region을 발명하지 않는다. `regions`의 9개에는 `R8 The Folding School`(`region_role: magic_training_craft_labor`)이 포함되며, 그 region도 다른 8개와 **동일한** RegionDefinition 계약을 쓴다(§5.10.1, §0bis).

root 형태가 두 가지뿐이라(index의 `array` boolean 하나로 분기) member path walking 같은 일반화 메커니즘을 만들지 않는다.

**route와 gate는 kind가 아니다.** `E01`–`E18` edge와 `G0`–`G8` gate는 `region_*.exits[]` 안의 인라인 sub-record다(§2.8, §3.5.2). `02`가 두 vocabulary를 소유하고 `06`이 저장 token을 공유한다. 별도 kind를 만들면 `03`·`07`의 route 설계가 schema 변경을 강제하고 catalog에 20번째 kind가 생긴다.

**cluster도 kind가 아니다.** `HC-00` + `RC-01`–`RC-08`의 9개 event cluster는 `region_*.initial_cluster` 안의 인라인 sub-record다(§3.5.7, §5.10). `02` §8가 9개를 소유하고 `06`이 `cluster_id` token을 매핑한다.

**group도 kind가 아니다.** `GRP-ARPG-01`–`GRP-ARPG-05`의 5개는 `enc_*.group` 안의 roster composition이다(§3.5.4, §5.17).

**magic도 kind가 아니다.** §0bis를 따른다.

### 1.3 index.json

`index.json`은 catalog의 단일 진입점이다. 파일을 디렉터리 순회하지 않는다.

```json
{
  "schema_version": 1,
  "module_id": "top_down_action_rpg",
  "entry_region_id": "region_h0_undersign_exchange",
  "kinds": [
    {"kind": "ledger",        "prefix": "seed_",       "array": false, "files": [{"id": "seed_ledger", "path": "ledger/seed_ledger.json"}]},
    {"kind": "seeds",         "prefix": "seed_s",      "array": true,  "files": [
      {"id": "seed_group_a", "path": "seeds/seed_a.json"},
      {"id": "seed_group_b", "path": "seeds/seed_b.json"}
    ]},
    {"kind": "effects",       "prefix": "eff_",        "array": false, "files": [{"id": "eff_ilyra_files_contradictory_copy", "path": "effects/eff_ilyra_files_contradictory_copy.json"}]},
    {"kind": "statuses",      "prefix": "st_",         "array": false, "files": []},
    {"kind": "actions",       "prefix": "act_",        "array": false, "files": []},
    {"kind": "equipment",     "prefix": "equipment_",  "array": false, "files": []},
    {"kind": "items",         "prefix": "item_",       "array": false, "files": []},
    {"kind": "clocks",        "prefix": "clock_",      "array": false, "files": []},
    {"kind": "relationships", "prefix": "rel_",        "array": false, "files": []},
    {"kind": "recovery",      "prefix": "rec_",        "array": false, "files": []},
    {"kind": "props",         "prefix": "prop_",       "array": false, "files": []},
    {"kind": "regions",       "prefix": "region_",     "array": false, "files": []},
    {"kind": "npcs",          "prefix": "npc_",        "array": false, "files": []},
    {"kind": "conversations", "prefix": "conv_",       "array": false, "files": []},
    {"kind": "documents",     "prefix": "doc_",        "array": false, "files": []},
    {"kind": "phases",        "prefix": "phase_",      "array": false, "files": []},
    {"kind": "enemies",       "prefix": "enemy_",      "array": false, "files": []},
    {"kind": "encounters",    "prefix": "enc_",        "array": false, "files": []}
  ],
  "registered_slots": [],
  "options": {
    "world_flag_prefix": "world_",
    "max_world_flags": 24,
    "closure_record_cap": 4096,
    "save_payload_bytes_cap": 262144,
    "history_list_cap": 64,
    "document_page_line_cap": 9,
    "max_equipment_definitions": 64,
    "max_item_definitions": 64
  }
}
```

`index.json` validation:

- 허용 key: 위 6개(`schema_version`, `module_id`, `entry_region_id`, `kinds`, `registered_slots`, `options`). `options`는 전체 7개 key를 모두 가져야 한다.
- `schema_version`은 `1`이어야 한다. `version` key가 같이 있으면 `invalid_schema`.
- `module_id`는 `top_down_action_rpg`와 정확히 같아야 한다.
- `entry_region_id`는 `region_` prefix를 가져야 하고 Stage 3에서 해석돼야 한다. canonical world에서는 `region_h0_undersign_exchange`가 유일하게 허용된다 → `entry_region_not_hub`.
- `kinds`는 위 표의 18개 kind를 **순서와 무관하게** 모두 한 번씩 선언해야 한다. 누락·중복 → `index_kind_missing` / `index_kind_duplicate`.
- `registered_slots`는 **빈 array여야 한다** → `slot_unexpected`. `equipment`/`items`가 이 문서에서 schema를 가지므로 남은 slot은 없다. 새 kind를 추가할 때만 이 배열에 `{kind, prefix, owner, validator_class}`를 넣고 §1.2 표에도 순번을 준다(§12.1 단계 4).
- `files[].id`는 prefix 검증 대상이다. `array: true` kind에서는 `files[].id`가 **그룹 ID**이므로 prefix 검증에서 제외한다(그룹 ID는 `seed_group_`로 시작해야 한다).
- `files[].id` 중복과 `files[].path` 중복은 `index_duplicate_file_entry`.
- `path`는 `res://` 상대 경로, `/` 시작 금지, `\` `:` `~` `.` 금지, `.json` 끝, path segment가 `""`/`.`/`..`가 아니어야 한다. 기존 `RuleLevelLoader._is_content_path`와 동일한 규칙을 쓰되 **모듈 로컬 복사본**을 쓴다(§11.6).
- `array: true` 파일은 root에 `records` array가 있어야 하고 각 record에 `schema_version`과 `id`가 있어야 한다. `array: false` 파일은 root가 그 kind의 단일 object여야 한다.
- `options.document_page_line_cap`은 정확히 `9`여야 한다 → `document_cap_not_nine`. 이 값은 tuning이 아니라 resolution이 닫은 상한이다.
- `index.json` 자체가 실패하면 catalog은 즉시 `CONTENT_UNAVAILABLE`이다(§9.5).

---

## 2. 공통 JSON 규칙

모든 kind에 공통으로 적용된다.

### 2.1 JSON-safe 계약

모든 content file은 다음 외에 값을 가질 수 없다.

- null, bool, int, **finite float**, string, array, string-key dictionary
- 금지: Node, Resource, Object, Callable, Signal, Vector2/2i/3, Rect2, Color, Transform, JSON에 매핑되지 않는 Packed array, NaN, Inf
- 금지: dictionary의 non-string key, 64단계 초과 깊이 (`SaveService.is_json_safe`와 동일 상한)
- float은 `0.0` `-0.0`을 포함해 저장·재파싱 후 값이 동일한 경우만 허용한다. `0.1`처럼 round-trip이 불안정한 표기가 필요하면 float 대신 permille 정수를 쓴다(§4.4)
- **이 Kit에서 authored float을 쓸 수 있는 field는 `document.reading.world_visible_ratio` 하나뿐이다.** 나머지 비율·확률·계수는 전부 정수(percent 또는 permille)다. 이렇게 하면 save에 float이 하나도 생기지 않는다(§10.2 규칙 4).

검증은 `SaveService.is_json_safe`와 동일한 판정 순서를 쓴다. 이 모듈은 `core/services/save_service`를 **import하지 않는다**(§11.5). 판정 로직을 모듈 로컬에 두되, 테스트는 두 결과가 항상 같은지 cross-check한다(§14.5).

### 2.2 schema_version

- 모든 file root와 `records[]`의 모든 record에 `schema_version`이 **필수**다.
- 값은 해당 kind의 `*_SCHEMA_VERSION` 정수와 같아야 한다. 첫 구현은 전부 `1`.
- float `1.0`은 통과시키지 않는다. 정수여야 한다. (`RuleLevelLoader`의 precedent)
- root에 `version`이 있으면 `schema_mixed_version`. 두 key를 섞는 것은 금지.
- **`01` §6.5가 action record에 요구하는 `version`은 여기서 `schema_version`이다.** 같은 필드의 다른 이름이므로 두 key를 같이 쓰지 않는다. `08` §3.1도 content version을 `schema_version`으로 부른다.
- schema bump는 breaking change에만 쓴다. 필드 추가는 bump 없이 default로 처리한다(§10.4).

### 2.3 strict key allowlist

- 모든 object는 **정확히** 허용 key 집합만 가진다. 알 수 없는 key 하나라도 있으면 그 kind error다.
- 필수 key 누락도 같은 error 코드군(`invalid_schema`)으로 보고하되 `detail`에 키 이름을 남긴다.
- allowlist는 "필수"와 "선택"을 나눈다. 선택 key는 **없으면 default**, 있으면 검증 대상이다. "선택이지만 비어 있으면 안 된다"는 상태는 허용하지 않는다(비었으면 key를 빼라).

### 2.4 선택 필드는 key를 생략한다

선택 필드를 `null`이나 빈 문자열이나 `0`으로 채우지 않는다. key 자체를 없앤다.

예외로 **authored intent상 0이 의미 있는 정수 필드**는 0을 쓸 수 있다. 예: `damage.self_damage: 0`, `effect.one_shot: false`, `recovery.cost.continuity_pressure_delta: 0`, `condition_bar.start_value: 0`. boolean과 "0이 유효한 정수"만 예외다. 빈 string은 예외가 아니다.

### 2.5 숫자 범위 규칙

- 모든 수치 필드는 그 필드의 declared `range`를 가진다. 범위를 벗어나면 `number_out_of_range`.
- 정수 필드에 float 값이 오면 통과시키지 않는다(정수 필드는 int여야 한다).
- 개수/횟수/스택/페이지 인덱스는 0 이상. tick/turn count는 10000 미만. 이 상한은 save payload 무한 성장을 막기 위한 값이다(§10.5).
- **음수가 유효한 정수 필드는 다음뿐이다**: `rel_*.axes` / `rel_*.axis_rules[].sets` / `recovery.cost.axis_deltas` / world `axis` 값(`-3..3`), `status.modifiers.stat_deltas`(`-9999..9999`), `damage.hit_modifier`(`-99..99`). 그 외 음수 정수는 전부 `number_out_of_range`다. 특히 **cost/delta/resource 계열에 음수를 쓸 수 없다.**

### 2.6 문자열 규칙

- 필수 text 필드는 `strip_edges()` 후 비어 있으면 안 된다.
- ID 필드는 §3 문법을 따른다. **ID에 `.`는 절대 들어가지 않는다.** 다른 plan 파일의 계획 ID가 `FAM-ARPG-01`, `FAM-ARPG-19`, `ENC-ARPG-25`, `GRP-ARPG-06`, `R-RETURN`, `NPC_IONA_VEY`, `END_R1_RECEIPT_OF_A_LIFE`, `S001`, `S121`처럼 점·하이픈·대문자를 쓰더라도 파일에는 §3.5 표의 **flat ID**만 쓴다.
- `text` 계열 필드에 새 줄은 허용한다(`documents`의 `lines[]`는 array라서 별도).
- content는 `res://` 경로를 절대 담지 않는다. `path`를 담는 위치는 `index.json`의 `files[].path`뿐이다.
- content는 색을 담지 않는다. `tint_key`처럼 **stable 문자열 key**만 쓴다. 해석은 presentation.
- 길이 상한: `text` 1200자, `audit_note` 400자, `note` 200자, ID 64자, `tint_key`/`art_key`/`silhouette_key`/`voice_key`/`icon_key`/`tell_key` 48자. 초과 시 `string_too_long`. 이 상한은 720p/16:9 재튜닝된 page 예산에서 나온다.

### 2.7 combat resource vocabulary — 3개로 닫힘

`resource_costs`(§5.5), `status.tick.operations[].resource_delta`, `enemy.stats.resource_pool`, `enemy.reward.resource_delta`, `recovery.cost.resource_costs`가 쓰는 key 집합은 **`hp`, `mp`, `equipment_charge` 3개로 닫힌다.**

- `ap`, `action_points`, `stamina`, `momentum`, `focus`(resource 의미), `sp`, `pp`, **`mana`, `mana_pool`, `concentration`, `concentration_field`, `body_load`, `craft`, `medium`, `blade`, `fold_count`** 를 쓰면 `resource_key_forbidden` error.
- `max_ap` stat은 존재하지 않는다. `enemy.stats`와 `status.modifiers.stat_deltas`에 `max_ap`가 있으면 `resource_key_forbidden` error. `mana`/`body_load`도 `STAT_KEYS`/`stat_deltas`에 들어가지 않는다 → `resource_key_forbidden`.
- A~H에서 AP label의 의미가 확인되지 않았으므로 이 Kit에는 action-point resource가 없다(`PLAN_RESOLUTION` §3, `10`의 `test_no_ap_resource_or_label_exists`).
- combat player band은 **HP/MP/status/action-slot text만** 표시한다. AP label, AP gauge, generic red bar는 `01`/`09`/`10`과 함께 금지이며 이 문서가 만드는 data도 없다.
- **magic은 combat resource가 아니다.** `12` §2.2와 `05` §2.8.1이 "단일 `mana` resource, 전역 `concentration` bar, craft 라벨 `mp` pool"을 금지한다. craft가 쓰는 것은 ① combat resource `mp`(일반 action cost와 같은 namespace) ② field/world `res_*`(§6.3) ③ `world.magic` sub-record(§10.2) 셋이며, **하나의 값이 두 namespace에 복제되지 않는다**(`02` §9.1).
- 이 규칙은 **이 문서의 예시 JSON에도 적용된다.** 예시에 `"ap": 0`이나 `"mana": 10`이 남아 있으면 그것 자체가 결함이다.
- `equipment_charge`를 cost로 내는 action은 charge pool을 가진 장비가 장비돼 있을 때만 유효하다 → Stage 3 `resource_cost_without_equipment`.

### 2.8 art key 규칙

- content는 `art_key`, `silhouette_key`, `body_class`, `tint_key`, `tell_key`, `icon_key`, `voice_key`, `arena_key`, `anchor_key`처럼 **해석 key만** 갖는다.
- content는 이미지 경로, `.tscn` 경로, 색 코드, opacity 값을 갖지 않는다. 이것이 나타나면 `content_holds_presentation_value` error.
- 모든 art key는 `09_PRESENTATION_ART_AND_AUDIO.md`가 소유하는 활성 Gold Standard manifest 또는 asset brief에 존재해야 한다. Stage 4에서 확인하고 없으면 `art_key_unregistered` error.
- 배경 오브젝트의 정보 중요도(`증거·직접 상호작용` / `길찾기·상황 이해` / `분위기`)는 asset brief가 정한다. content는 이를 추론하거나 덮어쓰지 않는다. content가 `importance` 값을 넣으면 `content_infers_art_priority` error.
- 이미지 생성/editing은 이 문서의 요구가 아니다. 이 파일은 schema만 정의한다.

### 2.9 인라인 sub-record ID

인라인 record(phase trigger, region revisit variant, region debt, region internal route, clock stage, relationship state/transition, encounter roster entry, enemy linked actor, choice, region exit/gate)는 **부모 파일 안에서만** 유일해야 한다.

- sub-record id 토큰: `variant_id`, `debt_id`, `internal_route_id`, `stage_id`, `state_id`, `transition_id`, `entry_id`, `rule_id`, `edge_id`, `line_index`+`token_index` 조합
- 런타임 namespacing: `<parent_id>/<sub_id>`
- sub-record ID는 global namespace에 들어가지 않는다. 따라서 `seed_` `region_` 같은 kind prefix가 필요 없고, 소문자 snake case만 쓴다.
- **단 하나 예외**: `edge_id`와 `gate_id`는 `region_*.exits[]` 안에 인라인으로 있으면서도 **전역에서 유일**해야 한다(§5.10의 `gate_id_collision`). `02`의 `E01`–`E18`/`G0`–`G8`와 1:1 대응하므로 naming도 전역 규칙(§3.5.2)을 따른다: `route_e01_…`, `gate_g0_…`. 게이트는 여러 region이 공유할 수 있으므로 runtime 이름은 flat `gate_g0_…`를 그대로 쓴다.
- `cluster_id`도 예외다. 9개 cluster는 9개 region이 하나씩 가지므로 `region_*.initial_cluster.cluster_id` 안에서 부모-지역 이름이 중복되지만, `02` §8 registry와 대조해야 하므로 **전역에서 유일**해야 한다 → `duplicate_cluster_id` error. `HC-00` + `RC-01`–`RC-08`의 9개 token은 §3.5.7에 있다.
- 유일성 검사 범위는 **부모 파일 1개**이다. 같은 `state_id`가 다른 `rel_` 파일에 있어도 conflict가 아니다.

---

## 3. Stable ID 규칙

### 3.1 문법

```text
id := lowercase_letter { lowercase_letter | digit | underscore }
길이: 3 … 64
```

- 첫 글자는 반드시 `a`–`z`
- **대문자 금지, 하이픈(`-`) 금지, 점(`.`) 금지, 공백/`/`/`:`/비ASCII 금지**
- 예외: `seed_s001` 형태는 같은 문법에 `seed_s` + 3자리 숫자(선행 0 허용)로 fit한다(`seed_s001`은 `s001` 부분이 소문자+숫자+underscore)
- namespace separator로 `.`나 `/`를 쓰지 않는다. `Parent.child` / `Parent/child` 형태의 ID를 **만들지 않는다.** 계층이 필요하면 dictionary key로 분리하고 ID는 leaf만 쓴다.

하이픈과 점을 금지하는 이유: ID는 `StringName` 비교, save dictionary key, test 이름, log 문자열, 파일명에 동시에 쓴다. `-`와 `.`는 어느 쪽에서도 이득이 없고, 파일명/경로 구분자로 오독되며, "ID 안에 계층이 있다"는 잘못된 인상을 준다(§2.9). `RuleLevelLoader`가 하이픈을 허용하는 precedent는 이 Kit의 근거로 쓰지 않는다. `RuleLevelLoader`는 사용 중인 ID가 전부 underscore이므로 기존 content의 호환 문제도 없다.

### 3.2 namespace

**flat global namespace**이다. `(kind, id)` tuple이 아니라 **ID 하나로** 모든 cross-reference를 쓴다.

근거:

- region은 NPC와 clock과 encounter를 함께 참조한다. tuple을 쓰면 모든 reference site에 `{kind, id}`를 반복해야 하고, 빠뜨리면 조용히 잘못 해석된다.
- save projection은 ID-keyed dictionary다. flat namespace이면 projection validator가 kind를 다시 확인할 필요가 없다.
- `seed_` prefix를 강제하므로 ID만 보고 kind를 알 수 있다.

ID로 kind를 알아내는 유일한 방법은 `prefix → kind` 역방향 표이며, 이 표는 `index.json.kinds[].prefix`가 단일 source다. validator는 `index.json`에서 읽는다. 코드에 prefix 목록을 하드코딩하지 않는다(§11.1).

### 3.3 안정성 계약

1. 한번 published된 ID는 **rename 금지**. stable ID는 save 호환성의 키다.
2. ID를 바꾸는 것은 schema bump + `migrate_save`가 함께 있어야 하는 변경이다. 그 전까지 옛 ID는 deprecated alias가 아니라 **stale ID**로 처리한다(§9.6).
3. ID 재사용 금지. 삭제한 content의 ID도 재사용하지 않는다. 재사용은 stale save가 조용히 재바인딩되는 사고다.
4. display name은 ID와 분리된 `display_name`이다. 이름을 바꿔도 ID는 그대로다.
5. 한 글자 prefix 변경도 rename이다.
6. `dev_` prefix는 개발 검증 전용이다. entry closure에 편입되지 않고, seed quota 분모/분자에 들어가지 않으며, `released: true`인 상태에서 존재하면 `dev_content_in_release` error.
7. `seed_ledger`, `index`, `entry`, `content`, `none`, `null`은 예약어. 선언 시 `reserved_id` error.
8. fixture ID는 `fx_` prefix를 쓴다. `fx_` prefix는 live content에서 금지(`fixture_id_in_live_content`).
9. `player` role ID는 content kind ID가 아니다. `PLAYER_BRIDGE_0`처럼 plan 문서의 player 표기를 `npc_*`로 만들지 않는다 → `player_id_in_npc_namespace`.

### 3.4 ID error 코드

| 코드 | 조건 |
|---|---|
| `id_malformed` | 문법 위반(대문자·하이픈·점·비ASCII 포함) |
| `id_too_short` / `id_too_long` | 길이 위반 |
| `id_prefix_mismatch` | kind에 선언된 prefix로 시작하지 않음 |
| `reserved_id` | §3.3의 예약어 |
| `duplicate_id` | catalog 전체에서 같은 ID가 두 번 이상 선언됨 |
| `dev_content_in_release` | `dev_` ID가 release 상태에 존재 |
| `fixture_id_in_live_content` | `fx_` ID가 `modules/**/content`에 존재 |
| `unrekeyed_planning_id` | 다른 plan 문서의 계획 ID(`FAM-ARPG-01`, `FAM-ARPG-19`, `ENC-ARPG-25`, `GRP-ARPG-06`, `R-RETURN`, `R-LATENCY`, `NPC_IONA_VEY`, `END_…`, `S001`, `S121` 등)가 content 파일에 그대로 쓰임. **retired ID(`R-*` 9개, `GRP-ARPG-06`~`12`)도 여기에 포함된다** — 대응표를 두지 않으므로 re-key가 불가능하고 `unrekeyed_planning_id`다 |
| `unknown_canonical_id` | 어떤 kind/prefix 소유 규칙에도 해당하지 않는 ID |
| `player_id_in_npc_namespace` | player role ID가 `npc_*`로 선언됨 |

### 3.5 re-key 표 — 계획 ID → catalog ID

다른 plan 문서는 **계획용 ID**를 자기 자리 문법으로 적는다(대문자, 하이픈, 점, 축약). content 파일은 그 ID를 그대로 복사하지 않는다. 아래 표가 유일한 변환 source다. 표에 없는 계획 ID가 content에 나타나면 `unrekeyed_planning_id` error다.

#### 3.5.1 region node와 event cluster (`02` §1, §7.0, §8) — 9개 고정

| `02` node | catalog ID | `region_role` (closed 9) | `02` cluster | `initial_cluster.cluster_id` |
|---|---|---|---|---|
| `H0` The Undersign Exchange | `region_h0_undersign_exchange` | `hub_registration_ration_appeal` | `HC-00` | `cluster_hc_00_first_docket` |
| `R1` The Returning Kiln | `region_r1_returning_kiln` | `recovery_reentry` | `RC-01` | `cluster_rc_01_wrong_return` |
| `R2` Siltglass Commons | `region_r2_siltglass_commons` | `resource_allocation` | `RC-02` | `cluster_rc_02_same_water` |
| `R3` Bellhouse Hospice | `region_r3_bellhouse_hospice` | `intervention_scheduling` | `RC-03` | `cluster_rc_03_mercy_delay` |
| `R4` Crownwell Archive | `region_r4_crownwell_archive` | `translation_precedence` | `RC-04` | `cluster_rc_04_sentence_above_stair` |
| `R5` Glasswing Ordinal | `region_r5_glasswing_ordinal` | `permission_before_transformation` | `RC-05` | `cluster_rc_05_uniform_name_contract` |
| `R6` Gristmarket Ward | `region_r6_gristmarket_ward` | `organ_authority_negotiation` | `RC-06` | `cluster_rc_06_hearts_petition` |
| `R7` The Hollow Orchard | `region_r7_hollow_orchard` | `boundary_crown_precedence` | `RC-07` | `cluster_rc_07_map_made_by_wall` |
| `R8` The Folding School | `region_r8_folding_school` | `magic_training_craft_labor` | `RC-08` | `cluster_rc_08_fold_refuses_hand` |

`region_role`의 9개 token은 `02` §1/§7.0의 region role을 flat snake로 옮긴 것이고 **여기서 새 이름을 만드는 것이 아니다.** `02`가 해당 region의 role을 바꾸면 `region_role_mismatch`로 잡힌다. region이 9개이므로 `region_role`도 9개로 닫힌다.

- `R8`은 `02` §2.2의 `E4 The Concentration Layer`가 만든 **같은 세계의 authored module**이다. 별도 namespace가 아니고 `region_*` 9개 중 하나이며, `gate_g9`를 만들지 않는다(§3.5.2). `R8`의 `region_role: magic_training_craft_labor`가 `05`의 `FAM-ARPG-19`·`ENC-ARPG-25`·`NPC-CONV-ARPG-05`가 읽는 값이다.
- **cluster 9개가 9개 region과 1:1이다.** 한 region이 두 cluster를 소유하거나 한 cluster가 두 region에 걸치면 `cluster_not_one_to_one` error. `HC-00` + `RC-01`–`RC-08`이 전부이고 하나라도 빠지면 `cluster_catalog_incomplete` error(`02` §12, `07` §14.1 A1). `cluster_id`는 §2.9의 전역 유일 예외다.
- 각 cluster는 `02` §8/§12가 요구하는 6~12 NPC, 2~4 institutions, 2~3 clocks, partial truth, resource conflict, immediate/delayed write를 가진다. `06`이 세는 것은 `initial_cluster.npc_ids` 크기(§5.10)와 `region.clocks[]` 크기뿐이고, institutions/threads/story 심층은 `02`/`03`이 소유한다.

#### 3.5.2 route edge와 gate (`02` §5.2, §6.1) — 인라인 sub-record

| `02` | catalog ID | 비고 |
|---|---|---|
| `E01` H0–R1 Ash Stair | `route_e01_ash_stair` | `region_*.exits[].edge_id` |
| `E02` H0–R2 Sluice Road | `route_e02_sluice_road` | 동일 |
| `E03` H0–R3 Mercy Causeway | `route_e03_mercy_causeway` | 동일 |
| `E04` H0–R4 Crownwell Ascent | `route_e04_crownwell_ascent` | 동일 |
| `E05` H0–R5 Foundry Tram | `route_e05_foundry_tram` | 동일 |
| `E06` R1–R3 Quiet Ward Passage | `route_e06_quiet_ward_passage` | 동일 |
| `E07` R1–R6 Ash Chute | `route_e07_ash_chute` | 동일 |
| `E08` R2–R6 Medicine Ferry | `route_e08_medicine_ferry` | 동일 |
| `E09` R2–R7 Orchard Causeway | `route_e09_orchard_causeway` | 동일 |
| `E10` R3–R4 Bell-Cable Lift | `route_e10_bell_cable_lift` | 동일 |
| `E11` R3–R5 Care Train | `route_e11_care_train` | 동일 |
| `E12` R4–R5 Courier Shaft | `route_e12_courier_shaft` | 동일 |
| `E13` R4–R7 Crown Stair | `route_e13_crown_stair` | 동일 |
| `E14` R5–R6 Under-Rail Shunt | `route_e14_under_rail_shunt` | 동일 |
| `E15` R5–R7 Supply Gantry | `route_e15_supply_gantry` | 동일 |
| `E16` R6–R7 Drainage Dark | `route_e16_drainage_dark` | 동일 |
| `E17` R2–R3 Water Ambulance Bridge | `route_e17_water_ambulance_bridge` | 동일 |
| `E18` R5–R8 Folding School Approach | `route_e18_folding_school_approach` | `region_*.exits[].edge_id`; magic module entry |
| `G0` Arrival Declaration | `gate_g0_arrival_declaration` | `region_*.exits[].gate_id` |
| `G1` Ash Debt | `gate_g1_ash_debt` | 동일 |
| `G2` Water Recognition | `gate_g2_water_recognition` | 동일 |
| `G3` Latency Receipt | `gate_g3_latency_receipt` | 동일 |
| `G4` Translation Precedence | `gate_g4_translation_precedence` | 동일 |
| `G5` Labor Pledge | `gate_g5_labor_pledge` | 동일 |
| `G6` Organ Quorum | `gate_g6_organ_quorum` | 동일 |
| `G7` Boundary Witness | `gate_g7_boundary_witness` | 동일 |
| `G8` Crown Precedence | `gate_g8_crown_precedence` | 동일 |

`02` §5.2의 18개 edge는 `index.json`에 등록하지 않는다. region `exits[]` 안에 인라인으로 있고, 18개가 전부 존재하는지 + 실제 인접 관계가 `02`와 일치하는지는 `10`의 `test_region_graph_matches_02_canonical_world`가 검사한다. `02`는 **bidirectional**으로 정의했으므로 catalog에서도 `A.exits`에 `B`가 있으면 `B.exits`에도 `A`가 있어야 한다 → `edge_not_bidirectional` error.

- `E18`(R5–R8)이 18번째 edge다. `R8`의 `entry.edge_id`와 `exits[].edge_id`는 **둘 다** `route_e18_folding_school_approach`여야 한다(`02` §1.1: "`E18`은 양방향 edge다").
- `E18`의 gate는 `gate_g5_labor_pledge` **하나**다. `gate_g9`를 만들면 `unknown_gate_id` error. `R8`의 curriculum/lineage/concentration 등록은 gate가 아니라 `RC-08`이 만든 region state다(`02` §5.2/§6.1).
- `R8`의 두 번째 return affordance는 edge가 아니라 `region_*.internal_routes[]`다(§5.10.1). `R8`은 `exits`가 1개이므로 `single_return_affordance`를 exemption 없이 걸면 안 된다.
- `E18`의 resource gate는 `res_concentration_sample` 1 + `res_craft_credit` 1이다(`02` §5.5). `E18`을 여는 근거는 `G5` resolution이며, `res_labor_pledge`는 `E05`/`E18` 양쪽에서 읽는 **비수량 debt key**다.

#### 3.5.3 NPC (`04` §2) — canonical core roster 14명

`04`의 `npc_01_ilyra_senn` … `npc_14_eda_marrow`가 **그대로** catalog ID다(문법을 이미 만족한다). `03`의 계획 ID는 아래처럼 재키한다.

| `03` 계획 ID | catalog ID |
|---|---|
| `NPC_IONA_VEY`, `REL_IONA_*` | `npc_01_ilyra_senn`, `rel_01_ilyra_record` |
| `NPC_NERA_KEST` | `npc_11_cael_ren` (social continuity·clone) + `npc_05_nera_voss` (organ broker) |
| `NPC_SABLE_ORR` | `npc_04_sable_halm` (transformation support) + `npc_06_tamas_quill` (private lexicon) |
| `NPC_MARA_VELL` | `npc_05_nera_voss` |
| `NPC_OREN_VALE` | `npc_05_nera_voss` |
| `NPC_LIO_FEN` | `npc_09_perrin_lask` |
| `NPC_RUSK_DELL` | `npc_10_juno_caster` + `npc_01_ilyra_senn` |
| `NPC_PELL_OAR`, `NPC_RHEA_SALT` | `npc_07_bryn_oskel` |
| `NPC_HALE_SEN` | `npc_08_meral_dune` |
| `NPC_NIX_ORR` | `npc_10_juno_caster` |
| `NPC_ARDEN_ROOK` | `npc_01_ilyra_senn` |
| `NPC_TAMSIN_QUILL` | `npc_12_ravenna_holt` |
| `NPC_ELI_MARLOW` | **재키 금지** — `04` §2.3/§2.4: support resident, `npc_*` ID 없음. `npc_02_orrin_kest`의 intake surface로 재사용 |
| `NPC_CALLA_ORN` | `npc_05_nera_voss` |
| `NPC_THE_SURVEYOR` | `npc_07_bryn_oskel` |
| `PLAYER_BRIDGE_0` | **재키 금지.** player role ID이지 NPC ID가 아니다. `npc_*`로 만들지 않는다 |

- `rel_*` ID는 `rel_<npc 번호 2자리>_<snake>` 형태를 쓴다(예: `rel_01_ilyra_record`, `rel_05_nera_organ`, `rel_12_ravenna_seat`). `04`의 relationship 표와 대조한다.
- `npc_15_mira_vask`(`07` §2.1) → `npc_20_mira_vask` (`roster_kind: support`). `R8`은 15번째 core actor를 만들지 않는다.
- `07`의 `npc_15_*` 나머지(R8 actor) → `npc_20_*`–`npc_26_*` support namespace. `npc_15`–`npc_19` 번호는 **사용하지 않는다** → `support_roster_id_range_forbidden` error.
- `02` §7.9의 `R8` support resident 7명은 `04` §2.4가 stable ID를 부여했다. 그대로 쓴다.

  | `02` R8 resident | catalog ID | `region_role` | magic port |
  |---|---|---|---|
  | `Mira Vask` | `npc_20_mira_vask` | `magic_training_craft_labor` | course index / student status |
  | `Halen Osk` | `npc_21_halen_osk` | `magic_training_craft_labor` | medium store / `craft_credit` |
  | `Iven Marrow` | `npc_22_iven_marrow` | `magic_training_craft_labor` | weave yard grading |
  | `Turo Bex` | `npc_23_turo_bex` | `boundary_crown_precedence` | `contract_tally` / contract 문서 |
  | `Perri Lowe` | `npc_24_perri_lowe` | `magic_training_craft_labor` | `lineage_token` |
  | `Jano Fesk` | `npc_25_jano_fesk` | `organ_authority_negotiation` | organ craft residue |
  | `Cael Orin` | `npc_26_cael_orin` | `translation_precedence` | `unassigned stock` / `untranslated term` |

  **core roster는 여전히 14명이다.** `R8` support resident는 `npc_20_*`–`npc_26_*` **7명**이 전부다. `npc_27_*`–`npc_29_*`는 이 Kit revision에서 **미할당**이다(§3.5.3 re-key 표에 `NPC_ELI_MARROW` 행이 있어도 `npc_*` ID를 부여하지 않는다). `NPC_ELI_MARROW`는 `03` §0.1/`04` §2.3대로 ID 없는 support resident이다.
- `npc_20_*`–`npc_26_*`는 전부 `region_*.residents[]`에 들어가야 하지만 `initial_presence`가 `transient`/`visiting`이어야 한다 → `core_roster_presence_mismatch` warning(§5.10). core 14명은 자기 home region에 `resident`로 있어야 한다(§5.11).
- `PLAYER_BRIDGE_0`를 "canonical NPC/role ID로 재키하라"는 resolution 문구를 **NPC 생성으로 해석하지 않는다.** `04`가 이미 "player role ID, NPC ID 아님"이라고 명시했고 `10`의 `test_fourteen_core_npcs_own_the_canonical_roster`가 14 core roster만 센다. `07`의 player role 표현은 payload 필드로 다룬다.

#### 3.5.4 enemy / encounter / group / variant / NPC-conversion (`05`)

| `05` 계획 ID | catalog ID | landing kind |
|---|---|---|
| `FAM-ARPG-01` … `FAM-ARPG-19` | `enemy_<snake family name>` | `enemy_*` |
| `ACT-<FAMILY>-BASELINE` | `act_<family>_basic` | `actions` |
| `ACT-<FAMILY>-SIGNATURE` | `act_<family>_signature` | `actions` |
| `ACT-<FAMILY>-COUNTER` | `act_<family>_counter` | `actions` |
| `ACT-<CODE>-<SLUG>` (이름 붙은 action) | `act_<family>_<snake slug>` | `actions` |
| `ENC-ARPG-01` … `ENC-ARPG-10` (field 10) | `enc_<snake name>` | `encounters` |
| `ENC-ARPG-11` … `ENC-ARPG-24` (boss 14) | `enc_<snake name>` | `encounters` |
| `ENC-ARPG-25` The Fold That Refuses the Hand | `enc_fold_that_refuses_the_hand` | `encounters` (field 11, `R8` data-only) |
| `GRP-ARPG-01` … `GRP-ARPG-05` | `enc_<snake name>_group` | `encounters` (§5.17 `group`) |
| `VAR-ARPG-01` … `VAR-ARPG-06` | `enc_<base>_var<n>` | `encounters` (`base_encounter_id` + `variant_overrides`) |
| `NPC-CONV-ARPG-01` … `NPC-CONV-ARPG-05` | `npc_<nn>_<snake>_conversion` | `npcs` (`encounter_profile`) |
| `CL-INST` | `clock_institutional_response` | `clocks` |
| `CL-CONT` | `clock_contamination` | `clocks` |
| `CL-REC` | `clock_public_record` | `clocks` |
| `CL-RES` | `clock_resource_collapse` | `clocks` |
| `CL-PER` | `clock_personal_collapse` | `clocks` |
| `CL-CROWN` | `clock_crown_alignment` | `clocks` |
| `S001` … `S160` | `seed_s001` … `seed_s160` | `seeds` |
| `ink_credit`, `entry_token`, … (22개 + `latency_key`는 `res_latency_token`으로 `02` §5.2 행에 등록) | `res_<snake name>` | field/world resource token (§6.3) |
| `recorded`, `redaction_mark`, … (status 이름) | `st_<snake>` | `statuses` |
| `concentration_load`, `medium_residue`, `misfolded`, `overflowed`, `contract_bound` | `st_<snake>` | `statuses` (§5.4.1, magic 5종) |
| `ACT-CGW-GRADE-MARK` | `act_grading_wall_basic` | `actions` |
| `ACT-CGW-FOLD-VERDICT` | `act_grading_wall_signature` | `actions` |
| `ACT-CGW-DISPERSE-READING` | `act_grading_wall_counter` | `actions` (`turn_cost: 0`, `SELF`) |
| `concentration_sample` … `labor_pledge` (10개) | `res_<snake name>` | field/world resource token (§6.3, magic 10종) |

- **retired: `R-RETURN`, `R-CROWN`, `R-ARCHIVE`, `R-LATENCY`, `R-LEXICON`, `R-VISCERA`, `R-SERVICE`, `R-COMMON`, `R-SEAM`.** 이 아홉 개의 shorthand key는 `05` §2.6이 명시적으로 폐기했다.|region ID가 아니었고 1:1로 대응하지 않았으며, `R-LATENCY`는 특히 서로 다른 role을 가진 두 region에 걸쳐 있었다. content에 나타나면 `unrekeyed_planning_id` error이고, 대응표는 두지 않는다.
- 그 자리를 대체하는 것은 **record 단위 `region_secondary`**다(§5.16, §5.17). 두 region에 걸치는 record는 base region의 `region_id`/`region_role`을 record에 쓰고 두 번째 region을 `region_secondary`에 적는다. `R-LATENCY`의 확정된 분할: faith-as-latency·care latency·signal relay는 `R3` `intervention_scheduling`, boot·permit·transformation service는 `R5` `permission_before_transformation`이다. **`region_role_split_unresolved` warning은 이 결정과 함께 삭제한다** — 분할은 이제 record가 직접 말하므로 catalog가 "애매함"을 추측할 필요가 없다. 대신 `region_secondary`가 해석되지 않으면 `region_secondary_not_canonical` error다.
- **`GRP-ARPG-06`–`GRP-ARPG-12` 범위는 retired다.** 유효 집합은 `05` §6.1의 5개 template(`GRP-ARPG-01`–`GRP-ARPG-05`)뿐이다. 여섯 번째 group은 이 Kit revision에 없다. magic 층도 group을 추가하지 않는다 — `ENC-ARPG-25`는 `FAM-ARPG-19`와 `FAM-ARPG-02`로 roster를 직접 구성한다. 여섯 번째 이후의 `GRP-ARPG-*`가 content에 나타나면 `unrekeyed_planning_id` error다.
- `FAM-ARPG-19` Grading Wall은 magic 층이 **추가하는 유일한 family**이고 `ENC-ARPG-25`는 **추가하는 유일한 encounter**다. 둘 다 `region_role: magic_training_craft_labor`, `region_id: region_r8_folding_school`이다. `VAR-ARPG-06`는 `enc_fold_that_refuses_the_hand_var1`, `NPC-CONV-ARPG-05`는 `npc_14_eda_marrow_conversion`이다.
- field encounter는 **11개**(`ENC-ARPG-01`–`ENC-ARPG-10` + `ENC-ARPG-25`), boss는 14개, group은 5개, variant는 6개, NPC-conversion은 5개다. `05` §8의 개수 대조가 이 숫자를 검사한다.
- `clock_*` ID는 `02` §4의 6개와 1:1이다. content가 새 clock을 만들지 않는다 → `clock_not_canonical` error.

#### 3.5.5 recovery type 표기 (`08` §7)

`08`의 continuity 표는 **표기**가 다르지만 종류는 7개가 전부다. `rec_*.kind`는 아래 canonical 7개만 쓴다.

| `08` 표기 | `rec_*.kind` (canonical) |
|---|---|
| `checkpoint_return` | `checkpoint` |
| `respawn` | `respawn` |
| `clone_branch` | `clone` |
| `reincarnation` | `reincarnation` |
| `loop_rehearsal` | `loop` |
| `immortal_continuation` | `immortality` |
| `institutional_reentry` | `institutional_reentry` |
| `crown_alignment` | **없음.** recovery type이 아니라 global irreversible world write다(§5.8) |

#### 3.5.6 ending / dialogue 표기 (`03`)

| `03` 계획 ID | catalog ID |
|---|---|
| `END_R1_RECEIPT_OF_A_LIFE` | `end_r1_receipt_of_a_life` |
| `END_G1_LAW_WITHOUT_MASTER` | `end_g1_law_without_master` |
| `END_O1_MANY_MOUTHS_ONE_PERSON` | `end_o1_many_mouths_one_person` |
| `END_A1_EMPTY_SEAT` | `end_a1_empty_seat` |
| `END_C1_FOUR_ANCHORS` | `end_c1_four_anchors` |
| `END_C2_LAST_WITNESS` | `end_c2_last_witness` |

- `end_*`는 **`03`이 소유한 ending ID**이며 `06`의 kind prefix 표에 없다. `06`은 `end_*`를 `index.json`에 등록하지 않고, `03`의 ending이 참조하는 `prop_*`/`rel_*`/`enc_*`/`npc_*`/`clock_*`만 해석한다. `10`의 `test_ending_catalog_matches_03_and_rewrites_roster_ids`가 re-key 완료를 확인한다.
- `03`의 `CHOICE_*`, `NODE_*`, `THREAD_*` 계획 ID는 `conv_*` 파일 안의 `choice_id`/`page_id`와 `initial_cluster.thread_ids`로 내려간다. thread는 content kind가 아니다(§5.10).

#### 3.5.7 event cluster (`02` §8) — 9개 고정, `region_*.initial_cluster` 안의 인라인 sub-record

| `02` cluster | catalog `cluster_id` | owning region |
|---|---|---|
| `HC-00` The First Docket | `cluster_hc_00_first_docket` | `region_h0_undersign_exchange` |
| `RC-01` Wrong Return | `cluster_rc_01_wrong_return` | `region_r1_returning_kiln` |
| `RC-02` Same Water | `cluster_rc_02_same_water` | `region_r2_siltglass_commons` |
| `RC-03` Mercy Delay | `cluster_rc_03_mercy_delay` | `region_r3_bellhouse_hospice` |
| `RC-04` Sentence Above the Stair | `cluster_rc_04_sentence_above_stair` | `region_r4_crownwell_archive` |
| `RC-05` Uniform, Name, Contract | `cluster_rc_05_uniform_name_contract` | `region_r5_glasswing_ordinal` |
| `RC-06` The Heart's Petition | `cluster_rc_06_hearts_petition` | `region_r6_gristmarket_ward` |
| `RC-07` Map Made by the Wall | `cluster_rc_07_map_made_by_wall` | `region_r7_hollow_orchard` |
| `RC-08` The Fold That Refuses the Hand | `cluster_rc_08_fold_refuses_hand` | `region_r8_folding_school` |

- `cluster_id`는 §2.9의 전역 유일 예외이며 `02` §8 registry와 1:1이다. `region_*.initial_cluster.cluster_id`는 **그 region의 행 값과 정확히 같아야 한다** → `cluster_id_not_canonical` error. 다른 region의 cluster id를 쓰면 `cluster_not_one_to_one` error.
- 9개가 전부 존재해야 한다 → Stage 4 `cluster_catalog_incomplete` error. `RC-08`도 예외가 아니다(§0bis, `07` §14.1 A1).
- `initial_cluster.thread_ids`는 자유 snake_case이고 `02`/`03`의 thread 이름만 쓴다. thread는 content kind가 아니다.
- `RC-08`의 `magic_training_craft_labor` 성격은 `region_role`이 이미 표현한다. cluster가 별도의 magic token을 갖지 않는다.

---

## 4. 공통 문법 두 개

모든 kind는 아래 두 문법만으로 조건과 효과를 표현한다. 이 두 문법 외에 표현력 있는 DSL, script, expression, eval을 도입하지 않는다.

### 4.1 Condition

```json
{ "all_of": [ CONDITION ], "any_of": [ CONDITION ], "not": CONDITION }
```

- 조합 key는 `all_of`/`any_of`/`not` 중 **최대 하나만** 허용한다. 같은 object에 둘 이상이면 `condition_shape_invalid`.
- 빈 `all_of`는 `{}`(항상 참)로만 쓴다. 빈 `any_of`는 금지(`condition_shape_invalid`) — 항상 거짓 조건은 content 버그다.
- `{}`는 항상 참이다. 명시적으로 "항상 거짓"을 쓰려면 금지된 상태를 `not`으로 감싼다.
- 최대 깊이 4, leaf 최대 32개, node 최대 64개.

### 4.2 Condition leaf catalogue

`{}`가 아닌 condition object는 **정확히 하나**의 leaf key를 가진다.

| leaf | 필드 | 의미 |
|---|---|---|
| `axis_at_least` | `axis`(§6.1의 4개 token), `value`(int -3..3) | world orthogonal axis 현재값. 정수만 허용 |
| `clock_at_least` | `clock_id`, `stage_index`(int ≥0, `02` ladder index) | clock이 해당 stage 이상 진행 |
| `clock_irreversible` | `clock_id` | clock이 `02` ladder의 irreversible stage 이상에 진입 |
| `npc_state_is` | `npc_id`, `key`(§4.3 token), `value`(string/int/bool) | NPC 런타임 state token |
| `npc_present` | `npc_id`, `presence`(§5.11 token) | NPC 존재/부재 |
| `relationship_is` | `relationship_id`, `target_npc_id`, `state_id` | relationship 현재 state |
| `relationship_visited` | `relationship_id`, `target_npc_id`, `state_id` | 해당 state를 한 번이라도 지남 |
| `route_open` | `gate_id`(§3.5.2 `gate_g*`) | route gate 개방 |
| `prop_state_is` | `prop_id`, `state_id` | world prop 현재 state |
| `region_visited` | `region_id`, `min_visits`(int ≥1, default 1) | region 방문 횟수 |
| `region_is` | `region_id` | 현재 region |
| `encounter_cleared` | `encounter_id`, `min_count`(int ≥1, default 1) | encounter clear 횟수 |
| `document_read` | `document_id`, `min_count`(int ≥1, default 1) | document 읽기 횟수 |
| `document_corrupted_at_least` | `document_id`, `stage_index` | document corruption 단계 |
| `choice_taken` | `conversation_id`, `choice_id` | 특정 choice를 선택함 |
| `choice_not_taken` | `conversation_id`, `choice_id` | 특정 choice를 선택하지 않음(미해결) |
| `conversation_completed` | `conversation_id` | 대화 완주 |
| `recovery_done` | `recovery_event_id`, `min_count`(int ≥1, default 1) | recovery 실행 횟수 |
| `effect_fired` | `effect_id` | effect가 한 번 이상 발화함 |
| `world_flag_is` | `key`(`world_` prefix), `value`(bool) | world flag |
| `equipment_held` | `equipment_id`, `min_count`(int ≥1, default 1) | 장비 보유 수 |
| `item_held` | `item_id`, `min_count`(int ≥1, default 1) | 소모품 보유 수 |
| `resource_held` | `resource_key`(§6.3), `min_count`(int ≥1, default 1) | field/world 자원 보유 수 |
| `status_present` | `status_id`, `stacks_at_least`(int ≥1, default 1) | 현재 actor에게 status 있음 |
| `recovery_type_done` | `recovery_event_id` | 해당 `rec_*`가 canonical 7 kind 중 무엇인지 직접 조건화 |
| `save_slot_count_at_least` | `count`(int ≥1) | recovery `clone` 분기용. meta지만 content가 요구할 때만 |

- `axis_at_least.value`는 **정수**만 받는다. `02`의 named ladder token(`provisional`, `artifact`, `crown-debt` …)을 여기에 넣으면 `axis_token_in_integer_field` error다. token↔integer mapping은 `02`가 소유한다(§6.1).
- `npc_state_is.key` token은 `presence`, `state_key`, `region_id`, `acting_role` 4개로 **닫힌**다. `§5.11`의 `npc_state` op이 쓰는 key 집합과 정확히 같아야 한다. `key_error_mismatch`로 검사한다. 임의 문자열 key를 열어 두면 save schema가 무한 확장된다.
- `rec_*.kind`는 7개 enum 밖 token을 받지 않는다. `08`의 표기(`checkpoint_return`, `clone_branch`, `loop_rehearsal`, `immortal_continuation`)를 content에 쓰면 `recovery_kind_token_mismatch`다(§3.5.5).

### 4.3 Effect operation catalogue

`EffectDefinition.operations[]`의 각 원소는 `op` 하나와 그 op이 허용하는 key만 가진다.

| op | 허용 key | 의미 |
|---|---|---|
| `set_axis` | `axis`, `value`(int -3..3) | axis 현재값을 **설정**(가산 아님) |
| `advance_clock` | `clock_id`, `ticks`(int ≥1), `optional stage_id` | clock을 `ticks`만큼 전진. `stage_id`가 있으면 그 stage 직전까지 최소 전진 |
| `set_clock_stage` | `clock_id`, `stage_id` | clock을 특정 stage로 강제 설정 |
| `npc_state` | `npc_id`, `key`(§4.2 token), `value` | NPC state token 변경 |
| `relationship` | `relationship_id`, `target_npc_id`, `to_state_id`, `optional reason` | relationship state 전이. 유효하지 않은 전이는 `no_op` + `effect_transition_rejected` report |
| `prop_state` | `prop_id`, `state_id` | world prop state 설정 |
| `unlock_route` | `gate_id` | route gate 개방 |
| `region_state` | `region_id`, `state_tag`(snake, 3..32자) | region 자유 상태 tag 설정 |
| `reveal_document` | `document_id` | document 해금 |
| `grant_equipment` | `equipment_id`, `count`(int ≥1) | 장비 지급(인벤토리 보유량 증가) |
| `consume_equipment` | `equipment_id`, `count`(int ≥1) | 장비 소모. 부족하면 op 실패 → `effect_partial_failure` |
| `grant_item` | `item_id`, `count`(int ≥1) | 소모품 지급 |
| `consume_item` | `item_id`, `count`(int ≥1) | 소모품 소모. 부족하면 op 실패 → `effect_partial_failure` |
| `apply_status` | `target`(`self|selected_actor|enemy_id` 구체값), `status_id`, `stacks`(int ≥1) | status 부여 |
| `clear_status` | `status_id`, `target` | status 제거(특정 cure category가 아니라 id 직접) |
| `queue_encounter` | `encounter_id`, `at`(`immediate|next_field_entry|post_recovery`) | encounter 예약 |
| `queue_recovery` | `recovery_event_id` | recovery 예약 |
| `flag` | `key`(`world_` prefix), `value`(bool) | world flag 설정 |

닫힌 규칙:

- `operations`는 1..24개. 0개면 `effect_empty`, 25개 이상이면 `effect_too_large`.
- `op` 값은 위 표에 없으면 `unknown_operation`. 새 op은 §12.3 예외 절차를 탄다.
- 각 op의 key 집합이 표와 정확히 일치하지 않으면 `operation_key_mismatch`.
- `npc_state.key`가 §4.2 token 집합 밖이면 `key_error_mismatch`.
- `set_axis`는 가산이 아니다. 현재값을 직접 지정한다. 축 누적을 필요로 하면 `02`가 `axis_rules` 형태로 먼저 확정하고, 그때 schema bump 절차를 탄다(§12.3).
- `set_axis.value`는 `02` ladder 안에 있는 정수여야 한다 → `axis_out_of_range` / `axis_value_off_02_ladder`.
- `set_clock_stage.stage_id`는 `02`가 소유한 해당 clock의 stage ladder token이어야 한다 → `clock_stage_not_in_02_ladder`.
- `unlock_route.gate_id`는 `02` §6.1의 9개 gate 중 하나여야 한다 → `unknown_gate_id`.
- `world_flag` key 개수가 catalog 전체에서 `index.options.max_world_flags`(24)를 넘으면 `flag_namespace_overflow`.
- op 실행 중 하나가 실패하면 앞선 op은 **rollback**한다. effect는 원자적이다. `consume_equipment`/`consume_item` 부족이 대표적 실패다.
- `immediate` effect는 다른 `immediate` effect를 `queue_*`할 수 없다. `immediate_effect_chain` error. depth 1의 간접 발화(→ region enter → clock stage)는 허용한다.
- **전투 resolution 중에는 이 op 목록이 실행되지 않는다.** `Effect`는 encounter 결과·field event·clock stage·recovery 결과 시점에서만 발화한다. 전투 한 턴의 resolution hook이 `Effect`를 발화시키는 경로는 §12.3 예외 대상이며 현재 없다.

### 4.4 수식과 resource/damage enum 규칙

수식은 interpreter가 아니라 **closed token**이다.

| field | 허용 형태 |
|---|---|
| `damage.base_value` | 정수 0..9999 (`shape == "percent_*"`면 percent 0..100) |
| `damage.shape` | `fixed`, `percent_max_hp`, `percent_current_hp`, `guaranteed` |
| `resource` formula (`status.tick`, `recovery.cost`) | `zero`, `flat_<int 0..9999>`, `pct_max_hp_<int 0..100>`, `pct_missing_hp_<int 0..100>`, `pct_resource_max_<resource>_<int 0..100>`, `self` |
| `ticks`, `turns`, `windows` | 정수 |
| chance/비율 | 정수 permille 0..1000 (`chance_permille`) |
| HP 비율 | 정수 percent 0..100 (`hp_ratio_at`) |

`chance`를 float으로 쓰지 않는다. `1.0` 대신 `1000`을 쓴다. HP 비율도 float이 아니라 percent 정수다. 이렇게 하면 §2.1의 float round-trip 논쟁이 사라지고 save에도 float이 생기지 않는다(§10.2 규칙 4). 예외는 `document.reading.world_visible_ratio` 하나뿐이고, 그것도 0.05 단위로 반올림한다.

#### 4.4.1 damage payload vocabulary (`01` §6.5와 1:1)

`01`이 `DamagePayload`의 **의미와 계산 순서**를 소유한다. 이 문서는 content가 그 축을 **어떤 키 이름으로** 담는지만 고정한다. 값이 다른 축을 추가하지 않는다.

| content key | 허용 enum/범위 | `01` 대응 |
|---|---|---|
| `delivery` | `physical`, `magical`, `true` | `delivery` |
| `shape` | `fixed`, `percent_max_hp`, `percent_current_hp`, `guaranteed` | `shape` |
| `base_value` | int 0..9999 | `base_value` |
| `affinity` | `none`, `fire`, `ice`, `lightning`, `light`, `darkness` | `affinity` |
| `hit_policy` | `roll`, `guaranteed` | `hit_policy` |
| `hit_modifier` | int -99..99 | `hit_modifier` |
| `evasion_policy` | `roll`, `disabled` | `evasion_policy` |
| `critical_policy` | `never`, `chance`, `always` | `critical_policy` |
| `dodge_pressure` | int 0..99 | `dodge_pressure` |
| `guard_ignore` | bool | `guard_ignore` |
| `breaks_guard` | bool | `breaks_guard` |
| `break_damage` | int 0..9999 | `break_damage` |
| `dodgeable` | bool | `dodgeable` |
| `break_damage_kinds` | `hp_damage`, `condition_damage`의 부분집합(0..2) | `break_damage_kinds` |
| `self_damage` | int 0..9999 | `self_damage` |
| `lifesteal` | int 0..999 | `lifesteal` |
| `reflect` | int 0..9999 | `reflect` |
| `on_hit_payload_ids` | `eff_*` 0..4개 | `on_hit_payload_ids` |
| `on_evade_payload_ids` | `eff_*` 0..4개 | `on_evade_payload_ids` |

강제 규칙(`01` §6.5와 동일):

- `delivery == "true"` ⇒ `dodgeable == false` **그리고** `evasion_policy == "disabled"` 필수 → `true_damage_dodgeable` error.
- `shape`가 `percent_max_hp` / `percent_current_hp`면 `base_value`는 percent로 읽는다. 100 초과면 `number_out_of_range`.
- `shape == "guaranteed"`는 `hit_policy`를 덮어쓰지 않는다. `hit_policy == "guaranteed"`는 hit roll만 건너뛰고 dodge roll은 별도다(`01` §6.5). 두 가지를 같은 키로 합치지 않는다.
- `guard_ignore == true`는 directed HP damage만 우회한다. `self_damage`/`reflect`/DoT에는 적용되지 않는다.
- `break_damage > 0`인데 `counters.breakable == false`이면 `break_damage_on_unbreakable` error.
- `on_hit_payload_ids`의 effect는 `01` §9.3의 13번(lifesteal/reflect/on-hit trigger) 위치에서 발화한다. **hook 순서는 core 소유이며 content는 ID만 준다.** content가 hook 순서를 재배열할 수 없다.

#### 4.4.2 `target_hp_or_condition` — combat bar의 유일한 이름

- B 화면에서 관찰된 별도 bar의 catalog 이름은 **`target_hp_or_condition`** 하나다. `09`가 화면 위치를 소유하고, 값과 전진 규칙은 이 문서의 `enemy_*.condition_bar`(§5.16)가 소유한다.
- content는 이 이름 외의 bar를 만들지 않는다. `enemy_*.condition_bar.kind` enum은 `hp`, `condition_progress`, `stability` 3개로 닫힌다. `generic_bar`, `red_bar`, `danger_bar` 같은 값은 `content_infers_bar_semantics` error.
- **generic red bar를 만들지 않는다.** `09` §4.3이 이 Kit 결정을 "combat domain이 projection하는 전용 bar"로 고정했고, `10`의 `test_target_hp_or_condition_bar_is_domain_projected`가 "UI가 앞에서 재계산하지 않는다"를 요구한다. content는 authored 시작값·최댓값·전진 트리거만 준다.
- bar에는 AP를 담지 않는다. AP label/gauge는 `01`·`09`·`10`과 함께 금지이며 이 문서가 만드는 data도 없다.

### 4.5 왜 interpreter는 두 개뿐인가

- `Condition`은 region exits/hidden_state, choice availability, phase trigger condition, encounter/remix eligibility, clock reversal, recovery trigger condition, prop `hidden_until_condition`에서 **7곳** 사용된다. 하나의 문법, 하나의 의미.
- `Effect` operation은 `EffectDefinition`과 `StatusDefinition.tick.operations`에서 **2곳** 사용된다. 두 번째 사용처가 이미 확정돼 있다(`§5.4`), 즉 미래 가정이 아니다.
- 그 외 공통 추출은 없다. 특히 `status`와 `relationship`과 `recovery`는 **저장하는 대상**이 다르다(각자의 `08` section). 이 셋을 "공통 progression state"로 묶으면 `docs/CODE_STYLE.md`의 "장르 공통 core에 냄새"가 된다. 금지한다.

---

## 5. Kind별 schema

아래 모든 예시는 **완전한 파일**이 아니라 core shape를 보여주는 축약본이다. 실제 file은 `schema_version`과 `id`를 갖고, 예시에서 생략된 optional key는 **아예 없는 것**으로 읽는다(§2.4). 예시 축약은 문서용이고, validator는 예시를 허용하지 않는다. 실제 key allowlist는 각 항목의 "허용 key" 줄이 단일 source다.

예시끼리 참조하는 id(예: `enemy` 예시가 참조하는 `phase`)는 **같은 절에 짝 예시가 없을 수 있다.** 그런 참조는 `§14`의 fixture에서 완성한다. 한 예시가 자기 안에서 도달 불가능한 참조를 만들지만 않으면 된다.

예시 ID는 전부 §3.5의 canonical ID다. `region_terminal_ledger_hall` 같은 구버전 region 이름은 이 문서에 더 이상 나오지 않는다.

### 5.1 `ledger` — LedgerDefinition

분모와 quota의 단일 source. content가 아니라 **계약**이다. 이 파일은 하나뿐이다.

```json
{
  "schema_version": 1,
  "id": "seed_ledger",
  "ledger_source": "docs/research/top_down_action_rpg/IDEA_LEDGER.md",
  "ledger_version": 1,
  "denominator": {
    "extracted_units": 160,
    "unit_rule": "independent_idea_unit",
    "excluded_from_denominator": ["dialogue_metadata", "author_attribution", "date_line", "duplicate_wording", "no_new_causal_relation"],
    "line_count_is_not_denominator": true
  },
  "quota": {
    "ratio_permille": 600,
    "gate_status_token": "planned_retained",
    "minimum_retained": 96,
    "preferred_planned": 120,
    "post_review_status_token": "used",
    "post_review_counts_toward_gate": false
  },
  "diversity": {
    "minimum_distinct_clock_kinds_in_catalog": 3,
    "max_single_ledger_section_share_permille": 250
  },
  "gate": {
    "blocks_review_ready": true,
    "blocks_runtime_start": false
  }
}
```

허용 key: 위 6개. 검증:

- `id`는 정확히 `seed_ledger`.
- `denominator.extracted_units`는 1..10000 정수. 이 Kit은 **160 고정**(`IDEA_LEDGER` §4, K-ARPG10). `unit_rule`은 `independent_idea_unit` 고정.
- `denominator.excluded_from_denominator`는 **정확히 5개**여야 한다(위 목록). 아니면 `ledger_exclusion_list_incomplete`. 원문 줄 수가 분모가 아니라는 근거가 여기서 고정된다.
- `quota.minimum_retained`는 `floor(extracted_units * ratio_permille / 1000)`와 **정확히 같아야 한다**. 다르면 `ledger_quota_arithmetic_mismatch`. 160 × 600 / 1000 = 96. 분모와 비율이 서로 어긋난 채 방치되는 것을 막는다.
- `quota.preferred_planned >= quota.minimum_retained`.
- `quota.ratio_permille` ∈ 1..1000. 이 Kit은 600 고정.
- `quota.gate_status_token`은 `planned_retained` 고정, `quota.post_review_status_token`은 `used` 고정 → `quota_token_mismatch`. **gate는 `planned_retained` transform 수를 센다.** `PLAN_RESOLUTION` §6이 "`USED`/`TRANSFORMED` planning claim 금지"라고 명시했기 때문에, 계획 단계에서 `used`/`transformed`를 세면 quota를 충족시키기가 아니라 **우회**하는 것이 된다.
- `quota.post_review_counts_toward_gate`는 `false` 고정. 검수 뒤에 `used`로 승격된 seed가 gate를 이미 충족시킨 것으로 재집계되지 않는다.
- `gate.blocks_runtime_start`는 `false` 고정. quota는 구현을 막지 않고 **검토 준비 완료 선언만** 막는다(§13.6).
- 이 파일이 없거나 실패하면 seed 전체가 unavailable이고 catalog은 `CONTENT_UNAVAILABLE`이다. denominator는 임의로 정하지 않는다.

### 5.2 `seeds` — SeedBindingDefinition

`array: true` kind다. 한 file에 ledger section 하나의 record들을 담는다.

```json
{
  "schema_version": 1,
  "records": [
    {
      "schema_version": 1,
      "id": "seed_s019",
      "ledger_section": "B",
      "ledger_usage_class": "SYSTEM",
      "status": "planned_retained",
      "source_intent": "기록이 사건보다 오래 산다.",
      "tin_structural_change": "record를 설명이 아니라 실행 가능한 local law로 만든다. 두 번역이 같은 filing weight를 갖는다.",
      "local_rule": "두 번역 중 하나가 먼저 Filing되면 그 문장이 region's operative rule이 된다. 해석이 아니라 접수 순서가 법을 만든다.",
      "bindings": [
        {"kind": "npc", "id": "npc_01_ilyra_senn"},
        {"kind": "region", "id": "region_r4_crownwell_archive"}
      ],
      "cross_link_a": {"kind": "npc", "id": "npc_01_ilyra_senn", "how": "이 NPC의 inquiry port가 Filing 순서를 입력으로 받는다."},
      "cross_link_b": {"kind": "clock", "id": "clock_public_record", "how": "Filing이 public_record clock 단계를 올린다."},
      "immediate_consequence": "Filing이 확정되면 region gate 하나가 열린다.",
      "delayed_consequence": {"timing": "on_clock_stage", "effect_id": "eff_ilyra_files_contradictory_copy", "what": "clock이 irreversible stage에 닿으면 기록이 사람보다 먼저 확정된다."},
      "anti_generic_gates": {
        "g1_local_rule": true,
        "g2_surface_removed_variant": true,
        "g3_two_cross_links": true,
        "g4_immediate_consequence": true,
        "g5_delayed_consequence": true,
        "g6_needed_by_npc_region_or_system": true,
        "g7_name_swap_still_specific": true,
        "g8_not_weirdness_only": true
      },
      "generic_risk_test": {
        "name_only_reskin": false,
        "justified_by_weirdness_only": false,
        "notes": "원 surface는 사건 문서다. 여기서는 Filing 순서가 gameplay gate이므로 이름만 바꾸면 성립하지 않는다."
      },
      "provenance": {"source_kind": "user_memo", "no_original_wording_copied": true}
    }
  ]
}
```

`ledger_section`은 `IDEA_LEDGER`의 `## A.`~`## L.` heading 12개 중 하나다: `A`~`L`. 정확히 12개 값으로 닫힌다. 새 section은 constitution 개정 없이는 추가하지 않는다. **`L`은 magic supplement(`S121`–`S160`, 40개) 전용 section이다.**

검증:

- `id`는 `seed_s001` … `seed_s160`. `denominator.extracted_units`를 넘는 번호는 `seed_id_out_of_range`. 3자리 형식 위반은 `seed_id_malformed`.
- `seed_s001`–`seed_s160`이 **정확히 한 번씩** 존재해야 한다. 누락은 Stage 4 `ledger_incomplete`, 중복은 `duplicate_id`. 이 검사가 60% 분모를 감사가능하게 만든다.
- **`seed_s121`–`seed_s160`은 `ledger_section: "L"`이어야 한다** → `magic_seed_wrong_section` error. `S001`–`S120`이 `L`이면 같은 error. core와 magic supplement의 accounting을 섞지 않는다.
- `S121`–`S160`이 `planned_retained`이면 §13.2.1의 magic-specific gate 3개(`magic_seed_unbound`, `magic_seed_r8_only`, `magic_seed_without_clock_write`)를 전부 통과해야 한다.
- `ledger_usage_class` enum: `ROOT`, `SYSTEM`, `MODULE`, `TONE`, `ONEOFF`, `CANDIDATE`, `DROP`.
- **`status` enum: `planned_retained`, `used`, `rejected`.**
  - `planned_retained`이 **계획 단계의 유일한 정상 상태**다. `02` §11.2의 26개 transformation unit은 전부 이 상태다.
  - `used`는 **구현·검수 뒤에만** 사람이 직접 기록한다. `used`는 `quota.post_review_status_token`과 같은 문자열이어야 한다.
  - `rejected`는 class 요구 gate를 충족하지 못한 결과를 남길 때 쓴다.
  - `planning_claim` enum(`USED`, `TRANSFORMED`)은 **schema에 없다.** 계획 문서가 `USED`/`TRANSFORMED`를 주장하려면 schema bump가 필요하고, 그 bump는 §12.3 예외 2회를 소모한다 → `planning_claim_forbidden` error.
- `status == "planned_retained"`이면 class별 요구 gate가 전부 true여야 한다(요구 집합은 §13.2). 하나라도 false이면 `seed_gate_failed_without_rejection` error — 그 상태는 곧 `rejected`로 기록하라는 뜻이다.
- `status == "used"`이면 요구 gate가 전부 true **이고** `delayed_consequence.effect_id`가 필수이며 Stage 3에서 해석돼야 한다. 이 강제 덕분에 `used`가 "핵심 시스템에 실제로 묶였는지"를 assertion할 수 있다.
- `status == "rejected"`이면 `rejection.class` enum(`filler`, `duplicate`, `tone-only`, `source-copy-risk`, `unbound`)과 비어 있지 않은 `reason`이 필수. `bindings`는 비어도 된다.
- `ledger_usage_class`가 `CANDIDATE` 또는 `DROP`이면 `status != "used"` → `candidate_marked_used`.
- `provenance.source_kind` enum: `user_memo`, `bs2_structural_rule`, `kit_design`. `no_original_wording_copied`는 `true` 필수 → `source_copy_risk` error. 원장은 대본이 아니다.
- `cross_link_a.kind != cross_link_b.kind` 필수(§13.3의 transform 판정).
- `cross_link_a.id != cross_link_b.id` 필수 → `cross_link_self_referential`.
- `delayed_consequence.timing` enum: `delayed`, `on_clock_stage`, `on_encounter_end`, `on_recovery`, `on_region_enter`.
- `delayed_consequence.effect_id`가 있으면 그 effect의 `timing`이 `immediate`가 아니어야 한다 → `seed_delayed_is_immediate`.
- 양방향 seed binding(§9.3): `bindings`는 전부 해석돼야 하고 content 쪽 `seed_ids`와 대칭이어야 한다 → `seed_binding_asymmetric`.
- `ledger_usage_class == "ONEOFF"`이면 `bindings` 중 `npc` 또는 `prop` kind가 **정확히 1개**여야 한다. 두 개 이상이면 `oneoff_binding_not_local` error. 그 content가 2개 이상의 conversation에서 참조되면 Stage 4 `oneoff_overused` warning.
- `ledger_usage_class == "TONE"`이면 g1/g2/g7/g8만 요구하고 `delayed_consequence`는 선택이다. constitution R10이 detail에 대한 규칙이고 TONE은 명시적으로 voice-only이기 때문이다.
- `bindings[].kind` enum: `ledger`, `seed`, `effect`, `status`, `action`, `equipment`, `item`, `clock`, `relationship`, `recovery`, `prop`, `region`, `npc`, `conversation`, `document`, `phase`, `enemy`, `encounter`. `index.json`의 kind 목록과 대조해 어긋나면 `content_holds_unknown_kind`다.
- **`planned_retained` → `used` 승격은 자동화하지 않는다.** catalog·validator·tooling 어디에도 승격 경로가 없고, 승격은 ledger 파일의 직접 편집이며 `change_ledger` entry가 필요하다(§12.1-9, §13.7).

### 5.3 `effects` — EffectDefinition

```json
{
  "schema_version": 1,
  "id": "eff_ilyra_files_contradictory_copy",
  "timing": "delayed",
  "delay_ref": {"kind": "clock_stage", "id": "clock_public_record", "stage_id": "filed"},
  "operations": [
    {"op": "relationship", "relationship_id": "rel_01_ilyra_record", "target_npc_id": "npc_01_ilyra_senn", "to_state_id": "rs_filed_contradictory", "reason": "기록이 먼저 굳었다."},
    {"op": "flag", "key": "world_r4_translation_filed", "value": true}
  ],
  "one_shot": true,
  "repeat_guard": "once",
  "seed_ids": ["seed_s019"],
  "audit_note": ""
}
```

허용 key: 9개(`schema_version`, `id`, `timing`, `delay_ref`, `operations`, `one_shot`, `repeat_guard`, `seed_ids`, `audit_note`).

검증:

- `timing` enum: `immediate`, `delayed`, `on_region_enter`, `on_encounter_end`, `on_recovery`, `on_clock_stage`.
- `timing == "immediate"`이면 `delay_ref`가 **없어야 한다** → `effect_delay_mismatch`.
- 그 외에는 `delay_ref`가 필수이고, `timing` ↔ `delay_ref.kind`는 일대일로 강제된다.

  | timing | 허용 delay_ref.kind |
  |---|---|
  | `immediate` | 없음 |
  | `delayed` | `recovery`, `encounter`, `clock_stage`, `region` |
  | `on_region_enter` | `region` |
  | `on_encounter_end` | `encounter` |
  | `on_recovery` | `recovery` |
  | `on_clock_stage` | `clock_stage` |

  `delay_ref.kind == "clock_stage"`이면 `stage_id` 필수, 그 외 kind에 `stage_id`가 있으면 `effect_delay_mismatch`.
- `delay_ref.stage_id`는 `02`가 소유한 해당 clock의 stage ladder token이어야 한다 → `clock_stage_not_in_02_ladder`.
- `one_shot == true`이면 `repeat_guard`는 `once` 또는 `never_repeat` → `one_shot_guard_mismatch`.
- `repeat_guard` enum: `once`, `per_region_visit`, `per_encounter`, `never_repeat`.
- **`seed_ids`와 `audit_note` 중 정확히 하나만** 채워야 한다. 둘 다 비면 `ungrounded_effect` error, 둘 다 채우면 `double_justification` error. 이것이 constitution R10("detail은 두 곳 이상에 연결된다")을 data layer에서 강제하는 지점이다. `audit_note`는 "이 detail이 두 곳에 연결되지 않지만 필요한 이유"를 사람이 쓴다는 escape hatch이고, 어느 쪽으로 정당화했는지 하나만 고르게 한다.
- `operations`는 원자적이다. 어느 op이든 실패하면 전체 rollback.
- **`timing == "immediate"`인 effect가 전투 한 턴 안에서 발화하는 경로는 없다.** encounter 결과는 `on_encounter_end`로 표현한다. 전투 중 effect가 필요해지면 §12.3 예외 절차를 탄다.

### 5.4 `statuses` — StatusDefinition

BS2 §4.5: status는 이름·색이 아니라 resolution hook을 가진 데이터다.

```json
{
  "schema_version": 1,
  "id": "st_audited",
  "display_name": "감사 보류",
  "stack_policy": "stack",
  "max_stacks": 3,
  "duration": {"kind": "turns", "turns": 3},
  "tick": {
    "interval_turns": 1,
    "operations": [{"op": "resource_delta", "resource": "hp", "formula": "pct_max_hp_3"}],
    "tick_on_apply": true
  },
  "modifiers": {
    "stat_deltas": {"agility": -1, "max_hp": -5},
    "traits_added": [],
    "traits_removed": []
  },
  "control": {
    "blocked_action_categories": ["magic"],
    "blocks_no_turn_actions": false,
    "prevents_guard": false,
    "prevents_dodge": false,
    "prevents_charge_commit": false
  },
  "cure": {
    "categories": ["ledger", "mind"],
    "removable_by_action_categories": ["item", "skill"],
    "removable_by_equipment_ids": [],
    "cures_other_status_ids": []
  },
  "resistance": {
    "incoming_status_ids": ["st_ink_bloom"],
    "immune_status_ids": [],
    "break_shatter": false
  },
  "presentation": {"icon_key": "st_audited", "tint_key": "contam_amber", "band_order": 3},
  "seed_ids": ["seed_s056"]
}
```

허용 key: 11개. `tick.operations`의 op은 §4.3의 **부분집합** `resource_delta`, `apply_status`만 허용한다.

검증:

- `stack_policy` enum: `none`, `refresh`, `stack`, `max_intensity`, `independent`. `none`/`refresh`이면 `max_stacks`는 1이어야 한다.
- `duration.kind` enum: `turns`, `encounter`, `region`, `permanent`. `kind == "turns"`이면 `turns` 필수(1..30), `kind == "permanent"`이면 `turns`가 없어야 한다.
- `duration.turns`는 **actor schedule window 수**다(`01` §12.3). tick 횟수가 아니다.
- `tick.operations` op 키 집합: `resource_delta`는 `resource` + `formula`, `apply_status`는 `target` + `status_id` + `stacks`. 다른 op은 `status_tick_op_not_allowed`.
- `resource_delta.resource`는 §2.7의 3개 key다. `ap`가 나오면 `resource_key_forbidden`.
- `modifiers.stat_deltas` key는 §5.5 `STAT_KEYS` 9개로 닫힌다: `agility`, `max_hp`, `max_mp`, `hit`, `evasion`, `critical`, `critical_avoidance`, `guard_efficiency`, `break_damage`. value int -9999..9999. **`max_ap`는 없다** → `resource_key_forbidden`. 새 stat 축은 §12.3의 schema bump 절차다.
- `cure.categories`는 **최소 1개**. 비면 `status_without_cure_class` error. BS2의 selective cure/dispel은 core 문법이고 영구히 못 치료되는 status는 content 버그다.
- `cure.categories` 값은 자유 snake_case(3..32자), core enum이 아니다. BS2 §4.5에서 확인된 category(control, DoT, stat, buff, dispel, cure, reflect, counter)도 이 원칙을 따른다.
- `cure.removable_by_equipment_ids`는 `equipment_*`를 참조, 0..4개.
- `resistance.incoming_status_ids` ∩ `immune_status_ids` = ∅ → `status_resistance_conflict`.
- `resistance.break_shatter == true`이면 이 status를 shatter할 경로가 존재해야 한다. Stage 4 `unreachable_break_shatter` warning.
- `presentation.band_order` int 0..7. 중복은 허용하되 Stage 4 `status_band_order_collision` warning. `10_TESTS_AND_ACCEPTANCE.md`의 focus 표시 검수 대상이 된다.
- combat player band에는 **short label, shape, stack count, urgent**만 표시한다(`01` §12.5). 남은 window 수와 내부 timer는 표시하지 않는다. content가 `remaining_turns`를 presentation 필드로 선언하지 않는다 → `content_infers_hud_field`.
- `presentation`에 Color나 path가 있으면 `content_holds_presentation_value`.
- **status 추가가 combat core 수정 없이 가능한지**가 이 Kit의 확장성 검증 항목이다(BS2 §4.5). 새 status는 이 schema의 필드만으로 표현되어야 하고, 새 op이 필요하면 §12.3 예외를 탄다.

#### 5.4.1 magic status 5종 — `12` §8 / `05` §2.2

magic 층이 추가하는 status는 **다섯 개뿐**이고, 다섯 개 모두 `StatusDefinition`의 기존 typed field(`stack_policy`, `max_stacks`, `duration`, `tick`, `modifiers`, `control`, `cure`, `resistance`, `presentation`)로만 표현된다. **새 key도 새 status op도 없다** — `tick.operations`는 §5.4처럼 `resource_delta`와 `apply_status` 둘뿐이다.

| `st_*` ID | 의미 | `stack_policy` / `max_stacks` | `cure.categories` 최소 | 반드시 만족할 조건 |
|---|---|---|---|---|
| `st_concentration_load` | committed craft output이 아직 몸에 남아 있다. 축적 압력 | `stack` / 1..3 | `load`, `dispersal` | `modifiers.stat_deltas`가 **비어야 한다** |
| `st_medium_residue` | 실패하거나 shape가 어긋난 craft를 handling한 기록. 전염 아님 | `stack` / 1..3 | `residue`, `cleanup` | `resistance.incoming_status_ids`에 `st_contamination`이 없어야 한다 |
| `st_misfolded` | authored `shape_or_pattern`에 맞지 않아 한 번 실패한 committed craft | `none` / 1 | `shape`, `record` | `display_name`에 이론 이름이 없어야 한다 |
| `st_overflowed` | `body_load`가 authored threshold를 한 번 넘었다 | `none` / 1 | `load`, `triage` | `control.blocked_action_categories`에 **`magic`**이 있어야 한다 |
| `st_contract_bound` | portal contract의 deferred obligation이 붙었다 | `none` / 1 | `contract`, `proof` | `tick.operations`가 **비어야 한다** |

강제 규칙:

- **catalog 전체에 위 5개가 모두 존재해야 한다** → Stage 4 `magic_status_missing` error(`12` §10 content floor, `05` §2.2). 하나라도 없으면 `FAM-ARPG-19`/`ENC-ARPG-25`가 표현 불가능하다.
- `st_concentration_load`·`st_medium_residue`의 `modifiers.stat_deltas`가 비어 있지 않으면 `magic_status_is_damage_multiplier` error. 이 둘은 축적/기록 압력이지 damage 배율이 아니다(`05` §2.2).
- `st_overflowed`의 `control.blocked_action_categories`에 `magic`이 없으면 `overflowed_without_magic_lock` error. 반대로 `magic` 이외 category를 이 status가 block하면 `overflowed_blocks_outside_magic` error — `magic` category 안의 command window만 제거한다.
- `st_contract_bound.tick.operations`가 비어 있지 않으면 `contract_bound_ticks_down` error. obligation은 스스로 내려가지 않는다(`05` §2.8.1: "auto-resolve a contract, tick an obligation down, or spend it as combat cost" 금지).
- `st_medium_residue`와 `st_contamination`은 **같은 transfer rule을 공유하지 않는다.** `st_contamination`의 전염 규칙을 `st_medium_residue`에 재사용하면 둘을 구별할 수 없게 되므로 `residue_reuses_contamination_rule` error.
- 위 5개 중 어떤 것도 `resistance.break_shatter: true`가 될 수 없다 → `magic_status_break_shatter` error. `st_overflowed`·`st_contract_bound`는 기록/차단 상태이지 break 대상이 아니다.
- `presentation.icon_key`/`tint_key`는 `09`의 manifest에 등록돼야 한다(§2.8). magic status가 특별한 색 규칙을 갖지 않는다.

### 5.5 `actions` — ActionDefinition

BS2 §7.2/§8.2. **charge/break가 hard-coded pair가 아니다**를 schema가 강제한다. `01`이 combat 실행 의미의 owner이고, 이 절은 content가 담는 필드 모양을 고정한다.

```json
{
  "schema_version": 1,
  "id": "act_audit_charge",
  "display_name": "감사 청구",
  "order": 20,
  "owner": "enemy",
  "category": "unique",
  "defense_mode": "none",
  "lifecycle": "charge",
  "intent": {"target_mode": "ONE_ENEMY", "requires_target_cursor": true, "target_eligibility": "living"},
  "cost": {"turn_cost": 1, "action_slot_cost": 1, "resource_costs": {"mp": 12}, "cooldown_windows": 0},
  "precondition": {
    "condition": {"axis_at_least": {"axis": "recognition_drift", "value": 2}},
    "blocker_status_ids": [],
    "required_phase_ids": ["phase_audit_ox_second_hearing"]
  },
  "telegraph": {"channels": ["pose", "vfx"], "windows_before_active": 1, "tell_key": "tell_audit_charge"},
  "commitment": {"spans_windows": 2, "interruptible": true, "interrupt_effect_ids": ["eff_audit_charge_broken"]},
  "damage_payload": {"delivery": "physical", "shape": "percent_max_hp", "base_value": 28, "affinity": "light", "hit_policy": "guaranteed", "hit_modifier": 0, "evasion_policy": "roll", "critical_policy": "never", "dodge_pressure": 10, "guard_ignore": true, "breaks_guard": true, "break_damage": 40, "dodgeable": true, "break_damage_kinds": ["hp_damage"], "self_damage": 0, "lifesteal": 0, "reflect": 0, "on_hit_payload_ids": [], "on_evade_payload_ids": []},
  "status_payloads": [{"status_id": "st_ink_bloom", "chance_permille": 1000, "target": "target"}],
  "break_spec": {"stacks": 1, "status_ids": ["st_charge_lock"], "effect_ids": ["eff_audit_charge_broken"], "requires_target_breakable": true, "cancels_charge": true},
  "reactions": {"valid_reaction_ids": ["act_audit_counter_sever"], "forbidden_response_ids": ["act_audit_counter_brace"]},
  "recovery": {"windows": 1, "punish_windows": 1, "recovery_locked": false},
  "counters": {
    "valid": ["break", "raw_survive", "status_counter"],
    "forbidden": ["guard", "dodge"],
    "breakable": true
  },
  "hooks": {"on_charge": [], "on_active": [], "on_hit": [], "on_evade": [], "on_break": ["eff_audit_charge_broken"], "on_recovery_end": [], "on_actor_death": ["eff_audit_ox_defeated"]},
  "presentation": {"icon_key": "act_audit_charge", "arena_key": "arena_r4_observation_hall"},
  "seed_ids": ["seed_s056"]
}
```

허용 key **23개**: `schema_version`, `id`, `display_name`, `order`, `owner`, `category`, `defense_mode`, `lifecycle`, `intent`, `cost`, `precondition`, `telegraph`, `commitment`, `damage_payload`, `status_payloads`, `break_spec`, `reactions`, `recovery`, `counters`, `hooks`, `presentation`, `craft`, `seed_ids`, `audit_note`. 이 목록이 단일 source이고 `TopDownValidateAction.ALLOWED_KEYS`가 여기서 직접 옮긴다. `§14.1`의 drift 검사가 이 목록과 실제 코드를 양방향 대조한다. `craft`는 §5.5.7의 **optional** sub-record이며 magic action에만 쓴다.

#### 5.5.1 `category`와 `defense_mode` 분리 결정

A~H에서 직접 확인된 command list는 Attack / Skill·Magic / Defend / Item / Escape / Equipment다. `dodge`는 top-level command row가 아니라 defend 안의 선택지로 캡처되지 않았고, 실제 화면 증거가 없다. 기억으로 채우지 않는다. 따라서:

- `category` enum: `attack`, `skill`, `magic`, `defend`, `item`, `escape`, `equipment`, `unique`, `noncombat`. (`01` §6.5의 `enemy`/`summon`/`service`는 `owner`가 구분하는 값이므로 `category`에 넣지 않는다. `owner == "enemy"`인 action이 `category: "attack"`일 수 있다.)
- `defense_mode` enum: `none`, `guard`, `dodge`, `break_attempt`. `category != "defend"`이면 `defense_mode`는 `none`이어야 한다.
- `dodge`와 `break`는 **command가 아니라 counter 축**이다. `break`를 건다는 것은 `break_spec`가 적을 대상에게 적용된다는 뜻이고, `defense_mode: "break_attempt"`는 그 `break_spec`를 가진 action을 고르는 것이다.
- `defense_mode: "dodge"`인 action의 실제 UI 위치와 기본 선택은 A~H에 없다. `10_TESTS_AND_ACCEPTANCE.md`가 targeted capture를 요구할 항목으로 등록한다. 그 전까지 `dodge`는 `category: "defend"`에만 존재할 수 있고, dodge UI의 row 위치는 `09`가 정한다. **여기서 결정하지 않는다.** 선택지를 agent에게 남기지 않고 "증거가 없으면 evidence request로 간다"를 문서화한 것이다.

#### 5.5.2 target mode — `01` §7.1의 6개로 닫힘

`intent.target_mode` enum은 **정확히 6개**다. 대소문자도 `01`과 같다.

| target mode | 대상 | target selection |
|---|---|---|
| `SELF` | 자신 | selection 없음 |
| `ONE_ENEMY` | living enemy 하나 | stable target focus |
| `ONE_ALLY` | 같은 side의 living actor 하나 | stable target focus |
| `ALL_ENEMIES` | 현재 유효한 enemy 전체 | selection 없음 |
| `ALL_ALLIES` | 현재 유효한 same-side actor 전체 | selection 없음 |
| `RANDOM_ENEMY` | 현재 유효한 enemy 중 하나 | selection 없음, resolution RNG |

- `positionless`, `single_enemy`, `all_enemies`, `random_enemy`, `single_ally`, `all_allies` 같은 소문자/변형 token은 전부 `target_mode_outside_canonical_enum` error다(`10`의 `test_target_modes_accept_only_closed_enum`).
- `intent.target_eligibility` enum: `living`, `alive_or_fallen`, `fallen_ally`, `any`. `SELF`/`ALL_*`는 `living`이어야 한다 → `target_eligibility_mismatch`.
- `target_mode == "SELF"`이면 `requires_target_cursor`는 `false` 필수 → `cursor_without_target`. 그 외 5개이면 `true` 필수 → `target_without_cursor`.
- **`linked_actor`는 target mode가 아니다.** actor roster의 linked-death / target-priority role이다. `enemy_*.linked_actors[].role`과 `encounter.target_priority[].role`에 있는 값이다(§5.16, §5.17). `act_*.intent.target_mode == "linked_actor"` → `target_role_used_as_target_mode` error.
- **`record`, `route`, `resource_node`도 target mode가 아니다.** encounter-level target role이다(§5.17 `target_roles`). action에 쓰면 `target_role_used_as_target_mode` error.
- target mode는 physical adjacency, distance, facing, grid position을 읽지 않는다(`01` §7.1). content는 그런 조건을 `precondition.condition`에 쓰지 않는다 → `position_rule_in_condition` error.

#### 5.5.3 `turn_cost` — 정수 `0..5`

`cost.turn_cost`는 **enum이 아니라 정수**이며 범위는 `0..5`다. `full`/`none`/`partial` 같은 문자열 token을 받지 않는다 → `turn_cost_not_integer` error.

**`01` 확인 필요 — 해결됨.** `01` §8.4는 `0` / `1` / `2..5`의 3단계 의미와 정수 상한 5를 명시한다. `PLAN_RESOLUTION` §3과 `10`의 `test_turn_cost_is_bounded_integer_with_three_semantics`가 같은 범위를 검증한다.

| 값 | 의미 | action slot | scheduler |
|---:|---|---|---|
| `0` | no-turn action. action pool에 들어가지 않고 현재 command selection에서 즉시 resolve | 소비하지 않음 | 영향 없음 |
| `1` | normal command. actor schedule을 한 단계 진행 | 1개 | progress 1 |
| `2`–`5` | committed/long action. 그 command window의 **유일한** normal command여야 하며 그 window에서 `action_slots = 1`로 고정 | 1개 | locked window + 추가 scheduler cost |

검증:

- `turn_cost` int 0..5. 음수·비정수·6 이상 → `turn_cost_out_of_range`.
- `turn_cost == 0`이면 `cost.action_slot_cost`는 없어야 한다(또는 0) → `slot_cost_on_no_turn`. `01` §8.3대로 slot을 소비하지 않는다.
- `turn_cost >= 2`이면 `cost.action_slot_cost`는 1이어야 한다 → `committed_slot_cost_mismatch`.
- `turn_cost >= 2`이면 `lifecycle`는 `instant`/`committed`여야 하고, `commitment.spans_windows`가 있어야 한다 → `committed_without_commitment`.
- `lifecycle == "charge"`이면 `turn_cost >= 1` **그리고** `telegraph.channels`가 최소 2개여야 한다 → `charge_without_tell` / `charge_single_tell_channel`. `01` §11.3의 "색 변화만으로는 tell을 만들지 않는다"를 data에서 강제한다.
  - `lifecycle == "committed"`이면 `turn_cost >= 2` 필수 → `committed_turn_cost_too_low`(`01` §6.5 `lifecycle`, §8.4 `turn_cost` 의미).
- `lifecycle == "instant"`이면 `turn_cost >= 0` (항상 성립)이고 `commitment`가 없어야 한다 → `commitment_on_instant`.
- `lifecycle == "charge"`인 action은 시작할 때 resource/turn cost를 **한 번만** 소비한다. strike와 recovery는 `ChargeState.stage_costs[]`가 소유하므로 그 action에 `turn_cost: 0` + 빈 resource cost를 준다 → `charge_stage_recharges` warning(§5.5.6).
- `cost.cooldown_windows` int 0..99. **turn이 아니라 actor schedule window 단위**다.
- `cost.resource_costs`는 §2.7의 3개 key만, value int 0..9999, 음수 금지 → `negative_cost`.

#### 5.5.4 나머지 axis 검증

- `owner` enum: `player`, `enemy`, `linked_actor`, `npc`. `01` §6.5의 `summon`은 `owner: "linked_actor"`에 해당한다.
- `order` int 0..99. action list 정렬은 `(category order → order → stable action ID)`이며 이름 알파벳으로 정렬하지 않는다.
- `commitment.spans_windows` int 1..5. `spans_windows >= 2`인데 `telegraph.windows_before_active < 1`이면 `charge_without_tell` error.
- `telegraph.channels`는 `pose`, `vfx`, `sound`, `numeric_bar`, `field_prop`의 부분집합, **최소 1개**(`lifecycle == "charge"`면 최소 2개). 비면 `action_without_telegraph` error.
- `telegraph.windows_before_active` int 0..5.
- `counters.valid` **최소 1개** → `action_without_counter` error.
- `counters.valid` ∩ `counters.forbidden` = ∅ → `counter_conflict`.
- `counters.breakable == true`이면 `"break"`이 `valid`에 있어야 한다 → `break_policy_inconsistent`.
- `counters.breakable == false`이면 `"break"`이 `forbidden`에 있어야 한다 → `break_policy_inconsistent`.
- `counters.breakable == false`이고 `valid`에 `break` 외가 하나도 없으면 `unbreakable_without_alternative` error. 최소 하나는 남겨야 charge를 맞을 방법이 생긴다.
- `counters` token은 `guard`, `dodge`, `break`, `resource_lock`, `status_counter`, `scripted_counter`, `escape`, `raw_survive`, `noncombat`, `phase_advance` 10개로 닫힌다.
- `break_spec.requires_target_breakable == true`인데 대상의 `enemy_*.break_profile.breakable`이 false면 이 payload는 no-op이다 → Stage 4 `break_payload_on_unbreakable` warning.
- `break_spec.effect_ids`가 **비어 있으면 안 된다** → `break_spec_without_effect`. break는 시각적으로도 규칙적으로도 존재해야 한다. `hooks.on_break`는 `break_spec.effect_ids`를 포함해야 한다 → `break_hook_unwired` error.
- `break_spec.cancels_charge`는 `lifecycle == "charge"`일 때만 의미가 있다. `lifecycle != "charge"`인데 `true`면 `charge_cancel_on_non_charge` error.
- `precondition.required_phase_ids`는 `phase_*`를 참조하고 **같은 owner 안에서만** 허용 → Stage 3 `phase_owner_mismatch`.
- `status_payloads[].target` enum: `self`, `target`. `target == "self"`이면 `self` 대상 항목이 두 번 이상 있으면 `duplicate_self_status`.
- `status_payloads[].chance_permille` int 0..1000.
- `damage_payload.self_damage` int 0..9999. `base_value == 0`인데 `self_damage == 0`이면서 `lifesteal == 0`이 아니면 `self_damage_without_cost`는 발화하지 않는다(반대 규칙은 §4.4.1에 있다).
- `recovery.recovery_locked == true`이면 `punish_windows == 0` → `punish_window_on_locked_recovery` error.
- `reactions.valid_reaction_ids` ∩ `forbidden_response_ids` = ∅ → `counter_conflict`. 두 배열이 **둘 다 비어 있으면** `reaction_unwired` error: charge/strike는 최소한 `Receive` 외의 반응 경로를 가져야 하고, 그 경로는 `01` §11.4의 counter family(`evade`, `mitigate`, `break`, `consume_resource`, `authored_scripted`) 중 하나로 표현된다.
- `act_*.seed_ids`에는 ungrounded rule을 적용하지 않는다(§12.3). 대신 `seed_ids`의 각 id는 해석돼야 한다.

#### 5.5.5 resolution hook — 순서는 core 소유

`hooks`는 `01` §9.3의 **17단계 순서를 재배열하지 않는다.** content는 각 hook에 붙는 `eff_*` ID만 준다.

| hook | `01` §9.3 위치 | 발화 조건 |
|---|---:|---|
| (pre-action) | 1–3 | target/actor liveness, resource 예약, pre-action status modifier. content hook 없음 |
| `on_charge` | 4 | charge/scripted counter 진입 |
| `on_active` | 5 | action commitment 및 hit policy |
| `on_hit` | 7, 10, 13 | hit 확정. `damage_payload.on_hit_payload_ids`와 같은 단계 |
| `on_evade` | 6 | dodge roll 성공. `damage_payload.on_evade_payload_ids`와 같은 단계 |
| (target death) | 11 | damage로 죽으면 status payload와 on-hit effect를 적용하지 않는다(`01` §9.3) |
| `on_break` | 13 | break 성공 |
| `on_recovery_end` | 15 | charge recovery 종료 |
| `on_actor_death` | 14 | owner actor 사망 처리 |

- `hooks`의 허용 key는 위 7개로 닫힌다. 새 hook 이름은 `01` §9.3 순서가 바뀌어야 하므로 §12.3 예외 절차 대상이다 → `unknown_hook` error.
- `on_hit`과 `damage_payload.on_hit_payload_ids`가 **같은 effect ID를 중복 선언**하면 두 번 발화한다. 둘 중 한 곳에 둔다 → `hook_double_registration` error. 이 문서는 `damage_payload` 쪽을 canonical으로 하고 `hooks.on_hit`는 **다른 성격**(예: relationship/clock) 의 effect만 허용한다. 같은 `eff_*`가 양쪽에 있으면 error다.
- `hooks`는 전투 **결과 확정 이후** world effect를 건드릴 수 없다. `on_actor_death`에 `queue_encounter`나 `queue_recovery` op이 있는 effect는 `effect_in_combat_hook` error.

#### 5.5.6 charge stage 비용 규칙

`lifecycle == "charge"`인 action은 `strike_action_id`와 recovery를 별도 `act_*`로 쓴다면 그 둘은 `turn_cost: 0`, `resource_costs: {}`, `category: "unique"`, `owner`가 원본과 같아야 한다. scheduler 비용은 `stage_costs[]`가 소유한다(§5.5.3). content는 `act_*.stages[]` 인라인 sub-record로 stage별 `window_cost` int 1..9를 준다.

| stage | 순서 | `window_cost` 범위 |
|---|---:|---|
| `telegraph` | 1 | 1..9 |
| `reaction` | 2 (enemy-owned만) | 1..9 |
| `strike` | 3 | 1..9 |
| `recovery` | 4 | 1..9 |

- `window_cost == 0` → `charge_stage_zero_cost` error. `01` §11.2-10이 0을 금지한다.
- `lifecycle != "charge"`인데 `stages`가 있으면 `charge_stages_on_non_charge` error.
- `owner == "player"`인 charge에는 `reaction` stage가 없어야 한다 → `player_charge_reaction_stage` error(`01` §11.1).

#### 5.5.7 `act_*.craft` — concentration-mediated craft의 data 모양

`12` §7의 `MagicActionDefinition`을 이 schema로 옮긴 것이다. **`ActionDefinition`의 새 category·target mode·lifecycle·turn_cost 범위를 열지 않는다**(`05` §2.8.1). `category: "magic"` 슬롯에 record를 더할 뿐이고, combat 실행 의미는 `01`이 소유한다.

`12` §7의 `MagicActionDefinition` field → `06` §5.5 field 매핑:

| `12` §7 field | `06` landing | 비고 |
|---|---|---|
| `craft_family` | `act_*.craft.craft_family` | closed 3 |
| `concentration_requirement` | `act_*.craft.concentration_requirement` | int 0..1000 permille |
| `body_profile_requirements` | `act_*.craft.body_profile_requirements` | `mana_profile` closed 8의 부분집합 |
| `medium_options` | `act_*.craft.medium_options` | `res_*` ID |
| `tool_options` | `act_*.craft.tool_options` | 자유 snake_case, 코드 enum 아님 |
| `shape_or_pattern` | `act_*.craft.shape_or_pattern` + `fold_count_budget` | authored geometric grammar |
| `preparation_turns` | `act_*.craft.preparation_turns` | int 0..5 |
| `turn_cost` | `act_*.cost.turn_cost` | `01` §8.4의 정수 `0..5`, 새 범위 아님 |
| `output_action` | `act_*.damage_payload` / `status_payloads` | 새 field 없음 |
| `waste` | `act_*.craft.waste` | `res_*` 소모 + `st_*` 잔류 |
| `failure_status` | `act_*.craft.failure_status_id` | magic status 5종 |
| `environment_effect` | `act_*.craft.environment_effect` | **clock write는 정확히 하나** |
| `social_recording` | `act_*.craft.social_recording` | `res_*` 1개 또는 none |
| `contract_ref` | `act_*.craft.contract_ref` | portal obligation id |

`12` §2.1의 `concentration_source`와 `12` §2.2의 `mana_profile`은 **`12`가 `MagicActionDefinition`에 넣지 않은 항목**이고, 이 문서가 `12`의 canonical name을 그대로 옮겨 붙인다. 새 이름이 아니다.

```json
{
  "craft_family": "rigid_fold",
  "concentration_source": "field",
  "concentration_requirement": 420,
  "body_profile_requirements": ["retention_balanced", "medium_reactive"],
  "medium_options": ["res_fold_sheet"],
  "tool_options": ["bone_rule", "curved_awl"],
  "shape_or_pattern": "closed_lantern_fold",
  "fold_count_budget": 7,
  "preparation_turns": 2,
  "waste": {"resource_costs": {"res_fold_sheet": 1}, "status_ids": ["st_medium_residue"]},
  "failure_status_id": "st_misfolded",
  "environment_effect": {"clock_id": "clock_resource_collapse", "ticks": 1, "field_level_delta_permille": -40},
  "social_recording": {"resource_id": "res_craft_credit", "amount": 1, "access": "open"}
}
```

(portal obligation이 없는 action이므로 `contract_ref`는 §2.4에 따라 **key 자체가 없다.** `contract_ref`가 있는 예는 `craft_family: "void_cut"` + `social_recording.resource_id: "res_contract_tally"` + `access: "debt_bearing"` + `amount` 없음이다.)

`craft` 허용 key **14개**: `craft_family`, `concentration_source`, `concentration_requirement`, `body_profile_requirements`, `medium_options`, `tool_options`, `shape_or_pattern`, `fold_count_budget`, `preparation_turns`, `waste`, `failure_status_id`, `environment_effect`, `social_recording`, `contract_ref`.

검증:

- `craft`가 있으면 `category`는 **`magic`**이어야 한다 → `craft_on_non_magic_action` error. `category: "magic"`인데 `craft`가 없어도 error는 아니다 — `05` §2.8.1이 허용하는 non-craft magic action(분산/reading 계열)이 있기 때문이다.
- `craft_family` enum **3개로 닫힘**: `weave`(weave/scroll craft), `rigid_fold`(rigid-fold craft), `void_cut`(void-cut/portal craft). `12` §3의 세 craft family가 전부다. `spell`·`sorcery`·`ritual` 같은 새 이름을 쓰면 `craft_family_outside_canonical_enum` error.
- `concentration_source` enum **3개로 닫힘**: `field`(환경 농도장), `body_load`(신체 축적), `social_permission`(사회적 허가). `12` §2.1이 나열한 네 출처 중 player stat은 `body_load`에 흡수된다. **전역 `concentration` 값이 아니다** → `global_concentration_forbidden` error.
- `concentration_requirement` int 0..1000 permille. `safe_band_permille`(§5.10.1의 region 값)보다 크면 `cast_without_field_threshold` error — 농도 임계치를 넘는 action은 저절로 가능해지지 않는다(`12` §2.1, `02` §4.4).
- `craft_family == "weave"` 또는 `"rigid_fold"`이면 `medium_options`가 **비어 있으면 안 된다** → `cast_without_medium` error. `12` §2.1: "medium이 없으면 cast는 성립하지 않는다."
- `craft_family == "void_cut"`이면 `medium_options`는 비어도 되지만 `tool_options`가 비어 있으면 안 된다 → `void_cut_without_tool` error. `12` §3.3/§2.2, `S160`: 가위/칼날의 물리 구조가 비용과 안정성을 결정한다.
- `craft_family == "rigid_fold"`이면 `fold_count_budget` int 1..99가 **필수** → `rigid_fold_without_fold_budget`. 그 외 family에 있으면 → `fold_budget_on_non_fold` error. `12` §3.2: 종이접기 계열은 3차원 구현이 어려워 weave보다 complexity/cost가 높다.
- `body_profile_requirements`는 `mana_profile` closed 8의 부분집합(0..8, 파일 내 유일). 빈 배열은 허용한다(모든 body가 쓸 수 있는 action).
- `medium_options[]`의 각 ID는 §6.3의 `res_*` registry에 있어야 한다 → `unknown_field_resource_key` error. combat resource(`mp` 등)를 넣으면 `combat_resource_in_field_namespace` error.
- `tool_options`는 자유 snake_case 1..48자, 0..4개. **코드 enum이 아니다** — 새 도구를 코드 수정 없이 추가할 수 있는 유일한 지점이다.
- `shape_or_pattern`은 자유 snake_case 3..48자, 파일 내 유일하지 않아도 된다(같은 shape가 여러 action에서 쓰인다).
- `preparation_turns` int 0..5. **준비 action과 실행 action은 서로 다른 authored action이다**(`12` §7). `preparation_turns >= 1`인 action은 `lifecycle: "instant"`/`"committed"` 중 어느 것도 될 수 있지만 그 output은 `world.magic.crafts`에 남고, `preparation_turns == 0`인 action은 이미 준비된 craft가 없으면 resolve할 수 없다 → Stage 3 `cast_without_prepared_craft` error. **이 준비/즉흥 분리는 `12` §11이 요구하는 "같은 action schema, 다른 cost/state"다.**
- `waste.resource_costs` key는 §6.3의 `res_*`만, value int 0..99. `waste.status_ids`는 `st_*` 0..4개. `craft.waste`는 실행에 **선행**하는 declared cost가 아니라 **잔류**다 — `cost.resource_costs`와 섞지 않는다 → `waste_on_cost_field` error.
- `failure_status_id`는 §5.4.1의 magic status 5종 중 하나여야 한다 → `craft_failure_status_not_magic` error. `st_misfolded`/`st_overflowed`/`st_concentration_load` 중 하나가 아니면 magic 실패가 표현되지 않는다(`12` §8).
- `environment_effect`는 **필수**이고 그 안의 `clock_id`는 §3.5.4의 6개 중 **정확히 하나**여야 한다 → `craft_without_clock_write` / `clock_not_canonical` error. `02` §4.4와 `05` §2.8.5가 "한 write가 두 clock을 한 번에 전진시키지 않음"을 강제하므로, 부수 clock write는 `hooks`/`eff_*`의 **별도 effect**로 표현한다.
- `environment_effect.ticks` int 1..9. `field_level_delta_permille` int -1000..1000 — `concentration_field`는 축도 clock도 아니고 **node 단위 측정값**이므로, 이 delta는 `world.magic.circulation`/`concentration_fields`에 적용되는 값이다. 0이면 키를 생략한다(§2.4).
- `social_recording.resource_id`는 §6.4의 **기록 가능 3종**(`res_craft_credit`, `res_lineage_token`, `res_contract_tally`) 중 하나여야 한다 → `craft_record_target_forbidden` error. `05` §2.8.2: "craft가 세 가지 중 하나로 기록되며, resolution마다 정확히 하나가 쓰이고 그 선택이 story content다."
- `social_recording.resource_id == "res_contract_tally"`이면 `access`는 **`debt_bearing`**이어야 하고 `amount`는 없어야 한다 → `contract_tally_quantified` error. `res_craft_credit`/`res_lineage_token`이면 `amount` int 0..99 필수.
- `contract_ref`는 자유 snake_case 3..48자. 있으면 `social_recording.resource_id == "res_contract_tally"`여야 한다 → `contract_ref_without_tally` error. `null`은 §2.4에 따라 key를 생략한다.
- **theory label 금지**: `craft`가 있는 action의 `display_name`·`tool_options`·`shape_or_pattern`·`social_recording` 어디에도 magic 이론의 positive 이름이 들어갈 수 없다 → `untranslated_theory_label` error. `12` §10과 `02` §13의 "이름은 `R4` glossary가 Filing한 뒤에만 기록한다"를 data에서 강제한다. `display_name`은 **기관의 물리적 표면**(예: "차단 재단")을 이름으로 쓰고 이론 이름을 쓰지 않는다(`05` §2.8.3).
- `craft`가 있는 action은 `damage_payload.delivery == "magical"`이어야 한다 → `craft_payload_not_magical` error. craft는 물리적 delivery일 수 없다.
- magic action은 combat resource와 `res_*`를 **동시에** cost로 내지 않는다 → `craft_mixes_resource_namespaces` error. 하나만 고른다.

### 5.6 `clocks` — ClockDefinition

constitution §5. R07(하나의 global danger bar 금지)의 강제 지점이다. **clock은 6개 고정**이고 stage vocabulary는 `02`가 소유한다.

```json
{
  "schema_version": 1,
  "id": "clock_public_record",
  "kind": "public_record",
  "scope": "region",
  "owner_region_id": "region_r4_crownwell_archive",
  "start_condition": {"clock_at_least": {"clock_id": "clock_contamination", "stage_index": 1}},
  "start_state": "active",
  "period": {"unit": "clock_tick", "per": 1},
  "stages": [
    {
      "stage_id": "circulating",
      "index": 0,
      "label": "비공식 유통",
      "advance": {"ticks": 3},
      "visible_signal": {"channel": "npc_warning", "npc_id": "npc_10_juno_caster", "text": "같은 사건이 두 문서로 돌아온다."},
      "intervention": {"encounter_id": null, "effect_ids": []},
      "irreversible": false,
      "reversal": {"allowed": true, "requires_condition": {"prop_state_is": {"prop_id": "prop_r4_low_level_stacks", "state_id": "ps_intact"}}, "effect_ids": ["eff_r4_document_read"]}
    },
    {
      "stage_id": "filed",
      "index": 1,
      "label": "canonical record 확정",
      "advance": {"ticks": 4},
      "visible_signal": {"channel": "document", "document_id": "doc_r4_contradictory_translation"},
      "intervention": {"encounter_id": "enc_r4_translation_drift", "effect_ids": ["eff_ilyra_files_contradictory_copy"]},
      "irreversible": true,
      "reversal": {"allowed": false, "requires_condition": {}, "effect_ids": []}
    }
  ],
  "pressure_policy": {"advance_on_player_action": false, "advance_on_region_enter": true, "advance_on_encounter_window": true, "decay_when_untouched": 0},
  "seed_ids": ["seed_s056"]
}
```

허용 key: `schema_version`, `id`, `kind`, `scope`, `owner_region_id`, `owner_npc_id`, `start_condition`, `start_state`, `period`, `stages`, `pressure_policy`, `never_advances`, `seed_ids`, `audit_note` 14개. `owner_npc_id`가 `scope == "character"`일 때만 사용한다.

검증:

- `id`는 §3.5.4의 6개 `clock_*` 중 하나여야 한다 → `clock_not_canonical`.
- `kind` enum은 constitution §5가 정한 **6개로 닫힌다**: `institutional_response`, `contamination`, `public_record`, `resource_collapse`, `personal_collapse`, `crown_alignment`. 여기만 closed enum인 category다. 여기 아니면 R07이 content에 의해 깨진다. `id`와 `kind`의 대응도 1:1이어야 한다 → `clock_kind_id_mismatch`.
- `scope` enum: `region`, `global`, `character`.
- `scope == "character"`이면 `owner_npc_id`가 **필수**(null 불가)이고, 아니면 key가 없어야 한다 → `clock_owner_mismatch`.
- `scope == "region"`이면 `owner_region_id` 필수. `scope == "global"`이면 둘 다 없어야 한다.
- `start_state` enum: `dormant`, `active`, `critical`.
- `period.unit` enum: `encounter_window`, `clock_tick`, `player_action`, `region_enter`. `per` int 1..10.
- `stages`는 1..12개, `index`는 0부터 **연속**(`clock_stage_gap`), `stage_id`는 파일 내 유일(§2.9). 12개 초과는 `clock_stage_too_many` — clock이 HUD처럼 읽히기 시작하는 지점을 여기서 막는다.
- **`stage_id`와 `index`는 `02`가 소유한다.** `02` §4가 각 clock의 시작 stage token을 이미 공개했고, resolution §8은 "각 clock의 stage vocabulary는 `02`가 닫힌 list와 integer mapping을 소유한다"고 명시한다. 따라서:
  - `stages[].stage_id`는 `02` ladder의 token이어야 한다 → `clock_stage_not_in_02_ladder`.
  - `stages[].index`는 `02` ladder의 integer mapping과 **정확히 같아야 한다** → `clock_stage_index_off_02_ladder`.
  - `stages[0].stage_id`는 `02`가 선언한 시작 stage여야 한다 → `clock_start_stage_mismatch`.
  - **`02` §4.1이 6개 clock의 full ladder(stage 0~5, index 매핑)와 irreversible stage(각 clock stage 4)를 publish했다.** `02` §4.2의 region별 시작 stage 표도 확정되어 있다. 따라서 이전의 "ladder 미공개" 결함과 `clock_ladder_unpublished` warning은 **삭제된다.** `stages`는 1..6개여야 하며(§4.1의 6칸), 7개 이상이면 `clock_stage_too_many` error.
  - irreversible stage는 clock마다 stage **4**이고 stage 5가 terminal이다. `stages`에 `irreversible: true`가 정확히 하나 있어야 하고 그 `index`가 4여야 한다 → `clock_irreversible_index_off_02_ladder` error.
  - 어떤 region도 clock을 `index == 5`(terminal)에서 시작하지 않는다 → `clock_start_stage_terminal` error(`02` §4.1).
- 모든 stage에 `visible_signal`이 있고 `channel != "none"`이어야 한다 → `clock_stage_without_signal`. channel enum: `npc_warning`, `document`, `resource_shortage`, `enemy_tell`, `world_event`, `prop_change`. `visible_signal`은 `channel` + 해당 channel의 payload key + (선택) `text`만 가진다. key 집합:

  | channel | 필수 | 금지 |
  |---|---|---|
  | `npc_warning` | `npc_id` | `document_id`, `prop_id` |
  | `document` | `document_id` | `npc_id`, `prop_id` |
  | `prop_change` | `prop_id` | `npc_id`, `document_id` |
  | `resource_shortage` | `text` | `npc_id`, `document_id`, `prop_id` |
  | `enemy_tell` | `text` | `npc_id`, `document_id`, `prop_id` |
  | `world_event` | `text` | `npc_id`, `document_id`, `prop_id` |

  위반은 `visible_signal_key_mismatch`. `text`는 §2.6의 비어 있지 않은 문자열 규칙을 적용한다.
- **적어도 한 stage가 `irreversible: true`** → `clock_without_irreversible_point` error. 그 stage의 `index`는 `02` ladder의 irreversible stage와 같아야 한다.
- **마지막 stage의 `reversal.allowed`은 `false`** → `terminal_stage_reversible` error.
- `pressure_policy`의 세 `advance_on_*`이 전부 false이면 `clock_never_advances` error. `never_advances == true`여도 같은 error.
- `decay_when_untouched` int 0..99.
- **모든 clock은 ≥1개 region의 `clocks[]`에 나타나야 한다** → Stage 4 `orphan_clock` error. `02` §4.2 manifest는 9개 node(H0 + `R1`~`R8`) 모두에 6개 clock을 둔다.
- **catalog 전체의 distinct `kind`가 3개 미만이면** `clock_diversity_insufficient` error. R07이 "서로 다른 속도"를 요구하므로 최소 3개. 이 Kit은 6개가 고정이라 항상 충족한다.
- `seed_ids`/`audit_note`는 §5.3의 ungrounded rule을 적용한다.
- **magic은 제7 clock을 만들지 않는다**(`05` §2.8.1, `02` §4.4). `concentration_field`·`body_load`·`circulation`·`contract debt`는 위 6개 clock의 **입력값**이다. `clock_concentration`, `clock_mana`, `clock_circulation` 같은 7번째 clock ID가 나오면 `clock_not_canonical` error. magic 이벤트의 clock 규칙은 §5.5.7의 `craft.environment_effect`(write 1개)와 `hooks`/`eff_*`의 별도 effect다.

### 5.7 `relationships` — RelationshipStateDefinition

**canonical relationship state는 `states[]` 하나다.** BS2 §6.3: 동료 power는 affinity 합이 아니라 rescue/betrayal/route history를 요약한다. schema가 강제한다.

`04`의 값들은 다음과 같이 배치한다(`PLAN_RESOLUTION` §2):

- `04`의 `trust`/`fear`/`debt`/`recognition`/`attachment` → `rel_*.axes` 5개 (state transition의 **입력/보조 축**)
- `04`의 `agency` → **`rel.axes`에 넣지 않는다.** `npc_state` op의 `state_key`/`acting_role` token과 world 축 write로 landing시킨다. 여섯 번째 key를 여는 것은 Kit 전체 schema bump이므로 하지 않는다.
- `04`의 `stance` → **presentation label**. `state_id`의 alias가 아니고, 저장되지 않고, 조건·gate·precondition으로 쓰이지 않는다. `states[].dialogue_policy`가 canonical presentation 축이다.

```json
{
  "schema_version": 1,
  "id": "rel_01_ilyra_record",
  "target_npc_id": "npc_01_ilyra_senn",
  "channel": "professional",
  "start_state_id": "rs_unmet",
  "states": [
    {"state_id": "rs_unmet", "order": 0, "label": "서로 모름", "entry_effect_ids": [], "exit_effect_ids": [], "port_ids": [], "unlocks_conversation_ids": ["conv_r4_translation_desk"], "companion_power": {"enabled": false, "encounter_modifier": 0, "granted_by_effect_ids": []}, "dialogue_policy": "guarded"},
    {"state_id": "rs_candid", "order": 1, "label": "서류상 신뢰", "entry_effect_ids": ["eff_ilyra_files_contradictory_copy"], "exit_effect_ids": [], "port_ids": ["port_r4_inquiry"], "unlocks_conversation_ids": ["conv_r4_operator_trial"], "companion_power": {"enabled": false, "encounter_modifier": 0, "granted_by_effect_ids": []}, "dialogue_policy": "operational"},
    {"state_id": "rs_indexed", "order": 2, "label": "인정", "entry_effect_ids": ["eff_ilyra_opens_index"], "exit_effect_ids": [], "port_ids": ["port_r4_inquiry", "port_r4_crown_seat"], "unlocks_conversation_ids": [], "companion_power": {"enabled": true, "encounter_modifier": 1, "granted_by_effect_ids": ["eff_ilyra_opens_index"]}, "dialogue_policy": "candid"},
    {"state_id": "rs_archived", "order": 3, "label": "기록으로 처리됨", "entry_effect_ids": ["eff_ilyra_recorded_as_artifact"], "exit_effect_ids": [], "port_ids": [], "unlocks_conversation_ids": [], "companion_power": {"enabled": false, "encounter_modifier": 0, "granted_by_effect_ids": []}, "dialogue_policy": "hostile"},
    {"state_id": "rs_filed_contradictory", "order": 4, "label": "기록이 먼저 굳음", "entry_effect_ids": ["eff_r4_record_sealed"], "exit_effect_ids": [], "port_ids": ["port_r4_inquiry"], "unlocks_conversation_ids": ["conv_r4_translation_desk"], "companion_power": {"enabled": false, "encounter_modifier": 0, "granted_by_effect_ids": []}, "dialogue_policy": "operational"}
  ],
  "transitions": [
    {"transition_id": "t_01", "from_state_id": "rs_unmet", "to_state_id": "rs_candid", "via": "choice", "requires_condition": {"choice_taken": {"conversation_id": "conv_r4_translation_desk", "choice_id": "ch_file_contradictory_copy"}}, "effect_ids": ["eff_ilyra_files_contradictory_copy"], "is_irreversible": false, "priority": 10},
    {"transition_id": "t_02", "from_state_id": "rs_candid", "to_state_id": "rs_indexed", "via": "choice", "requires_condition": {"recovery_done": {"recovery_event_id": "rec_r4_translation_reentry"}}, "effect_ids": ["eff_ilyra_opens_index"], "is_irreversible": true, "priority": 10},
    {"transition_id": "t_03", "from_state_id": "rs_candid", "to_state_id": "rs_archived", "via": "effect", "requires_condition": {"clock_irreversible": {"clock_id": "clock_public_record"}}, "effect_ids": ["eff_ilyra_recorded_as_artifact"], "is_irreversible": true, "priority": 5},
    {"transition_id": "t_04", "from_state_id": "rs_candid", "to_state_id": "rs_filed_contradictory", "via": "effect", "requires_condition": {"prop_state_is": {"prop_id": "prop_r4_low_level_stacks", "state_id": "ps_filed"}}, "effect_ids": ["eff_r4_record_sealed"], "is_irreversible": false, "priority": 8},
    {"transition_id": "t_05", "from_state_id": "rs_filed_contradictory", "to_state_id": "rs_candid", "via": "choice", "requires_condition": {"choice_taken": {"conversation_id": "conv_r4_translation_desk", "choice_id": "ch_reopen_docket"}}, "effect_ids": ["eff_ilyra_reopens_docket"], "is_irreversible": false, "priority": 10}
  ],
  "axes": {"trust": 0, "fear": 0, "debt": 0, "recognition": 0, "attachment": 0},
  "axis_rules": [{"key": "debt_raises_trust_when", "condition": {"choice_taken": {"conversation_id": "conv_r4_translation_desk", "choice_id": "ch_sign_translation"}}, "sets": {"trust": 1}}],
  "exclusions": {"max_final_state": 1, "conflicting_final_state_ids": ["rs_indexed", "rs_archived"]},
  "romance": {"allowed": false, "explicit_content": false, "gate_state_ids": [], "consent_beat_effect_ids": []},
  "seed_ids": ["seed_s046", "seed_s108"]
}
```

검증:

- `channel` enum: `professional`, `personal`, `care`, `confrontation`, `romance`, `kinship`.
- `states` 1..10개, `order`는 0부터 **연속** → `relationship_state_gap`. `state_id` 파일 내 유일.
- `start_state_id`는 `states` 중 하나여야 하고 그 `order == 0`.
- **DAG**: `transitions`에 cycle이 있으면 `relationship_cycle` error. relationship은 되돌릴 수 있지만 되돌림은 **역방향 edge**로 표현한다(`rs_candid` → `rs_unmet`). cycle 금지가 뜻하는 것은 "되돌릴 수 없다"가 아니라 "무한 ping-pong edge가 없다"다. `is_irreversible` flag로 되돌림 불가도 표시한다.
- **sink가 ≥1개**. `exclusions.max_final_state == 1`이면 sink가 **정확히 1개** → `ambiguous_final_state`. 2개 이상이면 "어느 쪽이 final인가"가 content bug다. `max_final_state >= 2`면 sink 2개가 허용된다(BS2 §6.3).
- `start_state_id` 이외의 모든 state에 incoming transition ≥1 → `unreachable_relationship_state` error.
- `transitions[].via` enum: `choice`, `effect`, `encounter_outcome`, `clock_stage`, `recovery`, `absence`.
- `via == "choice"`이면 `requires_condition`에 `choice_taken` leaf가 **반드시** 하나 있고, 그 `conversation_id`가 `rel`의 `target_npc_id`가 등장하는 conversation이어야 한다 → `relationship_choice_not_grounded`.
- `transitions[].priority` int 0..99. 같은 `(from_state_id, priority)`가 두 번이면 `transition_priority_ambiguous` error.
- **`companion_power.enabled == true`인 state는 `granted_by_effect_ids`가 비면 안 된다** → `companion_power_without_history` error. 그리고 그 effect id는 `state.entry_effect_ids`에 포함돼야 한다 → `companion_power_unwired`. 이것이 BS2 §6.3의 강제 지점이다.
- `axes` key는 정확히 5개(`trust`, `fear`, `debt`, `recognition`, `attachment`), value int -3..3 → `axis_out_of_range`. `agency`를 여섯 번째로 넣으면 `relationship_axis_key_unexpected` error.
- **`axes`는 전이 판정 authority가 아니다.** `transitions`가 authority다. `axis_rules[]`는 `key`(자유 snake_case) + `condition` + `sets`(§6.1의 4개 world axis만, int -3..3)로 구성되며, 조건이 참일 때 axis 값을 **설정**한다. axis 값은 presentation과 `axis_at_least` 조건만 소비한다. 이 관계를 테스트가 증명한다: 같은 transition 집합에서 `axes`와 `axis_rules`를 제거해도 모든 relationship 결과가 동일해야 한다(§14.1).
- `axis_rules[].sets`의 `axis`는 `rel.axes`의 5개 key가 아니라 §6.1의 4개 world axis여야 한다 → `relationship_axis_conflated_with_world_axis`.
- `exclusions.conflicting_final_state_ids`는 모두 sink여야 한다.
- `romance.explicit_content`은 `true`일 수 없다 → `explicit_content_forbidden` **error**. project law이며 우회가 없다.
- `romance.allowed == true`이면 `channel == "romance"`인 state가 **도달 가능하게** 존재해야 한다 → `romance_without_state` error.
- `romance.allowed == true`이면 romance state로 들어가는 모든 transition의 `via`가 `choice` 또는 `effect`여야 한다. `clock_stage`, `absence`, `encounter_outcome`으로 강제 진입 불가 → `romance_without_consent_path` error. constitution R12와 seed S118(consent 논쟁)을 구조로 강제한다.
- `romance.allowed == true`이면 `consent_beat_effect_ids`가 비면 안 된다 → `romance_without_consent_beat` error.
- `target_npc_id`는 `npc_*`를 참조하고, `npc.relationship_ids`에 이 `rel` id가 있어야 한다 → Stage 3 `relationship_backlink_missing` (양방향 대칭).
- 전투 동행이 가능한 NPC(`npc.encounter_profile.as_ally.effect_id` 있음)가 `rel`을 하나도 갖지 않으면 Stage 4 `npc_without_relationship` warning.
- `states[].dialogue_policy` enum: `guarded`, `operational`, `candid`, `hostile`, `absent`.
- `rel_*` ID는 §3.5.3의 `rel_<nn>_<snake>` 형태여야 한다 → `relationship_id_shape`.
- `04`의 `stance` token(`unmet`, `wary`, `conditional_trust`, …)이 content에 나타나면 `stance_used_as_canonical_state` error. `rs_unmet`처럼 state_id 안에 같은 단어가 들어가는 것은 허용한다(문자열 일치 판정이 아니라 **토큰 단독 사용**을 금지한다).

### 5.8 `recovery` — RecoveryEventDefinition

constitution R06: recovery 종류는 서로 다른 continuity를 가진다. 이 schema가 그 차이를 저장 가능하게 만든다. **canonical kind는 7개로 닫힌다**(`PLAN_RESOLUTION` §4, §3.5.5).

```json
{
  "schema_version": 1,
  "id": "rec_r4_translation_reentry",
  "display_name": "번역 담당자 재입회",
  "kind": "institutional_reentry",
  "trigger": {"kind": "encounter_failure", "encounter_id": "enc_r4_translation_drift", "condition": {}},
  "preserves": ["region_id", "region_state", "axis_values", "clock_stages", "npc_states", "relationship_states", "prop_states", "conversation_progress", "document_reads", "flags", "effects_fired", "encounter_clear_flags", "route_flags", "inventory", "equipment_slots", "recoveries", "player_vitals"],
  "discards": ["encounter_progress", "current_phase", "linked_actor_state", "combat_transient", "scheduler_cursor", "pending_effect_queue", "presentation_transient"],
  "self_layers_restored": ["body", "memory", "role"],
  "self_layers_not_restored": ["belief", "institution", "desire", "social_recognition"],
  "respawn": {"region_id": "region_r4_crownwell_archive", "prop_id": "prop_r4_crown_observation_desk", "encounter_id": "enc_r4_translation_drift", "reset_prop_ids": ["prop_r4_crown_observation_desk"]},
  "cost": {"continuity_pressure_delta": 1, "resource_costs": {}, "axis_deltas": {"continuity_pressure": 1}, "world_effect_ids": []},
  "entry_effect_ids": ["eff_r4_reentry_entry"],
  "cooldown": {"kind": "per_death", "count": 1},
  "authored_debt": {"debt_id": "d_ilyra_archived", "description": "재입회해도 아카이브 처리된 것은 유지된다.", "resolve_effect_ids": ["eff_ilyra_opens_index"]},
  "seed_ids": ["seed_s031"]
}
```

검증:

- **`kind` enum(7개, 닫힘)**: `checkpoint`, `respawn`, `clone`, `reincarnation`, `loop`, `immortality`, `institutional_reentry`.
  - `08` §7의 표기(`checkpoint_return`, `clone_branch`, `loop_rehearsal`, `immortal_continuation`)를 쓰면 `recovery_kind_token_mismatch`.
  - **`crown_alignment`은 recovery type이 아니다.** global irreversible world write다. `kind: "crown_alignment"` → `recovery_kind_violation` error(`10`의 `test_crown_alignment_is_a_world_write_not_recovery_type`). `crown_alignment`은 `clock_crown_alignment`과 `effect.operations[].set_axis`로 표현한다.
- `trigger.kind` enum: `death`, `encounter_failure`, `phase_complete`, `route_enter`, `scripted`. kind별 필수/금지 key:

  | kind | 필수 | 금지 |
  |---|---|---|
  | `death` | — | `encounter_id`, `gate_id`, `phase_id` |
  | `encounter_failure` | `encounter_id` | `gate_id`, `phase_id` |
  | `phase_complete` | `encounter_id`, `phase_id` | `gate_id` |
  | `route_enter` | `gate_id` | `encounter_id`, `phase_id` |
  | `scripted` | — | `encounter_id`, `gate_id`, `phase_id` |

  위반은 `trigger_key_mismatch`. 금지 key가 있어도 `""`/0이어도 위반이다(§2.4).
- `trigger.condition`은 모든 kind에서 선택이며 `{}`일 수 있다.
- **`preserves` token은 §10.2의 `STATE_TOKEN` 27개와 정확히 같은 집합**으로 닫힌다. `discards` token은 `encounter_progress`, `current_phase`, `linked_actor_state`, `combat_transient`, `scheduler_cursor`, `pending_effect_queue`, `presentation_transient` 7개로 닫힌다. 이 vocabulary 공유는 의도적이다: "recovery가 무엇을 보존하는가"와 "save가 무엇을 담는가"가 어긋나면 안 된다. `envelope`(`state_format`/`save_version`/`run_id`/`content_revision`)은 어느 쪽에도 속하지 않고, `combat`은 §10.4-7에 따라 항상 재구축되므로 `preserves`에 없다.
- `preserves ∩ discards = ∅` → `recovery_contradiction`. `preserves` 최소 1개 → `recovery_preserves_nothing`.
- **`self_layers_restored` ∪ `self_layers_not_restored`은 constitution R04의 7개 층위(`body`, `memory`, `role`, `belief`, `institution`, `desire`, `social_recognition`)의 완전 분할**이어야 한다. 겹치면 `recovery_layer_overlap`, 빠지면 `recovery_layer_gap`. R04("한 층위의 recovery가 다른 층위를 복구하지 않는다")의 data-level 강제다.
- `kind`별 강제(모두 `recovery_kind_violation`):
  - `clone`, `reincarnation` ⇒ `social_recognition`이 `not_restored`에 있어야 한다. (S005/S032)
  - `checkpoint`, `respawn` ⇒ `encounter_progress`가 `discards`에 있어야 한다.
  - `loop` ⇒ `preserves`에 `flags`가 있어야 하고 `cost.continuity_pressure_delta >= 1`. (S034: loop는 지식을 보존하고 책임을 옮긴다)
  - `immortality` ⇒ `cost.continuity_pressure_delta >= 1`. (S008/S035: 죽음 비용이 사라지지 않는다)
  - `institutional_reentry` ⇒ `preserves`에 `npc_states`와 `document_reads`가 있고 `entry_effect_ids`가 비어 있지 않아야 한다. (S011/S115)
  - **magic 실패를 recovery kind로 표현하지 않는다.** `12` §8의 failure 3등급(`recoverable`/`continuity-changing`/`terminal`)과 `02` §10의 분류는 **recovery type이 아니다**(`05` §2.8.1: "treat those three grades as recovery types, or add an eighth recovery type" 금지). `rec_*.kind`는 7개만 쓴다.
  - **`continuity-changing` 실패를 만들 recovery는 `clone`/`reincarnation`/`loop`/`immortality`/`institutional_reentry` 중 하나로 이미 존재한다.** `world.magic` 6종(`concentration_fields`/`body_load`/`circulation`/`crafts`/`contracts`/`glossary`)을 `preserves`에 넣으면 그 recovery가 `body_load`의 injury와 `contracts`의 미해결 obligation을 보존한다는 뜻이 되고, **`02` §10의 "recovery는 `magic` record를 초기화하지 않는다"와 일치한다.** `checkpoint`/`respawn`은 `body_load` injury를 `preserves`에 넣어도 되지만 `crafts`의 소모된 `res_medium_blank`/`res_fold_sheet`는 다시 지급되지 않는다(§6.3).
  - `respawn`, `checkpoint` ⇒ `respawn.encounter_id` 필수.
  - 모든 kind ⇒ `respawn.region_id` 필수.
- `cost.continuity_pressure_delta` int 0..3. `cost.axis_deltas`는 §6.1의 4개 axis만, value int -3..3. `cost.resource_costs`는 §2.7의 3개 key만.
- `cooldown.kind` enum: `once`, `per_death`, `per_route`, `per_encounter`, `gate`. `kind == "once"`이면 `count == 1`. `kind == "gate"`이면 `gate_id` 필수, 그 외에는 없어야 한다 → `cooldown_key_mismatch`.
- `authored_debt`가 있으면 `debt_id` 파일 내 유일, `resolve_effect_ids` 비어 있으면 안 됨. `debt_id`는 region `unresolved_debt[].debt_id`와 **같은 token**이어야 하고 양쪽에서 참조돼야 한다 → Stage 3 `recovery_debt_unlinked`.
- `respawn.reset_prop_ids`의 prop은 `respawn.region_id` region에 속해야 한다 → `recovery_reset_prop_foreign`.
- `seed_ids`/`audit_note` ungrounded rule은 §5.3과 동일.
- `kind == "checkpoint"`이고 `preserves`에 `player_vitals`가 없으면 `checkpoint_without_vitals` warning. §10.4-7이 전투 중간을 resume하지 않으므로, player가 죽은 채 복귀하는 경로가 생길 수 있다.
- `trigger.kind == "death"`이거나 `outcome`을 통해 참조되지 않는 recovery는 Stage 4 `recovery_unreferenced` warning. 죽음 경로는 항상 recovery로 귀결돼야 한다.
- **recovery는 전투 중 상태를 복원하지 않는다.** `respawn`, `preserves`, `discards` 어디에도 combat transient(`scheduler_cursor`, `current_phase`, charge stage, reaction window, queued action)를 넣을 수 없다 → `recovery_restores_combat_transient` error. `08` §9.1이 허용하는 rollback 범위는 "uncommitted encounter-local combat state"까지이고, 그 boundary는 §10.4-7의 pre-command intent + encounter-level checkpoint다.

### 5.9 `props` — PropStateDefinition

USER_PLAY_REFERENCE §6.1 `WorldPropState` + H aftermath. irreversible event가 dialogue flag만 남지 않게 하는 지점이다.

```json
{
  "schema_version": 1,
  "id": "prop_r4_low_level_stacks",
  "display_name": "Low-Level Stacks 원문",
  "region_id": "region_r4_crownwell_archive",
  "placement": {"anchor_key": "r4_low_level_stacks", "layer": "trace", "visible_from": "same_room"},
  "initial_state_id": "ps_intact",
  "states": [
    {"state_id": "ps_intact", "label": "번역되지 않은 층별 원문", "visible": true, "art_key": "prop_r4_stacks_intact", "collides": false, "interactable": false, "entry_effect_ids": []},
    {"state_id": "ps_filed", "label": "한 층이 canonical로 굳음", "visible": true, "art_key": "prop_r4_stacks_filed", "collides": false, "interactable": true, "entry_effect_ids": ["eff_ilyra_files_contradictory_copy"]}
  ],
  "interaction": {"verb_id": "verb_examine_stacks", "availability": {"prop_state_is": {"prop_id": "prop_r4_low_level_stacks", "state_id": "ps_filed"}}, "opens": "doc_r4_contradictory_translation", "return_focus": "prop"},
  "revisit_visible": true,
  "hidden_until_condition": {"not": {"prop_state_is": {"prop_id": "prop_r4_low_level_stacks", "state_id": "ps_intact"}}},
  "seed_ids": ["seed_s060"]
}
```

검증:

- `placement.layer` enum: `floor`, `prop`, `overhead`, `trace`, `wall`, `door`, `water`, `hazard`. `placement.visible_from` enum: `any`, `adjacent`, `same_room`, `interacted`.
- **`placement`에 information importance 값이 없어야 한다.** `importance`/`priority`/`hint` 같은 key가 나오면 `content_infers_art_priority` error. 배경 오브젝트의 정보 중요도(`증거·직접 상호작용` / `길찾기·상황 이해` / `분위기`)는 `docs/IMAGE_ASSET_WORKFLOW.md`에 따라 asset brief가 정한다.
- `states` 1..12개, `state_id` 파일 내 유일, `initial_state_id`가 그중 하나.
- `states[].visible`이 전부 false이면 `prop_never_visible` error.
- `interactable == true`인 state가 있는데 `interaction.availability`가 `{}`면 `prop_interaction_state_invariant` error — 항상 상호작용 가능하면 `interactable` flag가 무의미하다.
- `interaction.availability`가 `{}`이고 모든 state가 `interactable == false`이면 `dead_interaction` error.
- `interaction.opens`는 `conv_*`/`doc_*`/`enc_*` 중 하나를 참조. `interaction.verb_id`는 자유 snake_case이고 `npc.interaction_verbs[].verb_id`와 공유 vocabulary다(코드 enum 아님).
- 두 state가 같은 effect id를 가지면 `prop_state_effect_collision` error(한 번에 두 state로 갈 수 없다).
- `initial_state_id`의 state가 `visible == false`이면 `hidden_until_condition` 필수 → `prop_hidden_without_condition`.
- `revisit_visible == false`인데 `visible == true`인 state가 하나도 없으면 `prop_invisible_on_revisit` error.
- `interaction.return_focus` enum: `prop`, `field`. **`choice`/`conversation`은 §5.13의 `return_focus` enum에 있고, prop에는 없다** → `return_focus_not_in_kind`.

### 5.10 `regions` — RegionDefinition

constitution §6의 region contract를 필드로 펼친다. **region은 9개 고정**이고 `region_role`을 가진다.

```json
{
  "schema_version": 1,
  "id": "region_r4_crownwell_archive",
  "display_name": "Crownwell Archive",
  "region_role": "translation_precedence",
  "conflict_thesis": "기록이 남는 순서가 사람의 순서보다 빠르다.",
  "topology": {"shape": "vertical_archive", "size_class": "large", "landmark_count": 3, "traversal_axis": "elevation", "backtrack_supported": true},
  "entry": {"from_region_id": "region_h0_undersign_exchange", "edge_id": "route_e04_crownwell_ascent", "gate_id": "gate_g0_arrival_declaration", "one_way": false},
  "exits": [
    {"to_region_id": "region_h0_undersign_exchange", "edge_id": "route_e04_crownwell_ascent", "gate_id": "gate_g0_arrival_declaration", "route_state": "conditional", "requires_condition": {"region_visited": {"region_id": "region_h0_undersign_exchange"}}, "unlock_effect_id": "eff_ilyra_files_contradictory_copy"}
  ],
  "authority": {"institution_id": "institution_r4_record_office", "protocol_id": "protocol_category_precedence", "recognition_default": "artifact", "legitimacy_baseline": 0},
  "dominant_protocol": {"protocol_id": "protocol_category_precedence", "category_bias": ["artifact", "patient"], "category_error_policy": "escalate"},
  "resource_flow": {"scarce_keys": ["res_safe_water"], "surplus_keys": ["res_blank_form"], "access_rule_ids": ["rule_r4_form_quota"]},
  "residents": [{"npc_id": "npc_01_ilyra_senn", "initial_presence": "resident", "moves_on_absence_to": "region_h0_undersign_exchange"}],
  "clocks": [{"clock_id": "clock_public_record", "start_state": "active", "reversal": "slow", "weight": 2}, {"clock_id": "clock_institutional_response", "start_state": "active", "reversal": "none", "weight": 2}],
  "hidden_state": {"reveal_condition": {"recovery_done": {"recovery_event_id": "rec_r4_translation_reentry"}}, "reveal_kind": "partial", "reveal_prop_ids": ["prop_r4_low_level_stacks"], "reveal_document_ids": ["doc_r4_contradictory_translation"]},
  "initial_state": "as_saved",
  "combat_content": {"encounter_ids": ["enc_r4_translation_drift"], "field_pressure": "medium"},
  "noncombat_content": {"interactable_prop_ids": ["prop_r4_low_level_stacks"], "service_ids": ["service_r4_reentry_desk"]},
  "initial_cluster": {"cluster_id": "cluster_rc_04_sentence_above_stair", "npc_ids": ["npc_01_ilyra_senn"], "thread_ids": ["thread_r4_return_record", "thread_r4_name_ownership"], "starting_conversation_id": "conv_r4_translation_desk"},
  "revisit_variants": [
    {"variant_id": "rv_after_filing", "condition": {"clock_irreversible": {"clock_id": "clock_public_record"}}, "prop_state_ids": ["prop_r4_low_level_stacks"], "conversation_id": "conv_r4_translation_desk"}
  ],
  "internal_routes": [],
  "unresolved_debt": [
    {"debt_id": "d_ilyra_archived", "description": "동행인이 문서에서 object로 처리된다.", "due_condition": {"clock_irreversible": {"clock_id": "clock_public_record"}}, "resolve_effect_ids": ["eff_ilyra_opens_index"]}
  ],
  "cross_region_links": [
    {"to_region_id": "region_h0_undersign_exchange", "link_kind": "personnel", "note": "겸직 기록이 두 지역을 잇는다."}
  ],
  "oneoff_dialogue_seed_ids": ["seed_s108"],
  "axis_weights": {"protocol_legitimacy": 2, "recognition_drift": 1, "continuity_pressure": 0, "resource_scarcity": 1},
  "seed_ids": ["seed_s058", "seed_s099"]
}
```

검증:

- **region 개수는 정확히 9개**이고 §3.5.1의 ID 집합과 **집합으로 일치**해야 한다. 하나라도 없거나 하나라도 더 있으면 `region_not_canonical_9` error(`10`의 `test_region_graph_matches_02_canonical_world`).
- **`region_role`은 필수**이고 §3.5.1의 9개 token 중 **해당 region의 `02` §1/§7.0 role과 정확히 같아야 한다** → `region_role_mismatch`. `region_role`은 enemy/encounter의 `region_role`과 대조하는 기준이 된다(§5.16).
- `entry.edge_id`와 `exits[].edge_id`는 §3.5.2의 18개 `route_e*` 중 하나여야 한다. `edge_id` ↔ `(from_region_id, to_region_id)` 쌍은 `02` §5.2와 일치해야 한다 → `edge_endpoints_mismatch`.
- **`02`는 18개 edge를 bidirectional으로 정의했다.** `A.exits`에 `B`가 있으면 `B.exits`에도 `A`가 있어야 하고, 그 `edge_id`가 같아야 한다 → `edge_not_bidirectional` error. `R8`의 `entry`와 `exits[0]`은 **둘 다** `route_e18_folding_school_approach`다.
- `exits[].gate_id`와 `entry.gate_id`는 §3.5.2의 9개 `gate_g*` 중 하나여야 한다. `exits[].gate_id`는 **global으로 유일**해야 한다. `entry.gate_id`와 어떤 `exits[].gate_id`가 같으면 같은 문이다. `gate_g0_arrival_declaration`이 두 곳에 등장하는 것은 정상이다. 충돌은 **서로 다른 (from, to) 쌍이 같은 gate id를 쓰는 것** → `gate_id_collision` error. **`gate_g9`를 만들면 `unknown_gate_id` error**(`02` §6.1).
- `exits[].route_state` enum은 `02` §5.3의 5개로 닫힌다: `open`, `conditional`, `redirected`, `closed`, `debt-bearing`. 그 밖의 값 → `route_state_outside_02_enum` error.
- **모든 conditional edge는 unlock condition을 가져야 한다.** `route_state`가 `conditional`/`closed`/`redirected`/`debt-bearing` 중 하나인데 `requires_condition`가 `{}`이면 `conditional_edge_without_condition` error. `open`인데 `requires_condition`가 있으면 Stage 4 `open_edge_with_condition` warning.
- `exits[].unlock_effect_id`는 `eff_*`를 참조하고, 해당 effect의 `operations`에 `unlock_route` op이 이 `gate_id`를 대상으로 해야 한다 → Stage 3 `gate_unlock_unwired`. 조건만 있고 effect가 없는 gate는 아무도 열지 못한다.
- `topology.size_class` enum: `small`, `medium`, `large`, `sprawling`. `shape`/`traversal_axis`는 자유 snake_case(3..32자). `landmark_count` int 1..12.
- `topology.backtrack_supported == false`이면 `exits` 크기가 1이어야 한다 → `no_backtrack_single_exit`. **긴 이동으로 분량을 만들지 않는다**는 결정의 data-level 강제다. 이 Kit에서는 `backtrack_supported`는 9개 region 전부 `true`다 → Stage 4 `region_without_backtrack_affordance` warning.
- **모든 region은 최소 2개의 return affordance를 가져야 한다**(`02` §6.2). `exits` 크기 **+ `internal_routes` 크기**가 2보다 작으면 `single_return_affordance` error. `R8`은 `exits`가 1개(`E18`)지만 `internal_routes`에 `course index return` 1개를 선언하므로 2개가 된다. `internal_routes`가 `gate_id`를 쓰면 `unknown_gate_id` error — 내부 통로는 gate가 아니라 region state다(`02` §1.1/§7.9).
- `authority.institution_id`, `authority.protocol_id`, `dominant_protocol.protocol_id`, `resource_flow.access_rule_ids[]`는 자유 snake_case(3..64자)이며 **content kind가 아니다.** institution/protocol/rule은 개념 이름이고 mechanic binding은 `clocks`·`effects`·`npc`가 담당한다. institutions를 kind로 만들면 §1.2의 18개 밖에 19번째 kind가 생기고 다른 plan 파일 소유 범위를 침범한다. 의도적으로 string key로 둔다. **magic institution(`MAG_ACADEMY`, `WANDERING_MAGE`, `LINEAGE_HOUSE`, `FIELD_WEAVE_GUILD`, `VOID_CONTRACT_COURT`, `CIRCULATION_BOARD`)도 여기에 속한다** — `12` §5.2의 여섯 분기는 string key이며 새 kind가 아니다.
- `residents[].npc_id` 파일 내 유일. `initial_presence` enum: `resident`, `visiting`, `transient`, `absent`, `pending`.
- **support resident도 `residents[]`에 들어가지만 `initial_presence: "transient"`/`"visiting"`이어야 한다** → `core_roster_presence_mismatch` warning. canonical core roster 14명은 자기 home region에 `resident`로 있어야 한다(§5.11).
- `clocks[]`는 1..6개, `clock_id` 파일 내 유일, `weight` int 1..3. `reversal` enum: `none`, `slow`, `possible`, `terminal`. `start_state` enum은 §5.6과 동일. `clock_id`는 §3.5.4의 6개여야 한다.
- `hidden_state.reveal_kind` enum: `none`, `partial`, `full`. `reveal_prop_ids`/`reveal_document_ids` 중 최소 1개.
- `initial_state` enum: `as_authored`, `as_saved`.
- `combat_content.encounter_ids`는 비어도 된다(전투 없는 region 허용). `combat_content.field_pressure` enum: `low`, `medium`, `high`, `lethal`.
- `noncombat_content.service_ids`는 자유 snake_case이고 `01`이 services를 소유하므로 여기서 해석하지 않는다. `SERVICE_R8_COURSE_INDEX`도 여기에 있다 — **`R8`으로 향하는 route를 만들지 않는다는 `02` §7.0의 결정이 여기서 강제된다.**
- `initial_cluster.cluster_id`는 §3.5.7의 **그 region의 행 값과 정확히 같아야 한다** → `cluster_id_not_canonical` error. 다른 region의 값을 쓰면 `cluster_not_one_to_one` error. 9개 cluster가 9개 region과 1:1이므로 catalog 전체에서 `cluster_id`가 전역 유일해야 한다 → `duplicate_cluster_id` error(§2.9).
- `initial_cluster.thread_ids`는 자유 snake_case. **`thread_id`는 content kind가 아니다.** story flow 문법은 `03`이 소유하고, region data는 cluster가 어떤 thread id를 시작하는지 **참조만** 한다.
- `initial_cluster.npc_ids`는 6..12개여야 한다 → `cluster_size_outside_6_12` error. `PLAN_RESOLUTION` §7과 constitution R11의 major branch 규모다. **단, `entry_region`의 첫 cluster는 예외가 아니라 동일 규칙을 따른다** — 첫 방문부터 6명 이상이 authored되어야 한다.
- `internal_routes`는 0..4개, `internal_route_id` 파일 내 유일(§2.9). 허용 key: `internal_route_id`, `from_anchor_key`, `to_anchor_key`, `route_state`(§5.10의 5개), `requires_condition`, `unlock_effect_id`. `route_state`가 `conditional`/`closed`/`redirected`/`debt-bearing`인데 `requires_condition`가 `{}`이면 `conditional_edge_without_condition` error(내부 통로에도 같은 규칙).
- `revisit_variants`는 0..8개, `variant_id` 파일 내 유일(§2.9). **8개 초과는 `variant_overflow` error.** revisit가 play value라는 결정은 지키되 variant가 본편이 되는 것을 막는다. **2개 미만이면** `too_few_revisit_variants` error(`02` §12: "모든 region에는 최소 두 개의 state-driven revisit variant"). `R8`도 예외가 아니다 — filed grade / dispersed residue / recovered medium / unresolved contract의 4개가 요구된다(`05` `FAM-ARPG-19` aftermath).
- `revisit_variants[].prop_state_ids`의 prop은 **이 region에 속해야 한다** → `revisit_prop_foreign`.
- `revisit_variants[].conversation_id`는 해석돼야 한다.
- `unresolved_debt[]`는 1개 이상, `debt_id` 파일 내 유일, `resolve_effect_ids` 비어 있으면 안 됨. **1개 미만이면** `region_without_unresolved_debt` error.
- `unresolved_debt[]`의 **optional** `resource_id`는 §6.3의 `res_*`여야 하고, §6.4의 **비수량 debt key**(`res_labor_pledge`, `res_contract_tally`)를 가리킬 때는 `resolution_token`이 **필수**다 → `debt_key_without_resolution` error. 그 두 key는 amount가 없으므로 resolution이 유일한 진행 상태다.
- `unresolved_debt[].resolution_token` enum: `open`, `full`, `staged`, `refused`, `filed`, `voided`. `open` 이외의 token은 `resolve_effect_ids`가 비어 있으면 안 된다 → `debt_resolved_without_effect` error.
- `cross_region_links[].link_kind` enum: `trade`, `record`, `personnel`, `hostility`, `faith`, `resource`. `to_region_id`는 다른 region이어야 한다(자기 자신 금지) → `self_region_link`.
- `axis_weights`는 §6.1의 4개 axis만, value int **0..3**(가중치이므로 음수 없음). 합이 0이면 `region_axis_weightless` error.
- `conflict_thesis`는 **문장 하나**여야 한다. 종결 기호(`.`, `!`, `?`)가 2개 이상이면 `region_thesis_not_one_sentence` error.
- `oneoff_dialogue_seed_ids`의 seed는 `ledger_usage_class == "ONEOFF"`이어야 한다 → `oneoff_seed_class_mismatch`.
- `hidden_state`가 `reveal_kind == "none"`이면 `reveal_condition`은 `{}`여야 한다.

#### 5.10.1 `region_*.concentration` — 환경 농도, disperser, circulator

`02` §5.5/§9.1의 node 단위 `concentration_field`와 `R2`의 civic infrastructure를 region record에 붙인다. **optional**이며, `concentration_field`를 가진 region(=`R2`, `R8`, 그리고 `E4` era 표면을 가진 region)만 선언한다. 선언하지 않은 region에 농도가 없다는 뜻은 아니고, **측량값이 그 region's `authored surface`에 없다는 뜻**이다.

```json
"concentration": {
  "field_level_permille": 640,
  "safe_band_permille": 700,
  "threshold_permille": 900,
  "provenance_node_id": "r2_09_disperser_reading",
  "disperser_node_ids": ["prop_r2_disperser_a", "prop_r2_disperser_b"],
  "disperser_charge_key": "res_disperser_charge",
  "circulation_slot_key": "res_circulation_slot",
  "pollution_accumulated": 2
}
```

허용 key 8개. 검증:

- `field_level_permille` int 0..1000, `safe_band_permille` int 0..1000, `threshold_permille` int 0..1000. **`safe_band_permille < threshold_permille`**여야 한다 → `concentration_band_above_threshold` error.
- `field_level_permille >= threshold_permille`이면 그 region은 이미 임계치를 넘었다. 이 상태는 **저장되지 않는다** — `field_level_permille`은 `world.magic.concentration_fields`의 현재 측정값이고, threshold 초과 자체는 `K contamination` clock의 한 stage 전진으로 표현된다(`02` §4.4). `contaminated` 같은 bool key를 content가 만들지 않는다 → `contaminated_flag_in_content` error.
- `provenance_node_id`는 자유 snake_case이고 `02` §5.5의 두 측정 원천(`R2-09 Disperser Reading`, `R8-02 Concentration Registration`) 중 하나를 가리켜야 한다 → `concentration_provenance_not_measurable` error. **`E18`의 `res_concentration_sample`은 이 provenance 없이 만들어지지 않는다**(`05` §2.5).
- `disperser_node_ids`는 `prop_*` 0..4개, 파일 내 유일. **disperser는 재고를 안전 범위에 맞추는 civic infrastructure**이고 `circulator`는 축적 농도를 외부 공기로 옮기며 오염 비용을 만든다(`12` §2.3).
- `disperser_charge_key`/`circulation_slot_key`는 §6.3의 `res_disperser_charge`/`res_circulation_slot`이어야 한다 → `unknown_field_resource_key`. 다른 key를 넣으면 `concentration_infrastructure_wrong_resource` error.
- `pollution_accumulated` int 0..999. **`circulator`가 오염을 "해결"한 것으로 기록되지 않는다**(`02` §4.4) — 값이 줄기만 하고 0으로 돌아가지 않는다 → `pollution_written_as_solution` error.
- `concentration`은 **전역 위험 막대가 아니다.** `field_level_permille`을 combat player band나 world map에 노출하지 않는다 → `global_concentration_forbidden` error. `02` §12: "네 axis와 여섯 pressure clock은 상시 HUD로 노출하지 않는다. `concentration`도 예외가 아니다."
- `concentration`는 **축도 clock도 아니다.** 새 `axis`/`clock_*` key가 `concentration` 블록에 들어오면 `axis_out_of_range`/`clock_not_canonical` error.

### 5.11 `npcs` — NpcDefinition

constitution §7 + BS2 §6.1/6.2. **"dialogue-only NPC를 quest source로 삼지 않는다"**를 schema가 강제한다. roster는 `04` §2의 canonical core 14명 + support resident로 구성한다.

```json
{
  "schema_version": 1,
  "id": "npc_01_ilyra_senn",
  "display_name": "Ilyra Senn",
  "roster_kind": "core",
  "public_role": "archive inquiry and record correction",
  "private_role": "자신이 쓴 번역을 proofread 하지 않는다",
  "desire": "기록이 사람보다 먼저 완성되는 것을 막는다.",
  "fear": "자기 category가 남으면 이름보다 오래 산다.",
  "contradiction": "절차를 가장 믿으면서 절차가 사람을 지우는 걸 알고 있다.",
  "capability": {"port_ids": ["port_r4_inquiry", "port_r4_crown_seat"], "can": ["withhold_record", "reclassify_subject", "open_gate"]},
  "resource_access": {"grants": ["equipment_archive_seal_plate"], "denies": ["gate_g8_crown_precedence"], "denied_by_effect_id": "eff_ilyra_recorded_as_artifact"},
  "knowledge_boundary": {"knows": ["seed_s019", "seed_s069"], "does_not_know": ["seed_s036"], "never_learns": ["seed_s106"]},
  "speech_pressure": {"verb_ids": ["verb_ask_category", "verb_press_receipt", "verb_offer_name"], "silence_condition": {"axis_at_least": {"axis": "protocol_legitimacy", "value": 2}}},
  "interaction_verbs": [
    {"verb_id": "verb_press_receipt", "availability": {}, "opens": "conv_r4_translation_desk", "presentation_class": "neutral"},
    {"verb_id": "verb_ask_category", "availability": {"choice_taken": {"conversation_id": "conv_r4_translation_desk", "choice_id": "ch_file_contradictory_copy"}}, "opens": "doc_r4_contradictory_translation", "presentation_class": "official"}
  ],
  "relationship_ids": ["rel_01_ilyra_record"],
  "clock_ids": ["clock_public_record", "clock_institutional_response"],
  "encounter_profile": {
    "as_neutral": {"encounter_id": null},
    "as_hostile": {"encounter_id": "enc_r4_archive_return_protocol"},
    "conversion_condition": {"relationship_is": {"relationship_id": "rel_01_ilyra_record", "target_npc_id": "npc_01_ilyra_senn", "state_id": "rs_archived"}},
    "as_ally": {"effect_id": "eff_ilyra_opens_index", "encounter_modifier": 1}
  },
  "survival": {"death_allowed": true, "on_death_effect_ids": ["eff_ilyra_recorded_as_artifact"], "on_absence_effect_ids": ["eff_r4_record_sealed"], "absence_kind": "permanent"},
  "absence": {"kind": "permanent", "moves_to_region_id": "region_h0_undersign_exchange", "condition": {}},
  "appearance": {"body_key": "body_archivist_ox", "portrait_key": "portrait_ilyra_senn", "voice_key": "voice_ilyra_senn"},
  "oneoff_dialogue_seed_ids": ["seed_s104"],
  "cross_link_ids": ["region_r4_crownwell_archive", "npc_10_juno_caster"],
  "removal": "death",
  "seed_ids": ["seed_s019", "seed_s044"]
}
```

검증:

- **`roster_kind` enum: `core`, `support`.** `roster_kind == "core"`인 NPC는 §3.5.3의 14명 목록에 정확히 포함되어야 하고, `roster_kind == "support"`인 NPC는 그 목록에 없어야 한다. 14 core roster가 아니면서 `core`라 선언하면 `core_roster_not_canonical` error, 14 목록에 있는데 `support`라 선언하면 `core_roster_downgraded` error(`10`의 `test_fourteen_core_npcs_own_the_canonical_roster`).
- **`R8`는 15번째 core actor를 만들지 않는다.** `npc_20_*`–`npc_26_*` 7명은 전부 `support`다. `npc_15`–`npc_19` 번호를 쓰면 `support_roster_id_range_forbidden` error.
- **`PLAYER_BRIDGE_0`는 `npc_*`가 아니다.** `npc_20_player_bridge` 같은 ID를 만들면 `player_id_in_npc_namespace` error.
- **`capability.port_ids`는 비어 있으면 안 된다** → `npc_without_port` error. constitution §7("NPC 한 명은 dialogue-only가 아니다")의 강제 지점이다.
- `capability.can`은 자유 snake_case, 1..12개. `port_ids`는 자유 snake_case, 1..8개.
- `resource_access.grants`는 `equipment_*`/`item_*`를 참조 → prefix 불일치면 `npc_grant_target_not_item`. `resource_access.denies`는 `gate_g*` id를 참조하고 region `exits[].gate_id`에 존재해야 한다 → Stage 3 `npc_denies_unknown_gate`.
- `resource_access.denied_by_effect_id`는 `eff_*`를 참조.
- `knowledge_boundary.knows`/`does_not_know`/`never_learns`는 `seed_*`를 참조. **`knows`와의 교집합만 금지**한다(`npc_knowledge_overlap`). `does_not_know` ∩ `never_learns`는 겹쳐도 허용한다. 모른다와 못 배운다는 실제로 다른 상태이고, 이 차이를 보존해야 한다.
- `speech_pressure.verb_ids` 1..12개, 파일 내 유일. `interaction_verbs[].verb_id`와 교집합이 있어야 한다 → `npc_verb_unused` warning.
- `interaction_verbs[].presentation_class` enum: `neutral`, `official`, `confidential`, `hostile`, `extreme`, `narration`, `unavailable`, `result`. verb는 `neutral|official|confidential|hostile|extreme` 범위를 사용한다.
- `interaction_verbs[].availability`가 `{}`(항상 가능)이면 `opens`가 해석돼야 한다. 어느 것도 안 열면 `npc_verb_without_target` error.
- `interaction_verbs[].opens`는 `conv_*`/`doc_*`/`enc_*`를 참조. **`conv_*`의 `speaker_npc_id`가 이 NPC여야 한다** → Stage 3 `conversation_speaker_mismatch`.
- `interaction_verbs`는 1..10개, `verb_id` 파일 내 유일.
- **disabled/unavailable도 focusable이다**(`PLAN_RESOLUTION` §7, `01` §6.2). 따라서 `interaction_verbs`에 `focusable: false` 같은 field를 **두지 않는다** → `npc_verb_focus_field_present` error. focus와 disabled는 presentation이 별도로 읽는 두 state다.
- `relationship_ids` 1..4개, 파일 내 유일. `rel_*.target_npc_id`가 이 NPC여야 한다 → Stage 3 `relationship_backlink_missing`.
- `clock_ids`는 §3.5.4의 6개 `clock_*`를 참조하고 그 clock이 `owner_region_id` 또는 NPC의 region 중 하나와 맞아야 한다 → Stage 4 `npc_clock_orphaned` warning.
- `encounter_profile.as_hostile.encounter_id`가 있으면 그 encounter의 `activation.kind == "npc_conversion"`이거나 `roster`/`roster_add`에 이 NPC를 가리키는 enemy가 있어야 한다 → Stage 3 `npc_hostile_encounter_unwired`. **NPC-boss 전환은 별도 entity를 만들지 않고 같은 stable identity의 resolved state로 모델링한다.** `encounter_profile`이 그 지점이며 `05` §6.3의 `NPC-CONV-ARPG-*` 템플릿이 여기에 대응한다.
- `encounter_profile.as_ally.effect_id`가 있으면 그 effect의 `operations`에 `relationship` op이 있어야 한다 → Stage 3 `ally_effect_unwired`. 동행은 relationship state에서 열리고 효과만 받는다.
- `encounter_profile`의 세 slot(`as_neutral.encounter_id`, `as_hostile.encounter_id`, `as_ally.effect_id`)은 **§9.3의 `nullable_reference_slots`에 속한다.**
- `encounter_profile.as_hostile.encounter_id`가 `null`인데 `conversion_condition`이 있으면 `npc_hostile_encounter_unwired` error.
- `interaction_verbs[].availability`가 `{}`가 아니면 그 조건이 가리키는 `choice_taken`의 `conversation_id`는 `opens`가 가리키는 conversation이어야 한다 → Stage 3 `verb_condition_unrelated_target`.
- `survival.death_allowed == false`이면 `removal`은 `never`여야 한다 → `npc_removal_death_contradiction`.
- `absence.kind` enum: `permanent`, `route`, `conditional`, `none`. `kind`가 `route`/`conditional`이면 `moves_to_region_id` 필수, `none`이면 없어야 한다. `kind == "conditional"`이면 `condition`이 `{}`가 아니어야 한다 → `npc_absence_unconditional`.
- `absence.moves_to_region_id`가 있으면 해당 NPC가 resident인 region의 `residents[].moves_on_absence_to`와 **동일 token**이어야 한다 → Stage 3 `npc_absence_target_mismatch`.
- `cross_link_ids`는 2..12개, 파일 내 유일. **최소 2개** — R10의 최소 2개 연결이 NPC에도 예외가 아니다. 전부 `npc_*`/`region_*`/`clock_*`/`encounter_*` 중 하나여야 한다.
- `removal` enum: `death`, `permanent_absence`, `temporary`, `never`.
- `public_role`, `private_role`, `desire`, `fear`, `contradiction`은 **모두 비어 있으면 안 된다** → `npc_missing_character_core`.
- `core` roster NPC의 `absence.kind`는 `permanent`이어야 한다 → `core_npc_absence_temporary` warning. canonical NPC는 세계에서 사라지지 않는다.
- **`R8` core NPC visitor 7명**(`npc_03_veya_morcant`, `npc_04_sable_halm`, `npc_08_meral_dune`, `npc_09_perrin_lask`, `npc_14_eda_marrow`, `npc_07_bryn_oskel`, `npc_12_ravenna_holt`)은 `R8`의 `residents[]`가 아니라 `initial_cluster.npc_ids`/`cross_link_ids`로 등장한다. `R8`의 `residents[]`에는 `npc_20_*`–`npc_26_*` support 7명만 있다.

#### 5.11.1 `npc_*.mana_profile` — body compatibility / failure class

`12` §2.2의 `mana_profile`은 성격·선택지가 아니라 **body compatibility와 failure class**다. NPC record에 **optional** `mana_profile` 하나만 둔다. 새 kind도 새 axis도 아니다.

closed 8 enum:

| token | 뜻 |
|---|---|
| `retention_high_emission_low` | 저장은 잘 되지만 내보내기가 어렵다 |
| `retention_low_emission_high` | 내보내기는 빠르지만 남지 않는다 |
| `retention_balanced` | 둘 다 보통 |
| `retention_overflow` | 축적이 임계를 넘기 쉽다 |
| `blocked_emission` | 방출만 되고 저장이 되지 않는다 |
| `concentration_reactive` | 환경 농도에 반응해 효율이 바뀐다 |
| `medium_reactive` | 매개체에 반응한다 |
| `sensory_misclassification` | 감각이 대상을 잘못 분류한다 |

- `npc_*.mana_profile`은 위 8개 중 하나이거나 **키가 없어야 한다** → `mana_profile_outside_canonical_enum` error. `npc_*.mana_profile`은 `null`로 채우지 않는다(§2.4).
- **stage 3**에서 `npc_*.mana_profile`이 있으면 `region_*.residents[]`나 `initial_cluster.npc_ids`로 **그 NPC가 등장하는 region에** `concentration` 블록이 선언돼 있거나, 그 NPC의 region이 `E4` era 표면을 가져야 한다 → Stage 4 `mana_profile_without_concentration_region` warning.
- **`mana_profile`은 도덕적 판단이 아니다**(`12` §2.2). `npc_*.public_role`/`private_role`/`semantic_tags`에 그 profile을 "`유능하지 않은`" "`저주받은`" 같은 평가어로 옮기면 `mana_profile_as_moral_judgement` error. 이 profile은 triage·curriculum·employment 분류의 입력이지 평가가 아니다(`S129`).
- **catalog 전체에서 distinct `mana_profile`이 4개 미만이면** `mana_profile_diversity_insufficient` error. `12` §10의 floor(retention, emission, overflow, blocked)가 content에 실제 등장해야 한다.
- `act_*.craft.body_profile_requirements`는 이 8개의 부분집합이고, 그 token은 §5.5.7에서 같은 표를 참조한다. 별도 표를 만들지 않는다.
- `mana_profile`은 `02` §9.1의 `world.magic.body_load[<actor>].mana_profile`에 저장된다(§10.2). content의 `npc_*.mana_profile`은 **authored 기본값**이고 `body_load`가 현재 값이다. 한 값을 두 곳에 복제하지 않는다.

### 5.12 `conversations` — ConversationDefinition

USER_PLAY_REFERENCE §6.1의 `Conversation` + `ChoiceSet`을 한 파일에 묶는다. A~H가 둘을 분리해 보여주지 않았으므로 분리하지 않는다.

```json
{
  "schema_version": 1,
  "id": "conv_r4_translation_desk",
  "display_name": "번역 데스크",
  "region_id": "region_r4_crownwell_archive",
  "speaker_npc_id": "npc_01_ilyra_senn",
  "entry_condition": {"not": {"relationship_is": {"relationship_id": "rel_01_ilyra_record", "target_npc_id": "npc_01_ilyra_senn", "state_id": "rs_indexed"}}},
  "priority": 10,
  "pages": [
    {"page_id": "pg_official", "speaker": "npc", "presentation_class": "official", "text": "접수 번호가 이름보다 먼저입니다.", "advance": "auto"},
    {"page_id": "pg_paper", "speaker": "world", "presentation_class": "narration", "text": "데스크 아래 접힌 층별 원문.", "advance": "wait"}
  ],
  "choices": [
    {
      "choice_id": "ch_file_contradictory_copy",
      "text": "두 번역 중 하나를 먼저Filing한다.",
      "semantic_tags": ["cooperative", "bureaucratic"],
      "presentation_class": "neutral",
      "availability": {},
      "unavailable_reason_surface": "prop_r4_low_level_stacks",
      "irreversibility": "delayed_only",
      "return_focus": "field",
      "immediate_effect_id": "eff_ilyra_reopens_docket",
      "delayed_effect_id": "eff_ilyra_files_contradictory_copy",
      "one_shot": true,
      "hint_surface": "none"
    },
    {
      "choice_id": "ch_sign_translation",
      "text": "서명 없이 한 층만 옮긴다.",
      "semantic_tags": ["destructive", "bureaucratic"],
      "presentation_class": "extreme",
      "availability": {"document_read": {"document_id": "doc_r4_contradictory_translation"}},
      "unavailable_reason_surface": "doc_r4_contradictory_translation",
      "irreversibility": "irreversible",
      "return_focus": "field",
      "immediate_effect_id": "eff_ilyra_signature_taken",
      "delayed_effect_id": "eff_ilyra_recorded_as_artifact",
      "one_shot": true,
      "hint_surface": "none"
    }
  ],
  "on_complete": {"effect_ids": []},
  "on_abort": {"effect_ids": []},
  "revisit": "state_dependent",
  "alt_conversation_ids": ["conv_r4_operator_trial"],
  "seed_ids": ["seed_s016"]
}
```

검증:

- `region_id`는 `region_*`를 참조. **`speaker == "npc"`인 page가 하나라도 있으면 `speaker_npc_id` 필수**, 없으면 없어야 한다 → `conversation_speaker_unbound`.
- `pages` 1..24개, `page_id` 파일 내 유일. `speaker` enum: `npc`, `player`, `world`. `advance` enum: `auto`, `wait`. **`presentation_class` enum은 8개 canonical 값**을 사용한다. `narration`은 `speaker == "world"`인 page에만 허용한다 → `narration_class_on_npc_page`.
- **`pages`와 `choices`의 합이 0이면 안 된다** → `conversation_empty`.
- `pages[].text`는 1200자 이하. 1 page에 여러 문단을 넣으려면 `pages[]`를 여러 개 쓴다(A~H의 page 단위 진행).
- `entry_condition`은 `{}`일 수 있다. 같은 region에 `priority`가 같고 `entry_condition`이 모두 `{}`인 conversation이 2개 이상이면 `conversation_priority_ambiguous` error.
- `revisit` enum: `once`, `repeatable`, `state_dependent`, `replayable_after_state_change`.
- `revisit == "once"`이면 `entry_condition`에 conversation 완료 leaf가 있어야 한다 → `once_conversation_reentry_trap` error. 한 번만 볼 수 있는데 완료 후 다시 진입할 수 없으면 갇힌다.
- `alt_conversation_ids` 1..6개, 파일 내 유일, 자기 자신 금지. alt 순환은 허용하되 `entry_condition`으로 끊겨야 한다. 순환이 있는데 어느 하나에도 `conversation_completed`/`choice_taken` leaf가 없으면 `alt_cycle_without_gate` error.
- **`irreversible`인 choice가 하나라도 있으면 `on_abort.effect_ids`는 비어 있어야 한다** → `abort_after_irreversible_choice` error.
- `choices`는 0..8개, `choice_id` 파일 내 유일.
- `seed_ids`/`audit_note` ungrounded rule은 §5.3과 동일.
- dialogue는 world를 축소한 full-screen menu가 아니다(`09` §5.1). content는 그(layout)을 표현하지 않고 page/choice 순서만 준다.

### 5.13 `choices` — ChoiceDefinition

choice는 `ConversationDefinition.choices[]` 안에 **인라인**이다. 별도 kind가 아니다. `§2.9`의 인라인 sub-record 규칙이 그대로 적용된다.

```json
{
  "choice_id": "ch_sign_translation",
  "text": "서명 없이 한 층만 옮긴다.",
  "semantic_tags": ["destructive", "bureaucratic"],
  "presentation_class": "extreme",
  "availability": {"document_read": {"document_id": "doc_r4_contradictory_translation"}},
  "unavailable_reason_surface": "doc_r4_contradictory_translation",
  "irreversibility": "irreversible",
  "return_focus": "field",
  "immediate_effect_id": "eff_ilyra_signature_taken",
  "delayed_effect_id": "eff_ilyra_recorded_as_artifact",
  "one_shot": true,
  "hint_surface": "none"
}
```

허용 key: 12개(`choice_id`, `text`, `semantic_tags`, `presentation_class`, `availability`, `unavailable_reason_surface`, `irreversibility`, `return_focus`, `immediate_effect_id`, `delayed_effect_id`, `one_shot`, `hint_surface`). runtime namespacing은 `conv_r4_translation_desk/ch_sign_translation`.

검증:

- `semantic_tags`는 자유 snake_case 1..6개. **closed enum이 아니다.** core에 vocabulary를 늘리지 않는다.
- `presentation_class` enum: `neutral`, `official`, `confidential`, `hostile`, `extreme`, `narration`, `unavailable`, `result`. choice는 `neutral|extreme|unavailable|result`만 허용한다.
- **A~H에서 직접 확인된 것은 `extreme`(사용자 설명상 극단적 선택)뿐이고 `red`가 danger/불가/성적 중 무엇인지인지는 미확인이다.** 그래서:
  - `presentation_class`는 **색이 아니다.** `extreme`을 어떤 색으로 칠할지는 `09`가 정한다. 이 문서는 색을 정하지 않는다.
  - **`presentation_class == "extreme"`이면 `semantic_tags`에 `destructive`, `irreversible`, `transgressive` 중 최소 하나가 있어야 한다** → `ungrounded_extreme_class` error. 외형 클래스만으로 극단성을 표현하지 못하게 한다. constitution §10 gate 7("이름만 바꿔도 generic이 되지 않는다")의 data-level 강제다.
  - `presentation_class`가 `disabled`를 뜻하지 않는다. disabled는 `availability`가 비어 있지 않다는 **별도 상태**이고, `unavailable_reason_surface`가 그 이유를 world surface로 노출한다.
  - `semantic_tags`에 `danger`, `locked`, `disabled`가 있으면 `choice_tag_overlaps_state` error. semantic tag와 state는 다른 층위다.
- **unavailable choice도 focusable이고 auto-skip하지 않는다**(`01` §6.2, `PLAN_RESOLUTION` §7). 그래서 choice에 `focusable`/`auto_skip` 같은 field를 **두지 않는다** → `choice_focus_field_present` error. content는 `availability`와 `unavailable_reason_surface`만 준다.
- `availability`가 `{}`인데 `unavailable_reason_surface != "none"`이면 `redundant_unavailable_surface` warning. 반대로 `availability`가 비어 있지 않은데 `unavailable_reason_surface == "none"`이면 `silent_unavailable` **error**. unavailable choice는 왜 unavailable한지 world action으로 설명 가능해야 한다.
- `unavailable_reason_surface`는 `prop_*`/`doc_*`/`enc_*`/`conv_page:*`(부모 conv id의 page id)/`none` 중 하나. `prop`/`doc`/`enc`/`conv_page`는 해석돼야 한다.
- `irreversibility` enum: `reversible`, `delayed_only`, `irreversible`.
- `irreversibility == "irreversible"`이면 `delayed_effect_id` **필수** → `irreversible_without_delayed_consequence` error. 되돌릴 수 없는 선택은 반드시 delayed consequence를 가져야 한다(R10: immediate와 delayed 둘 다).
- `irreversibility == "irreversible"`이면 `immediate_effect_id`는 없어야 하거나 **flag op만** 가진 effect여야 한다 → `irreversible_with_large_immediate_effect` error. `flag` op은 되돌릴 수 없으므로 유일한 예외다.
- `return_focus` enum: `choice`, `field`, `conversation`, `document`. (`prop_*`의 `return_focus` enum과는 다르다. §5.9 `return_focus_not_in_kind`와 짝을 이룬다.)
- `return_focus == "choice"`이면 `availability`가 `{}`이고 `one_shot == false`여야 한다 → `choice_return_focus_escape` error.
- `delayed_effect_id`의 effect `timing`은 `immediate`가 아니어야 한다 → `choice_delayed_is_immediate`. `immediate_effect_id`의 effect `timing == "immediate"`이어야 한다 → `choice_immediate_is_delayed`.
- `hint_surface` enum: `none`, `prop`, `doc`, `npc`. `none`이 아니면 그 surface가 해석돼야 한다. "확실한 선택 결과를 설명문으로 대신하지 않는다"를 지키려면 default가 `none`이어야 한다.
- `text`는 1200자 이하. `text`에 결과 예고 token(`…`, `~다`, `~될 것이다`, `will`, `outcome`)이 2개 이상 있으면 `choice_text_predicts_outcome` **warning**. TIN 세계관의 deadpan 행정 어조가 의도적으로 미래담을 담기 때문이다. 완전한 금지가 아니라 집중을 보는 검수다.
- `semantic_tags`에 `romance`나 `consent`가 있으면 그 conversation의 region에 `channel == "romance"`인 `rel_*`이 최소 하나 있어야 한다 → `romance_choice_without_relationship` error.
- **`transgressive` tag는 `extreme` + romance-channel relationship을 동시에 요구한다.** `transgressive`가 `semantic_tags`에 있으면 그 conversation의 region에 romance `rel_*`이 있어야 한다 → `transgressive_without_romance_channel` error.

### 5.14 `documents` — DocumentDefinition

USER_PLAY_REFERENCE §5.3/§5.4. **page line cap은 9로 고정**이다(`PLAN_RESOLUTION` §7).

```json
{
  "schema_version": 1,
  "id": "doc_r4_contradictory_translation",
  "display_name": "Low-Level Stacks · 층별 번역 대조",
  "owner_npc_id": "npc_01_ilyra_senn",
  "region_id": "region_r4_crownwell_archive",
  "availability": {"condition": {}, "reached_by": "prop"},
  "reached_by_ref": "prop_r4_low_level_stacks",
  "pages": [
    {
      "page_id": "pg_plain",
      "lines": ["층 1: ——", "층 2: ——", "분류: 미Filing"],
      "presentation": "plain",
      "corruption_rules": []
    },
    {
      "page_id": "pg_wrong",
      "lines": ["층 1: ——", "층 2: ——", "분류: 회수물"],
      "presentation": "corrupted",
      "corruption_rules": [
        {"rule_id": "cr_class_line", "mode": "recolor", "line_index": 2, "token_index": 1, "trigger": {"axis_at_least": {"axis": "recognition_drift", "value": 2}}, "severity": 1, "replacement_seed_id": "seed_s107", "text_note": "글자색이 아니라 분류어 자체가 바뀐다."}
      ]
    }
  ],
  "reading": {"background_mode": "dim_world", "world_visible_ratio": 0.35, "advance": "page", "max_lines_per_page": 9, "min_font_size": 20, "requires_advance_affordance": true},
  "post_read": {"effect_ids": ["eff_r4_document_read"], "once": true},
  "revisit": "allowed",
  "seed_ids": ["seed_s019", "seed_s107"]
}
```

허용 key: 12개.

검증:

- `availability.reached_by` enum: `prop`, `victory_award`, `shop`, `pickup`, `npc_gift`, `scripted`. `prop`이면 `reached_by_ref`는 `prop_*`를 참조. `victory_award`/`shop`/`pickup`/`npc_gift`이면 `equipment_*`/`item_*`를 참조. `scripted`이면 `reached_by_ref`가 없어야 하고 `availability.condition`가 `{}`가 아니어야 한다 → `scripted_document_needs_condition`.
- `pages` 1..12개, `page_id` 파일 내 유일.
- **`pages[].lines`는 1..`reading.max_lines_per_page` 개. 정본 상한은 `9`이며(정본 `09` §7.1/`10` §1.4), 더 작은 값은 허용한다.**
  - `max_lines_per_page`가 9보다 크면 `document_cap_overridden` error. `index.options.document_page_line_cap`보다 크게 선언해 presentation 여유를 content가 먹는 것은 금지다.
  - `max_lines_per_page`가 9보다 작으면 그 값이 그 document의 상한이 된다(더 엄격한 것은 허용).
  - 어떤 page가 상한을 넘으면 `document_page_overflow` error.
  - **cap 9는 `09` §7.1의 9-line body 예산(`maximum body lines: 9`)과 충돌하지 않는다.** 여유는 presentation 물리 예산이고, authored cap은 9다. `10`의 `test_document_pages_never_exceed_nine_line_cap`가 authored 쪽을, `test_document_pages_fit_advance_and_respect_nine_line_cap`가 화면 쪽을 각각 확인한다.
- `pages[].lines[]` 각 줄은 64자 이하 → `document_line_too_long`. localisation이나 player-entered name이 길어지는 경우를 위한 상한이다.
- `presentation` enum: `plain`, `redacted`, `corrupted`. `corrupted`이면 `corruption_rules` 비어 있으면 안 된다 → `corrupted_page_without_rule`. `plain`/`redacted`인데 `corruption_rules`가 있으면 `corruption_rule_on_plain_page` error.
- `corruption_rules[].rule_id` 파일 내 유일.
- `corruption_rules[].mode` enum: `recolor`, `replace_token`, `shatter_line`, `drop_glyph`. 네 값 모두 A~H의 G 화면에서 관찰된 corruption 표상과 대응한다: 색 변화, 문자 깨짐, 줄 분리, 문자 누락.
- **`mode == "recolor"` 또는 `"replace_token"`이면 `text_note`가 필수** → `color_only_communication` error. `text_note`는 색이 아닌 channel이다.
- `mode == "shatter_line"`이면 `line_index` 필수, `mode == "drop_glyph"`이면 `line_index` + `token_index` 필수. 범위를 벗어나면 `corruption_out_of_range`.
- `severity` int 1..3. `trigger`가 `{}`면 처음부터 corruption 상태다. 허용하되 `presentation == "corrupted"`인데 모든 rule의 trigger가 `{}`이면 `corruption_without_state_driver` **warning**.
- `replacement_seed_id`가 있으면 `seed_*`를 참조하고 그 class는 `TONE` 또는 `ONEOFF`이어야 한다 → `corruption_seed_class_mismatch`.
- **corruption은 매번 random typo를 생성하지 않는다.** `corruption_rules[]`는 authored data이고 runtime RNG를 쓰지 않는다(`10`의 `test_corruption_rules_are_authored_and_deterministic`). content에 `random`/`rng`/`seed_offset` 같은 key가 있으면 `content_randomizes_corruption` error.
- `reading.background_mode` enum: `dim_world`, `full_dark`. `world_visible_ratio` float 0.0..1.0, 0.05 단위로 반올림. `full_dark`이면 0.0이어야 한다 → `world_ratio_on_full_dark`.
- `reading.advance` enum: `page`, `auto`. `requires_advance_affordance == false`는 `auto`에서만 허용 → `advance_affordance_without_auto` warning. A~H의 하단 진행 삼각형 affordance를 유지한다.
- `reading.min_font_size` int 16..32. **20 미만이면 `document_font_below_floor` error** — 720p 하한을 content가 넘지 못하게 한다.
- `post_read.once == true`이면 `revisit`는 `allowed`여야 한다 → `once_document_blocks_revisit` error.
- `revisit` enum: `allowed`, `blocked_after_corruption`, `once`. `blocked_after_corruption`이면 `corruption_rules`가 있는 page가 최소 1개 → `revisit_rule_without_corruption` error.
- `seed_ids`/`audit_note` ungrounded rule은 §5.3과 동일.
- `owner_npc_id`는 §9.3의 `nullable_reference_slots` 8번이다(null 허용: 주인이 기관).

### 5.15 `phases` — PhaseDefinition

BS2 §7.3. **"새 phase를 만들기 위해 combat algorithm을 수정하지 않는다"**를 여기서 보장한다.

```json
{
  "schema_version": 1,
  "id": "phase_audit_ox_second_hearing",
  "display_name": "제2 청문",
  "owner_enemy_id": "enemy_audit_ox",
  "index": 2,
  "trigger": {"kind": "previous_phase_complete", "condition": {}},
  "enter": {"effect_ids": ["eff_audit_charge_ready"], "status_ids": ["st_charge_lock"], "invulnerable_windows": 0, "arena_override": {"arena_key": "arena_r4_observation_hall", "boundary_mode": "hard"}},
  "overrides": {"action_add_ids": ["act_audit_charge"], "action_remove_ids": [], "stat_overrides": {"agility": 15}, "resistance_add_status_ids": ["st_ink_bloom"], "resistance_remove_status_ids": [], "signature_action_id": "act_audit_charge", "telegraph_gain_windows": 1},
  "roster": {"add_enemy_ids": ["enemy_melted_index"], "remove_enemy_ids": [], "count_overrides": []},
  "completion": {"kind": "reduce_owner_hp_to", "hp_ratio_at": 20},
  "next_phase_id": null
}
```

검증:

- `index` int 1..12. **같은 `owner_enemy_id` 안에서 1부터 연속** → `phase_index_gap`. `index == 1`은 `trigger.kind == "previous_phase_complete"`일 수 없다 → `first_phase_self_trigger`.
- `index == 1`인 phase의 `next_phase_id`는 `null`이거나 `index == 2`인 phase id여야 한다. 그 이상은 `phase_chain_skip` error.
- `next_phase_id`는 `index`가 더 큰 phase만 가리킬 수 있다 → `phase_forward_reference` error. 이것이 §7.2에서 "kind 내부 순서 제약"으로 예외를 두는 유일한 경우다.
- `next_phase_id` chain에 cycle 불가 → `phase_cycle` error.
- `index < owner의 max index`인데 `next_phase_id == null`이면 `phase_chain_broken` error.
- `trigger.kind` enum: `hp_ratio`, `cumulative_hp_loss`, `window_count`, `story_flag`, `linked_actor_death`, `previous_phase_complete`. 이 6개는 BS2 §7.3이 직접 확인한 trigger 목록과 1:1이다. kind별 필수/금지 key:

  | kind | 필수 | 금지 |
  |---|---|---|
  | `hp_ratio` | `hp_ratio_at` (int 1..99) | `window_count_at`, `story_flag_key`, `linked_enemy_id` |
  | `cumulative_hp_loss` | `hp_ratio_at` (int 1..99) | `window_count_at`, `story_flag_key`, `linked_enemy_id` |
  | `window_count` | `window_count_at` (int 1..99) | `hp_ratio_at`, `story_flag_key`, `linked_enemy_id` |
  | `story_flag` | `story_flag_key` (`world_` prefix) | `hp_ratio_at`, `window_count_at`, `linked_enemy_id` |
  | `linked_actor_death` | `linked_enemy_id` | `hp_ratio_at`, `window_count_at`, `story_flag_key` |
  | `previous_phase_complete` | 없음 | `hp_ratio_at`, `window_count_at`, `story_flag_key`, `linked_enemy_id` |

  `cumulative_hp_loss`와 `hp_ratio`의 필수 key가 같은 것은 의도적이다. BS2 §7.3이 "HP ratio"와 "cumulative HP loss"를 서로 다른 trigger로 나열하지만 authored 데이터로는 둘 다 누적 HP 감소량을 percent로 표현한다. **의미 차이는 `enter`/`completion`의 해제 순서에 남기고, trigger 입력은 공유한다.** 구분 없이 새 trigger를 만들지 않기 위해 두 값을 하나의 표현으로 통일했다.

  **금지 key는 `null`이어도 위반이다.** 금지 필드는 key 자체가 없어야 한다(§2.4). 이 schema의 모든 "금지" 규칙이 이 원칙을 따른다.
- `condition`은 모든 kind에서 선택이며 `{}`일 수 있다.
- `enter.invulnerable_windows` int 0..3. `enter.arena_override`가 있으면 `arena_key`는 자유 snake_case, `boundary_mode` enum: `none`, `soft`, `hard`.
- `overrides.action_add_ids` ∩ `action_remove_ids` = ∅ → `action_override_conflict`.
- `overrides.resistance_add_status_ids` ∩ `resistance_remove_status_ids` = ∅ → `resistance_override_conflict`.
- `overrides.action_add_ids`의 action은 `owner`가 `enemy`여야 한다 → `phase_adds_player_action` error.
- `overrides.stat_overrides`는 §5.5의 `STAT_KEYS` 9개만, value int 0..9999(가산 delta). `max_ap` 불가.
- `overrides.signature_action_id`가 있으면 그 action의 `precondition.required_phase_ids`에 이 phase가 들어 있어야 한다 → Stage 3 `phase_signature_unwired`. 동시에 `action_add_ids`에도 있으면 `phase_signature_duplicate` error.
- `roster.add_enemy_ids` ∩ `remove_enemy_ids` = ∅ → `roster_override_conflict`. `count_overrides[]`는 `{ "enemy_id": "enemy_...", "count": int 1..12 }`이며 파일 내 `enemy_id` 유일.
- `roster.add_enemy_ids`의 enemy는 `context.region_id`에 속해야 한다 → `enemy_region_mismatch`.
- `completion.kind` enum: `owner_dead`, `survive_windows`, `reduce_owner_hp_to`, `linked_actors_cleared`.

  | kind | 필수 | 금지 |
  |---|---|---|
  | `owner_dead` | — | `windows`, `hp_ratio_at`, `linked_enemy_id` |
  | `survive_windows` | `windows` (int 1..99) | `hp_ratio_at`, `linked_enemy_id` |
  | `reduce_owner_hp_to` | `hp_ratio_at` (int 1..99) | `windows`, `linked_enemy_id` |
  | `linked_actors_cleared` | `linked_enemy_id` | `windows`, `hp_ratio_at` |

  위반은 `completion_key_mismatch`. `reduce_owner_hp_to`의 `hp_ratio_at == 0`은 `completion_hp_ratio_zero` error.
- **새 phase의 유일한 표현 수단은 위 key들이다.** 여기에 없는 동작(예: "phase마다 AI 우선순위를 바꾼다")이 필요하면 §12.3의 schema bump 절차를 탄다. combat algorithm에 content 전용 분기를 넣는 것은 금지된다.

### 5.16 `enemies` — EnemyDefinition

constitution §8 + BS2 §7.

```json
{
  "schema_version": 1,
  "id": "enemy_audit_ox",
  "display_name": "Audit Ox",
  "role": {"base_region_id": "region_r4_crownwell_archive", "region_secondary": "region_r7_hollow_orchard", "region_role": "translation_precedence", "institution_id": "institution_r4_record_office", "role_tags": ["custodian", "paperwork"]},
  "body": {"body_class": "humanoid", "silhouette_key": "sil_audit_ox", "scale_class": "human", "stateful_body": "open_close", "motion_signature": "ledger_sweep"},
  "stats": {"max_hp": 220, "agility": 12, "action_slots": 1, "resource_pool": {"mp": 40, "equipment_charge": 0}},
  "condition_bar": {"kind": "condition_progress", "max_value": 100, "start_value": 0, "advance_on": ["hp_damage_taken", "window_elapsed"], "advance_per_source": 12, "decrease_on_phase_enter": 30},
  "baseline_action_ids": ["act_audit_ledger_sweep", "act_audit_ledger_file"],
  "signature_action_id": "act_audit_charge",
  "telegraph": {"signature_tell_key": "tell_audit_charge", "channels": ["pose", "numeric_bar"]},
  "status_profile": {"innate_status_ids": ["st_recorded"], "resistant_status_ids": ["st_ink_bloom"], "immune_status_ids": []},
  "break_profile": {"breakable": true, "break_source_action_ids": ["act_audit_charge"], "on_break_status_ids": ["st_misnamed"], "on_break_effect_ids": ["eff_audit_charge_broken"]},
  "phase_ids": ["phase_audit_ox_second_hearing"],
  "linked_actors": [
    {"enemy_id": "enemy_melted_index", "max_count": 2, "timing": "phase_enter", "role": "guard", "on_owner_death": "die_with", "on_actor_death": "none", "lifetime_windows": 0, "is_true_target": false}
  ],
  "reward": {"equipment_ids": ["equipment_archive_seal_plate"], "item_ids": ["item_blank_form"], "resource_delta": {"mp": 2}, "access_key": "gate_g8_crown_precedence"},
  "aftermath": {"effect_ids": ["eff_ilyra_recorded_as_artifact"], "region_state_tag": "r4_filed"},
  "lore_ref": "seed_s056",
  "seed_ids": ["seed_s056", "seed_s065"]
}
```

검증:

- **`role` 허용 key 6개**: `base_region_id`, `region_secondary`, `region_role`, `institution_id`, `role_tags`. `base_region_id`는 필수, `region_secondary`는 optional이다. **이전 `region_ids[]` 배열은 삭제한다** — `05` §2.6이 두 region에 걸치는 record를 record 단위 `region_secondary`로 표현하도록 정했고, catalog가 "어느 쪽인가"를 추측하지 않는다.
- `role.role_tags` 1..8개 자유 snake_case. **`role.role_tags`가 비면** `enemy_without_role` error. R09("모든 enemy는 region/resource/order 안에서 역할을 수행한다")의 강제 지점이다.
- **`role.region_role`은 `region_role` 중 하나여야 하고, `role.base_region_id`의 region의 `region_role`과 일치해야 한다** → `enemy_region_role_mismatch`. `region_secondary`가 있으면 **그 region의 `region_role`과도 일치해야 한다** → `enemy_secondary_region_role_mismatch`. `05`의 옛 shorthand key(`R-ARCHIVE` 등)는 retired이고 content에 나타나면 `unrekeyed_planning_id` error다(§3.5.4).
- `role.region_secondary`는 있으면 `base_region_id`와 달라야 하고 §3.5.1의 9개 `region_*` 중 하나여야 한다 → `self_region_link` / `region_secondary_not_canonical` error.
- **`R-LATENCY`의 확정 분할**: faith-as-latency·care latency·signal relay는 `region_r3_bellhouse_hospice`(`intervention_scheduling`), boot·permit·transformation service는 `region_r5_glasswing_ordinal`(`permission_before_transformation`). 어느 record도 이 분할을 다시 만들지 않는다.
- **magic 층의 유일한 새 family**는 `enemy_grading_wall`(§3.5.4)이고 `base_region_id: region_r8_folding_school`, `region_role: magic_training_craft_labor`, `region_secondary: region_r5_glasswing_ordinal`(medium·fold count·blade 구조를 제공) + `boundary_crown_precedence`(`R7`의 미완성 cut)이 `05` §2.6의 확정 분할이다. wall의 `role.role_tags`는 `instrument`/`grader`/`civic_measurement` 중에서만 고르고 `summoner`/`rival_mage`를 쓰지 않는다 → `enemy_role_tag_not_magic_layer`.
- `body.body_class` enum: `humanoid`, `cluster`, `architectural`, `avian`, `corpse`, `composite`, `abstract`. `body.stateful_body` enum: `none`, `open_close`, `split_merge`, `transform`. `body.scale_class` enum: `small`, `human`, `large`, `architectural`.
- **`abstract` body_class도 `role.role_tags`와 `signature_action_id`를 반드시 가져야 한다.** `abstract`인데 `body.motion_signature`가 비면 `enemy_abstract_without_motion` error. 외형-only weirdness 금지.
- `stats.max_hp` int 1..99999, `stats.agility` int 1..999, `stats.action_slots` int 1..3. `resource_pool` key는 §2.7의 3개, value int 0..9999. **`max_ap`는 없다** → `resource_key_forbidden`.
- **`condition_bar`이 `target_hp_or_condition`의 데이터 원천이다** (§4.4.2):
  - `kind` enum: `hp`, `condition_progress`, `stability`.
  - `max_value` int 1..9999, `start_value` int 0..`max_value`.
  - `advance_on`는 `hp_damage_taken`, `hp_damage_dealt`, `window_elapsed`, `status_applied` 의 부분집합(최소 1개), 파일 내 유일.
  - `advance_per_source` int 0..999. `decrease_on_phase_enter` int 0..9999(없으면 default 0).
  - `kind == "hp"`이면 `condition_bar`를 두지 않는다. player/actor HP bar와 별개 UI를 만들지 않는다 → `condition_bar_on_hp_kind` error. `hp`는 actor HP가 이미 담당하므로 **enemy가 `kind: "hp"` bar를 선언하면 중복이다.**
  - `kind`가 `condition_progress`/`stability`인데 `advance_on`이 비면 `condition_bar_without_advance` error. **값이 advance되지 않는 bar를 만들지 않는다.**
  - content는 bar의 **위치·색·크기**를 갖지 않는다. presentation이 `09` §4.3/§4.4가 정한 위치에 projection만 그린다.
- `baseline_action_ids` 1..12개, 파일 내 유일. `signature_action_id`가 그 안에 있으면 `signature_not_distinct` **error**(BS2 §7.1).
- `baseline_action_ids`/`signature_action_id`의 `owner`는 `enemy` 또는 `linked_actor`여야 한다 → Stage 3 `enemy_uses_player_action`.
- `telegraph.channels`는 §5.5의 telegraph channel 부분집합, 최소 1개.
- `status_profile`의 세 배열은 `st_*`를 참조. `resistant ∩ immune = ∅` → `enemy_resistance_conflict`. `innate ∩ immune = ∅` → `enemy_immune_and_innate`.
- `break_profile.breakable == true`이면 `break_source_action_ids`가 **비어 있으면 안 된다** → `breakable_without_source` error.
- `break_source_action_ids`의 action은 `break_spec`이 있고 `counters.breakable == true`여야 한다 → Stage 3 `break_source_without_payload`.
- `break_profile.breakable == false`이면 `break_source_action_ids`는 비어 있어야 한다 → `unbreakable_with_break_source`. `on_break_status_ids`/`on_break_effect_ids`도 비어 있어야 한다.
- **`scale_class`가 `large` 또는 `architectural`이면 `phase_ids`가 비어 있으면 안 된다** → `major_enemy_without_phase` error.
- `phase_ids` 1..6개, 파일 내 유일, `phase_*`를 참조. 각 phase의 `owner_enemy_id`가 이 enemy여야 한다 → Stage 3 `phase_owner_mismatch`.
- `linked_actors[]` 0..4개:
  - `enemy_id`가 자기 자신이면 `self_link` error
  - `max_count` int 1..12
  - `timing` enum: `encounter_start`, `phase_enter`, `hp_step`, `periodic`
  - `timing == "hp_step"`이면 `hp_step_percent` int 1..99 필수, 그 외 timing에서는 없어야 한다 → `linked_actor_timing_mismatch`
  - `timing == "periodic"`이면 `lifetime_windows` int 1..99가 필요하거나 `on_actor_death == "summon_replacement"`여야 한다 → `linked_actor_periodic_unbounded` error
  - `role` enum: `guard`, `pressure`, `true_actor`, `support`, `decoy`, `linked_actor`
  - **`role == "linked_actor"`은 `01`/resolution의 linked-actor roster role이다.** `intent.target_mode`으로 쓰지 않는다. 이 값은 `encounter.target_priority[].role`과 같은 vocabulary를 쓴다.
  - `on_owner_death` enum: `die_with`, `survive`, `flee`, `revive_changed` (BS2 §7.4의 4 lifecycle)
  - `on_actor_death` enum: `none`, `protect_owner`, `summon_replacement`, `become_true_target`
  - `role == "true_actor"`이면 `is_true_target == true`, 아니면 `false` → `linked_actor_true_target_mismatch`
  - **catalog 전체에서 `is_true_target: true`인 linked actor는 최대 1개** → `multiple_true_actors` error
- `reward.access_key`는 `gate_g*` 또는 `equipment_*` id. `gate_`이면 region `exits[].gate_id`에 존재해야 한다 → Stage 3 `unknown_access_key`.
- `reward.equipment_ids`는 `equipment_*`를 참조, 0..4개. `reward.item_ids`는 `item_*`를 참조, 0..4개. `reward.resource_delta`는 §2.7의 3개 key, int 0..9999.
- **`aftermath.effect_ids`는 비어 있으면 안 된다** → `enemy_without_aftermath` error. R09의 aftermath.
- `lore_ref`가 있으면 `seed_ids`에 포함되어야 한다 → `lore_ref_not_in_seed_ids` error.
- `seed_ids`/`audit_note` ungrounded rule은 §5.3과 동일.

### 5.17 `encounters` — EncounterDefinition

BS2 §8.4 + §7.5 variant/remix + `05` §6의 group/NPC-conversion 템플릿.

```json
{
  "schema_version": 1,
  "id": "enc_r4_translation_drift",
  "display_name": "번역 이동",
  "context": {"region_id": "region_r8_folding_school", "region_secondary": "region_r5_glasswing_ordinal", "region_role": "magic_training_craft_labor", "depth_band": 0, "story_stage": "late", "time_of_day": "institutional"},
  "activation": {"kind": "quest_add", "prop_id": "prop_r4_low_level_stacks", "eligibility": {"clock_at_least": {"clock_id": "clock_public_record", "stage_index": 0}}, "warning": {"channel": "sound", "windows_before": 1}},
  "visibility": {"visible_in_field": false, "shown_on_map": false},
  "roster": [
    {"entry_id": "r1", "enemy_id": "enemy_audit_ox", "count": 1, "count_variant": 0, "loadout_ids": [], "target_priority": 1, "spawn_at": "start"}
  ],
  "target_priority": [{"enemy_id": "enemy_audit_ox", "role": "true_actor", "priority": 1, "only_when": {}}],
  "target_roles": [
    {"role": "record", "surface_id": "doc_r8_course_index_row", "descendants_only": true},
    {"role": "resource_node", "surface_id": "res_disperser_charge", "descendants_only": false}
  ],
  "group": null,
  "allow": {"escape": true, "skip": false, "parley_encounter_id": "enc_r4_counter_proof", "noncombat_encounter_id": "enc_r4_counter_proof"},
  "clock_pressure": [{"clock_id": "clock_institutional_response", "ticks_on_start": 0, "ticks_per_window": 1, "ticks_on_end": 1}],
  "outcome": {
    "on_victory": {"effect_ids": ["eff_ilyra_files_contradictory_copy"]},
    "on_escape": {"effect_ids": []},
    "on_failure": {"effect_ids": [], "death_policy": "recover_event", "recovery_event_id": "rec_r4_translation_reentry"},
    "on_parley": {"effect_ids": ["eff_ilyra_signature_taken"]}
  },
  "world_effect": {"region_state_tag": "r4_filed", "prop_state_ids": ["prop_r4_low_level_stacks"], "unlock_gate_ids": ["gate_g8_crown_precedence"]},
  "repeat": {"policy": "once", "reset_policy": "none", "cooldown_windows": 0, "depth_scaling": {"per_band": {}, "max_bands": 0}},
  "base_encounter_id": null,
  "variant_overrides": {},
  "remix_eligibility": {"condition": {}, "requires_depth_band_min": 0, "requires_postgame": false},
  "lore_ref": "seed_s056",
  "seed_ids": ["seed_s056"]
}
```

검증:

- `context.region_id`는 `region_*`를 참조. **`context.region_role`은 그 region의 `region_role`과 정확히 같아야 한다** → `encounter_region_role_mismatch`. `context.region_secondary`는 optional이고, 있으면 해석돼야 하며 `region_id`와 달라야 한다 → `region_secondary_not_canonical` / `self_region_link` error. §5.16과 같은 record-level 규칙이다.
- `context.depth_band` int 0..20. `context.story_stage` enum: `open`, `mid`, `late`, `postgame`. `time_of_day` enum: `any`, `day`, `night`, `institutional`.
- `activation.kind` enum: `field_trigger`, `scripted`, `quest_add`, `npc_conversion`, `boss_gate`, `remix`. kind별 필수/금지 key:

  | kind | 필수 | 금지 |
  |---|---|---|
  | `field_trigger` | `prop_id` | `gate_id` |
  | `scripted` | — | `prop_id`, `gate_id` |
  | `quest_add` | `prop_id` | `gate_id` |
  | `npc_conversion` | `npc_id` | `prop_id`, `gate_id` |
  | `boss_gate` | `gate_id` | `prop_id` |
  | `remix` | `base_encounter_id` | `prop_id`, `gate_id` |

  위반은 `activation_key_mismatch`. `activation.kind == "remix"`이면 `base_encounter_id`가 필수여야 하고, 아니면 `base_encounter_id`는 `null`이어야 한다 → `remix_base_mismatch`.
- `activation.eligibility`는 `{}`일 수 있다.
- `activation.warning.channel` enum: `none`, `vfx`, `sound`, `npc_warning`. `channel != "none"`이면 `windows_before` int 0..3 필수 → `warning_without_timing`.
- `roster` 1..12개, `entry_id` 파일 내 유일. `count` int 1..12, `count_variant` int 0..8, `count + count_variant <= 12` → `roster_cap_exceeded`. `spawn_at` enum: `start`, `phase_enter`.
- `roster[].loadout_ids`는 `equipment_*`를 참조. `roster[].target_priority` int 1..99, 파일 내 유일.
- **모든 `roster[].enemy_id`의 `role.base_region_id`는 `context.region_id`여야 한다** → `enemy_region_mismatch` error. roster 복붙 사고를 잡는다. `role.region_secondary`는 `context.region_secondary`와 같아야 한다 → `enemy_secondary_region_role_mismatch` warning.
- **`roster[].enemy_id`의 `phase_ids`가 비어 있고 `roster.size() > 1`이면** `encounter_without_escalation` warning.
- `target_priority[]`는 비어도 된다(roster priority 사용). 있으면 `enemy_id` 파일 내 유일, `priority` 파일 내 유일, `only_when`가 `{}`인데 priority가 두 번이면 `target_priority_ambiguous` error.
- `target_priority[].role` enum: `true_actor`, `linked_actor`, `support`, `decoy`, `aggro`. **`linked_actor`은 여기서 roster 안의 linked-death/target-priority role이다**(§5.16).
- **`target_roles[]`가 encounter-level target role의 집합이다.** `role` enum은 `record`, `route`, `resource_node` **3개로 닫힌다**. `surface_id`는 `doc_*`/`prop_*`/`gate_g*`/`equipment_*`/`res_*` 중 해당 role에 맞는 ID를 참조한다.
  - `record` → `doc_*` 또는 `prop_*`; `route` → `gate_g*`; `resource_node` → `prop_*` **또는** `res_*`. 불일치 → `target_role_surface_mismatch`. `resource_node`이 `res_*`를 받는 것은 `R8`의 `resource_node:node disperser stock`(`res_disperser_charge`)이 저장 대상이 stock이기 때문이다. `res_*`는 §6.3 registry에 있어야 하고 definition file이 없으므로 "해석"이 아니라 **registry membership 검사**다.
  - `role == "record"`이면 `descendants_only`는 `true`여야 한다 → `target_role_not_descendant_only` error. record 표적은 서브 항목이지 표적 자신이 아니다. `resource_node`은 `false`가 정상이다.
  - `target_roles[]`는 `SELF`/`ONE_ENEMY` 같은 `act_*.intent.target_mode`으로 쓰이지 않는다 → `target_role_used_as_target_mode` error(`10`의 `test_encounter_level_target_roles_are_not_action_target_modes`).
  - **`target_roles[]`는 body도 HP pool도 일곱째 target mode도 아니다**(`05` §2.8.1). `damage_payload`를 이 표의 surface에 향하게 하면 `target_role_takes_damage` error.
- **`group`은 `05` §6.1의 group 템플릿이 적용되는 자리다.** group은 별도 kind가 아니고 **기존 enemy/action record의 roster composition**이다.
  - `group == null`이면 `group_*` key가 없어야 한다 → `group_field_on_null`.
  - `group`이 있으면 `group_id`(자유 snake_case, `GRP-ARPG-01`–`GRP-ARPG-05` 재키), `anchor_enemy_id`, `link_policy`(자유 snake_case), `phase_wave`(int 0..4), `status_policy`(`st_*` 0..4개), `resource_budget`(§2.7의 3개 key), `reward_policy`(`reward`와 동일 shape)만 가진다. `group_id`가 catalog에서 유일해야 한다 → `duplicate_group_id`. **`GRP-ARPG-06`–`GRP-ARPG-12` 범위는 retired**이므로 여섯 번째 이후의 id가 나오면 `unrekeyed_planning_id` error(§3.5.4).
  - `group.roster`를 다시 정의하지 않는다. `05` §6.1이 "group은 기존 family/action record 위의 roster composition이며 새 enemy implementation을 만들지 않는다"고 명시했고, `10`의 `test_remix_reuses_existing_actor_action_and_encounter_core`가 검사한다.
  - `group.anchor_enemy_id`는 `roster[]`에 있어야 한다 → `group_anchor_not_in_roster`.
  - **magic 층은 group을 추가하지 않는다.** `enc_fold_that_refuses_the_hand`는 `FAM-ARPG-19` ×1 + `FAM-ARPG-02` ×1로 roster를 직접 구성하고 `group`은 `null`이다.
- `allow.parley_encounter_id`/`noncombat_encounter_id`는 `enc_*`를 참조. 자기 자신 금지 → `encounter_self_reference`. `noncombat_encounter_id`가 있으면 그 encounter의 `allow.skip`은 `true`여야 한다 → Stage 3 `noncombat_encounter_not_skippable`.
- `clock_pressure` 0..6개, `clock_id` 파일 내 유일. **같은 clock의 `ticks_per_window` 합이 3을 넘으면** `clock_pressure_overload` error.
- `clock_pressure[].ticks_*`는 int 0..9. 셋이 모두 0이면 해당 entry는 `clock_pressure_null_entry` error.
- `outcome`은 `on_victory`, `on_escape`, `on_failure`, `on_parley` **4개 전부 필수**.
- `allow.parley_encounter_id`가 있는데 `on_parley.effect_ids`가 비어 있으면 `parley_without_consequence` error.
- **`outcome.on_victory.effect_ids`는 비어 있으면 안 된다** → `encounter_without_world_effect` error.
- `outcome.on_failure.death_policy` enum: `respawn_checkpoint`, `recover_event`. `recover_event`이면 `recovery_event_id` 필수, 그 외는 없어야 한다 → `death_policy_recovery_mismatch`. **`game_over`는 열거에 없다.** 이 Kit은 항상 recovery 경로를 갖기 때문이다. 쓰려면 schema bump가 아니라 `08`과의 계약 renegotiation이 필요하다.
- `world_effect.unlock_gate_ids`는 region `exits[].gate_id`에 존재해야 한다.
- **`on_victory.effect_ids` + `world_effect`(비어 있지 않으면)는 최소 하나의 world/npc/relationship 변화를 만들어야 한다** → `encounter_without_world_change` error.
- `repeat.policy` enum: `once`, `repeatable`, `once_per_run`, `escalating`.
  - `once` ⇒ `reset_policy == "none"` && `depth_scaling.max_bands == 0` → `repeat_policy_mismatch`
  - `once_per_run` ⇒ `depth_scaling.max_bands == 0` → `repeat_policy_mismatch`
  - `repeatable` ⇒ `reset_policy != "none"` → `repeatable_without_reset`
  - `escalating` ⇒ `depth_scaling.max_bands >= 1` → `repeat_policy_mismatch`
  - `cooldown_windows` int 0..99
  - `reset_policy` enum: `none`, `on_region_leave`, `on_death_recovery`, `on_recovery_event`
  - `depth_scaling.max_bands == 0`이면 `per_band`는 **빈 object여야 한다** → `depth_scaling_without_bands`. `max_bands >= 1`이면 `per_band`가 비어 있으면 안 된다.
  - `depth_scaling.per_band`는 `max_hp_pct` int 0..50, `agility_delta` int -9..9, `action_add_ids`(id list)만 허용
- `base_encounter_id`가 `null`이면 `variant_overrides`는 `{}`여야 한다 → `override_without_base` error. `group`도 `null`이어야 한다 → `group_without_base` error.
- `base_encounter_id`가 있으면 (`05` §6.2 variant 템플릿의 landing):
  - 자기 자신 금지 → `remix_self_base`
  - `variant_overrides` 비어 있으면 안 됨 → `remix_without_override` error
  - base encounter도 `base_encounter_id`를 가질 수 없음 → `nested_remix` error. **remix 깊이는 1단계로 고정**(§7.3)
  - `variant_overrides` 허용 key: `roster_add`(배열 of `{enemy_id, count}`), `action_add_ids`, `stat_pct`(`max_hp`/`agility`, int -50..200), `reward_add_equipment_ids`, `phase_id_override`. **roster 자체를 다시 정의할 수 없다** → `remix_redefines_roster` error.
  - variant는 해결책을 제거하거나 숨기지 않는다. `known_solution_tags`는 §5.17의 `variant_overrides`에 `known_solution_tags`(자유 snake_case 1..6개) key로 넣는다 → `variant_without_known_solution` error.
  - `remix_eligibility.condition`이 `{}`이고 `requires_postgame == false`이면 `remix_always_on` warning.
- `roster_add`가 참조하는 enemy도 `role.base_region_id`가 `context.region_id`여야 한다.
- `lore_ref`가 있으면 `seed_ids`에 포함 → `lore_ref_not_in_seed_ids` error. 그 외 ungrounded rule은 §5.3과 동일.
- **`05`의 field 11개(`ENC-ARPG-01`–`10` + `ENC-ARPG-25`) / boss 14개, group 5개, variant 6개, NPC-conversion 5개 템플릿이 모두 `enc_*`/`npc_*`로 resolve되어야 한다** → Stage 4 `encounter_catalog_incomplete` error. `10`의 `test_encounter_catalog_matches_05_counts_and_region_roles`가 개수와 region_role 대조를 한다.
- **`enc_fold_that_refuses_the_hand`(=`ENC-ARPG-25`)는 `R8`의 A1 data-only record다.** `context.region_id: region_r8_folding_school`, `context.region_role: magic_training_craft_labor`, `activation.kind: "field_trigger"`, `group: null`, `base_encounter_id: null`이어야 한다. 이 외의 모양이면 `r8_encounter_shape_off` error.
- **이 encounter와 `enemy_grading_wall`은 `02` §12 / `07` §14.1 A1의 `changed_core_files == []` 조건의 검수 대상이다.** `change_ledger` entry의 `changed_core_files`가 비어 있지 않으면 `magic_layer_changed_core` error. `05` §8의 "magic 층은 새 combat system을 추가하지 않는다"와 `02` §12의 `changed_core_files == []`를 함께 강제한다.

### 5.18 `equipment` — EquipmentDefinition

`PLAN_RESOLUTION` §7에 따라 이 문서가 schema를 소유한다. `01` §13.1/§13.2가 combat 의미(4 slot, quick-equip, derived query 순서)를 소유하고, 여기서는 필드 모양을 고정한다.

```json
{
  "schema_version": 1,
  "id": "equipment_archive_seal_plate",
  "display_name": "Archive Seal Plate",
  "slot": "accessory",
  "allow_empty": false,
  "floor_role": "resistance_behavior",
  "stat_modifiers": {"agility": 2, "guard_efficiency": 5},
  "resistances": {"physical_percent": 10, "magical_percent": 15, "affinity_percent": {"light": 20}},
  "status_grants": {"resistant_status_ids": ["st_audited"], "immune_status_ids": []},
  "defense": {"guard_power": 0, "guard_efficiency_bp": 300, "dodge_pressure": -5, "evasion": 3, "break_resistance": 10, "break_policy": "enabled"},
  "action_grants": {"basic_attack_action_id": "act_audit_ledger_sweep", "granted_action_ids": ["act_r4_counter_sever"], "no_turn_action_ids": ["act_r4_ward_switch"], "action_slot_delta": 0},
  "behavior_modifiers": {"reaction_modifier_ids": [], "escape_policy": "allowed", "break_response_policy": "stagger", "scheduler_turn_cost_delta": 0},
  "charge_pool": {"key": "equipment_charge", "max": 0, "start": 0},
  "field_keys": {"traversal_key": null, "pass_ids": []},
  "service": {"upgrade_service_id": null, "unlock_service_id": "service_r4_reentry_desk"},
  "acquisition": {"source_kind": "victory_award", "source_id": "enemy_audit_ox", "count": 1},
  "presentation": {"icon_key": "equipment_archive_seal_plate", "tint_key": "record_grey", "silhouette_key": "sil_seal_plate"},
  "seed_ids": ["seed_s058"]
}
```

허용 key: 17개(`schema_version`, `id`, `display_name`, `slot`, `allow_empty`, `floor_role`, `stat_modifiers`, `resistances`, `status_grants`, `defense`, `action_grants`, `behavior_modifiers`, `charge_pool`, `field_keys`, `service`, `acquisition`, `presentation`, `seed_ids`, `audit_note`).

검증:

- `slot` enum: `weapon`, `offhand`, `armor`, `accessory` 4개로 닫힘(`01` §13.1). `slot`이 없으면 `equipment_without_slot` error.
- `allow_empty`가 `false`인 slot에 빈 장비 상태를 허용하지 않는다 → core가 `slot`을 검사한다. content는 `allow_empty`만 선언한다.
- **`floor_role` enum: `weapon_basic_attack`, `granted_active_skill`, `resistance_behavior`, `action_slot_source`, `field_pass_key`, `no_turn_item_source`.** 6개 중 5개(`weapon_basic_attack`, `granted_active_skill`, `resistance_behavior`, `no_turn_item_source`, `field_pass_key`)가 `01` §13.4의 floor 목록이고, `action_slot_source`는 `01` §13.2/§13.3과 `EQUIP-E04`가 요구하는 6번째 floor다.
  - **catalog 전체에서 6개 `floor_role`이 각각 최소 1개 정의에서 등장해야 한다** → `equipment_floor_role_missing` error(`10`의 `test_equipment_floor_reuses_action_economy`).
  - `floor_role == "field_pass_key"`이면 `field_keys.traversal_key`가 `null`이 아니거나 `field_keys.pass_ids`가 비어 있으면 안 된다 → `field_pass_key_without_key`.
  - `floor_role == "action_slot_source"`이면 `action_grants.action_slot_delta != 0` 필수 → `action_slot_source_without_delta`. **이 modifier는 다음 command window부터 적용된다**(`01` §13.3)이고 content가 그 지연을 표현할 key를 갖지 않는다.
  - `floor_role == "no_turn_item_source"`이면 `action_grants.no_turn_action_ids`가 비어 있으면 안 된다 → `no_turn_source_without_action`. 그 action의 `cost.turn_cost`는 0이어야 한다 → Stage 3 `no_turn_action_not_zero_turn_cost`.
  - `floor_role == "granted_active_skill"`이면 `action_grants.granted_action_ids`가 비어 있으면 안 된다 → `granted_skill_without_action`.
- `stat_modifiers` key는 §5.5의 `STAT_KEYS` 9개로 닫힌다, value int -9999..9999. **`max_ap`는 없다** → `resource_key_forbidden`.
- `resistances.physical_percent`/`magical_percent` int 0..100. `affinity_percent` key는 §4.4.1의 `affinity` 6개로 닫힌다(`none` 제외), value int 0..100. **같은 장비 안에서 `physical_percent`와 `physical_resistance` 두 이름으로 쓰지 않는다.**
- `status_grants.resistant_status_ids` ∩ `immune_status_ids` = ∅ → `equipment_status_conflict`.
- `defense.guard_efficiency_bp` int -1000..1000 (basis point). `defense.dodge_pressure` int -99..99 (음수 허용: 내 dodge roll을 낮춘다). `break_policy` enum: `enabled`, `immune`, `resistant`.
- `action_grants.basic_attack_action_id`가 있으면 그 action의 `category`가 `attack`여야 한다 → `basic_attack_wrong_category`. `granted_action_ids` 0..4개, `no_turn_action_ids` 0..4개, 파일 내 유일.
- `action_grants.action_slot_delta` int -1..1. **1이면 `floor_role == "action_slot_source"`여야 한다** → `slot_delta_without_floor_role`.
- `behavior_modifiers.escape_policy` enum: `allowed`, `blocked`, `policy_authored`. `break_response_policy` enum: `stagger`, `hold`, `recoil`. `scheduler_turn_cost_delta` int -1..0(음수면 0으로 clamp, `01` §8.2는 cost를 줄이는 modifier를 scheduler에 정의하지 않음) → `scheduler_delta_negative` error.
- `charge_pool.key`는 §2.7의 3개 key 중 `equipment_charge`만 허용 → `charge_pool_wrong_key`. `max` int 0..99, `start` 0..`max`. `max == 0`이면 `charge_pool`이 없어야 한다 → `empty_charge_pool_declared`.
- `field_keys.traversal_key`는 `res_*`(§6.3) id이거나 `null`. **`field_keys`는 `01`이 아니라 `02`가 소유하는 field resource vocabulary를 쓴다** → 미등록 key는 `unknown_field_resource_key`.
- `service.upgrade_service_id`/`unlock_service_id`는 자유 snake_case이고 `01`이 services를 소유하므로 여기서 해석하지 않는다.
- `acquisition.source_kind` enum: `victory_award`, `shop`, `pickup`, `npc_gift`, `scripted`. `victory_award`/`shop`이면 `source_id`는 `enemy_*`/`enc_*`/`prop_*`를 참조, `npc_gift`면 `npc_*`를 참조, `scripted`면 `source_id`가 없어야 하고 대신 `effect_id`가 필수 → `scripted_acquisition_without_effect`.
- `acquisition.count` int 1..9.
- `presentation`에 Color나 path가 있으면 `content_holds_presentation_value`.
- `seed_ids`/`audit_note` ungrounded rule은 §5.3과 동일.
- **equipment는 stat을 직접 바꾸지 않는다.** `01` §13.2의 "derived combat query는 항상 `base + equipment + status + temporary action modifier` 순서로 재계산한다"가 이 schema의 전제다. content가 `base_value`나 `current_value` 같은 runtime 값을 담으면 `equipment_holds_runtime_value` error.

### 5.19 `items` — ItemDefinition

`01` §13.4: item 사용은 target mode, resource cost, cooldown, status payload를 **ActionDefinition**으로 표현한다. 따라서 `item_*`는 그것을 **참조**하고 행동을 복제하지 않는다.

```json
{
  "schema_version": 1,
  "id": "item_blank_form",
  "display_name": "Blank Form",
  "item_class": "quest",
  "floor_role": "no_turn_item_source",
  "use": {"action_id": "act_r4_ward_switch", "consumed_on_use": true, "max_stack": 9},
  "field_use": {"service_id": "service_r4_reentry_desk", "traversal_key": null},
  "acquisition": {"source_kind": "shop", "source_id": "prop_r4_crown_observation_desk", "count": 1},
  "presentation": {"icon_key": "item_blank_form", "tint_key": "record_grey"},
  "seed_ids": ["seed_s004"]
}
```

허용 key: 9개(`schema_version`, `id`, `display_name`, `item_class`, `floor_role`, `use`, `field_use`, `acquisition`, `presentation`, `seed_ids`, `audit_note`).

검증:

- `item_class` enum: `consumable`, `cure`, `buff`, `pass`, `key_material`, `quest` 6개.
- **`use.action_id`는 필수**이고 그 action은 `category == "item"`이어야 한다 → `item_action_wrong_category`. `category: "item"`인 action이 `item_*`를 참조하지 않으면 Stage 4 `item_action_unlinked` warning.
- **item 사용 action의 `cost.turn_cost`는 0이어야 한다**(`01` §13.4의 "no-turn heal/cure/buff item"). 0이 아니면 `item_action_not_no_turn` error. 이 rule이 `10`의 `test_equipment_floor_reuses_action_economy`가 요구하는 "no-turn item"을 강제한다.
- 그 action의 `intent.target_mode`는 `SELF` 또는 `ONE_ENEMY`여야 한다 → `item_action_bad_target_mode`. `ALL_*`/`RANDOM_ENEMY` item은 없다.
- `use.consumed_on_use == true`이면 `item_class`가 `pass`/`key_material`/`quest`가 아니어야 한다 → `consumable_class_mismatch`. 반대로 `item_class == "consumable"`이면 `consumed_on_use`는 `true`여야 한다.
- `use.max_stack` int 1..99. `max_stack > 1`인데 `consumed_on_use == true`여도 허용한다(소모품 스택).
- **`floor_role`은 `equipment`와 공유 vocabulary**이며, item이 채울 수 있는 값은 `no_turn_item_source`, `field_pass_key` 2개다. 그 외 값을 쓰면 `item_floor_role_not_applicable` error.
- `floor_role == "field_pass_key"`이면 `field_use.traversal_key`가 `null`이 아니어야 한다 → `field_pass_key_without_key`.
- `field_use.service_id`는 자유 snake_case(`01` 소유 vocabulary).
- `acquisition` 규칙은 §5.18과 동일(단, `source_kind == "victory_award"`면 `enemy_*`/`enc_*`).
- **item은 action을 복제하지 않는다.** `use`가 `damage`/`status`/`target` 같은 필드를 직접 담으면 `item_duplicates_action` error. 행위는 오직 `act_*`에 있다.
- `presentation`에 Color나 path가 있으면 `content_holds_presentation_value`.
- `seed_ids`/`audit_note` ungrounded rule은 §5.3과 동일.
- `index.options.max_equipment_definitions` / `max_item_definitions`(각 64)을 넘으면 `equipment_overflow` / `item_overflow` error. 무한정 장비/소모품 표를 content로 만들려면 schema를 바꾸지 말고 budget을 조정한다.

---

## 6. World state data

### 6.1 orthogonal axes

축은 4개로 고정(constitution §4)이고 **content kind가 아니다.** runtime state다.

| key | 범위 | 초기값 | token↔integer mapping owner |
|---|---|---|---|
| `protocol_legitimacy` | int -3..3 | 0 | `02` §3 |
| `recognition_drift` | int -3..3 | 0 | `02` §3 |
| `continuity_pressure` | int -3..3 | 0 | `02` §3 |
| `resource_scarcity` | int -3..3 | 0 | `02` §3 |

**`02`가 named axis token과 integer mapping의 owner다**(`PLAN_RESOLUTION` §5). 이 문서가 고정하는 것은 **저장되는 값의 표현(정수 -3..3)·초기값·저장 위치**뿐이다.

- `06`은 **정수만** 저장하고 쓴다. `02`의 ladder token(`unlicensed`, `provisional`, `sanctioned`, `contested`, `successor` / `person`, `patient`, `operator`, `artifact`, `organ-authority`, `unclassified` / `single`, `linked`, `branched`, `loop-bound`, `crown-debt` / `buffered`, `rationed`, `localized`, `failing`, `collapsed`, `externally-mediated`)을 content field에 넣지 않는다 → `axis_token_in_integer_field` error.
- **`02` §3.3이 full mapping을 publish했다.** 7칸 mapping은 `protocol_legitimacy`(-3 `unlicensed_floor` … 3 `successor_peak`), `recognition_drift`(-3 `person` … 3 `unclassified_peak`), `continuity_pressure`(-3 `single_floor` … 3 `crown_debt_peak`), `resource_scarcity`(-3 `buffered` … 3 `externally-mediated`)이다. `06`은 이 정수 위치만 저장하고 token은 `02`에서 읽는다.
- **`02` §3.2의 initial matrix 값도 canonical ladder 안에 있다.** 이전의 "ladder에 없는 token이 남아 있다"는 결함과 `axis_ladder_unpublished` warning은 **삭제된다.** B축의 composite는 primary 정수 하나 + disputed claim record로 표현하고(`02` §3.2), disputed token은 ladder 밖이어도 괜찮다.
- **`03`의 별도 3-value ladder는 삭제되었다.** `03`이 3-value token을 쓰면 `axis_ladder_conflict` error로 잡는다. 3-value와 5~7-value ladder를 동시에 가지는 상태는 남기지 않는다.
- 어느 NPC가 어떤 행동을 했을 때 축이 오르는지는 `02`의 domain이다. `set_axis` op이 값을 **설정**하는 이유도 여기에 있다.
- `rel_*.axis_rules`의 `sets`는 이 4개 key만 쓴다. relationship의 `axes` 5개(`trust`/`fear`/`debt`/`recognition`/`attachment`)는 **orthogonal axis가 아니라 relationship 축**이고 catalog-wide namespace도 아니다. 두 축 계층을 섞지 않는다(§4.5, §5.7).
- **`concentration`은 축이 아니다**(`02` §3.4). `mana_profile`·`concentration_field`·`body_load`는 `world.magic` sub-record에 저장하고 `world.axes`에 넣지 않는다 → `global_concentration_forbidden` error. magic 사건이 축을 건드릴 때는 `02` §3.4 표의 `set_axis` write로 표현하고, 각 write는 별도 transaction step이다.

### 6.2 region-local resource flow

`region.resource_flow.scarce_keys`/`surplus_keys`는 **§6.3의 field resource ID**여야 한다. 자유 문자열이 아니다.

- `scarce_keys ∩ surplus_keys = ∅` → `resource_key_conflict` error.
- `access_rule_ids`는 자유 snake_case(`02`의 rule 개념 이름).
- 검증: catalog의 9개 region에 등장하는 모든 `resource_flow` key가 §6.3 목록에 있어야 한다 → `unknown_field_resource_key` error.
- **`R2`/`R8`의 `resource_flow`는 §5.5의 magic 10종을 선언해야 한다** → Stage 4 `magic_resource_not_in_region_flow` warning. `R2`는 `res_disperser_charge`/`res_circulation_slot`/`res_concentration_sample`, `R5`는 `res_medium_blank`/`res_fold_sheet`/`res_blade_credit`/`res_craft_credit`/`res_labor_pledge`, `R8`는 `res_craft_credit`/`res_lineage_token`/`res_concentration_sample`/`res_contract_tally`를 `scarce_keys`(debt key는 §6.4)에 둔다.
- `magic` 이름이 `scarce_keys`/`surplus_keys`에 들어가면 → `unknown_field_resource_key` error. `concentration`은 resource가 아니라 region 측정값이다(§5.10.1).

### 6.3 field/world resource vocabulary

**field/world 자원 token은 `02`와 `06`이 공유한다**(`PLAN_RESOLUTION` §8). `02` §5.4의 시작 allotment와 `05` §2.5의 authored resource 목록이 이 namespace에 들어간다. combat resource(§2.7)와 **완전히 다른 namespace**다.

| catalog ID | 출처 | 용도 |
|---|---|---|
| `res_empty_category_docket` | `02` §5.4 | 도착 category 선언/보류 |
| `res_route_debt_token` | `02` §5.4 | H0 route debt |
| `res_lamp_oil` | `02` §5.4 | E01 통과 비용 |
| `res_care_token` | `02` §5.4 | E03 통과 비용 |
| `res_blank_form` | `02` §5.4 | E04 통과 비용 |
| `res_power_cell` | `02` §5.4 | E05 통과 비용 |
| `res_seed_case` | `02` §5.2 | E02 통과 비용 |
| `res_safe_water` | `02` §5.2 | E02/E08/E17 |
| `res_ash_thread` | `02` §5.2 | E06 통과 비용 |
| `res_preservative` | `02` §5.2 | E07 통과 비용 |
| `res_medicine` | `02` §5.2 | E08 통과 비용 |
| `res_seed_vault_sample` | `02` §5.2 | E09 통과 비용 |
| `res_latency_token` | `02` §5.2 / `05` | E10 통과 비용, scheduler lock 해제 |
| `res_care_ration` | `02` §5.2 | E11 통과 비용 |
| `res_sealed_plate` | `02` §5.2 | E12 통과 비용 |
| `res_archive_weight` | `02` §5.2 | E13 통과 비용 |
| `res_transformation_fuse` | `02` §5.2 | E14 통과 비용 |
| `res_crown_gear` | `02` §5.2 | E15 통과 비용 |
| `res_battery` | `02` §5.2 | E15 통과 비용 |
| `res_hand_pump` | `02` §5.2 | E16 통과 비용 |
| `res_stretcher` | `02` §5.2 | E17 통과 비용 |
| `res_ink_credit` | `05` §2.5 | record category 편집/삭제 |
| `res_entry_token` | `05` §2.5 | disputed crossing/re-entry |
| `res_harvest_residue` | `05` §2.5 | 복구/교역 흔적 |
| `res_petition_seal` | `05` §2.5 | 이의 종결/이전 증명 |
| `res_permit_fragment` | `05` §2.5 | transformation/route 부분 증명 |
| `res_clear_channel` | `05` §2.5 | signal relay/emergency route 정지 |
| `res_untranslated_glyph` | `05` §2.5 | source term 보존 |
| `res_definition_token` | `05` §2.5 | target category 변경 증명 |
| `res_recovered_note` | `05` §2.5 | 제거된 command/memory/record 복원 |
| `res_consent_charter` | `05` §2.5 | body authority 동의 기록 |
| `res_surgical_license` | `05` §2.5 | clinic procedure/service route |
| `res_identity_token` | `05` §2.5 | clone/role/legal name 분리 |
| `res_water_manifest` | `05` §2.5 | 대체 수원 검증 |
| `res_audit_credit` | `05` §2.5 | debt/audit charge 정산·이전 |
| `res_seam_key` | `05` §2.5 | boundary route 개폐 |
| `res_root_record_fragment` | `05` §2.5 | late route의 Crown 진실 증명 |
| `res_heat_token` | `05` §2.5 | chilled resource route 해제 |
| `res_cleanup_token` | `05` §2.5 | ecological residue 제거/aggregate 분리 |
| `res_medicine_reserve` | `05` §2.5 | 실패한 surgery/recovery 개입 |
| `res_party_supply` | `05` §2.5 | noncombat ration/resource 결정 |
| `res_relationship_token` | `05` §2.5 | NPC/companion 신뢰·분리 결정 |
| `res_ration_packet` | `05` §2.5 | settlement route의 safe-water ration |
| `res_concentration_sample` | `02` §5.5 | 한 지점의 농도 측정값 + provenance. `E18` resource gate |
| `res_medium_blank` | `02` §5.5 | weave/scroll용 종이·직물 blank. `weave`의 `medium_options` |
| `res_fold_sheet` | `02` §5.5 | rigid-fold용 종이 + fold count 예산. `rigid_fold`의 `medium_options` |
| `res_blade_credit` | `02` §5.5 | void-cut 도구 사용권. 획득 시 `shape_or_pattern`·`tool_variant` 고정 |
| `res_disperser_charge` | `02` §5.5 | humidifier/disperser 유지 분말. `st_concentration_load`의 대응 |
| `res_circulation_slot` | `02` §5.5 | 누출 농도를 외부 공기로 보낼 여유. 이웃 region에 비용을 옮긴다 |
| `res_craft_credit` | `02` §5.5 | 학교/직장이 인정하는 craft 시간. `E18` resource gate. 기록 가능 3종 |
| `res_lineage_token` | `02` §5.5 | 가문/묶음이 보존한 미정형 craft 접근권. 기록 가능 3종 |
| `res_contract_tally` | `02` §5.5 | 체결한 portal contract의 미해결 obligation 개수. **비수량 debt key** |
| `res_labor_pledge` | `02` §5.4 | `R5` boot contract의 signed commitment. **비수량 debt key** |

- **magic `res_*` 10종은 `02` §5.5가 vocabulary를 소유하고 `06` §6.3이 ID를 등록한다**(`02` §12의 위임). core 43개 + magic 10개 = **53개**가 이 목록의 전체다.
- 이 목록은 **closed**다. 새 token은 `02`가 authored resource를 추가한 뒤 여기를 갱신해야 한다. 목록에 없는 token을 쓰면 `unknown_field_resource_key` error다.
- combat resource(`hp`/`mp`/`equipment_charge`)와 field resource(`res_*`)를 섞지 않는다. `equipment.field_keys.traversal_key`는 `res_*`만 받는다 → `combat_resource_in_field_namespace` error.
- `02`가 아직 publish하지 않은 이름이 있으면 `02` 확인 필요 항목으로 기록하고 임의로 정하지 않는다. **magic 10종은 `02` §5.5가 이미 publish했으므로 이 예외에 해당하지 않는다.**
- field resource는 `region.resource_flow`와 `equipment.field_keys`가 **참조만** 한다. 수량 저장은 `08`의 `world.resources`가 소유한다(§10.1).
- `res_concentration_sample`은 **provenance 없이 존재할 수 없다**(`05` §2.5). `world.resources`의 `res_concentration_sample` entry는 `provenance`를 가지며 그 값은 `region_*.concentration.provenance_node_id`와 같은 측정 원천이어야 한다 → `concentration_sample_without_provenance` error. 측정값 자체는 `world.magic.concentration_fields`에 있고 `res_concentration_sample`은 그 **증명**이다(§10.2).
- `res_blade_credit`는 획득 시점에 `shape_or_pattern`과 `tool_variant`가 함께 고정된다(`02` §5.5). 같은 이름의 도구라도 fold count와 오차가 다르므로, `act_*.craft.tool_options`는 이름이 아니라 **구조**로 cost와 안정성을 정한다(`S160`).

### 6.4 비수량 debt key — `res_labor_pledge`, `res_contract_tally`

`02` §5.5가 **비수량**으로 지정한 두 key다. 수량이 없으므로 `world.resources`의 다른 token과 다른 shape로 저장한다.

| catalog ID | 정본 이름 | 소비 edge | 비수량 규칙 |
|---|---|---|---|
| `res_labor_pledge` | `R5` boot contract의 signed commitment | `E05`, `E18` | amount 없음. `access: debt_bearing`. 진행은 `region_*.unresolved_debt[].resolution_token` |
| `res_contract_tally` | 체결한 portal contract의 미해결 obligation 개수 | `E18` 통과를 막지 않음 | amount 없음. `access: debt_bearing`. 진행은 `world.magic.contracts[].obligation_state` |

- **`res_contract_tally`은 별도 카운터를 저장하지 않는다.** 미해결 obligation 수는 `world.magic.contracts`에서 `obligation_state == "open"`인 entry 수로 **load 시 재계산**한다(§10.3 규칙 8). 숫자를 두 곳에 저장하면 drift가 난다 → `contract_tally_counter_stored` error.
- 두 key 모두 `amount`를 갖지 않는다. `world.resources[<key>].amount`에 정수가 들어오면 `debt_resource_quantified` error.
- 두 key는 `region_*.resource_flow.scarce_keys`에 들어가지만 `region_*.resource_flow.surplus_keys`에는 들어갈 수 없다 → `debt_key_as_surplus` error.
- 두 key는 `equipment_*.field_keys.traversal_key`가 될 수 없다 → `debt_key_used_as_traversal` error. debt는 통행권의 근거가 아니다.
- `act_*.craft.social_recording`은 `res_contract_tally`를 쓸 수 있지만 `res_labor_pledge`는 **쓸 수 없다** → `craft_record_target_forbidden` error. `res_labor_pledge`는 `G5` resolution에서만 생기고 사라지며, craft의 social recording 대상이 아니다(`02` §5.5, `05` §2.5).
- `res_contract_tally`이 증가하면(새 contract 체결) 그 entry는 `region_*.unresolved_debt[]`에 `resolution_token: "open"`으로 나타나야 하고, 해소되면(`filed`/`voided`) 사라져야 한다 → Stage 4 `contract_tally_untracked` warning. **obligation은 스스로 내려가지 않는다**(`st_contract_bound` §5.4.1, `05` §2.8.1).
- `res_labor_pledge`의 `resolution_token`은 `full`/`staged`/`refused` 중 하나여야 한다 → `labor_pledge_resolution_invalid` error. `E18`은 `full`/`staged`일 때만 `open`이고 `refused`일 때 `closed`가 되며, 그때의 대체는 `R5` 내부 industrial permit craft다(`02` §5.2/§6.1).

---

## 7. Load order

### 7.1 6 stage

```text
STAGE 0  manifest 검증 → ModuleContext 주입 → catalog instance 생성(인스턴스 1개)
STAGE 1  index.json 1개 읽기·검증 → kind 목록, prefix 역방향 표, entry_region_id, options 확정
STAGE 2  kind 순서대로 파일 읽기 + 구조 검증(structural parse)
STAGE 3  catalog 전체를 대상으로 한 번에 cross-reference 해석 (02 ladder 대조 포함)
STAGE 4  파생 불변식 + art key 등록 확인 + seed quota 계산
STAGE 5  READY | READY_WITH_DEFECTS | CONTENT_UNAVAILABLE
```

STAGE 2의 kind 순서:

```text
ledger → seeds → effects → statuses → actions → equipment → items → clocks
→ relationships → recovery → props → regions → npcs → conversations → documents
→ phases → enemies → encounters
```

**이 순서는 정답 의존성이 아니다.** STAGE 3이 cross-reference를 순서 무관하게 해석하므로 어떤 definition이든 어떤 kind의 어떤 definition을 먼저 선언했든 참조할 수 있다. 이 순서가 존재하는 이유는 단 하나, **error report가 결정적으로 재현 가능하도록** 읽기 순서를 고정하기 위해서다. 이 사실을 다음 agent가 "순서를 dependency로 바꿔야 한다"고 오해하지 않도록 여기에 명시한다.

`equipment`/`items`가 중간에 오는 것은 equipment가 action을, item이 action을 참조하기 때문이다. 하지만 그 참조 해석은 STAGE 3에서 하므로 순서는 무관하다.

### 7.2 참조 순서 제약 4개

전체 catalog가 순서 무관한데도 다음 4곳만 예외다. 이들은 **kind 또는 파일 내부**의 순차 관계라서 못 없앤다.

1. `phase.next_phase_id`는 같은 `owner_enemy_id` 안에서 `index`가 **더 큰** phase만 가리킨다 → `phase_forward_reference` error. (§5.15)
2. `relationship.states[].order`는 0부터 연속이고 `transitions`는 그 위에만 존재한다. state가 transition보다 먼저 선언돼야 한다 → `relationship_state_gap`. (§5.7)
3. `clock.stages[].index`는 0부터 연속이고 `02` ladder의 index와 같아야 한다 → `clock_stage_index_off_02_ladder`. (§5.6)
4. `recovery.preserves`/`discards` token은 §10.2의 `STATE_TOKEN` 집합과 **같은 token 집합**을 쓴다. save schema가 바뀌면 recovery schema도 bump된다. (§5.8, §10.4)

네 번째가 실제로 schema version 결합을 만든다: `ModuleManifest.save_version`이 올라가면 해당 save version을 참조하는 `rec_*`도 함께 bump된다. `rec_*.seed_ids`/`audit_note`에 bump 사유를 남긴다.

### 7.3 remix 깊이

`encounter.base_encounter_id`는 자기 자신도, remix도 가리킬 수 없다. **깊이는 1단계 고정**이다 → `nested_remix` error. BS2 §7.5가 요구하는 "동일 actor set의 count/subset 조합, depth/stat/action override, remix"을 깊이 1로 모두 표현할 수 있고, 깊이 2는 "어떤 encounter가 진짜 base인지"를 검증 불가능하게 만든다.

### 7.4 load 실패 시 동작

- STAGE 0/1 실패 → 즉시 `CONTENT_UNAVAILABLE`. catalog instance는 만들어지지 않는다.
- STAGE 2/3/4 실패 → 실패한 record만 격리(§9.2)하고 나머지를 계속 읽는다.
- STAGE 5에서 어떤 outcome이든 module entry는 예외를 던지지 않는다. `CONTENT_UNAVAILABLE`은 `08`이 정의한 복구 상태로 들어가는 신호다.

## 8. Validation — error/warning catalogue

### 8.1 severity

- **error**: 그 record를 격리하거나, 그 참조를 unresolved로 만들거나, catalog outcome을 강등시킨다.
- **warning**: 격리하지 않는다. `catalog_report`에만 남기고 수동 검수 체크리스트(`10`)로 넘어간다.

"warning이지만 gameplay를 망가뜨리는 경우"를 허용하지 않는다. 그런 판단이 필요하면 error로 올린다.

### 8.2 error code 전체 목록

STAGE 1(index) — 15개

`invalid_json`, `unreadable_file`, `missing_file`, `index_root_invalid`, `invalid_schema`, `schema_mixed_version`, `reserved_id`, `index_kind_missing`, `index_kind_duplicate`, `index_duplicate_file_entry`, `invalid_content_path`, `index_geometry_invalid`, `entry_region_not_hub`, `slot_unexpected`, `document_cap_not_nine`

STAGE 2(구조) — 공통 16개

`invalid_json`, `unreadable_file`, `missing_file`, `invalid_schema`, `schema_mixed_version`, `number_out_of_range`, `string_too_long`, `array_size_out_of_range`, `id_malformed`, `id_too_short`, `id_too_long`, `id_prefix_mismatch`, `fixture_id_in_live_content`, `dev_content_in_release`, `unrekeyed_planning_id`, `unknown_canonical_id`

STAGE 2(공통 표현 규칙) — 9개

`content_holds_presentation_value`, `content_holds_unknown_kind`, `content_infers_art_priority`, `content_infers_bar_semantics`, `content_infers_hud_field`, `content_randomizes_corruption`, `empty_reference_forbidden`, `resource_key_forbidden`, `combat_resource_in_field_namespace`

STAGE 2(문법) — 11개

`condition_shape_invalid`, `condition_depth_exceeded`, `condition_leaf_unknown`, `condition_leaf_count_exceeded`, `unknown_operation`, `operation_key_mismatch`, `formula_unknown`, `key_error_mismatch`, `empty_string_reference`, `unknown_hook`, `planning_claim_forbidden`

STAGE 2(vocabulary 정합) — 14개

`target_mode_outside_canonical_enum`, `target_role_used_as_target_mode`, `target_eligibility_mismatch`, `cursor_without_target`, `target_without_cursor`, `position_rule_in_condition`, `turn_cost_out_of_range`, `turn_cost_not_integer`, `slot_cost_on_no_turn`, `committed_slot_cost_mismatch`, `committed_without_commitment`, `committed_turn_cost_too_low`, `charge_without_tell`, `charge_single_tell_channel`

STAGE 2(magic vocabulary 정합) — 24개

`craft_on_non_magic_action`, `craft_family_outside_canonical_enum`, `global_concentration_forbidden`, `cast_without_field_threshold`, `cast_without_medium`, `void_cut_without_tool`, `rigid_fold_without_fold_budget`, `fold_budget_on_non_fold`, `waste_on_cost_field`, `craft_failure_status_not_magic`, `craft_without_clock_write`, `craft_record_target_forbidden`, `contract_tally_quantified`, `contract_ref_without_tally`, `untranslated_theory_label`, `craft_payload_not_magical`, `craft_mixes_resource_namespaces`, `magic_status_is_damage_multiplier`, `overflowed_without_magic_lock`, `overflowed_blocks_outside_magic`, `contract_bound_ticks_down`, `residue_reuses_contamination_rule`, `mana_profile_outside_canonical_enum`, `mana_profile_as_moral_judgement`

STAGE 2(kind별) — §5의 각 항목에 나열된 code를 그대로 쓴다. 각 code는 **정확히 한 kind의 validator에만** 속한다(§11.1). 한 validator가 두 kind의 code를 만들지 않는다. code 수를 이 문서에 따로 적지 않는 이유는, 유일한 source가 §5이고 여기 적으면 두 곳이 drift하기 때문이다. 테스트는 `§5`에 등장한 모든 code token을 실제 code 목록과 대조한다.

STAGE 3(참조 해석) error — 79개

`unresolved_reference`, `duplicate_id`, `player_id_in_npc_namespace`, `phase_owner_mismatch`, `phase_signature_unwired`, `phase_signature_duplicate`, `break_source_without_payload`, `break_source_without_effect`, `break_hook_unwired`, `hook_double_registration`, `effect_in_combat_hook`, `charge_stage_zero_cost`, `charge_stage_recharges`, `charge_cancel_on_non_charge`, `charge_pool_without_delta`, `reaction_unwired`, `enemy_uses_player_action`, `enemy_region_mismatch`, `enemy_region_role_mismatch`, `enemy_secondary_region_role_mismatch`, `region_secondary_not_canonical`, `encounter_region_role_mismatch`, `group_anchor_not_in_roster`, `target_role_surface_mismatch`, `target_role_not_descendant_only`, `target_role_takes_damage`, `resource_cost_without_equipment`, `relationship_backlink_missing`, `relationship_choice_not_grounded`, `companion_power_unwired`, `ally_effect_unwired`, `npc_hostile_encounter_unwired`, `npc_absence_target_mismatch`, `npc_denies_unknown_gate`, `npc_grant_target_not_item`, `conversation_speaker_mismatch`, `verb_condition_unrelated_target`, `recovery_debt_unlinked`, `recovery_reset_prop_foreign`, `noncombat_encounter_not_skippable`, `unknown_access_key`, `unknown_gate_id`, `unknown_field_resource_key`, `gate_unlock_unwired`, `edge_endpoints_mismatch`, `edge_not_bidirectional`, `no_turn_action_not_zero_turn_cost`, `item_action_wrong_category`, `item_action_not_no_turn`, `item_action_bad_target_mode`, `equipment_holds_runtime_value`, `slot_delta_without_floor_role`, `action_slot_source_without_delta`, `no_turn_source_without_action`, `granted_skill_without_action`, `field_pass_key_without_key`, `duplicate_group_id`, `lore_ref_not_in_seed_ids`, `deferred_write_target_stale`, `equipment_without_slot`, `basic_attack_wrong_category`, `charge_pool_wrong_key`, `empty_charge_pool_declared`, `equipment_status_conflict`, `item_floor_role_not_applicable`, `item_duplicates_action`, `consumable_class_mismatch`, `scripted_acquisition_without_effect`, `cast_without_prepared_craft`, `concentration_infrastructure_wrong_resource`, `concentration_provenance_not_measurable`, `concentration_sample_without_provenance`, `debt_key_without_resolution`, `debt_key_as_surplus`, `debt_key_used_as_traversal`, `debt_resource_quantified`, `contract_tally_counter_stored`, `support_roster_id_range_forbidden`, `r8_encounter_shape_off`

STAGE 3 warning — 4개

`effect_transition_rejected`, `unbound_flag_key`, `break_payload_on_unbreakable`, `enemy_secondary_region_role_mismatch`

앞의 셋은 `relationship` op의 target state가 현재 relationship machine에서 도달 불가능할 때, `flag` op의 key가 그 시점까지 어떤 effect에서도 읽히지 않을 때, break payload가 break 불가 대상에 걸릴 때다. 넷째는 record가 `region_secondary`를 선언했지만 그 region의 `region_role`과 대조되지 않을 때다. 모두 content authoring 실수지만 world를 망가뜨리지는 않으므로 warning이다. **`region_role_split_unresolved`는 `region_secondary` 도입과 함께 삭제되었다** — 분할은 이제 record가 직접 말한다(§3.5.4).

STAGE 4 error (파생·audit·closure) — 37개

`ledger_incomplete`, `ledger_quota_unmet`, `ledger_section_over_share`, `ledger_quota_arithmetic_mismatch`, `ledger_exclusion_list_incomplete`, `quota_token_mismatch`, `clock_diversity_insufficient`, `clock_not_canonical`, `clock_kind_id_mismatch`, `clock_stage_not_in_02_ladder`, `clock_stage_index_off_02_ladder`, `clock_irreversible_index_off_02_ladder`, `clock_start_stage_mismatch`, `clock_start_stage_terminal`, `clock_without_irreversible_point`, `clock_never_advances`, `orphan_clock`, `npc_clock_orphaned`, `art_key_unregistered`, `flag_namespace_overflow`, `reference_cascade_incomplete`, `region_not_canonical_9`, `region_role_mismatch`, `encounter_catalog_incomplete`, `equipment_floor_role_missing`, `equipment_overflow`, `item_overflow`, `encounter_without_world_change`, `loop_recovery_without_flag_storage`, `combat_midstate_in_payload`, `save_root_key_not_in_08_envelope`, `save_payload_too_large`, `magic_status_missing`, `magic_status_break_shatter`, `mana_profile_diversity_insufficient`, `cluster_catalog_incomplete`, `magic_layer_changed_core`

STAGE 4 error (closure 상한) — 1개

`closure_overflow`. §9.4의 4096 상한을 넘으면 entry closure가 완전해지지 못하므로 error다.

STAGE 4 error (교차 참조) — 7개

`cluster_size_outside_6_12`, `cluster_id_not_canonical`, `cluster_not_one_to_one`, `duplicate_cluster_id`, `route_state_outside_02_enum`, `conditional_edge_without_condition`, `single_return_affordance`

STAGE 4 error (02 ladder 정합) — 4개

`axis_token_in_integer_field`, `axis_out_of_range`, `axis_value_off_02_ladder`, `axis_ladder_conflict`

STAGE 4 error (recovery vocabulary) — 7개

`recovery_kind_violation`, `recovery_kind_token_mismatch`, `recovery_contradiction`, `recovery_preserves_nothing`, `recovery_layer_overlap`, `recovery_layer_gap`, `recovery_restores_combat_transient`

STAGE 4 error (document cap) — 4개

`document_cap_overridden`, `document_page_overflow`, `document_line_too_long`, `document_font_below_floor`

STAGE 4 error (magic audit) — 7개

`magic_seed_wrong_section`, `magic_seed_unbound`, `magic_seed_r8_only`, `magic_seed_without_clock_write`, `concentration_band_above_threshold`, `contaminated_flag_in_content`, `pollution_written_as_solution`

STAGE 4 error (debt key) — 2개

`debt_resolved_without_effect`, `labor_pledge_resolution_invalid`

STAGE 4 warning — 28개

`always_open_gate_in_saved_state`, `open_edge_with_condition`, `checkpoint_without_vitals`, `recovery_unreferenced`, `npc_verb_unused`, `npc_without_relationship`, `core_roster_presence_mismatch`, `core_npc_absence_temporary`, `status_band_order_collision`, `unreachable_break_shatter`, `break_payload_on_unbreakable`, `encounter_without_escalation`, `corruption_without_state_driver`, `advance_affordance_without_auto`, `redundant_unavailable_surface`, `choice_text_predicts_outcome`, `alt_conversation_cycle`, `remix_always_on`, `oneoff_overused`, `seed_unreachable`, `item_action_unlinked`, `region_without_backtrack_affordance`, `corruption_seed_class_mismatch`, `npc_verb_without_target`, `gate_state_always_open`, `magic_resource_not_in_region_flow`, `mana_profile_without_concentration_region`, `contract_tally_untracked`

`seed_unreachable`의 정의: `status == "used"`인 seed의 `bindings`가 전부 entry closure 밖 content를 가리킨다. postgame content에 묶이는 seed는 정상이고 그 결과 검증은 `10`의 수동 대조 항목이다(§13.5). 자동 판정하지 않는다.

**`clock_ladder_unpublished`와 `axis_ladder_unpublished`는 삭제되었다.** `02` §3.3이 full axis↔integer mapping을, `02` §4.1이 6개 clock의 6칸 stage ladder와 irreversible stage index를 publish했고, `02` §3.2의 initial matrix도 canonical ladder 안에 있다. 이 둘은 `unresolved_owner_requests`의 짝이었는데, 짝이 사라졌으므로 warning도 사라진다. 남아 있는 `unresolved_owner_requests`는 §8.3이 단일 source다.

**kind별 error/warning의 단일 source는 §5다.** 이 절의 code 목록은 STAGE 1/2 공통 코드와 STAGE 3/4의 **교차 참조·파생** 코드만 적는다. §5의 각 kind 항목에 나열된 code를 여기에 중복으로 옮기지 않는다(두 곳이 drift하는 것을 막기 위해서다). 테스트는 `§5`에 등장한 모든 code token을 실제 code 목록과 대조하고, 실제 코드에 있는데 이 문서 어디에도 없는 token이 있으면 `undocumented_error_code`로 실패한다.

### 8.3 catalog_report

validation 결과는 사람이 읽는 고정 shape로 나온다. presentation/debug에 노출하지 않는다. `DebugRoot`에서만 본다(`docs/ARCHITECTURE.md` §3).

```json
{
  "schema_version": 1,
  "outcome": "ready|ready_with_defects|content_unavailable",
  "content_signature": "sha256 hex 64자",
  "counts": {"declared": 0, "loaded": 0, "quarantined": 0, "references_resolved": 0, "references_unresolved": 0},
  "per_kind": [{"kind": "effects", "declared": 0, "loaded": 0, "quarantined": 0}],
  "errors": [
    {"code": "operation_key_mismatch", "kind": "effects", "id": "eff_x", "path": "effects/eff_x.json", "detail": "operations[0] op=flag has unexpected key 'reason'"}
  ],
  "warnings": [
    {"code": "status_band_order_collision", "kind": "statuses", "id": "st_x", "detail": "band_order 3 shared with st_y"}
  ],
  "quarantined": [{"kind": "npcs", "id": "npc_x", "reason_code": "npc_without_port"}],
  "entry_closure": {"reachable_count": 0, "capped": false},
  "unresolved_owner_requests": [],
  "seed_audit": {
    "denominator": 160,
    "quota_ratio_permille": 600,
    "minimum_retained": 96,
    "gate_status_token": "planned_retained",
    "planned_retained_transforms": 0,
    "quota_met": false,
    "used": 0,
    "transformed": 0,
    "by_status": {"planned_retained": 0, "used": 0, "rejected": 0},
    "by_class": {"ROOT": 0, "SYSTEM": 0, "MODULE": 0, "TONE": 0, "ONEOFF": 0, "CANDIDATE": 0, "DROP": 0},
    "by_section": {"A": 0, "B": 0, "C": 0, "D": 0, "E": 0, "F": 0, "G": 0, "H": 0, "I": 0, "J": 0, "K": 0, "L": 0},
    "violations": []
  }
}
```

- `errors[]`는 `(kind, id, code)` 기준 **정렬**되어 있다. 같은 입력이 같은 출력을 낸다.
- `quarantined[]`는 STAGE 2/3에서 격리된 정의를 **정확히** 나열한다. report에 없는 격리는 없다. "조용히 사라진 content"를 금지한다.
- `references_unresolved > 0`이면 outcome은 `content_unavailable`이거나 `ready_with_defects`다. 어느 쪽인지는 §9.5가 정한다.
- `unresolved_owner_requests[]`는 이 문서가 다른 plan 문서의 결정을 대신하지 않는다는 증거다. 현재 `01` turn_cost 0..5, `08` `world.magic`/`equipment_slots`, `09` art key registry가 모두 확정되어 현재 0건이다. 새 owner 결정이 생기면 여기에 남기고 `ready_with_defects`로 막는다.
- `02` clock/axis ladder와 `08` `world.flags` container는 이미 publish되어 목록에 없다. 목록에 없는 항목을 임의로 남겨 두지 않는다.
- `seed_audit.planned_retained_transforms`가 gate 판정값이다. `used`/`transformed`는 검수 후에만 0이 아닌 값이 되며 gate에는 쓰이지 않는다(§5.1).
- 이 report는 **저장하지 않는다**. save payload에 report를 넣으면 schema가 매번 바뀌고 old save와 충돌한다. 검증은 load 시점에 매번 다시 수행된다.

---

## 9. Duplicate / missing reference 처리

### 9.1 duplicate — hard stop

같은 ID가 catalog 전체에서 두 번 이상 선언되면(같은 kind의 두 파일, 다른 kind, `records[]` 안의 중복 record, index의 중복 entry 전부 포함) **catalog은 `CONTENT_UNAVAILABLE`이 된다.** 두 번째 이후 선언을 격리하되 outcome은 실패로 고정한다.

이 결정이 Kit 03의 "중복은 해당 case만 unavailable로 격리"와 **다르다는 점을 의도적으로 기록한다.** 이유는:

- Kit 03에서 중복 ID는 한 case 내부의 모호함이었다. 여기서 ID는 18개 kind를 관통하는 global namespace의 키이고, 동시에 save projection의 key이며, 동시에 seed audit의 binding 대상이다.
- 중복 ID가 있으면 "어느 쪽을 선택했든" player의 예전 save가 조용히 다른 content로 재바인딩된다. load 시점 hard stop만이 save를 손상시키지 않는 유일한 동작이다.
- runtime 비용은 0이다. 이 검사는 load 시 1회만 돈다.

### 9.2 격리와 cascade

아래는 **격리**된다. 즉 catalog에서 제거되고 `quarantined[]`에 기록되며, 이를 가리키는 모든 참조는 unresolved가 된다.

- 파일 없음, JSON parse 실패, unreadable
- schema version 불일치, strict key allowlist 위반
- enum 위반, 수치 범위 위반, 문자열 길이 초과
- kind 내부 불변식 위반(§5의 각 validator 규칙)
- prefix 불일치, ID 문법 위반, re-key 안 된 계획 ID
- art/presentation value를 content가 들고 있음
- `02` ladder 밖의 axis/clock stage 값

cascade 규칙:

1. 격리된 record를 가리키는 record도 격리한다.
2. 이 과정을 **최대 8회** 반복한다.
3. 8회 후에도 unresolved가 남으면 `reference_cascade_incomplete` error를 남기고 **나머지는 그대로 둔다.** 9회 이상으로 뻗는 cascade는 content 구조 문제이므로 사람 손이 필요하다.
4. `quarantined[]`에는 최종적으로 제거된 모든 record가 **이유 코드와 함께** 들어간다. 중간 단계 record도 포함해 나열한다(순서: 발생 순서).

### 9.3 missing reference — referrer가 죽는다

참조 대상 ID가 catalog에 없으면 **그 참조를 가진 record가 격리된다.** 참조가 조용히 무시되지 않는다.

예외는 **참조가 없는 것과 참조가 null인 것을 구분할 표현 수단이 필요한 slot**에만 있다. 이 slot들을 `nullable_reference_slots`라고 하고 **여기 나열된 8개가 전부**다.

| # | slot | `null`의 의미 |
|---:|---|---|
| 1 | `npc.encounter_profile.as_neutral.encounter_id` | 이 NPC는 중립 상태 전투를 갖지 않는다 |
| 2 | `npc.encounter_profile.as_hostile.encounter_id` | 이 NPC는 전투로 전환되지 않는다 |
| 3 | `npc.encounter_profile.as_ally.effect_id` | 이 NPC는 동행하지 않는다 |
| 4 | `clock.stages[].intervention.encounter_id` | 이 단계는 개입 전투를 만들지 않는다 |
| 5 | `encounter.outcome.on_failure.recovery_event_id` | `death_policy == "respawn_checkpoint"`이므로 recovery가 별도 아니다 |
| 6 | `encounter.base_encounter_id` | remix가 아니다 |
| 7 | `phase.next_phase_id` | 이 phase가 chain의 끝이다 |
| 8 | `document.owner_npc_id` | 주인이 사람이 아니라 기관이다 |

**`encounter.group`은 9번째 slot이 아니다.** `group == null`은 "이 encounter가 group composition이 아니다"라는 **명시적 값**이므로 key 생략으로 표현한다(§2.4). group field가 `null`이면서 `group_*` key가 있으면 `group_field_on_null` error다.

규칙:

- 조건부 필드가 위 8개가 아닌데 `null`이 오면 `empty_reference_forbidden` error다. **특히 `""`도 금지**다. `""`는 "없다"가 아니라 malformed 값이므로 `empty_string_reference` error로 따로 친다.
- `equipment.field_keys.traversal_key`, `equipment.service.*_service_id`, `encounter.group`는 **조건부 key 자체를 생략**한다(§2.4). `null`을 쓰지 않는다.
- 5번 slot은 `death_policy != "respawn_checkpoint"`일 때 `null`이면 `death_policy_recovery_mismatch` error다(§5.17).
- 2번 slot이 `null`인데 `conversion_condition`이 있으면 `npc_hostile_encounter_unwired` error(§5.11).
- 6번 slot이 `null`인데 `variant_overrides`가 비어 있지 않으면 `override_without_base` error(§5.17).
- 7번 slot이 `null`인 phase가 그 owner의 마지막 index가 아니면 `phase_chain_broken` error(§5.15).
- 이 목록에 slot을 추가하려면 이 표를 먼저 고치고 테스트(`§14.2`)에 추가한다. **다른 reference field로 확장하지 않는다.** 이 표가 `docs/CODE_STYLE.md`의 "저장/상태 스키마가 무한 확장된다"는 냄새를 막는 유일한 장치다.

`preserves`/`discards` vocabulary(§5.8)와 `STATE_TOKEN`(§10.1)도 같은 이유로 **closed set**이고, 세 목록이 서로 대조되는지 테스트한다.

양방향 대칭 검사는 §5.7(relationship), §5.2/§9.4(seed binding)에서 이미 정의했다. `npc.relationship_ids` ↔ `rel.target_npc_id`, `npc.interaction_verbs[].opens` ↔ `conv.speaker_npc_id`, `region.unresolved_debt[].debt_id` ↔ `rec.authored_debt.debt_id`, `region.clocks[].clock_id` ↔ `clock` 자체 존재, `enemy.phase_ids` ↔ `phase.owner_enemy_id`, `region.entry/exits[].edge_id` ↔ `02` §5.2 registry가 모두 양방향으로 확인된다. 한쪽에만 있는 것은 error다.

### 9.4 entry closure

catalog outcome을 결정하는 최소 집합이다. 다음을 **transitive로** 확장한다.

1. `index.entry_region_id`의 region
2. 그 region의 `exits[].to_region_id` (조건 무시 — 잠긴 gate도 도달 가능하다)
3. closure 안 region의 `residents[].npc_id`와 `oneoff_dialogue_seed_ids`가 가리키는 seed
4. 그 NPC들의 `interaction_verbs[].opens`가 가리키는 `conv_*`/`doc_*`/`enc_*`, `relationship_ids`, `clock_ids`
5. closure 안 region의 `clocks[].clock_id`, `revisit_variants[].prop_state_ids`/`conversation_id`, `internal_routes[].unlock_effect_id`, `unresolved_debt[].resource_id`/`resolve_effect_ids`, `cross_region_links[].to_region_id`
6. 그 region의 `combat_content.encounter_ids`, `noncombat_content.interactable_prop_ids`, `hidden_state.reveal_prop_ids`/`reveal_document_ids`
7. closure 안 `rec_*` 중 `respawn.region_id`가 closure에 있는 것, 그리고 그 `entry_effect_ids`/`authored_debt.resolve_effect_ids`
8. closure 안 clock의 각 stage `intervention.encounter_id`와 `effect_ids`
9. closure 안 encounter의 `roster[].enemy_id`, `target_roles[].surface_id`, `allow.parley_encounter_id`/`noncombat_encounter_id`, `outcome.*.effect_ids`, `repeat`가 가리키는 base encounter, `group.anchor_enemy_id`
10. 위 encounter의 enemy가 참조하는 `phase_ids`, `linked_actors[].enemy_id`, `baseline_action_ids`, `signature_action_id`, `status_profile.*`, `break_profile.*`, `reward.equipment_ids`/`item_ids`/`access_key`
11. 위 phase가 참조하는 `overrides.*` action/enemy/status와 `enter.*`
12. 위 action/status/effect가 참조하는 status, action, effect, equipment, item
13. 위 effect `delay_ref`가 가리키는 recovery/encounter/clock/region (1단, 그 뒤 transitive 확장 안 함)
14. 위 recovery의 `trigger.encounter_id`, `respawn.encounter_id`, `respawn.prop_id`, `respawn.reset_prop_ids[]`
15. closure 안 region의 `resource_flow.scarce_keys`/`surplus_keys`가 가리키는 `res_*` token(토큰 자체는 definition이 없으므로 registry로 확장)
16. closure 안 region의 `concentration.disperser_node_ids`가 가리키는 `prop_*`, 그리고 `disperser_charge_key`/`circulation_slot_key`가 가리키는 `res_*` token
17. 위 action의 `craft`가 참조하는 `st_*`(failure/status/waste), `mana_profile` token, `res_*`(`medium_options`/`waste.resource_costs`/`social_recording.resource_id`), `clock_id`
18. closure 안 region의 `initial_cluster.cluster_id`(registry 확장)와 `residents[].npc_id`, `cross_region_links`의 도착 region

closure 확장은 재귀 깊이 제한이 없고 **방문 record 수 상한**이 있다: `index.options.closure_record_cap` 4096. 초과하면 `closure_overflow` error. 무한히 넓은 world를 content로 만들려면 closure가 아니라 content 구조를 바꿔야 한다.

### 9.5 catalog outcome 3상태

| outcome | 조건 | module 동작 |
|---|---|---|
| `ready` | `duplicate_id` 0개 + entry closure가 100% 해석 + STAGE 4 error 0개 + `unresolved_owner_requests == []` | 정상 play |
| `ready_with_defects` | `duplicate_id` 0개 + closure 해석 100% + STAGE 4 error 1개 이상(quota 미달, `ledger_incomplete`, art key 미등록, `02` ladder 미공개 등) | 정상 play. `DebugRoot`에 report 표시. **검토 준비 완료 선언 금지** |
| `content_unavailable` | `duplicate_id` 1개 이상, 또는 entry closure가 깨짐, 또는 STAGE 1 실패 | 08이 정의한 복구 상태로 진입. `requested(&"observation", {id: "top_down_action_rpg.content_unavailable", text: ...})` 1회. player 입력 무시. 예외 없음 |

`ready_with_defects`가 `ready`보다 우선되지 않는 경우가 정확히 세 개다. 그 세 개가 Kit 완료를 막는다.

1. `seed_audit.quota_met == false` (§13)
2. `core_files_changed != []` 인 ledger entry가 존재 (§12.2)
3. `unresolved_owner_requests != []` (§8.3) — 새 owner 결정이 추가되면 readiness를 막는다. 현재는 0건이다.

### 9.6 stale save reference와 duplicate의 구분

이 둘은 **절대로 섞지 않는다.** save 안의 ID가 없다고 해서 content가 중복되었다고 판단하지 않는다.

- **content duplicate** → §9.1. load 실패. save와 무관.
- **stale save reference** → save 안의 ID가 현재 catalog에 없음. §10.4의 stale-state resolution으로 처리. load는 성공한다.

이 구분이 필요한 이유는 §3.3-3(ID 재사용 금지)와 직접 연결된다. ID를 재사용하면 "stale save"가 "새 content"로 조용히 해석돼 버그가 된다. 그래서 ID 재사용은 hard error이고, stale은 조용히 drop된다.

---

## 10. Save-safe projection

`docs/MODULE_CONTRACT.md`의 저장 규칙(module 소유, versioned, JSON-safe, 깊은 복사) 위에 이 문서가 projection 모양을 고정한다.

**root envelope은 `08_SAVE_DEATH_AND_RECOVERY.md`가 소유한다**(`PLAN_RESOLUTION` §4). 이 문서는 root key를 하나도 만들지 않고, `08` section **내부의 per-kind key allowlist와 sanitize**만 소유한다. 이 문서의 이전 flat 19-key root return은 `08`의 section 이름 안으로 이동했다.

### 10.1 `08` V1 root — 이 문서가 고치지 않는 부분

`save_state()`가 반환하는 dictionary의 root는 `08` §4.2가 그대로 정의한다. **12개 key**다.

```text
TopDownActionRpgSaveV1
├─ state_format: String            ← 08 소유 ("top_down_action_rpg.save.v1")
├─ save_version: int               ← 08 소유 (== ModuleManifest.save_version)
├─ run_id: String                 ← 08 소유
├─ content_revision: String        ← 08 소유 (06 §8.3 content_signature 복사본)
├─ field: Dictionary
├─ combat: Dictionary
├─ player: Dictionary
├─ world: Dictionary
├─ recovery: Dictionary
├─ progression: Dictionary
├─ transaction: Dictionary
└─ commit_log: Array[Dictionary]
```

- `06`은 위 12개 외의 root key를 만들지 않는다. 하나라도 있으면 `save_root_key_not_in_08_envelope` error.
- envelope/scalar key 4개(`state_format`, `save_version`, `run_id`, `content_revision`)는 `06`이 값을 쓰지 않는다. 검증만 한다(문자열/int 타입, 비어 있지 않음, `save_version`은 `ModuleManifest.save_version`과 일치).
- **이전 version의 `created_content_revision` 이름은 retired다.** `08`가 root 이름으로 `content_revision`을 publish했으므로 `06`도 그 이름을 쓴다. 이전 이름이 `save_state()`에 남으면 `save_root_key_not_in_08_envelope` error.
- `08`의 `world` section에 **`flags`가 이미 있다**(`08` §4.2/§4.3: `world.flags: Dictionary`, `world_` prefix key → bool). 이전 version의 이 문서가 "⚠ `08`에 container 추가 필요"라고 적은 것은 **`08`의 실제 schema와 어긋난 낡은 기록**이었다. `world.flags`는 확정된 container이고, `loop` recovery는 `ready_with_defects` 사유가 **아니다**.
- `08`의 `progression`은 `equipment`/`items`/`conversations`/`documents`/`unlocked_action_ids`를 이미 선언한다. 이전 version의 이 문서가 쓴 `progression.inventory`와 `progression.quest_state_by_id`는 **`08`에 없는 이름**이었고, §10.2 표를 그 이름으로 다시 쓰면 안 된다.
- **`world.magic`는 `08` V1 root에 존재한다.** `02` §12가 위임한 6종 sub-record는 `08`의 `world.magic` child allowlist에 담기며, `06`이 shape를 소유한다.

### 10.2 section 소유표 — `06`이 소유하는 per-kind allowlist

`06`이 소유하는 것은 **section 아래의 child key**와 그 shape/range/sanitize다. §7.2-4의 `STATE_TOKEN`은 이 표의 `token` 열이 단일 source다. root key와 section 이름은 `08` §4.2가 소유하고(`§10.1`), 이 표는 그 안의 child만 다룬다.

| `08` section | `08`가 가진 child key | `06` child key | `STATE_TOKEN` | shape / allowlist |
|---|---|---|---|---|
| `field` | `region_id`, `scene_id`, `anchor_id`, `actor`, `active_interaction_id` | `region_id` | `region_id` | string, `region_*`, **9개 중 하나** |
| `field` | ↑ | `active_interaction_id` | — | `08` 소유(빈 문자열 허용). `06`은 해석만 검증 |
| `world` | `crown` | `precedence`, `operator_id`, `object_phase` | `crown_state` | `08` 소유 shape. 쓰기 권한은 `gate_g8_crown_precedence`/`clock_crown_alignment`뿐(§5.8). `06`은 token 검사만 |
| `world` | `axes` | `<axis>` | `axis_values` | `{value: int -3..3, last_write_event_id: string}`, axis key는 §6.1의 4개로 닫힘 |
| `world` | `clocks` | `<region_id>.<clock_id>` | `clock_stages` | `{stage: string, tick: int 0..9999, last_signal_event_id: string, committed_event_ids: string[]}`, clock key는 §3.5.4의 6개 |
| `world` | `regions` | `<region_id>` | `region_state` | `{state_tag: string snake 3..32, visits: int 0..9999, revisit_variant_id: string, debt_ids: string[]}` |
| `world` | `props` | `<prop_id>` | `prop_states` | `{state_id: string, visit_count: int 0..9999}`. 해석 안 되는 state는 `initial_state_id`가 아니라 **그 entry 제거**(§10.4-8) |
| `world` | `routes` | `<edge_id>` | `route_flags` | `{state: 02 route state 5개, gate_open: bool, alternative_edge_id: string, write_revision: int}` |
| `world` | `npcs` | `<npc_id>` | `npc_states` | `{presence, state_key, region_id, visits, role_result, removal}` — `state_key` 값은 자유 string(≤32) |
| `world` | `relationships` | `<rel_id>` | `relationship_states` | `{state_id, visited_state_ids: string[]}` |
| `world` | `encounters` | `<enc_id>` | `encounter_clear_flags` | `{cleared: bool, clear_count: int 0..9999, depth_band_reached: int 0..20, repeat_revision: int}` |
| `world` | `records` | `<record_id>` | `record_states` | `{official: bool, rumor: bool, contradictory_copy: bool, authority_token: string, filing_stage: int 0..3}` |
| `world` | `resources` | `<res_*>` | `resource_states` | `{amount: int 0..9999, access: open/closed/debt_bearing}`. **§6.4의 비수량 debt key 2개는 `amount`가 없다** → `debt_resource_quantified` |
| `world` | `flags` | `<key>` | `flags` | bool. key는 `world_` prefix, 24개 cap. **`08` §4.2/§4.3에 이미 있는 확정 container** |
| `world` | `effects_fired` | `<eff_id>` | `effects_fired` | `{fired: bool, fire_count: int 0..9999}` |
| `world` | `magic` (**`08` V1 root에 이미 있음** — §10.2.1) | `concentration_fields` | `concentration_fields` | `{<node_id>: {level_permille: int 0..1000, safe_band_permille: int 0..1000, measured_tick: int 0..9999, provenance_node_id: string}}` |
| `world` | ↑ | `body_load` | `body_load` | `{<actor_id>: {accumulation: int 0..9999, emission_capacity: int 0..999, injury_mark_count: int 0..99, mana_profile: §5.11.1의 8개 token}}` |
| `world` | ↑ | `circulation` | `circulation` | `{<node_id>: {disperser_state: enum, circulation_slot_amount: int 0..99, pollution_accumulated: int 0..999}}` |
| `world` | ↑ | `crafts` | `crafts` | `{<craft_id>: {craft_family: §5.5.7의 3개, shape_or_pattern: string, tool_variant: string, fold_count_remaining: int 0..99, residue: int 0..3, concentration_level_permille: int 0..1000}}` |
| `world` | ↑ | `contracts` | `contracts` | `{<contract_id>: {shape_or_pattern: string, consideration: string, condition: string, obligation_state: open/filed/voided}}` |
| `world` | ↑ | `glossary` | `glossary` | `{<doc_*>: {filled: bool, term: string, filed_by: string}}`. `filled == false`일 때 `term`/`filed_by`는 **key를 생략**한다(§2.4) |
| `player.body` | — | `vitals` | `player_vitals` | `{hp: int 0..99999, max_hp: int 1..99999, mp: int 0..9999, max_mp: int 0..9999, statuses: [{status_id, stacks 0..99, remaining_windows 0..99}]}`. **AP 필드 없음** |
| `player.body` | — | `mana_profile`, `body_load` | `body_load` | player의 `mana_profile` token 1개와 `body_load`. `world.magic.body_load[<player>]`와 **같은 값을 두 곳에 쓰지 않는다** — NPC/actor는 `world.magic`이, player는 `player.body`가 소유한다 |
| `recovery` | `active_checkpoint_id`, `checkpoint_state`, `continuity`, `pending_outcome_id`, `pending_content_error`, `history`, `recoveries` | `continuity` | `recoveries` | `08` 소유 shape(`recovery_type`, layer 연결). `06`은 `recovery_type`이 §3.5.5의 7개 token인지 검사 |
| `recovery` | ↑ | `history` | `recoveries` | `08` 소유 array. `06`은 각 item의 `recovery_type` token을 검사하고 `history_list_cap` 64로 자른다 |
| `progression` | `equipment` | `<equipment_id>` | `inventory` | `{count: int 0..99}`. `08`의 `progression.equipment`는 **보유 수량 map**으로 읽는다 |
| `progression` | `items` | `<item_id>` | `inventory` | `{count: int 0..99}` |
| `progression` | `conversations` | `<conv_id>` | `conversation_progress` | `{completed: bool, choice_ids: string[], page_index: int 0..23, revisit_count: int 0..9999}` |
| `progression` | `documents` | `<doc_id>` | `document_reads` | `{read: bool, read_count: int 0..9999, corruption_stage_index: int 0..3}` |
| `progression` | `unlocked_action_ids` | — | `unlocked_actions` | `Array[String]`, `act_*`만, `history_list_cap`으로 cap. `01`의 transient action slot 상태는 넣지 않는다 |
| `progression` | `equipment_slots` (**`08` V1 root에 이미 있음** — §10.2.1) | `<slot>` | `equipment_slots` | `equipment_*` 또는 빈 문자열. `01`의 4 slot(`weapon`/`offhand`/`armor`/`accessory`) |
| `transaction` | `last_committed_event_id`, `last_commit_sequence`, `delayed_writes` | — | — | `08` 소유. `06`은 `delayed_writes[].target_id`가 catalog에 있는지 검사 |
| `commit_log` | `Array[Dictionary]` | — | — | `08` 소유 array. `06`은 `commit_log[].event_id` 중복과 `seed_id` 해석만 검사 |
| `combat` | `active_encounter_id`, `resume_boundary`, `pre_command_intent`, `attempt_serial`, `result` | — | — | **항상 재구축**(§10.4-7). `08` 소유 |

**`STATE_TOKEN` 27개(닫힘)**: `region_id`, `region_state`, `axis_values`, `clock_stages`, `crown_state`, `npc_states`, `relationship_states`, `prop_states`, `record_states`, `conversation_progress`, `document_reads`, `flags`, `effects_fired`, `encounter_clear_flags`, `route_flags`, `resource_states`, `inventory`, `equipment_slots`, `recoveries`, `player_vitals`, `unlocked_actions`, `concentration_fields`, `body_load`, `circulation`, `crafts`, `contracts`, `glossary`.

- magic 6종(`concentration_fields`, `body_load`, `circulation`, `crafts`, `contracts`, `glossary`)은 `02` §9.1이 요구하고 §12가 `06`에 위임한 것이다. `rec_*.preserves`가 `clone`/`reincarnation`/`loop`/`immortality`/`institutional_reentry`에 이 여섯 token을 포함할 때 recovery가 `body_load` injury와 `contracts` 미해결 obligation을 보존한다. `checkpoint`/`respawn`에는 선택적이다(§5.8 `recovery_layer_gap`).
- `rec_*.preserves`는 이 27개 token의 부분집합이어야 한다. `discards`는 §5.8의 7개 token(`encounter_progress`, `current_phase`, `linked_actor_state`, `combat_transient`, `scheduler_cursor`, `pending_effect_queue`, `presentation_transient`)로 닫힌다.
- `preserves`에 `region_state`가 들어가면 그 region의 `state_tag`와 `visits`가 함께 보존된다(한 token = 한 group). `resource_states`가 들어가면 `world.resources` 전체가 보존된다. 이 대응은 `§14.5`가 대조한다.
- `discards` token 중 `current_phase`, `linked_actor_state`, `pending_effect_queue`, `presentation_transient`는 payload에 key 자체가 없고, `scheduler_cursor`/`combat_transient`/`encounter_progress`는 `combat` 안의 field다. token은 **저장 정책의 이름**이고 payload key는 **저장되는 것의 이름**이라 의도적으로 한 단계 어긋나 있다.
- `presentation_transient`는 어디에도 없다. `focus`, `hover`, `tooltip`, `tween`, `cursor`, `fading`, `dialogue_scroll`, `choice_scroll`은 전부 progress semantics가 없다(`docs/MODULE_CONTRACT.md` §저장). 예외가 필요하다고 느껴지면 그건 transient가 아니라 world state다.
- **`world.magic`는 `world.flags`/`world.records`와 같은 성격이다**: 전역 boolean이나 수량 map이 아니라 **record 집합**이고, 각각의 token이 다른 6개 record 종류와 1:1이다.
- `world.magic.crafts[].concentration_level_permille`가 §5.5.7의 `concentration_requirement`을 충족하지 못하면 그 craft는 `cast_without_prepared_craft`로 resolve되지 않는다. **저장된 현재 값과 authored 임계치는 별개 namespace에 있고, 판정은 load 시 content로 재계산한다**(§10.3 규칙 8).
- **`world.magic.contracts`의 `open` entry 수는 `res_contract_tally`이다.** 별도 카운터를 저장하지 않는다(§6.4).

#### 10.2.1 `08`에서 확정한 저장 child

`08` V1 root는 `world.magic`와 `progression.equipment_slots`를 명시적으로 소유한다. `06`은 이 두 child의 shape만 소유한다.

| 값 | root 위치 | 상태 |
|---|---|---|
| `world.magic` 6종(`concentration_fields`, `body_load`, `circulation`, `crafts`, `contracts`, `glossary`) | `08` `world.magic` | **확정** |
| `progression.equipment_slots` | `08` `progression.equipment_slots` | **확정** |

- `world.magic`를 `world.resources`나 `world.records`에 섞지 않는다.
- `progression.equipment`는 보유 수량 map이고 `progression.equipment_slots`는 slot map이다.
- `res_contract_tally` counter는 저장하지 않고 `world.magic.contracts`의 open obligation 수로 재계산한다.
- 두 child key는 root 12개 key를 늘리지 않으며, allowlist는 `08` §4.2 child 이름과 일치한다.

### 10.3 projection 규칙 9개

1. **allowlist만 쓴다.** §10.2의 child key 외에는 어떤 key도 `save_state()`에 넣지 않는다. 테스트가 exact key set을 assert한다. allowlist는 `08` §4.2가 선언한 child 이름과 **글자 단위로 일치**해야 한다 — `08`에 없는 이름(`progression.inventory`, `progression.quest_state_by_id`)을 쓰면 안 된다.
2. **ID-keyed, never positional.** 모든 map은 stable ID로 key한다. 위치가 의미를 가지는 array는 없다. `visited_state_ids`/`choice_ids`/`committed_event_ids`/`unlocked_action_ids`는 순서가 무의미한 set이다(저장 순서는 정렬한다. 판정에는 순서를 쓰지 않는다).
3. **content-derived 상수를 저장하지 않는다.** `player_vitals.max_hp`는 저장이지만 base stat이 아니다. `statuses[].remaining_windows`는 저장이지만 `duration.kind`는 아니다. `clock_stages[].stage`는 저장이지만 `stages[]` 배열이 아니다. `magic.crafts[].concentration_level_permille`는 저장이지만 `act_*.craft.concentration_requirement`은 아니다. **플레이 때문에 authored default와 달라질 수 있는 값만** 저장한다.
4. **수는 int·bool·string·array·dictionary만. payload에는 float이 하나도 없다.** `08` §4.1이 V1 module state에서 float을 허용하는 field를 `field.actor.x`/`field.actor.y` **2개로** 닫았으므로 `06`은 예외를 만들지 않는다. content의 float은 `document.reading.world_visible_ratio` 하나뿐이고(§2.1) 그것은 presentation 입력이지 저장 대상이 아니다. 나중에 비율을 저장해야 하면 float이 아니라 permille 정수로 정의한다.
5. **load 시 클램프와 타입 정규화.** 저장값을 신뢰하지 않는다. 정수는 declared range로 clamp하고, string은 length cap으로 자르고, array는 dedupe + cap한다. `odd_road_adventure._normalize`이 확정한 sanitizer discipline을 따른다. 그 파일을 import하지는 않는다(§11.5).
6. **`content_revision` 불일치로 save를 거부하지 않는다.** 불일치 시 stale-state resolution을 실행하고 debug log에 남긴다. 저장 포맷이 바뀌어도 플레이어의 진행은 보존되어야 한다.
7. **알 수 없는 ID는 drop + warning.** 단 `field.region_id`와 `combat.active_encounter_id`만 예외이고, 이 둘은 fallback 규칙을 적용한다(§10.4). **`world.magic`의 ID도 drop 규칙을 따른다** — 없는 `node_id`/`actor_id`/`craft_id`/`contract_id`/`doc_*`는 그 entry만 제거한다.
8. **파생 상태를 저장하지 않는다.** route 개방 여부, encounter 가용성, relationship 도달 가능성, `clock_irreversible`, clock의 irreversible stage index, **`res_contract_tally`의 미해결 count**, **`st_concentration_load`/`st_medium_residue`가 authored threshold를 넘었는지**는 저장하지 않고 **load 시 현재 content로 재계산**한다. 재계산이 오래된 결정을 덮어쓰는 일은 없다.
9. **`save_version` bump 정책.** section child key 집합에서 **키 추가만 하는 변경은 bump 불필요**(sanitizer가 default로 채운다). **키 제거·이름 변경·의미 변경은 bump 필수**이고 `migrate_save`가 같은 sanitizer를 거쳐 재투영한다. manifest의 `save_version`이 올라가면 이를 참조하는 `rec_*`도 §7.2 규칙 4에 따라 함께 bump된다.

### 10.4 sanitize와 fallback

load 순서:

```text
1. state_format 확인 → 불일치/future면 migrate_save 재투영
2. root allowlist 밖 key 전부 제거 (08의 12개 외 → 제거 + log)
3. 각 section의 child allowlist 밖 key 제거
4. 각 map을 catalog에 존재하는 ID로 재구성 (없는 ID drop + warning)
5. 정수/string/array clamp 및 dedupe
6. field.region_id fallback
7. combat 재구축 (§10.4-7)
8. 일관성 검사 → 깨진 record의 기본값 복원
9. 파생 상태 재계산 (route/encounter/relationship/clock irreversible/contract_tally/load threshold)
```

- **step 6** `field.region_id`가 없거나 해석 안 되면: save의 `recovery.history`에서 마지막 사용 `rec_*`의 `respawn.region_id` → 없으면 closure에서 첫 region → 그것도 없으면 `CONTENT_UNAVAILABLE`. 순서를 고정한다.
- **step 7 — 전투 중 resume 금지.** `combat.active_encounter_id`가 **비어 있지 않으면** 전투를 **중간에 resume하지 않는다.**
  - encounter를 `interrupted`로 표시하고, `content_revision` 불일치가 없으면 그 encounter의 `activation` 경로로 **재진입**한다.
  - `combat.attempt_serial` 이외의 전투 내부 진행(`scheduler_cursor`, `next_action_slot`, `actors`, `queued_action_ids`, `statuses`, `phase_id`, `result` 외의 charge stage, reaction window)은 **전부 버린다.** charge stage, reaction window, scheduler cursor를 복원하지 않는다.
  - 그 encounter의 `rec_*`가 `checkpoint`/`respawn`/`institutional_reentry` kind면 `respawn.reset_prop_ids`가 prop 상태를 되돌린다.
  - **이것은 의도된 단순화다.** combat resolution 순서를 save contract에 넣으면 schema가 전투 시스템에 종속되고, 그때마다 core 수정이 필요해진다. 전투 중 저장/복구는 금지하지 않는다(저장은 되지만 복구가 전투 중간이 아니다) — 이 사실을 `08`이 화면/UX로 설명한다.
  - **저장 시점 자체가 commit 경계로 제한된다**(`08` §2.2: "저장은 commit 경계에만 쓴다"). resolution transaction 중간·charge stage·reaction window에서 `save_state()`가 호출되면 module은 현재 command boundary까지 commit한 뒤 호출된 것으로 취급한다. 따라서 저장 payload에는 charge stage나 reaction prompt 상태가 **구조적으로 들어갈 수 없다** → `combat_midstate_in_payload` error. `01`의 charge/reaction restore 요구는 **pre-command intent(검증된 target stable ID + reserved resource)와 encounter-level checkpoint**로 재정의된다.
  - 이 규칙은 `10`의 `test_combat_mid_state_is_never_restored`, `test_charge_and_reaction_restore_is_intent_or_checkpoint_only`, `test_no_ledger_resume_across_save_boundary` 세 개가 검사한다.
- **step 8** `world.relationships[x].state_id`가 현재 `rel_*`에 없으면 그 `rel`의 `start_state_id`로 복원하고 `visited_state_ids`를 `[start_state_id]`로 줄인다. `world.clocks[..].stage`가 현재 `clock_*`의 `02` ladder index 범위(0..5)를 넘으면 index 0으로. `progression.conversations[x].choice_ids`에 현재 대화에 없는 choice id가 있으면 그 id만 제거한다. `progression.equipment_slots[slot]`의 장비가 현재 `progression.equipment`에 없으면 그 slot을 빈 문자열로 되돌린다. 각 복원마다 warning.
- **step 8** `world.props[x]`의 prop ID가 현재 catalog에 없으면 그 entry는 **drop**한다. `initial_state_id`로 되돌리지 않는다. 그 prop이 삭제된 것이지 이름이 바뀐 것이 아니고, 없는 prop의 기본 상태를 만드는 것은 존재하지 않는 world state를 발명하는 일이다. revisit에서 보이지 않게 되는 게 옳다. 같은 규칙이 `world.npcs`, `world.relationships`, `world.records`, `world.encounters`, **`world.magic.crafts`/`contracts`/`body_load`**에 적용된다.
- **step 8** `world.effects_fired[x].fire_count`가 `index.options.history_list_cap`을 넘으면 cap으로 자르고 warning. `commit_log` 길이도 같은 cap으로 자른다. `progression.unlocked_action_ids`도 같은 cap으로 자르고 `act_*`가 아닌 id는 drop한다.
- **step 9** `clock_irreversible`은 `world.clocks[..].stage`와 `02` ladder의 irreversible stage index(각 clock stage 4)를 비교해 **재계산**한다. 저장하지 않는다.
- **step 9** **`res_contract_tally`은 `world.magic.contracts`에서 `obligation_state == "open"`인 entry 수로 재계산**한다. 저장된 카운터가 있으면 `contract_tally_counter_stored` error 후 버린다(§6.4).
- **step 9** **`st_concentration_load`/`st_medium_residue`의 threshold 도달 여부는 `act_*.craft.concentration_requirement`과 `region_*.concentration.threshold_permille`로 재계산**한다. 저장된 bool이 있으면 drop한다.
- stale로 drop된 것은 `catalog_report`가 아니라 **module-local load log**에 남긴다. `catalog_report`는 load 시점의 content 상태이고, load log는 save 상태에 대한 판단이다. 둘을 섞으면 report가 매번 달라져 테스트가 무의미해진다.

### 10.5 schema bump 절차

`section child key`를 바꿀 때:

1. `ModuleManifest.save_version` +1
2. `migrate_save(old_version, data)`에서 버전에 따라 분기
3. §5.8의 `preserves`/`discards` token 목록 갱신
4. 해당 token을 참조하는 `rec_*` 파일의 `schema_version` bump
5. 테스트에 이전 version fixture 추가

`migrate_save`는 **재투영만** 한다. 새 의미를 발명하지 않는다. 이전 version에서 쓰던 key를 새 key로 옮기고, 알 수 없는 것은 default로 채운다.

- 이 Kit의 `migrate_save`가 반드시 처리해야 하는 이전 version 차이는 두 가지다: ① root `created_content_revision` → `save_version` + `content_revision` ② `progression.inventory`/`progression.quest_state_by_id` → `progression.equipment`/`items`/`conversations`/`documents`. content가 시작되기 전에 확정되는 version이라 별도 fixture 없이 규칙만 남긴다.
- `world.magic`는 container가 확정된 뒤 추가한다. 그전까지 `migrate_save`는 magic 값을 읽지 않고 버린다. **`magic` 값을 `world.resources`나 `world.records`에서 복원하려는 우회는 금지**다 — 두 namespace를 섞으면 되돌릴 수 없다.

### 10.6 크기 상한

- 모든 map은 catalog ID로 key되므로 content 크기에 비례한다
- history list(`recovery.history`, `commit_log`)는 `index.options.history_list_cap` 64로 cap
- `combat.queued_action_ids`는 8로 cap(그리고 §10.4-7에서 load 시 전부 버린다)
- 60분 플레이 payload가 `index.options.save_payload_bytes_cap` 262144 bytes를 넘으면 `save_payload_too_large` error (GUT에서 실패)
- `SaveService.is_json_safe(payload)`가 true여야 한다(테스트)
- 테스트는 scripted 10분 run 전후 payload를 비교해 **무관한 section/key가 늘지 않았는지** 확인한다. 늘면 presentation-only state가 새어 나온 것이다.

---

## 11. Loader / registry boundary

### 11.1 unit 목록과 소유

전부 `modules/top_down_action_rpg/` 아래다. `class_name`은 `PascalCase`, 파일은 `snake_case`.

| 경로 | class_name | 공개 surface | 소유 |
|---|---|---|---|
| `content/content_io.gd` | `TopDownContentIO` | `read_json(path)`, `is_content_id(v)`, `is_content_path(v)`, `is_json_safe(v)`, `parse_index(v)`, `hash_path(p)` | 파일 열기/파싱/ID·path 문법/JSON-safe 판정 |
| `content/catalog.gd` | `TopDownContentCatalog` | `load(index_path)`, `has(id)`, `get_kind(id)`, `get_record(id)`, `resolve(ref)`, `entries_of(kind)`, `signature()`, `report()`, `is_ready()` | catalog instance, STAGE 1–5, 참조 해석 |
| `content/condition.gd` | `TopDownCondition` | `validate(v) -> Dictionary`, `evaluate(v, ctx) -> bool` | Condition 문법 |
| `content/effect.gd` | `TopDownEffect` | `validate(v) -> Dictionary`, `apply(record, ctx) -> Dictionary` | op 문법, atomic rollback |
| `content/id_rules.gd` | `TopDownId` | `is_id(v)`, `is_reserved(v)`, `kind_of(id, prefix_map)`, `is_rekeyed(v)` | ID 판정, §3.5 re-key 표 조회 |
| `content/world_ladder.gd` | `TopDownWorldLadder` | `axis_in_ladder(axis, value)`, `clock_stage_index(kind, stage_id)`, `clock_irreversible_index(kind)`, `route_state_valid(v)` | `02` ladder 대조. **ladder 값은 `02`에서 읽어 온다** |
| `content/save_projection.gd` | `TopDownSaveProjection` | `project(state)`, `sanitize(data)`, `section_allowlist(section)`, `state_tokens()` | `08` section 내부 per-kind allowlist, sanitize, `STATE_TOKEN` |
| `content/validate/validate_ledger.gd` | `TopDownValidateLedger` | `parse(v, expected_id) -> Dictionary` | §5.1 |
| `content/validate/validate_seed.gd` | `TopDownValidateSeed` | `parse_record(v)`, `parse_array(v) -> Dictionary` | §5.2 |
| `content/validate/validate_effect.gd` | `TopDownValidateEffect` | `parse(v, expected_id) -> Dictionary` | §5.3 |
| `content/validate/validate_status.gd` | `TopDownValidateStatus` | `parse(v, expected_id) -> Dictionary` | §5.4 |
| `content/validate/validate_action.gd` | `TopDownValidateAction` | `parse(v, expected_id) -> Dictionary` | §5.5 |
| `content/validate/validate_equipment.gd` | `TopDownValidateEquipment` | `parse(v, expected_id) -> Dictionary` | §5.18 |
| `content/validate/validate_item.gd` | `TopDownValidateItem` | `parse(v, expected_id) -> Dictionary` | §5.19 |
| `content/validate/validate_clock.gd` | `TopDownValidateClock` | `parse(v, expected_id) -> Dictionary` | §5.6 |
| `content/validate/validate_relationship.gd` | `TopDownValidateRelationship` | `parse(v, expected_id) -> Dictionary` | §5.7 |
| `content/validate/validate_recovery.gd` | `TopDownValidateRecovery` | `parse(v, expected_id) -> Dictionary` | §5.8 |
| `content/validate/validate_prop.gd` | `TopDownValidateProp` | `parse(v, expected_id) -> Dictionary` | §5.9 |
| `content/validate/validate_region.gd` | `TopDownValidateRegion` | `parse(v, expected_id) -> Dictionary` | §5.10 |
| `content/validate/validate_npc.gd` | `TopDownValidateNpc` | `parse(v, expected_id) -> Dictionary` | §5.11 |
| `content/validate/validate_conversation.gd` | `TopDownValidateConversation` | `parse(v, expected_id) -> Dictionary`, `parse_choice(v) -> Dictionary` | §5.12, §5.13 |
| `content/validate/validate_document.gd` | `TopDownValidateDocument` | `parse(v, expected_id) -> Dictionary` | §5.14 |
| `content/validate/validate_phase.gd` | `TopDownValidatePhase` | `parse(v, expected_id) -> Dictionary` | §5.15 |
| `content/validate/validate_enemy.gd` | `TopDownValidateEnemy` | `parse(v, expected_id) -> Dictionary` | §5.16 |
| `content/validate/validate_encounter.gd` | `TopDownValidateEncounter` | `parse(v, expected_id) -> Dictionary` | §5.17 |

- **18개 kind = 18개 validator**다. `equipment`/`items`도 이 문서가 소유하므로 다른 파일이 추가하지 않는다.
- `registered_slots`에 새 kind가 채워지면 catalog은 그 slot의 `validator_class`를 호출한다. **catalog에 `if kind == "…"` 분기를 새로 만들지 않는다.** slot 기반 등록이며, 새 kind 추가가 catalog 수정 없이 이루어져야 한다.
- 각 validator는 **자기 kind의 code만** 만든다. 한 validator가 두 kind의 error code를 만들면 그건 두 kind가 실제로 다른 contract를 공유한다는 뜻이고, 그런 경우 두 kind를 한 schema로 합쳐야 한다. §5가 그렇게 하지 않은 이상 합치지 않는다.
- `TopDownWorldLadder`는 **`02`가 publish한 ladder를 읽는다.** `02` §3.3의 axis↔integer mapping과 §4.1의 6×6 clock stage ladder가 **이제 publish되어 있으므로** 이 유닛은 그 값을 그대로 읽고, ladder가 비어 있으면 빈 ladder로 시작하며 `clock_ladder_unpublished`/`axis_ladder_unpublished` warning을 낸다. **이 유닛이 ladder 값을 하드코딩하지 않는다.** 하드코딩하면 `02`와 이 문서가 두 개의 source가 되고, `05`의 §2.6 region role처럼 이미 그 사고가 한 번 발생했다.
- `TopDownSaveProjection`는 `world.magic` 6종의 child allowlist도 소유한다(§10.2). `concentration_fields`/`body_load`/`circulation`/`crafts`/`contracts`/`glossary`가 이 유닛에서만 정의되고, 다른 유닛이 같은 shape를 다시 만들지 않는다.

### 11.2 재사용 허용 사다리

`docs/ARCHITECTURE.md` §4와 `docs/KIT_WORKFLOW.md` §10: "두 실제 사용처에서 동일 의미와 계약이 확인된 뒤에만 shared".

| 후보 | 사용처 | 판정 |
|---|---|---|
| `TopDownId` (ID/path 문법) | 18 kind validator + catalog + seed audit + re-key 표 = 21곳 | **allowed.** 의미가 동일(문법 판정)이고 내용에 의존하지 않음 |
| `TopDownContentIO` (파일 열기/파싱) | catalog + test fixture loader = 2곳 | **allowed.** file mechanism이며 kind 의미를 모름 |
| `TopDownCondition` | region exits/hidden_state, choice availability, phase trigger `condition`, encounter `eligibility`, clock `reversal`, recovery trigger `condition`, prop `hidden_until_condition` = 7곳 | **allowed.** 하나의 문법, 하나의 의미 |
| `TopDownEffect` | `EffectDefinition.operations`, `StatusDefinition.tick.operations` = 2곳 | **allowed.** 두 번째 사용처가 이미 확정 |
| `TopDownWorldLadder` | axis 정합(§6.1), clock stage 정합(§5.6), route state 정합(§5.10) = 3곳 | **allowed.** `02` ladder 대조라는 단일 의미. 값을 가지지 않으므로 shared 유틸이 아니라 **adapter**다 |
| `TopDownSaveProjection` | `save_state()`, `load_state()` sanitize, `migrate_save` = 3곳 | **allowed.** 3개가 이미 확정 |
| `TopDownSaveProjection`의 magic 6종 allowlist | `world.magic` projection/sanitize, `res_contract_tally` 재계산, load threshold 재계산 = 3곳 | **allowed.** 하나의 shape를 3군데가 읽는다. `world.resources`와 공유하지 않는다 |
| `act_*.craft` validator | `act_*.craft` 구조 검사, `mana_profile` token 검사, `res_*`/`st_*`/`clock_*` 참조 검사 = 3곳 | **allowed.** 하나의 sub-record에 대한 검사이고, `TopDownValidateAction` 안에 들어간다. 별도 유닛이 아니다 |
| kind별 validator 합치기 | 없음 | **rejected.** 각 kind의 required key 집합과 cross-reference 규칙이 다르다 |
| `status` + `relationship` + `recovery` 공통 progression state | 없음 | **rejected.** 저장 대상이 다르다(§4.5) |
| generic formula evaluator | 없음 | **rejected.** formula는 closed token이다(§4.4) |
| `Resource`-based content class (`class_name ActionDef extends Resource`) | 없음 | **rejected.** `GODOT_JRPG_AUDIT` §3.2의 "Resource는 runtime identity를 저장하지 않는다"를 따라도, Resource는 이 Kit의 필요 없고 editor가 금지되어 있다. JSON + typed RefCounted로 충분 |
| `magic` content kind / `content/magic/` 디렉터리 | 없음 | **rejected.** §0bis. magic data는 기존 kind 안에 있다. 새 kind는 `A1`(`changed_core_files == []`)를 깨뜨린다 |
| global `ContentRegistry` (core) | 없음 | **rejected.** core가 구체 module ID를 알면 안 된다 |
| autoload content service | 없음 | **rejected.** `docs/ARCHITECTURE.md` §4 |
| `/root` 탐색 / service locator | 없음 | **rejected.** `docs/MODULE_CONTRACT.md` §GameModule |
| cross-module `preload` | 없음 | **rejected.** §11.4 경계 테스트가 막는다 |

### 11.3 catalog lifecycle

- catalog은 **인스턴스 1개**다. module의 최상위 노드가 소유하고, `enter()`에서 만들고 `exit()`에서 버린다.
- `static var`로 catalog을 들지 않는다. `RuleLevelLoader`는 `static` funcs만 쓰고 state가 없지만, `TopDownContentCatalog`는 loaded record 집합을 들기 때문에 **인스턴스가 반드시 필요하다.** static catalog은 module instance가 바뀌면 이전 module의 content가 새 module에 남고, re-entry와 save/load 테스트가 오염된다.
- 필요로 하는 시스템에 **생성자 인자로 명시적으로** 전달한다. 전역 접근은 없다.
- **STAGE 5 이후 catalog은 불변이다.** runtime state는 module의 runtime state 객체에 있고 catalog에는 없다. 10분 scripted run 전후로 catalog의 deep hash가 동일한지 테스트한다. 다르면 content가 runtime에 오염된 것이다.
- `load()`는 재호출 가능해야 한다(module re-entry). 재진입마다 새 인스턴스에서 새로 읽는다. 캐시를 파일시스템에 두지 않는다.

### 11.4 presentation 경계

- presentation은 catalog의 **typed projection 객체**와 stable ID 조회만 받는다.
- presentation은 `TopDownValidate*`를 호출하지 않는다. validation은 load 시점의 catalog 책임이다.
- presentation은 catalog state를 바꾸지 않는다. world/relationship/clock 전이는 domain system이 하고, presentation은 intent를 낸다.
- presentation은 `art_key`/`tint_key`/`silhouette_key`/`target_hp_or_condition`을 **해석**하지만 content에는 쓰지 않는다(§2.8, §4.4.2).
- **경계 테스트**가 이걸 기계적으로 지킨다: `modules/top_down_action_rpg/` 안의 모든 `.gd`를 훑어, `preload`/`load` 대상 path가 `res://modules/top_down_action_rpg/`, `res://core/contracts/`, `res://tests/` 셋 중 하나인지 assert한다. 하나라도 어기면 테스트 실패. `core/contracts/`는 `GameModule`, `ModuleContext`, `ModuleManifest`, `ModuleResult` 네 개만 허용하고 그것조차 module `entry`/`module.gd`에서만 import할 수 있다(§14.5).
- production `.gd`에 authored stable ID나 dialogue literal이 **0개**여야 한다(§3.5의 flat ID를 그대로 쓰지 않는다) → `10`의 `test_no_authored_id_or_dialogue_literal_exists_in_production_gd`.
- `game_library`와의 접점은 `module_manifest.tres` 등록뿐이다. per-Kit launcher, content browser, catalog 등록 API를 새로 만들지 않는다.

### 11.5 rejected import 목록

이 모듈은 아래를 **import하거나 참조하지 않는다.**

- `core/services/**` (`SaveService`, `InputRouter`, `AudioService`, `ModuleDirector`, `SettingsService`, `TransitionService`) — `SaveService.is_json_safe`의 판정 **로직**을 `TopDownContentIO`에 모듈 로컬 복사하되, `SaveService` 심볼을 참조하지 않는다.
- `modules/first_entry`, `modules/rule_rewriting`, `modules/odd_road_adventure`, `modules/game_library` — whitelist module이어도 **직접 import 금지**. 기존 `RuleLevelLoader`의 `_is_content_path` 규칙을 §1.3에서 "동일한 규칙"으로 명시한 것은 **규칙을 재사용한다는 뜻이 아니라, 검증 계약을 같게 유지한다는 뜻**이다. 구현은 `TopDownContentIO`에 독립 작성한다.
- `addons/**` — 승인 없는 의존성 금지. GUT 9.7.1은 기존 테스트 의존성이므로 예외다.
- `godot-jrpg` 및 그 파생물 — `11_EXTERNAL_CODE_DECISIONS.md`의 Reject.
- `/root` 탐색, service locator, 범용 EventBus.

### 11.6 기존 loader와의 차이

`modules/rule_rewriting/systems/level_loader.gd`와 **의도적으로 다른 것**을 기록한다. 다음 agent가 "Kit 01이 하는데 왜 이게 안 되냐"고 되돌리면 안 된다.

| 항목 | RuleLevelLoader | TopDown catalog | 이유 |
|---|---|---|---|
| 상태 | 없음(static funcs만) | catalog instance가 record 집합 소유 | §11.3 |
| ID prefix 검증 | 없음 | kind prefix 필수 | subagent 병렬 작성 시 파일 넘김 오류 차단 |
| ID 문법 | 하이픈 허용 | **하이픈·점 금지** | §3.1. `RuleLevelLoader`의 기존 ID가 전부 underscore이므로 호환 문제 없음 |
| path 검증 | `_is_content_path` (private) | 모듈 로컬 `TopDownContentIO` | §11.5 |
| schema | 1 kind(보드) | 18 kind (+`registered_slots`, 현재 빈 array) | 17개 content contract의 공통 규칙이 §2.3 strict allowlist 하나 |
| 중복 처리 | `parse_index`가 `seen_ids`로 reject | catalog 전체 hard stop | §9.1 |
| legacy schema | `version`/`schema_version` 양쪽 지원 | `schema_version`만, 혼용 금지 | legacy 호환은 1회성 비용이고 Kit 04는 처음부터 시작한다 |
| float | 허용 | authored float은 permille int로, save에는 float 없음 | §4.4, §10.3 규칙 4 |
| world vocabulary | 없음 | `02` ladder를 adapter로 대조 | §5.6, §6.1 |

---

## 12. Authored content 추가 방법

### 12.1 절차 10단계

```text
1. kind를 고르고 content/<kind>/ 에 JSON 파일 하나를 쓴다.
2. stable ID를 정한다. kind prefix 필수. §3.1 문법(하이픈·점·대문자 금지). 기존 ID를 재사용/rename하지 않는다.
3. 다른 plan 문서의 계획 ID를 쓰려면 §3.5 표에서 flat ID로 re-key 한다.
4. 기존 ID만 참조한다. 참조하는 kind가 없으면 같은 변경에서 함께 작성한다.
5. content/index.json 의 해당 kind.files[] 에 {id, path} 를 추가한다.
6. idea seed를 1개 이상 planned_retained 상태로 작성하고(§5.2), 서로 다른 kind의 cross-link를 2개 이상 건다.
7. 그 kind에 fixture coverage가 없으면 res://tests/core/fixtures/top_down_action_rpg/ 에 최소/최대/오류 fixture를 추가한다.
8. content validation 테스트를 돌리고 catalog_report를 읽는다. quarantined와 unresolved가 0이어야 한다.
9. 루트 AGENTS.md의 4개 자동 검증을 순서대로 실행한다.
10. modules/top_down_action_rpg/authored/change_ledger.json 에 항목을 append한다.
```

- 단계 3에서 새 kind를 필요로 하면 그 kind의 schema를 먼저 이 문서에 추가한다(§11.1의 slot 등록 절차). content가 schema 없는 kind를 참조하는 상태는 두지 않는다.
- 단계 4에서 `index.json`의 `kinds[]` 순서는 바꾸지 않는다(§7.1). 새 kind는 `registered_slots`에 넣고 §1.2 표에도 순번을 부여한다.
- 단계 6의 seed는 `status: "planned_retained"`으로 쓴다. `used` 승격은 검수 후(§13.7).
- 단계 8에서 `quarantined`가 0이 아니면 **다음 단계로 가지 않는다.** 격리된 content는 완성된 content가 아니다.
- 단계 10은 선택이 아니다. `content/`를 편집하면서 ledger를 안 남기면 Kit 실패다(§15).

### 12.2 core-modification ledger

`modules/top_down_action_rpg/authored/change_ledger.json`, append-only.

```json
{
  "schema_version": 1,
  "entries": [
    {
      "change_id": "chg_001_region_r4",
      "added_content_files": ["content/regions/region_r4_crownwell_archive.json", "content/npcs/npc_01_ilyra_senn.json"],
      "modified_content_files": [],
      "removed_content_files": [],
      "changed_core_files": [],
      "loader_changed": false,
      "validator_changed": false,
      "schema_version_bumped": false,
      "seed_status_changes": [],
      "notes": "동행 NPC와 region을 함께 추가. core 무수정."
    }
  ]
}
```

- `changed_core_files`는 `res://core/**`, `res://app/**`, `res://modules/top_down_action_rpg/domain/**`, `res://modules/top_down_action_rpg/systems/**`, `res://modules/top_down_action_rpg/presentation/**` 에서 실제로 편집한 파일의 `res://` 경로 배열이다. **빈 배열이어야 한다.**
- `loader_changed`/`validator_changed`는 `content/` 아래 파일을 편집했으면 `true`다. `content/` 아래를 손대면 그 자체로 이미 "content 추가가 아님"이므로 함께 기록한다.
- `changed_core_files`가 비어 있지 않은 entry가 하나라도 있으면 **Kit 실패**다. `notes`에 정당화를 쓰더라도 실패는 실패다.
- **`seed_status_changes`는 `[]`여야 한다.** `planned_retained → used` 승격은 `change_ledger`에 사유를 남기되 **별도 entry**로 기록한다(§13.7). 승격이 content 추가와 같은 entry에 섞이면 "무엇이 승격의 근거였는지"가 사라진다.
- entry는 변경마다 하나씩, 시간 순서로, **삭제하지 않는다.**

### 12.3 허용되는 예외 2회

`content/`를 건드리지 않고 content만으로는 표현할 수 없는 동작이 필요할 때, 예외는 정확히 두 종류다.

1. **새 `Effect` op 추가** — 기존 18개 op으로 표현할 수 없는 world 변화가 있을 때. `EffectDefinition` schema_version bump + `TopDownEffect`에 case 1개 추가 + `§4.3` 표 갱신 + 테스트 추가.
2. **새 `status`/`action`/`equipment` 의미 축 추가** — `STAT_KEYS` 9개나 `§4.4.1` damage 축에 없는 축(예: perception)을 mechanic으로 쓰려면. 해당 schema_version bump + 해당 validator 갱신 + 테스트 추가.

조건:

- 예외는 **Reference Game 제작 기간 동안 최대 2회**다. 3번째가 필요하면 그건 Kit 설계가 부족한 것이므로 멈추고 `06`/`01`을 고친다.
- 예외 1회마다 `change_ledger` entry에 `schema_version_bumped: true`로 기록하고, 왜 기존 op으로 못 했는지 `notes`에 쓴다.
- **`act_*.seed_ids`에는 ungrounded rule(§5.3)을 적용하지 않는다.** BS2 구조 규칙에서 온 action은 idea seed가 아니기 때문이다. 대신 `act_*.seed_ids`의 각 id가 해석되는 것만 요구한다. 이 예외도 여기에 기록한다.
- **`target_mode` enum, `turn_cost` 범위, recovery kind 7개, clock kind 6개, combat resource 3개, `region_role` 9개, `craft_family` 3개, `mana_profile` 8개, `concentration_source` 3개, magic status 5개는 예외 대상이 아니다.** 이들을 열면 `01`/`02`/`12`/resolution과의 계약이 renegotiate된다.

예외가 아닌 것(금지):

- content 전용 `match`/`if` 분기 추가
- 특정 enemy/status/region 이름을 아는 combat/movement/save 코드
- `08` root section 추가(§10.2)
- `save_state()` child key 집합 확대
- ID 문법/prefix 규칙 완화
- validator의 strict key allowlist 완화
- `index.json` 외에 catalog이 찾는 다른 manifest
- `planned_retained → used` 승격 자동화(§13.7)
- `magic`을 kind/directory/prefix로 승격하기(§0bis)
- `act_*.craft`에 새 key 추가하기 — `medium`/`tool`/`shape_or_pattern`를 바꿔야 하면 `tool_options`/`shape_or_pattern` **값**을 고치고, vocabulary 자체를 열어야 하면 §12.3 예외 절차를 탄다
- `mana_profile`에 9번째 token 추가하기
- `world.magic`를 `world.resources`/`world.records`와 섞기

### 12.4 제거와 이전

- content 파일 삭제는 가능하지만, 그 파일을 참조하는 모든 정의를 먼저 손봐야 한다(그래야 §9.2 cascade가 안 일어난다). 순서: 참조 제거 → 파일 삭제 → index에서 제거.
- ID는 재사용하지 않는다(§3.3-3).
- region을 두 region으로 쪼개는 것은 기존 region ID를 유지한 채 새 region을 추가하는 것으로 한다. **단, region은 9개 고정이라 쪼개기가 불가능하다.** 쪼개기가 필요해지면 `02`의 world 구조가 바뀌는 것이므로 `02`를 먼저 고친다. magic module 추가는 이 규칙의 예외가 아니다 — `R8`은 `02` §1에 이미 있는 node다(§3.5.1).
- 2회 예외를 이미 소모했고 새 mechanic이 필요해지면, 구현을 멈추고 `06`을 고친다. 그 순서를 넘기지 않는다.

---

## 13. idea-ledger audit — 160 분모, 96 planned-transform gate

### 13.1 분모

분모는 `IDEA_LEDGER`가 **작성에 이미 고정한** 160이다. `index.json`의 options가 아니라 `seed_ledger.json`의 `denominator.extracted_units`가 단일 source다(§5.1).

- 분모는 **원문 줄 수가 아니다**(K-ARPG10, `IDEA_LEDGER` §4).
- core 120개(`S001`–`S120`) + magic supplement 40개(`S121`–`S160`) = **160**이다. `seed_s001`–`seed_s160`이 정확히 한 번씩 존재해야 한다. 이 배열이 곧 분모다. `ledger_incomplete`면 audit 자체가 실행되지 않고 `ready_with_defects`가 된다.
- 중복 seed id는 `duplicate_id`이므로 audit 전에 catalog이 멈춘다(§9.1).
- `dev_` prefix seed는 분모에서 제외한다. 그리고 `seed_s` prefix를 쓸 수 없다(§3.3-8). dev용 seed audit를 만들려면 별도 audit을 쓴다. 이 Kit은 dev seed audit를 요구하지 않는다.
- **분모를 161 이상으로 올리지 않는다**(`§15`). `seed_s001`–`seed_s160` 밖의 번호는 `seed_id_out_of_range`다.

### 13.2 status와 요구 gate

`status == "planned_retained"`와 `status == "used"`가 요구하는 gate는 같다. 차이는 `used`가 `delayed_consequence.effect_id` 해석까지 요구한다는 것뿐이다(§5.2).

| `ledger_usage_class` | 요구 gate | `delayed_consequence` |
|---|---|---|
| `ROOT` | g1..g8 전부 | 필수 |
| `SYSTEM` | g1..g8 전부 | 필수 |
| `MODULE` | g1..g8 전부 | 필수 |
| `ONEOFF` | g1..g8 전부 | 필수 |
| `TONE` | g1, g2, g7, g8 | 선택 |
| `CANDIDATE` | 어느 것도 요구하지 않음. `status != "used"` | 없음 |
| `DROP` | 어느 것도 요구하지 않음. `status != "used"` | 없음 |

`TONE`에서 g3/g4/g5를 요구하지 않는 이유: constitution R10("detail은 두 곳 이상에 연결된다")은 **detail**에 대한 규칙이고, `IDEA_LEDGER`는 `TONE`을 `dialogue/log/format/voice에만 사용`으로 정의한다. voice에 delayed consequence를 강제하면 TONE class가 비어버리고 어조가 world rule이 된다. 이 예외를 명시하지 않으면 다음 agent가 "60%를 지키려면 TONE에도 delayed를 강제해야 한다"고 잘못 보강한다.

#### 13.2.1 magic supplement-specific gate (`S121`–`S160`)

`02` §11.4가 magic seed에 추가한 4개 요구를 `06`의 audit이 data에서 검사한다. `S121`–`S160`이 `planned_retained`이면 아래 셋을 **전부** 통과해야 하고, 하나라도 실패하면 `status`를 `rejected`로 기록해야 한다(§5.2의 `seed_gate_failed_without_rejection`과 같은 강제).

| code | 요구 | 근거 |
|---|---|---|
| `magic_seed_wrong_section` | `ledger_section == "L"` | `IDEA_LEDGER` `## L. Magic supplement`, `02` §11.1 |
| `magic_seed_unbound` | `bindings`에 §6.3의 magic `res_*` 10종 중 하나가 있거나, `cross_link_a`/`cross_link_b`/`bindings`가 `world.magic` sub-record(`concentration_fields`/`body_load`/`circulation`/`crafts`/`contracts`/`glossary`)를 **읽거나 쓴다** | `02` §11.4: "각 magic seed는 `res_*` 또는 `magic` record의 필드 중 하나 이상을 읽거나 쓴다. 둘 다 아니면 `unbound`다" |
| `magic_seed_r8_only` | `bindings`에 `region_r8_folding_school`만 있거나, core roster(`npc_01`–`npc_14`) 참조가 0개다 | `02` §11.4: "각 magic seed는 기존 region family 하나와 기존 core NPC 하나 이상에 concretely binding되어야 한다. `R8`에만 묶이면 `unbound`다" |
| `magic_seed_without_clock_write` | `delayed_consequence.effect_id`의 effect가 `advance_clock`/`set_clock_stage` op을 **하나 이상** 가진다 | `02` §11.4: "축 write만 있고 clock write가 없으면 world에 압력이 없다는 뜻이므로 audit에서 탈락한다" |

- **`magic` record 필드 참조는 content에서 어떻게 표현하는가**: `bindings`/`cross_link`는 kind ID를 받으므로 `world.magic`를 직접 참조할 수 없다. 대신 (a) `res_*` magic key를 `bindings`에 넣거나, (b) 그 seed가 관여하는 `act_*.craft`(§5.5.7)의 `st_*`/`res_*`/`clock_id` 참조를 통해 표현한다. `magic_seed_unbound` 검사는 (a)의 `res_*` 10종과 (b)의 `act_*.craft` 참조를 모두 인정한다.
- **audit은 magic seed의 이론 이름을 기록하지 않는다.** `02` §11.4: "magic theory의 positive label을 audit record에 적지 않는다. label은 `R4` glossary가Filing한 뒤에만 기록한다." `seed_audit.violations[]`와 `audit_note`에 이론 이름이 나오면 `untranslated_theory_label` error.
- **audit은 seed 변환률과 gate만 재고 magic 시스템은 재지 않는다.** `R8`/`FAM-ARPG-19`/`ENC-ARPG-25`의 존재 여부, `world.magic` allowlist, `mana_profile` diversity는 각각 §5.4.1/§5.10.1/§5.11.1/§10.2가 소유한다. 두 책임이 섞이면 audit이 설계 검사가 되어 어느 쪽도 못 하게 된다.

### 13.3 계산식

```text
denominator  = seed_ledger.denominator.extracted_units                  (160)
quota        = seed_ledger.quota.ratio_permille / 1000                 (0.6)
minimum      = seed_ledger.quota.minimum_retained                      (96)
preferred    = seed_ledger.quota.preferred_planned                    (120)

transform( row ) =
    요구 gate 전부 true
    and cross_link_a.kind != cross_link_b.kind
    and cross_link_a.id   != cross_link_b.id
    and delayed_consequence 가 존재
    and delayed_consequence.effect_id 가 해석됨
    and bindings 가 2개 이상 해석됨
    and ( ledger_section != "L"  or  §13.2.1 의 magic gate 3개 전부 true )

planned_retained_transforms = count( status == "planned_retained" and transform(row) )
quota_met = planned_retained_transforms >= minimum
```

- **gate는 `planned_retained` transform 수로 판정한다**(`PLAN_RESOLUTION` §6, `10`의 `test_seed_gate_is_96_distinct_planned_retained_transforms`). `used`/`transformed` 카운터는 **검수 전에는 0이고 gate에 쓰이지 않는다.**
- constitution §1("사용된 idea unit은 최소 60% 구조 변환한다")과 `IDEA_LEDGER` §4("retained transformation queue")가 요구하는 것이 구조 변환이지 mere retention이 아니기 때문이다. `transform(row)`가 그 요구를 표현한다.
- `quota`의 실제 비교는 `minimum` 정수에 대해 한다. float 비교를 하지 않는다. `seed_ledger`가 `minimum`을 `floor`로 이미 검증했으므로(§5.1) 이중 계산이 어긋날 수 없다.
- `preferred`(120)는 참고값이다. 판정에는 쓰지 않는다.
- **`USED`/`TRANSFORMED`를 계획 단계에서 주장하지 않는다.** `02` §11.2의 36개 transformation unit(X01–X36, 그중 X27–X36이 magic supplement)이 `PLANNED_RETAINED`라고 적힌 것은 "구현 완료나 실제 `used` 판정이 아니다"는 뜻이고, `06`의 `status` enum에 `USED`/`TRANSFORMED`가 없다는 것이 그걸 강제한다 → `planning_claim_forbidden` error.
- **core 120 / magic 40을 따로 gate하지 않는다.** `02` §11.1이 두 ledger의 per-ledger 분할을 나란히 적지만, `06`의 `seed_ledger`는 합계 하나만 가진다: denominator 160, hard gate 96, preferred 120. core/magic을 따로 세면 같은 seed를 두 번 세게 되므로, §13.2.1의 magic gate로 "magic이 R8에만 묶이지 않았다"만 보장하고 분모와 gate는 모두 합계로 처리한다.

### 13.4 분산 규칙

- **catalog 전체의 distinct `clock.kind`가 3개 미만이면** `clock_diversity_insufficient` error(§5.6). R07이 요구하는 "서로 다른 속도"의 최소 증거. 이 Kit은 6개가 고정이라 항상 충족하지만, `02` ladder 미공개로 clock이 격리되면 재검사한다.
- **단일 `ledger_section`이 전체 `planned_retained` transform의 25%를 초과하면** `ledger_section_over_share` error. 원장의 **12개 section(A~L)** 중 하나가 quota를 혼자 메우면 "폭넓게 변환했다"는 측정이 되지 않는다. 계산은 정수로 한다: `in_section * 1000 > total * 250`이면 위반. `total == 0`일 때는 이 규칙을 적용하지 않는다(모든 seed가 rejected인 경우 quota 미달이 이미 error다).
- **major branch 6~12 NPC cluster** 요구(`PLAN_RESOLUTION` §7, K-ARPG15)는 §5.10의 `initial_cluster`와 `03`이 소유한다. audit은 `npc_without_relationship` warning으로만 관여하고 직접 세지 않는다. **audit은 seed 변환률을 재고, 분기 규모는 재지 않는다.** 두 책임이 섞이면 audit이 설계 검사가 되어 어느 쪽도 못 하게 된다.
- **`S121`–`S160`의 40개가 `planned_retained` transform의 25%를 초과하지 않아야 한다**는 규칙을 별도로 두지 않는다. `L`은 이미 `ledger_section_over_share`의 계산에 포함되고, magic 40개는 전체 160의 25%보다 작다. 별도 규칙을 추가하면 같은 계산을 두 번 하는 것이고, core와 magic의 비율을 강제하는 규칙은 `02` §11.1의 60% gate에 이미 있다.

### 13.5 report payload

`catalog_report.seed_audit`(§8.3)가 산출물이다. 추가로 `10_TESTS_AND_ACCEPTANCE.md`가 요구하는 수동 검증용으로, audit은 `planned_retained` seed들의 `seed_id → bindings` 목록을 제공해 "이 seed가 어느 화면에서 실제로 보이는가"를 수동 확인할 수 있게 한다. 목록만 제공한다. 통과/실패를 자동 판정하지 않는다.

### 13.6 사용 시점과 게이트

| 시점 | quota 확인 | 결과 |
|---|---|---|
| Stage 4 (load) | `planned_retained_transforms` 계산, `quota_met` 기록 | false여도 load 성공. `ready_with_defects` |
| GUT 자동 테스트 | `quota_met == true` assert | false면 **테스트 실패** |
| 수동 Reference Game 플레이 | `seed_id → bindings` 목록을 사람이 대조 | 보고에 기록 |
| 완료 보고 | `quota_met == true` + `changed_core_files` 전부 비어 있음 + `unresolved_owner_requests == []` | 이 세 개가 **검토 준비 완료의 필요조건** |

- `seed_ledger.gate.blocks_runtime_start == false`이므로 quota 미달로 구현/플레이가 막히지는 않는다. 막히는 것은 **선언**이다.

### 13.7 `used` 승격 규칙 — 자동화 금지

`used` 승격은 사람이 한다. `IDEA_LEDGER`가 "실제 `used` 판정은 구현·검수 후 기록한다"고 명시하므로, validator는 `planned_retained → used`를 자동화하지 않는다.

- 승격은 `seed_*.json`의 `status`를 **직접 편집**하는 행위다.
- 그 편집은 `change_ledger.json`에 **별도 entry**로 남긴다. `seed_status_changes`에 `{seed_id, from, to, evidence}`를 기록한다. `evidence`는 사람이 쓴 판정 근거(어느 화면에서 어느 content로 보였는지)이다.
- 승격의 전제 조건: `transform(row)`가 참이고 `delayed_consequence.effect_id`가 해석된다(§5.2가 강제).
- **승격 자동화 금지 목록**: promotion script, one-shot command, CI hook, catalog load 시 자동 승격, `10`의 테스트가 status를 바꾸는 경로. 전부 금지이며 `10`의 `test_planned_seed_is_not_auto_promoted_to_used`가 repository 전체에서 0개를 검사한다.
- `quota.post_review_counts_toward_gate == false`이므로 승격이 gate를 이미 충족시킨 것으로 재집계되지 않는다. gate는 96개 `planned_retained` transform을 세는 것이고, 그것이 이미 충족된 상태다.

---

## 14. 자동 테스트 목록

`tests/core/test_top_down_content.gd`와 그 파생 파일이 담당한다. GUT 9.7.1 고정. 실패하면 멈추고 기존 실패와 신규 회귀를 구분한다.

### 14.1 content pipeline

- [ ] **18개 kind 전부의 최소 유효 fixture가 parse된다** (`equipment`/`items` 포함 — schema가 이 문서에 있으므로 `READY_WITH_DEFECTS` 예외가 없다)
- [ ] 각 kind의 최소 fixture가 **필수 key 누락**으로 reject된다
- [ ] 각 kind의 allowlist 밖 key가 reject된다(`invalid_schema`)
- [ ] 모든 `enum` 값이 양 끝(첫 값, 마지막 값, 그리고 하나 빠진 중간값)을 검사한다
- [ ] 모든 `range`가 `min-1`, `min`, `max`, `max+1`을 검사한다
- [ ] `array: true` kind의 `records`에 `schema_version`/`id`가 없으면 reject된다
- [ ] `index.json`의 kind 목록에서 하나를 빼면 `index_kind_missing`, 두 번 넣으면 `index_kind_duplicate`
- [ ] `registered_slots`에 항목이 있으면 `slot_unexpected`
- [ ] `entry_region_id`가 `region_h0_undersign_exchange`가 아니면 `entry_region_not_hub`; 해석 안 되면 `CONTENT_UNAVAILABLE`
- [ ] `options.document_page_line_cap`이 9가 아니면 `document_cap_not_nine`
- [ ] `dependencies`/`version` 혼용이 아니라 `schema_version` + `version` 혼용이 `schema_mixed_version`로 reject된다
- [ ] ID 문법: 대문자, **하이픈**, **점**, 숫자 시작, 빈 문자열, 64자 초과, `dev_` prefix
- [ ] `reserved_id` 목록 전부
- [ ] `content/` 아래 파일에 `Color`/path/`importance`가 있으면 reject된다
- [ ] **`axis`가 4개 world axis가 아니면 reject**되고, `axis_at_least.value`가 `02` ladder token이면 `axis_token_in_integer_field`
- [ ] `clock.kind`가 6개 enum 밖에 있으면 reject, `id`↔`kind` 대응 어긋나면 `clock_kind_id_mismatch`
- [ ] `clock.stages[].stage_id`/`index`가 `02` §4.1 ladder 밖이면 `clock_stage_not_in_02_ladder`/`clock_stage_index_off_02_ladder`, `stages`가 7개면 `clock_stage_too_many`
- [ ] `clock.stages[]`의 irreversible이 정확히 하나이고 그 `index`가 4가 아니면 `clock_irreversible_index_off_02_ladder`; `stages[0].index == 5`면 `clock_start_stage_terminal`
- [ ] `recovery.kind`가 7개 enum 밖이면 reject. **`crown_alignment`가 8번째로 들어가면 reject** (`10`의 `test_crown_alignment_is_a_world_write_not_recovery_type`과 대조)
- [ ] **magic failure 3등급(`recoverable`/`continuity-changing`/`terminal`)이 `rec_*.kind`에 들어가면 reject** (recovery type이 아니다, `12` §8/`05` §2.8.1)
- [ ] `08`의 표기(`checkpoint_return`, `clone_branch`, `loop_rehearsal`, `immortal_continuation`)가 `kind`에 있으면 `recovery_kind_token_mismatch`
- [ ] R04 7개 층위의 분할이 겹치면/빠지면 reject된다
- [ ] `rel_*.axes`와 `axis_rules`를 제거해도 relationship 판정 결과가 동일하다(§5.7의 관계 증명)
- [ ] `rel_*.axes`에 `agency`를 넣으면 `relationship_axis_key_unexpected`
- [ ] `rel_*.axis_rules[].sets`에 world axis가 아닌 relationship axis key가 있으면 `relationship_axis_conflated_with_world_axis`
- [ ] `04`의 `stance` token이 `state_id`로 쓰이면 `stance_used_as_canonical_state`
- [ ] `clock.stages[].visible_signal`이 channel별 key 집합(§5.6 표)을 어기면 `visible_signal_key_mismatch`
- [ ] `phase.trigger`/`completion`/`recovery.trigger`/`encounter.activation`의 enum별 key 집합 표를 각각 검사한다(금지 key가 `null`이어도 위반)
- [ ] **모든 error/warning code token이 §5 또는 §8.2에 문서화되어 있다** (`undocumented_error_code`)
- [ ] §5에 문서화된 code가 실제 code 목록에 존재한다 (drift 양방향 검사)

### 14.2 combat vocabulary 정합

- [ ] `intent.target_mode`이 canonical 6개(`SELF`, `ONE_ENEMY`, `ONE_ALLY`, `ALL_ENEMIES`, `ALL_ALLIES`, `RANDOM_ENEMY`)만 통과한다
- [ ] 8개 legacy token(`linked_actor`, `record`, `route`, `resource_node`, `positionless`, `single_enemy`, `all_enemies`, `random_enemy`)이 전부 content validation error이고 runtime에서 조용히 default 되지 않는다
- [ ] `record`/`route`/`resource_node`은 `enc_*.target_roles[]`에서만 쓰인다
- [ ] `linked_actor`는 `enemy_*.linked_actors[].role`과 `enc_*.target_priority[].role`에서만 쓰인다
- [ ] `turn_cost`가 `-1`, `0.5`, `6`이면 reject; `0`/`1`/`2`~`5`는 허용; `full`/`none`/`partial` 문자열은 reject (`10`의 `test_turn_cost_is_bounded_integer_with_three_semantics`와 대조)
- [ ] `turn_cost == 0`이면 `action_slot_cost`가 없어야 한다
- [ ] `turn_cost 2..5`이면 `action_slot_cost == 1`이고 `lifecycle`이 `instant`/`committed`이며 `commitment`가 있다
- [ ] `lifecycle == "charge"`이면 `turn_cost >= 1` + telegraph channel 2개 이상, `reaction` stage는 enemy-owned에만
- [ ] `damage_payload`가 §4.4.1의 21개 축과 1:1이고, `delivery == "true"`면 `dodgeable == false` + `evasion_policy == "disabled"`
- [ ] `hooks`의 7개 key만 허용, `on_hit`과 `damage_payload.on_hit_payload_ids`에 같은 effect가 중복 등록되지 않는다
- [ ] **combat resource가 `hp`/`mp`/`equipment_charge` 3개뿐이다.** `ap`/`max_ap`/`action_points`/`stamina`/`momentum`/`focus`가 어떤 위치에서도 `resource_key_forbidden` (`10`의 `test_no_ap_resource_or_label_exists`와 대조)
- [ ] `enemy_*.condition_bar.kind`가 `hp`/`condition_progress`/`stability` 3개뿐이고, `hp`를 enemy가 선언하면 `condition_bar_on_hp_kind`, advance가 없으면 `condition_bar_without_advance`
- [ ] `enc_*.group`이 `05` §6.1의 5개 concrete template(`GRP-ARPG-01`~`05`)과 `§6.2`의 6개 variant가 resolve된다
- [ ] variant가 `base_encounter_id` + `variant_overrides`로 표현되고, remix 깊이가 1이다
- [ ] **magic action**: `act_*.craft`의 14개 key만 허용되고, `craft`가 있으면 `category == "magic"` + `damage_payload.delivery == "magical"`이다
- [ ] `craft_family`가 `weave`/`rigid_fold`/`void_cut` 3개만 통과하고, `weave`·`rigid_fold`에는 `medium_options`가, `rigid_fold`에는 `fold_count_budget`가, `void_cut`에는 `tool_options`가 필요하다
- [ ] `concentration_source`가 `field`/`body_load`/`social_permission` 3개만 통과하고, `concentration`/`mana`/`mana_pool`은 `resource_key_forbidden`
- [ ] `craft.environment_effect.clock_id`가 6개 canonical clock 중 하나이고, 한 `craft`에 clock이 둘이면 fail
- [ ] `craft.social_recording.resource_id`가 `res_craft_credit`/`res_lineage_token`/`res_contract_tally` 3개만 통과하고, `res_labor_pledge`는 통과하지 않는다
- [ ] `res_contract_tally`에 `amount`가 붙으면 `contract_tally_quantified`, `contract_ref`가 있는데 `res_contract_tally`가 아니면 `contract_ref_without_tally`
- [ ] `craft.failure_status_id`가 magic status 5종 밖이면 `craft_failure_status_not_magic`
- [ ] **`preparation_turns >= 1`인 action과 `preparation_turns == 0`인 action이 같은 `act_*.craft` schema를 쓰고, 준비된 craft가 없으면 실행 action이 `cast_without_prepared_craft`로 resolve되지 않는다** (`12` §11: "preparation and improvisation use the same action schema with different cost/state")
- [ ] **magic status 5종이 catalog에 모두 존재하고**, `st_overflowed.control.blocked_action_categories`에 `magic`이 있으며, `st_concentration_load`/`st_medium_residue`의 `stat_deltas`가 비어 있고, `st_contract_bound.tick.operations`가 비어 있다
- [ ] `mana_profile` 8개 enum만 통과하고, distinct token이 4개 미만이면 `mana_profile_diversity_insufficient`
- [ ] `region_*.concentration`의 `safe_band_permille < threshold_permille`이고, `disperser_charge_key`/`circulation_slot_key`가 `res_disperser_charge`/`res_circulation_slot`이다
- [ ] `world.magic`가 `world.axes`/`world.flags`/`world.clocks`와 섞이지 않고 `region_*.concentration`이 `field_level_permille`을 combat player band에 노출하지 않는다
- [ ] **theory label 금지**: `world.magic.glossary` slot이 `filled == false`인 상태에서 어떤 content field에도 craft 이론의 positive 이름이 없다 (`untranslated_theory_label`)
- [ ] **`R8` data-only**: `region_r8_folding_school`, `enemy_grading_wall`, `enc_fold_that_refuses_the_hand`, magic status 5종, magic `res_*` 10종을 data로 추가하고 `change_ledger`의 `changed_core_files == []`로 통과한다

### 14.3 duplicate / missing / cascade

- [ ] 같은 ID가 2파일 → `duplicate_id` + `content_unavailable`
- [ ] 같은 ID가 다른 kind에서 → `duplicate_id` + `content_unavailable`
- [ ] `records[]` 내부 중복 → `duplicate_id`
- [ ] 존재하지 않는 `region_id` 참조 → referrer 격리
- [ ] 격리 후 referrer도 격리되고, 그 격리가 `quarantined[]`에 순서대로 남는다
- [ ] 8회 cascade 초과 시 `reference_cascade_incomplete`
- [ ] 양방향 대칭 6종(relationship↔npc, npc→conv speaker, region debt↔recovery debt, enemy↔phase owner, region exit↔`02` edge registry, `05` group↔roster anchor) 각각 검사
- [ ] `gate_id`가 서로 다른 (from, to) 쌍에서 중복되면 `gate_id_collision`
- [ ] 자기 참조(`enc.base == self`, `rel.transitions` self-loop, `phase.next == self`) 전부 reject
- [ ] `entry_closure`가 깨지면 `content_unavailable`, 깨지지 않으면 `ready_with_defects`
- [ ] `closure_overflow`가 4096에서 난다
- [ ] `nullable_reference_slots`(§9.3의 8개 슬롯) 밖의 `null`이 전부 reject된다
- [ ] `world_` flag가 25개째에서 `flag_namespace_overflow`
- [ ] `art_key`가 manifest에 없으면 `art_key_unregistered` error
- [ ] **re-key**: `FAM-ARPG-01`, `FAM-ARPG-19`, `ENC-ARPG-01`, `ENC-ARPG-25`, `GRP-ARPG-01`, `VAR-ARPG-01`, `NPC-CONV-ARPG-01`, `NPC-CONV-ARPG-05`, `CL-INST`, `S001`, `S121`, `S160`, `NPC_IONA_VEY`, `PLAYER_BRIDGE_0`, `END_R1_RECEIPT_OF_A_LIFE`가 content에 나타나면 `unrekeyed_planning_id` / `player_id_in_npc_namespace`
- [ ] **retired 계획 ID**: `R-RETURN`, `R-CROWN`, `R-ARCHIVE`, `R-LATENCY`, `R-LEXICON`, `R-VISCERA`, `R-SERVICE`, `R-COMMON`, `R-SEAM`가 content에 나타나면 `unrekeyed_planning_id`이고 대응표가 없어도 통과한다. `region_secondary`가 두 region에 걸치는 record를 표현한다
- [ ] `GRP-ARPG-06` 이후가 content에 나타나면 `unrekeyed_planning_id` (group 5개가 닫힘)
- [ ] `gate_g9*`가 content에 나타나면 `unknown_gate_id`
- [ ] `02` node 9개(`H0`+`R1`~`R8`) ↔ `region_*` 9개가 집합으로 일치하고, `02` edge `E01`~`E18` ↔ `route_e*` 18개가 양방향으로 일치하고, gate `G0`~`G8` ↔ `gate_g*` 9개가 일치한다 (`10`의 `test_region_graph_matches_02_canonical_world`/`test_route_state_vocabulary_is_closed_to_02`와 대조)
- [ ] **`R8`의 `entry.edge_id`와 `exits[0].edge_id`가 둘 다 `route_e18_folding_school_approach`**이고 `exits`가 1개일 때 `internal_routes`가 1개 이상이어서 return affordance가 2개다
- [ ] `HC-00` + `RC-01`~`RC-08`의 9개 `cluster_id`가 9개 `region_*.initial_cluster.cluster_id`와 1:1로 일치하고 전역 유일하다
- [ ] 각 region의 `region_role`이 `02` §1/§7.0 role과 일치하고, 그 region의 모든 enemy/encounter의 `region_role`이 그 region과 일치한다 (`10`의 `test_encounter_catalog_matches_05_counts_and_region_roles`와 대조)
- [ ] 각 `initial_cluster.npc_ids`가 6..12, 각 region이 `revisit_variants` ≥2, `unresolved_debt` ≥1, `exits` + `internal_routes` ≥2
- [ ] field encounter 11개(`ENC-ARPG-01`–`10` + `ENC-ARPG-25`), boss 14개, group 5개, variant 6개, NPC-conversion 5개가 모두 resolve된다
- [ ] `enemy_*.role.base_region_id`가 `enc_*.context.region_id`와 일치하고, `region_secondary`가 있으면 서로 일치한다

### 14.4 equipment / items

- [ ] `equipment`/`items` kind의 `schema_version`, root key allowlist, enum, range, prefix 검사 (`10`의 `test_equipment_and_items_schema_and_allowlist_are_owned_by_06`와 대조)
- [ ] 두 kind가 작성된 파일 0개여도 `READY_WITH_DEFECTS`가 되지 않는다
- [ ] 미해석 `equipment_`/`item_` 참조가 0개다
- [ ] 6개 `floor_role`(weapon/basic attack, granted active skill, resistance-behavior, action-slot source, no-turn item, field pass key)이 catalog에 모두 존재한다 (`test_equipment_floor_reuses_action_economy`와 대조)
- [ ] `item.use.action_id`의 action이 `category == "item"`이고 `cost.turn_cost == 0`이다
- [ ] `equipment_`/`item_` 수량이 `max_equipment_definitions`/`max_item_definitions`을 넘지 않는다
- [ ] `equipment.field_keys.traversal_key`와 `region.resource_flow.*`가 §6.3의 `res_*` 목록(53개 = core 43 + magic 10) 안에 있다
- [ ] §6.4의 비수량 debt key(`res_labor_pledge`, `res_contract_tally`)가 `traversal_key`나 `surplus_keys`에 없으면 안 되고 `amount`를 갖지 않는다

### 14.5 save

- [ ] **`save_state()`의 root key 집합이 `08` §4.2의 12개와 정확히 같다** (allowlist 밖 root key 0개). 이전 이름 `created_content_revision`이 남아 있으면 fail
- [ ] 각 `08` section의 child key 집합이 §10.2 표와 정확히 같다 (allowlist 밖 child key 0개). `progression.inventory`/`progression.quest_state_by_id` 같은 `08`에 없는 이름이 없어야 한다
- [ ] `rec_*.preserves` token 집합이 §10.2의 `STATE_TOKEN` 27개와 일치한다
- [ ] `rec_*.discards` token 7개 중 payload에 대응 field가 있는 것이 3개뿐(`scheduler_cursor`, `combat_transient`, `encounter_progress`)이고 나머지 4개는 어디에도 없다
- [ ] payload 안 어디에도 float이 없다(recursive scan)
- [ ] `SaveService.is_json_safe(payload)` true
- [ ] `JSON.stringify` → `parse` → `load_state` → `save_state`가 **정확히 같다** (float 없음)
- [ ] 각 child key의 stale/범위초과/타입오류 값이 clamp된다
- [ ] 존재하지 않는 ID가 `world.props`/`world.npcs`/`world.records`/`world.flags`/`world.magic.*`에서 drop된다
- [ ] 없는 `field.region_id`가 fallback 순서(`recovery.history` → closure 첫 region → `content_unavailable`)를 따른다
- [ ] **`combat`이 있으면 전투를 resume하지 않고 encounter `activation` 경로로 재진입한다** (§10.4-7)
- [ ] `combat`의 scheduler/action slot/actor/status/phase/charge stage가 load 후 모두 비어 있다
- [ ] charge stage 또는 reaction window에서 save하면 payload에 그 상태가 구조적으로 들어가지 않는다 (`combat_midstate_in_payload` 경로가 0)
- [ ] `content_revision` 불일치 후에도 load가 성공하고 진행이 보존된다
- [ ] `migrate_save`가 이전 version fixture를 새 child key로 옮긴다. 특히 root `created_content_revision` → `save_version` + `content_revision`, `progression.inventory`/`quest_state_by_id` → `progression.equipment`/`items`/`conversations`/`documents`
- [ ] 60분 scripted run payload가 262144 bytes 이하
- [ ] presentation-only 상태가 payload에 없음을 확인하는 테스트(§10.2)
- [ ] `clock_irreversible`이 payload에 없고 load 시 `02` ladder에서 재계산된다
- [ ] **`world.magic` 6종 child allowlist가 §10.2 표와 정확히 같다** (`concentration_fields`, `body_load`, `circulation`, `crafts`, `contracts`, `glossary`)
- [ ] `res_contract_tally` 카운터가 payload에 없고 `world.magic.contracts`의 `obligation_state == "open"` 수로 재계산된다
- [ ] `res_labor_pledge`/`res_contract_tally`의 `world.resources` entry에 `amount`가 없다
- [ ] `st_concentration_load`/`st_medium_residue`의 threshold 도달 bool이 payload에 없고 load 시 재계산된다
- [x] `08`가 `world.magic`와 `progression.equipment_slots`를 확정했다. 두 값은 `catalog_report.unresolved_owner_requests`에 남지 않는다.
- [ ] `world.flags`는 `08` §4.2에 이미 있으므로 **`loop` recovery가 `ready_with_defects` 사유가 아니다** (이전 version의 잔여 결함 제거 확인)

### 14.6 seed audit

- [ ] `seed_ledger`가 없으면 `content_unavailable`
- [ ] `extracted_units = 160`보다 seed가 많으면 `seed_id_out_of_range`
- [ ] `seed_s001`..`seed_s160` 중 하나가 없으면 `ledger_incomplete`
- [ ] `ledger_incomplete`이면 `seed_audit`가 비어 있다(가짜 통과 방지)
- [ ] `minimum_retained`가 `floor(units * ratio/1000)`과 다르면 `ledger_quota_arithmetic_mismatch`. 160 × 600 / 1000 = 96
- [ ] `quota.gate_status_token`이 `planned_retained`가 아니면 `quota_token_mismatch`
- [ ] `quota.post_review_counts_toward_gate == false` 강제
- [ ] **`planned_retained` transform이 96 미만이면 `ledger_quota_unmet`** (테스트 실패)
- [ ] **content와 plan 문서에 `USED`/`TRANSFORMED` claim이 0개**이고 `planning_claim` key가 schema에 없다 (`test_planned_seed_never_claims_used_or_transformed_in_planning`과 대조)
- [ ] 모든 `planned_retained`/`used` seed의 `delayed_consequence.effect_id`가 해석된다
- [ ] 모든 `planned_retained`/`used` seed의 `cross_link_a.kind != cross_link_b.kind` 그리고 `cross_link_a.id != cross_link_b.id`
- [ ] `CANDIDATE`/`DROP`이 `used`이면 `candidate_marked_used`
- [ ] gate 실패 + `status == "planned_retained"`이면 `seed_gate_failed_without_rejection`
- [ ] `TONE` class에 gate 8개가 없어도 `planned_retained`는 허용된다
- [ ] 단일 section이 25% 초과면 `ledger_section_over_share` (12개 section A~L 기준)
- [ ] `rejection.class` 5개 enum 밖에 있으면 reject
- [ ] `provenance.no_original_wording_copied == false`면 `source_copy_risk`
- [ ] 양방향 `seed_ids` ↔ `bindings` 대칭
- [ ] `ONEOFF` seed가 `bindings` 중 `npc`/`prop`을 정확히 1개만 갖고, 2개면 `oneoff_binding_not_local`
- [ ] **`planned_retained → used` 승격 경로가 repository에 0개**이고, 승격이 있었다면 `change_ledger`에 별도 entry로 남아 있다 (`test_planned_seed_is_not_auto_promoted_to_used`/`test_used_seed_counts_only_after_review`와 대조)
- [ ] `used`로 승격된 모든 seed의 `delayed_consequence.effect_id`가 해석된다 (`test_used_promotion_requires_resolved_delayed_effect`와 대조)
- [ ] **`S121`–`S160`이 전부 `ledger_section: "L"`**이고 `S001`–`S120`이 `L`이 아니다
- [ ] **`S121`–`S160`의 `planned_retained` seed가 §13.2.1의 4개 gate를 통과한다** — magic `res_*`/`world.magic` 참조 존재, `R8`-only 아니고 core NPC 참조 ≥1, clock write ≥1
- [ ] **magic seed의 `audit_note`/`violations[]`/content 어디에도 craft 이론의 positive 이름이 없다**

### 14.7 boundary

- [ ] `modules/top_down_action_rpg/**` 의 모든 `.gd`의 `preload`/`load`가 `res://modules/top_down_action_rpg/`, `res://core/contracts/`, `res://tests/` 셋 중 하나
- [ ] `core/contracts/` import가 `entry.tscn`/`module.gd`에서만 일어나고, `GameModule`/`ModuleContext`/`ModuleManifest`/`ModuleResult` 4개뿐
- [ ] `/root`, `get_node("/root")`, `Engine.get_singleton`, `InputMap.action_add_event`(module 코드), `add_to_group` 남용이 없음
- [ ] `SaveService` / `InputRouter` / `AudioService` / `ModuleDirector` 심볼 참조가 없음
- [ ] `RuleLevelLoader` / `odd_road_adventure` / `first_entry` / `game_library` 심볼 참조가 없음
- [ ] `autoload` 추가가 없음(`project.godot` diff 확인)
- [ ] `TopDownContentIO.is_json_safe`가 `SaveService.is_json_safe`와 8종 입력에서 같은 verdict를 낸다
- [ ] catalog deep hash가 10분 scripted run 전후 동일하다(§11.3)
- [ ] catalog이 2개 인스턴스로 만들어지면 두 인스턴스가 서로 오염되지 않는다
- [ ] `change_ledger.json`의 모든 entry가 `changed_core_files == []`이고 `seed_status_changes == []`(승격은 별도 entry)
- [ ] **`R8`/`FAM-ARPG-19`/`ENC-ARPG-25` 추가가 `changed_core_files == []`로 통과한다** (`07` §14.1 A1, `02` §12). magic 층이 새 combat system/enum을 요구하면 실패다
- [ ] `modules/top_down_action_rpg/` 아래에 fixture ID(`fx_`)가 없고, `tests/core/fixtures/top_down_action_rpg/` 아래에 `seed_s`/`region_`/`npc_` 같은 live prefix가 없다
- [ ] **production `.gd`에 authored stable ID가 0개**, dialogue literal이 0개 (`test_no_authored_id_or_dialogue_literal_exists_in_production_gd`). **magic 이론의 positive 이름도 0개** — `glossary` slot이 Filing되기 전엔 코드가 그 이름을 알 수 없다
- [ ] `content/magic/` 디렉터리와 `magic_` prefix ID가 없고, `index.json.kinds[]`에 `magic`이 없다
- [ ] `02` ladder 값이 `TopDownWorldLadder`에 하드코딩되지 않았고, `02`에서 읽는다

### 14.8 schema bump 경로

- [ ] `EffectDefinition`에 새 op을 추가하면 `status_tick_op_not_allowed` 검사가 유지된다
- [ ] `STAT_KEYS`에 stat 축을 추가하면 `StatusDefinition.stat_deltas`, `EquipmentDefinition.stat_modifiers`, `EnemyDefinition` stats가 함께 갱신된다
- [ ] `08`의 root section이 추가/이름 변경되면 `TopDownSaveProjection.section_allowlist()`가 같은 변경에서 갱신된다
- [ ] `save_version` bump 시 `migrate_save`가 이전 fixture를 처리하고, 참조하는 `rec_*`도 함께 bump된다
- [ ] `act_*.craft`에 key를 추가하려면 `§12.3` 예외 절차를 탄다. 새 key가 `medium`/`tool`/`shape_or_pattern`를 표현하지 못하면 추가하지 않는다 — `tool_options`/`shape_or_pattern` 값으로 충분해야 한다
- [ ] `mana_profile`에 token을 추가하면 §5.5.7 `body_profile_requirements`, §5.11.1 diversity floor, §10.2 `world.magic.body_load` shape가 함께 갱신된다
- [x] `08`가 `world.magic`/`progression.equipment_slots`를 확정했고 `unresolved_owner_requests` 0건이다.

---

## 15. 금지 shortcut

- [ ] content ID를 아는 `if`/`match`를 `domain/`, `systems/`, `presentation/` 어디에도 넣지 않는다
- [ ] `content/` 안에서 `preload` 하드코딩으로 definition을 참조하지 않는다
- [ ] validator 없이 raw `Dictionary`를 runtime truth로 통과시키지 않는다
- [ ] `index.json` 대신 디렉터리 순회로 content를 찾지 않는다
- [ ] 중복 ID를 "먼저 선언된 걸 쓴다"로 처리하지 않는다
- [ ] 없는 참조를 조용히 무시하거나 기본값으로 대체하지 않는다
- [ ] `presentation_class`로 danger/disabled를 표현하지 않는다
- [ ] color/red로만 정보를 전달하지 않는다
- [ ] `game_over`를 recovery 경로 대신 쓴다
- [ ] combat transient를 save에 넣어 전투 중간을 resume한다
- [ ] `charge`/`reaction` window를 save/load로 복원한다 (pre-command intent + encounter checkpoint만 허용)
- [ ] `art_key` 자리에 `.png` 경로나 `Color`를 넣는다
- [ ] `closed enum`을 content가 필요하다는 이유로 열면 §12.3 절차 없이 interpreter를 늘린다
- [ ] `§5` schema에 없는 field를 임시로 추가한다
- [ ] `dev_` content가 release 산출물에 남는다
- [ ] `seed_s`를 하나 더 만들어 161로 분모를 올린다
- [ ] `status`를 `planned_retained`에서 `used`로 올리는 자동화 스크립트·hook·CI 단계를 만든다
- [ ] 계획 문서에 `USED`/`TRANSFORMED`를 주장한다
- [ ] `content/`를 편집하면서 `change_ledger` entry를 안 남긴다
- [ ] `equipment`/`items` schema를 `01`에만 남기고 여기를 비워 둔다
- [ ] `ap`/`max_ap`/AP label/gauge를 어느 파일에도 reintroduce한다
- [ ] generic red bar를 `target_hp_or_condition` 대신 만든다
- [ ] `02` ladder를 `06`에서 하드코딩해 두 번째 source를 만든다
- [ ] 다른 plan 문서의 계획 ID(`FAM-ARPG-01`, `FAM-ARPG-19`, `ENC-ARPG-25`, `GRP-ARPG-06`, `R-RETURN`, `R-LATENCY`, `NPC_IONA_VEY`, `S001`, `S121`, `END_…`)를 content에 그대로 쓴다
- [ ] ID에 점(`.`)이나 하이픈을 넣는다
- [ ] `08` root에 key를 추가한다
- [ ] `document.reading.max_lines_per_page`를 9보다 크게 선언한다
- [ ] validation 실패를 조용히 통과시키거나, 실패한 content를 화면에서 숨기기만 한다
- [ ] **`magic`을 kind로 만든다** (`content/magic/`, `magic_` prefix, `index.json.kinds[]`에 `magic`) — §0bis
- [ ] **단일 `mana` resource, 전역 `concentration` 막대, craft 라벨 `mp` pool을 만든다** — §2.7
- [ ] **`concentration`을 `world.axes`나 `world.clocks`에 넣는다** — §6.1, §5.10.1
- [ ] **region 9개를 8개로 되돌리거나, edge를 `E01`–`E17`로 잘라낸다** — §3.5.1/§3.5.2
- [ ] **group을 6개 이상 만든다** — `05` §6.1이 5개로 닫았다
- [ ] **magic failure 3등급을 `rec_*.kind`로 쓰거나 제8 recovery type을 만든다** — §5.8
- [ ] **`res_contract_tally`에 `amount`를 주고 combat balance처럼 소비한다** — §6.4
- [ ] **`st_contract_bound`가 스스로 tick down하거나 obligation을 combat cost로 쓴다** — §5.4.1
- [ ] **magic theory의 positive 이름을 content·script·dialogue·audit에 쓴다** — §0bis, `glossary` slot이 Filing되기 전
- [ ] **`R8` 추가를 핑계로 core 시스템·loader·save codec·target enum을 수정한다** — `changed_core_files == []`가 성공 조건
- [ ] `08` root에 이미 있는 `world.flags` container를 다시 "미확정 결함"으로 남긴다

---

## 16. 완료 증거

- [ ] `catalog_report.outcome == "ready"`
- [ ] `catalog_report.counts.quarantined == 0`, `references_unresolved == 0`
- [x] `catalog_report.unresolved_owner_requests == []` — `01` turn_cost 상한 5, `08` `world.magic`/`equipment_slots`, `09` art key registry가 모두 확정되었다. `02` clock/axis ladder와 `08` `world.flags`도 확정되어 목록에 없다.
- [ ] `catalog_report.seed_audit.quota_met == true`, `planned_retained_transforms >= 96`
- [ ] `catalog_report.seed_audit.used == 0` 또는 검수 후 기록된 값이고 `change_ledger`에 근거 entry가 있다
- [ ] `catalog_report.errors`에 `ledger_*`, `art_key_unregistered`, `clock_diversity_insufficient`, `clock_stage_not_in_02_ladder`, `axis_value_off_02_ladder`, `magic_*`가 없음
- [ ] `change_ledger.json`의 모든 entry가 `changed_core_files == []`
- [ ] §12.3 예외를 2회 이하로 사용
- [ ] §14 전체 테스트 통과 기록
- [ ] **새 region 1개 + encounter 1개 + NPC 1명 + relationship 1개를 data만 추가해서 통과** — core 파일 diff 0을 PR에 붙인다. 단 region은 9개 고정이므로 "새 region"은 `02` world 구조 변경이 accompany된 경우이고, 일반적인 content 확장 증명은 새 encounter/variant/equipment/item이다
- [ ] **새 equipment 1개 + 새 item 1개(6개 floor_role 중 미구현 role)를 data만 추가해서 통과** — 6개 role이 combat/field 양쪽에서 실제 동작함을 수동 플레이로 확인
- [ ] **새 magic action 1개(`act_*.craft`의 `craft_family`/`medium_options`/`shape_or_pattern`/`tool_options`만 변경)와 새 magic status 0개로 통과** — `12` §11의 "medium/tool/shape changes result without code modification"과 `05` §2.8.1의 "new status key 금지"를 함께 증명. core diff 0
- [ ] **새 clock stage를 `02` ladder에 추가한 뒤 content만 고쳐 통과** — core diff 0
- [ ] **`R8 The Folding School` 1개 + `E18` + `RC-08` cluster 1개 + `enemy_grading_wall` 1개 + `enc_fold_that_refuses_the_hand` 1개를 data만 추가해서 통과하고 `change_ledger`의 `changed_core_files == []`** — `07` §14.1 A1, `02` §12
- [ ] fixture의 최소/최대/오류 케이스가 실제로 사용된다(죽은 fixture 0)
- [ ] `res://core/**`, `res://app/**` diff 0
- [ ] `project.godot` diff 0
- [ ] seed 120개 중 어떤 것이 어느 화면에서 보이는지 수동 대조 기록
- [ ] 1280×720 / 1920×1080 / 2560×1440에서 combat band(HP/MP/status/action-slot text)와 `target_hp_or_condition` bar가 겹치지 않는 캡처
- [ ] **1280×720 / 1920×1080 / 2560×1440에서 `concentration_field`·`mana_profile`·`contract_tally`가 상시 HUD나 world map에 노출되지 않는 캡처** — `02` §12: "네 axis와 여섯 pressure clock은 상시 HUD로 노출하지 않는다. `concentration`도 예외가 아니다"

---

## 17. 상태

- schema: **DEFINED** — 18 kind(`ledger`, `seeds`, `effects`, `statuses`, `actions`, `equipment`, `items`, `clocks`, `relationships`, `recovery`, `props`, `regions`, `npcs`, `conversations`, `documents`, `phases`, `enemies`, `encounters`) + `registered_slots`(현재 빈 array). **magic은 kind가 아니다**(§0bis)
- combat vocabulary 정합: **DEFINED** (target mode 6개, `turn_cost` 정수 0..5, damage payload 21축, resource 3개, `target_hp_or_condition` 단일 이름)
- magic / concentration 층: **DEFINED** (`act_*.craft` 14 key, magic status 5종 floor, `mana_profile` 8 enum + 4 diversity floor, `region_*.concentration` 8 key, `res_*` magic 10종 + 비수량 debt 2종, `world.magic` sub-record 6종, magic seed gate 3종)
- world 규모: **DEFINED** — region 9개(`H0`+`R1`~`R8`), `region_role` 9 token, edge 18개(`E01`~`E18`), gate 9개(`G0`~`G8`), event cluster 9개(`HC-00`+`RC-01`~`RC-08`), group 5개(`GRP-ARPG-01`~`05`), NPC 14 core + 7 support(`npc_20_*`~`npc_26_*`)
- re-key 표: **DEFINED** (`02` node/cluster/edge/gate, `03` NPC/ending, `04` roster + `R8` support resident, `05` family/encounter/group/variant/conversion/clock/status + magic 5 status + magic `res_*` 10종, `08` recovery type). **retired**: `R-RETURN`/`R-CROWN`/`R-ARCHIVE`/`R-LATENCY`/`R-LEXICON`/`R-VISCERA`/`R-SERVICE`/`R-COMMON`/`R-SEAM`, `GRP-ARPG-06`~`12`, `role.region_ids[]`(→ `region_secondary`)
- load order: **DEFINED** (6 stage)
- validation/error catalogue: **DEFINED** (STAGE 1/2/3/4 + kind별 + magic vocabulary 24개 + magic audit 7개)
- save projection: **DEFINED** — `08`이 root 12개 key와 8개 section, `06`이 section 내부 per-kind allowlist와 `STATE_TOKEN` 27개(§10.2)
- loader/registry boundary: **DEFINED** (18 validator + 5 shared unit)
- authored content 추가 절차: **DEFINED** (10단계)
- idea-ledger audit: **DEFINED** (160 → 96 `planned_retained` transform gate, 자동 승격 금지, magic-specific gate 3종)
- `content/` 실제 파일: **NOT STARTED**
- **`01` 확인 필요**: 없음. `turn_cost` 상한 5는 `01` §8.4에 명시되어 있다. **`08` 확인 필요 2건**: 없음. `world.magic`와 `progression.equipment_slots`가 root에 있다. **`09` 확인 필요**: 없음. art key registry가 §12.10에 있다.
- **해소된 stale 결함**: `02` clock full stage ladder + irreversible index, `02` axis↔integer mapping, `02` §3.2 initial matrix의 ladder 재키, `08` `world.flags` container, `region_role_split_unresolved` 경고
- 구현: **NOT STARTED** (`README.md` §3의 구현 순서 2단계)
- 완료 상태: **계획 중** — 본 문서는 `06_AUTHORED_CONTENT_AND_DATA.md` 단독 작성이다. 다른 plan 파일과 `README.md`의 status 갱신은 별도 작업이다.
