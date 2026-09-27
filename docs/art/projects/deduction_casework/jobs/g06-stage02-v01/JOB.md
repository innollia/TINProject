# g06-stage02-v01 — 03 Deduction Casework · Stage 02 「모렌가의 빈 의자」(모렌 저택)

상태: **candidate**. 승인은 사용자만 한다. 게임 코드·씬·content 수정 없음.

| 필드 | 값 |
|---|---|
| 대상 | `case_02_morren_empty_chair.json` 장면 5, 핫스팟 18, 출구 11 + VISUAL 1~4, 힌지 A~C |
| 근거 | 정본 02 v5.1/v5.3/v5.5, 13A-1 Stage 2(7인), 13B-1, 13C(저택 팔레트), 13E Stage 2 |
| 색 | `recipes/palette_s02_morren.json`(V1 + 먹녹 벽지·적갈 목재·포도주/이끼 천·황동·회색 묘지 점토), 가족사진 `palette_s02_sepia.json` |

## 만든 것 (64개)

모아 보기: `preview/sheet_s02_characters_1x.png`, `preview/sheet_s02_objects.png`, `preview/sheet_s02_closeups.png`. 배경+물건(사람 없이): `preview/scene_s02_{foyer,dining,study,service,grave}_bg_objects_1280x720.png`.

- [x] 배경 5: `bg_s02_foyer`(A 쿼터뷰), `bg_s02_dining`(B 와이드 정면), `bg_s02_study`(C 쿼터뷰), `bg_s02_service`(D 2×1), `bg_s02_grave`(E 사이드뷰, 밤비)
- [x] 인물 5: `chr_s02_helen_stand`, `chr_s02_luca_stand`, `chr_s02_eva_stand`, `chr_s02_peter_stand`, `chr_s02_silla_slumped`
- [x] 초상화 7: `por_s02_oswald`, `_helen`, `_luca`, `_eva`, `_silla`, `_yona`, `_peter`
- [x] 물건 26: 현관(coat_rack, umbrella_stand, lectern_book, photo_table, wreath, yona_bag, shoe_row, bench_foyer), 식당(dining_table, setting_guest, teacup, chair_family, chair_silla, chair_peter, chair_guest, seat_plan), 서재(sofa, desk_will, wall_safe, window_soil), 하인구역(key_board, butler_desk, payroll_ledger), 묘지(gravestones, footprint_trail, case44_page) — 모두 `obj_s02_*`
- [x] 확대 21: attendance, photo_young, photo_wedding, photo_family, yona_bag_open, funeral_card, preservation_cover, shoe_soles, seat_plan, guest_setting, teacup, pill_bottle, pharmacy_receipt, luca_notebook, will, safe_gap, window_soil, key_spec, payroll, footprints, case44 — 모두 `cu_s02_*`
- [x] 장면 배치 5: `recipes/scene_s02_*.json` (핫스팟 → 그림 대응은 각 파일의 `hotspots`)

## 작성자 설계

- 축척·시점 틀은 Stage 01과 같다(320px/m, 쿼터뷰 먼 모서리 (1180,560)).
- VISUAL 1: 이름표 없이 의자 자체로 자리를 읽는다. 뒤쪽 가족 의자 셋 등받이에 같은 문장(방패형 자수), 앞줄에 실라 의자(서류가방), 피터 의자(앞치마 고리), 통로 쪽으로 밀린 평의자(젖은 외투) = Guest.
- 힌지 A: Guest 자리만 수프막·가득 찬 잔·펴지 않은 냅킨(`obj_s02_setting_guest`, `cu_s02_guest_setting`).
- 힌지 B / VISUAL 4: 금고 빈 칸 폭 70px = 보존커버 등 두께 70px, 양쪽 끈 눌림 두 줄(`cu_s02_safe_gap` ↔ `cu_s02_preservation_cover`).
- VISUAL 3: 여섯 밑창 중 4번째만 좁은 V자 홈 + 회색 점토(`cu_s02_shoe_soles`) ↔ 창턱 흙(`cu_s02_window_soil`) ↔ 묘지길 발자국(`cu_s02_footprints`). 캡션 없음.
- VISUAL 2: 가족사진 3장은 세피아 팔레트로, 사진 안의 인물은 사진이라는 그림의 일부로 그렸다(인물 스프라이트를 배경에 합친 것이 아님). 결혼식 신부 = 에바(시뇽·장부클립).
- 장례식 저녁이라 헬렌 검은 상복, 루카 짙은 갈색 상복(정본 등장인물 줄). 요나는 장면에 서 있지 않아 초상화만 만들었다.
- 금고 문·서류철은 물건(`obj_s02_wall_safe`), 벽의 금고 홈은 배경. 유언장은 책상 위(`obj_s02_desk_will`).
- 출구: 현관→식당(오른벽 문), 식당→현관/서재/하인구역(왼문·오른문·쪽문), 서재→식당/하인구역/묘지(주문·보조문·창), 하인구역→식당/서재, 묘지→서재(창)/식당(측문).

## 도구 (stage01 도구 복사본 위에 추가)

- `g06kit/front.py`: stage01 스크립트에 있던 정면 가구·벽·문·창, 등각 물건 틀, 종이·손글씨 조각을 공용으로 옮김(+ `front_window` 커튼, `chair_front`).
- `g06kit/outfits.py`: 옷차림 사양(dict)으로 인물 조립 `figure()`(원피스·치마·재킷·조끼·앞치마·넥타이·안경 3종·콧수염·모자 4종·장갑), 의자 앉기 자세 `pose_sit_chair`(쓰러짐 slump), 머리 모양 3종 추가(bun, wave, crop).
- `g06kit/portrait.py`, `g06kit/stage.py`(스테이지 등록기·팔레트 쓰기·단색 팔레트 `desat_palette`·장면 JSON 쓰기), `make.py`(범용 레시피 작성).
- `rooms.py`: 적갈색 문짝을 한 단계 어둡게.

## 재실행

`tool`에서 `py -3 -B make.py` → `py -3 -B build.py --all` → `py -3 -B make.py --scenes` → `py -3 -B compose_preview.py ..\recipes\scene_s02_foyer.json`(dining, study, service, grave 같은 방식).
