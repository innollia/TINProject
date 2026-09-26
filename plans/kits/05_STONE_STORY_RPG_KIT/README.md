# Kit 05 — Stone Story RPG

분할 계획 문서의 중앙. 여기서 시작한다.

| 문서 | 책임 | 상태 |
|---|---|---|
| [01_RENDER_PIPELINE.md](01_RENDER_PIPELINE.md) | 960×540 정수 스케일, 드로잉 규칙, 팔레트, 절차 텍스처 | 작성 |
| [02_DOMAIN_STATE.md](02_DOMAIN_STATE.md) | 전체 상태 스키마, JSON-safe 규칙, 전 단위 정의 | 작성 |
| [03_SIMULATION.md](03_SIMULATION.md) | 30Hz 틱, 처리 순서, 적 상태 기계, 투사체, 장애물 | 작성 |
| [04_COMBAT_STATS_DAMAGE.md](04_COMBAT_STATS_DAMAGE.md) | 스탯 9, 스케일링, 요구치, 데미지 타입 5, 상태 3, 어펙스, 방어, 튜닝 | 작성 |
| [05_PLAYER_AI.md](05_PLAYER_AI.md) | 자동 조종 목표 스택, 개입 창 3종, 빌드 판독 | 작성 |
| [06_STAR_LEVEL_AND_GENERATION.md](06_STAR_LEVEL_AND_GENERATION.md) | 스타 레벨, 게이트, 밴드, 절차 생성 결정론 | 작성 |
| [07_ITEMS_ABILITIES_CRAFTING.md](07_ITEMS_ABILITIES_CRAFTING.md) | 아이템, 강화, 어펙스, 제작 4동사, 인벤토리 상한 | 작성 |
| [08_ECONOMY_AND_SHOPS.md](08_ECONOMY_AND_SHOPS.md) | 화폐, 상점 재고/가격, 계절, 전설 보상 | 작성 |
| [09_STONES_VERBS.md](09_STONES_VERBS.md) | 소울스톤 10 = 동사 10, 해금 판정, 패시브 | 작성 |
| [10_SCREENS_PRESENTATION.md](10_SCREENS_PRESENTATION.md) | 화면 12종, 상태 8종, 좌표 레이아웃, focus 규칙 | 작성 |
| [11_INPUT.md](11_INPUT.md) | InputMap action, 키 집합, Input Bubble, 재배정 | 작성 |
| [12_SAVE_LOAD_RESET.md](12_SAVE_LOAD_RESET.md) | versioned JSON, 사망/루프, 리셋, 마이그레이션 | 작성 |
| [13_CONTENT_SCHEMA.md](13_CONTENT_SCHEMA.md) | authored JSON 필드 단위 정의, 검증 규칙, 금지 | 작성 |
| [14_TESTS.md](14_TESTS.md) | 자동 테스트 항목 전수, 결정론 테스트 | 작성 |
| [15_MANUAL_PLAY.md](15_MANUAL_PLAY.md) | 수동 플레이 과제 20개, 기록 양식 | 작성 |
| [16_ACCEPTANCE.md](16_ACCEPTANCE.md) | 완료 게이트 (Stone Story 규모) | 작성 |
| [17_OPEN_QUESTIONS.md](17_OPEN_QUESTIONS.md) | 미확정 목록, 구현 차단 단계 | 작성 |

조사 정본: [../../../docs/research/stone_story_rpg/README.md](../../../docs/research/stone_story_rpg/README.md)
구조 추출: [../../../docs/research/stone_story_rpg/01_stone_story_rpg/structure_extraction.md](../../../docs/research/stone_story_rpg/01_stone_story_rpg/structure_extraction.md)
DS3 추출: [../../../docs/research/stone_story_rpg/03_dark_souls_3/structure_extraction.md](../../../docs/research/stone_story_rpg/03_dark_souls_3/structure_extraction.md)
렌더 계약: [../../../docs/research/stone_story_rpg/04_procedural_visuals/_README.md](../../../docs/research/stone_story_rpg/04_procedural_visuals/_README.md)
사용자 결정: [../../../PROJECT_DECISIONS.md](../../../PROJECT_DECISIONS.md) §21

---

## 0. Kit 목적

TINProject 본편의 한 구간을 **자동 전투 + 절차 생성 + 제작 시스템**의
top-down 액션 RPG로 전환하기 위한 기반.

Primary Reference는 **Stone Story RPG 하나**, 시스템 보강 축은 **Dark Souls 3(부분)**.
분위기·스토리·내용의 source는 **Ena: Dream BBQ** (시스템 레퍼런스 아님).

## 1. 확정된 성질 3가지

1. **플레이어 캐릭터는 AI가 조종한다.** 플레이어는 개입만 한다.
2. **진행은 스탯이 아니라 동사의 해금이다.** 소울스톤 10개 = 새 동사 10개.
3. **스타 레벨이 런의 1급 축이다.** `run = (location_id, star_level, run_seed)`.

## 2. 소유권 (사용자 확정)

이 Kit이 소유하는 경로. **이 밖은 수정하지 않는다.**

```text
plans/kits/05_STONE_STORY_RPG_KIT/**
docs/research/stone_story_rpg/**
modules/stone_story_rpg/**
tests/core/test_stone_story_rpg_*.gd     (신규 파일만)
app/app_root.gd                          (NORMAL_IDS 등록 1줄만 — 승인 완료)
```

금지: `core/`, `meta/`, `modules/`의 다른 모듈, `tests/`의 기존 파일,
`plans/kits/`의 다른 계획, `docs/`의 다른 문서.

**AppRoot 등록은 완료됐다.** `modules/stone_story_rpg/` 골격과
`app/app_root.gd`의 `NORMAL_IDS` 등록이 끝났고 부팅 검증도 통과했다.
`game_library`는 `catalog`에서 자동으로 이 모듈을 picking한다 (별도 수정 없음).
`InputRouter`가 `<id>_left/right/up/down/confirm/cancel`을 자동 생성한다.

## 3. Phase 구분

| Phase | 범위 | 상태 |
|---|---|---|
| Phase 0a | AppRoot 등록 + 부팅 골격 | **완료** (스모크 exit 0) |
| Phase 0b | 렌더 파이프라인 (960×540 정수 스케일, ink 헬퍼) | **미착수** |
| Phase 1 | SSR 구조 ( combat / 생성 / 제작 / 상점 / 돌 / 전설 ) | **계획 완료, 구현 대기** |
| Phase 2 | Dark Souls 3 보강 (전투 심화, 스탯 빌드) | **자료 1/2 수신. 설계 반영됨** |
| Phase 3 | 세 해상도 검수 + 자동/수동 검증 | 대기 |
| Phase 4 | Ena 톤·스토리·콘텐츠 | **자료 1차 수신 (에세이 + 스크린샷 9장)** |

## 4. 구현 순서

| # | 단계 | 선행 문서 | 완료 조건 |
|---|---|---|---|
| 1 | 렌더 파이프라인 | 01 | 960×540 정수 스케일, 선/텍스트 드로잉, 3해상도 캡처 |
| 2 | 상태 + 틱 + 세이브 | 02, 03, 12 | 결정론, save round-trip |
| 3 | 스탯 + 데미지 | 04 | 요구치 페널티, 소프트캡, 5속성, 3상태 |
| 4 | 적 상태 기계 + 전투 | 03, 04 | 행동 전이표 전수, 투사체, 사망 |
| 5 | 보스 | 03 | 페이즈 체인, 적응형 저항, 컷씬 |
| 6 | PlayerAI | 05 | 무입력 진행, 개입 창 3종 |
| 7 | 스타 레벨 + 생성 | 06 | (region, star, seed) 재현 |
| 8 | 인벤토리/아이템/어펙스/제작 | 07 | 4동사, 어펙스 결정론 |
| 9 | 경제/상점 | 08 | 가격 증가, 재고, 계절 |
| 10 | 돌/동사 | 09 | 10 verbs 해금 판정 |
| 11 | 전설 | 08, 13 | 15개, 선택 + 다중 엔딩 |
| 12 | 콘텐츠 확장 | 13 | [16](16_ACCEPTANCE.md) 수량 게이트 |
| 13 | 검증 | 14, 15, 16 | 전부 통과 |

## 5. AGENTS.md 규칙에 대한 이 Kit의 예외 (사용자 확정)

`AGENTS.md` 와 `docs/KIT_WORKFLOW.md` §8 은 각 Kit 계획에
**이미지 자산의 생성·편집 명세(톤앤매너, 자산군 brief, Gold Standard)** 를 요구한다.

**이 Kit에서는 사용자 결정으로 그 규칙을 대체한다.**

| 항목 | 결정 |
|---|---|
| 이미지 자산 | **0개.** `modules/stone_story_rpg/` 아래 이미지 파일 없음 |
| GPT 이미지 생성/편집 | **호출하지 않는다** |
| ASCII 문자 렌더링 | **금지** |
| 절차 비주얼 | `01_RENDER_PIPELINE.md` 가 그 자체가 명세다. 별도 자산 brief 불필요 |
| 톤앤매너 | Phase 4. Ena 자료 1차 수신 (`02_ena_dream_bbq/`) |
| `docs/IMAGE_ASSET_WORKFLOW.md` | 이 Kit에 적용되지 않는다 |
| `docs/VISUAL_DIRECTION.md` §4, §6 | 이 Kit에 적용되지 않는다 |
| `PROJECT_DECISIONS.md` §10 (IMG1–IMG25) | 이 Kit에 적용되지 않는다 |

- 이것은 **예외**이므로 예외的范围을 여기 명시한다.
  프로젝트 전체가 아니라 **이 Kit 한정**이다. (범위 미확정 → `17` Q1)
- 렌더 명세는 자산 brief 를 대체한다. 절차 드로잉에는
  픽셀 크기·알파·피벗·레이어가 없기 때문이다.
  대신 `01` §2 드로잉 규칙, §3 팔레트, §4 절차 텍스처가 그 역할을 한다.

## 6. 금지 (모든 단계 공통)

- 계획에 없는 구현
- 기억으로 채운 레퍼런스 내용
- `17_OPEN_QUESTIONS.md`의 미확정 항목을 추정으로 채우기
- **ASCII 문자 렌더링**
- **이미지 파일 로드 / 이미지 생성**
- 앵티에일리어싱, 실수 배 스케일, 채움 면
- 스크린샷에 없는 상시 HUD 요소
- 색 변화만으로 focus 표현
- placeholder 사각형을 월드 오브젝트로 완료 처리
- content ID/문구/대사의 core script 하드코딩
- 전용 에디터를 완료조건으로 만들기
- 두 번째 사용처 전의 shared 추상화
- Retired Prototype 재사용
- 원작 지명/NPC/소울스톤명 사용
- `알아서`, `게임답게`, `레퍼런스 느낌으로`로 결정 대체
- 자동 테스트 통과만으로 완료 선언
- 소유권 밖 경로 수정
