# R3 Bellhouse Hospice — 배경·사물 brief (mp07-bg-r3-v01)

작성 2026-09-27, 세션 07. 상태: **준비용 brief**. 화면 나누기·배치·재질·사물 모양·출구 그림 ID는 전부 **작성자 설계**이고 domain 데이터가 아니다. `대기`라고 적은 칸은 톤앤매너(분위기 기준)가 확정된 뒤 채운다. R2(`mp07-bg-r2-v01`)를 끝낸 다음 시작한다.

## 1. 근거

- 지역 원본 `modules/top_down_action_rpg/content/regions/region_r3_bellhouse_hospice.json`: topology `gallery_tower_and_undercroft`, size_class `large`, landmark_count 5, traversal_axis `elevation`, 되돌아가기 가능. 출구 5개, 내부 길 1개, revisit_variants 2개.
- 사물 원본 `content/props/prop_r3_*.json` 4개. 회복 `content/recovery/rec_r3_hospice_respawn.json`: 자비 기관 밸브(`prop_r3_mercy_engine_valve`) 자리에서 다시 일어나고, 밸브와 맹세 장부 책상이 처음 상태로 돌아간다.
- 기획: 02 §7.4 (Intake Gallery, Bell Tower, Boiler Undercroft, Mercy Engine, recovery ward가 층별로 이어짐. faith는 종교 상징이 아니라 도움이 늦게 오는 시간을 줄이는 운영 값), 02 §1 (출구가 막힌 이유가 현장에서 보여야 함), 03 지역 표(랜드마크).
- 규칙: 13 §1·§3·§5, 09 §12.1·§12.2·§12.8, 09 §3.1 (플레이어 기준점 (640,418)), 09 §5.1 (대화 띠 y=552..720), IMAGE_ASSET_WORKFLOW §3, `tin_mass_production/COMMON.md`.

## 2. 출력·시점·크기

R2 brief §2와 같다. 요약:

- 화면 한 장 = 논리 1280×720 = 원본 2560×1440, sRGB. 좌표는 논리 좌표의 바닥면 위치.
- 지면 기준 60° 정사영, 방위 고정. 바닥 가로 1 m = 원본 180 px, 깊이 ×0.866. 서 있는 높이 1 m ≈ 원본 110 px (플레이어 몸 약 186 px = 1.7 m).
- 조명: 위에서 퍼지는 빛, 넓은 면 명도 분리, 발밑 접촉 그림자. 빛 방향은 시험 작업과 같게. 세기·색온도·어둡기: `대기`.
- 레이어 (13 §1): `base_clean`을 사물 없이 먼저 그리고, `master_composite` = base + 첫 방문 모습의 사물(처음에 숨은 사물은 뺌) + 출구·내부 길 `closed` + foreground. `preview_reassembled`는 preview 폴더의 검수용.
- 사물·출구 PNG: 투명, 원본 2배, 그림 둘레 여백 64 px, 접촉 그림자 `_shadow.png` 따로, 옆 `.json`에 구역 ID·논리 위치·피벗·상태.
- 피벗: 바닥에 선 것 = 앞쪽 바닥선 가운데 / 벽에 붙은 것 = 바로 아래 벽 밑선 / 머리 위(`overhead`) = 매달린 물체 바로 아래 바닥점 / 출구·내부 길 = 통로 문턱 가운데.
- 좌표는 제안값이다. 길 폭과 계단 위치를 지키는 안에서 조정하고, 바꾼 값은 JOB.md에 적는다.

## 3. 화면 구역 나누기

size_class large, 랜드마크 5, 출구 5, 내부 길 1, 이동 축이 높이(`elevation`)라서 층마다 한 화면으로 나눈다. 층 사이는 계단으로 이어진다. 계단은 새 route가 아니다(새 route ID를 만들지 않는다).

| 구역 ID | 층 | 랜드마크 | 출구·내부 길 | 사물 |
|---|---|---|---|---|
| `r3_a_intake_gallery` | 1층 (첫 화면) | Intake Gallery | E03 Mercy Causeway (남, H0로), E17 Water Ambulance Bridge (동, R2로) | mana_profile_board |
| `r3_b_bell_tower_ward` | 2층 | Bell Tower, recovery ward | E06 Quiet Ward Passage (서, R1로), E10 Bell Cable Lift (북동, R4로) | latency_bell, vow_ledger_desk |
| `r3_c_boiler_undercroft` | 지하 | Boiler Undercroft, Mercy Engine | E11 Care Train (동, R5로), 내부 길 `boiler_undercroft_lift` | mercy_engine_valve |

- 계단 연결: A 북쪽 벽 가운데 올라가는 계단 x=620..780 → B 아래쪽 도착 x=620..780. A 북동쪽 바닥 계단 구멍 x=960..1100 → C 북서쪽 도착 x=60..220. 도착점의 계단 폭과 재질은 양쪽 그림에서 같게.
- 화면 위쪽에는 다음 목적지가 보이게 한다: A 위쪽에 올라가는 계단, B 위쪽에 케이블 승강기, C 위쪽에 자비 기관.

## 4. 구역별 배치와 정보 등급

### A `r3_a_intake_gallery` — 접수 회랑 (1층)

| 요소 | 위치 (논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| Mercy Causeway 입구 (E03) | 아래 가장자리 x=560..720, y=600..720 | 길찾기·상황 이해 | 둑길 끝은 base, 봉인 창살문은 출구 사물 |
| 접수 회랑 바닥 (타일) | x=0..1280, y=240..600 | 길찾기·상황 이해 | base |
| 북쪽 벽과 기둥 줄 | 벽 앞면 y=150..200, 기둥 x=100..1180, 간격 약 180 | 길찾기·상황 이해 | base |
| 방출 프로필 판 | 북쪽 벽, 피벗 (400,200) | 증거·직접 상호작용 | `prop_r3_profile_*` |
| 접수 책상과 돌봄 창구 (`service_r3_intake_seal`, `service_r3_care_window` 자리) | 서쪽 x=40..240, y=300..520 | 길찾기·상황 이해 | base, 빈 서식만 |
| 올라가는 계단 (B로) | 북쪽 벽 가운데 x=620..780, y=40..200 | 길찾기·상황 이해 | base |
| 내려가는 계단 구멍 (C로) | x=960..1100, y=250..340, 난간 두름 | 길찾기·상황 이해 | base |
| 들것 경사로 (E17) | 동쪽 x=1140..1280, y=330..470 | 증거·직접 상호작용 | 출구 사물 |
| 들것 바퀴 닳은 자국 | 입구 → 책상 → 경사로 | 분위기 | base, 대비 낮게 |
| 낮은 난간 | x=0..440, y=650..720 | 길찾기·상황 이해 | `foreground_gallery_rail`, 입구를 가리지 않음 |

### B `r3_b_bell_tower_ward` — 종탑과 회복 병동 (2층)

| 요소 | 위치 (논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| 계단 도착 (A에서) | 아래 가장자리 x=620..780, y=600..720 | 길찾기·상황 이해 | base |
| 종탑 우물 (난간 두른 바닥 구멍, 종소리가 아래층까지 내려감) | x=500..820, y=130..340 | 길찾기·상황 이해 | base |
| 지연 종 | 바닥 기준점(피벗) (660,300), 종은 그 위 3.5 m에 매달림 | 증거·직접 상호작용 | `prop_r3_bell_*` (overhead) |
| 회복 병동 (빈 침대 두 줄, 가운데 통로 y=330..400) | x=40..440, y=160..540 | 분위기 | base. 사람 없음, 침대보만 |
| Quiet Ward Passage (E06) | 서쪽 벽 x=0..90, y=300..430, 병동 가운데 통로 끝 | 증거·직접 상호작용 | 출구 사물 |
| 맹세 장부 책상 | 동쪽 벽감, 피벗 (990,350), 바닥 130×70 | 증거·직접 상호작용 | `prop_r3_vow_*` |
| Bell Cable Lift (E10) | 북동쪽 발코니 x=900..1120, y=20..150 | 증거·직접 상호작용 | 출구 사물 |
| 칸막이 병풍 | x=40..400, y=620..720 | 분위기 | `foreground_ward_screens` |

### C `r3_c_boiler_undercroft` — 보일러 지하실과 자비 기관 (지하)

| 요소 | 위치 (논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| 계단 도착 (A에서) | 북서쪽 x=60..220, y=40..180 | 길찾기·상황 이해 | base |
| 지하 바닥 (벽돌) | x=0..1280, y=200..620 | 길찾기·상황 이해 | base |
| 보일러 셋 | 서쪽 x=40..320, y=260..540 | 분위기 | base |
| 북쪽 벽 (관이 지나감) | 벽 앞면 y=150..200 | 길찾기·상황 이해 | base. 밸브가 숨어 있을 때도 관만 지나가는 벽으로 자연스럽게 |
| 자비 기관 밸브 | 북쪽 벽, 피벗 (540,200) | 증거·직접 상호작용 | `prop_r3_valve_*` |
| 자비 기관 (높은 단 위 큰 기계) | x=720..1240, y=20..270, 단 높이 1.5 m | 길찾기·상황 이해 | base. 눈금판에 숫자 없음 |
| 보일러 승강기 뼈대 | 단 앞 (680,280), 바닥 90×90 | 길찾기·상황 이해 | 뼈대는 base, 우리·문은 내부 길 사물 |
| Care Train 승강장 (E11) | 동쪽 x=1080..1280, y=340..520 | 증거·직접 상호작용 | 출구 사물 |
| 앞쪽 배관 | x=640..1280, y=650..720 | 분위기 | `foreground_pipe_run` |

## 5. 사물 (content 4개)

| 사물 · 레이어 · 피벗 | 상태 → 그림 이름 (art_key) | 모양 | 크기 |
|---|---|---|---|
| `prop_r3_latency_bell` · overhead(배우 위) · 종 바로 아래 바닥점 | `ps_struck` → `prop_r3_bell_struck`: 큰 종이 한쪽으로 기울고 추가 몸통에 닿음, 멍에 위 시간 톱니바퀴와 추, 대기 순번 나무 원판 줄이 한쪽 끝에 모여 있음<br>`ps_retimed` → `prop_r3_bell_retimed`: 종이 곧게 멈춤, 톱니바퀴의 핀 위치와 추 개수가 바뀜, 순번 원판 줄이 반대쪽으로 옮겨짐 | 어디서나 보이는 사물(`visible_from any`)이라 윤곽선을 가장 강하게. `_shadow.png`는 바닥의 흐린 그림자 | 종 입 지름 1.4 m (250 px), 종 높이 1.6 m (175 px), 멍에·바퀴 포함 폭 2.2 m |
| `prop_r3_mana_profile_board` · wall · 벽 밑선 | `ps_unmeasured` → `prop_r3_profile_blank`: 벽판에 세로 홈 네 줄, 줄마다 빈 칸<br>`ps_filed` → `prop_r3_profile_filed`: 네 줄에 모양이 서로 다른 말뚝·타일이 서로 다른 높이로 꽂힘(retention·emission·overflow·blocked를 줄마다 다른 모양으로 구분) | 글자 없음 | 폭 1.4 m (250 px), 높이 1.2 m (130 px), 바닥 위 0.8 m |
| `prop_r3_mercy_engine_valve` · wall · 벽 밑선 | `ps_open` → `prop_r3_valve_open`: 관 다발에 달린 큰 바퀴 밸브, 두 칸 레버가 빠른 쪽 멈춤쇠에, 옆 서명판은 빈칸<br>`ps_throttled` → `prop_r3_valve_throttled`: 바퀴가 돌아감, 레버가 안정 쪽, 잠금 꼬리표와 죔쇠 | 처음에 숨는 사물(`hidden_until_condition`, 지역 hidden_state). 회복해서 다시 일어나는 자리 | 바퀴 지름 0.9 m, 전체 폭 1.4 m (250 px), 높이 1.6 m (175 px) |
| `prop_r3_vow_ledger_desk` · prop · 앞쪽 바닥선 가운데 | `ps_open` → `prop_r3_vow_open`: 비스듬한 필기대 위에 펼친 장부(빈 줄), 펜<br>`ps_separate` → `prop_r3_vow_separate`: 장부 사이를 서로 다른 색 끈 셋이 나눔(care·kin·romance 줄 구분) | 글자 없음. 회복하면 처음 상태로 돌아감 | 폭 1.1 m (200 px), 깊이 0.6 m, 높이 1.1 m (120 px) |

## 6. 출구와 내부 길

그림 ID는 작성자 설계다(`prop_exit_*`, `prop_route_*`). 상태는 `closed`/`open` 두 장씩. 닫힌 그림은 왜 못 지나가는지 현장에서 보이게 한다(02 §1).

| 구역 | 출구 (content) | closed | open | 피벗 |
|---|---|---|---|---|
| A | `route_e03_mercy_causeway` → H0, gate G0 + care token 1개 보유 | `prop_exit_r3_e03_mercy_causeway_closed`: 접수 봉인 창살문이 닫히고 봉인을 꽂는 홈이 빔 | `…_open`: 창살문이 열림 | (640,650) |
| A | `route_e17_water_ambulance_bridge` → R2, gate G2 + R2 뿌리다리 `ps_raised` | `prop_exit_r3_e17_water_ambulance_bridge_closed`: 들것 경사로가 사슬로 들려 있음 | `…_open`: 경사로가 내려와 물가 다리로 이어짐 | (1230,400) |
| B | `route_e06_quiet_ward_passage` → R1, gate G1, STORY_FORCED | `prop_exit_r3_e06_quiet_ward_passage_closed`: 두꺼운 두 짝 문에 빗장 | `…_open`: 문이 열리고 어두운 복도가 보임 | (40,400) |
| B | `route_e10_bell_cable_lift` → R4, gate G3 | `prop_exit_r3_e10_bell_cable_lift_closed`: 케이블만 있고 칸이 없음, 발코니 문 닫힘 | `…_open`: 케이블 칸이 붙고 문이 열림 | (1010,150) |
| C | `route_e11_care_train` → R5, gate G3 | `prop_exit_r3_e11_care_train_closed`: 승강장 문이 닫히고 차량이 없음 | `…_open`: 작은 객차 한 칸이 멈춤판에 붙고 문이 열림 | (1200,470) |
| C | 내부 길 `boiler_undercroft_lift` (지하실 → 자비 기관, 밸브 `ps_throttled` 필요) | `prop_route_r3_boiler_undercroft_lift_closed`: 승강기 우리가 위에 있고 문이 잠김 | `…_open`: 우리가 내려오고 문이 열림 | (680,280) |

## 7. 다시 방문 (revisit_variants)

- `rv_after_latency_receipt` (지연 종 `ps_retimed`): 종 `retimed` 그림으로 보여 준다.
- `rv_after_profile_filed` (방출 프로필 판 `ps_filed`): 판 `filed`와 밸브 `throttled` 그림으로 보여 준다.
- 바뀌는 것은 모두 사물 상태 그림이 맡는다. base와 foreground는 바꾸지 않는다.

## 8. 재질과 색

H0(마른 회보라 광물 바닥), R2(젖은 나무·물·개흙)와 한눈에 구별되게 한다. 윤곽선·그림자·명암 방식과 공통 색은 `palette_h0.json` 그대로. 지역 색은 시작할 때 `palette_r3.json`으로 만든다. 아래는 재질과 색의 관계이고, 정확한 색 값은 `대기`.

- 1층: 문질러 닦은 옅은 회청색 유약 타일, 아이보리 줄눈. 석회 칠한 뼈색 회벽과 옅은 돌기둥.
- 2층: 밝은 널마루, 쇠 침대틀과 흰 리넨. 종탑 난간은 나무와 쇠.
- 지하: 그을린 붉은 벽돌 바닥과 아치, 녹슨 검붉은 쇠 보일러, 구리 관. 자비 기관은 쇠·청동에 유리 눈금판(숫자 없음).
- 종: 따뜻한 종 청동. H0의 탁한 청동보다 붉고 밝게.
- 분위기 밀도, 명도 범위, 채도: `대기`.

## 9. 유지·변형, 원본

- 유지: 시험 작업 `h0-icon-collage-v01`의 조합 방식과 칠하기 규칙(아이콘을 잘라 겹치기, 그림자 쪽이 굵은 짙은 자주 윤곽선, 초승달 명암, 발밑 접촉 그림자, 붓자국 설정 그대로), 60° 계산, R2와 같은 크기 기준.
- 변형: 바닥·벽·쇠붙이 재질과 색(지역 구분), 사물 모양(§5·§6).
- 원본: 모양 재료는 `addons/at-icons/node2d` SVG(MIT). 화풍은 시험 작업 결과를 눈으로 보고 맞춘다(candidate, 승인 아님). Gold Standard: 없음.

## 10. 금지

- 사람, 적, 시체, 동물, 눈, 이빨, 혈흔, 왕관 모양, 무작위 기괴 장식. 병동 침대에 사람 형태를 넣지 않는다.
- 실제 종교 상징(십자가, 후광 등). faith는 종·톱니·케이블 같은 장치로만 보여 준다.
- 읽을 수 있는 글자와 숫자(장부·서식·눈금판·순번 원판 포함), UI, 격자, 워터마크.
- BLACK SOULS·Alice 고유 지형·상징 복제.
- 원래 아이콘 모양이 그대로 읽히는 조각(알림 종, 톱니, 사슬, 문, 아치 등). 더 잘게 자르거나 겹친다.
- 공용 사물 3개(`art_prop_route_marker`, `art_prop_recovery_anchor`, `art_prop_magic_concentration_device`)와 아이템을 배경에 그려 넣기.
- 주 통로·계단·출구 문턱을 foreground나 장식으로 가리기.

## 11. 그리지 않고 비워 둘 자리

- 길 표시(`art_prop_route_marker`, 세션 01): 출구 옆. A (760,650), (1130,320) / B (110,300), (880,170) / C (1060,360).
- 회복 닻(`art_prop_recovery_anchor`, 세션 01): 자비 기관 밸브 앞 (540,300).
- 마력 농도 장치: R3 지역 JSON에 농도 항목이 없어서 자리 없음.
- NPC가 설 빈 자리: A 접수 책상 앞 (300,420) — 첫 대화 `conv_r3_intake_triage` 자리. B 병동 가운데 통로.

## 12. 만들 파일 (그림 29장 + 그림자·검수)

| 묶음 | 파일 | 장수 |
|---|---|---|
| 배경 | 구역마다 `master_composite`, `base_clean`, foreground 1장 (A `foreground_gallery_rail`, B `foreground_ward_screens`, C `foreground_pipe_run`) | 9 |
| 사물 | §5의 상태 그림 (종 2, 프로필 판 2, 밸브 2, 책상 2) + 각 `_shadow.png` | 8 |
| 출구·내부 길 | §6의 closed/open (출구 5 × 2, 내부 길 1 × 2) | 12 |
| 검수 | 구역마다 `preview_reassembled` 3장, 1280×720 게임 화면 미리보기 3장, 모아 보기 시트 | — |

미리보기에는 크기 확인용으로 플레이어 그림을 합성만 한다(배경에 굽지 않음). 캐릭터 형식이 8방향으로 바뀌므로 그때 확정된 플레이어 그림을 쓴다.

## 13. 검수

- 하드 게이트: 크기(배경 2560×1440 불투명, 사물 투명 PNG), 네 귀퉁이 알파, 피벗·64 px 여백, 글자 없음, 출처·해시 기록.
- 구도: 각 층에서 주 통로와 계단, 다음 이동 방향이 먼저 읽히는가. 증거 사물은 윤곽선이 강하고 분위기 요소(침대, 보일러)는 대비가 낮은가.
- 계단 연결: A↔B, A↔C 도착점의 폭·재질이 맞는가.
- 대화 띠(y=552..720)가 올라와도 프로필 판·종·책상·밸브가 가려지지 않는가.
- 머리 위 종: 배우 위에 그려도 주 통로의 플레이어가 완전히 가려지지 않는가.
- 상태 그림: 같은 피벗에 겹쳤을 때 흔들림이 없고 상태끼리 한눈에 구별되는가. 숨는 사물(밸브)을 뺀 base가 자연스러운가.
- 크기: 미리보기에서 플레이어 키 대비 허리 높이·문 높이가 맞는가. 캔버스 가장자리에서 잘린 곳이 없는가.
- 실제 게임 1280×720 / 1920×1080 / 2560×1440: 게임 연결 금지라 `not_run`.

## 14. 대기 (톤앤매너 확정 뒤 채움)

- `palette_r3.json` 색 값, 조명 세기·색온도·어둡기, 분위기 밀도.
- 새 기준이 화풍 기준 그림이나 크기 기준을 바꾸면 그 부분만 고친다. 배치·사물 목록·레이어 구성은 그대로 쓴다.
