# 원작 로직 대조 기록 — 2026-09-26

**사용자 결정이 필요한 항목은 [미결 질문 목록](OPEN_QUESTIONS.md)에 있다.** 이 문서는 사실
기록이고, 결정은 그 문서에서 한다.

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

## 4. 수정된 차이

### R1. 텍스트 PUSH 기본값 — 수정 완료, 검증 통과

- 원작: "텍스트 타일은 ([PUSH] 속성 없이도) 기본적으로 밀 수 있으며",
  "텍스트들은 PUSH가 명시되어 있지 않아도 기본적으로 PUSH 속성을 가지고 있어,
  해당 속성을 지우려면 TEXT IS NOT PUSH 와 같은 문장이 필요하다"
- 이전 구현: 모든 보드 JSON이 단어 타일마다 `"base_tags": ["PUSH"]`를 손으로 선언.
  총 399개 선언이 있었음.
- 수정: `RuleEvaluator._default_has_property`이 `is_word` 엔티티에 PUSH를 기본 부여.
  18개 보드 JSON에서 `base_tags: ["PUSH"]` 399개 제거.
- 판정: `tests/core` 362/362 통과(23,705 asserts), parity 1,138 asserts 통과.
  기존 데이터에서 행동 변화 없음(모든 보드가 이미 PUSH를 선언했었음). 계약이 원작과
  일치하게 되었고 새 보드는 태그가 필요 없어짐.

### R2. 파괴 속성 우선순위 — 구현 완료, 미결 충돌 발생

- 원작이 명시한 적용 순서(높을수록 먼저): `WEAK` > `DEFEAT`, 그리고 `WIN`은 전체에서 최하위.
  원문 근거: "[WEAK]는 [STOP]과 [DEFEAT]보다 우선순위가 높다",
  "[DEFEAT]는 [WIN] 다음으로 우선순위가 낮다", 그리고
  "YOU 개체가 DEFEAT 개체에 접촉하여 DEFEAT 개체를 파괴할 수 있는 경우 그것이 먼저
  적용되어 YOU 개체가 파괴되지 않는다".
- 이전 구현: `RuleEvaluator.resolve_contacts`가 SINK → HOT/MELT → OPEN/SHUT → WEAK →
  DEFEAT를 한 번의 쌍별 순회에서 순서 없이 전부 적용.
- 수정: `resolve_contacts`를 3단계로 분리.
  - Stage A: SINK / HOT-MELT / OPEN-SHUT이 만난 쌍을 파괴. 이 단계에서는 이미 제거된
    개체도 participate한다. SINK는 "같은 칸의 다른 개체들을 모두 파괴"하므로, 쌍 처리로
    먼저 제거되었어도 나머지를 파괴해야 한다. 가드를 넣으면 이를 놓친다.
  - Stage B: WEAK가 자신과 상호작용하는 개체를 만나면 자기 파괴.
  - Stage C: DEFEAT가 같은 칸의 YOU를 파괴. 앞 단계에서 상대가 제거되었으면 적용되지
    않는다.
  - WIN은 마지막에 잔존 YOU만 대상으로 판정한다(기존과 동일).
- 판정: `test_rule_evaluator` 13/13 통과. 전체 `tests/core`는 352/362.

#### R2가 드러낸 기존 콘텐츠 결함: board 06

board 06에는 `VINE IS DEFEAT AND WEAK`가 있다. LARK(YOU)가 VINE에 닿으면:

- 이전 동작: 한 번의 순회에서 양쪽 모두 제거 → LARK 사망 → `MOTH HAS KEY`로 KEY 생성 →
  KEY가 SHUT+STOP인 GATE를 열음. 이것이 저작된 루트.
- R2 적용 후: `WEAK`가 먼저 발동해 VINE이 자기 자신을 파괴 → VINE 소멸 → `DEFEAT`의 대상이
  없어 LARK 생존 → KEY 미생성 → 문을 열 수 없음.

이는 원작의 실제 동작이다. `DEFEAT`와 `WEAK`을 함께 가진 개체는 접촉하면 자기가 파괴되며
플레이어를 defeat하지 않는다. 즉 **board 06은 원작이 아닌 파괴 우선순위를 전제로 저작되었다.**

실패하는 테스트 3건은 코드가 아니라 이 콘텐츠 문제를 가리킨다.
`test_stop_shut_gate_blocks_direct_route_and_key_opens_it_for_win`,
`test_has_spawn_survives_save_and_undo_restores_its_removal_as_one_intent`,
`test_solved_cue_enter_skips_and_undo_cancels_with_state_restored`(연쇄).

#### 미결: 세 선택지

1. **R2 유지 + board 06 재저작.** 원작 규칙을 지킨 상태로 보드를 다시 설계한다. 단
   "VINE을 피해 도는" 루트로는 LARK가 죽지 않으므로, `MOTH`를 먼저 태우는 순서나
   `MOTH HAS KEY`의 발동 조건 등 **보드 설계 자체의 변경**이 필요하다. 판정기로 재측정
   해야 한다. 콘텐츠 결정.
2. **R2 되돌림 + 문서화.** 일부러 원작 규칙을 안 지킨다고 명시하고 이유를 기록한다.
   테스트는 전부 green으로 돌아온다.
3. **R2 유지 + board 06을 캠페인에서 제외.** 검증 전용 격리.

**보드에 맞춰 테스트를 고쳐 통과시키는 선택지는 없다.** 그건 규칙이 아니라 숫자를 맞추는
작업이고, 이번 작업의 취지를 배반한다.

## 5. 잘못 보고했던 것 (자기 정정)

- 처음에 "FLOAT는 원작에서 LIQUID 기반이라 다르다"고 단정했다. 원문 확인 결과
  FLOAT는 상호작용 층 분리지 LIQUID 관련이 아니며, 우리 구현이 원작과 같았다.
  본편에 LIQUID 속성은 존재하지 않는다.
- 처음에 "OPEN/SHUT는 겹침만 처리하고 이동 시점 트리거가 없다"고 단정했다.
  `movement_solver._can_open_shut_contact`가 이미 이동 단계에서 이를 처리하고
  있었다. `resolve_contacts`만 읽고 판단한 결과다.

두 건 모두 부분 읽기에서 나온 단정이었고, systems를 건드리기 전에 원문 대조로
잡았다. 이 기록은 같은 실수를 반복하지 않기 위해 남긴다.

## 6. 판정선에 필요한 원작 데이터

`plans/kits/01_RULE_REWRITE_KIT.md`에 난이도 수치를 박으려면 원작 퍼즐의 수치가 기준이어야
한다. 그 데이터가 아직 없다. Babap Is You 본편의 레벨은 copyrighted이고 Kit §7은 원작 레벨
배치 복사를 금지한다(§7은 검증 목적 복사를 예외로 허용하지만, 완성 증거로 세지 않는다).

가능한 입력:

1. 사용자가 원작을 직접 플레이해 판정기에 넣을 수 있는 형태로 숫자를 옮긴다.
2. 사용자가 레벨 파일을 제공한다.
3. 좁힌 표본만으로 상대 분포를 잡는다. 근사가 불완전함을 명시해야 한다.

어느 경로든 판정기가 원본을 재현해야 하므로, 3번의 경우에도 `MAKE`/`WRITE`/`TELE`/`MORE`
등 미구현 어휘가 쓰인 레벨은 제외된다. 그 결과 비교 가능한 원본 표본이 실제 BiY 난이도
분포 전체를 대표하지는 못한다. 그래도 곡선의 **모양과 기울기** 비교에는 충분하다.

## 7. 아직 하지 않은 것

- 16개 authored 보드의 `declared_rule_required`(초기 규칙 하나를 제거한 변형의 풀림 여부)
  미구현
- 3D 보드 14는 판정기 미모델링
- 11개 보드는 노드 예산 소진 상태이며, 예산 내 미발견은 불가능 증명이 아니다
- R2에 대한 미결 선택 (위 §4)
- 판정선 수치를 `plans/kits/01_RULE_REWRITE_KIT.md`에 기록하는 일 (원본 데이터 대기)
