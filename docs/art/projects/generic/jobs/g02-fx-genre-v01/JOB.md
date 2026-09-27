# g02-fx-genre-v01

상태: **candidate**, 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | g02 목록(`docs\art\projects\generic\catalog\g02_list.md`)의 판타지 밖 8장르 효과 11개 (192×192 칸, 한 줄 5칸) |
| 근거 | COMMON.md + GENERIC.md, V1 기준 `h0-icon-mood-v02`(tool 전체 + `palette_h0_mood.json` 복사), 팔레트 `recipes\palette_g02.json` |
| 만드는 곳 | `tool\make_fx.py` → `recipes\fx_*.json`, `tool\fx_sheet.py` |

## 진행

- [x] A 4개: fx_mo_muzzle_flash, fx_ho_possession, fx_sf_laser_hit, fx_sp_steam_burst — `output\<id>\<id>_sheet.png`(+ 더하기 합성용 `_sheet_emit.png`), 확인 `preview\sheet_a_fx.png`
- [x] B 4개: fx_cp_glitch, fx_pa_radiation, fx_pi_cannon_smoke, fx_we_dust — `preview\sheet_b_fx.png`
- [x] C 3개: fx_ho_wail, fx_sf_plasma_burst, fx_pa_shrapnel — `preview\sheet_c_fx.png`

## 작성자 설계·메모

- 증기 분출이 뒤 프레임에서 칸 오른쪽에 잘려 퍼지는 범위를 한 번 줄임.
- 효과에는 윤곽선을 넣지 않았다(빛나는 효과에 검은 테가 생기지 않게, 작성자 설계).

## 도구

V1 도구(`h0-icon-mood-v02\tool`)를 복사해 쓴다. 공통 변경(`make_palette.py`, `review_sheet.py --cols`, workers 2)은 `g02-people-fantasy-v01\JOB.md` 참고.

## 다시 시작

`tool`에서 생성 스크립트를 `--build`로 실행한다. 이미 만든 프레임은 건너뛴다.
