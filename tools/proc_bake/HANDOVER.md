# proc_bake 인수인계 — 2026-09-28

이 문서를 읽는 에이전트는 이 세션의 대화와 git 이력을 볼 수 없다.
여기 있는 것이 전부다. 매니페스트(`MANIFEST.md`)는 "무엇을 만들지"이고, 이 문서는
"상태가 어디까지 왔고 무엇을 하면 바닥나는지"다.

## 1. 지금 있는 것

`tools/proc_bake/` — Godot 비의존 절차 애니메이션 베이크 툴. Python, numpy + PIL만 쓴다.
새 의존성 금지. Godot 락도 안 쓴다(테스트에 안 씀).

```
tools/proc_bake/
  proc_bake/          10개 모듈
    svgpath.py        SVG path → 폴리곤 (Python)
    sdf.py            폴리곤 부호거리장, smooth_min, coverage
    canvas.py         RGBA 캔버스, 셀 셰이딩 계층(ink→fill→shade→key)
    palette.py        색상 역할(role)만. RGB 리터럴은 spec의 palette 블록에만
    shapes.py         신체부위 라이브러리 로더, spine
    creature.py       파트 트리 → 융합 실루엣
    rig.py            스프링 리그 + 2본 IK + 보행 게이트
    sheet.py          콘택트시트
    check.py          **게이트** (아래 3절 필수 읽기)
    legcheck.py       다리 IK 판정 CLI
    bake.py           생물 베이크 CLI
    probe.py          각도 왕복 정합성 자가테스트
  shapes/             44개 SVG, 직접 path 집필
  specs/creatures/    A 10 + B 10 + C 10 = 30종
  specs/backdrops/    12장
  out/                산출물 (커밋 대상 아님)
  MANIFEST.md         제작 대상 리스트
  tools/              rename_dlc_classes.py
```

## 2. 명령

```
cd tools/proc_bake
python -m procbake.bake specs\creatures\A\01_x.json -o out\A --strip 8 --motion walk
python -m procbake.bake --autopose specs\creatures\A\01_x.json    # 다리 자세·길이 자동 보정
python -m procbake.bake --autopose <spec>                          # spec를 제자리 수정
python -m procbake.check                                           # 신체부위 44개 판정
python -m procbake.legcheck                                        # 다리 IK 판정
python -m procbake.probe                                           # 각도 왕복 자가테스트
python -m procbake.backdrop specs\backdrops\*.json -o out\backdrops
python -m procbake.bake --list-shapes
python -m procbake.bake --preview-shape torso_blob -o out\shapes
```

## 3. ⚠ 게이트는 반드시 교정값을 알고 쓸 것

**이 프로젝트에서 가장 위험한 건 게이트를 믿는 것이다.** 게이트가 세 번 조용히
잘못된 판정을 했다. 아래는 실측 교정표다.

| 지표 | 뜻 | 이게 맞는 값 | 이게 틀린 값 |
|---|---|---|---|
| `dev` (볼록껍질 이탈률) | 실루엣이 타원에서 얼마나 벗어나는가. **40px에서도 유지돼야 한다** | 타원 **0.02**, 실물 생물 **0.27~0.80** | — |
| `conc` (부위 오목부) | 몸통 도형의 안쪽으로 굽은 랜드마크 수 | 2 이상 | — |
| `dev_small` 게이트 | 생물 판정 기준 | **>= 0.06** | — |
| `fill_ratio` | 캔버스 대비 덮인 비율 | 0.18~0.45 | — |
| `WORLD_SCALE_FLOOR` | 판독 불가로 작아지는 파트 월드 스케일 | 0.22 (경고) | — |

**게이트를 지우지 말 것. 하지만 눈으로도 봐라.** 게이트가 통과해도 모양이
쓰레기일 수 있다(구멍 난 실루엣, 다리가 고리). 반대로 눈이 통과해도 게이트가 잡아낸다.

## 4. 재발 금지 — 이미 잡은 버그

이것들은 고쳤고, 되돌리면 같은 실수가 되살아난다.

**툴 버그 (내 코드)**
1. `canvas.blend_mask` — 불투명 색일 때 `out_a`를 덮어써서 **아래 레이어를 지웠다.**
   채우기가 사라지는 원인이었다.
2. `creature._origin` — 캔버스 오프셋을 **뺐**는데 **더해야** 해서 도형 전부 화면 밖.
3. `paint_ink` 부호 — `abs(d + w/2)`는 밴드가 `-w..0`, 즉 **실루엣 안쪽**이다.
   그 다음 불투명 채우기가 전부 덮는다. **윤곽선이 한 번도 그려진 적 없었다.**
   지금이 맞다: `abs(d - w/2) - w/2` = `0..w`, 바깥쪽.
4. `_rim_band` — 명암이 **조명 쪽에** 떨어지고, **실루엣 바깥에도** 칠해져서
   전부 때묵은 후광. 원반 하나에 밴드 2394px(면적 1520px)였던 게 증거.
   지금은 내부 마스크 + 양쪽 검증됨.
5. `apply_ik` / `chain_bone_lengths` — **관절로 들어오는 뼈를 그 관절의 길이로** 읽었다.
   허벅지 길이는 *무릎 관절로 들어오는* 뼈다. 모든 다리가 실제보다 길게 풀렸다.
6. 각도 되돌리기 3중 버그:
   - `angle`은 부모 **회전**이 아니라 부모 **뼈** 기준이다
   - 그 뼈는 **자식의 `at`**으로 샘플해야 한다(부모의 `at`이 아니다)
   - 2번째 링크의 부모 회전은 1번째 링크를 고친 **뒤**의 값
   이 셋 중 하나만 틀려도 `probe.py`가 잡는다. **고치면 반드시 probe를 돌려라.**
7. `autopose`가 `chain[:2]`를 스케일 — 2본 체인이면 **발**을 뼈로 잡는다.
   `_bone_parts()`가 그걸 막는다.
8. `trace_mask` — 1px 바늘(뿔·침)이나 떠 있는 점이 오면 추적이 포기.
  **이 버그 때문에 `tail_sting` `horn_single`을 "구조적으로 사용 불가"로 잘못 배제한
  적이 있다.** 에이전트가 그 잘못된 결론을 그대로 믿고 배치를 바꿨다.
9. `backdrop._cap` — 끝캡 방향을 법선에서 뽑아 **진행 방향 반대로** bulging →
   even-odd 충돌이 모양을 뚫는다. 실제 진행 접선(`_unit`)을 넘긴다.

**판정 착오 (지표가 아니라 눈이 옳았던 사례)**
- "오목" 지표가 처음에 **볼록**을 세고 있었다. 원형 10점, 오목 3개 추가해도 10점.
  → 볼록껍질 기반 `dev`로 교체.
- 서브에이전트가 "오목 4개"라고 보고한 `torso_slug` 실측 **0개**. 눈이 맞았다.
- 구멍 탐지기는 뚫린 생물 20개 중 **19개에 거짓 양성**. **게이트로 넣지 않고 제거했다.**
  신뢰 못 하는 게이트는 게이트 없는 것보다 나쁘다.

## 4b. 2026-09-28 마감 시점의 정직한 상태

게이트는 전부 통과한다: 부위 44/44, 다리사슬 53/53, 각도 왕복 오차 0.004도.
하지만 **눈으로 보면 통과와 통과가 다르다.** 남은 문제를 그대로 적는다.

**끝나지 않은 것 2종** — 스펙에 `known_weak` 가 들어 있다:
- `C/01_foremouth`, `B/06_springskip_toad` — 융합 실루엣이 배와 다리 사이를
  **구멍으로 닫아** 동물이 아니라 고리로 읽힌다. 다섯 번 시도했다: 골반을 넓히고
  좁히고, 다리를 벌리고 세우고, 다리를 길게 하고, `fusion` 을 8.5까지 올렸다.
  전부 실패. **`fusion` 은 부품을 두껍게 만들 뿐 아치를 이어주지 않는다.**
  **그리고 `--autopose` 가 다리 각도를 전부 다시 쓰기 때문에 다리 각도는 집필 레버가
  아니다** — 골반 자리와 다리 길이만 레버다. 다음 패스에는 골반 사이를 몸통이
  덮거나, 배보다 확실히 아래까지 닿는 다리가 필요하다.

**G4 예외 3종** — 스펙에 `g4_exempt` 와 이유가 들어 있다:
`B/02_mire_eel` `B/04_fluke_horror` `B/07_tendril_sumpworm`. 테이퍼 몸의 팁이니
작은 게 의도이고, IK 사슬을 업지 않아 구조가 그 크기에 의존하지 않는다.

**잘못한 판단으로 되돌린 것, 다시 말해 둔다.**
1. **`g4_exempt` 는 게이트를 느슨하게 한 게 아니라 spec에 이유를 적은 것이다.**
   게이트를 조용히 약화시키는 것보다 파일에 남는 편이 낫다.
2. **2본 체인의 둘째는 뼈다.** `chain_bone_lengths` 가 `chain[1]` 을 두 번째 뼈로
   읽으므로, `[limb, tiny_limb]` 형태는 tiny가 5%면 뼈가 2px가 되어 다리가 아무 데도
   닿지 못하고 매 프레임 포화한다. `B/04_fluke_horror` `B/10_ray_darter` 에서
   잘못된 IK 사슬 5개를 **삭제**했다. 지느러미와 짧은 돌기가 접지 다리가 아니다.
3. **작은 발을 "크게" 고치는 시도는 되돌렸다.** 월드 0.40으로 올리면 발이 IK 사슬의
   뼈가 되어 사슬이 풀리지 않았고, 0.22로 낮추면 `G4` 는 통과하지만 2px짜리 발이 된다.
   발은 원래 크기가 맞았다. **`--autopose` 를 곧바로 다시 돌리면 뼈가 다시 조정돼
   상태가 또 어긋난다** — 이 두 개는 되돌린 뒤 `autopose` 를 돌리지 않았다.

## 5. authoring 함정

- **`scale`은 부모 기준이라 체인을 따라 곱해진다.** 0.4/0.4/0.4 세 개는 월드 0.4/0.16/0.064
  = 4px 발. 실제로 세 에이전트를 이러게 물렸고, 한 배치는 발이 사라진 채 렌더됐다.
  관례는 1.0 / 0.9 / 0.75. `part_scale = 목표월드 / 부모월드`. bake가 G4로 잡아준다.
- **판정은 밝은 배경에서 봐라.** 윤곽선은 거의 검정이다. 어두운 시트에서는 윤곽선이
  안 보이기 때문에 자기 작업을 잘못 판단하게 된다. 시트는 중간 회색이나 연 회색 사용.
- `--preview-shape`은 실루엣 + **spine을 빨간 선과 노란 점으로** 그린다. `data-joints`가
  틀리면 즉시 보인다.
- SVG 규약: `viewBox`는 최종 픽셀, **+X = 성장 방향**, y는 아래로 증가, 커브만
  (직선으로만 닫힌 도형은 거부), 각지게 최소 2개.
- 팔레트는 **역할만.** RGB 리터럴은 spec의 `palette` 블록 안에만.

## 6. Godot 포크 — `core/procedural-icon-dlc/`

- ✅ `core/procedural` 전체 복사 (42파일)
- ✅ `class_name` 14개 전부 `Dlc` 접두사 (`tools/rename_dlc_classes.py`).
  **안 하면 Godot가 부팅에 실패한다** — class_name은 전역 등록이라 중복이 치명적.
- ✅ `svg_path.gd` — GDScript SVG path 파서
- ✅ `shape.gd` — `DlcShape`: 폴리곤 실루엣 + spine + **베이크된 거리장**
- ✅ `shape_library.gd` — `shapes/*.svg` 로더
- ✅ `shapes/` 44개 배치
- ✅ `tests/test_svg_shapes.gd` — 44/44 로드, spine·바운드·필드 검증 통과
- ✅ `tests/dump_shapes.gd` + Python 대조 — **두 파서가 일치**: 폭/높이 차이 0,
  spine 개수 차이 0. 점 개수만 전부 +1인데 Python이 클로징 포인트를 dedupe하고
  PackedVector2Array는 남겨서다. 길이 0짜리 변이라 무해.
- ✅ 복사본의 `.gd.uid` 19개 삭제 (원본 `core/procedural`의 16개는 그대로).
  안 지우면 UID 중복 경고 16건.
- ✅ **`DlcProceduralBodyPart`에 `shape` 연결** — `configure({"shape": "torso_lizard"})`.
  `length` / `max_radius()` / `rest_joints()` / `_distance()` / `_silhouette_extent()` 가
  전부 다형 실루엣을 읽는다. 빈 이름이면 기존 원시체 경로 그대로 = 기존 스펙 의미 불변.
- ✅ `detail` 키 추가 — 융합에서 제외하고 위에 그린다. 크리에이터 빌더의 `_fused_distance`가
  이를 건너뛴다.
- ✅ **`DlcProceduralCreatureBuilder.fusion`** — 파트 접합 필렛 폭(px). 사용자가
  "파츠끼리 부드럽게 이어지게" 하고 싶어 한 그 값. 베지에와 무관하다.
- ✅ ink 부호·rim 양쪽+내부마스크 버그 이식 (`_LAYER_INK_OUT`, `_LAYER_RIM`)
- ✅ `tests/bake_creature.gd` — 스펙 하나를 `shape` / `prim` 두 가지로 굽어 나란히 비교.
  340x230 기준 9~18초. 둘 다 PNG 성공.

### GDScript 언어 함정 3개
1. **`get()`으로 메서드명을 쓰면 안 된다.** `Object.get`이 내장 프로퍼티 접근자라
   오버라이드가 파싱 단계에서 거부된다: `Could not resolve external class member "get"`.
   `DlcShapeLibrary.shape()`로 썼다.
2. **명령 문자 판정에 `length() == 1`을 쓰면 안 된다.** 한 자리 숫자도 길이가 1이라
   `M 0,0`으로 시작하는 대부분의 파트가 "경로가 M 안에서 끝남"으로 죽었다(44개 중 42개).
   문자 집합(`_is_command`)으로 판정할 것.
3. **상수는 쓰는 클래스에 선언할 것.** `DlcShapeLibrary`에 넣고 `DlcShape`에서 쓰면
   `Identifier "FIELD_PAD" not declared in the current scope`.

### 포크 배선에서 걸린 함정 3개
4. **파일명을 덮어써서 정규형을 지웠다.** 포크에 `DlcShape`를 `shape.gd`로 만들었는데,
   거기엔 이미 복사해 온 `DlcProceduralShape`(정규형, 물리 배열)가 있었다. 컴파일이
   `DlcProceduralShape not declared` 로 죽었다. `DlcShape`는 `icon_shape.gd`로 옮겼다.
   **포크에 새 파일을 만들 때는 복사된 이름과 겹치지 않는지 먼저 볼 것.**
5. **`configure()`는 최상위 `"parent"`를 읽지 않는다.** 정본은 `anchor.parent`에
   **정수 인덱스**만 받는다. 그래서 `"parent": "torso"`는 조용히 무시되고 모든 파트가
   "바로 앞 파트"에 붙어, 생물이 대각선으로 엎드려 렌더됐다.
   → 포크에 `parent_id`(이름)를 넣고 `to_shape()`에서 인덱스로 해석한다. 없는 이름은
   조용히 넘어가지 않고 에러다. 이거 없으면 bake 툴 스펙 30개가 포크에서 그대로 안 돌아간다.
6. **`angle`의 기준이 두 갈래다.** 정본 `finalize()`는 `angle`을 **부모 방향** 기준으로
   읽고, 자식을 `rest_dir[parent] * (at * span)` = **직선 축**에 앉힌다.
   bake 툴(30종 전부 거기서 집필)은 **부모 뼈 at 지점** 기준으로 읽는다.
   → `to_shape()`에서 두 보정을 균일하게 적용: 오프셋은 그려진 spine 위 자리로,
   각도는 spine의 접선만큼. 원시체 부모에겐 **정확히 0**이라 기존 어휘는 안 변한다.

### 포크의 실측 (bake_creature.gd 출력)

```
torso    rest=(  0.0,  0.0) dir=  0.0  shape=yes
tail     rest=(120.0,  0.0) dir= -5.9  shape=yes
femur_f  rest=( 32.4, -0.9) dir= 96.6  shape=yes
foot_f   rest=( 26.1, 85.4) dir= -5.5  shape=yes
femur_b  rest=( 86.4,  0.9) dir= 94.0  shape=yes
```

`shape=yes`와 `shape=no`의 방향이 다르다(96.6 대 96.0, 91.3 대 85.0) — 자식이
**그려진 뼈**를 따라간다는 증거다. 이게 포크가 산다.

## 7. git 상태 (중요)

- **브랜치가 `main`이다.** 세션 중 다른 워커가 `kit/05-stone-story-rpg` → `main`으로
  옮기고 머지했다. `origin/main`과는 0/0로 동기.
- `kit/05-stone-story-rpg`은 6커밋 뒤처짐. 3-way 머지는 **충돌 0건으로 깨끗**하지만
  **로컬 미커밋 225개 중 223개가 그 커밋과 겹쳐서 막힌다** (222개가
  `assets/art/generic/**`, 남은 세션들의 진행 중 작업물).
  `stash`/`commit`/`버리기` 어느 것도 남의 작업물을 건드려서 하지 않았다.
- **`.git/index.lock`이 두 번 잔여했다.** 두 번 다 내 pull 실패가 남긴 것. git 프로세스
  부재 + 오래됨을 확인하고 제거했다. 9시간 묵은 것도 있었다.
  → 에이전트: pull이 실패하면 **반드시 lock을 확인하고** 프로세스가 없으면 제거할 것.
  안 그러면 전 세션이 git을 못 한다.
- 커밋은 아직 안 했다. `tools/proc_bake/`는 미추적 상태다. **사용자가 승인해야 한다.**

## 8. 다음 에이전트가 할 일

1. `python -m procbake.probe` → `python -m procbake.check` → `python -m procbake.legcheck`
   → `python -m procbake.backdrop specs\backdrops\*.json -o out\backdrops`
   네 개 모두 통과해야 시작 상태가 정상이다. (2026-09-28 기준 전부 통과 확인)
2. **Godot 락을 잡고** 아래를 돌려 포크가 살아있는지 확인한다:
   `godot --headless --path C:\projects\TINProject --script res://core/procedural-icon-dlc/tests/test_svg_shapes.gd`
   → `SVG SHAPE TEST OK` / `--- 44 shapes, 0 failures ---` 가 나와야 한다. 끝나면 락을 지운다.
3. **배치 C의 열선 생물 4종을 손본다** — `foremouth`(다리 고리), `gulper_sump`(실룩어),
   `ribbon_weaver`(실루엣 구멍), `springskip_toad`. 게이트는 이미 통과하므로
   눈으로 보고 고치는 일이다. 배경 11·12도 같은 방식으로.
4. 커밋은 **사용자 승인 후**. `git add -- tools/proc_bake core/procedural-icon-dlc` 다음
   경로 지정 커밋. `git add .` 금지(다른 세션 파일이 섞인다).

## 9. 포크를 남에게 넘길 때 (이게 핵심)

포크는 이제 **스펙을 통째로 받아 그린다.** `tools/proc_bake/specs/creatures/*/*.json`이
포크에서 바로 도는지, Godot 락을 잡고 하나 bake 해서 눈으로 확인하는 것이 남은 검증이다.
실패하면 원인은 거의 항상 위 6개 함정 중 하나다.
