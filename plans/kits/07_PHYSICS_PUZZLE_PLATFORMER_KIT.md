# Kit 07 — 물리 조합 플랫포머 (physics_puzzle_platformer)

> Primary Reference: **Mosa Lina** (Steam appid `2477090`, Stuffed Wombat / Silkersoft / Lukke / Rollin'Barrel, 2023-10-17)
> 조사 정본: `docs/research/mosa_lina/MOSA_LINA_RESEARCH.md`
> 라운드 정본: `docs/research/round_2026_09_26/ROUND_PLAN.md`
> **세계관 노출 금지(정본):** 같은 라운드 정본 §11.3 — 이 Kit에서의 기계적 집행은 **§11.9 / §11.10** 가 정본이다.
> 공유 계약: `docs/KIT_WORKFLOW.md`, `docs/MODULE_CONTRACT.md`, `docs/CODE_STYLE.md`
> 이 기획서의 빈칸이 남아 있으면 구현하지 않는다.

**모듈 id:** `physics_puzzle_platformer`
**모듈 표시명:** `균열 조합장`
**Kit 폴더:** `modules/physics_puzzle_platformer/`
**이미지 파일:** 0개. **레벨 절차 생성:** 금지. **자물쇠-열쇠:** 금지. **pity/중복 억제:** 금지.

---

## 0. 현재 코드 감사 (TEMPLATE 필수 항목)

`docs/PROJECT_DECISIONS.md` §7에 따라 이 Kit의 whitelist 출발점은 `first_entry` / `rule_rewriting` / `odd_road_adventure` / `game_library` 뿐이다. 아래 두 항목은 **Retired Prototype**이며 새 설계의 근거로 쓰지 않는다.

### 0.1 살릴 후보

| 경로/시스템 | 살릴 이유 | 반드시 다시 검증할 것 |
|---|---|---|
| `core/contracts/game_module.gd` | `enter/exit/save_state/load_state/migrate_save/execute_command` 시그니처. 이 Kit도 같은 계약을 따른다 | `_ready`에서 gameplay를 시작하지 않는지, `exit`에서 timer/signal을 정리하는지 |
| `core/contracts/module_context.gd` | `allows_action` / `is_action_pressed` / `get_axis`가 ModuleContext 경계만 주입한다 | 물리 키를 domain에 하드코딩하지 않는지 |
| `core/services/input_router/input_router.gd`의 `configure_actions()` 패턴 | `InputMap.add_action()`을 **런타임에** 하는 기존 관례. 이 Kit이 `project.godot`(W0 소유)을 건드리지 않고도 자기 action을 등록할 수 있다 | 중복 등록 시 `action_has_event` 가드를 유지하는지 |
| `modules/first_entry/first_entry.gd`의 Input Bubble 계약 | `get_input_bubble_state()` / `get_bubble_state(action)` / `get_bubble_cell(action)` / `set_key_profile(profile, previous_profile)` / 상태 4종 `intact|popped|rising|restoring` / `GRID_COLUMNS = 3`. 전환층이 나중에 그대로 인계받을 수 있는 **동일 이름 API**다 | 이 Kit이 같은 이름과 같은 상태 문자열을 지키는지, `bubble_cells`가 저장 후에도 고정 셀을 유지하는지 |
| `modules/first_entry/first_entry.gd:165` `_profile_from_arrival` | `context.arrival["key_profile"]` / `["previous_key_profile"]`로 진입 구간의 키 집합을 받는 관례 | 복사하지 말고 `context.arrival["ppp_*"]`로 Kit-local 이름만 쓴다 |
| `core/services/audio_service/audio_service.gd` | 버스 4종(`Music/SFX/UI/Voice`) 확보됨. 새 버스를 만들지 않는다 | W3의 `audio_event_player`가 없을 때 무음 no-op으로 통과하는지 |

### 0.2 버릴 것

| 경로/표현/구조 | 버리는 이유 |
|---|---|
| `modules/physics_toolbox/` 전체 | Retired Prototype. `module.gd:11`의 `ROUTE_SOLUTIONS = [[0,1,2],[2,1,0]]`가 **정답 시퀀스를 코드에 박아 둔 자물쇠-열쇠**다. 이 Kit에서 금지되는 패턴 그 자체다. `OBJECT_HINTS` 3줄짜리 상시 힌트 라벨, `도구 상자` 패널, `밀대·고정자·되튐 스프링` 설명문도 전부 금지 대상. `mode` 2단계 판정 흐름도 재사용하지 않는다 |
| `modules/rule_rewriting/art/**` (PNG/SVG 200개+) | 이미지 파일. 이 Kit의 이미지 0개 하드 게이트를 위반한다. 스프라이트를 베끼지 않는다 |
| 기존 플레이 모듈들의 상시 Label HUD | `AGENTS.md` 화면 금지 목록 전체. 읽지 않는다 |

**결론:** 이 Kit은 기존 코드를 **읽기만** 하고 새로 쓴다. 재사용하는 것은 `core/contracts/*`와 `core/services/*`의 런타임 계약, Input Bubble의 **이름 계약**, InputRouter의 런타임 action 등록 패턴 3가지뿐이다.

---

## 1. Kit 목적과 한 문장 설계 기둥

### 1.1 Kit 목적

- TINProject 본편의 한 구간이 **물리 퍼즐 플랫포머**로 바뀌는 순간을 즉시 만들 수 있게 한다.
- 이 Kit를 쓰면 실제 콘텐츠 개발에서 **새로 만들지 않아도 되는 것**:
  - 하나의 물리 파이프라인 안에서 서로 전부 반응하는 바디 종류 13종과 재료 9종의 물성 표
  - authored 레벨/도구 JSON을 읽고 검증하고 스폰시키는 파이프라인
  - "레벨은 handmade, 변하는 것은 선택"이라는 런타임 무작위 선택기
  - "약간의 변형"을 안전하게 적용하는 변형 오퍼레이션 6종
  - 심판 우선순위가 고정된 접촉 해석기와 스텝 디렉터
  - 절차 비주얼만으로 구성한 3층 패럴랙스 + 물리 반응형 말랑말랑 배경
  - 이미지 0개 · 상시 HUD 0개 상태의 720p/FHD/QHD 대응 화면
  - 버전 있는 JSON 저장/복구와 사망·리셋 경로
  - GUT 자동 테스트 11개 파일
  - `body` / `creature` / `place` 세 축을 **읽기만** 하는 축 인계 어댑터와 그 물리 해석(§14.8)

### 1.2 이 Kit이 다루지 않는 것

- 절차적 **레벨 생성** (선택과 변형만 허용)
- 자물쇠-열쇠 (도구 A는 문제 A만 푼다 → 금지)
- 인벤토리 UI / 슬롯바 / 아이템 개수 숫자
- 적 AI, 전투, 체력 회복 아이템, 카르마식 누적 게이트
- 레벨 에디터, 레벨 브라우저, Steam Workshop 류 콘텐츠 공유
- 코-op, 로비, 멀티플레이
- 이미지·폰트·스프라이트 파일

### 1.3 한 문장 설계 기둥

> **손으로 만든 레벨과 손으로 만든 도구를 무작위로 섞어서 내어 주고, 무엇이든 서로 부딪힐 수 있는 하나의 물리 세계에 던져 넣는다. 해결법은 미리 정해 두지 않는다.**

영문: *Handmade pieces, dealt at random, in one world where everything collides with everything. No premeditated solution.*

이 기둥이 지켜지면 안 되는 순간은 **"지금 이 도구가 저 문제를 푼다"**가 화면에서 읽히는 순간이다. 그 순간이 생기면 설계가 깨진 것이다.

### 1.4 설계 법칙 5개 (Primary Reference 개발자 원문에서 온 것)

| # | 법칙 | 출처 | 이 Kit에서의 강제 방법 |
|---|---|---|---|
| L1 | "nothing is planned, and everything works" | 스토어 원문 (확인) | `systems/mutation.gd`에 지형·목표·스폰을 바꾸는 오퍼레이션이 **존재하지 않게** 한다. `tests/core/test_ppp_mutation.gd`가 6종 허용 목록 외 키를 거부함을 단언한다 |
| L2 | "This does NOT mean that the game has proc-gen. Tools and Levels are handmade, they are just randomly selected and sometimes slightly modified!" | 스토어 원문 (확인) | `systems/selector.gd`는 `content/levels/index.json`의 **고정 목록에서 인덱스를 균등 뽑을 뿐** 레벨을 조립하지 않는다. `test_ppp_selector.gd`가 `rng` 호출 결과가 index 범위 안의 정수임을 단언한다 |
| L3 | "There are no safeguards here. You might get the same item ten times in a row." | 스토어 원문 (확인) | `systems/selector.gd`에 `last_picked` 비교 코드, 가중치 테이블, pity 카운터가 **없어야** 한다. `test_ppp_selector.gd`가 20000회 뽑기에서 중복률과 연속 중복이 통계적으로 정상임을 단언한다 |
| L4 | "the player, tiles, items and obstacles are all parsed through the same physics-engine. Everything interacts with everything else." | 스토어 원문 (확인) | 플레이어는 `CharacterBody2D`가 아니라 **`RigidBody2D`** 다. `§4.2`의 13×13 상호작용 행렬에 빈 칸이 없어야 하고, 전부 `Godot PhysicsServer2D` 한 곳에서만 해결된다 |
| L5 | "It's literally impossible for me to check if all levels are beatable with all combinations of tools." | 스토어 원문 (확인) | "모든 조합이 해결 가능하다"는 **완료 조건이 아니다.** 테스트는 개별 레벨의 해법 존재를 검사하지 않고, 시스템 불변식(§4.7)만 검사한다 |

---

## 2. Primary Reference 표 — 무엇을 따르고 무엇을 따르지 않는가

**게임:** Mosa Lina
**개발:** Stuffed Wombat, Silkersoft, Lukke, Rollin'Barrel (4인 표기. Nintendo eShop에는 "Accidently Awesome" 표기가 있었으나 어느 쪽이 정확한지는 미확인 → **Steam 표기를 정본으로 쓴다**)
**출시:** 2023-10-17 · **리뷰:** Overwhelmingly Positive 95% (영문 1,721개)
**공식 출처:** https://store.steampowered.com/app/2477090/

**범위:** 베이스 게임만. **미반영:** 내장 레벨 에디터, Steam Workshop, 코-op, 분할 화면, Steam Cloud, 사운드트랙 번들.

### 2.1 상태별 레퍼런스 증거

조사 방법이 Steam 스토어 페이지 직접 조회였으므로, **정지 이미지로는 확인할 수 없는 상태는 `미확인`으로 적고 그것을 그대로 §20 미결로 넘긴다.** 구현자가 이 표의 빈칸을 "알아서 채우지" 않도록 §3에 우리 결정을 명시한다.

| 상태 | 실제 reference 자료 | 눈으로 확인할 것 | TIN에서 가져갈 규칙 | 확인도 |
|---|---|---|---|---|
| first playable frame | 스토어 페이지 헤더 아트워크 | 미니멀/컬러풀/픽셀 톤, 평면 색면 비중, 오브젝트 밀도 | 화면 70% 이상을 단색 평면 색면으로 채운다. 그라디언트·텍스처 금지 | 미확인(정지 아트워크) |
| normal play | 스토어 설명의 물리 문장, 스크린샷 썸네일 | 플레이어가 오브젝트에 **물리적으로** 반응하는지, HUD 유무 | HUD 0개. 진행 정보는 오브젝트 자체에 있다 | 미확인 |
| focus / selection | 없음 | — | **Primary Reference에 focus/selection 개념이 없다.** 이 Kit도 커서를 두지 않는다. 유일한 선택은 "들고 있는 도구"뿐이고 그것은 실루엣으로 보인다 | 미확인 |
| core mechanic change | 스토어 원문 2.5 | 아이템을 던지면 다른 것을 밀고, 그 힘이 또 다른 것을 민다 | `§4` 단일 물리 파이프라인. 모든 바디가 모든 바디와 반응 | **확인(텍스트)** |
| unavailable / failure | 스토어 원문 2.3 | "풀 수 없을 수도 있다"를 게임이 보장하지 않는지 | **해결 가능성 보장을 하지 않는다.** 리셋(R)과 사망 복구는 유일한 회복 경로다 | **확인(텍스트)** |
| success / completion | 스토어 원문 2.5 | "collect fruits to open the portal" | 목표 N개를 모으면 포털이 열린다. N개는 레벨 JSON이 정한다 | **확인(텍스트)** / 열림 애니메이션은 미확인 |
| menu / detail | 스토어 기능 목록 | 에디터/Steam 목록 화면 | **따르지 않는다.** TIN은 인게임 에디터·레벨 목록 UI를 넣지 않는다(§2.2, §11.4) | **확인(기능 존재만)** |
| level / scene transition | 없음 | — | 전환 화면에서만 레벨 이름 카드 0.9초. 같은 전환 화면의 런 진행 pip은 **도형 8개 고정이며 숫자를 그리지 않는다**(§11.9-2). 플레이 중에는 금지 | 미확인 → 우리 결정 |

### 2.2 강하게 따르는 것

| 항목 | 구체 규칙 | 근거 |
|---|---|---|
| 단일 물리 파이프라인 | 플레이어/타일/아이템/장애물/도구/데코가 전부 PhysicsServer2D 한 곳. 플레이어는 `RigidBody2D` | 원문 2.5 (확인) |
| Everything interacts with everything | 13종 바디의 모든 쌍에 상호작용 규칙이 존재. "아무것도 못 한다"는 코드 경로가 없음 | 원문 2.5 (확인) |
| handmade + 무작위 선택 | 레벨은 파일로 authored. 런타임은 어떤 파일을 제시할지만 고른다 | 원문 2.3 (확인) |
| raw random, 무 안전장치 | 균등 뽑기, 중복 허용, pity 없음, 등장률 가중 없음 | 원문 2.4 (확인) |
| lock-and-key 반대 | 도구는 특정 문제를 해결하도록 설계되지 않는다. 모든 도구는 모든 바디와 반응한다 | 원문 2.2 (확인) |
| 목표 = 수집 후 개방 | 레벨별 필요 개수를 모아 포털을 연다 | 원문 2.5 (확인) |
| 해결법 없음 | 사전에 정해진 해법이 없다 | 원문 2.3 (확인) |
| 미니멀 + 컬러풀 + 픽셀 + 사이드 스크롤 | 평면 색면 + 기하 도형. 그라디언트·노이즈 텍스처·디테일 스프라이트 금지 | 스토어 태그 (확인) |
| 롤백 없음 | 물리 상태는 되돌릴 수 없다. 중복은 `R`로 리셋한다 | 원문 2.4의 "safety 없음"을 물리 상태까지 확장한 **우리 결정** |

### 2.3 일부만 따른다

| 항목 | 따르는 부분 | 따르지 않는 부분 | 이유 |
|---|---|---|---|
| 미니멀 | HUD 0개, 색면 단순화, 오브젝트 실루엣 우선 | 화면 여백을 감추는 대신 **배경은 항상 살아 있다** | 배경이 말랑말랑하게 반응해야 "Everything interacts with everything"가 배경까지 확장돼 보인다. 배경 생략은 감각이 아니라 정보 손실이다(§11.3) |
| Raw Random | 레벨/도구 선택 | 런타임 중 재추첨, 리롤 버튼, "다른 세트" 메뉴 | 재추첨은 안전장치이며 원문이 금지한다. `AGENTS.md`의 "버튼으로 플레이 대체" 금지에도 어긋난다 |
| 에디터 | JSON으로 레벨을 **나중에 사람이 직접 쓸 수 있다** | 인게임 에디터 | §2.4 |

### 2.4 의도적으로 따르지 않는 것

> **[제작 전용]** 이 절 표의 "앨리스 포스트아포칼립스 재해석" 칸과 그 아래의 명칭 결정은 **제작 정본**이다. `시간알` `틈` `균열 조합장` `종이 부채` 는 authored 데이터의 `name` 필드와 모듈 `display_name`에만 존재하며, 그중 화면에 나갈 수 있는 값은 **레벨 `name` 9개뿐**이다(§11.9 `T1`~`T9`). 나머지는 §11.9-2에서 그리지 않는다.

| 원작 요소 | 따르지 않는 이유 | TIN에서의 대체 |
|---|---|---|
| 내장 레벨 에디터 | `PROJECT_DECISIONS.md` §6, `docs/KIT_WORKFLOW.md` §4가 "전용 에디터는 완료조건이 아니다"라고 명시한다. **결정: 넣지 않는다** | `content/levels/*.json` + `content/tools/*.json`를 사람이 직접 편집한다. 검증은 `dev/dev_probe.tscn` 헤드리스 하네스로 한다 |
| Steam Workshop / 레벨 공유 | 플레이어가 레벨을 고르는 화면은 raw random 설계와 정면 충돌한다. `AGENTS.md` 금지 목록의 "버튼 목록으로 world interaction 대체"에 해당한다 | 런타임 선택은 시드가 정한다. 특정 레벨을 보려면 `context.arrival["ppp_sequence"]`로 **개발/데모 경로만** 고정한다(UI 없음) |
| Co-op / 분할 화면 | 같은 물리 세계를 두 명이 공유하는 정확성 모델이 미확인(`§4.2`). 추측 구현 금지 | 싱글 플레이어만. `§20-OQ5`로 미결로 남긴다 |
| "과일" 수집물 | 원작 고유 모티프 | 앨리스 포스트아포칼립스 재해석: `시간알` |
| 포털 | 원작 고유 | 앨리스 재해석: `틈` |
| 원작 레벨 배치 | 원작 고유 저작물 | 9개 레벨 전부 `content/levels/`에 새로 authored. 원작 좌표·배치를 한 번도 보지 않는다 |
| 원작 도구 목록 | 미확인 + 원작 고유 | `§10.4`의 7개 도구를 새로 authored |
| 원작 문구·캐릭터·OST | 원작 고유 | 문구 0개. 캐릭터 0개. `§12`의 오디오 이벤트만 W3가 생성 |

### 2.5 레벨 에디터 결정 (명시적)

**결정: 전용 에디터는 넣지 않는다. IN이 아니라 OUT이다.**

한 줄 근거: *레퍼런스의 에디터는 콘텐츠 **저자**의 도구이고, TIN에서 레벨 저자는 사람이 JSON을 쓰는 에이전트 1명이므로 인게임 에디터는 완료조건도 될 수 없고 `AGENTS.md`가 금지한 상시 패널·버튼 행만 늘린다.*

**대신 넣는 것 3가지 (에디터가 아니다):**

1. `content/levels/*.json`, `content/tools/*.json` — 사람이 직접 쓰는 데이터 파일. 레벨 1개 추가는 JSON 1개 + `content/levels/index.json`에 ID 1줄이다.
2. `presentation/dev_probe.tscn` — **헤드리스 콘텐츠 검증 하네스.** 레벨 JSON을 읽어 바디 수·유효성·상호작용 행렬 적용 결과를 stdout으로 찍는다. 게임에서 진입 불가. 완료조건이 아니라 디버깅 도구다.
3. `context.arrival["ppp_seed"] / ["ppp_sequence"] / ["ppp_tools"]` — 시드/순서 고정용 **도착 계약.** 캡처 스크립트와 자동 테스트만 쓴다. 화면 버튼이 아니다.

**넣지 않는 것:** 타일 페인터, 드래그 앤 드롭 배치 UI, 인게임 레벨 브라우저, 정렬/스냅 그리드 편집기, 에디터 내 undo 스택, 플레이/테스트 에디터 안에서 즉시 실행, Steam Workshop 업로드/다운로드, 이그리 키바인드 에디터.

---

## 3. 레퍼런스 근거 — `확인` / `미확인` 구분

표기의미: `확인` = `MOSA_LINA_RESEARCH.md`에 Steam 스토어 원문으로 뒷받침된 사실. `미확인` = 조사에서 확인되지 않았으며, 이 기획서가 **우리 결정으로 채운다**는 표시. `미확인` 항목을 레퍼런스 fidelity로 포장하지 않는다.

### 3.1 `확인` — 설계에 직접 사용

| # | 주장 | 원문 위치 |
|---|---|---|
| A1 | 개발 4인, Stuffed Wombat / Silkersoft / Lukke / Rollin'Barrel, 발매 2023-10-17 | 조사 §1 |
| A2 | "a hostile interpretation of the immersive sim, where nothing is planned, and everything works" | §2.1 |
| A3 | "In order to counter this 'Lock and Key' philosophy, Mosa Lina is aggressively random." | §2.2 |
| A4 | "**This does NOT mean that the game has proc-gen. Tools and Levels are handmade, they are just randomly selected and sometimes slightly modified!**" | §2.3 |
| A5 | "It's literally impossible for me to check if all levels are beatable with all combinations of tools. This is what makes it so satisfying: **There is no premeditated solution for you to follow.** You're forced to get creative." | §2.3 |
| A6 | "There are no safeguards here. You might get the same item ten times in a row. You might beat the game without seeing it at all. Every playthrough contains only a fraction of the total levels. They're also selected randomly." | §2.4 |
| A7 | "Fun things happen more often if you don't force them." | §2.4 |
| A8 | "The player, tiles, items and obstacles are all parsed through **the same physics-engine**. Everything interacts with everything else." | §2.5 |
| A9 | "Sure, all you do is collect fruits to open the portal, but **HOW** you do that is up to you entirely." | §2.5 |
| A10 | 태그: Minimalist, Colorful, Pixel Graphics, 2D, Side Scroller, Puzzle Platformer, Immersive Sim, Simulation, Sandbox, Roguelike, Co-op | §1 |
| A11 | 내장 레벨 에디터 + Steam Workshop 존재 | §2.6 |
| A12 | 한국어 지원 | §1 |

### 3.2 `미확인` — 이 기획서가 **우리 결정**으로 채운 값

| # | 미확인 항목 (조사 §4) | 우리 결정 | 왜 이 값인가 |
|---|---|---|---|
| D1 | 입력 스킴 (조사 §4-1) | `A`/`D` 이동, `Space` 점프, `E` 잡기-차지-던지기, `R` 리셋. 화살표는 별칭 | 4키로 모든 상호작용이 가능하다. `E` 하나로 잡기/차지/던지기를 묶으면 물리 키 집합이 작아 Input Bubble이 짧아진다. 충전式 던지기는 키를 늘리지 않고 "목표 조준"을 만든다 |
| D2 | 런타임 선택 알고리즘 (조사 §4-3) | 런 시작 시 `RandomNumberGenerator` 하나로 레벨 8개 + 도구 8개를 **한 번에** 균등 추첨(중복 허용). 이후 재추첨 없음. 레벨 단위로 들어갈 때 `cursor`만 증가 | 한 번에 그려야 저장이 `seed` 하나로 결정론이 되고, 세이브/로드 중 시퀀스가 밀리지 않는다. "약간의 변형"도 같은 시드로 같이 뽑아 저장한다 |
| D3 | "slightly modified"가 무엇을 바꾸는가 (A4는 존재만 확인) | 6종 오퍼레이션 화이트리스트, 레벨당 최대 2개, 지형·목표·스폰은 불변 | 우리가 유일하게 통제할 수 있는 게 "handmade-ness를 깨지 않으면서 매번 조금 다른 물리가 나오게 하는 것"이기 때문. 변형이 물리 계수만 건드리면 authored 레이아웃이 보존된다 |
| D4 | 도구 목록과 물성 (조사 §4-4) | 7개 도구, 4가지 use 모드(`throw`/`shove`/`freeze_field`/`anchor_line`), 질량 0.35~4.2 | 각 모드는 **다른 물리 경로**를 여는 도구여야 한다. 던지기만 있으면 "everything interacts"의 절반만 증명된다 |
| D5 | 레벨 구조 (조사 §4-5) | 레벨 1개 = `bounds` + 지형 타일 4~9 + 바디 6~18 + 시간알 2~6 + 틈 1. 필요 개수 2~6 | 6종(0.4·0.7·1.0·1.4 등)은 돌다bundled 쌓기 상자가 무너지지 않는 대역 |
| D6 | 난이도/진행 구조·엔딩 (조사 §4-7) | 런 1회 = 레벨 8개. 분기 없음. 엔딩 없음. `run_complete` 후 `requested`로 결과만 보고하고 Shell이 결정 | primary reference의 클리어 조건이 미확인이다. "게임이 끝나는 화면"을 지면 Shell 권한을 넘어선다. 이 Kit은 결과를 **알리기만** 한다 |
| D7 | 카메라 (조사 §4-10) | 2D 사이드 스크롤, zoom 1.0, 세로 고정(`camera_y`), 가로 데드존 96px 추종, 셰이크 최대 6px | 사이드 스크롤에서 세로 추종은 플레이 영역이 흔들려 점프 판단이 어려워진다. 전형적인 2D 플랫포머 해상도다 |
| D8 | 오디오 (조사 §4-8) | `§12`의 17개 이벤트만. 배경음 루프 없음. 보이스 없음 | 미확인 항목에 대한 임의 상세 설계는 위험하다. 위에서 감지 가능한 소리(접촉·파손·획득·개방)만 만든다 |
| D9 | 코-op 정확성 모델 (조사 §4-2) | **미구현.** 싱글 플레이어만 | 추측 구현은 Primary Reference 규칙 위반이다 |
| D10 | 공방/협동 방지 수치 (조사에 없음) | 이 Kit은 전투 0개. 목표는 물리를 통한 위치 변화다 | Primary Reference의 Immersive Sim/Simulation 태그를 "전투"로 오독하지 않는다 |
| D11 | 성공 화면/클리어 연출 (미확인) | 성공 = 틈이 충전되어 벌어지고 플레이어가 통과하면 `requested(&"level_result", ...)`. 전용 성공 화면 없음 | 10분 Reference Game의 클라이맥스를 매번 별도 화면으로 끊지 않는다. 전환 화면(0.9s)만 쓴다 |
| D12 | 개발 과정·기간 (조사 §4-9) | 무관. 참조하지 않는다 | — |

**규칙:** `미확인` 항목을 이 기획서에서 지울 수 없다. 구현자는 `확인`과 `우리 결정`을 같은 무게로 취급하고, 화면·코드·문서 어디에도 "Mosa Lina처럼 보인다"고 쓰지 않는다. `D1`~`D12`는 이 Kit의 `PROJECT_DECISIONS.md` 추가 대상이며, 사용자가 바꾸면 이 기획서가 갱신된다.

---

## 4. 단일 물리 세계 시스템

### 4.1 원칙

1. 이 Kit에는 **물리 파이프라인이 하나뿐**이다. `Godot PhysicsServer2D`. 커스텀 AABB 스윕, 격자 충돌, 자체 이중 버퍼를 쓰지 않는다.
2. 플레이어는 `RigidBody2D`다. `CharacterBody2D`를 쓰면 "플레이어가 오브젝트를 민다"가 성립하지 않고, 오브젝트가 플레이어를 밀 수도 없다. 레퍼런스 원문 2.5가 요구하는 바로 그 관계다.
3. **총알 관통을 수치로 막지 않는다.** 총알이 통과하면 레벨 오류가 아니라 authored 배치의 문제다. 대신 통과가 반복되면 그 레벨은 `mutable`에 `size_mul`이 없거나 총알 수가 많다. `dev_probe`가 이 통계를 뱉는다.
4. 도형은 **최대 6개의 컨vex convex hull**로 표현한다. `CapsuleShape2D`는 1개 hull로 분해한다. Godot 2D는 concave를 직접 지원하지 않으므로 authored 단계에서 hull로 쪼갠다.
5. 물리는 전부 `Node2D` 기준 픽셀 단위다. 스케일 변환 없음. `zoom = 1.0` 고정.

### 4.2 바디 종류 13종

전부 `modules/physics_puzzle_platformer/domain/body_kind.gd`의 상수 테이블에 선언된다. `code`는 파일 안에서 쓰는 열거값이다.

| # | `code` | Godot 노드 | 물리 역할 | hp 기본 | damageable | breakable | objective | sensor | authored |
|---:|---|---|---|---:|---|---|---|---|---|
| 1 | `PLAYER` | `RigidBody2D` | 조작 대상. 전 바디와 충돌하고 전 바디에 힘을 준다 | 5 | true | false | false | false | 자동 생성 |
| 2 | `TOOL_CARRIED` | `RigidBody2D` | 손에 든 도구. 잡힌 동안 `freeze = true`로 플레이어에 붙고, 던져지면 자유 바디 | 도구별 | 도구별 | 도구별 | false | false | 도구 JSON에서 생성 |
| 3 | `TOOL_PLACEMENT` | `Area2D` | 레벨에 놓인 도구 픽업. `monitoring = true`, `monitorable = false` | ∞ | false | false | true(획득) | true | yes |
| 4 | `OBJECTIVE` | `RigidBody2D` | 시간알. 플레이어가 닿으면 소멸하며 개수를 1 올린다 | 1 | false | **true (소멸)** | **true (획득)** | false | yes |
| 5 | `PROP_DYNAMIC` | `RigidBody2D` | 일반 물체. 밀리면 굴러가고, 쌓이면 무너진다 | 3 | true | true | false | false | yes |
| 6 | `PROP_SLEEPING` | `RigidBody2D` | 처음에 잠든 물체. `can_sleep = true`, `sleeping = true`로 시작 | 3 | true | true | false | false | yes |
| 7 | `OBSTACLE_DYNAMIC` | `RigidBody2D` | 무거운 장애물. 밀기 어렵고 플레이어를 눌러 죽인다 | 6 | true | false | false | false | yes |
| 8 | `DECOR_DYNAMIC` | `RigidBody2D` | 밀리는 장식. 데미지도 파괴도 없다 | ∞ | false | false | false | false | yes |
| 9 | `TILE_STATIC` | `StaticBody2D` | 지형·벽. 절대 움직이지 않는다 | ∞ | false | false | false | false | yes |
| 10 | `TILE_KINEMATIC` | `AnimatableBody2D` | authored 궤적을 따라 움직이는 발판. 플레이어를 태운다 | ∞ | false | false | false | false | yes |
| 11 | `RIFT` | `Area2D` | 틈. 목표 개수가 차면 열린다 | ∞ | false | false | true(진입) | true | yes |
| 12 | `HAZARD_STATIC` | `StaticBody2D` | 고정된 해처. 닿으면 데미지, 바디는 파괴되지는 않음 | ∞ | false | false | false | false | yes |
| 13 | `HAZARD_AREA` | `Area2D` | 이동 해처(용암면, 성에구름). 위에 있으면 데미지 | ∞ | false | false | false | true | yes |

**금지:** `CharacterBody2D`를 게임플레이 바디로 쓰지 않는다. `Area2D`를 물리 충돌에 쓰지 않는다(센서 전용). `CollisionPolygon2D`의 concave를 쓰지 않는다.

### 4.3 충돌 도형 6종

| `shape` | Godot 클래스 | authored 필드 | 기본 convex hull 수 | 용도 |
|---|---|---|---:|---|
| `box` | `RectangleShape2D` | `size: [w, h]` | 1 | 지형, 판자, 도구 몸통 |
| `capsule` | `CapsuleShape2D` | `size: [w, h]`, `height`는 전체 높이 | 1 | 플레이어, 세로 도구 |
| `circle` | `CircleShape2D` | `size: [d, d]` (지름) | 1 | 시간알, 구슬, 항아리 |
| `triangle` | `ConvexPolygonShape2D` | `size: [w, h]` | 1 | 쐐기, 지붕 |
| `hull` | `ConvexPolygonShape2D` | `points: [[x,y], ...]` (2~6점, 로컬) | 2~6 | 비정형 지형, 찌그러진 판 |
| `segment` | `SegmentShape2D` | `size: [w, len]` | 1 | 닻줄·체인, 얇은 경사판 |

`hull`은 `points`의 정점 수 2 이하일 때 로드 실패로 거부한다. `points`는 중복 정점과 면적 0 삼각형을 금지하고, 로드 시 순서대로 시계 방향으로 정규화한다.

### 4.4 재료 9종

`domain/material_table.gd`. `density`는 kg-equivalent이고 Godot `PhysicsMaterial`의 `density`에 1:1로 들어간다.

| `material` | friction | bounce | density | absorb(rough) | 잉크 | `impact_damage` 스케일 | 부서질 때 파편 수 |
|---|---:|---:|---:|---:|---|---:|---:|
| `paper` | 0.62 | 0.02 | 0.30 | 0.35 | `#f4efe2` | 1.0 | 6 |
| `glass` | 0.30 | 0.28 | 0.70 | 0.10 | `#a8e4ef` | 0.7 | 14 |
| `wood` | 0.74 | 0.10 | 0.55 | 0.30 | `#b98a5a` | 1.2 | 9 |
| `stone` | 0.86 | 0.04 | 1.80 | 0.20 | `#9aa0a6` | 1.6 | 12 |
| `iron` | 0.52 | 0.06 | 3.20 | 0.05 | `#6f7b8a` | 2.2 | 7 |
| `clockwork` | 0.66 | 0.16 | 1.10 | 0.08 | `#d8c15a` | 0.9 | 16 |
| `wax` | 0.94 | 0.01 | 0.45 | 0.55 | `#f0d7c0` | 0.6 | 5 |
| `void` | 0.02 | 0.00 | 0.10 | 0.90 | `#2b2540` | 0.4 | 3 |
| `goal` | 0.40 | 0.00 | 1.00 | 0.00 | `#ffe9a8` | 0.0 | 0 |

`breakable` 재료는 `paper, glass, wood, stone, clockwork, wax`. `iron`과 `void`는 파괴되지 않는다(→ **soft-lock 원천 차단**).

### 4.5 상호작용 행렬 (13×13, 전부 채움)

`domain/interaction_rules.gd`의 `TABLE` 배열. **빈 칸이 없어야 한다.** `—`(none)는 이 Kit에서 "이 쌍은 절대로 접촉하지 않는다"를 뜻하며, 실측에서 접촉하면 로더가 로드 실패로 잡아낸다(dev_probe 경고).

행: 주어진 바디. 열: 접촉 상대. 대칭.

| | PLAYER | TOOL_CARRIED | TOOL_PLACEMENT | OBJECTIVE | PROP_DYNAMIC | PROP_SLEEPING | OBSTACLE_DYNAMIC | DECOR_DYNAMIC | TILE_STATIC | TILE_KINEMATIC | RIFT | HAZARD_STATIC | HAZARD_AREA |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **PLAYER** | — | `carry` | `grab` | `collect` | `dmg_a/b` | `wake+dmg` | `dmg_a/b` | `push` | `stand` | `ride` | `enter` | `dmg_a` | `dmg_a` |
| **TOOL_CARRIED** | `carry` | — | `swap` | `knock` | `knock` | `wake+knock` | `knock` | `knock` | `clack` | `clack` | `—` | `dmg_b` | `dmg_b` |
| **TOOL_PLACEMENT** | `grab` | `swap` | — | — | — | — | — | — | — | — | — | — | — |
| **OBJECTIVE** | `collect` | `knock` | — | — | `push` | `wake+push` | `push` | `push` | `rest` | `rest` | `fill` | `dmg_b` | `dmg_b` |
| **PROP_DYNAMIC** | `dmg_a/b` | `knock` | — | `push` | — | `wake+push` | `push` | `push` | `rest` | `rest` | — | `dmg_b` | `dmg_b` |
| **PROP_SLEEPING** | `wake+dmg` | `wake+knock` | — | `wake+push` | `wake+push` | — | `wake+push` | `wake+push` | `rest` | `rest` | — | `dmg_b` | `dmg_b` |
| **OBSTACLE_DYNAMIC** | `dmg_a/b` | `knock` | — | `push` | `push` | `wake+push` | — | `push` | `rest` | `rest` | — | `dmg_b` | `dmg_b` |
| **DECOR_DYNAMIC** | `push` | `knock` | — | `push` | `push` | `wake+push` | `push` | — | `rest` | `rest` | — | — | — |
| **TILE_STATIC** | `stand` | `clack` | — | `rest` | `rest` | `rest` | `rest` | `rest` | — | `stand` | — | — | — |
| **TILE_KINEMATIC** | `ride` | `clack` | — | `rest` | `rest` | `rest` | `rest` | `rest` | `stand` | — | — | — | — |
| **RIFT** | `enter` | — | — | `fill` | — | — | — | — | — | — | — | — | — |
| **HAZARD_STATIC** | `dmg_a` | `dmg_b` | — | `dmg_b` | `dmg_b` | `dmg_b` | `dmg_b` | — | — | — | — | — | — |
| **HAZARD_AREA** | `dmg_a` | `dmg_b` | — | `dmg_b` | `dmg_b` | `dmg_b` | `dmg_b` | — | — | — | — | — | — |

**규칙 코드 15종 정의**

| 코드 | 판정 조건 | 효과 |
|---|---|---|
| `carry` | `E` 눌림 + 도구 소켓 거리 ≤ 26px + 플레이어 빈손 | `TOOL_CARRIED.freeze = true`, 플레이어에 부착. `grab_cd = 0.18s` |
| `swap` | 도구를 들고 `E` + 소켓 거리 ≤ 26px | 들고 있던 도구를 그 자리에 두고(`freeze=false`, `linear_velocity=0`) 새 도구를 집는다. 들고 있던 게 없으면 아무 일도 없다 |
| `grab` | `TOOL_PLACEMENT`과 `E` 눌림 | 도구 생성, 배치점 소멸. 1개는 1개로 교체 |
| `collect` | 플레이어와 `OBJECTIVE` 접촉 | `objective_count += 1`, 알 소멸(파편 6), `collect_flash = 0.25s` |
| `fill` | `RIFT`와 `OBJECTIVE` 접촉 | 틈 충전 게이지 시각값만 +0.08. 개수는 안 오른다(중복 방지 아님 — 알이 이미 소멸하므로 1회) |
| `enter` | 플레이어와 `RIFT` 접촉 | `objective_count >= objective_needed`면 `LEVEL_CLEAR`. 아니면 아무 일도 없다 |
| `dmg_a` | 상대 법선 방향 상대속도 > 임계(§9) | A에 피해. A는 불가피 — 해처는 거부 불가 |
| `dmg_b` | 상대 법선 방향 상대속도 > 임계 | B에 피해. B가 `breakable`이고 hp ≤ 0이면 파괴. 파괴 시 파편 생성 |
| `wake` | B가 `PROP_SLEEPING` | `sleeping = false`, `wake_offset = 0.6s` 동안 접촉 상대에게 밀림(≈ 40 N·s) |
| `knock` | 도구 투척 중 상대속도 > 240 | 상대에 `impulse = 도구 linear_velocity * 0.6` 전달 |
| `push` | 일반 동적 접촉 | 없음(기본 물리) |
| `stand` | 플레이어가 `TILE_STATIC` 위에 접지 | 지면 상태. `coyote`/`jump_buffer` 갱신 |
| `ride` | `TILE_KINEMATIC`과 접촉 | 플랫폼 `linear_velocity`를 플레이어에 가산(캐리어). 지면 판정은 `TILE_STATIC` 우선 |
| `rest` | 정적/무거운 바디 접촉 | 없음 |
| `clack` | 도구가 벽에 부딪힘 | `clack_sound`, 상대속도 > 300이면 `dmg_b`도 함께 |

**파괴 시 파편 규칙:** 파편은 `DECOR_DYNAMIC`이며, 수명은 1.2s, 질량은 원래의 12%, 크기는 원래의 22~38%, 수명은 끝나면 `free()`된다. 파편은 저장을 하지 않는다.

### 4.6 결정 순서 (한 스텝에 여러 상호작용이 겹칠 때)

`systems/step_director.gd`가 **스텝마다** 이 순서를 지킨다. 순서가 바뀌면 같은 입력이 다른 결과가 나온다.

1. **입력 샘플** — `E`, `A`/`D`, `Space`, `R`를 이번 스텝 상태로 스냅샷. 게임 로직은 이 스냅샷만 본다.
2. **선행 검사** — `hitstop > 0`이면 3~11번을 건너뛴다. `frozen`이면 4~11번을 건너뛴다.
3. **플레이어 힘 적용** — 이동/점프/중력 스케일. `freeze` 상태가 아니고 죽지 않았을 때만.
4. **플레이어 구속** — `linear_velocity.y` 상한(-820), `rotation` 고정(플랫포머라 자전 없음), `rotation_lock` 유지.
5. **도구 부착/해제** — `carry`/`swap` 판정. 던지면 `freeze=false` + 투척 임펄스.
6. **Kinematic 발판 이동** — authored 궤적을 `delta`만큼 전진시키고 `sync_to_physics = true`로 밀어낸다.
7. **PhysicsServer2D 서브스텝** (§8.2). 접촉이 여기서 발생하고 `body_entered` 시그널이 쌓인다.
8. **시그널 수집** — `body_entered` / `body_shape_entered` / `area_entered` 를 호출 버퍼에 `Dictionary`로 쌓는다. 이 단계에서 아무 게임 상태도 바꾸지 않는다.
9. **접촉 버퍼 정렬** — §4.6.1 정렬키.
10. **상호작용 해석** — 정렬된 순서대로 `interaction_rules.resolve(entry, world_state)` 호출. 각각 `Dictionary{applied, events, sound}` 반환. `applied=true`면 버퍼에서 제거.
11. **데미지/사망 판정** — hp ≤ 0 처리. 오브젝트는 파괴, 플레이어는 `dead_pending`으로 전이.
12. **목표 판정** — `objective_count >= objective_needed`면 `RIFT` 상태 `open`, 그리고 플레이어가 안에 있으면 `LEVEL_CLEAR`.
13. **물리 후처리** — 총알 관통 카운터 기록(§4.1-3), `hitstop` 감소.
14. **프레임 끝 저장** — `hitstop`, `collect_flash`, `wake_offset` 타이머 감소.

#### 4.6.1 접촉 버퍼 정렬키

정렬은 **총동일, 결정론적**이다. `sort_custom`를 쓰지 않고 정수 키로 정렬한다.

```
key = (tier, kind_rank, body_index, entry_order)
```

- `tier`: 0 = `collect`/`fill`, 1 = `enter`, 2 = `carry`/`swap`/`grab`, 3 = `wake`, 4 = `dmg_a`, 5 = `dmg_b`/`knock`, 6 = `stand`/`ride`/`push`/`rest`/`clack`
- `kind_rank`: 알파벳 정렬 대신 `interaction_rules.RANK` 배열의 인덱스. 플레이어→0, 도구→1, 시간알→2, …
- `body_index`: 월드 바디 배열에서의 인덱스. 정적 바디가 동적 바디보다 먼저다(§4.6.2).
- `entry_order`: 시그널이 들어온 순서. 이것까지 같으면 완전히 동일하다.

#### 4.6.2 정적/동적 처리 순서 근거

Godot 2D 솔버는 바디를 접촉 유형별로 묶어 처리한다. **무게가 무거운 바디가 먼저 해석된다.** 그래서 `OBSTACLE_DYNAMIC(3.2)`는 `PAPER(0.30)`를 밀지 못한다. 이게 버그가 아니라 이 장르의 무게감이다. 저자들은 이걸 알고 질량을 배치한다.

### 4.7 이 장르 시스템의 불변식 (테스트 대상)

1. 같은 시드 + 같은 레벨 ID + 같은 변형 집합 → 300 스텝 후 모든 바디 위치/속도가 **1e-4 오차 안에서** 동일하다.
2. `objective_count`는 `OBJECTIVE` 바디 수보다 커질 수 없다.
3. `iron`/`void` 바디는 어떤 조건에서도 파괴되지 않는다.
4. `RIFT`를 수집하는 바디는 존재하지 않는다(장르적 자물쇠 금지).
5. `TOOL_PLACEMENT`은 `HAZARD_*`에 의해 파괴되지 않는다(픽업 소실 = 진행 불가 방지).
6. 어떤 레벨도 `pickable` 플래그를 `TOOL_*`에 가질 수 없다. **도구는 열쇠가 아니다.**
7. 모든 접촉이 `interaction_rules.TABLE`의 코드 하나로 해석된다. 미등록 접촉이 0건이다.
8. `hitstop` 중에는 물리 스텝이 진행되지 않는다.
9. 플레이어 hp는 0 미만으로 내려가지 않는다.
10. `PROP_SLEEPING`은 0.6초 이상 접촉 없으면 다시 잠든다(다시 잠드는 데 3.0s).

---

## 5. 원시 무작위 선택 시스템

### 5.1 무엇을 무작위로 만드는가

- **레벨 선택.** `content/levels/index.json`의 `levels` 배열에서 8번 균등 추출(중복 허용).
- **도구 선택.** `content/tools/index.json`의 `tools` 배열에서 8번 균등 추출(중복 허용).
- **변형 선택.** 각 레벨 슬롯마다 변형 세트를 추출(§5.4).

**무작위로 만들지 않는 것:** 레벨 본체, 도구 본체, 지형, 목표 위치, 스폰 위치, 물리 상수. 이것들은 전부 authored다. 이 경계를 넘는 코드가 생기면 즉시 `§18` 위반이다.

### 5.2 선택 알고리즘

```
rng = RandomNumberGenerator.new()
rng.seed = run_seed              # run_seed 는 0 이 될 수 없다(§5.7)

for i in 0..LEVEL_COUNT-1:                       # LEVEL_COUNT = 8
    idx      = rng.randi_range(0, levels.size() - 1)
    level_id = levels[idx]

    tools_idx = []
    for j in 0..TOOL_COUNT-1:                    # TOOL_COUNT = 8
        tools_idx.append(rng.randi_range(0, tools.size() - 1))

    mutations = []
    if rng.randf() < MUTATION_CHANCE:           # MUTATION_CHANCE = 0.62
        mutations.append(pick_mutation(rng, level.mutable))

mutations 를 cursor 순서로 2차원으로 만들어 run_state.sequence 에 저장
```

- `pick_mutation(rng, allowed)`: `allowed`가 비었으면 빈 배열을 반환. 아니면 `allowed[rng.randi_range(0, allowed.size()-1)]`를 1~2번 뽑되 **중복 없음**, 최대 `MUTATION_MAX = 2`개.
- `run_state.tools`는 레벨 슬롯마다 하나씩, 총 8개. **레벨 i에 배정되는 도구는 `tools[i]`.** 8개 런을 6개 도구로 채우므로 중복은 수학적으로 확정이다(§5.5).
- `MUTATION_CHANCE = 0.62`는 authored 레벨이 `mutable: []`면 아무 효과가 없다. 빈 목록인 레벨에서는 이 굴림이 일어나도 결과는 `[]`다.

**금지 코드(테스트로 강제):** `if idx == last_idx: idx = ...`, `if counts[level_id] > 2: ...`, `weights`, `shuffle`, `pick_unique`, `ensure_diversity`. `interaction_rules.gd`에 있는 `if`가 아니라 **`selector.gd` 전체를** 텍스트 스캔하는 테스트를 쓴다.

### 5.3 변형 오퍼레이션 6종

`systems/mutation.gd`. 각 오퍼레이션은 `(rng, level_dict) -> Dictionary`이며 **레벨의 어떤 값을 어떻게 바꾸는지**가 전부 코드에 적혀 있다.

| `op` | 인자 | 효과 | 적용 제한 |
|---|---|---|---|
| `gravity_scale` | `0.70` 또는 `1.45` | 레벨 내 모든 `RigidBody2D.gravity_scale` 을 `base * arg` 로. `TILE_*`은 불변 | 모든 레벨 |
| `material_swap` | 다른 재료 1종 | authored 배열 `shuffled`가 비어 있지 않을 때, 그 안의 **첫 번째** 바디의 재료를 교체 | `shuffled` 배열이 있는 레벨만 |
| `prop_size` | `0.78` 또는 `1.30` | `PROP_*`/`DECOR_*`/`OBSTACLE_DYNAMIC`의 collision shape와 스프라이트를 `base * arg` 로. mass는 그대로 (밀도 상승) | 해당 종류가 1개 이상인 레벨 |
| `prop_offset` | `-56.0` 또는 `+56.0` px | `bounds` 안에서 위 세 종류의 모든 바디를 `x += arg`, 단 `bounds`를 넘으면 반사 | 해당 종류가 1개 이상인 레벨 |
| `wind` | `-190.0` 또는 `+190.0` px/s² | `TILE_KINEMATIC`의 선형 속도에 `x` 성분을 더함(무한 래핑 없음, 궤적 끝에서 0으로 램프) | `TILE_KINEMATIC`이 1개 이상인 레벨 |
| `hazard_shift` | `0` 또는 `1` | `mutable_hazards` 배열의 모든 `HAZARD_*`를 1번 인덱스만큼 순환 이동(배열이 1개면 변화 없음) | `mutable_hazards`가 2개 이상인 레벨 |

**절대 변형하지 않는 것** (코드에도 분기가 없다): `TILE_STATIC`의 위치/크기, `TILE_KINEMATIC`의 authored 궤적 자체, `RIFT` 위치, `spawn` 위치, `TOOL_PLACEMENT` 위치, `objective_needed`, `bounds`, `parallax_seed`. 플레이어가 적응할 수 있는 지형은 손대지 않는다. 손대는 건 그 위의 물체와 물리 계수뿐이다.

**레벨이 거부하는 경우:** `mutable`에 위 6종에 없는 문자열이 있으면 `level_loader`가 그 레벨을 로드 실패로 버린다. `tests/core/test_ppp_mutation.gd`가 이를 검증한다.

### 5.4 변형의 결정 시점과 적용 시점

- **결정:** 런 시작 시 `pick_mutation` 안에서 `rng`로 확정되어 `run_state.sequence[i].mutations`에 저장된다.
- **적용:** `LevelFactory.build(run_state, cursor, cosmetic_rng)`가 레벨을 **로드하는 순간**에 한 번 적용한다. `enter_level`에서.

**왜 적용이 아니라 저장인가:** 로드/리셋이 몇 번 일어나도 같은 레벨은 같은 변형으로 다시 만들어져야 한다. 저장이 변형된 레벨이 아니라 **변형 지시**를 담아야 리셋이 결정론적이다.

### 5.5 중복 억제 없음의 결과와 그것을 견디는 설계

- `LEVEL_COUNT = 8`, 등록 레벨 9개. 생일 역설로 8번 뽑으면 **중복 확률 68.2%**가 최소 한 번 나타난다. `lvl_chalk_shelf`가 3번 나오는 것도 정상이다.
- 도구는 8개를 6종에서 뽑으니 **중복 확률 100%**. `tool_ember_lash`가 4번 나올 수 있다.
- 한 번의 런에서 플레이어가 보는 서로 다른 레벨 수는 기댓값 5.05개, 최악 1개다. **9개 전부를 못 볼 수 있는 것이 정상 상태다.**

이걸 견디는 장치는 4개뿐이다. **모두 pity가 아니다.**

1. **레벨 물리는 재시작해도 같다.** 변형은 결정론이므로 같은 레벨을 두 번 보면 같은 퍼즐이다. 두 번째는 "아 저거구나"를 5초 만에 확인하는 시간이다.
2. **도구는 매번 다르다.** `tool_ember_lash` 4번이 나와도 그 도구로 뭘 할 수 있는지는 매번 같다 → **겉으로는 반복, 속으로는 다른 퍼즐.** 3번은 리듬이다. " Fun things happen more often if you don't force them" 가 정확히 이 지점의 근거다(확인 A7).
3. **플레이어가 손댈 수 있는 게 많다.** 도구 6종 × 물리 상호작용 13종. 같은 레벨도 "이번엔 진흙을 파서 굴린다"가 새로 보인다.
4. **런 8레벨은 10~13분이면 끝난다.** "전부 못 본다"의 슬픔이 12분짜리 짧은 런에서는 축적되지 않는다.

### 5.6 seed · 상태 관측값 · presentation

- **`run_state.levels_seen`**는 `{level_id: 횟수}` 딕셔너리다. **읽는 곳이 없다.** 진행 화면·리롤 판단·밸런스 판정에 쓰지 않는다. 저장과 `run_complete` 리포트에만 존재한다. `selector.gd`가 이 딕셔너리를 참조하지 않는 것을 테스트가 검증한다.
- **`run_state.tools_seen`**도 같다. 같은 규칙.
- **`sequence_cursor`**는 현재 레벨 인덱스. `run_complete`면 `LEVEL_COUNT`.
- **`run_index`**는 새 런을 시작할 때마다 +1. 세이브 스킵에 쓰이지 않는다. `requested(&"portal", {"exit": "forward"})` payload의 `run_index`로만 보고한다.
- **`objective_total`**은 이번 런의 총 필요 개수 합. 런 화면에 숫자로 안 보인다(§11.4)지만 결과 리포트 payload에는 넣는다.

### 5.7 저장·로드에서의 시드

- `run_seed`는 `int`이며 **1 이상 `2^31-1` 이하**로 정규화한다. 0은 "미배정" 센티널로 예약한다.
- 로드 시 검증: `run_seed`가 범위 밖이거나 `sequence`가 8칸이 아니면 `sequence` 전체를 버리고 **새 시드로 처음부터 다시 뽑는다.** 부분 복구는 하지 않는다. 이유: 절반만 복구하면 그 뒤 레벨이 "정해진 런"이 아니라 무작위가 되어 저장 계약이 흐려진다.
- `sequence[i].level_id`가 현재 `index.json`에 없으면 그 슬롯만 새 인덱스로 **재추첨**한다(§16 테스트 `test_selector_reassigns_removed_level`).
- 로드 시 **`sequence`의 contents는 절대 재작성하지 않는다.** 바뀔 수 있는 건 위 두 경우뿐이다.
- 로드 후 `cursor < LEVEL_COUNT`면 해당 cursor의 레벨을 **다시 빌드**한다. 바디 위치는 저장값이 우선이다(§14.3).

### 5.8 presentation RNG 분리

`cosmetic_rng`는 `run_seed`에서 파생한다.

```
cosmetic_rng.seed = (run_seed * 2654435761 + 1013904223) & 0x7FFFFFFF
```

- 쓰임: 파편 스핀, 배경 요소 생성, 파티클 좌표, 색 jitter, 스쿼시 위상 오프셋.
- 금지: 선택, 변형 결정, 물리 상수. 이걸 어기면 스크린샷이 매 프레임 달라져 버그 재현이 안 된다.
- 테스트 `test_selector_ignores_cosmetic_rng`가 `cosmetic_rng`를 1000번 소비해도 `sequence`가 1바이트도 안 바뀌는 것을 검증한다.

---

## 6. 파일 목록 — `modules/physics_puzzle_platformer/**`

모든 경로는 `modules/physics_puzzle_platformer/` 기준. **이 목록에 없는 파일을 만들지 않는다.** `§6.2` 이후의 파일이 필요해지면 여기 먼저 고친다.

### 6.1 런타임 필수 파일

| 파일 | 종류 | 한 줄 목적 |
|---|---|---|
| `entry.tscn` | 씬 | 앱이 인스턴스하는 진입 씬. `Node2D` 루트 + `World`(Node2D) + `Camera2D` + `BubbleOverlay`(Control) + `AudioSink`(Node). 여기서 게임플레이를 시작하지 않는다. |
| `module.gd` | `GameModule` | 모듈 계약 구현. 진입 시 월드 1회 구성, 프레임마다 `StepDirector` 호출, 저장/복구, `requested` 방출, `Esc`를 `menu`로 중계. |
| `module_manifest.tres` | Resource | `ModuleManifest`. `id = &"physics_puzzle_platformer"`, `save_version = 3`, `input_actions` 목록(§13.1). |
| `audio_manifest.gd` | 스크립트(static) | W3가 제공하는 이벤트 표 형태에 이 Kit의 17개 이벤트를 선언. `CORE_AUDIO.register_manifest(...)`가 아니라 순수 데이터. 재생은 `W3_AUDIO_Player`. |
| `domain/body_kind.gd` | 스크립트(static) | 13종 바디 종류의 열거와 속성 테이블(hp, damageable, breakable, objective, sensor, solid, pull_scale). |
| `domain/material_table.gd` | 스크립트(static) | 9종 재료의 `friction`/`bounce`/`density`/`absorb`/`ink`/`damage_scale`/`debris_count` 테이블. `PhysicsMaterial` 팩토리 포함. |
| `domain/interaction_rules.gd` | 스크립트(static) | §4.5의 13×13 `TABLE`과 15종 규칙 코드. `resolve()`는 순수 함수 — `body_kind`, `material_table`, authored spec, `world_state`만 읽고 결과를 새 `Dictionary`로 반환한다. 노드에 손대지 않는다. |
| `domain/level_spec.gd` | RefCounted | 파싱된 레벨의 불변 데이터: `id`, `spawn`, `rift`, `bounds`, `parallax_seed`, `bodies[]`(authored 원본), `kinematics[]`, `mutable`, `mutable_hazards`. |
| `domain/body_spec.gd` | RefCounted | 바디 1개의 authored 정본: `id`, `kind`, `shape`, `size`, `points`, `material`, `pos`, `angle`, `hp`, `breakable`, `t_max`, `friction_override`, `bounce_override`, `tool`. `to_physics_body()`를 갖지 않는다. |
| `domain/tool_spec.gd` | RefCounted | 도구 1개의 authored 정본: `id`, `name`, `use`, `body`, `mass`, `friction`, `bounce`, `cooldown`, `trail`, 그리고 `use`별 1개 필드(`impulse_scale` / `reach` + `arc_deg` / `radius` + `duration`) + `fire_linger`. `validate()`가 `§10.4`를 강제한다. |
| `domain/world_state.gd` | RefCounted | 런타임 세계 상태. 바디별 위치/선속도/각속도/슬립/체력/파괴 플래그, `objective_count`, `objective_needed`, `phase`, `run_seed`, `cursor`, `run_index`, `elapsed`, `deaths`, `resets`, `hitstop`, `player_hp`. **프레젠테이션 상태를 갖지 않는다.** |
| `domain/run_state.gd` | RefCounted | 8-슬롯 런 시퀀스, 레벨·도구 인덱스, 관측 카운터. `select_sequence()`를 호출해 처음 한 번만 채운다. |
| `domain/save_codec.gd` | 스크립트(static) | `WorldState` ↔ JSON-safe `Dictionary` 변환, 스키마 버전 1~3 마이그레이션, 잘못된 값 정규화. NaN/Inf/Node/Resource를 절대 넣지 않는다. |
| `domain/axis_view.gd` | RefCounted | `context.arrival["worldstate"]`의 **읽기 전용 참조**만 보관하고 `body`/`creature`/`place` 세 축의 읽기 accessor만 제공한다. 복사·기본값 생성·쓰기 경로를 갖지 않는다(§14.8.2). |
| `domain/body_mass.gd` | 스크립트(static) | `PART_MASS` 표(상체 4개 부위 값)와 `player_mass()`/`player_reach_radius()` 두 순수 함수. `body.missing`을 **있는 그대로** 읽어 `player_mass`와 `carry` 반경을 산출한다(§14.8.4). 단위 변환·정규화 없음. |
| `systems/step_director.gd` | RefCounted | 프레임 처리 순서(§4.6)의 14단계를 실행하고 `hitstop`/페이즈 전이를 소유한다. |
| `systems/contact_buffer.gd` | RefCounted | 물리 시그널을 쌓고 §4.6.1 정렬키로 정렬해 돌려준다. |
| `systems/selector.gd` | RefCounted | §5.2의 시퀀스 생성, §5.7의 로드 시 재추첨. |
| `systems/mutation.gd` | RefCounted | §5.3의 6종 오퍼레이션. `apply(level_spec, mutations) -> LevelSpec`(변형본). |
| `systems/level_factory.gd` | RefCounted | `LevelSpec` + `mutations` + `cosmetic_rng` → 바디 노드 트리 + `WorldState`. 후처리(파편 풀, 오디오 연결, 물리 재질)도 여기서. |
| `systems/kinematics.gd` | RefCounted | `TILE_KINEMATIC` authored 궤적 진행과 램프(§5.3 `wind`). |
| `systems/objective_tracker.gd` | RefCounted | 시간알 획득, 틈 충전/개방, 레벨 클리어 판정, 런 완료 판정. |
| `systems/tool_holder.gd` | RefCounted | `E` 키의 잡기/놓기/던지기 판정, 도구 부착, 쿨다운 0.22s, 도구별 파괴. |
| `systems/damage.gd` | RefCounted | 접촉 상대속도 → 데미지, 파괴, 히트스톱 0.055s, 파편 생성. |
| `systems/save_service.gd` | RefCounted | 저장 스냅샷 생성/복원, 마이그레이션 체인, 복구 후 재구성. |
| `systems/axis_mutation.gd` | RefCounted | `request_mutation(axis, patch)` 호출 래퍼와 **거부 처리** 1개. 거부를 조용히 삼키되 `WorldState`를 한 필드도 바꾸지 않고 `StepDirector` 단계를 중단하지 않는다(§14.8.3). |
| `presentation/game_screen.gd` | Control | 화면 루트. 풀사이즈 `ColorRect` 배경 + `Control` 오버레이만. **상시 HUD 없음.** `LevelTitle` 자식은 전환 중에만 0.9초 보인다. |
| `presentation/world_root.gd` | Node2D | 월드 좌표계. 카메라 추종, 셰이크, 줌 고정(1.0). |
| `presentation/parallax_root.gd` | Node2D | 3개 레이어(far/near/fore) + 각 레이어의 이동·스쿼시. `core/procedural` 사용. |
| `presentation/parallax_layer.gd` | Node2D | 레이어 1개. 절차적 도형 생성 + `Spring` 스프링으로 말랑말랑. |
| `presentation/backdrop_dynamics.gd` | RefCounted | 배경이 물리 요구에 반응(§11.3). `core/procedural/anim/backdrop_dynamics.gd`를 감싼다. |
| `presentation/body_view.gd` | Node2D | 바디 1개 표시. 스프라이트 없음 — `core/procedural`로 만든 텍스처 + 스쿼시 스케일. |
| `presentation/procedural_bridge.gd` | 스크립트(static) | `core/procedural/` C1 스텁과 이 Kit의 호출 사이 유일한 어댑터. `domain/`·`systems/`는 이 파일도 모른다. W2 시그니처가 달라도 여기서 맞춘다. |
| `presentation/trail_renderer.gd` | Node2D | 던진 도구가 남기는 궤적 줄. 화면 정보가 아니라 물리 가독성 보조. 최대 24점, 0.35s 페이드. |
| `presentation/level_title.gd` | Control | 전환 중에만 보이는 레벨 이름 카드. 카운터·목표 수는 쓰지 않는다. |
| `presentation/bubble_overlay.gd` | Control | `first_entry`와 **동일한 API 이름**(`get_input_bubble_state`, `get_bubble_state`, `get_bubble_cell`, `set_key_profile`)과 4상태(`intact/popped/rising/restoring`)로 Input Bubble. 이동하는 격자 위에서 방울이 오르고 키를 누르면 터진다. |
| `presentation/audio_sink.gd` | Node | `audio_manifest.gd`의 이벤트를 `AudioStreamPlayer` 풀에 재생. W3 플레이어가 없을 때 조용히 no-op. |
| `presentation/dev_probe.tscn` | 씬 | `res://`에서 실행하는 개발 하네스. **게임에서 진입 불가.** 콘텐츠 검증용. |
| `presentation/dev_probe.gd` | 스크립트 | authored 레벨/도구 JSON 전수 로드, 상호작용 행렬 카운트, 총알 통과 통계 출력. |

### 6.2 콘텐츠 파일

> **[제작 전용]** 아래 표의 한국어 이름은 authored 정본의 표기다. 도구 이름 7개는 **디버그/리포트 전용**이고(§10.4 `name` 필드), 화면에는 나가지 않는다(§11.5). 레벨 `name` 9개는 유일하게 화면에 나가는 문자열이며 값은 §11.9가 정한다.

| 파일 | 종류 | 한 줄 목적 |
|---|---|---|
| `content/levels/index.json` | JSON | 등록 레벨 ID 배열 + `schema`. 로더는 **이 배열만** 본다. |
| `content/levels/lvl_chalk_shelf.json` | JSON | 레벨 1. 직선 바닥 + 판자 + 시간알 2. 이동·점프 학습. |
| `content/levels/lvl_rolling_coin.json` | JSON | 레벨 2. 철 구슬을 굴려야 도달하는 고지대. 데미지 해처. |
| `content/levels/lvl_glass_gallery.json` | JSON | 레벨 3. 유리와 잠든 물체. 변형 4종 허용. |
| `content/levels/lvl_lifting_slab.json` | JSON | 레벨 4. 키네마틱 발판 2개 + 근접 상호작용. |
| `content/levels/lvl_wind_ledger.json` | JSON | 레벨 5. `wind` 변형 효과가 가장 크게 체감되는 레벨. |
| `content/levels/lvl_slippery_ink.json` | JSON | 레벨 6. 마찰이 낮은 재료 위에서 관성 제어. `material_swap` 변형. |
| `content/levels/lvl_broken_teeth.json` | JSON | 레벨 7. 무너지는 중력 스택. `gravity_scale` 변형. |
| `content/levels/lvl_hollow_keyhole.json` | JSON | 레벨 8. 6종 상호작용이 전부 나오는 마지막 레벨. |
| `content/tools/index.json` | JSON | 등록 도구 ID 배열. |
| `content/tools/tool_paper_fan.json` | JSON | 도구 1. 밀어내기(shove). 마찰 계수를 바꾼다. |
| `content/tools/tool_ember_lash.json` | JSON | 도구 2. 던지기(throw). 불타는 채로 굴러간다. |
| `content/tools/tool_glass_rod.json` | JSON | 도구 3. 던지기 + 짧은 사거리. 부서짐. |
| `content/tools/tool_lead_weight.json` | JSON | 도구 4. 던지기 + 무거움. 발판을 떨군다. |
| `content/tools/tool_rope_hook.json` | JSON | 도구 5. 고리 걸기(anchor_line). 물리 조인트. |
| `content/tools/tool_chill_jar.json` | JSON | 도구 6. 냉각장(cool_field). 다리·오브젝트를 0.7초 정지. |
| `content/levels/lvl_clockwork_bell.json` | JSON | 레벨 9. **증명용.** 마지막에 추가해서 core 무수정을 보인다(§15.4). |
| `content/tools/tool_moth_wing.json` | JSON | 도구 7. **증명용.** 위와 동시 추가. |
| `audio/README.md` | 문서 | W3가 여기에 렌더한 wav를 넣는다. Kit은 manifest만 선언. |

**콘텐츠 추가 절차 (core 무수정):** JSON 1개 추가 → `index.json`의 배열에 ID 1줄 추가. 그게 전부다. 파서·로더·물리·저장·선택기 중 무엇도 고치지 않는다. §15.4가 이를 증명한다.

### 6.3 축 인계 파일 (공유 상태)

`§6.1`의 경로 규칙("모든 경로는 `modules/physics_puzzle_platformer/` 기준")에 대한 **명시적 예외 1개**를 둔다. 축 인계 테스트는 `tests/core/` 아래에 있어야 한다(`§16`의 규칙). 이 예외 외에 폴더를 바꾸지 않는다.

| 파일 | 종류 | 한 줄 목적 |
|---|---|---|
| `domain/axis_view.gd` | RefCounted | `arrival`의 축 뷰를 참조로만 보유. `body`/`creature`/`place` 접근자 외에 쓰기·변환·기본값 생성 메서드가 없다. |
| `domain/body_mass.gd` | 스크립트(static) | `body.missing` → `player_mass`/`player_reach_radius` 2개 순수 함수와 `PART_MASS` 표. 축 값 정규화 금지의 실행 지점. |
| `systems/axis_mutation.gd` | RefCounted | 쓰기 요청 1개 경로와 거부 처리. 이 Kit이 소유한 축은 없다. |
| `tests/core/test_ppp_axis_handover.gd` | GUT | §14.8 전체(인계·정규화 금지·거부·부재 물리·창작 경로)를 단언한다. §16.1 표와 1:1 대응. |

---

## 7. Domain / State 데이터 모델

### 7.1 `RunState` (런 단위, 8 슬롯)

`domain/run_state.gd`. `RefCounted`.

| 필드 | 타입 | 기본값 | 의미 |
|---|---|---|---|
| `run_seed` | `int` | `0` | 이 런의 시드. `0` = 미배정. 실제 사용 시 `1..2^31-1`. |
| `run_index` | `int` | `0` | 런이 시작된 횟수. 보고용. |
| `sequence` | `Array[Dictionary]` | `[]` | 길이 8. 각 원소 `{"level_id": String, "mutations": Array[Dictionary]}` (§7.5). |
| `cursor` | `int` | `0` | 현재 진행 중(또는 다음에 로드할) 슬롯 인덱스. `8` = 런 완료. |
| `tool_ids` | `Array[String]` | `[]` | 길이 8. 슬롯 i에 배정된 도구 ID. |
| `levels_seen` | `Dictionary` | `{}` | `{level_id: 등장 횟수}`. **판정에 절대 쓰지 않는다.** |
| `tools_seen` | `Dictionary` | `{}` | `{tool_id: 등장 횟수}`. **판정에 절대 쓰지 않는다.** |
| `total_objectives` | `int` | `0` | 이번 런의 `objective_needed` 총합. 리포트용. |
| `completed_levels` | `Array[int]` | `[]` | 클리어한 슬롯 인덱스. |
| `run_complete` | `bool` | `false` | |

### 7.2 `WorldState` (레벨 단위)

`domain/world_state.gd`. `RefCounted`. **프레젠테이션 상태(카메라, 스쿼시 위상, 트레일 점, 셰이크)는 여기 없다.** 그건 `presentation/`에 있다.

| 필드 | 타입 | 기본값 | 의미 |
|---|---|---|---|
| `level_id` | `String` | `""` | 현재 로드된 레벨 ID. |
| `applied_mutations` | `Array[Dictionary]` | `[]` | 이 레벨에 실제로 적용된 변형 (§7.5). |
| `objective_count` | `int` | `0` | 획득한 시간알 수. |
| `objective_needed` | `int` | `2` | 클리어에 필요한 수. `1..12`. |
| `phase` | `StringName` | `&"intro"` | `intro` → `play` → `clear` / `dead` (§7.4). |
| `phase_time` | `float` | `0.0` | 현재 페이즈 진입 후 경과 초. 페이즈 전환 애니메이션 판정에만 사용. 진행 의미 없음 → **저장하지 않는다.** |
| `player_hp` | `int` | `5` | 0이면 `dead`. |
| `deaths` | `int` | `0` | 런 전체 사망 횟수. |
| `resets` | `int` | `0` | 런 전체 리셋 횟수. |
| `elapsed` | `float` | `0.0` | 이 레벨에서 play 상태로 보낸 시간(초). |
| `tools_used` | `int` | `0` | 도구 사용 횟수. 리포트용. |
| `hitstop` | `float` | `0.0` | 남은 히트스톱 초. |
| `debris` | `Array[Dictionary]` | `[]` | 활성 파편. `{x, y, vx, vy, life, size, material, spin}` 전부 JSON-safe. |
| `bodies` | `Array[BodyRuntime]` | `[]` | 아래 §7.3. |

### 7.3 `BodyRuntime` (바디 1개)

`domain/body_spec.gd`에 `BodyRuntime` 클래스를 함께 둔다(순수 데이터, 노드 아님).

| 필드 | 타입 | 기본값 | 의미 |
|---|---|---|---|
| `spec_id` | `String` | `""` | authored 바디 ID. 안정 ID. 저장의 키. |
| `kind` | `int` | `BODY_KIND.PROP_DYNAMIC` | `body_kind.gd` 열거. |
| `x` `y` | `float` | `0.0` | 중심 좌표(월드). |
| `angle` | `float` | `0.0` | 회전(rad). |
| `vx` `vy` | `float` | `0.0` | 선속도(px/s). |
| `av` | `float` | `0.0` | 각속도(rad/s). |
| `sleeping` | `bool` | `false` | 현재 수면 상태. `PROP_SLEEPING`만 참이 될 수 있다. |
| `hp` | `float` | `3.0` | 내구. `≤0`이면 파괴. |
| `destroyed` | `bool` | `false` | 파괴 확정 플래그. 파편 스폰이 아직 안 끝났을 수 있음. |
| `t` | `float` | `0.0` | 이 레벨에서 살아 있던 시간. 시한 폭발·행동 전환용. authored 바디만 가진다. |
| `held` | `bool` | `false` | 도구가 손에 들려 있는가. `TOOL_CARRIED`만. |
| `tool_id` | `String` | `""` | 도구 정의 ID. |
| `tool_cooldown` | `float` | `0.0` | 남은 쿨다운 초. |
| `frozen` | `bool` | `false` | `tool_chill_jar` 등으로 정지. |
| `contact_flash` | `float` | `0.0` | 접촉 하이라이트 잔여 시간. **프레젠테이션 전용. 저장하지 않는다.** |
| `trail` | `Array[Vector2]` | `[]` | 도구 궤적. **프레젠테이션 전용. 저장하지 않는다.** |

### 7.4 페이즈 그래프

```
        ┌──────── load_state() / new run
        ▼
     ┌──────┐  0.9s 후 자동
     │ intro│  (전환 페이드. 입력 무시)
     └──┬───┘
        │ Space 또는 아무 키
        ▼
  ┌─────────┐  hp ≤ 0        ┌──────┐
  │   play  │───────────────▶│ dead │ 0.6s 후
  └──┬───┬──┘                └───┬──┘
     │   │ objective_needed 달성  │ 자동 복귀
     │   │ + RIFT 내부 진입      └────▶ play (hp=5, bodies=레벨 재구성)
     │   ▼
     │ ┌────────┐  0.9s 후
     │ │ clear  │──────────────▶ 다음 슬롯 로드 → intro
     │ └────────┘
     └──▶ R (리셋) ──▶ bodies 재구성, resets += 1, 같은 슬롯 intro
```

- `intro`는 입력 완전 차단 상태다. `context.input_enabled`를 직접 만지지 않고, `module.gd`의 `_can_input()`이 `phase == &"play"`일 때만 참을 반환한다.
- `dead`에서 `R`로 즉시 복귀할 수 있다(0.6s 대기 중).
- `clear`에서 `R`은 무시된다.

### 7.5 `applied_mutations` 원소

```json
{ "op": "gravity_scale", "arg": 0.7 }
```

`op`은 6종 중 하나, `arg`는 `float` 또는 `int`(`prop_size`는 float, `hazard_shift`는 int, 나머지 float). 저장에 그대로 실린다.

### 7.6 저장 스키마 (실제 JSON 예시)

`module_manifest.tres`의 `save_version = 3`이 현재 스키마 버전이다. `save_state()`가 반환하는 완전한 형태:

```json
{
  "schema": 3,
  "module": "physics_puzzle_platformer",
  "run": {
    "run_seed": 418324771,
    "run_index": 3,
    "cursor": 2,
    "run_complete": false,
    "total_objectives": 13,
    "sequence": [
      { "level_id": "lvl_glass_gallery", "mutations": [{ "op": "prop_size", "arg": 1.3 }] },
      { "level_id": "lvl_chalk_shelf",  "mutations": [{ "op": "wind", "arg": -190.0 }] },
      { "level_id": "lvl_rolling_coin", "mutations": [] },
      { "level_id": "lvl_lifting_slab", "mutations": [{ "op": "gravity_scale", "arg": 0.7 }, { "op": "prop_offset", "arg": 56.0 }] },
      { "level_id": "lvl_glass_gallery","mutations": [] },
      { "level_id": "lvl_slippery_ink", "mutations": [] },
      { "level_id": "lvl_hollow_keyhole","mutations": [{ "op": "material_swap", "arg": 1 }] },
      { "level_id": "lvl_chalk_shelf",  "mutations": [] }
    ],
    "tool_ids": [
      "tool_glass_rod", "tool_paper_fan", "tool_lead_weight", "tool_glass_rod",
      "tool_ember_lash", "tool_glass_rod", "tool_rope_hook", "tool_glass_rod"
    ],
    "levels_seen": { "lvl_chalk_shelf": 2, "lvl_glass_gallery": 2, "lvl_lifting_slab": 1, "lvl_rolling_coin": 1, "lvl_slippery_ink": 1, "lvl_hollow_keyhole": 1 },
    "tools_seen": { "tool_glass_rod": 4, "tool_paper_fan": 1, "tool_lead_weight": 1, "tool_ember_lash": 1, "tool_rope_hook": 1 },
    "completed_levels": [0, 1]
  },
  "world": {
    "level_id": "lvl_rolling_coin",
    "applied_mutations": [],
    "phase": "play",
    "objective_count": 1,
    "objective_needed": 2,
    "player_hp": 3,
    "deaths": 1,
    "resets": 2,
    "elapsed": 41.83,
    "tools_used": 6,
    "hitstop": 0.0,
    "debris": [
      { "x": 512.0, "y": 300.0, "vx": -40.0, "vy": -120.0, "life": 0.8, "size": 6.0, "material": "glass", "spin": 3.0 }
    ],
    "bodies": [
      { "spec_id": "player",       "kind": 1,  "x": 214.5,  "y": 402.0,  "angle": 0.0,   "vx": 0.0,    "vy": 0.0,    "av": 0.0, "sleeping": false, "hp": 3.0, "destroyed": false, "t": 41.83, "held": true,  "tool_id": "tool_glass_rod", "tool_cooldown": 0.0,  "frozen": false },
      { "spec_id": "iron_ball",    "kind": 7,  "x": 688.0,  "y": 388.0,  "angle": 1.2,   "vx": 96.0,   "vy": 0.0,    "av": -2.4, "sleeping": false, "hp": 6.0, "destroyed": false, "t": 41.83, "held": false, "tool_id": "",                   "tool_cooldown": 0.0,  "frozen": false },
      { "spec_id": "crate_a",      "kind": 5,  "x": 402.0,  "y": 356.0,  "angle": 0.0,   "vx": 0.0,    "vy": 0.0,    "av": 0.0, "sleeping": true,  "hp": 3.0, "destroyed": false, "t": 41.83, "held": false, "tool_id": "",                   "tool_cooldown": 0.0,  "frozen": false }
    ]
  }
}
```

**저장 규칙:**

- `Vector2`는 저장하지 않는다. `{x, y}` 두 값으로 평탄화한다(`MODULE_CONTRACT` 금지 항목).
- `NaN`/`Inf`는 저장 전에 `0.0`으로 대체하고 그 바디를 파괴로 표시한다. `save_codec`가 `is_finite()` 검사 후에만 넣는다.
- `int`/`float` 구분이 살아야 한다. `kind`는 열거값 정수, `hp`는 float.
- 바디 배열에는 **플레이어 1개 + 도구 1개(들고 있으면) + authored 바디 전부**가 들어간다. despawn/restoration 중인 바디는 넣지 않고, `objective_needed`는 그대로 둔다(아래 §14.4).
- `contact_flash`, `trail`, `phase_time`, 카메라, 스쿼시 위상은 **저장하지 않는다.**
- 플레이어와 도구만 `held`가 참일 수 있다. 저장 시 이 불변식을 검증하고 위반 시 도구를 분리한다.

### 7.7 잘못된/낡은 상태 처리

| 상황 | 처리 |
|---|---|
| `run_seed`가 0이거나 범위 밖 | `sequence`를 전부 버리고 새로 뽑는다 (§5.7). |
| `sequence` 길이가 8이 아님 | 위와 동일. |
| `sequence[i].level_id`가 `index.json`에 없음 | 그 슬롯만 재추첨. 나머지는 유지. |
| `applied_mutations`의 `op`이 6종 외 | 무시하고 그 변형만 버린다. 레벨 자체는 계속 로드. |
| `world.level_id`가 현재 슬롯의 ID와 다름 | `world` 전체를 버린다. 슬롯에 맞춰 레벨을 새로 빌드한다. |
| `bodies`의 `spec_id`가 현재 레벨에 없음 | 그 바디를 버린다. 나머지는 복원. |
| `bodies`에 플레이어가 없거나 2개 이상 | 첫 번째를 남기고 나머지를 버린다. |
| `objective_count > objective_needed` | `objective_needed`로 클램프한다. |
| `phase`가 알 수 없는 문자열 | `&"intro"`로 폴백. |
| `hitstop`가 0보다 큼 | `0.055`로 클램프. |
| `debris` 항목에 NaN | 항목 전체를 버린다. |
| `tool_id`가 `index.json`에 없음 | 도구를 `destroyed` 처리하고 그 슬롯에 `tool_ids[cursor]`로 재지정한다. |
| 스키마 버전 1, 2 | `migrate_save()`가 순차 변환(§14.5). |

### 7.8 공유 축 — 읽기 전용 입력

`body` / `creature` / `place` 세 축은 이 Kit의 **입력**이지 상태가 아니다. 이 Kit은 세 축 중 **어느 것도 소유하지 않는다.** 이 절은 축이 어떤 모양으로 들어오고 어떤 모양으로만 나가는지 고정한다. §14.8가 같은 사물의 런타임 규칙이다.

### 7.8.1 축 → 물리 도착 지점

| 축 | 읽는 필드 | 이 Kit의 물리 도착 지점 | 정규화 |
|---|---|---|---|
| `body` | `missing[].part` | `player_mass`와 `carry` 반경(§14.8.4) | **없음.** `PART_MASS`에 없는 `part`는 기여 `0`으로 두고 값을 지어내지 않는다 |
| `body` | `scale` | 플레이어 `CapsuleShape2D`의 `PLAYER_W`/`PLAYER_H`와 면적 비례 질량(§14.8.5) | **없음.** `0.62`는 `0.62`로 들어가고 `0.7`로 당겨지지 않는다 |
| `body` | `wounds[]` | `place.requires_body`와 대조하는 읽기 전용 값 | **없음.** `severity`를 능력 수치로 변환하지 않는다 |
| `creature` | `id`, `state`, `den`, `memory` | 레벨 표면 배치 판단(§14.8.6) | **없음.** `memory`는 점수로 세지 않는다 |
| `place` | `id`, `tags`, `requires_body` | 장소 식별, 레벨 짝짓기, `objective_needed` 상향(§14.8.5) | **없음.** 조건 미달을 권한 실패로 쓰지 않는다 |

**`place` 축은 지형 데이터를 갖고 있지 않다**(`core/worldstate/DESIGN_DECISION.md` §2.3). 이 Kit이 그리는 지형은 `content/levels/*.json`의 `LevelSpec`에서 온다. 따라서 `place.id`는 이 Kit의 레벨과 **짝을 이루는 키**일 뿐 지형 원본이 아니다. 공유 지형 원본이 어디에 있는지(어느 폴더·어느 스키마)는 **아직 미결**이다(§20 OQ10).

### 7.8.2 `arrival`로 들어오는 축 뷰 (실제 JSON 예시)

`enter(context)` 시점에 `context.arrival["worldstate"]`로 전달되는 **참조**다. 값 복사가 아니다(설계 §3). 이 Kit은 이 `Dictionary`를 가공하지 않고 보관만 한다.

```json
{
  "ax": 2,
  "body": {
    "scale": 0.62,
    "parts": ["torso", "arm_right", "leg_left", "leg_right"],
    "missing": [
      { "part": "arm_left", "kind": "amputation", "severity": 1, "permanent": true }
    ],
    "wounds": [
      { "part": "leg_left", "kind": "deep_cut", "severity": 2, "permanent": true }
    ]
  },
  "creature": [
    {
      "id": "fix.gardener",
      "archetype": "keeper",
      "stage": 3,
      "state": "dead",
      "traits": { "fear": "light", "need": "water" },
      "memory": [ { "event": "garden_gate_opened", "place_id": "place.ruined_garden" } ],
      "den": "place.ruined_garden"
    }
  ],
  "place": {
    "id": "place.tea_stair",
    "region_id": "region.middle",
    "tags": ["indoor", "narrow", "vertical"],
    "requires_body": { "scale_min": 0.7 }
  }
}
```

이 예시를 **읽는 방식**이 유일한 허용 방식이다.

- `body.scale = 0.62`는 `0.62`로 읽는다. `0.7`로 보정하지 않는다. (§7.8.1 정규화 열)
- `body.missing`의 `arm_left`는 `PART_MASS`에서 `0.25`를 뺀다. `parts` 배열에 없는 팔이 이미 하나 줄었다는 **추론을 하지 않는다.** 배열과 `missing`가 어긋나면 **어긋난 채로** `missing`만 사용한다.
- `creature[0].state = "dead"`는 문자열 그대로 비교한다. 이 Kit은 죽은 개체를 시체/잔해/빈자리 중 하나로 **표현만** 하고(§14.8.6), 축을 바꾸지 않는다.
- `place.requires_body = {"scale_min": 0.7}`에 `0.62`를 대조해 **판정한다.** 판정 결과는 `objective_needed` 상향 여부뿐이다. 통과를 막지 않는다(§14.8.5).
- 축 중 하나가 통째로 없으면 그 축은 "없음"이다. `body`가 없을 때 `player_mass = 0`으로 만들지 않고, `axis_view`는 "없음"을 반환하고 `body_mass.gd`는 **그 경우를 호출하지 않는다**(호출부는 `if not has_body(): ...`로 명시).

### 7.8.3 이 Kit의 세이브는 뷰다

> **`save_state()`가 반환하는 §7.6 JSON은 원본이 아니다. 이 Kit이 소유한 것만 담는 시점별 뷰다.**

| 규칙 | 내용 |
|---|---|
| 축 값 복사 금지 | `save_state()` 결과에 `body` / `creature` / `place` 키가 **없어야 한다.** 축을 복사해 넣는 순간 스토어의 원본과 이 Kit의 사본이 갈라진다 |
| 축 복원 금지 | `load_state()`는 축을 복원하지 않는다. 축 복원은 앱이 스토어에서 읽어 **다음 `arrival`**로 주는 몫이다 |
| 축 캐시 금지 | `enter` 이후 축이 바뀌어도 이 Kit은 모른다. 값을 받아 저장해 두지 않는다 |
| 요청 결과도 미반영 | `request_mutation`이 수용돼도 **다음 `enter` 전까지** 이 Kit의 물리에 반영하지 않는다(§14.8.3) |
| 뷰의 유일한 용도 | 이 Kit이 자기 런을 어디까지 진행했는지 말하는 것. 축에서 유래한 정보를 다른 Kit에 넘겨 축을 복원하려는 용도로 쓰지 않는다 |

`test_save_contains_no_axis_values`가 위 표를 전수 검사한다.

---

## 8. 프레임 처리 순서와 서브스텝

### 8.1 순서 (14단계, §4.6과 동일 — 여기서 한 번 더 확정)

| # | 단계 | 하는 일 | 실패 시 |
|---:|---|---|---|
| 1 | `sample_input` | `context.is_action_pressed()`로 4개 action 상태 스냅샷. 에지 검출(직전 프레임과 비교) | `context.input_enabled == false`면 3~14 스킵. 출력만 갱신 |
| 2 | `precheck` | `phase`가 `play`가 아니면 입력 무시. `hitstop > 0`이면 3~13 스킵 | `dead` 페이즈면 `phase_time`만 증가 |
| 3 | `player_force` | 이동 축·점프·중력 적용. `_apply_input_to_body` | 플레이어 `frozen`이면 스킵 |
| 4 | `player_clamp` | 속도 상한, 회전 고정, `bounds` 클램프(좌우만) | — |
| 5 | `tool_action` | 잡기/놓기/던지기. 쿨다운 검사 | 쿨다운 중이면 무시 |
| 6 | `kinematics` | 키네마틱 발판을 authored 궤적만큼 이동. 변형 `wind` 램프 적용 | 궤적 없으면 정지 |
| 7 | `physics_substeps` | **§8.2** | — |
| 8 | `collect_signals` | 접촉 버퍼에 쌓기(상태 변경 없음) | — |
| 9 | `sort_contacts` | §4.6.1 정렬키로 정렬 | — |
| 10 | `resolve_interactions` | 15종 규칙 적용. `collect`/`fill` 먼저 → `enter` → 도구 → `wake` → `dmg_a` → `dmg_b`/`knock` → 물리 보조 | `applied=false`면 버퍼에 남겨 다음 스텝에 재시도 |
| 11 | `resolve_damage` | hp 감소, 파괴 확정, 파편 스폰, `hitstop` 설정 | 파괴 후 `t >= t_max`인 바디는 즉시 파괴(§9.8) |
| 12 | `resolve_objective` | `objective_count` 갱신, 틈 개방, 클리어 판정 | — |
| 13 | `physics_aftercare` | 총알 관통 카운트, `debris` 수명, `tool_cooldown` 감소, `frozen` 해제 타이머 | — |
| 14 | `commit_frame` | `WorldState`에 결과 반영, `elapsed += delta`, `t += delta` | — |

**14단계가 "커밋"이라는 점이 중요하다.** 10~13단계는 계산만 하고 `WorldState`를 마지막에 한 번만 쓴다. 중간에 예외가 나면 스텝 전체가 버려져 물리가 깨지지 않는다(`CODE_STYLE.md`의 실패 원자성).

### 8.2 서브스텝 수와 이유

**값: `PHYSICS_HZ = 120`, 렌더 프레임당 서브스텝 `2`.**

- 이 Kit은 `stack_blast` 위에서 `IRON`(density 3.2) 상자가 `PAPER`(0.30) 상자 위에 쌓인다. 60Hz에서는 저밀도 박스가 고밀도 박스 사이를 16.7ms 동안 통과해 바닥을 뚫는다. 120Hz로 절반으로 줄인다.
- `PLAYER`는 32px 캡슐이고 `TILE_STATIC` 벽 두께는 24px다. 플레이어 낙하 속도 상한 820px/s에서 16.7ms 동안 13.7px 이동한다 — 벽 두께의 57%. 120Hz면 28%. 이 값이 벽을 "삼키지 않게" 만든다.
- `motion_scale`은 1.0. 비활성화하면 서브스텝의 이득이 절반으로 죽는다.

**Godot 프로젝트 설정(`project.godot`, W0 소유 — §21에 요청 목록):**

| 키 | 값 | 이유 |
|---|---|---|
| `physics/common/physics_ticks_per_second` | `120` | 위. |
| `physics/common/physics_jitter_fix` | `0.0` | 직선 궤적 판정 안정화. |
| `physics/2d/default_gravity` | `1400.0` | §9.1. |
| `physics/2d/sleep_threshold_linear` | `4.0` | 표류 중인 쓰레기 상자가 자꾸 미끄러져 움직이지 않게. |
| `physics/2d/sleep_threshold_angular` | `6.0` | 위. |
| `physics/2d/default_linear_damp` | `0.08` | 절벽 끝을 지나쳐 흔들리는 떨림 억제. |
| `physics/2d/default_angular_damp` | `0.9` | 저마찰 위에서 도구가 끝없이 빙글 도는 것 방지. |
| `physics/2d/solver/solver_iterations` | `24` | 스택 안정성. |
| `physics/2d/solver/contact_recycle_radius` | `0.5` | 얇은 판(24px)에서의 터널링 억제. |
| `display/window/stretch/mode` | `canvas_items` | 해상도 대응. §17. |

`physics_ticks_per_second = 120`은 Godot이 내부적으로 프레임을 2회 물리 스텝으로 쪼갠다. **렌더 프레임이 30fps로 떨어지면 한 프레임에 4 서브스텝이 돈다.** 물리는 프레임레이트와 무관하게 같은 시각 간격으로 진행된다.

---

## 9. 상수표

모든 값은 확정값이다. 구현 시 여기서 값을 바꾸지 않는다. 바꾸려면 `§20`으로 가서 사용자 승인을 받는다.

### 9.1 중력·시간

| 상수 | 값 | 단위 | 비고 |
|---|---:|---|---|
| `GRAVITY` | `1400.0` | px/s² | `default_gravity`. Projectile feel 기준. |
| `FIXED_DT` | `1.0 / 120.0` | s | 물리 스텝. |
| `PHYSICS_HZ` | `120` | Hz | §8.2. |
| `MAX_FRAME_DT` | `0.25` | s | 이 값을 넘는 프레임은 물리를 건너뛴다(스파이럴 방지). |

### 9.2 플레이어 이동

| 상수 | 값 | 단위 | 비고 |
|---|---:|---|---|
| `PLAYER_W` | `32.0` | px | 캡슐 지름. |
| `PLAYER_H` | `46.0` | px | 캡슐 전체 높이. |
| `PLAYER_DENSITY` | `0.90` | — | 총질량 `≈ 1.04`. |
| `MOVE_SPEED` | `196.0` | px/s | 지면 최대 수평 속도. |
| `ACCEL_GROUND` | `1450.0` | px/s² | 지면 가속. |
| `ACCEL_AIR` | `620.0` | px/s² | 공중 가속. 지면의 43%. 공중 조작이 무겁다. |
| `FRICTION_GROUND` | `0.86` | — | `PhysicsMaterial.friction`. |
| `BOUNCE_PLAYER` | `0.0` | — | 플레이어는 안 튄다. |
| `JUMP_VELOCITY` | `-470.0` | px/s | 최고 도달 높이 `≈ 79px`(점프 1회). |
| `JUMP_CUT` | `0.42` | — | 상승 중 키를 떼면 속도에 곱해지는 계수. |
| `COYOTE_TIME` | `0.10` | s | 지면 이탈 후 점프 가능 시간. |
| `JUMP_BUFFER` | `0.12` | s | 착지 직전 점프 입력 기억. |
| `MAX_FALL_SPEED` | `820.0` | px/s | §8.2 계산의 근거. |
| `APEX_ASSIST` | `0.0` | — | **0이다.** 정점 조작 없음. |
| `AIR_DRAG` | `0.9` | — | 공중에서 입력 없을 때의 `linear_damp` 추가값. |

### 9.3 도구

| 상수 | 값 | 단위 | 비고 |
|---|---:|---|---|
| `GRAB_RADIUS` | `26.0` | px | 소켓에서 픽업까지 거리. §4.5. |
| `TOOL_COOLDOWN` | `0.22` | s | 잡기 쿨다운. |
| `TOOL_THROW_IMPULSE` | `330.0` | kg·px/s | 던질 때 도구 선속도(도구 JSON이 `impulse_scale`로 배율). |
| `TOOL_THROW_UP` | `-140.0` | px/s | 던질 때 추가 수직 속도. 위로 던지는 각도 부여. |
| `TOOL_MAX_HOLD` | `6.0` | s | 이 시간 이상 들고 있으면 쿨다운 없이 놓아도 즉시 재잡기 가능(쿨다운 초기화). |
| `TOOL_HOLD_HINT` | `0.35` | s | 도구를 든 상태로 버티면 실루엣 옆에 최소 힌트. §11.5. |

### 9.4 데미지·내구

| 상수 | 값 | 단위 | 비고 |
|---|---:|---|---|
| `IMPACT_THRESHOLD` | `235.0` | px/s | 법선 방향 상대속도 임계. 이 아래는 데미지 0. |
| `IMPACT_DAMAGE_SCALE` | `0.035` | — | `(속도 - 임계) * scale`, 소수점 2자리에서 `ceil`. |
| `PLAYER_HP` | `5` | — | `PROP_DYNAMIC` hp와 같은 값(§9.5 표). `OBJECTIVE`에 닿을 때 `max - 1`. |
| `INVULN_TIME` | `0.65` | s | 피격 후 무적. |
| `HITSTOP` | `0.055` | s | `dmg_a` 성공마다. 최대 `0.11`. |
| `HAZARD_DPS` | `3` | hp/s | `HAZARD_AREA` 위에 서 있을 때 초당. `INVULN_TIME` 무시하고 매 스텝. |
| `DEAD_RECOVER_DELAY` | `0.6` | s | `dead` 페이즈 유지. |
| `DEBRIS_LIFE` | `1.2` | s | 파편 수명. |
| `DEBRIS_SCALE` | `0.12` | — | 원본 크기 대비. |

### 9.5 바디별 hp

| `kind` | hp | 파괴 | 비고 |
|---|---:|---|---|
| `PLAYER` | `5` | 리셋으로 복구 | 데미지로만 깎인다. |
| `TOOL_CARRIED` | 도구별 (2~6) | 파괴되면 `TOOL_PLACEMENT`으로 복귀(§9.9) | §10.4. |
| `TOOL_PLACEMENT` | — | 파괴 불가 | §4.7-5. |
| `OBJECTIVE` | `1` | 소멸(획득) | `PROP_DYNAMIC`이 깨면 2.5s 뒤 재생성(§9.9). |
| `PROP_DYNAMIC` | `3` | 파괴 → 파편 | |
| `PROP_SLEEPING` | `3` | 파괴 → 파편 | |
| `OBSTACLE_DYNAMIC` | `6` | 파괴 불가 | 해머 이상의 타격 필요. 휘ournal. |
| `DECOR_DYNAMIC` | `∞` | 파괴 불가 | 순수 장식. |
| `TILE_STATIC` / `TILE_KINEMATIC` | `∞` | 파괴 불가 | |
| `RIFT` / `HAZARD_*` | `∞` | 파괴 불가 | |
| `frozen` 상태인 모든 `RigidBody2D` | 변화 없음 | 파괴 불가 | `tool_ember_lash`의 `fire_linger`와 `tool_chill_jar`의 `cool_field`가 건다. 이 예외는 hp 표 전체에 적용되며, `OBSTACLE_DYNAMIC`이 닿아도 밀리기만 한다. `frozen`은 `§14.6`의 자동 해제 경로가 처리한다. |

### 9.6 목표·런

| 상수 | 값 | 단위 | 비고 |
|---|---:|---|---|
| `LEVEL_COUNT` | `8` | — | 한 런의 레벨 수. |
| `TOOL_COUNT` | `8` | — | 한 런에 배정되는 도구 수. |
| `MUTATION_CHANCE` | `0.62` | — | §5.2. |
| `MUTATION_MAX` | `2` | — | §5.2. |
| `OBJECTIVE_MIN` | `1` | — | |
| `OBJECTIVE_MAX` | `12` | — | |
| `INTRO_DURATION` | `0.9` | s | 전환 페이드. |
| `CLEAR_DURATION` | `0.9` | s | 클리어 페이드. |

### 9.7 카메라

| 상수 | 값 | 단위 | 비고 |
|---|---:|---|---|
| `CAM_ZOOM` | `1.0` | — | 고정. 줌 없음. |
| `CAM_DEADZONE_X` | `120.0` | px | 수평 데드존. |
| `CAM_FOLLOW_SPEED` | `6.5` | — | 지수 보간 계수(프레임 독립). |
| `CAM_LOOKAHEAD` | `58.0` | px | 진행 방향 미리 보기. |
| `CAM_Y` | `288.0` | px | 고정 세로. |
| `CAM_SHAKE_DECAY` | `9.0` | — | 셰이크 감쇠. |
| `CAM_BOUNDS_PAD` | `40.0` | px | 레벨 `bounds` 밖으로 카메라가 나가지 않게. |

### 9.8 바디 재등장·복구

| 상수 | 값 | 단위 | 비고 |
|---|---:|---|---|
| `OBJECTIVE_RESPAWN` | `2.5` | s | 시간알 파괴 후 같은 자리에 다시 생김. 플레이어가 볼 수 있는 수준으로 필터링. |
| `TOOL_RESPAWN` | `1.4` | s | 도구 파괴 후 `TOOL_PLACEMENT` 자리로 복귀. |
| `SLEEP_RELAX` | `3.0` | s | `PROP_SLEEPING`이 다시 잠드는 무접촉 시간. |
| `WAKE_PUSH` | `40.0` | N·s | `wake` 시 상대에게 가하는 충격량. |

### 9.9 물리 기본

| 상수 | 값 | 비고 |
|---|---:|---|
| `MAX_LINEAR_VEL` | `980.0` px/s | 모든 `RigidBody2D` 선속도 상한. |
| `MAX_ANGULAR_VEL` | `18.0` rad/s | 위. |
| `CONTACT_MAX_REPORTED` | `8` | 바디당. |
| `SOLVER_ITERATIONS` | `24` | project.godot. |

### 9.10 금지 상수(존재하면 안 되는 것)

아래 이름이 코드에 등장하면 `§18` 위반이다. 테스트 `test_ppp_no_forbidden_shortcuts.gd`가 전수 텍스트 스캔한다.

`PITY_COUNTER`, `DUPLICATE_LIMIT`, `REPEAT_PENALTY`, `WEIGHT_TABLE`, `pick_unique`, `shuffle_bag`, `LOCK_BY_LEVEL`, `SOLUTION_HINT`, `DIFFICULTY_RAMP`, `TUTORIAL_TEXT`, `INVENTORY_PANEL`, `TOOL_SLOT_UI`, `PROCEDURAL_LEVEL`, `MASS_SPAWN`

---

## 10. Authored Content 포맷

### 10.1 콘텐츠 종류와 확장성 요약

| content type | 파일 | 파싱 | 검증 | core 수정 없이 추가? |
|---|---|---|---|---|
| 레벨 | `content/levels/*.json` | `level_factory.gd` | `level_spec.gd::validate()` | **가능.** JSON 1개 + `index.json` 1줄 |
| 도구 | `content/tools/*.json` | `level_factory.gd` | `tool_spec.gd::validate()` | **가능.** 동일 |
| 인덱스 | `content/*/index.json` | `level_factory.gd` | ID 유일성 | **가능.** |

전용 에디터는 없다(§2.5). `dev_probe.tscn`는 검증 도구이지 에디터가 아니다.

### 10.2 레벨 정의 스키마

레벨 JSON 최상위 키. **모두 필수**다(기본값으로 채우지 않는다). JSON 파싱 실패나 필수 키 누락은 로드 실패다.

| 키 | 타입 | 범위 | 의미 |
|---|---|---|---|
| `schema` | int | `== 1` | 레벨 파일 스키마. |
| `id` | string | `^[a-z0-9_]{3,32}$`, `index.json`과 일치 | 안정 ID. 저장의 키. |
| `name` | string | 1~24자, 한글 허용 | `LevelTitle` 카드에 표기. **플레이 중에는 안 보임.** 값은 §11.9 `T1`~`T9`가 정하며, 코드에 하드코딩하지 않는다 |
| `parallax_seed` | int | `1..999999` | `core/procedural` 배경 생성 시드. |
| `spawn` | `{x, y}` float | `bounds` 안 | 플레이어 시작 위치. |
| `rift` | `{x, y, radius}` | `bounds` 안, radius `20..48` | 틈 위치/크기. |
| `bounds` | `{min_x, max_x, min_y, max_y}` | `max > min`, 폭 ≥ 1600, 높이 ≥ 640 | 카메라와 바깥 경계. |
| `bodies` | array | 1~64 | 바디 목록(§10.3). |
| `kinematics` | array | 0~4 | `TILE_KINEMATIC` 궤적(§10.3). |
| `shuffled` | array of body index | 0~2 | `material_swap` 변형 후보. |
| `mutable` | array of string | 6종 op만 | 허용 변형 op(§5.3). |
| `mutable_hazards` | array of body index | 0~4 | `hazard_shift` 대상. |
| `objective_needed` | int | `1..12`, `OBJECTIVE` 개수 이하여야 | 클리어 필요 개수. |

**검증 실패 조건(로드 거부):** 위 키 누락, `id` 불일치, 범위 초과, `bodies`가 64 초과, `hull`의 `points`가 2점 이하, `mutable`에 6종 외 문자열, `objective_needed > OBJECTIVE` 개수, `spawn`/`rift`가 `bounds` 밖, `kinematics`의 경로가 `bounds` 밖, `index.json`에 없는 `id`.

### 10.3 바디 항목 스키마

| 키 | 타입 | 필수 | 기본 | 의미 |
|---|---|---|---|---|
| `id` | string `^[a-z0-9_]{1,24}$` | ✔ | — | 바디 안정 ID. |
| `kind` | string | ✔ | — | `tile_static` `tile_kinematic` `prop_dynamic` `prop_sleeping` `obstacle_dynamic` `decor_dynamic` `objective` `rift` `hazard_static` `hazard_area` `tool_placement` |
| `shape` | string | ✔ | — | `box` `capsule` `circle` `triangle` `hull` `segment` |
| `material` | string | ✔ | — | `paper` `glass` `wood` `stone` `iron` `clockwork` `wax` `void` `goal` |
| `pos` | `[x, y]` | ✔ | — | 중심 좌표. |
| `size` | `[w, h]` | `hull` 아니면 ✔ | — | `circle`는 `[d, d]`. `segment`는 `[두께, 길이]`. |
| `points` | `[[x,y],…]` | `hull`만 ✔ | — | 3~6점. 로컬 좌표. |
| `angle` | float | ✖ | `0.0` | 초기 회전(rad). |
| `hp` | int | ✖ | `kind`별 §9.5 | `hull`/`triangle`은 2배. |
| `breakable` | bool | ✖ | `kind`∈{`prop_dynamic`,`prop_sleeping`,`objective`} | `false`면 데미지는 받지만 안 깨진다. |
| `t_max` | float | ✖ | `0.0`(무제한) | `>0`이면 `t` 도달 시 파괴. 시한 폭발 스택. |
| `friction_override` | float | ✖ | 없음 | `material`의 `friction`을 덮어쓴다. 범위 `0.0..1.6`. |
| `bounce_override` | float | ✖ | 없음 | `material`의 `bounce`을 덮어쓴다. 범위 `0.0..0.6`. |
| `tool` | string | `tool_placement`만 ✔ | — | 도구 ID. `tools/index.json`에 있어야 한다. |

`kind`가 `rift`면 `level.rift`와 중복 금지. 로더가 중복을 거부한다. `rift`는 `bodies`에 넣지 않는다.

### 10.4 도구 정의 스키마

> **[제작 전용]** 도구 `name` 값 7개는 **디버그/리포트 전용 authored 정본**이다. 화면·리포트 payload·오디오 이름에 넣지 않는다(§11.5, §11.9-2). `dev_probe`와 `test_*`가 읽을 수는 있다.

| 키 | 타입 | 필수 | 기본 | 의미 |
|---|---|---|---|---|
| `schema` | int | ✔ | — | `== 1`. |
| `id` | string | ✔ | — | `tools/index.json`과 일치. |
| `name` | string | ✔ | — | 표시명. **플레이 중 표시 안 함**(§11.5). 디버그/리포트용. |
| `use` | string | ✔ | — | `throw` `shove` `anchor_line` `cool_field` 4종. |
| `body` | object | ✔ | — | `{kind, shape, material, size, density}`. `kind`는 `prop_dynamic`. |
| `impulse_scale` | float | `throw`만 ✔ | `1.0` | `TOOL_THROW_IMPULSE`에 곱해짐. |
| `mass` | float | ✔ | — | 강제 밀기 시 이전도 파괴되지 않도록 `1.4` 이상 권장. |
| `friction` | float | ✔ | — | `0.05..1.20`. |
| `bounce` | float | ✔ | — | `0.0..0.45`. |
| `reach` | int | `shove`만 ✔ | — | 앞쪽 픽셀 거리 `18..90`. |
| `arc_deg` | int | `shove`만 ✔ | — | 부채꼴 각도 `30..180`. |
| `radius` | int | `cool_field`만 ✔ | — | 반경 `40..140`. |
| `duration` | float | `cool_field`만 ✔ | — | 정지 시간 `0.2..1.5`. |
| `cooldown` | float | ✔ | `0.22` | §9.3. |
| `trail` | string | ✔ | — | `none` `short` `long`. `long`는 `RigidBody` 드래그. |

**금지:** `pickable`, `opens`, `unlocks`, `required_for`, `key_id` 같은 필드는 **존재하지 않는다.** `dev_probe`가 레지스트리에 이 이름이 있으면 오류를 낸다(§4.7-6).

### 10.5 작업 예시 1 — 가장 단순한 레벨

`content/levels/lvl_chalk_shelf.json`. 이동과 점프만 배우는 레벨. 변형 0종(테스트 안정성 확보).

```json
{
  "schema": 1,
  "id": "lvl_chalk_shelf",
  "name": "분필 선반",
  "parallax_seed": 1041,
  "spawn": { "x": 140, "y": 452 },
  "rift": { "x": 1060, "y": 430, "radius": 28 },
  "bounds": { "min_x": -120, "max_x": 1240, "min_y": -80, "max_y": 620 },
  "objective_needed": 2,
  "mutable": [],
  "mutable_hazards": [],
  "shuffled": [],
  "kinematics": [],
  "bodies": [
    { "id": "floor",       "kind": "tile_static", "shape": "box",    "material": "stone", "pos": [560, 520], "size": [1120, 48] },
    { "id": "step_a",      "kind": "tile_static", "shape": "box",    "material": "wood",  "pos": [520, 424], "size": [176, 24] },
    { "id": "step_b",      "kind": "tile_static", "shape": "box",    "material": "wood",  "pos": [744, 360], "size": [176, 24] },
    { "id": "egg_low",     "kind": "objective",   "shape": "circle", "material": "clockwork", "pos": [300, 176], "size": [22, 22] },
    { "id": "egg_high",    "kind": "objective",   "shape": "circle", "material": "clockwork", "pos": [744, 300], "size": [22, 22] },
    { "id": "pillar",      "kind": "tile_static", "shape": "hull",   "material": "stone", "pos": [880, 452], "points": [[-40, 44], [40, 44], [26, -44], [-26, -44]] }
  ]
}
```

읽히는 것: 바닥 하나, 오르는 계단 둘, 시간알 둘, 틈 하나. 플레이어는 좌우로 걷고 두 번 올라가 알을 두 개 모은다.

### 10.6 작업 예시 2 — 중간 복잡도 레벨

`content/levels/lvl_rolling_coin.json`. 데미지 해처, 무거운 장애물, 도구 배치, 변형 2종.

```json
{
  "schema": 1,
  "id": "lvl_rolling_coin",
  "name": "굴러가는 동전",
  "parallax_seed": 2207,
  "spawn": { "x": 120, "y": 460 },
  "rift": { "x": 1480, "y": 392, "radius": 32 },
  "bounds": { "min_x": -160, "max_x": 1720, "min_y": -120, "max_y": 640 },
  "objective_needed": 3,
  "mutable": ["material_swap", "prop_offset"],
  "mutable_hazards": [7, 8],
  "shuffled": [4],
  "kinematics": [
    { "id": "lift_a", "from": [640, 470], "to": [640, 250], "duration": 2.4, "loop": "pingpong" }
  ],
  "bodies": [
    { "id": "floor",      "kind": "tile_static",      "shape": "box",  "material": "stone", "pos": [780, 520], "size": [1760, 48] },
    { "id": "wall_mid",   "kind": "tile_static",      "shape": "box",  "material": "stone", "pos": [900, 400], "size": [48, 200] },
    { "id": "ledge_far",  "kind": "tile_static",      "shape": "box",  "material": "wood",  "pos": [1440, 440], "size": [240, 24] },
    { "id": "spike_low",  "kind": "hazard_static",    "shape": "box",  "material": "void",  "pos": [1160, 508], "size": [96, 12] },
    { "id": "spike_high", "kind": "hazard_static",    "shape": "box",  "material": "void",  "pos": [1300, 428], "size": [96, 12] },
    { "id": "ice",        "kind": "tile_static",      "shape": "box",  "material": "glass", "pos": [1300, 508], "size": [160, 48], "friction_override": 0.04 },
    { "id": "ball",       "kind": "obstacle_dynamic", "shape": "circle","material": "iron",  "pos": [380, 470], "size": [40, 40], "hp": 6 },
    { "id": "crate_a",    "kind": "prop_dynamic",     "shape": "box",  "material": "wood",  "pos": [300, 486], "size": [36, 32] },
    { "id": "crate_b",    "kind": "prop_sleeping",    "shape": "box",  "material": "glass", "pos": [452, 490], "size": [30, 30] },
    { "id": "doodad",     "kind": "decor_dynamic",    "shape": "circle","material": "clockwork", "pos": [1000, 300], "size": [26, 26] },
    { "id": "mist",       "kind": "hazard_area",      "shape": "box",  "material": "void",  "pos": [1000, 470], "size": [180, 100] },
    { "id": "egg_a",      "kind": "objective",        "shape": "circle","material": "clockwork", "pos": [640, 200], "size": [22, 22] },
    { "id": "egg_b",      "kind": "objective",        "shape": "circle","material": "clockwork", "pos": [1160, 380], "size": [22, 22] },
    { "id": "egg_c",      "kind": "objective",        "shape": "circle","material": "clockwork", "pos": [1440, 396], "size": [22, 22] },
    { "id": "tool_spot",  "kind": "tool_placement",   "shape": "circle","material": "goal",  "pos": [180, 460], "size": [24, 24], "tool": "tool_lead_weight" }
  ]
}
```

추가로 지정한 필드:

- `friction_override` / `bounce_override` (float, 선택): `material`의 마찰/반발을 덮어쓴다. 이 예시에서 `ice`는 glass(마찰 0.30)이지만 0.04로 미끄럽다. 범위 밖 값은 로드 실패.
- `kinematics[]` 항목: `id`, `from`, `to`, `duration`, `loop`(`once`|`pingpong`). `TILE_KINEMATIC` 바디는 `pos`를 **쓰지 않고** 이 궤적을 따른다. `from`/`to`는 `bounds` 안이어야 한다.
- `mutable_hazards`는 `bodies` 배열의 **인덱스**다. `[7, 8]` = `spike_low`, `spike_high`. `hazard_shift`가 이 둘의 배열 순서를 1칸 순환 이동시킨다.
- `shuffled`도 인덱스. `[4]` = `ball`. `material_swap`은 이 바디의 재료를 다른 것으로 바꾼다.

### 10.7 작업 예시 3 — 최대 복잡도 레벨

`content/levels/lvl_hollow_keyhole.json`. 6종 상호작용이 전부 나오는 마지막 레벨. 변형 5종 허용.

```json
{
  "schema": 1,
  "id": "lvl_hollow_keyhole",
  "name": "빈 열쇠구멍",
  "parallax_seed": 7717,
  "spawn": { "x": 100, "y": 468 },
  "rift": { "x": 2200, "y": 300, "radius": 44 },
  "bounds": { "min_x": -240, "max_x": 2560, "min_y": -200, "max_y": 700 },
  "objective_needed": 5,
  "mutable": ["gravity_scale", "material_swap", "prop_size", "prop_offset", "wind", "hazard_shift"],
  "mutable_hazards": [12, 13, 14],
  "shuffled": [6, 9],
  "kinematics": [
    { "id": "lift_a", "from": [520, 480], "to": [520, 190], "duration": 3.1, "loop": "pingpong" },
    { "id": "lift_b", "from": [1180, 180], "to": [1520, 180], "duration": 2.6, "loop": "pingpong" },
    { "id": "crusher", "from": [1960, 200], "to": [1960, 420], "duration": 1.4, "loop": "pingpong" }
  ],
  "bodies": [
    { "id": "floor_main",  "kind": "tile_static", "shape": "box", "material": "stone", "pos": [900, 540], "size": [2100, 48] },
    { "id": "floor_pit",   "kind": "tile_static", "shape": "box", "material": "glass", "pos": [1640, 540], "size": [240, 48] },
    { "id": "cliff",       "kind": "tile_static", "shape": "hull", "material": "stone", "pos": [760, 420], "points": [[-60, 96], [60, 96], [60, -96], [-30, -96]] },
    { "id": "ramp",        "kind": "tile_static", "shape": "triangle", "material": "wood", "pos": [420, 460], "size": [220, 140], "angle": 0.0 },
    { "id": "roof",        "kind": "tile_static", "shape": "box", "material": "stone", "pos": [1340, 120], "size": [520, 32] },
    { "id": "hinge_post",  "kind": "tile_static", "shape": "segment", "material": "iron", "pos": [1880, 430], "size": [10, 220] },
    { "id": "anvil",       "kind": "obstacle_dynamic", "shape": "box", "material": "iron", "pos": [240, 500], "size": [72, 56], "hp": 6 },
    { "id": "stack_1",     "kind": "prop_dynamic",  "shape": "box", "material": "stone", "pos": [240, 470], "size": [30, 28] },
    { "id": "stack_2",     "kind": "prop_dynamic",  "shape": "box", "material": "stone", "pos": [240, 442], "size": [30, 28] },
    { "id": "stack_3",     "kind": "prop_dynamic",  "shape": "box", "material": "clockwork", "pos": [240, 414], "size": [30, 28] },
    { "id": "glass_jar",   "kind": "prop_sleeping", "shape": "circle", "material": "glass", "pos": [1080, 508], "size": [34, 34] },
    { "id": "paper_stack", "kind": "prop_sleeping", "shape": "box", "material": "paper", "pos": [1180, 512], "size": [44, 22] },
    { "id": "spikes_a",    "kind": "hazard_static", "shape": "triangle", "material": "void", "pos": [1520, 528], "size": [72, 24] },
    { "id": "spikes_b",    "kind": "hazard_static", "shape": "box", "material": "void", "pos": [1700, 528], "size": [80, 24] },
    { "id": "spikes_c",    "kind": "hazard_static", "shape": "circle", "material": "void", "pos": [2000, 520], "size": [40, 40] },
    { "id": "fog_low",     "kind": "hazard_area", "shape": "box", "material": "void", "pos": [1600, 470], "size": [200, 130] },
    { "id": "fog_high",    "kind": "hazard_area", "shape": "box", "material": "void", "pos": [2040, 250], "size": [180, 120] },
    { "id": "gear_a",      "kind": "decor_dynamic", "shape": "circle", "material": "clockwork", "pos": [900, 300], "size": [46, 46] },
    { "id": "gear_b",      "kind": "decor_dynamic", "shape": "hull", "material": "clockwork", "pos": [1020, 220], "points": [[-34, 0], [0, -34], [34, 0], [0, 34]] },
    { "id": "gear_c",      "kind": "decor_dynamic", "shape": "circle", "material": "clockwork", "pos": [2200, 160], "size": [30, 30] },
    { "id": "tether_anchor", "kind": "tile_static", "shape": "circle", "material": "iron", "pos": [2180, 380], "size": [18, 18] },
    { "id": "egg_a", "kind": "objective", "shape": "circle", "material": "clockwork", "pos": [200, 360], "size": [22, 22] },
    { "id": "egg_b", "kind": "objective", "shape": "circle", "material": "clockwork", "pos": [520, 150], "size": [22, 22] },
    { "id": "egg_c", "kind": "objective", "shape": "circle", "material": "clockwork", "pos": [1080, 240], "size": [22, 22] },
    { "id": "egg_d", "kind": "objective", "shape": "circle", "material": "clockwork", "pos": [1500, 400], "size": [22, 22] },
    { "id": "egg_e", "kind": "objective", "shape": "circle", "material": "clockwork", "pos": [1960, 160], "size": [22, 22] },
    { "id": "egg_f", "kind": "objective", "shape": "circle", "material": "clockwork", "pos": [2320, 380], "size": [22, 22] },
    { "id": "tool_spot", "kind": "tool_placement", "shape": "circle", "material": "goal", "pos": [140, 468], "size": [24, 24], "tool": "tool_rope_hook" }
  ]
}
```

이 레벨이 증명하는 것: 스택 붕괴(`gravity_scale`), 밀림(`prop_offset`, `prop_size`), 마찰 변화(`material_swap`), 발판 타이밍(`wind`), 해처 위치(`hazard_shift`), 그리고 위 6종 변형이 **동시에** 걸려도 지형이 무너지지 않는다는 것.

### 10.8 도구 정의 작업 예시 (점점 복잡하게)

**`tool_paper_fan`** — 최소. 밀어내기.

```json
{
  "schema": 1,
  "id": "tool_paper_fan",
  "name": "종이 부채",
  "use": "shove",
  "body": { "kind": "prop_dynamic", "shape": "box", "material": "paper", "size": [26, 34] },
  "mass": 1.4,
  "friction": 0.90,
  "bounce": 0.02,
  "reach": 42,
  "arc_deg": 90,
  "cooldown": 0.22,
  "trail": "none"
}
```

**`tool_glass_rod`** — 던지기 + 드래그.

```json
{
  "schema": 1,
  "id": "tool_glass_rod",
  "name": "유리 막대",
  "use": "throw",
  "body": { "kind": "prop_dynamic", "shape": "capsule", "material": "glass", "size": [10, 52] },
  "impulse_scale": 1.15,
  "mass": 1.4,
  "friction": 0.55,
  "bounce": 0.18,
  "cooldown": 0.22,
  "trail": "long"
}
```

**`tool_rope_hook`** — 최대. 물리 조인트.

```json
{
  "schema": 1,
  "id": "tool_rope_hook",
  "name": "줄 갈고리",
  "use": "anchor_line",
  "body": { "kind": "prop_dynamic", "shape": "capsule", "material": "iron", "size": [12, 30] },
  "mass": 2.0,
  "friction": 0.60,
  "bounce": 0.05,
  "cooldown": 0.22,
  "trail": "short"
}
```

`anchor_line`의 조인트 파라미터는 **도구 JSON이 아니라 `body_kind.gd`의 상수**다(도구마다 다르게 하면 장르가 아니라 도구 카운터가 된다):

| 상수 | 값 |
|---|---|
| `JOINT_SEGMENTS` | `5` |
| `JOINT_SEGMENT_LEN` | `16.0` px |
| `JOINT_STIFFNESS` | `0.85` |
| `JOINT_DAMPING` | `0.35` |
| `JOINT_BREAK_FORCE` | `900.0` N |
| `JOINT_MAX_LENGTH` | `80.0` px |

`tool_cool_field`(`tool_chill_jar`)는 `radius: 96`, `duration: 0.7`. 생성되는 `Area2D`는 0.7초 뒤 `free()`된다. **원래 있던 `RigidBody2D`는 파괴되지 않는다** — 정지만 한다. 파괴가 아니라 정지이므로 언제가 되더라도 복구된다. `frozen`은 §14.6에서 리셋으로 해제된다.

---

## 11. Presentation

### 11.1 화면의 주인공

- **플레이어가 첫 1초에 봐야 하는 것:** 현재 레벨의 지형 실루엣과, 그 위에서 어디로 움직일 수 있는가. 그다음 0.5초 안에: 시간알 2~5개가 어디에 있는가(위치만, 개수는 세지 않는다).
- **UI보다 우선하는 world element:** 물리 바디 전부. 시간알은 다른 모든 바디보다 1단계 밝은 잉크(`goal`)로 칠해져 눈에 띈다.
- **상시 표시가 정말 필요한 정보:** **없다.** (§11.4)
- **호출할 때만 보이는 정보:** ① 전환 중 레벨 이름 카드 0.9초 ② `intro` 페이즈의 Input Bubble ③ 런 완료 시 `requested(&"run_complete", …)` — **이 Kit이 넘기는 것은 ID와 정수뿐이고 표시 문자열은 0개**(§18.7, §11.9). 셸이 무얼 그릴지는 셸의 결정이지 이 Kit의 화면이 아니다 ④ Esc 메뉴(Shell 소유).

### 11.2 절차 비주얼 사용 계약

Kit은 픽셀을 직접 만들지 않는다. 전부 `core/procedural/`(ROUND_PLAN C1 동결 계약)에서 만든다. **시그니처를 바꾸지 않는다.**

| 호출 | 쓰임 |
|---|---|
| `Procedural.derive_seed(world_seed: int, id: String, version: int = 1) -> ProceduralSeed` | 레벨·바디별 결정론적 시드. 바디 id 문자열 + `parallax_seed` 해시. `ProceduralSeed.derive(sub_id)` / `derive_index(i)` 로 하위 스트림 파생. |
| `Procedural.make_noise(stream: ProceduralSeed, field: StringName = &"detail") -> ProceduralNoiseField` | `FIELD_SHAPE / DETAIL / FLOW / SQUISH` 4개 필드. `sample(x, y)` 단일, `sample_v` 2성분, `sample3` 3성분. |
| `Procedural.make_palette(stream: ProceduralSeed, variant: int = 0) -> ProceduralPalette` | 13개 역할 기반. `bg_far` `bg_near` `bg_fore` `ink` `ink_dim` `accent` `goal` 을 역할로 지정. `get_color(role)` 로 조회. |
| `Procedural.make_canvas(width: int, height: int) -> ProceduralCanvas` | RGBA8, 좌상단 원점. |
| `ProceduralSdf.circle / ellipse / segment / capsule / box / rounded_box / triangle` (모두 static) | **SDF는 배열이 아니라 `Callable`** — `field: Callable`, `field(point: Vector2) -> float` (음수 = 내부). `smooth_min` `smooth_max` `coverage` 로 합성·안티에일리어싱. |
| `ProceduralCanvas.fill / clear / set_pixel / get_pixel / blend_pixel / fill_rect / draw_line / draw_polygon / draw_circle / draw_ellipse` | 픽셀 쓰기. 전부 즉시 반영. |
| `ProceduralCanvas.blur / posterize / copy_from / shift` | 후처리. 2톤 포스터라이즈는 `posterize(levels: int)`. |
| `ProceduralCanvas.get_used_rect() -> Rect2i` | 유효 픽셀 경계. 배치·앵커 계산에 사용. |
| `ProceduralCanvas.to_image() -> Image` → `to_texture() -> ImageTexture` | 텍스처화. **`Procedural.texture()` 같은 도우미는 없다.** |
| `ProceduralSpring` / `Spring2D` | `configure(stiffness, damping_ratio)` `set_target` `kick(impulse)` `snap` `reset` `step(delta)` `is_settled`. 임계감쇠는 `ProceduralSpring.critical(...)`. |
| `ProceduralDeformField` | `build_grid` `configure` `bind_noise` `set_wind` `excite` `step` `get_point` `get_offset` `build_triangles`. 배경 정점 변형. |
| `ProceduralBackdropDynamics` | 레이어 단위. `add_anchor` `get_offset` `attach_field` `set_view_offset` `set_wind` `pulse` `step`. |
| `ProceduralBodyPart` / `ProceduralCreatureBuilder` / `ProceduralSquishRig` | 파츠 실루엣, 개체 합성, 리그. **wave 1 구현 대상** — 현재 `draw` `bounds` `compose_canvas` `outline` `compose` `step` `disturb` 는 스텁. |

**텍스처 캐시 규칙:** 바디 텍스처는 로드 시 1회 생성해 `body_view.gd`가 `Dictionary[spec_id]`로 가진다. 프레임마다 래스터링하지 않는다. 배경 텍스처는 레벨 전환 시 1회 생성.

**계약 위반 금지 (W0 확정):** 위 표는 `core/procedural/CONTRACT.md`의 **실제 동결 시그니처를 그대로 옮긴 것**이며,Kit이 임의로 다른 이름의 함수를 만들어 호출하는 것은 **계약 위반**이다. 이전 판본이 `Procedural.seed_for` / `rect_sdf` / `raster` / `texture` / `spring` / `deform_field` / `squish_rig` 같은 **존재하지 않는 함수를 쓰고 W2를 고치지 않고 어댑터로 우회하던 설계는 폐기**되었다. 구현이 필요하면 `presentation/` 안의 private 헬퍼로 쓰고, `core/procedural`의 공개 API를 재정의하지 않는다. `domain/`·`systems/`는 `core/procedural`을 전혀 모른다.

### 11.3 3층 배경 + 말랑말랑 물리 반응

`ParallaxRoot`가 세 레이어를 가진다.

| 레이어 | `parallax` | 역할 | 알파 상한 | 그리기 순서 |
|---|---:|---|---:|---|
| `far` | `0.28` | 지평선, 큰 실루엣. 정보 없음. | `0.55` | 0 |
| `near` | `0.55` | 중경 구조물. 플레이어 뒤. | `0.85` | 1 |
| `fore` | `1.35` | 화면 앞 장식. **플레이어를 가리지 않을 때만.** | `0.30` | 3 |

지형 바디는 항상 `fore` 아래, 배경 위에 그린다. `fore` 알파가 `0.30`을 넘으면 `body_view`가 화면 공간에서 플레이어 사각형을 검사해 가리면 그 요소를 **건너뛴다.** 플레이어가 보이지 않는 순간은 없다.

**물리 반응 — `BackdropDynamics`.** 이 Kit의 요구사항이며, 레퍼런스 무관한 우리 결정이다.

| 사건 | 조건 | 반응 |
|---|---|---|
| 플레이어 근접 | 플레이어와 요소 중심 거리 < `130px` | 요소가 플레이어 반대 방향으로 밀린다. 세기는 거리 반비례. 최대 변위 `26px`. |
| 점프 착지 | 플레이어가 `TILE_*`에 착지(상대속도 > `120px/s`) | 그 위치 반경 `200px` 안 요소가 위로 튀었다가 스프링으로 돌아온다. 최대 변위 `34px`. |
| 도구 충돌 | 도구가 바디에 충돌(`IMPACT_THRESHOLD` 초과) | 충돌점 반경 `160px` 요소에 방사형 임펄스. |
| 파괴 | 어떤 바디가 파괴됨 | 파편 수만큼 인접 요소에 임펄스. |
| 미끄럼 | 도구가 `friction < 0.3` 재질 위에서 `>150px/s` | 해당 요소에 접선 방향 스크롤. |

- 모든 반응은 `BackdropDynamics.pulse(kind, origin, radius, strength)` 한 호출로 들어온다. `step_director`가 접촉 처리 중 호출한다.
- 스프링: `stiffness = 26.0`, `damping_ratio = 0.42`(의도적으로 언더다amped — 2~3번 튀고 멈춘다).
- 정지 시간: 무입력 시 `1.8s` 안에 원위치 95%로 복귀.
- **한계:** 동시 활성 반응 요소는 최대 `28`개. 초과하면 가장 약한 것부터 버린다. 성능과 예측가능성 양쪽을 위한 값.

### 11.4 화면이 절대 보여주면 안 되는 것

| 금지 | 이 Kit에서의 확정 |
|---|---|
| 상시 HUD (hp, 개수, 시간, 도구 슬롯) | **없음.** hp는 `PLAYER_HP = 5`가 hp바로 보이지 않는다. 다쳤을 때 화면 가장자리 어두운 비네트가 1회 깜빡이고 끝난다. |
| 도구 인벤토리/슬롯바 | **없음.** 들고 있는 도구는 손에 붙은 실루엣(§11.5). |
| 숫자 카운터 | **없음.** 시간알 수는 `RIFT`의 충전 링으로만 말한다. |
| 조작법 텍스트 | **없음.** Input Bubble가 배운다. |
| 공간명/레벨명 상시 표기 | **없음.** `LevelTitle` 카드는 전환 0.9초만. |
| 키 힌트 바 | **없음.** |
| 디버그 라벨(release 노출) | **없음.** `dev_probe`는 `res://`에서만 실행되고 게임 씬에 붙지 않는다. |
| 버튼 목록으로 플레이 대체 | **없음.** 이 Kit의 UI 버튼은 Esc 메뉴(Shell 소유) 뿐. |
| "다음 레벨" 버튼, 리롤 버튼, 도구 전환 메뉴 | **없음.** `AGENTS.md` 금지. raw random 파괴. |
| 목표 안내 문장 | **없음.** 목표는 `RIFT`가 그리는 충전 링이 말한다. |
| 이미지 파일 | **없음.** `tests/core/test_no_binary_assets.gd`(W0)와 §16의 `test_ppp_content_schema.gd`가 검사. |

### 11.5 손에 든 도구의 표시

- 들고 있는 도구는 `PLAYER`에 붙은 `Sprite2D`로 **월드 좌표에** 그린다. UI가 아니다.
- 위치: 플레이어 중심에서 앞쪽 `14px`, 반높이만큼 위. 정지 상태에서 크기 `1.0`.
- 충전 중(`E` 누름): `Spring(180, 0.5)`로 `1.0 → 1.28`까지 부풀고, 붉은 틴트가 1단계 올라간다. 놓으면 `0.16s`에 `1.0`으로 돌아간다. 이 변화가 **유일한 조준 UI**다.
- `TOOL_HOLD_HINT = 0.35s` 이상 버티면 도구 옆에 잉크 3픽셀 점 하나가 맥동한다. "놓을 수 있다"는 신호일 뿐 도구 이름을 쓰지 않는다.
- 쿨다운 중에는 도구가 손에 없다(던졌으므로). 쿨다운 상태를 별도 표시하지 않는다.
- **도구 이름 텍스트는 어디에도 안 나온다.** 리포트 payload와 dev_probe에서만.
- 키 캡션(`A` `D` `Space` `E` `R`)은 §11.9-3의 예외 1종으로만 예외 처리된다. 그 밖에 이 오버레이가 그리는 글자는 0개다.

### 11.6 Focus / Selection

이 장르에는 focus가 없다.

- default focus: **없음.**
- focus 표시: **없음.** 커서, 선택 테두리, 하이라이트 아웃라인을 그리지 않는다.
- mouse: 이 Kit은 마우스를 사용하지 않는다. `ppp_grab`/`ppp_throw`는 키 전용. 포인터 입력을 무시한다.
- keyboard/controller: 좌/우/점프/도구/리셋 5개 물리 키.
- target 제거 시 fallback: 대상 개념이 없다. 항상 물리가 대상을 정한다.
- screen close 후 restore: `BubbleOverlay`가 닫히면 포커스를 아무 Control에도 돌려주지 않는다(포커스를 받는 Control이 없다). 셸이 focus를 가지면 `Context.allowed_actions`만 갱신한다.

### 11.7 화면 상태 표

| 화면 | initial | normal | focus | active | 실패 | 성공 | 복귀 |
|---|---|---|---|---|---|---|---|
| `intro` (레벨 진입) | 화면 밖에서 월드 페이드인 0.45s, `BubbleOverlay`가 필요한 키 표시(최초 1회만) | 배경만 보임, 입력 차단 | n/a | n/a | n/a | n/a | 아무 키/Space → `play` |
| `play` | — | 월드 전용 | n/a | 도구 충전 스쿼시, 접촉 시 파편/셰이크, 시간알 획득 링 | `dead`: 전체 `Color(0,0,0,0.86)` 0.6s 페이드 | `clear`: 흰색 0.35s 플래시 후 페이드아웃 0.55s | R 리셋 / Space 진행 / Esc 셸 |
| `dead` | 알파 0.86 검은 화면 | 아무것도 없음 | n/a | n/a | — | — | 0.6s 후 자동 `play` (hp 전량 복구, 바디 재구성) |
| `clear` | 흰색 플래시 0.35s | 레벨 이름 카드 0.55s | n/a | n/a | n/a | — | 0.9s 후 다음 슬롯 `intro` |
| 런 완료 | — | — | n/a | n/a | n/a | `requested(&"run_complete", …)` 1회. 화면 없음 | 앱이 route 결정 |
| Esc 메뉴 | — | — | Shell 소유 | Shell 소유 | — | — | Shell이 `input_enabled` 복원 |

### 11.8 톤앤매너와 이미지 제작 명세

**이 Kit의 이미지 자산은 0개다.** `PROJECT_DECISIONS.md` §10의 GPT 이미지 파이프라인은 이 Kit에 적용되지 않는다. `IMAGE_ASSET_WORKFLOW.md`, `VISUAL_DIRECTION.md`, 개인 화풍 코어, Gold Standard, A/B Style Reference는 **전부 비적용**이다. 위 §11.2~11.3의 절차 생성 규칙이 이 Kit의 유일한 시각 제작 기준이다.

적용하지 않는 항목:

| 항목 | 이 Kit에서 |
|---|---|
| 개인 화풍 코어 | 비적용. |
| 프로젝트 아트 층(인물/의상/무대) | 비적용. 이 Kit에는 인물이 없다. |
| A/B Style Reference | 비적용. |
| Gold Standard | 비적용. |
| GPT 이미지 생성 | **금지.** 이미지가 0개여야 하므로. |
| `IMAGE_ASSET_WORKFLOW.md` 후처리 허용 목록 | 비적용(처리할 이미지가 없다). |
| 기계적 후처리(알파 매트, 아틀라스, 색 프로파일) | 비적용. |
| `core/procedural`의 sdf/raster/posterize | **적용.** 이것이 이 Kit의 "제작 방식"이다. |
| 톤: 단색 평면 + 기하 | 적용. 그라디언트 금지, 노이즈 텍스처 금지, 아웃라인은 잉크 1픽셀. |
| 7역할 팔레트, `bg_*` 대비 `ink` 명도차 ≥ 0.42 | 적용. 테스트로 검증. |
| 톤앤매너 판정 기준 | 실제 플레이 화면 720p 캡처 3종(레벨 1 / 레벨 7 / 도구 충전 중)에서 본다. |
| 산출물 규격 | 이미지 파일 없음. 픽셀 데이터는 `Image` 객체로 런타임 생성. |
| 720p/FHD/QHD 판정 | §17. |

**절차 비주얼 톤 요약:** 이 Kit의 시각 제작 기준은 위 표가 전부다 — 이미지 파일 0개, `core/procedural` 7역할 팔레트, 3층 물리 반응 배경, 그라디언트/노이즈 금지, 잉크 1픽셀 아웃라인. `docs/KIT_WORKFLOW.md` §8이 요구하는 "Kit별 톤앤매너·이미지 제작 명세"를 이 표가 대체하며, 별도 시각 명세 문서를 만들지 않는다(자산이 0개이므로 분리를 낭비하지 않는다).

### 11.9 플레이어 노출 텍스트 — 닫힌 화이트리스트

**정본:** `docs/research/round_2026_09_26/ROUND_PLAN.md` §11.3. 이 절이 그 3개 규칙을 이 Kit에 집행하는 형태이며, **§11.9·§11.10이 이 기획서 안에서 §11.1~§11.8과 충돌하면 이 절이 이긴다.**

| # | 승인 규칙 (원문 요지) | 이 Kit에서의 집행 수단 |
|---|---|---|
| WT-1 | 세계관 문서는 **제작 전용 정본**이다. 인용은 `제작 전용` 표시가 있는 절 안에서만 | §11.9-1. §2.4·§6.2·§10.4에 `> **[제작 전용]**` 배너를 넣었다 |
| WT-2 | 플레이어 노출 텍스트는 **세 종류뿐** — 화면 이름 · 버튼 라벨 · 단수 명사 하나. **설명문 0개** | §11.9-2. **화이트리스트 10개 슬롯(9 레벨 + 키 캡션 1종).** 표에 없는 문자열은 금지 |
| WT-3 | **삭제한 설명을 되채우는 장치를 만들지 않는다.** 도감·저널·해설 NPC·엔딩 요약 | §11.10. §16.1의 `test_ppp_no_refilling_lore_device`가 식별자 0건을 검사 |

**WT-2가 이 Kit에서 뜻하는 것:** 플레이 중(`play` 페이즈) 화면 문자열은 **0개**다(§11.4). 남는 것은 전환 0.9초의 레벨 이름 카드 1줄과 Input Bubble의 키 심볼뿐이다. 그 두 개조차 아래 표의 값만 쓴다.

#### 11.9-1 제작 전용 — 이 Kit의 제작 정본

세계관 정본은 `docs/world/**`(W1 소유, 동시 개정 중)다. **이 Kit은 `docs/world/**`를 읽지 않는다.** 여기서 바인딩되는 것은 경로와 역할뿐이다. `docs/world/**`를 `load`/`preload`/`ResourceLoader` 인자로 쓰는 코드 **0건**을 유지한다(§16.1 `test_ppp_no_forbidden_shortcuts`의 `test_no_image_loading`과 같은 방식으로 스캔한다).

| 분류 | 이 Kit에서의 위치 | 플레이어 노출 |
|---|---|---|
| 세계관 정본 | `docs/world/**` | **없음** |
| 도구 이름 7종 | `content/tools/*.json`의 `name` (§10.4) | **없음.** §11.5 "어디에도 안 나온다" |
| 레벨 이름 9종 | `content/levels/*.json`의 `name` | **있음.** `intro`/`clear` 전환 0.9초 동안 `LevelTitle` 카드 1줄. 그 외 0회 |
| 재료 9종 이름 | `domain/material_table.gd` | **없음** |
| 바디 종류 13종 이름 | `domain/body_kind.gd` | **없음** |
| 레벨 `id` (`lvl_*`) · 도구 `id` (`tool_*`) | 전 authored JSON | **없음.** 카드에 `id`를 쓰지 않는다 |
| `place.*` `fix.*` `loc.*` 축 ID | §7.8 / §14.8 | **없음** |
| 관측 id `ppp.*` (`meta`, `observation`) | `domain/run_state.gd` | **없음.** 셸로만 나간다 |

#### 11.9-2 화이트리스트 — 닫힌 목록 (10슬롯)

**이 표가 전부다.** 표에 없는 문자열이 화면에 1개라도 뜨면 구현 실패이며 §16.1의 `test_no_player_text_outside_whitelist`가 잡는다. 슬롯을 늘리려면 **이 표를 먼저 고친다.**

| # | 문자열 | 화면 | 분류 | 나오는 곳 | 이게 말하는 것 / 말하지 않는 것 |
|---:|---|---|---|---|---|
| T1 | `분필 선반` | 전환 `intro`·`clear` | **화면 이름** | `content/levels/lvl_chalk_shelf.json`의 `name` | 레벨 이름만 말한다. 이 안의 장애물·목표·해법은 말하지 않는다 |
| T2 | `구르는 동전` | 전환 `intro`·`clear` | **화면 이름** | `lvl_rolling_coin.json`의 `name` | 〃 |
| T3 | `유리 회랑` | 전환 `intro`·`clear` | **화면 이름** | `lvl_glass_gallery.json`의 `name` | 〃 |
| T4 | `들리는 판` | 전환 `intro`·`clear` | **화면 이름** | `lvl_lifting_slab.json`의 `name` | 〃 |
| T5 | `바람 장부` | 전환 `intro`·`clear` | **화면 이름** | `lvl_wind_ledger.json`의 `name` | 〃 |
| T6 | `미끄러운 먹` | 전환 `intro`·`clear` | **화면 이름** | `lvl_slippery_ink.json`의 `name` | 〃 |
| T7 | `부러진 이빨` | 전환 `intro`·`clear` | **화면 이름** | `lvl_broken_teeth.json`의 `name` | 〃 |
| T8 | `빈 열쇠구멍` | 전환 `intro`·`clear` | **화면 이름** | `lvl_hollow_keyhole.json`의 `name` | 〃 |
| T9 | `태엽 종` | 전환 `intro`·`clear` | **화면 이름** | `lvl_clockwork_bell.json`의 `name` (증명용, §15.4) | 〃 |
| T10 | (키 심볼) | `intro` 페이즈 Input Bubble | **키 캡션 — 예외 1종** | `presentation/bubble_overlay.gd` | §11.9-3 |

**버튼 라벨 사용 횟수: 0회.** 이 Kit의 UI 버튼은 Esc 메뉴(Shell 소유)뿐이라서 (§11.4) 라벨이 없다. 라벨이 필요해지면 Shell에 요청한다. **이 Kit이 직접 `Button`을 만들어 라벨을 붙이는 것은 금지** — 라벨을 그 순간 규칙 2의 분류 2(버튼 라벨) 자리를 새로 열게 되고, 그 자리가 세계관 해설로 채워질 위험이 가장 크다.

**단수 명사 하나(분류 3) 사용 횟수: 0회.** 이 Kit은 그 자리를 비워 둔다.

**값의 출처 규칙:** T1~T9의 문자열은 **오직 `content/levels/*.json`의 `name` 필드에서만** 나온다. `presentation/`·`domain/`·`systems/`·`module.gd`에 이 9개 문자열을 리터럴로 박아 두지 않는다(`LevelTitle`은 `LevelSpec.name`만 그린다). 그래야 §10.1의 "레벨 추가 = JSON 1개 + index 1줄"이 화면 쪽에서도 성립한다.

#### 11.9-3 키 캡션 — 분류 4 (예외 1종, 근거 명시)

WT-2가 허용하는 세 종류에 `AGENTS.md` Input Bubble 계약이 요구하는 물리 키 표시가 들어가지 않는다. 이 예외를 **명시적으로** 등록한다. 숨기면 §16.1의 테스트가 튜토리얼 문장을 통과시켜 버린다.

| 항목 | 값 |
|---|---|
| 정당 근거 | `AGENTS.md` Input Bubble 계약 — "설명문으로 기능을 해설하지 않음", "리바인딩 시 실제 바인딩 표시" |
| 값 | `ppp_move_left` `ppp_move_right` `ppp_jump` `ppp_grab` `ppp_reset_level` 5개 바인딩에서 뽑은 **실제 물리 키 심볼**만. `A` `D` `Space` `E` `R` |
| 길이 | 공백 포함 **3자 이하** |
| 개수 | **5개.** `§13.4`의 `rising` bubble이 5칸이므로 개수도 5로 고정된다. `GRID_COLUMNS = 3` 고정 셀 5개(§13.4 표) |
| 금지 | 키 이름·동사·문장. `점프` `이동` `잡기` `리셋` 같은 단어 **금지** |
| 금지 | 캡션 옆에 무엇을 설명하든 금지. 캡션 옆 설명 텍스트 0자 |
| 리바인딩 | §13.4에 리바인딩 기능이 없으므로 글리프는 고정이다. 그래도 `presentation/bubble_overlay.gd`에 키 문자열 리터럴을 두지 말고 `InputMap.action_get_events()` 조회 결과에서 뽑는다(§16.1 `test_cells_are_stable`과 같은 입력 경로) |

#### 11.9-4 화이트리스트에 **없는** 것 (이 Kit이 절대로 그리지 않는다)

"안 되지만 아직 아무도 안 물어본" 항목을 미리 못 박는다. **전부 금지이며 화이트리스트에 추가하지 않는다.**

| tempting 대상 | 어디에 있나 | 왜 금지인가 |
|---|---|---|
| 도구 이름 7종 | `content/tools/*.json` `name` | §11.5, §10.4 |
| 재료 이름 9종 · 바디 종류 13종 | `domain/material_table.gd` `domain/body_kind.gd` | §11.4 |
| 레벨 `id` `lvl_*` · 도구 `id` `tool_*` | authored JSON | `id`는 저장 키다 |
| 레벨 지형·목표 수·해법 | `content/levels/*.json` | "목표 안내 문장 없음" (§11.4) |
| 런 진행 pip의 숫자 | 전환 화면 | §2.1을 고쳤고 §11.9-2가 금지한다. **pip은 도형 8개 고정, 숫자 0개** |
| `objective_count` / `objective_needed` / `player_hp` / `deaths` / `resets` | `domain/world_state.gd` | §11.4 "숫자 카운터 없음". `RIFT` 충전 링이 말한다 |
| `meta.unseen_levels` | `domain/run_state.gd` | `requested` payload의 **정수**일 뿐이다. 이 Kit은 이를 문자열로 바꾸지 않는다(§18.7) |
| `place.*` `fix.*` `loc.*` 축 ID | §7.8 / §14.8 | 축 계산용 |
| `ppp.*` 관측 id | `domain/run_state.gd` | 셸로만 나간다 |
| 물리 키 **이름**(`ppp_jump` 등 action id) | `module_manifest.tres` `input_actions` | 화면에는 §11.9-3의 **심볼**만. action id는 저장·계약용 |
| 조작법·툴팁·목표 안내·튜토리얼 | 어디에도 없음 | §11.4, §2.1 |
| `docs/world/**` 인용문 | W1 정본 | WT-1. 읽는 코드조차 0건 |

### 11.10 설명을 되채우는 장치 — 금지

`AGENTS.md` "세계관의 제작과 게임 내 전달"이 이미 전 Kit에 건 금지를, **이 Kit이 실제로 만들기 쉬운 장치 단위로** 다시 써서 못 박는다. 아래 "금지되는 행동"이 구현자가 실제로 쓰려는 코드다.

| # | 장치 | 이 Kit에서 금지되는 구체 행동 |
|---|---|---|
| PF-01 | **도감(codex)** | 도구 7종·레벨 9종·재료 9종·바디 13종을 목록으로 보여주는 화면·패널·토글을 만들지 않는다. 8레벨 시퀀스에서 "아직 못 본 레벨" 목록을 보여주는 UI도 금지 — 그건 도감이다 |
| PF-02 | **저널(journal)** | `levels_seen` `run_seed` `sequence` `applied_mutations` `deaths` `resets` `elapsed` 를 읽어 쓰는 기록 화면·탭·토글을 만들지 않는다. `requested(&"run_complete")` payload는 **셸** 것이고 이 Kit은 그 안에 문자열을 넣지 않는다(§18.7) |
| PF-03 | **해설 NPC(lore NPC)** | 이 Kit에는 사람이 없다. `TOOL_PLACEMENT` 바디에 `E`로 열리는 대화·툴팁·설명 패널을 붙이지 않는다. `ppp_grab`는 픽업/놓기/던지기 3상태뿐이다(§13.1) |
| PF-04 | **엔딩 요약(ending summary)** | `run_complete` 뒤에 "그래서 무슨 일이 있었냐"를 보여주는 화면·카드·요약을 만들지 않는다. 셸이 route를 결정하고 그 화면은 셸의 것이다(§3.2 D6). **이 Kit이 엔딩 텍스트를 만들어 전달하지 않는다** |
| PF-05 | **오디오 해설** | `Voice` 버스 이벤트 0개(§12 표는 `SFX`/`Music`만). 대사·보이스·내레이션을 이벤트 하나로 넣지 않는다 |
| PF-06 | **레벨 카드 확장** | `LevelTitle` 카드를 1줄 이름에서 늘리지 않는다. 레벨 소개·추천·난이도·이전 기록·별점을 붙이는 순간 WT-2를 위반한다. 카드는 **이름 1줄 그 자체**다 |
| PF-07 | **일시 배너·툴팁** | 특정 passage 통과 시 이유를 알려주는 힌트·배너·툴팁을 만들지 않는다(§18.2). 목표는 `RIFT`의 충전 링이 말한다 |
| PF-08 | **플레이 중 이름 표기** | 바디 위에 이름표를 붙이지 않는다. `id` `material` `kind` `tool` 값을 그리는 코드 0건 |

---

## 12. 오디오 이벤트 표 (C2 매니페스트 형태)

`modules/physics_puzzle_platformer/audio_manifest.gd`. `ROUND_PLAN.md` C2에 선언된 형태 그대로다. W3가 제공하는 `audio_event_player.gd`가 이 표를 소비한다. **새 버스를 만들지 않는다**(`Music` `SFX` `UI` `Voice`만 사용).

```gdscript
const audio_manifest: Dictionary = {
	"id_prefix": "ppp",
	"events": [
		{"id": "step_paper",  "file": "res://modules/physics_puzzle_platformer/audio/step_paper.wav",  "bus": "SFX", "max_polyphony": 4, "volume_db": -14.0},
		{"id": "step_stone",  "file": "res://modules/physics_puzzle_platformer/audio/step_stone.wav",  "bus": "SFX", "max_polyphony": 4, "volume_db": -13.0},
		{"id": "step_glass",  "file": "res://modules/physics_puzzle_platformer/audio/step_glass.wav",  "bus": "SFX", "max_polyphony": 3, "volume_db": -15.0},
		{"id": "jump",        "file": "res://modules/physics_puzzle_platformer/audio/jump.wav",        "bus": "SFX", "max_polyphony": 2, "volume_db": -15.0},
		{"id": "land_soft",   "file": "res://modules/physics_puzzle_platformer/audio/land_soft.wav",   "bus": "SFX", "max_polyphony": 3, "volume_db": -13.0},
		{"id": "land_hard",   "file": "res://modules/physics_puzzle_platformer/audio/land_hard.wav",   "bus": "SFX", "max_polyphony": 2, "volume_db": -8.0},
		{"id": "tool_grab",   "file": "res://modules/physics_puzzle_platformer/audio/tool_grab.wav",   "bus": "SFX", "max_polyphony": 2, "volume_db": -12.0},
		{"id": "tool_charge", "file": "res://modules/physics_puzzle_platformer/audio/tool_charge.wav", "bus": "SFX", "max_polyphony": 1, "volume_db": -16.0},
		{"id": "tool_throw",  "file": "res://modules/physics_puzzle_platformer/audio/tool_throw.wav",  "bus": "SFX", "max_polyphony": 3, "volume_db": -11.0},
		{"id": "impact_soft", "file": "res://modules/physics_puzzle_platformer/audio/impact_soft.wav", "bus": "SFX", "max_polyphony": 5, "volume_db": -14.0},
		{"id": "impact_hard", "file": "res://modules/physics_puzzle_platformer/audio/impact_hard.wav", "bus": "SFX", "max_polyphony": 4, "volume_db": -8.0},
		{"id": "shatter",     "file": "res://modules/physics_puzzle_platformer/audio/shatter.wav",     "bus": "SFX", "max_polyphony": 4, "volume_db": -9.0},
		{"id": "egg_take",    "file": "res://modules/physics_puzzle_platformer/audio/egg_take.wav",    "bus": "SFX", "max_polyphony": 2, "volume_db": -6.0},
		{"id": "rift_ready",  "file": "res://modules/physics_puzzle_platformer/audio/rift_ready.wav",  "bus": "SFX", "max_polyphony": 1, "volume_db": -4.0},
		{"id": "rift_enter",  "file": "res://modules/physics_puzzle_platformer/audio/rift_enter.wav",  "bus": "SFX", "max_polyphony": 1, "volume_db": -3.0},
		{"id": "hurt",        "file": "res://modules/physics_puzzle_platformer/audio/hurt.wav",        "bus": "SFX", "max_polyphony": 2, "volume_db": -6.0},
		{"id": "reset",       "file": "res://modules/physics_puzzle_platformer/audio/reset.wav",       "bus": "SFX", "max_polyphony": 1, "volume_db": -7.0},
		{"id": "level_clear", "file": "res://modules/physics_puzzle_platformer/audio/level_clear.wav", "bus": "SFX", "max_polyphony": 1, "volume_db": -5.0},
		{"id": "run_clear",   "file": "res://modules/physics_puzzle_platformer/audio/run_clear.wav",   "bus": "SFX", "max_polyphony": 1, "volume_db": -3.0}
	]
}
```

**19개 이벤트. ID는 전부 `ppp_` 접두사.**

### 발화 조건 (언제 울리는가)

| 이벤트 | 트리거 | 쿨다운 | 조건 |
|---|---|---|---|
| `step_paper` / `step_stone` / `step_glass` | 지면 위에서 수평 속도 `>40px/s` | `0.18s` | 발밑 바디의 재질로 고른다. |
| `jump` | 점프 성공(`JUMP_CUT` 미적용) | — | |
| `land_soft` / `land_hard` | 착지, 상대속도 `>120` / `>300` | — | |
| `tool_grab` | `carry` 성공 | `0.22s` | |
| `tool_charge` | 충전 시작 | `0.5s` | 루프가 아니라 1회. |
| `tool_throw` | 던짐 성공 | `0.22s` | |
| `impact_soft` / `impact_hard` | 임계 초과 접촉. 상대속도 `<420` / `>=420` | `0.06s` | 다중 접촉이면 스텝당 1회. |
| `shatter` | 바디 파괴 | — | `breakable` 바디만. |
| `egg_take` | 시간알 획득 | — | `objective_needed`와 무관하게 매번. |
| `rift_ready` | 틈이 처음 열림 | — | |
| `rift_enter` | 틈 진입으로 클리어 | — | |
| `hurt` | `dmg_a` 성공 | `0.65s`(`INVULN_TIME`) | |
| `reset` | `R` 입력 | — | |
| `level_clear` | 레벨 클리어 | — | |
| `run_clear` | 8슬롯 완료 | — | |

**금지:** 상시 앰비언트, 음악 루프, 보이스, 대사, 발자국 보컬라이징, UI 호버음. Esc 메뉴 음은 Shell 소유다.

**W3 의존 처리의 강제:** W3가 아직 없으면 `AudioSink`는 **조용한 no-op**이다. 그 상태에서도 `step_director`는 이벤트 `Dictionary`를 반환해야 하고, 테스트는 **이벤트 발생 여부**를 검증한다(소리 파일 유무가 아니라). 오디오 파이프라인이 나중에 붙어도 모듈 코드는 바뀌지 않는다.

---

## 13. Input

### 13.1 Game actions

물리 키는 domain에 쓰지 않는다. `InputMap` action 이름을 문자열로 선언하고 `ModuleContext`로만 조회한다.

| intent | InputMap action | 기본 물리 키 | 별칭 | gameplay 의미 |
|---|---|---|---|---|
| 좌 이동 | `ppp_move_left` | `A` | `←` | 지면/공중 가속. |
| 우 이동 | `ppp_move_right` | `D` | `→` | 지면/공중 가속. |
| 점프 | `ppp_jump` | `Space` | — | `COYOTE_TIME` / `JUMP_BUFFER` / `JUMP_CUT` 적용. |
| 도구 | `ppp_grab` | `E` | — | 빈손: 픽업 / 손에 도구: **놓기**. 누르고 있으면 충전. |
| 리셋 | `ppp_reset_level` | `R` | — | 레벨 물리를 authored 시작 상태로 되돌린다. |
| 셸 | `ui_cancel`(Shell 소유) | `Esc` | — | **이 Kit이 등록하지 않는다.** `requested(&"menu", {})`만 방출한다. |

`module_manifest.tres`의 `input_actions` = `["ppp_move_left", "ppp_move_right", "ppp_jump", "ppp_grab", "ppp_reset_level"]`.

**런타임 등록:** `module.gd::_ensure_actions()`가 `core/services/input_router/input_router.gd:7` `configure_actions()`와 같은 방식으로 `InputMap.add_action()` + `InputMap.action_has_event()` 가드를 쓴다. **`project.godot`을 건드리지 않는다**(W0 소유권 준수).

**`ppp_grab`의 3가지 동작 (입력값이 아니라 상태로 분기):**

| 상태 | 결과 |
|---|---|
| 빈손 + 픽업 반경(`GRAB_RADIUS = 26px`) 내 `TOOL_PLACEMENT` | 획득. `tool_cooldown = 0.22s`. |
| 손에 도구 + 짧게 누름(`< TOOL_HOLD_HINT`) | **던진다.** `TOOL_THROW_IMPULSE * impulse_scale`. 충전 시간에 비례해 `+0..40%`. |
| 손에 도구 + `0.35s` 이상 누름 | 놓고 **다시 집는다**(연속 토글 방지). 쿨다운 0. |

충전 만충은 `0.6s`. `use`가 `shove` / `cool_field`인 도구는 충전 대신 **누른 순간 1회 발동**한다.

### 13.2 `execute_command` 계약

셸/앱/테스트 경로와 키 경로가 **같은 함수**를 탄다.

| command | payload | 동작 |
|---|---|---|
| `move` | `{"axis": -1.0 \| 0.0 \| 1.0}` | 이동 축 설정. |
| `jump` | `{"pressed": true \| false}` | 점프 / 컷. |
| `tool` | `{"pressed": bool, "held": 0.0..1.0}` | 도구 상태. |
| `reset` | `{}` | `R`과 동일. |
| `menu` | `{}` | `requested(&"menu", {})`. |
| `seed_run` | `{"seed": int}` | **개발/테스트 전용.** 유효한 시드면 `run_state`를 재선택. `context.arrival["ppp_seed"]`와 같은 경로. |
| `abort` | `{}` | `requested(&"portal", {"exit": "back"})`. |

`context.allows_action()`가 false면 전부 `false`를 반환한다. 버튼 callback도 같은 가드를 통과한다(`docs/MODULE_CONTRACT.md`).

### 13.3 `context.arrival` 계약

| 키 | 타입 | 기본 | 의미 |
|---|---|---|---|
| `ppp_seed` | int | 없음 | `1..2^31-1` 유효. `run_state`가 없으면 이 시드로 첫 시퀀스를 뽑는다. |
| `ppp_sequence` | `Array[String]` | 없음 | 레벨 8개 ID. 유효하면 시퀀스를 **이 배열로 고정**한다(개발/캡처 전용). `ppp_seed`보다 우선. |
| `ppp_tools` | `Array[String]` | 없음 | 도구 8개 ID. `ppp_sequence`와 함께만 유효. |
| `ppp_start_cursor` | int | 없음 | `0..7`. 시작 슬롯. |
| `key_profile` | `Array[String]` | 없음 | §13.4. |
| `previous_key_profile` | `Array[String]` | 없음 | §13.4. |
| `language` | String | `"ko"` | `LevelTitle` 카드 언어. |
| `worldstate` | Dictionary | 없음 | `core/worldstate` 스토어가 넘기는 **읽기 전용 축 뷰 참조**(§7.8.2). `body` / `creature` / `place` 세 축을 담는다. 없으면 이 Kit은 축 없이 동작한다(레벨 authored 상태만). **쓰기 금지.** |

`ppp_sequence` / `ppp_tools`는 **화면 버튼으로 갈 수 없는 경로**다. `arrival`에만 존재한다. 이것이 "레벨 에디터 없음" 결정(§2.5)의 실행 지점이다.

### 13.4 Input Bubble 전환

레퍼런스 `modules/first_entry`와 **동일한 API 이름·상태 문자열·상수**를 쓴다. 새 이름을 만들지 않는다.

| 항목 | 값 |
|---|---|
| 이전 구간 required physical keys | `context.arrival["previous_key_profile"]`. 없으면 빈 배열. |
| 이 구간 required physical keys | `["ppp_move_left", "ppp_move_right", "ppp_jump", "ppp_grab", "ppp_reset_level"]` (5개, 고정) |
| restore 되는 bubble | 이전 프로필 ∩ 현재 프로필. 다른 구간의 키 집합과 겹치지 않으므로 보통 빈 집합. |
| rising bubble | 현재 프로필 전부(5개). |
| popped 흔적으로 남는 bubble | 이전 프로필 − 현재 프로필. |
| bubble 완료 조건 | 5개 전부 `popped`, 또는 0.4s 경과. 동시 `intro → play`. |
| `GRID_COLUMNS` | `3` (`first_entry.gd:15`와 동일) |
| `BUBBLE_DURATION` / `ABSORPTION_DURATION` | `0.45` / `0.45` (`first_entry.gd:16-17`와 동일) |
| 고정 셀 | `ppp_move_left`(0,0) `ppp_move_right`(1,0) `ppp_jump`(2,0) `ppp_grab`(0,1) `ppp_reset_level`(1,1). 저장 후에도 불변. |
| 상태 머신 | `rising`(0.45s 아래에서 상승) → `intact` → 실제 키 입력 시 `popped` + `absorption 0.45s`. |
| `set_key_profile` 재호출 | 이 Kit은 런타임에 호출하지 않는다(키 집합이 레벨마다 안 바뀐다). 호출되면 `PROJECT_DECISIONS.md` §9 규칙 3~4를 그대로 구현한다. |
| 설명 문구 | **없음.** `BubbleOverlay`에 장문 0자. 물리 키 캡션(`A` `D` `Space` `E` `R`)만. |
| 리바인딩 | 리바인딩 기능 자체가 없다. 캡션은 고정. |

**레벨 전환 중에는 버블을 다시 띄우지 않는다.** 키 집합이 안 바뀌었기 때문이다. `intro` 페이즈는 0.45초 페이드인만 하고 버블이 없다. 버블은 **이 모듈에 처음 진입할 때 단 한 번** 뜬다. 같은 키로 8레벨을 하는 동안 반복하면 "학습"이 "안내"가 된다.

**`BubbleOverlay`는 `presentation/` 소속이며 module HUD가 아니다.** `docs/MODULE_CONTRACT.md`의 "새 장르 구간의 물리 키 집합 학습은 module HUD가 아니라 전환층의 Input Bubble을 사용할 수 있다"를 따른다. 지금 전환층에 일반화된 버블이 없으므로 이 Kit이 동일 계약을 구현해 나중에 인계한다. 버플이 `visible`인 동안 `game_screen.gd`는 `context` 조회를 멈춘다.

### 13.5 포커스

이 장르에는 focus가 없다. §11.6대로 커서/선택 테두리를 그리지 않는다. `BubbleOverlay`는 표시되는 동안 `focus_mode = FOCUS_ALL`인 유일한 Control이며, 키를 누르면 방울이 `popped`가 되며 포커스를 유지한다. 닫히면 `release_focus()`를 호출하고 이후 포커스를 받을 Control이 없다. 셸이 메뉴를 닫으면 `ModuleContext.allowed_actions`만 갱신한다(`MODULE_CONTRACT` "Shell UI는 호출 시에만 보이며, 닫으면 module의 유효한 focus/input으로 복귀").

---

## 14. Save / Load / Reset / 복구

### 14.1 저장

- `module.save_state()`는 §7.6 JSON을 `Dictionary`로 반환한다. 파일을 직접 쓰지 않는다. `SaveService`가 버전과 함께 깊은 복사해 보관한다.
- `schema = 3`, `module = "physics_puzzle_platformer"`, `module_manifest.tres`의 `save_version = 3`과 일치.
- **저장하지 않는 것:** `phase_time`, `contact_flash`, `trail`, 카메라 위치, 스쿼시 위상, 배경 스프링 상태, `frozen` 잔여 시간, `TOOL_HOLD_HINT` 잔여. 모두 진행 의미가 없다.
- **저장하는 것:** `phase`는 `&"play"` 또는 `&"intro"`만 허용한다. `clear` / `dead` 페이즈에서 저장되면 `intro`로 정규화한다(§7.7).

### 14.2 Load sanitize

`docs/MODULE_CONTRACT.md`의 "load_state는 scene tree 진입 뒤, enter 전에 적용" 순서를 따른다. 앱이 호출하며, 이 모듈은 그 시점에 노드 트리를 만들지 않는다.

- §7.7 표를 그대로 적용한다.
- 정규화는 **조용히** 한다. `push_error`/`print`를 남기지 않는다. 콘솔 로그가 캡처를 흐린다. 경고는 `dev_probe`에서만 낸다.
- `assert`를 넣지 않는다. 런을 죽이지 않는다(`ROUND_PLAN.md` C1 스텁 규칙과 같은 취지).

### 14.3 복원 후 재구성 순서

1. `load_state(state)`가 정규화된 `WorldState`를 메모리에 채운다.
2. `enter(context)`에서 `level_factory`가 `cursor`의 레벨을 **authored 상태로** 빌드한다. 변형은 `sequence[cursor].mutations`를 그대로 적용한다(저장된 변형본이 아니라 지시본).
3. 빌드된 바디 위에 저장된 런타임 값을 `spec_id`로 매칭해 덮어쓴다.
4. 매칭 안 되는 `spec_id`는 버린다.
5. `OBJECTIVE`는 처음 `objective_needed`개를 스폰한 뒤 `objective_count`개를 제거해 "이미 먹은 것"을 재현한다. 저장/로드 후 개수가 어긋나지 않게 하는 유일한 방법이다.
6. 도구가 `held`로 저장돼 있으면 스폰해 손에 붙인다. `tool_id`가 레지스트리에 없으면 도구를 버리고 그 슬롯에 `tool_ids[cursor]`로 재지정한다.
7. `phase`가 `play`가 아니면 `intro`로 강제한다.
8. `hitstop = 0.0`, 모든 `frozen = false`, 모든 파편 제거. 첫 프레임이 정지 상태에 갇히지 않게.

### 14.4 Reset — 이 장르의 유일한 되돌리기

**되돌릴 수 있는 것:** 레벨 시작 상태. / **되돌릴 수 없는 것:** 런 시퀀스(레벨 8개), 도구 배정, `run_index`, `levels_seen`, `tools_seen`, `total_objectives`, `deaths`.

| 입력 | 동작 |
|---|---|
| `R` / `execute_command(&"reset")` | 현재 레벨을 `sequence[cursor].mutations` 그대로 재빌드. `objective_count = 0`, `player_hp = PLAYER_HP`, `deaths` **유지**, `resets += 1`, `phase = &"play"`로 직행(`intro` 스킵). `clear` 페이즈면 무시. |
| `dead` 페이즈 | `DEAD_RECOVER_DELAY = 0.6s` 후 자동. `deaths += 1`. 결과는 리셋과 동일하되 `resets`는 늘지 않는다. |
| 런 완료 후 | `R`은 아무 일도 하지 않는다. `requested(&"portal", {"exit": "forward"})`가 이미 나갔다. |

**설계 이유:** Mosa Lina는 물리 상태에 대한 안전장치를 두지 않는다(확인 A6). 여기서는 "안전장치"가 아니라 **되돌릴 수 있는 상태를 레벨 시작 상태 하나로 축소**함으로써 같은 효과를 낸다. 런의 무작위성은 절대 되돌리지 않는다. 그래서 "같은 레벨을 두 번째 만나면 다른 도구로"가 성립한다.

### 14.5 마이그레이션 체인

`migrate_save(old_version, data)`:

| from | to | 변환 |
|---:|---:|---|
| 1 | 2 | `world.objective_target` → `world.objective_needed`(기본 `2`). |
| 2 | 3 | `run.sequence[i].level` → `run.sequence[i].level_id`. `run.cursor` 없으면 `0`. `world.bodies[].body_id` → `spec_id`. |
| ≥ 3 | 3 | 정규화만. |

`old_version > 3`은 **복구 실패로 취급**한다. `load_state`는 새 런(`intro`)으로 시작하고 `requested(&"observation", {"id": "ppp.save_rejected", …})`를 1회 방출한다. 조용히 잘라내지 않는다.

### 14.6 회복 경로 7개 (전수)

| 경로 | 발동 | 복구 |
|---|---|---|
| 사망 | `player_hp <= 0` | 0.6s 자동. 레벨 재빌드, hp 전량, `deaths += 1`. |
| `R` 리셋 | 언제든 | 즉시. 레벨 재빌드. `resets += 1`. |
| 층원 이탈 | `player.y > bounds.max_y + 120` | 즉시 `dead` 전이(데미지 없음). 자동 복귀. |
| `frozen` 교착 | `tool_chill_jar` 정지 | `0.7s` 후 자동 해제. 리셋도 해제. **정지이므로 영구 교착이 없다.** |
| `PROP_SLEEPING` 탑승 | 잠든 상자 위 | `SLEEP_RELAX = 3.0s` 후 자동 해제. |
| 바디 소실 | 시간알/도구 파괴 | `OBJECTIVE_RESPAWN(2.5s)` / `TOOL_RESPAWN(1.4s)` 후 자동 복귀. **리셋 불필요.** |
| 스택 교착 | 물리적으로 전부 막힘 | `R`. |

**경로가 7개뿐이고, 6개가 자동 복구다.** "해결 가능한 해를 제시"하는 시스템은 존재하지 않는다. 전부 상태를 초기 상태로 되돌리는 경로다. 이것이 이 장르의 회복 문법이며, `PROJECT_DECISIONS.md` §14의 "실패한 플랫폼 구간 시작으로 복귀"와 일치한다.

### 14.7 요청 신호

`module.gd`가 방출하는 `requested` 전수. **`finished`는 사용하지 않는다**(§3.2 D6: 클리어 조건이 미확인이고, 완료 화면은 Shell 권한이다).

| kind | payload | 시점 |
|---|---|---|
| `menu` | `{}` | Esc 입력. |
| `portal` | `{"exit": "forward" \| "back", "run_index": int}` | 런 완료 시 `forward`. 앱이 목적지를 해석한다(모듈은 목적지 ID를 모른다). |
| `observation` | `{"id": "ppp.<level_id>.cleared", "text": "<레벨 name> 통과", "meta": {"deaths": int, "resets": int, "elapsed": float, "tools_used": int}}` | 레벨 클리어 1회. |
| `observation` | `{"id": "ppp.run.completed", "text": "균열이 닫혔다", "meta": {"run_index": int, "levels_cleared": int, "levels_total": 8, "deaths": int, "resets": int, "tools_used": int, "unseen_levels": int}}` | 런 완료 1회. `unseen_levels = levels.size() - levels_seen.size()`. |
| `observation` | `{"id": "ppp.save_rejected", "text": "…", "meta": {"found_version": int}}` | §14.5 미래 버전 수락 거부. |
| `input_bubble_profile` | `{"profile": [...], "previous_profile": [...]}` | `enter` 1회. 전환층이 인계받을 때 쓴다. |

**`requested` payload에 화면용 문자열을 넣지 않는다.** `text`는 기록/메타데이터이고 그리지 않는다(`docs/UI_IMPLEMENTATION_RULES.md`의 상태→표현 분리). 플레이 화면에 나오는 글자는 `LevelTitle`의 레벨 이름 하나뿐이다.

---

## 15. Reference Game — 10분+

### 15.1 장르의 Authored Content 단위

**이 Kit의 단위: handmade 레벨 1개 + handmade 도구 1개.**

`docs/KIT_WORKFLOW.md` §3이 요구하는 "같은 Kit 시스템에 서로 다른 Authored Content를 여러 번 넣는 시간"을 채우는 방식은 **레벨 8회 진입**이다. 8번이 전부 다른 물리 상황이고, 매번 다른 도구를 들고 시작한다.

### 15.2 10분 플레이 흐름 (비트 단위)

`ppp_sequence`로 레벨 순서를 고정한 **데모 시퀀스**. 시드 고정 캡처는 `arrival["ppp_sequence"]`로 한다. 이 표의 순서대로면 8레벨이 서로 다른 상호작용을 검증한다.

| 순서 | 레벨 ID | authored content | 이 비트에서 검증하는 시스템 | 이전 시스템 재사용 | 예상 시간 |
|---:|---|---|---|---|---|
| 0 | `lvl_chalk_shelf` | 지형 3 + 시간알 2 | 이동, 점프, 코요테/버퍼, `RIFT` 충전 링 | 최초 | 0:50–1:20 |
| 1 | `lvl_rolling_coin` | 지형 4 + 장애물 1 + 잠든 1 + 해처 2 + 도구 1 | `dmg_a` 데미지, `OBSTACLE_DYNAMIC` 밀기(밀림), `TILE_KINEMATIC` 탑승 | 이동/점프 재사용, `mutations: [material_swap, prop_offset]` | 1:10–1:50 |
| 2 | `lvl_glass_gallery` | 지형 5 + 잠든 3 + 장식 2 + 도구 1 | `wake`, 파괴/파편, 유리 마찰, `mutations` 4종 | 데미지/해처 재사용 | 1:30–2:20 |
| 3 | `lvl_slab_bridge` | 지형 6 + 키네마틱 2 + prop 4 | 동시 발판 2개 타이밍, `PROP_DYNAMIC` 스택 | `wake`/파괴 재사용, `mutations: [prop_size, hazard_shift]` | 1:20–2:00 |
| 4 | `lvl_wind_ledger` | 지형 6 + 키네마틱 1 + prop 3 + 해처 3 | `wind` 변형 효과(선반이 밀린다), `hazard_shift` | 발판 재사용 | 1:10–1:50 |
| 5 | `lvl_slippery_ink` | 지형 5 + prop 4 + 장식 3 | `material_swap` 마찰 0.04 관성 주행, `friction_override` | 해처/데미지 재사용 | 1:20–2:10 |
| 6 | `lvl_broken_teeth` | 지형 4 + prop 6 + `t_max` 상자 2 | `gravity_scale` 변형, 시한 붕괴, `IMPACT_DAMAGE` | 스택 재사용, `mutations: [gravity_scale, prop_offset, prop_size]` | 1:40–2:30 |
| 7 | `lvl_hollow_keyhole` | 지형 6 + 키네마틱 3 + 장애물 1 + prop 3 + 잠든 2 + 장식 3 + 해처 3 + 시간알 6 | 13종 바디 12쌍 동시 접촉, `mutations` 6종 동시 | 전 시스템 재사용 | 2:00–3:00 |
| — | — | — | — | **합계** | **11:00–16:40** |

**각 비트에서 플레이어가 하는 일(구체):**

| 순서 | 플레이어 행동 | 관찰 대상 |
|---:|---|---|
| 0 | 우측 이동 → 계단 2단 점프 → 알 2개 접촉 → 틈 진입 | 리프트/점프 버퍼, 틈 충전 링의 1/2 → 2/2 변화 |
| 1 | 알을 밟아 철 구슬을 굴린다 → 구슬로 높은 알을 밀어 올린다 → 해처를 피해 틈으로 | 구슬이 바닥을 긁는 소리, 데미지 시 비네트, 발판 탑승 |
| 2 | 유리 상자를 깨기 위해 도구를 던진다 → 깨진 파편을 밟아 높은 알에 닿는다 | 파편 밀기, `wake` 후의 재정지, `prop_size`로 커진 상자 |
| 3 | 두 발판의 위상이 겹치는 순간에 알 4개를 순서대로 회수 | 발판 동기화 실패 → `R`로 리셋 후 재시도 |
| 4 | 밀리는 선반 위에서 알을 회수, 해처 3개 중 하나가 이동해 있다 | 바람이 어깨를 밀 때의 이동 실패, `hazard_shift` 후 경로 변화 |
| 5 | 미끄러운 면에서 관성으로 굴러 알까지 밀어 올린다 | 가속도 0에 가까운 `ACCEL_AIR = 620` 체감, `material_swap`으로 마찰이 바뀌었을 때의 정반대 |
| 6 | 상자가 시간제한에 무너지는 타이밍을 보고 그 사이로 통과한다 | `t_max` 붕괴, `gravity_scale = 0.7`이면 낙하가 느려 붕괴 타이밍이 달라짐 |
| 7 | 구리 토크처럼 보이는 장애물을 밀고, 줄 갈고리로 발판에 매달려 상단을 건너, 틈까지 간다 | 6종 변형이 동시에 걸려도 지형이 무너지지 않는지 |

**10분을 채우는 방식:** 위 표의 각 행은 "같은 시스템에 다른 authored content를 넣었다"는 증거다. 대기·긴 이동·반복 노가도·대사 없음. 같은 레벨을 두 번 플레이하지 않는다(데모 시퀀스 기준). 실측 플레이타임은 §19에 기록한다.

**수행 시간이 다른 이유를 채우는 것이 아니라:** 각 레벨은 서로 다른 물리 도구를 쓴다. 1번은 관성, 2번은 파괴, 3번은 위상, 4번은 외력, 5번는 마찰, 6번은 중력, 7번은 복합. 시간이 걸리는 건 그 도구마다 다른 판단이 필요해서다.

### 15.3 아(authored) 단위 목록 — 실제로 만들어야 하는 것

**레벨 8개** (Reference Game이 쓰는 것):

| ID | 이름 | `objective_needed` | `mutable` | 핵심 상호작용 |
|---|---|---:|---|---|
| `lvl_chalk_shelf` | 분필 선반 | 2 | `[]` | 지형, 시간알, 틈 |
| `lvl_rolling_coin` | 굴러가는 동전 | 3 | `material_swap`, `prop_offset` | 장애물, 해처, 키네마틱, 도구 |
| `lvl_glass_gallery` | 유리 회랑 | 4 | `prop_size`, `prop_offset`, `material_swap`, `hazard_shift` | 잠든 유리, 파편, 장식 |
| `lvl_slab_bridge` | 널빤지 다리 | 3 | `prop_size`, `hazard_shift`, `prop_offset` | 키네마틱 2, 스택 |
| `lvl_wind_ledger` | 바람 장부 | 4 | `wind`, `prop_offset`, `prop_size` | 외력, 해처 순환 |
| `lvl_slippery_ink` | 미끄러운 잉크 | 3 | `material_swap`, `prop_offset` | 마찰, 관성 주행 |
| `lvl_broken_teeth` | 금 간 이빨 | 5 | `gravity_scale`, `prop_size`, `prop_offset` | `t_max` 붕괴, 중력 |
| `lvl_hollow_keyhole` | 빈 열쇠구멍 | 5 | 6종 전부 | 전부 |

**도구 7개** — Reference Game이 8 슬롯에 배정하는 후보군(6종):

| ID | 이름 | `use` | 질량 | 이 도구가 여는 상호작용 |
|---|---|---|---:|---|
| `tool_paper_fan` | 종이 부채 | `shove` | 1.4 | 관성 밀기. 무게 없는 물체를 방향 전환 |
| `tool_glass_rod` | 유리 막대 | `throw` | 1.4 | 단거리 투척, `knock` 임펄스 |
| `tool_ember_lash` | 잿불 채찍 | `throw` | 1.6 | 중거리 투척 + `fire_linger`로 자석 물리(§15.3 보강) |
| `tool_lead_weight` | 납 추 | `throw` | 4.2 | `knock` 임펄스 2배, 키네마틱 발판을 밀어 내린다 |
| `tool_rope_hook` | 줄 갈고리 | `anchor_line` | 2.0 | 물리 조인트 5단. 부착점으로 이동 경로 확장 |
| `tool_chill_jar` | 냉각 항아리 | `cool_field` | 1.1 | `frozen`. `PROP_SLEEPING`을 강제로 잠재운다 |

`tool_ember_lash` 보강 필드:

```json
{ "fire_linger": 2.2 }
```

`>0`이면 던진 도구가 맞은 `PROP_DYNAMIC`에 `frozen = true`를 `2.2s` 동안 건다. `frozen` 바디는 데미지를 받지 않지만 `OBSTACLE_DYNAMIC`이 닿으면 밀린다. `§9.5`의 hp 표에 이 예외가 명시되어 있다. `fire_linger`는 `material = "wax"` 바디에만 2배 지속된다(점화 위험). 그 외 `use`는 이 필드를 갖지 않는다.

### 15.4 "authored content 추가 = core 무수정" 증명 절차

Reference Game 검증의 **마지막 단계**로, 아래를 실행하고 `git diff --stat` 출력을 완료 증거에 그대로 붙인다.

1. `content/levels/lvl_clockwork_bell.json` 추가 (9번째 레벨). 초계종 주제. `objective_needed = 3`, `mutable: ["prop_size", "wind"]`, 키네마틱 1, prop 4, 시간알 3, 틈 1. **기존 JSON 구조 밖의 필드를 쓰지 않는다.**
2. `content/tools/tool_moth_wing.json` 추가 (7번째 도구). `use = "shove"`, `reach = 68`, `arc_deg = 140`, 질량 1.4.
3. `content/levels/index.json`에 `lvl_clockwork_bell` 1줄 추가.
4. `content/tools/index.json`에 `tool_moth_wing` 1줄 추가.
5. `arrival["ppp_sequence"]`로 `lvl_clockwork_bell`을 0번 슬롯에 넣어 1회 플레이한다.

**증명 기준:**

```powershell
git diff --stat
```

이 출력이 아래 4개 경로 밖의 파일을 **한 줄도** 건드리지 않아야 한다.

```
content/levels/lvl_clockwork_bell.json
content/tools/tool_moth_wing.json
content/levels/index.json
content/tools/index.json
```

`domain/`, `systems/`, `presentation/`, `module.gd`, `module_manifest.tres`의 diff가 0이면 통과다. 1이라도 있으면 그 구현은 이 Kit의 확장성 목표를 위반했다.

**`ARRIVAL` 순서(5단계)는 반드시 순서대로.** 도구를 먼저 추가하고 레벨을 나중에 추가하면 도구만 남는 인덱스가 생긴다.

### 15.5 하드코딩 방지량

| 항목 | 값 |
|---|---|
| 서로 다른 authored 레벨 수 | 8 (증명용 9) |
| 서로 다른 authored 도구 수 | 6 (증명용 7) |
| 같은 subsystem 재사용 사례 | `level_factory` 8회, `step_director` 8회, `save_codec` 8회, `tool_holder` 8회 |
| 마지막에 data만 추가해 증명 | §15.4 |
| 금지 패턴 | `domain/`·`systems/`에 `lvl_` 문자열 리터럴, `match`의 `bodies` 인덱스 하드코딩 |

`tests/core/test_ppp_reference_content.gd`가 `domain/`·`systems/` 전체를 텍스트 스캔해 `"lvl_"`·`"tool_"` 리터럴이 0개임을 단언한다.

---

## 16. 자동 테스트

전부 GUT 9.7.1. 파일 경로는 `tests/core/` 하위. `tests/core` 밖으로 쓰지 않는다.

### 16.1 파일별 검증 대상

**`tests/core/test_ppp_content_schema.gd`** — 콘텐츠 파서/검증기
| 테스트 | 단언 |
|---|---|
| `test_all_indexed_levels_load` | `index.json`의 모든 ID가 로드된다. 실패 0건. |
| `test_all_indexed_tools_load` | 동일. |
| `test_rejects_missing_required_key` | `schema` 빠진 레벨 → `validate()` 실패. |
| `test_rejects_bad_id_pattern` | `id`가 `^[a-z0-9_]{3,32}$` 위반 → 실패. |
| `test_rejects_unknown_mutable_op` | `mutable`에 `gravity_scale_mul`(오타) → 실패. |
| `test_rejects_objective_needed_above_core_count` | `objective_needed > OBJECTIVE` 개수 → 실패. |
| `test_rejects_spawn_outside_bounds` | `spawn`이 `bounds` 밖 → 실패. |
| `test_rejects_rift_body_duplicate` | `bodies`에 `kind: rift` → 실패. |
| `test_rejects_hull_with_two_points` | `hull`의 `points` 2점 → 실패. |
| `test_rejects_kinematic_outside_bounds` | 궤적 `from`/`to`가 `bounds` 밖 → 실패. |
| `test_rejects_tool_field_pickable` | 도구 JSON에 `pickable` → 실패. |
| `test_rejects_lock_field` | `unlocks`/`opens`/`required_for`/`key_id` → 실패. |
| `test_accepts_all_shipped_content` | 8레벨 + 6도구 전부 통과. |
| `test_no_binary_assets_in_kit_folder` | `modules/physics_puzzle_platformer/**`에 `.png .jpg .jpeg .webp .bmp .svg .ttf .otf .aseprite .kra` 0개. |
| `test_audio_folder_only_wav` | `audio/` 아래 확장자는 `.wav`/`.md`/`.import`/`.gitkeep`뿐. |

**`tests/core/test_ppp_selector.gd`** — 무작위 선택
| 테스트 | 단언 |
|---|---|
| `test_same_seed_same_sequence` | 시드 100개 × 시퀀스 비교, 완전 일치. |
| `test_different_seed_different_sequence` | 시드 1000쌍 중 995쌍 이상 상이. |
| `test_sequence_length_is_eight` | 항상 8. |
| `test_tools_length_is_eight` | 항상 8. |
| `test_indices_within_registry` | 모든 `level_id`/`tool_id`가 레지스트리에 존재. |
| `test_repeats_are_not_suppressed` | 시드 20000번 뽑기에서 5연속 중복이 최소 1회 발생(통계 하한). |
| `test_no_duplicate_suppression_code` | `selector.gd` 텍스트에 `last_` / `seen` 비교 / `weight` / `pity` 중 판정 로직 0건. |
| `test_selector_never_reads_levels_seen` | `levels_seen` 사전에 아무 값을 넣어도 `sequence`가 1바이트도 안 변한다. |
| `test_selector_ignores_cosmetic_rng` | `cosmetic_rng` 1000회 소비 후 `sequence` 불변. |
| `test_mutation_chance_within_bounds` | 10000런에서 변형 있는 비율이 `0.55..0.70`. |
| `test_mutation_max_two` | 전 슬롯에서 `mutations.size() <= 2`. |
| `test_selector_reassigns_removed_level` | 시퀀스의 레벨 ID를 미등록 값으로 바꾼 뒤 로드 → 그 슬롯만 재추첨, 나머지 유지. |
| `test_invalid_seed_resequences_everything` | `run_seed = 0` / `-5` / `2^31` → `sequence` 전체 재생성. |
| `test_save_load_preserves_sequence` | 저장→로드 후 `sequence` 완전 일치(바이트 동일). |

**`tests/core/test_ppp_mutation.gd`** — 변형 6종
| 테스트 | 단언 |
|---|---|
| `test_gravity_scale_changes_only_dynamic_bodies` | `RigidBody2D`의 `gravity_scale`만 변한다. `TILE_*`은 불변. |
| `test_material_swap_targets_shuffled_only` | `shuffled`에 없는 바디의 재료 불변. |
| `test_prop_size_scales_shape_not_mass` | shape 크기 ×, 질량 동일. |
| `test_prop_offset_reflects_at_bounds` | `bounds`를 넘으면 반사되어 `bounds` 안. |
| `test_wind_only_affects_kinematic` | `TILE_KINEMATIC`만 이동. 정적 바디 불변. |
| `test_hazard_shift_rotates_list` | `mutable_hazards` 2개 이상일 때 1칸 순환. 1개면 무변경. |
| `test_mutations_never_touch_geometry` | 6종 × 1000회 적용 후 `TILE_STATIC` 위치/크기, `RIFT`, `spawn`, `bounds` 불변. |
| `test_mutations_are_deterministic_given_seed` | 시드 고정 → 동일 변형 목록. |
| `test_empty_mutable_produces_no_mutation` | `mutable: []`인 레벨은 10000회 무시되고 항상 `[]`. |

**`tests/core/test_ppp_physics_world.gd`** — 단일 물리 세계
| 테스트 | 단언 |
|---|---|
| `test_player_is_rigid_body` | `PLAYER` 노드가 `RigidBody2D`다. `CharacterBody2D` 0개. |
| `test_all_thirteen_kinds_present` | 13종 바디가 모두 스폰된다. |
| `test_interaction_table_is_complete` | 13×13 행렬에 빈 문자열 0개. `—` 0개(모든 쌍에 코드 존재). |
| `test_every_pair_produces_a_rule` | 169쌍 전부 `resolve()`가 `Dictionary`를 반환. |
| `test_player_pushes_prop` | 플레이어가 `PROP_DYNAMIC`를 밀면 그 바디 `x`가 감소한다. |
| `test_prop_pushes_player` | `OBSTACLE_DYNAMIC`가 아래에서 밀면 플레이어 `y`가 증가한다. |
| `test_tool_knocks_prop` | 던진 도구가 `PROP_DYNAMIC`의 속도를 바꾼다. |
| `test_iron_never_destroyed` | 200스텝 충격 후에도 `destroyed == false`. |
| `test_breakable_fragments` | 유리 상자 파괴 시 파편 수 `== material_table` 값. |
| `test_sleeping_wakes_and_ressleeps` | 접촉 → `sleeping == false`, 3.0s 무접촉 후 `true`. |
| `test_kinematic_carries_player` | 발판 위 플레이어의 `x`가 발판 이동을 따라간다. |
| `test_hazard_area_damages_over_time` | `HAZARD_AREA` 위 1초 후 `player_hp` 감소. |
| `test_objective_credit_on_touch` | 접촉 한 번에 `objective_count` +1. 두 번 안 된다. |
| `test_objective_respawns_after_destruction` | 파괴 후 2.5s 뒤 재스폰. |
| `test_tool_placement_survives_hazard` | `HAZARD_AREA` 위에서도 픽업이 사라지지 않는다. |
| `test_determinism_same_seed_300_steps` | 시드 고정 300스텝 후 모든 바디 `x/y`가 1e-4 이내. |
| `test_thin_wall_not_tunnelled` | 최대 낙속(820px/s)으로 24px 두께 벽을 200회 돌파 시도, 통과 0회. |
| `test_heavy_does_not_tunnel_light` | `IRON`(3.2) 위 `PAPER`(0.30) 200스텝 스택, 바닥 관통 0회. |
| `test_no_solution_requirement` | 어떤 레벨도 `solvable` 플래그/해법 데이터가 파싱 결과에 없다. |
| `test_hitstop_freezes_physics` | `hitstop > 0` 동안 모든 바디 속도 0. |

**`tests/core/test_ppp_save_codec.gd`** — 저장
| 테스트 | 단언 |
|---|---|
| `test_round_trip_preserves_state` | 저장→로드→재저장 시 JSON 문자열 완전 일치. |
| `test_round_trip_preserves_partial_progress` | `objective_count = 1`, `player_hp = 3`, 도구를 들고 있는 상태 유지. |
| `test_drops_non_finite_numbers` | `x = NaN` → 0.0으로 치환 + `destroyed = true`. `x = INF` 동일. |
| `test_no_vector_in_payload` | 재귀 탐색으로 `Vector2` 0개. |
| `test_no_node_in_payload` | `Node`/`Resource`/`Callable` 0개. |
| `test_removes_unknown_body_ids` | 미등록 `spec_id` 1개 → 로드 후 바디 수 -1. |
| `test_deduplicates_players` | 플레이어 2개 → 1개. |
| `test_clamps_objective_count` | `objective_count = 99` → `objective_needed`. |
| `test_clamps_hitstop` | `hitstop = 5.0` → `0.055`. |
| `test_unknown_phase_falls_back` | `phase = "wat"` → `intro`. |
| `test_reassigns_missing_tool` | 미등록 `tool_id` → 도구 제거 후 `tool_ids[cursor]` 재지정. |
| `test_migrate_v1_to_v3` | v1 페이로드 → v3으로 변환 후 모든 필수 키 존재. |
| `test_migrate_v2_to_v3` | 동일. |
| `test_rejects_future_version` | `old_version = 4` → `save_rejected` observation 1회, 새 런 시작. |
| `test_does_not_store_presentation_state` | `phase_time`, `contact_flash`, `trail`, `camera` 키 0개. |
| `test_restore_keeps_mutations` | 저장된 `applied_mutations`로 재빌드 시 `§5.4` 결정이 동일. |

**`tests/core/test_ppp_module.gd`** — 모듈 계약
| 테스트 | 단언 |
|---|---|
| `test_enter_does_not_start_gameplay` | `enter` 후 `phase == &"intro"`. |
| `test_intro_blocks_input` | `intro`에서 `execute_command(&"move")` → `false`. |
| `test_reset_command_rebuilds_level` | `reset` 후 `objective_count == 0`, `resets == 1`, `deaths` 불변. |
| `test_reset_preserves_run_sequence` | `reset` 후 `sequence` 불변. |
| `test_menu_request_emitted` | `execute_command(&"menu")` → `requested`에 `menu` 1회. |
| `test_seed_run_command` | `seed_run`으로 시퀀스가 해당 시드 결과와 일치. |
| `test_arrival_sequence_overrides_seed` | `arrival["ppp_sequence"]`가 시드보다 우선. |
| `test_arrival_start_cursor` | `arrival["ppp_start_cursor"]`로 해당 슬롯부터 시작. |
| `test_run_completes_after_eight_levels` | 8회 클리어 후 `run_complete == true`, `portal` forward 1회. |
| `test_run_complete_emits_unseen_count` | `meta.unseen_levels == 9 - levels_seen.size()`. |
| `test_input_disabled_blocks_commands` | `context.input_enabled = false` → 전 명령 `false`. |
| `test_exit_clears_timers_and_signals` | `exit` 후 활성 Timer 0개, 시그널 연결 0개. |
| `test_module_isolation` | 다른 모듈 노드를 찾지 않는다. `/root` 접근 0건(텍스트 스캔). |
| `test_death_recovers_after_delay` | hp 0 → 0.6s 후 `phase == &"play"`, hp 5, `deaths +1`. |
| `test_offmap_falls_are_death` | `y > bounds.max_y + 120` → `dead` 전이. |

**`tests/core/test_ppp_presentation.gd`** — 표현 계층
| 테스트 | 단언 |
|---|---|
| `test_no_persistent_hud_nodes` | 플레이 페이즈에 `visible == true`인 `Label` 0개, `ProgressBar` 0개. |
| `test_no_inventory_panel` | 인벤토리류 노드 0개(`INVENTORY_PANEL` 문자열 0건). |
| `test_level_title_hidden_during_play` | `play` 페이즈에서 `LevelTitle.visible == false`. |
| `test_rift_ring_reflects_objective` | `RIFT` 링 채움 비율 == `objective_count / objective_needed`. |
| `test_tool_sprite_attached_to_player` | 들고 있는 도구 `Sprite2D`의 부모가 플레이어 뷰. 전역 좌표가 아니다. |
| `test_charge_scales_tool_sprite` | 충전 0.0→1.0에서 스케일 1.0→1.28 단조 증가. |
| `test_backdrop_reacts_to_player` | 플레이어가 요소 130px 안으로 들어오면 요소 변위 > 0. |
| `test_backdrop_reacts_to_impact` | `pulse()` 호출 후 인접 요소 변위 > 0. |
| `test_backdrop_settles` | 무입력 1.8s 후 요소 변위 < 1.0px. |
| `test_fore_layer_skips_when_occluding` | `fore` 요소가 플레이어를 덮으면 그 요소가 숨겨진다. |
| `test_palette_ink_contrast` | 9개 레벨 전부 `ink` vs `bg_near` 상대 명도차 `>= 0.42`. |
| `test_no_text_during_play` | `play` 페이즈에 표시 중인 `Label.text`가 비어 있다(레벨 이름 카드 제외). |
| `test_no_player_text_outside_whitelist` | **부정 검사 1.** `res://modules/physics_puzzle_platformer/` 아래 `.gd .tscn .tres .json` 을 `DirAccess` 재귀 순회해 `FileAccess.get_as_text()`로 읽고, §11.9-2의 규칙 R1~R4를 적용한다. **R1**: `presentation/`·`domain/`·`systems/`·`module.gd` 본문에서 `text` `tooltip_text` `title` `placeholder_text` 속성과 `draw_string` `Label` `RichTextLabel` 인자에 쓰인 문자열 리터럴을 전부 뽑고, 그 값이 §11.9-2의 `T1`~`T10` 중 하나와 완전 일치하거나 §11.9-3의 키 캡션 조건(공백 0 · 3자 이하)을 만족하지 않으면 실패. 실패 메시지에 파일·줄·문자열. **R2**: T1~T9의 9개 문자열이 `presentation/`·`domain/`·`systems/`·`module.gd` 리터럴에 **0건**(`LevelTitle`은 `LevelSpec.name`만 그린다). **R3**: `content/levels/*.json` 9개의 `name` 값이 §11.9-2 표와 1:1 일치하고 `1~24자`를 만족. **R4**: `content/**/*.json` 전체에 `title` `text` `desc` `description` `caption` `hint` `subtitle` `lore` `note` `memo` `summary` 키 0건. 주석은 판정 대상이 아니다 |
| `test_720_layout_no_overlap` | 1280×720에서 겹치는 `Control` 쌍 0개. |
| `test_1080_layout_no_overlap` | 1920×1080 동일. |
| `test_1440_layout_no_overlap` | 2560×1440 동일. |

**`tests/core/test_ppp_audio_manifest.gd`** — C2 정합
| 테스트 | 단언 |
|---|---|
| `test_manifest_shape` | `id_prefix == "ppp"`, `events` 배열, 각 항목에 `id`/`file`/`bus`/`max_polyphony`/`volume_db`. |
| `test_all_ids_prefixed` | 전 이벤트 ID가 `ppp_`로 시작. |
| `test_files_under_kit_audio` | 전 `file`이 `res://modules/physics_puzzle_platformer/audio/` 하위. |
| `test_buses_allowed` | `bus` ∈ {`Music`,`SFX`,`UI`,`Voice`}. 새 버스 없음. |
| `test_polyphony_and_volume_ranges` | `max_polyphony` 1..8, `volume_db` -24..0. |
| `test_events_fire_without_audio_player` | `AudioSink`이 `null`이어도 이벤트 카운터 증가. |

**`tests/core/test_ppp_input_bubble.gd`** — 버블 계약
| 테스트 | 단언 |
|---|---|
| `test_bubble_appears_once_on_entry` | `enter` 1회에서만 `rising` 상태. |
| `test_profile_is_five_fixed_actions` | `profile == ["ppp_move_left","ppp_move_right","ppp_jump","ppp_grab","ppp_reset_level"]`. |
| `test_cells_are_stable` | 저장→재진입 후 `bubble_cells` 완전 일치. |
| `test_key_press_pops_its_bubble` | `ppp_jump` 입력 시 `ppp_jump`만 `popped`, 나머지 `intact`. |
| `test_completion_requires_all_popped` | 5개 전부 `popped` 전에는 `play` 진입 불가. |
| `test_rising_then_intact_timing` | `BUBBLE_DURATION = 0.45` 후 `intact`. |
| `test_no_instruction_text` | `BubbleOverlay`의 모든 `Label.text`가 물리 키 캡션(1~6자) 또는 빈 문자열. |
| `test_previous_profile_becomes_popped_trace` | 이전 프로필 키는 `popped`으로 남고 복구되지 않는다. |
| `test_bubble_blocks_module_input` | 버플 `visible` 중 `execute_command` 전부 `false`. |

**`tests/core/test_ppp_reference_content.gd`** — 콘텐츠 확장성
| 테스트 | 단언 |
|---|---|
| `test_eight_levels_have_distinct_geometry` | 8레벨의 바디 좌표 집합이 서로 다르다. |
| `test_every_level_has_objective_and_rift` | 전 레벨 `objective_needed >= 1` + `RIFT` 존재. |
| `test_every_level_bounds_fit_viewport` | 전 레벨 `bounds` 폭 ≥ 1600, 높이 ≥ 640. |
| `test_tool_index_covers_all_referenced_tools` | 레벨이 참조하는 도구가 전부 `tools/index.json`에 있다. |
| `test_no_solution_data_in_content` | authored JSON 전체에 `solution`/`answer`/`hint` 키 0개. |
| `test_domain_has_no_content_id_literals` | `domain/`·`systems/`에 `"lvl_"`·`"tool_"` 리터럴 0개. |
| `test_all_kinds_appear_across_levels` | 13종 바디 중 authored 가능한 11종이 8레벨 합집합에 모두 등장. |
| `test_all_mutation_ops_exercised` | 6종 변형 중 적어도 1개라도 `mutable`에 선언된 레벨이 3개 이상. |
| `test_proof_content_adds_no_core_diff` | `lvl_clockwork_bell` + `tool_moth_wing`가 git diff에서 `content/` 밖을 0건 변경(§15.4). |

**`tests/core/test_ppp_no_forbidden_shortcuts.gd`** — 금지 코드 전수 스캔
| 테스트 | 단언 |
|---|---|
| `test_no_forbidden_constants` | §9.10의 15개 식별자가 `modules/physics_puzzle_platformer/` 전체에 0건. |
| `test_no_procedural_level_generation` | `selector.gd`·`level_factory.gd`에 `randi() 기반 바디 생성`·`스폰 위치 계산` 패턴 0건. 좌표는 전부 `LevelSpec`에서 온다. |
| `test_no_lock_and_key` | `domain/`·`systems/`에 레벨 ID와 도구 ID를 연결하는 맵 0개. `interaction_rules`에 `requires` 0건. |
| `test_no_pity_or_duplicate_suppression` | §16의 selector 테스트와 동일 조건. |
| `test_no_inventory_system` | `inventory` 식별자 0건(`MODULE_CONTRACT` 금지 "모든 장르 공통 Inventory"). |
| `test_no_image_loading` | `load()`·`Image.load`·`ResourceLoader.load` 호출 0건. 텍스처는 전부 `ProceduralCanvas.to_image()` → `ProceduralCanvas.to_texture()`. `Procedural.texture()` 같은 도우미는 **존재하지 않는다.** |
| `test_no_get_node_absolute_root` | `get_node("/root")`·`get_tree().root` 탐색 0건. |
| `test_no_service_locator` | `Engine.get_singleton`·`get_node_or_null("/root/…")` 0건. |
| `test_no_refilling_lore_device` | **부정 검사 2.** `test_no_inventory_system`과 **같은 방식**(코드 텍스트를 읽어 식별자 0건)이고, 판정 대상만 다르다. `res://modules/physics_puzzle_platformer/**` 의 모든 `.gd .tscn .tres .json` 본문을 읽어, **① 주석(`#`~줄 끝)과 문자열 리터럴 내용물을 제거한 뒤** 대소문자 무시 부분 일치로 `codex` `journal` `diary` `lore` `chronicle` `bestiary` `logbook` `encyclopedia` `recap` `epilogue` `afterword` `ending_summary` `ending_text` `story` `history` `exposition` `narration` `caption` `subtitle` `dialog` `dialogue` `speech` `monologue` `memo` `letter` `read_note` `unlock_note` `tutorial` `hint_text` `explain` 가 **0건**이다(노드명·클래스명·함수명·시그널명·사전 키에 걸리면 실패). ② `presentation/` 아래 파일명·씬 이름에 위 토큰 0건. ③ `audio_manifest.gd`에 `bus == "Voice"` 이벤트 0건(§12). ④ `docs/world` 문자열이 `load`/`preload`/`ResourceLoader` 인자로 쓰인 곳 0건. **주석을 먼저 제거하는 이유:** 이 Kit의 코드 주석과 계획에는 "도감", "기록", "설명"이 정당하게 나오므로, 주석까지 매칭하면 판정이 아니라 잡음이 된다 |

### 16.2 실행 명령 (정확한 명령)

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'

# 1) 임포트
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait -PassThru
$p.ExitCode

# 2) 프로젝트 전체 테스트 (run_tests.gd가 tests/core를 수집)
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/run_tests.gd' -NoNewWindow -Wait -PassThru
$p.ExitCode

# 3) GUT core 스윕
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gexit' -NoNewWindow -Wait -PassThru
$p.ExitCode

# 4) 부팅 스윕 (에러 0 확인)
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --quit-after 180 --fixed-fps 60' -NoNewWindow -Wait -PassThru
$p.ExitCode
```

**이 Kit 단독 실행(디버깅용):**

```powershell
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_physics_world.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_selector.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_mutation.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_save_codec.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_content_schema.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_module.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_presentation.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_audio_manifest.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_input_bubble.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_reference_content.gd -gexit
& $GodotExe --headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gtest=res://tests/core/test_ppp_no_forbidden_shortcuts.gd -gexit
```

**콘텐츠 검증 하네스(에디터 아님):**

```powershell
& $GodotExe --headless --path C:\projects\TINProject res://modules/physics_puzzle_platformer/presentation/dev_probe.tscn
```

**시드 고정 Reference Game 캡처(디버깅/스크린샷용):**

```powershell
& $GodotExe --path C:\projects\TINProject --fixed-fps 60 -- --ppp-seed=418324771 --ppp-capture=1
```

`--ppp-capture`는 `arrival`을 주입해 데모 시퀀스(§15.2)를 고정하고 `tests/performance`에 프레임을 저장한다. **릴리스 빌드에 포함하지 않는다.** 플래그 파싱은 `module.gd::_parse_cli()`가 하고, `OS.get_cmdline_user_args()`만 읽는다.

**통과 기준:** 위 11개 파일의 테스트가 **모두 green**이어야 한다. 실패가 있으면 멈추고 기존 실패와 신규 회귀를 구분한다(`AGENTS.md`).

---

## 17. 수동 플레이 과제와 수용 기준

### 17.1 플레이어에게 설명하지 않고 시킬 일

| # | 과제 | 관찰할 것 |
|---:|---|---|
| 1 | 아무 설명 없이 모듈을 진입시킨다. 30초 동안 아무것도 하지 않는다. | Input Bubble가 뜬다. 설명문 0자. 무엇을 해야 하는지 스스로 알아내는가. |
| 2 | 버블이 뜬 채로 `A` `D` `Space` `E` `R`를 한 번씩 누른다. | 각 방울이 개별적으로 터지는가. 다른 방울이 함부로 터지지 않는가. |
| 3 | 아무 키나 눌러 `play`로 넘어간다. 1분 동안 아무 설명 없이 플레이한다. | 첫 meaningful action까지 걸린 시간을 잰다. **목표 30초 이내.** |
| 4 | 첫 레벨에서 시간알 2개를 모은다. | 개수를 세려면 어디를 봐야 하는지 스스로 찾는가. 그때 본 곳이 `RIFT`의 링인가 화면 어딘가의 숫자인가. **숫자가 보이면 실패.** |
| 5 | 의도적으로 철 구슬을 맨 아래로 떨어뜨려 해처에 닿게 한다. | 데미지 반응이 즉각적이고 읽히는가. hp 상태를 어디서 아는가. |
| 6 | 도구를 든 채 1분간 아무것도 하지 않는다. | 도구가 손에 붙어 있는지, 충전 중 스쿼시가 보이는지, 이름이 보이는지. **이름이 보이면 실패.** |
| 7 | `R`을 5번 연타한다. | 매번 같은 레벨 시작 상태로 돌아오는가. 런 시퀀스(레벨 구성)가 바뀌면 실패. |
| 8 | 아무도 안 잡은 상태로 `Esc`를 누른다. | 셸 메뉴가 뜨는가. 닫으면 포커스/입력이 복구되는가. |
| 9 | 저장된 상태에서 앱을 껐다 켜고 계속한다. | 레벨·도구·개수가 그대로인가. |
| 10 | 720p에서 플레이하다 창을 1920×1080으로 바꾼다. | 월드/플레이 영역이 잘리지 않는가. |
| 11 | 4번에서 6번을 40초 안에 못 끝내고 `R`로 리셋 후 다시 한다. | 실패에서 회복 가능한가. 그 사이에 화면에 뭐가 뜬 있었나. |
| 12 | 이기려 하지 않고 3분 동안 아까워 보이는 조합을 일부러 망가뜨려 본다. | 실패에 벌칙(빼기, 경고, 숫자 감소)이 없는가. 리셋 외의 압박이 없는가. |

### 17.2 해상도별 수용 기준

모든 기준은 **플레이 중 상태**에서 판정한다. 전환 카드가 켜져 있는 동안에는 판정하지 않는다.

| 기준 | 1280×720 | 1920×1080 | 2560×1440 |
|---|---|---|---|
| 월드 플레이 영역 유지 | ☐ | ☐ | ☐ |
| `TILE_STATIC` 최소 두께 24px가 1px 이상으로 보임 | ☐ | ☐ | ☐ |
| 시간알(22px 원)이 배경과 구분됨(명도차 ≥ 0.42) | ☐ | ☐ | ☐ |
| `RIFT` 충전 링이 완전히 보인다 | ☐ | ☐ | ☐ |
| `fore` 레이어가 플레이어를 가리지 않음 | ☐ | ☐ | ☐ |
| HUD 없음(상시 표시 Label 0) | ☐ | ☐ | ☐ |
| 조작 설명 문장 0 | ☐ | ☐ | ☐ |
| Input Bubble가 격자 안에서 잘리지 않음 | ☐ | ☐ | ☐ |
| 버블 5개가 3열 2행에 모두 보임 | ☐ | ☐ | ☐ |
| 도구 실루엣이 플레이어와 겹치지 않음 | ☐ | ☐ | ☐ |
| 장문 텍스트/긴 문자열 | 해당 없음 (텍스트 0) | ☐ | ☐ |
| `LevelTitle` 카드가 화면 밖으로 안 나감 | ☐ | ☐ | ☐ |
| Esc 메뉴 open/close 후 복귀 | ☐ | ☐ | ☐ |
| 최대 데이터(13종 바디 64개 + 파편 48개)에서 프레임이 끊기지 않음 | ☐ | ☐ | ☐ |
| 물리 결과가 3해상도에서 동일(시드 고정) | ☐ | ☐ | ☐ |

**마지막 행이 중요하다.** 줌이 1.0 고정이고 월드 단위가 픽셀 단위이므로, 3해상도에서 **동일 시드·동일 입력의 물리 결과가 같아야 한다.** `stretch/mode = canvas_items` + `canvas_items` 스케일이 물리에 개입하지 않아야 한다. 다르면 `WorldState`가 아닌 곳에서 해상도가 물리를 조작하고 있다는 뜻이다.

### 17.3 캡처 기록

| 항목 | 경로 |
|---|---|
| 720p 플레이 | `tests/performance/captures/ppp_720_play.png` |
| 720p 도구 충전 | `tests/performance/captures/ppp_720_charge.png` |
| 720p Input Bubble | `tests/performance/captures/ppp_720_bubble.png` |
| 1080p 플레이 | `tests/performance/captures/ppp_1080_play.png` |
| 1440p 플레이 | `tests/performance/captures/ppp_1440_play.png` |
| 720p 사망 페이즈 | `tests/performance/captures/ppp_720_dead.png` |
| 720p 클리어 페이즈 | `tests/performance/captures/ppp_720_clear.png` |
| 플레이타임 로그 | `tests/performance/ppp_run_log.md` |

PNG 캡처는 `tests/` 아래에 있으므로 이미지 0개 하드 게이트의 예외다(`ROUND_PLAN.md` §5는 각 Kit 폴더를 대상으로 한다). `modules/physics_puzzle_platformer/**` 안에는 PNG가 없어야 한다.

---

## 18. 금지 Shortcut

이 Kit에서 에이전트가 가장 싸게 도망갈 수 있는 구현을 구체적으로 적는다. 전부 `tests/core/test_ppp_no_forbidden_shortcuts.gd` 또는 대응 테스트가 자동 실패시킨다.

### 18.1 레벨 생성

- [ ] **절차적으로 레벨을 만들지 않는다.** `randi()`/`randf()`로 바디 위치·개수·지형을 뽑는 코드 금지. 좌표는 전부 `LevelSpec`에서 온다. `test_no_procedural_level_generation`이 검사한다.
- [ ] `selector.gd`에 "가끔 레벨 지형을 섞는다"는 변형을 추가하지 않는다. 변형 6종은 **물리 계수와 물체 배치만** 건드린다(`§5.3`).
- [ ] 변형이 `TILE_STATIC`·`TILE_KINEMATIC` 궤적·`RIFT`·`spawn`·`bounds`를 건드리지 않는다. `test_mutations_never_touch_geometry`가 검사한다.
- [ ] "레벨이 너무 쉬우면 자동으로 난이도를 올린다"는 로직 금지. `DIFFICULTY_RAMP` 0건.

### 18.2 자물쇠-열쇠

- [ ] **도구 A가 문제 A를 풀게 만들지 않는다.** 특정 레벨 전용 도구, 특정 도구 전용 해처를 만들지 않는다. `test_no_lock_and_key`가 검사한다.
- [ ] 도구 JSON에 `pickable` `opens` `unlocks` `required_for` `key_id` `solution` `answer` `hint` 필드를 넣지 않는다. 스키마에 없다.
- [ ] authored JSON에 `solution`/`answer`/`hint` 데이터를 넣지 않는다. `test_no_solution_data_in_content`가 검사한다.
- [ ] "이 도구로 이 레벨이 풀리는지" 검증 테스트를 만들지 않는다. **해결 가능성 보장은 이 Kit의 금지 사항**이다(확인 A5).
- [ ] 힌트 텍스트로 조작을 보조하지 않는다. 상시 힌트 라벨 0개.

### 18.3 pity · 중복 억제 · 등장률 가중

- [ ] 같은 레벨/도구를 연속으로 뽑지 않도록 보정하지 않는다. 중복은 정상이다(`§5.5`).
- [ ] `weights`, `pick_unique`, `shuffle_bag`, `last_picked` 비교 로직을 넣지 않는다. `test_repeats_are_not_suppressed`가 20000회 통계로 검사한다.
- [ ] `levels_seen`/`tools_seen`를 판정에 읽지 않는다. `test_selector_never_reads_levels_seen`가 검사한다.
- [ ] "나온 적 없는 레벨 우선" 규칙을 넣지 않는다.

### 18.4 인벤토리 · UI

- [ ] **도구 인벤토리 UI를 만들지 않는다.** 슬롯바, 도구 목록, 개수 숫자, 다음 도구 예고 금지. `test_no_inventory_system`이 `inventory` 식별자 0건을 검사한다.
- [ ] 상시 HUD를 만들지 않는다. hp 바, 개수, 시간, 도구 슬롯, 공간명, 키 안내 전부 금지. `test_no_persistent_hud_nodes`가 검사한다.
- [ ] 조작 설명 문장을 화면에 쓰지 않는다. Input Bubble가 대체한다.
- [ ] `RIFT`의 충전 링 대신 숫자 카운터를 쓰지 않는다.
- [ ] 도구 이름을 화면에 쓰지 않는다. `test_no_text_during_play`가 검사한다.
- [ ] placeholder `ColorRect`/`Label`을 월드 오브젝트 최종 표현으로 남기지 않는다. 모든 바디는 `core/procedural` 텍스처를 쓴다.
- [ ] 리롤 버튼, "다음 레벨" 버튼, 레벨 선택 화면을 만들지 않는다. `arrival` 시퀀스만 쓴다.

### 18.5 이미지 · 외부 자산

- [ ] **이미지 파일을 import하지 않는다.** `.png` `.jpg` `.jpeg` `.webp` `.bmp` `.svg` `.ttf` `.otf` `.aseprite` `.kra` 전부 0개. `test_no_binary_assets_in_kit_folder`와 W0의 `tests/core/test_no_binary_assets.gd`가 이중 검사한다.
- [ ] Mosa Lina의 스프라이트·레벨 배치·문구·도구 모양·OST를 복제하지 않는다. 원작은 Steam 스토어 텍스트와 태그만 참고했고 플레이 화면을 직접 보지 못했다. **따라서 구현에 쓰이는 것은 "단일 물리 파이프라인", "handmade + 무작위 선택", "raw random", "lock-and-key 반대" 4가지뿐이고, 나머지는 전부 우리 결정이다.**
- [ ] `core/procedural/` 시그니처를 바꾸지 않는다. 이 모듈은 읽기만 한다.
- [ ] Mosa Lina의 레벨 에디터/Steam Workshop를 따라 인게임 에디터를 만들지 않는다(§2.5).
- [ ] 라이선스가 확인되지 않는 코드를 복사하지 않는다. `core/procedural/`과 `addons/gut`만 사용한다.

### 18.6 아키텍처

- [ ] `project.godot`, `app/app_root.gd`, `addons/`를 수정하지 않는다. 요청만 한다(§21).
- [ ] `/root` 탐색, `get_tree().root` 하강, `Engine.get_singleton`, 서비스 로케이터를 쓰지 않는다. `test_no_service_locator`가 검사한다.
- [ ] 다른 모듈(`first_entry`, `rule_rewriting`, `odd_road_adventure`)을 직접 참조하지 않는다. `Input Bubble`은 **이름 계약만** 재사용하고 코드를 복사하지 않는다.
- [ ] `Autoload`을 추가하지 않는다.
- [ ] `domain/`·`systems/`에 레벨 ID·도구 ID 리터럴을 넣지 않는다. `test_domain_has_no_content_id_literals`가 검사한다.
- [ ] 범용 추상화를 새 core에 추가하지 않는다. 이 Kit은 module-local 우선이다.

### 18.7 그러면 안 되는 나머지

- [ ] 자동 테스트 통과를 "Kit 완료"로 번역하지 않는다.
- [ ] `interaction_rules`를 169개 `if`로 전개하지 않는다. 13×13 테이블 + 15개 코드로 끝낸다. 커스텀 `match` 169개는 §5.2의 "content별 if/match" 냄새다.
- [ ] 결정론을 위해 `physics_ticks_per_second = 120`을 임의로 60/240으로 바꾸지 않는다(`§8.2`).
- [ ] `hitstop`을 튜닝 이유로 남겨 두지 않는다. 값은 `0.055`다.
- [ ] "한 화면에 정보를 더 넣자"는 이유로 `LevelTitle`을 상시 표시하지 않는다. 0.9초만.
- [ ] `requested` payload에 화면용 문자열을 넣어 셸이 그려지게 하지 않는다.

### 18.8 세계관 설명 노출 (ROUND_PLAN §11.3)

**전부 `- [ ]` 체크 항목이고, 전부 §16.1의 테스트가 자동 실패시킨다.** "조심한다"가 아니라 "이 코드를 쓰면 테스트가 red다"가 목적이면 적는 항목이다.

**WT-1 — 세계관 정본은 제작 전용이다**

- [ ] `docs/world/**`의 문장·용어·사건 설명을 코드·콘텐츠·화면 문자열로 옮겨 넣지 않는다. `Content(문장)` 0건. `test_no_refilling_lore_device` 규칙 ④가 검사한다.
- [ ] 앨리스 재해석 명칭(§2.4)을 `presentation/`에 리터럴로 박아 두지 않는다. `name` 9개는 `content/levels/*.json`에만 있고 코드는 그 값을 읽는다.

**WT-2 — 화면 문자열은 화이트리스트 10슬롯뿐이다**

- [ ] §11.9-2 표에 없는 문자열을 어떤 화면에도 쓰지 않는다. 특히 **도구 이름·재료명·바디 종류명·레벨 `id`·목표 수·hp·산출 수·축 ID**를 그리지 않는다.
- [ ] `LevelTitle` 카드를 1줄 이름에서 늘리지 않는다. 소개·난이도·이전 기록·별점을 붙이는 순간 위반이다.
- [ ] 이 Kit이 직접 `Button`을 만들어 라벨을 붙이지 않는다. 버튼은 Esc 메뉴(Shell 소유)뿐이다.
- [ ] `requested` payload에 `name` `title` `text` 키를 넣지 않는다. 정수와 ID만 (§18.7).

**WT-3 — 되채움 장치를 만들지 않는다**

- [ ] 도감·저널·해설 NPC·엔딩 요약 중 무엇 하나라도 만들지 않는다. "못 본 레벨 목록"을 보여주는 UI도 도감이므로 금지다(§11.10 PF-01).
- [ ] `Voice` 버스 이벤트나 대사·내레이션을 추가하지 않는다.
- [ ] 특정 passage 통과 시 힌트·배너·툴팁을 띄우지 않는다. 목표는 `RIFT`의 충전 링이 말한다.

---

## 19. 완료 증거

구현 완료 보고에 아래를 **전부** 첨부한다. 하나라도 비면 "완료"라고 쓰지 않는다.

### 19.1 자동 검증

- [ ] `--editor --import` 종료 코드 0
- [ ] `res://tests/run_tests.gd` 통과
- [ ] `addons/gut/gut_cmdln.gd -gdir=res://tests/core -gexit` 통과 (기존 실패 신규 회귀 구분 기록 포함)
- [ ] `--quit-after 180 --fixed-fps 60` 에러 0
- [ ] §16.2의 11개 Kit 단독 GUT 실행 로그
- [ ] `dev_probe.tscn` 실행 로그: 8레벨 + 6도구 로드 성공, 상호작용 행렬 169쌍 커버리지 100%, 총알 통과 0건

### 19.2 Primary Reference 비교

- [ ] §2.1 상태별 표를 채운다. 각 행에 **실제 확인한 것**과 **TIN에서 가져갈 규칙**을 적는다. `미확인` 행은 여전히 `미확인`으로 두고 지우지 않는다.
- [ ] 화면 캡처를 Primary Reference의 해당 상태 스크린샷과 나란히 붙인다. 못 붙인 행은 붙였다고 쓰지 않는다.
- [ ] `docs/research/mosa_lina/MOSA_LINA_RESEARCH.md` §4 미확인 10항목을 이 기획서 §3.2 `D1`~`D12`로 어떻게 처리했는지 명시한다.

### 19.3 Reference Game 실측

- [ ] §15.2 데모 시퀀스 8레벨을 **처음부터 끝까지** 플레이
- [ ] 실측 플레이타임 기재: **`__`분 `__`초** (하한 10분)
- [ ] 죽은 횟수, 리셋 횟수, 도구 사용 횟수 기록
- [ ] 이 런에서 못 본 레벨 수 기록 (`9 - levels_seen.size()`). **0이면 시드를 다시 뽑아 "전부 못 볼 수 있음"을 확인한다.**
- [ ] 반복된 레벨이 나왔을 때 "같은 퍼즐 다른 도구"가 실제로 성립했는지 서술

### 19.4 Authored Content 확장성

- [ ] §15.4의 5단계를 실행했다
- [ ] `git diff --stat` 출력이 `content/` 밖 0건임을 붙인다
- [ ] `lvl_clockwork_bell`을 실제로 플레이했다
- [ ] 8레벨 중 authored 기하가 모두 다름을 확인했다(`test_eight_levels_have_distinct_geometry`)

### 19.5 해상도

- [ ] §17.3의 8장 캡처
- [ ] §17.2의 표를 3해상도 전부에서 체크
- [ ] 시드 고정 3해상도 물리 결과 동일 확인
- [ ] 최대 데이터(13종 64바디 + 파편 48)에서 프레임이 30fps 미만으로 안 떨어짐

### 19.6 저장 · 복구

- [ ] 저장/로드 round-trip 로그
- [ ] 스키마 v1/v2 → v3 마이그레이션 테스트 로그
- [ ] 미래 버전 수락 거부 테스트 로그
- [ ] §14.6 회복 경로 7개를 각각 실제로 겪어 본 기록
- [ ] 앱 강제 종료 후 재기동 복원

### 19.7 화면 위생

- [ ] 상시 Shell HUD 없음 (플레이 중 화면 텍스트는 레벨 이름 카드 1회뿐)
- [ ] placeholder `ColorRect`/`Label`이 월드 오브젝트로 남아 있지 않음
- [ ] 이미지 파일 0개
- [ ] 조작 설명 0자
- [ ] §11.9-2 화이트리스트 10슬롯 외 화면 문자열 0건. `test_no_player_text_outside_whitelist` 로그 첨부
- [ ] §11.10 금지 장치 8종이 코드·씬·오디오에 0건. `test_no_refilling_lore_device` 로그 첨부
- [ ] Input Bubble 전환 구간 검수 기록
- [ ] Esc 메뉴 open/close 복귀

### 19.8 레벨 에디터 결정 기록

- [ ] §2.5의 결정을 지켰다는 기록. 인게임 레벨 편집 UI가 0개임을 확인.
- [ ] `dev_probe.tscn`는 헤드리스 검증 하네스로만 쓰였고 게임에서 진입 불가함을 확인.

### 19.9 선언

- [ ] 위 전부를 통과했으므로 **"검토 준비 완료"** 라고 쓴다.
- [ ] 사용자 직접 플레이 전에는 "최종 완성"으로 쓰지 않는다(`docs/KIT_WORKFLOW.md` §12, `PROJECT_DECISIONS.md` §13).

---

## 20. Open Questions — 구현이 멈추는 지점

> **2026-09-27 확정.** 사용자가 작업 중 질문 없이 끝까지 진행하고, 방향을 바꾸는 질문은 "네 추천대로 해"라고 위임했다(2026-09-27 02:10 KST). 그래서 OQ1~OQ9는 아래 표의 **"우리 권장" 열 그대로 확정**이다. 대안 열은 기록으로 남긴다. 구현 중 확정한 세부값은 §21에 적는다.
>
> - OQ1 확정: 도구 7종 = `tool_paper_fan`(shove) `tool_glass_rod`(throw) `tool_ember_lash`(throw + `fire_linger`) `tool_lead_weight`(throw) `tool_rope_hook`(anchor_line) `tool_chill_jar`(cool_field) `tool_moth_wing`(shove, §15.4 증명용). use 모드 이름은 §10.4 스키마의 `cool_field`가 정본이다(이 표의 옛 표기 `freeze_field`는 쓰지 않는다).
> - OQ2 확정: `PLAYER_HP = 5`, `DEAD_RECOVER_DELAY = 0.6s` 자동 복귀.
> - OQ3 확정: `LEVEL_COUNT = 8`.
> - OQ4 확정: 세로 고정 `CAM_Y = 288` + 레벨 JSON 선택 키 `camera_y`(§21.3).
> - OQ5 확정: 코-op 미구현.
> - OQ6 확정: 변형 6종 그대로.
> - OQ7 확정: 이 Kit 명칭 유지. `docs/world/04_DISTRICTS.md`가 우선한다고 적어 두었으므로 통합 때 차이만 반영한다.
> - OQ8 확정: Input Bubble는 모듈 안에 둔다(상태는 `systems/input_bubble.gd`, 그림은 `presentation/bubble_overlay.gd`).
> - OQ9 확정: `tests/performance/captures/` PNG는 게이트와 충돌하지 않는다.

**(원문, 확정 전 기록)** 아래 항목은 확정하지 않았다. 해당 영역 구현을 시작하기 전에 멈추고 사용자에게 물어야 한다. 임의로 골라 진행하지 않는다. `AGENTS.md` "구현 에이전트의 임의 판단. 없으면 멈추고 요청한다".

| # | 질문 | 우리 권장 | 대안 | 멈추는 범위 |
|---|---|---|---|---|
| **OQ1** | 도구 7종의 정체. 레퍼런스의 도구 목록이 미확인이고 우리는 앨리스 포스트아포칼립스로 재스킨했다. `paper_fan` `glass_rod` `ember_lash` `lead_weight` `rope_hook` `chill_jar` `moth_wing` 이 이름·질량·use 모드가 맞는가? | **그대로 확정.** 4가지 use 모드가 물리 4종(임펄스/마찰/정지/조인트)을 정확히 커버하고, 질량이 1.4~4.2로 3배 범위를 만들어 관성 차이가 난다. | 이름을 clockwork 기계어로 통일(`tick_rod` `mainspring` 등) | `content/tools/*.json` 7개 파일 작성 |
| **OQ2** | 플레이어 hp 5 + 0.6s 자동 복귀 vs 해처 즉시 사망. 레퍼런스의 실패 처리가 미확인이다. | **hp 5 + 자동 복귀.** 즉시 사망은 물리 퍼즐에서 실험을 너무 자주 끊고, 5hp는 "한 번은 되돌아온다"는 여유를 주면서도 해처를 진짜 위협으로 만든다. | 즉시 사망(리셋이 유일한 회복) | `domain/world_state.gd` hp 모델, `§14.6` |
| **OQ3** | 런 길이 8레벨(10~16분) vs 12레벨. | **8.** 8이 10분+를 넘기면서 "전 레벨을 못 본다"가 성립하는 최소값이다. 12는 반복 체감이 먼저 온다. | 12 | `LEVEL_COUNT`, `§5.5` |
| **OQ4** | 카메라 세로 고정(고정 `CAM_Y`) vs 수직 추종. `lvl_hollow_keyhole`는 높이 900이라 세로 추종이 필요할 수 있다. | **고정 + 레벨별 `camera_y` override.** 세로 추종은 점프 판단을 흔들지만, 900px 높이는 720p 화면에서 2.5스크롤이다. | 수직 추종(deadzone 140px) | `camera_y` 필드 추가 여부, `§9.7` |
| **OQ5** | Co-op. 레퍼런스가 LAN/온라인/분할 스크린을 지원하지만 정확성 모델이 미확인이다. | **미구현.** 2인 물리 동기화는 이 Kit의 검증 범위 밖이고, 추측 구현은 Primary Reference 규칙 위반이다. 나중에 필요하면 별도 리서치 라운드. | 지금 1인 플레이를 2인 입력으로 확장(로컬만) | 모듈 전체 |
| **OQ6** | "약간의 변형"의 6종 op이 사용자에게 맞는지. 존재만 확인되고 내용은 미확인이다. | **그대로 확정.** 6종이 전부 물리 계수·물체 배치·외력이고 지형을 건드리지 않아 handmade가 유지된다. | op 축소(4종) 또는 `friction_mul` 추가 | `systems/mutation.gd` |
| **OQ7** | 앨리스 포스트아포칼립스 재스킨의 명칭. W1이 `docs/world/**`를 동시에 작성 중이라 명칭이 겹칠 수 있다. | **이 Kit 명칭(`종이 부채`, `시간알`, `틈`, `균열 조합장`)을 유지.** 통합 시 W1 명칭이 우선하고 그 차이만 이 문서에 반영한다. | W1 명칭에 즉시 맞춤 | `content/*.json`의 `name`, `module_manifest.tres`의 `display_name` |
| **OQ8** | Input Bubble를 모듈 안에 두는 것(현재 계획)이 전이층 인계 없이 확정되어도 되는가. | **모듈에 둔다.** 전이층이 없으므로 지금 인계할 대상이 없다. API 이름이 `first_entry`와 동일해 인계 비용은 낮다. | 전이층 버블을 먼저 만들고 이 Kit은 사용만 | `presentation/bubble_overlay.gd` |
| **OQ9** | `tests/performance/captures/`에 PNG 캡처를 두는 것이 이미지 0개 게이트와 충돌하는가. | **충돌 안 함.** `ROUND_PLAN.md` §5는 각 Kit 폴더를 대상으로 하고 캡처는 `tests/` 아래다. | 캡처를 `docs/` 아래 `.md` 링크로 대체 | `§17.3` |

**차단 해제 (2026-09-27):** OQ1(도구 7종), OQ2(hp), OQ3(런 길이), OQ4(카메라 세로), OQ6(변형 6종)은 위 확정으로 풀렸다. 이 5개가 확정하는 `content/tools/`, `domain/world_state.gd`, `systems/selector.gd`, `presentation/world_root.gd`, `systems/mutation.gd`를 이 확정값으로 작성한다.

OQ5, OQ7, OQ8, OQ9는 원래 비차단이었고 권장값으로 확정했다.

**OQ10 (새로 연 비차단 항목):** 공유 지형 원본의 위치(§7.8.1). 확정: 이 Kit의 지형 원본은 계속 `content/levels/*.json`이다. `place.id`와 레벨을 짝짓는 필드는 이번 판에 만들지 않는다(§21.8). 공유 지형 스키마가 정해지면 그때 레벨 JSON에 선택 키 1개를 더한다.

### 20.1 W0에게 요청할 사항 (이 모듈이 직접 건드리지 않는다)

| 대상 | 요청 | 사유 |
|---|---|---|
| `app/app_root.gd` | `physics_puzzle_platformer`를 등록 목록에 추가 | W0 단독 소유(`ROUND_PLAN.md` §2) |
| `project.godot` | §8.2의 물리 키 10개와 `display/window/stretch/mode = canvas_items` | 이 모듈은 런타임에 action을 등록하지만 물리 설정은 프로젝트 설정에 있다 |
| `tests/core/test_no_binary_assets.gd` | W0이 생성. 이 Kit 폴더가 대상에 포함되는지 확인 | `ROUND_PLAN.md` §5 |

---

## 부록 A. 구현 순서 (wave)

| 웨이브 | 파일 | 선행 조건 |
|---|---|---|
| 0 | `module_manifest.tres`, `domain/*` 8개 파일 (상수/스키마/상태) | `core/procedural/` 스텁(ROUND_PLAN C1) |
| 1 | `systems/level_factory.gd`, `systems/selector.gd`, `systems/mutation.gd` | wave 0 |
| 2 | `systems/step_director.gd`, `systems/contact_buffer.gd`, `systems/damage.gd`, `systems/objective_tracker.gd`, `systems/tool_holder.gd`, `systems/kinematics.gd` | wave 1 |
| 3 | `content/levels/lvl_chalk_shelf.json`, `content/tools/tool_paper_fan.json`, `entry.tscn`, `module.gd` | wave 2 |
| 4 | `presentation/*` (월드/바디/배경/리프트) | wave 3 + `core/procedural/` 구현 |
| 5 | `presentation/game_screen.gd`, `presentation/bubble_overlay.gd`, `audio_manifest.gd` | wave 4 |
| 6 | `domain/save_codec.gd`, `systems/save_service.gd` | wave 2 |
| 7 | `content/` 나머지 7레벨 + 5도구 | wave 3 |
| 8 | `presentation/dev_probe.tscn`/`.gd` | wave 3 |
| 9 | `tests/core/test_ppp_*.gd` 11개 파일 | wave 0~8 중 대응 구현 |
| 10 | §15.4 증명 콘텐츠 2개 + `git diff --stat` | wave 9 |
| 11 | §17 수동 검수 + §19 증거 수집 | wave 10 |

**wave 3에서 `lvl_chalk_shelf` + `tool_paper_fan`만으로 플레이 가능한 세션을 먼저 세운다.** 8레벨을 다 만든 뒤에야 실행 가능한 구조를 만들면 오류가 한 번에 몰린다. wave 3에서 `Space`/`E`/`R`로 레벨 1을 클리어하고 저장·로드가 도는 것을 확인한 뒤 확장한다.

## 부록 B. 명명 규칙

| 종류 | 규칙 | 예 |
|---|---|---|
| 모듈 id | 소문자 스네이크 | `physics_puzzle_platformer` |
| InputMap action | `ppp_` 접두 + 의도 | `ppp_move_left` |
| 레벨 ID | `lvl_` 접두 + 앨리스 모티프 | `lvl_chalk_shelf` |
| 도구 ID | `tool_` 접두 + 앨리스 모티프 | `tool_rope_hook` |
| 바디 ID | 레벨 ID 없이 레벨 내부에서 유일 | `floor`, `egg_low`, `spike_high` |
| 오디오 이벤트 | `ppp_` 접두 | `ppp_egg_take` |
| `observation` id | `ppp.` 접두 | `ppp.lvl_chalk_shelf.cleared` |
| 파일 | `snake_case.gd` | `step_director.gd` |
| `class_name` | `PascalCase`, 이 Kit은 **사용하지 않음**(module-local 우선) | — |

`class_name`을 쓰지 않는 이유: `docs/CODE_STYLE.md`가 "shared는 두 실제 사용처에서 동일한 의미와 계약이 확인된 뒤에만 추출"이라 하고, `class_name`은 전역 등록이라 global scope를 차지한다. 이 Kit 내부에서는 파일 경로 기반 `preload`/`const` 참조만 쓴다.



