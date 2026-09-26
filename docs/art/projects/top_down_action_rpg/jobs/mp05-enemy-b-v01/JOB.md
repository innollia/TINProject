# mp05-enemy-b-v01 — 적 9종 전투 그림 (아이콘 조합 양산, 세션 05)

상태: **준비만 끝남.** COMMON.md 맨 위 "⚠ 준비만 할 것" 줄 때문에 레시피 작성, 도구 복사, build는 아직 하지 않았다. 분위기(톤앤매너) 기준이 확정되면 COMMON.md를 다시 읽고 시작한다. 결과는 전부 candidate이고 승인은 사용자만 한다.

| 필드 | 값 |
|---|---|
| 목적 | 적 9종의 정면 전투 그림(battler)을 상태마다 한 장씩, 마지막에 적×상태 모아 보기 시트 |
| 근거 결정 | 2026-09-27 사용자: 아이콘 조합 방식 양산 지시(시험 작업 h0-icon-collage-v01). 세션 05 담당 = 이 9종 |
| 쓰기 범위 | `assets/art/top_down_action_rpg/jobs/mp05-enemy-b-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp05-enemy-b-v01/`만. 게임 코드·content·규칙 문서 수정 없음, 게임 연결 없음, git 없음 |
| 대상 | `content/enemies/`의 enemy_kiln_door_ward, enemy_latency_bell_ringer, enemy_mana_triage_surrogate, enemy_organ_quorum_witness, enemy_permit_inspector, enemy_residue_cantor, enemy_seam_arbiter, enemy_worksheet_instructor, enemy_wrong_return_scribe |
| 카메라 | 60° 내려다보는 정사영(도구 계산 그대로), 정면 한 방향. 방향 세트 없음(09 §12.3) |
| 알파·피벗 | 투명 PNG, 피벗 = 캔버스 중심(게임이 적 위치를 몸 중심으로 씀). 접촉 그림자는 시험 작업처럼 별도 `_shadow.png` |
| 팔레트 | **대기.** 톤앤매너 확정 뒤 `recipes/palette_mp05_enemies.json`을 만든다. H0의 윤곽선·그림자·공통 색은 그대로 쓴다 |
| 금지 | 글자·숫자·UI를 그림에 넣기, 원작 적 복제, 떨어진 효과 그림(전투 효과는 12.4 별도 자산군), 원본 SVG 수정 |
| 입력 기록 | `inputs.json`은 build 때 작성 |

## 크기 (근거: 게임 코드 + COMMON 크기 표)

- `top_down_screen.gd` `_body_scale`: human 1.0, large 1.25. `top_down_vector_layer.gd`: 적 몸 상자 = 반지름 58×배율 → 사람 81×116, 큰 몸 101×145(논리 px).
- 2배 원본의 몸 기준 상자: 사람 162×232, 큰 몸 203×290. 치켜든 팔·도구는 상자 밖으로 나가도 되지만 캔버스 가장자리 32 px 안에 멈춘다.
- 캔버스(COMMON: 사람 크기 높이 384, 몸집 비례): **사람 320×384, 피벗 (160,192)** / **큰 몸 400×480, 피벗 (200,240)**. 선 두께·붓자국 크기는 두 캔버스에서 같다.
- 큰 몸 = kiln_door_ward, seam_arbiter. 나머지 7종은 사람 크기.

## 파일 이름

`output/<enemy_id>/baseline.png`, `telegraph.png`, `signature.png`, `break.png`(깨지지 않는 2종은 `exposure.png`), 단계가 있으면 `phase1_<이름>.png`, `phase2_<이름>.png`. 각 PNG 옆에 `.json`(build.py가 씀)과 `_shadow.png`.

## 적별 설계

05_ENEMIES_AND_ENCOUNTERS.md에는 이 9종 이름의 절이 없다(05의 적 계열 FAM-ARPG-01~19와 이름이 다름). 그래서 모습은 **content JSON 기준 작성자 설계**이고, 같은 지역의 05 계열 실루엣은 보조 참고로만 쓴다. 상태별 자세는 기술 JSON의 예고 채널(pose/field_prop이 있으면 자세로, sound/numeric_bar는 그림 밖)과 몸 변화 방식(stateful_body)을 따른다. 효과(vfx) 채널은 몸에 붙은 표시(빛나는 틈, 튀는 재)까지만 그린다.

### 1. enemy_kiln_door_ward — Kiln Door Ward (큰 몸)
- 근거: R1 돌아오는 가마·반환 등기소, 태그 문턱·자물쇠, 건축형, 몸 변화 없음, 동작 ward_seal_slam. 대표 기술 kiln_door_ward_seal(적 전체, 1창 예고, 자세·효과). 무너지면 st_misfolded + 재 빚 통로가 열림. 단계 2개.
- 모습(작성자 설계): 가마 아궁이에 박힌 낮고 넓은 쇠문과 두꺼운 문틀. 윗부분 둥근 아치, 문짝 가운데 봉인판, 문틀 아래 재받이. 얼굴·손 없음. 재질 참고: 같은 R1의 Tally-Skin(종이 덮은 쇠).
- baseline 문 닫힘, 봉인판 가운데 / telegraph 문짝이 뒤로 젖혀지고 봉인판이 들림, 문틈 불빛 / signature 문짝이 앞으로 쾅 닫히며 봉인판이 내리찍힘, 재가 튐 / break 문짝이 경첩에서 비틀려 기울고 봉인판이 접혀 휨, 안쪽 아궁이가 보임.
- phase1_sealed_frame(HP 60%, contract_bound): 문틀에 봉인 띠가 여러 겹 / phase2_open_frame(misfolded): 문짝이 옆으로 열린 채 고정, 빈 입구.

### 2. enemy_latency_bell_ringer — Latency Bell Ringer
- 근거: R3 종탑 요양원, 태그 일정 담당·빚, 사람형, 열림·닫힘 몸, 동작 bell_ringing. 대표 기술 latency_bell_ringing(3창 충전, 예고 소리·숫자·자세). 무너지면 st_recorded. 단계 없음.
- 모습(작성자 설계): 등이 굽은 요양원 종지기. 긴 장대 끝에 매단 큰 종(T자 실루엣), 앞이 열리는 외투 안에 작은 종 여러 개. 참고: 같은 R3의 Stalled Bell(고리 묶음, 매달린 추).
- baseline 외투 닫힘, 종을 낮게 든 자세 / telegraph 종을 머리 위로 치켜들고 외투가 열려 안쪽 종이 보임 / signature 몸을 옆으로 기울이며 종을 크게 휘둘러 울림 / break 종이 바닥에 엎어지고 외투가 반쯤 열린 채 무릎 꿇음.

### 3. enemy_mana_triage_surrogate — Mana Triage Surrogate
- 근거: R3, 태그 대리인·동의, 조합형 몸, 변신 몸, 동작 substitute_step. 대표 기술 mana_triage_substitute(빛 속성, 대상 계약 묶기). 무너지면 st_misfolded. 단계 2개.
- 모습(작성자 설계): 서로 다른 몸 조각을 이어 붙인 대리 몸. 마네킹 같은 몸통, 환자복 조각, 분류표 판, 한쪽 팔만 다른 사람 것. 가슴 한가운데 빈자리.
- baseline 한 발 앞으로 내딛은 자세 / telegraph 이음새가 벌어지며 가슴 빈자리에 빛 / signature 한 걸음 옮겨 서며 자기 조각을 손바닥에 얹어 내밂 / break 이음새가 어긋나 조각이 흩어지기 직전, 몸이 비틀림.
- phase1_first_passage(HP 70%, medium_residue): 잔여물 얼룩이 번지고 조각 하나가 바뀜 / phase2_replacement_signed(concentration_load): 조각 대부분이 바뀌어 다른 사람처럼 보임, 서명 봉인 띠.

### 4. enemy_organ_quorum_witness — Organ Quorum Witness
- 근거: R6 그리스트마켓 병동, 태그 정족수·증인, 무리형, 갈라짐·합쳐짐 몸, 동작 quorum_count. 대표 기술 organ_quorum_witness_count(자기 대상, 즉시, 예고는 소리·숫자뿐). 무너지면 st_recorded. 단계 1개.
- 모습(작성자 설계): 두건 쓴 작은 증인 넷이 한 덩어리로 뭉치고, 가운데에 심장 같은 박동 덩어리. 참고: 같은 R6의 Organ Chorus(크기 다른 얼굴 여럿 + 가운데 박동).
- baseline 뭉친 덩어리 / telegraph 데이터상 자세 신호가 없어서 작은 변화만: 머리들이 가운데로 모임 / signature 증인들이 갈라져 나란히 서서 손을 듦(표 세기) / break 증인들이 흩어져 넘어지고 박동 덩어리가 드러남.
- phase1_quorum_lapsed(3창 뒤): 증인 하나가 빠진 빈자리, 나머지가 기울어짐.

### 5. enemy_permit_inspector — Permit Inspector (깨지지 않음)
- 근거: R5 유리날개 서열청, 태그 검사관·허가, 사람형, 열림·닫힘 몸, 동작 inspection_poke. 대표 기술 permit_inspector_inspection(즉시, 예고 자세·현장 물건). 깨지지 않음, 대응은 자원 잠그기·막기·상태 대응. 단계 없음.
- 모습(작성자 설계): 곧고 뻣뻣한 제복 검사관, 챙 모자, 끝에 집게가 달린 긴 찌르개 막대, 여닫히는 가슴 점검표 판. 참고: 같은 R5의 Seal Lancer(좁은 갑옷, 긴 창, 점검표 판).
- baseline 막대를 세워 든 자세 / telegraph 막대를 앞으로 겨누고 허가증 판을 내밂 / signature 가슴판을 열며 막대로 찔러 넣음 / exposure 대응을 받아 가슴판이 열린 채 막대를 거둬들이며 멈춘 모습(깨지지는 않음).

### 6. enemy_residue_cantor — Residue Cantor
- 근거: R8 접는 학교·마법 학교, 태그 공예 노동·매개 취급, 무리형, 갈라짐·합쳐짐 몸, 동작 residue_lay. 대표 기술 cantor_overflow(적 전체, 1창 예고, 자세·효과). 무너지면 st_medium_residue. 단계 2개(단계에서 대표 기술이 cantor_void_gash로 바뀜).
- 모습(작성자 설계): 성가대원 셋이 한 몸처럼 겹친 무리, 발치에 잔여물 대야, 손에 깔 준비를 한 얇은 판. 참고: 같은 R8의 Grading Wall(잔여물 대야).
- baseline 입을 모아 부르는 자세, 대야는 발치 / telegraph 대야를 머리 위로 들어 기울임, 가장자리에 잔여물이 차오름 / signature 몸들이 갈라지며 대야를 앞으로 쏟음 / break 대야가 엎어지고 몸들이 잔여물에 미끄러져 주저앉음.
- phase1_first_lay(HP 55%): 바닥에 판을 깔고 한 몸이 떨어져 나와 긋는 손(어두운 틈) / phase2_contract_press(HP 25%, overflowed·contract_bound): 계약 띠에 묶여 한데 짓눌림, 대야가 넘쳐 있음.

### 7. enemy_seam_arbiter — Seam Arbiter (큰 몸)
- 근거: R7 텅 빈 과수원, 태그 중재자·경계, 건축형, 몸 변화 없음, 동작 seam_ruling. 대표 기술 seam_arbiter_boundary_ruling(얼음 속성, 2창 예고, 자세·효과·소리). 무너지면 st_recorded. 단계 2개.
- 모습(작성자 설계): 과수원 나무로 만든 키 큰 두 판이 버팀대로 이어진 문 모양 구조물, 가운데 분필색 세로 이음선, 위에 판결 막대, 낮게 움직이는 받침. 참고: 같은 R7의 Seam Bailiff(버팀대 문 모양, 분필색 이음선, 낮은 받침). Kiln Door Ward와 헷갈리지 않게 이쪽은 높고 차가운 나무, 저쪽은 낮고 넓은 쇠.
- baseline 두 판이 닫혀 이음선이 가늘게 / telegraph 이음선이 벌어지며 차가운 빛, 판결 막대가 들림 / signature 판결 막대를 내리치며 이음선에서 서리가 번짐 / break 한쪽 판이 기울어 무너지고 이음선이 어긋남.
- phase1_first_ruling(HP 70%, recorded): 판에 기록 판이 덧붙음 / phase2_final_ruling(concentration_load): 두 판이 벌어져 이음선이 넓게 갈라지고 안쪽이 드러남.

### 8. enemy_worksheet_instructor — Worksheet Instructor
- 근거: R8, 태그 채점·노동, 사람형, 변신 몸, 동작 grade_mark. 대표 기술 worksheet_instructor_grade_mark(1창 예고, 현장 물건·숫자·자세). 무너지면 st_overflowed. 단계 2개.
- 모습(작성자 설계): 어깨가 넓은 교사 가운, 접힌 높은 옷깃, 한 손에 네모난 채점판(글자 없음), 다른 손에 긴 붉은 표시봉. 참고: 같은 R8의 Grading Wall(매달린 점수판, 집게 팔).
- baseline 채점판을 가슴 앞에 든 자세 / telegraph 표시봉을 치켜들고 채점판을 앞으로 내밂 / signature 몸을 비틀며 표시봉을 크게 그어 내림 / break 채점판이 쪼개지고 종이가 흘러넘치며 몸이 뒤로 젖혀짐.
- phase1_second_sheet(HP 55%, misfolded): 두 번째 채점판까지 양손에 듦, 가운이 접혀 비틀림 / phase2_final_mark(overflowed): 몸과 채점판이 합쳐지고 표시봉이 팔처럼 붙음.

### 9. enemy_wrong_return_scribe — Wrong-Return Scribe (깨지지 않음)
- 근거: R1, 태그 기록자·추상, 추상형 몸, 몸 변화 없음, 동작 entry_add_sweep. 대표 기술 wrong_return_scribe_entry_add(즉시, 대상 st_recorded). 깨지지 않음, 대응은 상태 대응·전투 밖 선택. 단계 없음.
- 모습(작성자 설계): 얼굴 없이 떠 있는 기록 몸. 여러 장 겹친 세로로 긴 장부 몸통, 깃펜 팔 하나, 아래쪽은 잉크 자국처럼 흐려짐. 그림자는 몸에서 떨어져 옅게. 참고: 같은 R1의 Return Usher(얼굴 없음, 떠 있는 장부 판).
- baseline 떠서 펜 팔을 옆에 둠 / telegraph 펜 팔을 크게 뒤로 젖히고 장부가 펼쳐짐 / signature 펜 팔을 옆으로 쓸어내림, 장부에 새 줄(선만) / exposure 장부가 덮이고 펜이 멈춘 채 낮게 가라앉음.

## 작업 순서 (준비 해제 뒤)

1. 시험 작업 `tool/`(__pycache__ 제외)와 `palette_h0.json`을 복사. 복사본 build.py의 아이콘 변환 workers를 2 이하로.
2. 톤앤매너에 맞춰 `palette_mp05_enemies.json` 작성(바꾼 점을 이 파일에 기록).
3. 적 한 종씩, 위 목록 순서대로: baseline 레시피 → build → 직접 보고 고치기(최대 2번) → 같은 조각으로 자세만 바꿔 나머지 상태 → 캔버스 가장자리 잘림 확인 → 그 적의 모아 보기 시트 → 다음 적.
4. 마지막에 전체 시트 `preview/sheet_enemy_states.png`(행 = 적 9종, 열 = 기본·예고·대표 기술·무너짐(드러남)·단계1·단계2).
5. 1순위가 끝나면 짧게 보고하고 COMMON 순서대로 2순위 07 Physics Puzzle Platformer, 3순위 언데드·마법·기계 몬스터로 넘어간다.

## 체크리스트

- [x] 자료 읽기: COMMON, 시험 작업(도구·색·기록·QA·그림), 적 JSON 9개, 기술 20개, 단계 11개, 09 §12.3, 05의 같은 지역 계열, 게임 코드 크기
- [x] 대상 목록과 적별 설계 (이 문서)
- [ ] 기준 확정 대기 (COMMON ⚠ 줄)
- [ ] 도구 복사·팔레트
- [ ] kiln_door_ward: baseline / telegraph / signature / break / phase1 / phase2 / 모아 보기
- [ ] latency_bell_ringer: baseline / telegraph / signature / break / 모아 보기
- [ ] mana_triage_surrogate: baseline / telegraph / signature / break / phase1 / phase2 / 모아 보기
- [ ] organ_quorum_witness: baseline / telegraph / signature / break / phase1 / 모아 보기
- [ ] permit_inspector: baseline / telegraph / signature / exposure / 모아 보기
- [ ] residue_cantor: baseline / telegraph / signature / break / phase1 / phase2 / 모아 보기
- [ ] seam_arbiter: baseline / telegraph / signature / break / phase1 / phase2 / 모아 보기
- [ ] worksheet_instructor: baseline / telegraph / signature / break / phase1 / phase2 / 모아 보기
- [ ] wrong_return_scribe: baseline / telegraph / signature / exposure / 모아 보기
- [ ] 전체 시트, QA.md, __pycache__ 정리

합계: 상태 그림 36장 + 단계 그림 11장 = 47장.
