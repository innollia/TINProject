# TINProject — Visual Direction

## 1. 목표

화면은 기능 데모가 아니라 **Primary Reference를 실제로 플레이 가능한 수준으로 재현한 Reference Game**이어야 한다.

사용자가 제공한 두 이미지는 게임 전체의 아트 스타일 참고다. [A·B 이미지와 적용 범위](research/visual_reference/STYLE_AND_CAMERA_REFERENCE.md)를 공통 세계 아트의 붓질·질감·실루엣 비교에 사용한다. 이 자료는 Kit별 Primary Reference의 화면·조작 기준과 구분한다. 과거 at-icons 기반 제작 자료는 `archive/icon_based_image_assets/`에 보관한다. 현행 기반은 [GPT 이미지 게임 아트 제작 보고서](research/visual_reference/GPT_IMAGE_GAME_ART_PIPELINE_REPORT.md)를 반영한 개인 화풍 코어 + 프로젝트 아트 층이다.

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

## 4. 이미지 자산 기반 전환

과거 at-icons 기반 제작 문서와 실험은 `archive/icon_based_image_assets/`에 보관한다. 이미 만든 이미지 파일은 현재 위치와 내용 그대로 둔다. 아카이브의 조립 방식과 도구는 새 이미지 제작에 사용하지 않는다. 단, 2026-09-26 사용자 결정으로 04 Top-down Action-RPG Kit에서는 코드로 그린 그림을 허용하며 코드를 짜서 아이콘을 조합해도 된다(`IMAGE_ASSET_WORKFLOW.md` §1).

새 기반은 여러 게임에 재사용할 `개인 화풍 코어`와 게임별 `프로젝트 아트 층`으로 나눈다. 코어는 구조선, 명암 면, 색 관계, 재질별 붓질, 자산 크기별 번역을 소유한다. 프로젝트 층은 세계관, 캐릭터·의상, 구체 모티프, UI 형태, Primary Reference의 실루엣·배치·밀도·카메라를 소유한다.

2026-09-26 최신 사용자 결정으로 B를 생성 입력에서 완전히 제외한다. A 원본 또는 배경을 분리한 A 캐릭터만 Style Reference로 사용한다. 실제 A의 선·채색·피부와 천의 방향 있는 붓결·머리 명암 덩어리를 우선하며, 이전의 A/B 역할 분담은 과거 기록이다. A의 인물 정체성, 헤어스타일, 모티프, 의상과 정확한 팔레트는 복제하지 않는다. A를 임의의 정량 명암 단계나 새 머리 비율로 바꿔 설명하지 않는다.

구조선은 주변색보다 매우 어두운 유색선을 기본으로 한다. 얼굴은 안면 능선을 기준으로 기본색/주 그림자/작은 밝은 면의 3단 명암을 두고 각 면 안에서 붓질을 허용한다. 질감의 불균질함은 유지하되 붓질 모양은 재질마다 다르게 정의한다.

스프라이트는 일러스트의 번역판이다. 비율과 색 관계를 유지하되 구조선 수를 줄이고 명암을 2단으로 줄이며 내부 붓질 흔적은 극소량만 둔다. UI의 붓질은 테두리 마모가 아니라 넓은 정보면의 `내부 브러시 채움`으로 사용한다. 작은 아이콘과 글자에는 기본 적용하지 않는다.

배경 제작 brief는 오브젝트를 `증거·직접 상호작용`, `길찾기·상황 이해`, `분위기`로 나눈다. 앞 단계일수록 구조선과 형태 분리를 강하게 줄 수 있다. 중요도는 프로젝트 아트 층 또는 해당 장면 brief가 명시하며 모델이 추론해 승격하지 않는다.

형태의 비정상성은 자동 적용 규칙이 아니다. 해당 프로젝트가 명시적으로 요구할 때만 프로젝트 아트 층에 둔다.

Spine은 사용하지 않는다. 2D 리깅용 원본은 관절 파츠와 메시 변형 부위를 함께 제공하고, 가려진 부분의 overdraw margin을 포함한다. 사람의 재작화는 기본 공정이 아니다. 투명화/배경 분리, 크롭, 캔버스·피벗 정렬, 레이어 분리, 리사이즈, 아틀라스 패킹, 색 프로파일 변환, 결정론적 알파 매트·가장자리 정리만 기계적 후처리로 허용한다. 정체성과 구도가 맞는 실패는 사용자 요청 뒤 GPT 국소 편집으로, 전체 문법이 틀린 실패는 사용자 요청 뒤 재생성으로 처리한다.

규칙 충돌은 `최신 사용자 결정 → 프로젝트 아트 층 → 개인 화풍 코어 → 활성 A Style Reference → 해당 자산군 Gold Standard` 순으로 해소한다. Gold Standard는 환경/배경, 게임플레이 스프라이트, UI, 리깅용 전신 파츠, 비주얼노벨 전신·초상, 조사 화면으로 나누고 필요한 묶음만 활성화한다.

이전 at-icons 조립 절차는 `archive/icon_based_image_assets/`에 보존한다. 생성 도구 사용은 허용되지만 문서 정리·계획·검토 요청만으로 이미지를 임의 생성하지 않는다.

파일 구조, 작업 입력, Gold Standard 승인, 생성 단위, 하드 게이트는 [IMAGE_ASSET_WORKFLOW.md](IMAGE_ASSET_WORKFLOW.md)를 따른다. 대화 기억이나 에이전트 판정만으로 후보를 Gold Standard에 올리지 않는다.

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
- 이미지 자산 출처와 새 기반의 기준을 충족함
- 720p/FHD/QHD 캡처
- 사용자 플레이 검토 준비

