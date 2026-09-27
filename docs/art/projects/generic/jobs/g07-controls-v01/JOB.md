# g07-controls-v01 — 계기·조작 부품 (정면 평면 UI)

세션 g07. 앞으로 나올 키트(교환대·무전실, 잠수함, 철도·항구, 등대, 리듬 등)에서 장치를 조작하는 화면에 쓸 부품이다. 결과는 전부 candidate이고 승인은 사용자만 한다.
목록과 근거 키트(K1~K12): `docs\art\projects\generic\catalog\g07_future_kits.md`

## 형식
- 정면 평면(60도 계산 없음), 투명 PNG. 기본 192×192, 큰 것은 384×384, 밀대 홈판은 192×384.
- 게임이 돌리거나 움직이는 부분은 따로 그렸다: 바늘 `ui_ctl_needle`, 손잡이 `ui_ctl_knob`의 `knob` 프레임, 밀대 손잡이 `ui_ctl_throttle_handle`, 플러그 `ui_ctl_jack_plug`. manifest의 `pivot`이 회전 중심 또는 접점이다(`pivot_meaning`에 적음).
- 켜진 불빛은 `_emit.png`로 따로 나온다(게임 코드가 밝힌다). 본 그림에는 빛 번짐이 투명한 곳까지 퍼지지 않는다.
- 글자·숫자 없음. 눈금은 선, 이름표 자리는 빈 놋쇠판이다.

## 도구 (h0-icon-mood-v02 `tool` 복사본 + g07 추가)
- `iconkit\icons.py`: `prefetch` 기본 workers 8 → 2 (COMMON.md 병렬 제한). 그림을 그리는 코드(render·paint·raster)는 바꾸지 않았다.
- 추가 파일(그림 코드가 아니라 레시피를 만드는 스크립트라 빌드 키에 영향 없음):
  - `g07kit.py` — 레시피를 짧게 쓰는 도우미: 둥근 사각형, 고리, 부채꼴(원 아이콘을 다각형으로 자름), 방사 눈금, 나사, 유리 반사, 곡선 위 점 줄(케이블·실), 60도 상자·원기둥, 바닥 그림자.
  - `gen_controls.py` — 이 묶음 레시피 생성(`A`/`B`/`C` 단계별).
  - `g07_export.py` — `sheet16`(한 줄 16칸 시트), `slice9`(9-slice 9조각 + `_9s.json` + 늘린 확인 그림).
  - `make_palette_g07.py` — `palette_g07.json` 생성.
- 다시 만들기(tool 폴더에서): `py -3 -B make_palette_g07.py` → `py -3 -B gen_controls.py A B C` → `py -3 -B build.py --all`. build.py는 이미 만든 프레임을 건너뛴다.

## 팔레트 `recipes\palette_g07.json`
V1(`palette_h0_mood.json`)의 색·재질·스타일은 그대로 두고 아래만 더했다. 밝기는 V1처럼 어둡게, 켜진 불빛과 형광 화면만 밝다.
- 재질: enamel(계기 눈금판), steel·steel_dark, paint_teal·olive·red·ochre·violet, plastic_beige·plastic_dark, rubber, cable, screen·screen_glass, phosphor·phosphor_dim, amber_screen, glass_pane, felt, cork, water, rust_metal, wax, salt, crystal, bone, ink_red·ink_violet, lamp_(red·green·amber·white·blue)_(off·on).
- 색 이름: enamel, dial_mark, zone_red, glare(유리 반사), glow_red·green·amber·white·phosphor·blue(빛 번짐), ink_red·ink_violet.

## 작성자 설계 (문서에 없는 값)
- 크기: 192 칸 안에 부품 지름 146~184 px(가장자리 4~12 px 여백).
- 둥근 계기 눈금은 270도(화면 각도 135°→405°, 0°=오른쪽·90°=아래), 빨간 구간은 끝쪽 45도.
- 바늘·손잡이 표시선은 위(0도)를 향한다. 게임에서 시계 방향으로 돌린다.
- 밀대 손잡이의 접점은 홈판의 가운데 세로선 위, 이동 범위 y 58~326.
- 코드 줄 `ui_ctl_cable`은 12 px 주기 무늬라 192 px마다 끊김 없이 이어진다(Line2D 텍스처용). 테두리 윤곽선(silhouette)은 이음새에 줄이 생기지 않게 껐다.

## 진행
A (10)
- [x] ui_ctl_gauge_round — 원형 계기판 1장
- [x] ui_ctl_needle — slim, arrow
- [x] ui_ctl_toggle — down, up(녹색 등 켜짐)
- [x] ui_ctl_button — red/green/amber × off/on
- [x] ui_ctl_lamp — red/green/amber/white × off/on
- [x] ui_ctl_knob — base, knob
- [x] ui_ctl_throttle + ui_ctl_throttle_handle
- [x] ui_ctl_emergency — guarded, open, pressed
- [x] ui_ctl_jack — empty, plugged + ui_ctl_jack_plug
- [x] ui_ctl_cable — wine, black, teal
B (10)
- [ ] ui_ctl_gauge_depth, ui_ctl_gauge_thermo, ui_ctl_gauge_half, ui_ctl_telegraph, ui_ctl_tuner, ui_ctl_meter, ui_ctl_keypad, ui_ctl_dial, ui_ctl_selector, ui_ctl_panel
C (3)
- [ ] ui_ctl_crank, ui_ctl_hazard, ui_ctl_speedo

모아 보기: `assets\art\generic\jobs\g07-controls-v01\preview\review_*.png`
