# 게임형 모듈 계획 — 인덱스

UI 작업 계약: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). UI 변경이 있는 실행 계획은 화면별 계약과 검수 증거를 구체화한다. 후보/아이디어는 구현 계획 승격 시 적용한다.

공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`  
작업 절차·외부 베이스 감사·검증 규칙: `AGENTS.md`

이 폴더에는 기존 구현을 게임형 시스템으로 보완하는 **미완료 작업**과 사용자 요청으로 작성한 신규 게임형 계획을 둔다. 기존 구현의 실행 진입점은 [구현본 보완 계획](../implementation_improvements/INDEX.md), 최우선 판정은 [게임별 플레이 재설계](../implementation_improvements/03_GAMEPLAY_DEPTH.md)다.

## 계획 목록

| 파일 | 레퍼런스/방향 | 핵심 구현 난점 |
|---|---|---|
| 01_RULE_REWRITE.md | Baba Is You | 런타임 규칙 파싱·변환·MOVE·충돌 순서·undo; save v4, 두 번째 level UI route와 보드 시각화 미완료 |
| 02_DEDUCTION_CASEWORK.md | The Case of the Golden Idol | 증거 데이터 모델·추론 슬롯·부분 판정·사건 교체 |
| 03_PHYSICS_TOOLBOX.md | Mosa Lina | 물리 상호작용·도구 능력·오브젝트 조합·안전한 reset |
| 04_TIME_LOOP.md | In Stars and Time | loop-local/persistent 상태 분리·tick·reset·이벤트 재현 |
| 05_ODD_ROAD_ADVENTURE.md | West of Loathing 계열 | 지속적인 어드벤처 문법으로 지역·아이템·NPC·사건 증산 |
| [06_GHOST_PROCESSION.md](06_GHOST_PROCESSION.md) | The Sexy Brutale / The Count Lucanor | 사용자 유령 저택 메모 기반: 시간표·시선/은신·위장·행렬 탈출, 네 UI 연구 레퍼런스의 실제 화면 적용 |

## 구현 순서

서로 독립적인 계획이다. 같은 app/core/shared 파일을 병렬 수정하지 않는다.

현재 권장 순서:

1. RULE_REWRITE
2. DEDUCTION_CASEWORK
3. PHYSICS_TOOLBOX
4. TIME_LOOP
5. ODD_ROAD_ADVENTURE

사이클 4의 사용자 지정 구현 순서를 유지한다. 게임 내 등장 순서와는 별개다.

06은 2026-09-22 추가 요청에 따른 **신규 문서 계획**이다. 현재 코드/씬/등록 없음, 임시 ID와 구체 시스템은 AI 설계안이다. 기존 01~05 구현 순서를 바꾼 것으로 간주하지 않는다. 이불 반란 후보와 별개다.

## 상태

2026-09-23 코드 대조: 규칙·물리·루프는 작은 실행 프로토타입이 있고, 추리는 두 Resource 사건 번들과 ID 기반 3/4칸 판정표까지 추출했으며, 로드는 4지역 시스템 슬라이스가 있다. 아래 상세 계획의 큰 시스템과 authored content·시각 완료는 미완료다. 각 계획 첫 절에 현재 코드와 차이, 파일, 이관, 실패 경로를 적었다. 현재 테스트 통과를 게임성 완료로 간주하지 않는다.

구현이 완료되면:
1. 구현 사실과 검증 결과를 `HANDOVER.md`에 반영
2. 필요한 사용자 확정사항만 `PROJECT_DECISIONS.md`에 반영
3. 해당 완료 계획서는 삭제

완료 계획을 역사 문서처럼 `plans/`에 남기지 않는다.

## 시각 구현 게이트

모든 게임형 모듈 계획은 docs/VISUAL_DIRECTION.md를 필수 입력으로 사용한다.

각 계획에는:
- 1개 이상의 1차 상용 레퍼런스
- 실제로 참고할 화면/상태
- 1152×720 화면 구성
- at-icons 월드 아트 조립 방식
- UI icon 금지
- 최소 screenshot 검수 상태
가 들어 있어야 한다.

시스템 코드와 테스트만 완성하고 화면이 placeholder 상태면 해당 계획은 완료가 아니다.

이는 게임 내 등장 순서가 아니다.

## 모든 계획 공통 0단계 — 베이스 재조사

실제 구현 시작 시 계획에 적힌 후보만 믿지 말고 다시 조사한다.

최소 절차:

1. 같은 기능을 제공하는 공개 후보 **3개 이상** 찾기.
2. 각각 아래를 표로 기록:
   - repository
   - pinned commit/tag
   - license
   - Godot version
   - language
   - 핵심 subsystem
   - autoload/global dependency
   - 테스트 존재 여부
   - 가져올 파일
   - 버릴 파일
   - 포팅 난도
3. LICENSE가 없으면 **코드 복사 금지**. 동작/구조 참고만.
4. GPL 등 강한 copyleft는 TINProject의 배포 라이선스가 결정되기 전 기본적으로 직접 vendoring하지 않는다.
5. MIT/BSD/Apache/Unlicense/CC0 등 허용 라이선스도 저작권 고지·조건을 보존한다.
6. 후보가 현재 TIN 내부 시스템보다 못하면 외부 의존성을 추가하지 않는다.

## 완료 보고 형식

각 구현 작업 종료 시 반드시 아래를 남긴다.

- 채택한 외부 베이스와 pinned commit
- 라이선스 및 고지 위치
- 실제 복사/포팅한 파일 목록
- 구조만 참고한 저장소
- 새로 작성한 파일
- 샘플 콘텐츠 파일
- 테스트 수와 결과
- 저장 round-trip 결과
- reset/re-entry 결과
- 아직 직접 구현하지 않은 확장점
