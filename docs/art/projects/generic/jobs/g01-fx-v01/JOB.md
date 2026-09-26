# g01-fx-v01 — 전투·마법 효과 애니메이션

상태: **candidate.** 승인·반려는 사용자만 한다. 게임 코드·씬에는 연결하지 않았다.

## 근거

- 규칙: `docs/art/mass_production/GENERIC.md`(g01 담당: BS2 목록 보강 + 판타지 계열·장르 없는 아이콘·UI·효과·겹침 무늬), `COMMON.md`(그리는 규칙, 크기 통일, V1 기준 도구·팔레트).
- 목록: `docs/art/projects/generic/catalog/g01_list.md`(A → B → C).
- BS2: 이 컴퓨터에 BLACK SOULS II가 없어 보강은 건너뛰었다. `g01_bs2_inventory.md`의 g01 몫(아이콘 세트, 창틀·게이지 바탕·커서·감정 말풍선·전투 시작 전환, 칼·화살·소환·불꽃놀이·선 긋기·특수기·마법진, 안개·잡음·낙엽·거품·햇살·빛 원·시야 밖 어둠)은 전부 목록에 넣었다.
- 그림은 at-icons 모양을 잘라 겹친 조합으로만 만들었다. 글자·숫자·워터마크·원작 고유 요소 없음.

## 규격

| 항목 | 값 |
|---|---|
| 칸 | 192×192 투명 PNG × 5프레임(`<asset>_1..5.png`) + 한 줄 시트 `<asset>_sheet.png` 960×192 |
| 시점 | 정면·평면(전투 화면용) |
| 빛 | 잉크 테두리 없음. 빛 번짐은 흐린 평면 형태(g01kit.halo)로 따로 그림. 보통 알파 합성, 가산 합성도 가능 |
| 화풍 | V1 도구, 스타일 `fx`(2배 슈퍼샘플). 얼음 결정·흙처럼 물체인 부분만 V1 명암·선을 쓴다 |
| 색 | `recipes/palette_g01.json` = V1 `palette_h0_mood.json`의 모든 항목 그대로 + g01 추가 재질·색·스타일(금속, 물약, 보석, 음식, 천, 판 색, 효과 빛) |

## 자산

| 단계 | 자산 | 크기·프레임 | 설명 | 상태 |
|---|---|---|---|---|
| A | `fx_blunt_hit` | 192×192 × 5 | Blunt impact: white-gold star burst, expanding shock ring, dust puffs and flying chips. | 완료 |
| A | `fx_fire_burst` | 192×192 × 5 | Fire burst: flames flare up from the ground, peak with a hot core and embers, break into tongues and dark smoke. | 완료 |
| A | `fx_heal_light` | 192×192 × 5 | Healing light: green-gold glow gathers on the ground, a soft column rises with floating crosses and sparkles, then drifts away. | 완료 |
| A | `fx_ice_shards` | 192×192 × 5 | Ice shards: a frost ring spreads, crystals burst upward, glint, crack into flying fragments and mist. | 완료 |
| A | `fx_lightning_strike` | 192×192 × 5 | Lightning strike: a jagged bolt drops from the top, flashes on the ground with branches and sparks, then leaves an afterglow. | 완료 |
| A | `fx_slash` | 192×192 × 5 | Sword slash: a steel-white crescent sweeps from upper right to lower left, flashes, thins and fades with sparks. | 완료 |
| A | `fx_thrust` | 192×192 × 5 | Thrust: a narrow white streak drives from lower left to upper right, a four-point flash and ring burst at the tip. | 완료 |

## 결과 파일

- `assets/art/generic/jobs/g01-fx-v01/output/<asset>/<frame>.png` + `<frame>.json`(manifest: status candidate, 쓴 아이콘과 SHA-256, meta).
- 여러 프레임 자산은 `<asset>_sheet.png`(한 줄) + `<asset>_sheet.json`.
- 확인용 모아 보기: `assets/art/generic/jobs/g01-fx-v01/preview/`

## 도구

V1 `h0-icon-mood-v02/tool` 전체(__pycache__ 제외)와 `palette_h0_mood.json`을 복사했다. 바꾼 점:

- `iconkit/icons.py`: `prefetch` 기본 workers 8 → 2 (세션 규칙: 도구 workers 2 이하). 그림 결과는 같다.
- `build.py`: 레시피의 `meta`(9칸 여백, 핫스팟, 이음 여부, 단계)를 manifest에 그대로 넣는다.
- `review_sheet.py`: `--label`(어두운 바탕용 글자색), `--wrap N`(N개마다 줄 바꿈).
- 추가 `g01kit.py`: 레시피 작성 도우미(원·날카로운 사각형·다각형·물방울·반짝별 조각, 묶음 회전·확대, 부채꼴, 꺾은선, 반지름 일정한 둥근 사각형, 프레임 태그) + `palette_g01.json` 생성. 렌더러는 그대로다.
- 추가 `g01_docs.py`: 이 문서들과 목록 상태 칸을 레시피·결과에서 다시 쓴다.
- 추가 `row_sheet.py`: 5프레임 한 줄 시트.

다시 만들기(`tool` 폴더에서):

```
py -3 -B gen_fx.py --stage all
py -3 -B build.py --all
py -3 -B row_sheet.py
```

## 진행

- [x] A 단계 (7개 레시피)
- [ ] B 단계 (0개 레시피)
- [ ] C 단계 (0개 레시피)
