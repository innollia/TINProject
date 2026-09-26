---

## 10. Authored content 형식

모든 경로는 `modules/sideview_ecosystem/content/` 기준. **이 절에 없는 키는 로더가 `key_unknown`으로 거부한다.** 모든 JSON은 `JSON.parse_string`으로 읽고, 숫자는 전부 float로 들어오므로 정수 필드는 `value == floor(value)`를 검사한 뒤 `int()`로 바꾼다.

### 10.1 파일

| 파일 | 담는 것 |
|---|---|
| `schema_version.json` | `{"schema": 1, "content_seed": 418324771}`. 새 게임의 `world_seed = content_seed` |
| `regions/index.json` | 영역 id 배열(순서 = `region_index`), 시작 룸·쉼터·rung |
| `regions/reg_*.json` | 영역 1개 = 룸 N개 + link 목록 |
| `archetypes/index.json` | 아키타입 id 배열 |
| `archetypes/arc_*.json` | 아키타입 1개(§7.2 수치 + lineage) |

### 10.2 스키마 — 닫힌 키 표

**`regions/index.json`**

| 키 | 타입 | 검증 |
|---|---|---|
| `schema` | int | `== 1` |
| `regions` | Array[String] | 1..10개, 중복 0, 각 파일 `regions/<id>.json` 존재 |
| `start_room` | String | 어떤 영역의 룸 id |
| `start_shelter` | String | `start_room` 안의 쉼터 id |
| `start_rung` | String | 이 Kit의 rung 3개 중 하나 |

**영역 파일 `regions/<id>.json`**

| 키 | 타입 | 검증 |
|---|---|---|
| `schema` | int | `== 1` |
| `id` | String | 파일 이름과 같다 |
| `display_name` | String | 비어 있지 않음. **어디에도 그리지 않는다**(§W.2-1) |
| `rooms` | Array[룸] | 1..99개 |
| `links` | Array[link] | 0개 이상 |

**룸**

| 키 | 타입 | 기본값 | 검증 |
|---|---|---|---|
| `id` | String | — | 전 콘텐츠에서 유일. `[a-z0-9_]+` |
| `band` | String | — | 사다리의 rung 이름 6개 중 하나. **이 Kit은 `speck` `hand` `doll`만 쓴다**(나머지는 `band_not_used`) |
| `target_body_px` | number | — | `[24.0, 420.0]` |
| `place_id` | String | `""` | 비어 있거나 `place.` 접두사 |
| `tiles` | Array[String] | — | 행 수 12..200, 모든 행 길이 같음 16..240, 문자는 §10.3 legend만 |
| `exits` | Array[exit] | `[]` | |
| `passages` | Array[passage] | `[]` | |
| `triggers` | Array[trigger] | `[]` | |
| `shelters` | Array[shelter] | `[]` | |
| `dens` | Array[den] | `[]` | 0..9개 |
| `tethered` | Array[tethered] | `[]` | 0..10개 |

**exit** — 룸 가장자리의 출입구. 룸 전환은 몸 AABB 중심이 이 구간을 넘어 룸 밖으로 나갈 때 일어난다(§8.4).

| 키 | 타입 | 검증 |
|---|---|---|
| `id` | String | 룸 안에서 유일 |
| `side` | String | `left` `right` `top` `bottom` |
| `from` / `to` | int | 그 변을 따라가는 타일 인덱스 구간, `0 ≤ from ≤ to < 변 길이`. 그 구간의 가장자리 타일은 `.`이어야 한다(`exit_blocked`) |
| `to_room` / `to_exit` | String | 상대 룸의 exit. **상대도 이쪽을 가리켜야 한다**(`exit_unpaired`). 변은 반대(`left↔right`, `top↔bottom`) |

**link** — §4.9 그래프의 간선. 방향이 있다.

| 키 | 타입 | 검증 |
|---|---|---|
| `from` / `to` | String | 룸 id. `from`은 이 영역의 룸, `to`는 아무 영역. 둘 사이에 exit 쌍이 1개 이상(`link_without_exit`) |
| `via` | String | `""` 또는 passage id. 그 passage는 `from` 또는 `to` 룸에 있다(`via_unknown`). §4.7-1(`via_impassable`) |

**passage** — §4.6. 모든 passage는 rect(`cell` 좌상단 타일, `span` 타일 수)를 갖고, rect 안 타일은 전부 `.`이다(`passage_over_solid`). passage의 물리 형태는 §10.4.

| 키 | 타입 | 해당 kind | 검증 |
|---|---|---|---|
| `id` | String | 전부 | 전 콘텐츠에서 유일 |
| `kind` | String | 전부 | `GAP` `STEP` `DROP` `BREAK` `PRESS`. 그 외(`FLOOD` 포함) `passage_kind_unknown` |
| `cell` | [int, int] | 전부 | rect가 룸 안 |
| `span` | [int, int] | 전부 | 각 ≥ 1 |
| `width_class` | String | `GAP` | `SEAL` `HAIRLINE` `TIGHT` `FIT` `WIDE`. rect 폭 px ≥ `w_gap + 2 × TILE`(`gap_rect_too_narrow`) |
| `drift` | bool | `GAP` | 기본 `false` |
| `height_px` | number | `STEP` | `40` `200` `290` 중 하나. rect 높이 px ≥ `height_px` |
| `fall_px` | number | `DROP` | `1600` `2000` `2700` `4200` 중 하나. `|rect 높이 px − fall_px| ≤ TILE`(`drop_height_mismatch`), rect 바로 아래 행이 고체 |
| `hp` | int | `BREAK` | `1..4` |
| `mass_required` | number | `PRESS` | `0.10` `0.80` `12.00` 중 하나 |

kind에 해당하지 않는 키가 있으면 `key_unknown`이다(예: `GAP`에 `hp`).

**trigger** — §4.5. `kind`·`from_rung`·`to_rung`은 authored하지 않는다. `object`가 §4.5 표에서 정한다.

| 키 | 타입 | 검증 |
|---|---|---|
| `id` | String | 전 콘텐츠에서 유일 |
| `object` | String | `salt_bed` `collapse_floor` `salt_dust_bed` `narrow_cradle` |
| `cell` / `span` | [int, int] | rect가 룸 안. `salt_bed`는 rect 맨 아래 행이 전부 `s`, 그 밖 `s` 0개(`salt_outside_bed`). `collapse_floor`는 rect 맨 아래 행이 전부 `#` — 이 행이 소비되는 판이다 |

**shelter**: `{ "id": String(전 콘텐츠 유일), "cell": [int, int] }` — `cell`은 서는 칸, 그 바로 아래 칸이 고체.

**den**: `{ "id": String, "cell": [int, int], "lineage_of": String(아키타입 id), "stage": int(시작 스테이지, 0..lineage 길이−1) }`.

**tethered**: `{ "axis_id": String("fix." 접두사, 전 콘텐츠 유일), "archetype": String, "cell": [int, int], "rung": String }` — `rung`은 그 아키타입의 `variant_rungs` 중 하나이고 룸 band 이하(CV-06).

**아키타입 `archetypes/<id>.json`**: 키는 `schema`(1), `id`, `axis_name`(축 `creature.archetype`에 쓰는 이름, `arc_` 없는 것), `rung`, `variant_rungs`(1..2개, 인접), `density`, `hp`, `move_speed`, `chase_speed_mult`, `think_period`, `sense_radius_px`, `hearing_radius_px`, `fov_deg`, `reaction_latency`([min, max]), `aggression`, `courage`, `attack_range_ratio`, `attack_windup`, `attack_damage`, `body_parts`, `confined_only`, `graze_radius_px`(0 = 없음), `pack_bonus_count`, `lineage`(배열, 3..4개, 원소 `{"archetype": String 또는 "", "advance_chance": number}`, 마지막 `advance_chance == 0.0`). 값은 §7.2 표와 같다.

**예시 1 — 룸 (축약: `tiles` 12행)**

```json
{
  "id": "filter_bed_02", "band": "speck", "target_body_px": 96.0, "place_id": "",
  "tiles": [
    "################################",
    "#..............................#",
    "#..............................#",
    "#..............................#",
    "#..............................#",
    "#..............................#",
    "#......................#########",
    "#......................#########",
    "#..............ssssss..#########",
    "#......########################",
    "................................",
    "################################"
  ],
  "exits": [ { "id": "w", "side": "left", "from": 10, "to": 10, "to_room": "filter_bed_01", "to_exit": "e" } ],
  "passages": [ { "id": "step_fb_02_up", "kind": "STEP", "cell": [22, 1], "span": [2, 9], "height_px": 200 } ],
  "triggers": [ { "id": "salt_bed_fb_02", "object": "salt_bed", "cell": [15, 7], "span": [6, 2] } ],
  "shelters": [], "dens": [], "tethered": []
}
```

**예시 2 — link 3개**

```json
[
  { "from": "filter_bed_02", "to": "filter_bed_03", "via": "step_fb_02_up" },
  { "from": "filter_bed_03", "to": "filter_bed_02", "via": "" },
  { "from": "ash_terrace_04", "to": "ash_terrace_05", "via": "drop_at_04" }
]
```

**예시 3 — 아키타입**

```json
{
  "schema": 1, "id": "arc_skitter", "axis_name": "skitter", "rung": "speck", "variant_rungs": ["speck", "hand"],
  "density": 0.22, "hp": 1.0, "move_speed": 96.0, "chase_speed_mult": 1.0, "think_period": 0.16,
  "sense_radius_px": 260.0, "hearing_radius_px": 300.0, "fov_deg": 118.0, "reaction_latency": [0.05, 0.14],
  "aggression": 0.2, "courage": 0.85, "attack_range_ratio": 0.22, "attack_windup": 0.22, "attack_damage": 1.0,
  "body_parts": 8, "confined_only": false, "graze_radius_px": 0.0, "pack_bonus_count": 0,
  "lineage": [
    { "archetype": "arc_skitter", "advance_chance": 0.3 },
    { "archetype": "arc_skitter", "advance_chance": 0.3 },
    { "archetype": "arc_brood", "advance_chance": 0.2 },
    { "archetype": "", "advance_chance": 0.0 }
  ]
}
```

### 10.3 타일 legend

| 문자 | 정수 | 이름 | 재질 | 충돌 | 규칙 |
|---|---:|---|---|---|---|
| `.` | 0 | `EMPTY` | — | 없음 | |
| `#` | 1 | `SOLID` | `mat.slate` | 고체 | |
| `=` | 2 | `ONE_WAY` | `mat.plank` | 위에서만 | 하강 중이고 직전 서브스텝의 발이 타일 윗면 위였을 때만 막는다. `eco_curl` + `eco_jump`로 내려간다(§13.3) |
| `s` | 3 | `SALT` | `mat.salt` | 고체 | `salt_bed` rect 맨 아래 행에만(§10.2) |
| `d` | 4 | `DRIFT` | `mat.drift_powder` | 고체 | `press > 0.35`면 윗면 마찰 × `0.86` |
| `p` | 5 | `SOIL` | `mat.pressed_soil` | 없음 | 안에서 플레이어 속도 × `0.5`. 개체가 안에 1.4초 이상이면 사망(`buried`) |

`mat.*` 문자열은 코드에 **이 6개 표 밖으로 나오지 않는다**. "물"이라는 글자가 들어간 재질 0건.

### 10.4 passage의 물리 형태 (런타임 충돌체)

passage는 타일이 아니라 **rect 안의 AABB 충돌체**다. px 단위이며 룸 좌표계(`x = cell.x × 24`, `y = cell.y × 24`)다.

| kind | 충돌체 | 통과 방향 |
|---|---|---|
| `GAP` | rect 맨 위 한 타일 높이의 판. 가운데에 폭 `w_gap = 배수 × module_px`의 구멍. 판 = 구멍 왼쪽 AABB + 오른쪽 AABB 2개 | 위아래. 몸 폭 ≤ `w_gap`이면 구멍으로 지나간다. `w_gap < 1.42 × 몸 폭`이면 구멍 안에서 수평 속도 × `SQUEEZE_SPEED_MULT(0.45)` |
| `STEP` | rect 바닥에 붙은 높이 `height_px`, 폭 rect 폭의 블록 1개 | 위로 오르는 통로. 내려가기는 늘 된다 |
| `DROP` | 없음(빈 축). 착지면은 rect 아래 타일 | 아래로만 |
| `BREAK` | rect 전체 AABB 1개(벽). `broken_walls`에 있으면 없음 | 양쪽. `eco_use` 타격(§13.3)에 `break_power ≥ hp`면 1타에 사라진다. 아니면 변화 0 |
| `PRESS` | rect 맨 위 한 타일 높이의 판 1개 | 아래로만. 판 위 하중 합(§7.10) ≥ `mass_required`인 동안 판이 `SOLID`에서 빠진다(아래로 떨어진다). 하중이 빠지면 0.5초 뒤 복귀 |

### 10.5 로더 검증 목록

`EcoRegionLoader.load_all() -> Dictionary`는 `{ok, reason, detail, value: EcoContentIndex, errors: PackedStringArray}`를 돌려준다. **오류가 1개라도 있으면 `ok = false`이고 모듈은 룸을 시작하지 않는다.** 오류 문자열 형식은 `"<reason> <위치>"`(예: `"exit_unpaired filter_bed_02/w"`).

| reason | 조건 |
|---|---|
| `json_invalid` | 파싱 실패 |
| `schema_unsupported` | `schema`가 1이 아님 |
| `key_unknown` | §10.2 표에 없는 키 |
| `value_invalid` | 타입·범위 위반 |
| `id_duplicate` | 룸·passage·trigger·shelter·den·tethered id 중복 |
| `band_not_in_table` / `band_not_used` | band가 사다리에 없음 / 이 Kit이 안 쓰는 rung |
| `tile_char_unknown` / `tiles_ragged` | legend 밖 문자 / 행 길이 다름 |
| `exit_blocked` / `exit_unpaired` | §10.2 exit |
| `link_without_exit` / `via_unknown` / `via_impassable` | §10.2 link, §4.7-1 |
| `passage_kind_unknown` / `passage_over_solid` / `gap_rect_too_narrow` / `drop_height_mismatch` | §10.2 passage |
| `salt_outside_bed` | §10.2 trigger |
| `trigger_object_unknown` | §4.5 표 밖 |
| `creature_above_band` | den 첫 스테이지·tethered 개체 rung > 룸 band (CV-06) |
| `den_slots_exceeded` | 룸 den 9개 초과 |
| `lineage_last_stage_nonzero` | lineage 마지막 `advance_chance ≠ 0.0` |
| `variant_not_adjacent` | `variant_rungs` 인덱스 차 ≠ 1 (CV-02) |
| `start_invalid` | `start_room`·`start_shelter`·`start_rung` 불일치 |

### 10.6 사다리 로드

`EcoLadder.LADDER_PATH = "res://content/scale/ladder.json"`(W0 소유). 순서:

1. 그 파일이 있으면 읽어 `05` §2의 표대로 검증한다. 실패하면 **정직한 실패**(`ladder_invalid`) — 대체값으로 넘어가지 않는다.
2. 파일이 없으면 `EcoWorldstateBridge.store_rung_values()`(= `AxisBody.SCALE_RUNGS` 복사)와 `EcoLadder.FALLBACK_NAMES = ["speck", "hand", "doll", "common", "tall", "colossal"]`(`01` §1 순서)로 같은 표를 만든다. `edges[i] = snappedf(sqrt(v[i] × v[i+1]), 0.001)`, `band_min[0] = 0.0`, `band_max[5] = 99.0`. `source = "store_constant"`.
3. Kit 안에 사다리 사본 파일 0개(`06_TESTS_AND_GATES` T7-1).

### 10.7 영역 4개 · 룸 25개 · link 그래프 (정본)

**룸** (`band` / `target_body_px`):

| 영역 (index) | 룸 | band / target | 역할 |
|---|---|---|---|
| `reg_filter_bed` (0) | `filter_bed_00`~`05` (6) | `speck` / 96 | 시작 쉼터 `shelter_fb_00`(00). `salt_bed_fb_02`(02). hp 2 벽(04) |
| `reg_ash_terrace` (1) | `ash_terrace_00`~`02` (3) | `speck` / 96 | 00 = `place.ruined_garden`, `fix.gardener`. 01→02 `WIDE` 갭. 쉼터 `shelter_at_01` |
| | `ash_terrace_03`~`06` (4) | `hand` / 240 | 03→04 `FIT`. `collapse_floor_at_04`, 04→05 `DROP 2700`. 03→06 `DROP 2000`, `collapse_floor_at_06` |
| `reg_bone_shelf` (2) | `bone_shelf_00`~`06` (7) | `doll` / 384 | 00 = `place.tea_stair`, `fix.butler`. 00→01 `STEP 290`, 01↔02 hp 4 벽, 02↔03 `FIT`(`anchor` den), `salt_dust_bed_bs_04`, 04↔05 `TIGHT`, 05→06 `PRESS 0.80`, `collapse_floor_bs_06`, 06→`seed_vault_00` `DROP 1600`. 쉼터 `shelter_bs_01` |
| `reg_seed_vault` (3) | `seed_vault_00`~`04` (5) | `hand` / 240 | 00 = `place.mirror_march`, `fix.mirror`, `salt_dust_bed_sv_00`. `narrow_cradle_sv_01`(skitter den 3개 인접), 01↔02 `TIGHT`, 04→`filter_bed_01` `DROP 1600`. 쉼터 `shelter_sv_03` |

**link** (`→` 한 방향, `↔` 양방향 2개. 괄호 = `via`, 없으면 `""`):

```
fb_00 ↔ fb_01          fb_01 ↔ fb_02          fb_02 → fb_03 (step_fb_02_up)   fb_03 → fb_02
fb_03 ↔ fb_04          fb_04 ↔ fb_05 (wall_fb_04_a)                           fb_05 ↔ at_00
at_00 ↔ at_01          at_01 ↔ at_02 (gap_at_01_wide)                         at_02 ↔ at_03
at_03 ↔ at_04 (gap_at_03_fit)   at_04 → at_05 (drop_at_04)   at_03 → at_06 (drop_at_03)
at_05 ↔ bs_00          at_06 ↔ sv_00
bs_00 → bs_01 (step_bs_00_up)   bs_01 → bs_00          bs_01 ↔ bs_02 (wall_bs_01_a)
bs_02 ↔ bs_03 (gap_bs_02_fit)   bs_03 ↔ bs_04          bs_04 ↔ bs_05 (gap_bs_04_tight)
bs_05 → bs_06 (plate_bs_05)     bs_06 → sv_00 (drop_bs_06)
sv_00 ↔ sv_01          sv_01 ↔ sv_02 (gap_sv_01_tight)                        sv_02 ↔ sv_03
sv_03 ↔ sv_04          sv_04 → fb_01 (drop_sv_04)
```

(`fb_` = `filter_bed_`, `at_` = `ash_terrace_`, `bs_` = `bone_shelf_`, `sv_` = `seed_vault_`. JSON에는 전체 id를 쓴다.) 이 그래프가 §4.9 G1~G6을 만족한다는 것을 `test_eco_region_graph_fully_connected`가 매 실행 증명한다. 그래프를 바꾸면 이 표를 먼저 고친다.

---

## 11. 화면 (presentation) — 착수 조건부

### 11.0 착수 조건 (이 조건이 참이 되기 전에는 `presentation/`에 코드를 쓰지 않는다)

`core/procedural/README.md` 상태 표에서 아래가 전부 `done`이어야 한다. **2026-09-27 현재 전부 stub이다.**

| 필요한 것 | 쓰는 곳 |
|---|---|
| `ProceduralBodyPart.draw()` / `bounds()` | 플레이어·개체 실루엣 |
| `ProceduralCreatureBuilder.compose_canvas()` / `outline()` | 개체 텍스처 |
| `ProceduralSquishRig.step()` / `disturb()` / `draw()` | 착지 스쿼시·관절 |
| `ProceduralScaleFit.signature(q)` (W2 신규) | 5독자(§4.10-3) |

`ProceduralBackdropDynamics`·`ProceduralDeformField`·`ProceduralCanvas`·`ProceduralSdf`·`ProceduralPalette`는 이미 `done`이지만, 배경만 먼저 만들면 개체 없는 화면이 "완성처럼" 보이므로 **배경도 위 조건을 기다린다.**

### 11.1 노드 구성

`entry.tscn`: `Node2D` 루트(`module.gd`) → `WorldRoot`(Node2D, `world_root.gd`) → `BackdropRoot` + `RoomLayer` + `CreatureLayer` + `PlayerLayer`; `CameraRig`(Node2D → `Camera2D`); `OverlayHost`(Control, `mouse_filter = IGNORE`, 풀스크린 앵커) → `BubbleOverlay`, 3화면; `AudioSink`(Node). 3화면은 기본 `visible = false`. `normal` 상태에서 `OverlayHost`의 보이는 자식은 `BubbleOverlay`뿐이다.

### 11.2 5층 배경

§9.12 표의 5레이어. 각 레이어는 `ProceduralBackdropDynamics` 1개 + 앵커 18..34개. 앵커는 **룸 JSON의 타일에서** 뽑는다: `FOREGROUND` = 룸 가장자리 고체 타일 덩어리 윤곽점, `NEAR`/`MID` = 고체 타일 무게중심을 8칸 격자로 묶은 점, `FAR`/`SKY` = 룸 폭을 18등분한 점. 모양은 판·막·층·기둥(`13_REFERENCE_EXCLUSIONS` §1-R6): `ProceduralSdf`의 사각·캡슐만. 색은 §9.9 역할만.

### 11.3 실루엣 판독 기준 (F3의 수치)

| 대상 | 파츠 수 | 판독 기준 (실제 화면에서 사용자가 판정) |
|---|---:|---|
| 플레이어 | 18 (+ 사실 delta, §9.13) | 720p에서 `speck` 몸(`h 96`, 줌 3.4375 → 화면 330px)의 머리·몸통·팔다리가 구분된다 |
| 개체 | `body_parts` 8..12 | 5 아키타입이 색 없이(명도만) 서로 구분된다 |
| 배경 | — | 플레이어보다 밝은 배경 요소 0개(§9.9 초점 규칙) |

이 표의 판정은 W2 구현 뒤 실제 캡처로 한다. 판정 전에는 "실루엣이 충분하다"고 쓰지 않는다.

### 11.4 전이 연출

§4.5 B-06: 0.9초 입력 중단, 지형 1.9초 조임(`ProceduralDeformField.excite(1.0, 3 × module_px)`), 카메라 스프링 `(70.0, 0.75)`, 배경 `pulse(0.55)`. 몸 크기는 한 프레임에 바뀐다.

### 11.5 초점 규칙

화면에서 가장 밝은 것은 플레이어(`key_light`)다. 개체는 `body`/`rim`. `danger`는 `BREAK` 벽 1종에만, 휘도 `key_light × 0.82` 이하. 개체가 여러 마리면 플레이어에서 가장 가까운 1마리만 `rim`을 켠다.

### 11.6 세 화면

공통: 풀스크린 `Control`, 배경 `shade` 역할 색으로 채운 절차 캔버스 1장, 가운데 일러스트(`screen_illustration.gd`, 캔버스 높이의 60%), 우하단 `HBoxContainer`(오른쪽·아래 여백 48px)에 `Button`. 버튼 라벨은 §W.2 값만. 첫 버튼에 `grab_focus()`. `ui_left`/`ui_right`로 이동, `ui_accept`로 누른다. 본문 텍스트 0자.

#### 11.6.1 로딩

`enter` 직후 콘텐츠 로드·사다리 로드·룸 구성 동안. 일러스트 = 현재 rung 몸 실루엣이 `ProceduralDeformField`로 느리게 부푸는 것(주기 2.4초). 진행 바 0. 준비가 끝나면 버튼 `계속`(T2) 1개가 나타난다. 누르면 `normal`.

#### 11.6.2 잠

`shelter` 위에서 `eco_curl`을 1.2초 누르면 연다(§14.4). 일러스트 = 웅크린 몸. 왼쪽 1/3에 방문 그래프(`passage_graph_view.gd`): `rooms_visited`의 룸을 원(반지름 6px), link를 1px 선으로. 미방문 룸은 1px 점. **이름·숫자·순서 0.** 버튼 `일어나다`(T5), `나가다`(T6).

#### 11.6.3 사망

`integrity ≤ 0`이 된 프레임 + 0.8초. 일러스트 = 마지막 자세 실루엣이 식어가는 것(명도 1.0 → 0.4, 1.5초). 사망 원인 표시 0. 버튼 `다시`(T3), `나가다`(T4).

---

## 12. 오디오 이벤트 14개 — `audio_events.tres`

`id_prefix = &"eco"`. 버스는 `SFX`·`Music`만(`Voice` 0개, §W.5-2 규칙 D). 파일은 W3가 `modules/sideview_ecosystem/audio/<id>.wav`로 넣는다. 파일이 없으면 등록은 조용히 실패하고 게임은 무음으로 돈다. `pitch_scale = q`(§4.10-3 5번 독자)는 `step`·`land`·`strike` 3종에만.

| # | id | 버스 | 재생 조건 | `max_polyphony` | `volume_db` |
|---:|---|---|---|---:|---:|
| 1 | `eco_step` | SFX | 지상 이동 중 `run_speed × 0.35`px마다 | 2 | -12 |
| 2 | `eco_land` | SFX | 착지(§8.3 7.5) | 2 | -8 |
| 3 | `eco_jump` | SFX | 점프 시작 | 1 | -10 |
| 4 | `eco_squeeze` | SFX | 눌림 구간 진입(§10.4 GAP) | 1 | -9 |
| 5 | `eco_strike` | SFX | `eco_use` 타격 | 2 | -8 |
| 6 | `eco_shatter` | SFX | `BREAK` 벽 파괴 | 2 | -4 |
| 7 | `eco_plate` | SFX | `PRESS` 판이 빠짐 | 1 | -6 |
| 8 | `eco_rung_cut` | SFX | 전이 완료(§11.4) | 1 | -3 |
| 9 | `eco_settle_load` | Music | `press`가 0.45를 넘는 프레임(§9.10) | 1 | -14 |
| 10 | `eco_creature_alert` | SFX | 개체 `ALERT` 진입 | 3 | -10 |
| 11 | `eco_creature_strike` | SFX | 개체 `STRIKE` 명중 | 2 | -6 |
| 12 | `eco_creature_death` | SFX | 개체 `DEAD` 진입 | 2 | -8 |
| 13 | `eco_death` | SFX | 플레이어 사망 | 1 | -2 |
| 14 | `eco_sleep` | Music | 잠 화면 열림 | 1 | -12 |

물·비·수면 소리 이벤트 0건.

---

## 13. 입력

### 13.1 action 5개와 기본 바인딩

`module_manifest.tres`의 `input_actions`는 정확히 이 5개다. `module.gd`는 `enter`에서 `InputMap.has_action` / `action_has_event` 가드를 두고 **런타임에** 등록한다(`input_router.gd`의 관례, `project.godot` 수정 0). 셸이 전역으로 먼저 가져가는 키 **Esc(일시정지) · J(저널) · P · Enter는 쓰지 않는다**(`app/app_root.gd`의 `_input`, `input_router.gd`).

| action | 물리 키 | 쓰임 |
|---|---|---|
| `eco_left` | `A`, `←` | 왼쪽 |
| `eco_right` | `D`, `→` | 오른쪽 |
| `eco_jump` | `Space`, `W`, `↑` | 점프(누른 시간만큼 높이, §9.2 `JUMP_CUT_MULT`) |
| `eco_curl` | `S`, `↓` | 웅크리기. `eco_jump`와 함께 = 한 방향 판 내려가기. 쉼터에서 1.2초 = 잠 |
| `eco_use` | `E`, `K` | 붙잡기/놓기(§7.11) · 벽 타격(§10.4 BREAK) — 앞에 개체가 있으면 붙잡기가 먼저 |

### 13.2 Input Bubble

`first_entry`와 같은 API 이름·4상태(`intact/popped/rising/restoring`), `GRID_COLUMNS = 3`. 셀: `eco_left (0,0)` `eco_jump (1,0)` `eco_right (2,0)` `eco_curl (1,1)` `eco_use (2,1)`. 글리프는 현재 바인딩의 첫 물리 키(§W.3). 이 Kit에 들어올 때 5개가 아래에서 올라오고, 처음 누른 키의 방울이 터진다. 5개가 모두 터지면 오버레이는 보이지 않는다.

### 13.3 입력 → 의도 (`read_input`, §8.2 2단계)

| 의도 | 값 |
|---|---|
| `move_axis` | `context.get_axis(&"eco_left", &"eco_right")` (−1, 0, 1) |
| `jump_held` / `jump_pressed` | 이번 프레임 눌림 / 직전 프레임 안 눌림 → 눌림 |
| `curl_held` | `eco_curl` 눌림 |
| `use_pressed` | `eco_use` 직전 안 눌림 → 눌림 |
| `any_input` | 5개 중 하나라도 눌림 (§4.5 전이 3·4의 무입력 판정) |

`domain/`·`systems/`는 물리 키를 모른다. 테스트는 의도 사전을 직접 넣는다.

