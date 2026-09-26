# mp06-bg-h0-v01 — H0 The Undersign Exchange 배경·사물 (아이콘 조합 양산)

상태: **spec_ready, 준비만 끝남. 그림은 아직 만들지 않음.** COMMON.md 맨 위 '준비만' 줄(2026-09-27: 분위기 기준과 캐릭터 스프라이트 형식을 다시 정하는 중)에 따라 레시피 작성·build를 하지 않고 기다린다. 사용자 지시(03:23 KST): 톤앤매너 자료가 오고 있으니 작업 준비까지만 한다. 결과는 전부 candidate이고 승인은 사용자만 한다.

## 필드 (14 §3)

| 필드 | 값 |
|---|---|
| 목적 | environment_master + clean_base + prop + occluder + state_variant (H0 전체 4구역) |
| 소유권 | 세션 06. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/mp06-bg-h0-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp06-bg-h0-v01/`. 정본·게임 코드·씬·content 수정 없음. 커밋·푸시 없음 |
| 자산 identity | region `region_h0_undersign_exchange`, art key `art_world_h0_undersign`. content 사물 `prop_h0_ration_counter`, `prop_h0_counterweight_map`. 관문 `gate_g0_arrival_declaration`. 출구 `route_e01_ash_stair`~`route_e05_foundry_tram`. 내부 경로 `return_desk_lift`. service `service_h0_return_desk`. **미술 설계 ID**: 구역 `h0_a_arrival_approach`, `h0_b_exchange_shelf`, `h0_c_return_desk`, `h0_d_ash_stair`, 사물 `prop_h0_return_desk`, 전경 `foreground_*` 4개 |
| 입력 계약 | `inputs.json` (SHA-256). 규칙: COMMON.md, IMAGE_ASSET_WORKFLOW, VISUAL_DIRECTION, PROJECT_ART_LAYER, 09 §12, 13, 14, 기존 H0 brief, `BRIEF_H0_AREAS.md` |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 깊이 ×0.866, 앞면 높이 ×0.5. 좌표는 논리 1280×720(원본은 ×2) |
| 입력 이미지 | `inputs.json`의 이미지 항목. 시험 작업 미리보기 3장은 화풍 기준(눈으로만), 아이콘 목록 그림 4장은 아이콘 고르기용, 플레이어 `idle_down`은 키 기준(게임 화면 미리보기에만). 어느 것도 배경에 굽거나 잘라 쓰지 않는다 |
| 필요한 결과 | 아래 '만들 대상 목록' |
| 내용 고정 | `BRIEF_H0_AREAS.md` §4~§7 (A의 배치는 기존 brief 그대로) |
| 화풍 기준 | 시험 작업 `h0-icon-collage-v01` (눈으로 맞춤). 붓자국 설정은 시험 작업 그대로. 톤앤매너 자료가 확정되면 그것을 우선 적용 |
| 팔레트 | `recipes/palette_h0.json` (시험 작업 그대로). 톤앤매너 반영으로 바꾸면 여기에 기록 |
| 금지 | 사람·적·글자·도장 기호·UI·워터마크를 배경에 굽기, 원작 고유 요소, 공용 사물 3개(세션 01 담당) 그려 넣기, 원래 아이콘 모양이 읽히는 조각, 다른 mpNN 폴더 읽기·쓰기 |
| 수정 범위 | 이 job 폴더 안에 새 파일만 만든다. 기준 자료와 다른 job 파일은 고치지 않는다 |
| 승인 상태 | Gold Standard 0개. 화풍 기준인 시험 작업은 candidate(사용자가 방식만 인정). 이 job 결과는 전부 candidate |
| 검수 항목 | 구도·화풍·기술·state 모두 `not_run` |
| 중단 이유 | COMMON.md '준비만' 줄. 입력 누락은 없음 |

## 만들 대상 목록

사물·관문·출구 상태 그림 (투명 PNG + `_shadow.png` + `.json`, `output/<asset_id>/<state>.png`). 모양·위치·상태 설명은 BRIEF §4~§7.

| asset | 상태 | 구역 |
|---|---|---|
| `prop_h0_ration_counter` | `ps_open`, `ps_rationing` | A |
| `gate_g0_arrival_declaration` | `closed`, `open` (둘 다 통로를 막지 않음) | A |
| `prop_h0_counterweight_map` | `ps_matched`, `ps_contested` (바닥 사물) | B |
| `route_e02_sluice_road` | `conditional`, `open` (차단 들보만) | B |
| `route_e04_crownwell_ascent` | `conditional`, `open` (격자문만) | B |
| `route_e05_foundry_tram` | `conditional`, `open` (차단봉만) | B |
| `prop_h0_return_desk` | 한 상태 | C |
| `return_desk_lift` | `conditional`, `open` (격자문·받침판만) | C |
| `route_e03_mercy_causeway` | `conditional`, `open` (차단봉만) | C |

`route_e01_ash_stair`는 상태가 `open` 하나라 D의 base에 그린다. 합계 17장.

구역 레이어 (`output/<area_id>/`, 2560×1440):

| 구역 | 파일 |
|---|---|
| `h0_a_arrival_approach` | `base_clean`, `foreground_beam`, `master_composite`, `preview_reassembled` |
| `h0_b_exchange_shelf` | `base_clean`, `foreground_south_rail`, `master_composite`, `preview_reassembled` |
| `h0_c_return_desk` | `base_clean`, `foreground_south_ledge`, `master_composite`, `preview_reassembled` |
| `h0_d_ash_stair` | `base_clean`, `foreground_stair_parapet`, `master_composite`, `preview_reassembled` |

미리보기 (`preview/`): `<area_id>_game_1280x720.png` 4장(플레이어 키 기준을 올린 게임 화면), `sheet_h0_props.png`, `sheet_h0_areas.png`.

## 크기 기준 (작성자 설계)

COMMON의 "사물·구조물 크기는 플레이어 키(화면 96px)에 맞춘다"를 따른다. 시험 작업 플레이어 `idle_down`의 실제 그림 높이는 190 px(원본, 알파 범위 측정)이고 이것을 1.7 m로 본다. 원본 기준 높이 1 m ≈ 112 px, 가로 1 m ≈ 224 px, 바닥 깊이 1 m ≈ 194 px. 시험 작업의 180 px/m(가로)보다 사물이 약 1.24배 커진다. 기존 brief가 고정한 A의 바닥 배치(우물 외경 220, counter 바닥 260×110, 통로 폭)는 논리 px 그대로 둔다.

## 도구

- 지금 있는 `tool/`·`recipes/`(palette + 레시피 4개)·`input/` 복사본은 03:26에 만들었다. COMMON.md의 '준비만' 줄(도구 복사도 하지 않음)을 확인하기 전이었다. 기준 확정 전 사본이므로 재개할 때 지우고 그때의 기준 작업에서 다시 복사한다.
- `tool/iconkit/icons.py`: `prefetch` 기본 병렬 개수 8 → 2 (세션 10개가 같은 컴퓨터를 씀). 다시 복사하면 다시 적용한다.
- 예정: 구역 레이어 조립 기능(base_clean + 상태 레이어 + foreground → master_composite, preview_reassembled, 좌표 어긋남 검사). 만들면 여기에 적는다.

## 재개 순서 (사용자가 "이어서 해"라고 하면)

1. COMMON.md를 다시 읽는다. '준비만' 줄이 남아 있으면 다시 멈춘다.
2. 새 기준(톤앤매너 자료, 새 시험 작업)을 읽고 BRIEF §8 색·재질과 이 파일의 화풍·팔레트 줄을 고친다.
3. `tool/`·`recipes/`·`input/` 사본을 지우고 기준 작업에서 다시 복사한다(__pycache__ 제외, workers 2).
4. `inputs.json` 해시를 다시 계산한다.
5. 아래 체크리스트 순서대로 한 장씩 만든다: 레시피 → build → 직접 확인 → 고치기(최대 2번).

## 체크리스트

- [x] 자료 읽기: COMMON, 규칙 문서, 시험 작업 기록·미리보기, region·prop JSON, 02 §5.2·§7.1
- [x] 폴더 만들기와 시험 작업 사본 복사(위 '도구' 참고 — 재개 때 새로 복사)
- [x] 도구 불러오기 확인 (Python 3.13.7, numpy 2.3.3, Pillow 12.3.0, ImageMagick 7.1.2, 아이콘 618개)
- [x] `BRIEF_H0_AREAS.md` 작성 (화면 4개 나누기, B·C·D 배치, 레이어·상태)
- [x] 만들 대상 목록, `inputs.json` 해시 갱신 (04:05, 14번 문서가 03:38에 바뀜)
- [ ] 기준 확정 대기 (톤앤매너 자료)
- [ ] 재개 준비 (위 1~4)
- [ ] 사물·관문·출구 상태 그림 17장 → `sheet_h0_props.png`
- [ ] A: base_clean, foreground_beam, master_composite, preview_reassembled, 게임 화면 미리보기
- [ ] B: 같은 묶음
- [ ] C: 같은 묶음
- [ ] D: 같은 묶음 → `sheet_h0_areas.png`
- [ ] QA.md, __pycache__ 정리
- [ ] 다음: R1 `mp06-bg-r1-v01` (brief·JOB.md 준비 끝)
