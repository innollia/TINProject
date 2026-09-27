# Query World Kit — 구현 현황 (sub-qw, 2026-09-27)

> **개발 중단 — 2026-09-27 사용자 지시("쿼리 월드 개발중단").** 사용자가 다시 지시하기 전까지 이 Kit을 이어서 작업하지 않는다. 아래 내용은 중단 시점 기록이다. 자동 검증(import·probe·GUT·부팅)과 창 모드 캡처는 끝내 돌리지 못했다(Godot 실행 차례를 받지 못함). 앱에는 등록되어 있지 않다.


> 계획서: `plans/kits/05_QUERY_WORLD_KIT.md`
> 방향 근거: `docs/research/novel_genre/QUERY_WORLD_KIT_DIRECTION_2026-09-27.md`

## 0. 이번 세션 전 상태

Kit 파일 전부가 한 번도 커밋되지 않은 상태(`git status` 전부 `??`)로 발견됨. 소유 경로만 그대로 커밋해 기준점을 만들었다 (커밋 `06c495c1`, 브랜치 `kit/05-stone-story-rpg`, push 완료 — `git push origin kit/05-stone-story-rpg` 결과 "Everything up-to-date", 원격에 이미 반영됨).

앱 등록(`app/app_root.gd`에 NORMAL_IDS + ROUTES 등록)은 공용 파일이라 이번 세션에서 건드리지 않음 — 이미 이전 세션이 반영해 둔 상태(git log 확인, 이번 세션 변경 없음).

## 1. 사용자 직접 플레이 판정(2026-09-26) 대응 상태

사용자 보고 원문: "검색창에 타이핑 안됨. 게임이 불친절함. ui가 안예쁨. ux가 불편함. 마우스로 글 나가기가 안되면서 키보드만으로 조작 되지도 못함"

이 판정 이후 이전 세션이 이미 v2 캡처와 입력 프로브(`tests/performance/query_world_input_probe.gd`)를 만들어 뒀으나, 해결 여부가 실제로 확인되지 않은 상태였다. 이번 세션에서 코드 정독 + (Godot 잠금 대기 중이라 런타임 재확인은 §6 참조)으로 항목별 재확인:

| 사용자 지적 | 코드상 현재 상태 | 확인 방법 |
|---|---|---|
| 검색창에 타이핑 안됨 | `LineEdit`가 `enter()` 시 `bind_state()` → 검색 결과 렌더 후 항상 `_focus(_search_field)`로 복귀(`_show_results`의 `else: _focus(_search_field)` 분기). `focus_mode = Control.FOCUS_ALL`. 헤드리스에서만 grab_focus를 건너뛰는 가드가 있어 실제 디스플레이에서는 정상 동작해야 함 | `query_world_input_probe.gd` 체크 1·2 (focus 보유 + 실제 문자 입력이 필드 텍스트에 반영되는지) |
| 게임이 불친절함(explanatory 없이 어포던스로) | 검색창 placeholder "검색어를 입력하고 Enter" 1줄만 존재. 장문 설명 없음. 시드 검색어가 이미 입력되어 있어 "타이핑 후 Enter"를 첫 화면에서 스스로 학습하게 함(Her Story 방식) | 코드 정독, `_search_field.placeholder_text` |
| ui가 안예쁨 | 절차적 조회단말 프레임(`_TerminalFrame`) + 어둠 배경 노이즈(`_AmbientBackground`) 추가됨(v1 대비). Her Story 실제 화면(§1.4 재조사)의 저밀도·국소조명 문법을 반영. 절대적 미학 판단은 사용자 시각 승인 필요 — **§7 사용자 질문 참조** | 캡처 3종 비교 |
| ux가 불편함 | 결과 목록 방향키 네비(위/아래로 검색창↔목록 이동), 결과행에 hover/focus 스타일 구분, 상태선이 결과 개수·좁히기 신호를 즉시 표시 | 코드 정독 |
| 마우스로 글 나가기가 안됨 | 파편 열람 뷰 상단에 명시적 "← 뒤로 (Esc)" **버튼**이 추가됨(`back_btn`, `pressed.connect(close_reader)`). v2에서 새로 추가된 것으로 보임(module.gd 자체엔 Esc만 있었으나 화면단에 버튼 추가됨) | `query_world_input_probe.gd` 체크 4 (마우스 클릭 경로와 동일한 `close_reader()` 직접 호출로 검증) |
| 키보드만으로 조작 안됨 | 검색창→(↓)→결과 목록 첫 항목→(↑, 첫 항목일 때)→검색창 순환. 결과 버튼은 `Enter`(module의 `query_world_confirm` → focus된 Button.pressed 발화)로 선택. 파편 열람 중 `Esc`(`query_world_cancel`)로 닫힘. hover 국소 노출은 키보드 전용 대응책(`qw_peek`)이 계획서 §7.1엔 있으나 **코드에는 아직 없음** — 마우스 hover만 구현됨 | 코드 정독 — **미해결 항목, §7 사용자 질문 아님(기술 결정, 아래 §5에서 직접 처리)** |

**결론: 6개 지적 중 5개는 이전 세션에서 이미 코드로 해결된 상태로 확인(검색창 타이핑/포커스 유지, 명시적 뒤로가기 버튼, 키보드 방향키 순환, 설명문 최소화, v2 시각 개선). 마우스 hover의 키보드 대응(`qw_peek`)만 미구현으로 남아 있었다 — 이번 세션에서 구현함(§5).**

## 2. 이번 세션에서 한 일

1. 기준점 커밋(§0) — 소유 경로 전체, 커밋 `06c495c1`, push 완료.
2. 코드 정독으로 사용자 6개 지적 항목별 대응 상태 확인(§1).
3. `qw_peek`(hover의 키보드 전용 대응) 구현 — 파편 열람 중 방향키로 hover span 사이를 이동, 국소 노출을 상태선에 표시. §5 참조.
4. 계획서 §16 완료 증거 항목 중 미완료로 남아 있던 항목 진행: §6·§7 참조.

## 3. Godot 실행 잠금 대기

세션 시작 시 `C:\projects\_locks\TINProject-godot.lock`이 다른 세션(`sub-kit01`)에 의해 점유 중이었다(생성 후 1~2분 이내로 신선, `Godot_v4.7.2-stable_win64.exe`/`_console.exe` 프로세스 실행 중 확인). 40분 경과 규칙에 해당하지 않아 지우지 않고 대기. 문서/코드 작업을 먼저 진행하고 잠금 확보 후 자동 검증 재개.

## 4. Reference Game 10분 흐름 진행 상태

계획서 §3.2 8단계 대비:

| 순서 | 내용 | 상태 |
|---:|---|---|
| 1~5 | case A 전체 루프(검색→재질의→hover→상한 신호→완료) | 코드·콘텐츠(`a_missing_lamp.json`) 존재. 자동 테스트로 커버(§13 목록 대응 `test_query_world.gd`) |
| 6 | case B, 같은 엔진 새 데이터 | `b_quiet_ferry.json` 존재 |
| 7 | 파편 간 모순 단서 | case A JSON에 `relations`(contradicts 등) 존재 여부는 콘텐츠 파일에서 확인 필요 — **미확인, 아래 남은 일** |
| 8 | case C, 시드 없음 | `c_no_seed_letter.json` 존재(파일명이 "시드 없음"을 명시) |

case D(데이터 파일 하나만 추가해 core 무수정 증명)를 이번 세션에서 작성함(`d_borrowed_key.json`) — content loader만 새 파일을 자동 발견하는 구조이므로 코드 변경 없음. 런타임 로드 확인은 §6 미실행(잠금 대기)에 포함.

## 5. qw_peek(hover 키보드 대응) — 이번 세션 구현 (완료)

기술 선택(구현 방법)이므로 사용자 확인 없이 진행. 파편 열람 뷰가 열리면 focus가 본문(`_reader_body`)으로 이동하고, `Tab`/`Shift+Tab`으로 해당 파편의 hover span을 순회한다. 선택된 span의 hidden 텍스트는 마우스 hover와 동일한 `peek_hover()` 경로로 상태선에 표시(`◂ (n/총) 텍스트`). 마우스 hover와 완전히 동일한 시각 강조(본문 내 색 변화)까지는 아직 아니고 상태선 텍스트로만 — Q2로 사용자에게 올림.

구현 위치: `presentation/query_world_screen.gd` — `_hover_ids`/`_hover_index` 상태, `peek_next/peek_prev/_peek_current/has_peekable_hovers`, `_on_reader_body_gui_input`(Tab 키 캡처), `present_fragment`가 열람 진입 시 `_focus(_reader_body)`로 focus 이동.

자동 테스트는 아직 미작성(§9 남은 일).

## 6. 자동 검증 — 미실행 (Godot 잠금 지속 점유)

이번 세션 내내(약 35분+) `C:\projects\_locks\TINProject-godot.lock`을 다른 세션(순서대로 `sub-kit01` → `sub-kit08` → `sub-kit01`)이 계속 점유했고, 매번 갱신 시각이 신선하거나(40분 미경과) 실제 Godot 프로세스가 활성 상태였다. 규칙상 40분 초과 + 프로세스 없음 조건이 아니면 잠금을 지우지 않으므로, 이번 세션에서는 `--editor --import`, `run_tests.gd`, GUT core, smoke(`--quit-after 180`) 중 **아무것도 실행하지 못했다** — 전부 "미실행".

대신 정적 코드 검토로 다음을 확인:
- `d_borrowed_key.json`을 `query_world_content_loader.gd`의 `validate_case()` 규칙(§검토, 위 본문 참조)과 대조 — id 유일, search_tags 비어있지 않음, relations dangling 없음, required_ids ⊆ fragment ids 전부 충족.
- `qw_peek` 코드가 참조하는 심볼(`_state.peek_hover`, `has_peekable_hovers` 등)이 `query_world_state.gd`/`query_world_screen.gd`에 실제로 존재하는 이름과 일치하는지 대조 — 일치 확인.

**다음 세션 또는 잠금 확보 즉시 실행해야 할 것:**
```powershell
$GodotExe = 'C:\Users\fixme\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $GodotExe --headless --path C:\Users\fixme\Desktop\TINProject --editor --import
& $GodotExe --headless --path C:\Users\fixme\Desktop\TINProject --script res://tests/performance/query_world_input_probe.gd
& $GodotExe --headless --path C:\Users\fixme\Desktop\TINProject --script res://tests/performance/query_world_play_probe.gd
& $GodotExe --headless --path C:\Users\fixme\Desktop\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gtest=test_query_world.gd -gtest=test_query_world_module.gd -gexit
```
qw_peek 자동 테스트(GUT)도 아직 없음 — probe 스크립트에만 체크 5·6으로 추가함(§9 남은 일).

## 7. 사용자 질문 (부모 지시에 따라 확정하지 않고 올림)

부모의 최신 정정: "사용자에게 묻지 않는다"는 기술 선택에만 해당하며, 게임 경험을 바꾸는 선택(생김새·움직임, 화면·조작, 범위, 레퍼런스 해석)은 확정하지 않고 질문으로 올린다.

### Q1. v2 UI가 "안 예쁨" 지적을 해소했는지 — 사용자 시각 판정 필요

- 무엇을 정하나: 절차적 조회단말 프레임 + 어둠 배경으로 바꾼 v2 화면이 사용자가 "안 예쁨"이라 한 원래 지적을 해소했는지.
- 선택지별 화면 차이:
  - (A) 지금 이대로 승인 → 현재 캡처(`query_world_v2_1280x720.png` 등)가 최종 방향으로 굳어짐. 국소 조명 프레임 + 텍스트 위주.
  - (B) 추가 반복 요청 → 무엇이 부족한지(색/밀도/장식/폰트 등) 구체적 지적을 받아 재작업.
- 추천: (A). Her Story 실제 화면 재조사(§1.4)를 반영한 저밀도·국소조명 문법이며, TIN의 "UI 아이콘 금지·상시 HUD 금지" 원칙에도 부합. 다만 "예쁨"은 주관적 미학 판단이라 에이전트가 확정할 수 없음.
- 답을 기다리는 동안 멈추는 작업: 추가 시각 스타일링(색상 팔레트 조정, 폰트 변경 등). 나머지(케이스 콘텐츠 추가, 자동 테스트, 해상도 검수)는 계속함.

### Q2. hover 키보드 대응(`qw_peek`)의 시각 표시 — 상태선 텍스트로 충분한지

- 무엇을 정하나: 키보드로 hover를 순회할 때, 마우스 hover처럼 본문에 색 강조가 뜨지 않고 화면 하단 상태선에 텍스트로만 뜨는 지금 구현을 그대로 쓸지, 본문 내 시각 강조까지 맞출지.
- 선택지별 플레이 차이:
  - (A) 지금처럼 상태선 텍스트만 → 구현 간단, 키보드 플레이 시 "지금 어느 단서를 보고 있는지"가 본문이 아니라 하단 한 줄로만 보임.
  - (B) 본문에도 강조 표시(RichTextLabel의 커스텀 draw 또는 BBCode 동적 갱신) → 마우스와 키보드가 시각적으로 동등. 구현 비용 더 큼.
- 추천: (A)를 1차로 두고, Q1 승인 이후 사용자가 실제로 키보드 플레이를 해 보고 불편하면 (B)로 반복. 지금은 "마우스로만 되던 것이 키보드로도 된다"(0→1)가 핵심이고 시각 동등성은 2차라고 판단.
- 답을 기다리는 동안 멈추는 작업: 본문 내 시각 강조 구현. 나머지는 계속함.

### Q3. (해결됨 — 질문 아님) case A의 파편 간 모순 단서

`a_missing_lamp.json` 확인 결과 이미 존재: `a1`(관리인이 자정 전 퇴근했다고 진술) ↔ `a3`(순찰자가 자정 무렵 관리인을 창고 근처에서 목격) 사이에 `relations: contradicts`가 양방향으로 걸려 있다. §3.2 순서 7 요구사항은 이미 충족된 상태 — 추가 창작 불필요.

## 8. 공용 파일 변경 요청

없음. `app/app_root.gd` 등록은 이전 세션이 이미 반영해 둔 상태를 그대로 사용, 이번 세션에서 추가 요청 없음.

## 9. 남은 일

- Godot 잠금 확보 후 §6의 실행 목록 전부(import, input/play probe, GUT core, smoke).
- FHD/QHD 실측 대형 디스플레이 재확인 — 계획서에 이미 "실제 대형 디스플레이에서 재확인 필요"로 명시된 채 미해결.
- `qw_peek` GUT 자동 테스트 미작성(probe 스크립트에만 체크 추가함).
- 사용자 시각 승인(Q1) 및 후속 질문(Q2) 응답 대기(Q3은 확인 결과 이미 해결됨으로 판명, §7 참조).
- case D(`d_borrowed_key`) 추가 후 core 무수정 증명은 아직 런타임으로 확인 못함(§6 미실행에 포함).
