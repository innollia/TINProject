# g05-east-v01 — 동양 판타지 요괴 전투 그림 (아이콘 조합)

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | 범용 에셋 세션 g05(모든 장르의 생물) 중 동양 판타지(한중일 전통) 요괴·귀신 |
| 근거 | `docs\art\mass_production\COMMON.md`, `GENERIC.md`, 목록 `docs\art\projects\generic\catalog\g05_list.md` |
| 화풍 기준 | V1 `assets\art\top_down_action_rpg\jobs\h0-icon-mood-v02\` (도구·팔레트 복사, 기준 폴더는 읽기만) |
| 쓰기 범위 | `assets\art\generic\jobs\g05-east-v01\`, 이 기록 폴더, 목록 파일 |
| 아이콘 원본 | `addons\at-icons\node2d` (MIT) |

## 형식 · 도구

형식(정면 전투 그림, A 3장 idle/attack/hit·B·C 1장, 캔버스 높이 384 기준, 바닥점 피벗, `_shadow`·`_emit` 분리)과 도구 변경은 `docs\art\projects\generic\jobs\g05-fantasy-v01\JOB.md`와 같다. 이 묶음의 생물 정의는 `tool\g05kit\east.py`.

작성자 설계(이 묶음):
- 강시 이마의 부적은 글자 없이 빈 종이에 붉은 도장 자리만 둔다(그림 안 글자 금지).
- 구미호의 여우불은 발광 레이어(`_emit.png`)에 들어간다.

## 재실행

`tool` 폴더에서 `py -3 -B make_palette.py`, `py -3 -B make_recipes.py east`, `py -3 -B build.py --all`, `py -3 -B check_edges.py`.

## 진행 (체크리스트)

A (3, 기본·공격·피격): - [x] gumiho 구미호  - [x] dokkaebi 도깨비  - [x] jiangshi 강시

B (4, 기본 1장): - [x] tengu 텐구  - [x] kappa 갓파  - [x] oni 오니  - [x] haetae 해태

C (5, 기본 1장): imugi, lantern_ghost, umbrella_ghost, bulgasari, virgin_ghost — 대기

검수 시트: `preview\review_A_east.png`, `preview\review_B_east.png`