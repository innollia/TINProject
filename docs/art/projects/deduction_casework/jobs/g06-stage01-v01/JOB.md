# g06-stage01-v01 — 03 Deduction Casework · Stage 01 「눈을 고친 사람」(세인트 오린 대학)

상태: **candidate**. 승인은 사용자만 한다. 게임 코드·씬·content는 고치지 않았고 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 대상 | `modules/deduction_casework/content/cases/case_01_saint_orin.json`의 장면 4개, 핫스팟 20개, 출구 6개 + Stage 01 정본의 비수집형 시각단서(VISUAL 1~3, 힌지 A~C) |
| 근거 | 정본 01 v5.1/v5.3, 13A-1(인물 식별 5점), 13B-1(공간·물건), 13C(대학 팔레트·문서), 13E(Stage 1 배치), 미라 명세 `docs/art/projects/empty_axiom/asset_briefs/mira_ben_stage01_cutout.md` |
| 화풍 | V1(`h0-icon-mood-v02`) 아이콘 조합. 색 `recipes/palette_s01_orin.json`, CCTV 프레임 `recipes/palette_s01_cctv.json` |
| 쓰기 범위 | `assets/art/deduction_casework/jobs/g06-stage01-v01/`, 이 폴더 |

## 만든 것 (63개, 프레임 65장)

모아 보기: `preview/sheet_s01_characters_1x.png`, `preview/sheet_s01_objects_a_1x.png`, `preview/sheet_s01_objects_bcd.png`, `preview/sheet_s01_closeups_1.png`, `preview/sheet_s01_closeups_2.png`, `preview/sheet_s01_visual_clues.png`. 배경+물건 확인용(사람 없이): `preview/scene_s01_{lab,booth,locker,corridor}_bg_objects_1280x720.png`.

- [x] 배경 4: `bg_s01_lab`(A 쿼터뷰), `bg_s01_booth`(B 사이드뷰), `bg_s01_locker`(C 정면뷰), `bg_s01_corridor`(D 연결화면)
- [x] CCTV 프레임 바탕: `cu_s01_cctv_view` (VISUAL 1, 01:34 벽시계·과제보드 포함, 사람 없음)
- [x] 인물 4: `chr_s01_mira_seated_injured`, `chr_s01_mira_cctv_0134`(CCTV 색), `chr_s01_grell_tending`, `chr_s01_ed_door`
- [x] 초상화 4: `por_s01_mira`, `por_s01_grell`, `por_s01_ed`, `por_s01_lina`
- [x] 물건 A 9: `obj_s01_lab_bench`, `obj_s01_stim_desk`(CRT 12칸 과제 정지), `obj_s01_printer_two_sheets`, `obj_s01_task_board`, `obj_s01_wall_clock`(프레임 t0213/t0134), `obj_s01_bloody_gauze`, `obj_s01_first_aid_open`, `obj_s01_disinfect_floor`, `obj_s01_lens_case_broken`
- [x] 물건 B 9: `obj_s01_booth_desk`, `obj_s01_booth_chair`, `obj_s01_eeg_rack`, `obj_s01_cctv_monitor`, `obj_s01_eye_card`, `obj_s01_recorder`, `obj_s01_log_sheet`, `obj_s01_pager`, `obj_s01_eeg_printout`
- [x] 물건 C 10: `obj_s01_locker_mira`(프레임 closed/open), `obj_s01_labcoat_hung`, `obj_s01_notebook_shelf`, `obj_s01_prep_table`, `obj_s01_elephant_model`, `obj_s01_name_cards`, `obj_s01_lens_storage`, `obj_s01_repair_card`, `obj_s01_sketchbook`, `obj_s01_roster_sheet`
- [x] 물건 D 4: `obj_s01_sink`, `obj_s01_disinfect_tool`, `obj_s01_copier`, `obj_s01_guard_board`
- [x] 확대 18: `cu_s01_lens_case`, `cu_s01_calib_printout`, `cu_s01_behavior_printout`, `cu_s01_task_board`, `cu_s01_eye_card`, `cu_s01_log_sheet`, `cu_s01_pager`, `cu_s01_labcoat_label`, `cu_s01_notebook`, `cu_s01_repair_card`, `cu_s01_name_cards`, `cu_s01_roster`, `cu_s01_sketch_prev`, `cu_s01_sketch_day`, `cu_s01_tool_print`, `cu_s01_access_card`, `cu_s01_copier_log`, `cu_s01_guard_log`
- [x] 장면 배치 5: `recipes/scene_s01_{lab,booth,locker,corridor,cctv_frame}.json`

## 핫스팟 → 그림

| 핫스팟 | 그림 |
|---|---|
| hotspot_lab_bench (A1 미라) | chr_s01_mira_seated_injured |
| hotspot_lab_lens_case (A2) | obj_s01_lens_case_broken (미라 왼손 자리) → cu_s01_lens_case |
| hotspot_lab_stim_calibration / behavior (A3-1/2) | obj_s01_printer_two_sheets 두 장 → cu_s01_calib_printout / cu_s01_behavior_printout |
| hotspot_lab_task_board (VISUAL 2) | obj_s01_task_board → cu_s01_task_board |
| hotspot_lab_grell_gauze (A4) | chr_s01_grell_tending + obj_s01_bloody_gauze |
| hotspot_booth_eye_card / recorder / log_sheet / grell_pager | obj_s01_eye_card / recorder / log_sheet / pager → cu_s01_eye_card / — / cu_s01_log_sheet / cu_s01_pager |
| VISUAL 1 (핫스팟 없음) | obj_s01_cctv_monitor 화면 ← cu_s01_cctv_view + chr_s01_mira_cctv_0134 (`scene_s01_cctv_frame.json`) |
| hotspot_locker_cabinet / coat / notebook | obj_s01_locker_mira(open) / obj_s01_labcoat_hung → cu_s01_labcoat_label / obj_s01_notebook_shelf → cu_s01_notebook |
| hotspot_locker_sketchbook (VISUAL 3) | obj_s01_sketchbook → cu_s01_sketch_prev ↔ cu_s01_sketch_day |
| hotspot_locker_repair_card / name_cards / roster | obj_s01_repair_card → cu_s01_repair_card / obj_s01_name_cards → cu_s01_name_cards / obj_s01_roster_sheet → cu_s01_roster |
| hotspot_corridor_instruments (D1, 힌지 C) | obj_s01_disinfect_tool → cu_s01_tool_print ↔ cu_s01_access_card (+ cu_s01_repair_card 기름 지문) |
| hotspot_corridor_copier / guard_log | obj_s01_copier → cu_s01_copier_log / obj_s01_guard_board → cu_s01_guard_log |
| 출구 6개 | 배경의 창·문·통로. 다각형은 각 scene JSON의 `exits` |

## 작성자 설계 (문서에 수치가 없어서 정한 것)

- 축척: 모든 배경·물건·인물 원본 320px = 1m(세로). 쿼터뷰 바닥 축은 1m = 250px(2:1 등각). CCTV 프레임만 350px/m.
- 시점: A 쿼터뷰 = 먼 모서리 (1180,560)에서 왼벽(관찰창·자극 책상)·오른벽(준비실 문·보드·시계·복도 문)이 만나는 등각. B 사이드뷰 = 눈높이, 바닥 띠 y≥1160. C 정면뷰 바닥 y≥1020. D 연결화면 = 왼쪽 복도(실험실 문·세면대), 오른쪽 계단이 아래 층계참과 복사실 문으로 내려감.
- 미라는 화면 **왼쪽**을 향하게 앉혔다: 명세의 "왼쪽 얼굴이 보이는 3/4, 화면 오른쪽을 향함"은 오른쪽 얼굴이 보이는 자세라 13A-1 절대 고정인 왼귀 은핀 2개가 가려진다. 렌즈집은 왼손(무릎 위, 명세·13E), 오른손은 바닥(소독약병 쪽).
- 01:34 CCTV 미라는 보드를 향해 화면 오른쪽을 보므로 은핀이 반대편 귀에 있어 보이지 않는다(의도).
- 과제보드 배열(`tool/s01_board.py`): 모양 4×색 4, 정답 칸 (r,c) = 모양 (r+c)%4, 색 (c+2r)%4. 미라 자석은 모든 칸에서 돌출 윤곽 모양과 맞고 색은 같은 모양끼리 돌려 끼워 16칸 중 15칸이 틀림((2,1)만 우연히 맞음). 월드 보드·CCTV 프레임·확대가 같은 표를 쓴다.
- 벽시계 두 프레임: t0213(사건 시각), t0134(CCTV 프레임과 같은 시각, D2 '배경시계').
- 작은 단서 물건(호출기·눈검사 카드·렌즈집)은 가독성 때문에 실제보다 1.5~2배(13 바이블·정합성 점검: 핵심 단서 가독성 우선).
- 문서 확대에는 글자를 넣지 않았다. 글자 자리 선·칸만 있고, 문장·시각·이름은 게임 텍스트로 올린다(13G·이미지 정합성 점검의 '별도 레이어' 선택).
- CCTV 팔레트: V1 팔레트의 모든 색을 같은 밝기의 회녹색으로 바꾼 `palette_s01_cctv.json`(도구가 자동 생성).
- 준비실(C)에 실험실로 돌아가는 문을 왼쪽에 두었다(출구 trans_locker_to_lab). 계단문은 복사실로 내려가는 정본 묘사용.

## 도구 (V1 `tool/` 복사본에 추가·수정)

- `iconkit/icons.py`: 아이콘 변환 병렬 개수 기본값 8 → 2(공유 컴퓨터 규칙).
- 새 `g06kit/`(레시피를 **쓰는** 도구, 그리는 방식은 그대로 iconkit): `__init__.py`(사각형·다각형·타원·사지 조각, 시계 바늘), `iso.py`(2:1 등각 좌표·상자 세 면), `rooms.py`(등각 방·정면 방 바닥·벽·판벽·문·창), `person.py`(자세 뼈대 서기/바닥에 앉기/무릎 꿇기, 다리·팔·머리·얼굴·머리 모양·열린 코트), `palettes.py`(V1 팔레트 + 키트 공용 인물·종이·금속 재질, 색 이름 `@이름`).
- 새 스크립트: `make_s01.py`(레시피 전부 다시 쓰기), `s01_common.py`, `s01_bg.py`, `s01_objs.py`, `s01_chars.py`, `s01_cu.py`, `s01_board.py`, `s01_scenes.py`(배치 JSON).

## 재실행

`tool`에서 `py -3 -B make_s01.py` → `py -3 -B build.py --all` → `py -3 -B s01_scenes.py` → `py -3 -B compose_preview.py ..\recipes\scene_s01_lab.json`(booth, locker, corridor 같은 방식) → `review_sheet.py`.
