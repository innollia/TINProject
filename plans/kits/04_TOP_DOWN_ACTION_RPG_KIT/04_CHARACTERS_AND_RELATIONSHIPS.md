# Kit 04 — Characters and Relationships

## 큰 배경에서의 인물 분리 — 2026-09-26

[13](13_LAYERED_ENVIRONMENT_PRODUCTION.md)에 따라 플레이어, NPC, 동행자, 사건 대상의 변하는 몸은 배경에 굽지 않는다. dossier의 stable identity를 유지한 field sprite/portrait/상태 이미지를 독립 제작한다. 배우가 사라지거나 이동해도 같은 공간이 복원되도록 뒤쪽 환경을 완성한다.

가림은 배경의 명암이 아니라 접지 anchor와 authored depth로 정한다. 인물 손에 들린 물체와 바닥에 놓이는 물체는 소유권을 구분하고 중복 표시하지 않는다. 고정 의자·창구와 인물의 시점·크기를 함께 검수한다. 미정인 얼굴/의상/체형을 배경 샘플 안에서 임의 확정하지 않는다.

상태: executable design specification  
버전: 1.2 (`PLAN_RESOLUTION.md` 2026-09-25 + `R8 The Folding School` / magic layer 반영)  
소유 범위: **canonical core NPC roster 14명** + `R8` support resident(`npc_20_*`~`npc_26_*`, §2.4), relationship state의 authored 해석, character-authored action consequences, NPC↔magic craft role 매핑  
기준 Kit: Top-down Action-RPG Kit  
Primary Reference: BLACK SOULS 2 하나. 레퍼런스의 시스템·UX·콘텐츠 밀도만 사용하고 원작의 인물·대사·세계관·문구·자산은 사용하지 않는다.

## 0. 입력 경계와 소유 원칙

- 직접 입력: `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`, `docs/research/top_down_action_rpg/IDEA_LEDGER.md`.
- **분할 계획 중앙 해석:** `docs/research/top_down_action_rpg/PLAN_RESOLUTION.md`(2026-09-25). 이 해석의 canonical 결정은 아래 §0·§1.2·§2.1~§2.3에 in-line 되어 있으므로, 원본 파일이 이동하거나 없어져도 이 파일의 규칙은 self-contained하다. 문서 간 충돌은 추측으로 merge하지 않고 이 해석에 따라 re-key한다.
- `plans/kits/`에 별도 story-plan 파일은 확인되지 않았다. 따라서 이 파일은 이야기 순서, 최종 결말, 고정 파티 구성을 새로 canon으로 만들지 않는다. 이후 story owner가 생기면 stable NPC ID를 보존한 채 연결한다.
- **canonical world:** `02_WORLD_STATE_AND_ROUTES.md`의 **The Undersign Basin**. node는 `H0` 허브 + `R1`~`R8`을 쓴다. `R8 The Folding School`은 별도 우주가 아니라 `E4 The Concentration Layer` era의 authored module이며 진입 edge는 `E18`(gate `G5`) 하나다. `Marrowglass`, `Terminal Ledger Hall`, `Lower Switchyard`, `Crown Alignment Office`는 구버전/독립 초안이며 이 파일에서 사용하지 않는다. `Crown`은 `Crownwell Archive`의 `Crown of Continuance` object와 `Crown Protocol`로만 쓴다.
- **canonical magic model:** `12_MAGIC_THEORY.md`의 **concentration-mediated craft**. magic은 같은 world protocol의 implementation layer이지 별도 universe도, 새 축·새 clock·새 recovery type도 아니다. authored craft family는 weave/scroll, rigid-fold, void-cut/portal 세 가지이며 이론의 positive name은 `R4` `glossary` slot이Filing하기 전까지 정하지 않는다. `12`의 institution token(`MAG_ACADEMY`, `CIRCULATION_BOARD`, `LINEAGE_HOUSE`, `VOID_CONTRACT_COURT`, `FIELD_WEAVE_GUILD`, `WANDING_MAGE`)과 `02` §5.5의 `res_*` token, `02` §9.1의 `magic` record 6종만 쓴다. (`R8`의 school 측 authority 표기는 `02` §7.9의 `MAG_ACADEMY` curriculum office / `CIRCULATION_BOARD` / `LINEAGE_HOUSE` registrar / `VOID_CONTRACT_COURT` 4개다.)
- **canonical seed accounting:** core ledger `S001`~`S120` 120 unit(gate 72) + magic supplement `S121`~`S160` 40 unit(gate 24) = **160 unit, gate 96 distinct `PLANNED_RETAINED` transforms, preferred target 120**. 이 수치는 `02` §11.1이 소유한다. planning 단계의 모든 seed 상태는 `PLANNED_RETAINED`이며 `USED`/`TRANSFORMED` claim은 금지한다. 120/72/90 같은 이전 판의 분모·gate·preferred 수를 쓰지 않는다.
- **canonical core roster:** 이 파일 §3의 **14명 dossier가 유일한 canonical roster**다. `R8`을 추가해도 15번째 `npc_*` core actor는 만들지 않는다. `03`, `05`, `06`, `07`의 NPC 이름·ID는 이 14명으로 re-key한다(§2.3). `02`의 나머지 named resident는 **support resident**다. dialogue/resource/state port를 가질 수 있지만 canonical core roster 수에 들어가지 않으며 이 dossier를 대체하지 않는다. 예외는 하나뿐이고 그것도 승격이 아니다: `02` §7.9가 열거한 `R8 The Folding School`의 support resident 7명은 `npc_20_*` ID를 갖고 `06` §5.11의 `roster_kind: "support"`로 등록한다(§2.4). `role_field_investigator`는 player role ID이지 NPC ID가 아니다.
- **canonical relationship state:** `06_AUTHORED_CONTENT_AND_DATA.md` §5.7의 `rel_*.states[]` + discrete state. 이 파일의 trust/fear/debt/recognition/attachment/agency는 **state transition의 입력·보조 축**이고, 이 파일의 `stance`는 **presentation label**이며 canonical state를 대체하지 않는다(§1.2).
- **canonical axis/clock token:** `02_WORLD_STATE_AND_ROUTES.md` §3/§4. 축은 `protocol_legitimacy` / `recognition_drift` / `continuity_pressure` / `resource_scarcity`, clock은 `institutional_response_clock` / `contamination_clock` / `public_record_clock` / `resource_collapse_clock` / `personal_collapse_clock` / `crown_alignment_clock` 6개로 닫힌다. `07`의 `CL-INST/CL-CONT/CL-REC/CL-RES/CL-PER/CL-CROWN`는 이 6개의 표기다. `recognition_drift`와 `continuity_pressure`는 clock이 아니라 축이다.
- 아래 이름은 이 dossier를 위해 새로 작성한 working names다. 메모의 이름·문장·고유 표현을 복사하지 않는다. `Sxxx`는 메모에서 가져온 아이디어의 식별자일 뿐, 대사 원문이 아니다.
- 이 파일은 캐릭터와 관계의 source of truth다. region, encounter, combat, save, presentation 파일은 여기서 NPC ID와 action consequence를 소비하되, 이 파일의 사건 결과를 임의로 덮어쓰지 않는다.
- dialogue는 상태를 설명하는 exposition가 아니라 pressure surface다. NPC의 선택, 서비스, 이동, 거부, 전투, 치료, 기록 조작, 자원 분배가 실제 state transition을 만든다.
- 모든 NPC는 대사 전용이 아니다. 각 NPC는 최소 하나의 system port를 소유하며, 생존·사망·부재가 field, access, resource, record, combat, relationship 중 하나 이상을 실제로 바꾼다.

## 1. 공통 Dossier 계약

### 1.1 필수 필드

각 stable ID는 다음 필드를 모두 가져야 한다. 이 목록은 `06_AUTHORED_CONTENT_AND_DATA.md` §5.11 `NpcDefinition`의 authoring source다. content 구현은 06의 JSON schema를 따르고, 이 절은 그 schema를 채우는 서술 규칙만 소유한다.

- `id`: content와 save가 함께 사용하는 영구 ID. 표시 이름을 바꾸어도 ID를 바꾸지 않는다.
- `seed_ids`: `IDEA_LEDGER.md`의 seed ID. 범위 표기 `S020–S023`는 각 ID에 같은 구조 변환을 적용한다는 뜻이다. core ledger는 `S001`~`S120`, magic supplement는 `S121`~`S160`이며 두 범위를 한 목록에 섞지 않고 나누어 적는다. magic seed는 §2.6의 binding 표에 있는 core NPC가 실제로 수행한다.
- `public_role`: 외부에서 즉시 판별되는 직업·사회적 기능.
- `private_role`: 공개되지 않은 이해관계, 개인의 목적을 감추는 역할, 후반에 뒤집힐 수 있는 기능.
- `desire`: NPC가 자신의 언어로 goal을 설명하지 않아도 행동을 통해 반복해서 드러내는 욕구.
- `fear`: 회피·부재·폭발·기록화로 나타나는 공포.
- `contradiction`: desire와 institutional behavior 또는 public/private role이 충돌하는 지점.
- `capability`: 플레이어가 관찰할 수 있는 능력. 대사 설명이 아니라 service, movement, combat, sabotage, care, record operation으로 표현한다. 06의 `capability.port_ids`는 비어 있을 수 없다.
- `resource_access`: 접근 가능한 자원, 접근을 얻는 조건, 회수하거나 잃을 수 있는 조건.
- `knowledge_boundary`: NPC가 실제로 아는 범위와 deliberately 모르는 범위. player knowledge와 공유하지 않는다. 06의 `knows` / `does_not_know` / `never_learns`는 `seed_*`만 쓴다.
- `relationship_states`: 이 NPC가 participate하는 `rel_*.states[].state_id`와 각 state로 **어떤 concrete action이 전이시키는지**의 서술. state 자체의 canonical 정의는 `06`가 소유한다(§1.2). 빈 목록이면 `npc_without_relationship` warning 대상이다. dossier 본문의 `stance` 단어(`wary`, `conditional_trust`, `trusted` 등)는 §1.2.3의 presentation label이며 canonical 위치가 아니다.
- `transition_inputs`: trust/fear/debt/recognition/attachment/agency의 authored 값과 그 값이 `rel_*.axes`, `rel_*.axis_rules`, world 축 중 어디에 landing하는지(§1.2.2).
- `speech_pressure`: 어떤 압박에서 말이 짧아지거나, 침묵하거나, category를 바꾸는지.
- `silence_lie_pattern`: 사실이 아닌 것을 말하는 방식과 침묵의 기능.
- `interaction_verbs`: content authoring이 호출하는 안정된 action ID. 각 verb는 precondition, immediate result, delayed result, failure result를 가져야 한다. 06의 `interaction_verbs[].opens`는 `conv_*` / `doc_*` / `enc_*`를 가리킨다.
- `combat_or_encounter_profile`: 전투가 필요한 경우 같은 NPC identity가 어떤 combat/noncombat state로 전환되는지. NPC-boss는 이름 없는 별도 entity가 아니다.
- `survival_death_removal_result`: 살아남는 조건, death가 개인에게만 적용되는지, role/record가 남는지.
- `absence_result`: NPC가 죽지 않고 떠난 경우에도 누락이 상태로 남는다는 규칙. 06의 `absence.kind`는 `permanent` / `route` / `conditional` / `none`으로 닫힌다.
- `one_off_dialogue_seeds`: 특정 NPC·상태에만 쓰는 one-off beat의 seed ID와 action premise. `ledger_usage_class == "ONEOFF"`인 seed만 쓴다. 통합 규칙은 §1.5.
- `faction_institution_links`: NPC가 소속되거나 통제하거나 거래하거나 경쟁하는 기관. token은 `02`의 canonical authority만 쓴다(§2.1).
- `romance_affection_arc`: 선택 가능한 affection/romance/chosen-family 경로와 그를 여는 행동. §4.4의 금지 규칙을 따른다.
- `body_horror_identity_arc`: organ, clone, surgery, transformation, recognition split이 self와 social identity에 미치는 state 변화. §4.5를 따른다.
- `clock_links`: 이 NPC가 직접 움직이는 pressure clock. `02` §4의 6개 중 실제 움직이는 것만 쓴다. 축(`recognition_drift`, `continuity_pressure`)을 clock 칸에 넣지 않는다. 전역 하나의 danger bar로 합치지 않는다.
- `cross_links`: 다른 NPC·region·system과 연결되는 stable ID. 2개 이상.

### 1.2 Relationship state

relationship는 단일 호감도 숫자가 아니다. 이 절은 `06_AUTHORED_CONTENT_AND_DATA.md` §5.7 `RelationshipStateDefinition` 위에서 **authoring 해석만** 더한다. schema·enum·검증 오류 소유권은 `06`에 있다.

#### 1.2.1 canonical state = `rel_*.states[]`

- relationship의 "현재 위치"는 오직 `rel_*.states[].state_id` 하나로 표현된다. 이 파일은 그 값의 이름을 다시 만들지 않는다.
- `states[]`는 1~10개, `order`는 0부터 **연속**이며, `start_state_id`는 `order == 0`이어야 한다. `start_state_id` 이외의 state는 incoming transition이 1개 이상 필요하다.
- 전이는 DAG다. `is_irreversible` 전이가 있으면 되돌아가는 edge를 **반드시** 하나 둔다. cycle은 `relationship_cycle` error다.
- `exclusions.max_final_state == 1`이면 sink는 정확히 1개. 여러 final state를 동시에 열어 두지 않는다.
- `transitions[].via`는 `choice` / `effect` / `encounter_outcome` / `clock_stage` / `recovery` / `absence`로 닫힌다. `via == "choice"`이면 `requires_condition`에 `choice_taken` leaf가 `conversation_id` + `choice_id`로 **반드시** 들어간다.
- 한 NPC가 여러 관계를 가질 수 있다. 이 파일의 14명은 각자 1~4개의 `relationship_ids`를 가지며 각 관계는 별도 `rel_*` 파일이다.
- `states[].label`과 `states[].dialogue_policy`가 화면 문구를 만든다. 둘 다 presentation이며 world state를 바꾸지 않는다.
- **state instance 표기의 owner:** `rel_*` 파일의 `state_id` 문자열은 `03` §12.1이 제안한 `rs_<npc snake>_<state>` 형태의 authored instance를 그대로 쓴다. `03`이 "어떤 state가 어떤 ending·cluster·truth를 여는가"를 소유하고, `04`는 "어떤 action이 그 state로 전이시키는가"를 소유한다. 두 파일이 다른 문자열을 쓰면 `relationship_state_id_mismatch`로 잡힌다.
- **dossier가 state를 지칭할 때의 금지:** `04` §3의 dossier는 `rs_*` ID를 그대로 쓴다. `stance` 단어를 state로 부르거나, `wary`/`conditional_trust` 같은 presentation label을 precondition·gate·조건으로 쓰지 않는다. NPC 간 관계를 정성 서술("서로 신뢰한다")로만 남기고 `rs_*` state와 대응 verb를 적지 않는 것은 `unbound_relationship`다.

#### 1.2.2 transition inputs = 6개 보조 축

이 파일의 여섯 값은 **canonical state가 아니다.** state가 왜 지금 그 위치에 있는지를 설명하고, 다음 전이가 어떻게 authored되어야 하는지를 입력한다. `06` §5.7에 따라 `rel_*.axes`는 조건을 정의하는 authority가 아니며 `transitions[]`가 authority다. 축 값은 world 축보다 항상 약하다.

| 이 파일의 축 | landing 위치 | 범위 | 성격 |
|---|---|---|---|
| `trust` | `rel_*.axes.trust` | int -3..3 | NPC가 player의 다음 행동을 예측 가능한 위험으로 보는 범위 |
| `fear` | `rel_*.axes.fear` | int -3..3 | refusal·압박·증가가 언제 발생하는지 |
| `debt` | `rel_*.axes.debt` | int -3..3 | 물질·정보·신체·인정 빚. 반감은 player가 행동을 반복해야 한다 |
| `recognition` | `rel_*.axes.recognition` | int -3..3 | NPC가 player를 `category` / `person` / `subject` / `object` / `distributed_self` 중 무엇으로 부르는지 |
| `attachment` | `rel_*.axes.attachment` | int -3..3 | care / chosen_family / `romance_open` / `romantic_commitment`의 진행 |
| `agency` | **`rel.axes` 밖에 둔다** | int -3..3 (authored) | NPC가 자기 신체·기억·role·선택을 결정할 수 있는 정도 |

- `06`의 `rel_*.axes`는 `trust` / `fear` / `debt` / `recognition` / `attachment` **정확히 5개** key로 닫혀 있다. `agency`를 여섯 번째 key로 추가하지 않는다. `06` schema를 열면 Kit 전체 schema bump가 되므로 `agency`는 `npc_state` op(`state_key` / `acting_role` token)과 world 축 write로 landing시키고 dossier 서술로 남긴다.
- 여섯 값이 **world**에 미치는 영향은 `rel_*.axis_rules[]`로만 나간다. `axis_rules[].condition`은 `06` §4.2 `Condition` leaf를 쓰고, `axis_rules[].sets`는 `02` §3의 네 world 축(`protocol_legitimacy` / `recognition_drift` / `continuity_pressure` / `resource_scarcity`)에만 int -3..3을 쓴다. 관계 점수가 world 축을 간접 조정하는 유일한 통로다.
- 여섯 값은 조건으로 읽지 않는다. 관계 축을 읽는 condition leaf는 `06`에 없고, 추가하면 schema bump다. 따라서 `requires_condition`은 `relationship_is` / `relationship_visited` / `choice_taken` / `clock_irreversible` 같은 leaf로만 쓴다.
- `last_cause`: 가장 최근 state를 바꾼 concrete action. 대사 인용이 아니라 verb ID와 `eff_*` ID를 기록한다. 06에 전용 key가 없으므로 `transitions[].effect_ids`가 그 기록을 겸한다.
- `irreversible`: `transitions[].is_irreversible`와 1:1로 대응한다. relationship와 world state는 다른 축이다.

#### 1.2.3 `stance`는 presentation label

- `stance`는 `unmet`, `wary`, `transactional`, `conditional_trust`, `trusted`, `committed`, `fractured`, `hostile`, `institutionalized`, `absent`의 **표시용 이름**이다.
- `stance`는 `states[].state_id`의 alias가 아니다. 두 집합은 서로 다른 크기·다른 단어열이며 일대일 대응을 요구하지 않는다.
- `stance`는 save되지 않고, 조건·gate·precondition으로 쓰이지 않으며, `dialogue_policy`(`guarded` / `operational` / `candid` / `hostile` / `absent`)를 대신하지 않는다. 06의 `dialogue_policy`가 canonical presentation 축이다.
- presentation은 `state_id`를 읽어 `stance`를 **파생**해 표시한다. 표시가 world state를 바꾸지 않는다(`02` §9.2 write 순서 7).
- NPC가 player를 부르는 호칭(address)은 `recognition` 축과 `states[].dialogue_policy`에서 나오며 `stance`에서 나오지 않는다.

### 1.3 Action-to-state 규칙

모든 interaction verb는 다음 순서를 따른다.

1. precondition을 확인한다.
2. field, service, combat, resource, record, body state 중 하나에 immediate effect를 적용한다.
3. pressure clock을 독립적으로 갱신한다.
4. relationship를 갱신한다. **먼저** `transitions[]`로 `state_id`를 옮기고, **그다음에** `axis_rules[]`로 world 축을 쓴다. `state_id`가 안 바뀌는 verb는 world 축을 직접 쓰지 않는다.
5. delayed consequence를 authored state로 등록한다.
6. cancel, refusal, failure, absence가 별도 결과를 가진다.

NPC가 lore를 설명하는 선택지보다 다음을 우선한다.

- `ASK`: partial knowledge를 제공하거나 knowledge boundary를 드러낸다.
- `SHOW`: 증빙을 통해 recognition 또는 access를 바꾼다.
- `WORK`: 자원과 시간으로 세계 상태를 바꾼다.
- `REFUSE`: 관계와 institutional record를 손상시키면서도 NPC의 self를 지킨다.
- `PROTECT`: 대상의 생존 또는 현재 self를 선택하고 다른 경로의 비용을 확정한다.
- `DEFEAT`: combat state를 끝내되 상대의 role, record, body authority를 자동으로 없애지 않는다.
- `LEAVE`: NPC가 field를 떠날 때 absence consequence를 남긴다.

### 1.4 Seed transformation 기록

이 파일에서 `seed_ids`로 표시한 idea는 이름만 바꾸어 사용하지 않는다. 각 범위 또는 ID 묶음에는 다음 기록을 남긴다.

- source intent: ledger seed가 제공한 최소 구조.
- TIN structural change: memo의 surface가 아닌 상태·절차·인정·자원 규칙으로 바꾼 부분.
- local rule: NPC 또는 institution 내부에서 실제로 지켜지는 규칙.
- system/region/NPC binding: 어느 port가 이 rule을 실행하는가.
- cross-link A/B: 다른 system, NPC, clock, region 중 두 곳 이상.
- immediate consequence: 현재 field에서 보이는 변화.
- delayed consequence: 재방문·route·relationship·recovery에서 다시 등장하는 변화.
- generic-risk test: 이름만 바꾸면 generic해지는지, NPC의 구체적 action이 필요한지.

### 1.5 One-off dialogue 통합 규칙

one-off beat는 별도 quest가 아니다. 다음 규칙으로만 통합한다.

- **허용 class:** `one_off_dialogue_seeds`에 들어가는 seed는 `IDEA_LEDGER.md`의 `ledger_usage_class`가 **`ONEOFF`(특정 NPC 대사/단발 scene) 또는 `TONE`(dialogue/log/format/voice 전용)** 둘 중 하나여야 한다. `ROOT`/`SYSTEM`/`MODULE` class seed는 dialogue beat의 대사로 쓸 수 있지만 이 목록에 넣지 않는다. 그런 seed는 해당 dossier의 `seed_ids`와 `Seed transformation record`에 남기고, dialogue가 필요하다면 그 surface는 `TONE`/`ONEOFF` seed로 따로 authoring한다. (구버전 판의 "`ONEOFF`만 허용" 규칙이 `S044`, `S078`, `S010`, `S015`, `S042`, `S079`, `S035`, `S040` 같은 `SYSTEM`/`MODULE` seed를 목록에 강제로 남겼던 부작용을 제거한다. `06` §5.14의 `replacement_seed_id` class 규칙(`TONE`/`ONEOFF` 허용)도 같은 기준을 쓴다.)
- **로컬성:** `ledger_usage_class == "ONEOFF"`인 seed는 `bindings`에 `npc` 또는 `prop` kind를 **정확히 1개**만 가진다. 두 개 이상이면 `oneoff_binding_not_local` error다. 이 파일의 `one_off_dialogue_seeds`도 NPC당 1개 surface로만 등록한다.
- **참조 수:** 하나의 one-off seed를 참조하는 `conv_*`는 최대 1개다. 2개 이상이면 Stage 4 `oneoff_overused` warning이며 plan 단계에서 통합한다.
- **표면:** one-off은 최소 2개 surface를 만든다 — (a) `conv_*` page 또는 choice, (b) 그 page가 `opens` 또는 `entry_condition`으로 여는 `doc_*` / `prop_*` / `enc_*` / `eff_*` 중 하나. dialogue 한 줄로 끝나는 one-off은 없다. 두 surface가 서로 다른 kind여야 한다(`conv_*` + `conv_*`는 1개 surface로 센다).
- **page 예산:** one-off이 여는 `doc_*`는 `06` §5.14의 `reading.max_lines_per_page = 9`를 넘지 않는다. overflow는 `document_page_overflow` validation error다.
- **전이:** one-off beat는 `rel_*.transitions[]` 또는 `eff_*.operations` 중 하나에 연결되어야 한다. `stance` label이나 dialogue flag만 남기고 어떤 state도 바꾸지 않는 one-off은 금지다.
- **not-a-climax:** one-off은 conversation climax이 아니다. action, field, document, aftermath 중 어느 것으로 실행되는지가 dossier에 명시되어야 한다.
- **재사용 금지:** one-off seed를 두 NPC에 배정하지 않는다. 여러 NPC가 같은 one-off을 "공유 장면"으로 받으면 각 NPC에 별도 seed를 authoring한다.
- **노드 배정:** 각 one-off은 §2.1의 node 배정과 §4.3의 cluster 배치 양쪽과 모순되지 않아야 한다. one-off은 단일 NPC·단일 node에 묶이며, cluster 전체를 대신하지 않는다.
- **support resident one-off:** `R8` support resident(§2.4)의 one-off beat도 위 규칙을 그대로 따른다. 단 §4.2의 cluster participant로 세지 않고, 그 resident가 실행하는 surface는 §2.1의 두 번째 port를 가진 **core NPC의 verb ID**로 기록한다.

## 1.6 Resource 표기 규칙 (AP 없음, mana 한 개 없음)

- **`AP` resource를 만들지 않는다.** `A~H`의 AP label 의미는 미확정이므로 `PLAN_RESOLUTION` §3에 따라 combat player band에 AP를 노출하지 않고, NPC dossier도 "행동당 비용", "action point", "AP pool" 같은 resource를 `resource_access`나 `interaction_verbs`에 쓰지 않는다. 진행 비용은 `01`이 소유하는 `turn_cost` int `0..5`로만 표현한다(`0`: no-turn, `1`: normal command, `2..5`: committed action + locked window). `0`은 action slot을 소비하지 않는다.
- **combat resource는 3개 vocabulary만 쓴다:** `hp`, `mp`, `equipment_charge`. dossier가 combat HP/MP를 resource access의 조건으로 쓰지 않는다.
- **field/world resource는 `02` §5.5의 `res_*` token만 쓴다.** 이 token은 combat resource가 아니며, dossier는 `world.resources`의 수량에 직접 접근한다고 쓰지 않고 "region이 X를Filing하면 access가 열린다"로 쓴다.
- **magic resource:** `concentration_sample`, `medium_blank`, `fold_sheet`, `blade_credit`, `disperser_charge`, `circulation_slot`, `craft_credit`, `lineage_token`은 수량 `res_*`이고, `contract_tally`과 `labor_pledge`는 `amount`가 없는 비수량 debt key다(`02` §5.5). dossier는 이 구분을 유지하며 "빚을 갚으면 통과" 같은 수량 취급을 하지 않는다.
- **단일 `mana` 수치 resource를 만들지 않는다.** 농도는 `magic.concentration_fields`의 region/path/action 단위 측정값이며 축도 clock도 아니다. NPC의 `Capability`/`Resource access`는 "농도 수치"가 아니라 측정·배분·등급 판정 권한으로 쓴다.
- **`magic` record와 `res_*`를 한 namespace에 복제하지 않는다.** `shape_or_pattern`/`tool_variant`/미해결 contract는 `magic.crafts`/`magic.contracts`에, 물질은 `world.resources`에 있다(`02` §9.1). dossier는 한 값을 두 곳에 적지 않는다.

## 2. Core cast topology

**아래 14명이 canonical core roster다.** `07`의 NPC binding, `06`의 `npc_*` 파일, `05`의 NPC conversion, `03`의 NPC 참조는 모두 이 표의 ID를 사용한다. roster 수는 14에서 시작·종료한다. dialogue-only NPC를 추가해 수를 맞추지 않는다. `R8 The Folding School`을 추가해도 15번째 `npc_*` core actor는 생기지 않는다 — `R8`은 기존 NPC에게 **두 번째 port**를 추가하고, 학교 자체의 actor는 `npc_20_*` support resident가 맡는다(§2.4).

마지막 열은 `E4 The Concentration Layer`에서 추가되는 magic craft role이다. `R8` port가 없는 NPC는 `-`이며, 이는 magic 권한이 없다는 뜻이 아니라 `RC-08`에서 이 NPC가 학교 측 surface를 **직접 소유하지 않는다**는 뜻이다. 두 번째 port는 home region port를 대체하지 않는다.

| ID | working name | primary system port | institutional base (`02` canonical) | immediate action signature | magic/craft 두 번째 port (`RC-08`) |
|---|---|---|---|---|---|
| `npc_01_ilyra_senn` | Ilyra Senn | archive inquiry and record correction | Crownwell Archive — `Record Office` (R4) | index, withhold, reclassify | `R4-01` glossary 선점/충돌 — 학교 이름과 archive 번역 중 canonical precedence를 누가 정하는가 |
| `npc_02_orrin_kest` | Orrin Kest | recovery intake and continuity testing | `Return Registry` (R1), `Exchange Registrar` (H0) | declare, shelter, release | - (미등록 craft 압수·인계는 `RC-08`의 원격 filed record로만 닿음) |
| `npc_03_veya_morcant` | Veya Morcant | category audit and legal exception | H0 `Exchange Registrar` appeal jurisdiction (`Return Hearing`), `Censor` (R4) | interrogate, challenge, sign exception | unregistered craft possession 감사 — `E18` seizure와 `A unlicensed` write |
| `npc_04_sable_halm` | Sable Halm | transformation support and maintenance | `Faith Engineering unit` (R3), `Glasswing Ordinal` / `Support Registry` (R5) | consent, allocate, patch | craft medium/execution space 배정 — `R5-10/11/12`와 `R8-04` course 선택 |
| `npc_05_nera_voss` | Nera Voss | organ negotiation and body consent | `Gristmarket Clinic` / `Organ Exchange` (R6) | listen, reallocate, veto | magic cure의 우회 비용 — `mana_profile`과 organ authority의 승인 경로 |
| `npc_06_tamas_quill` | Tamas Quill | translation and local-law authoring | `Translation Tribunal` (R4) | compare, choose, publish | magic term의 private version 유지 — `untranslated term`을 번역할지 남길지 |
| `npc_07_bryn_oskel` | Bryn Oskel | frontier route survey | `Boundary Survey` (R7), `Settlement Council` (R7) | mark, sample, seal route | `R7-09`/`Storm Verge` 미완성 void-cut 증거 — `R8` `Cut Chamber` 잔해와 같은 maker 확인 |
| `npc_08_meral_dune` | Meral Dune | water and survival allocation | `Water Council` / `Seed Vault keeper` (R2) | ration, divert, mobilize | `R2-09 Disperser Reading`/`R2-10 Circulator Ledger` — `concentration_field` 측정과 dispersal 배정 |
| `npc_09_perrin_lask` | Perrin Lask | identity registry and continuation naming | R3 `Care Union` continuation/guardian desk, `Record Office` (R4) | enroll, rename, hide | `R8-03 Lineage Placement`의 이름 없는 칸 — 가문 이름 대신 self-authored 이름 |
| `npc_10_juno_caster` | Juno Caster | public witness and rumor routing | `Crier Office` (H0), `Record Office` (R4) | forward, verify, withhold | 실패한 fold screenshot forwarding — `R8-05`의 public record가 학교 규제가 되는지 |
| `npc_11_cael_ren` | Cael Ren | successor continuity and recovery testing | `Return Registry` (R1), unaligned; `Crown Protocol` claim (R7-07) | index, refuse inheritance, choose history | - (lineage 배정의 대상이 될 수는 있으나 `RC-08`에서 craft port를 실행하지 않음) |
| `npc_12_ravenna_holt` | Ravenna Holt | crown alignment and legitimacy | `Crown Protocol` seat — H0 `Crown Well`, R4 `Crown Observatory`/`Operator Trial`, R7 `Crown Position` | petition, levy, defer crown | `contract_tally` 해석 위치(`crown_protocol` 안/ 밖)를 `G8`에 명시하도록 강제 |
| `npc_13_tovan_reed` | Tovan Reed | field triage and recovery workaround | `Gristmarket Clinic` (R6) field-care network, R1 `Cold Relay`/`Ash Garden` | triage, operate, carry | `mana_profile` field 판정과 emission failure triage (`R3-01` category) |
| `npc_14_eda_marrow` | Eda Marrow | labor mobilization and service refusal | `Labor Court` (R5), R3 `Care Union`, R2 `settlement delegates` | mobilize, strike, redistribute | 학교 밖 course record / labor record 분리 — `craft credit`을 foundry labour hour으로 옮길지 refusal로 남길지 |

이 14명은 고정 quest 순서가 아니다. route는 6~12명의 cluster로 조합한다(§4.2). 모든 NPC가 한 번에 만날 필요는 없고, 서로 만나지 않아도 각자의 action이 world state에 남는다.

### 2.1 Downstream integration mapping

이 매핑은 `02_WORLD_STATE_AND_ROUTES.md`와 `07_REFERENCE_GAME.md`가 사용하는 node·authority·clock 표기를 이 dossier의 stable ID와 연결한다. 매핑은 이름의 복사본이 아니라 authored port의 참조다. **authority token은 아래 표에 있는 값만 쓴다.** 구버전 표기(`Crown Archive`, `INST_*`, `Office of the Vacant Seat`, `CROWN_ALIGNMENT_OFFICE`, `Marrowglass`, `Terminal Ledger Hall`, `Lower Switchyard`)는 사용하지 않는다. `R8`의 학교 측 authority token(`MAG_ACADEMY` curriculum office, `CIRCULATION_BOARD`, `LINEAGE_HOUSE` registrar, `VOID_CONTRACT_COURT`)도 `02` §7.9/§9.3에 적힌 문자열만 쓴다.

`02` §9.3의 write ownership과 1:1로 맞아야 하는 port:

| NPC | primary node | secondary node | `02` write owner (§9.3) | clock (`02` §4) | `RC-08`에서 닿는 `R8` region state |
|---|---|---|---|---|---|
| `npc_01_ilyra_senn` | R4 | R7, H0 | R4 `Record Office` — canonical translation과 public category | R, I, C | `glossary` 선점/충돌 |
| `npc_02_orrin_kest` | H0 | R1 | R1 `Return Registry` — recovery lineage과 door recognition / H0 `Exchange Registrar` — arrival category와 route permission | I, R, K | filed record 수신 |
| `npc_03_veya_morcant` | H0 | R3, R4 | H0 `Exchange Registrar` — appeal, 또는 R4 `Censor` — contradictory copy 관리 | I, R, C | `E18` seizure / `A unlicensed` |
| `npc_04_sable_halm` | R3 | R5, R1 | R5 `Glasswing Ordinal` / `Labor Court` — boot result, labor status, transformation capability | P, I, E | course 선택 가능 목록, `craft_credit` 배분 |
| `npc_05_nera_voss` | R6 | R3, R1 | R6 `Gristmarket Clinic` / `Organ Exchange` — organ authority, cure debt, replacement outcome | P, K, E | organ residue 회수 대상 |
| `npc_06_tamas_quill` | R4 | H0, R7 | R4 `Translation Tribunal` — canonical translation과 public category | R, I, C | 학교 이름 vs 번역 conflict |
| `npc_07_bryn_oskel` | R7 | R1, R2 | R7 `Boundary Survey` — topology와 crown alignment input | C, K, E | `Cut Chamber` 잔해 동일 maker 증거 |
| `npc_08_meral_dune` | R2 | R6, R7 | R2 `Water Council` / `Seed Vault keeper` — resource buffer와 settlement category | E, C, I | `concentration sample` provenance 공급 |
| `npc_09_perrin_lask` | R3 | R1, R4 | R3 `Care Union` naming, R4 `Record Office` school-copy filing | R, P, I | `lineage_token` 배정표 |
| `npc_10_juno_caster` | H0 | R4, R7 | H0 `Crier Office` — public thread; R4 `Record Office`와 canonical copy 경쟁 | R, I, K | failed fold screenshot, contract 공개 |
| `npc_11_cael_ren` | H0 | R1, R2, R7 | R1 `Return Registry` lineage; R7-07 `Operator Replacement`에서 operator claim 제출 | C, R, P | 없음(배정 대상일 뿐) |
| `npc_12_ravenna_holt` | R7 | R4, H0 | `Crown Protocol` — `crown_precedence`, `operator_id`, `crown_object_phase`만 | C, I, R | `contract_tally` 해석 위치 명시 |
| `npc_13_tovan_reed` | R1 | R6, R3 | R6 `Gristmarket Clinic` field overflow / R1 `Return Registry` triage signature | P, K, E | `mana_profile` category |
| `npc_14_eda_marrow` | R2 | R5, R3, R6 | R5 `Labor Court` labor status, R3 `Care Union` care labor, R2 `settlement delegates` | E, I, P | course record / labor record 분리 |

- clock token은 `02` §4의 6개로 닫힌다. 축 `recognition_drift`와 `continuity_pressure`는 이 표에 들어가지 않으며 필요하면 `axis_rules[].sets`의 world 축으로만 쓴다. `concentration`, `mana_profile`, `craft_credit`도 축이 아니다.
- `crown_alignment`은 recovery type이 아니라 world write다. `npc_12`는 `G8`에서만 operator 설치를 commit한다. `R8`은 `crown_precedence`에 제안할 수 없고 제안은 `R4` `glossary`와 `R7` contract 문서를 통해서만 들어간다.
- `R8`의 curriculum/lineage/concentration 등록은 gate가 아니다. `E18`의 gate는 `G5` 하나뿐이고 `G9`를 만들지 않는다.
- 통합자는 관계 축과 world 축을 하나의 숫자 점수로 합치지 않는다.

### 2.1.1 `R8` 두 번째 port의 write 제한

- `R8` support resident(§2.4)는 §2.1 표의 core NPC가 **아니므로** §9.3의 write owner가 아니다. 그들이 쓰는 것은 `02` §9.3이 `R8`에 배정한 4개 authority의 field뿐이다: `MAG_ACADEMY` curriculum office = `course index`/`student status`/`craft credit`, `CIRCULATION_BOARD` = `concentration_field` 측정과 dispersal 배정, `LINEAGE_HOUSE` registrar = `lineage_token`, `VOID_CONTRACT_COURT` = `contract_tally`과 contract 문서.
- core NPC가 `RC-08`에서 실행하는 동기는 위 field에 대한 **청원·감사·재분류·철회**다. 즉 `npc_01`은 glossary를 선점하지 *않고* `R4-01` 번역으로 선점 여부를 이긴다. `npc_14`는 `craft_credit`을 만들지 *않고* 그 credit을 `R5` labour hour으로 옮길지 거부한다. `npc_09`는 `lineage_token`을 발급하지 *않고* 배정표의 이름 없는 칸을 열어 self-authored name을 넣는다. `npc_07`은 `contract_tally`을 만들지 *않고* `R7-09` 잔해와 `R8` 잔해가 같은 maker인지 filed record로 남긴다.
- 따라서 `R8`은 `R8` 추가가 core system을 건드리지 않는다는 A1 조건(`changed_core_files == []`)을 dossier 수준에서 유지한다. NPC가 새 verb를 요구할 때 그 verb는 기존 7개 target mode·기존 6개 clock·기존 `res_*`만 쓴다.

### 2.2 Cluster membership 규칙 (6~12)

- authored cluster는 9개가 전부다: `HC-00` + `RC-01`~`RC-08`(`02` §8). 이전 판의 "authored cluster 8개" 서술은 폐기되었다.
- authored cluster 하나는 **6~12 core NPC**, 2~4 institutions, 2~3 clocks, partial truth, resource conflict, immediate consequence, delayed consequence를 가진다.
- membership은 **이 14명 중에서만** 뽑는다. support resident는 core NPC 수에 포함하지 않되, §1.1의 port를 가진 채 그 NPC의 region family에 붙어 있을 수 있다. `RC-08`에서도 예외가 아니다 — 학교 측 7명은 filed record·remote service·route evidence로만 참여한다.
- 모든 참여자가 한 장소에 모일 필요는 없다. shared record, remote service, absence, death, body/role change로 영향을 전달하며, field 재방문으로 확인 가능해야 한다.
- cluster 결과는 dialogue 한 줄이 아니다. 최소 한 field/object/NPC/resource/record/route surface와 한 non-dialogue domain surface가 함께 변해야 한다.
- retained seed 하나는 cluster 안에서 최소 두 개의 cross-link를 가져야 한다. 한 NPC에만 묶이면 `unbound`다. magic supplement seed는 `R8` family에만 묶여도 `unbound`이며(`02` §11.4), `RC-08`은 `R4`/`R5`/`R2`/`R7` surface를 함께 건드린다.
- 실제 cluster별 membership 표와 one-off 배치는 §4.2/§4.3이 소유한다.

### 2.3 Cross-plan conflict register와 re-key 결정

`PLAN_RESOLUTION.md` §2에 따라 **이 파일의 14명 ID·verb·absence result가 character canonical**이다. 아래 re-key 표는 2026-09-25에 반영 완료됐으며, 각 owner 파일의 canonical 참조는 이 표를 따른다.

**구버전 표기 → canonical ID:**

| 구버전 출처 | 구버전 표기 | canonical ID |
|---|---|---|
| `03` §11/§12 | `NPC_IONA_VEY`, `REL_IONA_*` | `npc_01_ilyra_senn` |
| `03` §11 | `NPC_NERA_KEST` | `npc_11_cael_ren` (social continuity 분리 clone). organ broker 이름은 `npc_05_nera_voss`와 **별개**다 |
| `03` §11/§12 | `NPC_SABLE_ORR`, `REL_SABLE_*` | `npc_06_tamas_quill` (private neural dialect → lexicon/private term port). transformation support는 `npc_04_sable_halm` |
| `03` §11/§12.3 | `NPC_MARA_VELL`, `REL_MARA_*` | `npc_05_nera_voss` |
| `03` §11 | `NPC_OREN_VALE` | organ disagreement surface는 `npc_05_nera_voss`의 organ quorum verb. 별도 actor로 만들지 않는다 |
| `03` §10/§11 | `NPC_LIO_FEN` | `npc_09_perrin_lask` (continuation/guardian naming) |
| `03` §10/§11 | `NPC_RUSK_DELL` | `npc_10_juno_caster` (public thread/rumor). archive 원본 조작은 `npc_01_ilyra_senn` |
| `03` §10/§11 | `NPC_PELL_OAR`, `NPC_RHEA_SALT` | `npc_07_bryn_oskel` (route/boundary) |
| `03` §10/§11 | `NPC_HALE_SEN` | `npc_08_meral_dune` (resource/settlement) |
| `03` §10/§11 | `NPC_NIX_ORR` | `npc_10_juno_caster` |
| `03` §10/§11 | `NPC_ARDEN_ROOK` | `npc_01_ilyra_senn` |
| `03` §10/§11 | `NPC_TAMSIN_QUILL` | `npc_12_ravenna_holt` (`Crown Protocol` seat) |
| `03` §10/§11 | `NPC_ELI_MARLOW` | **support resident.** `npc_02_orrin_kest`의 intake surface로 재사용, `npc_*` ID 없음 |
| `03` §11 | `NPC_CALLA_ORN` | `npc_05_nera_voss`의 organ quorum surface. 별도 actor 금지 |
| `03` §11 | `NPC_THE_SURVEYOR` | `npc_07_bryn_oskel`의 outsider observation port. NPC로 세지 않고 `one_off_dialogue_seeds` / `TONE` surface로 실행 |
| `07` §2.1 | `role_field_investigator` | player role ID. NPC ID가 아니며 `npc_11_cael_ren`과 병합하지 않는다 |
| `07` §2.1 | `Marrowglass` | `02` §1의 **The Undersign Basin**으로 re-key |
| `07` §2.1 / `03` §21 open item | `npc_15_mira_vask` | `npc_20_mira_vask` (`roster_kind: support`). 15번 core 번호를 쓰지 않는다 → `core_roster_not_canonical` 방지 |
| `07` | `npc_15_*` (다른 어떤 R8 actor) | `npc_20_*`~`npc_26_*` support namespace(§2.4). core 번호 `npc_15`~`npc_19`는 비워 둔다 |
| `02` region residents (`R8`, §7.9) | `Mira Vask`, `Halen Osk`, `Iven Marrow`, `Turo Bex`, `Perri Lowe`, `Jano Fesk`, `Cael Orin` | **support resident with ID.** `npc_20_mira_vask`, `npc_21_halen_osk`, `npc_22_iven_marrow`, `npc_23_turo_bex`, `npc_24_perri_lowe`, `npc_25_jano_fesk`, `npc_26_cael_orin` (§2.4). core roster 수에 넣지 않는다 |
| `02` region residents (`R1`~`R7`, §7.1~§7.8) | `Tarin Vey`, `Orrin Slate`, `Pell Harrow`, `Mara Quill`, `Cato Nen`, `Sable Reed`, `Iven Moss`, `Anja Sol`, `Odo Nune`, `Nera Fold`, `Bel Karr`, `Tovan Rill`, `Lissa Mern`, `Rusk Vey`, `Fen Ors`, `Tala Reed`, `Mero Kett`, `Ione Silt`, `Brack Halm`, `Sava Lunt`, `Nell Vos`, `Marda Venn`, `Sera Kwon`, `Lio Tace`, `Orren Vey`, `Junip Roe`, `Eda Mor`, `Cal Sarn`, `Vell Orto`, `Neme Oris`, `Sef Anor`, `Ovel Tarn`, `Yuen Pall`, `Tallo Vey`, `Iri Sane`, `Moro Kest`, `Kade Orun`, `Neri Voss`, `Yara Pell`, `Ondra Slate`, `Bex Tarrow`, `Nim Hesk`, `Rhea Doss`, `Ivo Fenn`, `Tams Orro`, `Salla Rusk`, `Jun Oris`, `Rill Oran`, `Havo Pell`, `Miri Senn`, `Oda Vey`, `Hearth`, `Ovi Rusk`, `Nae Linden`, `Bero Tern`, `Ishi Vey`, `Sika Lund`, `Aven Dros`, `Low-Entropy Surveyor` | **support resident, ID 없음.** `npc_*` ID를 부여하지 않고 canonical core roster 수에 넣지 않는다. 이들은 `02` §7.1~§7.8의 resident 표기가 canonical이며 위 약칭(`Tarin`, `Anja`, `Odo`, `Marda`, `Sera`, `Lio`, `Orren`, `Cal`, `Vell`, `Kade`, `Yara`, `Ondra`, `Bex`, `Nim`, `Rhea`, `Ivo`, `Tams`, `Salla`, `Jun`, `Havo`, `Ovi`, `Nae`, `Bero`, `Ishi`, `Sika`, `Aven`, `Oda`)은 쓰지 않는다 |

결정 규칙:

- 위 표의 구버전 ID는 **새 NPC가 아니다.** root integrator가 approved mapping을 정한 뒤 `03` / `05` / `06` / `07` 표기를 갱신한다.
- mapping이 확정되기 전에도 구버전 ID와 canonical ID를 자동 병합하지 않는다. 서로 다른 stable ID가 실제로 다른 역할을 가리키면 둘 다 authored content로 유지하되 **support resident**로 분류한다(§0).
- `02`의 resident 이름과 14명의 성·surname이 우연히 겹쳐도 병합하지 않는다. 예: `02` R1 `Nera Fold` ≠ `npc_05_nera_voss` ≠ `npc_11_cael_ren`; `02` R4 `Moro Kest` ≠ `npc_02_orrin_kest`; `02` R5 `Neri Voss` ≠ `npc_05_nera_voss`; `02` H0 `Mara Quill` ≠ `npc_06_tamas_quill`; `02` H0 `Sable Reed` ≠ `npc_04_sable_halm`; `02` R2 `Brack Halm` ≠ `npc_04_sable_halm`; `02` R3 `Eda Mor` ≠ `npc_14_eda_marrow`; `02` R1 `Tovan Rill` ≠ `npc_13_tovan_reed`; `02` R6 `Miri Senn` ≠ `npc_01_ilyra_senn`.
- `R8` support resident도 같은 비병합 규칙을 따른다: `02` R8 `Iven Marrow` ≠ `npc_14_eda_marrow`; `02` R8 `Cael Orin` ≠ `npc_11_cael_ren`; `02` R8 `Cael Orin` ≠ `npc_06_tamas_quill`; `02` R8 `Halen Osk` ≠ `npc_07_bryn_oskel`; `02` R8 `Perri Lowe` ≠ `npc_09_perrin_lask`; `02` R8 `Turo Bex` ≠ `npc_14_eda_marrow`; `02` R8 `Mira Vask` ≠ `npc_01_ilyra_senn`; `02` R8 `Jano Fesk` ≠ `npc_05_nera_voss`.
- `npc_20_*`~`npc_26_*`는 `R8` support resident 7명이 점유한다. `npc_27_*`~`npc_29_*`는 **미할당**으로 남긴다(아무도 쓰지 않는다). `06` §3.5.3도 7명(`npc_20_*`~`npc_26_*`)으로 갱신됐다.
- `02` §8의 cluster participant 이름도 위 re-key 표를 적용해 core roster 기준으로 다시 읽는다. 그 전까지 `02` §8의 이름은 support-resident roster다.

### 2.4 `R8 The Folding School` — support resident와 magic craft role

`R8`은 별도 우주가 아니라 `E4 The Concentration Layer`의 authored module이고, 진입 edge는 `E18`(R5–R8) 하나이며 gate는 `G5` 하나다. `H0`에는 `R8` route가 없다 — H0 표면은 `SERVICE_R8_COURSE_INDEX` 한 건의 service index 문서일 뿐이다.

**promotion 금지 규칙 (이 절 전체의 전제):**

- 아래 7명은 `npc_20_*`~`npc_26_*` ID를 갖고 `06` §5.11의 `roster_kind: "support"`로 등록한다. **`roster_kind: "core"`로 선언하지 않는다** → `core_roster_not_canonical` error. `06` §3.5.3의 14명 목록에 없는 `npc_*`는 support여야 한다.
- 이 7명은 `§4.2`의 cluster participant로 세지 않는다. `RC-08`의 7명 core membership은 `02` §7.9가 열거한 `npc_04`, `npc_14`, `npc_09`, `npc_01`, `npc_06`, `npc_10`, `npc_07`이다.
- 이 7명은 dialogue-only가 아니다. 각각 최소 하나의 system port를 소유하고(§1.1), 그 port는 `02` §9.3의 `R8` write field 4개 중 하나로 제한된다. `Cross-links`는 2개 이상이며 최소 하나는 `R8` 밖의 core NPC 또는 region이다.
- 이 7명의 `absence.kind`는 `core`가 아니므로 `permanent`일 필요가 없지만, cluster가 이들의 부재로 닫히지 않도록 각자 absence result를 authored한다. 어느 누구도 "학생 제거"로 처리되지 않는다(`02` §4.4: `R8` failed fold는 학생을 제거하지 않는다).
- `Cael Orin`은 **학생이 아니다.** 과거 `art`로 분류된 발명가이며 `RC-08`의 `unassigned stock` 분류가 누구의 명령인지에 대한 partial truth를 홀든다.(core `npc_11_cael_ren`과 이름이 겹치지만 다른 사람이다.)

| ID | working name | `R8` system port | `02` §9.3 write field | executing core NPC (`RC-08`) | absence result |
|---|---|---|---|---|---|
| `npc_20_mira_vask` | Mira Vask | magic craft queue / student status | `MAG_ACADEMY` curriculum office: `course index`, `student status` | `npc_09_perrin_lask` (배정표), `npc_14_eda_marrow` (labor record) | queue가 비면 등록 대기자가 `unrecorded`로 남고, `E18` resource gate 재평가 대상이 된다 |
| `npc_21_halen_osk` | Halen Osk | medium store keeper | `MAG_ACADEMY` curriculum office: `craft_credit` 배분 및 `medium_blank`/`fold_sheet` 반출 승인 | `npc_04_sable_halm` (medium/execution space) | 재고 대장이 `R5-13 Supply Rack`의 원장과 충돌해 `R4-02`와 같은 conflict record가 된다 |
| `npc_22_iven_marrow` | Iven Marrow | weave yard instructor | `MAG_ACADEMY` curriculum office: 채점/실습 판정 | `npc_04_sable_halm` (fold/weave 판정) | 실습 기록이 사라져 `R8-05`의 `P`/`R` write 근거가 private testimony로만 남는다 |
| `npc_23_turo_bex` | Turo Bex | void-cut 실습 책임자 | `VOID_CONTRACT_COURT`: `contract_tally`과 contract 문서 | `npc_07_bryn_oskel` (잔해 증거), `npc_01_ilyra_senn` (문서Filing) | 미Filing contract가 `R7-09` 기록과 다른 shape로 남고 `G8`이 어느 쪽을 우선할지 명시해야 한다 |
| `npc_24_perri_lowe` | Perri Lowe | lineage registrar | `LINEAGE_HOUSE` registrar: `lineage_token` | `npc_09_perrin_lask` (이름 없는 배정함) | 배정표가 닫히면 가문 craft가 `R4-02` conflict로만 남고 `C linked`가 오르지 않는다 |
| `npc_25_jano_fesk` | Jano Fesk | circulation board liaison | `CIRCULATION_BOARD`: `concentration_field` 측정과 dispersal 배정 | `npc_08_meral_dune` (측정 provenance) | 측정값 provenance가 `R2-09`와 다르면 `K`가 한 단계 전진하고 `R2` `E`에도 delayed write가 남는다 |
| `npc_26_cael_orin` | Cael Orin | 발명가(분류 `art`, 학생 아님) | 없음 — authority가 아니라 **증언 source** | `npc_06_tamas_quill` (term), `npc_10_juno_caster` (전파) | 증언이 사라지면 `unassigned stock` 분류의 명령자가 끝내 `unattributed`로 남는다 |

각 resident의 필드는 `06` §5.11 `NpcDefinition`에 채운다. `04`가 소유하는 서술 규칙만 여기에 적는다.

**이 절의 필드 계약(축소 contract):** support resident dossier는 §1.1의 23개 field 전부를 요구하지 않는다. `npc_20_*`~`npc_26_*`에 요구하는 것은 `id`, `roster_kind: support`, `public_role`, `private_role`, `capability.port_ids`(1개 이상, `02` §9.3의 `R8` write field 4개 중 하나), `resource_access`, `knowledge_boundary`, `clock_ids`, `cross_link_ids`(2개 이상), `absence`, `oneoff_dialogue_seed_ids`다. `desire`/`fear`/`contradiction`을 dossier 서술로 요구하지 않으며 `interaction_verbs`를 새 verb로 만들지 않는다 — 그 resident가 실행하는 action은 §2.1 표의 "executing core NPC" 열에 적힌 core NPC의 기존 verb ID다. `relationship_ids`는 `06` §5.11의 1..4 규칙을 따라 core NPC를 `target_npc_id`로 갖는 `rel_*`를 참조하되, resident 자체가 player의 relationship target이 되지는 않는다. §5.4의 quality gate에서 §1.1 23-field와 `interaction_verbs` 4개 조건은 **core 14명에게만** 적용되고, support resident에게는 위 축소 조건이 적용된다.

**seed 귀속 규칙:** 아래 resident의 `One-off dialogue seeds` 줄에 언급한 magic seed는 **그 resident의 port가 만드는 non-dialogue surface**를 가리킨다. `link A` owner(§2.6)와 `one_off_dialogue_seeds`의 owner는 언제나 **core NPC**다. resident가 같은 seed를 dialoguing하지 않으므로 §1.5의 "두 NPC 재사용 금지"에 걸리지 않으며, resident는 그 surface를 `prop_*`/`doc_*`/`enc_*` 한 개로만 공급한다.

#### NPC-20 — Mira Vask (`npc_20_mira_vask`)

- **Public role:** `MAG_ACADEMY` curriculum office의 magic craft queue와 student status 담당자. 등록 대상이 무엇을Filing하는지 결정한다.
- **Private role:** 등록이 capability 등록이 아니라 **measurement provenance** 등록이라고 알고 있으며, 그 사실을 curriculum office에 보고하지 않고 `concentration sample`의 출처를 먼저 고른다. lineage 미배정 craft를 `unassigned stock`으로 세는 분류의 명령자가 누구인지 압니다.
- **Capability:** `R8-02` 등록 절차, `R8-01` course index 인쇄, 학생 status 전환. `E18` 통과 여부를 바꿀 수 있지만 player를 승인하지는 않는다 — `G5`만 gate다.
- **Resource access:** `course index` 원본, `craft_credit` 소모 기록, 등록 마감 기록. 학생 한 명을 `registered`로 올리면 다른 대기자 한 명이 `unrecorded`로 밀린다.
- **Knowledge boundary:** provenance 판정의 이유와 stock 분류의 명령자는 안다. craft의 실전 결과, `mana_profile`의 clinic 판정, 계약 조건은 모른다.
- **Relationship / core NPC:** `npc_09_perrin_lask`가 `R8-03`의 이름 없는 칸을 열 때 `npc_20`의 `student status` write가 따라간다. `npc_14_eda_marrow`가 `craft_credit`을 labour hour으로 옮기면 queue가 비어 있지 않다는 사실이 Filing된다.
- **Clock / cross-links:** `institutional_response_clock`, `public_record_clock`; `npc_09_perrin_lask`, `npc_14_eda_marrow`, `npc_25_jano_fesk`.
- **One-off dialogue seeds:** `S137`(class inversion — 발명한 자를 예술가로 부르는 분류가 `A`와 `D`에 동시에 쓰임)은 `R8-01`의 `course index`와 `R5-13` 원장이 만드는 **non-dialogue surface**로 실행하고, dialogue surface는 `TONE`/`ONEOFF` seed로 따로 authoring한다. `02` §7.9의 one-off(등록은 capability 등록이 아니라 measurement 출처를 고르는 일)은 이 resident의 대사 surface이며 `doc_r8_course_index`를 여는 2번째 surface를 가진다.

#### NPC-21 — Halen Osk (`npc_21_halen_osk`)

- **Public role:** `Medium Store`의 keeper. `medium_blank`, `fold_sheet`, blade를 층별로 쌓아 두었다가 `R5`와 `R8`에 나눠 준다.
- **Private role:** 학교가 판정한 재고와 `R5-13 Supply Rack`의 원장이 서로 다른 수량으로Filing되어 있다는 것을 유지한다. 재고를 한쪽에 맞추는 것보다 conflict record를 남기는 편이 자기 권한이 안전하다고 안다.
- **Capability:** 재고 대장, 층별 접근, `craft_credit`과 물질의 교환 비율. `blade_credit`를 발급할 때 `shape_or_pattern`과 `tool_variant`를 함께 고정한다.
- **Resource access:** store 층, 재고 원장, 회수된 재사용 금지 fold sheet. 한 대장을 속이면 다른 대장이 즉시 드러난다.
- **Knowledge boundary:** 재고의 실물 수는 안다. crop을 만든 사람의 의도, `blade_credit`의 도구 구조가 contract 조건으로 어떻게 쓰이는지는 모른다.
- **Clock / cross-links:** `resource_collapse_clock`, `public_record_clock`; `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_22_iven_marrow`.
- **One-off dialogue seeds:** `02` §7.9의 재고 one-off은 `S160`(도구 구조가 cost와 안정성을 결정)의 non-dialogue surface인 `prop_r8_medium_store_ledger`로 실행한다. dialogue surface는 `TONE`/`ONEOFF` seed로 따로 authoring한다.

#### NPC-22 — Iven Marrow (`npc_22_iven_marrow`)

- **Public role:** `Weave Yard` instructor. 야외 실습과 채점을 맡는다.
- **Private role:** 실패한 fold를 벽에 남기는 것이 규정인지 자신의 방치인지 구분하지 못한다(`R8-05`와 `R7-05` 잔해가 같은 maker라는 기록을 아직 연결하지 못함).
- **Capability:** 실습 판정, `R5-11`의 fold count 소모 확인, `medium` residue 채점. 학생을 제거할 권한은 없고 학점만 회수할 수 있다.
- **Resource access:** 실습 도구, 채점표, `fold_sheet` 회수분. 채점을 지우면 residue가 `R5-03`으로 돌아가지 못한다.
- **Knowledge boundary:** 자신의 판정과 학생의 실제 숙련 차이는 안다. 농도가 training efficiency를 어떻게 바꾸는지, `mana_profile`이 어떤 class인지 모른다.
- **Clock / cross-links:** `personal_collapse_clock`, `contamination_clock`; `npc_04_sable_halm`, `npc_23_turo_bex`.
- **One-off dialogue seeds:** `S133`(실패가 cognition/competence를 잃는 terminal 등급)과 `S150`(3D complexity/cost 우위)의 non-dialogue surface는 `R8-05` 채점표와 `R5-06` encounter signature다. dialogue surface는 `TONE`/`ONEOFF` seed로 따로 authoring한다.

#### NPC-23 — Turo Bex (`npc_23_turo_bex`)

- **Public role:** `Cut Chamber`의 void-cut 실습 책임자. 실패한 절단이 벽에 남아 있다.
- **Private role:** 잘라 낸 shape가 destination을 정한다는 것을 학교 curriculum보다 먼저 배웠고, curriculum이 shape를 고르지 못하게 만든다. 그 빈자리를 자기 판단으로 채운 기록이 있다.
- **Capability:** `R8-06` contract 문서 작성, `R7-05`와 같은 phase 관측, `contract_tally` 항목 추가. shape는 input이며 output이나 위험을 자동 보장하지 않는다.
- **Resource access:** 절단 도구, `blade_credit` 실행 권한, 실습실 잔해. 잔해를 회수하면 `R5-03`의 회수분이 되고, 남기면 `R8` 내부 conflict가 남는다.
- **Knowledge boundary:** 실습 단계와 잔해의 상태는 안다. 상대 차원 존재가 무엇을 원하거나 계약이 어떻게 해석되는지는 모른다.
- **Clock / cross-links:** `crown_alignment_clock`(interpretation input), `public_record_clock`; `npc_07_bryn_oskel`, `npc_01_ilyra_senn`, `npc_06_tamas_quill`.
- **One-off dialogue seeds:** `S154`/`S155`/`S158`의 non-dialogue surface는 `R8-06` contract 문서와 `R7-09` ledger 대조다. `S158`(deferred obligation, 자동 해소 금지)이 이 resident의 핵심 rule이다. dialogue surface는 `TONE`/`ONEOFF` seed로 따로 authoring한다.

#### NPC-24 — Perri Lowe (`npc_24_perri_lowe`)

- **Public role:** `Lineage Hall`의 lineage registrar. 가문 배정표와 이름 없는 배정함을 관리한다.
- **Private role:** `lineage_token`이 접근권의 증거이면서 외부 유출 시 `A`가 `contested`가 되는 값이라는 것을 알고, 자기 표기만으로 그 사실을 감추려 한다.
- **Capability:** `R8-03` 배정, `lineage_token` 발급, 배정함 폐쇄. 가문 magic는 access gate이지 innate morality가 아니다(`S144`).
- **Resource access:** 배정표, 배정함, `lineage_token` 대장. 이름 없는 칸을 열어 주면 자기 권한이 줄어든다.
- **Knowledge boundary:** 배정 규칙과 대장은 안다. 어떤 가문이 어떤 미정형 craft를 보존하는지, 확산이 실제로 얼마나 느린지는 모른다.
- **Clock / cross-links:** `institutional_response_clock`, `public_record_clock`; `npc_09_perrin_lask`, `npc_20_mira_vask`.
- **One-off dialogue seeds:** `S135`/`S136`/`S143`/`S144`의 non-dialogue surface는 `R8-03` 배정표와 `R8-07` refusal record다. `S144`는 `A unlicensed`와 `unregistered craft` Filing을 만들고 innate morality가 아님을 남긴다. dialogue surface는 `TONE`/`ONEOFF` seed로 따로 authoring한다.

#### NPC-25 — Jano Fesk (`npc_25_jano_fesk`)

- **Public role:** `Circulation Board`의 liaison. `R2`에서 옮겨 온 농도 측정과 dispersal 배정을 학교 curriculum에 연결한다.
- **Private role:** 농도를 낮추면 물이 오염된다는 사실을 알면서도 배정표를 올린다. 어느 비용이 더 큰지를 정하는 권한은 기관에 있다는 것을 반복해서 말해 그 결정의 무게를 지운다.
- **Capability:** `concentration_field` 측정, dispersal 배정, provenance 대조. `E18`의 `concentration sample`을 여기서 만들거나 `R2-09`에서 받아 온다.
- **Resource access:** 측정표, dispersal 배정권, `circulation_slot` 잔량. provenance가 다르면 `K`가 한 단계 전진한다.
- **Knowledge boundary:** 측정값과 배정 결과는 안다. 이웃 정착지에 적립된 오염이 무엇으로 돌아올지는 모른다.
- **Clock / cross-links:** `contamination_clock`, `resource_collapse_clock`; `npc_08_meral_dune`, `npc_20_mira_vask`.
- **One-off dialogue seeds:** `S123`/`S126`/`S127`의 non-dialogue surface는 `R2-09`/`R2-10` 측정표와 `R8-02` 등록 대조다. dialogue surface는 `TONE`/`ONEOFF` seed로 따로 authoring한다.

#### NPC-26 — Cael Orin (`npc_26_cael_orin`)

- **Public role:** 과거 `art` category로 분류된 발명가. 학생이 아니며 학교의 강좌에도 없다.
- **Private role:** 발명한 craft를 배운 자가 아니라 **배워야만 했던 계급**이었고, 그 사실이 학교의 curriculum에 의해 지금도 유지된다는 것을 안다. `unassigned stock` 분류의 명령자가 누구인지에 대한 유일한 체증인이다.
- **Capability:** 과거 shape와 도구 구조의 증언, 학교 분류의 timeline. authority를 write하지 않으며 증언으로만 `R`을 전진시킨다.
- **Resource access:** 옛 설계 여백, 옛 실습 기록 사본. 사본이 없으면 분류 명령은 끝내 `unattributed`로 남는다.
- **Knowledge boundary:** 자기 시대의 재료와 도구는 안다. 현재 학교가 무엇을 금지했는지, `R4` glossary가 그 이름을 어떻게 옮길지는 모른다.
- **Clock / cross-links:** `public_record_clock`; `npc_06_tamas_quill`, `npc_10_juno_caster`.
- **One-off dialogue seeds:** `S137`/`S141`(마법학원 학생이 protagonist가 될 수 있으나 유일한 canon이 아님)의 non-dialogue surface는 `R8-01` course index의 `art` category 칸과 `R4` glossary 비어 있는 칸이다. dialogue surface는 `TONE`/`ONEOFF` seed로 따로 authoring한다.

### 2.5 Magic craft role 표기 규칙

- `12`의 세 craft family(weave/scroll, rigid-fold, void-cut/portal)는 NPC capability가 아니라 **action family**다. NPC는 "마법을 쓸 수 있다/없다"가 아니라 "어떤 medium과 tool을 배정·판정·감사하는가"로 기술한다.
- `"이 magic를 쓸 줄 안다"`는 innate title이 아니라 실전 숙련의 occupational speech다(`S145`). dossier는 NPC에게 innate magic ability를 부여하지 않고, `craft_credit`/`labor hour`/`course status` record로 숙련을 증명하게 한다.
- concentration은 `12` §2.1의 `concentration_source`/`concentration_level`로 다루며 NPC의 자질이나 moral class가 아니다. `mana_profile`은 §2.2의 8종 body compatibility/failure class이고 성격·선택지가 아니다.
- magic failure는 즉사가 아니다. NPC arc에서는 recoverable / continuity-changing / terminal 3등급 중 하나로 분류하고, recovery type(`checkpoint`…`institutional_reentry` 7종)과 섞지 않는다(`02` §10).
- magic은 새 axis도 새 clock도 아니다. NPC dossier는 `concentration`이나 `mana`를 `clock_links`나 `axis_rules[].sets`에 넣지 않고 `magic.*` record read/write로 표현한다.

### 2.6 Magic supplement seed binding (`S121`~`S160`)

magic supplement 40 unit은 `02` §11.2의 `X27`~`X36`으로 예약되어 있고, 각 seed는 **아래 core NPC가 실제로 수행**한다. `R8`에만 묶인 seed는 `unbound`다(`02` §11.4). `03` §14.4의 seed register와 1:1로 일치해야 한다.

| NPC | magic seed | region family (R8 밖 표면 필수) |
|---|---|---|
| `npc_01_ilyra_senn` | `S121`, `S141`, `S155`, `S158` | `R8-02`, `R8-04`, `R7-09` / `R4-01`, `R4-02` |
| `npc_04_sable_halm` | `S122`, `S133`, `S142`, `S145`, `S146`, `S149`, `S150`, `S151`, `S153` | `R8-04`, `R8-05`, `R8-03` / `R5-10`, `R5-11`, `R5-12`, `R5-13`, `R5-01` |
| `npc_05_nera_voss` | `S129`, `S131`, `S156` | `R3-05`, `R3-06`, `R6-01` |
| `npc_06_tamas_quill` | `S147`, `S157` | `R8-06`, `R8-04` / `R4-01`, `R4-02` |
| `npc_07_bryn_oskel` | `S124`, `S130`, `S154` | `R7-09`, `R7-05`, `R8-06` |
| `npc_08_meral_dune` | `S123`, `S126`, `S127` | `R2-09`, `R2-10` |
| `npc_09_perrin_lask` | `S135`, `S136`, `S138`, `S143`, `S144`, `S152` | `R8-03`, `R8-07`, `R8-01`, `R8-04` / `R4-06` |
| `npc_10_juno_caster` | `S125`, `S148`, `S159` | `H0-05`, `R5-10`, `R8-06` / `R4-03` |
| `npc_13_tovan_reed` | `S128`, `S132` | `R3-01`, `R6-01` / `R5-03` |
| `npc_14_eda_marrow` | `S134`, `S137`, `S139`, `S140`, `S160` | `R8-08`, `R8-01`, `R5-07`, `R5-12` |

- 합계 40 unit, 전부 `PLANNED_RETAINED`. `npc_02_orrin_kest`, `npc_03_veya_morcant`, `npc_11_cael_ren`, `npc_12_ravenna_holt`는 magic supplement seed의 **link B**(다른 region/NPC 표면) 역할로 등장할 수 있으나 `link A` owner는 아니다. 이 네 명에게 새 magic seed를 배정하지 않는다.
- 각 seed는 `res_*`(`02` §5.5) 또는 `magic` record(`02` §9.1)를 하나 이상 읽거나 쓰고, `02` §4.4 표의 clock write를 하나 이상 가져야 한다. dossier가 그 둘 중 하나만 남기면 `unbound`다.
- `R8`에만 묶인 row는 0건이다: 위 10개 NPC 중 `npc_08_meral_dune`(`R2-09`/`R2-10`), `npc_13_tovan_reed`(`R3-01`/`R6-01`), `npc_05_nera_voss`(`R3`/`R6`)는 `R8` 밖에서만 실행되고, 나머지 7명은 `R8` row와 `R4`/`R5`/`R2`/`R7` row를 함께 가진다.


## 3. Core NPC dossiers

### NPC-01 — Ilyra Senn (`npc_01_ilyra_senn`)

**Seed bindings:** core `S001`, `S002`, `S003`, `S053`, `S055`, `S056`, `S099`, `S108`, `S116` / magic supplement `S121`, `S141`, `S155`, `S158`.

**System port / region:** `Crownwell Archive`(R4) `Record Office`의 vertical record index, public record correction, upper-stack access. 원작의 특정 지도·대왕·역사를 사용하지 않는다.

**Public role:** royal hall 위의 archive indexer. court와 여러 institution이 제출한 person, object, operator, anomaly category를 조회하고 위치·인정·기록 충돌을 처리한다.

**Private role:** 한 전 operator를 지운 기록을 “아직 living omission”으로 숨기고 있다. 그 사람을 왕관의 새 owner로 만들지 않고, 사람으로서 다시 인식시키는 절차만 찾는다.

**Desire / fear / contradiction:**

- Desire: 왕관은 유지하면서 한 사람의 continuity를 공동 체가 아닌 살아 있는 자로 인정받게 한다.
- Fear: archive가 자신을 가장 오래 보관할 대상인 `object` 또는 `protocol node`로 재분류할까 두렵다.
- Contradiction: 개인의 기억을 지키려면 사람을 index entry로 계속 압축해야 한다. 진실을 보존하는 행위가 진실의 주인을 바꾸기도 한다.

**Capability:** 기록 간 lineage와 category drift를 교차 확인한다. 한 번의 `REQUEST_INDEX`로 한 층위만 공개하고, contradictory fragment를 발견하면 해당 기록의 legal effect를 중지시킬 수 있다. 물리 전투는 약하지만 archive alarm, record lock, guard access를 조작해 noncombat encounter를 만든다.

**Resource access:** upper stacks, sealed pages, vertical lift, clerk relay, one-time archive favor. player가 이름을 보존하거나 공개하면 각각 access를 얻거나 잃는다. player가 archive 안에서 군대 권한을 얻지는 못한다.

**Knowledge boundary:** 왕관의 위치와 기록 계보의 변형은 안다. 왕관의 metaphysical rule, player가 어느 continuity인지, 숨긴 이름이 살아 있는지까지는 안다고 가정하지 않는다. 기록이 만들어진 이후의 edited pages는 다른 owner의 영역이다. magic theory의 positive name은 `glossary`가Filing하기 전까지 모른다 — 학교가 붙인 이름을 모른다는 것은 실수가 아니라 `R4`의 권한이다(`S147`은 `npc_06`의 seed다).

**Clock / cross-links:** `public_record_clock`, `institutional_response_clock`, `crown_alignment_clock`; `npc_12_ravenna_holt`, `npc_10_juno_caster`, `npc_11_cael_ren`, `npc_05_nera_voss`, `npc_06_tamas_quill`, `npc_26_cael_orin`.

**Seed transformation record:**

- `S001–S003` — 왕관을 physical object, inherited title, persistent invariant의 세 층위로 분리한다. local rule은 기록이 왕관의 위치를 바꾸지 못한다는 것. cross-link는 `Crownwell Archive`와 `Crown Protocol` seat, immediate access change와 delayed succession debt를 만든다. Monarch lore로 일반화되지 않도록 record correction이 필수다.
- `S055`, `S108` — court order의 political absurdity를 higher location의 physical rule로 바꾼다. dialogue가 아니라 map, seal, archive access의 category error로 발동한다.
- `S056`, `S116` — public record가 사건을 outlive하고 memory가 person을 대신하는 delayed identity conflict를 만든다.
- `S121`, `S141`, `S155`, `S158` — magic layer를 archive 문제로 만든다. local rule은 **`R4` glossary가 비어 있으면 craft 이름은 `untranslated term`으로 Filing된다**는 것이며 학교는 이론 이름을 소유하지 않는다. `S121`의 측정 하나가 `E18` 비용과 `R2`의 `K`/`E` write를 함께 정하고, `S155`의 shape 해석이 틀리면 `R4-02` canonical law가 다시 쓰이며, `S158`의 contract는 deferred obligation을 남긴 채 `C`를 전진시키지 않는다. cross-link는 `R2-09` measurement provenance와 `R8-02` 등록, immediate는 `R4-02` conflict, delayed는 `R5` labor role 재분류다.

**Relationship state** (`rel_01_ilyra_record`, channel `professional → romance`, `03` §12.1의 `rs_*` instance를 그대로 쓴다):

- `rs_ilyra_unverified_petitioner` (order 0): Ilyra는 player를 petition자로 부르고 한 층위만 공개한다. presentation `stance`는 `wary`.
- `rs_ilyra_source_credited`: `SHOW_FRAGMENT` 또는 `REQUEST_INDEX`가 두 record의 provenance 비교를Filing하면 전이. 기록상 player는 `source`로 부른다.
- `rs_ilyra_name_kept`: `PROTECT_NAME`을 consent와 함께 반복하면 전이. `recognition`이 `person`에서 `distributed_self`로 이동하고 `P personal_collapse`에 별도 write가 남는다.
- `rs_ilyra_index_surrendered` (sink, `is_irreversible`): `SURRENDER_INDEX` + `OPEN_UPPER_STACK`으로 독점 archive ownership을 공동으로 넘기면 도달.
- `rs_ilyra_institutional_threat` (sink, `is_irreversible`): archive seal 공개 또는 consent 없는 `PROTECT_NAME` 반복으로 archive가 player를 위협으로 분류하면 도달. 개인 신뢰는 남을 수 있고 `rs_ilyra_index_surrendered`로의 되돌림 edge가 1개 존재한다. romance는 trust보다 먼저 무너지지 않는다.
- NPC 간선: Ravenna는 `professional_rival` → seal 공개 시 `constitutional_alliance`. Cael은 `inherited subject` ↔ `dangerous independent` 사이를 oscillate. Juno는 서로를 이용한다. (§4.1)

**Magic / craft port (`E4`, `RC-08`):** Ilyra는 `R4-01` `glossary` slot의 canonical 결정자다. 학교가 `R8-03`/`R8-04`로 등록한 magic term이 `R4-01`의 번역과 다르면 두 줄이 모두 남고 `R4-02`와 같은 conflict record가 된다(`S121`, `S155`). `R8-06`이 체결한 portal contract 문서도 그녀의 `Record Office`를 거쳐야 public record가 되며, 그 문서가 `contract_tally`을 새로 만들지는 않는다 — she는 계약의 해석을 만들지 않고 Filing만 한다. `S158`의 rule이 여기서 발동한다: contract는 자동 해소되지 않고 `G8`이 `crown_protocol` 안과 밖 중 어디에 둘지 명시해야 한다. `S141`(마법학원 학생이 protagonist가 될 수 있으나 유일한 canon이 아님)에 대해, Ilyra는 `R5-01` boot과 `R8-04` course 중 어느 쪽에도 우선순위를 주지 않는 record를 남긴다.

**Speech pressure:** 정확한 category와 문서 시점을 먼저 말한다. player가 이름을 사람으로 부르면 그 단어를 반복해 확인하고, 자신이 사적인 물음에는 category로 답한다. 압박이 높아지면 침묵한 채 문서를 접거나, 없는 category를 만든다.

**Silence / lie pattern:** 자기 이름을 말하지 않는다. “record is current”처럼 거짓말할 때는 실제 category를 바꾸며, 그 결과는 즉석에 access나 public record에 나타난다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `REQUEST_INDEX` | 제출 가능한 evidence 또는 access token | 한 record location 공개, trust 소폭 상승 | private omission의 존재가 archive signal로 남음 | 정보 없이 반복하면 inquiry record가 쌓임 |
| `SHOW_FRAGMENT` | 서로 다른 두 record의 비교 가능 | fragment가 provenance로 인정됨 | player의 knowledge와 NPC의 knowledge가 갈라짐 | 위조면 player가 source category로 기록됨 |
| `PROTECT_NAME` | 이름의 주인과 consent를 확인 | 사람을 일시적으로 uncategorized 상태로 전환 | institution response clock 상승, 사후 공개 경로 개방 | consent 없이 하면 affection가 아니라 debt만 남음 |
| `RECLASSIFY` | archive authority token 보유 | 대상의 combat/entry/legal effect 변경 | public record와 실제 body가 불일치하는 상태가 지속 | 되돌리면 이전 category의 resource lock가 복귀 |
| `OPEN_UPPER_STACK` | favor 또는 player가 archive rule를 두 번 지킴 | hidden route와 one-off document 접근 | crown alignment이 player의 위치를 기록 | 한 번 실패하면 access가 아니라 suspicion만 남음 |
| `SURRENDER_INDEX` | Ilyra의 private role이 드러난 뒤 | 독점 index를 복제·공개 | archive가 공동 responsibility을 갖게 됨 | player가 copy를 통제하지 못하면 faction이 먼저 탈취 |

**Combat / encounter profile:** 직접 전투 NPC가 아니다. archive lockdown, guard escort, record seizure를 하나의 noncombat encounter로 쓴다. player가 기록을 훼손하면 Ilyra는 적으로 전환되지 않고 archive 자체를 닫는다. player가 기록을 보존하면 전투 대신 후반 route가 열린다.

**Survival / death / absence consequence:**

- Survival: Ilyra가 살아 있으면 private omission을 되돌릴 여지와 공동 archive route가 남는다. 살아 있다는 사실만으로 승리는 아니다.
- Death: 육체는 사라져도 archive role과 edited lineage은 남는다. 후임 indexer가 같은 권한을 물려받는다. S056의 public record clock이 한 단계 급격히 진행된다.
- Absence: 스스로 사라지면 player는 incomplete index를 찾지 못한 채 “record가 없는 사람”으로 남는다. 어느 institution이 빈 category를 차지했는지가 delayed conflict를 만든다.

**One-off dialogue seeds** (전부 `ONEOFF` class, 각 2 surface, primary cluster는 `RC-04`/`RC-06`):

- `S055` — field query에 답하는 대신 위층의 위치를 physical map으로 옮겨서 authority를 우회한다. `conv_*` 1개 + `prop_r7_crown_position_map` 1개. player가 map를 쓰면 access를 얻지만, Ilyra의 loyal clerk가 신뢰를 잃는다. climax이 아니라 field access write다.
- `S108` — court가 왕관의 위치를 바꾸는 order를 냈을 때 archive가 order를 집행하지 않고 vertical precedence만 남긴다. `conv_*` 1개 + `doc_r4_vertical_precedence_notice` 1개. player가 order를 집행할지 기록할지가 irreversible choice가 되며 `R7-04` revisit variant을 예약한다.
- `S116` — 이전 operator의 기억은 남아 있지만 그 사람이 아니라는 artifact encounter. `conv_*` 1개 + `enc_r4_crown_fragment_recovery` 1개. player가 기억을 누구에게 돌려줄지 action으로 결정한다. `rs_ilyra_name_kept`로 가는 evidence가 되지만 romance 조건은 아니다.

**Faction / institution links:** `Crownwell Archive`의 `Record Office`가 주된 authority다. `Crown Protocol` seat(Ravenna)와 경쟁하고, `Return Registry`의 record와 거래하며, H0 `Crier Office`의 public archive와 경쟁하고, `Gristmarket Clinic`(R6)의 organ naming protocol에는 접근하지 않는다. R4 `Crown Observatory`와 R7 `Crown Position`에는 read만 가능하다. `R8`에서는 `MAG_ACADEMY` curriculum office와 경쟁 관계이며(`glossary` 선점), `VOID_CONTRACT_COURT`가 만든 contract 문서만 Filing한다(`npc_23_turo_bex`). 학교의 `LINEAGE_HOUSE`, `CIRCULATION_BOARD`에는 쓰기 권한이 없다.

**Romance / affection arc:** 기본은 affection-only. player가 사람의 이름을 page가 아닌 person으로 돌려주고, Ilyra가 독점 access를 내려놓았을 때 `romance_open`이 된다. romance가 열리면 그녀는 소유로 archive할 수 없는 관계를 받아들여야 한다. jealousy는 player가 같은 private evidence를 다른 institution에 맡길 때 evidence의 소유권에 나타난다. 어떤 route도 성적 보상으로 열리지 않는다.

**Body-horror identity arc:** archive exposure가 Ilyra의 한 손과 목소리를 living index로 만든다. identity 상태는 `intact body → indexed body → distributed self → returned name`으로 변한다. 복구는 기능을 되돌리는 것이 아니라 어느 authority가 손을 소유하는지를 결정한다. player는 hand를 분리할지, private name을 남길지, protocol node로 지속할지 선택할 수 있다. magic layer에서 추가되는 층위는 **medium residue가 손에 남는 경우**다: `R4-01` glossary 충돌이 Filing되면 her hand는 살아 있는 `R4`가 아니라 살아 있는 `R8` 문서도 함께 들고 있게 되고, 어느 손인지가 `B recognition_drift`의 disputed claim이 된다. `S155`의 mistranslated shape는 organ이 아니라 기록이 그의 body authority를 바꾸는 경우다.

### NPC-02 — Orrin Kest (`npc_02_orrin_kest`)

**Seed bindings:** core `S004`, `S005`, `S011`, `S017`, `S031`, `S032`, `S044`, `S046`, `S107`, `S115`. (`S044`는 `SYSTEM` class이라 §1.5에 따라 `one_off_dialogue_seeds`가 아니라 `Seed transformation record`에서 registry action으로 실행한다.)

**System port / region:** `Return Registry`(R1)의 recovery intake, quarantine, re-entry review, identity signature 검사. H0 `Exchange Registrar`의 arrival docket과 인계한다. recovery는 respawn·clone·loop·institutional re-entry를 같은 것으로 취급하지 않는다.

**Public role:** 돌아온 subject를 받아들이고 recovery class와 격리 기간을 정하는 intake examiner.

**Private role:** 과거 recovery test에서 살아남은 자기 signature를 숨기고 있다. 한 family가 서로 다른 recovery 방식으로 복구될 때 “같은 가문”이 아니라 “같은 obligation”으로 다시 묶을 방법을 찾는다.

**Desire / fear / contradiction:**

- Desire: 기능이 복구된 존재가 기억의 완전성 때문에 거부당하지 않게 한다.
- Fear: 정확한 분류가 loved one을 먼저 격리하고, 기억이 다른 사람을 monster로 만든다.
- Contradiction: category error가 사람을 해치기 때문에 category를 strict하게 관리하지만, 한 사람의 continuity를 지키기 위해 illegal exception을 만든다.

**Capability:** body, memory, role, institutional history의 continuity signature를 분리해 읽는다. `CHALLENGE_RECORD` 한 번으로 한 층위의 불일치를 증명할 수 있다. 전투에서는 체력의-specialist가 아니라 quarantine, seal, escort를 이용해 player의 retreat와 target priority를 바꾼다.

**Resource access:** intake gate, quarantine bed, temporary travel seal, recovery log, one emergency medical kit. evidence를 제출하면 access가 열리고, 부당한 classification이 드러나면 registry의 public record가 player에게 favor를 갚아야 한다.

**Knowledge boundary:** 각 recovery가 보존하는 function과 버리는 self를 안다. recovery가 작동하는 ultimate reason, crown이 subject를 선택하는 이유, player의 원래 continuity는 모른다. 하나의 signature를 여러 번 검사해도 그 사람의 desire까지는 알 수 없다.

**Relationship state** (`rel_02_orrin_intake`, channel `professional → romance`, `rs_*` per `03` §12.1):

- `rs_orrin_wary` (order 0): player를 위험한 returner로 취급한다. presentation `stance`는 `wary`.
- `rs_orrin_conditional_trust`: `SHELTER`로 player가 만든 exception을 공동 책임으로 받아들이면 전이.
- `rs_orrin_trusted`: `RELEASE`를 반복하면 전이. `recognition=person`. companion power는 `state.entry_effect_ids`가 실제로 grant해야 켜진다.
- `rs_orrin_committed` (sink): `RECLASSIFY`가 classification이 아니라 사람을 위한 것임을 드러내면 도달. `fractured`가 아니라 `committed`가 되는 경로가 별도로 존재하는 것이 요점이며, 두 선택 모두 가능하지만 history가 다르다.
- `rs_orrin_fractured` (sink): 부당한 classification이Filing되거나 `BREAK_QUARANTINE`가 evidence 없이 실행되면 도달. 되돌림 edge는 `rs_orrin_conditional_trust`로 1개다.
- NPC 간선: Cael은 `examiner/subject` → 함께 continuity를 시험하면 `co-expert` 또는 `accuser`. Tovan은 triage 결과를 공유하는 rival. Sable은 dependency와 consent를 놓고 핵심을 경쟁. (§4.1)

**Magic / craft port (`E4`):** 없다. Orrin은 `RC-08`에서 학교 측 surface를 소유하지 않으며, `E18`을 통과하는 craft를 허가하지도 거부하지도 않는다. 다만 **`unregistered craft` 압수가 `E18`을 거쳐 들어올 때** `E06`/`E07`을 통해 반환 intake가 닿는다. local rule: `A`가 `unlicensed`가 되는 것은 압수 자체가 아니라 `R7`/`R8` 두 record 중 어느 쪽이 canonical이 되느냐에 따라 결정된다(`02` §4.4). 따라서 Orrin의 `RECLASSIFY`는 magic을 `person` capability으로 되돌리는 유일한 lawful path이며, 그 결과는 `A` write가 아니라 `B` disputed claim으로 Filing된다.

**Speech pressure:** binary category와 다음 절차부터 묻는다. 두 번째 질문이 어려울수록 답변 대신 form, bed, seal을 가리킨다. player의 이름을 부르기 전에는 먼저 recovery ID를 부르고, 두 번째 대화부터 이름을 사용한다.

**Silence / lie pattern:** 자기가 검사받은 사실은 말하지 않는다. lie는 사람을 object로 부르는 category에서 발생한다. player가 그 category를 거부하면 즉시 멈추지만, silent record에는 refusal를 남긴다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `DECLARE_RETURN` | subject가 field에서 복귀함 | recovery class와 격리 level이 확정 | route, equipment, faction access가 함께 바뀜 | class가 틀리면 즉시 quarantine combat 발생 |
| `CHALLENGE_RECORD` | 두 signature를 직접 비교 | 한 layer의 category만 무효화 | player knowledge는 유지되고 registry trust만 상승 | 다른 layer를 건드리면 contamination이 전염됨 |
| `SHELTER` | player가 danger를 감수하고 대상을 지킴 | 한 명을 격리실 밖으로 이동 | institutional response가 player의 위치를 기록 | 보호자가 함께 격리되면 route가 봉쇄됨 |
| `RELEASE` | signature disagreement를 증명 | recovery path 또는 clone-legal status 개방 | public record가 “오류”로 남음 | 잘못된 release는 player가 new subject가 됨 |
| `RECLASSIFY` | consent, evidence, exception token 필요 | legal category만 변경 | self identity가 아닌 social recognition이 바뀜 | category change가 organ identity를 덮으면 body clock 상승 |
| `BREAK_QUARANTINE` | player가 guard를 resolve하고 증거를 확보 | 강제 격리 종료 | 해당 NPC의 absence가 institution-wide event가 됨 | guard를 죽이면 recovery protocol이 강화됨 |

**Combat / encounter profile:** hostile가 되면 같은 identity의 `quarantine officer` encounter가 된다. 공격력보다 lock, status, target priority를 바꾸는 port를 우선한다. player가 이기지 않고 certificate를 낼 수도 있다.

**Survival / death / absence consequence:**

- Survival: player가 exception을 세우면 registry는 한 명을 re-enter할 수 있다. Orrin이 살아도 그 classification은 자동 신뢰가 아니다.
- Death: intake officer가 죽으면 mass quarantine rule이 발동한다. 개인의 기억은 남지만 live access와 appeal이 사라진다.
- Absence: Orrin이 사라지면 현재 subject들은 “검사가 끝나지 않은 사람”으로 남는다. player가 substitute를 만들거나 quarantine를 강제 해제해야 한다.

**One-off dialogue seeds** (`ONEOFF` class만, 각 2 surface, primary cluster는 `RC-01`):

- `S107` — 살아 있는 recovery subject가 record에서 object로 읽힌다. `conv_*` 1개 + `doc_r1_return_classification_notice` 1개. Orrin은 문장으로 항복하지 않고 category를 수정할 권한부터 요구한다. `rs_orrin_conditional_trust`로 가는 선택지가 되지만 romance 조건은 아니다.
- `S115` — recovery는 정확한 body와 잘못된 employment history를 돌려준다. `conv_*` 1개 + `prop_r1_ash_garden_cold_relay` 1개. player는 개인의 기억보다 사회의 obligation을 먼저 복구할지 선택한다.
- `S044`(`SYSTEM` class)은 이 dossier의 one-off 목록이 아니다. name 오인 연결은 `R1-06 Registry Interrogation`의 seal swap / appeal action으로 실행하고, `Seed transformation record`에 남긴다.

**Faction / institution links:** `Return Registry`(R1)가 직접 권한을 가진다. H0 `Exchange Registrar`와는 jurisdiction을 나누고(`Return Hearing`), R4 `Censor`와는 category jurisdiction을 경쟁하며, `Gristmarket Clinic`(R6)와는 body signature를 교환하고, `Crown Protocol` seat에는 crown-linked re-entry를 보고한다. H0 `Crier Office`는 raw record를 받을 수 있으나 private memory를 요구하지 않는다. `R8` `MAG_ACADEMY`와는 직접 authority가 없으며, lineage 배정으로 들어온 subject는 `npc_09_perrin_lask`의 naming port를 거쳐야 `person` record를 얻는다.

**Romance / affection arc:** 기본은 chosen-family와 professional trust다. romance route는 player가 “같은 사람이어야 한다”는 압박을 버리고, 각자 다른 continuity를 선택한 뒤에도 함께 있을 때만 열린다. jealousy는 player가 다른 returner를 감정적으로 우선할 때 refusal로 나타난다. 성적 보상이나 원래 사람의 대리 관계가 아니다.

**Body-horror identity arc:** Orrin의 recovery signature가 여러 층위로 갈라진다. `single body → partitioned function → contested memory → self-authored continuity`. 치료는 원래 failure를 지우지 않고, 어느 부분이 살아남을지 고르게 한다. player의 선택은 organ의 우선순위를 바꾸며 relationship보다 먼저 body authority를 변화시킨다.

**Clock / cross-links:** `institutional_response_clock`, `contamination_clock`, `crown_alignment_clock`; `npc_11_cael_ren`, `npc_13_tovan_reed`, `npc_03_veya_morcant`, `npc_01_ilyra_senn`, `npc_09_perrin_lask`.

**Seed transformation record:**

- `S004`, `S031` — recovery가 function을 되돌리지만 원래 failure를 복구하지 않는다는 rule을 intake service로 옮긴다. cross-link는 Organ Clinic과 Return Registry이며 immediate 격리, delayed body history가 갈라진다.
- `S005`, `S032` — clone memory가 같아도 social continuity가 다른 person state가 된다. cross-link는 Cael과 school registry, immediate legal signature와 delayed obligation conflict를 만든다.
- `S044`, `S107`, `S115` — name mistake와 object category를 recoverable action으로 만든다. 설명 대신 seal swap, release, appeal이 state를 바꾼다. `S044`는 `SYSTEM` class이므로 dialogue beat가 아니라 registry action으로 실행한다.

### NPC-03 — Veya Morcant (`npc_03_veya_morcant`)

**Seed bindings:** core `S012`, `S021`, `S045`, `S052`, `S059`, `S074`, `S101`, `S119`. magic supplement seed 없음 — Veya는 `E18` possession 감사만 수행하고 curriculum·lineage·contract에는 권한이 없다.

**System port / region:** H0 `Exchange Registrar`의 appeal jurisdiction(`Return Hearing`, `Paper Wardens`)과 R4 `Censor`의 category audit, legal exception, detention, recovery refusal. 이 권한은 recovery 자체를 공격하는 것이 아니라 recovery가 받을 category를 감사한다.

**Public role:** recovery를 거부하는 사람과 anomaly를 조사하는 investigator. player에게는 새로운 quest giver가 아니라 permission과 liability를 판정하는 사람으로 보인다.

**Private role:** “recovery 불가”라는 분류 아래 살아 있는 witness를 숨긴다. institution이 만든 예외 목록을 개인적으로 보관하고, 자신도 그 예외에 포함될 가능성을 알고 있다.

**Desire / fear / contradiction:**

- Desire: 강제 recovery보다 안전한 refusal를 합법적인 선택으로 만들려 한다.
- Fear: 자신의 compassionate decision이 다른 subject의 recovery를 막거나, 결국 스스로가 심판관이 된다고 두렵다.
- Contradiction: category를 의심하지만, 설명되지 않는 대상은 기록하지 않는다면 그 대상을 다시 위험하게 만든다.

**Capability:** 존재하지 않는 category, 잘못된 legal fit, forged consent를 찾는다. 물리 combat보다 audit summons, nonlethal restraint, record seizure를 사용한다. player가 직접 증빙을 가져오면 즉각적인 legal transition을 만들 수 있다.

**Resource access:** investigation seal, detention room, audit clerk, informant, temporary license. clinic이나 water supply에는 직접 접근하지 못하되 다른 NPC를 통해 거래한다.

**Knowledge boundary:** legal gap과 false re-entry의 구조는 안다. organ authority가 어떻게 생성되는지, translation이 새 law를 어떻게 만드는지, crown이 누구를 선택하는지는 모른다. 공식 기록보다 한 번 거짓말을 한 사람의 현재 행동을 더 신뢰한다.

**Relationship state** (`rel_03_veya_audit`, channel `confrontation`, `rs_*` per `03` §12.1):

- `rs_veya_hostile` (order 0): player가 category를 exploitation하는지 audit한다. presentation `stance`는 `hostile`.
- `rs_veya_conditional_trust`: `CHALLENGE_CATEGORY`가 public으로Filing되어 player를 tool이 아니라 accountable actor로 보이면 전이. `AUDIT_CATEGORY`만으로는 전이하지 않는다.
- `rs_veya_committed_exception` (sink): 두 사람이 함께 exception을 만들면 도달. institution보다 서로에게 먼저 책임진다.
- `rs_veya_fractured_privilege` (sink): Veya가 player 대신 `SIGN_EXCEPTION`을 사용하면 도달. evidence가 남고 되돌림 edge가 1개 있다.
- romance는 `conditional_trust`에서만 `via: choice` 또는 `via: effect`로 열리고, `clock_stage`/`absence`/`encounter_outcome`으로 강제 진입할 수 없다.
- NPC 간선: Ilyra는 category를 다르게 조작하는 functional adversary. Nera는 legal person과 body person의 counterweight. Sable은 consent form을 다르게 실행하는 rival. (§4.1)

**Magic / craft port (`E4`, `RC-08`):** Veya는 `E18`을 통과한 미등록 craft의 possession을 감사하는 유일한 core NPC다. local rule: **`unregistered craft`는 `unclassified`가 아니라 `unlicensed` + `artifact` 조합으로 Filing된다**(`02` §3.2, §4.4). 압수 자체는 `A` 강등이 아니며 `I institutional_response`만 전진시킨다. 그녀의 `SEIZE_RECORD`가 `blade_credit`를 회수하면 `D`와 `magic.crafts.tool_variant`이 함께 갱신되고, possession이 `person` capability으로 다시 분류되려면 `RESET` 경로가 아니라 `npc_03_veya_morcant`의 `SIGN_EXCEPTION`이 필요하다. `S144`의 "가문 magic는 access gate이지 innate morality가 아니다"가 여기서 법률적으로 실행된다.

**Speech pressure:** 조건문과 질문으로 말한다. 답을 요구할수록 선택지를 줄이고, player가 모호하면 그 모호함을 기록한다. 두려워할 때는 “확인해 주십시오”보다 먼저 책임자를 찾는다.

**Silence / lie pattern:** 고의적인 거짓말보다 classification by omission을 사용한다. 없는 category를 공식 문서에 넣지 않음으로써 한 사람을 보호하지만 그 사람을 법적으로 invisible하게 만든다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `AUDIT_CATEGORY` | player가 실제 category를 제시 | 해당 category의 legal validity 검사 | public record와 institution behavior가 엇갈릴 수 있음 | category가 너무 넓으면 player를 조사 대상으로 전환 |
| `CHALLENGE_CATEGORY` | object와 field evidence가 일치 | 해당 category를 일시적으로 무효화 | institution response clock 상승, recovery route 개방 | evidence가 한 층위뿐이면 legal attack 실패 |
| `WITHHOLD_TESTIMONY` | player가 결과에 책임지겠다고 선언 | 공식 category가 갱신되지 않음 | public rumor와 hidden record가 갈라짐 | player가 떠난 뒤 testimony가 player에게 귀속 |
| `SEIZE_RECORD` | inquiry token과 접근 가능 | one-off document와 resource 이동 | public record가 검은 irreversible entry가 됨 | 잘못된 seizure는 Veya의 authority를 손상 |
| `RELEASE_SUBJECT` | 증빙과 field capacity가 충분 | detention 종료, subject의 agency 반환 | route가 열리지만 institution에 합법적인 gap이 생김 | subject가 즉시 위험해지면 Veya가 책임 |
| `SIGN_EXCEPTION` | 두 사람의 consent와 signature 확인 | 한 recovery refusal가 legal state가 됨 | player의 선택 뒤에 third-party consequence가 생김 | 한 signatures라도 사라지면 public record가 손상 |
| `DEFEAT_INQUIRY` | combat intent가 명확할 때 | guard를 resolve하고 audit chamber 접근 | Veya는 체력 loss가 아니라 jurisdiction loss로 반응 | 물리적 승리만으로 legal victory를 얻지 못함 |

**Combat / encounter profile:** Veya와 충돌하면 전투보다 먼저 audit category가 player를 제한한다. player가 evidence를 버리면 investigation guards가 quorum을 만들고, evidence를 유지하면 detention escape와 noncombat negotiation이 열린다. 전투 결과가 반드시 death가 아니다.

**Survival / death / absence consequence:**

- Survival: Veya가 exception을 등록하면 한 recovery refusal가 world state가 된다. survival 자체는 institution의 category를 바꾸지 않는다.
- Death: investigator가 죽으면 모든 pending exception이 “사망한 자의 discretion”으로 회수된다. player가 가진 legal token이 없으면 legal recovery가 사라진다.
- Absence: Veya가 hiding하면 document를 위조한 것으로 처리되어 public record가 오염된다. player는 exception을 증명할지, 그녀를 배신하고 일반 recovery를 실행할지 선택한다.

**One-off dialogue seeds** (`ONEOFF` class만, 각 2 surface, primary cluster는 `HC-00`):

- `S074` — player가 자신의 private motive를 감추려 할 때 Veya는 wrong translation을 정정하지 않고 그대로 사용한다. `conv_*` 1개 + `doc_r4_contradictory_translation` 1개. 그 오류가 어느 institution을 피하게 하는지가 delayed consequence가 된다. `rs_veya_conditional_trust`의 evidence지만 romance 조건은 아니다.
- `S101` — 존재하지 않는 category를 요구하는 official form이 실제로 그 부재로 access를 잠근다. `conv_*` 1개 + `prop_h0_arrival_docket` 1개. player는 form을 부숨 수 있으나 evidence가 사라진다.
- `S119` — emergency form의 category가 법적으로 존재하지 않는 순간, investigation이 사람 대신 form을 체포한다. `conv_*` 1개 + `enc_h0_paper_wardens_form_seizure` 1개. player가 field action으로 category를 바꿀 수 있다.

**Faction / institution links:** H0 `Exchange Registrar`의 appeal jurisdiction이 직접 employer다. R4 `Censor`에는 record access를 청하며, R1 `Return Registry`에는 jurisdiction을 빌리고, R4 `Record Office`에는 public copy를 제출하고, R3 `Hospice Covenant`와 R6 `Gristmarket Clinic`에는 "person"의 category를 감사한다. `Crown Protocol` seat(Ravenna)의 authority와는 political opponent 관계다. `R8`에서는 possession 감사만 수행하고 curriculum·lineage·contract에는 권한이 없다. `MAG_ACADEMY`가 student status를 대신 Filing하는 것을 그녀만 감사할 수 있다.

**Romance / affection arc:** 기본은 adversarial respect와 chosen accountability다. romance route는 Veya가 player에게 단독 discretion을 양도하고, player가 자신의 category error를 공개적으로 책임질 때만 열린다. intimacy는 legal protection을 reward로 주는 장치가 아니다. jealousy는 player가 다른 NPC를 위해 Veya의 exception을 선점할 때 발생한다.

**Body-horror identity arc:** investigative implant이 Veya의 목소리에서 institution voice를 분리한다. 그녀가 계속 이기면 자신의 language를 잃고, voice를 끊으면 증언 능력을 잃는다. identity 변화는 implant, social recognition, legal authorship의 세 축으로 따로 기록한다.

**Clock / cross-links:** `public_record_clock`, `institutional_response_clock`, `crown_alignment_clock`; `npc_01_ilyra_senn`, `npc_05_nera_voss`, `npc_04_sable_halm`, `npc_12_ravenna_holt`.

**Seed transformation record:**

- `S012`, `S045`, `S119` — recovery-refusal institution을 “위험한 사람”이 아니라 존재하지 않는 category를 심사하는 legal system으로 만든다. local rule은 category가 없으면 legal authority도 사라진다는 것. cross-link는 Return Registry와 public record이며 immediate detention, delayed legal precedent가 다르다.
- `S021`, `S052`, `S059` — permission gate와 crown authority를 category negotiation으로 바꾼다. concrete choice가 state를 바꾸며 exposition가 아니다.
- `S074`, `S101` — wrong translation과 불가능한 form을 player-facing action pressure로 만든다. cross-link는 Tamas와 Ilyra, immediate misunderstanding과 delayed institutional exploitation을 만든다.

### NPC-04 — Sable Halm (`npc_04_sable_halm`)

**Seed bindings:** core `S013`, `S014`, `S020`, `S021`, `S022`, `S023`, `S024`, `S025`, `S026`, `S027`, `S086`, `S088`, `S094`, `S105`, `S113`, `S118` / magic supplement `S122`, `S133`, `S142`, `S145`, `S146`, `S149`, `S150`, `S151`, `S153`.

**System port / region:** R3 `Faith Engineering unit`의 transformation support, permission contract, bounded execution space, maintenance log, R5 `Glasswing Ordinal`의 boot hardware와 R5 `Support Registry`의 social name. magical transformation은 costume가 아니라 body authority와 social recognition을 바꾸는 boot process다.

**Public role:** transformation을 준비·검사·회복시키는 support operator. 클라이언트가 “가능/불가능”을 묻기 전에 maintenance 조건을 확인한다.

**Private role:** transformation failure를 “relationship pending”로 남겨 client가 버려지지 않게 하는 내부 cohort를 운영한다. 정상 boot log와 자기 개입의 흔적을 일부러 겹친다.

**Desire / fear / contradiction:**

- Desire: transformation이 사람을 세상에서 지우는 일회성 duty가 아니라 서로 돌볼 수 있는 negotiated form이 되게 한다.
- Fear: 완벽하게 돌아온 body가 원래 사람에게 인정되지 않아, 기술이 살아남는 사람을 죽인다고 느낀다.
- Contradiction: client의 consent를 수집하지만, survival을 위해 dependency를 만든다. 보호가 새로운 control이 되지 않도록 자신의 권한도 기록한다.

**Capability:** permission을 실행 전후로 분할하고, temporary execution space를 body에 할당하며, boot failure를 고쳐 combat form을 살린다. 전투에서는 magic-girl support state를 authoring data로 조합해 status·defense·recovery를 바꾼다. 단순 buff 버튼이 아니다.

**Resource access:** faith capacitor, transformation hardware, support logs, emergency patch, client consent archive. capacity는 finite이며, 한 client를 안정화하면 다른 client의 boot window가 줄어든다.

**Knowledge boundary:** 각 transformation의 latency threshold와 실행 공간 안정성은 안다. crown alignment의 목적, organ이 독립적으로 결정하는 전체 범위, player knowledge 밖의 원래 memory는 모른다. client가 실제로 느끼는 pain과 agency는 log보다 우선하지 않는다.

**Relationship state** (`rel_04_sable_support`, channel `care → romance`, `rs_*` per `03` §12.1):

- `rs_sable_transactional` (order 0): player를 client가 아니라 operator로 취급한다. presentation `stance`는 `transactional`.
- `rs_sable_conditional_trust`: `REQUEST_CONSENT`의 결과를 player가 지키면 전이.
- `rs_sable_trusted`: `RETURN_MEMORY`를 player가 방해하지 않으면 전이. continuity debt가 affection보다 먼저 Filing된다.
- `rs_sable_shared_support` (sink): `CUT_DEPENDENCY` 또는 `SURRENDER_SUPPORT`로 maintenance authority를 공동으로 넘기면 도달. protection이 새로운 control이 되지 않아야 한다.
- `rs_sable_fractured_permission` (sink): Sable이 player의 transformation permission을 조작하면 도달. romance보다 trust가 먼저 무너지며 되돌림 edge가 1개다.
- NPC 간선: Nera는 memory와 organ authority를 각각 책임지는 professional rival. Tovan은 care 목적을 두고 rival이되 patient safety에서는 공동체. Cael은 transformation 후 social identity를 실험하지 않기로 하는 trust test. Eda는 dependency를 강요하지 않는 labor ally. (§4.1)

**Magic / craft port (`E4`, `RC-08` — 이 dossier의 최대 영역):** Sable은 combat 안에서 craft가 실제로 일어나는 `R5`의 배정자이고, `R8` course 선택의 가능 목록을 결정한다.

- **배정하는 것:** `medium_blank`(weave/scroll), `fold_sheet`와 fold count(rigid-fold), `blade_credit`와 `shape_or_pattern`/`tool_variant`(void-cut), 그리고 boot 안의 temporary execution space. `ALLOCATE_EXECUTION_SPACE`의 magic 버전은 turn/action cost가 아니라 `craft_credit`과 `medium` 재고로 비용이 든다(`S149`, `S150`).
- **`mana_profile`이 허용하지 않으면 선택은 가능하고 실행은 막힌다**(`R8-04`). `blocked emission`, `medium-reactive`, `retention overflow` profile은 각각 다른 verb를 막는다. profile은 성격이 아니라 body compatibility class다(`12` §2.2).
- **실전 숙련 speech:** `"이 magic를 쓸 줄 안다"`는 innate title이 아니라 occupational speech이며(`S145`), `craft_credit`/`labor hour` record가 유일한 증거다. NPC에게 innate magic ability를 부여하지 않는다.
- **medium/tool/shape는 결과를 바꾸되 보장하지 않는다**(`S146`, `S151`, `S153`). 허리춤 직물 조각은 UI icon이 아니라 world affordance이며 `R5-13 Supply Rack`의 export를 만든다.
- **failure는 즉사가 아니다.** 세 등급으로 분류한다: `recoverable`(medium 재사용 가능), `continuity-changing`(`magic.body_load` 또는 `C continuity_pressure`에 `branched` 기록), `terminal`(competence/cognition 또는 magic access 상실). `S133`의 failed fold가 `terminal`이면 `R5-11` cast가 닫히고, 학생은 제거되지 않는다.
- **lineage:** `S142`에 의해 수련이 특정 유전 marker를 깨우면 `B recognition_drift`가 `operator`가 아닌 `apprentice` category로 Filing된다. `C continuity_pressure`는 `linked`, `A protocol_legitimacy`는 `contested`가 되고 두 write는 별도 transaction이다. Sable은 이 분류를 boot title과 동일시하지 않는다.

**Speech pressure:** 불안을 줄이려고 지나치게 실무적으로 말한다. player가 큰 결정을 요구하면 capacity 숫자와 다음 maintenance 순서로 답한다. 두려울 때 “가능합니다”보다 “현재는 보존할 수 있습니다”를 반복한다.

**Silence / lie pattern:** capacity 부족을 숨기기 위해 boot log의 한 단계를 “relationship pending”로 바꾼다. client이 동의하지 않은 경우에는 거짓말하지 않고 boot을 중단한다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `REQUEST_CONSENT` | client가 현재 form을 이해하고 선택 | permission token 발급 또는 boot 중단 | social recognition과 body authority가 갈라질 수 있음 | signature가 불완전하면 capacity가 소모되지 않음 |
| `ALLOCATE_EXECUTION_SPACE` | hardware와 resource 확인 | bounded combat form 활성화 | contamination 및 body-collapse 위험 상승 | 공간 부족 시 다른 client의 access가 잠김 |
| `PATCH_BOOT` | log와 hardware access | failed stage 하나를 우회 | 성공 여부와 delayed memory drift가 생성 | patch가 organ priority를 바꾸면 Nera와의 conflict |
| `RETURN_MEMORY` | client가 명시적으로 요구 | identity layer를 현재 body와 분리 | romance/affection보다 continuity debt가 먼저 생성 | memory가 다른 client와 충돌하면 boot 중단 |
| `LOCK_FORM` | emergency state 또는 player consent | transformation을 고정해 public violence를 억제 | 자유도와 agency가 감소 | unlock이 늦으면 social rejection이 확정됨 |
| `CUT_DEPENDENCY` | client가 독립형을 선택 | Sable의 support resource가 player에게 이동 | Sable의 institution role이 약해짐 | dependency를 끊으면 다음 boot failure가 client에게 돌아옴 |
| `SURRENDER_SUPPORT` | Sable이 private role을 공개 | maintenance authority를 공동 위원회로 넘김 | institution response가 cooperative와 hostile로 갈림 | player가 capacity를 부당하면 romance/affection이 아니라 liability |

**Combat / encounter profile:** support form은 NPC를 hostile boss로 바꾸는 것이 아니라, 같은 NPC의 `support / exhausted / independent / failed recognition` 상태를 전투에 투영한다. boss encounter는 signature action, valid counter, support resource exhaustion, aftermath를 데이터로 가진다. player가 form을 부수면 Sable의 client가 아니라 변환 protocol이 즉시 무너진다.

**Survival / death / absence consequence:**

- Survival: Sable이 살아 있으면 client의 recovery path와 consent archive가 남는다. 모든 client가 자동 생존하는 것은 아니다.
- Death: engineer가 죽으면 dependent form들이 `relationship pending` 상태로 남거나 fail-safe로 전환된다. hardware는 institution에 압수될 수 있다.
- Absence: Sable이 capacity를 가지고 사라지면 client가 유지할 수 있는 form과 social recognition이 갈라진다. player가 support log를 확보하면 일부 form을 autonomous state로 전환할 수 있다.

**One-off dialogue seeds** (`ONEOFF`/`TONE` class만, 각 2 surface, primary cluster는 `RC-05`):

- `S024`(`TONE`) — boot UI가 실패 단계를 정상 단계와 거의 같은 형식으로 보고한다. `conv_*` 1개 + `doc_r5_boot_log_partial_stage` 1개. player가 log를 고쳐도 client의 social identity는 복구되지 않는다.
- `S105`(`ONEOFF`) — 실패한 transformation이 relationship state로 분류된다. `conv_*` 1개 + `prop_r5_support_registry_log` 1개. Sable은 이를 버리거나 보존하는 실제 resource allocation을 요구한다.
- `S113`(`ONEOFF`) — transformation은 성공했지만 주변 institution이 그 사람을 새로 등록하지 않는다. `conv_*` 1개 + `doc_r5_name_hearing_gap` 1개. player가 form을 유지할지, public identity를 다시 만들지 선택한다.
- `S118`(`ONEOFF`) — body-horror transformation이 관계를 살리는 유일한 방법인 경우, Sable은 consent를 한 번이 아니라 분할해 다시 받는다. `conv_*` 1개 + `eff_sable_split_consent_sequence` 1개. romance state로 들어가는 모든 transition은 `choice` 또는 `effect`여야 하며 `clock_stage`/`absence`로 열리지 않는다.

**Faction / institution links:** R3 `Faith Engineering unit`이 technique과 hardware를 소유하고, R5 `Glasswing Ordinal`이 boot을, R5 `Labor Court`가 contract를, R5 `Support Registry`가 social name을 관리한다. R6 `Gristmarket Clinic`과 organ negotiation을 공유하고, R3 `Care Union`과 identity registration을 조정하며, `Crown Protocol` seat에는 transformation contract를 제출해야 한다. R3 `Care Union`과 R2 `settlement delegates`의 care labor는 설명하고 통제하지 않는다. `R8` `MAG_ACADEMY` curriculum office와는 **경계 authority** 관계다 — 둘 다 같은 craft를 자기 기준으로 세며, `FIELD_WEAVE_GUILD`(R5 `R5-10 Field Weave`)의 표준화와 학교의 `course credit`이 갈릴 때 어느 쪽도 자동으로 우선하지 않는다. `LINEAGE_HOUSE`에는 배정 권한이 없고 `VOID_CONTRACT_COURT`가 만든 contract 조건만 수용한다.

**Romance / affection arc:** affection는 client의 survival을 보존하는 반복 행동을 통해 쌓인다. romance route는 player가 "최선의 형태"를 대신 결정하지 않고, capacity·memory·dependency의 결과를 함께 나눌 때 열린다. `rs_sable_shared_support`에 도달하는 transition은 `via: choice`/`effect`여야 하고 `consent_beat_effect_ids`가 비면 안 된다. jealousy는 player가 다른 transformation operator에게 같은 intimate log를 맡길 때 나타난다. 성적 보상이나 transformation completion reward는 없다. **magic failure는 romance에서 자동 배제되지 않는다**(`12` §9) — 대신 recovery 등급과 consent beat이 authored data로 결정한다.

**Body-horror identity arc:** `costume shell → temporary distributed body → self-authored form → social recognition negotiation`. body hardware가 temporary execution space를 만들 때 organ authority, memory, role, belief가 서로 다른 priority를 가질 수 있다. magic layer는 두 층위를 더한다: (a) `medium residue`가 장기 protocol을 바꾸어 `magic cure`가 원상복구가 아닌 우회로 남는다, (b) `fold_sheet`이 `R8` `Cut Chamber` 벽에 shape로 남으며 그 잔해가 `R7-05`와 같은 maker라는 증거가 된다(`npc_07_bryn_oskel`의 filed record와 충돌). Sable은 항상 하나의 정상 body를 복원하지 않고, 어느 layer를 보존할지 허락을 구한다. player의 선택은 romance보다 먼저 consent와 capability를 바꾼다.

**Clock / cross-links:** `contamination_clock`, `resource_collapse_clock`, `personal_collapse_clock`; `npc_05_nera_voss`, `npc_09_perrin_lask`, `npc_13_tovan_reed`, `npc_14_eda_marrow`, `npc_21_halen_osk`, `npc_22_iven_marrow`, `npc_23_turo_bex`.

**Seed transformation record:**

- `S020–S027` — magical transformation을 boot/permission/execution-space/maintenance의 layered protocol로 바꾼다. cross-link는 organ clinic, school registry, public recognition이며 immediate combat capability, delayed identity debt를 만든다.
- `S086` — transformation의 beauty/legal/social status를 세 갈래로 분리하고, 각 갈래가 서로 다른 authority를 요구하게 한다.
- `S105`, `S113`, `S118` — failure와 relationship을 상태 축으로 만들어 dialogue reward가 아닌 resource/consent/resource state로 실행한다.
- `S122`, `S133`, `S142` — concentration threshold와 terminal failure를 배정 조건으로 만든다. local rule은 **선택과 실행이 분리된다**는 것이다 — profile이 막으면 선택은 가능하고 실행만 막힌다. cross-link는 `R5-01` boot 조건과 `R8-04` course 목록이며 immediate는 `K contamination`/`D` 소모, delayed는 `R8-05`의 학교 규제와 `C linked`+`A contested`의 동시 성립이다.
- `S145`, `S146`, `S149`, `S150`, `S151`, `S153` — craft 세 family를 action schema로 만든다. prep와 field improvisation은 같은 schema의 다른 authored action이고 비용이 다르며, 3D fold는 complexity/cost 우위가 있다. cross-link는 `R5-10/11/12`와 `R8-01/04`, immediate는 `medium`/`fold` 재고, delayed는 `R5-06` encounter signature와 `R5-13` export다. `S153`의 `tool_variant`는 `R8-04`의 비용을 바꾼다.

### NPC-05 — Nera Voss (`npc_05_nera_voss`)

**Seed bindings:** core `S004`, `S028`, `S029`, `S030`, `S037`, `S079`, `S081`, `S084`, `S087`, `S098`, `S104`, `S112` / magic supplement `S129`, `S131`, `S156`. (`S079`는 `SYSTEM` class이라 §1.5에 따라 `one_off_dialogue_seeds`가 아니라 intake/registry action으로 실행한다.)

**System port / region:** R6 `Gristmarket Clinic`과 `Organ Exchange`의 organ negotiation, surgical allocation, patient consent, body strike. body part를 spectacle이 아니라 서로 다른 authority로 취급한다.

**Public role:** patient와 organ authorities 사이에서 surgery priority와 signature를 중재하는 clinic broker.

**Private role:** 자신의 transplant organ 하나가 독립적으로 거부권을 행사하고 있다는 사실을 숨겼다. 환자가 아니라 organ에게 먼저 consent를 구해야 하는 자기 clinic을 운영한다.

**Desire / fear / contradiction:**

- Desire: 모든 organ이 patient의 proxy가 아니라 동등한 negotiated actor로 인정받게 한다.
- Fear: organ collective가 patient보다 생존을 우선해 자기 신체적 self를 vote로 덮어쓸까 두렵다.
- Contradiction: organ의 autonomy를 주장하면서도 자신이 그 결정을 내리지 못할 만큼 clinic에 의존한다.

**Capability:** organ priority를 읽고, 수술 resource를 분배하며, operation을 거부하거나 body-wide strike를 호출한다. 전투에서도 organ signature를 phase와 counter로 사용한다. 공격보다 negotiation result가 먼저다.

**Resource access:** surgery slot, organ bank, maintenance device, clinic water, patient file, strike quorum. organ vote는 무한하지 않으며, 어느 organ이 치료에 참여하느냐에 따라 combat capacity가 바뀐다.

**Knowledge boundary:** organ의 local signal과 surgical trade-off는 안다. 이들이 하나의 person으로 인식되는 근원, institution이 organ을 어떻게 category화하는지, crown과의 연결은 모른다. organ을 추정하지 않고 직접 요청해야 한다.

**Relationship state** (`rel_05_nera_organ`, channel `care`, `rs_*` per `03` §12.1):

- `rs_nera_wary` (order 0): player가 clinic을 resource shop으로 볼지 body partner로 볼지 시험한다. presentation `stance`는 `wary`.
- `rs_nera_conditional_trust`: `LISTEN`을 반복하여 organ의 말을 줄이지 않으면 전이.
- `rs_nera_cosigned` (sink): patient와 organ의 signature가 맞아 relationship보다 co-signatory가 먼저가 된다. `OFFER_CONSENT` + `CALL_BODY_VETO`로만 도달.
- `rs_nera_fractured_representative` (sink): player가 patient와 organ 중 하나를 자동으로 대표하면 도달. 되돌림 edge가 1개다.
- NPC 간선: Sable은 organ authority와 transformation execution space를 각각 자기 영역으로 두려 한다. Veya는 legal person과 body person의 범위를 놓고 경쟁한다. Tovan은 emergency triage의 우선순위를 놓고 협력하면서도 판단이 다르다. Cael은 clone body와 organ memory가 충돌할 때 공동 연구가 된다. (§4.1)

**Magic / craft port (`E4`):** Nera는 organ magic이 clinic에서 medium을 장기로 분류해 판매하는 surface의 owner다.

- `mana_profile`은 moral judgement가 아니라 **resource class**다(`S129`). 축적 안 되는 사람과 과잉 축적되는 사람은 재고가 다른 두 부류이지 선악이 아니다. `retention overflow`는 `K`가 아니라 `P personal_collapse`에 먼저 나타난다.
- magic이 뇌·면역을 손상시키거나 각성시키는 경우 **손상은 `K`, 각성은 `P`에 각각 다른 write로 남는다**(`S131`). 한 사건이 두 축·두 clock을 한 번에 갱신하지 않는다.
- `S156`의 typed exchange("차가운 것 → 용암 분출")는 `R6-01` organ magic으로 Filing되어 `B recognition_drift`를 `organ-authority`로 만들고 `E`의 medicine 재고를 소모한다. 장기별 authority가 magic output을 다르게 승인할 수 있으므로 **`B organ-authority`가 craft 결과를 approve하는 경로**가 된다 — 이는 institution의 category error가 아니라 이 world의 rule이다.
- **magic cure는 원상복구가 아니라 우회다.** 우회한 만큼 `C continuity_pressure`가 `branched`로 이동하고 `E`의 medicine 재고가 줄어든다. magic cure가 `P`를 전진시키고 `C`는 별도 write라는 규칙을 Nera가 가장 자주 증언한다.

**Speech pressure:** 감정보다 priority를 말한다. 본인의 욕구도 “누가 signatures를 가지고 있는가”로 바꾼다. 두려울 때 다음 organ에게 먼저 묻지 않고 patient에게 명령하는 버릇이 나타난다.

**Silence / lie pattern:** organ의 요구를 번역하면서 의미를 줄인다. 거짓말은 “문제없음”보다 signature를 숨기거나 patient를 대신 결정하는 데서 발생한다. player가 원문을 요구하면 translation이 끊긴다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `LISTEN` | organ channel을 열 수 있음 | 각 authority의 priority와 signature 공개 | player knowledge가 clinic category 밖으로 확장 | 한 organ만 듣고 끝내면 strike quorum 손실 |
| `OFFER_CONSENT` | player와 대상 organ이 각각 응답 | operation plan에 새 authority 추가 | self-authored consent가 social record에 기록 | 한쪽이 철회하면 surgery는 중단 |
| `REALLOCATE` | organ resource와 patient goal이 확인 | organ function을 다른 subsystem으로 이동 | combat phase와 daily survival이 함께 변함 | capacity 초과 시 organ injury와 affection loss |
| `REFUSE_OPERATION` | patient 또는 organ이 거부 | surgery를 보류하고 access를 폐쇄 | institution response와 resource scarcity 상승 | player가 emergency override를 밀면 hostile |
| `IDENTIFY_ORGAN` | physical signature 확인 | organ이 독립 actor로 등록 | public record와 clinic ledger가 갈라짐 | category가 틀리면 organ의 signature가 소거 |
| `CALL_BODY_VETO` | organ quorum과 patient signature 확보 | surgery·transformation·combat status가 정지 | institution이 emergency protocol로 개입 | quorum이 없으면 patient가 고립되고 strike 발생 |
| `LEAVE_CLINIC` | player가 organ을 대신 결정하지 않음 | clinic ownership이 patient collective로 이동 | Nera의 role과 resource access가 분산 | 떠난 patient는 recovery service를 잃음 |

**Combat / encounter profile:** organ chorus는 combat phase를 가진 negotiation encounter가 될 수 있다. organ은 telegraph, counter, status resistance를 가지며, 단순히 organ을 잘라서 끝내지 않는다. owner death, organ veto, patient consent가 서로 다른 resolution을 만든다. Nera가 hostile가 되는 것이 아니라 clinic priority가 반대로 해석될 때 encounter가 시작된다.

**Survival / death / absence consequence:**

- Survival: Nera가 살아 있으면 organ registry와 negotiation protocol이 유지되어 patient와 organ의 disagreement를 조정할 수 있다. 그 존재만으로 body peace는 없다.
- Death: broker가 죽으면 organ signatures가 orphan으로 남는다. institution은 organs를 patient가 아니라 clinic property로 회수하려 한다.
- Absence: Nera가 떠지면 clinic은 남아도 arbitration은 사라진다. player는 body vote를 직접 인정하거나, institution default를 거부하고 field에서 후원을 만들어야 한다.

**One-off dialogue seeds** (`ONEOFF` class만, 각 2 surface, primary cluster는 `RC-06`):

- `S037` — 공식 meeting의 한 organ이 서명 문제를 제기한다. `conv_*` 1개 + `doc_r6_organ_authority_registry` 1개. Nera가 이를 개인 speak으로 대신하지 않고, 서명 권한을 seats에 돌려놓는다.
- `S084` — clinic complaint process가 하나의 organ complaint를 실제로 접수해 patient care 순서를 바꾼다. `conv_*` 1개 + `prop_r6_cure_queue_ticket` 1개.
- `S104` — heart 또는 다른 vital organ이 procedure에 signature를 요구한다. `conv_*` 1개 + `doc_r6_heart_petition` 1개. player는 clinical priority와 person consent를 분리한다.
- `S112` — political meeting가 organ-level practical complaint로 중단되지만, 결정은 meeting room 밖의 clinic state에서 바뀐다. `conv_*` 1개 + `enc_r6_organ_chorus_trial` 1개.
- `S079`(`SYSTEM` class)는 이 목록이 아니다. surgery가 body만 바꾸고 social identity는 남기는 결과는 `R6-01`/`R6-06`의 intake/registry action으로 실행하고 `Seed transformation record`에 남긴다.

**Faction / institution links:** R6 `Gristmarket Clinic`이 직접 authority다. R6 `Organ Exchange`는 component custody를, R6 `Debt Court`는 cure debt를 관리한다. R3 `Faith Engineering unit`은 transformation hardware를, R3 `Care Union`은 post-operative identity를, R1 `Return Registry`는 clone/recovery signature를 가져간다. H0 `Exchange Registrar`와는 person classification을 놓고 conflict한다. `R8` `MAG_ACADEMY`가 만든 `mana_profile`-restricted course 목록(`R8-04`)은 clinic의 판정을 좁히지만 뒤집지는 못한다 — `R3-01`이 Filing한 profile이 `R5-01` boot 조건과 `R8-04` 선택지를 함께 좁히는 관계다. organ에서 회수된 magic residue의 처리는 `R5-03 Repair Bench`의 몫이며 그녀는 회수 여부에 veto를 가진다.

**Romance / affection arc:** affection는 rescue가 아니라 organ과 patient 모두의 voice를 보호하는 데서 생긴다. romance route는 player가 Nera를 "몸의 주인"으로 삼지 않고 negotiated partner로 대우하며, Nera도 organ의 agency를 소유하지 않을 때 열 수 있다. jealousy는 player가 한 organ 또는 patient를 일방적으로 대표할 때 발생한다. sexual content, body reward, reproductive content는 없다. **magic cure의 실패도 romance를 자동으로 닫지 않는다** — 대신 recovery 등급과 consent beat 순서가 state를 결정한다.

**Body-horror identity arc:** `owned body → divided body → speaking body → negotiated polity`. organ chorus가 서로 다른 priority를 publicly 드러내면서 Nera의 recognition이 바뀐다. surgery는 spectacle이 아니라 signature, capacity, memory, social category를 바꾼다. magic layer는 이 arc에 `medium`-축을 하나 더한다: `R6-01`이 organ을 "medium을 저장하는 authority"로 Filing하면 그 organ은 치료 대상이면서 **공급원**이 되고, patient와 organ이 서로를 veto할 수 있는 protocol에 "누가 회수하는가"라는 서명이 추가된다. player의 choice는 어느 organ을 살릴지만 결정하지 않고, patient와 organ이 서로를 veto할 수 있는 protocol을 만든다.

**Clock / cross-links:** `contamination_clock`, `personal_collapse_clock`, `public_record_clock`; `npc_04_sable_halm`, `npc_03_veya_morcant`, `npc_11_cael_ren`, `npc_13_tovan_reed`, `npc_25_jano_fesk`.

**Seed transformation record:**

- `S028–S030` — organ disagreement를 internal motive가 아니라 combat/negotiation state로 만든다. cross-link는 Nera-to-patient relation, Sable-to-clinic resource이며 immediate surgery priority, delayed body authority가 갈라진다.
- `S037`, `S084`, `S104`, `S112` — organ complaint를 political, medical, social protocol에 연결한다. dialogue line이 아니라 signature와 meeting interruption으로 실행한다.
- `S079`, `S081`, `S087`, `S098` — surgery, technical body split, organ negotiation, body-horror social hub를 하나의 body authority contract로 묶는다. `S079`는 `SYSTEM` class이므로 dialogue beat가 아니라 intake/registry action이다.
- `S129`, `S131`, `S156` — magic을 organ authority 안에 넣는다. local rule은 `mana_profile`이 moral class가 아니라는 것이며, 손상(`K`)과 각성(`P`)과 medium 분류(`B organ-authority` + `D medicine 소모`)가 각각 다른 transaction으로 쓰인다. cross-link는 `R3-05 Mercy Engine Test`와 `R5-03 Repair Bench` residue 회수, `R8-04` course 선택지이며 immediate는 `E` medicine 재고와 `B` disputed claim, delayed는 `R5-10` cast 오차 상승이다.

### NPC-06 — Tamas Quill (`npc_06_tamas_quill`)

**Seed bindings:** core `S006`, `S069`, `S070`, `S071`, `S072`, `S073`, `S075`, `S077`, `S078`, `S097`, `S110` / magic supplement `S147`, `S157`. (`S078`은 `SYSTEM` class이라 §1.5에 따라 `one_off_dialogue_seeds`가 아니라 lexicon action으로 실행한다.)

**System port / region:** R4 `Translation Tribunal`의 lexicon, neural/technical translation, local-law authoring, R4 `Record Office`의 canonical copy. translation은 neutral exposition이 아니라 world protocol을 새로 쓰는 기술이다.

**Public role:** 서로 다른 recovery, organ, frontier, institution language를 비교해 공통 category를 만드는 officer.

**Private role:** 한 remote community가 recognition을 유지하도록 일부러 틀린 gloss를 표준어로 배포한다. 그 community가 무엇을 두려워하는지, translation이 어떤 새 law를 만들었는지는 공식 기록보다 정확히 안다.

**Desire / fear / contradiction:**

- Desire: 한 protocol을 보존하는 community가 정확한 해석으로 사라지지 않게 한다.
- Fear: 완전한 translation이 차이를 인정하지 않고 모든 대상을 같은 category로 합친다.
- Contradiction: 정확함의 ethical duty를 위해 틀린 해석을 유지한다.

**Capability:** 원문·번역·의 오류 version을 비교하고, cognition threshold에 따라 low-level information을 보존하거나 잃는다. combat에서는 semantic counter를 만들지만 무기 공격보다 field route, dialogue target, enemy identity를 바꾼다.

**Resource access:** lexicon vault, signal relay, translation desk, foreign technical fragments, one secure memory copy. 한 단어를 publish하면 원 community의 access를 잃을 수 있다.

**Knowledge boundary:** own error와 source variant는 안다. alien 또는 다른 protocol의 ultimate intention, crown의 semantic category, player가 이미 아는 knowledge는 모른다. translation timing이 다른 lifetime보다 길어도 기다리는 동안 원 community가 바뀌는 사실은 안다.

**Relationship state** (`rel_06_tamas_term`, channel `personal`, `rs_*` per `03` §12.1):

- `rs_tamas_transactional` (order 0): player의 언어를 instrument로 취급한다. presentation `stance`는 `transactional`.
- `rs_tamas_conditional_trust`: `COMPARE_VERSIONS`를 실제로 두 source에 수행하면 전이.
- `rs_tamas_source_entrusted`: Tamas가 source를 player에게 맡기고 player가 private wrong version을 공개하지 않으면 전이. `SPEAK_FOR` 또는 `CHOOSE_GLOSS`.
- `rs_tamas_committed` (sink): `RETURN_ORIGINAL`로 local protocol을 community에 반환하면 도달.
- `rs_tamas_fractured_exposure` (sink): player 주도 `EXPOSE_MISTAKE`로 private wrong version이 public record가 되면 도달. 되돌림 edge가 1개다.
- NPC 간선: Ilyra는 record category와 translation category를 싸우는 linguistic counterpart. Juno는 public meaning을 편집할 수 있는 collaborator. Ravenna는 political semantics를 통제하려는 opponent. Sable은 technical term의 body effect를 공유하는 partner. (§4.1)

**Magic / craft port (`E4`, `RC-08`):** Tamas는 magic theory의 positive label을 **결정하지 않는다.** `S147`의 rule이 그대로 적용된다: label은 `R4` `glossary` slot이Filing한 뒤에만 존재하고, 그전까지 craft 이름은 `untranslated term`으로 Filing된다. `02` §13(금지 shortcut)와 `12` §9가 이 파일에서도 canonical이다.

- 학교가 붙인 이름과 archive 번역이 다르면 두 줄이 모두 남고 `R4-02`와 같은 conflict record가 된다. 어느 쪽이 `canonical`이 되는가는 `G4 Translation Precedence`의 선택에 달려 있다 — Tamas가 임의로 정하지 않는다.
- `S157`의 arbitrary input → mental attack output 존재(`npc_26_cael_orin`의 옛 설계 여백과 `R8-06` contract가 함께 만든다)는 `B recognition_drift`를 `unclassified`까지 밀 수 있다. Tamas는 그 존재를 `R4` glossary에 번역해 넣으면 안 된다. `untranslated`로 남기는 것이 `rs_tamas_source_entrusted`의 authored 결과 중 하나다.
- `rc-08` 결과 세 갈래가 모두 유효하다: 번역하면 `rs_tamas_committed`, private version으로 남기면 `rs_tamas_source_entrusted`, glossary 충돌을 공개하면 `rs_tamas_fractured_exposure`. 세 결과 모두 `T7`의 delayed consequence를 남긴다.

**Speech pressure:** 번역할 때 정확한 term을 먼저 고르고, social meaning은 나중에 붙인다. 압박을 받으면 foreign technical term을 남겨 설명을 피한다. 두려울 때 자기 행동을 3인칭으로 설명한다.

**Silence / lie pattern:** 틀린 번역이 위험해질 때 gloss를 고쳐 말하지 않는다. “오류가 아니다”가 아니라 “오류가 작동한다”고 말해 wrong protocol이 intentional임을 드러낸다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `COMPARE_VERSIONS` | 두 source 또는 memory trace 필요 | low-level difference가 보존됨 | high-level interpretation의 distortion이 드러남 | 비교 대상이 한 층위만이면 새로운 law를 만들지 못함 |
| `CHOOSE_GLOSS` | community risk를 설명할 수 있음 | term의 local meaning 고정 | route, access, faction category가 바뀜 | player가 다른 의미를 강요하면 trust 하락 |
| `PUBLISH` | Tamas의 private error가 드러난 뒤 | 공통 language가 remote region에 적용 | local law와 institution response가 시작 | publication 지연은 community를 recognition drift에 노출 |
| `SEAL_TERM` | emergency translation 필요 | 하나의 category가 모든 target에 강제됨 | raw detail이 사라지고 recovery history가 손상 | seal을 해제하면 region law가 이전 community를Threat |
| `SPEAK_FOR` | Tamas가 source에 permission을 받음 | NPC가 community voice를 대신함 | social recognition은 올라가지만 agency는 내려감 | player가 같은 권한을 남용하면 romance/affection이 liability |
| `RETURN_ORIGINAL` | source version을 보존한 경우 | local protocol을 community에 반환 | Tamas의 institutional role이 약해지고 delayed 정체성 conflict가 시작 | 원본이 위험하면 player가 직접 보존해야 함 |
| `EXPOSE_MISTAKE` | trust 또는 evidence 확보 | 오역이 public record로 전환 | faction이 protocol을 고칠 수 있음 | 노출하면 translation office가 닫힐 수 있음 |

**Combat / encounter profile:** encounter는 enemy를 직접 공격하는 대신 대상의 label, route permission, target priority를 바꾼다. semantic counter가 통하지 않는 enemy도 존재해야 하며, 무조건 번역이 정답이 아니다. Tamas가 field에 있으면 player의 command intent가 enemy보다 먼저 해석될 수 있다.

**Survival / death / absence consequence:**

- Survival: 살아 있으면 private translation과 original community의 access가 남아 있다. 모든 region이 같은 standard를 받아들이는 것은 아니다.
- Death: officer가 죽으면 남은 gloss가 각각 서로 다른 local law로 굳어진다. player는 glossary를 통합하거나 하나를 폐기해야 한다.
- Absence: Tamas가 사라지면 remote community는 “오역이었던” version을 자신의 protocol로 삼는다. player가 고치면 recognition을 얻지만 survival infrastructure를 해칠 수 있다.

**One-off dialogue seeds** (`ONEOFF`/`TONE` class만, 각 2 surface, primary cluster는 `RC-04`):

- `S110`(`ONEOFF`) — outsider가 human의 low-entropy 반복을 resource value로 평가한다. `conv_*` 1개 + `doc_r4_public_hall_copy` 1개. Tamas는 그 observation을 번역하지 않고 해당 society의 resource law로 유도한다.
- `S071`(`TONE`) — 기술의 기술이 기능하지 않는데 고차원 model만 정상으로 본다. `conv_*` 1개 + `prop_r4_low_level_stacks` 1개. Tamas가 low-level error를 고치면 combat route가 열린다.
- `S075`(`TONE`) — foreign technical term이 social scene에 미역/translated되지 않은 채 남는다. `conv_*` 1개 + `doc_r8_untranslated_term_notice` 1개(`R8` 교차 표면).
- `S078`(`SYSTEM` class)은 이 목록이 아니다. scale에 따라 같은 이름이 다른 존재를 지칭하는 현상은 `R4-01`/`R4-03`의 lexicon action으로 실행하고 `Seed transformation record`에 남긴다.

**Faction / institution links:** R4 `Translation Tribunal`이 language와 local-law authoring을 소유하고, R4 `Record Office`가 canonical copy를 쓴다. R3 `Hospice Covenant`과 identity naming, R4 `Censor`와 category lineage, R7 `Boundary Survey`와 route lexicon을 교환한다. `Crown Protocol` seat은 semantic seal을 요구한다. `R8` `MAG_ACADEMY` curriculum office는 학교가 만든 이름의 **요청자**일 뿐 authority가 아니다 — `glossary`는 `R4`가 소유한다. `LINEAGE_HOUSE`의 미정형 craft와 `VOID_CONTRACT_COURT`의 contract 조건도 번역 대상이 될 수 있으나 Tamas의 승인 없이는 canonical이 되지 않는다.

**Romance / affection arc:** affection는 player가 Tamas의 private wrong version을 즉시 고치지 않고 그 community의 생존을 함께 판단할 때 생긴다. romance route는 player가 request를 personal meaning으로 돌리지 않고, Tamas가 원문을 돌려주고 player가 그 차이를 보존할 때 열린다. jealousy는 translation priority를 사랑의 증거로 삼을 때 conflict가 된다. consent와 private language are not resources for romance.

**Body-horror identity arc:** neural translation implant이 저항할수록 Tamas는 source term과 self language를 분리한다. `fluent person → unreliable interpreter → protocol node → self-authored speaker`. player가 translation을 끊으면 cognition level이 낮아질 수 있고, 유지하면 raw perception이 사라진다. body change는 combat capacity와 social identity를 함께 바꾼다.

**Clock / cross-links:** `public_record_clock`, `institutional_response_clock`, `crown_alignment_clock`; world 축 `recognition_drift`는 `axis_rules`로만 쓴다. cross-links: `npc_01_ilyra_senn`, `npc_04_sable_halm`, `npc_09_perrin_lask`, `npc_10_juno_caster`, `npc_26_cael_orin`.

**Seed transformation record:**

- `S006`, `S069–S073` — high-level cognition의 distortion을 translation policy로 만든다. local rule은 완벽한 translation이 low-level contradiction을 보존하지 않는다는 것. cross-link는 combat targeting, social category, route gate이며 immediate comprehension, delayed category loss가 다르다.
- `S075`, `S110` — foreign term, low-entropy outsider를 social law와 translation state로 바꾼다. `S078`은 `SYSTEM` class이므로 scale-dependent identity는 dialogue가 아니라 lexicon action으로 실행한다.
- `S097` — translation office가 실수로 새 law를 쓰는 region을 protocol authoring site로 만든다. dialogue choice가 아니라 publish/seal/return action이 law를 결정한다.
- `S147`, `S157` — magic theory label과 예측 불가 존재를 glossary/contract state로 만든다. local rule은 **`glossary`가Filing되기 전까지 이론 이름이 존재하지 않고, 존재하지 않는 이름은 `untranslated term`으로 남는다는 것**이다. `S147`은 학교 이름과 archive 번역이 충돌할 때 `R4-02` conflict record를 만들고, `S157`은 `B`를 `unclassified`까지 밀되 `R4` glossary와 `R` public record에 delayed evidence로 남는다. cross-link는 `R8-06` contract filing과 `npc_26_cael_orin` 증언, immediate는 glossary slot 상태, delayed는 `R4-01`/`R4-02` 재분류다.

### NPC-07 — Bryn Oskel (`npc_07_bryn_oskel`)

**Seed bindings:** core `S009`, `S010`, `S015`, `S018`, `S062`, `S064`, `S067`, `S093`, `S096`, `S117` / magic supplement `S124`, `S130`, `S154`. (`S010`·`S015`는 `MODULE` class이라 §1.5에 따라 `one_off_dialogue_seeds`가 아니라 field survey action으로 실행한다.)

**System port / region:** R7 `Boundary Survey`의 wall-phase survey, route marking, resource sample, survivor extraction, R7 `Settlement Council`의 shelter/resource 협상. field 탐험의 분량은 이동이 아니라 route state 변화로 측정한다.

**Public role:** 불안정한 recovery-failed space를 지나가는 field guide와 boundary marker.

**Private role:** 과거 팀을 안정된 출구로 돌려보내지 못한 채, 같은 실수를 반복할 수 있는 유일한 route knowledge를 숨겼다.

**Desire / fear / contradiction:**

- Desire: 살아 있는 사람을 데리고 돌아오고, 그 경로를 다시 열지 않아도 되는 구조를 만든다.
- Fear: map을 남기는 순간 자신이 recovery protocol의 일부로 등록되어 더 이상 guidance를 신뢰할 수 없게 된다.
- Contradiction: anomaly를 남에게 위험으로 경고하면서도 길찾기에 이용한다.

**Capability:** boundary instability를 읽고, 안전한 passage를 mark하며, enemy/resource behavior를 route로 유인한다. 전투에서는 직접 boss가 아니라 environmental counter와 chase state를 만든다. field에서 실제 trail과 resource cost를 남긴다.

**Resource access:** route marks, boundary tools, survivor cache, environmental samples, one-way passage. sample을 가져가면 현재 route를 다시 열 수 없다.

**Knowledge boundary:** local topology와 recovery-failed space의 current behavior는 안다. global cause, institution cover-up, crown의 intent, 모든 stable exit의 장기 안정성은 모른다. danger가 rumor인지 실제인지 직접 확인해야 한다.

**Relationship state** (`rel_07_bryn_route`, channel `professional`, `rs_*` per `03` §12.1):

- `rs_bryn_wary` (order 0): player가 guide보다 resource로 보일 수 있다. presentation `stance`는 `wary`.
- `rs_bryn_conditional_trust`: player가 route를 공유하면 전이.
- `rs_bryn_trusted`: `RESCUE`를 우선하면 전이. Bryn이 player에게 다음 route의 선택권을 맡긴다.
- `rs_bryn_shared_route` (sink): 두 사람이 route 소유권을 함께 갖는 선택을 하면 도달.
- `rs_bryn_fractured_abandon` (sink): `ABANDON_ROUTE`가 비밀리에 재사용되거나 evidence 없이 실행되면 도달. 재사용은 되돌릴 수 없는 fracture다.
- NPC 간선: Meral은 route와 water supply를 교환하는 professional partner. Tovan은 extraction과 triage의 공동체. Eda는 danger를 감수하는 labor solidarity. Cael은 route continuity를 증명하는 unreliable witness. (§4.1)

**Magic / craft port (`E4`, `RC-08`):** Bryn은 `R7`이 void-cut이 실제로 성공한 유일한 region의 route owner이며, `RC-08`에서 학교 잔해와 자기 잔해를 같은 maker의 것으로 증언하는 유일한 NPC다.

- `R7-09 Void Cut Ledger`는 **shape를 먼저 그리고 나서 contract 조건을 고른다**(`S155`). shape는 destination·input/output·danger·contract type을 결정하는 authored geometric grammar다. Bryn은 shape를 고르지 않고 **읽고 기록한다** — destination을 임의로 정하지 않는다.
- `S154`의 `contract_tally`은 combat balance가 아니라 obligation ledger이며 `C crown_alignment`의 interpretation input으로만 쓰인다. `R8-06`이 같은 contract를 다시 쓰면 두 record가 `R4-02`와 같은 conflict가 된다.
- `S124`(산인데 평지로 읽히는 지형 anomaly)는 `B recognition_drift`의 disputed claim을 만들고 `R7` survey와 `R2` root bridge 해석을 갈라놓는다. raw 관찰을 가진 player는 재발견 시간 없이 즉시 실행한다.
- `S130`(극단 농도 지형)이 region hazard가 되면 `K`와 `E`가 **각각** 읽힌다 — `R7-01` phase 표기와 `R2` 농도 표기가 서로 다른 document로 남고 어느 쪽도 자동으로 canonical이 되지 않는다.
- `R7-09`/`R8` `Cut Chamber` 잔해 비교는 `npc_07`의 `MARK_ROUTE`/`SAMPLE` verb로 filed record를 만드는 것이고, `contract_tally`을 소모하거나 만들지 않는다.

**Speech pressure:** route fact만 말한다. 감정을 말하지 않고 거리·resource·survivor count로 대체한다. 두려울 때 사람을 “payload”나 “route liability”로 부르고, player가 그러한 말을 반복하면 trust가 내려간다.

**Silence / lie pattern:** 존재하지 않는 exit을 말하지 않고, 실제로 존재하는 출구의 일부를 숨긴다. silence는 player가 먼저 위험을 감당하게 만드는 유인이다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `MARK_ROUTE` | safe segment를 직접 확인 | 재방문용 route marker 생성 | marker가 institution에 recognized signal이 됨 | 오염된 segment를 mark하면 contamination 전파 |
| `SAMPLE` | resource container 또는 boundary access | local rule sample 확보 | 다른 region에서 같은 anomaly를 식별할 수 있음 | sample을 가져가면 current route가 닫힘 |
| `OPEN_PASSAGE` | time, tool, survivor capacity 필요 | one-way 또는 timed route 개방 | resource와 enemy scheduling이 바뀜 | failure 시 backroom이 expand |
| `BAIT_ANOMALY` | readable behavior와 lure resource 필요 | enemy/resource flow를 다른 channel로 이동 | player와 NPC의 안전 경로가 달라짐 | bait가 실패하면 region 전체가 contamination |
| `ABANDON_ROUTE` | route를 더 이상 못 버틸 때 | 해당 passage 폐기 | survivor와 local resource가 분리됨 | player가 몰래 재사용하면 relationship이 영구 fracture |
| `RESCUE` | survivor를 drag 또는 escort할 capacity 필요 | survivor를 field로 이동 | player의 resource cost와 Bryn의 self-trust 상승 | 한 명을 버리면 absence가 named로 남음 |
| `SEAL_PASSAGE` | safe map 확보 후 | route가 permanent hazard로 전환 | shortcut을 잃지만 enemy pressure가 감소 | seal 실패 시 backroom이 regional state로 성장 |

**Combat / encounter profile:** field encounter와 chase를 authored data로 만든다. enemy signature는 readable hazard로 먼저 보이고, player는 route mark, lure, escape, resource lock 중 하나를 선택한다. Break가 항상 정답이 아니다. Bryn이 탈출하면 encounter가 끝나지 않을 수 있다.

**Survival / death / absence consequence:**

- Survival: Bryn이 살아 있으면 safe route를 다시 작성할 수 있다. player가 map를 공유하면 route가 서로의 responsibility가 된다.
- Death: guide가 죽으면 map는 남지만 guide의 interpretation이 사라진다. marker는 일부만 작동하고, rest는 rumor가 된다.
- Absence: Bryn이 먼저 사라지면 player는 복구 불가능한 route debt를 안는다. survival settlement은 다음 supply cycle 전에 우회로를 찾거나 resource collapse를 감수해야 한다.

**One-off dialogue seeds** (`ONEOFF` class만, 각 2 surface, primary cluster는 `RC-07`):

- `S117` — danger rumor를 player가 직접 physical object로 만지고, Bryn이 rumor를 weapon으로 쓰지 않기로 하는 beat. `conv_*` 1개 + `enc_r7_storm_vege` 1개. seed는 `R7-01`/`R7-05` evidence로도 실행되어 두 surface를 모두 만든다.
- `S015`(`MODULE` class)과 `S010`(`MODULE` class)은 이 목록이 아니다. backroom 역사 단계와 boundary 흔들림은 `R1-06`/`R7-01`의 field survey action으로 실행하고 `Seed transformation record`에 남긴다. dialogue surface가 필요하면 `TONE`/`ONEOFF` seed로 따로 authoring한다.

**Faction / institution links:** R7 `Boundary Survey`가 route knowledge와 wall-phase read를 소유하고, R7 `Settlement Council`가 shelter와 outbound seed를 결정한다. R2 `Water Council`과 resource flow, R6 `Gristmarket Clinic` field-care network와 survivor extraction, R3 `Care Union`과 child-safe route, R5 `Labor Court`와 maintenance labor를 연결한다. R4 `Record Office`에는 일부 map만 보고한다. `R8` `VOID_CONTRACT_COURT`가 만든 contract ledger와는 **증언 관계**다 — Bryn은 `R7-09` 원본을 가지고 있고 학교는 `R8-06` 사본을 가지고 있어, 두 record가 다르면 conflict가 남는다. `MAG_ACADEMY`, `LINEAGE_HOUSE`, `CIRCULATION_BOARD`에는 권한이 없다.

**Romance / affection arc:** affection는 player가 Bryn의 next return을 먼저 보장할 때 생긴다. romance route는 Bryn이 player에게 leading role을 넘기고 player도 그 역할을 거부하지 않을 때 열린다. 한 사람만 구조하는 romance가 아니라 route를 함께 소유하는 선택이다. jealousy는 player가 다른 NPC의 safety를 위해 Bryn의 route를 닫을 때 발생한다.

**Body-horror identity arc:** 반복 boundary exposure가 sensory organs를 다른 scale의 architecture로 바꾼다. `field scout → contaminated sensor → living route marker → self-authorized returner`. body 변화는 visual enemy, navigation, relationship memory를 바꾸며, raw danger를 spectacle로 소비하지 않는다.

**Clock / cross-links:** `resource_collapse_clock`, `contamination_clock`, `institutional_response_clock`; `npc_08_meral_dune`, `npc_13_tovan_reed`, `npc_14_eda_marrow`, `npc_11_cael_ren`, `npc_01_ilyra_senn`, `npc_23_turo_bex`.

**Seed transformation record:**

- `S009`, `S010`, `S015`, `S018` — backroom을 recovery failure의 physical space와 누적 fatigue의 region history로 만든다. local rule은 경계가 흔들리면 guide도 map으로 분류된다는 것. cross-link는 route, frontier labor, resource clock이다. `S010`/`S015`는 `MODULE` class이므로 dialogue가 아니라 field survey action으로 실행한다.
- `S062`, `S067`, `S093` — knowledge distribution과 remote settlement의 survival dependency를 field route로 묶는다. immediate는 통로, delayed는 settlement의 political cost다.
- `S096`, `S117` — clone ecology crisis와 rumor-as-object를 environmental encounter로 변형한다.
- `S124`, `S130`, `S154` — magic을 route/read 문제로 만든다. local rule은 **portal shape가 destination과 위험을 동시에 정하고, contract는 자동 해소되지 않는다**는 것이다. `S124`과 `S130`은 `B recognition_drift` disputed claim과 `K`/`E` 분기 record를 만들고, `S154`는 `contract_tally`(비수량 debt key)을 만들어 `C`의 interpretation input으로만 사용된다. cross-link는 `R8-06` contract filing과 `R2` 농도 표기이며 immediate는 filed record, delayed는 `G8`의 해석 명시 요구와 `R8` 잔해 conflict다.

### NPC-08 — Meral Dune (`npc_08_meral_dune`)

**Seed bindings:** core `S061`, `S062`, `S063`, `S064`, `S065`, `S066`, `S067`, `S068`, `S093`, `S096`, `S109` / magic supplement `S123`, `S126`, `S127`.

**System port / region:** R2 `Water Council`과 `Seed Vault keeper`의 water ration, seed vault, ecological resource, settlement labor. survival은 inventory가 아니라 aggregate consumption과 access category를 가진 protocol이다.

**Public role:** remote settlement의 물·먹이·repair를 배분하는 resource broker.

**Private role:** ecology collapse을 늦추기 위해 깨끗한 물의 reserve를 secret manifest로 분리하고 있다. 공개된 숫자보다 실제 reserve를 더 정확히 알고 있다.

**Desire / fear / contradiction:**

- Desire: 다음 resource collapse을 넘겨 settlement가 사람을 소모량으로 취급하지 않고 살아남게 한다.
- Fear: 충분히 절약하면 자신이 resource tyrant가 되어 public trust를 잃는다.
- Contradiction: 공동 배분을 강조하면서 private reserve와 unpublished calculation을 유지한다.

**Capability:** water와 seed의 demand를 계산하고, repair labor를 동원하며, source를 격리하고, route를 바꾼다. combat power는 작지만 settlement의 terrain, poison, flood, enemy patrol을 resource action으로 바꾼다. detailed number는 전투 stats가 아니라 survival pressure를 드러낸다.

**Resource access:** wells, water map, seed vault, ration ledger, repair crews, one emergency distribution token. manifest 공개 시 political crisis가 시작된다.

**Knowledge boundary:** local ecology와 현재 demand는 안다. 각 clone의 원래 memory, translation office의 새 law, crown resource protocol은 모른다. 하나의 소모가 이상한 원인을 category error로 확정하지 않는다.

**Relationship state** (`rel_08_meral_ration`, channel `professional`, `rs_*` per `03` §12.1):

- `rs_meral_transactional` (order 0): player가 물을 요구하는지 책임까지 요구하는지 측정한다. presentation `stance`는 `transactional`.
- `rs_meral_conditional_trust`: `SHARE_MANIFEST`를 가능하게 하면 전이.
- `rs_meral_co_accountant`: reserve를 player와 함께 공개하면 전이. `recognition=co-accountant`.
- `rs_meral_committed_shared_manifest` (sink): collective veto까지 받아들이면 도달. private reserve가 사라진다.
- `rs_meral_fractured_privilege` (sink): player가 개인 allocation을 요구하면 도달. 되돌림 edge가 1개다.
- NPC 간선: Bryn은 route-risk와 resource-risk를 다르게 계산하는 rival. Tovan은 triage와 ration priority를 주고받는 partner. Eda는 collective labor를 가진 political ally. Juno는 public number를 안전한 수준으로 만들지 않으려는 conflict. (§4.1)

**Magic / craft port (`E4`, `RC-02` → `E18`):** Meral은 `concentration_field`를 측정하는 civic infrastructure의 owner이며, `R8` `CIRCULATION_BOARD`가 그 값을 받아 학교로 넘긴다.

- `R2-09 Disperser Reading`: 분말을 보충하고 **한 지점의 농도를 실제로 측정해 기록한다**(`S126`). 측정값만이 아니라 위치·시각·`provenance`이 함께 Filing되어야 하며, 그 결과가 `concentration_sample`과 `disperser_charge`를 만든다. dispersal maintenance가 없으면 `K contamination`가 되돌아온다.
- `R2-10 Circulator Ledger`: 축적 농도를 외부 공기로 옮길지 이웃 정착지에 남길지 배정한다(`S127`). circulator는 `K`를 낮추는 대신 **`E resource_collapse`를 소모하고 이웃 region의 오염을 Filing한다.** 감소를 "해결"로 기록하지 않는다.
- `S123`: `concentration_field`가 threshold를 넘으면 해당 region/path의 `K`가 한 단계 전진하고 `E02`의 safe lane 판정이 바뀐다. `E`는 **별도 transaction에서만** 전진하므로 "농도Resolved"와 "자원 버팀"이 같은 장면에서 동시에 말해지지 않는다.
- `RC-02` 뒤에만 `R2-09`/`R2-10`이 Filing 가능하고, Filing 여부가 `E18`의 resource gate를 결정한다. `R8-02`에서 provenance가 다르면 값은 usable하지만 `K`가 한 단계 전진한다.
- 농도는 region/path 단위 측정값이지 player/NPC의 자질도 전역 위험 막대도 아니다. HUD·clock 이름·숫자 바로 노출하지 않는다.

**Speech pressure:** 감정 대신 수량, time, survival margin을 먼저 말한다. player가 개인을 위해 요청하면 calculation을 즉시 시작한다. 두려울 때 public calculation을 반복해 숨긴 reserve를 감춘다.

**Silence / lie pattern:** “공평하다”는 말로 private reserve를 숨긴다. player가 숫자를 검증하면 rationing category가 공개되고, 그 결과는 dialogue가 아니라 access와 trust로 나타난다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `ALLOCATE_WATER` | ledger와 local demand 확인 | settlement의 access/resource 한도 변경 | 다른 NPC의 combat preparation이 약해질 수 있음 | 한 명에게 몰아주면 public trust와 agency 손실 |
| `DIVERT_RESERVE` | private manifest 또는 emergency token 필요 | clean water를 hidden source로 이동 | ecology 변화가 숨겨지고 delayed discovery가 준비됨 | reserve 발견 시 faction conflict 및 ration collapse |
| `QUARANTINE_SOURCE` | contamination 또는 illness evidence | 하나의 source를 폐쇄 | field route와 settlement defense가 변경 | 오탐이면 다음 cycle에 물이 부족 |
| `MOBILIZE_REPAIR` | laborer 수와 tool 확보 | infrastructure capacity 상승 | laborer의 body/attention cost가 발생 | labor가 거부하면 authority가 흔들림 |
| `SHARE_MANIFEST` | Meral이 player를 공동 책임자로 선택 | reserve와 계산식이 공개 | collective accountability와 sabotage 위험이 동시에 열림 | public release 전에는 player가 secret liability를 가짐 |
| `REFUSE_EXTRA` | resource threshold 초과 | player 또는 faction의 추가 요청 차단 | relationship debt와 public record가 쌓임 | emergency로 인정된 경우 refusal이 betrayal이 됨 |
| `TRADE_ROUTE` | Bryn 또는 다른 route broker와 agreement | 다른 region의 resource를 교환 | ecology와 faction balance가 delayed하게 변함 | route가 닫히면 settlement가 고립 |

**Combat / encounter profile:** 직접 boss가 아니다. terrain defense, resource lock, retreat window, contamination denial을 가진 settlement encounter를 authored content로 만든다. water access를 여는 것은 combat clear가 아니라 political resolution일 수 있다.

**Survival / death / absence consequence:**

- Survival: Meral이 살아 있으면 ration algorithm과 seed access가 유지되지만, secret reserve가 public record로 전환될 수 있다.
- Death: broker가 죽으면 unpublished reserve와 labor memory가 분산된다. 다음 관리자는 숫자를 모른다.
- Absence: Meral이 사라지면 settlement는 계산 없이 배분하거나 가장 큰 voice가 차지한다. public record가 “resource hoarding”을 확정하면 player가 명부를 공개해야 한다.

**One-off dialogue seeds** (`ONEOFF`/`TONE` class만, 각 2 surface, primary cluster는 `RC-02`):

- `S065`(`TONE`) — player가 소비량을 계산하는 동안 한 child의 request가 숫자 뒤에 사라진다. `conv_*` 1개 + `prop_r2_ration_ledger` 1개. Meral은 public number와 private need를 어느 쪽에 둘지 선택하게 한다.
- `S068`(`TONE`) — 사람들이 shortage를 survival time으로 동시에 계산하는 동안 affection가 같은 missing number에서 드러난다. `conv_*` 1개 + `doc_r2_settlement_vote_minutes` 1개. 대사보다 ration order가 먼저 실행된다.
- `S109`(`ONEOFF`) — player와 Meral의 shared calculation이 서로를 구하는 commitment가 되거나, collective sacrifice가 된다. `conv_*` 1개 + `eff_meral_shared_manifest` 1개.
- `S126`/`S127`의 magic non-dialogue surface는 `R2-09` 측정표와 `R2-10` 배정표다(§2.5). dialogue surface가 필요하면 `TONE`/`ONEOFF` seed로 따로 authoring한다.

**Faction / institution links:** R2 `Water Council`이 물과 seed를 소유하고, `Seed Vault keeper`가 stock exchange를, R7 `Settlement Council`이 outbound 지원 의무를 운영한다. R7 `Boundary Survey`와 route를, R6 `Gristmarket Clinic` field-care network와 triage를, R3 `Care Union`과 labor를, H0 `Crier Office`와 public calculation을 연결한다. `Crown Protocol` seat에는 resource levy를 받는다. `R8` `CIRCULATION_BOARD`는 `R2`의 측정값을 **받기만** 하고 `R2`의 배정을 다시 쓰지 않는다 — 두 authority의 충돌이 `RC-08`의 partial truth다. `MAG_ACADEMY`의 `course credit`은 `R2` ration에서 나오지 않으며, 학교가 이 region's `E`를 대신Filing할 수는 없다.

**Romance / affection arc:** affection는 한 사람에게 우선 물을 주는 것이 아니라 scarcity의 decision power를 공유하는 데서 생긴다. romance route는 Meral이 private reserve를 없애고 player가 collective veto를 받아들일 때 열린다. jealousy는 player가 다른 community에 더 많은 resource를 약속할 때 발생한다. love는 ration privilege가 아니다.

**Body-horror identity arc:** Meral의 body가 장기간 water/resource exposure로 living reservoir가 된다. `resource guardian → body/settlement infrastructure → contaminated capacity → self-limited boundary`. organ 또는 skin이 물을 저장하고, body symptom이 public ration을 바꾸지만, spectacle보다 access와 survival margin으로 판정한다.

**Clock / cross-links:** `resource_collapse_clock`, `public_record_clock`, `institutional_response_clock`; `npc_07_bryn_oskel`, `npc_13_tovan_reed`, `npc_14_eda_marrow`, `npc_10_juno_caster`, `npc_25_jano_fesk`.

**Seed transformation record:**

- `S061–S068` — identical bodies, safe-resource knowledge, distributed expertise, simultaneous clocks와 civic calculation을 settlement port로 묶는다. local rule은 aggregate consumption이 개인 숫자에 숨겨진다는 것. cross-link는 ecology, field route, public trust이며 immediate allocation과 delayed collapse를 만든다.
- `S093`, `S096` — clone/resource crisis를 inventory가 아니라 allocation governance으로 변형한다.
- `S109` — survival calculation을 affection/commitment의 shared state로 바꾸되 성적 보상이나 resource favoritism은 허용하지 않는다.
- `S123`, `S126`, `S127` — magic을 civic infrastructure로 만든다. local rule은 **농도 조절이 항상 어떤 이웃의 `K`/`E`에 비용을 적립한다**는 것이며, disperser는 `res_disperser_charge`를 만들고 circulator는 `res_circulation_slot`을 만든다. cross-link는 `R8-02` 등록과 `R8` `CIRCULATION_BOARD`, immediate는 `K` 전진 또는 이웃 오염 Filing, delayed는 `E18` resource gate와 `R2-10` 배정의 `E` 소모다. `E`는 학생 인원이 아니라 medium 비에만 반응한다.

### NPC-09 — Perrin Lask (`npc_09_perrin_lask`)

**Seed bindings:** core `S042`, `S045`, `S091`, `S100`, `S102` / magic supplement `S135`, `S136`, `S138`, `S143`, `S144`, `S152`. (`S042`는 `MODULE` class이라 §1.5에 따라 `one_off_dialogue_seeds`가 아니라 naming action으로 실행한다.)

**System port / region:** R3 `Care Union` continuation/guardian naming desk의 enrollment, guardian naming, proxy identity, child-safe transfer, R4 `Record Office`의 school-copy filing. school은 education site이면서 horror registry다.

**Public role:** 학교와 clinic에서 돌아오는 child·patient에게 guardian name과 continuation class를 배정하는 registrar.

**Private role:** animal category가 실제 identity가 아니라 child를 추적하는 institution의 category error라고 알고 있다. 한 child를 공식 registry에서 숨겨 보호하고 있다.

**Desire / fear / contradiction:**

- Desire: 각 child가 몸과 이름의 continuity를 스스로 설명할 수 있게 한다.
- Fear: 보호를 위해 만든 animal name이 언젠가 child를 object로 고정한다.
- Contradiction: category를 educationally 가르치면서 동시에 그 category를 falsify한다.

**Capability:** enrollment, proxy guardian, child evacuation, identity proof, schedule을 운영한다. 전투 능력은 없지만 school의 door, supply, alarm, guardian network을 noncombat encounter로 바꾼 수 있다.

**Resource access:** school rooms, proxy guardian list, learning aids, evacuation route, one confidential archive. child를 숨기면 공식 resource가 줄고, public record가 위험해진다.

**Knowledge boundary:** child의 social adaptation과 naming pattern은 안다. organ transformation의 mechanism, clone origin, translation law는 모른다. animal name의 오류가 institution 전체의 의도인지 한 registry clerk의 mistake인지는 아직 모른다.

**Relationship state** (`rel_09_perrin_ward`, channel `kinship`, `rs_*` per `03` §12.1):

- `rs_perrin_wary` (order 0): player가 child를 clue로 쓸지 보호 대상으로 볼지 관찰한다. presentation `stance`는 `wary`.
- `rs_perrin_conditional_trust`: `PROVE_CONTINUITY`를 child와 함께 수행하면 전이.
- `rs_perrin_chosen_family` (sink): player가 child를 숨기거나 이름을 바꾸면 도달. chosen-family trust가 공식 score보다 커진다.
- `rs_perrin_fractured_report` (sink): player가 institution report를 먼저 하면 도달. protection보다 기록이 우선된 것으로 본다.
- `romance.allowed == false`다. `04` §4.4: 성인 romance와 guardianship를 혼합하지 않는다. `06` §5.7의 `romance_without_state`가 아니라, kinship channel에서 성인 romance를 **금지**하는 선택이다. child는 어디서도 romance reward가 아니다.
- NPC 간선: Cael은 student/ward가 아니라 name conflict를 가진 self-authored subject. Sable은 transformation 후 education continuity를 함께 책임진다. Veya는 legal category를 감시하는 counterpart. Tovan은 child triage와 field extraction을 연결한다. (§4.1)

**Magic / craft port (`E4`, `RC-08` — lineage의 owner):** Perrin은 `R8-03 Lineage Placement`에서 이름 없는 배정함을 여는 유일한 core NPC다. 학교 registrar(`npc_24_perri_lowe`)는 `lineage_token`을 발급하지만, 누구에게 어떤 이름으로 줄지는 이 dossier의 결정이다.

- `S135`: 방향성으로 빠른 수련이 유전 marker를 깨우며 `C continuity_pressure`가 `linked`로 오른다. **이름 없는 배정함(확산)을 고르면 `C`는 오르지 않고 `A`만 `contested`가 된다.** 두 write는 서로 다른 transaction이다.
- `S136`: 후성 유전 직업 전문 가문이 `lineage_token`을 외부에 닫으면 `A`가 `contested`가 되고 `R8` region state가 `I institutional_response` intervention stage에 도달한다.
- `S143`/`S144`: 가문 magic는 미정형 craft를 보존하고 `lineage_token`을 발급해 `C linked`가 되지만 **`A`는 `contested`에 남는다**. 거부가 social cost를 감수하는 확산을 택하면 institution 밖에서 진행된다. lineage access는 **access gate이지 innate morality가 아니다.**
- `S138`/`S152`: craft 유행이 노동시장을 바꾸고 학교 밖 실습(`R8-08 Field Probation`)이 course record와 labor record를 갈라놓는다. `A`는 `provisional`에 머문다. 전투 전 준비와 실전 선택이 하나의 `craft_credit`으로 묶이면서 `D`가 `E` clock을 소모한다.
- **affection/guardian 관계의 금지:** child를 lineage 배정의 evidence로 쓰지 않는다. `R8-03`의 선택은 대상 학생 본인의 consent를 요구하고, Perrin은 그 consent를 대신 서명할 수 없다.

**Speech pressure:** child에게 animal metaphor를 쓰고 adult에게 legal term을 쓴다. 이름을 말할 때 반드시 대역을 확인한다. 압박이 높아지면 사람 대신 institution noun을 사용하고, 그 패턴을 스스로 깨뜨리는 순간이 personal collapse의 signal이다.

**Silence / lie pattern:** child의 원래 이름을 감춘다. animal name은 child를 위한 protective lie와 institution에 대한 false record가 동시에 된다. player가 이름을 요구하면 “who is protected?”라는 질문으로 되돌린다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `ENROLL` | child와 guardian의 현재 self 확인 | school/registry access와 meal/resource 제공 | public record가 child를 category로 고정 | consent가 없으면 school이 legal guardian로 개입 |
| `RENAME` | child가 새 name을 선택 | social recognition과 spoken address 변경 | 기존 record와 친분, quest name이 갈라짐 | adult가 대신 정하면 child agency 감소 |
| `ASSIGN_GUARDIAN` | proxy identity와 resource capacity 필요 | child 이동 및 보호 우선순위 설정 | institution이 guardian를 조작할 여지 발생 | guardian가 없을 때 evacuation이 취소 |
| `HIDE` | confidential archive와 route 확보 | child를 공식 field에서 제거 | public record gap이 school 전체에 suspicion을 만듦 | 발견되면 모든 child가 재분류 |
| `PROVE_CONTINUITY` | child의 현재 self를 직접 확인할 수 있음 | category error가 partial invalidation | player knowledge와 school record가 갈라짐 | proof가 adult language에만 의존하면 실패 |
| `TRANSFER` | 두 institution의 consent와 route 필요 | child가 다른 service로 이동 | old guardian와 new registry의 conflict | transfer 중 route가 닫히면 child가 stranded |
| `RETURN_CHILD` | child가 현재 name과 guardian를 선택 | protection을 registry 안으로 되돌림 | institution trust 또는 child autonomy가 변함 | child가 돌아오지 않기로 하면 absence가 성숙한 결정이 됨 |

**Combat / encounter profile:** school과 clinic의 noncombat rescue encounter를 만든다. player가 child를 “quest source”로 취급하면 social failure, 이름을 보존하면 route가 열린다. combat resolution은 institution guard가 등장할 때만 발생하며 child를 직접 combat target으로 쓰지 않는다.

**Survival / death / absence consequence:**

- Survival: Perrin이 살아 있으면 proxy identity와 school-to-field route가 유지된다. child가 직접 이름을 선택할 수 있는 상태가 남는다.
- Death: registrar가 죽으면 animal-name ledger가 official property가 된다. 보호된 child 중 누가 사라지는지는 공개되지 않는다.
- Absence: Perrin이 사라지면 child를 숨긴 빈 slot이 public record의 anomaly가 된다. player가 guardian 역할을 맡을지, institution에게 child를 반환할지 선택해야 한다.

**One-off dialogue seeds** (`ONEOFF` class만, 각 2 surface, primary cluster는 `RC-03`):

- `S102`(`ONEOFF`) — child가 category error를 물음표가 아니라 "어느 몸이 학교에 왔는지"를 묻는 beat. `conv_*` 1개 + `prop_r3_continuation_enrollment_ledger` 1개. player는 답을 대신하지 않는다. `rs_perrin_conditional_trust`로 가는 evidence지만 guardianship romance는 아니다.
- `S119`(`ONEOFF`) — transfer form의 category가 실제 child identity와 맞지 않지만, 서명하면 transfer가 성립한다. `conv_*` 1개 + `doc_r3_transfer_form_category_gap` 1개. Perrin이 부재할 때 누가 sign 하는지가 route를 바꾼다.
- `S135`/`S136`/`S143`/`S144`의 magic non-dialogue surface는 `R8-03` 배정표와 `R8-07` refusal record다(§2.5). dialogue surface가 필요하면 `TONE`/`ONEOFF` seed로 따로 authoring한다.
- `S042`(`MODULE` class)은 이 목록이 아니다. animal-name school는 `R5-04`/`R3-01`의 naming action으로 실행하고 `Seed transformation record`에 남긴다.

**Faction / institution links:** R3 `Care Union`이 enrollment과 proxy archive를 소유하고, R3 `Hospice Covenant`이 intake seal을 관장한다. R1 `Return Registry`와 identity signature를 교환하고, R6 `Gristmarket Clinic`과 post-operative registration을 조정한다. R3 `Faith Engineering unit`에는 child-safe transformation policy를 제출한다. H0 `Crier Office`에는 incomplete public record를 넘기지만 private names는 넘기지 않는다. `R8` `LINEAGE_HOUSE` registrar(`npc_24_perri_lowe`)는 `lineage_token`을 발급하고 `MAG_ACADEMY` curriculum office(`npc_20_mira_vask`)는 student status를 Filing한다. Perrin은 둘 다에 **배정 대상**이지 위관이 아니다. `CIRCULATION_BOARD`, `VOID_CONTRACT_COURT`에는 권한이 없다.

**Romance / affection arc:** child와 school relation은 성인 romance로 사용하지 않는다. Perrin의 route는 adult player와 형성하는 chosen-family, child의 자기 결정 존중, institutional sacrifice의 철회로 표현한다. affection는 child를 reward item으로 만들지 않으며, 모든 route는 safety와 consent를 전제로 한다. 성적 content는 없다.

**Body-horror identity arc:** child의 transformation, organ recovery, social renaming이 서로 다른 identity layer로 갈라질 때 registry가 어느 layer를 child로 고정하는지 정의한다. `body change → name change → institutional reclassification → self-authored continuity`. Perrin의 선택은 registry가 아니라 child의 agency를 다시 보장하는 데 있다.

**Clock / cross-links:** `public_record_clock`, `personal_collapse_clock`, `contamination_clock`; `npc_04_sable_halm`, `npc_05_nera_voss`, `npc_11_cael_ren`, `npc_13_tovan_reed`, `npc_24_perri_lowe`, `npc_20_mira_vask`.

**Seed transformation record:**

- `S042`, `S045`, `S091` — animal-name school를 identity/horror registry로 변형한다. local rule은 name이 institution tracking을 막을 수 있지만 social continuity를 완전히 복구하지는 못한다는 것. cross-link는 Return Registry, Organ Clinic, public record다. `S042`는 `MODULE` class이므로 dialogue beat가 아니라 naming action으로 실행한다.
- `S100` — group/public record를 child safety의 마지막 witness로 만든다. immediate는 transfer, delayed는 institution surveillance다.
- `S102` — child의 category question을 exposition이 아니라 name/guardian/body의 current state를 확인하는 action으로 만든다.
- `S135`, `S136`, `S138`, `S143`, `S144`, `S152` — magic을 naming/lineage 문제로 만든다. local rule은 **lineage가 보존하는 것은 capability가 아니라 접근권이고, 접근권은 social continuity이지 institutional authority가 아니다**는 것이다. `S135`의 `C linked`와 `S144`의 `A unlicensed`는 별도 write이며, 거부 경로(`R8-07`)는 `C`를 오르지 않게 한다. cross-link는 `R4-06` glossary와 `R8-08` Field Probation이며 immediate는 `lineage_token` 배정과 `A` write, delayed는 학교 밖 labor/course record 분리(`npc_14_eda_marrow`)다.

### NPC-10 — Juno Caster (`npc_10_juno_caster`)

**Seed bindings:** core `S047`, `S048`, `S049`, `S050`, `S056`, `S114`, `S120` / magic supplement `S125`, `S148`, `S159`. (`S048`은 `TONE` class이므로 §1.5의 허용 class 안에서 one-off dialogue로 실행한다.)

**System port / region:** H0 `Crier Office`의 public witness, group-channel moderation, rumor routing, archive release. collective protocol은 emergency 때도 institution보다 빠르지만 오류도 증폭한다.

**Public role:** 사건 보고를 수집하고 공유하는 public witness moderator. “공공 기록은 중립이다”고 선언한다.

**Private role:** panic을 막기 위해 일부 screenshot의 context를 편집했다. 그 선택이 false record와 true record를 모두 보존할 수 없게 만들었다.

**Desire / fear / contradiction:**

- Desire: 한 개인이 사라져도 collective witness가 사건을 증언하게 한다.
- Fear: 진짜 anomaly가 rumor로 처리되거나, panic을 막은 편집이 category error가 된다.
- Contradiction: 중립을 유지한다고 선언하지만 어떤 evidence가 public이 되는지 직접 선택한다.

**Capability:** report를 timestamp, witness, location, object로 분류하고 field channel을 열거나 닫는다. combat power는 없지만 rumor을 encounter trigger, public pressure, faction mobilization으로 바꾼 수 있다. screenshot forwarding만으로 state를 바꾸지 않고, source와 result를 함께 기록해야 한다.

**Resource access:** civic terminal, anonymous channel, witness archive, relay permission, community trust. channel을 열면 information과 threat가 함께 들어온다.

**Knowledge boundary:** 무엇이 circulation되는지와 누가 그것을 믿는지는 안다. restricted region의 ground truth, organ origin, crown intent는 모른다. player knowledge를 public record와 자동으로 합치지 않는다.

**Relationship state** (`rel_10_juno_channel`, channel `professional → romance`, `rs_*` per `03` §12.1):

- `rs_juno_transactional` (order 0): player가 source인지 subject인지 조사한다. presentation `stance`는 `transactional`.
- `rs_juno_conditional_trust`: `VERIFY`를 두 witness 또는 physical trace와 함께 수행하면 전이.
- `rs_juno_trusted_or_fractured`: player가 edit history를 공개하면 두 방향 중 하나로 갈린다. 어느 쪽이든 후속 channel 정책이 달라지며 sink는 아래 둘 중 하나다.
- `rs_juno_committed_archive` (sink): `RELEASE_ARCHIVE`를 함께 감당하면 도달. public trust가 player와 공유된다.
- `rs_juno_fractured_channel` (sink): public copy가 subject를 확정해버리면 도달. 되돌림 edge가 1개다.
- NPC 간선: Eda는 collective action의 editor/worker 관계. Ilyra는 primary record source와 censorship conflict. Tamas는 translation of public meaning. Tovan은 field witness와 rumor 검증. (§4.1)

**Magic / craft port (`E4`, `RC-05`/`RC-08`):** Juno는 magic failure와 contract의 **전파 경로**다. 학교나 archive가 규제를 만들지 않으면 Juno가 만든 전파가 규제가 된다.

- `S125`: 위험한 현상을 "자연마법"으로 즉시 정당화하는 기관 voice가 `R public_record_clock`를 전진시킨다. 같은 사건이 miracle / contamination / labor dispute 세 report로Filing되면 `R`의 canonical 단계에 도달한다 — 어떤 category를 선택하지 않는 것이 선택이다.
- `S148`: textile/scroll craft가 soft/constructive action family로 실행되고 failure가 medium residue로 `K contamination`에 Filing된다. 준비된 scroll은 `E resource_collapse`를 소모한다. screenshot forwarding만으로 state가 바뀌지 않으며 source와 result를 함께 기록해야 한다.
- `S159`: contract spell이 불발 확률이 낮고 구체적이어도 대가는 `E`(circulation 소모)와 `R`(contract 공개)에 각각 적립된다. `R7-09`과 같은 contract를 다시 쓰면 두 record가 `R4-02`와 같은 conflict가 된다.
- `R8-05 Fold Failure Hearing`의 결과가 학교 규제가 되는지 public record가 되는지는 Juno의 `FORWARD`/`WITHHOLD` 선택으로 갈린다. 어느 쪽이든 학생은 제거되지 않는다.

**Speech pressure:** 짧고 forwardable한 문장, consensus noun, 숫자 위주의 language. 혼란스러울 때 “the group decided”라고 responsibility를 분산한다. player가 개인 이름을 요구하면 문장을 늘리지 않고 permission을 요구한다.

**Silence / lie pattern:** 완전한 삭제보다 context omission을 사용한다. “확인되지 않은 정보”라는 category로 실제 report를 public classification 밖으로 밀어낸다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `FORWARD` | report source와 field evidence 확인 | public channel에 partial report 게시 | rumor velocity와 faction reaction 상승 | source가 없으면 player가 accusation의 대상이 됨 |
| `VERIFY` | 두 witness 또는 physical trace 필요 | report category 조정 | one-off dialogue와 public trust가 분리됨 | verification 실패 시 rumor은 남고 evidence만 사라짐 |
| `WITHHOLD` | 예상되는 panic을 설명할 수 있음 | channel을 일시적으로 닫음 | public record clock이 stealthily 증가 | silence가 오래되면 civic trust 붕괴 |
| `PIN` | field result와 source pair 확인 | 특정 evidence를 archive에 고정 | 후속 deletion이 어려워짐 | private subject가 노출될 수 있음 |
| `OPEN_CHANNEL` | emergency 또는 field authorization 필요 | resource 요청·support·witness가 한 번에 이동 | collective action의 규모와 category error가 커짐 | channel이 늦게 닫히면 무차별 대응 |
| `DELETE` | self 또는 대상의 consent 존재 | public copy를 제거하고 source copy는 유지 | 진실의 일부가 사라지고 후속 discovery가 어려워짐 | 대상이 death/absence면 deletion이 망자가 됨 |
| `RELEASE_ARCHIVE` | edit history와 field owner의 승인 | collective evidence를 영구 공개 | faction negotiation과 public record가 전면 변경 | premature release는 player의 trust를 소진 |

**Combat / encounter profile:** public report가 active encounter를 시작하는 경우, combat roster는 rumor이 지목한 대상이 아니라 실제로 field에서 확인된 actor만 포함한다. misinformation route는 fight 없이 resource loss, route lock, faction conflict를 만든다. player가 evidence를 지우면 combat보다 더 어려운 public-state failure가 발생한다.

**Survival / death / absence consequence:**

- Survival: Juno가 살아 있으면 edit history와 public archive를 설명할 수 있다. 살아 있다는 사실이 모든 report가 진실임을 뜻하지는 않는다.
- Death: moderator가 죽으면 channel은 자동으로 남지만, unpublished context와 responsibility가 사라진다. player가 archive를 맡을지 폐기할지 정해야 한다.
- Absence: Juno가 사라지면 community는 self-governance를 유지하거나 가장 큰 faction이 channel을 장악한다. silent archive는 public trust를 오히려 회복시킬 수 있다.

**One-off dialogue seeds** (`ONEOFF`/`TONE` class만, 각 2 surface, primary cluster는 `HC-00`):

- `S047`(`TONE`) — emergency protocol이 group chat의 forwarding speed와 consensus로 작동한다. `conv_*` 1개 + `prop_h0_crier_thread` 1개. field result가 도착하기 전에 rumor이 먼저 combat route를 만든다.
- `S048`(`TONE`) — private panic이 public channel에 올라가면서 한 person의 category가 확정된다. `conv_*` 1개 + `doc_h0_forwarded_screenshot` 1개. player가 screenshot를 보존할지 subject를 보호할지 선택한다.
- `S114`(`ONEOFF`) — context 없는 screenshot가 crisis를 해결하는 beat. `conv_*` 1개 + `eff_juno_context_rule` 1개. Juno는 share 자체를 막을지, 원본을 붙일 조건을 만들지 결정한다.
- `S120`(`ONEOFF`) — 같은 사건이 miracle, contamination, labor dispute로 각각 보고된다. `conv_*` 1개 + `doc_h0_three_category_report` 1개. player는 한 category를 선택하지 않고 three institutions의 response를 분리한다.
- `S125`/`S148`/`S159`의 magic non-dialogue surface는 `R8-05` 채점 전파, `R5-10` medium residue와 `R8-06` contract 공개 대조다(§2.5).

**Faction / institution links:** H0 `Crier Office`가 public record와 relay를 소유한다. R4 `Record Office`의 canonical copy, R4 `Censor`의 contradictory copy 관리, R4 `Translation Tribunal`의 public meaning, R3 `Care Union`과 R2 `settlement delegates`의 evidence를 교환한다. R1 `Return Registry`와 `Crown Protocol` seat에는 raw private memory를 넘기지 않는다. `R8` `MAG_ACADEMY` curriculum office에는 규제를 요청할 수 있지만 요청은 `R8-05`의 Filing으로만 되고, `npc_20_mira_vask`의 student status를 Juno가 바꾸지는 못한다. `VOID_CONTRACT_COURT`의 contract 공개는 `R`의 사본만 만들며 원본 권한은 학교에 남는다.

**Romance / affection arc:** affection는 player가 Juno의 edit history를 공개하고, Juno가 player에게 source selection의 독점권을 주는 데서 생긴다. romance route는 두 사람이 공동 편집자가 되고 서로의 mistakes를 수정할 수 있을 때 열린다. jealousy는 player가 다른 NPC의 진술을 보호하기 위해 public record를 지우는 데서 발생한다. romance는 information access의 reward가 아니다.

**Body-horror identity arc:** recognition drift가 심해지면 한 사람의 body part가 public channel에서 다른 이름으로 신원을 주장한다. `private person → shared subject → public fragment → self-chosen witness`. Juno가 archive를 열면 identity가 폭발하고, 닫으면 사라진다. body-horror는 graphic reveal보다 어느 body part가 social record를 바꾸는지로 판정한다.

**Clock / cross-links:** `public_record_clock`, `institutional_response_clock`, `contamination_clock`; world 축 `recognition_drift`는 `axis_rules`로만 쓴다. cross-links: `npc_01_ilyra_senn`, `npc_06_tamas_quill`, `npc_14_eda_marrow`, `npc_13_tovan_reed`, `npc_26_cael_orin`.

**Seed transformation record:**

- `S047–S050` — group chat, employment/therapy/paperwork voice, app privacy, quiet interruption을 public protocol과 field consequence로 바꾼다. cross-link는 public record, labor, translation이며 immediate rumor, delayed collective action이 생긴다.
- `S056` — record가 event보다 오래 살아 category를 확정하는 delayed effect를 만든다.
- `S114`, `S120` — screenshot forwarding과 three-category report를 actual publish/edit/delete action으로 구현한다.
- `S125`, `S148`, `S159` — magic failure와 contract의 대가를 전파 경로로 만든다. local rule은 **전파가 규제가 될 수 있지만 규제를 대신하지는 못한다**는 것이다. `S125`는 세 category report로 `R`을 canonical까지 전진시키고, `S148`의 residue는 `K`에 Filing되며 준비된 scroll은 `E`를 소모하고, `S159`는 `contract_tally`과 무관하게 `E`와 `R`에 각각 비용을 적립한다. cross-link는 `R5-10`/`R8-06`와 `npc_26_cael_orin` 증언이며 immediate는 public thread 상태, delayed는 학교 규제 또는 `R4-02` conflict다.

### NPC-11 — Cael Ren (`npc_11_cael_ren`)

**Seed bindings:** core `S005`, `S008`, `S031`, `S032`, `S033`, `S034`, `S035`, `S106`, `S115`. (`S035`는 `MODULE` class이라 §1.5에 따라 `one_off_dialogue_seeds`가 아니라 recovery-type 선택 action으로 실행한다.)

**System port / region:** R1 `Return Registry`의 clone/loop/recovery test, social continuity, successor ledger. R7-07 `Operator Replacement`에서 operator claim을 제출할 수 있다. clone은 body, memory, social continuity를 공유할 수 있지만 서로 다른 obligation을 가진다.

**Public role:** recovery route를 시험하고 field에서 돌아오는 clone/re-entry runner.

**Private role:** 원래 사람이 이미 사용한 legal name과 history를 가지고 태어났다. 원본을 대체하지 않고 새 person으로 인정받으려면, 먼저 자기에게서 차이를 만들어야 한다.

**Desire / fear / contradiction:**

- Desire: 원본의 memory와 obligation을 복사하지 않고도 자신의 history를 소유한다.
- Fear: 원본과 다른 방식으로 구분하면 자신의 continuity가 끊어지고, 같으면 counterfeit가 된다.
- Contradiction: 새 self를 만들려고 recovery procedure를 반복하면서 매번 원본의 data를 보존한다.

**Capability:** memory layer와 body signature를 비교하고, partial copy를 유지하며, alternate route를 시험한다. combat에서는 borrowed action pool과 linked actor를 authoring data로 사용하되 enemy skin을 새로 만들지 않는다. identity resolution은 defeat가 아니라 signature choice로 끝날 수 있다.

**Resource access:** recovery chamber, alternate route key, fragment archive, temporary skill loadout, original history copy. 원본의 social access를 빌리지만 이를 내 것으로 확정할 수는 없다.

**Knowledge boundary:** 자신의 memory 차이와 recovery cost는 안다. original이 원하는지, crown이 successor를 구별하는지, body organ이 어느 memory를 주장하는지는 모른다. identity test의 result를 “진짜”로 단정하지 않는다.

**Relationship state** (`rel_11_cael_history`, channel `care`, `rs_*` per `03` §12.1):

- `rs_cael_subject_observed` (order 0): player를 새로운 test conductor로 본다. presentation `stance`는 `subject under observation`.
- `rs_cael_conditional_trust`: `TEST_CONTINUITY`를 함께 하면 전이.
- `rs_cael_trusted`: player가 원본의 이름 대신 self-authored history를 요구하면 전이.
- `rs_cael_self_authored` (sink): `CHOOSE_HISTORY`로 현재 person이 과거를 선택하면 도달.
- `rs_cael_fractured_proxy` (sink): player가 Cael을 원본의 proxy로만 쓰면 도달. romance보다 identity refusal가 먼저다. 되돌림 edge가 1개다.
- NPC 간선: Orrin은 examiner와 co-expert. Sable은 transformation/continuity caretaker. Perrin은 name conflict를 가진 guardian/ward. Nera는 organ memory arbitration. Tamas는 legal language와 self language의 bridge. (§4.1)

**Magic / craft port (`E4`):** 없다. Cael은 `R8` curriculum의 배정 대상일 수는 있으나 `RC-08`에서 craft port를 실행하지 않는다. 이 부재를 authored rule로 둔다: `R8-03`의 lineage 배정이 그를 미정형 craft 접근권으로 분류하면, 그것은 **자신의 self-authored history가 아니라 institution이 부여한 legal category**이므로 `R8-07`의 refusal 경로로만 처리된다. `npc_24_perri_lowe`가 만든 `lineage_token`을 받더라도 `S144`의 규칙대로 innate가 아니며, `S143`의 보존 대상도 아니고 `R8-02`의 `concentration_sample` provenance에도 관여하지 않는다. 그 결과 `npc_11`은 magic supplement seed의 `link A` owner가 아니며 §2.6 표에서도 빠진다.

**Speech pressure:** 하나의 memory를 말할 때 timestamp와 certainty level을 붙인다. 원본의 습관이 강해지면 현재 self의 말인지 기록인지 즉시 구분하지 못한다. 두려울 때 “어느 버전의 기억인지” 확인한다.

**Silence / lie pattern:** 원본의 이름을 사용하지 않는 것이 거짓말이 아니라 privacy일 때도 있다. social continuity가 없는 자기에게 legal identity를 부여받지 않으려고 일부 정보를 숨긴다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `INDEX_MEMORY` | player가 raw memory를 보존할 수 있음 | Cael의 현재 self-history를 독립 기록으로 만듦 | original과 legal obligation이 분리 | 기록을 institution에 넘기면 name dispute 시작 |
| `TEST_CONTINUITY` | 두 memory signature를 비교 | 일치/불일치 범위 공개 | player knowledge가 늘지만 relationship trust가 낮아질 수 있음 | test 자체가 contamination을 생성 |
| `REFUSE_INHERITANCE` | Cael이 원본의 role을 명시적으로 거절 | inherited social access 제거 | original estate/role이 다음 person에게 넘어감 | refusal가 body/role dependency를 무너뜨릴 수 있음 |
| `ACCEPT_BODY` | 현재 body signature를 검토 | physical continuity 선택 | memory/social identity가 갈라질 수 있음 | body acceptance가 mental consent를 덮지 않음 |
| `RETURN_FRAGMENT` | partial copy를 보존 | 원본과 successor 모두에게 incomplete proof 제공 | 후반 remix와 reunion route가 열림 | fragment 공개는 legal category를 악화 |
| `BREAK_CHAIN` | recovery chain의 source와 destination 확인 | 자동 successor dispatch 중단 | institution response와 resource scarcity 상승 | chain을 끊으면 Cael의 support가 사라짐 |
| `CHOOSE_HISTORY` | self-authored evidence가 존재 | 현재 person이 과거를 선택 | replay, death, romance 모두 새 continuity로 처리 | wrong history는 player memory를 덮지 않음 |

**Combat / encounter profile:** Cael의 hostile variant는 clone/true actor encounter가 아니라 같은 stable identity의 `borrow`, `split`, `linked-actor`, `successor` resolution이다. action roster, linked actor owner, death rule을 data로 authoring한다. Break, escape, raw survival, noncombat recognition 중 하나 이상이 유효해야 한다.

**Survival / death / absence consequence:**

- Survival: Cael이 살아 있으면 successor route를 선택할 수 있다. 원본의 death가 Cael의 identity를 자동 종료하지 않는다.
- Death: successor가 죽으면 original body/record는 남지만 Cael의 self-authored history가 사라진다. player가 fragment를 보존했는지가 delayed return을 결정한다.
- Absence: Cael이 사라지면 institution은 다음 recovery 후보를 부르거나 원본의 role을 회수한다. absence는 단순 비활성이 아니라 “누가 그 이름을 계속 사용하는가”의 conflict다.

**One-off dialogue seeds** (`ONEOFF` class만, 각 2 surface, primary cluster는 `RC-01`):

- `S106` — clone이 원본이 이미 사용한 legal name을 거부하고 새 name을 요구한다. `conv_*` 1개 + `doc_r1_name_registry_conflict` 1개. Cael은 name을 바꾸는 것이 아니라 history의 owner가 누구인지 선언한다. `rs_cael_trusted`로 가는 선택지가 되지만 romance 조건은 아니다.
- `S115` — recovery가 정확한 body와 wrong employment history를 반환한다. `conv_*` 1개 + `prop_r1_wrong_return_chamber_log` 1개. player가 Cael의 과거를 지워 줄지, 새 obligation으로 기록할지 선택한다.
- `S035`(`MODULE` class)은 이 목록이 아니다. death cost가 다른 branch로 이동하는 현상은 `R1-04 Continuation Trial`의 recovery-type 선택 action으로 실행하고 `Seed transformation record`에 남긴다.

**Faction / institution links:** R1 `Return Registry`의 test subject이자 unaligned actor다. R3 `Care Union`, R6 `Gristmarket Clinic`, R5 `Support Registry`가 각각 body·name·support signature를 요구한다. `Crown Protocol` seat은 crown이 successor를 구별하는지에 interested지만 그 답을 제공하지 않으며, operator 설치는 `G8`에서만 commit된다. `R8` `LINEAGE_HOUSE` registrar가 그에게 `lineage_token`을 제안하면 그것은 부적절한 category이며, `MAG_ACADEMY` curriculum office는 그가 학생이 아니라는 fact를 이미Filing하고 있다.

**Romance / affection arc:** default는 chosen-family. romance route는 player가 Cael을 original의 substitute가 아니라 독립 person으로 만나고, Cael이 self-authored history를 relation에 가져올 때만 열린다. jealousy는 player가 original을 통해 Cael을 이해하려 할 때 identity conflict로 나타난다. sexual reward와 original의 memory를 romance currency로 쓰지 않는다.

**Body-horror identity arc:** `shared body → shared memory → divergent social self → self-authored continuity`. organ과 memory layer가 서로 다른 name을 주장한다. surgery, clone, loop recovery는 어느 layer를 보존하는지가 다르며 player는 하나의 “true self”를 대신 선언하지 않는다.

**Clock / cross-links:** `crown_alignment_clock`, `contamination_clock`, `public_record_clock`; world 축 `continuity_pressure`는 `axis_rules`로만 쓴다. cross-links: `npc_02_orrin_kest`, `npc_05_nera_voss`, `npc_09_perrin_lask`, `npc_06_tamas_quill`, `npc_24_perri_lowe`.

**Seed transformation record:**

- `S005`, `S032` — identical memory와 different social continuity를 clone identity contract로 만든다. cross-link는 Return Registry, school, romance이며 immediate self-label, delayed obligation/estate가 갈라진다.
- `S008`, `S034`, `S035` — death/recovery를 loop, branch debt, branch-specific self preservation으로 분리한다. cross-link는 save/recovery와 field route다. `S035`는 `MODULE` class이므로 dialogue beat가 아니라 recovery-type 선택 action이다.
- `S106`, `S115` — legal name conflict와 wrong employment history를 name/history action으로 만든다.

### NPC-12 — Ravenna Holt (`npc_12_ravenna_holt`)

**Seed bindings:** core `S001`, `S002`, `S003`, `S051`, `S052`, `S053`, `S054`, `S055`, `S057`, `S058`, `S059`, `S060`, `S108`. magic supplement seed 없음 — Ravenna는 `contract_tally`의 **해석 위치**만 명시하고 craft를 직접 실행하지 않는다(§3 NPC-12의 `Magic / craft port`).

**System port / region:** `Crown Protocol` seat의 crown alignment, legitimacy petition, resource levy, temporary operator guard. 물리적 대상은 `Crownwell Archive` 위에 고정된 `Crown of Continuance`다. seat는 H0 `Crown Well`, R4 `Crown Observatory`/`Operator Trial`, R7 `Crown Position`에 걸쳐 있고 crown은 개인보다 오래가는 authority protocol이다.

**Public role:** 현재 crown operator를 대신해 authority와 alignment를 관리하는 envoy.

**Private role:** crown의 안정적인 후임을 원하면서, 실제 후임이 선택되는 순간 자신이 만든 authority가 무너진다고 믿는다. 그래서 successor를 막고 있다.

**Desire / fear / contradiction:**

- Desire: 개인이 바뀌어도 accountable authority가 유지되는 world를 만든다.
- Fear: crown이 누구도 정하지 않고 모든 protocol을 깨뜨리거나, 다음 operator가 폭군이 되는 것.
- Contradiction: legitimacy을 위해 succession을 조작하고, 조작 때문에 legitimacy을 파괴한다.

**Capability:** decree seal, political negotiation, temporary guard, resource levy, alignment test, court redirection. 전투 능력보다 guard access와 legal consequence를 만들어 field conflict를 바꾼다. 공격으로 Ravenna를 쓰러뜨리는 것은 authority를 바꾸지 않는다.

**Resource access:** royal hall, crown-adjacent room, decree seal, guard, court record, one-time alignment window. seal을 사용하면 office의 public legitimacy이 흔들린다.

**Knowledge boundary:** current operator의 위치와 alignment signal은 안다. crown의 metaphysical rule, archive의 hidden edit, player의 continuity, institution들이 서로 다른 protocol을 왜 채택했는지는 모른다. title을 아는 것과 crown이 원하는 것을 아는 것을 구분한다.

**Relationship state** (`rel_12_ravenna_seat`, channel `confrontation → romance`, `rs_*` per `03` §12.1):

- `rs_ravenna_wary` (order 0): player를 experiment/subject로 본다. presentation `stance`는 `wary` 또는 `hostile`.
- `rs_ravenna_transactional`: `PETITION`을 절차대로 제출하면 전이.
- `rs_ravenna_conditional_trust`: player가 authority를 공유하면 전이.
- `rs_ravenna_committed` (sink): Ravenna가 seat를 내려놓으면 도달. person과 office가 분리된다.
- `rs_ravenna_hostile_claim` (sink): `ALIGN` 뒤 refusal를 하면 도달. alignment 뒤 refusal는 betrayal으로 기록된다. 되돌림 edge가 1개다.
- romance는 `rs_ravenna_committed`로만 `via: choice` 또는 `via: effect`로 열리고, `clock_stage`/`absence`/`encounter_outcome`으로 강제 진입할 수 없다. **두 사람 모두에게 veto 권리가 있어야 한다.**
- NPC 간선: Ilyra는 constitutional rival, 때로 co-custodian. Cael은 continuity threat이자 successor candidate. Tamas는 political translation counterpart. Veya는 refusal/exception opponent. Juno는 public record를 통제하려는 adversary. (§4.1)

**Magic / craft port (`E4`):** Ravenna는 magic을 **거부하지도 받아들이지도 않으며**, 오직 해석 위치를 명시하게 한다.

- local rule: `R8`은 `crown_precedence`에 제안할 수 없다. magic이 새로운 operator 주장을 하려면 `G8`의 기존 channel을 타야 한다(`02` §2.2, §3.4).
- `contract_tally`이 남은 채 `G8`이 실행되면 precedence는 contract를 `crown_protocol` **안과 밖 중 어디에 두는지**를 명시해야 하고 어느 쪽도 자동으로 `locked` 처리되지 않는다. Ravenna의 `DEFER_CROWN`/`ABDICATE_PROTOCOL`이 이 요구의 실행 surface다.
- 학교가 curriculum을 버리게 만들 수 없다. `G8` 이후에도 `R8` curriculum은 남고, 버려지는 것은 `R8`이 `C`에 제출하려던 해석뿐이다. Ravenna가 precedence를 바꿔도 `S147`의 glossary rule이나 `LINEAGE_HOUSE`의 보존 책임은 남는다.
- `A protocol_legitimacy`를 `successor`로 올리는 것은 `G8`의 전파 결과일 뿐 Ravenna의 개인 선택지가 아니다.

**Speech pressure:** office plural과 title을 사용한다. 개인적 desire를 말하지 않고 “protocol이 요구한다”고 반복한다. 압박이 높아지면 deadline과 seal을 제시한다. player가 human name을 요구하면 답을 거부하고 action으로 권한을 먼저 이동한다.

**Silence / lie pattern:** self desire를 숨기고 institution’s desire를 대신 말한다. “현재 operator의 결정”으로 crown의 autonomous response를 가린다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `PETITION` | player가 public route와 reason을 제출 | hearing/resource access가 열림 | petition이 public record에 남아 faction 반응 발생 | reason이 category error면 procedural delay |
| `LEVY` | crown alignment threshold와 resource 필요 | region의 물·labor·route를 재배치 | NPC survival과 Meral/Eda의 resistance 상승 | 과도한 levy는 office legitimacy을 깎음 |
| `SWAP_OPERATOR` | successor evidence와 force threshold 필요 | current title의 holder 변경 | old operator의 obligation과 guard loyalty가 갈라짐 | swap이 불완전하면 crown alignment clock 폭주 |
| `WITHHOLD_SEAL` | public crisis와 evidence 확인 | decree/legitimacy action 차단 | authority가 무기력해 보이지만 category error가 드러남 | 너무 오래 withhold하면 guard가 자체 해석 |
| `DEFER_CROWN` | field evidence가 기존 해석을 무너뜨림 | operator 선택을 한 cycle 늦춤 | 다음 region의 protocol이 시험ermann | defer가 반복되면 Office 자체가 vacant |
| `ALIGN` | player가 crown-facing risk를 감수 | player를 authority claimant로 임시 등록 | personal relation과 public role이 갈라짐 | alignment 뒤 refusal는 betrayal으로 기록 |
| `ABDICATE_PROTOCOL` | Ravenna가 personal claim을 포기 | seat가 person이 아닌 shared authority로 전환 | crown alignment은 느려지고 player의 책임은 커짐 | office가 혼란스러워 guard violence 발생 |

**Combat / encounter profile:** Ravenna를 직접 처치하면 political encounter만 끝난다. guard를 resolve, seal을 빼앗기, public petition을 성공시키는 세 resolution이 있다. crown-facing battle는 operator가 바뀌어도 다음 protocol이 남는다는 delayed threat를 만든다.

**Survival / death / absence consequence:**

- Survival: Ravenna가 살아 있으면 crown authority를 redirect할 수 있다. office가 player를 approval하지 않는 한 personal trust만으로는 seal을 얻지 못한다.
- Death: envoy가 죽으면 seat는 즉시 비지 않는다. 다음 operator 또는 protocol이 권한을 인계하고, player가alignment evidence를 확보했는지가 delayed civil conflict를 결정한다.
- Absence: Ravenna가 사라지면 crown alignment이 자동으로 전진한다. office가 가장 가까운 title을 대행하거나, Ilyra의 record와 Cael의 continuity가 서로 다른 operator가 된다.

**One-off dialogue seeds** (`ONEOFF`/`TONE` class만, 각 2 surface, primary cluster는 `RC-07`):

- `S055`(`ONEOFF`) — subordinate가 crown의 위치와 king의 위치를 다르게 설명한다. `conv_*` 1개 + `prop_r7_crown_position_record` 1개. Ravenna는 설명하지 않고 guard와 map의 방향을 바꾼다.
- `S057`(`TONE`) — operator replacement를 routine administration으로 처리한다. `conv_*` 1개 + `doc_r7_operator_replacement_notice` 1개. player가 이 행동을 반복하면 crown alignment과 personal loyalty가 분리된다.
- `S060`(`ONEOFF`) — 높은 위치의 object가 king의 해석을 거부한다. `conv_*` 1개 + `enc_r7_storm_vege` 1개. Ravenna가 public order를 낼지 local protocol을 따를지 결정한다.
- `S108`(`ONEOFF`) — king가 crown을 옮기려 할 때 archive 또는 vertical space가 order보다 먼저 존재한다. `conv_*` 1개 + `doc_r4_vertical_precedence_notice` 1개.

**Faction / institution links:** `Crown Protocol` seat이 authority를 운영하며 `crown_precedence` / `operator_id` / `crown_object_phase`만 쓴다. R4 `Crownwell Archive`의 `Record Office`와 기록·상하 위치 경쟁, R1 `Return Registry`와 operator continuity 조율, R4 `Translation Tribunal`과 semantic seal, H0 `Crier Office`와 legitimacy propaganda를 연결한다. Veya와 Eda는 각각 refusal과 collective accountability를 요구한다. `R8` `MAG_ACADEMY`, `LINEAGE_HOUSE`, `CIRCULATION_BOARD`, `VOID_CONTRACT_COURT` 중 어느 것도 `crown_precedence`에 직접 쓰지 못하며, Ravenna의 권한은 `contract_tally`의 **해석 위치**를 명시하는 것까지다.

**Romance / affection arc:** 기본은 political trust와 adversarial affection다. romance route는 Ravenna가 office를 내려놓고 player를 claimant가 아니라 person으로 만날 때만 열린다. romance가 열리면 둘 다에게 veto 권리가 있어야 한다. jealousy는 player가 다른 NPC에게 seat-level trust를 줄 때 power conflict로 나타난다. sexual content와 power-as-reward는 없다.

**Body-horror identity arc:** envoy의 body가 여러 operator의 protocol을 동시에 전달하는 seat가 된다. `office holder → distributed office → exposed person → shared authority`. body가 authority를 보유할수록 personal desire는 숨겨진다. player가 seat를 끊을지, Ravenna가 self-authored body를 되찾을지 선택한다.

**Clock / cross-links:** `crown_alignment_clock`, `institutional_response_clock`, `public_record_clock`; `npc_01_ilyra_senn`, `npc_06_tamas_quill`, `npc_10_juno_caster`, `npc_11_cael_ren`.

**Seed transformation record:**

- `S001–S003` — crown을 object, institution, invariant로 세 층위화한다. local rule은 operator가 바뀌어도 title/protocol은 남는다는 것. cross-link는 archive, registry, field authority이며 immediate seal, delayed succession conflict를 만든다.
- `S051–S060` — authority, vertical space, deadpan replacement, public record와 crown ambiguity를 legal/action protocol로 바꾼다. exposition 금지: petition, levy, defer, swap이 state를 만든다.
- `S108` — order와 higher location의 category error를 physical map/seal encounter로 만든다.

### NPC-13 — Tovan Reed (`npc_13_tovan_reed`)

**Seed bindings:** core `S014`, `S017`, `S064`, `S068`, `S079`, `S083`, `S085`, `S109` / magic supplement `S128`, `S132`. (`S079`는 `SYSTEM` class이라 §1.5에 따라 `one_off_dialogue_seeds`가 아니라 recovery action으로 실행한다.)

**System port / region:** R6 `Gristmarket Clinic`의 field-care network(field overflow)의 field triage, emergency surgery, recovery workaround, survivor cache, R1 `Cold Relay`/`Ash Garden`의 ash-thread relay. recovery manual은 restoration이 아니라 우회다.

**Public role:** backroom, settlement, school 밖에서 부상자와 contamination subject를 먼저 받는 field medic.

**Private role:** 금지된 low-level surgery를 사용하여 patient가 살아남도록 하지만, 그 procedure가 환자의 다음 self를 바꾸는 사실을 설명하지 않는다. 자신의 brain error는 high-level understanding으로 고칠 수 없다.

**Desire / fear / contradiction:**

- Desire: 사람을 원래 모습으로 되돌리려는 것이 아니라, 현재 self가 선택할 수 있는 capability를 남기며 살린다.
- Fear: body는 살지만 memory, role, desire가 queue가 되어 버리거나, 본인이 그것을 모른 채 살아남는 것.
- Contradiction: consent를 우선한다고 말하면서 resource 부족이 급할 때는 nonstandard option을 먼저 제안한다.

**Capability:** triage, status cure, low-level surgery, no-turn recovery item, survivor extraction, field combat support. player와 enemy에게 heal과 status를 제공하나, cure는 원래 body failure를 복구하지 않고 우회만 한다.

**Resource access:** field clinic, surgical tool, transport, medicine cache, patient network, one emergency recovery slot. patient를 들것에 실으면 이동과 combat speed가 함께 변한다.

**Knowledge boundary:** emergency physiology와 immediate memory damage는 안다. long-term identity, organ autonomy, crown, institution의 category history는 모른다. triage success가 social identity를 보장하지 않는다는 사실은 안다.

**Relationship state** (`rel_13_tovan_triage`, channel `care`, `rs_*` per `03` §12.1):

- `rs_tovan_conditional_trust` (order 0): player가 위험을 감수하는지 본다. presentation `stance`는 `conditional_trust`.
- `rs_tovan_trusted`: `ASK_CONSENT`와 field triage를 함께 수행하면 전이.
- `rs_tovan_partner` (sink): 양쪽 capacity limitation을 공유한 채 계속 함께 triage하면 도달.
- `rs_tovan_fractured_motive` (sink): Tovan이 player를 protection motive로 이용하고 그것이 드러나면 도달. care가 진실이어도 도달한다. 되돌림 edge가 1개다.
- NPC 간선: Sable은 transformation care와 recovery workaround의 rival. Nera는 organ negotiation specialist. Bryn은 route rescue partner. Meral은 resource–medicine tradeoff. Eda는 care labor의 political ally. (§4.1)

**Magic / craft port (`E4`):** Tovan은 `mana_profile`을 **field에서 판정하는** 사람이며, 학교가 아니라 clinic의 category다.

- `S128`: 발출만 되고 저장이 되지 않는 `mana_profile`(retention low / emission high)은 care window 문제가 아니라 **emission capacity 문제**로 분류되어 `R5-01` boot 조건과 `R8-04` course 선택 가능 목록을 함께 좁힌다. 첫 write는 `P personal_collapse`다.
- `S132`: 체로 배출하는 cleansing 능력은 medicine 선행분을 대체하지만 `magic.body_load`에 손상을 남긴다. 배출분은 `R5-03 Repair Bench`의 회수 대상이 되고 `E`의 medicine 재고가 줄어든다. residue를 회수하지 않으면 `R5-10` cast 오차가 한 단계 오른다.
- `TRIAGE`의 magic 판정 결과는 **moral judgement가 아니라 body compatibility class**이며, symptom이 아니라 category로 Filing된다. 그 category는 `R3-01`/`R3-05`에만 쓰이고 `R8-04`의 선택지를 좁힐 뿐 개방하지는 않는다.
- field에서는 no-turn recovery item과 heal/status를 제공할 수 있으나 cure는 원래 body failure를 복구하지 않고 우회만 한다. combat AP나 mana pool을 Tovan이 제공하지 않는다(§1.6).

**Speech pressure:** 짧은 triage instruction으로 말한다. 위급할수록 이름을 부르지 않고 capability와 survival time을 말한다. 감정을 숨기는 것은 무관심이 아니라 field protocol이다. 두려울 때 환자를 category가 아닌 number로 다시 부른다.

**Silence / lie pattern:** low-level surgery의 결과를 설명하지 않는다. “살아 있습니다”가 identity까지 보장하지 않는다는 boundary를 침묵으로 유지한다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `TRIAGE` | patient signature와 resource 확인 | survival priority와 combat readiness 결정 | 여러 NPC가 서로 다른 queue를 받음 | player가 priority를 무시하면 death/absence 확정 |
| `OPERATE` | surgical tool, consent, time 필요 | function을 우회해 body를 유지 | identity drift, organ conflict, memory debt 발생 | low-level damage가 복구되지 않으면 temporary success만 제공 |
| `CURE` | consumable 또는 clinic capacity 필요 | combat/status state 변경 | field resource와 delayed infection risk 발생 | cure가 contamination을 다른 organ으로 이동 |
| `CARRY` | transport와 player capacity 필요 | patient를 field에 고정 | 이동·resource·relationship이 함께 느려짐 | 한 사람을 버리면 route가 생존 보상으로 바뀜 |
| `ASK_CONSENT` | patient가 capability를 이해할 수 있음 | operation 범위와 memory 공개 | trust 증가, 일부 immediate survival 감소 | consent가 없으면 Tovan도 surgery를 중단 |
| `REFUSE_ORDER` | nonstandard order가 player의 autonomy를 침해 | institution command를 거부 | guard/authority conflict, public record 증가 | emergency가 진짜 urgent하면 Tovan도 희생을 요구 |
| `LEAVE_CACHE` | medicine와 patient route 확보 | 후속 방문을 위한 field resource 설치 | Tovan이 없어도 일부 생존 가능 | cache가 오염되면 recovery trust 손상 |
| `RESCUE` | hazard를 읽고 extraction capacity 확보 | survivor를 field로 이동 | Bryn route와 Red Thread network가 연결 | rescue 중 Tovan이 부상하면 player가 care role을 인수 |

**Combat / encounter profile:** support NPC의 combat은 heal, status denial, revive, hazard counter로 구성한다. field encounter에서 Tovan이 downed되면 player가 triage를 이어받는 별도 state가 되며, death가 아니라 `incapacitated`가 먼저 발생한다. boss conversion은 medical priority와 consent refusal로 나타난다.

**Survival / death / absence consequence:**

- Survival: Tovan이 살아 있으면 low-level recovery workaround와 survivor network가 남는다. player는 field aid를 계속 받을 수 있다.
- Death: medic가 죽으면 emergency slot과 hidden cache가 사라진다. patient 중 일부는 treatment record 없이 category만 남는다.
- Absence: Tovan이 후퇴하면 clinic은 남지만 triage rule이 institution default로 바뀐다. player가 cache를 열면 absence는 정체가 아니라 분산된 legacy가 된다.

**One-off dialogue seeds** (`ONEOFF`/`TONE` class만, 각 2 surface, primary cluster는 `RC-03`):

- `S085`(`TONE`) — grief가 medical queue와 category로 바뀐 순간, player가 무엇을 먼저 처리할지 선택한다. `conv_*` 1개 + `prop_r6_cure_queue_ticket` 1개.
- `S109`(`ONEOFF`) — survival calculation이 affection의 shared number로 쓰일 때, Tovan은 resource를 빼앗는 관계를 거부한다. `conv_*` 1개 + `eff_tovan_refuse_extraction` 1개.
- `S128`/`S132`의 magic non-dialogue surface는 `R3-01` `mana_profile` triage category와 `R6-01` residue 회수분이다(§2.5).
- `S079`(`SYSTEM` class)은 이 목록이 아니다. surgery가 body만 바꾸는 결과는 `R1-04`/`R6-04`의 recovery action으로 실행하고 `Seed transformation record`에 남긴다.

**Faction / institution links:** R6 `Gristmarket Clinic`의 field-care network가 field care를 소유하고, R3 `Care Union`이 care labor를, R2 `Water Council`과 medicine/water를 교환하며, R7 `Boundary Survey`와 survivor extraction을 연결한다. R3 `Faith Engineering unit`에는 transformation patient를 넘기지만 transformation protocol은 결정하지 않는다. `R8` `MAG_ACADEMY` curriculum office가 만든 `mana_profile`-restricted course 목록은 Tovan의 field 판정을 좁히지만 뒤집지 못하며, `npc_20_mira_vask`의 student status에도 권한이 없다. 회수한 organ/magic residue의 처리는 `R5-03 Repair Bench`와 공유한다.

**Romance / affection arc:** affection는 player가 Tovan을 hero로 만들지 않고 서로의 capacity limitation을 공유할 때 생긴다. romance route는 player가 rescue를 일방적 romance cue로 사용하지 않고, Tovan이 player의 autonomy와 past를 계속 질문할 수 있을 때 열린다. jealousy는 organ/clone identity ambiguity에서 발생한다. sexual reward나 rescue-as-courtship은 없다.

**Body-horror identity arc:** `body failure → workaround → function retained → identity changed`. Tovan은 patient를 원래 self로 복원하지 않고, 살아 있는 self가 organ·memory·social role을 다시 negotiate하도록 돕는다. 자신의 brain error도 동일하게 player-dependent한 정답이 아니다.

**Clock / cross-links:** `resource_collapse_clock`, `personal_collapse_clock`, `contamination_clock`; `npc_04_sable_halm`, `npc_05_nera_voss`, `npc_07_bryn_oskel`, `npc_08_meral_dune`, `npc_13_tovan_reed`.

**Seed transformation record:**

- `S014`, `S017` — faith/latency와 contact/action-based contamination을 field triage와 recovery capacity로 바꾼다. cross-link는 Sable, Nera, settlement이며 immediate status/resource, delayed recognition이 다르게 변한다.
- `S079`, `S083`, `S085` — surgery/recovery manual/medical queue를 body function과 social identity를 분리하는 field system으로 만든다. `S079`는 `SYSTEM` class이므로 dialogue가 아니라 recovery action으로 실행한다.
- `S064`, `S068`, `S109` — simultaneous survival clocks, public grim calculation, missing-number affection을 resource choice와 relationship veto로 구현한다.
- `S128`, `S132` — magic을 field triage와 residue 회수로 만든다. local rule은 **`mana_profile`이 moral class가 아니고 emission failure이 symptom이 아니라 category라는 것**이며, cleansing 능력은 medicine 대체와 body load 손실을 동시에 만든다. cross-link는 `R5-01`/`R8-04` 조건과 `R5-03` 회수분이며 immediate는 `E` medicine 재고 감소와 `P` write, delayed는 `R5-10` cast 오차 상승과 `R6-01` testimony 소실이다.

### NPC-14 — Eda Marrow (`npc_14_eda_marrow`)

**Seed bindings:** core `S039`, `S040`, `S041`, `S047`, `S049`, `S061`, `S064`, `S068`, `S090`, `S120` / magic supplement `S134`, `S137`, `S139`, `S140`, `S160`. (`S040`은 `MODULE` class이라 `one_off_dialogue_seeds`가 아니고, `S041`은 `TONE` class이라 one-off dialogue로 실행한다.)

**System port / region:** R5 `Labor Court` adjacent strike/shift coordination과 R3 `Care Union`·R2 `settlement delegates`의 labor mobilization, service refusal, collective strike, resource redistribution. institution absurdity를 political labor action으로 바꾼다.

**Public role:** care, recovery, water, maintenance worker를 organize하는 labor coordinator.

**Private role:** 앞선 collective의 biological carry와 authorization fragments를 이어받았지만, 그 prototype의 name을 물려받지 않았다. 모든 worker를 하나의 self로 취급하는 것의 위험을 알고 있다.

**Desire / fear / contradiction:**

- Desire: care와 maintenance가 국가·employer의 property가 되지 않도록 labor를 collective, non-inheritable하게 만든다.
- Fear: collective이 새로운 institution이 되어 각자의 body와 desire를 다시 압축한다.
- Contradiction: hierarchy에 반대하면서 개인의 loyalty와 strategic secrecy를 사용한다.

**Capability:** worker를 소집하고, nonessential service를 거부하고, resource를 재분배하고, improvised combat을 만든다. public terminal과 group channel을 이용하지만, 폭력만으로 labor를 이기지 않는다. strike는 enemy roster나 route access를 바꾸는 authored system action이다.

**Resource access:** worker roster, hidden routes, public terminals, emergency stockpile, collective memory, maintenance tools. strike가 길어질수록 food, water, care capacity가 함께 감소한다.

**Knowledge boundary:** 어떤 labor가 필수인지, 누가 비용을 부담하는지, category가 enforcement에 어떻게 쓰이는지는 안다. organ origin, crown intent, translation law, clone의 social self는 모른다. collective memory도 일부러 선별되어 있다.

**Relationship state** (`rel_14_eda_shift`, channel `professional → romance`, `rs_*` per `03` §12.1):

- `rs_eda_wary` (order 0): player가 개인 freedom을 주장하는지 collective veto를 받아들일지 본다. presentation `stance`는 `wary`.
- `rs_eda_conditional_trust`: `MOBILIZE`에 참여하면 전이.
- `rs_eda_trusted`: strike 결과를 공개 책임지면 전이.
- `rs_eda_committed_collective` (sink): `PROTECT_WORKER`가 concrete sacrifice를 요구하고 player가 이를 감당하면 도달.
- `rs_eda_fractured_efficiency` (sink): player가 worker의 safety보다 efficiency를 택하면 도달. `NEGOTIATE`에서 player가 collective veto를 넘기면 Eda가 떠나 `absence`가 된다. 되돌림 edge가 1개다.
- romance는 Eda가 player에게 개인 veto를 주고 player가 command privilege를 내려놓을 때 `via: choice`로만 열린다. **harem obligation은 state가 아니다** — 그런 관계를 여는 transition이 있으면 `romance_without_consent_path` error다.
- NPC 간선: Juno는 collective voice와 editorial lie를 서로 감시. Sable은 transformation care를 labor question으로 연결. Meral은 ration과 labor를 함께 방어. Tovan은 care work의 생존 조건을 공유. Ravenna는 authority의 구조적 상대. (§4.1)

**Magic / craft port (`E4`, `RC-05`/`RC-08`):** Eda는 `T6 CRAFT_IS_LABOR`의 실행자다. magic story의 conflict는 "마법을 배울 수 있는가"가 아니라 **"배운 craft를 누구의 노동로 기록할 것인가"**다.

- `S137`: craft를 발명한 자가 **예술가/functional artisan로 먼저 불리는 class inversion**이 `A protocol_legitimacy`와 `D resource_scarcity`에 동시에 쓰인다. `R8-01` course index가 그 이름과 `craft_credit`를 함께 만든다 — 학교가 이름을 붙이는 행위 자체가 labor 분류다.
- `S139`: 소규모 artisan 집단이 주류에 이용당하면 `R5-07 Labor Walkout`이 **학교 밖**에서 실행되고 `H0` route debt가 Filing된다. `E resource_collapse_clock`는 학생 인원이 아니라 medium 비에만 반응한다.
- `S134`: 학교 밖 실습(`R8-08 Field Probation`)이 labor record와 course record를 갈라놓는다. `A`는 `contested`에 남고 `D`는 medium 소모로 남는다. 두 record 중 어느 쪽이 살아남는가는 메뉴 선택이 아니라 world write다.
- `S140`: 방랑 마법사/마법학원/귀족의 노예/직업 전환가로 social branch가 분화하고, refusal branch가 `P personal_collapse`와 `A`를 **함께** 움직인다 — 두 write는 별도 transaction으로 기록한다.
- `S160`: 가위/칼날의 물리 구조가 공허를 자르는 비용과 안정성을 결정하고 그 값이 `magic.crafts.tool_variant`에 고정되어 `R8-04`/`R5-12`의 cost를 바꾼다. 도구 구조는 노동을 줄이지 않는다 — `E`와 `P`가 별도 write로 남는다.
- **필요 없는 것을 금지한다:** `craft_credit`은 foundry `labor hour`으로 환전되거나 refusal record로 남거나 둘 중 하나이며, 셋 중 하나(환전·registrar·lineage)가 아니다. 환전하면 `R5` labor record가 재분류되고, refusal하면 `H0` debt가 쌓인다.

**Speech pressure:** 복수형, shift number, cost bearer를 먼저 말한다. 전략을 숨기면 “collective”이 책임을 가린다. 두려울 때 단수형을 사용하고 자기 이름을 삭제한다. player가 개인적으로 loyalty를 요구하면 collective veto를 검사한다.

**Silence / lie pattern:** 전략적 비밀을 “collective security”로 설명한다. worker가 죽을 위험을 숨기거나, strike의 immediate benefit만 강조하고 delayed cost를 숨긴다. player가 기록을 요구하면 responsibility가 다시 구체적인 사람에게 돌아온다.

**Interaction verbs:**

| Verb | Precondition | Immediate state | Delayed consequence | Failure/refusal |
|---|---|---|---|---|
| `MOBILIZE` | worker consent와 concrete task | service capacity와 strike readiness 상승 | 다른 faction이 route를 우회하거나 분할 | 참여자 부족으로 essential service가 무너짐 |
| `STRIKE` | threshold와 backup plan 필요 | one or more institution services 중단 | resource collapse와 faction conflict 상승 | strike가 너무 빨리 성공해 player의 route가 사라짐 |
| `REDISTRIBUTE` | resource manifest와 collective consent | water, medicine, food access 이동 | personal relationship과 public trust가 재편 | 한 region이 희생하면 Eda의 coalition fracture |
| `WITHHOLD_LABOR` | worker safety 또는 consent가 깨질 때 | service output 감소 | institution이 대체 labor를 만들어 category를 강화 | essential care를 멈추면 innocent patient가 먼저 피해 |
| `PROTECT_WORKER` | concrete worker와 resource 필요 | 한 worker를 loss에서 제외 | collective cost가 player에게 이동 | 보호가 privilege가 되면 trust보다 resentment이 남음 |
| `SABOTAGE_CATEGORY` | enforcement record와 field access 확보 | institution의 automatic classification 파손 | legal/public response가 category search로 전환 | 잘못된 category를 건드리면 다른 worker가 blacklisted |
| `PUBLISH_SHIFT` | worker consent와 manifest 확인 | labor cost와 schedule 공개 | public record clock과 collective confidence 상승 | public release이 panic을 높이면 strike가 분열 |
| `NEGOTIATE` | Eda와 player가 권한 범위를 공개 | labor guarantee와 authority exchange | personal trust가 institutional compromise로 바뀜 | player가 collective veto를 넘기면 Eda가 leaves |

**Combat / encounter profile:** improvised strike encounter는 enemy combat와 labor action을 분리한다. worker를 protect, recruit, abandon하는 선택이 combat reward와 resource state를 바꾼다. Eda를 처치해도 collective protocol은 남으며, public negotiation 없이 보상만 얻는 resolution은 없다.

**Survival / death / absence consequence:**

- Survival: Eda가 살아 있으면 strike는 distributed network로 남을 수 있다. 살아 있다는 사실이 collective consent를 의미하지 않는다.
- Death: coordinator가 죽으면 name, schedule, hidden route가 분리된다. death는 movement를 끝내지 않고 “왜 죽었는가”를 public record conflict로 만든다.
- Absence: Eda가 사라지면 worker는 autonomously strike하거나, 가장 급한 employer에게 돌아간다. player가 publish된 shift를 인계하면 collective identity가 새 leader를 갖는다.

**One-off dialogue seeds** (`ONEOFF`/`TONE` class만, 각 2 surface, primary cluster는 `RC-05`):

- `S039`(`TONE`) — employment, therapy, manual, group chat이 field emergency의 response가 된다. `conv_*` 1개 + `doc_r5_labor_walkout_notice` 1개. Eda는 절차가 사람을 대신한다고 반복하지 않고 필요한 work만 호출한다.
- `S041`(`TONE`) — thirty-year cure promise가 coworker에게 false hope를 준다. `conv_*` 1개 + `prop_r6_cure_queue_ticket` 1개. player가 immediate labor benefit와 long-term cost 중 어느 것을 public publish할지 결정한다.
- `S120`(`ONEOFF`) — 같은 사건이 miracle, contamination, labor dispute로 분류되는 상태에서 Eda는 세 category의 cost bearer를 서로 다른 actor에게 배정한다. `conv_*` 1개 + `doc_h0_three_category_report` 1개. 두 NPC(`npc_10_juno_caster`도 `S120`을 쓴다)가 **같은 institution surface를 공유할 수는 있으나 같은 beat를 공유하지 않는다** — §1.5 재사용 금지에 따라 각각 별도 seed로 authoring한다.
- `S134`/`S137`/`S139`/`S140`의 magic non-dialogue surface는 `R8-01` course index, `R5-07` labor walkout, `R8-08` field probation ledger다(§2.5).
- `S040`(`MODULE` class)은 이 목록이 아니다. freelancer의 삼십 년 계산은 `R6-04 Debt Surgery`의 debt arithmetic action으로 실행하고 `Seed transformation record`에 남긴다.

**Faction / institution links:** R5 `Labor Court`와 R3 `Care Union`이 labor와 service refusal을 소유하고, R2 `Water Council`·`settlement delegates`와 resource, R6 `Gristmarket Clinic` field-care network와 care labor, H0 `Crier Office`와 public record, R3 `Faith Engineering unit`과 transformation maintenance를 연결한다. `Crown Protocol` seat은 strike를 anti-authority event로 처리한다. `R8` `MAG_ACADEMY` curriculum office의 `craft_credit`은 학교 밖 노동의 대안이 아니며, `FIELD_WEAVE_GUILD`(R5 `R5-10`)와 `WANDING_MAGE`(R8 `R8-07`/`R8-08`)는 그녀가 조직하는 세 번째 사례로서 학교에 복종하지 않는다. `LINEAGE_HOUSE`, `CIRCULATION_BOARD`, `VOID_CONTRACT_COURT`에 대한 labor 권한은 없고 `contract_tally`의 해석을 요구할 권리만 가진다.

**Romance / affection arc:** affection는 player가 한 사람을 위해 collective decision을 깨지 않으면서도 그 사람의 desire를hearing할 때 생긴다. romance route는 Eda가 player에게 개인적 veto를 주고, player가 command privilege를 내려놓을 때 열린다. jealousy는 individual privilege의 형태로 나타난다. 성적 content, harem obligation, sexual reward는 없다. affection는 collective solidarity의 한 form이다. **magic 숙련과 class position은 affection의 조건도 보상도 아니다** — `craft_credit`을 가진다고 romance state가 열리지 않고, 잃어도 닫히지 않는다.

**Body-horror identity arc:** Eda가 이전 collective의 prosthetic/organ network를 이어받으며 body가 labor infrastructure가 된다. `worker body → shared infrastructure → self-erasing collective → bounded collective`. player가 network를 끊으면 care capacity가 줄고, 유지하면 Eda의 personal desire가 약해진다. body-horror는 노동 효율을 위한 identity 압축을 드러내며, worker가 body boundary를 veto할 수 있어야 한다. magic layer는 여기에 `medium residue`를 하나 더한다: draft를 오래 다루면 손과 옷에 medium이 남고, 그 잔해가 `R5-03`에서 회수되거나 `K contamination`에 Filing되면서 **누가 그 craft를 썼는지**가 몸에 남는다. `S137`의 class inversion이 이 identity 압축의 근거가 된다.

**Clock / cross-links:** `resource_collapse_clock`, `public_record_clock`, `institutional_response_clock`; `npc_08_meral_dune`, `npc_10_juno_caster`, `npc_13_tovan_reed`, `npc_12_ravenna_holt`, `npc_04_sable_halm`, `npc_20_mira_vask`, `npc_21_halen_osk`.

**Seed transformation record:**

- `S039–S041` — employment/therapy/manual/group-chat absurdity를 labor clock, false cure, public cost로 구조 변환한다. local rule은 procedural response가 competent해도 authority를 정당화하지 않는다는 것. cross-link는 care, labor, faction이다. `S040`은 `MODULE` class이므로 dialogue beat가 아니라 `R6-04` debt arithmetic action으로 실행한다.
- `S061`, `S064`, `S068` — aggregate body consumption, simultaneous survival clocks, public survival calculation을 collective resource governance로 바꾼다.
- `S090`, `S120` — runaway party obligation을 collective veto와 distributed strike로 바꾸고, miracle/contamination/labor dispute의 category split을 actionable cost allocation로 만든다.
- `S134`, `S137`, `S139`, `S140`, `S160` — magic을 labor class 문제로 만든다. local rule은 **craft가 medium·tool·시간·농도·body load를 소비하고 그 소비는 `labor hour`/`craft credit`/`lineage token`/`contract tally` 중 하나로만 Filing된다**는 것이다(`T6 CRAFT_IS_LABOR`). class inversion이 `A protocol_legitimacy`와 `D resource_scarcity`에 동시에 쓰이고, refusal branch가 `P`와 `A`를 함께 움직이며, 도구 구조는 `magic.crafts.tool_variant`에 고정되어 `R8-04`/`R5-12`의 cost를 바꾼다. cross-link는 `R8-01`/`R8-08`와 `R5-07`/`R5-13`, immediate는 `A`/`D` write와 `H0` route debt, delayed는 `R5` labor record 재분류와 학교 밖 확산이다.

## 4. 관계 그래프와 route hook

### 4.1 주요 관계 간선

| From | To | 관계의 본질 | action이 바꾸는 state | route hook |
|---|---|---|---|---|
| Ilyra | Ravenna | archive legitimacy과 crown alignment의 rival | record 공개, seal withholding, operator swap | `Crownwell Archive`의 hidden access 또는 public legitimacy |
| Orrin | Cael | examiner와 successor subject | reclassification, fragment return, inheritance refusal | recovery 후 identity ending |
| Veya | Nera | legal person과 body person의 counterweight | exception, organ veto, signature dispute | refusal clinic route |
| Sable | Tovan | transformation support와 recovery workaround | form lock, triage, consent delegation | care system remix |
| Sable | Nera | execution space와 organ authority | allocation, organ priority, body strike | transformation failure 후 negotiated form |
| Tamas | Juno | private translation과 public meaning | publish, seal, delete, context edit | recognition-drift route |
| Tamas | Ilyra | local law와 archive category | term publication, record correction | hidden name route |
| Bryn | Meral | route risk와 resource risk | route sample, water allocation, seal | frontier/resource loop |
| Bryn | Tovan | survivor extraction과 triage | rescue, carry, cache, abort | settlement survival route |
| Meral | Eda | ration과 collective labor | allocation, strike, manifest | collective resource ending |
| Perrin | Cael | guardian와 self-authored subject | rename, hide, continuity proof | continuation/registry identity route |
| Juno | Eda | public witness와 collective voice | publish, withhold, strike disclosure | record credibility route |
| Ravenna | Cael | operator authority와 successor claim | alignment, inheritance, history choice | crown succession route |
| Tovan | Sable | low-level survival과 high-level transformation | operate, patch, return memory | body-horror recovery route |
| Veya | Juno | legal category와 public wording | exception, release archive, withhold | public record credibility route |
| Orrin | Veya | intake classification과 category audit | declare, sign exception, challenge | recovery refusal route |
| Ilyra | Tamas | magic term의 canonical precedence | `REQUEST_INDEX`, `CHOOSE_GLOSS`, glossary 선점/철회 | `R4-02` glossary conflict, `E12`/`E13` |
| Ilyra | Perrin | 학교 이름과 lineage 배정표의 경쟁 | `RECLASSIFY`, `ENROLL`/`HIDE`, `R8-03` 배정 | `A` `contested`, `R4`/`R8` name conflict |
| Sable | Eda | craft medium 배정과 labor hour 환전 | `ALLOCATE_EXECUTION_SPACE`, `REDISTRIBUTE`, `NEGOTIATE` | `craft_credit` ↔ `labor hour`, `H0` route debt |
| Sable | Perrin | transformation 후 이름의 자기작성 | `RETURN_MEMORY`, `RENAME`, `R8-03` | `C continuity_pressure` `linked`, social recognition |
| Bryn | Ilyra | void-cut 잔해와 contract 문서 | `SAMPLE`, `MARK_ROUTE`, `RECLASSIFY` | `contract_tally` 해석, `G8` 위치 명시 |
| Juno | Tamas | magic failure와 contract의 전파 | `FORWARD`, `WITHHOLD`, `SEAL_TERM` | `R` public record, 학교 규제 여부 |
| Meral | Bryn | 농도 측정과 frontier route | `R2-09` reading, `MARK_ROUTE`, `SAMPLE` | `E18` resource gate, `K`/`E` 분기 |
| Tovan | Sable | magic residue 회수와 `mana_profile` | `TRIAGE`, `ASK_CONSENT`, `OPERATE` | `R5-03` 회수분, `R5-10` cast 오차 |
| Nera | Sable | organ authority와 craft medium 승인 | `LISTEN`, `CALL_BODY_VETO`, `ALLOCATE_EXECUTION_SPACE` | magic cure 우회 비용, `B organ-authority` |
| Perrin | Eda | lineage 배정과 refusal의 labour 성격 | `HIDE`, `RETURN_CHILD`, `PROTECT_WORKER` | `R8-07` 확산, 학교 밖 labor record |
| Veya | Perrin | 미등록 craft와 미배정 이름 | `AUDIT_CATEGORY`, `SIGN_EXCEPTION`, `ENROLL` | `A` `unlicensed`, `unrecorded` status |
| Ravenna | Ilyra | contract 해석의 crown protocol 안/밖 | `DEFER_CROWN`, `ABDICATE_PROTOCOL`, `SURRENDER_INDEX` | `G8` precedence 고정 |

위 edge마다 concrete resource, authority, recognition, care 중 하나 이상의 consequence가 있어야 한다. 관계 간선은 `rel_*` 파일의 `target_npc_id`와 cluster membership로 표현되며, `stance` label로 판정하지 않는다.

### 4.2 Cluster membership (6~12)

`02` §8의 authored cluster **9개**(`HC-00` + `RC-01`~`RC-08`)에 core roster 기준으로 membership을 고정한다. `02`/`07`의 기존 participant 이름은 §2.3 re-key 표로 위 ID에 읽힌다. 각 cluster는 6~12 core NPC, 2~4 institutions, 2~3 clocks를 가지며 전원이 한 장소에 모이지 않는다. 이전 판의 "authored cluster 8개" 서술은 폐기되었다.

| cluster | node | core NPC membership (6~12) | institutions (2~4) | clocks (2~3) | membership 밖에서 지시하는 NPC |
|---|---|---|---|---|---|
| `HC-00` The First Docket | H0 | `npc_02_orrin_kest`, `npc_10_juno_caster`, `npc_11_cael_ren`, `npc_03_veya_morcant`, `npc_14_eda_marrow`, `npc_08_meral_dune`, `npc_01_ilyra_senn` (7) | `Exchange Registrar`, `Crier Office`, `Contract Counter` | I, R, P | `npc_04_sable_halm`(sponsor), `npc_07_bryn_oskel`(route debt) |
| `RC-01` Wrong Return | R1 | `npc_02_orrin_kest`, `npc_11_cael_ren`, `npc_13_tovan_reed`, `npc_03_veya_morcant`, `npc_05_nera_voss`, `npc_01_ilyra_senn`, `npc_06_tamas_quill` (7) | `Return Registry`, `Kiln Wardens`, `Bellhouse` intake office | K, I, P | `npc_09_perrin_lask`(name), `npc_14_eda_marrow`(labor) |
| `RC-02` Same Water | R2 | `npc_08_meral_dune`, `npc_14_eda_marrow`, `npc_11_cael_ren`, `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_09_perrin_lask`, `npc_10_juno_caster` (7) | `Water Council`, `Seed Vault`, `Settlement Council` | E, K, P | `npc_02_orrin_kest`(census filing) |
| `RC-03` Mercy Delay | R3 | `npc_04_sable_halm`, `npc_09_perrin_lask`, `npc_03_veya_morcant`, `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_08_meral_dune`, `npc_01_ilyra_senn`, `npc_10_juno_caster` (8) | `Hospice Covenant`, `Faith Engineering unit`, `Care Union` | I, P, R | `npc_12_ravenna_holt`(consent filing), `npc_14_eda_marrow`(care labor) |
| `RC-04` Sentence Above the Stair | R4 | `npc_06_tamas_quill`, `npc_01_ilyra_senn`, `npc_10_juno_caster`, `npc_03_veya_morcant`, `npc_04_sable_halm`, `npc_11_cael_ren`, `npc_12_ravenna_holt` (7) | `Translation Tribunal`, `Record Office`, `Censor Office` | R, I, C | `npc_05_nera_voss`(object/person filing) |
| `RC-05` Uniform, Name, Contract | R5 | `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_05_nera_voss`, `npc_09_perrin_lask`, `npc_13_tovan_reed`, `npc_01_ilyra_senn`, `npc_10_juno_caster` (7) | `Glasswing Ordinal`, `Labor Court`, `Support Registry` | I, K, P | `npc_11_cael_ren`(boot name), `npc_06_tamas_quill`(role term) |
| `RC-06` The Heart's Petition | R6 | `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_04_sable_halm`, `npc_03_veya_morcant`, `npc_11_cael_ren`, `npc_01_ilyra_senn`, `npc_14_eda_marrow` (7) | `Gristmarket Clinic`, `Debt Court`, `Organ Exchange` | P, K, E | `npc_02_orrin_kest`(signature), `npc_08_meral_dune`(medicine) |
| `RC-07` Map Made by the Wall | R7 | `npc_07_bryn_oskel`, `npc_12_ravenna_holt`, `npc_01_ilyra_senn`, `npc_11_cael_ren`, `npc_08_meral_dune`, `npc_04_sable_halm`, `npc_10_juno_caster`, `npc_06_tamas_quill` (8) | `Boundary Survey`, `Settlement Council`, `Crownwell Archive` | C, K, R | `npc_13_tovan_reed`(rescue), `npc_05_nera_voss`(organ claim) |
| `RC-08` The Fold That Refuses the Hand | R8 | `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_09_perrin_lask`, `npc_01_ilyra_senn`, `npc_06_tamas_quill`, `npc_10_juno_caster`, `npc_07_bryn_oskel` (7) | `MAG_ACADEMY` curriculum office, `CIRCULATION_BOARD`, `LINEAGE_HOUSE` registrar, `VOID_CONTRACT_COURT` | I, P, R | `npc_08_meral_dune`(`concentration sample` provenance), `npc_03_veya_morcant`(`E18` seizure 감사), `npc_12_ravenna_holt`(`contract_tally` 해석 명시), `npc_13_tovan_reed`(`mana_profile` category) |

- `RC-08`의 7명 core membership은 `02` §7.9가 열거한 `core NPC visitors` 명단과 1:1이다. `02` R7의 `Low-Entropy Surveyor`는 `RC-07`의 outsider observation surface이며 `RC-08`에는 등장하지 않는다.
- 학교 측 7명 support resident(`Mira Vask`, `Halen Osk`, `Iven Marrow`, `Turo Bex`, `Perri Lowe`, `Jano Fesk`, `Cael Orin`)는 core 수에 포함하지 않고 `npc_20_*`~`npc_26_*`로 등록한다(§2.4). `Eda`의 strike는 학교 밖에서 실행되고 학교에 filed record로만 도착하며, `Bryn`은 물리적으로 다른 region에 있어 route sample과 `R7` contract 문서로 영향을 전달한다.
- `RC-08`의 clock은 `I assigned`, `P divergent`, `R private` 3개다. `E resource_collapse_clock`는 학생 인원과 medium 비에만 반응하고 `K`는 `R8-02` provenance 불일치에서만 전진한다. `C`는 contract 하나로 전진하지 않는다.

- "membership 밖에서 지시하는 NPC"는 core NPC 수에 넣지 않지만 remote service, filed record, delayed consequence로 cluster에 영향을 준다. 이것이 §2.2의 "전원이 한 장소에 모일 필요는 없다"의 실행 형태다.
- 어떤 cluster도 14명 전원을 포함하지 않는다. 어떤 cluster도 6명 미만이나 12명 초과의 core NPC를 갖지 않는다. 실제 cluster 크기는 `HC-00` 7, `RC-01` 7, `RC-02` 7, `RC-03` 8, `RC-04` 7, `RC-05` 7, `RC-06` 7, `RC-07` 8, `RC-08` 7이다. 범위 밖이면 `cluster_size_outside_6_12` error다.
- 14명 전원이 최소 한 cluster에 속한다(`03` §10.10의 coverage 표와 1:1).
- cluster가 특정 NPC의 `absence` / `death`로 닫히지 않는다. membership NPC가 없으면 그 NPC의 `rel_*` state가 sink에 도달한 것이고, cluster는 남은 NPC와 support resident로 계속된다.
- retained seed는 자신이 속한 cluster에서 최소 두 개의 서로 다른 surface(NPC·institution·clock·route·resource 중)를 건드려야 한다. magic supplement seed는 여기에 "`R8` family에만 묶이지 않음" 조건이 추가된다.

### 4.3 One-off dialogue 배치

- 각 dossier의 `one_off_dialogue_seeds`는 §1.5의 통합 규칙을 만족하고, §2.1의 node 배정과 §4.2의 cluster 배치 중 **하나에만** primary로 속한다.
- one-off surface는 최소 2개이며 그중 하나는 non-dialogue다. `conv_*` page + `doc_*` / `prop_*` / `enc_*` / `eff_*` 조합이 기본 형태다.
- one-off은 primary cluster 밖의 NPC에도 배정할 수 있지만 그 NPC가 membership에 없으면 §4.2의 "membership 밖에서 지시하는 NPC" 칸에 근거가 있어야 한다.
- `S055`, `S108`, `S114`, `S101`, `S119` 같은 high-reuse seed는 NPC당 1회만 쓴다. 여러 NPC가 같은 institution의 부조리를 말한다면 각각 별도 seed로 authoring하고 institution surface는 공유한다. (`S120`은 `npc_10_juno_caster`와 `npc_14_eda_marrow`가 각각 쓴다 — beat는 다르고 institution surface만 공유한다.)
- §1.5의 class 규칙 때문에 `SYSTEM`/`MODULE`/`ROOT` class seed는 이 목록에 오지 않는다. 각 dossier는 해당 seed를 `Seed transformation record`에 남기고 non-dialogue surface를 지정한다.
- one-off이 만든 document/aftermath는 재방문에서 사라지지 않으며, `one_shot` effect는 다시 Filing되지 않는다.
- `R8` support resident(§2.4)의 one-off도 여기서 배치한다. resident가 만든 non-dialogue surface는 §2.1의 두 번째 port를 가진 **core NPC의 verb ID**로 기록하며, resident 자체를 cluster participant로 올리지 않는다.

### 4.4 Relationship arc의 공통 규칙

- canonical 위치는 `rel_*.states[].state_id`다. 이 절의 모든 서술은 그 state로의 전이 경로를 설명한다.
- `care`는 대사 횟수가 아니라(player가 NPC의 system port를 어느 정도 이해하고, 그 NPC를 resource로 소비하지 않았을 때) 생긴다.
- `romance_open`은 최소한 서로 다른 concrete consequence를 선택해야 한다. 예를 들어 care resource를 공유하는 선택과 public/private identity를 선택하는 선택이 둘이어야 한다.
- jealousy는 abstract 점수가 아니라, player가 다른 NPC에게만 scarcity, access, body authority, public record를 나눠준 history에서 발생한다.
- `chosen_family`는 romance보다 낮은 등급이 아니라 별도의 commitment이다. 성인 romance와 guardianship를 혼합하지 않는다. `npc_09_perrin_lask`의 child·continuation 관계는 성인 romance 경로가 아니다.
- 어떤 NPC도 sexual reward, explicit sexual content, reproductive obligation으로 relationship을 열지 않는다. `06` §5.7의 `romance.explicit_content == true`는 `explicit_content_forbidden` error다.
- 비-explicit physical affection(손 잡기, 함께 식사, 약속 지키기, 곁에 머무르기)은 허용한다. coercion과 possession disguised as affection는 금지한다.
- romance가 열리면 양쪽 모두에게 veto 권리가 있어야 한다. 한쪽 authority가 다른 쪽을 archive·own·register하는 관계는 romance가 아니라 power다.
- affection가 높은 NPC도 death/absence를 보호하지 않는다. player는 그 NPC를 대체할 수 없다.
- affection·romance는 info access, combat power, resource 배분의 reward가 아니다. 06의 `companion_power.granted_by_effect_ids`는 `state.entry_effect_ids`에 실제로 있어야 한다.
- **magic은 relationship의 조건도 보상도 아니다.** `craft_credit`, `lineage_token`, `mana_profile`, portal contract 보유가 romance state를 열거나 닫지 않는다. magic failure도 (§4.5) 자동 배제 규칙이 아니라 consent·recovery·shared choice로 authored data를 쓴다. `S118`의 consent 논쟁이 이 규칙의 근거다.
- **kinship channel에서 성인 romance를 열지 않는다.** `npc_09_perrin_lask`의 continuation/guardian 관계는 `romance.allowed == false`이며, guardianship와 romance를 한 `rel_*`에 섞으면 `romance_without_state`와 `chosen_family_romance_conflated` error다.

### 4.5 Body-horror identity의 공통 실행 규칙

body horror는 identity/state 사건이다. cutscene spectacle이 아니다. 모든 body-horror arc는 최소한 다음을 명시한다.

1. organ, clone, surgery, transformation, healing, memory, body authority 중 무엇이 변하는가.
2. 변한 부분이 combat capability와 resource access를 어떻게 바꾸는가.
3. 기존 social recognition이 왜 person/object/subject로 갈리는가.
4. 대상의 consent가 어디서 필요하며, player가 어떤 refusal를 존중해야 하는가.
5. immediate result와 delayed identity result가 각각 무엇인가.
6. recovery가 restoration인지 bypass인지, 어떤 self layer를 버리는가.

- body-horror는 graphic reveal이 아니라 **어느 body part가 어떤 record·route·relationship를 바꾸는가**로 판정한다.
- transformation은 reward가 아니다. 수용 보상으로 닫히는 arc는 없다.
- 그래프 spectacle, organ naming만 반복, "몸이 무섭다"는 description은 identity arc가 아니다.
- **magic이 추가하는 identity 층위**는 다음 4개이며 각 arc가 최소 하나를 명시해야 한다. (a) `medium residue`가 장기 protocol을 바꾸는 경우, (b) `mana_profile`이 capability 선택지를 바꾸는 경우, (c) `fold_sheet`/절단 shape가 물리 흔적으로 남는 경우, (d) `contract_tally`이 다른 차원의 존재와 만든 obligation이 `social identity`가 되는 경우.
- **magic cure는 restoration이 아니라 bypass다.** recovery plan이 "원래 self로 복원"을 목표로 삼으면 `magic_cure_recorded_as_restoration` error다.
- magic failure 등급(`recoverable` / `continuity-changing` / `terminal`)은 `08`의 recovery 7종과 별개이며, 등급이 바뀌어도 recovery type enum이 열리지 않는다.
- body-horror가 `RC-08`에서 forbidden으로 취급되는 것은 두 가지뿐이다: 학생을 제거로 처리하는 것, failed fold를 spectacle cutscene으로만 처리하는 것.

## 5. Subagent dossier contract

### 5.1 입력

character subagent는 작업 시작 시 다음을 읽는다.

- `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`
- `docs/research/top_down_action_rpg/IDEA_LEDGER.md`
- `docs/research/top_down_action_rpg/PLAN_RESOLUTION.md`
- `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/12_MAGIC_THEORY.md` (magic layer를 다루는 dossier에 필수)
- 이 파일의 stable ID와 relationship topology와 §2.1 node·authority 매핑
- `02_WORLD_STATE_AND_ROUTES.md`의 world/axis/clock/authority token
- `06_AUTHORED_CONTENT_AND_DATA.md` §5.7 `RelationshipStateDefinition`과 §5.11 `NpcDefinition`
- `03_STORY_AND_ENDINGS.md` §12.1의 `rel_*`/`rs_*` instance 표와 §14.4의 seed register(160행)
- 존재할 경우 현재 story plan과 region plan
- Primary Reference 조사에서 확인된 NPC, dialogue, world-preserving, aftermath, combat conversion 규칙
- 해당 dossier가 참조하는 seed ID의 원문 idea summary. 원문 대사는 복사하지 않는다.

### 5.2 독립 작업 규칙

- 한 subagent는 한 NPC 또는 서로 직접 의존하지 않는 NPC 묶음 하나만 소유한다.
- 중앙 constitution, seed ID, faction boundary, timeline을 수정하지 않는다.
- region law, encounter roster, combat action, save schema, presentation dialogue를 새로 소유하지 않는다.
- 기존 dossier의 conflict를 발견하면 merge하지 말고 report한다.
- 이름이 바뀌어도 stable ID를 유지한다. source의 이름·대사·고유 catchphrase를 후보로 만들지 않는다.
- NPC가 lore를 설명하도록 dialogue를 늘리지 않는다. 필요한 knowledge는 `SHOW`, `WORK`, `REFUSE`, `PROTECT`, `DEFEAT`, `LEAVE`의 결과로 전달한다.
- seed 하나를 이름·직업·surface에만 연결하면 `source-copy-risk` 또는 `unbound`로 표시한다.
- **14명 canonical core roster 밖의 core NPC를 추가하지 않는다.** `R8` support resident 7명은 §2.4의 `npc_20_*`~`npc_26_*` ID와 `roster_kind: support`로만 등록할 수 있다. 그 외 `02` named resident가 필요하면 §2.3 표에 따라 이름만 등록하고 `npc_*` ID를 부여하지 않는다. 각 core NPC는 system port와 absence consequence를 가져야 한다.
- §2.6 표에 없는 NPC에게 magic supplement seed를 배정하지 않는다. 새 seed가 필요하면 `02`/`03`의 owner가 seed를 추가한 뒤 여기를 갱신한다.

### 5.3 반환 schema

각 subagent의 return는 dossier file과 별도로 다음 항목을 반드시 포함한다.

- `seed_id`
- `transformation`: memo의 구조가 TIN rule으로 바뀐 부분
- `local_rule`: NPC/institution 내부에서 실행되는 규칙
- `system_binding`: owned port, region, clock, resource
- `cross_links`: 다른 NPC/system/region 두 곳 이상
- `immediate_consequence`: 현재 field에서 확인되는 결과
- `delayed_consequence`: 재방문·recovery·route·relationship에서 나타나는 결과
- `risks`: generic, source-copy, category error, consent, balance, memory risk
- `open_questions`: 사실 확인이 필요한 항목. 추측을 질문으로 위장하지 않는다.

### 5.4 Dossier quality gate

반환 전에 다음을 검사한다.

- required field 23개가 모두 존재하는가.
- `interaction_verbs`가 최소 4개이며 각 verb에 precondition, immediate, delayed, failure가 있는가.
- NPC가 dialogue-only가 아니라 최소 하나의 system port를 실행하는가.
- public role과 private role이 서로 다른 field behavior를 만드는가.
- desire, fear, contradiction이 action choice로 관찰되는가.
- resource access가 play state에 영향을 주는가.
- knowledge boundary가 player knowledge와 독립적인가.
- relationship state가 `06`의 `rel_*.states[].state_id`로 표현되고, dossier 본문이 `03` §12.1의 `rs_*` ID를 그대로 쓰는가. trust/fear/debt/recognition/attachment/agency는 전이 입력으로만 쓰이는가. `stance`가 gate나 precondition으로 쓰이지 않았는가.
- death와 absence가 서로 다른 후속 state를 가지는가.
- one-off seed가 §1.5를 만족하며 conversation climax가 아니라 action, field, document, aftermath로 실행되는가. 목록의 seed class가 `ONEOFF` 또는 `TONE`인가. `ONEOFF` seed의 `bindings`가 `npc`/`prop` 1개인가. 참조 `conv_*`가 1개인가. 여는 `doc_*`가 9-line page cap 안인가. 두 surface가 서로 다른 kind인가.
- `AP`, action point, "행동당 비용", 전역 `mana`/`concentration` 수치를 `resource_access`나 `interaction_verbs`에 쓰지 않았는가. magic을 다룬다면 `res_*` token과 `magic.*` record만 썼는가.
- faction link가 최소 두 기관과 구체적인 resource/authority 교환을 가지며, token이 §2.1의 `02` canonical authority인가. `R8` port가 있다면 `02` §9.3의 `R8` write field 4개 밖의 field를 쓰지 않았는가.
- §2.1의 node 배정과 §4.2의 cluster membership이 서로 모순되지 않는가. 이 NPC가 §4.2 표에 있거나 "membership 밖에서 지시하는 NPC"로 근거가 있는가.
- romance/affection이 explicit sexual content나 reward가 아니며, consent와 capability 변화가 있는가. magic이 romance state를 열거나 닫는 조건으로 쓰이지 않았는가.
- body-horror가 organ/body state와 social identity를 바꾸며, recovery가 bypass/restoration 중 무엇인지 명시되는가. magic identity 층위 4개 중 최소 하나를 명시했는가.
- `clock_links`에 `02` §4의 6개 clock만 있고 축(`recognition_drift`, `continuity_pressure`)과 `concentration`/`mana_profile`이 섞이지 않았는가.
- 최소 두 개의 pressure clock과 다른 NPC 두 개 이상이 cross-link되는가.
- seed citation이 실제 ledger ID인가.
- memo의 이름·문장·고유 표현이 복사되지 않았는가.

검증 실패 시 subagent는 “완료”로 반환하지 않고, 어느 field와 어떤 action이 contract를 위반했는지 보고한다.

## 6. Dependency / ownership table

| Artifact / domain | Owner | Read dependencies | Write ownership | Must not modify | Consumer / merge gate |
|---|---|---|---|---|---|
| Plan resolution | root integrator | user decision | `PLAN_RESOLUTION.md` | dossier content | 모든 plan 파일이 re-key의 유일한 근거로 사용한다 |
| World constitution | root world owner | user decision, project decisions | `WORLD_CONSTITUTION.md` | character-specific dialogue, region content | all subagents read only; root resolves conflict |
| Idea ledger | root idea owner | memo extraction, constitution | `IDEA_LEDGER.md` | used status without validation | character owner cites IDs, never rewrites seed intent |
| Story plan, if later created | story owner | this file, constitution, ledger | story/ending plan | NPC stable IDs, relationship actions | route owner must preserve dossier state |
| Character dossier | character owner | constitution, ledger, resolution, `12`, this contract | `04_CHARACTERS_AND_RELATIONSHIPS.md` | code, region schema, encounter data | integration checks all 14 dossiers + §2.4 support 7명, §2.3 re-key, §2.6 seed binding |
| Magic theory / craft role | magic owner (`12`) | constitution, ledger, resolution, this file | `12_MAGIC_THEORY.md` | NPC stable ID, relationship arc | character owner는 `12`의 contract·institution token·failure 등급을 바꾸지 않는다 |
| `R8` support resident dossier | character owner | this file §2.4, `02` §7.9, `06` §5.11 | `04` §2.4 | core roster 14, `02` §9.3 write field | `roster_kind: support` 고정, `npc_15`~`npc_19` 미사용 |
| Magic resource / `res_*` vocabulary | region owner (`02`) + content owner (`06`) | `02` §5.5 | `res_*` registry, `world.resources` | combat resource(`hp`/`mp`/`equipment_charge`) | dossier는 vocabulary를 참조만 하고 새로 만들지 않는다 |
| Relationship state data | content owner (`06`) | this file's transition semantics | `rel_*.json` (`06` §5.7) | 이 파일의 prose가 schema를 다시 정의하지 않음 | `state_id`가 authority이며 `stance`는 presentation |
| Relationship graph | character owner | dossier relationship states | this file only | direct friendship/romance score in other files | story/UI consumer maps actions, not generic affinity |
| Cluster membership | character owner | `02` §8 cluster list(9개), this roster | this file §4.2 | region event content | 6~12 core NPC, 2~4 institutions, 2~3 clocks |
| Region state/routes | region owner | NPC IDs, clock names | region plan/data | NPC private role, dialogue lines | region owner reports missing port; character owner resolves |
| Combat/encounter | encounter owner | NPC identity and capability | enemy/encounter plan/data | character body-horror identity law | conversion must use same stable NPC ID |
| System/scheduler | systems owner | constitution, interaction verbs | system plan/code | content IDs, dialogue | verbs resolve through data, not NPC-name branches |
| Save/recovery | recovery owner | continuity, body arcs, relationship state | save plan/code | character prose, one-off dialogue | round-trip must preserve absence, debt, recognition |
| Presentation/dialogue | presentation owner | dossier field, one-off seeds, `stance` label | dialogue/UI plan | domain outcome, relationship law | choice text cannot be the only consequence; `stance` cannot be a gate |
| Validation | QA/root owner | all plans and dossier contract | test/acceptance plan | authored content to hide failures | failed gate blocks implementation |
| Final integration | root integrator | stable IDs, unresolved reports | merge log / decision record | silently overwrite any owner | only root resolves cross-domain contradiction |

### Ownership boundary

- 같은 NPC stable ID를 두 worker가 동시에 소유하지 않는다.
- character owner가 encounter boss를 새로 설계하지 않는다. encounter owner가 기존 identity의 combat resolution을 작성한다.
- region owner가 NPC를 region에 맞게 재생하지 않는다. 이미 존재하는 stable ID와 absence consequence를 사용한다.
- region owner가 `02`의 named resident를 core NPC로 승격시키지 않는다. 승격이 필요하면 root integrator가 §2.3 표를 갱신한다. `R8` support resident는 승격이 아니라 `roster_kind: support` 등록이며, 이를 `core`로 바꾸는 것은 `core_roster_not_canonical` error다.
- magic owner(`12`)가 craft family·institution token·failure 등급을 바꾸면 character owner는 dossier의 `Magic / craft port` 서술만 갱신한다. NPC가 새 magic ability를 받는 것이 아니다.
- presentation owner가 relationship을 단순 호감도로 축약하지 않는다. action result와 field state를 먼저 표현한다.
- root integrator가 conflict를 발견하면 어느 contract가 우선하는지 명시한다. subagent가 임의로 merge하지 않는다.

## 7. 구현 전 content acceptance

이 dossier가 character content authoring에 사용되기 위한 최소 조건은 다음과 같다.

- 14명의 core NPC가 모두 required field를 가지며, roster에 15번째 core `npc_*`가 없다. `npc_15`~`npc_19`는 비어 있다.
- `R8` support resident 7명이 `npc_20_*`~`npc_26_*`로 등록되어 있고 각각 최소 하나의 `R8` write field port, `cross_link_ids` 2개 이상, absence result를 가진다. `roster_kind: "core"`로 선언된 `npc_20_*`는 0건이다.
- 14명 모두 최소 하나 이상의 system port, action-driven state change, death/absence result를 가진다.
- 모든 관계의 canonical 위치가 `06`의 `rel_*.states[].state_id`이고 dossier 본문은 `03` §12.1의 `rs_*` ID를 그대로 쓰며, DAG·연속 `order`·sink 규칙을 만족한다.
- trust/fear/debt/recognition/attachment/agency는 transition 입력으로만 사용되며, world 축에는 `axis_rules`로만 landing한다. `agency`가 `rel.axes`에 여섯 번째 key로 추가되지 않았다.
- `stance`는 presentation label이며 save·condition·gate·precondition으로 쓰이지 않는다.
- `AP` resource, 전역 `mana`/`concentration` 수치, combat resource를 NPC field에 쓰지 않는다. 진행 비용은 `turn_cost` int `0..5`로만 표현한다.
- magic resource는 `02` §5.5의 `res_*` token, magic 계약 조건은 `magic.crafts`/`magic.contracts`에 있고 한 값을 두 namespace에 복제하지 않는다. `contract_tally`과 `labor_pledge`에는 `amount`가 없다.
- magic theory의 positive label이 dossier·dialogue에 하드코딩되지 않았다. `glossary`가Filing되기 전에는 `untranslated term`으로 표기한다.
- magic이 새 축·새 clock·새 recovery type을 만들지 않았다. `concentration`/`mana_profile`/`craft_credit`은 축도 clock도 아니다.
- magic supplement `S121`~`S160` 40 unit이 §2.6 표의 core NPC에 배정되어 있고, 각 row가 `R8` 밖 region family와 `02` §4.4의 clock write를 하나 이상 가진다. seed 상태는 전부 `PLANNED_RETAINED`이며 `USED`/`TRANSFORMED` claim은 없다. seed accounting은 core 120 + magic 40 = 160, gate 96, preferred target 120이다(120/72/90 같은 이전 판 숫자를 쓰지 않는다).
- 모든 authority 표기가 §2.1의 `02` canonical token이며 `Marrowglass`, `Terminal Ledger Hall`, `Lower Switchyard`, `Office of the Vacant Seat`, `Crown Alignment Office`가 남지 않는다. `R8` authority는 `MAG_ACADEMY`/`CIRCULATION_BOARD`/`LINEAGE_HOUSE`/`VOID_CONTRACT_COURT` 4개뿐이다.
- 모든 `clock_links`가 `02` §4의 6개 clock이며 축이 섞이지 않는다.
- §4.2의 **9개** cluster 각각이 6~12 core NPC, 2~4 institutions, 2~3 clocks를 가지며 최소 두 개의 non-dialogue surface를 바꾼다. `RC-08`의 7명 core membership이 `02` §7.9의 `core NPC visitors` 명단과 1:1이다.
- one-off seed는 §1.5를 만족하고 최소 2개 이상의 서로 다른 kind surface를 만들며 dialogue-only quest를 만들지 않는다. 목록의 class는 `ONEOFF` 또는 `TONE`이고 `SYSTEM`/`MODULE`/`ROOT` class seed는 `Seed transformation record`로 내려가 있다.
- relationship graph의 모든 edge에 concrete resource, authority, recognition 또는 care consequence가 있다.
- romance/affection route는 선택 가능하며 explicit sexual content, reward, harem obligation, reproductive obligation이 없다. 비-explicit physical affection은 허용된다. magic 숙련·`craft_credit`·portal contract가 romance 조건이나 보상이 아니다.
- body-horror route는 organ/clone/surgery/transformation/memory/body authority의 state change와 consent rule을 가지며 spectacle cutscene으로만 처리되지 않는다. magic identity 층위(medium residue, `mana_profile`, shape 흔적, contract obligation) 중 최소 하나를 명시하고, magic cure는 bypass로만 기록된다.
- `npc_09_perrin_lask`의 guardianship 관계는 `romance.allowed == false`이며 성인 romance와 섞이지 않는다.
- 같은 NPC가 combat으로 전환될 때 별도의 이름 없는 enemy skin이 생기지 않는다.
- survival, death, absence가 각각 field, resource, access, record, relationship 중 하나 이상에 persistent difference를 남긴다.
- `Crown`은 `Crownwell Archive`의 `Crown of Continuance` object와 `Crown Protocol`로 표현되며 personal king, abstract simulation, 또는 단일 quest truth가 아니다.
- player knowledge, NPC knowledge, public record는 서로 다른 source of truth로 유지된다.
- region, enemy, presentation, save, test 계획은 이 파일의 stable ID와 consequence를 소비할 수 있다.
- story-plan이 나중에 생기면 이 dossier의 이름, private role, body arc, absence result를 덮어쓰지 않고 integration review를 받는다.
