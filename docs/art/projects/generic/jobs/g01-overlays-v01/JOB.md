# g01-overlays-v01 — 날씨·안개·빛 겹침 무늬, 어둠 가림막

상태: **candidate.** 승인·반려는 사용자만 한다. 게임 코드·씬에는 연결하지 않았다.

## 근거

- 규칙: `docs/art/mass_production/GENERIC.md`(g01 담당: BS2 목록 보강 + 판타지 계열·장르 없는 아이콘·UI·효과·겹침 무늬), `COMMON.md`(그리는 규칙, 크기 통일, V1 기준 도구·팔레트).
- 목록: `docs/art/projects/generic/catalog/g01_list.md`(A → B → C).
- BS2: 이 컴퓨터에 BLACK SOULS II가 없어 보강은 건너뛰었다. `g01_bs2_inventory.md`의 g01 몫(아이콘 세트, 창틀·게이지 바탕·커서·감정 말풍선·전투 시작 전환, 칼·화살·소환·불꽃놀이·선 긋기·특수기·마법진, 안개·잡음·낙엽·거품·햇살·빛 원·시야 밖 어둠)은 전부 목록에 넣었다.
- 그림은 at-icons 모양을 잘라 겹친 조합으로만 만들었다. 글자·숫자·워터마크·원작 고유 요소 없음.

## 규격

| 항목 | 값 |
|---|---|
| 이음 무늬 | 768×768, 네 변이 이어진다(가장자리에 걸친 조각을 반대편에 한 번 더 놓음). manifest `meta.tileable = true` |
| 빛 원 | 192·384·768 정사각, 색마다 프레임. 가산(또는 스크린) 합성용 |
| 가림막·전환 | 2560×1440(배경 크기와 같음) |
| 화풍 | V1 팔레트 색, 스타일 `overlay`(슈퍼샘플 1, 선·테두리 없음). 반복 무늬에는 이어지지 않는 잡음(얼룩·붓자국)을 쓰지 않음 |
| 색 | `recipes/palette_g01.json` = V1 `palette_h0_mood.json`의 모든 항목 그대로 + g01 추가 재질·색·스타일(금속, 물약, 보석, 음식, 천, 판 색, 효과 빛) |

## 자산

| 단계 | 자산 | 크기·프레임 | 설명 | 상태 |
|---|---|---|---|---|
| A | `ov_fog_light` | 768×768 | Light fog: sparse soft wisps of pale violet-grey, low alpha, tiles seamlessly (768). | 완료 |
| A | `ov_light_circle_l` | 768×768 × 2 | Light circle, large (768): white and yellow. | 완료 |
| A | `ov_light_circle_m` | 384×384 × 2 | Light circle, medium (384): white and yellow. | 완료 |
| A | `ov_light_circle_s` | 192×192 × 2 | Light circle, small (192): white and yellow soft radial light, three stacked falloffs. | 완료 |
| A | `ov_vision_dark` | 2560×1440 × 2 | Darkness outside the field of view: near-black veil over 2560x1440 with a soft clear hole (wide and narrow). | 완료 |
| B | `ov_fog_thick` | 768×768 | Thick fog: dense layered banks of dark and pale violet-grey, higher alpha, tiles seamlessly (768). | 완료 |
| B | `ov_leaves` | 768×768 | Falling leaves: sparse brown, rust and wine leaves at random angles with midribs, tiles seamlessly (768). | 완료 |
| B | `ov_rain` | 768×768 | Rain: thin slanted streaks in two depths (long faint far drops, shorter brighter near drops), tiles seamlessly (768). | 완료 |
| B | `ov_snow` | 768×768 | Snow: soft flakes in two depths, small far dots and larger blurred near flakes with a few sparkles, tiles seamlessly (768). | 완료 |
| C | `ov_bubbles` | 768×768 | Bubbles: pale rings of mixed sizes with small highlights, rising, tiles seamlessly (768). | 완료 |
| C | `ov_dust_motes` | 768×768 | Dust motes: small warm specks and a few larger soft blurred ones, drifting, tiles seamlessly (768). | 완료 |
| C | `ov_light_circle_color_l` | 768×768 × 2 | Light circle, large (768): blue and red. | 완료 |
| C | `ov_light_circle_color_m` | 384×384 × 2 | Light circle, medium (384): blue and red. | 완료 |
| C | `ov_light_circle_color_s` | 192×192 × 2 | Light circle, small (192): blue and red. | 완료 |
| C | `ov_screen_noise` | 768×768 × 2 | Screen noise: fine grain in three greys plus faint scanlines, two frames to flicker, tiles seamlessly (768). | 완료 |
| C | `ov_sunbeams` | 2560×1440 | Sunbeams: soft warm shafts slanting down from the upper left, over 2560x1440, low alpha. | 완료 |

## 결과 파일

- `assets/art/generic/jobs/g01-overlays-v01/output/<asset>/<frame>.png` + `<frame>.json`(manifest: status candidate, 쓴 아이콘과 SHA-256, meta).
- 여러 프레임 자산은 `<asset>_sheet.png`(한 줄) + `<asset>_sheet.json`.
- 확인용 모아 보기: `assets/art/generic/jobs/g01-overlays-v01/preview/`

## 도구

V1 `h0-icon-mood-v02/tool` 전체(__pycache__ 제외)와 `palette_h0_mood.json`을 복사했다. 바꾼 점:

- `iconkit/icons.py`: `prefetch` 기본 workers 8 → 2 (세션 규칙: 도구 workers 2 이하). 그림 결과는 같다.
- `build.py`: 레시피의 `meta`(9칸 여백, 핫스팟, 이음 여부, 단계)를 manifest에 그대로 넣는다.
- `review_sheet.py`: `--label`(어두운 바탕용 글자색), `--wrap N`(N개마다 줄 바꿈).
- 추가 `g01kit.py`: 레시피 작성 도우미(원·날카로운 사각형·다각형·물방울·반짝별 조각, 묶음 회전·확대, 부채꼴, 꺾은선, 반지름 일정한 둥근 사각형, 프레임 태그) + `palette_g01.json` 생성. 렌더러는 그대로다.
- 추가 `g01_docs.py`: 이 문서들과 목록 상태 칸을 레시피·결과에서 다시 쓴다.
- 추가 `tile_preview.py`: 이음 무늬를 2×2로 붙여 이음새를, 빛·가림막을 체커 위에서 투명도를 보는 확인 시트.

다시 만들기(`tool` 폴더에서):

```
py -3 -B gen_overlays.py --stage all
py -3 -B build.py --all
py -3 -B tile_preview.py --out ../preview/overlays_all.png
```

## 진행

- [x] A 단계 (5개 레시피)
- [x] B 단계 (4개 레시피)
- [x] C 단계 (7개 레시피)
