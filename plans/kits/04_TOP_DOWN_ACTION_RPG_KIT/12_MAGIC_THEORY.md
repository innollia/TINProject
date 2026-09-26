# Magic Theory 계획 — Top-down Action-RPG

## 1. 범위

magic은 별도 우주가 아니라 Undersign world의 `concentration-mediated craft` protocol이다. 이 파일은 magic theory, magic data, magic region, magic social institution, magic failure/body consequence를 정의한다.

원 메모의 이름·문구·인물은 복제하지 않는다. theory label은 아직 고정하지 않고 `glossary` data slot으로 남긴다.

## 2. Canonical magic model

### 2.1 공통 계약

```text
MagicCast
- concentration_source
- concentration_level
- medium
- tool
- shape_or_pattern
- training_or_inheritance
- output
- waste
- failure_state
- social_recording
```

- concentration이 높으면 efficiency와 safety가 함께 달라진다.
- magic은 MP가 아니라 concentration/body load/medium/tool의 결과를 가진 domain action이다.
- concentration은 player stat, environmental field, body accumulation, social permission 중 하나 이상에서 나온다.
- medium이 없으면 cast는 성립하지 않는다.
- tool은 spell의 결과를 바꾸지만 동일한 결과를 보장하지 않는다.
- shape/pattern은 portal·weave·fold의 authored contract다.

### 2.2 Mana profiles

`mana_profile`은 성격/선택지가 아니라 body compatibility와 failure class다.

- retention high / emission low
- retention low / emission high
- retention balanced
- retention overflow
- blocked emission
- concentration-reactive
- medium-reactive
- sensory misclassification

각 profile은 combat resource, recovery, magic action, body status와 연결된다. profile은 moral judgement가 아니다.

### 2.3 Environmental concentration

- `concentration_field`는 region/path/action state에서 측정된다.
- `humidifier`/`disperser`는 농도를 안전 범위에 맞추는 civic infrastructure다.
- `circulator`는 고농도 위험을 외부 공기로 이동시키지만 pollution/contamination/clock 비용을 만든다.
- concentration threshold를 넘는 region은 단순 damage가 아니라 route, dialogue, recognition, body state를 바꾼다.

## 3. 세 가지 craft family

### 3.1 Weave / scroll craft

- 종이·직물·천에 magic pattern을 적신다.
- 자르면 command가 만들어진다.
- 실전에서는 미리 준비한 scroll을 사용하거나 전투 중 빠르게 직조한다.
- 오류는 pattern tearing, misfire, incomplete command, medium residue로 나타난다.
- 전투 마법사는 필요한 도구/패치를 외투·허리춤·belt에 보관한다. 이는 UI icon이 아니라 world affordance다.

### 3.2 Rigid-fold craft

- 종이를 접어 입체 구조를 만든다.
- 종이접기 계열은 3차원 구현이 어려워 weave보다 complexity/cost가 높다.
- 성공 시 더 어려운 shape와 portal을 만들 수 있지만 failure가 body/space에 남을 수 있다.
- fold count/shape/lock 조건을 authored data로 둔다.

### 3.3 Void-cut / portal craft

- 가위로 공허를 잘라 다른 층/차문을 연다.
- 잘라낸 shape가 destination, input/output, danger, contract type을 결정한다.
- 저위 portal은 재물/먹이를 주고 불확실한 존재나 세상의 공격을 받는다.
- 고위 portal은 존재와 contract를 맺고 구체적 spell을 얻지만 deferred obligation이 생긴다.
- 이계는 name/input/output/other type을 가진 authored record다.

## 4. Magic as body and evolution system

- magic training은 특정 유전/능력 marker를 깨우는 repeated action이다.
- lineage magic는 정식화되지 않은 craft를 가문/그룹이 보존하는 방식이다.
- 발현에 성공하면 capability가 열리지만, 실패하면 competence/cognition/resource access가 손상될 수 있다.
- 몸에 magic medium이 축적되면 sweat/immune/nerve/organ protocol이 바뀐다.
- 장기별 authority가 magic output을 다르게 승인할 수 있다.
- post-human/microplastic/material era는 지금 당장 구현할 시대가 아니라 authored deep-era content다.

## 5. Magic society

### 5.1 Artisans before mages

초기 magic 사용자는 professional hero가 아니라 artisanal maker다. 주문이 자유로운 형태를 만들 수 있어 diffusion이 일어나지만, 재료 축적과 신체 취약성이 political class conflict를 만든다.

### 5.2 Institution branches

- `MAG_ACADEMY`: 표준 curriculum과 certification을 만든다.
- `WANDERING_MAGE`: 노예, 실업자, 은둔자, 배교자, 방랑자로 분화한다.
- `LINEAGE_HOUSE`: family-specific spell access를 보존한다.
- `FIELD_WEAVE_GUILD`: combat textile/weaving 기술과 trade를 표준화한다.
- `VOID_CONTRACT_COURT`: portal contract와 cost를 adjudicate한다.
- `CIRCULATION_BOARD`: concentration infrastructure를 관리한다.

각 institution은 local competence를 가지며 서로 다른 category를 사용한다.

## 6. Magic regions in the Undersign world

- `R5 The Glasswing Ordinal`: transformation, boot, work permit, magic labor status.
- `R7 The Hollow Orchard`: boundary, void-cut, phase, portal consequence.
- `R2 Siltglass Commons`: mana/material/clone/resource collapse.
- `R4 Crownwell Archive`: magic theory, translation, lineage, glossary.
- `R3 Bellhouse Hospice`: emission failure, body compatibility, care, consent.
- `R6 Gristmarket Ward`: organ magic, replacement parts, magic cure economy.
- `R8 The Folding School`: 후속 authored module. magic academy, genetic training, craft diffusion, art/labor conflict. 진입 edge는 `E18`(R5–R8) **하나**이고 gate는 `G5` 하나다. `H0`에는 `R8` route가 없다(`SERVICE_R8_COURSE_INDEX`는 service index 문서 한 건일 뿐).

## 7. Magic action authoring

```text
MagicActionDefinition
- id
- craft_family
- concentration_requirement
- body_profile_requirements
- medium_options
- tool_options
- shape_or_pattern
- preparation_turns
- turn_cost
- output_action
- waste
- failure_status
- environment_effect
- social_recording
- contract_ref
```

- combat spell은 위 action definition을 재사용한다.
- pre-cast preparation과 field improvisation은 서로 다른 authored action이다.
- magic은 combat target mode를 바꾸지 않는다. target은 01의 canonical enum을 따른다.
- magic이 `resource_node`나 `route`를 “공격”하지 않는다. encounter-level role로 표현한다.

## 8. Failure and body horror

- concentration overflow: tremor, sensory loss, organ conflict, involuntary emission.
- medium failure: pattern inversion, wrong shape, voice duplication, record corruption.
- void failure: wrong destination, contract debt, body replacement, duplicated self.
- lineage failure: inherited ability without trained control, social misrecognition.
- magic cure: body function을 되돌리는 대신 우회한다.
- failure는 recoverable/continuity-changing/terminal로 분류한다.

## 9. Story/social integration

- magic은 power가 아니라 labor/status/resource/recognition을 동시에 바꾸는 사건이다.
- magic failure는 NPC를 romance/affection route에서 배제하는 자동 규칙이 아니다. consent, recovery, shared choice를 authored data로 다룬다.
- body horror는 organ authority, transformation, clone, memory, contract를 통해 identity event로 쓴다.
- magic academy는 tutorial dungeon이 아니라 social class, curriculum, institutional gate, genetic access, employment consequence를 가지는 module이다.
- magic theory의 이름은 glossary authored record. plan/core script에 하드코딩하지 않는다.

## 10. Content floors and seed binding

- 최소 authored magic actions: weave, rigid-fold, void-cut, one no-turn recovery, one committed portal, one concentration failure.
- 최소 magic regions: existing R2/R3/R4/R5/R6/R7 integration + R8 Folding School.
- 최소 magic institutions: academy, circulation board, void contract court, weaving guild, lineage house.
- 최소 magic body profiles: retention, emission, overflow, blocked.
- 최소 one-off magic dialogue: “I can use this spell” = field mastery, not innate title.
- 관련 seed ID: core ledger `S020`–`S027`(core 120 범위이며 magic supplement가 아님) + magic supplement `S121`–`S160`(40). `04` §0/§2.6과 같이 두 범위를 한 목록에 섞지 않는다.
- 각 retained seed는 2개 cross-link, immediate consequence, delayed consequence를 기록한다.

## 11. Tests and acceptance

- concentration threshold changes action availability and environment state.
- medium/tool/shape changes result without code modification.
- preparation and improvisation use the same action schema with different cost/state.
- magic failure writes a status/clock/record effect atomically.
- portal contract creates deferred obligation and does not auto-resolve.
- magic academy gating uses stable data IDs, not class-name branches.
- R8 expansion adds region+NPC+encounter with `changed_core_files == []`.
- no explicit sexual content; body-horror and affection content are allowed.
