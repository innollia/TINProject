# 지식 기반 게임 설계 기준

이 문서는 `Knowledge Based Game / MetroidBrainia`라는 말을 흐리지 않기 위한 용어 보조 문서다. 특정 Kit 계획이나 기존 콘텐츠를 정당화하는 문서가 아니다.

## 1. 정의

지식 기반 게임은 **플레이어가 규칙·구조·언어·사실·인과관계를 이해하는 것 자체가 진행 자원이 되는 게임**이다.

가능한 지식:
- 게임 규칙과 예외
- 언어/기호의 의미
- 사건의 사실관계
- 시간/공간의 작동
- 오브젝트의 숨은 affordance
- 시스템 간 인과
- 이전 장면을 다시 해석하게 하는 정보

“정답 문자열을 한 번 외움”과는 구분한다.

## 2. 설계할 때 묻는 질문

지식 기반 요소를 Kit에 넣으려면 계획서에 답한다.

1. 플레이어가 정확히 무엇을 알게 되는가?
2. 그 지식은 규칙/구조/인과에 대한 이해인가, 일회성 암호인가?
3. 알기 전과 후에 가능한 판단/행동이 어떻게 달라지는가?
4. 캐릭터 스탯/열쇠/hidden flag 없이도 지식이 진행 자원으로 작동하는가?
5. 다른 상황에서 재사용되는가?
6. UI가 연결을 대신 해버리지 않는가?

## 3. 강한 지식 게이트

필요하면 다음 패턴을 사용한다.

- 행동은 처음부터 가능하지만 방법을 모름
- 배운 뒤 fresh state에서도 수행 가능
- 새 지식이 과거 장면의 의미를 바꿈
- 한 장소의 규칙이 다른 맥락에서 재사용됨
- hidden unlock 없이 이해만으로 순서를 건너뜀

이 패턴을 표방하면:
- fresh-state solve
- no-secret-flag
- cross-context reuse
를 테스트한다.

## 4. 약한 구현

다음만으로 강한 지식 기반 게임이라고 부르지 않는다.

- 바로 옆 표찰의 순서를 복사
- 눈에 보이는 특징 하나로 3지선다
- 모든 단서를 누르면 UI가 정답을 조립
- 한 번 쓰고 버리는 암호
- 정답을 미리 알면 스킵 가능하다는 이유만으로 지식 기반이라고 주장

## 5. Kit와의 관계

지식 기반은 프로젝트 전체 공통 루프가 아니다.

필요한 Kit의 Primary Reference가 이런 문법을 핵심으로 가질 때만 해당 Kit 계획에 구체적으로 넣는다.

예:
- Golden Idol 계열 추리 Kit
- 언어 해독 Kit
- 시간루프/재맥락화 Kit

Kit마다 Primary Reference 하나라는 원칙은 그대로 유지한다. 이 문서의 여러 게임 이름을 Secondary Reference 묶음으로 가져가지 않는다.

## 6. 검증

필요한 항목만 선택:
- knowledge statement
- resource check
- recontextualization
- cross-context reuse
- fresh-state solve
- no-secret-flag
- spoiler audit
- wrong-order robustness

자동 테스트가 가능한 state/flag 계약과 사람이 실제로 이해하는 과정은 별도로 검수한다.
