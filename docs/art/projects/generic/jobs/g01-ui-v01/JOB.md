# g01-ui-v01 — UI (창틀·버튼 바탕·게이지·커서·선택 테두리·감정 말풍선·화면 전환)

상태: **candidate.** 승인·반려는 사용자만 한다. 게임 코드·씬에는 연결하지 않았다.

## 근거

- 규칙: `docs/art/mass_production/GENERIC.md`(g01 담당: BS2 목록 보강 + 판타지 계열·장르 없는 아이콘·UI·효과·겹침 무늬), `COMMON.md`(그리는 규칙, 크기 통일, V1 기준 도구·팔레트).
- 목록: `docs/art/projects/generic/catalog/g01_list.md`(A → B → C).
- BS2: 이 컴퓨터에 BLACK SOULS II가 없어 보강은 건너뛰었다. `g01_bs2_inventory.md`의 g01 몫(아이콘 세트, 창틀·게이지 바탕·커서·감정 말풍선·전투 시작 전환, 칼·화살·소환·불꽃놀이·선 긋기·특수기·마법진, 안개·잡음·낙엽·거품·햇살·빛 원·시야 밖 어둠)은 전부 목록에 넣었다.
- 그림은 at-icons 모양을 잘라 겹친 조합으로만 만들었다. 글자·숫자·워터마크·원작 고유 요소 없음.

## 규격

| 항목 | 값 |
|---|---|
| 9칸 | 글자 없는 바탕·틀만. 한 장 PNG + manifest `meta.nine_slice` = [왼, 위, 오른, 아래] px. 모서리 칸 밖의 변은 길이 방향으로 똑같게 만들어 늘려도 무늬가 안 깨진다 |
| 상태 | 버튼 4상태, 게이지 채움 4색은 한 레시피의 프레임(`<asset>_<상태>.png`) + `<asset>_sheet.png` 한 줄 |
| 커서 | 128×128, manifest `pivot` = `meta.hotspot`(누르는 점) |
| 감정 말풍선 | 128×128, 5프레임(1~3 튀어나옴, 4~5 가볍게 흔들림) + 한 줄 시트, `meta.anchor` = 꼬리 끝(말하는 캐릭터 머리 위에 둘 점). 기호는 도형으로 조립 |
| 화풍 | V1 도구. 스타일 `ui`(2배 슈퍼샘플). 바탕 판은 V1보다 거의 검게(글자가 올라갈 자리) |
| 색 | `recipes/palette_g01.json` = V1 `palette_h0_mood.json`의 모든 항목 그대로 + g01 추가 재질·색·스타일(금속, 물약, 보석, 음식, 천, 판 색, 효과 빛) |

## 자산

| 단계 | 자산 | 크기·프레임 | 설명 | 상태 |
|---|---|---|---|---|
| A | `ui_balloon_exclaim` | 128×128 × 5 | Emotion balloon: exclamation mark (bar + dot) on a bone-white bubble, 5-frame pop. | 완료 |
| A | `ui_balloon_question` | 128×128 × 5 | Emotion balloon: question mark built from a ring arc, stem and dot, 5-frame pop. | 완료 |
| A | `ui_button` | 192×96 × 4 | Button base in four states (normal, hover, pressed, disabled): bevelled plate, bronze or gold rim, no label. | 완료 |
| A | `ui_cursor_gauntlet` | 128×128 | Pointing cursor: steel gauntlet pointing right, curled armoured fingers, bronze cuff. Hotspot at the fingertip. | 완료 |
| A | `ui_dialogue_wood` | 192×192 | Dialogue box frame: black-stained wood band, iron L brackets with nails at the corners, warm dark panel. | 완료 |
| A | `ui_gauge_fill` | 192×24 × 4 | Gauge base, fill part in four colours (red life, blue mana, green stamina, gold experience): glossy capsule. | 완료 |
| A | `ui_gauge_frame` | 192×48 | Gauge base, frame part: iron tube with capsule ends, dark channel with inner shadow, bronze end studs. | 완료 |
| A | `ui_select_corners` | 128×128 | Selection frame: four gold L brackets with a soft glow and a faint edge line, empty centre. | 완료 |
| A | `ui_window_stone` | 192×192 | Basic window frame: dark bevelled stone band, bronze inner line, bronze corner diamonds with garnets, near-black panel. | 완료 |
| B | `ui_balloon_anger` | 128×128 × 5 | Emotion balloon: anger mark of four bent red strokes around a gap, 5-frame pop. | 완료 |
| B | `ui_balloon_heart` | 128×128 × 5 | Emotion balloon: red heart (square + two circles), 5-frame pop. | 완료 |
| B | `ui_balloon_idea` | 128×128 × 5 | Emotion balloon: bright gold four-point sparkle with two small ones (sudden idea), 5-frame pop. | 완료 |
| B | `ui_balloon_note` | 128×128 × 5 | Emotion balloon: two beamed musical notes built from ellipses and bars, 5-frame pop. | 완료 |
| B | `ui_balloon_silence` | 128×128 × 5 | Emotion balloon: three dots (silence), 5-frame pop. | 완료 |
| B | `ui_balloon_sweat` | 128×128 × 5 | Emotion balloon: two pale blue sweat drops with highlights, 5-frame pop. | 완료 |
| B | `ui_window_parchment` | 192×192 | Parchment window: pale paper panel with foxing, rolled top and bottom edges, burnt-brown border, wax dots in the corners. | 완료 |

## 결과 파일

- `assets/art/generic/jobs/g01-ui-v01/output/<asset>/<frame>.png` + `<frame>.json`(manifest: status candidate, 쓴 아이콘과 SHA-256, meta).
- 여러 프레임 자산은 `<asset>_sheet.png`(한 줄) + `<asset>_sheet.json`.
- 확인용 모아 보기: `assets/art/generic/jobs/g01-ui-v01/preview/`

## 도구

V1 `h0-icon-mood-v02/tool` 전체(__pycache__ 제외)와 `palette_h0_mood.json`을 복사했다. 바꾼 점:

- `iconkit/icons.py`: `prefetch` 기본 workers 8 → 2 (세션 규칙: 도구 workers 2 이하). 그림 결과는 같다.
- `build.py`: 레시피의 `meta`(9칸 여백, 핫스팟, 이음 여부, 단계)를 manifest에 그대로 넣는다.
- `review_sheet.py`: `--label`(어두운 바탕용 글자색), `--wrap N`(N개마다 줄 바꿈).
- 추가 `g01kit.py`: 레시피 작성 도우미(원·날카로운 사각형·다각형·물방울·반짝별 조각, 묶음 회전·확대, 부채꼴, 꺾은선, 반지름 일정한 둥근 사각형, 프레임 태그) + `palette_g01.json` 생성. 렌더러는 그대로다.
- 추가 `g01_docs.py`: 이 문서들과 목록 상태 칸을 레시피·결과에서 다시 쓴다.
- 추가 `row_sheet.py`: 프레임을 한 줄 시트로 잇는다.
- 추가 `nine_preview.py`: 9칸 원본과 늘린 모습을 나란히 그린 확인 시트.

다시 만들기(`tool` 폴더에서):

```
py -3 -B gen_ui.py --stage all
py -3 -B build.py --all
py -3 -B row_sheet.py
py -3 -B nine_preview.py --out ../preview/nine_all.png
```

## 진행

- [x] A 단계 (9개 레시피)
- [x] B 단계 (7개 레시피)
- [ ] C 단계 (0개 레시피)
