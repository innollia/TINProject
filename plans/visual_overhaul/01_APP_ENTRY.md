# 배치 01 — AppRoot / 전역 UI / first_entry

## AppRoot와 전역 UI

1차 레퍼런스: There Is No Game: Wrong Dimension.

참조:
- 일반 앱 툴바처럼 보이는 UI를 최소화하는 방식
- 화면 자체가 상호작용 대상처럼 느껴지는 전환
- 메뉴가 게임 위에 얹힌 개발 패널처럼 보이지 않는 구성

개편:
- 상단 UI가 플레이 공간보다 먼저 보이는지 점검
- Save/Load/pause/reset/records/settings는 아이콘 금지, 텍스트 중심
- 항상 필요하지 않은 기능은 접거나 상황에 따라 표시
- 디버그 상태값/모듈 ID는 release 화면에서 제거
- records overlay는 generic admin panel이 아니라 기록/문서 화면처럼 구성
- settings의 useless clicker는 기묘한 물건/텍스트로 보이게 하되 UI icon 금지

기능 계약은 바꾸지 않는다.

## first_entry

1차 레퍼런스: There Is No Game: Wrong Dimension의 화면 침범/전환 연출.

검수 상태:
1. 키 흡수 전
2. 키 흡수 중
3. 블랙홀
4. 대각선 낙하
5. 외형 선택
6. 시작 모듈 배정 직전

아트:
- 외형 3종을 단순 폴리곤만으로 끝내지 않고 at-icons 조각 콜라주로 재작성
- 동일 identity가 이후 모듈에서도 재현될 수 있게 조립 규칙을 data로 유지
- 외형 선택은 icon button이 아니라 실제 캐릭터 프리뷰를 무대 위에 배치
- 텍스트 버튼은 허용, UI icon 금지

## 완료
AppRoot 기본 화면, records, settings, first_entry 6상태를 1152×720로 검수한다.
