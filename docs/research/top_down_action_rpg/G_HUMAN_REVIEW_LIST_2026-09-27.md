# Kit 04 미결 G — 사람 검수용 목록 (2026-09-27)

현황 정본: [IMPLEMENTATION_STATUS_2026-09-27.md](IMPLEMENTATION_STATUS_2026-09-27.md) §6 G.

이 목록은 **검수할 거리만 모아 둔 것**이다. 에이전트는 판정하지 않았다. 추천안(§6 G)대로 지금 템플릿 콘텐츠는 "완료 콘텐츠 아님"으로 두고, 새 세계(《저녁의 해안》) 콘텐츠를 지역·인물 담당이 검수한다. 이 목록은 그때 무엇을 버리고 무엇을 옮길지 고르는 데 쓴다.

## 검수 기준 (`AGENTS.md` '독립 집필' 절에서)

- 전형적인 상황, 추상 주제를 설명만 하는 인물, '평범한 장소 + 기괴한 신체 부위' 반복은 완료 콘텐츠가 아니다.
- 뒤틀림의 구체 규칙 · 물질적 결과 · 인물 행동과 사건 사이 차이를 본다.
- 이상한 수식어·고유명사 개수로 독창성을 판정하지 않는다.
- 칸: `[ ]` 에 유지 = K, 고쳐서 옮김 = M, 버림 = X 를 적는다.

## 기계적으로 확인한 사실 (판정 아님)

| 항목 | 수 | 뜻 |
|---|---|---|
| seed 전체 | 160 | `content/seeds/seed_core.json` |
| `local_rule`이 "Authored rule for Sxxx: <구조 변경 문장>" 복사형 | **160 / 160** | 규칙 문장이 따로 쓰이지 않았다 |
| 지연 결과가 모두 같은 effect(`eff_r1_return_registry_logs_name`) | **160 / 160** | 지연 결과가 seed마다 다르지 않다 |
| 연결이 기본값(H0 지역 + `clock_public_record`) | 112 / 160 | 실제 쓰임처 없이 기본 연결만 있을 가능성 |
| `cross_link`·`immediate_consequence` 문장 | 전부 같은 틀 | "Sxxx is read by the … record and changes its state." |
| anti-generic 게이트 g1–g8 | 전부 true | 자동 게이트는 통과하지만 사람이 읽은 적은 없다 |
| effect 전체 | 57 | `content/effects/` |
| effect의 `seed_ids`가 `seed_s001` 하나뿐 | **57 / 57** | effect↔seed 연결이 형식만 채워졌다 |

→ seed의 `source_intent`(사용자 메모에서 온 한 줄)만 실제 내용이다. 나머지 칸은 틀이다. 검수는 `source_intent`와 실제 연결 대상이 맞는지를 보면 된다.

## A. seed 160건

| 판정 | id | 절/쓰임 | 원래 의도(source_intent) | 연결 | 기계 표시 |
|---|---|---|---|---|---|
| [ ] | seed_s001 | A/ROOT | 왕관은 왕보다 높은 곳에 위치한다. | action:act_ash_hound_lunge, clock:clock_contamination | 규칙=구조 문구 복사 |
| [ ] | seed_s002 | A/ROOT | 왕은 바뀌지만 왕관은 하나다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s003 | A/ROOT | 왕관은 왕보다 오래간다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s004 | A/SYSTEM | 개인을 하나의 self로 보지 않는 신체/장기/신경의 다중 voice. | relationship:rel_02_orrin_intake, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s005 | A/SYSTEM | clone은 body와 memory를 공유해도 social continuity가 다르다. | region:region_r2_siltglass_commons, clock:clock_public_record | 규칙=구조 문구 복사 |
| [ ] | seed_s006 | A/SYSTEM | high-level cognition이 low-level information을 버린다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s007 | A/ROOT | 여러 protocol이 recovery와 recognition을 동시에 관리한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s008 | A/SYSTEM | death를 없애는 대신 다른 시간/role/branch로 비용을 옮긴다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s009 | B/MODULE | 틈새/백룸은 recovery가 실패한 공간. | relationship:rel_07_bryn_route, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s010 | B/MODULE | 성벽/경계가 갑자기 흔들리면 사람이 빠진다. | document:doc_r7_wall_phase_ledger, prop:prop_r7_outer_wall_seam | 규칙=구조 문구 복사 |
| [ ] | seed_s011 | B/SYSTEM | 귀환 총괄청이 복귀자를 record/분류/격리한다. | conversation:conv_r1_intake_desk, npc:npc_02_orrin_kest | 규칙=구조 문구 복사 |
| [ ] | seed_s012 | B/SYSTEM | 이단심문소는 recovery를 거부하는 사람을 처리한다. | conversation:conv_h0_appeal_chamber, npc:npc_03_veya_morcant | 규칙=구조 문구 복사 |
| [ ] | seed_s013 | B/SYSTEM | 신성공학은 신앙/오염을 기술어로 변환한다. | prop:prop_r3_latency_bell, region:region_r3_bellhouse_hospice | 규칙=구조 문구 복사 |
| [ ] | seed_s014 | B/SYSTEM | faith가 response delay를 줄인다. | conversation:conv_r1_cold_relay, npc:npc_13_tovan_reed | 규칙=구조 문구 복사 |
| [ ] | seed_s015 | B/MODULE | backroom history가 disaster, administration/industrialization, normalization 단계로 변한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s016 | B/TONE | “빠져” 같은 짧은 operational dialogue. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s017 | B/SYSTEM | contamination는 이동/접촉/행동으로 변한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s018 | B/MODULE | 200년간의 backroom 공략이 실패와 fatigue를 누적한다. | region:region_r4_crownwell_archive, clock:clock_public_record | 규칙=구조 문구 복사 |
| [ ] | seed_s019 | B/TONE | rule chapter number와 incident report 형식. | conversation:conv_r8_medium_store, document:doc_r4_contradictory_translation | 규칙=구조 문구 복사 |
| [ ] | seed_s020 | C/MODULE | magical girl transformation is a boot/load process. | conversation:conv_r8_medium_workspace, npc:npc_04_sable_halm | 규칙=구조 문구 복사 |
| [ ] | seed_s021 | C/SYSTEM | contract/permission validation precedes transformation. | prop:prop_r5_boot_contract_board, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s022 | C/SYSTEM | body hardware allocates a temporary execution space. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s023 | C/SYSTEM | fast boot trades spectacle for stability. | prop:prop_r5_repair_bench_rack, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s024 | C/TONE | transformation UI/log reports incomplete stages and failures. | conversation:conv_r8_weave_yard, npc:npc_22_iven_marrow | 규칙=구조 문구 복사 |
| [ ] | seed_s025 | C/MODULE | magical girl support system has brain/body hardware logs. | region:region_r6_gristmarket_ward, clock:clock_public_record | 규칙=구조 문구 복사 |
| [ ] | seed_s026 | C/SYSTEM | transformation is not a costume change; it changes who can recognize the person. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s027 | C/MODULE | “fairy” support system is absurdly bureaucratic and intimate. | document:doc_r3_mercy_engine_trial_value, prop:prop_r3_mercy_engine_valve | 규칙=구조 문구 복사 |
| [ ] | seed_s028 | D/SYSTEM | organs answer with different priorities. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s029 | D/MODULE | brain speaks after decoding neural language. | document:doc_r6_custody_split_deed, prop:prop_r6_heart_petition_table | 규칙=구조 문구 복사 |
| [ ] | seed_s030 | D/SYSTEM | the same event can be “for prosperity” from brain and organs. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s031 | D/ROOT | recovery preserves a function but not the original failure. | prop:prop_r6_drainage_pump, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s032 | D/SYSTEM | clone memory is identical but each clone becomes socially distinct. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s033 | D/MODULE | mass clone deployment consumes ecology and coordination capacity. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s034 | D/SYSTEM | loop preserves knowledge but can move responsibility. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s035 | D/MODULE | quantum immortality shifts death cost rather than erasing it. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s036 | D/TONE | “infinite regression” can become a single-player joke. | conversation:conv_r8_art_testimony, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s037 | D/ONEOFF | a body part speaks in a serious meeting. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s038 | D/SYSTEM | low-level brain damage cannot be fixed by understanding alone. | prop:prop_r6_organ_intake_counter, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s039 | E/TONE | people answer impossible problems with employment, therapy, paperwork, manuals, group chat. | conversation:conv_r8_labor_desk, npc:npc_14_eda_marrow | 규칙=구조 문구 복사 |
| [ ] | seed_s040 | E/MODULE | freelancer says the situation will continue for thirty years. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s041 | E/TONE | a cure is promised in thirty years; coworkers react with false hope. | document:doc_r6_cure_debt_ledger, prop:prop_r6_cure_queue_board | 규칙=구조 문구 복사 |
| [ ] | seed_s042 | E/MODULE | school uses animal names as guardian names. | conversation:conv_r8_lineage_hall, document:doc_r5_boot_name_hearing | 규칙=구조 문구 복사 |
| [ ] | seed_s043 | E/TONE | adult/administrative confusion around a photograph. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s044 | E/SYSTEM | a guard’s mistake changes which name protects whom. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s045 | E/MODULE | institution labels a dangerous child/patient as a special case. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s046 | E/SYSTEM | a person can be helpful and legally dangerous at the same time. | document:doc_r2_water_ration_sheet, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s047 | E/TONE | group chat is the emergency protocol. | conversation:conv_h0_crier_thread, npc:npc_10_juno_caster | 규칙=구조 문구 복사 |
| [ ] | seed_s048 | E/TONE | app/open chat makes private panic public. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s049 | E/MODULE | a company/office treats biological anomaly as a deliverable. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s050 | E/TONE | a simple “shut up” subverts a verbose technical explanation. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s051 | F/ROOT | operator replaces operator, protocol survives. | conversation:conv_h0_crown_well, npc:npc_12_ravenna_holt | 규칙=구조 문구 복사 |
| [ ] | seed_s052 | F/SYSTEM | authority has a physical object and an abstract claim. | prop:prop_r4_crown_fragment_plinth, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s053 | F/MODULE | a title is more durable than the person who holds it. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s054 | F/SYSTEM | institutions compete over the right to interpret the crown. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s055 | F/ONEOFF | a subordinate knows the crown’s position better than the king. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s056 | F/SYSTEM | a record can outlive the event and become more dangerous than the event. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s057 | F/TONE | “the king changes” treated as routine administration. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s058 | F/MODULE | a region’s architecture encodes who is above whom. | prop:prop_r4_weight_lift_counter, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s059 | F/SYSTEM | the crown does not explain itself; every faction supplies a different protocol. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s060 | F/ONEOFF | an object in a higher location refuses the king’s interpretation. | prop:prop_r4_low_level_stacks, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s061 | G/SYSTEM | many identical bodies can destroy an ecosystem through aggregate consumption. | conversation:conv_h0_ration_counter, npc:npc_08_meral_dune | 규칙=구조 문구 복사 |
| [ ] | seed_s062 | G/MODULE | survival depends on knowing which plants/water are safe. | conversation:conv_h0_route_board, npc:npc_07_bryn_oskel | 규칙=구조 문구 복사 |
| [ ] | seed_s063 | G/SYSTEM | knowledge is distributed among people, not one hero. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s064 | G/MODULE | cold, hunger, disease, and social conflict are simultaneous clocks. | prop:prop_r2_waterline_mark, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s065 | G/TONE | a detailed number makes an absurd catastrophe feel bureaucratic. | conversation:conv_r8_circulation_board, prop:prop_r7_shelter_ring_ledger | 규칙=구조 문구 복사 |
| [ ] | seed_s066 | G/SYSTEM | resource extraction changes climate, sound, and social order. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s067 | G/MODULE | a remote settlement is safe only if knowledge exchange survives. | document:doc_r2_seed_vault_ledger, prop:prop_r2_seed_vault_shelf | 규칙=구조 문구 복사 |
| [ ] | seed_s068 | G/TONE | people estimate survival by making grim calculations in public. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s069 | H/ROOT | high-level interpretation discards low-level errors. | conversation:conv_h0_glossary_counter, npc:npc_06_tamas_quill | 규칙=구조 문구 복사 |
| [ ] | seed_s070 | H/SYSTEM | reading can become shortcut and lose nuance. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s071 | H/TONE | technical process is understood through an intentionally wrong or simplified model. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s072 | H/MODULE | translation takes longer than the original world’s lifetime. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s073 | H/SYSTEM | a partial translation creates a new local law. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s074 | H/ONEOFF | a person knows the translation is wrong but uses it anyway. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s075 | H/TONE | foreign technical terms remain untranslated in a social scene. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s076 | H/MODULE | an alien values humans for low entropy and stable repetition. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s077 | H/SYSTEM | human identity is ambiguous at low and high cognition levels. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s078 | H/TONE | a precise name fails to identify the same being at another scale. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s079 | I/MODULE | surgery can alter a body without altering its social identity. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s080 | I/SYSTEM | a failed operation leaves a valid but unfamiliar protocol. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s081 | I/TONE | device logs report a body part as a separate subsystem. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s082 | I/MODULE | a low-level brain error changes how a person reads language and identity. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s083 | I/SYSTEM | recovery is a workaround manual, not restoration of the original. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s084 | I/ONEOFF | a person calmly explains that a body part is filing a complaint. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s085 | I/TONE | medical terminology turns grief into a queue. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s086 | I/MODULE | a transformation can be beautiful, legally forbidden, and socially rejected at once. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s087 | I/SYSTEM | organ disagreement is a combat/negotiation state. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s088 | J/MODULE | magical girl support system as a social service. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s089 | J/MODULE | dragon warrior as an absurd institutional job. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s090 | J/MODULE | runaway party from a harem-like obligation. | prop:prop_r3_vow_ledger_desk, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s091 | J/MODULE | a school that is both a horror site and a registry. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s092 | J/MODULE | a freelancer’s cure/therapy economy. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s093 | J/MODULE | a survival settlement with no native expertise but many bodies. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s094 | J/MODULE | a magic-girl transformation lab inside a medieval-looking order. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s095 | J/MODULE | a backroom cathedral that treats faith as latency reduction. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s096 | J/MODULE | a wilderness region where mass cloning ends the local ecology. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s097 | J/MODULE | a translation office that accidentally creates a new law. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s098 | J/MODULE | an organ clinic where patients negotiate with body authorities. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s099 | J/MODULE | a crown archive above every royal hall. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s100 | J/MODULE | a public group chat becomes the only surviving witness. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s101 | K/ONEOFF | a serious official explains a ridiculous rule without breaking tone. | conversation:conv_r8_cut_chamber, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s102 | K/ONEOFF | a child asks the only question that exposes the crown’s category error. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s103 | K/ONEOFF | a therapist treats a loop as a work schedule. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s104 | K/ONEOFF | a doctor asks the heart to sign a form. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s105 | K/ONEOFF | a magic-girl support agent logs a failed transformation as “relationship pending.” | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s106 | K/ONEOFF | a clone refuses a name because the original already used it legally. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s107 | K/ONEOFF | a public record describes a person as an object while the person is speaking. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s108 | K/ONEOFF | a king orders a crown moved, and the clerk replies that the crown is already above the order. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s109 | K/ONEOFF | a survival calculation becomes a love confession because both use the same missing number. | prop:prop_r5_gantry_cradle, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s110 | K/ONEOFF | an alien compliments a human’s repetitive low-entropy behavior. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s111 | K/ONEOFF | a backroom rule is broken by following an institution’s safety manual exactly. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s112 | K/ONEOFF | an organ chorus interrupts a political meeting with a practical complaint. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s113 | K/ONEOFF | a magical transformation is technically successful but socially unrecognized. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s114 | K/ONEOFF | a group chat member solves a crisis by forwarding a screenshot with no context. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s115 | K/ONEOFF | a recovery system returns a person with a correct body and wrong employment history. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s116 | K/ONEOFF | a crown archive contains a previous king’s memory but not the king. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s117 | K/ONEOFF | a region’s danger is a rumor until an NPC treats the rumor as a physical object. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s118 | K/ONEOFF | a body-horror transformation is the only way to save a relationship, and both characters argue about consent. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s119 | K/ONEOFF | an institution’s emergency form requires a category that legally does not exist. | conversation:conv_r8_lineage_desk, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s120 | K/ONEOFF | the same event is reported as a miracle, a contamination case, and a labor dispute. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s121 | L/ROOT | 마나를 원소로 둘지 미발견 화합물로 둘지 선택해야 한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s122 | L/SYSTEM | 마나 농도가 높을수록 시전자는 편해지고 수련 효율이 오른다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s123 | L/SYSTEM | 마나 농도가 임계치를 넘으면 폭발한다. | prop:prop_r2_disperser_housing, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s124 | L/MODULE | 산인데 사람들은 평지를 걷는다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s125 | L/TONE | 위험한 현상을 자연마법으로 즉시 정당화하는 설명. | npc:npc_23_turo_bex, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s126 | L/SYSTEM | 마나를 안전 밀도로 흩뿌리는 가습기/분산기. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s127 | L/SYSTEM | 축적 마나를 외부 공기로 순환시키는 장치. | document:doc_r2_circulation_ledger, prop:prop_r2_circulator_stack | 규칙=구조 문구 복사 |
| [ ] | seed_s128 | L/SYSTEM | 발을 못하거나 방출만 되는 체질처럼 마나 처리 체질이 존재한다. | document:doc_r3_mana_profile_triage_board, prop:prop_r3_mana_profile_board | 규칙=구조 문구 복사 |
| [ ] | seed_s129 | L/SYSTEM | 마나가 쌓이지 않는 사람과 과잉 축적되는 사람. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s130 | L/MODULE | 마나 밀도가 극단인 자연 지형. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s131 | L/SYSTEM | 마나가 뇌/면역체계를 손상시키거나 각성시킨다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s132 | L/SYSTEM | 미세플라스틱를 땀샘으로 배출하는 능력. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s133 | L/SYSTEM | 미세플라스틱를 다루는 능력은 실패하면 cognition/competence를 잃는다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s134 | L/MODULE | 인류가 플라스틱 시대를 지나 진화한 미래. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s135 | L/SYSTEM | 진화가 방향성과 효율 측면에서 매우 빠르다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s136 | L/MODULE | 후성 유전 능력이 직업별 전문 집안을 빠르게 만든다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s137 | L/MODULE | 마법을 발명한 자가 먼저 예술가로 불린다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s138 | L/MODULE | 마법 유행이 마을을 바꾸고 마법사 집단이 탄생한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s139 | L/MODULE | 소규모 마법 예술가 집단은 허약하고 주류에 이용당한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s140 | L/MODULE | 방랑 마법사, 마법학원, 귀족의 노예, 직업 전환자가 분화된다. | document:doc_r5_supply_rack_receipt, prop:prop_r5_supply_rack | 규칙=구조 문구 복사 |
| [ ] | seed_s141 | L/MODULE | 마법학원 학생이 protagonist가 될 수 있다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s142 | L/SYSTEM | 수련이 특정 유전인자를 활성화한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s143 | L/SYSTEM | 마법사 가문은 아직 정립되지 않은 magic을 유전한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s144 | L/SYSTEM | 가문 magic는 특정 가문만 사용할 수 있다. | npc:npc_24_perri_lowe, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s145 | L/TONE | “나는 이 magic를 쓸 줄 안다”가 실전 숙련을 뜻하는 occupational speech. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s146 | L/SYSTEM | 종이에 magic을 적신 뒤 자른다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s147 | L/SYSTEM | positive magic theory label을 아직 확정하지 않는다. | document:doc_r4_glossary_slot_register, prop:prop_r4_glossary_slot | 규칙=구조 문구 복사 |
| [ ] | seed_s148 | L/MODULE | magic이 textile/scroll craft로 시작된다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s149 | L/SYSTEM | 가위로 재단을 빠르게 만드는 combat weave. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s150 | L/SYSTEM | 종이접기 magic은 입체 구현이 어려워 더 고난도다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s151 | L/MODULE | 전투 마법사는 허리춤에 직물 조각을 건넨다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s152 | L/SYSTEM | 전투 전에 scroll/weave를 준비하고 실전에서 선택해 직조한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s153 | L/SYSTEM | 종이를 던지고 칼로 썰어 magic을 발동한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s154 | L/MODULE | 포탈 magic은 가위로 공허를 잘라 다른 차원을 연다. | prop:prop_r7_storm_verge_cut, region:region_h0_undersign_exchange | 규칙=구조 문구 복사 |
| [ ] | seed_s155 | L/SYSTEM | 포탈 shape는 인풋이며 아웃풋/위험을 결정한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s156 | L/MODULE | 화산: 차가운 것 | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s157 | L/MODULE | James/observer entity: arbitrary input, mental attack output. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s158 | L/SYSTEM | 고위 portal은 다른 차원 존재와 계약한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s159 | L/SYSTEM | 계약 spell은 불발 가능성이 낮고 구체적이다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |
| [ ] | seed_s160 | L/SYSTEM | 가위/칼날의 물리 구조가 공허를 자르는 비용과 안정성을 결정한다. | region:region_h0_undersign_exchange, clock:clock_public_record | 규칙=구조 문구 복사; H0+공공기록 시계 기본 연결 |


## B. effect 57건

effect는 실제 게임 상태를 바꾸는 기록이다. 연산 목록과 쓰이는 곳을 보고, 결과가 공간·사물·인물 행동으로 보이는지 판정한다.

| 판정 | id | 시점 | 연산 | 쓰이는 곳 | seed_ids |
|---|---|---|---|---|---|
| [ ] | eff_h0_arrival_declaration_filed | delayed | set_axis, flag, relationship | conv_h0_appeal_chamber, conv_h0_crier_thread, conv_h0_crown_well, conv_h0_glossary_counter, conv_h0_ration_counter, conv_h0_return_desk, conv_r8_art_testimony, prop_h0_counterweight_map, npc_01_ilyra_senn, npc_03_veya_morcant, npc_06_tamas_quill, npc_08_meral_dune, npc_10_juno_caster, npc_12_ravenna_holt, npc_26_cael_orin | seed_s001 |
| [ ] | eff_r1_ash_debt_opens_chute | immediate | unlock_route, prop_state, grant_item | conv_h0_route_board, conv_r1_cold_relay, prop_h0_ration_counter, prop_r1_ash_garden_thread, enc_r1_the_debt_walk, npc_02_orrin_kest, npc_07_bryn_oskel, npc_08_meral_dune, npc_13_tovan_reed, npc_14_eda_marrow | seed_s001 |
| [ ] | eff_r1_return_registry_logs_name | on_clock_stage | npc_state, set_axis, flag | conv_h0_appeal_chamber, conv_h0_crier_thread, conv_h0_crown_well, conv_h0_glossary_counter, conv_h0_ration_counter, conv_h0_route_board, conv_r1_cold_relay, conv_r1_intake_desk, conv_r8_art_testimony, prop_r1_wrong_return_door, enc_r1_door_role_test, enc_r1_the_debt_walk, npc_01_ilyra_senn, npc_02_orrin_kest, npc_03_veya_morcant, npc_05_nera_voss, npc_06_tamas_quill, npc_07_bryn_oskel, npc_11_cael_ren, npc_12_ravenna_holt, npc_20_mira_vask, npc_26_cael_orin, rec_r1_kiln_reentry | seed_s001 |
| [ ] | eff_r1_wrong_return_witnessed | immediate | relationship, set_axis, flag | conv_r1_intake_desk, conv_r1_wrong_return_hearing, doc_r1_wrong_return_log, enc_r1_ash_choir, enc_r1_second_registration, enc_the_intake_stamp, enc_the_intake_stamp_deep, npc_02_orrin_kest, npc_08_meral_dune, npc_10_juno_caster, npc_11_cael_ren, npc_13_tovan_reed | seed_s001 |
| [ ] | eff_r2_census_third_count_filed | immediate | flag | conv_r2_water_round, enc_r2_the_stack_dump, enc_the_clone_census, rec_r2_census_clone | seed_s001 |
| [ ] | eff_r2_circulation_ledger_filed | immediate | flag | prop_r2_circulator_stack, enc_r2_the_stack_dump, enc_the_siltglass_toll, enc_the_siltglass_toll_civic | seed_s001 |
| [ ] | eff_r2_circulation_ledger_read | immediate | flag | conv_r2_water_round, doc_r2_circulation_ledger, enc_the_many_become_one, enc_the_many_become_one_quorum | seed_s001 |
| [ ] | eff_r2_disperser_reading_filed | immediate | flag | prop_r2_disperser_housing, enc_the_many_become_one, enc_the_many_become_one_quorum | seed_s001 |
| [ ] | eff_r2_emergency_convoy_rostered | immediate | flag | enc_the_last_safe_water | seed_s001 |
| [ ] | eff_r2_flood_refuge_opened | immediate | flag | prop_r2_root_bridge_anchor | seed_s001 |
| [ ] | eff_r2_seed_vault_ledger_read | immediate | flag | doc_r2_seed_vault_ledger, prop_r2_seed_vault_shelf | seed_s001 |
| [ ] | eff_r2_seed_vault_sample_filed | immediate | flag | prop_r2_root_bridge_anchor, enc_the_last_safe_water | seed_s001 |
| [ ] | eff_r2_water_ration_read | immediate | flag | conv_r2_water_round, doc_r2_water_ration_sheet | seed_s001 |
| [ ] | eff_r2_water_recognition_filed | immediate | flag | prop_r2_waterline_mark, enc_the_last_safe_water | seed_s001 |
| [ ] | eff_r3_boiler_lift_opened | immediate | flag | prop_r3_mercy_engine_valve | seed_s001 |
| [ ] | eff_r3_care_train_rostered | immediate | flag |  | seed_s001 |
| [ ] | eff_r3_consent_record_filed | immediate | flag | conv_r3_intake_triage, enc_the_bell_that_counts_late, enc_the_bell_that_counts_late_blackout | seed_s001 |
| [ ] | eff_r3_emergency_care_received | immediate | flag |  | seed_s001 |
| [ ] | eff_r3_latency_receipt_filed | immediate | flag | conv_r3_intake_triage, prop_r3_latency_bell, enc_r3_the_scheduled_bell, enc_signal_interference | seed_s001 |
| [ ] | eff_r3_mana_profile_filed | immediate | flag | conv_r3_intake_triage, doc_r3_mana_profile_triage_board, prop_r3_mana_profile_board, enc_r3_the_scheduled_bell | seed_s001 |
| [ ] | eff_r3_return_registry_handoff | immediate | flag | enc_the_bell_that_counts_late, enc_the_bell_that_counts_late_blackout, rec_r3_hospice_respawn | seed_s001 |
| [ ] | eff_r3_trial_value_read | immediate | flag | doc_r3_mercy_engine_trial_value | seed_s001 |
| [ ] | eff_r3_vow_ledger_filed | immediate | flag | conv_r3_intake_triage, prop_r3_vow_ledger_desk, enc_the_bell_that_counts_late, enc_the_bell_that_counts_late_blackout | seed_s001 |
| [ ] | eff_r4_care_outcome_filed | immediate | flag | conv_r4_translation_desk, enc_archive_return_protocol, enc_a_name_has_teeth, enc_the_above_record | seed_s001 |
| [ ] | eff_r4_crown_stair_opened | immediate | flag | prop_r4_weight_lift_counter, enc_r4_the_precedence_hearing, enc_the_above_record, enc_the_above_record_authority | seed_s001 |
| [ ] | eff_r4_glossary_slot_filled | immediate | flag | conv_r4_translation_desk, doc_r4_glossary_slot_register, prop_r4_glossary_slot, enc_the_above_record, enc_the_above_record_authority, enc_the_unfinished_sentence | seed_s001 |
| [ ] | eff_r4_operator_memory_classified | immediate | flag | conv_r4_translation_desk, prop_r4_crown_fragment_plinth, enc_archive_return_protocol, enc_a_name_has_teeth, rec_r4_crown_continuity | seed_s001 |
| [ ] | eff_r4_translation_precedence_filed | immediate | flag | conv_r4_translation_desk, doc_r4_contradictory_translation, prop_r4_low_level_stacks, enc_a_name_has_teeth, enc_r4_the_precedence_hearing, enc_translation_drift | seed_s001 |
| [ ] | eff_r5_care_train_consent | immediate | flag | prop_r5_boot_contract_board, enc_licence_of_the_first_body | seed_s001 |
| [ ] | eff_r5_courier_shaft_consent | immediate | flag | enc_licence_of_the_first_body | seed_s001 |
| [ ] | eff_r5_folding_school_approach_opened | immediate | flag |  | seed_s001 |
| [ ] | eff_r5_gantry_cradle_loaded | immediate | flag | conv_r5_boot_contract, prop_r5_gantry_cradle | seed_s001 |
| [ ] | eff_r5_name_hearing_filed | immediate | flag | conv_r5_boot_contract, doc_r5_boot_name_hearing, enc_licence_of_the_first_body, enc_r5_the_permit_inspection | seed_s001 |
| [ ] | eff_r5_repair_bench_recovered | immediate | flag | prop_r5_repair_bench_rack | seed_s001 |
| [ ] | eff_r5_supply_gantry_opened | immediate | flag |  | seed_s001 |
| [ ] | eff_r5_supply_permit_split_filed | immediate | flag | conv_r5_boot_contract, enc_licence_of_the_first_body, enc_r5_the_permit_inspection | seed_s001 |
| [ ] | eff_r5_supply_rack_issued | immediate | flag | conv_r5_boot_contract, doc_r5_supply_rack_receipt, prop_r5_supply_rack | seed_s001 |
| [ ] | eff_r5_under_rail_shunt_opened | immediate | flag | prop_r5_boot_contract_board | seed_s001 |
| [ ] | eff_r6_ash_chute_opened | immediate | flag |  | seed_s001 |
| [ ] | eff_r6_drainage_dark_opened | immediate | flag |  | seed_s001 |
| [ ] | eff_r6_medicine_ferry_opened | immediate | flag | conv_r6_organ_intake, enc_r6_the_organ_quorum, enc_triage_conflict | seed_s001 |
| [ ] | eff_r6_organ_quorum_filed | immediate | flag | conv_r6_organ_intake, doc_r6_custody_split_deed, prop_r6_cure_queue_board, prop_r6_heart_petition_table, enc_consent_of_the_viscera, enc_r6_the_organ_quorum | seed_s001 |
| [ ] | eff_r6_pump_primed | immediate | flag | conv_r6_organ_intake, prop_r6_drainage_pump, enc_triage_conflict | seed_s001 |
| [ ] | eff_r6_residue_recovery_filed | immediate | flag | conv_r6_organ_intake, doc_r6_cure_debt_ledger, prop_r6_organ_intake_counter, enc_consent_of_the_viscera | seed_s001 |
| [ ] | eff_r6_under_rail_shunt_opened | immediate | flag | enc_consent_of_the_viscera | seed_s001 |
| [ ] | eff_r7_boundary_shortcut_opened | immediate | flag | conv_r7_wall_phase_survey, prop_r7_storm_verge_cut, enc_bailiff_of_the_outer_seam | seed_s001 |
| [ ] | eff_r7_boundary_witness_filed | immediate | flag | conv_r7_wall_phase_survey, doc_r7_wall_phase_ledger, enc_audit_above_the_market, enc_r7_the_seam_ruling, enc_the_audit_crossing | seed_s001 |
| [ ] | eff_r7_contract_placed_filed | immediate | flag | prop_r7_storm_verge_cut, enc_bailiff_of_the_outer_seam | seed_s001 |
| [ ] | eff_r7_crown_precedence_filed | immediate | flag, unlock_route | conv_r7_wall_phase_survey, doc_r7_crown_shadow_manifest, prop_r7_crown_position_plinth, enc_audit_above_the_market, enc_r7_the_seam_ruling | seed_s001 |
| [ ] | eff_r7_crown_stair_opened | immediate | flag |  | seed_s001 |
| [ ] | eff_r7_drainage_dark_opened | immediate | flag |  | seed_s001 |
| [ ] | eff_r7_settlement_vote_filed | immediate | flag | prop_r7_shelter_ring_ledger, enc_audit_above_the_market, enc_bailiff_of_the_outer_seam | seed_s001 |
| [ ] | eff_r7_supply_gantry_arrived | immediate | flag |  | seed_s001 |
| [ ] | eff_r7_wall_mandate_filed | immediate | flag | conv_r7_wall_phase_survey, prop_r7_outer_wall_seam, enc_bailiff_of_the_outer_seam | seed_s001 |
| [ ] | eff_r8_ash_choir_defeated | on_encounter_end | advance_clock, prop_state, apply_status | prop_r8_cut_chamber_wall, enc_r8_fold_that_refuses_the_hand, enc_r8_fold_that_refuses_the_hand_withdrawn, enc_r8_medium_store_quarantine, npc_04_sable_halm, npc_14_eda_marrow | seed_s001 |
| [ ] | eff_r8_concentration_registered | on_clock_stage | region_state, flag | conv_r8_circulation_board, conv_r8_cut_chamber, conv_r8_labor_desk, conv_r8_lineage_desk, conv_r8_lineage_hall, conv_r8_medium_store, conv_r8_medium_workspace, conv_r8_weave_yard, prop_r8_medium_store_shelf, enc_r8_medium_store_quarantine, enc_r8_the_graded_sheet, npc_04_sable_halm, npc_09_perrin_lask, npc_20_mira_vask, npc_21_halen_osk, npc_22_iven_marrow, npc_23_turo_bex, npc_24_perri_lowe, npc_25_jano_fesk, rec_r8_lineage_return | seed_s001 |
| [ ] | eff_r8_course_index_printed | immediate | region_state, grant_equipment, flag | conv_r8_circulation_board, conv_r8_course_index_desk, conv_r8_cut_chamber, conv_r8_labor_desk, conv_r8_lineage_desk, conv_r8_lineage_hall, conv_r8_medium_store, conv_r8_medium_workspace, conv_r8_weave_yard, enc_r8_the_graded_sheet, npc_04_sable_halm, npc_09_perrin_lask, npc_14_eda_marrow, npc_21_halen_osk, npc_22_iven_marrow, npc_23_turo_bex, npc_24_perri_lowe, npc_25_jano_fesk | seed_s001 |

