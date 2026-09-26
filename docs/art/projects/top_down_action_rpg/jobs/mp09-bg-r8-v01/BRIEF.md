# R8 The Folding School — 배경·사물 brief (mp09-bg-r8-v01)

> ⚠ COMMON.md 04:25판(V1 확정) 전에 쓴 판이다. R8을 시작할 때 R6 BRIEF.md(V1판) §4·§5·§7·§9 형식으로 다시 쓴다: 배경은 base_clean + foreground만, 책상·서류장·선반·배정함·계측판·베틀·등불은 지역 오브젝트, 출구·뒷길 상태도 오브젝트, 빨랫줄 전경은 고정 구조(돌 퍼걸러 보)로 바꿈, 색은 palette_h0_mood.json을 물려받은 어두운 값, 캐릭터 합성 미리보기 없음.

작성 2026-09-27, 세션 09. 상태: **제작 전 준비.** 분위기 값(명도·채도·빛의 세기)은 톤앤매너 기준이 오면 다시 맞춘다(COMMON.md 준비 규칙). 아래 배치·재질·크기·상태 모양은 이 작업의 **작성자 설계**이고 domain 좌표가 아니다. 출력 규격·빛·선 규칙은 R6 brief(`../mp09-bg-r6-v01/BRIEF.md` §4)와 같다.

## 1. 근거

- 기존 기획 사실: `modules/top_down_action_rpg/content/regions/region_r8_folding_school.json`(topology `terraced_court_and_store`, size_class large, 랜드마크 5, 이동 축 elevation, 되돌아가기 가능, 출구 1, 내부 길 1, 다시 방문 2, 숨은 상태, concentration 값), `content/props/prop_r8_*.json` 2개, `content/recovery/rec_r8_course_repeat.json`·`rec_r8_lineage_return.json`, 02 §7.9(Course Court, Medium Store, Lineage Hall, Circulation Board, Weave Yard, Cut Chamber, Index Desk. Cut Chamber에서 E18 쪽으로 되돌아가는 course index return), §1.1, §5.2(E18), §6.1(G5), §8.9.
- 제작 계약: 13 §1·§5, 09 §12(공통 필드, 12.1, 12.2, 12.8), `docs/IMAGE_ASSET_WORKFLOW.md` §3, COMMON.md.
- 모듈 코드에는 공간 배치가 없다(`systems/field_controller.gd` 4열 임시 격자). 아래 배치는 전부 작성자 설계다.

## 2. 자산 ID와 게임 상태

- art key `art_world_r8_folding_school`. 구역 ID(작성자 설계): `bg_r8_approach_court`, `bg_r8_store_lineage`, `bg_r8_yard_chamber`.
- 첫 방문: `as_authored`, 입구이자 유일한 출구는 E18 Folding School Approach(STORY_FORCED).
- 다시 방문: `rv_after_registration`(region state `concentration_filed`) = 선반 `ps_quarantined`. `rv_after_verdict` = 절단실 벽 `ps_opened`.
- 내부 길 `course_index_return`(두 번째 방문부터 열림)은 Index Desk와 Cut Chamber를 잇는 뒷길이다. 양쪽 끝을 상태 그림으로 만든다.
- 숨은 상태(contamination 1단계)가 드러내는 것은 절단실 벽이다. 벽 상태 그림으로 충분해서 새 그림을 만들지 않는다.
- Index Desk의 과정 목록 서비스는 NPC(Mira Vask)가 맡고 content에 사물이 없다. 책상은 고정 가구로 바탕에 그린다.
- 필드 전투가 있다(field_pressure lethal: enc_r8_fold_that_refuses_the_hand, 02 §8.9의 field court encounter). 구역마다 막힘없는 바닥을 남긴다.
- NPC는 다른 세션 담당이라 그리지 않는다.

## 3. 화면 나누기 (작성자 설계)

terraced court + elevation 이동이라 1280×720 구역 3개를 아래 단에서 위 단으로 올라가는 순서로 둔다. 단 사이는 옹벽을 가르는 계단으로 잇고, 계단 위치와 폭을 양쪽에서 맞춘다. 가장자리 그림을 이어 붙이지는 않는다.

| 구역 | 랜드마크 | 출구·내부 길 | 사물 | 이어지는 곳 |
|---|---|---|---|---|
| `bg_r8_approach_court` (아래 단, 도착) | Index Desk, Course Court | E18 Approach, 뒷길의 책상 쪽 끝 | 없음 | 북쪽 큰 계단 x 560..760 → store_lineage |
| `bg_r8_store_lineage` (가운데 단) | Medium Store, Lineage Hall, Circulation Board | 없음 | 재료 저장고 선반 | 남쪽 계단 끝 x 560..760, 북쪽 계단 x 520..700 → yard_chamber |
| `bg_r8_yard_chamber` (위 단) | Weave Yard, Cut Chamber | 뒷길의 절단실 쪽 끝 | 절단실 벽 | 남쪽 계단 끝 x 520..700 |

## 4. 출력 규격

R6 brief §4와 같다: base_clean 2560×1440 불투명, master_composite, prop_*(투명, 접촉 피벗, 여백 원본 64 px, 그림자 따로, 이름은 art_key), 출구·길·전경은 2560×1440 투명 겹침판(원점 0,0), preview_reassembled 1280×720(처음 방문 + 다시 방문). 60° 정사영, 바닥 180 px/m, 깊이 ×0.866, 높이 110 px/m(플레이어 화면 키 96 px = 1.75 m). 빛은 왼쪽 위 확산광, 선·명암·붓자국은 palette_h0 `styles` 그대로.

## 5. 재질과 색 (작성자 설계, 임시)

명도·채도·빛의 세기는 톤앤매너 기준을 받으면 다시 맞춘다. 지역을 구분하는 색상 방향은 유지한다. 윤곽선·그림자·접촉 그림자·선 색 계열은 H0 그대로. **따뜻한 사암 단 + 짙은 호두나무 + 쪽빛 천 + 종이 크림색**으로 R8임을 알게 한다.

| 재질 | 쓰는 곳 | base / shadow / light |
|---|---|---|
| sandstone | 단 바닥, 옹벽, 계단 | `#c9b48f` / `#a4906c` / `#dccaa8`, 옆면 `#9c8763` |
| walnut | 저장고 마루, 선반, 책상, 베틀 | `#6a4e3b` / `#4a3629` / `#8a6a52` |
| indigo_cloth | 차양, 베틀 천, 빨랫줄 천 | `#414b73` / `#2c3452` / `#5d6891` |
| plaster | 절단실 벽과 바닥 | `#bdb2a4` / `#968b7e` / `#d3c9bc` |
| fold_sheet | 접은 종이, 빈 종이판 | `#e4dccb` / `#bfb6a2` |
| bronze, paper | H0 그대로(계기, 인쇄기, 꼬리표) | — |

## 6. 구역별 배치와 정보 중요도

좌표는 논리 px(1280×720), 원본은 ×2. 주 동선은 폭 140 px 이상을 두고 물체·전경으로 막지 않는다.

### 6.1 `bg_r8_approach_court` — 아래 단, 도착

| 요소 | 위치(논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| 북쪽 옹벽 | 앞면 y 30..140(2 m), 그 위 y 0..30에 가운데 단 바닥 | 길찾기·상황 이해 | base |
| 가운데 단 큰 계단 | x 560..760, 옹벽을 가르며 북쪽으로 올라감 | 길찾기·상황 이해 | base |
| 뒷길 옆 계단 | 옹벽 x 60..180의 좁은 계단 | 길찾기·상황 이해 | base |
| 뒷길 책상 쪽 문 | 옆 계단 발치 | 증거·직접 상호작용(두 번째 방문 결과) | `route_r8_course_index_return` (index_*) |
| 과정 목록 책상 | 앞면 바닥선 y 300, x 220..520(3.2 × 0.8 × 1.0 m), 작은 손 인쇄기. 서류장은 옹벽에 붙이고 책상과 사이에 사람이 설 틈 0.8 m | 길찾기·상황 이해 | base |
| 쪽빛 차양 | 책상 위 | 분위기 | base |
| 실습 마당 | x 580..1220, y 180..520, 청동 동심원 상감 중심 (900,350) 560×480 | 길찾기·상황 이해 / 필드 전투 공간 | base |
| E18 진입 다리와 아치 기둥 | 다리 x 520..760, y 620..720. 기둥 x 500..540 / 740..780, 바닥선 y 700, 높이 3.2 m | 길찾기·상황 이해 | base |
| E18 격자문 | 아치 기둥 사이 | 증거·직접 상호작용 | `exit_r8_e18_folding_school_approach` |
| 아치 윗보 | x 480..800, y 510..560 | 분위기 | `foreground_r8_approach_lintel` |

주 동선: 아치 → 북쪽 → 마당 → 큰 계단. 마당 서쪽 → 책상 앞(y 320 부근) → 옆 계단.

### 6.2 `bg_r8_store_lineage` — 가운데 단

| 요소 | 위치(논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| 북쪽 옹벽 | 앞면 y 30..130, 그 위 y 0..30에 위 단 바닥 | 길찾기·상황 이해 | base |
| 위 단 계단 | x 520..700 | 길찾기·상황 이해 | base |
| 아래 단에서 올라온 계단 끝 | x 560..760, y 650..720 | 길찾기·상황 이해 | base |
| 재료 저장고 마루 | x 40..500, y 130..480 호두나무 마루. 동쪽은 기둥 두 개만 두고 트임(반벽 없음) | 길찾기·상황 이해 | base |
| 재료 저장고 선반 | 피벗 (280,180), 폭 216 × 깊이 47 × 높이 121, 옹벽 앞 | 증거·직접 상호작용 | prop |
| 고정 선반 | 옹벽 앞 x 40..160 / 400..500, 저장고 안 한 줄 x 80..440, y 300..350 | 분위기 | base |
| 가문 배정함 벽 | 옹벽 앞면 x 780..1180의 칸 격자, 명패 없는 큰 칸 하나 (1100, y 60..120) | 분위기 | base |
| 순환 계측판 | 따로 선 판 x 1000..1220, 바닥선 y 430, 높이 2.2 m, 청동 계기·관 | 길찾기·상황 이해 | base |

주 동선: 아래 계단 끝 → 위 계단, 저장고 선반 앞(y 260 부근), 계측판 앞. 필드 전투 공간: x 560..980, y 180..620.

### 6.3 `bg_r8_yard_chamber` — 위 단

| 요소 | 위치(논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| 아래 단에서 올라온 계단 끝 | x 520..700, y 650..720 | 길찾기·상황 이해 | base |
| 직조 마당 뒤 낮은 담 | 앞면 x 0..600, y 60..120 | 길찾기·상황 이해 | base |
| 직조 마당 | x 40..560, y 130..620. 베틀 틀 3개 (160,300) (380,240) (240,500), 각 2.0 × 1.0 × 1.8 m, 쪽빛 천 | 분위기 | base |
| 절단실 | 바닥 x 640..1260, y 230..600(회반죽 판). 북벽 앞면 y 60..230(3.1 m). 남쪽은 기둥 (660,600) (1240,600)과 문턱 선만 | 길찾기·상황 이해 / 필드 전투 공간 | base |
| 절단실 벽 | 벽 밑선 기준점 (900,230), 폭 234 × 높이 154 | 증거·직접 상호작용 | prop(벽) |
| 뒷길 절단실 쪽 문 | 북벽 x 1120..1220(폭 1.1 m, 높이 2.2 m), 문틀은 base | 증거·직접 상호작용(두 번째 방문 결과) | `route_r8_course_index_return` (chamber_*) |
| 빨랫줄 천 조각 | x 0..420, y 640..700 | 분위기 | `foreground_r8_cloth_line` |

주 동선: 계단 끝 → 북동쪽 절단실 → 벽 앞 → 뒷길 문. 계단 끝 → 서쪽 마당.

## 7. 사물·출구·길 상태 그림

| 자산 | 상태 그림 | 실제 크기 | 놓는 곳 | 모양과 달라지는 점 |
|---|---|---|---|---|
| `prop_r8_medium_store_shelf` | `prop_r8_shelf_stocked`, `prop_r8_shelf_quarantined` | 2.4 × 0.6 × 2.2 m | store_lineage (280,180) | stocked: 빈 종이판·접은 종이·천 두루마리가 칸마다 가지런함. quarantined: 물건이 끈으로 묶이고 빈 납 꼬리표, 선반 앞을 가로 나무살과 밧줄로 막음 |
| `prop_r8_cut_chamber_wall` | `prop_r8_wall_marked`, `prop_r8_wall_opened` | 폭 2.6 × 높이 2.8 m(벽면) | yard_chamber 벽 밑선 (900,230) | marked: 회반죽에 구겨진 종이 모양으로 눌린 실패한 접기 자국(부조). opened: 자국이 갈라져 얕은 벽감이 드러나고 청동 판독 집게가 물림 |
| `exit_r8_e18_folding_school_approach` | `closed`, `open` | 문 폭 2.2 m, 높이 2.8 m | approach_court 아치 | closed: 접이식 격자문이 닫히고 빈 꼬리표. open: 격자문이 양옆으로 접혀 열림 |
| `route_r8_course_index_return` | `index_closed`, `index_open`, `chamber_closed`, `chamber_open` | 문 폭 1.1 m | approach_court 옆 계단, yard_chamber 뒷길 문 | closed: 접이 격자문에 빗장과 자물쇠(글자 없음). open: 문이 열리고 계단·통로가 보임 |

## 8. 공용 사물 자리 (세션 01 담당. 배경에 그리지 않음)

- `art_prop_route_marker`: approach_court (820,600) 아치 안쪽, (660,170) 큰 계단 발치, (120,180) 옆 계단 발치 / store_lineage (620,160) 위 계단 발치, (680,620) 아래 계단 끝 / yard_chamber (610,630) 계단 끝, (1170,300) 뒷길 문 앞.
- `art_prop_recovery_anchor`: store_lineage (280,260) 선반 앞(rec_r8_course_repeat), yard_chamber (900,300) 벽 앞(rec_r8_lineage_return).
- `art_prop_magic_concentration_device`: store_lineage (960,480) 순환 계측판 옆. R8은 농도를 재는 유일한 지역이다(02 §7.9).

## 9. 유지할 것, 바꿀 것, 금지

- 유지: 시험 작업의 선·명암·붓자국·접촉 그림자 방식, 60° 계산, 13 레이어 규칙.
- 바꿈: 바닥·벽 재질과 색(§5), 가구·구조물 높이를 플레이어 키 기준으로.
- 금지: 사람·적·시체·피·눈, 읽을 수 있는 글자·숫자(과정 목록·배정함·계기판 눈금도 무늬로만), UI·HUD·focus 표시·워터마크, BLACK SOULS·Alice 고유 지형·상징, 무작위 기괴 장식, 원래 아이콘 모양이 그대로 읽히는 조각, 주 동선을 가리는 전경, 마법 빛 효과, 공용 사물 3개 그려 넣기.

## 10. 원본과 Gold Standard

R6 brief §10과 같다. 화풍 기준은 h0-icon-collage-v01 결과(candidate)와 palette_h0.json, Gold Standard 없음, 톤앤매너 기준은 받는 중, 아이콘 원본 SVG는 고치지 않는다.

## 11. 검수 장면과 해상도

- 구역별 미리보기(처음·다시 방문), 사물·출구 모아 보기 시트, 재합성 차이 검사, 가장자리 잘림, 알파 가장자리, 그림자 잔상, 계단으로 단 높이 차이가 읽히는지.
- 세 해상도 실제 게임 화면 검수: 게임 연결 금지라 not_run.
