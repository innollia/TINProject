# Kit 07 physics_puzzle_platformer — 구현 현황 (인계용)

최종 갱신: 2026-09-27 05:10 KST. 작성 세션: Kit 07 구현 세션(Godot 잠금 이름 `kit07`). 이 대화방은 닫혔다. 다음 작업자는 이 문서부터 읽는다.

- 계획서: `plans/kits/07_PHYSICS_PUZZLE_PLATFORMER_KIT.md` (§20 OQ1~OQ10 확정, §21 구현 중 확정값)
- 쓸 수 있는 경로: `modules/physics_puzzle_platformer/**`, `tests/core/test_ppp_*.gd`, 위 계획서, `docs/research/mosa_lina/**`
- 사용자 위임: 질문 없이 계획서 "우리 권장" 값으로 진행한다(§20 첫 인용 블록).

## 한 줄 상태

wave 0~3 코드는 돌지만 wave 3 스모크 테스트가 **실패 중**이다(두 번째 시간알을 못 먹는다). wave 4 화면 코드와 단위 테스트 4개는 **작성만 했고 한 번도 실행하지 않았다.** wave 6 일부, 7~11은 손대지 않았다. 검토 준비 완료 아님.

## 덩어리별 현황

| 덩어리 | 부록 A wave | 파일 | 상태 | 확인된 것 |
|---|---|---|---|---|
| A. 도메인 | 0 | `module_manifest.tres`, `domain/` 12개(`tuning` `body_kind` `material_table` `interaction_rules` `level_spec` `body_spec` `tool_spec` `world_state` `run_state` `save_codec` `axis_view` `body_mass`) | 작성 완료 | 로드·파싱은 wave 3 테스트에서 동작 |
| B. 레벨 조립·선택·변형 | 1 | `systems/level_factory.gd` `selector.gd` `mutation.gd` `content_index.gd` | 작성 완료 | 레벨 1개 빌드 동작 |
| C. 프레임 처리 | 2 | `systems/step_director.gd` `contact_buffer.gd` `damage.gd` `objective_tracker.gd` `tool_holder.gd` `kinematics.gd` `input_bubble.gd` | 작성 완료 | 걷기로 첫 시간알 수집까지 동작 |
| D. 첫 판 | 3 | `content/levels/lvl_chalk_shelf.json`, `content/tools/tool_paper_fan.json`, 두 `index.json`, `entry.tscn`, `module.gd` | 작성 완료, **테스트 실패** | enter → 버블 → intro → play 전이 동작 |
| E. 화면 | 4~5 | `presentation/` 12개(`game_screen` `world_root` `parallax_root` `parallax_layer` `backdrop_dynamics` `body_view` `procedural_bridge` `trail_renderer` `level_title` `bubble_overlay` `audio_sink`), `audio_manifest.gd` | 작성만 함, **미실행** | 없음. 파싱 오류가 있으면 모듈 전체가 안 뜬다 |
| F. 저장 서비스·축 요청 | 6 | `domain/save_codec.gd`(완료), `systems/save_service.gd`·`systems/axis_mutation.gd`(미작성) | 부분 | 저장·로드는 wave 3 테스트의 일부 단언까지 동작 |
| G. 나머지 콘텐츠 | 7 | 레벨 7개 + 도구 5개 | 미착수 | — |
| H. 개발 하네스 | 8 | `presentation/dev_probe.tscn/.gd` | 미착수 | — |
| I. 테스트 | 9 | 작성: `test_ppp_module.gd`(wave 3 스모크 1개뿐), `test_ppp_selector.gd`, `test_ppp_mutation.gd`, `test_ppp_save_codec.gd`, `test_ppp_content_schema.gd` / 미작성: `physics_world` `presentation` `audio_manifest` `input_bubble` `reference_content` `no_forbidden_shortcuts` `axis_handover` | 부분, **4개 미실행** | — |
| J. 증명 콘텐츠 | 10 | `lvl_clockwork_bell`, `tool_moth_wing` | 미착수 | — |
| K. 수동 검수 | 11 | §17, §19 | 미착수 | — |

## 먼저 할 일 (순서대로)

1. **wave 3 스모크 테스트를 돌린다.** `tests/core/test_ppp_module.gd`.
   - 마지막 실행 결과(04:00 KST, 03:21 코드 기준): 26개 단언 중 16개 통과. `egg_low`는 걸어서 먹는다. 그다음 플레이어를 `(650, 330)`으로 순간이동해 `step_b` 위의 `egg_high`로 걸어가게 하는데, 240 물리 프레임 안에 먹지 못한다. 이후 단언(틈 개방, 클리어, 커서 이동, 재로드 커서)은 전부 이 실패의 연쇄다.
   - `_walk_until`에 20프레임마다 플레이어 위치·속도·접지·`egg_high` 상태를 찍는 `DIAG` 출력을 넣어 두었다. 잠금 경합으로 **한 번도 돌지 못했다.** 이 출력으로 원인을 가른다. 의심 순서: RigidBody2D에 `global_position`을 넣는 순간이동이 안 먹힘 → 플레이어가 바닥에 남아 기둥에 막힘 / `step_b` 위에서 막힘 / 접촉이 보고되지 않음.
   - 고친 뒤 `DIAG` 블록을 지운다.
2. **그 뒤 바뀐 것은 전부 미검증이다.** 첫 실행이 곧 파싱 검사다: 화면 전면 교체(E 덩어리), 파서 호출 방식 변경(`LevelSpec.new().parse(...)` 등, `load()` 제거), 도구 내려놓기 규칙(§21.4), `Mutation.apply`의 `mutable` 필터, 변형 인자 타입 고정, 신체 부위 이름(`left_arm`).
3. 단위 테스트 4개를 돌려 초록으로 만든다. `test_ppp_content_schema.gd`의 `test_accepts_all_shipped_content`와 `test_ppp_save_codec.gd`의 `test_restore_keeps_mutations`는 G 덩어리(콘텐츠 8+6)가 있어야 통과한다. 그 전에는 실패·보류가 정상이다.
4. 남은 배선 2개:
   - `entry.tscn`에 `AudioSink`(Node, `presentation/audio_sink.gd`) 노드를 붙인다. `module.gd`는 이미 `get_node_or_null("AudioSink")`로 찾는다.
   - `module.gd`가 첫 진입 때 `requested(&"input_bubble_profile", {"profile": [...], "previous_profile": [...]})`를 1회 내게 한다(§14.7). `test_rejects_future_version`은 이미 여러 번의 방출을 견디게 짜 두었다.
5. 그다음 부록 A 순서대로: F(`save_service.gd`, `axis_mutation.gd`) → G(레벨 7 + 도구 5, §10.6·§10.7·§10.8 예시와 §15.3 목록) → H → I 나머지 7개 파일(§16.1 표) → J(§15.4) → K.

## 되돌아보지 않아도 되는 결정

전부 계획서 §21에 적었다. 요약만:

- 월드는 `GameScreen` 안의 SubViewport(논리 1280×720, 자체 World2D = 자체 물리 공간)에서 돈다. 물리 설정은 그 공간에만 걸고 `Engine.physics_ticks_per_second = 120`은 enter에서 바꾸고 exit에서 되돌린다(§21.2).
- `E`: 누르면 충전(던지기형) 또는 즉시 발동(밀기·냉각). 만충 뒤 `TOOL_HOLD_HINT`만큼 더 누르면 점이 맥동하고, 그때 떼면 던지지 않고 내려놓는다(§21.4).
- 관측 payload에 표시 문자열(`text`)을 넣지 않는다(§21.5).
- 레벨마다 그 슬롯의 도구가 손에 쥐어진 채 시작한다(`tool:dealt`, §21.6).

## 연결 요청 (§20.1, 이 Kit이 직접 고치지 않는다)

| 대상 | 요청 | 상태 |
|---|---|---|
| `app/app_root.gd` | `physics_puzzle_platformer`를 등록 목록에 추가 | 요청만, 미반영 |
| `project.godot` | §8.2 물리 키, `display/window/stretch/mode = canvas_items` | 요청만. 모듈은 자기 SubViewport 공간에 같은 값을 직접 걸어서 이 요청 없이도 돈다 |
| `tests/core/test_no_binary_assets.gd` | 이 Kit 폴더 포함 확인 | 요청만. Kit 자체 검사는 `test_ppp_content_schema.gd`에 있다 |

## 작업 환경 메모

- Godot 잠금 경합이 심하다(kit01·kit05·procedural 등이 번갈아 30분 이상 잡는다). 잠금 대기는 짧게 끊어 반복한다. 한 번에 60분씩 기다리는 스크립트를 셸에서 돌리면 턴이 끊겨도 뒤에서 계속 살아 있다가 잠금을 잡는다(실제로 한 번 그랬다).
- 이 모듈 파일은 다른 세션의 일괄 백업 커밋 `aec5d9a0`(03:47)에 처음 들어갔다. 그 뒤 변경은 이 세션의 커밋 `fc9561f1`과 이 문서 갱신 커밋에 있다.
- **두 커밋은 로컬에만 있다.** 05:10 푸시가 거절됐다(원격 `kit/05-stone-story-rpg`에 이 로컬에 없는 커밋 4개, 로컬에만 있는 커밋 7개로 갈라짐). 병렬 세션 규칙상 pull·rebase·merge를 하지 않았다. 원격과 합치는 일은 사용자나 통합 담당이 한다.
- `audio/` 폴더와 `audio/README.md`는 만들지 않았다. W3가 wav를 넣을 때 만든다. 파일이 없으면 `AudioSink`는 조용히 아무것도 재생하지 않는다.
