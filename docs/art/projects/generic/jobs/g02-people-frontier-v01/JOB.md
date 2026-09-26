# g02-people-frontier-v01

상태: **candidate**, 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | g02 목록(`docs\art\projects\generic\catalog\g02_list.md`)의 스팀펑크 3, 해적·바다 4, 서부 4명 (초상화 + 전투 그림) |
| 근거 | COMMON.md + GENERIC.md, V1 기준 `h0-icon-mood-v02`(tool 전체 + `palette_h0_mood.json` 복사), 팔레트 `recipes\palette_g02.json` |
| 만드는 곳 | `recipes\_people_frontier.json` → `tool\make_people.py` (도구 원본은 g02-people-fantasy-v01) |

## 진행

- [x] A 5명: sp_inventor, pi_captain, pi_pirate, we_sheriff, we_gunslinger — 시트 `preview\sheet_a_frontier.png`
- [ ] B
- [ ] C

## 작성자 설계·메모

- 카우보이 모자 꼭대기 홈이 구멍처럼 보여 한 번 고침.

## 도구

V1 도구(`h0-icon-mood-v02\tool`)를 복사해 쓴다. 공통 변경(`make_palette.py`, `review_sheet.py --cols`, workers 2)은 `g02-people-fantasy-v01\JOB.md` 참고.

## 다시 시작

`tool`에서 생성 스크립트를 `--build`로 실행한다. 이미 만든 프레임은 건너뛴다.
