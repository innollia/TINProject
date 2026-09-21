# 게임형 모듈 계획 — 환생 왕녀 / Life-Goal World Adventure

작성: 2026-09-21  
상태: **설계 확정 전 구현 계획**  
정식 작품명 / 모듈 ID: 미정

이 문서는 기존 `02_REINCARNATOR_ROAD.md`의 "장면을 순서대로 보는 로드무비" 해석을 폐기하고, 같은 설정을 **실제로 플레이 가능한 게임 시스템**으로 다시 설계한다.

---

## 0. 무엇이 게임인가

이 작품의 핵심은 여행 자체도, 왕녀 서사 자체도 아니다.

플레이어는 **한 생 동안 절대 바뀌지 않는 기괴한 인생목표들을 가진 환생자**를 조작한다.  
지역을 돌아다니고, 사람·사물·제도·동물과 상호작용하면서 세계 상태를 바꾼다.  
그 결과가 다른 장소와 인물에게 전파되고, 어느 순간 플레이어가 의도했든 아니든 인생목표의 조건이 충족된다.

즉 기본 루프는:

```text
지역 탐색
→ 사람/사물과 상호작용
→ WorldState 변화
→ 다른 상호작용/지역 반응 변화
→ LifeGoal 조건 재평가
→ 예상 밖의 목표 달성 또는 새로운 해결 경로 발견
→ 다음 장소로 이동
```

**"퀘스트를 받아서 목적지 마커로 가서 완료"가 아니다.**

인생목표는 세계를 돌아다니게 만드는 이유이면서 동시에  
플레이어가 세계의 규칙을 엉뚱하게 이용하도록 만드는 장기 퍼즐 조건이다.

---

# 1. 레퍼런스와 변형 경계

## 1.1 1차 레퍼런스 — West of Loathing

가져올 감각:

- 이상한 세계 상식이 일상처럼 취급됨
- 짧은 상호작용 하나에도 개그/발견이 있음
- 메인 목적 외의 옆길을 자주 파게 됨
- 장소를 돌아다니며 엉뚱한 문제와 사람을 만남
- 텍스트와 플레이가 분리되지 않음

복제하지 않을 것:

- 원작 세계관
- 원작 전투
- 원작 스탯/장비
- 원작 개그 문구
- 서부극 구조

## 1.2 TIN에서의 변형

이 모듈은 일반 RPG보다 **세계 상태 퍼즐 어드벤처**에 가깝게 만든다.

- 전투는 코어 시스템이 아님
- 레벨/경험치 성장 없음
- 퀘스트 로그 중심 진행 없음
- 하나의 정답 루트만 강제하지 않음
- 같은 상호작용 대상도 세계 상태에 따라 다른 행동을 제공
- 한 장소의 행동이 다른 장소의 상태를 바꿀 수 있음
- 인생목표 완료 자체가 경험치/재화 보상이 아님

---

# 2. 사용자 확정 설정과 AI 제안을 분리

## 2.1 사용자 제공 원재료

다음은 사용자 아이디어에서 직접 온 내용이다.

- 몰락한 왕국의 세 번째 왕녀
- 3년 전 왕녀라는 정치적 지위가 거의 말살됨
- 충실한 종 여섯과 도주
- 도시 수색을 피해 시골 마을에서 서민처럼 숨어 삶
- 전생의 기억을 간직한 환생자
- 기억은 기본적으로 봉인
- 현재 삶이 자살하지 않을 정도로 마음에 들면 기억을 계속 봉인해 둘 수 있음
- 위기의 순간에 기억이 먼저 풀리고, 주인공이 그 현상 때문에 오히려 "지금이 위기"라고 깨닫는 장면
- 도파민 역치가 높은 환생자답게 삶마다 인생목표의 기준이 매우 까다롭고 변칙적
- 한 생 동안 인생목표는 바뀌지 않음
- 확정된 인생목표 예시 하나:
  - **현재 국가의 정반대편 국가에 있는 마사지사에게 마사지 받기**
- 여러 이상한 목표를 예기치 않게 하나씩 달성
- 마지막에 전부 달성할 상황이 되고서야 그것이 윤회의 고리를 끊고 영원한 죽음으로 가는 조건이었다는 장기 반전
- 시골에서 오랫동안 건실한 인상을 쌓은 뒤 혈통을 공개하는 "혈밍아웃", 비교적 잘 받아들여짐
- 공룡을 타고 다니고 감자가 주적인 세계 아이디어
- 많이 먹여 수호신이 뚱뚱해지는 모습을 좋아하는 종교
- 눈이 하나뿐인 교복 차림 고등학생이 자신을 귀환자라고 소개하며 이세계 학교 이야기를 함
- 주인공 자신은 이 지구에서만 환생하며 살아옴
- 아침에 맥락 없는 문장/비문/모르는 단어가 머리에 떠오름
- 시나: 주인공보다 두 살 많고 장난이 많은 시녀
- 귀이개/칫솔 장면

## 2.2 아직 미정

다음은 계획서에서 임의로 확정하지 않는다.

- 왕국 이름
- 왕녀 이름
- 다른 인생목표들의 실제 문구
- 마사지사가 있는 국가 이름
- 마사지 목표를 실제로 어떻게 달성하는지
- 맥락 없는 문장이 전생 기억인지, 다른 세계 신호인지, 다른 원인인지
- 여섯 종의 이름과 성격
- 감자가 왜 적인지
- 공룡 문화의 세부 구조
- 귀환자 학생의 정체와 진위
- 최종 윤회 종료의 정확한 규칙

테스트에 필요한 임시 값은 **fixture**로만 만들고 정본 설정으로 취급하지 않는다.

---

# 3. 플레이어가 실제로 하는 행동

## 3.1 필수 동사

첫 구현에서 플레이어 동사는 다음 정도로 제한한다.

- 이동
- 살펴보기
- 대화
- 집기 / 내려놓기
- 사용하기
- 건네기
- 타기 / 내리기
- 장소 이동

모든 상호작용 대상이 모든 동사를 지원할 필요는 없다.

대상 앞에서 Z:
- 가능한 행동이 하나면 즉시 실행
- 둘 이상이면 작은 contextual action menu 표시

X:
- 취소 / 메뉴 닫기

정밀 타이밍, 연타, 어려운 액션 조작을 코어 진행에 사용하지 않는다.

## 3.2 왜 이 동사들이 필요한가

이 게임의 재미는 "정답 선택지 고르기"가 아니라  
**같은 세계 상태를 여러 수단으로 바꾸는 것**에서 나온다.

예:

- 사람에게 직접 부탁
- 다른 물건을 건네 태도 변경
- 주변 사물을 먼저 건드려 새로운 대화 발생
- 다른 지역에서 생긴 사건 때문에 현재 NPC 행동 변경
- 탈것/문/시설 상태를 바꿔 새 장소 접근

따라서 상호작용 결과를 긴 if문으로 하드코딩하지 않고 데이터 규칙으로 만든다.

---

# 4. 핵심 시스템 A — WorldState

WorldState가 게임의 진실이다.

씬 노드 상태가 진실이 되면 안 된다.

## 4.1 저장 구조

```text
facts: Array[String]
counters: Dictionary[String, int]
states: Dictionary[String, String]
relations: Dictionary[String, String]
inventory: Array[String]
visited_locations: Array[String]
completed_interactions: Array[String]
```

예시는 모두 fixture이며 정본 설정이 아니다.

```text
facts:
  village.knows_princess_is_reliable
  stable.dinosaur_is_available

states:
  village.well = "working"
  stable.gate = "open"

relations:
  sina = "close"
  villager_baker = "familiar"
```

## 4.2 규칙

- 모든 key는 namespace 사용
- Node/Resource/Callable 저장 금지
- save_state는 JSON-safe
- 씬 재진입 시 WorldState에서 화면 재구성
- 상호작용 하나 때문에 별도 boolean 멤버를 무한 추가하지 않음

---

# 5. 핵심 시스템 B — Predicate / Effect

인생목표, 상호작용 조건, 장소 변화, 위기 조건이  
각각 자기만의 판정 시스템을 만들지 않는다.

공통 predicate/effect 언어를 사용한다.

## 5.1 Predicate 종류 1차

```text
has_fact
lacks_fact
state_equals
state_not_equals
counter_at_least
counter_at_most
has_item
lacks_item
relation_equals
visited
all
any
not
```

## 5.2 Effect 종류 1차

```text
add_fact
remove_fact
set_state
add_counter
set_relation
give_item
remove_item
open_location
emit_observation
start_encounter
```

1차 구현에서 script callback을 content data에 넣지 않는다.

정말 특수한 장면만 module-local scripted event를 별도로 가진다.

---

# 6. 핵심 시스템 C — Interaction Resolver

모든 사물/NPC의 반응은 `InteractionDefinition`으로 작성한다.

## 6.1 구조

```text
interaction_id
target_id
verb
variants[]
```

variant:

```text
priority
requires[]
text/event_id
effects[]
once
```

Resolver 순서:

1. 대상 + verb로 후보 찾기
2. requires가 모두 참인 variant만 남김
3. priority 높은 것 선택
4. 동률이면 안정적인 authoring order
5. text/event 실행
6. effects commit
7. WorldReactionSystem 실행
8. LifeGoalEvaluator 실행
9. CrisisSystem 실행
10. 화면 refresh

## 6.2 중요 효과

같은 빵집 주인에게 말을 걸어도:

- 처음 방문
- 도움을 준 후
- 왕녀의 정체를 아는 후
- 마을 전체 사건 이후

각각 다른 variant를 사용할 수 있다.

새 분기를 위해 `module.gd`에 if문을 추가하지 않는다.

---

# 7. 핵심 시스템 D — World Reaction

이 시스템이 있어야 장소들이 독립된 미니게임이 아니라 **하나의 세계**가 된다.

`ReactionDefinition`:

```text
reaction_id
requires[]
once
effects[]
presentation_event
```

상호작용 또는 이동 뒤 조건을 검사한다.

예시 fixture:

```text
A 지역에서 수문을 열었다
→ world fact 변경
→ B 지역의 진흙 상태 변경
→ B 지역 NPC의 이동 경로/대사/상호작용 변경
```

직접 A가 B 노드를 참조하지 않는다.

둘 다 WorldState만 읽는다.

## 완료 기준

첫 수직 슬라이스에 반드시:
- **다른 장소에서 한 행동이 현재 장소에 영향을 주는 반응 2개 이상**
- 되돌아갔을 때 실제 화면/상호작용 변화 확인

---

# 8. 핵심 시스템 E — Life Goal

이 게임의 고유 시스템.

## 8.1 목표는 퀘스트가 아니다

한 생의 인생목표 목록은 **게임 시작 시 전부 제시되며 그 생이 끝날 때까지 추가·교체되지 않는다.**

플레이어에게 보이는 형식:

```text
"현재 국가의 정반대편 국가에 있는 마사지사에게 마사지 받기"
[미완료]
```

다른 실제 목표 문구는 사용자 미정이므로 계획서가 생성하지 않는다.

보이지 않는 것:

- 세부 progress %
- 목적지 marker
- "다음 행동"
- 숨은 조건 숫자
- 경험치 보상

## 8.2 GoalDefinition

```text
goal_id
display_text
visible_from_start
completion_predicate
completion_event
```

여러 방식의 완료를 허용하려면:

```text
completion_predicate:
  any:
    - all: [...]
    - all: [...]
```

## 8.3 판정 시점

다음 뒤마다 전체 미완료 goal을 재평가:

- committed interaction
- travel
- encounter resolution
- scripted world reaction

목표가 처음 참이 되는 순간:

1. completed에 기록
2. 짧은 전용 연출
3. 주인공 반응
4. 기록에 completion event
5. XP/재화 없음
6. 게임을 멈추지 않고 그대로 플레이 계속

## 8.4 예상 밖의 달성

중요 설계 규칙:

**모든 인생목표를 플레이어가 직접 추적하게 만들지 않는다.**

목표 중 일부는:
- 다른 목적을 수행하는 중
- 전혀 다른 사람을 도와주다가
- 지역 상태가 바뀐 결과
- 우연히 생긴 이동 경로 때문에

달성될 수 있어야 한다.

이 "어? 이걸 지금 깼어?"가 주요 도파민 포인트다.

## 8.5 테스트 목표와 플레이 감각 검증

사용자가 실제 추가 목표를 아직 정하지 않았으므로 자동 테스트에는 **fixture goal**을 사용한다.

두 종류를 분리한다.

1. **unit-test fixture**
   - 플레이어에게 절대 노출하지 않음
   - GoalEvaluator 정확성 검증

2. **development-only feel fixture**
   - 개발 빌드 수직 슬라이스에서만 잠시 노출 가능
   - 일부러 unrelated interaction chain 도중 갑자기 완료되도록 설계
   - "어? 이게 여기서 깨져?"라는 핵심 감각을 사람이 직접 검수
   - 정식 빌드 전 반드시 제거하고 사용자 확정 목표로 교체

AI가 만든 fixture 문구는 정본 설정이 아니다.

---

# 9. 핵심 시스템 F — 지역과 이동

## 9.1 구조

하나의 거대한 seamless map을 만들지 않는다.

```text
RegionGraph
  ├─ location A
  ├─ location B
  ├─ location C
  └─ routes
```

각 location은 독립 씬이나 data-driven scene.

`LocationDefinition`:

```text
location_id
scene
display_name
spawn_points
interaction_set
local_reactions
exits
```

`RouteDefinition`:

```text
from
to
requires[]
arrival_spawn
travel_event_pool
```

## 9.2 플레이 감각

- 마을 안은 직접 걸어다님
- 멀리 떨어진 지역은 지도에서 이동
- 지도는 퀘스트 마커가 아니라 **이미 아는 장소와 연결 관계**만 보여줌
- route가 열리는 이유는 대화/물건/세계 상태 등 다양

## 9.3 첫 수직 슬라이스

최소 세 location:

1. 왕녀가 숨어 사는 집
2. 시골 마을 중심부
3. 마을 외곽 / 이동수단이 있는 공간

정식 지명은 만들지 않는다.

플레이어는 세 장소를 반복 왕복 가능해야 한다.

---

# 10. 핵심 시스템 G — Encounter / Obstacle

깊은 전투를 만들지 않는다.

감자 등 적대 요소도 기본적으로 **세계 상호작용 문제**로 처리한다.

`ObstacleDefinition`:

```text
obstacle_id
active_when[]
blocks[]
resolution_variants[]
```

resolution은 Predicate + Effect로 구성.

하나의 장애물에 최소 2개 이상의 실제 해결 경로를 허용할 수 있다.

예시로 공룡/감자 조합을 사용할 수 있으나  
구체 관계는 사용자 미확정이므로 **AI 제안 fixture**로만 작성한다.

금지:
- HP를 깎아 이기는 것이 기본 해결법
- 3지선다 메뉴만 누르면 해결
- 정밀 회피/액션 성공이 필수

---

# 11. 핵심 시스템 H — Memory Seal

이 시스템은 플레이어 능력 버튼이 아니다.

## 11.1 상태

```text
sealed
leaking
partial
released
```

## 11.2 CrisisDefinition

```text
crisis_id
requires[]
minimum_memory_state
memory_fragment_id
effects[]
once
```

세계 상태가 crisis 조건을 만족하고  
해당 사건이 memory release를 허용하면 자동 실행.

## 11.3 핵심 장면 지원

반드시 가능한 흐름:

1. 플레이어와 주인공 모두 평범한 상황으로 인식
2. 특정 세계 상태가 조합됨
3. 갑자기 전생 기억 한 조각이 해금
4. 주인공이 **기억이 풀렸다는 사실 때문에**
   현재 상황이 위험하다는 것을 역으로 깨달음
5. 새 행동/정보가 생김
6. 위기 처리

기억이 미래를 예언하는 만능 힌트 시스템이 되면 안 된다.

실제 정식 crisis 내용이 아직 없으면 첫 수직 슬라이스 개발 빌드에는 **development-only crisis fixture** 하나를 둔다.
목적은 "위기라고 몰랐는데 기억이 먼저 풀려 위험을 인지한다"는 감각 검증뿐이다.
정식 빌드 전에 제거하거나 사용자 확정 사건으로 교체한다.

## 11.4 저장

```text
memory_state
released_fragments[]
crisis_seen[]
```

기억 fragment가 제공한 정보는 WorldState의 knowledge fact로 연결 가능.

---

# 12. Nonsense Text Leak

아침에 떠오르는 비문/모르는 단어는 **원인을 아직 확정하지 않는다.**

따라서 1차 구현에서는 별도 presentation/event 시스템만 둔다.

`TextLeakDefinition`:

```text
id
trigger
text
once
```

첫 확정 문장:

```text
마늘 먹고 매운 혀 치약 맛보고 매워한다
```

이 텍스트가:
- 전생 기억
- 다른 세계
- 미래
- 신탁

중 무엇인지 코드 변수명에도 넣지 않는다.

예:
`memory_message` 금지  
`text_leak` 사용

---

# 13. 사회적 위장 / 혈밍아웃

"신뢰 게이지 73/100" 방식은 사용하지 않는다.

## 13.1 관계 상태

NPC 또는 집단마다 discrete state:

```text
unknown
familiar
reliable
trusted
```

구체 상태명은 구현 시 바꿀 수 있음.

## 13.2 마을 평가

개별 행동이 world facts를 만든다.

예:
- 특정 도움
- 약속 이행
- 반복 방문
- 문제 해결

후반의 혈밍아웃 사건은  
필요한 사실/관계 상태 조합을 검사해 반응 variant가 달라진다.

**오래 신뢰를 쌓은 뒤 다행히 잘 받아주는 사용자 아이디어가 기본 방향**이다.

첫 수직 슬라이스에서는 혈밍아웃 자체를 구현하지 않아도 된다.  
대신 이후 장면을 받을 수 있도록 관계 상태 시스템까지만 증명한다.

---

# 14. 단기 동기 — 퀘스트 로그 없이 길을 잃지 않게 하기

인생목표는 너무 장기적이므로 그것만으로 매 순간 행동 방향을 제공하지 않는다.

대신 각 location은 **즉시 눈에 보이는 문제/이상현상/호기심거리 1~3개**를 가진다.

예:
- 누군가 뭔가를 못 하고 있음
- 평소와 다른 물체 상태
- 갈 수 있는데 이유가 이상한 길
- 대화 중 나온 장소/사람
- 눈앞에서 벌어지는 작은 사고

중요:
- UI에 "서브퀘스트 3/7"로 등록하지 않음
- objective marker 없음
- 완료 체크리스트 없음
- NPC 대사, 환경, 지도 변화로만 다음 가능성을 암시

플레이어가 막히면 다른 location을 가도 된다.

이 구조의 역할:
- **인생목표 = 장기 방향과 큰 놀람**
- **지역의 문제/호기심 = 30초~10분 단기 동기**

---

# 15. 첫 35~60분 수직 슬라이스

중요: 아래는 **Scene 1→2→3의 직선 진행표가 아니다.**

첫 5분 이후 세 장소를 자유롭게 왕복하면서 플레이한다.

## 15.1 시작 5분 — 집

확정 콘텐츠:

- 아침 text leak
- 화장실 이동
- 혼자 양치 시도
- 귀이개/칫솔 혼동
- 시나 장난
- 왕녀가 평민 생활에 익숙하지 않다는 점

여기서 플레이어가 직접:
- 방을 이동
- 물건을 조사
- 시나에게 대화
- 물건을 집고 사용

해야 한다.

긴 자동 대화만 재생하고 끝내지 않는다.

## 15.2 집의 선택 상호작용

최소:
- 조사 대상 8개
- 상태가 변하는 대상 3개
- 시나 대화 variant 4개 이상
- 한 상호작용이 다른 상호작용을 바꾸는 조합 2개 이상

정식 소품 설정은 사용자 확인 전 fixture 가능.

## 15.3 마을 중심부

목표:
- "왕녀가 숨어 사는 장소"를 실제 생활 공간으로 만들기
- 플레이어가 건실한 인상을 쌓아 왔음을 설명문이 아니라 반응으로 확인

최소:
- NPC 4명
- 상호작용 대상 10개
- 반복 대화 variant
- 집에서 한 행동 때문에 반응이 바뀌는 대상 1개 이상
- 외곽 행동 때문에 나중에 반응이 바뀌는 대상 1개 이상

이곳에 모든 lore를 몰아넣지 않는다.

## 15.4 외곽

사용자 아이디어 중 다음을 실제 게임 오브젝트 후보로 사용 가능:

- 공룡 탈것
- 적대적 감자

단, 둘의 정확한 관계/생태는 미정.

첫 slice에서 보여줘야 하는 것은:
- 탈것과 상호작용할 수 있음
- 장애물에 여러 해결 경로가 있음
- 외곽 상태를 바꾸면 마을/집에 반응이 돌아옴

## 15.5 인생목표 화면

첫 slice에서 실제 사용자 확정 goal 하나만 노출:

> 현재 국가의 정반대편 국가에 있는 마사지사에게 마사지 받기

현재는 달성 불가여도 됨.

화면은 "이 게임의 장기 방향"을 보여주는 역할.

다른 실제 goal은 사용자가 추가하기 전까지 release 콘텐츠로 임의 생성하지 않는다.

다만 개발 빌드에서는 8.5의 development-only fixture goal 하나를 사용해 **목표가 예상 밖의 순간 완료되는 연출과 감각을 반드시 직접 검수**한다.

## 15.6 slice의 종료

"마사지를 받으러 여행을 출발한다" 컷신으로 끝내지 않는다.

완료 gate는 시스템 증명이다:

- 세 장소 왕복
- cross-location reaction 2개 이상
- 상태 기반 대화 변화
- inventory/use 1개 이상
- obstacle multiple solution
- LifeGoal evaluator 동작을 fixture test로 검증
- TextLeak
- save/load

그 뒤 플레이어는 계속 돌아다닐 수 있다.

---

# 16. 피드백과 도파민 계층

이 게임은 XP/레벨업으로 보상감을 만들지 않는다.

플레이어 행동의 결과가 **즉시 세계에 반영되는 것**을 보상으로 삼는다.

## 16.1 Micro — 1~10초

의미 있는 상호작용에는 최소 하나:

- 짧은 애니메이션
- 물체 상태 변화
- NPC 반응
- 새로운 한 줄
- 화면상 위치/모양 변화

같은 피드백이 있어야 한다.

"Z를 눌렀는데 설명문만 읽고 아무것도 안 바뀜"이 반복되지 않게 한다.

## 16.2 Meso — 1~10분

다른 장소의 변화, 새 route, 이전 NPC의 새 반응 등.

플레이어가:
> 아까 그거 때문에 이게 이렇게 됐네

를 알아차릴 수 있어야 한다.

## 16.3 Macro — 드문 큰 사건

- 인생목표 예상 밖 완료
- 위기에서 기억 해금
- 큰 정체성/세계 반응
- 장기 route 변화

큰 피드백을 자주 주지 않는다. 희소해야 효과가 있다.

## 16.4 대화 구현

새 범용 dialogue engine을 만들지 않는다.

현재 TIN의 `TinIntegrationKit` 대화 기능을 우선 사용한다.

InteractionVariant는 필요할 때:
- dialogue id
- line set
- choice set
를 presentation 계층에 전달한다.

대화 선택 결과도 최종적으로 Effect로 WorldState를 바꾼다.

---

# 17. 콘텐츠 밀도 규칙

게임이 30분짜리 컷신 묶음이 되는 것을 막는다.

## 한 location 최소 권장치

- 직접 이동 가능한 공간
- 상호작용 대상 8~15
- NPC 2~5
- state-changing interaction 3+
- 세계 상태에 따른 variant 4+
- 다른 location과 연결된 reaction 1+
- optional gag 2+
- 반드시 보지 않아도 되는 상호작용 비율 40% 이상

## 10분 콘텐츠 단위

새 콘텐츠 10분을 추가할 때:
- 대화 10분 추가 금지
- 최소 1개의 새로운 상태 변화
- 기존 대상의 새 variant
- 다른 장소와의 연결 반응
중 2개 이상 포함.

---

# 18. 오픈소스 베이스

## 18.1 1차 참고/부분 포팅 — GDQuest Godot Open RPG 0.4.0

repository:
`gdquest-demos/godot-open-rpg`

license:
MIT

tag:
`0.4.0`

commit:
`ff4f907d71385d459e64383f799700e998518153`

Godot:
4.4+

확인한 유용한 구조:
- `src/field/cutscenes/interaction.gd`
- `src/field/cutscenes/templates/area_transitions/area_transition.gd`
- `src/field/gamepieces/controllers/player_controller.gd`
- `src/field/map.gd`

### 판정

**전체 프로젝트 vendoring 금지.**

이유:
- Player / Camera / CombatEvents / FieldEvents / Gameboard 등 전역 의존이 많음
- 전투 시스템까지 포함
- TIN의 autoload 금지 및 ModuleContext 입력 계약과 충돌

### 가져올 가치가 있는 것

코드 직접 복사 전에 파일별 라이선스 고지를 보존하며 다음 패턴만 포팅 후보:

- interaction area가 플레이어 인접 상태를 감지하는 방식
- interaction target selection
- area transition lifecycle
- map/field를 분리하는 구조

### 새로 작성할 것

- TIN용 player controller
- WorldState
- PredicateEvaluator
- EffectExecutor
- InteractionResolver
- LifeGoalEvaluator
- WorldReactionSystem
- MemorySealSystem

## 18.2 Popochiu

현재 TIN에는 이미 Popochiu의 hotspot/inventory/room 개념을 조사해 만든 `TinIntegrationKit`이 있다.

따라서 이 모듈을 위해 Popochiu 전체 addon을 다시 설치하지 않는다.

---

# 19. 파일 구조

```text
modules/<REINCARNATOR_MODULE_ID>/
  module_manifest.tres
  entry.tscn
  module.gd

  domain/
    world_state.gd
    predicate.gd
    effect.gd
    interaction_definition.gd
    interaction_variant.gd
    reaction_definition.gd
    goal_definition.gd
    location_definition.gd
    route_definition.gd
    obstacle_definition.gd
    crisis_definition.gd
    text_leak_definition.gd

  systems/
    predicate_evaluator.gd
    effect_executor.gd
    interaction_resolver.gd
    reaction_system.gd
    goal_evaluator.gd
    travel_system.gd
    obstacle_resolver.gd
    memory_seal_system.gd
    text_leak_system.gd
    save_codec.gd

  field/
    player_controller.gd
    interaction_sensor.gd
    interactable.gd
    area_exit.gd
    location_host.gd

  ui/
    interaction_menu.gd
    dialogue_panel.gd
    goal_panel.gd
    inventory_panel.gd
    world_map.gd
    text_leak_overlay.gd

  content/
    locations/
      home.tres
      village.tres
      outskirts.tres
    interactions/
    reactions/
    goals/
    crises/
    text_leaks/

  scenes/
    home.tscn
    village.tscn
    outskirts.tscn
```

테스트:

```text
tests/core/
  test_reincarnator_predicates.gd
  test_reincarnator_effects.gd
  test_reincarnator_interactions.gd
  test_reincarnator_reactions.gd
  test_reincarnator_goals.gd
  test_reincarnator_travel.gd
  test_reincarnator_memory.gd
  test_reincarnator_save.gd
  test_reincarnator_module_contract.gd
```

---

# 20. module.gd 책임

module.gd는 오케스트레이션만 한다.

책임:
- GameModule lifecycle
- ModuleContext 입력 enable 확인
- 현재 location host 관리
- subsystem 생성/연결
- save/load/migrate
- TIN requested signal
- location 전환

금지:
- 개별 NPC 분기
- 개별 goal 조건
- 감자/공룡 전용 로직
- 대화 내용 하드코딩
- 직접 AppRoot 접근

---

# 21. 저장 schema v1

```json
{
  "location_id": "home",
  "spawn_id": "bedroom",
  "world": {
    "facts": [],
    "counters": {},
    "states": {},
    "relations": {},
    "inventory": [],
    "visited_locations": [],
    "completed_interactions": []
  },
  "goals": {
    "completed": []
  },
  "memory": {
    "state": "sealed",
    "released_fragments": [],
    "crisis_seen": []
  },
  "text_leaks_seen": []
}
```

### load 규칙

- unknown location → 안전한 시작 위치
- 삭제된 interaction id → completed 목록에서 제거 가능
- 삭제된 item id → content registry 기준 sanitize
- unknown state key는 보존 여부를 schema version 정책으로 결정
- malformed values → fallback
- crash 금지

---

# 22. 구현 단계 — 저지능 모델용 작업 분해

## Phase 0 — 베이스 읽기

읽을 것:
- TIN GameModule contract
- ModuleContext
- SaveService 규칙
- GDQuest Open RPG의 interaction / area transition / player controller

산출물:
- `docs/reincarnator_base_audit.md`

반드시 기록:
- 실제 포팅 파일
- 구조 참고만 한 파일
- 버린 전역 의존

## Phase 1 — 순수 domain

구현:
- WorldState
- Predicate
- Effect
- evaluator/executor

이 단계에서는 scene/UI 금지.

Gate:
- unit tests 통과

## Phase 2 — Interaction

구현:
- InteractionDefinition
- Resolver
- variant priority
- once
- effects

Gate:
- 같은 target이 world state에 따라 세 variant를 정확히 선택

## Phase 3 — Reaction + Goal

구현:
- ReactionSystem
- GoalEvaluator

Gate:
- A interaction → reaction → B state 변경
- fixture goal 자동 완료
- goal 완료 중복 없음

## Phase 4 — Field

구현:
- top-down player
- interaction sensor
- location host
- area exit

Gate:
- home test scene에서 이동/조사/대화/사용
- input disabled 시 완전 정지

## Phase 5 — Travel

3 location 연결.

Gate:
- 왕복
- spawn point
- 이전 world state 유지
- 다른 장소 reaction 화면 반영

## Phase 6 — Memory / Text leak

Gate:
- 평범한 action 후 crisis predicate 성립
- memory fragment 자동 해금
- 새 interaction variant 등장
- text leak 원인과 memory system을 코드상 분리

## Phase 7 — 실제 사용자 콘텐츠

순서:
1. 아침 문장
2. 양치/귀이개
3. 시나
4. 집 optional interactions
5. 마을 반응
6. 외곽
7. 공룡/감자 후보 콘텐츠

정식 이름/미정 설정을 모델이 임의 확정하지 않는다.

## Phase 8 — 콘텐츠 밀도

각 location의 minimum density 채움.

Gate:
- 필수 상호작용만 직선으로 따라가도 작동
- 옆길 탐색 시 플레이 시간이 의미 있게 늘어남
- optional content를 안 봐도 진행 가능

---

# 23. 테스트 세부

## Predicate

- all/any/not
- missing key
- counter numeric normalize
- state
- relation
- inventory
- visited

## Effect

- idempotent fact
- counter
- item add/remove
- invalid effect 거부
- JSON-safe

## Interaction

- priority
- requirements
- once
- fallback variant
- state 변경 후 variant 변경

## Reaction

- cross-location reaction
- once
- reaction chain
- 무한 reaction loop 감지

반드시 reaction chain 최대 실행 수를 둔다.
예: 한 commit당 64 reaction 초과 시 오류 처리.

## Goal

- 처음 false
- world 변화 후 true
- 중복 완료 없음
- any-of solution
- visible goal과 test fixture 분리

## Memory

- crisis 전 해금 없음
- crisis 성립 시 자동 해금
- 같은 crisis 재실행 없음
- save/load
- memory fragment가 없으면 안전하게 넘어감

## Field

- movement
- collision
- interaction range
- action menu
- pause/input disable
- transition 중 입력 없음

## Save

- 각 location에서 round-trip
- interaction 직후
- reaction 직후
- goal 완료 직후
- memory release 직후
- stale content sanitize

---

# 24. "멋진 게임" 판정 게이트

시스템이 작동하는 것만으로 완료 처리하지 않는다.

첫 slice 리뷰에서 다음 질문에 모두 YES여야 한다.

1. 5분 이상 대사만 읽는 구간 없이 계속 직접 움직이고 건드릴 수 있는가?
2. 같은 장소에 다시 왔을 때 실제로 바뀐 것이 보이는가?
3. 다른 장소에서 한 행동이 예상 밖의 반응으로 돌아오는가?
4. 한 장애물을 적어도 두 방식으로 해결할 수 있는가?
5. 상호작용 대상 대부분이 한 줄짜리 장식물이 아니라 상태에 따라 변하는가?
6. 인생목표가 일반 퀘스트처럼 느껴지지 않는가?
7. 플레이어가 "이것도 목표 조건에 들어가나?"라고 세계를 실험할 여지가 있는가?
8. 기억 해금이 힌트 버튼이 아니라 사건처럼 느껴지는가?
9. optional 상호작용을 찾아다닐 이유가 텍스트 자체의 재미와 세계 변화에 있는가?
10. 30분을 채우기 위해 같은 행동을 반복시키지 않았는가?

하나라도 NO면 콘텐츠를 더 넣기 전에 해당 구조부터 고친다.

---

# 25. 명시적 금지

- Scene 1→2→3→4 식 직선 컷신 진행을 "게임"이라고 부르기
- 여행 거리를 플레이 시간으로 부풀리기
- 무작위 전투로 분량 늘리기
- 인생목표마다 마커/체크리스트/XP 지급
- 목표 하나당 전용 if문
- 모든 상호작용을 3지선다 대화 선택으로 해결
- 기억을 플레이어가 임의로 꺼내는 스킬로 만들기
- text leak 원인을 임의 확정
- 왕국/국가/NPC 이름 임의 정본화
- 공룡/감자 설정을 AI가 멋대로 확정
- 혈밍아웃을 단순 수치 100 달성 이벤트로 만들기
- TIN 전체에 전역 inventory/quest/reputation 시스템 추가

---

# 26. 콘텐츠 검증기

데이터 기반 구조는 저지능 모델이 문자열 ID를 틀리기 쉽다.  
따라서 구현 초기에 `content_validator.gd`를 만든다.

검사 대상:

- 중복 interaction_id
- 존재하지 않는 target_id
- 존재하지 않는 location_id
- route의 from/to 누락
- Predicate가 참조하는 미등록 state key
- Effect가 잘못된 타입의 값을 쓰는 경우
- goal이 존재하지 않는 id를 참조
- reaction cycle 가능성
- crisis의 memory fragment 누락
- 같은 once id 중복
- 시작 location 없음

개발/테스트에서는 invalid content를 **조용히 무시하지 말고 실패**시킨다.

release load에서 오래된 save의 unknown content id는 sanitize 가능하지만,
작성 중인 content definition 자체의 오류는 테스트 실패로 잡는다.

## ID registry

최소한 다음 registry를 content load 시 만든다.

```text
location_ids
target_ids
interaction_ids
reaction_ids
goal_ids
crisis_ids
item_ids
known_state_keys
```

임의 문자열 오타가 새로운 state key로 자동 생성되지 않게 한다.

---

# 27. TIN 모듈 경계

이 게임 안의 `home → village → outskirts` 이동은 **하나의 GameModule 내부 location 전환**이다.

TIN의 ModuleDirector를 location 이동에 사용하지 않는다.

- 내부 location은 module local
- 다른 TIN 게임으로 넘어갈 때만 `requested("portal")`
- module-local inventory/reputation/world facts를 AppRoot/global에 노출하지 않음
- module-local item은 다른 게임으로 전달하지 않음
- 재진입 시 이 모듈의 저장을 어떻게 복원할지는 TIN의 기존 module save 계약을 따름

몸과 기억만 게임 경계를 통과한다는 프로젝트 원칙과 충돌하지 않게 한다.

---

# 28. 이후 콘텐츠가 늘어나는 방식

이 구조가 완성되면 새 콘텐츠 추가는 시스템 코드를 거의 수정하지 않고:

- location 하나 추가
- NPC/대상 추가
- interaction variants 추가
- reaction 추가
- route 추가
- life goal 추가
- crisis 추가

로 끝나야 한다.

**30분 → 2시간 → 8시간 확장은 코드 규모보다 authored world graph의 밀도가 커지는 방식**이어야 한다.
