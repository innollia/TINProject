# 3-Kit + 공통 시스템 라운드 — 실행 구조 (2026-09-26)

이 파일은 이번 라운드의 **크로스킷 정본**이다. Kit별 상태는 각 Kit의 docs 폴더가 소유한다.
루트 `docs/GRILLING_STATE.md`는 다른 에이전트가 동시에 사용하므로 이 라운드에서 수정하지 않는다.

## 1. 목적

**한시적 무료 AI 모델에게 대량 코드 작업을 맡기는 것.** 따라서 설계 우선순위는 다음 순서다.

1. 서로 간섭하지 않는 파일 소유권
2. 약한 모델이 그대로 실행할 수 있는 자기 완결 작업 단위
3. 검증은 자동 테스트 명령으로만
4. 공유 시스템은 **계약과 스텁을 먼저 동결**해 모든 Kit이 병렬로 코딩 시작할 수 있게 한다

## 2. 워크스트림 7개

각 워크스트림은 **경로 하나를 배타적으로 소유**한다. 두 워크스트림이 같은 파일을 절대 같이 쓰지 않는다.

| ID | 이름 | 소유 경로 | 산출물 |
|---|---|---|---|
| W0 | 계획·통합 | `docs/research/round_2026_09_26/`, `plans/kits/06_*.md` `07_*.md` `08_*.md` | 기획서, 동결 계약, 통합 |
| W1 | 세계관 문서 | `docs/world/**` | 앨리스 포스트아포칼립스 세계관 대문서 |
| W2 | 절차 비주얼 시스템 | `core/procedural/**` | 이미지·스프라이트·애니메이션 생성 엔진 |
| W3 | 오디오 파이프라인 | `tools/nkido_pipeline/**`, `core/services/audio_service/**` | 상황별 사운드 생성 + 재생 |
| W4 | Kit A | `modules/sideview_ecosystem/**` | Rain World 계열 Kit |
| W5 | Kit B | `modules/physics_puzzle_platformer/**` | Mosa Lina 계열 Kit |
| W6 | Kit C | `modules/descent_exploration/**` | Swallow the Sea 유사 Kit |
| W7 | 공용 기록판 | `core/worldstate/**` | 뭉탕이 3축 공유 상태 + 인계 검증 |

### W7 — 공용 기록판 (2026-09-26 확정)

사용자 확정: **3축으로 간다.** Kit이 아니라 집 전체가 소유하는 공유 상태가 있어야
"장르가 바뀌어도 같은 사람이 계속 다닌다"가 성립한다. 소유는 **어떤 Kit에도 두지 않는다.**

| 축 | 담는 것 | Kit A | Kit B | Kit C |
|---|---|---|---|---|
| **몸** | 잃은 것 / 바뀐 것 | read+write | read | read |
| **개체** | 누가 살고 있고 그 개체의 기억 | read+write | read | read |
| **장소** | 구역 지형과 변화 | read | read+write | read+write |

규칙:

- **어떤 Kit도 다른 Kit의 축 값을 정규화하지 않는다.** 적은 그대로 다른 축에 전달된다.
- 모듈은 `core/worldstate`를 통해만 읽고 쓴다. 다른 모듈을 직접 보지 않는다.
- 저장에는 픽셀이 아니라 축 값과 `(axis, id, version)`만 들어간다.
- 판정 테스트: Kit A에서 몸을 잃고 Kit B로 이동해도 그 손실이 그대로 남아 있고,
  Kit B가 그것을 정규화하지 않았음을 단언한다. 이 테스트가 통과해야 "1개 게임"이다.

**아직 비어 있음:** 세 축이 실제 장면에서 어떻게 엮이는지. `docs/world/12_AXIS_WEAVING.md`에서 확정한다.

### 소유권 규칙 (강제)

- 한 파일의 작성자는 **한 워크스트림뿐**이다.
- 다른 워크스트림이 그 파일이 필요하다면 **읽기만** 한다. 쓰기를 요청하지 않는다.
- 통합 수정은 **W0만** 한다.
- `app/app_root.gd`의 등록 목록, `project.godot`, `addons/`는 **W0 단독 소유**. 다른 워크스트림은 요청만 한다.

## 3. 공유 계약 (wave 0에서 동결)

세 Kit이 동시에 코딩을 시작하려면 공유 API가 **먼저** 고정되어야 한다. 고정 대상은 3개다.

### C1. 절차 비주얼 시스템 — `core/procedural/`

모든 Kit은 이것만 쓴다. Kit은 직접 픽셀을 만들지 않는다.

```
core/procedural/
  procedural.gd            #Procedural (최상위 진입)
  seed.gd                  # 결정적 시드. 같은 (seed, id, version) → 같은 결과
  noise_field.gd           # FastNoiseLite 래퍼. 위상/주파수/옥타브 고정값 보유
  raster/
    canvas.gd              # 픽셀 버퍼. fill/line/polygon/circle/blur/posterize
    sdf.gd                 # SDF 도형 래스터화 (부호 있는 거리 기반)
  palette/
    palette.gd             # 관계 기반 팔레트. 색 역할 -> 실제 색 매핑
    scheme_builder.gd      # 하나의 시드에서 조화 팔레트를 파생
  sprite/
    body_part.gd           # 파츠 하나 = 절차적 실루엣 + 채움 + 내부 명암
    creature_builder.gd    # 파츠 목록 → 개체 실루엳 합성
  anim/
    spring.gd              # 임계감쇠 스프링. 물리 기반
    deform_field.gd        # Per-vertex 변형. 배경 말랑말랑 운동의 핵심
    squish_rig.gd          # 컷아웃 관절 + 메시 변형 혼합 리그
  anim/backdrop_dynamics.gd# 배경 요소에 물리 + 스프링 적용
```

동결 규칙:

- 위 시그니처는 **이름과 인자 순서까지 고정**한다. wave 1 이후 변경은 W0 승인 없이 금지.
- 구현이 아직 없으면 **스텁을 먼저 만든다.** 빈 함수라도 시그니처가 있으면 Kit은 코딩을 시작할 수 있다.
- 스텁은 `push_error` 대신 `assert` 없이 빈 값을 반환한다. 테스트는 W2 책임.

### C2. 오디오 이벤트 — `core/services/audio_service/audio_service.gd` 확장

이미 존재하는 버스 `Music / SFX / UI / Voice`를 그대로 쓴다. 새 버스를 추가하지 않는다.

Kit은 아래 형태의 이벤트 표를 자기 소유 폴더에 선언한다.

```
audio_manifest = {
  "id_prefix": "eco",
  "events": [
    { "id": "footstep_wet", "file": "res://modules/sideview_ecosystem/audio/footstep_wet.wav", "bus": "SFX", "max_polyphony": 3, "volume_db": -6.0 }
  ]
}
```

W3는 **이벤트 재생기**(`audio_event_player.gd`)와 **nkido 랜더 스크립트**를 제공한다. Kit은 위 표만 채운다.

### C3. 모듈 등록 계약

기존 규칙 그대로다. `docs/MODULE_CONTRACT.md`를 바꾸지 않는다.

- `modules/<id>/entry.tscn`, `module.gd`, `module_manifest.tres`
- 등록은 W0만 `app/app_root.gd`에 한다.
- Kit은 `module_manifest.tres`까지만 만든다.

## 4. 실행 웨이브

| 웨이브 | 내용 | 동시 작업 수 | 선행 조건 |
|---|---|---|---|
| **wave 0** | 계약 C1–C3 스텁, 기획서 3편, 세계관 뼈대 | 4 | 없음 |
| **wave 1** | W2 엔진 구현 / W1 세계관 작성 / W4·W5·W6 도메인 코어 | 6 | wave 0의 스텁 |
| **wave 2** | 표현층·authored 콘텐츠·오디오 이벤트·테스트 | 6 | 자기 코어 |
| **wave 3** | 통합·해상도 검수·수동 플레이 | 1 (W0) | 전부 |

각 wave의 진입 조건은 파일 존재가 아니라 **테스트 통과**로 판정한다.

## 5. 이미지 0개 하드 게이트

세 Kit 모두 이미지 파일을 쓰지 않는다. 이건 문서가 아니라 **테스트**로 강제한다.

```
각 Kit 폴더 아래 .png .jpg .jpeg .webp .bmp .svg .ttf .otf .aseprite .kra 가 1개라도 있으면 실패
```

W0이 `tests/core/test_no_binary_assets.gd`를 만든다. 허용 예외는 **오디오 파일뿐**이고, 그마저도 `.import`가 커밋되어야 한다.

## 6. 오디오 선행 조건 (W3)

- 도구: **nkido** (MIT). `https://github.com/mlaass/nkido`
- 로컬 클론 위치: `C:\projects\_tools\nkido` (저장소 밖)
- 렌더 명령: `nkido render <patch.akkado> -o <out.wav> --seconds <n> --rate 48000 --no-default-bank`
- 자체 샘플: `--sample name=<path.wav>`
- **이 PC에 cmake / MSVC / ninja가 없다.** 빌드에 설치가 선행된다. 이게 W3의 첫 작업이다.
- 기본 샘플 뱅크(`--no-default-bank`로 끄지 않으면)에는 **CC-BY-SA 4.0과 무라이선스 샘플**이 섞인다. 절대 기본 뱅크를 쓰지 않는다.

원래 지시에는 `strudel.cc`가 적혀 있었으나, 라이선스와 브라우저 의존성 때문에 **nkido로 확정**했다. 근거는 `docs/STRUDEL_AUDIO.md`.

## 7. 세 Kit의 서로 다른 축 (복제 금지)

세 Kit이 같은 시스템을 공유하면 안 된다. 공유하는 것은 C1(절차 비주얼)과 C2(오디오)뿐이다.

| Kit | 진행 방식 | UI | authored 단위 |
|---|---|---|---|
| A `sideview_ecosystem` | **신체(몸)** — 게이트 없음, 공간이 요구하는 신체로만 통과 | 로딩·사망·잠 3개뿐. HUD·인벤토리·거래 UI 전무 | 신체 상태별로 열리는 구역 |
| B `physics_puzzle_platformer` | **조합** — 도구와 레벨은 전부 handmade, 무작위 선택·약간 변형. 자물쇠-열쇠 금지 | 도구 상태는 실루엣으로만 | handmade 레벨 + 도구, 선택기가 매 런타임 결정 |
| C `descent_exploration` | **지식과 선택** — 수집·소모·분기 종료. 세기 반복 금지 | 전환·종료 화면 위주 | 하강 구간 + 분기 |

## 8. 금지 (전 Kit 공통)

- 이미지 파일
- 상시 HUD
- 장문 조작 설명
- 카르마식 누적 수치 게이트
- "Tool A opens Door A" 자물쇠-열쇠 설계
- 전용 에디터를 Kit 완료조건으로 삼기
- `app/app_root.gd` / `project.godot`를 Kit이 직접 수정
- 구현 에이전트의 임의 판단. 없으면 멈추고 요청한다

## 11. 확정 — 2026-09-26 (사용자)

### 11.1 세계관 붕괴 조건 = A 스케일 붕괴

세계가 **크기를 잃었다.** 문이 집보다 크고, 방이 서로 맞지 않고, 같은 문이 두 크기로 열린다.
앨리스의 축소/확대가 원래 축이므로, 이것이 유일하게 앨리스 고유인 붕괴 방식이다.

**물은 금지한다.** 침수·홍수·비에 잠긴 폐허는 Rain World의 고유 형질이며 이 세계관에 쓰지 않는다.
`docs/world/`의 기존 판이 물에 의존하므로 foundations를 다시 세운다.

다른 후보는 기각했다:
- B 판단 정지 (재판이 끝나지 않는다) — 미채택
- C 영원한 다과 — 미채택
- D 카드가 재질을 삼킨다 — 미채택

### 11.1a 스케일 값 체계 = 6단 사다리 (사용자 확정)

정수 사다리 하나만 존재한다. `docs/scale_collapse/01_SCALE_ALGEBRA.md`가 정본이다.

```
speck 0.05 · hand 0.12 · doll 0.28 · common 0.65 · tall 1.50 · colossal 3.60
```

- 연속 float를 쓰지 않는다. "지금 몇 배"가 화면에 읽히는 것을 막고, 아무도 그 수치를 요구하지 않으며, 사다리가 오히려 텍스트 없이 구분 가능하기 때문이다.
- `1.0`은 사다리 값으로 금지한다. "정상 크기"로 읽히기 때문이다.
- 두 번째 숫자 체계(10단계 등)는 존재하지 않는다. 다른 문서가 같은 규격을 말하면 그 문서가 정본을 가리켜야 한다.

### 11.1b scale은 가역이다 (사용자 확정 — 에이전트 추천과 반대)

- `body.scale`은 **되돌릴 수 있다.** 비가역 밀도 손실 모델을 폐기한다.
- 따라서 세계관 헌법의 "몸의 변화는 일방이 아니다"는 불변식이 그대로 성립하고, 예외 규칙이 필요 없다.
- `body` 축은 두 부류로 나뉜다.
  - **확정 사실** — 잃은 부위, 흉터, 잃은 감각. **진행 축.** 되돌아가지 않는다.
  - **가변 능력** — 현재 `scale` 하나. **능력 축.** 되돌아간다.
- 진행 축과 능력 축은 섞지 않는다. 가변 능력은 진행 게이트가 될 수 없고, 확정 사실은 장비처럼 다루지 않는다.
- 현재 scale은 `body` 축에 저장한다. 되돌릴 수 있다는 것과 저장하지 않아도 된다는 것은 다른 문제다. 세이브/로드가 현재 크기를 복원해야 한다.

### 11.1c `den`/계승은 형질이 아니라 시스템이다 (사용자 확정)

11.2가 Rain World 고유 형질로 `den`/계승을 금지했는데, 그것은 과했다.
den/lineage는 **시스템**이며 — 개인 정체성 고정, 세 주기 간 지속, 확률적 세대 진행 — 이미 `creature` 축의 `id` / `memory` / `stage`로 옮겨앉았다. 금지 대상이 아니다. `den`/계승을 쓰는 코드는 허용한다.

### 11.2 레퍼런스 고유 형질 금지

Primary Reference 3작의 **고유한 시각 형질**을 우리 세계관에 가져오지 않는다.
Rain World에서 특히 금지: 침수, 비에 잠긴 산업 폐허, 작은 포유류 생존자.
다른 두 작에서도 같은 원칙을 적용한다. 시스템과 UX는 따라가고, 형질은 안 간다.
**`den`/계승은 예외다 — 형질이 아니라 시스템이므로 허용한다.** 11.1c 참조.

### 11.3 세계관 설명은 플레이어에게 전혀 보이지 않는다 (사용자 승인)

1. **세계관 문서는 제작 전용 정본이다.** 계획서에 인용은 되되 `제작 전용` 표시가 있는
   섹션 안에서만. 인용이 플레이어 노출 문자열로 넘어가면 안 된다.
2. **플레이어 노출 텍스트는 세 종류뿐** — 화면 이름, 버튼 라벨, 단수 명사 하나.
   **설명문은 0개.** Kit A는 UI가 로딩·사망·잠 3개뿐이므로 그 세 화면에 화이트리스트를 둔다.
3. **삭제한 설명을 되채우는 장치를 만들지 않는다.** 도감·저널·해설 NPC·엔딩 요약으로
   "그래서 무슨 일이 있었냐"를 플레이어에게 알려주는 것. `AGENTS.md`의 기존 금지를
   이 라운드 3개 Kit 전부에 명시한다.

실제 위험은 2번보다 3번이다. 계획서 작성자가 플레이어에게 세계관을 알려주고 싶은 유혹을
받으면 설명문이 들어간다. 그래서 금지 목록 명시 + 기계 검사로 막는다.

## 12. 상태 문서 위치

| Kit | 상태 문서 | 조사 문서 |
|---|---|---|
| A | `docs/research/rain_world/GRILLING_STATE.md` | `docs/research/rain_world/RAIN_WORLD_RESEARCH.md` |
| B | `docs/research/mosa_lina/GRILLING_STATE.md` | `docs/research/mosa_lina/MOSA_LINA_RESEARCH.md` |
| C | `docs/research/swallow_the_sea/GRILLING_STATE.md` | `docs/research/swallow_the_sea/SWALLOW_THE_SEA_RESEARCH.md` |
| 공통 | 이 파일 | `docs/STRUDEL_AUDIO.md` |
