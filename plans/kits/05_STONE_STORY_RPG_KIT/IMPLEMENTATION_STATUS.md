# IMPLEMENTATION_STATUS — Kit 05

> 이 파일이 **사실의 원천**이다. 계획 문서보다 이 파일을 먼저 믿는다.
> 계획은 목표이고, 이 파일은 지금 실제로 되는 것과 안 되는 것을 적는다.

최종 갱신: 2026-09-27
브랜치: `kit/05-stone-story-rpg`

---

## 0. 다음 세션이 먼저 읽을 것

1. **개체(캐릭터) 표현은 사용자가 반려했다 (2026-09-27).**
   > "배경은 몰라도 캐릭터들이 너무 촌스럽지 않니. 내가 기대한건 rainworld식 procedural animation인데.
   > 개체들의 생김새가 정형화된 초현실주의인 점도 문제임"

   A3-a(좌표 실루엣 3종)는 폐기 대상이다. 다음 작업은 §5 의 **Rain World식 절차 애니메이션 개체**다.
   배경(하늘·바닥·구조물·소품)은 사용자가 판정을 보류했다("배경은 몰라도"). 손대지 않는다.
2. **푸시가 막혀 있다.** 로컬 커밋 `8dc7009e`(+ 이 문서 커밋)가 원격에 없다. 원격에 다른 컴퓨터가 올린
   커밋 4개(LDP, Kit 04 문서, 이 Kit 경로는 건드리지 않음)가 있어 fast-forward 가 안 된다.
   병렬 세션 규칙상 `pull`·`merge`·`rebase` 를 하지 않았다. **사용자가 합쳐 줘야 한다.**
3. 프로젝트 전역 회귀(`tests/run_tests.gd`, GUT 전체, 180프레임 부팅)는 **이번 라운드에 돌리지 않았다.**
   마지막 실측은 2026-09-26 의 644/644 다.

---

## 1. 검증 수치 (2026-09-27 실측)

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
| U-2 | ★12 저수조에서 약 1.5초 만에 HP 33/100. 밸런스 미조정 (관찰만) | 중간 |
| U-3 | 로비 글에 내부 키가 그대로 보인다 (`actions_per_turn_mod`, `open_with`, `attack`, `nearest`) | 중간 |
| U-4 | `test_p2_integer_scale_factors_960x640` 는 정수 배 시절 산수만 확인한다. 현재 `frame.gd` 와 무관 (V13 배치는 장면 테스트가 잰다) | 낮음 |
| U-5 | 허브에서 우물이 플레이어 키의 약 2.5배. 의도한 크기 규칙 깨기가 아니다 | 낮음 |

### 4.3 정본 반영 대기 (이번에 내가 정한 해석)

사용자 확인 전이다. 틀렸으면 되돌린다.

- A1-a · A2-a 추천안 채택 (사용자 /goal: "질문하지 말고 추천대로")
- 적 행동 전환 거리 = 그 적 공격 중 가장 긴 `reach`. 벗어남 판정은 +2 여유
- 적 개인 간격 4칸 (`PERSONAL_SPACE_SQ = 16`)
- 플레이어 걷기 3틱/칸 (`tuning/combat.json::player_walk_frames_per_unit`)
- 행동 수(`actions_per_turn`) = 한 번 휘두를 때 맞히는 횟수
- 탐험은 매번 무대 중앙에서 시작

---

## 5. 다음 작업 — Rain World식 절차 애니메이션 개체 (인계)

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
