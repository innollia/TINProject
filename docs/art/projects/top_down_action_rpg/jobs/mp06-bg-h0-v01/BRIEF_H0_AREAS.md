# H0 The Undersign Exchange — 구역 나누기 brief (mp06-bg-h0-v01)

작성 2026-09-27, 세션 06. 상태: spec_ready 초안, 그림 없음. 톤앤매너(분위기 기준)가 확정되면 §8 색·재질을 먼저 다시 맞춘다. 결과는 전부 candidate이고 승인은 사용자만 한다.

구역 A의 배치 정본은 기존 brief [`h0_layered_environment_pilot.md`](../../asset_briefs/h0_layered_environment_pilot.md)다. 이 문서는 H0 전체를 화면 4개로 나누는 방식, B·C·D 구역, 모든 구역의 레이어와 상태 그림을 정한다. 구역 이름·좌표·치수·재질·상태 표현은 **작성자 설계**이며 domain 데이터 변경이 아니다.

## 1. 근거 (기존 기획 사실)

- region JSON: topology `ring_shelf_well` / `large` / landmark 4 / `elevation`. 출구 5개: E01 `open`(조건 없음), E02~E05 `conditional`(G0 열림 + 자원 1). 내부 경로 `return_desk_lift`(arrival_well → return_desk, 조건: map `ps_contested`). service `service_h0_return_desk`. revisit `rv_after_filing`(map), `rv_after_rationing`(counter). resident `npc_01_ilyra_senn`. 전투 없음(encounter 0).
- 02 §7.1: 건조한 중앙 선반 위 원형 Arrival Well, 네 방향 계단·tram·수로, 중앙 Counterweight Map, 지하 return lift, 항상 비어 있는 Crown Well 위쪽 그림자. §5.2 출구 형태: E01 Ash Stair, E02 Sluice Road, E03 Mercy Causeway, E04 Crownwell Ascent, E05 Foundry Tram. H0-02: 지도 우선 탐색과 우회.
- prop JSON: counter `ps_open`(초기) / `ps_rationing`, layer prop. map `ps_matched`(초기) / `ps_contested`(카드 한 장이 precedence 줄로 다시 인쇄됨), layer floor. 둘 다 collides false.
- 08: checkpoint는 H0의 recovery/service에 둘 수 있다.
- 13 §1 레이어, §3 정보 우선순위, §5 분리 규칙. 09 §12.1 배경, §12.2 사물.

## 2. 나누는 방식

```text
                 E04 Crownwell Ascent (북서, 위로)
                          |
E02 Sluice Road (서) -- [B 교환 선반] -- E05 Foundry Tram (동)
                          |  Counterweight Map, Crown Well
                          |  (G0 관문을 지나감. 막지 않음)
                    [A 도착 접근] ------ [C 반환 창구] -- E03 Mercy Causeway (동)
                          |  Arrival Well, counter       return desk, return lift
                    [D 재 계단]
                          |
                 E01 Ash Stair (남, 아래로 R1)
```

- 랜드마크 4개(Arrival Well, Counterweight Map, Crown Well, return lift)와 출구 5개를 1280×720 화면 4개에 나눈다. 가운데 A에서 북 B, 동 C, 남 D로 이어진다.
- 02의 "중앙의 Counterweight Map"은 출구 세 개가 갈라지는 B의 가운데로 해석한다. 기존 brief가 A에 지도를 넣지 말라고 했기 때문이다.
- 화면 사이 이동은 화면 가장자리 통로(내부 연결)다. 새 route ID를 만들지 않는다. 출구 5개는 화면 경계 통로로 대신하지 않고, 각 구역 안의 실제 구조물로 그린다.
- 이음매: 맞닿는 통로 범위를 같게 한다. A 북 x=550..710 ↔ B 남 x=550..710, A 동 y=400..550 ↔ C 서 y=400..550, A 남 x=540..720 ↔ D 북 x=540..720.
- 내부 경로 `return_desk_lift`는 Arrival Well 아래에서 반환 창구로 올라오는 지하 승강기로 본다. 승강기 칸은 C에만 그리고, A 쪽 끝은 우물 바닥 아래(보이지 않음)에 둔다. 그래서 A의 기존 배치는 바꾸지 않는다.

## 3. 모든 구역 공통

| 항목 | 값 |
|---|---|
| 캔버스 | 2560×1440(논리 1280×720 ×2), sRGB. master·base는 불투명, 나머지 레이어는 투명 |
| 카메라 | 지면 기준 60° 정사영, 방위 고정(북쪽을 보고 내려다봄). 바닥 깊이 ×0.866, 앞면 높이 ×0.5. 소실점·지평선 없음 |
| 크기 | 플레이어 그림 높이 190 px(원본, 시험 작업 idle_down 측정) ≈ 1.7 m. 원본 기준 가로 1 m ≈ 224 px, 바닥 깊이 1 m ≈ 194 px, 높이 1 m ≈ 112 px(논리는 절반). 예: 허리 높이 1.0 m → 112 px, 문 2.3 m → 258 px. 시험 작업의 180 px/m보다 약 1.24배 |
| 기존 좌표 | 기존 brief가 정한 A의 논리 좌표는 바꾸지 않는다. 새 크기 기준에서 A의 통로 폭은 약 1.4~1.6 m가 된다 |
| 빛 | 상부 확산광, 넓은 면의 값 분리, 국소 접촉 그림자. 스포트라이트·비네트 없음. 그림자 방향·초승달 명암·윤곽선 두께·붓자국 설정은 시험 작업과 같게 |
| 통로 | 주 통로 폭 논리 140 이상, 보조 통로 100 이상. 사물·파편·진한 무늬로 막지 않는다 |
| 방향과 가독성 | 방위가 고정이라 동·서를 향한 면은 보이지 않는다. 문·격자처럼 면이 읽혀야 하는 것은 북쪽 벽(앞면이 보임)에 두고, 동·서 끝 출구의 차단물은 굵은 봉·말뚝·덩어리로 만든다 |
| 가림 | base는 플레이어보다 늘 아래에 그려진다. 키 큰 고정 구조물은 북쪽 벽에 붙이거나, 그 그림이 덮는 바닥을 걸을 수 없게 둔다. 뒤로 걸어 들어갈 수 있는 키 큰 물체는 base에 넣지 않고 분리 레이어로 만든다(13 §5 가림 대상) |
| 사물 파일 | 투명 PNG, 사방 32 px(원본) 안전 여백. 피벗: 서 있는 사물은 앞면 바닥선 가운데, 바닥에 깔린 사물은 바닥 모양 가운데. 접촉 그림자는 `_shadow` 별도 파일. 배치 좌표와 피벗은 json에 기록 |
| 상태 그림 | 상태에 따라 바뀌는 부분만 레이어로 분리하고, 고정 구조는 base에 남긴다. 치운 자리는 base에서 복원한다 |
| 금지 | 사람·적·시체·눈·식물·왕관·혈흔·읽을 수 있는 글자·도장 기호·UI·격자·워터마크, 원작(BLACK SOULS, Alice) 고유 요소, 원래 아이콘 모양이 그대로 읽히는 조각 |
| 공용 사물 | route marker, recovery anchor, magic concentration device는 세션 01 담당. 그리지 않고 아래 표의 자리만 비운다. magic concentration device는 H0 content에 근거가 없어 자리를 두지 않는다 |
| 사람 자리 | 사람은 그리지 않는다. 서 있을 빈 바닥만 남긴다 |

정보 등급: **증거·직접 상호작용** / **길찾기·상황 이해** / **분위기**. 표에 없는 물체는 분위기로만 취급하고 대비를 낮춘다.

## 4. 구역 A `h0_a_arrival_approach` (기존 brief 그대로 + 관문 상태)

초점: Arrival Well(랜드마크)과 counter(상호작용).

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| Arrival Well | 중심 (790,290), 외경 220, 낮은 원형 테와 비어 있는 안쪽 | 길찾기 | base |
| 주 통로 | 남 x=540..720 → 가운데 → 북 x=550..710, 우물 왼쪽 우회 폭 140 이상 | 길찾기 | base |
| 동쪽 연결(→C) | y=400..550, x=1040..1280 | 길찾기 | base |
| 접수 counter `prop_h0_ration_counter` | 중심 (250,265), 바닥 260×110, 앞면 높이 1.0 m | 증거·직접 상호작용 | `ps_open`(창구 열림, 빈 서식) / `ps_rationing`(배급 쟁반·토큰이 올라옴). 글자·도장 기호 없음 |
| G0 관문 `gate_g0_arrival_declaration` | 북 통로 위 끝. 여는 폭 = 통로 x=550..710, 문턱 바닥선 y≈155, 기둥 높이 2.4 m | 길찾기 | `closed`(선언 전: 위쪽 청동 서류판이 비어 곧게 걸림, 옆 받침대의 도장이 덮개 아래) / `open`(선언 후: 덮개가 열려 도장이 서 있고 서류판이 옆으로 젖혀 올라감). **두 상태 모두 통로를 막지 않는다** |
| 전경 가로보 `foreground_beam` | x=70..440, y=570..615 | 길찾기 | foreground, 주 통로를 가리지 않음 |
| 낮은 외곽 벽 | 화면 좌우 끝, 출입구 제외 | 길찾기 | base |
| 마모·조인트 | 표면 | 분위기 | base, 낮은 대비 |
| 사람 자리 | counter 앞 (250,360) — resident Ilyra | — | 빈 바닥 |

G0를 막지 않는 이유: G0는 E02~E05의 조건일 뿐이고 A–B 사이 이동에는 조건이 없다. 지도(B)는 선언 전에도 볼 수 있어야 한다(H0-02). 막힌 문을 그리면 실제로 갈 수 있는 길이 막혀 보인다.

## 5. 구역 B `h0_b_exchange_shelf`

초점: Counterweight Map(상호작용), Crown Well(랜드마크). 출구 세 개가 여기서 갈라진다.

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| 남쪽 연결(→A) | x=550..710, y=620..720 | 길찾기 | base |
| Counterweight Map `prop_h0_counterweight_map` | 중심 (640,455), 팔각 바닥 약 230×120(약 2.0×1.2 m) | 증거·직접 상호작용 | `ps_matched`(카드 칸과 추 눈금이 맞음) / `ps_contested`(카드 한 장이 가로줄이 하나 더 있는 새 카드로 바뀌고, 빈 카드 칸 하나와 빚 표식 칸 하나가 추가됨). 글자 없음 |
| Crown Well | 중심 (700,200), 외경 240, 비어 있음 | 길찾기 | base. 덮은 구조물은 화면 위 밖에 있어 보이지 않고, 우물과 그 둘레 바닥에 큰 그림자만 드리운다. 우물 북쪽은 벽이라 걸을 수 없다. 왕관 없음 |
| E04 Crownwell Ascent `route_e04_crownwell_ascent` | 북서 x=200..380, 바닥 y≈230에서 화면 위로 오르는 넓은 계단 | 길찾기 | 계단은 base. `conditional`(계단 아래 격자문 닫힘) / `open`(격자문 열려 옆으로 접힘) |
| E02 Sluice Road `route_e02_sluice_road` | 서쪽 끝, 길 y=400..520, 북쪽 옆 마른 돌 수로 y=380..400 | 길찾기 | 길·수로는 base(얕은 물줄기 한 줄). `conditional`(돌 말뚝 두 개 사이 굵은 수문 들보가 길을 가로막음, x≈150) / `open`(들보가 말뚝 위로 올라감) |
| E05 Foundry Tram `route_e05_foundry_tram` | 동쪽 끝, 레일 두 줄 y=430·490(x=1000..1280), 남쪽 낮은 승강대 x=1020..1200, y=520..560 | 길찾기 | 레일·승강대는 base, 전차 차량은 그리지 않음. `conditional`(말뚝에 달린 차단봉이 레일 위로 내려옴, x≈1060) / `open`(차단봉이 섬) |
| 전경 `foreground_south_rail` | 남쪽 끝 낮은 난간 x=0..500, x=760..1280, y=660..720 | 길찾기 | foreground. 남쪽 연결 x=550..710은 비움 |
| 빈 카드 꽂이, 마모 | 벽과 바닥 | 분위기 | base |
| 공용 자리 | route marker: E02 (250,560), E04 (420,250), E05 (1000,560) | — | 빈 바닥 |

주 동선: 남쪽 입구 (630,700) → 지도 (640,455) → 서(E02), 동(E05), 북서(E04, Crown Well 왼쪽으로).

## 6. 구역 C `h0_c_return_desk`

초점: return desk(서비스), return lift(내부 경로).

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| 서쪽 연결(→A) | y=400..550, x=0..120 | 길찾기 | base |
| return desk `prop_h0_return_desk` (service `service_h0_return_desk`, 미술 설계 ID) | 북쪽 벽, 앞면 바닥선 가운데 (500,250), 폭 약 2.6 m(논리 290), 깊이 0.7 m, 앞면 높이 1.1 m. 뒤 벽에 창살 창구, 빈 서식 칸 | 증거·직접 상호작용 | 한 상태. 글자·도장 기호 없음. 창구 뒤 y≈200..240에 직원이 설 자리 비움 |
| return lift `return_desk_lift` | 창구 오른쪽, 북쪽 벽에 붙음. 바닥 중심 (840,245), 약 170×150, 승강로 틀 높이 2.6 m, 남쪽을 향한 격자문 | 길찾기 | 틀은 base. `conditional`(격자문 닫힘, 받침판이 내려가 있어 어두운 구멍) / `open`(격자문 열림, 받침판이 바닥 높이로 올라옴) |
| E03 Mercy Causeway `route_e03_mercy_causeway` | 동쪽 끝 y=300..460, 낮은 기둥 위 둑길 x=1040..1280, 양옆 난간 | 길찾기 | 둑길은 base. `conditional`(말뚝에 달린 차단봉이 내려옴, x≈1070) / `open`(차단봉이 섬) |
| 전경 `foreground_south_ledge` | x=0..460, y=660..720 | 길찾기 | foreground |
| 공용 자리 | recovery anchor: 창구 왼쪽 앞 (330,420) / route marker: E03 (1010,500) | — | 빈 바닥 |

주 동선: 서쪽 입구 (60,475) → 창구 앞 (500,340) → 승강기 앞 (840,340) → 동쪽 둑길 (1100,380).

## 7. 구역 D `h0_d_ash_stair`

초점: E01 Ash Stair(R1로 내려가는 유일한 출구).

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| 북쪽 연결(→A) | x=540..720, y=0..120 | 길찾기 | base |
| 계단참 | y=120..420 | 길찾기 | base |
| E01 Ash Stair `route_e01_ash_stair` | 가운데 x=500..780(폭 약 2.5 m), y=420에서 화면 아래로 내려가는 넓은 계단 | 길찾기 | base. 상태는 `open` 하나라 상태 레이어 없음. R1 A의 계단과 폭을 같게 한다 |
| 계단 양옆 낮은 난간 | x=470..500, 780..810, y=380..720 | 길찾기 | base |
| 아래에서 올라오는 재 먼지와 옅은 따뜻한 빛 | 계단 아래쪽 y=600..720 | 분위기 | base, 낮은 대비. R1 가마로 이어짐을 암시 |
| 전경 `foreground_stair_parapet` | 두 난간의 앞쪽 끝 x=460..510, 770..820, y=630..720 | 길찾기 | foreground |
| 공용 자리 | route marker: 계단 머리 왼쪽 (440,380) | — | 빈 바닥 |

## 8. 색·재질 (톤앤매너 확정 전 초안)

- H0는 시험 작업 `palette_h0.json`을 그대로 쓴다: 분필빛 회보라 광물성 바닥, 짙은 자주 구조선, 탁한 청동 기능 부품, 바랜 종이색 소량(PROJECT_ART_LAYER).
- 구역 차이: B는 청동 카드 꽂이·레일로 금속 비중이 조금 높고, C는 종이색 서식 칸이 조금 많고, D는 계단 아래에 R1의 따뜻한 재색이 조금 섞인다.
- 톤앤매너(분위기 기준)가 오면 이 절을 먼저 고치고, 바뀐 값은 JOB.md와 `palette_h0` 변경 기록에 적는다.

## 9. 재방문 상태

| variant | 바뀌는 그림 | 구역 |
|---|---|---|
| `rv_after_filing` | map `ps_contested` | B |
| `rv_after_rationing` | counter `ps_rationing` | A |

G0 `closed/open`, 출구 `conditional/open`, lift `conditional/open`은 재방문이 아니라 route 상태 그림이다.

## 10. 합성과 검수

- master_composite는 초기 상태로 합성한다: counter `ps_open`, G0 `closed`, map `ps_matched`, 출구 E02~E05 `conditional`, lift `conditional`.
- preview_reassembled = base + 초기 상태 레이어 + foreground를 같은 좌표로 다시 조립한 그림. master와 어긋나면 반려한다.
- 게임 화면 미리보기(1280×720)에만 플레이어 키 확인용 그림(`input/scale_ref`)을 올린다. 배경에 굽지 않는다.
- 검수(09 §12.1, 13 §5·§6): 필드 기본·초점, 재방문 상태, 긴 이동(구역 이음매), 1280×720/1920×1080/2560×1440, 레이어 재조립 일치, 치운 자리 복원, alpha 가장자리, 그림자 잔상, 좌표 drift, 가장자리 잘림. H0에는 전투가 없어 전투 전환 검수는 해당 없음.

## 11. 출처 구분 (14 §7)

- 사용자 결정: 60° 카메라, 큰 배경 + 분리 레이어, 아이콘 조합 방식, 크기 통일 표, candidate/승인 구분, 붓자국 설정 고정.
- 기존 기획 사실: §1의 ID·상태·출구·지형 설명.
- 작성자 설계: 화면 4개 나누기, B·C·D 배치·좌표·치수, 출구·lift·G0의 모양과 상태 표현, G0를 막지 않는 결정, 공용 사물·사람 자리, 구역별 재질 배분, 크기 기준 계산.
- 미해결: 톤앤매너(분위기 기준) — 사용자 결정 대기. 색·빛·분위기 밀도는 확정 뒤 다시 맞춘다.
