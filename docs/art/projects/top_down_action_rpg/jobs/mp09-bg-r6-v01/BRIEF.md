# R6 Gristmarket Ward — 배경·오브젝트 brief (mp09-bg-r6-v01)

작성 2026-09-27, 세션 09. 기준: COMMON.md 04:25판(V1 확정). 아래 배치·재질·크기·상태 모양은 이 작업의 **작성자 설계**이고 domain 좌표가 아니다.

## 1. 근거

- 기존 기획 사실: `modules/top_down_action_rpg/content/regions/region_r6_gristmarket_ward.json`(topology `ring_market_and_drainage`, size_class large, 랜드마크 5, 이동 축 depth, 되돌아가기 가능, 출구 4, 내부 길 1, 다시 방문 2, 숨은 상태), `content/props/prop_r6_*.json` 4개, `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/02_WORLD_STATE_AND_ROUTES.md` §7.7(Gristmarket Ring, Organ Intake, Cure Queue, Debt Hall, Replacement Stalls, Drainage Dark가 층과 수로로 연결), §5.2(E07/E08/E14/E16), §6.1(G1/G2/G5/G6), §8.7.
- 제작 계약: COMMON.md(우선), 13 §1·§5, 09 §12(공통 필드, 12.1, 12.2, 12.8), `docs/IMAGE_ASSET_WORKFLOW.md` §3.
- 모듈 코드는 사물·NPC·출구를 4열 격자(`systems/field_controller.gd`의 `_anchor_position`)에 임시로 놓을 뿐 공간 배치가 없다. 그래서 배치는 전부 작성자 설계다.

## 2. 자산 ID와 게임 상태

- art key `art_world_r6_gristmarket_ward`. 구역 ID(작성자 설계): `bg_r6_intake_ring`, `bg_r6_debt_hall`, `bg_r6_stalls_drainage`.
- 첫 방문: `as_authored`, 입구는 E07 Ash Chute(STORY_FORCED).
- 다시 방문: `rv_after_quorum` = 대기판 `ps_reassigned` + 청원 탁자 `ps_cosigned`. `rv_after_debt_surgery` = 카운터 `ps_split` + 펌프 `ps_primed`.
- 숨은 상태(personal_collapse 3단계 이상)가 드러내는 것은 청원 탁자와 문서다. 탁자 상태 그림으로 충분해서 새 그림은 없다.
- 필드 전투가 있다(field_pressure high). 구역마다 막힘없는 바닥을 남긴다.
- 02 §7.7의 "Quorum 이후 E07 intake stamp 변화"는 region JSON에 없어서 만들지 않는다. NPC 7명은 다른 세션 담당이다.

## 3. 화면 나누기 (작성자 설계)

size_class large, 랜드마크 5, depth(층) 이동이라 1280×720 구역 3개를 위에서 아래로 내려가는 순서로 둔다. 구역 사이는 화면 가장자리 계단으로 잇고 계단 위치와 폭을 양쪽에서 맞춘다. 가장자리 그림을 이어 붙이지는 않는다.

| 구역 | 랜드마크 | 출구·내부 길 | 사물 | 이어지는 곳 |
|---|---|---|---|---|
| `bg_r6_intake_ring` (도착, 윗단) | Gristmarket Ring, Organ Intake, Cure Queue | E07 Ash Chute(입구), E08 Medicine Ferry | 접수 카운터, 대기판 | 남쪽 계단 x 560..720 → debt_hall |
| `bg_r6_debt_hall` (가운데 단) | Debt Hall, Heart Petition | E14 Under-Rail Shunt | 청원 탁자 | 북쪽 계단 x 560..720, 남동 계단 x 880..1040 → stalls_drainage |
| `bg_r6_stalls_drainage` (아랫단) | Replacement Stalls, Drainage Dark | E16 Drainage Dark, 내부 길 drainage_pump_run | 배수 펌프 | 북쪽 계단 x 880..1040 |

## 4. 출력 규격 (V1)

- 배경 그림은 `base_clean`(바닥·벽·계단·수조·레일·수로처럼 장소 모양을 이루는 고정 구조와 바닥에 납작한 무늬)과 캐릭터 앞을 가리는 고정 구조 `foreground_*`만 만든다. base는 2560×1440 불투명, foreground는 2560×1440 투명(원점 0,0). 원본 2 px = 논리 1 px.
- 떼어 놓을 수 있거나 다른 곳에 또 놓일 물건은 전부 오브젝트: 투명 PNG, 바닥 접촉 피벗(벽에 붙는 것은 붙는 자리), 사방 여백 원본 64 px 이상, 그림자 `_shadow.png`, 빛나는 부분 `_emit.png`. 지역 오브젝트는 한 번만 만들고 세 구역에서 같이 쓴다. content 사물 그림 이름은 art_key.
- 출구·관문과 내부 길 상태도 오브젝트(closed/open 상태 그림)다.
- 구역마다 `recipes/scene_<구역>.json`(items는 오브젝트만, `lighting` 없음, 빛나는 오브젝트에 게임 코드용 `light`)과 배경+오브젝트 확인용 그림 1280×720(사람·적 없음). 다시 방문 상태는 `scene_<구역>_revisit.json`으로 한 장 더.
- 시점: 지면 기준 60° 정사영, 방위 고정. 바닥 가로 1 m = 원본 180 px, 깊이 ×0.866(156 px/m). 높이 1 m = 원본 110 px: 플레이어 그림(원본 약 192 px)을 1.75 m로 본 값이다. 도구의 옆면 0.5배(90 px/m)에 플레이어 그림의 과장(약 1.2배)을 같이 곱해 COMMON.md "플레이어 키 기준 실제 비율"을 맞춘다. 예: 허리 높이 카운터 1.05 m = 116 px, 문·아치 2.2 m = 242 px.
- 빛과 그림자: 그림에는 도구의 기본 확산광(왼쪽 위)과 물체 자체 명암만. 화면 어둡게 누르기, 비네트, 불빛 웅덩이는 넣지 않는다. 선·명암·붓자국은 palette_h0_mood `styles` 그대로.
- 바닥 얼룩은 작은·중간·큰 세 겹으로 크기를 섞고 겹마다 세기를 낮춘다(반복 무늬 방지).

## 5. 재질과 색 (작성자 설계)

`palette_r6.json`은 `palette_h0_mood.json`을 물려받고(윤곽선 ink `#0f0a11`, 그림자 `#1a1420`, 접촉 그림자 `#0e0a12`, 공통 색, styles 그대로) 아래 재질만 더한다. 밝기는 V1 바닥(`#57505c`, 밝기 약 83)과 비슷하게. H0(회보라)와 달리 **어두운 뼈빛 유약 타일 + 녹청 구리 + 젖은 청회색 돌**로 R6임을 알게 한다.

| 재질 | 쓰는 곳 | base / shadow / light |
|---|---|---|
| tile | 바닥 유약 타일(한 변 약 0.75 m) | `#58564a` / `#474539` / `#6b6858`, 줄눈 `#1a1916` |
| tile_wall | 회랑 벽 | `#4f5249` / `#3c3f37` / `#60645a`, 옆면 `#383b34` |
| wet_slate | 배수로, 수조, 젖은 계단 | `#3f4744` / `#2e3533` / `#505955` |
| verdigris | 관, 펌프, 레일 부품 | `#4a5e52` / `#34443b` / `#6a8273` |
| canvas_ochre | 좌판 천막 | `#5e5031` / `#3f3520` / `#776741` |
| court_wood | 빚 법정 단, 의자 | `#4a3528` / `#30231a` / `#624838` |
| water_dark | 고인 물 | `#101615`, 반사 `#2e3a37` |
| bronze, iron, wood, paper, glass, flame | V1 그대로 | — |

## 6. 구역별 배치와 정보 중요도

좌표는 논리 px(1280×720), 원본은 ×2. 주 동선은 폭 140 px 이상, 물체·전경으로 막지 않는다. '오브젝트'는 장면 JSON에 놓는 따로 된 그림이다.

### 6.1 `bg_r6_intake_ring` — 도착, 링 시장 윗단

| 요소 | 위치(논리) | 정보 등급 | 그림 |
|---|---|---|---|
| 북쪽 진료 회랑 벽(관·기둥 포함) | 앞면 y 0..150(밑선 150) | 길찾기·상황 이해 | base |
| E07 Ash Chute | 벽 구멍 x 120..300, 경사 슈트가 재 쌓인 도착 단(x 100..340, y 150..240)으로 | 길찾기·상황 이해 | base |
| E07 검표 차단봉 | 도착 단 앞 (220,245) | 증거·직접 상호작용 | 오브젝트 `exit_r6_e07_ash_chute` |
| 장기 접수 카운터 | (300,440), 폭 288 × 깊이 70 | 증거·직접 상호작용 | 오브젝트 |
| 접수 앞 세 줄 바닥 상감 | x 170..430, y 450..570 | 분위기 | base |
| 치료 대기판 | 북벽, 벽 밑선 (700,150) | 증거·직접 상호작용 | 오브젝트(벽) |
| 링 광장 | 중심 (760,440), 바깥 440×380 타원, 가운데 배수 구멍 | 길찾기·상황 이해 / 전투 공간 | base |
| 링 가운데 둥근 배수구 덮개 | (760,440) | 분위기 | 오브젝트 `obj_r6_drain_cover` |
| 빈 돌 좌판 4개 | (870,275) (950,345) (950,535) (870,605) | 분위기 | 오브젝트 `obj_r6_stone_stall` |
| 동쪽 수로와 부두 | 수로 x 1150..1280, 부두 x 1150..1250, y 380..500 | 길찾기·상황 이해 | base |
| E08 배 | 부두 옆 (1215,440) | 증거·직접 상호작용 | 오브젝트 `exit_r6_e08_medicine_ferry` |
| 남쪽 내려가는 계단 | x 560..720, y 640..720 | 길찾기·상황 이해 | base |
| 회랑 가로보 | x 0..400, y 664..720 | 분위기 | `foreground_r6_lintel` |
| 벽등 3, 약 상자 더미 1 | 벽등 북벽 (430,150) (980,150) (1100,150), 상자 (1060,200) | 분위기 | 오브젝트 |

주 동선: 도착 단 → 동쪽(y 150..300) → 링 → 남쪽 계단. 링 동쪽 좌판 사이 틈(y 400..480) → 부두.

### 6.2 `bg_r6_debt_hall` — 빚 법정, 심장 청원

| 요소 | 위치(논리) | 정보 등급 | 그림 |
|---|---|---|---|
| 북쪽 벽 | 앞면 y 0..120, 계단 자리 x 560..720은 뚫림 | 길찾기·상황 이해 | base |
| 북쪽 계단 끝과 층계참 | 계단 x 560..720, y 0..80, 층계참 y 80..120 | 길찾기·상황 이해 | base |
| E14 레일 아치와 레일 | 북벽 아치 x 80..280, 레일 두 줄이 아치에서 y 300까지 | 길찾기·상황 이해 | base |
| E14 셔터와 멈춤 받침 | 아치 밑선 (180,120) | 증거·직접 상호작용 | 오브젝트 `exit_r6_e14_under_rail_shunt` |
| 심장 청원 탁자 | (420,460) | 증거·직접 상호작용 | 오브젝트 |
| 빚 법정 단 | x 860..1200, y 140..300, 0.5 m 높은 나무 단 | 길찾기·상황 이해 | base |
| 판결대 | 단 위 (1030,250) | 분위기 | 오브젝트 `obj_r6_court_bench` |
| 대기 긴 의자 6 | x 760..920 / 1020..1180, 줄 y 420, 500, 580 | 분위기 | 오브젝트 `obj_r6_wait_bench` |
| 남동 내려가는 계단 | x 880..1040, y 640..720 | 길찾기·상황 이해 | base |
| 앞 난간 기둥과 가로대 | x 40..360, y 650..720 | 분위기 | `foreground_r6_rail_posts` |
| 벽등 2, 배수구 덮개 1 | 벽등 (420,120) (820,120), 덮개 (620,560) | 분위기 | 오브젝트 |

주 동선: 층계참 → 탁자 앞(y 480 부근) → 레일 끝(180,320). 층계참 → 의자 사이 통로(x 920..1020) → 남동 계단. 전투 공간: x 460..860, y 140..420.

### 6.3 `bg_r6_stalls_drainage` — 교체 부품 좌판, 배수 어둠

| 요소 | 위치(논리) | 정보 등급 | 그림 |
|---|---|---|---|
| 북쪽 벽과 층계참 | 앞면 y 0..110, 계단 x 880..1040은 뚫림 | 길찾기·상황 이해 | base |
| 교체 부품 좌판 3칸 | (151,300) (331,300) (511,300) | 분위기 | 오브젝트 `obj_r6_parts_booth` |
| 배수 펌프 | (660,420) | 증거·직접 상호작용 | 오브젝트 |
| 배수로 | 펌프 옆 (700,440)에서 남동 수조까지, 폭 약 110, 마른 돌 바닥 | 길찾기·상황 이해 | base |
| 가라앉은 수조 | x 820..1260, y 470..720, 바닥 2 m 낮음(북쪽 옹벽 면 y 470..580) | 길찾기·상황 이해 | base |
| 수조로 내려가는 젖은 계단 | x 820..900, y 470..600 | 길찾기·상황 이해 | base |
| 물 높이·쇠사슬 | 수조 가운데 (1040,640) | 증거·직접 상호작용(펌프 결과) | 오브젝트 `route_r6_drainage_pump_run`(바닥층) |
| E16 터널 입구 | 옹벽 아치 x 960..1160 | 길찾기·상황 이해 | base |
| E16 쇠창살 | 아치 밑선 (1060,580) | 증거·직접 상호작용 | 오브젝트 `exit_r6_e16_drainage_dark` |
| 머리 위 녹청 관 | x 0..520, y 640..700 | 분위기 | `foreground_r6_pipe` |
| 벽등 2, 배수구 덮개 2, 잔해 2, 약 상자 1 | 벽등 (300,110) (700,110), 덮개 (440,560) (180,620), 잔해 (60,150) (780,130), 상자 (620,150) | 분위기 | 오브젝트 |

주 동선: 층계참 → 좌판 앞(y 320..360) → 펌프 → 젖은 계단 → 수조 → 터널. 전투 공간: x 200..800, y 340..640.

## 7. 오브젝트 목록

content 사물 (피벗: 바닥 사물은 앞면 바닥 가운데, 벽 사물은 벽 밑선 가운데)

| 자산 | 상태 그림 | 실제 크기 | 모양과 달라지는 점 |
|---|---|---|---|
| `prop_r6_organ_intake_counter` | `prop_r6_counter_open`, `prop_r6_counter_split` | 3.2 × 0.9 × 1.05 m | open: 칸막이로 나뉜 서류함 셋, 칸마다 모양·색 띠가 다른 빈 서식. split: 칸막이를 걷고 긴 빈 서식 한 장이 세 칸을 가로지름, 빈 봉인 자리 셋 |
| `prop_r6_cure_queue_board` | `prop_r6_queue_numbered`, `prop_r6_queue_reassigned` | 폭 2.4 × 높이 1.6 m, 바닥에서 0.8 m 위 | numbered: 걸이 막대에 무늬만 다른 판이 순서대로(숫자 없음). reassigned: 판 절반이 옆 새 걸이로 옮겨져 순서가 바뀌고 청동 끈으로 묶임 |
| `prop_r6_heart_petition_table` | `prop_r6_petition_draft`, `prop_r6_petition_cosigned` | 1.8 × 0.9 × 0.8 m | 청원서 + 뚜껑 덮인 청동 그릇(Hearth, 실물 장기는 안 보임)과 이어진 끈. draft: 맨 윗줄만 봉인. cosigned: 네 줄(수술·통증·거부·증인)에 모양이 다른 봉인, 끈이 서류에 고정 |
| `prop_r6_drainage_pump` | `prop_r6_pump_dry`, `prop_r6_pump_primed` | 1.2 × 1.0 × 1.5 m | dry: 손잡이 위, 받침 물통 말라 금 감, 주둥이 녹. primed: 손잡이 아래, 물통에 물, 젖은 광택, 주둥이 물줄기 |

출구·내부 길

| 자산 | 상태 그림 | 피벗 | 모양 |
|---|---|---|---|
| `exit_r6_e07_ash_chute` | `closed`, `open` | 차단봉 받침 바닥 가운데 | closed: 검표 차단봉 내려옴, 빈 표 집게. open: 차단봉 올라감 |
| `exit_r6_e08_medicine_ferry` | `closed`, `open` | 부두 앞 물 위 가운데 | closed: 부두 입구 쇠사슬 기둥, 배 없음. open: 평저선 정박, 발판 |
| `exit_r6_e14_under_rail_shunt` | `closed`, `open` | 아치 밑선 가운데(벽) | closed: 셔터 내려옴 + 레일 끝 멈춤 받침. open: 셔터 올라감, 받침 치움, 분기 레버 젖힘 |
| `exit_r6_e16_drainage_dark` | `closed`, `open` | 터널 아치 밑선 가운데(벽) | closed: 쇠창살 내려옴. open: 창살 올라감, 널빤지 다리 |
| `route_r6_drainage_pump_run` | `closed`, `open` | 수조 바닥 가운데 | closed: 검은 물이 계단 아래와 수조를 채움, 계단 위 쇠사슬. open: 물이 빠져 젖은 바닥, 쇠사슬 풀림 |

지역 오브젝트 (분위기)

| 자산 | 그림 | 크기 | 쓰는 곳 |
|---|---|---|---|
| `obj_r6_stone_stall` | 1 | 1.4 × 0.8 × 0.8 m 돌 좌판, 녹청 테 | intake_ring 4 |
| `obj_r6_parts_booth` | `a`, `b` | 1.8 × 1.2 m, 계산대 1.0 m, 황토 천막 2.2 m, 청동 관절·스프링·흐린 병·감긴 관 | stalls_drainage 3 |
| `obj_r6_wait_bench` | 1 | 1.8 × 0.5 × 0.45 m 나무 의자, 쇠 다리 | debt_hall 6 |
| `obj_r6_court_bench` | 1 | 3.0 × 0.9 × 1.3 m 판결대 | debt_hall 1 |
| `obj_r6_drain_cover` | `round`, `square` | 둥근 1.5 m, 네모 0.6 m | 세 구역 |
| `obj_r6_wall_lamp` | 1 | 벽 까치발 등, 유리 발광(`light` 색 `#ffc987`, 반지름 원본 260 px) | 세 구역 |
| `obj_r6_medicine_crates` | 1 | 약 상자 셋 쌓음 | intake_ring, stalls_drainage |
| `obj_r6_rubble` | 1 | 깨진 타일·돌 조각 더미 | stalls_drainage |

## 8. 공용 사물 자리 (세션 01 담당. 그리지 않음)

- `art_prop_route_marker`: intake_ring (360,200) 도착 단 옆, (1100,520) 부두 남쪽, (740,630) 남쪽 계단 위 / debt_hall (230,340) 레일 끝 / stalls_drainage (1080,450) 수조 위.
- `art_prop_recovery_anchor`: R6에는 회복 지점(content recovery)이 없어 자리 없음.
- `art_prop_magic_concentration_device`: R6 없음(R8 전용).

## 9. 유지할 것, 바꿀 것, 금지

- 유지: V1의 선·명암·붓자국·때 얼룩 방식, 60° 계산, 레이어 규칙.
- 바꿈: 바닥·벽 재질과 색(§5), 물체 높이를 플레이어 키 기준으로.
- 금지: 사람·적·시체·실물 장기·피·눈, 읽을 수 있는 글자·숫자, UI·HUD·focus 표시·워터마크, BLACK SOULS·Alice 고유 지형·상징, 무작위 기괴 장식, 원래 아이콘 모양이 그대로 읽히는 조각, 주 동선을 가리는 전경, 그림에 넣은 장면 조명·비네트·불빛 웅덩이, 배경에 오브젝트 합치기, 캐릭터를 배경에 얹은 미리보기, 공용 사물 3개.

## 10. 원본과 Gold Standard

- 화풍 기준: `assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/`의 V1 결과(`preview/asset_bg_h0_v1_1280x720.png`, `asset_sheet_v1_props_0.5x.png`, `output/`)와 `palette_h0_mood.json`. candidate라 승인 기준은 아니고 눈으로 맞춘다.
- Gold Standard: 없음(0개). 아이콘 원본 `addons/at-icons/node2d`(MIT)는 고치지 않는다.

## 11. 검수

- 구역별 배경+오브젝트 확인 그림(처음·다시 방문), 오브젝트 모아 보기 시트, 가장자리 잘림, 알파 가장자리, 그림자·발광 분리, 원래 아이콘 모양이 읽히는지.
- 1280×720 / 1920×1080 / 2560×1440 실제 게임 화면 검수: 게임 연결 금지라 not_run.
