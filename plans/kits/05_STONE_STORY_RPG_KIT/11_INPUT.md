# 11 — 입력

> **2026-09-26 전면 개정.** 1차 판은 6개 action + Input Bubble + 전투 중 개입 입력이었다.
> 사용자가 "직접 조종 없다"고 명시했으므로 **전투 입력이 없다.** Input Bubble 는
> 구현되지 않았고 승인 대기다 (D2).

---

## 0. 사용 가능한 키

`app/app_root.gd::_configure_module_actions` 가 `NORMAL_IDS` 에서 자동 생성한다.
이 모듈의 action 6개:

| action | 키 | 역할 |
|---|---|---|
| `stone_story_rpg_up` | `↑` | 로비 포커스 위 / **`guard` 홀드** (탐험) |
| `stone_story_rpg_down` | `↓` | 로비 포커스 아래 / 제작대(미구현) |
| `stone_story_rpg_left` | `←` | 로비 값 감소 / 다음 장비 |
| `stone_story_rpg_right` | `→` | 로비 값 증가 |
| `stone_story_rpg_confirm` | `Z` | 로비 확정 / 장비 토글 |
| `stone_story_rpg_cancel` | `X` | 로비 나가기 / **탐험 중단 → 로비 복귀** |

### 0.1 `Esc` 는 동작하지 않는다

`app_root` 가 `<id>_cancel` 에 `KEY_X` 만 바인딩한다. `Esc` 는 `meta_cancel` 이고
이 모듈은 ModuleContext 허용 action 밖을 쓰지 못한다.

→ `Esc` 지원은 `app/` 수정이므로 **승인 대기 (D3).**
승인 전까지 `Esc` 를 지원한다고 문서화하지 않는다.

### 0.2 `app/` 를 건드리지 않는 대안

확장 action (`inventory` `workbench` `jump`) 은 필요 없어졌다.
**전부 로비의 포커스 4칸으로 접근한다.** (`10_SCREENS_PRESENTATION.md` §1.1)

---

## 1. 엣지 vs 홀드

- **기본은 전부 엣지 트리거.** `is_action_just_pressed`.
- **유일한 홀드 예외: `guard`.** 스탠스이므로 유지해야 한다.

```gdscript
# 04 §6
var GUARD_ACTION := &"stone_story_rpg_up"
func _guard_held() -> bool:
	return context != null and context.input_enabled \
			and context.is_action_pressed(GUARD_ACTION)
```

- 홀드 중에도 반복 발화하지 않는다. 스탠스 유지만.
- 기력이 0 이면 강제 해제.
- **1차 판에서 이 예외를 문서화 안 해서 `guard` 가 표현 불가 상태였다.** 지금은 명시적.

---

## 2. 입력 펌프

`module.gd::_pump_input`

```gdscript
const LOBBY_ACTIONS := [up, down, left, right, confirm, cancel]

if mode == "lobby":
    for a in LOBBY_ACTIONS:
        if _pressed(a) and _lobby.handle(a): return
    return
if _pressed(cancel):
    _to_lobby("돌아왔다")
```

- **실제 키가 눌린 프레임에만** 넘긴다.
- 모듈 allowlist 밖 action 은 무시한다.
- `context.input_enabled` 가 false 면 아무것도 안 한다.

> **1차 판 버그**: `_pump_input` 이 키 확인 없이 매 프레임 `lobby.handle()` 을
> 불렀다. 로비에 머무는 동안 포커스가 매 프레임 회전했다. 테스트가 잡았다.

---

## 3. 탐험 중 조작

- **없다.** `cancel` 로 로비 복귀만.
- 장비는 탐험 중 동결. (`test_lobby_is_the_only_control_surface`)
- 이건 버그가 아니라 **설계**다. 플레이어가 전투 중 개입하면 짝퉁이 된다.

---

## 4. Input Bubble — 미구현

`docs/KIT_WORKFLOW.md` §7 은 장르 전환에서 Input Bubble 을 요구한다.

**현재 상태: 이 모듈은 Input Bubble 을 쓰지 않는다.**

- 팩토리/전환층은 `app/` 소유 → **승인 대기 (D2)**
- 승인 전까지: 버블이 없는 대신 **로비의 포커스 이동**이 키를 가르친다.
  이건 버블 대체가 아니다. **Phase 1 은 전환이 1회(로비→탐험)뿐**이므로
  버블이 배울 것이 적다.
- 키 힌트 문장은 로비 하단에 1줄 있다 (`11_INPUT.md` 의 `Y_KEYS`).
  이것은 버블 대체가 아니라 **가벼운 안내**이고, 문서화해 둔다.

### 4.1 Phase 2 에서 필요한 것

장르 전환이 2 이상으로 늘면 (로비↔탐험 외에 전설/제작이 추가되면)
`app/` 전환층에 Input Bubble 을 넣어야 한다. 그때:

- 키 집합: 로비 4칸 + 탐험 1개 = 실제로 6개
- `Esc` 는 넣지 않는다 (취소 키를 학습시키지 않는다)
- 버블 격자: 8열 × 2행, 물리 키 고정 셀

---

## 5. 마우스

- **필수 아니다.** 키보드만으로 전 기능 도달 (F-05 수동 과제).
- 그래도 클릭 = focus 이동 + confirm 으로 매핑 (편의).
- `docs/UI_IMPLEMENTATION_RULES.md` R2: hover 전용 정보 금지. 이 모듈엔 hover 정보가 없다.

---

## 6. 테스트

`tests/core/test_stone_story_rpg_core.gd`

| 테스트 | 보장 |
|---|---|
| `test_m_input_disabled_blocks_commands` | input 비활성 시 명령 거부 |
| `test_lobby_focus_and_navigation` | 포커스 순환 · 값 조절 |
| `test_lobby_is_the_only_control_surface` | 탐험 중 장비 동결 |
| (수동) F-05 | 키보드만으로 12개 기능 도달 |

**아직 없는 검증**: 홀드된 `guard` 가 실제로 유지되는지 자동 테스트.
탐험 중 입력을 시뮬레이션해야 해서 미구현. 수동 과제로 남김.

---

## 7. 금지

- 전투 중 플레이어 조작 창
- 탐험 중 장비 변경
- `app/` 를 직접 수정 (승인 없이)
- `Esc` 를 지원한다고 문서화
- 모듈 allowlist 밖 action 사용
- 매 프레임 입력 펌프
- key 하드코딩 (InputMap action 만 쓴다)
