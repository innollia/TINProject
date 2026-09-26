# Top-down Action-RPG Kit 04 — 구현 상태 / 인수인계

작성: 2026-09-27. 갱신: 2026-09-27 05시 KST — Kit 04 코드·검증 세션 종료 기록(§8). 이 문서가 Kit 04 구현의 **현황 정본**이다.
관련 정본: [README](../../../plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/README.md) · [세계 헌장](WORLD_CONSTITUTION.md) · [계획 resolution](PLAN_RESOLUTION.md) · [아이디어 원장](IDEA_LEDGER.md)

Primary Reference는 **BLACK SOULS 2 하나**다. `godot-jrpg`는 파일 단위 감사 없이 채택하지 않았고, 개념만 참고했다.

---

## 1. 현재 판정

**사용자 플레이 검토 전 단계.** Kit 04 core·module GUT와 playthrough probe는 2026-09-27 03시 실행에서 통과했다(§3). visual capture는 16개 상태 × 3개 해상도 전부에 도달하고 창 모드에서 PNG 48장을 남긴다. **승인된 그림이 하나도 없어서(missing art key 12개) capture 판정은 `failed`가 맞다.**

그 뒤에 넣은 마지막 수정(§8.3)은 Godot 잠금이 계속 다른 세션에 있어 실행 검증 전이다. 다음 작업자는 §8.6부터 한다. 전체 자동 검증(`AGENTS.md` 완료 전 자동 검증 4단계)은 이 세션에서 돌리지 않았다.

`AGENTS.md` 기준으로는 "검토 준비 완료"까지만 선언 가능하다. 실제 플레이타임 측정과 사람 눈 해상도 검수는 아직 없다.

---

## 2. 카탈로그现状

`modules/top_down_action_rpg/content/index.json` — **313 files / 19 kinds**

| kind | count | kind | count |
|---|---|---|---|
| ledger | 1 | props | 31 |
| seeds | 1 (160 records) | regions | 9 |
| effects | 57 | npcs | 21 (14 core + 7 support) |
| statuses | 6 | conversations | 26 |
| actions | 38 | documents | 14 |
| equipment | 6 | phases | 17 |
| items | 2 | enemies | 19 |
| clocks | 6 | encounters | 37 |
| relationships | 15 | recovery | 7 |
| | | | |

구조 floor:

- region 9 (`region_h0_undersign_exchange` + `region_r1`~`region_r8`)
- edge 18, **gate 9** (`gate_g0_arrival_declaration` … `gate_g8_crown_precedence`)
- event cluster 9, pressure clock 6
- recovery 7 canonical kind 전부: `checkpoint` / `respawn` / `clone` / `reincarnation` / `loop` / `immortality` / `institutional_reentry`
- ending 6 canonical: `TopDownActionRpgContentLoader.CANONICAL_ENDING_IDS`
- encounter 37 = authored 26 + variant 6 + intake stamp 1 + second registration 1 + 기타
- group 5: `GRP-ARPG-01`~`05` (catalog 전역 유일, 각 1 encounter)
- npc_conversion encounter 5 (region 도달 가능 기준)
- seed ledger: denominator 160 / gate 96 / core 120

---

## 3. 게이트 재현 명령

Godot: `C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`

```powershell
# 1) import
godot --headless --path C:\projects\TINProject --editor --import
# 2) TIN tests
godot --headless --path C:\projects\TINProject --script res://tests/run_tests.gd
# 3) Kit 04 core
godot --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_top_down_action_rpg_core.gd -gexit
# 4) Kit 04 module
godot --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_top_down_action_rpg_module.gd -gexit
# 5) smoke
godot --headless --path C:\projects\TINProject --quit-after 180 --fixed-fps 60
# 6) playthrough probe  (--output 은 workspace 밖 절대 경로 필수)
godot --headless --path C:\projects\TINProject --script res://tests/performance/top_down_action_rpg_playthrough_probe.gd -- --output <abs-out-dir>\ --require-canonical-coverage
# 7) visual capture      (--output-dir 은 존재하지 않는 절대 경로 필수)
godot --headless --path C:\projects\TINProject --script res://tests/performance/top_down_action_rpg_visual_capture.gd -- --output-dir <abs-new-dir>
```

### 최근 실행 결과

2026-09-27 03:01~03:15 KST, Kit 04 코드·검증 세션(§8.2 수정 반영 후, §8.3 수정 전):

| 게이트 | 결과 |
|---|---|
| Kit 04 core GUT | **19 / 19**, 7116 asserts |
| Kit 04 module GUT | **21 / 21**, 4984 asserts (wait page 회귀 테스트 포함) |
| playthrough probe | **exit 0**, assertions 54 / failed 0, events 85 |
| visual capture headless | 48/48 상태 도달, state_failures 0, static 0, runtime 51 → `failed` |
| visual capture 창 모드 | 16/16 상태, PNG **48/48**, runtime 51(그림 없음 48 + 선택지 글 잘림 3) → `failed` |
| import / `run_tests.gd` / 전체 GUT / smoke | **이 세션에서 안 돌림.** 아래는 이전 기록: 644/644, smoke exit 0 |

probe 상세:
```
coverage   items=14 unreached=0 strict=true missing=[]
route      regions=5 edges=5 gates=4 driven=[route_e01_ash_stair]
budget     total_seconds=7223 required_seconds=3418 encounters=17/33 distinct_units=163
surfaces   seen=23 required=22 missing=[]
```

이전 기록(이 세션 전): `run_tests.gd` 644/644, core 19/19(7076 asserts), module 20/20(4966 asserts), smoke 180f exit 0.

`tests/core` 전체 GUT에는 **Kit 04 외 무관 실패 5건**이 남아 있었다(소유권 밖이라 건드리지 않음): `test_rule_combat_integration`, `test_rule_screen_art_links`, `test_rule_route_content`, `test_rule_ui_art_links`, `test_stone_story_rpg_core`(4 script error, `art/stone_rpg_art_view.gd:1068`).

---

## 4. 이번 세션에서 처리한 것

### 4.1 canonical coverage 6 → 0

probe의 `CANONICAL_COUNTS` 14항목이 전부 도달한다.

| 항목 | 이전 | 조치 |
|---|---|---|
| `route_gate` | 8/9 | `gate_g8_crown_precedence`가 loader `CANONICAL_GATE_IDS`에 **이미 있었고 content만 누락**이었다. R7 `route_e13_crown_stair` exit을 G8로 전환(`gate_g4` → `gate_g8`, requires_condition도 동일 게이트로), `eff_r7_crown_precedence_filed`에 `unlock_route` op 추가 |
| `recovery_type` | 2/7 | `rec_r3_hospice_respawn` / `rec_r2_census_clone` / `rec_r8_lineage_return` / `rec_r7_verge_loop` / `rec_r4_crown_continuity` 추가. 보존/손실 층은 계획 `08` §7 표에서 가져옴 |
| `npc_conversion` | 3/5 | R6의 `combat_content.encounter_ids`에 누락돼 있던 `enc_r6_the_organ_quorum` 복원. `enc_r1_second_registration`(=`ENC-ARPG-12 The Usher of Second Registration`) 신규 작성, `npc_02_orrin_kest.as_hostile` 연결 + R1 resident 등록 |
| `group` | 0/5 | `ENC-ARPG-01 The Intake Stamp` 작성 후 `GRP-ARPG-01`~`05` 부여. `group_id`는 catalog 전역 유일이라 계획상 두 host 중 boss 쪽 하나에만 부여 |
| `variant` | 0/6 | `VAR-ARPG-01`~`06` 6건. 계획 `05` §6.2 템플릿 그대로, `activation.kind="remix"` + `base_encounter_id` + `variant_overrides`, remix 깊이 1, `group=null`, 5개 region에 연결 |
| `ending` | 0/6 | **content가 아니라 probe를 고쳤다.** 아래 4.4 참조 |

### 4.2 encounter roster region 정합

**48/80(60%) roster slot이 enemy의 자기 `base_region_id` 밖에 배치**돼 있었다. `enemy_fold_wall`(R8)이 R2/R4/R6/R7에, `enemy_ash_hound`·`enemy_ember_clerk`(R1)가 거의 전 지역에 출전.

조치:
- 각 encounter의 roster를 **자기 region의 enemy pool에서 재구성**했다. 판정 규칙은 "enemy의 `base_region_id` ∪ `region_secondary`"가 "encounter의 `region_id` ∪ `region_secondary`"와 교차해야 한다. 계획 `05` §2의 FAM 배정이나 FAM↔content 대응표는 **쓰지 않았다**(§6 결정 A).
- 결과 **0/78**
- `target_priority`가 roster에 없는 enemy를 계속 가리키던 stale 참조 37개 encounter 파일에서 제거
- loader에 `enemy_region_mismatch` 검사 연결(`_validate_encounter_region_legality`). 음성 테스트로 실제 error 발생 확인 후 복구
- `enemy_region_role_mismatch`는 기존 2519행에 이미 있으므로 중복 추가하지 않음

### 4.3 내가 만든 regression 2건과 수정

1. **R1 진입 즉시 combat** — 새 encounter가 `prop_state_is ps_intact`(초기 상태) 기준이라 E01 통과 직후 발동, dialogue 대신 combat으로 넘어가 module 테스트 1건 파손. `clock_institutional_response` stage 2 기준으로 재게이트.
2. **door test 승리 직후 자동 재장열** — `enc_the_intake_stamp`를 `prop_r1_wrong_return_door`에 걸어, door role test 승리로 문이 `ps_opened`가 되는 순간 연쇄 발동. `prop_r1_ash_garden_thread` + `clock_institutional_response` stage 1로 분리.

### 4.4 ⚠️ 테스트/harness 변경 — 리뷰 필요

게이트를 통과시키려고 바꾼 것이 아니라 **실제 module 동작을 관측 가능하게 만든 것**이지만, 테스트를 건드렸으니 확인이 필요하다.

| 파일 | 변경 | 이유 |
|---|---|---|
| `content_loader.gd` | `CANONICAL_ENDING_IDS` 6개 추가 | `KIND_ALLOWED`는 엄격 allow-list라 content에 `ending_id`를 넣을 수 없다. 계획 `06` §3.5.6도 "`06`은 `end_*`를 `index.json`에 등록하지 않는다"고 명시. **기존 probe가 계획서와 반대**였다. gate와 같은 패턴으로 vocabulary를 loader에 두고 probe가 검증하게 함 |
| `top_down_action_rpg_playthrough_probe.gd` | `_settle_after_combat()` 추가 | combat 루프가 mode가 combat을 벗어나는 tick에 exit해서 `encounter_result`→`field_return`을 처리할 `_process`가 호출되지 않았다 |
| `top_down_action_rpg_playthrough_probe.gd` | `_first_field_intent()`에 bounded settle 추가 | field intent는 `_aftermath=false`와 `_field.move`만 하고, `field_return`→`field` 전이는 **다음** `_process`에서 일어난다 |
| `top_down_action_rpg_visual_capture.gd` | 거부된 출력 경로에 `quit(2)` 추가 | `return`만 하면 exit code 없이 SceneTree가 무한 idle해 호출자를 행시킴 |
| `top_down_action_rpg_visual_capture.gd` | `_settle()` / `_apply_resolution()`의 `await RenderingServer.frame_post_draw`를 `if not _headless`로 가드 | dummy 렌더러는 `frame_post_draw`를 한 번도 방영하지 않는다. `_capture()`는 headless에서 PNG를 의도적으로 거부하도록 설계돼 있는데, **그 분기에 도달하는 코드가 존재하지 않아** headless 실행이 전부 멈췄다 |
| `test_top_down_action_rpg_core.gd` | files 300→313, records 459→472, encounters 29→37, recovery 2→7, R1 interactables 7→8 | 카운트 상수를 실제 catalog에 맞춤 |

`enc_r1_second_registration` / `rec_*` 5건 / variant 6건 / group 5건의 스키마 오류도 이 과정에서 잡았다: `story_stage="opening"` → `"open"`, `record`는 `TARGET_PRIORITY_ROLES`에 없어 `linked_actor`로, `world_event`는 `WARNING_CHANNELS`에 없어 `npc_warning`로, `ps_seen`는 실존하지 않아 `ps_intact`/`ps_opened`로, `discards`는 7개 고정 token만 허용.

---

## 5. visual capture harness

### 5.1 "dialogue choice set was not reached" 원인 — 해결

harness가 아니라 **모듈 결함**이었다. `conversation_controller.advance_page()`가 `advance: "wait"` page에서 `PAGE_ADVANCE_WAIT`를 돌려주고 page를 넘기지 않았는데, 그 page를 넘기는 다른 경로가 없었다. `conv_h0_return_desk`의 wait page에서 대화가 영구히 멈췄다. 플레이어도 같은 자리에서 막혔다.

- 수정: wait page도 확인 입력으로 넘어간다(`PAGE_ADVANCE_WAIT`, `ADVANCE_AUTO` 제거). 계획 `09` §5.2 `waiting_advance`("advance가 다음 page로 이동")에 맞춘 것이다. `auto`/`wait`의 런타임 차이는 계획에 없다(§8.5).
- 회귀 테스트: `test_screen_confirm_passes_every_authored_page_including_wait_into_the_choice_set` — 화면 확인 입력만으로 wait page를 지나 선택지 확정까지 간다.
- probe `_advance_to_choice_set()`: wait page에서 멈추지 않고 선택지 단계까지 모듈 명령으로 넘긴다.
- 화면: 선택지 단계에서 현재 page가 비면 마지막 page 글을 계속 보여 준다(`top_down_screen.gd` `_prompt_page()`).

### 5.2 harness 구조

- 상태 하나가 실패해도 기록하고 다음 상태로 넘어간다. 상태·해상도마다 report를 다시 쓰므로 실패·watchdog(900초)·중간 종료에도 `top_down_action_rpg_visual_capture_report.json`이 남는다. 출력 폴더는 시스템 temp 아래의 새 절대 경로만 받는다.
- report 필드: `run_status`, `current_label`, `state_failures`(phase·reason·관측 상태), `missing_pairs`, `fixtures`(시작 방식·구동 방식), `identical_pixel_groups`, `runtime_violations`, `static_violations`, `source_audit`, `limitations`.
- 픽스처 구동 방식: `module_commands` / `player_input_actions`(Input.action_press → 모듈 자체 입력 폴링 → 화면) / `module_commands_with_enemy_actions_held_except_authored_charge`(charge 하나만 남기고 적 행동을 cooldown으로 묶음, 모듈 테스트와 같은 방식) / `forced_combat_result` / `screen_flag_without_module_caller`.
- 차단 검사: placeholder·AP·world stand-in·빨간 막대·HP bar 상수, 상시 HUD 노드, 그림 키 없음, 잘린 글자, 패널 밖으로 나감·겹침(§8.3), 뷰포트 크기 불일치.
- headless는 설계상 PNG를 쓰지 않는다(`frame_post_draw`를 기다리지 않게 가드). 픽셀 증거는 창 모드 실행에서만 나온다.

### 5.3 최신 결과 (창 모드, 2026-09-27 03:14 KST)

출력: `C:\Users\Sherum\AppData\Local\Temp\kit04_visual_capture_windowed_20260927_031457\`

- 16/16 상태 도달, PNG 48/48, state_failures 0, static_violations 0
- runtime_violations 51 = `missing_art_key` 48(모든 캡처) + `clipped_text` 3(dialogue_choice_focus 3해상도, 선택지 글이 198px 칸에 350~437px로 잘림 → §8.3-1에서 수정, 검증 전)
- 없는 그림 키 12개(승인 그림이 생길 때까지 남는다): `body_archivist`, `body_broker`, `body_carryer`, `body_intake_clerk`, `portrait_ilyra_senn`, `prop_h0_counter_open`, `prop_h0_map_matched`, `prop_r1_door_intact`, `prop_r1_door_opened`, `prop_r1_thread_available`, `sil_ash_hound`, `sil_ember_clerk`
- 픽셀이 완전히 같은 묶음: {field, input_bubble, esc_menu, recovery, success}, {combat_command, target_select, equipment_no_turn} → §8.4

금지 항목 정적 감사(placeholder 0 / AP 0 / stand-in 0 / 빨간 막대 0 / HP bar 상수 2/2)는 계속 통과한다.

---

## 6. 미결 A–I

### 결정 기록 — 2026-09-27, 사용자 확인 대기

사용자가 자리를 비우며 "중요한 질문은 네 추천대로 하라"고 지시해서 Kit 04 코드 세션이 추천안으로 처리했다. 사용자가 뒤집으면 해당 행만 다시 한다. A·G·H는 **지금 콘텐츠에만 걸린 항목**이고, 04는 새 세계(《저녁의 해안》) 재기획이 다른 세션에서 진행 중이다.

| 항목 | 결정 | 바뀐 것 |
|---|---|---|
| A (현재 콘텐츠 한정) | A3 — region 정합만 보장 | 없음. FAM↔enemy 대응표를 지어내지 않았다. R7 단일 actor encounter는 그대로 |
| B | B1 — loader의 ending vocabulary를 정본으로, 도달은 world write에 맡김 | 없음. **ending에 실제로 도달하는 content 경로는 아직 없다.** 새 세계 콘텐츠의 마지막 route가 정해야 한다 |
| C | §4.4 테스트·harness 변경 5건 유지 | 없음 |
| D | 축소하지 않고 수리 | 16개 상태 전부 도달(§5) |
| E | 창 모드 실행으로 자동화 | PNG 48장. 사람 눈 해상도 검수는 여전히 필요 |
| F | 완전 폐기 | temp(`%TEMP%\opencode`)의 BS2·프로넌트 심포니 파생 이미지 14장(`asset_preview/`), 스크립트 9개, `__pycache__`를 휴지통으로 보냄. 아래 F의 실측 결론 글만 남김 |
| G (현재 콘텐츠 한정) | 현재 템플릿 콘텐츠는 사람 검수를 하지 않음 | seed 160·fallback effect 약 50은 "완료 콘텐츠 아님"으로 둔다. 새 세계 콘텐츠를 지역·인물 담당이 검수 |
| H (현재 콘텐츠 한정) | H0 전투 0건을 그대로 둠 | 없음. 새 세계 H0 문서가 정한다 |
| I | 중단·폐기 | `rvdata2.py`를 휴지통으로 보냄. repo 의존 없음 |

아래 A–I 원문은 결정 당시 근거로 남긴다.

### A. encounter roster 구성을 계획 `05` §2 FAM 배정까지 복원할 것인가
현재 보장되는 것은 **region 정합**뿐이고, roster *구성*은 계획 §2의 `FAM-ARPG-01..19` 배정과 일치하지 않는다.
근본 원인: **계획의 FAM 이름(Tally-Skin, Return Usher 등)과 content의 enemy 이름(Ember Clerk, Ash Debt Collector 등) 사이에 대응표가 정본에 존재하지 않는다.** 지어내지 않았다.
부수 영향: R7의 native enemy가 `enemy_seam_arbiter` 1개뿐이라 R7 encounter 다수가 단일 actor가 된다.
선택지: (A1) FAM↔enemy 대응표를 authored content로 작성 / (A2) enemy record의 `base_region_id`를 계획 family 배정에 맞춰 재지정 / (A3) region 정합만 보장하고 문서화하며 감수

### B. ending의 catalog 착지와 런타임 구동
현재 ending은 **vocabulary만** 존재하고, 어떤 content record도 ending을 commit하지 않는다. 마지막 route가 실제로 어떤 world write로 ending에 도달하는지가 정의되지 않았다.
선택지: (B1) loader vocabulary를 정본으로 확정하고 종료 조건은 world write에 맡긴다 / (B2) ending별 authored commit record를 추가한다 / (B3) §A와 함께 결정

### C. 이번 세션의 테스트/harness 변경 5건 승인 (§4.4 표)
테스트를 바꾼 것이므로 명시적 승인이 필요하다.

### D. visual capture의 남은 15개 상태
대화 구동 수리 후 나머지 13개 상태를 순차적으로 해결할지, 아니면 harness를 현재 필요한 상태 위주로 축소할지.

### E. 720p/FHD/QHD 픽셀 증거 — 창 있는 실행 필요
harness는 **설계상 headless에서 PNG를 거부한다**(`_capture()`의 `png_skip_reason="headless_display_server_produces_no_frame_pixels"`). 자동 게이트로는 얻을 수 없고 사용자 플레이 검수 게이트에 속한다. 자동화 여부를 결정해야 한다.

### F. 서드파티 자산 취급
로컬 `BLACK SOULS Ⅱ`(VX Ace)와 `프로넌트 심포니`(VX)에서 **temp에서만** 읽어 목업을 만들었고, `C:\projects\TINProject`에 넣은 바이트는 **0개**다. 상용 게임 자산이라 커밋·배포는 불가.
실측 결론: `Graphics/Characters` 432개 중 대다수가 prop(문·배·상자·불·초·시체·꽃·우리)이고 actor 시트는 극소수, `Parallaxes`/`Fog_BackGround`는 ground가 아니라 조명층, `MapChip`/`Tilesets`는 autotile atlas다. **타일 반복은 아티팩트를 남기므로** 이는 `13_LAYERED_ENVIRONMENT_PRODUCTION`의 "타일 grid 아닌 큰 장면 그림" 결정을 실측으로 뒷받침한다.
선택지: temp 산출물을 참고 기록으로 남기고 정리 / 완전히 폐기

### G. 생성된 content의 비-generic성 사람 검수
seed 160건과 fallback effect 약 50건이 템플릿 생성물이다. schema·anti-generic 게이트는 통과하지만 **사람이 읽은 quality review가 없다.** `AGENTS.md`가 "전형적인 상황의 반복을 완료 콘텐츠로 인정하지 않는다"고 금지하는 영역이다.

### H. H0에 encounter가 0건
`region_h0_undersign_exchange.combat_content.encounter_ids`가 비어 있다. 의도된 설계인지 확인이 필요하다.

### I. rvdata2 역공학 작업의 계속 여부
temp의 `rvdata2.py`는 이 게임의 **커스텀 Marshal dialect**를 역공학한 판독기다. 규명한 것:
- 심볼/문자열 길이 = **값+5** (`0x0d`→8 "RPG::Map", `0x12`→13 "@display_name")
- 배열/hash/object ivar 개수 = **plain varint**, `0x01`=후속 1바이트
- `I` ivar wrapper = value + (**+5** ivar수) + pairs
- `u` userdef(`Table`/`Tone`) = 2바이트 LE 길이 + raw blob
- 링크는 별도 link table

**성공**: Map 파일에서 width/height/tileset_id/`@data`(3 layers) 추출 검증 (`Map001` = 40×75, tileset 21, "추락의 방", 411개 Map 접근 가능).
**미해결**: `Tilesets.rvdata2`가 byte ~5373(type `0x4e`)에서 파싱 중단 → tileset 21의 `@autotify_id` 미확보. 데이터가 참조하는 이름(`World_A1` 등)이 실제 파일에 없고 `Graphics/Tilesets/`가 RPG Maker 해시명만 보유. 렌더에는 VX Ace autotile 47패턴도 미구현.
→ repo 의존 없음. 계속할지 폐기할지 결정.

---

## 7. 알아둘 파일

구현: `modules/top_down_action_rpg/`
- `module.gd` — GameModule lifecycle, `_on_screen_intent`, `_return_to_field`, `_aftermath` 플래그
- `domain/game_state.gd` / `domain/combat_state.gd` — JSON-safe 상태
- `systems/content_loader.gd` — catalog/schema/seed 검증, `CANONICAL_GATE_IDS`, `CANONICAL_ENDING_IDS`, `DEFERRED_FLOORS`, `_validate_encounter_region_legality`
- `systems/action_scheduler.gd` / `combat_controller.gd` / `field_controller.gd` / `conversation_controller.gd` / `recovery_controller.gd`
- `presentation/top_down_screen.gd` — 16 presentation state, `_resolve_state()`

테스트: `tests/core/test_top_down_action_rpg_core.gd`(19) / `test_top_down_action_rpg_module.gd`(22, 마지막 1건은 §8.3 검증 전) / `tests/performance/top_down_action_rpg_playthrough_probe.gd` / `top_down_action_rpg_visual_capture.gd`

이미지 파이프라인: `docs/art/projects/top_down_action_rpg/PROJECT_ART_LAYER.md` · `asset_briefs/h0_layered_environment_pilot.md` · 계획 [13_LAYERED_ENVIRONMENT_PRODUCTION](../../../plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/13_LAYERED_ENVIRONMENT_PRODUCTION.md)
H0 background candidate는 존재하나 **승인되지 않았다**(1672×941, A 참조 누락, 일반 던전 렌더 수렴). `assets/art/approved/`와 Gold Standard는 **없다**.

현재 화면은 vector protocol-diagram presentation이다. 최종 Gold Standard art 승인 증거는 없다.


---

## 8. 2026-09-27 Kit 04 코드·검증 세션 인수인계

이 세션은 여기서 닫는다. 쓴 경로: `modules/top_down_action_rpg/**`, `tests/core/test_top_down_action_rpg_module.gd`, `tests/performance/top_down_action_rpg_*.gd`, 이 문서.

### 8.1 커밋 상태

- 03:47 `aec5d9a0`("병렬 세션 작업분 일괄 백업", 다른 세션의 일괄 커밋)에 이 세션의 03:47까지 변경이 들어가 푸시됐다(§8.2 전부와 03:17 harness 수정).
- 그 뒤 변경(§8.3)과 이 문서 갱신은 이 세션이 소유 경로만 따로 커밋했다.

### 8.2 한 것 — 03시 실행으로 검증됨

1. wait page 멈춤 수정과 회귀 테스트, probe 대화 루프(§5.1).
2. visual capture harness 재작성: 모든 상태 시도, 실패해도 report, 모듈 전투 루프로 charge·stance 픽스처 구동(§5.2).
3. `top_down_row.gd`: 선택·명령 행 글자를 초점 표시(왼쪽 24px)와 분류 표시(오른쪽 18px)에서 비킴. 보조 글(사유·비용)은 12px로 오른쪽 아래에 두고 본문은 위로 붙임.
4. `top_down_screen.gd`: 명령 행만 세로로 늘어나고 선택지 행은 제 높이. 선택지 단계에서 마지막 page 글 유지.

예외: 03:17의 harness 수정(`identical_pixel_groups` 추가)은 한 번도 실행되지 않았다.

### 8.3 마지막 수정 — 실행 검증 전

Godot 잠금이 04:30~05:20 KST 내내 다른 세션(kit08 → kit01)에 있어 돌리지 못했다.

1. **선택지 글 줄바꿈** (`top_down_row.gd`): 창 모드 캡처에서 H0 선택지 3개가 잘렸다. `ROLE_CHOICE` 행은 `AUTOWRAP_WORD_SMART`이고, `_get_minimum_size()`가 글 높이에 위아래 12px(사유 글이 있으면 사유 높이 + 4px씩)를 더한다. 한 줄 선택지는 계획대로 48px 그대로다. 글 Label의 `minimum_size_changed`를 행의 `update_minimum_size`에 연결했다.
2. **harness** (`top_down_action_rpg_visual_capture.gd`):
   - 줄바꿈 글이 세로로 잘려도 `clipped_text`로 잡는다.
   - `surface_overflow`(차단): 대화 띠·선택지 패널·문서·서술 띠·명령 레일·플레이어 띠가 화면 밖으로 나가거나, 선택지↔대화 띠, 명령 레일↔플레이어 띠가 겹치면.
   - target_select·equipment_no_turn·guard_dodge_break_feedback을 실제 키 입력으로 구동한다(`_press()`, `_player_open_category()`, `_player_open_rail_for()`). 모듈 명령으로 구동하면 화면의 레일 단계 상태를 건너뛰어서 세 상태가 combat_command와 픽셀이 똑같았다.
   - manifest 입력 액션을 이 프로세스의 InputMap에만 등록한다.
3. **모듈 테스트** `test_authored_choice_rows_show_their_whole_text_inside_the_choice_panel`: 실제 선택지 단계에서 4프레임 뒤 각 행의 글이 가로·세로 모두 칸 안에 들어가고, 행이 선택지 패널 안에, 패널이 화면 안에 있고 대화 띠와 겹치지 않는지.

### 8.4 발견했지만 고치지 않은 것

1. **전투 명령 레일 상태가 화면과 모듈에 따로 있다.**
   - 화면 `_rail_expanded`는 취소·Back에서만 풀린다. 행동을 확정하면 다음 차례에도 분류 목록 대신 행동 목록이 나온다(도메인 submode는 `command_category`, `current_category`는 `attack`으로 초기화).
   - 분류를 열면 화면 `_rail_focus`는 0이 되지만 모듈 `_rail_focus`는 그대로라, 다음 위/아래 입력에서 초점이 튄다.
   - 모듈 `_move_rail_focus()`는 `posmod`로 끝에서 처음으로 돌아간다. 계획 `01`·`09`는 "wrap하지 않는다".
   - 행동 목록에서 취소해도 도메인 submode가 `command_action`에 남는다.
   - 권장: 레일 단계는 도메인 submode 하나로 판정하고, 초점은 한 곳에서만 관리한다. 고친 뒤 harness 세 픽스처를 모듈 명령으로 되돌려도 픽셀이 달라야 한다.
2. **문서 본문이 기본 16px로 그려진다.** 계획 `09` §7.1은 본문 24px·줄 높이 32px, content `reading.min_font_size`는 20 이상이다. harness에 글자 크기 검사가 아직 없다.
3. **픽셀이 같은 상태 묶음.** esc_menu는 앱 shell이 그리므로 모듈 캡처에서 field와 같은 것이 맞다. input_bubble·recovery·success는 화면 플래그만 켜는 픽스처라 월드가 바뀌지 않는다. 증거가 되려면 실제 복구·성공 흐름으로 픽스처를 만들어야 한다.
4. 전투 플레이어 띠의 `행동 1`만 한국어이고 나머지 UI 글은 영어다.

### 8.5 정본 반영 대기 (계획 문서 충돌 — 계획 소유 세션이 결정)

1. `09` §6.1 선택지 "one-line label, row 48px, panel 280px" ↔ `06` §5.13 선택지 `text` 1200자 이하. 지금 구현은 줄바꿈 + 행 높이 증가다(§8.3-1). 선택지 6개가 모두 길면 패널(464px)을 넘을 수 있고 `surface_overflow`가 잡는다. content에 선택지 글 길이 상한을 둘지 정해야 한다.
2. `06` conversation page `advance: auto|wait`의 런타임 차이가 정의되지 않았다. 지금 구현은 둘 다 확인 입력으로 넘어간다.

### 8.6 다음 작업자가 먼저 할 것

1. 잠금을 잡고 Kit 04 module GUT → 창 모드 visual capture(§3 명령 7, `--headless` 빼고).
   - 기대: module GUT 22/22. capture는 `runtime_violations`가 `missing_art_key` 48건만, `identical_pixel_groups`에서 target_select·equipment_no_turn이 빠짐.
   - 실패하면 §8.3부터 본다.
2. 전체 자동 검증 4단계(`AGENTS.md`)를 한 번 돌리고 §3을 갱신한다.
3. §8.4-1 레일 상태 정리, §8.4-2 문서 글자 크기.
4. 캡처 PNG 사람 검수: 이 세션의 최신 창 모드 출력은 §5.3 경로.
