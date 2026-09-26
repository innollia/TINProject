# Kit 08 하강 탐사 — 구현 현황 · 인계

기록 2026-09-27 05:0x KST · 모듈 `descent_exploration` · 브랜치 `kit/05-stone-story-rpg`
계획서 `plans/kits/08_DESCENT_EXPLORATION_KIT.md` — 구현 중 판정은 **§20**(앞 절과 충돌하면 §20이 정본)

이 문서 하나로 이어받을 수 있게 적었다. 이 세션은 여기서 닫힌다.

## 0. 다음 작업자가 할 일 (순서대로)

1. **Kit 08 테스트만 먼저 돌린다.** `AGENTS.md` 의 Godot 잠금 절차를 지킨 뒤:
   ```powershell
   $GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'
   $p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait -PassThru; $p.ExitCode
   $p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gprefix=test_descent_exploration_ -gexit' -NoNewWindow -Wait -PassThru; $p.ExitCode
   ```
   `-gprefix=test_descent_exploration_` 는 이 Kit의 7개 파일만 고른다. 새 스크립트를 만들었으면 import 를 먼저 해야 `class_name` 이 잡힌다.
2. 남은 실패를 고친다(§3의 "재실행" 칸 참고). 소유 경로 안에서만.
3. 통과하면 `AGENTS.md` "완료 전 자동 검증" 4개 명령을 한 번 돌리고, 남의 파일 실패는 기록만 한다.
4. 소유 경로만 커밋·푸시(`git add -- <경로>` → `git commit -m ... -- <경로>` → `git push origin kit/05-stone-story-rpg`).
5. 사용자가 OQ-1(§5)을 답하면 계획서 §10을 먼저 고치고 `presentation/` 을 만든다(§8).

소유 경로(이 Kit이 쓸 수 있는 곳): `modules/descent_exploration/**`, `tests/core/test_descent_exploration_*.gd`, `plans/kits/08_DESCENT_EXPLORATION_KIT.md`, `docs/research/swallow_the_sea/**`. 나머지는 읽기만. `app/**` 변경은 §6 연결 요청으로만.

## 1. 지금 상태

- **된 것:** 규칙 전부(`domain/` 6개, `systems/` 14개), 정본 6개 층 + 증명층 1개 authored JSON, 로더·검증기(13규칙), 저장·불러오기·마이그레이션·재시작, 결말 3종 판정, 몸통 인계(읽기 뷰·부력·손 자리·잔해·쓰기 요청 1회), Input Bubble 상태 보관, 오디오 이벤트 표 13줄. 테스트 7개 파일.
- **안 된 것:** 화면(`presentation/` 9개 파일). §19 OQ-1이 열려 있어 시작하지 않았다. 그래서 10분 Reference Game 실측, 720p/FHD/QHD 캡처, §16 수동 과제, §18 완료 증거는 아직 할 수 없다.
- **남의 일:** wav 13개(W3), 앱 등록과 arrival 훅(W0), ID 매핑(W1).
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

**미실행.** 세 원인을 고친 뒤 재실행을 걸었지만 이 세션이 닫힐 때(05:06)까지 다른 세션(kit01)이 Godot 잠금을 쥐고 있어 돌지 못했다. 다음 작업자는 §0-1 부터 한다. 1차에서 통과가 확인된 것은 `domain` 14개뿐이고, 나머지 6개 파일은 고친 뒤 한 번도 돌지 않았다.

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
| W3 | `audio_manifest.json` 13줄 그대로 wav 렌더(OQ-6). 생기면 `test_manifest_validates_once_the_renders_exist` 가 `pending` 에서 강제 단언이 된다 |
| W1 | OQ-4 ID 매핑표 |
| Kit 06 · W7 | 몸 `missing` 부위 이름 어휘 확정. 이 Kit·Kit 07 은 `arm_left`, core README·테스트는 `left_arm` (D16) |

## 8. 다음 작업 (OQ-1이 닫힌 뒤)

계획서 §10을 사용자 확인값으로 먼저 고치고 → `presentation/` 9개(§5.4) → `entry.tscn` 에 `DescentView` → `test_screen_names_map_only_the_three_endings` 가 `pending` 에서 실제 검사로 바뀌는지 확인 → 10분 실측 3루트(§14.3) → 해상도 캡처 3장 → §16 수동 과제 → §18 완료 증거.

## 9. 알아 둘 함정

- GUT 9.7 은 `push_error` 와 엔진 오류를 "Unexpected Errors" 로 실패 처리한다. 이 Kit은 경고만 `push_warning` 으로 낸다.
- 새 `.gd` 를 만들면 import 전까지 `class_name` 이 안 잡혀 연쇄 파싱 실패가 난다.
- `modules/descent_exploration/**` 에서 `get_tree()`, `/root`, `WorldState`/`Axis*` 클래스 이름, 다른 `res://modules/` 경로를 쓰면 테스트가 잡는다(`test_module_code_*`).
- 결말 이름 3개(`정지` `귀환` `삼키다`)와 셸 이름 `하강` 외의 한글 문자열을 코드에 넣으면 `test_no_player_text_outside_whitelist` 가 잡는다.
