# Kit 03 — Deduction Casework

> 상태: **STAGE 01 PLAYABLE / FULL CAMPAIGN IN PROGRESS**
>
> `CONCRETE STORY`: **로컬 Notion export의 v5 명세를 사용한다. Stage 01~12 authored case와 route chain을 구현했다.**
>
> 사용자의 명시적 요청에 따라 `docs/golden_idol_story/`의 로컬 export를 정본으로 사용하고, placeholder box 아트를 허용한 교체 가능한 foundation과 12단계 authored campaign을 구현한다. 최종 art와 사람 중심 수동 플레이 검증은 아직 별도 과제다.
>
> 다른 Kit 개발과 충돌하지 않도록 이 slice의 코드 소유 범위는 `modules/deduction_casework/**`, `tests/core/test_deduction_casework*`, 계획 문서로 제한한다. `app/app_root.gd`는 이미 추가한 corrected ID 등록 외에는 수정하지 않는다.
>
> `The Case of the Golden Idol/game_recovered/**`는 사용자가 제공한 원본 자료에서 추출·복구된 읽기 전용 조사 자료다. 원본 개발 소스나 공식 pristine 설치본으로 간주하지 않으며, 원본 코드·에셋·문구·레이아웃·리소스를 TIN 프로젝트에 복사하지 않는다.

공통 계약: `docs/KIT_WORKFLOW.md`

현행 이미지 제작 입력: [《빈 공리》 프로젝트 아트 층](../../docs/art/projects/empty_axiom/PROJECT_ART_LAYER.md), [Stage 1 미라 합성용 인물](../../docs/art/projects/empty_axiom/asset_briefs/mira_ben_stage01_cutout.md). 과거 at-icons recipe와 캐릭터 검토판은 현재 최종 이미지 제작 입력이 아니다. 미라 명세의 장면 충돌·배치 규격을 해소하기 전 생성하지 않는다.

## 0. Kit 목적

- TINProject의 한 게임 안에서 **2D 현장 조사·단어 수집·다중 패널 추론·case review** 장르 구간을 즉시 만들 수 있게 한다.
- Kit를 사용하면 scene, entity, message, panel, solution, hint, review를 authored data와 scene으로 추가할 수 있고, core parser/evaluator/save/input을 다시 만들지 않아야 한다.
- 이 Kit의 단위는 `case`다. 한 case 안에 여러 scene, close-up, message, entity, panel, solution이 있다.
- 이 Kit가 다루지 않는 것:
  - 원작의 인물·사건·대사·결말·에셋·세계관 복제
  - 전투, 이동 중심 액션, 대화 엔진의 일반화, 전역 서비스 로케이터
  - 원작의 모든 optional minigame의 무조건적 복제
  - 전용 authoring editor, 전역 chapter manager, 원작의 recovered script/autoload 구조
  - concrete story 담당자가 제공하지 않은 TIN canonical content
  - TIN global Shell HUD, 자동 저장 표시, 상시 키 설명, 디버그 화면

### 0.1 Campaign foundation 범위

이번 캠페인에서 구현하는 것:

- corrected GameModule ID `deduction_casework`와 `module_manifest.tres`
- typed case/scene/entity/message/panel/solution/hint/review schema
- content index/case validator, authored catalog, stale ID recovery
- discovery, message effect, panel assignment, status/condition evaluator
- versioned `DeductionSaveState`, reset/command boundary, focus-safe presentation state
- authored scene를 mount할 수 있는 CaseScreen/focus/drawer 계약
- placeholder box 기반 world/UI 구분
- at-icons 조합 recipe schema와 UI image inventory
- 자동 테스트와 다른 Kit과 독립적인 fixture
- Stage 01~12의 4~5개 region, hotspot, 중간문제, main statement, hint, review와 순서 route

이번 캠페인에서 아직 구현하지 않는 것:

- 최종 이미지/원본풍 art asset
- 12단계 전체 10분+ Reference Game 완료 증거
- 기존 `modules/dedution_casework/**` Retired Prototype의 코드·콘텐츠·UI 이관
- 다른 Kit/module의 파일, content, route, test 변경

## 1. Primary Reference — 정확히 하나

**게임:** *The Case of the Golden Idol*
**개발사/제작자:** Color Gray Games
**출시/잼 맥락:** 상용 인디게임. 로컬 PCK-derived recovery의 `game_recovered/globals.gd:3,168`은 버전 `2025.07.28 / DLC 2.0.6`과 Steam app `1677770`의 *The Case of the Golden Idol* URL을 가리킨다.
**공식/신뢰 가능한 reference source:**

- Steam: https://store.steampowered.com/app/1677770/The_Case_of_the_Golden_Idol/
- 로컬 원본 실행물: `The Case of the Golden Idol/game.exe`
- 로컬 원본 데이터: `The Case of the Golden Idol/game.pck`
- 읽기 전용 PCK-derived recovered project: `The Case of the Golden Idol/game_recovered/`
- recovery provenance: `The Case of the Golden Idol/game_recovered/gdre_export.log:1-13,36-47,54-58`
- 원본 visual asset: `The Case of the Golden Idol/game_recovered/assets/`
- 제공된 `goldenidol_UI_ref/` 28 JPG: **사용자가 제공한 원본의 runtime 시각 증거로 인정한다**

**출처 등급:**

1. 로컬 실행물과 PCK의 실제 runtime, recovered scene/asset의 존재: 제품·화면 구성의 1차 확인
2. `game_recovered`의 구조·상태·입력 코드: 동작 구조의 보조 근거. decompile/recovery artifact와 debug hack은 규칙으로 보지 않는다
3. 공식 Steam 페이지: 제품과 공식 설명의 보조 근거
4. 사용자 제공 `goldenidol_UI_ref` JPG: 원본 화면/상태의 runtime 시각 증거

`The Rise of the Golden Idol` / Steam app `2716400` 자료는 이 로컬 PCK recovery가 가리키는 Steam app `1677770`과 제목이 다르므로 이 계획서의 Primary Reference 근거에서 제외한다. 원작 asset, script, text, scene을 TIN에 복사하지 않는다.

이 절의 `game_recovered/`, `UI/`, `scenarios/`, `assets/` 경로는 모두 `The Case of the Golden Idol/game_recovered/`를 기준으로 한다.

**Evidence integrity:** `game_recovered`는 `game.pck`에서 추출한 GDRE recovery artifact이지만, `gdre_export.log`의 입력 경로와 현재 PCK 경로가 다르며 PCK/tree hash 비교도 없다. 공식 pristine depot과의 동일성은 확인하지 않았다. `goldenidol_UI_ref`의 28장은 사용자가 원본에서 제공한 runtime 캡처로 기록하고, recovered source와 시각 차이가 있더라도 **사용자 제공 캡처를 화면 근거로 우선 사용한다**. 차이가 나는 recovered code는 동작 구조의 보조 근거로만 사용한다.

### 1.1 상태별 레퍼런스 증거

| 상태 | 실제 reference URL/자료 | 눈으로 확인할 것 | TIN에서 그대로 가져갈 규칙 |
|---|---|---|---|
| first playable frame | `goldenidol_UI_ref/20260925014944_1.jpg`; `game_recovered/main.gd:163-183,319-405`; `The Case of the Golden Idol/game_recovered/project.godot:213-245`; `splash_screen_dlc.tscn` | splash와 scenario intro를 지난 뒤 첫 location이 instantiate되는 순간; 사용자 캡처와 runtime transition을 대조한다 | pre-play shell과 gameplay world를 분리하고, 첫 playable frame은 authored location과 focus를 준비한 뒤 연다 |
| normal play | `goldenidol_UI_ref/20260925015335_1.jpg`, `20260925015408_1.jpg`; `scenarios/1_untimely_demise_of_rural_gentleman/bedroom.tscn:115-290`; `location.gd:94-108` | hotspot hover, pointer affordance, location 이동, phrase progress | world의 silhouette와 animation이 조사 대상을 읽히게 하고, click intent가 authored action으로 분기된다 |
| focus / selection / direct manipulation | `goldenidol_UI_ref/20260925015354_1.jpg`, `20260925015838_1.jpg`, `20260925015847_1.jpg`, `20260925015852_1.jpg`; `UI/spot.gd:44-65`; `UI/pointer.gd:35-115`; `UI.gd:500-614`; `assets/UI/help/explore.png`; `assets/UI/help/fill_in.png` | hotspot highlight, pointer 상태, phrase drag, target slot, focus/selected의 차이 | pointer drag를 1급 조작으로 유지하고 keyboard/controller에는 같은 focus→confirm command를 제공한다 |
| core mechanic change | `goldenidol_UI_ref/20260925015322_1.jpg`, `20260925015820_1.jpg`, `20260925015823_1.jpg`, `20260925015828_1.jpg`, `20260925015901_1.jpg`; `scenario.gd:90-241`; `UI.gd:740-901`; `UI/scroll_solver.gd:15-21`; `UI/segmented_solver.gd:23-67`; `UI/portrait_solver.gd:36-83` | solver reveal, phrase 배치, `NOT_FILLED`/`UNSOLVED`/`ALMOST`/`SOLVED`, scenario solved signal | authored slot/solution을 평가하고 partial/full correctness를 명시적으로 표시한다 |
| unavailable / failure | `scenario.gd:198-219`; `UI.gd:871-887`; `UI/solver.gd:41-84`; 실패 runtime capture는 추가 필요 | wrong/near-correct/full-correct가 화면·sound·motion에서 어떻게 구별되는지 | TIN은 wrong assignment rollback + transient slot feedback, almost 상태 표시, solved lock을 고정한다. source runtime capture는 구현 전 보강 증거다 |
| success / completion | `goldenidol_UI_ref/20260925015316_1.jpg`; `main.gd:425-432`; `UI.gd:1287-1307`; `UI/victory_dialog.tscn:38-90`; `scenarios/1_untimely_demise_of_rural_gentleman/assets/victory.png` | scenario solved dialog, hint count, case state, review/selector 전환 | 정답 시 solved state, phrase/slot lock, completion signal, review를 순서화한다 |
| menu/detail if core | `goldenidol_UI_ref/20260925015354_1.jpg`, `20260925015413_1.jpg`; `location.gd:132-192`; `UI.gd:1051-1099`; `UI/comment_box.tscn`; `UI/dialog.gd:27-37`; `UI/dialog.tscn`; `assets/UI/help/*.png` | comment box, close-up/detail, dialog의 위치·크기·close/back 경로 | detail은 parent location과 focus를 복원하며 world를 대체하지 않는다 |
| level/scene transition | `goldenidol_UI_ref/20260925015408_1.jpg`; `main.gd:469-514`; `location.gd:132-192,292-315`; `scenarios/1_untimely_demise_of_rural_gentleman/bedroom.tscn:115-290` | close-up stack, location slide, destination 변경, progress restore | scene 교체는 domain transition과 presentation transition을 분리하고, 돌아오면 이전 scene progress를 복원한다 |

**현재 증거 부족:** 사용자 제공 28장 JPG는 원본의 정적 runtime 상태를 문서화한다. 아직 부족한 것은 10분 연속 플레이, 클릭 반복, drag 놓기 실패, controller focus 이동, hint 전환의 연속 기록이다. 이 부족분은 구현을 시작할 수 없는 증거 공백으로 유지한다.

### 1.2 강하게 따라갈 시스템/UX

- 시스템:
  - scene/location → hotspot → close-up/document/comment/message(콘텐츠가 제공하는 경우) → phrase discovery → solver panel → validation → scenario review 순서
  - 이름, 사물/대상, 행위, 특수 단서, 기호/숫자 같은 authored vocabulary를 panel에 배치하는 구조
  - ordered slots, portrait/identity slots, segmented slots를 하나의 panel contract 아래 처리하는 구조
  - `undiscovered`, `not_filled`, `unsolved`, `almost`, `solved`의 단계적 solver feedback
  - case-local 진행을 저장하고, solved case를 다시 열어 결과를 재확인하는 구조
- 입력 감각:
  - world 위 pointer가 hover affordance를 바꾸고 click이 조사 의도를 전달한다
  - phrase는 pointer drag로 slot에 이동하며, 잘못된 message/entity kind 또는 slot에서는 원래 container로 돌아온다
  - keyboard/controller는 같은 조작을 focus 이동과 confirm/cancel intent로 수행한다
  - 원본의 `main.gd:560-630` 직접 key 분기는 복제하지 않는다. TIN은 InputMap action과 `ModuleContext`를 사용한다
- 카메라/보드/공간:
  - world scene이 기본 공간이다
  - close-up은 world 위에 뜨는 상세 view이며, parent location을 가리지 않는 비율과 복귀 위치를 가진다
  - phrase container와 thinking panel은 아래쪽/ contextual drawer로 열린다
  - panel의 slot과 phrase는 authored layout slot을 사용하며, container size는 해상도 규칙으로 계산한다
- 정보 노출:
  - 현재 조사 대상, 발견한 phrase, 현재 panel의 필요한 vocabulary만 노출한다
  - undiscovered solver는 구체 정답을 미리 보여주지 않는다
  - hint는 authored hint list에서 호출되는 별도 정보이며 자동 정답 assembler's replacement가 아니다
- focus/selection:
  - 원본의 pointer hover, focus, selected 상태를 서로 다른 상태로 유지한다
  - focus는 색 변화만이 아니라 reticle, frame, position, label 중 적어도 두-channel로 읽힌다
  - mouse hover가 없어도 keyboard/controller가 모든 선택 가능한 대상에 접근할 수 있다
- feedback:
  - phrase 발견, message 방문, slot rejection, partial correctness, full correctness, completion을 서로 다른 짧은 feedback으로 표현한다
  - 실패 feedback은 원인을 가리되 panel을 닫거나 case를 초기화하지 않는다
- retry/undo/reset:
  - 원본에는 current scenario reset과 drag 기반 slot 복원이 있다. 이를 따라가되 TIN은 명시적인 `reset current case`를 제공하는 local operation으로 고정한다
  - close/cancel은 현재 overlay를 닫고 draft를 보존한다
  - 잘못된 submit은 atomic failure이며 발견 상태와 이전 case를 보존한다
- 콘텐츠 구조:
  - content author가 scene, close-up, entity, message, panel, solution, hint, review를 독립 authored 단위로 추가한다
  - text 자체를 identity로 쓰지 않고 stable authored ID를 쓴다
  - category 이름은 core enum에 넣지 않고 content가 선언한다

### 1.3 복제하지 않을 고유 저작물

- 원작의 캐릭터, portrait, 이름, 대사, 사건, chapter 이름, 결말, hint 문구
- 원작의 Steam/streaming/DLC/achievement 구현과 recovered script
- 원작의 이미지, portrait, NinePatch, pointer animation, sound, music, font, UI texture
- 원작의 실제 scenario constant, close-up 경로, solver answer, character reference
- 원작의 Godot 3 `setget`, autoload singleton, global enum, Steam API, debug key
- 원작의 전역 scenario index와 DLC route를 TIN core에 복사하지 않는다
- 원작의 모든 optional minigame를 Kit의 필수 범위로 승격하지 않는다

## 2. 현재 코드 감사

### 2.1 살릴 후보

| 경로/시스템 | 살릴 이유 | 반드시 다시 검증할 것 |
|---|---|---|
| `core/contracts/game_module.gd` | `enter`, `exit`, `save_state`, `load_state`, command lifecycle | 새 module이 Shell을 직접 찾지 않고 lifecycle만 호출하는가 |
| `core/contracts/module_context.gd` | action polling과 module input boundary | physical key가 domain에 들어가지 않는가 |
| `core/contracts/module_manifest.gd` | id, display name, entry scene, save version, input action 선언 | planned id `deduction_casework`가 기존 오타 route와 혼동되지 않는가 |
| `core/services/module_director/module_director.gd` | module 전환, arrival context, catalog 검증 | case module이 다른 module을 참조하지 않는가 |
| `core/services/save_service/save_service.gd` | module-local JSON snapshot과 load/export | case-local versioned payload가 Shell state와 섞이지 않는가 |
| `core/services/input_router/input_router.gd` | action activation/lock과 transition-safe input | pointer, keyboard, controller intent가 같은 locked 상태를 지나는가 |
| `modules/first_entry/first_entry.gd` | 시작 phase와 Input Bubble 연결 패턴 | 현재 tutorial presentation을 추리 화면에 복사하지 않는가 |
| `modules/first_entry/presentation.gd` | 참고만. 현재 presentation은 보존 대상이 아니며 시작/입력 로직만 재검토한다 | physical key cell과 rebinding만 module-local하게 재검증하는가 |
| `modules/rule_rewriting/systems/level_loader.gd` | JSON index, schema version, duplicate/missing reference validation 패턴 | parser를 global/shared로 올리지 않고 case-local content loader에 두는가 |
| `modules/rule_rewriting/systems/rule_evaluator.gd` | 조건식의 deterministic evaluation 패턴 | rule puzzle vocabulary를 case domain에 복사하지 않는가 |
| `modules/rule_rewriting/domain/grid_state.gd` | typed state와 JSON serialization 패턴 | save payload가 stable ID만 저장하는가 |
| `modules/rule_rewriting/module.gd` | module-local state와 action wiring 패턴 | puzzle-specific history/inventory/metrix를 새 Kit으로 옮기지 않는가 |
| `modules/odd_road_adventure/module.gd` | location, event, inventory, NPC state의 분리 패턴 | `LOCATION_IDS`, `TARGETS`, 특정 story ID를 버리고 data/scene으로 옮기는가 |
| `modules/game_library/module.gd` | 직접 실행, focus traversal, `gui_get_focus_owner()` 패턴 | 개발 목록 UI의 presentation을 player case UI로 가져오지 않는가 |

### 2.2 버릴 것

| 경로/표현/구조 | 버리는 이유 |
|---|---|
| `The Case of the Golden Idol/game_recovered/**` 전체 | 원작의 코드·에셋·문구·scene을 복사하거나 TIN source로 import하지 않는다. 읽기 전용 행동 근거로만 사용한다 |
| `app/app_root.gd:6-7`, `:33-35`의 기존 `dedution_casework` 문자열 | 오타가 포함된 stale route이며 구현이나 설계 근거가 아니다. 새 planned id는 `deduction_casework`로 고정하고 구현 시 route를 교체한다 |
| `modules/dedution_casework/**` 전체 | 실제로 존재하는 Retired Prototype이다. `module.gd`, `module_manifest.tres`, concrete content, UI, tests, story ID를 새 Kit의 기준·콘텐츠·UX·저장 모델로 재사용하지 않는다 |
| `modules/deduction_casework/**`의 현재 부재 | 새로 만들 correctly-spelled planned path는 아직 존재하지 않는다. 존재하지 않는 구현을 “이미 있다”고 가정하지 않는다 |
| `modules/odd_road_adventure/module.gd:3-20`, `:22-56`의 concrete ID/콘텐츠 | location/target/event/story를 core script에 하드코딩한 구조 |
| `modules/rule_rewriting/module.gd:3-16`, `:30-43`의 puzzle actions/history | rule rewrite 전용 vocabulary와 history를 추리 Kit contract로 확장하지 않는다 |
| 원작 `Globals.Topic`, `Globals.SolverTypes`, `ScenarioStates`를 core enum으로 승격 | content category와 presentation type이 core에 결합되고 새 content가 core 수정으로 귀결된다 |
| 원작 `globals.gd:141-165`의 scenario path와 `main.gd:1095-1141`의 hard-coded unlock | 원작 story route/DLC를 TIN 범용 route로 복사하지 않는다 |
| 원작의 `setget`, autoload, Steam API, debug key, direct `Input.get_*`/`KEY_*` 처리 | Godot 4 typed GDScript와 ModuleContext/InputMap 계약에 맞지 않으며 global side effect가 많다 |
| `addons/tin_integrations/runtime/tin_integration_kit.gd` | legacy integration 후보이며 새 Kit의 required dependency가 아니다 |
| 모든 기존 retired play module | whitelist 밖 구현은 아이디어·대사·UI를 새 Kit의 근거로 삼지 않는다 |

### 2.3 Retired Prototype 경계

- 기존 `modules/dedution_casework/`는 `module_manifest.tres:7-11`, `module.gd:3-5`, `content/case_01_empty_signal.tres:7-84`, `content/case_02_clockwork_song.tres:7-103`, `tests/core/test_cycle4_modules.gd:148-342`를 가진 별도 구현이다.
- 이 구현의 `dedution_casework` ID, concrete story, `ColorRect`/`Label` presentation, 네 단계 mode, index 기반 save, `cycle` command는 Retired Prototype이다.
- 새 Kit은 `deduction_casework`라는 corrected ID와 `modules/deduction_casework/**`를 사용하되, old prototype의 content/UI/state/test를 이관하지 않는다.
- old ID save migration은 **호환 불가 폐기 후 새 초기 state**로 고정한다. `current_module == "dedution_casework"`를 새 ID로 치환하되 old module state와 story는 보존하지 않는다. 구현 시 AppRoot import 경계에서 ID alias를 처리하고 generic SaveService key schema는 변경하지 않으며, migration 테스트를 남긴다.
- `deduction_casework`의 manifest filename은 `module_manifest.tres`로 통일한다. `manifest.tres`는 사용하지 않는다.

### 2.4 원본에서 추출할 구조와 버릴 구현

| 원본 구조/근거 | 관찰 | TIN 적용 |
|---|---|---|
| `game_recovered/globals.gd:5-62` | mouse/action/topic/solver/scenario 상태가 enum으로 분리됨 | presentation/content category를 JSON field와 typed domain 값으로 옮긴다. core enum에 원작 topic을 추가하지 않는다 |
| `game_recovered/scenario.gd:90-241` | solver별 answer count, `almost`, `solved`, scenario win을 계산 | panel definition의 slot/solution/condition을 검증하는 Kit-local evaluator로 재작성한다 |
| `game_recovered/scenario.gd:66-80,127-145` | phrase가 다른 phrase와 특정 offset으로 함께 맞아야 하는 조건이 존재 | `all_of`/`any_of`/`not`와 assignment prerequisite를 지원하는 작은 condition schema로 일반화한다 |
| `game_recovered/UI.gd:393-442` | hotspot click이 새 phrase를 한 번만 container에 추가 | stable entity ID로 idempotent discovery를 수행한다 |
| `game_recovered/UI.gd:740-901` | topic mismatch, occupied slot, persistent slot, copy/return 규칙 | `accepted_kinds`, slot occupancy, `move/copy`, persistent authored slot을 명시한다 |
| `game_recovered/UI.gd:1185-1307` | thinking panel이 아래에서 열리고 solved phrase/lock을 갱신 | transient drawer와 domain status를 분리하고 solved slot의 authored persistence를 따른다 |
| `game_recovered/location.gd:132-192`, `:292-315` | close-up observer stack, parent 복귀, slide transition | scene/detail presentation stack을 가지되 parent state를 domain에서 소유하지 않는다 |
| `game_recovered/persistence_manager.gd:18-147` | JSON으로 scenario progress를 저장 | version/schema validation, stale ID sanitize, missing content fallback을 추가한다 |
| `game_recovered/minigame/*.gd` | 별도 drag/order/random minigame 존재 | 핵심 casework와 분리한다. 이번 Kit에서는 구현하지 않고 별도 후속 authored content로만 다룬다 |

## 3. Reference Game — 최소 10분

### 3.1 장르의 Authored Content 단위

- `case`: 하나의 독립적인 조사/추론 단위
- `scene`: case 안의 조사 공간
- `closeup`: world에서 여는 상세 문서/대상/ 인물/사물 view
- `entity`: 이름, 사물, 행위, 특수 단서, 기호, 숫자 등 vocabulary
- `message`: authored detail/message source. vocabulary category는 `EntityDefinition.kind`에 있고, dialogue choice engine은 원본에 없으므로 이 Kit의 core에도 만들지 않는다
- `panel`: ordered slots, portrait/identity slots, segmented slots 중 하나
- `solution`: panel별 저자 지정 정답과 조건
- `hint`: authored 도움말
- `case_review`: solved case의 결과와 다음 case를 연결하는 authored review

**이 Kit의 단위:** `case`

### 3.2 10분 플레이 흐름

아래 ID와 구조는 TIN Reference Game의 authored placeholder이다. 원작 case 이름·story·문구·정답을 복사하지 않는다.

| 순서 | authored content | 새로 검증하는 시스템 | 이전 시스템 재사용 |
|---:|---|---|---|
| 1 | `case_01` / `scene_start` | 첫 frame, world focus, hotspot affordance, case state 초기화 | module lifecycle, scene transition |
| 2 | `case_01` / `scene_start` close-up 3개 | comment, close-up, phrase/entity discovery, focus restore | location/observer stack, phrase discovery |
| 3 | `case_01` / message 2개 | message prerequisite, 새 vocabulary 공개, detail close | message/detail, save boundary |
| 4 | `case_01` / `panel_ordered` | phrase drag, message/entity kind validation, wrong assignment recovery | pointer/slot, undo-like cancel |
| 5 | `case_01` / `panel_segmented` | partial status, `almost`, 조건 결합, authored hint | evaluator, feedback |
| 6 | `case_01` / panel solutions | full validation, solved lock, case review | save/load, completion |
| 7 | `case_02` / `panel_portrait` | 같은 core를 identity slot topology로 재사용 | content loader, no core edit |
| 8 | `case_03` / `panel_ordered` + `panel_segmented` | 이전 case vocabulary/panel rule의 fresh-state reuse | cross-context reuse, no secret flag |
| 9 | `case_03` review | case conclusion, next case transition, revisit | review/route state |

**Primary Reference runtime evidence 상태:** `BLOCKED`. 위 흐름을 verified local executable에서 실제로 플레이하고 시간·오조작·focus·recovery를 기록해야 한다. 정지 화면이나 source inspection은 증거로 치환하지 않는다. TIN Reference Game 10분 검증은 구현 후 완료 증거다.

### 3.3 하드코딩 방지량

- 서로 다른 authored case 최소 수: **3**
- 같은 subsystem 재사용 사례: scene, close-up, phrase, message, panel, solution, save/review를 각 case에서 최소 한 번씩 사용
- 다른 panel topology 최소 수: ordered, portrait/identity, segmented 중 3종
- 새 content 추가 방법: 새 case JSON, 필요한 scene/closeup scene, art recipe, message/entity data만 추가
- core 무수정 검증: `case_04`를 추가한 뒤 parser/evaluator/save/input/router/registry 알고리즘 diff가 0인지 검사
- content별 `if/match`가 core에 생기면 실패로 간주한다. presentation dispatch만 panel `kind`를 허용한다

## 4. Domain / State

원본의 `ScenarioProgress`처럼 배열 위치와 phrase text를 그대로 신뢰하지 않는다. JSON은 authoring input이고, runtime에서는 stable ID를 가진 typed domain object를 사용한다. `evidence`는 별도 record가 아니라 `EntityDefinition`의 presentation/authoring 용어다.

```text
CaseDefinition
  id
  title
  start_scene_id
  scenes[]
  entities[]
  messages[]
  panels[]
  solutions[]
  hints[]
  review
  next_case_ids[]

SceneDefinition
  id
  scene_path
  start_focus_id
  hotspots[]
  transitions[]

CloseupDefinition
  id
  scene_path
  parent_scene_id
  return_focus_id
  hotspots[]

EntityDefinition
  id
  kind
  display_text
  source_text_id
  tags[]

MessageDefinition
  id
  source_refs[]
  prerequisite_condition
  effects[]
  detail_scene_id

PanelDefinition
  id
  kind
  title
  accepted_entity_kinds[]
  slots[]
  segments[]
  almost_threshold
  required_for_completion
  unlock_condition

PanelSlotDefinition
  id
  segment_id
  accepted_kinds[]
  accepted_entity_ids[]
  persistent
  move_policy: move | copy

ConditionDefinition
  all_of[]
  any_of[]
  not[]
  requires_discovered_entity_id
  requires_resolved_message_id
  requires_solved_case_id
  requires_assignment_id
  requires_assignment_entity_id

SolutionDefinition
  id
  panel_id
  required_assignments[]
  forbidden_assignments[]
  all_of_conditions[]
  completion_review_id

HintDefinition
  id
  title
  body
  prerequisite_condition
  one_shot

ReviewDefinition
  id
  conclusion
  referenced_case_ids[]
  scene_path

CaseProgressState
  case_id
  current_scene_id
  visited_scene_ids[]
  discovered_entity_ids[]
  resolved_message_ids[]
  revealed_panel_ids[]
  panel_drafts{}
  panel_status{}
  accepted_solution_ids[]
  unlocked_hint_ids[]
  reviewed
  status: open | solved | reviewed | content_unavailable

DeductionSaveState
  active_case_id
  last_case_id
  case_progress_by_id{}
  route_state
    unlocked_case_ids[]
    reviewed_case_ids[]

PanelStatus
  UNDISCOVERED
  NOT_FILLED
  UNSOLVED
  ALMOST
  SOLVED

TransientViewState
  open_surface_id
  focus_id
  hover_id
  selected_entity_id
  dragged_entity_id
  feedback_id
  return_focus_id
```

### 4.1 State graph

```text
ENTER
  → SCENE_ACTIVE
  → CLOSEUP_ACTIVE
  → MESSAGE_ACTIVE
  → PANEL_DRAFT
  → PANEL_REVIEW
  → CASE_SOLVED
  → CASE_REVIEW
  → NEXT_CASE

CONTENT_UNAVAILABLE
  → RECOVERY_SCENE

CLOSEUP_ACTIVE --cancel--> SCENE_ACTIVE
MESSAGE_ACTIVE --cancel--> previous surface
PANEL_DRAFT --cancel--> SCENE_ACTIVE with draft preserved
PANEL_REVIEW --invalid--> PANEL_DRAFT with feedback only
PANEL_REVIEW --valid--> CASE_SOLVED atomically
CASE_SOLVED --review--> CASE_REVIEW
```

### 4.2 처리 규칙

- `ENTER`와 scene load는 authored ID가 유효할 때만 성공한다.
- close-up은 parent scene과 return focus를 필수로 갖는다.
- phrase/entity 발견은 같은 ID를 반복해서 추가하지 않는다.
- `message`는 authored detail/message source다. vocabulary category는 `EntityDefinition.kind`이며, 원본에는 dialogue choice engine이 없으므로 core dialogue system을 만들지 않는다.
- panel draft는 domain state를 바꾸지 않고 별도 `panel_drafts`에만 기록한다.
- slot assignment는 entity kind와 accepted ID를 먼저 검증한다. 실패하면 assignment를 원상 복구한다.
- `required_for_completion = true`인 모든 panel을 검사한 뒤 모든 solution condition이 참일 때만 `CASE_SOLVED`로 원자적 전환한다. 원본의 scroll/portrait/segmented solver를 모두 같은 완료 조건으로 강제하지 않는다.
- `almost_threshold`는 authored 값이며 Reference Game case는 원본 호환값 `2`를 명시한다. core에 숫자 2를 고정하지 않는다.
- 정답을 아는 플레이어가 fresh state에서 바로 정답을 실행할 수 있어야 한다. `clue_found` secret flag는 정답 실행을 막지 않는다.
- hint는 정답을 자동 배치하지 않는다. hint는 condition/visibility를 보조할 뿐 정답 판정 authority가 아니다.
- `CaseDefinition.next_case_ids`가 route의 단일 authority다. 배열 순서가 authored choice order이며, 0개면 case end, 1개면 자동 next, 2개 이상이면 review에서 명시 선택한다. `ReviewDefinition`은 conclusion과 referenced case만 소유한다.

### 4.3 Invalid / stale state

- JSON parse/validator 실패는 module entry를 실패시키지 않고 `content_unavailable` state로 진입한다.
- load 시 없는 scene/entity/panel/message ID는 제거하고, 유효한 ID와 case route는 유지한다.
- 현재 case ID가 없으면 `DeductionSaveState.last_case_id`가 유효할 때 그 case를 선택하고, 그것도 없으면 content index의 첫 case를 선택한다.
- 저장된 panel slot 수가 현재 definition과 다르면 남는 assignment를 제거하고 status를 `unsolved` 또는 `not_filled`로 재계산한다.
- stale content는 조용히 정답으로 처리하지 않는다. recovery notice를 한 번 표시하고 안전한 초기 scene으로 돌아간다.
- transient focus, drag, popup, animation, pointer position은 save하지 않는다.

## 5. Authored Content Format

원본은 scenario script, tscn, exported node property에 콘텐츠가 분산되어 있다. TIN은 같은 authoring 범위를 유지하되 content schema와 validation을 분리한다.

| content type | 파일 형식 | 필수 필드 | validation | core 수정 없이 추가? |
|---|---|---|---|---|
| case index | `res://modules/deduction_casework/content/index.json` | `schema_version`, `cases[]`의 stable `id`/`path` | version, duplicate ID/path, missing file, valid ID | 예 |
| case definition | `res://modules/deduction_casework/content/cases/<case_id>.json` | case, scenes, entities, messages, panels, solutions, hints, review, next IDs | 모든 cross-reference, panel capacity, solution reference, condition leaf 검증 | 예 |
| scene | `res://modules/deduction_casework/content/scenes/<scene_id>.tscn` | scene root ID, background recipe, hotspot nodes, transition metadata는 case JSON이 소유 | node ID, path, focus target, transition destination | 예 |
| close-up/detail | `res://modules/deduction_casework/content/closeups/<closeup_id>.tscn` | close-up ID, parent scene, return focus, hotspot metadata | parent 존재, close-up ID unique, nested close-up 제한 | 예 |
| message definition | case JSON의 `messages[]` | `id`, `source_refs`, `prerequisite`, `effects`, `detail_scene_id` | message/entity reference, effect type, duplicate ID | 예 |
| art recipe | `res://modules/deduction_casework/art/recipes/<recipe_id>.json` | source fragments, transforms, palette, silhouette target | fragment path, transform 유효성, raw UI icon 금지 | 예 |
| runtime manifest | `res://modules/deduction_casework/module_manifest.tres` | `id = deduction_casework`, display name, `entry_scene`, `save_version = 1`, `input_actions = [deduction_casework_left/right/up/down/confirm/cancel]` | ModuleDirector catalog validation과 InputMap action 존재 테스트 | 아니며 구현 시 한 번만 추가 |
| tests/fixtures | `res://tests/core/fixtures/deduction_casework/*.json` | 최소/중간/최대/오류 content | fixture schema validation | 예 |

작성 규칙:

- JSON root와 모든 record는 `schema_version`을 가진다. 첫 구현 schema version은 `1`이다.
- ID는 lowercase snake case stable ID를 사용한다. 표시 문자열은 ID와 분리한다.
- message/category/panel kind는 core enum에 추가하지 않는다. content가 선언하는 `StringName`을 validator가 허용한다.
- 원작의 `Topic` 값, answer list, portrait path, close-up path, 인물 이름, 문장을 복사하지 않는다.
- 새 authored unit은 content file, scene, art recipe, message/entity data만 추가한다.
- 전용 editor는 만들지 않는다.
- raw dictionary를 runtime truth로 통과시키지 않는다. loader가 typed domain object를 만든 뒤 검증한다.
- content validator는 전체 registry를 한 번에 실패시키지 않고 해당 case를 unavailable로 격리한다.

## 6. 핵심 시스템

| 시스템 | 입력 | 출력 | side effect | 실패 atomicity | 순서 의존성 | determinism |
|---|---|---|---|---|---|---|
| ContentLoader | index/case JSON, scene paths | typed `CaseDefinition` | module-local registry/cache | invalid case는 격리, 다른 case 계속 | schema → references → paths | 필요 |
| Discovery | scene/close-up hotspot intent | `EntityDefinition` 발견 | phrase/entity state, source visited | 중복 발견은 no-op | interaction guard 후 entity commit | 필요 |
| MessageResolver | message ID, condition | message detail/effect | vocabulary/message/panel reveal | 실패 시 state 변경 없음 | prerequisite → effect → UI signal | 필요 |
| PanelWorkspace | phrase/entity assignment, move/copy/cancel | slot draft, slot status | `panel_drafts`, focus/selection은 transient | 잘못된 slot은 원상 복구 | validate slot → mutate draft → status | 필요 |
| SolutionEvaluator | panel drafts, conditions | `unsolved`/`almost`/`solved` | solved event는 마지막에 atomic commit | invalid는 feedback만 | required panel → conditions → completion | 필요 |
| CaseProgression | solved event, review action | next case/review state | case route/save payload | review 전에 다음 case unlock 금지 | solve → review → next | 필요 |
| SaveAdapter | `DeductionSaveState` | versioned JSON dictionary | module-local snapshot 반환 | sanitize 후에만 반환 | load → validate → fallback | 필요 |
| Hints | hint ID, prerequisite | detail body/visibility | hint unlock count | hint 실패는 state 변경 없음 | condition → reveal → close | 필요 |

### 처리 순서

1. ModuleDirector가 manifest를 검증하고 `ModuleContext`를 전달한다.
2. ContentLoader가 index와 시작 case를 읽고 schema/reference를 검증한다.
3. Case state를 sanitize한 뒤 scene을 instantiate한다.
4. 현재 scene의 focus 가능한 hotspot을 계산한다.
5. 입력 intent를 world/detail/message/panel command로 변환한다.
6. action의 precondition을 검사한다.
7. domain state 또는 panel draft를 원자적으로 갱신한다.
8. SolutionEvaluator가 필요한 경우 panel status를 계산한다.
9. presentation이 transient focus/selection/feedback를 갱신한다.
10. module은 `save_state()`로 JSON-safe snapshot을 반환만 한다. Director/AppRoot가 저장 경계에서 snapshot을 캡처한다.
11. case solved이면 review를 열고, review action 이후에만 `CaseDefinition.next_case_ids`를 따라 next case를 unlock한다.

Presentation node는 domain 판정을 읽어 직접 해결하지 않는다. runtime `PanelStatus` enum 이름은 `UNDISCOVERED`, `NOT_FILLED`, `UNSOLVED`, `ALMOST`, `SOLVED`로 고정하고, JSON에는 lower snake case인 `undiscovered`, `not_filled`, `unsolved`, `almost`, `solved`만 저장한다.

## 7. Input

### 7.1 Game actions

| intent | InputMap action | gameplay meaning |
|---|---|---|
| focus left | `deduction_casework_left` | authored focus traversal의 이전/좌측 대상 |
| focus right | `deduction_casework_right` | authored focus traversal의 다음/우측 대상 |
| focus up | `deduction_casework_up` | authored focus traversal의 위/이전 segment 대상 |
| focus down | `deduction_casework_down` | authored focus traversal의 아래/다음 segment 대상 |
| confirm | `deduction_casework_confirm` | hotspot/comment/detail, message 선택, phrase→slot 배치, solution 제출, review confirm |
| cancel | `deduction_casework_cancel` | detail/drawer 닫기, drag 취소, panel draft 복귀 |

- 위 여섯 action은 `app/app_root.gd:260-305`가 새 module ID에 대해 생성하는 이름과 manifest의 `input_actions`에 동일하게 등록한다.
- 새 `deduction_interact`, `deduction_move_focus`, `deduction_toggle_thinking`, `deduction_sort`, `deduction_reset_case`, `deduction_toggle_highlight` action은 만들지 않는다.
- pointer click/drag는 같은 module command로 변환한다. keyboard/controller는 focus 이동 + confirm/cancel로 동일한 domain 결과를 만든다.
- `Esc`는 module action이 아니라 Shell menu 호출로 고정한다. `deduction_casework_cancel`은 `X` baseline을 사용하고, overlay를 닫은 뒤 world focus를 복원한다.
- `thinking panel`은 world 안의 focus 가능한 affordance를 confirm하여 열고, `cancel`로 닫는다. 별도 action을 만들지 않는다.
- current-case reset은 InputMap action이 아니라 `execute_command(&"reset")` → confirmation → `execute_command(&"reset_confirm")` command contract로 처리한다.
- `ModuleContext`의 `is_action_pressed`, `get_axis`만 사용한다. `get_axis`는 `_left/_right`, `_up/_down` 쌍으로 호출한다.
- 원본처럼 `KEY_SPACE`, `KEY_ESCAPE`, `Input.get_action_strength()`를 module script에 직접 쓰지 않는다.
- 잘못된 slot, unavailable detail, locked panel은 intent를 소비하되 domain state를 바꾸지 않는다.
- sort/highlight/help는 원본 UI에 있지만 이 Kit의 core action으로 승격하지 않는다. 필요한 경우 authored presentation affordance와 command로 추가한다.

### 7.2 장르 전환 Input Bubble

- 이전 구간의 required physical keys: `ModuleContext.arrival`의 이전 key profile을 사용한다. 기본 profile은 `first_entry_up/down/left/right/confirm/cancel`이며, profile이 없으면 구현을 시작하지 않는다.
- 이 구간의 required physical keys: 현재 AppRoot baseline은 `←`, `→`, `↑`, `↓`, `Z`, `X`다. 실제 전환과 rebinding을 기록한 뒤 확정한다.
- restore되는 bubble: 현재 구간에서 다시 필요한 이전 physical cell
- rising bubble: Deduction Kit baseline physical cell
- popped 흔적으로 남는 bubble: 이전 구간에만 있던 physical cell
- bubble 완료 조건: 해당 구간에서 필요한 physical key를 실제로 눌러 action intent가 처리되었을 때
- `Esc`는 Shell menu physical key이므로 Input Bubble의 module action cell에 포함하지 않는다.
- 설명문으로 키 기능을 해설하지 않는다.
- physical key는 `InputMap`/리바인딩을 통해 표시하며, domain과 content에 key name을 저장하지 않는다.
- 현재 action 이름과 physical key baseline이 실제 `InputMap`에 등록되었는지 자동 테스트로 확인한다.

## 8. Save / Load / Retry

저장:

- module은 core service를 직접 호출하지 않는다. `GameModule.save_state()`가 module-local JSON-safe snapshot을 반환하고, Director/AppRoot가 전환·명시 저장 경계에서 캡처한다.
- `ModuleManifest.save_version = 1`은 module state version이다. `SaveService.FORMAT_VERSION`은 전역 envelope version, content JSON의 `schema_version = 1`은 authored content version이며 서로 독립이다.
- 저장 payload는 `DeductionSaveState`를 사용한다: `active_case_id`, `last_case_id`, `case_progress_by_id`, `route_state`.
- 각 `CaseProgressState`의 fields: `case_id`, `current_scene_id`, `visited_scene_ids`, `discovered_entity_ids`, `resolved_message_ids`, `revealed_panel_ids`, `panel_drafts`, `panel_status`, `status`, `accepted_solution_ids`, `unlocked_hint_ids`, `reviewed`.
- `focus_id`, `open_surface_id`, `hover_id`, `dragged_entity_id`, `feedback_id`, pointer position, animation progress는 저장하지 않는다.
- `next_case_ids`와 panel/solution definition은 authored content에 있으므로 save payload에 중복 저장하지 않는다.
- 원본 `persistence_manager.gd`의 JSON 형식 idea는 참고하되 version 없는 payload, index-based migration, array shape 검증을 그대로 복사하지 않는다.

load sanitize:

- root/type/schema version을 먼저 검사한다.
- `active_case_id`가 없으면 첫 authored case를 선택한다.
- `case_progress_by_id`의 존재하지 않는 case/entity/scene/panel/message ID를 제거한다.
- stale route는 마지막 유효 case 또는 index 첫 case로 fallback한다.
- panel definition 수와 state 수를 맞춘 뒤 남는 assignment를 제거한다.
- 올바른 definition으로 panel status를 다시 계산한다. 저장된 `status`를 trust하지 않는다.
- focus가 복원되지 않으면 scene의 `start_focus_id`를 사용한다. 저장 후 focus가 아니라 현재 case/scene과 안전한 start focus가 복구된다.
- 일부분 손상된 load는 정상 case data를 함께 초기화하지 않는다.
- `migrate_save()`는 content catalog나 presentation 없이 이전 module state의 version/shape만 처리하고, 새 corrected ID의 old prototype state는 보존하지 않는다.

retry/reset/undo:

- `deduction_casework_cancel`은 현재 surface를 닫고 draft를 보존한다.
- drag 중 cancel은 현재 assignment를 원상 복구한다.
- 잘못된 submit은 `unsolved` 또는 `almost` feedback만 만들고 discovery/case progress를 삭제하지 않는다.
- `execute_command(&"reset")`은 reset confirmation만 열고, `execute_command(&"reset_confirm")`만 현재 `case_progress_by_id` entry를 authored initial state로 원자적 교체한다. 이전 case와 route selection은 유지한다.
- global undo stack은 만들지 않는다. 필요한 최소 복구는 slot assignment 취소와 current-case reset으로 충분하다.
- `Esc`는 Shell menu를 호출하며 reset을 실행하지 않는다.

실패 중간 상태:

- 모든 required panel validation이 끝나기 전에는 `case_solved`를 저장하지 않는다.
- panel 하나가 invalid이면 다른 정상 panel draft와 기존 discovery를 유지한다.
- content validation failure는 `content_unavailable`로 표시하고 이전 정상 case로 돌아갈 수 있게 한다.
- 원본의 `force_win`, developer number key, `hack_create_and_assign_phrase_to_solver`는 production path가 아니다.

## 9. Presentation

### 9.1 화면의 주인공

- 플레이어가 첫 1초에 봐야 하는 것: 현재 조사 scene의 공간, 가장 가까운 actionable hotspot, 현재 focus/selection
- UI보다 우선하는 world element: 배경, 사물, 인물, exit/transition의 실루엣과 배치
- 상시 표시가 정말 필요한 정보: **없음.** phrase count와 panel affordance는 해당 drawer가 열릴 때만 표시한다
- 호출할 때만 보이는 정보: close-up, message/detail, document detail, solver panel, hint, completion/review dialog
- gameplay `CaseBar`는 만들지 않는다. phrase container와 thinking panel은 world를 가리지 않는 contextual drawer로만 나타난다.
- `Esc`로 Shell menu를 호출하기 전에는 Shell의 시각적 존재감이 0이다.
- phrase container는 world를 가리지 않는 contextual area로 둔다.
- thinking panel은 원본의 아래 drawer 흐름을 참고하되, 세 해상도에서 world와 필요한 phrase 목록을 동시에 읽을 수 있게 한다.
- detail close-up은 world 위 central/localized surface로 열리고 close 시 parent scene, location, focus를 복원한다.
- pointer는 hotspot, close-up, phrase, location transition에 따라 형태·위치·애니메이션을 바꾼다. 색만으로 affordance를 전달하지 않는다.
- full-screen dashboard, permanent quest list, constant key legend, placeholder `ColorRect`/`Label`은 금지한다.

### 9.2 월드 이미지 자산 — 후보 목록

현재 확정된 Gold Standard 이미지는 없다. story를 넣기 전에 아래 후보를 authored recipe로 정리하고, 실제 이미지 제작/승인은 별도 asset workflow에서 수행한다. 후보 경로는 `res://addons/at-icons/node2d/` 기준이며 원본 pictogram을 그대로 world object로 쓰지 않는다.

| 용도 | 후보 source fragments | UI에서 처리할 것 |
|---|---|---|
| 공간/실내 | `floor_plane.svg`, `mesh_plane.svg`, `brick_wall.svg`, `doorway.svg`, `window.svg`, `chair.svg`, `table.svg`, `ground.svg`, `mountains.svg`, `house.svg`, `factory.svg`, `institutional_building.svg` | focus reticle, hotspot frame, lock/visited shape |
| 인물 | `person_body.svg`, `face.svg`, `head_with_gear.svg`, `hand.svg`, `briefcase.svg` | portrait/name/selected state는 텍스트·프레임으로 처리 |
| 문서/증거 | `book_open.svg`, `files.svg`, `file_document.svg`, `paperclip.svg`, `stamp.svg`, `ruler.svg`, `envelope.svg`, `notepad.svg`, `magnifying_glass.svg`, `fingerprint.svg`, `key.svg`, `clock.svg`, `footsteps.svg`, `paw_print.svg` | 목록/선택/disabled/filter/check 상태는 Control geometry로 처리 |
| 지도/보드 | `map.svg`, `location.svg`, `road.svg`, `sign_post.svg`, `briefcase.svg`, `box_wireframe.svg`, `link.svg` | route node, focus ring, connector line은 UI 선/모양으로 처리 |
| 기계/추론 | `node_graph.svg`, `node_graph_node.svg`, `node_graph_connection.svg`, `rotary_dial.svg`, `radio_button.svg`, `gauge.svg`, `switch.svg`, `signal_wave.svg`, `circuit_board.svg`, `brain.svg` | solver slot/status/focus는 UI typography/frame으로 처리 |
| 사건/차량 | `car.svg`, `roadblock.svg`, `traffic_cone.svg`, `wrench.svg`, `bandages.svg`, `droplet.svg`, `footsteps.svg` | detail inset, source marker는 Control overlay로 처리 |
| 완료/review | `clapperboard.svg`, `film_cartridge.svg`, `photo_camera.svg`, `projector.svg`, `trophy.svg`, `medal_1st.svg`, `star.svg`, `stars.svg` | success/review/next action은 버튼·프레임으로 처리 |
| 사무실/close-up | `storage.svg`, `desktop.svg`, `mobile_phone.svg`, `handset.svg`, `box.svg`, `table.svg`, `chair.svg`, `window.svg` | close-up panel, detail title, focus return은 Container로 처리 |

이미지가 필요한 경우는 world/character/vehicle/close-up art recipe뿐이다. reticle, check, selection, status, list icon, panel slot은 at-icons를 사용하지 않고 `Control` geometry·typography·색·선으로 만든다.

### 9.3 Focus / Selection

- default focus: scene의 `start_focus_id`, 없으면 authored 순서상 첫 actionable hotspot
- focus 표시: reticle/frame/position/label을 조합한다. 색 변화만 사용하지 않는다.
- mouse: pointer hover와 click을 직접 manipulation으로 사용한다.
- keyboard/controller: authored spatial/logical order로 focus를 이동하고 confirm/cancel한다.
- phrase focus: phrase 자체와 target slot을 별도로 표시한다. 어느 phrase가 어디로 가는지 항상 읽힌다.
- selected: 현재 조작 대상인 phrase/entity를 focus와 구분해 표시한다.
- target 제거 시 fallback: 다음 authored focus → 이전 container phrase → scene start focus 순서로 이동한다.
- screen close 후 restore: close-up은 parent hotspot, message/detail은 source focus, panel은 panel entry focus로 돌아간다.
- pointer를 사용할 수 없는 장치에서도 focus 정보가 동일하게 읽혀야 한다.

## 10. 화면 상태

`N/A — 이 화면에 해당하지 않음`은 빈칸 대신 명시적인 상태이다. 아래의 unavailable/success 규칙은 원작 source에서 확인된 contract와 TIN의 failure/accessibility 규칙을 구분해 기록한 것이다.

| screen | initial | normal | focus | active | unavailable/failure | success | return |
|---|---|---|---|---|---|---|---|
| `scene_active` | scene background와 first focus | world exploration, hotspot pointer, contextual drawer 없음 | reticle/frame가 current hotspot을 표시 | pointer click이 comment/close-up/phrase/location command 실행 | 범위 밖 target은 N/A; 잘못된 transition은 state 변경 없이 feedback | 필요한 target/phrase가 scene에 반영 | close-up/surface를 닫으면 scene focus 복원 |
| `closeup_detail` | parent scene 위 detail surface | close-up hotspots와 document text | active detail target 표시 | click hotspot이 phrase/message/detail을 공개 | 이미 수집한 phrase는 no-op과 `already discovered` feedback만 반환 | 새 entity/message 반영 | parent scene과 origin hotspot으로 복귀 |
| `message_detail` | 첫 message focus | 선택 가능한 message와 minimal text | keyboard/controller message focus 유지 | confirm이 message effect를 원자적 commit | locked message는 intent block, 설명문 대신 disabled affordance | message effect/save 반영 | source scene focus로 복귀 |
| `thinking_panel` | 필요한 panel slot만 표시 | phrase container와 solver slot 동시 표시 | current phrase와 target slot을 별도 표시 | drag/place/remove와 submit | message/entity kind mismatch, occupied/solved slot은 assignment rollback | correct slot 시각/상태 반영 후 panel status 갱신 | close 시 draft와 scene focus 유지 |
| `solver_review` | 현재 panel의 authored rules/slots | partial draft와 status | invalid target와 current assignment 표시 | `deduction_casework_confirm`이 solution 평가 | invalid/almost는 draft와 discovery 유지 | `solved`와 review affordance | review close 시 solved case 재방문 가능 |
| `hint_detail` | hint title과 prerequisite state | hint body | close/confirm focus | hint claim으로 detail close | locked hint는 N/A; hint가 없으면 명시적 no-hint feedback | hint count/locked ID 반영 | source focus 복원 |
| `case_review` | solved case 결과와 authored conclusion | 이전 case entity/panel 결과 확인 | review action focus | confirm이 next case를 요청 | next case content invalid면 review에 머물고 recovery 표시 | route state와 next scene 전환 | 이전 case 재방문은 read/revisit intent |
| `reset_confirm` | 현재 case 이름과 reset 범위 | destructive action 명시 | cancel/confirm focus 구분 | confirm만 current case reset 실행 | cancel은 아무 상태도 바꾸지 않음 | authored initial state로 복귀 | source scene focus 복원 |
| `content_unavailable` | validator가 찾은 오류와 recovery 대상 | 오류 없는 이전 정상 case를 임시로 표시 | cancel은 recovery를 유지하고 confirm은 fallback case를 선택 | module이 content를 실행하지 않음 | missing/stale reference는 정답 처리하지 않음 | fallback case 또는 안전한 scene으로 복귀 | source case가 복구되면 authored start scene으로 복귀 |

`solver_review`는 state graph의 `PANEL_REVIEW`를 화면에서 부르는 presentation 이름이다. `content_unavailable`는 `CONTENT_UNAVAILABLE → RECOVERY_SCENE`의 presentation 이름이다.

### 10.1 화면별 reference brief

| screen | source evidence | focal point | world/UI ratio | persistent/contextual info | TIN adaptation |
|---|---|---|---|---|---|
| `scene_active` | `bedroom.tscn:115-290`, `location.gd:94-108` | world 배경과 actionable hotspot | world 우선, UI는 숨김 | persistent 없음; hotspot은 world에 있음 | 2D pixel reference의 layout를 TIN의 확정된 이미지 자산 기반으로 표현 |
| `closeup_detail` | `location.gd:132-192`, `comment_box.tscn` | parent 위에 뜬 detail과 현재 detail hotspot | world가 parent로 남음 | detail text만 contextual | 중앙/인접 overlay와 return focus를 사용하고 원작 frame/asset는 복사하지 않음 |
| `message_detail` | `UI.gd:1051-1099`, `UI/comment_box.tscn` | 현재 message와 선택 가능한 effect | world 우선, 작은 detail surface | message/detail만 contextual | dialogue engine을 만들지 않고 authored message source로 제한 |
| `thinking_panel` | `UI.tscn:93-116`, `UI.gd:1185-1213`, solver scenes | phrase와 target slot의 관계 | world와 phrase container를 함께 읽을 수 있는 drawer | panel slot만 contextual | bottom drawer를 anchor/Container로 만들고 별도 상시 bar를 만들지 않음 |
| `solver_review` | `scenario.gd:198-241`, `UI/solver.gd:51-84` | partial/full status와 current assignment | panel 중심, world는 배경 | status/draft만 표시 | lower-case JSON status와 runtime enum을 분리하고 focus를 명시 |
| `case_review` | `main.gd:425-432`, `UI/victory_dialog.tscn:38-90` | authored conclusion과 다음 case 선택 | detail surface가 world를 대체하지 않음 | review 중만 표시 | 원작 victory text/image를 복사하지 않고 TIN story/review를 사용 |
| `content_unavailable` | `persistence_manager.gd:149-162`의 한계를 TIN validation으로 보강 | 오류와 recovery destination | recovery surface 우선 | 오류 동안만 표시 | placeholder world가 아니라 명시적 recovery state를 사용 |

## 11. Shell 관계

- 플레이 중 Shell persistent HUD: **없음**
- `CaseBar`/상시 gameplay toolbar는 만들지 않는다. 필요한 affordance는 world focus target 또는 열린 drawer 안에 둔다.
- Esc 메뉴 호출 시: 항상 Shell menu를 호출한다. module overlay는 `deduction_casework_cancel` 또는 pointer outside-click으로 닫는다.
- 메뉴 닫을 때: focus를 호출 전 screen의 안전한 focus로 복원한다.
- Journal/기록이 이 Kit에서 필요한가: **별도 상시 Journal은 필요 없다.** case review와 phrase/detail은 case domain/presentation이 소유한다.
- Shell이 gameplay 정보를 소유하지 않는지: **소유하지 않는다.** Shell은 module 전환·저장 호출·Esc menu만 담당한다.
- AppRoot의 기존 `dedution_casework` 오타 route는 gameplay contract로 사용하지 않는다. 구현 시 `SET_IDS`, `NORMAL_IDS`, `ROUTES`의 해당 ID를 `deduction_casework`로 교체한다.
- module은 `/root`, service locator, 다른 module을 찾지 않는다. `GameModule`, `ModuleContext`, `ModuleManifest` 계약만 사용하고 `SaveService`에는 직접 접근하지 않는다.
- original recovered project의 autoload `Main`, `Globals`, `Gamestate`, `PersistenceManager` 구조를 복제하지 않는다.

## 12. 해상도

구현 후 실제 캡처를 기록한다. 계획서 작성 시점에 완료했다고 표시하지 않는다.

실제 캡처:
- [ ] 1280×720
- [ ] 1920×1080
- [ ] 2560×1440

각 해상도에서:
- [ ] core play area 유지
- [ ] focus/reticle/selected/disabled 표시 유지
- [ ] UI 겹침/잘림 없음
- [ ] 긴 문자열과 최대 phrase/slot 데이터
- [ ] world/detail/panel 비율 유지
- [ ] 최소 panel과 최대 panel 모두 focus 가능
- [ ] pointer와 keyboard/controller 전환 후 동일 command
- [ ] Esc menu open/close와 focus 복귀
- [ ] case reset과 revisit 시 동일 scene 구성

## 13. 자동 테스트

### domain/system
- [ ] `module_manifest.tres`의 id/display_name/entry_scene/save_version/input_actions가 ModuleDirector 계약을 만족한다.
- [ ] manifest의 여섯 action이 InputMap에 등록되고 `ModuleContext.get_axis()` 쌍으로 동작한다.
- [ ] ContentLoader가 schema version, duplicate ID/path, missing reference를 거부한다.
- [ ] 잘못된 case 하나가 다른 정상 case를 파괴하지 않는다.
- [ ] entity discovery는 같은 ID를 반복해도 한 번만 반영된다.
- [ ] message prerequisite가 false면 effect가 적용되지 않는다.
- [ ] panel slot의 accepted kind/ID 검사가 동작한다.
- [ ] wrong assignment는 원래 draft/phrase 위치로 rollback된다.
- [ ] occupied slot의 move/copy/persistent policy가 결정적으로 동작한다.
- [ ] ordered, portrait, segmented panel status가 같은 evaluator contract를 사용한다.
- [ ] `almost_threshold`가 authored 값만 사용한다.
- [ ] required/forbidden assignment와 authored condition이 동시에 검사된다.
- [ ] 모든 panel이 valid할 때만 `CASE_SOLVED`가 commit된다.
- [ ] wrong submit이 discovery와 case status를 삭제하지 않는다.
- [ ] fresh state에서 정답을 아는 경우 secret discovery flag 없이 solution을 실행할 수 있다.
- [ ] case review가 다음 case를 unlock하기 전에 명시적 confirm을 요구한다.
- [ ] reset current case가 이전 case와 route selection을 보존한다.

### content pipeline
- [ ] `case_01`, `case_02`, `case_03`을 content/scene만 추가해 같은 core로 실행한다.
- [ ] 새 case JSON에 새 enum, 새 `match`, 새 core field를 추가하지 않는다.
- [ ] invalid content reject/sanitize
- [ ] duplicate/missing ref
- [ ] missing scene/close-up path
- [ ] maximum phrase/slot/long text fixture
- [ ] authored hint with no available hint
- [ ] core 무수정 여부를 diff와 grep로 확인한다.

### save
- [ ] module이 core SaveService를 직접 호출하지 않고 `save_state()` snapshot만 반환한다.
- [ ] `DeductionSaveState`가 여러 case를 보존하고 active case만 전환한다.
- [ ] versioned round-trip
- [ ] missing/stale entity, scene, panel, message ID sanitize
- [ ] definition shape 변경 후 정상 state 보존
- [ ] save/load 후 solver status 재계산
- [ ] focus/hover/drag/animation이 저장되지 않음
- [ ] reset current case
- [ ] case revisit
- [ ] review/next route
- [ ] old `dedution_casework` current module ID가 corrected ID로 alias되고 old state/story가 폐기되는지 확인한다.

### UI contract
- [ ] state → visible state
- [ ] selected phrase → detail/slot content
- [ ] disabled target → intent block
- [ ] focus traversal → 모든 interactive target
- [ ] target 삭제/비활성화 → fallback focus
- [ ] close-up → parent focus
- [ ] panel close → scene focus
- [ ] Esc menu open/close와 호출 전 focus 복귀
- [ ] `deduction_casework_cancel`으로 detail/panel을 닫고 parent focus 복귀
- [ ] wrong/near/success feedback 구별
- [ ] pointer drag와 keyboard/controller assignment가 같은 domain 결과
- [ ] 720p/FHD/QHD layout

## 14. 수동 플레이 과제

플레이어에게 조작법을 설명하지 않고 다음 과제를 수행시킨다. 원작의 정답이나 단서를 미리 알려주지 않는다.

1. 시작 화면에서 첫 조사 scene으로 진입한다.
2. 화면에 보이는 world object 중 조사 가능한 대상을 찾는다.
3. detail을 열어 더 작은 대상을 조사한다.
4. message/detail에서 얻는 단서를 phrase container에 둔다.
5. thinking panel을 열어 phrase를 slot에 배치한다.
6. 일부러 잘못된 message/entity kind 또는 잘못된 slot에 배치한다.
7. 원래 draft로 복구할 수 있는지 확인한다.
8. hint가 있으면 한 번 열고, 정답이 자동 완성되지 않는지 확인한다.
9. case를 해결하고 review를 읽는다.
10. case를 다시 열어 이전 결과를 재확인한다.
11. 다음 case에서 같은 panel subsystem이 다른 content에 재사용되는지 확인한다.
12. 저장·로드·재접속 후 현재 case/scene과 안전한 start focus 복귀를 확인한다.
13. 1280×720, 1920×1080, 2560×1440에서 같은 과제를 반복한다.

관찰:
- 첫 meaningful action까지 시간
- world affordance를 찾기까지 시간
- 오조작과 rollback 시간
- focus 상실 여부
- 도움/장문 설명 필요 여부
- 잘못 읽은 pointer/panel affordance
- failure에서 회복 가능한지
- long text/maximum data에서 잘림 여부
- 10분 동안 서로 다른 authored case를 실제로 사용했는지

## 15. 금지 Shortcut

- [ ] `modules/dedution_casework/**`의 concrete story, UI, save schema, test를 새 Kit으로 이관한다.
- [ ] `modules/dedution_casework/**`의 script, asset, text, scene, path, answer를 복사한다.
- [ ] 원작 인물·사건·chapter·결말을 TIN story로 옮긴다.
- [ ] placeholder `ColorRect`/`Label`을 world object로 사용한다.
- [ ] 상시 키 설명, 자동 저장 표시, location name, debug label을 표시한다.
- [ ] 우상단 Menu/Journal/개발 toolbar를 추가한다.
- [ ] 버튼 목록으로 world hotspot 상호작용을 대체한다.
- [ ] 모든 clue를 누르면 UI가 자동으로 정답을 조립하게 한다.
- [ ] case별 `if/match`, ID array, answer list를 module core에 추가한다.
- [ ] 원작의 global topic/solver enum을 core contract로 복사한다.
- [ ] 원본의 autoload, Steam API, debug key, force-win을 구현한다.
- [ ] random minigame를 핵심 deduction evaluator로 사용한다.
- [ ] retry/reset가 현재 case progress를 조용히 삭제한다.
- [ ] hidden discovery flag로 이미 아는 정답 실행을 막는다.
- [ ] 저장하지 않는 transient UI 상태를 domain state로 만든다.
- [ ] content 추가마다 parser/evaluator/save/input/router를 수정한다.
- [ ] 10분을 이동·대기·반복 클릭·대사량으로 채운다.
- [ ] 자동 테스트만으로 Reference Game 완료를 선언한다.
- [ ] 원본 또는 외부 리뷰를 실제 확인하지 않은 상태에서 UI를 추측한다.
- [ ] 두 번째 사용처가 없는데 shared 추상화를 만든다.

## 16. 파일 소유권과 구현 순서

### 16.1 소유 범위

새 구현이 시작되면 아래 범위만 이 Kit의 소유자가 수정한다.

- `res://modules/deduction_casework/module_manifest.tres`: module identity와 input action 목록
- `res://modules/deduction_casework/entry.tscn`: AppRoot가 instantiate할 entry scene
- `res://modules/deduction_casework/module.gd`: lifecycle, context, command 연결만 담당
- `res://modules/deduction_casework/domain/`: typed case/scene/entity/message/panel/state 정의
- `res://modules/deduction_casework/systems/`: content loader, discovery, evaluator, save adapter, case progression
- `res://modules/deduction_casework/presentation/`: world scene, close-up, phrase drawer, thinking panel, focus/feedback
- `res://modules/deduction_casework/content/`: authored index, case JSON, scene/closeup, art recipe
- `res://modules/deduction_casework/art/`: TIN 월드 이미지 자산
- `res://tests/core/test_deduction_casework_*.gd`: domain/content/save/UI contract 테스트
- `res://app/app_root.gd`: `NORMAL_IDS`/`SET_IDS`/`ROUTES`에 corrected ID 추가, legacy ID catalog alias 유지, 새 manifest catalog 등록을 위한 최소 연결만 허용
- `res://core/**`: 이 Kit 구현을 위한 직접 참조를 추가하지 않는다. 공유 계약 수정이 필요하면 두 번째 실제 사용처를 먼저 확인한다.

원본 폴더 `C:\projects\TINProject\The Case of the Golden Idol\**`는 읽기 전용이고 소유 범위에 포함하지 않는다.

### 16.2 구현 순서

1. story 담당자로부터 TIN concrete story를 받는다.
2. verified local Primary Reference에서 10분 이상 runtime capture를 기록한다. 사용자 제공 JPG는 상태별 시각 근거로 이미 사용한다.
3. domain ID와 `DeductionSaveState`를 구현한다.
4. content loader/validator를 구현한다.
5. discovery/message/panel evaluator를 구현한다.
6. pointer와 keyboard/controller intent를 연결한다.
7. world/detail/phrase drawer/thinking panel presentation을 연결한다.
8. versioned save/load/reset을 연결한다.
9. 서로 다른 case 3개를 content만 추가한다.
10. 자동 테스트와 세 해상도 수동 검사를 실행한다.
11. authored case 4를 추가해 core 무수정을 증명한다.
12. 사용자 직접 플레이 검토를 요청한다.

## 17. 완료 증거

구현 완료 보고에 반드시 첨부/기록한다.

현재 조사·계획 상태:
- [x] 로컬 PCK와 GDRE recovery artifact의 위치 및 version을 확인했다.
- [x] recovered source의 `Globals`, `Scenario`, `ScenarioProgress`, `Location`, `UI`, solver, persistence 구조를 읽었다.
- [x] `goldenidol_UI_ref` 28 JPG를 읽고 사용자가 제공한 원본 runtime 시각 증거로 기록했다.
- [x] recovered code/asset/text를 TIN에 복사하지 않는 경계를 기록했다.
- [x] 기존 `modules/dedution_casework/**`가 Retired Prototype임을 확인하고 재사용 금지 경계를 기록했다.
- [x] title/app ID가 다른 이전 웹 자료를 이 계획서에서 제외했다.
- [x] TIN concrete story 12단계 authored content를 제공받았다.
- [x] 12개 case의 loader/route/solve 자동 검증을 완료했다.
- [ ] 12단계 사람 중심 10분+ 플레이와 720p/FHD/QHD 캡처
- [ ] 최종 art asset 승인
- [ ] 사용자 직접 플레이 **검토 준비 완료**

구현 후:
- [ ] Primary Reference 상태별 비교
- [ ] 10분+ 실측 Reference Game
- [ ] authored content 3개가 같은 core를 재사용
- [ ] authored content 4번째 추가 시 core 무수정
- [ ] 1280×720 캡처
- [ ] 1920×1080 캡처
- [ ] 2560×1440 캡처
- [ ] 자동 테스트 결과
- [ ] save/load/retry/reset/revisit 검수
- [ ] 상시 Shell HUD 없음
- [ ] Input Bubble 실제 physical key 기록
- [ ] 이미지 자산 출처·라이선스 및 확정된 제작 기준 audit
- [ ] placeholder world object 없음
- [ ] 사용자 직접 플레이 **검토 준비 완료**

사용자 실제 검토 전에는 “최종 완성”이라고 쓰지 않는다.

## 18. 현재 차단 조건

- 12단계 전체 사람 중심 10분+ 플레이 기록 없음
- placeholder box를 대체할 최종 art asset 승인 없음
- controller/keyboard drag·실패 recovery의 수동 검증 기록 없음
- 1280×720/1920×1080/2560×1440 최종 캡처와 사용자 리뷰 없음
- 구현 시작 전 이 네 조건이 해소되어야 한다.

현재 판정: **12단계 authored campaign placeholder 플레이 가능 / 최종 art·수동 플레이 검증 대기**
