# BLACK SOULS 2 통합 조사 — Top-down Action-RPG Kit

상태: 텍스트 레퍼런스·외부 코드 감사·사용자 실제 플레이 캡처 A~H 통합 완료. 사용자 세계관 메모 대기.  
조사일: 2026-09-25  
계획 게이트: 이 문서만으로 Kit 계획을 확정하거나 구현을 시작하지 않는다.

## 1. 조사 목적

이 조사는 다음 Kit 계획의 입력이 된다.

- Kit 이름: 작업명 `Top-down Action-RPG`
- Primary Reference: **BLACK SOULS 2 하나**
- 기준 강도: 시스템·UX·콘텐츠 구조·스토리/캐릭터/적 설계의 범용 규칙과 분량을 최대한 강하게 따른다.
- TIN 적용: 원작의 고유 자산·문구·캐릭터·지도 배치·세계관을 복제하지 않는다.
- 확정 금지: 앨리스 원작 세계관을 대체 세계관으로 사용하지 않는다.
- 다음 필수 입력: 사용자의 세계관 메모와, 계획 범위를 확정할 때 필요한 추가 상태별 플레이 캡처

“분량을 따른다”는 작은 로컬 전투 데모를 뜻하지 않는다. 한 보스나 한 맵으로 닫는 계획은 이 Kit의 Reference Game 분량으로 인정하지 않는다. 여러 지역·NPC 관계·적군·보스 패턴·전역 상태·선택지를 같은 core 위에서 증명하는 수직 슬라이스가 필요하다. 정확한 authored content 수량은 실제 플레이 증거와 사용자 메모를 받은 뒤 계획서에서 고정한다.

## 2. 출처와 증거 등급

사용자가 제공한 출처:

- https://namu.wiki/w/BLACK%20SOULS%202
- https://namu.wiki/w/BLACK%20SOULS%202/%EB%B3%B4%EC%8A%A4
- https://namu.wiki/w/BLACK%20SOULS%202/%EA%B4%91%EB%A0%B9%E3%83%BB%EC%95%85%EB%AA%BD%EB%A0%B9%E3%83%BBNPC
- https://namu.wiki/w/BLACK%20SOULS%202/%ED%98%BC%EB%8F%88%20%EB%8D%98%EC%A0%84
- https://namu.wiki/w/BLACK%20SOULS%202/%EB%AA%AC%EC%8A%A4%ED%84%B0
- https://namu.wiki/w/BLACK%20SOULS%202/%EC%8A%A4%ED%82%AC
- https://namu.wiki/w/BLACK%20SOULS%202/%EC%83%81%ED%83%9C%EC%9D%B4%EC%83%81
- https://namu.wiki/w/BLACK%20SOULS%202/%EC%A4%91%EC%9A%94%ED%92%88%E3%83%BB%EC%86%8C%EC%9A%B8%E3%83%BB%EB%8F%99%ED%99%94

사용자 실제 플레이 캡처:

- [A~H 상태별 evidence map](USER_PLAY_REFERENCE_2026-09-25.md)

근거 표기:

- **화면 직접 관찰**: A~H 캡처에서 보이는 배치, 색, 문구 상태, progress affordance를 확인한 것.
- **사용자 설명**: 대화 또는 caption으로 제공한 사건 의미와 화면 semantics. 화면에서 직접 읽히지 않는 부분도 이 등급에 둔다.
- **텍스트 문서 확인**: 사용자가 제공한 문서가 mechanic, 목록, 분기 또는 콘텐츠 구조를 명시하는 것.
- **반복 패턴**: 여러 문서/사례에서 같은 구조가 반복되는 것.
- **TIN 추상화**: 확인된 규칙을 TIN의 독립 authored content와 시스템 구조로 바꾼 것.
- **미확인**: A~H, 사용자 설명, 텍스트 문서만으로 결정하지 않은 것.

나무위키는 자체적으로 검증되지 않은 community source임을 경고한다. 수치·공략·정체성 추정은 원작 사실로 승격하지 않는다.

## 3. 레퍼런스 정체

제공된 메인 문서에서 확인되는 작품 정보:

- 제작자: 寿司勇者トロ
- 엔진: RPG Maker VX Ace
- 출시: 2018-11-10
- 장르: 쯔꾸르 중심의 JRPG
- 주요 축: 2D 필드 탐색, 위치 없는 대상 선택 전투, 턴·행동권, 상태이상, 장비/소울 진행, 광범위한 선택지

TIN에서 따라갈 것은 위 동작 구조와 콘텐츠 밀도다. RPG Maker의 UI, 에셋, 표현, 원작 캐릭터와 세계관은 복제하지 않는다.

## 4. 가장 중요한 시스템 문법

### 4.1 필드와 전투는 서로 다른 문법이다

**직접 확인·반복 패턴**

- 필드에서는 이동, 문·다리·엘리베이터 등 authored passage, 상자·시체·레버, NPC, 상점, 추격과 은닉, 위험 gimmicks를 사용한다.
- 전투에는 별도의 명령→대상 선택 흐름이 있다.
- 전투 스킬은 자기/적 하나/전체/아군/무작위 대상을 사용한다.
- 별도 근거가 없으면 전투 이동, 인접, 열·방위·후방약점 등을 더하지 않는다.

**TIN 추상화**

```text
FIELD
movement → encounter trigger → target/transition → combat

COMBAT
command intent → target intent → scheduled resolution → feedback
```

필드 탐험과 전투는 같은 카메라·연속 이동으로 잇지 않는다. 전투 진입·복귀는 authored encounter transition으로 만든다.

### 4.2 행동 순서는 단순 alternation이 아니다

**직접 확인**

- 민첩이 행동 빈도/순서에 영향을 준다.
- 플레이어와 적은 action pool에 명령을 넣고 순서대로 resolution한다.
- 행동권 추가 효과로 한 번에 여러 명령을 할 수 있다.
- 특정 기술·소비품은 턴을 소비하지 않는다.
- MP와 쿨다운은 별도 자원이다.
- 보스 charge는 준비 턴과 실제 공격 턴을 분리한다.

**미확인**

- 민첩→게이지 수식
- tie-break 순서
- 정확한 no-turn 우선순위

**TIN 추상화**

다음 세 가지 개념을 혼동하지 않는다.

1. `schedule_rate`: 누가 얼마나 자주 선택받는지
2. `action_slots`: 선택 한 번에 몇 명령을 낼 수 있는지
3. `turn_cost`: 명령이 다음 scheduler 진행을 소비하는지

전투 시스템은 BS2와 같은 pacing을 목표로 하되 수치는 실제 플레이 증거 후 고정한다.

### 4.3 Guard / Dodge / Break

**직접 확인**

- Guard는 단순 방어 스탯이 아니라 2턴 상태이다.
- Guard는 방어효과율에 비례해 피해를 줄이고 일반 회피·반격을 잃는다.
- Break 취약 상태가 되며, 이는 보스 charge를 취소하는 핵심 수단이 된다.
- Dodge는 민첩과 장비로 완성되는 확률 회피 상태다.
- Dodge는 일반 공격과 여러 상태이상을 피하지만 필중을 전부 막지는 않는다.
- Break 성공은 charge 버프 제거, 행동 불가, 방어 붕괴, damage window를 만든다.
- Break resistance/immunity는 정상적인 적 성질이다.

**TIN 추상화**

```text
Defend = mitigation + stance vulnerability
Dodge  = chance avoidance + status denial
Break  = counter/telegraph cancellation + punish window
```

세 수단은 정답·오답이 아니라 서로 다른 enemy counter axis다. 모든 적을 Break로 푸는 구조는 금지한다.

### 4.4 보스 charge

**직접 확인된 기본 패턴**

```text
charge state
→ visible tell
→ player's counter decision
→ cancel or commit
→ attack/recovery
```

- charge 중에 흔들림·상태 변화·VFX가 발생한다.
- Break에 취약해진다.
- 실제 공격은 보통 필중 또는 즉사에 가깝다.
- charge를 깨면 즉시 반격/처치 opportunity가 생긴다.

**예외도 많다**

- Break 불가능 charge
- 필중이라 Dodge 불가
- 즉사·death immunity로 받는 경우
- MP 고갈, 자원 차단, 특정 속성, 전용 아이템으로 받는 경우
- 보스가 방어 회피·반격을 무효화해 기존 전략을 지우는 경우

따라서 `charge`와 `break`는 hard-coded pair가 아니다. 각 attack/action이 허용하는 counter와 forbidden response를 명시한다.

### 4.5 Damage와 status

**직접 확인된 축**

- physical / magical delivery
- fire / ice / lightning / light / darkness affinity
- hit / evasion / critical / critical avoidance
- physical / magical resistance
- percentage, fixed, guaranteed-hit
- guard-ignore, self-damage
- regeneration, status resistance, extra actions
- control, DoT, stat, buff, dispel, cure, reflect, counter

**TIN 추상화**

Status는 이름·색이 아니라 resolution hook을 가진 데이터다.

```text
status definition
+ duration/tick
+ stat/trait modifiers
+ control/disable behavior
+ cure category
+ resistance/immunity query
+ presentation icon
```

status 추가가 combat core 수정 없이 가능한지는 authored-content 확장성 검증의 일부다.

### 4.6 Equipment와 consumables

**직접 확인**

- 무기는 기본 공격을 바꿀 수 있다.
- 장비 강화는 active skill을 열 수 있다.
- 장비와 소울은 기본 stat뿐 아니라 행동경제를 바꾼다.
- 많은 소비품과 buff item은 턴을 소비하지 않는다.
- 행동 추가 장치가 있다.
- 방어·회피·즉사·상태·저항 build가 있다.
- item/equipment/service는 hub에서 성장한다.

**TIN 적용**

최소 Reference Game도 다음을 다른 authored content와 함께 증명해야 한다.

- 기본 공격을 바꾸는 무기 1종 이상
- 강화/해금 active skill 1종 이상
- resistance/behavior을 바꾸는 equipment 1종 이상
- no-turn heal/cure/buff 1종 이상
- action-slot을 바꾸는 source 1종 이상
- field traversal을 바꾸는 key/pass 1종 이상

## 5. World와 story의 범용 규칙

### 5.1 Hub + backtracking

**반복 패턴**

- 중앙 dream/library hub가 복구·저장·서비스·후기 진입을 맡는다.
- 여러 route가 hub 또는 region branch에 연결된다.
- 빠른 direct route와 긴 우회 route가 병존한다.
- 이전 지역으로 돌아올 수 있다.
- 보스, key, NPC state, global state, optional route이 서로 다른 gate로 작동한다.
- ending/신규 DLC가 후기 content의 접근 권한 자체가 된다.

**TIN 추상화**

- Reference Game에는 최소 hub와 두 갈래 이상의 authored region route가 있어야 한다.
- 긴 이동으로 분량을 채우지 않는다.
- backtrack은 collectible 보상이 아니라 상태 변화 확인, NPC 관계, shortcut, unresolved consequence를 확인하는 이유가 있어야 한다.
- route gate는 key 하나로 통일하지 않는다.

### 5.2 Story는 quest flag 나열이 아니다

**반복 패턴**

- NPC quest는 item, letter, ring, visit, combat result, survival, repeated action을 서로 결합한다.
- NPC는 dialogue 외에 shop/access/upgrade/reward/combat/companion/global event를 소유한다.
- NPC의 생존·사망·배신이 지역, 상점, dialogue, final party, world event를 바꾼다.
- refusal도 consequence를 만든다.
- global progress가 일정 임계값 뒤 NPC를 일괄 소실시키거나 endgame threat를 발생시킨다.
- optional content는 region-local, cross-region, route-defining, truth-revealing, postgame로 층위가 다르다.
- collection은 combat support와 world knowledge로 연결되지만 모든 ending의 강제 조건은 아니다.

**TIN 추상화**

NPC 1명은 최소 하나의 system port를 소유한다.

```text
NPC
= need/fear
+ observable behavior
+ system role
+ request/refusal
+ survival state
+ world consequence
+ later role inversion/reveal
```

dialogue-only NPC를 quest source로 삼지 않는다.

### 5.3 전역 state는 여러 표면에 동시에 작용한다

**직접 확인된 world pattern**

- 하나의 recognition/perception state가 BGM, NPC dialogue, enemy/object form, region access와 story variant를 함께 바꾼다.
- 별도의 progress state가 hub service, NPC availability와 mass event를 바꾼다.
- difficulty는 combat/reward scaling axis다.
- run-local dungeon depth는 별도 scaling axis다.

**TIN 추상화**

전역 축을 한 덩어리로 뭉개지 않는다.

- cognition/perception axis: 무엇이 정상/게임 규칙으로 보이는가
- world-change axis: 세계와 NPC가 얼마나 변했는가
- difficulty axis: combat 수치와 보상
- run/depth axis: 한 반복 run 내부의 위험

각 축은 최소 하나의 authored threshold를 가져야 한다. 단순히 수치만 저장하고 UI 색만 바꾸는 것은 stateful fiction이 아니다.

### 5.4 Layered revelation과 좋은 결말의 불완전성

**반복 패턴**

- 표층 해석과 later truth가 다르다.
- quest를 많이 해결해도 system-level liberation과 별개다.
- 겉보기 탈출 뒤 substrate가 남거나 다시 반복될 수 있다.
- 진짜 해제는 후기 optional content와 동료/기억/세계 이해를 합쳐 연다.
- 완전히 권력을 받아도 새로운 지배 체계가 될 수 있다.

**TIN 추상화**

- hidden route prerequisite는 secret flag 하나로 만들지 않는다.
- optional region, collectible, relationship, world-state threshold, replay-only memory를 결합한다.
- breadcrumb 수와 표시는 plan에서 명시한다.
- ending은 “탐색 대상 구출”, “구조 해방”, “현실 귀환”을 별도 축으로 기록한다.
- 후기는 단순히 HP가 높은 boss가 아니라 이전 결말이 왜 incomplete였는지 다시 설명해야 한다.

### 5.5 Horror와 humor

**반복 패턴**

- 밝은 BGM과 불쾌한 결과를 병치한다.
- corridor, clock, room, organ, mouth, teeth, eye, doll, corpse 등을 공포 stimulus로 쓴다.
- 치료가 monster를 만드는 medical horror, 산업적 시체 처리 방식에서 ethico-social horror를 만든다.
- 심한 장면 안에 작고 명확한 resident NPC/service를 두어 navigation과 tonal anchor를 준다.
- character-system mismatch, 자기 과장, 반복 signature, history/current gap으로 humor를 만든다.

**TIN 적용**

- 앨리스 고유 imagery와 원작 horror set piece는 사용하지 않는다.
- jump scare는 climax이고 horror grammar 전체가 아니다.
- 공백·소리·온도처럼 조작 가능한 단서를 먼저 만들고 irreversible state change로 끝낸다.
- character signature의 반복 횟수는 실제 플레이 증거로 확인한 뒤 고정한다. 반복마다 새 정보·오해·반전을 추가해 성격이 변화하게 한다.

## 6. Character 설계 규칙

### 6.1 성격은 설명이 아니라 player action으로 번역된다

**반복 패턴**

- fear, greed, faith, attachment, trauma, loneliness, incompetence가 quest condition, combat form, service behavior, transformation에 나타난다.
- 중요한 NPC는 단순 job vendor가 아니라 자신의 기호/공포가 서비스 방식에 드러나는 resident다.

**TIN content template**

```text
CharacterDefinition
- core_need
- core_fear_or_defect
- public_role
- hidden_or_late_role
- request_chain
- refusal_policy
- system_ports[]
- survival_states[]
- combat_or_ally_conversion[]
- world_effects[]
- dialogue_state_rules[]
```

### 6.2 NPC-boss 전환

**직접 확인**

- NPC는 조건에 따라 hostile combat variant가 된다.
- 전투 후 death, repeated challenge, ally/spirit, persistent NPC, removal 중 하나가 될 수 있다.
- 전투 결과는 dialogue만 바꾸지 않는다.
- NPC combat은 별도 새 entity를 만드는 것이 아니라 같은 stable identity의 resolved state로 모델링한다.

**TIN 추상화**

```text
neutral_npc
→ condition/choice
→ encounter_or_noncombat_resolution
→ resolution_state
```

전투 스킨만 갈아입히는 설계는 금지한다.

### 6.3 Companion은 관계 history를 압축한다

**반복 패턴**

- 치료·구원·배신·조건 달성에 따라 final combat support가 된다.
- 동료의 power는 단순 affinity 값보다 rescue/betrayal/route history를 요약한다.
- 여러 동료 중 선택이 final phase/ending을 바꾼다.

**TIN 적용**

동료 candidate를 선형 호감도만으로 만들지 않는다. 어떤 행위가 power를 열었는지 authored state와 직접 연결한다.

## 7. Enemy와 encounter 설계 규칙

### 7.1 적은 하나의 signature rule + escalation로 읽힌다

**반복 패턴**

- 기본 공격
- standout rule
- phase/summon/status/resource/arena escalation

이것이 모든 적을 3가지 행동으로 제한하라는 뜻이 아니다. 초안의 최소 분해이며, complex boss는 signature rule을 phase·arena·summon 중 하나와 결합한다.

**TIN 추상화**

```text
Enemy
= body/role identity
+ baseline actions
+ signature action
+ counter profile
+ status/resistance profile
+ escalation
+ visual tell
```

### 7.2 모든 공격에 counter policy가 있다

**TIN content field**

```text
precondition
telegraph_duration
telegraph_channels
commitment
active_hit
recovery
punish_window
valid_counters
forbidden_responses
break_policy
reaction_on_hit
reaction_on_miss
reaction_on_break
```

Break 가능한 attack만 만들지 않는다. unbreakable, avoid-only, resource-lock, scripted counter, escape, quiz, raw survival도 허용한다.

### 7.3 Phase trigger

직접 확인된 trigger:

- HP ratio
- cumulative HP loss
- turn count
- external story flag
- actor/companion state
- linked actor death
- encounter phase completion

**TIN authoring rule**

새 phase를 만들기 위해 combat algorithm을 수정하지 않는다. phase data가 action set, resistance, roster, invulnerability, arena, completion rule을 override한다.

### 7.4 Summon과 linked actor

직접 확인된 lifecycle:

- encounter start summon
- HP threshold summon
- periodic HP-step summon
- adds protect owner
- owner death kills adds
- adds remain after owner death
- adds flee at threshold
- simultaneous/linked death
- clone/true actor
- revive with changed form

**TIN content rule**

모든 summon/linked actor에 owner, count, max_count, timing, role, death, escape, lifetime, true target을 명시한다.

### 7.5 Group와 variant

혼돈 던전 문서에서 확인된 재사용 방식:

- 동일 actor set의 count/subset 조합
- 같은 loadout의 장비 조합
- 동일 boss의 depth/stat/action override
- 고정 wave sequence에 depth band 적용
- 기존 encounter에 story/roster/action을 mix한 remix

**TIN 추상화**

```text
base_enemy_id
+ base_encounter_id
+ stat/action/roster/reward/phase/arena override
+ eligibility condition
```

새 enemy implementation을 복제하지 않는다.

### 7.6 Enemy visual rule

텍스트로는 다음 축이 확인된다.

- anchor body/prop
- size/quantity contrast
- stateful body: open/close, split/merge, transform
- role prop
- motion signature

A~H에는 enemy silhouette/density 비교 자료가 없으므로 실제 값은 확정하지 않는다. 이 문서의 at-icons 적 이미지 recipe는 과거 기준으로, `archive/icon_based_image_assets/`에 보존된 현행 제작 지침이 아닌 역사적 기록이다.

## 8. Authored Content schema 방향

### 8.1 EnemyArchetype

필수 개념:

- stable ID/version
- entity/encounter mode
- role tags
- body/tell/art class
- base stats and stats growth
- action set
- status/resistance/break profile
- phase set
- summon/linked actor refs
- reward profile
- lore reference

### 8.2 ActionDefinition

필수 개념:

- intent/targeting
- resource/turn/cooldown cost
- precondition
- telegraph
- commitment
- hit/status payload
- recovery/punish
- valid/invalid counter
- break/phase/summon/arena hooks

### 8.3 PhaseDefinition

필수 개념:

- trigger
- enter override
- action/roster/resistance override
- completion/death rule
- next phase

### 8.4 EncounterDefinition

필수 개념:

- region/story/depth context
- activation/visibility
- one-shot/repeat policy
- roster/group/order/target priority
- allowed escape/skip
- failure policy
- world effects
- reward policy

### 8.5 StoryConversion

필수 개념:

- NPC stable ID
- pre-combat state
- combat condition/profile
- post-victory/failure state
- relationship state
- repeat policy
- world effects

## 9. Reference Game 분량 방향

아래는 수가 아니라 mandatory authored content family다.

1. Hub와 recovery/service/checkpoint
2. 최소 두 authored field regions
3. 직접 route와 우회/backtrack route
4. key/equipment gate와 combat gate가 각각 존재하는 진행
5. baseline field encounter
6. charge-break tutorial boss
7. break이 정답이 아닌 boss
8. HP/turn threshold phase boss
9. summon 또는 linked-actor boss
10. NPC quest chain 2개 이상
11. NPC-boss 또는 noncombat boss resolution 1개 이상
12. companion/relationship outcome 1개 이상
13. cognition/world-state threshold variation
14. service/upgrade authored content
15. 후기 remix/variant encounter로 기존 core 재사용 증거

작성 계획은 이 family 각각에 concrete authored content를 배정해야 한다. 긴 이동, 대기, 대사량, 같은 보스 반복으로 10분을 채우지 않는다.

## 10. 현재 TIN 코드와 결합 경계

호스트 통합 계약과 whitelist 구현의 재검증 대상:

- AppRoot가 유지하는 GameModule lifecycle
- ModuleDirector가 수행하는 module 전환·상태 capture 수명
- 주입되는 ModuleContext와 manifest input allowlist
- ModuleDirector가 capture하고 SaveService가 보관하는 versioned JSON-safe 저장 수명
- game_library의 manifest catalog 등록·실행 흐름
- first_entry의 Input Bubble 시작·복원 로직
- module-local `AudioStreamPlayer2D`가 필요할 때 기존 audio bus 사용

새 module은 AppRoot, ModuleDirector, SaveService 구현 또는 다른 whitelist module을 직접 import하거나 참조하지 않는다. 위 whitelist 항목은 host integration 또는 필요한 최소 로직의 코드 단위 재검증 대상으로만 사용한다.

새 구현:

- `modules/top_down_action_rpg/` 아래 field/combat/domain/content/presentation
- combat은 positionless target-selection 기반
- NPC/event/route/equipment/content data는 module-local
- global/shared combat/player/inventory/event bus를 만들지 않음
- Retired Prototype combat/UI/asset은 가져오지 않음

## 11. 복제 금지 목록

다음은 원작의 skin이므로 계획과 콘텐츠에 넣지 않는다.

- 앨리스와 앨리스 저작물 고유 세계관·인물·가계·아이템
- 원작의 특정 찾는 대상과 정체
- 원작 캐릭터 이름·대사·catchphrase
- 원작 지역 순서·맵 배치·도착 지점
- 원작 문구, 동화 제목, 실제 역사 인물 이름
- 원작 UI/아이콘/스프라이트/효과
- 원작의 수치, drop, ending condition, quest chain
- 원작 성적 요소
- sexual choice, reward, scene, covenant

재사용하는 것은 mechanic relationship, authored structure, information hierarchy, content density다.

## 12. A~H evidence 범위와 미확인 항목

A~H 화면에서 직접 확인한 것:
- world-preserving NPC dialogue와 우측 choice list
- choice의 흰색/빨간색 presentation과 진행 화살표
- combat command list, 초록/빨간 bar, 하단 HP/MP/AP/status band
- world narration, page 단위 document, corrupted text
- H 화면의 player, 대상, blood/trace와 narration band

사용자가 설명한 것:
- A의 빨간 선택은 이 사건의 극단적 선택이다.
- B의 초록 bar는 다음 공격이 올 시간을 나타낸다.
- C~H는 가짜 바다거북 사건과 유서의 흐름으로 제시됐다.

아래 항목은 A~H만으로 확정하지 않는다.

- field camera height와 exact movement feel
- 16:9 TIN adaptation에서의 dialogue/command balance
- choice focus, cancel, unavailable, result focus
- target selection cursor와 cancel
- action gauge의 exact 수치와 advance cadence
- charge tell timing, sound, animation
- Guard/Dodge/Break의 실제 모션
- skills/magic/items/equipment submenu와 return
- hit, miss, critical, status application feedback
- death/recovery/checkpoint
- field encounter warning과 chase
- first frame, success/completion, ending
- input device defaults
- New Game+ / late content UX

[사용자 A~H evidence map](USER_PLAY_REFERENCE_2026-09-25.md)에 확인된 것과 미확인 항목을 분리했다. wiki memory로 빈 항목을 채우지 않는다.

## 13. 다음 입력

1. 사용자 세계관 메모
2. 메모와 A~H를 통합한 뒤 Reference Game 범위를 정한다.
3. 그 범위에 꼭 필요한 화면이 아직 없으면 targeted capture만 추가로 요청한다.
4. 실제 gameplay를 바꾸는 미결정만 질문한다.
5. shared understanding 확인 후 `plans/kits/` 아래 여러 파일로 Kit 계획 작성

예상 계획 분할은 콘텐츠와 스토리를 더 크게 둔다.

```text
04_TOP_DOWN_ACTION_RPG_KIT/
├── README.md
├── 01_SYSTEM_UX.md
├── 02_WORLD_STATE_AND_ROUTES.md
├── 03_STORY_AND_ENDINGS.md
├── 04_CHARACTERS_AND_RELATIONSHIPS.md
├── 05_ENEMIES_AND_ENCOUNTERS.md
├── 06_AUTHORED_CONTENT_AND_DATA.md
├── 07_REFERENCE_GAME.md
├── 08_SAVE_DEATH_AND_RECOVERY.md
├── 09_PRESENTATION_ART_AND_AUDIO.md
├── 10_TESTS_AND_ACCEPTANCE.md
└── 11_EXTERNAL_CODE_DECISIONS.md
```

이 구조는 생성 예시이며 shared understanding 뒤 확정한다.
