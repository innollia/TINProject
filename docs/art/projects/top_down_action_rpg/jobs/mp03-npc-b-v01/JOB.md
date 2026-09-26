# mp03-npc-b-v01 — NPC 11명 필드 그림·대화 초상화

상태: **초상화 제작 중 (V1 기준).** 필드 그림(걸어 다니는 캐릭터)은 COMMON.md의 '캐릭터 스프라이트 형식'이 아직 미정이라 만들지 않는다. 결과는 전부 candidate이고 승인은 사용자만 한다. 게임에 연결하지 않는다.

| 필드 | 값 |
|---|---|
| 목적 | 아이콘 조합 양산(세션 03): NPC 11명의 대화 초상화, 기준이 정해지면 필드 스프라이트(8방향 × 3칸) |
| 근거 결정 | 사용자 결정 2026-09-27 (COMMON.md): 아이콘 조합 양산, 분위기는 `h0-icon-mood-v02`의 V1(어두운 색, 낡은 재질, 그림에는 확산광만), 빛·그림자는 게임 코드가 한다, 캐릭터를 배경에 합친 그림은 만들지 않는다, 방향 없는 그림(초상화 포함)부터 만든다, 캐릭터 스프라이트는 실제 RPG Maker 구성의 8방향(기준 미정) |
| 소유권 | 세션 03. 쓰기 범위: `C:\projects\TINProject\assets\art\top_down_action_rpg\jobs\mp03-npc-b-v01\`, `C:\projects\TINProject\docs\art\projects\top_down_action_rpg\jobs\mp03-npc-b-v01\`. 게임 코드·씬·content JSON·규칙 문서 수정 없음 |
| 자산 identity | 아래 '만들 것' 표. NPC ID·body_key·portrait_key는 content JSON의 실제 값, 초상화 묶음 키는 09 §12.10의 `art_npc_core_portrait` / `art_npc_support_portrait` |
| 입력 계약 버전 | 파일 목록과 SHA-256은 끝날 때 `inputs.json`에 적는다 |
| 카메라 | 초상화: 정면에서 본 3/4 흉상(60° 계산 안 씀, 09 §12.5). 필드 그림: 지면 기준 하향각 60° 정사영, 방위 고정 |
| 입력 이미지 | 픽셀 입력 없음. 모양 재료는 `C:\projects\TINProject\addons\at-icons\node2d` SVG. 화풍은 `h0-icon-mood-v02`의 `preview\asset_sheet_v1_characters_1x.png`·`output\player`를 눈으로 보고 맞춘다 |
| 팔레트 | `recipes\palette_npc_b.json` = `palette_h0_mood.json`(V1) 그대로 + 인물 재질 + `portrait` 스타일(아래). 윤곽선·그림자·공통 색은 V1 값 그대로 |
| 금지 | 글자·UI·워터마크, 원작(BLACK SOULS, Alice) 고유 요소, 아이콘 원래 모양이 그대로 읽히는 조각, 장면 조명·비네트·불빛 웅덩이, 캐릭터를 배경에 합친 그림, 다른 mp 작업 폴더 참조, 서브에이전트, git 커밋·푸시, 새 프로그램 설치 |
| 승인 상태 | 승인된 기준 그림 없음. 시험 작업 결과도 candidate |
| 중단 이유 | 필드 그림만: 8방향 파일 이름·시트 배치 미정(`h0-icon-8dir-v02` 결과로 정해질 예정, COMMON.md에 '확정'이 적힐 때까지 대기) |

## 만들 것 (순서대로)

| # | NPC ID | 이름 | 종류 | 지역 | body_key | portrait_key | 초상화 묶음 키 |
|---|---|---|---|---|---|---|---|
| 1 | `npc_11_cael_ren` | Cael Ren | core | R1, H0 | `body_carryer` | `portrait_cael_ren` | `art_npc_core_portrait` |
| 2 | `npc_12_ravenna_holt` | Ravenna Holt | core | H0 | `body_protocol_envoy` | `portrait_ravenna_holt` | `art_npc_core_portrait` |
| 3 | `npc_13_tovan_reed` | Tovan Reed | core | R1, R6 | `body_field_medic` | `portrait_tovan_reed` | `art_npc_core_portrait` |
| 4 | `npc_14_eda_marrow` | Eda Marrow | core | R8, H0 | `body_labor_coordinator` | `portrait_eda_marrow` | `art_npc_core_portrait` |
| 5 | `npc_20_mira_vask` | Mira Vask | support | R8 | `body_clerk` | `portrait_mira_vask` | `art_npc_support_portrait` |
| 6 | `npc_21_halen_osk` | Halen Osk | support | R8 | `body_store_keeper` | `portrait_halen_osk` | `art_npc_support_portrait` |
| 7 | `npc_22_iven_marrow` | Iven Marrow | support | R8 | `body_yard_instructor` | `portrait_iven_marrow` | `art_npc_support_portrait` |
| 8 | `npc_23_turo_bex` | Turo Bex | support | R8 | `body_cut_chamber_instructor` | `portrait_turo_bex` | `art_npc_support_portrait` |
| 9 | `npc_24_perri_lowe` | Perri Lowe | support | R8 | `body_lineage_registrar` | `portrait_perri_lowe` | `art_npc_support_portrait` |
| 10 | `npc_25_jano_fesk` | Jano Fesk | support | R8 | `body_circulation_liaison` | `portrait_jano_fesk` | `art_npc_support_portrait` |
| 11 | `npc_26_cael_orin` | Cael Orin | support | R8 | `body_unassigned_inventor` | `portrait_cael_orin` | `art_npc_support_portrait` |

사용자 지시는 "한 명의 필드 그림과 초상화를 다 만든 다음 다음 사람"이지만, COMMON.md(2026-09-27 04시) 결정으로 필드 그림은 기준이 확정될 때까지 만들 수 없다. 그래서 초상화 11장을 순서대로 먼저 만들고, 기준이 확정되면 필드 그림을 같은 순서로 만든다.

## 인물 설계 (작성자 설계)

content JSON과 04_CHARACTERS_AND_RELATIONSHIPS.md(§2.4 NPC-20~26, §3 NPC-11~14)에 외모 서술이 없다. 그래서 아래 외모는 전부 역할·직업·소지품에서 정한 **작성자 설계**다. 성별도 문서에 없으면 작성자 설계다(Ravenna만 JSON에 she가 있음).

공통:
- 비율·화풍은 V1 플레이어(`h0-icon-mood-v02\recipes\player_*.json`)와 같게. 필드 그림에서 키는 플레이어보다 크지 않게 하고, 차이는 폭·머리 위·등짐·아랫단으로 낸다.
- 필드 그림은 좌우 뒤집기로 오른쪽 방향을 만들 수 있게 큰 소지품을 몸 가운데·등·양쪽에 둔다.
- R8 학교(MAG_ACADEMY) 소속 3명(Mira, Halen, Iven)은 목에 접힌 종이 모양의 뼈색 깃을 단다. 다른 기관 소속(Turo, Perri, Jano)과 기관이 없는 Cael Orin은 달지 않는다.
- Cael Ren과 Cael Orin은 이름이 겹치지만 다른 사람이다(04 §2.4). 나이·색·실루엣을 정반대로 둔다. Iven과 Eda는 성(Marrow)이 같지만 관계가 문서에 없으므로 닮게 그리지 않는다.

대표 색은 V1 밝기에 맞춰 준비 단계 계획보다 어둡게 바꿨다(`palette_npc_b.json`의 재질 이름).

| NPC | 대표 재질 (기본색) | 피부 / 머리 | 한눈에 알아보는 실루엣 |
|---|---|---|---|
| Cael Ren | `cr_wrap` 녹슨 불씨 주황 `#743b28`, 옷 `cr_cloth` 재 회색 | `skin` / `hair` | 등의 나무 지게틀이 머리 옆 높이까지 솟음 |
| Ravenna Holt | `rh_coat` 검붉은 포도주색 `#4d1c29`, 장갑 `rh_glove` | `skin` / `hair_black` | 바닥까지 닿는 곧은 코트, 각진 어깨 망토, 틀어 올린 머리 |
| Tovan Reed | `tr_coat` 이끼 초록 `#3d4836`, 앞치마 `tr_apron` | `skin_tan` / `hair_brown` | 넓고 두꺼운 몸, 등에 가로로 묶은 들것 |
| Eda Marrow | `em_jacket` 황토 `#7a5f2e`, 머릿수건 `em_kerchief` | `skin_deep` / `hair_black` | 넓은 어깨, 머리 높이까지 오는 갈고리 정비 장대 |
| Mira Vask | `mv_robe` 회청색 `#485668`, 흰 토시 `paper` | `skin` / `hair_ash` | 작고 가는 몸, 곧은 로브, 옆구리에 낀 두꺼운 색인 책 |
| Halen Osk | `ho_apron` 올리브 `#4d4a2c`, 셔츠 `ho_shirt` | `skin_tan` / `hair_grey` | 작고 옆으로 넓은 몸, 짧은 챙 모자, 긴 앞치마 |
| Iven Marrow | `iv_coat` 청록 `#2e4d48`, 목도리 `iv_scarf` | `skin` / `hair_auburn` | 키 크고 마른 몸, 넓은 챙 모자, 늘어진 긴 목도리 |
| Turo Bex | `tb_apron` 짙은 가죽 갈색 `#452f1e`, 옷 `tb_cloth` 숯색 | `skin_deep` / `hair_black` | 가장 작고 단단한 몸, 굵은 팔 토시, 이마 위 보안경, 등의 곧은 칼집 |
| Perri Lowe | `pl_robe` 탁한 장밋빛 `#693f48`, 청동 단추 | `skin` / `hair_black` | 머리 뒤까지 솟은 세운 깃, 두 손으로 든 상자 |
| Jano Fesk | `jf_coat` 짙은 남색 기름천 `#23354e`, 청동 측정 막대 | `skin_tan` / `hair_brown` | 후드 기름천 코트, 아랫단이 넓게 퍼짐, 긴 측정 막대 |
| Cael Orin | `co_smock` 바랜 뼈색 `#9f9682`, 잉크 얼룩 | `skin_aged` / `hair_white` | 허리가 굽은 노인, 흐트러진 흰머리, 넓은 소매, 등에 둥근 통 |

인물별 근거와 소지품:
1. **Cael Ren** — JSON "지역 사이로 사람과 물건을 나른다", `carry_claimant`, `spend_ash_thread`, `port_kiln_relay`, "구해 주고 나중에 길값을 받는다", 04 §3 원본의 이름을 갖고 태어난 복제 러너. 지게틀에 감은 주황 재 실, 틀에 매단 청동 길값 꼬리표, 목에 내린 녹슨 두건, 한쪽 어깨에만 새로 덧댄 천(원본과 다른 자기 흔적), 눈 밑 그을음. 짧게 자른 머리.
2. **Ravenna Holt** — JSON "운영자가 의심받는 동안 자리를 지키는 사절", `withhold_seal`, `levy_resource`, 04 §3 decree seal·guard. 높은 깃, 뻣뻣한 어깨 망토, 가슴의 둥근 청동 인장(사슬), 짙은 장갑, 틀어 올린 머리, 다문 입. 왕관은 쓰지 않는다(운영자가 아니라 사절).
3. **Tovan Reed** — JSON "몸이 아직 할 수 있는 일로 생존자를 분류한다", `triage_subject`, `carry_survivor`, 04 §3 수술 도구·들것. 걷어 올린 소매, 바랜 흰 앞치마, 팔뚝 붕대, 등에 가로로 묶은 말린 들것, 청동 걸쇠 약가방, 이마에 묶은 머리 수건, 짧은 수염, 피곤한 눈.
4. **Eda Marrow** — JSON "돌봄·물·정비를 돌리는 교대를 부른다", `mobilize_shift`, `protect_worker`, 04 §3 노동자 명부·정비 도구. 황토 작업 재킷, 무거운 공구 벨트, 교대 나무패 묶음, 갈고리 장대, 붉은 갈색 머릿수건, 옷깃에 이름 없는 핀 여러 개(앞선 집단의 흔적). 성별 작성자 설계(여성).
5. **Mira Vask** — JSON "강좌 색인과 학생 신분 담당", `print_course_index`, 04 §2.4 course index 원본. 회청색 로브, 흰 토시, 학교 깃, 두꺼운 색인 책, 도장, 작은 둥근 안경, 낮게 묶은 머리. 성별 작성자 설계(여성).
6. **Halen Osk** — JSON "층별로 공백지와 종이를 내준다", "서로 다른 두 재고 대장". 올리브 긴 앞치마, 갈색 셔츠, 짧은 챙 모자, 학교 깃, 열쇠 꾸러미, 앞치마 주머니의 장부 두 권, 종이 뭉치, 귀에 꽂은 연필, 두꺼운 눈썹. 성별 작성자 설계(남성).
7. **Iven Marrow** — JSON "야외 접기를 채점하고 학점을 회수한다", `grade_fold`, `reclaim_sheet`. 청록 긴 코트, 넓은 챙 모자, 줄무늬 긴 목도리, 학교 깃, 채점판, 회수한 종이 묶음, 짧은 턱수염. 성별 작성자 설계(남성).
8. **Turo Bex** — JSON "계약서를 쓰고 실패한 절단을 벽에 남긴다", `write_contract`, 04 §2.4 절단 도구·VOID_CONTRACT_COURT. 두꺼운 가죽 앞치마, 양팔 긴 가죽 토시, 이마 위 보안경, 등의 곧은 칼집, 계약서 두루마리 통, 짧게 민 머리, 굵은 목. 성별 작성자 설계(남성).
9. **Perri Lowe** — JSON "접근 토큰을 발급하고 이름 없는 상자를 지킨다", 04 §2.4 LINEAGE_HOUSE. 장밋빛 로브, 세운 깃, 청동 단추, 글자 없는 작은 상자(청동 모서리), 나무 토큰 끈, 짧은 단발, 가는 눈. 성별 작성자 설계(여성).
10. **Jano Fesk** — JSON "물 협의회의 측정값을 학교 장부로 옮긴다", `measure_field`, `compare_provenance`, 04 §2.4 CIRCULATION_BOARD. 남색 후드 기름천 코트, 목 긴 장화, 청동 측정 막대(끝에 추), 출처가 다른 물병 두 개, 젖은 앞머리, 옅은 수염. 성별 작성자 설계(남성).
11. **Cael Orin** — JSON "학교 명부의 예술 칸에만 있고 어느 강좌에도 없다", `produce_old_margin`, 04 §2.4 학생이 아님·자기 시대의 재료와 도구를 안다(→ 노인으로 설계). 바랜 뼈색 헐렁한 겉옷(넓은 소매, 잉크 얼룩), 등의 둥근 설계 두루마리 통, 접이 자·컴퍼스 조각, 흐트러진 흰머리, 깊은 주름. 성별 작성자 설계(남성).

## 초상화 형식

- 파일: `output\<npc_id>\<portrait_key>.png` 320×320 투명 PNG + 같은 이름 `.json`(identity, `anchors.face`, 사용 아이콘과 SHA-256). 레시피: `recipes\portrait_<이름>.json`.
- 3/4 흉상, 얼굴은 화면 오른쪽(대화 글 쪽)을 향한다. 어깨는 아래 가장자리에서 끊기는 것이 정상이다(외곽선은 끊긴 가장자리에 그리지 않음).
- 얼굴 기준점(모든 초상화 같은 픽셀): 두 눈 사이 (168,124) = 레시피 `pivot`, 머리 중심 (160,122). 게임의 임시 초상화(`top_down_row.gd` `_draw_portrait`: 머리 중심 가로 50%·세로 38%, 반지름 20%)에 맞춘 값. 세션 02와 다를 수 있어 합칠 때 메인 대화에서 맞춘다.
- `portrait` 스타일: V1 `sprite` 스타일과 같고, 윤곽선·붓자국·얼룩·부품 그림자 크기만 1.8배. 320 원본이 88 논리 px(QHD에서 176 px)로 줄어 보이므로, 필드 그림(192 원본 = QHD 192 px)과 화면에서 같은 굵기로 보이게 하려는 값. 빛 방향은 V1과 같은 확산광 하나(왼쪽 위), 장면 조명·바닥 그림자 없음.
- 확인: 1배와 게임 표시 크기(0.275배)로 모아 보기를 만들어 read 도구로 본다. 얼굴이 88 px에서도 읽히는지, 기준점 십자가 두 눈 사이에 오는지.

## 필드 그림 형식 (미정 — COMMON.md 확정 뒤 그대로 따름)

준비 단계 임시안: 한 칸 192×192 투명 PNG, 피벗 (96,186) 발 접점, 8방향 × 3칸(`_1` 한쪽 발, `_2` 서 있기, `_3` 다른 발, 걷기 1-2-3-2), 기본 시트(아래·왼쪽·오른쪽·위)와 대각선 시트(왼쪽 아래·오른쪽 아래·왼쪽 위·오른쪽 위), 접촉 그림자는 `_shadow.png`. 정확한 파일 이름·시트 배치는 확정된 규칙으로 바꾼다.

## 도구 변경 (`h0-icon-mood-v02\tool\` 복사본 대비, 이 작업 폴더 안에만)

2026-09-27 04시 COMMON.md 규칙대로 옛 도구(`h0-icon-collage-v01`)를 V1 도구로 바꾸고, 준비 단계에 넣었던 기능을 다시 넣었다. 옛 `palette_h0.json` 사본은 지우고 `palette_h0_mood.json`을 복사했다.
- `tool\iconkit\icons.py`: 아이콘 변환 병렬 개수 최대 2(`MAX_WORKERS`). 세션 10개가 같은 컴퓨터를 쓰기 때문.
- `tool\iconkit\render.py`:
  - `scale_all.to`와 `translate_forms`: 늘린 그림을 새 캔버스 기준점으로 옮김. 그라데이션 줄 위치도 배율·이동을 따라감.
  - 스타일 `stamp_scale`: 붓자국·얼룩 도장 크기 배율(초상화 1.8). 없으면 1(기존과 같음).
  - 스타일 `silhouette.pad_edges`: 캔버스 가장자리에서 잘린 부분(흉상 아래쪽)에 전체 외곽선을 그리지 않음. 없으면 기존과 같음.
  - 도구 버전 `0.3-mood+mp03.1`.
- `tool\build.py`: 레시피의 `identity`(NPC ID, 키)와 `anchors`(얼굴 기준점)를 결과 `.json`에 복사.
- `tool\review_sheet.py`: `--cols`(줄 바꿈), `--crop`(같은 영역 잘라 보기), `--label-parent`(폴더 이름=NPC ID 표시), `--anchor`(기준점 십자 표시). 옵션을 안 주면 원래 배치 그대로.

## 진행 체크리스트

- [x] 작업 폴더, 도구·팔레트를 V1로 교체, 도구 기능 다시 넣기
- [x] 자료 읽기, 대상 목록, 인물 설계
- [x] `recipes\palette_npc_b.json`
- 초상화
  - [x] 1 Cael Ren
  - [ ] 2 Ravenna Holt
  - [ ] 3 Tovan Reed
  - [ ] 4 Eda Marrow
  - [ ] 5 Mira Vask
  - [ ] 6 Halen Osk
  - [ ] 7 Iven Marrow
  - [ ] 8 Turo Bex
  - [ ] 9 Perri Lowe
  - [ ] 10 Jano Fesk
  - [ ] 11 Cael Orin
  - [ ] 초상화 시트(11명, 기준점 표시)
- 필드 그림 (8방향 기준 확정 뒤)
  - [ ] 1~11 필드 8방향 × 3칸, 인물마다 모아 보기
  - [ ] 필드 그림 시트(11명)
- [ ] `inputs.json`(입력 파일과 SHA-256), `QA.md`, `__pycache__` 지우기
- [ ] 1순위 중간 보고 → 2순위 03 Deduction Casework(`deduction_casework`) → 3순위 범용 특별한 사람(경비병, 기사, 마법사, 성직자, 귀족, 도적)

자산마다: 레시피 → build → read 도구로 직접 확인 → 고치기(최대 2번) → 다음.

## 검수 항목 (끝날 때 QA.md에 pass / partial / fail / not_run)

크기·알파·피벗, 가장자리 잘림, 글자·UI 없음, 화풍(V1과 같은 선·명암·붓자국·얼룩), 아이콘 원래 모양 티, 인물끼리 구분(흑백으로도), 초상화 기준점, 88 px 표시 크기에서 얼굴 읽힘, 8방향 구성과 걷기 동작(필드), 실제 게임 3해상도(게임 연결 금지라 not_run).
