# g02-icons-genre-v01

상태: **candidate**, 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | g02 목록(`docs\art\projects\generic\catalog\g02_list.md`)의 판타지 밖 8장르 소지품 아이콘 31개 (128×128 평면 + 한 줄 16칸 시트) |
| 근거 | COMMON.md + GENERIC.md, V1 기준 `h0-icon-mood-v02`(tool 전체 + `palette_h0_mood.json` 복사), 팔레트 `recipes\palette_g02.json` |
| 만드는 곳 | `tool\make_icons.py`(아이콘마다 조각 정의) → `recipes\icon_*.json`, `tool\icon_sheet.py` |

## 진행

- [x] A 10개 — 시트 `preview\sheet_a_icons.png`, 16칸 시트 `output\iconset_g02_genre.png`(+ `.json` 번호표)
- [x] B 13개 — 시트 `preview\sheet_b_icons.png`, 16칸 시트 갱신
- [x] C 8개 — 시트 `preview\sheet_c_icons.png`, 16칸 시트 `output\iconset_g02_genre.png` 31칸 완성

## 작성자 설계·메모

- 총은 수평으로 만든 뒤 통째로 비스듬히 돌려 부품이 어긋나지 않게 했다.
- 16칸 시트는 목록 순서로 칸 번호가 고정이고, 아직 없는 아이콘 칸은 비워 둔다.

## 도구

V1 도구(`h0-icon-mood-v02\tool`)를 복사해 쓴다. 공통 변경(`make_palette.py`, `review_sheet.py --cols`, workers 2)은 `g02-people-fantasy-v01\JOB.md` 참고.

## 다시 시작

`tool`에서 생성 스크립트를 `--build`로 실행한다. 이미 만든 프레임은 건너뛴다.
