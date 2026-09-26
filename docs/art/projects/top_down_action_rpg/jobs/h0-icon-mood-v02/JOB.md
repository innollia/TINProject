# h0-icon-mood-v02 — BS2 분위기 시험 (아이콘 조합)

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

사용자 결정 (2026-09-27): **V1**을 양산 화풍 기준으로 쓴다. 빛과 그림자는 게임 코드로 따로 구현하므로 V2·V3의 장면 조명은 그림에 넣지 않는다. 검수 이미지에 캐릭터를 배경 위에 합치지 않는다. 에셋만 따로 본 그림: `preview/asset_bg_h0_v1_1280x720.png`(배경만), `preview/asset_sheet_v1_props_0.5x.png`, `preview/asset_sheet_v1_characters_1x.png`. 배경에 그린 불빛 자리: `output/bg_h0_arrival_approach/lights.json`.

| 필드 | 값 |
|---|---|
| 목적 | 사용자 지적 "blacksouls2적인 분위기가 없다"(2026-09-27)에 대한 분위기 변형 시험. 고른 변형이 양산 세션 mp01~mp10의 분위기 기준이 된다 |
| 근거 | h0-icon-collage-v01과 같은 대상·배치를 색과 조명만 바꿔 비교. 참고 자료는 사용자가 가리킨 BLACK SOULS II `Graphics` 폴더(Parallaxes, Battlebacks, Tilesets, Characters만). 수치와 색 관계만 쟀고 픽셀·형태·모티프는 가져오지 않음 |
| 쓰기 범위 | `assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/`, 이 기록 폴더. 규칙 문서·게임 코드·씬·v01 폴더 수정 없음 |
| 진행 | 첫 작업자가 분석·도구·부품 빌드까지 하고 03:32 Kiro 재시작으로 끊김. 배경 빌드, 장면 3개, 비교 시트, 기록은 대화방에서 이어서 마침 |

## 변형

| 변형 | 바꾼 것 | 미리보기 |
|---|---|---|
| V1 | 어두운 팔레트(`palette_h0_mood.json`), 때·습기·녹 얼룩, 벽 발치 잔해·상자·배관 추가. 조명은 그림에 칠한 확산광 그대로(PROJECT_ART_LAYER 조명 규칙 안) | `preview/preview_h0_v1_1280x720.png` |
| V2 | V1 + 장면 조명: 화면 전체 어둡게(주변광 0.22), 화로·벽등·기둥 등불·우물 위 빛줄기·플레이어 주변만 밝게. 통로 최소 0.36~0.4, 상호작용 사물 0.55 | `preview/preview_h0_v2_1280x720.png` (+ `_light.png` 빛 지도) |
| V3 | V2와 같은 빛 위치, 세기만 중간(주변광 0.45, 통로 0.52~0.55) | `preview/preview_h0_v3_1280x720.png` |

비교 시트: `preview/compare_v01_v1_v2_v3.png`

## 도구 변경 (v01 복사본만 고침)

- 새 파일: `tool/iconkit/lighting.py`(장면 조명: 주변광, 빛 웅덩이, 따라다니는 빛, 빛줄기, 비네트, 읽힘 보장), `tool/compare_sheet.py`
- 고친 파일: `tool/iconkit/paint.py`·`render.py`(재질별 얼룩 grime 도장, 발광 `emit` 레이어, 빛번짐 glow를 추가·확장), `tool/build.py`(`_emit.png` 출력), `tool/compose_preview.py`(장면 JSON `lighting`, 발광 가림)
- 붓자국·윤곽선 방식은 v01과 같다. `lighting`이 없는 장면은 v01과 같은 결과가 나온다

## 재실행

`tool` 폴더에서 `py -3 -B build.py --all` 후 `py -3 -B compose_preview.py ..\recipes\scene_h0_v1.json` (v2, v3도 같은 방식).
