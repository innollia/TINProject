# mp09-bg-r7-v01 — R7 The Hollow Orchard 배경·오브젝트

상태: **제작 중(V1 기준).** 결과는 전부 candidate이고 승인은 사용자만 한다. 게임에 연결하지 않는다.

| 필드 | 값 |
|---|---|
| 목적 | clean_base + occluder + prop(오브젝트) + state_variant. 아이콘 조합 코드 그림 |
| 근거 결정 | 2026-09-27 아이콘 조합 양산 지시와 V1 확정(COMMON.md 04:25판). 세션 09 담당: R6 → R7 → R8 |
| 소유권 | 세션 09. 쓰기: `assets/art/top_down_action_rpg/jobs/mp09-bg-r7-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp09-bg-r7-v01/`. 정본·코드·씬·content 수정 없음 |
| 자산 identity | `region_r7_hollow_orchard` / `art_world_r7_hollow_orchard`. 사물 4종·출구 4개(edge ID)·내부 길 1개는 content의 실제 ID. 구역 ID, `obj_*`·`exit_*`·`route_*`·`foreground_*` 이름은 작성자 설계 |
| 입력 계약 버전 | COMMON.md 04:25판, 이 폴더 BRIEF.md, R6 BRIEF.md §4, 13, 14, 09 §12, IMAGE_ASSET_WORKFLOW §3, PROJECT_ART_LAYER 0.1, region·prop·recovery JSON. SHA-256은 inputs.json |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 180 px/m, 깊이 ×0.866, 높이 110 px/m(플레이어 키 기준, 작성자 설계) |
| 입력 이미지 | 픽셀 입력 없음. 화풍은 h0-icon-mood-v02 V1 결과를 눈으로 비교만. 모양 재료는 `addons/at-icons/node2d` SVG |
| 필요한 결과 | 아래 체크리스트 |
| 내용 고정 | BRIEF.md §3, §6, §7 |
| 금지 | BRIEF.md §9 |
| 수정 범위 | 이 작업 폴더 두 곳의 새 파일만 |
| 승인 상태 | 원본 입력 없음, approved 기준 없음(Gold Standard 0), 결과는 candidate |
| 검수 항목 | 구도·화풍·기술·상태를 각각 pass/partial/fail/not_run으로 QA.md에 |
| 중단 이유 | 없음 |

## 만들 대상

배경 (2560×1440)
- [ ] `bg_r7_wall_causeway`: base_clean
- [ ] `bg_r7_orchard_shelter`: base_clean
- [ ] `bg_r7_crown_verge`: base_clean(받침 없는 원형 단), foreground_r7_wall_stub

content 사물
- [ ] `prop_r7_outer_wall_seam`: prop_r7_seam_sealed, prop_r7_seam_reported
- [ ] `prop_r7_crown_position_plinth`: prop_r7_plinth_unclaimed, prop_r7_plinth_claimed
- [ ] `prop_r7_storm_verge_cut`: prop_r7_cut_open, prop_r7_cut_matched, prop_r7_cut_filed
- [ ] `prop_r7_shelter_ring_ledger`: prop_r7_ledger_open, prop_r7_ledger_quota

출구·내부 길
- [ ] `exit_r7_e09_orchard_causeway`, `exit_r7_e13_crown_stair`, `exit_r7_e15_supply_gantry`, `exit_r7_e16_drainage_dark`: closed, open
- [ ] `route_r7_storm_verge_shelter_run`: verge_closed, verge_open, shelter_closed, shelter_open

지역 오브젝트
- [ ] `obj_r7_hollow_tree`(a, b, c), `obj_r7_shelter`(a, b), `obj_r7_hearth_ring`, `obj_r7_dry_shrub`(a, b)
- [ ] `obj_r7_fallen_fruit`, `obj_r7_wall_rubble`, `obj_r7_lantern_post`

장면과 검수
- [ ] 장면 JSON 3개 + 다시 방문 3개, 배경+오브젝트 확인 그림 6장
- [ ] 오브젝트 모아 보기 시트 3장
- [ ] inputs.json, QA.md

## 도구와 팔레트 변경

- 도구: R6 작업 폴더의 tool을 그대로 복사(h0-icon-mood-v02 tool + 병렬 2 + 팔레트 상속 + 장면 전경 레이어). R6 JOB.md '도구와 팔레트 변경' 참고. 이 폴더에서 더 바꾼 것은 아래에 적는다.
- `recipes/palette_r7.json`: palette_h0_mood.json을 물려받고 R7 재질(loam, root_flag, basalt, basalt_dark, basalt_cap, bark_hollow, bark_inner, leaf_dry, verge_scour, canvas_shelter, void_cut, fruit, rope)과 environment 바탕색만 더함.

## 기록

- 2026-09-27 준비: 자료 읽고 BRIEF.md와 계획을 씀. 옛 도구 복사본은 지웠다.
- 2026-09-27 R6를 끝내고 R7 시작. BRIEF.md를 V1 규칙으로 다시 썼다.
