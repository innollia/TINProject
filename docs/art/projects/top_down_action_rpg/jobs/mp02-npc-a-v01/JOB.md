# mp02-npc-a-v01 — NPC 10명 필드 그림 + 대화 초상화

상태 (2026-09-27 06:00 KST): **대화 초상화 10장 완료 (candidate)**. **NPC 필드 그림은 대기**: COMMON.md의 '캐릭터 스프라이트 형식'이 아직 미정이라 걸어 다니는 캐릭터는 만들지 않는다(8방향 시험 `h0-icon-8dir-v02` 결과로 정해짐). 결과는 전부 candidate이고 승인은 사용자만 한다. 게임에 연결하지 않았다.

| 필드 | 값 |
|---|---|
| 목적 | 자산 제작: 09 §12.5 `portrait_dialogue`(대화 초상화, 완료)와 §12.2 `gameplay_sprites`(NPC 필드 그림, 대기). 14 §3 목적 목록에는 인물 항목이 없어 09 자산군 이름을 쓴다 |
| 근거 결정 | `docs/art/mass_production/COMMON.md`(2026-09-27 저장소로 옮김, ✅ 기준 확정 04시): 아이콘 조합 양산, 분위기 V1(`h0-icon-mood-v02`), 빛과 그림자는 게임 코드, 캐릭터를 배경에 합친 검수 그림 금지, 방향 없는 그림(초상화 포함) 먼저, 걸어 다니는 캐릭터는 8방향 기준 확정 뒤. 사용자 지시(세션 02 대화): 한 명씩 필드 그림과 초상화를 끝내고 다음 사람, 마지막에 필드 그림 시트와 초상화 시트를 따로. 필드 그림이 막혀 초상화 10장을 먼저 만들었다 |
| 소유권 | 세션 02. 쓰기 범위: `assets/art/top_down_action_rpg/jobs/mp02-npc-a-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp02-npc-a-v01/`. 게임 코드·씬·content·규칙 문서 수정 없음, 게임 연결 없음, 커밋 없음 |
| 자산 identity | NPC ID 10개와 각 `appearance.body_key` / `portrait_key`는 content의 실제 값. `art_npc_core_portrait`는 09 §12.10 조회 키이지 자산 ID가 아니다. 파일 이름은 이 작업의 설계 |
| 입력 계약 버전 | `inputs.json`: COMMON.md, 09, 14, 04 dossier, PROJECT_ART_LAYER 0.1, PERSONAL_STYLE_CORE 0.3, IMAGE_ASSET_WORKFLOW, VISUAL_DIRECTION, V1 팔레트·도구·캐릭터 시트, 화면 코드 2개, content npcs 10개의 SHA-256 |
| 카메라 | 초상화: 눈높이 3/4 흉상, 화면 오른쪽(대사 글 쪽)을 봄, 60° 계산 끔(작성자 설계, 09 §12.5 "3/4 bust"). 필드: 지면 기준 60° 정사영, 방위 고정, 바닥 ×0.866, 높이 ×0.5 |
| 입력 이미지 | 픽셀 입력 없음. 모양 재료는 `addons/at-icons/node2d` SVG(MIT), 그림마다 쓴 아이콘 SHA-256은 결과 옆 `.json`. 화풍은 V1 `preview/asset_sheet_v1_characters_1x.png`와 `output/`을 눈으로 보고 맞춤. 다른 mpNN 작업 결과는 보지 않음 |
| 팔레트 | `recipes/palette_mp02_npc.json` = `palette_h0_mood.json`(V1) 값을 하나도 바꾸지 않고 그대로 + 아래 추가분. 윤곽선·그림자·공통 색과 세 스타일은 V1 그대로 |
| 금지 | 글자·UI·워터마크, 원작(BLACK SOULS, Alice) 요소, 원래 아이콘 모양이 그대로 읽히는 조각, 몸 변화의 과한 묘사(04 §4.5, spectacle 금지), 배경·가구를 인물에 굽기, 캐릭터를 배경 위에 합친 검수 그림, 다른 세션 폴더 읽기·쓰기 |
| 수정 범위 | 이 작업 폴더 안 새 파일만 |
| 승인 상태 | 전부 candidate. 인물·초상화 Gold Standard 없음 |
| 검수 | `QA.md` |
| 중단 이유 | 필드 그림 240칸: COMMON.md '캐릭터 스프라이트 형식'이 "아직 미정". 확정되면 COMMON.md를 다시 읽고 아래 "필드 그림 계획"대로 시작 |

## 결과 파일 (assets/art/top_down_action_rpg/jobs/mp02-npc-a-v01/)

| NPC | 초상화 (320×320 투명 PNG, 피벗 = 얼굴 기준점 (168,128)) | 필드 그림 |
|---|---|---|
| 01 Ilyra Senn | `output/npc_01_ilyra_senn/portrait_ilyra_senn.png` | 대기 |
| 02 Orrin Kest | `output/npc_02_orrin_kest/portrait_orrin_kest.png` | 대기 |
| 03 Veya Morcant | `output/npc_03_veya_morcant/portrait_veya_morcant.png` | 대기 |
| 04 Sable Halm | `output/npc_04_sable_halm/portrait_sable_halm.png` | 대기 |
| 05 Nera Voss | `output/npc_05_nera_voss/portrait_nera_voss.png` | 대기 |
| 06 Tamas Quill | `output/npc_06_tamas_quill/portrait_tamas_quill.png` | 대기 |
| 07 Bryn Oskel | `output/npc_07_bryn_oskel/portrait_bryn_oskel.png` | 대기 |
| 08 Meral Dune | `output/npc_08_meral_dune/portrait_meral_dune.png` | 대기 |
| 09 Perrin Lask | `output/npc_09_perrin_lask/portrait_perrin_lask.png` | 대기 |
| 10 Juno Caster | `output/npc_10_juno_caster/portrait_juno_caster.png` | 대기 |

- 파일 이름 = content `portrait_key`. 각 PNG 옆 `.json`에 상태, 크기, 피벗, 쓴 아이콘 SHA-256, 레시피 해시.
- 초상화 시트: `preview/sheet_npc_portraits_1x_88px.png` (윗줄 원본 320px, 아랫줄 대화창 표시 크기 88px, V1 바탕색 #3a343f).
- 레시피: `recipes/<npc_id>_portrait.json` (스크립트가 만든 것), 팔레트 `recipes/palette_mp02_npc.json`.

## 초상화 규격 (작성자 설계)

- 320×320 투명 PNG, 3/4 흉상, 모두 화면 오른쪽을 본다. 가슴은 캔버스 아래 가장자리에서 잘리고(의도), 어깨는 맨 아래 15~38줄에서 좌우 가장자리에 닿는다(의도). 머리카락·모자는 위 가장자리에서 11px 이상 안쪽.
- 얼굴 기준점(두 눈 사이) = (168,128), 가까운 눈 중심 (146,129), 먼 눈 중심 (194,127): 10장 모두 같다. 기준점은 게임 대화창 자리표시 그림의 머리 위치(가로 50%, 세로 38%, `top_down_row.gd` `_draw_portrait`)에 맞춘 값이고, manifest의 `pivot`에 기록.
- 얼굴: 코·입·턱을 잇는 가운데 선을 경계로 먼 쪽 볼에 그림자 면을 깔고(PERSONAL_STYLE_CORE §1), 얼굴 덩어리 자체는 거의 평평하게 칠해 우연한 얼룩이 생기지 않게 했다. 눈은 흰자·홍채·동공·빛점·윗눈꺼풀 선(바깥쪽이 굵음)·아랫눈꺼풀·쌍꺼풀 선. 눈 크기, 눈꺼풀 내림, 기울기, 눈썹 모양, 코 길이, 입 모양, 주름으로 얼굴을 다르게 했다.
- 선 두께·명암·붓자국은 V1 `sprite` 스타일 값 그대로(COMMON '크기 통일': 모든 종류 같은 선 두께와 밀도). 초상화에만 준 차이 두 가지: ① 캔버스 가장자리에 윤곽선이 생기지 않게 `silhouette.edge_extend` ② 넓은 옷 덩어리에서 얼룩이 위장무늬처럼 보여 옷 얼룩을 크게·드물게·약하게(size 26, density 0.08, strength 0.1)하고 명암 경계 흔들림을 0.2→0.07로. 필드 그림에는 V1 기본값을 그대로 쓴다.
- 표정 변형은 content에 없어 정체성 초상 하나만 만들었다.

## 팔레트에 더한 것 (`palette_mp02_npc.json`, V1 대비)

- 색 2개: `sclera` #a89e94(흰자, V1 밝기에 맞춰 어둡게), `catchlight` #e8dcc8.
- 피부 3개: `skin_warm`, `skin_tan`, `skin_deep` (V1 `skin`은 가장 밝은 피부로 그대로 씀). 명암 규칙은 V1 `skin`과 같음.
- 머리카락 10개: blueblack, grey, ash, copper, auburn, chestnut, darkbrown, black, white, honey. 붓자국은 V1 `hair`와 같음.
- 옷 17개: slate, slate_dark, ash, ember, ink, steel, teal, rose, brown_dark, brick, cream, olive, indigo, sand, oat, sage, mustard. 유리 2개: `lens_glass`, `water_glass`. 붓자국·얼룩은 V1 `coat`와 같은 방식.

## 인물 설계 (작성자 설계)

근거: content JSON의 역할·능력·주는 물건, 04 dossier의 역할·기관·몸 변화 첫 단계. 두 문서 모두 얼굴·머리·옷 서술이 없다. 몸 변화는 첫 단계와 작은 암시만 넣었다. V1 플레이어는 어두운 자주 외투 + 포도주색 목도리 + 갈색 가방 + 짙은 갈색 단발이라, 원래 계획의 Veya 보조색(검붉은 띠)을 강철 회색으로 바꿨다. 한쪽 표시는 인물 몸 기준(초상화에서는 인물의 오른쪽이 화면 왼쪽, 가까운 쪽).

| # | 인물 | 체형·키 | 실루엣 핵심 | 대표 색 (주 / 보조) | 머리·얼굴 | 소지품·표시 | 한쪽 표시 |
|---|---|---|---|---|---|---|---|
| 1 | Ilyra Senn (여) | 큼(+6), 마름 | 곧은 긴 옷, 높은 올림머리 + 청동 필기구 | 회청색 / 종이색 | 검푸른 올림머리, 밝은 피부, 내리뜬 눈 | 가슴 주머니의 빈 색인 카드, 청동 핀, 오른손 종이 띠(필드) | 오른손 종이 띠 |
| 2 | Orrin Kest (남) | 보통, 떡 벌어짐 | 네모난 몸통, 두꺼운 검사복 | 재회색 / 불씨 주황 | 짧은 회색 머리, 수염 자국, 짙은 피부, 지친 눈 | 목에 내린 천 마스크, 격리 팔띠, 접수판(필드) | 왼팔 팔띠 |
| 3 | Veya Morcant (여) | 보통(+2), 꼿꼿 | 뾰족한 어깨 망토, 높은 깃 | 먹색 / 강철 회색 | 오른쪽이 긴 재빛 금발 단발, 날카로운 눈 | 목 앞 강철판, 봉인 막대(필드) | 단발 긴 쪽(오른쪽) |
| 4 | Sable Halm (여) | 보통, 단단함 | 높은 포니테일 + 보안경, 공구 상자(필드) | 청록 / 청동·가죽 | 구릿빛 붉은 머리, 그을린 피부, 뺨의 기름 얼룩 | 가죽 멜빵, 가슴 주머니의 렌치 | 공구 상자(오른손) |
| 5 | Nera Voss (여) | 보통, 풍만 | 넓은 숄 + 종 모양 긴 치마(필드) | 먼지 낀 장미색 / 짙은 갈색 | 오른쪽 어깨로 넘긴 긴 적갈색 물결 머리 | 청동 브로치, 장부 사슬 | 장부(왼쪽 허리) |
| 6 | Tamas Quill (남) | 큼(+4), 마름 | 긴 외투 + 비스듬한 두루마리 통 끈 | 벽돌빛 적갈색 / 크림색 | 흐트러진 밤색 머리, 둥근 안경, 걱정스러운 눈썹 | 귀 뒤 깃펜, 청동 귀 장치 | 오른쪽 귀 장치 |
| 7 | Bryn Oskel (남) | 큼(+8), 다부짐 | 쓴 두건 + 배낭 + 지팡이(필드) | 올리브 / 가죽 갈색 | 흰 가닥 섞인 짙은 수염, 풍상 겪은 얼굴 | 왼눈 렌즈 장치, 배낭 끈, 어깨의 밧줄 | 왼눈 렌즈, 지팡이(오른손) |
| 8 | Meral Dune (여) | 보통, 단단함 | 머리 두건 + 물 항아리(필드) | 쪽빛 남색 / 모래색 | 흰 섞인 검은 머리, 짙은 피부, 굳은 턱 | 물방울 유리 목걸이, 씨앗 주머니(필드) | 항아리(왼쪽 어깨) |
| 9 | Perrin Lask (남, 문서에 성별 단서 없음) | 작음(−14), 조금 굽은 노인 | 둥근 긴 가디건 | 귀리색 / 세이지 초록 | 대머리에 옆머리만 흰 머리, 처진 온화한 눈, 주름 | 끈에 단 청동 종, 나무 이름표 | 없음 |
| 10 | Juno Caster (여) | 작음(−8), 활발 | 챙 넓은 모자 + 나팔(필드) | 겨자색 / 검정 | 꿀빛 짧은 곱슬, 말하는 중인 벌린 입 | 가슴에 핀으로 꽂은 빈 종이 | 나팔(오른손) |

- 세션 03의 NPC(11~14, 20~26)와 색이 겹칠 수 있다. 다른 세션 폴더는 보지 않으므로 메인 대화에서 함께 비교한다.

## 도구 변경 (V1 `h0-icon-mood-v02/tool` 복사본만 고침)

- `tool/iconkit/icons.py`: 아이콘 변환 병렬 개수 기본값 8 → 2 (세션 10개가 같은 컴퓨터를 씀).
- `tool/iconkit/render.py`: 스타일 `silhouette.edge_extend` 옵션 추가. 캔버스 가장자리에서 잘린 흉상 아래쪽에 윤곽선이 생기지 않게 한다. 켜지 않으면 결과는 V1과 같다.
- `tool/review_sheet.py`: `--label` 글자색 옵션 추가(어두운 V1 바탕에서 이름표가 안 보여서). 기본값은 그대로.
- 새 파일 `tool/mp02_make_recipes.py`: 팔레트와 초상화 레시피 10개를 만드는 스크립트. 얼굴 도구(얼굴·목·귀·그림자 면, 눈, 눈썹, 코, 입), 머리 가닥(`lock`), 짧은 머리 붓질(`dashes`), 옷(`cloth`, 초상화용 얼룩 값) 도우미가 들어 있다. 얼굴·깃·작은 선은 `square` 아이콘을 다각형으로 자른 조각, 머리카락·옷 주름·소품은 아이콘 모양(원, 물방울, 방패, 종, 꼬리표, 깃털, 렌치 등)을 쓴다.

## 재실행

`tool` 폴더에서 `py -3 -B mp02_make_recipes.py` (팔레트 + 레시피) → `py -3 -B build.py ..\recipes\npc_01_ilyra_senn_portrait.json …` (끝난 그림은 건너뜀) → `py -3 -B review_sheet.py --scales 1,0.275 --bg "#3a343f" --label "#bdb3c4" --out ..\preview\sheet_npc_portraits_1x_88px.png ..\output\npc_*\portrait_*.png`.

## 필드 그림 계획 (8방향 기준 확정 뒤)

- 한 칸 192×192 투명 PNG, 피벗 (96,186) = 두 발 사이 접점(V1 플레이어와 같음), 접촉 그림자 `_shadow.png` 따로. 8방향 × 3칸(1 한쪽 발, 2 서 있기, 3 다른 발), 걷기 1-2-3-2, 걷는 칸은 다리 앞뒤·팔과 옷자락 흔들림. 기본 시트(아래·왼쪽·오른쪽·위)와 대각선 시트(왼쪽 아래·오른쪽 아래·왼쪽 위·오른쪽 위). 파일 이름·시트 배치는 `h0-icon-8dir-v02` 결과를 따른다.
- 보기 레시피 5개(앞, 뒤, 옆, 앞 3/4, 뒤 3/4), 오른쪽 계열은 좌우 반전 + 위 표 "한쪽 표시" 보정. 키는 플레이어와 같은 정수리 높이를 기준으로 +8/−16px 안, 가장자리 4px 안쪽. 소품 크기는 플레이어 키 기준 실제 비율. 옷 색·소지품은 초상화와 같게.
- 인물 순서 1 → 10, 인물마다 build → 직접 확인 → 고치기(최대 2번) → 방향 시트 2장. 마지막에 필드 그림 시트(10명 × 8방향 서 있기 칸, 1배·0.5배).
- 상태 그림: 기본 모습 하나. presence가 `absent`면 그리지 않음. 몸 변화 단계와 화면 코드의 `changed` 변형은 그림 규칙이 없어 만들지 않음(작성자 설계).

## 체크리스트

- [x] 자료 읽기, 만들 대상, 인물 설계
- [x] V1 도구·팔레트 복사(`tool/`, `recipes/palette_h0_mood.json`), workers ≤ 2, `inputs.json`, `palette_mp02_npc.json`
- [x] 초상화 01 Ilyra (고침 2번) / 02 Orrin (2번) / 03 Veya (2번) / 04 Sable (0번) / 05 Nera (1번)
- [x] 초상화 06 Tamas (1번) / 07 Bryn (2번) / 08 Meral (0번) / 09 Perrin (1번) / 10 Juno (1번)
- [x] 초상화 시트 `preview/sheet_npc_portraits_1x_88px.png`, `QA.md`
- [ ] 8방향 기준 확정 대기 (COMMON.md '캐릭터 스프라이트 형식')
- [ ] 필드 그림 01 ~ 10 (인물마다 24칸 + 시트 2장)
- [ ] 필드 그림 시트
- [ ] 1순위 중간 보고 → 2순위 02 Odd Road(`plans/kits/02_ODD_ROAD_KIT.md`) → 최종 보고 후 멈춤. 3순위(범용 그림)는 2026-09-27 사용자 결정으로 g 세션 담당이라 하지 않음

## 확인한 사실

- 화면 코드: NPC 필드 변형은 `normal` / `changed` / `absent`(`top_down_screen.gd` `_field_variant`). presence 값은 `resident`, `visiting`, `transient`, `absent`, `pending`(`content_loader.gd`). 초상화는 대화창 88×88 칸(09 §5.1, x=28 y=572)이고, portrait_key가 없으면 칸을 숨긴다.
- content: `appearance`에는 `body_key`, `portrait_key`, `voice_key`만 있다. 지역 JSON의 residents에는 배치 좌표가 없다.
- 04 dossier: 외모 항목이 없다(§1.1 필수 필드에도 없음). 몸 변화는 graphic reveal보다 기능·기록 변화로 판정한다(§4.5와 각 인물 arc).
- 성별 단서: Ilyra her, Orrin his, Veya 그녀, Sable her, Nera 그녀, Tamas he, Bryn him, Meral her, Juno her. Perrin은 단서 없음(작성자 설계로 남성 노인).
