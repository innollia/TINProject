# Kit 06 `sideview_ecosystem` — 구현 현황 · 인계

> 이 파일은 사실 기록이다. 테스트를 돌리지 않은 것을 통과로 쓰지 않는다.
> 결정은 `GRILLING_STATE.md` §5.1, 규격은 `plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md`가 정본이다.

상태: **domain·로더·콘텐츠 1차안 완료, systems·화면 미착수** (2026-09-27, 첫 세션 종료)

## 0. 다음 작업자가 먼저 읽을 것 (이 순서)

1. `AGENTS.md` '병렬 세션 작업' — 같은 폴더·같은 브랜치(`kit/05-stone-story-rpg`), 소유 경로만 커밋, Godot 잠금.
2. 이 파일 전체.
3. `GRILLING_STATE.md` §5.1 — 결정 14건(에이전트 추천, **사용자 확인 대기**).
4. 계획서: 머리말 → §16.2(테스트 wave 순서) → §21(정정 목록 E-01~E-20) → 작업할 절만. 19만 자라 통째로 열지 않는다.

소유 경로: `modules/sideview_ecosystem/**`, `tests/core/test_eco_*.gd`, `plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md`, `docs/research/rain_world/**`. Godot 잠금 이름 `kit06`.

## 1. 결정 (에이전트 추천 — 사용자가 뒤집으면 그 답이 이긴다)

- **물 0건 유지.** 근거만 "세계가 물을 금지"에서 "`ROUND_PLAN` §11.2의 '물이 장면의 조건이 되면 실패'를 이 Kit에 적용한 결과"로 바꿨다. `test_eco_no_water_systems`가 집행한다(Q1).
- Q2~Q14(Kit 슬롯, 조사 주체, 입력 5 action, 전이 통행료, `integrity`는 축에 안 씀, 사다리 파일 없으면 스토어 상수, 스토어 주입 등)는 `GRILLING_STATE.md` §5.1 표.
- 이번 세션 중 추가로 고친 계획서 모순: **E-19** `fix.gardener`=`arc_brood`(speck), `fix.mirror`=`arc_warden`(hand) — 원래 값은 "개체 rung ≤ 룸 band"(CV-06)와 충돌했다. **E-20** den은 낼 수 있는 모든 스테이지를 band 검사하고, 개체 rung 2택은 band 이하 후보 중에서 고른다. 없던 §9.14(ability 경계 상수)·§9.15(상수가 사는 파일)를 채웠다.

## 2. 커밋

| 커밋 | 내용 |
|---|---|
| `97cc2d07` | 계획서 §10~§21 작성(빈칸 0), 모순 18건 정정, `GRILLING_STATE` §5.1 |
| `f568f7c3` | domain 13파일 + `systems/` 3파일 + wave D0 테스트 5개 |
| 이 커밋 | 계획서 E-19·E-20·§9.14·§9.15 등, content 25룸·아키타입 5, authoring 도구, 로더 테스트 2개, 이 인계 문서 |

## 3. 만든 파일

| 경로 (`modules/sideview_ecosystem/` 기준) | class_name | 계획서 |
|---|---|---|
| `domain/trait.gd` | `EcoTrait` | §4.2, §9.14 |
| `domain/ladder.gd` | `EcoLadder` | §10.6 — `ladder.json`이 없어 지금은 `AxisBody.SCALE_RUNGS`로 만든다 |
| `domain/body_rung.gd` | `EcoBodyRung` | §4.3, §6.1, §9.1 상수 |
| `domain/rung_table.gd` | `EcoRungTable` | §4.3-3 |
| `domain/passage_kind.gd` · `gap_class.gd` · `passage_spec.gd` | `EcoPassageKind` · `EcoGapClass` · `EcoPassageSpec` | §4.6, §10.2 |
| `domain/tile_kind.gd` | `EcoTileKind` | §10.3 |
| `domain/room_spec.gd` · `region_spec.gd` · `content_index.gd` | `EcoRoomSpec` · `EcoRegionSpec` · `EcoContentIndex` | §5.1, §10 |
| `domain/world_state.gd` · `transition_state.gd` · `toll.gd` | `EcoWorldState` · `EcoTransitionState` · `EcoToll` | §6.2, §6.3, §4.5 |
| `systems/passage_resolver.gd` | `EcoPassageResolver` | §4.6, §4.9 `passable` |
| `systems/transition_rule.gd` | `EcoTransitionRule` | §4.5 표 |
| `systems/region_loader.gd` | `EcoRegionLoader` | §10.5 전 항목. `load_all(table)` / `load_from_texts(texts, table)` |
| `content/**` | — | §10.7: 4영역 25룸, 아키타입 5, 링크 그래프 |

테스트(`tests/core/`): `test_eco_no_water_systems.gd`, `test_eco_forbidden_systems.gd`, `test_eco_no_lore_exposure.gd`, `test_eco_ladder_and_rungs.gd`, `test_eco_passages.gd`, `test_eco_region_loader.gd`(4개 중 2개만).

authoring 도구: `docs/research/rain_world/authoring/kit06_rooms.py`. **룸 좌표는 사람이 정한 값이고, 이 스크립트는 그 좌표를 JSON으로 옮기며 검사만 한다(난수·자동 배치 0, 게임은 이 스크립트를 모른다).** 룸을 고칠 때는 스크립트를 고치고 `python docs\research\rain_world\authoring\kit06_rooms.py`로 다시 만든다. JSON만 직접 고치면 다음 재생성 때 사라진다.

**아직 없는 것:** `domain/save_codec.gd` `body_axis.gd` `creature_axis.gd`, `systems/`의 나머지 전부(§5.1: `region_graph` `step_director` `collision_resolver` `player_body` `transition_system` `settle_system` `creature*` `ai_*` `den_system` `id_allocator` `social_table` `creature_contact` `save_service` `worldstate_bridge`), `module.gd` `module_manifest.tres` `audio_events.tres` `entry.tscn`, `presentation/**`.

## 4. 테스트 결과

| 날짜 | 범위 | 결과 |
|---|---|---|
| 2026-09-27 | wave D0 5파일 (`-gprefix=test_eco_`) | 5 scripts · 27 tests · **24 pass · 3 pending** · 389 asserts · 종료 코드 0. pending 3개 = `entry.tscn` / `module_manifest.tres` / `presentation/`이 아직 없음(계획서 §11.0·§16.2대로) |
| 2026-09-27 | content 25룸 + `test_eco_region_loader.gd` | **Godot으로 아직 안 돌렸다**(Godot 잠금을 다른 세션 kit01이 쥐고 있었음). authoring 스크립트 자체 검사(룸 크기·rect 빈칸·갭 폭·낙하 높이·소금·쉼터 발판·exit 짝과 길이)는 통과 |

전체 자동 검증(`AGENTS.md` 4명령)은 아직 안 돌렸다.

## 5. 다음 순서 (계획서 §16.2 wave)

1. **이 Kit 테스트를 돌린다**(계획서 §16.1 명령). content가 실제 로더를 통과하는지 여기서 처음 확인된다. 오류가 나면 `errors` 목록의 reason과 위치를 보고 authoring 스크립트나 로더를 고친다.
2. **D1 나머지:** `test_eco_region_loader.gd`에 `test_eco_loader_rejects_each_reason`·`test_eco_content_extension_without_core_change`(§15.4) → `systems/region_graph.gd` + `test_eco_region_graph.gd`(G1~G6, §15.3 검산표) → `test_eco_scale_rung_contract.gd`의 1·2·4·8·9.
3. **S wave:** `test_eco_transitions` `test_eco_player_physics` `test_eco_creatures` `test_eco_save_and_flow` `test_eco_worldstate_handover`와 그 systems, `save_codec`, `body_axis`·`creature_axis`·`worldstate_bridge`, `module.gd`, `module_manifest.tres`, `audio_events.tres`.
4. **P wave(화면):** §11.0 — `ProceduralBodyPart`·`ProceduralCreatureBuilder`·`ProceduralSquishRig`는 done, `ProceduralScaleFit`은 없음(§20 OQ-1). S wave가 전부 통과한 뒤 시작.
5. **마무리:** 전체 자동 검증 → M-01~M-12(화면 뒤에만 가능) → 이 파일 갱신 → 커밋·푸시.

## 6. 밟기 쉬운 것

- `domain/`·`systems/`의 `.gd`에 **`1.0` 리터럴 금지**(정수 `1`을 float 자리에 쓴다). rung 값(`0.05` `0.12` `0.28` …)은 같은 줄에 `scale`·`rung`·`band`·`ladder`가 있으면 금지. 판정 방식은 계획서 §16.3.
- **물 토큰은 부분 문자열로 잡힌다:** `flood`(flood fill), `pool_`(pool_size), `breath`, `swim` 등을 식별자·문자열에 쓰지 않는다.
- **설명 장치 토큰은 식별자 조각으로 잡힌다:** `history` `story` `memo` `letter` `note` 계열. `memory`는 괜찮다.
- **인벤토리·카르마 조각 금지:** `item` `tool` `loot` `coin` `shop` / `score` `progress` `threshold` `unlock` `karma`. 전이 진행도는 `elapsed`로 쓴다.
- 난수는 `Procedural.derive_seed(...).make_rng()`만. `randi(` `randf(` `RandomNumberGenerator.new(` 금지.
- `domain/`·`systems/` 문자열에 authored id(`filter_bed_00`, `arc_maw`, `gap_at_01_wide` 같은 꼴)와 `get_node(` 금지(§18.1).
- 코드 주석 금지(`CODE_STYLE`). 새 `class_name`을 만들면 `--editor --import`를 먼저 돌린다.
- **룸 기하는 1차안이다.** 링크 그래프(§10.7)와 로더 규칙에는 맞췄지만 몸이 실제로 지나가는지는 물리 구현 뒤 M-01에서만 확인된다. 특히 GAP 구멍을 아래에서 위로 되돌아가는 자리(`ash_terrace_01` `ash_terrace_03` `bone_shelf_02` `bone_shelf_04` `seed_vault_01`)는 점프 도달 거리가 빠듯하다.

## 7. 정본 반영 대기 (이 세션 소유가 아님 — 각 소유자가 반영)

- **W0:** `plans/kits/INDEX.md`에 06·07·08 행, `res://content/scale/ladder.json`, 모듈 등록(`ROUND_PLAN` C3), `app_root` 입력 바인딩, `attach_world_store` 배선, `project.godot` aspect(`keep` vs 계획서의 `expand`, §20 OQ-4).
- **W1:** `docs/world/00_CONSTITUTION.md` 불변식 0-2와 `11_CONFLICTS_WITH_PLANS.md` N1이 폐기된 "물 금지" 판을 인용한다.
- **W2:** `ProceduralScaleFit.signature(q)`.
- **W3:** 오디오 wav 14개(§12).
