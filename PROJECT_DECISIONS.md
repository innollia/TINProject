# TINProject — 사용자 확정 결정

이 파일은 현재 유효한 사용자 확정값만 둔다. 과거 아이디어 덤프·대사·라우트·모듈 수 목표는 정본이 아니다.

이 파일의 항목은 **Settled decision**이다. 설계 인터뷰에서 새 정보나 명시적 충돌 없이 처음부터 다시 묻지 않는다. 현재 인터뷰의 범위·Rejected 항목·다음 frontier는 `docs/GRILLING_STATE.md`가 기록한다.

## 1. 프로젝트 목적

TINProject는 **한 게임 안에서 장르를 자유롭게 바꾸기 위한 프로젝트**다.

예를 들어 한 게임이 FPS로 진행되다가 2D 추리로 바뀌고, 다시 3D 퍼즐 세계로 넘어가고, 그 안에서 클리커 문법을 사용하는 식의 전환이 가능해야 한다.

목표는 여러 독립 미니게임을 많이 만드는 것이 아니다. 특정 툴/장르의 초기 선택에 전체 게임이 묶이지 않도록, 필요한 장르 시스템을 미리 준비한다.

## 2. Kit

장르 기반 구현의 계획 단위 이름은 **Kit**다.

Kit는:
- 특정 장르의 핵심 시스템을 미리 구현한다.
- 실제 TINProject의 한 구간에서 그 장르가 필요할 때 즉시 사용할 기반이다.
- 독립 상품이나 공개 프레임워크가 목적이 아니다.
- 기술적 GameModule과 같은 뜻이 아니다.

Kit 개수 목표는 없다.

## 3. Primary Reference

Kit마다 **Primary Reference 하나만** 둔다.

가능한 레퍼런스:
- 인기 itch.io 게임
- n시간 게임 개발 대회/게임잼 출품작
- 상용 또는 출시 인디게임
- 실제 화면과 플레이를 충분히 확인할 수 있는 완성 게임

여러 레퍼런스를 평균내거나 섞지 않는다.

에이전트는 기억으로 구현하지 않고 실제 화면/플레이 자료를 확인한다. 계획서에 상태별 레퍼런스와 무엇을 따라갈지 기록한다.

## 4. Reference Game

AI에게 독창적인 재해석을 기대하기보다, **먼저 Primary Reference의 시스템과 UX를 강하게 따라가는 짝퉁 Reference Game을 만든다.**

그 뒤 실제 TIN 콘텐츠를 만들 때 사용자 취향에 맞게 수정한다.

원작에서 복제하지 않는 것:
- 고유 자산
- 고유 문구
- 고유 캐릭터

단, **시스템 검증과 수치 측정을 위한 원작 레벨 배치 복사는 허용한다.** 복사한 배치는 authored content가 아니라 검증 입력으로 기록하고 Reference Game 완성 증거로 세지 않는다.

강하게 따라가는 것:
- 핵심 시스템
- 플레이 문법
- 입력 감각
- 화면 정보 구조
- 선택/focus
- 실패/성공 피드백
- 콘텐츠 추가 구조

## 5. 계획 우선

계획서는 가장 중요한 구현 입력이다.

계획서가 충분히 구체적이면 에이전트가 장시간 독립 실행할 수 있도록 작성한다.

구현 전에 반드시:
- 실제 Primary Reference 조사
- 시스템/UX 분해
- 상태/데이터 모델
- authored content 포맷
- 입력
- 저장/복구
- 화면 상태
- Kit별 톤앤매너와 이미지 생성·편집 명세(필요한 자산군, 입력 정본, 출력 규격, 시각 단서, 후처리, 검수)
- 10분+ 샘플
- 테스트
- 해상도 검수
- 금지 shortcut
- 완료 증거
를 계획에 확정한다.

계획에 빈칸이 있으면 구현하지 않는다.

시각 명세가 길면 `plans/kits/` 아래 별도 문서로 분리하고 Kit 계획에서 링크한다. Golden Idol의 `13A~13G`는 복잡한 추리 장면에 유용한 형식 사례이며 다른 Kit에 동일한 문서 수와 사건 내용을 강제하지 않는다. 구체 규칙은 `docs/KIT_WORKFLOW.md` 8절을 따른다.

## 6. 시스템과 콘텐츠

Kit는 **시스템 위에서 에이전트가 콘텐츠를 쉽게 추가할 수 있는 상태**까지 만든다.

전용 에디터 툴은 필요 없다. 에이전트가 Resource/데이터/scene을 추가하면 된다.

Reference Game은 최소 10분 이상 플레이 가능해야 하며, 여러 authored content가 같은 core system을 재사용해야 한다.

## 7. 현재 구현 whitelist

현재 코드를 새 방향의 기반 후보로 인정하는 것은 다음뿐이다.

- `modules/first_entry/`: 시작/입력 학습 로직
- `modules/rule_rewriting/`: 규칙 parser/evaluator/movement/undo/save 기반
- `modules/odd_road_adventure/`: location/inventory/NPC/event/save 기반
- `modules/game_library/`: Nintendo OS 계열 레퍼런스를 따라 만든 개발/탐색용 목록 UI. 게임 콘텐츠로 세지 않는다.

위 항목도 현재 화면을 완성품으로 인정한다는 뜻은 아니다.

그 외 기존 플레이 모듈은 **Retired Prototype**이다. 아이디어·대사·UI를 새 작업의 기반으로 사용하지 않는다. 코드 삭제는 별도 구현 작업에서 한다.

## 8. UI

**미니멀 UI를 기본값으로 한다.**

잘못된 기본값:
- 좌상단 상태 뭉치
- 우상단 Menu/Journal 버튼
- 자동 저장 상태 상시 노출
- 공간명/조작법 상시 HUD
- 화면 중앙 장문 설명
- 개발도구 같은 버튼 행

AppRoot/Shell은 기술적으로 살아 있어도 플레이 중 시각적 존재감은 0이어야 한다.

Esc 메뉴는 Esc를 눌렀을 때만 나타난다. 기록 같은 기능도 상시 버튼으로 광고하지 않는다.

## 9. Input Bubble

키바인드는 설명문 대신 **뽁뽁이 방울을 직접 눌러 터뜨리며 학습**한다.

배경:
- 움직이는 무늬
- 그 위에 가상의 격자
- 물리 키마다 고정된 셀

방울 상태:
- 온전함
- 터진 흔적
- 새 키가 아래에서 올라옴
- 다음 장르에서 다시 필요한 키가 복구됨

예:
- Game A: WASDZ
- Game B: WASDZX
- Game C: W

흐름:
- 시작창 A: WASDZ 방울이 올라와 자기 셀에 멈춤. 해당 키를 누르면 터짐.
- 중간창 AB: A에서 터진 WASDZ가 복구되는 동안 새 X 방울이 올라옴.
- 중간창 BC: W만 복구되고 ASDZX는 터진 흔적으로 남음.

새 장르 구간에서 새 키바인드가 필요할 때 같은 원리를 사용한다. 로딩/전환 화면에서 진행해도 된다.

## 10. 이미지 자산 기반 전환

2026-09-25 사용자 지시에 따라 at-icons 조립을 공통 이미지 자산 기반으로 삼던 결정을 종료했다. 관련 제작 문서와 실험 도구는 `archive/icon_based_image_assets/`에 보관한다. 이미 만들어진 이미지 파일은 원래 경로와 내용을 유지한다. 대체 기반은 GPT 이미지 제작을 전제로 한 **개인 화풍 코어 + 프로젝트 아트 층** 구조다. 같은 날 사용자가 기존 생성 이미지 절대 금지를 즉시 해제했다. 구체적인 이미지 자산 제작·편집 요청이 있을 때 생성 도구를 사용할 수 있다.

### 이미지 기반 grilling에서 확정된 방향

- 개인 화풍 코어는 여러 게임에서 재사용하고, 세계관·캐릭터·구체 UI 형태는 프로젝트 아트 층이 소유한다.
- A는 안면 중앙 구조선, 얼굴 명암 면 분할, 피부와 큰 색면의 거친 내부 붓결, 머리카락 덩어리 안의 회화적 밝기 변화를 참조한다.
- B는 선 굵기의 강약, 의상 구조선, 복잡한 실루엣 정리, 인물과 배경의 밀도 대비, 콜라주처럼 겹치는 배경 덩어리를 참조한다.
- A/B에서 얼굴형, 헤어스타일, 구체 모티프, 의상 디자인, 정확한 색 조합을 상속하지 않는다.
- A/B는 규칙 추출 뒤 폐기하지 않고 영구 Style Reference로 유지한다. 다만 위 권한 밖의 소재를 따라 하지 않는다.
- 얼굴에는 동일한 코선을 복제하는 대신 `안면 능선`을 두고 큰 명암 면을 조직한다.
- 구조선은 고정 순수 검정이 아니라 주변색보다 매우 어두운 유색선을 기본으로 한다. UI의 정보선은 판독성을 위해 별도 ink color를 가질 수 있다.
- 얼굴 명암은 기본색/주 그림자/작은 밝은 면의 3단 구조를 뼈대로 하고, 각 면 안의 붓질은 자유롭게 둔다.
- 질감의 불균질함은 공통 규칙으로 두되 붓질 형태는 피부·천·금속·목재·석재 등 재질마다 달라진다.
- 같은 시각 효과를 모든 자산에 같은 브러시로 복제하지 않는다. 큰 일러스트, 스프라이트, UI가 각 크기와 기능에 맞게 번역한다.
- UI는 테두리 마모를 공통 효과로 쓰지 않는다. `내부 브러시 채움`을 넓은 정보면과 선택 상태에 사용하고 작은 아이콘과 글자는 비교적 깨끗하게 유지한다.
- 기괴한 신체·형태의 비정상성은 개인 화풍 코어의 필수값도 자동 적용 대상도 아니다. 필요한 프로젝트가 명시적으로 선택한다.
- 스프라이트는 큰 일러스트의 축소판이 아니라 번역판이다. 비율과 색 관계를 유지하면서 구조선 수를 줄이고, 명암을 2단으로 줄이며, 내부 붓질 흔적을 극소량만 둔다.
- 배경 오브젝트는 제작 brief에서 `증거·직접 상호작용`, `길찾기·상황 이해`, `분위기`의 3단계로 분류한다. 모델이나 작업자가 중요도를 임의 추론하거나 승격하지 않는다. 앞 단계일수록 구조선과 형태 분리를 강하게 줄 수 있다.
- Spine 라이선스는 사용하지 않는다. 범용 2D 리깅은 관절 파츠 분리와 머리카락·옷·살의 메시 변형을 합친 혼합형을 목표로 하고, 가려진 부위에는 움직임을 위한 overdraw margin을 포함한다.
- GPT가 최종 그림을 만든다. 사람은 다시 그리지 않는다. 투명화/배경 분리, 크롭, 캔버스·피벗 정렬, 레이어 분리, 리사이즈, 아틀라스 패킹, 색 프로파일 변환, 결정론적 알파 매트·가장자리 정리만 기계적 후처리로 허용한다.
- 실패한 자산은 정체성과 구도가 맞으면 GPT 국소 편집, 전체 시각 문법이 틀리면 재생성을 사용한다. 에이전트는 실패를 판정할 수 있지만 사용자의 요청 없이 이미지 편집이나 재생성을 실행하지 않는다.
- 최종 판정은 개별 이미지의 아름다움이 아니라 실제 게임 화면의 정보 계층과 일관성으로 한다.
- 규칙 충돌 시 `최신 사용자 결정 → 프로젝트 아트 층 → 개인 화풍 코어 → 역할이 제한된 A/B Style Reference → 해당 자산군 Gold Standard` 순으로 적용한다.
- Gold Standard는 환경/배경, 게임플레이 스프라이트, UI, 리깅용 전신 파츠, 비주얼노벨 전신·초상, 조사 화면의 자산군별 묶음으로 둔다. 프로젝트에 필요한 묶음만 활성화한다.
- 공유 대화의 첫 조사 보고서에서 채택한 제작 원리는 [GPT 이미지 게임 아트 제작 보고서](docs/research/visual_reference/GPT_IMAGE_GAME_ART_PIPELINE_REPORT.md)에 보존한다.
- 개인 화풍 코어, 프로젝트 아트 층, 자산군 brief는 각각 별도 파일로 관리한다. 구체 경로와 필수 필드는 [이미지 자산 제작 워크플로](docs/IMAGE_ASSET_WORKFLOW.md)를 따른다.
- 생성 결과는 자동으로 Gold Standard가 되지 않는다. 에이전트는 후보를 탈락시킬 수 있지만 승격·교체·폐기는 사용자의 명시적 승인으로만 확정한다. 새 기준이 승인되기 전에는 기존 기준이 유효하다.
- 모든 생성 요청은 독립 작업이다. 정본 문서를 생성 프롬프트에 통째로 직렬화하지 않고 `docs/IMAGE_ASSET_WORKFLOW.md`의 Compact Visual Contract로 컴파일한다. 실제 A/B 원본, 승인 Style Master, 필요한 Gold Standard와 편집 원본은 이미지 입력으로 명시한다.
- Style Master와 Gold Standard는 생성기가 이미 원본 Style Reference의 화풍을 따라갈 수 있을 때 일관성을 유지하는 기준일 뿐, reference fidelity를 획득시키는 장치가 아니다.
- 생성기/모델은 production 전에 A/B 원본으로 Generator Style-Fidelity Gate를 통과해야 한다. 원본 화풍을 직접 따라하지 못하면 같은 생성기로 Style Master/Gold Standard를 더 만들지 않고 다른 생성기/모델을 시험한다.
- 현재 ChatGPT/OpenAI 이미지 생성 경로의 A/B/AB fresh-generation 실험은 원본 그림체 fidelity 실패로 기록한다. 다음 도구 비교는 `docs/research/visual_reference/STYLE_REFERENCE_TOOL_SURVEY_2026-09-26.md`를 따른다.
- 2026-09-26 사용자 결정: 판정을 기다리던 생성형 도구 화풍 시험(Nano Banana Pro/Seedream 4.5 비교, Layer GPT Image 2, 내장 imagegen A 단독 등)은 전부 불합격으로 처리한다.
- Character Bible은 관계를 비교할 한 장으로, 리깅 파츠는 서로 맞물리는 한 세트로 만든 뒤 기계적으로 분리한다. 애니메이션은 승인 기준 프레임과 포즈 자료를 붙여 프레임별로 만든다.
- 파일 규격·알파·피벗·레이어·명명·출처 같은 기계 판정은 하드 게이트다. 이를 통과한 후보만 실제 게임 화면에 넣고, 정보 계층과 시각 일관성은 사용자가 최종 승인한다.

## 11. 해상도

필수 지원/검수:
- 1280×720
- 1920×1080
- 2560×1440

FHD와 QHD에서 UI 겹침/잘림 없이 같은 게임을 플레이할 수 있어야 한다.

## 12. 공유와 아키텍처

기존 방향을 유지한다.

- 영속 AppRoot
- ModuleDirector
- ModuleContext
- 모듈 격리
- 버전 있는 JSON 저장
- 다른 모듈 직접 참조 금지

두 실제 사용처에서 같은 의미와 계약이 확인되기 전에는 shared 추상화를 만들지 않는다. 두 번째 실제 사례가 생기면 추출을 검토한다.

Kit 전체를 외부로 복사/포크하기 위한 공개 API 제품으로 설계하지 않는다.

## 13. 완료

자동 테스트 통과만으로 완료가 아니다.

최소 조건:
- 핵심 시스템 동작
- 10분+ Reference Game
- authored content 추가 가능
- Primary Reference와 화면/UX 비교
- 720p/FHD/QHD 검수
- 저장/복원/실패/재시도
- placeholder 화면 제거
- 상시 HUD 제거
- 사용자 직접 플레이 검토 가능

사용자 플레이 검토 전 상태는 **검토 준비 완료**다.

## 14. 장르 구간의 묶음과 전환

여러 Kit의 장르 구간이 본편에서 하나의 **뭉탱이**를 이룰 수 있다. 한 뭉탱이 안에서는 해당 뭉탱이의 설계에 따라 물건이나 신체 상태가 여러 Kit에 공통일 수 있다. 장르에 어울리지 않는 물건·신체 상태가 다른 장르에 그대로 들어오는 충돌은 TIN의 핵심 경험이다. 예를 들어 3D 아이템이 2D 화면에 등장하거나, 체력이 1~3인 플랫폼 게임 문법에 체력 200인 캐릭터가 들어올 수 있어야 한다.

뭉탱이 안에서 여러 Kit가 공유하는 상태는 뭉탱이가 하나의 원본을 소유하고, 각 Kit가 필요한 부분을 사용한다. Kit 사이에 상태를 복사해 별도의 진실을 만들지 않는다.

뭉탱이 경계를 넘어 물건·신체 상태를 계속 가져가려면 명시적인 인계가 있어야 한다. 장르에 맞지 않는다는 이유로 인계된 상태를 자동 정규화하지 않는다.

월드 변화의 유지·초기화, 방 재진입, 실패·재시작·체크포인트는 각 Kit의 게임 문법을 따른다. 방 밖으로 나갔다 들어오면 초기화되는 문법도 정상이다. 모든 세계 변화를 영속화하거나 모든 실패를 뭉탱이 단위로 되돌리는 전역 기본값을 만들지 않는다. FPS→추리→플랫폼 진행 중 플랫폼에서 실패한 제시 사례는 실패한 플랫폼 구간 시작으로 복귀한다. 이를 다른 Kit까지 같은 복귀 범위로 고정하는 근거로 사용하지 않는다.

이질적 규칙 충돌의 기준 사례: 체력 200인 캐릭터가 통상 세 번 맞으면 죽는 플랫폼 구간에 들어와 피해 1을 받으면 체력은 **200에서 199**가 된다. 플랫폼 장르의 통상 체력 범위에 맞춰 1~3으로 환산하지 않는다.

같은 장소·장면이 다른 장르 문법으로 바뀌는 경험은 일급 요구사항이다. 내부 GameModule 교체 구조를 유지하더라도 플레이어가 느끼는 공간·사건의 연속성을 지원한다.

같은 장소에서 장르가 바뀔 때 좌표 숫자를 그대로 옮기는 대신 ‘문 앞’, ‘책상 옆’처럼 장면에서 의미 있는 위치를 이어받아 새 장르가 표현한다.

장르 전환은 사건·진행에 의해 일어날 수도 있고, 플레이어가 필요에 따라 오갈 수도 있다. 자유 전환은 이를 허용하도록 설계한 뭉탱이에서 제공한다.

다른 장르에서 가져온 물건·능력은 원래 조작 문법까지 함께 가져올 수 있다. 현재 장르의 조작으로 반드시 환산하지 않는다. 여러 장르의 문법이 동시에 작동할 때 입력 충돌과 화면 구성은 해당 뭉탱이에서 설계한다.

플레이어가 실제로 알아낸 규칙·암호·해법은 저장 상태와 별개다. 실패나 체크포인트 복귀로 게임 상태를 되돌릴 수 있어도 플레이어 머릿속 지식을 선택적으로 지우거나 저장 상태로 통제할 수 있다고 전제하지 않는다.

이미 해법을 아는 플레이어는 처음부터 그 해법을 실행할 수 있다. 추리의 범인이나 수학 문제의 답을 이미 알면서도 정해진 발견 시간을 다시 채우도록 강제하지 않는다. 순수한 지식 관문을 `clue_found` 같은 발견 기록으로 잠그지 않는다.

## 15. Kit UI와 본편 적용

Reference Game 단계에서는 Primary Reference의 화면 구성과 UI 문법을 강하게 따라간다. 시스템만 가져와 UI를 임의로 재해석하지 않는다. 모든 Kit를 만든 뒤 실제 TIN 본편을 제작할 때 사용자 취향에 맞게 UI를 다시 설계할 수 있다.

## 16. 사용자 검토와 다음 Kit

한 Kit가 검토 준비 완료에 도달하면 사용자 직접 플레이 전에도 다음 Kit의 grilling·계획 논의는 시작할 수 있다. 다음 Kit의 구현은 앞선 Kit의 사용자 플레이 피드백을 반영한 뒤 시작한다.

사용자 피드백이 시스템·입력·화면 구조를 바꾸면 해당 Kit 계획서의 계약과 완료 기준에 먼저 반영한 뒤 수정한다. 수치·간격 같은 작은 튜닝은 검수 기록에 남기고 바로 수정할 수 있다.

프로젝트 전체에도 적용되는 실패 원인은 한 번 확인되면 즉시 공통 규칙으로 승격한다. 같은 실패가 두 Kit에서 반복될 때까지 기다리지 않는다.

project-wide direction을 닫은 뒤 첫 Kit별 grilling 대상은 **Rule Rewrite**다. Kit 계획 논의는 겹쳐 진행할 수 있지만 Kit 구현은 한 번에 하나씩 진행한다.

## 17. Rule Rewrite Kit — 사용자 확정 방향

Reference Game은 인게임 퍼즐에 집중한다. 현재 단계에서 지도·챕터·스테이지 구분 체계를 확장하지 않는다. 사용자가 이미 아는 규칙을 빠르게 조합하며 시스템 동작을 확인하는 경험을 우선한다.

여러 장르의 규칙을 섞어 예상 밖의 상호작용을 만들 기반을 원한다. 사용자 요청 확장으로, 오브젝트로 만든 속이 빈 테두리 내부를 인벤토리로 정의하는 문법을 설계한다. 테두리를 하나의 대형 오브젝트로 취급하고 인벤토리 판정을 부여한다. 구체적인 실행 계약은 Rule Rewrite Kit 계획서에 기록한다.

Authored 퍼즐의 대안 route와 우회는 금지하지 않는다. 다만 특정 문장 집합을 강제로 완성시키기만 하는 trivial한 puzzle이나, 핵심 시스템과 무관한 우회만 남는 콘텐츠는 유효한 Reference Game 증거로 삼지 않는다.

복합 오브젝트 문법의 기준 예시는 실제 `BOX` 오브젝트로 속이 빈 사각형 테두리를 만들고, 텍스트 오브젝트로 `BOX INSIDE IS METRIX`를 성립시키는 것이다. 조건을 만족하는 각 사각형은 `METRIX`라는 하나의 대형 오브젝트 판정을 받는다. 기존 BOX 오브젝트와 복합 결과 명사를 구분한다.

하나의 선언에서 닫힌 테두리가 둘 이상 문법적으로 성립하면 후보 하나를 고르지 않고 각각이 대형 오브젝트가 된다. 공유 벽·중첩 구조도 Baba의 겹친 토큰과 다중 규칙처럼 모든 유효 결과를 만든다.

인벤토리 UI와 보드 내부는 같은 아이템 상태를 표현한다. 보드에서 아이템을 넣거나 빼면 인벤토리에 즉시 반영되고, 인벤토리에서 아이템을 꺼내거나 사용하면 보드 내부에서도 사라지거나 상태가 바뀐다. 테두리에 문을 넣으면 인벤토리 판정이 성립한 뒤에도 내부로 들어가 조각과 아이템을 조작할 수 있다.

테두리가 METRIX로 성립한 뒤 구성 BOX를 밀면 조각 하나가 빠지는 대신 METRIX 전체가 움직인다. 대형 오브젝트 판정을 해체하려면 `BOX INSIDE IS METRIX` 규칙을 깨야 한다. 이동 시 내부 물건도 함께 운반되며 4096처럼 이동 방향의 안쪽 벽에 붙는다. 외부 월드와의 이동 가능 여부는 METRIX 경계만 충돌 검사한다. 내부 물건은 외부 충돌 판정에 참여하지 않는다.

인벤토리의 기본 소유자는 개별 개체가 아니라 현재 **YOU 집합**이다. YOU가 여러 개면 하나의 공용 인벤토리를 공유한다. 별도의 소유 문법이 성립하면 소유자를 바꾸거나 인벤토리를 분리할 수 있다.

BABA IS 3D 상태에서 인벤토리와 핫바가 마인크래프트처럼 나타나는 방향을 요청했다. Minecraft를 이 인벤토리·핫바 확장점의 Secondary Reference로 허용하며, 다른 화면·시스템으로 허용 범위를 확대하지 않는다. 선택된 시점이 3D일 때 핫바가 보이고 2D로 돌아오면 사라진다. 공용 인벤토리 상태 자체는 유지된다. 사용자가 제공한 인벤토리 화면 캡처는 docs/research/rule_rewrite/minecraft_inventory_user.png에 보존했다.

3D 진입은 1인칭에서 시작하고, 1인칭 이동은 격자 턴으로 한다. W는 전방 한 칸, A/D는 좌우 90도 회전, V는 1인칭/3인칭 전환이다. 회전과 시점 전환은 물리 턴·Undo를 만들지 않는다.

3D 핫바에서 ROCK 같은 오브젝트를 선택했을 때의 기본 행동은 현재 3D 공간에 그 오브젝트를 배치하는 것이다.

YOU가 여러 인벤토리 METRIX를 소유하면 각 METRIX는 별도 인벤토리로 유지된다. 하나의 합쳐진 슬롯 목록으로 병합하지 않는다. 현재 활성 인벤토리와 소유 관계는 규칙으로 바꿀 수 있게 설계한다.

## 18. 전역 이미지 기준과 Rule Rewrite 3D 카메라

사용자가 제공한 이미지 A·B는 TIN 게임 전체의 이미지 스타일 참고로 보존한다. 원본 캐릭터·배경은 복제하지 않는다. 과거 at-icons 조립 실험과 제작 방식은 `archive/icon_based_image_assets/`에 보관하며, 해당 기록은 새 이미지 자산 기반을 정하는 근거로 자동 승격하지 않는다. 원본 이미지와 적용 범위는 [시각 레퍼런스 기록](docs/research/visual_reference/STYLE_AND_CAMERA_REFERENCE.md)에 보존한다.

Rule Rewrite의 `IS 3D`는 사용자 제공 이미지 C의 DOOM식 **1인칭 화면으로 시작**한다. 기존 3인칭 3D 보드 시점도 보존하고 키 입력으로 전환한다. 두 시점은 같은 물리 상태를 표현한다. C는 이 Kit의 카메라 참조이며 A·B의 전역 아트 스타일을 대체하지 않는다.

## 19. 다음 Kit — Top-down Action-RPG

다음 Kit의 작업명은 **Top-down Action-RPG Kit**이다.

- 유일한 Primary Reference는 **BLACK SOULS 2**다.
- 이 Kit의 계획에서 BLACK SOULS 2에 최대 가중치를 준다. 다른 게임의 시스템·UI·분위기를 섞지 않는다.
- 시스템·UX·콘텐츠 밀도·분량을 따라가되, 원작 자산·문구·캐릭터·지도 배치·세계관은 복제하지 않는다.
- Reference Game은 한 보스나 한 맵으로 끝나지 않는다. 여러 지역·NPC 관계·적군·보스 패턴·전역 상태·선택지를 같은 core 위에서 사용하는 substantial multi-route content slice여야 한다.
- 스토리·character·enemy design의 범용 규칙을 추출해 우리 콘텐츠 제작의 기반으로 삼는다. 이는 원작 고유 세계관의 대체 skin이 아니다.
- 앨리스는 새 세계관·콘텐츠·계획에서 완전히 제외한다. 다른 세계관을 쓰되 앨리스 요소를 변형해 재사용하지 않는다.
- 사용자가 제공한 실제 플레이 캡처 A~H를 Kit 조사에 반영했다. 후속 세계관 메모를 shared understanding에 반영하고, 계획 범위에 꼭 필요한 상태가 비어 있을 때만 추가 캡처를 요청한 뒤 최종 계획을 확정한다.
- 계획서는 여러 파일로 분할하며, authored content와 story/world/character 부분에 가장 큰 분량을 준다.
- 2026-09-26 사용자 결정: 이 Kit는 코드로 그린 그림(아이콘 조합, 도트, SVG/Pillow 절차 그림)을 최종 그림으로 허용한다. 이 Kit에서는 §10의 GPT 최종 그림·기계적 후처리 한정·생성기 화풍 게이트보다 이 결정이 우선한다. 결과는 candidate로 시작하고 승인·Gold Standard 승격은 사용자만 한다. 같은 날 사용자 결정으로 아이콘 조합의 코딩 금지도 해제한다: 이 Kit에서는 코드를 짜서 아이콘을 조합해도 된다(보관된 at-icons 문서의 편집기 전용·코드 생성 금지 미적용).

현재 조사 결과는 [BLACK SOULS 2 통합 조사](docs/research/top_down_action_rpg/BLACK_SOULS_2_RESEARCH.md), [사용자 실제 플레이 A~H](docs/research/top_down_action_rpg/USER_PLAY_REFERENCE_2026-09-25.md), [분할 계획 중앙 해석](docs/research/top_down_action_rpg/PLAN_RESOLUTION.md)에 보존한다. 사용자 세계관 메모와 shared understanding 및 분할 계획 검토가 완료되었으므로, 이제 구현·검증으로 진행한다.

## 20. Top-down Action-RPG 세계관 메모와 실행 계약

사용자가 제공한 긴 메모는 canon 원문이 아니라 **문장 단위 idea source**다. 대화 metadata, 작성자/날짜, 중복, 독립성이 없는 filler는 자동 canon이 아니다. 한 문장이나 특정 NPC 대사 한 번의 언급도 authored content seed로 사용할 수 있다.

- usable idea unit의 최소 60%를 구조적으로 변환해 사용한다.
- 사용한 seed마다 local rule, TIN system binding, 최소 두 개의 cross-link, immediate consequence, delayed consequence를 기록한다.
- subagent는 독립 작업하되 중앙 world constitution, stable IDs, 파일 소유권, dependency contract를 공유한다. subagent가 타 영역의 canon을 덮어쓰지 않는다.
- 세상은 하나의 deep system 안에 여러 module/era를 가지며, 왕관은 literal object·political institution·metaphysical invariant의 세 층위를 가진다.
- root law는 단순 simulation이 아니라 recovery·recognition·authority를 서로 다르게 구현하는 여러 protocol의 meta-system이다.
- player는 investigator이면서 world protocol의 experiment/subject다.
- institutions는 local competence를 가지며 category error와 interface failure에서 political absurdity를 만든다.
- orthogonal axes 2~4개, 서로 다른 pressure clocks, 분기별 6~12 NPC interaction cluster를 사용한다.
- romance와 affection은 허용한다. explicit sexual content는 제거한다. body horror는 허용한다.
- 사용자는 계획서 완성부터 게임 Kit 구현·검증까지 8시간 연속 one-shot 실행을 요청했다. 구현은 계획 게이트와 파일 소유권을 확인한 뒤 시작한다.

## 21. Next Kit — Stone Story RPG (2026-09-26 사용자 지시)

사용자가 새 방향을 확정했다.

- 목표는 **Stone Story RPG와 유사한 게임**이다.
- **이미지 작업을 전부 코드로 작성한 절차적 애니메이션으로 대체한다.** 이 Kit은 이미지 자산 파일을 쓰지 않는다.
- 분위기·스토리·내용의 source는 **Ena: Dream BBQ**다.
- 시스템은 **Stone Story RPG (main) + Dark Souls 3 (sub)** 다.
- 분량은 **Stone Story RPG 규모**다.
- **자료조사는 전부 사용자가 수행한다.** 에이전트는 외부 조사를 하지 않고, 추가 자료가 필요하면 사용자에게 요청한다.
- 사용자는 1만자 이상의 조사 결과를 주기적으로 제공한다. 제공된 원문은 `docs/research/stone_story_rpg/00_user_dumps/`에 수정 없이 보관하고, 해석 문서는 `01`~`04` 폴더로 분리한다.

레퍼런스 지위:

- Primary Reference는 **Stone Story RPG 하나**다.
- Dark Souls 3는 Sub Reference다. **확장점이 확정되기 전에는 사용하지 않는다.**
- Ena: Dream BBQ는 시스템 레퍼런스가 아니라 분위기·스토리·내용의 source다. `01`의 시스템 문법과 섞지 않는다.

이미지 자산 파이프라인과의 관계:

- `docs/VISUAL_DIRECTION.md`, `docs/IMAGE_ASSET_WORKFLOW.md`, `docs/art/**`,
  본 문서 §10의 IMG1–IMG25는 **이 Kit에 적용되지 않는다.**
- 적용 범위가 이 Kit 한정인지 프로젝트 전체인지는 미확정이다. 전체라면 프로젝트 아트 층과 Gold Standard 구조의 지위가 바뀐다.
- 이미지 생성/편집 도구는 이 Kit에서 호출하지 않는다.

조사 정본: [Stone Story RPG Kit 조사 인덱스](docs/research/stone_story_rpg/README.md)
계획서: [plans/kits/05_STONE_STORY_RPG_KIT.md](plans/kits/05_STONE_STORY_RPG_KIT.md)

### 21.1 미확정 결정

- **Kit 슬롯**: 이 방향이 `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/`(Primary Reference BLACK SOULS 2)의 슬롯을 대체하는지, 별도 슬롯인지 미확정. `modules/top_down_action_rpg/`에 미커밋 구현이 남아 있으므로 삭제·재방향은 사용자 결정 후에만 수행한다.
- **완료 기준**: `docs/KIT_WORKFLOW.md` §3·§12의 "10분+ Reference Game"과 "Stone Story RPG 규모"의 관계가 미확정.
- **Dark Souls 3 확장점**: 미확정.
- **코드 전용 범위**: Kit 한정인지 프로젝트 전체인지 미확정.

### 21.2 계획 게이트

`docs/research/stone_story_rpg/README.md` §2의 S1–S14, E1–E5, P1–P5가 `MISSING`인 동안에는
**어떤 코드도 작성하지 않는다.** 기억으로 채운 Primary Reference 내용은 구현 근거로 인정하지 않는다.

---

# 23. Kit 04 Top-down Action-RPG 구현 상태 — 2026-09-27

## 23.1 확정된 사실

Primary Reference는 **BLACK SOULS 2 하나**로 확정되어 있다. `godot-jrpg`는 파일 단위 감사 없이 채택하지 않았다.

2026-09-27 기준으로 Kit 04는 **자동 게이트 전부 통과** 상태다.

- catalog **313 files / 19 kinds** · region 9 · edge 18 · **gate 9** · cluster 9
- NPC 21 (14 core + 7 support) · enemy 19 · **encounter 37** · recovery **7 canonical 전부**
- **group 5** (`GRP-ARPG-01`~`05`) · **variant 6** (`VAR-ARPG-01`~`06`) · npc_conversion encounter 5
- `run_tests` 644/644 · core GUT 19/19 · module GUT 20/20 · import 0 · smoke 0
- playthrough probe **exit 0**, canonical coverage **14/14**, budget 7223s (required 3418s), surfaces 23/22

`gate_g8_crown_precedence`는 loader의 `CANONICAL_GATE_IDS`에 원래부터 있었고 **content만 누락**한 상태였다. content를 연결해 gate 9/9가 되었다.

## 23.2 이번 세션에 고친 구조적 결함

encounter roster slot의 **48/80(60%)이 enemy의 자기 `base_region_id` 밖에 배치**돼 있었다. 각 encounter의 roster를 자기 region pool에서 재구성해 **0/78**로 만들었고, 회귀를 막기 위해 loader에 `enemy_region_mismatch` 검사를 연결했다(음성 테스트로 실제 동작 확인).

`05` §2의 `FAM-ARPG-*` 이름과 content의 enemy 이름 사이에 대응표가 정본에 없으므로 **그 매핑을 지어내지 않았다.** region 정합만 보장된다.

## 23.3 미결 — 사용자 결정 필요

`docs/research/top_down_action_rpg/IMPLEMENTATION_STATUS_2026-09-27.md` §6의 A–I 항목을 참조. 핵심 3건:

- **A** encounter roster 구성을 계획 `05` §2 FAM 배정까지 복원할 것인가
- **B** ending의 catalog 착지와 런타임 구동 — 현재 vocabulary만 있고 commit 경로가 없다
- **C** 테스트/harness 변경 5건 승인

## 23.4 픽셀 증거와 최종 아트

720p/FHD/QHD 캡처는 **headless가 구조적으로 생성하지 못한다.** visual capture harness가 design상 headless에서 PNG를 거부하므로, 이는 사용자 플레이 검수 게이트에 속한다.

이미지 파이프라인은 `docs/art/projects/top_down_action_rpg/`에 준비돼 있고 H0 background candidate 1장이 있으나 **승인되지 않았다.** approved/와 Gold Standard는 없다. 현재 화면은 vector presentation이며 최종 Gold Standard 증거가 아니다.
