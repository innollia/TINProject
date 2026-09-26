# Rule Rewrite Kit 실제 레퍼런스 조사 보고서

> 2026-09-24 검토 상태: **보완 완료, Rule Rewrite Kit grilling 입력으로 사용 중**. 사용자 촬영 스크린샷 10장을 확보했고 후속 그릴링 에이전트가 원본을 직접 판독했다. 오브젝트·단어·속성·문법은 팬덤 위키의 전체 카탈로그와 모딩 가이드까지 조사 범위를 넓혔다. 정지 화면으로 알 수 없는 모션·음향·입력 반복과 실제 플레이로 검증하지 않은 복합 처리 순서는 계속 미확인으로 남긴다.
>
> 8절의 사용자 질문 목록도 그대로 grilling에 사용하지 않는다. 복수 YOU 이동, undo/reset 등의 원작 문법은 에이전트가 자료로 확인할 사항이다. 지원 범위 질문은 전체 목록 조사 후 실제 설계상 선택이 남을 때 제시한다. 위키에서 확인 가능한 규칙을 모두 사용자 직접 실험 과제로 넘기지 않는다.
>
> 보완 순서: 에이전트가 UI 촬영 목록 작성 → 사용자 스크린샷 수집·분석. 이와 독립적으로 에이전트가 전체 항목 목록·분류·개별 출처·버전 차이·조사 상태를 정리한다. 모션·소리·입력 반복처럼 스크린샷만으로 알 수 없는 항목은 별도 증거가 필요한 상태로 표시한다. 공식 업데이트는 전체 목록의 변경 사항을 대조하는 데 사용한다.
>
> UI 자료 처리: 사용자가 10장의 화면 캡처와 설명을 제공했다. 원본은 `docs/research/rule_rewrite/`에 보존하고 사용자의 설명을 그대로 목록화한다. 요청에 따라 이미지 내용은 이 보고서 작성자가 해석·주석하지 않았으며, UI 레퍼런스 목적상 게임 버전은 포함 여부나 UI 평가 기준으로 삼지 않는다. 후속 실무자와 검토자가 원본을 직접 살핀다.

- 조사 기준일: 2026-09-24
- Primary Reference: Baba Is You 하나
- 사용 목적: 후속 Rule Rewrite Kit별 grilling 및 초상세 계획서의 조사 입력
- 작업 경계: 조사와 보고서 작성만 수행. 구현, 기존 Kit 계획 수정, 테스트 실행, 패키지 설치, 커밋은 하지 않음.

## 1. 조사 범위와 실제 확인 수준

### 확인한 것

지정된 설계·워크플로·아키텍처 문서를 읽고, 기존 계획을 가설 목록으로만 사용했다. modules/rule_rewriting/**와 직접 관련된 도메인, 시스템, authored level JSON, 모듈 및 tests/core/test_rule_{parser,evaluator,movement,level_loader}.gd, tests/core/test_cycle4_modules.gd의 관련 부분을 읽었다. Retired Prototype은 조사하지 않았다.

실제 플레이 화면은 제3자 2019년 플레이 영상의 첫 구간에서 브라우저 화면으로 확인했다. 이 영상은 업로더가 첫 플레이라고 밝힌 영상이며, 영상 설명은 당시 일부 퍼즐이 조정·변경됐다고 알린다. 화면 관찰은 첫 보드와 화면에 표시된 입력 힌트 정도로 제한된다. 플레이어가 실제로 어떤 방향 입력을 했고 어떤 상태 변화를 일으켰는지를 특정할 수 있는 연속 장면, 규칙이 끊기는 장면, 막힘·실패·성공·undo·reset·메뉴 조작은 이 조사에서 확인하지 못했다. 영상 편집으로 생긴 컷을 게임의 전환 연출 증거로 취급하지 않는다.

현재 상용판을 직접 플레이하거나 설치하지 않았다. 공식 페이지와 개발자 자료, 커뮤니티 규칙 자료를 화면 관찰과 구분해 사용했다. 따라서 본 보고서는 “Baba Is You 전체를 직접 검증한 플레이 분석”이 아니다. 2019년 화면 증거와 현재 제품·공식 업데이트 정보가 서로 다른 시점이라는 점도 유지한다.

### 증거 표기

- **[화면 관찰]** 브라우저에서 실제 영상 프레임을 본 것. 영상이 보여 준 부분만 지지한다.
- **[공식 자료]** 개발자 또는 공식 배포 페이지가 명시한 것. 실제 플레이를 대신하지 않는다.
- **[커뮤니티 자료]** 위키·공략의 설명. 개별 세부 규칙은 게임에서 재현하기 전까지 확정 판정으로 사용하지 않는다.
- **[코드 확인]** 현재 TIN 소스의 실제 구현.
- **[테스트 명세]** 테스트 코드에 assertion/시나리오가 있다는 뜻. 테스트가 통과했다는 뜻이 아니다.
- **[추론]** 관찰·자료·코드에서 도출한 설계상 해석.
- **[미확인]** 근거가 충분치 않거나 직접 실험이 필요한 항목.

### 실행 및 산출물 한계

- 테스트와 Godot 실행 명령은 실행하지 않았다. 아래 테스트 평가는 테스트 코드의 존재와 내용을 읽은 결과뿐이다.
- 브라우저 화면은 인라인으로 확인했으며 이 인터페이스에서 로컬 캡처 파일로 저장하지 못했다. 따라서 docs/research/rule_rewrite/ 캡처 디렉터리와 캡처 경로는 없다. 아래 증거 인덱스에는 확인한 영상 시각과 화면 상태를 기록했다.
- 영상 플레이어 폭이 좁게 표시된 상태여서 픽셀 단위 보드 비율, 타일 크기, 720p/FHD/QHD에서의 실제 레이아웃을 측정하지 않았다.

## 2. 출처 목록 및 증거 인덱스

### 출처

| ID | 출처와 성격 | 보고서에서 사용한 범위 | 한계 |
|---|---|---|---|
| S1 | [Baba Is You 공식 사이트](https://hempuli.com/baba/) | 규칙 문장이 물리 오브젝트이며 배치·조작에 따라 게임 동작이 바뀐다는 제품 설명 | 화면·전체 규칙집·현재 플레이 검증을 대신하지 않음 |
| S2 | [공식 itch.io 상용판 페이지](https://hempuli.itch.io/baba) | 상용판의 공식 배포 정보, 키보드/컨트롤러와 재설정 가능한 조작, 접근성 설명, 페이지의 업데이트 일자 | 본 조사에서 상용판을 구매·실행하지 않음. 페이지 정보가 현재 실행 파일의 모든 세부를 증명하지 않음 |
| S3 | [공식 버전 481d 업데이트 노트](https://hempuli.itch.io/baba/devlog/1285463/version-481d) | 2026-01-02 게시 버전의 새 오브젝트·단어 및 모드 지원 추가 목록. Bean/Fox/Chili/Hotdog/Brain/Rook/Bone/Cactus/Palm/Yes/No 및 Become/Facedby/Hold/Happy/Angry가 명시됨 | 해당 단어의 전체 의미·충돌 순서는 여기서 검증하지 않음 |
| S4 | [공식 레벨 에디터 출시 안내](https://hempuli.itch.io/baba/devlog/315102/official-level-editor-releasing-on-november-17th) | 에디터·공유·추천 목록과 150개 이상 신규 및 100개 이상 잘린 레벨이 언급된 콘텐츠 규모·저작 지원 | 레벨 수는 Kit의 최소 분량이나 에디터 요구사항을 뜻하지 않음 |
| S5 | [공식 2017 Jam 빌드](https://hempuli.itch.io/baba-is-you) | 초기 프로토타입 배포 페이지의 방향키, Z undo, R restart, Esc 종료, F1 전체화면 안내 | 상용판 조작과 같다고 일반화하지 않음 |
| S6 | [실제 플레이 영상: ScorpVerse, Part 1](https://www.youtube.com/watch?v=SfNlJkJEEOw) | E01–E03 화면 증거. 영상 제목은 “Flag is Win”; 영상 설명은 첫 플레이·2019년 영상 및 일부 조정된 퍼즐을 고지 | 제3자 영상, 2019년 스냅샷, 일부 컷 편집. 2026년 현재판이나 전체 흐름 증거가 아님 |
| S7 | [개발자 Arvi Teikari 인터뷰](https://intoindiegames.com/features/2019-best-original-concept-winner-interview-arvi-teikari-baba-is-you/) | 아이디어 발생, Jam 당시 약 10레벨, 객체에 고정 속성을 두기보다 명시적 문장으로 속성을 부여한 설계, 초기 레벨 다듬기와 단일 기능 단어의 정리 | 매체 인터뷰를 통해 전달된 개발자 발언. 게임 실행 증거가 아님 |
| S8 | [GDC 발표 소개](https://www.gdcvault.com/play/1026628/Reading-the-Rules-of-Baba) | 개발자가 물리 단어에서 문장을 만들고 rule data structure로 구현한 이야기를 발표 주제로 삼았다는 소개 | 회원 전용 발표 영상은 시청하지 않음. 첨부 PDF도 열람하지 않았으므로 세부 구현 주장은 가져오지 않음 |
| S9 | [Baba Is You 위키: Properties](https://babaiswiki.fandom.com/wiki/Category:Properties) | 속성 카탈로그, 효과 요약, stack 여부, 편집기 목록 밖/제거/무효 속성 분리. MOVE 중첩은 이동 횟수를 더하고 YOU 중첩은 그렇지 않다고 설명 | CC-BY-SA 커뮤니티 편집 자료. 표는 모든 예외·턴 순서를 싣지 않으며 실행 파일 대조는 안 함 |
| S10 | [Baba Is You 위키: Order of Operations](https://babaiswiki.fandom.com/wiki/Order_of_Operations) | 턴 단계 개요, 단계 사이 재파싱, 개체 목록 우선순위와 같은 tick에서 같은 대상을 밀거나 당기는 충돌에 대한 설명 | CC-BY-SA 커뮤니티 편집 자료. 페이지는 매우 세밀하고 버전별 게임 코드 비교는 하지 않음. 본문에서 확인된 부분만 인용하며 화면 실험으로 검증하지 않은 하위 단계는 미확인으로 둠 |
| S11 | [Baba Is You 위키: Advanced Rulebook](https://babaiswiki.fandom.com/wiki/Advanced_rulebook) | 조합 규칙의 엣지 케이스를 찾는 보조 카탈로그 | 커뮤니티 자료. 이번 보완에서는 실제 열람/관찰 가능한 항목만 제한적으로 참조하며, 개별 상세 사례를 포괄적 규칙처럼 쓰지 않음 |
| S12 | [Walkthrough King: Baba Is You](https://www.walkthroughking.com/text/babaisyou.aspx) | 레벨 진행 중 AND, 변환, 복수 YOU, MOVE, DEFEAT, HAS, OPEN 같은 서로 다른 시스템이 콘텐츠에서 등장한다는 탐색 단서 | 비공식 공략이며 화면 관찰이 아님. 해법/레벨 배치 복제를 위한 자료가 아님 |
| S13 | [Baba Is You 위키: Nouns](https://babaiswiki.fandom.com/wiki/Category:Nouns) | 특수 명사, 일반 오브젝트 명사, 기본 오브젝트 목록 밖의 levelpack 전용 오브젝트와 게임/에디터 sprite 종류를 분류 | CC-BY-SA 커뮤니티 카탈로그. wiki에 수록된 레벨팩/에디터 오브젝트를 기본 캠페인의 전부와 동일시하지 않음 |
| S14 | [Baba Is You 위키: Operators](https://babaiswiki.fandom.com/wiki/Category:Operators) | Baba Is You levelpack, New Adventures, 미사용, 내부 operator를 나눠 verb/condition/AND/NOT을 분류. 문장 방향과 조건 문법을 확인 | CC-BY-SA 커뮤니티 카탈로그. 공식 현재 빌드의 사용 가능성을 혼자 확정하는 자료는 아님 |
| S15 | [Baba Is You 위키: Conditions](https://babaiswiki.fandom.com/wiki/Category:Conditions) | prefix/infix condition의 문법·결합·NOT 적용과 조건 복수 결합 예시 | CC-BY-SA 커뮤니티 규칙 페이지. 매우 복합적인 상호작용의 모든 구현 결과를 직접 재현하지 않음 |
| S16 | [Baba Is You 위키: YOU](https://babaiswiki.fandom.com/wiki/YOU) | YOU의 조작 의미, YOU가 0개가 되었을 때 음악 fade와 undo/restart 안내, YOU2 관련 제약 | CC-BY-SA 커뮤니티 규칙 페이지. 안내가 뜨는 정확한 프레임·스타일·현재 설정별 입력은 미확인 |
| S17 | [Baba Is You 위키: Advanced rulebook](https://babaiswiki.fandom.com/wiki/Advanced_rulebook) | 동시 이동·충돌의 예외 사례를 찾는 보조 색인 | 커뮤니티 자료. 직접 열람이 안정적이지 않은 개별 항목은 증거로 쓰지 않음 |
| S18 | [Baba Is You 위키: Special object](https://babaiswiki.fandom.com/wiki/Special_object) | 이동·undo·restart·pause 등 control 표시 special object 이름을 확인 | 커뮤니티 설명. UI에 실제로 어떤 label이 언제 나타나는지 확인한 화면 자료가 아님 |
| S19 | [Baba Is You 위키: Removed/Unused Content](https://babaiswiki.fandom.com/wiki/Unused_and_Removed_Content) | 제거·미사용 이름을 플레이 가능 문법 목록에서 분리하는 데 사용 | 커뮤니티 편집 자료. 특정 빌드에서 재사용된 경우 공식 업데이트와 함께 다시 대조해야 함 |
| S20 | [Baba Is You 공식 481d 업데이트 노트](https://hempuli.itch.io/baba/devlog/1285463/version-481d) | 공식적으로 추가한 11개 object 이름과 5개 word 이름을 확인하고 wiki 목록을 대조 | 2026-01-02 공식 배포 노트. 이름 추가는 모든 단어가 기본 편집기/캠페인에서 사용 가능하거나 같은 의미로 사용된다는 증거가 아님 |
| S21 | [Puzzle Genome Atlas: Baba Is You](https://puzzlegenome.org/en/games/baba-is-you/) | 2026-09-14 기준 검증된 상용판 규칙 기록. 한 방향 입력이 현재 YOU인 모든 개체를 대상으로 한다는 설명 및 기본 이동/규칙 갱신 계약 | 연구 카탈로그의 2차 자료. 해당 레코드가 직접 플레이하지 않았다고 밝히므로 실제 화면·소리·특정 충돌 결과를 대체하지 않음 |
| S22 | [Baba Is You rules guide](https://babaisyou.net/docs) | 방향키 이동/밀기, X/Z undo, R restart 등의 입력 표기와 기본 용어 | 비공식 안내. 플랫폼/설정 차이와 상용판 실제 리바인딩 화면은 별도 확인 필요 |
| S23 | [Baba Is You 위키: Word Templates](https://babaiswiki.fandom.com/wiki/Category:Word_Templates) | operator/property/noun 템플릿 인덱스를 교차 확인 | 커뮤니티 색인. 모든 단어를 기본 레벨팩 사용 가능성의 증거로 간주하지 않음 |
| S24 | [Baba Is You 위키: 3D](https://babaiswiki.fandom.com/wiki/3D) | 3D 대상의 시점·조작, 복수 3D 대상 선택, YOU/SELECT와의 동시 조작, EMPTY/LEVEL 예외 | CC-BY-SA 커뮤니티 규칙 페이지. 직접 플레이와 화면 검증은 하지 않았으며 시점을 설명하는 명칭이 페이지·분류 사이에서 일관되지 않음 |
| S25 | [Baba Is You 위키: WORD](https://babaiswiki.fandom.com/wiki/WORD), [Rule](https://babaiswiki.fandom.com/wiki/Rule) | 물리 오브젝트를 자신의 명사 TEXT처럼 문장에 참여시키는 WORD, 단순 자기유지 금지, 무한 루프/복잡도 실패 가능성 | CC-BY-SA 커뮤니티 규칙 페이지. 이미지로만 제시된 구체 예시는 이번 조사에서 복원하지 않음 |
| S26 | [PlasmaFlare Baba Modding Guide](https://github.com/PlasmaFlare/baba-modding-guide), [Parsing overview](https://github.com/PlasmaFlare/baba-modding-guide/blob/master/references/parsing.md) | `updatecode` 기반 재파싱, firstword 수집, 겹친 텍스트의 모든 조합 생성, syntax 검사와 부분 문장 재삽입, rule table 등록의 상위 구조 | 비공식·실험적 모딩 자료이며 저자도 완전한 문서가 아니라고 밝힘. 원작 Lua 소스를 대신하는 최종 명세로 사용하지 않음 |
| S27 | [Baba is Hint: Temple Ruins](https://www.keyofw.com/baba-is-blog/temple-ruins) | 2026-09-25 브라우저 확인. Baba Is You Temple Ruins의 Weak·HAS·MOVE 학습 순서, 속성 조합 질문, HAS 생성물 활용, 문장을 한 줄로 고정하는 설계 힌트와 1280×720 맵 캡처 | 스포일러 없는 팬/community 가이드와 힌트 질문이지 실제 플레이 영상·정답 경로·현재 원작 동작의 직접 증거가 아님. 화면 캡처는 참고 비교 자료로만 사용하고 TIN 구현 계약으로 사용하지 않음 |

### 카탈로그 증거의 판독 기준

이하 어휘표는 위키의 카테고리 인덱스 하나를 “기본 캠페인에 모두 사용 가능”으로 읽지 않도록 상태를 붙였다. 위키에는 본편 levelpack, New Adventures, editor-exclusive, internal, removed, unused, levelpack 고유 오브젝트가 함께 나타난다. 공식 481d 노트는 단어와 오브젝트의 이름 추가를 확정하지만 각 단어의 실행 가능 범위와 실제 레벨 사용을 모두 말해주지는 않는다. 따라서 보고서는 `본편 카탈로그`, `New Adventures`, `2026 공식 추가`, `에디터 전용/미사용/제거`, `사용처 미확인`을 구분한다. 수록 이름은 범위 선택의 입력이지 Kit 필수 목록이 아니다.

### 재조사: 오브젝트·단어 인벤토리와 문장 문법

이 인벤토리는 S13–S15, S19–S20, S23의 개별 페이지/카테고리 내용을 항목 이름 단위로 정리했다. Fandom의 “All items (186)”·“All items (59)”는 카테고리 인덱스 수치로, 그 자체를 플레이 가능한 고유 오브젝트/속성 개수로 읽지 않는다. 아래 명사 목록은 위키의 noun 표·special nouns·levelpack 전용 항목과 공식 481d object 추가를 토큰 기준으로 합친 출처 인덱스다. 사용자 레벨팩, 모드, 숨은 내부 엔티티까지 모두 포괄하는 엔진 리소스 dump라고 주장하지 않는다. 개별 이름의 레벨팩/에디터 상태가 달라질 때는 다음 상태 표기를 우선한다.

**명사/오브젝트 토큰 — 출처 카탈로그의 일반 명사와 481d 추가를 합친 이름 인덱스 (알파벳순):**

| 문자 | 토큰 |
|---|---|
| A | ALGAE, ARM, ARROW |
| B | BABA, BADBAD, BANANA, BAT, BEAN, BED, BEE, BELT, BIRD, BLOB, BOAT, BOBA, BOG, BOLT, BOMB, BONE, BOOK, BOTTLE, BOX, BRAIN, BRICK, BUBBLE, BUCKET, BUG, BUNNY, BURGER |
| C | CACTUS, CAKE, CAR, CART, CASH, CAT, CHAIR, CHEESE, CHILI, CIRCLE, CLIFF, CLOCK, CLOUD, COG, CRAB, CRYSTAL, CUP |
| D | DOG, DONUT, DOOR, DOOR2, DOT, DRINK, DRUM, DUST |
| E | EAR, EGG, EYE |
| F | FENCE, FIRE, FISH, FLAG, FLOWER, FOFO, FOLIAGE, FOOT, FORT, FOX, FROG, FRUIT, FUNGI, FUNGUS |
| G | GATE, GEM, GHOST, GRASS, GUITAR |
| H | HAND, HEDGE, HIHAT, HOTDOG, HOUSE, HUSK, HUSKS |
| I | ICE, IT |
| J | JELLY, JIJI |
| K | KEKE, KEY, KNIGHT |
| L | LADDER, LAMP, LAVA, LEAF, LEVER, LIFT, LILY, LINE, LIZARD, LOCK, LOVE |
| M | ME, MIRROR, MONITOR, MONSTER, MOON |
| N | NOSE |
| O | ORB |
| P | PALM, PANTS, PAPER, PAWN, PIANO, PILLAR, PIPE, PIXEL, PIZZA, PLANE, PLANET, PLANK, POTATO, PUMPKIN |
| R | RAIN, REED, RING, ROAD, ROBOT, ROCK, ROCKET, ROSE, RUBBLE |
| S | SAX, SCISSORS, SEASTAR, SEED, SHELL, SHIRT, SHOVEL, SIGN, SKULL, SNAIL, SPIKE, SPROUT, SQUARE, STAR, STATUE, STICK, STUMP, SUN, SWORD |
| T | TABLE, TEETH, TILE, TOWER, TRACK, TRAIN, TREE, TREES, TRIANGLE, TRUMPET, TURNIP, TURTLE, TUTO |
| U | UFO |
| V | VASE, VINE |
| W | WALL, WATER, WHAT, WIND, WORM |

**특수 명사:** TEXT, EMPTY, ALL, GROUP, GROUP2, GROUP3, LEVEL, CURSOR, IMAGE, ERROR, BLOSSOM, EDGE. 위키는 TEXT를 규칙을 만드는 모든 글자 오브젝트의 계열로 설명하고 기본적으로 `TEXT IS PUSH`라고 기록한다. EMPTY는 비어 있는 칸을 지칭하며, ALL/GROUP 계열은 단일 화면 sprite와 동등한 보통 오브젝트가 아니라 대상 집합/변환 관련 특수 문법이다. LEVEL은 레벨 자체·레벨 아이콘·경계와 연결되며, CURSOR는 기본 `CURSOR IS SELECT` 및 ALL 소속, IMAGE는 Gallery 특수 효과, ERROR는 디버그용 사라짐, BLOSSOM은 기본 엔딩 일부, EDGE는 바깥 타일과 관련된다. (S13; 개별 효과는 해당 noun 페이지별로 다르며 Kit 적용 전 추가 대조 필요.)

**목록 범위가 다른 오브젝트:** S13은 기본 팔레트 밖 levelpack 객체 ANNI (Baba Is You levelpack), MBLOCK, MPIPEB, MPIPE (New Adventures)를 따로 열거하며, 후자의 세 객체에는 TEXT가 없다고 명시한다. 481d는 BEAN, FOX, CHILI, HOTDOG, BRAIN, BONE, CACTUS, PALM, YES, NO 오브젝트를 새로 추가했고 ROOK은 Tower sprite와 같이 쓰는 word sprite-only라고 명시한다 (S20). 위 일반 명사표에 이미 보이는 새 오브젝트 이름도 중복 수록하지 않았다. YES/NO의 이번 조사 시점 기본 팔레트/레벨팩 노출 범위는 공식 노트만으로 확인하지 못했다. STAR/FLOWER/TREE는 본편에서 일부 special sprite가 있고 BOX/BABA는 New Adventures에서 일부 special sprite가 있다고 위키가 설명한다. 이는 새 noun 토큰 추가와 구분한다.

**속성 토큰 — wiki 속성 표·인덱스의 현재/확장 항목을 기능 가족별로 묶음:**

| 계열 | 토큰 |
|---|---|
| 조작·방향·이동 | YOU, YOU2, SELECT, MOVE, AUTO, RIGHT, UP, LEFT, DOWN, TURN, DETURN, FALLDOWN, FALLRIGHT, FALLUP, FALLLEFT, NUDGEDOWN, NUDGERIGHT, NUDGEUP, NUDGELEFT, LOCKEDDOWN, LOCKEDRIGHT, LOCKEDUP, LOCKEDLEFT, PULL, PUSH, SHIFT, REVERSE, SWAP, TELE, STILL, FLOAT, PHANTOM |
| 차단·상태·접촉·변환 | STOP, SLEEP, HIDE, BROKEN, CHILL, BACK, HOT, MELT, OPEN, SHUT, SINK, WEAK, SAFE, MORE, WORD, POWER, POWER2, POWER3, 3D, BOOM, HOLD |
| 목표·진행·수집 | WIN, DEFEAT, BONUS, END, DONE, REVERT |
| 색 | RED, BLUE, ORANGE, YELLOW, LIME, GREEN, CYAN, PURPLE, PINK, ROSY, GREY, BLACK, SILVER, WHITE, BROWN |
| 시각/입자 효과 | BEST, SAD, WONDER, PARTY, PET, HAPPY, ANGRY |

속성의 기본 효과와 조합은 서로 다른 계약이다. 예를 들어 wiki 표는 MOVE가 중첩되면 이동 단계가 추가되지만 YOU는 중첩해도 두 번 이동하지 않는다고 명시한다 (S9). PUSH와 PULL은 각각 STOP도 함의한다고 설명하고, HOT/MELT, OPEN/SHUT, SINK, WEAK, BONUS, DEFEAT 등은 서로 다른 삭제·생존 규칙을 가진다. 따라서 “collision 처리” 하나로 모든 상호작용을 대체할 수 없다. 위키는 HAPPY를 시각 속성·에디터 전용으로 분류한다. ANGRY도 공식 추가 목록에 있으나 그 상세 효과·기본 플레이 가용성은 이 조사에서 독립적으로 확인하지 못했다. 속성 카테고리에는 에디터 목록 밖/실험성 이름이 섞이므로 이 표를 완성된 출시판 런타임 명세로 취급하지 않는다.

**조건·operator 토큰 및 상태:**

| 출처 범위 | verb/operator/condition 이름 | 조사 상태 |
|---|---|---|
| 본편 Baba Is You levelpack | IS, HAS, MAKE, WRITE, AND, NOT, ON, NEAR, FACING, LONELY | 위키의 “present in the Baba Is You levelpack” 표. IS는 property 부여와 명사 변환, HAS는 파괴 때 생성, MAKE는 턴마다 생성, WRITE는 명사/property text로 바꾸는 verb로 설명됨. AND/NOT 및 세 조건도 같은 목록에 있다 (S14). |
| New Adventures | FEAR, EAT, FOLLOW, MIMIC, PLAY, IDLE, POWERED, OFTEN, SELDOM, WITHOUT, ABOVE, BELOW, BESIDE, FEELING, NEXTTO, SEEING | 위키가 New Adventures 확장으로 나눠 놓은 operator/condition. 기본 levelpack에서의 사용과 동일시하지 않음 (S14–S15). |
| 2026 공식 추가 및 editor 상태 확인 | BECOME, FACEDBY, HOLD, HAPPY, ANGRY | 공식 481d는 다섯 단어를 “New words”로 추가. 현재 위키는 BECOME/FACEDBY를 editor-exclusive로, HAPPY를 시각·editor-exclusive 속성으로 분류한다. HOLD의 상세 효과는 속성 페이지에 있고, 기본 campaign에서 어느 구간에 나타나는지와 ANGRY의 상세 효과는 미확인 (S20, S14, S9). |
| 제거·미사용·내부 항목 | ALONE2, ISIN, ISNOT, SLIP, STICK, CRASH, SCARY | 위키의 condition/operator/property 페이지와 Removed/Unused 색인은 제거/미사용, 폐기, 내부/무효 또는 오류 위험 이름을 섞어 기록한다. 플레이 가능 어휘와 분리한다. 정확한 빌드별 재사용 여부는 미확인 (S14–S15, S19). |

**문장 문법에서 확인된 구조 (S14–S15):**

- 문장은 물리 word object가 가로로 왼쪽→오른쪽 또는 세로로 위→아래 정렬되었을 때 읽힌다. 규칙은 `NOUN IS PROPERTY`뿐 아니라 `NOUN IS NOUN`도 포함한다. 문장 문자열/유효성은 놓인 단어의 공간 정렬에 종속된다.
- 본편 verbs는 IS 외에도 HAS, MAKE, WRITE를 포함한다. 이들은 property 할당/변환 외의 생성·텍스트 생성 효과를 만든다.
- AND는 여러 주어/술어를 한 문장에 잇거나 여러 조건을 결합한다. NOT은 규칙 무효화와 조건 반전 등 문맥별 의미가 있어 단순 문자열 전처리로 환원하면 안 된다.
- Prefix condition은 문장 첫 noun 앞 (`condition NOUN VERB ...`), infix condition은 주어와 조건 대상 noun 사이 (`NOUN CONDITION NOUN VERB ...`)에 위치한다. 조건 페이지는 복수 조건 결합, NOT과 AND의 범위, 가장 긴 유효 규칙 선택, 불가능한 조건 조합을 별도 규칙으로 기록한다. 위키 설명은 조건 문법이 단순 임의 길이 토큰 나열이 아니라는 직접 근거다.
- `TEXT`/`WORD`는 규칙 재료의 종류/가시성과 관계된 메타 문법 후보이며, 전체 text 유형과 inactive/active 표현, text 변환은 TIN의 3-token parser 모델에 넣기 전에 개별 규칙을 더 추적해야 한다.

**문법 가족 분류 이유:** 이 카탈로그는 명사(대상/집합) → operator(관계/행동/조건) → property(상태/행동 결과)라는 서로 다른 타입의 어휘뿐 아니라 TEXT/WORD 같은 자기참조 재료를 포함한다. 따라서 단어 개수를 늘리는 과제가 아니라 파서의 문장 형태, semantic evaluation, 턴 단계, 상호작용, 표현 상태가 서로 의존하는 시스템 확장이다. 기존 초안의 YOU/PUSH/STOP/WIN/DEFEAT는 이 넓은 범위의 일부다.

### 추가 확인: 3D와 WORD

S24는 `3D`가 대상의 관점으로 보드를 3D 투영하고 조작을 부여한다고 설명한다. 위 입력은 전진, 좌우 입력은 회전, 아래 입력은 복수 3D 대상 사이의 현재 시점 대상을 바꾼다. 선택되지 않은 3D 대상도 다른 속성과 상호작용할 때는 YOU처럼 취급되며, 기존 YOU/SELECT 조작도 계속 작동한다. 따라서 사용자 제안의 `BABA IS 3D`는 새 시점 시스템의 존재 여부보다 새 인벤토리 표현이 이 원작 조작 문법과 어떻게 결합하는지가 설계 대상이다. 정확한 시점 외형과 전환 모션은 실제 화면으로 별도 확인해야 한다.

S25는 `WORD`가 물리 오브젝트를 그 오브젝트의 명사 TEXT처럼 규칙 구성에 참여시킨다고 설명한다. WORD가 자기 자신을 WORD로 유지하는 단순 자기지지는 허용되지 않으며, 일부 자기참조 구성은 무한 루프를 만들 수 있다. 사용자 제안의 복합 BOX 인식도 같은 종류의 순환·재파싱 문제를 별도 계약으로 가져야 한다. 원작 WORD의 정확한 자기참조 판정식을 자료에서 임의로 복원해 복합 BOX 규칙으로 사용하지 않는다.

S26은 텍스트 이동·생성·파괴처럼 규칙 집합에 영향을 줄 수 있는 변화가 생기면 재파싱하고, 한 칸에 여러 텍스트가 겹치면 가능한 문장 조합을 각각 생성한다고 설명한다. 따라서 복합 테두리 인식에서도 여러 유효한 폐곡선이 생겼을 때 하나를 임의 선택하기보다 각각을 유효 결과로 만드는 방향이 원작의 다중 결과 문법과 맞는다. 다만 복합 도형 탐색 자체는 TIN 확장 문법이므로 원작 parser 구현을 그대로 복사할 근거는 아니다.

### 화면 증거 인덱스

| ID | 시각 | 확인한 화면·행동 | 뒷받침하는 내용 | 확인하지 못한 것 |
|---|---:|---|---|---|
| E01 | 약 01:32 | 레벨 제목 “WHERE DO I GO?”와 첫 보드. 어두운 배경 가운데 직교 격자형 보드, 벽으로 둘러싸인 칸, 텍스트 타일과 캐릭터가 보임. 원근감이 없는 2D 탑다운 구도처럼 보이고 화면에서 카메라 이동은 관찰되지 않음. 포인터나 별도 커서 표시는 보이지 않음. | 실제 플레이 영상에서 확인한 초기 보드의 배치·시각 언어 | 정확한 보드/화면 비율, 셀 픽셀 치수, 해상도별 스케일, 키를 누른 뒤 움직임, 초기 진입 애니메이션 |
| E02 | 약 02:00 | 보드 양쪽에 “Z UNDO”, “P MENU” 힌트가 보임. 보드는 계속 화면 중심의 격자로 제시됨. | 영상의 해당 순간에 undo/menu 입력 힌트가 표시된 사실. 별도 상시 HUD보다 작은 텍스트 힌트만 확인됨 | 힌트가 모든 레벨/상태에서 계속 노출되는지, 실제 키 작동, 눌렀을 때 피드백·메뉴·복귀 |
| E03 | 약 02:02 | 영상에 “NOW WHAT IS THIS?” 제목/다음 장면이 컷 뒤 표시됨 | 영상 편집본에 다음 레벨을 소개하는 제목이 나타난 사실 | 직전 레벨 성공 시점, 게임이 레벨 사이를 어떻게 이동하는지, 전환 모션·결과 패널·맵 복귀. 편집이 원인과 순서를 가림 |

E01–E03은 영상의 특정 프레임을 브라우저에서 본 기록이며, 로컬 이미지 파일은 없다. 약 05:38에는 맵/보드처럼 보이는 장면이 있었지만 장면 맥락을 특정할 수 없어 분석 근거에서 제외했다.

## 3. 핵심 시스템과 규칙

### 게임의 중심 루프

**[공식 자료 S1, 화면 관찰 E01]** 플레이 공간은 격자 위 오브젝트와 단어 타일로 구성된다. 플레이어는 캐릭터를 격자 이동시켜 단어를 배치·분리하고, 유효한 문장으로 세계의 속성을 바꾼다. 오브젝트가 “본래부터” 가진 고정 속성만으로 게임을 설명하지 않고, 보드에서 성립한 문장이 그 시점의 속성을 정한다는 것이 이 레퍼런스의 중심 문법이다. 이는 규칙을 읽는 동시에 규칙의 재료를 움직이는 퍼즐이다.

문장 하나를 옮기는 결과가 이동 가능성, 통과 가능성, 승리 대상, 위험한 접촉, 자동 이동 등 보드 전체에 파급될 수 있다. 따라서 문장 만들기 자체가 목적이 아니라, 성립한 규칙 집합으로 보드 상태가 어떻게 달라지는지 관찰하고 다음 입력을 실험하는 것이 루프다.

### 규칙·속성 범위와 Kit 분류 기준

분류는 기존 계획에 적힌 단어만 구현 범위로 고정하지 않기 위해 시스템 간 의존성과 플레이 역할로 나눈다. 아래 “핵심 후보”는 Baba Is You의 전체 규칙을 충실히 구현할 때 중심성이 높다는 분석이지, 이번 Kit에 무조건 포함하라는 결정이 아니다.

| 시스템/문법 | 확인 가능한 범위와 근거 | 분류 이유 및 계획상 의미 |
|---|---|---|
| 격자 위 물리 단어와 문장 | S1, E01은 격자와 단어 타일을 확인. 공략 S12는 완성·분리된 문장의 사례를 기록 | **핵심 기반.** 파서만이 아니라 단어의 위치·겹침·이동과 문장 변경을 게임 상태로 다뤄야 함 |
| Noun IS Property | 공식 설명 S1, 규칙 카탈로그 S14, S21. YOU/PUSH/STOP/WIN은 최소 playable fragment 예시 | **핵심 기반.** 규칙 해석과 행동/상호작용을 잇는 의미 모델이 필요 |
| 단어 밀기 및 규칙 파괴·재성립 | S1의 물리 규칙 개념, S21의 push chain 및 active-rule reassignment. 화면 연속 증거는 미확인 | **핵심 상호작용 후보.** 단어를 옮기는 것과 속성이 사라지는 경우를 같은 턴 모델 안에서 규정해야 함 |
| Noun IS Noun 변환 | S12의 레벨 진행 사례 및 S14의 IS verb 설명 | **핵심 확장 후보.** 변환 이후 ID/정체성, 여러 결과 명사, 변환의 반복·연쇄 규칙을 정해야 함 |
| AND, NOT 및 확장 문장 | S14–S15의 본편/확장 문법 분류, S20의 2026 신규어휘 확인 | **문법 확장 계열.** 짧은 3단어 문장만을 전체 원작 문법으로 간주할 수 없음. 포함 범위는 Kit 결정 |
| 복수 YOU/복수 조작 대상 | S21은 하나의 방향 입력이 현재 YOU인 모든 개체에 동시 적용된다고 명시하고, S10은 개체별 이동 목록/우선순위와 충돌 예를 설명한다. 실제 장면은 미확인 | **핵심 후보.** 조작 집합은 규칙에 따라 매 입력마다 달라진다. 충돌은 개체별 처리 순서에도 의존할 수 있으므로 global all-or-none으로 가정할 수 없음 |
| 자동 이동 MOVE | S9 및 S12에 MOVE가 등장. 실제 연속 동작·밀기 우선순위는 미확인 | **행동 주체가 없는 턴 전이 계열.** 플레이어 입력 외 이동이 규칙 갱신 및 접촉과 어떻게 섞이는지 계약 필요 |
| PUSH/STOP과 통과 | S9, S12에서 일반 속성으로 제시. 화면에서 밀기 충돌을 직접 확인하지 못함 | **기본 공간 상호작용 후보.** 동일 칸 허용, 밀기 사슬, 다중 대상 차단을 정밀히 시험해야 함 |
| DEFEAT/WIN | S9/S12의 커뮤니티 분류·공략, 게임 타이틀 및 공식 설명 | **목표·위험 계열.** 동시 접촉, 복수 YOU 생존, 승리 판정과 사망 판정의 순서가 UX와 레벨 해법을 결정 |
| HAS/생성, OPEN/SHUT, HOT/MELT, SINK, WEAK | S9/S12에서 확인되는 대표 상호작용군 | **확장 상호작용 계열.** 특정 키트의 종류 수가 아니라 서로 다른 결과 형태(생성·파괴·상태 변화)를 대표하는지 기준으로 범위 결정 |
| PULL, SHIFT, SWAP, TELE 및 자동/위치 속성 | S9, S11의 커뮤니티 인덱스/룰북 | **고급 이동·공간 변환 계열.** 사용 빈도와 처리 순서가 서로 다르므로 한 번에 묶어 간단 구현으로 축약하지 말 것 |
| TEXT/WORD 및 문장 특수화 | S9/S13의 special noun·property 설명, S14의 operator 분류 | **메타 규칙 계열.** 텍스트 자체의 성질을 바꾸거나 문법을 확장할 가능성은 범위·파서 모델에 직접 영향. 각 메타 상호작용 깊이는 미확인 |
| 레벨 맵·해금·에디터·공유 | S4의 공식 레벨 에디터 안내, S12의 진행 공략 | **메타 진행/저작 체계.** 핵심 퍼즐 시스템과 같은 Kit 범위인지 별도로 결정해야 함. 에디터는 TIN의 완료조건으로 자동 승격되지 않음 |

### 기본 규칙이 보드에서 바꾸는 것

다음은 **커뮤니티 규칙 카탈로그(S9–S16, S19), 2026 공식 어휘 업데이트(S20), 2026-09-14 검증 규칙 레코드(S21)**에 기록된 작동 규칙이다. 직접 플레이로 재현하지 않았으며, 출처가 명시한 범위보다 넓게 일반화하지 않는다.

| 문법/속성 | 커뮤니티 자료가 설명하는 일반 효과 | 이 보고서에서 남기는 경계 |
|---|---|---|
| Noun IS Property | 모든 현재 해당 noun 개체에 성립 속성을 바인딩한다. YOU/PUSH/STOP/WIN이 가장 짧은 playable fragment의 예다 (S21). | 여러 속성 간 상호작용은 속성 조합별로 다름. stack 여부도 개별 속성 문서 참조. |
| Noun IS Noun | 변환 문법이다. 위키는 본편 IS가 객체를 다른 noun으로 바꾸는 데 사용된다고 기록한다 (S13–S14). | 변환 다중 규칙/순환/동일 턴 다른 이동과의 상호작용은 코드 단계까지 위키 근거를 옮기되, 필요한 정확한 사례는 별도 확인. |
| YOU | 현재 YOU인 모든 noun instance가 방향 입력에 반응한다. 하나의 YOU 규칙 아래 다수 개체도 모두 조작 집합에 들어간다 (S16, S21). | object priority 때문에 충돌 처리의 세부 결과는 입력 집합/위치/해결 queue를 함께 봐야 함. 화면별 효과는 미확인. |
| PUSH / STOP | 인접 PUSH object/단어는 이동 입력 방향으로 밀 수 있고, 연쇄는 줄 끝까지 이동 가능한 경우 성립한다. PUSH도 solid/STOP으로 분류된다 (S9, S21). | PUSH+다른 특수 속성, 반대 방향에서 같은 대상에 접근하는 충돌은 Order of Operations의 우선순위 예를 참조하고 필요 시 해당 배치를 대조. |
| MOVE | facing 방향으로 자동 이동하고 차단 시 방향을 되돌린다. 중복 MOVE는 이동 단계를 쌓는다고 속성 페이지가 설명한다 (S9). | 페이지는 MOVE 행동을 한 번의 원자적인 점프로 설명하지 않고 여러 movement stage/단계별 collision 검사로 풀이한다. 특수 이동과의 전체 우선순위는 아래 S10의 제한 참조. |
| DEFEAT / WIN | DEFEAT와 YOU가 겹치면 YOU가 파괴될 수 있고, 같은 위치에 WIN과 DEFEAT가 있는 일부 상황에서 DEFEAT 우선이라고 위키가 명시한다. WIN은 YOU가 WIN 대상에 닿을 때 목표를 끝낸다 (S16, S21). | 매 tick의 모든 제거/승리 우선순위는 이 단문 규칙으로 환원하지 않는다. 원작 screen feedback은 미확인. |
| AND / NOT | AND는 subject 또는 predicate 여러 개를 결합하고 조건을 연계한다. NOT은 규칙 무효화, 집합 제외 및 condition 반전 등 문맥별 해석을 가진다 (S14–S15). | 고정 3-token 파서로는 전체 문법을 나타낼 수 없다. 실제 지원 형태와 parse 선택을 Kit 범위로 명시해야 한다. |
| HAS / MAKE / WRITE | HAS는 제거 시 대상 생성, MAKE는 turn마다 생성, WRITE는 noun/property word 형태를 생성하는 verb로 분류된다 (S14). | 각 생성 시점·중복 억제·생성 텍스트의 같은 turn 평가를 포함해 독립 interaction contract가 필요. |
| HOT/MELT, OPEN/SHUT, SINK, WEAK 등 | 접촉/겹침에 의한 제거 효과가 서로 다르다. 예컨대 open/shut은 둘 다 제거하고, hot/melt는 melt 쪽 제거에 적용되며, safe 등의 예외도 각 표에 설명된다 (S9, S19). | 전체 interaction matrix를 일반적인 collision test 한두 개로 대표하지 않는다. 선택 속성별 조합과 우선순위가 필요. |

위 카탈로그에는 PULL, SHIFT, SWAP, TELE, SINK, WEAK, HOT/MELT, OPEN/SHUT, HAS 등도 포함된다. 이를 “충돌” 한 가지로 요약하면 각기 다른 이동·생성·파괴 규칙이 사라진다. Kit가 선택한 어휘마다 규칙의 적용 대상, trigger, 제거/생성/이동 결과, 예외 및 undo 후 상태를 따로 계약화해야 한다.

2026-01-02 공식 481d 업데이트는 새 object 11종과 word 5종을 명시하고, 위키 카탈로그는 본편 및 New Adventures 문법을 더 넓게 구분한다 (S13–S20). 이는 현 TIN 파서가 3-token `NOUN IS (PROPERTY|NOUN)`에 집중되어 있는 것과 비교해 원작 어휘·문법 폭이 훨씬 넓다는 직접적인 범위 차이다. 다만 481d의 추가가 이 모든 단어를 기본 캠페인에 필수로 쓴다는 뜻은 아니다. 사용자 선택은 카탈로그와 버전 상태를 본 뒤 Kit가 무엇을 채택할지로 한정한다.

### 처리 순서와 동시성

**커뮤니티 자료에서 확인된 상위 처리 모델 (S10, CC-BY-SA):** 각 turn에서 다수 속성·verb가 한 번 실행되며 conditions는 해당 rule/object를 실제 조회할 때 평가된다. `domovement()`은 한 movement stage의 개체 목록을 처리하고, 그 stage가 끝난 다음 다음 stage에 들어가며, 다음 stage 전에 condition/rule을 다시 읽는 구조로 기술돼 있다. 이후 페이지는 rule parse → IS/BECOME 변환 → parse → MAKE/추가 이동·fall/status/level·collision 처리 → 추가 parse의 여러 단계를 열거한다. 이 자료는 규칙이 보드 이동 중 갱신되지 않는 정적 1회 parse라는 해석을 배제한다.

**priority 사실 (S10):** 새로 시작한 레벨의 object list는 보드 열 왼쪽→오른쪽, 각 열 안에서 위→아래, 같은 tile에서는 아래 layer 먼저 순으로 만들어진다고 설명한다. 새 object는 생성 순서대로 목록 끝에 붙는다. 이 priority는 한 action에서 같은 PUSH/PULL/SWAP 대상에 복수 object가 접근할 때, 그 밖의 몇몇 상호작용에도 관여한다. 따라서 의미 수준에서는 한 방향 입력이 모든 YOU에 동시 적용돼도 실제 collision 해결이 “모든 YOU를 하나의 all-or-none 이동 계획으로 합친다”는 뜻은 아니다.

**동시 YOU의 확인 수준:** S21은 하나의 방향 입력이 모든 현재 YOU instance를 대상으로 한다고 명시한다. S10은 movement list/priority의 순차 처리와 서로 다른 방향의 동일 target push가 priority-dependent인 예를 설명한다. 이 둘로 “복수 YOU 제어는 공통 입력, 개별 개체 이동은 우선순위가 개입할 수 있음”까지 확인한다. 특정 mixed-blocked 보드에서 정확히 어느 개체가 이동하는지는 그 보드의 배치·목록 순서와 상호작용 종류에 따라 다를 수 있으므로 특정 결과를 일반 규칙으로 쓰지 않는다. 이는 자료 확인을 사용자에게 떠넘길 항목이 아니라, 후속 구현이 원작 사례를 필요로 할 때 보고서 출처에서 케이스를 선정하고 최소 대조 보드로 재현할 세부다.

**남은 미확인:** S10 검색/본문 렌더가 일부 하위 행동 이름을 이미지로 돌려줘 세부 movement/collision substage의 각 속성별 전체 순서를 이 보고서에서 빠짐없이 인용하지 않았다. 이 위키는 게임 코드/빌드별 비교가 아니고 실제 상용판 플레이로 검증하지 않았다. 선택할 interaction이 이 정확한 순서에 걸리면 위키 해당 행과 동영상/현재판 재현을 계획서의 소스 증거로 더 추적한다. 기계적 사실 자체를 grilling 질문으로 사용자에게 묻지 않는다.

## 4. 상태별 화면·입력·피드백 분석

이 표의 **작성자가 직접 확인한 화면 관찰**은 E01–E03에 한정된다. 규칙 사실은 별도 출처(S9–S22)의 기록으로 표시하고 화면을 확인한 것처럼 섞지 않는다. 사용자는 10장의 실제 플레이 화면을 추가 제공했으며, 요청에 따라 이 보고서는 캡처를 해석하지 않고 사용자가 제공한 설명과 함께 아래에 출처 자료로 등록한다.

| 상태 | 화면/입력/피드백에서 확인된 것 | 보드·가독성·초점 관찰 | 직접 보지 못한 것과 후속 확인 |
|---|---|---|---|
| 첫 플레이 화면 | E01에서 레벨명과 보드가 함께 보임. 별도 커서 없이 정적인 첫 장면 | 보드는 어두운 바탕의 가운데 영역을 차지한다. 직교 격자 칸과 벽, 단어·캐릭터가 식별된다. 대체로 정사각 타일처럼 보이나 치수 측정은 아님. 원근 카메라나 카메라 이동은 보이지 않음 | 새 게임 진입 전 화면, 최초 입력 안내, 보드가 화면에서 차지하는 정확한 비율, 단어 최소 크기, 접근성 모드 |
| 일반 이동과 밀기 | 화면 입력/결과 쌍은 확보하지 못함. S21은 방향 입력, 인접 밀기, 연쇄 이동의 규칙을 기술. S22는 가이드 조작을 표기 | 움직이는 개체 표시, 선택 프레임/커서, 입력 전후의 보드 흔들림/애니메이션은 판단 불가 | 현재판에서 실제로 쓰이는 key binding, press/hold repeat, blocked input 반응, 모션·소리 |
| 규칙이 끊기거나 성립하는 순간 | S21은 word push 후 문장이 달라지면 해당 속성이 즉시 사라진다고 기술. 영상에서 문장 변경은 관찰 못함 | active/inactive 글자 색·대비, 규칙 강조, 성립 순간 애니메이션/사운드는 미확인 | 동일 행동의 화면 전/후 및 입력과 결과의 연결. 상세 syntax는 화면이 아니라 S14–S15 카탈로그로 재조사됨 |
| 여러 대상이 동시에 변하는 순간 | S16/S21은 현재 YOU 전부가 동일 방향 입력에 반응한다고 기술. S10의 priority 자료는 처리 queue가 개체 순서에 민감할 수 있음을 보인다. 직접 화면 없음 | 각 YOU 대상의 외형/표시, 같은 frame에서 움직이는 연출, 겹침 시 구분은 불명 | 시각적으로 복수 조작 대상을 얼마나 읽기 쉬운지 보여주는 전/후 sequence. mechanically all-or-none인지 묻는 항목은 아님 |
| 이동 불가 | 직접 관찰 없음. S9/S21은 STOP 및 밀기 chain의 규칙을 제공 | 막힌 입력의 시각·청각 cue, 입력이 소비되는 animation, turn counter 표시 여부 불명 | 동일 배열의 정지 전/후 화면과 짧은 입력 영상/음향. wiki-confirmed collision rules를 사용자의 설계 판단으로 미루지 않음 |
| 조작 대상 상실 또는 실패 | S16은 현재 YOU가 하나도 없으면 음악 fade 후 undo 또는 restart 안내가 뜬다고 설명하고, YOU가 돌아오면 음악이 다시 난다고 설명 | 안내 위치·문구·버튼·보드 지속 표시·fade 속도는 화면/소리 관찰 전 | YOU 룰 파괴/DEFEAT로 인한 마지막 YOU 소실 후의 actual prompt와 복구 선택 UI |
| undo와 reset | E02에서 Z UNDO 힌트. S5 Jam 안내는 초기 빌드의 Z undo/R restart, S22 비공식 guide는 X/Z undo와 R restart를 기술 | 실제 key label, 힌트 노출 위치·빈도, undo animation은 미확인 | 현재판 UI의 rebind 값, 한 번 취소되는 state, history 제한, reset 확인/복귀 화면. 규칙 확인과 화면 확인을 구분 |
| 성공과 다음 레벨 전환 | 영상에는 E03의 다음 레벨 소개 컷. 성공 연속 장면은 없음 | 성공 문구/효과/다음 화면의 위치 및 보드 회수 방식 불명 | 승리 조건이 감지되는 프레임, 자동 이동/확인 입력, 맵으로 돌아가는지, 스킵/반복 진입 |
| 메뉴 열기·닫기와 플레이 복귀 | E02에 P MENU 힌트. 메뉴는 열어 보지 않음 | 메뉴의 오버레이 방식, 보드의 배경 유지·암전, 포커스 표시 모두 미확인 | 일시정지와 입력 차단, 선택 포커스, 뒤로 닫은 뒤 보드·선택·입력 반복의 복귀 상태 |

### 사용자 제공 화면 파일과 설명 원문

아래는 사용자가 첨부한 설명을 수정·요약하지 않고 기록한 자료 인덱스다. 이 보고서의 작성자는 이미지 내용을 분석하거나 이미지에서 추가 사실을 추출하지 않았다. 후속 검토자는 링크된 원본을 직접 살펴볼 것. 파일은 사용자 첨부 원본을 `docs/research/rule_rewrite/`에 복사해 보존했다.

| 자료 ID | 보고서 내 원본 복사본 | 사용자가 제공한 설명 |
|---|---|---|
| U01 | [user_capture_01.jpg](rule_rewrite/user_capture_01.jpg) | 시작 |
| U02 | [user_capture_02.jpg](rule_rewrite/user_capture_02.jpg) | 화면전환시 안개 |
| U03 | [user_capture_03.jpg](rule_rewrite/user_capture_03.jpg) | 메인화면 |
| U04 | [user_capture_04.jpg](rule_rewrite/user_capture_04.jpg) | 게임시작(이미 진행중이라 지도가 나옴. 처음부터 하면 스테이지 1에서 시작함) |
| U05 | [user_capture_05.jpg](rule_rewrite/user_capture_05.jpg) | 오른쪽으로 한칸 간 모습. 좌상단에 챕터가 나옴에 주목하라. |
| U06 | [user_capture_06.jpg](rule_rewrite/user_capture_06.jpg) | 사원 챕터에 들어온 모습. 스테이지가 여럿 있다 |
| U07 | [user_capture_07.jpg](rule_rewrite/user_capture_07.jpg) | 스테이지 하나 위에 올라갔음 |
| U08 | [user_capture_08.jpg](rule_rewrite/user_capture_08.jpg) | 스테이지 들어감. 화면전환 안개가 꽉 채우고 스테이지명이 나옴 |
| U09 | [user_capture_09.jpg](rule_rewrite/user_capture_09.jpg) | 인게임 상황 |
| U10 | [user_capture_10.jpg](rule_rewrite/user_capture_10.jpg) | 플레이 중 is you가 깨지거나 you가 전부 죽었을 때 나오는 안내(모바일이라 두 손가락 스왑이라는 방법과 처음부터 다시하기 버튼이 제공되고 있다.) |

U01–U10은 별도 화면 캡처 증거군이며, E01–E03의 2019년 영상 프레임을 대체하거나 작성자의 직접 관찰로 승격하지 않는다. UI 레퍼런스 선택에 게임 빌드 버전 제한을 두지 않는다는 사용자 지시를 따른다.

### 화면에 관해 말할 수 있는 범위

- E01의 좁은 영상 프레임에서 확인되는 것은 **격자형 2D 보드가 화면 중앙에 놓이고 주변에 어두운 여백이 있는 구도**다. 정밀 보드/화면 비율, 셀 크기와 글자 크기는 측정할 자료가 없다.
- 화면의 칸은 정사각 타일처럼 보이고 원근 투영은 보이지 않는다. 그러나 수치 비율·확대 단계·카메라 경계는 미확인이다.
- E02는 undo와 menu 입력 힌트가 적어도 그 순간 화면에 나타남을 보여 준다. 상시 HUD인지, 맵/튜토리얼 상태에 종속되는지는 이 짧은 장면으로 일반화할 수 없다.
- 영상에 업로더 음성과 편집이 섞여 있어 게임 효과음의 종류·타이밍·믹스를 분리해 평가하지 않았다. 키 반복 감각도 단발/홀드 입력 측정을 하지 않았다.
- TIN의 현재 텍스트 그리드 화면을 Baba 화면의 일부라고 해석하지 않는다. 두 화면 비교는 후속 실행 캡처에서 해야 한다.

이 절의 보드 비율, 정각 셀/실제 타일 크기, 카메라 framing, 화면 내 단어 크기, active/inactive 표현, focus/조작 대상 표시, 입력 반복 연출, 소리, menu close 뒤 복귀는 E01–E03만으로 미확인이다. 다음 단계의 실제 UI 검토는 사용자 스크린샷/영상에만 근거를 더하고, 원작 기계적 사실은 위 출처 목록으로 확인한다.

## 5. 콘텐츠·학습·진행·복구 구조

### 개념을 가르치고 다시 쓰는 방식

**[공식 자료 S1; 공략 S12]** 학습 단위는 문장 카드 하나를 읽는 일보다, 보드의 단어를 움직여 규칙을 세우고 그 결과를 보드에서 시험하는 일에 가깝다. 공략은 초반의 규칙 분해/재조립 뒤에 AND, 명사 변환, 다중 제어, 자동 MOVE, DEFEAT/HAS/OPEN 같은 서로 다른 규칙 상호작용을 다루는 진행 사례를 나열한다. 이는 새 문법을 별도 설명문으로 외우게 한 뒤 끝내는 대신, 기존 이동·문장 조작에 새 결과를 추가해 재조합하는 콘텐츠 구조의 근거다. 단, 실제 레벨 화면과 순서는 이 조사에서 직접 대조하지 않았으므로 순서 자체를 Kit 설계안으로 복제하지 않는다.

**[개발자 인터뷰 S7]** Teikari는 최초 아이디어가 NOT과 블록 밀기에서 시작했고 Jam에서는 약 10개 레벨이 있었다고 설명한다. 초기 프로토타입에서 객체 속성을 고정값으로 두지 않고 명시적 문장으로 만들도록 생각을 바꿨으며, 상용판을 다듬는 과정에서 약한 초기 레벨과 한 가지 기능만 보여 주는 단어 사용을 정리했다고 말한다. 이것은 레벨 수를 채우기보다 같은 시스템을 여러 authored 상황에 반복 배치하고, 고립된 단어 기능이 코어를 정당화하는지 검토했다는 저작 판단의 근거다.

S7의 “Hold” 사례는 당시 초기 개발/정리 과정의 언급이고, S3의 최신 481d 업데이트는 Hold를 새 어휘로 다시 목록에 올린다. 서로 다른 시점의 자료이므로 이를 모순으로 지우지 않는다. 원작의 vocabulary도 버전·저작 시점에 따라 달라질 수 있다는 근거로 사용한다.

### 반복 콘텐츠와 Reference Game의 분량

S4는 공식 에디터가 150개 이상 신규 및 100개 이상 잘린 레벨과 제작/공유 지원을 언급한다. 이는 원작의 콘텐츠 생태계와 문법 조합이 넓다는 증거지만, Kit가 그 수량이나 에디터를 제공해야 한다는 근거는 아니다. TIN의 완료 기준은 별도 결정 문서와 KIT_WORKFLOW에 따르며, 최소 10분 플레이를 같은 입력 반복이나 이동 시간으로 채우지 않고 동일 시스템을 서로 다른 authored content에서 반복 검증해야 한다.

후속 계획에서 필요한 증거는 레벨 총량만이 아니다. 각 레벨이 이미 소개한 규칙을 어떤 새 조건에서 재사용하고, 새 조합이 core parser/evaluator의 수정 없이 데이터 추가만으로 표현되는지 보여야 한다. 본 보고서는 원작 맵의 정확한 해금 임계값·레벨 수·순서를 확인하지 않았다.

### 플레이어 이해와 저장 진행은 다르다

**[추론]** 플레이어가 규칙의 해법을 기억하는 지식은 게임 저장 데이터로 되돌리거나 초기화할 수 없다. 따라서 지식을 새로 “발견했는가”와 게임이 기록하는 해금/완료 플래그는 다른 상태다. 순수한 플레이어 지식이나 플레이 횟수를 게임이 감지할 수 있다고 계획에 가정하지 않는다. 새로 진입한 플레이어를 위한 발견 순서·힌트와, 이미 해법을 아는 플레이어의 반복을 방지하는 레벨 접근/진행 규칙은 별개 설계 결정이다.

원작이 해법을 기억하는 플레이어에게 매번 발견 절차를 강제하는지, 레벨을 자유롭게 선택하게 하는지, 힌트/건너뛰기를 어떻게 처리하는지는 직접 확인하지 못했다. 게임의 장기 저장·월드 맵을 플레이해 보지 않고 추측하지 않는다.

### 복구

E02는 undo 입력 힌트를 보여 주지만 undo가 무엇을 한 단계로 정의하는지, reset이 언제 허용되는지 확인하지 않는다. 규칙 퍼즐에서는 잘못된 단어 배치가 세계의 속성/조작 가능성을 바꾸므로, 한 입력씩 복구 가능한 undo와 authored 초기 상태로 돌아가는 reset은 발견 실험의 핵심 UX 후보다. TIN 계획은 용어와 키 입력뿐 아니라 undo의 대상(플레이어 턴, 자동 이동/변환, 메뉴/모드), 기록 한계, 저장/복원 시점, reset 확인 및 재진입 결과를 명시해야 한다.

## 6. 현재 TIN 구현과의 차이

다음은 문서 설명이 아니라 현재 소스와 테스트 코드를 읽은 결과다. 테스트 실행은 하지 않았다.

### 코드상 확인된 구현

| 영역 | 확인된 현재 TIN 코드 | 범위와 차이 |
|---|---|---|
| 엔티티·그리드·문장·규칙 집합 | [grid_entity.gd](../../modules/rule_rewriting/domain/grid_entity.gd), [grid_state.gd](../../modules/rule_rewriting/domain/grid_state.gd), [rule_sentence.gd](../../modules/rule_rewriting/domain/rule_sentence.gd), [rule_set.gd](../../modules/rule_rewriting/domain/rule_set.gd) | 셀 좌표, 엔티티 ID/종류/방향, 단어의 역할·값, base/runtime tags와 JSON 변환이 있다. 문장은 subject/operator/predicate와 source cells를 담고 의미 중복을 정리한다. |
| 파서 | [rule_parser.gd](../../modules/rule_rewriting/systems/rule_parser.gd#L10) | 수평 RIGHT·수직 DOWN으로 연속 3단어만 스캔한다. subject는 noun, operator는 IS, predicate는 property 또는 noun이다. 여러 단어가 한 셀에 있으면 후보를 만들고 의미가 같은 문장은 dedupe한다. AND/NOT/전치사/조건문/가변 길이 문장 모델은 없다. |
| 평가·변환 | [rule_evaluator.gd](../../modules/rule_rewriting/systems/rule_evaluator.gd#L5) | 비단어 엔티티의 Noun IS Noun 변환을 적용한다. 대상 명사가 여럿이면 원래 종류가 후보에 있을 때 원형 유지, 아니면 정렬된 첫 종류를 원본에 적용하고 나머지는 복제한다. 한 호출에서 변환 연쇄는 막는다. |
| 이동 | [movement_solver.gd](../../modules/rule_rewriting/systems/movement_solver.gd#L8) | cardinal 입력, PUSH 사슬, STOP 차단, 겹침 허용, 복수 YOU 계획, MOVE 자동 이동과 막힌 대상의 방향 반전이 있다. PULL/SHIFT/SWAP/TELE/OPEN/SHUT 등은 이 시스템에 보이지 않는다. |
| 턴 연결·상호작용 | [module.gd](../../modules/rule_rewriting/module.gd#L249) | _move_controlled에서 입력 이동 후 규칙 재구성·변환, MOVE 자동 이동 후 이동한 단어가 있으면 규칙 재구성·변환, 이후 DEFEAT 제거 후 WIN 판정을 수행한다. 이것은 현재 TIN의 처리 순서이지 원작 Baba의 확정 순서가 아니다. |
| 승리·실패 | [module.gd](../../modules/rule_rewriting/module.gd#L323) | DEFEAT 대상 YOU를 먼저 제거한 뒤 YOU가 하나도 없을 때 실패, 남은 YOU의 WIN 속성/접촉으로 승리하는 코드 흐름이다. YOU가 아예 없으면 이 검사만으로 자동 실패하지 않는다. |
| undo/history | [module.gd](../../modules/rule_rewriting/module.gd#L389) | 보드 액션의 스냅샷 undo, 최대 64개 history가 있다. 모드/grid/solved/failed/턴·시도 수 등이 저장 대상이다. |
| 저장/복구 | [module.gd](../../modules/rule_rewriting/module.gd#L193), [module_manifest.tres](../../modules/rule_rewriting/module_manifest.tres) | state_format 4 JSON-safe 딕셔너리와 입력 action 목록을 사용한다. 오래된 형식은 초기 상태로 이행한다. 유효하지 않은 저장/알 수 없는 레벨 처리와 엔티티 검증 로직이 있다. |
| 콘텐츠 로딩 | [level_loader.gd](../../modules/rule_rewriting/systems/level_loader.gd#L4), [content/level_01_signal_room.json](../../modules/rule_rewriting/content/level_01_signal_room.json), [content/level_02_crossing.json](../../modules/rule_rewriting/content/level_02_crossing.json) | JSON 정의 2개가 있으나 ID→경로 LEVEL_PATHS가 core 스크립트에 하드코딩돼 있다. 새 level ID마다 loader 수정이 필요하다. 현재 일반 진입 흐름은 signal_room_01부터 시작하며 두 번째 레벨은 일반 흐름에서 선택/진입 메뉴로 연결되지 않는다. |
| 입력·presentation | [module.gd](../../modules/rule_rewriting/module.gd#L48), [module.gd](../../modules/rule_rewriting/module.gd#L121), [module.gd](../../modules/rule_rewriting/module.gd#L618) | ModuleContext 경유 action을 사용하고 press edge로 처리해 키 홀드 반복은 발생하지 않는다. 현재 화면은 ColorRect/Label 중심이며 보드를 문자 격자로 렌더링하고 한 셀에 여러 엔티티가 있으면 우선순위 하나만 보여 준다. 단어 텍스트는 첫 세 글자로 줄인다. 시작은 보드가 아니라 고정 clue 3개 관찰 모드이며 항상 룰 패널/상태/조작 문자열을 표시한다. |

### 테스트 코드가 명시하는 범위

| 파일 | 테스트가 작성한 시나리오 | 이 조사에서의 상태 |
|---|---|---|
| [test_rule_parser.gd](../../tests/core/test_rule_parser.gd) | 수평·수직 3토큰 문장, 불완전/잘못된/범위 밖 문장, noun 변환, 겹치는 의미 중복 제거, 엔티티 순서 불변 | 읽음. 미실행 |
| [test_rule_evaluator.gd](../../tests/core/test_rule_evaluator.gd) | 단일·복수 변환, 변환 연쇄 금지, 안정 ID, 규칙 삽입 순서와 독립성 | 읽음. 미실행 |
| [test_rule_movement.gd](../../tests/core/test_rule_movement.gd) | 1/5/20개 PUSH 사슬, 막힌 사슬 원자성, 겹침/STOP, 복수 YOU, 잘못된 입력, MOVE 반전, 자동 밀기 | 읽음. 미실행 |
| [test_rule_level_loader.gd](../../tests/core/test_rule_level_loader.gd) | 두 authored level JSON 로드/roundtrip, 알려지지 않은 ID, 형식 버전, 중복 ID, 비정수 좌표 | 읽음. 미실행 |
| [test_cycle4_modules.gd](../../tests/core/test_cycle4_modules.gd) | 모듈 save/migration, clue 관찰, 첫 레벨 승리/portal, 단어 이동 재파싱과 undo, 저장 roundtrip, 입력 비활성화, crossing 변환/MOVE/save/undo, DEFEAT-before-WIN 및 undo | 관련 영역 읽음. 미실행. 시각 검수나 원작 일치 테스트가 아님 |

위 테스트 명세에는 복수 YOU 중 일부만 막힌 입력의 결과, 단어 PUSH 후 그 턴에 바뀐 규칙이 자동 이동에 미치는 영향, 충돌의 ID/방향 순서, PULL/SHIFT/SWAP 계열, 정확한 화면/키 반복, 두 번째 레벨의 통상 진입·재진입, 원작과의 비교 테스트가 보이지 않는다.

### 의심되는 차이·누락·미확인

- **파서 범위:** Baba Is You의 문장/속성 폭은 현재 3단어 IS 중심 파서보다 넓다. 현재 스코프에서 AND/NOT, 그 이상 길이의 문장, 전치사형 관계, 조건, 신규 어휘를 어디까지 처리할지는 결정·구현되지 않았다.
- **이동과 상호작용:** TIN movement solver는 PUSH/STOP과 MOVE 중심이다. 원작 문법을 충실히 잇는 범위를 목표로 하면 다른 속성의 공간·접촉 효과가 부족하다. 특히 collision rule을 새 authored 레벨마다 하드코딩하는 설계는 피해야 한다.
- **다중 제어:** TIN은 복수 YOU의 이동 요청을 하나의 계획/적용 호출로 합치며 테스트는 양쪽이 이동하는 사례를 작성한다. 원작 자료는 한 방향 입력이 모든 YOU를 대상으로 한다고 하면서 실제 resolution은 object priority/turn queue와 연계함을 설명한다. 현재 TIN의 mixed-blocked 결과가 원작의 해당 배치·목록 순서 사례와 같은지는 비교 테스트가 없어 미확인이다.
- **변환:** 단일 단계 변환과 다중 출력의 선택·복제 규칙은 현 코드의 명시적 선택이다. 원작이 어떤 복수 변환/순환 상태를 갖는지, 키트 콘텐츠가 이 의미를 요구하는지 직접 검증되지 않았다.
- **턴 스케줄:** 코드에 순서가 있지만 그것을 레퍼런스 일치로 볼 비교 근거가 없다. 특히 움직인 단어만 재파싱하는 시점, 자동 MOVE와 규칙변경, 변환 재시도/processed ID, 사망 후 승리의 정확한 계약을 실험으로 확인해야 한다.
- **실패 UX:** 현재 _move_controlled에서 YOU가 없으면 상태 메시지로 끝날 뿐 failed로 설정하지 않는 경로가 있다. 반면 DEFEAT로 마지막 YOU가 제거되면 failed mode로 간다. 레퍼런스에서 “YOU 문장 파괴로 제어 없음”과 “DEFEAT 사망”의 화면·복구가 같은지 관찰하지 못했다.
- **저작 데이터 확장성:** 두 JSON 레벨의 공간/엔티티 데이터는 있으나 신규 ID 등록이 코드맵에 의존한다. 또한 save 검증은 authored noun 범위에 엔티티를 묶으므로 레벨 정의에 없는 콘텐츠를 만들거나 더 일반적인 rule vocab을 추가할 때 제한이 될 수 있다. 정확한 제한은 _grid_matches_level과 level JSON의 조합으로 재확인 필요.
- **진행·화면:** clue card gate, 항상 보이는 활성 룰 목록, 고정 상태 문구 및 한 셀 1문자 표현은 현재 TIN 구현 사실일 뿐 Baba Is You의 화면 문법은 아니다. 장르 화면의 최종 UX 근거로 승격하지 않는다.
- **실행 검증:** 파서 오류, 엔진 import, 실제 키 바인딩, 화면 스케일, 메뉴 복귀, 입력 repeat, save/load의 런타임 결과는 실행하지 않아 미확인이다.

## 7. Kit 계획에 반드시 명시해야 할 계약

계획서는 범위를 채우기보다 검증 가능한 계약을 먼저 적어야 한다. 아래 항목을 해당 Kit의 선택과 자료 증거에 연결해 구체화한다.

1. **선택한 규칙 문법:** 지원하는 noun/property/operator/관계 유형, 문장 길이·방향·AND/NOT·중복·겹침, 단어가 아닌 오브젝트가 문법에 들어오는 방식과 범위 밖 표현 처리.
2. **규칙 갱신 시점:** 어떤 이동/변환/파괴/생성 후 rule set을 다시 만들고, 새 규칙이 같은 턴의 어느 단계부터 유효한지. 최소 재현 레벨과 입력별 기대 결과를 계획에 기록.
3. **충돌과 동시성:** 한 방향 입력의 복수 YOU, 일부 blocked actor, 동일 칸/대상 중첩, PUSH 사슬, 자동 MOVE 및 우선순위. 순서 의존 사례를 정렬 순서 우연에 맡기지 않기.
4. **속성 상호작용 표:** 선택한 속성의 조합별 결과(예: PUSH와 STOP, YOU와 DEFEAT, HOT/MELT, OPEN/SHUT, HAS 등), 존재하지 않는 조합의 기본값, 테스트 가능한 기대 상태.
5. **변환 계약:** Noun IS Noun, 복수 대상, 자기 자신 대상, 변환 연쇄/순환, 정체성·방향·저장 ID, 변환 오브젝트의 동일 턴 행동.
6. **목표와 실패 회복:** WIN 접촉/속성, DEFEAT 우선순위, 일부/전부 YOU 상실, YOU 규칙 파괴로 인한 무조작, 실패 상태에서 undo/reset/menu가 가능한 시점.
7. **Undo/reset 범위:** 한 단계의 정의, history 크기/저장, undo에 포함되는 자동행동·변환·규칙 변경·진행 플래그, reset의 기준 상태와 확인 방식, 레벨 재진입의 저장 효과.
8. **콘텐츠 로딩:** 새 authored content를 추가할 때 수정되는 파일 목록을 명시하고 core 수정 없이 새 레벨 ID를 추가할 수 있는지 입증. 스키마 버전, ID 유일성, 잘못된 데이터 복구/거부.
9. **콘텐츠 배열과 학습:** 각 규칙의 첫 발견, 기존 규칙 재해석, 같은 시스템을 재사용하는 서로 다른 레벨, 실패 시 학습 기회, 10분+ 실측 Reference Game 검증.
10. **진행/해금과 플레이어 지식:** 저장할 플래그와 저장하지 않을 플레이어 지식, 순서 고정/레벨 선택/건너뛰기, 이미 해법을 아는 플레이어의 재진입. 프로젝트의 “지식 그 자체를 게임 상태로 간주하지 않음” 결정을 지킬 것.
11. **화면·입력:** 보드와 화면의 비율·셀/단어 최소 가독성, 겹친 오브젝트, 조작 대상 식별, 메시지/상태 변화, press/hold 반복, menu focus와 close 복귀, 오디오/모션 검증. 근거 화면을 해상도별 캡처와 연결.
12. **입력 버블·저장 경계:** 장르 구간의 물리 키 변화는 KIT_WORKFLOW의 Input Bubble 계약에 따르고, 실제 바인딩 표시/복구를 기술. ModuleContext, JSON-safe versioned state, AppRoot 유지/ModuleHost 교체 경계와 맞춰야 함.
13. **완료 증거:** 1280×720, 1920×1080, 2560×1440 화면, 첫 플레이부터 끝까지 및 실측 플레이시간, 실패·성공·undo/reset·save/load·재진입, 새 authored content 추가 시 core 무수정, placeholder/상시 HUD/금지 UI/확정된 이미지 자산 출처·라이선스 검사를 구체 과제로 포함. 이전 at-icons 오용 검사는 2026-09-25 이미지 기반 전환 지시에 따라 대체한다.

현 Kit 초안은 가설이다. 이 보고서만으로 위 각 항목의 구현 깊이, 레벨 수, 포함 속성이나 UI를 확정하지 않는다.

## 8. 사용자 판단이 필요한 설계 갈림길

프로젝트 전체 방향에서 이미 결정된 한 게임/모듈 경계, 저장·입력 규약, 화면 원칙은 다시 열지 않는다. 위키/공식 자료로 답을 얻은 기계적 사실(예: 복수 YOU에 대한 방향 입력, YOU 상실 시 안내, 문법 카테고리, MOVE stack, object priority)은 사용자에게 “원작에서 어떻게 되나요?”라고 다시 묻지 않는다. 아래 항목만 카탈로그를 본 후 사용자 취향·키트 범위로 남는 갈림길이다.

1. **어휘 버전 범위:** Baba Is You 본편 levelpack의 어휘군만 다룰지, New Adventures의 조건/verb를 포함할지, 481d 및 editor-exclusive 단어까지 선택할지. 각 항목의 노출 상태를 서로 구분하고, “원작 전체 복제”로 자동 확대하지 않는다.
2. **문법 가족과 깊이:** 최소 executable text + IS 외에 HAS/MAKE/WRITE, AND/NOT, prefix/infix conditions, 특수 noun/TEXT/WORD 중 Reference Game의 학습 핵심을 무엇으로 정할지. 10분 이상 서로 다른 authored 상황에 재사용할 수 있는 학습 곡선이 범위 근거다.
3. **상호작용 가족의 대표성:** 이동/방향, 생성, 변환, 접촉 제거, 목표·실패 중 어떤 서로 다른 결과 가족을 실제 레벨에서 반복해 체험시킬지. 규칙 이름 수보다 조합 의미와 재사용 가치로 고른다.
4. **진행과 진입:** 하나의 직선 레벨 흐름에 집중할지, 화면/맥락 근거를 확인한 뒤 map, 자유 레벨 선택, 해금, 재진입까지 Kit에 둘지. 공식 에디터와 대형 levelpack 생태계만으로 월드 맵 구현을 요구하지 않는다.
5. **발견 신호:** 신규 개념을 물리 규칙 조작으로만 제시할지, 발견 실패를 줄이는 contextual signal을 어떤 상태에 허용할지. 화면 캡처 근거와 기존 상시 HUD/장문 설명 금지 원칙을 함께 적용한다.
6. **복구 경험:** 원작 규칙의 입력 단위를 사실로 다시 결정하지 않는다. TIN Reference Game에서 undo/reset/re-entry를 어느 범위까지 노출하고, 장기 undo history와 reset 확인을 어떤 감각으로 제공할지가 선택 사항이다.
7. **콘텐츠 작성 계약:** 새 레벨·새 허용 단어를 data만으로 추가할 수 있어야 하는 정도, 어휘 정의와 상호작용 구현의 경계를 정한다. 외부 공개용 범용 API를 목표로 만들지는 않으며, 새 authored content가 core 수정 없이 추가되는 증거가 필요하다.

## 9. 미확인 사항과 후속 확인 방법

### 사용자 화면 캡처 요청 목록

사용자가 이미 제공한 U01–U10은 위 표에 원본 파일과 설명을 그대로 등록했다. 아래 체크리스트는 화면 상태별 자료의 범위를 정리하는 항목이며, 이미지 분석이나 사용자가 위키에서 확인 가능한 규칙을 다시 실험해 답하는 설문이 아니다. 원본 화면 검토는 후속 실무자와 검토자가 수행한다.

**캡처 묶음에 함께 적을 정보:** platform, UI language, display/window resolution, fullscreen/windowed, control layout/rebinding 화면. UI 레퍼런스 판독에서 게임 version/build는 수집 기준으로 사용하지 않는다. 캡처는 원본 비율의 전체 게임 창으로 저장하고 crop/upscale하지 않는다. 캡처 이름/주석에는 상태, 입력, 순서를 적는다 (예: `baba_<resolution>_multi-you_before.png`, `_after.png`). private account/user details가 보이면 가려도 되지만 게임 UI는 가리지 않는다.

| ID | 상태와 필요한 자료 | 화면에서 비교할 것 | 정지 이미지 외 증거 |
|---|---|---|---|
| U01 | 첫 플레이/신규 저장의 첫 보드 전체 화면 | 보드 화면 점유율, 타일 격자, 첫 이동 안내/입력 힌트, 가장자리, 제목/레벨명, 카메라 여백 | 초기 진입 fade/이동이 있으면 짧은 영상 |
| U02 | 동일 보드에서 일반 한 칸 이동 전/후 | YOU 대상의 시각 표현, 셀 정렬, 글자·sprite 크기, 이동 결과 표시 | 실제 키와 repeat 감각·모션을 보려면 key-down/hold를 포함한 짧은 영상 |
| U03 | 한 단어를 한 번 미는 장면과 PUSH 연쇄 한 장면, 입력 전/후 각 쌍 | 단어·오브젝트 겹침, 밀림 후 정각 정렬, HUD 변화 | 연쇄가 처리되는 애니메이션과 소리, 홀드 반복은 영상/음향 |
| U04 | 벽/STOP 앞 blocked input 전/후 | 화면이 정지하는지, 캐릭터/칸/단어 변화, 입력 안내 또는 턴 상태 | 동일 방향 1회 누름과 짧은 hold 영상. 피드백 sound가 들리는 원본 audio |
| U05 | 규칙이 active인 보드와 단어 하나를 밀어 규칙이 끊긴 후(또는 성립한 후) | active/inactive 텍스트 대비, 색·밝기·파티클, 적용 대상 변화, 별도 rule HUD 유무 | 끊는 입력 직전부터 후속 상태까지 연속 영상·소리 |
| U06 | 화면 안에 YOU인 개체가 둘 이상 보이는 상태의 입력 전/후 | 현재 조작되는 대상을 화면에서 알아볼 수 있는지, 겹침/가려짐과 색·방향 표시 | 모든 YOU가 같은 방향 입력에 반응하는 순간을 보여주는 연속 영상. still pair만으로 동시성 판정 불가 |
| U07 | 마지막 YOU가 없어졌을 때(규칙 파괴 또는 DEFEAT 후) 나타나는 상태 | 문구/overlay 위치와 hierarchy, board 지속 여부, undo/restart 등 선택지와 focus | 음악 fade/상태 전환은 video+audio. wiki는 안내가 있다고 설명하나 외형은 관찰 전 |
| U08 | 같은 한 단계의 이동 전, 이동 후, undo 후; 변경된 상태에서 reset 전/후 | 되돌린 보드가 입력 이전과 일치하는지, undo/reset 접근 표시, reset 확인 여부 | 애니메이션·입력 repeat는 영상. 키 설정 화면도 포함 |
| U09 | WIN 상태와 다음 레벨이 로드된 직후 | 성공 텍스트/효과/보드 전환, 자동/확인 입력의 존재, 다음 레벨 표시 | WIN 입력부터 다음 보드까지 이어지는 짧은 영상과 게임 음향 |
| U10 | pause/menu 열린 전체 화면과 닫은 직후 같은 보드 | menu가 보드를 덮는 방식, 선택 focus, 선택된 항목, background dim, 닫은 뒤 cursor/focus 및 보드 유지 | 메뉴/게임 소리와 close 동작을 확인할 수 있는 짧은 영상 |
| U11 | map/hub가 접근 가능하면 전체 화면, level 진입·이탈/재진입 화면 | level 이름/아이콘, 완료/접근 상태, 선택 표시, 이전 보드로 돌아오는 방식 | level transition 및 map animation 영상 |

모션·오디오·홀드 반복·전환 타이밍은 스크린샷으로 판정하지 않는다. 해당 자료가 없으면 보고서에 “이미지로 확인 불가/별도 자료 대기”로 남긴다. 참조 게임의 해상도를 TIN의 필수 QA resolution에 억지로 맞추지 않는다. reference screenshot에는 실제 표시 해상도를 기록하고, TIN은 계획 단계에서 1280×720/1920×1080/2560×1440 검증을 별도로 유지한다.

### 조사 후속 작업과 미확인 경계

- **사용자 캡처:** U01–U10 원본과 사용자 설명을 부록 인덱스로 보존했다. 이 보고서 작성자는 이미지 내용을 분석하지 않았으므로 보드 비율, actual cell/text size, menu focus, UI selection/highlight, exact transition은 이 이미지들로부터 평가하지 않았다. 후속 검토자가 원본을 직접 판독한다. 모션·오디오·홀드 반복은 정지 이미지로 확인할 수 없다.
- **게임 입력 profile:** S22는 guide key list, S5는 Jam build inputs, E02는 2019 영상의 Z UNDO/P MENU라는 서로 다른 출처의 표기다. 사용자 U10 설명에는 모바일 undo 제스처와 restart 선택지가 기록돼 있다. 키/제스처는 자료에 표시된 실제 입력 맥락과 함께 다루며, 게임 버전은 UI 레퍼런스의 유효성 조건으로 쓰지 않는다.
- **위키/공식 간 범위 교차:** 일반 noun list와 category token을 정리했지만 모든 word/levelpack/entity의 기본 editor palette 노출, 481d 뒤의 플랫폼별/빌드별 반영, 공식 custom-level-only 분류는 확정하지 않았다. KIT scope가 그 갈래에 닿으면 표의 정확한 word page와 현재판을 대조한다.
- **세부 턴 interaction:** S10에서 확인한 stage/priority 모델은 핵심 틀이다. 이미지 링크로 가려진 substage 이름, 선택할 개별 property 조합의 전체 처리, 변환·생성·파괴가 섞인 특별 사례는 해당 레벨을 지원할 만큼의 공식/커뮤니티 증거와 필요 시 TIN 회귀 fixture가 더 필요하다. 일반 원작 기계 원칙을 사용자에게 재질문하지 않는다.
- **원작 progress/save 경계:** map/level entry, completion flags, restart/reentry, undo history의 전체 범위는 아직 실제 상용판 화면 흐름을 확인하지 않았다. 지도와 맵이 있다는 것과 그 흐름을 이 Kit가 채택할지는 다른 질문이다.
- **Reference Game 실측:** 직접 시작부터 종료까지 플레이하지 않았으므로 이번 보고서로 특정 10분 구간/실측 시간을 증명하지 않는다. 후속 Kit 계획에서 고른 authored content를 직접 통과해야 한다.

### 조사 결론

현재 초안의 YOU/PUSH/STOP/WIN/DEFEAT/MOVE 및 변환은 레퍼런스 범위의 일부다. 전체 어휘/문법 카탈로그와 처리 모델은 소스 근거에 맞춰 확장 기록했고, 사용자 판단은 범위 선택으로 재정의했다. UI 자료는 기존 영상 관찰 E01–E03과 사용자가 설명을 붙여 제공한 원본 이미지 U01–U10으로 구분했다. U 이미지의 시각적 해석은 요청에 따라 이 보고서에서 수행하지 않았으며, UI 레퍼런스 목적상 버전 구분도 적용하지 않는다. 현재 TIN 구현은 제한된 파서, 좁은 속성 상호작용, 코드상 ID 맵, 문자 기반 presentation이므로 Baba Is You 전체 문법/UX를 검증하거나 대표하지 않는다. 원본 UI 판독은 후속 실무자·검토자의 작업으로 남긴다.
