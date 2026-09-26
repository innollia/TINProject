# mp07-bg-r2-v01 — R2 Siltglass Commons 배경과 오브젝트

상태: **진행 중** (2026-09-27 04:35 KST 시작). 결과는 전부 candidate이고 승인은 사용자만 한다. 게임에 연결하지 않는다.

| 필드 | 값 |
|---|---|
| 목적 | clean_base + occluder + prop(오브젝트) + state_variant (R2 지역 한 묶음) |
| 소유권 | 세션 07. 쓰기: `assets/art/top_down_action_rpg/jobs/mp07-bg-r2-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp07-bg-r2-v01/`. 게임 코드·씬·content·규칙 문서 수정 없음, git 커밋·푸시 없음 |
| 자산 identity | 지역 `region_r2_siltglass_commons` / art key `art_world_r2_siltglass_commons`. content 사물 5개는 content ID와 art_key 그대로. 구역 ID, 출구·내부 길·지역 오브젝트 이름은 작성자 설계 (BRIEF §3·§6) |
| 입력 계약 버전 | `inputs.json` |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 가로 180 px/m, 깊이 ×0.866, 높이는 플레이어 키 기준 1 m ≈ 110 px |
| 화풍 | V1 (`h0-icon-mood-v02`). 빛은 기본 확산광만, 장면 조명 없음 |
| 입력 이미지 | 픽셀 입력 없음. 모양 재료 `addons/at-icons/node2d` SVG |
| 필요한 결과 | BRIEF §12 |
| 금지 | BRIEF §10 |
| 승인 상태 | Gold Standard 0개. 이 job 결과 = candidate |
| 검수 | `QA.md` |

## 체크리스트

준비
- [x] 자료 읽기, 만들 대상 목록, BRIEF, JOB 계획 (04:02 KST)
- [x] 새 기준 반영: COMMON 다시 읽기(04:35), V1 기록·그림 확인, BRIEF를 배경·오브젝트 분리 기준으로 다시 씀
- [x] 도구 바꾸기: `tool/`을 `h0-icon-mood-v02/tool`로 교체, `palette_h0_mood.json` 복사, 옛 `palette_h0.json` 삭제
- [ ] `recipes/palette_r2.json`

구역 A `r2_a_sluice_landing`
- [ ] base_clean
- [ ] foreground_mooring_piles
- [ ] prop_r2_waterline_mark (low, raised, spent)
- [ ] exit_r2_e02_sluice_road, exit_r2_e08_medicine_ferry (closed, open)
- [ ] obj_r2_lantern_post, obj_r2_toll_booth, obj_r2_water_cask
- [ ] scene_r2_a_sluice_landing.json, check 그림, 모아 보기 시트

구역 B `r2_b_stilt_settlements`
- [ ] base_clean, foreground_deck_rail
- [ ] prop_r2_disperser_housing (full, empty), prop_r2_circulator_stack (idle, vented)
- [ ] exit_r2_e17_water_ambulance_bridge (closed, open), obj_r2_net_rack
- [ ] scene JSON, check 그림, 모아 보기 시트

구역 C `r2_c_root_bridge_seed_vault`
- [ ] base_clean, foreground_root_tangle
- [ ] prop_r2_root_bridge_anchor (locked, raised, surveyed), prop_r2_seed_vault_shelf (counted, reissued)
- [ ] exit_r2_e09_orchard_causeway, route_r2_flood_refuge_gallery (closed, open)
- [ ] scene JSON, check 그림, 모아 보기 시트

마무리
- [ ] 이음 확인 (A↔B, B↔C), QA.md, `__pycache__` 지우기
- [ ] 그다음 R3 (`mp07-bg-r3-v01`)

만드는 방식: 자산 하나씩 레시피 → build → 직접 보고 확인 → 고치기(자산당 최대 2번). 배경은 한 번에 한 장씩.

## 도구 변경 (이 job 복사본만)

- `tool/`은 `h0-icon-mood-v02/tool`(`__pycache__` 제외)을 04:36 KST에 복사한 것. 준비 때 복사한 옛 도구(`h0-icon-collage-v01`)는 이 복사로 전부 덮어씀(옛 도구의 파일은 모두 새 도구에도 있음).
- `tool/iconkit/icons.py` `prefetch()` `workers` 8 → 2. 세션 10개가 CPU를 나눠 씀(COMMON).

## 작성자 설계 (문서에 없던 값)

- 3구역 나누기와 이음 위치, 모든 좌표 (BRIEF §3·§4).
- 높이 기준 1 m ≈ 110 px (플레이어 몸 186 px = 1.7 m). COMMON 약점 "캐릭터 대비 사물이 낮아 보임"을 바로잡기 위한 값.
- 재질과 색, "실트유리" 벽돌 (BRIEF §8).
- 오브젝트 모양과 상태별 차이, 출구·내부 길·지역 오브젝트 이름과 모양 (BRIEF §5·§6).
- `prop_r2_waterline_spent`는 content에서 `visible:false`라 선택 그림.
- 벽에 붙는 오브젝트(분사기 함, 순환 굴뚝)의 피벗은 붙는 벽의 밑선(벽과 바닥이 만나는 점). 장면 JSON의 `at`도 그 점.
