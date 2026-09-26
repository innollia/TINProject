# H0 The Undersign Exchange — 구역 나누기 brief (mp06-bg-h0-v01)

작성 2026-09-27, 세션 06. 개정 2026-09-27 07시: 기준 확정(COMMON.md — V1 분위기, 배경과 오브젝트 분리, 빛·그림자는 게임 코드)에 맞춰 다시 씀. 결과는 전부 candidate이고 승인은 사용자만 한다.

구역 A의 배치 정본은 기존 brief [`h0_layered_environment_pilot.md`](../../asset_briefs/h0_layered_environment_pilot.md)다. 이 문서는 H0 전체를 화면 4개로 나누는 방식, 구역마다 배경에 그리는 것과 오브젝트로 떼는 것, 상태 그림을 정한다. 구역 이름·좌표·치수·재질·상태 표현은 **작성자 설계**이며 domain 데이터 변경이 아니다.

## 1. 근거 (기존 기획 사실)

- region JSON: topology `ring_shelf_well` / `large` / landmark 4 / `elevation`. 출구 5개: E01 `open`(조건 없음), E02~E05 `conditional`(G0 열림 + 자원 1). 내부 경로 `return_desk_lift`(arrival_well → return_desk, 조건: map `ps_contested`). service `service_h0_return_desk`. revisit `rv_after_filing`(map), `rv_after_rationing`(counter). resident `npc_01_ilyra_senn`. 전투 없음(encounter 0).
- 02 §7.1: 건조한 중앙 선반 위 원형 Arrival Well, 네 방향 계단·tram·수로, 중앙 Counterweight Map, 지하 return lift, 항상 비어 있는 Crown Well 위쪽 그림자. §5.2 출구 형태: E01 Ash Stair, E02 Sluice Road, E03 Mercy Causeway, E04 Crownwell Ascent, E05 Foundry Tram. H0-02: 지도 우선 탐색과 우회.
- prop JSON: counter `ps_open`(초기) / `ps_rationing`, map `ps_matched`(초기) / `ps_contested`(카드 한 장이 precedence 줄로 다시 인쇄됨), 둘 다 collides false. map은 바닥(floor) 사물.
- 08: checkpoint는 H0의 recovery/service에 둘 수 있다.
- 사용자 결정(COMMON.md): V1 분위기, 배경은 배경만·물건은 오브젝트, 빛과 그림자는 게임 코드, 캐릭터를 배경에 합친 검수 그림 금지, 크기는 플레이어 키 기준.

## 2. 나누는 방식

```text
                 E04 Crownwell Ascent (북서, 위로)
                          |
E02 Sluice Road (서) -- [B 교환 선반] -- E05 Foundry Tram (동)
                          |  Counterweight Map, Crown Well
                          |  (G0 관문을 지나감. 막지 않음)
                    [A 도착 접근] ------ [C 반환 창구] -- E03 Mercy Causeway (동, 구덩이 위 둑길)
                          |  Arrival Well, counter       return desk, return lift
                    [D 재 계단]
                          |
                 E01 Ash Stair (남, 아래로 R1)
```

- 랜드마크 4개와 출구 5개를 1280×720 화면 4개에 나눈다. 가운데 A에서 북 B, 동 C, 남 D로 이어진다. 02의 "중앙의 Counterweight Map"은 출구 세 개가 갈라지는 B의 가운데로 해석한다(기존 brief가 A에 지도를 넣지 말라고 했기 때문).
- 화면 사이 이동은 화면 가장자리 통로(내부 연결)다. 새 route ID를 만들지 않는다. 출구 5개는 각 구역 안의 실제 구조물로 그린다.
- 이음매: A 북 x=550..710 ↔ B 남 x=550..710, A 동 y=400..550 ↔ C 서 y=400..550, A 남 x=540..720 ↔ D 북 x=540..720. E01 계단 폭은 R1 A와 같게(논리 280).
- `return_desk_lift`는 Arrival Well 아래에서 반환 창구로 올라오는 지하 승강기로 본다. 승강기 칸은 C에만 그리고 A의 기존 배치는 바꾸지 않는다.

## 3. 모든 구역 공통

| 항목 | 값 |
|---|---|
| 배경 파일 | 구역마다 `base_clean`(2560×1440 불투명, 바닥·벽·계단·구덩이·우물 같은 고정 구조와 바닥 무늬만) + `foreground_*`(같은 크기 투명, 캐릭터 앞을 가리는 고정 구조). master_composite·preview_reassembled·prop_* 레이어는 만들지 않는다(COMMON 규격) |
| 오브젝트 | 떼어 놓을 수 있거나 또 놓일 물건, content 사물, 출구·관문의 상태 부분은 전부 오브젝트(투명 PNG, 접촉 피벗, `_shadow.png`, 빛나는 부분은 `_emit.png`). H0 오브젝트는 한 번만 만들고 네 구역이 같이 쓴다 |
| 배치 | 구역마다 `recipes/scene_<구역>.json`(오브젝트만, 원본 px 좌표, 빛나는 것에 `light`). 이 파일로 배경+오브젝트 확인 그림(1280×720, 사람·적 없음)을 만든다 |
| 카메라 | 지면 기준 60° 정사영, 방위 고정(북쪽을 보고 내려다봄). 바닥 깊이 ×0.866, 앞면 높이 ×0.5 |
| 크기 | 플레이어 그림 높이 190 px(원본) ≈ 1.7 m. 원본 기준 가로 1 m ≈ 224 px, 바닥 깊이 ≈ 194 px, 높이 ≈ 112 px. V1 레시피(180 px/m)에서 온 것은 ×1.24(높이도 손으로 ×1.24). 벽 1.7 m, counter 허리 높이, 관문 기둥 1.9 m |
| 빛·그림자 | 그림에는 도구의 기본 확산광과 물체 자체 명암만. 화면 어둡게 누르기·비네트·불빛 웅덩이·장면 `lighting` 없음. 벽 발치 AO와 바닥 그림자는 `base_clean_shadow.png` / `_shadow.png`로 따로 |
| 색 | V1 `palette_h0_mood.json` 그대로(분필빛 회보라 바닥을 어둡게 누른 V1 값, 짙은 자주 윤곽선, 탁한 청동, 바랜 종이색, 때·녹·습기 얼룩) |
| 얼룩 | 작은 것(슬래브 grime), 중간(손으로 놓은 얼룩), 큰 것(큰 번짐 + mottle) 세 겹, 겹마다 세기를 낮춤 |
| 통로 | 주 통로 폭 논리 140 이상, 보조 100 이상 |
| 방향과 가림 | 동·서를 향한 면은 보이지 않는다. 문·격자는 북쪽 벽에, 동·서 끝 출구의 차단물은 대각선으로 눕힌 판·봉으로(똑바로 남북으로 누우면 서 있는 기둥처럼 보임). base는 캐릭터보다 늘 아래에 그려지므로 키 큰 고정 구조는 벽에 붙이고, 앞을 가리는 구조는 foreground로 뺀다. foreground는 그 앞(남쪽)에 아무도 설 수 없는 자리에만 둔다(화면 아래 끝, 낙차, 머리 위) |
| 금지 | 사람·적·시체·눈·식물·왕관·혈흔·읽을 수 있는 글자·도장 기호·UI·격자·워터마크, 원작(BLACK SOULS, Alice) 고유 요소, 원래 아이콘 모양이 그대로 읽히는 조각(우물 둘레 조리개 모양은 돌 두 겹 고리로 바꿈, 지도 연결선은 조각으로 자름, counter 창구 아치는 고리 조각과 막대로 바꿈) |
| 공용 사물 | route marker, recovery anchor, magic concentration device는 세션 01 담당. 그리지 않고 아래 표의 자리만 비운다. magic concentration device는 H0 content에 근거가 없어 자리를 두지 않는다 |

정보 등급: **증거·직접 상호작용** / **길찾기·상황 이해** / **분위기**. 표에 없는 물체는 분위기로만 취급하고 대비를 낮춘다.

## 4. H0 오브젝트 (네 구역 공용)

| 오브젝트 | 상태(프레임) | 등급 | 피벗 |
|---|---|---|---|
| `prop_h0_ration_counter` | `ps_open` / `ps_rationing`(배급 쟁반·꾸러미·물병이 올라오고 토큰 고리 하나가 빠짐) | 증거·직접 상호작용 | 앞면 바닥선 가운데 |
| `prop_h0_counterweight_map` | `ps_matched` / `ps_contested`(가로줄 하나 더 있는 새 카드, 빈 카드 칸, 빚 표식) | 증거·직접 상호작용 | 테두리 앞 바닥선 가운데(바닥 사물) |
| `gate_g0_arrival_declaration` | `closed`(등 꺼짐, 도장에 청동 덮개) / `open`(등 켜짐 emit, 도장이 섬). 두 상태 모두 통로를 막지 않음 | 길찾기 | 여는 곳 바닥선 가운데 |
| `prop_h0_return_desk` (service_h0_return_desk) | 한 상태(창살 창구 칸막이, 빈 서식, 닫힌 장부, 잉크병) | 증거·직접 상호작용 | 앞면 바닥선 가운데 |
| `return_desk_lift` | `conditional`(격자문 닫힘·자물쇠, 받침판이 구덩이 아래) / `open`(격자문 접힘, 청동 받침판이 바닥 높이) | 길찾기 | 승강로 앞 바닥선 가운데 |
| `route_e02_sluice_road` | `conditional`(쇠띠 두른 굵은 판이 받침대 두 개 위에 길을 대각선으로 가로질러 누움) / `open`(판은 세워 기대고 받침대는 길 남쪽 끝에 모음) | 길찾기 | 길 남쪽 끝 바닥 |
| `route_e04_crownwell_ascent` | `conditional`(계단 발치 쇠살문 닫힘·자물쇠) / `open`(두 짝이 문설주 쪽으로 접힘) | 길찾기 | 계단 발치 바닥선 가운데 |
| `obj_h0_barrier_arm` (E03·E05 공용) | `conditional`(돌 기둥에서 차단봉이 길을 대각선으로 가로질러 받침 기둥에 걸림) / `open`(차단봉이 길 가장자리를 따라 동쪽으로 돌아감) | 길찾기 | 길 남쪽 가장자리의 기둥 바닥 |
| `obj_h0_brazier` | 한 상태(숯·불꽃 emit) | 분위기 | 받침 바닥 |
| `obj_h0_wall_sconce` | 한 상태(유리·불꽃 emit) | 분위기 | 벽에 붙는 받침 아래 가운데(벽 부착) |
| `obj_h0_post_lantern` | 한 상태(유리·불꽃 emit) | 분위기 | 기둥 윗면에 닿는 발(기둥 위) |
| `obj_h0_crate` | `crate_large` / `crate_small` / `crate_stack` | 분위기 | 앞면 바닥선 가운데 |
| `obj_h0_rubble` | `rubble_large` / `rubble_small` | 분위기 | 더미 앞 바닥 |
| `obj_h0_drain_cover` | 한 상태 | 분위기 | 가운데(바닥 사물) |
| `obj_h0_docket_rack` | 한 상태(빈 서류 꽂이) | 분위기 | 벽에 붙는 아래 가운데(벽 부착) |

벽에 붙는 것과 기둥 위에 서는 것은 장면 JSON에 `sort_y`(붙은 벽·기둥의 바닥선)를 함께 적는다. 빛나는 것은 장면 JSON에 `light`를 적는다(화로 #ffb45c 반지름 300, 등 #ffc987 반지름 220, 관문 등은 `open` 상태에서만).

## 5. 구역 A `h0_a_arrival_approach` (기존 brief 배치 그대로)

초점: Arrival Well(랜드마크)과 counter(상호작용). V1 배경 레시피에서 화로·벽등·기둥 등불·상자·잔해·배수구 덮개·서류 꽂이를 빼서 오브젝트로 만들고, 원래 자리는 `scene_h0_a_arrival_approach.json`에 적었다.

| 요소 | 위치(논리) | 등급 | 어디에 |
|---|---|---|---|
| Arrival Well | 중심 (790,290), 외경 220, 둘레 돌 두 겹 고리 | 길찾기 | base |
| 주 통로 | 남 x=540..720 → 북 x=550..710, 우물 왼쪽 우회 140 이상 | 길찾기 | base |
| 동쪽 연결(→C) | y=400..550 | 길찾기 | base |
| counter | 앞면 바닥선 (250,320), 크기 ×1.24(폭 약 2.8 m) | 증거·직접 상호작용 | 오브젝트 |
| G0 관문 | 북 통로 위, 바닥선 (630,165) | 길찾기 | 오브젝트 |
| 머리 위 가로보 | x=57..453, y=553..597, 기둥 두 개는 화면 아래 끝에 섬(높이 약 2.2 m) | 길찾기 | `foreground_beam` |
| 낮은 외곽 벽·벽 기둥·배관 | 화면 위·좌우 끝 | 길찾기 | base |
| 사람 자리 | counter 앞 (250,360) — resident Ilyra | — | 빈 바닥 |

## 6. 구역 B `h0_b_exchange_shelf`

초점: Counterweight Map, Crown Well. 출구 세 개가 여기서 갈라진다.

| 요소 | 위치(논리) | 등급 | 어디에 |
|---|---|---|---|
| 남쪽 연결(→A) | x=550..710 | 길찾기 | base |
| Crown Well | 중심 (700,210), 외경 240, 비어 있음. 덮은 구조물은 화면 위 밖, 바닥에 큰 그림자만 | 길찾기 | base(그림자는 `base_clean_shadow.png`) |
| Counterweight Map | 앞 바닥선 (640,515) | 증거·직접 상호작용 | 오브젝트(바닥) |
| E04 계단 | x=202..378, 바닥 y≈235에서 벽 틈으로 오르는 8단 | 길찾기 | 계단은 base, 쇠살문은 오브젝트(290,235) |
| E02 길·마른 수로 | 서쪽 끝, 조약돌 길 y=400..520, 북쪽 옆 마른 돌 수로 | 길찾기 | 길은 base, 차단 판은 오브젝트(150,520) |
| E05 레일·승강대 | 동쪽 끝, 레일 y=430·490, 남쪽 낮은 승강대 | 길찾기 | 레일은 base, 차단봉은 오브젝트(1050,514) |
| 남쪽 낮은 난간 | 화면 아래 끝, 남쪽 연결 양옆 | 길찾기 | `foreground_south_rail` |
| 공용 자리 | route marker: E02 (250,560), E04 (420,250), E05 (1000,560) | — | 빈 바닥 |

## 7. 구역 C `h0_c_return_desk`

초점: return desk, return lift. 방의 동쪽 3분의 1은 깊은 마른 구덩이이고 E03 둑길이 그 위를 건너 동쪽 벽 틈으로 나간다.

| 요소 | 위치(논리) | 등급 | 어디에 |
|---|---|---|---|
| 서쪽 연결(→A) | y=400..550 | 길찾기 | base |
| return desk | 앞 바닥선 (500,250), 칸막이 뒤(벽과 칸막이 사이)가 직원 자리 | 증거·직접 상호작용 | 오브젝트 |
| return lift | 앞 바닥선 (840,235), 벽에 붙음. 승강로 구덩이는 base | 길찾기 | 오브젝트 + base 구덩이 |
| 구덩이와 E03 둑길 | x=1000..1290, 둑길 상판 y=300..450, 앞면이 어둠으로 내려감 | 길찾기 | base, 둑길 남쪽 난간은 foreground, 차단봉은 오브젝트(1045,450) |
| 낮은 턱 | 왼쪽 아래, 화면 아래 끝 | 길찾기 | `foreground_ledge_rail`(둑길 남쪽 난간과 한 장) |
| 공용 자리 | recovery anchor: 창구 왼쪽 앞 (330,420) / route marker: E03 (1010,500) | — | 빈 바닥 |

## 8. 구역 D `h0_d_ash_stair`

초점: E01 Ash Stair(R1로 내려가는 유일한 출구).

| 요소 | 위치(논리) | 등급 | 어디에 |
|---|---|---|---|
| 북쪽 연결(→A) | x=540..720, 북쪽 벽 틈 | 길찾기 | base |
| 계단참 | y=106..435 | 길찾기 | base |
| 남쪽 난간벽 | 계단참 끝, 계단 틈 양옆. 바깥 면은 낙차 속으로 어두워짐 | 길찾기 | `foreground_stair_arch` |
| E01 Ash Stair | x=500..780, 난간벽 틈에서 아래로 8단, 아래로 갈수록 어두움. 상태 `open` 하나 | 길찾기 | base |
| 계단 머리 아치 | 난간벽 끝의 기둥 둘 + 상인방(약 2.8 m) | 길찾기 | `foreground_stair_arch` |
| 낙차 | 난간벽 너머 화면 아래 끝까지 어둠 | 분위기 | base |
| 재 먼지 | 계단 머리와 계단참의 회색 얼룩(R1 가마로 이어짐을 암시) | 분위기 | base |
| 공용 자리 | route marker: 계단 머리 왼쪽 (440,380) | — | 빈 바닥 |

## 9. 재방문 상태

| variant | 바뀌는 그림 | 구역 |
|---|---|---|
| `rv_after_filing` | map `ps_contested` | B |
| `rv_after_rationing` | counter `ps_rationing` | A |

G0 `closed/open`, 출구 `conditional/open`, lift `conditional/open`은 재방문이 아니라 route 상태 그림이다.

## 10. 확인 그림과 검수

- 확인 그림은 장면 JSON의 초기 상태로 합성한다: counter `ps_open`, G0 `closed`, map `ps_matched`, 출구 E02~E05 `conditional`, lift `conditional`. 배경 → 배경 그림자 → 오브젝트(그림자 포함, 바닥 사물 먼저, 나머지는 바닥선 순) → foreground 순서.
- 검수(09 §12.1, 13 §5·§6): 배경끼리 이음매와 층 위치, 오브젝트 가장자리 잘림과 32 px 여백, 피벗, 상태끼리 차이, 원래 아이콘이 읽히는지, 얼룩이 무늬처럼 보이는지, 밝기가 V1과 비슷한지. H0에는 전투가 없어 전투 전환 검수는 해당 없음.

## 11. 출처 구분 (14 §7)

- 사용자 결정: 60° 카메라, V1 분위기, 배경/오브젝트 분리, 빛·그림자는 게임 코드, 캐릭터 합성 검수 그림 금지, 아이콘 조합 방식, 크기 통일 표, candidate/승인 구분, 붓자국 설정 고정.
- 기존 기획 사실: §1의 ID·상태·출구·지형 설명.
- 작성자 설계: 화면 4개 나누기, B·C·D 배치·좌표·치수, 오브젝트 목록과 상태 모양, G0를 막지 않는 결정, 동·서 출구 차단물을 대각선으로 둔 것, C의 구덩이와 둑길, D의 낙차와 아치, 공용 사물·사람 자리, 크기 기준 계산.
- 미해결: 없음(8방향 캐릭터 기준은 배경 작업과 무관).
