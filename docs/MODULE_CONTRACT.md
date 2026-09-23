# 모듈 계약

## 용어

- **GameModule**: AppRoot의 ModuleHost에 붙는 런타임 교체 단위.
- **Kit**: 특정 장르 시스템을 미리 구현하고 Reference Game으로 검증하는 개발 단위.

둘은 같은 말이 아니다. Kit 전체를 공개 framework API로 만들지 않는다.

## Manifest

`core/contracts/module_manifest.gd`는 Resource다.

필수:
- id
- display_name
- entry_scene
- save_version
- input_actions

ID는 저장 호환성을 위해 안정적으로 유지한다.

## GameModule

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

- GameModule은 Node다.
- enter/exit override는 super를 호출한다.
- 새 instance마다 새 ModuleContext를 주입한다.
- `_ready`에서 gameplay를 시작하지 않는다.
- load_state는 scene tree 진입 뒤, enter 전에 적용된다.
- child process_mode는 INHERIT를 유지한다.
- input은 ModuleContext가 허용한 action만 사용한다.
- button callback도 input_enabled를 확인한다.
- exit는 자신이 만든 timer/signal/reference를 정리한다.
- 다른 module/app/meta node를 직접 찾지 않는다.
- `/root` 탐색이나 service locator를 사용하지 않는다.

## ModuleContext

ModuleContext는 service locator가 아니다.

현재 핵심:
- module_id
- input_enabled
- allowed_actions
- arrival
- identity_view
- action query helper

장르별 서비스가 필요하다고 해서 context를 무제한 bag으로 만들지 않는다.

## requested / finished

`finished`는 실제 module 완료 결과에 사용한다.

앱에 의도를 요청해야 하는 전환/관찰/메뉴 등은 `requested(kind,payload)`를 사용한다.

module은 목적지 GameModule ID를 직접 알지 않는다. 앱이 route를 해석한다.

## 저장

SaveService는 module state를:
- schema version과 함께
- 깊은 복사로
- JSON-safe 형태로
보관한다.

허용:
- string key dictionary
- string/number/bool/null
- array
- finite number

금지:
- Node
- Resource
- Callable
- Vector 자체
- NaN/Inf

상태 의미와 migrate는 module 소유다.

UI focus, hover, 열린 tooltip, tween 같은 presentation-only 상태는 진행 의미가 없다면 저장하지 않는다.

## Director

`ModuleDirector`는:
- 현재 module 하나
- 전환 busy
- load/enter/exit 순서
- state capture
를 소유한다.

일반 순서:
1. input 차단
2. 필요 시 current state capture
3. exit
4. remove/free
5. new context
6. new module attach
7. load_state
8. enter
9. transition
10. input enable

## Shell과 Module

AppRoot/Shell이 기술적으로 영속한다고 해서 module 화면 위에 상시 UI를 띄우지 않는다.

Shell UI는 호출 시에만 보이며, 닫으면 module의 유효한 focus/input으로 복귀한다.

새 장르 구간의 물리 키 집합 학습은 module HUD가 아니라 전환층의 Input Bubble을 사용할 수 있다.

## Kit와 shared

Kit의 장르 시스템은 module-local을 우선한다.

두 실제 사용처에서 같은 의미와 계약이 확인된 뒤에만 작은 shared unit을 추출한다.

금지:
- 모든 장르 공통 Player
- 모든 장르 공통 Inventory
- 모든 장르 공통 Combat
- 범용 UI framework 선제 구축
- 다른 module 직접 참조

## 검증

새 GameModule/Kit는:
- input disabled
- save/load
- reset/re-entry
- transition
- stale state
- module isolation
을 자동 테스트한다.

화면 완료는 별도다. `docs/KIT_WORKFLOW.md`, `docs/UI_WORKFLOW.md`, `docs/VISUAL_DIRECTION.md`의 수동 검수를 통과해야 한다.
