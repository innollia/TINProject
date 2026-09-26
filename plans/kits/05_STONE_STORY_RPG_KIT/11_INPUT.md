# 11 — Input

물리 키를 domain에 하드코딩하지 않는다. InputMap action + `ModuleContext` 만 쓴다.

---

## 1. Action 목록

`app/app_root.gd` 의 `_configure_module_actions()` 가 `NORMAL_IDS` 에서
`<id>_left/right/up/down/confirm/cancel` 을 자동 생성한다.
추가 action 은 `app/` 수정이 필요하므로 **기본 6개만 쓴다.**

| action | 기본 키 | 용도 |
|---|---|---|
| `stone_story_rpg_left` | `←` | 커서 왼쪽 / 목록 위 |
| `stone_story_rpg_right` | `→` | 커서 오른쪽 / 목록 아래 |
| `stone_story_rpg_up` | `↑` | 위 / **가드 홀드** (§3A) |
| `stone_story_rpg_down` | `↓` | 아래 / 제작대 (§3B) |
| `stone_story_rpg_confirm` | `Z` | 확정 / 진행 |
| `stone_story_rpg_cancel` | `X` | 취소 / 닫기 |

### 1.0 `Esc` 는 이 Kit에서 동작하지 않는다

`app/app_root.gd` 의 `_configure_module_actions()` 가 `<id>_cancel` 에 `KEY_X` 만 바인딩한다.
`Esc` 는 `meta_cancel` 이고, 이 모듈은 ModuleContext 허용 action 밖을 쓰지 못한다.

→ **`Esc` 바인딩 추가는 `app/` 수정이므로 승인 대기다.** `17` A-03.
승인 전까지 `Esc` 를 지원한다고 문서화하지 않는다.
승인되면 이 절과 `15` F-07 을 함께 고친다.

### 1.1 확장 action (Phase 1에 넣지 않음)

`inventory`, `workbench`, `status`, `jump` 등은 키가 더 필요하다.
하지만 `app/` 수정은 금지 범위다.

**결정: 확장 action 은 `confirm`/`cancel` 조합으로 표현한다.**

```text
confirm + up     = 상단 섹션
confirm + down   = 하단 섹션
cancel  반복     = 닫기
```

- 이 방식은 키를 외우게 한다. **Input Bubble 로 배운 키만으로 전 기능 접근 가능해야 한다.**
- 실제 전 functionality가 이 조합으로 도달되는지 `15_MANUAL_PLAY.md` §8에서 검증한다.
- 키를 늘리고 싶어지면 그때 `app/` 수정 승인을 요청한다. `17` Q9.

---

## 2. 키 집합 (Input Bubble 대상)

이 Kit이 요구하는 물리 키:

```text
← ↑ → ↓   Z   X
```

8개. 실제 버블 셀에 물리 키 1개씩 고정 배치.

### 2.1 버블 격자

```text
가상 격자   8열 x 2행
셀 크기     80 x 80  (내부 픽셀)
배치        물리 키코드 순서가 아니라 "가장 많이 쓰는 키" 순으로 왼쪽부터
            ↑ ← ↓ →   Z   X   Esc
```

- `Esc` 는 버블에 넣지 않는다. 취소 키를 학습시키면 안 된다.
  → 7개: `↑ ← ↓ → Z X` + 여분 1칸.
- 버블 그리드는 8열. 남는 칸은 비운다.

### 2.2 상태

| 상태 | 표현 |
|---|---|
| `intact` | 온전한 원(1px ring) |
| `popped` | 원 + 중앙 2px 십자 |
| `rising` | 아래에서 올라오는 중. y 오프셋 보간 |
| `restoring` | 채워지는 중. radius 보간 |

- 이동은 정수 프레임 보간. 실수 y.
  → `01` §2.1 정수 규칙을 지키되, 버블은 화면 전환 연출이므로 예외 허용 범위를
  `transition_layer` 로 분리한다. **월드 좌표에는 적용하지 않는다.**

### 2.3 흐름

```text
Phase 1 진입 시 (첫 진입)
  → rising 7개, 순차 3프레임 간격
  → intact 정착
  → 플레이어가 실제 키를 누르면 해당 버블이 popped

Phase 2 진입 시 (키 집합 동일)
  → 모든 버블 restoring → intact
  → 1개라도 popped 면 해당 키를 다시 눌러야 함
```

- 키 집합이 같으면 `restoring` 만 한다. 새 버블 없음.
- 키 집합이 달라지면 새 키는 `rising`, 필요 없는 키는 `popped` 잔존.
  → Phase 2 에서 실제 키 집합이 바뀔 때 사용.

### 2.4 버블 트리거

- `docs/KIT_WORKFLOW.md` §7 에 따라 **App/전환층**이 소유한다.
- 이 모듈은 `requested(&"input_bubble", {"keys": [...]})` 로 요청만 보낸다.
- `AppRoot` 구현은 `app/` 수정이므로 **별도 승인 필요.** `17` Q10.
- **Phase 1에서 버블 구현하지 않는다.** 키 힌트를 대체하는 다른 수단도 넣지 않는다.
  → 사용자가 키를 모르면 키 목록을 `status` 화면에서 볼 수 있게 한다.
  이건 튜토리얼 텍스트가 아니라 도구 화면이다. `10` §5.11

---

## 3. 입력 처리 규칙

```gdscript
func _process(_delta: float) -> void:
    if context == null or not context.input_enabled:
        return
```

- 기본은 **전 action 엣지 트리거.** `is_action_just_pressed` 만 쓴다.
- 입력 차단 중에는 큐에 넣지 않는다. 드롭한다.
- 전이 중 입력은 **버린다.** 나중에 실행되지 않는다.
- `context.is_action_pressed()` 가 아니라 ModuleContext 허용 action 만 쓴다.
- 버튼 callback 도 `context.input_enabled` 를 확인한다.

### 3A. 유일한 홀드 예외: `guard`

`guard` 는 **스탠스**이므로 홀드여야 한다. 예외는 하나뿐이고, 명시적으로 선언한다.

```gdscript
func _guard_held() -> bool:
    return context != null and context.input_enabled \
            and context.is_action_pressed(&"stone_story_rpg_up")
```

- 어느 action 을 홀드로 쓸지는 `04` §11.2 와 같다. 기본 `up`.
- 홀드 중에도 **반복 발화하지 않는다.** 스탠스 유지만 한다.
- 홀드 해제 즉시 해제. 쿨다운 없음.
- 기력이 0 이면 홀드 중이어도 강제 해제. → `04` §7.3
- 나머지 5개 action 은 전부 엣지 트리거.

### 3B. 패널 여는 입력 (6개 패널 → 3개 패턴)

`10` §1 의 패널 6개는 키를 늘리지 않고 3개 패턴으로 도달한다.

| 패널 | 패턴 | 비고 |
|---|---|---|
| `inventory` | `confirm` | 전투 중에도 열림 |
| `workbench` | `confirm` + `down` | 제작대 |
| `status` | `confirm` + `up` | 스탯 배분 |
| `shop` | `cancel` (지역 진입 시 자동) | 상점은 자동 개방 |
| `legend` | `cancel` (지역 선택 화면 경유) | 전설은 지역 선택에서 |
| `beastiary` | `confirm` + `left` / `right` | `observe` 돌 보유 시 |

- `shop` 과 `legend` 은 **화면 안에서 호출형**이다. 키 조합이 아니라 진입 경로다.
- 겹치는 조합 없음. 6개 패널 전부 도달 가능.
- `10` §1 의 "`아이템` 입력" "`작업실` 입력" "`≡` 입력" 표현은
  **모두 위 표의 조합으로 해석한다.** `≡` 은 글리프이며 키가 아니다.

---

## 4. 포커스 이동 규칙

```gdscript
func move_focus(dir: int) -> void:
    if _focus_list.is_empty(): return
    var idx: int = _focus_list.find(_focus)
    if idx < 0: idx = 0
    idx = wrapi(idx + dir, 0, _focus_list.size())
    _focus = _focus_list[idx]
    _focus_origin = _focus          # 닫을 때 복귀할 곳
```

- 2D 격자 메뉴는 상/하 우선으로 튀지 않게 `rows` 를 따로 관리.
- `focus_list` 는 **화면 상태별로** 계산한다. 전역 유지 금지.
- 포커스 이동 중 렌더 갱신은 그 프레임 끝에 1회만.

---

## 5. 마우스

- **마우스가 필요한 기능이 없어야 한다.**
- 그래도 클릭은 `focus` 이동 + `confirm` 으로 매핑한다 (편의).
- `docs/UI_IMPLEMENTATION_RULES.md` R2: hover 전용 정보 금지.

---

## 6. 테스트 항목

1. `input_enabled = false` 에서 6개 action 전부 무시.
2. 엣지 트리거: 키 홀드 시 1회만 발화.
3. 전이 중 입력은 드롭.
4. 패널 닫으면 `focus_origin` 로 복귀.
5. 대상 소멸 시 다음 유효 항목으로 이동.
6. 전원이 비면 닫기 버튼으로 이동.
7. 키보드만으로 12개 화면 전 기능 도달.
8. 허용되지 않은 action 은 실행되지 않는다.
