# g07-icons-v01 — 특수 아이콘 (예보 기호, 데스크톱, 보드게임 조각)

세션 g07. 기상 방송국(예보 기호), 데스크톱 OS 세계(데스크톱 아이콘), 탐정 보드게임(말·주사위·표식) 키트용 128×128 평면 아이콘. 결과는 전부 candidate이고 승인은 사용자만 한다.
목록과 근거 키트: `docs\art\projects\generic\catalog\g07_future_kits.md`

## 형식
- 128×128 투명 PNG 한 장씩 + 한 줄 16칸 시트 `preview\sheet16_icons_g07.png`(순서는 같은 이름의 `.json`).
- 글자·숫자 없음. 주사위는 점(눈), 데스크톱 아이콘은 모양만.
- 여러 색·면은 같은 레시피의 프레임: `icon_bg_pawn`(wine/teal/ochre/violet/bone/charcoal), `icon_bg_die`(face_1~6).

## 도구·팔레트
`g07-controls-v01\JOB.md`와 같다(같은 tool 복사본 + `gen_icons.py`, 같은 `palette_g07.json`).

## 작성자 설계
- 예보 기호는 g01·g02에 없는 "송출용 기호"다(날씨 효과 겹침 무늬 ov_rain 등과 다름). wrong_weather의 '위로 내리는 비', '실내만 눈'을 넣었다.
- 데스크톱 아이콘은 g02의 현대 소지품 아이콘(스마트폰 등)과 겹치지 않는 OS 화면 기호만.
- 말은 체스 말 아이콘을 쓰지 않고 삼각형·원·둥근 판으로 새로 조립했다(원래 아이콘이 보이지 않게).

## 진행
A (10)
- [x] icon_fc_sun, icon_fc_cloud, icon_fc_rain, icon_fc_rain_up
- [x] icon_os_folder, icon_os_trash, icon_os_file, icon_os_chat
- [x] icon_bg_pawn(6색), icon_bg_die(6면)
B (9)
- [ ] icon_fc_snow, icon_fc_storm, icon_fc_fog, icon_fc_snow_indoor, icon_os_mail, icon_os_web, icon_os_settings, icon_os_terminal, icon_os_webcam
C (6)
- [ ] icon_fc_wind, icon_fc_night, icon_os_music, icon_os_heart, icon_os_follower, icon_bg_token
