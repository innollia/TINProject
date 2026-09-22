# TINProject — 현재 핸드오버

설계 철학: `docs/DESIGN_PHILOSOPHY.md`  
사용자 확정사항: `PROJECT_DECISIONS.md`  
작업 절차·검증: `AGENTS.md`

## 1. 현재 구현 상태

| 구분 | 내용 |
|---|---|
| 엔진 | Godot 4.7.2 stable / GDScript / GL Compatibility |
| 메인 씬 | `app/app_root.tscn` |
| 구조 | 영속 AppRoot + ModuleDirector + ModuleHost |
| 데모 | `click_counter`, `box_mover`, `room_3d` |
| 신규 모듈 | 25개 구현 |
| 저장 | 버전 있는 JSON-safe 모듈 상태 + global profile/records |
| 전역 UI | 상단 UI, Save/Load, pause, reset, 기록, 설정 |
| 기록 | 자동 observation + 수동 메모/태그 + 테마 |
| 마지막 기록 검증 | 통합 러너 639/639, GUT 113/113 / 4,419 assertions, smoke 통과 |

위 테스트 수치는 마지막 전체 검증 기록이다. 새 코드 변경 후에는 `AGENTS.md`의 전체 검증을 다시 실행한다.

## 2. 구현된 주요 콘텐츠

### 시작/경계
- `first_entry`: 키 흡수 → 블랙홀 → 낙하 편집 → 외형 선택 → 자연 배정
- 몸/기억 정체성 유지
- 죽음 귀환 / 세션 상태 초기화
- 기록/프로필 보존
- 설정 내 무의미 클리커

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
