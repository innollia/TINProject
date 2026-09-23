# 콘텐츠 증설 계획 — 인덱스

UI 작업 계약: [UI_WORKFLOW](../../docs/UI_WORKFLOW.md). UI 변경이 있는 실행 계획은 화면별 계약과 검수 증거를 구체화한다. 후보/아이디어는 구현 계획 승격 시 적용한다.

공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`  
작업 절차: `AGENTS.md`

이 폴더에는 **아직 구현하지 않은 콘텐츠 증설 작업과 아이디어 은행**만 둔다.

## 활성 계획

| 파일 | 대상 | 작업 |
|---|---|---|
| 01_EXISTING_MODULES.md | violet_case / paper_moon_clinic / quiet_locker 등 | 기존 모듈 authored content 증설 |
| 03_TEXTILE_REVOLT.md | 이불 반란 | 게임형 모듈 후보 구체화 |
| BACKLOG.md | 아이디어 은행 | 미배치 재료 보존 |

## 현재 우선순위

1. [게임별 플레이 재설계](../implementation_improvements/03_GAMEPLAY_DEPTH.md)의 게임성 검증. 사건/환자/물건 수 증가를 먼저 하지 않는다.
2. `paper_moon_clinic` 검사 상태 모델 보완 후 환자 증설
3. `quiet_locker` 재조사·관계 반응 보완 후 사물 증설
4. 다음 게임형 모듈은 `plans/game_modules/` 후보와 전체 아이디어 풀을 함께 보고 선택

구현 완료된 계획은 이 폴더에 보존하지 않고 삭제한다.

`violet_case` 3사건 증설은 구현됐다. 남은 Case 03 판정·이관·시각 검증은 [후속 작업 C0](../implementation_improvements/01_CONTENT_AND_CONTINUITY.md)로 진행한다. 기존 확장 소재는 보존하되 완료 작업을 재구현하지 않는다.

## 시각 기준

콘텐츠 증설은 텍스트 상호작용 수만 늘리는 작업이 아니다. 기존 모듈에 새 조사물·사건·오브젝트를 넣을 때도 docs/VISUAL_DIRECTION.md와 plans/visual_overhaul/INDEX.md를 따른다.

새 월드 오브젝트는 가능한 경우 res://addons/at-icons/를 원래 의미와 무관한 collage 재료로 재조립한다. UI에는 icon을 사용하지 않는다.
