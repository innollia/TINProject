# Kit 05 — Query World Kit

> 공통 계약: `docs/KIT_WORKFLOW.md`
> 방향 확정 근거: `docs/research/novel_genre/QUERY_WORLD_KIT_DIRECTION_2026-09-27.md`
> 조사 정본: `docs/research/novel_genre/GENRE_INVENTION_SURVEY_2026-09-26.md`, `AWARD_IDEA_CATALOG_2026-09-26.md`

## 0. Kit 목적

- TINProject 안에서 **"질의로만 드러나는 세계"** 장르 구간을 즉시 만들기 위한 Kit다. 플레이어는 캐릭터를 움직이지 않는다. **무엇을 검색하고 어디에 커서를 대느냐**로 보이지 않던 세계를 조각조각 밝혀 나간다.
- 이 Kit를 쓰면 실제 콘텐츠 개발에서 다음을 새로 만들지 않아도 된다: 검색어→파편 매칭 엔진, 질의 이력 추적, hover 국소 노출 레이어, 파편(fragment) 데이터 포맷, 노출 진행도 저장.
- 이 Kit가 다루지 않는 것: 캐릭터 이동/물리, 실시간 전투, 3D 공간 탐험, 상시 HUD. 세계는 "공간"이 아니라 "질의 가능한 데이터 표면"이다.

## 1. Primary Reference — 정확히 하나

**게임:** Her Story
**개발사/제작자:** Sam Barlow
**출시/잼 맥락:** 2015년 정식 출시. 검색 기반 내러티브 장르를 사실상 발명한 작품.
**공식/신뢰 가능한 reference source:**
- https://en.wikipedia.org/wiki/Her_Story_(video_game)
- https://www.gamedeveloper.com/design/deep-dive-i-telling-lies-i---making-a-mechanic-out-of-scrubbing-video
- https://kairos.technorhetoric.net/21.2/reviews/karabinus-batti/basics.html

### 1.1 상태별 레퍼런스 증거

| 상태 | 실제 reference URL/자료 | 눈으로 확인할 것 | TIN에서 그대로 가져갈 규칙 |
|---|---|---|---|
| first playable frame | Wikipedia gameplay 절 | 검색창 하나 + 시드 검색어 "MURDER"가 이미 입력됨 | 첫 화면에 시드 질의 하나를 미리 넣어 검색 행위를 자연 학습시킨다 |
| normal play | GameDeveloper deep dive | 검색어 입력 → 매칭 파편 목록 반환 → 파편 열람 | 단어 입력이 유일한 능동 조작. 파편에서 새 단어를 뽑아 재질의 |
| focus / selection / direct manipulation | Kairos review "basics" | 결과 목록에서 한 파편을 선택해 열람, 나머지는 흐릿 | 선택된 파편 = focus 첫 클래스 상태. 선택 안 하면 아무것도 열리지 않음 |
| core mechanic change | GameDeveloper deep dive | 결과 개수 상한(원작 5개)이 "더 좁혀 물어라"를 강제 | 상한 초과 질의는 "너무 넓다" 신호를 주고 일부만 노출 |
| unavailable / failure | Wikipedia gameplay 절 | 매칭 0건이면 빈 결과 | 매칭 없는 질의도 "이력"에 남아 진행 단서가 됨(실패가 정보) |
| success / completion | Wikipedia 구조 절 | 명시적 승리 조건 없이 "이해에 도달"이 완료 | authored case별로 "핵심 파편 N개 노출 + 결론 질의" 도달을 완료로 정의 |
| menu/detail if core | Kairos review | 파편 상세 = 화면 대부분을 차지하는 열람 뷰 | 상세 열람이 곧 월드. 별도 detail UI 아님 |
| level/scene transition | (TIN 자체 계약) | — | case→case 전환은 검색 DB 교체로 표현(뭉탱이 인계는 §11·뭉탱이 문서) |

한 URL을 여러 상태에 쓰되, 실제 화면 재조사를 2026-09-27 수행해 아래 사실을 확정했다(§1.4).

### 1.4 실제 화면 재조사 결과 (2026-09-27 확정)

복수 신뢰 출처로 확인한 사실 — 이 값들을 계획에 못박는다.

| 확정 사실 | 내용 | 출처 |
|---|---|---|
| **결과 상한 = 정확히 5** | 몇 개가 매칭되든 처음 5개만 표시. "더 좁혀 물어라"를 강제하는 핵심 규칙 | tvtropes / roboheartbeat / mechanicsofmagic (복수) |
| **시드 = "MURDER"** | 첫 화면에 이미 입력되어 검색 행위를 자연 학습 | Her Story 통설 |
| **노출 추적 색 코드** | 별도 DB 뷰: **초록=열람함 / 빨강=미열람 / 노랑=마지막으로 본 것.** 정확한 내용은 안 알려주고 "얼마나 봤나"만 | giantbomb |
| **레이아웃** | 레트로 데스크톱 셸 + 메인 창 하나(검색+결과 집계 앱), 그 아래 별도 소형 앱이 "본 클립 추적" | wordpress / strategywiki / giantbomb |
| **질의·결과수 추적** | 게임이 모든 검색어와 결과 개수를 기록(노출 여부 무관) | kairos "basics" |

TIN 반영: 결과 상한 5를 그대로 채택. 노출 추적을 초록/빨강/노랑 색 코드로 채택하되 **상시 HUD 아닌 별도 호출 뷰**로 둔다(TIN UI 원칙). 원작 영상/배우/사건은 복제 안 함 — 시스템 규칙만.

한 URL을 여러 상태에 쓰되, 실제로 그 상태가 자료에 보여야 한다.

### 1.2 강하게 복제할 것

- 시스템: 키워드 검색 → 파편 반환 → 재질의 루프. 결과 개수 상한으로 "좁혀 묻기" 강제.
- 입력 감각: 텍스트 입력 + Enter. 마우스/커서로 파편 선택·hover.
- 카메라/보드/공간: 없음. 세계는 검색 인터페이스 표면.
- 정보 노출: 기본 은폐. 질의(검색어=능동, hover=국소)로만 노출.
- focus/selection: 선택된 파편이 유일한 열람 대상. focus 없으면 세계 닫힘.
- feedback: 매칭 수, 이미 본 파편 표시, 질의 이력.
- retry/undo/reset: 질의는 되돌릴 필요 없음(재입력이 곧 새 질의). 이력은 누적.
- 콘텐츠 구조: case = 파편 묶음 + 태그(검색어) 색인 + 완료 조건.

### 1.3 복제하지 않을 고유 저작물

- 원작 asset: Her Story의 영상 클립/배우/음성 일절 사용 안 함.
- 원작 캐릭터: Hannah 등 등장인물 사용 안 함.
- 원작 문구: 대사·자막 복제 안 함.
- 원작 레벨/맵 배치: 원작 사건·타임라인 복제 안 함.
- 원작 고유 이름/세계관: 사용 안 함. 검색-노출-재질의 **시스템 원리만** 가져온다.

## 2. 현재 코드 감사

### 2.1 살릴 후보

| 경로/시스템 | 살릴 이유 | 반드시 다시 검증할 것 |
|---|---|---|
| `core/` ModuleContext / 입력 폴링 계약 | Kit 공통 런타임 계약 | 텍스트 입력 경로가 ModuleContext로 들어오는지 |
| `core/` 버전 있는 JSON-safe save 유틸(있으면) | 질의 이력·노출 상태 저장에 재사용 | 스키마 버전·sanitize 경로 |
| `modules/game_library/` 목록 UI 패턴(참고만) | 파편 목록 렌더 참고 | 재사용 아닌 참고 — 새 GameModule로 신규 작성 |

### 2.2 버릴 것

| 경로/표현/구조 | 버리는 이유 |
|---|---|
| Retired Prototype 전체 | 아이디어·대사·UI 재사용 금지(AGENTS.md) |
| 상시 HUD/좌상단 상태뭉치류 | UI 원칙 위반 |

기존 코드라는 이유만으로 보존하지 않는다. 새 `modules/query_world/`로 신규 작성한다.

## 3. Reference Game — 최소 10분

### 3.1 장르의 Authored Content 단위

**이 Kit의 단위:** `case`(사건 하나) = 파편(fragment) 묶음 + 검색어 색인 + 완료 조건.

### 3.2 10분 플레이 흐름

| 순서 | authored content | 새로 검증하는 시스템 | 이전 시스템 재사용 |
|---:|---|---|---|
| 1 | case A: 시드 검색어로 첫 파편 3개 노출 | 검색→매칭→열람 루프 | — |
| 2 | case A: 파편에서 뽑은 새 단어로 재질의 | 재질의·이력 추적 | 검색 루프 |
| 3 | case A: hover로 파편 속 국소 단서 노출 | hover 국소 질의 레이어 | 검색·이력 |
| 4 | case A: 결과 상한 초과 → "좁혀 묻기" 신호 | 결과 상한·좁히기 유도 | 검색·hover |
| 5 | case A: 핵심 파편 N개 노출 + 결론 질의 → 완료 | 완료 판정 | 전부 |
| 6 | case B: 다른 사건, **같은 엔진**에 새 데이터만 | (엔진 무수정 증명) | 전부 |
| 7 | case B: 파편끼리 모순되는 단서(신뢰성 판단) | 파편 간 관계/모순 표기 | 전부 |
| 8 | case C: 시드 없이 시작(플레이어가 첫 질의 발명) | 시드 없는 진입 난이도 | 전부 |

대기/이동/HP/대사량으로 10분을 채우지 않는다. 서로 다른 case를 물으며 시간이 찬다.

### 3.3 하드코딩 방지량

- 서로 다른 authored 단위 최소 수: **case 3개 이상** (A/B/C).
- 같은 subsystem 재사용: 3 case 모두 동일 검색·hover·완료 엔진 사용.
- 마지막 증명: case D를 **데이터 파일 하나만 추가**해 core 무수정으로 붙인다.

## 4. Domain / State

```text
QueryWorldState (versioned, JSON-safe)
├─ case_id: StableId
├─ fragments: { fragment_id -> Fragment }   # authored, 불변
│    Fragment:
│      id: StableId
│      body: rich text (표시용 파편 본문)
│      search_tags: [String]                # 이 파편이 매칭되는 검색어(색인)
│      hover_reveals: [{ span, hidden_text }]# hover 시 국소 노출되는 조각
│      relations: [{ to_fragment_id, kind }] # supports/contradicts/mentions
├─ query_history: [ QueryEvent ]            # runtime, 진행도
│    QueryEvent: { raw_query, matched_ids:[], result_count, ts }
├─ revealed: Set<fragment_id>               # runtime, 한 번이라도 연 파편
│    # 노출 추적 색: 초록=revealed, 빨강=미열람, 노랑=마지막 열람(Her Story 색 코드 채택)
├─ hover_seen: Set<hover_reveal_id>         # runtime
├─ last_opened: fragment_id | null          # 노랑 표시 대상
└─ completion: { required_ids:[], concluded:bool }  # authored 조건 + runtime 달성

RESULT_CAP = 5   # 확정: 매칭이 몇이든 처음 5개만 반환(Her Story 규칙 채택)
```

필수:
- stable IDs: fragment_id / case_id는 authored 불변 문자열.
- runtime state: query_history, revealed, hover_seen, completion.concluded.
- transient presentation state와의 경계: 현재 검색창 텍스트, 흐림 애니메이션, 커서 위치는 저장 안 함.
- invalid/stale state: 저장된 revealed에 없는 fragment_id가 있으면 drop하고 로그. relations의 dangling ref는 로드 시 sanitize.

## 5. Authored Content Format

| content type | 파일 형식 | 필수 필드 | validation | core 수정 없이 추가? |
|---|---|---|---|---|
| case | JSON (`res://modules/query_world/cases/<id>.json`) | id, title, seed_query(optional), fragments[], completion.required_ids, completion.conclusion_query | id 유일성, required_ids ⊆ fragments, search_tags 비어있지 않음, relations의 to_id 존재 | 예 — 파일 추가만으로 등록 |
| fragment | 위 case JSON 내 배열 원소 | id, body, search_tags[] | id 유일, hover_reveals span 범위 유효 | 예 |

전용 editor는 요구하지 않는다. JSON 스키마 + 로드 시 validation으로 충분.

## 6. 핵심 시스템

**QueryEngine**
- 입력: raw_query(문자열), 현재 case.
- 출력: 매칭 fragment_id 목록(정규화·부분일치·결과 상한 적용).
- side effect: query_history append, result_count 기록.
- 실패 atomicity: 매칭 0건도 정상 이벤트(이력에 남김). 예외 아님.
- 순서 의존성: 없음. 각 질의는 독립.
- determinism: 같은 case + 같은 query → 항상 같은 결과(자동 테스트 가능).

**HoverRevealLayer**
- 입력: 열람 중 파편 + 커서가 가리키는 span.
- 출력: 해당 span의 hidden_text 노출.
- side effect: hover_seen append.
- determinism: 예.

**CompletionEvaluator**
- 입력: revealed set + 마지막 결론 질의.
- 출력: completion.concluded true/false.
- 판정: required_ids ⊆ revealed AND 결론 질의가 conclusion_query와 매칭.

### 처리 순서

1. 플레이어 검색어 입력 → QueryEngine 매칭 → 결과 목록 갱신 → query_history 기록.
2. 결과에서 파편 선택(focus) → 열람 뷰 표시 → revealed 추가.
3. 열람 중 hover → HoverRevealLayer 국소 노출 → hover_seen 기록.
4. 매 질의/노출 후 CompletionEvaluator 재평가 → 완료면 전환 신호.

## 7. Input

### 7.1 Game actions

| intent | InputMap action | gameplay 의미 |
|---|---|---|
| 검색어 입력 | 텍스트 필드(문자 입력) | 능동 질의 |
| 질의 실행 | `qw_submit` (Enter) | 검색 확정 |
| 파편 선택 | `qw_select` (클릭/Enter on 목록) | focus 이동·열람 |
| 국소 노출 | hover (마우스) / `qw_peek`(키보드 커서) | hover 질의 |
| 열람 닫기 | `qw_back` (Esc/Backspace) | 목록으로 복귀 |

물리 키는 domain에 넣지 않는다. intent만 저장.

### 7.2 장르 전환 Input Bubble

- 이전 구간의 required physical keys: (뭉탱이 상 직전 Kit에 따라 다름 — 예: 이동 WASD)
- 이 구간의 required physical keys: **문자 입력 전체 + Enter + Esc + 마우스 hover**. 이동/점프/사격 키는 이 구간에서 불필요.
- restore되는 bubble: Enter, Esc (대개 다음 구간에도 쓰임).
- rising bubble: 문자 입력(A~Z 등) — "이제 타이핑이 조작이다"를 아래에서 올라오는 방울로 학습.
- popped 흔적: 이동/사격 키는 터진 흔적으로 남겨 "여기선 안 쓴다"를 시각적으로 표시.
- bubble 완료 조건: 첫 유효 질의 1회 실행(시드 검색어 재입력 포함).

설명문으로 키 기능을 해설하지 않는다. 방울과 실제 입력으로 학습.

## 8. Save / Load / Retry

저장:
- QueryWorldState의 runtime 부분(query_history, revealed, hover_seen, completion.concluded)을 버전 있는 JSON으로 저장.

load sanitize:
- fragment_id/relation dangling ref drop + 로그.
- 스키마 버전 불일치 시 마이그레이션 또는 안전 초기화.

retry/reset/undo:
- reset: 해당 case의 runtime state 초기화(파편은 불변이라 그대로).
- undo 불필요: 질의는 재입력으로 대체. (단 "직전 열람으로 돌아가기"는 qw_back으로 제공)

실패 중간 상태:
- 저장 중 크래시 대비 원자적 쓰기(temp→rename). 매칭 0건은 실패 아님.

## 9. Presentation

### 9.1 화면의 주인공

- 첫 1초: **검색창 하나 + 시드 검색어**. 그 외 화면은 거의 빔(어둠).
- UI보다 우선하는 world element: 열람 중인 파편 본문(선택되면 화면 대부분 차지).
- 상시 표시가 정말 필요한 정보: 검색창, 현재 결과 목록. (Primary Reference에서 항상 필요)
- 호출할 때만 보이는 정보: 파편 상세, hover 국소 단서, 질의 이력, **노출 추적 뷰(초록=열람/빨강=미열람/노랑=마지막)** — Her Story의 별도 추적 앱을 채택하되 상시 HUD가 아니라 호출 시에만 연다.

### 9.2 월드 이미지 자산

| object | asset source | 제작/변형 방법 | silhouette 목표 |
|---|---|---|---|
| 검색 인터페이스 프레임 | 신규 제작(프로젝트 아트 층) | GPT 생성 + 기계적 정렬 | "낡은 조회 단말/기록 열람기" 느낌의 단일 실루엣 |
| 파편 카드 배경 | 신규 제작 | GPT 생성 | 문서/기록 조각다운 질감 |
| hover 노출 하이라이트 | 코드 렌더(이미지 최소) | 셰이더/스타일 | 손전등이 비춘 국소 영역 |

세부 계약은 `docs/KIT_WORKFLOW.md` 톤앤매너·이미지 명세 및 `docs/IMAGE_ASSET_WORKFLOW.md`를 따른다. 자산이 늘면 `plans/kits/05_QUERY_WORLD_KIT_VISUAL.md`로 분리하고 여기서 링크한다.

### 9.2.1 Kit별 톤앤매너

- 적용할 개인 화풍 코어 버전과 프로젝트 아트 층 문서: `docs/VISUAL_DIRECTION.md` 기준(구현 착수 시 버전 확정).
- 세계·시대·재질·형태·색 관계·조명·정서: 어두운 배경 위 국소 조명. "정보를 캐내는" 차갑고 건조한 톤.
- Primary Reference 카메라·밀도·정보 순서·UI 표현: Her Story식 저밀도 — 화면 대부분 비우고 검색·파편만.
- 원작 자산·모티프와 구분: 영상 대신 텍스트/기록 파편. 원작 UI 스킨 복제 금지.
- 배경 오브젝트 3분류: 검색창·파편(증거·직접 상호작용) / 결과 목록·이력(길찾기·상황 이해) / 배경 질감·조명(분위기).
- 스타일·가독성 확인 장면: 파편 열람 + hover 노출이 동시에 걸린 화면.

### 9.2.2 이미지 제작 명세

자산 수가 적어 이 문서에 유지. 구현 착수 시 아래 표를 채운다(계획 승인 전 필수 항목은 §9.2.1로 충족).

| asset ID·자산군 | 게임 상태·용도 | 장면/오브젝트 정본 | 생성·편집 입력과 Gold Standard | 출력 규격·피벗·레이어 | 정확한 문자·시각 단서 처리 | 검수 장면 |
|---|---|---|---|---|---|---|
| (구현 착수 시 채움) |  |  |  |  |  |  |

- 재등장 요소 고정 특징: 검색 프레임 형태 일관.
- 생성/편집과 기계적 후처리 경계: 투명화·크롭·정렬만 후처리.
- 출처·권리 기록: 자산 매니페스트에 기록.
- 하드 게이트: 720p/FHD/QHD 실제 화면 판정.
- 사용자 시각 승인 지점: 첫 case 플레이 화면 캡처.

### 9.3 Focus / Selection

- default focus: 검색창.
- focus 표시: 검색창 활성 테두리 / 선택 파편 강조.
- mouse: 파편 클릭 선택, hover 국소 노출.
- keyboard/controller: 결과 목록 방향키 이동 + Enter 선택 + qw_peek로 hover 대응.
- target 제거 시 fallback: 선택 파편 없으면 목록으로, 목록 비면 검색창으로.
- screen close 후 restore: 마지막 focus 복원.

## 10. 화면 상태

| screen | initial | normal | focus | active | unavailable/failure | success | return |
|---|---|---|---|---|---|---|---|
| 검색 화면 | 검색창+시드어 | 결과 목록 표시 | 검색창 or 목록 항목 | 파편 열람 뷰 | 매칭 0 "결과 없음"(이력엔 남음) | 완료 파편 도달 표시 | case 전환 신호 |
| 파편 열람 | — | 본문 전체 | 커서 대상 span | hover 노출 중 | 손상 파편 sanitize 표시 | 핵심 파편 열람 체크 | qw_back로 목록 |

## 11. Shell 관계

- 플레이 중 Shell persistent HUD: **없음**.
- Esc 메뉴 호출 시: 표준 Esc 메뉴만(재개/설정/종료). 게임 상태 소유 안 함.
- 메뉴 닫을 때: 마지막 focus·검색 상태 복원.
- Journal/기록: 질의 이력은 이 Kit의 domain state이지 Shell Journal이 아니다. Shell로 빼지 않는다.
- Shell이 gameplay 정보를 소유하지 않음: 확인.

## 12. 해상도

실제 캡처:
- [ ] 1280×720
- [ ] 1920×1080
- [ ] 2560×1440

각 해상도:
- [ ] 검색창+결과 목록 레이아웃 유지
- [ ] focus 보임
- [ ] 파편 본문 겹침/잘림 없음
- [ ] 긴 검색어/최대 결과 수/긴 파편 본문
- [ ] hover 노출 위치 정확
- [ ] Esc 메뉴 open/close 복귀

## 13. 자동 테스트

### domain/system
- [ ] QueryEngine: 같은 case+query → 결정적 결과
- [ ] 결과 상한 초과 시 좁히기 신호
- [ ] hover span → 정확한 hidden_text 노출
- [ ] CompletionEvaluator: required_ids 충족 판정

### content pipeline
- [ ] 새 case JSON 추가 → core 무수정 로드
- [ ] invalid case(빈 search_tags, dangling relation) reject/sanitize
- [ ] duplicate fragment_id 거부

### save
- [ ] round-trip(query_history/revealed/hover_seen/completion)
- [ ] stale fragment_id drop
- [ ] reset이 runtime만 초기화, authored 파편 보존

### UI contract
- [ ] focus 이동(검색창↔목록↔파편)
- [ ] qw_back 복귀
- [ ] 매칭 0 시 열람 불가
- [ ] domain state → 화면 상태 반영

## 14. 수동 플레이 과제

설명 없이 실제로 시킬 일:

1. 시드 검색어만 주고 첫 파편에서 새 단어를 스스로 뽑아 재검색하게 한다.
2. 파편 본문에 hover해 숨은 단서를 찾게 한다(툴팁이 유일한 시야임을 스스로 깨닫는지).
3. 서로 모순되는 두 파편을 찾아 어느 쪽을 믿을지 판단하게 한다.

관찰:
- 첫 meaningful 질의까지 시간
- 검색창 말고 이동키를 누르려 하는지(장르 오인)
- hover의 존재를 스스로 발견하는지
- 매칭 0 실패에서 다른 단어로 회복하는지
- 완료 조건(결론 질의)을 설명 없이 도달하는지

## 15. 금지 Shortcut

- [ ] placeholder ColorRect/Label을 파편으로 완료 처리
- [ ] 상시 키 설명/조작 안내문으로 검색·hover 해설
- [ ] 버튼 목록으로 "검색" 대체(자유 텍스트 입력이 핵심)
- [ ] case별 if/match 분기로 엔진 오염(데이터 주도여야 함)
- [ ] Her Story 화면 미재조사 상태로 임의 UI 확정
- [ ] 자동 테스트만으로 완료 선언(수동 플레이·해상도 캡처 필수)
- [ ] hover를 "설명 툴팁"으로 격하(국소 질의여야 함)
- [ ] 질의 이력을 Shell HUD로 상시 노출

## 16. 완료 증거

- [ ] Primary Reference(Her Story) 상태별 비교 캡처
- [ ] 10분+ 실측 Reference Game(case A/B/C + D 데이터 추가 증명)
- [ ] authored case 추가가 core 무수정
- [ ] 720p/FHD/QHD 캡처
- [ ] 자동 테스트 결과
- [ ] save/load/reset 검수
- [ ] 상시 Shell HUD 없음
- [ ] Input Bubble(타이핑 rising / 이동 popped) 검수
- [ ] 이미지 자산 출처·라이선스 및 확정 제작 기준 audit
- [ ] 사용자 플레이 **검토 준비 완료**

사용자 실제 검토 전에는 "최종 완성"이라고 쓰지 않는다.

## Unverified / 구현 착수 전 차단 항목

- Her Story 화면 재조사는 2026-09-27 완료(§1.4): 결과 상한 5, 시드 "MURDER", 초록/빨강/노랑 노출 추적, 레트로 데스크톱+메인 검색창+별도 추적 뷰 확정. **UI 규칙 게이트 해제.**
- 남은 확인: 정확한 픽셀 배치(창 위치/여백)는 구현 시 실제 게임 실행 캡처와 나란히 비교해 미세 조정한다. §9·§10의 원리·요소·색 코드는 확정.

## 구현 현황 (2026-09-27)

작성 완료(직접 인라인, 서브에이전트 미사용):

| 파일 | 역할 |
|---|---|
| `modules/query_world/domain/query_world_state.gd` | 순수 도메인: Fragment 모델 + QueryEngine(결과 상한 5) + HoverRevealLayer + CompletionEvaluator + JSON-safe save/load(stale drop) |
| `modules/query_world/domain/query_world_content_loader.gd` | case JSON 발견·검증·목록화 (파일 추가만으로 등록, core 무수정) |
| `modules/query_world/content/a_missing_lamp.json` | case A (시드 있음, 모순 단서, hover) |
| `modules/query_world/content/b_quiet_ferry.json` | case B (같은 엔진, 새 데이터) |
| `modules/query_world/content/c_no_seed_letter.json` | case C (시드 없음) |
| `modules/query_world/presentation/query_world_screen.gd` | 표현층: 검색창+절차적 조회단말 프레임 / 5-cap 결과목록 / 파편 열람+hover 국소노출 / 초록·빨강·노랑 추적 뷰 / 절차적 어둠 배경. 상시 HUD·아이콘 없음 |
| `modules/query_world/module.gd` | GameModule: enter/exit/save/load, action→intent, 시드 질의 1회, 완료 latch(중복 finished 방지) |
| `modules/query_world/entry.tscn`, `module_manifest.tres` | 씬·매니페스트 |
| `tests/core/test_query_world.gd` | 도메인 GUT 18 테스트 (§13 전부) |
| `tests/core/test_query_world_module.gd` | 모듈 계약 GUT 10 테스트 |
| `app/app_root.gd` | NORMAL_IDS + ROUTES에 query_world 등록(입력 액션 자동 생성) |

**검증 완료 (2026-09-27, Godot 4.7.2-stable):**
- editor --import → exit 0, parse 에러 없음
- run_tests.gd → **644/644** (기존 baseline 무손상 — query_world 등록이 아무것도 깨지 않음)
- GUT core → **338/338, 0 실패** (query_world 도메인 18 + 모듈 10 테스트 포함)
- smoke(--quit-after 180 --fixed-fps 60) → exit 0, 런타임 에러 없음
- 해상도 캡처 3종 생성: `tests/performance/captures/query_world_{1280x720,1920x1080,2560x1440}.png`. 720p 캡처에서 어둠 배경·조회단말 프레임·시드 "등불"·2건 결과·A1 focus·A2 미열람(빨강) 정상 렌더 확인. (FHD/QHD는 캡처 시 물리 모니터 크기로 클램프됨 — 레이아웃은 Container/anchor 기반이라 스케일되며, 정확한 대형 해상도 검수는 실제 대형 디스플레이에서 재확인 필요.)

정적 검토로 잡아 수정한 것: `FlowContainer`(추상, 인스턴스 불가) → `HFlowContainer`; 표현층이 domain을 변경하던 경로 제거(read-only 렌더); 완료 중복 발화 방지 latch + enter/reset 리셋. 검증 중 잡아 수정: 헤드리스 grab_focus 접근성 경고 → `_focus()` 가드; 진입 시드 질의를 고려하도록 테스트 정리.

**남은 것(사용자 검토 단계):** Primary Reference 나란히 비교, 10분 실측 플레이(case A/B/C + D 데이터 추가 증명), 실제 대형 디스플레이 해상도 수동 검수, 사용자 직접 플레이 검토.
