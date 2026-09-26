# mp06-bg-h0-v01 — H0 The Undersign Exchange 배경·사물 (아이콘 조합 양산)

상태: **준비만 끝남. 그림은 아직 만들지 않음.** 사용자 지시(2026-09-27 03:23 KST): 톤앤매너 자료가 오고 있으니 작업 준비까지만 한다. 결과는 전부 candidate이고 승인은 사용자만 한다.

## 필드 (14 §3)

| 필드 | 값 |
|---|---|
| 목적 | environment_master + clean_base + prop + occluder + state_variant (H0 전체 구역) |
| 소유권 | 세션 06. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/mp06-bg-h0-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp06-bg-h0-v01/`. 정본·게임 코드·씬·content 수정 없음. 커밋·푸시 없음 |
| 자산 identity | region `region_h0_undersign_exchange`, art key `art_world_h0_undersign`. content 사물 `prop_h0_ration_counter`, `prop_h0_counterweight_map`. 관문 `gate_g0_arrival_declaration`. 출구 edge `route_e01_ash_stair`~`route_e05_foundry_tram`. 구역·레이어 이름(`h0_a_*` 등)과 `prop_h0_return_desk`는 이 작업의 미술 설계 ID |
| 입력 계약 | `inputs.json` (SHA-256). 규칙: COMMON.md(양산 공통), IMAGE_ASSET_WORKFLOW, VISUAL_DIRECTION, PROJECT_ART_LAYER 0.1, 09 §12, 13, 14, H0 brief |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 지면 깊이 ×0.866, 높이 ×0.5 |
| 화풍 기준 | 시험 작업 `h0-icon-collage-v01` (눈으로 맞춤). 톤앤매너 자료가 오면 그것을 우선 적용 |
| 팔레트 | `recipes/palette_h0.json` (시험 작업 그대로). 톤앤매너 도착 뒤 바꾸면 여기에 기록 |
| 금지 | 사람·적·글자·UI·워터마크를 배경에 굽기, 원작 고유 요소, 공용 사물 3개(세션 01 담당)를 그려 넣기, 다른 mpNN 폴더 읽기·쓰기 |

## 구역 나누기 계획 (작성자 설계, 초안)

H0는 `size_class: large`, `landmark_count: 4`(Arrival Well, Counterweight Map, return lift, Crown Well), 출구 5개라서 1280×720 화면 4개로 나눈다. 정식 설명은 그림을 시작할 때 `BRIEF_H0_AREAS.md`에 쓴다.

| 구역 | 위치 | 담는 것 | 이어지는 곳 |
|---|---|---|---|
| A `h0_a_arrival_approach` | 가운데 | 기존 brief 배치 그대로: Arrival Well, 접수 counter(`prop_h0_ration_counter`), 전경 가로보, 북쪽 통로의 G0 관문 | 북 → B(G0 통과), 동 → C, 남 → D |
| B `h0_b_exchange_shelf` | A 북쪽 | Counterweight Map(바닥 사물), 비어 있는 Crown Well과 그 위 구조물의 그림자, 출구 E02 Sluice Road(서), E04 Crownwell Ascent(북), E05 Foundry Tram(동) | 남 → A |
| C `h0_c_return_desk` | A 동쪽 | return desk(서비스 창구), 지하 return lift(내부 경로 `return_desk_lift`), 출구 E03 Mercy Causeway(동) | 서 → A |
| D `h0_d_ash_stair` | A 남쪽 | 출구 E01 Ash Stair 계단참(R1로 내려감, 지역 입구) | 북 → A |

brief의 "5개 외부 route를 화면 경계 통로 3개로 대체하지 않는다"를 지키려고, A의 남·북·동 통로는 내부 연결로 두고 출구는 B·C·D 안에 실제 구조물로 그린다.

## 상태 그림 계획

| 대상 | 상태 | 근거 |
|---|---|---|
| `prop_h0_ration_counter` | ps_open, ps_rationing | prop JSON, revisit `rv_after_rationing` |
| `prop_h0_counterweight_map` | ps_matched, ps_contested(카드 한 장이 precedence 줄로 다시 인쇄됨) | prop JSON, revisit `rv_after_filing` |
| `gate_g0_arrival_declaration` | closed(선언 전), open | E02~E05의 `route_open gate_g0` 조건 |
| 출구 E02~E05 | conditional, open | region exits `route_state` |
| 출구 E01 | open | region exits `route_state` |
| return lift | conditional, open | internal route `return_desk_lift` |

## 크기 기준 (작성자 설계, 초안)

COMMON의 "사물·구조물 크기는 플레이어 키(화면 96px)에 맞춘다"를 따른다. 플레이어(약 1.7 m)가 원본 192px로 보이므로 높이 1 m = 원본 110px, 가로 1 m = 220px, 바닥 깊이 1 m = 190px(60° 비율 유지). 시험 작업의 180px/m보다 사물이 약 1.2배 커진다. 예: counter 앞면 높이 약 1.0 m = 110px, 문 높이 약 2.3 m = 253px. brief가 고정한 바닥 배치(우물 외경 220, counter 바닥 260×110, 통로 폭)는 논리 px 그대로 둔다.

## 도구 변경

- `tool/iconkit/icons.py`: `prefetch` 기본 병렬 개수 8 → 2. 세션 10개가 같은 컴퓨터를 쓰기 때문.
- 예정: 구역 레이어 조립 도구(base_clean + 레이어 → master_composite, preview_reassembled, 좌표 어긋남 검사). 만들면 여기에 적는다.

## 체크리스트

- [x] 폴더 만들기, 시험 작업의 tool(__pycache__ 제외)·palette_h0.json·레시피 4개 복사, 아이콘 목록 그림과 키 비교용 플레이어 복사
- [x] 도구 불러오기 확인 (Python 3.13.7, numpy 2.3.3, Pillow 12.3.0, ImageMagick 7.1.2, 아이콘 618개)
- [ ] 톤앤매너 자료 반영 (도착 대기)
- [ ] `BRIEF_H0_AREAS.md` 작성
- [ ] A: base_clean, counter 2상태, G0 2상태, foreground_beam, master_composite, preview_reassembled, 게임 화면 미리보기
- [ ] B: base_clean, Counterweight Map 2상태, Crown Well 위 구조물, E02·E04·E05 2상태, 합성·미리보기
- [ ] C: base_clean, return desk, return lift 2상태, E03 2상태, 합성·미리보기
- [ ] D: base_clean, E01, 합성·미리보기
- [ ] 모아 보기 시트, QA.md, __pycache__ 정리
- [ ] 다음: R1 `mp06-bg-r1-v01` (brief부터)
