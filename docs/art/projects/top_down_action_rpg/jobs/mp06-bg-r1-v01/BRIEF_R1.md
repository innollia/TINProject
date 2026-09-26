# R1 The Returning Kiln — 배경 brief (mp06-bg-r1-v01)

작성 2026-09-27, 세션 06. 상태: spec_ready 초안, 그림 없음. R1에는 기존 brief가 없어 COMMON.md에 따라 새로 쓴다. 톤앤매너(분위기 기준)가 확정되면 §9 색·재질을 먼저 다시 맞춘다. 결과는 전부 candidate이고 승인은 사용자만 한다.

구역 이름·좌표·치수·재질·상태 표현은 **작성자 설계**이며 domain 데이터 변경이 아니다. 공통 규칙은 H0 구역 brief [§3](../mp06-bg-h0-v01/BRIEF_H0_AREAS.md)과 같고, 여기에는 요약과 R1에서 다른 점만 적는다.

## 1. 근거 (기존 기획 사실)

- region JSON `region_r1_returning_kiln`(art key `art_world_r1_returning_kiln`), role `recovery_reentry`. topology `stacked_furnace_loops` / `large` / landmark 5 / `elevation` / 되돌아가기 가능. 출구 3개: E01 Ash Stair → H0(`open`, 조건 없음), E06 Quiet Ward Passage → R3(`conditional`, G1, STORY_FORCED), E07 Ash Chute → R6(`conditional`, G1, STORY_FORCED). 내부 경로 없음. 사물 2개, service `service_r1_warm_door`. revisit `rv_after_witness`(door), `rv_after_chute`(thread `ps_spent`). 숨은 상태: `ch_carry_the_claimant` 선택 뒤 door가 일부 드러남. residents `npc_05_nera_voss`, `npc_02_orrin_kest`, `npc_11_cael_ren`. field_pressure high.
- 02 §7.2: `Intake Stack`, `Wrong Return`, `Ash Garden`, `Cold Relay`, `Deep Door`가 서로 다른 층의 loop로 이어진 furnace complex. 정상 stair와 ash chute가 같은 chamber를 다른 protocol로 읽는다. R1-08 Warm Door Exit: ash thread로 만든 우회문, E06/E07 route state를 씀, 되돌아가는 지름길. revisit: R1-01 rescue 뒤 Warm Door Exit가 열림. §4.3 R1 signal: wrong-name door, ash thread, reheated bell, 세 이름이 다른 furnace log. §6.1 G1 Ash Debt: wrong-return case를 rescue·preserve·classify·erase 중 하나로 처리하면 E06(R3 care), E07(R6 organ)이 열린다.
- prop JSON: `prop_r1_wrong_return_door` layer door, `ps_intact`(초기: return이 이미 일어났는데 닫혀 있음) / `ps_opened`(잘못된 쪽에서 열림), 문 기록 읽기 → `doc_r1_wrong_return_log`. `prop_r1_ash_garden_thread` layer trace, `ps_available`(초기: 아직 열을 품음) / `ps_spent`(문 안정에 써 버림), 가져가기 → `conv_r1_wrong_return_hearing`. 둘 다 collides false, revisit_visible true.
- `rec_r1_kiln_reentry`: 쓰러지면 wrong return door에서 다시 시작한다. 08: checkpoint는 R1 recovery chamber에 둘 수 있다.
- 전투 트리거: door에서 Ash Choir·Door Role Test, thread에서 Intake Stamp(와 Second Reading)·Debt Walk, Orrin 전환에서 Second Registration. 전투는 별도 전투 화면(09 §4.1, 적 무대 x=280..1240, y=32..552)에서 한다. 필드 배경에 전투 공간을 따로 만들지 않는다.

## 2. 나누는 방식

```text
H0 D 구역 --- E01 Ash Stair (위로) ---+
                                [A Intake Stack]  맨 위층. E07 Ash Chute (서쪽 바닥, 아래로 R6)
                                       | 계단
                                [B Wrong Return]  되살아나는 곳 (recovery chamber)
                                       | 계단
                                [C Ash Garden]
                                       | 계단
                                [D Cold Relay]    E06 Quiet Ward Passage (북쪽 벽, R3), Warm Door
                                       | 계단
                                [E Deep Door]     맨 아래층, 막다른 곳
```

- 랜드마크 5개가 서로 다른 층의 loop라서 층 하나를 1280×720 화면 하나로 만든다. 아래 화면일수록 한 층 아래다.
- 층 사이 계단은 내부 연결이다(새 route ID 없음). 위층의 내려가는 계단과 아래층의 올라오는 계단은 같은 x 범위에 둔다: A 남 x=420..600 ↔ B 북 x=420..600, B 남동 x=960..1140 ↔ C 북동 x=960..1140, C 남서 x=100..280 ↔ D 북서 x=100..280, D 남동 x=960..1140 ↔ E 북동 x=960..1140.
- 내려가는 계단은 화면 아래 끝으로 내려가고, 올라오는 계단은 화면 위 끝에서 방으로 내려온다. 둘 다 계단 단이 보이는 방향이다.
- 02의 "정상 stair와 ash chute가 같은 chamber를 다른 protocol로 읽는다"를 따라, E01 Ash Stair가 도착하는 A에 E07 Ash Chute 입구를 둔다. 사람은 계단으로, 재와 장기는 Chute로 같은 방을 지난다.
- G1 Ash Debt는 공간에 세운 구조물이 아니라 wrong-return case를 처리하는 행위다. 그래서 따로 관문을 세우지 않고 E06·E07의 `conditional/open` 상태 그림으로 G1 상태를 보여 준다.
- Warm Door는 D에 둔다. 식은 방 안의 따뜻한 문이라 상호작용 초점으로 잘 읽히고, 맨 위층으로 돌아가는 지름길 역할과 맞는다.

## 3. 공통 (H0 구역 brief §3 요약 + R1에서 다른 점)

| 항목 | 값 |
|---|---|
| 캔버스·카메라 | 2560×1440 sRGB(논리 1280×720 ×2). 60° 정사영, 방위 고정, 바닥 깊이 ×0.866, 앞면 높이 ×0.5 |
| 크기 | 플레이어 190 px(원본) ≈ 1.7 m. 원본 기준 가로 1 m ≈ 224 px, 바닥 깊이 ≈ 194 px, 높이 ≈ 112 px. 계단 E01은 H0 D와 같은 폭(약 2.5 m) |
| 빛 | 상부 확산광, 국소 접촉 그림자, 스포트라이트·비네트 없음. 윤곽선·그림자·초승달 명암·붓자국 설정은 시험 작업과 같게 |
| 통로 | 주 통로 논리 140 이상, 보조 100 이상 |
| 사물 파일 | 투명 PNG, 사방 32 px(원본) 여백, 접촉 피벗(문은 문 바닥선 가운데, 실은 두 말뚝 가운데 바닥), `_shadow` 별도 파일, 좌표 json |
| 벽과 가림 | 닫힌 가마 건물이라 북쪽 벽이 높다(3~4 m, 위 끝은 화면 밖). 문은 모두 북쪽 벽에 둬 앞면이 보이게 한다. 키 큰 고정 구조물은 북쪽 벽에 붙이고, 뒤로 걸어 들어갈 수 있는 키 큰 물체는 분리 레이어로 만든다 |
| 열기 | 불씨 색은 칠로만 표현한다. 불꽃·연기·빛 애니메이션 같은 효과 그림은 만들지 않는다 |
| 강조 제한 | 밝은 불씨 색은 상호작용 사물(실, Warm Door)과 가마 투입구에만 쓴다. 넓은 면에 쓰지 않는다 |
| 금지 | 사람·적·시체·눈·왕관·혈흔·읽을 수 있는 글자·도장 기호·UI·격자·워터마크, 원작(BLACK SOULS, Alice) 고유 요소, 원래 아이콘 모양이 읽히는 조각. Ash Garden은 재 밭이라 산 식물도 없다 |
| 공용 사물 | 세션 01 담당, 자리만 비운다. recovery anchor: B의 문 앞. route marker: 각 출구 옆. magic concentration device: R1 content에 근거가 없어 자리를 두지 않는다 |
| 사람 자리 | 사람은 그리지 않는다. 서 있을 빈 바닥만 남긴다 |

정보 등급: **증거·직접 상호작용** / **길찾기·상황 이해** / **분위기**. 표에 없는 물체는 분위기로만 취급하고 대비를 낮춘다.

## 4. 구역 A `r1_a_intake_stack` (맨 위층)

초점: Intake Stack(랜드마크). H0에서 내려온 계단과 Ash Chute가 같은 방에 있다.

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| E01 Ash Stair `route_e01_ash_stair` | 북쪽 끝 x=500..780, y=0..200, 위에서 방으로 내려오는 계단 | 길찾기 | base. 상태는 `open` 하나 |
| 북쪽 벽 | 바닥선: 서쪽 x=0..500은 y≈200, 동쪽 x=780..1280은 y≈260 | 길찾기 | base |
| Intake Stack | 동쪽 북벽에 붙음. 바닥 중심 (960,360), 약 260×200(지름 약 2.3 m), 높이 4 m. 앞면에 쇠 뚜껑 달린 투입구 3개가 위아래로 쌓이고 맨 아래 투입구에만 옅은 불씨 | 길찾기 | base |
| E07 Ash Chute `route_e07_ash_chute` | 서쪽 바닥 x=60..260, y=320..470, 서쪽 아래로 기울어진 벽돌 깔때기 | 길찾기 | 깔때기는 base. `conditional`(쇠 미닫이 덮개가 닫혀 있고 위에 재가 얇게 쌓임) / `open`(덮개가 밀려 열려 어두운 구멍이 보이고 재 먼지가 빨려 들어감) |
| 아래층 계단(→B) | 남쪽 x=420..600, y=580..720 | 길찾기 | base |
| 전경 `foreground_flue` | 낮은 받침 위 가로 연도관 x=760..1280, y=650..705 | 길찾기 | foreground |
| 그을음·재 자국 | 벽과 바닥 | 분위기 | base |
| 공용 자리 | route marker: E01 발치 왼쪽 (470,240), E07 옆 (300,500) | — | 빈 바닥 |

주 동선: 계단 발치 (640,220) → 가운데 → 아래층 계단 (510,580). 서쪽 가지는 Chute (260,395), 동쪽 가지는 Intake Stack 앞 (960,480).

## 5. 구역 B `r1_b_wrong_return` (recovery chamber)

초점: Wrong Return Door. 문 앞 바닥은 비운다(전투 트리거 두 개와 되살아나는 자리).

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| 위층 계단(→A) | 북쪽 끝 x=420..600, y=0..170 | 길찾기 | base |
| Wrong Return Door `prop_r1_wrong_return_door` | 북쪽 벽, 문 바닥선 가운데 (860,195), 폭 1.2 m, 높이 2.3 m, 앞에 낮은 두 단 문턱 x=780..940, y=195..245. 문 왼쪽 벽에 빈 쇠 기록판(문 사물에 포함) | 증거·직접 상호작용 | `ps_intact`: 쇠띠 두른 그을린 문이 닫혀 있고 문 밑 틈에 아직 식지 않은 불씨 선 / `ps_opened`: 문짝이 방 쪽으로 열려 있다. 경첩과 빗장이 방 쪽 면에 있어 반대쪽에서 밀려 열린 것이 보이고, 안쪽은 어둡고 따뜻하다. 기록판은 두 상태 모두 빈 판 |
| reheated bell | 문 오른쪽 벽의 쇠 받침 위 작은 종 (960,110) | 분위기 | base, 낮은 대비(§4.3 signal) |
| 벽돌로 막은 가마 입구 2개 | 북쪽 벽 왼쪽 (120,195), (300,195) | 분위기 | base |
| 아래층 계단(→C) | 남동 x=960..1140, y=580..720 | 길찾기 | base |
| 전경 `foreground_arch_lip` | 아치 아래 끝 x=0..420, y=655..720 | 길찾기 | foreground |
| 공용 자리 | recovery anchor: 문 앞 (860,320) | — | 빈 바닥 |
| 사람 자리 | 문 양옆 (720,300), (1000,300) — Nera, Orrin | — | 빈 바닥 |

## 6. 구역 C `r1_c_ash_garden`

초점: Ash Garden Thread. 이 화면에서 밝은 불씨 색은 실 하나뿐이다.

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| 위층 계단(→B) | 북동 x=960..1140, y=0..170 | 길찾기 | base |
| 재 밭 6개 | 낮은 벽돌 테두리(0.2 m) 안에 갈퀴 자국 난 회색 재. 두 줄 y=200..290, y=350..440 × 세 칸 x=90..290, 400..600, 710..910 | 길찾기(밭 사이가 길) | base. 재 속 불씨 점은 낮은 대비 |
| Ash Garden Thread `prop_r1_ash_garden_thread` | 둘째 줄 가운데 밭 위, 쇠 말뚝 (420,400)과 (580,400) 사이에 걸린 실, 말뚝 높이 0.4 m. 피벗 (500,400) | 증거·직접 상호작용 | `ps_available`: 실이 주황빛으로 달아 있고 가운데에 흰 선, 아래 재에 옅은 따뜻한 번짐, 말뚝 끝이 달궈짐 / `ps_spent`: 실이 없고 식은 말뚝만 남음, 실이 있던 자리에 옅은 회색 재 줄 |
| 주 통로 | 아래쪽 y=460..600, 동쪽 x=940..1180 | 길찾기 | base. 실 앞(500,450)이 주 통로에 닿게 둔다(전투 트리거 자리) |
| 아래층 계단(→D) | 남서 x=100..280, y=600..720 | 길찾기 | base |
| 전경 `foreground_south_parapet` | x=760..1280, y=660..720 | 길찾기 | foreground |
| 사람 자리 | 동쪽 통로 (1060,400) — Cael | — | 빈 바닥 |

## 7. 구역 D `r1_d_cold_relay`

초점: Warm Door(식은 방 안의 따뜻한 문)와 E06.

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| 위층 계단(→C) | 북서 x=100..280, y=0..160 | 길찾기 | base |
| Warm Door `prop_r1_warm_door` (service `service_r1_warm_door`, 미술 설계 ID) | 북쪽 벽, 문 바닥선 가운데 (420,190), 폭 1.0 m, 높이 2.1 m. 문틀을 ash thread가 감고 있음 | 증거·직접 상호작용 | `closed`: 문이 닫혀 있고 감긴 실이 어둡게 식어 있음 / `open`: 문이 열려 따뜻한 빛이 식은 바닥에 번짐. 두 상태는 작성자 설계(근거: 02 §7.2 "R1-01 rescue 뒤 Warm Door Exit가 열림") |
| Cold Relay | 북쪽 벽에 붙은 식은 가마 돔 2개, 바닥 중심 (600,250), (820,250), 각 약 160×120, 높이 2 m. 쇠 중계관이 벽을 따라 둘을 잇고, 위에 푸른 회색 식은 재 | 길찾기 | base |
| E06 Quiet Ward Passage `route_e06_quiet_ward_passage` | 북쪽 벽 오른쪽, 문 바닥선 가운데 (1060,190), 폭 1.6 m, 높이 2.4 m, 누빈 천을 댄 두 짝 문 | 길찾기 | 문틀은 base. `conditional`(두 짝이 닫혀 있고 쇠 빗장이 가로지름) / `open`(두 짝이 안쪽으로 열려 서늘하고 어둑한 복도가 보임) |
| 아래층 계단(→E) | 남동 x=960..1140, y=600..720 | 길찾기 | base |
| 전경 `foreground_relay_pipe` | x=0..420, y=650..700 | 길찾기 | foreground |
| 공용 자리 | route marker: E06 앞 왼쪽 (940,300) | — | 빈 바닥 |

주 동선: 위층 계단 (190,160) → 방 가운데 → 아래층 계단 (1050,600). 북쪽 띠 y=190..320은 Warm Door·E06 앞으로 이어진다.

## 8. 구역 E `r1_e_deep_door` (맨 아래층)

초점: Deep Door. 출구·사물이 없는 막다른 층이고 가장 어둡고 차갑다.

| 요소 | 위치(논리) | 등급 | 레이어·상태 |
|---|---|---|---|
| 위층 계단(→D) | 북동 x=960..1140, y=0..160 | 길찾기 | base |
| Deep Door | 북쪽 벽 가운데 왼쪽, 문 바닥선 가운데 (520,240), 폭 2.6 m, 높이 3.6 m. 가장 오래된 벽돌, 수리 자국, 금 간 자리 | 길찾기 | base. 지금 content에 상호작용이 없어 닫힌 한 상태 |
| 계단에서 문까지 닳은 길 | | 길찾기 | base |
| 전경 `foreground_broken_beam` | x=0..380, y=640..720 | 길찾기 | foreground |

## 9. 색·재질 (톤앤매너 확정 전 초안)

| 부분 | R1 제안 | H0와 차이 |
|---|---|---|
| 바닥 | 재를 뒤집어쓴 따뜻한 회색 벽돌 바닥 | H0: 분필빛 회보라 돌 |
| 벽 | 짙게 구운 적갈색 벽돌, 가마 입구 둘레 그을음 | H0: 회보라 돌 |
| 금속 | 검게 그을린 쇠(문, 덮개, 말뚝, 관) | H0: 탁한 청동 |
| 강조 | 불씨 주황(실, Warm Door, 가마 투입구만) | H0: 바랜 종이색 소량 |
| 층별 | A·B·C 따뜻함 → D 푸른 회색 식은 재 → E 가장 어둡고 오래됨 | — |
| 그대로 | 윤곽선(짙은 자주), 그림자, 초승달 명암, 빛 방향은 `palette_h0.json` 값 그대로 | — |

`palette_r1.json`은 그림을 시작할 때 만들고, H0 팔레트에서 바꾼 값을 JOB.md에 적는다.

## 10. 재방문과 숨은 상태

| 대상 | 바뀌는 그림 | 구역 |
|---|---|---|
| `rv_after_witness` | door `ps_opened` | B |
| `rv_after_chute` | thread `ps_spent` | C |
| 숨은 상태(door 일부 드러남) | door `ps_opened` 그림으로 나타낸다(작성자 판단) | B |

이번 범위 밖(region JSON에 없음): R6 organ treaty 뒤 Wrong Return chamber가 clinic annex로 바뀜, R7 alignment 뒤 Deep Door가 외벽으로 redirect됨(02 §7.2). content에 들어오면 B·E의 상태 그림으로 더한다.

## 11. 합성과 검수

- master_composite는 초기 상태로 합성한다: door `ps_intact`, thread `ps_available`, Warm Door `closed`, E06·E07 `conditional`.
- preview_reassembled와 게임 화면 미리보기는 H0 구역 brief §10과 같다. 플레이어 키 기준 그림은 미리보기에만 올린다.
- 검수: H0와 같은 항목(필드 기본·초점, 재방문, 세 해상도, 레이어 재조립, 치운 자리 복원, alpha, 그림자 잔상, drift, 가장자리 잘림) + 전투 전환(B·C: 적 무대가 배경 위에 올라와도 적과 배경이 구별되는지) + 층 계단 5개의 위치·방향이 이어지는지 + 층마다 한눈에 구별되는지 + H0와 R1이 한눈에 구별되는지.

## 12. 출처 구분 (14 §7)

- 사용자 결정: 60° 카메라, 큰 배경 + 분리 레이어, 아이콘 조합 방식, 크기 통일 표, candidate/승인 구분, 붓자국 설정 고정.
- 기존 기획 사실: §1의 ID·상태·출구·지형 설명.
- 작성자 설계: 층 5개 나누기, 모든 배치·좌표·치수, E07을 A에 둔 해석, G1을 출구 상태로만 표현, Warm Door의 위치와 두 상태, 사물 상태의 모양, 재질·색 제안, 공용 사물·사람 자리.
- 미해결: 톤앤매너(분위기 기준) — 사용자 결정 대기. region JSON에 없는 revisit 두 개(§10).
