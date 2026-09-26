# PVE 설계 결정 — 절차 비주얼 엔진

이 문서가 `core/procedural/**`의 **최우선 정본**이다. `CONTRACT.md`는 이 문서에서
파생된 결과물이고, 사람이 손으로 쓴다. 아래 코드는 이 문서 승인 없이는 쓰지 않는다.

기존 `body_part.gd:15-17`이 스스로 박아둔 사실이 출발점이다 — "pose 규약이 정해질
때까지 스텁". 그 공백 때문에 키트 계획서가 존재하지 않는 함수를 발명했다
(`plans/kits/07_PHYSICS_PUZZLE_PLATFORMER_KIT.md:1196-1205`). 그 공백을 메운다.

**정본 용어:** 절차 비주얼 엔진(PVE). `CONTEXT.md`의 "모듈"과 다른 것이다.
GameModule이 아니다. 런타임 교체 단위가 아니다.

---

## 0.axiom — 그림이 곧 물리다

> **보이는 것 · 충돌하는 것 · 닿으면 변형되는 것 — 셋이 하나의 스펙에서 나온다.**

- 스펙(JSON) → 정규 형상을 **한 번만** 생성한다.
- 그 형상에서 렌더 데이터 / 콜라이더 / 변형 핸들을 **함께** 파생한다.
- 움직임의 원천은 **접촉과 힘뿐**이다. 트윈·보간·타임라인·사인파 애니메이션 금지.
- 그래서 화면과 물리가 어긋날 코드 경로가 **존재할 수 없어야 한다.**

이것이 모든 아래 결정의 근거다. 아래 §1~§5에서 어떤 구조도 이 axiom을 깨면 기각한다.

### 0.1 핵심 구조: 정규 형상(Canonical Form)

셋을 "함께" 파생하려면 **공통 배열이 하나 있어야 한다.** 그 배열이 정규 형상이다.

```
class ProceduralShape
  rest    PackedVector2Array   # 정지 좌표. 빌드 시 1회. 불변.
  points  PackedVector2Array   # 현재 좌표. 매 프레임 갱신. <- 단 하나의 진실
  radius  PackedFloat32Array   # 노드당 반지름(스케일). points와 같은 인덱스.
  links   PackedInt32Array     # 연결 (i, j) 쌍. chain은 순차, grid는 격자.
```

**세 산출물은 전부 `points`를 읽는다.**

| 산출물 | 읽는 것 | bake 금지 |
|---|---|---|
| 렌더 데이터 | `points` | **금지** — 매 프레임 현재 좌표를 그대로 그린다 |
| 콜라이더 | `points` (동적) 또는 `rest` (정적) | — |
| 변형 핸들 | `points` + 노드별 스프링 | — |

`ProceduralShape`는 `rest`/`points`/`radius`/`links` 네 배열과 노드당
`ProceduralSpring.Spring2D` 하나를 소유한다. 이 클래스가 없으면 axiom 0을 증명할
수 없다. `rigid`/`soft_chain`/`soft_grid` 세 종류는 **모두 이 한 구조의 배선만
다르다** (§3).

---

## 1. 스펙 JSON 스키마

JSON-safe. `float`은 Godot JSON 파서 관점의 실수. 없는 키는 기본값.

### 1.1 공통 코어 (세 종류 모두 필수)

| 필드 | 타입 | 필수 | 기본값 | 범위 | 뜻 |
|---|---|---|---|---|---|
| `version` | int | ✅ | — | `== Procedural.ENGINE_VERSION` | 불일치 시 즉시 실패 |
| `id` | String | ✅ | — | 비어있지 않음 | 시드 경로. `derive_seed(world_seed, id)` |
| `kind` | String | ✅ | — | `rigid` \| `soft_chain` \| `soft_grid` | §3 |
| `seed` | int | ▫ | `0` | 0 ≤ v < 2³¹ | world seed 대체. 지정 시 caller seed 무시 |
| `palette` | Object | ▫ | `{}` | — | §1.5 |
| `physics` | Object | ▫ | `{}` | — | §1.4 |
| `collider` | bool | ▫ | `false` | — | `true`면 콜라이더 파생 (§2.2) |
| `render` | Object | ▫ | `{}` | — | §1.6 |

`kind`별로 아래 중 정확히 하나가 **필수**다. 나머지 두 개가 들어 있으면 실패한다.
(조용한 무시 금지 — `07` 사건의 재발 방지)

- `rigid` → `parts` (§1.2) 필수
- `soft_chain` → `chain` (§1.3) 필수
- `soft_grid` → `grid` (§1.7) 필수

### 1.2 `parts` — `rigid` 전용

배열. 각 항목은 `ProceduralBodyPart.configure()` 스펙 **그대로**이며 기존 키를
그대로 쓴다 (06 계획서가 이미 인용 중이므로 키를 바꾸지 않는다). 여기에 3개만 추가한다.

| 필드 | 타입 | 필수 | 기본값 | 범위 | 뜻 |
|---|---|---|---|---|---|
| `id` | String | ✅ | — | 고유 | 파츠 식별자 |
| `length` | float | ✅ | — | > 0 | 로컬 +X 방향 길이 |
| `base_radius` | float | ✅ | — | ≥ 0 | 시작 굵기 |
| `tip_radius` | float | ✅ | — | ≥ 0 | 끝 굵기 |
| `bend` | float | ▫ | `0.0` | -180 ~ 180 | 끝이 꺾이는 각도(도) |
| `wiggle` | float | ▫ | `0.0` | -1 ~ 1 | 횡방향 S자 흔들림 진폭(길이 대비) |
| `at` | float | ▫ | `0.0` | 0 ~ 1 | 부모 파츠 길이 대비 부착 지점 |
| `angle` | float | ▫ | `0.0` | -180 ~ 180 | 부모 프레임 기준 회전(도) |
| `scale` | float | ▫ | `1.0` | > 0 | 부모 대비 배수 |
| `kind` | String | ▫ | `"limb"` | 기존 `KIND_NAMES` | **기하 없음.** 메타데이터 (§7-1) |
| `shade` | String | ▫ | `"volumetric"` | 기존 `SHADE_NAMES` | 음영 방식 |
| `joint` | String | ▫ | `"root"` | 기존 `JOINT_NAMES` | **구형 호환. `at`로 환산** (§7-2) |
| `body_role` / `shade_role` / `rim_role` | String | ▫ | 팔레트 기본 | 기존 역할명 | §1.5 |

**`at` + `angle` + `scale`이 이 엔진의 핵심 확장이다.** 기존 `Joint{NONE,ROOT,MIDDLE,TIP}`
은 부착 지점 3개밖에 없어서 "모든 결합"을 표현하지 못했다. `at`은 연속이다.

### 1.3 `chain` — `soft_chain` 전용

노드 체인. **이것이 풀·이끼·수변 식생·머리카락·로프·꼬리의 표현이다.**
배열. 각 항목은 하나의 노드.

| 필드 | 타입 | 필수 | 기본값 | 범위 | 뜻 |
|---|---|---|---|---|---|
| `length` | float | ✅ | — | > 0 | 이전 노드에서 이 노드까지 거리(px) |
| `angle` | float | ▫ | `0.0` | -180 ~ 180 | 이전 노드의 진행 방향 대비 회전(도) |
| `radius` | float | ▫ | `0.0` | ≥ 0 | 이 노드 굵기 |
| `bend` | float | ▫ | `0.0` | -1 ~ 1 | 매 노드마다 누적되는 정지 곡률 |
| `anchor` | Object | ▫ | `{"mode":"free"}` | — | §4 |

첫 노드의 `angle`은 **오브젝트 로컬 기준**이다. 즉 `Object space에 서 있는 전체의 방향`을
결정하는 유일한 값이며, 이후 모든 노드는 여기서 누적된다. 전역 "위"는 없다 (§4.1).

### 1.4 `physics`

| 필드 | 타입 | 필수 | 기본값 | 범위 | 뜻 |
|---|---|---|---|---|---|
| `stiffness` | float | ▫ | `140.0` | > 0 | ω². 스프링 레이트 |
| `damping` | float | ▫ | `0.6` | ≥ 0 | 감쇠비. 1.0=임계, 0.4~0.7=흔들림 |
| `coupling` | float | ▫ | `0.0` | 0 ~ 1 | **`soft_grid` 전용.** 이웃 결합 가중치 (§3.3) |
| `force` | [x,y] | ▫ | `[0,0]` | — | 상시 외력(바람). 접촉이 아닌 지속 힘 |
| `max_substep` | float | ▫ | `1/240` | > 0, ≤ 1/30 | 고정 서브스텝. 프레임률 독립성 |

`gravity`·`timeline`·`phase_offset` **없다.** 중력은 `force`다. 시간 기반 애니메이션은 금지.

**결합에도 매직넘버가 없다.** 이웃 결합은 `stiffness`·`damping`과 **같은** 스프링을 쓴다
(§5 단계 3). 엔진 전체의 튜닝 상수는 이 표에 있는 것 + `ProceduralSpring`의 기존 상수
뿐이며, 결합에 `60.0` 같은 프레임레이트 가림 상수를 두지 않는다.

### 1.5 `palette`

역할명 → 명시 색. 키가 없으면 `Procedural.make_palette()`가 정한다.
**리터럴 RGB를 `palette` 밖에서 쓰면 실패.** (§8 e)

```json
"palette": { "body": "#c8b89a", "shade": "#6a5f4a", "rim": "#ffffff" }
```

### 1.6 `render`

| 필드 | 타입 | 필수 | 기본값 | 범위 | 뜻 |
|---|---|---|---|---|---|
| `mode` | String | ▫ | kind별 기본 (§1.8) | `bake` \| `strip` \| `mesh` \| `discs` | 그리는 방식 |
| `width_scale` | float | ▫ | `1.0` | > 0 | `radius`에 곱해지는 배수 |
| `body_role` / `shade_role` / `rim_role` / `outline_role` | String | ▫ | 팔레트 기본 | — | 역할명 |

### 1.7 `grid` — `soft_grid` 전용

| 필드 | 타입 | 필수 | 기본값 | 범위 | 뜻 |
|---|---|---|---|---|---|
| `width` | int | ✅ | — | ≥ 2 | 가로 정점 수 |
| `height` | int | ✅ | — | ≥ 2 | 세로 정점 수 |
| `rect` | [x,y,w,h] | ✅ | — | w,h > 0 | 오브젝트 로컬 배치 사각형 |
| `radius` | float | ▫ | `0.0` | ≥ 0 | 정점 굵기 |
| `field` | String | ▫ | `""` | `ProceduralNoiseField.FIELD_*` | 배경 드리프트용. `shape`\|`detail`\|`flow`\|`squish` |
| `field_amplitude` | float | ▫ | `0.0` | ≥ 0 | 노이즈 진폭(px) |
| `anchor` | Object | ▫ | `{"mode":"free"}` | — | §4 |

`rect`는 32×18 이하를 권장한다(§9 성능).

### 1.8 `render.mode` 기본값

| kind | 기본 mode | 의미 |
|---|---|---|
| `rigid` | `bake` | §2.4 bake 판정을 통과하면 1회 → 텍스처. **다시는 regen 금지** |
| `soft_chain` | `strip` | 매 프레임 `points`를 선으로. **bake 금지** |
| `soft_grid` | `mesh` | 매 프레임 `points` + `links` → 메시 |
| — | `discs` | 노드마다 원. 파티클·포드·점묘 |

`render.mode`가 `bake`여도 **§2.4 판정이 이긴다.** 스펙이 `bake`를 요청해도
`points`가 불변이 아니면 엔진이 거부한다.`

### 1.9 예시 3종

**예시 A — 풀 한 다발 (`soft_chain`).** 풀은 콜라이더가 아니다.

```json
{
  "version": 2,
  "id": "grass.blade",
  "kind": "soft_chain",
  "seed": 41,
  "collider": false,
  "physics": { "stiffness": 90.0, "damping": 0.45, "force": [14.0, 0.0] },
  "render": { "mode": "strip", "width_scale": 1.0, "body_role": "body" },
  "chain": [
    { "length": 0.0, "radius": 1.4, "anchor": { "mode": "pinned" } },
    { "length": 3.0, "radius": 1.2 },
    { "length": 3.5, "radius": 0.9 },
    { "length": 3.5, "radius": 0.6 },
    { "length": 3.0, "radius": 0.3 }
  ]
}
```

`chain[0]`만 `pinned`. 나머지 4노드는 `anchor`가 **없는데** 전부
`attached`(기본값, `parent = index − 1`)가 된다. 이것이 §3.2의 풀 정의다.

**예시 B — 바위 (`rigid`).** 같은 스펙에서 콜라이더가 나온다.

```json
{
  "version": 2,
  "id": "prop.rock",
  "kind": "rigid",
  "seed": 7,
  "collider": true,
  "render": { "mode": "bake", "outline_role": "ink" },
  "parts": [
    { "id": "mass",  "length": 18.0, "base_radius": 11.0, "tip_radius": 7.0,  "angle": 12.0 },
    { "id": "chip_a", "length": 7.0,  "base_radius": 4.0,  "tip_radius": 1.5,  "at": 0.55, "angle": -38.0 },
    { "id": "chip_b", "length": 6.0,  "base_radius": 3.5,  "tip_radius": 1.2,  "at": 0.72, "angle": 64.0, "scale": 0.9 },
    { "id": "chip_c", "length": 9.0,  "base_radius": 3.0,  "tip_radius": 2.0,  "at": 0.20, "angle": 100.0 }
  ]
}
```

**예시 C — 물 위를 부푼 수면 (`soft_grid`).** 넓은 면.

```json
{
  "version": 2,
  "id": "surface.pond",
  "kind": "soft_grid",
  "seed": 3,
  "collider": false,
  "physics": { "stiffness": 60.0, "damping": 0.8, "coupling": 0.35, "force": [0.0, 0.0] },
  "render": { "mode": "mesh" },
  "grid": { "width": 16, "height": 9, "rect": [0.0, 0.0, 160.0, 90.0], "field": "squish", "field_amplitude": 1.5 }
}
```

---

## 2. 스펙이 내는 산출물 3종의 정확한 형태

### 2.1 렌더 데이터

`ProceduralShape`의 `points`/`radius`/`links`를 **그대로** 소비한다. 중간 캐시가 없다.

| mode | 입력 | 소비 방법 |
|---|---|---|
| `strip` | `points`, `radius` | `links` 순서대로 `draw_polyline`. 굵기는 `radius[i]*width_scale` |
| `mesh` | `points`, `links` | `ArrayMesh` + `build_triangles()` 상당의 인덱스. **매 프레임 정점 갱신** |
| `discs` | `points`, `radius` | 노드마다 `draw_circle` |
| `bake` | `rest` | `compose_canvas()` 1회 → `ImageTexture`. **`rigid` 전용** |

**`bake`는 `soft_*`에서 호출하면 실패한다.**(`push_error` + 빈 결과)
구워넣으면 눕지 않는다는 것이 이 엔진의 존재 이유다.

### 2.2 콜라이더

**소스 배열 규칙 (axiom의 기계 검증 가능 지점):**

- `collider == false` → 없음. 풀·수면·머리카락이 여기 해당한다.
- `collider == true` + `kind == "rigid"` → **`rest`**에서 파생. 절대 움직이지 않으므로 정적으로 파생해도 정합하다.
- `collider == true` + `kind != "rigid"` → **`points`**에서 파생. 매 프레임 갱신된 좌표를 쓴다.

파생물은 노드 인덱스를 **보존**해야 한다. 콜라이더 i는 `points[i]`에서 나온다.
그래야 "누가 밀렸는지"를 되짚을 수 있다.

```gdscript
# 반환 형태 (신규 클래스 아님 — Dictionary, JSON-safe)
{
  "kind": "rigid",                       # 또는 "dynamic"
  "source": "rest",                      # 또는 "points"  <- §2.2 규칙
  "segments": PackedInt32Array,          # (2i, 2i+1) 쌍: points[i]→points[i+1]
  "circles": PackedInt32Array,           # 반지름이 있는 노드 인덱스
  "radius": PackedFloat32Array,          # circles와 대응. points와 같은 인덱스 기준
  "count": int
}
```

이 Dictionary는 `points`를 **복사하지 않는다.** 세그먼트 인덱스와 반지름 배열만
보관하므로, 렌더가 읽는 배열과 콜라이더가 참조하는 배열은 **물리적으로 같은 객체**다.
테스트 (b)가 이 동일성을 단언한다.

### 2.3 변형 핸들

`ProceduralShape` 그 자체다. 별도 클래스 없음.

```gdscript
func collect_contacts(world_point: Vector2, radius: float) -> PackedInt32Array
func apply_impulse(world_point: Vector2, radius: float, strength: float,
                   direction: Vector2) -> PackedInt32Array
func step(delta: float) -> void            # 물리 → points 갱신 (§5)
func get_points() -> PackedVector2Array    # 정본 배열. 복사 아님.
```

`get_points()`가 **복사본을 반환하지 않는다**는 것이 axiom 0의 구현 지점이다.
테스트 (b)가 이 참조 동일성을 검사한다.

---

## 3. 종류 판정 — `rigid` / `soft_chain` / `soft_grid`

셋은 **같은 `ProceduralShape`의 서로 다른 배선**이다. 별도 클래스를 만들지 않는다.

### 3.1 `rigid`

| 항목 | 값 |
|---|---|
| 언제 | 바닥·블록·장벽·의자·바위·기계 몸통처럼 변하지 않는 것 |
| 스프링 | 할당하지 않음. `points == rest` 항상 |
| 부모 | `parts[].at/angle` 트리로 리깅되나 **정지 상태 고정** |
| 콜라이더 | `rest`에서 파생 (§2.2) |
| 렌더 | **§2.4 판정 통과 시** `bake` 1회. 판정 기준은 kind가 아니라 데이터다 |
| 변형 | 없음. 대신 `collider`가 있음 |

### 3.2 `soft_chain`

| 항목 | 값 |
|---|---|
| 언제 | 풀·이끼·수변 식생·머리카락·로프·꼬리·천 조각·불꽃 |
| 스프링 | 노드당 `Spring2D` 1개 |
| 부모 | 기본값이 `attached`, `parent` 기본값이 **인덱스 − 1** (§4.3). `angle`은 **누적**되어 진행 방향이 된다 |
| 결합 | 없음 (체인이라 부모 상속이 곧 결합) |
| 콜라이더 | 기본 `false`. 필요하면 `true`로 두고 `points`에서 동적 파생 |
| 렌더 | `strip` 또는 `discs`. **절대 bake 금지** |
| 변형 | 접촉 → `apply_impulse` → §5 |

**풀의 정의를 여기에 고정한다.** 풀은 콜라이더가 아니다. 스프링으로 고정된 노드
체인이고, 매 프레임 자신에게 닿은 것을 쿼리해 임펄스를 받고, 화면은 그 노드의
현재 좌표를 그대로 그린다.

풀의 앵커는 정확히 두 갈래다.

```
chain[0]  anchor = pinned     ← 바닥에 박힌다
chain[1..] anchor = attached   ← 기본값. 앞 노드를 따른다
```

바람이 불면 뒤따르는 노드들이 밀리고, 밀린 만큼 앞 노드가 끌려가고, 그 결과
바람에 눕는다. 스프링이 복원력을 주므로 다시 일어선다. **양쪽 모두 `attached`가
있어야 성립한다.** `free`로 두면 눕는 힘(바람)이 없어 눕지 않는다.

| 항목 | 값 |
|---|---|
| 언제 | 수면·지면· membrane Curtain처럼 **넓은 면** |
| 스프링 | 정점당 `Spring2D` 1개 |
| 부모 | **없다.** 공간 근접성이 부모를 대신한다 |
| 결합 | `physics.coupling`. Laplacian 항: `Σ(이웃의 현재값 - 자기 평균)` |
| 콜라이더 | 기본 `false`. 필요하면 `points`에서 동적 파생 |
| 렌더 | `mesh`. **절대 bake 금지** |
| 변형 | 접촉 → `apply_impulse` → §5, **연결이 압력을 전파한다** |

**`coupling`이 0이면 `soft_grid`는 무의미하다.** 정점이 서로 독립이라 눌린 자리가
옆으로 전달되지 않는다. 그래서 `coupling`은 preemptive 파라미터가 아니라
**`soft_grid`가 `soft_grid`가 되기 위한 필수 항목**이며, 기본값 0은 "정지 상태"일 뿐이다.

---

## 4. 앵커 규약

> 이 항목이 비어 있으면 아무도 구현할 수 없다. (`body_part.gd:15-17`이 박아둔 사실)

### 4.1 전역 "위"는 없다

엔진에 전역 상·하·좌·우가 **존재하지 않는다.** 방향은 전부 국소적이다.
각 노드는 `angle`(도)로 **부모 프레임 기준** 자기 방향을 말한다.
"위"는 첫 노드의 `angle`과 오브젝트의 배치 회전에서 emerges 한다.

따라서 "어디가 기준이고 어느 방향이 위인가"는 오브젝트마다 다른 것이 **문제가 아니다.**
다른 것이 **정상**이고, 그 차이는 전역 규칙이 아니라 스펙의 수치로 표현된다.

### 4.2 앵커 3종

스프링 타깃이 **어디에서 오는가**만 정하면 끝이다.

| `anchor.mode` | 스프링 타깃 | 쓰임 |
|---|---|---|
| `free` | 자신의 `rest` 위치 | 로프 중간·깃발·잎.(default) |
| `pinned` | 고정된 월드 좌표 (= 자기자신 `rest`) | 풀밭 바닥·벽 등불·천장 조명. **움직이지 않는다** |
| `attached` | 다른 노드의 현재 프레임에서 계산 (§4.4) | 꼬리 끝→몸통, 발→몸통, 양동이→크레인 팔, 풀 다발→바위 |

`pinned`와 `free`의 차이는 **자유도**다. `pinned`는 스프링을 아예 만들지 않는다.
`ProceduralSquishRig.JointKind{PINNED, SOFT, RIGID}`가 이 3종과 1:1로 대응한다.

### 4.3 앵커 객체 필드

```json
"anchor": {
  "mode": "attached",
  "parent": 2,        // int, 노드 인덱스. mode=="attached"일 때 필수
  "at": 0.62,         // 0~1, 부모 노드 **길이** 대비 지점
  "offset": [0.0, 2.0],// px, 부모 프레임에서 그 지점 기준 로컬 오프셋
  "angle": 34.0       // 도, 부모 프레임 기준 회전
}
```

| 필드 | 타입 | 필수 | 기본값 | 범위 |
|---|---|---|---|---|
| `mode` | String | ▫ | `"free"` | `free`\|`pinned`\|`attached` |
| `parent` | int | `attached`일 때 ✅ | — | 0 ≤ i < 노드 수 |
| `at` | float | ▫ | `0.0` | 0 ~ 1 |
| `offset` | [x,y] | ▫ | `[0,0]` | — |
| `angle` | float | ▫ | `0.0` | -180 ~ 180 |

`parent`는 **앞선 인덱스만 허용한다.** 순환 참조는 빌드 시 실패.
`rigid`의 `parts[].at/angle`은 `parent`가 직전 파츠인 `attached`와 등가다.

### 4.4 부모 변환 상속 — 합성식

런타임에서 자식의 타깃은 **부모의 현재(변형된) 변환**에서 계산한다. 정지값이 아니다.

```
depth 0:  target_0 = rest_0                                  (pinned 또는 free)
depth n:  anchor_world = points[parent] + rotate(offset, rest_dir[parent])
          target_n     = anchor_world + rest_dir[n] * span[n]
```

`node_dir[i]`를 쓰지 않는다. **방향원은 `rest_dir` 다.** (§4.7)
`rigid` 에서는 `rest_dir[parent] * (at * span[parent])` 로 파트의 축 위 지점을 탄다.

**이 순서가 유일한 정답이다.** 정지값에서 자식을 계산하면 꼬리가 몸통을 따라가지
못한다. `squish_rig.gd:12-14`의 stub 명세가 말한 것이 정확히 이것이다.

`at`은 `rest_offset_n`을 **부모의 진행 방향**을 기준으로 잘라낸다.
`at == 0.62` + 부모 `length` 20이면, 자식의 정지 위치는 부모 시작점에서
진행 방향으로 12.4px 지점이다. `offset`은 그 지점에서의 추가 로컬 이동이다.
둘은 직교하므로 합이 아니다 — 순서가 있다.

### 4.5 리깅 깊이 합성

- `chain[0]`은 깊이 0. `anchor`를 **반드시 명시**한다. 생략 시 `pinned`.
  `attached`로 쓰면 빌드 실패.
- `chain[n]` (n ≥ 1)은 깊이 n. 기본값이 `attached` + `parent = n − 1`이므로
  깊이를 **따로 선언하지 않는다.** 별도 `depth` 필드는 없다 — 중복 상태는 없다.
- **트리 순회 순서 = 인덱스 오름차순.** 이 순서로 `points`를 갱신해야 부모가 먼저
  확정된다. (§5 단계 4)
- `rigid`의 `parts[].at/angle` 트리도 같은 규칙. `parts[0]`이 깊이 0이며
  엔진 좌표계에 직접 서 있다. `parts[n]`의 기본 부모는 `parts[n-1]`.
- `soft_grid`는 **깊이 합성 대상이 아니다.** 부모가 없고, 결합은 §3.3의 이웃 항이다.
  `grid.anchor.mode == "attached"`면 빌드 실패한다.

### 4.6 오브젝트 간 결합

`ProceduralShape`는 자기 루트 원점을 가진다. 다른 오브젝트에 붙는 것은 **caller의
responsibility**이며 엔진은 두 가지 제공만 한다.

1. `shape.get_root_transform() -> Transform2D` — 루트의 현재 위치·회전
2. `shape.set_root_transform(t: Transform2D)` — 루트를 놓고, 자식 `attached`가 전파됨

**씬 그래프를 엔진이 알지 않는다.** `Node`가 아니다. autoload 없다.

### 4.7 형태 기억 — 방향원은 `rest_dir` 다 (구현에서 확정)

`attached`만으로는 **정지 모양으로 돌아올 힘이 없다.** 자식 타깃이 부모의 *현재*
위치를 따라가므로, 부모가 한 번 밀리면 자식도 그 자리를 새 정지점으로 받아들이고
체인이 접힌 채로 남는다. 실제로 이 버그가 있었다 — 풀을 bodies 로 밀고 나면
끝단이 `rest` 에서 26px 어긋난 채로 영원히 돌아오지 않았다.

`free`가 정지 모양을 못 잡는 것과 **같은 종류의 구멍**이다. (§12-1)

해결은 새 파라미터가 아니라 **방향원의 교체**다.

```
위치원 = points[parent]     ← 부모의 현재 좌표. 부모를 따라간다.
방향원 = rest_dir[index]    ← 정지 방향.     형태를 기억한다.
```

`run_dir`(휜 방향, 실제 이동에서 유도)을 방향원으로 쓰면 끝단에 형태 기억이 없다.
`rest_dir`를 쓰면 스프링이 수렴할 때 각 노드가 저절로 정지 모양으로 돌아온다.
**상수 0개가 추가로 필요하다.**

| 항 | 결과 |
|---|---|
| 부모를 따라간다 | 위치원이 `points[parent]` 다. 몸통이 움직이면 자손이 따라온다 |
| 형태를 기억한다 | 방향원이 `rest_dir` 다. 스프링이 수렴하면 정지 모양으로 돌아온다 |
| 꼬리가 휜다 | 루트가 `attached` 면 루트가 따라가고, 끝단은 스프링 지연으로 뒤처진다 |

### 4.8 soft chain 은 부모의 **이동**을 상속한다. 회전은 상속하지 않는다

`soft_chain` 자식은 부모의 평행이동만 따른다. 부모가 회전하면 자식은 따라가지
않는다 — 스프링이 좌표만 integration 하기 때문이다.

회전해야 하는 서브트리는 두 방법 중 하나로 표현한다.

1. `rigid` 로 authoring 하고 `set_root_transform()` 으로 회전시킨다. (§4.6)
2. 회전한 자세를 그대로 `angle` 로 authoring 한다.

이것은 한계가 아니라 경계다. 2D 위치 스프링만으로는 각도 스프링이 필요하고,
그것은 요구사항이 아니라 범위다. 필요해지면 그때 붙인다.

---

## 5. 접촉 → 변형의 정확한 절차

5단계. **하나도 빠뜨리지 않는다.** 빠진 단계는 axiom 0의 위반이다.

### 단계 1 — 쿼리

```gdscript
var hit: PackedInt32Array = shape.collect_contacts(world_point, radius)
```

`rest`(또는 `points`) 기준 거리 `≤ radius`인 노드 인덱스를 **인덱스 오름차순**으로
반환한다. 거리순 정렬은 **하지 않는다** — 순서가 결과 재현성에 영향을 주면 안 된다.

### 단계 2 — 임펄스

각 `i` in `hit`에 대해:

```
falloff = 1.0 - (dist_i / radius)              # 중심 1.0, 경계 0.0
push    = project_onto_tangent(direction, node_dir[i])
spring[i].kick(push * strength * falloff)
```

- `push`는 접선 방향 성분만 쓴다. 접선 방향은 접점 법선과 직교해야 한다 — 그래야
  눌린 것이 옆으로 미끄러지지 않는다.
- `dist_i`는 `rest` 기준이다. 변형 중에도 쿼리 반경은 흔들리지 않는다.
- `strength == 0`이면 아무 일도 없다. `hit`은 비어 있어도 된다.

### 단계 3 — 적분

`soft_grid`는 **공용 스프링**으로 간다. 전용 상수가 없다.

```
# 인덱스 오름차순, in-place. 나중 인덱스의 이웃은 갱신된 값을 본다.
for i in 0 .. node_count:
    if not dynamic[i]: continue
    displacement = Σ_{j ∈ neighbours(i)} ( points[j] - rest[j] ) / degree(i)
    target[i] = rest[i] + coupling * displacement
    spring[i].set_target( target[i] )
    spring[i].step( delta )
```

- 결합은 **변위 평균**이다. 이웃의 위치를 이웃이 "있어야 할 자리"로 끌어당기는
  힘이 아니라, **이웃이 얼마나 움직였냐**를 나누어 갖는 것이다.
- `coupling`은 링마다 감쇠율을 정한다. 1.0이면 이웃과 함께 완전 강체로 움직이고,
  0.0이면 결합이 없다. 0 < c < 1에서 밀린 자리가 링을 넘어 전파된다.
- `stiffness`·`damping`은 다른 종류와 **같은 값**을 쓴다. 결합 전용 파라미터가 없다.
- 타깃이 **위치**이므로 `delta`를 곱하지 않는다. 프레임레이트에 독립적이다.
  `60.0` 같은 `1/dt` 가림 상수를 넣지 않는다.
- `coupling == 0`이면 `displacement` 항은 계산하지 않는다.

`soft_chain`·`rigid`는 이 단계를 건너뛴다. 그 종류의 결합은 §5 단계 4의 부모 상속이다.

### 단계 4 — 정점 갱신 (전파)

**이 단계가 없다면 연성 표면이 물리지 않는다.** 순서가 강제된다.

`soft_chain`·`rigid`:

1. **인덱스 오름차순**으로 노드 순회
2. 노드 `i`의 `attached` 부모가 있으면 **부모의 이번 프레임 `points`가 이미 확정된
   상태**에서 §4.4 식으로 `target_i`를 계산한다
3. `spring[i].set_target(target_i)`
4. `spring[i].step(delta)` → `points[i] = spring[i].value`

1단계와 2단계가 별개 호출이 아니다. **부모 갱신 → 자식 타깃 계산 → 자식 적분**이
노드마다 즉시 일어난다. 배치 처리로 미루지 않는다.

`soft_grid`는 이 단계를 수행하지 않는다. (단계 3이 이미 전파를 포함한다)

### 단계 5 — 화면이 그대로 읽는다

```gdscript
var pts: PackedVector2Array = shape.get_points()   # 복사 아님
draw_polyline(pts, color)
```

- **같은 프레임, 같은 배열.** 렌더는 `points`를 읽기만 한다.
- `rest`에서 다시 그리지 않는다. `compose_canvas()`를 다시 부르지 않는다.
- 텍스처에 굽지 않는다. `ImageTexture`는 `rigid`의 `bake` 모드에서만 존재한다.
- 렌더는 `points`를 **변경하지 않는다** (읽기 전용).

### 5.1 호출 순서 규약

```
1. caller가 접촉을 계산한다 (물리는 Kit/Mock의 몫)
2. shape.apply_impulse(...) 또는 collect_contacts(...) 후 직접 kick
3. shape.step(delta)          ← §5 단계 3~4. 물리 전부 여기서.
4. 화면이 shape.get_points()를 읽는다
```

**`step()` 이전에 그리는 코드는 금지.** 이것이 §0 axiom의 실행 가능 조건이다.

---

## 6. 동결 API 목록 (v2 delta)

`CONTRACT.md`는 **이 문서 1~2가 확정된 뒤에** 다시 쓴다. 지금 쓰지 않는다.
`ENGINE_VERSION`은 `1` → **`2`**. migration 절은 `CONTRACT.md`에 함께 실린다.

### 6.1 유지 (한 글자도 안 바뀜)

`Procedural`의 `derive_seed` / `make_noise` / `make_palette` / `make_canvas`,
`ProceduralSeed` 전체, `ProceduralNoiseField` 전체, `ProceduralCanvas` 전체,
`ProceduralSdf` 전체, `ProceduralPalette` 전체, `ProceduralPaletteScheme` 전체,
`ProceduralSpring` + `Spring2D` 전체, `ProceduralDeformField` 기존 13개,
`ProceduralBackdropDynamics` 기존 15개, `ProceduralBodyPart` 기존 16개,
`ProceduralCreatureBuilder` 기존 10개, `ProceduralSquishRig` 기존 17개.

**모든 기존 클래스명과 기존 시그니처는 살아 있다.** 계획서가 인용하므로.

### 6.2 추가 — 신규 파일

| 파일 | 클래스 | 역할 |
|---|---|---|
| `core/procedural/shape.gd` | `ProceduralShape` | §0.1 정규 형상. `rest`/`points`/`radius`/`links` + 노드별 스프링 + §2.3 + §5 |

`shape.gd`는 §0 axiom이 요구하므로 preemptive가 아니다. 없으면 axiom이 증명 불가.

### 6.3 추가 — 기존 클래스에 붙는 멤버

| 클래스 | 추가 | 이유 |
|---|---|---|
| `ProceduralBodyPart` | `at: float`, `angle: float`, `scale: float` | §1.2. 부착 지점을 3칸에서 연속으로 |
| `ProceduralBodyPart` | `anchor_mode: int`, `anchor_parent: int` | §4.3을 flat하게. `JointKind` 재사용 |
| `ProceduralBodyPart` | `segments: int` | 파츠 1개가 여러 노드를 가지는 경우. `soft_chain` 필요분 |
| `ProceduralSquishRig` | `to_shape() -> ProceduralShape` | 리그 → 정규 형상. §0 |
| `ProceduralDeformField` | `to_shape() -> ProceduralShape` | 격자 → 정규 형상. §3.3 |
| `ProceduralBackdropDynamics` | `to_shape() -> ProceduralShape` | 배경 → 정규 형상. §7-5 |
| `ProceduralDeformField` | `_coupling` 결합 항 (§3.3) | `soft_grid`가 되기 위한 필수 |

`JointKind` / `KIND_NAMES` / `JOINT_NAMES` / `SHADE_NAMES` / `Layer` / `FIELD_*`
enum은 **추가하지 않는다.** (`Kind` 관련 §7-1)

### 6.4 dict 팩토리 4개 — 구현됨 (2026-09-27)

`Procedural.build_sprite` / `render_frame` / `make_rig` / `make_backdrop` 은 처음에
"두 번째 사용처 전 금지"로 미구현이었다. 2026-09-27 사용자 지시("Kit 06·07·08의 화면이
쓸 core/procedural의 비어 있는 기능(스텁)을 채운다")로 구현했다. 06 계획서의
`screen_illustration.gd` 가 `build_sprite` 를 쓴다. 넷 다 얇은 껍데기이며 로직은 각
클래스에 있다. 결정 내용은 §14.

---

## 7. 기존 구조에서 발견한 충돌과 처리

### 7-1 `Kind` enum — 생성 금지와 기존 존재의 충돌

지시에는 "파츠 종류를 담는 `Kind` enum을 **만들지 마라**"가 있다. 그러나
`body_part.gd:20`에 이미 있고, `plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md:1540`이
`ProceduralBodyPart.Kind.TORSO`를 인용 중이다.

**처리: 유지하되 확장하지 않는다.** 지시는 "만들지 마라"이지 "지우라"가 아니다.
`Kind`는 이미 기하에 영향이 없는 메타데이터이고(§1.2), 요구사항 "종류는 메타데이터일
뿐 실제 형태는 숫자 파라미터에서 나온다"를 **이미 충족**한다. 이름을 바꾸거나 지우면
06 계획서가 깨진다. **추가 멤버 추가는 W0 승인 필요.**

### 7-2 `Joint{NONE,ROOT,MIDDLE,TIP}` → `at` 환산

구형 스펙 호환. `joint`가 주어지고 `at`가 없으면 `at = 0.0 / 0.5 / 1.0`.
`NONE`은 `anchor.mode = "pinned"`. 06 계획서 스펙이 **그대로 동작**한다.

### 7-3 `compose_canvas` / `compose` / `outline` — bake 경로

요구사항 "래스터에 구워박지 마라"와 충돌하나 **충돌하지 않는다.**
bake 허용 여부는 **kind가 아니라 §2.4의 데이터 판정**이 결정한다. `points`가 불변이면
bake는 옳고, 불변이 아니면 bake는 틀린다. `soft_*`는 이 판정에서 항상 거부된다.
기존 시그니처는 그대로 둔다.

### 7-4 `ProceduralDeformField`에 이웃 결합이 없다

현재는 정점별 독립 스프링 + 노이즈뿐이다. `soft_grid`가 `soft_grid`로 기능하려면
결합이 필수다. `coupling` 항을 추가한다(§3.3). 기존 멤버는 전부 유지.

### 7-5 `ProceduralBackdropDynamics`가 두 번째 코드 경로다

지시: "배경은 약한 스프링 + 바람이며 **같은 규칙**을 쓴다. 별도 코드를 만들지 마라."
현재는 자기만의 `_springs` 루프를 갖고 있어 `ProceduralShape`를 우회한다.
**처리: `ProceduralShape` 위에 얇은 껍데기로 재구성한다.** 기존 15개 시그니처는
그대로 유지하고, 내부만 위임으로 바꾼다. 바깥에서 보이는 동작은 같아야 한다.

### 7-6 `plans/kits/07_*.md:1196-1205`의 발명된 심볼

`Procedural.seed_for` / `palette` / `rect_sdf` / `circle_sdf` / `seg_sdf` /
`raster` / `texture` / `spring` / `deform_field` / `squish_rig` — **10개 전부 실재하지 않는다.**
`tools/procedural_contract_dump.gd`가 이걸 실패로 보고해야 한다.
**`plans/`는 내 소유가 아니다.** (§12). 보고만 하고 고치지 않는다. W0가 고친다.

---

## 8. 재발 방지 장치

### 8-1 계약 덤프

`tools/procedural_contract_dump.gd` — 엔진의 **실제** 공개 시그니처를 읽어
(1) 정본 계약표를 stdout으로 뽑고 (2) `plans/kits/0[678]_*.md`에 등장하는
`Procedural*` 심볼이 전부 실재하는지 검사한다. 하나라도 없으면 **실패(exit != 0)**.

**정본 계약표는 이 도구의 출력이다. 사람이 손으로 쓰지 않는다.**
`CONTRACT.md`는 도구 출력으로 갱신한다.

### 8-2 엔진 내 테스트

`core/procedural/tests/`에 GUT 테스트를 직접 둔다.

| ID | 내용 |
|---|---|
| a | 결정성 — 같은 `(spec_hash, version)`은 항상 같은 `rest` |
| b | 형상/콜라이더 일치 — `get_points()`가 반환하는 **참조**와 콜라이더 파생점이 **동일 배열** |
| c | 변형 반응 — 수용 기준 §6-3의 이동 임계값 테스트 |
| d | 팔레트 결정성 — 같은 시드 = 같은 역할 색 |
| e | 금지 API — `Input.` / `InputMap` / `get_tree()` / `/root` / autoload 0건 |

### 8-3 금지 (자체 테스트가 강제)

`Input.` · `InputMap` · `get_tree()` · `/root` · autoload · `Node` 상속 ·
`randf()`/`randi()` (시드 경로 외) · 리터럴 RGB (팔레트 경로 외) · 이미지 파일 로드.

---

## 9. 성능 예산

| 항목 | 한계 |
|---|---|
| `soft_grid` 정점 | 레이어당 32×18 이하 |
| `soft_chain` 노드 | 개체당 64 이하 (풀 다발 1개 = 다발 1-chain) |
| `soft_chain` 인스턴스 | 화면에 200개 이하. 그 이상은 `discs`로 낮춘다 |
| 배경 | 레이어당 앵커 18~34 (기존 `backdrop_dynamics` 계약 유지) |
| 목표 | 배경 5레이어 + 개체 20 + 풀 다발 100 = **2 ms/frame** |
| `bake` | `rigid` 1회. 프레임 경로에서 호출 0건 |

`blur` · `stroke_field` · `stamp_field` · `shadow_field`는 **빌드 타임 전용.**

---

## 10. 수용 기준 (기계 판정)

1. 시각적으로 완전히 다른 개체 **3종을 순수 JSON**으로 추가. **기존 파일 수정 0건.**
2. 움직임 **2종을 순수 JSON**으로 추가. 같은 조건.
3. **가장 중요** — 풀 한 덩어리를 만들고 움직이는 바디를 그 위로 통과시킨 뒤
   **정점 좌표가 실제로 밀렸는지** 단언. "텍스처가 만들어졌다"는 통과로 치지 않음.
   임계값 이상 변위 미관측 시 **실패**.
4. 위 0~3을 통과하면서 **기존 동결 시그니처가 한 글자도 안 바뀌었음**을 확인.

`core/procedural/tests/fixtures/`에 JSON을 넣는다. 신규 파일 추가는 허용.

---

## 11. 소유권

| 경로 | 상태 |
|---|---|
| `core/procedural/**` | **내 단독 소유** |
| `tools/procedural_contract_dump.gd` | 내 소유 (지시된 신규 파일) |
| `plans/**` `modules/**` `app/**` `project.godot` | **손대지 않는다** |
| `docs/**` `CONTEXT.md` `PROJECT_DECISIONS.md` | **손대지 않는다** (W0 소유) |

동결 시그니처 변경은 W0 승인 없이 못 한다. 본문 재구성은 승인 없이 한다.

---

## 12. W0 결정 — 2026-09-26 확정

네 개 미결 항목이 전부 닫혔다. 이 문서는 이제 구현 가능한 상태다.

### 12-1 `anchor.mode` 기본값 = `attached`

`free`는 **복원력 문제가 아니라 타깃 참조 문제**로 기각됐다. `free`는 부모 움직임을
무시하고 자기 `rest`로만 돌아가므로 **형상이 부모에 대해 고정되지 않는다.** 풀밭에서
`free`로 두면 눕는 힘(바람)이 없어 눕지 않는다. 눕는 것은 저절로 되는 게 아니다.

- 기본값 `attached`, `parent` 기본값 `인덱스 − 1`
- `chain[0]`은 부모가 없으므로 `anchor` 명시 필수. 생략 시 `pinned`
- 풀의 정의 = **`chain[0]`은 `pinned`, 나머지는 `attached`(기본값)**
- `free`는 **매달린 장식 파츠에만** 명시적으로 쓴다
- 상세 근거 §4.2

### 12-2 `soft_grid` 결합 상수 60.0 = **삭제**

`60.0`은 `1/dt`(60fps 가림)였다. 프레임레이트 의존을 가리는 상수다.

- **결합에도 매직넘버 금지.** 엔진의 튜닝 상수는 §1.4 표 + `ProceduralSpring` 기존
  상수뿐이다.
- 이웃 결합은 `stiffness`·`damping`과 **같은 스프링**을 쓴다. 결합 전용 파라미터 없음.
- 결합식은 **변위 평균** 기반이고 타깃이 **위치**다. 그래서 `delta`를 곱하지 않는다.
  `60.0`이 필요해질 이유가 구조적으로 없다.
- `coupling` 하나가 링마다의 감쇠율을 정한다. 1.0 = 이웃과 완전 강체, 0.0 = 결합 없음
- 상세 식 §5 단계 3

### 12-3 bake 판정 = kind가 아니라 **데이터**

> **규칙은 하나다. build 후 `points`가 불변이면 bake 가능하다.**

- 판정 입력에 `kind`는 **들어가지 않는다**
- `soft_chain`·`soft_grid` → 무조건 금지
- `rigid` + deform 필드 없음 → 허용
- `rigid` + deform 필드 있음 → 금지
- **패럴랙스·스케일·회전은 bake를 막지 않는다.** 노드 트랜스폼으로 그린다
  (`get_root_transform()` / `set_root_transform()`, §4.6). 그래서 카메라 오프셋을
  스프링에 넣지 않는다.
- **이중 판정.** 빌드 시 `is_bakeable()` 정적 검사 + 첫 `step()` 직후
  `points == rest` 원소 비교. 하나라도 다르면 `push_error` + 거부. 조용히 bake 안 한다.
- 상세 §2.4, §2.4.1

### 12-4 명칭 정본화 = **승인됨 (W0가 실행)**

`CONTEXT.md`에 `## 절차 비주얼 엔진`(61-64행)과 `## 정규 형상`(66-69행)이 추가되었다.
두 항의 문언이 본 문서의 §0과 일치함을 확인했다. `docs/**`는 계속 손대지 않는다.

---

## 13. 구현 순서 — 처리 완료 (2026-09-26)

**`CONTRACT.md`를 손으로 쓰지 않는다.** `tools/procedural_contract_dump.gd` (owner W9) 가
엔진에서 직접 읽어 뽑은 출력이 그 정본이다. 현재 **v2 생성 완료**, 도구가
`INFO DOC_DRIFT none: the CONTRACT.md tables and the code agree` 로 확인했다.

형식 규칙 — 도구는 `── 클래스명 (` 패턴으로 절을 찾는다. ASCII `-- ` 로 쓰면
14개 클래스 전부가 drift 로 잡힌다. 실제로 한 번 그렇게 되돌렸다.

| # | 산출물 | 상태 |
|---|---|---|
| 1 | `shape.gd` 정규 형상 | ✅ 31KB |
| 2 | 13개 기존 파일 본문 재구성 | ✅ 이름·시그니처 유지, 4개 공장 미구현, Kind 유지·미확장 |
| 3 | `tools/procedural_contract_dump.gd` | ✅ owner W9 |
| 4 | `core/procedural/tests/` | ✅ 54개 / 624 assert 전부 통과 |
| 5 | `core/procedural/tests/fixtures/` | ✅ 개체 3 + 움직임 2 순수 JSON |
| 6 | `CONTRACT.md` v2 | ✅ 도구 출력, `ENGINE_VERSION = 2` |
| 7 | 수용 기준 §10 판정 | ✅ 0~3 통과, 동결 시그니처 유지 |

`core/worldstate/CONTRACT.md` 는 별도 subsystem 이라 이 문서와 무관하다.
기본값 인자는 도구가 `<default>` 로 찍는다. 값이 필요하면 소스를 본다.

### 13.1 도구 소유

`tools/procedural_contract_dump.gd` 는 **owner W9.** 이 엔진은 건드리지 않는다.
2026-09-26 에 이 파일이 한 번 덮어써졌고(AGENTS.md `### 소유권 침해 시 동작`),
W0 가 "그대로 살림" 으로 결정했다. 정본 생성은 그 도구의 `--dump` 출력이 담당한다.


---

## 14. Wave 1 구현 결정 — 2026-09-27

사용자가 작업 중 질문 없이 추천안대로 진행하라고 지시했다. 아래는 그 과정에서 에이전트가
고른 것이다. 공개 시그니처(이름·인자 순서·인자 이름·반환 타입)는 하나도 바뀌지 않았다.

1. **리그의 회전·찌그러짐은 정규 형상에서 읽는다.** 관절마다 따로 두던 회전 스프링·
   squash 스프링은 두 번째 스프링 집합이라 §0 과 부딪혔다. 지우고, 뼈(부모 → 관절)가
   얼마나 돌고 줄었는지로 `get_rotation()` / `get_scale()` / `draw()` 를 만든다.
   움직임의 원천은 `disturb()` 임펄스와 `force` 뿐이다.
2. **리그 전체가 정규 형상 하나다.** 어느 관절에서 `to_shape()` 를 불러도 루트의 것이 나온다.
   전에는 자식 관절이 자기 하위 트리로 따로 형상을 만들 수 있었다.
3. **`rest_rotation` 은 라디안, `rest_position` 은 부모 프레임.** 이전 코드는 한쪽에서
   라디안, 다른 쪽에서 도로 읽었다. `get_rotation()` 과 같은 단위로 맞췄다.
4. **RIGID 관절은 부모에 정확히 붙어 간다.** 이전 매핑(RIGID → pinned)은 부모가 움직여도
   제자리에 남았다. pinned 노드로 두고 리그가 매 step 부모 위치에 놓는다. §4.8 대로 이동만
   상속한다.
5. **빌더의 부모는 `anchor.parent` 를 따른다.** §4.3·§4.5 의 규약인데 빌더가 무시하고
   늘 직전 파트에 붙였다. 다리를 몸통에 붙일 수 없었다. `ProceduralShape._build_rigid()`
   는 Kit 05 가 쓰므로 건드리지 않았다.
6. **`configure()` 가 JSON 문자열 이름을 받는다.** `"kind": "torso"` 가 조용히 LIMB 가
   되던 것을 고쳤다. enum 정수 `joint` 도 `at` 으로 바뀐다. (§7-2)
7. **`wiggle` 은 S 자다.** §1.2 문언대로. 이전 구현은 C 자였다.
8. **`render_frame` 은 굽지 않고 옮긴다.** 첫 호출에 한 번 굽고, 이후엔 두 관절 리그
   (고정된 밑동, soft 정수리)의 뼈를 따라 구운 그림을 다시 샘플한다. README 의
   "per frame 에 다시 만들지 않는다" 를 지킨다.
