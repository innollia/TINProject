# 게임형 모듈 계획 — 환생 왕녀 / Life-Goal Systemic Sandbox

작성: 2026-09-21  
상태: **설계 확정 전 구현 계획**  
정식 작품명 / 모듈 ID: 미정

이 문서는 기존 `02_REINCARNATOR_ROAD.md`의 "장면을 순서대로 보는 로드무비" 해석을 폐기하고, 같은 설정을 **실제로 플레이 가능한 게임 시스템**으로 다시 설계한다.

---

## 0. 무엇이 게임인가

이 작품의 핵심은 여행도, 대화도, 퀘스트 수행도 아니다.

플레이어는 **기괴한 고정 인생목표를 가진 환생자**를 조작하지만,
실제 손에 잡히는 재미는 **작은 공간 안의 사람·동물·물건·장치·환경을 직접 조작해서 상황을 만들어내는 것**이다.

걷기는 위치를 바꾸기 위한 보조 행동이다.
대화는 상황의 반응을 보여주는 보조 수단이다.

코어는:

```text
상황 관찰
→ 물건/장치/NPC/동물을 직접 조작
→ 여러 시스템이 서로 충돌·연쇄
→ 공간의 상태가 눈에 보이게 변함
→ 예상하지 못한 해결/사건 발생
→ LifeGoal 조건 또는 위기 조건이 사후 판정
→ 바뀐 공간을 다시 갖고 놈
```

플레이어가 가장 많이 하는 것은:
- 걷기
- 이야기 읽기

가 아니라:

- 집기
- 옮기기
- 놓기
- 던지기
- 넣기/빼기
- 먹이기
- 붓기
- 열기/닫기
- 밀기/당기기
- 타기/내리기
- 보여주기/건네기
- 장치 조작

다.

이 모듈의 장르 감각은 **작은 이머시브심 + 장난감 상자 + 상황 퍼즐**에 가깝다.

인생목표는 이 샌드박스를 장기간 관통하는 조건식이지,
플레이어가 NPC에게 받은 퀘스트가 아니다.

---

# 1. 레퍼런스와 변형 경계

## 1.1 레퍼런스 조합 — Untitled Goose Game + Mosa Lina + West of Loathing

가져올 감각:

### Untitled Goose Game 계열
- 물건이 사람과 상호작용하는 언어가 됨
- NPC 반응이 대화 메뉴보다 행동으로 드러남
- 작은 공간을 여러 번 건드리며 상태를 바꿈
- 같은 물건을 여러 상황에 쓸 수 있음

### Mosa Lina 계열
- 도구/물체와 장애물의 관계가 1:1 열쇠-자물쇠가 아님
- 동일 시스템끼리 예상 밖 상호작용이 발생
- 해결 순서를 작가가 전부 고정하지 않음
- "무엇을 해야 하는가"보다 "이걸 여기다 쓰면 어떻게 되지?"가 중요

### West of Loathing 계열
- 이상한 세계 상식이 평범하게 취급됨
- 개그와 세계관이 플레이 중 발견됨
- 진지한 설정과 허술한 일상이 공존

복제하지 않을 것:

- 원작 세계관/문구/캐릭터
- Goose Game의 todo-list 구조
- Mosa Lina의 랜덤 도구 배급
- West of Loathing의 전투/스탯/서부극 구조

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

## 3.1 이동은 콘텐츠가 아니다

빈 길을 오래 걷게 하지 않는다.

공간은 작고 조밀해야 한다.

- 집 한 채 안에서도 15개 이상 물체와 상호작용 가능
- 마을 한 화면/몇 화면 안에서 여러 시스템이 겹침
- 장거리 이동은 지도/짧은 전환으로 압축
- "걸어서 2분"을 콘텐츠 시간으로 계산 금지

## 3.2 1차 물리/상황 동사

첫 구현에서 실제 손맛을 만드는 동사:

```text
grab        집기
drop        내려놓기
place       특정 위치/용기에 놓기
throw       던지기
push/pull   밀기/당기기
open/close  열기/닫기
insert      넣기
remove      꺼내기
pour        붓기
feed        먹이기
use         장치 작동/도구 사용
show        NPC에게 보여주기
give        건네기
mount       타기
dismount    내리기
```

모든 대상이 모든 동사를 받을 필요는 없다.

대상은 capability tag로 허용 동사를 제공한다.

## 3.3 물건이 단어보다 먼저 말하게 하기

가능하면 NPC에게 말을 걸어 설명을 듣기 전에
**환경 반응으로 규칙을 알 수 있어야 한다.**

예:
- 수호신에게 음식을 갖다 대면 입/눈/몸이 반응
- 공룡에게 큰 물건을 가져가면 냄새 맡거나 밀어냄
- 귀이개/칫솔은 UI 이름보다 실제 사용 결과로 정체를 알게 됨
- 감자 현상은 경고문보다 가까이 둔 물체에 반응하는 모습을 먼저 보여줌

## 3.4 대화 예산

대화는 금지하지 않지만 중심 루프에서 강하게 제한한다.

일반 상호작용:
- 0~2줄 bark
- 읽는 동안 플레이 정지 최소화
- 같은 NPC 반복 접근 시 긴 대화창 금지

긴 대화:
- 정말 중요한 캐릭터 장면에만 사용
- 첫 60분 전체에서 30초 이상 연속 대화 장면은 최대 2회
- 2분 이상 읽기 전용 구간은 첫 slice에서 0회

NPC 정보는:
- 행동
- 위치
- 가지고 있는 물건
- 물건에 대한 반응
- 다른 NPC와의 상호작용

으로 최대한 표현한다.

## 3.5 조합이 콘텐츠다

오브젝트 A를 B에 쓰는 것만이 아니라:

```text
A를 C 위치에 둠
→ NPC B가 A를 발견
→ B가 이동
→ 원래 막고 있던 장치 D가 비어 있음
→ D를 조작 가능
→ E 지역의 상태 변화
```

같은 연쇄를 기본 authored unit으로 본다.

대화 선택지 하나는 authored unit 하나로 세지 않는다.

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

# 6.5 핵심 시스템 C-2 — Object Affordance / NPC Reaction

## ObjectDefinition

```text
object_id
tags[]
capabilities[]
portable
container
weight_class
material
state{}
owner_id
```

1차 tag 예:
- edible
- liquid
- noisy
- fragile
- wearable
- container
- rideable
- feedable
- insertable
- pushable

## NPCReactionProfile

NPC는 완전한 AI가 아니라 작은 상태기계로 충분하다.

```text
npc_id
current_activity
attention_target
held_object
home_position
routine_state
reaction_rules[]
```

ReactionRule은:
- 어떤 object/tag가
- 어떤 위치/state에서
- NPC 시야/범위에 들어왔을 때
무엇을 하는지 정의.

가능 action:
- look_at
- walk_to
- pick_up
- move_object
- return_object
- block_path
- leave_area
- change_activity
- bark
- world_effect

이 시스템이 있어야 플레이어가 NPC와 **대화하지 않고도 NPC를 움직이고 상황을 만들 수 있다.**

## 첫 구현 완료 기준

한 공간에서 반드시:

1. 물건을 옮겨 NPC를 다른 위치로 유도
2. NPC가 물건을 되돌려놓으려 함
3. 그 사이 비워진 공간/장치를 이용 가능
4. NPC에게 다른 물건을 보여주면 같은 행동이 깨짐

을 실제로 구현한다.

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

# 15. 첫 45~75분 수직 슬라이스 — 대화가 아니라 상황 조작

첫 slice의 절반 이상은 **텍스트를 읽지 않고도 플레이 가능**해야 한다.

## 15.1 화장실 — 5~10분짜리 작은 장난감 상자

공간:
- 물대야
- 컵
- 물통
- 가느다란 도구 2개
- 수건
- 비누
- 작은 쓰레기통/용기
- 선반
- 문
- 시나

### 플레이 가능한 조작

- 컵에 물 받기
- 컵의 물을 대야/바닥/다른 용기에 붓기
- 도구를 물에 담그기
- 도구를 입/귀에 사용
- 수건을 물에 적시기
- 물건을 선반/대야/바닥/용기에 놓기
- 시나에게 물건 보여주기/건네기

### 시나의 역할

시나는 대화 NPC가 아니라 **상황에 반응하는 행위자**.

예:
- 바닥에 물을 쏟으면 걸레/수건을 찾으려 움직임
- 특정 도구를 들면 쳐다봄
- 이상한 곳에 물건을 두면 원위치시키려 함
- 플레이어가 양치 행동을 하면 원래의 귀이개 장난 장면 발동

즉 플레이어가 시나를 움직이고,
시나가 움직인 결과 비워진 선반/자리/물건 상태를 다시 건드릴 수 있다.

양치 장면은 **퍼즐 정답이 아니라 이 샌드박스에서 발생하는 authored 사건 하나**다.

## 15.2 집 — 10~15분

핵심은 시나에게 계속 말 거는 것이 아니라
**아침 준비 공간 전체를 망가뜨리거나 정리하거나 이상하게 사용할 수 있는 것**.

오브젝트:
- 빵
- 마늘
- 접시
- 컵
- 물
- 장바구니
- 평민 옷
- 왕녀 상자
- 작은 거울
- 문/창문
- 수선 중인 물건
- 다른 종이 쓰는 생활용품

### 실제 chain 예시

#### chain A — 마늘 / 아침 문장
- 마늘을 집음
- 먹음
- 물/다른 음식 사용 가능
- 아침 text leak과 정확히 겹치는 단어가 있다는 걸 플레이어가 스스로 눈치챔
- 정답 알림 없음

#### chain B — 장바구니
- 장바구니 안에 실제 오브젝트를 넣을 수 있음
- 넣은 물건 그대로 들고 마을 이동
- 상점/NPC/수호신 반응이 내용물에 따라 달라짐

#### chain C — 왕녀 상자
- 상자를 열어 일부 물건을 **볼 수는 있지만 첫 slice에서 마음대로 들고 나가는 기능은 제한 가능**
- 시나가 근처에 있으면 반응
- 시나를 다른 일로 움직이면 혼자 볼 수 있음
- 긴 대화 대신 행동/짧은 bark로 긴장감 표현

## 15.3 마을 — 15~25분짜리 하나의 시스템 공간

마을은 NPC 대화 허브가 아니다.

한 화면/짧은 연결 화면에 다음 시스템을 겹친다.

- 식료품 진열대
- 우물 도르래
- 물통/양동이
- 수호신 사당
- 먹이 바구니
- 마구간 문
- 공룡
- 수색 전단
- 외눈 학생
- 주민 몇 명
- 옮길 수 있는 작은 가구/상자/통

### NPC는 루틴을 가짐

[식료품 상인]:
- 진열대 정리
- 떨어진 물건 되돌림
- 특정 물건이 사라지면 찾음

[우물 주민]:
- 물 긷기
- 양동이가 없으면 다른 행동

[사당 주민]:
- 먹이를 확인
- 수호신 상태에 반응

[마구간 관리인]:
- 문/안장/공룡 상태 관리

[외눈 학생]:
- 정해진 자리만 있는 설명 NPC가 아니라
  벤치→가게 앞→사당 근처 등 짧은 이동 루틴

### 플레이어가 할 수 있는 것

- 진열 물건 옮기기
- 장바구니에 담기
- 양동이를 다른 곳에 두기
- 우물에서 물을 받아 다른 곳에 붓기
- 먹을 것을 수호신에게 주기
- 수호신 앞에 이상한 물건 놓기
- 마구간 문 열고 닫기
- 공룡에게 물건 보여주기/먹이기
- 학생에게 이세계 관련 **물건을 보여주는 방식**으로 반응 확인
- 수색 전단 앞에 다른 물건을 놓거나 가리는 정도의 물리 조작
  - 전단 훼손/경찰 시스템까지 확장하지 않음

## 15.4 수호신 — 시스템 장난감

수호신은 단순 "음식 선택 메뉴"가 아니다.

플레이어가 실제 오브젝트를 들고 제단에 가져다 놓거나 먹인다.

반응은 tag 조합.

예:
- edible → 먹을 가능성
- spicy → 별도 반응
- huge → 먹지 못하고 밀어냄
- non_food → 주민/NPC 반응
- 특정 조합 → 예상 밖 반응

먹은 횟수만 세지 않고 **무엇을 먹였는지**에 따라 animation/state가 달라질 수 있음.

정식 콘텐츠의 구체 음식 조합은 추후 작성.

## 15.5 우물 — 작은 물리/상황 퍼즐

도르래 상태만 클릭해서 고치는 구조 금지.

구성:
- 양동이
- 줄/손잡이
- 물
- 주변 통
- NPC 동선

플레이어가 물과 용기를 실제로 옮기면서
마을의 다른 시스템에 쓸 수 있어야 한다.

예:
- 물을 사당 쪽에 가져감
- 공룡 쪽에 가져감
- 집으로 가져감

"우물 퀘스트 완료"가 아니라 **물이라는 상태/자원을 공간에 퍼뜨리는 시스템**.

전역 RPG 자원으로 저장하지 않고 이 모듈 로컬 오브젝트 상태.

## 15.6 외눈 귀환자 — 대화보다 반응

이 캐릭터의 핵심 lore를 대화창으로 10분 읽지 않는다.

플레이어가:
- 교복을 조사
- 마을 물건을 보여줌
- 왕녀 쪽 옛 물건을 보여줄 기회가 생김
- 이세계와 관련 있을 법한 text leak을 본 뒤 다시 접근

할 때 짧은 반응이 달라짐.

긴 설명은 드문 선택 이벤트로만 존재.

첫 slice에서 반드시:
- 물건 보여주기 반응 4종 이상
- 위치/상태에 따른 bark 4종 이상
- 긴 대화는 1회 이하

## 15.7 공룡 — 이동수단이 아니라 거대한 물리 변수

공룡을 타면:
- 몸집 때문에 못 들어가는 곳
- 높은 곳에 닿는 위치
- 밀 수 있는 물건
- NPC가 비켜나는 범위
- 감자 현상의 반응

이 달라짐.

공룡을 내려놓는 위치도 세계 상태.

공룡이 어디 있느냐 때문에:
- 마구간 문이 막힘
- 주민 동선이 달라짐
- 특정 상자를 밀 수 있음
- 우회로가 막히거나 열림

같은 일이 가능해야 함.

## 15.8 감자 장애물 — 작은 이머시브심 문제

"감자에게 말 걸기" 없음.

"감자를 공격하기"를 기본 해법으로 두지 않음.

장애물 공간에:
- 감자 현상
- movable objects
- 높낮이/좁은 틈
- 공룡
- 물 또는 다른 환경 요소

를 함께 둔다.

목표:
**정답 버튼 없이 상태 조합으로 통과.**

최소 두 해법은 작가가 확인하지만,
세 번째 이상의 emergent 해법이 나와도 막지 않는다.

## 15.9 개발용 LifeGoal 검수도 물리 chain으로

개발용 목표는 대화 선택으로 달성하지 않는다.

예시 fixture:

> [DEV] 특정 물건이 주인 손을 떠난 뒤, 플레이어가 직접 들지 않고 원래 자리에 돌아오게 하기

가능 chain:
- 물건 이동
- NPC가 발견
- NPC가 다른 NPC 때문에 이동
- 결국 다른 행위자가 원위치

플레이어는 마지막에 아무 버튼도 누르지 않았는데 goal completion이 뜸.

이것이 핵심 감각.

## 15.10 첫 slice 완료 게이트

- 전체 플레이 시간의 50% 이상이 텍스트 읽기 외 행동
- 2분 이상 연속 읽기 전용 구간 0개
- NPC에게 말을 한 번도 걸지 않고도 최소 15분 플레이 가능
- 집기/놓기/던지기/붓기/먹이기/타기 중 최소 5개 동사가 실제 콘텐츠에서 사용됨
- NPC reaction chain 3개 이상
- 물건이 NPC를 움직이게 하는 상황 2개 이상
- 동일 물건을 서로 다른 시스템 2곳 이상에 사용
- 수호신이 menu가 아니라 world object로 반응
- 공룡 위치가 실제 공간 상태를 바꿈
- 감자 장애물 해법 2개 이상
- 개발용 goal이 action chain 결과로 자동 달성
- save/load 후 오브젝트 위치/중요 상태가 일관됨

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


# 29. 첫 수직 슬라이스 이후 실제 콘텐츠 묶음

이 절은 **걷고 대화하는 콘텐츠가 아니라 새로운 조작 시스템·오브젝트 조합·상황 chain을 추가해 분량을 늘리는 authored content 후보**다.

각 묶음은 대화량이 아니라:
- 새 object affordance
- 새 NPC reaction
- 새 environmental rule
- 기존 시스템의 새로운 조합

중 최소 2개를 추가해야 한다.

표기:
- **[USER]** 사용자가 직접 준 설정
- **[PROPOSED]** 해당 설정을 게임으로 만들기 위한 구체적 구성. 정식 채택 전 교체 가능

---

## 29.1 마을 생활 / 혈밍아웃 묶음 — 약 30~60분 추가

### [USER]
- 마을 사람들에게 건실한 인상을 오랫동안 줌
- 신뢰를 쌓은 뒤 혈통 공개
- 다행히 잘 받아들여짐

### 게임화 핵심

"평판 수치 올리기"도, 주민들을 돌아다니며 대화 이벤트를 보는 구조도 아니다.

평판의 증거는 **마을 물체/공간/NPC 루틴에 이미 박혀 있어야 한다.**

예:
- 주인공이 자유롭게 열 수 있는 창고
- 상인이 감시하지 않아도 만질 수 있는 물건
- 공룡이 주인공을 경계하지 않음
- 주민이 자기 물건을 잠깐 맡기고 다른 일을 하러 감

혈밍아웃 전까지 플레이어는 이런 **행동권 자체**로 신뢰를 느낀다.

### [PROPOSED] 반복 방문형 생활 사건 5개

정식 사건명/인물명은 미정.

1. **빌린 물건 돌려주기**
   - 집에 오래 있던 마을 물건 하나를 발견
   - 누구 것인지 사람들 대화로 추론 가능
   - 돌려주면 끝
   - 보상 아이템 없음
   - 나중에 그 사람이 주인공을 두둔하는 근거로 사용 가능

2. **우물 약속**
   - 앞 절의 우물 상태를 건드림
   - 완전 수리가 아니라 "오늘은 내가 봐두겠다"는 정도의 생활 약속
   - 다음날/재방문 시 실제로 반영

3. **가게 외상/정산**
   - 이미 단골이라 상인이 자연스럽게 거래
   - 플레이어가 돈을 벌어 갚는 경제 게임으로 확장 금지
   - 장부 한 줄과 관계 반응만 남음

4. **마구간의 반복 도움**
   - 공룡을 타기 전후로 관리인과 짧게 상호작용
   - 한번 도움 줬다고 절친이 되지 않음
   - 여러 번 마주치며 familiar→reliable 느낌 축적

5. **수호신 먹이 행사 돕기**
   - 종교의 진지한 교리 설명 없음
   - 주민들은 그냥 신이 통통해지는 걸 보고 만족
   - 주인공도 행사 준비를 조금 돕고 같이 구경
   - 기괴하지만 평화로운 공동체 경험

### 혈밍아웃 장면 구조 — 짧게

혈밍아웃 자체는 긴 선택지 대화가 아니라 짧은 사건.

핵심 콘텐츠는 그 **이후 시스템 상태 변화**다.

예:
- 이전에는 자유롭게 만지던 물건 앞에서 잠깐 멈칫하는 NPC
- 반대로 왕녀를 과하게 모시려 물건을 먼저 가져다주는 NPC
- 평소 루틴을 고집하며 아무것도 안 바꾸는 NPC
- 호칭만 바뀌었는데 행동권은 그대로인 공간

즉 한 컷신보다 "그 뒤 마을 전체를 다시 갖고 놀 때 달라진 반응"이 본체.

### 혈밍아웃 장면 구조

정확한 계기와 장소는 미정.

장면이 시작되면 플레이어가:
- "사실 나는 왕녀였다"
- "정확히는 세 번째 왕녀였다"
같은 정보를 공개.

중요:
**선택지로 거짓말/진실 루트를 갈라 게임 전체를 분기시키는 구조는 기본안 아님.**
사용자 설정대로 결국 혈통을 밝히는 사건.

마을 사람 반응은 이전 생활 사실을 실제로 참조.

예:
- 빌린 물건 돌려준 사람
- 우물에서 자주 마주친 사람
- 마구간 관리인
- 수호신 행사 주민

각자가:
> 왕녀라서 받아준다
가 아니라
> 우리가 몇 년 동안 알고 지낸 사람이 먼저 있고, 그 사람이 왕녀였다는 사실이 뒤늦게 붙는다

는 방향.

### 혈밍아웃 이후 세계 변화

반드시 최소:
- NPC 대사 5명 이상 변경
- 일부는 존댓말/호칭을 바꾸려다가 어색해함
- 일부는 평소대로 부름
- 집에 돌아가면 시나 반응 추가
- 수색 전단을 다시 보면 새 독백
- 왕녀 상자를 다시 조사하면 이전과 다른 문장

**마을이 받아줬다는 사실이 컷신 한 장으로 끝나지 않고 이후 상호작용 전체에 남아야 함.**

---

## 29.2 뚱뚱한 수호신 종교 — 20~40분 선택 콘텐츠

### [USER]

종교의 핵심:

> 많이 먹여서 수호신이 뚱뚱해지는 모습을 보고 "아 좋다" 할 뿐

이 설정에 불필요한 비밀교단/악신/반전을 붙이지 않는다.

### 실제 플레이

사당은 마을의 고정 장소.

플레이어가 여러 지역에서 **먹을 수 있어 보이는 것**을 발견하면
사당에서 바칠 수 있는지 시험 가능.

모든 물건이 accepted일 필요 없음.

#### 반응 종류

1. 좋아함
2. 별 반응 없음
3. 신상이 뱉음
4. 주민이 "그건 먹이는 게 아니다"라고 말림
5. 이유 없이 매우 좋아함

### 외형 변화

한 번에 거대해지지 않음.

작은 누적 변화:
- 볼
- 배
- 팔
- 앉는 자세
- 제단 공간

등으로 시각적으로 보이게.

### 핵심 금지

- 먹이 포인트
- 신앙 레벨
- 버프
- 엔딩 요구치
- 최적 음식 공략

그냥 **세계 안에서 오래 건드릴 수 있는 장난감**이어야 함.

### 장기 variation

혈밍아웃 전/후에도 주민 반응이 달라질 수 있음.

예:
- 공개 전: "또 가져오셨네요"
- 공개 후: "왕녀님도 이건 계속 하시는군요"

정확한 대사는 writing 단계에서 결정.

---

## 29.3 외눈 교복 귀환자 — 25~45분 선택 대화/탐색 묶음

### [USER]

- 눈알 하나뿐인 교복 차림 고등학생
- 자신을 귀환자라고 소개
- 이세계 학교를 다녀왔다고 함
- 주인공은 이 지구에서만 환생해 왔음
- 그의 이야기 때문에 다른 세상이 있을지도 모른다는 느낌

### 게임화

이 캐릭터를 "설정 설명 NPC"로 두지 않는다.

처음엔 평범하게 마을에 있음.

#### 첫 만남
- 자신을 귀환자라고 말함
- 학교에서 돌아왔다고 함
- 설명을 길게 하지 않음

#### 두 번째 만남
다른 위치에 있음.
- 그쪽 학교의 사소한 생활 규칙 하나
- 여기와 비교

#### 세 번째 만남
플레이어가 마을에서 특정 학교 관련 물건/표지/책을 조사한 뒤라면 새로운 대화.

#### 네 번째 이후
항상 새로운 lore를 주지 않는다.
- 밥
- 숙제
- 교복
- 집
같은 평범한 얘기도 함.

**다른 세계의 존재를 증명하는 열쇠 NPC로 만들지 않는다.**

### 주인공과의 대비

주인공은:
- 환생은 익숙함
- 다른 세계 이동 경험은 없음

학생은:
- 환생 얘기 없음
- 다른 세계 학교 경험을 주장

둘이 서로:
> 네 쪽이 더 이상하다
는 느낌을 가질 수 있음.

이 대조는 설정 설명보다 캐릭터 대화에서 보여준다.

---

## 29.4 공룡 이동 구간 — 30~60분

### [USER]
- 공룡을 타고 다님
- 공룡에도 석기를 쓰는 선사시대가 있었음
- 중세 공룡 문화권 판타지 아이디어

첫 모듈에서는 후자의 역사/문화 설정을 전부 합치지 않는다.
현재 세계의 공룡 탈것만 먼저 실제 게임에 사용.

### 실제 콘텐츠

외곽 이후 route가 열리면:
- 평지
- 좁은 길
- 낮은 장애물
- 마을과 작은 중간 거점

정도를 공룡으로 이동.

### 공룡 탑승 중 상호작용

정지 상태에서:
- 내려보기
- 공룡 반응 보기
- 길가 대상 조사
- 사람과 대화

가능.

자동 러너/미니게임 금지.

### 공룡 때문에 바뀌는 것

- 일부 NPC가 멀리서 먼저 반응
- 좁은 장소 진입 불가
- 특정 높이의 대상 조사 가능
- 길 위 장애물에 다른 해결법
- 공룡을 두고 걸어가면 또 다른 길

공룡은 "이동속도 +50%" 장비가 아니라
**플레이어의 공간 affordance를 바꾸는 몸집 큰 동료 도구**로 취급.

---

## 29.5 감자 적대 구간 — 20~40분

### [USER]
- 감자가 주적

왜 감자가 주적인지는 미정.

따라서 첫 구현에서:
- 감자가 사람을 먹음
- 감자가 군대를 조직함
- 감자가 마법을 씀

같은 설정을 임의 확정하지 않는다.

### 실제 구현 최소형

플레이어가 멀리서 봤을 때:
- 분명 감자처럼 보임
- 그런데 이동/반응함
- 길을 점유
- 가까이 가면 안전하지 않다는 사실만 알 수 있음

### 플레이

감자를 "죽이는 전투"보다:
- 접근 경로 바꾸기
- 환경 이용
- 공룡 상태 이용
- 다른 장소에서 얻은 정보 활용

으로 처리.

### 반복 변형

두 번째 감자 상황에서는 첫 해결법이 그대로 통하지 않게 해야 함.

예:
- 첫 구간은 공간 문제
- 두 번째는 NPC 이동을 막고 있음
- 세 번째는 물건을 지키고 있음

정확한 감자 생태는 사용자 설정 후 확정.

---

## 29.6 마사지 목표 — 첫 장거리 방향 제시

### [USER]

> 지금 국가에서 정반대편 국가 마사지사에게 마사지받기

주인공이 여러 목표 중 이것을 가장 힘들어 보이는 목표로 보고
모험의 장기 방향으로 잡음.

### 첫 모듈에서 해야 할 것

마사지사를 바로 만나지 않는다.

대신 플레이어가 실제로:

1. 현재 국가 지도를 봄
2. "정반대편"이 어디인지 대략 확인
3. 현지에서는 그 마사지사에 대한 정보가 거의 없다는 걸 확인
4. 이동하려면 여러 region을 지나야 함을 알게 됨
5. 첫 route 하나를 직접 열어봄

### 금지

- 지도에 목적지 큰 노란 화살표
- 1,200km 남음 같은 수치 추적
- "메인 퀘스트: 마사지사 찾기"
- 즉시 fast travel

### 장기 진행 감각

마사지 목표는 계속 화면에 있지만,
플레이어는 대부분의 시간:
- 마을
- 이상한 사람
- 공룡
- 감자
- 다른 인생목표
- 위기
- 우연한 사건

을 상대함.

그러다 수 시간 후:
> 아 맞다, 나 마사지 받으러 가던 중이었지

가 자연스러운 구조.

---

## 29.7 인생목표들이 예기치 않게 깨지는 방식 — 콘텐츠 작성 규칙

실제 목표 문구는 사용자 미정.

하지만 목표를 추가할 때 작성자는 각 목표마다 **정면 루트와 비정면 루트**를 설계한다.

예시 구조:

```text
목표 A
정면 루트:
  플레이어가 목표를 의식하고 직접 조건을 맞춤

비정면 루트:
  전혀 다른 사건 B → world reaction C → NPC 이동 D
  → 결과적으로 목표 A 조건 충족
```

전체 목표 중 최소 절반은 비정면 달성이 가능해야 함.

목표마다:
- "무엇을 해야 하나?"
보다
- "어떤 세계 상태라면 이미 달성된 것으로 볼 수 있나?"

를 먼저 작성한다.

---

## 29.8 전생 기억이 실제 콘텐츠에 개입하는 빈도

기억 해금은 흔한 보상으로 쓰지 않는다.

권장 밀도:
- 45~90분 플레이당 0~1회
- 큰 위기 구간에만 몰릴 수 있음

기억이 열릴 때마다:
- 과거 생 하나를 장황하게 설명하지 않음
- 필요한 장면/기술/감각 조각 정도만
- 나중에 추가 조각이 같은 과거 생을 재해석할 수 있음

플레이어가 "기억 게이지를 채우고 있다"는 감각을 가지면 실패.

---

## 29.9 2~4시간 분량 기준

이 게임형 모듈을 1차로 "콘텐츠가 있다"고 볼 최소 authored pool:

- 집: 20+ 상호작용/variant
- 마을 중심: 30+ 상호작용/variant
- 사당: 먹이 반응 12+
- 귀환자 학생: 위치/상태별 대화 8+
- 마구간/공룡: 15+ 상호작용/variant
- 외곽: obstacle 3종 이상
- 감자 상황: 최소 2종
- cross-location reaction: 8+
- 시나 대화 variant: 12+
- 혈밍아웃 전/후 NPC 변화: 10+
- text leak: 사용자 작성분 + 추가 확정분만
- 정식 life goal: 사용자 확정분만
- 개발 fixture goal/crisis는 release 전 제거

이 수치는 "버튼 개수"가 아니라
**서로 다른 상태/맥락에서 실제로 다른 반응이 존재하는 authored unit** 수다.

