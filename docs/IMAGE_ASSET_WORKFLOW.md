# TINProject — Image Asset Workflow

## 1. 목적

이 문서는 GPT 이미지 자산의 입력, 후보, 승인, 후처리, 실제 게임 화면 검수를 규정한다. 시각 문법은 `docs/VISUAL_DIRECTION.md`, 조사 근거는 `docs/research/visual_reference/GPT_IMAGE_GAME_ART_PIPELINE_REPORT.md`를 따른다.

Kit의 Reference Game에서는 계획서의 톤앤매너와 이미지 제작 명세를 먼저 확정한다. 필수 장면·인물·단서 자료나 참조 링크를 읽을 수 없어 생성할 내용이 불분명하면 추측으로 생성하지 않고 작업을 멈춰 누락을 기록한다.

## 2. 파일 구조

```text
docs/art/
  PERSONAL_STYLE_CORE.md
  projects/<project_id>/
    PROJECT_ART_LAYER.md
    asset_briefs/<asset_family>.md
    gold_standards/<asset_family>/MANIFEST.md

assets/art/<project_id>/
  candidates/<asset_family>/
  approved/<asset_family>/
```

문서와 실제 이미지를 분리한다. 프로젝트가 해당 자산군을 처음 사용할 때만 디렉터리와 brief를 만든다. 빈 자산군 구조를 미리 만들지 않는다.

## 3. 필수 필드

### PERSONAL_STYLE_CORE.md

- 버전과 변경일
- 구조선과 안면 능선
- 색 관계와 명도 범위
- 명암 면 규칙
- 재질별 내부 붓질
- 자산 크기별 번역
- UI 렌더 문법
- 금지 요소
- A/B Style Reference의 허용 역할

### PROJECT_ART_LAYER.md

- 프로젝트 ID와 적용할 코어 버전
- 세계관과 정서
- 캐릭터·의상·소품 정체성
- 프로젝트 색 관계
- 카메라와 Primary Reference 적용
- UI 형태와 화면 구성
- 허용하거나 금지한 형태의 비정상성
- 활성 자산군과 Gold Standard manifest

### asset_briefs/<asset_family>.md

- 자산 ID, 용도, 실제 게임 상태
- 출력 크기, 파일 형식, 알파, 피벗, 레이어
- 실루엣, 포즈, 카메라, 조명
- 정보 중요도와 초점
- 유지할 요소와 변형할 요소
- 사용할 원본과 활성 Gold Standard
- 금지 요소
- 실제 화면 검수 장면과 지원 해상도

배경 brief는 각 오브젝트를 `증거·직접 상호작용`, `길찾기·상황 이해`, `분위기` 중 하나로 명시한다.

## 4. 독립 생성 작업

모든 생성·편집 요청은 독립 작업으로 구성한다. 매번 다음을 입력한다.

1. 현재 PERSONAL_STYLE_CORE
2. 해당 PROJECT_ART_LAYER
3. 해당 asset brief
4. 해당 자산군의 활성 Gold Standard
5. 편집이면 원본 이미지와 유지할 영역

채팅의 이전 기억, 이전에 승인되지 않은 결과, 다른 자산군의 Gold Standard는 암묵적 입력으로 사용하지 않는다.

## 5. 제작 단위

- Character/World Bible: 여러 시점과 재질 관계를 비교하는 한 장
- 리깅용 전신 파츠: 비례와 연결부가 맞는 한 세트로 생성한 뒤 허용된 기계적 공정으로 분리
- 애니메이션: 승인 기준 프레임과 포즈 자료를 붙여 프레임별 생성
- 그 밖의 자산: asset brief 하나가 정의한 실제 게임 용도 하나

완성 스프라이트 시트를 한 번에 생성해 반복 프레임으로 채우지 않는다.

## 6. 후보와 Gold Standard

생성 결과의 초기 상태는 항상 `candidate`다.

- 에이전트는 하드 게이트 또는 정본 규칙 위반 후보를 탈락시킬 수 있다.
- 에이전트나 모델은 후보를 스스로 Gold Standard로 승격하지 않는다.
- 승격, 기존 기준 교체, 기준 폐기는 사용자의 명시적 승인으로만 확정한다.
- 교체 후보가 승인되기 전에는 기존 Gold Standard가 계속 유효하다.
- MANIFEST에는 승인 파일, 적용 범위, 승인 근거가 된 사용자 결정, 대체한 기준을 기록한다.

## 7. 하드 게이트

다음을 모두 통과해야 실제 게임 화면 후보가 된다.

- brief의 픽셀 크기와 파일 형식
- 알파 유무와 배경 분리 상태
- 지정 색 프로파일
- 캔버스, 피벗, 안전 여백
- 요구 레이어와 파츠 누락 없음
- 파일명과 자산 ID 일치
- 원치 않는 글자·워터마크·서명 없음
- 입력 레퍼런스와 권리 출처 기록 존재
- 허용된 기계적 후처리만 적용

하드 게이트는 작품의 아름다움이나 스타일 적합성을 자동 승인하지 않는다.

## 8. 실제 게임 화면 승인

하드 게이트를 통과한 후보를 지정 장면에 넣어 1280×720, 1920×1080, 2560×1440에서 확인한다.

- 플레이 정보와 장식의 우선순위
- 캐릭터·배경·UI의 밀도와 초점
- focus와 입력 상태의 판독성
- Primary Reference의 카메라·화면 문법 유지
- 같은 자산군 및 장면 안의 시각 일관성

에이전트는 검사 결과와 차이를 보고한다. 사용자가 실제 화면을 보고 최종 승인한 뒤 `approved` 및 Gold Standard 승격 여부를 기록한다.
