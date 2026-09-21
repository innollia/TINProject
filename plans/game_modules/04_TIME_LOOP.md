# 계획 04 — 시간루프 게임형 모듈

공통 설계 원칙: `docs/DESIGN_PHILOSOPHY.md`

레퍼런스: **In Stars and Time**  
목표: 스토리 한 루프를 쓰는 것이 아니라 **반복되는 시간 구간에서 무엇이 초기화되고 무엇이 남는지 명확히 통제하는 loop-state 시스템**을 만든다.

> 작업 ID 미정. 경로 `modules/<LOOP_MODULE_ID>/`.

---

## 0. 외부 베이스

### 채택 후보 A — threadsmind/godot-tick-system

- Godot **4.7**
- GDScript
- Unlicense
- commit: `2fb6b0e1f97596a3be137edcd4a12446691c8f53`
- 핵심 파일: `src/tick_system.gd`
- 장점: 현재 TIN Godot 4.7.2와 매우 가까움
- 원본 사용법은 autoload지만 핵심 구현은 단일 파일

### 채택 방식

코드를 사용할 경우:
- 라이선스 고지
- 원본 파일을 TIN 전체 autoload로 등록하지 않음
- 모듈 내부 child node 또는 RefCounted/Node component로 변환
- start/pause/reset lifecycle을 module enter/exit에 묶음

### 참고 전용 후보 B — laplante-sean/torn

- Godot 3 계열
- GPL-3.0
- commit: `58c6f58c81f97b7913e886b19692399dab4d43ce`
- `RecordablePlayer.gd`, `PlaybackPlayer.gd` 구조 존재
- 행동 기록→재생하는 looper puzzle proof-of-concept

TINProject의 배포 라이선스가 미정이므로 **코드 직접 복사 기본 금지**.
record/playback 구조를 이해하는 참고 자료로만 사용.

### 참고 전용 후보 C — looped-mansion

- Godot 4.4.1
- death reset + memory persistence를 표방
- 명시 LICENSE 확인되지 않음
- 코드 복사 금지, 시스템 분리 방식만 참고 가능

---

## 1. 루프 시스템 범위

In Stars and Time 레퍼런스에서 가져오는 핵심:

- 같은 구간 반복
- 일부 사실/메타 상태는 누적
- 대부분의 세계 상태는 리셋
- 반복 자체가 대화/상호작용 조건을 바꿈
- 플레이어가 아는 것과 캐릭터/세계가 기억하는 것을 분리 가능

전투 시스템 복제는 이 계획 범위가 아니다.

---

## 2. 상태를 4층으로 강제 분리

### A. Frame/transient
저장하지 않음.
- animation
- current velocity
- temporary tween
- hover

### B. Loop-local
루프 리셋 시 초기화.
- 문 열림
- NPC 현재 위치
- 이번 루프 대화 선택
- 이번 루프 획득 임시 키
- 현재 시각/tick
- local event flags

### C. Module-persistent
루프가 끝나도 이 모듈 안에서 유지.
- loop_count
- 발견한 지식 표현이 필요한 경우 해당 기록
- permanently seen conversation variants
- 반복에 의해 열린 meta option

### D. TIN-global
모듈이 직접 소유하지 않음.
- identity
- global records
- AppRoot profile

module code가 D를 직접 수정하지 않는다.

---

## 3. 파일 구조

```
modules/<LOOP_MODULE_ID>/
  module_manifest.tres
  entry.tscn
  module.gd

  domain/
    loop_definition.gd
    loop_state.gd
    persistent_state.gd
    event_definition.gd
    scheduled_event.gd
    condition.gd
    action.gd

  systems/
    loop_clock.gd
    loop_controller.gd
    event_scheduler.gd
    condition_evaluator.gd
    action_executor.gd
    state_partition.gd
    checkpoint_codec.gd

  actors/
    loop_actor.gd
    npc_actor.gd
    interactable.gd

  presentation/
    world_view.gd
    dialogue_view.gd
    clock_view.gd

  content/
    sample_loop_01.tres
    sample_loop_02.tres

tests/core/
  test_loop_clock.gd
  test_loop_partition.gd
  test_loop_scheduler.gd
  test_loop_reset.gd
  test_loop_save.gd
```

---

## 4. LoopClock

가능하면 godot-tick-system의 핵심을 모듈 로컬로 포팅.

필수 API:

```text
start()
pause()
resume()
reset()
advance_for_test(n_ticks)
current_tick() -> int
ticks_per_second
ticked(tick)
```

실제 runtime은 physics process 기반.
테스트에서는 `advance_for_test`로 wall clock 없이 진행 가능해야 함.

루프 콘텐츠 로직이 `Time.get_ticks_msec()`를 직접 읽지 못하게 한다.

---

## 5. LoopDefinition

데이터:

```text
loop_id
duration_ticks
initial_world_state
scheduled_events[]
actors[]
interactions[]
reset_transition
```

루프 길이와 사건 배치는 content data로 교체 가능.

---

## 6. EventScheduler

ScheduledEvent:

```text
id
tick
conditions[]
actions[]
once_per_loop
priority
```

같은 tick에 여러 event:
1. priority
2. stable id
순으로 실행.

event action 예:
- actor_move
- actor_state_set
- dialogue_enable
- object_state_set
- local_flag_set
- persistent_flag_set
- loop_end

Callable을 content resource에 저장하지 않는다.

---

## 7. ConditionEvaluator

최소 조건:

- loop_count compare
- loop flag
- persistent flag
- object state
- actor state
- interaction count
- time range

조건 평가가 scene node를 직접 읽지 않고 LoopState/PersistentState만 본다.

---

## 8. 루프 종료

종료 source:
- clock duration
- player death/failure
- explicit reset
- scripted event

LoopController 처리 순서:

1. 입력 block
2. 현재 loop 결과 집계
3. persistent mutation commit
4. loop-local state 폐기
5. initial state 재생성
6. loop_count 증가
7. scheduler reset
8. clock reset
9. actor/presentation rebuild
10. input enable

중간에 scene 전체를 무작정 reload하지 않는다.
module instance가 유지되어 persistent state를 명확히 관리하게 한다.

필요하면 하위 world scene만 재생성.

---

## 9. module save

schema v1:

```json
{
  "content_id":"sample_loop_01",
  "persistent":{
    "loop_count":4,
    "flags":{},
    "seen_events":[],
    "interaction_memory":{}
  },
  "current_loop":{
    "tick":230,
    "flags":{},
    "world_state":{},
    "actor_state":{}
  }
}
```

사용자가 모듈을 떠났다가 돌아오는 경우 current loop까지 복원 가능하게 한다.

루프 자체 reset과 **TIN module unload/re-entry를 혼동하지 않는다.**

---

## 10. knowledge와 flag 분리

지식 기반 플레이와 결합할 수 있지만 모든 플레이어 지식을 flag로 대체하지 않는다.

예:
- 플레이어가 특정 암호를 실제로 기억하면 fresh loop에서도 직접 입력 가능 → flag 불필요
- 캐릭터가 이전 루프의 대화를 명시적으로 기억해야 새 대사가 생김 → persistent flag 가능

계획/콘텐츠 작성 시 각 persistent flag에:
`왜 이것이 플레이어 지식만으로는 표현 불가능한가`
를 한 줄 기록.

---

## 11. 선택적 record/playback 확장

Torn류 행동 녹화는 1차 필수 아님.

추가할 경우 별도 subsystem:
- InputFrame
- Recording
- PlaybackActor

기록은 logical command 단위로:
```text
tick
action
payload
```

raw InputEvent 저장 금지.

이 기능은 실제 콘텐츠 요구가 생길 때 추가.

---

## 12. 샘플 루프

### sample 01
- 3~5분 equivalent tick
- actor 2
- timed events 5+
- interaction 4+
- loop-local 변화
- persistent 변화 1개
- death reset
- manual reset

### sample 02
- 다른 duration
- 같은 scheduler 사용
- loop_count 조건 분기
- event priority collision
- persistent flag 없이 플레이어 지식으로 건너뛸 수 있는 interaction 1개

샘플은 시스템 검증용.

---

## 13. 테스트

### clock
- exact ticks
- pause/resume
- reset
- test manual advance

### scheduler
- order
- same-tick priority
- conditions
- once-per-loop
- reset re-fire

### partition
- local reset
- persistent retained
- global untouched

### loop reset
- death
- timeout
- explicit
- 100 loops 반복 후 state leak 없음

### save
- mid-loop save/load
- between-loop save/load
- content stale state sanitize

### lifecycle
- enter/exit
- transition 중 tick 중지
- input disabled
- orphan timer/signal 없음

---

## 14. 완료 금지 조건

- 모든 상태를 flags Dictionary 하나에 몰아넣음
- loop reset을 전체 AppRoot reload로 구현
- TickSystem을 전역 autoload로 추가
- 대화 분기 때문에 timeline flag를 무제한 남발
- 테스트가 실제 시간을 기다림
- 루프마다 노드/신호가 누적
- GPL Torn 코드를 라이선스 검토 없이 복사
## 시각 구현 계약 — 2026-09-22

### 1차 레퍼런스
In Stars and Time의 실제 방 화면, 대화 화면, 반복 진입 장면.

참조:
- 같은 장소가 유지되면서 작은 차이가 강하게 읽히는 구성
- 대화 시 캐릭터와 텍스트의 시선 순서
- 루프 정보를 상시 HUD 숫자로 설명하지 않고 장면 변화와 문장으로 체감시키는 방식

### 화면 산출물
1. loop start
2. normal room
3. dialogue
4. persistent change가 있는 같은 방
5. death/reset 직전
6. loop restart 직후

### at-icons
- 캐릭터, 가구, 방 장식은 collage
- loop count, memory, state에 icon badge 금지
- 반복에서 바뀌는 핵심 소품은 silhouette/배치/색 변화로 구분

### 완료 스크린샷
같은 장소 loop A/B, dialogue, reset 전후를 1152×720로 나란히 검수한다.
