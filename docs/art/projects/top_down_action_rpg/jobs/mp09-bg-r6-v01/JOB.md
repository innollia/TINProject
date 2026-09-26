# mp09-bg-r6-v01 — R6 Gristmarket Ward 배경·오브젝트

상태: **제작 중(V1 기준).** 결과는 전부 candidate이고 승인은 사용자만 한다. 게임에 연결하지 않는다.

| 필드 | 값 |
|---|---|
| 목적 | clean_base + occluder + prop(오브젝트) + state_variant. 아이콘 조합 코드 그림 |
| 근거 결정 | 2026-09-27 아이콘 조합 양산 지시와 V1 확정(COMMON.md 04:25판). 세션 09 담당: R6 → R7 → R8 |
| 소유권 | 세션 09. 쓰기: `assets/art/top_down_action_rpg/jobs/mp09-bg-r6-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp09-bg-r6-v01/`. 정본·코드·씬·content 수정 없음 |
| 자산 identity | `region_r6_gristmarket_ward` / `art_world_r6_gristmarket_ward`. 사물 4종·출구 4개(edge ID)·내부 길 1개는 content의 실제 ID. 구역 ID, `obj_*`·`exit_*`·`route_*`·`foreground_*` 이름은 작성자 설계 |
| 입력 계약 버전 | COMMON.md 04:25판, 이 폴더 BRIEF.md, 13, 14, 09 §12, IMAGE_ASSET_WORKFLOW §3, PROJECT_ART_LAYER 0.1, region·prop JSON. SHA-256은 inputs.json |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 180 px/m, 깊이 ×0.866, 높이 110 px/m(플레이어 키 기준, BRIEF.md §4, 작성자 설계) |
| 입력 이미지 | 픽셀 입력 없음. 화풍은 h0-icon-mood-v02 V1 결과를 눈으로 비교만. 모양 재료는 `addons/at-icons/node2d` SVG |
| 필요한 결과 | 아래 체크리스트 |
| 내용 고정 | BRIEF.md §3, §6, §7 |
| 금지 | BRIEF.md §9 |
| 수정 범위 | 이 작업 폴더 두 곳의 새 파일만 |
| 승인 상태 | 원본 입력 없음, approved 기준 없음(Gold Standard 0), 결과는 candidate |
| 검수 항목 | 구도·화풍·기술·상태를 각각 pass/partial/fail/not_run으로 QA.md에 |
| 중단 이유 | 없음 |

## 만들 대상

배경 (2560×1440, BRIEF.md §3·§6)
- [ ] `bg_r6_intake_ring`: base_clean, foreground_r6_lintel
- [ ] `bg_r6_debt_hall`: base_clean, foreground_r6_rail_posts
- [ ] `bg_r6_stalls_drainage`: base_clean, foreground_r6_pipe

content 사물 (BRIEF.md §7)
- [ ] `prop_r6_organ_intake_counter`: prop_r6_counter_open, prop_r6_counter_split
- [ ] `prop_r6_cure_queue_board`: prop_r6_queue_numbered, prop_r6_queue_reassigned
- [ ] `prop_r6_heart_petition_table`: prop_r6_petition_draft, prop_r6_petition_cosigned
- [ ] `prop_r6_drainage_pump`: prop_r6_pump_dry, prop_r6_pump_primed

출구·내부 길
- [ ] `exit_r6_e07_ash_chute`: closed, open
- [ ] `exit_r6_e08_medicine_ferry`: closed, open
- [ ] `exit_r6_e14_under_rail_shunt`: closed, open
- [ ] `exit_r6_e16_drainage_dark`: closed, open
- [ ] `route_r6_drainage_pump_run`: closed, open

지역 오브젝트
- [ ] `obj_r6_stone_stall`, `obj_r6_parts_booth`(a, b), `obj_r6_wait_bench`, `obj_r6_court_bench`
- [ ] `obj_r6_drain_cover`(round, square), `obj_r6_wall_lamp`, `obj_r6_medicine_crates`, `obj_r6_rubble`

장면과 검수
- [ ] `scene_bg_r6_intake_ring.json`, `scene_bg_r6_debt_hall.json`, `scene_bg_r6_stalls_drainage.json` + 배경+오브젝트 확인 그림 3장
- [ ] 다시 방문 장면: rv_after_quorum(intake_ring, debt_hall), rv_after_debt_surgery(intake_ring, stalls_drainage)
- [ ] 오브젝트 모아 보기 시트(review_sheet.py)
- [ ] inputs.json, QA.md, __pycache__ 삭제

## 도구와 팔레트 변경 (h0-icon-mood-v02의 tool 복사본에만)

- `tool/iconkit/icons.py`: 아이콘 변환 병렬 개수 기본값 8 → 2(최대 2로 고정). 세션 10개가 같은 컴퓨터를 쓰기 때문(COMMON.md).
- `tool/iconkit/render.py`, `tool/build.py`: 팔레트 상속 `"extends": "<파일>"`. 지역 팔레트가 palette_h0_mood.json을 그대로 물려받고 더하는 재질만 적는다. 공통 윤곽선·그림자 색이 바뀔 일이 없다. build 키는 물려받은 것까지 합친 팔레트로 계산한다.
- `recipes/palette_r6.json`: palette_h0_mood.json을 물려받고 R6 재질(tile, tile_wall, wet_slate, verdigris, canvas_ochre, court_wood, water_dark)과 environment 바탕색만 더함. 공통 색·styles는 바꾸지 않음.

## 기록

- 2026-09-27 준비: 자료 읽고 BRIEF.md와 계획을 씀. 준비 규칙보다 먼저 복사됐던 옛 도구 복사본(h0-icon-collage-v01의 tool)은 지웠다.
- 2026-09-27 04:25 COMMON.md에서 V1 확정. BRIEF.md를 V1 규칙(배경은 배경만, 물건은 오브젝트, 어두운 팔레트, 캐릭터 합성 미리보기 없음)으로 다시 썼다. h0-icon-mood-v02의 tool과 palette_h0_mood.json을 복사해 제작 시작.
