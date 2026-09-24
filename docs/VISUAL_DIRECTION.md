# TINProject — Visual Direction

## 1. 목표

화면은 기능 데모가 아니라 **Primary Reference를 실제로 플레이 가능한 수준으로 재현한 Reference Game**이어야 한다.

사용자가 제공한 두 이미지는 게임 전체의 아트 스타일 참고다. [A·B 이미지와 적용 범위](research/visual_reference/STYLE_AND_CAMERA_REFERENCE.md)를 공통 세계 아트의 붓질·질감·실루엣 비교에 사용한다. 이 자료는 Kit별 Primary Reference의 화면·조작 기준과 구분하며, 월드 자산은 `at-icons` 조각의 변형·조합으로 제작한다.

완료로 인정하지 않는다:
- 네모 몇 개와 Label로 장소를 대신
- 버튼 목록으로 플레이를 대신
- ASCII/텍스트로 공간 좌표를 대체
- 개발용 텍스트가 사물 역할
- 상시 HUD가 월드보다 먼저 보임
- 작품명만 문서에 적고 실제 화면은 안 봄

## 2. Primary Reference는 하나

각 Kit는 실제 게임 하나를 Primary Reference로 둔다.

보고서의 사례를 인용하면 [UI_REFERENCE_SOURCES.md](UI_REFERENCE_SOURCES.md)의 원 URL을 그대로 기록하고, 실제 비교한 화면/캡처는 구분한다. Primary Reference와 Secondary Reference의 선택 규칙은 [UI_REFERENCE_ADAPTATIONS.md](UI_REFERENCE_ADAPTATIONS.md)를 따른다.

구현 전:
1. 실제 플레이 화면을 본다.
2. 첫 화면/평상시/focus/핵심 변화/실패/성공/전환을 확인한다.
3. 계획서에 출처와 따라갈 구조를 적는다.

여러 게임의 시각 언어를 한 화면에 섞지 않는다.

## 3. 따라갈 것

원작 자산을 복사하지 않으면서 다음은 강하게 따라간다.

- 카메라 거리
- play area 크기
- cell/오브젝트 비율
- 정보 밀도
- 선택 위치
- UI 노출 조건
- 실패/성공 피드백 위치
- 화면 전환 감각
- 장르가 읽히는 silhouette와 hierarchy

예: Baba형이라면 셀이 정각으로 읽혀야 한다. “대충 격자처럼 보임”이나 ASCII 문자 간격으로 대신하지 않는다.

## 4. at-icons — 모든 Kit의 월드 아트 재료

경로: `res://addons/at-icons/`

Reference Game의 월드 아트는 at-icons 조각을 사용한다.

허용:
- 여러 unrelated glyph 조합
- crop
- rotation
- mirror
- non-uniform scale
- overlap
- partial masking
- color transform
- 2D Sprite2D/TextureRect collage
- 3D Sprite3D/plane/cutout

금지:
- house icon = house
- person icon = NPC
- magnifier = 조사 마커
- 원본 하나를 그대로 크게 확대
- UI icon 사용

주요 캐릭터/건물/초점 object는 원칙적으로 2개 이상의 원본 조각을 사용한다.

이 공통 재료 때문에 모든 장르가 같은 화면처럼 보여서는 안 된다. Primary Reference의 실루엣·배치·밀도·카메라를 우선한다.

## 5. UI 최소주의

UI는 없을수록 좋다.

상시 표시가 허용되는 것은 플레이 중 계속 알아야 하는 정보뿐이다.

금지:
- 좌상단 공간명/상태/자동저장
- 우상단 Menu/Journal
- 조작법 문장
- 개발 toolbar
- debug label

Esc 메뉴는 호출 시에만 나타난다.

## 6. Input Bubble

키 학습은 설명문 대신 뽁뽁이 상호작용으로 처리한다.

- 움직이는 무늬 배경
- 물리 키마다 가상 grid cell
- 새 키: 아래에서 올라옴
- 다시 필요한 기존 키: 터진 상태에서 복구
- 다음 장르에 필요 없는 키: 터진 흔적 유지
- 실제 키를 누르면 터짐

Input Bubble은 튜토리얼 텍스트의 장식이 아니다. **그 자체가 입력 학습**이다.

## 7. 해상도

필수 화면:
- 1280×720
- 1920×1080
- 2560×1440

세 해상도에서:
- 주요 focal point 유지
- UI 겹침/잘림 없음
- 월드 오브젝트 구별 가능
- 정각 grid는 정각 유지
- 긴 텍스트가 플레이를 덮지 않음

## 8. 화면 브리프

각 주요 화면은 다음을 적는다.

- Primary Reference URL / 상태
- Player sees
- Focal point
- Camera / world bounds
- World art recipe
- Persistent UI
- Contextual UI
- Focus/selection
- Input before/after
- Failure
- Success
- Transition
- 720p/FHD/QHD acceptance

## 9. 완료 판정

- 실제 Primary Reference와 나란히 비교
- placeholder 월드 없음
- 버튼 목록이 월드를 대체하지 않음
- 상시 shell HUD 없음
- focus가 분명함
- 입력 결과가 화면에서 읽힘
- at-icons 원본 의미가 먼저 읽히지 않음
- 720p/FHD/QHD 캡처
- 사용자 플레이 검토 준비
