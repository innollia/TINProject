# TINProject — Image Asset Workflow

## 1. 목적

이 문서는 GPT 이미지 자산의 입력, 스타일 bootstrap, 후보, 승인, 후처리, 실제 게임 화면 검수를 규정한다. 시각 문법은 `docs/VISUAL_DIRECTION.md`, 조사 근거는 `docs/research/visual_reference/GPT_IMAGE_GAME_ART_PIPELINE_REPORT.md`를 따른다.

Kit의 Reference Game에서는 계획서의 톤앤매너와 이미지 제작 명세를 먼저 확정한다. 필수 장면·인물·단서 자료나 참조 링크를 읽을 수 없어 생성할 내용이 불분명하면 추측으로 생성하지 않고 작업을 멈춰 누락을 기록한다.

**문서가 정본으로 길 수 있는 것과 한 번의 이미지 생성 요청이 길어야 하는 것은 별개다.** 생성 모델에 프로젝트 문서를 통째로 직렬화하지 않는다. 실제 생성 입력은 아래 Compact Visual Contract로 압축한다.

## 2. 파일 구조

```text
docs/art/
  PERSONAL_STYLE_CORE.md
  style_master/
    MANIFEST.md
  projects/<project_id>/
    PROJECT_ART_LAYER.md
    asset_briefs/<asset_family>.md
    gold_standards/<asset_family>/MANIFEST.md

assets/art/style_master/
  candidates/
  approved/

assets/art/<project_id>/
  candidates/<asset_family>/
  approved/<asset_family>/
```

문서와 실제 이미지를 분리한다. 프로젝트가 해당 자산군을 처음 사용할 때만 디렉터리와 brief를 만든다. 빈 자산군 구조를 미리 만들지 않는다.

`style_master/`는 A/B의 제한된 역할을 실제 한 장의 픽셀 문법으로 합성하기 위한 전역 bootstrap 자산이다. production 캐릭터나 사건 장면이 아니다.

## 3. 필수 필드

### PERSONAL_STYLE_CORE.md

- 버전과 변경일
- 관찰 가능한 얼굴 중앙 구조와 명암 분할
- 구조선의 굵기·압력·끊김
- 색 관계와 명도 범위
- 재질별 내부 붓질
- 머리카락과 큰 색 덩어리의 처리
- 인물/배경 밀도 분리
- 자산 크기별 번역
- UI 렌더 문법
- 실패 판정
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

## 4. Generator Style-Fidelity Gate

Gold Standard와 Style Master는 **스타일을 획득하는 장치가 아니다.** 생성기가 원본 레퍼런스의 화풍을 직접 따라갈 수 있다는 사실이 먼저 증명된 뒤, 이미 성공한 화풍을 반복하기 위한 일관성 기준으로만 사용한다.

### 4.1 첫 게이트

새 이미지 도구/모델을 생산 파이프라인에 넣기 전에 A/B 원본으로 다음만 검증한다.

1. 원본을 style/reference 입력으로 사용한 새 피사체 생성
2. 원본을 편집해 색 또는 한 가지 내용 요소만 바꾸기
3. 결과를 원본과 나란히 보고 렌더링 과정의 보존 여부 판정

통과 기준은 "비슷한 분위기"가 아니다.

- 얼굴 면 분할 방식
- 선의 굵기·압력·끊김
- 내부 붓질의 크기와 방향
- 머리카락 큰 덩어리 처리
- 인물/배경의 밀도 계층

이 항목이 원본과 같은 계열의 렌더링 과정으로 보이지 않으면 해당 도구/모델은 **style-critical production에 부적합**으로 기록한다.

### 4.2 실패 시

게이트에 실패한 생성기로:
- Style Master를 새로 만들지 않는다.
- 실패 결과를 다시 reference로 넣어 재귀적으로 "스타일을 학습"시키려 하지 않는다.
- Gold Standard를 쌓아 해결하려 하지 않는다.
- production 캐릭터를 계속 재생성하며 우연한 성공을 기다리지 않는다.

대신 **reference-style 전용 제어가 더 강한 다른 도구/모델**로 넘어간다.

### 4.3 Style Master와 Gold Standard의 역할

Generator Style-Fidelity Gate를 통과한 뒤에만 Style Master를 선택적으로 만든다.

- Style Master: 이미 검증된 생성기의 전역 렌더 문법을 한 장으로 고정하는 편의 기준
- Gold Standard: 특정 자산군에서 이미 성공한 production 결과의 일관성 기준

둘 다 원본 A/B보다 상위의 스타일 근거가 아니며, 원본을 제대로 못 따라가는 생성기의 fidelity를 높여 주는 장치가 아니다.

현재 도구 조사와 다음 검증 순서는 `docs/research/visual_reference/STYLE_REFERENCE_TOOL_SURVEY_2026-09-26.md`를 따른다.

## 5. Compact Visual Contract

모든 생성 요청은 정본 문서를 읽고 판단한 뒤, 생성 모델에는 아래만 압축해서 전달한다.

1. **Use case / output** — 자산 용도, 크기, 알파·레이어 등 실제 출력 조건
2. **Pixel target** — 실제 A/B 원본, 게이트를 통과한 도구에서만 승인 Style Master/Gold Standard, 편집 원본 중 필요한 실제 이미지 입력
3. **Style invariants** — 이번 자산에서 눈으로 확인 가능한 핵심 4~7개
4. **Identity anchors** — 결과를 바꾸는 캐릭터·소품·장면 특징만
5. **Composition / hierarchy** — 카메라, 초점, 정보 밀도
6. **Failure guards** — 이미 실제로 반복된 실패를 막는 최소 금지

하지 않는다:
- PERSONAL_STYLE_CORE 전체를 프롬프트에 붙여 넣기
- PROJECT_ART_LAYER 전체를 프롬프트에 붙여 넣기
- 같은 의미를 긍정문과 여러 금지문으로 반복하기
- "painterly", "stylized", "detailed", "high quality" 같은 일반 형용사로 고유 시각 불변식을 대체하기
- 캐릭터 정체성 세부를 스타일 calibration 단계에 과적재하기

문서와 brief는 **컴파일 입력**이고 Compact Visual Contract는 **생성 실행물**이다.

생성 표면이 `revised_prompt` 또는 동등한 실제 전달 프롬프트를 노출하면 원 요청과 함께 기록한다. ChatGPT처럼 rewrite 결과를 직접 볼 수 없는 표면에서는 생성 경계를 lossy compiler로 취급하고, 핵심 불변식이 짧은 계약 안에 남도록 한다.

## 6. 독립 생성 작업

모든 생성·편집 요청은 독립 작업으로 구성한다.


각 생성 작업에는 필요한 입력을 다시 명시적으로 넣는다.

1. 실제 A/B 원본 중 필요한 것
2. 현재 생성기가 Style-Fidelity Gate를 통과했다면 승인 Style Master
3. 현재 생성기가 Style-Fidelity Gate를 통과했다면 해당 자산군의 활성 Gold Standard
4. Compact Visual Contract
5. 편집이면 원본 이미지와 유지할 영역

이전 생성 작업의 채팅 기억, 이전에 승인되지 않은 결과, 다른 자산군의 Gold Standard를 암묵적 입력으로 사용하지 않는다.

## 7. 스타일과 정체성은 단계적으로 잠근다

production 캐릭터에서 스타일과 정체성을 처음부터 같은 난이도로 밀어 넣지 않는다.

기본 순서:
1. **style lock** — 먼저 원본 A/B에 대해 Generator Style-Fidelity Gate를 통과한 생성기를 사용하고, 그 뒤에만 Style Master 또는 Gold Standard와 핵심 실루엣/색 관계를 사용한다.
2. **identity correction** — 얼굴 특징, 정확한 장식 수, 소품, 손 습관처럼 정체성 오류를 국소 편집 또는 제한된 재생성으로 조인다.
3. **technical correction** — 알파, 여백, 피벗, 레이어와 같은 기계 조건을 맞춘다.

스타일 문법 전체가 틀렸는데 핀 개수·손가락·소품만 고치는 데 시간을 쓰지 않는다. 반대로 스타일과 구도가 맞았는데 작은 정체성 오류만 있으면 전체 재생성보다 국소 편집을 우선한다.

## 8. 제작 단위

- Character/World Bible: 여러 시점과 재질 관계를 비교하는 한 장
- 리깅용 전신 파츠: 비례와 연결부가 맞는 한 세트로 생성한 뒤 허용된 기계적 공정으로 분리
- 애니메이션: 승인 기준 프레임과 포즈 자료를 붙여 프레임별 생성
- 그 밖의 자산: asset brief 하나가 정의한 실제 게임 용도 하나

완성 스프라이트 시트를 한 번에 생성해 반복 프레임으로 채우지 않는다.

## 9. 후보와 Gold Standard

생성 결과의 초기 상태는 항상 `candidate`다.

- 에이전트는 하드 게이트 또는 정본 규칙 위반 후보를 탈락시킬 수 있다.
- 에이전트나 모델은 후보를 스스로 Style Master나 Gold Standard로 승격하지 않는다.
- 승격, 기존 기준 교체, 기준 폐기는 사용자의 명시적 승인으로만 확정한다.
- 교체 후보가 승인되기 전에는 기존 기준이 계속 유효하다.
- MANIFEST에는 승인 파일, 적용 범위, 승인 근거가 된 사용자 결정, 대체한 기준을 기록한다.
- Gold Standard가 0장이라는 사실은 production을 무한 맨땅 생성하는 허가가 아니다. 먼저 Generator Style-Fidelity Gate를 통과한 생성기를 확보한다.

## 10. 하드 게이트

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

## 11. 스타일 게이트

하드 게이트와 별도로, 큰 일러스트/캐릭터판은 최소 다음을 눈으로 비교한다.

- 얼굴 중앙 구조선 또는 능선이 실제로 큰 명암 면을 조직하는가
- 선 굵기·압력·끊김이 실제 픽셀에서 보이는가
- 내부 붓질이 전역 노이즈가 아니라 재질과 형상을 따르는가
- 머리카락이 잔가닥이 아니라 큰 밝기 덩어리로도 읽히는가
- 인물과 배경의 선·대비·밀도 계층이 분리되는가
- 일반적인 클린 애니 콘셉트 아트로 환원되지 않았는가

프롬프트에 해당 단어가 들어갔는지는 증거가 아니다.

## 12. 실제 게임 화면 승인

하드 게이트와 스타일 게이트를 통과한 후보를 지정 장면에 넣어 1280×720, 1920×1080, 2560×1440에서 확인한다.

- 플레이 정보와 장식의 우선순위
- 캐릭터·배경·UI의 밀도와 초점
- focus와 입력 상태의 판독성
- Primary Reference의 카메라·화면 문법 유지
- 같은 자산군 및 장면 안의 시각 일관성

에이전트는 검사 결과와 차이를 보고한다. 사용자가 실제 화면을 보고 최종 승인한 뒤 `approved` 및 Gold Standard 승격 여부를 기록한다.
