# mp06-bg-h0-v01 — H0 The Undersign Exchange 배경·오브젝트 (아이콘 조합 양산)

상태: **candidate 완성(1차)**. 2026-09-27 기준 확정(COMMON.md, 저장소 `docs/art/mass_production/COMMON.md`) 뒤 V1 도구·팔레트로 다시 시작해 배경 4구역, 전경 4장, 오브젝트 15종(상태 포함 25장), 장면 JSON 4개, 확인 그림 4장을 만들었다. 게임에 연결하지 않았다. 승인은 사용자만 한다.

## 필드 (14 §3)

| 필드 | 값 |
|---|---|
| 목적 | clean_base + occluder + prop(오브젝트) + state_variant (H0 전체 4구역) |
| 소유권 | 세션 06. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/mp06-bg-h0-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp06-bg-h0-v01/`. 정본·게임 코드·씬·content 수정 없음. 커밋·푸시 없음 |
| 자산 identity | region `region_h0_undersign_exchange`, art key `art_world_h0_undersign`. content 사물 `prop_h0_ration_counter`, `prop_h0_counterweight_map`. 관문 `gate_g0_arrival_declaration`. 출구 `route_e01`~`route_e05`. 내부 경로 `return_desk_lift`. service `service_h0_return_desk`. **미술 설계 ID**: 구역 `h0_a_arrival_approach`, `h0_b_exchange_shelf`, `h0_c_return_desk`, `h0_d_ash_stair`, `prop_h0_return_desk`, `obj_h0_*`, `foreground_*` |
| 입력 계약 | `inputs.json` (SHA-256). 규칙: COMMON.md, IMAGE_ASSET_WORKFLOW, VISUAL_DIRECTION, PROJECT_ART_LAYER, 09 §12, 13, 14, 기존 H0 brief, `BRIEF_H0_AREAS.md` |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 깊이 ×0.866, 앞면 높이 ×0.5 |
| 입력 이미지 | V1 기준 그림 `asset_bg_h0_v1_1280x720.png`, `asset_sheet_v1_props_0.5x.png`(눈으로만), 아이콘 목록 그림(`input/`), 플레이어 `idle_down`(키 측정용, 어디에도 합치지 않음) |
| 필요한 결과 | 아래 '결과' |
| 내용 고정 | `BRIEF_H0_AREAS.md` §4~§8 |
| 화풍 | V1(`h0-icon-mood-v02`). 붓자국 설정 그대로 |
| 팔레트 | `recipes/palette_h0_mood.json`(V1 그대로, 바꾼 값 없음) |
| 금지 | 사람·적·글자·도장 기호·UI·워터마크, 원작 고유 요소, 공용 사물 3개 그려 넣기, 원래 아이콘 모양이 읽히는 조각, 장면 조명·비네트·빛 웅덩이, 캐릭터를 배경에 합친 그림, 다른 mpNN 폴더 읽기·쓰기 |
| 수정 범위 | 이 job 폴더 안에서만. 기준 자료는 고치지 않음 |
| 승인 상태 | Gold Standard 0개. V1은 사용자가 고른 분위기 기준(개별 그림은 candidate). 이 job 결과는 전부 candidate |
| 검수 항목 | `QA.md` |
| 중단 이유 | 없음 |

## 결과

배경 (`output/<구역>/`, 2560×1440, 원점 = 논리 (0,0)):

| 구역 | base_clean(+ `_shadow`) | foreground(투명, + `_shadow`) | 레시피 |
|---|---|---|---|
| `h0_a_arrival_approach` | `base_clean.png` | `foreground_beam.png` | `bg_h0_arrival_approach.json`, `fg_h0_a_beam.json` |
| `h0_b_exchange_shelf` | `base_clean.png` | `foreground_south_rail.png` | `bg_h0_b_exchange_shelf.json`, `fg_h0_b_rail.json` |
| `h0_c_return_desk` | `base_clean.png` | `foreground_ledge_rail.png` | `bg_h0_c_return_desk.json`, `fg_h0_c_ledge_rail.json` |
| `h0_d_ash_stair` | `base_clean.png` | `foreground_stair_arch.png` | `bg_h0_d_ash_stair.json`, `fg_h0_d_arch.json` |

B·C·D는 공통 바닥 `recipes/_inc_h0_floor.json`을 함께 쓴다. 배경 그림자(벽 발치 AO, Crown Well 덮개 그림자)는 `base_clean_shadow.png`로 따로 나온다.

오브젝트 (`output/<오브젝트>/<프레임>.png` + `_shadow.png`, 빛나는 것은 `_emit.png`, 피벗은 같은 이름 `.json`): 모양·상태는 BRIEF §4.

| 오브젝트 | 프레임 |
|---|---|
| `prop_h0_ration_counter` | `ps_open`, `ps_rationing` |
| `prop_h0_counterweight_map` | `ps_matched`, `ps_contested` |
| `gate_g0_arrival_declaration` | `closed`, `open` |
| `prop_h0_return_desk` | `prop_h0_return_desk` |
| `return_desk_lift` | `conditional`, `open` |
| `route_e02_sluice_road` | `conditional`, `open` |
| `route_e04_crownwell_ascent` | `conditional`, `open` |
| `obj_h0_barrier_arm` (E03·E05) | `conditional`, `open` |
| `obj_h0_brazier` | 1 |
| `obj_h0_wall_sconce` (벽 부착: 받침 아래 가운데) | 1 |
| `obj_h0_post_lantern` (기둥 위: 발) | 1 |
| `obj_h0_crate` | `crate_large`, `crate_small`, `crate_stack` |
| `obj_h0_rubble` | `rubble_large`, `rubble_small` |
| `obj_h0_drain_cover` (바닥) | 1 |
| `obj_h0_docket_rack` (벽 부착: 아래 가운데) | 1 |

장면 JSON (`recipes/`): `scene_h0_a_arrival_approach.json`, `scene_h0_b_exchange_shelf.json`, `scene_h0_c_return_desk.json`, `scene_h0_d_ash_stair.json` — 오브젝트 자리(원본 px), 벽 부착물의 `sort_y`, 빛나는 것의 `light`.

확인 그림·시트 (`preview/`): `h0_<구역>_check_1280x720.png` 4장(배경+오브젝트, 사람·적 없음), `sheet_h0_areas.png`, `sheet_h0_objects_region.png`, `sheet_h0_objects_content.png`, `sheet_h0_objects_routes.png`.

## 크기 기준 (작성자 설계)

플레이어 `idle_down` 실제 그림 높이 190 px(원본) ≈ 1.7 m → 가로 1 m ≈ 224 px, 바닥 깊이 ≈ 194 px, 높이 ≈ 112 px. V1 레시피(180 px/m)에서 온 것은 `scale_all` 1.24 + 높이(extrude) ×1.24. 새로 그린 것은 이 값으로 바로 그렸다. A의 바닥 배치(기존 brief 논리 좌표)는 그대로 두고 벽·기둥 높이만 ×1.24.

## 도구 변경 (V1 도구 복사본에만)

- `tool/iconkit/icons.py`: `prefetch` 병렬 개수 8 → 2 (세션 10개가 같은 컴퓨터를 씀).
- `tool/iconkit/render.py`: 레시피 `offset: [dx, dy]` 추가(모든 조각 위치를 옮김, `scale_all` 뒤). 그림을 다시 그리지 않고 캔버스 여백을 32 px 이상으로 넓히려고.
- `tool/compose_preview.py`: 배경 `_shadow.png`를 오브젝트보다 먼저 깔기, 장면 `foreground` 목록(전경 그림자는 배경 그림자와 함께, 전경 그림은 모든 오브젝트 위) 추가. 배경의 AO를 따로 뽑았기 때문(COMMON: 바닥 그림자는 그림에 합치지 않음).
- `tool/review_sheet.py`: `_emit.png`를 따로 칸으로 그리지 않게.
- 배경 레시피는 `style_override: {"shadow_output": "separate"}`로 AO를 `base_clean_shadow.png`에 뽑는다. 전경 레시피는 `{"background": null, ...}`로 투명하게 만든다.
- 준비 단계(03:26)에 복사한 옛 도구·팔레트·레시피(`h0-icon-collage-v01`)는 지우고 V1 것으로 바꿨다.

## 체크리스트

- [x] 준비: 자료 읽기, 구역 나누기 brief, 목록 (03:25~04:05)
- [x] 기준 확정 뒤 COMMON 다시 읽기, 옛 도구·레시피를 V1 것으로 교체, workers 2
- [x] 오브젝트: V1 배경에서 뺀 7종 + content·관문 3종(상태별) + 새 5종 → 모아 보기 시트 3장
- [x] 배경 A(조리개 무늬·얼룩·높이 고침) → 장면 JSON → 확인 그림
- [x] 배경 B, C, D + 전경 4장 → 장면 JSON → 확인 그림 → `sheet_h0_areas.png`
- [x] 고침: 벽등 전구 모양, E02·E05 차단물 대각선, D 계단참 경계, A 상자 위치, 오브젝트 여백 32 px
- [x] QA.md, __pycache__ 없음 확인
- [ ] 다음: R1 `mp06-bg-r1-v01`
