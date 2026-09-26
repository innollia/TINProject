# godot-jrpg 외부 코드 감사 — Top-down Action-RPG Kit

조사 대상: https://github.com/kuryart/godot-jrpg  
감사 브랜치: `main`  
감사 시점 HEAD: `6d62e6e75d9533240eddc289a991607f39ef5780`  
HEAD 날짜: 2026-05-18  
라이선스: MIT  
판정: **전체 기반 채택 거부. 구조 참고 후 TIN module-local 직접 구현.**

## 1. 왜 전체 기반이 아닌가

저장소 README가 범위를 직접 명시한다.

- classic 2D JRPG/RPG Maker VX Ace inspired framework다.
- action RPG에는 작동하지 않는다고 적었다.
- Fear and Hunger, Don't Look Outside 같은 complex battle system에는 작동하지 않는다고 적었다.
- battle system은 skeleton, item/skill/AI는 planned 또는 incomplete다.
- load system은 planned다.
- 전체 저장소는 work-in-progress다.
- 별도 release와 tag가 없고 plugin version은 `0.1`이다.

BLACK SOULS 2는 단순 JRPG party battler가 아니라 다음을 동시에 요구한다.

- 민첩 기반 행동 scheduling
- extra action slots
- no-turn commands
- charge/commit/counter/punish
- target-specific Break
- Guard/Dodge의 상태·상호작용
- selective status cure/dispel
- field↔battle authored transition
- NPC/enemy/story conversion
- global state와 run-local state
- 큰 content remix

따라서 이 저장소를 그대로 가져오면 TIN 구조와 Primary Reference 사이에서 가장 어려운 부분이 맞지 않거나, 제거해야 할 framework bulk가 커진다.

## 2. 버전·license·dependency

확인된 사실:

- Godot `4.6`, TIN은 `4.7.2 stable`.
- MIT license라 독립 코드의 사용·수정·배포 자체는 허용된다.
- TIN `addons/at-icons`와 달리 외부 runtime dependency를 여러 개 요구한다.
- README dependency: Phantom Camera, Dialogue Manager 3, Safe Resource Loader, gd-plug, gd-plug-ui, Universal Fade.
- 일부 bundled art는 CC-BY/OGA-BY/CC0가 섞여 있다.
- art를 쓸 경우 file-level license와 저작자 표기를 별도 감사해야 한다.

판정:

- MIT 코드만 사용하더라도 TIN plugin/dependency policy를 우회할 근거가 되지 않는다.
- TIN에는 승인 없는 package/addon 추가가 금지되어 있다.
- 현재 bundle dependency 전체를 승인할 수 없다.
- Git HEAD만으로 release 안정성을 간주하지 않는다.

## 3. 참고할 가치가 있는 패턴

코드와 문서에서 다음 개념은 유용하다. 구현을 가져오기보다 TIN에서 더 단순하게 다시 설계한다.

### 3.1 Domain/presentation 분리

- `BattleEngine`는 UI 노드를 직접 소유하지 않고 battle logic을 담당한다.
- `BattleUI`는 입력과 표현을 담당한다.
- action intent를 먼저 만들고 queue에서 resolution한다.

TIN 적용:

```text
input intent
→ validated command
→ domain mutation
→ presentation projection
```

Godot `Control`/`Sprite2D` 상태가 HP나 phase의 진실이 되면 안 된다.

### 3.2 Resource-based content

- Item, Skill, Status, Target, Formula, Trait 등을 Resource로 표현한다.
- content와 formula를 교체해 구현 변경을 줄이는 방향이다.

TIN 적용:

- enemy/action/phase/encounter/status/equipment의 authored data에 참고한다.
- Resource는 runtime identity와 reference로 직접 저장하지 않는다.
- save는 stable ID + JSON-safe state로 codec한다.

### 3.3 Action queue와 atomic intent

- 선택 중에는 HP/inventory를 바꾸지 않고 action object를 만든다.
- resolution phase에서 순서대로 적용한다.

TIN 적용:

- field command, combat command, story event 모두 “검증 전 mutation 금지” 원칙을 참고한다.
- 실패한 target/command는 resource와 world state를 소비하지 않는다.

### 3.4 Modifier 재계산

- `TraitAggregator`가 장비·status·class의 modifier를 모아 조회한다.
- 일시 buff가 base stat을 직접 오염시키지 않는 방향이다.

TIN 적용:

- aggregate modifier query는 참고할 수 있다.
- BS2의 모든 stat, immunity, break, counter를 generic trait bag 하나로 과도하게 일반화하지 않는다.
- combat query surface는 Kit에서 실제 필요한 축으로 닫는다.

### 3.5 Controller/command 분리

- manual player, enemy AI, NPC, simulation controller를 command interface로 교체하는 구조다.

TIN 적용:

- player intent와 enemy decision은 같은 command vocabulary를 사용하되 서로 다른 policy를 가진다.
- controller abstraction을 RL/local multiplayer까지 미리 만들지 않는다.

### 3.6 Event command list

- map/dialogue/battle scene을 command resource 순서로 실행한다.

TIN 적용:

- authored story event의 표현 순서와 atomic effect validation에 참고한다.
- global EventBus나 autoload command runner는 TIN에 들이지 않는다.

## 4. TIN에 그대로 가져오면 충돌하는 부분

### 4.1 Autoload와 global manager

외부 project는 다음을 autoload로 둔다.

- GameManager
- MenuManager
- InputManager
- EventRunner
- Audio
- UI
- VFXManager
- DialogueManager
- PhantomCameraManager

TIN은 승인 없는 autoload, 범용 EventBus, service locator를 금지한다. 새 Kit combat/player/inventory를 global singleton으로 만들면 module isolation을 깨뜨린다.

판정: **Reject.**

### 4.2 Scene swap 방식

`CommandStartBattle`는 fade 후 battle scene을 올리고 battle 종료 후 map으로 돌아가는 전제를 가진다.

TIN은 AppRoot의 GameModule lifecycle과 module-local view를 유지한다. Kit 안에서 battle/map을 전역 scene swap하는 framework를 추상화하지 않는다.

판정: **Adapt structure only.**

### 4.3 Input wiring

외부 project는 project.godot의 `[input]`과 global InputManager에 직접 의존한다.

TIN은 manifest input allowlist와 ModuleContext를 사용한다. 새 모듈이 global InputMap이나 autoload controller에 직접 접근하면 안 된다.

판정: **Reject implementation; retain intent concept.**

### 4.4 Save representation

외부 문서는 `SaveState` Resource를 disk에 저장하는 전제를 사용한다.

TIN 저장은 versioned JSON-safe state다. Node, Resource, Callable, Vector를 직접 저장할 수 없다.

판정: **Reject.**

### 4.5 Turn/action order mismatch

`BattleEngine.calc_action_order()`는 action pool을 actor speed로 insertion sort하고 한 global turn cycle을 돈다.

BS2는 다음이 필요하다.

- agility-based schedule rate
- action slots
- no-turn cost
- charge spans turns
- break can cancel charge
- late death와 target invalidation
- enemy decision policy

단순 speed sort framework에 BS2 문법을 덧씌우려면 engine과 phase를 광범위히 수정해야 한다.

판정: **Direct Build.**

### 4.6 Party/class assumptions

외부 project는 party leader, class, XP, equipment slot, battle menu, multiple party member를 중심으로 한다.

TIN Reference Game은 BS2의 solo-like flow와 command/target 문법을 먼저 검증해야 한다. party/class/auto-battle을 선제 구현하지 않는다.

판정: **YAGNI; do not adopt.**

### 4.7 Generic EventBus signal resource

`BattleSignals` Resource를 engine/UI 공용 communication bus로 사용한다.

TIN에서 module-local event/direct callback는 가능하지만 범용 EventBus를 shared로 만들면 안 된다. presentation/domain 연결은 필요한 최소 surface만 둔다.

판정: **Adapt narrowly.**

### 4.8 UI와 art

- 외부 battle UI와 screenshots는 RPG Maker 계열이며 Primary Reference UI가 아니다.
- bundled art license가 여러 갈래다.
- 이 감사 당시에는 at-icons를 TIN world art 기본 재료로 권고했다. 이 제작 방향은 2026-09-25 사용자 지시에 따라 종료됐고, 관련 규칙은 `archive/icon_based_image_assets/`에 보존한다.
- UI icon과 world art를 구분한다.

판정: **No art/UI import.**

## 5. Adopt / Adapt / Build / Reject

| 대상 | 판정 | 이유 |
|---|---|---|
| domain/presentation 분리 | Adapt | TIN 계약에 맞춰 더 작게 재구성 |
| intent 후 atomic resolution | Adapt | 입력→command→mutation 원칙만 사용 |
| Resource content | Adapt | stable ID/JSON codec를 추가 |
| modifier re-computation | Adapt | BS2 query surface에 맞게 축소 |
| controller/command 분리 | Adapt | player/enemy policy만 필요 |
| event command authoring | Adapt | module-local, atomic validation |
| 전체 battle framework | Reject | action RPG/complex battle 비목표 |
| autoload/GameManager | Reject | TIN architecture 위반 |
| scene-swap battle shell | Reject | ModuleHost lifecycle 위반 |
| project-wide InputMap | Reject | ModuleContext allowlist 위반 |
| Resource save | Reject | JSON-safe 위반 |
| party/class/auto-battle | Reject | Primary Reference보다 앞선 scope |
| external UI/assets | Reject | Primary mismatch, mixed license |
| third-party addons | 현재 미채택 | 승인/dependency 감사 전 |

## 6. 최종 기술 결정

1. `godot-jrpg`를 submodule/addon/dependency로 설치하지 않는다.
2. 전체 파일을 복사해 framework를 변형하지 않는다.
3. 작은 MIT code file을 재사용해야 하는 specific case가 나중에 생기면 그때 해당 파일의 license, Godot 4.7 호환, dependency, test를 별도 감사한다.
4. 계획과 shared understanding이 완료된 뒤 구현 단계에서는 개념만 참고하고 `modules/top_down_action_rpg/`를 직접 구현한다.
5. combat/player/enemy/status/equipment/content/AI는 모두 module-local이다.
6. 기존 whitelist module을 직접 import하지 않는다.
7. `AppRoot → ModuleDirector → ModuleContext`와 versioned JSON save를 유지한다.
8. game_library는 새 manifest를 catalog에 노출하는 기존 흐름만 사용한다.

## 7. 예상 module-local 구조

```text
modules/top_down_action_rpg/
├── module_manifest.tres
├── entry.tscn
├── module.gd
├── domain/
├── systems/
│   ├── field/
│   ├── command/
│   ├── scheduling/
│   ├── combat/
│   ├── status/
│   ├── ai/
│   └── recovery/
├── content/
│   ├── actors/
│   ├── actions/
│   ├── phases/
│   ├── encounters/
│   ├── items/
│   ├── regions/
│   └── story/
├── presentation/
│   ├── field/
│   ├── combat/
│   ├── ui/
│   └── transitions/
├── authored/
└── tests/
```

`authored/`와 `tests/`의 최종 위치는 TIN 기존 convention을 확인한 뒤 확정한다. 새 directory가 필요해도 공용 registry를 먼저 만들지 않는다.

## 8. Import를 허용하는 유일한 조건

모두 현재는 **미허용**이다.

- exact file path와 commit SHA가 고정됨
- 해당 file이 MIT로 명확함
- Godot 4.7.2에서 parse/run됨
- 필요한 dependency가 zero이거나 별도 승인됨
- TIN module contract 위반이 없음
- file을 제외한 TIN architecture를 바꾸지 않음
- 해당 file에 dedicated test가 있음
- file-level audit 결과가 기록됨

큰 framework를 사용하면 이 조건들을 파일 단위가 아니라 프로젝트 전체에 적용해야 하므로 비용이 더 크다.

## 9. 사용자 입력 이후 다시 확인할 것

- 사용자가 제안한 BS2 gameplay에서 이 repo가 실제로 줄 수 있는 subsystem이 있는지
- formula/trait/event가 두 번째 실제 사용처 없이 필요한가
- no code import가 더 짧고 안전한지
- exact file-level code reuse가 core보다 작은지

기본값은 **직접 구현 + 필요한 개념 참고**다.
