# ADR 0001: 영속 AppRoot와 교체 가능한 GameModule

- 상태: 채택
- 대상: `app/app_root.tscn`

## 배경

한 게임 안에서 장르가 바뀌더라도 저장·설정·입력 전환 같은 앱 수명은 유지되어야 한다. 동시에 각 장르 구현이 다른 장르의 구체 코드를 직접 알아서는 안 된다.

## 결정

AppRoot, Core 서비스, MetaLayer, UIHost, DebugRoot를 유지하고 ModuleHost의 현재 GameModule만 교체한다.

설치 목록은 앱의 manifest 카탈로그에서 구성한다. core는 구체 모듈 경로를 참조하지 않으며 GameModule은 주입된 ModuleContext와 좁은 계약만 사용한다.

명시적 승인 없는 범용 EventBus/서비스 로케이터/추가 autoload는 도입하지 않는다.

## 시각적 Shell

영속 AppRoot는 **상시 HUD를 뜻하지 않는다**.

플레이 중 Shell은 시각적 존재감이 0이어야 한다. 메뉴/설정 등은 Esc처럼 사용자가 호출했을 때만 나타난다.

과거의 “상단 고정 전역 UI 영역” 해석은 폐기한다.

## 결과와 비용

- module 전환 중에도 저장/설정/전환 서비스 수명을 유지할 수 있다.
- 모듈은 process/input 차단 계약을 지켜야 한다.
- 저장 상태는 버전 있는 JSON-safe 봉투이며 각 GameModule이 의미와 이관을 책임진다.
- Shell 화면 복귀/focus를 별도로 검증해야 한다.
- 이 결정은 Kit 설계와 별개다. Kit는 장르 시스템 개발 단위이며 GameModule과 동의어가 아니다.

장르 Kit 방향은 `0002-in-game-genre-kits.md`를 따른다.
