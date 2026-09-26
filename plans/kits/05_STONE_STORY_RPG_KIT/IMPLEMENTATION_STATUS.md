# IMPLEMENTATION_STATUS — Kit 05

> 이 파일이 **사실의 원천**이다. 계획 문서보다 이 파일을 먼저 믿는다.
> 계획은 목표이고, 이 파일은 지금 실제로 되는 것과 안 되는 것을 적는다.

최종 갱신: 2026-09-26
브랜치: `kit/05-stone-story-rpg`

---

## 1. 검증 수치 (이 시점 실측)

| 항목 | 결과 |
|---|---|
| Kit 05 테스트 (`test_stone_story_rpg_core.gd`) | **49/49** |
| 비주얼 계약 테스트 (`test_stone_story_rpg_visual.gd`) | **15/15** |
| 프로젝트 전역 `tests/run_tests.gd` | **644/644** |
| 헤드리스 부팅 스모크 | exit 0, `stone_story` 오류 0 |
| AppRoot 등록 | 완료. `stone_story_rpg` 선택 가능 |
| 이미지 에셋 | 0개 (전 경로 스캔 테스트) |
| ASCII 문자 렌더 | 0 (정적 검사 테스트) |
| 캡처 | 1280×720 / 1920×1080 / 2560×1440 / 1920×1280 |

### 비주얼 계약 실측값 (`DRAW_STATS`)

```
filled=1.000  flatblack=0.00  strokes=0.10  hues=4  grey=0.20
sky=12  ground=6  big=0.34  eyes=2
```

**주의: 이 숫자가 통과해도 화면이 좋다는 뜻이 아니다.** V1~V15 는
"빠지지 않았는가"를 재는 것이고 "예쁜가"를 재는 것이 아니다.
2026-09-26 실제로 V 전부 통과한 상태에서 사용자가 "허접"이라 지적한 전례가 있다.
→ V 통과는 **하한선**이다. 상한선이 아니다.

---

## 2. 실제로 동작하는 것

### 2.1 도메인 / 시뮬레이션

| 기능 | 위치 | 상태 |
|---|---|---|
| 30Hz 고정 틱 | `module.gd::_process` | 동작 |
| 결정론 RNG (호출 순서 무관) | `systems/rng.gd` (PVE `ProceduralSeed`) | 동작 |
| 역참조 RNG (hoist) | `StoneStoryRunState.equip` / `unequip` | 동작 |
| 4속성 (다리/놀랍다/틀림/동그라미) | `systems/attributes.gd` | 동작 |
| 놀랍다 = 크기 최대 상관 + 시드 미스터리 | `attributes.gd::surprise` | 동작 (분포 테스트 통과) |
| 4-사이클 상성 | `attributes.gd::affinity` | 동작 |
| 스탯 소프트캡 / 요구치 페널티 / 양손 | `systems/combat.gd` | 동작 |
| 단일 정수 데미지 파이프라인 10단계 | `combat.gd::damage_pre` | 동작 |
| 적 상태 기계 (`behavior` + `state_time`) | `systems/foe_machine.gd` | 동작 |
| 절차 생성 `(region, star, seed)` | `systems/encounter.gd` | 동작 |
| 스타 레벨 5밴드 / 게이트 | `content/tuning/*.json` | 동작 |
| 보스 페이즈 체인 | `module.gd::_check_phase` | 동작 |
| 세이브 / 로드 / 거부 | `domain/run_state.gd` | 동작 |
| 죽음 페널티 0 | `module.gd::_on_death` | 동작 (테스트) |
| 맵 해금 (탐험 보상) | `run_state.gd::grant_unlocks` | 동작 (테스트) |

### 2.2 조작면

| 기능 | 위치 | 상태 |
|---|---|---|
| 로비: 지역 / 별 / 장비 / 탐험 | `presentation/lobby.gd` | 동작 |
| 장비 → AI 정책 (유일한 간접 조종) | `systems/gear_policy.gd` | 동작 (테스트) |
| 장비 인스턴스 + 콘텐츠 정의 병합 | `run_state.gd::gear_defs` | 동작 |
| 탐험 중 장비 동결 | `module.gd::_pump_input` | 동작 (테스트) |
| 결과 1줄과 함께 로비 복귀 | `module.gd::_to_lobby` | 동작 |

### 2.3 렌더

| 기능 | 위치 | 상태 |
|---|---|---|
| 960×640 고정 버퍼 + 정수 배 | `presentation/frame.gd` | 동작 (1920×1280 = 정확히 2배) |
| `project.godot` 무수정 | 런타임 비율 계산 | 동작 |
| 하늘 그라데이션 / 구름 / 바닥 6단 | `view.gd::_draw_space` | 동작 |
| 큰 원경 구조물 3종 | `view.gd::_draw_far_structure` | **기하가 사각형. 부적합** |
| 개체 (부품별 다른 형태) | `view.gd::_draw_critter` | 동작하나 "선+원". 부적합 |
| 눈 (놀랍다에 비례해 1~4개) | `view.gd::_draw_eyes` | 동작 |
| 렌더 자기 보고 | `presentation/draw_stats.gd` | 동작 |

---

## 3. 하지 않은 것 / 잘린 것

| 항목 | 이유 |
|---|---|
| Input Bubble | `app/` 수정 필요. D2 대기 |
| `Esc` 바인딩 | `app_root` 가 `KEY_X` 만 바인딩. 이 모듈은 우회 불가 |
| NPC · 대화 · 선택지 | 미구현. R1~R12 시각 규칙만 있음 |
| 상점 · 제작 UI 실행 | 데이터만 있고 화면 없음 |
| 전설 15개 | 스키마만. 본문 미수집 (C2) |
| 소품 (초현실 규칙 파괴) | 미구현. R9~R12 규칙만 있음 |
| 스크립트언어 | 사용자가 폐기 ("우리는 스크립트 없어") |
| Stonescript | C3 미수집 |
| 오프라인 진행 | Phase 1 범위 밖 |
| 12개 씬 | 지리 12개 데이터만. 씬 1개도 통과 안 됨 |

---

## 4. 알려진 결함 (숨기지 않는다)

| # | 결함 | 위치 | 심각도 |
|---|---|---|---|
| D-1 | **바닥 결이 선 대시** — 면이 아니라 선. 계약 §4.2 위반 | `view.gd::_draw_space` 4번 | 중간 |
| D-2 | **바닥 색이 탁한 올리브** — Ena 톤과 거리 멀다 | 팔레트 역할 | 높음 |
| D-3 | **구조물이 사각형 중첩** — 형태가 아님 | `_draw_far_structure` dome | 높음 |
| D-4 | **개체가 막대+원** — 실루엣이 없음 | `_draw_critter` | 높음 |
| D-5 | 씬 팔레트와 로비 팔레트가 다름 — 화면 톤이 안 통함 | `view.gd` / `lobby.gd` 별개 `ProceduralPalette` | 높음 |
| D-6 | 캡처 하네스가 창 모드에서 크래시할 수 있음 (exit `-1073741819`) | `tests/capture_stone_story.gd` | 낮음 |
| D-7 | 허브 지역은 적이 없어 즉시 "클리어"되어 로비로 튕긴다 | `encounter.gd` (hub `spawn_cap` 0) | 중간 |

---

## 5. 코드를 실행하는 법

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'

# 임포트 (새 class_name 등록)
Start-Process $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait

# Kit 05 테스트
Start-Process $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gselect=test_stone_story_rpg_core -gexit' -NoNewWindow -Wait
Start-Process $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gselect=test_stone_story_rpg_visual -gexit' -NoNewWindow -Wait

# 프로젝트 회귀
Start-Process $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/run_tests.gd' -NoNewWindow -Wait

# 캡처 (창 모드. headless 는 더미 렌더러라 픽셀이 안 나온다)
Start-Process $GodotExe -ArgumentList '--path C:\projects\TINProject --script res://tests/capture_stone_story.gd --resolution 1280x720' -NoNewWindow -Wait
```

캡처 출력: `%TEMP%\opencode\ssr_lobby\`

---

## 6. 파일 지도

```
modules/stone_story_rpg/
  module.gd                    GameModule. 틱·배선·로비/탐험 전환
  module_manifest.tres
  entry.tscn
  domain/run_state.gd          상태 스키마 · 세이브 · gear_defs · 맵 해금
  systems/
    core.gd                    스트림 팩토리 + 소프트캡
    rng.gd                     StoneStoryRng (PVE ProceduralSeed 래퍼)
    tuning.gd                  튜닝 로더 + 파생값 공식
    attributes.gd              ★ 4속성 · 놀랍다 공식 · 상성 · 행동 도출
    gear_policy.gd             ★ 장비 → AI 정책
    combat.gd                  데미지 파이프라인 · 상태 축적
    foe_machine.gd             적 상태 기계 · 투사체
    encounter.gd               절차 생성
    content.gd                 JSON 로더 + 전수 검증
    player_ai.gd               정책 실행 (데미지 안 만든다)
  presentation/
    frame.gd                   960×640 + 정수 배
    draw_stats.gd              ★ 렌더 자기 보고 (계약 검증 근거)
    view.gd                    월드 뷰  ← 결함 D-1~D-4
    critter.gd                 4속성 → 정규 형상 스펙
    backdrop.gd                3-밀도 대역
    palette.gd                 PVE 역할 → 색
    lobby.gd                   ★ 로비 (유일한 조작면)
  content/                     JSON 50개
  PRESENCE.md                  삭제 감시 센티널

tests/core/
  test_stone_story_rpg_core.gd      49
  test_stone_story_rpg_visual.gd    15
capture_stone_story.gd              캡처 하네스
```

★ = 핵심. 나머지는 이걸支撑한다.

---

## 7. 소유 경로

이 Kit 이 **소유**한다. 밖은 건드리지 않는다.

```
plans/kits/05_STONE_STORY_RPG_KIT/**
docs/research/stone_story_rpg/**
modules/stone_story_rpg/**
tests/core/test_stone_story_rpg_*.gd
tests/capture_stone_story.gd
app/app_root.gd            (NORMAL_IDS 1줄 — 승인 완료)
```

금지: `core/` `meta/` 다른 모듈 다른 계획 기존 테스트 파일.

## 8. 동시 작업 주의

이 저장소에는 **다른 작업자가 있다.** 2026-09-26 기준 다음 파일을 손대고 있었다:
`tests/core/test_rule_*.gd` · `tests/core/test_top_down_action_rpg_*.gd` ·
`modules/rule_rewriting/` · `modules/top_down_action_rpg/` · `plans/kits/01,03,04_*` ·
`docs/art/**` · `docs/golden_idol_story/**`

그때문에:
- 전체 GUT 의 실패 5개는 **내 것이 아니다** (Kit 04 콘텐츠가 진행 중).
- 한 번 `modules/stone_story_rpg/` 전체와 테스트 파일이 **사라졌다** (원인 미확정, 복구 완료).
  `PRESENCE.md` 가 있으면 확인하고, 없으면 즉시 복구하복구한다.
- 커밋은 `git add -- <내 경로>` 로 **경로 지정**. `git add .` 금지 (남의 작업을 삼킨다).
