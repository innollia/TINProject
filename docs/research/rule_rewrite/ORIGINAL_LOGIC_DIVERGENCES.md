# 원작 로직 대조 기록 — 2026-09-26

`modules/rule_rewriting/`의 규칙 실행 순서와 접촉 처리가 Baba Is You의 실제 동작과
어디에서 다른지 정리한다. 근거가 있는 항목만 코드를 고쳤고, 근거가 없는 항목은
추측으로 채우지 않았다.

## 1. 확인된 출처

- 속성 정의: 사용자가 제공한 Baba Is You 위키 본문(한국어 위키, CC BY-NC-SA 2.0 KR).
- 턴 실행 순서: 프로젝트가 이미 인용한 `PlasmaFlare/baba-modding-guide`의
  `references/order of operations.md`. 원작 내부 함수에 print를 넣어 실제로 측정한
  턴 실행 순서를 기록한 문서.

## 2. 원작과 일치함이 확인된 항목

| 항목 | 원작 정의 | 우리 구현 |
|---|---|---|
| FLOAT | "FLOAT이 아닌 개체와 상호작용을 하지 않는다. 단, FLOAT끼리는 상호작용을 한다. STOP, PUSH, PULL, SWAP은 FLOAT와 상관없이 영향을 준다" | `entities_interact`가 FLOAT 층 동일 여부만 비교. STOP/PUSH/PULL/SWAP은 별도 경로 |
| SINK | "자신과 같은 칸에 다른 개체가 존재하면 그 개체들을 모두 파괴하고 자신도 파괴된다" | 양쪽 제거 |
| HOT/MELT | "같은 칸에 존재하는 MELT 속성의 개체를 모두 파괴한다. 이때 ([SINK]와는 달리) HOT 속성의 개체는 사라지지 않는다" | melt 쪽만 제거, HOT은 생존 |
| OPEN/SHUT | "겹치거나 둘 중 하나가 다른 하나가 있는 칸으로 들어오려고 할 경우 둘 다 파괴된다. 충돌 속성을 무시한다" | `_can_open_shut_contact`가 이동 단계에서 PUSH/STOP 분기보다 먼저短路하여 진입을 허용하고, 접촉 패스에서 파괴 |
| WEAK | "자신과 같은 칸에 다른 개체가 존재하면 자신이 파괴된다. STOP과 DEFEAT보다 우선순위가 높다" | 무조건 자기 파괴. STOP 개체 위에서도 파괴됨 |
| WIN | "모든 속성 중에 우선순위가 가장 낮다. 파괴와 동시에 승리 조건을 달성하면 승리할 수 없다" | 제거 후 승리 판정. 제거된 YOU는 제외. YOU+WIN 동시 부여 시 즉시 승리 |
| DEFEAT/WIN 순서 | "DEFEAT는 WIN 다음으로 우선순위가 낮다" | 제거 후 YOU 생존 검사. 동일 효과 |
| SAFE | "파괴되는 속성에게 파괴되지 않는다. 다만 상호작용은 하며, 변화로 제거되는 것은 막지 않는다" | 제거 분기에서만 예외. `entities_interact`는 SAFE를 보지 않음 |
| MOVE | "YOU에 의한 이동이 끝난 이후에 연산이 시작되며, STOP에 막혀있으면 뒤를 바라본 뒤 MOVE가 걸린 횟수만큼 앞으로 이동한다" | `plan_move_auto`이 단계별로 이동, 막히면 방향 반전 |
| SHIFT | "MOVE에 의한 이동이 끝난 이후 ... 이동 판정 검사를 먼저 실시한 후 실제 이동이 이루어진다" | 판정 후 적용 순서 동일 |
| 문장 방향 | "문장은 왼쪽→오른쪽, 위쪽→아래쪽으로만 가능" | 파서가 동일 |
| 속성 주어 금지 | "동사 뒤에서만 기능하며 주어로 사용할 수는 없다" | 파서가 noun을 주어로 요구 |

## 3. 수정된 차이

### R1. 텍스트 PUSH 기본값 — 수정 완료

- 원작: "텍스트 타일은 ([PUSH] 속성 없이도) 기본적으로 밀 수 있으며",
  "텍스트들은 PUSH가 명시되어 있지 않아도 기본적으로 PUSH 속성을 가지고 있어,
  해당 속성을 지우려면 TEXT IS NOT PUSH 와 같은 문장이 필요하다"
- 이전 구현: 모든 보드 JSON이 단어 타일 19개마다 `"base_tags": ["PUSH"]`를
  손으로 선언. 총 399개 선언이 있었음.
- 수정: `RuleEvaluator._default_has_property`이 `is_word` 엔티티에 PUSH를 기본 부여.
  18개 보드 JSON에서 `base_tags: ["PUSH"]` 399개 제거.
- 판정: `tests/core` 362/362 통과(23,705 asserts), parity 1,138 asserts 통과.
  기존 데이터에서는 행동 변화 없음(모든 보드가 이미 PUSH를 선언했었음). 계약이
  원작과 일치하게 되었고 새 보드는 태그가 필요 없어짐.

## 4. 남은 차이

### R2. 파괴 속성 우선순위 — 미수정

- 원작이 명시한 순서: `WIN` < `DEFEAT` < `WEAK` (`[STOP]`은 비접촉 속성).
  원문 예: "YOU 개체가 DEFEAT 개체에 접촉하여 DEFEAT 개체를 파괴할 수 있는 경우
  그것이 먼저 적용되어 YOU 개체가 파괴되지 않는다."
- 현재 구현: `RuleEvaluator.resolve_contacts`가 SINK → HOT/MELT → OPEN/SHUT →
  WEAK → DEFEAT를 한 번의 쌍별 순회에서 순서 없이 전부 적용.
- 영향 범위: 한 개체가 파괴 관련 속성을 둘 이상 가질 때만 드러난다
  (예: YOU+WEAK인 개체가 DEFEAT 개체를 밟는 경우). ours는 양쪽 모두 제거하고,
  원작은 DEFEAT 개체가 먼저 사라져 YOU가 생존한다.
- 판정: 좁은 차이. `resolve_contacts`는 Kit의 가장 안전-critical한 함수이므로
  수정 시 회귀 검증 필요.

## 5. 잘못 보고했던 것 (자기 정정)

- 처음에 "FLOAT는 원작에서 LIQUID 기반이라 다르다"고 단정했다. 원문 확인 결과
  FLOAT는 상호작용 층 분리지 LIQUID 관련이 아니며, 우리 구현이 원작과 같았다.
  본편에 LIQUID 속성은 존재하지 않는다.
- 처음에 "OPEN/SHUT는 겹침만 처리하고 이동 시점 트리거가 없다"고 단정했다.
  `movement_solver._can_open_shut_contact`가 이미 이동 단계에서 이를 처리하고
  있었다. `resolve_contacts`만 읽고 판단한 결과다.

두 건 모두 부분 읽기에서 나온 단정이었고, systems를 건드리기 전에 원문 대조로
잡았다. 이 기록은 같은 실수를 반복하지 않기 위해 남긴다.

## 6. 판정기로 검증하는 방법

systems 수정이든 보드 수정이든 판정기(`tools/rule_judge/`)를 다시 돌려 각 보드의
`first_solution_depth`, 해 개수 곡선, 규칙 변경 횟수를 기록한다.
`tests/core/test_rule_judge_parity.gd`가 통과해야 systems 변경이 유효하다
(판정기가 실제 게임과 같은 결과를 내는지 확인하는 게이트).

## 7. 아직 하지 않은 것

- 16개 authored 보드의 `declared_rule_required`(초기 규칙 하나를 제거한 변형의
  풀림 여부) 미구현
- 3D 보드 14는 판정기 미모델링
- 11개 보드는 노드 예산 소진 상태이며, 예산 내 미발견은 불가능 증명이 아니다
- R2 미수정
