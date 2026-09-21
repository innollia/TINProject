# 아키텍처

## 영속 셸

Godot 4.7.2 stable / GDScript / GL Compatibility. `project.godot`에서 `app/app_root.tscn`을 직접 시작한다. 1152×720 논리 해상도에 canvas_items stretch를 사용한다. Autoload는 없다.

```text
AppRoot
├── Core
│   ├── ModuleDirector
│   ├── SaveService
│   ├── SettingsService
│   ├── InputRouter
│   ├── TransitionService
│   └── AudioService
├── MetaLayer
├── ModuleHost
│   └── 현재 GameModule 하나
├── UIHost
└── DebugRoot
```

AppRoot는 끝까지 유지한다. 모듈 전환은 호스트 자식을 명시적으로 exit/remove/free한 뒤 새 모듈 하나만 붙인다. 전체 씬 교체, runtime plugin, 기본 SubViewport는 사용하지 않는다.

## 의존성과 소유권

- app → core/services, core/contracts, meta. 구체 manifest 카탈로그와 데모 입력 키 바인딩은 조립 지점인 app 소유다.
- core/services → core/contracts. core에는 장르 ID, 구체 모듈 경로, 장르별 동작이 없다.
- modules → core/contracts. 다른 모듈/app/meta 노드나 전역 서비스를 직접 찾지 않는다.
- meta → core/contracts. 완료 횟수와 결과, 간단한 내레이터 문구를 관리한다.
- shared는 두 모듈 이상에서 실제 재사용이 확인된 뒤 만든다. 지금은 필요 없어 만들지 않았다.
- 모듈의 씬·HUD·물리·카메라·장르 상태·리소스는 해당 `modules/<id>/` 안에 둔다.

새 모듈은 manifest와 GameModule 진입 씬을 제공하고 앱 카탈로그에 등록한다. 전용 키가 필요하면 앱의 바인딩에 추가한다. 기존 모듈과 core를 수정하지 않는다. 테스트의 설치 모듈 목록/장르별 기대값은 새 사례에 맞춰 확장한다.

## 실행 가능한 데모

- click_counter: 버튼/Enter로 10까지 증가, 완료 결과 한 번 발행.
- box_mover: WASD/방향키로 경계 안의 상자 이동.
- room_3d: 조명·바닥·큐브·카메라, 버튼/Enter로 회전.

공통 HUD는 첫 진입 전용 UI와 겹치지 않도록 시작 후에만 표시하며, 현재 공간·진행 위치·자동 저장 상태·입력 힌트를 제공한다. 공통 메뉴는 선택/전환, Save/Load, P/Escape 일시정지, reset 명령, Master 볼륨 저장을 제공한다. 모듈 자식은 process_mode를 상속한다. 정지/전환 동안 모듈 처리와 입력을 차단하되 셸은 살아 있다. 완료 후 자동 이동은 하지 않는다.

## 저장과 전환

SaveService는 format_version/current_module/global/modules 봉투만 이해한다. modules에는 schema_version/state가 있다. 전역 진행은 global.progression이다. JSON 문자열 키, 유한 숫자, 배열, 사전, bool/null만 저장한다. 모듈 상태는 깊은 복사한다. 쓰기는 tmp → 기존 파일 bak → 교체 순서이며 백업 파일은 남긴다. 자동 백업 복구는 아직 제공하지 않는다.

파일 Load 실패는 기존 메모리를 보존한다. 앱 restore_progress는 기존 봉투를 보관하고, 읽기 성공 후 director.change_module(id, true)를 호출하여 현재 실행 상태가 로드된 상태를 덮어쓰지 않게 한다. 알 수 없는 ID/미래 스키마/잘못된 진입 씬은 기존 모듈을 유지하고 봉투를 복구한다. 모듈 enter/load_state 내부의 임의 런타임 오류까지 롤백하는 구조는 아니다. 모듈 계약 테스트로 방지한다.

SettingsService는 ConfigFile 볼륨 설정, AudioService는 Master 아래 Music/SFX/UI/Voice와 영속 음악 플레이어를 소유한다. 장르 효과음은 모듈 소유다. 실제 BGM/음성 자산은 아직 없다.

## 검증과 한계

`AGENTS.md`에 엔진 파싱·통합 러너·GUT·smoke 명령을 고정했다. 테스트는 반복 전환, 상태 roundtrip, 입력 격리, 정지/재개, 완료 중복, 손상/미래 저장, 로드 덮어쓰기 회귀, 설정/오디오를 검사한다. DebugRoot는 로드된 모듈 수와 최근 앱 전환 시간을 표시한다.

목표 저사양 장치의 GPU/CPU/메모리 예산, 수동 UI 검수, 실제 콘텐츠/현지화/음성, 패키징·배포는 이 베이스의 완료 범위가 아니다. 성능 문제 확인 전 threaded loader나 공통 물리 추상화를 만들지 않는다.
