# strudel 오디오 자산 파이프라인

적용 범위: TINProject의 이미지 0개 파이프라인에 대응하는 **오디오 자산 생성 도구** 사용법.
목적은 `strudel.cc`를 실행해 상황별 사운드 파일을 미리 만들고, 그 파일을 Godot 모듈에 넣는 것이다.

이 문서는 **도구 사용법과 검증된 사실만** 담는다. 어떤 사운드를 만드는지는 Kit 계획서가 정한다.

## 1. 로컬 설치 위치와 버전

| 항목 | 값 |
|---|---|
| 로컬 클론 | `C:\projects\_tools\strudel` |
| 저장소 | `https://codeberg.org/uzu/strudel` (strudel 공식 upstream. GitHub 이전본) |
| 클론 방식 | `git clone --depth 1 --single-branch` |
| 확인된 커밋 | `8f81463b9cb5ddd5f117ed7baef6a1fde9445dc2` (2026-08-19) |
| 작업 트리 크기 | 약 29.6 MB, 712 파일 |
| 패키지 수 | 33개 (`packages/`) |
| 라이선스 | **AGPL-3.0-or-later** |

클론은 저장소 밖에 둔다. TINProject 저장소 안에 넣지 않는다.

```powershell
New-Item -ItemType Directory -Path "C:\projects\_tools" -Force | Out-Null
git clone --depth 1 --single-branch https://codeberg.org/uzu/strudel "C:\projects\_tools\strudel"
```

업데이트가 필요할 때만 다시 받는다. 갱신하면 아래 "확인된 커밋"과 API 위치를 다시 확인한다.

## 2. 실행 환경

| 항목 | 상태 |
|---|---|
| git | 2.50.1.windows.1, 있음 |
| node | v24.19.0, 있음 |
| corepack | 0.35.0, 있음 |
| pnpm | **없음** |

strudel은 pnpm workspace 모노레포다(`engines.node >= 18`). REPL을 직접 띄우려면 pnpm이 필요하다.

```powershell
corepack enable pnpm
cd C:\projects\_tools\strudel
pnpm i
pnpm dev
```

REPL을 띄우는 일은 **상시 필요하지 않다.** 오프라인 렌더 API만 쓸 경우 이 경로를 건너뛸 수 있는지는 미검증이다(9절).

## 3. 검증된 오프라인 렌더 API

`packages/webaudio/webaudio.mjs`에 오프라인 렌더 함수가 실제로 존재한다.

```js
export async function renderPatternAudio(
  pattern, cps, begin, end, sampleRate, maxPolyphony, multiChannelOrbits, downloadName
)
```

위치: `packages/webaudio/webaudio.mjs:40`

동작:

1. 기존 오디오 컨텍스트를 닫는다.
2. `new OfflineAudioContext(2, ((end - begin) / cps) * sampleRate, sampleRate)` 로 교체한다.
3. 패턴을 렌더해 `AudioBuffer`를 얻는다.
4. `audioBufferToWav()` (같은 파일 `:180`) 로 WAV 인코딩한다.
5. `Blob` + `<a download>` 로 브라우저 다운로드한다.

WAV 형식 (`audioBufferToWav` / `encodeWAV`, 같은 파일 `:180`, `:199`):

- 기본 **16-bit PCM** 정수. `opt.float32 = true`면 32-bit float.
- 스테로 2ch면 인터리브. 그 외에는 채널 0만 사용.
- 샘플레이트는 인자의 `sampleRate`를 그대로 쓴다.

주의점:

- `document.createElement('a')` 를 쓰므로 **DOM이 필요하다.** 순수 Node 스크립트에서는 이 함수가 그대로 동작하지 않는다.
- 함수 진입 전에 오디오 컨텍스트가 존재해야 한다(`getAudioContext()` 후 `close()`).
- Firefox는 `OfflineAudioContext`의 `suspend`를 지원하지 않아 chunk 렌더가 불가능하다. 같은 파일의 주석에 명시돼 있다.

## 4. 자동화 경로 (설계됨, 미실행)

브라우저에는 DOM이 필요하므로, 렌더는 브라우저 안에서 돌아가고 파일만 밖으로 꺼내야 한다.

1. 로컬 HTTP 서버로 strudel 패키지를 또는 자체 페이지를 서빙한다.
2. `renderPatternAudio()` 를 부르는 페이지를 만든다.
3. Playwright로 페이지를 열고 다운로드 이벤트를 가로챈다.
4. 결과 WAV를 저장한다.

이 경로는 **설계만 된 상태이고 아직 실행 검증하지 않았다.** 9절의 미검증 항목을 먼저 해결해야 한다.

## 5. 라이선스 — 코드

strudel 코드는 **GNU AGPL v3**다 (`LICENSE`, `package.json`의 `license` 필드 양쪽 확인).

적용 규칙:

- TINProject 저장소에 strudel 코드, strudel 패키지 번들, 패치된 strudel 소스를 **복사하지 않는다.**
- strudel은 저장소 밖에서 외부 도구로만 실행한다.
- 외부 도구로 만든 **출력물(렌더된 WAV)**은 TINProject 자산이 된다. 코드를 링크하지 않으므로 TINProject 저장소 자체는 AGPL 대상이 아니다.
- 이 판단은 코드를 복사하지 않는다는 전제 위에서 성립한다. 나중에 strudel 코드를 가져오면 즉시 재검토한다.

## 6. 라이선스 — 기본 사운드 뱅크 (중대 리스크)

strudel의 기본 샘플은 실행 시 원격에서 내려받는다. 로컬 클론에 포함되지 않는다.

출처: `https://github.com/felixroos/dough-samples`
로딩 형태: `https://raw.githubusercontent.com/felixroos/dough-samples/main/<bank>.json`

| 뱅크 | 출처 | 라이선스 |
|---|---|---|
| `piano` | Salamander Grand Piano V3 (archive.org) | **CC-BY 3.0** — 저자 Alexander Holm, 출처 표기 필요 |
| `VCSL` | sgossner/VCSL | **CC0** — 제약 없음 |
| `mridangam` | Arthur Carabott 2022 / Harishankar V Menon | **CC-BY-SA 4.0** — 동일조건동일창조 |
| `Dirt-Samples` | tidalcycles/Dirt-Samples | **라이선스 명시 없음** — 원저작자 권리 그대로 |
| `tidal-drum-machines` | ritchse/tidal-drum-machines | **라이선스 명시 없음** — 원저작자 권리 그대로 |

결론:

- 기본 뱅크로 렌더한 WAV를 게임 자산으로 넣으면 **CC-BY-SA 전염과 무라이선스 샘플 문제가 그대로 따라온다.**
- 특히 `Dirt-Samples`와 `tidal-drum-machines`는 라이선스가 확인되지 않았다. 확인 전 사용 금지.
- 따라서 **기본 뱅크는 쓰지 않는다.** 이 프로젝트의 오디오는 자체 생성 샘플 뱅크만 쓴다(7절).

이 판단은 라이선스 확인이 아니라 리스크 회피다. 나중에 실제로(strudel 기본 뱅크로 렌더한 파일을 배포) 쓰게 되면 counsel 확인이 필요하다.

## 7. 권장 파이프라인

이미지가 "파일 0개, 코드로 생성"으로 정해졌으므로, 오디오도 같은 결론을 쓴다.

```
자체 코드 → 절차 생성 샘플 뱅크(우리 소유)  →  strudel(순서·합성 엔진)  →  WAV 파일  →  Godot
```

- 샘플 뱅크는 이미지 파이프라인과 같은 원칙으로, 직접 생성한다. 출처가 우리 코드다.
- strudel은 **시퀀싱/합성**만 맡는다. sampler가 자체 제공 샘플을 받을 수 있는지는 미검증이다(9절).
- 생성한 샘플과 WAV는 둘 다 프로젝트 소유 자산이 되므로 제3자 권리 문제가 없다.
- strudel이 없으면 strudel이 제공하던 역할(루프, 인덱스, 변형, 레이어)을 직접 코드로 만드는 것만 남는다.

## 8. Godot 쪽 접점

| 항목 | 경로 |
|---|---|
| 오디오 서비스 | `core/services/audio_service/audio_service.gd` |
| 버스 | `Music`, `SFX`, `UI`, `Voice` (모두 `Master`로 송신) |
| 설정 서비스 버스 목록 | `core/services/settings_service/settings_service.gd` |
| 저장 위치 | `user://settings.cfg` |
| 현재 저장소 내 오디오 파일 | **0개** (`.wav`/`.ogg`/`.mp3` 모두 없음) |

주의:

- 버스가 이미 4개로 정해져 있다. 새 버스를 추가하지 않는다.
- `AudioService`에는 `play_music` / `stop_music` / `set_volume` 만 있다. 상황별 SFX 재생은 **아직 없다.** 필요한 재생 정책은 Kit 계획서에서 정한다.
- WAV를 넣으면 Godot이 `.import`를 만든다. 저장소에 `.import`가 커밋되어 있으므로 그 파일도 함께 남겨야 한다.

## 9. NOT VERIFIED

아래는 아직 확인하지 않았다. 이 항목을 해결하기 전에는 "strudel로 오디오를 만들었다"고 쓰지 않는다.

1. `@strudel/web`가 `renderPatternAudio` 를 루트에서 export 하는지. 페이지에서 바로 쓸 수 있는 형태인지.
2. Node만으로 `OfflineAudioContext` 를 쓸 수 있는지. 불가능하면 브라우저 경로 확정.
3. Playwright로 다운로드 이벤트를 안정적으로 캡처할 수 있는지.
4. `samples()` 가 로컬 HTTP URL이나 `file:` 경로를 받는지. 자체 샘플 뱅크를 쓸 수 있는지의 핵심.
5. 프로젝트에 필요한 pnpm 버전. `package.json` 에 `packageManager` 필드가 없다(확인함). pnpm 9/10 어느 쪽인지 미확정.
6. `pnpm i` 가 Windows에서 통과하는지.
7. 절차 생성 샘플을 strudel에 넣을 때 샘플 포맷·길이·루프 지점 요구사항.
8. WAV 16-bit PCM을 Godot이 어떤 임포트 설정으로 받아야 하는지.

## 10. 다른 에이전트 주의사항

- **Codeberg 크롤링 금지.** `codeberg.org` 의 `robots.txt` 가 `/src/`, `/raw/`, `/commits/`, `/tags/` 등 경로를 자동 페치에 금지한다. 이 문서를 쓰면서 그 경로를 fetch하려 하면 403 또는 robots 차단이 난다. 문서는 `strudel.cc/learn` 와 npm 패키지 문서, 또는 로컬 클론을 읽는다.
- **AGPL 함정.** "strudel을 쓰면 우리 저장소가 AGPL이 된다"는 오해가 있다. 코드를 복사하지 않으면 해당 없다. 반대로 strudel 코드 조각을 붙여넣으면 그 순간의许可이 바뀐다.
- **샘플 뱅크 함정.** `samples()` 를 기본 뱅크 URL로 호출하면 제3자 샘플이 섞인다. 그러면 산출물의 권리가 곧 깨진다. 7절 파이프라인을 따른다.
- **pnpm 부재.** `pnpm` 명령이 없다. 설치 없이 REPL을 띄우려는 시도는 실패한다.
