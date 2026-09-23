# TINProject — Visual Direction

이 문서는 TINProject의 시각 구현 규칙 단일 출처다.

- 사용자 확정: PROJECT_DECISIONS.md
- 설계 철학: docs/DESIGN_PHILOSOPHY.md
- 작업 절차: AGENTS.md
- 기존 화면 개편: plans/visual_overhaul/
- 개별 신규 게임 계획: plans/game_modules/

## 1. 목표

TIN의 화면은 기능 데모가 아니라 게임 화면이어야 한다.

완료로 인정하지 않는 형태:
- 네모 몇 개와 Label로 장소를 대신함
- 버튼/패널 나열로 플레이를 대신함
- "HOUSE", "NPC", "EVIDENCE" 같은 개발용 텍스트가 월드 오브젝트 역할을 함
- 테스트가 통과했다는 이유로 placeholder 화면을 완료 처리
- 상용 레퍼런스 이름만 문서에 적고 실제 화면은 보지 않음

## 2. 상용 게임 레퍼런스 규칙

각 주요 화면은 최소 1개의 1차 상용 레퍼런스를 가진다. 구현 전 실제 이미지를 확인한다.

레퍼런스에서 최소 다음을 추출한다.
1. 화면에서 가장 먼저 보이는 것
2. 플레이 공간과 UI의 우선순위
3. 상호작용 대상이 읽히는 방법
4. 입력 후 피드백 위치와 방식

주요 참고축:
- There Is No Game: Wrong Dimension — 화면/인터페이스 경계를 가지고 노는 연출
- Baba Is You — 보드 가독성과 월드 안의 텍스트 규칙
- The Case of the Golden Idol — 조사 장면, 문서, 어휘/추론 UI
- Mosa Lina — 전 화면 플레이 공간과 실루엣 중심 물리 상호작용
- In Stars and Time — 반복 공간, 대화, 작은 변화의 강조
- West of Loathing — 단순 선/형태로 만드는 장소와 캐릭터 개성
- Chants of Sennaar — 기호와 공간을 함께 읽게 하는 환경 표현
- Papers, Please — 서류/검사/부스형 상호작용의 정보 계층
- Strange Horticulture — 오브젝트 조사와 책상형 공간 밀도
- The Witness — 설명 없는 시각 비교와 환경 관찰
- World of Horror — 제한된 팔레트의 고밀도 기괴한 화면

원작의 자산, 고유 캐릭터, 문구, 레벨 배치를 복제하지 않는다.

UI 구조의 유사성 자체는 회피 대상이 아니다. [UI 레퍼런스 적용 지도](UI_REFERENCE_ADAPTATIONS.md)의 Dead Space·Destiny·Persona 5·Metaphor 분석을 각 게임의 1차 레퍼런스와 함께 사용한다. 예를 들어 동일한 목록→선택 상세→전문 구조를 가져오되 색상·장식은 TIN으로 바꾼다. 실제 화면 검수에서는 겉모양뿐 아니라 같은 과제의 선택 횟수, 정보가 열리는 위치, 취소 복귀점, 모션 강도 순서를 나란히 비교한다.

## 3. 1152×720 기준

모든 주요 화면은 1152×720를 기준으로 설계·검수한다.

각 화면 계획에는 다음이 있어야 한다.
- 1차 초점
- 배경/중경/전경
- 플레이 공간
- 항상 보이는 UI
- 필요할 때만 열리는 UI
- 입력 전 상태
- focus/hover/선택 상태
- 입력 후 상태
- 실패/성공/전환 상태

"알아서 보기 좋게 배치"는 계획으로 인정하지 않는다.

## 4. UI

UI에는 아이콘을 쓰지 않는다.

금지:
- at-icons 또는 다른 아이콘 세트의 버튼 아이콘
- gear/save/back/arrow/map/bag 등의 픽토그램
- 아이콘만 있는 탭
- 상태를 작은 glyph badge로만 표시
- 개발 툴바처럼 기능을 일렬 배치

사용:
- 짧은 텍스트
- 타이포그래피 크기/굵기
- 선, 여백, 패널
- 선택 상태의 배경/테두리
- 위치 이동과 짧은 애니메이션

UI는 기본적으로 월드보다 먼저 눈에 들어오지 않는다. deduction/document처럼 UI 자체가 플레이 공간인 장르는 예외다.

## 5. at-icons

에셋 경로: res://addons/at-icons/

이 폴더는 아이콘 라이브러리가 아니라 형태 조각 라이브러리처럼 취급한다.

허용:
- 서로 다른 원본 조각을 한 캐릭터/건물/가구/기계로 조립
- unrelated glyph를 지붕/창/팔/머리카락/식물/기계부품으로 전용
- 회전, 비균일 스케일, 미러, crop, 겹치기, 부분 가리기, 색 변형
- 2D collage scene, 3D Sprite3D/평면 cutout

금지:
- house glyph를 그대로 house로 사용
- person glyph를 그대로 NPC로 사용
- magnifier glyph를 조사 마커로 사용
- gear/save/arrow glyph를 UI 기능에 사용
- 원본 한 장을 크게 키운 뒤 완성 아트로 취급

조립 기준:
- 주요 캐릭터/건물/초점 오브젝트는 원칙적으로 2종 이상의 원본 조각
- 작은 소품은 단일 원본도 가능하지만 원래 픽토그램 의미가 먼저 읽히지 않게 변형
- 원본 에셋은 보존하고 module-local scene에서 조합
- 두 번째 실제 재사용 사례 전에는 범용 collage composer를 만들지 않음

## 6. 텍스트

텍스트가 화면을 지배할 수 있는 경우:
- 대화, 문서, 추리 슬롯
- 규칙 재작성 게임의 word object
- 방송/표지/편지처럼 세계 속 텍스트

금지:
- 그림 대신 사물명을 적어둠
- 시각 피드백 대신 "성공", "실패"만 표시
- 플레이 방법을 장문 overlay로 설명

## 7. 화면 브리프 템플릿

UI의 행동·상태·검수 계약은 [UI_WORKFLOW.md](UI_WORKFLOW.md)를 함께 사용한다. 아래 화면 브리프와 연결해 정보의 항상/문맥/요청 노출 조건, initial/return focus, 입력 차단, 긴 문자열·확대·모션 감소 상태를 명시한다.

- Reference: 게임명 + 실제 화면 종류
- Player sees: 첫 프레임
- Focal point: 1차 초점
- World art: 실제 월드 오브젝트
- at-icons recipe: 조립 방식
- UI: 항상 보이는 텍스트/패널
- Interaction states: idle → focus → action → result
- Transition: 진입/이탈
- Acceptance: 1152×720 검수 스크린샷

## 8. 완료 판정

- 주요 상태 스크린샷 확보
- 레퍼런스와 나란히 비교
- 플레이 초점이 분명함
- placeholder 월드 오브젝트 없음
- UI icon 없음
- at-icons를 원래 의미 그대로 쓴 사례 없음
- 입력 후 피드백이 화면에서 읽힘
- 기존 기능/저장/입력 테스트 회귀 없음

- UI_WORKFLOW의 화면별 입력/접근성/반응형 매트릭스와 증거 행 작성
- 모달 종료·대상 삭제·실패 복구 뒤 유효 포커스와 하위 입력 소유권 확인
- 색 이외의 상태 전달, 확대/긴 문자열, 모션 감소 시 기능 피드백 검수

1152×720는 필수 기준이며 다른 지원 창 크기와 배율 검수를 대체하지 않는다. 지원 범위·옵션이 아직 미정/미구현이면 그 상태를 기록하고 화면 완료와 구분한다.
