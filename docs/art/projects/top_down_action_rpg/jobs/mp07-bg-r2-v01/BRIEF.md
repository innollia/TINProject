# R2 Siltglass Commons — 배경·오브젝트 brief (mp07-bg-r2-v01)

작성 2026-09-27, 세션 07. 04:25 KST에 확정된 기준(COMMON.md: 분위기 V1, 빛·그림자는 게임 코드, 배경과 오브젝트 분리)으로 고친 판. 화면 나누기·배치·재질·오브젝트 모양·출구 그림 ID는 전부 **작성자 설계**이고 domain 데이터가 아니다.

## 1. 근거

- 지역 원본 `modules/top_down_action_rpg/content/regions/region_r2_siltglass_commons.json`: topology `stilt_settlements_and_channels`, size_class `large`, landmark_count 5, traversal_axis `water_level`, 되돌아가기 가능. 출구 4개, 내부 길 1개, revisit_variants 2개.
- 사물 원본 `content/props/prop_r2_*.json` 5개. 회복 `content/recovery/rec_r2_census_clone.json`: 순환 굴뚝 자리에서 다시 일어난다.
- 기획: 02 §7.3 (Glasswater 둘레 말뚝 마을 셋, Seed Vault, 얕은 나루, 홍수 수로, 뿌리다리가 물높이에 따라 이어졌다 끊김), 02 §1 (출구가 막힌 이유가 현장에서 보여야 함), 03 지역 표.
- 규칙: 13 §1·§3, 09 §12.1·§12.2·§12.8, 09 §3.1 (플레이어 기준점 (640,418)), 09 §5.1 (대화 띠 y=552..720), IMAGE_ASSET_WORKFLOW §3, `tin_mass_production/COMMON.md`.
- 화풍 기준: 분위기 시험 `h0-icon-mood-v02`의 V1 (`preview/asset_bg_h0_v1_1280x720.png`, `preview/asset_sheet_v1_props_0.5x.png`). candidate, Gold Standard 없음.

## 2. 출력·시점·크기·빛

- 화면 한 장 = 논리 1280×720 = 원본 2560×1440, sRGB. 원본 2 px = 논리 1 px. 아래 표의 좌표는 논리 좌표의 바닥면 위치다.
- 시점: 지면 기준 60° 정사영, 방위 고정. 바닥 가로 1 m = 원본 180 px, 깊이 ×0.866.
- 높이: 플레이어 몸 높이(원본 약 186 px)를 1.7 m로 보고 **1 m ≈ 원본 110 px** (COMMON "사물은 플레이어 키 기준"). 예: 허리 높이 1 m = 110 px, 문 2.2 m = 240 px.
- 빛: 도구의 기본 확산광과 물체 자체 명암만. 화면 어둡게 누르기·비네트·빛 웅덩이·장면 `lighting` 없음. 빛나는 부분은 `emit`으로 `_emit.png`에 따로, 장면 JSON에 게임 코드용 `light`(색, 반지름)를 적는다.
- 배경 그림(13 §1 중): `base_clean`(바닥·물·벽·말뚝·데크·계단 같은 고정 구조와 바닥에 납작한 무늬), `foreground_*`(캐릭터 앞을 가리는 고정 구조, 투명). `master_composite`·`preview_reassembled`·`prop_*` 레이어 대신 오브젝트와 장면 JSON을 쓴다.
- 오브젝트: 떼어 놓거나 다른 곳에 또 놓을 수 있는 물건은 전부 따로 만든다. 투명 PNG, 원본 2배, 그림 둘레 여백 64 px, 접촉 그림자 `_shadow.png` 따로, 빛나는 부분 `_emit.png` 따로. 한 번 만들어 이 지역 배경 여러 장에서 같이 쓴다.
- 피벗: 바닥에 선 것 = 앞쪽 바닥선 가운데 / 벽에 붙은 것 = 붙는 벽의 밑선(바닥과 만나는 점) / 물에 박힌 것 = 수면에 닿는 점 / 출구·내부 길 = 통로 문턱 가운데.
- 장면 JSON: 배경마다 `recipes/scene_<구역>.json`(compose_preview 형식, items에는 오브젝트만, `lighting` 없음). 이걸로 배경+오브젝트 확인용 그림(1280×720, 사람·적 없음)을 만든다.
- 좌표는 제안값이다. 길 폭과 이음 위치를 지키는 안에서 만들며 조정하고, 바꾼 값은 JOB.md에 적는다.

## 3. 화면 구역 나누기

size_class large, 랜드마크 5, 출구 4, 내부 길 1이라 물길을 따라 남→북 3구역으로 나눈다. 구역 경계는 걸어서 이어지는 화면 이음일 뿐 새 route가 아니다.

| 구역 ID | 이름 | 랜드마크 | 출구·내부 길 | content 사물 |
|---|---|---|---|---|
| `r2_a_sluice_landing` | 수문 나루 (첫 화면) | Glasswater 가장자리, 얕은 나루 | E02 Sluice Road (남, H0로), E08 Medicine Ferry (서, R6로) | waterline_mark |
| `r2_b_stilt_settlements` | 말뚝 마을 | 말뚝 마을 셋 | E17 Water Ambulance Bridge (동, R3로) | disperser_housing, circulator_stack |
| `r2_c_root_bridge_seed_vault` | 뿌리다리와 종자 저장고 | 홍수 수로·뿌리다리, Seed Vault | E09 Orchard Causeway (북, R7로), 내부 길 `flood_refuge_gallery` | root_bridge_anchor, seed_vault_shelf |

- 이음: A 위쪽 널판 길 x=560..740 ↔ B 아래쪽 x=560..740. B 위쪽 널판 길 x=380..520 ↔ C 아래쪽 x=380..520. 이음의 길 폭·재질은 양쪽 그림에서 같게.
- 화면 위쪽에는 다음 목적지가 보이게 한다: A 위쪽에 마을 쪽 널판 길과 말뚝, B 위쪽에 C로 가는 널판 길, C 위쪽에 둑길과 저장고.

## 4. 구역별 배치와 정보 등급

### A `r2_a_sluice_landing` — 수문 나루

| 요소 | 위치 (논리) | 정보 등급 | 그림 |
|---|---|---|---|
| Glasswater 수면 | 화면 대부분 (둑·개흙·데크 밖) | 길찾기·상황 이해 | base |
| Sluice Road 둑길 | 아래 가장자리 x=550..730, y=590..720 | 길찾기·상황 이해 | base |
| 주 널판 길 | x=560..740, 둑길 끝에서 위쪽 이음까지 | 길찾기·상황 이해 | base (가장자리 말뚝·밧줄 포함) |
| 나루 잔교 | x=0..560, y=300..420 (앞면 y=420..450) | 길찾기·상황 이해 | base |
| 개흙 둑 | 서남쪽 x=0..530, y=460..720 / 동남쪽 x=750..1280, y=590..720 | 분위기 | base |
| 수위 말뚝 셋 | (800,220), (810,275), (820,330) | 길찾기·상황 이해 | base |
| 수위 표시 | 세 번째 말뚝 (820,330) | 증거·직접 상호작용 | `prop_r2_waterline_mark` |
| 수문 차단봉 (E02) | 둑길 (640,650) | 증거·직접 상호작용 | `exit_r2_e02_sluice_road` |
| 나룻배 자리 (E08) | 잔교 서쪽 끝 (120,370) | 증거·직접 상호작용 | `exit_r2_e08_medicine_ferry` |
| 통행료 초소 (`service_r2_sluice_road_toll` 자리) | 둑길 서쪽 (470,610) | 길찾기·상황 이해 | `obj_r2_toll_booth` |
| 등불 기둥 | (555,500), (745,190), (210,305) | 분위기 | `obj_r2_lantern_post` |
| 물통 | (280,350), (410,630) | 분위기 | `obj_r2_water_cask` |
| 계류 말뚝 줄 | x=0..400, y=640..720 | 분위기 | `foreground_mooring_piles` |

### B `r2_b_stilt_settlements` — 말뚝 마을

| 요소 | 위치 (논리) | 정보 등급 | 그림 |
|---|---|---|---|
| 가운데 공용 데크 | x=400..880, y=370..570 | 길찾기·상황 이해 | base |
| 마을 1 (서) 데크와 집 | 데크 x=40..340, y=200..500, 집 앞 벽 밑선 y=200 | 길찾기·상황 이해 | base |
| 마을 2 (북) 데크와 물 위원회 건물 | 데크 x=560..900, y=40..300, 건물 앞 벽 밑선 y=240 | 길찾기·상황 이해 | base (실트유리 벽돌) |
| 마을 3 (동) 데크와 집 | 데크 x=940..1240, y=180..470, 집 앞 벽 밑선 y=220 | 길찾기·상황 이해 | base |
| 데크를 잇는 널판 다리 | 공용 데크 ↔ 마을 1·2·3 | 길찾기·상황 이해 | base |
| C로 가는 널판 길 | x=380..520, 공용 데크에서 위쪽 이음까지 | 길찾기·상황 이해 | base |
| 분사기 함 | 마을 2 건물 앞 벽 (640,240) | 증거·직접 상호작용 | `prop_r2_disperser_housing` |
| 순환 굴뚝 | 마을 3 집 앞 벽 (1060,220) | 증거·직접 상호작용 | `prop_r2_circulator_stack` |
| 들다리 (E17) | 마을 3 데크 동쪽 끝 (1220,430) | 증거·직접 상호작용 | `exit_r2_e17_water_ambulance_bridge` |
| 그물 건조대 | 마을 1 데크 (190,400) | 분위기 | `obj_r2_net_rack` |
| 물통·등불 기둥 | 공용 데크 가장자리 | 분위기 | `obj_r2_water_cask`, `obj_r2_lantern_post` |
| 공용 데크 앞 난간 | 널판 길 입구 양옆, y=520..570 | 분위기 | `foreground_deck_rail` |

### C `r2_c_root_bridge_seed_vault` — 뿌리다리와 종자 저장고

| 요소 | 위치 (논리) | 정보 등급 | 그림 |
|---|---|---|---|
| 남쪽 둑 | x=0..900, y=480..620 | 길찾기·상황 이해 | base |
| 홍수 수로 | y=260..470, 동쪽은 저장고 언덕에서 끝남 | 길찾기·상황 이해 | base |
| 북쪽 둑과 바깥 물 | 둑 y=140..260, 그 위는 물 | 길찾기·상황 이해 | base |
| 피난 회랑 (높은 말뚝 위 널판 통로) | 다리 북쪽 끝 (310,230) → 저장고 테라스 (900,330), 첫 칸은 비어 있음 | 길찾기·상황 이해 | base |
| 종자 저장고와 앞 테라스 | 건물 x=900..1250, y=40..300, 테라스 y=300..360, 앞 벽 가운데 빈 벽감 | 길찾기·상황 이해 | base (실트유리 벽돌) |
| 뿌리다리 | 닻 기둥 (310,490), 몸통 x=240..380이 수로를 건넘 | 증거·직접 상호작용 | `prop_r2_root_bridge_anchor` (바닥 레이어) |
| 종자 선반 | 벽감 안 (1070,300) | 증거·직접 상호작용 | `prop_r2_seed_vault_shelf` |
| 둑돌 길 (E09) | 북쪽 가장자리 (320,70) | 증거·직접 상호작용 | `exit_r2_e09_orchard_causeway` |
| 회랑 입구 (내부 길) | (380,230) | 증거·직접 상호작용 | `route_r2_flood_refuge_gallery` |
| 등불 기둥·물통 | 남쪽 둑, 테라스 | 분위기 | `obj_r2_lantern_post`, `obj_r2_water_cask` |
| 뿌리 뭉치 | x=0..300, y=630..720 | 분위기 | `foreground_root_tangle` |

## 5. content 사물 5개

| 사물 · 피벗 | 상태 → 프레임 이름 (art_key) | 모양 | 크기 |
|---|---|---|---|
| `prop_r2_waterline_mark` · 수면에 닿는 점 | `prop_r2_waterline_low`: 세 번째 말뚝에 박은 좁은 눈금판, 칠한 띠가 낮은 곳<br>`prop_r2_waterline_raised`: 띠를 위로 옮겨 새로 칠함, 서명 대신 매듭 끈 꼬리표, 옛 띠 자리는 옅은 자국<br>`prop_r2_waterline_spent`: content에서 `visible:false`. 칠이 다 벗겨진 판을 선택 그림(trace)으로 | 숫자 없이 새김 눈금만. `visible_from any`라 가장 또렷하게 | 폭 0.25 m, 수면 위 2.8 m |
| `prop_r2_seed_vault_shelf` · 앞쪽 바닥선 가운데 | `prop_r2_shelf_counted`: 칸 4개에 종자 상자 3개와 빈 칸 1개<br>`prop_r2_shelf_reissued`: 빈 칸에 뚜껑 색이 다른 새 상자, 이름표는 빈 칸 | 처음에 숨는 사물. 벽감은 선반 없이도 자연스럽게 | 폭 1.6 m, 깊이 0.45 m, 높이 1.5 m |
| `prop_r2_root_bridge_anchor` · 남쪽 닻 기둥 밑 | `prop_r2_bridge_locked`: 뿌리를 엮은 다리 몸통이 물속에 어둡게 비치고 닻 기둥 사슬이 죔쇠로 잠김<br>`prop_r2_bridge_raised`: 몸통이 물 위로 올라옴, 물 흘러내린 자국, 사슬이 권양기에 감김<br>`prop_r2_bridge_surveyed`: raised + 측량 말뚝, 천 조각, 분필 선 | 장면에서 바닥 레이어(배우 아래) | 폭 1.55 m, 수로 폭만큼 길이 |
| `prop_r2_disperser_housing` · 벽 밑선 | `prop_r2_disperser_full`: 녹청 구리 함, 깔때기 투입구에 흰 가루, 아래 그물 배출구<br>`prop_r2_disperser_empty`: 투입구가 비고 뚜껑이 열림, 옆 꽂이에 빈 카드 | 연기·안개는 그리지 않음 | 폭 0.9 m, 높이 1.4 m, 바닥 위 0.6 m |
| `prop_r2_circulator_stack` · 벽 밑선 | `prop_r2_circulator_idle`: 벽을 타고 오르는 배기관, 꼭대기 바람 갓, 닫힌 댐퍼, 장부 판에 빈 꽂이 칸 하나<br>`prop_r2_circulator_vented`: 댐퍼 열림, 배출구 둘레 그을음 줄, 바람 갓이 동쪽으로 돌아감, 빈 칸에 꼬리표 | 회복해서 다시 일어나는 자리 | 관 지름 0.5 m, 높이 4 m |

## 6. 출구·내부 길과 지역 오브젝트

출구·내부 길은 `closed`/`open` 두 프레임씩. 닫힌 그림은 왜 못 지나가는지 현장에서 보이게 한다(02 §1).

| 오브젝트 | 근거 | closed | open |
|---|---|---|---|
| `exit_r2_e02_sluice_road` | `route_e02_sluice_road` → H0, gate G0 + 종자 상자 보유 | 둑길을 가로지른 차단봉이 내려감 | 차단봉이 세워져 둑길이 열림 |
| `exit_r2_e08_medicine_ferry` | `route_e08_medicine_ferry` → R6, gate G2 | 잔교 끝 두 말뚝 사이에 사슬, 배 없음 | 나룻배가 붙고 발판이 걸림 |
| `exit_r2_e17_water_ambulance_bridge` | `route_e17_water_ambulance_bridge` → R3, gate G2 | 들다리가 세워져 있고 들것 걸이가 빔 | 들다리가 내려와 들것 레일이 보임 |
| `exit_r2_e09_orchard_causeway` | `route_e09_orchard_causeway` → R7, gate G7, 뿌리다리 `ps_surveyed` 필요, STORY_FORCED | 둑돌이 물에 잠겨 말뚝 끝만 보이고 가지 문이 닫힘 | 둑돌이 드러나고 가지 문이 열림 |
| `route_r2_flood_refuge_gallery` | 내부 길 (뿌리다리 → 저장고, 수위 표시 `ps_raised` 필요) | 입구 덧문이 닫히고 발판 널이 옆에 쌓임 | 덧문이 열리고 첫 칸에 발판이 깔림 |

지역 오브젝트 (작성자 설계, 한 번 만들어 세 구역에서 같이 씀):

| 오브젝트 | 모양 | 빛 (게임 코드용) |
|---|---|---|
| `obj_r2_lantern_post` | 젖은 나무 기둥 2.4 m, 쇠 팔에 매단 등불 | `#ffc987`, 반지름 300 |
| `obj_r2_toll_booth` | 갈대벽·초가지붕의 작은 초소, 빈 창구, 글자 없는 표찰 | 없음 |
| `obj_r2_water_cask` | 쇠테 두른 물통, 뚜껑과 국자 | 없음 |
| `obj_r2_net_rack` | 기둥 둘과 가로대, 걸어 말리는 그물 | 없음 |

## 7. 다시 방문 (revisit_variants)

- `rv_after_circulation` (순환 굴뚝 `ps_vented`): 굴뚝 `vented`와 분사기 함 `empty` 프레임으로 보여 준다.
- `rv_after_ration_filed` (자원 붕괴 시계 3단계): 수위 표시 프레임(`raised` 또는 `spent`)으로 보여 준다.
- 배경은 바꾸지 않는다.

## 8. 재질과 색 (`recipes/palette_r2.json`)

`palette_h0_mood.json`을 바탕으로 윤곽선·그림자·공통 색과 전체 밝기(V1 수준)를 그대로 두고, 지역 재질만 더한다. H0(마른 회보라 광물 바닥)와 한눈에 구별되게 한다.

- 바닥: 물에 바랜 회녹색 널판 데크, 검은 틈. 낮은 곳은 황회색 개흙.
- 물: 탁한 어두운 청록(Glasswater), 개흙 구름, 잔물결은 옅게. 말뚝과 둑에 밝은 개흙 물때 줄.
- 벽: 갈대·널판 벽과 초가지붕, 젖은 검갈색 말뚝. 물 위원회 건물과 종자 저장고는 개흙을 구워 굳힌 반투명 녹갈색 벽돌(실트유리).
- 쇠붙이: 녹청이 슨 구리. H0의 탁한 청동과 구별.
- 얼룩: 크기가 다른 두세 겹으로 나누고 겹마다 세기를 낮춘다(COMMON 약점 반영).

## 9. 유지·변형, 원본

- 유지: V1의 조합 방식과 칠하기 규칙(아이콘을 잘라 겹치기, 그림자 쪽이 굵은 짙은 자주 윤곽선, 초승달 명암, 붓자국 설정 그대로, 때·녹·습기 얼룩), 60° 계산.
- 변형: 재질과 색(지역 구분), 오브젝트 모양(§5·§6).
- 원본: 모양 재료는 `addons/at-icons/node2d` SVG(MIT). Gold Standard 없음.

## 10. 금지

- 사람, 적, 시체, 동물, 눈, 이빨, 혈흔, 왕관 모양, 무작위 기괴 장식.
- 읽을 수 있는 글자와 숫자(수위 눈금·장부·카드·이름표 포함), UI, 격자, 워터마크.
- BLACK SOULS·Alice 고유 지형·상징 복제.
- 뿌리다리 말고 장식용 식물.
- 원래 아이콘 모양이 그대로 읽히는 조각(구명환, 물방울, 사슬, 톱니, 바람개비, 아치 등).
- 공용 사물 3개(`art_prop_route_marker`, `art_prop_recovery_anchor`, `art_prop_magic_concentration_device`)와 아이템을 그리기.
- 배경에 옮길 수 있는 물건(등불, 통, 상자, 선반, 잔해 더미 등)을 그려 넣기. 장면 조명·비네트·바닥에 합친 그림자.
- 주 통로·이음·출구 문턱을 foreground나 오브젝트로 가리기.

## 11. 그리지 않고 비워 둘 자리

- 길 표시(`art_prop_route_marker`, 세션 01): 출구 옆. A (760,650), (230,330) / B (1150,370) / C (420,120).
- 회복 닻(`art_prop_recovery_anchor`, 세션 01): 순환 굴뚝 앞 (1060,300).
- 마력 농도 장치(`art_prop_magic_concentration_device`, 세션 01): 분사기 함 앞 (700,320).
- NPC가 설 빈 데크: A 수위 말뚝 앞 널판 길 (650,400) — 첫 대화 `conv_r2_water_round` 자리. B 공용 데크 가운데.

## 12. 만들 파일

| 묶음 | 파일 (`output/<이름>/`) | 장수 |
|---|---|---|
| 배경 | 구역마다 `base_clean.png` + foreground 1장 (A `foreground_mooring_piles`, B `foreground_deck_rail`, C `foreground_root_tangle`) | 6 |
| content 사물 | §5 프레임 (수위 3, 선반 2, 다리 3, 분사기 2, 굴뚝 2) | 12 |
| 출구·내부 길 | §6 closed/open (5 × 2) | 10 |
| 지역 오브젝트 | §6 표 | 4 |
| 장면·검수 | `recipes/scene_<구역>.json` 3개, `preview/check_<구역>_1280x720.png` 3장, 오브젝트 모아 보기 시트 | — |

## 13. 검수

- 하드 게이트: 크기(배경 2560×1440 불투명, foreground·오브젝트 투명 PNG), 네 귀퉁이 알파, 피벗·64 px 여백, 글자 없음, 출처·해시 기록.
- 배경에 옮길 수 있는 물건·사람·장면 조명이 들어가지 않았는가.
- 구도: 주 통로와 다음 이동 방향이 먼저 읽히는가. 증거 사물은 또렷하고 분위기 요소는 대비가 낮은가.
- 이음: A↔B, B↔C 널판 길의 폭·위치·재질이 맞는가.
- 대화 띠(y=552..720)가 올라와도 수위 표시·분사기·굴뚝·다리·선반이 가려지지 않는가.
- 프레임끼리 같은 피벗에서 흔들림이 없고 상태가 한눈에 구별되는가.
- 크기: 플레이어 키 대비 허리 높이·문 높이. 캔버스 가장자리 잘림.
- 얼룩이 반복 무늬처럼 보이지 않는가.
- 실제 게임 1280×720 / 1920×1080 / 2560×1440: 게임 연결 금지라 `not_run`.
