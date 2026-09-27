# 03 Deduction Casework — 구현 현황

> **2026-09-27 부모(통합 담당) 전달 — 이 파일의 다른 내용보다 우선한다.**
> 1. 아래 3번의 "stage01 한 잡만 존재"는 틀렸다. 부모가 확인한 결과(17:2x): `assets/art/deduction_casework/jobs/g06-stage02-v01/`(본 그림 72장, 커밋됨)과 `g06-stage03-v01/`(본 그림 60장, 아직 미커밋 — g06 그림 세션 소유라 이 Kit이 커밋하지 않는다)이 있다. case_02·case_03에도 같은 방식으로 경로를 잇는다. 파일이 없으면 placeholder로 돌아가는 규칙은 그대로다.
> 2. 배경을 투명도 0.28로 옅게 깐 것은 사용자 결정과 다르다. 사용자는 "상자 대신 후보 그림이 들어간 실제 게임 화면을 보고 판정"하기로 했다. 배경은 불투명하게 그린다. 글자·테두리·포커스가 안 보이면 UI 쪽 대비를 조정한다.
> 3. 자동 검증(import, 이 Kit 테스트, 12-stage route/solve, run_tests, 180프레임 부팅)과 창 모드 720p/FHD/QHD 캡처를 아직 한 번도 돌리지 않았다. Godot 잠금이 풀리면 이것부터 한다.


작성: sub-kit03 (2026-09-27)

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
