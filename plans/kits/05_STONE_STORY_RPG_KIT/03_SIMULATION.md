# 03 — 시뮬레이션

유도 근거: Stone Story RPG 위키의 보행 표 2개가 독립적으로 30을 낸다.
`structure_extraction.md` §2.3. **30Hz는 유도값이며 사용자 확인 대상**(`17` Q4).

---

## 1. 시간

- **시뮬레이션: 고정 30Hz 정수 틱.** `delta` 가 아니라 `tick` 단위.
- 렌더: 디스플레이 주파수 무관. `accumulator` 로 틱을 쌓고 나머지는 버린다.
- `randf()` 금지. 모든 난수는 `xorshift32` 정수 시퀀스. → `01` §4.5
- 실수 초를 도메인에 저장하지 않는다. 초가 필요하면 프레임으로 표현.

### 1.1 루프

```gdscript
const TICK_HZ: int = 30
const MAX_CATCHUP: int = 5      # 프레임 급락 시 복구 상한

func _process(delta: float) -> void:
    _acc += delta
    var steps: int = 0
    while _acc >= 1.0 / float(TICK_HZ) and steps < MAX_CATCHUP:
        _acc -= 1.0 / float(TICK_HZ)
        _simulate_tick()
        steps += 1
    if steps >= MAX_CATCHUP:
        _acc = 0.0     # 너무 뒤처지면 버린다 (무한 복구 금지)
    _render()
```

`_render()` 는 `sim_state` 를 정수 내부 좌표로 매핑해 그린다.
`01` §2 규칙을 따른다.

---

## 2. 틱 처리 순서 (고정, 변경 금지)

```text
 1. tick += 1
 2. 상태 지속 감소 (statuses.frames) + 시간 배율(chill) 적용
 3. 버프/능력 지속 시간 감소
 4. PlayerAI 가 intent 결정
 5. 플레이어 행동 실행 (공격 / 교체 / 물약 / 주문 / 능력)
 6. 적 전행동: 정렬된 순서로 상태 기계 1스텝
 7. 투사체 이동 + 충돌 판정
 8. 데미지 판정 (스케일링 → 강화 → 어펙스 → 방어 → 스탠스)
 9. 사망 판정 + 보상 확정
10. 스폰/디스폰, chest 드랍
11. 보스 페이즈 전이 검사
12. 전투 종료 검사 (cleared / failed)
13. 위치 게이트 / 클리어 조건 검사
14. 상태 저장 필요 플래그 설정
```

- 순서를 바꾸면 결정론이 깨진다. **테스트가 순서를 고정한다.**
- 6번의 정렬 키: `ready_tick` → `foe_id` 문자열 → `spawn_index`.
- 7번의 투사체 정렬: `id` 문자열.
- 어느 단계도 딕셔너리 순회 순서에 의존하지 않는다.

---

## 3. 적 상태 기계

원작 `foe.state` / `foe.time` 구조를 그대로 쓴다.

### 3.1 상태 정의

```gdscript
# content/foe/foe_husk_scrapper.json
{
  "id": "foe_husk_scrapper",
  "states": {
    "cooldown":   { "frames": 0,  "next": ["slash", "sweep"] },
    "slash":      { "frames": 12, "next": ["recover"], "on_enter": "hit_forward" },
    "sweep":      { "frames": 16, "next": ["recover"], "on_enter": "hit_wide" },
    "recover":    { "frames": 20, "next": ["cooldown"] },
    "awaken":     { "frames": 60, "next": ["approach"] },
    "approach":   { "frames": 1,  "next": ["approach"] },
    "stagger":    { "frames": 22, "next": ["recover"], "forced": true },
  },
  "behaviors": {
    "1": { "default_state": "cooldown", "moves": false },
    "2": { "default_state": "approach", "moves": true,
           "walk_frames_per_unit": 3, "wake_distance": 25 }
  },
  "tags": ["humanoid", "melee"],
  "attacks": { ... },
  "defense": { ... },
  "resistances": { ... },
  "immunities": [],
  "poise": 30,
  "death_drops": [ ... ],
}
```

### 3.2 상태 전이 규칙

- `state_time` 1 증가.
- `state_time >= states[state_id].frames - 1` 이면 `next` 로 전이.
  (`frames == 0` 인 상태는 **전이만 즉시 하고 `state_time` 을 누적하지 않는다**)
- `forced: true` 인 상태(`stagger`)는 전이 조건과 무관하게 강제 진입하고,
  `states[state_id].frames` 만큼 유지 후 `next` 로 돌아간다.
- `on_enter` 는 전이 순간 1회만 실행한다. (프레임마다 중복 실행 금지)
- `next` 가 배열이면 `cycle_index % next.size()` 로 고른다. `cycle_index` 는 전이마다 증가.
- `next` 가 없으면 현재 상태에 머문다.
- `cooldown_after` 은 **공격 전용.** `states` 의 `frames` 와 별개다.
  `on_enter` 로 공격을 실행한 뒤 `state.cooldown = attack.cooldown_after` 로 설정하고,
  `cooldown > 0` 이면 상태 전이는 **공격으로 이어지는 전이만** 허용한다.
  `cooldown == 0` 이면 모든 전이가 허용된다.
  → 이 규칙이 없으면 `cooldown: 0` 상태에서 공격이 연쇄된다.
- `telegraph_frames` 는 `on_enter` **직전**에 시작한다.
  구현: `on_enter` 핸들러는 `telegraph` 를 `telegraph_frames` 만큼 먼저 소비한 뒤
  `hit_*` 를 실행한다. 즉 예고 구간과 판정 구간이 분리된다.

### 3.2A 초기 상태와 `awaken` 진입

- 스폰 시 `behavior` 로부터 초기 상태를 정한다.
  ```gdscript
  var beh := behaviors[str(behavior)]
  var init_state: String = "awaken" if beh.wake_distance > 0 else beh.default_state
  ```
- `wake_distance > 0` 이면 **항상 `awaken` 으로 시작**한다.
  → `awaken` 은 도달 불가능한 상태가 아니다. 스폰 규칙이 진입시킨다.
- `wake_distance == 0` 이면 즉시 `default_state`.
- 상태 전이표에 `awaken` 을列入할 필요가 없다. 스폰 규칙이 진입시킨다.

### 3.3 이동

```gdscript
if behaviors[str(behavior)].moves and state_id != "stagger":
    var per_unit: int = behaviors[str(behavior)].walk_frames_per_unit
    _move_accum += 1
    if _move_accum >= per_unit:
        _move_accum = 0
        pos = _step_toward_player(pos, 1)      # distance 1단위 정수 이동
```

- 1 틱 = 1 프레임. `walk_frames_per_unit` 프레임마다 1단위.
- 원작 값(Scout 3, Bomb Cart 15)을 **참조 범위로만** 쓴다.
  실제 값은 TIN가 정한다. `13_CONTENT_SCHEMA.md` §4.
- 이동 제약 태그: `slow`(per_unit 2배), `fixed_direction`(전진만),
  `static`(이동 없음).
  → 원작 Bomb Cart "can only move forward" 의 구조.

### 3.4 기상 조건

```gdscript
if state_id == "awaken":
    if dist <= behaviors[str(behavior)].wake_distance:
        state_id = "approach"; state_time = 0
```

- `wake_distance == 0` 이면 즉시 기상. (원작 Bomb Cart)
- `wake_distance` 이 크면 플레이어가 가까이 가야 일어난다. (원작 Scout 25)

### 3.5 공격 판정

`on_enter` 에서 호출되는 핸들러:

| 핸들러 | 동작 |
|---|---|
| `hit_forward` | 진행 방향 `reach` 거리 직선 1칸 판정 |
| `hit_wide` | 진행 방향 기준 좌우 각 45도, 거리 `reach` 판정 |
| `spawn_projectile` | `attacks.<id>.projectile` 생성 |
| `apply_status` | 자신에게 버프 |
| `telegraph` | 예고 표시만 (원작 charge) |

- 판정 순간 1회. 지속 판정이 아니다.
- `evadable` 은 투사체 데이터에 있다. `03` §4.

### 3.6 시간 배율 (chill)

```gdscript
var scale: float = 1.0
for s in statuses:
    if s.id in TIME_SCALE_STATUSES:       # "chill"
        scale = maxf(scale, s.magnitude)  # 예: 1.30
# 보정: 배율이 클수록 느려진다
if scale > 1.0:
    _slow_debt += (scale - 1.0) * state_time_speed   # 실제로는 state_time을 매 틴 1씩만 증가
```

결정: `chill` 은 **확률적 스킵**으로 구현한다.

```gdscript
# chill_frames_left > 0 이면
if rng(seed, tick) % 100 < 25:   # 25% 확률로 이 틱의 state_time 증가를 건너뛴다
    pass
else:
    state_time += 1
```

- 이산적이라 틱 결정론이 유지된다. 연속 배율은 비결정적이 되므로 쓰지 않는다.
- `rng()` 은 `04` §11.7 의 `rng.at(stream, index)` 다. 2인자가 아니라 스트림+인덱스.
- `chill_frames_left` 는 `FoeState.statuses` 안의 `{id: "chill", magnitude: 0.25}` 항목.
  별도 필드가 아니다.

---

## 4. 투사체

```gdscript
func step(p: ProjState, target_pos: Vector2i) -> void:
    if p.lifetime > 0:
        p.pos += p.vel                      # vel 은 Dictionary -> 로컬 int 로 풀어 쓴다
        p.lifetime -= 1
        if p.lifetime <= 0:
            p.dead = true                   # 수명 종료: 판정 없이 소멸
            return
    if _within(p.pos, p.reach, target_pos):
        p.dead = true
        _apply_damage(p)                    # 04 §4.1 파이프라인
        return
    if p.lifetime <= 0:
        p.dead = true                       # 수명 0 이고 미명중: 즉시 소멸
```

- `lifetime == 0` 은 **이동 없는 즉시 판정형.** 첫 틱에 판정하고 끝낸다.
  위 순서에서 수명 감소 분기를 건너뛰므로 판정이 반드시 일어난다.
- 이동은 **정수 distance 단위.** `pos` / `vel` 은 도메인에서 Dictionary 이므로
  함수 진입 시 `var px := p.pos["x"]` 로 int 로 풀고, 결과만 다시 넣는다.
- `evadable: false` 인 투사체는 회피 무시를 못 한다. (원작 Bomb Cart)
- 충돌 시 `status_build` 을 대상에게 축적. → `04` §11.4
  단, 투사체는 `status_build` 가 0 이므로 축적이 생기지 않는다.

---

## 5. 장애물

| kind | blocks_move | blocks_sight | 특징 |
|---|---|---|---|
| `pillar` | true | false | 기둥. 뒤로 숨을 수 있음 |
| `rubble` | true | true | 파편. 시야도 막음 |
| `pit` | true | false | 낙하 데미지. 지면이 없음 |
| `water` | true | false | 상태 축적 저하 |
| `gate` | true | true | `world.flags` 게이트 상태로 개방 |

- `blocks_sight` 는 **적의 타겟팅**에만 영향. 플레이어 시야는 카메라가 정한다.
- 원작: 11* 이상에서 "obstacles appearing between the player and the boss".
  → `06` §3 게이트.

---

## 6. 자동 전투 AI 의 스텝 위치

AI 는 4번(의도 결정)에서만 동작한다. AI 가 6번 이후에 직접 데미지를 넣지 않는다.

- AI 가 정하는 것: 스탠스(가드/회피/스탠스 없음), 사용할 손패, 사용할 주문,
  어느 타깃을 우선할지, 움직일지.
- AI 가 정하지 **않는** 것: 데미지 수치, 명중 여부. → `04` §4, §7.
- 이 분리가 "플레이어가 개입만 한다"는 Kit 정의를 지킨다.

---

## 7. 시뮬레이션 종료 조건

| 조건 | 다음 |
|---|---|
| 모든 적 사망 + 보스 없음 | `cleared` |
| 플레이어 hp <= 0 | `failed` |
| `Ouroboros` 보유 + 클리어 지점 도달 | 루프 진입 → `06` §6 |
| 전투 중 Esc | 일시정지. `state` 유지 |

`failed` 처리는 `12_SAVE_LOAD_RESET.md` §3.
