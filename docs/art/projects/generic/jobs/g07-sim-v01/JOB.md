# g07-sim-v01 — 시뮬·물류·채굴 오브젝트 (60도 탑다운)

세션 g07. 철도·항구 물류, 우편 분류, 시각적 인크리멘털(채굴·쌓기) 키트의 시뮬 오브젝트. 결과는 전부 candidate이고 승인은 사용자만 한다.
목록과 근거 키트: `docs\art\projects\generic\catalog\g07_future_kits.md`

## 형식
- 60도 탑다운, 투명 PNG, `style: prop`, 크기는 g04·g07-devices와 같다(180 / 156 / 105 px/m).
- 타일 192 칸(`obj_conveyor` 등): 192×192 칸마다 이어 깐다. 칸 경계를 넘는 것은 벨트·레일뿐이고, 이음새에 윤곽선이 생기지 않게 전체 윤곽선(silhouette)을 껐다. 피벗 = 칸 아래 가운데.
- 움직임은 프레임: 컨베이어 `x_0,x_1,x_2`(가로), `y_0,y_1,y_2`(세로) — 칸막이가 32 px 간격의 1/3씩 움직인다. 0-1-2 순서로 틀면 +x / +y 방향.
- 상태는 프레임, 그림자 `_shadow.png`, 빛 `_emit.png`.

## 도구·팔레트
`g07-controls-v01\JOB.md`와 같다(같은 tool 복사본 + `gen_sim.py`, 같은 `palette_g07.json`). `gen_sim.py`의 `jag_line`은 짧은 막대를 이어 금·광맥을 그린다(원래 아이콘 모양이 보이지 않게).

## 작성자 설계
- obj_conveyor 가로: 벨트 깊이 0.8 m, 높이 0.45 m, 앞면에 롤러 캡(32 px 간격)과 노란 경고 줄무늬. 세로: 폭 0.9 m 띠, 끝 마개는 C 단계 obj_conveyor_end.
- obj_ore_rock: 지름 약 1.2 m 바위, 광맥(황토색)·수정 조각(약한 _emit). whole → crack1 → crack2(부스러기) → broken(낮은 잔해+광석).
- 이음 확인: `preview\obj_conveyor_tiling_check.png`(가로 4칸 + 세로 2칸).

## 진행
A (2)
- [x] obj_conveyor(x_0~2, y_0~2), obj_ore_rock(whole/crack1/crack2/broken)
B (2)
- [ ] obj_container, obj_shard_pile
C (6)
- [ ] obj_pallet_stack, obj_freight_wagon, obj_rail_tile, obj_mine_cart, obj_conveyor_end, obj_crane_hook
