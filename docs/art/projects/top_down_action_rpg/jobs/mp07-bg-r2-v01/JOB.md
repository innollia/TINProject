# mp07-bg-r2-v01 — R2 Siltglass Commons 배경과 오브젝트

상태: **candidate (완료, 사용자 검토 대기)**. 2026-09-27 04:35 KST 시작, 06:20 KST 끝. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | clean_base + occluder + prop(오브젝트) + state_variant (R2 지역 한 묶음) |
| 소유권 | 세션 07. 쓰기: `assets/art/top_down_action_rpg/jobs/mp07-bg-r2-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp07-bg-r2-v01/`. 게임 코드·씬·content·규칙 문서 수정 없음, git 커밋·푸시 없음 |
| 자산 identity | 지역 `region_r2_siltglass_commons` / art key `art_world_r2_siltglass_commons`. content 사물 5개는 content ID와 art_key 그대로. 구역 ID, 출구·내부 길·지역 오브젝트 이름은 작성자 설계 |
| 입력 계약 버전 | `inputs.json` |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 가로 180 px/m, 깊이 ×0.866, 높이는 플레이어 키 기준 1 m ≈ 110 px |
| 화풍 | V1 (`h0-icon-mood-v02`). 빛은 기본 확산광만, 장면 조명 없음 |
| 입력 이미지 | 픽셀 입력 없음. 모양 재료 `addons/at-icons/node2d` SVG |
| 결과 | 아래 "결과 파일" |
| 금지 | BRIEF §10 |
| 승인 상태 | Gold Standard 0개. 이 job 결과 = candidate |
| 검수 | `QA.md` |

## 체크리스트

- [x] 준비: 자료 읽기, 만들 대상 목록, BRIEF, JOB 계획 (04:02 KST)
- [x] 새 기준 반영: COMMON 다시 읽기, V1 기록·그림 확인, BRIEF를 배경·오브젝트 분리 기준으로 다시 씀
- [x] 도구 바꾸기(아래 "도구 변경"), `recipes/palette_r2.json`
- [x] 구역 A: base_clean, foreground_mooring_piles, 수위 표시 3, 출구 E02·E08 4, 등불 기둥·초소·물통, 장면 JSON, 확인 그림
- [x] 구역 B: base_clean, foreground_deck_rail, 분사기 2, 굴뚝 2, 출구 E17 2, 그물 건조대, 장면 JSON, 확인 그림
- [x] 구역 C: base_clean, foreground_root_tangle, 뿌리다리 3, 선반 2, 출구 E09 2, 회랑 입구 2, 장면 JSON, 확인 그림
- [x] 모아 보기 시트 4장, 자동 점검(크기·알파·여백), QA.md
- [x] `__pycache__` 지우기
- [ ] 다음: R3 (`mp07-bg-r3-v01`)

## 결과 파일 (`assets/art/top_down_action_rpg/jobs/mp07-bg-r2-v01/`)

| 묶음 | 파일 (`output/<이름>/`) |
|---|---|
| 배경 | `r2_a_sluice_landing/`, `r2_b_stilt_settlements/`, `r2_c_root_bridge_seed_vault/` 에 각각 `base_clean.png`(2560×1440 불투명)과 `foreground_*.png`(투명, 같은 원점) + `_shadow.png` |
| content 사물 | `prop_r2_waterline_mark/` (low, raised, spent), `prop_r2_disperser_housing/` (full, empty), `prop_r2_circulator_stack/` (idle, vented), `prop_r2_root_bridge_anchor/` (bridge_locked, bridge_raised, bridge_surveyed), `prop_r2_seed_vault_shelf/` (shelf_counted, shelf_reissued) |
| 출구·내부 길 | `exit_r2_e02_sluice_road/`, `exit_r2_e08_medicine_ferry/`, `exit_r2_e17_water_ambulance_bridge/`, `exit_r2_e09_orchard_causeway/`, `route_r2_flood_refuge_gallery/` 에 `_closed`, `_open` |
| 지역 오브젝트 | `obj_r2_lantern_post/` (기본 + `_left` 좌우 반전, `_emit.png`), `obj_r2_toll_booth/`, `obj_r2_water_cask/`, `obj_r2_net_rack/` |
| 장면 | `recipes/scene_r2_a_sluice_landing.json`, `scene_r2_b_stilt_settlements.json`, `scene_r2_c_root_bridge_seed_vault.json` (오브젝트 자리, 등불의 게임용 `light`, 비워 둘 공용 사물 자리) |
| 검수 그림 | `preview/check_r2_*_1280x720.png` 3장, `preview/sheet_r2_props_states_0.5x.png`, `sheet_r2_bridge_states_0.5x.png`, `sheet_r2_exits_0.5x.png`, `sheet_r2_region_objects.png` |

모든 PNG 옆 `.json`에 크기·피벗·사용 아이콘 SHA-256·레시피 해시가 있다. 다시 만들기: `tool` 폴더에서 `py -3 -B build.py --all`, 그다음 `py -3 -B compose_preview.py ..\recipes\scene_<구역>.json`.

## 도구 변경 (이 job 복사본만)

- `tool/`은 `h0-icon-mood-v02/tool`(`__pycache__` 제외) 복사본. 준비 때 복사한 옛 도구는 이 복사로 덮어씀.
- `tool/iconkit/icons.py`: `prefetch()` `workers` 8 → 2 (세션 10개가 CPU를 나눠 씀).
- `tool/iconkit/render.py`: `load_palette()` 추가. 팔레트에 `"extends": "<기본 팔레트>"`를 쓰면 기본 팔레트를 먼저 읽고 그 위에 덮어씀. `palette_r2.json`이 V1 값을 복사하지 않고 지역 재질만 더하게 하려고.
- `tool/build.py`: 빌드 키에 `extends`로 이어진 팔레트 내용까지 넣음(기본 팔레트가 바뀌어도 다시 빌드되게).
- 새 스타일 `environment_layer`(`palette_r2.json`): `environment`와 같고 바탕색 없음, 그림자 따로. foreground 그림용.

## 팔레트 (`recipes/palette_r2.json`, V1에서 바꾼 점)

V1(`palette_h0_mood.json`)의 윤곽선·그림자·공통 색·재질은 그대로 물려받고 새 재질만 더했다: 회녹색 널판(`plank`, `plank_dark`), 황회색 개흙(`silt`), 어두운 청록 물(`water`, `water_deep`, `sheen`, `silt_cloud`), 젖은 말뚝(`stilt`), 갈대벽(`reed`), 초가(`thatch`), 실트유리 벽돌(`siltglass`), 녹청 구리(`verdigris`, `verdigris_bloom`), 산 뿌리(`root`), 끈·그물(`cord`, `net`), 수위 칠(`paint`, `paint_fresh`), 흰 가루(`powder`), 분필(`chalk`), 물때(`silt_mark`), 틈(`deck_joint`). 걷는 면의 밝기는 V1 바닥과 비슷하게(밝기 중앙값 80대) 맞췄다.

## 피벗 (벽에 붙는 오브젝트)

- `prop_r2_disperser_housing`: 물 위원회 건물 앞 벽과 데크가 만나는 점. 장면 B `at` (1280,480).
- `prop_r2_circulator_stack`: 동쪽 오두막 앞 벽과 데크가 만나는 점. 장면 B `at` (2080,440).
- `prop_r2_waterline_mark`: 세 번째 말뚝이 수면에 닿는 점. 장면 A `at` (1640,660).

## 작성자 설계와 만들면서 바꾼 값

- 3구역 나누기, 모든 좌표, 재질과 색, 오브젝트 모양, 출구·내부 길·지역 오브젝트 이름 (BRIEF). 최종 위치는 장면 JSON이 정본이다.
- 높이 기준 1 m ≈ 110 px (플레이어 몸 186 px = 1.7 m).
- 안전 여백: BRIEF의 64 px 목표 대신 COMMON의 32 px 이상을 지킴(재 보니 29~62 px라 분사기 함 캔버스를 넓혀 49 px로 맞춤). 화면 밖으로 이어지는 구조(E09 둑돌, E17 부교, 뿌리 뭉치)는 일부러 캔버스 끝에 닿는다.
- 구역 A: 계류 말뚝 foreground를 잔교 남쪽 물 위(논리 x 75..350, y 388..505)로 옮김(잔교 위를 걷는 캐릭터를 가리도록). 초소를 1.2×1.0×2.1 m로 줄임.
- 구역 B: C로 가는 널판 길을 논리 x 400..540으로(이음도 같이). 순환 굴뚝을 (1040,220)으로 옮기고 높이를 2.9 m로 낮춤(바람 갓이 화면 안에 보이게). E17 들다리를 동쪽 끝 대신 동쪽 마을 데크의 남쪽 끝 (1180,470)에 두고 다리가 남쪽으로 이어지게 함(세운 다리판이 정면으로 보이게).
- 구역 C: 둑과 수로를 북쪽 둑 y 100..280, 수로 295..470, 남쪽 둑 480..620(논리)으로 정리. 회랑은 높이 1.2 m, 양 끝 계단. 저장고는 북쪽 둑 동쪽(x 940..1240, 앞 벽 밑선 y 220). 선반 (1075,220), 뿌리다리 닻 기둥은 다리를 막지 않게 다리 동쪽 (395,495), 둑돌 문 (320,100), 회랑 입구 (425,154).
- `prop_r2_waterline_spent`는 content에서 `visible:false`라 선택 그림.
- 장면 C는 처음에 숨는 선반도 자리 확인용으로 넣고 `initially_hidden`을 표시함.
