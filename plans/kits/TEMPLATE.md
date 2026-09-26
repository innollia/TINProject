# Kit 계획 템플릿

> 이 템플릿의 빈칸이 남아 있으면 구현을 시작하지 않는다.  
> 공통 계약: `docs/KIT_WORKFLOW.md`

# Kit <NN> — <NAME>

## 0. Kit 목적

- TINProject의 한 게임 안에서 어떤 장르 구간을 즉시 만들기 위한 Kit인가?
- 이 Kit를 사용하면 실제 콘텐츠 개발에서 무엇을 새로 만들지 않아도 되는가?
- 이 Kit가 다루지 않는 것은 무엇인가?

## 1. Primary Reference — 정확히 하나

**게임:**  
**개발사/제작자:**  
**출시/잼 맥락:**  
**공식/신뢰 가능한 reference source:**  

### 1.1 상태별 레퍼런스 증거

| 상태 | 실제 reference URL/자료 | 눈으로 확인할 것 | TIN에서 그대로 가져갈 규칙 |
|---|---|---|---|
| first playable frame |  |  |  |
| normal play |  |  |  |
| focus / selection / direct manipulation |  |  |  |
| core mechanic change |  |  |  |
| unavailable / failure |  |  |  |
| success / completion |  |  |  |
| menu/detail if core |  |  |  |
| level/scene transition |  |  |  |

한 URL을 여러 상태에 쓸 수는 있지만 **실제로 그 상태가 자료에 보여야 한다**.

### 1.2 강하게 복제할 것

- 시스템:
- 입력 감각:
- 카메라/보드/공간:
- 정보 노출:
- focus/selection:
- feedback:
- retry/undo/reset:
- 콘텐츠 구조:

### 1.3 복제하지 않을 고유 저작물

- 원작 asset:
- 원작 캐릭터:
- 원작 문구:
- 원작 레벨/맵 배치:
- 원작 고유 이름/세계관:

## 2. 현재 코드 감사

### 2.1 살릴 후보

| 경로/시스템 | 살릴 이유 | 반드시 다시 검증할 것 |
|---|---|---|
|  |  |  |

### 2.2 버릴 것

| 경로/표현/구조 | 버리는 이유 |
|---|---|
|  |  |

기존 코드라는 이유만으로 보존하지 않는다.

## 3. Reference Game — 최소 10분

### 3.1 장르의 Authored Content 단위

예: level / encounter / case / room / NPC event / recipe / track / wave

**이 Kit의 단위:**  

### 3.2 10분 플레이 흐름

| 순서 | authored content | 새로 검증하는 시스템 | 이전 시스템 재사용 |
|---:|---|---|---|
| 1 |  |  |  |

대기/긴 이동/HP 부풀리기/대사량만으로 10분을 만들지 않는다.

### 3.3 하드코딩 방지량

- 서로 다른 authored 단위 최소 수:
- 같은 subsystem 재사용 사례:
- 마지막에 새 content 하나를 data/scene만 추가해 증명하는 방법:

## 4. Domain / State

domain state를 코드/표로 구체화한다.

```text
<state graph or data schema>
```

필수:
- stable IDs
- runtime state
- transient presentation state와의 경계
- invalid/stale state 처리

## 5. Authored Content Format

| content type | 파일 형식 | 필수 필드 | validation | core 수정 없이 추가? |
|---|---|---|---|---|
|  |  |  |  |  |

전용 editor는 요구하지 않는다.

## 6. 핵심 시스템

시스템별:
- 입력
- 출력
- side effect
- 실패 atomicity
- 순서 의존성
- determinism 필요 여부

### 처리 순서

1. 
2. 
3. 

## 7. Input

### 7.1 Game actions

| intent | InputMap action | gameplay 의미 |
|---|---|---|
|  |  |  |

물리 키는 domain에 넣지 않는다.

### 7.2 장르 전환 Input Bubble

- 이전 구간의 required physical keys:
- 이 구간의 required physical keys:
- restore되는 bubble:
- rising bubble:
- popped 흔적으로 남는 bubble:
- bubble 완료 조건:

설명문으로 키 기능을 해설하지 않는다.

## 8. Save / Load / Retry

저장:
- 

load sanitize:
- 

retry/reset/undo:
- 

실패 중간 상태:
- 

## 9. Presentation

### 9.1 화면의 주인공

- 플레이어가 첫 1초에 봐야 하는 것:
- UI보다 우선하는 world element:
- 상시 표시가 정말 필요한 정보:
- 호출할 때만 보이는 정보:

### 9.2 월드 이미지 자산

핵심 object별 출처·라이선스·제작 방법을 적는다. 기존 at-icons recipe는 `archive/icon_based_image_assets/`에 보존하며 새 기준으로 사용하지 않는다. 세부 계약은 `docs/KIT_WORKFLOW.md`의 Kit별 톤앤매너와 이미지 제작 명세 및 `docs/IMAGE_ASSET_WORKFLOW.md`를 따른다.

| object | asset source | 제작/변형 방법 | silhouette 목표 |
|---|---|---|---|
|  |  |  |  |

### 9.2.1 Kit별 톤앤매너

- 적용할 개인 화풍 코어 버전과 프로젝트 아트 층 문서:
- 세계·시대·재질·형태·색 관계·조명·정서:
- Primary Reference에서 따를 카메라·밀도·정보 순서·UI 표현:
- 원작 고유 자산·캐릭터·모티프·문구와 구분하는 방법:
- 배경 오브젝트의 `증거·직접 상호작용` / `길찾기·상황 이해` / `분위기` 분류:
- 실제 화면에서 스타일과 정보 가독성을 확인할 장면:

### 9.2.2 이미지 제작 명세

자산이 많으면 `plans/kits/`의 별도 시각 명세 문서로 분리하고 여기에 링크한다. 계획 승인 전에는 아래 항목을 채운다.

| asset ID·자산군 | 게임 상태·용도 | 장면/인물/오브젝트 정본 | 생성·편집 입력과 Gold Standard | 출력 규격·피벗·레이어 | 정확한 문자·시각 단서 처리 | 검수 장면 |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

- 재등장 인물·물건·장소에서 절대 고정할 특징과 상태별 변주:
- 생성·편집과 기계적 후처리의 경계:
- 자산 출처·사용 권리 기록 방식:
- 하드 게이트와 720p/FHD/QHD 실제 화면 판정:
- 사용자 시각 승인 지점:
- 명세의 필수 입력을 읽을 수 없을 때의 차단 상태:

### 9.3 Focus / Selection

- default focus:
- focus 표시:
- mouse:
- keyboard/controller:
- target 제거 시 fallback:
- screen close 후 restore:

## 10. 화면 상태

각 화면/장면마다 작성:

| screen | initial | normal | focus | active | unavailable/failure | success | return |
|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |

## 11. Shell 관계

- 플레이 중 Shell persistent HUD: **없음**
- Esc 메뉴 호출 시:
- 메뉴 닫을 때:
- Journal/기록이 이 Kit에서 필요한가:
- Shell이 gameplay 정보를 소유하지 않는지:

## 12. 해상도

실제 캡처:
- [ ] 1280×720
- [ ] 1920×1080
- [ ] 2560×1440

각 해상도에서:
- [ ] core play area 유지
- [ ] focus 보임
- [ ] UI 겹침 없음
- [ ] 긴 문자열/최대 데이터
- [ ] 월드 규칙상의 비율 유지
- [ ] 메뉴 open/close

## 13. 자동 테스트

### domain/system
- [ ] 

### content pipeline
- [ ] 새 authored content 추가
- [ ] invalid content reject/sanitize
- [ ] duplicate/missing ref

### save
- [ ] round-trip
- [ ] stale state
- [ ] retry/reset/undo if applicable

### UI contract
- [ ] focus
- [ ] cancel/return
- [ ] disabled intent block
- [ ] state → visible state

## 14. 수동 플레이 과제

플레이어에게 설명하지 않고 실제로 시킬 일:

1. 
2. 
3. 

관찰:
- 첫 meaningful action까지 시간
- 오조작
- focus 상실
- 도움/설명 필요 여부
- 잘못 읽은 affordance
- failure에서 회복 가능한지

## 15. 금지 Shortcut

이 Kit에서 에이전트가 가장 싸게 도망갈 수 있는 구현을 구체적으로 적는다.

- [ ] placeholder ColorRect/Label world
- [ ] 상시 키 설명
- [ ] 버튼 목록으로 world interaction 대체
- [ ] content별 if/match
- [ ] 레퍼런스 미확인 상태에서 임의 UI
- [ ] 자동 테스트만으로 완료 선언
- [ ] 
- [ ] 

## 16. 완료 증거

구현 완료 보고에 반드시 첨부/기록:

- [ ] Primary Reference 상태별 비교
- [ ] 10분+ 실측 Reference Game
- [ ] authored content 추가가 core 무수정
- [ ] 720p/FHD/QHD 캡처
- [ ] 자동 테스트 결과
- [ ] save/load/retry 검수
- [ ] 상시 Shell HUD 없음
- [ ] Input Bubble 필요 구간 검수
- [ ] 이미지 자산 출처·라이선스 및 확정된 제작 기준 audit
- [ ] 사용자 플레이 **검토 준비 완료**

사용자 실제 검토 전에는 “최종 완성”이라고 쓰지 않는다.
