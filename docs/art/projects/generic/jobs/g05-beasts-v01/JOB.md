# g05-beasts-v01 — 동물(짐승·새·파충류·양서류) 전투 그림 (아이콘 조합)

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | 범용 에셋 세션 g05(모든 장르의 생물) 중 동물: 짐승, 새, 파충류, 양서류 |
| 근거 | `docs\art\mass_production\COMMON.md`, `GENERIC.md`, 목록 `docs\art\projects\generic\catalog\g05_list.md` |
| 화풍 기준 | V1 `assets\art\top_down_action_rpg\jobs\h0-icon-mood-v02\` (도구·팔레트 복사, 기준 폴더는 읽기만) |
| 쓰기 범위 | `assets\art\generic\jobs\g05-beasts-v01\`, 이 기록 폴더, 목록 파일 |
| 아이콘 원본 | `addons\at-icons\node2d` (MIT) |

## 형식 · 도구

형식(정면 전투 그림, A 3장 idle/attack/hit·B·C 1장, 캔버스 높이 384 기준, 바닥점 피벗, `_shadow`·`_emit` 분리)과 도구 변경은 `docs\art\projects\generic\jobs\g05-fantasy-v01\JOB.md`와 같다. 이 묶음의 생물 정의는 `tool\g05kit\beasts.py`.

작성자 설계(이 묶음):
- 네 발 짐승(늑대·멧돼지·쥐·개·말)과 서 있는 새(까마귀)는 왼쪽 아래를 보는 3/4 정면으로 그렸다. 똑바른 정면은 네 발 짐승이 작은 덩어리로 보인다(COMMON.md 시험 개 약점). 곰은 뒷발로 선 정면, 고양이·개구리는 앉은 정면.
- 작은 동물(쥐·박쥐·뱀·까마귀·개·고양이)은 전투에서 읽히도록 실제보다 크게 그렸다.

## 재실행

`tool` 폴더에서 `py -3 -B make_palette.py`, `py -3 -B make_recipes.py beasts`, `py -3 -B build.py --all`, `py -3 -B check_edges.py`.

## 진행 (체크리스트)

A (7, 기본·공격·피격): - [x] wolf 늑대  - [x] bear 곰  - [x] boar 멧돼지  - [x] bat 박쥐  - [x] rat 쥐  - [x] snake 뱀  - [x] crow 까마귀

B (5, 기본 1장): - [x] dog 개  - [x] cat 고양이  - [x] horse 말  - [x] giant_frog 거대 개구리  - [x] vulture 대머리수리

C (22, 기본 1장): - [x] bat_swarm 박쥐 떼  - [x] frog 개구리  - [x] crocodile 악어  - [x] coyote 코요테  - [x] small_bird 작은 새(비둘기)  - [x] pig 돼지  - [x] goat 염소  - [x] deer 사슴  - [x] chicken 닭  - [x] duck 오리  - [x] squirrel 다람쥐  - [x] raccoon 너구리  - [x] monkey 원숭이  - [x] elephant 코끼리  - [x] lizard 도마뱀  - [x] turtle 거북  - [x] penguin 펭귄  - [x] walrus 바다코끼리  - [x] flamingo 플라밍고  - [x] bison 들소  - [x] parrot 앵무새  - [x] rattlesnake 방울뱀

검수 시트: `preview\review_A_beasts.png`, `preview\review_B_beasts.png`, `preview\review_C_beasts_1.png`, `preview\review_C_beasts_2.png`
