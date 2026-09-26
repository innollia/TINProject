# mp08-bg-r4-v01 — R4 Crownwell Archive 배경과 오브젝트 (아이콘 조합)

상태: **제작 중.** 2026-09-27 04시 기준 확정(분위기 V1, 빛·그림자는 게임 코드, 배경과 오브젝트 분리)에 맞춰 brief를 고치고 시작했다. 결과는 전부 candidate, 승인은 사용자만 한다. 게임에 연결하지 않는다.

| 필드 | 값 |
|---|---|
| 목적 | clean_base + occluder + prop(오브젝트) + state_variant. R4 세 층 배경과 그 지역 오브젝트 |
| 근거 결정 | 사용자 결정 2026-09-27: 아이콘 조합 양산(세션 10개), V1 분위기, 빛·그림자 코드 처리, 배경은 배경만·물건은 오브젝트, 캐릭터 합성 확인 그림 금지(COMMON.md) |
| 소유권 | 세션 08. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/mp08-bg-r4-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp08-bg-r4-v01/`. 정본·코드·씬·content 수정 없음. 다른 세션 폴더는 읽지도 쓰지도 않음 |
| 자산 identity | region `region_r4_crownwell_archive`, art key `art_world_r4_crownwell_archive`. content ID: `prop_r4_low_level_stacks`, `prop_r4_weight_lift_counter`, `prop_r4_glossary_slot`, `prop_r4_crown_fragment_plinth`, edge E04/E10/E12/E13. `bg_r4_*`, `fg_r4_*`, `exit_r4_*`, `obj_r4_*`는 이 작업의 설계 ID |
| 입력 계약 | COMMON.md(04시 확정판), PROJECT_ART_LAYER 0.1, 13·14, 09 §12, `brief_r4_crownwell_archive.md`. 해시는 `inputs.json` |
| 카메라 | 60° 정사영, 방위 고정, 바닥 깊이 ×0.866, 높이 ×0.5. 배율 원본 1 m = 226 px(사람 1.7 m = 192 px) |
| 입력 이미지 | 픽셀 입력 없음. at-icons node2d SVG(MIT) 조각. V1 결과는 눈으로만 비교 |
| 팔레트 | `recipes/palette_h0_mood.json`(복사본) 바탕의 `recipes/palette_r4.json` |
| 필요한 결과 | brief 6·8절 |
| 금지 | brief 12절 |
| 수정 범위 | 이 작업 폴더 안의 새 파일만 |
| 승인 상태 | candidate. Gold Standard 없음 |
| 검수 | `QA.md`. 실제 게임 3해상도는 not_run |
| 중단 이유 | 없음 |

## 도구 (h0-icon-mood-v02 `tool/` 복사본, 바꾼 것)
- `iconkit/icons.py`: 아이콘 변환 병렬 개수 기본값 8 → 2(세션 10개가 동시에 돔).
- `build.py`: 기록 파일의 `alpha`를 스타일 이름 대신 실제 픽셀로 판단(투명 전경 레이어를 environment 스타일로 그리기 때문).
- `compose_preview.py`: 배경의 따로 뽑은 그림자(`_shadow.png`)를 확인 그림에 먼저 깐다(장면 `background_shadow`, 기본 켬). 장면 `foreground` 목록의 전체 크기 투명 레이어를 오브젝트 위에 올린다.
- `review_sheet.py`: `_emit.png`를 따로 칸으로 넣지 않는다.
- 레시피 쪽 설정: 배경은 `style_override: {"shadow_output": "separate"}`로 벽 발치 그림자를 `_shadow.png`로 뺀다. 전경은 `style_override: {"background": null, "shadow_output": "separate"}`로 투명하게 그린다.

## 작성자 설계로 정한 값
- 층마다 한 화면(세 구역), 승강기·우물 자리를 세 층에서 같게(brief 4절).
- 배율: 사람 키 기준 원본 1 m = 226 px. V1 H0 배경은 180 px/m이다. 다른 세션이 180 px/m를 그대로 쓰면 지역마다 사람 대비 건물 크기가 달라질 수 있어서 최종 보고 때 알린다.
- 오브젝트 모양, 막이 모양, 재질과 색(brief 6·9절).


## 체크리스트
자산 하나씩: 레시피 → build → read로 직접 확인 → 고치기(최대 2번) → 다음. 배경은 한 번에 한 장.

### 0. 준비
- [x] 자료 읽기(COMMON 확정판, V1 기록·QA·팔레트·배경 레시피·도구, 규칙 문서, region·prop JSON)
- [x] brief 확정 기준으로 고침
- [x] V1 `tool/`(__pycache__ 제외)와 `palette_h0_mood.json` 복사, 도구 수정(위 목록)
- [ ] `palette_r4.json`, `inputs.json`

### 1. 배경 `bg_r4_hall`
- [ ] base_clean (+ `_shadow`)
- [ ] fg_r4_hall_balustrade

### 2. 오브젝트 (세 구역 공용)
- [ ] obj_r4_weight_lift_car
- [ ] obj_r4_lamp_post, obj_r4_wall_lamp
- [ ] obj_r4_copy_shelf, obj_r4_translation_desk, obj_r4_record_boxes, obj_r4_paper_drift
- [ ] prop_r4_counter_idle / spent
- [ ] prop_r4_slot_empty / filled
- [ ] exit_r4_e04_crownwell_ascent _closed / _open
- [ ] exit_r4_e10_bell_cable_lift _closed / _open
- [ ] scene_bg_r4_hall(+ rv_after_canonical, rv_after_glossary_slot), check_bg_r4_hall_1280x720

### 3. 배경 `bg_r4_stacks`
- [ ] base_clean, fg_r4_stacks_ladder
- [ ] prop_r4_stacks_intact / filed
- [ ] exit_r4_e12_courier_shaft _closed / _open
- [ ] scene_bg_r4_stacks(+ rv_after_canonical), check 그림

### 4. 배경 `bg_r4_observatory`
- [ ] base_clean, fg_r4_observatory_parapet
- [ ] prop_r4_plinth_object / titled
- [ ] exit_r4_e13_crown_stair _closed / _open
- [ ] scene_bg_r4_observatory, check 그림

### 5. 마무리
- [ ] 오브젝트 모아 보기 시트, QA.md, `__pycache__` 지우기 → R5
