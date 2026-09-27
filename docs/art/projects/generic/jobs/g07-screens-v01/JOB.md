# g07-screens-v01 — 화면·특수 UI

세션 g07. 앞으로 나올 키트의 화면 UI: 탐지 화면·파형(교환대·잠수함·이상 현상), 레트로 OS(데스크톱 세계·질의 세계), 도장 자국(우편·세관), 리듬 레인(리듬·합창), 화면 가림 틀(뷰파인더·잠망경). 결과는 전부 candidate이고 승인은 사용자만 한다.
목록과 근거 키트: `docs\art\projects\generic\catalog\g07_future_kits.md`

## 형식
- 정면 평면, 투명 PNG, 글자·숫자 없음(제목줄·점수 칸·자막 띠는 빈 모양. 게임이 글자를 얹는다).
- 9-slice: 창틀·레인 등은 `g07_export.py slice9`로 9조각(`<프레임>_9s_<tl…br>.png`)과 여백 정보(`_9s.json`), 늘린 확인 그림(`preview\<자산>_9s_check.png`)을 만든다. 여백: ui_os_window 48, ui_os_progress_frame 16, ui_rhythm_lane 48, ui_rhythm_judge 가로 28·세로 16.
- 도는 것·깜빡이는 것은 따로: `ui_scr_sonar_sweep`(회전), `ui_scr_sonar_blip`(밝음→흐려짐 3칸), `ui_scr_wave_strip`(가로로 흘려 보내는 이음 띠).
- 빛나는 부분(형광 격자, 불빛, 노트)은 `_emit.png`.
- 화면 가림 2560×1440(`ui_scr_viewfinder`)은 큰 캔버스라 `supersample 1`(환경 그림과 같음)로 그렸다. 윤곽선 굵기는 2560 기준 2 px(화면 1280에서 1 px).

## 도구·팔레트
`g07-controls-v01\JOB.md`와 같다(같은 tool 복사본 + `gen_screens.py`, 같은 `palette_g07.json`).

## 작성자 설계
- 원형 탐지 화면: 384 캔버스, 화면 지름 302, 격자 원 3개, 방위 눈금 72/12개. 훑는 부채꼴의 앞선은 위(0도), 시계 방향으로 돌린다.
- 파형 화면 576×384, 형광 화면 478×298(중심 288,176). 파형 띠 480×128: 사인(주기 120), 심장 박동(160), 잡음(480) — 셋 다 480마다 이어진다.
- 레트로 OS: 창틀은 베이지 플라스틱+음각 테(활성 청록 제목줄, 비활성 회색), 창 버튼 128(최소·최대·닫기 × 보통·누름), 커서 4개는 레시피를 따로 두어 각자 핫스팟을 pivot에 적었다(화살 25,15 / 기다림 64,64 / 손 52,20 / 글자 막대 64,64).
- 진행 막대 칸은 48×48, 틀 안의 어두운 홈에 38~40 px 간격으로 나란히 놓는다.
- 도장 자국: 승인(두 겹 원+별), 반려(원+X), 보류(원+세모), 무효(네모 틀+두 줄). 잉크 빨강·보라(보랏빛 잉크는 violet_case 단서). 가장자리 거칠게(rough), 잉크가 빈 곳(mottle).
- 리듬: 레인 폭 152, 레일 놋쇠. 노트 캡슐 150×54. 홀드 몸통은 세로로 이어지는 따로 된 레시피(`ui_rhythm_note_body`).

## 진행
A (11)
- [x] ui_scr_sonar + ui_scr_sonar_sweep + ui_scr_sonar_blip(bright/fade1/fade2)
- [x] ui_scr_wave + ui_scr_wave_strip(sine/pulse/noise)
- [x] ui_os_window(active/inactive) + 9-slice
- [x] ui_os_titlebtn(min/max/close × normal/pressed)
- [x] ui_os_cursor_arrow / _wait / _hand / _beam
- [x] ui_os_progress_frame + 9-slice, ui_os_progress_cell(teal/wine/amber)
- [x] ui_stamp_mark(approve/deny/hold/void × red/violet)
- [x] ui_rhythm_lane + 9-slice, ui_rhythm_judge + 9-slice
- [x] ui_rhythm_note(tap_amber/tap_teal/hold_head/hold_tail) + ui_rhythm_note_body
- [x] ui_rhythm_target(idle/hit/miss)
- [x] ui_scr_viewfinder(rec/standby)
B (9)
- [x] ui_scr_terminal(off/on, 9-slice 48) + ui_scr_terminal_input(9-slice 24, 주황 커서)
- [x] ui_scr_fragment(찢긴 종이 카드, 9-slice 40)
- [x] ui_os_bubble(left 베이지 / right 청록, 9-slice 48, 꼬리는 아래 모서리 칸 안)
- [x] ui_scr_periscope(2560×1440, 보이는 원 반지름 600)
- [x] ui_scr_broadcast(하단 띠, 9-slice 가로 48·세로 24) + ui_scr_onair(off/on, 글자 대신 마이크 모양)
- [x] ui_scr_front(warm/cold/occluded, 384마다 이어짐)
- [x] ui_scr_xray(9-slice 48) + ui_scr_xray_scan(훑는 선, 9-slice 가로 24·세로 16)
- [x] ui_upgrade_node(locked/open/bought) + ui_upgrade_link(dim/lit, 192마다 이어짐)
- [x] ui_bg_card(suspect/method/place/back, 256×384)
C (6)
- 건너뜀(2026-09-27 사장님 지시: 전체 이미지 3000장 도달, 새 자산 시작 금지): ui_scr_flapboard, ui_os_tooltip, ui_os_taskbar, ui_rhythm_beat, ui_progress_ring, ui_scr_tally
