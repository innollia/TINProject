# 신규 세 Kit 공통 시스템 검수

기준은 [이번 사용자 요구사항](USER_REQUIREMENTS.md) 2절과 [3-Kit 라운드 계획](../../research/round_2026_09_26/ROUND_PLAN.md)이다. 범위는 Rain World / Mosa Lina / Swallow the Sea 계열 세 Kit의 공통 절차 비주얼·오디오이며, Stone Story나 BLACK SOULS 2에 이 공유 구현 사용을 강제하지 않는다. nkido 확정 및 병렬 제작 방향은 유지한다.

- 최종 근거 재확인: **2026-09-26 16:08:47 +09:00 (Asia/Seoul)**.
- HEAD: `bf3d76415930a220325960376d798a840389a6ab`.
- 방식: 정적 코드·문서 확인, 파일 존재 확인, 생성하지 않는 `-DryRun -CheckFirst` 실행. Godot 자동 검증·실행·시각 검수, 실제 nkido 실행·렌더·청취는 **미수행**이다.
- 주요 공통 구현은 현재 미추적 파일이다. HEAD만으로 재현할 수 없어 아래 SHA256을 함께 기록했다. 병렬 작업 중인 스냅샷이며 미구현을 완료 후 회귀로 판정하지 않는다.

## S1. [P1 · 확인된 명령 구성 결함] CheckFirst가 검사와 렌더를 한 호출로 합친다

**요구/근거:** [build_audio.ps1](../../../tools/nkido_pipeline/build_audio.ps1) 24–26행과 [파이프라인 README](../../../tools/nkido_pipeline/README.md) 92–93행은 패치 검사 후 렌더를 약속한다. 실제 스크립트 181–185행은 같은 인자 배열에 `check <patch>`와 `render <patch> ...`를 연이어 추가하고, 207행에서 한 번 실행한다.

**재현/영향:** `tools/nkido_pipeline/build_audio.ps1 -DryRun -CheckFirst`에서 다음 명령이 출력됐다. 경로만 줄여 표기했다.

```text
nkido check .../footstep_stone.akkado render .../footstep_stone.akkado -o .../footstep_stone.wav --seconds 0.35 --rate 48000 --bpm 108 --no-default-bank
```

검사 성공 뒤 별도 렌더 호출로 이어지는 흐름이 구성되지 않는다. **DryRun으로 인자 조립을 확인했으며, 실제 nkido의 오류 문구·종료 코드는 확인하지 않았다.**

**조치:** 검사와 렌더를 분리 호출하고 검사 실패 시 해당 이벤트의 렌더를 생략한다.

**닫힘 조건:** 실제 nkido에서 정상 패치는 검사 후 WAV 생성, 비정상 패치는 검사 실패 후 렌더 생략을 확인한다. DryRun 종료 코드 0만으로 닫지 않는다.

## S2. [P1 · 알려진 wave 1 미구현] 스프라이트 합성과 리그 동작이 스텁이다

**요구:** 사용자 요구사항 2절의 이미지·스프라이트 절차 생성, 절차 애니메이션, 배경 물리·말랑한 움직임. 라운드 계획 40–68행은 공통 API와 스텁 선행을 정한다.

**근거/영향:** 다음은 코드에 명시된 wave 1 스텁이며 새 회귀가 아니다.

| 근거 | 현재 결과 |
|---|---|
| [procedural.gd](../../../core/procedural/procedural.gd) 41–80행 | `build_sprite`, `render_frame`, `make_rig`, `make_backdrop`가 오류 출력 후 `null` 반환 |
| [body_part.gd](../../../core/procedural/sprite/body_part.gd) 164–172행 | `bounds`, `draw` 미구현 |
| [creature_builder.gd](../../../core/procedural/sprite/creature_builder.gd) 81–95행 | 합성 캔버스는 1×1, 윤곽은 빈 배열, 텍스처는 `null` |
| [squish_rig.gd](../../../core/procedural/anim/squish_rig.gd) 108–119행 | `step`, `disturb`, `draw` 미구현 |

시그니처를 소비하는 병렬 코딩은 가능하지만 이 경로로 실제 스프라이트·신체 애니메이션을 얻을 수 없다. `CreatureBuilder` 직접 사용도 합성 스텁을 우회하지 못한다. 반면 [deform_field.gd](../../../core/procedural/anim/deform_field.gd) 94–106행과 [backdrop_dynamics.gd](../../../core/procedural/anim/backdrop_dynamics.gd) 99–111행에는 스프링·노이즈 동작 구현이 있다. 배경 물리 전체가 미구현이라는 판정은 하지 않는다.

**조치:** 동결한 API의 합성·리그 내부를 구현하고 세 Kit 표현층에서 공통 결과를 소비하도록 연결한다.

**닫힘 조건:** 실제 Kit의 authored spec에서 비어 있지 않은 스프라이트가 나오고, 계획한 착지·충격·바람 반응과 배경 변형이 실제 게임 화면에 적용된다. API 존재와 실제 화면 사용 증거를 구분한다.

## S3. [P1 · 작업 중 미구현/미검증] 오디오 초안은 있으나 생성물과 소비 경로가 없다

**요구:** 사용자 요구사항 2절 및 라운드 계획 71–86, 117–126행의 nkido 상황별 자산 생성과 실제 Kit 상황 연결.

**근거:** [파이프라인 README](../../../tools/nkido_pipeline/README.md) 159–179행은 패치 문법·실제 렌더·Godot 재생을 미검증으로 명시한다. [audio_events.json](../../../tools/nkido_pipeline/audio_events.json)의 각 `wav` 및 `res_file`에 파일 존재 검사를 수행했다.

| 범위 / 매니페스트 행 | 이벤트 초안 | 생성 경로 WAV | 런타임 경로 WAV |
|---|---:|---:|---:|
| Kit A / 22–238행 | 16 | 0 | 0 |
| Kit B / 240–417행 | 13 | 0 | 0 |
| Kit C / 419–544행 | 9 | 0 | 0 |
| 공통 UI / 546–619행 | 5 | 0 | 0 |

`C:\projects\_tools\nkido` 및 예상 실행파일 경로가 없고 PATH에서도 nkido를 찾지 못했다. 재확인 당시 `modules/sideview_ecosystem`, `modules/physics_puzzle_platformer`, `modules/descent_exploration` 폴더 자체가 없었으며 실제 모듈의 재생기 소비 경로도 없었다. 없는 경로는 링크로 만들지 않았다.

[audio_event_player.gd](../../../core/services/audio_service/audio_event_player.gd) 59–65, 85–88행은 실제 `AudioStream` 로드 성공분만 재생한다. 재생기 구현은 있지만 신규 Kit에 전달된 소리 자산은 아직 없다. 현재 43개 초안이 최종 게임의 모든 필요한 상황을 덮는지는 Kit 구현 부재로 미판정이다.

**조치:** nkido에서 패치 검사·렌더를 수행해 WAV를 지정 런타임 경로에 배치하고, Kit의 이벤트 표와 실제 상황 호출을 연결한다.

**닫힘 조건:** 최종 Kit의 필요한 상황 목록과 이벤트 표를 대조하고 해당 상황에서 생성된 소리가 재생됨을 확인한다. 패치 수·DryRun 성공을 자산 생성이나 청취 완료로 세지 않는다. 이전 [Strudel 조사](../../STRUDEL_AUDIO.md)는 nkido 확정을 되돌리는 근거로 삼지 않는다.

## 주요 근거 SHA256

아래 파일은 최종 재확인 때 최초 검수와 같은 내용이었다.

| 파일 | SHA256 |
|---|---|
| `core/procedural/procedural.gd` | `7331B023FB157923C0B5524D70A92CD6FDE66AE4161D03A9CDEBE3FE0643E1EC` |
| `core/procedural/sprite/body_part.gd` | `0AA8B2696644E4D951BD6DF4DAD117797036E514F047C2682790D760F050EB20` |
| `core/procedural/sprite/creature_builder.gd` | `A97F6C12CE05C30E35417127F42B40E8F57E8649C3B7891BBBBDBCEC86CB6E19` |
| `core/procedural/anim/squish_rig.gd` | `614B7709718AAB2517484A77A64838E3845567A0FCE9137BCCA70B412967B06D` |
| `tools/nkido_pipeline/audio_events.json` | `EEC84F3978478858E7876A20656DBF3A0FA18AEF0161F34B986D509450A4A394` |
| `tools/nkido_pipeline/build_audio.ps1` | `3DD3089ED440987D98AA8972533D6FEE653A92B93ACDE5224F327FA90DE5DAE5` |
| `tools/nkido_pipeline/README.md` | `BC3AD93C8B632804DD17F9D793D2E40EC52FBE465FEECFDA0BD67745243AF146` |
| `core/services/audio_service/audio_event_player.gd` | `FE2C0855019801390FCAB5E77A2E3985D3D3FD05AF6DCC42469F1756888E24ED` |
| `docs/research/round_2026_09_26/ROUND_PLAN.md` | `95E3E8F79B7EABB9DDFFE2C20A991A91E0078DB08C4DF4CB6D3391E94B733145` |
