# mp04-enemy-a-v01 — 04 전투 적 10종 상태 그림 (아이콘 조합 양산 세션 04)

상태: **준비만 끝남, 제작 보류.** `COMMON.md` 맨 위의 "준비만 할 것" 줄(분위기 기준과 스프라이트 형식을 다시 정하는 중) 때문에 레시피 작성, 도구 복사, build는 하지 않았다. 결과는 나중에도 전부 candidate이고 승인은 사용자만 한다. 게임에 연결하지 않는다. 서브에이전트 없이 이 세션이 직접 만든다.

## 1. 필수 항목 (14 §3)

| 필드 | 값 |
|---|---|
| 목적 | state_variant: 04 전투 적 10종의 전투 그림과 상태별 그림 (09 §12.3 `enemy_encounter`) |
| 근거 결정 | 사용자 결정 2026-09-27: 아이콘 조합 방식 양산 (`C:\Users\Sherum\.kiro\crew\workspace\tin_mass_production\COMMON.md`). 세션 04 담당 = 아래 적 10종 |
| 소유권 | 세션 04. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/mp04-enemy-a-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp04-enemy-a-v01/`. 게임 코드·씬·content JSON·규칙 문서·다른 작업 폴더는 고치지 않는다 |
| 자산 identity | 적 ID 10개는 모듈 content의 실제 ID. 상태 이름(baseline, telegraph, signature, break, exposure, phase_*)과 파일 이름은 이 작업의 설계 ID |
| 입력 계약 버전 | 9절 목록. SHA-256은 작업이 끝날 때 `inputs.json`에 적는다(기준 문서가 지금 바뀌는 중이라서) |
| 카메라 | 지면 기준 60° 정사영, 방위 고정, 지면 깊이 ×0.866, 높이 ×0.5 (도구 계산 그대로). 방향 없는 정면 전투 그림: 적은 보는 사람 쪽을 향하고 정수리·어깨 윗면이 보인다. 좌우 반전본은 만들지 않는다 |
| 입력 이미지 | 픽셀 입력 없음. 모양 재료는 `addons/at-icons/node2d` SVG(MIT). 시험 작업 결과는 화풍을 눈으로 맞추는 용도로만 본다 |
| 필요한 결과 | 3절: 상태 그림 46장 + 그림자 레이어 + 파일별 manifest, 적별 시트 10장, 전체 시트 1장 |
| 내용 고정 | 4절 적별 설계 |
| 금지 | 그림 안의 글자·숫자·기호, UI·게이지, 워터마크, 원작(BLACK SOULS, Alice) 적·동작 복제, 명령 줄을 가리는 큰 효과, 원래 아이콘 모양이 그대로 읽히는 조각, 원본 SVG 수정 |
| 수정 범위 | 이 작업 폴더 안의 새 파일만. 도구는 이 작업의 복사본만 고친다(6절) |
| 승인 상태 | 시험 작업 `h0-icon-collage-v01` 결과는 candidate(사용자는 방식만 양산 허용). 이 작업 결과도 전부 candidate |
| 검수 항목 | `QA.md`에 적마다 구도·화풍·기술(크기·알파·피벗·가장자리 잘림)·상태 구분을 pass/partial/fail/not_run으로 |
| 중단 이유 | 지금: COMMON.md "준비만 할 것" 줄(기준 확정 대기). 그 밖에 문서에 없는 값은 작성자 설계로 채우고 멈추지 않는다 |

## 2. 공통 규격 (10종 모두 같게)

캔버스와 피벗. 피벗은 발밑 바닥 중앙이고, 몸은 위·아래·옆 32px 여백 안에 들어온다.

| 크기 등급 (`scale_class`) | 적 | 캔버스 | 피벗 |
|---|---|---|---|
| human | 8종 | 384×384 | (192, 352) |
| large | enemy_fold_wall | 576×480 (낮고 넓은 벽이라 가로를 늘림) | (288, 448) |
| architectural | enemy_crown_fragment_echo | 576×576 | (288, 544) |

- 세로 크기는 게임의 크기 배율(`top_down_screen.gd` `_body_scale`: human 1.0, large 1.25, architectural 1.5)을 384에 곱한 값이다. 사람 크기 적의 몸 높이는 약 260~280px로 잡아서 팔이나 도구를 들어도 위 여백 안에 들어오게 한다.
- 한 적의 상태 그림은 모두 같은 캔버스·피벗을 쓴다. 상태를 바꿔 끼워도 위치가 튀지 않게 하기 위해서다.
- 선·명암·붓자국·빛 방향: `palette_h0.json`의 `sprite` 스타일 그대로(COMMON 규칙). 접촉 그림자는 `_shadow.png`로 따로 둔다.
- 파일: `output/<적 ID>/<상태>.png` + `<상태>_shadow.png` + `<상태>.json`(build.py가 만드는 manifest). 적 하나에 레시피 하나(`recipes/<적 ID>.json`)를 두고, 상태는 레시피의 frame(hide/show/move/materials)으로 만든다.
- 상태 이름: `baseline`(기본), `telegraph`(기술 예고), `signature`(대표 기술), `break`(무너짐), `exposure`(무너지지 않는 적의 빈틈), `phase_<단계 이름>`(그 단계의 기본 자세).
- 예고 채널을 그림으로 옮기는 법(작성자 설계):
  - `pose`: 자세를 바꾼다.
  - `field_prop`: 적이 들거나 발 앞에 놓는 물건으로 캔버스 안에 그린다. 따로 떨어진 바닥 물건 그림은 만들지 않는다.
  - `vfx`: 몸에 붙은 빛·연기·안개만 그린다. 화면 효과는 12.4 `combat_vfx` 몫이다.
  - `numeric_bar`, `sound`: 그림 없음.
  - 자세 채널이 없는 적(순환 적재기, 분산 감시관)은 기본 자세에 물건이나 몸의 빛만 더해서 예고를 구분한다.
- 몸 상태(`stateful_body`, 작성자 설계): `open_close`는 기본 닫힘 → 예고 열리기 시작 → 대표 기술 활짝 열림 → 무너짐 열린 채 늘어짐. `split_merge`는 기본 합쳐짐 → 대표 기술 갈라짐 → 무너짐 흩어짐.
- 무너지지 않는 적 2종(enemy_ash_debt_collector, enemy_glossary_arbiter, `breakable: false`)은 `break` 대신 `exposure`를 만든다. 그 적에게 먹히는 대응을 받을 틈이 드러난 자세다.
- 상태끼리 자세가 확실히 달라 보여야 한다(시험 작업 약점). 결과마다 캔버스 가장자리에서 잘린 곳이 없는지 확인한다.

## 3. 만들 목록 (46장)

순서는 개가 먼저다. 시험 레시피가 있어서 전투 그림의 크기·밀도 기준을 여기서 잡는다. 그다음은 지역별로 묶어서 같은 지역 색을 이어 쓴다(작성자 설계).

| 순서 | 적 ID | 지역 | 몸 | 캔버스 | 상태 그림 | 장 |
|---|---|---|---|---|---|---|
| 1 | enemy_ash_hound | R1 | composite(네 발) | 384×384 | baseline, telegraph, signature, break | 4 |
| 2 | enemy_ash_debt_collector | R1 | humanoid | 384×384 | baseline, telegraph, signature, exposure | 4 |
| 3 | enemy_ember_clerk | R1 | humanoid | 384×384 | baseline, telegraph, signature, break | 4 |
| 4 | enemy_circulator_stacker | R2 | composite | 384×384 | baseline, telegraph, signature, break, phase_third_count | 5 |
| 5 | enemy_disperser_warden | R2 | humanoid | 384×384 | baseline, telegraph, signature, break, phase_second_housing | 5 |
| 6 | enemy_glossary_arbiter | R4 | abstract | 384×384 | baseline, telegraph, signature, exposure | 4 |
| 7 | enemy_crown_fragment_echo | R4 | architectural | 576×576 | baseline, telegraph, signature, break, phase_first_recital, phase_second_recital | 6 |
| 8 | enemy_boot_contract_holder | R5 | humanoid | 384×384 | baseline, telegraph, signature, break, phase_clause_struck | 5 |
| 9 | enemy_cure_queue_clerk | R6 | humanoid | 384×384 | baseline, telegraph, signature, break | 4 |
| 10 | enemy_fold_wall | R8 | architectural | 576×480 | baseline, telegraph, signature, break, phase_second_hearing | 5 |

그 밖에: 적마다 `preview/sheet_<적 ID>.png`(×1, ×0.5), 마지막에 전체 시트 `preview/sheet_mp04_enemy_states_0.5x.png`(세로 = 적 10종, 가로 = baseline · telegraph · signature · break/exposure · 단계 1 · 단계 2, 없는 칸은 비움).

## 4. 적별 설계 (작성자 설계. 근거는 content의 적·기술·단계 JSON)

05 문서에는 10종 중 enemy_fold_wall만 있다(`ENC-ARPG-25`, `FAM-ARPG-19`). 나머지 9종의 모습은 문서에 없어서 JSON 값(역할, 몸, 움직임, 기술, 도구)으로 정했다.

### 4.1 enemy_ash_hound — Ash Hound (R1 The Returning Kiln)
- 근거: 역할 custodian·pursuit, 움직임 `ash_lunge`. 대표 기술 `act_ash_hound_lunge`(모았다가 돌진: 예고 2창 → 공격 2창 → 회복 1창, 막기를 깨고 피하기로 대응). 예고 pose(기술 파일에는 vfx도). 무너짐 가능 → `st_recorded`.
- 모습: 시험 레시피의 부품과 재질을 그대로 쓴다(재 갈기 = mountains, 불씨 금 = lightning_bolt를 몸에 맞춰 자름, 청동 목줄과 꼬리표 = tag, 꼬리 = comet, 재질 ash/ash_far/ember/bronze). 옆모습을 정면 전투 그림으로 다시 배치한다. 머리가 어깨보다 낮은 추적 자세.
- baseline: 네 발로 서서 머리를 낮춤, 꼬리 수평, 불씨 금 약하게.
- telegraph: 뒷다리를 접고 앞다리를 벌려 웅크림, 갈기가 곤두섬, 불씨 금이 밝아짐.
- signature: 앞으로 뛰어듦. 앞발을 뻗고 입을 벌림, 뒤로 재가 흩날림.
- break: 옆으로 쓰러져 다리가 풀림, 불씨 금이 꺼짐, 꼬리표에 빈 기록 종이가 걸림.

### 4.2 enemy_ash_debt_collector — Ash Debt Collector (R1, 무너지지 않음)
- 근거: 역할 creditor·paperwork, 움직임 `debt_call_in`, 몸 `open_close`. 대표 기술 `act_debt_collector_call_in`(대상을 `st_contract_bound`로 묶음. 대응은 반환 서식 제출·자원 잠금·도망이고 무너뜨리기·막기는 안 됨). 예고 pose + field_prop, 바로 발동.
- 모습: 키 크고 마른 수금원. 재빛 긴 외투의 가슴판이 장부 상자처럼 열린다. 한 손에 긴 갈고리 막대, 다른 손에 증서 뭉치. 불씨 서기와 겹치지 않게 세로로 길쭉한 실루엣.
- baseline: 외투를 여미고 갈고리 막대를 세워 든 자세, 가슴 장부 닫힘.
- telegraph: 증서 한 장을 앞으로 내밀고 발 앞에 청구 말뚝(field_prop)을 꽂음, 가슴 장부가 열리기 시작.
- signature: 갈고리를 앞으로 뻗어 끌어당김, 가슴 장부 활짝 열림, 증서 끈이 앞으로 뻗음.
- exposure: 가슴 장부가 열린 채 빈 칸이 드러남(반환 서식이 들어갈 자리), 갈고리는 내려감.

### 4.3 enemy_ember_clerk — Ember Clerk (R1)
- 근거: 역할 paperwork·custodian, 움직임 `ledger_sweep`, 몸 `open_close`. 대표 기술 `act_ember_clerk_stamp`(명중 보장, `st_recorded` 40%). 예고 pose + field_prop, 바로 발동. 무너짐 → `st_recorded`. 보상 `equipment_kiln_ledger_seal`.
- 모습: 작고 옆으로 다부진 서기. 몸통이 불빛이 비치는 장부 상자이고, 커다란 달군 인장(가마 장부 인장)을 든다.
- baseline: 장부 상자 닫힘, 인장을 옆에 늘어뜨림.
- telegraph: 인장을 머리 위로 들어 올림, 상자 틈으로 불빛, 발 앞에 인주판(field_prop).
- signature: 인장을 내리찍음, 인장 면에서 불씨가 튐.
- break: 장부 상자가 터져 열리고 종이가 쏟아짐, 인장을 떨어뜨리고 주저앉음.

### 4.4 enemy_circulator_stacker — Circulator Stacker (R2 Siltglass Commons)
- 근거: 역할 collector·quota, 움직임 `stack_pull`, 몸 `split_merge`. 대표 기술 `act_circulator_stack_collect`(체력 흡수, `st_overflowed`. 도구 bone_rule, 모양 closed_stack_pull, 매체 순환 칸). 예고 field_prop + numeric_bar(자세 없음). 타고난 `st_medium_residue`. 무너짐 → `st_overflowed`. 단계 `phase_circulator_stack_third_count`(2창 뒤, 분산 감시관을 부름).
- 모습: 흐린 유리 뚜껑 쟁반(순환 칸)을 층층이 쌓은 몸에 가는 다리, 한쪽 팔이 긴 뼈 자. 쟁반 틈으로 실트 앙금이 샌다.
- baseline: 쟁반 두 무더기가 하나로 합쳐 섬.
- telegraph: 기본 자세 그대로, 빈 쟁반 두세 개가 발 앞에 펼쳐짐.
- signature: 무더기가 둘로 갈라져 좌우로 벌어지고, 뼈 자로 앞을 끌어당김.
- break: 넘쳐서 무너짐. 쟁반이 쏟아져 흩어지고 앙금이 흘러넘침.
- phase_third_count: 세 번째 무더기가 붙어 셋으로 쌓임(더 높고 넓게), 앙금 얼룩이 늘어남.

### 4.5 enemy_disperser_warden — Disperser Warden (R2)
- 근거: 역할 purge·custodian, 움직임 `purge_pass`, 몸 `open_close`. 대표 기술 `act_disperser_warden_purge_pass`(명중 보장·피할 수 없음, 대상 `st_misfolded`, 자신 `st_medium_residue`. 도구 curved_awl, 모양 open_purge_sweep). 예고 vfx + numeric_bar(자세 없음). 무너짐 → `st_medium_residue`. 단계 `phase_disperser_warden_second_housing`(체력 45%, 순환 적재기를 부름).
- 모습: 유리창 달린 등불 집 모양 두건(하우징)을 쓴 감시관. 등에 분사 통, 손에 굽은 송곳, 앙금 얼룩 외투.
- baseline: 두건 창 닫힘, 송곳을 아래로.
- telegraph: 기본 자세 그대로, 분사 통 노즐과 두건 틈에서 앙금 안개가 새기 시작.
- signature: 송곳을 크게 휘둘러 쓸어 넘김, 두건 창이 열리고 노즐에서 앙금이 뿜어짐.
- break: 두건 창이 금 간 채 열림, 앙금이 막혀 흘러내림, 한 무릎을 꿇음.
- phase_second_housing: 두건 위에 두 번째 유리 하우징을 덧씌움(어깨까지 덮는 틀), 앙금 얼룩 증가.

### 4.6 enemy_glossary_arbiter — Glossary Arbiter (R4 Crownwell Archive, 무너지지 않음)
- 근거: 역할 arbiter·language, 움직임 `precedence_rewrite`, 몸 abstract. 대표 기술 `act_glossary_arbiter_precedence_rule`(대상 `st_misfolded`, `st_recorded` 50%. 대응은 막기·비전투·정해진 대응이고 무너뜨리기·피하기는 안 됨). 예고 pose + field_prop(1창 전). `st_recorded` 면역.
- 모습: 얼굴 없이 떠 있는 형체. 겹친 용어집 낱장과 색인 카드가 긴 옷 모양을 이룬다. 글자 대신 줄 자국만 있다. 책갈피 끈으로 된 지휘봉.
- baseline: 낱장 옷이 접혀 모인 채 떠 있음, 바닥엔 그림자만.
- telegraph: 낱장이 고리 모양으로 펼쳐짐, 발 앞에 색인 탭 말뚝(field_prop)이 섬.
- signature: 큰 낱장 하나가 앞으로 덮쳐 씌움(선례로 덮어쓰기), 낱장들이 앞으로 흐름.
- exposure: 낱장 옷이 벌어져 속이 빈 틀이 드러나고 낱장이 힘없이 늘어짐(막기·비전투 대응을 받는 틈).

### 4.7 enemy_crown_fragment_echo — Crown Fragment Echo (R4, 건축 크기)
- 근거: 역할 archive·judge, 움직임 `fragment_recital`, 몸 architectural. 대표 기술 `act_crown_fragment_echo_recital`(적 전체, 3창 동안 멈출 수 없음, 빛 속성, 2창 전 예고, pose + vfx + numeric_bar, 자신 `st_overflowed`). 타고난 `st_concentration_load`. 무너짐 → `st_overflowed`. 단계 `first_recital`(체력 65%, 1창 무적, 용어집 중재자를 부름) → `second_recital`(넘침, 불씨 서기를 부르고 중재자는 빠짐).
- 모습: 거대한 왕관의 부서진 조각이 우물돌 받침과 독서대에 붙은 구조물. 왕관 가지 사이의 빈 아치가 울림통이고, 쇠사슬에 묶인 낱장이 걸려 있다. 빛은 탁한 금빛.
- baseline: 조각들이 받침 위에 가라앉아 모임, 낱장 닫힘.
- telegraph: 조각들이 떠올라 줄을 맞춤, 독서대 낱장이 열리며 안쪽에 빛이 모임.
- signature: 왕관 고리가 완전히 떠올라 빛을 뿜음, 낱장이 펄럭임.
- break: 조각들이 떨어져 부딪혀 금 가고 빛이 꺼져 감.
- phase_first_recital: 조각들이 방패처럼 고리로 둘러 떠 있음(무적 1창), 한 층 높아짐.
- phase_second_recital: 넘침. 금 간 틈에서 빛이 새고 조각 하나가 빠져 있음.

### 4.8 enemy_boot_contract_holder — Boot Contract Holder (R5 Glasswing Ordinal)
- 근거: 역할 contract_holder·consent, 움직임 `clause_read`. 대표 기술 `act_boot_contract_holder_binding_clause`(1창 전 예고, pose + sound + numeric_bar, 막기를 깸, 대상 `st_concentration_load` 60%). 타고난 `st_contract_bound`. 무너짐 → `st_misfolded`. 단계 `phase_boot_contract_holder_clause_struck`(체력 40%, 허가 검사관을 부름, 민첩 8 → 7).
- 모습: 꼿꼿한 관리. 유리 판을 납 틀로 이은 날개 망토, 두루마리 계약서, 계약 끈에 묶인 무거운 장화.
- baseline: 두루마리를 말아 가슴 앞에 든 자세.
- telegraph: 두루마리를 펼쳐 조항을 읽음. 한 손을 들고 입을 벌림, 날개 유리가 곧게 섬.
- signature: 조항 끈이 앞으로 뻗어 휘감음, 두루마리 활짝, 몸에 약한 빛.
- break: 두루마리가 잘못 접혀 구겨짐, 한 무릎을 꿇음, 날개 유리 한 장이 빠짐.
- phase_clause_struck: 두루마리 한 부분이 굵은 줄로 지워짐(글자 아님), 날개 유리에 금, 자세가 낮고 무거워짐.

### 4.9 enemy_cure_queue_clerk — Cure Queue Clerk (R6 Gristmarket Ward)
- 근거: 역할 queue·clerk, 움직임 `queue_enqueue`, 몸 `open_close`. 대표 기술 `act_cure_queue_clerk_enqueue`(대상 `st_concentration_load`, 체력 흡수). 예고 pose + field_prop, 바로 발동. 타고난 `st_concentration_load`. 무너짐 → `st_misfolded`.
- 모습: 긴 앞치마와 병동 겉옷의 서기. 몸통에 번호표 통이 달려 문이 열리고 닫힌다(숫자 없음). 대기줄 말뚝과 줄, 곡물 가루 얼룩.
- baseline: 번호표 통 닫힘, 대기줄 말뚝을 짚고 섬.
- telegraph: 통 문이 열려 번호표 띠가 풀려 나옴, 발 앞에 대기줄 말뚝(field_prop).
- signature: 번호표 띠와 줄을 앞으로 던져 올가미처럼 감음.
- break: 통이 막혀 번호표가 구겨져 쏟아짐, 허리를 숙임.

### 4.10 enemy_fold_wall — Fold That Refuses The Hand (R8 The Folding School, 큰 크기)
- 근거: 05 `FAM-ARPG-19 Grading Wall`(`ENC-ARPG-25`와 이름·지역·역할이 같다). 낮고 넓은 벽걸이 틀, 접힌 쟁반 층, 튀어나온 집게 팔 하나, 걸린 점수 석판, 밑의 앙금 대야. 얼굴·손·다리가 없고 아주 오래 채점해 온 가구처럼 보인다. 예고는 집게 팔이 열려 빈 접힘 모양을 들고, 석판이 빈 줄로 넘어가고, 대야에 막이 올라오는 것. 집게 팔은 무너지지 않고 진짜 목표도 아니다. content: 대표 기술 `act_fold_wall_verdict`(3창 동안 멈출 수 없음, 2창 전 예고, pose + vfx + numeric_bar, 막기 무시). 무너짐 → `st_concentration_load`. 단계 `phase_fold_wall_second_hearing`(체력 40%, 민첩 7 → 2, measure 추가).
- baseline: 집게 팔 접힘, 석판 빈 면, 대야 잔잔.
- telegraph: 집게 팔이 열려 빈 접힘 모양을 듦, 석판이 넘어가 빈 줄, 대야 막이 올라옴(빛).
- signature: 쟁반 층이 앞으로 접히며 내리치는 판결, 집게가 닫힘.
- break: 접힌 쟁반이 주저앉아 납작해짐, 석판에 금, 대야가 넘침. 집게 팔은 멀쩡함.
- phase_second_hearing: 쟁반을 더 촘촘히 다시 접어 낮고 무거워짐, 석판에 두 번째 빈 줄, 재는 자가 튀어나옴.

## 5. 색 (잠정. 분위기 기준이 정해지면 다시 정함)

- `palette_h0.json`의 윤곽선(ink), 그림자(shade_tint, shadow_contact), 공통 재질(bronze, paper, eye, ash, ember 등)은 그대로 쓴다.
- 새 재질은 `recipes/palette_mp04_enemy.json`(palette_h0 + 추가분)에 넣고 H0와 달라진 점을 여기 적는다. 지역별 방향(hex는 레시피 작성 때 정함):
  - R1 The Returning Kiln: 재 회색, 불씨 주황, 청동(H0에 있음) + 그을린 벽돌색 조금.
  - R2 Siltglass Commons: 황회색 앙금, 흐린 청회색 유리, 짙은 올리브색 끈적한 앙금.
  - R4 Crownwell Archive: 바랜 양피지, 녹슨 금, 짙은 청회색 우물돌, 탁한 금빛.
  - R5 Glasswing Ordinal: 차가운 청보라 유리, 짙은 납 틀, 바랜 붉은 계약 끈(작게).
  - R6 Gristmarket Ward: 곡물 가루 베이지, 밀기울 갈색, 바랜 흰 병동 천, 무딘 쇠.
  - R8 The Folding School: 분필색 두꺼운 접힘 판, 짙은 석판, 쇠 집게, 우윳빛 대야 막.
- 같은 지역 적끼리는 실루엣과 대표 물건으로 구분한다. 예: R1은 개 = 네 발, 수금원 = 세로로 길쭉, 서기 = 낮고 넓음.

## 6. 기준이 정해지면 시작하는 순서

1. `COMMON.md`를 다시 읽는다. "준비만 할 것" 줄이 없어졌는지, 분위기·형식 기준이 어떻게 정해졌는지 확인하고 바뀐 점을 이 파일(2·4·5절)에 반영한다. VISUAL_DIRECTION, IMAGE_ASSET_WORKFLOW, PROJECT_ART_LAYER가 바뀌었으면 다시 읽는다.
2. 복사: 시험 작업의 `tool\`(__pycache__ 제외), `recipes\palette_h0.json`, `recipes\enemy_ash_hound.json` → 이 작업 폴더.
3. 도구 복사본 수정(바꾼 내용과 이유는 여기에 적음):
   - `iconkit\icons.py` `prefetch` 병렬 개수 8 → 2 (COMMON: 세션 10개 동시 작업).
   - `review_sheet.py`에 표 배치 추가(세로 적, 가로 상태, 빈 칸 허용). 지금은 한 줄 배치만 되어서 전체 시트를 못 만든다.
4. `recipes\palette_mp04_enemy.json` 작성(5절).
5. 한 종씩: 레시피 → `tool`에서 `py -3 -B build.py ..\recipes\<적 ID>.json` → read 도구로 그림 직접 확인 → 고치기(최대 2번) → `py -3 -B review_sheet.py --out ..\preview\sheet_<적 ID>.png ..\output\<적 ID>\*.png` → 7절 체크. 임시 파일은 `$KIROCREW_SCRATCH`.
6. 끝나면 전체 시트, `QA.md`, `inputs.json`(SHA-256), `__pycache__` 삭제. 커밋·푸시는 하지 않는다.

## 7. 진행

- [x] 준비: 자료 읽기, 만들 목록, 적별 설계, 이 JOB.md (2026-09-27)
- [ ] 기준 확정 확인 (COMMON.md "준비만 할 것" 줄)
- [ ] 도구·팔레트 복사, 병렬 2, 시트 표 배치
- [ ] 1 enemy_ash_hound (4)
- [ ] 2 enemy_ash_debt_collector (4)
- [ ] 3 enemy_ember_clerk (4)
- [ ] 4 enemy_circulator_stacker (5)
- [ ] 5 enemy_disperser_warden (5)
- [ ] 6 enemy_glossary_arbiter (4)
- [ ] 7 enemy_crown_fragment_echo (6)
- [ ] 8 enemy_boot_contract_holder (5)
- [ ] 9 enemy_cure_queue_clerk (4)
- [ ] 10 enemy_fold_wall (5)
- [ ] 전체 시트
- [ ] QA.md, inputs.json, __pycache__ 삭제

## 8. 기준이 바뀌면 영향받는 곳

- 분위기(BLACK SOULS 2 느낌): 5절 색 전체와 명암 대비. 붓 설정은 COMMON 규칙상 시험 작업 그대로이고, 바뀌면 새 COMMON 지시를 따른다.
- 방향: COMMON 규칙("RPG Maker 정면 전투 그림처럼 방향 없이")대로 정면으로 잡았다. 시험 작업의 개는 왼쪽을 보는 옆모습이었다.
- 8방향 규칙은 맵에서 움직이는 캐릭터용이라 방향 없는 전투 적인 이 작업에는 해당하지 않는다. 기준에서 전투 적 형식도 바뀌면 3절 목록을 다시 짠다.

## 9. 읽은 자료 (읽기만. SHA-256은 끝날 때 inputs.json에)

- `C:\Users\Sherum\.kiro\crew\workspace\tin_mass_production\COMMON.md`
- 적 `modules/top_down_action_rpg/content/enemies/` 10개
- 대표 기술 `content/actions/` 10개: act_ash_hound_lunge, act_debt_collector_call_in, act_ember_clerk_stamp, act_circulator_stack_collect, act_disperser_warden_purge_pass, act_glossary_arbiter_precedence_rule, act_crown_fragment_echo_recital, act_boot_contract_holder_binding_clause, act_cure_queue_clerk_enqueue, act_fold_wall_verdict
- 단계 `content/phases/` 6개: phase_circulator_stack_third_count, phase_disperser_warden_second_housing, phase_crown_fragment_echo_first_recital, phase_crown_fragment_echo_second_recital, phase_boot_contract_holder_clause_struck, phase_fold_wall_second_hearing
- `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/09_PRESENTATION_ART_AND_AUDIO.md` §12(12.3 `enemy_encounter`), `14_ISOLATED_ART_JOBS.md` §2·§3, `05_ENEMIES_AND_ENCOUNTERS.md` FAM-ARPG-19·ENC-ARPG-25 (나머지 9종은 05에 없음. `docs/GRILLING_STATE.md`에도 "FAM↔enemy 대응표가 정본에 없음"이라고 적혀 있음)
- `modules/top_down_action_rpg/presentation/top_down_screen.gd`(`_enemy_position`, `_body_scale`), `top_down_vector_layer.gd`(`_draw_actor`: 지금은 사람 크기 적을 높이 116px 도형으로 그림)
- 시험 작업 `h0-icon-collage-v01`: JOB.md, QA.md, `recipes/enemy_ash_hound.json`, `recipes/palette_h0.json`, `tool/`(build.py, review_sheet.py, iconkit/render.py의 frame 기능, iconkit/icons.py의 병렬 개수), COMMON이 가리키는 기준 그림
- 아직 다시 읽지 않은 것: VISUAL_DIRECTION.md, IMAGE_ASSET_WORKFLOW.md, PROJECT_ART_LAYER.md 전문(적 관련 줄만 검색했고 적 전용 규칙은 없었음). 기준이 정해진 뒤 읽는다.
