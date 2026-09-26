# mp01-props-common-v01 — 아이템 2개와 공용 사물 3개

상태: **제작 중, candidate.** 승인은 사용자만 한다. 게임에 연결하지 않는다.

## 기준 (2026-09-27 04시 확정, `C:\Users\Sherum\.kiro\crew\workspace\tin_mass_production\COMMON.md`)

- 화풍: 분위기 시험 `h0-icon-mood-v02`의 V1(어두운 색, 낡은 재질, 그림에는 확산광만). 빛과 그림자는 게임 코드가 한다.
- 도구: `h0-icon-mood-v02/tool/` 복사본(__pycache__ 제외). 팔레트: `palette_h0_mood.json` 복사본 그대로. 준비 단계에서는 옛 도구·팔레트를 복사하지 않았으므로 바꿀 것 없음.
- 오브젝트는 투명 PNG, 바닥 접촉 피벗, 그림자는 `_shadow.png`, 빛나는 부분은 `_emit.png`로 따로. 캐릭터와 합친 확인 그림은 만들지 않는다.

## 도구에서 바꾼 것

- `tool/iconkit/icons.py`: 아이콘 변환 병렬 개수 기본값 8 → 2(다른 세션 9개와 동시 실행).
- `tool/iconkit/render.py`: 형태 옵션 `"decal": true` 추가. 도구가 그림 전체 둘레에 짙은 바깥 윤곽선을 둘러서 바닥 분필이 검은 선으로 나왔다. decal 형태는 따로 그려 윤곽선을 받지 않고 오브젝트 아래에 깔린다. `decal`이 없는 레시피는 V1과 똑같이 나온다.
- `tool/review_sheet.py`: 모아 보기 시트에서 긴 이름표가 겹치지 않게 칸 너비를 이름표에 맞춤(그림 결과에는 영향 없음).

## 공통 규격

| 필드 | 값 |
|---|---|
| 납품 유형 | 독립 소품(오브젝트). 배경에 굽지 않는다. 배경 세션은 놓일 자리만 적는다 |
| 형식 | 투명 PNG, 바닥 접촉 피벗, `_shadow.png`(접촉 그림자·바닥 AO), 빛나는 것만 `_emit.png`, 파일마다 `.json` 기록 |
| 크기 | 아이템 128×128(크기 통일 '물건 아이콘'). 사물은 크기 규정이 없어 물건 크기에 32px 이상 여백을 둔 캔버스(작성자 설계) |
| 비율 | 플레이어 그림 키(발~정수리 약 180px)를 1.7m로 보고 맞춘다: 가로 약 210px/m, 바닥 깊이 약 182px/m, 서 있는 높이 약 105px/m(60° 계산). 아이템은 줍는 물건이라 시험 작업처럼 실제보다 크게 그린다 |
| 카메라·빛 | 지면 기준 60° 정사영, 방위 고정, 도구 기본 확산광(왼쪽 위) |
| 색 | `palette_h0_mood.json` 그대로. 새 색 2개는 레시피의 `color`로만 지정(작성자 설계): 분필 `#9d97a2`, 마력 매체 `#5f8f8a`(빛 `#7fb3ad`) |
| 금지 | 글자·읽히는 기호·숫자·UI, 김·빛줄기 같은 움직이는 효과(세션 10), 원작 요소, 원본 SVG 수정, 코드·content·규칙 문서 수정, 다른 mp 번호 폴더, git |
| 쓰기 범위 | `assets/art/top_down_action_rpg/jobs/mp01-props-common-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp01-props-common-v01/` |
| 검수 | 하나씩 read 도구로 직접 본다(잘림, 여백, 원래 아이콘 티, 상태 차이). 묶음이 끝나면 review_sheet.py 모아 보기 시트. 게임 연결 금지라 실제 게임 3해상도 검수는 하지 않는다 |

## 자산별 계획

| 자산 | 캔버스 · 피벗 | 상태(프레임) | 정보 분류 | 근거 |
|---|---|---|---|---|
| `item_blank_return_form` 빈 반송 서식 | 128×128 · (64,90) 종이 아래 가장자리 | 기본 | 증거·직접 상호작용 | quest 아이템, tint `record_grey`, `act_file_return_form`. V1 레시피를 128 캔버스로 옮김 |
| `item_ash_thread_spool` 재 실타래 | 128×128 · (64,90) 실패 아래 바닥 | 기본(가마빛 알갱이 `_emit`) | 증거·직접 상호작용 | material 아이템, tint `kiln_amber`, 엮기 기술 `act_weave_lash` 재료, R1 가마 지역에서 받음 |
| `art_prop_route_marker` 길 표지 | 192×192 · (96,112) 말뚝 밑동 | normal, recognized, trace, damaged | 길찾기·상황 이해 | 길 안내자 `npc_07_bryn_oskel`의 `mark_route`, 선택지 `ch_mark_the_safe_segment`(분필값), 04 문서 MARK_ROUTE |
| `art_prop_recovery_anchor` 복귀 지점 | 320×320 · (160,180) 판 가운데 바닥 | normal, used | 길찾기·상황 이해 | `content/recovery/rec_*.json`의 `respawn.prop_id`, `recovery_controller.gd`의 `field.anchor_id`, 08 문서 회복 7종 |
| `art_prop_magic_concentration_device` 농도 장치 | 192×320 · (96,244) 장치 가운데 아래 바닥 | charged(`_emit`), spent | 증거·직접 상호작용 | 12 문서 §2.3 분산·순환 장치, 지역 JSON `concentration`, `prop_r2_disperser_housing` 상태 설명 |

모양(모두 작성자 설계):

- 재 실타래: 뼈빛 실패가 옆으로 누워 있고 잿빛 실이 두껍게 감겨 있다. 풀린 실 끝이 바닥에 끌리고, 실 사이로 가마빛 알갱이가 비친다.
- 길 표지: 무릎 아래 높이의 나무 말뚝, 분필 칠한 머리판, 노끈과 포도주색 천 조각. 바닥에 분필로 두 줄 띠와 시작 가로줄, 점 세 개를 그려 걸을 수 있는 구간을 가리킨다. recognized는 청동 등록표를 단다. trace는 분필이 바래고 끊긴다(안내자가 죽으면 일부만 작동). damaged는 오염 구간이라 분필이 번지고 습기 얼룩이 번진다.
- 복귀 지점: 바닥에 박힌 지름 약 1m의 둥근 청동 판, 가장자리 눈금 홈, 짙은 돌 상감, 발로 닳아 반들거리는 발자리. 뒤쪽 왼편에 무릎 높이 쇠기둥과 청동 고리. used는 이번 죽음에 한 번 쓴 뒤라 판에 재 얼룩과 새 긁힘이 남는다(`cooldown: per_death`).
- 농도 장치: 쇠 받침대와 바닥 고리 위의 청동 원통(굴뚝 갓까지 약 1.4m, 가슴 높이), 쇠 덮개와 통풍구, 앞면의 유리 눈금관, 옆의 판독 카드. charged는 눈금관에 매체가 차 있고 약하게 빛난다(게임 코드용 빛 제안: `{"color": "#7fb3ad", "radius": 60}`). spent는 매체가 말라 바닥에만 남고 카드에 줄·점 표시가 생긴다. 김이나 매체 흐름은 그리지 않는다(12 문서).

## 결과 파일

- `output/<자산>/<자산>[_<상태>].png`, `_shadow.png`, `_emit.png`(빛나는 것만), `.json` — 모두 10장
- `preview/sheet_items_props_1x_0.5x.png`: 아이템·사물 모아 보기 시트(1배, 0.5배 = 게임 화면 크기)
- 재실행: `tool` 폴더에서 `py -3 -B build.py --all`

## 진행 체크리스트

- [x] 자료 읽기, 만들 목록, 계획
- [x] V1 도구·팔레트 복사, workers 2
- [x] item_blank_return_form
- [x] item_ash_thread_spool (1번 고침)
- [x] art_prop_route_marker 4상태 (2번 고침)
- [x] art_prop_recovery_anchor 2상태 (1번 고침)
- [x] art_prop_magic_concentration_device 2상태 (2번 고침)
- [x] 모아 보기 시트
- [x] QA.md, inputs.json
- [ ] __pycache__ 정리(이 세션 작업이 전부 끝날 때)
