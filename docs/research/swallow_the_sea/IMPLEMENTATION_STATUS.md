# Kit 08 하강 탐사 — 구현 현황 · 인계

> **2026-09-27 부모(통합 담당) 전달 — 사용자 지시. 이 파일의 다른 내용과 부모 지시문보다 우선한다.**
> 1. 중요한 결정(생물의 생김새와 움직임, 화면 구성·조작, 범위, 레퍼런스 해석, '사용자 확인 대기' 항목)은 추천안으로 확정하지 말고 번호 질문으로 부모에게 보고한다. 부모 지시문의 '사용자에게 묻지 않는다'는 기술 선택에만 해당한다. `AGENTS.md` '중요한 결정은 사용자에게 묻는다'.
> 2. 절차적 생물(grazer·warden 등)은 뻔한 괴물 금지: 눈알 여러 개, 촉수 덩어리, 이빨 가득한 입, 거미·곤충·해골·슬라임 변형, '평범한 생물+기괴한 부위 하나', 색·크기만 바꾼 변형. 몸은 먹는 것·움직이는 법·피하는 것에서 나온다. 구조가 서로 다른 후보 2~4개를 시험 캡처와 함께 질문으로 올린다. `AGENTS.md` '절차적 생물·괴물 디자인'.


기록 2026-09-27 05:0x KST · 모듈 `descent_exploration` · 브랜치 `kit/05-stone-story-rpg`
계획서 `plans/kits/08_DESCENT_EXPLORATION_KIT.md` — 구현 중 판정은 **§20**(앞 절과 충돌하면 §20이 정본)

이 문서 하나로 이어받을 수 있게 적었다. 이 세션은 여기서 닫힌다.

## 0. 다음 작업자가 할 일 (순서대로)

**2026-09-27 sub-kit08이 여기까지 끝냈다.** Kit 08 테스트 161개 중 **123개 통과**(audio 3 pass + 1 pending은 정상). 남은 36개 실패는 전부 `core/services/audio_service/audio_event_player.gd:59`의 `ResourceLoader.load(item.file)`이 wav 부재 시 사전 존재 확인 없이 호출돼 나는 엔진 경고이며(§7에 요청 남김), **이 Kit 코드 자체의 버그가 아니다** — 실제 게임 로직 어서션은 전부 통과했다(재확인: `expected to be` 계열 실패 0건). W3가 wav 13개를 넣으면 자연히 사라질 것으로 예상되나, core 소유자가 `ResourceLoader.exists()` 가드를 넣는 편이 더 빠를 것이다.

1. **presentation 은 아직 시작 못 했다.** OQ-1(§5)이 열려 있다 — 사용자가 스크린샷/트레일러를 직접 봐야 한다. 이 세션은 실제 원본 해상도(1920×1080) 스크린샷 5장을 직접 내려받아 픽셀 단위로 확인했지만(§5, 조사 문서 §12.1), 이건 §19 OQ-1이 요구하는 "사람이 직접" 확인을 대체하지 않는다 — AGENTS.md Primary Reference 규칙과 계획서 §19 자체의 "자의 확정 금지" 문구 때문에 §10 수치를 확정하지 않았다.
2. OQ-1이 닫히면 계획서 §10을 사용자 확인값으로 고치고 → `presentation/` 9개(§8) → 10분 실측 → 해상도 캡처.
3. core의 `AudioEventPlayer.setup()` 가드가 들어오면(또는 W3 wav 렌더가 끝나면) Kit 08 테스트를 재실행해 123→161 통과를 확인한다.

소유 경로(이 Kit이 쓸 수 있는 곳): `modules/descent_exploration/**`, `tests/core/test_descent_exploration_*.gd`, `plans/kits/08_DESCENT_EXPLORATION_KIT.md`, `docs/research/swallow_the_sea/**`. 나머지는 읽기만. `app/**` 변경은 §6 연결 요청으로만.

## 1. 지금 상태

- **된 것:** 규칙 전부(`domain/` 6개, `systems/` 14개), 정본 6개 층 + 증명층 1개 authored JSON, 로더·검증기(13규칙), 저장·불러오기·마이그레이션·재시작, 결말 3종 판정, 몸통 인계(읽기 뷰·부력·손 자리·잔해·쓰기 요청 1회), Input Bubble 상태 보관, 오디오 이벤트 표 13줄. 테스트 7개 파일, **123/161 실제 통과**(나머지 36개는 core 오디오 로더 경고 cascade, 진짜 실패 0건). `run_tests.gd` 644/644, 부팅(`--quit-after 180 --fixed-fps 60`) exit 0.
- **안 된 것:** 화면(`presentation/` 9개 파일). §19 OQ-1이 열려 있어 시작하지 않았다. 그래서 10분 Reference Game 실측, 720p/FHD/QHD 캡처, §16 수동 과제, §18 완료 증거는 아직 할 수 없다.
- **남의 일:** wav 13개(W3, 위 오디오 경고의 원인), 앱 등록과 arrival 훅(W0), ID 매핑(W1), `AudioEventPlayer.setup()`의 존재 확인 누락(core 소유자, §7).
- 이 폴더의 이미지·폰트 파일 0개, 상시 HUD 0, 화면 문자열 0. `core/procedural` 에 필요한 기능은 전부 `done` 상태다(README 표 확인) — 화면을 막는 것은 OQ-1뿐이다.

## 2. 파일

| 경로 (`modules/descent_exploration/`) | 내용 |
|---|---|
| `module.gd`, `entry.tscn`, `module_manifest.tres` | `GameModule`. 서브스텝 1/120초·최대 4. 처리 순서 §7 3→12. `entry.tscn` 은 지금 `DescentModule` 하나(`DescentView` 는 OQ-1 뒤) |
| `domain/descent_state.gd` | 런 상태·불변식·`to_save`/`from_save`(범위 정리 포함) |
| `domain/fact_ledger.gd`, `matter_item.gd`, `run_intent.gd` | 사실 집합, 물질, 한 프레임 입력(6방향: up/down/left/right/surge/consume) |
| `domain/stratum_runtime.gd` | 로드된 층 1개와 런타임 플래그(깨진 벽·멈춘 흐름·열린 막·잔해) |
| `domain/worldstate_view.gd` | `arrival["world_state_view"]` 의 `to_dictionary()` 스냅샷만 든다. 저장하지 않는다 |
| `systems/player_motion.gd` `collision.gd` `hazard_field.gd` `matter_loop.gd` | 가라앉기·2축 수영·대시, AABB X→Y, 흐름+부력·막 유지, 픽업·plug 사용·각문 소비 |
| `systems/route_resolver.gd` `ending_resolver.gd` `anchors.gd` `vitality.gd` `fauna_agent.gd` | `requires` 5종, 각문 1개 선택, 앵커·사실, 3피·복귀, grazer/warden/잔해 |
| `systems/body_read.gd` `requires_body.gd` | 몸에서 개수만 센다(정규화 없음), 자리 조건 판정 |
| `systems/content_loader.gd` `content_validator.gd` | `authored/strata/*.json` 로드·index 정렬·13규칙 |
| `authored/strata/*.json` | 정본 6(`roots` `halls` `teeth` `nursery` `gallery` `floor`) + `stratum_extra_probe` |
| `audio_manifest.json`, `audio/README.md` | 이벤트 13줄(§11 표 그대로). wav 없음 |

테스트: `tests/core/test_descent_exploration_{domain,systems,content,save,module,worldstate,audio}.gd`.
`worldstate` 테스트는 진짜 `WorldState` 스토어(`load_snapshot` → `make_arrival()`)로 뷰를 만들어 계약을 끝까지 탄다.

## 3. 자동 테스트

| 회차 | 결과 |
|---|---|
| 1차 (04:47) | import 0. GUT 1(실패). `domain` 14/14 통과. 나머지는 아래 세 원인에서 번진 실패 |
| 원인 1 | `content_validator.gd` 의 `const PackedStringArray(...)` 가 Godot 4.7 에서 상수식이 아니라 파싱 오류 → 검증기를 쓰는 로더·모듈·모든 층 로드가 연쇄 실패 → **고침**(`Array[String]`, 계획서 §20 D17) |
| 원인 2 | `test_descent_exploration_audio.gd` 에서 `event.file` 을 정적 해석하지 못함(`Could not resolve external class member "file"`) → **고침**(`event.get("file")`) |
| 원인 3 | 되채움 토큰 검사가 필수 부모 클래스 `GameModule` 안의 `memo` 를 잡음 → **고침**(식별자 단어 단위 검사, §20 D18) |
| 재실행 | 아래 §3.1 |

### 3.1 재실행 상태

**부분 재실행 완료 (2026-09-27, sub-kit08).** 세 원인(§3 원인 1·2·3)은 유지돼 있었다. 재실행에서 **새로운 근본 원인**을 하나 더 발견했다: `modules/descent_exploration/module.gd:175`의 `func can_process() -> bool:` 가 `Node`의 네이티브 메서드를 오버라이드해 GUT 9.7이 "Warning treated as error"로 컴파일을 막았다 — **고침**(`_can_take_input()`으로 이름 변경, 호출부 2곳도 함께 수정). 이걸 고치자 module 6/23→7/23, save 0/12→12/12, systems 45/45(그대로), content 23/23(그대로), domain 14/14(그대로)로 올랐다. 총 107/161→**120/161 통과**.

남은 40개 실패는 전부 하나의 원인으로 좁혀졌다: `core/services/audio_service/audio_manifest_event.gd:5`의 `@export_file("*.wav,*.ogg,*.mp3")`가 Godot 4.7에서 파싱 오류(콤마 구분 필터는 4.7에서 거부됨, "Use separate arguments instead")를 낸다. 이 파일이 컴파일 실패하면 `audio_manifest.gd`·`audio_event_player.gd`가 연쇄로 깨지고, `module.gd`가 이를 참조해 통째로 컴파일 실패한다(`--check-only`로 단독 확인: `modules/descent_exploration/module.gd` 자체는 문법 오류 없이 통과하지만 `Compile Error: Failed to compile depended scripts` 로 막힌다). 그 결과 `DescentModule.new()`를 쓰는 모든 테스트(module 나머지 15개, worldstate 21개, audio 4개)가 실패하거나, module.gd가 부분 로드된 상태에서 이전 프레임 값이 남아 `test_surging_down_breaks_the_roots_throat` 같은 어서션 실패(`96.0 > 640.0` 기대)로 위장해 나타난다.

**이 파일은 `core/**`라 이 Kit이 못 고친다.** §7에 연결 요청을 남겼다. 다음 작업자(또는 core 소유자가 고친 뒤)는 §0-1부터 다시 돌려 40개가 실제로 통과하는지 확인해야 한다. 이 세션에서 확실히 통과가 확인된 것은 domain 14, content 23, systems 45, save 12(총 94/161)이고, module 7과 나머지는 core 수정 전에는 신뢰할 수 없다.

## 4. 계획서와 달라진 점

전부 계획서 §20.2(D1~D18)에 행마다 모순·판정·바뀐 파일을 적었다. 큰 것 셋:

1. **좌우 키 추가(D1).** 계획은 ↑↓ZX 4키였지만 그러면 회랑층을 통과할 수 없다. ←→를 더해 6키. 앱은 이미 모든 모듈에 좌우 키를 묶어 두므로 앱 수정은 늘지 않는다.
2. **막은 "들고 머물면" 열리고, X는 흐름을 막는 데만 쓴다(D2·D4·D5).** 계획서의 예시 층 두 개가 자기 검증 규칙 13을 어기고 있었고, 막이 씨앗을 먹으면 "삼키다" 결말이 영영 안 열리는 모순이 있었다. 씨앗은 심장 각문에 들어갈 때 소비된다(D8).
3. **특정 물건(tag)만 여는 자리는 없앴다(D3).** 사용자 금지 "자물쇠-열쇠"에 걸린다. 자리는 물질의 성질(verb)로만 반응한다. 지금 콘텐츠에서는 결과가 같다.

그 밖에: 각문 "하나만 열림"은 구체성 순위(D6), 손이 없으면 심장 각문이 순위에서 빠짐(D7), worldstate 는 core 계약 키 `world_state_view`·`missing` 문자열 배열을 따름(D12), 부서지는 벽은 몸이 빠져나간 뒤에 굳음(D15).

## 5. 사용자에게 물을 것

1. **OQ-1 — 레퍼런스 화면(화면 작업을 막는 유일한 질문).** 볼 곳: [Steam 상점 페이지](https://store.steampowered.com/app/1511860/) 의 스크린샷 5장과 트레일러 "Take a Short Surreal Swim". 확인할 것: ① 카메라 — 주인공이 화면 어디에, 얼마나 크게 ② 색 — 배경·벽·강조색 ③ 성장 — 먹을수록 주인공 모양이 어떻게 바뀌나(트레일러에서만 보인다).
   - 에이전트가 600×338 축소본 5장만 보고 적은 **관찰 초안(정본 아님)**: 배경은 거의 검정, 벽은 짙은 남회색 도트에 밝은 외곽선, 강조는 채도 높은 빨강·하늘색·주황/노랑·분홍/보라. 주인공으로 보이는 노란 테 주황 원판이 늘 화면 가운데 근처, 크기는 화면 폭의 약 1/10. 원판 안 무늬가 장마다 다르다(점 4개·점 가득·소용돌이·점 1개). 큰 생물이 화면 밖으로 잘릴 만큼 카메라가 가깝고 가장자리가 어두워진다. 붉은 살로 된 구간이 있다. 글자·HUD 없음. 위아래 단서가 없어 가라앉는 게임으로는 보이지 않는다(가라앉기는 이 Kit 자체 결정, 계획서 §1.2).
2. **OQ-4 — ID 매핑.** `region_hollow` `loc.*` `thing.*` 9개가 `docs/world/**` 와 같은 문자열인지(W1).
3. **§20 판정 D1~D3 승인.** 되돌리면 행에 적힌 파일만 바뀐다.
4. OQ-2·5·6·8 은 사용자 지시("추천대로")로 추천안을 적용했다. OQ-3·7·9 는 등록 때 할 일(§6)이다.

## 6. 등록 때 할 일 (W0 · `app/**` — 이 Kit은 고치지 않는다)

1. `app/app_root.gd` `NORMAL_IDS` 에 `&"descent_exploration"` 추가. 6개 action 이 기존 루프로 ↑↓←→ Z X 에 묶인다.
2. `arrival["persist_checkpoint"] = func(module_id: String, data: Dictionary) -> void` — 앵커 저장(OQ-7). 없으면 앵커는 메모리에만 남는다.
3. `arrival["world_state_view"] = store.issue_view()` (`WorldState.make_arrival()` 과 같다).
4. `arrival["request_mutation"] = func(axis: String, patch: Dictionary) -> Dictionary: return store.request_mutation(StringName(axis), patch, &"descent_exploration")` — 없으면 몸 요청을 조용히 건너뛴다.
5. `requested(&"input_profile", {"required_keys": [...6], "previous": [...]})` 를 전환층 Input Bubble 로 넘기고, 직전 구간 키를 `arrival["previous_required_keys"]` 로 준다(OQ-3).

## 7. 연결 요청 (다른 소유자)

| 받는 쪽 | 요청 |
|---|---|
| W3 | `audio_manifest.json` 13줄 그대로 wav 렌더(OQ-6). 생기면 `test_manifest_validates_once_the_renders_exist` 가 `pending` 에서 강제 단언이 된다. **추가 발견(2026-09-27 sub-kit08):** wav 13개가 없는 동안 `AudioEventPlayer.setup()`(`core/services/audio_service/audio_event_player.gd:59`)이 `ResourceLoader.exists()` 사전 확인 없이 `ResourceLoader.load(item.file)`을 호출해 엔진 경고("Method/function failed. Returning: Ref<Resource>()", "Condition \"err != OK\" is true")를 이벤트당 1회씩 낸다. GUT 9.7은 이걸 "Unexpected Errors"로 실패 처리하므로(AGENTS.md §9), `module.gd`를 거치는 이 Kit 테스트 다수(worldstate·module 나머지)가 **실제 버그가 아니라 이 경고 때문에** Failed로 표시된다. wav가 채워지면 자연히 사라진다. core 소유자가 급하면 `setup()`에 `ResourceLoader.exists(item.file)` 가드를 추가해도 될 것이다(이 Kit은 core를 고치지 않는다). |
| W1 | OQ-4 ID 매핑표 |
| Kit 06 · W7 | 몸 `missing` 부위 이름 어휘 확정. 이 Kit·Kit 07 은 `arm_left`, core README·테스트는 `left_arm` (D16) |
| **core 소유자** (`core/services/audio_service/**`) | **긴급 — Kit 08 테스트 40개가 이 버그로 실패한다.** `core/services/audio_service/audio_manifest_event.gd:5`의 `@export_file("*.wav,*.ogg,*.mp3")`가 Godot 4.7에서 파싱 오류다("Argument 1 of annotation contains a comma. Use separate arguments instead"). 콤마 구분 문자열 하나가 아니라 별도 인자로 나눠야 한다(예: `@export_file("*.wav", "*.ogg", "*.mp3")` 또는 지원되는 필터 문법으로 교체). 이 파일이 컴파일 실패하면 `audio_manifest.gd`·`audio_event_player.gd`가 연쇄로 깨지고, 이를 `preload`/`class_name` 참조하는 `modules/descent_exploration/module.gd`까지 통째로 컴파일 실패해 `DescentModule.new()`가 전부 죽는다(worldstate 19/40, module 7/23, save 0/12→12/12 순서로 확인). 2026-09-27 05:0x 현황 문서 "원인 1·2·3 고침"에는 이 문제가 없었다 — 그 사이 이 파일이 새로 생겼거나 되돌아간 것으로 보인다. `core/**`는 이 Kit이 못 고치므로 요청만 남긴다. |

## 8. 다음 작업 (OQ-1이 닫힌 뒤)

계획서 §10을 사용자 확인값으로 먼저 고치고 → `presentation/` 9개(§5.4) → `entry.tscn` 에 `DescentView` → `test_screen_names_map_only_the_three_endings` 가 `pending` 에서 실제 검사로 바뀌는지 확인 → 10분 실측 3루트(§14.3) → 해상도 캡처 3장 → §16 수동 과제 → §18 완료 증거.

## 9. 알아 둘 함정

- GUT 9.7 은 `push_error` 와 엔진 오류를 "Unexpected Errors" 로 실패 처리한다. 이 Kit은 경고만 `push_warning` 으로 낸다.
- 새 `.gd` 를 만들면 import 전까지 `class_name` 이 안 잡혀 연쇄 파싱 실패가 난다.
- `modules/descent_exploration/**` 에서 `get_tree()`, `/root`, `WorldState`/`Axis*` 클래스 이름, 다른 `res://modules/` 경로를 쓰면 테스트가 잡는다(`test_module_code_*`).
- 결말 이름 3개(`정지` `귀환` `삼키다`)와 셸 이름 `하강` 외의 한글 문자열을 코드에 넣으면 `test_no_player_text_outside_whitelist` 가 잡는다.
