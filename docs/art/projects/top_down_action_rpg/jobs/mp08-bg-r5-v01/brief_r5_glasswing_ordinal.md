# R5 Glasswing Ordinal — 배경·오브젝트 brief (mp08-bg-r5-v01)

작성: 2026-09-27, 세션 08. 개정: 04시 기준 확정 반영(분위기 V1, 빛·그림자는 게임 코드, 배경과 오브젝트 분리, 캐릭터를 합친 확인 그림 금지). 배치·치수·재질·모양은 전부 **작성자 설계**이며 domain 데이터를 바꾸지 않는다. 오브젝트의 정확한 자리는 `recipes/scene_<배경>.json`이 정본이다. 시점·배율·빛·납품 파일·금지·검수의 공통 규칙은 R4 brief(`../mp08-bg-r4-v01/brief_r4_crownwell_archive.md`) 3·8·12·13절과 같다.

## 1. 근거
- region: `modules/top_down_action_rpg/content/regions/region_r5_glasswing_ordinal.json` — topology `industrial_loop_and_gantry`, size_class `large`, landmark_count 5, traversal_axis `route`, internal_route `gantry_cradle_descent`, 출구 6개(E05/E11/E12/E14/E15/E18).
- 지역 기획: `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/02_WORLD_STATE_AND_ROUTES.md` §7.6, §8.6, §5.2, §5.3, §6.1.
- 사물: `content/props/prop_r5_boot_contract_board.json`, `prop_r5_repair_bench_rack.json`, `prop_r5_supply_rack.json`, `prop_r5_gantry_cradle.json`. recovery 파일 없음.
- 화풍 기준: `h0-icon-mood-v02`의 V1. art key: `art_world_r5_glasswing_ordinal`(네 구역 묶음 전체).

## 2. 납품
- 배경: 구역마다 `base_clean`(바닥·벽·선로·구덩이·계단·승강장 같은 고정 구조와 바닥에 납작한 무늬만) + `foreground_*` 하나.
- 오브젝트: content 사물(상태별), 출구·내부 길 막이(`_closed`/`_open`), 이 지역에 되풀이해 놓는 물건. 한 번 만들어 네 구역에서 같이 쓴다.
- 구역마다 `recipes/scene_<배경>.json`과 배경+오브젝트 확인 그림 1280×720(사람·적 없음), 재방문 상태 장면.
- 배경 자체에 빛나는 곳(주조 구덩이 속 불씨)이 있으면 `_emit.png`로 따로 나오고, 장면 JSON의 `background_lights`에 자리·색·반지름을 적는다(게임 코드용).
- 현재 모듈의 4열 임시 격자 배치는 따르지 않는다. 게임에 연결하지 않는다.

## 3. 구역 나누기
랜드마크 5개(Foundry Lane, Boot Hall, Repair Bench, Labor Yard, Supply Gantry), 출구 6개, 내부 길 1개라 **2×2 네 구역**. 네 구역이 가운데 큰 주조 구덩이(`Ordinal core`, 작성자 설계)를 시계 방향으로 둘러싸서 기획의 industrial loop가 된다: Foundry Lane → Boot Hall → Repair Bench·Support Clinic → Labor Yard·Supply Gantry → Foundry Lane. Support Clinic은 landmark_count 5에 맞춰 보조 건물로 둔다.

| 구역 ID | 자리 | 장소 | 출구 | content 사물 |
|---|---|---|---|---|
| `bg_r5_foundry_lane` | 북서 | Foundry Lane | E05 Foundry Tram, E14 Under-Rail Shunt | — |
| `bg_r5_boot_hall` | 북동 | Boot Hall | E12 Courier Shaft | `prop_r5_boot_contract_board` |
| `bg_r5_repair_clinic` | 남동 | Repair Bench, Support Clinic | E11 Care Train | `prop_r5_repair_bench_rack` |
| `bg_r5_labor_yard_gantry` | 남서 | Labor Yard, Supply Gantry | E15 Supply Gantry, E18 Folding School Approach, 내부 길 | `prop_r5_supply_rack`, `prop_r5_gantry_cradle` |

- 구역 경계 통로(양쪽 같은 범위, 막이 없음, 바닥 재질이 이어짐): 북서 동쪽 ↔ 북동 서쪽 y 220..440 / 북동 남쪽 ↔ 남동 북쪽 x 540..760 / 남동 서쪽 ↔ 남서 동쪽 y 300..520 / 남서 북쪽 ↔ 북서 남쪽 x 520..740 (논리 좌표).
- 주조 구덩이는 네 구역 안쪽 모서리에 4분의 1씩: 북서 x 880..1280·y 480..720, 북동 x 0..400·y 480..720, 남동 x 0..400·y 0..240, 남서 x 880..1280·y 0..240. 난간 달린 낮은 테두리 안으로 파인 구덩이라서 다른 물체를 가리지 않는다.
- 구역 경계는 새 route가 아니다. 좌표는 구역 논리 좌표(원본 px = 논리 × 2).
