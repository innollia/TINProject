# Stone Story RPG Kit — 조사 정본 인덱스

이 폴더는 **사용자가 직접 수행한 조사 자료의 정본 위치**다.
에이전트는 외부 조사를 하지 않는다. 필요한 자료는 여기 없는 상태로 남기고 사용자에게 요청한다.

관련 계획: [../../../plans/kits/05_STONE_STORY_RPG_KIT/README.md](../../../plans/kits/05_STONE_STORY_RPG_KIT/README.md)
사용자 확정 결정: [../../../PROJECT_DECISIONS.md](../../../PROJECT_DECISIONS.md) §21

## 0. 확정된 방향 (2026-09-26 사용자 지시)

| 축 | 값 |
|---|---|
| 목표 게임 | Stone Story RPG 유사 |
| Primary Reference | **Stone Story RPG 하나** |
| Sub Reference | Dark Souls 3 (특정 확장점에만) |
| 분위기·스토리·내용 | Ena: Dream BBQ |
| 비주얼 | **이미지 자산 0. ASCII 문자 렌더링 0. 절차적 애니메이션, 코드로만** |
| 분량 | Stone Story RPG 규모 |
| 조사 담당 | 사용자 전부 |

Primary Reference는 정확히 하나다. Dark Souls 3는 사용자가 명시한 확장점에만 쓴다.
Ena: Dream BBQ는 시스템 레퍼런스가 아니라 **분위기·스토리·내용의 source**다.

## 1. 폴더 계약

| 폴더 | 담당 | 규칙 |
|---|---|---|
| `00_user_dumps/` | 사용자가 그대로 붙여넣은 원문 | **수정 금지.** 받은 그대로 저장. 해석·요약·정리를 이 파일에 하지 않는다. 해석은 아래 전용 폴더로 분리한다. |
| `01_stone_story_rpg/` | Primary Reference 실증 | `docs/KIT_WORKFLOW.md` §2 상태별 증거. 상태 하나당 파일 하나. |
| `02_ena_dream_bbq/` | 분위기·스토리·내용 source | 분위기/톤/정서/세계관/콘텐츠 요소. TIN에 이식할 것과 이식 금지 대상을 명시. |
| `03_dark_souls_3/` | 서브 레퍼런스 | **어떤 시스템 확장점인지**를 먼저 확정. 확정 전에는 내용을 적지 않는다. |
| `04_procedural_visuals/` | 코드로만 그리는 비주얼 결정 | 이미지 자산 금지 조건, 절차 드로잉 계약, 화면 정보 구조. |

### 파일 규칙

- `00_user_dumps/` 파일명: `YYYY-MM-DD_seq_slug.md` (예: `2026-09-26_01_primary_reference_text.md`)
- 나머지 폴더 파일명: `<topic>_<subject>_<state>.md`
- 각 해석 문서 첫 줄에 `원본: 00_user_dumps/<파일명>` 을 기록한다.
- 원문이 1만자 이상이어도 쪼개지 않는다. 쪼개야 하면 원본을 먼저 저장하고 해석 문서에서만 분할한다.

## 2. 상태별 근거 — 현재 상태

구조 추출 결과: [01_stone_story_rpg/structure_extraction.md](01_stone_story_rpg/structure_extraction.md)
계획: [../../../plans/kits/05_STONE_STORY_RPG_KIT/README.md](../../../plans/kits/05_STONE_STORY_RPG_KIT/README.md)

### 01 Stone Story RPG — Primary Reference

사용자 제공 1차 자료(2026-09-26): 위키 본문 + 스크린샷 10장.
→ [00_user_dumps/2026-09-26_01_wiki_and_screenshots.md](00_user_dumps/2026-09-26_01_wiki_and_screenshots.md)

| # | 상태 | 근거 |
|---|---|---|
| S1 | 첫 플레이 화면 | **확보** — 스크린샷 1 |
| S2 | 평상시 필드 플레이 | **확보** — 스크린샷 5/6/9 + 적 상태표 + 사거리 표 |
| S3 | 전투 진입과 첫 턴 | **확보** — 스크린샷 5, 상태 기계 표 |
| S4 | 적을 변신하는 순간 | 해당 없음 — 이 게임에 존재하지 않는 기능. `아니오`로 종결 |
| S5 | 전투 목표 전환·파괴 조건 | **확보** — 페이즈 체인, 페이즈별 `foe_id` |
| S6 | 보스전 페이즈 전환 | **부분** — 유형 4종 확보. **HP 임계값 미수집** |
| S7 | 사망·리스폰 | **부분** — 스크린샷 10(해석 유보), 루프 돌 규칙 |
| S8 | 세이브/로드·이어하기 | **미수집** |
| S9 | 인벤토리·장비 | **확보** — 스크린샷 8/10, 인챈트 규칙, chest 상한 규칙 |
| S10 | 제작 | **확보** — 스크린샷 10, 4동사 전부, 레시피 40개 |
| S11 | 지역 이동·전환 | **확보** — 스크린샷 2/3, 지역 그래프 |
| S12 | 상점 | **확보** — 스크린샷 10, 가격/재고 표 |
| S13 | 컷신 | **확보** — 스크린샷 3/4, 스킵 불가 규칙 |
| S14 | 상시 HUD 범위 | **확보** — 모서리 4곳, 2~3 glyph, 박스 없음 |
| S15 | 상점/제작 화면 | **확보** — 스크린샷 10 |
| S16 | 전설(퀘스트) 구조 | **부분** — 2건 상세. 나머지 13건 미수집 |
| S17 | 소울스톤 10종 | **확보** — 전종 설명 |
| S18 | 속성 상성 행렬 | **미수집** — `poison ← ice` 만 확인 |
| S19 | 어펙스 기호 의미 | **미수집** — `aL` `dL` `D/A` `dX/ax` |
| S20 | Stonescript 문법 | **미수집** — Phase 2 대상 |

### 02 Ena: Dream BBQ — 분위기·스토리·내용

**전부 미수집.** 사용자 제공 예정.

| # | 항목 | 근거 |
|---|---|---|
| E1 | 실제 화면 캡처 | 미수집 |
| E2 | 정서·톤 | 미수집 |
| E3 | 가져올 스토리 기법 | 미수집 |
| E4 | 이식 금지 대상 | 미수집 |
| E5 | 코드 전용 비주얼로 재현 가능한 장면 | 미수집 |

Phase 4(콘텐츠) 전에 받으면 된다. Phase 1 화면 구현을 막지는 않는다.

### 03 Dark Souls 3 — Sub Reference

**Phase 1 범위 밖.** 확장점 선택을 아직 받지 않았다.
후보 목록은 [03_dark_souls_3/_README.md](03_dark_souls_3/_README.md)에 있다.

### 04 절차적 비주얼

**확정.** 계약 전문: [04_procedural_visuals/_README.md](04_procedural_visuals/_README.md)

| # | 항목 | 값 |
|---|---|---|
| P1 | 목표 해상도 | 16:9, 내부 버퍼 **960×540**, 정수 배만, nearest |
| P2 | 카메라 | 전투/필드 단일 고정. 스크린샷 5 기준 |
| P3 | 그릴 요소 | 월드 선화, HUD 4모서리, 대사 박스, 패널, 오닉스 프레임, 커서 |
| P4 | 밀도 기준 | 스크린샷 10장 (원본 보관) |
| P5 | 금지 | ASCII 문자, 이미지 파일, 채움 면, AA, 실수 배, 색 focus |

## 3. 이 방향이 깨는 기존 규칙

코드 작성 없이 **기록만 해 두는 상태**다.

1. **이미지 자산 파이프라인이 이 Kit에서 무효화된다.**
   `docs/IMAGE_ASSET_WORKFLOW.md`, `docs/VISUAL_DIRECTION.md`,
   `docs/art/PERSONAL_STYLE_CORE.md`, `docs/art/projects/**`, `docs/art/style_master/**`,
   `PROJECT_DECISIONS.md` §10의 IMG1–IMG25가 이 Kit에는 적용되지 않는다.
   적용 범위가 Kit 한정인지 프로젝트 전체인지는 **미확정**.

2. **완료 판정.**
   `docs/KIT_WORKFLOW.md` §3·§12의 "10분+ Reference Game"은 이 Kit에 적용하지 않는다.
   사용자가 명시한 **Stone Story 규모**가 완료 기준이다. → `05_STONE_STORY_RPG_KIT.md` §15

3. **Kit 슬롯.**
   2026-09-26 사용자가 **새 슬롯**을 만들기로 확정했다.
   `plans/kits/05_STONE_STORY_RPG_KIT.md`가 그 슬롯이다.
   `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/`와 `modules/top_down_action_rpg/`는
   건드리지 않고 보존한다. 소유권 경계는 `05` 계획서 §0.2 참조.

4. **작업 범위.**
   이 Kit은 자기 경로 안에서만 작업한다. `app/`, `core/`, `meta/`, 다른 모듈,
   다른 계획, 기존 테스트 파일은 수정하지 않는다. AppRoot 등록은 별도 승인 게이트다.
