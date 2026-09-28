# nkido 파이프라인 — 상태와 인수인계

2026-09-28. **이 문서가 이 폴더의 단일 진입점이다.** 새 세션은 여기서 읽고,
`README.md` 는 "어떻게 도는지", `KNOWHOW.md` 는 "왜 이렇게 하고 무엇을 하면 안 되는가"다,
`music/PIPELINE_REVIEW.md` 는 "외부 계획서를 무엇을 남기고 무엇을 버렸나"다.

소유 범위: `tools/nkido_pipeline/**`, 그리고 이 파이프라인이 산출물로 선언한
`modules/descent_exploration/audio/ambience/**`, `modules/descent_exploration/ambient_stems.json`,
`modules/descent_exploration/audio_ambience.gd`, `tests/core/test_descent_exploration_ambient.gd`.
**`modules/descent_exploration/module.gd` 는 건드리지 않았다.** 그 파일은 Kit 세션 소유다(§5).

> **주의 — 이 폴더의 한국어 파일을 PowerShell 로 덮어쓰지 마라.**
> `Set-Content` / `Get-Content -Raw` 왕복이 UTF-8 을 깨뜨렸다(2026-09-28 실제로 잃음).
> `edit` / `write` 도구 또는 UTF-8 인식 편집기를 쓴다.

---

## 0. 30초 요약

| | |
|---|---|
| nkido | Windows에서 **clang-cl로만** 빌드된다. MSVC 빌드는 컴파일을 죽인다 |
| 렌더 | 이벤트 43/43 · 앰비언스 stem 11/11 · exit 0 |
| 객관 게이트 | `tool/analyze_audio.py` · 자체 셀프테스트 통과 · 미해결 1건 |
| 청취 검증 | 사람이 11개 stem을 들어 봤다. **루프 이음은 못느꼈다 = §6 통과.** 반대로 7건에서 실제 결함 발견(§4) |
| 프로필 믹스 | `tool/mix_profiles.py` 가 프로필 7개를 **파일 1개씩**로 합쳐 낸다. **믹 게이트 exit 0** |
| Godot | `DescentAmbience` 믹서 + 테스트 12/12 통과. `module.gd` 미연결 |
| 음악 컴파일러 | 사양→`.akkado` 변환기까지 작성. 레이어 추가는 보류(§6) |
| 다음 일 | §7 의 1번. `build/mix/` 7개를 파일 하나씩 듣기 |

## 1. 이걸 다시 쓰지 마라 (확인된 사실)

전부 실측이다. 근거는 `README.md` 3·8절과 `music/PIPELINE_REVIEW.md`.

1. **nkido는 MSVC로 컴파일을 죽인다.** 링크와 실행은 되고 `akkado --help` 도 되지만,
   비어 있지 않은 패치를 컴파일하면 `0xC0000409`. 원인은 한 번의 잘못된 할당:
   `0x0102011600000037` = 약 66 PB. 하위 32비트 `0x37`(=55)만 유효하고 상위 32비트는
   인접 메모리. clang-cl로 바꾸면 사라진다. `nkido_build/badalloc_probe.cpp` 로 재확인 가능.

2. **빌드 함정 다섯 개.** `CEDAR_ENABLE_FILE_IO=OFF` 는 링크가 깨진다(OpenSSL Dev 설치가 정답).
   `CMAKE_CXX_FLAGS` 를 덮어쓰면 `/EHsc` 가 사라져 죽는다. `/utf-8` 필수(한국어 코드페이지).
   `core.autocrlf=true` 로 받으면 소스가 CRLF 가 된다. clang-cl 은 `/EHsc` 와
   `/D__PRFCHWINTRIN_H` 가 추가로 필요하다. 전부 `README.md` 3절.

3. **akkado 문법 규칙.** `//` 만 된다. 변수는 **단일 바인딩**(`var` 로도 재대입 안 됨, E150).
   `gate` `left` `right` `room` `chord` `voicing` 은 선점 이름. `@.field` 는 **파이프 안에서만**
   가능하다(E003). nkido는 블록 단위로 끊겨서 `--seconds` 와 실제 길이가 정확히 안 맞는다.

4. **nkido 스테레오 규칙 세 문장.** 이게 이 파이프라인에서 가장 비싸게 얻은 교훈이고
   **두 번 깨졌다가 세 번 고쳤다.**

   1. 스테레로 차이는 **첫 필터 이전에, 맨 소스에서만** 만든다.
   2. **어떤 필터도 스테레로 플래그가 붙은 신호를 보면 안 된다.**
   3. 두 모노 체인은 **"컴파일이 접지 못하는 것"**으로 달라야 한다. 음파 detune과
      `noise` 시드는 안 접히지만, **상수가 다른 컷오프는 접힌다.** 그 결과 두 체인의
      출력이 바이트 단위로 같아져 모노가 된다.

   필터는 항상 두 채널을 쓰고 입력이 `STEREO_INPUT` 플래그가 없으면 같은 `input[i]`를
   양쪽에 복제한다. 즉 필터는 모노를 스테레로 만드는 지점이고, 필터를 통과한 신호는
   복제쌍이다. 21개 경우로 검증(`tool/probe_filter_width.py`, `probe_stereo_rule.py`).
   **컴파일러는 이 형태로만 코드를 낸다** — 사람이 같은 실수를 반복할 자리가 없다.

5. **저역통과가 스테레로 경로에서 DC를 쌓는다.** `stereo(...) |> lp` 는 모노 경로보다 훨씬
   크고 DC가 0.45 까지 간다(결과는 마스터 soft clip 포화). `freeverb` 이 그 오프셋을 더
   증폭해 0.57 까지 간 사례가 있다. **뒤에 하이패스를 하나 두면 사라진다.**
   소스의 `DENORMAL_DC` 가 원인 후보다. upstream 버그이므로 규칙으로 피한다.

6. **`saw()` 는 이미 0-mean 이다. 0.5를 빼지 마라.** **이 실수를 두 번 했다.**
   첫 번째는 되돌렸고, **다음 라운드에 그대로 다시 해서** 게이트가 DC −0.57 로 다시 잡아냈다.

7. **주어진 툴체인으로는 sample을 못 쓴다.** `--no-default-bank` 필수(라이선스).
   `n"sh*8"` 같은 패턴은 조용히 무음이다(−60 dBFS 실측).

8. **`euclid(n, 8)` 을 곱셈에 쓰면 무음이다.** `noise() * euclid(5,8) * ar(trigger(1))`
   = −60 dBFS. 드럼 레시피는 이 경로에 기대고 있었다.

## 2. 명령

```powershell
# 1. 툴체인이 없다면 (한 번만)
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --source winget `
  --accept-source-agreements --accept-package-agreements --disable-interactivity `
  --override "--quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
winget install --id Kitware.CMake          -e --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
winget install --id Ninja-build.Ninja      -e --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
winget install --id ShiningLight.OpenSSL.Dev -e --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity --force
winget install --id LLVM.LLVM              -e --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
# SDL2-devel-<ver>-VC.zip 을 C:\projects\_tools\deps\sdl2 에 풀어 둔다

# 2. nkido 클론 + 빌드 (저장소 밖. 10~15분)
git clone --depth 1 --single-branch https://github.com/mlaass/nkido C:\projects\_tools\nkido
cd C:\projects\_tools\nkido
git config core.autocrlf false
git config core.eol lf
cd /d C:\projects\TINProject
tools\nkido_pipeline\nkido_build\build.cmd

# 3. 전체 파이프라인 (렌더 + 루프 접기 + 분석 게이트)
cd C:\projects\TINProject
.\tools\nkido_pipeline\build_audio.ps1 -CheckFirst
```

`build_audio.ps1` 은 네 단계를 한 번에 돈다: `nkido check` → `nkido render` →
`tool/loopify.py`(루프 크로스페이드) → `tool/analyze_audio.py`(게이트). 아무것도 지우지
않으므로 중간에 실패해도 다시 돌리면 된다.

검증 도구:

```powershell
py .\tools\nkido_pipeline\tool\analyze_audio.py --selftest     # 게이트 자체 검증
py .\tools\nkido_pipeline\tool\probe_filter_width.py          # 스테레오 규칙 21건
py .\tools\nkido_pipeline\tool\probe_stereo_rule.py           # 레벨 규칙 6건
py .\tools\nkido_pipeline\tool\probe_rhythm.py                 # 리듬 구성요소 12건
py .\tools\nkido_pipeline\tool\probe_melody.py                 # 멜로디/화성 9건
py .\tools\nkido_pipeline\tool\probe_level.py                  # 레벨 10건
tools\nkido_pipeline\nkido_build\probe.cmd                  # MSVC 버그 재확인
```

## 3. 파일 지도

```
tools/nkido_pipeline/
  STATUS.md                 이 문서. 상태와 인수인계
  README.md                 사용법 · 툴체인 설치 · Windows 함정 5개 · akkado 문법 · 게이트
  analysis_targets.json     게이트 기준 + mono_ok + open_findings + resolved_findings
  audio_events.json         이벤트 43건 (손으로 쓴 정본)
  ambient.json              앰비언스 stem 11 · profile 7 (손으로 쓴 정본)
  build_audio.ps1           렌더 + 루프 접기 + 게이트
  nkido_build/
    build.cmd               nkido를 Windows에 세우는 전 과정
    std_bit_shim.h          <bit> 강제 include (nkido가 include를 안 함)
    badalloc_probe.cpp      MSVC 컴파일러 버그의 근본을 찍는 프로브
    probe.cmd               위 프로브를 링크해서 돌린다
  tool/
    loopify.py              루프 크로스페이드. 표준 라이브러리만
    analyze_audio.py        객관 게이트. numpy만
    mix_profiles.py         프로필 7개를 파일 1개씩으로 합친다. 사람에게 3개 동시 재생을 요구하지 않기 위해
    compile_music.py        MusicSpec -> .akkado (레이어 추가는 보류, §6)
    probe_*.py              계측용 프로브 5종
  patches/
    kit_a..kit_c, shared_ui  이벤트 43
    ambient/                 stem 11
  music/
    PIPELINE_REVIEW.md      외부 계획서 판정 + 발견 기록
  KNOWHOW.md                규칙 · 근거 · 대가. 왜 이렇게 하고 무엇을 하면 안 되는가
  build/                    렌더 결과. 커밋 대상 아님 (.gitignore)
```

## 4. 청취 검증 기록 (2026-09-28)

사람이 11개 stem을 원래 속도로 들었다. **게이트가 잡지 못한 것을 잡아낸 것이
이 라운드의 실질 산출물이다.** 계측으로는 8번까지 좋다.

| 파일 | 들은 것 | 조치 |
|---|---|---|
| `amb_air` | "귀에 대고 바람불기" | 레벨 −19→−22, 컷오프 하강, hp 120→90. 상관도 0.00 |
| `amb_surface` | "고압수 쏘는 소리. 엄청강함" | hp 1800→500, phaser 제거, 레벨 −22→−26. 상관도 1.000→−0.00 |
| `amb_column` | "활공하면서 바람 가르는 소리" | **좋음. 유지** (상관도 0.77) |
| `amb_pulse` | "맥박이 아니라 외계 총 쏘는 소리" | saw → sine, 어택 0.001→0.22 s |
| `amb_pressure` | "소리가 안 들림" | 41 Hz → 82 Hz, 중간 성분·노이즈 추가. peak −9.5→−2.2 |
| `amb_cavern` | "정체불명의 불협화음" | fdn → freeverb, 근음 추가, 게이트 완만. 상관도 0.980→0.55 |
| `amb_drone` | "겁나 크긴 한데 공포임" | 레벨 −20→−24, `−0.5` 제거. DC −0.574→없음 |
| `amb_dread` | "가장 완성도있어" | **기준점. 그대로 둔다** |
| `bgm_descent` | "마인크래프트 배경음악 시작부분같다" | **성공 + 기준 앵커. 레벨만 −21→−25** |
| `bgm_swell` | "9랑 같은 낮은 우웅" | **근본 문제.** 트라이톤 2옥타브 상향, 아크 상향, 스웰 2박. 상관도 0.97→0.10 |
| `bgm_dread` | "올라갔다 내려갔다. 서스펜스" | 유지 (레벨 −25) |
| 루프 이음 | "못느낌" | **§6 통과. 귀로 검증됨** |

**게이트가 못 잡는 것의 목록** — 사람이 해야 하는 전부다:

- **-layer가 속삭임인지 죽은 것인지.** 계측이 −22 dB 아래 레이어를 "들릴 수도, 죽었을 수도"로
  통과시킨다. 게이트는 NOTE 로만 보고한다. 이건 취향이다.
- **지루함.** 8초와 16초 루프를 몇 번 반복해야 지루해지는지.
- **정체성.** `bgm_swell` 과 `bgm_descent` 가 같은지 여부처럼, "의도했나?"는 숫자가 아니다.

### 4.1 3개를 동시에 들을 수 없을 때

2026-09-28 사용자 확인: 프로필을 섞어 듣는 것을 요구할 수 없다. 그래서
**요구하지 않는 쪽으로 해결했다.** `tool/mix_profiles.py` 가 프로필 7개를 각각
**파일 하나로** 합쳐서 `build/mix/` 에 낸다.

합산은 대충한 것이 아니라 **런타임이 하는 산술 그대로**다.

- 게인은 stem 의 base `volume_db` + 프로필 선형 게인 + 버스 트림(`mix_trim_db`).
  즉 플레이어가 실제로 듣는 레벨이다.
- 믹스보다 짧은 stem은 루프해서 채운다. 게임의 루프하는 `AudioStreamPlayer` 가 하는 일이다.
- 결과도 루프 접기를 거친다. 미리듣기에서 "탁" 하는 소리는 게임에서도 난다.

이 도구가 처음 돌렸을 때 계측으로만 보이는 결함을 **두 개** 잡았다.

1. **7개 프로필 전부 목표보다 10~25 dB 작았다.** 목표 −24..−14 LUFS, 실제 −27.9..−42.0.
   "겁나 크다"는 말에 base trim을 −22~−26까지 내렸는데, 프로필 게인이 또 곱해져
   바닥이 사라졌다. → `mix_trim_db` 한 개(13.5 dB)를 추가. 열한 개를 눈대중으로 맞추는
   대신 **측정 가능한 수 하나로** 해결했다.
2. **죽은 레이어가 있었다.** `deep` 의 `amb_dread` 가 −27 dB, `amb_cavern` 이 −34 dB,
   `dread` 의 `bgm_swell` 이 −29 dB. 게인 0.35로 심어놨는데 믹스에서 들리지 않았다.
   stem 을 하나씩 들어서는 절대 알 수 없는 종류의 결함이다.
   → `--balance` 가 floor 아래 레이어를 floor까지 올린 값을 제안하고, 실제로 반영했다.
   이건 사람이 아니라 **기계가 고쳐야 하는 것**이다. 40 dB 아래는 취향이 아니라 꺼짐이다.

그리고 과잉 교정도 드러났다: "고압수 엄청강함" 수정은 `amb_surface` 를 약 12 dB,
`amb_column` 을 약 9 dB 깎아 **게인 1.0으로도 들리지 않게** 만들었다. 이건 게인이 아니라
**stem 레벨 문제**였고, base `volume_db` 를 −16 / −15 로 되올려 고쳤다.


## 5. Godot 쪽 남은 일 (6줄)

`DescentAmbience` 는 만들어졌고 테스트도 통과한다. **`module.gd` 에 붙지 않았다.**
그 파일은 Kit 세션 소유라 건드리지 않았다.

```gdscript
# _ready 에서
_ambience = DescentAmbience.new()
_ambience.name = "Ambience"
add_child(_ambience)
_ambience.setup()               # res://modules/descent_exploration/ambient_stems.json
_ambience.apply_profile(&"surface", 0.0)

# 상태가 바뀔 때마다
_ambience.apply_profile(&"column", 4.0)
_ambience.fade_out(2.0)         # 죽음·일시정지
```

`apply_profile` 은 알 수 없는 이름을 받으면 `false` 를 돌려주고 아무것도 바꾸지 않는다.
프로필 이름: `silence` `surface` `wade` `column` `deep` `cavern` `dread`.

## 6. 음악 컴파일러 — 보류와 그 이유

`tool/compile_music.py` (사양 → `.akkado` × layer) 와 프로브 다섯 개를 썼다.
문법 제약은 다 확인했다(§1 의 3·4·7·8). **레이어를 추가는 보류한다.**

거부한 이유: 레이어 레시피가 §1-5(스테레로 저역통과 DC)와 §1-6(`saw` 0-mean)을
모르고 있었다. 실제로 그 오해로 **stem 네 개가 DC 0.57 과 상관도 1.000 으로 망가졌다가
게이트가 잡아 되돌렸다.** 22 dB 를 모르는 상태에서 20개 stem 을 얹으면 전부 막힌다.

`compile_music.py` 는 이 규칙을 **자동으로 지킬 수 있다** — wide stem 은
`stereo()` + `out()` 1인자 형태로만 코드 생성하고, 상수 컷오프 차이는 쓰지 않으면 된다.
그래서 컴파일러는 §7-2 다음 순서로 다시 쓴다.

## 7. 다음 일 — 순서대로

1. **`build/mix/*.wav` 7개를 파일 하나씩 들어본다.** 이것이 §4-1에서 요구하지 않기로
   정한 것이다. 순서: `surface` → `wade` → `column` → `deep` → `cavern` → `dread`.
   질문은 하나다. **"stem 개별보다 덜하거나 같거나, 많다"** — 그리고 `NOTE` 로 찍힌
   레이어가 실제로 들리는지, 음악이 너무 얇은지.
2. `music/identity.yaml` 과 `music/states/*.yaml` 작성 (아직 없다).
   `compile_music.py` 가 기대하는 입력이며, motif(3·7도)·조성·레이어 게인을 담는다.
3. `compile_music.py` 의 레이어 레시피를 §1-4·5·6 규칙으로 재작성하고,
   `min_rms_dbfs` 와 true peak 을 통과한 뒤에만 stem 을 추가한다.
4. stem category 확장 — 현재 ambience 11개 + bed 3개. drums·bass·harmony·melody 가
   있어야 §5 의 계층이 음악이 된다.
5. Godot 연결(§5), 수평 재구성, §13 수정 이력.

## 8. 하지 말 것

- **MSVC 로 nkido 를 빌드하지 말 것.** 컴파일러가 죽는다.
- **`--no-default-bank` 를 빼지 말 것.** 라이선스 규칙.
- **`saw()` 에서 0.5를 빼지 말 것.** 이미 0-mean 이다. 두 번 했다.
- **스테레로 플래그가 붙은 신호를 필터에 넣지 말 것.**
- **두 모노 체인을 상수 컷오프 차이로 구분하지 말 것.** 컴파일러가 접어서 모노가 된다.
- **레벨이 0인 stem 을 추가하지 말 것.** 레시피가 조용히 무음을 만든 사례가 세 건 있다.
- **`open_findings` 를 지우지 말 것.** 래칫이다. 해결되면 `resolved_findings` 로 옮긴다.
- **REAPER 와 생성형 오디오 모델을 넣지 말 것.** 2026-09-28 사용자 확인:
  "음악은 100% AI가 만들거라 인간용 도구 필요없음". 근거는 `music/PIPELINE_REVIEW.md` 2절.
- **루트에 `/music` 처럼 평행 트리를 세우지 말 것.** 정본 위치는 여기다.
- **이 폴더의 한국어 파일을 PowerShell `Set-Content` 로 덮어쓰지 말 것.** UTF-8 이 깨졌다.
