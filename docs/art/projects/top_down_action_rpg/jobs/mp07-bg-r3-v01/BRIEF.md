# R3 Bellhouse Hospice — 배경·오브젝트 brief (mp07-bg-r3-v01)

작성 2026-09-27, 세션 07. 확정 기준(COMMON: 분위기 V1, 빛·그림자는 게임 코드, 배경과 오브젝트 분리)으로 고친 판. 화면 나누기·배치·재질·오브젝트 모양·출구 그림 ID는 전부 **작성자 설계**이고 domain 데이터가 아니다. 좌표는 논리 좌표(1280×720)이고 최종 위치는 장면 JSON이 정본이다.

## 1. 근거

- 지역 원본 `modules/top_down_action_rpg/content/regions/region_r3_bellhouse_hospice.json`: topology `gallery_tower_and_undercroft`, size_class `large`, landmark_count 5, traversal_axis `elevation`. 출구 5개, 내부 길 1개(`boiler_undercroft_lift`), revisit_variants 2개.
- 사물 원본 `content/props/prop_r3_*.json` 4개. 회복 `content/recovery/rec_r3_hospice_respawn.json`: 자비 기관 밸브 자리에서 다시 일어나고 밸브와 맹세 장부 책상이 처음 상태로 돌아간다.
- 기획: 02 §7.4 (Intake Gallery, Bell Tower, Boiler Undercroft, Mercy Engine, recovery ward가 층별로 이어짐. faith는 종교 상징이 아니라 도움이 늦게 오는 시간을 줄이는 운영 값), 02 §1, 03 지역 표.
- 규칙·화풍: R2 brief §1·§2와 같다(V1 `h0-icon-mood-v02`, 13 §1, 09 §12, COMMON).

## 2. 출력·시점·크기·빛

R2 brief §2와 같다. 화면 한 장 = 원본 2560×1440, 60° 정사영, 바닥 180 px/m, 높이 1 m ≈ 110 px. 빛은 기본 확산광만(장면 조명·비네트 없음), 빛나는 부분은 `_emit.png`와 장면 JSON의 `light`. 배경 그림은 `base_clean`과 `foreground_*`만, 옮길 수 있는 물건과 content 사물·출구는 오브젝트(투명 PNG, 접촉 피벗, `_shadow.png`, 여백 32 px 이상).

60° 카메라에서는 동서 방향 벽이 옆모습(얇은 띠)으로만 보이므로, 문·승강기·창구처럼 보여야 하는 것은 북쪽 벽(정면)이나 화면 아래 가장자리에 둔다.

## 3. 화면 구역 나누기

이동 축이 높이(`elevation`)라서 층마다 한 화면. 층 사이는 계단(고정 구조)이고 새 route가 아니다.

| 구역 ID | 층 | 랜드마크 | 출구·내부 길 | content 사물 |
|---|---|---|---|---|
| `r3_a_intake_gallery` | 1층 (첫 화면) | Intake Gallery | E03 Mercy Causeway (남 가운데, H0로), E17 Water Ambulance Bridge (남동, R2로) | mana_profile_board |
| `r3_b_bell_tower_ward` | 2층 | Bell Tower, recovery ward | E06 Quiet Ward Passage (북서 문, R1로), E10 Bell Cable Lift (북동 승강장, R4로) | latency_bell, vow_ledger_desk |
| `r3_c_boiler_undercroft` | 지하 | Boiler Undercroft, Mercy Engine | E11 Care Train (동, R5로), 내부 길 `boiler_undercroft_lift` | mercy_engine_valve |

- 계단: A 북쪽 벽 가운데 올라가는 계단(x 620..780) → B 아래 가운데 계단 구멍(x 620..780). A 동쪽 바닥의 내려가는 계단 구멍(x 960..1100) → C 북서쪽 벽을 따라 내려오는 계단(x 60..220).

## 4. 구역별 배치와 정보 등급

### A `r3_a_intake_gallery` — 접수 회랑

| 요소 | 위치 | 등급 | 그림 |
|---|---|---|---|
| 회랑 바닥 (유약 타일) | y 160..650 | 길찾기·상황 이해 | base |
| 북쪽 벽과 붙은 기둥 | 벽 밑선 y 160, 기둥 x 90, 270, 450, 960, 1140 | 길찾기·상황 이해 | base |
| 올라가는 계단 (B로) | 북쪽 벽 가운데 x 620..780 | 길찾기·상황 이해 | base |
| 내려가는 계단 구멍 (C로) | x 960..1100, y 250..340, 세 면 난간 | 길찾기·상황 이해 | base |
| 남쪽 문턱과 바깥 | 문턱 y 650, 그 아래 둑길(x 560..720)과 어두운 물 | 길찾기·상황 이해 | base |
| 방출 프로필 판 | 북쪽 벽 (400,160) | 증거·직접 상호작용 | `prop_r3_mana_profile_board` |
| 접수 봉인 문 (E03) | 남쪽 문턱 가운데 (640,650) | 증거·직접 상호작용 | `exit_r3_e03_mercy_causeway` |
| 들것 경사로 (E17) | 남동쪽 문턱 (1080,650) | 증거·직접 상호작용 | `exit_r3_e17_water_ambulance_bridge` |
| 접수 책상 (`service_r3_intake_seal`, `service_r3_care_window` 자리) | 서쪽 (220,380) | 길찾기·상황 이해 | `obj_r3_intake_desk` |
| 대기 의자 | (300,520), (860,520) | 분위기 | `obj_r3_waiting_bench` |
| 벽등 | 북쪽 벽 기둥 사이 | 분위기 | `obj_r3_wall_lamp` |
| 남쪽 낮은 난간 | 문턱을 따라, 두 출구 자리는 비움 | 분위기 | `foreground_gallery_rail` |

### B `r3_b_bell_tower_ward` — 종탑과 회복 병동

| 요소 | 위치 | 등급 | 그림 |
|---|---|---|---|
| 병동 바닥 (널마루) | y 160..720 | 길찾기·상황 이해 | base |
| 북쪽 벽 | 밑선 y 160 | 길찾기·상황 이해 | base |
| 종탑 우물 (바닥 구멍, 네 면 난간) | x 520..800, y 240..390 | 길찾기·상황 이해 | base |
| 계단 구멍 (A에서) | 아래 가운데 x 620..780, y 600..720 | 길찾기·상황 이해 | base |
| 지연 종 | 우물 가운데 바닥점 (660,315), 종은 그 위에 매달림 | 증거·직접 상호작용 | `prop_r3_latency_bell` (머리 위) |
| 맹세 장부 책상 | (1000,420) | 증거·직접 상호작용 | `prop_r3_vow_ledger_desk` |
| 조용한 병동 통로 문 (E06) | 북쪽 벽 서쪽 (150,160) | 증거·직접 상호작용 | `exit_r3_e06_quiet_ward_passage` |
| 종 케이블 승강장 (E10) | 북쪽 벽 동쪽 (1050,160) | 증거·직접 상호작용 | `exit_r3_e10_bell_cable_lift` |
| 병상 여섯 | 서쪽 두 줄 x 60..440 | 분위기 | `obj_r3_ward_bed` |
| 칸막이 병풍 | 병상 사이 | 분위기 | `obj_r3_privacy_screen` |
| 벽등 | 북쪽 벽 | 분위기 | `obj_r3_wall_lamp` |
| 계단 구멍 난간 | 계단 구멍 양옆 | 분위기 | `foreground_stair_balustrade` |

### C `r3_c_boiler_undercroft` — 보일러 지하실과 자비 기관

| 요소 | 위치 | 등급 | 그림 |
|---|---|---|---|
| 벽돌 바닥 | y 160..720 | 길찾기·상황 이해 | base |
| 북쪽 벽 (관이 지나감) | 밑선 y 160 | 길찾기·상황 이해 | base |
| 계단 (A에서) | 북서쪽 벽을 따라 x 60..220 | 길찾기·상황 이해 | base |
| 벽돌 기둥 | (360,420), (760,560) | 길찾기·상황 이해 | base |
| 자비 기관 단 (높이 1.5 m) | x 720..1240, 단 앞선 y 270 | 길찾기·상황 이해 | base |
| 승강기 뼈대 | 단 앞 서쪽 (680,270) | 길찾기·상황 이해 | base |
| 선로와 승강장 가장자리 | y 450..490, x 700..1280 | 길찾기·상황 이해 | base |
| 자비 기관 밸브 | 북쪽 벽 (540,160) | 증거·직접 상호작용 | `prop_r3_mercy_engine_valve` |
| 승강기 우리 (내부 길) | (680,270) | 증거·직접 상호작용 | `route_r3_boiler_undercroft_lift` |
| 돌봄 열차 승강장 문과 객차 (E11) | 선로 동쪽 (1140,470) | 증거·직접 상호작용 | `exit_r3_e11_care_train` |
| 자비 기관 | 단 위 (980,250) | 길찾기·상황 이해 | `obj_r3_mercy_engine` |
| 보일러 둘 | 서쪽 (180,380), (180,560) | 분위기 | `obj_r3_boiler` |
| 벽등 | 북쪽 벽 | 분위기 | `obj_r3_wall_lamp` |
| 앞쪽 배관 | 아래 가장자리 x 0..640 | 분위기 | `foreground_pipe_run` |

## 5. content 사물 4개

| 사물 · 피벗 | 상태 → 프레임 (art_key) | 모양 |
|---|---|---|
| `prop_r3_latency_bell` · 종 바로 아래 바닥점, 장면에서 배우 위 | `prop_r3_bell_struck`: 기운 종과 추, 멍에 위 시간 톱니바퀴, 순번 원판 줄이 한쪽에 모임<br>`prop_r3_bell_retimed`: 곧게 멈춘 종, 톱니바퀴 핀과 추 개수가 바뀜, 원판 줄이 반대쪽으로 | 종 입 1.4 m, 바닥 위 3.5 m. 숫자 없음 |
| `prop_r3_mana_profile_board` · 벽 밑선 | `prop_r3_profile_blank`: 세로 홈 네 줄, 빈 칸<br>`prop_r3_profile_filed`: 네 줄에 모양이 다른 말뚝이 서로 다른 높이로 | 1.4×1.2 m, 바닥 위 0.8 m. 글자 없음 |
| `prop_r3_mercy_engine_valve` · 벽 밑선 | `prop_r3_valve_open`: 관 다발의 큰 바퀴 밸브, 레버가 빠른 쪽, 빈 서명판<br>`prop_r3_valve_throttled`: 바퀴가 돌고 레버가 안정 쪽, 잠금 꼬리표와 죔쇠 | 처음에 숨는 사물. 회복해서 다시 일어나는 자리 |
| `prop_r3_vow_ledger_desk` · 앞쪽 바닥선 가운데 | `prop_r3_vow_open`: 비스듬한 필기대에 펼친 빈 장부와 펜<br>`prop_r3_vow_separate`: 장부 사이를 색이 다른 끈 셋이 나눔 | 1.1×0.6 m, 높이 1.1 m. 글자 없음 |

## 6. 출구·내부 길과 지역 오브젝트

| 오브젝트 | 근거 | closed | open |
|---|---|---|---|
| `exit_r3_e03_mercy_causeway` | → H0, gate G0 + care token | 접수 봉인 창살문이 닫히고 봉인 홈이 빔 | 창살문 두 짝이 열림 |
| `exit_r3_e17_water_ambulance_bridge` | → R2, gate G2 + R2 뿌리다리 `ps_raised` | 들것 경사판이 사슬에 세워짐 | 경사판이 내려와 바깥으로 이어짐 (R2 쪽 들다리와 같은 모양) |
| `exit_r3_e06_quiet_ward_passage` | → R1, gate G1, STORY_FORCED | 두꺼운 두 짝 문에 빗장 | 문이 열리고 어두운 복도 |
| `exit_r3_e10_bell_cable_lift` | → R4, gate G3 | 케이블만 있고 칸이 없음, 난간 문 닫힘 | 케이블 칸이 붙고 문이 열림 |
| `exit_r3_e11_care_train` | → R5, gate G3 | 승강장 문이 닫히고 선로가 빔 | 작은 객차가 멈춤판에 붙고 문이 열림 |
| `route_r3_boiler_undercroft_lift` | 내부 길 (지하실 → 자비 기관, 밸브 `ps_throttled` 필요) | 우리가 단 높이에 올라가 있고 아래 문이 잠김 | 우리가 바닥으로 내려오고 문이 열림 |

지역 오브젝트 (작성자 설계): `obj_r3_wall_lamp`(쇠 벽등, 빛 `#ffc987` 반지름 280), `obj_r3_intake_desk`(빈 서식과 봉인 도장대가 있는 접수 책상), `obj_r3_waiting_bench`(대기 의자), `obj_r3_ward_bed`(쇠 병상과 흰 시트, 사람 없음), `obj_r3_privacy_screen`(천 병풍), `obj_r3_boiler`(쇠 보일러, 불구멍 `emit`, 빛 `#ff9a4a` 반지름 360), `obj_r3_mercy_engine`(쇠·청동 큰 기계, 숫자 없는 유리 눈금, 불빛 없음).

## 7. 다시 방문

- `rv_after_latency_receipt`: 종 `retimed` 프레임.
- `rv_after_profile_filed`: 판 `filed`, 밸브 `throttled` 프레임. 배경은 바꾸지 않는다.

## 8. 재질과 색 (`recipes/palette_r3.json`, V1을 `extends`)

H0(회보라 광물), R2(젖은 나무·물)와 구별: 1층은 옅은 회청색 유약 타일과 뼈색 회벽, 2층은 널마루와 흰 리넨, 지하는 그을린 붉은 벽돌과 녹슨 쇠. 종은 따뜻한 청동. 밝기는 V1 수준(걷는 면 밝기 중앙값 80대).

## 9. 금지

R2 brief §10과 같고, 더해서 실제 종교 상징(십자가, 후광 등)을 쓰지 않는다. 병상에 사람 모양을 넣지 않는다.

## 10. 그리지 않고 비워 둘 자리

- 길 표시(세션 01): A (760,650), (1180,650) / B (230,190), (960,190) / C (1080,430).
- 회복 닻(세션 01): 밸브 앞 (540,230).
- 마력 농도 장치: R3 JSON에 농도 항목이 없어 자리 없음.
- NPC 자리: A 접수 책상 앞 (300,440) — 첫 대화 `conv_r3_intake_triage`. B 병상 사이 통로.

## 11. 검수

R2 brief §13과 같다. 더해서: 머리 위 종이 주 통로의 캐릭터를 완전히 가리지 않는가, 층 사이 계단 위치가 맞는가.
