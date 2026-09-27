# 03 Deduction Casework — 구현 현황

작성: sub-kit03 (2026-09-27, 이어서 검증)

## 4차 실행 (2026-09-27 21:2x~) — world 배치 런타임 검증 완료

- Godot 잠금 확보 후 순서대로 실행: import(오류 0) → GUT `-gdir=res://tests/core -gdir=res://core/procedural/tests -gdir=res://core/worldstate/tests`(이 Kit 무관 실패 16건은 다른 세션 소유 파일의 기존 실패, 그대로 둠) → `run_tests.gd`(644/644 통과) → 180프레임 부팅(오류 0) → 창 모드 캡처(1·2·3번 사건 14장면×3해상도=42장).
- **테스트 버그 2건 발견·수정(진짜 회귀 아님, 테스트가 낡은 전제를 씀):**
  1. `tests/core/test_deduction_casework_art.gd`의 `test_world_layout_boxes_stay_keyboard_and_mouse_reachable`: 씬 루트가 전체 anchor(0,0,1,1)인데 `scene.size = Vector2(1280,720)`을 직접 대입해 "non-equal opposite anchors" 엔진 경고로 실패. `scene.set_anchors_preset(Control.PRESET_TOP_LEFT)`를 add_child 전에 호출해 anchor를 0으로 풀고 나서 size를 대입하도록 수정.
  2. `tests/core/test_deduction_casework_skeleton.gd`의 3개 테스트(`test_entry_mounts_case_screen_and_generic_placeholder_boxes`, `test_scene_hotspot_click_opens_message_detail_and_restores_focus`, `test_region_transition_replaces_snapshot_and_restores_origin_focus`): world 모드에서는 핫스팟이 `%TargetGrid`/`%ExitGrid`가 아니라 `%WorldLayer`에 함께 들어가는데, 테스트가 여전히 옛 grid 노드를 찾아 0개로 실패. `_boxes()`를 `Node`를 받게 넓히고 `_boxes_of_kind(container, kind)`를 추가해 `%WorldLayer`에서 kind로 나눠 읽도록 3곳 수정. `_target_grid()`는 이제 `%WorldLayer`를 반환.
  - 두 수정 모두 게임 코드(`authored_case_scene.gd` 등)는 건드리지 않음. 테스트만 world 모드 전제에 맞춤.
- **world 배치 좌표 변환 검증 결과: 버그 없음.** `_layout_world_boxes()`의 좌표 계산을 손으로 재검증(예: `chr_s02_luca_stand`: at=[2330,1360] - pivot=[190,612] = box_pos[2140,748], art_candidates.json 저장값과 정확히 일치). `bake_hotspot_boxes.gd`의 `pos = at - pivot` 산수도 compose_preview.py와 동일함을 재확인.
- **캡처로 직접 확인:** 1번 사건(4장면)은 그림이 있는 핫스팟마다 물건 위에 정확히 겹쳐 보임(책상 위 서류, 벽 사물함 등). 2·3번 사건은 좌표 자체는 정확하나(계산 재검증함) g06 그림 후보가 stage02/03의 일부 핫스팟에만 있어 placeholder 해치 상자가 많고, 그림이 없는 핫스팟은 화면 하단 fallback 격자로 빠짐(코드 설계대로). 여러 조사물이 근접·겹쳐 보이는 곳(예: 3번 사건 debris/n_lux/shoes)은 사건 현장 특성(잔해가 한 자리에 모임)이며 좌표 오류가 아님.
- **격자 모드 회귀 없음.** `HOTSPOT_LAYOUT="grid"`로 되돌리는 코드는 그대로 있고 손대지 않음.
- **캡처 산출물:** 42장을 임시 작업 폴더(`C:/Users/fixme/workplace/kirocrew-workspace/subagent_68c47786/captures/`)에 저장. 대표 3장(1·2·3번 사건 각 1장, FHD)을 직접 열어 확인함. 저장소에는 아직 복사하지 않음(다음 항목).
- `docs/research/deduction_casework/tools/capture_scenes.gd`의 `OUT_DIR`을 이번 세션 작업 폴더로 갱신(이전 세션의 임시 경로가 하드코딩돼 있었음).

## 남은 일 (다음 세션 우선순위)

1. 대표 캡처 6~9장을 `docs/research/deduction_casework/captures/`에 복사해 커밋(아직 안 함, 임시 폴더는 지워질 수 있음).
2. stage02/03 그림 후보가 없는 핫스팟은 여전히 placeholder다. g06 세션이 나머지 그림을 채우면 `art_candidates.json`(bake 도구 재실행)만 갱신하면 이어짐 — 코드 변경 필요 없음.
3. save/load/reset, 입력 재검증은 이번 실행에서 GUT(전체 20/20 관련 케이스 포함 run_tests 644/644)로 커버됨. 추가 수동 확인은 필요 없음.

## 3차 실행 (2026-09-27 19:5x~) — world 배치로 전환, 부모 지시로 중단 (요약, 위 4차에서 검증 완료)

- 사용자 확정(부모 전달): 조사할 곳을 카드 격자 대신 배경 속 제자리에 놓는다. `authored_case_scene.gd`의 `HOTSPOT_LAYOUT` 상수(`"world"`/`"grid"`)로 전환.
- `docs/research/deduction_casework/tools/bake_hotspot_boxes.gd` 신규: g06 recipes의 물건 좌표를 읽어 `art_candidates.json`을 schema 3(box 포함)으로 재작성. 1·2·3번 사건 56개 핫스팟 전부 box 확보.
- `art_candidate_lookup.gd`에 `hotspot_world_box(case_id, hotspot_id)` 추가.
- `authored_case_scene.gd`: world 모드 배치 로직 추가(격자 모드 코드는 그대로 유지).


## 2차 실행 (2026-09-27 17:4x) — 위 부모 전달 1~3 처리 완료

- `art_candidates.json` schema 2: 사건별로 나눔(scene_locker·scene_service가 사건마다 겹침). 1·2·3번 사건의 장면 14개·핫스팟 전부 연결, 경로 누락 0. 핫스팟→그림 대응은 g06 `recipes/scene_s0N_*.json`의 `hotspots` 항목의 첫 물건 그림을 따랐다. 1번 사물함은 JOB.md대로 `open.png`.
- 배경을 화면 전체에 불투명(cover)하게 그림. 핫스팟 그림은 비율 유지(contain), 번호 뱃지·제목 외곽선으로 대비 확보.
- 흰 사각형 버그 수정: 그리기 중 텍스처 참조가 풀려 흰색으로 그려졌다 → 조회기가 로드한 텍스처를 캐시.
- 검증: import 오류 0 / Kit GUT 20/20(1872 asserts, 12-stage route/solve·save/load/reset 포함, 새 `test_deduction_casework_art.gd` 4개) / run_tests 644/644 / 180프레임 부팅 오류 0 / 창 모드 캡처 42장(3사건×14장면×3해상도). 직접 본 결과: 그림이 제자리에 보이고 글자·번호·포커스 테두리 모두 읽힌다.
- 캡처 도구: `docs/research/deduction_casework/tools/capture_scenes.gd`.
- `g06-stage03-v01` 그림 파일은 커밋하지 않음(g06 세션 소유).
- 알려진 점: 핫스팟은 여전히 격자 카드이고 배경 위의 제자리(좌표)에 놓이지 않는다. recipes에 좌표가 있어 옮길 수 있지만 화면 문법을 바꾸는 일이라 이번엔 하지 않았다.

## 이번 세션에서 한 일

1. `plans/kits/03_DEDUCTION_CASEWORK_KIT.md`, 기존 코드, `modules/deduction_casework/**`, `tests/core/test_deduction_casework_skeleton.gd` 확인.
2. `modules/dedution_casework/`(오타 폴더) 확인: 내 소유가 아니며, 이 Kit(`deduction_casework`)와 무관한 **별도의 옛 구현**이다. `case_definition.gd` 4단계 mode(현장 기록/사건 순서/판정표/사건 종결), `dedution_casework_*` 입력 액션, `ColorRect`/`Label` 직접 그리기 방식의 자체 완결형 모듈로, 계획서 2.3절이 이미 이를 "Retired Prototype"으로 명시하고 old ID로 지정해 두었다. 지우지 않고 그대로 둔다. 손대지 않음.
3. `assets/art/deduction_casework/jobs/`에는 `g06-stage01-v01` **한 잡만** 존재(stage02/03 art candidate 없음). 원 지시문의 "stage01~03 candidate"는 사실과 다르며 stage01만 실재하는 상태로 확인.
4. `hotspot_*` id → `msg_*`(대사) 매핑은 case JSON에 이미 있으나, 그림 후보와의 매핑은 존재하지 않았다. 새로 만든 module-local 참조 파일 `modules/deduction_casework/content/art_candidates.json`에 scene_id/hotspot_id → `res://assets/art/deduction_casework/jobs/g06-stage01-v01/output/**` 경로만 기록했다(그림 파일 복사/수정 없음). case_01_saint_orin.json(scene_lab/booth/locker/corridor)의 모든 hotspot 19개 + 4개 배경에 대해 채웠다. case_02~12는 g06 산출물이 없으므로 매핑 없음 → 자동으로 placeholder.
5. `modules/deduction_casework/systems/art_candidate_lookup.gd` 추가: JSON을 읽어 `scene_texture(scene_id)` / `hotspot_texture(hotspot_id)`를 돌려주는 조회기. 파일이 없거나 `ResourceLoader.exists()`가 false면 `null`을 돌려줘서 호출부가 placeholder로 자동 복귀.
6. `modules/deduction_casework/presentation/authored_case_scene.gd` 수정:
   - `_ready()`에서 `_stage_panel.draw`에 `_draw_stage_backdrop` 연결, `_sync()`에서 매 동기화마다 `_stage_panel.queue_redraw()`.
   - `_draw_stage_backdrop()`: 현재 `scene_id`에 candidate 배경이 있으면 옅은 알파(0.28)로 스테이지 패널 뒤에 깐다(텍스트/hatch 판정 UI를 가리지 않도록 옅게).
   - `_draw_box()`: `box_id`(=hotspot_id)에 candidate 그림이 있으면 그 텍스처를 박스 전체에 그리고 어둡게 오버레이(0.28~0.45 알파)한 뒤 기존 테두리/포커스/순서번호를 그대로 위에 그린다. 없으면 기존 해치 placeholder 그대로.
   - candidate 승격/승인 로직 없음(계획서 지시대로 하지 않음). 텍스처 로드 실패는 전부 조용히 placeholder로 귀결.

## 남은 일 (미완료, 이유)

- **테스트/부팅 실행 미실행.** `C:\projects\_locks\TINProject-godot.lock`을 sub-kit01이 쥐고 있어 Godot을 실행하지 못했다. 즉시/3분/8분/13분 경과 시점 총 4회 확인했으나 계속 보유 중이었고 40분 미만이라 stale 판정 기준(godot 프로세스 없이 40분+ 방치)에 해당하지 않아 강제 해제하지 않았다. 잠금 해제 후 재시도할 것: import, `test_deduction_casework_skeleton.gd`(GUT), `--quit-after 180 --fixed-fps 60` 부팅.
- **720p/FHD/QHD 캡처 미실행.** 위와 같은 이유로 Godot 창 모드 실행이 필요해 보류.
- **save/load/reset, 입력 재검증** 미착수. Godot 잠금 해제 후 코드 리뷰(정적) 먼저 하고 필요 시 런타임 확인.
- **12-stage route/solve 자동 검증** 재실행 미실행(Godot 필요).
- **stage02/03 art candidate 자체가 없음.** g06 세션이 만든 것이 stage01뿐이라 이번 작업은 stage01(=case_01_saint_orin, 4개 scene) 연결까지만 가능했다. stage02/03 art가 나오면 같은 방식(`art_candidates.json`에 항목 추가)으로 이어서 연결 가능.

## 채택한 추천안 (에이전트 추천 → 사용자가 확정, 2026-09-27)

- **사용자가 확정함:** "03 추리 화면에 g06 후보 그림을 임시로 붙이기"를 추천대로 확정. 승인/Gold Standard 승격이 아니라는 점은 그대로 유지된다. 이 절 이하의 구현(placeholder 위에 옅게 겹치는 방식)은 되돌리지 않는다.
- candidate 그림을 "완전 교체"가 아니라 "placeholder 위에 옅게 겹쳐 보여주는" 방식으로 연결. 판정 UI(테두리/포커스/순서번호)를 가리지 않는 것을 우선했다.
- 매핑 파일은 module-local JSON 하나(`modules/deduction_casework/content/art_candidates.json`)로, 코드에서 하드코딩하지 않았다. 이후 stage가 추가될 때 이 파일만 늘리면 된다.

## 공용 파일 변경 요청

없음.
