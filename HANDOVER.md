# 핸드오버 — 사이클 3 진행 중 / 다음 작업 재개용

작성 시각: 2026-09-21. 단독 작업으로 후일담 모듈을 추가한 뒤 전체 검증 통과.

> **2026-09-21 해석 교정:** 현재 25개 신규 모듈은 그대로 유효한 소규모 모듈이다. 문제는 존재나 규모가 아니라, 구현 에이전트가 각각을 독립된 완성 게임처럼 취급해 얕은 미니게임 릴레이로 만든 해석이다. `PROJECT_DECISIONS.md` 0절의 모듈 규모 구분을 먼저 읽는다. 기존 사용자 설계와 기존 모듈은 명시적 철회 없이 폐기·동결하지 않는다. '준호'는 임시 구현명이다.
---

## 1. 현재 상태 요약

| 구분 | 내용 |
|---|---|
| **엔진/프로젝트** | Godot 4.7.2 stable, `C:\projects\TINProject`, 메인 씬 `app/app_root.tscn` |
| **핵심 아키텍처** | 영속 AppRoot + ModuleDirector, 모듈 격리(모듈 간 직접 참조 금지), 불투명 버전 JSON 저장, autoload/EventBus 금지 |
| **기존 데모(회귀 기준)** | `click_counter`, `box_mover`, `room_3d` — **무수정 보존**, 통합 테스트 639 checks 유지 |
| **신규 구현 모듈** | 25개: 사이클 1·2의 12개 + 사이클 3 신규 13개(`numberless_clock`부터 `return_address`까지) |
| **신규 시스템** | 기록 v1(전역 관찰·수동 정리·테마 수집), 죽음·귀환·지름길 검증, 프로필·체크포인트, 공용 메뉴/저널/클리커 |
| **검증 상태** | `import` → 통합 러너(639/639) → GUT(113/113, 4,419 assertions) → smoke — **전부 통과(종료 코드 0, SCRIPT ERROR 0)** |
| **git** | 사용자 승인 후 저장소 초기화·첫 커밋 완료. |

---

## 2. 구현된 핵심 경험(확정 방향 반영)

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
| **Godot 통합 팩** | `addons/tin_integrations/` | 26개 런타임 어댑터·에디터 플러그인·VN 템플릿. 전역 오토로드 없음 |

---

## 3. 계약·인터페이스 확정 사항(다른 모듈 작성 시 준수)

### 3.1 GameModule — 신규 시그널/명령
```gdscript
signal requested(kind: StringName, payload: Dictionary)
```
- `kind` 표준: `portal {exit}`, `died {}`, `observation {id,text}`, `checkpoint {intro_seen}`, `start {shape,color}`, `menu {}`, `language {}`
- `finished`는 **진짜 완료**만 사용(포털·죽음·관찰은 `finished` 금지)

### 3.2 ModuleContext — 신규 읽기 전용 데이터(깊은 복사 주입)
```gdscript
var arrival: Dictionary = {}      # {intro_seen, language}
var identity_view: Dictionary = {} # {shape, color}
```
- 모듈은 `context.arrival`, `context.identity_view`만 읽음. 쓰기 금지.

### 3.3 ModuleDirector.change_module — 확장 인자
```gdscript
func change_module(id, restore_snapshot=false, arrival={}, identity={}, discard_current=false)
```
- `discard_current=true`: 죽음 귀환 시 현재 모듈 상태 캡처 생략 + 이전 세션 상태 롤백.
- `arrival`, `identity`는 Director가 깊은 복사 후 컨텍스트에 주입.

### 3.4 AppRoot — 라우트/프로필/기록 소유
- `ROUTES` 딕셔너리: 앱만 목적지 해석. 모듈은 로컬 `exit` 키만 방출.
- `profile`: `{intro_seen, shape, color, started}` — `user://save.json` 봉투의 `global.profile`에 저장.
- `records_store`(RefCounted): `observe/visit/capture/restore/add_note/select_theme` API.
- `records_overlay`(Control): `setup(store)`, `refresh()`, `close_requested` 시그널.

### 3.5 입력 액션 네이밍 규칙(앱이 바인딩)
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

`paper_lighthouse` → `lost_signal_vn` → `violet_case` → `after_signal` → `return_address` → `signal_desk` 라우트가 연결되어 있다. `return_address`는 사건 해결 뒤 다음 신호의 주소를 해독하는 종결부이지 전체 엔딩은 아니며, 다음 작업도 모듈 격리·불투명 저장·관찰 기록·실제 입력·시각 검증 계약을 유지한다.

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

**모두 종료 코드 0, stderr에 `SCRIPT ERROR`/`ERROR` 없어야 통과.**

---

## 8. 인계 문구(다음 작업자용)

> **핵심 불변식:**  
> 1. 모듈은 목적지 ID·다른 모듈 상태·전역 저장·autoload 모름.  
> 2. `requested` 시그널로만 앱과 통신. `finished`는 완료만.  
> 3. `context.arrival/identity_view`는 읽기 전용 깊은 복사.  
> 4. 죽음 귀환은 세션 상태 초기화, 기록/프로필/정체성 보존.  
> 5. 기록 기능은 처음부터 전부 제공, 테마 수집만 해금.  
> 6. 공통 성장 재화/인벤토리/능력치 **없음**.  
> 7. 메타 해설(게임 구조 설명 대사) **금지**.  
> 8. 기존 데모 3개·639 checks·GUT 113/113 **회귀 0** 유지.

다음 작업자는 `PROJECT_DECISIONS.md` 0절의 **소규모 모듈 / 게임형 모듈 규모 구분**을 먼저 적용한다. 기존 모듈은 필요하면 그대로 재사용·조합·확장한다. 소규모 모듈 하나를 억지로 독립 게임으로 완결하지 말고, 게임형 모듈을 만들 때는 30분~8시간 규모의 밀도 있는 콘텐츠 잠재력을 별도로 설계한다. 지식 기반 요소를 표방할 때만 `docs/KNOWLEDGE_BASED_DESIGN.md` 기준을 적용한다.
