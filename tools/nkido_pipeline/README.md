# nkido 오디오 파이프라인 — 운영 안내

상황별로 필요한 사운드를 **오프라인 렌더**로 만들어 WAV로 뽑는다.
이미지 0개 파이프라인의 오디오 절반이다. 즉 이 파이프라인도 외부 자산을 가져오지 않는다.

- 도구: **nkido** (MIT), `https://github.com/mlaass/nkido`
- 계약: `docs/research/round_2026_09_26/ROUND_PLAN.md` 6절, C2절
- 재생 쪽 계약: `core/services/audio_service/README.md`

두 가지가 있다. **이벤트**( situations, 3초 미만, 한 번 울림)와 **앰비언스 stem**
(무한 루프, 게임 상태에 따라 레벨이 섞임). 두 번째 것이 2026-09-28에 추가됐다.

**단일 진입점은 `STATUS.md` 다.** 상태, 인수인계, 다음 일, 하지 말 things가 거기 있다.
이 문서는 "어떻게 하는가"만 설명한다.

```
tools/nkido_pipeline/
  STATUS.md                 ← 먼저 읽을 것
  README.md                 이 문서
  music/PIPELINE_REVIEW.md  외부 계획서 판정과 발견 기록
  analysis_targets.json     객관 게이트 기준
  nkido_build/              nkido를 Windows에 세우는 전 과정
```

---

## 1. 폴더 구조

```
tools/nkido_pipeline/
  README.md              이 문서
  STATUS.md              상태 · 인수인계 · 다음 일 · 하지 말 것
  audio_events.json      이벤트 기계 입력. 4개 그룹 · 43 사건
  ambient.json           앰비언스 stem 기계 입력. 11 stem · 7 profile
  analysis_targets.json  객관 게이트 기준 + 미해결 추적
  build_audio.ps1        두 매니페스트를 읽어 nkido render 를 돌리고 PASS/FAIL 을 낸다
  nkido_build/           nkido 빌드 스크립트 · <bit> 강제 include · 버그 프로브
  tool/
    loopify.py           루프 크로스페이드 후처리와 dBFS 측정 (표준 라이브러리만)
    analyze_audio.py     객관 게이트. numpy만
    compile_music.py     MusicSpec -> .akkado (현재 막힘, STATUS 6절)
    probe_*.py           계측용 프로브 4종. 규칙을 왜 그렇게 정했는지 남긴다
  events/README.md       상황 → 사건 매핑 읽기 도우미. 기계는 읽지 않는다
  patches/
    kit_a_sideview_ecosystem/           16
    kit_b_physics_puzzle_platformer/    13
    kit_c_descent_exploration/           9
    shared_ui/                           5
    ambient/                            11   ← stem
  build/wav/            렌더 결과. 스크립트가 만든다. 커밋 대상 아님
  samples/              우리 소유 샘플만 여기에 둔다. 현재 비어 있음
```

각 매니페스트는 자기 영역의 유일한 정본이다. `events/README.md`는 사람이 읽는
도우미일 뿐이고 어떤 값도 두 곳에 쓰지 않는다.

렌더가 파이프라인 밖으로 나가는 곳은 하나뿐이다. stem의 `res_file`이 가리키는
`modules/<kit>/audio/ambience/`와, 거기서 파생되는 `modules/<kit>/ambient_stems.json`.

---

## 2. nkido를 Windows에 세우는 법 (2026-09-28 실측)

이 절은 그대로 따라 하면 된다. 전부 실제로 필요한 순서로 적었다.

| 항목 | 필요한 것 | 비고 |
|---|---|---|
| git | 클론용 | |
| 툴체인 | VS 2022 Build Tools (`Microsoft.VisualStudio.Workload.VCTools` + 권장 항목), CMake, Ninja | `winget install` 3회 |
| SDL2 | 개발용 zip | `SDL2-devel-2.32.10-VC.zip`. 클론이므로 `lib/x64/SDL2.dll` 을 실행 파일 옆에 복사 |
| OpenSSL | 개발 패키지 | **Light 가 아니라 Dev.** Light 는 DLL만 깔아서 `find_package(OpenSSL)` 이 실패 |
| LLVM | clang-cl | MSVC 빌드가 컴파일을 죽이므로 (§3) |

```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --source winget `
  --accept-source-agreements --accept-package-agreements --disable-interactivity `
  --override "--quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
winget install --id Kitware.CMake     -e --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
winget install --id Ninja-build.Ninja -e --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
winget install --id ShiningLight.OpenSSL.Dev -e --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity --force
winget install --id LLVM.LLVM         -e --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
```

클론과 의존성:

```powershell
git clone --depth 1 --single-branch https://github.com/mlaass/nkido C:\projects\_tools\nkido
# git이 LF로 체크아웃하게 한다. autocrlf=true로 받으면 소스가 CRLF가 된다 (§3-4)
cd C:\projects\_tools\nkido
git config core.autocrlf false
git config core.eol lf
```

`std_bit_shim.h`는 `C:\projects\_tools\deps\std_bit_shim.h` 한 줄짜리 파일이다.
nkido가 `std::countr_zero` 를 쓰면서 `<bit>` 를 include 하지 않는다. Clang과 GCC는
전이적으로 그 헤더가 들어오지만 MSVC는 아니어서 `pattern_compiler.hpp` 가 컴파일되지
않는다. 클론 소스를 고치지 않고 강제 include로 푼다.

```cpp
#include <bit>
```

의존성은 **공백 없는 경로**로 둔다. `C:\Program Files\OpenSSL-Win64` 는 CMake
인자를 공백으로 깨뜨린다. 그래서 `include/`와 `lib/`을 `C:\projects\_tools\deps\openssl`
로 복사해 쓴다.

빌드 스크립트는 저장소 밖 `C:\projects\_tools\build_nkido_clang.cmd` 에 있다.
`build-clang\bin\nkido.exe` 와 `akkado.exe` 가 나온다. **실행 파일 옆에
`SDL2.dll` 과 `libcrypto-4-x64.dll` / `libssl-4-x64.dll` 을 복사해 둔다.**
없으면 프로세스가 `0xC0000135` 로 죽는다.

확인:

```powershell
C:\projects\_tools\nkido\build-clang\bin\nkido.exe --help
C:\projects\_tools\nkido\build-clang\bin\akkado.exe --check <어떤 .akkado>
```

---

## 3. nkido on Windows — 실제로 밟은 함정

이 도구의 Windows 대응 상태는 `docs/prd-windows-port.md` 기준 "IN PROGRESS" 다.
라이브러리는 MSVC로 통과하지만 **실행 파일은 MSVC로 못 쓴다.**

### 3-1. MSVC 빌드는 컴파일을 죽인다 (우회 필수)

MSVC로 빌드하면 링크·실행까지는 된다. `akkado --help` 도 된다. 하지만 **비어 있지 않은
패치를 어떤 것이든 컴파일하면 죽는다.** 종료 코드는 `0xC0000409` (fast-fail), 출력이
없다. CLI에 `try/catch` 가 없어서 `std::bad_alloc` 이 `std::terminate` 으로 새어나간다.

원인은 4줄짜리 프로브로 확정했다 (`C:\projects\_tools\probe\`, nkido 밖).

- `akkado::compile("")` 는 정상. 진단 "Empty source file" 을 돌려준다.
- `akkado::compile("sine(440) |> out(%)")` 는 `std::bad_alloc` 을 던진다.
- 그때 요구한 단일 할당 크기: `72621737992257591` 바이트 = `0x0102011600000037` ≈ 66 PB.
  하위 32비트 `0x37`(=55)만 유효하고 **상위 32비트는 인접 메모리**다.
- Debug 라이브러리(`/Od`)에서도 같은 값이 나온다. 옵티마이저 문제가 아니다.

64비트 `size_t` 에 32비트 값을 상위 비트 없이 넣는 곳이 있어, MSVC에서는 그 뒤 4바이트
가 이웃 필드(1, 2, 1, 22 같은 값)를 읽는다. clang-cl로 빌드하면 문제가 사라진다.
**프런트엔드를 갈아 끼운 것이고, nkido 소스는 고치지 않았다.**

### 3-2. `CEDAR_ENABLE_FILE_IO=OFF` 는 링크가 깨진다

HTTP 로딩을 없애려고 이 옵션을 끄면 `cedar::io` 네 파일이 빌드에서 빠진다. 그런데
`tools/nkido/asset_loader.cpp` 는 `cedar::HttpHandler` 를 무조건 참조해서
`LNK1120` 이 난다. 그래서 OpenSSL 을 설치해 이 옵션을 **켜 둔다.**

### 3-3. CMake 기본 플래그를 지우면 안 된다

`CMAKE_CXX_FLAGS` 에 `/utf-8` 을 붙이려고 덮어쓰면 `/EHsc` 가 같이 사라진다.
그러면 예외가 스택을 타고 나가지 못하고 프로세스가 죽는다. 기본값
`/DWIN32 /D_WINDOWS /W3 /GR /EHsc` 를 명시적으로 다시 넣는다.

### 3-4. `/utf-8` 와 CRLF

nkido 소스에는 UTF-8 em-dash 가 들어 있다. 한국어 코드 페이지(949)로 읽으면
`mini_lexer.cpp` 가 깨진다. `/utf-8` 가 필수다. `core.autocrlf=true` 로 체크아웃하면
소스 전체가 CRLF 가 되는데, 이 저장소도 `.gitattributes` 로 LF 고정에 신경을 쓴
프로젝트다. 빌드 전에 `core.autocrlf false` 로 다시 받는다.

### 3-5. clang-cl specifics

- clang-cl 은 예외가 꺼진 상태로 시작한다. `/EHsc` 를 명시하지 않으면 rtmidi 가
  `cannot use 'try' with exceptions disabled` 로 죽는다.
- SDL2 의 `_m_prefetch` 재정의가 clang builtin 과 충돌한다.
  `/D__PRFCHWINTRIN_H` 를 주면 SDL 이 그 정의를 건너뛴다.
- CMake/Ninja가 `build.ninja` 를 못 갱신했다는 `failed recompaction: Permission denied`
  가 뜨면 이전 실행이 남긴 잠금이다. `build-clang` 를 지우고 다시 configure 한다.

---

## 4. 실행할 명령

### 4.1 전체

```powershell
cd C:\projects\TINProject
.\tools\nkido_pipeline\build_audio.ps1 -CheckFirst
```

`-CheckFirst` 는 렌더 전에 `nkido check` 를 패치마다 한 번씩 돌린다. 문법이
확정된 지금은 항상 붙이는 게 맞다. (이 옵션은 이번에 처음 실제로 돌렸고,
그 전까지 스크립트 안에서 `check` 와 `render` 가 한 줄로 이어 붙는 버그가 있었다.
고쳤다.)

| 옵션 | 뜻 |
|---|---|
| `-DryRun` | 명령만 찍는다. nkido·python 이 없어도 된다. 디렉터리도 안 만든다 |
| `-CheckFirst` | 렌더 전에 `nkido check` 를 한 번씩 돌린다 |
| `-SkipAmbient` | stem 을 건너뛴다 |
| `-NkidoPath <exe>` | nkido 실행 파일 경로 |
| `-OutputRoot <dir>` | WAV 목적지. 기본은 `tools/nkido_pipeline/build/wav` |
| `-ManifestPath <json>` | 다른 이벤트 매니페스트 |

종료 코드: `0` 전부 성공, `1` 한 건 이상 실패, `2` 실행 거부(라이선스 게이트,
매니페스트 오류, nkido/python 없음).

재실행해도 안전하다. **이 스크립트는 아무것도 지우지 않는다.** 만든 WAV만 덮어쓴다.
중간에 실패해서 다시 돌려도 앞선 성공분은 그대로 있다.

### 4.2 손으로 한 번

전체 파이프라인 전에 도구가 살아 있는지 한 사건만 렌더해 본다.

```powershell
nkido render tools/nkido_pipeline/patches/ambient/amb_air.akkado `
  -o tools/nkido_pipeline/build/wav/ambient/raw/amb_air.wav `
  --seconds 8.75 --rate 48000 --bpm 60 --no-default-bank
```

`--no-default-bank` 를 빼면 안 된다. 5절 참조.

---

## 5. 라이선스 규칙

이 파이프라인의 규칙은 스크립트가 강제한다.

1. **항상 `--no-default-bank`.** 모든 호출에 하드코딩돼 있다.
   기본 뱅크에는 **CC-BY-SA 4.0** 샘플과 **라이선스가 확인되지 않은** 샘플이 섞여 있다.
   `docs/STRUDEL_AUDIO.md` 6절 참조.
2. **매니페스트는 `"default_bank": false` 를 선언해야 한다.** 아니면 exit 2.
3. **`bank` 키는 어디에도 받지 않는다.** `file://`, `http(s)://`, `github:`,
   `bundled://` 전부 거부. 로컬 뱅크도 거부한다.
4. **`--sample` 은 우리 소유 파일만.** `samples/` 아래의 상대 경로여야 한다.
5. **코드를 복사하지 않는다.** nkido는 저장소 밖에서 외부 실행 파일로만 쓴다.
   산출물(WAV)은 우리 소유 자산이 된다.
6. **stem 은 렌더에 성공하면 `res_file` 로 복사되고, 파생 런타임 JSON이 함께
   갱신된다.** 이벤트는 `build/wav/` 에만 남는다. 저장소에 넣는 것은 Kit이 정한다.
7. **WAV를 넣으면 Godot이 `.import` 를 만든다.** 그 파일을 커밋한다.

새 사운드가 필요할 때: 해당 매니페스트에 항목을 추가하고 패치를 만든다.
`core/services/audio_service/` 쪽은 건드리지 않는다. Kit이 자기 표에 옮긴다.

---

## 6. 매니페스트 한 항목

이벤트(`audio_events.json`):

```json
{
  "id": "footstep_stone",
  "situation": "player footfall on dry stone",
  "description": "Dry tick, bright attack, no tail. Must not read as metal or wood.",
  "duration_seconds": 0.35,
  "bpm": 108,
  "akkado": "patches/kit_a_sideview_ecosystem/footstep_stone.akkado",
  "wav": "build/wav/kit_a_sideview_ecosystem/footstep_stone.wav",
  "res_file": "res://modules/sideview_ecosystem/audio/footstep_stone.wav",
  "max_polyphony": 3,
  "volume_db": -10.0,
  "min_interval_seconds": 0.09
}
```

| 키 | 읽는 곳 | 뜻 |
|---|---|---|
| `id` | Kit 매니페스트 | 접두사 없는 사건 이름 |
| `situation` | 사람 | 이 소리가 필요한 **상황**. 음악 용도가 아니다 |
| `description` | 사람 | 한 줄 의도. 나중에 다시 들을 때 기준이 된다 |
| `duration_seconds` | 스크립트 | `--seconds`. 게임 큐는 짧게. 3초를 넘기지 않는다 |
| `bpm` | 스크립트 | `--bpm`. 한 주기 안에서 여러 음이 있을 때만 의미 있다 |
| `akkado` | 스크립트 | 패치 경로, 이 폴더 기준 상대 |
| `wav` | 스크립트/사람 | **예상** 출력 경로, 이 폴더 기준 상대 |
| `res_file` | Kit | WAV를 복사할 `res://` 위치 |
| `max_polyphony` | `AudioEventPlayer` | 동시 발화 한도 |
| `volume_db` | `AudioEventPlayer` | 기본 감쇠 |
| `min_interval_seconds` | `AudioEventPlayer` | 안티스팸 간격 |
| `sample` (선택) | 스크립트 | `samples/` 아래 상대 경로 |

stem(`ambient.json`)은 여기에 `loop_seconds`, `fade_seconds`, `role` 이 더 있다.
`bus` 는 stem 단위로 준다. **여기서 버스를 추가하지 않는다.** 버스는
`Music / SFX / UI / Voice` 네 개가 전부다.

---

## 7. 다이나믹 앰비언스 — 왜 이 모양인가

긴 트랙 하나를 만들어서 두면, 장면이 바뀌어도 소리가 그 장면이 아니게 들린다.
그래서 앰비언스를 **stem 11개 + profile 7개**로 쪼갠다.

- **stem** 은 무한 루프 WAV 하나. 8초 또는 16초. 서로 다른 레이어만 담당한다
  (바람, 수면, 물기둥 압력, 공동 소리, 바닥 드론, 불안 트레이톤, 맥박, 음악상 3종).
- **profile** 은 stem마다 선형 게인 한 개씩인 한 행이다. `surface`(얼음 위) →
  `wade` → `column` → `deep` → `cavern` → `dread`(바닥), 그리고 `silence`.
- 게임은 profile을 부르고, 믹서는 게인을 크로스페이드한다.

이러면 **소리 파일은 상태를 몰라도 된다.** 같은 11개 파일이 물 위와 물 밑에서
다르게 들린다. 상태 추가가 새 렌더가 아니라 데이터 한 줄이다.
`tests/core/test_descent_exploration_ambient.gd` 가 프로필 간 게인 단조성과
stem/profile 집합 일치를 검사한다.

루프가 조용히 이어지려면 세 가지가 성립해야 한다.

1. **루프 길이가 신호 주기의 정배수.** 8초 stem은 LFO를 0.125/0.25/0.5 Hz 같은
   2의 분수배로만 쓴다. 16초는 0.0625배수. 그래야 크로스페이드가 남는 게 없다.
2. **크로스페이드.** nkido에는 루프 모드가 없다. `loop + fade + 0.25`초를 렌더하고
   `tool/loopify.py` 가 초과분을 자기 머리에 다시 접는다. 앞 0초는 본문의 자연스러운
   다음 샘플이 되므로 이어 붙이는 지점이 없다.
3. **재생기가 멈추지 않는다.** 믹서는 stem을 끄지 않고 −80 dB로만 내린다.
   멈췄다가 다시 틀면 위상이 튀어서 "같은 방"이 아니게 된다.

런타임 데이터는 `modules/descent_exploration/ambient_stems.json` 이고, 이건
`ambient.json` 에서 파생된다(수동 편집 금지). stem이 오디오에는 있는데 믹스에는
없는 상태가 원천적으로 생기지 않게 하려는 것이다.

### 7.1 Kit 쪽에서 남은 일

`modules/descent_exploration/audio_ambience.gd` (`DescentAmbience`)가 stem을
플레이하고 profile을 크로스페이드한다. 테스트는 이 파일과 생성된 JSON을 검사한다.
**`module.gd` 에는 아직 붙지 않았다.** 그 파일은 Kit 세션 소유라 건드리지 않았다.
붙이려면 `_ready` 에서 노드를 만들고 상태 변화 지점에서
`apply_profile(name, fade)` 를 부르면 된다. 그 6줄은 Kit 세션이 넣는다.

---

## 8. akkado 문법 — 실제 빌드로 확인한 것

이전 판은 전부 "미검증"이었다. clang-cl 빌드로 전부 확인했다.
`//` 주석은 되고 `/* */` 는 안 된다. 그 밖에 패치를 쓰면서 걸린 것:

| 규칙 | 근거 |
|---|---|
| `//` 줄 주석만 된다 | 전부 통과. `/* */` 는 파서 오류 |
| **변수는 단일 바인딩이다.** 같은 이름을 두 번 묶으면 `E150 Cannot reassign immutable variable`. `var` 로도 재대입 안 된다 | 9개 stem 을 고치며 확인 |
| `gate`, `left`, `right`, `room`, `chord`, `voicing` 은 예약 이름이라 못 쓴다. `fdn` 의 별명이 `room` 이고 `adsr`·`reverb` 계통 파라미터가 `gate` 다 | `E150` 로 드러남 |
| **`@.field` 는 파이프 안에서만 가능하다.** `wide * adsr(@.gate, ...)` 는 `E003 Hole used outside of pipe expression`. 감싸인 신호를 먼저 바인딩하고 그 다음에 pan 해야 한다 | `probe_melody.py` |
| `%` 는 `@` 와 같은 홀이다 | `out(%)` 가 통과 |
| `noise()` 는 백 노이즈, `noise(freq)` 는 sample-and-hold, 세 번째 인자가 시드 | 파라미터별 시드를 줘야 좌우가 다르다 |
| 주석에 적힌 `--seconds` 값과 실제 렌더 길이는 정확히 같지 않다. nkido는 블록 단위로 끊는다 | 8.5초 요청에 8.499초가 나였다 |
| **sample 이름 패턴은 조용히 무음이다.** `n"sh*8"` 는 라이선스 때문에 뱅크가 꺼져 있어 −60 dBFS | `probe_melody.py` 실측 |
| **`euclid(n, 8)` 을 곱셈에 쓰면 무음이다** | `probe_melody.py` 실측 |

### 8.1 스테레오 규칙 — 이게 이 저장소에서 가장 비싼 교훈이다

2026-09-28. 두 번 깨졌다가 세 번 고쳤다. 규칙은 아래 세 문장이 전부다.

> **1. 스테레오 차이는 첫 필터 이전에, 맨 소스에서만 만든다.**
> **2. 어떤 필터도 스테레로 플래그가 붙은 신호를 보면 안 된다.**
> **3. 두 모노 체인은 "컴파일이 접지 못하는 것"으로 달라야 한다.**

`cedar/include/cedar/opcodes/filters.hpp` 의 모든 필터가 두 채널을 쓰고,
입력에 `STEREO_INPUT` 플래그가 없으면 **같은 `input[i]`를 양쪽에 복제**한다.
즉 필터는 모노를 스테레로 만드는 지점이고, 필터를 통과한 신호는 복제쌍이다.
그 쌍을 다시 넓히거나(`stereo()`로 다시 감싸기) 두 인자로 나누거나
(한 바인딩을 양쪽에 `pan`) 차이가 돌아오지 않는다.

세 번째 문장이 없으면 1·2번을 지켜도 모노가 나온다. **두 체인이 컴파일 후
동일한 그래프로 접히면** 결과가 바이트 단위로 같아진다. 상수가 다른 컷오프
(420 대 428)는 접히고, `saw(55)` 대 `saw(55.6)` 같은 음파 detune과 `noise(0,0,101)`
대 `noise(0,0,977)` 같은 시드는 안 접힌다. `amb_drone` 은 이걸 배웠다.

21개 경우로 검증했다(`tool/probe_filter_width.py`, `probe_stereo_rule.py`).
필터 종류·컷오프가 오디오레이트인지·q·인스턴스 개수는 전부 무관했고,
오직 위 세 문장만 상관된다.

```akk
// 좁음: 상관도 1.000
air = noise() * 0.30 |> lp(@, breath, 1.6) |> hp(@, 120)
out(air.pan(0.15), air.pan(-0.15))

// 넓음: 상관도 -0.01
left_air  = noise(0, 0, 101) * 0.10 |> lp(@, breath, 0.9) |> hp(@, 90)
right_air = noise(0, 0, 977) * 0.10 |> lp(@, breath, 0.9) |> hp(@, 90)
out(stereo(left_air, right_air))
```

### 8.2 저역통과가 스테레로 경로에서 DC를 쌓는다

`probe_level.py` 가 "스테레로 필터가 22 dB 크다"고measures 했고, 한동안
원인이 불명으로 남았다. **틀렸다.** DC를 재서 수치가 뒤집혔다.

| case | peak | RMS | **DC offset** |
|---|---|---|---|
| `d` 모노 사인 | −27.9 | −32.7 | **0.00000** |
| `g` `stereo(tri...) │> lp` | −0.9 | −6.9 | **0.44998** |
| `c` `stereo(mel...) │> lp │> reverb` | −0.9 | −9.9 | **0.22513** |
| `j` `stereo(noise) │> lp` | −5.2 | −22.5 | 0.00016 |
| `stereo → lp → hp` (하이패스 추가) | **−29.6** | **−49.4** | — |
| 모노 체인 → 필터 → `stereo` (규칙) | −29.6 | −46.4 | — |

읽히는 것:

1. `stereo()` 자체는 레벨을 바꾸지 않는다. `stereo(x,x)` 가 `out(x)` 와 소수점까지
   같고, 레벨을 절반으로 하면 정확히 −6 dB 간격이다.
2. **저역통과가 스테레로 플래그가 붙은 신호를 보면 최저역대(DC 포함)에 에너지가
   모노 경로보다 훨씬 많이 쌓인다.** `tri` 의 평균 0.5 가 DC로 증폭돼 0.45 가
   된 것이 1·2번이고, `j` 는 저역대 전체다. 결과는 마스터 soft clip(−0.9)에
   걸린다. `freeverb` 이 그 오프셋을 더 증폭한다(실측 DC −0.57).
3. **뒤에 하이패스를 하나 두면 사라진다.** 그래서 `stereo → lp → hp` 는 멀쩡하다.

소스에도 이 버그의 위치가 보인다. 필터 본체에 DC hacks 가 박혀 있다.

```cpp
float v3 = x - (state.ic2eq[ch] + DENORMAL_DC);
```

`DENORMAL_DC` 를 빼는 방식이 스테레오 경로에서 상쇄되지 않는 것으로 보인다.
**이건 여전히 upstream 이슈다.** 우리는 1·2·3번 규칙으로 피하고 있고, 규칙을
기억할 필요 없이 지키기만 하면 된다.

### 8.3 `saw()` 는 이미 0-mean 이다

**두 번 틀렸다.** `saw()` 에서 0.5를 빼 DC를 잡으려 했고, 게이트가 DC −0.71을
만들어 되돌렸다. **그 다음 라운드에 같은 수정을 다시 했다.** 게이트가
DC −0.574 로 다시 잡아냈다. `freeverb` 이 오프셋을 증폭하기 때문에 두 번째에는
더 심했다.

`saw()` 는 이미 0-mean 이다. 0.5를 빼지 말 것. `bgm_dread` 의 잔여 DC
0.00208 은 이쪽이 아니라 체인 어딘가의 다른 원인이다.

---

## 9. 객관 게이트 — `tool/analyze_audio.py`

렌더가 성공하는 것과 렌더가 옳은 것은 다르다. 패치를 쓰는 사람과 들어야 하는
사람이 다르고, 측정 가능한 것은 측정기가 본다.

| 측정 | 근거 |
|---|---|
| integrated LUFS | ITU-R BS.1770-4 K-weighting, 400 ms 블록 75% 중첩, 절대 −70 / 상대 −10 게이팅. **채널 RMS 는 합산한다**(평균하면 스테레오가 3 dB씩 낮게 읽힌다) |
| true peak | 4배 오버샘플, windowed sinc |
| 클리핑 샘플 수 | |
| DC offset | |
| 옥타브 밴드 밸런스, 20–40 Hz 과잉 | |
| **채널 상관도** | 1.000 = 모노, 0 근처 = 정상 전폭. 스테레오가 실제로 벌어졌는지 |
| **루프 랩 불연속** | 랩 지점 도약이 표본 기울기의 몇 배인지 + 그 지점 고주파가 전체보다 몇 dB 밝은지 |
| mix 합성 후 LUFS / true peak | 프로필의 레이어를 실제로 합산해서 잰다 |

`--selftest` 가 있다. 답이 이미 아는 기준 신호 6개(정상 / 랩 클릭 / 하드 클리핑 /
저역 럼블 / 과도한 스테레오 폭 / 기준 사인)를 만들어 **정확히 그 결함만** 잡는지
확인한다. 게이트를 아무도 검증하지 않은 게이트로 두지 않기 위해서다.

기준은 `analysis_targets.json` 에 있다. **키가 없으면 그 항목은 켜져 있는 것으로
본다** — 빠진 필드가 조용히 완화되면 아무것도 안 막는 게이트가 되니까.
`open_findings` 는 **래칫이지 스위치가 아니다.** 이미 확인된 미해결 항목은 `KNOWN`
으로 계속 출력되고 리포트에도 남지만 빌드를 막지 않는다. **새 실패만 막는다.**
해결되면 지우는 대신 `resolved_findings` 로 옮긴다.

`-SkipAnalysis` 로 건너뛸 수 있다. 그러면 게이트가 없는 빌드가 된다.

---

## 10. NOT VERIFIED

1. **소리가 좋은지는 미판정이다.** 렌더 성공은 좋은 소리가 아니다.
   프로필 간 밸런스, stem 간 위상, 실제 장면에서의 존재감은 사람이 들어야 한다.
   Kit 수동 플레이 검수에서 처음으로 듣는다.
2. **stem 프로필의 게인 값은 추측이다.** 물 위에 바람이 우세하다는 직관으로
   0..1 을 채웠다. 귀로 고쳐야 한다.
3. **`bgm_dread` DC 0.00208 의 근원은 미확정.** `saw` 는 이미 0-mean이라 0.5를 빼는
   시도는 DC −0.71을 만들어 되돌렸다. 잔여가 어디서 오는지는 모른다.
4. **`bgm_swell` true peak −0.94** (한계 −1.0). 경미하다.
5. **43개 이벤트는 리포지토리에 없다.** `build/wav/` 에만 렌더된다.
   기존 `tests/core/test_descent_exploration_audio.gd` 가 그 상태를 pending 으로
   처리한다. 이벤트를 넣을지는 Kit이 정한다.
6. **MusicSpec 컴파일러는 막혀 있다.** 사양→`.akkado` 변환기는 있고 문법 제약은
   다 확인했다(STATUS 2·6절). 레이어 레시피가 8.2의 +22 dB 때문에 아직 안전하지 않다.
7. **MSVC 이외 툴체인 미검증.** clang-cl만 확인했다. MSVC는 3-1 때문에 못 쓴다.
8. **nkido 버전 고정.** `VERSION` 은 0.4.9. 업그레이드하면 3-1이 고쳐졌는지부터
   확인한다.

