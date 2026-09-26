# R4 Crownwell Archive — 배경·오브젝트 brief (mp08-bg-r4-v01)

작성: 2026-09-27, 세션 08. 개정: 2026-09-27 04시 기준 확정 반영(분위기 V1, 빛·그림자는 게임 코드, 배경과 오브젝트 분리, 캐릭터를 합친 확인 그림 금지). 배치·치수·재질·모양은 전부 **작성자 설계**이며 domain 데이터를 바꾸지 않는다. 오브젝트의 정확한 자리는 `recipes/scene_<배경>.json`이 정본이다.

## 1. 근거
- region: `modules/top_down_action_rpg/content/regions/region_r4_crownwell_archive.json` — topology `vertical_stack_and_hall`, size_class `large`, landmark_count 5, traversal_axis `elevation`, internal_routes 없음.
- 지역 기획: `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/02_WORLD_STATE_AND_ROUTES.md` §7.5, §8.5, §5.2(E04/E10/E12/E13), §5.3(route state), §6.1(G0/G3/G4), §1(왕관 다섯 조각).
- 사물: `content/props/prop_r4_low_level_stacks.json`, `prop_r4_weight_lift_counter.json`, `prop_r4_glossary_slot.json`, `prop_r4_crown_fragment_plinth.json`. recovery: `content/recovery/rec_r4_crown_continuity.json`(Plinth에서 되살아남).
- 규칙: `tin_mass_production/COMMON.md`(최신 사용자 결정), 13 §1·§3·§5, 09 §3.1·§12.1·§12.2·§12.8, `docs/IMAGE_ASSET_WORKFLOW.md` §3.
- 화풍 기준: `assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/`의 V1(배경만 그림, 사물 모음 그림, `palette_h0_mood.json`).
- art key: `art_world_r4_crownwell_archive`(09 §12.10). 이 키는 아래 세 구역 묶음 전체를 가리킨다.

## 2. 납품과 실제 게임 상태
- 배경: 구역마다 `base_clean`(바닥·벽·계단·구멍 같은 고정 구조와 바닥에 납작한 무늬만) + 필요한 `foreground_*`.
- 오브젝트: content 사물(상태별), 출구 막이(`_closed`/`_open`), 이 지역에 되풀이해 놓는 물건. 한 번 만들어 세 구역에서 같이 쓴다.
- 구역마다 `recipes/scene_<배경>.json`(오브젝트 자리, 빛나는 오브젝트의 `light`)과 배경+오브젝트 확인 그림 1280×720(사람·적 없음).
- 현재 모듈은 사물·NPC·출구를 4열 임시 격자(`systems/field_controller.gd`의 `_anchor_position`)에 놓는다. 이 배치는 그 격자를 따르지 않는 작성자 설계이고 도메인 좌표로 자동 승격하지 않는다. 게임에 연결하지 않는다.

## 3. 시점·배율·빛
- 지면 기준 하향각 60° 정사영, 방위 고정, 지평선·소실점 없음. 도구의 60° 계산(바닥 깊이 ×0.866, 높이 ×0.5).
- 배율(작성자 설계, COMMON의 '사물 크기는 플레이어 키 기준'): 서 있는 사람 1.7 m = 화면 키 96 logical = 원본 192 px. 원본 기준 가로 1 m = 226 px, 바닥 깊이 1 m = 196 px, 높이 1 m = 113 px(도구 `extrude` 값).
- 대표 높이(원본 px): 난간·카운터 1.0 m = 113, 책상 0.8 m = 90, 책장 2.4 m = 271, 승강기 칸 2.6 m = 294, 벽 3.2 m = 362.
- 한 구역 = 논리 1280×720 = 원본 2560×1440 ≈ 바닥 11.3 m × 7.3 m. 아래 좌표는 구역 논리 좌표(원본 px = 논리 × 2).
- 빛: 도구의 기본 확산광과 물체 자체의 명암만. 화면 어둡게 누르기, 비네트, 불빛 웅덩이, 장면 `lighting` 없음. 바닥에 떨어지는 그림자는 `_shadow.png`로 따로(배경도 `shadow_output: separate`). 불꽃·등 유리는 `emit`으로 `_emit.png`에 따로.

## 4. 구역 나누기
랜드마크 5개(Public Record Hall, Translation Well, Weight Lift, Low-Level Stacks, Crown Observatory), traversal_axis elevation이라 **층마다 한 화면**, 세 구역.

| 구역 ID | 층 | 랜드마크 | 출구 | content 사물 |
|---|---|---|---|---|
| `bg_r4_stacks` | 지하 | Low-Level Stacks, Translation Well 바닥, Weight Lift | E12 Courier Shaft | `prop_r4_low_level_stacks` |
| `bg_r4_hall` | 지상(입구) | Public Record Hall, Translation Well, Weight Lift | E04 Crownwell Ascent, E10 Bell-Cable Lift | `prop_r4_glossary_slot`, `prop_r4_weight_lift_counter` |
| `bg_r4_observatory` | 꼭대기 | Crown Observatory, Translation Well 뚜껑 단, Weight Lift | E13 Crown Stair | `prop_r4_crown_fragment_plinth` |

- 층 이동은 Weight Lift 한 곳. 세 층 모두 승강기 구멍 중심 (1060, 330), Translation Well 중심 (420, 440)으로 같은 자리에 둬서 한 건물의 위아래로 읽히게 한다.
- internal_routes가 비어 있으므로 층 이동에 새 잠금을 그리지 않는다. 구역 경계와 층 나눔은 새 route가 아니다.


## 5. 구역별 배치와 정보 등급
등급: **증거·직접 상호작용** / **길찾기·상황 이해** / **분위기**. 표에 없는 물체는 분위기로만 취급한다(13 §3). 주 통로 폭은 논리 200 이상, 통로 위에 물체·진한 파편·글자를 두지 않는다. 북쪽 벽은 세 구역 모두 벽 밑선 y 190.

### 5.1 `bg_r4_hall` — Public Record Hall (지상, 입구 층)
| 요소 | 위치(논리) | 등급 | 어디에 |
|---|---|---|---|
| 북쪽 벽(벽기둥 포함), 점판암 바닥 | y 0..190 / 전체 | 길찾기·상황 이해 | base |
| Translation Well 구멍과 둘레 난간 | 중심 (420, 440), 외경 240, 빈 구멍 170 | 길찾기·상황 이해 | base |
| Weight Lift 승강기 구멍(바닥 틀) | 중심 (1060, 330), 220×150 | 길찾기·상황 이해 | base. 승강기 칸은 오브젝트 |
| E04 Crownwell Ascent 계단 머리 | 남쪽 끝 x 560..780, y 600..720, 남쪽으로 내려감 | 길찾기·상황 이해 | 계단 base, 막대문 오브젝트 |
| E10 Bell-Cable Lift 승강장 | 동쪽 끝 x 1150..1280, y 470..650, 벽 구멍 | 길찾기·상황 이해 | 승강장 base, 곤돌라·접이문 오브젝트 |
| Glossary Slot | 북쪽 벽면 (560, 100), 아래 가장자리 바닥에서 1.2 m | 증거·직접 상호작용 | 오브젝트(벽) |
| Weight Lift Counter | (820, 520) 부근 | 증거·직접 상호작용 | 오브젝트 |
| Translation Desk(RC-04 첫 대화 자리) | (700, 300) 부근 | 길찾기·상황 이해. content 사물이 없어서 상호작용 의미를 넣지 않음 | 오브젝트 |
| 공개 사본 책장 둘, 기름등 기둥, 벽등, 종이 흩어짐, 기록 상자 | 벽 앞과 가장자리 | 분위기 | 오브젝트 |
| 앞쪽 낮은 난간벽 | x 0..400, y 660..720 | 분위기 | foreground |

### 5.2 `bg_r4_stacks` — Low-Level Stacks (지하)
| 요소 | 위치(논리) | 등급 | 어디에 |
|---|---|---|---|
| 북쪽 벽, 먼지 낀 어두운 점판암 바닥 | y 0..190 / 전체 | 길찾기·상황 이해 | base |
| Translation Well 바닥(둥근 받침 테두리, 빛 웅덩이 없음) | 중심 (420, 440), 지름 240 | 길찾기·상황 이해 | base |
| Weight Lift 구멍 | 중심 (1060, 330) | 길찾기·상황 이해 | base |
| E12 Courier Shaft 네모 구멍 | 중심 (760, 560), 180×120 | 길찾기·상황 이해 | 구멍 base, 도르래 틀·뚜껑 오브젝트 |
| Low-Level Stacks | 북쪽 벽 앞 x 80..800 | 증거·직접 상호작용 | 오브젝트 |
| 기록 상자, 종이 흩어짐, 기름등 기둥, 벽등 | 가장자리 | 분위기 | 오브젝트 |
| 앞쪽 사다리와 등 사슬 | x 1000..1280, y 640..720 | 분위기 | foreground |

### 5.3 `bg_r4_observatory` — Crown Observatory (꼭대기)
| 요소 | 위치(논리) | 등급 | 어디에 |
|---|---|---|---|
| 북쪽 난간벽과 가는 기둥, 차가운 빛깔 바닥, 황동 자오선 줄(바닥에 박힘) | y 0..190 / 전체 | 벽은 길찾기·상황 이해, 줄은 분위기 | base |
| Translation Well 뚜껑 단(높이 0.3 m, 쇠살 뚜껑) | 중심 (420, 440), 외경 240 | 길찾기·상황 이해 | base |
| Weight Lift 구멍 | 중심 (1060, 330) | 길찾기·상황 이해 | base |
| E13 Crown Stair | 북서쪽 x 100..320, 북쪽 벽을 지나 위로 오르는 계단 | 길찾기·상황 이해 | 계단 base, 쇠창살 오브젝트 |
| Crown Fragment Plinth | 뚜껑 단 한가운데 (420, 440) | 증거·직접 상호작용 | 오브젝트 |
| 기름등 기둥, 벽등 | 가장자리 | 분위기 | 오브젝트 |
| 앞쪽 난간벽 조각 | x 880..1280, y 660..720 | 분위기 | foreground |

Weight Lift 칸(`obj_r4_weight_lift_car`)은 세 구역 모두 같은 오브젝트를 같은 자리에 놓는다.

### 5.4 다른 세션 담당 사물이 놓일 자리 (그리지 않고 바닥만 비워 둠)
- `art_prop_route_marker`: 출구마다 하나, 반지름 40. hall — E04 옆 (500, 650), E10 옆 (1100, 690). stacks — E12 옆 (900, 640). observatory — E13 옆 (360, 250).
- `art_prop_recovery_anchor`: observatory (420, 600), 반지름 50. `rec_r4_crown_continuity`가 Plinth에서 되살아나므로 그 앞.
- `art_prop_magic_concentration_device`: R4에는 두지 않는다.


## 6. 오브젝트
투명 PNG, 원본 2배, 안전 여백 논리 32(원본 64), 바닥 그림자 `_shadow.png`, 빛나는 부분 `_emit.png`. 피벗은 바닥 접촉점(앞면 바닥선 가운데). 벽에 붙는 것은 벽에 붙는 자리를 피벗으로 한다. 캔버스는 계획값이고 build 뒤 실제 값을 JOB.md에 적는다. 출력 폴더는 `output/<오브젝트 ID>/<상태 파일>.png`.

### 6.1 content 사물 (파일 이름 = content `art_key`)
| 오브젝트 ID | 상태 → 파일 | 모습 | 캔버스 / 피벗(원본) |
|---|---|---|---|
| `prop_r4_low_level_stacks` | `ps_intact` → `prop_r4_stacks_intact` | 벽에 붙여 세운 6.4 m × 0.5 m × 2.8 m 4칸 선반, 상자·두루마리. 칸마다 앞턱에 같은 무늬 하나가 되풀이됨(번역을 거부하는 한 문장. 읽을 수 없는 기호) | 1600×560 / (800, 496) |
| | `ps_filed` → `prop_r4_stacks_filed` | 한 칸이 청동 띠 두 줄과 봉인판으로 묶여 굳음, 그 칸 무늬만 진한 먹으로 메워짐 | 같음 |
| `prop_r4_weight_lift_counter` | `ps_idle` → `prop_r4_counter_idle` | 1.3 × 0.6 × 1.0 m 청동 계기대, 걸이 셋에 기록 추 셋, 기둥 위 눈금판(눈금·바늘만) | 440×440 / (220, 376) |
| | `ps_spent` → `prop_r4_counter_spent` | 걸이 셋이 비고 바늘이 끝까지 내려감, 옆 작은 셔터가 반쯤 내려옴 | 같음 |
| `prop_r4_glossary_slot`(벽) | `ps_empty` → `prop_r4_slot_empty` | 1.0 × 0.7 m 얕은 벽 틀과 빈 꽂이 한 칸 | 360×240 / (180, 176) 틀 아래 가운데, 벽면 부착점 |
| | `ps_filled` → `prop_r4_slot_filled` | 같은 칸에 색만 다른 종이 띠 두 장이 겹쳐 꽂힘(한 기술의 두 이름, 글자 없음) | 같음 |
| `prop_r4_crown_fragment_plinth` | `ps_object` → `prop_r4_plinth_object` | 1.4 × 0.8 × 1.1 m 낮은 돌 받침 위 청동 조각 다섯(부서진 고리 띠 조각. 온전한 왕관 모양·보석 없음). 받침 윗면에 조각마다 그림자 하나, 모두 다섯(내용이라 그림 안에 그림) | 448×448 / (224, 384) |
| | `ps_titled` → `prop_r4_plinth_titled` | 같은 조각, 그림자 다섯 둘레에 가는 분필선, 그림자마다 빈 종이 꼬리표 | 같음 |

- `prop_r4_glossary_slot`은 `ps_empty`가 visible:true인데 `hidden_until_condition`은 빈 동안 숨긴다. 두 상태를 다 그리고, 처음 상태 장면에서는 뺀다.
- `prop_r4_low_level_stacks`는 hidden_state의 부분 공개 대상이다. 그림은 두 상태 모두, 공개 전후 표시는 게임 쪽.

### 6.2 출구 막이
네 출구 모두 route_state `conditional`. 계단·구멍·승강장은 base, 막는 부분만 오브젝트. `locked`·`conditional`·`closed`는 `_closed`, `open`·`redirected`·`debt-bearing`은 `_open`.

| 오브젝트 ID | edge / 목적지 / gate / 필요한 것 | `_closed` / `_open` | 캔버스 / 피벗(원본) |
|---|---|---|---|
| `exit_r4_e04_crownwell_ascent` | E04 / H0 / G0 / blank form 1 | 계단 머리를 가로지르는 청동 막대문 + 빈 서식 꽂이 기둥 / 막대가 위로 들림 | 640×340 / (320, 276) 문선 가운데 |
| `exit_r4_e10_bell_cable_lift` | E10 / R3 / G3 / latency token | 곤돌라 칸 앞 접이식 쇠문 닫힘, 종 추 묶임 / 접이문 접힘 | 500×660 / (250, 596) |
| `exit_r4_e12_courier_shaft` | E12 / R5 / G4 / sealed plate | 도르래 틀 아래 뚜껑 닫힘 + 봉인 막대 / 뚜껑 열리고 운반 바구니 | 540×660 / (270, 596) |
| `exit_r4_e13_crown_stair` | E13 / R7 / G4 / archive weight | 계단 발치 쇠창살 + 추 자물쇠 / 창살이 위로 올라감 | 640×460 / (320, 396) |

E12의 반대쪽 끝(R5)도 같은 설계로 만든다.

### 6.3 이 지역에 되풀이해 놓는 물건
| 오브젝트 ID | 모습 | 캔버스 / 피벗(원본) |
|---|---|---|
| `obj_r4_weight_lift_car` | 1.9 × 1.5 × 2.6 m 쇠살 승강기 칸, 지붕 도르래, 평형추 줄 | 560×760 / (280, 696) |
| `obj_r4_translation_desk` | 2.6 × 0.9 × 0.8 m 먹 얼룩 책상, 빈 서류함 셋 | 720×420 / (360, 356) |
| `obj_r4_copy_shelf` | 1.6 × 0.45 × 2.4 m 벽에 붙여 세운 사본 책장, 묶음·두루마리 | 500×500 / (250, 436) |
| `obj_r4_record_boxes` | 1.2 × 0.8 × 0.9 m 기록 상자 더미, 끈 묶음 | 400×390 / (200, 326) |
| `obj_r4_paper_drift` | 바닥에 흩어진 빈 종이 몇 장(납작) | 340×260 / (170, 196) 바닥 가운데, 장면에서 `floor` 층 |
| `obj_r4_lamp_post` | 1.9 m 쇠 등 기둥, 유리 안 작은 불꽃(`emit`) | 210×410 / (105, 346) |
| `obj_r4_wall_lamp`(벽) | 벽 받침과 등 유리(`emit`), 바닥에서 1.9 m에 붙음 | 200×180 / (100, 116) 받침 뒤 가운데, 벽면 부착점 |

빛나는 오브젝트(`obj_r4_lamp_post`, `obj_r4_wall_lamp`)는 장면 JSON 항목에 `"light": {"color": "#ffc987", "radius": 원본px}`를 적는다(게임 코드용).


## 7. 재방문 상태
| variant | 바뀌는 오브젝트 | 구역 |
|---|---|---|
| `rv_after_canonical` | `prop_r4_stacks_filed`, `prop_r4_counter_spent` | stacks, hall |
| `rv_after_glossary_slot` | `prop_r4_slot_filled` | hall |

확인 그림은 장면 JSON을 상태별로 하나 더 만들어 뽑는다(배경+오브젝트만).

## 8. 납품 파일 (구역마다)
| 파일 | 내용 | 규격 |
|---|---|---|
| `output/bg_r4_<구역>/bg_r4_<구역>.png` + `_shadow.png` | base_clean. 오브젝트·막이·전경 없음. 코드 그림이라 오려내지 않고 처음부터 뒤쪽 표면까지 그림 | 2560×1440 불투명 / 그림자 투명, 원점 (0,0) = 논리 (0,0) |
| `output/fg_r4_<구역>_<이름>/…png` | foreground. 주 통로·오브젝트·출구를 가리지 않음 | 2560×1440 투명, 원점 같음 |
| `recipes/scene_bg_r4_<구역>.json`(+ variant) | 오브젝트 자리(원본 px, 피벗 기준), 빛나는 것의 `light`, `lighting` 없음 | compose_preview 장면 형식 |
| `preview/check_bg_r4_<구역>_1280x720.png` | 배경+오브젝트 확인 그림. 사람·적 없음. runtime 자산 아님 | 1280×720 |
| `preview/sheet_r4_objects*.png` | 오브젝트 상태 모아 보기 | review_sheet |

## 9. 재질과 색 (V1 바탕, `recipes/palette_r4.json`)
- 윤곽선·그림자·공통 색(`ink`, `shade_tint`, `shadow_contact`, `floor_joint`, `grime`, `damp`, `rust`, `soot`, `paper`, `bronze`)과 스타일(선 굵기, 붓자국, 빛 방향)은 `palette_h0_mood.json` 그대로.
- 지역 구분: 바닥은 푸른빛 도는 어두운 점판암 판석(H0의 회보라보다 차갑게, 밝기는 V1과 비슷하게). 벽은 먹빛으로 그을린 석재. 책장·책상은 짙은 옻칠 나무. 기능 부품은 V1 청동. 종이는 V1 종이색(가장 밝은 면)을 많이. 먼지·습기·먹 얼룩.
- 층 차이: 지하는 한 단계 어둡고 먼지, 꼭대기는 조금 차갑고 밝게. 전체 밝기는 V1과 비슷하게 유지한다(밝게 올리지 않는다).
- 얼룩은 크기가 다른 세 겹(작은 것, 중간, 큰 것), 겹마다 세기를 낮춰 반복 무늬로 보이지 않게 한다.
- H0 팔레트에서 바꾼 점은 JOB.md에 적는다.

## 10. 유지할 것과 바꿀 것
- 유지: V1 화풍(짙은 자주 윤곽선을 그림자 쪽에 굵게, 초승달 명암, 때·녹·습기 얼룩, 아이콘을 잘라 겹쳐 쓰기), 붓자국 설정, 60° 계산.
- 바꿈: 바닥·벽 재질과 색(지역 구분), 배율(사람 키 기준).
- 원래 아이콘 모양이 통째로 읽히는 조각(바람개비, 조리개, 지도 연결선, 아치 등)은 잘게 자르거나 겹쳐 숨긴다.

## 11. 입력과 Gold Standard
- 모양 재료: `addons/at-icons/node2d` SVG(MIT). 픽셀 입력 없음.
- 화풍 비교: V1 결과(candidate)를 눈으로만 본다. 스타일 입력이나 승인 기준으로 쓰지 않는다.
- 활성 Gold Standard 없음.

## 12. 금지
- 사람, 적, 시체, 눈(eye), 혈흔, 식물 장식. 캐릭터를 얹은 확인 그림.
- 읽을 수 있는 글자·숫자·문장. 서식·꼬리표는 빈 칸이나 뜻 없는 선으로만.
- UI, HUD, focus 표시, 워터마크, 격자·타일 이음 표시, 화면 어둡게 누르기·비네트·불빛 웅덩이.
- 원작(BLACK SOULS, Alice) 고유 지형·상징, 온전한 왕관 실루엣·보석·종교 상징. content에 없는 증거·상호작용 의미. 무작위 기괴 장식.
- 공용 사물 3개와 아이템을 그려 넣기(자리만 비움).

## 13. 검수
- 하드 게이트: 크기, 알파(오브젝트 네 귀퉁이 알파 0, 배경 불투명), 피벗, 안전 여백, 파일 이름 = ID, 글자·워터마크 없음, 사용 아이콘 해시, 가장자리 잘림 없음.
- 판독: 확인 그림에서 출구 방향, 상호작용 사물 넷, 주 통로가 먼저 읽히는가. 사람 키(192 px) 대비 카운터·책장·승강기 높이가 맞는가(치수로 확인). 세 층이 같은 건물로 읽히는가.
- 실제 게임 1280×720 / 1920×1080 / 2560×1440 검수, field focus·전투 전환은 게임 연결 금지 범위라 `not_run`.
- 결과는 전부 candidate. 승인은 사용자만 한다.
