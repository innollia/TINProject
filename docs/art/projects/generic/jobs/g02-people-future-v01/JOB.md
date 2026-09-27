# g02-people-future-v01

상태: **candidate**, 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | g02 목록(`docs\art\projects\generic\catalog\g02_list.md`)의 SF·우주 4, 사이버펑크 4, 포스트아포칼립스 3명 (초상화 + 전투 그림) |
| 근거 | COMMON.md + GENERIC.md, V1 기준 `h0-icon-mood-v02`(tool 전체 + `palette_h0_mood.json` 복사), 팔레트 `recipes\palette_g02.json` |
| 만드는 곳 | `recipes\_people_future.json` → `tool\make_people.py` (도구 원본은 g02-people-fantasy-v01) |

## 진행

- [x] A 3명: sf_astronaut, cp_hacker, pa_survivor — 시트는 `g02-people-modern-v01\preview\sheet_a_modern_future.png`에 함께 둠
- [x] B 4명(sf_captain, sf_scientist, cp_merc, pa_raider) — 시트 `preview\sheet_b_mixed_2.png`
- [x] C 4명(sf_marine, cp_agent, cp_ripperdoc, pa_scout) — 시트는 `g02-people-modern-v01\preview\sheet_c_mixed.png`에 함께

## 작성자 설계·메모

- 겨누기 공격은 팔을 짧게 줄이고 총을 정면 모양(총구 원)으로 바꿔 화면 쪽을 겨누게 했다(작성자 설계).

## 도구

V1 도구(`h0-icon-mood-v02\tool`)를 복사해 쓴다. 공통 변경(`make_palette.py`, `review_sheet.py --cols`, workers 2)은 `g02-people-fantasy-v01\JOB.md` 참고.

## 다시 시작

`tool`에서 생성 스크립트를 `--build`로 실행한다. 이미 만든 프레임은 건너뛴다.
