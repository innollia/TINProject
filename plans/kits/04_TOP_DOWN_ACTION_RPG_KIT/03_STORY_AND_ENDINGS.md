# Kit 04 — Story and Endings

## 사건 결과의 환경 자산 계약 — 2026-09-26

배경 제작은 [13](13_LAYERED_ENVIRONMENT_PRODUCTION.md)을 따른다. 각 cluster/ending/revisit의 이미 정의된 world mutation을 동일 장소의 prop presence·상태 차분·ground overlay로 나타낸다. 사건마다 무관한 새 배경을 생성하거나 전체 화면 tint만으로 결과를 대신하지 않는다.

인물이 사라진 결과는 배경에 남은 인물 그림을 포함하지 않아야 한다. 제거된 물체 뒤의 바닥과 그림자도 clean base로 복구한다. 여러 기관의 결과가 동시에 남을 때는 domain이 해석한 결과를 레이어 조합으로 보존하며, 미술용 우선순위가 narrative write를 취소하지 않는다. 관계·로맨스·공포·정치적 부조리의 내용과 분량은 기존 계획 그대로다.

상태: **WORLD/STORY EXECUTABLE PLAN**  
범위: `Top-down Action-RPG Kit`의 world narrative, NPC interaction cluster, layered truths, relationship/body arcs, authored story formats, partial resolution, endings, 10분+ beat map  
Primary Reference: **BLACK SOULS 2 하나**  
정본: `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`, `docs/research/top_down_action_rpg/IDEA_LEDGER.md`  
분할 해석: `docs/research/top_down_action_rpg/PLAN_RESOLUTION.md` (2026-09-25 canonical resolution)

이 파일은 위 resolution을 그대로 따른다. world/node는 `02_WORLD_STATE_AND_ROUTES.md`, NPC·관계는 `04_CHARACTERS_AND_RELATIONSHIPS.md`, data schema는 `06_AUTHORED_CONTENT_AND_DATA.md`, magic theory는 `12_MAGIC_THEORY.md`, Reference Game 실행은 `07_REFERENCE_GAME.md`가 소유하고, **이 파일은 story·cluster·truth·ending 분해만 소유한다.** 아래 §0.1의 re-key 표는 이미 폐기된 구버전 표기를 migration 기록으로만 보존한다. 표에 없는 구버전 표기는 이 파일에 남아 있지 않다.

이 파일은 core ledger(`S001`~`S120`)에 더해 magic supplement(`S121`~`S160`)의 story binding까지 소유한다. magic은 별도 우주가 아니라 `E4 The Concentration Layer`라는 같은 world의 implementation era이며, story가 다루는 대상은 power가 아니라 **labour/status/resource/recognition**이다. 통합 결과는 다음과 같다.

- node는 `H0` + `R1`~`R8` 9개, edge는 `E01`~`E18` 18개, cluster는 `HC-00` + `RC-01`~`RC-08` 9개다.
- axis는 `02` §3의 4개, pressure clock은 `02` §4의 6개, recovery는 `PLAN_RESOLUTION` §4의 7종이다. magic은 이 셋을 늘리지 않는다.
- seed register는 160행 전부 `PLANNED_RETAINED`이고, hard gate는 96, preferred target은 120이다.

## 0. 사용 경계와 원본성

이 문서는 사용자의 긴 메모를 `IDEA_LEDGER.md`의 문장 단위 idea source로 사용하되, 원문을 canon 문구나 원작 대사로 복사하지 않는다. 이 문서의 모든 고유 명사, 사건, 장소, NPC 관계, 문서 형식의 이름, 결말 조건은 TIN을 위해 새로 작성한 것이다.

- BLACK SOULS 2에서 가져가는 것은 world-preserving dialogue, command-first combat, layered document/corruption/aftermath, hub/backtracking, NPC system port, layered revelation, companion history라는 **구조적 문법**뿐이다.
- BLACK SOULS 2의 인물, 고유 세계관, 문구, 지도 순서, 보스, 유서, 수치, ending condition, UI asset은 사용하지 않는다.
- 앨리스와 앨리스 고유 요소는 사용하지 않는다. 앨리스 요소를 이름만 바꾸어 재사용하는 것도 금지한다.
- 사용자 플레이 A~H는 아래 story content type의 근거다. 확인되지 않은 death, target focus, gauge 수치, ending 화면을 원작 사실처럼 채우지 않는다.
- `IDEA_LEDGER.md`의 `planned` 사용 기록은 구현 완료를 뜻하지 않는다. 이 파일은 seed transformation, content binding, consequence, acceptance 조건을 고정하는 planning ledger다.

### 0.1 구버전 → canonical re-key 표

`04` §2.3과 `PLAN_RESOLUTION.md` §1–§2가 정한 re-key 결과다. 이 표는 migration 기록이며, 표의 좌변 ID는 이 파일의 어느 본문에서도 사용하지 않는다.

| 구버전 표기 (이 파일의 이전 판) | canonical | 근거 |
|---|---|---|
| world `Marrowglass`, `Marrowgate` | **The Undersign Basin**, `H0 The Undersign Exchange` | `02` §1 |
| `LOC_QUAY_OF_RETURNS`, `LOC_GLASS_STAIR`, `LOC_HOLLOW_WORKS`, `LOC_UPPER_REGISTER`, `LOC_HOLLOW_MARGIN`, `LOC_CLONE_GARDEN`, `LOC_MARROWGATE` | `R1`~`R8` + `H0`의 authored 내부 place 이름 | `02` §1, §7 |
| `CROWN_OBJECT_UPPER_REGISTER` | **Crown of Continuance** (다섯 조각 물리 왕관, `Crownwell Archive` 위에 고정) | `02` §1 |
| `CROWN_ALIGNMENT_OFFICE`, `CROWN_INVARIANT_CONTINUITY`, `CROWN_META_PROTOCOL` | **Crown Protocol** + `G8 Crown Precedence` gate | `02` §1, §6.1 |
| `INST_REENTRY_REGISTRY` | `Return Registry` (R1) / `Exchange Registrar` (H0) | `02` §9.3 |
| `INST_INTERPRETANCE` | `Translation Tribunal` / `Record Office` (R4) | `02` §9.3 |
| `INST_LUMEN_WORKS` | `Faith Engineering unit` (R3) / `Glasswing Ordinal`·`Support Registry` (R5) / `Gristmarket Clinic` (R6) | `02` §9.3 |
| `INST_UPPER_REGISTER` | `Crownwell Archive` — `Record Office`, `Censor`, `Crown Observatory` | `02` §7.5 |
| `INST_HOLLOW_MAINTENANCE` | `Boundary Survey` (R7) + `Kiln Wardens` (R1) | `02` §7.2, §7.8 |
| `LATTICEWAKE` | R1 `Wrong Return` lineage, `E1 The First Return` 층위, `E4 The Concentration Layer` 층위 | `02` §2.2, §7.2 |
| `CLUSTER_01_REENTRY_COUNTER` … `CLUSTER_10_AUDIT_CHAMBER` | `HC-00`, `RC-01` ~ `RC-08` (9개) | `02` §8, `07` §6 |
| `C01` … `C10` (cluster shorthand) | `HC-00`, `RC-01` ~ `RC-08` (9개) | `02` §8 |
| `CLUSTER_08_FOLDING_SCHOOL` 부재 | `RC-08` — The Fold That Refuses the Hand, `R8` | `02` §8.9, §7.9 |
| `CLUSTER_COUNT = 8` 서술 (이 파일 §10, §16.8, §18, §22 및 `04` §4.2/§7/§12 인용) | cluster 수 9개 (`HC-00` + `RC-01`~`RC-08`) | `02` §8, §12 |
| `AXIS_PROTOCOL_LEGITIMACY` / `AXIS_RECOGNITION_DRIFT` / `AXIS_CONTINUITY_PRESSURE` / `AXIS_RESOURCE_SCARCITY` | `protocol_legitimacy` / `recognition_drift` / `continuity_pressure` / `resource_scarcity` | `02` §3, `06` §6.1 |
| `AXIS_CONCENTRATION` / `AXIS_CRAFT_MASTERY` (이전 판의 magic 전용 축 시도) | **없음.** magic은 4축 안에서만 write한다 | `02` §3.4, `06` §6.1 |
| 이 파일의 자체 3-value ladder (low/middle/high) | **삭제.** 값 순서는 `02` §3, 저장 정수는 `06` §6.1 | `PLAN_RESOLUTION` §5 |
| `CLOCK_INSTITUTIONAL_RESPONSE` … `CLOCK_CROWN_ALIGNMENT` | `CL-INST`, `CL-CONT`, `CL-REC`, `CL-RES`, `CL-PER`, `CL-CROWN` | `02` §4, `07` §8 |
| `CLOCK_MAGIC`, `CLOCK_CONCENTRATION`, `CLOCK_CRAFT` (이전 판의 magic 전용 clock 시도) | **없음.** magic pressure는 기존 6개 clock의 입력값이다 | `02` §4.4, `06` §5.6 |
| `RECOVERY_MAGIC_CAST`, `RECOVERY_CIRCULATION` (이전 판의 magic recovery 시도) | **없음.** recovery는 canonical 7종이고 magic failure는 그 7종의 `kind`가 아니라 `status`/`clock`/`record` write다 | `PLAN_RESOLUTION` §4, `02` §10, `12` §8 |
| `E1` ~ `E3` era 목록만 존재 | `E1` ~ `E4` (`E4 The Concentration Layer` 추가) | `02` §2.2 |
| `E01` ~ `E17` edge 목록 | `E01` ~ `E18` (`E18 R5–R8 Folding School Approach` 추가) | `02` §5.2 |
| `H0` ~ `R7` node 목록 | `H0` + `R1` ~ `R8` | `02` §1, §7.0 |
| `VOICE_RETURN` / `VOICE_WORD` / `VOICE_ORGAN` / `VOICE_ARCHIVE` | `PLAYER_LAYER_BODY` / `_MEMORY` / `_ROLE` / `_RECOGNITION` (능력 트리 아님, consent owner 있는 identity state) | `04` §4.3, `WORLD_CONSTITUTION` R04 |
| `CONTINUITY_RECEIPT`, `SEMANTIC_BANDWIDTH`, `STABLE_LATENCY`, `LEGITIMACY_ACCESS` | `02` §5.4 allotment: `empty category docket`, `route debt token`, `lamp oil`, `care token`, `blank form`, `power cell`, `seed case`, `ash thread`, `archive weight`, organ medicine, safe water, `concentration sample`, `medium blank`, `fold sheet`, `blade credit`, `craft credit`, `lineage token` | `02` §5.4, §5.5 |
| `MANA_POINT`, `CONCENTRATION_BAR`, `CRAFT_XP` (이전 판의 magic 단일 자원 표기) | `magic.body_load` + `02` §5.5의 `res_*` (단일 `mana` 수치 없음) | `02` §5.5, §9.1, `12` §2.1 |
| `DOC_CROWN_MANIFEST`, `DOC_REENTRY_RECEIPT_NERA`, `DOC_WORKS_CONSENT`, `DOC_COST_LEDGER`, `DOC_MAINTENANCE_MANUAL`, `THREAD_MARROW_EMERGENCY`, `LOG_OPERATOR_SUCCESSION`, `LOG_ORGAN_CHORUS` | `02` family로 재지정: `R4-06`/`R4-07`, `R1-01`/`R1-06`, `R3-03`/`R5-01`, `R6-04`/`R2-08`, `R1-02`, `H0-05`, `R7-07`, `R6-03`/`R6-06` | `02` §7, §8 |
| `EVENT_RETURN_AUDIT`, `EVENT_GLOSSARY_HEARING`, `EVENT_CHORUS_CONSENT`, `EVENT_EMPTY_SEAT` | `RC-01` `carry claimant`, `RC-04` `publish contradiction`, `RC-06` `split custody`, `R7-07` `Operator Replacement`(=`G8`) | `02` §8, §6.1 |
| `DOC_CROWN_MANIFEST` … 잔여 `DOC_*`, `THREAD_*`, `LOG_*`, `EVENT_*` (이전 판의 story artifact ID) | 아래 §14.2의 `doc_*` / `thread_*` catalog ID로 재지정 | `02` §7, §8, `06` §3.2 |
| `REL_ILYRA_INDEX`, `REL_ORRIN_INTAKE`, `REL_VEYA_AUDIT`, `REL_SABLE_SUPPORT`, `REL_NERA_ORGAN`, `REL_TAMAS_TERM`, `REL_BRYN_ROUTE`, `REL_MERAL_RATION`, `REL_PERRIN_WARD`, `REL_JUNO_CHANNEL`, `REL_CAEL_HISTORY`, `REL_RAVENNA_SEAT`, `REL_TOVAN_TRIAGE`, `REL_EDA_SHIFT` | `rel_01_ilyra_record`, `rel_02_orrin_intake`, `rel_03_veya_audit`, `rel_04_sable_support`, `rel_05_nera_organ`, `rel_06_tamas_term`, `rel_07_bryn_route`, `rel_08_meral_ration`, `rel_09_perrin_ward`, `rel_10_juno_channel`, `rel_11_cael_history`, `rel_12_ravenna_seat`, `rel_13_tovan_triage`, `rel_14_eda_shift` (`rel_<nn>_<snake>` 형태) | `06` §3.5.3, §5.7 |
| `end_receipt_of_a_life`, `end_law_without_master`, `end_many_mouths_one_person`, `end_empty_seat`, `end_four_anchors`, `end_last_witness` | `end_r1_receipt_of_a_life`, `end_g1_law_without_master`, `end_o1_many_mouths_one_person`, `end_a1_empty_seat`, `end_c1_four_anchors`, `end_c2_last_witness` | `06` §3.5.6 |
| `ROUTE_CRAFT` 부재 (이전 판의 magic 미통합 상태) | `ROUTE_CRAFT` — The Folded Wage (§9) | `02` §5.1 craft loop, §6.2 loop 7·8 |
| `TRUTH_T6_*`, `TRUTH_T7_*` 부재 (이전 판의 magic 미통합 상태) | `TRUTH_T6_CRAFT_IS_LABOR`, `TRUTH_T7_CUT_IS_A_DEBT` (§8) | `12` §5, §9, `IDEA_LEDGER` §L |
| `SEED_REGISTER_120` / `gate 72` / `preferred 90` | denominator 160, hard gate 96, preferred target 120 | `PLAN_RESOLUTION` §6, `10` `test_seed_usage_counts_distinct_units_not_lines` |
| `TRUTH_T0_PUBLIC_PROMISE` | `TRUTH_T0_CONTINUANCE_PROMISE` | 이 파일 §8 |
| `TRUTH_T1_OFFICE_SPLIT` | `TRUTH_T1_PROTOCOL_SPLIT` | 이 파일 §8 |
| `TRUTH_T2_COST_TRANSFER` | `TRUTH_T2_COST_EXPORT` | 이 파일 §8 |
| `TRUTH_T3_CROWN_INVARIANT` | `TRUTH_T3_CROWN_CONTINUANCE` | 이 파일 §8 |
| `TRUTH_T4_PLAYER_BRIDGE` | `TRUTH_T4_BRIDGE_SUBJECT` | 이 파일 §8 |
| `TRUTH_T5_NO_SINGLE_WILL` | `TRUTH_T5_NO_SINGLE_WILL` (ID 유지, source 재지정) | 이 파일 §8 |
| `NPC_IONA_VEY`, `REL_IONA_*` | `npc_01_ilyra_senn`, `rel_01_ilyra_record` | `04` §2.3 |
| `NPC_ARDEN_ROOK` | `npc_01_ilyra_senn` | `04` §2.3 |
| `NPC_TAMSIN_QUILL` | `npc_12_ravenna_holt` (`Crown Protocol` seat) | `04` §2.3 |
| `NPC_NERA_KEST` | `npc_11_cael_ren` | `04` §2.3 |
| `NPC_SABLE_ORR`, `REL_SABLE_*` | `npc_06_tamas_quill`, `rel_06_tamas_term` | `04` §2.3 |
| `NPC_MARA_VELL`, `REL_MARA_*` | `npc_05_nera_voss`, `rel_05_nera_organ` | `04` §2.3 |
| `NPC_OREN_VALE` | organ disagreement surface = `npc_05_nera_voss`의 `CALL_BODY_VETO` + organ quorum. 별도 actor 금지 | `04` §2.3 |
| `NPC_LIO_FEN` | `npc_09_perrin_lask` | `04` §2.3 |
| `NPC_RUSK_DELL`, `NPC_NIX_ORR` | `npc_10_juno_caster` | `04` §2.3 |
| `NPC_PELL_OAR`, `NPC_RHEA_SALT` | `npc_07_bryn_oskel` | `04` §2.3 |
| `NPC_HALE_SEN` | `npc_08_meral_dune` | `04` §2.3 |
| `NPC_CALLA_ORN` | `npc_05_nera_voss`의 organ quorum surface. 별도 actor 금지 | `04` §2.3 |
| `NPC_ELI_MARROW` | **support resident**. `npc_02_orrin_kest`의 intake surface로 재사용, `npc_*` ID 없음 | `04` §2.3 |
| `NPC_THE_SURVEYOR` | `npc_07_bryn_oskel`의 outsider observation port. NPC로 세지 않고 `one_off_dialogue_seeds`/`TONE` surface로 실행 | `04` §2.3 |
| `role_field_investigator` | player role ID. NPC ID가 아니다. `npc_11_cael_ren`과 병합하지 않는다 | `04` §2.3 |


## 1. Primary Reference와 실제 evidence 적용

| evidence | 관찰된 구조 | 이 스토리 계획에 적용하는 것 | 적용하지 않는 것 |
|---|---|---|---|
| 사용자 A | world를 유지한 NPC conversation, portrait/name/text band, 우측 choice list, page advance, world-preserving dialogue | `ConversationDefinition`, `ChoiceDefinition`, narration beat를 독립 authored type으로 둔다. choice의 결과는 dialogue가 아니라 NPC/world/relationship state에 atomic하게 적용한다 | 원작 choice 문구, red 의미의 원작 확정, focus/cancel 동작을 아직 확인되지 않았다는 사실 |
| 사용자 B | 중앙 enemy, command category, target/action timing, combat-local resource band | 스토리 choice가 전투로 이어질 때 command/target을 별도 domain state로 유지한다. gauge/story text가 combat scheduler를 소유하지 않는다 | AP, red bar, exact cadence, hit/break motion을 story data에서 임의 추정하지 않음 |
| 사용자 C·H | 정상 world 위 narration band, 사건 후 같은 world에 player/target/trace가 남는 aftermath | narration beat와 aftermath state를 world 위에 투영하고, irreversible event는 field/NPC/object surface를 바꾼다 | 원작 사건, blood placement, 화면 비율, world layout |
| 사용자 D~F | 한 문서를 여러 page로 읽고 world 위에 layered reading focus를 둠 | `doc_*`는 `06` §5.14 `DocumentDefinition`(page, source, corruption, post-read effect)을 쓴다. 한 page는 `02`/`10` 기준 9줄을 넘지 않는다 | 원작 유서, font, line length, page timing |
| 사용자 G | deterministic-looking corruption, 일부 token/character/line의 붕괴 | corruption rule은 authored token span과 state threshold만 사용한다. 매번 random text를 만들지 않는다 | 원작 corrupted string과 exact glitch sequence |
| `BLACK_SOULS_2_RESEARCH.md`의 반복 구조 | hub와 복수 route, NPC quest의 system port, survival/death/refusal이 world를 바꿈, 후기의 partial liberation | 모든 route가 같은 world state와 recovery consequence를 공유한다. NPC는 dialogue-only가 아니다 | 원작 quest chain, map sequence, boss/ending content |
| `USER_PLAY_REFERENCE_2026-09-25.md`의 미확인 목록 | choice focus, target cancel, death/recovery, ending, gauge exact meaning 미확인 | story plan은 이 미확인 항목을 구현 사실로 취급하지 않고, sibling system plan의 검증 대상으로 남긴다 | 미확인 UI/수치를 채우기 위한 기억 기반 구현 |

## 2. Story logline

`H0 The Undersign Exchange`를 중심으로 수직으로 겹친 **The Undersign Basin**에서 `Crown of Continuance`는 세 층위로 동시에 존재한다. 물리적으로는 `R4 Crownwell Archive` 위에 고정된 다섯 조각 왕관이고(`R4-06 Crown Fragment`, `R7-04 Crown Position`), 정치적으로는 operator를 교체하고 recovery·recognition·authority 중 어느 protocol이 우선하는지를 정하는 **`Crown Protocol`**이며, 규칙적으로는 operator가 바뀌어도 왕관과 이전 protocol의 debt가 사라지지 않는다는 invariant다.

플레이어는 네 recovery protocol이 서로 다른 continuity를 한 몸에 남긴 `role_field_investigator`로 깨어난다. 플레이어는 investigator이면서 각 protocol의 experiment/subject다. `Return Registry`, `Translation Tribunal`, `Gristmarket Clinic`/`Faith Engineering unit`, `Crownwell Archive`는 각각 competent하지만 서로 다른 category를 쓴다. 그 category error가 recovery, recognition, authority를 각각 다르게 구현하면서 disaster를 만든다.

그 위에 `E4 The Concentration Layer`가 같은 spine 위로 쌓여 있다. 농도(`concentration`)는 별도 우주가 아니고 `R2`의 `humidifier`/`disperser`/`circulator` 같은 civic infrastructure, `R3`의 `mana_profile` triage, `R5`의 boot·craft, `R7`의 void-cut, `R4`의 비어 있는 `glossary` slot, `R8 The Folding School`의 curriculum으로 물리적 표면을 갖는다. 그 era에서 craft를 발명한 사람은 마법사가 아니라 **예술가/functional artisan**로 먼저 불리고, 그래서 재료 축적과 허약한 몸을 감당해야 했으며, 학교는 그 계급을 `공정`·자격·고용으로 정형화했다. magic story의 conflict는 "마법을 배울 수 있는가"가 아니라 **"배운 craft를 누구의 노동로 기록할 것인가"**다.

핵심 질문은 "누구를 구할 것인가?"만이 아니다. 다음 질문이 서로 충돌한다.

```text
어떤 몸을 구하면 그 사람의 이름은 어디에 남는가?
어떤 기록을 보호하면 그 기록은 누구의 reality를 지배하는가?
어떤 장기를 만들면 그 장기는 사람을 소유하는가, 사람이 장기를 소유하는가?
누가 Crown Protocol을 해석할 수 있으며, 해석의 비용은 누가 계속 운반하는가?
농도를 낮춰 안전을 얻은 비용은 어느 이웃의 `K`와 `E`에 적립되는가?
배운 craft를 학교의 course credit으로 적을 것인가, foundry의 labor hour으로 적을 것인가, lineage에 숨길 것인가?
자른 공허가 돌아오지 않을 obligation을 남겼을 때 그 빚은 누구의 이름으로 계속 서 있는가?
```

## 3. Crown Protocol spine

### 3.1 세 층위

| layer | canonical | 존재 방식 | 서사 기능 | 단독으로 해결할 수 없는 것 |
|---|---|---|---|---|
| literal object | `Crown of Continuance` (다섯 조각) | `R4 Crownwell Archive` 위, `R7 Crown Position`에서 그림자로 확인되는 physical anchor | physical anchor, vertical route, refusal의 evidence | who is a valid person |
| political institution | `Crown Protocol` seat | operator를 교체하고 precedence를 고정하는 institution. `H0 Crown Well`, `R4 Crown Observatory`/`R4-07 Operator Trial`, `R7-07 Operator Replacement`이 그 surface | authority, access, operator choice, `G8` | whether the record is true |
| metaphysical invariant | operator 교체에도 남는 protocol/debt | `E1 The First Return` 층위부터 이어진 meta-protocol | recovery/recognition/authority의 순환을 강제 | what the player should value |

왕관은 conscious king가 아니다. 각 institution은 Crown의 한 층위만 이해한다고 믿는다. 그 오해가 political absurdity의 원천이다.

### 3.1.1 Concentration Layer의 위치

`E4 The Concentration Layer`는 위 세 층위 위에 쌓인 **implementation era**이지 네 번째 층위가 아니다.

- magic은 `Crown Protocol`보다 낮은 precedence다. `R8`이 `crown_precedence`를 올리지 않으며, magic 이론이 operator 주장을 하려면 `G8`의 기존 channel(`R4` glossary, `R7` contract 문서)을 타야 한다(`02` §2.2, §3.4).
- magic은 새 axis도 새 clock도 새 recovery type도 아니다. `concentration`, `body load`, `circulation`, `contract debt`는 기존 4축과 6 clock의 **입력값**이다(`02` §3.4, §4.4).
- magic 실패는 즉시 죽음이 아니다. `status`/`clock`/`record` effect를 한 transaction으로 쓰고(`02` §4.4), `12` §8의 `recoverable`/`continuity-changing`/`terminal` 3등급은 recovery 7종과 별개 분류다.
- 따라서 이 문서에서 magic은 **새 protagonist power**가 아니라 **새 labour/status/resource/recognition 사건**으로만 등장한다(`12` §9).

### 3.2 Meta-protocol operation

Crown Protocol은 다음 세 operation으로 authored state를 만든다. UI나 dialogue가 이 operation을 계산하지 않는다.

```text
RECOVER(subject, continuity_candidate, cost_target)
→ continuity receipt / bypass recovery / unresolved debt

RECOGNIZE(subject, category, address, public_or_private)
→ local name, legal category, access, recognition drift

AUTHORIZE(actor, action, successor_or_scope)
→ permit, refusal, inherited Crown cost
```

각 operation은 `immediate effect`, `delayed consequence`, `pressure clock change`, `surface change`를 동시에 기록한다. 한 operation이 실패하면 partial state를 남길 수 있지만 transaction 전체를 원자적으로 되돌릴 수 있는 것은 아니다. recovery 자체가 "원래 실패를 복구하지 않는 bypass"이므로 rollback보다 debt와 후속 확인이 중요하다.

### 3.3 Institution의 local competence와 category error

| institution (canonical) | local competence | local protocol | category error |
|---|---|---|---|
| `Return Registry` (R1) + `Exchange Registrar` (H0) | 귀환, clone, loop, receipt, return safety, arrival category | body continuity를 receipt/class stamp로 먼저 증명한다 | receipt가 같은 사람이었다고 social continuity까지 증명한다고 착각한다 |
| `Translation Tribunal` / `Record Office` (R4) | anomaly의 이름, 번역, 주소, vocabulary, `glossary` | recognition을 번역본으로 고정한다 | partial translation이 새로운 local law가 되어 원래 대상을 지운다 |
| `Gristmarket Clinic` / `Organ Exchange` (R6), `Faith Engineering unit` (R3), `Glasswing Ordinal` (R5) | body calibration, organ authority, care, latency, boot | body를 실행 가능한 interface로 수리한다 | consent와 identity를 component/state로 압축한다 |
| `Crownwell Archive` — `Record Office`/`Censor`/`Crown Observatory` (R4) + `Boundary Survey` (R7) | archive, succession, permission, public record, boundary topology | 접근 가능한 actor에게 authority를 부여한다 | archive에 들어갈 수 있다는 사실과 정당한 해석 능력을 동일시한다 |
| `CIRCULATION_BOARD` (R2 `concentration_field`/`disperser`/`circulator`) | 농도 측정, dispersal 배정, 누출 이동 | 위험을 자기 node가 아닌 다른 node의 값으로 환산한다 | "해결"을 기록하지 않고 비용만 이웃에 적립한다 |
| `MAG_ACADEMY` curriculum office (R8) | course, 시험, `craft credit`, `student status`, lineage 배정 | capability이 아니라 인증된 시간이 재산을 정의한다 | 미등록 craft를 `unrecorded`가 아니라 `unassigned stock`으로 센다 |
| `LINEAGE_HOUSE` registrar (R8) | 미정형 craft 보존, `lineage_token` 발급 | 가문 접근권을 social continuity로 기록한다 | 접근권을 institutional authority로 오독하게 한다 |
| `VOID_CONTRACT_COURT` (R8) + `R7-09 Void Cut Ledger` | portal shape, contract 조건, `contract_tally` | 대가를 지금 내는 대신 나중에 서게 만든다 | deferred obligation을 combat balance나 taxonomy로 읽는다 |

`Boundary Survey`는 `Crownwell Archive`의 field unit이지 별도 meta-protocol institution이 아니다. `R7-01`/`R7-08` traversal, contamination warning, boundary permit을 소유하며 local competence는 route safety다.

마지막 네 institution은 서로 같은 craft를 서로 다른 category로 센다. 같은 weave가 `MAG_ACADEMY`에서는 `craft credit`, `Glasswing Ordinal`에서는 `labor hour`, `Crownwell Archive`에서는 아직 `untranslated term`, `LINEAGE_HOUSE`에서는 `lineage token`이다. 그 다섯 번째 충돌 record가 `RC-08`의 사건이고, `02` §7.9의 네 authority가 서로의 field를 쓰지 않는다는 규칙이 그 충돌을 보존한다.

## 4. Original setting and chronology

### 4.1 현재 사건: alignment audit와 `G8`

alignment audit는 새 operator를 정하는 season이 아니라, recovery·recognition·authority protocol이 서로 다른 continuity를 어느 operator에게 넘길지 검사하는 **재인정 절차**다. `E3 The Undersign`에서 `H0`의 provisional docket, `R2`의 resource collapse, `R5`의 transformation contract, `R7`의 phase shift가 서로 충돌하고, 그 위에 `E4`의 `R2` 농도 인프라, `R5` craft, `R7` void-cut, `R8` curriculum이 같은 crisis를 다른 category로 다시 서술한다. 최종 선택은 `G8 Crown Precedence`에서 protocol **precedence**를 고르는 것이며, `02` §12에 따라 world ending 자체가 아니다.

- 현재 seat holder는 `npc_12_ravenna_holt`(`Crown Protocol` envoy)이지만 왕관 자체는 아니다. title은 오래 남고 사람은 교체된다.
- R1 `Wrong Return`은 `E1 The First Return` 층위의 recovery 실패가 아직 Filing되지 않은 lineage다. `R1-05 Three Bodies One Name`이 그 name registry 충돌을 surface로 만든다.
- `role_field_investigator`는 그 lineage의 여러 recovery attempt가 한 몸에 겹쳐 만들어진 live audit exception이다.
- The Undersign Basin은 governance, survival ecology, record가 같은 crisis를 서로 다른 category로 처리하는 하나의 vertical basin이다.
- `E4`가 가장 늦게 쌓였기 때문에, 이 audit가 검사하는 것은 protocol 3종에 더해 **craft가 labour로 기록되는 방식**이다. `R8`의 `course index`는 `G8`의 입력이 아니지만, `R8`이 남긴 `craft credit`/`lineage`/`contract` record는 그 audit가 다시 읽는 대상이다(`02` §3.4).

### 4.2 Node와 authored place

| node | authored place (surface) | story port | revisit rule |
|---|---|---|---|
| `H0` The Undersign Exchange | `Arrival Well`, `Counterweight Map`, `Return Hearing`, `Ration Counter`, `Crown Well` | arrival category, appeal, route debt, precedence | canonical translation·operator·Crown phase별로 counterweight 문장이 다시 인쇄된다 |
| `R1` The Returning Kiln | `Intake Stack`, `Wrong Return`, `Ash Garden`, `Cold Relay`, `Deep Door` | `RECOVER`와 social continuity | R1-01을 rescue하면 warm exit가 열리고 NPC가 player를 operator가 아니라 witness로 부른다 |
| `R2` Siltglass Commons | `Glasswater`, stilt settlements, `Seed Vault`, shallow ferry, flood channel, root bridge | aggregate consumption과 resource conflict, `concentration_field`/`disperser`/`circulator` 인프라 | ration/medicine/climate/audio와 census roster가 함께 재작성되고, dispersal 배정에 따라 순환 여유와 이웃 오염이 바뀐다 |
| `R3` Bellhouse Hospice | `Intake Gallery`, `Bell Tower`, `Mercy Engine`, recovery ward | care latency와 consent, `mana_profile` triage | fast/stable recovery, consent form, school record가 archive filing에 따라 재생성된다 |
| `R4` Crownwell Archive | `Public Record Hall`, `Translation Well`, `Weight Lift`, `Low-Level Stacks`, `Crown Observatory` | `RECOGNIZE`와 local law, 비어 있는 `glossary` slot | canonical/contradictory copy가 동시에 살아 있고 archive fire는 reconstruction queue를 만든다 |
| `R5` Glasswing Ordinal | `Foundry Lane`, `Boot Hall`, `Repair Bench`, `Support Clinic`, `Labor Yard`, `Supply Gantry`, `Gantry Cradle` | transformation과 labor status, 세 craft family의 실행 | full/staged/refused boot이 name hearing, care shift, gantry 비용을 함께 바꾸고, `G5 refused`는 `E18`을 닫는다 |
| `R6` Gristmarket Ward | `Gristmarket Ring`, `Organ Intake`, `Cure Queue`, `Debt Hall`, `Replacement Stalls`, `Drainage Dark` | organ authority와 cure debt, organ magic과 medium residue | organ quorum 이후 `R1` recovery chamber가 clinic annex로 바뀐다 |
| `R7` The Hollow Orchard | `Outer Wall`, `Root Orchard`, `Shelter Ring`, `Crown Position`, `Storm Verge` | boundary와 `AUTHORIZE`, void-cut과 contract | `G8` 이후 모든 revisit가 old phase archive로 읽히며 지워지지 않는다 |
| `R8` The Folding School | `Course Court`, `Medium Store`, `Lineage Hall`, `Circulation Board`, `Weave Yard`, `Cut Chamber`, `Index Desk` | craft를 labour/status로 기록하는 방식, curriculum과 `craft credit` | 등록된 magic term이 `R4` glossary와 충돌하고, `G5` 결과와 `R7` 미완성 절단이 같은 maker의 흔적으로 수렴한다 |

`R8`은 `E18`(R5–R8) 단 하나의 entry edge를 갖고 gate는 `G5` 하나다. `G9`를 만들지 않는다(`02` §5.2, §6.1). `R8`의 두 return affordance는 `E18` 왕복과 `Cut Chamber`의 `course index return`(region 내부 route state)이다.

### 4.3 Era spine (authored record가 사용하는 층)

`02` §2.2가 소유한다. 이 파일은 story reading 순서만 고정한다.

- `E1 The First Return`: 왕관을 하나의 object로 취급하던 층위. R1 최초 door와 R7 oldest wall phase. 현재는 low-level evidence로만 접근한다.
- `E2 Administrative Recovery`: Return Registry, hospice, archive, organ exchange가 recovery를 기록·분류하기 시작한 층위. 현재 authority의 기본 language를 제공하지만 항상 정확하지 않다.
- `E3 The Undersign`: 여러 protocol이 동시에 실행되고 `Crown Protocol` seat가 비어 있는 현재 era.
- `E4 The Concentration Layer`: 위 세 era 위에 쌓인 magic implementation era. 별도 우주가 아니다. `R2`의 `disperser`/`circulator`, `R3`의 `mana_profile` triage, `R4`의 `glossary` slot, `R5`의 weave/fold/void-cut, `R6`의 organ magic, `R7`의 void-cut consequence, `R8`의 curriculum이 이 층의 물리적 표면이다.

era 전환은 별도 chapter clear가 아니다. 이전 era의 NPC는 삭제하지 않고 role/access만 바뀐 채 재등장한다. `E4`가 이 규칙을 특히 잘 보여 준다: 학교가 possession을 등록하지 않은 craft는 illegal이 아니라 `unrecorded`이고, `Crown Protocol`은 `E4`를 별도 precedence로 취급하지 않는다. 이전 era의 NPC도 `E4`에서 사라지지 않는다. 예컨대 `R3`의 triage 대상, `R5`의 boot recipient, `R2`의 water delegate가 그대로 `E4`의 `mana_profile`·`craft credit`·`concentration sample` 기록의 주어가 된다.


## 5. Player와 identity contract

플레이어는 `02` §2.3의 네 capability로 시작한다: 선언/보류, evidence·document·resource의 실제 운반, recovery·translation·transformation·boundary 결과의 관찰, world가 그 행동을 어떤 protocol로 기록했는지 확인. quest giver가 아니다.

```text
role_field_investigator            (player role ID — NPC ID 아님)
- body_anchor              physical continuity
- memory_anchor            recovered memory, 원래 chronology 보장 없음
- role_anchor              임시 audit subject
- recognition_anchor       public record가 현재 부를 수 있는 것
- consent_record           body / memory / role / recognition 층위별 consent
- axis_writes              protocol_legitimacy, recognition_drift, continuity_pressure, resource_scarcity
```

네 anchor는 magic power tree가 아니다. 각각 `StoryState` flag이며 consent owner, resource 비용, 대응하는 domain surface, delayed social effect를 가진다.

| anchor | 무엇을 되돌릴 수 있는가 | 비용 | 무엇을 되돌리지 못하는가 |
|---|---|---|---|
| `PLAYER_LAYER_BODY` | contamination과 organ priority를 한 cycle 우회한다 | `continuity_pressure` write + field hazard | 원래 failure와 memory 손상 |
| `PLAYER_LAYER_MEMORY` | 이미 Filing된 사건의 low-level detail을 addressable하게 만든다 | raw sensory fact 1개 소모 | 그 detail을 잃은 사람과의 관계 |
| `PLAYER_LAYER_ROLE` | 하나의 permission/contract를 player가 아닌 role로 통과시킨다 | `protocol_legitimacy` write + institution 기록 | 그 role이 누군가를 대신한다는 사실 |
| `PLAYER_LAYER_RECOGNITION` | 한 gate의 category를 일시적으로 무효화한다 | `recognition_drift` write + public record 반응 | social recognition이 이전과 같아지지 않음 |

어떤 anchor도 route에 필수 아니다. relationship, evidence, noncombat resolution, authored sacrifice만으로 story를 끝낼 수 있다. `01`이 combat command로 무엇을 여는지 소유하고, 이 파일은 그 state 변화만 고정한다.

`player_knowledge`는 world state와 별개다. 규칙을 이미 알면 다시 발견하도록 강제하지 않고, NPC·institution은 그 지식을 공유하지 않는다. save/load는 world state를 복원하지 player의 memory나 insight를 복원하지 않는다.

### 5.1 player의 cast state — magic power tree가 아니다

`role_field_investigator`는 craft를 소유하지 않는다. `E4`에서 player가 가지는 것은 **실행한 craft의 기록과 그 결과가 남긴 부담**뿐이다. 상태 표현의 정본은 `02` §9.1의 `magic` 하위 record 6종이며, `06` §10.2의 save projection allowlist를 따른다.

| story가 읽는 것 | 정본 record (`02` §9.1) | 이 파일이 고정한 서사적 의미 |
|---|---|---|
| 한 지점의 농도 측정값과 그 출처 | `magic.concentration_fields` | 값 하나만 적으면 `R8`이 거절한다. `provenance`이 `R2-09`인지 `R8-02`인지가 곧 `R4` glossary와 `R2` `E` clock의 분기다. |
| actor별 축적·배출·상처·`mana_profile` | `magic.body_load` | 체질은 성격이 아니라 body compatibility/failure class다(`12` §2.2). moral judgement로 쓰지 않는다. |
| 노드별 분산기와 순환 여유, 누적 오염 | `magic.circulation` | 농도를 낮추는 결정은 언제나 이웃 region의 `K`/`E`에 값을 적립한다. |
| 준비된 weave/scroll, 남은 fold count, `shape_or_pattern`, `tool_variant`, residue | `magic.crafts` | 준비(pre-cast)와 즉흥(field improvisation)은 같은 schema의 다른 authored action이고 비용이 다르다(`12` §7). |
| 체결한 portal contract의 shape·대가·조건·`contract_tally` | `magic.contracts` | contract는 자동 해소되지 않는다. `contract_tally`은 obligation ledger이며 combat balance가 아니다. |
| `R4`가 소유하는 양식 있는 이론 이름 slot | `magic.glossary` | 비어 있으면 craft 이름은 `untranslated term`으로 Filing된다. 이론 이름을 이 문서나 core script이 정하지 않는다. |

- 이 여섯 record는 `res_*` field resource(`concentration_sample`, `medium_blank`, `fold_sheet`, `blade_credit`, `disperser_charge`, `circulation_slot`, `craft_credit`, `lineage_token`, `contract_tally`, `labor_pledge`)와 분리된다. 물질은 `world.resources`에, 계약 조건은 `magic.crafts`에 있다. 한 값을 두 namespace에 복제하지 않는다(`02` §9.1).
- `mana`라는 이름의 단일 수치 resource, 전역 `concentration` 막대, combat resource(`hp`/`mp`/`equipment_charge`)에 붙는 magic pool을 만들지 않는다.
- "이 magic를 쓸 줄 안다"는 innate title이 아니라 **실전 숙련의 occupational speech**다(`IDEA_LEDGER` `S145`). story는 이 구분을 dialogue로만 유지하지 않고 `craft credit`/`labor hour`/`course status` record로 증명한다.
- magic failure는 NPC를 romance/affection route에서 배제하는 자동 규칙이 아니다. consent, recovery, shared choice를 authored data로 다룬다(`12` §9).

## 6. Story axes

이 파일은 **축의 값 순서를 소유하지 않는다.** named axis token과 integer mapping의 owner는 `02` §3이고, 저장 형태(int `-3..3`)의 owner는 `06` §6.1이다.

| axis key | 값 순서 (owner `02` §3) | 이 파일이 고정하는 것 |
|---|---|---|
| `protocol_legitimacy` | `unlicensed → provisional → sanctioned → contested → successor` | 어느 choice·document·NPC refusal이 A를 올리고 내리는지 |
| `recognition_drift` | `person → patient → operator → artifact → organ-authority → unclassified` | 어느 NPC가 player를 무엇으로 부르고 어느 enemy label이 바뀌는지 |
| `continuity_pressure` | `single → linked → branched → loop-bound → crown-debt` | body anchor·recovery·clone이 어떤 obligation을 남기는지 |
| `resource_scarcity` | `buffered → rationed → localized → failing → collapsed → externally-mediated` | 어떤 배분이 route 비용·companion support·ecology를 바꾸는지 |

- 이 파일에 **별도 3-value ladder를 두지 않는다.** `02` §3 token 순서와 `06` §6.1 int 저장이 유일한 해석이며, "문서 간 충돌용 별도 3-value ladder가 존재·참조되지 않음"이라는 acceptance 조건은 §21.1의 `10` 요청 항목에 명시되어 있다.
- 이 파일에 **magic 전용 축을 두지 않는다.** `AXIS_CONCENTRATION`·`AXIS_CRAFT_MASTERY` 같은 5번째 축은 만들지 않는다(`02` §3.4).
- 한 event가 두 축 이상에 닿으면 각 write와 immediate/delayed consequence를 **분리해** 기록한다(`02` §3.1).
- 축은 합산·복사·정규화하지 않는다. combat HP, damage number, ending score, single progress bar로 바꾸지 않는다.
- axis는 상시 HUD가 아니다. world sign, NPC address, document stamp, encounter label, route gate로만 읽힌다.

### 6.1 magic 사건이 4축에 쓰는 것

`02` §3.4가 정본 표다. 이 파일은 그 write를 어떤 story beat에서 읽는지만 고정한다. 한 magic 사건이 두 축을 건드리면 각 write를 별도 transaction step으로 기록한다(`02` §9.2).

| magic 사건 | 이 파일이 고정한 story reading |
|---|---|
| weave/scroll cast 성공 | `D`의 `medium` 재고만 줄고 category는 흔들리지 않는다. 성공이 recognition을 바꾸지 않는다는 것이 `T6`의 첫 evidence다. |
| rigid-fold cast 성공 | `D`의 `fold` 재료·시간이 줄고 더 어려운 shape가 열린다. 성공이 `A`를 올리지 않는다. |
| lineage magic 첫 발현 | `A`는 `provisional` 유지 또는 `contested`, `B`는 `operator`가 아닌 `apprentice` category로 Filing된다. `C`는 `linked`에 머문다. |
| concentration overflow | `A contested`, `B` 유지 또는 도구 `artifact`, `C branched`, `D failing`이 **각각 별도 write**로 남는다. |
| unregistered craft 압수 | `A unlicensed`, `B artifact`. 압수 자체가 곧 강등은 아니다(`02` §4.4). |
| portal contract 체결 | `A contested`(존재에게 권한 발생), `B operator`, `C linked`(deferred obligation), `D failing`(circulation 여유 소모). `C`는 contract 하나로 전진하지 않는다. |
| magic cure | `B patient` 유지, `C branched` 증가, `medicine` 재고 감소. 원상복구로 기록되지 않는다. |
| failed fold (`R8-05`/`RC-08`) | `A provisional` 유지, `B`는 수단 실패면 `artifact`·숙련 실패면 `person`, `C branched` 증가, `medium`+`course credit` 소실. |

## 7. Pressure clocks

시계는 여섯 개이며 서로 다른 단위로 진행한다. 전역 위험 막대, 상시 숫자 HUD, clock 이름 표시를 만들지 않는다. signal은 world event, enemy tell, NPC warning, document shortage, route change로만 드러난다. stage vocabulary와 integer mapping은 `02` §4가 소유한다.

| clock | 시작 단계 | visible signal | escalation | intervention | irreversible point | story surface |
|---|---|---|---|---|---|---|
| `CL-INST` (`I`) | `noticed` | 같은 사건에 두 office stamp | category가 좁혀지고 담당자 배정 | 해당 기관의 local protocol 실행 | 공식 dispatch 또는 operator replacement 기록 | route permission, NPC role, H0 route card |
| `CL-CONT` (`K`) | `clean` | 접촉·이동·실패 recovery의 흔적 | recovery/recognition failure 누적 | 격리, 우회, 검사, 치료 | contamination이 현재 복구 경로를 재정의 | body authority와 route safety 재계산 |
| `CL-REC` (`R`) | `private` | 같은 사건의 서로 다른 문서 전파 | rumor·form·screenshot가 category 확정 | archive·court·crier가 public copy 생성 | contradictory record가 canonical이 됨 | society의 대상 분류, NPC 호칭 |
| `CL-RES` (`E`) | `buffered` | stock, waterline, battery, care window 감소 | ration·substitution·debt 일상화 | region이 seed·parts·attention·medicine 재분배 | 한 cycle buffer 0 또는 external supply 차단 | route 차단과 external mediation 개방 |
| `CL-PER` (`P`) | `role_bound` | NPC가 자기 role을 먼저 말함 | memory·desire·organ voice가 다른 결정 | care·bargain·separation·public role change | NPC가 새 self-authored role 기록 또는 role 상실 | dialogue access, combat target, care outcome |
| `CL-CROWN` (`C`) | `vacant` | Crownwell의 그림자·operator stamp 불일치 | institution이 자기 protocol을 crown에 우선순위 제시 | operator 교체 또는 precedence 공개 | `Crown Protocol`이 precedence와 operator 고정 | physical route와 canonical record의 world-wide 재해석 |

`crown_alignment`는 recovery type이 아니다. `G8`은 world write이며, recovery enum 7종 밖에 있고 같은 intent는 operator/precedence/route 재해석으로만 commit된다(acceptance 조건은 §21.1). 이전 phase는 revisit archive로만 읽힌다.

### 7.1 magic이 clock에 쓰는 것

`02` §4.4가 정본 표다. magic은 일곱째 clock을 만들지 않는다. 이 파일은 각 write가 어떤 story surface로 읽히는지 고정한다.

| trigger | 이 파일이 고정하는 story reading |
|---|---|
| `concentration_field`가 threshold를 넘음 | 해당 region/path의 `K`가 한 단계 전진한다. `E`는 별도 transaction에서만 전진하므로 "농도Resolved"와 "자원 버팀"이 같은 장면에서 동시에 말해지지 않는다. |
| circulator가 축적 농도를 외부 공기로 이동 | `K`는 줄고 `E`는 소모된다. 감소는 "해결"로 기록되지 않으며, `R2-10 Circulator Ledger`가 그 사실을 적어 둔다. |
| 실패한 cast | `K`(medium residue) 또는 `P`(body load) 중 **하나**를 고른다. `R`은 failure document가 Filing될 때만 움직인다. |
| magic cure | `P`가 움직이고 `C`는 별도 write다. cure가 원상복구로 기록되지 않는다. |
| portal contract 체결 | `C`의 interpretation input으로만 사용된다. `E`(circulation 소모)와 `R`(contract 공개)는 각각 다른 transaction이다. |
| unregistered craft 압수 | `I`가 움직인다. `R`은 별도다. 압수가 곧 `A` 강등으로 기록되지 않는다. |
| `R8` course index Filing | `I`와 `R`만 움직이고 `E`는 학생 인원으로만 반응한다. |
| `R8` failed fold | `P`(학생 role)와 `R`(학교 record)이 움직인다. 학생은 제거되지 않는다. |

- `K`·`P`·`R` 동시 전진 금지, `C`가 contract 하나로 전진 금지라는 규칙은 §19에서 금지 shortcut으로 다시 선언한다.
- 농도는 region/path 단위 `concentration_field`이며 HUD·clock 이름·숫자 바로 노출하지 않는다.
- `R8`의 초기 clock manifest는 `I assigned`, `K clean`, `R private`, `E localized`, `P divergent`, `C contested`이고, `R7`과 함께 `E`/`R`이 stage 4에서 시작하는 region이 아니다(`02` §4.2). 어느 region도 terminal stage에서 시작하지 않는다.

## 8. Layered truths

truth는 additive하고 서로 모순된다. 모든 document를 읽어도 단일 정답 해석이 자동으로 생기지 않는다.

| truth ID | public layer | later proof | required sources (canonical) | player action | consequence |
|---|---|---|---|---|---|
| `TRUTH_T0_CONTINUANCE_PROMISE` | Crown Protocol이 미등록 recovery를 막고 continuity를 지킨다 | log는 비용이 사라진 게 아니라 옮겨졌음을 보여 준다 | `R1-06 Registry Interrogation`, `R4-07 Operator Trial`, `RC-01` `carry claimant` | 약속을 수락하거나 질문한다 | `protocol_legitimacy`와 첫 route permission |
| `TRUTH_T1_PROTOCOL_SPLIT` | 하나의 Crown이 모든 recovery를 지배한다 | recovery·recognition·authority가 서로 다른 receipt/word/body log/permission을 낸다 | `R1-01` ↔ `R4-01` ↔ `R6-06` ↔ `R5-01` 비교, `RC-01`/`RC-04`/`RC-06` | 사람이 아니라 protocol 간 불일치를 route로 삼는다 | cross-route gate 개방, institution 반응 |
| `TRUTH_T2_COST_EXPORT` | recovery는 몸을 살린다 | 각 bypass가 debt를 body·ecology·memory·record·social recognition 중 한 곳에 수출한다 | `R6-04 Debt Surgery`, `R2-08 Settlement Vote`, `R1-04 Continuation Trial`, `R7-03 Clone Burial`, `R8-08 Field Probation` | 보이는 비용과 그 소유자를 고른다 | lens별 partial success |
| `TRUTH_T3_CROWN_CONTINUANCE` | 왕관은 하나의 sovereign object다 | object, `Crown Protocol` seat, invariant가 서로 다른 층위다 | `R4-06 Crown Fragment`, `R7-04 Crown Position`, `npc_01_ilyra_senn`, `npc_12_ravenna_holt`, `npc_11_cael_ren` | 어느 층위를 따를지 고른다 | `G8`과 authority/hybrid ending eligibility |
| `TRUTH_T4_BRIDGE_SUBJECT` | player는 filing되지 않은 survivor다 | organ log와 여러 recovery trace가 한 body에서 수렴한다 | `R1-01 Misreturned Person`, `R3-08 Memory Copy Consent`, `R6-03 Heart Petition`, `npc_13_tovan_reed`/`npc_06_tamas_quill`/`npc_05_nera_voss` 증언 | bridge identity를 받거나 나누거나 거부한다 | body arc와 최종 companion support |
| `TRUTH_T5_NO_SINGLE_WILL` | Crown이 최종 지시를 하나 준다 | 네 protocol이 같은 사건에 서로 양립 불가능한 응답을 낸다 | `R4-02 Contradictory Record`, `H0-05 Crier Thread`, `RC-04` `publish contradiction`, `R7-07` operator claim 경쟁 | 단일 해석을 거부한다 | convergence 또는 last-witness ending |
| `TRUTH_T6_CRAFT_IS_LABOR` | magic은 능력이고 배운 사람이 대가가 없다 | craft는 medium·tool·시간·농도·body load를 소비하고, 그 소비는 `labor hour`·`craft credit`·`lineage token`·`contract tally` 중 하나로만 Filing된다 | `R8-01 Course Index`, `R8-03 Lineage Placement`, `R8-08 Field Probation`, `R5-13 Supply Rack`, `R5-07 Labor Walkout`, `R2-09 Disperser Reading` | 자신의 craft를 어느 노동 record에 적을지 고른다(임장 / course credit / lineage / refusal) | `A`·`D`·`P` write, `R5` labor 재분류, `R8` region state, `ROUTE_CRAFT`/`ROUTE_BODY` ending eligibility |
| `TRUTH_T7_CUT_IS_A_DEBT` | portal은 도구이며 닫으면 끝난다 | 절단 shape는 destination과 위험을 동시에 정하고, 고위 portal은 구체적 spell 대신 deferred obligation을 남기며 어떤 contract도 자동 해소되지 않는다 | `R7-09 Void Cut Ledger`, `R8-06 Void Contract Filing`, `R7-05 Storm Verge`, `R5-12 Void Cut`, `R4-02 Contradictory Record` | contract를 체결/거부/기록만 남기고, 어느 해석 안에 둘지 `G8`에서 명시한다 | `contract_tally` 부채, `C` interpretation input, `R4` canonical law 재작성, ending incomplete 항목 |

`truth_state`는 `unknown → partial → corroborated → actionable`이다. `partial`이어도 쓸 수 있다. secret flag 하나는 어떤 ending도 열지 않는다. ending evaluator는 route decision, relationship/body decision, world consequence, 구체적 resolution을 함께 요구한다.

`T6`와 `T7`는 core truth를 대체하지 않는다. 둘 다 `T2`(비용 수출)와 `T5`(단일 의지 없음)의 magic 버전이며, 새 axis·새 clock·새 recovery type을 요구하지 않는다. `T6` 없이 `T2`가, `T7` 없이 `T5`가 성립할 수 있지만 둘 다 성립하면 `END_C1_FOUR_ANCHORS`의 admissibility가 올라간다.

### 8.1 Truth acquisition order

1. `R1-06` 또는 `R1-01`이 `TRUTH_T0_CONTINUANCE_PROMISE`를 `partial`로 만든다.
2. `R1-01`과 `R4-01` 또는 `R6-06`의 비교가 `TRUTH_T1_PROTOCOL_SPLIT`을 `corroborated`로 만든다.
3. `R6-04` 또는 `R2-08`가 `TRUTH_T2_COST_EXPORT`를 `corroborated`로 만든다. `R8-08`도 같은 truth를 corroborate할 수 있다.
4. `R4-06`+`R7-04`를 `npc_01_ilyra_senn`의 hidden access refusal과 함께 읽으면 `TRUTH_T3_CROWN_CONTINUANCE`가 `actionable`이 된다.
5. `R3-08`과 `R6-03`에 `npc_13_tovan_reed`/`npc_06_tamas_quill`/`npc_05_nera_voss` 증언이 더해지면 `TRUTH_T4_BRIDGE_SUBJECT`가 `actionable`이 된다.
6. `R4-02`의 contradictory copy와 `R7-07`의 operator claim 경쟁이 `TRUTH_T5_NO_SINGLE_WILL`을 `actionable`로 만든다.
7. `R2-09`/`R2-10`의 measurement와 dispersal 배정, 또는 `R5-13`의 labour hour 전환이 `TRUTH_T6_CRAFT_IS_LABOR`를 `corroborated`로 만든다. `R8-01`/`R8-03`/`R8-08` 중 하나가 그 위에 `lineage` 또는 `refusal`을 더하면 `actionable`이 된다.
8. `R7-09` 또는 `R8-06`이 체결된 contract를 남기고, 그 shape·대가·조건이 `R4`의 두 문장 중 하나와 충돌하면 `TRUTH_T7_CUT_IS_A_DEBT`가 `actionable`이 된다. `R7-05`의 미완성 절단이 `R8` `Cut Chamber` 잔해와 같은 maker의 것임을 확인하는 것이 두 번째 source다.

player는 이 순서를 바꿔 진행할 수 있다. 단일 고립 document, secret flag, dialogue confession은 어떤 truth도 `actionable`로 만들지 못한다. `R8`을 방문하지 않아도 `T6`는 `R5`/`R2` 표면만으로 `corroborated`가 되고, `R8`을 방문하지 않아도 `T7`는 `R7-09`만으로 성립한다. `R8`은 두 truth의 유일한 source가 아니다.

## 9. Protocol-precedence lens

lens는 moral alignment label이 아니라 **어느 protocol을 먼저 실행하느냐**의 institutional view다. 정본 route graph(`E01`~`E18`), gate(`G0`~`G8`), resource key는 `02`가 소유하고, Reference Game의 실제 run 이름·시간은 `07`이 소유한다. 이 절은 lens가 어느 edge/gate/cluster를 통과하는지만 고정한다.

| lens ID | 07 run 이름 | 정문 | 통과하는 cluster | 최종 write | lens ending |
|---|---|---|---|---|---|
| `ROUTE_RETURN` — The Second Receipt | 10.1 Direct — The Receipt Route (`H0→R1→R6→R7→R4`) | `G1 Ash Debt` + `E06`/`E07` | `RC-01` → `RC-06` → `RC-07` | `R7-07` `Operator Replacement` | `END_R1_RECEIPT_OF_A_LIFE` |
| `ROUTE_RECOGNITION` — The Untranslatable | 10.3 Resource — The Living Commons Route의 category 축 (`H0→R2→R6→R5→R7→R4`) | `G4 Translation Precedence` + `E04`/`E13` | `RC-02` → `RC-06` → `RC-04` | `R4-02` canonical translation | `END_G1_LAW_WITHOUT_MASTER` |
| `ROUTE_BODY` — The Many-Mouthed | 10.2 Body — The Split Form Route (`H0→R3→R5→R6→R7→R4`) | `G3 Latency Receipt` + `G5 Labor Pledge` + `E11`/`E14` | `RC-03` → `RC-05` → `RC-06` | `R6-06` Body Authority Registry | `END_O1_MANY_MOUTHS_ONE_PERSON` |
| `ROUTE_CRAFT` — The Folded Wage | 10.4 Craft route — The Folded Wage Route (`H0→R2→R8→R5→R4→R3`, A1 이후) | `G5 Labor Pledge` resolution + `E18` + `E10`/`E12` | `RC-02` → `RC-08` → `RC-04` 또는 `RC-05` → `RC-03` | `R8-01`/`R8-03`/`R8-08` region state + `R5-13` labour hour 재분류 | `END_O1_MANY_MOUTHS_ONE_PERSON` (fallback `END_C2_LAST_WITNESS`) |
| `ROUTE_AUTHORITY` — The Empty Seat | 10.5 Full survey — Convergence Route의 precedence 축 (`H0→R1→H0→R3→R5→H0→R2→R6→R7→R4`) | `G8 Crown Precedence` + `E04`/`E13` | `RC-04` → `RC-07` → `RC-03` | `G8` `crown_precedence` + `operator_id` | `END_A1_EMPTY_SEAT` |
| `ROUTE_CONVERGENCE` | 10.5 Full survey | `G0`~`G8` 전부 | `HC-00` + `RC-01` + `RC-04` 필수 + `RC-02`/`RC-03`/`RC-05`/`RC-06`/`RC-08` 중 3개 이상 | `G8` 분배 | `END_C1_FOUR_ANCHORS` |

- lens는 fixed quest 순서가 아니다. 한 run은 두 lens를 실행할 수 있고, 한 lens만으로도 ending에 도달할 수 있다.
- `07`은 5개 run(10.1 direct / 10.2 body / 10.3 resource / 10.4 craft / 10.5 full survey)을 정의하고 이 절은 6개 lens를 정의한다. `ROUTE_RETURN`·`ROUTE_BODY`·`ROUTE_CRAFT`는 전용 run(10.1, 10.2, 10.4)을 갖고, `ROUTE_RECOGNITION`·`ROUTE_AUTHORITY`는 전용 run이 없으므로 10.3/10.5 안에서 해당 축을 실행해 검증한다. 전용 run이 없다는 것은 검증 생략이 아니다.
- `ROUTE_CRAFT`는 `02` §5.1의 craft loop(`R3—E11—R5—E18—R8—E18—R5—E12—R4—E10—R3`)과 §6.2 loop 7·8을 그대로 읽는다. `E18`이 양방향 out-and-back leg이므로 별도 loop를 만들지 않는다. `ROUTE_CRAFT`는 새 ending을 열지 않고 `END_O1`의 labor/body 축으로 합류한다. 이 lens가 `G5 refused`로 Filing되면 `E18`이 닫히고, 우회는 `R5` 내부 industrial permit craft가 담당한다(`02` §7.6 revisit, §6.2).
- `ROUTE_CONVERGENCE`는 여섯 번째 major route가 아니라 **cross-route resolution pattern**이다. `HC-00` + `RC-01` + `RC-04`이 필수이고 `RC-02`/`RC-03`/`RC-05`/`RC-06`/`RC-08` 중 세 개 이상이 필요하다. `RC-08`을 세는 것은 `R8`이 baseline 10분 run에 포함된다는 뜻이 아니다. `02` §6.3의 9번 항목대로 A1 data-only 조건을 통과한 뒤에야 convergence requirement가 열린다.
- 어떤 lens도 §0.1의 폐기 place를 열지 않는다. 모든 surface는 `H0` + `R1`~`R8` 안이다.


## 10. NPC interaction cluster contract

authored cluster는 **정확히 9개**다: `HC-00`과 `RC-01`~`RC-08`. 각각 **6~12 core NPC**, 2~4 institutions, 2~3 clocks, partial truth, resource conflict, immediate consequence, delayed consequence를 가진다. membership은 `04` §2의 14명 core roster에서만 뽑는다. NPC가 서로 모두 만날 필요는 없고, shared record·remote service·absence·death·body/role change로 영향을 전달한다. cluster 결과는 dialogue 한 줄이 아니다. 최소 한 field/object/NPC/resource/record/route surface와 한 non-dialogue domain surface가 함께 변한다.

`RC-08`은 `07` §14.1의 A1 data-only 조건을 만족해야 한다. baseline 8개 cluster는 `R8` 없이도 완성된다. `RC-08`은 authoring 순서상 뒤에 오지만 계획상으로는 위 9개와 동등한 authored unit이며, implementation이 `RC-08` 때문에 core 파일을 요구하면 그건 A1 실패다.

### 10.1 `HC-00` — The First Docket, `H0` (7 NPC)

- core NPC: `npc_02_orrin_kest`, `npc_10_juno_caster`, `npc_11_cael_ren`, `npc_03_veya_morcant`, `npc_14_eda_marrow`, `npc_08_meral_dune`, `npc_01_ilyra_senn`
- institutions: `Exchange Registrar`, `Crier Office`, `Contract Counter` (3)
- clocks: `CL-INST` `assigned`, `CL-REC` `private→circulating`, `CL-PER` `role_bound` (3)
- partial truths: 빈 `Crown Well`은 왕관이 사라졌다는 뜻이 아니다 / `npc_10_juno_caster`는 마지막 operator가 떠났다고 말하지만 record는 Filing되지 않았다 / `npc_01_ilyra_senn`은 하나의 route만 지워졌다고 안다
- resource conflict: 하나의 `route debt token`을 R2 water, R3 care, R5 parts 중 하나에 배정한다.
- 고정 choice: `withhold category` 후 `sponsor a return`
- immediate → delayed: `H0-01 Arrival Docket` filing, `protocol_legitimacy=provisional`, `recognition_drift` category 확정 → `R3`/`R5` NPC가 player의 declaration에 따라 care sponsor 또는 labor witness로 갈리고, `R4`가 filing을 거부하면 첫 public record가 생긴다.
- support resident: `02` H0 resident(`Orrin Slate`, `Pell Harrow`, `Mara Quill`, `Cato Nen`, `Sable Reed`, `Iven Moss`)는 core 수에 넣지 않고 해당 NPC의 port에 붙는다.
- R8 표면: `SERVICE_R8_COURSE_INDEX`는 이 cluster의 여섯 번째 route card가 아니다. `RC-08`이 Filing된 뒤 revisit에서 한 줄만 추가된다(`02` §7.1).

### 10.2 `RC-01` — Wrong Return, `R1` (7 NPC)

- core NPC: `npc_02_orrin_kest`, `npc_11_cael_ren`, `npc_13_tovan_reed`, `npc_03_veya_morcant`, `npc_05_nera_voss`, `npc_01_ilyra_senn`, `npc_06_tamas_quill`
- institutions: `Return Registry`, `Kiln Wardens`, `Bellhouse` intake office (3)
- clocks: `CL-CONT` `exposed`, `CL-INST` `noticed`, `CL-PER` `divergent` (3)
- partial truths: door는 body를 되돌렸지만 role을 되돌리지 않았다 / 마지막 bell을 들었다는 증언과 `R1-07 Ash Choir` log가 비어 있다 / `npc_11_cael_ren`은 원 employment를 기억하지 못한다
- resource conflict: `ash thread`를 door 안정화에 쓰면 recovery evidence가 소모된다.
- 고정 choice: `carry claimant`
- immediate → delayed: `continuity_pressure` branch, `R1-01` category, `CL-CONT` increment, `E06`/`E07` candidate → `R4`에 pending record, `R6`에 body authority 후보, `H0` return hearing이 두 번 열린다.
- R8 표면: 없다. `RC-01`의 lineage topic은 `R8-03 Lineage Placement`에서 다른 이름으로 다시 읽힌다.

### 10.3 `RC-02` — Same Water, `R2` (7 NPC)

- core NPC: `npc_08_meral_dune`, `npc_14_eda_marrow`, `npc_11_cael_ren`, `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_09_perrin_lask`, `npc_10_juno_caster`
- institutions: `Water Council`, `Seed Vault`, `Settlement Council` (3). `MAG_ACADEMY` curriculum office는 `concentration registration`을 curriculum 인증으로 요구하므로 원격 attendee로 등장한다.
- clocks: `CL-RES` `failing`, `CL-CONT` `active`, `CL-PER` `divergent` (3)
- partial truths: water는 safe하지만 legal name은 새 home을 인정하지 않는다 / 같은 body가 서로 다른 water claim을 한다 / seed count가 census보다 많다
- resource conflict: clean water와 `seed case`를 medicine ferry에 보낼지 settlement에 남길지 선택한다.
- 고정 choice: `share` 후 medicine ferry 또는 settlement에 seed 1단위 배정
- immediate → delayed: `resource_scarcity` buffer, public ration, `E08`/`E17` route state → `R6` medicine price와 `R7` shelter capacity가 바뀐다.
- magic write: `R2-09`/`R2-10`은 이 cluster 뒤에만 Filing할 수 있고 그 Filing 여부가 `E18`의 resource gate를 정한다. circulator를 먼저 돌린 run에서는 `E08` medicine lane이 `failing`에서 시작하고 `R2` `E`가 한 단계 앞선다(`02` §6.2 loop 8).

### 10.4 `RC-03` — Mercy Delay, `R3` (8 NPC)

- core NPC: `npc_04_sable_halm`, `npc_09_perrin_lask`, `npc_03_veya_morcant`, `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_08_meral_dune`, `npc_01_ilyra_senn`, `npc_10_juno_caster`
- institutions: `Hospice Covenant`, `Faith Engineering unit`, `Care Union` (3)
- clocks: `CL-INST` `assigned`, `CL-PER` `divergent`, `CL-REC` `private` (3)
- partial truths: bell은 신앙이 아니라 response latency를 조율한다 / memory copy는 consent가 아니다 / transformed status를 worker record에만 넣길 원한다
- resource conflict: care labor 한 명을 fast recovery와 memory archive 중 하나에 배정한다.
- 고정 choice: `split the window`
- immediate → delayed: intervention stage, role decision, care record, `E10`/`E11` candidate → `R5` boot contract와 `R4` archive outcome이 서로 다른 operator name을 생산하고 두 NPC의 relationship state가 갈라진다.
- magic write: `mana_profile`이 Filing되면 같은 patient에게 `emission failure` category가 붙고 그 category는 `R5-01`의 boot 조건과 `R8-04`의 course 선택 가능 목록을 함께 좁힌다(`02` §7.4).

### 10.5 `RC-04` — Sentence Above the Stair, `R4` (7 NPC)

- core NPC: `npc_06_tamas_quill`, `npc_01_ilyra_senn`, `npc_10_juno_caster`, `npc_03_veya_morcant`, `npc_04_sable_halm`, `npc_11_cael_ren`, `npc_12_ravenna_holt`
- institutions: `Translation Tribunal`, `Record Office`, `Censor Office` (3)
- clocks: `CL-REC` `filing→canonical`, `CL-INST` `assigned`, `CL-CROWN` `contested` (3)
- partial truths: 두 번역은 같은 원문에서 나왔지만 서로 다른 recovery rule을 만든다 / public copy는 이미 외부로 나갔다 / contradiction보다 speed를 우선한다
- resource conflict: `archive weight` 한 묶음을 canonical translation에 쓸지 public evacuation에 쓸지 선택한다.
- 고정 choice: `publish contradiction`
- immediate → delayed: `public_record` canonical flag, `protocol_legitimacy=contested`, `E04`/`E12`/`E13` route category → 선택한 문장이 `R5` labor role과 `R7` wall category를 바꾸고 archive에 남은 이전 operator memory가 새 law에 맞춰 재분류된다.
- magic write: `R4`의 `glossary` slot에 먼저 들어온 쪽이 이름의 canonical이 된다. `R8-03`/`R8-04`가 `RC-08` 이전에 Filing되었다면 학교 이름과 archive 번역이 충돌하고 두 줄 모두 남으며 `R4-02`와 같은 conflict 상태가 된다(`02` §7.5 revisit).

### 10.6 `RC-05` — Uniform, Name, Contract, `R5` (7 NPC)

- core NPC: `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_05_nera_voss`, `npc_09_perrin_lask`, `npc_13_tovan_reed`, `npc_01_ilyra_senn`, `npc_10_juno_caster`
- institutions: `Glasswing Ordinal`, `Labor Court`, `Support Registry` (3)
- clocks: `CL-INST` `assigned`, `CL-CONT` `exposed`, `CL-PER` `divergent` (3)
- partial truths: boot는 성공했지만 보호 능력의 소유자가 불명확하다 / consent가 capability보다 먼저 필요하다 / refusal를 contract breach로 처리하지 않는다
- resource conflict: `power cell` 하나를 boot, repair, gantry battery 중 하나에 배정한다.
- 고정 choice: `staged boot` + `record partner permission`
- immediate → delayed: `recognition_drift=operator`, labor legitimacy, transformation lineage, `E14`/`E15` route gate → `R3` care result와 `R6` organ testimony가 같은 사람을 서로 다르게 부르고 `H0` route debt가 sponsor인지 subject인지에 따라 생성된다.
- magic write: `G5`의 세 결과가 `E18`을 서로 다르게 만든다. `full`/`staged`는 `open`, `refused`는 `closed`(우회: `R5` 내부 industrial permit으로만 craft). `R5-10 Field Weave`·`R5-11 Rigid Fold`·`R5-12 Void Cut`의 실행 가능 여부는 이 결과와 `mana_profile`이 함께 결정한다(`02` §7.6 revisit, §8.6).

### 10.7 `RC-06` — The Heart's Petition, `R6` (7 NPC)

- core NPC: `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_04_sable_halm`, `npc_03_veya_morcant`, `npc_11_cael_ren`, `npc_01_ilyra_senn`, `npc_14_eda_marrow`
- institutions: `Gristmarket Clinic`, `Debt Court`, `Organ Exchange` (3)
- clocks: `CL-PER` `divergent`, `CL-CONT` `active`, `CL-RES` `failing` (3)
- partial truths: organ authority는 patient의 pain과 clinic의 liability를 다른 priority로 본다 / organ signature를 권한으로 받아들이지 않는다 / 정상 part를 failure part보다 싸게 분류한다
- resource conflict: medicine, credit, replacement part 중 하나를 organ testimony의 대가로 쓴다.
- 고정 choice: `split custody`
- immediate → delayed: `recognition_drift=organ-authority`, `continuity_pressure` bypass lineage, cure debt, `E16` candidate → `R1` recovery chamber가 clinic annex로 바뀌고 `R4` public record가 organ을 object로 쓸지 person으로 쓸지 결정해야 한다.
- magic write: magic cure가 Filing되면 `C`가 `branched`로 이동하고 장기 residue는 `R5-03 Repair Bench`의 회수 대상이 된다. residue를 회수하지 않으면 `R5-10 Field Weave`의 cast 오차가 한 단계 올라간다(`02` §8.7).

### 10.8 `RC-07` — Map Made by the Wall, `R7` (8 NPC)

- core NPC: `npc_07_bryn_oskel`, `npc_12_ravenna_holt`, `npc_01_ilyra_senn`, `npc_11_cael_ren`, `npc_08_meral_dune`, `npc_04_sable_halm`, `npc_10_juno_caster`, `npc_06_tamas_quill`
- institutions: `Boundary Survey`, `Settlement Council`, `Crownwell Archive` (3)
- clocks: `CL-CROWN` `contested→aligned`, `CL-CONT` `systemic`, `CL-REC` `canonical` (3)
- partial truths: wall은 crown을 지키는 장치가 아니라 crown의 category를 외부에 보여 주는 장치다 / outsider observation은 반복되는 human behavior를 low-entropy resource로 평가한다 / empty tree의 fruit를 transplant로 기억한다
- resource conflict: `seed case`와 battery를 shelter, wall survey, gantry 중 하나에 배정한다.
- 고정 choice: `keep the wall closed` 후 seed를 보낼 destination을 명시하거나, `align recovery`/`align recognition`/`align authority` 중 하나를 선택한다.
- immediate → delayed: `crown_precedence` alignment, physical topology 재작성, `E09`/`E13`/`E16` redirect → `H0` + `R1`~`R6` 모든 revisit에 one named debt가 추가된다.
- magic write: `R7-09`의 contract가 Filing되면 `contract_tally`가 남고 `G8`은 그 contract를 `crown_protocol`의 안과 밖 중 한 곳에 명시해야 한다. 어느 쪽도 자동 `locked`가 되지 않으며 `R8-06`이 같은 contract를 다시 쓰면 두 record가 conflict한다(`02` §7.8 revisit, §8.8).

### 10.9 `RC-08` — The Fold That Refuses the Hand, `R8` (7 NPC)

- core NPC: `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_09_perrin_lask`, `npc_01_ilyra_senn`, `npc_06_tamas_quill`, `npc_10_juno_caster`, `npc_07_bryn_oskel`
- institutions: `MAG_ACADEMY` curriculum office, `CIRCULATION_BOARD`, `LINEAGE_HOUSE` registrar, `VOID_CONTRACT_COURT` (4)
- clocks: `CL-INST` `assigned`, `CL-PER` `divergent`, `CL-REC` `private` (3)
- partial truths: 학교는 lineage 미배정 craft를 `unassigned stock`으로 세지만 그 분류를 만든 authority가 아무도 답하지 못한다 / `R4` glossary는 학교가 붙인 이름을 아직 모른다 / `R7 Storm Verge`의 미완성 절단은 `Cut Chamber` 벽의 잔해와 같은 maker의 것이다 / 등록은 capability 등록이 아니라 measurement provenance 등록이다
- resource conflict: 마지막 `medium blank` 하나를 course 채점에 쓸지, 실패한 fold의 `Cut Chamber` 잔해를 회수해 `R5-03 Repair Bench`로 보낼지 배정한다.
- 고정 choice: `register concentration` 후 `place in lineage` 또는 `withdraw and take the labor record`
- immediate → delayed: `concentration sample` 등록(지점·시각·측정값·`provenance`), `lineage token`/`craft credit` 배분, `CL-INST` intervention stage, `CL-PER` role 결정, `R8` region state → `R4` `glossary` 충돌(학교 이름과 archive 번역이 두 줄로 남음), `R5` labor record 재분류, `R2` `E` 한 단계 전진(§6.2 loop 8), `R7` contract와 `R8-06`의 conflict
- combat/noncombat: `ENC-ARPG-25 The Fold That Refuses the Hand`(field court encounter)로도 끝나고 noncombat `withdraw and take the labor record`로도 끝난다. shape/medium 불일치는 spell rename이 아니라 `status`·`document`·`clock` write로만 표현한다.
- A1 조건: `R8` 추가 시 `changed_core_files == []`이어야 한다. `05`에 `FAM-ARPG-02` 기반의 `ENC-ARPG-25`와 `region_role: magic_training_craft_labor`가 등록되어 있어야 하고, `06`에 `region_r8_folding_school`/`route_e18_folding_school_approach`/magic `res_*` allowlist가 있어야 한다. 이 세 가지 중 하나라도 없으면 `RC-08`은 authoring 불가 상태다.

### 10.10 Cluster coverage와 비-몰집 규칙

| core NPC | 소속 cluster |
|---|---|
| `npc_01_ilyra_senn` | `HC-00`, `RC-01`, `RC-03`, `RC-04`, `RC-05`, `RC-06`, `RC-07`, `RC-08` |
| `npc_02_orrin_kest` | `HC-00`, `RC-01` |
| `npc_03_veya_morcant` | `HC-00`, `RC-01`, `RC-03`, `RC-04`, `RC-06` |
| `npc_04_sable_halm` | `RC-03`, `RC-04`, `RC-05`, `RC-06`, `RC-07`, `RC-08` |
| `npc_05_nera_voss` | `RC-01`, `RC-02`, `RC-03`, `RC-05`, `RC-06` |
| `npc_06_tamas_quill` | `RC-01`, `RC-04`, `RC-07`, `RC-08` |
| `npc_07_bryn_oskel` | `RC-07`, `RC-08` |
| `npc_08_meral_dune` | `HC-00`, `RC-02`, `RC-03`, `RC-07` |
| `npc_09_perrin_lask` | `RC-02`, `RC-03`, `RC-05`, `RC-08` |
| `npc_10_juno_caster` | `HC-00`, `RC-02`, `RC-03`, `RC-04`, `RC-05`, `RC-07`, `RC-08` |
| `npc_11_cael_ren` | `HC-00`, `RC-01`, `RC-02`, `RC-04`, `RC-06`, `RC-07` |
| `npc_12_ravenna_holt` | `RC-04`, `RC-07` |
| `npc_13_tovan_reed` | `RC-01`, `RC-02`, `RC-03`, `RC-05`, `RC-06` |
| `npc_14_eda_marrow` | `HC-00`, `RC-02`, `RC-05`, `RC-06`, `RC-08` |

- 14명 전원이 최소 한 cluster에 속하고, 어느 cluster도 12명을 넘지 않으며, 어느 cluster도 6명 아래로 떨어지지 않는다. 실제 cluster 크기는 `HC-00` 7, `RC-01` 7, `RC-02` 7, `RC-03` 8, `RC-04` 7, `RC-05` 7, `RC-06` 7, `RC-07` 8, `RC-08` 7이다. **4명 이하 cluster는 0개**며, 그런 cluster를 새로 만들면 `cluster_size_outside_6_12` error다.
- `R8`의 7명 core NPC visitor는 `02` §7.9가 열거한 명단과 1:1이다. `R8` support resident(`Mira Vask`, `Halen Osk`, `Iven Marrow`, `Turo Bex`, `Perri Lowe`, `Jano Fesk`, `Cael Orin`)는 core 수에 포함하지 않고 `npc_20_*` namespace로 해당 NPC의 port에 붙는다(`02` §12, `06` §5.11). `02` R7의 `Low-Entropy Surveyor`는 `RC-07`의 outsider observation surface이며 `RC-08`에는 등장하지 않는다.
- 모든 NPC가 한 장소에 모이는 giant meeting을 만들지 않는다. `npc_07_bryn_oskel`은 물리적으로 다른 region에 있으므로 `RC-08`에서 route sample과 `R7` contract 문서로 영향을 전달한다. `npc_14_eda_marrow`의 strike는 학교 밖에서 실행되고 학교에 filed record로만 도착한다.
- support resident(`02` §7의 region residents)는 core 수에 포함하지 않되, 그 NPC의 region family에 port를 가진 채 붙는다. dialogue-only resident를 새로 만들지 않는다.
- retained seed 하나는 자신이 수행되는 cluster 안에서 최소 두 개의 cross-link를 가진다. 한 NPC에만 묶이면 `unbound`다. `02` §11.4에 따라 magic seed는 `R8` family에만 묶여도 `unbound`다.


## 11. Core roster binding과 NPC 사용 규칙

`04` §2의 14명이 canonical core roster다. 이 파일의 모든 NPC 참조는 아래 stable ID만 쓴다.

| NPC | working name | primary port | `02` write owner | home node | 이 파일의 story 기능 |
|---|---|---|---|---|---|
| `npc_01_ilyra_senn` | Ilyra Senn | archive inquiry and record correction | `R4` `Record Office` | R4, R7 | hidden archive access, 이전 operator record의 living omission, record vs category, `R4` glossary 선점/충돌 |
| `npc_02_orrin_kest` | Orrin Kest | recovery intake and continuity testing | `R1` `Return Registry` / `H0` `Exchange Registrar` | H0, R1 | arrival category, wrong-return classification, receipt의 social cost |
| `npc_03_veya_morcant` | Veya Morcant | category audit and legal exception | `H0` appeal / `R4` `Censor` | H0, R3 | legally nonexistent category, exception 소유, jurisdiction 상실 |
| `npc_04_sable_halm` | Sable Halm | transformation support and maintenance | `R5` `Glasswing Ordinal` / `Labor Court` | R3, R5 | permission contract, bounded execution space, transformation success와 recognition failure의 분리, craft medium/execution space 배정 |
| `npc_05_nera_voss` | Nera Voss | organ negotiation and body consent | `R6` `Gristmarket Clinic` / `Organ Exchange` | R6, R3 | organ quorum, `CALL_BODY_VETO`, cure debt, co-signature, magic cure의 우회 비용 |
| `npc_06_tamas_quill` | Tamas Quill | translation and local-law authoring | `R4` `Translation Tribunal` | R4, H0, R7 | private wrong version, local law 작성, untranslatable self, magic term의 private version 유지 |
| `npc_07_bryn_oskel` | Bryn Oskel | frontier route survey | `R7` `Boundary Survey` | R7, R1, R2 | route mark/sample/seal, survivor extraction, outsider observation port, void-cut 증거 |
| `npc_08_meral_dune` | Meral Dune | water and survival allocation | `R2` `Water Council` / `Seed Vault keeper` | R2, R6, R7 | public ration arithmetic, secret reserve, collective accountability, `disperser`/`circulator` 배정 |
| `npc_09_perrin_lask` | Perrin Lask | identity registry and continuation naming | `R3` `Care Union` / `R4` `Record Office` | R3, R1, R4 | guardian alias, self-authored name, institution report vs 보호, lineage 배정표의 이름 없는 칸 |
| `npc_10_juno_caster` | Juno Caster | public witness and rumor routing | `H0` `Crier Office` / `R4` `Record Office` | H0, R4, R7 | thread, forward/verify/withhold, context 없는 screenshot, 실패한 fold의 public 전파 |
| `npc_11_cael_ren` | Cael Ren | successor continuity and recovery testing | `R1` `Return Registry` / `R7-07` operator claim | H0, R1, R2, R7 | wrong return, clone/branch, self-authored history, operator claim |
| `npc_12_ravenna_holt` | Ravenna Holt | crown alignment and legitimacy | `Crown Protocol` seat | R7, R4, H0 | petition, levy, operator 교체, precedence 공개 |
| `npc_13_tovan_reed` | Tovan Reed | field triage and recovery workaround | `R6` field-care / `R1` triage signature | R1, R6, R3 | field triage, survival cache, bypass recovery의 대가, `mana_profile` field 판정 |
| `npc_14_eda_marrow` | Eda Marrow | labor mobilization and service refusal | `R5` `Labor Court` / `R3` `Care Union` / `R2` delegates | R2, R5, R3, R6 | strike, care labor 재배정, collective veto, publish shift, 학교 밖 labour record |

`R8 The Folding School`에서의 두 번째 system port — `RC-08`에서 실행되는 surface다. home node는 바뀌지 않고 port가 하나 더 생긴다.

| NPC | `R8` 두 번째 port | `RC-08`에서 이 NPC가 바꾸는 것 |
|---|---|---|
| `npc_04_sable_halm` | transformation support → craft medium/execution space 배정 | 보호 capability와 `craft credit` 중 무엇을 boot에 쓸지 `CUT_DEPENDENCY`로 결정 |
| `npc_14_eda_marrow` | `R5 Labor Court` strike → 학교 밖 course/labor record 분리 | `craft credit`을 foundry labour hour로 옮길지 refusal record로 남길지 공개 결정 |
| `npc_09_perrin_lask` | continuation naming → lineage 배정표의 이름 없는 칸 | 가문 이름 대신 self-authored 이름을 등록하거나 숨긴다 |
| `npc_01_ilyra_senn` | `R4 Record Office` → `R4-01` glossary 선점/충돌 | 학교 이름과 archive 번역 중 어느 쪽이 canonical인지에 challenge를 건다 |
| `npc_06_tamas_quill` | translation → magic term의 private version 유지 | `untranslated term`을 그대로 남길지 번역할지 고른다 |
| `npc_10_juno_caster` | crier thread → 실패한 fold screenshot forwarding | `R8-05`의 public record가 학교 규제가 되는지 여부를 결정 |
| `npc_07_bryn_oskel` | `R7 Boundary Survey` → `R7-09`/`Storm Verge` 미완성 절단 증거 | `Cut Chamber` 잔해와 같은 maker임을 기록해 두 authority를 conflict시킨다 |

사용 규칙:

- NPC 한 명은 dialogue-only가 아니다. 각자 최소 하나의 system port를 실행하고 survival/death/absence가 field, resource, access, record, combat, relationship 중 하나 이상을 실제로 바꾼다.
- death와 absence는 서로 다른 후속 state를 가진다. NPC를 death 처리하고 같은 이름의 initial actor를 자동 재생성하지 않는다.
- affection가 높은 NPC도 death/absence에서 보호되지 않는다. player는 그 NPC를 대체할 수 없다.
- 두 region resident의 이름이 core NPC의 성·surname과 겹쳐도 병합하지 않는다(`04` §2.3의 비병합 목록을 따른다).
- support resident는 `npc_*` ID를 부여받지 않고 canonical core roster 수에 들어가지 않는다. nonhuman low-entropy observer도 NPC로 세지 않고 `npc_07_bryn_oskel`의 outsider observation port와 `TONE` surface로 실행한다.
- **roster는 14에서 시작·종료한다.** `R8 The Folding School`을 추가해도 15번째 `npc_*` core actor를 만들지 않는다. `R8`의 7명 core NPC visitor는 `02` §7.9가 열거한 `npc_04`, `npc_14`, `npc_09`, `npc_01`, `npc_06`, `npc_10`, `npc_07`이며 이들은 자신의 home region port를 유지한 채 `RC-08`에서 두 번째 port를 실행한다. 학교 측 surface는 `02` §7.9의 support resident(`Mira Vask`, `Halen Osk`, `Iven Marrow`, `Turo Bex`, `Perri Lowe`, `Jano Fesk`, `Cael Orin`)가 담당하고 `06` §5.11의 `roster_kind: support` + `npc_20_*` namespace로 등록한다. `role_field_investigator`는 여전히 player role ID이지 NPC ID가 아니다.

## 12. Relationship state와 affection arc

canonical relationship state는 `06` §5.7 `RelationshipStateDefinition`의 `states[].state_id` 하나다. schema·enum·검증 오류 소유권은 `06`, state 배열과 transition의 저작 해석은 `04`, 어떤 state가 어떤 ending·cluster·truth를 여는지는 이 파일이 소유한다. 아래 `rel_*` / `rs_*`는 이 파일이 제안하는 authored instance이며 `06` content 파일이 그대로 쓴다. `rel_*` ID는 `06` §3.5.3의 `rel_<nn>_<snake>` 형태를 따른다.

`04` §1.2.2의 여섯 값(`trust`/`fear`/`debt`/`recognition`/`attachment`/`agency`)은 **state transition의 입력**이며 canonical state가 아니다. `stance`(`04` §1.2.3)는 presentation label이고 save되지 않으며 condition으로 쓰이지 않는다. `agency`는 `rel.axes` 밖의 여섯 번째 값으로 authored되고 `npc_state` op과 world 축 write로 landing한다.

### 12.1 Relationship instance 전체표

| `rel_*` | target | channel | start state | 중간 state | sink state(s) | romance | driven by (`04` verbs) |
|---|---|---|---|---|---|---|---|
| `rel_01_ilyra_record` | `npc_01_ilyra_senn` | `professional` → `romance` | `rs_ilyra_unverified_petitioner` | `rs_ilyra_source_credited`, `rs_ilyra_name_kept` | `rs_ilyra_index_surrendered` / `rs_ilyra_institutional_threat` | allowed | `REQUEST_INDEX`, `PROTECT_NAME`, `SURRENDER_INDEX`, `OPEN_UPPER_STACK` |
| `rel_02_orrin_intake` | `npc_02_orrin_kest` | `professional` → `romance` | `rs_orrin_wary` | `rs_orrin_conditional_trust`, `rs_orrin_trusted` | `rs_orrin_committed` / `rs_orrin_fractured` | allowed | `DECLARE_RETURN`, `SHELTER`, `RELEASE`, `CHALLENGE_RECORD` |
| `rel_03_veya_audit` | `npc_03_veya_morcant` | `confrontation` | `rs_veya_hostile` | `rs_veya_conditional_trust` | `rs_veya_committed_exception` / `rs_veya_fractured_privilege` | allowed | `CHALLENGE_CATEGORY`, `AUDIT_CATEGORY`, `SIGN_EXCEPTION`, `RELEASE_SUBJECT` |
| `rel_04_sable_support` | `npc_04_sable_halm` | `care` → `romance` | `rs_sable_transactional` | `rs_sable_conditional_trust`, `rs_sable_trusted` | `rs_sable_shared_support` / `rs_sable_fractured_permission` | allowed | `REQUEST_CONSENT`, `ALLOCATE_EXECUTION_SPACE`, `CUT_DEPENDENCY`, `SURRENDER_SUPPORT` |
| `rel_05_nera_organ` | `npc_05_nera_voss` | `care` | `rs_nera_wary` | `rs_nera_conditional_trust` | `rs_nera_cosigned` / `rs_nera_fractured_representative` | allowed | `LISTEN`, `OFFER_CONSENT`, `CALL_BODY_VETO`, `REALLOCATE`, `LEAVE_CLINIC` |
| `rel_06_tamas_term` | `npc_06_tamas_quill` | `personal` | `rs_tamas_transactional` | `rs_tamas_conditional_trust`, `rs_tamas_source_entrusted` | `rs_tamas_committed` / `rs_tamas_fractured_exposure` | allowed | `COMPARE_VERSIONS`, `CHOOSE_GLOSS`, `SPEAK_FOR`, `EXPOSE_MISTAKE`, `RETURN_ORIGINAL` |
| `rel_07_bryn_route` | `npc_07_bryn_oskel` | `professional` | `rs_bryn_wary` | `rs_bryn_conditional_trust`, `rs_bryn_trusted` | `rs_bryn_shared_route` / `rs_bryn_fractured_abandon` | allowed | `MARK_ROUTE`, `SAMPLE`, `OPEN_PASSAGE`, `RESCUE`, `ABANDON_ROUTE` |
| `rel_08_meral_ration` | `npc_08_meral_dune` | `professional` | `rs_meral_transactional` | `rs_meral_conditional_trust`, `rs_meral_co_accountant` | `rs_meral_committed_shared_manifest` / `rs_meral_fractured_privilege` | allowed | `ALLOCATE_WATER`, `DIVERT_RESERVE`, `SHARE_MANIFEST`, `REFUSE_EXTRA` |
| `rel_09_perrin_ward` | `npc_09_perrin_lask` | `kinship` | `rs_perrin_wary` | `rs_perrin_conditional_trust` | `rs_perrin_chosen_family` / `rs_perrin_fractured_report` | not allowed (`04` §4.2: 성인 romance와 guardianship를 혼합하지 않는다) | `ENROLL`, `RENAME`, `ASSIGN_GUARDIAN`, `HIDE`, `PROVE_CONTINUITY`, `RETURN_CHILD` |
| `rel_10_juno_channel` | `npc_10_juno_caster` | `professional` → `romance` | `rs_juno_transactional` | `rs_juno_conditional_trust`, `rs_juno_trusted_or_fractured` | `rs_juno_committed_archive` / `rs_juno_fractured_channel` | allowed | `FORWARD`, `VERIFY`, `WITHHOLD`, `OPEN_CHANNEL`, `RELEASE_ARCHIVE` |
| `rel_11_cael_history` | `npc_11_cael_ren` | `care` | `rs_cael_subject_observed` | `rs_cael_conditional_trust`, `rs_cael_trusted` | `rs_cael_self_authored` / `rs_cael_fractured_proxy` | allowed | `TEST_CONTINUITY`, `INDEX_MEMORY`, `REFUSE_INHERITANCE`, `RETURN_FRAGMENT`, `CHOOSE_HISTORY` |
| `rel_12_ravenna_seat` | `npc_12_ravenna_holt` | `confrontation` → `romance` | `rs_ravenna_wary` | `rs_ravenna_transactional`, `rs_ravenna_conditional_trust` | `rs_ravenna_committed` / `rs_ravenna_hostile_claim` | allowed | `PETITION`, `LEVY`, `WITHHOLD_SEAL`, `DEFER_CROWN`, `ABDICATE_PROTOCOL` |
| `rel_13_tovan_triage` | `npc_13_tovan_reed` | `care` | `rs_tovan_conditional_trust` | `rs_tovan_trusted` | `rs_tovan_partner` / `rs_tovan_fractured_motive` | allowed | `TRIAGE`, `ASK_CONSENT`, `OPERATE`, `CARRY`, `LEAVE_CACHE` |
| `rel_14_eda_shift` | `npc_14_eda_marrow` | `professional` → `romance` | `rs_eda_wary` | `rs_eda_conditional_trust`, `rs_eda_trusted` | `rs_eda_committed_collective` / `rs_eda_fractured_efficiency` | allowed | `MOBILIZE`, `STRIKE`, `REDISTRIBUTE`, `PROTECT_WORKER`, `NEGOTIATE` |

공통 검증(`06` §5.7):

- `states[]`는 1~10개, `order`는 0부터 연속, sink는 `max_final_state`만큼 정확히 존재한다. 위 표에서 sink가 2개인 relation은 두 final state 중 하나가 run을 끝낸다는 뜻이다.
- 전이는 DAG이고 `is_irreversible` 전이에는 되돌림 edge가 1개 있다. `via`는 `choice`/`effect`/`encounter_outcome`/`clock_stage`/`recovery`/`absence` 중 하나이고 `via == "choice"`이면 `choice_taken` leaf가 반드시 있다.
- `rs_*_trusted`(companion power가 켜지는 state)는 `entry_effect_ids`에 `granted_by_effect_ids`가 포함돼야 한다. romance state로 들어가는 전이는 `choice` 또는 `effect`여야 하고 `clock_stage`/`absence`/`encounter_outcome`으로 강제 진입할 수 없다.
- `dialogue_policy`는 `guarded`/`operational`/`candid`/`hostile`/`absent` 중 하나다. `stance` label은 presentation이므로 dialogue를 바꾸지 않는다.

### 12.2 세 개의 full arc

#### 12.2.1 Ilyra Senn — "기록은 사람을 지우지 않는다"

1. `rel_01_ilyra_record` `rs_ilyra_unverified_petitioner`: Ilyra는 player를 petition자로 부르고 한 층위만 공개한다.
2. `rs_ilyra_source_credited`: player가 source provenance를 묻고 private name을 category로 덮지 않는다. `REQUEST_INDEX` + `SHOW_FRAGMENT`.
3. `rs_ilyra_name_kept`: consent 있는 person record를 유지한다. `PROTECT_NAME`. `recognition`이 `person`에서 `distributed_self`로 이동한다.
4. `rs_ilyra_index_surrendered`: 단독 archive ownership을 포기하고 maintenance authority를 공동으로 넘긴다. `SURRENDER_INDEX` + `OPEN_UPPER_STACK`.
5. `rs_ilyra_institutional_threat`: archive seal을 공개하거나 `PROTECT_NAME`을 consent 없이 반복하면 institution이 player를 위협으로 분류한다. 개인적 신뢰는 남을 수 있고 romance는 trust보다 먼저 무너지지 않으며, 이 경로에서도 `rs_ilyra_index_surrendered`로의 복귀 edge가 있다.

Delayed consequence: player가 Ilyra를 archive access로만 쓰면 `R4` hidden route는 열리지만 `CL-REC`가 한 단계 진행되고 public copy가 먼저 도착한다. 반대로 이름의 주인을 지키면 hidden access 대신 late revisit에서 `R4-08 Archive Fire`의 reconstruction queue가 Ilyra의 몫으로 남는다.

`RC-08` 연결: 학교가 `R8-03`에서 등록한 magic term이 `R4-01`의 번역과 다르면 `rs_ilyra_institutional_threat`와 `rs_ilyra_index_surrendered` 어느 쪽에서도 `R4-02`의 contradictory copy가 남는다. 이 conflict는 Ilyra가 `REQUEST_INDEX`를 거부했는지와 무관하게 발생하며, 그 conflict를Filing하는 것이 이 relation의 `R8` 축 evidence다.

#### 12.2.2 Tamas Quill — "번역되지 않을 말을 지켜라"

1. `rel_06_tamas_term` `rs_tamas_transactional`: Tamas는 player의 언어를 instrument로 취급한다.
2. `rs_tamas_conditional_trust`: 두 source version을 실제로 비교한다. `COMPARE_VERSIONS`.
3. `rs_tamas_source_entrusted`: Tamas가 source를 player에게 맡기고 player가 private wrong version을 공개하지 않는다. `SPEAK_FOR` 또는 `CHOOSE_GLOSS`.
4. `rs_tamas_committed`: local protocol을 community에 반환한다. `RETURN_ORIGINAL`.
5. `rs_tamas_fractured_exposure`: player가 private wrong version을 public record로 노출한다. `EXPOSE_MISTAKE`가 player 주도으로 실행된 경우. 되돌림은 `rs_tamas_conditional_trust`로.

Delayed consequence: Tamas의 wrong version이 Filing되면 society는 그것을 진실로 쓰기 시작한다. community는 recognition을 얻지만 survival infrastructure를 해칠 수 있고, `R4-01 Translation Desk`의 term 하나가 `R5` labor role과 `R7` wall category를 동시에 다시 쓴다.

`RC-08` 연결: `R4` `glossary`가 비어 있는 동안 학교가 붙인 이름은 `untranslated term`으로 Filing된다. Tamas가 그 term을 번역하면 `rs_tamas_committed`, private version으로 남기면 `rs_tamas_source_entrusted`, glossary 충돌을 공개하면 `rs_tamas_fractured_exposure`가 된다. 세 결과 모두 유효하며 `T7`의 delayed consequence를 남긴다.

#### 12.2.3 Nera Voss — "consent에는 주어가 둘 이상 있다"

1. `rel_05_nera_organ` `rs_nera_wary`: Nera는 player가 clinic을 resource shop으로 볼지 시험한다.
2. `rs_nera_conditional_trust`: player가 organ voice를 줄이지 않는다. `LISTEN` 반복.
3. `rs_nera_cosigned`: patient와 organ의 signature가 맞아 relationship보다 co-signatory가 먼저가 된다. `OFFER_CONSENT` + `CALL_BODY_VETO`.
4. `rs_nera_fractured_representative`: player가 patient와 organ 중 하나를 자동으로 대표한다. 되돌림은 consent를 다시 여는 action이 필요하다.
5. organ quorum 자체(`CALL_BODY_VETO`, `LEAVE_CLINIC`)는 별도 actor가 아니다. `npc_05_nera_voss`의 port이며 quorum이 없으면 patient가 고립되고 strike가 발생한다.

Delayed consequence: player가 organ의 refusal을 무시하고 player를 안정시키면 care debt로 끝나고 `ROUTE_BODY`는 public apology/repair event를 요구한다. player가 procedure를 거부하면 Nera는 autonomous하게 남지만 immediate survival cost는 그대로다.

`RC-08` 연결: organ magic의 output을 승인할 수 있는 장기 authority가 organ마다 다르다. `R6`의 magic cure는 통증을 되돌리지 않고 우회하며 그 우회가 `C`에 `branched`로 남는다. Nera가 magic cure를 거부하면 `rs_nera_fractured_representative`가 되고, organ이 승인하면 `rs_nera_cosigned`가 된다. magic failure는 이 relation의 어떤 state도 자동으로 닫지 않는다(`12` §9).

### 12.3 Chosen-family와 non-romantic bond

- `npc_11_cael_ren`의 loyalty는 합법적으로 인정된 이름 또는 self-authored history에서 나오며 romance가 아니다.
- `npc_09_perrin_lask`의 생존은 truthful record와 institution이 조용히 닫을 수 없는 질문에 묶인다. `rel_09_perrin_ward`는 `kinship` channel이고 romance를 열지 않는다.
- `npc_07_bryn_oskel`의 route support는 boundary/resource 결정에 의존하고 나중에 잃을 수 있다(`ABANDON_ROUTE`).
- `npc_04_sable_halm`과 `npc_05_nera_voss`는 organ plurality를 인정하지 않으면 support할 수 없다.
- `npc_14_eda_marrow`의 collective solidarity는 form이며, 개별 privilege와는 별개다.
- `R8`은 chosen family를 새로 만들지 않는다. `rel_09_perrin_ward`의 lineage 이름 문제는 kinship arc의 연장선이고, `rel_14_eda_shift`의 학교 밖 labour record는 collective arc의 연장선이다. 가문(`LINEAGE_HOUSE`)은 romance나 chosen family의 조건이 아니다.

## 13. Body-horror identity arc

body horror는 identity/state 사건이다. 무엇을 명령·기억·인정·구조·사랑할 수 있는지를 바꾼다. transformation을 수락한 보상도, spectacle도 아니다. `04` §4.3의 6개 요소를 모든 arc가 명시한다.

### 13.1 `BODY_ARC_PLAYER_FOUR_ANCHORS`

- **무엇이 변하는가:** `role_field_investigator`의 body/memory/role/recognition anchor 4개가 서로 다른 층위에서 독립적으로 write된다.
- **combat/resource 영향:** `PLAYER_LAYER_BODY`는 contamination/organ priority 우회를, `PLAYER_LAYER_ROLE`은 permission 통과를, `PLAYER_LAYER_RECOGNITION`은 한 gate의 category를 무효화한다. 각 사용은 `continuity_pressure` 또는 `recognition_drift` write와 field hazard를 동반한다.
- **social recognition 분기:** 한 층위의 recovery가 다른 층위를 복구하지 않는다. record가 맞아도 social recognition이 없고, title이 남아도 operator가 바뀔 수 있다.
- **consent:** 각 anchor는 consent owner가 있다. `npc_05_nera_voss`의 `CALL_BODY_VETO`가 거부하면 해당 cycle의 body write는 실행되지 않는다.
- **immediate / delayed:** immediate는 field hazard와 axis write, delayed는 해당 NPC의 relationship state와 public record category.
- **recovery가 restoration인가 bypass인가:** bypass다. `PLAYER_LAYER_MEMORY`를 쓰면 raw sensory fact 1개를 잃고, 그 detail을 알아야만 완성되는 관계가 delayed consequence로 남는다.

### 13.2 `BODY_ARC_CAEL_SAME_BODY_DIFFERENT_SOCIAL_CONTINUITY`

`npc_11_cael_ren`은 존재하지 않는 settlement의 기억을 되찾은 채 `R1 Wrong Return`으로 돌아온다. body와 memory trace는 original/return candidate와 공유되지만 `Return Registry`가 합법적으로 인정할 수 있는 이름은 하나다. player는 새 이름을 줄 수 있고, original을 인정할 수 있고, category를 미해결로 둘 수 있다. public record가 단일 identity를 강제하면 같은 NPC가 NPC-boss state가 되며, 그 encounter는 새 사람이 기존 skin을 입는 형태가 아니다. `05`가 encounter detail을 소유하고, `06`이 stable NPC ID 유지를 강제한다.

### 13.3 `BODY_ARC_ORGAN_QUORUM`

`npc_05_nera_voss`가 broker/subject로 대표하는 organ disagreement는 `R6` organ priority를 공개하고, 보호·인식·욕구를 서로 다른 authority로 나눈다. `Gristmarket Clinic`은 한 organ을 우세하게 만들어 body를 안정시킬 수 있지만 social recognition은 그 사람이 patient인지 worker인지 operator인지 여러 개인지를 아직 결정하지 않는다. player는 조정하거나, 분할하거나, consent로 통합하거나, quorum을 거부할 수 있다. 모든 voice를 침묵시킨 승리는 encounter가 끝나도 partial failure다. organ delegate와 peer mediator 표기(§0.1의 organ quorum 항목)는 이 surface에 folding되며 별도 actor가 아니다.

### 13.4 `BODY_ARC_ILYRA_WRONG_HISTORY`

`npc_01_ilyra_senn`는 correct body와 다른 continuity의 employment history로 돌아온다(archive indexer의 경우 record/lineage 층위). player는 그 account를 받아들일 수 있고, record를 요구할 수 있고, missing person으로 만들 수 있다. 이 arc는 affection과 identity evidence를 충돌시킨다. 사랑은 그 사람의 history를 덮어쓸 권한이 아니며, valid한 archive record도 그 사람이 player가 사랑한 사람이라는 것을 증명하지 않는다.

### 13.5 `BODY_ARC_TAMAS_TRANSLATION_DRIFT`

`npc_06_tamas_quill`의 low-level language error는 이름과 social role을 읽는 방식을 바꾼다. high-level translation은 기능을 유지하면서 관계를 알아보게 만드는 sensory detail을 지울 수 있다. arc는 nuance 복원, 새 private protocol, 또는 일부러 부분 미분류로 남기는 public category 중 하나로 끝난다.

### 13.6 `BODY_ARC_SABLE_BOOT_RECOGNITION_SPLIT`

`npc_04_sable_halm`의 transformation은 `R5` boot process다. `R5-02 Boot Sequence`의 load/allocate/protect/recognize가 각각 독립 write이고, protect는 성공해도 recognize가 실패할 수 있다. body capability와 labor/social name이 별도로 남는다. `R5-06 Formation Failure`의 signature enemy를 쓰면 combat 경로가 열리고, noncombat 경로는 `npc_13_tovan_reed`의 field triage와 `npc_09_perrin_lask`의 continuation naming이 받는다. 성공과 인정의 분리는 `ROUTE_BODY`의 핵심 evidence다.

### 13.7 `BODY_ARC_MANA_PROFILE_NOT_MORAL_CLASS`

- **무엇이 변하는가:** `magic.body_load`의 `mana_profile` 8종(`12` §2.2)이 actor의 저장·배출·상해 경로를 정한다. retention high/emission low, retention low/emission high, balanced, overflow, blocked emission, concentration-reactive, medium-reactive, sensory misclassification.
- **combat/resource 영향:** 발출만 되는 체질은 care window가 아니라 emission capacity 문제로 분류되고 `R5-01` boot 조건과 `R8-04` course 선택을 좁힌다. 과잉 축적 체질은 `K`가 아니라 `P`에 먼저 나타난다. blocked emission은 cast 자체를 막는다.
- **social recognition 분기:** profile은 `R3-01 Intake Triage`에서 `patient` 아래의 sub-category로 남고, 그 값이 `R4`에서 `artifact`로 번역되면 동일 몸이 다른 category로 Filing된다. `R3` disputed `worker` claim과 같은 구조다.
- **consent:** profile은 측정값이지 동의가 아니다. `npc_13_tovan_reed`의 field triage와 `npc_05_nera_voss`의 organ signature가 `R3-01`의 `mana_profile`Filing을 각각 승인·반박할 수 있다. player가 측정값을 대신 결정하면 `PLAYER_LAYER_RECOGNITION` write가 companion power 없이 통과한다.
- **immediate / delayed:** immediate는 course/boot 선택지 자체가 줄어드는 것과 field hazard, delayed는 그 profile이 `R4`와 `R8`에서 서로 다른 이름으로 재사용되는 것이다.
- **recovery가 restoration인가 bypass인가:** bypass다. magic cure는 body function을 되돌리지 않고 우회하며 그 우회가 `C`에 `branched`로 남는다(`02` §7.4).

### 13.8 `BODY_ARC_ORGAN_MEDIUM_RESIDUE`

- **무엇이 변하는가:** magic medium이 organ protocol에 축적되어 sweat/immune/nerve 경로가 바뀐다(`12` §4). `R6`은 그 residue를 medium으로 분류해 판매하고, `R5-03 Repair Bench`는 회수 대상으로 센다.
- **combat/resource 영향:** residue를 회수하지 않으면 `R5-10 Field Weave`의 cast 오차가 한 단계 오르고 `R5-12 Void Cut`의 도구 안정성이 떨어진다. 회수하면 `res_medium_blank` 계열 재고가 늘지만 organ testimony 한 건이 사라진다.
- **social recognition 분기:** residue는 `B`를 `organ-authority` 쪽으로 민다. clinic은 이를 complication으로, 환자는 이를 기억 저하로 읽는다(`02` §7.7).
- **consent:** organ이 residue 배출을 거부할 수 있다. `CALL_BODY_VETO`가 거부하면 회수는 combat/negotiation으로만 실행된다.
- **immediate / delayed:** immediate는 `R5` cast 오차, delayed는 `R4` public record가 organ을 object로 쓸지 person으로 쓸지 결정해야 한다는 `RC-06`의 delayed consequence다.
- **recovery가 restoration인가 bypass인가:** bypass다. 배출은 cleansing이면서 동시에 resource loss다.

### 13.9 `BODY_ARC_FAILED_FOLD_TERMINAL`

- **무엇이 변하는가:** `R8-05 Fold Failure Hearing`이 남긴 실패가 `Cut Chamber` 벽에 physical residue로 남고, cognition/competence가 손상될 수 있다. 실패 등급은 `12` §8의 `recoverable`/`continuity-changing`/`terminal`이며 recovery 7종의 `kind`가 아니다.
- **combat/resource 영향:** `terminal` 등급이면 해당 cast family가 닫히고 `R5-11 Rigid Fold`와 `R8-04`의 해당 course option이 막힌다. 학생은 제거되지 않고 다른 course로 전환할 수 있다.
- **social recognition 분기:** `B`는 수단 실패면 `artifact`, 숙련 실패면 `person`으로 갈린다. 어느 쪽이든 `R5-04 Name Hearing`의 결과와 충돌한다.
- **consent:** `R8-08 Field Probation`의 학교 밖 실습이 실패를 되돌릴 수 있다. player가 그 제안만으로 `R8-05`를 닫으려 하면 `CL-PER`만 전진하고 `CL-REC`는 남는다.
- **immediate / delayed:** immediate는 `medium`+`course credit` 소실, delayed는 `R4-05 Name Hearing` 재개와 `R2` `E` 전진이다.
- **recovery가 restoration인가 bypass인가:** restoration이 아니다. competence는 복구되지 않고 다른 competent 경로로 우회된다.

### 13.10 `BODY_ARC_PORTAL_DEFERRED_SELF`

- **무엇이 변하는가:** 고위 portal contract는 다른 층/차원의 존재와 무언가를 맺어 deferred obligation을 남긴다. 존재의 출력 규칙이 예측 불가할 수 있어(`IDEA_LEDGER` `S157`) `B`를 `unclassified` 쪽으로 민다. 저위 portal은 재물/먹이를 주고 불확실한 공격을 받는다.
- **combat/resource 영향:** shape가 destination과 위험을 결정하고, 도구(가위/칼날)의 물리 구조가 cost와 안정성을 정한다. `contract_tally`은 combat balance가 아니라 obligation ledger다.
- **social recognition 분기:** 계약 상대는 `B operator`로 Filing되지만 사람도 organ도 아니다. `R4`가 그것을 어느 문장으로 번역하느냐에 따라 `B` primary가 다시 갈린다.
- **consent:** `R8-06 Void Contract Filing`의 `approval_signature`는 있으나 철회 불가다. 되돌림은 없지만 `G8`에서 `crown_protocol` 안과 밖 중 어디에 둘지는 선택할 수 있다.
- **immediate / delayed:** immediate는 `E`(circulation 소모)와 `R`(contract 공개), delayed는 `C` interpretation input과 `R4-02`의 canonical law 재작성이다.
- **recovery가 restoration인가 bypass인가:** 어느 쪽도 아니다. contract는 obligation을 남기며 death/recovery로 회수되지 않는다. `checkpoint` 뒤에도 `magic.contracts`는 초기화되지 않는다(`02` §10).


## 14. Authored story content format

모든 format은 module-local authored data다. global quest log, permanent journal button, global EventBus가 아니다. player는 world object, NPC interaction, terminal, document, called detail layer로 접근한다. schema와 검증 오류는 `06`이 소유한다.

### 14.1 Schema 매핑

| story format | `06` kind | 비고 |
|---|---|---|
| conversation / choice | `conversations`, `choices` | choice 결과는 dialogue가 아니라 domain state에 atomic 적용 |
| document (paged, corruption) | `documents` | page당 최대 9줄, `lines` 1..9, `max_lines_per_page ≤ 9` |
| operational log | `documents` (kind of log) 또는 `effects`가 쓰는 surface | log 자체는 world artifact + aftermath projection |
| consent record | `effects` + `flags` + `relationships` 전이 | body/memory/role/recognition 층위별 boolean과 `revocable_until` |
| group thread | `conversations` + `effects` | `certainty: fact|inference|rumor|forwarded`, `visibility: private|local|public` |
| encounter aftermath | `encounters` outcome + `props` state + `effects` | irreversible event는 최소 한 world surface와 한 non-dialogue domain surface를 바꾼다 |
| ending | `encounters` terminal outcome + `effects` + `flags` + `relationships` | `06` content ID는 lowercase snake_case (§14.7) |
| concentration registration | `documents` + `effects` | 값·시각·지점·`provenance` 4개가 모두 있어야 Filing된다. 하나만 적으면 `R8-02`가 거부한다 |
| course index / craft credit | `documents` + `props` + `effects` | `craft_credit`는 `res_*` field resource이고 `course index`는 region state다. 같은 값을 두 곳에 복제하지 않는다 |
| void contract filing | `documents` + `effects` | shape·대가·조건·`contract_tally`·`approval_signature`를 함께 남긴다. 자동 해소 field를 두지 않는다 |
| lineage placement | `documents` + `effects` | `lineage_token` 발급과 이름 없는 배정함 보존을 각각 기록한다 |
| magic failure record | `statuses` + `effects` + `clocks` write | 실패 등급 3종(`12` §8)은 recovery type이 아니다 |
| glossary slot | `documents` (`glossary`이 비어 있으면 `untranslated term` Filing) | `R4`가 소유. `R8`은 이름 요청만 한다 |

### 14.2 초기 authored artifact set

`02`의 region family가 authored surface를 소유한다. 이 표는 그 family가 어느 document/log/thread로 읽히는지 story-side에서 고정한다.

| artifact | canonical surface | `06` kind | first unlock | immediate story effect |
|---|---|---|---|---|
| `doc_return_record` | `R1-01 Misreturned Person` / `R1-06 Registry Interrogation` | `documents` | `RC-01` | 첫 receipt/category 선택을 만든다 |
| `doc_door_role_test` | `R1-02 Door Role Test` | `documents` | `RC-01` | exact-compliance 우회와 그 delayed 비용을 준다 |
| `doc_translation_desk` | `R4-01 Translation Desk` | `documents` | `RC-04` | 같은 사건의 세 문장이 서로 다른 category를 만든다 |
| `doc_contradictory_record` | `R4-02 Contradictory Record` | `documents` | `RC-04` | 두 문장이 서로 다른 route gate를 동시에 활성화한다 |
| `doc_crown_fragment` | `R4-06 Crown Fragment` | `documents` | `RC-04` + `G8` precondition | literal object evidence를 만든다 |
| `doc_crown_position` | `R7-04 Crown Position` | `documents` | `RC-07` | 세 층위를 분리해 기록하게 한다 |
| `doc_boot_contract` | `R5-01 Boot Contract` | `documents` | `RC-05` | full/staged/refused boot의 capability와 빚을 기재한다 |
| `doc_name_hearing` | `R5-04 Name Hearing` | `documents` | `RC-05` | body name과 labor/operator name을 분리한다 |
| `doc_supply_rack_receipt` | `R5-13 Supply Rack` | `documents` | `RC-05` + `E15` 통과 | 학교로 넘길 medium/fold/blade와 labor hour를 묶어 `E18` 비용을 만든다 |
| `doc_heart_petition` | `R6-03 Heart Petition` | `documents` | `RC-06` | organ의 operation consent/pain/refusal/witness를 제출한다 |
| `doc_body_authority_registry` | `R6-06 Body Authority Registry` | `documents` | `RC-06` | organ이 사람보다 먼저 legal signatory가 되는 record를 만든다 |
| `doc_debt_surgery_terms` | `R6-04 Debt Surgery` | `documents` | `RC-06` | debt를 organ/work hour/memory access 중 하나로 전환한다 |
| `doc_memory_copy_consent` | `R3-08 Memory Copy Consent` | `documents` | `RC-03` | recovery type의 memory policy를 authored explicit value로 고정한다 |
| `doc_mana_profile_chart` | `R3-01 Intake Triage` | `documents` | `RC-03` | `mana_profile`을 moral judgement가 아닌 body compatibility class로 Filing한다 |
| `doc_disperser_reading` | `R2-09 Disperser Reading` | `documents` | `RC-02` 이후 | `concentration_sample`/`disperser_charge`와 측정 provenance를 만든다 |
| `doc_circulator_ledger` | `R2-10 Circulator Ledger` | `documents` | `RC-02` 이후 | `circulation_slot` 배정과 이웃 region 오염 Filing을 만든다 |
| `doc_void_cut_ledger` | `R7-09 Void Cut Ledger` | `documents` | `RC-07` | shape를 먼저 그리고 나서 contract 조건을 고르게 한다 |
| `doc_care_notice` | `H0-06 Care Notice` | `documents` | `HC-00` | sponsor/kin/chosen family/romance 후보를 별도 record로 제시한다 |
| `thread_civic_channel` | `H0-05 Crier Thread` | `conversations` + `effects` | `HC-00` 이후 모든 public anomaly | local event를 rumor, action, record로 바꾼다 |
| `doc_operator_replacement_claim` | `R7-07 Operator Replacement` | `documents` + `effects` | `RC-07` + `G8` | operator claim 제출과 `crown_precedence` write를 만든다 |
| `doc_course_index` | `R8-01 Course Index` | `documents` | `RC-08` / A1 | `SERVICE_R8_COURSE_INDEX`와 같은 내용을 world 안에서 만든다 |
| `doc_concentration_registration` | `R8-02 Concentration Registration` | `documents` | `RC-08` / A1 | 지점·시각·측정값·`provenance`를 함께 등록한다. page 2에 deterministic corruption 1개를 둔다 |
| `doc_lineage_placement` | `R8-03 Lineage Placement` | `documents` | `RC-08` / A1 | `lineage_token`과 이름 없는 배정함 중 하나를 고른다 |
| `doc_course_selection` | `R8-04 Course Selection` | `documents` | `RC-08` / A1 | weave/fold/void-cut 중 하나와 필요한 `medium`을 기재한다 |
| `doc_failed_fold_hearing` | `R8-05 Fold Failure Hearing` | `documents` | `RC-08` / A1 | 실패한 fold를 course credit·student status·public record로 나눠 Filing한다 |
| `doc_void_contract` | `R8-06 Void Contract Filing` | `documents` | `RC-08` / A1 | shape·대가·조건과 `contract_tally`을 적는다 |
| `doc_glossary_slot` | `R4` `glossary` slot | `documents` | `RC-04` 이후 / `RC-08` 충돌 시 | 비어 있으면 `untranslated term` Filing, 채워지면 학교 이름과 archive 번역이 충돌한다 |
| `doc_operator_index` | `R7-07` + `R4-07` | `documents` | `RC-07` + `G8` | operator claim과 archive seat의 category를 함께 남긴다 |

문서 규칙: corruption은 authored token span과 state threshold만 쓴다. random text를 만들지 않고, corruption이 color에만 의존하지 않으며, critical fact의 유일한 원천이 되지 않는다. 긴 정보는 page로 나누고 next-page affordance를 준다.

### 14.3 Story state

```text
StoryState
- crown_precedence
- operator_id
- crown_object_phase
- truth_evidence: Dictionary[truth_id, StoryTruthState]
- axis_writes: axis_key -> int -3..3        (02 §3 mapping, 06 §6.1 storage)
- clocks: Dictionary[clock_id, ClockState]
- route_flags: Dictionary[route_id, RouteState]
- cluster_states: Dictionary[cluster_id, ClusterState]
- relationship_states: Dictionary[rel_id, rs_state_id]
- body_anchor_states: Dictionary[anchor_id, BodyAnchorState]
- recovery_lineage: Array[recovery_event_id]   (08 §history)
- document_reads: Array[document_id]
- pending_consequences: Array[consequence_id]
- magic: 02 §9.1의 6개 하위 record
  - concentration_fields: node/path/action, 값, 시각, provenance
  - body_load: actor, accumulation, emission_capacity, injury, mana_profile
  - circulation: node, disperser_state, circulation_slot, 누적 pollution
  - crafts: 준비된 weave/scroll, fold count, shape_or_pattern, tool_variant, residue
  - contracts: shape, 대가, 조건, contract_tally, resolution
  - glossary: R4 소유. 비어 있으면 untranslated term으로 Filing
- ending_eligibility
```

presentation focus, hover, panel position, current page는 transient다. presentation state가 복원하며 위 domain state를 대체하지 않는다.

`magic` record는 `res_*` field resource와 분리한다. `medium_blank` 같은 물질은 `world.resources`에, `shape_or_pattern`/`tool_variant` 같은 계약 조건은 `magic.crafts`에 있다. 한 값을 두 namespace에 복제하지 않는다(`02` §9.1).

### 14.4 Conversation / Choice

```text
ConversationDefinition
- conversation_id
- speaker_npc_id          (core roster 14명 중 1명)
- entry_condition
- node_ids[] (page 순서)
- choice_set_id
- exit_policy
- revisit_policy
- return_focus_id

ChoiceDefinition
- choice_id
- label
- availability            (focusable disabled도 published 한다)
- reveal_when_unavailable
- result: effect_id / relationship transition / axis write / prop write
- is_irreversible
```

- conversation은 `port`를 최소 하나 가진다. dialogue-only NPC를 quest source로 쓰지 않는다.
- choice의 focus와 result는 서로 다른 state다. focus는 bracket·brush fill·line/text 중 두 channel 이상으로 표시하고 color로만 구분하지 않는다.
- commit 이전의 cancel은 이전 page/choice focus로 돌아가고, commit 이후의 cancel은 rollback하지 않는다. `return_focus_id`가 있으면 그 choice로, 없으면 authored `result_node`로 진행하며, 둘 다 없으면 conversation을 종료한다.
- unavailable choice는 `reveal_when_unavailable`이 true일 때만 표시하고, 표시할 때 focusable하지만 confirm은 state를 바꾸지 않는다. disabled와 focus를 같은 표시로 처리하지 않는다.

### 14.5 Document

```text
DocumentDefinition
- document_id
- title
- source_role
- availability_condition
- pages[]
  - page_id
  - lines[]                 (1..9, 줄당 64자 이하)
  - source_refs[]
  - corruption_rules[]      (authored token span + state threshold)
  - reader_attention_anchor
- post_read_effect_ids[]
- world_prop_state_after_read
- revisit_policy
- min_font_size            (20 이상)
```

- page는 9줄을 넘지 않는다. overflow는 `document_page_overflow` validation error다.
- corruption은 authored이고 deterministic이다. random typo/runtime RNG를 쓰지 않고, corruption이 critical fact의 유일한 원천이 되지 않으며, red-only rule을 만들지 않는다.
- 긴 정보는 page로 나누고 next-page affordance를 준다. 마지막 page와 revisit에서 focus가 이전 유효 focus로 복귀한다.

### 14.6 Operational log과 consent record

```text
OperationalLogDefinition (documents kind의 log 형태)
- log_id
- event_id
- era_or_local_time
- protocol_function: recover | recognize | authorize
- subject_id
- category_before / category_after
- continuity_anchor
- resource_delta
- approval_signature
- cost_target
- unresolved_debt
- corruption_rules[]

ConsentRecordDefinition
- record_id
- subject_id
- body_consent / memory_consent / role_consent / recognition_consent
- revocable_until
- irreversible_effect_ids[]
- witness_npc_ids[]
- organ_or_protocol_authorities[]
- refusal_result
```

- log는 world artifact이자 aftermath projection이다. recovery가 비용을 contamination·body·name·public record 중 어디로 옮겼는지를 드러낼 수 있다. 정확한 수치 문체는 필요할 때 건조하지만, 수치가 인과 state를 대신하지 않는다.
- 단일 yes/no는 transformation을 승인하지 않는다. player와 NPC는 한 층위를 거절하고 다른 층위를 승인할 수 있다. form 실패 자체가 authored state이며 Works labor/legal dispute를 만들 수 있다.
- `revocable_until` 이후의 write는 되돌릴 수 없다. 되돌림이 있는 경우 `is_irreversible` 전이에 대응하는 역방향 edge로 authored한다.
- `era_or_local_time`는 `E1`~`E4`를 쓴다. `E4` log는 `concentration`/`medium`/`tool`/`shape_or_pattern`/`social_recording` 칸을 갖고, 이 칸은 `12` §2.1의 `MagicCast` field 이름과 일치한다. module script이 그 값을 하드코딩하지 않는다.

### 14.7 Group thread, aftermath, stable ID 규칙

```text
GroupThreadDefinition
- thread_id
- participant_npc_ids[]
- messages[]
  - message_id
  - author_npc_id
  - reply_to_id
  - certainty: fact | inference | rumor | forwarded
  - attachment_ref
  - visibility: private | local | public
- moderation_state
- forward_without_context_rule
- rumor_effect
- post_thread_record_effect

IncidentAftermathDefinition
- event_id
- official_category
- alternate_categories[]
- world_prop_changes[]
- npc_state_changes[]
- route_effects[]
- delayed_consequence_ids[]
- revisit_variant_id
```

- thread는 비동기 social infrastructure다. 이미지를 forwarding하면 settlement에 도움이 될 수 있고 private anomaly를 public category로 만들 수 있다. 많은 사람이 반복한다고 message가 truth가 되지 않는다.
- aftermath는 최소 한 world surface와 한 non-dialogue domain surface를 함께 바꾼다. dialogue flag, 깨진 document, boss defeat만으로는 완전한 consequence가 아니다.

stable ID 규칙:

- plan-level ID(`END_*`, `TRUTH_*`, `ROUTE_*`, `CONSEQ_*`, `BEAT_*`, cluster 대체 ID)는 이 문서와 `10`이 공유하는 **catalog ID**다.
- `06` content ID는 `06` §3.2 namespace와 §3.3 ID 규칙을 따른다: lowercase snake_case, 3~64자, flat, dot·sla sh 비ASCII 금지, kind prefix 필수, 재사용·rename 금지.
- ending content ID 매핑(`06` §3.5.6이 유일한 변환 source다):

| plan-level ending ID | `06` content ID |
|---|---|
| `END_R1_RECEIPT_OF_A_LIFE` | `end_r1_receipt_of_a_life` |
| `END_G1_LAW_WITHOUT_MASTER` | `end_g1_law_without_master` |
| `END_O1_MANY_MOUTHS_ONE_PERSON` | `end_o1_many_mouths_one_person` |
| `END_A1_EMPTY_SEAT` | `end_a1_empty_seat` |
| `END_C1_FOUR_ANCHORS` | `end_c1_four_anchors` |
| `END_C2_LAST_WITNESS` | `end_c2_last_witness` |

- production `.gd`에 authored ID나 dialogue literal을 넣지 않는다. content 추가로 core 파일이 바뀌면 Kit 실패다.

## 15. Delayed consequence와 partial success

### 15.1 Delayed consequence register

| consequence ID | immediate trigger (canonical) | delayed trigger | changed surfaces | 영향 lens / ending |
|---|---|---|---|---|
| `CONSEQ_01_RECEIPT_DEBT` | `RC-01` `carry claimant`, `R1-06` receipt 발급 또는 거부 | 두 번째 귀환 또는 `HC-00` return hearing | `npc_11_cael_ren`의 이름/`recognition_drift`, `Return Registry` access, `E06`/`E07` | `ROUTE_RETURN`, `END_R1` |
| `CONSEQ_02_TRANSLATION_LAW` | `RC-04` translation A/B 제출 또는 `publish contradiction` | NPC/enemy가 그 term으로 불릴 때 | local sign, dialogue address, encounter label, `public_record` | `ROUTE_RECOGNITION`, `END_G1` |
| `CONSEQ_03_ORGAN_PARTITION` | `RC-06` organ custody 분할, `PLAYER_LAYER_BODY` 사용 | body가 후반 route에서 복귀할 때 | combat target priority, care capacity, consent state | `ROUTE_BODY`, `ROUTE_CRAFT`, `END_O1` |
| `CONSEQ_04_THREAD_PUBLIC` | `H0-05` `FORWARD`/`WITHHOLD`/`RELEASE_ARCHIVE` | `CL-INST` intervention 또는 rumor 확산 | NPC `recognition`, `public_record`, route permission | 전 lens |
| `CONSEQ_05_SHORTCUT_CONTAMINATION` | `R1-02`/`R7-08` shortcut 개방, `npc_07_bryn_oskel`의 `OPEN_PASSAGE` | `CL-CONT` 또는 `CL-RES` tick | `R2` supply, `npc_07_bryn_oskel`/`npc_13_tovan_reed` state, field encounter variant | `ROUTE_RETURN`, `ROUTE_BODY` |
| `CONSEQ_06_CLONE_ECOLOGY` | `RC-02` `share`, `seed case`/water 배분 | settlement이 다른 climate/labor/class로 재결합 | water, sound, labor, `recognition_drift` category | `ROUTE_RECOGNITION`, `ROUTE_BODY` |
| `CONSEQ_07_ARCHIVE_LEGITIMACY` | `R4-06`/`R4-07` page·permission 접촉 | `npc_12_ravenna_holt`의 `PETITION`/`DEFER_CROWN` | vertical access, public succession, `crown_alignment` | `ROUTE_AUTHORITY`, `END_A1` |
| `CONSEQ_08_RELATIONSHIP_BOUNDARY` | `rel_*` 전이, commitment/refusal/repair | 최종 companion support 또는 분리 | combat support, dialogue policy, ending witness | 전 lens |
| `CONSEQ_09_ORGAN_HOSTILITY` | organ signature가 지워지거나 강제 통합됨 | `R6-05` encounter variant 또는 ally state | body, route gate, public category | `ROUTE_BODY`, `END_C1` |
| `CONSEQ_10_RECORD_SURVIVAL` | private fact가 formalize됨 | 후속 authority가 wrong record를 사용 | NPC legal category, `protocol_legitimacy`, family/school | `ROUTE_RECOGNITION`, `ROUTE_AUTHORITY` |
| `CONSEQ_11_CROWN_PRECEDENCE` | `G8`에서 precedence 선택 | world-wide revisit | 전 node의 route state, revisit archive, operator | `ROUTE_AUTHORITY`, `END_C1` |
| `CONSEQ_12_CONCENTRATION_EXPORT` | `R2-09`/`R2-10` dispersal 배정, `R8-02` 등록 | 이웃 region의 `CL-CONT` 또는 `CL-RES` tick | `R2` `E` 한 단계, 이웃 `K`, `E18` resource, `RC-08` provenance | `ROUTE_CRAFT`, `ROUTE_RECOGNITION`, `END_O1` |
| `CONSEQ_13_CRAFT_CLASS_RECLASS` | `R5-13` labour hour 전환, `R8-01` course index Filing, `R8-08` field probation | `RC-05` 재방문 또는 `R5-07` walkout | `R5` labor record, `A`, `D`, `P`, `R8` region state | `ROUTE_CRAFT`, `ROUTE_BODY`, `END_O1`, `END_C1` |
| `CONSEQ_14_CONTRACT_TALLY` | `R7-09`/`R8-06` void-cut 계약 | `G8` precedence 확정 또는 `R4-02` 재Filing | `contract_tally`, `C` interpretation input, `R4` canonical law | 전 lens(특히 `ROUTE_AUTHORITY`, `END_A1`, `END_C1`) |
| `CONSEQ_15_GLOSSARY_CONFLICT` | 학교 이름과 archive 번역이 다른 `R4-02`/`RC-08` Filing | `R4-01` 재방문 또는 `G8` 후 | `glossary` slot 2줄, `npc_06_tamas_quill`/`npc_01_ilyra_senn` dialogue address, encounter label | `ROUTE_RECOGNITION`, `ROUTE_CRAFT`, `END_G1`, `END_C1` |

각 consequence는 immediate 1회, delayed 1회만 발동한다. 같은 event를 reload·revisit·phase transition으로 재처리해도 추가 effect가 없다. `CONSEQ_12`~`CONSEQ_15`도 이 규칙을 따른다 — `provenance`나 `contract_tally`가 남은 채로 revisit해도 다시 적립되지 않는다.

### 15.2 Partial-success vocabulary

resolution은 `person`, `relationship`, `truth`, `local_stability` 중 하나 이상을 지키면서 다른 차원에 명시적 debt를 만들 때 `partial_success`다. hidden fail state가 아니라 first-class ending input이다.

- `PARTIAL_PERSON`: body/returner는 살아 있지만 social identity가 미해결이다.
- `PARTIAL_RELATIONSHIP`: bond는 실재하고 검증되었지만 boundary·lie·jealousy가 남는다.
- `PARTIAL_TRUTH`: document는 `actionable`이 되었지만 contradiction 또는 source 하나가 남는다.
- `PARTIAL_RECOVERY`: function은 복구됐지만 원 memory·role·failure는 아니다.
- `PARTIAL_AUTHORITY`: gate는 열렸지만 legitimacy 또는 public trust가 이전/양도/보류된다.
- `PARTIAL_ECOLOGY`: 지금은 자원을 지켰지만 다음 supply·climate·labor가 나빠진다.
- `PARTIAL_CRAFT`: cast는 성공했지만 medium·course credit·body load 중 하나가 소모되거나, 계약이 남았다.
- `PARTIAL_CONCENTRATION`: 농도를 낮췄지만 이웃의 `K`/`E`에 값이 적립되었다.


## 16. Major ending

ending은 6종이 전부다. ID는 `10`이 요구하는 ending catalog ID(acceptance 조건은 §21.1)이며, `06` content ID는 §14.7의 `06` §3.5.6 canonical ID를 쓴다. 모든 ending은 text-only epilogue가 아니다. 최소 한 NPC, world prop, route access, relationship 또는 clock surface를 바꾼다.

**route bundle**은 `route gate + 두 cluster resolution + 하나의 `corroborated` truth + 하나의 delayed consequence`다. bundle은 convergence와 last-witness eligibility에 쓰이며 route 이름만으로는 충분하지 않다.

acceptance hook 규칙: 각 ending의 hook은 (a) 해당 lens의 mechanical·timing evidence를 만드는 `07` 수동 task, (b) recovery·save·revisit evidence를 만드는 `07` `RG-M09`/`RG-M10` 항목, (c) `10`의 자동 test ID로 구성한다. `07`의 run 단위 task(`RG-M02`~`RG-M05`)는 encounter 수와 실측 시간만 증명하고 ending eligibility를 증명하지 않는다. `RC-08`을 근거로 하는 hook은 `07` `RG-M13`(A1)을 추가 요구한다. ending-eligible run은 이 문서 §16의 cluster·truth·relationship 조건을 **추가로** 만족해야 하며, 그 조건이 깨지면 §16.7 downgrade 규칙이 적용된다.

### 16.1 `END_R1_RECEIPT_OF_A_LIFE` — `ROUTE_RETURN`

- content ID: `end_r1_receipt_of_a_life`
- 정문: `G1 Ash Debt` + `RC-01` `carry claimant`
- cluster: `HC-00` 필수 + `RC-01`, `RC-02`, `RC-03`, `RC-06`, `RC-07` 중 ≥4 resolved
- truth: `TRUTH_T0_CONTINUANCE_PROMISE` ≥ `corroborated`, `TRUTH_T2_COST_EXPORT` ≥ `corroborated`
- relationship: `rel_11_cael_history` ≥ `rs_cael_self_authored`, `rel_02_orrin_intake` ≥ `rs_orrin_committed`, `rel_10_juno_channel` ≥ `rs_juno_conditional_trust`
- recovery: `institutional_reentry`(`R1`) + `checkpoint`/`respawn`(실패 경로) 1회 이상
- acceptance hook: ending catalog 6종 존재 + re-key 잔여 0 검사, `07` `RG-M02`, `RG-M09` 3번, `10` `test_revisit_preserves_consequences_without_replaying_oneshot_effects`
- saved: 선택한 사람, 한 지역 관계, 작동하는 귀환 route
- incomplete: Crown Protocol이 continuity의 정의를 계속 소유한다. duplicate·loop·settlement debt가 남는다.
- world change: `Return Registry`가 신뢰 가능한 local office가 되지만 `R2`와 public record가 비용을 지불하고 `npc_12_ravenna_holt`는 clean succession을 주장할 수 없다.
- affection consequence: `rs_ilyra_index_surrendered`면 archive 공동 소유가 남고, `rs_ilyra_institutional_threat`면 archive가 withhold된다. 두 경로 모두 유효하다.
- partial success: 한 사람이 receipt를 가진다. social peace가 보장되지는 않는다.
- magic 표면: 이 ending은 `R8`을 열지 않는다. `E18`이 닫힌 채 `CONSEQ_13_CRAFT_CLASS_RECLASS`만 `R5-13` labour hour로 발생한다. `R8` curriculum은 world 밖의 학제로 남는다.

### 16.2 `END_G1_LAW_WITHOUT_MASTER` — `ROUTE_RECOGNITION`

- content ID: `end_g1_law_without_master`
- 정문: `G4 Translation Precedence` + `RC-04` `publish contradiction`
- cluster: `HC-00` 필수 + `RC-02`, `RC-03`, `RC-04`, `RC-05`, `RC-07` 중 ≥4 resolved
- truth: `TRUTH_T1_PROTOCOL_SPLIT` ≥ `actionable`, `TRUTH_T5_NO_SINGLE_WILL` ≥ `actionable`
- relationship: `rel_06_tamas_term` ≥ `rs_tamas_committed`, `rel_10_juno_channel` ≥ `rs_juno_committed_archive`, `rel_09_perrin_ward` ≥ `rs_perrin_conditional_trust`
- recovery: `loop`(`R5` maintenance cycle) + `institutional_reentry`(`R4` filing) 1회 이상
- acceptance hook: ending catalog 6종 존재 + re-key 잔여 0 검사, `07` `RG-M04`, `RG-M09` 5번, `10` `test_corruption_rules_are_authored_and_deterministic`
- saved: 번역 불가능한 사람/category, 스스로를 이름 붙일 수 있는 local community
- incomplete: 옛 주소·기억·관계가 유지되기 어렵고 모든 region이 조정할 수 없다.
- world change: `Translation Tribunal`/`Record Office`가 분산 civic institution이 되고 public category는 Crown permission 없이도 생기지만 local legal conflict를 만든다.
- affection consequence: `rs_tamas_committed`는 잃은 low-level detail을 되찾았을 때만 성립한다. 아니면 Tamas는 legally legible하고 personally overwritten이다.
- partial success: Crown의 naming monopoly가 끝나고 communication과 law가 복수(plural)가 된다.
- magic 표면: `CONSEQ_15_GLOSSARY_CONFLICT`가 발동하면 `glossary` slot에 두 줄이 남고 ending의 `saved` 목록에 "이름 없는 craft"가 추가된다. 학교 이름을 먼저 Filing한 경우에는 `TRUTH_T6`가 `corroborated`까지만 올라가며, 학교가 그 이름을 소유한다.

### 16.3 `END_O1_MANY_MOUTHS_ONE_PERSON` — `ROUTE_BODY`

- content ID: `end_o1_many_mouths_one_person`
- 정문: `G3 Latency Receipt` + `G5 Labor Pledge` + `RC-06` `split custody`
- cluster: `HC-00` 필수 + `RC-03`, `RC-05`, `RC-06`, `RC-01` 중 ≥4 resolved. `ROUTE_CRAFT` run이면 `RC-08`이 `RC-05`를 대체할 수 있고, 이 경우 `RC-03`가 추가 필수다.
- truth: `TRUTH_T2_COST_EXPORT` ≥ `actionable`, `TRUTH_T4_BRIDGE_SUBJECT` ≥ `actionable`
- relationship: `rel_05_nera_organ` ≥ `rs_nera_cosigned`, `rel_04_sable_support` ≥ `rs_sable_trusted`, `rel_13_tovan_triage` ≥ `rs_tovan_trusted`
- recovery: `reincarnation`(`R3` care alternate) + `immortality`(`R6` redirected-cost branch) 1회 이상. `clone`(`R2`)는 선택.
- acceptance hook: ending catalog 6종 존재 + re-key 잔여 0 검사, `07` `RG-M03`, `RG-M09` 6·7번, `RG-M12`, `10` `test_recovery_operation_preserves_declared_identity_layers`. `ROUTE_CRAFT` 경로면 `RG-M13` 추가.
- saved: organ plurality를 가진 한 사람의 self, 강제 통합을 거부할 수 있는 body protocol, explicit하지 않은 chosen bond
- incomplete: clinic이 medical authority를 유지하고 일부 organ은 안정되지 않거나 합법적으로 인식되지 않는다.
- world change: body가 distributed protocol site로 인식되고 Crown Protocol은 한 organ을 전체 사람으로 취급할 수 없지만 institution은 새로운 medical authority를 얻는다.
- affection consequence: `rs_sable_shared_support`는 어떤 organ도 player의 편의 위해 override되지 않았을 때만 유지된다.
- partial success: plurality가 civic fact로 보호되지만 무해해지지는 않는다.
- magic 표면: `RC-08`을 이 ending의 근거로 삼았다면 `R8`은 magic을 `labor hour`/`craft credit`로Filing한 기관으로 남고 학교는 worker를 certification 대상에서 빼지 못한다. `rel_14_eda_shift`가 `rs_eda_committed_collective`이면 `craft credit`의 일부는 `labor hour`로 환전되지 않는다. `contract_tally`은 ending이 끝난 뒤에도 남는다.

### 16.4 `END_A1_EMPTY_SEAT` — `ROUTE_AUTHORITY`

- content ID: `end_a1_empty_seat`
- 정문: `G8 Crown Precedence` + `R4-07 Operator Trial`에서 서로 다른 출처의 permission 3개
- cluster: `HC-00` 필수 + `RC-04`, `RC-05`, `RC-07`, `RC-03` 중 ≥4 resolved
- truth: `TRUTH_T0_CONTINUANCE_PROMISE` ≥ `actionable`, `TRUTH_T3_CROWN_CONTINUANCE` ≥ `actionable`, `TRUTH_T5_NO_SINGLE_WILL` ≥ `corroborated`
- relationship: `rel_12_ravenna_seat` ≥ `rs_ravenna_committed`, `rel_01_ilyra_record` ≥ `rs_ilyra_name_kept`, `rel_11_cael_history` ≥ `rs_cael_conditional_trust`
- recovery: `institutional_reentry` 1회 이상 + `G8` world write(`crown_precedence`, `operator_id`, `crown_object_phase`). `crown_alignment`를 recovery type으로 기록하지 않는다.
- acceptance hook: ending catalog 6종 존재 + re-key 잔여 0 검사, `07` `RG-M05`, `RG-M09` 8번, 10단계 recovery 7종 + operator/precedence world write 보존 검사(`§21` handoff 참조)
- saved: 물리 왕관의 위치, successor record, 최소 한 local office가 부당한 명령을 거부하는 능력
- incomplete: legitimacy이 중앙집중되거나 파편화된다. player는 protocol의 다음 비용을 상속한다.
- world change: operator가 Crown로 오해되지 않게 되지만 `Crownwell Archive`가 명시적·강제 가능한 authority가 된다.
- affection consequence: `npc_12_ravenna_holt`는 deposed·witness·successor 중 하나가 되고, `rs_ravenna_hostile_claim`이면 seat는 hostile actor에게 간다. intimate relationship은 자동 access를 주지 않는다.
- partial success: throne은 비었지만 protocol의 seat는 어딘가에 남는다.
- magic 표면: `G8`은 `contract_tally`이 남은 채 실행될 수 있다. 이때 precedence는 각 contract를 `crown_protocol`의 안과 밖 중 어디에 두는지 **명시해야** 하고, 어느 쪽도 자동으로 `locked` 처리되지 않는다. `RC-08`이Filing되었다면 `R8` curriculum은 precedence가 바뀌어도 남는다(`02` §7.9 revisit).

### 16.5 `END_C1_FOUR_ANCHORS` — convergence

- content ID: `end_c1_four_anchors`
- 정문: `G0`~`G8` 전부 resolved, `HC-00` + `RC-01` + `RC-04` 필수 + `RC-02`/`RC-03`/`RC-05`/`RC-06`/`RC-08` 중 3개 이상
- truth: `TRUTH_T3_CROWN_CONTINUANCE` ≥ `actionable`, `TRUTH_T4_BRIDGE_SUBJECT` ≥ `actionable`, `TRUTH_T5_NO_SINGLE_WILL` ≥ `actionable`
- relationship: 14명 중 최소 6명이 sink state에 도달하고 그중 최소 2개가 `romantic_commitment` 또는 `chosen_family`이고, 어느 하나도 `absent`가 아니다
- recovery: 7개 canonical type을 모두 실제 authored surface에서 1회 이상 실행
- magic 조건: `TRUTH_T6_CRAFT_IS_LABOR` ≥ `actionable`이고 `TRUTH_T7_CUT_IS_A_DEBT` ≥ `actionable`이면 이 ending이 **선호**된다(강제 아님). 두 truth가 `partial`/`corroborated`에 머물면 `END_C1`는 성립하지만 `saved` 목록에서 magic 항목이 빠진다.
- acceptance hook: ending catalog 6종 존재 + re-key 잔여 0 검사, `07` `RG-M05`, `RG-M07`, `RG-M09` 전 항목, `RG-M11`, `RG-M12`, `RG-M13`(A1 통과 후), 7 canonical recovery type의 self-layer 보존표 검사(`§21` handoff 참조)
- saved: 어떤 institution도 recovery·recognition·authority의 단독 소유자가 아니다. player는 plural하지만 인식되고, 최소 두 local community가 self-chosen continuity를 유지한다.
- incomplete: Crown invariant는 maintenance burden로 남고 clock은 사라지지 않으며 player는 계속 협상해야 한다.
- world change: 왕관 object는 public로 남고 `Crown Protocol` seat는 rotating council이 되며, `Record Office`는 local vocabulary control을 얻고, `Return Registry`는 consent-based가 되고, `Organ Exchange`는 organ representation을 얻는다.
- affection consequence: committed companion은 독립 exit을 유지한다. story는 possessiveness를 보상하지 않는다.
- partial success: 해방은 분산되고 다시 검토 가능하지만 영구 최종 승리가 아니다.
- magic 표면: `RC-08`이 cluster 조건에 포함되었다면 `MAG_ACADEMY`, `CIRCULATION_BOARD`, `LINEAGE_HOUSE`, `VOID_CONTRACT_COURT` 중 최소 두 authority가 course/lineage/contract 각각에 대한 자기 범주를 유지한다. `E18`은 `open`으로 남고 `R8`의 두 return affordance가 모두 열린다.

### 16.6 `END_C2_LAST_WITNESS` — incomplete / partial

- content ID: `end_c2_last_witness`
- 정문: 어느 lens에서든 `corroborated` route bundle이 2개 미만, 또는 `RC-07`에서 한 사람을 살리면서 archive/seat를 포기한 resolution
- cluster: `HC-00` + 최소 3개, 그중 2개는 delayed consequence까지 발동
- truth: `TRUTH_T4_BRIDGE_SUBJECT` ≥ `partial`, 그 외 `actionable` 0개 허용
- relationship: 최소 1개 sink, 최대 2개. 그 외는 `fractured` 또는 `absent` 허용
- recovery: `respawn` 또는 `checkpoint`만 사용 가능. 다른 5개 type을 한 번도 실행하지 않은 상태
- magic 조건: `E18`을 열었지만 `RC-08`을 resolved cluster로 만들지 못한 경우, 또는 `contract_tally`이 남은 채 `G8`을 실행하지 못한 경우 모두 이 ending으로 떨어진다. `END_C2`는 그에 대해 failure가 아니라 지정된 fallback이다.
- acceptance hook: ending catalog 6종 존재 + re-key 잔여 0 검사, `07` `RG-M01` + `RG-M10`, 그리고 "`planned` row는 완료 증거로 인용되지 않는다"는 seed 감사 규칙(`§21` handoff 참조)
- saved: player와 작은 선택된 무리가 usable한 truth fragment로 즉시 alignment를 피한다.
- incomplete: Crown Protocol은 unknown/local operator 아래 계속되고 region clock과 public record는 미해결이다.
- world change: world가 양립 불가능한 protocol로 분열하고 recovery-failed space, clone debt, untranslated category가 흔해진다.
- affection consequence: player가 버린 것에 대해 진실을 말하면 관계를 살릴 수 있고, 거짓말은 한 사람을 지킬 수 있지만 ending을 더 고립시킨다.
- partial success: player는 해방자가 아니라 witness다. 이것은 유효한 ending이며 hidden punishment가 아니다.
- magic 표면: `glossary` slot이 비어 있고 `concentration_field`가 threshold를 넘긴 채 끝나면 마지막 field surface는 이름 없는 craft와 낮아지지 않은 농도로 남는다. 둘 다 `unclassified` 경로로 읽힌다.

### 16.7 Ending resolution 순서와 downgrade 규칙

1. route와 cluster history를 검증한다.
2. truth evidence와 pending consequence를 검증한다.
3. body/relationship state를 operator authority보다 먼저 resolve한다.
4. institution별 immediate ending effect를 atomic하게 적용한다.
5. aftermath를 같은 world에 changed prop/NPC/route로 투영한다.
6. 미해결 clock을 world behavior로 남긴다. victory cutscene으로 지우지 않는다.

**downgrade 규칙(고아 방지):** 어떤 조합도 ending 없이 끝나지 않는다.

- lens 5개 중 하나 이상(`ROUTE_RETURN`/`ROUTE_RECOGNITION`/`ROUTE_BODY`/`ROUTE_CRAFT`/`ROUTE_AUTHORITY`)을 resolved bundle로 갖고 있으면 그 lens ending으로 resolve한다.
- 두 lens 이상을 resolved bundle로 갖고 `TRUTH_T3`+`TRUTH_T4`가 `actionable`이면 `END_C1_FOUR_ANCHORS`로 resolve한다.
- 위 두 조건을 모두 만족하지 못하면 `END_C2_LAST_WITNESS`로 resolve한다. 이 경우 `END_C2`는 실패가 아니라 지정된 fallback이다.
- 어떤 ending도 다른 ending으로 "승격"되지 않으며, ending ID는 content에서 재사용·삭제하지 않는다.

### 16.8 Coverage matrix (고아 없음 증명)

| 대상 | 커버하는 ending |
|---|---|
| `HC-00` | `END_R1`, `END_G1`, `END_O1`, `END_A1`, `END_C1`, `END_C2` (모든 run의 필수 첫 cluster) |
| `RC-01` | `END_R1`, `END_O1`, `END_C1`, `END_C2` |
| `RC-02` | `END_G1`, `END_R1`, `END_O1`, `END_C1`, `END_C2` |
| `RC-03` | `END_O1`, `END_A1`, `END_G1`, `END_C1` |
| `RC-04` | `END_G1`, `END_A1`, `END_C1` |
| `RC-05` | `END_O1`, `END_G1`, `END_A1`, `END_C1` |
| `RC-06` | `END_O1`, `END_R1`, `END_C1`, `END_C2` |
| `RC-07` | `END_A1`, `END_R1`, `END_G1`, `END_O1`, `END_C1`, `END_C2` |
| `RC-08` | `END_O1`, `END_G1`, `END_A1`, `END_C1`, `END_C2` (`END_R1`에서는 `E18`이 닫힌 채 unresolved로 남는다) |
| `E18` 통과/미통과 | `END_O1`(`ROUTE_CRAFT`), `END_C1`, `END_C2`(fallback), `END_R1`(미통과 시 `CONSEQ_13`만 발생) |
| `TRUTH_T0` | `END_R1`, `END_A1` |
| `TRUTH_T1` | `END_G1` |
| `TRUTH_T2` | `END_R1`, `END_O1` |
| `TRUTH_T3` | `END_A1`, `END_C1` |
| `TRUTH_T4` | `END_O1`, `END_C1`, `END_C2` |
| `TRUTH_T5` | `END_G1`, `END_A1`, `END_C1` |
| `TRUTH_T6` | `END_O1`, `END_G1`, `END_C1`, `END_C2` |
| `TRUTH_T7` | `END_A1`, `END_G1`, `END_O1`, `END_C1`, `END_C2` |
| `ROUTE_RETURN` / `_RECOGNITION` / `_BODY` / `_CRAFT` / `_AUTHORITY` / `_CONVERGENCE` | `END_R1` / `END_G1` / `END_O1` / `END_O1` / `END_A1` / `END_C1` (+ 전 lens가 `END_C2`로 fallback) |
| `rel_01_ilyra_record`, `rel_10_juno_channel`, `rel_11_cael_history`, `rel_02_orrin_intake` | `END_R1`, `END_A1` |
| `rel_06_tamas_term`, `rel_09_perrin_ward` | `END_G1` |
| `rel_05_nera_organ`, `rel_04_sable_support`, `rel_13_tovan_triage` | `END_O1` |
| `rel_12_ravenna_seat` | `END_A1` |
| `rel_03_veya_audit`, `rel_07_bryn_route`, `rel_08_meral_ration`, `rel_14_eda_shift` | `END_C1` aggregate(14명 전원 sink 요구) + `07` `RG-M07` NPC consequence check |
| `rel_*` 14개 전체 | `END_C1`이 14명 전원을 요구하며, 어느 하나도 `absent` sink가 될 수 없다 |
| `checkpoint` | `END_R1`, `END_C2` |
| `respawn` | `END_C2` (기본 실패 경로) |
| `clone` | `END_O1`(선택), `END_C1` |
| `reincarnation` | `END_O1`, `END_C1` |
| `loop` | `END_G1`, `END_C1` |
| `immortality` | `END_O1`, `END_C1` |
| `institutional_reentry` | `END_R1`, `END_G1`, `END_A1`, `END_C1` |
| `G8` world write | `END_A1`, `END_C1` |
| `CONSEQ_12_CONCENTRATION_EXPORT` | `END_O1`, `END_G1`, `END_C1`, `END_C2` |
| `CONSEQ_13_CRAFT_CLASS_RECLASS` | `END_O1`, `END_G1`, `END_A1`, `END_C1`, `END_C2` |
| `CONSEQ_14_CONTRACT_TALLY` | `END_G1`, `END_A1`, `END_O1`, `END_C1`, `END_C2` |
| `CONSEQ_15_GLOSSARY_CONFLICT` | `END_G1`, `END_A1`, `END_C1`, `END_C2` |
| `magic` 하위 6개 record | `END_C1`(6개 모두), `END_O1`(`body_load`/`crafts`/`circulation`), `END_G1`(`glossary`/`crafts`), `END_A1`(`contracts`), `END_C2`(전부 미해결 상태) |

## 17. 10분+ story beat map

이 map은 playable story spine이며 quest-list 추정이 아니다. 한 Reference Game run은 최소 6개 interaction cluster, 6명 NPC state actor, document/log/thread sequence 1개, combat 또는 NPC-boss 또는 noncombat resolution 1개, partial success 1개, delayed-consequence revisit 1개를 포함한다. `07`이 소유하는 실측 목표는 direct `18~25분`, body `30~42분`, resource `30~40분`, full survey `75~95분`이며 10분은 하한이다. 이동·대기·반복 combat·대사량으로 시간을 채우지 않는다.

| beat ID | target time | node / cluster | authored unit | player action and story information | new system proof / state change |
|---|---:|---|---|---|---|
| `BEAT_00_ARRIVAL` | 0:00–0:45 | `H0` | `H0-01 Arrival Docket`, 첫 arrival record | `npc_02_orrin_kest`에게 arrival stamp 하나를 조사하고 category를 선언하거나 보류한다 | 첫 field frame, contextual interaction, 상시 HUD 0건 |
| `BEAT_01_FIRST_DOCKET` | 0:45–1:45 | `H0` / `HC-00` | `H0-03 Return Hearing`, `doc_return_record` 1 page | body/role/record 중 어느 층위만 일치하는지 확인하고 `withhold category` 후 한 return을 sponsor한다 | `TRUTH_T0` `partial`, `CONSEQ_01`, `G0` 통과, `rel_02_orrin_intake` 전이 |
| `BEAT_02_FIVE_EXITS` | 1:45–2:30 | `H0` | `H0-02 Counterweight Map`, `H0-08 Route Debt` | 다섯 출발 edge의 gate/resource/epistemic 조건을 실물 route card와 lift counter로 확인한다 | route gate projection, quest arrow 0건 |
| `BEAT_03_RECOVERY_CHOICE` | 2:30–3:30 | `R1` / `RC-01` | `R1-01`, `R1-04 Continuation Trial`, `doc_door_role_test` | `RC-01` `carry claimant`를 실행하고 recovery type을 고르며 contamination signal 하나를 본다 | `CONSEQ_05`, `CL-CONT` increment, combat/avoid/noncombat choice |
| `BEAT_04_THREAD_WARNING` | 3:30–4:15 | `H0` / `R4` | `H0-05 Crier Thread`(`thread_civic_channel`) | `npc_10_juno_caster`에게 screenshot/log를 forward·verify·withhold 중 하나로 처리한다 | `CONSEQ_04`, `CL-REC` 전진, `rel_10_juno_channel` 전이 |
| `BEAT_05_FIRST_LAYERED_TRUTH` | 4:15–5:15 | `R4` / `RC-04` | `R4-01` + `R1-01` 또는 `R6-06` 비교 | 두 source를 실제로 나란히 놓고 어느 protocol이 그 사건을 먼저 처리하는지 고른다 | `TRUTH_T1` `corroborated`, 두 institution 간 cross-link |
| `BEAT_06_FIRST_BOND` | 5:15–6:00 | `R3` / `R5` | `R3-03 Vow Ledger`, `R5-05 Care Shift` | care·boundary·작은 commitment 중 하나를 고르고 그 NPC의 다음 state를 본다 | `rel_*` state 이동, companion support, explicit하지 않은 affection |
| `BEAT_07_LENS_CLUSTER` | 6:00–8:00 | lens별 cluster | `RC-02`/`RC-03`/`RC-04`/`RC-05`/`RC-06` | 조정하거나, category를 거부하거나, 같은 NPC의 combat state를 해결하거나, noncombat으로 끝낸다 | system port, encounter data, body/recognition state |
| `BEAT_08_RESOURCE_PRESSURE` | 8:00–9:00 | `R2` / `RC-02` | `R2-01 Water Round`, `R2-08 Settlement Vote` | 한 ration line을 medicine 또는 settlement에 배정하고 이전 선택이 physical shortage로 돌아오는 것을 본다 | `CONSEQ_06`, `CL-RES` escalation, `rel_08_meral_ration` 전이 |
| `BEAT_08B_CONCENTRATION_INFRA` | 9:00–9:40 | `R2` / `RC-02` | `R2-09 Disperser Reading`, `R2-10 Circulator Ledger`, `doc_disperser_reading` | 한 지점의 농도를 실제로 측정하고 `provenance`을 적으며, 누출 농도를 이웃으로 보낼지 남길지 배정한다 | `CONSEQ_12` 시작, `concentration_sample`/`disperser_charge`/`circulation_slot` 생성, `E18` resource gate 후보 |
| `BEAT_09_PARTIAL_RESOLUTION` | 9:40–10:40 | 직전 cluster의 aftermath | `R6-04`/`R4-02` deferred write | 하나를 지키고 무엇을 지키지 못했는지 field 표면으로 확인한다 | `partial_success`, `CONSEQ_10`, changed prop/NPC |
| `BEAT_10_SECOND_AUTHORED_UNIT` | 10:40–12:10 | 다른 lens cluster 또는 같은 cluster의 다른 resolution | 두 번째 content family | core를 고치지 않고 같은 system으로 새 request/refusal을 실행한다 | cross-route gate, alternate resolution |
| `BEAT_11_PUBLIC_CATEGORY` | 12:10–13:10 | `R4` / `R3` | `R4-03 Public Hall Copy`, `R3-01 Intake Triage`, `doc_mana_profile_chart` | 한 사람을 person·object·role·unclassified 중 무엇으로 보호할지 결정하고 `mana_profile`을 moral judgement가 아닌 class로 Filing한다 | `recognition_drift`, `CL-INST`, public record change, `R8-04` course eligibility |
| `BEAT_12_BODY_TRUTH` | 13:10–14:10 | `R6` / `R5` | `R3-08 Memory Copy Consent`, `R5-04 Name Hearing`, `R6-03` | body anchor 하나를 쓰거나 거절하고, boundary를 고치거나, plural identity를 받는다 | body arc state, `continuity_pressure` write, relationship repair/rift |
| `BEAT_13_CROWN_APPROACH` | 14:10–15:10 | `R7` / `RC-07` | `R7-04 Crown Position`, `R7-07 Operator Replacement`, `R7-09 Void Cut Ledger` | 무엇을 지킬지, 무엇을 공개할지, 누가 precedence를 해석할지 결정하고 절단 shape를 contract 조건보다 먼저 그린다 | lens final choice, `G8` precondition, `contract_tally` 생성, ending eligibility 평가 |
| `BEAT_14_ENDING_AFTERMATH` | 15:10–16:10 | 같은 node 재방문 | 선택된 ending의 `CONSEQ_11` + document 1개 | changed prop/NPC/route/record를 확인하고 마지막 document 또는 thread entry를 연 뒤 world frame으로 돌아온다 | ending surface write, 미해결 clock, user-visible aftermath |

baseline 8개 cluster로 끝나는 run은 위 15개 beat에서 끝난다. 아래 `BEAT_15_*`~`BEAT_17_*`는 `07` §14.1의 A1 data-only 조건을 통과한 뒤에 덧붙는 선택 beat이며, baseline 10분 acceptance에는 포함되지 않는다. 이 beat들은 시간을 늘리기 위한 filler가 아니라 `TRUTH_T6`/`TRUTH_T7`의 `actionable` 전환과 `RC-08` resolution을 증명하기 위한 최소 단위다.

| beat ID | target time | node / cluster | authored unit | player action and story information | new system proof / state change |
|---|---:|---|---|---|---|
| `BEAT_15_CRAFT_ENTRY` | A1 +0:00–0:50 | `R5` → `R8` / `RC-08` 진입 | `R5-13 Supply Rack`, `doc_supply_rack_receipt`, `E18` | `G5`가 `full`/`staged`로 Filing된 뒤 `E18`의 gate/resource/epistemic 세 조건을 실물로 확인하고 `R8`에 들어간다 | `craft_credit`/`medium blank`/`fold sheet` 소모, `region_role: magic_training_craft_labor`, `changed_core_files == []` |
| `BEAT_16_COURSE_AND_CONCENTRATION` | A1 +0:50–1:50 | `R8` / `RC-08` | `R8-01 Course Index`, `R8-02 Concentration Registration`, `R8-04 Course Selection` | 지점·시각·측정값·`provenance`을 함께 등록하고 weave/fold/void-cut 중 하나를 기재한다. `mana_profile`이 허용하지 않으면 선택만 되고 실행은 막힌다 | `TRUTH_T6` `corroborated`, `concentration sample` 등록, `blade_credit`/`D` write, `E18` 통과 상태 |
| `BEAT_17_LINEAGE_OR_REFUSAL` | A1 +1:50–2:50 | `R8` / `RC-08` | `R8-03 Lineage Placement`, `R8-05 Fold Failure Hearing`, `R8-07 Lineage Refusal`, `R8-08 Field Probation` | 가문 배정을 받거나 이름 없는 배정함에 넣거나, 실패한 fold를 학교 record로 나눠Filing하거나, 학교 밖 직장으로 나간다 | `TRUTH_T6` `actionable`, `CONSEQ_13`, `CONSEQ_15`, `R4` glossary 충돌, `RC-08` resolution |
| `BEAT_18_CONTRACT_DEBT` | A1 +2:50–3:50 | `R8` → `R7` / `RC-07` 재방문 | `R8-06 Void Contract Filing`, `R7-05 Storm Verge`, `R7-09 Void Cut Ledger` | 다른 차원의 존재와 contract를 맺거나 거부하고, `G8`에서 그 contract를 `crown_protocol` 안과 밖 중 어디에 둘지 명시한다 | `TRUTH_T7` `actionable`, `CONSEQ_14`, `C` interpretation input, `R4-02` 재작성, `ENC-ARPG-25` combat 또는 noncombat withdrawal |

### 17.1 Minimum run과 convergence run

- minimum acceptance run: `HC-00` → `RC-01` → `RC-06` → `RC-02` → `RC-07` → `RC-04` 6개 cluster, document sequence 1개, encounter 1개, partial result 1개, revisit 1개. `R2` 우회는 `02` §6.2 backtracking loop 2(`H0→R2→R6→H0`)를 재사용하므로 추가 이동 time을 만들지 않는다. `07` `RG-M02`의 10 encounter / 18~25분 판정이 mechanics·timing 근거고, 위 cluster 순서가 `END_R1` eligibility의 추가 조건이다.
- convergence run: `HC-00` + `RC-01` + `RC-04` 필수, `RC-02`/`RC-03`/`RC-05`/`RC-06`/`RC-08` 중 3개 이상, `RC-07`에서 분배/seat 결정. `RECOVER`, `RECOGNIZE`, `AUTHORIZE` 세 operation을 서로 다른 authored content로 노출한다. secret flag가 아니고 완벽한 대화 한 번도 필요 없다. `RC-08`이 포함될 때는 `07` `RG-M13`의 A1 no-core-edit 증명이 선행되어야 한다.
- craft run(`ROUTE_CRAFT`): `HC-00` + `RC-02` + `RC-08` 필수, `RC-04` 또는 `RC-05`, 그리고 `RC-03`에서 `E10`으로 `E18` 왕복 leg를 닫는다. `R2`의 `E18` resource gate는 `RC-02`에서 만든 값이므로, `E18`의 resource gate와 `RC-08`의 `provenance`은 서로 다른 record로 남는다(`02` §6.2 loop 8).
- 어느 run도 §0.1의 폐기 surface를 열지 않는다.


## 18. Story completion과 acceptance evidence

story layer는 core combat/input/save algorithm을 새 content ID용으로 수정하지 않고 authored·verified될 때만 implementation-ready다.

- [ ] `Crown of Continuance` object, `Crown Protocol` seat, invariant, `G8`이 stable ID와 읽을 수 있는 document로 표현된다.
- [ ] 9개 cluster 각각이 6~12 core NPC, 2~4 institutions, 2~3 clocks, resource conflict, refusal, delayed consequence를 가진다. 실제 크기는 7/7/7/8/7/7/7/8/7이다.
- [ ] 14 core NPC 전원이 최소 한 cluster에 속하고, 어느 cluster도 6명 미만/12명 초과가 아니며, support resident는 core 수에 포함되지 않는다. 15번째 core `npc_*`는 0개다.
- [ ] 8개 truth 각각이 source, contradiction, `actionable` transition, route effect를 가진다. `TRUTH_T6_CRAFT_IS_LABOR`와 `TRUTH_T7_CUT_IS_A_DEBT`가 `R8`을 방문하지 않아도 `corroborated`가 되는 경로가 존재한다.
- [ ] `rel_*` 14개가 discrete `states[]`, refusal, rupture/repair, ending consequence를 가지며 `rel_09_perrin_ward`만 romance가 닫혀 있다. `rel_*` ID는 `rel_<nn>_<snake>` 형태다.
- [ ] `role_field_investigator`와 `npc_11_cael_ren`, `npc_05_nera_voss`(organ quorum), `npc_01_ilyra_senn`, `npc_06_tamas_quill`, `npc_04_sable_halm`의 body/identity arc가 combat/resource access, recognition, recovery를 실제로 바꾼다.
- [ ] magic body arc 4종(`BODY_ARC_MANA_PROFILE_NOT_MORAL_CLASS`, `BODY_ARC_ORGAN_MEDIUM_RESIDUE`, `BODY_ARC_FAILED_FOLD_TERMINAL`, `BODY_ARC_PORTAL_DEFERRED_SELF`)이 각각 두 surface 이상을 바꾼다.
- [ ] `magic` 하위 record 6종(`concentration_fields`, `body_load`, `circulation`, `crafts`, `contracts`, `glossary`)이 `02` §9.1 정본 token으로Filing되고 `06` save projection allowlist에 등재된다. `mana` 단일 수치 resource와 전역 `concentration` 막대는 0건이다.
- [ ] `documents`·`conversations`·`choices`·`effects`·`props`·`encounters` schema가 validate되고 round-trip한다. page는 9줄을 넘지 않는다.
- [ ] 10분+ 연속 run이 복수 cluster, combat/NPC-boss/noncombat resolution, document corruption, thread decision, partial success, revisit를 포함한다.
- [ ] `RC-08`이 `07` §14.1의 A1 조건을 만족한다: `changed_core_files == []`, `ENC-ARPG-25`와 `region_role: magic_training_craft_labor` 등록, `R8`/NPC/encounter/document/aftermath/H0 service만 추가.
- [ ] 1280×720, 1920×1080, 2560×1440 capture가 world priority, page text bound, choice focus, aftermath state를 보존한다.
- [ ] save/load가 truth evidence, relationship history, body anchor, clocks, route flags, pending consequence, recovery lineage, `magic` record를 보존하고 presentation focus는 transient다. `contract_tally`과 `glossary` filled slot은 checkpoint 뒤에도 남는다.
- [ ] 새 story cluster가 data/scene만으로 추가되고 combat parser/evaluator, input routing, save codec, registry algorithm이 바뀌지 않는다.
- [ ] 6개 ending이 §16.8 matrix대로 authored catalog에 존재하고 미해소 combination이 `END_C2_LAST_WITNESS`로 떨어진다. ending content ID가 `06` §3.5.6과 1:1이다.
- [ ] seed register 160행이 전부 `PLANNED_RETAINED`이고 row마다 서로 다른 대상 cross-link 2개 이상, immediate 1개, delayed 1개가 있다. `res_*` 또는 `magic` record를 읽거나 쓰지 않는 magic row 0건, `R8`에만 묶인 magic row 0건, clock write 없는 magic row 0건이다.
- [ ] 최종 상태는 자동·수동 검사 후 **검토 준비 완료**이며 user play review 전 최종 완료를 주장하지 않는다.

## 19. Hard prohibition

- 원작 BLACK SOULS 2의 이름, lore, text, map order, document content, asset, 수치, ending beat을 사용하지 않는다.
- 앨리스 content, 이름만 바꾼 앨리스 content, 변환된 앨리스 character/event/asset을 사용하지 않는다.
- 거대한 dialogue script, quest-flag parade, one-key route gate, all-NPC meeting, single global danger bar를 만들지 않는다.
- body horror를 spectacle, shock image, transformation reward로 쓰지 않는다. 모든 body change는 consent, state, resource, recognition, delayed consequence를 가진다.
- romance reward for sex, explicit sexual content, coercive intimacy, possession disguised as affection를 만들지 않는다.
- random corruption, red-only critical information, 접근 불가능한 focus, 지원 해상도를 넘는 document text를 만들지 않는다. disabled/unavailable choice도 focusable하며 focus와 disabled state를 별도로 표시한다.
- 상시 Shell HUD, menu/journal button, location label, autosave label, key instruction, debug label, placeholder ColorRect/Label로 만든 world를 만들지 않는다.
- "secret truth flag" ending, route content를 core에 hardcode, walking/waiting/repeated input/dialogue volume로 10분을 채우는 행위를 금지한다.
- 이 문서가 story/content 소유 경계 밖의 구현 edit을 승인하지 않는다.
- 8번째 recovery type을 만들지 않는다. `crown_alignment`는 world write다. magic failure를 recovery type으로 만들지 않는다.
- 별도 3-value axis ladder를 이 문서 안에 두지 않는다. 5번째 축(`concentration`, `craft mastery`, `magic`)을 두지 않는다.
- 7번째 pressure clock을 만들지 않는다. magic pressure는 기존 6개 clock의 입력값이다.
- 10번째 route edge나 10번째 gate를 만들지 않는다. `E18`이 마지막 edge이고 `G5`가 `E18`의 유일한 gate다. `G9`를 만들지 않는다.
- 10번째 authored cluster를 만들지 않는다. `RC-08`이 마지막 cluster다. 6명 미만 또는 12명 초과의 cluster를 만들지 않는다.
- magic 이론의 positive label을 이 문서나 module script에 하드코딩하지 않는다. `glossary` slot이 비어 있으면 `untranslated term`으로 Filing한다.
- `mana` 단일 수치, 전역 `concentration` 막대, magic XP bar를 만들지 않는다. 실패한 cast가 `K`·`P`·`R`을 동시에 전진시키지 않게 하고, `C`가 contract 하나로 전진하지 않게 한다(`02` §4.4).
- `R8`/`RC-08` 추가를 핑계로 core system·loader·save codec·target enum을 수정하지 않는다.
- magic failure를 이유로 NPC를 romance/affection route에서 자동 배제하지 않는다. consent, recovery, shared choice를 authored data로 다룬다.
- 계획 단계에서 seed를 `used`/`transformed`로 승격하거나 완료 증거로 인용하지 않는다.


## 20. Idea Ledger transformation register

이 register는 planning-level use만 기록한다. 상태는 160행 전부 `PLANNED_RETAINED`이며, 이는 TIN 구조 binding이 **예정되었다**는 뜻이지 대응 장면이 구현되었다는 뜻이 아니다. `used`/`transformed` 승격은 구현·검수 후 `06` §13.6 절차로 사람이 한다.

- denominator: 160 independent idea unit — core 120(`S001`~`S120`) + magic supplement 40(`S121`~`S160`)
- hard gate: 96 distinct `PLANNED_RETAINED` transform (정수 비교, 60%)
- preferred target: 120 (75%)
- 이 표가 예약한 planned row: **160 / 160 planned, not used**
- 160/160은 **planned target**이다. 게이트 통과나 구현 완료를 뜻하지 않는다.

표 규칙:

- `unit`은 `02` §11.2의 transformation unit `X01`~`X36`이다. core는 `X01`~`X26`, magic supplement는 `X27`~`X36`이다.
- `link A`는 `02` §7의 region content family(`region` kind)이고, `link B`는 그 family를 실행하는 core NPC(`npc` kind)다. 두 대상의 kind가 다르므로 `06` §13.3의 `cross_link_a.kind != cross_link_b.kind`를 만족한다. `cluster`는 그 family가 수행되는 `HC-00`/`RC-01`~`RC-08`(`phase` kind)이며 세 번째 cross-link로 함께 검증된다.
- `I → D`는 `02` §11.2의 unit 단위 immediate → delayed consequence다. seed별 문구는 authored `seeds` content 작성 시 family 기준으로 세분화한다.
- `gate`는 `06` §13.2의 요구 gate다. `g1..g8`은 ROOT/SYSTEM/MODULE/ONEOFF, `g1,g2,g7,g8`은 TONE. CANDIDATE/DROP은 이 표에 없다.
- 어떤 row도 이름·문장만 바꾼 reskin이 아니다. `generic-risk`는 `g7`(`name_swap_still_specific`)과 `g8`(`not_weirdness_only`)로 강제한다.
- magic row(`S121`~`S160`)는 `02` §11.4의 추가 gate를 함께 만족한다: `res_*` 또는 `magic` record를 하나 이상 읽거나 쓴다, `R8` family에만 묶이지 않는다, `02` §4.4 표의 clock write가 하나 이상 있다. `I → D` 칸에는 그 clock write가 명시되어 있다.

| seed | status | unit | link A — region family (`02` §7) | link B — core NPC (`04` §2) | cluster | I → D (`02` §11.2) | gate |
|---|---|---|---|---|---|---|---|
| `S001` | PLANNED_RETAINED | X01 | `R7-04 Crown Position` | `npc_12_ravenna_holt` | `RC-07` | 왕관 object/office/invariant가 동시에 드러나고, 이후 operator가 누적 continuity debt를 물려받는다 | g1..g8 |
| `S002` | PLANNED_RETAINED | X01 | `R7-07 Operator Replacement` | `npc_11_cael_ren` | `RC-07` | 동일 | g1..g8 |
| `S003` | PLANNED_RETAINED | X01 | `R4-07 Operator Trial` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1..g8 |
| `S004` | PLANNED_RETAINED | X01 | `R6-01 Organ Intake` | `npc_05_nera_voss` | `RC-06` | 동일 | g1..g8 |
| `S005` | PLANNED_RETAINED | X02 | `R2-04 Same Body Census` | `npc_11_cael_ren` | `RC-02` | category·recovery 선택이 lineage를 갈리고 다음 region의 legal name을 바꾼다 | g1..g8 |
| `S006` | PLANNED_RETAINED | X02 | `R4-01 Translation Desk` | `npc_06_tamas_quill` | `RC-04` | 동일 | g1..g8 |
| `S007` | PLANNED_RETAINED | X02 | `H0-03 Return Hearing` | `npc_03_veya_morcant` | `HC-00` | 동일 | g1..g8 |
| `S008` | PLANNED_RETAINED | X02 | `R1-04 Continuation Trial` | `npc_02_orrin_kest` | `RC-01` | 동일 | g1..g8 |
| `S009` | PLANNED_RETAINED | X03 | `R1-02 Door Role Test` | `npc_02_orrin_kest` | `RC-01` | recovery space를 열면 institutional stamp가 붙고 route가 닫힐 때 다른 institution이 대신 개입한다 | g1..g8 |
| `S010` | PLANNED_RETAINED | X03 | `R7-01 Wall Phase Survey` | `npc_07_bryn_oskel` | `RC-07` | 동일 | g1..g8 |
| `S011` | PLANNED_RETAINED | X03 | `R1-06 Registry Interrogation` | `npc_02_orrin_kest` | `RC-01` | 동일 | g1..g8 |
| `S012` | PLANNED_RETAINED | X03 | `R3-01 Intake Triage` | `npc_09_perrin_lask` | `RC-03` | 동일 | g1..g8 |
| `S013` | PLANNED_RETAINED | X04 | `R3-02 Latency Bell` | `npc_04_sable_halm` | `RC-03` | care window와 contamination trace가 바뀌고 장기간 failure는 다음 institution의 staffing/resource demand로 누적된다 | g1..g8 |
| `S014` | PLANNED_RETAINED | X04 | `R3-02 Latency Bell` | `npc_04_sable_halm` | `RC-03` | 동일 | g1..g8 |
| `S015` | PLANNED_RETAINED | X04 | `R1-06 Registry Interrogation` | `npc_02_orrin_kest` | `RC-01` | 동일 | g1..g8 |
| `S016` | PLANNED_RETAINED | X04 | `H0-05 Crier Thread` | `npc_10_juno_caster` | `HC-00` | 동일 | g1,g2,g7,g8 |
| `S017` | PLANNED_RETAINED | X04 | `R2-05 Harvest Failure` | `npc_08_meral_dune` | `RC-02` | 동일 | g1..g8 |
| `S018` | PLANNED_RETAINED | X04 | `R4-03 Public Hall Copy` | `npc_10_juno_caster` | `RC-04` | 동일 | g1..g8 |
| `S019` | PLANNED_RETAINED | X05 | `R4-02 Contradictory Record` | `npc_01_ilyra_senn` | `RC-04` | report가 filing되면 gate가 바뀌고 incomplete stage는 delayed maintenance/encounter를 만든다 | g1,g2,g7,g8 |
| `S020` | PLANNED_RETAINED | X05 | `R5-02 Boot Sequence` | `npc_04_sable_halm` | `RC-05` | 동일 | g1..g8 |
| `S021` | PLANNED_RETAINED | X05 | `R5-01 Boot Contract` | `npc_04_sable_halm` | `RC-05` | 동일 | g1..g8 |
| `S022` | PLANNED_RETAINED | X05 | `R5-02 Boot Sequence` | `npc_04_sable_halm` | `RC-05` | 동일 | g1..g8 |
| `S023` | PLANNED_RETAINED | X05 | `R5-06 Formation Failure` | `npc_04_sable_halm` | `RC-05` | 동일 | g1..g8 |
| `S024` | PLANNED_RETAINED | X05 | `R5-06 Formation Failure` | `npc_04_sable_halm` | `RC-05` | 동일 | g1,g2,g7,g8 |
| `S025` | PLANNED_RETAINED | X06 | `R6-06 Body Authority Registry` | `npc_05_nera_voss` | `RC-06` | log가 Filing되면 NPC가 새 role로 호명되고 care contract가 delayed recognition을 만든다 | g1..g8 |
| `S026` | PLANNED_RETAINED | X06 | `R5-04 Name Hearing` | `npc_09_perrin_lask` | `RC-05` | 동일 | g1..g8 |
| `S027` | PLANNED_RETAINED | X06 | `R3-05 Mercy Engine Test` | `npc_14_eda_marrow` | `RC-03` | 동일 | g1..g8 |
| `S028` | PLANNED_RETAINED | X07 | `R6-05 Organ Chorus Trial` | `npc_05_nera_voss` | `RC-06` | organ signature가 custody와 route를 바꾸고 bypass는 symptom을 줄이는 대신 continuity debt를 남긴다 | g1..g8 |
| `S029` | PLANNED_RETAINED | X07 | `R6-03 Heart Petition` | `npc_05_nera_voss` | `RC-06` | 동일 | g1..g8 |
| `S030` | PLANNED_RETAINED | X07 | `R3-06 Organ Complaint Hearing` | `npc_05_nera_voss` | `RC-03` | 동일 | g1..g8 |
| `S031` | PLANNED_RETAINED | X07 | `R1-04 Continuation Trial` | `npc_11_cael_ren` | `RC-01` | 동일 | g1..g8 |
| `S032` | PLANNED_RETAINED | X08 | `R2-04 Same Body Census` | `npc_11_cael_ren` | `RC-02` | clone 수와 loop 선택이 resource와 operator claim에 영향을 주고 다음 region에서 social cost가 나타난다 | g1..g8 |
| `S033` | PLANNED_RETAINED | X08 | `R2-05 Harvest Failure` | `npc_08_meral_dune` | `RC-02` | 동일 | g1..g8 |
| `S034` | PLANNED_RETAINED | X08 | `R1-04 Continuation Trial` | `npc_11_cael_ren` | `RC-01` | 동일 | g1..g8 |
| `S035` | PLANNED_RETAINED | X08 | `R7-07 Operator Replacement` | `npc_12_ravenna_holt` | `RC-07` | 동일 | g1..g8 |
| `S036` | PLANNED_RETAINED | X09 | `R6-03 Heart Petition` | `npc_05_nera_voss` | `RC-06` | 한 줄 organ voice가 negotiation을 뒤집고 long-horizon projection은 다음 resource deadline을 만든다 | g1,g2,g7,g8 |
| `S037` | PLANNED_RETAINED | X09 | `R6-03 Heart Petition` | `npc_05_nera_voss` | `RC-06` | 한 줄 organ voice가 negotiation을 뒤집고 long-horizon projection은 다음 resource deadline을 만든다 | g1..g8 |
| `S038` | PLANNED_RETAINED | X09 | `R6-01 Organ Intake` | `npc_13_tovan_reed` | `RC-06` | 동일 | g1..g8 |
| `S039` | PLANNED_RETAINED | X09 | `H0-01 Arrival Docket` | `npc_02_orrin_kest` | `HC-00` | 동일 | g1,g2,g7,g8 |
| `S040` | PLANNED_RETAINED | X09 | `R6-04 Debt Surgery` | `npc_14_eda_marrow` | `RC-06` | 동일 | g1..g8 |
| `S041` | PLANNED_RETAINED | X10 | `R6-04 Debt Surgery` | `npc_13_tovan_reed` | `RC-06` | category가 Filing되면 care access와 trust가 갈라지고 legal danger가 route permission을 바꾼다 | g1,g2,g7,g8 |
| `S042` | PLANNED_RETAINED | X10 | `R5-04 Name Hearing` | `npc_09_perrin_lask` | `RC-05` | 동일 | g1..g8 |
| `S043` | PLANNED_RETAINED | X10 | `R4-03 Public Hall Copy` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1,g2,g7,g8 |
| `S044` | PLANNED_RETAINED | X10 | `R4-07 Operator Trial` | `npc_03_veya_morcant` | `RC-04` | 동일 | g1..g8 |
| `S045` | PLANNED_RETAINED | X10 | `R3-01 Intake Triage` | `npc_09_perrin_lask` | `RC-03` | 동일 | g1..g8 |
| `S046` | PLANNED_RETAINED | X10 | `R2-08 Settlement Vote` | `npc_14_eda_marrow` | `RC-02` | 동일 | g1..g8 |
| `S047` | PLANNED_RETAINED | X11 | `H0-05 Crier Thread` | `npc_10_juno_caster` | `HC-00` | rumor이 canonical copy를 앞지르면 public record clock이 전진하고 짧은 interruption이 긴 설명을 취소한다 | g1,g2,g7,g8 |
| `S048` | PLANNED_RETAINED | X11 | `H0-05 Crier Thread` | `npc_10_juno_caster` | `HC-00` | 동일 | g1,g2,g7,g8 |
| `S049` | PLANNED_RETAINED | X11 | `R5-01 Boot Contract` | `npc_04_sable_halm` | `RC-05` | 동일 | g1..g8 |
| `S050` | PLANNED_RETAINED | X11 | `R4-01 Translation Desk` | `npc_06_tamas_quill` | `RC-04` | 동일 | g1,g2,g7,g8 |
| `S051` | PLANNED_RETAINED | X12 | `R7-07 Operator Replacement` | `npc_12_ravenna_holt` | `RC-07` | operator claim이 Filing되면 title과 body가 갈라지고 다음 precedence dispute가 시작된다 | g1..g8 |
| `S052` | PLANNED_RETAINED | X12 | `R4-06 Crown Fragment` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1..g8 |
| `S053` | PLANNED_RETAINED | X12 | `R4-07 Operator Trial` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1..g8 |
| `S054` | PLANNED_RETAINED | X12 | `H0-03 Return Hearing` | `npc_11_cael_ren` | `HC-00` | 동일 | g1..g8 |
| `S055` | PLANNED_RETAINED | X12 | `R7-04 Crown Position` | `npc_01_ilyra_senn` | `RC-07` | 동일 | g1..g8 |
| `S056` | PLANNED_RETAINED | X13 | `R4-02 Contradictory Record` | `npc_01_ilyra_senn` | `RC-04` | record가 Filing되면 category가 굳고 vertical route와 operator replacement가 topology를 바꾼다 | g1..g8 |
| `S057` | PLANNED_RETAINED | X13 | `H0-01 Arrival Docket` | `npc_03_veya_morcant` | `HC-00` | 동일 | g1,g2,g7,g8 |
| `S058` | PLANNED_RETAINED | X13 | `R4-04 Weight Lift` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1..g8 |
| `S059` | PLANNED_RETAINED | X13 | `R4-01 Translation Desk` | `npc_06_tamas_quill` | `RC-04` | 동일 | g1..g8 |
| `S060` | PLANNED_RETAINED | X13 | `R7-04 Crown Position` | `npc_12_ravenna_holt` | `RC-07` | 동일 | g1..g8 |
| `S061` | PLANNED_RETAINED | X14 | `R2-05 Harvest Failure` | `npc_08_meral_dune` | `RC-02` | resource extraction이 climate와 social order를 바꾸고 마지막 medicine가 여러 region에 delayed pressure를 만든다 | g1..g8 |
| `S062` | PLANNED_RETAINED | X14 | `R2-03 Root Bridge Survey` | `npc_07_bryn_oskel` | `RC-02` | 동일 | g1..g8 |
| `S063` | PLANNED_RETAINED | X14 | `R2-04 Same Body Census` | `npc_10_juno_caster` | `RC-02` | 동일 | g1..g8 |
| `S064` | PLANNED_RETAINED | X14 | `R2-01 Water Round` | `npc_14_eda_marrow` | `RC-02` | 동일 | g1..g8 |
| `S065` | PLANNED_RETAINED | X15 | `R2-08 Settlement Vote` | `npc_08_meral_dune` | `RC-02` | 숫자와 계산이 allocation을 Filing하고 knowledge를 나눈 settlement만 다음 phase에 생존한다 | g1,g2,g7,g8 |
| `S066` | PLANNED_RETAINED | X15 | `R2-01 Water Round` | `npc_08_meral_dune` | `RC-02` | 동일 | g1..g8 |
| `S067` | PLANNED_RETAINED | X15 | `R2-07 Seed Vault Exchange` | `npc_14_eda_marrow` | `RC-02` | 동일 | g1..g8 |
| `S068` | PLANNED_RETAINED | X15 | `R2-08 Settlement Vote` | `npc_14_eda_marrow` | `RC-02` | 동일 | g1,g2,g7,g8 |
| `S069` | PLANNED_RETAINED | X16 | `R4-01 Translation Desk` | `npc_06_tamas_quill` | `RC-04` | 잘못된 해석이 route를 열거나 닫고 raw observation을 가진 player는 이미 아는 규칙을 즉시 실행할 수 있다 | g1..g8 |
| `S070` | PLANNED_RETAINED | X16 | `R4-01 Translation Desk` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1..g8 |
| `S071` | PLANNED_RETAINED | X16 | `R4-01 Translation Desk` | `npc_06_tamas_quill` | `RC-04` | 동일 | g1,g2,g7,g8 |
| `S072` | PLANNED_RETAINED | X16 | `R4-07 Operator Trial` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1..g8 |
| `S073` | PLANNED_RETAINED | X16 | `R4-02 Contradictory Record` | `npc_10_juno_caster` | `RC-04` | 동일 | g1..g8 |
| `S074` | PLANNED_RETAINED | X17 | `R4-01 Translation Desk` | `npc_06_tamas_quill` | `RC-04` | term이 category와 operator를 바꾸고 outsider observation이 `RC-07`의 crown interpretation에 delayed evidence가 된다 | g1..g8 |
| `S075` | PLANNED_RETAINED | X17 | `R4-03 Public Hall Copy` | `npc_10_juno_caster` | `RC-04` | 동일 | g1,g2,g7,g8 |
| `S076` | PLANNED_RETAINED | X17 | `R7-01 Wall Phase Survey` | `npc_07_bryn_oskel` | `RC-07` | 동일 | g1..g8 |
| `S077` | PLANNED_RETAINED | X17 | `R2-04 Same Body Census` | `npc_11_cael_ren` | `RC-02` | 동일 | g1..g8 |
| `S078` | PLANNED_RETAINED | X17 | `R6-06 Body Authority Registry` | `npc_05_nera_voss` | `RC-06` | 동일 | g1,g2,g7,g8 |
| `S079` | PLANNED_RETAINED | X18 | `R6-04 Debt Surgery` | `npc_13_tovan_reed` | `RC-06` | operation이 discharge와 archive record를 만들고 bypass는 symptom이 줄어도 body/social split을 남긴다 | g1..g8 |
| `S080` | PLANNED_RETAINED | X18 | `R6-04 Debt Surgery` | `npc_05_nera_voss` | `RC-06` | 동일 | g1..g8 |
| `S081` | PLANNED_RETAINED | X18 | `R6-06 Body Authority Registry` | `npc_05_nera_voss` | `RC-06` | 동일 | g1,g2,g7,g8 |
| `S082` | PLANNED_RETAINED | X18 | `R6-03 Heart Petition` | `npc_06_tamas_quill` | `RC-06` | 동일 | g1..g8 |
| `S083` | PLANNED_RETAINED | X18 | `R1-04 Continuation Trial` | `npc_02_orrin_kest` | `RC-01` | 동일 | g1..g8 |
| `S084` | PLANNED_RETAINED | X19 | `R6-03 Heart Petition` | `npc_05_nera_voss` | `RC-06` | complaint가 signature를 바꾸고 transformation choice가 relationship과 legal route를 동시에 열거나 닫는다 | g1..g8 |
| `S085` | PLANNED_RETAINED | X19 | `R3-06 Organ Complaint Hearing` | `npc_14_eda_marrow` | `RC-03` | 동일 | g1,g2,g7,g8 |
| `S086` | PLANNED_RETAINED | X19 | `R5-04 Name Hearing` | `npc_04_sable_halm` | `RC-05` | 동일 | g1..g8 |
| `S087` | PLANNED_RETAINED | X19 | `R6-05 Organ Chorus Trial` | `npc_05_nera_voss` | `RC-06` | 동일 | g1..g8 |
| `S088` | PLANNED_RETAINED | X20 | `R3-05 Mercy Engine Test` | `npc_04_sable_halm` | `RC-03` | job/contract가 care access와 combat route를 바꾸고 obligation을 거부하면 `H0` debt가 Filing된다 | g1..g8 |
| `S089` | PLANNED_RETAINED | X20 | `R5-07 Labor Walkout` | `npc_14_eda_marrow` | `RC-05` | 동일 | g1..g8 |
| `S090` | PLANNED_RETAINED | X20 | `H0-06 Care Notice` | `npc_14_eda_marrow` | `HC-00` | 동일 | g1..g8 |
| `S091` | PLANNED_RETAINED | X20 | `R5-04 Name Hearing` | `npc_09_perrin_lask` | `RC-05` | 동일 | g1..g8 |
| `S092` | PLANNED_RETAINED | X20 | `R6-04 Debt Surgery` | `npc_13_tovan_reed` | `RC-06` | 동일 | g1..g8 |
| `S093` | PLANNED_RETAINED | X21 | `R2-05 Harvest Failure` | `npc_08_meral_dune` | `RC-02` | 각 content family가 다른 axis를 쓰며 다음 region의 protocol이 cross-link를 요구한다 | g1..g8 |
| `S094` | PLANNED_RETAINED | X21 | `R5-02 Boot Sequence` | `npc_04_sable_halm` | `RC-05` | 동일 | g1..g8 |
| `S095` | PLANNED_RETAINED | X21 | `R3-02 Latency Bell` | `npc_04_sable_halm` | `RC-03` | 동일 | g1..g8 |
| `S096` | PLANNED_RETAINED | X21 | `R2-05 Harvest Failure` | `npc_14_eda_marrow` | `RC-02` | 동일 | g1..g8 |
| `S097` | PLANNED_RETAINED | X21 | `R4-02 Contradictory Record` | `npc_06_tamas_quill` | `RC-04` | 동일 | g1..g8 |
| `S098` | PLANNED_RETAINED | X22 | `R6-01 Organ Intake` | `npc_05_nera_voss` | `RC-06` | testimony가 filed되면 public classification과 physical edge가 동시에 바뀐다 | g1..g8 |
| `S099` | PLANNED_RETAINED | X22 | `R4-06 Crown Fragment` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1..g8 |
| `S100` | PLANNED_RETAINED | X22 | `H0-05 Crier Thread` | `npc_10_juno_caster` | `HC-00` | 동일 | g1..g8 |
| `S101` | PLANNED_RETAINED | X23 | `H0-01 Arrival Docket` | `npc_02_orrin_kest` | `HC-00` | 질문·form·schedule가 route category를 뒤집고 다음 institution이 그 결정을 실제로 적용한다 | g1..g8 |
| `S102` | PLANNED_RETAINED | X23 | `R5-04 Name Hearing` | `npc_09_perrin_lask` | `RC-05` | 동일 | g1..g8 |
| `S103` | PLANNED_RETAINED | X23 | `R1-04 Continuation Trial` | `npc_13_tovan_reed` | `RC-01` | 동일 | g1..g8 |
| `S104` | PLANNED_RETAINED | X23 | `R6-03 Heart Petition` | `npc_05_nera_voss` | `RC-06` | 동일 | g1..g8 |
| `S105` | PLANNED_RETAINED | X24 | `R5-05 Care Shift` | `npc_05_nera_voss` | `RC-05` | legal name과 affection 선택이 Filing되고 `H0` route debt와 `RC-07` witness evidence가 delayed consequence로 남는다 | g1..g8 |
| `S106` | PLANNED_RETAINED | X24 | `R2-04 Same Body Census` | `npc_11_cael_ren` | `RC-02` | 동일 | g1..g8 |
| `S107` | PLANNED_RETAINED | X24 | `R4-03 Public Hall Copy` | `npc_01_ilyra_senn` | `RC-04` | 동일 | g1..g8 |
| `S108` | PLANNED_RETAINED | X24 | `R7-04 Crown Position` | `npc_12_ravenna_holt` | `RC-07` | 동일 | g1..g8 |
| `S109` | PLANNED_RETAINED | X24 | `R2-08 Settlement Vote` | `npc_08_meral_dune` | `RC-02` | 동일 | g1..g8 |
| `S110` | PLANNED_RETAINED | X24 | `R7-01 Wall Phase Survey` | `npc_07_bryn_oskel` | `RC-07` | 동일 | g1..g8 |
| `S111` | PLANNED_RETAINED | X25 | `R1-02 Door Role Test` | `npc_07_bryn_oskel` | `RC-01` | manual compliance가 encounter signature를 바꾸고 screenshot/recognition failure가 public record와 NPC action을 분리한다 | g1..g8 |
| `S112` | PLANNED_RETAINED | X25 | `R6-05 Organ Chorus Trial` | `npc_05_nera_voss` | `RC-06` | 동일 | g1..g8 |
| `S113` | PLANNED_RETAINED | X25 | `R5-04 Name Hearing` | `npc_04_sable_halm` | `RC-05` | 동일 | g1..g8 |
| `S114` | PLANNED_RETAINED | X25 | `H0-05 Crier Thread` | `npc_10_juno_caster` | `HC-00` | 동일 | g1..g8 |
| `S115` | PLANNED_RETAINED | X25 | `R1-01 Misreturned Person` | `npc_11_cael_ren` | `RC-01` | 동일 | g1..g8 |
| `S116` | PLANNED_RETAINED | X26 | `R4-06 Crown Fragment` | `npc_01_ilyra_senn` | `RC-04` | precedence, topology, relationship, public record가 동시에 delayed write를 예약하며 final cluster가 세 report를 모두 보존한다 | g1..g8 |
| `S117` | PLANNED_RETAINED | X26 | `R2-03 Root Bridge Survey` | `npc_08_meral_dune` | `RC-02` | 동일 | g1..g8 |
| `S118` | PLANNED_RETAINED | X26 | `R5-08 Partner Permission` | `npc_05_nera_voss` | `RC-05` | 동일 | g1..g8 |
| `S119` | PLANNED_RETAINED | X26 | `H0-01 Arrival Docket` | `npc_03_veya_morcant` | `HC-00` | 동일 | g1..g8 |
| `S120` | PLANNED_RETAINED | X26 | `H0-05 Crier Thread` | `npc_14_eda_marrow` | `HC-00` | 동일 | g1..g8 |
| `S121` | PLANNED_RETAINED | X27 | `R8-02 Concentration Registration` | `npc_01_ilyra_senn` | `RC-08` | 마나를 원소/미발견 화합물로 확정하지 않고 `concentration` 공통 contract와 여러 물질 모델을 허용한다. measurement 하나(`res_concentration_sample`)가 `E18` 비용과 `R2` `K`/`E` write를 함께 정하고, `R4-02`와 같은 category error record를 만든다 | g1..g8 |
| `S122` | PLANNED_RETAINED | X27 | `R8-04 Course Selection` | `npc_04_sable_halm` | `RC-08` | 농도가 efficiency와 training을 동시에 올리다가 threshold를 넘으면 `K contamination`이 전진하고 `D`(`res_medium_blank`)가 소모된다. `R5-01` boot 조건과 `R8-04` 선택지가 함께 좁혀진다 | g1..g8 |
| `S123` | PLANNED_RETAINED | X27 | `R2-09 Disperser Reading` | `npc_08_meral_dune` | `RC-02` | threshold 초과가 `K`를 한 단계 올리고 해당 region/path의 safe lane 판정을 바꾼다. `E`는 별도 transaction에서만 전진한다 | g1..g8 |
| `S124` | PLANNED_RETAINED | X27 | `R7-01 Wall Phase Survey` | `npc_07_bryn_oskel` | `RC-07` | 산이 평지로 읽히는 지형 anomaly가 `B recognition_drift` disputed claim을 만들고, `R7` survey와 `R2` root bridge의 해석이 갈라진다. raw 관찰을 가진 player는 재발견 없이 즉시 실행한다 | g1..g8 |
| `S125` | PLANNED_RETAINED | X27 | `H0-05 Crier Thread` | `npc_10_juno_caster` | `HC-00` | 위험한 현상을 "자연마법"으로 즉시 정당화하는 기관 voice가 `R public_record`를 전진시킨다. 같은 사건이 세 report로 Filing되면 `CL-REC` canonical 단계에 도달한다 | g1,g2,g7,g8 |
| `S126` | PLANNED_RETAINED | X28 | `R2-09 Disperser Reading` | `npc_08_meral_dune` | `RC-02` | `humidifier`/`disperser`가 `res_disperser_charge`를 만들고 `E`를 소모한다. dispersal maintenance가 없으면 `K`가 되돌아오며, `R2-10` 배정이 `E18` 통과를 만든다 | g1..g8 |
| `S127` | PLANNED_RETAINED | X28 | `R2-10 Circulator Ledger` | `npc_08_meral_dune` | `RC-02` | `circulator`가 `K`를 낮추는 대신 이웃 정착지에 오염을 Filing하고 `E`를 소모한다. `res_circulation_slot`이 `E18` resource gate가 되고 감소는 "해결"로 기록되지 않는다 | g1..g8 |
| `S128` | PLANNED_RETAINED | X28 | `R3-01 Intake Triage` | `npc_13_tovan_reed` | `RC-03` | 발출만 되고 저장은 되지 않는 `mana_profile`이 care window가 아니라 emission capacity로 분류되어 `R5-01` boot 조건을 좁힌다. `P personal_collapse`가 첫 write가 된다 | g1..g8 |
| `S129` | PLANNED_RETAINED | X29 | `R3-05 Mercy Engine Test` | `npc_05_nera_voss` | `RC-03` | 축적 안 되는 사람과 과잉 축적되는 사람을 moral class가 아니라 resource class로 적어 `B` disputed claim을 만든다. profile이 `R5-01`/`R8-04`의 선택지를 함께 좁힌다 | g1..g8 |
| `S130` | PLANNED_RETAINED | X29 | `R7-01 Wall Phase Survey` | `npc_07_bryn_oskel` | `RC-07` | 극단 농도 지형이 region hazard가 되어 `K`와 `E`를 함께 읽는다. `R7-01`의 phase 표기와 `R2`의 농도 표기가 서로 다른 document로 남는다 | g1..g8 |
| `S131` | PLANNED_RETAINED | X29 | `R3-06 Organ Complaint Hearing` | `npc_05_nera_voss` | `RC-03` | 마나가 뇌/면역을 손상시키거나 각성시키며 `C continuity_pressure`를 `branched`로 이동시킨다. 손상은 `K`, 각성은 `P`에 각각 다른 write로 남는다 | g1..g8 |
| `S132` | PLANNED_RETAINED | X29 | `R6-01 Organ Intake` | `npc_13_tovan_reed` | `RC-06` | 체로 배출하는 cleansing 능력이 medicine 선행분을 대체하고 `magic.body_load`에 손상을 남긴다. 배출분 회수가 `R5-03`의 회수 대상이 되고 `E` medicine 재고가 줄어든다 | g1..g8 |
| `S133` | PLANNED_RETAINED | X30 | `R8-05 Fold Failure Hearing` | `npc_04_sable_halm` | `RC-08` | 실패가 cognition/competence를 잃어 `terminal` 등급이 되고 `R5-11` cast가 닫힌다. `P`(학생 role)와 `R`(학교 record)만 전진하고 학생은 제거되지 않는다 | g1..g8 |
| `S134` | PLANNED_RETAINED | X30 | `R8-08 Field Probation` | `npc_14_eda_marrow` | `RC-08` | 플라스틱 시대를 지난 post-human/material era가 `RC-08`의 deep-era record로 읽히고, 학교 밖 실습이 labor record와 course record를 갈라놓는다. `A`는 `contested`, `D`는 medium 소모로 남는다 | g1..g8 |
| `S135` | PLANNED_RETAINED | X30 | `R8-03 Lineage Placement` | `npc_09_perrin_lask` | `RC-08` | 방향성으로 빠른 수련이 유전 marker를 깨우며 `C continuity_pressure`를 `linked`로 올린다. 이름 없는 배정함을 고르면 `C`는 오르지 않고 `A`만 `contested`가 된다 | g1..g8 |
| `S136` | PLANNED_RETAINED | X30 | `R8-03 Lineage Placement` | `npc_09_perrin_lask` | `RC-08` | 후성 유전 직업 전문 가문이 `res_lineage_token`을 외부에 닫아 `A`가 `contested`가 되고 `R8` region state가 `I institutional_response` intervention stage에 도달한다 | g1..g8 |
| `S137` | PLANNED_RETAINED | X31 | `R8-01 Course Index` | `npc_14_eda_marrow` | `RC-08` | 마법을 발명한 자가 예술가/functional artisan로 먼저 불리는 class inversion이 `A`와 `D`에 동시에 쓰인다. `course index`가 그 이름과 `craft credit`를 함께 만든다 | g1..g8 |
| `S138` | PLANNED_RETAINED | X31 | `R8-04 Course Selection` | `npc_09_perrin_lask` | `RC-08` | craft 유행이 마을과 노동시장을 바꾸고 `R8-08 Field Probation`에서 학교 밖 실습이 course record와 labor record를 갈라놓는다. `A`는 `provisional`에 머문다 | g1..g8 |
| `S139` | PLANNED_RETAINED | X31 | `R8-08 Field Probation` | `npc_14_eda_marrow` | `RC-08` | 소규모 artisan 집단이 주류에 이용당하며 `R5-07 Labor Walkout`이 학교 밖에서 실행되고 `H0` route debt가 Filing된다. `E resource_collapse`는 학생 인원으로만 반응한다 | g1..g8 |
| `S140` | PLANNED_RETAINED | X31 | `R5-07 Labor Walkout` | `npc_14_eda_marrow` | `RC-05` | 방랑 마법사/마법학원/귀족의 노예/직업 전환가로 social branch가 분화하고 refusal branch가 `P`와 `A`를 함께 움직인다 | g1..g8 |
| `S141` | PLANNED_RETAINED | X32 | `R8-04 Course Selection` | `npc_01_ilyra_senn` | `RC-08` | 마법학원 학생이 protagonist가 될 수 있으나 유일한 canon이 아니다. 선택지는 `R5-01` boot와 `R8-04` course 양쪽에 동시에 Filing되어 어느 쪽도 우선하지 않는다 | g1..g8 |
| `S142` | PLANNED_RETAINED | X32 | `R8-03 Lineage Placement` | `npc_04_sable_halm` | `RC-08` | 수련이 특정 유전 marker를 활성화해 `B`가 `operator`가 아닌 `apprentice` category로 Filing된다. `C linked`와 `A contested`가 동시에 성립한다 | g1..g8 |
| `S143` | PLANNED_RETAINED | X32 | `R8-07 Lineage Refusal` | `npc_09_perrin_lask` | `RC-08` | 가문 magic가 미정형 craft를 보존해 `res_lineage_token`을 발급하고 `C linked`가 되지만 `A`는 `contested`에 남는다. 거부하면 확산이 institution 밖에서 진행된다 | g1..g8 |
| `S144` | PLANNED_RETAINED | X32 | `R8-07 Lineage Refusal` | `npc_09_perrin_lask` | `RC-08` | 가문 magic가 특정 가문만 쓰는 access gate로 작동해 `A unlicensed`가 되지만 innate morality가 아니다. `R public_record`에 `unregistered craft`가 Filing된다 | g1..g8 |
| `S145` | PLANNED_RETAINED | X33 | `R5-10 Field Weave` | `npc_04_sable_halm` | `RC-05` | "이 magic를 쓸 줄 안다"가 실전 숙련의 occupational speech로 고정되고, `res_craft_credit`이 실전 증거가 된다. innate title은 0건이다 | g1,g2,g7,g8 |
| `S146` | PLANNED_RETAINED | X33 | `R5-10 Field Weave` | `npc_04_sable_halm` | `RC-05` | 종이에 magic을 적신 뒤 자르는 craft가 baseline이며 `res_medium_blank`를 소모한다. `res_*` field resource와 combat resource가 분리된다 | g1..g8 |
| `S147` | PLANNED_RETAINED | X33 | `R4-01 Translation Desk` | `npc_06_tamas_quill` | `RC-04` | positive theory label을 확정하지 않고 `R4` `glossary` slot에 비워 둔다. slot이 비면 `untranslated term`으로 Filing되고 학교 이름과 충돌할 때 `R4-02` conflict record가 남는다 | g1..g8 |
| `S148` | PLANNED_RETAINED | X33 | `R5-10 Field Weave` | `npc_10_juno_caster` | `RC-05` | textile/scroll craft가 soft/constructive action family로 실행되고 failure가 medium residue로 `K`에 Filing된다. 준비된 scroll이 `E`를 소모한다 | g1..g8 |
| `S149` | PLANNED_RETAINED | X34 | `R5-10 Field Weave` | `npc_04_sable_halm` | `RC-05` | 가위로 빠르게 재단하는 combat weave와 전투 전 준비가 같은 action schema의 다른 authored action으로 실행되고, 두 경로의 cost/state가 다르다. `D`와 `E` write가 각각 남는다 | g1..g8 |
| `S150` | PLANNED_RETAINED | X34 | `R5-11 Rigid Fold` | `npc_04_sable_halm` | `RC-05` | 종이접기 magic의 3D complexity/cost 우위가 `res_fold_sheet` count 소모로 표현되고 `R5-06` encounter signature를 바꾼다. `P personal_collapse`는 failed fold에서만 전진한다 | g1..g8 |
| `S151` | PLANNED_RETAINED | X34 | `R5-01 Boot Contract` | `npc_04_sable_halm` | `RC-05` | 허리춤 직물 조각이 world affordance가 되어 `R5-13 Supply Rack`의 medium export를 만들고 `E18` resource cost를 확정한다. UI icon이 아니다 | g1..g8 |
| `S152` | PLANNED_RETAINED | X34 | `R8-01 Course Index` | `npc_09_perrin_lask` | `RC-08` | 전투 전 scroll/weave 준비와 실전 선택이 하나의 `res_craft_credit`으로 묶이면서 `A`는 `provisional` 유지, `D`는 `E` clock을 소모한다 | g1..g8 |
| `S153` | PLANNED_RETAINED | X35 | `R5-12 Void Cut` | `npc_04_sable_halm` | `RC-05` | 종이를 던지고 칼로 썰어 발동하는 field improvisation이 `res_blade_credit`을 소모하고, 성공/실패가 `magic.crafts`의 `tool_variant`로 남는다 | g1..g8 |
| `S154` | PLANNED_RETAINED | X35 | `R7-09 Void Cut Ledger` | `npc_07_bryn_oskel` | `RC-07` | 가위로 공허를 잘라 다른 층을 여는 void-cut이 `contract tally`(비수량 debt key)를 만들고 `C crown_alignment`의 interpretation input으로만 사용된다 | g1..g8 |
| `S155` | PLANNED_RETAINED | X35 | `R7-09 Void Cut Ledger` | `npc_01_ilyra_senn` | `RC-07` | shape가 destination과 위험을 결정하는 authored geometric grammar가 contract 문서를 만들고, 오역된 shape가 `R4-02` canonical law를 다시 쓴다 | g1..g8 |
| `S156` | PLANNED_RETAINED | X35 | `R6-01 Organ Intake` | `npc_05_nera_voss` | `RC-06` | "차가운 것 → 용암 분출" 같은 typed otherworld/element exchange가 `R6` organ magic으로 Filing되어 `B organ-authority`를 만들고 `E` medicine 재고를 소모한다 | g1..g8 |
| `S157` | PLANNED_RETAINED | X36 | `R8-06 Void Contract Filing` | `npc_06_tamas_quill` | `RC-08` | arbitrary input에 mental attack output을 돌려주는 예측 불가 존재가 `B recognition_drift`를 `unclassified`로 밀고, `R4` glossary 충돌과 `R` public record에 delayed evidence가 남는다 | g1..g8 |
| `S158` | PLANNED_RETAINED | X36 | `R8-06 Void Contract Filing` | `npc_01_ilyra_senn` | `RC-08` | 고위 portal contract가 구체적 spell을 주지만 deferred obligation(`contract tally`)을 남기고, `G8`이 그 contract를 `crown_protocol` 안과 밖 중 어디에 둘지 명시하도록 강제한다. `C`는 전진하지 않고 `R` public record에 contract가 공개된다 | g1..g8 |
| `S159` | PLANNED_RETAINED | X36 | `R8-06 Void Contract Filing` | `npc_10_juno_caster` | `RC-08` | contract spell이 불발 확률이 낮고 구체적이어도 대가는 `E`(circulation 소모)와 `R`(contract 공개)에 각각 적립된다. `R7-09`과 같은 contract를 다시 쓰면 두 record가 `R4-02`와 같은 conflict가 된다 | g1..g8 |
| `S160` | PLANNED_RETAINED | X36 | `R5-12 Void Cut` | `npc_14_eda_marrow` | `RC-05` | 가위/칼날의 물리 구조가 공허를 자르는 비용과 안정성을 결정하고 그 값이 `magic.crafts.tool_variant`에 고정되어 `R8-04`/`R5-12`의 cost를 바꾼다. `E`와 `P`가 별도 write로 남는다 | g1..g8 |

Row 수 검증: `S001`~`S160`이 정확히 한 번씩 존재한다. `S001`~`S120`은 core 120행, `S121`~`S160`은 magic supplement 40행이다. `S037`은 `02` §11.3에서 `RC-06` cluster로 bind되지만 표는 같은 node의 region family(`R6-03`)로 표기해 link A 스키마를 유지한다. `S037`·`S101`~`S120`은 `ONEOFF` class이므로 `link B`가 `npc` 1개뿐이다(06 §5.2 `oneoff_binding_not_local` 준수).

magic supplement 행 검증(`02` §11.4`):

- `S121`~`S160` 40행이 각각 `res_*` 또는 `magic` record를 하나 이상 읽거나 쓴다.
- `R8` family에 bind된 14행(`S121`,`S122`,`S133`~`S144`,`S152`,`S157`~`S159`)은 `I → D`가 `R5`/`R4`/`R2`/`R7`의 명시적 surface를 함께 건드린다. `R8`에만 묶인 행 0건이다.
- 40행 모두 `I → D` 칸에 `K`/`I`/`E`/`P`/`R`/`C` 중 하나 이상의 clock write가 명시되어 있다. clock write 없는 행 0건이다.
- `link B`는 14 core roster에서만 뽑았고, 그 NPC는 표에 적힌 cluster의 membership 안에 실제로 있다. magic용 15번째 core `npc_*`는 0건이다.
- `gate` 열은 `06` §13.2의 usage class 요구를 따른다. magic supplement에서 `TONE`은 `S125`, `S145` 2행뿐이고 그 둘은 `g1,g2,g7,g8`이며, 나머지 38행은 `g1..g8`이다.


## 21. Handoff contract for sibling plan files

이 파일은 split Kit plan의 story source다. 타 파일을 수정하지 않지만 구현은 아래 interface를 보존해야 한다.

- `01_SYSTEM_UX.md`: field/combat 전환, NPC-boss same-identity resolution, action/command resolution, focus owner 규칙(§1 evidence 표의 `DLG`/`DOC`/`PRES` 항목), `PLAYER_LAYER_*`가 command로 열릴지 여부.
- `02_WORLD_STATE_AND_ROUTES.md`: `H0` + `R1`~`R8` node, `E01`~`E18` edge, `G0`~`G8` gate, 4개 axis token과 integer mapping, 6개 clock stage vocabulary, region/resource key, `E4 The Concentration Layer` era.
- `04_CHARACTERS_AND_RELATIONSHIPS.md`: 14 core NPC dossier, `rel_*` state 배열 해석, verb precondition, body-horror 6요소, survival/death/absence result, `R8`의 7명 core NPC visitor 표기.
- `05_ENEMIES_AND_ENCOUNTERS.md`: `npc_11_cael_ren`/`npc_04_sable_halm`/`npc_12_ravenna_holt`의 NPC conversion variant, organ quorum phase, noncombat counter, aftermath, `FAM-ARPG-02` 기반 `ENC-ARPG-25`와 `region_role: magic_training_craft_labor`.
- `06_AUTHORED_CONTENT_AND_DATA.md`: `documents`·`conversations`·`choices`·`effects`·`props`·`encounters` schema와 stable ID 규칙, `seeds` row(160), `relationships` state 검증, ending content ID(§14.7), `magic` 하위 record 6종의 save projection allowlist, `02` §5.5의 magic `res_*` registry.
- `07_REFERENCE_GAME.md`: `HC-00`/`RC-01`~`RC-08` 실행 순서, 9 cluster, 5개 run의 실측 시간, recovery 7(+`G8`) 실행, A1 data-only 확장(`RG-M13`).
- `08_SAVE_DEATH_AND_RECOVERY.md`: truth, relationship, body anchor, clock, route, pending consequence, recovery lineage, `magic` record 직렬화, stale ID 처리.
- `09_PRESENTATION_ART_AND_AUDIO.md`: world-preserving dialogue/document/aftermath presentation, 9줄 page bound, focus와 disabled의 분리, nonsexual body-horror staging, magic 실패 staging.
- `10_TESTS_AND_ACCEPTANCE.md`: 위 test ID로 ending catalog, re-key 잔여 0, 3-value ladder 부재, 5번째 축/7번째 clock 부재, 96/160 gate, 계획 단계 `used`/`transformed` 완료 claim 0건을 검증한다.

### 21.1 `10`에 요청하는 acceptance check (이 파일은 `10`을 수정하지 않는다)

아래 test ID는 모두 `10_TESTS_AND_ACCEPTANCE.md`에 구현되어 있다. 이 표는 요청 기록이며 미구현 blocker가 아니다. `10` §0.2(실행 로그 없는 근거는 `FAIL`)와 §1.4에 따라 여기 없는 test ID를 증거로 인용하지 않는다.

| 요청 ID | 검증 대상 | 근거 |
|---|---|---|
| `test_ending_catalog_matches_03_and_rewrites_roster_ids` | ending catalog 6종 존재, route bundle·truth·relationship 조건 요구, world/NPC/route/relationship/clock surface 변화 ≥1, ending 내부 NPC 표기가 14 core roster stable ID이며 미re-key 잔여 0, ending content ID가 `06` §3.5.6과 1:1 | `10` §1, 이 파일 §16, §16.8, §14.7 |
| `test_axis_values_use_02_integer_ladder` | 4축이 int `-3..3`으로 저장되고 `02` mapping으로 해석되며, 별도 3-value ladder token이 어떤 계획 문서에도 존재·참조되지 않음 | `PLAN_RESOLUTION` §5, `02` §3, `06` §6.1 |
| `test_magic_adds_no_axis_clock_or_recovery_kind` | 5번째 world 축, 7번째 clock, 8번째 recovery kind가 어떤 계획 문서와 content에도 없고, magic write가 `02` §3.4/§4.4의 표에만 존재하며 `mana` 단일 수치 resource와 전역 `concentration` 막대가 0건 | `PLAN_RESOLUTION` §4·§7, `02` §3.4, §4.4, §5.5, `06` §5.6 |
| `test_cluster_registry_has_nine_clusters_each_six_to_twelve` | cluster가 `HC-00` + `RC-01`~`RC-08` 정확히 9개이고 각각 6..12 core NPC, 2~4 institutions, 2~3 clocks를 가지며 14 core roster 밖 actor가 membership에 없음 | `02` §8, `04` §4.2, 이 파일 §10 |
| `test_ro_08_has_no_orphan_ending_path` | `RC-08`이 resolved되었을 때와 `E18`이 닫힌 채 남았을 때 각각 어떤 ending으로 resolve되는지 결정되며, 어느 조합도 ending 없이 끝나지 않음 | 이 파일 §9, §16.3, §16.5, §16.6, §16.7, §16.8 |
| `test_crown_alignment_is_a_world_write_not_recovery_type` | recovery enum 7종에 `crown_alignment`가 없고, 같은 intent는 operator/precedence/route 재해석 world write로만 commit되며 world 전체 reset이 없음 | `PLAN_RESOLUTION` §4, `10` §1 |
| `test_crown_alignment_world_write_preserves_operator_and_precedence` | `Crown of Continuance` precedence/operator 교체 후 이전 operator memory가 archive에 잔존하고 route variant가 world-wide 재해석되며, 이전 phase는 revisit archive로만 읽힘 | `02` §10, `08` §7, 이 파일 §7 |
| `test_seven_recovery_types_match_identity_table` | 7 canonical type이 `08`의 body/memory/role/belief/institution/desire/social recognition 보존표와 일치하고 8번째 type 0건 | `06` §5.8, `08` §7, 이 파일 §16.8 |
| `test_planned_seed_never_claims_used_or_transformed_in_planning` | 계획 문서와 content에 `used`/`transformed` 완료 claim 0건, `status == planned` row가 완료 증거로 인용된 사례 0건 | `PLAN_RESOLUTION` §6, `IDEA_LEDGER` §4, `06` §13.6 |
| `test_fourteen_core_npcs_own_the_canonical_roster` | `npc_01_ilyra_senn`~`npc_14_eda_marrow` 14명 core roster가 모두 존재하고 각자 required field를 가지며, `R8` support resident가 core roster로 승격되지 않았고 15번째 core `npc_*`가 0건 | `04` §2, `04` §2.2, `02` §7.9, §12, 이 파일 §11 |

`10`에 이미 존재하는 `test_major_branch_has_six_to_twelve_npc_cluster`와 `test_seed_usage_counts_distinct_units_not_lines`가 이 파일 §10의 6~12 조건과 §20의 96/160 gate를 이미 판정한다.

### 21.2 re-key 상태 (2026-09-25 확인)

- **완료.** `04` §4.2/§7/§12와 `07` §6/§10.4/§15.1은 9개 cluster를 사용한다.
- **완료.** `04` §2.1의 primary/secondary node 표에 `R8`과 7명 core visitor/support 정책이 반영됐다.
- **완료.** `05`에 `FAM-ARPG-19`, `ENC-ARPG-25`, `region_role: magic_training_craft_labor`가 반영됐다.
- **완료.** `06`은 9 region/18 edge, `npc_20_*`~`npc_26_*` support namespace, 160/96/120 seed accounting을 사용한다.
- **완료.** `07` §14.1/§16은 `ENC-ARPG-25`와 `RG-M13`/`RG-M15`를 canonical로 사용한다.
- **확인.** story plan은 content ID를 combat, input, save, registry core algorithm에 추가하지 않고 구현된 때만 design artifact로 완료된다. user play review는 별도 gate이다.

## 22. 상태

- world/narrative spine: **DEFINED** (`H0` + `R1`~`R8`, `Crown of Continuance`, `Crown Protocol`, `G8`, `E1`~`E4`)
- NPC re-key: **DONE** (14 core roster + support resident 정책, `04` §2.3 준수. `R8` core visitor 7명 추가, 15번째 core `npc_*` 없음)
- relationship re-key: **DONE** (`rel_01_ilyra_record` ~ `rel_14_eda_shift`, `06` §3.5.3 shape)
- cluster: **DEFINED** (9개, 각각 6~12 core NPC. 실제 크기 7/7/7/8/7/7/7/8/7)
- axes: **DELEGATED** (`02` §3 token · `06` §6.1 int 저장. 이 문서의 3-value ladder 삭제. magic 전용 축 0건)
- clocks: **DELEGATED** (`02` §4의 6개. magic 전용 clock 0건)
- recovery: **DELEGATED** (`PLAN_RESOLUTION` §4의 7종 + `G8` world write. magic recovery type 0건)
- truth layer: **DEFINED** (8개, acquisition order 포함)
- relationship: **DEFINED** (`rel_*` 14개, sink 명시, `R8` 두 번째 port 표 포함)
- body arc: **DEFINED** (player + 5 core NPC + magic 4종)
- magic integration: **DEFINED** (`R8` region/`RC-08` cluster, `E18`, concentration·circulation infrastructure, craft family 3종, magic academy labour/class conflict, portal contract, post-human/material era deep record)
- lens: **DEFINED** (6개, `ROUTE_CRAFT` 포함. 각 lens가 최소 1개 ending에 매핑)
- ending: **DEFINED** (6종, downgrade 규칙 + coverage matrix. `RC-08`/`TRUTH_T6`/`TRUTH_T7`/`CONSEQ_12`~`CONSEQ_15` 커버)
- seed register: **PLANNED** (160행 전부 `PLANNED_RETAINED`, planned target 160/160, gate 96 / preferred 120)
- `content/` 실제 파일: **NOT STARTED**
- 구현: **NOT STARTED**
- 완료 상태: **계획 중** — 이 문서는 story/ending 소유 범위만 갱신했으며 다른 plan file과 `README.md`의 status는 별도 작업이다.

