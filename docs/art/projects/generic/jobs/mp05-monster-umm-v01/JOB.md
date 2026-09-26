# mp05-monster-umm-v01 — 범용 몬스터: 언데드·마법·기계 (세션 05, 3순위)

상태: **제작 중.** 결과는 전부 candidate, 승인은 사용자만 한다. 특정 게임의 이름·문양·설정은 넣지 않는다.

| 필드 | 값 |
|---|---|
| 근거 | COMMON.md 3순위 표(세션 05: 해골, 유령, 골렘, 인형, 악마, 정령). 2순위 07 키트는 그림 파일을 쓰지 않아 건너뜀(`docs/art/projects/physics_puzzle_platformer/jobs/mp05-ppp-v01/JOB.md`) |
| 쓰기 범위 | `assets/art/generic/jobs/mp05-monster-umm-v01/`, `docs/art/projects/generic/jobs/mp05-monster-umm-v01/` |
| 형식 | RPG Maker 몬스터 구성 = 맵 시트(8방향 × 3칸) + 전투용 정면 그림 1장. **맵 시트는 8방향 기준이 확정되면 만든다(지금은 COMMON상 금지).** 이번에는 전투용 정면 그림만 |
| 카메라 | 60° 내려다보는 정사영, 정면 한 방향(탑다운 전투 적과 같음) |
| 크기 | 전투 적 규칙: 사람 크기 320×384(피벗 160,192), 작은 몸 224×272(피벗 112,136, 0.7배), 큰 몸 400×480(피벗 200,240, 1.25배). 선 두께·붓자국은 모두 같음(sprite 화풍) |
| 알파·레이어 | 투명 PNG, 피벗 = 몸 중심, 바닥 그림자 `_shadow.png`, 빛나는 부분 `_emit.png` |
| 팔레트 | `recipes/palette_mp05_generic.json` = `palette_h0_mood.json`을 `extends`로 물려받고 몬스터 재질만 추가(윤곽선·그림자·공통 색 그대로) |
| 도구 | `mp05-enemy-b-v01/tool` 최종판 복사(병렬 2, 팔레트 extends, offset_all, 이동 목록, check_edges.py) |
| 금지 | 글자·문양·기호(마법진, 룬 문자 등) 넣기, 특정 게임의 몬스터 복제, 떨어진 효과 그림(불꽃 효과 자체는 세션 10 몫. 불 정령은 몸이 불이라 몸으로만 그림) |

## 만들 목록 (16종, 전투용 정면 그림 각 1장)

| # | 파일 | 한국어 | 크기 | 모습 (작성자 설계) |
|---|---|---|---|---|
| 1 | skeleton_soldier | 해골 병사 | 사람 | 녹슨 투구·가슴판 조각, 이 빠진 칼과 금 간 둥근 방패 |
| 2 | skeleton_mage | 해골 마법사 | 사람 | 해진 두건 망토, 뼈 지팡이 끝의 흐린 빛 구슬 |
| 3 | zombie | 시체 괴물 | 사람 | 구부정한 몸, 찢어진 옷, 한쪽 팔을 앞으로 뻗음 |
| 4 | ghost | 유령 | 사람 | 아래가 흐려지는 창백한 형체, 늘어진 소매, 속이 비친 몸 |
| 5 | wraith | 망령 | 사람 | 검은 넝마 두건, 얼굴 자리에 두 점 빛, 녹슨 낫 |
| 6 | mummy | 미라 | 사람 | 누런 붕대, 풀린 끝자락, 붕대 틈 한쪽 눈빛 |
| 7 | lich | 리치 | 사람 | 해골 얼굴, 두꺼운 예복, 떠 있는 빛 구슬 둘, 해진 옷깃 |
| 8 | imp | 임프 | 작은 몸 | 붉은 갈색 작은 악마, 박쥐 날개, 긴 꼬리, 쪼그린 자세 |
| 9 | demon | 악마 | 큰 몸 | 뿔, 넓은 어깨, 박쥐 날개, 갈라진 피부 틈 불빛 |
| 10 | fire_spirit | 불 정령 | 사람 | 불꽃 몸통과 팔, 가운데 밝은 심, 아래는 꼬리처럼 가늘어짐 |
| 11 | living_grimoire | 살아있는 마법서 | 작은 몸 | 이빨처럼 갈라진 책장, 쇠 모서리, 떠 있음 |
| 12 | gargoyle | 가고일 | 사람 | 웅크린 돌 괴물, 돌 날개, 이끼·금 |
| 13 | stone_golem | 돌 골렘 | 큰 몸 | 쌓은 돌덩이 몸, 틈에서 흐린 빛, 굵은 팔 |
| 14 | living_armor | 움직이는 갑옷 | 사람 | 빈 투구 속 어둠, 녹슨 판금, 큰 칼 |
| 15 | clockwork_doll | 태엽 인형 | 사람 | 도자기 얼굴, 금 간 뺨, 등의 태엽 열쇠, 드레스 |
| 16 | marionette | 꼭두각시 | 사람 | 나무 관절 인형, 위로 늘어진 끊어진 줄, 칼 든 손 |

## 체크리스트

- [x] 팔레트 (`palette_mp05_generic.json`: bone·bone_dark·rotten·rag·rag_dark·ghost·bandage·robe_wine·imp_skin·demon_skin·horn·wing·flame_body·fire_core·hell_glow·soul·arcane·book_leather·moss·steel·porcelain·doll_dress·lace 추가. 나머지는 V1 그대로)
- [x] 1~4 (+ 모아 보기 `preview/sheet_generic_01_04.png`) — zombie 고침 1회: 둥근 옷 구멍과 가운데 상처가 과녁처럼 보임 → 찢긴 모양, 모자처럼 보이던 머리 → 흐트러진 가닥
- [x] 5~8 (+ `sheet_generic_05_08.png`) — mummy 고침 1회: 목을 굵게, 든 팔을 앞으로 뻗은 팔로(여전히 조금 어색함)
- [x] 9~12 (+ `sheet_generic_09_12.png`) — fire_spirit 고침 1회: 불꽃 아이콘 속 빈 구멍이 두 번째 입처럼 보임 → 채움
- [x] 13~16 (+ `sheet_generic_13_16.png`)
- [x] 전체 시트 `preview/sheet_generic_monsters_0.5x.png`(게임 크기), `preview/sheet_generic_monsters_1x.png`, QA.md, __pycache__ 없음
- [ ] 맵 시트(8방향 × 3칸): 8방향 기준 06:40 확정(`docs/art/mass_production/COMMON.md`로 옮겨짐). 다음 할 일: `h0-icon-8dir-v03/tool`의 build8.py·check8.py·export_sheet8.py·iconkit/walk8.py를 이 tool에 넣고, `h0-icon-8dir-v02/JOB.md` '양산 규칙'대로 몬스터마다 방향 레시피 5개(down, down_left, left, up_left, up; `<이름>_<방향>.json`)를 만든다. 사람형은 `h0-icon-8dir-v03/recipes/player_*.json`, 네 발은 `enemy_ash_hound_*.json`에서 시작. 칸 192×192 피벗(96,182), 큰 몸 384×384. 순서 build8 → export_sheet8 → check8. 떠 있는 것(ghost, wraith, fire_spirit, living_grimoire)은 다리 대신 위아래 흔들림.

## 결과 (assets/art/generic/jobs/mp05-monster-umm-v01/)

- 그림: `output/<이름>/<이름>.png` + `_shadow.png` + (눈빛·불꽃·빛 구슬이 있으면) `_emit.png` + `.json`. 16장.
- 레시피 `recipes/<이름>.json` 16개. 다시 만들기: `tool`에서 `py -3 -B build.py --all`.
- 도구: `mp05-enemy-b-v01` 최종판 + 새 `grid_sheet.py`(여러 그림을 피벗 기준 격자로 모음).
