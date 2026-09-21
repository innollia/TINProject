# TINProject — 현재 핸드오버

설계 철학: `docs/DESIGN_PHILOSOPHY.md`  
사용자 확정사항: `PROJECT_DECISIONS.md`  
작업 절차·검증: `AGENTS.md`

## 1. 현재 구현 상태
> **2026-09-21 해석 교정:** 현재 구현 모듈은 소규모 모듈과 게임형 모듈을 구분해 읽는다. 기존 사용자 설계와 기존 모듈은 명시적 철회 없이 폐기·동결하지 않는다. '준호'는 임시 구현명이다.

| 구분 | 내용 |
|---|---|
| 엔진 | Godot 4.7.2 stable / GDScript / GL Compatibility |
| 메인 씬 | `app/app_root.tscn` |
| 구조 | 영속 AppRoot + ModuleDirector + ModuleHost |
| 데모 | `click_counter`, `box_mover`, `room_3d` |
| 신규 모듈 | 29개 구현 |
| 저장 | 버전 있는 JSON-safe 모듈 상태 + global profile/records |
| 전역 UI | 상단 UI, Save/Load, pause, reset, 기록, 설정 |
| 기록 | 자동 observation + 수동 메모/태그 + 테마 |
| 마지막 기록 검증 | 통합 러너 644/644, GUT 131/131 / 4,684 assertions, smoke 통과 |

위 테스트 수치는 마지막 전체 검증 기록이다. 새 코드 변경 후에는 `AGENTS.md`의 전체 검증을 다시 실행한다.

## 2. 구현된 주요 콘텐츠

### 시작/경계
- `first_entry`: 키 흡수 → 블랙홀 → 낙하 편집 → 외형 선택 → 자연 배정
- 몸/기억 정체성 유지
- 죽음 귀환 / 세션 상태 초기화
- 기록/프로필 보존
- 설정 내 무의미 클리커
| 경험 | 구현 위치 | 비고 |
|---|---|---|
| **첫 진입: 키 흡수→블랙홀→낙하 편집→자연 배정** | `modules/first_entry/` | 6키(화살표+Z/X) 순서 자유, 홀드 무시, 재실행 시 0.6s 단축 연출, 외형(실루엣 3×색 3)만으로 시작 작품 배정(결과표 없음) |
| **여러 시작·연결·왕복/편도/변형** | `app/app_root.gd` 라우트 테이블 + `GameModule.requested(kind,payload)` | 신호 기반, 모듈은 목적지 ID 모름. `signal_desk→relay_quay→last_echo→return_cradle` 세트 루프 + 숨은 `maintenance_cut` 지름길 |
| **다른 게임의 메인화면 위 걷기** | `modules/last_echo/` | "별의 정원" 메인 메뉴 글자·발판 위를 캐릭터가 이동, 준호(친구) 대화 존재 |
| **죽음→귀환→지름길(플래그 없이 행동만으로)** | `last_echo`(died) → `return_cradle` → `maintenance_cut`(90+왼쪽+확인) → `last_echo` | 세션 상태 초기화, 기록·정체성·프로필 보존, knowledge flag 금지 검증 통과 |
| **기록: 항상 열리는 비물질 UI(J키), 테마 수집만 해금** | `meta/records/` + `records_overlay` | 자동 관찰(`observation`), 수동 메모/태그(`add_note`), 5작품 테마 수집, 편집/삭제 가능 |
| **동료(준호) 신뢰·재회·흔적** | `last_echo`, `return_cradle` | 메타 해설 없이 세계관 내 대사로만 지원 |
| **설정 속 무의미 클리커** | `app/app_root.gd` `_on_useless_click` | 보상·진입 조건 연결 없음 |
| **신체 연속성·비성적 단순 실루엣** | `first_entry`·`last_echo`·`return_cradle` `_apply_identity` | 머리카락 3종·피부색 3종 조합, 폴리곤 프리미티브 |
| **두 번째 세트 「접힌 오후」** | `glyph_gallery`→`switchboard_choir`→`rain_lift`→`borrowed_title`→`glasshouse_return`→`teacup_orbit` | 2D/3D 혼합, 다른 게임 저장 화면 위 걷기, 개그 구간 뒤 원래 배달국으로 귀환 |
| **플래그 없는 지식 해법 2개** | 교환대 아래→왼쪽→위, 온실 아래→위→아래 | 단서를 못 봐도 아는 플레이어는 신선한 상태에서 즉시 통과 가능 |
| **교차 세트 지식 재사용** | `numberless_clock` | 기호관의 아래→왼쪽→위 규칙을 찻잔 궤도 아래 시계방에서 다시 사용 |
| **정적 선택형 3D 공간** | `shadow_ferry` | 그림자 길이를 관찰해 선착장을 고르는 무타이밍 퍼즐. 시계방과 왕복 가능 |
| **배열형 2D 공간** | `receipt_orchard` | 비→차→달 영수증 단서대로 종이 열매를 맞추고 신호 기록실로 귀환 |
| **관찰 코미디 공간** | `wrong_weather` | 위로 오르는 빗방울을 보고 가장 덜 틀린 예보를 골라 송출 |
| **동료 흔적 탐색 공간** | `quiet_locker` | 세 사물함을 자유 순서로 살피며 준호의 생활 흔적을 기록, 아이템 획득 없음 |
| **몸+기억 경계 선택** | `memory_customs` | 네 통과표 중 몸과 기억만 도장 찍어 경계를 통과, 해금 플래그 없음 |
| **순서 자유 진찰 공간** | `paper_moon_clinic` | 종이달의 세 증상을 자유 순서로 진찰하고 각각 관찰 기록 생성 |
| **잔상 방향 판별** | `afterimage_aquarium` | 세 수조 중 물고기와 잔상이 반대 방향인 곳을 정적 관찰로 선택 |
| **자기 그림자 관찰** | `paper_lighthouse` | 세 등대 중 자기 그림자를 비추는 곳을 정적 관찰로 선택 |
| **비주얼 노벨 단편** | `lost_signal_vn` | 두 단계 대화 분기·신뢰 수치·관찰 기록·저장을 한 장면에 결합 |
| **추리 조사** | `violet_case` | 세 증거 조사 → 범인·수법·동기 판정 → 사건 재구성 확인 → 귀환 |
| **사건 후일담** | `after_signal` | 접힌 답장·우편함·창문을 모두 읽고 다음 주소를 확인한 뒤 기록실로 귀환 |
| **주소 해독** | `return_address` | 세 흔적의 첫 단어를 주소 세 칸에 옮겨 봉인하고 기록실로 귀환 |
| **규칙 재작성** | `rule_rewriting` | 세 표찰을 관찰하고 두 규칙을 다시 써 방의 반응을 재판정 |
| **사건기록** | `dedution_casework` | 세 현장 기록 → 사건 순서 복원 → 범인·수법·동기 판정 |
| **물리 도구** | `physics_toolbox` | 실제 `RigidBody2D` 세 물체에 밀대·고정자·스프링을 적용하고 힘 전달을 재검증 |
| **시간 반복** | `time_loop` | 세 박자를 반복 관찰하고 기억을 유지한 채 다음 루프 경로를 판정 |
| **Godot 통합 팩** | `addons/tin_integrations/` | 26개 런타임 어댑터·에디터 플러그인·VN 템플릿. 전역 오토로드 없음 |

### 기존 세트/소규모 모듈
- `signal_desk`
- `relay_quay`
- `last_echo`
- `return_cradle`
- `maintenance_cut`
- `glyph_gallery`
- `switchboard_choir`
- `rain_lift`
- `borrowed_title`
- `glasshouse_return`
- `teacup_orbit`
- `numberless_clock`
- `shadow_ferry`
- `receipt_orchard`
- `wrong_weather`
- `quiet_locker`
- `memory_customs`
- `paper_moon_clinic`
- `afterimage_aquarium`
- `paper_lighthouse`
- `lost_signal_vn`
- `violet_case`
- `after_signal`
- `return_address`

### 통합 팩
- `addons/tin_integrations/`
- module-local RefCounted 기반
- dialogue/history, inventory, quest, relationship, timeline, evidence, checkpoint, scene stack, audio, camera shake, hotspot, event queue, settings 등
- 전역 autoload 없음

## 3. 계약

### GameModule

```gdscript
signal finished(result: ModuleResult)
signal requested(kind: StringName, payload: Dictionary)

func enter(context: ModuleContext) -> void
func exit() -> void
func save_state() -> Dictionary
func load_state(state: Dictionary) -> void
func migrate_save(old_version: int, data: Dictionary) -> Dictionary
func execute_command(command: StringName, payload: Dictionary = {}) -> bool
```

- `finished`: 실제 완료에만 사용
- 앱 이동/관찰/죽음 등은 `requested`
- 모듈은 목적지 ID를 모름
- `ModuleContext` 입력만 사용
- 다른 모듈/app/meta/autoload 직접 참조 금지

### ModuleContext

현재 주요 읽기 전용 데이터:
- `module_id`
- `input_enabled`
- `allowed_actions`
- `arrival`
- `identity_view`

`arrival`, `identity_view`는 깊은 복사로 주입된다.

### ModuleDirector

```gdscript
change_module(id, restore_snapshot=false, arrival={}, identity={}, discard_current=false)
```
- `discard_current=true`: 죽음 귀환 시 현재 모듈 상태 캡처 생략 + 이전 세션 상태 롤백.
- `arrival`, `identity`는 Director가 깊은 복사 후 컨텍스트에 주입.

### AppRoot — 라우트/프로필/기록 소유
- `ROUTES` 딕셔너리: 앱만 목적지 해석. 모듈은 로컬 `exit` 키만 방출.
- `profile`: `{intro_seen, shape, color, started}` — `user://save.json` 봉투의 `global.profile`에 저장.
- `records_store`(RefCounted): `observe/visit/capture/restore/add_note/select_theme` API.
- `records_overlay`(Control): `setup(store)`, `refresh()`, `close_requested` 시그널.

### 입력 액션 네이밍 규칙(앱이 바인딩)
- 기존: `click_counter_confirm`, `box_mover_left/right/up/down`, `room_3d_rotate`
- 신규 공통 접두사: `<module_id>_left/right/up/down/confirm/cancel` (화살표+Z/X)

---

## 4. 파일 소유권(충돌 방지 — 다음 작업자 필독)

| 담당 | 소유 경로 | 수정 금지 경로 |
|---|---|---|
| **계약·앱 통합** | `core/contracts/*.gd`, `core/services/module_director/*.gd`, `app/app_root.gd`, `app/app_root.tscn`, `tests/run_tests.gd`, `tests/core/test_cycle_app.gd` | `modules/*`, `meta/records/*` |
| **첫 진입** | `modules/first_entry/**`, `tests/core/test_first_entry.gd` | 위 외 전부 |
| **세트·기록** | `modules/{signal_desk,relay_quay,last_echo,return_cradle,maintenance_cut}/**`, `meta/records/**`, `tests/core/test_set_modules.gd`, `tests/core/test_records.gd` | 위 외 전부 |

> **규칙:** 동일 파일 동시 수정 금지. 공유 파일(`app_root`, `run_tests`, `contracts`)은 계약·앱 통합 담당만 수정.

---

## 4.1 게임형 모듈 상세 계획

게임형 모듈은 콘텐츠를 먼저 채우지 않고 시스템 기반부터 만든다. 구현 시작점은 `plans/game_modules/INDEX.md`다.

현재 상세 계획:
- `01_RULE_REWRITE.md` — Baba Is You 레퍼런스, 규칙 재작성 엔진
- `02_DEDUCTION_CASEWORK.md` — Golden Idol 레퍼런스, 추리/사건 재구성 엔진
- `03_PHYSICS_TOOLBOX.md` — Mosa Lina 레퍼런스, 물리 도구 샌드박스
- `04_TIME_LOOP.md` — In Stars and Time 레퍼런스, 시간루프 상태 시스템

공통 원칙은 **Adopt → Adapt → Build**다. 공개 구현을 먼저 조사하고 라이선스/버전/전역 의존성을 확인한 뒤 재사용 가능한 subsystem은 가져오며, 부족한 부분만 직접 구현한다.

---

## 4.2 콘텐츠 증설 계획

2026-09-21 사용자 아이디어 덤프를 `plans/content_expansion/`에 배치했다.

- `INDEX.md` — 기존 모듈 확장 / 신규 게임형 모듈 / 백로그 배치 원칙
- `01_EXISTING_MODULES.md` — `violet_case`, `paper_moon_clinic`, `quiet_locker` 중심의 즉시 분량 증설
- `02_REINCARNATOR_ROAD.md` — 환생 왕녀·이상한 인생 목표·공룡/감자 여행 게임형 모듈
- `03_TEXTILE_REVOLT.md` — 이불 반란·베개 기억장치·직물 첩보 세계 게임형 모듈
- `BACKLOG.md` — 사막 바늘, 괴담 인력소, 태어나기 전 정책 투표, 저작권 협회, 탑, 공룡 문화권, 개그 seed 등 후속 보존

**콘텐츠 단계의 우선순위는 기존 얕은 모듈의 실제 상호작용 수와 선택 콘텐츠를 먼저 늘리는 것**이다. 아이디어 하나마다 새 모듈을 만들지 않는다.

---

## 5. 즉시 재개 가능한 다음 작업(우선순위)

### 5.1 git 기준점

사용자 승인 후 저장소 초기화와 첫 커밋을 완료했다.

### 5.2 사이클 2 완료 내역
| 작업 | 예상 소요 | 비고 |
|---|---|---|
| 첫 진입 960×600·1152×720 레이아웃 검수 | 완료 | 두 해상도 렌더 캡처에서 햄버거·언어·편집 패널·부딪히기 겹침 없음 |
| `last_echo`·`return_cradle` 대사 자연화 | 완료 | 준호 이름 표기, 친구다운 문구, 귀환 정박지 3단계 반복 대화 |
| 기록 편집/삭제 UI와 저장 테스트 | 완료 | `edit_note`, `remove_note`, 오버레이의 stale selection 보호 포함 |
| 시작 3종 콘텐츠 확장 | 완료 | `signal_desk` 순환 우편, `relay_quay` 다단계 배달, `return_cradle` 재회 대화 |
| Iris Xe 실기 측정 | 완료 | 1152×720: 첫 진입 25~26 FPS/320.3 MiB, 중계 안뜰 37~39 FPS/402.9 MiB. setup 1.691초, load 0.171초 |
| 배치 증산 | 완료 | 신규 6개, 누적 12 신규 + 3 데모 = 15개. 신규 6개 테마와 GL 캡처 포함 |

### 5.3 사이클 3 현재 기준점

`paper_lighthouse` → `lost_signal_vn` → `violet_case` → `after_signal` → `return_address` → `rule_rewriting` → `dedution_casework` → `physics_toolbox` → `time_loop` → `signal_desk` 라우트가 연결되어 있다. 사이클 4는 규칙 재작성·사건 추리·실제 물리 도구·시간 반복을 각각 독립 모듈로 추가했으며, 다음 작업도 모듈 격리·불투명 저장·관찰 기록·실제 입력·시각 검증 계약을 유지한다.

---

## 6. 알려진 제한·미완료(사이클 1 범위 밖)

- **엔딩/전체 스토리**: 미구현(의도적 제외).
- **자동 번역/현지화**: ko/en 문자열만 하드코딩, 완전 i18n 아님.
- **긴 3D 모듈(L등급)**: 실측 전 미제작.
- **공용 테마 시스템(전역 Theme 리소스)**: 각 모듈/기록이 자체 팔레트 사용.
- **성능 여유**: Intel Iris Xe 1152×720 실제 창에서 첫 진입 25~26 FPS, 중계 안뜰 37~39 FPS로 측정되어 60 FPS는 보장하지 않는다.
- **프로필/기록 별도 저장 파일(`entry_profile.json`)**: 현재는 메인 봉투 `global.profile` + `global.records`로 통합 저장(분리 불필요 판정).

---

## 7. 검증 명령(변경 없음 — AGENTS.md 준수)

```powershell
$exe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'
$p = Start-Process -FilePath $exe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait -PassThru; $p.ExitCode
$p = Start-Process -FilePath $exe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/run_tests.gd' -NoNewWindow -Wait -PassThru; $p.ExitCode
$p = Start-Process -FilePath $exe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gexit' -NoNewWindow -Wait -PassThru; $p.ExitCode
$p = Start-Process -FilePath $exe -ArgumentList '--headless --path C:\projects\TINProject --quit-after 180 --fixed-fps 60' -NoNewWindow -Wait -PassThru; $p.ExitCode
```

- 일반 전환은 현재 모듈 캡처
- `discard_current=true`는 죽음 귀환 등 세션 롤백용
- 전환 중 입력 차단

### 저장

- core는 모듈 state 의미를 해석하지 않음
- JSON-safe 값만 저장
- 모듈별 schema_version/migration
- Node/Resource/Callable 저장 금지
- 미래 schema는 거부

상세 계약은 `docs/MODULE_CONTRACT.md`.

> **핵심 불변식:**  
> 1. 모듈은 목적지 ID·다른 모듈 상태·전역 저장·autoload 모름.  
> 2. `requested` 시그널로만 앱과 통신. `finished`는 완료만.  
> 3. `context.arrival/identity_view`는 읽기 전용 깊은 복사.  
> 4. 죽음 귀환은 세션 상태 초기화, 기록/프로필/정체성 보존.  
> 5. 기록 기능은 처음부터 전부 제공, 테마 수집만 해금.  
> 6. 공통 성장 재화/인벤토리/능력치 **없음**.  
> 7. 메타 해설(게임 구조 설명 대사) **금지**.  
> 8. 기존 데모 3개·644 checks·GUT 131/131 **회귀 0** 유지.

## 4. 소유권

공유 파일:
- `app/app_root.gd`
- `app/app_root.tscn`
- `core/contracts/**`
- `core/services/**`
- `tests/run_tests.gd`

동시 병렬 수정 금지.

모듈 작업은 기본적으로 해당 `modules/<id>/**`와 전용 테스트 안에서 끝낸다.

## 5. 활성 계획

### 게임형 모듈

`plans/game_modules/INDEX.md`

- `01_RULE_REWRITE.md`
- `02_DEDUCTION_CASEWORK.md`
- `03_PHYSICS_TOOLBOX.md`
- `04_TIME_LOOP.md`
- `05_ODD_ROAD_ADVENTURE.md`

### 콘텐츠 증설

`plans/content_expansion/INDEX.md`

- `01_EXISTING_MODULES.md`
- `03_TEXTILE_REVOLT.md`
- `BACKLOG.md`

`plans/`에는 미구현 작업만 둔다. 구현 완료 후 해당 계획은 삭제한다.

## 6. 알려진 미완료/제약

- 전체 엔딩/스토리: 미구현
- 완전한 i18n: 미구현
- 정식 아트/오디오: 대부분 미구현
- Intel Iris Xe 1152×720 기준 과거 측정에서 60 FPS 미보장
- 게임형 대형 모듈 5종 계획: 아직 구현 전
- 콘텐츠 증설 계획: 아직 구현 전

## 7. 검증

`AGENTS.md`의 순서 고정:

1. Godot import
2. 통합 러너
3. GUT
4. smoke
5. 영향받은 씬 수동/시각 확인

완료된 계획서나 과거 사이클 계획은 검증 근거로 사용하지 않는다.  
현재 코드·테스트 결과가 기준이다.

## 8. 현재 시각 개편 트랙

기능 구현 상태와 별개로 현재 화면 품질은 개편 대상으로 본다. 기존 모듈 다수가 네모, Label, 단순 프리미티브 중심으로 작성되어 있으며 이를 완성 아트로 간주하지 않는다.

새 기준:
- docs/VISUAL_DIRECTION.md
- plans/visual_overhaul/INDEX.md
- 사용자 제공 MIT 에셋 경로: res://addons/at-icons/
- at-icons는 월드 아트 콜라주 재료로만 사용
- UI 아이콘 금지
- 원래 아이콘 의미 그대로 사용 금지
- 주요 화면은 상용 게임 레퍼런스를 실제로 확인한 뒤 구현

대형 신규 모듈 계획도 동일한 시각 계약을 포함한다. 기능 시스템만 만든 뒤 화면을 나중 문제로 미루는 방식으로 완료 처리하지 않는다.
다음 작업자는 `PROJECT_DECISIONS.md` 0절의 **소규모 모듈 / 게임형 모듈 규모 구분**을 먼저 적용한다. 기존 모듈은 필요하면 그대로 재사용·조합·확장한다. 소규모 모듈 하나를 억지로 독립 게임으로 완결하지 말고, 게임형 모듈을 만들 때는 30분~8시간 규모의 밀도 있는 콘텐츠 잠재력을 별도로 설계한다. 지식 기반 요소를 표방할 때만 `docs/KNOWLEDGE_BASED_DESIGN.md` 기준을 적용한다.
