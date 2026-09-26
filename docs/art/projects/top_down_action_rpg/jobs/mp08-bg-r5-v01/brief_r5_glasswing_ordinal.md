# R5 Glasswing Ordinal — 배경·사물 brief (mp08-bg-r5-v01)

작성: 2026-09-27, 세션 08. 상태: **준비 단계**. 분위기 기준(톤앤매너)과 캐릭터 규격을 다시 정하는 중이라 색·분위기 항목은 초안이다. 기준이 확정되면 이 문서를 먼저 고친 뒤 제작한다. 배치·치수·재질·모양은 전부 **작성자 설계**이며 domain 데이터를 바꾸지 않는다. R4 brief(`../mp08-bg-r4-v01/brief_r4_crownwell_archive.md`)와 같은 배율·화풍 규칙을 쓴다.

## 1. 근거
- region: `modules/top_down_action_rpg/content/regions/region_r5_glasswing_ordinal.json` — topology `industrial_loop_and_gantry`, size_class `large`, landmark_count 5, traversal_axis `route`, internal_route `gantry_cradle_descent` 1개, 출구 6개.
- 지역 기획: `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/02_WORLD_STATE_AND_ROUTES.md` §7.6(R5), §8.6(RC-05), §5.2(E05/E11/E12/E14/E15/E18), §6.1(G0/G3/G4/G5).
- 사물: `content/props/prop_r5_boot_contract_board.json`, `prop_r5_repair_bench_rack.json`, `prop_r5_supply_rack.json`, `prop_r5_gantry_cradle.json`.
- 규칙: 13 §1·§3·§5, 09 §3.1·§12.1·§12.2·§12.8, `docs/IMAGE_ASSET_WORKFLOW.md` §3, `tin_mass_production/COMMON.md`.
- art key: `art_world_r5_glasswing_ordinal`(09 §12.10). 이 키는 아래 네 구역 묶음 전체를 가리킨다.

## 2. 용도와 실제 게임 상태
- 납품 유형: 배경 + 독립 소품(사물 상태 그림, 출구·내부 길 막이 레이어).
- 용도: R5 필드 배경 — field normal/focus, 전투 전환(`field_pressure` lethal), 재방문.
- 현재 모듈은 사물·NPC·출구를 4열 임시 격자(`systems/field_controller.gd`의 `_anchor_position`)에 놓는다. 이 brief 배치는 그 격자를 따르지 않는 작성자 설계이고 도메인 좌표로 자동 승격하지 않는다. 게임에 연결하지 않는다.

## 3. 시점·배율·조명
- R4 brief 3절과 같다: 60° 정사영, 방위 고정, 바닥 깊이 ×0.866, 높이 ×0.5. 사람 1.7 m = 원본 192 px, 원본 가로 1 m = 226 px, 깊이 1 m = 196 px, 높이 1 m = 113 px.
- 대표 높이(원본 px): 난간·작업대 0.9~1.0 m = 102~113, 승강장 0.3 m = 34, 부팅 틀 2.4 m = 271, 갠트리 다리 5 m = 565, 벽 3.2 m = 362.
- 조명: 위에서 오는 확산광, 빛 방향은 `palette_h0.json`의 `light`와 같게. 구덩이·화덕의 주황빛은 약하게 해서 사물보다 눈에 띄지 않게 한다.

## 4. 구역 나누기
size_class large, 랜드마크 5개, 출구 6개, 내부 길 1개라 **2×2 네 구역**으로 나눈다. 네 구역이 가운데의 큰 주조 구덩이(`Ordinal core`, 작성자 설계)를 시계 방향으로 둘러싸서 기획의 industrial loop가 된다: Foundry Lane → Boot Hall → Repair Bench·Support Clinic → Labor Yard·Supply Gantry → Foundry Lane.

랜드마크 5개: Foundry Lane, Boot Hall, Repair Bench, Labor Yard, Supply Gantry(Gantry Cradle 포함). Support Clinic은 기획 목록에는 있지만 landmark_count가 5라서 Repair Bench 구역의 보조 건물로 둔다.

| 구역 ID | 자리 | 장소 | 출구 | content 사물 |
|---|---|---|---|---|
| `bg_r5_foundry_lane` | 북서 | Foundry Lane | E05 Foundry Tram, E14 Under-Rail Shunt | — |
| `bg_r5_boot_hall` | 북동 | Boot Hall | E12 Courier Shaft | `prop_r5_boot_contract_board` |
| `bg_r5_repair_clinic` | 남동 | Repair Bench, Support Clinic | E11 Care Train | `prop_r5_repair_bench_rack` |
| `bg_r5_labor_yard_gantry` | 남서 | Labor Yard, Supply Gantry | E15 Supply Gantry, E18 Folding School Approach, 내부 길 `gantry_cradle_descent` | `prop_r5_supply_rack`, `prop_r5_gantry_cradle` |

- 구역끼리 잇는 통로(양쪽 구역에서 같은 범위, 막이 없음): 북서 동쪽 끝 ↔ 북동 서쪽 끝 y 220..440 / 북동 남쪽 끝 ↔ 남동 북쪽 끝 x 540..760 / 남동 서쪽 끝 ↔ 남서 동쪽 끝 y 300..520 / 남서 북쪽 끝 ↔ 북서 남쪽 끝 x 520..740. 통로의 바닥 재질은 경계 양쪽에서 이어지게 그린다.
- 주조 구덩이는 네 구역의 안쪽 모서리에 4분의 1씩 보인다: 북서 x 880..1280·y 480..720, 북동 x 0..400·y 480..720, 남동 x 0..400·y 0..240, 남서 x 880..1280·y 0..240. 난간이 있는 낮은 테두리 안쪽으로 내려가는 구덩이라서 60° 시점에서 다른 물체를 가리지 않는다.
- 구역 경계는 새 route가 아니다. 좌표는 전부 구역 논리 좌표(0..1280, 0..720), 원본 px = 논리 × 2.


## 5. 구역별 배치와 정보 등급
등급: **증거·직접 상호작용** / **길찾기·상황 이해** / **분위기**. 표에 없는 물체는 분위기로만 취급하고 대비를 낮춘다(13 §3). 주 통로 폭은 논리 200 이상, 통로 위에 물체·진한 파편·글자를 두지 않는다.

### 5.1 `bg_r5_foundry_lane` — Foundry Lane (북서)
| 요소 | 위치(논리) | 등급 | 레이어 |
|---|---|---|---|
| 북쪽 주조장 벽(벽 밑선 y 190)과 화덕 입구 셋 | y 0..190, 화덕 빛은 약하게 | 벽은 길찾기·상황 이해, 화덕은 분위기 | base |
| E05 Foundry Tram 종점 | 서쪽 끝에서 들어오는 선로 y 250..330, 완충 멈춤틀 x 470, 승강장(높이 0.3 m) x 0..470·y 330..410 | 길찾기·상황 이해 | 선로·승강장 base, 승강장 입구 문(x 470..530) exit 레이어 |
| E14 Under-Rail Shunt | 남서쪽 x 60..330·y 480..660, 서쪽으로 내려가는 경사 도랑과 좁은 선로 | 길찾기·상황 이해 | 도랑 base, 도랑 머리(x 330..390)의 신호 팔·퓨즈 상자 exit 레이어 |
| Foundry Lane 주 통로 | 남쪽 통로(x 520..740)에서 북쪽 y 220..460으로, 다시 동쪽 통로(y 220..440)로 | 길찾기·상황 이해 | base |
| 주조 구덩이 4분의 1 | x 880..1280, y 480..720 | 길찾기·상황 이해 | base |
| 도가니 수레, 주괴 더미 | 북쪽 벽 앞 x 560..860, y 190..220 | 분위기 | base |
| 앞쪽 낮은 배관 묶음 | x 0..260, y 670..720 | 분위기 | foreground |

### 5.2 `bg_r5_boot_hall` — Boot Hall (북동)
| 요소 | 위치(논리) | 등급 | 레이어 |
|---|---|---|---|
| 북쪽 홀 벽(벽 밑선 y 190)과 높은 유리 날개 창 | y 0..190 | 벽은 길찾기·상황 이해, 창은 분위기 | base |
| Boot Contract Board | 북쪽 벽면, 중심 (420, 100). 판 2.4 m × 1.3 m, 아래 가장자리가 바닥에서 0.9 m | 증거·직접 상호작용 | prop(벽) |
| 부팅 틀 셋(비어 있는 2.4 m 선 틀) | 벽 앞 x 620..960, y 200..290 | 길찾기·상황 이해(Boot Hall임을 알림) | base |
| E12 Courier Shaft 수갱 머리 | 중심 (1120, 280), 바닥 200×160, 도르래 틀 높이 2.2 m | 길찾기·상황 이해 | 틀 base, 뚜껑·봉인 막대 exit 레이어 |
| 주 통로 | 서쪽 통로(y 220..440)에서 동쪽 x 760까지, 다시 남쪽 통로(x 540..760)로. 수갱으로 가는 갈래길 | 길찾기·상황 이해 | base |
| 주조 구덩이 4분의 1 | x 0..400, y 480..720 | 길찾기·상황 이해 | base |
| 벽 공구 걸이, 케이블 감개 | x 900..1260, y 440..640 | 분위기 | base |
| 앞쪽 머리 위 케이블 선반 | x 980..1280, y 670..720 | 분위기 | foreground |


### 5.3 `bg_r5_repair_clinic` — Repair Bench, Support Clinic (남동)
| 요소 | 위치(논리) | 등급 | 레이어 |
|---|---|---|---|
| 주조 구덩이 4분의 1 | x 0..400, y 0..240 | 길찾기·상황 이해 | base |
| Support Clinic 건물 앞벽(벽 밑선 y 200), 문 하나, 커튼 친 창 | x 820..1280, y 0..200, 문 x 980..1080 | 길찾기·상황 이해(진료소 자리. 상호작용 의미 없음) | base |
| Repair Bench Rack | 중심 (1000, 400), 바닥 270×90, 선반 높이 1.9 m | 증거·직접 상호작용 | prop |
| 주 통로 | 북쪽 통로(x 540..760)에서 y 300..520으로, 다시 서쪽 통로(y 300..520)로 | 길찾기·상황 이해 | base |
| E11 Care Train | 남쪽 승강장(높이 0.3 m) x 700..1280·y 580..660, 동쪽 끝으로 나가는 선로 y 660..720 | 길찾기·상황 이해 | 선로·승강장 base, 승강장 서쪽 입구 문(x 640..700) exit 레이어 |
| 부품 상자 | 작업대 옆 | 분위기 | base |
| 앞쪽 낮은 손잡이 난간 | x 0..300, y 670..720 | 분위기 | foreground |

### 5.4 `bg_r5_labor_yard_gantry` — Labor Yard, Supply Gantry (남서)
| 요소 | 위치(논리) | 등급 | 레이어 |
|---|---|---|---|
| 주조 구덩이 4분의 1 | x 880..1280, y 0..240 | 길찾기·상황 이해 | base |
| 적재대(높이 1.0 m) | 윗면 x 120..480·y 190..300, 앞면은 y 356까지 | 길찾기·상황 이해 | base |
| Supply Rack | 적재대 위 중심 (300, 250), 바닥 226×70, 높이 1.8 m | 증거·직접 상호작용 | prop |
| 내부 길 `gantry_cradle_descent` 철 계단 | 적재대 앞면에서 x 330..430·y 356..470으로 내려감 | 길찾기·상황 이해 | 계단 base, 계단 머리 사슬문 exit 레이어 |
| Gantry Cradle | 중심 (270, 560), 바닥 226×100, 높이 1.1 m | 증거·직접 상호작용 | prop |
| 갠트리 다리 둘과 머리 위 들보 | 다리 (40, 200)·(40, 640), 들보는 서쪽 띠 x 0..110 | 다리는 길찾기·상황 이해, 들보는 분위기 | 다리 base, 들보 foreground |
| E15 Supply Gantry | 남서쪽 x 120..260·y 620..720, 갠트리 위로 올라가는 철 계단 | 길찾기·상황 이해 | 계단 base, 계단 발치 잠금문 exit 레이어 |
| E18 Folding School Approach | 남쪽 끝 x 700..920·y 620..720, 남쪽으로 내려가는 지붕 덮인 접근로 | 길찾기·상황 이해 | 접근로 base, 격자문 exit 레이어 |
| 주 통로 | 동쪽 통로(y 300..520)에서 서쪽으로, 다시 북쪽 통로(x 520..740)로. 요람·E15·E18로 가는 갈래길 | 길찾기·상황 이해 | base |
| Labor Yard 작업 칸 선(글자 없음), 상자 더미, 집계 기둥 | x 1000..1260, y 540..700 | 분위기 | base |

### 5.5 다른 세션 담당 사물이 놓일 자리 (그리지 않고 바닥만 비워 둠)
- `art_prop_route_marker`: 출구마다 하나, 반지름 40. foundry_lane — E05 옆 (580, 400), E14 옆 (420, 470). boot_hall — E12 옆 (980, 330). repair_clinic — E11 옆 (620, 560). labor_yard_gantry — E15 옆 (330, 680), E18 옆 (960, 600).
- `art_prop_magic_concentration_device`: labor_yard_gantry (640, 600), 반지름 50. E18이 concentration sample을 요구하므로 그 앞에 둔다.
- `art_prop_recovery_anchor`: R5에는 recovery 파일이 없어서 두지 않는다.


## 6. 사물 상태 그림
투명 PNG, 원본 2배, 안전 여백 논리 32(원본 64), 접촉 그림자는 별도 `_shadow.png`. 파일 이름은 content의 `art_key`. 캔버스는 계획값이고 build 뒤 실제 값을 JOB.md에 적는다.

| content ID | 상태 → 파일 | 모습 | 캔버스 / 피벗(원본 px) |
|---|---|---|---|
| `prop_r5_boot_contract_board`(벽) | `ps_unsigned` → `prop_r5_board_unsigned` | 벽에 붙은 넓은 계약판. full·staged·refused 세 칸이 한 판에 나란히. 칸마다 빈 계약 쪽지와 빈 서명 네모, 글자 없음 | 680×300 / (340, 236) 판 아래 가운데(벽면 부착점) |
| | `ps_staged` → `prop_r5_board_staged` | 가운데 칸에 청동 집게로 반쯤 끼운 부팅 표, 그 옆의 빈 소유자 칸이 두드러짐 | 같음 |
| | `ps_refused` → `prop_r5_board_refused` | 셋째 칸을 가로지르는 거절 띠가 핀으로 고정되어 그대로 남음(찢거나 지우지 않음 = 선택으로 보관) | 같음 |
| `prop_r5_repair_bench_rack` | `ps_open` → `prop_r5_bench_open` | 작업대와 4단 선반. 단마다 퓨즈, 배터리, 접은 작업복(이름표 없음), 청동 관절 대체 부품(살·피 없음) | 680×520 / (340, 456) 작업대 앞면 바닥 가운데 |
| | `ps_residue_held` → `prop_r5_bench_residue` | 넷째 단에 진료소에서 돌려받은 매질 찌꺼기(탁한 유리질 덩어리가 든 봉인 쟁반). 나머지는 open과 같음 | 같음 |
| `prop_r5_supply_rack` | `ps_sealed` → `prop_r5_rack_sealed` | 세 칸(말린 직물 blank, 접은 종이 묶음, 칼집에 든 칼날)을 가로지르는 Ordinal 봉인 띠 | 580×480 / (290, 416) 선반 앞면 바닥 가운데 |
| | `ps_issued` → `prop_r5_rack_issued` | 봉인 띠가 끊겨 늘어지고 칸이 절반쯤 빔 | 같음 |
| `prop_r5_gantry_cradle` | `ps_empty` → `prop_r5_cradle_empty` | 강철 받침틀. 큰 받침 하나(crown gear 자리)와 작은 받침 둘(배터리 자리), 느슨한 끈 | 580×480 / (290, 416) 앞면 바닥 가운데 |
| | `ps_loaded` → `prop_r5_cradle_loaded` | 큰 청동 톱니바퀴 하나와 원통 배터리 둘이 끈으로 묶임 | 같음 |

- `prop_r5_supply_rack`은 `ps_sealed`에 visible:true인데 `hidden_until_condition`은 봉인된 동안 숨긴다고 적혀 있고, hidden_state의 부분 공개 대상이기도 하다. 두 상태를 모두 그리고, 기준 합성본(처음 상태)은 `hidden_until_condition`을 따라 선반을 빼서 적재대만 보이게 한다.

## 7. 출구와 내부 길
여섯 출구 모두 route_state `conditional`, 내부 길도 `conditional`. 구조물은 base에 두고 막는 부분만 막이 레이어(투명 PNG, 원본 2배)로 뺀다. `locked`·`conditional`·`closed`는 `_closed`, `open`·`redirected`·`debt-bearing`은 `_open`.

| edge | 목적지 / gate / 필요한 것 | 구역 | base 구조 | `_closed` / `_open` |
|---|---|---|---|---|
| E05 Foundry Tram | H0 / G0 / power cell 1 | foundry_lane 서쪽 | 선로, 완충 멈춤틀, 승강장 | 승강장 입구 미닫이문 닫힘 + 빈 전지 꽂이 기둥 / 문 열리고 전지가 꽂힘 |
| E14 Under-Rail Shunt | R6 / G5 / transformation fuse | foundry_lane 남서쪽 | 선로 밑으로 내려가는 경사 도랑과 좁은 선로 | 신호 팔 내려감 + 빈 퓨즈 상자 두 칸 / 팔 올라가고 퓨즈 꽂힘 |
| E12 Courier Shaft | R4 / G4 / sealed plate | boot_hall 북동쪽 | 네모 수갱 머리와 도르래 틀(R4 쪽과 같은 설계) | 뚜껑 닫히고 봉인 막대 / 뚜껑 열리고 운반 바구니 |
| E11 Care Train | R3 / G3 / care ration | repair_clinic 남쪽 | 동쪽으로 나가는 선로와 낮은 승강장 | 승강장 문 닫힘 + 빈 배급 쟁반 세 칸 / 문 열리고 쟁반 채워짐 |
| E15 Supply Gantry | R7 / G5 / crown gear 1, battery 2 | labor_yard_gantry 남서쪽 | 갠트리 위로 올라가는 철 계단 | 계단 발치 잠금문 + 빈 톱니 모양 자물쇠 / 문 열림 |
| E18 Folding School Approach | R8 / G5 / concentration sample 1, craft credit 1 (STORY_FORCED) | labor_yard_gantry 남쪽 | 남쪽으로 내려가는 지붕 덮인 접근로 | 주름처럼 접히는 격자문이 펼쳐져 막음 / 격자문이 접혀 한쪽으로 모임 |
| 내부 길 `gantry_cradle_descent` | Supply Rack → Gantry Cradle / 요람 `ps_loaded` | labor_yard_gantry 서북쪽 | 적재대에서 내려오는 철 계단 | 계단 머리 사슬문 걸림 / 사슬이 풀려 늘어짐 |

- 파일: `exit_r5_e05_foundry_tram_closed` / `_open`, `exit_r5_e14_under_rail_shunt_*`, `exit_r5_e12_courier_shaft_*`, `exit_r5_e11_care_train_*`, `exit_r5_e15_supply_gantry_*`, `exit_r5_e18_folding_school_approach_*`, `route_r5_gantry_cradle_descent_closed` / `_open`. 이 ID들은 이 작업의 설계 ID다.
- E18 격자문에 학교 문장·문양을 넣지 않는다. 접힌 주름 모양만 쓴다.

## 8. 재방문 상태
| variant | 바뀌는 그림 | 구역 |
|---|---|---|
| `rv_after_staged_boot` | `prop_r5_board_staged`, `prop_r5_bench_residue` | boot_hall, repair_clinic |
| `rv_after_supply_rack` | `prop_r5_rack_issued`, `prop_r5_cradle_loaded`, 내부 길 `_open` | labor_yard_gantry |

`prop_r5_board_refused`는 재방문 variant 목록에는 없지만 G5 결과 중 하나라서 상태 그림으로 만든다.

## 9. 레이어 (구역마다, 13 §1)
R4 brief 9절과 같다: `base_clean`(2560×1440 불투명, 사물·막이·전경 없음, 뒤쪽 표면까지 처음부터 그림), `prop_*`, `exit_*`·`route_*` 막이, `foreground_*`(2560×1440 투명, 주 통로·사물·출구를 가리지 않음), `master_composite`(처음 상태: 사물 첫 상태, 막이 `_closed`, 숨김 선반 제외, 전경 포함), `preview_reassembled_<variant>`(8절 상태), `preview_<구역>_1280x720`(크기 확인용 플레이어 한 명).


## 10. 재질과 색 (초안 — 톤앤매너 확정 뒤 다시 정함)
- 지역 인상: 변환·노동 기관. 쇠판·유리·선로·갠트리, 열이 남는 주조장(남는 자원 heat token).
- 바닥: 그을린 청회색 줄무늬 철판에 녹빛 이음새와 기름 얼룩. H0의 밝은 광물 바닥, R4의 차가운 점판암과 한눈에 달라 보이게 한다. 단 중간 밝기로 둬서 캐릭터 옷보다 확실히 밝게 유지한다.
- 벽: 리벳 박힌 쇠판 + 옅은 초록빛 유리판(Glasswing).
- 기능 부품: 구리와 청동. 전지·퓨즈는 작은 청록 포인트.
- 빛: 주조 구덩이와 화덕의 약한 주황빛. 사물보다 밝지 않게, 통로를 가리는 빛 웅덩이 없이.
- 그대로 쓰는 것(H0와 같음): `ink` 윤곽선, `shade_tint`, `shadow_contact`, 빛 방향, 선 굵기, 붓자국 설정.
- 새 색은 자기 폴더 `recipes/palette_r5.json`에 둔다. H0에서 바꾼 점은 JOB.md에 적는다.

## 11. 유지할 것과 바꿀 것
- 유지: 시험 작업 `h0-icon-collage-v01`의 화풍, 붓자국 설정, 60° 계산, R4와 같은 배율.
- 바꿈: 바닥·벽 재질과 색(지역 구분).
- 톱니바퀴·전지처럼 content가 요구하는 물건은 알아볼 수 있게 두되, 원래 아이콘 모양이 통째로 읽히는 조각(바람개비, 지도 연결선, 아치 등)은 잘게 자르거나 겹쳐서 숨긴다.

## 12. 입력과 Gold Standard
R4 brief 12절과 같다. 모양 재료는 at-icons node2d SVG(MIT), 픽셀 입력 없음, 시험 작업 결과는 눈으로만 비교, 크기 확인용 플레이어 한 장만 `input/`에 복사. 활성 Gold Standard 없음.

## 13. 금지
- 사람, 적, 시체, 눈(eye), 혈흔. 부팅 틀·수리대·진료소에 몸이나 살점을 넣지 않는다(대체 부품은 청동 관절로만).
- 읽을 수 있는 글자·숫자·문장. 계약판·표·봉인 띠는 빈 칸이나 뜻 없는 선으로만.
- UI, HUD, focus 표시, 대화창, 워터마크, 격자·타일 이음 표시.
- 원작(BLACK SOULS, Alice) 고유 지형·상징·실내, 학교 문장·문양.
- content에 없는 증거·상호작용 의미를 배경 물체에 붙이기. 무작위 기괴 장식.
- 공용 사물 3개와 아이템을 배경에 그려 넣기(자리만 비움).

## 14. 검수
- 하드 게이트: 크기, 알파(투명 그림은 네 귀퉁이 알파 0, 배경은 불투명), 피벗, 안전 여백, 파일 이름 = 자산 ID, 글자·워터마크 없음, 사용 아이콘 해시 기록, 가장자리에서 잘린 곳 없음.
- 레이어: `master_composite`와 같은 좌표로 다시 합쳤을 때 어긋남 없음. 들보·전경이 주 통로·사물·출구를 가리지 않음.
- 판독: 1280×720 미리보기에서 출구 방향, 상호작용 사물, 주 통로가 먼저 읽히는가. 네 구역을 이어 놓았을 때 구덩이 테두리와 통로가 경계에서 맞는가(네 장을 2×2로 붙인 확인용 시트를 preview에 만든다). 사람 키 대비 작업대·난간·문 높이가 맞는가.
- 실제 게임 화면 1280×720 / 1920×1080 / 2560×1440 검수와 field focus·전투 전환 확인은 게임 연결 금지 범위라 `not_run`으로 기록한다.
- 결과는 전부 candidate. 승인은 사용자만 한다.
