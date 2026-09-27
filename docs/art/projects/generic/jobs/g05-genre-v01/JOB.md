# g05-genre-v01 — 판타지 밖 장르 괴물 전투 그림 (아이콘 조합)

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | 범용 에셋 세션 g05(모든 장르의 생물) 중 판타지 밖 장르(호러·오컬트, SF·우주, 사이버펑크, 스팀펑크, 포스트아포칼립스, 해적·바다, 서부)의 괴물 |
| 근거 | `docs\art\mass_production\COMMON.md`, `GENERIC.md`, 목록 `docs\art\projects\generic\catalog\g05_list.md` |
| 화풍 기준 | V1 `assets\art\top_down_action_rpg\jobs\h0-icon-mood-v02\` (도구·팔레트 복사, 기준 폴더는 읽기만) |
| 쓰기 범위 | `assets\art\generic\jobs\g05-genre-v01\`, 이 기록 폴더, 목록 파일 |
| 아이콘 원본 | `addons\at-icons\node2d` (MIT) |

## 형식 · 도구

형식(정면 전투 그림, A 3장 idle/attack/hit·B·C 1장, 캔버스 높이 384 기준, 바닥점 피벗, `_shadow`·`_emit` 분리)과 도구 변경은 `docs\art\projects\generic\jobs\g05-fantasy-v01\JOB.md`와 같다. 이 묶음의 생물 정의는 `tool\g05kit\genre.py`.

작성자 설계(이 묶음):
- 특정 작품의 로봇·외계인 디자인을 따르지 않고 흔한 유형(상자형 경비 로봇, 회색 외계인)으로 만들었다.
- 로봇 공격은 팔 끝 총구를 정면으로 겨눈 모습(원형 총구)과 붉은 눈빛으로만 보여 준다(총구 불꽃 없음).
- 광대 괴물은 사람 광대(g02)와 겹치지 않게 긴 팔다리, 귀까지 찢어진 이빨 웃음, 붉은 눈으로 괴물임을 분명히 했다.
- 돌연변이는 신체 훼손 대신 부풀어 오른 혹, 세 번째 눈, 병든 초록 눈빛으로만 표현했다.

## 재실행

`tool` 폴더에서 `py -3 -B make_palette.py`, `py -3 -B make_recipes.py genre`, `py -3 -B build.py --all`, `py -3 -B check_edges.py`.

## 진행 (체크리스트)

A (4, 기본·공격·피격): - [x] robot 경비 로봇  - [x] alien 외계인  - [x] tentacle_horror 촉수 괴물  - [x] eyeball 눈알 괴물

B (12, 기본 1장): - [x] winged_horror 날개 달린 괴물  - [x] clown_monster 광대 괴물  - [x] jack_in_the_box 깜짝 상자  - [x] dark_matter 암흑 물질 덩어리  - [x] android 안드로이드  - [x] combat_drone 전투 드론  - [x] guard_doll 태엽 경비 인형  - [x] steam_golem 증기 골렘  - [x] mutant_rat 돌연변이 쥐  - [x] mutant_roach 돌연변이 바퀴벌레  - [x] cactus_monster 선인장 괴물  - [x] skeleton_pirate 해골 해적

C (8, 기본 1장): cursed_doll, shadow_stalker, xeno_bug, cyber_dog, mech_walker, clockwork_spider, clockwork_bird, two_headed_dog — 대기

검수 시트: `preview\review_A_genre.png`, `preview\review_B_genre.png`
