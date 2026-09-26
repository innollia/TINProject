# Kit 05 — Stone Story RPG

> **2026-09-26 대개편.** 참조 분담이 바뀌었다.
> **비주얼 · 분위기 · 서사 = Ena: Dream BBQ** (1차 판은 Stone Story 스크린샷을 비주얼로 씁니다 — 오류)
> **시스템 · UX · 진행 = Stone Story RPG**
> **절차 생성 = core/procedural (PVE)**
> 사용자가 바로잡음: *"저런 검은 배경에 글씨 찍찍 아니야. 그런거 아니야. 기획부터 잘못됐어."*

**fact 의 원천은 [`IMPLEMENTATION_STATUS.md`](IMPLEMENTATION_STATUS.md) 다.** 계획보다 그 파일을 먼저 믿는다.
**미결정은 전부 [`17_OPEN_QUESTIONS.md`](17_OPEN_QUESTIONS.md) 에 있다.**

---

## 0. 게임 (한 문장)

> **로비에서 지역과 별과 장비를 골라 탐험을 보내면, AI가 그 장비가 만든 정책대로 싸운다.
> 돌아오면 통화와 해금이 늘어난다.**

플레이어는 직 조종하지 않는다. **장비가 유일한 간접 조종 수단**이다.

---

## 1. 문서

### 읽는 순서

| 순서 | 문서 | 상태 |
|---|---|---|
| 1 | [`IMPLEMENTATION_STATUS.md`](IMPLEMENTATION_STATUS.md) | **사실.** 실측 수치 · 결함 · 실행법 |
| 2 | [`17_OPEN_QUESTIONS.md`](17_OPEN_QUESTIONS.md) | **미결정 목록.** 여기부터 |

### 설계

| 문서 | 책임 | 상태 |
|---|---|---|
| [01_RENDER_PIPELINE.md](01_RENDER_PIPELINE.md) | 비주얼 계약 + V1~V15 검수 | **개정됨 (폐기 기록 포함)** |
| [04_COMBAT_STATS_DAMAGE.md](04_COMBAT_STATS_DAMAGE.md) | 4속성 · 단일 데미지 · 상성 · 장비 정책 | **개정됨** |
| [05_PLAYER_AI.md](05_PLAYER_AI.md) | 목표 스택 · 정책 실행 | **개정됨** |
| [10_SCREENS_PRESENTATION.md](10_SCREENS_PRESENTATION.md) | 로비 · 탐험 2화면 | **개정됨** |
| [11_INPUT.md](11_INPUT.md) | 6 action · 홀드 예외 · Input Bubble 미구현 | **개정됨** |
| [02_DOMAIN_STATE.md](02_DOMAIN_STATE.md) | 상태 스키마 | ⚠ 1차 판 (구 시스템 전제) |
| [03_SIMULATION.md](03_SIMULATION.md) | 틱 순서 · 상태 기계 | ⚠ 1차 판 |
| [06_STAR_LEVEL_AND_GENERATION.md](06_STAR_LEVEL_AND_GENERATION.md) | 스타 레벨 · 절차 생성 | ⚠ 1차 판 |
| [07_ITEMS_ABILITIES_CRAFTING.md](07_ITEMS_ABILITIES_CRAFTING.md) | 제작 4동사 | ⚠ 1차 판 |
| [08_ECONOMY_AND_SHOPS.md](08_ECONOMY_AND_SHOPS.md) | 화폐 · 상점 · 전설 | ⚠ 1차 판 |
| [09_STONES_VERBS.md](09_STONES_VERBS.md) | 돌 10 = 동사 10 | ⚠ 1차 판 |
| [12_SAVE_LOAD_RESET.md](12_SAVE_LOAD_RESET.md) | 세이브 | ⚠ 1차 판 |
| [13_CONTENT_SCHEMA.md](13_CONTENT_SCHEMA.md) | JSON 스키마 | ⚠ 1차 판 |
| [14_TESTS.md](14_TESTS.md) | 테스트 목록 | ⚠ 1차 판 |
| [15_MANUAL_PLAY.md](15_MANUAL_PLAY.md) | 수동 과제 | ⚠ 1차 판 |
| [16_ACCEPTANCE.md](16_ACCEPTANCE.md) | 완료 게이트 | ⚠ 1차 판 |
| [18_REFERENCE_MAPPING.md](18_REFERENCE_MAPPING.md) | 레퍼런스 매핑 | ⚠ 타인 작성 |
| [19_REFERENCE_GAME_FLOW.md](19_REFERENCE_GAME_FLOW.md) | Reference Game 흐름 | ⚠ 타인 작성 |

⚠ = **1차 판 그대로다.** 2026-09-26 설계 변경(4속성 · 로비 · 2화면)을 반영하지 않았다.
구현에 대조하지 말고 **CODE 를 정본으로 읽을 것.**

---

## 2. 확정된 것

### 2.1 소유 경로

```
plans/kits/05_STONE_STORY_RPG_KIT/**
docs/research/stone_story_rpg/**
modules/stone_story_rpg/**
tests/core/test_stone_story_rpg_*.gd
tests/capture_stone_story.gd
app/app_root.gd        (NORMAL_IDS 1줄 — 승인 완료)
```

금지: `core/` `meta/` 다른 모듈 다른 계획 기존 테스트 파일.

### 2.2 Procedural (PVE)

- **소유자가 W2. 동결 계약. 쓰기만 한다.** (`core/procedural/CONTRACT.md`)
- 쓰는 것: `Procedural.derive_seed` `make_palette` `make_noise` ·
  `ProceduralShape.build_from_spec` + `step` + `points` · `ProceduralBackdropDynamics` ·
  `ProceduralCanvas` · `ProceduralPalette` · `ProceduralSeed` · `ProceduralDeformField`
- **쓰지 않는 것**: `build_sprite` `render_frame` `make_rig` `make_backdrop`
  (전부 "wave 1 stub" — `push_error` 후 null)
- 공식 우회로: **shape 를 step 하고 points 를 읽는다.**
- **정수 스케일러는 PVE 에 없다.** `presentation/frame.gd` 가 직접 구현.

### 2.3 금지 (프로젝트 규칙)

- 이미지 파일 · ASCII 문자 렌더링
- 데미지 타입 5종 (물리/화염/번개/마력/어둠) — 초현실 세계관에서 불가능
- `core/` 수정 · `app/` 수정(승인 없이) · `git add .`
- 두 번째 사용처 전의 shared 추상화
- 전용 에디터

---

## 3. 현재 수치

| 항목 | 값 |
|---|---|
| 내부 버퍼 | 960 × 640 (1920×1280 = 정확히 2배) |
| 정수 배 | 720p 1 · 1080p 1 · 1440p 2 · 1920×1280 2 |
| 시뮬레이션 | 30Hz 고정 틱 |
| 결정론 | PVE `ProceduralSeed` + `derive_index` (호출 순서 무관) |
| 속성 | 4종 (다리 1–12 · 놀랍다/틀림/동그라미 0–10) |
| 상성 | 4-사이클 1개 (다리→틀림→동그라미→놀랍다) |
| 스탠스 | 가드(홀드) · 회피 · 슈퍼아머 |
| 장비 정책 키 | 14 (`policy_delta`) + hook 5 |
| 스크립트 언어 | **없다** (사용자 확정) |
| 테스트 | Kit 49 · 비주얼 계약 15 · 프로젝트 644 |

---

## 4. 다음 작업 (순서 고정)

1. **A1 씬 팔레트 authored 고정** — `17` §A1
2. **A2 구조물 기하를 명시적 폴리곤으로** — `17` §A2
3. **A3 개체 실루엣 3종 확정** — `17` §A3
4. 소품(prop) 시스템 — R6/R8 을 쓸 자리 (§3 미구현)
5. V13 4해상도 겹침 실측
6. `02`/`03`/`06`/`13` 계획 문서를 4속성 · 로비 구조에 맞춰 갱신

A1~A3 는 **17_OPEN_QUESTIONS.md** 가 추천을 싣고 있다. 추천대로 처리하거나
사용자에게 결정 받는다. **추측으로 착수하지 않는다.**

---

## 5. 완료 기준

`16_ACCEPTANCE.md` 는 1차 판이다 (전투 지역 수 · 보스 수 기준).
실제 기준은:

- [ ] V1~V15 통과 (15/15 — **하한선**)
- [ ] 사람이 캡처를 보고 "게임 같다"고 판단한다 (**상한선. V 통과로는 부족**)
- [ ] 12개 씬이 같은 품질로 나온다
- [ ] 지리 3곳 이상 · 보스 2기 · 전설 1개 완성
- [ ] 프로젝트 644 무회귀
- [ ] `03_dark_souls_3` 자료 2차분 반영
- [ ] `02_ena_dream_bbq` 2차분 반영
