# g02-people-fantasy-v01 — 판타지 3장르 사람 (초상화 + 전투 그림)

상태: **candidate**, 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | g02 목록(`docs\art\projects\generic\catalog\g02_list.md`)의 다크 판타지·고딕 14, 중세 판타지 15, 동양 판타지 14명 |
| 근거 | COMMON.md + GENERIC.md, V1 기준 `h0-icon-mood-v02`(tool 전체 + `palette_h0_mood.json` 복사) |
| 형식 | 초상화 320×320(3/4 흉상, 얼굴 기준점 (160,146) 고정). 전투 그림 정면 384×384(사람 크기, 발 피벗 (192,374)), A는 `battle_idle/attack/hit`, B·C는 `battle_idle`. 8방향 걷기 스프라이트는 COMMON.md '미정'이라 만들지 않음 |
| 결과 | `output\<id>\portrait.png`, `battle_*.png`(+ `_shadow.png` 발밑 그림자, 빛나는 부분이 있으면 `_emit.png`) |
| 사양 | `recipes\_people_df.json`, `_people_mf.json`, `_people_ef.json` → `make_people.py`가 `<id>_battle.json`, `<id>_portrait.json` 생성 |

## 진행

- [x] A 12명: df_monster_hunter, df_crusader, df_priest, df_noble_lady, mf_farmer, mf_knight, mf_mage, mf_guard, mf_soldier, ef_samurai, ef_monk, ef_ninja — 시트 `preview\sheet_a_fantasy_1.png`, `sheet_a_fantasy_2.png`, `sheet_stop_point_3people.png`
- [ ] B 14명
- [ ] C 17명

## 작성자 설계 (문서에 없는 값)

- 체형은 V1 플레이어처럼 머리 큰 약 3.2등신. 전투 캔버스는 높이 384 고정, 폭도 384로 두고 인물을 0.9배로 그려 칼을 들어 올린 공격 자세와 모자가 잘리지 않게 함.
- 공격 자세: 휘두르기(swing), 들어 찌르기(thrust), 겨누기(aim, 팔을 앞으로 줄이고 총을 정면 모양으로 바꿈), 주문(cast), 던지기(throw) 등. 피격: 몸을 뒤로 젖히고 눈을 감음.
- 초상화: 같은 인물을 머리 중심 2배로 다시 잡고 눈·코·입을 오른쪽으로 옮겨 3/4 방향을 냄. 얼굴 기준점이 모든 g02 초상화에서 같다.

## 도구에 추가·변경한 것 (복사본만)

- `tool\make_palette.py` → `recipes\palette_g02.json`: V1 팔레트 그대로 + 피부·머리·천·금속·빛 재질 추가(V1 coat/leather와 같은 명암 비율). 확대(초상화)에서 얼룩이 뭉쳐 보여 천·금속 얼룩 세기를 낮추고 피부 명암 경계를 매끈하게 함.
- `tool\g02kit\`(core, body, head, outfit, items): 사양 JSON으로 몸·얼굴·표정·머리·모자·옷·장신구·손에 든 물건을 아이콘 조각으로 조립. 방패 아이콘 가운데 틈이 비치지 않게 왼쪽 반쪽 두 장을 거울로 겹쳐 씀. 반복 조각(repeat)도 회전·거울·확대에 같이 따라가게 함.
- `tool\make_people.py`: `recipes\_people*.json` → 레시피 두 개, `--build`로 바로 빌드. `figure_scale`(작은 체구).
- `tool\review_sheet.py`: `--cols`(여러 줄 격자), `_emit.png` 건너뜀.
- `tool\iconkit\icons.py`: 아이콘 변환 병렬 개수 8 → 2.
- 이 컴퓨터는 ImageMagick 7.1.2가 PATH에 없어 명령 앞에 `C:\Program Files\ImageMagick-7.1.2-Q16-HDRI`를 붙여 실행했다(설치 없음).
- 같은 도구를 `g02-people-modern-v01`, `g02-people-future-v01`, `g02-people-frontier-v01`에 복사해 쓴다(이 폴더가 원본).

## 다시 시작

`tool`에서 `py -3 -B make_palette.py` → `py -3 -B make_people.py --build`(또는 `--tier B`). 이미 만든 프레임은 건너뛴다.
