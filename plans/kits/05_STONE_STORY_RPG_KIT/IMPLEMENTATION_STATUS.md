# IMPLEMENTATION_STATUS — Kit 05

> **2026-09-27 부모(통합 담당) 전달 — 사용자 답. 이 파일의 다른 내용과 부모 지시문보다 우선한다.** (§0.2 질문 1~4의 답)
> 1. 방향은 C(장대 위의 몸)로 확정. 사용자 원문: "기본 형태랑 그림체부터가 rainworld나 ena dream bbq스럽지가 않음. C가 맞음". C를 바탕으로 기본 형태와 그림체를 Rain World·Ena: Dream BBQ답게 다시 잡는다. 근거 자료는 저장소의 `docs/research/stone_story_rpg/02_ena_dream_bbq/`와 `docs/research/rain_world/`(읽기 전용)를 쓴다. 이 Kit은 에이전트 외부 조사 금지(SSR6)라 자료가 모자라면 필요한 자료를 질문으로 요청한다.
> 2. 플레이어도 같은 뼈대(발을 딛고 몸이 늘어짐) 확정. 지금대로 유지.
> 4. 다리는 전부 그린다. 사용자 원문: "다리 다발 좋아. 색깔 좀 단순하게 해서 다리랑 몸통 사이 끊기는 부분 안 보이게 하고 몸통도 관절 나누고 물리 넣어서 유연하게 해줘."
> 5. 생물 기준 정정: Rain World 수준의 절차 애니메이션이면 촉수 덩어리·눈알 여러 개도 된다. 거미만 안 된다. 앞선 부모 지시의 금지 목록은 이것으로 대체한다. `AGENTS.md` '절차적 생물·괴물 디자인'.
> 6. 사용자 선택 때문에 이미 한 작업을 되돌려야 하면 되돌리지 않는다. 질문 3(3계열 + 시드)은 답이 없어 지금대로 둔다.
> 7. 부모 지시문이 U-3·U-5·U-2만 하라고 했어도, 이번 실행에서 위 1·2·4의 개체 작업을 먼저 한다. 앞서 짚인 문제도 같이 고친다: 머리가 세 계열 모두 둥근 머리+흰 눈 하나로 같았고, 한 화면의 세 마리 중 둘이 크기만 달라 보였고, 싸움이 붙으면 플레이어와 적이 한 덩어리로 겹쳐 안 보였다. 창 모드 0.1초 간격 연속 프레임으로 걸음·몸통 휨·다리-몸통 이음매를 직접 판정하고, 결과 캡처를 절대 경로로 보고한다. 방향은 정해졌으니 다시 묻지 않는다. U-3·U-5·U-2는 그다음에 한다.
> 8. 거미 주의: C(몸을 높이 든 장대 다리)에 다리를 전부 그리면 둥근 몸 하나에서 긴 다리가 사방으로 뻗는 장님거미처럼 읽히기 쉽다. 사용자는 "거미가 안돼"라고 했다. 다리가 한 점에서 방사형으로 나오지 않게 하고, 관절로 나뉜 긴 몸통의 마디를 따라 다리가 붙게 한다. 캡처에서 거미로 읽히면 실패로 친다.


> 이 파일이 **사실의 원천**이다. 계획 문서보다 이 파일을 먼저 믿는다.
> 계획은 목표이고, 이 파일은 지금 실제로 되는 것과 안 되는 것을 적는다.

최종 갱신: 2026-09-27
브랜치: `kit/05-stone-story-rpg`

---

## 0. 다음 세션이 먼저 읽을 것

1. **개체(캐릭터) 표현은 사용자가 반려했다 (2026-09-27).**
   > "배경은 몰라도 캐릭터들이 너무 촌스럽지 않니. 내가 기대한건 rainworld식 procedural animation인데.
   > 개체들의 생김새가 정형화된 초현실주의인 점도 문제임"

   A3-a(좌표 실루엣 3종)는 폐기했다. 움직임 쪽은 §5 설계대로 **절차 애니메이션 리그(A3-b)로 교체 완료**
   (`057fb23c`). **생김새·움직임 방향은 사용자 답을 기다린다** (§0.2). 답이 오기 전에는 개체 생김새를 더 다듬지 않는다.
   배경(하늘·바닥·구조물·소품)은 사용자가 판정을 보류했다("배경은 몰라도"). 손대지 않는다.
2. 예전 '푸시 막힘'은 해소됐다. 이 Kit 커밋은 원격에 올라가 있다.
3. 프로젝트 전역 회귀(`tests/run_tests.gd`, GUT 전체, 180프레임 부팅)는 부모가 돌린다. 이 Kit 테스트 3개만 실측했다(§1).

### 0.2 사용자 답을 기다리는 것 (2026-09-27, sub-kit05)

사용자 정정: 게임 경험을 바꾸는 선택(개체·플레이어의 생김새와 움직임 방향 등)은 추천안으로 확정하지 않고 묻는다.

| # | 질문 | 후보 | 상태 |
|---|---|---|---|
| Q1 | 개체 생김새·움직임 방향 | A 딛고 걷는 짐승 / B 몸을 끌고 가는 것 / C 장대 위의 몸 (캡처 `kit05_captures/zoo/`) | 대기. 에이전트 추천 A 또는 C를 섞지 않고 하나만 |
| Q2 | 플레이어도 같은 리그인가 | 이미 같은 리그로 진행함(strider 계열, 무기는 앞팔 손). 뒤집을 수 있음 | 이미 진행 |
| Q3 | 몸 설계 3계열 유지 vs 완전 절차 | 이미 '계열 3개 + 시드로 비율 흔들기'로 진행함. 뒤집을 수 있음 | 이미 진행 |
| Q4 | 다리가 많은 개체(다리 속성 8~12)의 표현 | 지금은 다리를 전부 그려 보스가 '다리 다발'로 보인다(`r6_rig/cistern_1280x720.png`). 다리 수를 몸 마디·걸음 박자로 바꿔 보여 줄지 | 대기 |

기다리는 동안 멈춘 것: 개체 생김새 튜닝, 캡처 품질 판정, 보스 표현. 진행 가능한 것: U-3, U-5, U-2 관찰 기록.

### 0.1 2026-09-27 세션 작업 묶음

| 묶음 | 내용 | 들어간 커밋 |
|---|---|---|
| 1. 장면 (A1·A2·소품·D-1~D-7) | authored 팔레트 3 · 구조물 폴리곤 3 · 실루엣 3 · 소품 7 + 규칙 깨기 검증 · 하늘/바닥/구조물/소품/잉크 그리기 파일 분리 · 로비=허브 장면 · 허브 우물 작업 · 장면 테스트 신설 | `aec5d9a0` (다른 작업자의 일괄 백업 커밋에 섞여 올라감) |
| 2. 전투 루프 (D-8·D-9) | 무기 공격 주기 · 사거리 행동 전환 · 적 간격 · 플레이어 이동 · 보스 참전 · 휘두르기 자세 · core 테스트 3개 | `8dc7009e` (로컬만) |
| 3. 검증 도구 | 캡처 하네스 창 크기로 파일 이름 · 살아 있는 적 수 출력 · A3 구별 테스트를 구조 비교로 교체 | `8dc7009e` (로컬만) |
| 4. 문서 | 이 파일 · `17` §A · `README` §3·§4 | 이 커밋 (로컬만) |

증거: 캡처 `kit05_captures/r5_space/` (§1). 사용자가 본 뒤 반려한 개체는 이 묶음 1의 실루엣이다.

---

## 1. 검증 수치 (2026-09-27 실측, sub-kit05 리그 교체 후)

| 항목 | 결과 |
|---|---|
| `-gselect=test_stone_story_rpg_` (core 52 · visual 15 · scene 19) | **86/86**, 2171 assert, script error 0 |
| 다른 세션 기록의 core 'script error 4건' (`art/stone_rpg_art_view.gd:1068`) | 재현 안 됨. 그 파일은 이 저장소 어느 커밋에도 없다 → 다른 PC/다른 트리의 실행으로 판단 |
| 창 모드 캡처 `r6_rig` (lobby·hub·cistern, 1280×720) | 3장, exit 0, overlaps 0 / clipped 0 |
| 창 모드 캡처 `zoo` (후보 3 × 0.1초 간격 6장) | 18장, exit 0 |

### 1.1 이전 수치 (2026-09-27 오전)

| 항목 | 결과 |
|---|---|
| `test_stone_story_rpg_core.gd` | **52/52** |
| `test_stone_story_rpg_visual.gd` | **15/15** |
| `test_stone_story_rpg_scene.gd` (신규) | **15/15** |
| 합계 (`-gselect=test_stone_story_rpg_`) | **82/82**, 2101 assert |
| 창 모드 캡처 | 4장면 × 4해상도 = 16장, exit 0, 실패 0 |
| V13 겹침·잘림 (캡처 AUDIT) | 16장 전부 overlaps 0 / clipped 0 |
| 이미지 에셋 | 0개 |
| ASCII 문자 렌더 | 0 |
| 프로젝트 전역 회귀 | **미실행** (§0-3) |

`DRAW_STATS` (저수조 ★12, 비주얼 테스트):

```
filled=1.000  flatblack=0.00  strokes=0.00  hues=7  grey=0.13
sky=16  ground=6  big=0.46  eyes=18
```

**V1~V15 통과는 하한선이다.** 2026-09-26, 2026-09-27 두 번 모두 V 전부 통과 상태에서 사용자가 화면을 반려했다.

캡처 위치: `%APPDATA%\Godot\app_userdata\TINProject\kit05_captures\<step>\<장면>_<창 크기>.png`
마지막 묶음은 `r5_space/`. 1920×1280 창은 프로젝트 비율 유지(`project.godot`, 소유 밖) 때문에
1920×1080 그림에 위아래 여백으로 나온다.

---

## 2. 실제로 동작하는 것

### 2.1 도메인 / 시뮬레이션

| 기능 | 위치 | 상태 |
|---|---|---|
| 30Hz 고정 틱 | `module.gd::_process` | 동작 |
| 결정론 RNG (호출 순서 무관) | `systems/rng.gd` (PVE `ProceduralSeed`) | 동작 |
| 4속성 (다리/놀랍다/틀림/동그라미) · 상성 · 소프트캡 · 데미지 10단계 | `systems/attributes.gd` `combat.gd` | 동작 |
| 적 상태 기계 + **사거리 행동 전환** | `foe_machine.gd::update_behavior` | 동작. behaviors "2"(접근)로 오다 공격 사거리에 들면 "1"(cooldown→공격→recover) |
| **적끼리 겹치지 않음** | `foe_machine.gd::crowded` | 동작. 4칸 간격, 막히면 줄을 선다 |
| **플레이어 공격 주기** | `module.gd::_player_attack` | 동작. 무기 `attack.frames` 한 번, `attack.cast` 선딜 뒤 판정 (07 §2) |
| **플레이어 이동** | `module.gd::_walk_toward` | 동작. 목표가 사거리 밖이면 `player_walk_frames_per_unit`(3틱)마다 1칸 |
| **보스 참전** | `module.gd::_tick` 6단계 | 동작. 보스도 상태 기계·이동·공격·피격. ★3 이상 저수조가 끝난다 |
| 목표 선택 (개체 단위, 보스 포함) | `player_ai.gd::_pick_target` `target_key` | 동작 |
| 탐험 시작 위치 초기화 | `module.gd::_on_go` | 동작. 매 탐험 무대 중앙(0,0)에서 시작 |
| 허브 작업 (우물 긷기) | `encounter.gd` `module.gd::_tick_work` | 동작 (D-7) |
| 절차 생성 · 스타 밴드 · 보스 페이즈 · 세이브/로드 · 죽음 페널티 0 · 맵 해금 | 기존 | 동작 |

### 2.2 조작면

| 기능 | 위치 | 상태 |
|---|---|---|
| 로비: 지역 / 별 / 장비 / 탐험 | `presentation/lobby.gd` | 동작. 허브 장면 위 색판 2장 |
| 장비 → AI 정책 | `systems/gear_policy.gd` | 동작 |
| 결과 1줄과 함께 로비 복귀 (캔 재료 포함) | `module.gd::_check_end` | 동작 |

### 2.3 렌더

| 기능 | 위치 | 상태 |
|---|---|---|
| 논리 960×640 안전 영역, 16:9 면 논리 폭 1138 | `presentation/frame.gd` | 동작. **정수 배 아님**: 실제 픽셀 크기로 래스터화(번짐 없음) |
| 씬 팔레트 5색 authored (A1-a) | `content/palette/*.json` · `palette.gd` | 동작. 변형은 PVE `shifted`/`mix_roles` 만 |
| 하늘 16단 · 해 · 구름 | `presentation/sky.gd` | 동작 |
| 바닥 6단 · 길 폴리곤 · 자갈/꽃잎 면 · 근경 풀 흔들림 | `presentation/ground.gd` | 동작 (D-1) |
| 큰 구조물 좌표 폴리곤 3종 (A2-a) | `content/structure/*.json` · `structure.gd` · 원본 `content/_source/geometry.py` | 동작. 돔(저수조) · 아치 성당(허브) · 협곡(미배정) |
| 소품 + 세계 규칙 깨기 1개 (V9) | `content/prop/*.json` · `props.gd` · `content.gd::scene_errors` | 동작. 허브=뜬 표지판(중력), 저수조=쌍둥이 통(배치) |
| 로비 = 허브 장면 (D-5) | `lobby.gd::_draw_room` | 동작. 같은 팔레트·구조물·소품 |
| 개체: 좌표 실루엣 3종 + 4속성 변형 (A3-a) | `content/silhouette/*.json` · `critter.gd` | **동작하나 사용자 반려** (§0-1, §5) |
| 휘두르기 자세 | `view.gd::swing_lean` · `critter.gd::draw_gear` | 동작. 선딜에 뒤로, 판정 틱에 앞으로 |
| 렌더 자기 보고 | `presentation/draw_stats.gd` | 동작 |

---

## 3. 하지 않은 것 / 잘린 것

| 항목 | 이유 |
|---|---|
| **Rain World식 절차 애니메이션 개체** | 사용자 요청 직후 대화방 종료. **미착수.** §5 |
| Input Bubble · `Esc` 바인딩 | `app/` 수정 필요. D2 대기 |
| NPC · 대화 · 상점/제작 화면 | 미구현 |
| 전설 본문 · Stonescript · 어이름/지명/NPC 이름 | C2~C6 자료 없음. 사용자 제공 필요 |
| 12개 씬 | 지역 2개(허브·저수조)만 씬 완성. 협곡 구조물은 지역에 배정 안 됨(캡처 시험용) |
| 투사체 | 원거리 공격은 사거리 안 즉시 판정. 투사체를 만들지 않는다 |
| 계획 문서 02/03/06/13 갱신 (README §4-6) | 미착수 |

---

## 4. 결함

### 4.1 닫힌 것 (2026-09-27)

| # | 결함 | 처리 | 근거 |
|---|---|---|---|
| D-1 | 바닥 결이 선 대시 | 채운 타원(자갈·꽃잎)과 길 폴리곤으로 교체 | `ground.gd`, V4 strokes 0.00 |
| D-2 | 바닥 색이 탁한 올리브 | authored 팔레트 (A1) | `pal_dome_sand` 등 |
| D-3 | 구조물이 사각형 중첩 | 좌표 폴리곤 (A2) | 장면 테스트 A2 |
| D-4 | 개체가 막대+원 | 좌표 실루엣 (A3-a) — **그러나 사용자 반려**, §5 로 다시 연다 | 장면 테스트 A3 |
| D-5 | 씬·로비 팔레트가 다름 | 로비가 허브 팔레트·장면을 그린다 | 장면 테스트 D-5 |
| D-6 | 캡처 하네스 창 모드 크래시 | 하네스 재작성. 16장 exit 0 | `r1`~`r5` 캡처 |
| D-7 | 허브가 즉시 클리어되어 튕김 | 우물 긷기 작업이 끝나야 클리어 | 장면 테스트 D-7 |
| D-8 (신규) | 플레이어가 **매 틱** 때림(공격 주기 무시), 적은 접근 상태에서 공격으로 안 넘어감 | 무기 frames/cast 주기, 사거리 행동 전환, 적 간격 | core 테스트 D-8 ×2 |
| D-9 (신규) | 보스가 틱에 참여하지 않아 움직이지도 맞지도 않음 → ★3 이상 저수조가 끝나지 않음 | 6단계에 보스 포함, 목표 후보에 보스 포함, 플레이어 이동 | core 테스트 D-9 |

### 4.2 남은 것

| # | 내용 | 심각도 |
|---|---|---|
| U-1 | 개체 표현 사용자 반려 (§0-1) | **높음. 다음 작업** |
| U-2 | 밸런스 관찰 (2026-09-27 저녁, 틱 직접 호출 시뮬, 레벨 1 · 시작 장비, 시드 100~102): ★1 약 4초 HP 86 · ★6 약 100초 HP 79~81 · ★12 약 200초 HP 60~64, 9판 모두 클리어·사망 0. 너무 쉬워 보인다. 그러나 창 모드 캡처(★12, 약 1.7초)에서는 HP 33/100 이 나와 두 측정이 어긋난다 → 원인을 찾기 전까지 수치 조정 보류 | 중간 |
| U-3 | **닫힘.** 로비 글을 쉬운 말로 바꿨다("먼저 친다 · 가까운 적부터 · 늘 방패를 든다", "한 번에 1타 더", "강한 쪽 다리"). 테스트가 `_`·`=` 노출을 막는다 | — |
| U-4 | `test_p2_integer_scale_factors_960x640` 는 정수 배 시절 산수만 확인한다. 현재 `frame.gd` 와 무관 (V13 배치는 장면 테스트가 잰다) | 낮음 |
| U-5 | **닫힘.** 허브 우물 배치 scale 1.0 → 0.5 (플레이어 키와 비슷하게). 캡처 `r7_u3u5/` | — |

### 4.3 정본 반영 대기 (이번에 내가 정한 해석)

사용자 확인 전이다. 틀렸으면 되돌린다.

- A1-a · A2-a 추천안 채택 (사용자 /goal: "질문하지 말고 추천대로")
- 적 행동 전환 거리 = 그 적 공격 중 가장 긴 `reach`. 벗어남 판정은 +2 여유
- 적 개인 간격 4칸 (`PERSONAL_SPACE_SQ = 16`)
- 플레이어 걷기 3틱/칸 (`tuning/combat.json::player_walk_frames_per_unit`)
- 행동 수(`actions_per_turn`) = 한 번 휘두를 때 맞히는 횟수
- 탐험은 매번 무대 중앙에서 시작

---

## 5. Rain World식 절차 애니메이션 개체 — 리그 구현됨, 생김새 방향 대기

**2026-09-27 sub-kit05 구현 (`057fb23c`)**: `presentation/critter.gd` 를 아래 설계대로 교체했다. API 유지
(`view.gd`·`lobby.gd` 는 몸빛 두 줄만 바뀜). 몸빛은 검정+분홍 띠 대신 `foe_tones`/`player_tones`.
몸 설계 파일은 `sil_crawler`·`sil_strider`·`sil_hauler` (좌표 키 `body/mark/horns/eyes/limbs` 는 로더가 거부).
장면 테스트 A3 는 새 계약 7개(IK 뼈 길이 보존, 딛은 발은 땅 위, 교대 걸음, 꼬리 뒤처짐·따라잡기, 계열 구별, 플레이어 손)로 교체.
참고 자료: Rain World 개발자 인터뷰 "점들을 정해진 거리로 이어 뼈대를 만들고 그 위에 종이 인형을 그린다"
([Game Developer 2017, 보관본](https://web.archive.org/web/20230515012000/https:/www.gamedeveloper.com/design/crafting-the-complex-chaotic-ecosystem-of-i-rain-world-i-)),
GDC 2016 [Rain World Animation Process](https://gdcvault.com/play/1023475/Animation-Bootcamp-Rainworld-Animation).
자체 판정(캡처 `zoo/`, `r6_rig/`): 걸음·발 딛기·꼬리 끌림은 연속 프레임에서 보인다. 그러나 A는 평범한 도마뱀,
B는 올챙이·민달팽이, 보스(다리 11)는 다리 다발로 읽힌다 → 생김새 방향은 §0.2 Q1·Q4 답을 기다린다.

### 5.0 원래 인계 (참고)

사용자가 기대한 것: 몸이 물리로 끌려오고, 다리가 땅을 딛고 걸음을 스스로 내딛는 개체.
생김새는 "정형화된 초현실"(스토크 눈알, 검은 몸 + 분홍 띠, 거미 다리 다발)을 버린다.

확인한 사실:
- `core/procedural` 에 IK 나 "머리가 끌고 몸이 따라오는" 체인이 없다. `ProceduralShape` SOFT_CHAIN 은
  휴지 자세로 돌아가는 스프링이고, `ProceduralSquishRig` 도 휴지 자세 스프링 관절이다.
  → `core/` 는 호출만 하므로 **리그는 이 모듈 `presentation/` 안에 둔다.** 노이즈·시드는 PVE 를 계속 쓴다.
- 뷰·로비가 쓰는 `StoneStoryCritter` API 를 유지하면 `view.gd`·`lobby.gd` 수정이 작다:
  `build(sil, attrs, shape, seed, scale, flying)` `step(dt)` `draw(ci, origin, pal, stats, body, mark)`
  `walk` `hit` `facing` `look` `lean` `dying` `t` `size_px` `height()` `width()` `hover()` `hand_point()`
  `draw_gear()` `leg_count` `eye_count`.

제안 구조 (추천. 사용자 확인 전):
1. 몸 = 척추 노드 체인(베를레 적분 + 거리 제약). 머리 노드가 목표로 가고 나머지가 끌려온다. 꼬리는 더 느슨하다.
2. 다리 = 척추 노드에 붙은 2관절 IK. 발은 땅에 고정됐다가 이상 위치에서 멀어지면 호를 그리며 새로 딛는다.
   교대 걸음(짝 다리가 딛는 중이면 기다림). 앞다리 팔꿈치는 뒤로, 뒷다리 무릎은 앞으로.
3. 그리기 = 노드 반지름으로 만든 매끈한 몸통 튜브 + 등 밝은 면 + 배 어두운 면. 먼 쪽 다리 → 몸 → 가까운 쪽 다리 → 머리.
4. 4속성 매핑: 다리 = 다리 수(1이면 뛰기, 6+면 지네형) · 동그라미 = 몸 굵기/부드러움 ·
   틀림 = 비대칭(다리 길이 차, 절뚝임, 척추 꺾임) · 놀랍다 = 머리 움직임의 급함과 작은 눈 수.
5. 비행 개체는 다리 대신 늘어진 촉수 체인.
6. `content/silhouette/*.json` 은 좌표 대신 몸 설계 파라미터로 바꾸고 `content.gd` 검증과
   장면 테스트 A3 3개를 새 계약(IK 길이 보존, 딛은 발은 땅 위, 이동하면 꼬리가 뒤처짐)으로 교체한다.

정해야 할 것 (다음 세션이 사용자에게 번호 붙여 묻는다):
1. 플레이어(재에 묶인 자)도 같은 방식으로 바꾸는가 — 추천: 예
2. 몸 설계 3계열(게·각형·덩어리)을 남기는가, 완전 절차인가 — 추천: 계열은 남기되 시드로 비율을 흔든다

---

## 6. 코드를 실행하는 법

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'

# 임포트 (새 class_name 등록)
Start-Process $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait

# Kit 05 테스트 3개 (core · visual · scene)
Start-Process $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gselect=test_stone_story_rpg_ -gexit' -NoNewWindow -Wait

# 창 모드 캡처 (headless 는 더미 렌더러라 픽셀이 안 나온다)
Start-Process $GodotExe -ArgumentList '--path C:\projects\TINProject --script res://tests/capture_stone_story.gd -- --step=<이름>' -NoNewWindow -Wait
#   선택 인자: --scenes=lobby,hub,cistern,canyon  --res=1280x720,1920x1080,2560x1440,1920x1280
#   출력: %APPDATA%\Godot\app_userdata\TINProject\kit05_captures\<이름>\<장면>_<창>.png
#   로그: SCENE(살아 있는 적 수) · AUDIT(겹침·잘림) · SAVED_COUNT
```

Godot 은 `AGENTS.md` '병렬 세션 작업' 의 잠금 파일(`C:\projects\_locks\TINProject-godot.lock`)을 잡고 돌린다.

---

## 7. 파일 지도

```
modules/stone_story_rpg/
  module.gd                    GameModule. 틱 · 전투 루프 · 로비/탐험 전환 · 허브 작업
  domain/run_state.gd          상태 스키마 · 세이브 · gear_defs · 맵 해금
  systems/
    attributes.gd  combat.gd  gear_policy.gd  tuning.gd  core.gd  rng.gd
    foe_machine.gd             적 상태 기계 · 사거리 행동 전환 · 간격
    player_ai.gd               정책 실행 · 목표 선택(보스 포함)
    encounter.gd               절차 생성 · 허브 작업 항목
    content.gd                 JSON 로더 + 전수 검증 (팔레트·구조물·실루엣·소품 규칙)
  presentation/
    frame.gd                   논리 960×640(16:9 는 폭 1138) · 실제 픽셀 래스터
    view.gd                    탐험 화면 · 깊이 정렬 · HUD · 휘두르기 자세
    lobby.gd                   로비 = 허브 장면 + 색판
    palette.gd                 authored 5색 → 역할 색
    sky.gd  ground.gd          하늘 · 바닥 · 근경
    structure.gd  props.gd     구조물 · 소품 (좌표 레이어)
    ink.gd                     채움 · 빔 · 원 · 레이어 그리기 헬퍼
    critter.gd                 개체 ← §5 에서 교체 대상
    backdrop.gd                PVE 배경 흔들림 (근경 풀)
    draw_stats.gd              렌더 자기 보고
  content/                     JSON (palette · structure · silhouette · prop 신규) + _source/geometry.py
tests/core/
  test_stone_story_rpg_core.gd      52
  test_stone_story_rpg_visual.gd    15
  test_stone_story_rpg_scene.gd     15   A1 · A2 · A3 · V9 · D-5 · D-7 · V13
tests/capture_stone_story.gd        창 모드 캡처 + AUDIT
```

---

## 8. 소유 경로

```
plans/kits/05_STONE_STORY_RPG_KIT/**
docs/research/stone_story_rpg/**
modules/stone_story_rpg/**
tests/core/test_stone_story_rpg_*.gd
tests/capture_stone_story.gd
```

`core/procedural` 은 호출만 한다. 공용 문서·`app/`·`project.godot`·`tests/run_tests.gd` 는 고치지 않는다
(`AGENTS.md` '병렬 세션 작업'). 커밋은 `git add -- <내 경로>` → `git commit -m ... -- <내 경로>`.
