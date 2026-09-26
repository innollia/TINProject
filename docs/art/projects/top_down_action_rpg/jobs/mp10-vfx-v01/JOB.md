# mp10-vfx-v01 — 전투 효과 · 효과 키 · 상태 표시

상태: **준비 끝, 기준 확정 대기** (2026-09-27). `COMMON.md` 맨 위의 '준비만 할 것' 줄 때문에 자료 읽기, 만들 목록, brief, 계획까지만 했다. 레시피 작성, 도구 복사, build는 하지 않았다. 결과는 전부 candidate가 되고, 승인은 사용자만 한다.

준비 중에 되돌린 것: 중단되기 전 턴에서 `tool/`과 `palette_h0.json`을 먼저 복사해 두었다. 준비 단계에서는 도구를 복사하지 않는다는 규칙이 있어서 둘 다 휴지통으로 보냈다(원본과 같은 사본이었고, 바꾼 것은 workers 제한 한 곳뿐). 시작할 때 `COMMON.md`가 정한 원본에서 다시 복사한다. `input/preview_h0_1280x720.png` 사본은 입력 자료라 그대로 두었다(원본과 해시 같음).

| 필드 | 값 |
|---|---|
| 목적 | state_variant: 전투 결과, 예고, 상태를 보여 주는 효과 그림. 14 §3 목록에 효과 항목이 없어서 가장 가까운 것을 골랐다. 아이콘 조합 코드 그림이다(09 §11.3) |
| 근거 결정 | 사용자 결정 2026-09-27: 아이콘 조합 양산(`COMMON.md`, 14 §1). 세션 10 담당은 전투 효과와 상태 표시다(세션 시작 지시 1~3, 6) |
| 소유권 | 세션 10. 쓰기 범위는 `assets/art/top_down_action_rpg/jobs/mp10-vfx-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp10-vfx-v01/` 두 곳뿐이다. 게임 코드·씬·content·규칙 문서는 고치지 않고, 게임에 연결하지 않고, 커밋하지 않는다 |
| 자산 identity | `art_effect_*`는 09 §12.10의 art key다(조회 키이지 파일 ID가 아님). `st_*`는 content의 상태 ID다. `vfx_*`는 이 작업의 설계 ID이고, 09 §12.4 결과 종류와 게임 코드의 feedback kind·presentation event에 맞췄다 |
| 입력 계약 버전 | `inputs.json` (SHA-256, 2026-09-27 준비 시점) |
| 카메라 | 전투 효과는 전투 화면의 고정 카메라를 쓴다(방향 없음, 09 §12.3과 같음). 바닥에 닿는 효과(사건 흔적, 공허 가르기의 바닥선, 필드 상태)는 60° 정사영을 쓴다(바닥 세로 ×0.866, 높이 ×0.5) |
| 입력 이미지 | `input/preview_h0_1280x720.png`: 시험 작업 미리보기의 사본. 겹쳐 보기 바탕으로만 쓰고 화풍 권위로 쓰지 않는다. 모양 재료는 `addons/at-icons/node2d` SVG(MIT)이고, 실제로 쓴 아이콘과 해시는 만들 때 PNG 옆 `.json`에 적는다 |
| 필요한 결과 | 아래 '만들 목록' |
| 내용 고정 | 결과 종류마다 모양이 달라야 한다(09 §4.5: 효과 하나가 모든 결과를 대신하지 않는다). 색만으로 구분하지 않는다. 뜻은 게임 코드가 지금 그리는 모양(`top_down_vector_layer.gd`의 `_draw_feedback_mark`, `_draw_charge_tell`, `_draw_target_bracket`)과 같은 순서를 따른다 |
| 금지 | 글자·숫자, 데미지 숫자를 그림에 굽기, 화면 전체 번쩍임, 화면을 계속 물들이기, 무작위 색종이, 명령 목록·게이지·플레이어 띠를 가리는 크기, 원작(BLACK SOULS, Alice)의 효과·타이밍 복제, 원래 아이콘 모양이 그대로 읽히는 조각, 반려된 후보 참조, 다른 mp 작업 폴더 참조 |
| 수정 범위 | 이 job 폴더 안의 새 파일만 |
| 승인 상태 | 입력은 원본(읽기 전용)이다. approved 기준(Gold Standard)은 없다. 결과는 candidate가 될 예정이다 |
| 검수 항목 | 아래 'QA 계획'. 구도, 화풍, 기술, 상태를 pass/partial/fail/not_run으로 `QA.md`에 적는다 |
| 중단 이유 | `COMMON.md`의 '준비만' 줄: 톤앤매너(분위기 기준)와 스프라이트 기준을 다시 정하는 중이다. 사용자가 '이어서 해'라고 하면 `COMMON.md`를 다시 읽고 시작한다 |

## 공통 규격 (작성자 설계)

- 칸 크기: 1칸은 192×192다(`COMMON.md` 크기 표의 '효과 한 칸'). 적 전체를 감싸는 효과는 2칸 크기 384×384를 쓴다. 사람 크기 적의 캔버스 높이 384와 같아서 적 그림과 맞추기 쉽다. 게임 코드의 적 몸(반지름 58 논리 px, body_scale 1.0)과 예고 고리(반지름 ×1.36 = 원본 지름 316 px)가 384 칸의 여백 안에 들어간다. 더 큰 적에는 게임이 배율을 조정하거나, 모서리만 그린 효과는 9분할로 늘린다.
- 가장자리 여백: 원본 32 px(논리 16 px). 09 §12.4의 '32 logical px'(원본 64 px)를 192 칸에 적용하면 그림 자리가 64 px만 남는다. 그래서 사용자 크기 결정을 우선했다.
- 피벗: 효과 중심 피벗이다. 맞은 자리 효과는 칸 가운데(192 칸 (96,96), 384 칸 (192,192))이고, 이 점이 게임의 feedback 위치나 적 중심(`_draw_actor`의 point)에 온다. 바닥 효과는 바닥 접점을 피벗으로 한다(항목별로 적음).
- 프레임: 움직이는 효과는 3~5칸이다. 시트 한 줄이 5칸이라 한 상태가 한 줄에 들어간다. 반복 효과는 마지막 칸이 첫 칸으로 이어지게 만든다. 모션 줄이기용으로 칸 하나를 `static_frame`으로 지정한다.
- 합성: 전부 normal alpha다(잉크 윤곽이 있는 그림이라 add가 필요 없음). 매니페스트에 `"blend": "normal"`을 적는다.
- 스타일: 192·384 효과 칸과 128 토큰은 모두 palette_h0의 `sprite` 스타일을 쓴다. 캐릭터·적 위에 얹히므로 선 두께를 캐릭터와 같게 한다. 붓자국 설정은 시험 작업 그대로 쓴다(`COMMON.md`).
- 읽힘: 짙은 자주 윤곽과 밝은 속을 같이 쓴다. 검은 전투 판(`#0d1219`)과 밝은 H0 바닥(`#b3a8b7`) 두 바탕 모두에서 읽혀야 한다.
- 파일: `output/<ID>/<상태>_<n>.png`와 `.json`을 둔다. 한 줄 시트는 `output/sheets/<ID>[__<상태>].png`이고, 라벨 없이 칸 크기·피벗·순서를 `.json`에 적는다.

## 만들 목록

### A. 전투 결과 효과 (09 §12.4, §4.5)

| ID | 게임 상태 (근거) | 칸 | 프레임 | 모양 (작성자 설계) | 아이콘 후보 |
|---|---|---|---|---|---|
| `vfx_hit` | 맞음. feedback `hit` | 192 | 5: 번쩍 → 조각 튐 → 사라짐 | 가운데 종이빛 번쩍과 바깥으로 튀는 짧은 잉크 쐐기 4~6개 | star, stars, lightning_bolt, razor_blade (잘게 잘라서) |
| `vfx_hit_critical` | 크게 맞음. feedback `critical` (12.4 QA에 있음) | 192 | 5 | hit보다 크게, 위로 솟는 이중 꺾쇠와 조각 | 위 + triangle |
| `vfx_miss` | 빗나감. feedback `miss` | 192 | 4 | 바깥으로 벌어지는 흐린 호 두 개가 스쳐 지나감. 번쩍 없음, 흐린 색 | wind, wave, signal_wave |
| `vfx_guard` | 막기. feedback `guard`, event `stance_guard` | 192 | 4 | 위아래 두 호가 닫히고, 맞닿는 곳에 작은 불꽃 | shield (반쪽씩), ring |
| `vfx_guard_broken` | 막기 깨짐. event `guard_broken` | 192 | 4 | guard의 호가 금 가며 끊겨 흩어짐 | shield, heart_broken (금 모양만) |
| `vfx_dodge` | 피하기. feedback `dodge`, event `stance_dodge` | 192 | 4 | 가로 속도선 두 줄과 옆으로 밀리는 잔상 조각 | wind, arrow_double_horizontal (잘라서), duplicate |
| `vfx_break` | 무너뜨림 순간. feedback `break`, event `break_applied` | 384 | 5 | 점선 틀이 대각선으로 갈라지고 파편이 떨어짐. 마지막 칸이 `art_effect_break_window`로 이어짐 | glass_pane, arrow_zigzag, square_brackets |
| `vfx_status_apply` | 상태 걸림. feedback `status`, event `status_applied` | 192 | 4 | 작은 네모 도장 3개가 찍히며 모임. 색 두 벌: `_amber`, `_grey` (상태의 tint_key) | stamp, sticker, checkmark_in_square |
| `vfx_charge_gather` | 기술 모으기(모으는 동안 반복) | 192 | 4 반복 | 바깥에서 안으로 빨려 드는 작은 조각과 호 | orbit, arrows_clockwise, selection_circle |
| `vfx_resource_gain` | 자원 늘어남(HP·MP 회복) | 192 | 4 | 종이빛 작은 조각이 위로 떠오름 | droplet (뒤집어서), stars |
| `vfx_resource_spend` | 자원 줄어듦(소모·잃음) | 192 | 4 | 짙은 방울이 아래로 빠져나감. gain과는 방향과 모양으로 구분 | droplet, arrow_down (잘라서) |
| `vfx_target_confirm` | 대상 확정. feedback `queued`, 09 §4.4 confirm | 384 | 4: 모서리 꺾쇠가 안으로 조여 붙음 | 네 모서리 꺾쇠와 가운데 작은 네모(코드 `_draw_target_bracket`과 같은 구성). 모서리에만 그려서 9분할(여백 96)로 늘릴 수 있음 | square_brackets, target, bullseye |

### B. 효과 키 (09 §12.10)

| ID | 게임 상태 (근거) | 칸 | 프레임 | 모양 (작성자 설계) | 아이콘 후보 |
|---|---|---|---|---|---|
| `art_effect_charge_tell` | 적 기술 예고. `combat_state.gd` charge stage `telegraph`·`reaction`·`strike`, event `charge_stage_*`·`charge_strike`·`charge_cancelled` | 384 | 상태마다 한 줄: `telegraph` 4(반원이 차오름), `reaction` 4(닫힌 고리가 두꺼워지며 맥박), `strike` 3(위쪽 쐐기 번쩍), `cancelled` 3(고리가 끊겨 흩어짐) | 게임 코드의 반원 → 고리 → 삼각 순서를 그대로 따름. 삼각은 칸 안에 들어오게 적 위 1.2배 높이에 둠 | ring, orbit, triangle, bullseye |
| `art_effect_break_window` | 무너진 상태가 이어지는 동안(stance `broken`) | 384 | 4 반복 | 금 간 점선 틀의 틈이 천천히 벌어졌다 닫히는 맥박 | glass_pane, window, square_brackets |
| `art_effect_document_corruption` | 문서 깨짐. 09 §7.3, `top_down_row.gd`의 `CORRUPTION_MODES` | 아래 | 상태마다 3(나타남). 마지막 칸이 정지 그림 | `recolor`: 붉은 띠와 가는 줄, 384×64, 양끝 32 고정 3분할. `replace_token`: 글자 자리를 덮는 네모 조각, 64×64. `shatter_line`: 꺾여 끊긴 밑줄, 384×64. `drop_glyph`: 글자가 빠진 틈 두 줄, 64×64. 높이 64는 문서 글줄 32 논리 px의 2배다. 붉은색은 게임 EXTREME `#b34c3c`만 쓰고, 붉은 띠에는 언제나 줄 모양 변화를 같이 둔다(붉은색만으로 알리지 않음). 글자 없음. 모아 보기 시트에서는 192 칸 가운데에 둔다 | pen_nib, underline, razor_blade, brush |
| `art_effect_portal_void_cut` | 가위로 공허를 자르는 문(12_MAGIC_THEORY §3.3). 필드 | 384 | 5: 가는 선 → 벌어짐 → 유지 2칸(반복). 닫힘은 거꾸로 재생 | 세로로 긴 좁은 틈. 가장자리는 종이를 자른 듯 너덜하고 안은 공허색. 걸어 들어가는 문처럼 보이지 않게 폭을 좁게 한다(12_MAGIC_THEORY: 없는 통로를 암시하지 않음). 피벗은 바닥 접점 (192,352) | scissors (날만 잘라서), razor_blade, black_hole |
| `art_effect_aftermath_trace` | 사건 뒤 바닥 흔적(09 §8.2, §12.8). 바닥층, 분류는 '상황 이해' | 192, 긴 끌림은 384×192 | 3(나타남) + 정지 1 | 60° 바닥에 눌린 자국, 끌린 자국, 흩어진 찌꺼기. 피 대신 짙은 자주 얼룩(상시 고어 금지). 피벗은 흔적 가운데 | droplet, brush, paintbrush, wind |

### C. 상태 표시 (content/statuses 6개)

같은 상태를 세 가지 크기로 만든다. 선 두께가 스타일 값이라서 같은 레시피를 `scale_all`로 키워도 선 두께가 유지된다.

- 몸 둘레 반복 효과: 384 칸, 4칸 반복. 전투 화면의 적에게 쓴다. 겹치는 상태는 `stack1`~`stack3`을 한 줄씩 만든다.
- 띠 토큰: 128×128. `presentation.icon_key` 자리이고 플레이어 전투 띠에 쓴다. 글자·숫자 없이 겹 수는 작은 점 1~3개로 보여 준다. 모음 시트는 한 줄 16칸(아이콘 규칙과 같음)이다.
- 필드용 192 칸 반복 효과: 지속 방식이 `region`이라 필드 플레이어에게도 보일 수 있다. 시간이 남으면 만든다.

| ID | 뜻 (content JSON) | 색 (tint_key) | 위치 | 모양 (작성자 설계, 근거 12_MAGIC_THEORY) | 아이콘 후보 |
|---|---|---|---|---|---|
| `st_concentration_load` | 집중 부하. 최대 3겹, 마법 막음, 기술 모으기 확정 막음 | kiln_amber | 머리 위 | 짓누르는 호박색 고리(추 조각). 겹마다 하나씩 늘고 천천히 내려앉았다 올라옴 | weight, orbit, anchor, hourglass |
| `st_overflowed` | 넘침. 마법 막음(§8 농도 넘침: 저절로 새어 나옴) | kiln_amber | 몸 가장자리, 위로 | 몸 가장자리 여러 곳에서 호박색 김과 방울이 새어 나와 위로 넘침 | cup (가장자리만), droplet, fire (잘라서), wave |
| `st_medium_residue` | 매질 잔여. 최대 3겹, 민첩 −1, 잘못 접힘을 풀어 줌 | kiln_amber | 발치, 다리 | 달라붙은 섬유 조각과 끈적한 찌꺼기 덩어리. 겹마다 한 덩이씩 늚 | droplet, cloud, sewing_needle (실만), brush |
| `st_misfolded` | 잘못 접힘. 한 겹(§3.2 접기 실패가 몸에 남음) | record_grey | 몸 둘레 | 엉뚱한 각도로 접힌 종이 면(삼각 조각) 3~4개가 떠서 흔들림. 접힌 선이 보임 | paper_airplane (면만 잘라서), file (접힌 귀퉁이), note_double |
| `st_contract_bound` | 계약 묶임. 한 겹, 민첩 −1, 기술 모으기 확정 막음 | record_grey | 허리 | 몸을 감는 꿰맨 띠와 끈, 매듭 하나. 띠가 조였다 풀림 | knot, link, sewing_needle, paperclip |
| `st_recorded` | 기록됨. 최대 3겹, 민첩 −1 | record_grey | 몸 옆 | 옆에 떠 있는 장부 줄(가로 괘선)과 체크 표시. 겹마다 한 줄씩 늚. 글자 없음 | notepad, underline, list_checkboxes, checkmark |

같은 색을 쓰는 상태끼리도 위치(머리 위, 가장자리, 발치 / 둘레, 허리, 옆)와 모양으로 구분된다. QA에서 흑백으로 바꿔서 확인한다.

### D. 모아 보기와 미리보기 (세션 시작 지시 6)

- 한 줄 시트: 효과·상태마다 `output/sheets/…png`, 라벨 없이 한 줄 5칸.
- 전체 모음 시트: `output/sheets/vfx_all_192.png`(192 칸 효과, 한 줄에 효과 하나), `vfx_all_384.png`(384 칸 효과), `status_tokens_128.png`(토큰, 한 줄 16칸).
- 검수 시트(라벨 있음, review_sheet.py): 검은 바탕과 H0 바닥 바탕으로 한 장씩. `preview/sheet_vfx_192_dark.png`, `…_floor.png`, `sheet_vfx_384_…`, `sheet_status_…`.
- 겹쳐 보기: `preview/preview_h0_vfx_1280x720.png`. `input/preview_h0_1280x720.png` 위에 다음을 얹는다(논리 px 기준). 개(1000,472) 몸에 `vfx_hit` 3칸째와 `vfx_status_apply`, 플레이어(640,418) 몸에 필드용 `st_concentration_load`와 `vfx_resource_gain`, 문(630,165) 오른쪽 바닥에 `art_effect_portal_void_cut` 유지 칸, 카운터 앞 바닥에 `art_effect_aftermath_trace`.
- 추가 미리보기(작성자 설계): `preview/preview_combat_mock_1280x720.png`. 09 §4.1 좌표대로 게임 색 평면 판(명령 목록, 적 무대, 게이지 두 줄, 플레이어 띠)을 깐다. 적 자리(760,290)에는 시험 작업의 개 그림(input 사본)을 두고 `art_effect_charge_tell`, `art_effect_break_window`, `vfx_target_confirm`, 상태 384를 올린다. 명령 목록(x ≤ 248), 게이지(y 464~494), 플레이어 띠(y ≥ 576)를 가리지 않는지 본다. 미리보기 전용이다.

## 색 (`recipes/palette_mp10.json` 계획, 작성자 설계)

톤앤매너가 확정되면 이 값을 새 기준에 맞춰 다시 정한다.

- H0에서 그대로 쓰는 색: ink `#26152b`(윤곽선), shade_tint `#4b3352`, shadow_contact `#3a2342`, paper `#d8ceb7`, ember_glow `#e2a45c`, well_void `#1c1223`(공허), grime `#6d5f74`.
- 새 색: kiln_amber (기본 `#c68a45`, 그림자 `#8b5a2e`, 밝은 면 `#edc27e`), record_grey (기본 `#b8b1a2`, 그림자 `#7d776b`, 밝은 면 `#dfd9ca`, 게임 condition 게이지 `#bdb6a4` 근처), flash `#f3ecdc`(번쩍 가운데), mute `#8f8794`(빗나감), extreme_red `#b34c3c`(게임 EXTREME과 같음, 문서 깨짐 전용).
- H0에서 바꾼 점: 상태 tint_key 두 개(kiln_amber, record_grey)가 content에 이름만 있고 색 값이 없어서 새로 정했다. 윤곽선, 그림자, 명암 방식은 그대로다.

## 도구에 추가할 기능 (계획, 시작할 때 자기 복사본에만)

1. `iconkit/icons.py`: 아이콘 변환 병렬 개수를 2로 제한한다(`COMMON.md`).
2. 프레임별 투명도: frame에 `"opacity": {"<태그>": 0.4}`를 받는다. 지금 도구의 frame은 move, hide, show, materials만 된다. 효과가 나타나고 사라지는 칸에 필요하다.
3. 번쩍임 알파: 투명 캔버스에서 `glow`(lighten)가 알파에 들어가는지 먼저 시험한다. 안 들어가면 glow를 알파까지 넣는 옵션을 추가한다.
4. `pack_sheet.py`(새 파일): 프레임 PNG를 라벨 없는 한 줄 5칸(토큰은 16칸) 시트로 묶는다. 칸 크기, 피벗, 순서, blend, loop, static_frame을 `.json`에 적는다.
5. `compose_preview.py`: 바탕을 2배로 키우는 `background_scale`, 항목별 `opacity`, 평면 판을 까는 `plates`를 추가한다. 겹쳐 보기와 전투 화면 흉내에 필요하다.
6. `build.py`: 매니페스트에 레시피의 `blend`, `cell`, `loop`, `static_frame`을 옮겨 적는다.

## QA 계획 (`QA.md`에 기록할 것)

- 하드 게이트(자동): 크기, 네 귀퉁이 알파 0, 가장자리 32 px 안쪽이 비었는지(잘림 없음), 피벗 기록, 글자 없음, 아이콘 SHA-256 기록.
- 눈으로 확인(read 도구 Image 모드): 결과 종류끼리 모양이 헷갈리지 않는지(맞음, 크게 맞음, 막기, 피하기, 빗나감), 두 바탕에서 읽히는지, 원래 아이콘 모양이 보이지 않는지, 3~5칸 흐름이 자연스러운지, 전투 흉내 화면에서 명령 목록·게이지·플레이어 띠를 가리지 않는지, 상태 6개가 흑백에서도 구분되는지.
- 실행 안 함(not_run): 실제 게임 3해상도 검수(게임 연결 금지 범위), 모션 줄이기 설정의 실제 동작(정지 칸 지정만 함).

## 진행 체크리스트

- [x] 자료 읽기, 만들 목록, brief, 계획 (2026-09-27 준비)
- [x] `input/preview_h0_1280x720.png` 사본 (원본과 해시 같음)
- [ ] `COMMON.md` 다시 읽고 바뀐 기준 반영: 톤앤매너, 팔레트, 도구 원본 위치
- [ ] 도구와 palette_h0 복사, workers 2 제한, 위 도구 기능 추가, JOB.md에 바꾼 점 기록
- [ ] `palette_mp10.json`
- [ ] A 전투 결과 12종 → 검수 시트
- [ ] B 효과 키 5종 → 검수 시트
- [ ] C 상태 6종 (384 반복, 128 토큰, 필요하면 192 필드) → 검수 시트
- [ ] 한 줄 시트와 전체 모음 시트
- [ ] 겹쳐 보기 미리보기와 전투 흉내 미리보기
- [ ] `QA.md` 작성, `inputs.json` 해시 갱신, `__pycache__` 지우기
- [ ] 1순위 끝나면 짧게 보고 → 3순위

## 3순위 메모 (범용 효과·UI, 1순위가 끝난 뒤. 폴더와 JOB.md는 그때 만든다)

`COMMON.md` 대상은 불, 물, 번개, 얼음, 독, 회복, 폭발, 연기, 창틀, 버튼 바탕, 아이콘 틀, 커서다. 아래 초안(31개)을 generic job의 JOB.md로 옮겨 확정하고 시작한다. 효과는 192 칸 한 줄 5칸 애니메이션 시트로 만들고, 이번에 추가하는 도구 기능(프레임 투명도, pack_sheet)을 그대로 쓴다. 횃불 몸체처럼 장소에 붙은 물건은 다른 세션 담당이고, 거기서 나오는 불꽃만 여기서 만든다.

- 불: 작은 불꽃(반복), 불붙음, 불 폭발, 횃불·촛불 불꽃(반복)
- 물: 물 튐, 바닥 물결, 물방울 떨어짐
- 번개: 내리침(384 세로), 전기 튐
- 얼음: 조각 튐, 얼어붙음, 서리 김
- 독: 독 구름(반복), 독 방울, 독 거품
- 회복: 회복 빛, 반짝임, 되살림 빛기둥(384 세로)
- 폭발·연기: 작은 폭발, 큰 폭발(384), 연기 한 번, 연기 줄기(반복), 먼지 일기
- 강화·약화: 위로 오르는 강화, 아래로 가라앉는 약화
- UI: 창틀 밝은 것·어두운 것(9분할), 버튼 바탕 4상태(보통·올림·눌림·꺼짐), 아이콘 틀 2상태(보통·선택), 커서 화살표(3칸 반복), 선택 커서 쐐기
