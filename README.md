# TINProject

Godot 4.7.2 / GDScript 기반의 **한 게임 내부 장르 전환 프로젝트**.

TINProject의 목표는 여러 미니게임을 많이 만드는 것이 아니다. 한 게임이 FPS → 2D 추리 → 3D 퍼즐 → 클리커처럼 장르를 바꿀 때, 필요한 장르 시스템을 즉시 꺼내 쓸 수 있도록 **Kit**를 미리 만들어 두는 것이다.

## 먼저 읽기

- 용어: `CONTEXT.md`
- 사용자 확정: `PROJECT_DECISIONS.md`
- 설계 철학: `docs/DESIGN_PHILOSOPHY.md`
- Kit 작업 계약: `docs/KIT_WORKFLOW.md`
- UI 작업 계약: `docs/UI_WORKFLOW.md`
- 시각 기준: `docs/VISUAL_DIRECTION.md`
- AI 작업 규칙: `AGENTS.md`
- 현재 상태: `HANDOVER.md`
- Kit 계획: `plans/kits/INDEX.md`
- 새 Kit 계획 템플릿: `plans/kits/TEMPLATE.md`

## 런타임 구조

```text
AppRoot
├── Core
├── MetaLayer
├── ModuleHost
│   └── 현재 GameModule
├── UIHost
└── DebugRoot
```

`GameModule`은 런타임 교체 단위이고 `Kit`는 장르 시스템 계획 단위다. 둘은 같은 말이 아니다.

## 현재 보존 후보

- `modules/first_entry/` — 시작/입력 학습 로직
- `modules/rule_rewriting/` — 규칙 재작성 시스템 기반
- `modules/odd_road_adventure/` — 탐험/아이템/NPC/사건 시스템 기반
- `modules/game_library/` — 개발/탐색용 게임 목록 UI

그 외 기존 플레이 모듈은 Retired Prototype이며 새 설계의 기반으로 사용하지 않는다. 코드 삭제는 별도 구현 작업에서 진행한다.

## Kit 기준

Kit마다:
- Primary Reference 하나
- 실제 레퍼런스 화면/플레이 조사
- 핵심 시스템 + UX 구현
- 10분 이상 Reference Game
- 여러 authored content가 같은 core를 재사용
- 1280×720 / 1920×1080 / 2560×1440 검수
- 사용자 플레이 검토 준비
가 필요하다.

새 계획은 `plans/kits/TEMPLATE.md`를 사용하며 빈칸이 남으면 구현하지 않는다.

## UI 기본값

- 상시 Shell HUD 없음
- Esc 메뉴는 호출 시에만 표시
- 장문 키설명 없음
- 장르 입력 프로필 전환은 Input Bubble로 학습
- `addons/at-icons`는 월드 아트 조립 재료, UI 아이콘이 아님

## 실행

Godot 4.7.2로 `project.godot`을 연다. 현재 프로젝트 설정은 과거 1152×720 기준이 남아 있으며, 새 문서 기준의 720p/FHD/QHD 지원은 후속 구현 작업이다.

## 라이선스 및 서드파티

- 게임 코드: 프로젝트 자체 코드(라이선스 미정)
- `addons/gut`: GUT 9.7.1 (MIT)
- `addons/at-icons`: 월드 아트 조립 재료
- `.opencode/skills/ponytail`: MIT
