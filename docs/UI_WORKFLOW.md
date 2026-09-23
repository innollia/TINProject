# TIN UI 작업 계약

이 문서는 사용자가 제공한 「고도엔진 기반 바이브코딩 게임 UI 심층 연구 보고서」를 TINProject에 적용하는 실행 규칙이다.

구체 장르 화면의 최우선 기준은 각 Kit의 **Primary Reference 하나**다. 이 문서는 그 레퍼런스를 제대로 구현하고 검수하기 위한 공통 UI 계약을 제공한다.

## 1. 기본 원칙

UI를 마지막 장식이나 버튼 배치로 취급하지 않는다.

화면은 다음 계약으로 본다.

```text
게임 상태
→ 플레이어에게 지금 필요한 정보
→ 표시 상태
→ focus/선택
→ 사용자 입력
→ intent
→ domain 변화
→ 피드백
```

표현 노드가 게임 상태의 진실을 소유하지 않는다.

## 2. 정보는 필요한 만큼만

기본값은 숨김이다.

항상 보이는 정보는:
- 즉시 판단에 지속적으로 필요하고
- Primary Reference에서도 같은 수준으로 지속 노출되며
- 월드 자체로 충분히 읽히지 않는 경우
에만 허용한다.

금지:
- 현재 공간명 상시 표시
- 자동 저장 상시 표시
- 키바인드 상시 표시
- Menu/Journal 상시 버튼
- 개발용 상태 라벨
- “여기서 Z를 누르세요” 식 장문 설명

Shell은 호출 전까지 보이지 않는다.

## 3. Primary Reference 우선

계획에는 화면별로 다음을 기록한다.

| 항목 | 내용 |
|---|---|
| Reference state | 실제 원작의 어떤 화면/상태인지 |
| Focal point | 처음 눈에 들어오는 것 |
| World/UI ratio | 플레이 공간과 UI의 비율 |
| Persistent info | 항상 보이는 것 |
| Contextual info | 상호작용할 때만 보이는 것 |
| Focus/selection | 무엇을 고르고 있는지 읽히는 방식 |
| Result feedback | 입력 뒤 어디가 어떻게 바뀌는지 |
| Back/restore | 취소하면 어디로 돌아오는지 |
| TIN adaptation | 고유 자산을 복제하지 않고 무엇을 바꾸는지 |

여러 게임의 UI를 섞지 않는다. 보고서의 Dead Space/Destiny/Persona/Metaphor 사례는 일반 원리를 이해하는 자료이지 Kit마다 자동으로 혼합하는 보조 레퍼런스가 아니다.

## 4. Focus는 첫 클래스 상태

선택 가능한 화면은 항상:
- 현재 focus가 무엇인지 보인다.
- 마우스 hover 없이도 같은 정보에 접근 가능하다.
- 키보드/패드 탐색 순서가 논리적이다.
- 화면을 닫았다 열 때 복귀 지점을 정의한다.
- 선택 대상이 삭제/비활성되면 안전한 다음 focus를 정한다.

“색이 조금 달라짐”만으로 focus를 전달하지 않는다.

## 5. 상태별 화면 계약

각 interactive screen은 최소 다음 상태를 가진다.

- initial
- normal
- focus
- selected/active
- disabled/unavailable
- error/failure
- success/result
- closing/return

필요한 장르에서:
- empty
- loading
- maximum data
- long text
- save restored
- reset
를 추가한다.

## 6. 입력

물리 키를 domain에 하드코딩하지 않는다. InputMap action과 ModuleContext를 사용한다.

새 장르로 넘어가며 물리 키 집합이 달라지면 `docs/KIT_WORKFLOW.md`의 **Input Bubble**을 사용한다.

Input Bubble은 일반적인 화면 하단 `[Z] 확인` glyph 시스템이 아니다. 전환 자체에서 뽁뽁이를 눌러 키를 익히게 하는 별도 인터랙션이다.

게임 화면에서는 키 설명문을 기본값으로 두지 않는다.

## 7. Layout / 해상도

필수 검수:
- 1280×720
- 1920×1080
- 2560×1440

Control UI:
- 큰 화면 경계는 anchor
- 내부 정렬/간격은 Container 우선
- Container child의 위치를 수동 좌표와 경쟁시키지 않음
- breakpoint는 실제 레이아웃 의미가 바뀔 때만 사용

월드:
- grid/보드/물리 공간처럼 게임 규칙상 좌표가 중요한 것은 직접 layout 계산 가능
- UI 반응형과 월드 좌표를 섞지 않음

세 해상도에서 같은 핵심 플레이가 가능해야 한다.

## 8. 공통 컴포넌트

Primitive → Component → Pattern → Screen은 **책임을 나누는 사고 도구**다. 미리 전역 UI 프레임워크를 만들라는 뜻이 아니다.

두 실제 사용처에서 의미와 계약이 같을 때만 작은 공통 단위를 추출한다.

금지:
- 사용처 없는 GameButton/TooltipService/UIRouter를 선제 구현
- 하나의 RPG UI 규칙을 모든 장르에 강제
- Primary Reference보다 공통 Theme를 우선

## 9. UI 아이콘

UI에는 at-icons를 포함한 아이콘을 기본적으로 사용하지 않는다.

선택/상태/경고는:
- 텍스트
- 타이포그래피
- 여백
- 선
- 형태
- 위치
- 짧은 모션
으로 해결한다.

at-icons는 월드 아트 재료다.

## 10. 모션

모션은 사건의 의미를 강화해야 한다.

- 반복 focus: 짧고 즉각적
- 선택 확정: focus보다 강함
- 핵심 규칙/세계 변화: 원인→결과가 이어져 보임
- 실패: 원인을 가리지 않음
- 장식 때문에 다음 입력을 기다리게 하지 않음

정확한 ms를 공통 규칙으로 고정하지 않는다. Primary Reference와 실제 반복 조작으로 튜닝한다.

Reduced Motion을 구현하는 Kit에서는 기능적 차이가 사라지지 않게 한다.

## 11. 자동 테스트

자동화하기 좋은 것:
- state → visible state
- selected item → detail content
- disabled → intent 차단
- menu open → initial focus
- cancel → previous focus
- save/load → 같은 표시
- deleted target → focus fallback
- rebind → duplicate signal 없음

픽셀 미감 자체를 unit test로 증명하려 하지 않는다.

## 12. 수동 검수

“예쁜가?” 대신 과제를 수행한다.

예:
- 현재 선택을 찾아라.
- 잘못된 행동을 한 뒤 원래 상태로 돌아와라.
- 특정 정보를 열어 확인하고 다시 게임으로 돌아와라.
- 같은 장면을 720p/FHD/QHD에서 플레이해라.

기록:
- 성공/실패
- 첫 유효 행동까지 시간
- 오조작
- backtracking
- 설명 필요 여부
- 무엇을 찾으려 했는지

## 13. 완료 실패 조건

다음이 하나라도 남으면 화면 완료가 아니다.

- 무엇을 선택했는지 모름
- 버튼 뭉탱이가 월드 플레이를 대체
- 설명문이 조작을 대신
- 상시 shell HUD
- placeholder ColorRect/Label 월드
- Primary Reference 실제 화면 비교 없음
- 720p/FHD/QHD 미검수
- 긴 문자열/최대 데이터에서 겹침
- focus 복귀가 깨짐
- 테스트 통과만으로 완료 선언

## 14. 보고서 적용 경계

사용자 제공 보고서의 핵심을 채택한다:
- 정보 우선순위와 상호작용 규칙
- 상태/표현 분리
- persistent project rules
- focus
- responsive layout
- 자동 + 수동 QA
- AI 반복 실패를 규칙으로 승격

보고서 속 특정 컴포넌트 이름, 서비스 목록, 예시 수치, 제3자 테스트 도구는 자동 구현 승인 목록이 아니다.
