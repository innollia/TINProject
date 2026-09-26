# h0-icon-8dir-v03 — 8방향 캐릭터를 V1 색으로 다시 뽑기 + 양산용 합친 도구

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | `h0-icon-8dir-v02`의 8방향 플레이어·Ash Hound를 V1(`h0-icon-mood-v02`) 색과 도구로 다시 뽑고, 걸어 다니는 캐릭터를 만드는 양산 세션이 복사할 도구 하나(V1 기능 + 8방향 기능)를 만든다 |
| 근거 결정 | 2026-09-27 사용자: 분위기 V1, 빛과 그림자는 게임 코드, 캐릭터 스프라이트는 8방향(실제 RPG Maker 구성), 크기보다 일관성 |
| 시작점 | `tool/` = `h0-icon-mood-v02/tool` 전체 + `h0-icon-8dir-v02/tool`의 `build8.py`, `check8.py`, `export_sheet8.py`, `iconkit/walk8.py`. `recipes/` = 8dir-v02의 방향 레시피 10개. 바꾼 것은 `palette`(→ `palette_h0_mood.json`)와 개의 불씨 부품 `emit`(tail_embers 0.8, cracks 0.9, eye 1.0 — mood-v02와 같은 값)뿐 |
| 모양·칸·피벗·시트·파일 이름 | 8dir-v02 `JOB.md`와 같다(사람형 192×192·피벗 (96,182), 개 384×384·피벗 (192,320), 행 순서, `$` 시트) |
| 검수 | `QA.md` |

## 8dir-v02 도구에서 바꾼 것 (이 폴더의 복사본만)

- `build8.py`: `emit` 부품을 `<방향>_<칸>_emit.png`로 따로 저장하고 manifest에 `emit_file`을 적는다(mood-v02 `build.py`와 같은 방식).
- `export_sheet8.py`: 빛나는 부분이 있으면 `$<asset>_emit.png`, `$<asset>_diag_emit.png` 시트를 같은 배치로 만들고 시트 manifest에 `emit_file`을 적는다. 미리보기 바닥색을 V1 `floor`(#57505c)로 바꿨다.
- 그 밖의 코드는 그대로다. mood-v02의 `build.py`·`render.py`·`paint.py`(때 얼룩 grime, emit)는 8방향 파일과 그대로 맞물린다.

## 결과 (`assets/art/top_down_action_rpg/jobs/h0-icon-8dir-v03/`)

- 시트: `output/sheets/$player.png`, `$player_diag.png`, `$enemy_ash_hound.png`, `$enemy_ash_hound_diag.png` (+ `_shadow`, 개는 `_emit`)
- 칸: `output/<asset>/<방향>_<0|1|2>.png` (+ `_shadow.png`, `_emit.png`, `.json`)
- 미리보기: `preview/player_walk8.gif`, `preview/enemy_ash_hound_walk8.gif`, `preview/compare_player_enemy_ash_hound.png`, `preview/<asset>_cells.png`
- 다시 만들기(`tool` 폴더): `py -3 -B build8.py --all` → `py -3 -B export_sheet8.py player enemy_ash_hound --compare player,enemy_ash_hound` → `py -3 -B check8.py player enemy_ash_hound`
