# h0-pixel-trial-v01 — H0 도트 시험 그림

상태: **candidate** (이 job의 결과는 전부 후보다. 승인·기준 승격은 사용자만 한다.)
만든 날: 2026-09-26. 방법: Python 3.13.7 + Pillow 12.3.0 코드 도트. AI 그림 도구·외부 그림 API 사용 없음.
비교 대상: 같은 대상을 아이콘 조합으로 만드는 `h0-icon-collage-v01` (그 폴더는 팔레트 파일 읽기만 했다).
prompt.txt는 없다. 코드 그림 job이므로 그림을 만든 스크립트를 결과 옆 `tool/`에 둔다 (14_ISOLATED_ART_JOBS.md §1).

| 필드 | 값 |
|---|---|
| 목적 | generator_calibration — 코드 도트 방식이 04 키트 화풍으로 쓸 만한지 보는 시험. production 승인 후보가 아니다 |
| 소유권 | 작업자 kirocrew-worker. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/h0-pixel-trial-v01/`, `docs/art/projects/top_down_action_rpg/jobs/h0-pixel-trial-v01/`. 정본·게임 코드·씬 수정 불가, 게임 연결 없음 |
| 자산 identity | 실제 domain ID: `region_h0_undersign_exchange`, `prop_h0_ration_counter`(ps_open), `prop_h0_counterweight_map`(ps_matched), `gate_g0_arrival_declaration`, `item_blank_return_form`, `enemy_ash_hound`. 플레이어는 domain ID 없는 필드 actor. 파일 이름은 이 job의 새 미술 ID |
| 입력 계약 버전 | inputs.json의 파일별 SHA-256 |
| 카메라 | 지면 기준 60° 정사영, 고정 방위(화면 위 = 먼 쪽). 바닥 깊이 ×0.866, 높이 ×0.5. 빛은 왼쪽 위 |
| 입력 이미지 | 없음. 참조 이미지 없이 코드로만 그림. Gold Standard 0개 |
| 필요한 결과 | 아래 표. 모두 PNG, 도트 1칸 = 원본 4px = 1280x720 화면 2px. 원본은 x1을 정수배 nearest 확대만 함 |
| 내용 고정 | 배치는 모듈 좌표 그대로(아래 '배치'). 사물 상태는 초기 상태만 |
| 금지 | 글자 굽기 없음(명판·공고문은 글자 없는 줄), 팔레트 밖 색 없음(검사 결과 QA.md), 다른 job 파일 덮어쓰기 없음 |
| 수정 범위 | 이 job 폴더 안 새 파일만 |
| 승인 상태 | 원본 입력: 없음 / approved 기준: 없음 / candidate: 아래 전부 / rejected: 없음 |
| 검수 항목 | QA.md |
| 중단 이유 | 없음 |

## 결과 (`assets/art/top_down_action_rpg/jobs/h0-pixel-trial-v01/`)

| 파일 (output/, x1은 output/x1/ 같은 이름) | 원본 크기 | x1 크기 | 알파 | 피벗(원본 px) |
|---|---|---|---|---|
| player/player_stand_down / _up / _left / _right.png | 192x192 | 48x48 | 투명 | (96,184) 발 가운데 |
| player/player_walk_down_0..3.png (왼발 앞·지나감·오른발 앞·지나감) | 192x192 | 48x48 | 투명 | (96,184) |
| player/player_shadow.png | 192x192 | 48x48 | 반투명 | (96,184) |
| enemy/enemy_ash_hound_stand_left.png (+ _shadow) | 256x192 | 64x48 | 투명 | (128,184) |
| prop/prop_h0_ration_counter_open.png (+ _shadow) | 384x320 | 96x80 | 투명 | (192,312) |
| prop/prop_h0_counterweight_map_matched.png | 320x208 | 80x52 | 투명 | (160,104) 판 가운데 |
| prop/gate_g0_arrival_declaration_closed.png (+ _shadow) | 352x352 | 88x88 | 투명 | (176,340) |
| item/item_blank_return_form.png (소지품 아이콘) | 96x96 | 24x24 | 투명 | 가운데 |
| background/bg_h0_undersign_exchange_arrival.png | 2560x1440 | 640x360 | 불투명 | 왼쪽 위 |
| preview/h0_screen_preview_1280x720.png (검수용 합성) | 1280x720 | — | 불투명 | — |

그림자는 스프라이트에 굽지 않고 같은 캔버스·피벗의 `_shadow` 파일로 따로 둔다(팔레트 style `shadow_output: separate`).

## 배치 (모듈 코드 기준)

- 화면 가운데 `WORLD_ORIGIN (640,418)`: 플레이어 자리(vector layer가 플레이어를 늘 여기 그림), 고리 선반 중심.
- topology `ring_shelf_well` 해시값: 고리 2개(반지름 67.5/103.5px), 선반 막대 5줄, 우물 (690,394) r24, 가운데 원 r30.
- 필드 사물·출구 자리(`field_controller._anchor_position` + `_world_mapping`): 위 줄 y251 — 추 지도 x140, 배급 카운터 x473, NPC Ilyra Senn x807, 출구 e01 x1140 / 아래 줄 y585 — 출구 e02 x140, e03 x473, e04 x807, e05 x1140.
- 도착 신고 게이트는 H0 entry edge(`route_e01_ash_stair`, gate_g0) 자리 x1140,y251에 한 번 놓았다. 뒤에 R1로 내려가는 재 계단.

## 모듈 코드와 대상 목록의 차이 (모듈 쪽을 따름)

1. 도착 신고 게이트: 모듈에 사물 파일이 없다. `gate_g0_arrival_declaration`은 H0 출구 5개 전부의 gate_id다. 게이트 그림은 entry 출구 e01에만 두고, 나머지 출구 4개는 배경의 계단 입구로만 그렸다.
2. 빈 반환 서식: 모듈에서 필드 사물이 아니라 소지품(`item_blank_return_form`, quest, icon_key)이다. 필드에 놓지 않고 아이콘으로 만들었다.
3. Ash Hound: 모듈에서 소속 지역이 R1(`region_r1_returning_kiln`)이고 H0는 전투 조우가 없다(`encounter_ids: []`). 미리보기에서 H0 바닥에 놓지 않고 오른쪽 아래 작은 칸에 서식 아이콘과 함께 따로 두었다.
4. 모듈의 H0 필드에는 NPC `npc_01_ilyra_senn` 자리(x807,y251)가 있으나 대상 목록에 없어 비워 두었다.
5. 모듈의 월드→화면 변환은 위에서 본 1:1 매핑이라 60°용 세로 압축이 없다. 사물 자리는 모듈 좌표를 그대로 쓰고, 바닥 무늬(고리·막대·우물)만 가운데 기준 세로 ×0.866으로 눌렀다.
6. 플레이어 초기 방향은 모듈에서 0(위)이지만, 미리보기는 비교를 위해 아래 보기 서 있기 프레임을 썼다.

## 작성자 설계 (사용자·모듈에서 온 값이 아님)

캐릭터 외형(흐린 종이색 목도리, 회보라 긴 코트, 가죽 가방), Ash Hound 외형(재 털, 불씨 균열·눈, 청동 목줄·표찰), 카운터·게이트·지도의 구조, 배경의 위층 기록 선반·옹벽·반환 창구 승강기·계단 입구, 1도트 = 화면 2px 밀도.

## 다시 만들기

`tool/`에서 차례로: `python draw_player.py all`, `python draw_hound.py`, `python draw_props.py`, `python draw_background.py`, `python compose_preview.py`. 난수는 고정 시드라 같은 결과가 나온다. 팔레트는 `tool/palette_h0_snapshot.json`(아이콘 job 팔레트의 사본)만 읽는다.
