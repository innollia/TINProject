# Kit 04 — 월드 상태와 라우트

상태: 계획 문서. 구현·이미지 제작·다른 문서 변경은 이 파일의 범위가 아니다.  
입력 정본: `docs/research/top_down_action_rpg/PLAN_RESOLUTION.md`(문서 간 충돌의 canonical 해석), `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`, `docs/research/top_down_action_rpg/IDEA_LEDGER.md`, `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/README.md`  
Primary Reference: **BLACK SOULS 2 하나**. 다른 게임의 맵·UI·분위기를 혼합하지 않는다.

이 파일이 소유하는 것(다른 plan 문서가 인용해야 하는 정본):

- canonical world와 node ID: `H0` + `R1`~`R8`
- `region_role` 9개 token(§1)
- named axis token(§3)과 `-3..3` integer mapping(§3.3)
- pressure clock 6개의 stage vocabulary와 integer mapping(§4.1)
- route edge `E01`~`E18`, gate `G0`~`G8`, route state vocabulary(§5, §6.1)
- field resource key(`res_*` 매핑은 `06`이 소유)(§5.4, §5.5)
- event cluster `HC-00` + `RC-01`~`RC-08`(§8)
- seed accounting: core 120 + magic supplement 40 = 160, gate 96(§11)

## 1. Map-first 설계 잠금

Reference Game의 이름은 **The Undersign Basin: A Season of Returning**으로 고정한다. 플레이어는 The Undersign Basin의 field investigator이면서, 각 recovery·recognition·authority protocol의 experiment/subject다. 전용 왕좌를 즉시 받거나 정답 범주의 소유자가 되지 않는다. 대신 선언, 증거, 계약, 치료, 번역, 자원 분배, recovery를 실행해 world protocol이 무엇을 survivor로 인정할지 바꾼다.

세계의 중심은 **Crown of Continuance**다.

- literal object: Crownwell Archive 위에 고정된 다섯 조각의 물리적 왕관. 사용자는 왕관을 들어 올리지 않고 그 위치와 그림자를 관찰·기록한다.
- political institution:.operator를 교체하고 recovery/recognition/authority 중 어느 protocol이 우선하는지 정하는 `Crown Protocol`.
- metaphysical invariant: operator가 바뀌어도 왕관과 이전 protocol의 debt는 사라지지 않는다. recovery는 원래 사람의 role을 복원하는 대신, 무엇을 보존할지에 따라 다른 연속성을 만든다.

지도는 1개의 허브와 8개의 authored region으로 고정한다. `region_role` token은 `06` RegionDefinition의 `region_role` field 정본이며, 여기서 새 이름을 만들지 않는다.

| ID | authored place | `region_role` | map role | one-sentence causal thesis |
|---|---|---|---|---|
| H0 | The Undersign Exchange | `hub_registration_ration_appeal` | 중앙 허브 | 모든 복귀·자원·기록을 권한과 빚으로 변환해 다음 라우트를 만든다. |
| R1 | The Returning Kiln | `recovery_reentry` | recovery/backroom | 복귀는 원래 role을 되찾지 않고 새 continuity debt를 만든다. |
| R2 | Siltglass Commons | `resource_allocation` | ecology/settlement | clone과 추출의 합산 소비가 물·종자·지식의 접근성을 바꾼다. |
| R3 | Bellhouse Hospice | `intervention_scheduling` | care/faith | faith는 응답을 빠르게 만들지만 consent와 social recognition을 지연시킬 수 있다. |
| R4 | Crownwell Archive | `translation_precedence` | record/translation | 번역이 category error를 고쳐서가 아니라 새로운 local law를 만든다. |
| R5 | Glasswing Ordinal | `permission_before_transformation` | transformation/labor | 변환은 전투 능력뿐 아니라 labor status와 socially recognized name을 바꾼다. |
| R6 | Gristmarket Ward | `organ_authority_negotiation` | organ/cure economy | 장기와 대체 부품이 독립된 authority가 되어 몸·신분·빚을 동시에 분류한다. |
| R7 | The Hollow Orchard | `boundary_crown_precedence` | boundary/crown | wall의 phase와 crown alignment가 physical topology와 모든 route precedence를 바꾼다. |
| R8 | The Folding School | `magic_training_craft_labor` | magic academy / craft diffusion | concentration-mediated craft에 학교가 공정·자격·고용을 소유하면 power가 labor class가 되고, curriculum이 바뀌면 R5 boot·R4 glossary·R7 boundary가 다시 분류된다. |

`R8 The Folding School`은 별도 우주가 아니라 이 세계의 authored module이다. 진입 경로는 `E18`(R5–R8) 단 하나이며 gate는 `G5`다. `R8`이 world state, clock, resource, NPC roster에 쓰는 표면은 `R1`~`R7`과 완전히 같은 계약을 따른다.

각 region은 이동거리로 분량을 만들지 않는다. 처음 방문, 사건 후, recovery 후, crown alignment 후의 차이를 재방문 가치로 삼는다. H0도 중립적인 상점이 아니라 world write를 권한으로 번역하는 authored location이다.

### 1.1 물리 지도 원칙

- 모든 edge는 실제 이동 구간이다. 보이지 않는 teleport는 없다. H0의 return desk도 부상자의 recovery 경로를 호출할 뿐 장소를 강제로 복사하지 않는다.
- 첫 진입 시 H0에서 다섯 개의 서로 다른 출발 edge를 확인할 수 있다. 비용과 선언은 다르지만 어느 한 길을 강제하지 않는다.
- 후반 edge는 순환을 만든다. 한 edge가 닫혀도 authored content 전체가 삭제되지 않으며, 우회로 다른 institution과 다른 pressure clock을 경험하게 한다.
- world map은 상시 HUD가 아니다. H0의 `Counterweight Map`, field의 physical sign, NPC의 route card, 기록의 경로 도면으로 정보가 요청될 때만 공개된다.
- region 경계는 이동 animation보다 먼저 protocol 결과를 보여 준다. 문·다리·승강기·수로가 통과 조건을 바꾸면 field 안에서도 이유를 확인할 수 있어야 한다.
- 새 era/module은 기존 world를 복제하지 않고 `H0`/`R1`~`R8` 중 하나에 명시적 entry path를 추가한다. `R8`은 이 규칙의 첫 적용자다: `E18`(R5–R8), gate `G5`, `labor pledge` resolution 이후에만 통과한다. magic-era content가 world state에 쓰는 것은 concentration·circulation·craft record·body load이며, 새 축·새 clock·새 recovery type을 만들지 않는다.
- `E18`은 양방향 edge다. `R8`의 return leg는 `E18`을 그대로 되짚어 `R5`로 돌아온 뒤 `E11`/`E12`/`E14`/`E15` 중 하나로 이어진다. `R8`은 두 번째 backtracking affordance로 `R8` 내부의 `course index` 반환 통로를 갖고, 이것은 gate가 아니라 region 내부 route state다.

인접 관계는 아래 edge registry가 정본이다. 여기의 화살표는 일방통행을 뜻하지 않는다. 표의 gate가 닫힐 때도 해당 장면과 NPC debt는 남으며, 다른 edge의 variant로 다시 접근한다.

## 2. World spine과 causality contract

World flow는 다음 순서로 읽는다.

1. Crown of Continuance가 precedence를 보유한다.
2. Crown Protocol과 recovery·recognition·authority protocol이 각 region의 rule을 해석한다.
3. region의 resource·route·record가 NPC system port에 입력된다.
4. NPC 또는 player가 regional event cluster를 실행한다.
5. immediate write와 delayed clock write가 commit된다.
6. 다른 region의 route·NPC·encounter variant가 바뀐다.

### 2.1 Root law

모든 anomaly는 human/institutional response를 하나 이상 가진다. response는 정답이 아니어도 되며, competent local rule이 잘못된 category에 적용될 때 political absurdity가 발생한다.

기관은 대상의 본질보다 현재 category를 우선한다. `person`, `patient`, `operator`, `artifact`, `organ authority`, `worker`, `contagion`은 서로 겹칠 수 있지만 같은 meaning으로 사용하지 않는다. 한 층위의 recovery가 다른 층위를 자동 복구하지 않는다.

- body가 살아도 memory가 원래 사람의 것이 아닐 수 있다.
- record가 정확해도 social recognition이 없을 수 있다.
- title이 남아도 operator가 바뀌었을 수 있다.
- 물리적 왕관이 동일한 위치에 있어도 authority가 다른 protocol을 선택할 수 있다.

### 2.2 Era spine

세계는 여러 module/era를 가지며, era가 바뀌어도 region 자체를 reset하지 않는다. 각 era는 physical layer, institution, record format, recovery protocol의 층으로 남는다.

- `E1 The First Return`: Crown of Continuance를 하나의 object로 취급하던 era. R1의 최초 door와 R7의 oldest wall phase가 이 층이다. 현재는 R1-02와 R7-01의 low-level evidence로만 접근한다.
- `E2 Administrative Recovery`: Return Bureau, hospice, archive, organ exchange가 recovery를 기록·분류하기 시작한 era. R3의 latency bell, R4의 incident form, R6의 custody registry가 이 층이다. 현재 authority의 기본 language를 제공하지만 항상 정확하지 않다.
- `E3 The Undersign`: 여러 protocol이 동시에 실행되며 Crownwell의 operator seat가 비어 있는 현재 era. H0의 provisional docket, R2의 resource collapse, R5의 transformation contract, R7의 phase shift가 이 층에서 서로 충돌한다.
- `E4 The Concentration Layer`: 위 세 era 위에 쌓인 magic implementation era다. 새 우주가 아니라 같은 `Crown / institutions / local modules / NPC agents / event clusters` spine 위의 한 층이다. `R2`의 humidifier/disperser/circulator, `R3`의 mana-profile triage, `R4`의 magic glossary slot, `R5`의 weave/fold/void-cut boot, `R6`의 organ magic, `R7`의 void-cut consequence, `R8`의 curriculum이 이 층의 물리적 표면이다.

`E1`~`E4`는 era ID이고 `E01`~`E18`은 route edge ID다. 두 namespace를 섞지 않으며, `E4`를 추가해도 `E18`이 18번째 edge라는 사실은 바뀌지 않는다.

era 전환은 별도 chapter clear가 아니다. player가 한 era의 evidence를 다른 era의 institution에 제출하면 category error와 route variant가 발생한다. 이전 era의 NPC는 삭제하지 않고, 현재 era의 record에 의해 role/access가 바뀐 채 재등장할 수 있다. magic era는 특히 이 규칙을 따른다: 학교가 possession을 등록하지 않은 craft는 illegal이 아니라 `unrecorded`다. `Crown Protocol`은 `E4` era를 별도 precedence로 다루지 않으며, magic 이론이 새로운 operator 주장을 하려면 `G8`의 기존 channel을 타야 한다.

### 2.3 Player의 위치

플레이어는 다음 네 capability만 가지고 시작한다.

1. 현재 대상을 하나의 category로 선언하거나 선언을 보류한다.
2. physical evidence, document, testimony, resource를 실제로 운반하거나 교환한다.
3. recovery·translation·transformation·boundary 행동의 결과를 관찰한다.
4. world가 그 행동을 어떤 protocol로 기록했는지 확인할 수 있다.

플레이어의 기존 지식은 world state와 별개다. 이미 알고 있는 문장·암호·공식은 다시 발견하도록 강제하지 않는다. 순수 knowledge gate는 `clue_found` 같은 flag로 잠그지 않고, 지금 문장을 말하거나 물건을 내밀거나 phase를 조작하는 행동을 요구한다.

## 3. 네 개의 직교 축

네 축은 서로 값을 공유하지 않는다. combat HP, damage number, inventory count, mana 수치가 네 축의 어느 것도 직접 대표하지 않는다. 각 행의 "고정된 값 순서"는 아래에서 위로 오가는 **ladder 순서**이며 좋고 나쁨의 점수가 아니다. 정수 값은 이 ladder의 위치다(§3.3).

| 축 | 고정된 값 순서 | 값을 바꾸는 주체 | world 결과 |
|---|---|---|---|
| A `protocol_legitimacy` | `unlicensed → provisional → sanctioned → contested → successor` | credential, contract, hearing, operator installation | route permission, institution response, who may give a valid order |
| B `recognition_drift` | `person → patient → operator → artifact → organ-authority → unclassified` | observer, document, public rumor, organ voice, medium/tool record | target priority, encounter label, social relationship, legal treatment |
| C `continuity_pressure` | `single → linked → branched → loop-bound → crown-debt` | recovery, clone, loop, re-entry, branch, lineage inheritance | which memories/roles/obligations survive, event aftermath, route return point |
| D `resource_scarcity` | `buffered → rationed → localized → strained → failing → collapsed → externally-mediated` | extraction, ration, attention, medicine, parts, seed stock, medium stock, circulation capacity | physical traversal, encounter reinforcement, institution cost, settlement survival |

`resource_scarcity`만 `strained` 단계를 가진다. 이 단계는 §3.2 초기 matrix와 §7 dossier가 실제 사용하는 값이므로 canonical ladder에 포함된다. clock `resource_collapse_clock`에는 `strained` 단계가 **없다**(§4.1). 축 ladder와 clock ladder는 의도적으로 다른 granularity를 쓰며, 서로의 token을 빌려 쓰지 않는다.

### 3.1 직교성 검사

- A가 높고 B가 낮을 수 있다. 합법적인 artifact도 존재한다.
- B가 artifact여도 C가 single일 수 있다. 기록상 대상이 바뀌어도 최초 연속성은 남는다.
- D가 collapsed여도 A가 sanctioned일 수 있다. 희소한 자원에 대한 공식 권한은 유지될 수 있다.
- C가 branched여도 combat power가 낮다는 뜻은 아니다. 분기 자체는 combat modifier가 아니라 책임·증거·재방문 상태다.
- 어떤 world event도 두 축을 동시에 갱신한다고 기록하지 않는다. 한 event가 두 축에 영향을 줄 때는 서로 다른 write와 서로 다른 immediate/delayed consequence로 분리한다.
- R8에서 medium/tool이 B를 `artifact` 쪽으로 밀어도 A는 `provisional`에 머무를 수 있다. 미등록 craft는 권한 없는 것이지 미분류가 아니다.
- lineage가 C를 `linked`로 올리면 A는 변하지 않는다. 가문 접근권은 social continuity이지 institutional authority가 아니다.

### 3.2 초기 축 matrix

matrix의 `B` 칸은 `primary token`과 선택적 `disputed claim` 두 칸으로 읽는다. disputed token은 B ladder 위에 있든 없든 상관없고 `disputed_claim` record로만 보관한다. B primary를 고치는 write와 disputed claim을 추가하는 write는 서로 다른 write다.

| node | A legitimacy | B recognition (primary) | B disputed claim | C continuity | D scarcity |
|---|---|---|---|---|---|
| H0 | provisional | person | artifact | linked | rationed |
| R1 | provisional | patient | artifact | branched | localized |
| R2 | sanctioned | person | worker | branched | failing |
| R3 | contested | patient | worker | linked | localized |
| R4 | sanctioned | artifact | record | linked | rationed |
| R5 | contested | operator | worker | linked | localized |
| R6 | provisional | organ-authority | person | linked | failing |
| R7 | contested | unclassified | — | crown-debt | collapsed |
| R8 | provisional | person | artifact | linked | localized |

- R8의 B disputed claim `artifact`는 소지한 craft 도구/매체를 school이 어떻게 분류하는지 남는 문제다. 등록하면 `person`이 유지되고, 미등록 도구가 possession으로Filing되면 B primary가 `artifact`로 이동한다.
- R7은 `crown-debt`에서 시작한다. `Clone Burial`로 값을 낮추지 않고 named branch로 남기는 것이 R7의 rule이다(§7.8).
- R2/R3의 disputed `worker`는 census와 care roster가 같은 사람을 각각 다른 category로 기록한 상태다. `public_record_clock`이 `canonical`에 닿으면 어느 한쪽만 B primary가 된다.
- `institutional`, `survivor`, `record-only` 같은 값은 어떤 축에도 없다. 그 표현이 필요하면 disputed claim의 free-text 근거로만 쓴다.

### 3.3 Axis token ↔ integer mapping

`06`은 integer `-3..3`을 저장하고 아래 canonical mapping을 사용한다. composite claim은 `disputed_claim` record로 별도 보관한다.

| axis | -3 | -2 | -1 | 0 | 1 | 2 | 3 |
|---|---|---|---|---|---|---|---|
| `protocol_legitimacy` | unlicensed_floor | unlicensed | provisional | sanctioned | contested | successor | successor_peak |
| `recognition_drift` | person | patient | operator | artifact | organ-authority | unclassified | unclassified_peak |
| `continuity_pressure` | single_floor | single | linked | branched | loop-bound | crown-debt | crown_debt_peak |
| `resource_scarcity` | buffered | rationed | localized | strained | failing | collapsed | externally-mediated |

mapping 규칙:

- 정수는 ladder 위치다. `0`은 ladder token 수 `n`에 대해 index `floor(n/2)`인 token이다. 즉 A/C는 index 2, B는 index 3, D는 index 3이다.
- canonical token이 7칸보다 적은 축은 남는 칸을 `*_floor`(ladder 아래, 어떤 category도 아직 없음)와 `*_peak`(ladder 위, 복수의 주장이 동시에 성립)로 채운다. A는 5개라 양쪽 칸을 모두 쓴다(`unlicensed_floor`, `successor_peak`). C도 5개라 양쪽 칸을 쓴다(`single_floor`, `crown_debt_peak`). B는 6개라 위 칸만 쓴다(`unclassified_peak`). D는 canonical token이 7개라 확장 칸이 없다.
- ladder는 단조 증가한다. 같은 축에서 더 큰 정수가 더 낮은 권한·인정·연속성·희소성을 뜻하지 않는다. 합산 점수·progress bar·ending score로 변환하지 않는다.
- `06`은 위 token을 직접 저장하지 않고 정수만 저장한다. `03`, `04`, `07`은 위 mapping을 인용한다.
- `07` §7은 이미 `strained`를 포함한 7칸으로 갱신되었다. 6단계 축약 인용은 0건이며 정본은 위 7칸이다.
- 초기 matrix의 composite category는 primary integer 하나와 disputed record로 표현한다.

### 3.4 Magic이 네 축에 쓰는 것

magic은 다섯 번째 축을 만들지 않는다. craft 실행은 아래와 같이 이미 존재하는 축에만 write한다.

| magic 사건 | A legitimacy | B recognition | C continuity | D scarcity | 함께 움직이는 clock |
|---|---|---|---|---|---|
| medium으로 weave/scroll cast 성공 | 변화 없음 | 변화 없음 | 변화 없음 | `medium` 재고 감소 | E |
| rigid-fold cast 성공 | 변화 없음 | 변화 없음 | 변화 없음 | `fold` 재료·시간 감소 | E |
| lineage magic 첫 발현 | `provisional` 유지 또는 `contested` | `operator`가 아닌 `apprentice` category로Filing | `linked` 유지 | 변화 없음 | I, P |
| concentration overflow | `contested`(신뢰 하락) | `person` 유지, instrument면 `artifact` | `branched`(신체 경로 분기) | `failing`(field 농도 붕괴) | K, P, E |
| unregistered craft 압수 | `unlicensed` | `artifact` | 변화 없음 | 변화 없음 | I, R |
| portal contract 체결 | `contested`(존재에게 권한이 생김) | `operator` | `linked`(deferred obligation) | `failing`(circulation 여유 소모) | C, E, R |
| magic cure(우회) | 변화 없음 | `patient` 유지 | `branched` 증가 | `medicine` 재고 감소 | P, K |
| failed fold(§8.9 `RC-08`) | `provisional` 유지 | `artifact`(수단 실패) 또는 `person`(숙련 실패) | `branched` 증가 | `medium` 소실 + `course credit` 소실 | P, R, E |

- 한 magic 사건이 두 축을 건드리면 각 write를 별도 transaction step으로 기록한다(§9.2). `commit_log`에 축 write가 두 줄이 아니라면 그 사건은 위 표를 따른 것이 아니다.
- concentration 값 자체는 축이 아니다. `D`와 `K`에 영향을 주는 **원인**으로 저장되며, §9.1의 `magic.concentration`이 정본이다.
- `R8`은 `A`를 `successor`로 올리지 않는다. 학교가 왕관보다 위가 아니다. precedence는 `G8`의 `Crown Protocol`만 정한다.

## 4. Pressure clocks

시계는 여섯 개이며 서로 다른 단위로 진행한다. 전역 위험 막대, 상시 숫자 HUD, clock 이름 표시를 만들지 않는다. signal은 world event, enemy tell, NPC warning, document shortage, route change로만 드러낸다.

| clock ID | 시작 단계 | world signal | escalation | intervention | irreversible point | aftermath |
|---|---|---|---|---|---|---|
| I `institutional_response_clock` | `noticed` | 같은 사건에 두 office stamp가 붙는다. | category가 좁혀지고 담당자가 배정된다. | 해당 기관의 local protocol이 실행된다. | 공식 dispatch 또는 operator replacement가 기록된다. | route permission과 NPC role이 바뀐다. |
| K `contamination_clock` | `clean` | 접촉·이동·실패한 recovery 뒤 흔적이 남는다. | recovery와 recognition failure이 누적된다. | 격리, 우회, 검사, 치료가 지역별로 수행된다. | contamination이 현재 protocol의 복구 경로를 재정의한다. | body authority와 route safety가 다시 계산된다. |
| R `public_record_clock` | `private` | 같은 사건이 서로 다른 문서로 전파된다. | rumor, form, chat screenshot가 category를 확정한다. | archive·court·crier가 public copy를 만든다. | contradictory record가 하나의 canonical record가 된다. | player knowledge와 무관하게 사회의 대상 분류가 바뀐다. |
| E `resource_collapse_clock` | `buffered` | stock, waterline, battery, care window가 줄는다. | ration, substitution, debt가 일상사가 된다. | region이 seed·parts·attention·medicine을 재분배한다. | 한 cycle의 buffer가 0이 되거나 외부 공급이 끊긴다. | 기존 route가 막히고 우회·external mediation이 열린다. |
| P `personal_collapse_clock` | `role_bound` | NPC가 자기 role을 먼저 말하고 다른 parts를 부른다. | memory, desire, organ voice가 서로 다른 결정을 내린다. | care, bargain, separation, public role change가 선택된다. | NPC가 새 self-authored role을 기록한다. | role을 상실하면 dialogue access, combat target, care outcome이 바뀐다. |
| C `crown_alignment_clock` | `vacant` | Crownwell의 그림자·counterweight·operator stamp가 어긋난다. | institution이 자기 protocol을 crown에 우선순위로 제시한다. | operator를 교체하거나 precedence를 공개한다. | Crown Protocol이 한 protocol을 선택하고 operator를 고정한다. | physical route와 canonical record가 world-wide하게 바뀐다. |

### 4.1 Closed clock stage vocabulary

각 clock은 아래 6개 stage를 순서대로 사용한다. `06`은 stage index를 저장하고, 표시 문자열은 02의 token을 따른다.

| clock | stage 0 | stage 1 | stage 2 | stage 3 | stage 4 | stage 5 |
|---|---|---|---|---|---|---|
| I institutional response | noticed | assigned | contested | intervened | filed | superseded |
| K contamination | clean | exposed | active | systemic | irreversible | collapsed |
| R public record | private | circulating | contested | filing | canonical | retired |
| E resource collapse | buffered | rationed | localized | failing | collapsed | externally_mediated |
| P personal collapse | role_bound | divergent | contested | intervened | self_authored | lost |
| C crown alignment | vacant | contested | aligned | intervened | fixed | locked |

`strained`, `displaced`, `delayed`, `notified`, `role-bound`(하이픈 표기), `externally-mediated`(축 D 표기)처럼 위 표에 없는 token은 사용하지 않는다. `canonical`은 `public_record`의 stage 4이므로 허용된다. irreversible은 해당 clock의 stage 4이며, stage 5는 terminal이다.

- 어떤 region도 clock을 stage 5(terminal)에서 시작하지 않는다. terminal에서 시작하는 region manifest는 authoring 오류다.
- stage 4에 도달한 clock은 해당 region의 irreversible point가 이미 발생한 상태다. `R7`은 `E`와 `R`이 stage 4에서 시작하는 유일한 region이며, 그래서 `R7`의 irreversible point는 그 둘이 아니라 `C`의 고정이다.
- `06`은 stage index(`0..5`)를 저장하고 위 token을 표시 문자열로 쓴다. `03`·`04`·`07`은 같은 token을 쓴다.

### 4.2 Region별 clock manifest

| node | I | K | R | E | P | C | region-specific irreversible point |
|---|---|---|---|---|---|---|---|
| H0 | assigned | clean | private | buffered | role_bound | vacant | 첫 official docket 또는 route debt가Filing되는 순간 |
| R1 | noticed | exposed | circulating | localized | divergent | contested | wrong-return person이 role과 다른 record로Filing되는 순간 |
| R2 | assigned | active | circulating | failing | divergent | contested | clone census가 identities를 한 category로 확정하거나 물 buffer가 0이 되는 순간 |
| R3 | assigned | exposed | private | localized | divergent | contested | consent record 또는 miracle classification이Filing되는 순간 |
| R4 | assigned | clean | filing | rationed | role_bound | contested | partial translation이 canonical local law가 되는 순간 |
| R5 | assigned | exposed | circulating | localized | divergent | contested | boot/employment contract가Filing되는 순간 |
| R6 | assigned | active | private | failing | divergent | contested | organ authority와 cure debt가 하나의 court record가 되는 순간 |
| R7 | assigned | systemic | canonical | collapsed | intervened | contested | Crown Protocol이 precedence와 operator를 고정하는 순간 |
| R8 | assigned | clean | private | localized | divergent | contested | concentration 등록 또는 course index가Filing되는 순간 |

### 4.3 signal의 authored 형태

- H0: 중복된 arrival stamp, crier thread, 닫힌 route slot, registrar의 role change.
- R1: wrong-name door, ash thread, reheated bell, 세 이름이 다른 furnace log.
- R2: waterline, identical footprints, empty seed shelf, public ration arithmetic, circulator가 내뿜는 밤잠.
- R3: 늦게 울린 bell, signature 없는 bed, queue ticket, organ complaint interrupt, 측정표가 두 번 다르게 읽힌 concentration line.
- R4: 서로 다른 번역의 한 문장, 층별 weight counter, copied record, missing floor, 비어 있는 glossary slot.
- R5: incomplete boot log, uniform without name, labor refusal, failed recognition hearing, 재단 직전 재가 접히지 않는 종이.
- R6: body-part complaint, replacement invoice, queue number, court summons issued to an organ, 장기에서 발화된 medium residue.
- R7: wall phase, fruit without a tree, crown shadow displacement, settlement census disappearing, 잘린 공허가 닫히지 않는 자국.
- R8: 등록 concentration 표, 이름 없는 lineage 배정표, 반납된 course credit, 재사용 금지 처리된 fold sheet.

### 4.4 Magic이 clock에 쓰는 것

magic은 일곱째 clock을 만들지 않는다. `concentration_field`, `body load`, `circulation capacity`, `contract debt`는 아래 6개 clock의 입력값이다.

| trigger | write 대상 | 부수 write | 금지 |
|---|---|---|---|
| `concentration_field`가 threshold를 넘김 | 해당 region/path의 `K contamination` +1 stage | `E resource_collapse`는 별도 transaction에서만 전진 | 한 write가 `K`와 `E`를 한 번에 전진시키지 않음 |
| circulator가 축적 농도를 외부 공기로 이동 | `K`는 감소, `E`는 소모 | `R public_record`에 neighbor region의 오염Filing | 감소를 "해결"로 기록하지 않음 |
| 실패한 cast | `K`(medium residue) 또는 `P`(body load) 중 **하나**를 고름 | `R`은 failure document가Filing될 때만 | `K`·`P`·`R` 동시Filing 금지 |
| magic cure | `P personal_collapse` | `C continuity_pressure`는 §3.4 표대로 별도 write | cure가 원상복구로 기록되지 않음 |
| portal contract 체결 | `C crown_alignment`의 interpretation input으로만 사용 | `E`(circulation 소모), `R`(contract 공개) | `C` stage가 contract 하나로 전진하지 않음 |
| unregistered craft 압수 | `I institutional_response` | `R public_record` | 압수가 곧 `A` 강등으로 기록되지 않음 |
| `R8` course index Filing | `I` | `R` | `E`는 학생 인원으로만 반응 |
| `R8` failed fold | `P`(학생 role) | `R`(school record) | 학생 제거 없음 |

- 위 표의 `부수 write`는 항상 별도 transaction step이며 각각 즉시/지연 결과를 따로 기록한다(§9.2).
- concentration은 전역 위험 막대가 아니다. region/path 단위 `concentration_field`이며, HUD·clock 이름·숫자 바로 노출하지 않는다.
- `12_MAGIC_THEORY.md`가 요구하는 "failure는 status/clock/record effect를 atomic하게 쓴다"는 규칙은 위 표의 한 행이 한 transaction이라는 뜻이다. `atomic`은 `K`와 `P`를 동시에 전진시키라는 뜻이 아니다.

## 5. Physical / institutional / resource / epistemic route graph

각 edge는 네 축을 함께 가진다. physical gate를 통과해도 institutional permission, resource cost, epistemic action 중 하나가 빠지면 통과한 것으로 보지 않는다. route는 authored data가 읽는 state 조합이며 core script에 node ID를 하드코딩하지 않는다.

### 5.1 Route topology loops

각 loop는 실제 인접 edge로만 닫힌다. loop 목록의 모든 edge는 §5.2 registry에 존재하고, registry의 모든 edge는 적어도 하나의 loop 또는 spoke에 나타난다.

| loop | cycle | dominant clock | 이 loop가 다시 읽는 write |
|---|---|---|---|
| central spokes | H0—E01—R1, H0—E02—R2, H0—E03—R3, H0—E04—R4, H0—E05—R5 | R `public_record_clock` | H0의 arrival/route category |
| recovery loop | R1—E06—R3—E17—R2—E08—R6—E07—R1 | K `contamination_clock` | recovery lineage와 resource buffer |
| authority loop | R4—E12—R5—E14—R6—E16—R7—E13—R4 | C `crown_alignment_clock` | operator claim과 precedence |
| care/translation loop | R3—E10—R4—E12—R5—E11—R3 | P `personal_collapse_clock` | care record와 local law |
| frontier loop | R2—E09—R7—E15—R5—E11—R3—E17—R2 | D `resource_collapse_clock` | seed/water/crown gear의 cross-region 재분배 |
| craft loop | R3—E11—R5—E18—R8—E18—R5—E12—R4—E10—R3 | I `institutional_response_clock` | curriculum, labor record, concentration 등록 |

- loop는 다른 loop를 통과할 수 없다. recovery loop는 E06/E07/E08/E17만, craft loop는 E10/E11/E12/E18만 쓴다.
- craft loop는 양방향 `E18`을 out-and-back leg로 쓴다. `R8`은 edge가 하나뿐이므로 자기 루프를 위조하지 않고 `R5`와 왕복한다. `R8`의 두 번째 return affordance는 `R8` 내부 route state(§7.9)다.
- 6개 loop의 dominant clock은 여섯 개 clock과 1:1이다. 한 loop가 두 clock을 지배하지 않으며, 부차 clock은 §4.4 표의 `함께 움직이는 clock` 칸에만 존재한다.
- E15(`R5—R7`)는 frontier loop에서 처음 쓰인다. gantry는 R7 방향 supply leg이지 R7→R5 return leg이 아니다.

### 5.2 Route registry

| edge | physical passage | institutional gate | resource gate | epistemic action | initial state |
|---|---|---|---|---|---|
| E01 H0–R1 | Ash Stair | Arrival Registrar가 arrival category를Filing | lamp oil 1 | `person`, `patient`, `operator`, `artifact` 중 선언 또는 보류 | open |
| E02 H0–R2 | Sluice Road | Water Council ration slip | seed case 2 또는 water allotment 1 | salt/water mark로 현재 safe lane 선택 | conditional |
| E03 H0–R3 | Mercy Causeway | Hospice intake seal | care token 1 | recovery goal을 patient/work role과 분리해 말하기 | open |
| E04 H0–R4 | Crownwell Ascent | Archive access request | blank form 2 | 한 문장을 실제로 번역해 제출 | conditional |
| E05 H0–R5 | Foundry Tram | Foundry work permit | power cell 1 또는 labor pledge 1 | boot에서 맡을 role name을 선언 | open |
| E06 R1–R3 | Quiet Ward Passage | Return Registry가 mismatch case를 인계 | ash thread 1 | body가 맞고 role이 틀렸다는 차이를 제시 | locked |
| E07 R1–R6 | Ash Chute | Gristmarket intake ticket | preservative 1 | organ을 독립 patient가 아니라 authority로 분류 | locked |
| E08 R2–R6 | Medicine Ferry | Gristmarket debt ledger | water cask 2 또는 medicine 2 | remedy의 원재료와 counterfeit's 차이 확인 | locked |
| E09 R2–R7 | Orchard Causeway | Boundary Survey permit | seed-vault sample 1 | wall phase의 low-level mark를 읽음 | locked |
| E10 R3–R4 | Bell-Cable Lift | Archive가 care outcome을 Filing | latency token 1 | hospice term을 archive category로 번역 | locked |
| E11 R3–R5 | Care Train | joint support roster | care ration 3 | body name과 labor role name을 분리해 선언 | locked |
| E12 R4–R5 | Courier Shaft | translation contract | sealed plate set 1 | 두 문장의 충돌을 하나의 operative rule로 결정 | locked |
| E13 R4–R7 | Crown Stair | Crown Archive seal | archive weight 3 | literal object와 title/authority claim을 구분 | locked |
| E14 R5–R6 | Under-Rail Shunt | Labor Clinic intake | transformation fuse 2 | post-boot person을 장비가 아니라 human/operator로 기술 | locked |
| E15 R5–R7 | Supply Gantry | Ordnance permit | crown gear 1, battery 2 | operator sequence를 관찰해 재현 | locked |
| E16 R6–R7 | Drainage Dark | Boundary Maintenance court | hand pump 1 | scar/continuity pattern으로 returning body를 구별 | locked |
| E17 R2–R3 | Water Ambulance Bridge | Emergency convoy roster | stretcher 1, water 2 | scarcity가 water인지 attention인지 선언 | locked |
| E18 R5–R8 | Folding School Approach | Glasswing Ordinal course index가 `G5` labor pledge resolution을 확인 | `concentration sample` 1, `craft credit` 1 | 보유 craft를 `person` capability으로 부를지 `artifact` possession으로 부를지 선언 | locked |

`E18`의 institutional gate는 `G5` 하나다. `G9`를 만들지 않는다. `R8` 내부의 curriculum/lineage/concentration 등록은 gate가 아니라 region state이며, 새 gate ID를 필요로 하지 않는다. `E18`의 resource gate는 R5 또는 `RC-08` 이전에 authored act로 얻는 값이어야 하므로, `G5` 미해결 상태에서 `E18`을 여는 것은 불가능하다.

### 5.3 Route state vocabulary

- `locked`: 선행 gate가 Filing되기 전의 기본 상태. `closed`와 달리 되돌릴 수 있는 published pre-state이며, 언제 어떤 gate가 열면 `open`/`conditional`/`debt-bearing`이 되는지가 registry에 정의되어 있다.
- `open`: physical/institutional/resource/epistemic 조건이 모두 충족됨.
- `conditional`: 한 region event나 player action이 edge를 다시 열어 두는 상태.
- `redirected`: 원래 목적지는 유지되지만 다른 protocol, NPC, encounter family를 통과함.
- `closed`: 현재 tick에서는 통과할 수 없음. 대체 edge는 반드시 존재함.
- `debt-bearing`: 통행은 가능하지만 community 또는 NPC에 구체적 빚이 생김.

이 6개가 닫힌 vocabulary다. registry의 `initial state`는 `locked`, `open`, `conditional` 중 하나여야 하며 `redirected`/`closed`/`debt-bearing`은 authored event 이후에만 나타난다.

`closed`는 region을 삭제하지 않는다. edge를 다시 열 수 있는 event family, 우회 edge, NPC가 들고 있는 key consequence를 사전에 지정한다.

### 5.4 첫 방문 resource contract

플레이어의 시작 allotment은 `empty category docket` 1, `route debt token` 1, `lamp oil` 1, `care token` 1, `blank form` 2, `power cell` 1이다. `seed case`, safe water, organ medicine, archive weight, ash thread, §5.5의 magic resource는 시작 allotment이 아니며 해당 region의 authored act로 얻는다.

- E01은 lamp oil을 소비하고, E03은 care token을 소비한다.
- E05는 power cell 하나를 소비한다. `labor pledge`는 물질 resource가 아니라 즉시 H0 route debt를 만드는 signed commitment이다. `scarce_keys`에는 `labor_pledge`를 별도 non-quantified key로 둔다.
- `labor pledge`는 region resident의 labor obligation, wage, and institutional jurisdiction을 바꾼다. 단순 currency 대체가 아니다.
- region을 재방문해도 이미Filing된 route permission과 resource debt는 다시 지급되지 않는다.
- 이 allotment는 combat HP가 아니며, 전투 보상·NPC 호의·resource event만 authored consequence로 추가할 수 있다.

#### 5.4.1 E02 unlock — 인과 순서 고정

`E02`는 `R2`의 gate가 아니다. `R2`에 들어가기 전에 `H0`에서 끝나는 authored act가 유일한 unlock source다.

1. `G0 Arrival Declaration`이 Filing된다(H0-01). 선언을 보류한 경우에는Filing된다고 본다.
2. `H0-04 Ration Counter`에서 water line을 하나Filing한다. 이것이 H0 측 물 배분 record다.
3. 그 결과로 `seed case` 2 또는 `water allotment` 1 중 하나를 받는다. 두 값은 동시에 지급되지 않는다.
4. 위 두 act가 모두 끝나면 `E02`가 `open`으로 바뀐다. 그 전까지 화면에는 `conditional`로 보인다.

- `G2 Water Recognition`은 `R2`에서 수행하는 gate다. `E02`를 여는 근거가 될 수 없다. `G2`의 산출물은 `E08`/`E17`의 resource 배분과 public ration Filing이며, `E02`의 상태를 바꾸지 않는다.
- `R2-01 Water Round`도 `E02`의 unlock source가 아니다. `E02`를 지난 뒤의 authored act이기 때문이다. 따라서 `E02`는 `R2` evidence 없이 열릴 수 있고, 열린 뒤 `R2-01`이 그 record를 나중에 다시 읽는다.
- 인과 역전을 피하기 위해 `G2`의 이름(`Water Recognition`)과 `H0-04`의 filed water line은 서로 다른 record다. 전자는 R2 judgment, 후자는 H0 distribution이다.

#### 5.4.2 E04 unlock — 인과 순서 고정

`E04`도 `R4`의 gate가 아니다. unlock은 `H0`에서 끝난다.

1. `G0 Arrival Declaration`이 Filing된다(H0-01).
2. `H0-04`에서 `Exchange Registrar`에게 `blank form` 두 장을 제출한다. 이때 두 장을 소비한다.
3. 제출이 Filing되면 `E04`가 `open`으로 바뀐다. 그 전까지 화면에는 `conditional`로 보인다.

- form 2장을 Filing하면 잔여 수량이 0이 되므로 재제출이 불가능하다. `E04`는 한 번만 열린다.
- `R4-01 Translation Desk`의 partial translation evidence는 `E04`를 대신 열지 않는다. translation은 `E04`를 지난 뒤의 authored act다.
- `G4 Translation Precedence`의 산출물은 `E12`/`E13`의 route category와 canonical law이며, `E04`의 상태를 바꾸지 않는다.

### 5.5 Magic resource contract

`res_*` ID는 `06`이 등록하고 이 파일이 vocabulary를 소유한다. 아래 값은 전부 field/world resource이며 combat resource(`hp`/`mp`/`equipment_charge`)가 아니다. `mana`라는 이름의 단일 수치 resource를 만들지 않는다.

| key | 정본 이름 | 최초 획득 authored act | 소비 edge | 공급 region | 비수량 여부 |
|---|---|---|---|---|---|
| `concentration_sample` | 한 지점의 농도 측정값 | `R2-09 Disperser Reading` 또는 `R8-02 Concentration Registration` | E18 | R2, R8 | 수량 |
| `medium_blank` | weave/scroll용 종이·직물 blank | `R5-13 Supply Rack`(E15 통과 후) | E18 | R5 | 수량 |
| `fold_sheet` | rigid-fold용 종이 + fold count 예산 | `R5-03 Repair Bench`의 재사용 금지 회수분 | E18 | R5 | 수량 |
| `blade_credit` | void-cut 도구 사용권 | `R7-05 Storm Verge` 또는 `R8-04 Course Selection` | E18 | R7, R8 | 수량 |
| `disperser_charge` | humidifier/disperser 유지 분말 | `R2-09 Disperser Reading` | E18 | R2 | 수량 |
| `circulation_slot` | 누출 농도를 외부 공기로 보낼 여유 | `R2-10 Circulator Ledger` | E18 | R2 | 수량 |
| `craft_credit` | 학교/직장에서 인정하는 craft 시간 | `R5-01 Boot Contract`의 labor hour 전환 | E18 | R5, R8 | 수량 |
| `lineage_token` | 가문/묶음이 보존한 미정형 craft 접근권 | `R8-03 Lineage Placement` | E18 | R8 | 수량 |
| `contract_tally` | 체결한 portal contract의 미해결 obligation 개수 | `R7-05` 또는 `R8-06`의 void-cut | E18 | R7, R8 | **비수량 debt key** |
| `labor_pledge` | §5.4의 signed commitment | `R5-01 Boot Contract` | E05, E18 | R5 | **비수량 debt key** |

규칙:

- `E18`의 resource gate는 `concentration sample` 1과 `craft credit` 1이다. 나머지 값은 `E18` 안에서 선택적으로 소비된다.
- `blade_credit`는 도구의 물리 구조가 cost와 안정성을 결정한다. 같은 이름의 도구라도 fold count와 오차가 다르므로, 획득 시점에 `shape_or_pattern`과 `tool_variant`가 함께 고정된다.
- `contract_tally`는 combat balance가 아니라 obligation ledger다. `E18` 통과를 막는 값이 아니라 `R8-06`과 `R7-05`의 delayed write를 예약하는 값이다.
- `labor_pledge`와 `contract_tally`는 `resource_flow.scarce_keys`에 들어가지만 `amount`를 갖지 않는다. `06`은 `access: debt_bearing`로 저장한다.
- magic resource는 2개 이상의 region에 영향을 줄 때에만 지급한다. 한 region 전용 consumable은 그 region family 안에서만 쓴다.


## 6. Route gates와 backtracking

### 6.1 Gate registry

| gate | 필요한 authored act | primary region | cross-links와 대안 | world write |
|---|---|---|---|---|
| G0 `Arrival Declaration` | H0에서 대상을 한 category로 선언하거나 보류한다. | H0 | E01/E03/E04/E05 중 어느 protocol을 선택하느냐가 A/B를 바꾼다. | arrival docket, initial legitimacy, record status |
| G1 `Ash Debt` | R1에서 wrong-return case를 rescue, preserve, classify, erase 중 하나로 처리한다. | R1 | E06은 R3 care route, E07은 R6 organ route를 연다. | continuity lineage, contamination increment, regional record |
| G2 `Water Recognition` | R2에서 safe water를 직접 확인하고 ration/migrate/share 중 하나를 결정한다. | R2 | `E08`은 medicine route, `E17`은 emergency convoy를 연다. `E02`는 이미 `G0`+`H0-04`에서 열렸으므로 이 gate는 건드리지 않는다(§5.4.1). | resource buffer, public ration, R6 supply price |
| G3 `Latency Receipt` | R3에서 빠른 recovery와 consent 보존 중 목적을 선택한다. | R3 | E10은 archive, E11은 transformation labor route를 연다. | response clock, personal collapse, care record |
| G4 `Translation Precedence` | R4에서 두 번역 중 하나를 제출하고 category error를 직접 만든다. | R4 | E12/E13으로 foundry와 crown stair를 잇는다. `E04`는 이미 `G0`+`H0-04`에서 열렸으므로 이 gate는 건드리지 않는다(§5.4.2). | canonical record, legitimacy, crown interpretation |
| G5 `Labor Pledge` | R5에서 boot contract를 full, staged, refused로 끝낸다. | R5 | E14는 clinic, E15는 gantry, E18은 Folding School approach로 이어진다. 세 edge 모두 `G5`를 읽는다. | operator category, labor record, transformation debt |
| G6 `Organ Quorum` | R6에서 organ authority와 patient가 서로 다른 custody를 허용한다. | R6 | E07/E08/E16을 통해 return, medicine, boundary를 잇는다. | body authority, cure debt, recognition category |
| G7 `Boundary Witness` | R7에서 wall phase를 조사하고 seed-vault sample 또는 crown trace를 운반한다. | R7 | E09/E13/E16 중 하나를 사용한다. | phase map, boundary event, crown alignment input |
| G8 `Crown Precedence` | Crownwell에서 recovery, recognition, authority 중 하나의 protocol을 먼저 실행한다. | R7/H0/R4 | 최종 선택은 region을 지우는 것이 아니라 모든 edge의 route state를 재해석한다. | operator, precedence, world-wide route variant |

`G0`~`G8`이 닫힌 gate vocabulary다. `G9`를 추가하지 않는다. `R8`의 curriculum/lineage/concentration 등록은 gate가 아니라 `RC-08`이 만든 region state이며, 새 gate를 요구하지 않는다.

모든 epistemic gate는 `clue_found` 저장으로 통과시키지 않는다. 플레이어가 이미 알고 있다면 필요한 문장·관찰·물건을 즉시 실행할 수 있다. gate는 world가 그 행정을 어느 protocol로 처리하는지를 정한다.

### 6.2 Backtracking loops

다음 loop는 authored content를 반복 재생하는 것이 아니라 이전 write를 새 조건에서 다시 읽는다.

1. H0 → R1 → R3 → H0: E01의 arrival category가 care goal과 충돌하면 R3에서 return hearing으로 되돌아간다. E06이 열린 뒤에는 R1을 다시 방문하지 않아도 R3 shortcut을 쓸 수 있다.
2. H0 → R2 → R6 → H0: medicine를 운반하면 R6의 cure price와 R2의 water ration이 동시에 바뀐다. 같은 NPC가 두 region에서 서로 다른 resource claim을 한다.
3. H0 → R3 → R4 → H0: latency choice가 archive outcome으로Filing되면 R3의 care queue가 public record로 바뀐다. E10은 return이 아니라 evidence route가 된다.
4. R1 → R6 → R7: organ quorum를 만들면 E16 drainage가 열린다. body recovery를 먼저 했는지에 따라 R7의 returning body encounter가 다른 signature action을 가진다.
5. R4 → R5 → R7: translation contract가 boot contract의 role을 바꾸면 E15 supply gantry가 열리지만, E13 crown stair의 access category도 바뀐다.
6. R2 → R3 → R5: water ambulance가 care train의 ration을 바꾸면, player가 먼저 만든 R5 boot name과 R3 patient name이 충돌한다. 어느 쪽을 버리는지는 world write이며 메뉴 선택이 아니다.
7. R5 → R8 → R4: E18을 통과해 concentration을 등록하면 R4의 glossary slot이 채워지고, 그 문장이 R5의 labor role을 다시 분류한다. 학교에 등록한 값과 학교가 이름을 붙인 값은 다른 record이며, 둘 다 남는다.
8. R2 → R8 → R5: circulator 여유를 써서 R8을 통과하면 R2의 `E resource_collapse_clock`이 한 단계 전진한다. E18의 `concentration sample`은 R2에서 만든 것일 수 있고, 이 차이는 `R8-02`에서 measurement provenance으로 확인된다.

region은 항상 최소 두 개의 return affordance를 가진다. 하나는 H0로 돌아가는 institutional route, 하나는 인접 region 안의 field shortcut 또는 recovery site다. field shortcut도 자동으로 열리지 않으며 gate write가 필요하다.

### 6.3 10분+ authored path

Reference Game의 최소 world path는 이동으로 시간을 채우지 않고 다음 authored cluster 순서로 진행한다.

1. H0 `HC-00`에서 arrival category와 route debt를 결정한다.
2. R1 `RC-01`에서 wrong-return case를 rescue·preserve·classify·erase 중 하나로 commit한다.
3. R3 `RC-03`에서 fast recovery와 consent 보존을 다른 protocol로 실행한다.
4. R2 `RC-02`로 돌아가 water round와 settlement vote를 수행하고 E17 emergency convoy를 연다.
5. R2에서 돌아 H0를 거쳐 R4 `RC-04`에 도달하거나, E17로 R3에 돌아 E10을 타서 contradictory translation 중 하나를 Filing해 E12/E13을 만든다.
6. R5 `RC-05`에서 full·staged·refused boot을 실행해 E15와 operator claim을 만든다.
7. R6 `RC-06`에서 organ authority와 cure debt를 협상해 E16을 연다.
8. R7 `RC-07`에서 wall phase와 crown precedence를 commit한다.

baseline 10분 run은 위 8개 cluster로 끝난다. `R8`은 `07` §14.1의 A1 data-only addition이므로 baseline에는 들어가지 않는다.

9. (A1 이후 선택 경로) R5 `RC-05`의 `G5` resolution이 Filing된 뒤 E18로 R8 `RC-08`에 들어가 concentration 등록·lineage 배치·course selection 중 하나를 commit한다. 8번까지 마친 run에 덧붙이면 10분 안에 끝나므로, Reference Game 길이는 `RC-08`의 conversation/document/commit_log 깊이로 만든다.

각 cluster는 6~12 NPC, 2~3 clocks, 2~4 institutions와 concrete family 4개 이상을 가지며, combat와 noncombat resolution을 모두 포함한다. 이 경로가 10분 안에 끝나면 authored interaction, route decision, record conflict, recovery variant을 추가하되 이동·대기·같은 combat 반복으로 시간을 늘리지 않는다.

## 7. Region dossier

각 dossier의 content family는 독립 authored unit이다. family ID는 dialogue, document, encounter, object, route의 결합을 설명하지만 core system이 family ID를 직접 special-case하지 않는다. residents에 적은 role은 해당 NPC가 소유하는 system port의 이름이다. 모든 cluster participant는 최소 하나의 port를 가지며 dialogue-only NPC를 만들지 않는다.

resident 표기 규칙:

- 각 dossier의 `residents` 목록은 전부 **support resident**다. canonical core roster 수에 포함하지 않고 `npc_01`~`npc_14` ID를 부여하지 않는다.
- canonical core NPC 14명은 region resident가 아니라 visitor/actor로 등장한다. 소속 node, system port, ID는 `04` §2.1 표가 정본이며, 각 dossier의 `core NPC visitors` 줄이 그 표를 인용한다.
- support resident 이름이 core NPC의 이름·surname과 우연히 겹쳐도 같은 사람으로 병합하지 않는다(`04` §2.3 결정 규칙).

### 7.0 Region contract index

`dominant protocol` 칸의 값은 §1의 `region_role` token과 동일한 문자열이다. `06` RegionDefinition의 `region_role` field는 여기서 옮긴 것이며 새 이름을 만들지 않는다.

| node | entry / exit | `region_role` | hidden state | current state | combat / noncombat | initial cluster | cross-region links |
|---|---|---|---|---|---|---|---|
| H0 | E01–E05 / return desk | `hub_registration_ration_appeal` | Crown Well의 빈 공간은 마지막 operator의 unfiled route claim을 보관한다. | operator seat vacant, five route cards, one debt token | Paper Wardens / arrival hearing, paperwork, sponsor | HC-00 | R1–R7 |
| R1 | E01, E06, E07 / R1-08 | `recovery_reentry` | door log는 Nera의 role을 이전 operator branch에서 가져왔다고 기록한다. | wrong-return case open, registry quarantine active | Ash Choir, Door Role Test / Registry Interrogation, witness rescue | RC-01 | H0, R3, R4, R6 |
| R2 | E02, E08, E09, E17 / seed vault exit | `resource_allocation` | Ione의 추가 seed는 census에서 빠진 네 번째 household를 먹이고 있다. | water buffer critical, three settlements rationing, one circulator running past safe capacity | Twin Shoal, Harvest Failure / Water Round, Seed Vault Exchange | RC-02 | H0, R6, R7, R8 |
| R3 | E03, E06, E10, E11, E17 / Mercy Engine | `intervention_scheduling` | Mercy Engine의 fast-stage latency record는 한 번 삭제된 시험값이다. | care queue active, Faith Engineering unit waiting | Mercy Engine Test / Intake Triage, Vow Ledger, Care Shift | RC-03 | R1, R4, R5, R8 |
| R4 | E04, E10, E12, E13 / Crown Observatory | `translation_precedence` | Low-Level Stacks의 원문은 번역되지 않은 채 한 문장만 반복한다. | two incompatible translations have equal filing weight, magic glossary slot empty | Archive Guardian / Translation Desk, Public Hall Copy, Operator Trial | RC-04 | H0, R3, R5, R7, R8 |
| R5 | E05, E11, E12, E14, E15, E18 / Gantry Cradle | `permission_before_transformation` | Recognitionless boot recipient has a valid labor record but no legal body name. | Labor Court reviewing one incomplete boot, one craft rack open to the school | Formation Failure / Boot Contract, Name Hearing, Care Shift | RC-05 | R3, R4, R6, R7, R8 |
| R6 | E07, E08, E14, E16 / Discharge Route | `organ_authority_negotiation` | Hearth의 petition은 patient가 아니라 clinic policy가 먼저 sign한 draft다. | debt court and organ authority disagree | Organ Chorus Trial / Debt Surgery, Heart Petition, Body Authority Registry | RC-06 | R1, R4, R7 |
| R7 | E09, E13, E15, E16 / Storm Verge | `boundary_crown_precedence` | wall은 crown을 지키는 장치가 아니라 category를 관찰하는 장치이며 Surveyor report도 수정되었다. | phase unstable, one operator claim open, one unfinished void cut at the verge | Storm Verge / Wall Phase Survey, Settlement Vote, Operator Replacement | RC-07 | H0, R1, R2, R3, R4, R5, R6, R8 |
| R8 | E18 / course index return | `magic_training_craft_labor` | 학교는 lineage에 배정되지 않은 craft를 `apprentice`가 아니라 `unassigned stock`으로 세고 있다. | one course index open, concentration registration pending, one student record already failed | The Fold That Refuses the Hand / Concentration Registration, Lineage Placement, Course Selection | RC-08 | R5, R4, R7, R2 |

`H0`에는 `R8`으로 향하는 route가 없다. `R8`의 H0 표면은 `SERVICE_R8_COURSE_INDEX` 한 건의 service index 문서일 뿐이며, route permission을 만들지 않는다.

### 7.1 H0 — The Undersign Exchange

- causal thesis: 모든 region write는 허브에서 권한, 빚, public category로 변환된다. H0는 중립적인 안전지대가 아니다.
- physical topology: 건조한 중앙 선반 위 원형 `Arrival Well`, 네 방향의 계단·tram·수로, 중앙의 `Counterweight Map`, 지하 return lift, 항상 비어 있는 `Crown Well` 위쪽 그림자.
- authority: Exchange Registrar가 arrival, ration, appeal을 관장한다. Crown 자체는 여기에 없다. Registrar는 competent하지만 category를 physical fact보다 우선한다.
- resource flow: region에서 들어오는 blank form, water, replacement part, care labor, attention을 H0가 route permission으로 바꾼다. 내보내는 것은 credential, record copy, ration right다.
- residents(support): Tarin Vey(registrar), Orrin Slate(route cartographer), Pell Harrow(returned courier), Mara Quill(resource broker), Cato Nen(contract notary), Sable Reed(public crier), Iven Moss(hospice liaison).
- core NPC visitors: `npc_02_orrin_kest`, `npc_03_veya_morcant`, `npc_10_juno_caster`, `npc_11_cael_ren`, `npc_01_ilyra_senn`, `npc_14_eda_marrow`, `npc_08_meral_dune`.
- initial axes: A `provisional`, B `person`(disputed `artifact`), C `linked`, D `rationed`.
- initial clocks: I `assigned`, K `clean`, R `private`, E `buffered`, P `role_bound`, C `vacant`.
- unresolved debt: Crown Well을 덮은 구조물이 무엇을 기록했는지, 빈 return docket의 원 소유자가 누구인지 아직Filing되지 않았다.
- one-off dialogue seeds: Tarin은 빈 Crown Well을 "왕관의 부재"가 아니라 "위치를 확인하지 않은 상태"로 부른다; Sable은 "category는 오늘의 문서보다 먼저 사람 이름을 바꾸게 된다"고 말한다; Iven은 care window가 기다리는 사람의 몫이라고 단언한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| H0-01 | Arrival Docket: NPC가 `person`, `patient`, `worker`, `artifact` stamp 중 하나를 직접 찍는다. | A/B와 G0을 쓴다. | 첫 선언과 category error의 결과를 만든다. |
| H0-02 | Counterweight Map: 방마다 다른 route card와 physical lift counter를 실물로 맞춘다. | route state를 읽어 현재 edge를 보여 준다. | 지도 우선 탐색과 우회를 제공한다. |
| H0-03 | Return Hearing: body, role, record가 다른 복귀자를 세 기관 앞에서 분리한다. | C/R/P를 갱신한다. | legal/social continuity 선택을 만든다. |
| H0-04 | Ration Counter: water, parts, care labor, attention을 서로 교환한다. | D와 region buffer를 갱신한다. | route 비용과 공급 conflict를 만든다. |
| H0-05 | Crier Thread: 스크린샷, rumor, forwarded message가 public record seed가 된다. | R을 전진시킨다. | 정보의 speed와 오류를 만든다. |
| H0-06 | Care Notice: NPC가 sponsor, kin, chosen family, romance 후보를 각각 별도 record로 제시한다. | relationship와 P를 갱신한다. | non-explicit affection과 delayed care outcome을 만든다. |
| H0-07 | Paper Wardens: stamp와 queue가 공격적으로 operationalize되는 combat encounter. | I/R/E를 즉시 갱신한다. | 전투와 noncombat paperwork 우회를 모두 제공한다. |
| H0-08 | Route Debt: 한 region의 medicine·parts·attention을 다음 route에 배정한다. | D와 edge state를 cross-region write한다. | 하나의 hub 선택이 distant content를 바꾼다. |

Revisit variants:

- 첫 regional commit 후에는 Counterweight Map에 contested edge와 unpaid debt가 새 slot으로 생긴다.
- R4 canonical record가Filing되면 Crier Thread가 rumor을 복사하지 않고 official wording으로 재생성된다.
- R7 crown alignment 후에는 H0의 route card가 삭제되지 않고 `precedence`가 바뀐 문장으로 다시 인쇄된다.
- Care Notice relationship가 resolved/rejected가 되면 route permission은 유지되고 NPC availability와 delayed event만 바뀐다.
- `R8` course index가Filing되면 `SERVICE_R8_COURSE_INDEX` 한 줄이 추가된다. 이것은 service index row이며 새 route card가 아니다. 다른 다섯 route card는 그대로 남는다.

### 7.2 R1 — The Returning Kiln

- causal thesis: recovery는 원래 failure를 지우는 bypass다. 매번 보존되는 function을 고르면 player identity, NPC role, route authority가 달라진다.
- physical topology: `Intake Stack`, `Wrong Return`, `Ash Garden`, `Cold Relay`, `Deep Door`가 서로 다른 층의 loop로 연결된 furnace complex. 정상 stair과 ash chute가 같은 chamber를 다른 protocol로 읽는다.
- authority: Return Registry와 Kiln Wardens. Registry는 이름·role·employment를 각각 관리한다.
- resource flow: ash thread, heat, memory anchor, replacement latch가 들어오고 safe passage와 recovery evidence가 나간다.
- residents(support): Anja Sol(warden), Odo Nune(door clerk), Nera Fold(re-entry claimant), Bel Karr(ash-choir conductor), Tovan Rill(loop scheduler), Lissa Mern(witness), Rusk Vey(furnace engineer).
- core NPC visitors: `npc_02_orrin_kest`, `npc_11_cael_ren`, `npc_13_tovan_reed`, `npc_03_veya_morcant`, `npc_05_nera_voss`, `npc_01_ilyra_senn`, `npc_06_tamas_quill`.
- initial axes: A `provisional`, B `patient`(disputed `artifact`), C `branched`, D `strained`.
- initial clocks: I `noticed`, K `exposed`, R `circulating`, E `localized`, P `divergent`, C `contested`.
- unresolved debt: Nera의 original name과 직무 이력이 어느 branch에서Filing되었는지 확인되지 않는다.
- one-off dialogue seeds: Odo는 "문은 사람을 기억하지 않는다. 마지막 role만 기억한다"라고 말한다; Bel은 세 번째 bell을 돌아온 사람이 아니라 돌아오지 않은 사람의 수로 설명한다; Nera는 "나는 여기 있지만 내 employment는 다음 cycle에 Filing됐다"고 말한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| R1-01 | Misreturned Person: Nera는 같은 body와 다른 employment record를 가지고 돌아온다. | C/B/R을 쓴다. | recovery가 무엇을 보존하는지 만든다. |
| R1-02 | Door Role Test: 문이 body, role, record 중 하나를 요구하고 다른 하나를 enemy로 전환한다. | A/C와 encounter state를 쓴다. | combat/noncombat counter를 분리한다. |
| R1-03 | Ash Thread Relay: heat budget을 분배해 세 chamber의 문을 동시에 안정시킨다. | D와 E route state를 쓴다. | physical resource puzzle를 만든다. |
| R1-04 | Continuation Trial: checkpoint, re-entry, loop rehearsal 중 recovery type을 고른다. | C와 recovery lineage를 쓴다. | death/recovery 선택을 만든다. |
| R1-05 | Three Bodies One Name: 세 claimant의 서로 다른 기억을 하나의 name registry에 제출한다. | B/R/P를 쓴다. | social continuity conflict를 만든다. |
| R1-06 | Registry Interrogation: Anja와 Odo가 evidence보다 job category를 먼저 요구한다. | I/A와 NPC role을 쓴다. | institution의 category error를 만든다. |
| R1-07 | Ash Choir: `Ash Hound`, `Empty Clerk`, `Bell Choir`가 body, role, name signature를 각각 공격한다. | encounter result와 K를 쓴다. | readable conflict와 delayed aftermath를 만든다. |
| R1-08 | Warm Door Exit: ash thread로 만든 우회문이 return evidence를 보존한다. | E06/E07 route state를 쓴다. | backtracking shortcut을 만든다. |

Revisit variants:

- R1-01을 rescue하면 `Warm Door Exit`가 열리고 NPC들은 player를 recovery operator가 아니라 witness로 부른다.
- R6 organ treaty가Filing되면 `Wrong Return` chamber가 clinic annex로 바뀐다. organ voice가 먼저 문을 연다.
- R7 alignment가 `crown-debt`로 넘어가면 Deep Door가 닫히는 대신 외벽으로 redirect된다. chamber content는 삭제되지 않는다.
- checkpoint 뒤에는 미commit encounter만 reset된다. 이미Filing된 wrong-return record와 C debt는 남는다.

### 7.3 R2 — Siltglass Commons

- causal thesis: clone deployment와 plant/water extraction은 aggregate consumption으로 settlement 전체를 바꾼다. 지도 표시는 자원이 안정된 뒤에만 신뢰할 수 있다.
- physical topology: `Glasswater` 중심의 세 stilt settlement, seed vault, shallow ferry, flood channel, root bridge가 물높이에 따라 연결·재연결된다.
- authority: Water Council, settlement delegates, Seed Vault keeper가 서로 다른 resource claim을 가진다.
- resource flow: clean water, seed stock, calories, care attention을 사용하고 medicine와 safe water를 내보낸다. magic era에는 `humidifier`/`disperser`가 농도를 안전 범위에 붙들고, `circulator`가 축적분을 외부 공기로 옮긴다. 마지막은 pollution과 `E`/`K` 비용을 만든다.
- residents(support): Fen Ors(water delegate), Tala Reed(hydrologist), Mero Kett(clone census keeper), Ione Silt(seed keeper), Brack Halm(ferryman), Sava Lunt(medic), Nell Vos(public recorder).
- core NPC visitors: `npc_08_meral_dune`, `npc_14_eda_marrow`, `npc_11_cael_ren`, `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_09_perrin_lask`, `npc_10_juno_caster`.
- initial axes: A `sanctioned`, B `person`(disputed `worker`), C `branched`, D `failing`.
- initial clocks: I `assigned`, K `active`, R `circulating`, E `failing`, P `divergent`, C `contested`.
- magic layer: `R2`는 `E4` era의 concentration infrastructure를 소유한다. `R2-09 Disperser Reading`이 `concentration sample`과 `disperser charge`를 만들고, `R2-10 Circulator Ledger`가 `circulation slot`을 만든다. circulator는 농도를 낮추는 대신 이웃 정착지의 `K`와 `E`를 올린다. 이 region의 `concentration_field`가 threshold를 넘으면 `E02`의 safe lane 판정이 바뀐다(§3.4, §4.4).
- unresolved debt: clone census에서 같은 name을 세 번 세는 것이 mistake인지 citizenship인지 Filing되지 않았다.
- one-off dialogue seeds: Tala는 "safe water는 맛이 아니라 다른 body의 hunger를 계산한 결과"라고 말한다; Mero는 "같은 name을 가진 둘은 census에서 한 줄이 된다"고 확인한다; Sava는 medicine를 나누려면 먼저 누가 patient인지 정해야 한다고 말한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| R2-01 | Water Round: 세 settlement이 한 measuring cup과 한 ration slip을 공유한다. | D/E와 E02를 쓴다. | physical route와 resource conflict를 만든다. |
| R2-02 | Clone Meal Plan: clone household가 calories와 water를 계산해 household role을 정한다. | B/C/D를 쓴다. | social recognition과 survival math를 연결한다. |
| R2-03 | Root Bridge Survey: 물 아래 phase와 seed root growth를 함께 조사한다. | E09와 epistemic route를 쓴다. | hidden topology를 공개한다. |
| R2-04 | Same Body Census: Mero가 외형, memory, legal name, preference를 각각 기록한다. | B/C/R을 쓴다. | identity evidence를 만든다. |
| R2-05 | Harvest Failure: identical bodies가 bloom을 먼저 먹고 `Twin Shoal`을 만든다. | K/D와 encounter result를 쓴다. | resource pressure를 combat으로 만든다. |
| R2-06 | Flood Refuge: root bridge가 잠길 때 고지대 storage로 물을 옮긴다. | E17와 physical variant를 쓴다. | emergency return을 만든다. |
| R2-07 | Seed Vault Exchange: seed sample을 medicine, access, future harvest 중 하나로 교환한다. | D/A와 delayed E를 쓴다. | 단기 survival과 장기 route를 경쟁시킨다. |
| R2-08 | Settlement Vote: ration, migrate, share 중 하나를 공개 투표한다. | P/R/D와 H0 ration을 쓴다. | region-wide branch를 만든다. |
| R2-09 | Disperser Reading: 분말을 보충하고 한 지점의 농도를 실제로 측정해 기록한다. | `concentration sample`/`disperser charge`를 만들고 `K`를 쓴다. | E18의 resource gate와 `R8-02`의 measurement provenance을 공급한다. |
| R2-10 | Circulator Ledger: 누출 농도를 외부 공기로 보낼지, 이웃 정착지에 남길지 배정한다. | `circulation slot`과 `E`를 쓴다. | `E18` 통과와 이웃 region의 오염Filing을 함께 만든다. |

Revisit variants:

- `Flood Refuge`가Filing되면 E02가 `redirected`가 되고, E17은 emergency convoy로 남는다.
- seed sample을 R6에 전달하면 R2의 medicine lane이 열리지만 다음 harvest의 buffer가 줄어든다.
- `Twin Shoal` encounter의 승리 방식이 raw survival이면 census가 person으로, resource lock이면 artifact로 rewrite된다.
- R7 causeway가 열리면 settlement delegate가 outbound route를 만들지만, 남은 인원과 water allocation은 다시 계산된다.

### 7.4 R3 — Bellhouse Hospice

- causal thesis: faith는 magic power가 아니라 intervention latency를 줄이는 operational parameter다. 빠른 도움이 consent·recognition·personal continuity를 대신 보장하지 않는다.
- physical topology: `Intake Gallery`, `Bell Tower`, `Boiler Undercroft`, `Mercy Engine`, recovery ward가 층별로 연결된다.
- authority: Hospice Covenant, Faith Engineering unit, Care Union이 각각 intake, latency, labor를 관리한다.
- resource flow: care labor, latency window, attention, memory archive를 사용하고 recovery result와 care record를 내보낸다. magic era에는 `mana_profile`(retention/emission/overflow/blocked 4종을 최소로)을 triage 입력으로 받고, emission failure을 symptom 대신 category로 기록한다.
- residents(support): Marda Venn(hospice master), Sera Kwon(intake physician), Lio Tace(faith engineer), Orren Vey(bell keeper), Junip Roe(transformed support worker), Eda Mor(memory archivist), Cal Sarn(patient advocate), Vell Orto(bereavement clerk).
- core NPC visitors: `npc_04_sable_halm`, `npc_09_perrin_lask`, `npc_03_veya_morcant`, `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_08_meral_dune`, `npc_01_ilyra_senn`, `npc_10_juno_caster`.
- initial axes: A `contested`, B `patient`(disputed `worker`), C `linked`, D `strained`.
- initial clocks: I `assigned`, K `exposed`, R `private`, E `localized`, P `divergent`, C `contested`.
- magic layer: hospice는 `mana_profile`을 moral judgement가 아니라 body compatibility class로 기록한다. 발출만 되고 저장은 되지 않는 체질은 care window가 아니라 emission capacity 문제로 분류되고, 과잉 축적 체질은 `K`가 아니라 `P`(personal collapse)에 먼저 나타난다. magic cure는 body function을 되돌리지 않고 우회하며, 그 우회가 `C`에 `branched`로 남는다.
- unresolved debt: Mercy Engine이 miracle을 만든 것인지 delay를 줄인 것인지 공식 category가 없다.
- one-off dialogue seeds: Lio는 "faith는 bell을 멈추지 않는다. bell이 늦게 도착하게 만든다"고 말한다; Junip은 "transformation log는 성공이고 recognition form은 공백"이라고 지적한다; Vell은 "grief도 queue number를 받는다"고 답한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| R3-01 | Intake Triage: 환자의 body, name, work role을 각각 다른 stamp로 받는다. | B/A와 G0 alternative를 쓴다. | recovery 목표를 구체화한다. |
| R3-02 | Latency Bell: 세 recovery window를 bell phase로 조율한다. | I/E와 encounter timing을 쓴다. | resource scheduling을 만든다. |
| R3-03 | Vow Ledger: player와 NPC가 care, kin, romance, refusal을 서로 다른 contract로 남긴다. | P/relationship/R을 쓴다. | delayed affection outcome을 만든다. |
| R3-04 | Delayed Ambulance: support crew가 wrong category를 고치기 전까지 실제 운반이 늦어진다. | I/D와 E03/E10을 쓴다. | physical delay을 선택으로 만든다. |
| R3-05 | Mercy Engine Test: faster stage와 stable stage의 trade-off를 encounter로 검증한다. | C/D와 boot residue를 쓴다. | combat/noncombat recovery를 만든다. |
| R3-06 | Organ Complaint Hearing: heart, scar tissue, memory organ이 각자 priority를 제출한다. | P/B와 R6 quote를 쓴다. | body horror를 정치 절차로 만든다. |
| R3-07 | Care Strike: care labor가 멈추면 latency window와 route supply가 함께 변한다. | I/D/P를 쓴다. | institution pressure를 만든다. |
| R3-08 | Memory Copy Consent: Nera/다른 claimant의 memory branch를 보존할지 말지 선택한다. | C/R/K를 쓴다. | recovery type을 만든다. |

Revisit variants:

- `Memory Copy Consent`를 보존하면 Mercy Engine은 안전한 우회로가 되지만 intervention delay가 늘어난다.
- fast stage를 선택하면 R5 boot capacity는 올라가지만 social recognition hearing이 어려워진다.
- Care Strike 이후에는 route가 닫히는 대신 volunteer staff가 부족한 다른 protocol로 운영된다.
- R4가 care outcome을Filing하면 R3 patient record가 public category가 되고, Cal과 Vell의 relationship state가 갈라진다.

### 7.5 R4 — Crownwell Archive

- causal thesis: translation은 meaning을 전달하는 문서가 아니라, category를 고정해 새 local law를 생산하는 institution이다. 틀린 번역도 Filing되면 사회에는 진실이 된다.
- physical topology: `Public Record Hall`, `Translation Well`, `Weight Lift`, `Low-Level Stacks`, `Crown Observatory`가 수직으로 쌓인다. 층 사이 이동은 counterweight와 record access가 함께 필요하다.
- authority: Translation Tribunal이 phrase precedence, Record Office가 canonical copy, Censor가 contradictory copy를 관리한다.
- resource flow: blank form, archive weight, attention, seal capacity를 사용하고 permission과 public record를 내보낸다. magic era에는 비어 있는 `glossary` slot을 소유한다. `glossary`는 positive theory label을 담는 authored record이며, 비어 있는 동안 magic craft의 이름은 `untranslated term`로 Filing된다.
- residents(support): Neme Oris(translation chief), Sef Anor(public record clerk), Ovel Tarn(elevator operator), Yuen Pall(examiner), Tallo Vey(witness), Iri Sane(censor), Moro Kest(low-level translator).
- core NPC visitors: `npc_01_ilyra_senn`, `npc_06_tamas_quill`, `npc_10_juno_caster`, `npc_03_veya_morcant`, `npc_04_sable_halm`, `npc_11_cael_ren`, `npc_12_ravenna_holt`.
- initial axes: A `sanctioned`, B `artifact`(disputed `record`), C `linked`, D `rationed`.
- initial clocks: I `assigned`, K `clean`, R `filing`, E `rationed`, P `role_bound`, C `contested`.
- magic layer: `R4`가 `glossary` slot을 소유한다는 사실이 `R8`의 course index와 충돌한다. 학교가 이름을 붙인 magic term을 archive가 번역하면 두 record가 생기고, 어느 쪽이 `canonical`이 되는가는 `G4`의 precedence 선택에 달려 있다. 이론 이름을 먼저 정하지 않는다.
- unresolved debt: 이전 operator의 memory는 archive에 있으나 operator의 self는 Crownwell에 없다는 기록이 서로 충돌한다.
- one-off dialogue seeds: Neme은 "두 번역 중 하나는 틀렸지만 오늘은 둘 다 문을 연다"고 말한다; Ovel은 "archive weight는 사실의 무게가 아니라 access priority다"라고 답한다; Tallo는 "copy가 먼저 도착하면 original은 뒤따라간다"고 기록한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| R4-01 | Translation Desk: 같은 사건을 `person`, `patient`, `artifact` 세 문장으로 번역한다. | B/R/A를 쓴다. | epistemic action을 만든다. |
| R4-02 | Contradictory Record: 두 문장이 서로 다른 route gate를 동시에 활성화한다. | R/C와 edge state를 쓴다. | branch conflict를 만든다. |
| R4-03 | Public Hall Copy: 방문자가 record 한 줄을 외운다. | R과 NPC knowledge boundary를 쓴다. | rumor propagation을 만든다. |
| R4-04 | Weight Lift: 세 archive weight를 올려 문을 열거나 public floor를 닫는다. | D/E04/E13을 쓴다. | physical/institutional trade-off를 만든다. |
| R4-05 | Archive Guardian: `Index Wraith`, `Redaction Knight`, `Weight Bearer`가 record access를 방어한다. | encounter result와 A/I를 쓴다. | combat으로 category를 강제하지 않는다. |
| R4-06 | Crown Fragment: 왕관의 한 조각 그림자를 기록한다. | C input과 G8을 쓴다. | literal object evidence를 만든다. |
| R4-07 | Operator Trial: player가 archive clerk인지 witness인지 operator인지 선언한다. | A/C와 role access를 쓴다. | institutional ambiguity를 만든다. |
| R4-08 | Archive Fire: paper, heat, copy priority가 충돌해 canonical record 하나가 사라진다. | R/E와 delayed public rumor을 쓴다. | knowledge loss를 만든다. |

Revisit variants:

- `Contradictory Record`가Filing되면 같은 NPC가 서로 다른 gate를 설명한다. 어느 쪽도 자동 삭제되지 않는다.
- Archive Fire 이후에는 빈 층이 아니라 `reconstruction queue`가 나타난다. queue는 R을 전진시키지만 D를 소모한다.
- R3 care outcome과 R5 boot record가 들어오면 archive의 public language가 바뀐다.
- G8 이후에는 archive가 Crownwell의 새 precedence를 읽지만, 기존 record는 contradiction flag를 유지한다.
- `R8`의 등록된 magic term이 들어오면 `glossary` slot이 채워지지만, 학교가 붙인 이름과 archive의 번역이 다르면 두 줄 모두 남고 `R4-02`와 같은 conflict 상태가 된다.

### 7.6 R5 — Glasswing Ordinal

- causal thesis: magical transformation은 labor contract, temporary execution space, recognition hearing으로 이루어진다. boot는 외형 skin이 아니라 capability와 social status를 동시에 만든다.
- physical topology: `Foundry Lane`, `Boot Hall`, `Repair Bench`, `Support Clinic`, `Labor Yard`, `Supply Gantry`가 하나의 industrial loop를 이룬다. `Gantry Cradle` 뒤쪽 `Supply Rack`이 학교에 내보낼 medium/fold sheet/blade를 보관한다.
- authority: Glasswing Ordinal이 boot를, Labor Court가 계약을, Support Registry가 social name과 care sponsor를 관리한다. magic era에는 Ordinal이 `E4` craft의 산업판 허가를, 학교가 curriculum을 소유한다. 둘은 같은 craft를 서로 다른 category로 세는 별개 authority다.
- resource flow: power cell, temporary execution space, labor hour, fuse, care attention을 사용하고 protection, recognition certificate, gantry access를 만든다. magic era에는 `medium blank`, `fold sheet`, `blade credit`, `craft credit`를 만들고, `labor hour`을 `craft credit`으로 전환한 뒤 학교에 보낸다.
- residents(support): Kade Orun(foundry foreman), Neri Voss(support agent), Yara Pell(transferee), Ondra Slate(mechanic), Bex Tarrow(labor delegate), Nim Hesk(registry clerk), Rhea Doss(care partner), Ivo Fenn(boot examiner).
- core NPC visitors: `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_05_nera_voss`, `npc_09_perrin_lask`, `npc_13_tovan_reed`, `npc_01_ilyra_senn`, `npc_10_juno_caster`.
- initial axes: A `contested`, B `operator`(disputed `worker`), C `linked`, D `strained`.
- initial clocks: I `assigned`, K `exposed`, R `circulating`, E `localized`, P `divergent`, C `contested`.
- magic layer: `R5`는 combat 안에서 craft가 일어나는 유일한 region이다. `R5-10 Field Weave`(전투 중 직조를 선택), `R5-11 Rigid Fold`(fold count를 소모하는 committed action), `R5-12 Void Cut`(공허를 자르는 no-turn recovery prep)가 세 craft family를 이 region에서 실행하고, `R5-13 Supply Rack`가 학교로 넘길 물질을 만든다. magic failure는 즉사가 아니라 medium residue, body load, public record로 나타난다. 이름 없는 magic은 "이 magic를 쓸 줄 안다"가 실전 숙련이며, innate title이 아니다.
- unresolved debt: boot 실패가 contract breach인지 operator 선택인지 registry가 아직 category를 정하지 않았다. `E18`을 학교에 열린 registry와 foundry가 서로 다른 craft permit을 쓰고 있다는 사실도 아직Filing되지 않았다.
- one-off dialogue seeds: Kade는 "boot는 완료되지 않았다. contract만 완료됐다"고 말한다; Neri는 "transformation success와 social recognition은 다른 signature를 요구한다"고 설명한다; Bex는 "refusal는 labor record의 결손이 아니라 선택이다"라고 답한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| R5-01 | Boot Contract: full, staged, refused boot의 capability와 빚을 기재한다. | A/D와 G5를 쓴다. | 계약 선택을 만든다. |
| R5-02 | Boot Sequence: four stage의 load, allocate, protect, recognize를 실제로 수행한다. | C/D와 combat ability를 쓴다. | transformation encounter를 만든다. |
| R5-03 | Repair Bench: fuse, battery, uniform, body part를 각각 점검한다. | D/R5 state를 쓴다. | maintenance resource를 만든다. |
| R5-04 | Name Hearing: body name, worker name, operator title 중 무엇을 외부에 부를지 정한다. | B/R/P를 쓴다. | social recognition을 만든다. |
| R5-05 | Care Shift: Neri와 Rhea가 boot recipient의 consent를 번갈아 확인한다. | relationship/P를 쓴다. | affection과 institutional duty를 결합한다. |
| R5-06 | Formation Failure: `Bootlag`, `Unlicensed Spark`, `Recognitionless`가 incomplete stage를 공격한다. | encounter result와 K를 쓴다. | signature enemy/counter를 만든다. |
| R5-07 | Labor Walkout: repair와 boot가 동시에 멈추면 care와 combat capacity가 나뉜다. | I/E/P를 쓴다. | labor clock을 만든다. |
| R5-08 | Partner Permission: 보호 capability를 받을 때 상대가 직접 consent를 남긴다. | relationship/C/R을 쓴다. | explicit content 없이 intimacy를 system choice로 만든다. |
| R5-09 | Gantry Cradle: crown gear와 battery를 transport actor에게 맡긴다. | E15와 R7 input을 쓴다. | final route를 만든다. |
| R5-10 | Field Weave: 허리춤의 textile 조각으로 scroll을 빠르게 직조하거나 prepared scroll을 선택한다. | `medium blank`과 `equipment_charge`를 소모하고 `D`/`E`를 쓴다. | 전투 중 craft와 pre-cast 준비를 같은 action schema로 실행한다. |
| R5-11 | Rigid Fold: fold count를 하나씩 소모해 입체 구조를 만든다. | `fold sheet`을 소모하고 성공 시 더 어려운 shape를 연다. | 3D craft의 complexity/cost 우위를 만든다. |
| R5-12 | Void Cut: 가위로 공허를 잘라 다른 층/차원을 연다. | `blade credit`과 `contract tally`을 쓴다. | shape가 destination과 risk를 결정하는 authored contract를 만든다. |
| R5-13 | Supply Rack: 학교로 넘길 `medium blank`, `fold sheet`, blade를 Ordinal 판정과 labor hour으로 묶어 내보낸다. | `E18`의 resource를 만들고 `A`를 쓴다. | `E18` 통과 비용과 학교의 입학 category를 만든다. |

Revisit variants:

- full boot이면 R5 name이 public record가 되지만 E15에는 additional battery가 필요하다.
- staged boot이면 E15 shortcut은 열리고 combat capacity는 낮지만 R3/R6 recovery option이 늘어난다.
- Partner Permission을 거부한 NPC는 care shift를 떠나지 않고 별도의 refusal protocol을 실행한다.
- Labor Walkout 이후에도 foundry lane은 열려 있다. 들어가는 방식과 NPC faction만 바뀐다.
- boot refusal는 `E18`을 막는다. `G5`가 `refused`로 Filing된 경우 `R8` 진입은 `open`이 되지 않고, `R5` 안의 craft는 Ordinal의 산업판으로만 실행된다. 이 asymmetry가 R5의 rule이다.

### 7.7 R6 — Gristmarket Ward

- causal thesis: medicine, replacement part, credit, attention이 서로 다른 organ authority로 변한다. cure는 원상복원이 아니라 통증과 social role을 어디로 옮길지에 대한 협상이다.
- physical topology: `Gristmarket Ring`, `Organ Intake`, `Cure Queue`, `Debt Hall`, `Replacement Stalls`, `Drainage Dark`가 층과 수로로 연결된다.
- authority: Gristmarket Clinic이 치료를, Debt Court가 빚을, Organ Exchange가 component custody를 관리한다.
- resource flow: medicine, replacement parts, credit, care attention을 사용하고 temporary function, debt instrument, organ testimony를 내보낸다. magic era에는 medium이 장기 protocol에 축적되어 sweat/immune/nerve 경로가 바뀌며, 그 residue는 `R5`의 `R5-03 Repair Bench`에서 회수된다.
- residents(support): Tams Orro(clinic physician), Salla Rusk(organ broker), Jun Oris(patient), Rill Oran(debt mediator), Havo Pell(replacement vendor), Miri Senn(discharge clerk), Oda Vey(organ advocate), `Hearth`(speaking heart authority).
- core NPC visitors: `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_04_sable_halm`, `npc_03_veya_morcant`, `npc_11_cael_ren`, `npc_01_ilyra_senn`, `npc_14_eda_marrow`.
- initial axes: A `provisional`, B `organ-authority`(disputed `person`), C `linked`, D `failing`.
- initial clocks: I `assigned`, K `active`, R `private`, E `failing`, P `divergent`, C `contested`.
- magic layer: organ magic은 clinic이 medium을 장기로 분류해 판매하는 surface다. magic cure는 통증을 되돌리지 않고 우회하며, 우회한 만큼 `C`가 `branched`로 이동하고 `E`의 medicine 재고가 줄는다. 장기별 authority가 magic output을 다르게 승인할 수 있어 `B`의 organ-authority가 craft 결과를 approve하는 경로가 된다.
- unresolved debt: Hearth가 서명한 petition이 치료계약인지 organ refusal인지 법원 category가 없다.
- one-off dialogue seeds: Hearth는 "내 pain은 clinic의 liability보다 먼저 서명되었다"고 말한다; Salla는 "정상 organ을 사도 organ의 동의는 남지 않는다"고 답한다; Rill은 "debt를 organ에 기록하면 court는 organ을 방문하러 온다"고 설명한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| R6-01 | Organ Intake: organ, patient, replacement part를 각각 다른 form으로 받는다. | B/A/K를 쓴다. | category error를 만든다. |
| R6-02 | Cure Queue: 대기 번호가 symptom보다 먼저 치료를 결정한다. | I/D와 NPC survival을 쓴다. | institutional pressure를 만든다. |
| R6-03 | Heart Petition: Hearth가(operation consent, pain, refusal, witness)를 제출한다. | P/B/R을 쓴다. | one-off dialogue와 body state를 연결한다. |
| R6-04 | Debt Surgery: debt를 organs, work hours, memory access 중 하나로 전환한다. | D/C와 discharge route를 쓴다. | resource/continuity trade-off를 만든다. |
| R6-05 | Organ Chorus Trial: 서로 다른 organ priorities를 combat 또는 negotiation으로 해결한다. | encounter result와 P를 쓴다. | hybrid encounter를 만든다. |
| R6-06 | Body Authority Registry: organ이 사람보다 먼저 legal signatory가 되는 record를 만든다. | B/R/E07-E16를 쓴다. | record와 route를 직접 연결한다. |
| R6-07 | Replacement Market: 정상 부품을 고르는 대신 failure signature을 고른다. | D/K와 encounter roster를 쓴다. | readable enemy choice를 만든다. |
| R6-08 | Discharge Route: 치료가 끝나도 body part의 testimony가 player를 따라온다. | C/R/E16를 쓴다. | backtracking consequence를 만든다. |

Revisit variants:

- Organ Quorum 이후에는 Hearth가 clinic authority가 되어 E07 intake stamp가 바뀐다.
- debt surgery를 선택하면 medicine는 충분하지만 body continuity가 `branched`로 이동한다.
- replacement market에서 failure part를 가져가면 combat signature가 바뀌고 R1 recovery chamber의 문이 재분류된다.
- R4 public record가 organ을 object로Filing하면 discharge route가 막히고, witness가Filing되면 route가 열리지만 social conflict가 커진다.

### 7.8 R7 — The Hollow Orchard

- causal thesis: boundary가 안정되면 crown이 상속되는 것이 아니라, world가 recovery·recognition·authority 중 무엇을 먼저 믿는지에 따라 physical topology가 다시 작성된다.
- physical topology: `Outer Wall`, `Root Orchard`, `Shelter Ring`, `Crown Position`, `Storm Verge`가 phase별로 서로 다른 출입구를 만든다.
- authority: Boundary Survey가 wall, Settlement Council가 shelter, Crownwell Archive가 position record를 관리한다. 어느 authority도 단독으로 crown을 소유하지 않는다.
- resource flow: seed stock, battery, safe path, attention, low-entropy observation time이 사용된다. return은 안전한 memory가 아니라 위험한 knowledge를 가져온다.
- residents(support): Ovi Rusk(wall reader), Nae Linden(orchard keeper), Bero Tern(settlement delegate), Ishi Vey(scout), Sika Lund(child witness), Aven Dros(former operator), `Low-Entropy Surveyor`(outsider).
- core NPC visitors: `npc_07_bryn_oskel`, `npc_12_ravenna_holt`, `npc_01_ilyra_senn`, `npc_11_cael_ren`, `npc_08_meral_dune`, `npc_04_sable_halm`, `npc_10_juno_caster`, `npc_06_tamas_quill`.
- initial axes: A `contested`, B `unclassified`, C `crown-debt`, D `collapsed`.
- initial clocks: I `assigned`, K `systemic`, R `canonical`, E `collapsed`, P `intervened`, C `contested`.
- magic layer: `R7`은 void-cut이 실제로 성공한 유일한 region이다. 잘라낸 shape가 destination, input/output, danger, contract type을 결정하고, 고위 portal은 존재와 contract를 맺어 구체적 spell을 주지만 deferred obligation을 남긴다. 저위 portal은 재물/먹이를 주고 불확실한 존재나 세상의 공격을 받는다. `contract tally`은 이 region에서 만들어진다. `Storm Verge`의 미완성 절단은 `R8-06`과 같은 evidence다.
- unresolved debt: wall은 crown의 위치를 지키는지, crown을 외부에서 밀어내기 위해 설계되었는지Filing되지 않았다. void-cut으로 얻은 존재의 contract가 Crown Protocol 안에 있는지 밖에 있는지도Filing되지 않았다.
- one-off dialogue seeds: Ovi는 "wall은 문보다 먼저 category를 기록한다"고 말한다; Aven은 "crown이 위에 있다고 해서 내가 위에 있는 건 아니다"고 답한다; Sika는 "fruit가 tree를 기억하지 않아도 root는 옮겨진다"고 설명한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| R7-01 | Wall Phase Survey: fruit, shadow, boot mark, wall seam을 서로 다른 evidence로 기록한다. | E/G7과 C input을 쓴다. | epistemic route를 만든다. |
| R7-02 | Orchard Shelter: settlement이 seed, water, memory slot을 나눠가진다. | D/P/R을 쓴다. | resource branch를 만든다. |
| R7-03 | Clone Burial: returning body를 매장하거나 name slot을 남긴다. | C/B/R을 쓴다. | continuity debt를 물질화한다. |
| R7-04 | Crown Position: 다섯 조각의 그림자를 physical object와 title로 따로 기록한다. | C/A와 G8을 쓴다. | crown tri-layer를 드러낸다. |
| R7-05 | Storm Verge: `Boundary Orchard`, `Return Storm`, `Unnamed Operator`가 phase를 시험한다. | K/C와 encounter result를 쓴다. | final combat family을 만든다. |
| R7-06 | Settlement Vote: wall을 닫을지, seed를 보낼지, survey를 떠날지 선택한다. | E/R/H0를 쓴다. | regional ending branch를 만든다. |
| R7-07 | Operator Replacement: Aven, player, institution, organ voice가 operator claim을 제출한다. | A/C/P를 쓴다. | world ending input을 만든다. |
| R7-08 | Boundary Shortcut: storm phase에 맞춰 R2/R6의 reverse route를 만든다. | E09/E16와 topology를 쓴다. | final backtracking을 만든다. |
| R7-09 | Void Cut Ledger: 절단 shape를 먼저 그리고 나서 contract 조건을 고른다. | `blade credit`/`contract tally`과 `C` interpretation input을 쓴다. | destination과 obligation을 authored data가 결정하게 한다. |

Revisit variants:

- Wall Phase가 바뀌면 같은 region의 enemy roster와 resource route가 함께 바뀐다.
- Clone Burial을 완료하면 C value가 낮아지지 않고 `crown-debt`의 named branch가 남는다.
- settlement vote가Filing되면 H0와 R2가 서로 다른 support obligation을 받는다.
- G8 이후에는 R7의 모든 revisit가 old phase/variant로 archive된다. 이전 operator의 memory가 사라지는 것은 아니다.
- `R7-09`에서 체결한 contract는 자동 해소되지 않는다. `contract tally`가 남은 채로 `G8`이 실행되면, precedence는 contract를 `crown_protocol` 안과 밖 중 어디에 두는지 명시해야 하고 어느 쪽도 자동으로 `locked` 처리되지 않는다.

### 7.9 R8 — The Folding School

- causal thesis: craft를 발명한 측이 먼저 예술가로 불리고, 그 대가로 재료 축적과 허약한 몸을 감당해야 했다. 소규모 artisan 집단은 주류에 이용당하고, 학교는 이 계급을 curriculum으로 정형화해 `공정`·자격·고용을 소유한다. 그래서 `R8`의 conflict는 "마법을 배울 수 있는가"가 아니라 "배운 craft를 누구의 노동로 기록할 것인가"다.
- physical topology: `Course Court`(sessione 있는 training court), `Medium Store`(종이·직물·fold sheet가 층별로 쌓인 창고), `Lineage Hall`(가문 배정표와 이름 없는 배정함), `Circulation Board`(농도 측정과 dispersal 배정), `Weave Yard`(야외 실습), `Cut Chamber`(void-cut 연습실, 실패한 fold가 벽에 남아 있다), `Index Desk`(H0 service와 연결된 course index). `Cut Chamber`에서 `E18`로 되돌아가는 `course index return`이 두 번째 return affordance다.
- authority: `MAG_ACADEMY` curriculum office가 과정과 시험을, `CIRCULATION_BOARD`가 농도 인프라를, `LINEAGE_HOUSE`가 미정형 craft 보존을, `VOID_CONTRACT_COURT`가 portal 조건을 각각 관장한다. 네 authority는 같은 craft를 서로 다른 category로 세며, 그 충돌이 `RC-08`의 사건이다.
- resource flow: `medium blank`, `fold sheet`, `blade credit`, `craft credit`, `concentration sample`, `lineage token`을 사용하고, curriculum이 인정하는 `craft credit`과 `R4` glossary 항목을 만들어 낸다. 소모한 `disperser charge`와 `circulation slot`의 원천은 `R2`다.
- residents(support): `Mira Vask`(magic craft queue와 student status 담당), Halen Osk(medium store keeper), Iven Marrow(weave yard instructor), Turo Bex(void-cut 실습 책임자), Perri Lowe(lineage registrar), Jano Fesk(circulation board liaison), Cael Orin(과거 art로 분류된 발명가, 학생이 아님).
- core NPC visitors: `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_09_perrin_lask`, `npc_01_ilyra_senn`, `npc_06_tamas_quill`, `npc_10_juno_caster`, `npc_07_bryn_oskel`.
- initial axes: A `provisional`, B `person`(disputed `artifact`), C `linked`, D `localized`.
- initial clocks: I `assigned`, K `clean`, R `private`, E `localized`, P `divergent`, C `contested`.
- magic layer detail: `R8`은 `concentration_field`를 측정하는 유일한 region이다. field는 `R2-09`에서 옮긴 값의 provenance과 함께 Filing된다. magic 이론의 positive name은 여기서 정하지 않는다. `glossary`는 `R4`가 소유하므로 `R8`은 이름을 요청만 한다.
- unresolved debt: 학교가 lineage에 배정되지 않은 craft를 `unassigned stock`으로 세는 근거가 누구의 명령인지Filing되지 않았다. `Cut Chamber` 벽의 실패한 fold가 누구의 것인지, 그리고 그 failure가 `R` clock의 public record에 있는지Filing되지 않았다.
- one-off dialogue seeds: Mira는 "등록은 내 capability가 아니라 내 measurement의 출처를 고르는 일이라고 말한다"; Jano는 "농도를 낮추면 물이 오염된다. 어느 비용이 더 큰지는 기관이 정한다"고 말한다; Cael은 "발명한 사람을 예술가라 부르기는 쉬웠고, 배부를 가르치기는 어렵지 않았지만 그 뒤가 문제였다"고 말한다.

Exact authored content families:

| family | concrete unit | state read/write | play function |
|---|---|---|---|
| R8-01 | Course Index: 현재 개설된 craft 과정, 소지 credit, 남은 registration 기한을 한 장에 인쇄한다. | `I`/`R`과 `E18` 경과 여부를 쓴다. | `SERVICE_R8_COURSE_INDEX`와 같은 내용을 world 안에서 만든다. |
| R8-02 | Concentration Registration: 지점·시각·측정값·provenance를 함께 등록한다. | `concentration sample`과 `K`를 쓴다. | 값 하나만 적으면 안 되는 이유를 만든다. |
| R8-03 | Lineage Placement: 가문 배정을 받거나 이름 없는 배정함에 넣는다. | `lineage token`과 `C`를 쓴다. | `linked` continuity의 원천을 만든다. |
| R8-04 | Course Selection: weave/fold/void-cut 중 하나를 고르고 필요한 `medium`을 기재한다. | `blade credit`과 `D`를 쓴다. | body `mana_profile`이 허용하지 않으면 선택만 가능하고 실행은 막힌다. |
| R8-05 | Fold Failure Hearing: 실패한 fold를 course credit, student status, public record로 나눠Filing한다. | `P`와 `R`을 쓴다. | `R5-06`과 같은 signature를 학교 규제로 만든다. |
| R8-06 | Void Contract Filing: 다른 차원의 존재와 맺은 contract를 모양·비용·조건과 함께 적는다. | `contract tally`과 `C` input을 쓴다. | deferred obligation이 combat balance가 아님을 만든다. |
| R8-07 | Lineage Refusal: 가문 접근을 거부하고 확산을 택한다. | `A`와 `R`을 쓴다. | `WANDING_MAGE` 분화와 social cost를 만든다. |
| R8-08 | Field Probation: 학교 밖 직장에서 craft를 쓰면 labor record와 course record가 갈라진다. | `A`와 `D`를 쓴다. | 학교가 world 밖으로 새지 않는다는 것을 만든다. |

Revisit variants:

- `R8-05`가Filing되면 그 학생의 `R4-05 Name Hearing` 결과가 다시 열리고, `B` primary가 `artifact`로 이동할 수 있다.
- `R8-03`에서 이름 없는 배정함을 선택하면 `C`는 `linked`로 올라가지 않고 `A`가 `contested`가 된다. 확산은 느리지만 institution 밖에서 일어난다.
- `R8-02`의 provenance이 `R2-09` 기록과 다르면 `concentration sample`은 사용 가능하지만 `K`가 한 단계 전진한다(§6.2 loop 8).
- `G8` 이후에도 `R8` curriculum은 남는다. precedence가 바뀌어도 학교가 curriculum을 버리지는 않는다. 버려지는 것은 `R8`이 `C`에 제출하려던 해석뿐이다.


## 8. Regional event cluster registry

각 cluster는 6~12 NPC, 2~4 institutions, 2~3 clocks, partial truths, resource conflict, immediate consequence, delayed consequence를 가져야 한다. NPC가 서로 모두 만날 필요는 없으며, system port를 가진 NPC는 dialogue-only가 아니다.

`participants`는 canonical core roster(`04` §2의 `npc_01`~`npc_14`)에서만 뽑는다. 각 region's `residents`(support resident)는 cluster participant로 세지 않으며, support resident이 이 문에 직접 관여하는 경우에도 signature는 core NPC의 verb로 기록한다. cluster는 `HC-00` + `RC-01`~`RC-08` 9개가 전부다.

### 8.1 HC-00 — The First Docket, H0

- participants: `npc_02_orrin_kest`(declare), `npc_03_veya_morcant`(challenge), `npc_10_juno_caster`(withhold), `npc_11_cael_ren`(sponsor a return), `npc_01_ilyra_senn`(index), `npc_14_eda_marrow`(redistribute), `npc_08_meral_dune`(ration).
- institutions: Exchange Registrar, Crier Office, Contract Counter.
- clocks: I `assigned`, R `private→circulating`, P `role_bound`.
- partial truths: 빈 Crown Well은 왕관이 사라졌다는 뜻이 아니다; Sable은 마지막 operator가 떠났다고 말하지만 record는Filing되지 않았다; Orrin은 하나의 route만 지워졌다고 안다.
- resource conflict: 하나의 route debt token을 R2 water, R3 care, R5 parts 중 하나에 배정한다.
- choices: `declare person`, `declare patient`, `declare worker`, `withhold category`, `sponsor a return`.
- immediate write: H0 arrival docket, A provisional, B category, E debt.
- delayed consequence: R4가 filing을 거부하면 첫 public record가 생기고, R3/R5 NPC가 player의 declaration에 따라 care sponsor 또는 labor witness로 갈린다.

### 8.2 RC-01 — Wrong Return, R1

- participants: `npc_02_orrin_kest`(shelter), `npc_11_cael_ren`(carry claimant), `npc_13_tovan_reed`(carry), `npc_03_veya_morcant`(challenge), `npc_05_nera_voss`(listen), `npc_01_ilyra_senn`(index), `npc_06_tamas_quill`(compare).
- institutions: Return Registry, Kiln Wardens, Bellhouse intake office.
- clocks: K `exposed`, I `noticed`, P `divergent`.
- partial truths: door는 body를 되돌렸지만 role을 되돌리지 않았다; Lissa는 마지막 bell을 들었다고 기억하지만 Ash Choir log는 비어 있다; Nera는 원 employment를 기억하지 못한다.
- resource conflict: ash thread를 door 안정화에 쓰면 recovery evidence가 소모된다.
- choices: `restore role`, `restore body`, `keep door`, `erase record`, `carry claimant`.
- immediate write: C branch, B category, K increment, E06/E07 candidate.
- delayed consequence: R4에는 pending record, R6에는 body authority 후보가 생기고 H0 return hearing이 두 번 열린다.

### 8.3 RC-02 — Same Water, R2

- participants: `npc_08_meral_dune`(ration), `npc_14_eda_marrow`(redistribute), `npc_11_cael_ren`(migrate), `npc_05_nera_voss`(veto), `npc_13_tovan_reed`(triage), `npc_09_perrin_lask`(enroll), `npc_10_juno_caster`(publish the census).
- institutions: Water Council, Seed Vault, Settlement Council. (`MAG_ACADEMY` curriculum office는 `concentration registration`을 curriculum 인증으로 요구하므로 원격 attendee로 등장한다.)
- clocks: E `failing`, K `active`, P `divergent`.
- partial truths: water는 safe하지만 legal name은 새 home을 인정하지 않는다; 같은 body가 서로 다른 water claim을 한다; Ione의 seed count는 census보다 많다.
- resource conflict: clean water와 seed를 medicine ferry에 보낼지 settlement에 남길지 선택한다.
- choices: `ration`, `migrate`, `share`, `seal the ferry`, `publish the census`.
- immediate write: E buffer, R public ration, E08/E17 route state, C claimant category.
- delayed consequence: R6 medicine price와 R7 shelter capacity가 바뀐다. migration을 선택한 clone은 H0에서 새로운 provisional identity를 요구한다.
- magic consequence: `R2-09`/`R2-10`이 이 cluster 뒤에만 Filing 가능하고, Filing 여부가 `E18`의 resource gate를 결정한다. circulator를 먼저 돌린 run에서는 `E08`의 medicine lane이 `failing`에서 시작한다.

### 8.4 RC-03 — Mercy Delay, R3

- participants: `npc_04_sable_halm`(consent), `npc_09_perrin_lask`(enroll/rename), `npc_03_veya_morcant`(challenge), `npc_05_nera_voss`(listen), `npc_13_tovan_reed`(triage), `npc_08_meral_dune`(mobilize), `npc_01_ilyra_senn`(index), `npc_10_juno_caster`(withhold).
- institutions: Hospice Covenant, Faith Engineering unit, Care Union.
- clocks: I `assigned`, P `divergent`, R `private`.
- partial truths: bell은 신앙을 측정하지 않고 response latency를 줄인다; Eda는 memory copy가 consent가 아니라고 생각한다; Junip은 transformed status를 worker record에만 넣길 원한다.
- resource conflict: care labor 한 명을 fast recovery와 memory archive 중 하나에 배정한다.
- choices: `fast recovery`, `preserve consent`, `split the window`, `join the care shift`, `close the queue`.
- immediate write: I intervention stage, P role decision, R care record, E10/E11 candidate.
- delayed consequence: R5 boot contract와 R4 archive outcome이 서로 다른 operator name을 생산한다. Marda와 Cal의 relationship state가 갈라진다.
- magic consequence: `mana_profile`이 Filing되면 같은 patient에게 `emission failure` category가 붙고, 그 category는 `R5-01`의 boot 조건과 `R8-04`의 course 선택 가능 목록을 함께 좁힌다.

### 8.5 RC-04 — Sentence Above the Stair, R4

- participants: `npc_06_tamas_quill`(choose), `npc_01_ilyra_senn`(index), `npc_10_juno_caster`(publish contradiction), `npc_03_veya_morcant`(sign exception), `npc_04_sable_halm`(patch), `npc_11_cael_ren`(refuse inheritance), `npc_12_ravenna_holt`(defer crown).
- institutions: Translation Tribunal, Record Office, Censor Office.
- clocks: R `filing→canonical`, I `assigned`, C `contested`.
- partial truths: 두 번역은 같은 원문에서 나왔지만 서로 다른 recovery rule을 만든다; Tallo는 public copy가 이미 외부로 나갔다고 한다; Iri는 contradiction보다 speed를 우선한다.
- resource conflict: archive weight 한 묶음을 canonical translation에 쓸지 public evacuation에 쓸지 선택한다.
- choices: `submit translation A`, `submit translation B`, `publish contradiction`, `withhold the sentence`.
- immediate write: R canonical flag, A contested, E12/E13 route category, C interpretation input. (`E04`는 이 cluster 이전에 열려 있어야 한다. §5.4.2.)
- delayed consequence: 선택한 문장이 R5의 labor role과 R7의 wall category를 바꾼다. archive에 남아 있는 이전 operator memory가 새 law에 맞춰 재분류된다.
- magic consequence: `glossary` slot에 먼저 들어온 쪽이 이름의 canonical이 된다. `R8-03`/`R8-04`가 `RC-08` 이전에 Filing되었다면 학교 이름과 archive 번역이 충돌하고 `R4-02` 상태가 된다.

### 8.6 RC-05 — Uniform, Name, Contract, R5

- participants: `npc_04_sable_halm`(consent), `npc_14_eda_marrow`(mobilize), `npc_05_nera_voss`(veto), `npc_09_perrin_lask`(rename), `npc_13_tovan_reed`(operate), `npc_01_ilyra_senn`(index), `npc_10_juno_caster`(withhold).
- institutions: Glasswing Ordinal, Labor Court, Support Registry.
- clocks: I `assigned`, K `exposed`, P `divergent`.
- partial truths: boot는 성공했지만 보호 능력의 소유자가 불명확하다; Rhea는 consent가 capability보다 먼저 필요하다; Bex는 refusal를 contract breach로 처리하지 않는다.
- resource conflict: 한 power cell을 boot, repair, gantry battery 중 하나에 배정한다.
- choices: `full boot`, `staged boot`, `refuse boot`, `split the name`, `record partner permission`.
- immediate write: B operator, A labor legitimacy, C transformation lineage, E14/E15/E18 route gate.
- delayed consequence: R3 care result와 R6 organ testimony가 같은 operator name을 서로 다른 방식으로 부른다. H0의 route debt는 해당 NPC가 sponsor인지 subject인지에 따라 생성된다.
- magic consequence: `G5`의 세 결과가 `E18`을 서로 다르게 만든다. `full`/`staged`는 `open`, `refused`는 `closed`(우회: R5 내부 industrial permit으로만 craft). `R5-10`~`R5-12`의 실행 가능 여부는 이 결과와 `mana_profile`이 함께 결정한다.

### 8.7 RC-06 — The Heart's Petition, R6

- participants: `npc_05_nera_voss`(listen), `npc_13_tovan_reed`(operate), `npc_04_sable_halm`(patch), `npc_03_veya_morcant`(challenge), `npc_11_cael_ren`(choose history), `npc_01_ilyra_senn`(reclassify), `npc_14_eda_marrow`(redistribute). (`Hearth`는 organ authority surface이며 actor가 아니다.)
- institutions: Gristmarket Clinic, Debt Court, Organ Exchange.
- clocks: P `divergent`, K `active`, E `failing`.
- partial truths: Hearth는 patient의 pain과 clinic의 liability를 다른 priority로 본다; Jun은 organ signature를 권한으로 받아들이지 않는다; Salla는 replacement part를 정상 part보다 싸게 분류한다.
- resource conflict: medicine, credit, replacement part 중 하나를 organ testimony의 대가로 쓴다.
- choices: `sign custody`, `split custody`, `refuse replacement`, `record the complaint`, `take the debt`.
- immediate write: B organ-authority, C bypass lineage, D debt, E16 route candidate.
- delayed consequence: R1 recovery chamber가 organ clinic으로 바뀌고 R4 public record가 organ을 object로 쓸지 person으로 쓸지 결정해야 한다.
- magic consequence: magic cure가Filing되면 `C`가 `branched`로 이동하고, 장기 residue는 `R5-03`의 회수 대상이 된다. residue를 회수하지 않으면 `R5-10`의 cast 오차가 한 단계 올라간다.

### 8.8 RC-07 — Map Made by the Wall, R7

- participants: `npc_07_bryn_oskel`(seal route), `npc_12_ravenna_holt`(defer crown), `npc_01_ilyra_senn`(reclassify), `npc_11_cael_ren`(choose history), `npc_08_meral_dune`(divert), `npc_04_sable_halm`(patch), `npc_10_juno_caster`(forward), `npc_06_tamas_quill`(compare). (`Low-Entropy Surveyor`는 actor가 아니라 outsider observation surface다.)
- institutions: Boundary Survey, Settlement Council, Crownwell Archive.
- clocks: C `contested→aligned`, K `systemic`, R `canonical`.
- partial truths: wall은 crown을 지키는 것이 아니라 crown의 category를 외부에 보여주는 장치다; Surveyor는 반복되는 human behavior를 low entropy resource로 평가한다; Sika는 empty tree의 fruit를 transplant로 기억한다.
- resource conflict: seed stock와 battery를 shelter, wall survey, gantry 중 하나에 배정한다.
- choices: `align recovery`, `align recognition`, `align authority`, `keep the wall closed`, `send the seed away`.
- immediate write: C alignment, physical topology, E09/E13/E16 redirect, global route variant.
- delayed consequence: H0, R1, R2, R3, R4, R5, R6의 모든 revisit에 one named debt가 추가된다. player가 이미 아는 final rule은 재발견 시간 없이 즉시 실행할 수 있다.
- magic consequence: `R7-09`의 contract가Filing되면 `contract tally`가 남고, `G8`은 그 contract를 `crown_protocol`의 안과 밖 중 한 곳에 명시해야 한다. 어느 쪽도 자동 `locked`가 되지 않으며, `R8-06`이 같은 contract를 다시 쓰면 두 record가 conflict한다.

### 8.9 RC-08 — The Fold That Refuses the Hand, R8

- participants: `npc_04_sable_halm`(consent, allocation), `npc_14_eda_marrow`(strike, redistribute), `npc_09_perrin_lask`(enroll, hide), `npc_01_ilyra_senn`(reclassify), `npc_06_tamas_quill`(compare, publish), `npc_10_juno_caster`(forward, withhold), `npc_07_bryn_oskel`(mark the cut).
- institutions: `MAG_ACADEMY` curriculum office, `CIRCULATION_BOARD`, `LINEAGE_HOUSE` registrar, `VOID_CONTRACT_COURT`.
- clocks: I `assigned`, P `divergent`, R `private`. (`E`는 학생 수와 medium 비에만 반응한다.)
- partial truths: 학교는 lineage 미배정 craft를 `unassigned stock`으로 세지만, 그 분류를 만든 authority가 누구인지 아무도 답하지 못한다; `R4` glossary는 학교 이름을 아직 모른다; `R7`의 미완성 절단은 `R8` 실습실의 잔해와 같은 maker의 것이다; `Mira`는 등록이 capability 등록이 아니라 measurement provenance 등록이라고 안다.
- resource conflict: 마지막 `medium blank` 하나를 course 채점에 쓸지, 실패한 fold의 `Cut Chamber` 잔해를 회수해 `R5-03`으로 보낼지 배정한다.
- choices: `register concentration`, `place in lineage`, `select course`, `withdraw and take the labor record`, `record the failed fold`.
- immediate write: `concentration sample` 등록, `lineage token`/`craft credit` 배분, `I` intervention stage, `P` role decision, `R8` region state.
- delayed write: `R4` glossary 충돌, `R5` labor record 재분류, `R2` `E` 한 단계 전진, `R7` contract와의 conflict.
- combat/noncombat: `ENC-ARPG-25`는 field court encounter로도, noncombat `withdraw and take the labor record`로도 끝난다. shape/medium 불일치는 spell rename이 아니라 status·document·clock write로만 표현한다.

## 9. World state write contract

### 9.1 저장할 world state

World plan이 다른 Kit 파일과 공유할 최소 state는 다음과 같다. 표현 노드는 이 state의 진실을 소유하지 않는다.

- `world_id`, `schema_version`, `crown_precedence`, `operator_id`, `crown_object_phase`
- `axes`: A/B/C/D의 현재 integer와 마지막 write event. token 문자열을 저장하지 않는다(§3.3).
- `clocks`: region별 I/K/R/E/P/C의 stage, tick, last signal, committed event
- `regions`: physical topology, authority, resource flow, current state, hidden state, revisit variant, unresolved debt, cross-region link
- `routes`: edge ID, `locked`/`open`/`conditional`/`redirected`/`closed`/`debt-bearing`, gate ID, alternative edge, route write
- `npcs`: role, location, system port, knowledge boundary, relationship stage, survival/removal/absence result
- `encounters`: roster, phase, failure, victory/escape, world effect, repeat policy
- `records`: official copy, public rumor, contradictory copy, authority, filing stage
- `recovery`: checkpoint/respawn/clone/reincarnation/loop/immortality/institutional_reentry type와 보존·버린 self
- `magic`: 아래 6개 하위 record. 축이나 clock이 아니다.
  - `concentration_fields`: node/path/action 단위 측정값, 측정 시각, `provenance`(`R2-09`/`R8-02` 중 어느 record에서 왔는지)
  - `body_load`: actor별 accumulation, emission capacity, injury, `mana_profile`(12 §2.2의 8종 중 world가 쓴 것만)
  - `circulation`: node별 disperser 상태, `circulation_slot` 잔량, 누적 pollution 기록
  - `crafts`: 준비된 weave/scroll, fold count 잔량, `shape_or_pattern`, `tool_variant`, 중량 residue
  - `contracts`: 체결된 portal contract의 shape, 대가, 조건, `contract_tally`, resolution 상태
  - `glossary`: `R4`가 소유하는 authored record. 비어 있으면 craft 이름은 `untranslated term`으로 Filing된다
- `commit_log`: seed ID, event ID, source region, target regions, immediate write, delayed write, player action

`magic` record는 `res_*` field resource(amount)와 분리한다. `medium_blank` 같은 물질은 `world.resources`에, `shape_or_pattern`/`tool_variant` 같은 계약 조건은 `magic.crafts`에 있다. 한 값을 두 namespace에 복제하지 않는다.

player knowledge는 `world state`의 route gate flag로 저장하지 않는다. 이미 아는 문장은 즉시 실행할 수 있게 하고, NPC·institution은 그 지식을 공유하지 않는다.

### 9.2 Write transaction 순서

모든 authored event는 다음 순서를 따른다.

1. **Intent**: player 또는 NPC가 action intent를 만든다.
2. **Precondition**: physical location, institution permission, resource, epistemic act를 확인한다.
3. **Local commit**: 해당 region의 NPC/encounter/record/domain state를 먼저 갱신한다.
4. **Cross-region fanout**: 명시된 cross-link만 다른 region의 axis, clock, route, NPC state를 갱신한다.
5. **Delayed write**: pressure clock이 다음 intervention 또는 irreversible stage를 예약한다.
6. **Commit log**: seed ID와 authored event ID, immediate/delayed consequence를 기록한다.
7. **Presentation read**: 화면은 committed state만 읽는다. Label, animation, NPC portrait가 world state를 바꾸지 않는다.

transaction이 중단되면 local provisional state와 public committed state를 구분한다. combat failure는 encounter-local provisional state를 reset할 수 있지만, 이미Filing된 record·debt·route permission·player knowledge를 지우지 않는다.

### 9.3 Write ownership

- Crown Protocol은 `crown_precedence`, `operator_id`, `crown_object_phase`만 쓴다. region의 water, NPC affection, combat HP를 직접 쓰지 않는다.
- H0 Registrar는 arrival category와 route permission을 쓰며 region 내부 결과를 복사하지 않는다.
- R1 Return Registry는 recovery lineage과 door recognition을 쓴다.
- R2 Water Council/Seed Vault는 resource buffer와 settlement category를 쓴다.
- R3 Hospice는 intervention stage, care record, consent state를 쓴다.
- R4 Record Office/Translation Tribunal만 canonical translation과 public category를 쓴다.
- R5 Ordinal/Labor Court는 boot result, labor status, transformation capability를 쓴다.
- R6 Clinic/Organ Exchange는 organ authority, cure debt, replacement outcome을 쓴다.
- R7 Boundary Survey는 topology와 crown alignment input을 쓴다. operator 설치는 G8에서만 commit한다.
- R8 `MAG_ACADEMY` curriculum office는 `course index`, `lineage placement`, `student status`, `craft credit`을 쓴다. `CIRCULATION_BOARD`는 `concentration_field` 측정값과 dispersal 배정만 쓴다. `LINEAGE_HOUSE` registrar는 `lineage_token`만 쓴다. `VOID_CONTRACT_COURT`는 `contract tally`와 contract 문서만 쓴다. 네 authority는 서로의 field를 쓰지 않으며, 충돌은 `R4-02`와 같은 conflict record로 남긴다.
- magic은 어떤 authority도 `Crown Protocol`의 세 field를 직접 쓰지 못한다. `R8`이 `crown_precedence`에 제안하는 것은 없고, 제안은 `R4` glossary와 `R7` contract 문서를 통해서만 들어간다.
- encounter는 reward와 failure result를 계산할 수 있지만 cross-region write는 authored event fanout을 통해서만 한다.

### 9.4 주요 event의 cross-region write

| event | immediate write | delayed write | route/result |
|---|---|---|---|
| HC-00 | H0 arrival, A/B provisional, route debt token | R4 public filing, R3/R5 NPC role change | E01-E05의 비용과 category가 바뀐다. |
| RC-01 | R1 continuity branch, K increment, pending record | R4 category, R6 body authority | E06/E07이 서로 다른 recovery route로 열린다. |
| RC-02 | R2 water/seed buffer, `concentration sample`/`circulation slot`, E08/E17 state | R6 medicine price, R7 shelter capacity, R8 E18 resource gate | medicine/emergency route가 resource variant를 만들고, magic route의 비용이 정해진다. |
| RC-03 | R3 latency and consent record, `mana_profile` | R5 contract, R4 archive outcome, R8 course eligibility | E10/E11의 category와 NPC availability가 바뀐다. |
| RC-04 | R4 canonical law, C interpretation, `glossary` 선점 | R5 labor name, R7 wall category, R8 course naming | E12/E13의 epistemic target과 학교 이름의 canonical 여부가 바뀐다. |
| RC-05 | R5 boot and labor record, `medium`/`blade` 배분 | R3 consent, R6 organ testimony, R8 E18 permission | E14/E15가 organ과 crown route를 함께 엮고 E18의 route state가 `G5` 결과로 정해진다. |
| RC-06 | R6 organ custody, C bypass, D debt, medium residue | R1 recovery room, R4 public record, R5-03 회수분 | E16과 discharge route가 evidence가 되고 R5 cast 오차가 바뀐다. |
| RC-07 | R7 topology, C alignment, `contract tally`, all route redirect | H0/R2 support obligation, global revisit variants, R8 contract conflict | final state가 아니라 새 protocol 우선순위를 만든다. |
| RC-08 | R8 `concentration sample` 등록, `lineage_token`/`craft credit`, I/P stage, R8 region state | R4 glossary 충돌, R5 labor 재분류, R2 `E` 전진, R7 contract conflict | E18이 통과한 상태로 남고 capability 5가 열린다. |

## 10. Recovery와 재방문 규칙

- **Checkpoint**: encounter-local body, combat, local resource state를 복원한다. 이미Filing된 region write, NPC removal, route permission, player knowledge는 유지한다.
- **Re-entry**: body 또는 role은 보존할 수 있으나 social continuity와 employment history가 달라진다. 원래 failure를 되돌리는 recovery가 아니다.
- **Clone/branch**: body·memory의 공유 여부와 social continuity를 분리해 저장한다. clone은 같은 name을 자동으로 공유하지 않는다.
- **Loop rehearsal**: local route mechanics와 NPC action window를 되감지만, knowledge, debt, filed record는 유지한다.
- **Institutional re-entry**: archive/clinic/registry가 대상을 새 category로 기록한다. 이전 record를 삭제하지 않고 contradictory copy로 남긴다.
- **Crown alignment**: irreversible global write다. 이후에는 old phase를 revisit archive로 읽을 수 있지만 이전 player choice를 지운다.
- **magic failure**: `recoverable`(medium 재사용 가능, body 무변경), `continuity-changing`(body load 또는 `C`에 `branched` 기록), `terminal`(competence/cognition 또는 magic access 상실) 세 등급으로 분류한다. 이 등급은 `08`의 recovery 7종과 별개이며, recovery type이 아니다.

모든 recovery 결과는 region dossier의 `revisit variants`를 호출한다. recovery가 world state 전체를 초기화하는 shortcut은 금지한다.

recovery는 `magic` record를 초기화하지 않는다. `concentration_fields`의 `provenance`, `body_load`의 injury, `contracts`의 미해결 obligation, `glossary`의 filled slot은 checkpoint 뒤에도 남는다. 되돌릴 수 있는 것은 현재 encounter의 cast뿐이며, 이미 소모된 `medium_blank`와 `fold_sheet`는 다시 지급되지 않는다(§5.4).

## 11. 160-seed ledger transformation plan (core 120 + magic supplement 40)

### 11.1 Quota와 audit policy

- core ledger의 독립 idea unit은 120개(`S001`~`S120`), magic supplement는 40개(`S121`~`S160`)다. 합계 denominator는 160개다.
- 이 파일에서는 160개를 36개의 구조 변환 단위(X01~X26 core, X27~X36 magic supplement)에 예약한다. 각 seed는 이름만 바꾸지 않고 local rule, TIN binding, 두 개 이상의 cross-link, immediate consequence, delayed consequence를 가져야 한다.
- 계획 상태는 전부 `PLANNED_RETAINED`다. 이는 구현 완료나 실제 `used` 판정이 아니다. 계획 단계에서 `USED`/`TRANSFORMED`를 주장하지 않는다.
- accounting은 다음이 고정이다.

| ledger | 독립 unit | hard gate (60%) | preferred target |
|---|---:|---:|---:|
| core | 120 | 72 | 90 |
| magic supplement | 40 | 24 | 30 |
| total | 160 | 96 | 120 |

- `used`와 `transformed`는 구현·검수 뒤에만 기록한다. drop/replace가 필요하면 기존 unit ID를 audit에 남기고 새 seed를 예약하며, gate 산정에서 seed 수를 줄이지 않는다.
- `TONE` seed는 lore paragraph가 아니라 report form, NPC interruption rhythm, document layout, one-off scene로 구조화한다. `ONEOFF` seed도 최소 두 cross-link와 delayed consequence를 가져야 한다.
- 아래 표의 `links`는 region/family/cluster/axis/clock에 대한 stable ID다. `I → D`는 immediate consequence → delayed consequence다.
- magic supplement seed는 새 region이나 새 system을 요구하지 않는다. 전부 기존 `R2`~`R8` family, 기존 축, 기존 6개 clock 안에서 실행된다. 새 축·새 clock·새 recovery type·새 combat system을 만들면 그 seed는 `unbound`다.

### 11.2 Transformation units

| unit | seed IDs | local rule and structural change | binding and cross-links | immediate → delayed | status |
|---|---|---|---|---|---|
| X01 | S001-S004 | 다섯 조각 왕관은 physical object, operator title, protocol precedence를 동시에 드러낸다. S001은 위치, S002는 operator 교체, S003은 title persistence, S004는 organ/body의 분산 voice를 담당한다. | R7-04, R4-06, R6-01, R1-08; A/B/C | observing crown fragment는 recognition을 바꾸고, 이후 operator는 누적 continuity debt를 물려받는다. | PLANNED_RETAINED |
| X02 | S005-S008 | clone은 memory를 공유해도 social continuity가 갈라진다. high cognition은 raw contradiction을 버리며, death cost는 다른 branch/role로 이동한다. | R2-04, R1-01, R4-07, R7-03; B/C | category 또는 recovery를 선택하면 lineage가 갈리고, 다음 region의 legal name이 바뀐다. | PLANNED_RETAINED |
| X03 | S009-S012 | backroom은 recovery 실패가 공간화된 곳이다. boundary가 흔들리면 Return Bureau와 interrogation office가 각각 접근을 시도한다. | R1-02, R7-01, R1-06, R3-01; I/K/C | recovery space를 열면 institutional stamp가 붙고, route가 닫힐 때 다른 institution이 대신 개입한다. | PLANNED_RETAINED |
| X04 | S013-S018 | faith는 intervention latency를 줄이는 engineering parameter다. contamination는 이동·접촉·행동으로 변하고, 200년의 실패는 fatigue와 document form으로 남는다. | R3-02, R3-04, R1-06, R2-01, R4-03; I/K/R | care window와 contamination trace가 바뀌고, 장기간 failure는 다음 institution의 staffing/resource demand로 누적된다. | PLANNED_RETAINED |
| X05 | S019-S024 | incident report는 world law가 된다. transformation은 permission, temporary execution space, stability trade-off, incomplete log를 가지는 boot process다. | R4-02, R5-01, R5-02, R5-06, R3-05; A/C/D | report가 filing되면 gate가 바뀌고, incomplete stage는 delayed maintenance/encounter를 만든다. | PLANNED_RETAINED |
| X06 | S025-S027 | brain/body hardware log는 organ별 authority를 드러낸다. 변환은 costume가 아니라 social recognition phase를 만들며, intimate care도 bureaucratic protocol로 처리된다. | R6-01, R5-04, R5-08, R3-03; B/P | log가Filed되면 NPC가 새 role로 호명되고, care contract가 delayed recognition을 만든다. | PLANNED_RETAINED |
| X07 | S028-S031 | organ들은 서로 다른 priority를 가진다. brain은 decoding threshold 이후에만 speak하고, recovery는 원상복원이 아니라 bypass manual이다. | R6-03, R6-05, R6-06, R1-04; B/C/P | organ signature가 custody와 route를 바꾸고, bypass는 symptom을 줄이는 대신 continuity debt를 남긴다. | PLANNED_RETAINED |
| X08 | S032-S035 | clone의 social distinction, mass ecology cost, loop responsibility, branch debt가 동일한 recovery family를 공유한다. | R2-02, R2-05, R1-05, R7-03, R7-07; C/D/R | clone 수와 loop 선택이 resource와 operator claim에 영향을 주고, 다음 region에서 social cost가 나타난다. | PLANNED_RETAINED |
| X09 | S036-S040 | 한 줄의 organ voice, thirty-year employment/cure, freelancer fatigue를 긴 administrative record와 만남의 interruption으로 만든다. 긴 문장은 format을 깨고 긴 contract는 survival arithmetic로 바뀐다. | R6-03, R5-07, R6-04, H0-05, RC-06; P/R/E | 한 줄이 negotiation을 뒤집고, thirty-year projection은 다음 resource deadline을 만든다. | PLANNED_RETAINED |
| X10 | S041-S046 | cure/therapy economy, animal-name guardian registry, photo misclassification, special-case child, helpful-but-dangerous person을 concrete document와 route record로 만든다. | R6-02, R5-04, R4-03, R3-01, R2-08; A/B/P | category가Filing되면 care access와 trust가 갈라지고, legal danger가 route permission을 바꾼다. | PLANNED_RETAINED |
| X11 | S047-S050 | emergency group chat, public app rumor, company deliverable, “shut up” interruption을 H0 crier와 institution communication으로 만든다. | H0-05, R4-03, R5-01, HC-00, RC-04; R/I | rumor이 canonical copy를 앞지르면 public record clock이 전진하고, 짧은 interruption이 긴 설명을 취소한다. | PLANNED_RETAINED |
| X12 | S051-S055 | operator 교체에도 protocol은 남는다. authority는 물체와 claim으로 나뉘고, subordinate가 crown position을 더 정확히 아는 one-off을 만든다. | R7-04, R7-07, R4-07, H0-03, R5-04; A/C | operator claim이Filing되면 title과 body가 갈라지고, 다음 precedence dispute가 시작된다. | PLANNED_RETAINED |
| X13 | S056-S060 | record는 event보다 오래 살아 architecture가 위계를 만든다. crown은 설명하지 않고 faction별 protocol을 공급한다. higher object가 king의 order를 거부하는 scene을 만든다. | R4-02, R4-06, R4-08, R7-04, R7-07; R/C | record가Filing되면 category가 굳고, vertical route와 operator replacement가 topology를 바꾼다. | PLANNED_RETAINED |
| X14 | S061-S064 | identical bodies의 aggregate consumption은 ecology와 infrastructure를 파괴한다. safe plant/water knowledge는 분산된 NPC network에만 있다. cold·hunger·disease·conflict는 별도 pressure로 작동한다. | R2-01, R2-05, R2-07, R3-04, R7-02; D/K/P | resource extraction이 climate와 social order를 바꾸고, 마지막 medicine가 여러 region에 delayed pressure를 만든다. | PLANNED_RETAINED |
| X15 | S065-S068 | survival 계산을 public detail number로 만들고, remote settlement의 knowledge exchange를 route/revisit value로 만든다. | R2-04, R2-08, R2-06, R7-02, H0-04; D/R/P | 숫자와 계산이 allocation을 Filing하고, knowledge를 나눈 settlement만 다음 phase에 생존한다. | PLANNED_RETAINED |
| X16 | S069-S073 | high-level cognition은 low-level error를 버린다. reading shortcut은 partial translation을 새 law로 만들고, translation lifetime은 region time보다 길다. | R4-01, R4-02, R4-07, R7-01, R5-04; B/R/C | 잘못된 해석이 route를 열거나 닫고, raw observation을 가진 player는 이미 아는 규칙을 즉시 실행할 수 있다. | PLANNED_RETAINED |
| X17 | S074-S078 | wrong translation을 알면서 사용하고, untranslated term을 social scene에 남긴다. outsider는 human의 low-entropy repetition을 resource로 평가한다. scale이 바뀌면 name과 identity가 갈라진다. | R4-01, R4-03, R7-01, R7-04, R6-06; B/R/E | term이 category와 operator를 바꾸고, outsider report가 R7의 crown interpretation에 delayed evidence가 된다. | PLANNED_RETAINED |
| X18 | S079-S083 | surgery는 body만 바꾸고 social identity는 남길 수 있다. failed operation도 valid protocol이며, log와 manual은 recovery limits를 명시한다. | R6-01, R6-06, R6-08, R1-04, R4-07; B/C/R | operation이 discharge와 archive record를 만들고, bypass는 symptom이 줄어도 body/social split을 남긴다. | PLANNED_RETAINED |
| X19 | S084-S087 | organ complaint와 organ chorus는 political meeting을 중단한다. transformation은 beauty·legal prohibition·social rejection을 동시에 가질 수 있고 disagreement는 negotiation combat이 된다. | R6-03, R6-05, R5-04, R3-03, H0-06; P/B/A | complaint가 signature를 바꾸고, transformation choice가 relationship과 legal route를 동시에 열거나 닫는다. | PLANNED_RETAINED |
| X20 | S088-S092 | magical support는 social service, dragon warrior는 institutional job, runaway obligation은 agency test, school과 cure economy는 horror registry가 된다. | R3-05, R5-01, R5-05, R5-08, R6-04; A/P/E | job/contract가 care access와 combat route를 바꾸고, obligation을 거부하면 H0 debt가 Filing된다. | PLANNED_RETAINED |
| X21 | S093-S097 | clone-heavy settlement, medieval order 안의 boot lab, faith-lag cathedral, cloning wilderness, translation office를 genre boundary가 아니라 resource/epistemic collision로 만든다. | R2-05, R5-02, R3-02, R7-02, R4-02; D/R/C | 각 content family가 다른 axis를 쓰며, 다음 region의 protocol이 cross-link를 요구한다. | PLANNED_RETAINED |
| X22 | S098-S100 | organ clinic은 social hub, crown archive는 vertical institution, public chat는 유일한 witness가 된다. 각 organ과 record가 route를 직접 열거나 닫는다. | R6-01, R4-06, H0-05, R7-06, R1-06; B/R/C | testimony가 filed되면 public classification과 physical edge가 동시에 바뀐다. | PLANNED_RETAINED |
| X23 | S101-S104 | official이 불가능한 rule을 employment/manual로 설명하고, child question이 category error를 드러낸다. therapist는 loop를 schedule로, doctor는 organ에 form signature를 요구한다. | H0-05, R1-06, R3-06, R6-03, R5-01; A/P/R | 질문·form·schedule가 route category를 뒤집고, 다음 institution이 그 결정을 실제로 적용한다. | PLANNED_RETAINED |
| X24 | S105-S110 | transformation을 relationship pending로 기록하고, clone은 이미 사용된 legal name을 거부한다. public record는 speaking person을 object로 쓴다. survival calculation과 love confession, outsider compliment는 same-number tension을 가진다. | R5-04, R2-04, R4-03, R2-08, R7-01, R6-03; B/P/R | legal name과 affection 선택이Filing되고, H0 route debt와 R7 witness evidence가 delayed consequence로 남는다. | PLANNED_RETAINED |
| X25 | S111-S115 | institution safety manual을 그대로 따라 backroom rule을 깬다. organ chorus는 political agenda를 가진다. transformation은 social recognition 없이 성공할 수 있고, chat screenshot는 context를 잃는다. | R1-02, R1-06, R6-05, R5-06, H0-05; A/C/R | manual compliance가 encounter signature를 바꾸고, screenshot/recognition failure가 public record와 NPC action을 분리한다. | PLANNED_RETAINED |
| X26 | S116-S120 | archive에는 이전 operator의 memory가 있어도 operator는 없다. king의 order보다 crown이 높다는 one-off, rumor을 physical object로 만드는 scene, transformation의 consent conflict, 세 기관의 서로 다른 사건 report를 만든다. | R4-06, R7-04, R7-08, R5-08, H0-05, R6-06; C/R/P | precedence, topology, relationship, public record가 동시에 delayed write를 예약하며 final cluster가 세 report를 모두 보존한다. | PLANNED_RETAINED |
| X27 | S121-S124 | 마나를 원소로 둘지 미발견 화합물로 둘지 선택하지 않고, `concentration-mediated craft`라는 공통 contract와 여러 물질 모델을 허용한다. 농도가 높을수록 efficiency와 training이 오르다가 threshold를 넘으면 failure와 world pressure로 돌아온다. 산인데 평지로 읽히는 지형은 spatial perception anomaly로 `B`를 흔든다. | R8-02, R2-09, R5-11, R7-01; D/K/P | measurement 하나가 `E18` 비용과 `K` stage를 함께 정하고, threshold 초과가 `R4-02`와 같은 category error record를 만든다. | PLANNED_RETAINED |
| X28 | S125-S128 | 위험한 현상을 자연마법으로 즉시 정당화하는 기관 voice를 만든다. 마나를 안전 밀도로 흩뿌리는 humidifier/disperser와 축적분을 외부 공기로 순환시키는 circulator는 civic infrastructure이며, circulator는 오염 비용을 만든다. 발출만 되고 저장은 되지 않는 체질은 body compatibility profile이다. | R2-09, R2-10, R3-01, R8-02; I/K/E | dispersal이 `E18` resource를 만들고, circulation이 이웃 region의 `K`를 올리며, emission profile이 `R5-01` boot 조건을 좁힌다. | PLANNED_RETAINED |
| X29 | S129-S132 | 마나가 쌓이지 않는 사람과 과잉 축적되는 사람을 moral class가 아니라 resource class로 분류한다. 극단 농도 지형은 region hazard가 되고, 마나가 뇌/면역을 손상시키거나 각성시키며, 체로 배출하는 능력은 cleansing과 resource loss를 동시에 만든다. | R3-01, R3-05, R6-01, R7-01, R2-09; B/P/D | profile이 `B` disputed claim을 만들고, 배출 능력이 medicine 선행분에 substitution을 제공하며, 각성/손상이 `C`를 `branched`로 이동시킨다. | PLANNED_RETAINED |
| X30 | S133-S136 | 미세플라스틱를 다루는 능력은 실패하면 cognition/competence를 잃는다. 플라스틱 시대를 지난 진화, 방향성으로 빠른 수련, 후성 유전 직업 전문 가문을 deep-era와 institution 응답으로 만든다. | R8-05, R8-03, R3-05, R6-04; P/R/C | 실패가 terminal 등급이 되어 `R5-11` cast를 닫고, 가문이 `lineage_token`을 외부에 닫아 `A`가 `contested`가 된다. | PLANNED_RETAINED |
| X31 | S137-S140 | 마법을 발명한 자가 예술가로 먼저 불리는 class inversion. 유행이 마을을 바꾸고 마법사 집단을 만들며, 소규모 허약한 artisan 집단은 주류에 이용당한다. 방랑 마법사/마법학원/귀족의 노예/직업 전환가 social branch로 분화한다. | R8-01, R8-04, R8-08, R5-07, H0-06; A/E/P | class가 `A`와 `E`에 동시에 쓰이고, refusal branch가 H0 route debt를 만들며, R8 밖 실습이 course record와 labor record를 갈라놓는다. | PLANNED_RETAINED |
| X32 | S141-S144 | 마법학원 학생이 protagonist가 될 수 있으나 유일한 canon은 아니다. 수련이 유전 marker를 활성화하고, 가문은 미정형 magic을 보존하며, 가문 magic는 특정 가문만 쓰는 access gate로 작동한다. | R8-03, R8-04, R8-07, R4-06; A/C/R | lineage 배정이 `C linked`와 `A contested`를 동시에 만들고, 거부하면 확산이 느리지만 institution 밖에서 진행된다. | PLANNED_RETAINED |
| X33 | S145-S148 | "이 magic를 쓸 줄 안다"는 innate title이 아니라 실전 숙련의 occupational speech다. 종이에 magic을 적신 뒤 자르는 craft가 baseline이며, positive theory label은 `R4` glossary slot에 비워 둔다. textile/scroll craft는 soft/constructive action family다. | R5-10, R5-01, R4-01, R8-04, H0-05; A/R/D | spell 이름이 `R4`과 `R8`에서 다르면 glossary conflict가 되고, 준비된 scroll이 실전 선택지가 되어 `E`를 소모한다. | PLANNED_RETAINED |
| X34 | S149-S152 | 가위로 빠르게 재단하는 combat weave, 종이접기 magic의 3D complexity/cost 우위, 허리춤 직물 조각이라는 world affordance, 전투 전 준비와 실전 선택을 하나의 action schema로 묶는다. | R5-10, R5-11, R5-01, R8-01, R6-07; D/E/A | prep와 improvisation이 다른 cost/state로 실행되고, fold 우위가 `R5-06` encounter signature를 바꾼다. | PLANNED_RETAINED |
| X35 | S153-S156 | 종이를 던지고 칼로 썰어 발동하는 field improvisation, 가위로 공허를 잘라 다른 층을 여는 void-cut, shape가 destination과 risk를 결정하는 authored geometric grammar, 차가운 것→용암 분출 같은 typed exchange를 만든다. | R5-12, R7-09, R8-06, R4-01, R6-01; C/E/R | portal shape가 contract 문서를 만들고, `contract_tally`이 `G8`에 해석을 요구하며, 오역된 shape가 `R4` canonical law를 다시 쓴다. | PLANNED_RETAINED |
| X36 | S157-S160 | James/observer entity처럼 arbitrary input에 mental attack output을 돌려주는, 예측 불가능한 material law 없는 존재. 고위 portal은 다른 차원 존재와 contract를 맺고, contract spell은 불발 확률이 낮고 구체적이며, 가위/칼날의 물리 구조가 공허를 자르는 비용과 안정성을 결정한다. | R7-09, R8-06, R5-12, R6-01, R4-02; C/P/R | 존재가 `B`를 `unclassified`로 밀고, contract가 deferred obligation을 남기며, 도구 구조가 `R5-12`/`R8-04`의 cost를 결정한다. | PLANNED_RETAINED |

### 11.3 Per-seed binding index

The unit row above supplies the local rule, cross-links, immediate consequence, and delayed consequence for every seed in that unit. This index prevents a range from hiding an unbound seed: each ID points to at least one concrete family or cluster where that seed is performed.

- A / X01–X03: S001 → R7-04 Crown Position; S002 → R7-07 Operator Replacement; S003 → R4-07 Operator Trial; S004 → R6-01 Organ Intake; S005 → R2-04 Same Body Census; S006 → R4-01 Translation Desk; S007 → H0-03 Return Hearing; S008 → R1-04 Continuation Trial; S009 → R1-02 Door Role Test; S010 → R7-01 Wall Phase Survey; S011 → R1-06 Registry Interrogation; S012 → R3-01 Intake Triage.
- B / X04–X05 (S013–S024): S013 → R3-02 Latency Bell; S014 → R3-02 Latency Bell; S015 → R1-06 Registry Interrogation; S016 → H0-05 Crier Thread; S017 → R2-05 Harvest Failure; S018 → R4-03 Public Hall Copy; S019 → R4-02 Contradictory Record; S020 → R5-02 Boot Sequence; S021 → R5-01 Boot Contract; S022 → R5-02 Boot Sequence; S023 → R5-06 Formation Failure; S024 → R5-06 Formation Failure.
- C / X06–X09 (S025–S036): S025 → R6-06 Body Authority Registry; S026 → R5-04 Name Hearing; S027 → R3-05 Mercy Engine Test; S028 → R6-05 Organ Chorus Trial; S029 → R6-03 Heart Petition; S030 → R3-06 Organ Complaint Hearing; S031 → R6-04 Debt Surgery; S032 → R2-04 Same Body Census; S033 → R2-05 Harvest Failure; S034 → R1-04 Continuation Trial; S035 → R7-07 Operator Replacement; S036 → R6-03 Heart Petition.
- D / X09–X11 (S037–S050): S037 → RC-06 Heart's Petition; S038 → R6-01 Organ Intake; S039 → H0-01 Arrival Docket; S040 → R6-04 Debt Surgery; S041 → R6-04 Debt Surgery; S042 → R5-04 Name Hearing; S043 → R4-03 Public Hall Copy; S044 → R4-07 Operator Trial; S045 → R3-01 Intake Triage; S046 → R2-08 Settlement Vote; S047 → H0-05 Crier Thread; S048 → H0-05 Crier Thread; S049 → R5-01 Boot Contract; S050 → R4-01 Translation Desk.
- E / X12–X15 (S051–S065): S051 → R7-07 Operator Replacement; S052 → R4-06 Crown Fragment; S053 → R4-07 Operator Trial; S054 → H0-03 Return Hearing; S055 → R7-04 Crown Position; S056 → R4-02 Contradictory Record; S057 → H0-01 Arrival Docket; S058 → R4-04 Weight Lift; S059 → R4-01 Translation Desk; S060 → R7-04 Crown Position; S061 → R2-05 Harvest Failure; S062 → R2-03 Root Bridge Survey; S063 → R2-04 Same Body Census; S064 → R2-01 Water Round; S065 → R2-08 Settlement Vote.
- F / X15–X18 (S066–S080): S066 → R2-01 Water Round; S067 → R2-07 Seed Vault Exchange; S068 → R2-08 Settlement Vote; S069 → R4-01 Translation Desk; S070 → R4-01 Translation Desk; S071 → R4-01 Translation Desk; S072 → R4-07 Operator Trial; S073 → R4-02 Contradictory Record; S074 → R4-01 Translation Desk; S075 → R4-03 Public Hall Copy; S076 → R7-01 Wall Phase Survey; S077 → R2-04 Same Body Census; S078 → R6-06 Body Authority Registry; S079 → R6-04 Debt Surgery; S080 → R6-04 Debt Surgery.
- G / X18–X22 (S081–S100): S081 → R6-06 Body Authority Registry; S082 → R6-03 Heart Petition; S083 → R1-04 Continuation Trial; S084 → R6-03 Heart Petition; S085 → R3-06 Organ Complaint Hearing; S086 → R5-04 Name Hearing; S087 → R6-05 Organ Chorus Trial; S088 → R3-05 Mercy Engine Test; S089 → R5-07 Labor Walkout; S090 → H0-06 Care Notice; S091 → R5-04 Name Hearing; S092 → R6-04 Debt Surgery; S093 → R2-05 Harvest Failure; S094 → R5-02 Boot Sequence; S095 → R3-02 Latency Bell; S096 → R2-05 Harvest Failure; S097 → R4-02 Contradictory Record; S098 → R6-01 Organ Intake; S099 → R4-06 Crown Fragment; S100 → H0-05 Crier Thread.
- H / X23–X26 (S101–S120): S101 → H0-01 Arrival Docket; S102 → R5-04 Name Hearing; S103 → R1-04 Continuation Trial; S104 → R6-03 Heart Petition; S105 → R5-05 Care Shift; S106 → R2-04 Same Body Census; S107 → R4-03 Public Hall Copy; S108 → R7-04 Crown Position; S109 → R2-08 Settlement Vote; S110 → R7-01 Wall Phase Survey; S111 → R1-02 Door Role Test; S112 → R6-05 Organ Chorus Trial; S113 → R5-04 Name Hearing; S114 → H0-05 Crier Thread; S115 → R1-01 Misreturned Person; S116 → R4-06 Crown Fragment; S117 → R2-03 Root Bridge Survey; S118 → R5-08 Partner Permission; S119 → H0-01 Arrival Docket; S120 → H0-05 Crier Thread.
- M1 / X27–X28 (S121–S128): S121 → R8-02 Concentration Registration; S122 → R8-04 Course Selection; S123 → R2-09 Disperser Reading; S124 → R7-01 Wall Phase Survey; S125 → H0-05 Crier Thread; S126 → R2-09 Disperser Reading; S127 → R2-10 Circulator Ledger; S128 → R3-01 Intake Triage.
- M2 / X29–X30 (S129–S136): S129 → R3-05 Mercy Engine Test; S130 → R7-01 Wall Phase Survey; S131 → R3-06 Organ Complaint Hearing; S132 → R6-01 Organ Intake; S133 → R8-05 Fold Failure Hearing; S134 → R8-08 Field Probation; S135 → R8-03 Lineage Placement; S136 → R8-03 Lineage Placement.
- M3 / X31–X32 (S137–S144): S137 → R8-01 Course Index; S138 → R8-04 Course Selection; S139 → R8-08 Field Probation; S140 → R5-07 Labor Walkout; S141 → R8-04 Course Selection; S142 → R8-03 Lineage Placement; S143 → R8-07 Lineage Refusal; S144 → R8-07 Lineage Refusal.
- M4 / X33–X34 (S145–S152): S145 → R5-10 Field Weave; S146 → R5-10 Field Weave; S147 → R4-01 Translation Desk; S148 → R5-10 Field Weave; S149 → R5-10 Field Weave; S150 → R5-11 Rigid Fold; S151 → R5-01 Boot Contract; S152 → R8-01 Course Index.
- M5 / X35–X36 (S153–S160): S153 → R5-12 Void Cut; S154 → R7-09 Void Cut Ledger; S155 → R7-09 Void Cut Ledger; S156 → R6-01 Organ Intake; S157 → R8-06 Void Contract Filing; S158 → R8-06 Void Contract Filing; S159 → R8-06 Void Contract Filing; S160 → R5-12 Void Cut.

### 11.4 Seed acceptance rules

각 seed의 구현 후 audit record는 다음을 반드시 채운다.

- seed ID와 transformation unit
- source intent
- TIN structural change
- local rule
- region/family/cluster binding
- cross-link A와 cross-link B
- immediate consequence
- delayed consequence
- generic-risk 결과
- implementation path
- rejected/dropped 사유와 대체 seed

raw sentence, 원작 고유 문구, source character name은 world asset에 복사하지 않는다. 이름·문장·배치를 바꿔도 local rule과 cross-link가 없는 candidate는 `CANDIDATE` 또는 `DROP`으로 audit하고, planned-retained count에 포함하지 않는다.

magic supplement seed에 대한 추가 gate:

- 각 magic seed는 기존 region family 하나와 기존 core NPC 하나 이상에 concretely binding되어야 한다. `R8`에만 묶이면 `unbound`다.
- 각 magic seed는 `res_*`(§5.5) 또는 `magic` record(§9.1)의 필드 중 하나 이상을 읽거나 쓴다. 둘 다 아니면 `unbound`다.
- 각 magic seed는 §4.4 표의 clock write를 하나 이상 가져야 한다. 축 write만 있고 clock write가 없으면 world에 압력이 없다는 뜻이므로 audit에서 탈락한다.
- magic theory의 positive label을 audit record에 적지 않는다. label은 `R4` glossary가Filing한 뒤에만 기록한다.

## 12. Handoff와 acceptance

- `H0`+`R1`~`R8`의 9개 node와 `E01`~`E18`의 18개 edge는 authored content manifest에서 같은 stable ID를 사용한다.
- region dossier의 family ID는 dialogue, document, encounter, object, route authored data가 함께 참조한다. core script는 region-specific ID를 하드코딩하지 않는다.
- 9개 event cluster(`HC-00`, `RC-01`~`RC-08`)는 각각 6~12 core NPC, 2~4 institutions, 2~3 clocks, partial truth, resource conflict, immediate/delayed write를 가진다.
- `RC-08`은 `07` §14.1의 A1 data-only 조건을 만족해야 한다. `R8` 추가 시 `changed_core_files == []`이어야 하며, 이 파일이 `R8` 때문에 새 system·새 enum·새 recovery type을 요구한다면 그건 A1 실패다.
- 모든 route gate에는 적어도 하나의 우회 edge와 하나 이상의 noncombat resolution이 있다. `E18`의 우회는 `R5` 왕복이며, `G5`가 `refused`일 때 `E18`이 닫히면 `R5` 내부 industrial permit craft가 그 대체다.
- 모든 region에는 최소 두 개의 state-driven revisit variant와 unresolved debt가 있다. `R8`의 두 affordance는 `E18` 왕복과 `course index return`이다.
- 네 axis와 여섯 pressure clock은 상시 HUD로 노출하지 않는다. signal은 world event·NPC·document·enemy tell·physical topology로 읽힌다. `concentration`도 예외가 아니다.
- `G8`은 world ending 자체가 아니라 world protocol의 precedence를 선택한다. ending/story 분해는 `03_STORY_AND_ENDINGS.md`가 소유한다.
- NPC schema, combat/target grammar, save codec, presentation, image brief는 각각 다른 plan file이 소유한다. 이 파일은 world state와 route content만 고정한다.
- 720p/FHD/QHD에서 physical route sign, focus object, encounter entry, map/request surface가 잘리지 않는지는 `10_TESTS_AND_ACCEPTANCE.md`에서 실제 실행으로 확인한다.

이 파일이 다른 plan 문서에 요구하는 반영은 2026-09-25에 완료됐다:

- **완료(2026-09-25).** `03` §10/`07` §6/`04` §4.2·§7는 9 cluster를, `03`/`04`/`05`/`07`은 `H0`+`R1`~`R8`·`E18`까지를 사용한다. 8 cluster·`R1–R7` 인용은 0건이다.
- `07` §7은 이미 7칸으로 갱신되었다. 6단계 축약 인용은 0건이며 정본은 7칸이다(§3.3).
- `06`은 §5.5의 magic resource key를 `res_*` registry에 등록하고, `06` §3.5.1의 `region_r8_folding_school`/§3.5.2의 `route_e18_folding_school_approach`와 이 파일을 1:1로 맞춘다. `gate_g9`는 만들지 않는다.
- `06`은 `magic` 하위 record 6종(`concentration_fields`, `body_load`, `circulation`, `crafts`, `contracts`, `glossary`)을 save projection allowlist에 넣고, `05`는 `FAM-ARPG-19`/`FAM-ARPG-02` 기반의 `ENC-ARPG-25`와 `region_role: magic_training_craft_labor`를 등록한다.
- `04`는 `R8`의 support resident(`Mira Vask` 등)에 `npc_20_*`~`npc_26_*` ID를 붙이되 canonical core roster 14는 늘리지 않는다. `R8`의 core NPC visitors는 §7.9가 열거한 7명이다.
- `12`는 §4.4/§5.5의 token(`disperser`, `circulator`, `concentration_field`, `medium`, `shape_or_pattern`, `tool_variant`, `contract_tally`)을 그대로 쓴다. 새 이름을 만들지 않는다.

## 13. 금지 shortcut

- region을 이동거리, 대기, 같은 combat 반복으로 늘리는 것.
- adjectives만 바꾸고 region causal write·resource flow·route gate를 복제하는 것.
- world map을 상시 HUD로 Always Visible하게 만드는 것.
- route gate를 `clue_found`, quest counter, 단일 dialogue flag만으로 구현하는 것.
- NPC가 knowledge를 공유한다고 가정하거나 이미 아는 해법을 다시 발견하게 만드는 것.
- one event가 모든 region의 clock·axis를 한꺼번에 덮어쓰는 것.
- seed를 이름·문장만 바꾸어 content family에 붙이는 것.
- recovery, clone, loop, checkpoint를 하나의 `respawn`으로 지우는 것.
- H0, R1, R2, R3, R4, R5, R6, R7, R8을 서로 다른 색의 동일한 combat room으로 만드는 것.
- 구현 전 image 생성/editing을 임의로 실행하거나 원작 자산을 가져오는 것.
- `E02`/`E04`를 `R2`/`R4`의 gate처럼 취급해서 인과를 뒤집는 것. 두 edge의 unlock은 `H0`에서 끝난다(§5.4.1, §5.4.2).
- `G9`를 만들어 `R8` 진입을 새 gate에 묶는 것. `E18`의 gate는 `G5`다.
- magic을 단일 MP/마나 막대로 축약하거나 `concentration_field`를 전역 위험 막대로 표시하는 것.
- magic theory 이름을 module script나 dialogue에 하드코딩하는 것. `glossary` slot이 비어 있으면 `untranslated term`으로 Filing한다.
- `R8` 추가를 핑계로 core system·loader·save codec·target enum을 수정하는 것. `changed_core_files == []`이 A1의 성공 조건이다.
- magic이 새 recovery type을 만들거나 `crown_alignment`를 recovery로 쓰는 것.
- `C`가 contract 하나로 전진하거나, 실패한 cast가 `K`·`P`·`R`을 동시에 전진시키는 것(§4.4).
