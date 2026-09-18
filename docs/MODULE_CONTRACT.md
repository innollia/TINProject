# 모듈 계약

## Manifest

`core/contracts/module_manifest.gd`는 Resource다. id(StringName), display_name(String), entry_scene(tscn 경로), save_version(1 이상), input_actions(PackedStringArray)를 제공한다. ID는 저장 호환성 때문에 안정적으로 유지한다. 앱의 Array[ModuleManifest] 카탈로그만 설치 목록을 결정한다.

## GameModule

```gdscript
signal finished(result: ModuleResult)
func enter(context: ModuleContext) -> void
func exit() -> void
func save_state() -> Dictionary
func load_state(state: Dictionary) -> void
func migrate_save(old_version: int, data: Dictionary) -> Dictionary
func execute_command(command: StringName, payload: Dictionary = {}) -> bool
```

- GameModule은 Node다. enter/exit override는 super를 호출한다.
- 새 인스턴스마다 새 ModuleContext를 주입한다. context.module_id, input_enabled, allowed_actions와 allows_action/is_action_pressed/get_axis를 제공한다. 서비스 로케이터가 아니다.
- 입력 활성화는 InputRouter 소유다. 모듈은 input_enabled를 읽기만 한다. 허용 액션만 폴링하고 버튼 콜백도 input_enabled를 검사한다.
- 이관은 씬 트리에 들어가기 전 실행하는 순수 데이터 변환이다. 기본 구현은 깊은 복사다. 노드/@onready/context에 의존하지 않는다.
- 다음 순서로 진입한다: context 할당 → add_child 및 _ready → load_state → enter → fade in → 처리/입력 활성화.
- _ready에서 플레이를 시작하지 않는다. load_state는 `{}`이면 초기 상태로 복원하고 입력을 기다리지 않는다. JSON 숫자는 float로 돌아올 수 있으므로 모듈에서 정규화한다.
- 자식 process_mode는 INHERIT다. 모듈 처리/입력이 전환 동안 꺼져 있어도 enter가 호출될 수 있다.
- exit는 타이머/외부 신호/참조 등 자신이 만든 자원을 정리한다. director가 exit → remove_child → free한다. 외부에 소유자 없는 노드를 만들지 않는다.
- finished는 module_id/outcome/data를 전달한다. 완료 중복 방지는 모듈 책임이다. director는 현재 모듈의 결과만 전달하고 진입 중 결과는 전환 종료까지 보관한다.
- reset 명령 지원 시 true, 알 수 없는 명령은 false다. Meta가 구체 플레이어 필드를 조작하지 않는다.

## 저장

SaveService는 `get_module_state(id) -> {schema_version, state}` 또는 `{}`를 반환한다. `set_module_state(id, version, state)`는 깊은 복사한다. `export_data()/import_data(data)`는 전체 봉투 경계다. import는 검증 후 교체하며 실패 시 기존 메모리를 유지한다.

schema_version이 manifest보다 크면 전환을 거부한다. 작으면 모듈 migrate_save를 호출한다. 상태 의미는 core가 해석하지 않는다. Node/Resource/Callable/Vector/비유한 숫자는 JSON 상태에 넣지 않는다. save_file은 JSON 안전성을 검사하고 실패 시 오류를 반환한다.

## Director와 서비스

```gdscript
ModuleDirector.setup(host: Node, catalog: Array[ModuleManifest], router: InputRouter, saves: SaveService, transition: TransitionService) -> void
ModuleDirector.change_module(id: StringName, restore_snapshot: bool = false) -> Error
ModuleDirector.unload_module() -> void
ModuleDirector.capture_current() -> void
ModuleDirector.execute_command(command: StringName, payload: Dictionary = {}) -> bool
SaveService.save_file(path: String = "user://save.json") -> Error
SaveService.load_file(path: String = "user://save.json") -> Error
```

change_module은 await한다. restore_snapshot=true는 디스크 복원 전용으로 기존 모듈 상태 캡처를 건너뛴다. 일반 전환/unload는 캡처한다. busy 중 전환은 ERR_BUSY이며 unload/command를 차단한다. current_module/current_id/busy와 module_changed/module_finished를 제공한다.

InputRouter는 공통 meta 액션만 등록한다. 데모 전용 키 바인딩은 app에서 조립한다. TransitionService는 ColorRect overlay와 duration을 받아 fade_out/fade_in한다. SettingsService는 changed()와 볼륨 저장/읽기를 제공한다. AudioService는 setup/set_volume/play_music(stream: AudioStream)/stop_music를 제공한다.

## 금지

다른 모듈 참조, core의 구체 모듈 import, `/root` 또는 autoload 조회, 앱 노드 경로 의존, 전역 EventBus, 모든 장르 공통 Player/Combat/Physics를 금지한다. 자산은 모듈 가까이 두고 실제 재사용 전까지 shared로 옮기지 않는다.
