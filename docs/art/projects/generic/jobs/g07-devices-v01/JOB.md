# g07-devices-v01 — 장르 전용 장치 (60도 탑다운 오브젝트)

세션 g07. 앞으로 나올 키트의 "그 장르에만 있는 장치": 교환대, 무전 책상, 우편 분류 선반, 엑스선 검색대, 개찰구, 등대 렌즈, 잠수함 해치, 금전 등록기, 증거 게시판 등. g04 목록(자판기·SF 콘솔·등대 건물·계산대 등)과 겹치는 것은 넣지 않았다. 결과는 전부 candidate이고 승인은 사용자만 한다.
목록과 근거 키트: `docs\art\projects\generic\catalog\g07_future_kits.md`

## 형식
- 60도 탑다운(도구의 60도 계산), 투명 PNG(원본 2배), `style: prop`.
- 크기는 g04와 같다: 폭 180 px/m, 바닥 깊이 156 px/m(×0.866), 높이 105 px/m. 플레이어 그림 약 180 px = 1.7 m.
- 피벗: 앞쪽 아래 가운데 바닥점(달리 적은 것만 예외: 해치는 바닥 중심, 금전 등록기는 카운터 위에 놓는 접점).
- 바닥 그림자는 `_shadow.png`, 불빛·화면은 `_emit.png`로 따로. 상태는 같은 캔버스·피벗의 프레임.
- 글자·숫자 없음: 이름표·탭·표지는 빈 판, 화면은 형광 모양만.

## 도구·팔레트
`g07-controls-v01\JOB.md`와 같다(같은 tool 복사본 + `gen_devices.py`, 같은 `palette_g07.json`).

## 작성자 설계 (크기·배치)
- obj_switchboard: 폭 1.65 m 책상(높이 0.8 m) + 뒤 잭 판(높이 1.9 m). 잭 12×4, 호출등 12. active = 등 4개 켜짐 + 코드 3줄.
- obj_radio_desk: 책상 1.3 m, 무전기 0.8×0.35×0.42 m, 주파수 창·계기·스피커·손잡이, 마이크·헤드폰.
- obj_sorting_rack: 1.4×0.4×1.9 m, 칸 7×7, 칸마다 빈 이름표.
- obj_xray_scanner: 기계 1.0×1.1×1.45 m(입구가 보는 쪽), 앞으로 롤러 탁자 0.8×0.6×0.7 m, 오른쪽에 모니터 기둥, 위에 경광등.
- obj_turnstile: 몸통 0.28×0.9×1.0 m, 삼발 팔은 오른쪽(통로 쪽)으로 허리 높이.
- obj_lighthouse_lens: 받침 지름 0.8 m, 유리 렌즈 지름 0.62 m·높이 1.1 m, 놋쇠 띠 6줄, 가운데 과녁 렌즈.
- obj_sub_hatch: 지름 1.0 m 바닥 해치, 닫힘(손잡이 바퀴·볼트 12) / 열림(뚜껑 세움, 사다리).
- obj_cash_register: 0.47×0.45×0.6 m, 빈 가격 탭 5, 옆 손잡이. 카운터(g04 obj_counter_shop 등) 위에 놓는다.
- obj_evidence_board: 코르크 판 1.4×1.0 m, 다리 2개. pinned = 빈 사진 3·빈 쪽지 3·핀·붉은 실.

## 진행
A (9)
- [x] obj_switchboard(idle/active), obj_radio_desk(off/on), obj_sorting_rack(empty/full), obj_xray_scanner(off/on), obj_turnstile(locked/open)
- [x] obj_lighthouse_lens(off/on), obj_sub_hatch(closed/open), obj_cash_register(closed/open), obj_evidence_board(empty/pinned)
B (14)
- [ ] obj_telegraph_desk, obj_antenna_mast, obj_parcel_scale, obj_checkpoint_booth, obj_locker_bank, obj_weather_mast, obj_studio_camera, obj_fog_horn, obj_bell_buoy, obj_valve_wheel, obj_periscope, obj_display_case, obj_seance_table, obj_bell_rack
C (13)
- [ ] obj_mail_cart, obj_parcel_chute, obj_rain_gauge, obj_onair_lamp, obj_bollard, obj_marker_buoy, obj_bulkhead_door, obj_porthole, obj_music_stand, obj_ghost_trap, obj_salt_circle, obj_heart_monitor, obj_specimen_tank
