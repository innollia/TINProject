# 12 — Save / Load / Reset / Death

---

## 1. 저장 형식

```gdscript
{
  "state_format": "ssr_run_v1",
  "save_version": 1,
  "tuning_signature": "<hash>",
  ...
}
```

- module state 는 이 Kit이 소유. 전역 봉투는 `SaveService`.
- `02` §10 의 검증 규칙을 따른다.
- `load_state()` 는 씬 트리 진입 **뒤**, `enter()` **전에** 적용된다.

### 1.1 마이그레이션

```gdscript
func migrate_save(old_version: int, data: Dictionary) -> Dictionary:
    if old_version >= 1:
        return data.duplicate(true)
    return {}     # 복구 불가 → 초기화
```

- Version 1이 최초. `old_version < 1` 이면 초기화.
- 복구 불가를 **빈 dict 가 아니라 명시적 실패**로 표현한다.
  `SaveService` 가 `{}` 를 받으면 진행 손실로 보고 초기 상태를 쓴다.

---

## 2. 저장 시점

| 시점 | 이유 |
|---|---|
| 지역 진입 완료 | 진행 손실 방지 |
| 전투 클리어 | 드랍 확정 |
| 돌 획득 | 되돌릴 수 없는 해금 |
| 제작 성공 | 재료 소모 확정 |
| 상점 구매 | 재고/가격 확정 |
| 전설 엔딩 | 보상 확정 |
| 레벨업 | 스탯 확정 |
| `Esc` → 세이브 | 명시적 |

- 자동 저장 **알림은 화면에 띄우지 않는다.** (`docs/PROJECT_DECISIONS.md` §8 금지)
- 저장은 조용히 일어난다.

---

## 3. 사망

```gdscript
func on_failure(state) -> void:
    if has_verb("loop") and state.has_loop_point:
        # stone_of_return 보유 + 루프 지점 존재 → 클리어 지점으로 복귀
        _rewind_to_loop_point(state)
    else:
        # 지역 시작부로 복귀. 인벤토리/진행은 유지
        _respawn_at_region_start(state)
```

### 3.1 유지되는 것

- `player.level`, `stats`, `xp`
- `inventory` 전체 (재료·인챈트·어펙스)
- `chests` 전체
- `currency`
- `world` 전체 (해금 지역, 전설 진행, 퀘스트 카운터)
- `stones` 전체

### 3.2 사라지는 것

- `encounter` 전체
- 해당 지역에서 **획득하지 못한 드랍**
- `run_seed` → **새로 뽑는다.** 같은 시드로 재도전할지 선택 가능하게 UI에서 고르지만,
  기본값은 새 시드다. (재도전은 의도적 선택이어야 한다)

### 3.3 사망 후 화면

- 사망 화면: `08` 참고가 아니라 `10` 에서 추가한 전용 화면.
  → 실제로는 `region_select` 로 돌아간다 + `title` 텍스트 영역에 1줄 사유.
- 별도 사망 화면을 만들지 않는다. (스크린샷 10의 해석이 유보다)
  → `17` Q11

### 3.4 `stone_of_return` 루프

- 루프 지점은 `encounter.cleared_at_tick` 이 아니라 **`world.loop_point[region_id]`** 에 저장.
- 클리어 시 기록. 사망 시 그 지점으로 복귀.
- 루프 중에는 `player.hp` 가 `min_hp` 까지만 회복. (`tuning.loop_min_hp`)
- 루프 무한 반복이 가능하다. **탈출 조건은 돌이 제거되지 않는 한 없다.**
  → 무한 플레이가 핵심 기능이다. `09` §3.6

---

## 4. 리셋

```gdscript
func reset() -> void:
    # 런 파라미터만 초기화
    state.run_seed = new_seed()
    state.star_level = state.last_star_level     # 마지막 선택 유지
    state.encounter = null
    state.respec_used = 0
    # player / world 는 유지
```

- **리셋 ≠ 새 게임.** 진행은 남는다.
- `stamina`, `hp` 는 만충.
- `chests` 는 유지. `chest_cap` 도 유지.
- 리셋 직후 아무 표시 없음. (`10` §4 `reset` 상태)

---

## 5. 검증 항목

| 항목 | 기대 |
|---|---|
| 전투 중 세이브 → 로드 | `encounter` 가 그 지점에서 재현. `tick` 일치 |
| 사망 상태로 세이브 → 로드 | 실패 상태로 재개. 즉시 사망 판정 안 함 |
| 튜닝 변경 후 로드 | 거부 + 초기화 + `reset_tuning` 반환 |
| 잘못된 `star_level` 로드 | 거부 + 초기화 + `reset_star` |
| `state_format` 불일치 | 거부 + 초기화 + `reset_format` |
| JSON 비호환 값 (NaN, Node) | 거부 |
| 저장 200회 반복 | 값 변화 없음 (drift 없음) |
| 루프 지점에서 사망 | 지점에서 재개. 지역 처음부터 아님 |
| 재배분 횟수 | 세이브/로드 후에도 유지 |

---

## 6. 저장을 저장하지 않는 것

`02` §9 표를 그대로 적용.

- 커서 위치 / 스크롤 / 점선 점멸
- 패널 열림 여부
- 스탯 스케일링 계산 결과
- 요구치 충족 여부
- 방어율
- `chest_cap`
- AI 목표 스택 / 개입 창 상태

- **개입 창 상태를 저장하지 않는 이유:** 창은 순간적 이벤트다.
  로드 직후 열려 있으면 플레이어가 "선택 안 한 것"이 승격된다.
  → 창은 재계산되지 않는다. 새로 발생해야 한다.
