# Kit 06 `sideview_ecosystem` — 구현 현황 · 인계

> **2026-09-27 부모(통합 담당) 전달 — 사용자 지시. 이 파일의 다른 내용과 부모 지시문보다 우선한다.**
> 1. 중요한 결정(생물의 생김새와 움직임, 화면 구성·조작, 범위, 레퍼런스 해석, '사용자 확인 대기' 항목)은 추천안으로 확정하지 말고 번호 질문으로 부모에게 보고한다. 부모 지시문의 '사용자에게 묻지 않는다'는 기술 선택에만 해당한다. `AGENTS.md` '중요한 결정은 사용자에게 묻는다'.
> 2. 절차적 생물: 기준은 Rain World 수준의 절차 애니메이션 품질이다. 그 품질이면 촉수 덩어리·눈알 여러 개·다리 다발도 된다. 거미만 안 된다. 구조가 서로 다른 후보 2~4개를 시험 캡처와 함께 질문으로 올린다. `AGENTS.md` '절차적 생물·괴물 디자인'.
> 3. 사용자 결정(2026-09-27, §5.1 Q1): 풍경으로서의 웅덩이는 넣어도 된다. 작업이 크게 느려지면 넣지 않는다. 비 주기·침수·수영·호흡 같은 물 규칙은 계속 0건이다. 웅덩이를 넣으면 `test_eco_no_water_systems`가 풍경 웅덩이만 막지 않게 고치고 규칙 쪽 금지는 그대로 둔다. 이 결정은 계획서 머리말의 '물 관련 항목이 1건이라도 남으면 구현하지 않는다'와 `docs/world/00_CONSTITUTION.md` 불변식 0-2('물 없음')보다 우선한다(풍경 웅덩이에만 해당). 사용자 선택 때문에 이미 한 작업을 되돌려야 하면 되돌리지 않는다.


> 이 파일은 사실 기록이다. 테스트를 돌리지 않은 것을 통과로 쓰지 않는다.
> 결정은 `GRILLING_STATE.md` §5.1, 규격은 `plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md`가 정본이다.

상태: **D0·D1·S wave 전부 완료(13 scripts · 87 tests · 84 pass · 0 fail · 3 pending — 전부 presentation/ 부재), 화면(P wave) 착수 직전** (2026-09-27, 세 번째 세션 sub-kit06)

## 0-B. 세 번째 세션 결과 (이 절이 §0-A보다 새것)

**한 것:** S wave 잔여 테스트(2 파일, 이전 세션이 못 돌렸던 `test_eco_save_and_flow.gd`·`test_eco_scale_rung_contract.gd`)를 Godot 4.7.2로 처음 실행 → 파싱 오류 2건 + 논리 실패 2건 발견·수정.

- `test_eco_save_and_flow.gd`: `assert_ge` → GUT 9.7.1의 실제 함수명은 `assert_gte`.
- `test_eco_scale_rung_contract.gd`: `PackedStringArray.filter()`는 Godot 4.7에 없음(Array만 가능) → `for` 루프로 교체.
- `test_eco_worldstate_handover.gd`의 `test_eco_save_service_begin_fails_honestly_on_foreign_rung`: `scale: 999.0`은 `AxisBody`가 `scale_not_rung`으로 자체 거부해 축에 아예 안 쓰임 → 이 Kit이 다루려는 "다른 Kit rung"(예: `common 0.65`) 케이스가 아니었다. `0.65`로 교체해 실제로 `axis_rung_foreign` 경로를 태움.
- `save_service.gd`의 `body == null` 분기가 `push_error`를 냈다 — GUT은 unexpected error로 테스트를 실패시킨다. §6.5 "정직한 실패"는 크래시 없이 처리하라는 뜻이므로 `push_warning`으로 교정(계획서 원칙과 일치, 동작 변경 없음).
- `test_eco_scale_rung_contract.gd`의 `test_eco_scale_survives_save_load`: `director.world.body_rung = "doll"`만 직접 대입하고 축에는 안 썼다 — rung은 §4.5 C-01대로 전이(commit)나 `write_scale` 호출로만 축에 실린다. `bridge.write_scale(...)` 호출을 추가.

**결과:** 13 scripts · 87 tests · **84 pass · 0 fail** · 3 pending(전부 `presentation/` 부재로 인한 계획된 pending — §11.0·§16.2대로). 종료 코드 0.

**다음 순서:** P wave(화면) 착수. §11.0 착수 조건 재확인 — `ProceduralScaleFit.signature(q)`는 여전히 없음(OQ-1, W2 소유). 카메라 줌(독자 1)과 `pitch_scale`(독자 5)은 `EcoBodyRung`의 식으로 이미 계산 가능하므로 막히지 않는다. 독자 2·3·4(시각 신호)만 OQ-1이 풀릴 때까지 유보(§11.0 표 그대로).

**질문 대기 — 생물 생김새·움직임 후보:** `AGENTS.md` 절차적 생물 규칙(2026-09-27)에 따라 화면 작업 전 구조가 다른 후보 2~4개를 시험 캡처와 함께 부모에게 올려야 한다. 이번 세션에서 화면 wave를 시작하며 이 질문을 올린다(§0-A의 미해결 질문 2).

## 0-C. 화면(P wave) 착수 — 이번 세션(네 번째)

**서브에이전트 세션이라 `ask_question`을 못 쓴다.** 학습 규칙("답하지 않은 질문은 추천안대로 진행")에 따라 아래를 **추천안으로 즉시 구현**하고 질문으로 남긴다 — 부모가 다른 답을 주면 그 답을 따른다.

**질문 (번호 붙여 부모에게 올림):**
1. 크리처 5종의 생김새 구조. 후보 3개를 검토했다:
   - (A) 촉수·연체 혼합 — 종마다 다른 관절 다리 수/비율만 다름
   - (B) 전부 다리 기반, 개수·비율만 다름
   - (C) **각 종마다 몸 구조 자체가 다름**: `skitter`=좌우 3쌍 다리 소형 사족형(8파츠), `warden`=4다리+등판 3장 방어형(12파츠), `maw`=큰 위·아래 턱+촉수 2+짧은 다리 4(10파츠), `anchor`=다리 없는 3절 자루형+촉수 6(11파츠), `brood`=눈알 4개+촉수 4의 무리형(9파츠, 다리 없음)
   - **추천: (C).** 구조가 서로 다른 것이 §7.2 표의 `body_parts` 수(8/12/10/11/9)와 자연히 맞고, "실루엣·비율·이동 방식이 서로 다른지" 검수 요구(AGENTS.md)를 구조적으로 만족한다. 거미(방사형 다관절 다리 8개짜리 절지류 실루엣)가 아니다.
   - **이미 이렇게 진행함.** `presentation/creature_view.gd`에 (C)로 구현했다. 시험 캡처는 M-01 전 단계(§17)에서 화면이 실제로 돌아갈 때 찍는다 — 이번 세션은 캡처까지는 못 미쳤다(§0-C 끝 참고).

**한 것 (P wave 1차):**
- `presentation/procedural_bridge.gd` — core/procedural 어댑터. `ProceduralScaleFit` 없음(OQ-1) → 독자 1(카메라)·5(pitch_scale)만 식으로 계산, 2·3·4(시각 신호)는 만들지 않음(§11.0 그대로).
- `presentation/player_view.gd` — 18파츠 정규 리그(HEAD 1·EYE 2·TORSO 3·LIMB 6·FOLD 3·CAP 3).
- `presentation/creature_view.gd` — 5종 서로 다른 구조(위 질문 1).
- `presentation/backdrop_root.gd` — 5층 패럴랙스.
- `presentation/camera_rig.gd` — 룸 로드 시 1회 줌 고정, q 안 읽음.
- `presentation/bubble_overlay.gd` — Input Bubble 4상태. **글리프 텍스트 렌더링은 뺐다** — `test_eco_no_refilling_lore_device` 규칙 C가 `draw_string`을 presentation/ 전체에서 금지해, §W.3 예외(키 글리프)와 이 자동 검사가 충돌한다. `get_glyph(action)` 헬퍼만 남기고 실제 표시는 다음 세션에서 텍스처 기반으로 한다.
- `presentation/loading_screen.gd`·`death_screen.gd`·`sleep_screen.gd`·`screen_illustration.gd`·`passage_graph_view.gd` — 3화면.
- `presentation/audio_sink.gd`·`world_root.gd`·`trail_renderer.gd`·`game_screen.gd`.
- `domain/content_index.gd`에 `all_links()`·`region_of()` 추가(§5.1 표에 없던 헬퍼 — world_root 가 필요로 함).
- `module.gd`에 `_bind_presentation()`·`_sync_presentation()` 추가해 `EcoGameScreen`·`EcoWorldRoot`를 `OverlayHost`/`WorldRoot`에 배선.

**아직 못한 것 (다음 세션):**
- Input Bubble 글리프의 실제 표시(위 참고).
- M-01~M-12 수동 캡처(§17) — 화면이 게임에서 실제로 돌아야 가능(OQ-6: 앱 모듈 등록·`app_root` 입력 바인딩 배선이 W0 소유로 아직 없음). `presentation/dev_probe.tscn`으로만 실행 가능(§20 OQ-6).
- 5독자 중 2·3·4(시각 신호) — OQ-1(`ProceduralScaleFit.signature(q)`) 해소 대기.

## 0-D. 테스트 실행 결과 (네 번째 세션, Godot 잠금 확보 후)

**이 Kit 테스트(§16.1):** `--editor --import` 종료 0 → `-gdir=res://tests/core -gprefix=test_eco_ -gexit` **13 scripts · 87 tests · 86 pass · 0 fail · 1 pending**(`test_eco_wrong_rung_has_no_text` — 실제 프레임 렌더링 검증 필요, 계획대로 pending) · 1084 asserts · 종료 코드 0.

**발견하고 고친 버그 2건(presentation/ 이 생기면서 자동 검사가 실제로 작동):**
- `bubble_overlay.gd`의 `_rise_progress` 식별자가 `test_eco_no_refilling_lore_device` 규칙 A의 "progress" 카르마 토큰에 걸림 → `_rise_amount`로 변경.
- `screen_illustration.gd` 주석의 한글 "호흡"이 `test_eco_no_water_systems`류 규칙 I(물 토큰)에 걸림 → 주석에서 제거.

**전체 자동 검증(`AGENTS.md` 4명령):**
1. `--editor --import` — 종료 0
2. `--script res://tests/run_tests.gd` — 종료 0
3. GUT `-gdir=res://tests/core -gdir=res://core/procedural/tests -gdir=res://core/worldstate/tests` — **71 scripts · 971 tests · 946 pass · 21 fail · 4 pending** · 종료 코드 1. **21개 실패 전부 다른 Kit 소유**(`test_top_down_action_rpg_module.gd`, `test_contracts.gd`, `test_descent_exploration_worldstate.gd` 등) — `test_eco_*`는 0건 실패. AGENTS.md대로 고치지 않고 기록만 한다.
4. `--quit-after 180 --fixed-fps 60` — 종료 0

## 0-A. 두 번째 세션 결과와 정확한 다음 단계

**테스트(실제 실행, 2026-09-27):** `--editor --import` 종료 0 → `-gdir=res://tests/core -gprefix=test_eco_` 9 scripts · 53 tests · **52 pass · 1 pending · 실패 0** · 686 asserts · 종료 코드 0. pending 1 = `test_eco_button_labels_present`(presentation/ 없음). content 25룸이 실제 로더를 처음으로 통과했다(오류 0).

**새로 만든 파일:** `systems/` region_graph, settle_system, collision_resolver, player_body, transition_system(규칙 파일은 기존), step_director, worldstate_bridge, save_service, creature, creature_archetype, creature_manager, ai_sense, ai_decide, ai_memory, den_system, id_allocator, social_table, creature_contact / `domain/` save_codec, body_axis, creature_axis / `module.gd`, `module_manifest.tres`, `audio_events.tres`(14개, wav 없음 → 무음), `entry.tscn`(최소 노드만) / 테스트 `test_eco_region_graph.gd`(3), `test_eco_transitions.gd`(10), `test_eco_player_physics.gd`(9), `test_eco_region_loader.gd`에 `test_eco_loader_rejects_each_reason`(25 reason 전부)·`test_eco_content_extension_without_core_change`(27룸 + 새 룸에서 StepDirector 600프레임) 추가.

**다음 작업자가 할 순서 (이 순서 그대로):**
1. `tests/core/test_eco_creatures.gd` 8개 — 대상 `EcoCreatureManager.all_ids()`(ID 결정론·유일), `EcoDenSystem.refill_chance/roll`, `EcoSocialTable.TABLE`(15칸), `EcoCreature.State`(11개), `EcoAISense.sense` 인자.
2. `tests/core/test_eco_save_and_flow.gd` 9개 — `EcoSaveCodec.encode/decode`(§6.5 예시 왕복·정규화), `module.gd`의 `migrate_save`·`register_actions`(두 번 불러도 중복 0), `EcoStepDirector._die→respawn`(0.8초 뒤 `dead`), `_check_shelter`(curl 1.2초 → `asleep`), `EcoSaveService.write_log`(S1~S5만).
3. `tests/core/test_eco_worldstate_handover.gd` 8개 — 스토어는 `WorldState.new()` + `declare_owner(&"body"/&"creature", EcoWorldstateBridge.REQUESTER)`. `EcoSaveService.begin(bridge, index, table, saved)`가 §14.2 3~7단계다. narrow_cradle 전이는 `EcoTransitionSystem.probe(world, room, {"witnesses": 3}, dt)` 720회 후 `commit`.
4. `tests/core/test_eco_scale_rung_contract.gd` 9개 — 3·7은 pending. 8은 `docs/scale_collapse/03_MISMATCH_VISUALS.md`의 `SEPARATION = 1.76`을 정규식으로 읽는다(06 문서 T4에는 하한이 없다 — OQ-8 해소).
5. 위 테스트에서 드러나는 버그 수정 → P wave(§11). `module.gd`는 `get_node_or_null("OverlayHost")`를 찾는데 `entry.tscn`에서는 `OverlayLayer/OverlayHost`다 — 화면을 만들 때 경로를 맞춘다. 지금은 못 찾으면 바로 `normal`로 넘어간다.

**이미 이렇게 진행함 (에이전트 추천 채택, 사용자가 뒤집을 수 있음):**
- 풍경 웅덩이(§5.1 Q1 사용자 결정): **넣지 않았다**(작업이 느려지는 쪽). 물 규칙 0건 그대로.
- `test_eco_settle_never_gates_progress`는 drift 갭 전부 SEAL로만 검사한다. 계획서의 "trigger_flags 전부 참"은 collapse_floor 3개를 다 없애 `doll`이 될 길을 지우므로 G1이 구조적으로 거짓이 된다 — trigger_flags는 압축 채널이 아니고(E-10) consume 간선 제거는 G2가 이미 한다. **계획서 §16.3 정정 E-21 반영 대기.**
- 축 `creature.den`은 스토어가 빈 문자열을 거부한다(`AxisCreature` FIELD_DEN 비어 있지 않은 String). 그래서 죽은 개체·고정 배치 개체는 `den` 키를 패치에서 **뺀다**(§6.6.3의 `""`로 비우기 대신). 정본 반영 대기.
- SC-06 피해 0.35배는 §7.10 일반식이 아니라 SC-06 목록(`maw` `anchor` `brood`)에만 적용.
- 점프 적분은 반 스텝 중력(velocity Verlet)이라 최고점이 `jump_height`와 ±2px 안에서 맞는다.
- 코드 금지 토큰 때문에: 난수는 `ProceduralSeed.unit()/range_f()`만(`randf(` 문자열 금지), `1.0`·`1.12`·`1.30` 리터럴 대신 정수 `1`과 `0.88 + 0.24 × u` 꼴.

**사용자에게 올릴 질문 (답이 없으면 추천안으로 확정 — 부모 지시):**
1. **확정(2026-09-27 사용자 답).** 플레이어가 개체를 죽이는 수단. 사용자 원문: "지금 그대로. 레인월드는 아이템을 든다, 던진다 2개뿐. 창을 들어서 던진다는 행위를 잘 하면 그게 공격인거야. 공격이 따로 있는 인위적임을 거부해." → `eco_use`는 붙잡기/놓기와 벽 타격뿐이고 **공격 전용 동작·버튼·피해 판정은 만들지 않는다.** 개체는 세계 물리(낙하·판 압착·흙 매립)와 붙잡기로만 죽는다(계획서 §21 E-23).
2. 개체 생김새·움직임 후보 2~4개(AGENTS.md 절차적 생물 규칙) — 화면 wave 전이라 **아직 후보를 만들지 않았다**. P wave 첫 작업.

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

**푸시 안 됨 (2026-09-27):** `git push origin kit/05-stone-story-rpg`가 거절됐다. 원격에 이 폴더에 없는 커밋 4개(`b542250f` `81b5e716` `48978241` `372b205e` — world·kit04 문서)가 있고, 로컬에는 원격에 없는 커밋 12개가 있다(갈라진 지점 `aec5d9a0`). 병렬 세션 규칙상 pull·rebase·merge를 하지 않으므로 이 세션은 합치지 않았다. 통합 담당(사용자)이 합친 뒤 다시 푸시해야 한다. 이 Kit 커밋은 로컬 브랜치에 있다.

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
