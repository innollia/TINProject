# AudioService — 상황별 이벤트 재생

여기 있는 것:

| 파일 | 역할 |
|---|---|
| `audio_service.gd` | 기존 서비스. 버스 4개 생성, `play_music` / `set_volume`. **수정하지 않는다.** |
| `audio_manifest.gd` | C2 표의 스키마. `AudioManifest` |
| `audio_manifest_event.gd` | 표 한 줄. `AudioManifestEvent` |
| `audio_event_player.gd` | 풀 기반 이벤트 재생기. `AudioEventPlayer` |

버스는 `Music`, `SFX`, `UI`, `Voice`뿐이다. 여기서 버스를 추가하지 않는다.
`AudioManifest.ALLOWED_BUSES`는 `SettingsService.BUSES`에서 `Master`를 뺀 것과 정확히 같다.

## 1. Kit이 만들어야 하는 파일

Kit은 자기 소유 폴더 아래에 **딱 하나**, 오디오 이벤트 표를 만든다.

```
modules/<kit_id>/audio_events.tres
```

`Resource` = `AudioManifest`. 인스펙터에서 `id_prefix` 와 `events` 를 채운다.
`id_prefix` 는 Kit 이름의 축약형이다. 서로 다른 Kit의 id가 충돌하지 않게 하는 유일한 방법이다.

`AudioManifestEvent` 필드:

| 필드 | 타입 | 뜻 |
|---|---|---|
| `id` | `StringName` | Kit 안에서 유일한 사건 이름. 접두사 없이 쓴다 |
| `file` | `String` | `res://` 로 시작하는 오디오 파일 경로 |
| `bus` | `StringName` | `Music` / `SFX` / `UI` / `Voice` 중 하나 |
| `max_polyphony` | `int` | 이 사건이 동시에 울리는 최대 개수. 1 이상 |
| `volume_db` | `float` | 이 사건의 기본 감쇠(dB) |
| `min_interval_seconds` | `float` | 같은 사건이 이 시간 안에 다시 울리지 않는다. 0이면 없음 |

사건 없는 Kit은 이 파일을 만들지 않는다. 이벤트를 추가할 때 만든다.

## 2. `_ready` 에서 부르는 것

Kit은 노드를 직접 만들고, 의존성은 명시적으로 주입한다.
`/root` 탐색, 서비스 로케이터, `get_tree()` 는 쓰지 않는다.

```gdscript
var _audio: AudioEventPlayer

func _ready() -> void:
	_audio = AudioEventPlayer.new()
	_audio.name = "AudioEventPlayer"
	add_child(_audio)
	var manifest: AudioManifest = load("res://modules/<kit_id>/audio_events.tres")
	_audio.setup(manifest)
```

`setup(manifest)` 이 곧 전부다. 두 번째 인자, 세 번째 인자는 선택이다.

- `setup(manifest, settings, audio)` — 버스 볼륨을 설정에 영속시키고 AudioServer 에 즉시 반영하고 싶을 때
- `setup(manifest)` — 재생만 필요할 때

`setup` 은 `OK` 를 반환한다. 개별 이벤트의 파일이 없으면 그 사건만 등록되지 않고
`get_setup_errors()` 로 문자열을 읽는다. **매니페스트 구조 오류**(잘못된 버스,
`max_polyphony` 0 이하, 빈 `id_prefix`, 파싱 실패)는 `push_error` 로 보고된다.
오디오가 하나 없어도 나머지 Kit은 계속 놀아야 하기 때문이다.

## 3. 재생

```gdscript
_audio.play(&"footstep_wet")
_audio.play(&"footstep_wet", 0.08, 0.9)   # pitch_variation, volume_scale
```

- id는 접두사 없이(`footstep_wet`) 붙여도 되고, 붙여서(`eco_footstep_wet`) 부를 수도 있다.
- `pitch_variation` 은 0이면 고정, 0보다 크면 ± 비율로 랜덤 흔들림. 발소리 계열에 쓴다.
- 반환값이 `false` 면 재생되지 않았다. `event_rejected` 신호로 이유가 온다
  (`unknown_event` / `cooldown` / `no_voice`).

### 음성 풀과 도둑질

- `AudioEventPlayer` 는 `AudioStreamPlayer` 를 `_ready` 에서 `voice_pool_size` 개만 만든다.
  이후에는 노드를 더 만들지 않는다.
- 한 사건은 `max_polyphony` 개보다 많은 음성을 붙들지 않는다. 한도를 넘으면
  그 사건의 **가장 오래된 음성**을 가져간다.
- 그래도 풀이 다 차고 새 사건이 오면, 전체 풀에서 **가장 오래된 음성**을 가져간다.
  아무것도 재생 중이 아니면 빈 음성을 쓴다.
- `set_voice_pool_size(n)` 으로 크기를 바꾼다. `setup` 전에 부르는 걸 권한다.

### 안티스팸

`max(기본 min_interval_seconds, 사건의 min_interval_seconds)` 안에서 같은 사건은 재발화하지 않는다.
`event_rejected(REASON_COOLDOWN)` 으로 걸러진 걸음이 쓴다.
기본값 0이므로, 걸음처럼 겹쳐도 되는 사건은 0으로 두고 총알·피격처럼 필요한 사건만 값을 넣는다.

## 4. 버스 볼륨

```gdscript
_audio.set_bus_volume_db(&"SFX", -6.0)
```

- `SettingsService.BUSES` 밖 버스면 `ERR_INVALID_PARAMETER`.
- dB → 선형 변환 후 `SettingsService.set_volume` 과 `AudioService.set_volume` 에 넘긴다.
  그래야 **설정 저장(`user://settings.cfg`)과 AudioServer 가 같이** 움직인다.
- 이 경로는 감쇠만 다룬다. 선형 모델이 0..1 이라 0 dB 위로 올릴 수 없다.

## 5. 코드로 표를 만들기

`.tres` 대신 코드에서 만들 수도 있다. 같은 스키마를 쓴다.

```gdscript
var manifest := AudioManifest.new()
manifest.id_prefix = &"eco"
var item := AudioManifestEvent.new()
item.id = &"footstep_wet"
item.file = "res://modules/sideview_ecosystem/audio/footstep_wet.wav"
item.bus = &"SFX"
item.max_polyphony = 3
item.volume_db = -8.0
item.min_interval_seconds = 0.12
manifest.events.append(item)
_audio.setup(manifest)
```

검증은 언제든 직접 부를 수 있다.

```gdscript
for problem: String in manifest.validate():
	push_error(problem)
```

`validate()` 가 돌려주는 문자열은 사람이 읽는 형태다.

- `event 'x': missing 'file'`
- `event 'x': file not found 'res://…'`
- `event 'x': bus 'Nope' is not one of Music, SFX, UI, Voice`
- `event 'x': max_polyphony must be >= 1, got 0`
- `event 'x': duplicate id`
- `manifest: missing 'id_prefix'`

파일 경로와 WAV 자체는 `tools/nkido_pipeline/` 이 만든다. 그 절차는
`tools/nkido_pipeline/README.md` 에 있다.
