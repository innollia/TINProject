# 사용자 메모 Idea Ledger v1

상태: source extraction 완료. retained/used 결과가 아니라 planning ledger.  
사용량 규칙: 독립 idea unit 중 최소 60% 구조 변환.  
원문은 긴 대화의 idea source이며, 아래 항목은 원문을 그대로 복사하지 않고 의도/구조를 요약한다.

## 사용 상태

- `ROOT`: 세계 헌장 또는 root law로 직접 사용
- `SYSTEM`: Kit system/authoring data로 사용
- `MODULE`: region/era/module surface로 사용
- `TONE`: dialogue/log/format/voice에만 사용
- `ONEOFF`: 특정 NPC 대사 또는 단발 scene에만 사용
- `CANDIDATE`: transform 후 cross-link가 부족해 보류
- `DROP`: duplicate, source-copy, adult-only, unresolved filler

현재 목표: ROOT/SYSTEM/MODULE/TONE/ONEOFF 중 최소 60개를 retained transformation queue에 넣는다. 실제 `used` 판정은 구현/검수 후 기록한다.

## A. Invariant and cosmology seeds

- `S001 ROOT` — 왕관은 왕보다 높은 곳에 위치한다. → physical/social/metaphysical invariant를 동시에 가지는 object.
- `S002 ROOT` — 왕은 바뀌지만 왕관은 하나다. → mutable operator와 persistent protocol 분리.
- `S003 ROOT` — 왕관은 왕보다 오래간다. → title/order/record가 human보다 오래 사는 구조.
- `S004 SYSTEM` — 개인을 하나의 self로 보지 않는 신체/장기/신경의 다중 voice. → distributed identity와 organ authority.
- `S005 SYSTEM` — clone은 body와 memory를 공유해도 social continuity가 다르다. → clone/resurrection identity rule.
- `S006 SYSTEM` — high-level cognition이 low-level information을 버린다. → recognition_drift와 player knowledge.
- `S007 ROOT` — 여러 protocol이 recovery와 recognition을 동시에 관리한다. → meta-protocol world spine.
- `S008 SYSTEM` — death를 없애는 대신 다른 시간/role/branch로 비용을 옮긴다. → continuity_pressure.

## B. Backroom / institution seeds

- `S009 MODULE` — 틈새/백룸은 recovery가 실패한 공간. → recovery infrastructure.
- `S010 MODULE` — 성벽/경계가 갑자기 흔들리면 사람이 빠진다. → boundary reliability event.
- `S011 SYSTEM` — 귀환 총괄청이 복귀자를 record/분류/격리한다. → institution with local competence.
- `S012 SYSTEM` — 이단심문소는 recovery를 거부하는 사람을 처리한다. → institutional category error.
- `S013 SYSTEM` — 신성공학은 신앙/오염을 기술어로 변환한다. → faith-to-latency engineering.
- `S014 SYSTEM` — faith가 response delay를 줄인다. → belief as operational parameter.
- `S015 MODULE` — backroom history가 disaster, administration/industrialization, normalization 단계로 변한다. → region-era history.
- `S016 TONE` — “빠져” 같은 짧은 operational dialogue. → NPC/institution voice, not lore.
- `S017 SYSTEM` — contamination는 이동/접촉/행동으로 변한다. → status/resource/clock.
- `S018 MODULE` — 200년간의 backroom 공략이 실패와 fatigue를 누적한다. → long-term institutional memory.
- `S019 TONE` — rule chapter number와 incident report 형식. → document content and bureaucratic absurdity.

## C. Magic / transformation seeds

- `S020 MODULE` — magical girl transformation is a boot/load process. → identity/body/defense layered transformation.
- `S021 SYSTEM` — contract/permission validation precedes transformation. → social/legal gate.
- `S022 SYSTEM` — body hardware allocates a temporary execution space. → bounded resource and instability.
- `S023 SYSTEM` — fast boot trades spectacle for stability. → visible tradeoff, not upgrade button.
- `S024 TONE` — transformation UI/log reports incomplete stages and failures. → in-world technical evidence.
- `S025 MODULE` — magical girl support system has brain/body hardware logs. → distributed self and maintenance.
- `S026 SYSTEM` — transformation is not a costume change; it changes who can recognize the person. → social identity phase.
- `S027 MODULE` — “fairy” support system is absurdly bureaucratic and intimate. → care/romance/affection through protocol.

## D. Body / identity / recovery seeds

- `S028 SYSTEM` — organs answer with different priorities. → organ authority conflict.
- `S029 MODULE` — brain speaks after decoding neural language. → cognition/communication threshold.
- `S030 SYSTEM` — the same event can be “for prosperity” from brain and organs. → distributed motive.
- `S031 ROOT` — recovery preserves a function but not the original failure. → bypass-based recovery.
- `S032 SYSTEM` — clone memory is identical but each clone becomes socially distinct. → continuity pressure.
- `S033 MODULE` — mass clone deployment consumes ecology and coordination capacity. → resource_scarcity.
- `S034 SYSTEM` — loop preserves knowledge but can move responsibility. → loop consequence.
- `S035 MODULE` — quantum immortality shifts death cost rather than erasing it. → branch debt.
- `S036 TONE` — “infinite regression” can become a single-player joke. → format/identity humor.
- `S037 ONEOFF` — a body part speaks in a serious meeting. → one-line body horror dialogue.
- `S038 SYSTEM` — low-level brain damage cannot be fixed by understanding alone. → recovery limits.

## E. Institution / absurd social seeds

- `S039 TONE` — people answer impossible problems with employment, therapy, paperwork, manuals, group chat. → political absurdism voice.
- `S040 MODULE` — freelancer says the situation will continue for thirty years. → stagnation clock and career institution.
- `S041 TONE` — a cure is promised in thirty years; coworkers react with false hope. → temporal absurdity.
- `S042 MODULE` — school uses animal names as guardian names. → identity/registration category.
- `S043 TONE` — adult/administrative confusion around a photograph. → social misclassification, no explicit content.
- `S044 SYSTEM` — a guard’s mistake changes which name protects whom. → record/recovery identity.
- `S045 MODULE` — institution labels a dangerous child/patient as a special case. → case management as horror.
- `S046 SYSTEM` — a person can be helpful and legally dangerous at the same time. → trust/fear/debt split.
- `S047 TONE` — group chat is the emergency protocol. → asynchronous institution voice.
- `S048 TONE` — app/open chat makes private panic public. → rumor/record propagation.
- `S049 MODULE` — a company/office treats biological anomaly as a deliverable. → political work absurdity.
- `S050 TONE` — a simple “shut up” subverts a verbose technical explanation. → dialogue rhythm.

## F. Authority / crown / protocol seeds

- `S051 ROOT` — operator replaces operator, protocol survives. → crown/institution model.
- `S052 SYSTEM` — authority has a physical object and an abstract claim. → crown as object + invariant.
- `S053 MODULE` — a title is more durable than the person who holds it. → role persistence.
- `S054 SYSTEM` — institutions compete over the right to interpret the crown. → faction route.
- `S055 ONEOFF` — a subordinate knows the crown’s position better than the king. → one-line political horror.
- `S056 SYSTEM` — a record can outlive the event and become more dangerous than the event. → public_record_clock.
- `S057 TONE` — “the king changes” treated as routine administration. → deadpan absurdity.
- `S058 MODULE` — a region’s architecture encodes who is above whom. → vertical power space.
- `S059 SYSTEM` — the crown does not explain itself; every faction supplies a different protocol. → partial truth.
- `S060 ONEOFF` — an object in a higher location refuses the king’s interpretation. → environmental clue.

## G. Ecology / resource / survival seeds

- `S061 SYSTEM` — many identical bodies can destroy an ecosystem through aggregate consumption. → resource_scarcity.
- `S062 MODULE` — survival depends on knowing which plants/water are safe. → knowledge gate.
- `S063 SYSTEM` — knowledge is distributed among people, not one hero. → NPC expertise network.
- `S064 MODULE` — cold, hunger, disease, and social conflict are simultaneous clocks. → multiple pressure clocks.
- `S065 TONE` — a detailed number makes an absurd catastrophe feel bureaucratic. → deadpan technical horror.
- `S066 SYSTEM` — resource extraction changes climate, sound, and social order. → region system effect.
- `S067 MODULE` — a remote settlement is safe only if knowledge exchange survives. → route/revisit content.
- `S068 TONE` — people estimate survival by making grim calculations in public. → social voice.

## H. Science / cognition / translation seeds

- `S069 ROOT` — high-level interpretation discards low-level errors. → recognition_drift.
- `S070 SYSTEM` — reading can become shortcut and lose nuance. → document/knowledge system.
- `S071 TONE` — technical process is understood through an intentionally wrong or simplified model. → unreliable narrator.
- `S072 MODULE` — translation takes longer than the original world’s lifetime. → institutional absurdity.
- `S073 SYSTEM` — a partial translation creates a new local law. → protocol diversity.
- `S074 ONEOFF` — a person knows the translation is wrong but uses it anyway. → choice/affection.
- `S075 TONE` — foreign technical terms remain untranslated in a social scene. → voice differentiation.
- `S076 MODULE` — an alien values humans for low entropy and stable repetition. → outsider perspective.
- `S077 SYSTEM` — human identity is ambiguous at low and high cognition levels. → distributed self.
- `S078 TONE` — a precise name fails to identify the same being at another scale. → identity horror.

## I. Horror / transformation / body seeds

- `S079 MODULE` — surgery can alter a body without altering its social identity. → body/social split.
- `S080 SYSTEM` — a failed operation leaves a valid but unfamiliar protocol. → transformation aftermath.
- `S081 TONE` — device logs report a body part as a separate subsystem. → technical body horror.
- `S082 MODULE` — a low-level brain error changes how a person reads language and identity. → cognition region.
- `S083 SYSTEM` — recovery is a workaround manual, not restoration of the original. → recovery content.
- `S084 ONEOFF` — a person calmly explains that a body part is filing a complaint. → absurd body horror.
- `S085 TONE` — medical terminology turns grief into a queue. → institutional tone.
- `S086 MODULE` — a transformation can be beautiful, legally forbidden, and socially rejected at once. → romance/affliction/authority conflict.
- `S087 SYSTEM` — organ disagreement is a combat/negotiation state. → noncombat/boss hybrid.

## J. Genre / module seeds

- `S088 MODULE` — magical girl support system as a social service. → care economy and romance space.
- `S089 MODULE` — dragon warrior as an absurd institutional job. → party/faction content.
- `S090 MODULE` — runaway party from a harem-like obligation. → social pressure and agency.
- `S091 MODULE` — a school that is both a horror site and a registry. → education/identity region.
- `S092 MODULE` — a freelancer’s cure/therapy economy. → debt and recovery economy.
- `S093 MODULE` — a survival settlement with no native expertise but many bodies. → clone/resource crisis.
- `S094 MODULE` — a magic-girl transformation lab inside a medieval-looking order. → genre collision.
- `S095 MODULE` — a backroom cathedral that treats faith as latency reduction. → religion/technical system.
- `S096 MODULE` — a wilderness region where mass cloning ends the local ecology. → resource collapse arc.
- `S097 MODULE` — a translation office that accidentally creates a new law. → epistemic region.
- `S098 MODULE` — an organ clinic where patients negotiate with body authorities. → body-horror social hub.
- `S099 MODULE` — a crown archive above every royal hall. → vertical institution.
- `S100 MODULE` — a public group chat becomes the only surviving witness. → record/rumor system.

## K. One-off dialogue / scene seeds

- `S101 ONEOFF` — a serious official explains a ridiculous rule without breaking tone.
- `S102 ONEOFF` — a child asks the only question that exposes the crown’s category error.
- `S103 ONEOFF` — a therapist treats a loop as a work schedule.
- `S104 ONEOFF` — a doctor asks the heart to sign a form.
- `S105 ONEOFF` — a magic-girl support agent logs a failed transformation as “relationship pending.”
- `S106 ONEOFF` — a clone refuses a name because the original already used it legally.
- `S107 ONEOFF` — a public record describes a person as an object while the person is speaking.
- `S108 ONEOFF` — a king orders a crown moved, and the clerk replies that the crown is already above the order.
- `S109 ONEOFF` — a survival calculation becomes a love confession because both use the same missing number.
- `S110 ONEOFF` — an alien compliments a human’s repetitive low-entropy behavior.
- `S111 ONEOFF` — a backroom rule is broken by following an institution’s safety manual exactly.
- `S112 ONEOFF` — an organ chorus interrupts a political meeting with a practical complaint.
- `S113 ONEOFF` — a magical transformation is technically successful but socially unrecognized.
- `S114 ONEOFF` — a group chat member solves a crisis by forwarding a screenshot with no context.
- `S115 ONEOFF` — a recovery system returns a person with a correct body and wrong employment history.
- `S116 ONEOFF` — a crown archive contains a previous king’s memory but not the king.
- `S117 ONEOFF` — a region’s danger is a rumor until an NPC treats the rumor as a physical object.
- `S118 ONEOFF` — a body-horror transformation is the only way to save a relationship, and both characters argue about consent.
- `S119 ONEOFF` — an institution’s emergency form requires a category that legally does not exist.
- `S120 ONEOFF` — the same event is reported as a miracle, a contamination case, and a labor dispute.

## L. Magic supplement

- `S121 ROOT` — 마나를 원소로 둘지 미발견 화합물로 둘지 선택해야 한다. → TIN에서는 `concentration-mediated craft`라는 공통 contract와 여러 물질 모델을 허용한다.
- `S122 SYSTEM` — 마나 농도가 높을수록 시전자는 편해지고 수련 효율이 오른다. → concentration/efficiency tradeoff.
- `S123 SYSTEM` — 마나 농도가 임계치를 넘으면 폭발한다. → environmental pressure clock와 failure state.
- `S124 MODULE` — 산인데 사람들은 평지를 걷는다. → spatial perception/cognition anomaly.
- `S125 TONE` — 위험한 현상을 자연마법으로 즉시 정당화하는 설명. → institution/observer rationalization.
- `S126 SYSTEM` — 마나를 안전 밀도로 흩뿌리는 가습기/분산기. → civic infrastructure and maintenance.
- `S127 SYSTEM` — 축적 마나를 외부 공기로 순환시키는 장치. → disaster mitigation with side effects.
- `S128 SYSTEM` — 발을 못하거나 방출만 되는 체질처럼 마나 처리 체질이 존재한다. → body/cast compatibility profiles.
- `S129 SYSTEM` — 마나가 쌓이지 않는 사람과 과잉 축적되는 사람. → resource class, not moral class.
- `S130 MODULE` — 마나 밀도가 극단인 자연 지형. → region hazard/clock.
- `S131 SYSTEM` — 마나가 뇌/면역체계를 손상시키거나 각성시킨다. → body horror + ability system.
- `S132 SYSTEM` — 미세플라스틱를 땀샘으로 배출하는 능력. → cleansing, resource loss, evolution.
- `S133 SYSTEM` — 미세플라스틱를 다루는 능력은 실패하면 cognition/competence를 잃는다. → irreversible craft consequence.
- `S134 MODULE` — 인류가 플라스틱 시대를 지나 진화한 미래. → post-human era/module.
- `S135 SYSTEM` — 진화가 방향성과 효율 측면에서 매우 빠르다. → generational adaptation clock.
- `S136 MODULE` — 후성 유전 능력이 직업별 전문 집안을 빠르게 만든다. → institution/economy response.
- `S137 MODULE` — 마법을 발명한 자가 먼저 예술가로 불린다. → craft class, not hero class.
- `S138 MODULE` - 마법 유행이 마을을 바꾸고 마법사 집단이 탄생한다. → diffusion/social change.
- `S139 MODULE` — 소규모 마법 예술가 집단은 허약하고 주류에 이용당한다. → political class conflict.
- `S140 MODULE` - 방랑 마법사, 마법학원, 귀족의 노예, 직업 전환자가 분화된다. → social consequence branches.
- `S141 MODULE` - 마법학원 학생이 protagonist가 될 수 있다. → playable role candidate, not sole canon.
- `S142 SYSTEM` - 수련이 특정 유전인자를 활성화한다. → training/ability unlock grammar.
- `S143 SYSTEM` - 마법사 가문은 아직 정립되지 않은 magic을 유전한다. → lineage/knowledge preservation.
- `S144 SYSTEM` - 가문 magic는 특정 가문만 사용할 수 있다. → access gate, not innate morality.
- `S145 TONE` - “나는 이 magic를 쓸 줄 안다”가 실전 숙련을 뜻하는 occupational speech. → combat mastery voice.
- `S146 SYSTEM` - 종이에 magic을 적신 뒤 자른다. → material/medium/technique schema.
- `S147 SYSTEM` - positive magic theory label을 아직 확정하지 않는다. → glossary placeholders must be authored, not hardcoded.
- `S148 MODULE` - magic이 textile/scroll craft로 시작된다. → soft/constructive action family.
- `S149 SYSTEM` - 가위로 재단을 빠르게 만드는 combat weave. → preparation/action economy.
- `S150 SYSTEM` - 종이접기 magic은 입체 구현이 어려워 더 고난도다. → 3D craft complexity rule.
- `S151 MODULE` - 전투 마법사는 허리춤에 직물 조각을 건넨다. → visible equipment/affordance.
- `S152 SYSTEM` - 전투 전에 scroll/weave를 준비하고 실전에서 선택해 직조한다. → prep/resource/turn cost.
- `S153 SYSTEM` - 종이를 던지고 칼로 썰어 magic을 발동한다. → improvised field casting.
- `S154 MODULE` - 포탈 magic은 가위로 공허를 잘라 다른 차원을 연다. → shape determines destination/spell.
- `S155 SYSTEM` - 포탈 shape는 인풋이며 아웃풋/위험을 결정한다. → authored geometric grammar.
- `S156 MODULE` - 화산: 차가운 것 → 용암 분출. → typed otherworld/element exchange example.
- `S157 MODULE` - James/observer entity: arbitrary input, mental attack output. → NPC/magic anomaly with no predictable material law.
- `S158 SYSTEM` - 고위 portal은 다른 차원 존재와 계약한다. → commitment, cost, delayed consequence.
- `S159 SYSTEM` - 계약 spell은 불발 가능성이 낮고 구체적이다. → precision magic vs low-tier improvisation.
- `S160 SYSTEM` - 가위/칼날의 물리 구조가 공허를 자르는 비용과 안정성을 결정한다. → tool/medium ecology; no sword-board or false technical claim.

## 4. Quota and audit

- core extracted independent idea units: 120
- core minimum retained transformed units: 72 (60%)
- magic supplement independent idea units: 40
- magic supplement minimum retained transformed units: 24 (60%)
- combined denominator: 160
- combined gate: 96 distinct `PLANNED_RETAINED` transforms
- preferred initial target: 120 planned transforms
- current status: `planned`, not yet `used`
- usage audit must record: root/module/system/tone/oneoff, cross-links, immediate consequence, delayed consequence, implementation path, rejection reason

A raw sentence is not automatically a content unit. A line with only punctuation, metadata, duplicate wording, or no new causal relation is excluded before the 60% calculation.

## 5. Binding rule

No seed may be used as a name-only reskin. The minimum transformation record is:

```text
seed_id
source intent
TIN structural change
local rule
system/region/NPC binding
cross-link A
cross-link B
immediate consequence
delayed consequence
generic-risk test
```
