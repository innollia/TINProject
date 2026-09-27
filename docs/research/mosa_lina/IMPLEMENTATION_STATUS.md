# Kit 07 physics_puzzle_platformer — 구현 현황 (인계용)

최종 갱신: 2026-09-27 18:10 KST. 작성: sub-kit07 세션(Godot 잠금 이름 `sub-kit07`). 다음 작업자는 이 문서부터 읽는다.

- 계획서: `plans/kits/07_PHYSICS_PUZZLE_PLATFORMER_KIT.md` (§20 OQ1~OQ10 확정, §21 구현 중 확정값)
- 쓸 수 있는 경로: `modules/physics_puzzle_platformer/**`, `tests/core/test_ppp_*.gd`, 위 계획서, `docs/research/mosa_lina/**`
- 사용자 위임: §20 첫 인용 블록의 OQ1~OQ9는 "우리 권장" 값으로 확정됐다. 그 밖의 **게임 경험을 바꾸는 선택**(조작, 화면 구성, 플레이어가 보는 글자, 레벨 구성 해석)은 2026-09-27 사용자 정정에 따라 추천안으로 확정하지 않고 아래 '사용자 질문'으로 올린다.

## 한 줄 상태

wave 0~4, wave 6(F) 코드가 돌고 wave 3 스모크 테스트가 통과한다. **G(레벨 7 + 도구 5)는 아래 질문 1의 답을 기다리며 멈췄다.** H~K 미착수. 검토 준비 완료 아님.

## 사용자 질문 (답이 올 때까지 해당 작업 정지)

1. **레벨 이름·ID가 계획서 두 곳에서 다르다.** 플레이어가 레벨 시작·클리어 때 보는 유일한 글자라서 어느 쪽을 쓸지 정해야 한다.
   - A안(§11.9-2 화이트리스트 표): `구르는 동전`, `들리는 판`(ID `lvl_lifting_slab`), `미끄러운 먹`, `부러진 이빨`.
   - B안(§15.2·§15.3 레벨 표): `굴러가는 동전`, `널빤지 다리`(ID `lvl_slab_bridge`), `미끄러운 잉크`, `금 간 이빨`.
   - 나머지 4개(분필 선반, 유리 회랑, 바람 장부, 빈 열쇠구멍)는 두 표가 같다.
   - 추천: A안. 화이트리스트 표는 "이 표에 없는 글자가 화면에 뜨면 실패"로 테스트가 묶여 있는 닫힌 목록이고, B안의 `널빤지 다리`는 움직이는 발판 두 개로 타이밍을 맞추는 이 레벨 내용과도 `들리는 판`보다 덜 맞는다.
   - 멈춘 작업: G 덩어리(레벨 JSON 7개). 도구 5개는 OQ1로 확정돼 있지만 레벨과 한 묶음으로 커밋·검증하려고 같이 멈췄다.
2. **`E` 키를 오래 누르면 던지지 않고 내려놓는 규칙(§21.4).** 이전 세션이 추천안으로 넣었고 코드도 그렇게 돈다. 조작 규칙이라 확인이 필요하다.
   - 유지: 던지기 도구는 0.6초 눌러 만충 → 0.35초 더 누르면 손 옆 점이 맥동 → 떼면 내려놓기. 한 키로 던지기·내려놓기를 다 한다.
   - 빼기: `E`는 줍기·던지기·발동만. 도구를 버리려면 다른 도구를 줍는다(주우면 들고 있던 것은 그 자리에 놓인다). 키 조작이 단순해지고, 도구를 바닥에 세워 두고 쓰는 퍼즐은 줍기로만 가능하다.
   - 추천: 유지. Mosa Lina처럼 도구를 발판·쐐기로 세워 두는 풀이가 이 Kit의 핵심이라 빈손으로 내려놓는 길이 있어야 한다.
   - 멈춘 작업: 없음(현재 코드 유지 중). 빼기로 정하면 `systems/tool_holder.gd`만 고친다.
3. **레벨마다 그 슬롯의 도구를 손에 쥔 채 시작한다(§21.6).**
   - 유지: 레벨이 시작되면 이미 도구가 손에 있다. 레벨에 놓인 도구 표식(`tool_placement`)은 두 번째 도구가 된다.
   - 바꾸기: 슬롯 도구가 레벨 시작 지점 바닥에 놓여 있고 직접 주워야 한다. 첫 1~2초에 줍는 동작이 하나 늘고, 줍지 않고 진행하는 선택이 생긴다.
   - 추천: 유지. "매번 다른 도구를 들고 시작한다"(§15.1)를 가장 직접 보여 준다.
   - 멈춘 작업: 없음.
4. **화면 구성: 월드를 항상 1280×720 논리 화면으로 그리고, 창 비율이 다르면 위아래나 좌우를 레터박스로 비운다(§21.2).** 720p/FHD/QHD에서 보이는 월드 범위가 같아진다.
   - 유지: 해상도가 달라도 보이는 퍼즐 범위가 같다. 16:9가 아닌 창에서는 검은 띠가 생긴다.
   - 바꾸기: 창 크기만큼 월드를 더 보여 준다. 큰 화면에서 더 멀리 보이므로 퍼즐 난이도가 해상도에 따라 달라진다.
   - 추천: 유지. 물리 퍼즐은 보이는 범위가 곧 정보량이라 해상도마다 달라지면 안 된다.
   - 멈춘 작업: 없음.

## 덩어리별 현황

| 덩어리 | 부록 A wave | 상태 | 확인된 것 |
|---|---|---|---|
| A. 도메인 | 0 | 완료 | 전 테스트에서 로드·파싱 |
| B. 레벨 조립·선택·변형 | 1 | 완료 | selector 14개, mutation 10개 테스트 통과 |
| C. 프레임 처리 | 2 | 완료 | 스모크: 걷기·점프로 시간알 2개, 틈 개방, 클리어, 다음 슬롯 |
| D. 첫 판 | 3 | 완료 | 스모크 26개 단언 전부 통과(아래 AudioSink 오류 제외) |
| E. 화면 | 4~5 | 파싱 통과, 헤드리스에서 생성·갱신 오류 0 | 창 모드 캡처 미실행 |
| F. 저장 서비스·축 요청 | 6 | 완료 | `systems/save_service.gd`(스냅샷·읽기·재지정·복원), `systems/axis_mutation.gd`(거부를 조용히 돌려주고 상태 불변). save_codec 16개, axis_handover 5개 통과 |
| G. 나머지 콘텐츠 | 7 | **질문 1 대기** | — |
| H. 개발 하네스 | 8 | 미착수 | — |
| I. 테스트 | 9 | 작성·통과: module(스모크), selector, mutation, save_codec, content_schema, axis_handover(F 범위 5개) / 미작성: physics_world, presentation, audio_manifest, input_bubble, reference_content, no_forbidden_shortcuts | — |
| J. 증명 콘텐츠 | 10 | 미착수 | — |
| K. 수동 검수 | 11 | 미착수 | — |

## 이번 세션에서 고친 것 (원인)

- **wave 3 스모크 실패의 원인:** 테스트가 플레이어 `RigidBody2D`에 `global_position`만 넣어 순간이동했다. 시간알을 먹은 직후 프레임에는 노드 쪽 값이 물리 서버에 전달되지 않고, 다음 동기화 때 옛 위치로 되돌아갔다(두 번째 순간이동만 사라진 이유). 첫·세 번째는 우연히 통과했다. `StepDirector.place_rigid()`가 노드와 `PhysicsServer2D` 상태를 함께 쓰게 했고, 같은 문제가 날 수 있는 게임 코드 5곳(경계 클램프, 세이브 복원, 도구 손 붙이기·내려놓기·던지기)도 이 함수로 바꿨다. 레벨 설계 문제는 아니었다.
- `presentation/game_screen.gd` 파싱 오류 2건(타입 추론 불가 `:=`) → 명시 타입.
- `domain/save_codec.gd` sanitize: 키가 없을 때 `body["held"]` 접근 오류 5곳 → `get(key, false)`.
- 배선 2개 완료: `entry.tscn`에 `AudioSink`, `enter`마다 `requested(&"input_bubble_profile", {profile, previous_profile})` 1회.
- 모듈의 저장 처리(스냅샷·해석·재지정·복원)를 `systems/save_service.gd`로 옮겼다. `module.bind_world_store(store)` / `module.request_axis_mutation(axis, patch)`가 축 쓰기 요청의 유일한 경로다(이 Kit이 소유한 축은 없어서 호출부는 아직 없다).

## 테스트 수치 (2026-09-27 17:05 KST)

- `--editor --import`: 종료 0.
- `--script res://tests/run_tests.gd`: 644/644 통과.
- `--quit-after 180 --fixed-fps 60` 부팅: 종료 0, ERROR 0.
- GUT `-gprefix=test_ppp_` (AudioSink 배선 상태 그대로): 62개 중 48 통과, 13 실패, 1 보류. 실패 13 = core 오디오 스크립트 파싱 오류로 인한 "Unexpected Errors" 12 + 콘텐츠 개수 1(G 대기, 정상).
- 같은 테스트를 `AudioSink` 노드만 임시로 뺀 상태: 57개 중 55 통과, 1 실패(콘텐츠 개수), 1 보류(`test_restore_keeps_mutations`, gravity_scale 허용 레벨이 G에서 생긴다). axis_handover 5/5.

## 연결 요청 (이 Kit이 직접 고치지 않는다)

| 대상 | 요청 | 상태 |
|---|---|---|
| `core/services/audio_service/audio_manifest_event.gd` 5행 | `@export_file("*.wav,*.ogg,*.mp3") var file` → `@export_file("*.wav", "*.ogg", "*.mp3") var file`. Godot 4.7.2가 쉼표 하나로 묶은 필터를 파싱 오류로 거부해 `AudioManifestEvent`·`AudioManifest`·`AudioEventPlayer`가 전부 컴파일되지 않는다. 이 Kit의 `AudioSink`와 `modules/descent_exploration`이 영향을 받는다 | **요청.** 반영되면 ppp 테스트의 Unexpected Errors 12건이 사라진다 |
| `app/app_root.gd` | `physics_puzzle_platformer`를 등록 목록에 추가 | 요청만, 미반영 |
| `project.godot` | §8.2 물리 키, `display/window/stretch/mode = canvas_items` | 요청만. 모듈이 자기 SubViewport 공간에 같은 값을 직접 걸어서 이 요청 없이도 돈다 |
| `tests/core/test_no_binary_assets.gd` | 이 Kit 폴더 포함 확인 | 요청만. Kit 자체 검사는 `test_ppp_content_schema.gd`에 있다 |

## 다음 할 일 (순서대로)

1. 질문 1의 답을 받으면 G: `content/tools/` 5개(`tool_glass_rod` `tool_ember_lash` `tool_lead_weight` `tool_rope_hook` `tool_chill_jar`, §10.8·§15.3 값)와 `content/levels/` 7개(§15.2 비트 표의 구성, §10.6·§10.7 예시를 이 Kit 검증기 규칙에 맞춰 수정 — 예시의 `kinematics` 항목은 같은 id의 `tile_kinematic` 바디가 있어야 로드된다). 두 `index.json`에 id 추가.
   - 설계 기준(실측 튜닝): 점프로 오르는 높이 ≈ 79px이므로 발판 윗면 간격 ≤ 64px, 수평 간격 ≤ 110px. 떠 있는 판의 아랫면이 바닥에서 46px 안(플레이어 키)이면 그 밑으로 못 지나간다(분필 선반 `step_a`가 그렇다).
   - 각 레벨에 대해 "시간알 위로 순간이동 → 수집", "필요 개수 채운 뒤 틈으로 순간이동 → 클리어"를 확인하는 테스트를 `test_ppp_reference_content.gd`에 넣는다(시간알이 지형에 묻히지 않았는지 기계 검증).
2. H: `presentation/dev_probe.tscn/.gd`.
3. I: 남은 6개 파일(§16.1 표).
4. J: `lvl_clockwork_bell`, `tool_moth_wing`(§15.4) + `git diff --stat`.
5. K: 창 모드 720p/FHD/QHD 캡처, 자동 플레이 probe로 레벨별 경로 길이·소요 시간 근거. 실측 10분 플레이는 사람만 할 수 있다.

## 되돌아보지 않아도 되는 결정

계획서 §21 참조(월드 SubViewport·자체 물리 공간, 관측 payload에 `text` 없음, `load()` 0건 등). 조작·화면에 관한 §21.2·§21.4·§21.6은 위 질문 2~4로 확인 중이다.

## 작업 환경 메모

- 이 PC의 저장소는 `C:\Users\fixme\Desktop\TINProject`, Godot 콘솔은 `C:\Users\fixme\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`.
- Godot 잠금은 `C:\projects\_locks\TINProject-godot.lock`.
- `audio/` 폴더는 없다. W3가 wav를 넣을 때 만든다. 파일이 없으면 `AudioSink`는 조용히 재생하지 않는다.

## 18:10 KST 갱신 (이 절이 위 내용보다 우선)

- 오디오 core 수정 반영 확인: ppp 테스트의 오디오 오류 0.
- **G 완료:** 레벨 7(lvl_rolling_coin lvl_glass_gallery lvl_lifting_slab lvl_wind_ledger lvl_slippery_ink lvl_broken_teeth lvl_hollow_keyhole), 도구 5. **레벨 이름 사용자 답 대기 -- 지금은 A안(§11.9-2). B안이면 JSON 
ame 문자열 4개와 lvl_lifting_slab→lvl_slab_bridge(파일명·index 1줄)만 교체.**
- **H 완료:** presentation/dev_probe.tscn/.gd. 창 모드로 레벨마다 지정 해상도 SubViewport 캡처, 시간알→틈 최단 보행 경로 길이 출력. 실행: Godot_v4.7.2-stable_win64.exe --path <저장소> --resolution 1280x720 res://modules/physics_puzzle_platformer/presentation/dev_probe.tscn -- --out=<폴더> --size=1920x1080.
- **I 완료:** 테스트 12파일 97개 통과, 1 보류(	est_restore_keeps_mutations).
- **J 완료:** lvl_clockwork_bell + 	ool_moth_wing, 변경은 content/ 안 JSON 2개 + index 2줄뿐(커밋 e3e3cfb1·34183792). core 무수정.
- **K(에이전트 몫):** 9레벨 × 720p/FHD/QHD 캡처 27장 docs/research/mosa_lina/captures/. 보행 경로 합계 93.6초(9레벨) — 걷기만으로는 10분이 안 된다. 10분 근거는 퍼즐 판단 시간이어야 하며 사람 실측이 필요하다.
- **한계:** 레벨은 모든 시간알이 닿으면 먹히고 틈이 열리는지까지 자동 검증했다(	est_ppp_reference_content). 도구가 **필요한** 퍼즐인지(걷기·점프만으로 풀리는지)는 검증하지 않았다.