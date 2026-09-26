# mp01-rr-objects-v01 — Rule Rewrite 보드 물체 그림 (2순위)

상태: **제작 중, candidate.** 승인은 사용자만 한다. 게임에 연결하지 않는다(모듈의 `art/` 파일은 건드리지 않는다).

## 근거

- 규칙: `C:\projects\TINProject\docs\art\mass_production\COMMON.md`의 2순위(세션 01 = 01 Rule Rewrite). 그림은 아이콘 조합으로만, V1 도구와 같은 선·명암·붓자국 밀도.
- 키트 계획서 `plans/kits/01_RULE_REWRITE_KIT.md` §8: 예전 at-icons 월드 그림의 조립 기준은 2026-09-25부터 현행 지침이 아니고, 대체 이미지 기반이 정해지면 캐릭터·BOX/DOOR·ROCK·목표물을 다시 정한다. 기존 파일은 그대로 둔다. 글자는 단어 타일의 자체 글꼴이 맡는다.
- 모듈: `modules/rule_rewriting/presentation/rule_board_view.gd`는 물체 종류(kind)마다 그림 한 장(`art/<kind>.svg`)을 2D 보드 칸과 3D 세워 둔 그림(Sprite3D), 인벤토리 미리보기에 같이 쓴다. 보드 칸 색은 `#1a2026`/`#20272d`로 매우 어둡다.
- 보드 JSON 16개에서 쓰는 물체: WALL 232, BOX 158, MOTH 15, ROCK 12, BASIN 9, BEACON 6, STAR 6, DOOR 7, FLAG 4, GATE 4, BABA 3, LAMP 3, LARK 3 등 29종(README 기준 28종 + BABA/PLAYER/METRIX 별칭).

## 규격 (작성자 설계)

| 항목 | 값 |
|---|---|
| 캔버스 | 192×192 투명 PNG(크기 통일의 '타일 한 칸'). 칸 안에서 크게 보여야 해서 물체는 약 150px까지, 여백 약 20px 이상 |
| 시점 | 키트를 따른다: 보드 칸 아이콘이자 3D에 세워 두는 그림이라 앞에서 조금 내려다본 모습. 상자·벽·판처럼 윗면이 있는 것만 도구의 돌출(윗면+앞면)을 쓴다 |
| 바닥선 | 서 있는 물체의 바닥을 y≈160에 맞춤(3D에 세울 때 기준). 피벗 (96,160) |
| 그림자·발광 | 보드는 그림자 레이어를 쓰지 않아 접촉 그림자를 만들지 않는다. 불·등불만 `_emit.png` |
| 색 | `palette_rr.json` = V1 팔레트 그대로 + `rr_*` 재질(종류마다 알아보기 쉬운 색). 밝기는 V1 범위 안(V1 종이색보다 밝게 하지 않음). 어두운 보드 칸 위에서 구별되게 중간 밝기로 |
| 도구 | `mp01-props-common-v01/tool` 복사본 = V1 도구 + workers 2 + `decal` + 모아 보기 시트 이름표 너비(변경 내용은 그 작업의 JOB.md) |
| 금지 | 글자·숫자·원작(Baba Is You) 캐릭터·팔레트·레벨 그림 복제, 아이콘 그림문자를 그대로 한 장 붙이기, 모듈 파일 수정, git |

## 만들 목록 (27개)

| 묶음 | 물체 |
|---|---|
| A 고정 구조 | ROCK, WALL, BOX, DOOR, GATE, PAD, PANEL |
| B 작은 물건 | KEY, TOKEN, STAR, PEARL, INK, BELL, CORE |
| C 불·빛 | LAMP, LANTERN, BEACON, EMBER, LAVA |
| D 나머지 | POOL, BASIN, GLASS, RUNE, TURNER, VINE, FLAG, METRIX(묶음 미리보기) |

건너뜀(8방향 기준 대기): BABA, PLAYER(주인공), MOTH, LARK(규칙에 따라 돌아다니는 생물). COMMON.md에서 걸어 다니는 캐릭터와 돌아다니는 몬스터는 8방향 기준이 정해질 때까지 만들지 않는다. 이 키트는 지금 종류마다 그림 한 장을 쓰므로, 기준이 정해지면 한 장으로 둘지 방향 그림을 만들지 함께 정한다.

## 결과 파일

- `assets/art/rule_rewriting/jobs/mp01-rr-objects-v01/output/rr_<kind>/rr_<kind>.png`(+ 빛나는 것만 `_emit.png`, `.json`)
- `preview/`: 묶음별 모아 보기 시트, 보드 칸 색 위 확인 시트

## 진행 체크리스트

- [x] 자료 읽기, 목록, 규격
- [x] 도구·팔레트 복사, `rr_*` 재질 추가
- [ ] 묶음 A
- [ ] 묶음 B
- [ ] 묶음 C
- [ ] 묶음 D
- [ ] 모아 보기 시트, QA.md, inputs.json
