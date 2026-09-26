# h0-icon-collage-v01 — 아이콘 조합 방식 시험 제작

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | generator_calibration + 샘플 세트: at-icons 조각 조합(코드 조합 도구)으로 04 키트 그림을 만들 수 있는지 시험 |
| 근거 결정 | 사용자 결정 2026-09-26: 04 키트는 코드로 그린 그림(아이콘 조합 포함)을 최종 그림으로 허용. AI 생성 도구 시험은 전부 불합격. 코딩 금지 해제. 문서 반영은 다른 작업자 담당이라 이 작업은 규칙 문서를 수정하지 않음 |
| 소유권 | 이 작업자. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/h0-icon-collage-v01/`, `docs/art/projects/top_down_action_rpg/jobs/h0-icon-collage-v01/`. 정본·코드·씬 수정 없음 |
| 자산 identity | `player` (ID는 이 작업의 설계 ID), `enemy_ash_hound`, `prop_h0_ration_counter`, `prop_h0_counterweight_map`, `gate_g0_arrival_declaration`, `item_blank_return_form`(res_blank_form), `bg_h0_arrival_approach`(region_h0_undersign_exchange). 앞의 여섯은 모듈 content의 실제 ID |
| 입력 계약 버전 | 파일과 SHA-256은 `inputs.json`. 적용: PROJECT_ART_LAYER 0.1, PERSONAL_STYLE_CORE 0.3, H0 brief, 13/14 문서 |
| 카메라 | 지면 기준 하향각 60° 정사영, 방위 고정. 지면 깊이 ×0.866, 높이 ×0.5, 원본 180 px/m. 캐릭터는 정수리·어깨 윗면이 보이고 얼굴이 머리 아래쪽에 옴 |
| 입력 이미지 | 픽셀 입력 없음. 모양 재료는 `addons/at-icons/node2d` SVG 618개(MIT) 중 37종. `user_style_A.png`는 화풍 관찰용으로만 봄 |
| 팔레트 | H0 샘플 제안: 회보라 광물 바닥, 짙은 자주 윤곽선, 탁한 청동, 소량의 바랜 종이색 → `recipes/palette_h0.json` |
| 필요한 결과 | 아래 표. 캐릭터·사물은 투명 PNG, 접촉 그림자는 별도 `_shadow.png`, 배경은 불투명 2560×1440 |
| 내용 고정 | 배경은 H0 brief 배치: 우물 (790,290) 외경 220, 주 통로 남 x540..720 → 북 x550..710, 동쪽 연결 y400..550, 좌우 낮은 벽. 사람·글자·UI 없음 |
| 금지 | 원본 SVG 수정, 규칙 문서 수정, AI 그림 도구·외부 API, 글자·HUD 굽기, 반려된 H0 후보 참조, pixel 작업자 폴더 접근 |
| 수정 범위 | 이 job 폴더 안의 새 파일만 |
| 검수 | `QA.md` (자체 검토 2회 후 멈춤) |
| 중단 이유 | 없음 |

## 결과 파일 (assets/art/top_down_action_rpg/jobs/h0-icon-collage-v01/)

| 파일 | 크기 | 알파 | 피벗(원본 px) |
|---|---|---|---|
| `output/player/idle_down.png`, `idle_up.png`, `idle_left.png`, `idle_right.png` | 192×192 | 투명 | (96,186) 발 접점 |
| `output/player/walk_down_1.png` … `walk_down_4.png` | 192×192 | 투명 | (96,186) |
| `output/enemy_ash_hound/idle_left.png`, `idle_right.png` | 256×192 | 투명 | (140,178) / (116,178) |
| `output/prop_h0_ration_counter/prop_h0_ration_counter.png` | 560×400 | 투명 | (280,382) 앞면 바닥 중앙 |
| `output/prop_h0_counterweight_map/prop_h0_counterweight_map.png` | 440×300 | 투명 | (220,262) |
| `output/gate_g0_arrival_declaration/gate_g0_arrival_declaration.png` | 480×380 | 투명 | (240,360) |
| `output/item_blank_return_form/item_blank_return_form.png` | 112×96 | 투명 | (56,78) |
| `output/bg_h0_arrival_approach/bg_h0_arrival_approach.png` | 2560×1440 | 불투명 | (0,0) = 논리 (0,0) |
| `preview/preview_h0_1280x720.png` | 1280×720 | 불투명 | 검수용 합성, 런타임 자산 아님 |

각 PNG 옆 `.json`에 상태, 크기, 피벗, 사용 아이콘과 SHA-256, 레시피 해시가 있다. `_shadow.png`는 접촉 그림자 레이어다.

## 조합 도구

- `tool/iconkit/` 조합 엔진, `tool/build.py` 빌드(끝난 프레임은 건너뜀), `tool/compose_preview.py` 장면 합성, `tool/review_sheet.py` 검수 시트, `tool/inspect_icons.py`·`tool/catalog.py` 아이콘 고르기용 확대·목록 시트.
- 에셋마다 `recipes/<asset>.json` 레시피만 바꾸면 새 그림이 나온다. 공통 재질·화풍은 `recipes/palette_h0.json`.
- 재실행: `tool` 폴더에서 `py -3 -B build.py --all` 후 `py -3 -B compose_preview.py ..\recipes\scene_h0_preview.json`.
