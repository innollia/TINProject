# 사용자 실제 플레이 레퍼런스 — BLACK SOULS 2

상태: 사용자 제공 A~H 8장 직접 확인 완료.  
일자: 2026-09-25  
Primary Reference: BLACK SOULS 2  
용도: 실제 화면/스토리 전달 방식의 레퍼런스. 원작 skin 복제 금지.

## 1. 출처 처리

- 사용자가 2026-09-25 대화에서 실제 플레이 캡처 8장을 제공했다.
- A: NPC conversation/choice
- B: combat command/action gauge
- C~H: 가짜 바다거북 사건과 유서
- 캡처는 모두 960×720이다.
- 원본 첨부는 읽기 전용 reference다. crop, redraw, 생성적 편집, world asset 변환을 하지 않는다.
- 현재 작업 환경은 첨부 binary의 안정적인 repository path를 노출하지 않았다. 따라서 아래는 실제 화면 관찰과 사용자 설명을 통합한 evidence record이며, 원본 이미지 파일 보존 여부는 별도로 확인한다.

## 2. 상태별 evidence map

| ID | 화면 상태 | 화면에서 직접 확인한 것 | 사용자 설명/caption | TIN이 가져갈 수 있는 규칙 | 아직 모르는 것 |
|---|---|---|---|---|---|
| A | NPC conversation + choice | world와 NPC가 배경에 남음, 하단 portrait dialogue, 우측 vertical choice list, 흰색/빨간색 선택 문구, 진행 화살표 | 빨간 선택이 이 사건의 극단적 선택이라고 설명함 | world-preserving dialogue, speaker portrait, semantic tag와 presentation class 분리, page 단위 advance | 선택 focus, 입력, cancel/back, red 선택의 정확한 semantic과 결과 |
| B | combat command | 중앙 enemy, 좌측 command list, 초록 bar와 별도 red bar, 하단 portrait/status/HP/MP/AP band | 초록 bar가 다음 공격이 올 시간이라고 설명함. red bar의 의미는 확인하지 않음 | command-first combat, timing bar의 domain projection, combat-local resource/status band | target focus/cancel, gauge의 정확한 의미·advance·state 유지 여부, red bar, AP 정의, submenu, 실제 resolution |
| C | world event 시작 | 정상 실내 world 위에 어두운 narration band, player와 NPC/사건 대상, 진행 화살표 | 가짜 바다거북 사건의 시작이라고 설명함 | world 위에 사건 정보를 띄우는 정보 위계 | trigger 조건, 입력 잠금, event duration |
| D | document page 1 | 어두운 배경에 큰 흰 글자, 여러 줄, page advance | 유서 1페이지라고 설명함 | artifact/document를 설명의 주인공으로 사용하고 한 page의 정보량을 제어 | font bounds, page timing, 선택 여부 |
| E | document page 2 | 같은 layout에서 다음 page로 진행 | 같은 유서의 2페이지라고 설명함 | 긴 정보를 page 단위로 나누는 authored pacing | font bounds, page timing, 선택 여부 |
| F | document page 3 | world와 일부 배경이 어둡게 남는 reading layer | 같은 유서의 3페이지라고 설명함 | 중요한 문서를 world 위에 읽는 layered composition | 배경 dimming 규칙 |
| G | corrupted page | 흰 글자 일부의 적색화, 깨진 문자, 비정상적인 줄 분리 | — | story artifact가 cognition/corruption state를 표현할 수 있음 | 색의 정확한 trigger, recovery, accessibility |
| H | world aftermath | world frame에 player, 대상, blood/trace와 narration band가 보임 | 가짜 바다거북 사건의 aftermath라고 설명함 | 사건 결과를 실제로 변하는 world/NPC/object state에 기록 | 대상의 최종 state, 재방문 결과 |

## 3. A — NPC conversation과 선택지

### 3.1 화면 구성

- world는 화면의 대부분을 유지한다.
- player와 NPC가 같은 field frame 안에 있다.
- 하단 dialogue band가 portrait, speaker name, 본문을 맡는다.
- 우측 panel이 vertical choice list를 맡는다.
- 하단 중앙의 down triangle은 추가 text 또는 다음 page가 있다는 progress affordance다.
- 대화 중에도 player/NPC/world 위치 관계를 잃지 않는다.

### 3.2 선택지의 정보 규칙

- 기본 선택은 흰색으로 표시된다.
- 사용자가 설명한 극단적 선택은 빨간색으로 표시된다.
- 이 캡처만으로 red이 항상 “위험”, “불가”, “성적” 중 무엇을 뜻하는지 확정하지 않는다.
- 사용자가 빨간 선택을 “극단적 선택”으로 설명한 사실만 기록한다. moral extremity/violent intent 같은 더 좁은 semantic은 TIN 설계에서 정하고 원작 규칙으로 확정하지 않는다.
- red를 accessible focus와 동일시하지 않는다. 선택 위치는 별도 focus navigation으로 명시해야 한다.
- TIN에서는 색을 보조 channel로만 쓰고, 선택 문장·초기 설명·결과가 해당 presentation category를 보조해야 한다.

### 3.3 적용할 dialog contract

```text
field state
→ interact intent
→ conversation state lock
→ portrait/speaker/text page
→ choice list or advance
→ consequence
→ field state projection
```

- dialogue는 world를 장식 background로 축소하지 않는다.
- portrait는 누구의 말인지 빠르게 판별하게 한다.
- choice는 별도 list panel에 모아 keyboard/gamepad navigation 단위로 만든다.
- irreversible choice를 숨기지 않되, 설명문으로 결과를 대신하지 않는다.
- choice 결과는 dialogue만 바꾸지 않고 NPC/quest/world/relationship state에 반영한다.

## 4. B — combat command와 action timing

### 4.1 화면 구성

- enemy가 화면 중앙의 visual focus다.
- command list는 좌측에 있으며 위에서 아래로 attack, skill/magic, defend, item, escape, equipment category를 노출한다.
- enemy 하단의 초록 bar는 사용자가 설명한 “다음 공격이 올 시간”이다.
- 초록 bar 아래 별도 red bar가 있다. 사용자 설명으로 semantics가 확정되지 않았으므로 plan에서 HP인지 다른 combat resource인지 확인하지 않는다.
- 화면 하단 player band는 portrait, status effect icons, HP, MP, AP를 노출한다.
- player combat stats는 combat-local band에 있고, dialogue/field screenshot에는 같은 band가 보이지 않는다.

### 4.2 Combat information contract

```text
command category
→ target/intent
→ action queued or no-turn resolution
→ enemy/action timing change
→ hit/status/resource result
```

- command list는 공격, 기술/마법, 방어, item, 도주, 장비의 상위 category를 유지한다.
- 장비 command가 battle에서 full equipment screen을 여는지, quick command인지, battle 후 disengage인지 미확인이다.
- 이 combat 화면에서는 사용자가 설명한 enemy next-attack timing을 초록 bar로 보여 준다. command/target/result state에서도 유지되는지는 A~H만으로 확정하지 않는다.
- gauge가 정확한 턴/초/상대 비율 중 무엇인지는 screenshot으로 확정하지 않는다.
- target 선택과 focus/return screenshot은 아직 없다.
- AP가 action point인지 다른 resource naming인지는 미확인이다.

### 4.3 시스템화 규칙

- command category와 action definition을 분리한다.
- action은 turn cost, target mode, resource cost, cooldown, telegraph, status payload, counter를 가진다.
- action timing bar는 domain scheduler의 projection이다.
- UI가 gauge를 계산하거나 미래 enemy action을 추측하지 않는다.
- player HUD는 combat state에서만 나타날 수 있다. field에 상시 HP/MP/AP band를 복제하지 않는다.
- escape와 equipment의 failure/return은 실제 reference 동작을 추가 확인한 뒤 고정한다.

## 5. C~H — world event, document, corruption, aftermath

### 5.1 사건 흐름

사용자가 A~H를 제시한 순서와 각 화면의 직접 관찰을 결합해 얻는 범용 순서:

```text
정상 world
→ NPC/object interact
→ 짧은 world narration
→ 긴 artifact/document를 page 단위로 읽음
→ artifact가 비정상/오염 상태를 표시
→ 같은 world로 복귀
→ world 위에 player/target/blood/trace가 보이는 aftermath 화면
```

### 5.2 World narration

- C와 H는 world 위에 어두운 translucent band를 사용한다.
- player와 대상은 여전히 보인다.
- band는 사건의 현재 state를 설명하거나 unpack한다.
- 긴 essay를 화면 중앙 modal로 몰지 않는다.

TIN 적용:

- dialogue와 artifact는 별도 content type으로 authored한다.
- artifact mode에서도 world의 위치 관계를 완전히 버리지 않는다.
- narration band가 event ID/choice consequence를 소유하지 않는다.

### 5.3 Document page

D~F는 artifact를 읽는 동안 큰 흰 text를 어두운 배경에 놓는다.

- 긴 정보는 한 화면에 모두 넣지 않고 page로 나눈다.
- 각 page에는 명확한 line wrap과 next-page affordance가 있다.
- portrait와 command menu는 사라져 reading focus가 하나가 된다.
- 원작 문구와 사건은 복제하지 않는다.

TIN authored schema:

```text
DocumentDefinition
- stable_id
- pages[]
- optional corruption rules per page/token span
- world presentation mode
- unlock/availability condition
- post-read effect
- revisit policy
```

### 5.4 Corrupted text

G는 document 자체가 깨진 상태를 표현한다.

- 글자 일부가 빨갛게 변한다.
- 일부 문자가 깨지거나 순서가 어긋난다.
- 줄이 비정상적으로 분리된다.
- pagination은 유지되지만 text readability가 의도적으로 변한다.

TIN 적용:

- random typo를 매번 생성하지 않는다.
- authored corruption rule이 token/character/state threshold를 명시한다.
- 중요한 accessibility option이 있다면 red-only communication을 금지한다.
- corrupted state는 story artifact data와 presentation effect를 분리한다.
- 원작의 정확한 glitch sequence와 문구는 복제하지 않는다.

### 5.5 Aftermath

H는 이벤트가 끝난 뒤 같은 장소로 돌아온 world state를 보여 준다.

- player와 대상이 같은 frame에 있다.
- blood/trace가 현재 world object로 보인다. 재방문 시 persistent한지는 A~H만으로 확정하지 않는다.
- narration이 사건 결과를 확인시킨다.
- 화면이 clean menu/quest log로 바뀌지 않는다.

TIN 적용:

- irreversible event는 dialogue flag만 남기지 않는다.
- world prop, NPC presence/absence, route availability, dialogue, relationship 중 실제 변화할 surface를 plan에 지정한다.
- 재방문 state를 별도 authored variant로 둔다.
- 긴 이동으로 consequence를 보여 주지 않는다.

## 6. A~H에서 얻는 content authoring 규칙

### 6.1 Story content type

최소한 다음 authored type을 분리한다.

```text
Conversation
ChoiceSet
NarrationBeat
Document
CorruptionRule
AftermathState
WorldPropState
NPCStateTransition
```

하나의 giant dialogue script에 전부 넣지 않는다.

### 6.2 Character rule — TIN 추상화

- TIN에서는 NPC의 personality/decision을 red option, request, refusal, aftermath와 연결하는 authored pattern을 사용할 수 있다.
- TIN에서는 character introduction의 defect를 선택지 category와 aftermath에 반복할 수 있다. A~H가 그 defect 자체를 확인했다는 뜻은 아니다.
- NPC가 사건 전/중/후에 같은 identity를 가지는지는 authored state로 확인한다.
- dialogue portrait는 gameplay identity를 보조하지만 domain truth는 아니다.

### 6.3 Choice rule

각 choice는 최소 다음을 가진다.

```text
choice_id
text
semantic_tags
presentation_class
availability condition
irreversibility class
immediate result
delayed result
world/NPC/quest/relationship effect
return focus
```

- TIN은 semantic_tags와 presentation_class를 분리한다. red는 별도 focus가 아니며 danger나 destructive 의미를 대신하지 않는다.
- focus와 disabled는 다른 state다.
- unavailable choice는 왜 unavailable한지 world action으로 설명 가능해야 한다.
- 결과를 dialogue 한 줄로만 끝내지 않는다.

### 6.4 Document rule

- page count와 content budget을 authored한다.
- page 안에서 자동 overflow만 믿지 않는다.
- 1280×720, 1920×1080, 2560×1440에서 line wrap과 maximum page를 검수한다.
- localization/player-entered name이 길어지는 경우를 고려한다.
- corrupted text는 accessibility와 정보 전달을 해치지 않게 한다.

## 7. 16:9 TIN 적용에서 따라갈 것과 바꿀 것

원작 캡처는 960×720, 4:3이다. TIN은 1280×720, 1920×1080, 2560×1440을 지원해야 한다.

따라서 그대로 복제하지 않고 다음을 따른다.

- world/command/dialogue의 relative priority는 유지한다.
- command list의 left placement와 enemy-centered focus는 유지한다.
- gauge를 enemy object에 붙이는 관계는 유지한다.
- 하단 combat resource band의 정보 priority는 유지하되 anchor/Container로 재구성한다.
- 16:9 여백에서 command와 bottom band가 enemy를 가리지 않게 한다.
- dialogue portrait/name/text/choice의 정보 순서를 유지한다.
- document page는 16:9에서 한 페이지 정보량을 다시 튜닝한다.
- 원작 frame, checker pattern, font asset, portrait art는 복제하지 않는다.

## 8. A~H에서 직접 관찰한 것, 사용자 설명, TIN 추상화

화면에서 직접 관찰한 것:
- NPC dialogue는 world를 유지하면서 portrait, speaker, text, choice를 보여 준다.
- combat 화면은 중앙 enemy, 좌측 command list, 초록/빨간 bar, 하단 HP/MP/AP/status band를 보여 준다.
- C와 H는 world 위에 narration band를 띄운다.
- D~F는 page 단위 document reading layer를 보여 준다.
- G는 일부 문자의 적색화·깨짐·비정상적인 줄 분리를 보여 준다.
- H에는 player, 대상, blood/trace가 보인다.

사용자가 설명한 것:
- A의 빨간 선택은 이 사건의 극단적 선택이다.
- B의 초록 bar는 다음 공격이 올 시간을 나타낸다.
- C~H는 가짜 바다거북 사건과 유서의 흐름으로 제시됐다.

TIN 추상화:
- dialogue, choice, document, aftermath를 서로 다른 authored content type으로 추가한다.
- irreversible event는 실제 변경되는 world/NPC/object surface를 authored state로 기록한다.
- red presentation은 focus나 danger semantic을 대신하지 않는다.

## 9. 이 evidence로 아직 확정하지 않는 것

- choice focus/cancel/result focus
- target selection focus/cancel
- skills, magic, item, equipment submenu
- active Guard, Dodge, Break와 charge tell의 실제 모션
- hit, miss, critical, status application feedback
- enemy/player action resolution 순서
- death, save/checkpoint, recovery transition
- field encounter warning와 chase
- first frame, success/completion, ending
- New Game+ / late content UX
- input device defaults
- gauge의 정확한 수치와 advance cadence

이 항목은 wiki를 memory로 채우지 않는다. 세계관 메모와 통합한 뒤 Reference Game 범위를 정하고, 계획 구현에 꼭 필요한 screen이 아직 없으면 그때 사용자에게 targeted capture를 요청한다.

## 10. 복제 금지

이 evidence에서 가져가는 것은 screen grammar와 content relationship다.

- 원작 NPC 이름·초상·대사·선택지 문구
- 가짜 바다거북/그리피 등 원작 인물과 사건
- 원작 유서 내용
- 원작 문서 오염 문자열
- 원작 지도·blood placement·interior layout
- 원작 font, frame, portrait, sprite

TIN 세계관은 사용자 메모를 받은 뒤 새로 정한다.
