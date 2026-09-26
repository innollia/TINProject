# R7 The Hollow Orchard — 배경·사물 brief (mp09-bg-r7-v01)

> ⚠ COMMON.md 04:25판(V1 확정) 전에 쓴 판이다. R7을 시작할 때 R6 BRIEF.md(V1판) §4·§5·§7·§9 형식으로 다시 쓴다: 배경은 base_clean + foreground만, 나무·쉼터·화덕·덤불·등불·잔해는 지역 오브젝트, 출구·지름길 상태도 오브젝트, 색은 palette_h0_mood.json을 물려받은 어두운 값, 캐릭터 합성 미리보기 없음(배경+오브젝트 확인 그림만).

작성 2026-09-27, 세션 09. 상태: **제작 전 준비.** 분위기 값(명도·채도·빛의 세기)은 톤앤매너 기준이 오면 다시 맞춘다(COMMON.md 준비 규칙). 아래 배치·재질·크기·상태 모양은 이 작업의 **작성자 설계**이고 domain 좌표가 아니다. 출력 규격·빛·선 규칙은 R6 brief(`../mp09-bg-r6-v01/BRIEF.md` §4)와 같다.

## 1. 근거

- 기존 기획 사실: `modules/top_down_action_rpg/content/regions/region_r7_hollow_orchard.json`(topology `orchard_ring_and_wall`, size_class large, 랜드마크 5, 이동 축 phase, 되돌아가기 가능, 출구 4, 내부 길 1, 다시 방문 2, 숨은 상태), `content/props/prop_r7_*.json` 4개, `content/recovery/rec_r7_verge_loop.json`, 02 §7.8(Outer Wall, Root Orchard, Shelter Ring, Crown Position, Storm Verge), §5.2(E09/E13/E15/E16), §6.1(G5/G6/G7/G8), §8.8.
- 제작 계약: 13 §1·§5, 09 §12(공통 필드, 12.1, 12.2, 12.8), `docs/IMAGE_ASSET_WORKFLOW.md` §3, COMMON.md.
- 모듈 코드에는 공간 배치가 없다(`systems/field_controller.gd` 4열 임시 격자). 아래 배치는 전부 작성자 설계다.

## 2. 자산 ID와 게임 상태

- art key `art_world_r7_hollow_orchard`. 구역 ID(작성자 설계): `bg_r7_wall_causeway`, `bg_r7_orchard_shelter`, `bg_r7_crown_verge`.
- 첫 방문: `as_authored`, 입구는 E09 Orchard Causeway(STORY_FORCED).
- 다시 방문: `rv_after_void_cut` = 절단 흔적 `ps_cut_filed` + 벽 이음매 `ps_reported`. `rv_after_settlement_vote` = 장부 `ps_quota_filed` + 왕관 자리 받침 `ps_claimed`.
- 숨은 상태: 왕관 자리 받침은 `ps_claimed`가 되기 전에는 안 보인다(prop의 hidden_until_condition, region hidden_state는 crown_alignment 2단계에서 일부 공개). 그래서 바탕에는 받침 없는 빈 원형 단을 그리고, 받침 두 상태는 따로 만든다.
- 02 §7.8의 "phase별로 다른 출입구"는 content에 벽 이음매와 내부 길 상태로만 들어 있어서, 그 밖의 phase 그림은 만들지 않는다.
- 필드 전투가 있다(field_pressure lethal: enc_the_audit_crossing, enc_audit_above_the_market, enc_bailiff_of_the_outer_seam). 구역마다 막힘없는 바닥을 남긴다.
- NPC 8명은 다른 세션 담당이라 그리지 않는다. 왕관 자체는 그리지 않는다(왕관은 R4 위에 있고, 여기에는 그림자만 떨어진다).

## 3. 화면 나누기 (작성자 설계)

바깥 벽이 지역 북쪽을 두르고, 서쪽 둑길로 들어와 동쪽 폭풍 가장자리로 가는 순서로 1280×720 구역 3개를 가로로 둔다. 구역 사이 길의 위치와 폭을 양쪽에서 맞춘다. 가장자리 그림을 이어 붙이지는 않는다.

| 구역 | 랜드마크 | 출구·내부 길 | 사물 | 이어지는 곳 |
|---|---|---|---|---|
| `bg_r7_wall_causeway` (도착, 서쪽) | Outer Wall | E09 Orchard Causeway(입구), E16 Drainage Dark | 벽 이음매 | 동쪽 가장자리 길 y 350..490 → orchard_shelter |
| `bg_r7_orchard_shelter` (가운데) | Root Orchard, Shelter Ring | E15 Supply Gantry, 지름길의 쉼터 쪽 끝 | 쉼터 장부 | 서쪽 y 350..490, 동쪽 아래 y 500..640 → crown_verge, 동쪽 위 지름길 y 270..360 |
| `bg_r7_crown_verge` (동쪽 끝) | Crown Position, Storm Verge | E13 Crown Stair, 지름길의 가장자리 쪽 끝 | 왕관 자리 받침, 폭풍 가장자리 절단 흔적 | 서쪽 아래 y 500..640, 서쪽 위 지름길 y 270..360 |

## 4. 출력 규격

R6 brief §4와 같다: base_clean 2560×1440 불투명, master_composite, prop_*(투명, 접촉 피벗, 여백 원본 64 px, 그림자 따로, 이름은 art_key), 출구·길·전경은 2560×1440 투명 겹침판(원점 0,0), preview_reassembled 1280×720(처음 방문 + 다시 방문). 60° 정사영, 바닥 180 px/m, 깊이 ×0.866, 높이 110 px/m(플레이어 화면 키 96 px = 1.75 m). 빛은 왼쪽 위 확산광, 선·명암·붓자국은 palette_h0 `styles` 그대로. 절단 흔적 안의 빛나는 효과는 세션 10의 효과 그림(`art_effect_portal_void_cut`) 몫이라 사물 그림에 넣지 않는다.

## 5. 재질과 색 (작성자 설계, 임시)

명도·채도·빛의 세기는 톤앤매너 기준을 받으면 다시 맞춘다. 지역을 구분하는 색상 방향은 유지한다. 윤곽선·그림자·접촉 그림자·선 색 계열은 H0 그대로. **흑갈색 흙 + 차가운 현무암 벽 + 은회색 빈 나무 + 폭풍 가장자리의 옅은 재청색**으로 R7임을 알게 한다.

| 재질 | 쓰는 곳 | base / shadow / light |
|---|---|---|
| loam | 흙 바닥 | `#7d6a55` / `#5f4f3f` / `#97836b` |
| root_flag | 뿌리에 갈라진 판석 길 | `#948a7b` / `#72695c` / `#ada393` |
| basalt | 바깥 벽, 계단, 받침 | `#56535f` / `#3d3a46` / `#6f6c79`, 옆면 `#47444f` |
| bark_hollow | 속 빈 나무 | `#948c80` / `#6e675d` / `#b0a899` |
| leaf_dry | 마른 잎, 풀 | `#7a7a52` / `#5a5a3b` |
| verge_scour | 폭풍 가장자리의 쓸린 땅 | `#a8aea8` / `#858b86` / `#c3c8c2` |
| canvas_shelter | 쉼터 천 | `#7f8a78` / `#5f6859` |
| void_cut | 절단 흔적 안쪽 | `#2a1838` |
| fruit | 떨어진 열매(소량) | `#a0703e` |
| bronze, paper | H0 그대로 | — |

## 6. 구역별 배치와 정보 중요도

좌표는 논리 px(1280×720), 원본은 ×2. 주 동선은 폭 140 px 이상을 두고 물체·전경으로 막지 않는다.

### 6.1 `bg_r7_wall_causeway` — 도착, 바깥 벽

| 요소 | 위치(논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| 바깥 벽(현무암) | 앞면 y 0..170(밑선 170), 전체 폭, 청동 측량 못 | 길찾기·상황 이해 | base |
| 벽 이음매 | 벽 밑선 기준점 (640,170), 이음매 x 586..694, y 5..170 | 증거·직접 상호작용 | prop(벽) |
| E16 배수 아치 | 벽 밑 x 980..1180, y 71..170. 앞 돌 웅덩이 x 1000..1160, y 180..260, 물은 동쪽 가장자리 관으로 빠짐 | 길찾기·상황 이해 | base |
| E16 창살 | 배수 아치 | 증거·직접 상호작용 | `exit_r7_e16_drainage_dark` |
| E09 둑길 | 서쪽 가장자리에서 들어옴, 길 y 420..560, x 0..300. 흙 둑 남쪽 비탈 y 560..600, 양옆 마른 도랑 | 길찾기·상황 이해 | base |
| E09 차단목 | 둑길 안쪽 끝 x 280..320, y 420..560 | 증거·직접 상호작용 | `exit_r7_e09_orchard_causeway` |
| 판석 길 | 둑길 끝 → 동쪽 가장자리 y 350..490. 가지 길 → 이음매 앞, 배수 아치 앞 | 길찾기·상황 이해 | base |
| 속 빈 나무 4그루 | 밑동 (560,690) (820,650) (1000,700) (1190,640), 키 2.5~3.5 m, 잎 적음 | 분위기 | 밑동 base, 가지 `foreground_r7_canopy_edge` |
| 떨어진 열매 | 나무 밑 몇 개 | 분위기 | base |

필드 전투 공간: x 360..960, y 200..420.

### 6.2 `bg_r7_orchard_shelter` — 뿌리 과수원, 쉼터 링

| 요소 | 위치(논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| 바깥 벽 | 앞면 y 0..120 | 길찾기·상황 이해 | base |
| E15 보급 기중기 탑 | 벽 앞 x 880..1060, 높이 6 m. 승강판 내려오는 자리 x 900..1040, y 180..260 | 길찾기·상황 이해 | base |
| E15 승강판과 제동 | 탑 | 증거·직접 상호작용 | `exit_r7_e15_supply_gantry` |
| 쉼터 링 | 중심 (640,420), 반지름 300×260 | 길찾기·상황 이해 / 필드 전투 공간 | base |
| 천·나무 쉼터 4채 | (430,240) (730,170) (430,600) (560,650), 한 채 2.0 × 1.6 m | 분위기 | base |
| 불 없는 화덕 돌 원 | 중심 (640,480), 120×104 | 분위기 | base |
| 쉼터 장부 탁자 | 피벗 (600,380), 폭 144 × 깊이 62 × 높이 50 | 증거·직접 상호작용 | prop |
| 속 빈 나무 | 벽 앞 (170,180) (1180,190), 밑동 (1150,460) (120,700) (1180,700) | 분위기 | 벽 앞 두 그루 base, 나머지 가지 `foreground_r7_canopy_orchard` |
| 판석 길 | 서쪽 y 350..490 → 링, 링 → 동쪽 아래 y 500..640, 링 → 탑, 링 → 동쪽 위 y 270..360 | 길찾기·상황 이해 | base |
| 지름길 쉼터 쪽 끝 | 동쪽 가장자리 x 1120..1280, y 270..360 | 증거·직접 상호작용(절단 결과) | `route_r7_storm_verge_shelter_run` (shelter_*) |

### 6.3 `bg_r7_crown_verge` — 왕관 자리, 폭풍 가장자리

| 요소 | 위치(논리) | 정보 등급 | 레이어 |
|---|---|---|---|
| E13 왕관 계단 | x 340..580, 맨 아래 단 y 200, 북쪽 화면 밖으로 올라감. 양옆 돌 난간벽 x 320..340 / 580..600 | 길찾기·상황 이해 | base |
| E13 쇠사슬 문 | 계단 발치 y 170..240 | 증거·직접 상호작용 | `exit_r7_e13_crown_stair` |
| 바깥 벽 끝 | 앞면 x 0..320 / 600..800, y 0..120. x 800 동쪽은 부서진 벽 토막 (860,110) (1000,140) (1150,100) | 길찾기·상황 이해 | base |
| 왕관 자리 원형 단 | 중심 (520,500), 320×278, 0.3 m 높이 | 길찾기·상황 이해 | base(받침 없음) |
| 왕관 자리 받침 | 피벗 (520,500), 지름 1.2 × 높이 0.6 m, 그림자 무늬는 지름 3 m 안 | 증거·직접 상호작용 | prop(처음엔 안 보임) |
| 능선 지름길 | 가장자리 쪽 (900,320)에서 서쪽 가장자리 y 270..360까지 | 길찾기·상황 이해 | base |
| 지름길 가장자리 쪽 막힘 | x 40..220, y 270..360 | 증거·직접 상호작용(절단 결과) | `route_r7_storm_verge_shelter_run` (verge_*) |
| 폭풍 가장자리 | x 760..1280, y 120..720. 쓸린 옅은 땅, 동쪽에서 온 모래 줄무늬, 휜 마른 덤불 | 길찾기·상황 이해 / 필드 전투 공간 | base |
| 절단 흔적 | 흔적 가운데 (1000,440), 216×94 | 증거·직접 상호작용 | prop(바닥 흔적) |
| 부서진 벽 토막 | x 1080..1280, y 620..720 | 분위기 | `foreground_r7_wall_stub` |

주 동선: 서쪽 아래 y 500..640 → 원형 단 → 계단 발치 / 폭풍 가장자리. 필드 전투 공간: x 760..1200, y 250..620.

## 7. 사물·출구·길 상태 그림

| 자산 | 상태 그림 | 실제 크기 | 놓는 곳 | 모양과 달라지는 점 |
|---|---|---|---|---|
| `prop_r7_outer_wall_seam` | `prop_r7_seam_sealed`, `prop_r7_seam_reported` | 폭 1.2 × 높이 3.0 m(벽면) | wall_causeway 벽 밑선 (640,170) | sealed: 납 같은 메움재로 닫힌 세로 이음매, 빈 눈금판 셋. reported: 측량 까치발과 추 달린 줄이 걸리고 눈금판이 열려 관측점이 됨 |
| `prop_r7_crown_position_plinth` | `prop_r7_plinth_unclaimed`, `prop_r7_plinth_claimed` | 지름 1.2 × 높이 0.6 m | crown_verge (520,500) | unclaimed: 빈 받침 위와 둘레에 다섯 조각 그림자(어두운 조각 모양 바닥 무늬), 표시 없음. claimed: 받침 앞면에 청동 서랍과 빈 봉인 꼬리표, 다섯 그림자 자리에 작은 말뚝 |
| `prop_r7_storm_verge_cut` | `prop_r7_cut_open`, `prop_r7_cut_matched`, `prop_r7_cut_filed` | 바닥 흔적 2.4 × 1.2 m | crown_verge (1000,440) | open: 닫히지 않은 날카로운 절단 자국(안쪽 짙은 보라, 빛 효과 없음), 청동 말뚝 흩어짐. matched: 말뚝과 줄이 절단 모양을 따라 팽팽히 둘러쳐지고 가장자리가 정리됨. filed: 청동 꺾쇠로 꿰맨 자국 + 빈 계약 꼬리표 |
| `prop_r7_shelter_ring_ledger` | `prop_r7_ledger_open`, `prop_r7_ledger_quota` | 1.6 × 0.8 × 0.9 m | orchard_shelter (600,380) | open: 칸 나눈 상자에 씨앗 주머니·물병·기억 꼬리표(나무패)가 손으로 나뉘어 들쭉날쭉. quota: 같은 크기 틀로 정리되고 장부 상자에 납 봉인, 매듭 끈 |
| `exit_r7_e09_orchard_causeway` | `closed`, `open` | 차단목 길이 2.0 m | wall_causeway 둑길 끝 | closed: 밧줄 감긴 차단목 + 빈 꼬리표. open: 차단목 들림 |
| `exit_r7_e13_crown_stair` | `closed`, `open` | 문 폭 2.6 m | crown_verge 계단 발치 | closed: 납 봉인된 쇠사슬 문(글자 없음). open: 사슬 내려지고 문짝 열림 |
| `exit_r7_e15_supply_gantry` | `closed`, `open` | 승강판 1.6 × 1.0 m | orchard_shelter 탑 | closed: 승강판이 탑 위(y 약 60)에 걸리고 제동 쐐기. open: 승강판이 땅에 내려옴, 빈 나무 상자 둘 |
| `exit_r7_e16_drainage_dark` | `closed`, `open` | 아치 폭 2.2 m | wall_causeway 배수 아치 | closed: 창살 내려옴. open: 창살 올라감, 좁은 발판 |
| `route_r7_storm_verge_shelter_run` | `verge_closed`, `verge_open`, `shelter_closed`, `shelter_open` | 길 폭 1.4 m | crown_verge 서쪽 위, orchard_shelter 동쪽 위 | closed: 무너진 뿌리·잔해 더미가 막음. open: 걷어낸 길 + 갈라진 틈 위 널빤지 |

## 8. 공용 사물 자리 (세션 01 담당. 배경에 그리지 않음)

- `art_prop_route_marker`: wall_causeway (340,400) 둑길 끝, (1080,290) 배수 아치 앞 / orchard_shelter (980,300) 기중기 앞, (1230,560) 동쪽 아래 길 / crown_verge (460,250) 계단 발치, (880,300) 능선 동쪽 끝.
- `art_prop_recovery_anchor`: crown_verge (920,520). rec_r7_verge_loop는 절단 흔적에서 되살아난다.
- `art_prop_magic_concentration_device`: R7 없음.

## 9. 유지할 것, 바꿀 것, 금지

- 유지: 시험 작업의 선·명암·붓자국·접촉 그림자 방식, 60° 계산, 13 레이어 규칙.
- 바꿈: 바닥·벽 재질과 색(§5), 나무·구조물 높이를 플레이어 키 기준으로.
- 금지: 사람·적·시체·피·눈, 왕관 실물, 읽을 수 있는 글자·숫자, UI·HUD·focus 표시·워터마크, BLACK SOULS·Alice 고유 지형·상징, 무작위 기괴 장식, 원래 아이콘 모양이 그대로 읽히는 조각, 주 동선을 가리는 나뭇가지·전경, 절단 흔적 안의 빛 효과, 공용 사물 3개 그려 넣기.

## 10. 원본과 Gold Standard

R6 brief §10과 같다. 화풍 기준은 h0-icon-collage-v01 결과(candidate)와 palette_h0.json, Gold Standard 없음, 톤앤매너 기준은 받는 중, 아이콘 원본 SVG는 고치지 않는다.

## 11. 검수 장면과 해상도

- 구역별 미리보기(처음·다시 방문), 사물·출구 모아 보기 시트, 재합성 차이 검사, 가장자리 잘림, 알파 가장자리, 그림자 잔상, 받침 없는 원형 단이 비어 보이지 않는지.
- 세 해상도 실제 게임 화면 검수: 게임 연결 금지라 not_run.
