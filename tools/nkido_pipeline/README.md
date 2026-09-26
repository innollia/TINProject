# nkido 오디오 파이프라인 — 운영 안내

상황별로 필요한 사운드를 **오프라인 렌더**로 만들어 WAV로 뽑는다.
이미지 0개 파이프라인의 오디오 절반이다. 즉 이 파이프라인도 외부 자산을 가져오지 않는다.

- 도구: **nkido** (MIT), `https://github.com/mlaass/nkido`
- 계약: `docs/research/round_2026_09_26/ROUND_PLAN.md` 6절, C2절
- 재생 쪽 계약: `core/services/audio_service/README.md`

## 1. 폴더 구조

```
tools/nkido_pipeline/
  README.md              이 문서
  audio_events.json      유일한 기계 입력. 상황 이벤트 목록 43개
  build_audio.ps1        매니페스트를 읽어 nkido render 를 돌리고 PASS/FAIL 을 낸다
  events/README.md       상황 → 사건 매핑 읽기 도우미. 기계는 읽지 않는다
  patches/
    kit_a_sideview_ecosystem/           16개
    kit_b_physics_puzzle_platformer/    13개
    kit_c_descent_exploration/           9개
    shared_ui/                           5개
  build/wav/            렌더 결과. 스크립트가 만든다. 커밋 대상 아님
  samples/              우리 소유 샘플만 여기에 둔다. 현재 비어 있음
```

`audio_events.json` 하나가 유일한 정본이다. `events/README.md`는 사람이 읽는 도우미일 뿐이고
어떤 값도 두 곳에 쓰지 않는다. 패치와 WAV 경로는 전부 매니페스트가 가리킨다.

## 2. 선행 조건

이 저장소에는 nkido가 없다. 외부 도구다. TINProject 저장소에 넣지 않는다.

| 항목 | 필요한 것 |
|---|---|
| git | 클론용 |
| C++ 툴체인 | cmake, MSVC(via Visual Studio Build Tools), ninja — **이 PC에는 없음이 기록돼 있다** |
| 라이선스 | MIT. 코드를 복사하지 않는다. 외부 바이너리로만 실행한다 |
| 네트워크 | 렌더 단계에 필요 없다. `--bank`, `--sample` 원본 URL 을 쓰지 않으므로 |

설치:

```powershell
New-Item -ItemType Directory -Path "C:\projects\_tools" -Force | Out-Null
git clone --depth 1 --single-branch https://github.com/mlaass/nkido "C:\projects\_tools\nkido"
```

그 다음 **빌드 명령은 클론한 저장소의 문서를 그대로 따른다.** 이 문서는 빌드 시스템
(cmdle / CMake / Makefile 중 무엇인지)을 확인하지 않았다. 지어내지 않는다.
빌드가 끝나면 실행 파일이 `C:\projects\_tools\nkido\build\nkido.exe` 에 있다는 전제로
동작하며, `build_audio.ps1` 이 그 경로와 PATH 를 순서대로 찾는다. 다른 위치면
`-NkidoPath` 를 준다.

확인:

```powershell
nkido --help
```

## 3. 실행할 명령

### 3.1 먼저 이것을 손으로 한 번 돌린다

전체 파이프라인을 돌리기 전에, 한 사건만 실제로 렌더해서 도구가 살아 있는지 본다.

```powershell
nkido render tools/nkido_pipeline/patches/kit_a_sideview_ecosystem/footstep_stone.akkado -o tools/nkido_pipeline/build/wav/kit_a_sideview_ecosystem/footstep_stone.wav --seconds 0.35 --rate 48000 --bpm 108 --no-default-bank
```

`--no-default-bank` 를 빼면 안 된다. 7절 참조.

### 3.2 문법 확인

`.akkado` 는 전부 초안이다. 실제 빌드에 대조해 본 적이 없다.
먼저 구문만 확인한다.

```powershell
nkido check tools/nkido_pipeline/patches/kit_c_descent_exploration/ending_a.akkado
```

### 3.3 전체

```powershell
cd C:\projects\TINProject
.\tools\nkido_pipeline\build_audio.ps1
```

옵션:

| 옵션 | 뜻 |
|---|---|
| `-DryRun` | 명령만 찍는다. nkido가 없어도 된다. 디렉터리도 안 만든다 |
| `-CheckFirst` | 렌더 전에 `nkido check` 를 한 번씩 돌린다. 문법이 확정된 뒤에 쓴다 |
| `-NkidoPath <exe>` | nkido 실행 파일 경로 |
| `-OutputRoot <dir>` | WAV 목적지. 기본은 `tools/nkido_pipeline/build/wav` |
| `-ManifestPath <json>` | 다른 매니페스트 |

종료 코드: `0` 전부 성공, `1` 한 건 이상 실패, `2` 실행 거부(라이선스 게이트, 매니페스트 오류, nkido 없음).

재실행해도 안전하다. **이 스크립트는 아무것도 지우지 않는다.** 만든 WAV만 덮어쓴다.
중간에 실패해서 다시 돌려도 앞선 성공분은 그대로 있다.

## 4. 라이선스 규칙

이 파이프라인의 규칙은 스크립트가 강제한다.

1. **항상 `--no-default-bank`.** 모든 호출에 하드코딩돼 있다.
   기본 뱅크에는 **CC-BY-SA 4.0** 샘플과 **라이선스가 확인되지 않은** 샘플이 섞여 있다.
   `docs/STRUDEL_AUDIO.md` 6절 참조.
2. **매니페스트는 `"default_bank": false` 를 선언해야 한다.** 아니면 스크립트가 거부한다(exit 2).
3. **`bank` 키는 어디에도 받지 않는다.** `file://`, `http(s)://`, `github:`, `bundled://`
   전부 거부. 로컬 뱅크도 거부한다.
4. **`--sample` 은 우리 소유 파일만.** `samples/` 아래의 상대 경로여야 한다.
   절대 경로, `://`, `github:` 로 시작하는 값은 exit 2 로 거부한다.
   샘플을 추가할 때는 출처와 라이선스를 `samples/README.md` 에 적는다.
5. **코드를 복사하지 않는다.** nkido는 저장소 밖에서 외부 실행 파일로만 쓴다.
   산출물(WAV)은 우리 소유 자산이 된다.
6. **WAV를 넣으면 Godot이 `.import` 를 만든다.** 그 파일을 커밋한다.

새 사운드가 필요할 때: `audio_events.json` 에 항목을 추가하고, `patches/<dir>/<id>.akkado` 를 만든다.
`core/services/audio_service/` 쪽은 건드리지 않는다. Kit이 자기 표에 옮긴다.

## 5. 매니페스트 한 항목

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
| `res_file` | Kit | WAV를 복사할 `res://` 위치. Kit의 `audio_events.tres` 와 같아야 한다 |
| `max_polyphony` | `AudioEventPlayer` | 동시 발화 한도 |
| `volume_db` | `AudioEventPlayer` | 기본 감쇠 |
| `min_interval_seconds` | `AudioEventPlayer` | 안티스팸 간격 |
| `sample` (선택) | 스크립트 | `samples/` 아래 상대 경로. 없으면 샘플 안 쓴다 |

`bus` 는 Kit 단위로 준다. `shared_ui` 만 `UI`, 나머지는 `SFX`.
**여기서 버스를 추가하지 않는다.** 버스는 `Music / SFX / UI / Voice` 네 개가 전부다.

## 6. NOT VERIFIED

아래는 이 문서를 쓴 시점에 확인되지 않았다. 확인 전 "만들었다"고 쓰지 않는다.

1. **모든 `.akkado` 패치가 미검증이다.** `//` 주석 문법조차 미확인이다.
   `nkido check` 가 주석에서 실패하면 `//` 줄을 지우고 다시 돌린다.
2. **조합이 미검증인 구성.** 검증된 예시는
   `sine(440) |> out(%)`, `n"c4 e4 g4" as e |> saw(e.freq) |> % * e.vel |> out(%)`,
   `n"c4 e4 g4 b4" |> tri(@.freq) * adsr(@.gate, 0.01, 0.1, 0.7, 0.2) |> out(%)`,
   `sample(trigger(2), 1.0, "bd") |> out(%)` 뿐이다.
   아래는 이 예시들에서 유도했지만 실제 빌드에 대조하지 않았다.
   - 대괄호 세분화 `n"[a3 a3 c4 a3]"` — `rain_onset`, `tool_use_scrape`, `breath_critical`
   - 화음 리터럴 `c"a2 c3 e3"` — `ending_a/b/c`
   - `sine(@.freq)` 형태 — `player_noticed`, `player_ignored`, `sleep`, `wake`, `portal_open`, `descent_deep`, `surface_return`, `rain_onset`, `level_start`
   - `tri(@.freq)` / `sine(@.freq)` 의 adsr 를 곱한 형태 전체
3. **nkido 빌드 시스템 미확인.** 클론 전제로만 경로를 가정했다.
4. **nkido의 16-bit PCM WAV 가 Godot 4.7.2 기본 임포트 설정으로 열리는지 미확인.**
5. **한 WAV가 버퍼 없이 리샘플 필요 없이 재생되는지 미확인.**
   48 kHz 출력이 프로젝트 설정과 맞는지 실행 후 확인한다.
6. **소리가 실제로 좋은지 미판정.** 렌더 성공은 좋은 소리가 아니다.
   Kit 수동 플레이 검수에서 처음으로 듣는다.
