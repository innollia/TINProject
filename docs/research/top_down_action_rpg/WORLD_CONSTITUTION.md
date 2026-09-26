# Top-down Action-RPG 세계 헌장 v1

상태: Kit shared understanding 반영 완료. 계획·구현의 공통 source of truth.  
Primary Reference: BLACK SOULS 2 하나.  
원작 skin 복제 금지. 앨리스 제외.

## 1. 이 헌장의 목적

사용자의 긴 메모는 canon 원문이 아니라 문장 단위 idea source다. 이 헌장은 그 아이디어를 서로 충돌하지 않는 world rules, systems, characters, regions, encounters로 변환한다.

원문에서 다음은 자동 canon이 아니다.

- 대화 metadata와 작성자/날짜
- 중복 문장
- 독립 world rule이 없는 filler
- 한 장면의 우연한 joke
- 원작/타 작품의 고유 문구와 인물의 직접 복제

사용된 idea unit은 최소 60% 구조 변환한다. 60%는 원문 줄 수가 아니라 독립 idea unit 기준이다. core 120개와 magic supplement 40개를 합쳐 160개, gate은 96개다.

## 2. World spine

TIN의 세계는 여러 protocol이 recovery, recognition, authority를 서로 다르게 구현하는 하나의 deep system이다.

```text
Crown / persistent invariant
→ institutions and protocols
→ local modules and regions
→ NPC agents and player
→ event clusters
→ consequences and reinterpretations
```

- 개인은 바뀐다.
- 왕은 바뀐다.
- 왕관은 하나다.
- 왕관은 왕보다 오래간다.
- institution, title, loop, language system, operating protocol은 개인보다 오래간다.
- player는 investigator이면서 experiment/subject다.
- world는 simulation이라고 단정하지 않는다. 여러 local model이 서로 다른 reality claim을 만든다.
- absurdity는 deliberately strange한 장식이 아니라 competent한 local rule이 잘못된 category에서 작동할 때 발생한다.

## 3. Hard rules

### R01 — 불가능한 것에도 protocol이 있다

모든 anomaly에는 최소 한 개의 human/institutional response가 있다. response는 정답이 아니어도 된다.

### R02 — protocol은 대상을 category로 압축한다

기관은 실제 대상보다 institution이 이해하기 쉬운 category를 우선한다. category error가 disaster의 직접 원인이 될 수 있다.

### R03 — 추상화는 개인보다 오래 산다

왕관, title, order, loop, rank, record, language, recovery protocol은 사람이 교체되어도 유지된다. character death는 actor removal만 아니다.

### R04 — self는 여러 층위다

```text
body
memory
role
belief
institution
desire
social recognition
```

한 층위의 recovery가 다른 층위를 복구하지 않는다.

### R05 — 높은 해석은 낮은 정보를 버린다

player가 더 높은 cognition level로 올라갈수록 raw perception과 low-level contradiction이 사라진다. 해석은 빠르지만 distortion을 만든다.

### R06 — recovery는 서로 다른 continuity를 가진다

checkpoint, respawn, clone, reincarnation, loop, immortality, institutional re-entry는 같은 recovery가 아니다. 각 방식이 보존하는 self와 버리는 self를 명시한다.

### R07 — pressure는 여러 clock으로 작동한다

한 개의 global danger bar를 만들지 않는다. 최소한 institution response, contamination/resource, personal collapse, public record가 서로 다른 속도로 작동한다.

### R08 — NPC는 자기 protocol을 실행한다

NPC의 성격은 dialogue style보다 decision, resource access, refusal, survival, memory, faction action으로 나타난다. 한 번의 대사는 그 NPC가 특정 state에서 취할 수 있는 pressure voice다.

### R09 — enemy는 readable conflict다

모든 enemy는 region/resource/order 안에서 역할을 수행하고 고유 signature action, counter, cost, aftermath를 가진다. appearance-only weirdness는 enemy design가 아니다.

### R10 — detail은 두 곳 이상에 연결된다

사용한 detail은 최소 두 개의 system, NPC, region, faction, clock, route 중 하나 이상에 영향을 준다. 연결되지 않은 detail은 filler로 분류한다.

### R11 — 분기는 interaction cluster다

major branch는 6~12 NPC, 2~4 institutions, 2~3 clocks, partial truths, resource conflicts, delayed effects를 가진다. 모든 NPC가 서로 만날 필요는 없다.

### R12 — romance와 affection은 선택/commitment다

romance, loyalty, jealousy, grief, marriage, chosen family, care, betrayal, reconciliation, non-explicit physical affection를 허용한다. explicit sexual content, sexual reward, pornographic scene은 제외한다.

### R13 — body horror는 identity 사건이다

organ, clone, surgery, transformation, death, healing, memory, body authority를 세계 규칙과 player 선택에 명확하게 드러내되, spectacle이 아니라 system/state 변화로 기능시킨다.

### R14 — player knowledge는 world state와 별개다

플레이어가 이미 규칙을 알면 다시 발견 시간을 강제하지 않는다. NPC와 institutions는 player knowledge를 공유하지 않는다.

## 4. Orthogonal axes

Reference Game은 다음 네 축을 사용한다. 서로 값을 공유하지 않는다.

### A. `protocol_legitimacy`

기관이 승인한 protocol의 정당성. player가 행동할 때 어떤 authority가 player를 승인·기록·허용하는지 바꾼다.

### B. `recognition_drift`

world와 player가 대상을 무엇으로 보는가. monster/human/patient/artifact/operator의 category가 달라질 수 있다.

### C. `continuity_pressure`

respawn, clone, loop, reincarnation, immortality가 누적한 identity와 responsibility의 부담. 숫자 combat HP와 별개다.

### D. `resource_scarcity`

ecological, economic, administrative, attention, memory resource의 부족. quantity shortage뿐 아니라 classification/access shortage도 포함한다.

## 5. Pressure clocks

각 clock은 start, visible signal, escalation, intervention, irreversible point, aftermath를 가진다.

- `institutional_response_clock`: 기관이 anomaly를 처리하기까지
- `contamination_clock`: recovery/recognition failure이 누적되는 정도
- `public_record_clock`: 기록이 조작되고 society가 category를 확정하는 정도
- `resource_collapse_clock`: 생존 infrastructure가 한계에 도달하는 정도
- `personal_collapse_clock`: NPC가 자신의 role/identity를 유지하지 못하는 정도
- `crown_alignment_clock`: 왕관/authority가 특정 operator를 선택하거나 교체하는 정도

시계는 상시 HUD로 전부 노출하지 않는다. world event, NPC warning, document, resource shortage, enemy tell로 각기 다른 방식으로 드러낸다.

## 6. Region contract

모든 region은 다음을 가져야 한다.

```text
RegionDefinition
- id
- one-sentence conflict thesis
- physical topology
- entry/exit
- authority
- dominant protocol
- resource flow
- residents
- pressure clocks
- hidden state
- current state
- combat/noncombat content
- initial interaction cluster
- revisit variants
- unresolved debt
- cross-region links
- one-off dialogue seeds
```

region은 이동 거리로 분량을 만들지 않는다. 재방문과 state difference가 주요 play value다.

## 7. Character contract

```text
CharacterDefinition
- id
- public role
- private role
- desire
- fear
- contradiction
- capability
- resource access
- knowledge boundary
- relationship states
- speech pressure
- silence/lie pattern
- interaction verbs
- combat/encounter profile
- survival/death/removal result
- absence result
- one-off dialogue seeds
- clock links
- cross-links
```

NPC 한 명은 dialogue-only가 아니다. 최소 하나의 system port를 소유한다.

## 8. Enemy and encounter contract

```text
EnemyDefinition
- id
- region/institution role
- body/silhouette class
- baseline action
- signature action
- telegraph
- valid counters
- forbidden counters
- status/resistance
- phase triggers
- summon/linked actors
- reward/resource effect
- aftermath

EncounterDefinition
- context
- roster
- activation
- target priority
- clock pressure
- victory/escape/failure
- world effect
- repeat policy
```

charge/break는 보편 정답이 아니다. dodge, resource lock, raw survival, scripted counter, status, escape, noncombat resolution도 authored counter다.

## 9. Subagent ownership

- 중앙 constitution과 stable ID를 읽고 독립 작성한다.
- 자기 domain 밖의 law, timeline, faction boundary를 수정하지 않는다.
- 발견한 충돌은 report하고 merge하지 않는다.
- return에는 seed_id, transformation, local rule, cross-links, consequences, risks, open questions를 포함한다.
- character, region, encounter, flow, validation 파일을 서로 다른 owner가 맡는다.

## 10. Anti-generic gate

사용할 seed는 다음을 모두 통과해야 한다.

1. local rule이 있다.
2. 원 surface를 제거한 변형이 있다.
3. 최소 두 cross-link가 있다.
4. immediate consequence가 있다.
5. delayed consequence가 있다.
6. NPC/region/system 중 하나가 실제로 그것을 필요로 한다.
7. 이름만 바꿔도 generic이 되지 않는다.
8. “기괴함”만으로 정당화되지 않는다.

실패한 seed는 `filler`, `duplicate`, `tone-only`, `source-copy-risk`, `unbound`로 기록한다.

## 11. Art and asset boundary

현행 이미지 기반은 GPT image + 개인 화풍 코어 + project art layer다. at-icons 조립은 현재 제작 기준으로 승격하지 않는다.

이번 one-shot 실행에서 이미지 생성/editing을 임의로 호출하지 않는다. 실제 화면에 필요한 asset family는 brief와 프로젝트 layer를 먼저 만들고, 명시적 자산 제작 요청이 있을 때 candidate를 생성한다.

## 12. Magic supplement

사용자 메모의 magic theory는 별도 우주가 아니라 world protocol의 한 implementation layer다.

- canonical contract는 `concentration-mediated craft`다.
- 마나/마력은 단일 스탯이 아니라 concentration, accumulation, emission, circulation, body compatibility, environmental pressure를 가진다.
- 농도는 효율과 안전을 동시에 바꾸며, 임계치를 넘으면 failure와 world pressure를 만든다.
- magic은 material/medium가 필요하다. 같은 spell도 매개체·도구·숙련·환경에 따라 다른 result/state를 만든다.
- baseline craft: 종이/직물에 마나를 적셔 자르는 weave/scroll.
- rigid craft: 종이접기처럼 입체 구현이 어려운 방식은 더 높은 complexity/cost를 가진다.
- void craft: 가위로 공허를 잘라 다른 층/차원을 여는 방식. shape는 destination과 risk를 authored contract로 결정한다.
- combat magic은 pre-combat preparation과 field improvisation을 모두 포함한다.
- magic 실패는 즉사가 아니라 환경/신체/사회/지식/계약 state를 바꾼다.
- magic theory의 이름은 아직 고정하지 않는다. plan data의 authored glossary slot으로 둔다.
- magic era/module은 canonical `H0`/`R1`~`R7` 또는 명시적인 후속 `R8` 경로로 진입해야 한다.

## 13. Completion boundary

- world constitution과 ledger가 먼저 존재한다.
- 계획서가 split files로 완성된다.
- 구현은 계획서와 ownership gate를 통과한 뒤 시작한다.
- Reference Game은 10분 이상, 여러 authored cluster와 recovery path를 사용한다.
- 자동 테스트, 실제 플레이, 720p/FHD/QHD 캡처가 모두 필요하다.
- 이미지/asset production은 user approval gate를 별도로 통과해야 한다.
