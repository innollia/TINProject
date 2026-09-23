# ADR 0002: 한 게임 내부 장르 전환을 위한 Kit 선제 구축

- 상태: 채택
- 날짜: 2026-09-23

## 배경

TINProject의 목적이 여러 독립 게임이나 미니게임을 많이 만드는 것으로 해석되면서, 작은 상태 머신과 임시 UI가 각각 “게임 모듈”로 완료 처리되는 문제가 생겼다.

이 방식은 모듈 수는 늘리지만 실제 목표인 **한 게임 안에서 장르를 자유롭게 바꾸는 개발**에는 도움이 되지 않았다.

## 결정

TINProject는 **하나의 게임**이며 플레이 도중 장르가 바뀔 수 있다.

장르 전환을 빠르게 구현하기 위해 각 장르의 핵심 시스템을 **Kit**로 미리 구축한다. 각 Kit는 하나의 Primary Reference를 강하게 따라가는 10분 이상의 Reference Game으로 검증한다.

Reference Game은 시스템과 UX를 가능한 한 충실히 재현하되 원작의 고유 자산·문구·레벨 배치·캐릭터는 복제하지 않는다. 이후 실제 TIN 콘텐츠를 만들 때 이 검증된 기반을 사용자 취향에 맞게 수정한다.

GameModule은 계속 런타임 교체 단위로 남으며 Kit와 동의어가 아니다.

## 현재 whitelist

새 방향에서 재검토 가능한 기존 구현은:

- `first_entry` — 시작/입력 학습 로직
- `rule_rewriting` — 규칙 parser/evaluator/movement/undo/save 기반
- `odd_road_adventure` — location/inventory/NPC/event/save 기반
- `game_library` — Nintendo OS 계열 레퍼런스를 따라 만든 개발/탐색용 목록 UI

whitelist는 현재 presentation이나 콘텐츠를 완성품으로 승인한다는 뜻이 아니다.

그 외 기존 플레이 모듈은 Retired Prototype이다.

## 결과

- 모듈/작품 개수 목표를 개발 목표로 사용하지 않는다.
- 새 Kit는 계획서가 완성되기 전에 구현하지 않는다.
- 기존 AppRoot + ModuleDirector + ModuleContext 경계를 유지한다.
- Retired Prototype의 아이디어·대사·UI를 새 설계 기반으로 사용하지 않는다.
- 자동 테스트 통과는 Kit 완료가 아니다.
- 사용자 플레이 검토가 가능한 Reference Game이 필요하다.
- UI는 최소화하고 Shell은 호출 전까지 보이지 않는다.
- 장르 전환 입력 학습은 Input Bubble 계약을 사용한다.
- 기존 옛 계획 파일은 active 문서에서 제거하고 Git 이력에만 남긴다.
