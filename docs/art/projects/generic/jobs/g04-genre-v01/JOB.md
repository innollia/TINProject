# g04-genre-v01 — 장르별 물건 (현대·SF·사이버펑크·스팀펑크·포스트아포칼립스·해적·서부·동양)

세션 g04(범용 오브젝트). 전부 candidate이고 승인은 사용자만 한다. 규칙: `docs\art\mass_production\COMMON.md` + `GENERIC.md`. 목록: `docs\art\projects\generic\catalog\g04_list.md`.

## 폴더
- 그림·도구: `assets\art\generic\jobs\g04-genre-v01\` (tool, recipes, output, preview. input은 비어 있음 — 외부 그림을 쓰지 않음)
- 기록: 이 폴더(JOB.md, inputs.json, QA.md)

## 만드는 법
- 레시피(아이콘 조합 JSON)는 `tool\make_recipes.py`가 `tool\g04kit.py`로 만든다. 그림 계산은 V1 도구 그대로(`tool\build.py`, `tool\iconkit\`).
- 다시 만들기(자산 폴더에서): `cd tool` → `python -B make_recipes.py` → `python -B build.py --all` → `python -B lineup.py`.
  시트: `python -B tool\review_sheet.py --scales 1 --cols 6 --out preview\<이름>.png "output\obj_*\*.png"`.
- 필요한 것: Python 3 + Pillow + numpy, ImageMagick 7(SVG 변환). 이 PC에서는 PATH에 없어서 설치된 전체 경로(Python 3.12, ImageMagick 7.1.2)로 불렀다. 새로 설치한 것은 없다.

## 규격 (작성자 설계)
- 시점: 지면 기준 60도 정사영, 방위 고정, 빛은 도구 기본 확산광(왼쪽 위). 장면 조명·비네트·불빛 웅덩이 없음.
- 크기: 폭 180 px/m, 바닥 깊이 156 px/m(×0.866), 높이 105 px/m. 근거: 플레이어 그림 키 약 180 px(원본) = 1.7 m 사람.
  V1 카운터 레시피는 높이를 90 px/m(정확한 60도 투영)로 잡아 사람 옆 사물이 낮아 보였다(COMMON.md 약점). 그래서 높이만
  플레이어와 같은 비율로 올렸다. 예: 문 2.1 m = 220 px(플레이어보다 큼), 책상 0.76 m = 80 px, 가게 계산대 1.05 m = 110 px(허리).
- 캔버스: 물체 + 32 px 안전 여백(+ 빛 번짐·흐림 여유), 짝수 크기. 원본 2배 기준(게임 화면에서는 0.5배).
- 피벗: 바닥 접촉점. 기본은 '앞면 아래 가운데'(물체 앞면이 바닥에 닿는 선의 가운데). 나무는 줄기 밑동, 벽에 붙는 것은 붙는 자리
  (벽판 가운데), 문은 문턱 가운데, 매다는 것은 바로 아래 바닥점. 자산마다 manifest `pivot_meaning`에 적었다.
- 레이어 힌트: manifest `layer_hint` = world(y 정렬) / floor(바닥에 깔림) / wall(벽에 붙음). 상자형 물체는 `footprint`(바닥 사각형, 캔버스 px).
- 그림자: 바닥 그림자는 `_shadow.png`로만 둔다(그림에 합치지 않음). 빛나는 부분은 `_emit.png`.
- 게임용 빛: 켜짐 프레임 manifest `game_light` {color, radius, at}(여러 개면 목록) + `recipes\scene_<묶음>_lineup.json` 항목의 `light`.
- 불꽃 경계(GENERIC.md): 불꽃·연기 효과는 그리지 않는다(g01·g02·g10). 켜짐 그림은 빛나는 연료·숯·심지만, 불꽃 놓을 자리는 manifest `anchors.flame_anchor`.
- 상태 그림: 같은 레시피의 프레임 `output\<자산>\<상태>.png`. 한 자산의 모든 상태는 캔버스·피벗이 같다.
- 글자·로고·특정 게임 문양 없음. 간판·표지판은 빈 판 또는 단순한 그림 기호만.

## 도구에 추가한 것 (V1 `h0-icon-mood-v02\tool` 복사본 기준, 그림 계산 코드는 그대로)
- `iconkit\icons.py`: SVG 변환 병렬 개수 기본 8 → 2(10개 세션 동시 작업).
- `build.py`: manifest에 state, layer_hint, footprint, game_light, anchors를 더 적는다.
- `review_sheet.py`: `--cols`(여러 줄로 감기), 칸 이름에 자산/프레임, `_emit.png`는 칸으로 넣지 않음.
- `compose_preview.py`: `background` 대신 `background_color` + `canvas`로 평평한 바닥 위 배치 확인(오브젝트만, 조명 없음).
- 새 파일: `g04kit.py`(레시피 생성 도우미: 상자·원기둥·다각형·판자·리벳·그림자, 캔버스와 피벗 자동 계산), `make_recipes.py`(이 묶음 자산 정의),
  `lineup.py`(배치 장면 JSON + 확인 그림), `make_palette_g04.py`(팔레트 생성).

## 팔레트
- `recipes\palette_g04.json` = V1 `palette_h0_mood.json` 그대로 + 새 재질(식물·바위·물·눈·금·구리·강철·고무·유리·화면·네온·신호등·천·
  지붕·벽토·벽돌·옻칠 등). V1의 윤곽선·그림자·공통 색·재질·스타일은 바꾸지 않았다. 밝기는 V1 범위(종이색이 가장 밝은 면).

## 체크리스트 (21/21 완료)

| 완료 | 단계 | 자산 ID | 이름 | 장르 | 프레임(상태) | 캔버스 | 피벗 뜻 | 빛 | 출처 |
|---|---|---|---|---|---|---|---|---|---|
| [x] | A | obj_vending_machine | 자판기 | 현대 | off, on | 310×424 | front-bottom centre on the floor; the back face stands on the wall line | 빛 emit |  |
| [x] | A | obj_car | 자동차 | 현대 | obj_car, obj_car_burnt/obj_car_burnt | 880×490 | centre of the car's near-side ground line |  |  |
| [x] | A | obj_sf_console | SF 조종 콘솔 | SF | off, on | 400×374 | front-bottom centre of the base on the floor | 빛 emit |  |
| [x] | A | obj_sf_capsule | 냉동 캡슐 | SF | closed, open | 300×404 | front-bottom centre on the floor; the back face stands on the wall line | 빛 emit |  |
| [x] | A | obj_steam_boiler | 증기 보일러 | 스팀펑크 | off, on | 588×554 | front-bottom centre of the base on the floor | 빛 emit |  |
| [x] | B | obj_traffic_light | 신호등 | 현대 | green, off, red | 172×532 | front-bottom centre of the base on the floor | 빛 emit |  |
| [x] | B | obj_neon_sign | 네온 간판(글자 없음) | 사이버펑크 | off, on | 314×238 | centre of the back plate = attach point on the wall face | 빛 emit |  |
| [x] | B | obj_oil_drum | 드럼통 | 포스트아포칼립스 | dented, normal | 242×290 | front-bottom centre of the base on the floor |  |  |
| [x] | B | obj_barricade | 바리케이드 | 포스트아포칼립스 | obj_barricade | 586×312 | centre of the barricade's ground line |  |  |
| [x] | B | obj_stone_lantern | 석등 | 동양 | off, on | 230×386 | front-bottom centre of the base on the floor | 빛 emit |  |
| [x] | C | obj_phone_booth | 공중전화 부스 | 현대 | off, on | 254×432 | front-bottom centre of the base on the floor | 빛 emit |  |
| [x] | C | obj_trash_can | 쓰레기통 | 현대 | obj_trash_can | 222×284 | front-bottom centre of the base on the floor |  |  |
| [x] | C | obj_hitching_post | 말 매는 말뚝 | 서부 | obj_hitching_post | 502×272 | centre of the rail's ground line |  |  |
| [x] | C | obj_water_tower | 물탱크 | 서부 | obj_water_tower | 490×950 | centre of the front legs' ground line |  |  |
| [x] | C | obj_torii | 도리이(신사 문) | 동양 | obj_torii | 578×484 | centre between the pillars on the ground |  |  |
| [x] | C | obj_anchor_large | 큰 닻 | 해적·바다 | obj_anchor_large | 390×374 | fluke tip contact on the ground |  |  |
| [x] | C | obj_car_burnt | 불탄 차 | 포스트아포칼립스 | obj_car_burnt | 860×478 | centre of the car's near-side ground line |  |  |
| [x] | C | obj_street_terminal | 거리 단말기 | 사이버펑크 | off, on | 228×352 | front-bottom centre of the base on the floor | 빛 emit |  |
| [x] | C | obj_rail_signal | 철도 신호기 | 스팀펑크 | green, red | 268×580 | front-bottom centre of the base on the floor | 빛 emit | BS2 증기기관차 부품(신호기) |
| [x] | C | obj_steam_chimney | 증기 굴뚝 | 스팀펑크 | obj_steam_chimney | 336×842 | front-bottom centre of the base on the floor |  | BS2 증기기관차 부품(굴뚝) |
| [x] | C | obj_cage_lift | 승강기(철창 리프트) | 스팀펑크 | down, up | 360×708 | front-bottom centre of the base on the floor | emit | BS2 승강기 |

