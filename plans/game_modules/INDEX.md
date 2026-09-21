# 게임형 모듈 시스템 계획 — 인덱스

작성: 2026-09-21

## 목적

이 폴더는 TINProject의 **게임형 모듈**을 저지능 구현 모델에게 맡기기 위한 상세 실행 계획이다.

핵심 원칙은 다음과 같다.

1. **콘텐츠보다 시스템을 먼저 만든다.**
   - 샘플 스테이지/사건/루프 하나를 만드는 것이 목표가 아니다.
   - 이후 30분~8시간 규모의 authored content를 얹을 수 있는 상태 모델, 데이터 형식, 입력, 저장, 편집·확장 지점, 테스트를 먼저 완성한다.
2. **처음부터 다시 만들지 않는다.**
   - 구현 전 공개 저장소·Godot Asset Library·현재 TIN 내부 구현을 조사한다.
   - 라이선스와 엔진 버전이 맞고 코드 품질이 충분하면 가져와서 TIN 계약 안에 가둔다.
   - 외부 프로젝트가 autoload/EventBus/전역 저장을 요구해도 TIN 전체를 거기에 맞추지 않는다.
3. **Adopt → Adapt → Build 순서**
   - 그대로 사용 가능한 subsystem은 vendoring/포팅.
   - 구조가 안 맞으면 필요한 subsystem만 추출.
   - 라이선스가 없거나 호환되지 않으면 코드 복사 없이 구조 참고만.
   - 마지막 남은 부분만 직접 구현.
4. **샘플 콘텐츠와 시스템을 분리한다.**
   - 샘플은 시스템 검증용이다.
   - 샘플 하나가 동작한다고 모듈 완료로 판정하지 않는다.
5. **게임형 모듈 하나는 하나의 게임이다.**
   - 30분~8시간 분량을 서로 독립된 미니게임/scenario로 채우지 않는다.
   - 콘텐츠가 늘어날수록 기존 플레이 문법·상태·도구·지식이 더 많이 재사용되어야 한다.
   - 일회성 변칙은 허용하지만 별도 규칙 설명/별도 런타임이 콘텐츠 대부분을 차지하면 실패다.
6. **TIN 계약을 유지한다.**
   - 다른 모듈 직접 참조 금지.
   - 승인 없는 autoload/EventBus 금지.
   - 입력은 ModuleContext 경유.
   - 저장은 모듈 소유 JSON-safe state.
   - AppRoot/core의 장르별 오염 금지.

## 계획 목록

| 파일 | 레퍼런스 | 핵심 시스템 난점 |
|---|---|---|
| 01_RULE_REWRITE.md | Baba Is You | 런타임 규칙 파싱·평가·충돌·undo |
| 02_DEDUCTION_CASEWORK.md | The Case of the Golden Idol | 증거 데이터 모델·추론 슬롯·부분 판정·사건 교체 |
| 03_PHYSICS_TOOLBOX.md | Mosa Lina | 물리 상호작용·도구 능력·오브젝트 조합·안전한 reset |
| 04_TIME_LOOP.md | In Stars and Time | loop-local/persistent 상태 분리·tick·reset·이벤트 재현 |
| 05_ODD_ROAD_ADVENTURE.md | West of Loathing | 하나의 지속적인 어드벤처 문법으로 지역·아이템·NPC·괴상한 사건을 대량 수용 |

## 구현 순서

네 계획은 서로 독립적이다. 동시에 구현해도 되지만 **같은 app/core/shared 파일을 병렬 수정하지 않는다.**

권장 순서는 시스템 리스크 기준으로:

1. RULE_REWRITE
2. PHYSICS_TOOLBOX
3. TIME_LOOP
4. DEDUCTION_CASEWORK
5. ODD_ROAD_ADVENTURE

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
