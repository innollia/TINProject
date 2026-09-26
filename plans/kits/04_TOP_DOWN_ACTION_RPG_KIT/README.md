# Kit 04 — Top-down Action-RPG

> 2026-09-26: 기존 Kit를 제작 기반으로 사용하는 새 콘텐츠 재기획 인터뷰 진행 중. 기존 세계관·인물·사건은 새 콘텐츠의 승인 정본이 아니다. [현재 사용자 결정과 인터뷰 상태](docs/GRILLING_STATE.md)를 먼저 읽는다. 구현·이미지 제작 재개를 의미하지 않는다.

공통 계약: `docs/KIT_WORKFLOW.md`  
세계 헌장: `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`  
아이디어 원장: `docs/research/top_down_action_rpg/IDEA_LEDGER.md`  
Primary Reference: **BLACK SOULS 2 하나**

## 0. Kit 목적

새 콘텐츠 작업 입구: [15 새 World 초안](15_NEW_WORLD.md). 이 문서는 기존 제작 계약을 사용하며 구세계의 교체 구현 지시가 아니다. 지도·사건·독립 집필 규칙은 [새 세계 제작 정본](world_new/00_MAP_AND_AUTHORING.md)을 따른다.

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
| [13_LAYERED_ENVIRONMENT_PRODUCTION.md](13_LAYERED_ENVIRONMENT_PRODUCTION.md) | 큰 장면 배경, clean base, 가림·소품·상태 레이어, 지역별 제작 범위, 샘플 선행 검수 |

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
- field 카메라는 지면 기준 하향각 60°의 정사영 탑다운이다. 수직에서 30° 기울어지며 방위는 고정한다. 완전 수직 90° 시점이 아니다.
- 2026-09-26 사용자 요청으로 Kit 04 이미지 샘플 제작이 허용됐다. 배경은 타일 필수가 아닌 큰 장면 그림과 분리 레이어가 기본이다. 문서 갱신 → 샘플 → 검수 → 사용자 검토 후 양산 순서를 따른다. 상세 계약은 13이 소유한다.
- 2026-09-26 사용자 결정: 코드로 그린 그림(아이콘 조합, 도트, SVG/Pillow 절차 그림)을 이 Kit의 최종 그림으로 허용한다. 이 Kit에서는 위 at-icons 줄, §4의 at-icons 금지, 공통 문서의 GPT 최종 그림·생성기 화풍 게이트보다 이 결정이 우선한다. 같은 날 판정을 기다리던 생성형 도구 화풍 시험은 전부 불합격 처리됐다. 코드 그림도 candidate로 시작하고 승인은 사용자만 한다. 같은 날 사용자 결정으로 아이콘 조합의 코딩 금지도 해제한다: 코드를 짜서 아이콘을 조합해도 된다(보관된 at-icons 문서의 편집기 전용·코드 생성 금지 미적용).

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

환경 자산은 13의 구역 brief와 레이어 샘플을 먼저 검수한다. 지역 하나를 그림 한 장으로 축소하거나, 이번 H0 샘플을 Reference Game 완료로 세지 않는다.

## 4. Hard prohibitions

- plan 없는 구현
- content ID/문구/dialogue의 core script hardcode
- one battle/one map completion claim
- generic `알아서`, `게임답게`, `레퍼런스 느낌으로`
- placeholder ColorRect/Label world
- constant shell HUD
- adult sexual content
- at-icons as current art basis (2026-09-26 사용자 결정의 코드 그림 허용은 예외, §2)
- external godot-jrpg framework import without file-level audit
- Retired Prototype reuse
- shared combat/player/inventory/event abstraction before second real use

## 5. Status

- shared understanding: **CONFIRMED**
- world constitution: **WRITTEN**
- idea ledger: **WRITTEN — planned usage, not completion proof**
- split plan: **WRITTEN** (01–13)
- implementation: **DONE — 자동 게이트 전부 통과**
- catalog: **313 files / 19 kinds**, region 9 · edge 18 · gate 9 · cluster 9 · NPC 21 · enemy 19 · encounter 37 · recovery 7 · group 5 · variant 6 · npc_conversion 5
- automated gates: `run_tests` 644/644 · core GUT 19/19 · module GUT 20/20 · import 0 · smoke 0 · playthrough probe **exit 0 / coverage 14/14**
- Reference Game human playthrough: **NOT STARTED** — 실측 플레이타임 없음
- 720p/FHD/QHD pixel evidence: **NOT PRODUCED** — headless는 PNG를 생성하지 않음
- final art: **NOT APPROVED** — vector presentation이 현재 화면, Gold Standard 없음

**현황 정본**: [IMPLEMENTATION_STATUS_2026-09-27](../../../docs/research/top_down_action_rpg/IMPLEMENTATION_STATUS_2026-09-27.md).
아직 결정되지 않은 9개 항목(A–I)이 그 문서 §6에 있다. 다음 작업자는 그 항목을 먼저 읽을 것.

`tests/core` 전체 GUT의 무관 실패 5건(`test_rule_*` 4건, `test_stone_story_rpg_core` 4 script error)은 Kit 04 소유 범위 밖이며 손대지 않았다.
