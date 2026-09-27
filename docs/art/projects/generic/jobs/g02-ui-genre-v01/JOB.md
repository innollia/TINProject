# g02-ui-genre-v01

상태: **candidate**, 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | g02 목록(`docs\art\projects\generic\catalog\g02_list.md`)의 판타지 밖 8장르 창틀 (글자 없는 9-slice, 192×192, 모서리 48px) |
| 근거 | COMMON.md + GENERIC.md, V1 기준 `h0-icon-mood-v02`(tool 전체 + `palette_h0_mood.json` 복사), 팔레트 `recipes\palette_g02.json` |
| 만드는 곳 | `tool\make_ui.py` → `recipes\ui_*.json`, `tool\ui_slice.py`(9조각 + 늘린 확인 그림 + 여백 json) |

## 진행

- [x] A 3개: ui_mo_panel, ui_sf_panel, ui_we_panel — 확인 그림 `preview\<id>_stretched.png`
- [x] B 3개: ui_ho_panel, ui_cp_panel, ui_pi_panel — `preview\sheet_b_ui.png`
- [x] C 2개: ui_sp_panel, ui_pa_panel — `preview\sheet_c_ui.png`

## 작성자 설계·메모

- 가운데는 어두운 반투명(09 §12.7). 모서리 장식만 48px 안에 두고 변은 길이 방향으로 같게 해 늘려도(반복해도) 이음새가 없다.
- SF 창틀 모서리 괄호가 윤곽선에 묻혀 검게 보여 굵기·자리를 한 번 고침.

## 도구

V1 도구(`h0-icon-mood-v02\tool`)를 복사해 쓴다. 공통 변경(`make_palette.py`, `review_sheet.py --cols`, workers 2)은 `g02-people-fantasy-v01\JOB.md` 참고.

## 다시 시작

`tool`에서 생성 스크립트를 `--build`로 실행한다. 이미 만든 프레임은 건너뛴다.
