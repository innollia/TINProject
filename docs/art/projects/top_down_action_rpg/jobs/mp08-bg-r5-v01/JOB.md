# mp08-bg-r5-v01 — R5 Glasswing Ordinal 배경과 사물 (아이콘 조합)

상태: **준비만 함.** `COMMON.md` 맨 위 '준비만 할 것' 줄이 남아 있어서 레시피 작성, 도구 복사, build는 하지 않았다. 결과물 없음. R4(`mp08-bg-r4-v01`)를 끝낸 뒤 시작한다.

| 필드 | 값 |
|---|---|
| 목적 | environment_master + clean_base + prop + occluder + state_variant. R5 네 구역 배경과 그 지역 사물·출구·내부 길 |
| 근거 결정 | 사용자 결정 2026-09-27: 아이콘 조합 방식 양산, 세션 10개 분담, 결과는 전부 candidate(14 §1, COMMON) |
| 소유권 | 세션 08. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/mp08-bg-r5-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp08-bg-r5-v01/`. 정본·코드·씬·content 수정 없음. 다른 세션 폴더는 읽지도 쓰지도 않음 |
| 자산 identity | region `region_r5_glasswing_ordinal`, art key `art_world_r5_glasswing_ordinal`. content ID: `prop_r5_boot_contract_board`, `prop_r5_repair_bench_rack`, `prop_r5_supply_rack`, `prop_r5_gantry_cradle`, edge E05/E11/E12/E14/E15/E18, internal route `gantry_cradle_descent`. 구역 ID `bg_r5_*`, 막이 ID `exit_r5_*`·`route_r5_*`, 전경 ID는 이 작업의 설계 ID |
| 입력 계약 버전 | COMMON.md(2026-09-27, '준비만 할 것' 줄이 있는 판), PROJECT_ART_LAYER 0.1, 13·14, 09 §12, `brief_r5_glasswing_ordinal.md`. 파일 SHA-256은 기준 확정 뒤 작업을 시작할 때 `inputs.json`에 적는다 |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 깊이 ×0.866, 높이 ×0.5. 배율 원본 1 m = 226 px(R4와 같음) |
| 입력 이미지 | 픽셀 입력 없음. 모양 재료는 at-icons node2d SVG(MIT). 시험 작업 그림은 눈으로만 비교, 플레이어 한 장만 미리보기 크기 확인용으로 `input/`에 복사 |
| 팔레트 | `palette_h0.json` 복사 + 새 `palette_r5.json`(톤앤매너 확정 뒤) |
| 도구 | R4 작업 폴더의 도구 복사본을 이 폴더로 다시 복사해 쓴다(같은 세션 소유, R4에서 추가한 기능 포함). 새로 바꾸면 여기에 적는다 |
| 필요한 결과 | 아래 체크리스트. 배경 2560×1440 불투명, 사물·막이·전경 투명 PNG, 미리보기 1280×720 |
| 내용 고정 | brief 5~8절 배치·상태 |
| 금지 | brief 13절 |
| 수정 범위 | 이 작업 폴더 안의 새 파일만 |
| 승인 상태 | 전부 candidate 예정. Gold Standard 없음. 승인은 사용자 |
| 검수 | 제작 때 `QA.md`를 만든다. 구도·화풍·기술·상태를 pass/partial/fail/not_run으로. 실제 게임 3해상도는 not_run |
| 중단 이유 | 기준 확정 대기(분위기 기준, 캐릭터 규격). 그 밖의 누락 입력 없음 |

## 작성자 설계로 정한 값
- 2×2 네 구역이 가운데 주조 구덩이를 둘러싸는 고리 구조, 구역 경계 통로 범위(brief 4절).
- Support Clinic을 랜드마크가 아닌 보조 건물로 둠(landmark_count 5에 맞춤).
- 출구 배치: E05·E14는 선로가 있는 Foundry Lane, E12는 Boot Hall, E11은 진료소 옆, E15·E18은 Supply Gantry 쪽.
- 사물 모양, 막이 모양, 재질과 색 초안(brief 6·7·10절).


## 만들 대상 (체크리스트)
배경은 한 번에 한 장씩. 자산마다 레시피 → build → read로 직접 확인 → 고치기(최대 2번) → 다음.

### 0. 준비
- [x] 자료 읽기: R4 준비 때 읽은 자료 + 02 §7.6·§8.6, R5 region·prop JSON
- [x] brief: `brief_r5_glasswing_ordinal.md`
- [x] 이 계획
- [ ] 기준 확정 뒤 COMMON 다시 읽고 brief 10절(색·분위기) 고치기
- [ ] R4 도구 복사본과 `palette_h0.json` 복사(workers 2 이하 유지), `palette_r5.json`, `inputs.json`(해시), `input/` 크기 확인용 플레이어 복사

### 1. `bg_r5_foundry_lane` (북서)
- [ ] base_clean
- [ ] exit_r5_e05_foundry_tram_closed / _open
- [ ] exit_r5_e14_under_rail_shunt_closed / _open
- [ ] foreground_r5_lane_pipes
- [ ] master_composite, preview_bg_r5_foundry_lane_1280x720

### 2. `bg_r5_boot_hall` (북동)
- [ ] base_clean
- [ ] prop_r5_board_unsigned, prop_r5_board_staged, prop_r5_board_refused
- [ ] exit_r5_e12_courier_shaft_closed / _open (R4 수갱 머리와 같은 설계)
- [ ] foreground_r5_hall_cable_tray
- [ ] master_composite, preview_reassembled_rv_after_staged_boot, preview_bg_r5_boot_hall_1280x720

### 3. `bg_r5_repair_clinic` (남동)
- [ ] base_clean
- [ ] prop_r5_bench_open, prop_r5_bench_residue
- [ ] exit_r5_e11_care_train_closed / _open
- [ ] foreground_r5_clinic_handrail
- [ ] master_composite, preview_reassembled_rv_after_staged_boot, preview_bg_r5_repair_clinic_1280x720

### 4. `bg_r5_labor_yard_gantry` (남서)
- [ ] base_clean
- [ ] prop_r5_rack_sealed, prop_r5_rack_issued
- [ ] prop_r5_cradle_empty, prop_r5_cradle_loaded
- [ ] route_r5_gantry_cradle_descent_closed / _open
- [ ] exit_r5_e15_supply_gantry_closed / _open
- [ ] exit_r5_e18_folding_school_approach_closed / _open
- [ ] foreground_r5_gantry_beam
- [ ] master_composite, preview_reassembled_rv_after_supply_rack, preview_bg_r5_labor_yard_gantry_1280x720

### 5. 마무리
- [ ] 네 구역 2×2 이음 확인 시트(preview/), review_sheet.py로 사물·막이 상태 모아 보기 시트
- [ ] QA.md, `__pycache__` 지우기
- [ ] 1순위(탑다운) 끝 → 짧게 중간 보고 → 3순위 범용(던전·동굴·유적)으로. 세션 08은 2순위가 없다

합계: 배경 base 4장, 사물 상태 9장, 출구·내부 길 막이 14장, 전경 4장, 기준 합성본 4장, 재방문 재조립 3장, 게임 화면 미리보기 4장.
