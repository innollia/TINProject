# 아키텍처

## 1. 목적

런타임은 **한 게임 안에서 장르가 바뀌는 것**을 지원한다.

`GameModule`은 교체 가능한 실행 단위이고 `Kit`는 특정 장르 시스템을 미리 완성해 두는 개발 단위다. 둘은 같은 개념이 아니다.

## 2. 영속 AppRoot

Godot 4.7.2 stable / GDScript / GL Compatibility.

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

AppRoot는 유지하고 ModuleHost의 현재 GameModule만 교체한다.

전체 씬 교체를 기본값으로 삼지 않는다. 모듈은 다른 모듈의 존재를 모른다.

## 3. Shell은 기술적으로 영속, 시각적으로는 비영속

영속 Shell은 저장/설정/전환 수명을 유지하기 위한 기술 구조다.

플레이 화면에 상시 Shell HUD를 띄우지 않는다.

금지:
- 현재 공간명 상시 표시
- 자동 저장 상태 상시 표시
- 키설명 상시 표시
- Menu/Journal 상시 버튼

Esc 메뉴 등은 사용자가 호출했을 때만 나타난다. 닫으면 원래 GameModule의 화면과 focus로 돌아간다.

DebugRoot는 개발 빌드/검수에서만 사용하고 release 플레이 화면의 일부로 취급하지 않는다.

## 4. 의존성과 소유권

- app → core/services, core/contracts, meta, manifest 조립
- core/services → core/contracts
- modules → core/contracts + module-local 구현
- meta → core/contracts
- modules 간 직접 참조 금지
- core가 구체 module ID/경로/장르 동작을 알지 않음
- shared는 두 실제 사용처에서 동일 계약이 확인된 뒤에만 추출

Kit 전체를 공용 framework로 승격하지 않는다.

## 5. GameModule과 Kit

### GameModule
런타임 교체 단위:
- enter/exit
- save/load
- ModuleContext input
- requested/finished

### Kit
개발/설계 단위:
- 장르 핵심 system
- authored content format
- presentation
- 10분+ Reference Game
- Primary Reference 기반 UX
- 테스트/검수

하나의 Kit가 여러 GameModule을 사용할 수 있다.

## 6. Input 전환

새 장르 구간에서 필요한 물리 키 집합이 달라지면 App/전환층은 `docs/KIT_WORKFLOW.md`의 Input Bubble을 사용할 수 있다.

Input Bubble은 GameModule 안의 상시 키설명 HUD가 아니다.

- 필요한 기존 키 복구
- 새 키 상승
- 필요 없는 키는 popped 흔적 유지
- 실제 키 입력으로 bubble pop

입력 의미 자체는 각 GameModule의 InputMap action과 ModuleContext가 소유한다.

## 7. 저장과 전환

SaveService는 전역 봉투와 module state를 저장한다.

module state:
- versioned
- JSON-safe
- 의미/이관은 module 소유

전환:
1. 현재 module 입력 차단
2. 필요한 상태 capture
3. exit
4. remove/free
5. 새 context 생성
6. 새 module attach/load/enter
7. transition 완료
8. input 활성화

장르 전환 연출이 Input Bubble을 포함하더라도 module domain state와 분리한다.

## 8. 해상도

현재 project setting의 과거 기준값은 지원 범위를 뜻하지 않는다.

새 화면의 필수 검수:
- 1280×720
- 1920×1080
- 2560×1440

UI는 anchor/Container 중심으로 대응한다. grid/board 등 게임 규칙상 좌표가 중요한 월드는 별도 계산을 사용한다.

## 9. 개발/탐색용 game_library

`modules/game_library/`는 Nintendo OS 계열 레퍼런스를 따라 만든 개발/탐색용 목록 UI로 취급한다.

이 도구는:
- 여러 GameModule을 빠르게 열어 검수하는 데 사용할 수 있다.
- Kit나 게임 콘텐츠 수에 포함하지 않는다.
- 플레이 중 상시 HUD로 노출하지 않는다.

## 10. Retired Prototype

현재 whitelist 바깥의 기존 플레이 모듈은 Retired Prototype이다.

런타임에 남아 있더라도:
- 신규 Kit 설계의 기준이 아님
- 현재 품질 기준의 완료 사례가 아님
- 아이디어/대사/UI의 source of truth가 아님

코드 삭제는 별도 구현 작업에서 진행한다.
