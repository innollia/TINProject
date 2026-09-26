# 07 — Reference Game: The Undersign Basin: A Season of Returning

## 환경 제작 및 분량 보존 — 2026-09-26

[13](13_LAYERED_ENVIRONMENT_PRODUCTION.md)의 장면 배경+분리 레이어를 전 지역에 적용한다. H0 샘플 한 장 또는 한 구역의 조립 성공은 기존 Reference Game의 region·NPC·encounter·cluster·revisit·플레이 분량을 충족하지 않는다. 배경 장수나 layer 수를 authored content 수로 세지 않는다.

샘플 검수 뒤 실제 구역을 확장할 때, 각 구역의 출입·가림·상호작용·상태 차분이 기존 authored unit에 대응하는지 기록한다. 기존 core를 수정하지 않고 두 번째 서로 다른 구역과 사건 후 차분을 추가하는 증거도 남긴다. 단순 이동/대사/대기를 늘려 이미지 제작 누락을 가리지 않는다.

상태: 구현 전 Reference Game 실행 계획.  
범위: `Top-down Action-RPG Kit`의 실제 플레이 흐름, authored content 배치, route/recovery/revisit, 수동 플레이와 완료 증거.  
Primary Reference: **BLACK SOULS 2 하나**.  
문서 간 충돌 해석: `docs/research/top_down_action_rpg/PLAN_RESOLUTION.md`.  
세계/node/edge/gate/axis/clock/cluster/seed 정본: `02_WORLD_STATE_AND_ROUTES.md`.  
story/ending/rel/body arc 정본: `03_STORY_AND_ENDINGS.md`.  
NPC 정본: `04_CHARACTERS_AND_RELATIONSHIPS.md`.  
enemy/encounter/action/status/resource 정본: `05_ENEMIES_AND_ENCOUNTERS.md`.  
schema/ID/registry 정본: `06_AUTHORED_CONTENT_AND_DATA.md`.  
save/death/recovery 정본: `08_SAVE_DEATH_AND_RECOVERY.md`.  
acceptance 정본: `10_TESTS_AND_ACCEPTANCE.md`.  
magic theory 정본: `12_MAGIC_THEORY.md`.

이 파일은 10분보다 긴 substantial multi-route content slice를 고정한다. direct route는 18~25분, body route는 30~42분, resource route는 30~40분, craft route는 25~35분, full survey는 75~95분을 목표로 한다. 10분은 하한이며 이동, 대기, 대사량, 반복 전투, HP inflation으로 채우지 않는다.

## 1. 하드 범위

| 항목 | 고정 범위 | 정본 ID |
|---|---:|---|
| Hub | 1 | `H0 The Undersign Exchange` |
| Authored region | 8 | `R1 The Returning Kiln` ~ `R8 The Folding School` |
| World node | 9 | `H0` + `R1`~`R8` |
| Route edge | 18 | `E01`~`E18` |
| Route gate | 9 | `G0 Arrival Declaration` ~ `G8 Crown Precedence` |
| Core NPC | 14 | `npc_01_ilyra_senn` ~ `npc_14_eda_marrow` |
| Support resident (ID 보유) | 7 | `npc_20_mira_vask` ~ `npc_26_cael_orin` (`R8` only, `roster_kind: support`) |
| Support resident (ID 없음) | region residents | `02` §7.1~§7.8 표기 그대로. canonical core 수에 포함하지 않는다 |
| Enemy family | 19 | `FAM-ARPG-01`~`FAM-ARPG-19` |
| Authored encounter | 25 | `ENC-ARPG-01`~`ENC-ARPG-25`. field 11 + boss 14 |
| Group template | 5 | `GRP-ARPG-01`~`GRP-ARPG-05` |
| Variant | 6 | `VAR-ARPG-01`~`VAR-ARPG-06` |
| NPC conversion | 5 | `NPC-CONV-ARPG-01`~`05` |
| Event cluster | 9 | `HC-00` + `RC-01`~`RC-08` |
| Orthogonal axis | 4 | A legitimacy, B recognition, C continuity, D scarcity |
| Pressure clock | 6 | `CL-INST`, `CL-CONT`, `CL-REC`, `CL-RES`, `CL-PER`, `CL-CROWN` |
| Recovery type | 7 | `checkpoint`, `respawn`, `institutional_reentry`, `clone`, `loop`, `reincarnation`, `immortality` |
| World write (recovery 아님) | 1 | `crown_alignment` (`G8` global irreversible write) |
| Ending | 6 | `end_r1_receipt_of_a_life`, `end_g1_law_without_master`, `end_o1_many_mouths_one_person`, `end_a1_empty_seat`, `end_c1_four_anchors`, `end_c2_last_witness` |
| Relationship instance | 14 | `rel_01_ilyra_record` ~ `rel_14_eda_shift` (`rel_09_perrin_ward`는 romance 아님) |
| Body-horror arc | 10 | `BODY_ARC_*` (`03` §13.1~§13.10) |
| A1 authored expansion | 1 | `R8` region + `npc_20_*`~`npc_26_*` 7명 + `ENC-ARPG-25`. `changed_core_files == []` |
| Seed ledger | 160 | core 120 (`S001`~`S120`) + magic supplement 40 (`S121`~`S160`). hard gate 96 distinct `PLANNED_RETAINED`, preferred target 120 |

모든 수량은 authored content가 같은 field, combat, dialogue, document, relationship, clock, save/recovery surface를 실제로 재사용한다는 증거다. 수량을 채우기 위한 palette-only variant, dialogue-only NPC, 반복 boss, 긴 corridor는 허용하지 않는다.

- `npc_15`~`npc_19` 번호는 **사용하지 않는다** → `support_roster_id_range_forbidden` error.
- `R8`은 15번째 core actor를 만들지 않는다. `RC-08`의 학교 측 surface는 `npc_20_*`~`npc_26_*`가 맡고, 그들이 실행하는 action은 `04` §2.1의 core NPC verb ID로 기록한다.
- `G9`를 만들지 않는다. `E18`의 gate는 `G5` 하나다.
- 10번째 edge, 10번째 gate, 10번째 cluster를 만들지 않는다.
- 이전 판의 수량(24 encounter, 18 family, 8 cluster, 8 recovery type, 7 region, `E17`까지, 120/72/90 seed)은 모두 retired다.

## 2. 시작과 첫 meaningful action

### 2.1 시작 상태

player는 The Undersign Basin의 한 vertical basin으로 돌아온 field investigator다. body, memory, role, recognition, organ authority가 한 사람에게 온전히 정렬되어 있지 않다. player는 각 recovery·recognition·authority protocol의 experiment/subject이며, 정답 operator로 시작하지 않는다.

`H0 The Undersign Exchange`의 `npc_02_orrin_kest`가 incomplete arrival record를 제시한다. player는 `person`, `patient`, `worker`, `artifact` 중 하나를 stamp하거나 category를 보류한다(`H0-01 Arrival Docket`, `G0 Arrival Declaration`).

### 2.2 첫 meaningful action 계약

- Input Bubble 종료 직후 stopwatch를 시작한다.
- `npc_02_orrin_kest`에게 field `interact` intent를 보낸다.
- arrival record의 한 stamp를 조사해 “body, role, record 중 어느 층위만 현재 player와 일치하는가?”를 확인한다.
- 20초 안에 interact, 30초 안에 raw mismatch observation, 45초 안에 door/access/NPC trust의 world projection이 보여야 한다.
- quest arrow, space label, 장문 tutorial, 버튼 목록으로 첫 행동을 보조하지 않는다.

## 3. 9개 node와 18개 edge

`02` §5.2의 edge registry가 정본이다. `05`의 `region_role` token은 retire된 role key(`R-RETURN`, `R-COMMON`, `R-SERVICE`, `R-LATENCY`, `R-LEXICON`, `R-VISCERA`, `R-SEAM`, `R-CROWN`, `R-ARCHIVE`)를 쓰지 않는다. 두 region에 걸친 record는 `region_secondary`로 split을 명시한다(`05` §2.6).

### 3.1 Edge inventory와 첫 통과 evidence

| edge | passage | gate | 첫 통과에 필요한 player evidence |
|---|---|---|---|
| `E01` H0–R1 | Ash Stair | `G0` | arrival category를 stamp하거나 보류한 filed record |
| `E02` H0–R2 | Sluice Road | `G0` + `H0-04` ration line filed | H0에서 끝난 두 act의 인과 순서(`02` §5.4.1). `R2` evidence로 열지 않는다 |
| `E03` H0–R3 | Mercy Causeway | `G0` | recovery goal을 patient/work role과 분리해 말하기 |
| `E04` H0–R4 | Crownwell Ascent | `G0` + `blank form` 2 제출 | H0에서 끝난 두 act(`02` §5.4.2). 한 번만 열린다 |
| `E05` H0–R5 | Foundry Tram | `G0` | boot에서 맡을 role name을 선언 |
| `E06` R1–R3 | Quiet Ward Passage | `G1` | body가 맞고 role이 틀렸다는 차이를 제시 |
| `E07` R1–R6 | Ash Chute | `G1` | organ을 독립 patient가 아니라 authority로 분류 |
| `E08` R2–R6 | Medicine Ferry | `G2` | remedy의 원재료와 counterfeit's 차이 확인 |
| `E09` R2–R7 | Orchard Causeway | `G2` | wall phase의 low-level mark를 읽음 |
| `E10` R3–R4 | Bell-Cable Lift | `G3` | hospice term을 archive category로 번역 |
| `E11` R3–R5 | Care Train | `G3` | body name과 labor role name을 분리해 선언 |
| `E12` R4–R5 | Courier Shaft | `G4` | 두 문장의 충돌을 하나의 operative rule로 결정 |
| `E13` R4–R7 | Crown Stair | `G4` | literal object와 title/authority claim을 구분 |
| `E14` R5–R6 | Under-Rail Shunt | `G5` | post-boot person을 장비가 아니라 human/operator로 기술 |
| `E15` R5–R7 | Supply Gantry | `G5` | operator sequence를 관찰해 재현 |
| `E16` R6–R7 | Drainage Dark | `G6` | scar/continuity pattern으로 returning body를 구별 |
| `E17` R2–R3 | Water Ambulance Bridge | `G2` | scarcity가 water인지 attention인지 선언 |
| `E18` R5–R8 | Folding School Approach | `G5` | 보유 craft를 `person` capability으로 부를지 `artifact` possession으로 부를지 선언. `concentration sample` 1 + `craft credit` 1 |

- `E02`와 `E04`의 unlock은 `R2`/`R4`의 gate가 아니라 `H0`에서 끝난다. `G2`/`G4`는 각 region에서 수행하는 gate이고 `E02`/`E04`의 상태를 바꾸지 않는다.
- `E18`은 양방향 edge다. `R8`의 두 번째 return affordance는 `E18` 왕복이 아니라 `R8` 내부 `course index return` route state다.
- 모든 gate는 `clue_found` 저장으로 통과시키지 않는다. 이미 아는 문장·관찰·물건은 즉시 실행할 수 있다.

### 3.2 Node별 첫 meaningful action과 encounter 배치

`05`가 encounter의 family/action/phase/break/status/linked-actor/outcome 상세를 소유한다. 07은 첫 등장, route 배치, meaningful action, evidence를 고정한다.

| Node | 첫 meaningful action | 주요 core NPC | 그 node의 encounter | 주요 clock signal | full-survey 시간 |
|---|---|---|---|---|---:|
| `H0` | `npc_02_orrin_kest`의 arrival stamp 조사, category 선언 또는 보류 | `npc_02_orrin_kest`, `npc_10_juno_caster`, `npc_11_cael_ren`, `npc_03_veya_morcant` | `ENC-ARPG-03`, `ENC-ARPG-14` | 중복 stamp, `R private`, crier thread | `0:00~0:04` |
| `R1` | `npc_11_cael_ren`의 body와 name/role 불일치를 실제 record에서 분리 | `npc_02_orrin_kest`, `npc_11_cael_ren`, `npc_13_tovan_reed`, `npc_03_veya_morcant` | `ENC-ARPG-01`, `ENC-ARPG-02`, `ENC-ARPG-11`, `ENC-ARPG-12`, `ENC-ARPG-13` | ash residue, `K exposed`, filing, return stamp | `0:04~0:20` |
| `R3` | `npc_04_sable_halm`에게 care window를 fast recovery와 consent 보존으로 나눌 권한을 요구 | `npc_04_sable_halm`, `npc_09_perrin_lask`, `npc_05_nera_voss`, `npc_13_tovan_reed` | `ENC-ARPG-08`, `ENC-ARPG-15` | bell delay, school category, care record | `0:20~0:30` |
| `R5` | `npc_04_sable_halm`의 transformation permission과 boot resource를 확인하고 거부 가능성을 유지 | `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_09_perrin_lask` | `ENC-ARPG-16` | labor shift, latency, contract record | `0:30~0:40` |
| `R2` | `npc_08_meral_dune`에게 한 water allotment을 medicine와 settlement 중 어디로 돌릴지 결정 | `npc_08_meral_dune`, `npc_14_eda_marrow`, `npc_11_cael_ren`, `npc_05_nera_voss` | `ENC-ARPG-06`, `ENC-ARPG-07`, `ENC-ARPG-20`, `ENC-ARPG-21` | waterline, seed count, public ration, `concentration_field` | `0:40~0:55` |
| `R6` | `npc_05_nera_voss`의 organ complaint를 끝까지 듣고 patient signature를 먼저 확인 | `npc_05_nera_voss`, `npc_13_tovan_reed`, `npc_04_sable_halm` | `ENC-ARPG-05`, `ENC-ARPG-19` | pain, custody, medicine debt, medium residue | `0:55~1:07` |
| `R4` | `npc_06_tamas_quill`에게 두 source version을 실제 page에서 비교하고 contradiction 공개 여부를 결정 | `npc_06_tamas_quill`, `npc_01_ilyra_senn`, `npc_12_ravenna_holt` | `ENC-ARPG-04`, `ENC-ARPG-10`, `ENC-ARPG-17`, `ENC-ARPG-18`, `ENC-ARPG-24` | filing, copied name, public copy, `glossary` slot | `1:07~1:24` |
| `R7` | `npc_07_bryn_oskel`에게 wall phase를 기록하고 recovery/recognition/authority 중 하나의 precedence를 제시 | `npc_07_bryn_oskel`, `npc_12_ravenna_holt`, `npc_01_ilyra_senn` | `ENC-ARPG-09`, `ENC-ARPG-22`, `ENC-ARPG-23` | wall phase, writ, `C contested`, Crown alignment | `1:24~1:36` |
| `R8` (A1) | `npc_09_perrin_lask`에게 lineage 배정표의 이름 없는 칸을 열게 하고 `concentration sample` provenance를 등록 | `npc_09_perrin_lask`, `npc_04_sable_halm`, `npc_14_eda_marrow`, `npc_01_ilyra_senn`, `npc_06_tamas_quill`, `npc_10_juno_caster`, `npc_07_bryn_oskel` | `ENC-ARPG-25` | 등록 concentration 표, 반납된 course credit, failed fold, `I assigned` | A1 이후 선택 |
| aftermath | 같은 node의 NPC, route, resource, document, companion state 재확인 | committed cast | 선택한 ending terminal | unresolved clock 유지 | `1:36~1:45` |

- `ENC-ARPG-08`/`ENC-ARPG-15`는 `R3` primary에 `H0`/`R5`를 `region_secondary`로 갖는다. `ENC-ARPG-16`은 `R5` primary에 `R6` secondary, `ENC-ARPG-18`은 `R4` primary에 `R1` secondary다. 한 record를 두 node의 첫 encounter로 중복 집계하지 않는다.
- 이 시간표는 loading, long travel, pause, menu 정리를 제외한다. 각 encounter는 telegraph와 counter를 읽는 시간, dialogue/document page, world consequence 확인까지 포함한다.

## 4. NPC binding

### 4.1 Core 14명

`04` §2의 stable ID와 system port를 그대로 사용한다. 각 NPC는 첫 방문, late revisit, survival/absence 결과를 모두 가져야 한다.

| NPC | Home node | 첫 meaningful action (canonical verb) | Reference Game system proof | late revisit proof |
|---|---|---|---|---|
| `npc_01_ilyra_senn` Ilyra Senn | `R4`, `R7` | `REQUEST_INDEX` — 두 record의 source provenance 비교 | archive inquiry, canonical translation, `glossary` 선점/충돌, romance/record ownership | copied name, withheld page, `R4-02` conflict, `R8-06` contract 문서 Filing |
| `npc_02_orrin_kest` Orrin Kest | `H0`, `R1` | `DECLARE_RETURN` / `CHALLENGE_RECORD` | arrival category, recovery lineage, `institutional_reentry` owner | accepted/disputed/erased record, quarantine access, `NPC-CONV-ARPG-01` conversion |
| `npc_03_veya_morcant` Veya Morcant | `H0`, `R3` | `CHALLENGE_CATEGORY` / `SIGN_EXCEPTION` | legal exception, category audit, `E18` unregistered craft seizure | exception ownership, public filing, jurisdiction loss |
| `npc_04_sable_halm` Sable Halm | `R3`, `R5` | `REQUEST_CONSENT` → `ALLOCATE_EXECUTION_SPACE` | permission, execution space, craft medium/execution space 배정, `NPC-CONV-ARPG-02` conversion | failed recognition, independent form, course selection 목록 |
| `npc_05_nera_voss` Nera Voss | `R6` | `LISTEN` 후 `CALL_BODY_VETO` | organ negotiation, body consent, `NPC-CONV-ARPG-03` conversion, organ residue 회수 | organ coalition, patient veto, clinic route, magic cure 우회 비용 |
| `npc_06_tamas_quill` Tamas Quill | `R4` | `COMPARE_VERSIONS` — 두 source term을 실제 page에서 비교 | translation, local law authoring, `untranslated term` 유지 | canonical/contradictory copy, `glossary` 상호 claim |
| `npc_07_bryn_oskel` Bryn Oskel | `R7` | `MARK_ROUTE` / `SAMPLE` / `OPEN_PASSAGE` | frontier route survey, boundary shortcut, `R7-09` void-cut 증거 | wall phase, redirected edge, route witness, `Cut Chamber` 잔해 동일 maker |
| `npc_08_meral_dune` Meral Dune | `R2` | `ALLOCATE_WATER` / `DIVERT_RESERVE` — 한 ration line 배정 | water/seed state, `R2-09` disperser reading, `R2-10` circulator ledger | ration schedule, medicine price, `concentration_field` provenance |
| `npc_09_perrin_lask` Perrin Lask | `R3` | `ENROLL` / `RENAME` / `HIDE` | identity registry, continuation naming, `R8-03` 이름 없는 배정함 | protected alias, lost record, `lineage_token` 배정표 |
| `npc_10_juno_caster` Juno Caster | `H0`, `R4` | `FORWARD` / `VERIFY` / `WITHHOLD` | public thread, rumor routing, failed fold screenshot forwarding | crier copy, official wording, trust/rupture |
| `npc_11_cael_ren` Cael Ren | `H0`, `R1`, `R2`, `R7` | `TEST_CONTINUITY` / `REFUSE_INHERITANCE` / `CHOOSE_HISTORY` | successor continuity, clone/branch, operator claim | new body/role/social record와 source archive |
| `npc_12_ravenna_holt` Ravenna Holt | `R7`, `R4`, `H0` | `PETITION` / `DEFER_CROWN` | Crown Protocol, `G8` sole writer, `contract_tally` 해석 위치 명시 | deposed/witness/successor, global route variant |
| `npc_13_tovan_reed` Tovan Reed | `R1`, `R6` | `TRIAGE` / `OPERATE` / `CARRY` | field triage, recovery workaround, `mana_profile` field 판정 | injury, debt, absence, carried patient state |
| `npc_14_eda_marrow` Eda Marrow | `R2`, `R5`, `R3`, `R6` | `MOBILIZE` / `STRIKE` / `REDISTRIBUTE` | labor clock, service refusal, 학교 밖 course/labor record 분리, `NPC-CONV-ARPG-05` conversion | strike, redistributed service, `craft_credit` ↔ labour hour 환전 |

NPC 수를 늘리기 위한 unnamed resident는 Reference Game manifest에 넣지 않는다. `npc_15`~`npc_19` 번호를 쓰지 않는다. background chatter와 visual crowd는 NPC state actor로 세지 않는다.

### 4.2 `R8` support resident 7명 (A1)

`04` §2.4의 canonical ID를 그대로 쓴다. 7명 모두 `roster_kind: "support"`이며 canonical core roster 14는 늘지 않는다. `R8`에 `npc_*`를 하나 더 만들지 않는다는 것이 A1의 NPC 조건이다.

| support resident | `R8` system port | executing core NPC (`RC-08`) | Reference Game evidence |
|---|---|---|---|
| `npc_20_mira_vask` | magic craft queue / student status, `course index` | `npc_09_perrin_lask`, `npc_14_eda_marrow` | `R8-01` course index 인쇄, `SERVICE_R8_COURSE_INDEX` 한 줄, queue가 비면 대기자가 `unrecorded`로 남는 delayed write |
| `npc_21_halen_osk` | medium store keeper, `medium_blank`/`fold_sheet` 반출 | `npc_04_sable_halm` | 재고 대장과 `R5-13 Supply Rack` 원장의 수량 conflict가 `R4-02`와 같은 conflict record로 남음 |
| `npc_22_iven_marrow` | weave yard instructor, 실습 채점 | `npc_04_sable_halm` | `R8-05` 채점표와 `R5-06` encounter signature, `fold_sheet` 회수분 |
| `npc_23_turo_bex` | void-cut 실습 책임자, `contract_tally` | `npc_07_bryn_oskel`, `npc_01_ilyra_senn` | `R8-06` contract 문서와 `R7-09` ledger 대조, deferred obligation이 자동 해소되지 않음 |
| `npc_24_perri_lowe` | lineage registrar, `lineage_token` | `npc_09_perrin_lask` | `R8-03` 배정표와 `R8-07` refusal record, 이름 없는 배정함 |
| `npc_25_jano_fesk` | circulation board liaison, `concentration_field` 측정/배정 | `npc_08_meral_dune` | `R2-09`/`R2-10` 측정표와 `R8-02` 등록 대조, provenance 불일치 시 `K` +1 |
| `npc_26_cael_orin` | 발명가(분류 `art`, 학생 아님), 증언 source | `npc_06_tamas_quill`, `npc_10_juno_caster` | `unassigned stock` 분류의 명령자 증언, `R4` glossary 비어 있는 칸 |

- 7명 중 누구도 cluster participant로 세지 않는다. 학교 측 영향은 filed record, remote service, route evidence로 전달한다.
- `npc_26_cael_orin`은 core `npc_11_cael_ren`과 다른 사람이다. 이름이 겹쳐도 병합하지 않는다.
- 어떤 resident도 "학생 제거"로 처리되지 않는다. `R8` failed fold는 region에서 사람을 빼지 않는다.
- `R8`에는 `G9` gate가 없다. curriculum/lineage/concentration 등록은 `RC-08`이 만든 region state다.

## 5. Authored encounter 25개

각 encounter의 family/action/phase/break/status/linked-actor/outcome 상세는 `05`가 소유한다. 07은 첫 등장, route 배치, meaningful action, evidence를 고정한다.

| Encounter | Type | Canonical node | 첫 등장/필수 행동 | 분량 |
|---|---|---|---|---:|
| `ENC-ARPG-01` The Intake Stamp | field gate | `R1` | arrival seal을 제시하거나 disputed stamp를 combat으로 전환 | `0:45~1:30` |
| `ENC-ARPG-02` The Spill Index | field contamination gate | `R1` | source knot을 quarantine/isolate하고 spill을 닫음 | `1:15~2:00` |
| `ENC-ARPG-03` Complaint Queue | field court gate | `H0` | 첫 claim을 evidence로 정정하거나 combat intake로 진입 | `0:45~1:30` |
| `ENC-ARPG-04` Translation Drift | field research route | `R4` | source glyph을 anchor해 command label의 오역전을 끊음 | `1:15~2:00` |
| `ENC-ARPG-05` Triage Conflict | field clinic | `R6` | organ voice 하나를 silence/negotiate하고 consent link를 확인 | `1:15~2:00` |
| `ENC-ARPG-06` The Clone Census | field service/registry | `R2` | outlier를 mark하고 census record와 분리 | `1:00~1:45` |
| `ENC-ARPG-07` The Siltglass Toll | field survival | `R2` | named resource를 deny/divert하고 alternate water를 검증 | `1:00~1:45` |
| `ENC-ARPG-08` Signal Interference | field service-route | `R3` | verified message를 forward하거나 relay를 disconnect | `1:00~1:45` |
| `ENC-ARPG-09` The Audit Crossing | field border | `R7` | witness/source proof로 charge와 writ를 우회 | `1:15~2:00` |
| `ENC-ARPG-10` Archive Return Protocol | field archive gate | `R4` | source record를 expose하고 name category를 challenge | `1:30~2:15` |
| `ENC-ARPG-11` The Gate With No Name | charge/Break tutorial boss | `R1` | marked sweep와 unbreakable anchor를 구분 | `1:30~2:15` |
| `ENC-ARPG-12` The Usher of Second Registration | identity boss/NPC conversion | `R1` | duplicated name의 source를 release하거나 correct | `1:45~2:30` |
| `ENC-ARPG-13` Bloom at the Bottom of the Form | contamination/resource boss | `R1` | ink bloom/resource threshold 후 source를 quarantine/sever | `2:00~3:00` |
| `ENC-ARPG-14` The Court of Grievances | institutional boss | `H0` | claim을 settle/sever하고 Ward accumulator를 원본에 돌림 | `2:00~3:00` |
| `ENC-ARPG-15` The Bell That Counts Late | scheduler boss | `R3` | relay를 disconnect해 stolen slot을 되찾음 | `1:45~2:30` |
| `ENC-ARPG-16` Licence of the First Body | transformation/NPC-conversion boss | `R5` | permit/consent source를 revoke 또는 renegotiate | `2:15~3:00` |
| `ENC-ARPG-17` The Unfinished Sentence | language/authority boss | `R4` | source term과 contradiction을 보존 | `2:00~3:00` |
| `ENC-ARPG-18` A Name Has Teeth | category-priority boss | `R4` | guardian category를 source에서 retag하고 collar link를 끊음 | `1:45~2:30` |
| `ENC-ARPG-19` Consent of the Viscera | body-authority boss | `R6` | organ/patient co-signature를 만들고 false authority를 sever | `2:15~3:15` |
| `ENC-ARPG-20` The Many Become One | clone/link boss | `R2` | 두 link를 끊어 outlier의 social identity를 Filing | `2:00~3:00` |
| `ENC-ARPG-21` The Last Safe Water | ecology/resource boss | `R2` | alternate source를 verify하고 resource decision을 내림 | `2:15~3:15` |
| `ENC-ARPG-22` Audit Above the Market | debt/charge boss | `R7` | Ox charge와 grievance claim을 서로의 record에 돌림 | `2:00~3:00` |
| `ENC-ARPG-23` Bailiff of the Outer Seam | route/authority boss | `R7` | unbreakable Bailiff를 공격하지 않고 mandate/route를 변경 | `1:45~2:30` |
| `ENC-ARPG-24` The Above-Record | final archive boss | `R4` | truth, authority, continuity proof를 각각 제출 | `3:00~4:30` |
| `ENC-ARPG-25` The Fold That Refuses the Hand | field court encounter (A1) | `R8` | shape/medium mismatch를 `record_corruption`/status/clock write로만 표현 | `2:00~3:00` |

### 5.1 Family 19개 reachability

| family | canonical `region_role` | Reference Game에서 처음 보이는 encounter |
|---|---|---|
| `FAM-ARPG-01` Tally-Skin | `recovery_reentry` | `ENC-ARPG-01` |
| `FAM-ARPG-02` Return Usher | `recovery_reentry` | `ENC-ARPG-01` |
| `FAM-ARPG-03` Melted Index | `recovery_reentry` | `ENC-ARPG-02` |
| `FAM-ARPG-04` Grievance Ward | `hub_registration_ration_appeal` | `ENC-ARPG-03` |
| `FAM-ARPG-05` Stalled Bell | `intervention_scheduling` | `ENC-ARPG-08` |
| `FAM-ARPG-06` Seal Lancer | `permission_before_transformation` | `ENC-ARPG-14` (`H0`), `ENC-ARPG-16` (`R5`) |
| `FAM-ARPG-07` Script Moth | `translation_precedence` | `ENC-ARPG-04` |
| `FAM-ARPG-08` Boundary Hound | `translation_precedence` | `ENC-ARPG-04` |
| `FAM-ARPG-09` Record Sponge | `recovery_reentry` | `ENC-ARPG-06` |
| `FAM-ARPG-10` Organ Chorus | `organ_authority_negotiation` | `ENC-ARPG-05` |
| `FAM-ARPG-11` Incision Envoy | `organ_authority_negotiation` | `ENC-ARPG-05` |
| `FAM-ARPG-12` Kinward Mob | `resource_allocation` | `ENC-ARPG-06` |
| `FAM-ARPG-13` Aggregate Grazer | `resource_allocation` | `ENC-ARPG-07` |
| `FAM-ARPG-14` Coldwater Pilgrim | `resource_allocation` | `ENC-ARPG-07` |
| `FAM-ARPG-15` Audit Ox | `boundary_crown_precedence` | `ENC-ARPG-09` |
| `FAM-ARPG-16` Static Tithe | `intervention_scheduling` | `ENC-ARPG-08` |
| `FAM-ARPG-17` Seam Bailiff | `boundary_crown_precedence` | `ENC-ARPG-09` |
| `FAM-ARPG-18` Living Ledger Avatar | `translation_precedence` | `ENC-ARPG-10` |
| `FAM-ARPG-19` Grading Wall | `magic_training_craft_labor` | `ENC-ARPG-25` (A1) |

- `FAM-ARPG-19`과 `ENC-ARPG-25`는 `R8` A1 data-only addition이다. 둘 다 `changed_core_files == []`으로 land한다.
- `ENC-ARPG-25`는 field encounter이며 boss가 아니다. roster는 `FAM-ARPG-19 x1` + `FAM-ARPG-02 x1`이고 `group: null`이다.
- `ENC-ARPG-25`의 action: baseline `ACT-CGW-GRADE-MARK`, `ACT-RU-STAFF-PULSE`. signature `ACT-CGW-FOLD-VERDICT`, `ACT-RU-NAME-CALL`. valid counter `ACT-CGW-DISPERSE-READING` (threshold 미만). `FAM-ARPG-01`/`02`의 `ACT-TS-PIN`/`ACT-TS-REDA-SWEEP`/`ACT-RU-NAME-CALL`은 이미 존재하므로 재사용만 한다.
- `ENC-ARPG-25`의 target priority는 `record:residue ledger` → `record:course index row` → `resource_node:node disperser stock` → `linked_actor:residue record` → Grading Wall → recording clerk다. clamp arm은 `unbreakable`이고 true target이 아니다.
- 5개 group은 `ENC-ARPG-01`, `ENC-ARPG-05`, `ENC-ARPG-07`, `ENC-ARPG-09`, `ENC-ARPG-10`, `ENC-ARPG-19`, `ENC-ARPG-21`, `ENC-ARPG-22`, `ENC-ARPG-24`에서 사용된다. 6번째 group은 없다. 6개 variant는 `VAR-ARPG-01`~`VAR-ARPG-06`이고 `VAR-ARPG-06`(`ENC-ARPG-25-WITHDRAWN`)의 declared solution은 `medium match`, `dispersal action`, `labour-record withdrawal`다.
- 5개 NPC conversion의 `npc_stable_id`는 `npc_02_orrin_kest`, `npc_04_sable_halm`, `npc_05_nera_voss`, `npc_01_ilyra_senn`, `npc_14_eda_marrow`다. conversion은 relationship/death/absence/port를 지우지 않는다.

## 6. Event cluster 9개

각 cluster는 6~12 core NPC, 2~4 institutions, 2~3 clocks, partial truth, resource conflict, immediate/delayed consequence를 가진다. NPC가 한 장소에 모두 모이지 않아도 된다. cluster participant는 canonical core roster 14명에서만 뽑는다.

| Cluster | Node | core NPC 수 | institutions / clocks | 고정 choice | immediate → delayed |
|---|---|---:|---|---|---|
| `HC-00` The First Docket | `H0` | 7 | Exchange Registrar, Crier Office, Contract Counter / `CL-INST`, `CL-REC`, `CL-PER` | `withhold category` 후 `sponsor a return` | arrival docket, A provisional, B category, route debt → `R3`/`R5` NPC가 care sponsor 또는 labor witness로 갈리고, `R4`가 filing을 거부하면 첫 public record가 생긴다 |
| `RC-01` Wrong Return | `R1` | 7 | Return Registry, Kiln Wardens, Bellhouse intake office / `CL-CONT`, `CL-INST`, `CL-PER` | `carry claimant` | C branch, `K` increment, `E06`/`E07` candidate → `R4` pending record, `R6` body authority 후보, `H0` return hearing 2회 |
| `RC-02` Same Water | `R2` | 7 | Water Council, Seed Vault, Settlement Council / `CL-RES`, `CL-CONT`, `CL-PER` | `share` 후 medicine ferry 또는 settlement에 seed 1단위 배정 | E buffer, public ration, `E08`/`E17` state, `R2-09`/`R2-10` Filing → `R6` medicine price, `R7` shelter capacity, `E18` resource gate |
| `RC-03` Mercy Delay | `R3` | 8 | Hospice Covenant, Faith Engineering unit, Care Union / `CL-INST`, `CL-PER`, `CL-REC` | `split the window` | intervention stage, `mana_profile`, role decision, `E10`/`E11` candidate → `R5` boot contract와 `R4` archive outcome이 서로 다른 operator name을 생산 |
| `RC-04` Sentence Above the Stair | `R4` | 7 | Translation Tribunal, Record Office, Censor Office / `CL-REC`, `CL-INST`, `CL-CROWN` | `publish contradiction` | canonical flag, A contested, `E12`/`E13` category, `glossary` 선점 → `R5` labor role, `R7` wall category, `R8` course naming |
| `RC-05` Uniform, Name, Contract | `R5` | 7 | Glasswing Ordinal, Labor Court, Support Registry / `CL-INST`, `CL-CONT`, `CL-PER` | `staged boot` + `record partner permission` | B operator, labor legitimacy, transformation lineage, `E14`/`E15`/`E18` gate → `R3`/`R6`가 같은 사람을 다르게 부르고 `H0` route debt 생성 |
| `RC-06` The Heart's Petition | `R6` | 7 | Gristmarket Clinic, Debt Court, Organ Exchange / `CL-PER`, `CL-CONT`, `CL-RES` | `split custody` | organ authority, bypass lineage, cure debt, `E16` candidate, medium residue → `R1` recovery chamber가 clinic annex로 바뀌고 `R4`가 organ을 object/person 중 무엇으로 쓰는지 결정 |
| `RC-07` Map Made by the Wall | `R7` | 8 | Boundary Survey, Settlement Council, Crownwell Archive / `CL-CROWN`, `CL-CONT`, `CL-REC` | `keep the wall closed` 후 seed destination 명시 또는 `align recovery`/`align recognition`/`align authority` | C alignment, topology 재작성, `E09`/`E13`/`E16` redirect, `contract_tally` → `H0`+`R1`~`R6` 모든 revisit에 one named debt |
| `RC-08` The Fold That Refuses the Hand | `R8` | 7 | `MAG_ACADEMY` curriculum office, `CIRCULATION_BOARD`, `LINEAGE_HOUSE` registrar, `VOID_CONTRACT_COURT` / `CL-INST`, `CL-PER`, `CL-REC` | `register concentration` 후 `place in lineage` 또는 `withdraw and take the labor record` | `concentration sample` 등록, `lineage_token`/`craft_credit` 배분, `R8` region state → `R4` glossary 충돌, `R5` labor 재분류, `R2` `E` 전진, `R7`/`R8-06` contract conflict |

- 위 표의 institution 명칭은 `02` §9.3의 canonical 문자열을 쓴다.
- cluster 결과는 dialogue 한 줄이 아니다. 최소 한 field/object/NPC/resource/record/route surface와 한 non-dialogue domain surface가 함께 변해야 한다.
- retained seed 2개 이상 cross-link를 가져야 하고, magic seed가 `R8`에만 묶이면 `unbound`다.

## 7. Orthogonal axes

`02` §3의 token 순서와 `-3..3` integer mapping을 그대로 인용한다. 값을 합산하거나 combat HP, ending score, single progress bar로 바꾸지 않는다.

| Axis | 고정된 값 순서 | Reference Game write | 바꾸지 않는 것 |
|---|---|---|---|
| A `protocol_legitimacy` | `unlicensed → provisional → sanctioned → contested → successor` | arrival stamp, care/translation/operator permit, institution response, `G5` 결과 | 대상 category, continuity debt, resource 양 |
| B `recognition_drift` | `person → patient → operator → artifact → organ-authority → unclassified` | legal name, dialogue address, command label, enemy target priority, `mana_profile` sub-category | permission, recovery history, combat balance |
| C `continuity_pressure` | `single → linked → branched → loop-bound → crown-debt` | return profile, clone/name/organ/role relation, `lineage_token`, companion support | recognition stage, resource stage, raw HP |
| D `resource_scarcity` | `buffered → rationed → localized → strained → failing → collapsed → externally-mediated` | water, `medium_blank`, `fold_sheet`, `craft_credit`, care labor, attention, route access | protocol authority, category recognition, player identity |

- D축은 **7칸**이다. `strained` 단계를 빠뜨린 6단계 축약은 이 파일에서 사용하지 않는다.
- axis는 상시 HUD에 표시하지 않는다. 한 event가 두 축 이상을 바꾸면 각 write와 immediate/delayed consequence를 `02` §9.2의 별도 transaction step으로 기록한다.
- `concentration`, `mana_profile`, `craft_credit`는 축이 아니다. `D`와 `K`에 영향을 주는 원인 또는 별도 `magic` record다.
- 5번째 축을 만들지 않는다.

## 8. Pressure clock 6개

`CL-INST`/`CL-CONT`/`CL-REC`/`CL-RES`/`CL-PER`/`CL-CROWN`은 `02` §4의 6개 clock과 1:1이다. stage vocabulary도 `02` §4.1의 닫힌 6칸을 쓴다.

| Clock | 시작 단계 (`02` §4.2 manifest) | escalation | intervention | irreversible point (stage 4) | Reference Game evidence |
|---|---|---|---|---|---|
| `CL-INST` | `H0 assigned`, `R1 noticed`, `R2`~`R8 assigned` | category narrowing, 담당자 배정 | 기관의 local protocol 실행 | 공식 dispatch 또는 operator replacement 기록 | `HC-00`, `RC-05`, `RC-08` aftermath, `E18` seizure |
| `CL-CONT` | `H0/R4 clean`, `R1/R3/R5 exposed`, `R2/R6 active`, `R7 systemic`, `R8 clean` | recovery/recognition failure 누적 | 격리, 우회, 검사, 치료 | contamination이 현재 protocol의 복구 경로를 재정의 | `ENC-ARPG-02`, `ENC-ARPG-13`, `R2-09` provenance 불일치, `R5-03` residue 회수 |
| `CL-REC` | `H0/R3/R6/R8 private`, `R1/R2/R5 circulating`, `R4 filing`, `R7 canonical` | rumor, form, screenshot가 category를 확정 | archive/court/crier가 public copy 생성 | contradictory record가 하나의 canonical record가 됨 | `H0-05`, `ENC-ARPG-04`, `ENC-ARPG-14`, `ENC-ARPG-17`, `ENC-ARPG-18`, `R4-03`, failed fold screenshot |
| `CL-RES` | `H0 buffered`, `R1 localized`, `R2 failing`, `R3/R5/R8 localized`, `R4 rationed`, `R6 failing`, `R7 collapsed` | ration, substitution, debt 일상화 | seed/parts/attention/medicine 재분배 | 한 cycle buffer 0 또는 외부 공급 차단 | `npc_08_meral_dune`/`npc_14_eda_marrow` 결정, `ENC-ARPG-07`, `ENC-ARPG-21`, `R2-10` circulator |
| `CL-PER` | `H0/R4 role_bound`, `R1`~`R3/R5/R6/R8 divergent`, `R7 intervened` | memory, desire, organ voice가 다른 결정을 냄 | care, bargain, separation, public role change | NPC가 self-authored role을 기록 | `BODY_ARC_*`, `R5-04`, `R6-03`, `R8-05` 채점 |
| `CL-CROWN` | `H0 vacant`, `R1`~`R6/R8 contested`, `R7 contested` | institution이 자기 protocol을 crown에 제시 | operator 교체 또는 precedence 공개 | Crown Protocol이 precedence와 operator를 고정 | `R7-04`, `R7-07`, `G8`, `ENC-ARPG-24`, global revisit |

- clock은 real-time bar가 아니다. authored event commit과 region intervention 순서로 진행하며 combat animation/menu time으로 증가하지 않는다.
- 7번째 clock을 만들지 않는다. `concentration_field`, `body_load`, `circulation_slot`, `contract_tally`는 6개 clock의 입력값이다.
- 한 write가 두 clock을 전진시키지 않는다. 실패한 cast는 `K`(medium residue) 또는 `P`(body load) 중 하나만 고르고, `R`은 failure document가 Filing될 때만 움직인다. `C`는 contract 하나로 전진하지 않는다.

## 9. Recovery flow 7개 + Crown world write

recovery는 `08` §7의 self-layer 계약을 그대로 따른다. canonical recovery type은 **7개**이며 `crown_alignment`는 world write다.

| Type | Reference Game 진입 | 보존 | 초기화/변경 | 직접 확인 |
|---|---|---|---|---|
| `checkpoint` | `H0` 또는 region authored recovery facility | filed history와 현재 route | uncommitted encounter/field state | recovery surface에서 명시적으로 선택 |
| `respawn` | active encounter failure (`F` outcome) | filed world/NPC/resource/relationship | encounter-local combat만 | `ENC-ARPG-13` death 후 같은 source/counter |
| `institutional_reentry` | `R1`에서 `npc_02_orrin_kest`의 signature conflict 또는 `RC-01` death outcome | previous record | body/role/social category를 일부 보존/교체하고 contradictory copy 추가 | player가 원 name으로 즉시 appeal하지 못함 |
| `clone` | `R2` `ENC-ARPG-20`의 noncombat/failure resolution 후 `npc_11_cael_ren` consent | source individual | 새 body/legal/social identity와 branch cost | source가 복원되지 않고 새 이름이 Filing됨 |
| `loop` | `R5` `ENC-ARPG-15` maintenance/cycle (`REL-G1` hook) | player knowledge, filed debt, relationship | loop scope의 local mechanics/NPC action window만 | NPC는 player knowledge를 공유하지 않음 |
| `reincarnation` | `R3` care intervention의 authored alternate outcome (`BODY_ARC` hook) | 이전 record/archive debt | 새 body, 제한된 memory policy, 새 role/recognition | 이전 cycle NPC가 같은 role을 자동 인지하지 않음 |
| `immortality` | `R6` `npc_13_tovan_reed`의 redirected-death branch 선택 | current body function | death cost를 resource/social/continuity debt로 Filing | damage immunity만으로 끝나지 않음 |
| `crown_alignment` (world write, recovery 아님) | `R7` `RC-07` 후 `G8` | Crown와 이전 operator memory/record | `crown_precedence`, `operator_id`, `crown_object_phase`와 global route rewrite | 이전 phase는 revisit archive로만 읽고 global write는 reset되지 않음 |

- default flow는 authored failure마다 `respawn`/`checkpoint`를 사용한다. `F` outcome은 `checkpoint` kind에만 resolve한다.
- 7개 recovery type은 route/event authoring으로 실제 선택 가능해야 하며 debug menu로만 실행하지 않는다. 8번째 recovery type을 만들지 않는다.
- `crown_alignment`를 `rec_*.kind`로 기록하지 않는다. `contract_tally`과 `glossary` filled slot은 checkpoint 뒤에도 남는다.
- 이미Filing된 record, NPC removal, route permission, player knowledge는 death/load가 되돌리지 않는다.

## 10. Multi-route 플레이 흐름

### 10.1 Direct route — The Receipt Route (`ROUTE_RETURN`)

```text
E01 → E07 → E16 → E13 → E04
H0 → R1 → R6 → R7 → R4
```

- 시간: `18~25분`
- encounter: `ENC-ARPG-03`, `01`, `11`, `12`, `05`, `19`, `23`, `04`, `10`, `24` 10개
- 핵심 action: `HC-00 withhold category` → `RC-01 carry claimant` → `RC-06 split custody` → `R7` mandate change → `R4` three-proof terminal.
- 첫 revisit: `npc_11_cael_ren`을 `R1`과 `R4`에서 다른 category로 확인.
- recovery: `R1 institutional_reentry`와 `R6` failure `checkpoint`.
- relationship: `rel_11_cael_history` ≥ `rs_cael_self_authored`를 목표로 하고, romance commitment은 선택.
- ending eligibility: `end_r1_receipt_of_a_life` (`G1` + `RC-01 carry claimant`). `R8`은 열지 않고 `CONSEQ_13_CRAFT_CLASS_RECLASS`만 발생한다.
- 10분 acceptance에는 유효하지만 full content completion evidence는 아니다.

### 10.2 Body route — The Split Form Route (`ROUTE_BODY`)

```text
E03 → E11 → E14 → E16 → E13 → E04
H0 → R3 → R5 → R6 → R7 → R4
```

- 시간: `30~42분`
- encounter: `ENC-ARPG-03`, `15`, `08`, `16`, `05`, `19`, `23`, `04`, `17`, `24` 10개
- 핵심 action: `RC-03 split the window` → `RC-05 staged boot + record partner permission` → organ co-signature → transformed document → final continuity proof.
- body evidence: transformation success와 social recognition failure가 별도로 남음.
- romance: `npc_04_sable_halm` `REQUEST_CONSENT → ALLOCATE_EXECUTION_SPACE → CUT_DEPENDENCY → SURRENDER_SUPPORT`.
- recovery: `loop` rehearsal, `reincarnation`, organ continuity `checkpoint`를 구분.
- ending eligibility: `end_o1_many_mouths_one_person` (`G3` + `G5` + `RC-06 split custody`).

### 10.3 Resource route — The Living Commons Route (`ROUTE_RECOGNITION`)

```text
E02 → E08 → E14 → E15 → E13 → E04
H0 → R2 → R6 → R5 → R7 → R4
```

- 시간: `30~40분`
- encounter: `ENC-ARPG-03`, `06`, `07`, `20`, `21`, `05`, `19`, `16`, `09`, `22`, `23`, `04`, `17`, `24` 14개
- 핵심 action: `RC-02 share` → clone name/role 분리 → medicine allocation → labor walkout/resource reroute → audit/boundary → archive correction.
- 첫 meaningful resource action: `npc_08_meral_dune`의 한 ration line을 medicine 또는 settlement에 배정.
- recovery: `clone`과 `immortality` redirected cost.
- late revisit: `R2` weather/audio/ration, `R5` service, `R4` public wording가 모두 변함.
- ending eligibility: `end_g1_law_without_master` (`G4` + `RC-04 publish contradiction`), `CONSEQ_15_GLOSSARY_CONFLICT`가 발동하면 `saved` 목록에 "이름 없는 craft"가 추가된다.

### 10.4 Craft route — The Folded Wage Route (`ROUTE_CRAFT`, A1 이후)

```text
E05 → E18 → E18 → E11 → E10 → E03
H0 → R2 → R8 → R5 → R4 → R3
```

- 시간: `25~35분` (A1 통과 이후에만 유효)
- 선행 조건: `G5`가 `full` 또는 `staged`로 Filing된 뒤 `E18`의 gate/resource/epistemic 세 조건을 실물로 확인한다. `G5`가 `refused`면 `E18`은 `closed`이고 우회는 `R5` 내부 industrial permit craft다.
- encounter: `ENC-ARPG-03`, `07`, `06`, `25`, `08`, `04`, `15` 7개
- 핵심 action: `RC-02 share`로 `E18` resource gate를 만들고 → `RC-08 register concentration` 후 `place in lineage` 또는 `withdraw and take the labor record` → `R3`에서 `E10`으로 왕복 leg를 닫는다.
- ending eligibility: `end_o1_many_mouths_one_person`(`ROUTE_CRAFT`). `RC-08`이 `RC-05`를 대체하고 `RC-03`가 추가 필수다(`03` §16.3).
- `R2`의 `E18` resource gate와 `RC-08`의 `concentration sample` provenance은 서로 다른 record로 남는다.

### 10.5 Full survey — Convergence Route

```text
H0
→ R1 → H0
→ R3 → R5 → H0
→ R2 → R6 → H0
→ R4 → R7
→ same-node aftermath
```

- 시간: `75~95분`
- node: `H0` + `R1`~`R7` 전부
- encounter: `ENC-ARPG-01`~`24` 전부
- family: `FAM-ARPG-01`~`19` 전부
- NPC: core 14명 모두 최소 한 system action과 late consequence를 가짐
- cluster: `HC-00`, `RC-01`~`RC-07` 전부 first resolution
- clock: 6개 모두 start→signal→intervention을 최소 한 번 보임
- axes: A/B/C/D가 서로 다른 authored write로 한 번 이상 변함
- terminal: `ENC-ARPG-24`의 victory, escape, noncombat proof 중 하나와 동일 node aftermath를 모두 별도 run에서 확인
- ending eligibility: `end_a1_empty_seat`(`G8` + `R4-07`) 또는 `end_c1_four_anchors`(`G0`~`G8` 전부 resolved + 6명 이상 sink). `end_c1`는 7개 recovery type 전부를 실제 authored surface에서 1회 이상 실행해야 한다.

full survey는 NPC를 한 장소에 모아 gigantic meeting으로 만들지 않는다. shared record, remote service, absent/dead state, body/role change로 영향을 전달한다.

### 10.6 Ending coverage — orphan 없는 종료

`03` §16.7의 downgrade 규칙대로 어떤 조합도 ending 없이 끝나지 않는다. `07`의 각 route가 어느 ending으로 resolve되는지 고정한다.

| `07` route | 최소 조건 | resolve되는 ending |
|---|---|---|
| `RG-M02` direct | `G1` + `RC-01 carry claimant` | `end_r1_receipt_of_a_life` |
| `RG-M03` body | `G3` + `G5` + `RC-06 split custody` | `end_o1_many_mouths_one_person` |
| `RG-M04` resource | `G4` + `RC-04 publish contradiction` | `end_g1_law_without_master` |
| `RG-M15` craft | `G5` + `RC-08` resolved + `RC-03` | `end_o1_many_mouths_one_person` (magic 조건 충족) |
| `RG-M05` full survey | `G8` + `R4-07` 세 permission | `end_a1_empty_seat` |
| `RG-M05` convergence | 2개 이상 lens bundle + `TRUTH_T3`+`TRUTH_T4` actionable | `end_c1_four_anchors` |
| 어떤 조건도 만족하지 못함 | — | `end_c2_last_witness` (지정된 fallback, 실패가 아님) |

- ending ID는 6종이 전부다. 어떤 ending도 content에서 재사용·삭제하지 않는다.
- `end_c1`가 요구하는 7개 recovery type 실행은 `RG-M09`, 14명 sink 확인은 `RG-M07`, romance/body는 `RG-M11`/`RG-M12`, A1은 `RG-M13`이 각각 증명한다.
- `end_c2`는 `respawn`/`checkpoint`만 사용하고 `RC-08`을 resolved cluster로 만들지 못한 run에서 지정된 결과로 발생한다. 이 경우 `E18`이 열려도 `RC-08`이 unresolved로 남는다.

## 11. First meaningful action과 revisit

| Node | 첫 meaningful action | 중기 revisit가 바뀌는 것 | late revisit가 바뀌는 것 |
|---|---|---|---|
| `H0` | `npc_02_orrin_kest`의 mismatch stamp 조사 | arrival category, route card, debt token, NPC service | canonical translation/operator/Crown phase별 counterweight wording |
| `R1` | `npc_11_cael_ren`의 body/name/role signature 분리 | wash 여부, return guard, organ annex, warm/redirected exit | archived wrong-return record와 Crown phase |
| `R2` | `npc_08_meral_dune`의 water line을 실제 reroute | ration, medicine price, climate/audio, census roster | outbound support obligation, `concentration_field` provenance, 외부 mediation |
| `R3` | `npc_04_sable_halm`의 care window에 player가 concrete priority 제출 | fast/stable recovery, consent form, school record, `mana_profile` | archive가 care outcome을 public category로 재생성 |
| `R4` | `npc_06_tamas_quill`의 두 source version 비교 | canonical/contradictory copy, archive access, enemy label, `glossary` | `G8` precedence와 이전 operator memory |
| `R5` | `npc_04_sable_halm`에게 transformation consent/permission 확인 | full/staged/refused boot, labor relation, support capacity, craft 실행 가능 목록 | name/labor record와 final route category, `R5-13` 원장 |
| `R6` | `npc_05_nera_voss`의 organ complaint를 끝까지 listen | surgery/cure/role priority, body target, medicine debt, residue 회수 | `R1`/`R4`가 organ을 person/object 중 무엇으로 읽는지 |
| `R7` | `npc_07_bryn_oskel`의 wall evidence를 record | wall phase, boundary route, seed/battery destination | old phase archive와 선택된 Crown protocol, 미해결 `contract_tally` |
| `R8` (A1) | `npc_09_perrin_lask`에게 lineage 배정표의 이름 없는 칸을 열게 함 | filed grade, `course index` row, `R5-03` 회수 medium | unresolved contract, `R4` glossary 두 줄 |

revisit는 같은 encounter를 다시 채우지 않는다. 최소 두 surface가 달라야 하고, one-shot effect는 다시 Filing되지 않는다.

## 12. Romance와 body-horror acceptance

### 12.1 Romance

`03` §12.1의 `rel_*` 14개 중 `rel_09_perrin_ward`만 `kinship` channel이고 romance를 열지 않는다. 나머지 13개는 romance `sink` state를 가질 수 있다.

**`rel_04_sable_support` (`npc_04_sable_halm`) — care → romance**

1. `REQUEST_CONSENT`: transformation capability를 player/NPC 공동 decision으로 만든다.
2. `ALLOCATE_EXECUTION_SPACE`: finite resource를 사용하여 bounded combat form을 연다.
3. `CUT_DEPENDENCY`: success를 relationship ownership으로 바꾸지 않고 독립 capacity를 만든다.
4. `SURRENDER_SUPPORT`: support authority를 공동 responsibility로 위임한다.
5. `ENC-ARPG-24`에서 history에 맞는 companion action을 실행한다.

**`rel_01_ilyra_record` (`npc_01_ilyra_senn`) — professional → romance**

1. `REQUEST_INDEX` + `SHOW_FRAGMENT`: source provenance를 묻고 private name을 category로 덮지 않는다.
2. `PROTECT_NAME` + `OPEN_UPPER_STACK`: consent 있는 person record를 유지하고 maintenance authority를 공동으로 넘긴다.
3. `SURRENDER_INDEX`: 단독 archive ownership을 포기한다.
4. `ENC-ARPG-17`/`ENC-ARPG-24`에서 contradictory record와 root proof를 각각 사용한다.
5. `rs_ilyra_institutional_threat` rupture와 repair, evidence-sharing에서 생기는 jealousy, independent exit을 허용한다.

**`rel_10_juno_channel` (`npc_10_juno_caster`) — professional → romance**

`FORWARD`/`VERIFY`/`WITHHOLD`로 public thread를 다룬 뒤 `OPEN_CHANNEL`/`RELEASE_ARCHIVE`로 channel을 넘긴다. `rs_juno_committed_archive`와 `rs_juno_fractured_channel` 중 하나가 run을 끝낸다.

두 path 모두 affection, care, jealousy, grief, reconciliation, chosen-family boundary를 authoring할 수 있다. **explicit sexual content, sexual reward, coercive intimacy, possession disguised as affection은 금지한다.** magic failure는 어떤 affection route의 state도 자동으로 닫지 않는다.

### 12.2 Body horror

| arc ID | binding | 두 surface 이상을 실제로 바꾸는 증거 |
|---|---|---|
| `BODY_ARC_PLAYER_FOUR_ANCHORS` | player body/memory/role/recognition 4 anchor | `PLAYER_LAYER_ROLE` permission 통과, `PLAYER_LAYER_BODY` organ priority 우회, `PLAYER_LAYER_RECOGNITION` gate category 무효화 |
| `BODY_ARC_CAEL_SAME_BODY_DIFFERENT_SOCIAL_CONTINUITY` | `npc_11_cael_ren` | `R1` recovery category와 `R4` legal name이 갈라지고, forced single identity는 NPC-boss state가 된다 |
| `BODY_ARC_ORGAN_QUORUM` | `npc_05_nera_voss`, `ENC-ARPG-05`, `ENC-ARPG-19` | organ/patient/clinic의 target priority와 consent link, treatment와 social recognition의 분리 |
| `BODY_ARC_ILYRA_WRONG_HISTORY` | `npc_01_ilyra_senn` | archive access와 affection evidence가 충돌하고 delayed record가 남음 |
| `BODY_ARC_TAMAS_TRANSLATION_DRIFT` | `npc_06_tamas_quill`, `ENC-ARPG-04`, `ENC-ARPG-17` | local law와 `R5` labor role / `R7` wall category가 동시에 재작성됨 |
| `BODY_ARC_SABLE_BOOT_RECOGNITION_SPLIT` | `npc_04_sable_halm`, `ENC-ARPG-16` | transformation success와 social recognition failure가 별도 record로 남음 |
| `BODY_ARC_MANA_PROFILE_NOT_MORAL_CLASS` | `npc_13_tovan_reed` + `npc_05_nera_voss`, `R3-01` | `mana_profile`가 `R5-01` boot 조건과 `R8-04` course 선택을 동시에 좁힘 |
| `BODY_ARC_ORGAN_MEDIUM_RESIDUE` | `npc_05_nera_voss`, `R6-01` + `R5-03` | residue 미회수 시 `R5-10`/`R5-12` cast 오차 상승, organ testimony 1건 소실 |
| `BODY_ARC_FAILED_FOLD_TERMINAL` (A1) | `R8-05`, `ENC-ARPG-25` | `terminal` 등급이 course option을 닫고 `R4-05 Name Hearing`이 다시 열림. 학생은 region에서 제거되지 않음 |
| `BODY_ARC_PORTAL_DEFERRED_SELF` (A1) | `R7-09`/`R8-06`, `contract_tally` | contract obligation이 death/recovery로 회수되지 않고 `G8` 해석 입력이 남음 |

- 각 body event는 combat target/status, recovery, relationship, access, document, route 중 두 surface를 실제로 바꿔야 한다.
- body horror를 cutscene spectacle, transformation reward, shock image로만 처리하지 않는다. 모든 body change는 consent owner, state, resource, recognition, delayed consequence를 가진다.
- `BODY_ARC_MANA_PROFILE_NOT_MORAL_CLASS`, `BODY_ARC_ORGAN_MEDIUM_RESIDUE`, `BODY_ARC_FAILED_FOLD_TERMINAL`, `BODY_ARC_PORTAL_DEFERRED_SELF`는 A1 이후에만 실제 플레이 evidence가 된다. A1 이전에는 `TRUTH_T6`/`TRUTH_T7`이 `corroborated`까지만 올라간다.

## 13. Replay와 revisit 절차

- 같은 run: `H0`의 physical counterweight map와 방문한 direct/alternate edge로 재진입한다. hidden teleport와 long backtrack은 없다.
- encounter rematch: `05`의 repeat/variant policy를 따른다. one-shot reward, NPC filing, clock write를 다시 만들지 않는다.
- route replay: clean reset 또는 새 profile로 다른 cluster order를 선택한다.
- known solution: player가 이미 아는 gate, command, source term, encounter counter는 discovery timer 없이 즉시 실행한다.
- NPC knowledge: NPC/institution은 player knowledge를 공유하지 않는다.
- recovery replay: `08`의 lineage과 `commit_log`를 보존한 채 current encounter만 reset한다.
- ending/terminal replay: `ENC-ARPG-24`의 victory, escape, noncombat proof를 각각 별도 run에서 확인하고 같은 node를 재방문한다.
- `A1` 이후에는 `R8`의 두 return affordance(`E18` 왕복, `course index return`)와 `VAR-ARPG-06` late variant를 별도로 확인한다.
- direct/body/resource/craft/full survey 중 최소 3개 run log를 서로 다른 evidence로 보관한다.

## 14. Authored content addition A1 — `R8 The Folding School`

A1은 **새 region 1개 + 새 support NPC 7명 + 새 authored encounter 1개**를 추가하면서 core 파일을 0바이트 바꾸는{data-only} 확장을 증명한다. "새 내용이 없다"는 주장이 아니라, 새 authored content가 정확히 무엇인지와 그것이 기존 schema만으로 들어가는지를 함께 증명한다.

### 14.1 추가 content

baseline 24 encounter(`ENC-ARPG-01`~`24`)와 18 family(`FAM-ARPG-01`~`18`)가 모두 validation된 뒤 다음 package을 추가한다.

- **새 region:** `R8 The Folding School`
  - canonical `region_role`: `magic_training_craft_labor`
  - entry: `E18 R5–R8`, gate `G5`만. `G9` 없음. `H0` route 없음(`SERVICE_R8_COURSE_INDEX`는 service index 문서 한 건이다)
  - causal thesis: 배운 craft를 누구의 노동로 기록할 것인가
  - authorities: `MAG_ACADEMY` curriculum office, `CIRCULATION_BOARD`, `LINEAGE_HOUSE` registrar, `VOID_CONTRACT_COURT`
  - two return affordance: `E18` 왕복, `R8` 내부 `course index return`
  - `R8-01`~`R8-08` family 8개 (`Course Index`, `Concentration Registration`, `Lineage Placement`, `Course Selection`, `Fold Failure Hearing`, `Void Contract Filing`, `Lineage Refusal`, `Field Probation`)
- **새 support NPC 7명:** `npc_20_mira_vask`, `npc_21_halen_osk`, `npc_22_iven_marrow`, `npc_23_turo_bex`, `npc_24_perri_lowe`, `npc_25_jano_fesk`, `npc_26_cael_orin`
  - 전부 `roster_kind: "support"`. `npc_15`~`npc_19`를 쓰지 않는다
  - 각각 `id`, `public_role`, `private_role`, `capability.port_ids`, `resource_access`, `knowledge_boundary`, `clock_ids`, `cross_link_ids` 2개 이상, `absence`, `oneoff_dialogue_seed_ids`를 가진다
  - 학교 측 write field 4개(`course index`/`student status`/`craft credit`, `concentration_field` 측정·배정, `lineage_token`, `contract_tally`+contract 문서) 밖의 field를 쓰지 않는다
- **새 authored encounter 1개:** `ENC-ARPG-25 The Fold That Refuses the Hand` (content ID `enc_fold_that_refuses_the_hand`)
  - `type`: field court encounter. boss 아님
  - `region_id`: `region_r8_folding_school`; `region_secondary`: `region_r5_glasswing_ordinal`, `region_r7_hollow_orchard`
  - roster: `FAM-ARPG-19 x1` + `FAM-ARPG-02 x1`. `group: null`. 새 enemy implementation 0건
  - 새 action: `ACT-CGW-GRADE-MARK`, `ACT-CGW-FOLD-VERDICT`, `ACT-CGW-DISPERSE-READING` 3개뿐이고, 나머지는 기존 action 재사용
  - 새 status: `concentration_load`, `medium_residue`, `misfolded`, `overflowed`, `contract_bound` 5개뿐
  - rule: shape/medium mismatch는 spell rename이 아니라 `record`/`status`/`clock` write로만 표현한다
  - valid counters: marked verdict Break, threshold 미만 dispersal, 명시된 `shape_or_pattern`과 일치하는 `medium_blank`/`fold_sheet` 제출, hearing에서 alternate shape 수용, `record:residue ledger` sever, `circulation_slot` route 개방과 이웃 비용 지불, commitment 전 contract Filing/거부, noncombat withdrawal
  - invalid responses: spell/shape rename, clamp arm만 공격, mismatched medium, `medium_residue`를 damage로 grinding, `concentration_load`를 damage multiplier로 사용, magic 전용 combat rule 추가
  - noncombat resolution: `withdraw and take the labor record` 또는 `R8-05` Filing
  - `NPC-CONV-ARPG-05 Crafting Wrangler`의 `npc_stable_id`는 `npc_14_eda_marrow`다. `npc_20_mira_vask`~`npc_26_cael_orin`은 conversion subject가 아니다
  - `VAR-ARPG-06 ENC-ARPG-25-WITHDRAWN`의 declared solution 3종을 실제로 실행한다
- **새 authored record:** `doc_r8_course_index`, `doc_r8_concentration_registration`(지점·시각·측정값·`provenance` 4칸 모두 필수), `doc_r8_fold_failure_hearing`, `doc_r8_supply_rack_receipt`, `SERVICE_R8_COURSE_INDEX`(기존 service schema에 한 index row)
- **새 aftermath:** `prop_r8_cut_chamber_failed_fold`가 filed grade / dispersed residue / recovered medium at `R5-03` / unresolved contract 4개 revisit variant를 공급한다
- **새 recovery type / 새 axis / 새 clock / 새 target mode / 새 lifecycle / 새 status op / 새 phase trigger:** 0건

### 14.2 Strict no-core-edit proof

1. domain, systems, loader/validator algorithm, save codec, input router, presentation controller, combat core, target enum의 pre-add SHA-256 manifest를 기록한다.
2. `modules/top_down_action_rpg/content/` 아래 `R8` region record, `npc_20_*`~`npc_26_*` 7명, `ENC-ARPG-25`, `VAR-ARPG-06`, `NPC-CONV-ARPG-05`, `FAM-ARPG-19`, `ACT-CGW-*` 3건, magic status 5건, `res_*` magic key 10건, document, aftermath, service record만 추가한다.
3. `06` §3.5의 `region_r8_folding_school` / `route_e18_folding_school_approach` re-key, `gate_g5` 재사용, `06` §6.3 magic `res_*` registry, save projection allowlist에 `magic` 하위 6 record를 등록한다. 이 등록은 content catalog 갱신이며 core algorithm 변경이 아니다.
4. content validation, route probe, recovery probe를 다시 실행한다.
5. `E18` 진입, `RC-08` conversation, `ENC-ARPG-25` combat과 noncombat, `VAR-ARPG-06`, document, aftermath, `SERVICE_R8_COURSE_INDEX`를 실제로 플레이한다.
6. save/load, reset/re-entry, `concentration_field` threshold 초과, failed fold 3등급(`recoverable`/`continuity-changing`/`terminal`), delayed public record, NPC absence를 확인한다.
7. `R4` `glossary` slot 비어 있음 → craft 이름이 `untranslated term`으로 Filing되는지 확인한다. 학교 이름과 archive 번역이 다르면 두 줄이 남는다.
8. `contract_tally`이 자동 해소·tick down·combat cost로 소모되지 않는지 확인하고, `G8`에서 `crown_protocol` 안/밖 위치를 명시한다.
9. 같은 core file들의 post-add SHA-256가 pre-add와 byte-identical해야 한다. → `changed_core_files == []`
10. authored ID/dialogue를 production `.gd`에 추가한 변경 0건이어야 한다.
11. core hash 또는 algorithm이 한 줄이라도 바뀌면 A1은 실패다.
12. `project.godot` diff 0, dependency 추가 0, new shared abstraction 0이어야 한다.
13. A1은 `R8` region, support NPC 7명, `ENC-ARPG-25` 세 항목을 모두 플레이 evidence로 확인하기 전 통과로 세지 않는다. 세 항목 중 하나라도 evidence가 없으면 A1 실패다.

## 15. Completion evidence

### 15.1 Content inventory

- `H0` 1개와 `R1`~`R8` 8개 region의 physical field/aftermath capture, `E01`~`E18` 18개 edge 통과 capture.
- core 14명 각각의 first action, system port, survival/death/absence, revisit log.
- `npc_20_mira_vask`~`npc_26_cael_orin` 7명 각각의 `R8` write field port, absence result, filed/remote surface log.
- `FAM-ARPG-01`~`19` 전부의 first encounter/counter/aftermath log.
- `ENC-ARPG-01`~`25` 전부의 victory 또는 authored noncombat resolution log.
- `GRP-ARPG-01`~`05` 5개, `VAR-ARPG-01`~`06` 6개, `NPC-CONV-ARPG-01`~`05` 5개 사용 log.
- `HC-00`, `RC-01`~`RC-08` 각각의 6~12 core NPC impact table.
- A/B/C/D axis 시작값과 독립 write 기록(D는 7칸 전체 사용).
- `CL-INST`, `CL-CONT`, `CL-REC`, `CL-RES`, `CL-PER`, `CL-CROWN` 각각의 signal/intervention/aftermath 기록.
- seed ledger: core 120 + magic supplement 40 = denominator 160, distinct `PLANNED_RETAINED` transform **96** 이상, preferred target **120`. 이전 판의 120/72/90 수치는 사용하지 않는다. planning 단계에서 `used`/`transformed`를 주장하지 않는다.
- aggregate score, global danger bar, hidden truth route, 5번째 축, 7번째 clock, 8번째 recovery type은 0건.

### 15.2 Play evidence

`10_TESTS_AND_ACCEPTANCE.md`의 `PLAYTHROUGH.md`와 `acceptance_playthrough.json`에 다음을 기록한다.

- direct route 18~25분
- body route 30~42분
- resource route 30~40분
- craft route 25~35분 (A1 이후)
- full survey 75~95분
- 각 run의 first meaningful action, active time, region/route/encounter/action/document/choice ID
- backtracking, focus loss, misinput, recovery, save/load, terminal result
- full survey에서 core 14명, 25 encounter, 19 family, 9 cluster의 reachability
- 각 run이 resolve된 ending ID
- long movement/wait/repeat combat을 제외한 이유

### 15.3 Relationship/body/recovery

- `rel_04_sable_support` 최소 한 run, `rel_01_ilyra_record` 또는 `rel_10_juno_channel` 최소 한 run.
- 각 romance의 refusal, jealousy/rupture 또는 repair, final companion action.
- `BODY_ARC_*` 10개 중 A1 전 6개 + A1 후 4개를 각각 combat/resource/relationship/document surface로 확인.
- recovery 7 type을 실제 authored surface에서 실행하고 preserve/discard self layer를 기록.
- death/load가 filed NPC, record, resource, route를 되돌리지 않음을 확인.
- explicit sexual content, sexual reward 0건.

### 15.4 Save/revisit

- `H0` checkpoint 전후, `R1` institutional re-entry, `R2` clone branch, `R5` loop, `R7` crown world write에서 save/load.
- 같은 node를 immediate aftermath와 late revisit에 각각 capture.
- presentation-only focus/tween/page pixel은 복원되지 않고 semantic source는 복원됨.
- `contract_tally`과 `glossary` filled slot은 checkpoint 뒤에도 남음.
- required stale ID는 임의 NPC/region으로 대체되지 않음.

### 15.5 Resolution/UI

- 1280×720, 1920×1080, 2560×1440에서 field, dialogue, choice, document, corruption, combat, target, charge, guard/dodge/break, aftermath, recovery, success를 capture한다.
- A~H의 world-preserving dialogue, command-first combat, document paging, corruption, aftermath 순서를 비교한다.
- focus/cancel/return, unavailable, extreme red와 focus 분리, long text, maximum page(9줄)를 확인한다.
- 상시 Shell HUD, space label, autosave label, debug label, placeholder ColorRect/Label world는 0건.

### 15.6 A1

- pre/post core SHA-256 manifest와 `changed_core_files == []`
- A1 content-only diff
- `R8` region / `npc_20_*`~`npc_26_*` / `ENC-ARPG-25` 실제 play log
- content/full route test result
- production authored-ID/dialogue hardcode 0건

## 16. Exact manual play tasks

### `RG-M01` — First meaningful action

1. 새 profile과 fresh save를 만든다.
2. Input Bubble이 끝나면 stopwatch를 시작한다.
3. `npc_02_orrin_kest`에게 `interact` intent를 보내 arrival stamp 하나를 조사한다.
4. body/role/record mismatch, `H0` door 변화, NPC trust/recognition projection을 순서대로 capture한다.
5. 통과: 30초 이내 mismatch observation, 별도 tutorial/quest text 0건.

### `RG-M02` — Direct route (`ROUTE_RETURN`)

1. `HC-00`에서 category를 보류하고 한 return을 sponsor한다.
2. `R1`에서 `RC-01 carry claimant`를 실행하고 `ENC-ARPG-01`, `ENC-ARPG-11`, `ENC-ARPG-12`를 해결한다.
3. `R6`에서 `ENC-ARPG-05`를 organ negotiation으로 끝낸다.
4. `R4`에서 `ENC-ARPG-04`, `ENC-ARPG-10`의 source와 category를 expose한다.
5. `R7`에서 `ENC-ARPG-23` mandate를 바꾸고 `ENC-ARPG-24` noncombat proof를 선택한다.
6. 같은 node를 재방문한다.
7. `rel_11_cael_history`를 `rs_cael_self_authored`까지 진행하거나 refusal을 유지한다.
8. 통과: active time 18~25분, 10 encounter, one document/thread, one partial success, changed revisit, `end_r1_receipt_of_a_life` 또는 명시적 `end_c2_last_witness` fallback이 resolve됨.

### `RG-M03` — Body route (`ROUTE_BODY`)

1. `R3`에서 `RC-03 split the window`를 실행하고 `ENC-ARPG-15` maintenance로 끝낸다.
2. `RC-05 staged boot + record partner permission`을 Filing한다.
3. `ENC-ARPG-16`에서 permit/consent source를 revoke하거나 renegotiate하고 `ENC-ARPG-08` relay를 disconnect한다.
4. `R6`에서 organ/patient co-signature를 만든다.
5. `R4`/`R7`에서 transformation success와 social recognition failure를 분리한다.
6. 통과: 30~42분, `rel_04_sable_support` romance 또는 explicit refusal/repair state, body state가 combat/recovery/relationship에 모두 남음, `end_o1_many_mouths_one_person` resolve.

### `RG-M04` — Resource route (`ROUTE_RECOGNITION`)

1. `R2`에서 `npc_08_meral_dune`의 한 water line을 medicine 또는 settlement에 배정한다.
2. `ENC-ARPG-06`, `ENC-ARPG-20`에서 clone name과 outlier을 Filing한다.
3. `ENC-ARPG-07`, `ENC-ARPG-21`에서 safe-water source를 verify하거나 collapse를 감수한다.
4. `R6`에서 medicine/attention을 organ testimony에 배정한다.
5. `R5`에서 `npc_14_eda_marrow`의 labor action으로 support capacity를 재분배하고 `RC-04 publish contradiction`를 실행한다.
6. `R7`에서 audit debt와 wall writ를 route proof로 우회한다.
7. `R4`에서 translation result가 public copy와 NPC role에 미치는 delayed effect를 확인한다.
8. 통과: 30~40분, resource decision이 combat, NPC, route, climate/revisit에 모두 나타남, `end_g1_law_without_master` resolve.

### `RG-M05` — Full survey

1. `H0→R1→R3→R5→R2→R6→R4→R7` 순서로 clean start부터 실행한다.
2. `ENC-ARPG-01`~`24`를 각각 한 번 first resolution한다.
3. core 14명의 system action을 최소 한 번 수행한다.
4. `HC-00`, `RC-01`~`RC-07`을 모두 commit한다.
5. 6 clock 각각의 signal과 intervention을 기록한다.
6. 4 axis가 서로 다른 event에서 변하는지 확인한다. (D는 7칸)
7. `G8` operator/precedence를 명시하거나 convergence 조건을 만든다.
8. 통과: active time 75~95분, long movement/wait/repeat combat 없이 full inventory 달성, `end_a1_empty_seat` 또는 `end_c1_four_anchors` resolve.

### `RG-M06` — Counter matrix

1. `ENC-ARPG-11`에서 Guard, Dodge, marked Break, valid seal을 각각 시험한다.
2. `ENC-ARPG-13`에서 resource threshold와 unbreakable fringe를 구분한다.
3. `ENC-ARPG-19`에서 link-break, consent, noncombat resolution을 실행한다.
4. `ENC-ARPG-20`에서 owner Break가 아니라 두 link sever가 필요한지 확인한다.
5. `ENC-ARPG-23`에서 Break-only가 실패하고 route/mandate counter가 성공하는지 확인한다.
6. `ENC-ARPG-24`에서 root projection HP가 아니라 truth/authority/continuity proof로 끝나는지 확인한다.
7. 통과: 모든 signature에 telegraph, valid counter, invalid counter, aftermath가 있고 universal Break가 없음.

### `RG-M07` — NPC consequence

1. core 14명의 `system port`, first action, late result를 `PLAYTHROUGH.md`에 행으로 기록한다.
2. 최소 2명을 NPC conversion으로 종료한다(`NPC-CONV-ARPG-01`~`05`).
3. 최소 2명을 noncombat으로 종료한다.
4. 최소 1명을 death/removal하고 다른 region의 delayed effect를 확인한다.
5. 최소 1명을 absence로 종료하고 empty service/record가 남는지 확인한다.
6. `npc_20_*`~`npc_26_*` 7명의 absence result를 확인하고, core 수에 포함되지 않았음을 확인한다.
7. 통과: dialogue-only NPC 0, NPC skin만 바꾼 combat 0, initial NPC 자동 재생성 0, 15번째 core `npc_*` 0건.

### `RG-M08` — Axes and clocks

1. fresh state에서 A/B/C/D와 6 clock의 initial signal을 capture한다.
2. `HC-00`, `RC-01`, `RC-02`, `RC-04`, `RC-05`, `RC-06`, `RC-07`을 순서대로 commit한다.
3. 각 write가 어떤 axis와 clock을 독립적으로 바꾸는지 표로 기록한다.
4. 한 event가 두 축을 건드렸다면 separate write/consequence가 존재하는지 확인한다.
5. 한 transaction이 두 clock을 전진시키지 않았는지 확인한다.
6. aggregate score와 single danger bar 0건을 확인한다.
7. 통과: axis 공유·합산·자동 normalization 0건, 5번째 축 0건, 7번째 clock 0건.

### `RG-M09` — Recovery 7 types + Crown world write

1. `ENC-ARPG-13`에서 death → `respawn`을 실행한다.
2. `H0` authored facility에서 `checkpoint` return을 실행한다.
3. `R1` `npc_02_orrin_kest`를 통해 `institutional_reentry`를 실행한다.
4. `R2` `ENC-ARPG-20` alternate outcome에서 `clone`을 실행한다.
5. `R5` `ENC-ARPG-15` maintenance cycle에서 `loop` rehearsal을 실행한다.
6. `R3` care intervention에서 `reincarnation` alternate를 실행한다.
7. `R6` `npc_13_tovan_reed`를 통해 `immortality` redirected-cost branch를 실행한다.
8. `R7` `RC-07` 후 `G8` world write를 실행하고 `crown_precedence`/`operator_id`/`crown_object_phase`를 확인한다.
9. 각 결과의 body/memory/role/belief/institution/desire/social recognition 보존표를 채운다.
10. 통과: 7 type이 같은 modal/HP refill/world reset으로 합쳐지지 않음, `crown_alignment`가 `rec_*.kind`로 기록되지 않음, 8번째 type 0건.

### `RG-M10` — Save/load/revisit

1. `H0` 직전, `R1` `RC-01` 직후, `R2` `ENC-ARPG-20` 직후, `R5` loop 직후, `R7` phase 2에서 save한다.
2. 각 save를 process 종료 → 재실행 → load한다.
3. field/NPC/record/resource/route/axis/clock/relationship/continuity를 비교한다.
4. immediate aftermath와 late revisit을 나란히 capture한다.
5. 통과: filed consequence와 player knowledge 유지, presentation-only state만 재계산, `contract_tally`/`glossary` 유지.

### `RG-M11` — Romance

1. `rel_04_sable_support` run에서 `REQUEST_CONSENT`, execution-space allocation, dependency cut, shared support authority를 차례로 수행한다.
2. `rel_01_ilyra_record` 또는 `rel_10_juno_channel` run에서 `REQUEST_INDEX`+`SHOW_FRAGMENT`, `PROTECT_NAME`+`OPEN_UPPER_STACK`, `SURRENDER_INDEX`를 수행한다.
3. 각 run에서 refusal 또는 jealousy/rupture를 한 번 발생시키고 repair/independent exit을 확인한다.
4. `ENC-ARPG-24` companion action이 해당 history에서만 열린는지 확인한다.
5. `rel_09_perrin_ward`가 romance를 열지 않는지 확인한다.
6. 통과: non-explicit intimacy, history-backed commitment, explicit sexual content/reward 0건, magic failure가 affection state를 자동 닫지 않음.

### `RG-M12` — Body horror

1. `R5` transformation success와 failed social recognition을 분리한다.
2. `R6` organ lobe, patient, envoy target priority를 확인한다.
3. `R2` clone memory와 legal/social name을 분리한다.
4. `R1` recovery function 보존과 failure 재발을 확인한다.
5. `R4` translation detail이 intimate/address recognition에 미치는 delayed effect를 확인한다.
6. `mana_profile`이 `R5-01` boot 조건과 `R3-01` category를 함께 좁히는지 확인한다.
7. 통과: 각 arc가 combat, recovery, relationship, access, document, route 중 두 surface를 변경.

### `RG-M13` — Authored addition A1 (`R8` + support NPC + encounter)

1. baseline core pre-hash manifest를 기록한다.
2. `R8` region, `npc_20_*`~`npc_26_*` 7명, `ENC-ARPG-25`, `VAR-ARPG-06`, `NPC-CONV-ARPG-05`, `FAM-ARPG-19`, `ACT-CGW-*` 3건, magic status 5건, document/aftermath/`SERVICE_R8_COURSE_INDEX`를 authored package로 추가한다.
3. content validation과 full route probe를 다시 실행한다.
4. `G5` resolution이 `full`/`staged`인 상태에서 `E18`을 통과하고 `R8`에 들어간다.
5. `ENC-ARPG-25`를 combat 경로(marked verdict Break / dispersal / medium match / contract Filing)와 noncombat `withdraw and take the labor record` 경로로 각각 해결한다.
6. `VAR-ARPG-06`의 declared solution 3종을 실행한다.
7. failed fold 3등급(`recoverable`/`continuity-changing`/`terminal`)을 각각 확인하고 `terminal`에서도 학생이 region에 남는지 확인한다.
8. `R4` `glossary`가 비어 있는 동안 craft 이름이 `untranslated term`으로 Filing되는지, 학교 이름과 archive 번역이 두 줄로 남는 conflict인지 확인한다.
9. `contract_tally`이 자동 해소되지 않고 `G8`에서 `crown_protocol` 안/밖이 명시되는지 확인한다.
10. core post-hash와 production authored-ID scan을 실행한다.
11. 통과: `R8` reachable, 7명 support resident port 실행, `ENC-ARPG-25` combat+noncombat 해결, `changed_core_files == []`, production `.gd` authored literal 0.

### `RG-M14` — Reference and resolution

1. dialogue/choice, combat command/target/charge, document/corruption, aftermath를 A~H와 나란히 capture한다.
2. 1280×720, 1920×1080, 2560×1440에서 반복한다.
3. focus/cancel/return, long text, maximum page(9줄), unavailable/extreme class를 확인한다.
4. shell/debug/placeholder/source-copy/HUD 금지 scan을 실행한다.
5. 통과: BLACK SOULS 2의 고유 skin은 복제하지 않고 system/UX grammar는 읽히며 세 해상도에서 정보가 손상되지 않음.

### `RG-M15` — Craft route (`ROUTE_CRAFT`)

1. `RG-M13`의 A1 proof가 통과한 build에서 시작한다.
2. `HC-00`에서 category를 보류하고 `RC-02 share`로 `E18` resource gate를 만든다.
3. `R5-13 Supply Rack`에서 `medium_blank`/`fold_sheet`/`blade_credit`를 받아 `E18` resource gate(`concentration sample` 1 + `craft credit` 1)를 충족한다.
4. `R8`에서 `RC-08 register concentration`를 실행하고 지점·시각·측정값·`provenance`을 모두 적는다.
5. `R8-03`에서 `place in lineage` 또는 이름 없는 배정함을 선택한다.
6. `ENC-ARPG-25` P4에서 portal contract의 `crown_protocol` 안/밖 위치를 명시하거나 거부한다.
7. `R3`에서 `E10`을 타고 `E18` 왕복 leg를 닫아 `E11`/`E12`/`E14`/`E15` 중 하나로 이어진다.
8. `R2-09`/`R2-10` provenance와 `R8-02` 등록값이 다르면 `CL-CONT`가 한 단계 전진하는지 확인한다.
9. 통과: 25~35분, `E18`이 `open`으로 남고 `R8`의 두 return affordance가 모두 열림, `end_o1_many_mouths_one_person`의 magic 조건 충족.

## 17. 금지 shortcut

- direct 10분 evidence를 full content completion으로 주장
- `H0` 또는 한 region만 구현하고 complete 처리
- 25 encounter를 dialogue/cutscene로 대체
- 19 family를 skin/scale-only 변형으로 복제
- core 14명 수를 맞추기 위한 dialogue-only actor 추가
- `npc_20_*`~`npc_26_*`를 core roster로 승격하거나 `npc_15`~`npc_19` 번호 사용
- named NPC를 삭제하고 initial actor를 자동 재생성
- `R8`를 별도 우주로 만들거나 `H0`에 `R8` route를 추가
- `G9`, `E19`, 10번째 cluster 생성
- 모든 signature를 Break 또는 raw damage로 해결
- Guard/Dodge/Break/action slot/turn cost를 한 success 값으로 합치기
- axis를 global score/ending gauge로 합치기
- pressure clock을 single global bar로 합치기
- 두 clock을 한 transaction에서 전진시키기
- `C`를 contract 하나로 전진시키기
- red를 focus, disabled, danger, sexuality로 재사용
- recovery type을 같은 respawn modal로 축약하거나 8번째 type 추가
- `crown_alignment`를 recovery type으로 기록
- death/load가 filed NPC/record/resource/route를 되감음
- romance를 explicit sexual content/reward로 바꾸기
- magic failure를 affection route 자동 배제 사유로 쓰기
- body horror를 cutscene spectacle로만 처리
- event consequence를 dialogue flag 한 줄에 저장
- long movement, idle, repeated combat, dialogue volume으로 시간 충족
- route 차이를 이름/색상만으로 구현
- player knowledge를 persisted discovery flag으로 잠금
- authored ID별 core `if/match`, save key, scheduler, input branch 추가
- `FAM-ARPG-19`/`ENC-ARPG-25`/`VAR-ARPG-06`/`NPC-CONV-ARPG-05`를 새 combat system 확장으로 구현
- A1 증명을 위해 core 수정
- seed를 planning 단계에서 `used`/`transformed`로 주장
- image 생성이나 자동 테스트만으로 완료 선언
- 사용자 직접 플레이 전 최종 완성 선언

모든 evidence가 통과한 최종 상태는 **검토 준비 완료**다. 사용자의 실제 플레이 검토 전에는 최종 완료를 주장하지 않는다.
