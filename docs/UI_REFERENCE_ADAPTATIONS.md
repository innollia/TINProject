# UI 레퍼런스 사용 규칙

이 문서는 사용자가 제공한 UI 연구 보고서의 사례를 TINProject에서 **어떻게 오용하지 않을지** 정한다.

## 1. Primary Reference가 우선

각 Kit에는 Primary Reference 하나만 둔다.

보고서에 등장하는 Dead Space, Destiny, Persona 5, Metaphor: ReFantazio 등은 UI 사고법을 이해하는 연구 사례다. Kit 계획에서 이들을 자동으로 보조 레퍼런스로 섞지 않는다.

예:
- Rule Rewrite Kit의 Primary Reference가 Baba Is You라면 화면 구조/보드/피드백의 구체 기준은 Baba Is You다.
- “Persona식 선 + Metaphor식 모션 + Destiny식 상세”을 계획자가 임의로 덧붙이지 않는다.

사용자가 특정 확장점에 Secondary Reference를 명시적으로 허용한 경우만 예외다.

## 2. 보고서에서 프로젝트 전체에 가져오는 것

### 정보 우선순위
첫 화면에는 지금 판단에 필요한 것만 둔다. 상세 정보는 문맥 또는 요청 시 공개한다.

### 상태와 표현 분리
domain state가 진실이고 UI는 표현과 intent를 담당한다.

### focus
선택 대상이 항상 읽혀야 한다. hover-only 정보는 만들지 않는다.

### 반응형
Control/Container/anchor를 사용하고 실제 target resolution에서 검수한다.

### AI 규칙 고정
반복 실패는 채팅에서 한 번 고치는 것으로 끝내지 않고 AGENTS/UI_WORKFLOW/Kit 계획의 금지 규칙으로 승격한다.

### 자동 + 수동 QA
상태/입력 계약은 자동 테스트하고, 정보 계층/가독성/조작 경험은 실제 실행으로 검수한다.

## 3. 보고서에서 자동 채택하지 않는 것

다음은 필요성이 생길 때만 채택한다.

- 전역 UIRouter
- TooltipService
- ModalService
- UISettings
- ItemSlot/ResourceBar/StatusChip 등 특정 컴포넌트
- GdUnit4
- 예시 breakpoint 수치
- 예시 animation ms
- 장르별 공통 HUD

Kit의 실제 두 사용처가 확인되지 않은 shared 추상화는 만들지 않는다.

## 4. TIN 고유 적용

### Shell
플레이 중 보이지 않는다. Esc 등 호출할 때만 나타난다.

### Input
키바인드 안내는 상시 InputGlyph가 아니라 장르 전환의 Input Bubble이 기본이다.

### Art
UI 아이콘은 사용하지 않는다. at-icons는 월드 아트 조립 재료다.

### Resolution
1280×720 / 1920×1080 / 2560×1440을 실제 검수한다.

## 5. 계획서 체크

UI 계획이 다음처럼 쓰였다면 미완성이다.

- “깔끔한 UI”
- “Persona 느낌”
- “선택이 잘 보이게”
- “반응형으로”
- “적절한 피드백”

대신 실제 Primary Reference 상태와 TIN 상태를 1:1로 연결한다.

```text
Reference state
→ 화면 구조
→ 정보 노출
→ focus
→ input
→ result feedback
→ TIN adaptation
→ acceptance capture
```

이 문서는 구체 게임 화면을 대신 설계하지 않는다.
