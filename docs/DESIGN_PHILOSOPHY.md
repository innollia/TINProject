# TINProject — Design Philosophy

공통 용어는 `CONTEXT.md`, 구체 작업 절차는 `docs/KIT_WORKFLOW.md`가 소유한다.

## 1. 하나의 게임, 여러 장르

TINProject는 여러 게임을 모아놓은 런처가 아니다.

**한 게임이 플레이 도중 다른 장르의 문법으로 바뀔 수 있어야 한다.**

장르 전환이 생길 때마다 시스템을 처음부터 발명하면 개발이 멈춘다. 그래서 장르별 Kit를 미리 충분히 구현한다.

Kit의 존재 이유는 “모듈 수”가 아니라 **미래의 장르 전환 비용을 낮추는 것**이다.

## 2. Kit는 장르 시스템이다

Kit는 장르의 핵심 문법을 가진다.

예:
- 규칙 재작성 퍼즐이라면 parser, grid, movement, rule evaluation, undo, level data
- FPS라면 movement, aim, weapon, hit, enemy, encounter, checkpoint
- 추리라면 observation, evidence, vocabulary/inference, validation, revisit
- 어드벤처라면 location, interaction, NPC, inventory, event, route, revisit

“버튼 몇 개 + 상태 변수 몇 개”는 Kit가 아니다.

## 3. 먼저 짝퉁을 제대로 만든다

AI에게 처음부터 독창적인 장르 해석을 맡기지 않는다.

Kit마다 Primary Reference 하나를 정하고 실제 화면과 플레이를 조사한 뒤:
1. 핵심 시스템을 분해한다.
2. UX와 정보 노출을 분해한다.
3. 그 구조를 가능한 한 충실히 구현한다.
4. 고유 자산/문구/레벨/캐릭터만 독자적으로 바꾼다.
5. 이후 실제 TIN 콘텐츠에서 사용자 취향대로 변형한다.

“영감을 받음”은 구현 계약이 아니다.

## 4. 계획서는 실행 프로그램에 가깝게 쓴다

Vibe coding에서 긴 실행을 안정적으로 만드는 것은 막연한 미감이 아니라 **고정된 계획과 완료 조건**이다.

계획서는 에이전트가 수십 시간 독립 실행해도 방향을 잃지 않도록 작성한다.

계획 안에서:
- 무엇을 조사할지
- 무엇을 만들지
- 무엇을 보존/버릴지
- 어떤 상태가 존재하는지
- 어떤 데이터가 콘텐츠인지
- 실패 시 어떻게 복구하는지
- 어떤 화면을 어떤 해상도에서 볼지
- 무엇이 완료를 막는지
를 결정한다.

## 5. 시스템 위에 콘텐츠를 얹는다

구현 순서는:

```text
Primary Reference 조사
→ 장르 시스템 정의
→ domain/state/data
→ presentation/input/save
→ 최소 authored content
→ 여러 authored content 추가
→ 10분+ Reference Game
→ 사용자 플레이 검토
→ 실제 TIN 콘텐츠로 변형
```

Reference Game의 목적은 **콘텐츠를 추가해도 core가 깨지지 않는지 증명**하는 것이다.

전용 에디터는 필요 없다. 에이전트가 데이터/Resource/scene을 추가할 수 있으면 된다.

## 6. 플레이 화면이 최종 증거다

테스트는 중요하지만 화면을 대신하지 않는다.

- parser test 통과 ≠ 퍼즐 화면 완성
- save round-trip ≠ 어드벤처 게임 완성
- 버튼이 눌림 ≠ 추리 UI 완성

플레이어가 실제로:
- 무엇을 보고
- 무엇을 조작하고
- 무엇이 선택되었는지 알고
- 입력 결과를 이해하고
- 실패에서 회복하고
- 다음 authored content로 진행
할 수 있어야 한다.

## 7. UI는 없을수록 좋다

기본값은 **표시하지 않는 것**이다.

항상 보여야 할 이유가 Primary Reference와 게임 상태에서 증명되지 않으면 HUD를 만들지 않는다.

Shell은 기술적 기반이지 화면 장식이 아니다. Esc 등으로 호출되기 전에는 보이지 않는다.

키바인드 학습도 장문 텍스트 대신 Input Bubble 같은 실제 상호작용으로 처리한다.

## 8. Reference 화면을 실제로 본다

작품명만 적고 기억으로 구현하지 않는다.

각 주요 상태에서 실제 화면을 확인한다:
- 첫 장면
- 평상시
- 선택/focus
- 핵심 시스템 변화
- 실패
- 성공
- 전환

레퍼런스에서 가져올 것은 모양만이 아니다.

- 화면의 주인공
- 플레이 공간과 UI의 비율
- 좌표/격자/카메라
- 정보 우선순위
- 상태 피드백
- 입력 흐름
- 되돌리기
- 콘텐츠 밀도

## 9. at-icons는 월드의 공통 재료다

모든 Kit Reference Game에서 `res://addons/at-icons/`를 월드 아트 재료로 사용한다.

아이콘 하나를 그대로 “집/사람/돋보기”로 쓰지 않는다. 여러 조각을 재조립해 원래 pictogram 의미를 지운다.

UI 아이콘으로는 사용하지 않는다.

이 공통 재료를 쓰더라도 장르마다 Primary Reference의 실루엣, 밀도, 카메라, 정보 구조는 달라야 한다.

## 10. 공통화는 장르 자유를 해치지 않게 한다

두 번째 실제 사용처 전에는 shared를 만들지 않는다.

공통화의 목적은 중복 제거이지 서로 다른 장르를 한 UI/한 Player/한 Inventory로 억지 통일하는 것이 아니다.

AppRoot/ModuleDirector/ModuleContext 같은 기존 런타임 계약은 유지하되 Kit의 장르별 시스템은 module-local을 우선한다.

## 11. 수량을 성과로 세지 않는다

Kit 수, 모듈 수, 사이클당 신규 개수는 품질 지표가 아니다.

한 Kit가 오래 걸려도:
- 시스템이 깊고
- authored content를 쉽게 추가할 수 있고
- 10분+ Reference Game이 실제로 게임처럼 플레이된다면
그게 올바른 진행이다.

## 12. 기존 구현은 자동으로 유산이 아니다

현재 whitelist:
- first_entry의 시작/입력 학습 로직
- rule_rewriting의 시스템 기반
- odd_road_adventure의 시스템 기반
- game_library의 개발/탐색용 UI

나머지 기존 플레이 모듈은 Retired Prototype이다.

과거에 만들었다는 이유로 아이디어·대사·구조를 새 Kit에 끌고 오지 않는다.

## 13. 완료는 사용자 검토 직전까지

에이전트의 마지막 완료 단계는 **사용자가 직접 플레이해 검토할 수 있는 상태**다.

그 뒤의 취향 조정과 실제 TIN 콘텐츠화는 사용자 피드백을 받아 진행한다.
