# h0-icon-8dir-v02 — 아이콘 조합 도구 8방향 캐릭터 시험

상태: **candidate (후보)**. 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | 아이콘 조합 도구로 RPG Maker 방식 8방향 캐릭터(사람형 + 네 발 짐승)를 만들 수 있는지 시험하고, 양산 세션이 따를 레시피·파일 이름·시트 배치를 정한다 |
| 근거 결정 | 사용자 결정 2026-09-27: 캐릭터 스프라이트는 8방향, 실제 RPG Maker 기준, 이미지 크기보다 일관성. 04 계획서 09 §12.2의 '8방향 가정 금지'는 이 결정으로 풀렸다(문서는 수정하지 않음) |
| 소유권 | 이 작업자. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/h0-icon-8dir-v02/`, `docs/art/projects/top_down_action_rpg/jobs/h0-icon-8dir-v02/`. 다른 job 폴더(h0-icon-mood-v02, h0-icon-8dir-v01)·게임 코드·씬·규칙 문서 수정 없음, git 커밋 없음 |
| 시작점 | v01(h0-icon-collage-v01)의 `tool/` 전체와 레시피 5개(`player_front/back/side.json`, `enemy_ash_hound.json`, `palette_h0.json`)를 그대로 복사. 복사본은 수정하지 않았고, 8방향 레시피는 새 파일 |
| 자산 | `player`, `enemy_ash_hound` |
| 칸·피벗 | 사람형 192×192(게임 96 px), 피벗 (96,182) = 두 발 사이 바닥점. 개는 2배 칸 384×384, 피벗 (192,320) = 몸 중심 아래 바닥점. 한 캐릭터의 24칸은 크기·피벗이 모두 같다 |
| 카메라 | 60° 고정. 캐릭터는 v01처럼 키를 줄이지 않고, 남북(깊이) 방향 길이·걸음만 0.5배(RPG Maker식 눈속임) |
| 빛 | 팔레트 sprite 스타일의 빛 하나(왼쪽 위). 반전 칸은 모양만 뒤집고 다시 칠하므로 빛은 그대로 왼쪽 위 |
| 팔레트 | `recipes/palette_h0.json`. 레시피에는 재질·색 이름만 쓴다(hex 없음) |
| 검수 | `QA.md` (자체 검토 2회 후 멈춤) |

## 결과 파일 (assets/art/top_down_action_rpg/jobs/h0-icon-8dir-v02/)

| 파일 | 내용 |
|---|---|
| `output/sheets/$player.png` | 576×768, 3칸 × 4행: 아래, 왼쪽, 오른쪽, 위 |
| `output/sheets/$player_diag.png` | 576×768, 3칸 × 4행: 왼쪽 아래, 오른쪽 아래, 왼쪽 위, 오른쪽 위 |
| `output/sheets/$enemy_ash_hound.png`, `$enemy_ash_hound_diag.png` | 1152×1536 (384 칸), 행 순서 같음 |
| `output/sheets/$<asset>_shadow.png`, `$<asset>_diag_shadow.png` | 같은 배치의 접촉 그림자 |
| `output/sheets/$<asset>.json` | 칸 크기, 피벗, 행·칸 뜻, 원본 칸 경로, SHA-256 |
| `output/<asset>/<방향>_<칸>.png` (+ `_shadow.png`, `.json`) | 칸별 원본과 manifest(아이콘 SHA-256, 레시피 해시, 반전 여부) |
| `preview/player_walk8.gif`, `preview/enemy_ash_hound_walk8.gif` | 8방향 걷기(0-1-2-1, 200 ms), 나침반 배치 |
| `preview/compare_player_enemy_ash_hound.png` | 같은 배율 비교(1배 8방향 + 게임 배율 0.5배) |
| `preview/<asset>_cells.png` (+ `_round0`, `_round1`) | 검수 시트, 기준선: 피벗·아래 서기 머리 위 |
| `preview/<asset>_consistency.json` | check8 수치 |

칸 번호 0·1·2 = RPG Maker의 1·2·3칸: 0 왼발 앞, 1 서기(대기), 2 오른발 앞. 재생 0-1-2-1(= 1-2-3-2).

## 도구에 추가한 것 (새 파일만)

- `tool/iconkit/walk8.py`: 8방향 이름·RPG Maker 방향 번호(2·4·6·8·1·3·7·9)·시트 행 순서. 레시피의 `rig`에서 걷기 3칸을 자동으로 만든다(다리 앞뒤, 뒷발 들기, 팔 흔들기, 몸 2 px 내려감, 꼬리·스카프 끝 흔들림). 반전 방향 생성(칸 0↔2 교환해 0이 항상 왼발), 비대칭 부품 `only: source / mirror`.
- `tool/build8.py`: 방향 레시피 → 칸 PNG·그림자·manifest. 끝난 칸은 건너뛴다(v01 `build.py`의 해시 함수 재사용).
- `tool/export_sheet8.py`: 기본·대각선 시트, 그림자 시트, 시트 manifest, 8방향 걷기 GIF, 검수 시트, 비교 그림.
- `tool/check8.py`: 8방향 키·머리 크기·발 위치·외곽선 밝기·빛 방향 수치. 칸 밖으로 나가거나 레시피가 빛·스타일을 덮어쓰면 실패.
- 기존 파일 수정: **없음**. v01에서 복사한 `build.py`, `iconkit/render.py` 등은 그대로다.

재실행(`tool` 폴더): `py -3 -B build8.py --all` → `py -3 -B export_sheet8.py player enemy_ash_hound --compare player,enemy_ash_hound` → `py -3 -B check8.py player enemy_ash_hound`

## 양산 규칙 (8방향 레시피)

1. 방향 5개만 그린다: down, down_left, left, up_left, up. 파일 `recipes/<asset>_<방향>.json`에 `"view"`를 쓰고, left·down_left·up_left에는 `"mirror_view"`(right·down_right·up_right)를 써서 반전으로 만든다.
2. 칸: 사람형 192×192·피벗 (96,182). 큰 캐릭터는 정수배(2배 384×384), 피벗 x = 칸 가운데. 한 캐릭터의 모든 방향은 canvas·pivot·palette·style이 같고 `light`·`style_override`·hex 색은 쓰지 않는다.
3. 부품 이름·태그는 캐릭터 기준 왼쪽/오른쪽(leg_left, arm_right…)으로 쓴다. 먼 쪽 팔다리는 몸 뒤 z로, `shade.threshold` 0.62~0.7로 어둡게.
4. 대각선: 머리 중심은 그대로 두고, 몸 앞면 부품은 x를 몸 반지름×sin(방향각)만큼 옮긴다(아래 0°, 왼쪽 아래 −45°, 왼쪽 −90°, 왼쪽 위 −135°, 위 180°). 남북 깊이 길이는 0.5배.
5. `rig`: 다리 pivot=엉덩이, len=발까지; phase +1 = 왼다리·오른팔(네 발은 앞왼+뒤오른). stride 사람 14 / 네 발 22, lift 3 / 4, bob 2. 칸 0·1·2는 도구가 만든다.
6. 비대칭 부품(가방·끈·스카프 끝): 반전하면 반대편에 가는 것은 `"only": "source"`, 반전 방향에서 보이는 모양은 그 방향 좌표로 다시 그려 `"only": "mirror"`. 끈은 앞면이 보이면 왼쪽 위→오른쪽 아래, 등이 보이면 오른쪽 위→왼쪽 아래.
7. 파일: 칸 `output/<asset>/<방향>_<0|1|2>.png`, 시트 `output/sheets/$<asset>.png`(행: 아래·왼쪽·오른쪽·위)와 `$<asset>_diag.png`(행: 왼쪽 아래·오른쪽 아래·왼쪽 위·오른쪽 위), 그림자는 `_shadow`.
8. build8 → export_sheet8 → check8 순서로 돌리고, check8이 실패하면 고친다. 결과는 전부 candidate.
