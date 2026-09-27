# g05-fantasy-v01 — 중세 판타지 생물 전투 그림 (아이콘 조합)

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | 범용 에셋 세션 g05(모든 장르의 생물) 중 중세 판타지 괴물·용 무리·정령·식물 괴물·요정의 정면 전투 그림 |
| 근거 | `docs\art\mass_production\COMMON.md`, `GENERIC.md`, 목록 `docs\art\projects\generic\catalog\g05_list.md` |
| 화풍 기준 | V1 `assets\art\top_down_action_rpg\jobs\h0-icon-mood-v02\` (도구·팔레트 복사, 기준 폴더는 읽기만) |
| 쓰기 범위 | `assets\art\generic\jobs\g05-fantasy-v01\`, 이 기록 폴더, 목록 파일 |
| 아이콘 원본 | `addons\at-icons\node2d` (MIT). 아이콘을 잘라 겹쳐 쓰고 원래 모양이 그대로 보이지 않게 했다 |

## 형식 (작성자 설계, 규칙 안에서 정한 값)

- 정면 전투 그림(RPG Maker 정면 battler 방식), 방향 없음. A 항목 3장 `idle`(기본)·`attack`(공격)·`hit`(피격), B·C 항목은 `idle` 1장.
- 파일: `output\<id>\<frame>.png` + 바닥 그림자 `<frame>_shadow.png` + 빛나는 부분(눈·불꽃) `<frame>_emit.png` + `<frame>.json`(빌드 기록, status candidate).
- 캔버스: 사람 크기 = 높이 384(320×384, 384×384). 큼 512×512, 날개가 넓은 것 640×512, 거대 768×640. 선 두께·붓자국·빛 방향은 모든 크기에서 같다(V1 `sprite` 스타일 그대로, 덮어쓰기 없음).
- 피벗: 몸 가운데 아래 바닥점(레시피 `pivot`). 작은 생물도 같은 바닥선에 서고, 날짐승은 그 위에 떠 있다.
- 공격 효과·피격 섬광은 그리지 않는다(g01·g02 담당). 공격은 무기를 치켜들거나 입을 벌린 자세, 피격은 뒤로 밀리며 눈을 질끈 감은 자세로 보여 준다.
- 맵 8방향 스프라이트는 이번 세션 지시로 만들지 않았다.

## 도구 (V1 복사본에서 바꾼 것)

- `tool\iconkit\icons.py`: 아이콘 변환 병렬 개수 기본값 8 → 2 (10개 세션이 한 컴퓨터를 같이 씀).
- `tool\review_sheet.py`: `--cols N`(격자 배치), `--label parent`(`<폴더>/<파일>` 라벨), `_emit.png`는 칸으로 넣지 않음.
- 새 파일:
  - `tool\make_palette.py` → `recipes\palette_g05.json`: V1 `palette_h0_mood.json`을 그대로 복사하고 생물 재질(피부·털·비늘·키틴·뼈·유령·식물·원소·금속·빛나는 눈)만 더한다. 윤곽선·그림자·공통 색과 스타일은 바꾸지 않았다.
  - `tool\g05kit\`: 생물을 파이썬으로 짧게 쓰는 도우미(`kit.py` 조각·대칭·꼬리·이빨·날개막·얼굴, `body.py` 두 발 몸 뼈대, `parts.py` 날개·가시, `fantasy.py` 이 묶음의 생물 정의).
  - `tool\make_recipes.py`: `g05kit\fantasy.py` → `recipes\<id>.json`. 레시피 JSON이 그림의 정확한 원본이고, build.py는 V1 그대로 이 JSON을 그린다.
  - `tool\check_edges.py`: 그림이 캔버스 가장자리에서 잘렸는지 검사(모든 결과 통과).
- 렌더러(`render.py`, `raster.py`, `paint.py`)와 `build.py`는 V1 그대로다.

## 재실행

`tool` 폴더에서:

```
py -3 -B make_palette.py
py -3 -B make_recipes.py fantasy
py -3 -B build.py --all
py -3 -B check_edges.py
```

## 진행 (체크리스트)

A (15, 기본·공격·피격):
- [x] slime 슬라임  - [x] goblin 고블린  - [x] orc 오크  - [x] troll 트롤  - [x] mimic_chest 미믹(보물상자)
- [x] golem 돌 골렘  - [x] harpy 하피  - [x] minotaur 미노타우로스  - [x] lizardman 리자드맨  - [x] dragon 드래곤
- [x] wyvern 와이번  - [x] griffon 그리폰  - [x] treant 나무 괴물  - [x] mushroom 버섯 괴물  - [x] fire_spirit 불 정령

B (10, 기본 1장): hydra, yeti, giant, fairy, beastman, snake_man, man_eater_plant, water_spirit, wind_spirit, earth_spirit — 대기

C (9, 기본 1장): cyclops, kobold, cockatrice, unicorn, giant_snake, light_spirit, ice_spirit, mandrake, vine_monster — 대기

검수 시트: `preview\review_A_fantasy_1.png`(작음·사람 크기 8종), `preview\review_A_fantasy_2.png`(큼·거대 7종)
