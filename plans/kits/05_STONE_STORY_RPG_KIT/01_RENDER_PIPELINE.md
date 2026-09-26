# 01 — 렌더 파이프라인

원칙: **이미지 파일 0개, ASCII 문자 렌더링 0개.** 모든 픽셀이 코드로 만들어진다.

---

## 1. 내부 버퍼

```text
내부 해상도   960 × 540  (16:9)
확대 배율     정수만. 실수 배 금지.
필터         nearest
```

| 목표 출력 | 정수 배 | 실제 그려지는 영역 | 여백 |
|---|---|---|---|
| 1280×720 | 1 | 960×540 | 없음 |
| 1920×1080 | 2 | 1920×1080 | 없음 |
| 2560×1440 | 2 | 1920×1080 | 좌우 320px + 상하 180px |

여백도 검정이라 화면과 경계가 없다. **흑백 방향의 실제 이득이다.**

### 1.1 정수 배 계산

```gdscript
var k: int = maxi(1, floori(minf(win.x / 960.0, win.y / 540.0)))
```

- `k` 는 창 크기가 바뀔 때만 재계산한다. 매 프레임 하지 않는다.
- `k == 1` 이면 여백이 없다.
- 창이 960×540보다 작아도 `k = 1` 이고 잘린다. 최소 창 크기를 960×540으로 고정한다.

### 1.2 Godot 설정

```ini
; project.godot
display/window/size/viewport_width=960
display/window/size/viewport_height=540
display/window/stretch/mode="disabled"
display/window/stretch/aspect="keep"
rendering/textures/canvas_textures/default_texture_filter=0
rendering/anti_aliasing/quality/msaa_2d=0
rendering/2d/snap/snap_2d_transforms_to_pixel=true
rendering/2d/snap/snap_2d_vertices_to_pixel=true
```

씬 구조:

```text
StoneStoryRpg (Node, GameModule)
└── Frame (SubViewportContainer, stretch=false, full rect)
    └── View (SubViewport, size=960x540, transparent_bg=false)
        └── World (Node2D)        ← 절차 드로잉 전부
```

**`stretch_shrink` 를 쓰지 않는다.** `SubViewportContainer.stretch = true` 로 두면
뷰포트 크기가 `container_size / stretch_shrink` 가 되어 **내부 960×540 가 깨진다.**

정수 배 확대는 **별도 정사각형 뷰포트 + 정수 스케일 샘플러**로 처리한다.

```gdscript
# Frame 이 창 크기에 맞춰 크기를 바꾼다. View 는 항상 960x540 로 고정.
func _on_resized() -> void:
    var win: Vector2i = DisplayServer.window_get_size()
    var k: int = maxi(1, floori(minf(win.x / 960.0, win.y / 540.0)))
    Frame.size = Vector2i(960 * k, 540 * k)
    Frame.position = ((win - Frame.size) / 2).round()      # 중앙 정렬
    View.size = Vector2i(960, 540)                        # 고정
```

- `Frame` 는 `SubViewportContainer` 가 아니라 **단순 `Control`** 이다.
  자식으로 `View`(SubViewportTexture 를 그리는 `TextureRect`) 를 둔다.
  `TextureRect.stretch_mode = STRETCH_SCALE` + `texture_filter = NEAREST`.
- `k` 는 `resized` 시그널에서만 재계산한다. 매 프레임 하지 않는다.
  → `15` X-04 "즉시 재계산" 의 트리거는 이 시그널이다.
- 여백은 `Frame` 바깥 검정이다. 화면과 경계가 없다.

### 1.3 금지 설정 (검수 항목)

- `msaa_2d` 를 2 이상으로 올리지 않는다.
- `default_texture_filter` 를 linear로 바꾸지 않는다.
- CanvasItem 에 `texture_filter` 를 개별 지정하지 않는다. 전역 nearest 하나만 쓴다.
- `draw_primitive` / `draw_polygon` 의 안티에일리어싱 옵션을 켜지 않는다.
- 서브픽셀 모션: 모든 좌표는 `roundi()` 한 번만 거친다. 두 번 이상 가하지 않는다.

---

## 2. 드로잉 규칙

| 규칙 | 값 | 강제 |
|---|---|---|
| 좌표 | 정수. 부동소수 좌표는 그리기 전에 `roundi` | `_draw` 진입 시점 |
| 선 굵기 | 1px 고정. 2px 이상 금지 | 헬퍼가 파라미터 |
| 채움 | 금지. 면을 채우는 도형 쓰지 않는다 | 헬퍼 없음 |
| 곡선 | 선분 폴리라인. 베지어 없음 | 헬퍼 없음 |
| 원 | `draw_arc` 12분할 고정 | `ring()` 헬퍼 |
| 색 | 무채색 원칙 | 팔레트 §3 |
| 텍스트 | 정수 좌표, 8/10/12/14px만 | `text()` 헬퍼 |
| 커서 | 흰 1×1 칩 1개 | 전용 |
| focus | 색 변화 금지. **점선 테두리** | `focus_rect()` 헬퍼 |

### 2.1 헬퍼 API (module-local)

`presentation/ink.gd` — 전 Kit의 드로잉은 이것만 쓴다.

```gdscript
class_name StoneStoryInk
extends RefCounted

static func line(canvas: CanvasItem, a: Vector2i, b: Vector2i, col: Color) -> void
static func polyline(canvas: CanvasItem, pts: PackedVector2i, col: Color) -> void
static func rect_outline(canvas: CanvasItem, r: Rect2i, col: Color) -> void
static func rect_dashed(canvas: CanvasItem, r: Rect2i, col: Color, dash: int = 4, gap: int = 3) -> void
static func ring(canvas: CanvasItem, center: Vector2i, radius: int, col: Color) -> void
static func text(canvas: CanvasItem, at: Vector2i, s: String, px: int, col: Color) -> void
static func text_right(canvas: CanvasItem, right_x: int, y: int, s: String, px: int, col: Color) -> void
static func text_center(canvas: CanvasItem, cx: int, y: int, s: String, px: int, col: Color) -> void
static func chip(canvas: CanvasItem, at: Vector2i) -> void          # 흰 1x1 커서
static func hatch(canvas: CanvasItem, r: Rect2i, col: Color, spacing: int) -> void
static func stipple(canvas: CanvasItem, r: Rect2i, col: Color, density: float, seed: int) -> void
```

**금지**: 이 헬퍼를 거치지 않는 `draw_*` 호출.
단 `draw_set_transform`은 정수 이동 purpose로만 허용.

### 2.2 선분 격자

- 모든 선의 끝점은 정수.
- 대각선은 Bresenham으로. `draw_line`이 하는 일을 그대로 쓴다(직접 구현 금지, 엔진 사용).
- 45도가 아닌 각도는 **금지.** 선분 오프셋을 정수로만 결정한다.
  → 45/90/0도만 쓴다. 기울어진 벽은 45도 계단으로 표현.

---

## 3. 팔레트

```gdscript
const VOID      := Color(0.00, 0.00, 0.00)   # 배경. 순수 검정
const INK       := Color(0.86, 0.86, 0.86)   # 주 선
const INK_DIM   := Color(0.42, 0.42, 0.42)   # 배경 텍스처, 장식 프레임
const INK_MUTE  := Color(0.26, 0.26, 0.26)   # 원경, 최원경
const PAPER     := Color(0.92, 0.92, 0.92)   # 텍스트
const PAPER_DIM := Color(0.55, 0.55, 0.55)   # 비활성 텍스트
const ACCENT    := Color(0.30, 0.72, 0.52)   # 강조 1. 화면 총면적 1% 미만
const WARN      := Color(0.78, 0.24, 0.20)   # 강조 2. 위험·경고
```

규칙:
1. 한 화면에서 `ACCENT` 과 `WARN` 을 **동시에** 쓰지 않는다.
2. 강조색 총면적은 화면의 1% 미만.
3. `INK_DIM` 이하는 원경에만. 근경 오브젝트에는 `INK` 만.
4. 상태 표현(독/화상/서리 등)에 색을 쓰지 않는다. **모양으로 표현한다.** §4.4.

---

## 4. 절차 텍스처

### 4.1 밀도 3단계

| 등급 | 용도 | 밀도 | 선 색 |
|---|---|---|---|
| `evidence` | 증거 · 직접 상호작용 | 높음 (간격 3~5) | `INK` |
| `navigation` | 길찾기 · 상황 이해 | 중간 (간격 8~14) | `INK_DIM` |
| `mood` | 분위기 | 낮음 (간격 20~40) | `INK_MUTE` |

- 밀도는 **장면 brief가 명시한다.** 코드가 추론해 승격하지 않는다.
- 기본값은 `navigation`.
- 한 화면에 3단계가 모두 있으면 등급 경계가 화면에서 읽혀야 한다.

### 4.2 벽 (원근 수직)

```gdscript
# 시드 → 선 개수/길이/간격
# x 위치는 최하단 간격 d에서 위로 갈수록 ceil(d * f) 로 넓어진다. f = 0.55
for i in range(count):
    var x_bottom: int = (i * spacing) + jitter(seed, i, 1)
    var x_top: int = x_bottom - int(ceil(spacing * 0.55)) + jitter(seed, i, 2)
    line(canvas, Vector2i(x_bottom, y_bottom), Vector2i(x_top, y_top), col)
```

- 세로선만. 수평 벽선은 쓰지 않는다 (스크린샷 근거).
- 높이 = 벽 대역 높이. 대역은 지형 데이터가 준다.

### 4.3 바닥 (수평 대역)

- 3~4개의 수평 대역. 각 대역 안에는 짧은 대시(`-`)를 무작위 간격으로 배치.
- 대역마다 밀도를 다르게 준다. 위쪽이 성기고 아래가 조밀.
- 대시 길이 1~3. 정수.
- **지면 텍스처 위에 오브젝트를 그린다.** 오브젝트가 바닥에 얹힌 깊이감을 만든다.

### 4.4 상태 표현 (색 금지)

| 상태 | 표현 |
|---|---|
| 독 축적 | 대상 아래에 점(`·`) 밀도 증가. 3단 변화 |
| 화상 | 대상 주위 사선(`/`) 3~5개, 축적 비례 |
| 서리 | 대상 위에 짧은 수평선(`-`) 추가 |
| 경직 | 대상 위 `*` 1개 + 대상 사본이 1px 진동 |
| 사망 | 대상이 3프레임 주기로 1px 아래로 이동 후 소멸 |
| 대기(AI) | 대상 머리 위 `o` 1개 |
| 공격 예고 | 공격 방향으로 1px 화살표 선 1개 |
| 무적(evade) | 대상이 투명. **점선 원**으로 위치만 표시 |

### 4.5 절차 시드

- 모든 시드는 `run_seed` + 좌표 + 용도 문자열에서 유도한 정수.
- `FastNoiseLite` 를 쓰지 않는다. `hash()` + LCG만 쓴다.
- 같은 좌표는 프레임이 지나도 같은 무늬다. (깜빡임 금지)

```gdscript
static func rng(seed_value: int) -> int:            # xorshift32
	var x: int = seed_value
	x ^= (x << 13) & 0x7FFFFFFF
	x ^= (x >> 17)
	x ^= (x << 5) & 0x7FFFFFFF
	return x
```

---

## 5. 폰트

- 시스템 산세리프. 프로젝트 기본 폰트 그대로 쓴다.
- 외부 폰트 파일을 추가하지 않는다. (이미지/폰트 자산 금지)
- 크기: **8, 10, 12, 14만.** 다른 크기를 쓰지 않는다.
- 자간(letter spacing) 조정으로 밀도를 만든다. 크기를 늘리지 않는다.
- 한국어 줄바꿈은 **어절 단위.** 12px에서 어절이 넘치면 다음 줄.
- 최장 문자열: 전설 최장 문단. `10_MANUAL_PLAY.md` §3에 실측 항목으로 둔다.

---

## 6. 화면 공통 레이아웃

```text
좌상 (12, 10)     통화 2~3 glyph
상단중앙 (cx, 10)  진행 중 목표 2~3 glyph
우상 (948, 10)     화폐 2~3 glyph (우정렬)
좌하 (12, 528)     생명 3~5 glyph
우하 (948, 528)    퀘스트 카운터 (우정렬)
중앙 (cx, 300)     대사 / 경고 팝업
```

- HUD 요소는 **최대 4개.** 스크린샷에 없던 요소는 추가하지 않는다.
- HUD에 박스·프레임·배경을 그리지 않는다.
- 좌상/좌하는 좌정렬, 우상은 우정렬.
- `VOID` 여백 외에 여백을 만들지 않는다.

---

## 7. 절대로 하지 않는 것

- 이미지 파일 로드
- `Image.create` 로 만든 텍스처를 `ImageTexture` 로 올리기
- ASCII 문자 지형
- 안티에일리어싱
- 실수 배 스케일
- 색으로 상태 표현
- 채움 면
- 1px 초과 선 굵기
- 상시 HUD 5개 이상
- 실수 좌표 드로잉
