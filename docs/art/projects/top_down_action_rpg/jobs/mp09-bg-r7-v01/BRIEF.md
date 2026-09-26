# R7 The Hollow Orchard — 배경·오브젝트 brief (mp09-bg-r7-v01)

작성 2026-09-27, 세션 09. 기준: COMMON.md 04:25판(V1 확정). 출력 규격·시점·빛 규칙은 R6 brief(`../mp09-bg-r6-v01/BRIEF.md` §4)와 같다. 아래 배치·재질·크기·상태 모양은 이 작업의 **작성자 설계**이고 domain 좌표가 아니다.

## 1. 근거

- 기존 기획 사실: `modules/top_down_action_rpg/content/regions/region_r7_hollow_orchard.json`(topology `orchard_ring_and_wall`, size_class large, 랜드마크 5, 이동 축 phase, 되돌아가기 가능, 출구 4, 내부 길 1, 다시 방문 2, 숨은 상태), `content/props/prop_r7_*.json` 4개, `content/recovery/rec_r7_verge_loop.json`, 02 §7.8(Outer Wall, Root Orchard, Shelter Ring, Crown Position, Storm Verge), §5.2(E09/E13/E15/E16), §6.1(G5/G6/G7/G8), §8.8.
- 제작 계약: COMMON.md(우선), 13 §1·§5, 09 §12, `docs/IMAGE_ASSET_WORKFLOW.md` §3. 모듈 코드에는 공간 배치가 없어(`systems/field_controller.gd` 4열 임시 격자) 배치는 전부 작성자 설계다.

## 2. 자산 ID와 게임 상태

- art key `art_world_r7_hollow_orchard`. 구역 ID(작성자 설계): `bg_r7_wall_causeway`, `bg_r7_orchard_shelter`, `bg_r7_crown_verge`.
- 첫 방문: `as_authored`, 입구는 E09 Orchard Causeway(STORY_FORCED).
- 다시 방문: `rv_after_void_cut` = 절단 흔적 `ps_cut_filed` + 벽 이음매 `ps_reported`. `rv_after_settlement_vote` = 장부 `ps_quota_filed` + 왕관 자리 받침 `ps_claimed`.
- 숨은 상태: 왕관 자리 받침은 `ps_claimed` 전에는 안 보인다(prop hidden_until_condition, region hidden_state는 crown_alignment 2단계에서 일부 공개). 바탕에는 받침 없는 빈 원형 단을 그리고 받침 두 상태는 오브젝트로 만든다.
- 02 §7.8의 "phase별 다른 출입구"는 content에 벽 이음매와 내부 길 상태로만 들어 있어서 그 밖의 phase 그림은 만들지 않는다. 왕관 실물은 R4 위에 있어서 그리지 않고 그림자만 받침 그림에 넣는다.
- 필드 전투가 있다(field_pressure lethal). 구역마다 막힘없는 바닥을 남긴다. NPC 8명은 다른 세션 담당이다.

## 3. 화면 나누기 (작성자 설계)

바깥 벽이 지역 북쪽을 두르고, 서쪽 둑길로 들어와 동쪽 폭풍 가장자리로 가는 순서로 1280×720 구역 3개를 가로로 둔다. 구역 사이 길의 위치와 폭을 양쪽에서 맞춘다. 가장자리 그림은 이어 붙이지 않는다.

| 구역 | 랜드마크 | 출구·내부 길 | 사물 | 이어지는 곳 |
|---|---|---|---|---|
| `bg_r7_wall_causeway` (도착, 서쪽) | Outer Wall | E09 Orchard Causeway(입구), E16 Drainage Dark | 벽 이음매 | 동쪽 길 y 350..490 → orchard_shelter |
| `bg_r7_orchard_shelter` (가운데) | Root Orchard, Shelter Ring | E15 Supply Gantry, 지름길 쉼터 쪽 끝 | 쉼터 장부 | 서쪽 y 350..490, 동쪽 아래 y 500..640 → crown_verge, 동쪽 위 지름길 y 270..360 |
| `bg_r7_crown_verge` (동쪽 끝) | Crown Position, Storm Verge | E13 Crown Stair, 지름길 가장자리 쪽 끝 | 왕관 자리 받침, 절단 흔적 | 서쪽 아래 y 500..640, 서쪽 위 지름길 y 270..360 |

## 4. 출력 규격

R6 brief §4와 같다. 배경은 base_clean(바닥·벽·계단·둑·원형 단·기중기 탑 같은 고정 구조와 납작한 무늬)과 foreground만, 나무·쉼터·화덕·덤불·등불·잔해 같은 물건은 지역 오브젝트, 출구와 지름길 상태도 오브젝트. 구역마다 장면 JSON과 배경+오브젝트 확인 그림(처음·다시 방문). 절단 흔적 안의 빛 효과는 세션 10 몫(`art_effect_portal_void_cut`)이라 그리지 않는다.

## 5. 재질과 색 (작성자 설계)

`palette_r7.json`은 `palette_h0_mood.json`을 물려받고 아래 재질만 더한다. 밝기는 V1 바닥과 비슷하게. **흑갈색 흙 + 차가운 현무암 벽 + 은회색 빈 나무 + 폭풍 가장자리의 옅은 재청색**으로 R7임을 알게 한다.

| 재질 | 쓰는 곳 | base / shadow / light |
|---|---|---|
| loam | 흙 바닥 | `#544739` / `#40362b` / `#665849` |
| root_flag | 뿌리에 갈라진 판석 길 | `#5a5550` / `#46423e` / `#6c6660` |
| basalt | 바깥 벽, 계단, 원형 단 | `#3d3c46` / `#2d2c35` / `#4d4c57`, 옆면 `#302f39` |
| bark_hollow | 속 빈 나무 | `#5f5a52` / `#47433d` / `#756f66` |
| leaf_dry | 마른 잎·풀 | `#4d4d36` / `#393926` / `#5f5f44` |
| verge_scour | 폭풍 가장자리의 쓸린 땅 | `#62675f` / `#4d514b` / `#757a72` |
| canvas_shelter | 쉼터 천 | `#4d5549` / `#3a4137` / `#5f675a` |
| void_cut | 절단 흔적 안쪽 | `#1c1026` |
| fruit | 떨어진 열매 | `#7a5530` |

## 6. 구역별 배치와 정보 중요도

좌표는 논리 px(1280×720), 원본은 ×2. 주 동선은 폭 140 px 이상, 물체·전경으로 막지 않는다.

### 6.1 `bg_r7_wall_causeway` — 도착, 바깥 벽

| 요소 | 위치(논리) | 정보 등급 | 그림 |
|---|---|---|---|
| 바깥 벽(현무암, 청동 측량 못) | 앞면 y 0..170(밑선 170) | 길찾기·상황 이해 | base |
| 벽 이음매 | 벽 밑선 (640,170) | 증거·직접 상호작용 | 오브젝트(벽) |
| E16 배수 아치와 앞 돌 웅덩이 | 아치 x 980..1180, 웅덩이 x 1000..1160, y 180..260 | 길찾기·상황 이해 | base |
| E16 창살 | 아치 밑선 (1080,170) | 증거·직접 상호작용 | 오브젝트 `exit_r7_e16_drainage_dark` |
| E09 둑길 | 서쪽 가장자리, 길 y 420..560, x 0..300, 남쪽 비탈 y 560..600, 양옆 마른 도랑 | 길찾기·상황 이해 | base |
| E09 차단목 | 둑길 끝 (300,490) | 증거·직접 상호작용 | 오브젝트 `exit_r7_e09_orchard_causeway` |
| 판석 길 | 둑길 끝 → 동쪽 가장자리 y 350..490, 가지 길 → 이음매 앞, 배수 아치 앞 | 길찾기·상황 이해 | base |
| 속 빈 나무 4, 떨어진 열매, 벽 잔해 2, 등불 기둥 1 | 나무 (560,690) (820,650) (1000,700) (1190,640), 잔해 (200,190) (900,185), 등불 (350,410) | 분위기 | 오브젝트 |

전투 공간: x 360..960, y 200..420.

### 6.2 `bg_r7_orchard_shelter` — 뿌리 과수원, 쉼터 링

| 요소 | 위치(논리) | 정보 등급 | 그림 |
|---|---|---|---|
| 바깥 벽 | 앞면 y 0..120 | 길찾기·상황 이해 | base |
| E15 보급 기중기 탑 | 벽 앞 x 880..1060, 승강판 내려오는 자리 x 900..1040, y 180..260 | 길찾기·상황 이해 | base |
| E15 승강판과 제동 | 탑 앞 (970,260) | 증거·직접 상호작용 | 오브젝트 `exit_r7_e15_supply_gantry` |
| 쉼터 링(다져진 흙 원) | 중심 (640,420), 반지름 300×260 | 길찾기·상황 이해 / 전투 공간 | base |
| 쉼터 4채, 화덕 돌 원 | 쉼터 (430,240) (730,170) (430,600) (560,650), 화덕 (640,480) | 분위기 | 오브젝트 |
| 쉼터 장부 탁자 | (600,380) | 증거·직접 상호작용 | 오브젝트 |
| 속 빈 나무 5, 등불 기둥 2 | 나무 (170,180) (1180,190) (1150,460) (120,700) (1180,700), 등불 (500,350) (780,500) | 분위기 | 오브젝트 |
| 판석 길 | 서쪽 y 350..490 → 링, 링 → 동쪽 아래 y 500..640, 링 → 탑, 링 → 동쪽 위 y 270..360 | 길찾기·상황 이해 | base |
| 지름길 쉼터 쪽 끝 | 동쪽 가장자리 (1200,315) | 증거·직접 상호작용(절단 결과) | 오브젝트 `route_r7_storm_verge_shelter_run` (shelter_*) |

### 6.3 `bg_r7_crown_verge` — 왕관 자리, 폭풍 가장자리

| 요소 | 위치(논리) | 정보 등급 | 그림 |
|---|---|---|---|
| E13 왕관 계단과 돌 난간벽 | x 340..580, 맨 아래 단 y 200, 북쪽 화면 밖으로 올라감 | 길찾기·상황 이해 | base |
| E13 쇠사슬 문 | 계단 발치 (460,215) | 증거·직접 상호작용 | 오브젝트 `exit_r7_e13_crown_stair` |
| 바깥 벽 끝과 부서진 벽 토막 | 앞면 x 0..320 / 600..800, y 0..120, x 800 동쪽은 토막 | 길찾기·상황 이해 | base |
| 왕관 자리 원형 단 | 중심 (520,500), 320×278, 0.3 m 높이 | 길찾기·상황 이해 | base(받침 없음) |
| 왕관 자리 받침 | (520,500) | 증거·직접 상호작용 | 오브젝트(처음엔 안 보임) |
| 능선 지름길과 막힘 | 가장자리 쪽 (900,320)에서 서쪽 가장자리 y 270..360, 막힘 (130,315) | 증거·직접 상호작용(절단 결과) | 길은 base, 막힘은 오브젝트 (verge_*) |
| 폭풍 가장자리 | x 760..1280, 쓸린 옅은 땅, 동쪽에서 온 모래 줄무늬 | 길찾기·상황 이해 / 전투 공간 | base |
| 절단 흔적 | (1000,440) | 증거·직접 상호작용 | 오브젝트(바닥 흔적) |
| 휜 마른 덤불 4, 벽 잔해 2 | 덤불 (850,350) (1150,300) (1220,550) (900,625), 잔해 (880,140) (1120,150) | 분위기 | 오브젝트 |
| 부서진 벽 토막(앞) | x 1080..1280, y 620..720 | 분위기 | `foreground_r7_wall_stub` |

주 동선: 서쪽 아래 y 500..640 → 원형 단 → 계단 발치 / 폭풍 가장자리. 전투 공간: x 760..1200, y 250..620.

## 7. 오브젝트 목록

content 사물

| 자산 | 상태 그림 | 실제 크기 | 모양과 달라지는 점 |
|---|---|---|---|
| `prop_r7_outer_wall_seam` | `prop_r7_seam_sealed`, `prop_r7_seam_reported` | 폭 1.2 × 높이 3.0 m(벽면) | sealed: 납 같은 메움재로 닫힌 세로 이음매, 빈 눈금판 셋. reported: 측량 까치발과 추 달린 줄, 눈금판이 열려 관측점이 됨 |
| `prop_r7_crown_position_plinth` | `prop_r7_plinth_unclaimed`, `prop_r7_plinth_claimed` | 지름 1.2 × 높이 0.6 m, 그림자 무늬 지름 3 m 안 | unclaimed: 빈 받침 둘레에 다섯 조각 그림자(바닥 무늬). claimed: 받침 앞면 청동 서랍과 빈 봉인 꼬리표, 다섯 그림자 자리에 작은 말뚝 |
| `prop_r7_storm_verge_cut` | `prop_r7_cut_open`, `prop_r7_cut_matched`, `prop_r7_cut_filed` | 바닥 흔적 2.4 × 1.2 m | open: 닫히지 않은 날카로운 절단 자국(안쪽 짙은 보라, 빛 없음), 청동 말뚝 흩어짐. matched: 말뚝과 줄이 절단 모양을 따라 팽팽히. filed: 청동 꺾쇠로 꿰맴 + 빈 계약 꼬리표 |
| `prop_r7_shelter_ring_ledger` | `prop_r7_ledger_open`, `prop_r7_ledger_quota` | 1.6 × 0.8 × 0.9 m | open: 칸 나눈 상자에 씨앗 주머니·물병·나무 꼬리표가 들쭉날쭉. quota: 같은 크기 틀로 정리, 장부 상자에 납 봉인과 매듭 끈 |

출구·내부 길

| 자산 | 상태 그림 | 피벗 | 모양 |
|---|---|---|---|
| `exit_r7_e09_orchard_causeway` | `closed`, `open` | 차단목 받침 바닥 가운데 | closed: 밧줄 감긴 차단목 + 빈 꼬리표. open: 차단목 들림 |
| `exit_r7_e13_crown_stair` | `closed`, `open` | 계단 발치 문 가운데 | closed: 납 봉인 쇠사슬 문. open: 사슬 내려지고 문짝 열림 |
| `exit_r7_e15_supply_gantry` | `closed`, `open` | 승강판 자리 앞 가운데 | closed: 승강판이 탑 위에 걸리고 제동 쐐기. open: 승강판이 땅에 내려옴, 빈 나무 상자 둘 |
| `exit_r7_e16_drainage_dark` | `closed`, `open` | 배수 아치 밑선 가운데(벽) | closed: 창살 내려옴. open: 창살 올라감, 좁은 발판 |
| `route_r7_storm_verge_shelter_run` | `verge_closed`, `verge_open`, `shelter_closed`, `shelter_open` | 길 가운데 | closed: 무너진 뿌리·잔해 더미가 막음. open: 걷어낸 길 + 갈라진 틈 위 널빤지 |

지역 오브젝트 (분위기)

| 자산 | 그림 | 크기 | 쓰는 곳 |
|---|---|---|---|
| `obj_r7_hollow_tree` | `a`, `b`, `c` | a 3.5 m 두 갈래, b 2.5 m 부러진 꼭대기, c 기운 나무. 잎 적음 | wall_causeway 4, orchard_shelter 5 |
| `obj_r7_shelter` | `a`, `b` | 2.0 × 1.6 m 기댄 천막(나무 기둥) | orchard_shelter 4 |
| `obj_r7_hearth_ring` | 1 | 지름 1.4 m 돌 원, 불 없음 | orchard_shelter 1 |
| `obj_r7_dry_shrub` | `a`, `b` | 1.0 m 휜 마른 덤불 | crown_verge 4 |
| `obj_r7_fallen_fruit` | 1 | 열매 몇 개와 마른 잎 | wall_causeway |
| `obj_r7_wall_rubble` | 1 | 현무암 벽 토막 더미 | wall_causeway, crown_verge |
| `obj_r7_lantern_post` | 1 | 1.8 m 기둥 등불, 발광(`light` 색 `#ffc987`, 반지름 원본 260 px) | wall_causeway 1, orchard_shelter 2 |

## 8. 공용 사물 자리 (세션 01 담당. 그리지 않음)

- `art_prop_route_marker`: wall_causeway (340,400) 둑길 끝, (1080,290) 배수 아치 앞 / orchard_shelter (980,300) 기중기 앞, (1230,560) 동쪽 아래 길 / crown_verge (460,250) 계단 발치, (880,300) 능선 동쪽 끝.
- `art_prop_recovery_anchor`: crown_verge (920,520). rec_r7_verge_loop는 절단 흔적에서 되살아난다.
- `art_prop_magic_concentration_device`: R7 없음.

## 9. 유지할 것, 바꿀 것, 금지

- 유지: V1의 선·명암·붓자국·때 얼룩 방식, 60° 계산, 레이어 규칙.
- 바꿈: 바닥·벽 재질과 색(§5), 물체 높이를 플레이어 키 기준으로.
- 금지: 사람·적·시체·피·눈, 왕관 실물, 읽을 수 있는 글자·숫자, UI·HUD·focus 표시·워터마크, BLACK SOULS·Alice 고유 지형·상징, 무작위 기괴 장식, 원래 아이콘 모양이 그대로 읽히는 조각, 주 동선을 가리는 전경, 그림에 넣은 장면 조명·비네트·불빛 웅덩이, 절단 흔적 안의 빛 효과, 배경에 오브젝트 합치기, 캐릭터를 배경에 얹은 미리보기, 공용 사물 3개.

## 10. 원본과 Gold Standard

R6 brief §10과 같다(화풍 기준 h0-icon-mood-v02 V1 결과와 palette_h0_mood.json, Gold Standard 없음, 아이콘 원본 SVG 수정 없음).

## 11. 검수

구역별 배경+오브젝트 확인 그림(처음·다시 방문), 오브젝트 모아 보기 시트, 가장자리 잘림, 알파 가장자리, 그림자·발광 분리, 받침 없는 원형 단이 비어 보이지 않는지. 세 해상도 실제 게임 화면 검수는 게임 연결 금지라 not_run.
