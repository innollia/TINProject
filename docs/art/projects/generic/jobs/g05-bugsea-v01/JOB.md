# g05-bugsea-v01 — 벌레·바다 생물 전투 그림 (아이콘 조합)

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | 범용 에셋 세션 g05(모든 장르의 생물) 중 벌레(거미류·곤충·지네)와 바다 생물 |
| 근거 | `docs\art\mass_production\COMMON.md`, `GENERIC.md`, 목록 `docs\art\projects\generic\catalog\g05_list.md` |
| 화풍 기준 | V1 `assets\art\top_down_action_rpg\jobs\h0-icon-mood-v02\` (도구·팔레트 복사, 기준 폴더는 읽기만) |
| 쓰기 범위 | `assets\art\generic\jobs\g05-bugsea-v01\`, 이 기록 폴더, 목록 파일 |
| 아이콘 원본 | `addons\at-icons\node2d` (MIT) |

## 형식 · 도구

형식(정면 전투 그림, A 3장 idle/attack/hit·B·C 1장, 캔버스 높이 384 기준, 바닥점 피벗, `_shadow`·`_emit` 분리)과 도구 변경은 `docs\art\projects\generic\jobs\g05-fantasy-v01\JOB.md`와 같다. 이 묶음의 생물 정의는 `tool\g05kit\bugsea.py`.

작성자 설계(이 묶음):
- 거미·전갈·게의 다리는 몸에서 높은 무릎을 지나 바닥으로 내려오는 활 모양으로 그렸다. 끝이 넘치지 않도록 `kit.tube`에 `cap` 옵션을 더했다(기본값은 예전과 같아서 다른 묶음 결과는 그대로).
- 대왕 상어는 왼쪽 아래로 달려드는 3/4 정면, 나머지는 정면.

## 재실행

`tool` 폴더에서 `py -3 -B make_palette.py`, `py -3 -B make_recipes.py bugsea`, `py -3 -B build.py --all`, `py -3 -B check_edges.py`.

## 진행 (체크리스트)

A (3, 기본·공격·피격): - [x] spider 거대 거미  - [x] scorpion 거대 전갈  - [x] centipede 거대 지네

B (5, 기본 1장): - [x] caterpillar 거대 애벌레  - [x] kraken 크라켄(거대 문어)  - [x] giant_shark 대왕 상어  - [x] crab 거대 게  - [x] jellyfish 해파리

C (9, 기본 1장): - [x] giant_wasp 거대 말벌  - [x] grasshopper 거대 메뚜기  - [x] flea 거대 벼룩  - [x] slug 거대 민달팽이  - [x] bug_swarm 벌레 떼  - [x] whale 고래  - [x] shrimp 거대 새우  - [x] oyster 진주 굴 괴물  - [x] piranha 이빨 물고기

검수 시트: `preview\review_A_bugs.png`, `preview\review_B_bugsea.png`, `preview\review_C_bugsea.png`
