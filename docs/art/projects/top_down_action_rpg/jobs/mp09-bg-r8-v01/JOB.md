# mp09-bg-r8-v01 — R8 The Folding School 배경·사물

> ⚠ COMMON.md 04:25판(V1 확정) 전에 쓴 계획이다. R8을 시작할 때 R6 JOB.md(V1판) 형식으로 다시 쓴다: 도구는 R7 작업 폴더의 tool, 팔레트는 palette_h0_mood.json을 물려받는 palette_r8.json, 만들 대상은 배경(base_clean·foreground) + 오브젝트 + 장면 JSON + 배경+오브젝트 확인 그림.

상태: **준비 완료, 제작 전.** COMMON.md 맨 위의 '준비만 할 것' 줄 때문에 레시피 작성, 도구 복사, build는 하지 않았다. 결과가 생기면 전부 candidate이고 승인은 사용자만 한다. 게임에 연결하지 않는다. R7(mp09-bg-r7-v01)을 끝낸 뒤 시작한다.

| 필드 | 값 |
|---|---|
| 목적 | environment_master + clean_base + prop + occluder + state_variant. 아이콘 조합 코드 그림 |
| 근거 결정 | 2026-09-27 아이콘 조합 양산 지시(COMMON.md, 14 §1). 세션 09 담당: R6 → R7 → R8 |
| 소유권 | 세션 09. 쓰기: `assets/art/top_down_action_rpg/jobs/mp09-bg-r8-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp09-bg-r8-v01/`. 정본·코드·씬·content 수정 없음 |
| 자산 identity | `region_r8_folding_school` / `art_world_r8_folding_school`. 사물 2종·출구 1개(edge ID)·내부 길 1개는 content의 실제 ID. 구역 ID 3개, `exit_*`·`route_*`·`foreground_*` 이름은 작성자 설계 |
| 입력 계약 버전 | COMMON.md(2026-09-27 03:15판), 이 폴더 BRIEF.md, R6 BRIEF.md §4, 13, 14, 09 §12, IMAGE_ASSET_WORKFLOW §3, PROJECT_ART_LAYER 0.1, region·prop·recovery JSON. SHA-256은 제작 시작 때 inputs.json에 기록 |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 180 px/m, 깊이 ×0.866, 높이 110 px/m(플레이어 키 기준, 작성자 설계) |
| 입력 이미지 | 픽셀 입력 없음. 화풍은 h0-icon-collage-v01 결과를 눈으로 비교만. 모양 재료는 `addons/at-icons/node2d` SVG |
| 필요한 결과 | 아래 체크리스트 |
| 내용 고정 | BRIEF.md §3, §6, §7 |
| 금지 | BRIEF.md §9 |
| 수정 범위 | 이 작업 폴더 두 곳의 새 파일만 |
| 승인 상태 | 원본 입력 없음, approved 기준 없음(Gold Standard 0), 결과는 candidate |
| 검수 항목 | 구도·화풍·기술·상태를 각각 pass/partial/fail/not_run으로 QA.md에 |
| 중단 이유 | 지금: 분위기 기준(톤앤매너)과 캐릭터 8방향 형식 확정 대기(COMMON.md). 그 밖에는 없음 |

## 만들 대상

배경 (구역마다 2560×1440, BRIEF.md §3·§6)
- [ ] `bg_r8_approach_court`: base_clean, foreground_r8_approach_lintel, master_composite, preview_reassembled
- [ ] `bg_r8_store_lineage`: base_clean, master_composite, preview_reassembled (전경 없음)
- [ ] `bg_r8_yard_chamber`: base_clean, foreground_r8_cloth_line, master_composite, preview_reassembled

사물 (투명, 접촉 피벗, 그림자 따로, BRIEF.md §7)
- [ ] `prop_r8_medium_store_shelf`: prop_r8_shelf_stocked, prop_r8_shelf_quarantined
- [ ] `prop_r8_cut_chamber_wall`: prop_r8_wall_marked, prop_r8_wall_opened

출구·내부 길 (2560×1440 투명 겹침판)
- [ ] `exit_r8_e18_folding_school_approach`: closed, open
- [ ] `route_r8_course_index_return`: index_closed, index_open, chamber_closed, chamber_open

미리보기와 기록
- [ ] 구역별 1280×720 처음 방문 미리보기 3장
- [ ] 다시 방문 미리보기: rv_after_registration(store_lineage), rv_after_verdict(yard_chamber), 두 번째 방문 뒷길 열림(approach_court + yard_chamber)
- [ ] 사물·출구 상태 모아 보기 시트(review_sheet.py)
- [ ] inputs.json, QA.md

## 시작할 때 할 일 (준비 줄이 지워지고 R7이 끝난 뒤)

1. COMMON.md를 다시 읽고 확정된 톤앤매너를 BRIEF.md §4·§5·§9에 반영한다.
2. R7 작업 폴더의 `tool\`(__pycache__ 제외)와 `palette_h0.json`을 복사한다. 그사이 기준 도구가 바뀌었으면 그 변경을 먼저 합치고 여기에 적는다. `iconkit\icons.py` 병렬 개수는 2 이하.
3. `palette_r8.json`을 만들고 H0에서 바꾼 점을 아래 '도구와 팔레트 변경'에 적는다.
4. base_clean부터 한 장씩: 레시피 → build → 직접 보기 → 고치기(자산당 최대 2번). 배경은 한 번에 한 장.
5. 사물 → 출구·길 상태 → 전경 → master_composite·미리보기 → 모아 보기 시트 → QA.md.
6. 끝나면 __pycache__를 지우고 탑다운 담당 중간 보고, 그다음 3순위 범용(자연) 작업으로 간다(세션 09는 2순위 없음).

## 도구와 팔레트 변경

(아직 없음)

## 기록

- 2026-09-27 준비: 자료 읽음(COMMON.md, region·prop·recovery JSON, 02 §1.1·§5.2·§6.1·§7.9·§8.9, 09 §12, 13, 14, IMAGE_ASSET_WORKFLOW, PROJECT_ART_LAYER, 시험 작업 기록). BRIEF.md와 이 계획을 씀. 준비 규칙보다 먼저 복사됐던 도구 복사본(assets 쪽 작업 폴더)은 지웠다. 제작한 그림은 없다.
