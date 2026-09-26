# mp06-bg-r1-v01 — R1 The Returning Kiln 배경·사물 (아이콘 조합 양산)

상태: **spec_ready, 준비만 끝남. 그림은 아직 만들지 않음.** COMMON.md 맨 위 '준비만' 줄에 따라 레시피 작성·도구 복사·build를 하지 않고 기다린다. assets 쪽 작업 폴더도 아직 만들지 않았다. 순서상 H0 `mp06-bg-h0-v01`을 끝낸 다음에 시작한다. 결과는 전부 candidate이고 승인은 사용자만 한다.

## 필드 (14 §3)

| 필드 | 값 |
|---|---|
| 목적 | environment_master + clean_base + prop + occluder + state_variant (R1 전체 5구역) |
| 소유권 | 세션 06. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/mp06-bg-r1-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp06-bg-r1-v01/`. 정본·게임 코드·씬·content 수정 없음. 커밋·푸시 없음 |
| 자산 identity | region `region_r1_returning_kiln`, art key `art_world_r1_returning_kiln`. content 사물 `prop_r1_wrong_return_door`, `prop_r1_ash_garden_thread`. 출구 `route_e01_ash_stair`, `route_e06_quiet_ward_passage`, `route_e07_ash_chute`. 관문 `gate_g1_ash_debt`(따로 세운 구조물 없음, E06·E07 상태로 표현). service `service_r1_warm_door`. **미술 설계 ID**: 구역 `r1_a_intake_stack`, `r1_b_wrong_return`, `r1_c_ash_garden`, `r1_d_cold_relay`, `r1_e_deep_door`, 사물 `prop_r1_warm_door`, 전경 `foreground_*` 5개 |
| 입력 계약 | `inputs.json` (SHA-256). 규칙: COMMON.md, IMAGE_ASSET_WORKFLOW, VISUAL_DIRECTION, PROJECT_ART_LAYER, 09 §4.1·§12, 13, 14, `BRIEF_R1.md` |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 깊이 ×0.866, 앞면 높이 ×0.5. 좌표는 논리 1280×720(원본은 ×2) |
| 입력 이미지 | `inputs.json`의 이미지 항목. 시험 작업 미리보기는 화풍 기준(눈으로만), 플레이어 `idle_down`은 키 기준(게임 화면 미리보기에만). 배경에 굽거나 잘라 쓰지 않는다 |
| 필요한 결과 | 아래 '만들 대상 목록' |
| 내용 고정 | `BRIEF_R1.md` §4~§8 |
| 화풍 기준 | 시험 작업 `h0-icon-collage-v01` (눈으로 맞춤), 붓자국 설정 그대로. 톤앤매너 자료가 확정되면 그것을 우선 적용 |
| 팔레트 | 시작할 때 `palette_h0.json`을 복사하고 `palette_r1.json`을 만든다. 윤곽선·그림자·공통 색은 그대로, 바닥·벽·금속·강조 색만 바꾸고 바꾼 값을 여기에 적는다(BRIEF §9) |
| 금지 | 사람·적·글자·도장 기호·UI·워터마크를 배경에 굽기, 원작 고유 요소, 산 식물, 불꽃·연기 효과 그림, 공용 사물 3개(세션 01 담당) 그려 넣기, 원래 아이콘 모양이 읽히는 조각, 다른 mpNN 폴더 읽기·쓰기 |
| 수정 범위 | 이 job 폴더 안에 새 파일만 만든다. 기준 자료와 다른 job 파일은 고치지 않는다 |
| 승인 상태 | Gold Standard 0개. 화풍 기준인 시험 작업은 candidate(사용자가 방식만 인정). 이 job 결과는 전부 candidate |
| 검수 항목 | 구도·화풍·기술·state 모두 `not_run` |
| 중단 이유 | COMMON.md '준비만' 줄. 입력 누락은 없음 |

## 만들 대상 목록

사물·출구 상태 그림 (투명 PNG + `_shadow.png` + `.json`, `output/<asset_id>/<state>.png`). 모양·위치·상태 설명은 BRIEF §4~§8.

| asset | 상태 | 구역 |
|---|---|---|
| `route_e07_ash_chute` | `conditional`, `open` (미닫이 덮개만) | A |
| `prop_r1_wrong_return_door` | `ps_intact`, `ps_opened` (빈 기록판 포함) | B |
| `prop_r1_ash_garden_thread` | `ps_available`, `ps_spent` | C |
| `prop_r1_warm_door` | `closed`, `open` | D |
| `route_e06_quiet_ward_passage` | `conditional`, `open` (문짝·빗장만) | D |

`route_e01_ash_stair`는 상태가 `open` 하나라 A의 base에 그린다. Deep Door는 상호작용이 없어 E의 base에 그린다. 합계 10장.

구역 레이어 (`output/<area_id>/`, 2560×1440):

| 구역 | 파일 |
|---|---|
| `r1_a_intake_stack` | `base_clean`, `foreground_flue`, `master_composite`, `preview_reassembled` |
| `r1_b_wrong_return` | `base_clean`, `foreground_arch_lip`, `master_composite`, `preview_reassembled` |
| `r1_c_ash_garden` | `base_clean`, `foreground_south_parapet`, `master_composite`, `preview_reassembled` |
| `r1_d_cold_relay` | `base_clean`, `foreground_relay_pipe`, `master_composite`, `preview_reassembled` |
| `r1_e_deep_door` | `base_clean`, `foreground_broken_beam`, `master_composite`, `preview_reassembled` |

미리보기 (`preview/`): `<area_id>_game_1280x720.png` 5장, `sheet_r1_props.png`, `sheet_r1_areas.png`.

## 크기 기준

H0와 같다(`mp06-bg-h0-v01/JOB.md`): 플레이어 190 px(원본) ≈ 1.7 m → 가로 1 m ≈ 224 px, 바닥 깊이 ≈ 194 px, 높이 ≈ 112 px. E01 계단 폭은 H0 D와 같게(논리 280).

## 도구

- 시작할 때 그때의 기준 작업(지금은 시험 작업 `h0-icon-collage-v01`)에서 `tool/`(__pycache__ 제외)과 `palette_h0.json`을 복사하고 `prefetch` workers를 2로 낮춘다. H0 작업에서 추가한 기능(레이어 조립 등)은 H0 사본에서 가져오고 여기에 적는다.

## 재개 순서 (H0를 끝낸 뒤)

1. COMMON.md를 다시 읽는다. '준비만' 줄이 남아 있으면 멈춘다.
2. 새 기준(톤앤매너 자료)을 반영해 BRIEF §9 색·재질을 고친다.
3. assets 쪽 폴더를 만들고 도구·팔레트를 복사한다. `palette_r1.json`을 만든다.
4. `inputs.json` 해시를 다시 계산한다.
5. 아래 체크리스트 순서대로 한 장씩 만든다: 레시피 → build → 직접 확인 → 고치기(최대 2번).

## 체크리스트

- [x] 자료 읽기: region·prop·recovery·encounter JSON, 02 §4.3·§5.2·§6.1·§7.2, 03(R1 장소), 08(checkpoint), 09 §4.1·§12, 13, 14
- [x] `BRIEF_R1.md` 작성 (층 5개 나누기, 배치, 레이어·상태)
- [x] 만들 대상 목록, `inputs.json` (04:05)
- [ ] 기준 확정 대기 (톤앤매너 자료)
- [ ] H0 `mp06-bg-h0-v01` 끝내기
- [ ] 재개 준비 (위 1~4)
- [ ] 사물·출구 상태 그림 10장 → `sheet_r1_props.png`
- [ ] A: base_clean, foreground_flue, master_composite, preview_reassembled, 게임 화면 미리보기
- [ ] B: 같은 묶음
- [ ] C: 같은 묶음
- [ ] D: 같은 묶음
- [ ] E: 같은 묶음 → `sheet_r1_areas.png`
- [ ] QA.md, __pycache__ 정리
- [ ] 1순위 끝 중간 보고 → 2순위 08 Descent Exploration
