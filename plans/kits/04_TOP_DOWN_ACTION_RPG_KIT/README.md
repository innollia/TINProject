# Kit 04 — Top-down Action-RPG

공통 계약: `docs/KIT_WORKFLOW.md`  
세계 헌장: `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`  
아이디어 원장: `docs/research/top_down_action_rpg/IDEA_LEDGER.md`  
Primary Reference: **BLACK SOULS 2 하나**

## 0. Kit 목적

TINProject의 한 게임 안에서 top-down command/target RPG 구간으로 전환하기 위한 기반이다. field exploration, action scheduling, Guard/Dodge/Break, status, equipment, NPC interaction cluster, recovery, multi-clock world state를 한 Kit로 묶는다.

Reference Game은 한 보스·한 맵 demo가 아니다. 여러 region, NPC cluster, encounter family, recovery path, world-state threshold를 같은 core 위에서 재사용한다.

## 1. 계획 파일

| 파일 | 책임 |
|---|---|
| [01_SYSTEM_UX.md](01_SYSTEM_UX.md) | combat grammar, field grammar, input, scheduler, target, recovery UX |
| [02_WORLD_STATE_AND_ROUTES.md](02_WORLD_STATE_AND_ROUTES.md) | map constitution, regions, orthogonal axes, pressure clocks, route gates |
| [03_STORY_AND_ENDINGS.md](03_STORY_AND_ENDINGS.md) | world narrative, partial resolutions, event clusters, endings, romance/affection |
| [04_CHARACTERS_AND_RELATIONSHIPS.md](04_CHARACTERS_AND_RELATIONSHIPS.md) | character schema, NPC dossiers, relationship state, one-off dialogue |
| [05_ENEMIES_AND_ENCOUNTERS.md](05_ENEMIES_AND_ENCOUNTERS.md) | enemy data, telegraphs, counters, phases, encounter authoring |
| [06_AUTHORED_CONTENT_AND_DATA.md](06_AUTHORED_CONTENT_AND_DATA.md) | JSON/Resource formats, loader, validation, seed ledger integration, core reuse |
| [07_REFERENCE_GAME.md](07_REFERENCE_GAME.md) | 10분+ content flow, authored content floors, repeat/re-entry, authored expansion proof |
| [08_SAVE_DEATH_AND_RECOVERY.md](08_SAVE_DEATH_AND_RECOVERY.md) | versioned JSON, death, recovery, clone/loop/identity semantics, reset |
| [09_PRESENTATION_ART_AND_AUDIO.md](09_PRESENTATION_ART_AND_AUDIO.md) | field/combat/dialogue/document presentation, current GPT image asset boundary, audio |
| [10_TESTS_AND_ACCEPTANCE.md](10_TESTS_AND_ACCEPTANCE.md) | automated tests, manual play, 720p/FHD/QHD, evidence and forbidden shortcuts |
| [11_EXTERNAL_CODE_DECISIONS.md](11_EXTERNAL_CODE_DECISIONS.md) | godot-jrpg and external dependency decision |
| [12_MAGIC_THEORY.md](12_MAGIC_THEORY.md) | concentration craft, weave/fold/void portal, magic institutions and magic-era module |

## 2. Settled design constraints

- 문장 단위 idea seed 사용을 허용한다. 특정 NPC 대사의 one-off mention도 유효하다.
- 독립 idea unit 최소 60%를 구조 변환한다. 원문 line count는 quota denominator가 아니다.
- world는 하나의 deep system 안에 여러 module/era를 가진다.
- 왕관은 literal object, political institution, metaphysical invariant의 세 층위다.
- root law는 여러 recovery/recognition/authority protocol의 meta-system이다.
- player는 investigator이면서 experiment/subject다.
- institutions는 local competence와 interface failure를 가진다.
- orthogonal axes는 2~4개, pressure clock은 복수다.
- major branch는 6~12 NPC interaction cluster다.
- romance와 affection은 허용한다.
- body horror는 허용한다.
- explicit sexual content는 제외한다.
- 앨리스와 원작 고유 skin은 사용하지 않는다.
- at-icons 조립은 현행 제작 기준으로 사용하지 않는다.
- 이미지 생성/editing은 명시적 자산 제작 요청이 있을 때만 수행한다.

## 3. Implementation order

1. plan split files와 world constitution을 merge/검토한다.
2. content schema와 최소 vertical slice를 작성한다.
3. field/command/target/scheduler/status/break core를 구현한다.
4. NPC interaction cluster와 event state를 구현한다.
5. enemy/encounter data와 presentation을 연결한다.
6. AppRoot manifest, game_library, ModuleContext input, save를 연결한다.
7. authored content를 추가하며 core 수정 여부를 측정한다.
8. 자동 테스트, 실제 플레이, 해상도 캡처를 실행한다.
9. 사용자 플레이 검토 전에는 `검토 준비 완료`까지만 선언한다.

## 4. Hard prohibitions

- plan 없는 구현
- content ID/문구/dialogue의 core script hardcode
- one battle/one map completion claim
- generic `알아서`, `게임답게`, `레퍼런스 느낌으로`
- placeholder ColorRect/Label world
- constant shell HUD
- adult sexual content
- at-icons as current art basis
- external godot-jrpg framework import without file-level audit
- Retired Prototype reuse
- shared combat/player/inventory/event abstraction before second real use

## 5. Status

- shared understanding: **CONFIRMED**
- world constitution: **WRITTEN**
- idea ledger: **WRITTEN — planned usage, not completion proof**
- split plan: **REVIEW READY — canonical resolution과 magic supplement 반영 완료. 구현·검수 증거는 아직 없다**
- implementation: **READY TO START — 계획 게이트 통과**
- Reference Game: **NOT STARTED**
