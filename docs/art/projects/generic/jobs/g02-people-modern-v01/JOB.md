# g02-people-modern-v01

상태: **candidate**, 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | g02 목록(`docs\art\projects\generic\catalog\g02_list.md`)의 현대·도시 8명 + 호러·오컬트 6명 (초상화 + 전투 그림) |
| 근거 | COMMON.md + GENERIC.md, V1 기준 `h0-icon-mood-v02`(tool 전체 + `palette_h0_mood.json` 복사), 팔레트 `recipes\palette_g02.json` |
| 만드는 곳 | `recipes\_people_mo.json` → `tool\make_people.py` (도구 원본은 g02-people-fantasy-v01) |

## 진행

- [x] A 5명: mo_student, mo_police, mo_surgeon, mo_nurse, ho_cultist — 시트 `preview\sheet_a_modern_future.png`
- [ ] B
- [ ] C

## 작성자 설계·메모

- 학생 세일러 깃이 가슴을 덮는 띠로 보여 V자 깃으로 한 번 고침.
- 아기(mo_baby)는 도구에 앉은 자세가 없어 작은 서 있는 체구(figure_scale 0.62)로 만든다(작성자 설계).

## 도구

V1 도구(`h0-icon-mood-v02\tool`)를 복사해 쓴다. 공통 변경(`make_palette.py`, `review_sheet.py --cols`, workers 2)은 `g02-people-fantasy-v01\JOB.md` 참고.

## 다시 시작

`tool`에서 생성 스크립트를 `--build`로 실행한다. 이미 만든 프레임은 건너뛴다.
