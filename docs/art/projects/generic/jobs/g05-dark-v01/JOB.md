# g05-dark-v01 — 다크 판타지·고딕 생물 전투 그림 (아이콘 조합)

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | 범용 에셋 세션 g05(모든 장르의 생물) 중 다크 판타지·고딕 생물: 언데드, 악마, 저주받은 갑옷, 흉내 괴물 |
| 근거 | `docs\art\mass_production\COMMON.md`, `GENERIC.md`, 목록 `docs\art\projects\generic\catalog\g05_list.md`, BS2 종류 목록 `g01_bs2_inventory.md`(이름만) |
| 화풍 기준 | V1 `assets\art\top_down_action_rpg\jobs\h0-icon-mood-v02\` (도구·팔레트 복사, 기준 폴더는 읽기만) |
| 쓰기 범위 | `assets\art\generic\jobs\g05-dark-v01\`, 이 기록 폴더, 목록 파일 |
| 아이콘 원본 | `addons\at-icons\node2d` (MIT) |

## 형식 · 도구

형식(정면 전투 그림, A 3장 idle/attack/hit·B·C 1장, 캔버스 높이 384 기준, 바닥점 피벗, `_shadow`·`_emit` 분리)과 도구 변경은 `docs\art\projects\generic\jobs\g05-fantasy-v01\JOB.md`와 같다. 이 폴더의 `tool\`은 V1 도구를 새로 복사하고 같은 g05 추가 파일(`icons.py` 병렬 2, `review_sheet.py` 격자, `make_palette.py`, `make_recipes.py`, `check_edges.py`, `g05kit\kit.py`·`body.py`·`parts.py`)을 넣은 것이다. 이 묶음의 생물 정의는 `tool\g05kit\dark.py`.

작성자 설계(이 묶음):
- 시체·신체 훼손은 그리지 않는다(BS2 목록 규칙). 좀비·구울은 찢긴 옷과 썩은 피부색까지만, 머리 없는 기사는 머리 대신 투구를 들고 목에서 유령 불꽃이 오른다.
- 유령은 몸 부분을 불투명도 0.84로 그려 뒤가 살짝 비친다.

## 재실행

`tool` 폴더에서 `py -3 -B make_palette.py`, `py -3 -B make_recipes.py dark`, `py -3 -B build.py --all`, `py -3 -B check_edges.py`.

## 진행 (체크리스트)

A (10, 기본·공격·피격):
- [x] skeleton 해골 병사  - [x] zombie 좀비  - [x] ghost 유령  - [x] vampire 흡혈귀  - [x] werewolf 늑대인간
- [x] gargoyle 가고일  - [x] living_armor 살아 있는 갑옷  - [x] demon 악마  - [x] ghoul 구울  - [x] headless_knight 머리 없는 기사

B (7, 기본 1장): robed_skeleton, bone_dog, wraith, pumpkin_ghost, giant_knight, imp, mimic_door — 대기

C (8, 기본 1장): hungry_ghost, soul_wall, bone_beast, skull_mimic, pumpkin_bat, snake_ghost, owl, hellhound — 대기

검수 시트: `preview\review_A_dark_1.png`(사람 크기 8종), `preview\review_A_dark_2.png`(큼 2종)
