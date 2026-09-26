# Kit 08 — Descent Exploration (하강 탐사)

> 상태: **구현 착수 가능.** 단 §19 OQ-1~OQ-3이 닫히기 전에는 **presentation 파일부터 시작하지 않는다.**
> 공통 계약: `docs/KIT_WORKFLOW.md` · 모듈 계약: `docs/MODULE_CONTRACT.md` · 코드 규칙: `docs/CODE_STYLE.md`
> 조사 근거: `docs/research/swallow_the_sea/SWALLOW_THE_SEA_RESEARCH.md`
> 라운드 정본: `docs/research/round_2026_09_26/ROUND_PLAN.md` (C1 절차 비주얼 · C2 오디오 · C3 모듈 등록)
> **세계관 노출 금지(정본):** 같은 라운드 정본 §11.3 — 이 Kit에서의 기계적 집행은 **§10.9 / §10.10** 이 정본이다.
> 템플릿: `plans/kits/TEMPLATE.md`
>
> 모듈 id: `descent_exploration` · 소유 경로: `modules/descent_exploration/**`
> 소유 경로 밖 금지: `app/app_root.gd` · `project.godot` · `core/**` · `addons/**` 는 **읽기만** 한다. 필요한 변경은 §19 OQ-9에 요청으로만 적는다.

---

## 0. Kit 목적과 설계 기둥

### 0.1 이 Kit는 무엇인가

**한 게임 안에서 "세로로 내려가는 탐사" 구간을 즉시装配하기 위한 Kit다.**

`sideview_ecosystem`(Kit A, 신체로 통과)과 `physics_puzzle_platformer`(Kit B, 도구 조합으로 통과)의 사이에 오는 세 번째 축이다. 이 축의 진행 방식은 **지식과 선택**이다.

- 사용하면 새로 만들지 않아도 되는 것: 하강 물리, 소모성 물질 운반, 사실(knowledge) 장부와 그 사실이 여는 authored 경로, 층 전환, 앵커 체크포인트, 3종 결말 판정, 실패 복구, 10분 Reference Game 6개 구간, 오디오 이벤트 표, 3해상도 줌 스냅.
- 이 Kit가 다루지 **않는** 것: 전투, 인벤토리 화면, 상점/거래, 인원, 능력 해금, 스킬 트리, 지도 화면, 인벤토리 UI, 상시 HUD, 편집기 툴.

### 0.2 설계 기둥 — 세 문장. 위반하면 구현이 실패다.

1. **내려가는 방향은 기본값이다.** 플레이어가 아무것도 하지 않으면 아래로 가라앉는다. 위로 오르려면 키를 눌러야 하고, 그 키를 오래 누를수록 회복이다. 그러므로 "내려가기"는 대기가 아니라 **끊김 없는 판단**이다.
2. **무게는 유일한 능력치다.** 들고 있는 것의 질량이 곧 이동·돌파·내려가기 능력이다. 무거우면 빨리 가라앉고 부서뜨리는 데 강하지만 방향 전환이 느리다. 숫자 게이트·레벨·경험치는 없다. 진행은 **몸이 아니라 머리(fact)** 로 열린다.
3. **잃은 것과 남긴 것이 곧 결말이다.** 남긴 물질과 쌓은 사실만으로 마지막 세 갈래가 결정된다. 그 세 갈래는 종류가 다르다 — 아무것도 필요 없는 것 / **알아야** 하는 것 / **가져와야** 하는 것. 세 갈래는 서로 배타적이지 않지만 한 번에 하나만 갈 수 있다.

### 0.3 다른 두 Kit와 세계를 공유하는 방식

> **[제작 전용]** 아래 표의 `region_hollow` / `loc.*` / `thing.*` ID와 표기(`뿌리층` `회랑층` `이빨층` `육자층` `전시층` `바닥` `공동의 심장` `관리인`)는 **authored 정본의 표기**다. **`표기` 열의 값은 결말 화면의 화면 이름 3개를 제외하고 전부 그리지 않는다**(§10.9). 이 Kit은 `docs/world/**`를 **읽지 않는다**(아래 그대로).

- 세계: **이상한 나라의 앨리스에서 출발한 포스트아포칼립스.** (이 라운드 공통 결정)
- 이 Kit의 지역: `region_hollow` — 세계가 무너진 뒤 남은 수직 공동(空洞). 지상의 무너진 정원 → 지루 → 지하 수직 낙하축 순으로 이어진다.
- 다른 Kit와 **공유하는 것**은 `loc.*` ID 문자열뿐이다. 이 Kit은 `docs/world/**`를 **읽지 않는다.** 다른 module을 **참조하지 않는다.** (`docs/MODULE_CONTRACT.md` §Kit와 shared)
- 이 Kit이 사용하는 world ID (W1 `docs/world/**`이 나중에 매핑한다):

| ID | 표기 | 이 Kit에서의 역할 |
|---|---|---|
| `region_hollow` | 정원 아래 공동 | 이 Kit의 유일한 지역 |
| `loc.roots` | 뿌리층 | 구간 0 |
| `loc.halls` | 회랑층 | 구간 1 |
| `loc.teeth` | 이빨층 | 구간 2 |
| `loc.nursery` | 육자층 | 구간 3 |
| `loc.gallery` | 전시층 | 구간 4 |
| `loc.floor` | 바닥 | 구간 5 |
| `thing.heart` | 공동의 심장 | 결말의 물질적 중심 |
| `thing.warden` | 관리인 | 구간 4~5의 저해 |

- **W1이 이 표를 다 쓰기 전까지 구현이 멈추지 않는다.** `loc.*`는 이 Kit이 **소유하는 문자열**이고, 나중에 W1이 의미를 채운다. 해석이 충돌하면 이 Kit의 `docs/research/swallow_the_sea/` 문서가 아니라 W0 조정으로 푼다. (§19 OQ-4)

---

## 1. Primary Reference

**게임:** Swallow the Sea
**개발:** Talia bob Mair (=Maceo), Nicolás Delgado (=Kondorriano) — Steam `developers` 확인
**발매:** itch.io 이름값 지정 무료, 2020-04경 공개 / Steam 2021-09-03
**플랫폼:** Windows, macOS, Linux
**엔진:** Unity + Aseprite (itch `Made with` 필드로 **확정**)
**공식 출처:**
- Steam 스토어 데이터: `https://store.steampowered.com/api/appdetails?appids=1511860&l=english&cc=us`
- itch: `https://itsthemaceo.itch.io/swallow-the-sea`
- Steam 성취 10개: `https://steamcommunity.com/stats/1511860/achievements`
- 개발자 데브로그: `https://itsthemaceo.itch.io/swallow-the-sea/devlog`
- 아케이드vs(descendant) 루프 해설: `https://www.rockpapershotgun.com/swallow-the-sea-is-a-short-free-tale-of-birth-hunger-and-gnawing-teeth`
- 루트 가이드(영문 원저 YouGotHitByGunner): `https://steamah.com/swallow-the-sea-100-walkthrough-achievement-guide/`

### 1.1 강하게 따라가는 것

| 축 | 가져가는 규칙 | 근거 |
|---|---|---|
| 성장 | 먹고 커져서 원래의 위협을 먹게 되는 물리적 성장 | Store "eat and grow combat" / RPS "Start out small... until you grow and can take on the big boys" |
| 소모성 자원 | 자원이 유한해서 "지금 쓸까"가 매 순간 성립 | 가이드 "ignore all food from the surroundings, those don't help you at all" |
| 질량 = 능력 | 먹은 것이 이동 능력을 바꾼다 | 가이드 "Avoid the blue worms, they considerably slow you down" |
| 성장 단계 표시는 UI가 아니라 몸 | 성장 순간을 별도 화면 없이 몸으로 알린다 | RPS "you're still growing, but now you see what exactly you're growing into" |
| 환경 escalation | 구간이 내려갈수록 세계가 더 나빠진다 | RPS "the passages tinge red with rotten flotsam and foul vents" |
| 돌파 | 대시가 부서지는 벽을 깬다 | 가이드 "Dash in the gate, to break it" / "smash through certain crumbly walls" |
| 구간 분할 | 여섯 개의 이름 붙은 구간 + 그 사이 문 | 가이드 구간 목록 |
| 결말 3개 | 플레이어가 무엇을 먹었느냐로 갈림 | Steam 성취 Ouroboros / Mercy / Sororicide |
| 10분 클리어 | 8~15분이 정식 분량. 짧음을 숨기지 않는다 | Store "a 8-15 minute 2D survival exploration game" |
| 점프스케어 금지 | 공포는 점프스커어가 아니라 압박으로 | itch 개발자 코멘트 "contains no jump scares... oppressive atmosphere and dark themes" |
| 상시 HUD 없음 | 타이머조차 **토글**이다(기본 꺼짐) | QoL 데브로그 "A toggleable in-game timer" |

### 1.2 일부러 떠나가는 것 (이유 필수)

| 원작의 것 | 왜 버리는가 | 대신 무엇을 넣는가 |
|---|---|---|
| **"N개를 먹어라" 누적 카운터 게이트** (9 orbs / 13 orbs / 15 orbs…) | 사용자가 카르마식 누적 게이트를 금지했다. 카운터 게이트는 10분을 "필요 개수 채우기"로 바꾼다 | 통과 조건 4종(`always` / `fact:<id>` / `clearance:<n>` / `opened:<site_id>`) 중 하나. `clearance`는 **현재 운반 질량**이며 누적값이 아니다 |
| **오르기는 하강이 아니다** | 원작은 "언젠가 태어나는" 방향이다. Kit 이름이 `descent_exploration`이므로 축을 뒤집는다 | **아무것도 안 하면 가라앉는다.** 상승은 유일한 능동 입력이다 |
| **오로 1인이 뒤따르는 추격자**(Orro / Mr X 패턴) | 한 층에만 성립하는 패턴이라 6개 구간을 못 만든다 | 저해가 층마다 다르다. §4.5 표 참조 |
| 보라 아이 / Orro / Vobble / Ubb / Nooty / Gump Sucker | 원작 고유 존재. 복제 금지 | `thing.heart`, `thing.warden`, 그리고 이 표에 없는 TIN 고유 이름. 아래 §0.3 world ID 외에 원작 이름은 **문자열로도 쓰지 않는다** |
| 마우스 좌클릭 이동 + 우클릭 대시 | Input Bubble은 **물리 키**를 세는 계약이다. 마우스 버튼은 가상 격자 칸에 앉힐 수 없다 | 키보드 4키 `W S Z X`. §12 |
| 4분 스피드런 성취 | 사용자가 "기다림·반복 입력으로 10분을 채우지 말라"고 금지했다. 시간 압박 성취는 그 반대 방향이다 | 시간 성취 없음. 대신 6개 authored 구간 전부 통과가 10분을 구성 |
| 죽으면 처음부터 | 데스처 성취 보유자가 96.6%. 검증용 Reference Game에서 매번 0부터는 검증이 아니라Punishment다 | 앵커 귀환 + **사실은 영구 유지**. §13 |
| 카메라/팔레트/전환 연출 | **조사에서 미확인.** `SWALLOW_THE_SEA_RESEARCH.md` §10 N2·N3·N12 | TIN이 `core/procedural`로 자체 정의. §8·§10 |

### 1.3 복제하지 않는 고유 저작물 — 금지 목록

원작의 **자산·캐릭터·문구·레이아웃 배치·고유 이름·세계관**을 복제하지 않는다. 특히 다음 문자열은 TIN 코드·데이터·문서 어디에도 넣지 않는다: `Swallow the Sea`, `Borrus`, `Orro`, `Ubb`, `Nooty`, `Vobble`, `Gump Sucker`, `Ouroboros`, `Sororicide`, `nursery wall`. Steam 성취 이름 10개도 그대로 쓰지 않는다.

---

## 2. Reference evidence 표 (전 행 `확인` / `미확인`)

`확인` = 텍스트 출처에 그 문장이 있다. `미확인` = 이 조사자가 확인하지 못했다. **미확인 행을 근거로 한 구현 지시는 없다.**

| 상태 | 출처 | 눈으로 확인할 것 | 판정 | TIN이 가져가는 규칙 |
|---|---|---|---|---|
| first playable frame | Steam 스크린샷 5장 (URL은 조사문서 §12) | 타이틀 유무, 첫 화면 구성 | **미확인** (조사자가 이미지 미열람) | **없음.** 별도 타이틀 화면을 만들지 않는다. 첫 화면 = §5.1의 기동 화면 |
| normal play | Store/리뷰/가이드 전부 | HUD 유무, 플레이어 중심 프레이밍 | HUD 없음은 `추론(강함)`, 프레이밍은 **미확인** | 상시 HUD 0개. §10.2 |
| focus / selection / 직접 조작 | itch `Inputs: Mouse`, QoL "Controller and keyboard support" | 커서/선택 개념 유무 | **없음이 확인됨**(직접 조작은 자기 몸뿐) | 마우스 커서 게임 금지. 조작 대상은 오직 자기 몸 |
| core mechanic change 직후 | RPS "you're still growing, but now you see what exactly you're growing into" | 성장 순간 화면 | **미확인**(연출) | 별도 화면 없음. 실루엣 변화로만 알린다 |
| unavailable / failure | 가이드 "hits you two times, restart the game" | 사망 화면 | 화면 구성 **미확인** | 앵커 귀환 + 화면 암전 1.4초. §13.3 |
| success / completion | Steam 성취 10개 | 결말 화면 | 결말 **3개라는 사실은 확인**, 화면은 **미확인** | 결말 3개. 조건·연출 전부 교체. §4.7 |
| menu / detail | QoL "An improved pause menu" | 메뉴 항목 구성 | **존재 확인**, 구성 **미확인** | Kit은 메뉴를 만들지 않는다. Shell의 Esc 메뉴만 쓴다 |
| level/scene transition | 가이드 구간 목록 + "Dash in the gate to break it" | 전환 연출 | 구간 분할은 **확인**, 연출은 **미확인** | 층 전환 0.9초 + 암전 플래시 12프레임. §4.9 |
| 압력/타이머 죽음 | 전수 검색에서 부재 | — | **부재 확인** | 시간 압박 없음. 대기 없음 |
| 런마다 목표가 달라지는가 | 결정적 출처 없음 | — | **미확인** | authored 고정. 절차 생성 금지 |

---

## 3. 아키텍처 — 7개 층

```
[presentation]  descent_view · backdrop_rig · squish_backdrop · *_figure · transition_veil
        │ 읽기                       ▲ 신호 4개만(consume/blocked/hit/descend)
        ▼                            │
[input]        module.read_intent() → RunIntent
        │
[systems]      player_motion · collision · hazard_field · matter_loop
               route_resolver · anchors · vitality · fauna_agent · ending_resolver
        │
[domain]       DescentState · StratumRuntime · MatterItem · FactLedger   ← 게임 상태의 진실
        │
[content]      content_loader → authored/strata/*.json
        │
[contracts]    GameModule · ModuleContext · ModuleManifest · AudioManifest
```

- domain state가 진실이다. presentation 노드의 색·위치·텍스트를 판정 읽지 않는다. (`docs/CODE_STYLE.md` §Domain/Presentation)
- physical key는 domain에 없다. `ModuleContext`가 해석한 action만 intent로 내려온다.
- 저장 payload는 JSON-safe다. `Vector2`를 넣지 않고 `[x, y]` 배열로 직렬화한다. (`docs/MODULE_CONTRACT.md` §저장)

---

## 4. 핵심 시스템 — 전부 실제 수치로

모든 수치는 §8 상수표가 정본이다. 이 절은 그 수치가 **무슨 뜻인지**를 고정한다.

### 4.1 이동 (`PlayerMotion`) — 4축이 아니라 2축, 그리고 중력

수평 + 수직 자유 이동(2D). 매 프레임 순서:

1. 입력 없으면 수평 속도에 `linear_drag`(1.6 /s)를 적용한다. 물속이므로 즉시 멈추지 않는다.
2. `up` 홀딩: 수직 속도를 `swim_up_speed`(70) 쪽으로 끌어올린다. **`up`을 놓는 순간 가라앉기 시작.**
3. `down` 홀딩: `dive_accel`(46)을 아래로 더한다. 최대 `sink_terminal * 1.25`까지만.
4. `up`도 `down`도 안 누름: `sink_accel`(22) 아래로, `sink_terminal`에서 포화.
5. `surge` 순간: `surge_speed` 방향으로 속도를 **덮어쓴다**(더하지 않는다). 0.16초 동안. 쿨다운 0.45초. 방향은 **가장 최근에 눌린 방향 intent**이고, 방향 intent가 한 번도 없었으면 `facing`의 수평 방향(±1, 0)이다. 눌린 방향 intent가 `(0,0)`이면 `facing`으로 대체한다.
6. 질량 보정: 3·4·5의 모든 속도 상한에 `mass` 계수를 적용한다. (§8)

**오르기의 비용은 시간으로 지불된다.** 위로 오르려면 1초당 70px를 직접 만들어야 하고, 그 사이 아래로 끌리는 힘과 부딪힐 벽을 수동으로 처리해야 한다. 이게 "긴 이동으로 10분 채우기"가 아니라 "판단으로 10분 채우기"의 근거다.

### 4.2 질량 — 유일한 능력치

```
mass = carried matter 의 size 합계, 0 ≤ mass ≤ 4
```

| mass가 만드는 변화 | 값 |
|---|---|
| 가라앉는 속도 | `30 + 14 * mass` px/s |
| 수평 최대 속도 | `62 - 3 * mass` px/s |
| 수평 가속 | `240 - 28 * mass` px/s² |
| 대시 초기 속도 | `168 - 20 * mass` px/s |
| 몸 충돌 박스 | `9 + 2 * mass` × `7 + 2 * mass` px (충돌은 커진다) |

- **mass는 내리기도, 돌파하기도, 방어도 하는 하나의 축이다.** 무거우면 이빨층의 거꾸로 흐르는 물살을 뚫고(§4.5) grazer가 도망가지만, 수평 최대 속도가 줄어(§8) warden 56px/s에서 **못 달아난다.** `mass` 0 vs 4의 수평 가속은 240 vs 128 — 방향 전환 시간이 1.9배가 된다.
- **mass는 누적 게이트가 아니다.** 운반 한도는 **4로 정적**이고(`body` 상태와 무관하다, §13.6.6), `carried` 에서 물질이 빠지는 경로는 **3개**다 — `consume` 성공 / `place.requires_body` 로 성에린 `consume` 자리 / `downed` 시 체크포인트 스냅샷 교체(§13.6.6). **되찾기는 어느 경로에도 없다.** "9개 먹은 누적"을 대체하는 것은 "지금 2kg 들고 있나"라는 **순간 상태**다.
- `clearance:<n>` 조건은 이 순간값을 **그 문에 닿는 그 순간에만** 평가한다. 누적하지 않는다. 그러므로 `clearance` 경로가 있는 층에는 반드시 `clearance`가 아닌 대안이 하나 이상 더 authored되어 있어야 한다. (authored 검증 규칙 11, §9.4)

### 4.3 물질 루프 (`MatterLoop`) — 픽업 · 운반 · 사용

물질 한 개는 다음 필드만 가진다: `id`, `size`(1..3), `verb`, `tag`.

| verb | 무엇을 엽니다 | 소비 후 | 대표 authored 사용처 |
|---|---|---|---|
| `plug` | 흐름을 막거나 배수를 연다 | 사라짐 | 이빨층의 막힌 홈 |
| `feed` | `tag`가 맞는 막만족시킨다 | 사라짐 | 바닥의 `thing.heart` |
| `strike` | 한 번의 강한 충격을 버틴다 | 사라짐 | 전시층의 낙석 구간 |
| `weigh` | 아무것도 열지 않고 **질량만 +1** | 사라짐 | 상승 흐름을 뚫는 유일한 방법 |

- 픽업: 물질의 `position`에서 반경 6px 안에 도착하면 자동 획득. 화면 표시 없음.
- **획득 순간 배낭이 4초과면 아무것도 얻지 않는다.** (획득 실패도 표시 없음. 부딪힌 느낌만으로 알린다.)
- 소비: `consume` 입력 1회. **범위(USE_RADIUS 8px) 안에 유효한 목표가 있는 운반 물질 중, 가장 먼저 획득한 것 1개만** 사용한다. `carried[0]`을 무조건 쓰는 것이 아니다 — 무조건 쓰면 앞쪽의 쓸모없는 물질이 뒤쪽의 유효한 물질을 가려 소프트락이 생긴다.
- 유효한 목표 = `membranes[]` 중 `tag`가 같고 `consume`는 **`verb` + `tag` 가 모두** 일치하는 것. `verb`만 같으면 안 된다. `weigh` 물질은 **어떤 목표와도 일치하지 않는다.**
- 성공·실패 모두 atomic — 성공하면 `consumed`에 기록되고 되돌아오지 않는다. 실패하면 아무것도 변하지 않는다.
- **버리기 없음.** 물질을 버리는 입력이 없다. `X`를 눌러도 대상이 없으면 `desc_denied`만 나고 `carried`는 그대로다. `carried`에서 물질이 빠지는 경로는 **3개**다 — ① `consume` 성공, ② `place.requires_body` 로 성에린 `consume` 자리(§13.6.2), ③ `downed` 시 체크포인트 스냅샷으로의 교체(§13.3). **②는 새 입력이 아니다.** 손이 있다는 것은 "버릴 수 있다"가 아니라 "그 자리가 열린다"이고, 버리는 동작 자체는 여전히 없다.
- **맨 앞 = 획득 순서.** `consume` 우선순위가 획득 순서로 고정되므로, "이것만 들고 내려간다"는 결정이 물질 구성으로 확정된다. 이것이 §0.2-3의 구현이다.

### 4.3.1 막(`membranes`)의 물리 규칙

- **닫힌 막은 통과를 막는다.** `DescentCollision` 에서 `solids` 와 같은 방식으로 X축→Y축 순서로 해결하되, **파괴할 수 없다.** 대시해도 안 열린다.
- 열린 조건: `USE_RADIUS`(8px) 안에 `verb` + `tag` 가 모두 일치하는 운반 물질이 있고, 그 상태가 `hold_seconds` 동안 유지될 것. **`hold_seconds` 경과 즉시 영구히 열린다**(`opened_membranes` 상태가 되며 저장 대상).
- `hold_seconds` 도중 플레이어가 물질을 소비하거나 멀어지면 진행도가 되돌아간다(누적이 아니라 현재 유지값).
- 열린 막은 `StratumRuntime` 의 런타임 플래그로만 존재한다. 저장하지 않는다 — 앵커를 지나면 그 층은 어차피 다시 진입하므로 원상 복구된다. **저장하지 않음은 버그가 아니라 규칙이다.** (§6.2)
- `membranes` 의 `rect` 는 `trigger` 와 겹쳐도 된다. **단 `exit` 계열 `trigger` 와는 겹치지 않아야 한다** — 겹치면 `ending` 이 항상 막혀 `ending.hollow` 만 가능해진다. (validator 규칙 13으로 강제, §9.4)

### 4.4 사실 장부 (`FactLedger`) — 진행은 숫자가 아니라 목록이다

- 사실은 **문자열 ID 집합**이다. 개수·가중치·레벨이 없다. `{"current_lies", "vent_above"}`.
- 사실을 얻는 유일한 방법: authored `sites` 중 `kind: "plaque"` 를 **물리적으로 만지는 것**. 읽는 UI가 없다. 화면에 글자가 한 줄도 뜨지 않는다.
- 사실이 여는 것: authored route의 `requires: [{"kind":"fact","fact":"vent_above"}]`. 사실 자체는 어떤 능력도 올리지 않는다.
- **사실은 낭비되지 않는다.** `fact.current_lies` 는 이빨층에서만, `fact.vent_above` 는 바닥에서만 쓰인다. 6개 층에 걸친 사실은 2개뿐이다. 그 이상 늘리지 않는다.

### 4.5 저해 — 층마다 규칙이 다르다 (`HazardField` + `FaunaAgent`)

이 표가 "6개 authored 구간이 같은 core를 재사용한다"의 증거다. 저해 종류 4개를 6개 층에 다른 배합으로 배치한다.

| 층 | 저해 규칙 | 물리 구현 |
|---|---|---|
| 0 `loc.roots` | 없음 | 전부 0. 저해 없는 층이 정확히 1개 |
| 1 `loc.halls` | **부서지는 벽** 3개. 대시 1회로 각 벽을 깬다. 벽을 깬 뒤 0.4초 안에 통과해야 벽이 다시 굳는다 | `solids[].kind: "brittle"`, `regrow_seconds: 0.4` |
| 2 `loc.teeth` | **거꾸로 흐르는 물살** `tide_main` (바닥 전폭 80px, `flow = [0, -62]`). 물살 안에서 `mass 2`(하강 58)는 부족해 못 내려간다. `mass 3`(하강 72) 이상이면 뚫고 내려간다. 통과가 8초 이상 걸리지 않게 물살 높이를 80px로 고정했다. **여기에 우회구가 정확히 하나 있다** — 오른쪽 아래 `membrane_brine`(`tag: "brine"`)은 `verb: "plug", tag: "brine"` 물질을 소비해야 열린다 | `currents[]` + `membranes[]` + 두 개의 `descent` route |
| 3 `loc.nursery` | **放牧獸 grazer** 1마리. 순찰 34px/s. `mass >= 2`이면 도망치고(50px/s), `mass < 2`이면 50px/s로 추격. 접촉 반경 7에서 1 피해. `site_nursery_plaque`는 brittle 벽 뒤에 있다 | `fauna[]` |
| 4 `loc.gallery` | **`thing.warden`** 1마리. 구간 4에서는 `line_y` 위쪽(위 240px)에서는 존재 자체가 없다. `line_y` 아래로 내려가면 출현하고 **56px/s**로 추격한다. `mass 3`의 플레이어 수평 최대는 53px/s이므로 **달아나서 벗어날 수 없다.** 막을 수 있는 유일한 물건은 `verb: "strike"` 물질 1회다. `line_y` 위쪽 우회로가 항상 열려 있으므로 완전 막힘은 아니다 | `fauna[]` + `line_y` |
| 5 `loc.floor` | `thing.warden` 56px/s 추격 지속. `thing.heart` 앞 `heart_meld`(반경 56, `tag: "seed"`, `hold_seconds: 0.9`)만 `feed` 물질로 열린다. `mouth.above` 앞에는 26px/s의 **오르막 흐름**이 있어 700px를 다시 올라가야 한다 | `membranes[]` + `currents[]` + `fauna[]` |

**난이도 호(弧) — 의도된 값trade다.** 질량 3은 구간 3의 grazer를 만나면 도망가게 만들어 쉽게 넘기되, 구간 4의 warden는 56px/s라 **같은 질량으로는 추격을 못 벗어난다.** 이 层에서 벌린 값은 저 层에서 돌아온다. 그래서 구간 2의 선택은 "여기서 편해지느냐"가 아니라 "어디에서 값을 치르느냐"다.

**금지**: `thing.warden`을 죽이거나 진정시키는 authored 이벤트를 만들지 않는다. 층 4·5에서 이기는 유일한 방법은 위치(`line_y`)와 `strike` 1회다.

### 4.6 앵커 — 체크포인트의 유일한 형태

- 각 층에 `anchors[]` 1~2개. 12×12 영역. **표시 없음.** 닿으면 그 층의 벽 질감 색이 3초간 1단계 밝아진다(§10.3).
- 앵커에 닿는 순간: `checkpoint = {stratum_id, anchor_id, position, mass, facts, carried}` 로 갱신하고 저장을 요청한다.
- 앵커는 **일방통행**. 재방문해도 아무 일도 없다. 되돌아가는 순간 체크포인트가 그 앵커로 **갱신되지 않는다** — 그럼 `opened` 조건과 anchor가 충돌하므로, 코드에서 갱신은 `anchor.entered == false`일 때만 수행한다.
- 앵커는 층 진입 시 `entered = false`로 리셋된다. 층 재진입은 세이브의 체크포인트로 되돌아간다.

### 4.7 결말 3종 (`EndingResolver`) — 세 종류의 근거

> **[제작 전용]** 아래 표의 `결말 id`(`ending.hollow` `ending.return` `ending.swallow`)·각문 id·`requires`·`결과` 서술은 **판정 정본**이다. **`표기` 열의 값 3개(`정지` `귀환` `삼키다`)만이 결말 화면에 나가는 문자열이다**(§10.9 `T2`~`T4`) — 그 1줄은 결말의 **이름**이지 결말의 **내용**이 아니다. "그래서 무슨 일이 있었는가"를 쓰는 문장은 금지다(§10.10 PF-04).

바닥(`loc.floor`)에 **나가는 곳 3개**가 있다. 각 각문은 **다른 종류의 근거**로만 열린다.

| 결말 id | 표기 | 각문 | 열리는 조건 (이것만) | 결과 |
|---|---|---|---|---|
| `ending.hollow` | 정지 | `mouth.still` | `always`. 항상 열림 | 남은 자리. 한 층 더 아래가 없음을 확인하고 머무는 끝 |
| `ending.return` | 귀환 | `mouth.above` | `requires: [{"kind":"fact","fact":"vent_above"}]` | 되돌아가는 길. 단 **위로 향하는 흐름 90px/s** 안에 놓여 있어, 소모성 물질이 없으면 오르지 못한다 |
| `ending.swallow` | 삼키다 | `mouth.heart` | `requires: [{"kind":"tag_available","verb":"feed","tag":"seed"}]` — 즉 `tag: "seed"` 물질을 들고 도착할 것 | `thing.heart`를 먹는다 |

**핵심 규칙 3개:**
1. 세 각문 중 **한 번에 하나만** 열린다. 열린 각문은 1개다. 나머지 두 개는 심장이 조여 닫혀 있다.
2. `ending.return`에는 `tag: "seed"` 물질을 **가지고 갈 수 없다** — 위로 흐르는 흐름을 무거운 몸은 뚫지만, `feed` 물질을 가진 손은 심장 앞에서 고정된다(§4.3). 이건 물리 규칙이 아니라 authored `mouth.above`의 `blocks_tag: ["seed"]`다. **결말 2개가 서로 배타적으로 잠긴다.**
3. 결말 판정에는 **숫자가 없다.** 획득 개수·생존 시간·피격 수 어느 것도 판정에 들어가지 않는다.

`ending.return`을 열려면 사실 2개를 다 모아야 하고, 그 사실을 얻은 층(3)이 `tag: "seed"` 물질이 있는 층(2)보다 **깊다**. 그러니 10분 Reference Game의 필수 순서는 **2 → 3 → 5**다. 그러면서 층 2에서 `tag: "seed"`를 들고 내려갈지, **`requires_body` 성에린 자리에서 내려놓고**(§13.6.2, §13.6.6) `weigh` 물질로 이빨층을 뚫을지가 §0.2-3의 실제 선택이 된다. **이 선택이 층 2에서 성립하는지는 아직 미결이다** — `requires_body` 자리가 층 5에만 있으므로 층 2에서는 되돌릴 수 없다. §13.6.6 마지막 미결 항목이 그 판정이고, `ending.hollow` 가 항상 열려 있으므로 **소프트락은 없다.**

### 4.8 성장 = 질량. 레벨 없음

- 성장 단계가 없다. `mass`가 연속량이다. 스프라이트는 `mass` 구간별로 다른 실루엣으로 그려지지만 게임 규칙은 구간을 전혀 모른다.
- 규칙상 `mass`는 정수로만 저장한다(0..4). 표현은 `mass`를 16단계로 보간해 스프링으로 부드럽게 따라온다. **표현만 연속, 규칙은 정수.**
- 반올림 경계: 질량계수가 바뀌는 지점은 `mass` 1, 2, 3, 4의 4개뿐이므로 임계값 튐이 없다.

### 4.9 층 전환

1. `routes[kind: "descent"]`의 `trigger` 영역에 들어간다.
2. `DescentState.transition_pending = true`, 입력 잠금.
3. `TransitionVeil` 0.9초: 암전이 0→1(0.35초), 백색 1프레임 플래시 후 흑백 12프레임 수축(0.15초), 암전 1→0(0.40초).
4. `content_loader.load(next_id)` → `StratumRuntime.build()` → `DescentState.enter_stratum()`.
5. 입력 해제.

**전환 중 저장하지 않는다.** 전환은 atomic이다. 저장 시점은 앵커뿐이다. (§13)

---

## 5. 파일 목록 — `modules/descent_exploration/**` 전체

아래가 **전체 목록**이다. 없는 파일은 없다. 하나를 추가할 때 위 목록에도 추가하지 않으면 구현이 불완전한 것으로 본다.

### 5.1 루트

| 경로 | 책임 |
|---|---|
| `modules/descent_exploration/entry.tscn` | 유일한 진입 씬. `DescentModule`(module.gd) + `DescentView`(presentation/descent_view.gd). 그 외 자식 없음 |
| `modules/descent_exploration/module.gd` | `GameModule` 상속. lifecycle, `save_state`/`load_state`/`migrate_save`, `execute_command`, Input Bubble 프로필, 앵커 영속 훅 |
| `modules/descent_exploration/module_manifest.tres` | `ModuleManifest` 리소스. `id = &"descent_exploration"`, `save_version = 1`, `input_actions` 4개 |
| `modules/descent_exploration/audio_manifest.json` | C2 형태의 오디오 이벤트 표. `id_prefix = "desc"` |
| `modules/descent_exploration/audio/README.md` | nkido 렌더 명령과 원본 패치 파일 이름. **wav는 W3가 생성** |

### 5.2 domain — 순수 데이터, 노드 없음

| 경로 | 책임 |
|---|---|
| `domain/descent_state.gd` | `class_name DescentState`. 런 전체 상태 + 불변식. `enter_stratum`, `add_fact`, `pick_up`, `consume`, `apply_damage`, `to_save`/`from_save` |
| `domain/stratum_runtime.gd` | `class_name StratumRuntime`. 한 층의 로드된 인스턴스( solids / currents / membranes / routes / sites / matter / anchors / fauna ). 런타임 소비 플래그를 함께 들고 있다 |
| `domain/matter_item.gd` | `class_name MatterItem`. `id`, `size`, `verb`, `tag`, `source_stratum` |
| `domain/fact_ledger.gd` | `class_name FactLedger`. 문자열 ID 집합. `has`, `grant`, `to_array`, `from_array` |
| `domain/run_intent.gd` | `class_name RunIntent`. 한 프레임의 입력 해석 결과. `up`, `down`, `surge`, `consume` (모두 bool) |
| `domain/worldstate_view.gd` | `class_name DescentWorldstateView`. `arrival["worldstate"]` 읽기 전용 뷰의 보유자. `limb_deficit`, `hands_free`, `has_wound(spec)`, `creature_state(id)`, `creature_den(id)`, `place_requires_body(id)` 만 노출. **저장하지 않는다**(§6.7) |

### 5.3 systems — 규칙. 표현 노드를 모른다

| 경로 | 책임 |
|---|---|
| `systems/descent_clock.gd` | `class_name DescentClock`. 고정 스텝 누산기. `1/120 s`, 프레임당 최대 4 서브스텝 |
| `systems/player_motion.gd` | `class_name PlayerMotion`. §4.1·§4.2. 순수 함수형: `(state, intent, mass, delta) -> void` (state 안의 position/velocity만 바꾼다) |
| `systems/collision.gd` | `class_name DescentCollision`. AABB 스윕. X축 먼저 → Y축. brittle 벽 파괴 판정 포함 |
| `systems/hazard_field.gd` | `class_name HazardField`. `currents[]` 적용(+`body` 부력 보정, §13.6.2), `membranes[]` 검사 |
| `systems/matter_loop.gd` | `class_name MatterLoop`. 픽업 / 맨 앞 물질 선택 / `consume` verbs 해석. atomic. `RequiresBodyGate` 를 경유해 `place.requires_body` 자리만 닫을 수 있다(§13.6.2) |
| `systems/route_resolver.gd` | `class_name RouteResolver`. `requires` 4종 평가, `opened` 추적 |
| `systems/anchors.gd` | `class_name AnchorBook`. 앵커 진입 판정 + 체크포인트 쓰기 |
| `systems/vitality.gd` | `class_name Vitality`. `integrity`, 무적 시간, `downed` 전이 |
| `systems/fauna_agent.gd` | `class_name FaunaAgent`. 순찰/추격/도망 상태기계. `pending_damage`만 만든다. `creature.state == "dead"` 인 개체는 `remains` 로만 배치하며 `pending_damage` 0건(§13.6.3) |
| `systems/ending_resolver.gd` | `class_name EndingResolver`. 열린 각문 판정 + `ModuleResult` 생성 |
| `systems/body_read.gd` | `class_name BodyRead`. §13.6.2. `body` 뷰 → `limb_deficit` / `hands_free` / `has_wound(spec)` 파생. **값을 변환하지 않고 개수만 세며**, 모르는 키는 세지 않는다 |
| `systems/requires_body.gd` | `class_name RequiresBodyGate`. `place.requires_body` 와 `BodyRead` 결과를 대조해 자리 열림/닫힘을 판정하고 실패 사유를 `Dictionary` 로 돌려준다(§13.6.2) |
| `systems/content_loader.gd` | `class_name DescentContentLoader`. `res://modules/descent_exploration/authored/strata/*.json` 로드, `index` 정렬, `next` 참조 확인 |
| `systems/content_validator.gd` | `class_name DescentContentValidator`. §9.4의 12개 규칙. 실패 시 층 로드 거부 |

### 5.4 presentation — `core/procedural/`만 사용

| 경로 | 책임 |
|---|---|
| `presentation/descent_view.gd` | `class_name DescentView`. `Node2D`. draw order 고정, Camera2D 정수 줌 스냅, §10.2 금지 목록 집행 |
| `presentation/backdrop_rig.gd` | `class_name DescentBackdropRig`. 5개 레이어의 `ProceduralBackdropDynamics` 보유. 카메라 이동·바람·펄스를 스프링 타깃으로 |
| `presentation/squish_backdrop.gd` | `class_name DescentSquishBackdrop`. 5개 레이어의 `ProceduralDeformField` 보유. 배경 **메시** 말랑말랑 변형 |
| `presentation/world_raster.gd` | `class_name DescentWorldRaster`. 층의 `solids`/`currents`/`membranes` 를 `ProceduralCanvas` + `ProceduralSdf` 로 한 번 래스터화해 캐시 |
| `presentation/palette_bank.gd` | `class_name DescentPaletteBank`. 층 ID → `ProceduralPalette`. `ProceduralPaletteScheme.build_named` 사용 |
| `presentation/player_figure.gd` | `class_name DescentPlayerFigure`. `ProceduralBodyPart` 목록 → 실루엣. **운반 물질이 몸에 붙어 그려진다** |
| `presentation/fauna_figure.gd` | `class_name DescentFaunaFigure`. `ProceduralBodyPart` 목록 → 실루엣 |
| `presentation/matter_figure.gd` | `class_name DescentMatterFigure`. 물질 4종 실루엣 |
| `presentation/transition_veil.gd` | `class_name DescentTransitionVeil`. `CanvasLayer`. §4.9의 0.9초 시퀀스 |

### 5.5 authored — 데이터 7개 (정본 6 + 증명 1)

| 경로 | 책임 |
|---|---|
| `authored/strata/stratum_roots.json` | 구간 0 `loc.roots`. 입문. 저해 없음. 사실 `current_lies` 제공. `fauna[]` 에 `fix.gardener` 의 `remains_at` 자리 1개(§13.6.3) — 저해가 아니므로 "저해 없는 층" 불변식 유지 |
| `authored/strata/stratum_halls.json` | 구간 1 `loc.halls`. brittle 벽 3개 |
| `authored/strata/stratum_teeth.json` | 구간 2 `loc.teeth`. 상승 흐름 2개 + `tag: "seed"` 막. `weigh` 물질 제공 |
| `authored/strata/stratum_nursery.json` | 구간 3 `loc.nursery`. grazer 1 + 사실 `vent_above` |
| `authored/strata/stratum_gallery.json` | 구간 4 `loc.gallery`. `thing.warden` + `strike` 물질 제공 |
| `authored/strata/stratum_floor.json` | 구간 5 `loc.floor`. 세 각문 + `thing.heart` |
| `authored/strata/stratum_extra_probe.json` | **증명 전용 7번째 층.** `index: 6`, `next: ""`, `PROBE_LAYER_EXEMPT_IDS` 대상. §14.4의 "core 무수정" 증거로 **삭제하지 않고 남긴다** |

### 5.6 이 목록에 **없는** 것 (금지)

`modules/descent_exploration/` 아래에 `.png .jpg .jpeg .webp .bmp .svg .ttf .otf .aseprite .kra` **0개.** `.wav`는 오디오만 허용하며 `.import`가 커밋되어야 한다. 전용 에디터 스크립트 없음. 인벤토리 화면 없음. HUD 컨트롤 없음. 프리팹 없음. **`core/worldstate/**` 노드·리소스 직접 참조 0개** — 축 뷰는 오직 `ModuleContext.arrival`로만 온다(§13.6.1). **`core/worldstate/**` 안의 파일도 이 Kit이 만들지 않는다.** 저장 파일 없음(§6.7).

---

## 6. Domain / State

### 6.1 필드 전체 (기본값 = 새 런 값)

| 필드 | 타입 | 기본값 | 의미 |
|---|---|---|---|
| `schema` | int | `1` | 저장 스키마 버전. `module_manifest.tres`의 `save_version`와 같아야 한다 |
| `run_id` | String | `""` | 런 식별자. `enter()`에서 `world_seed` 파생해 대입. **UI에 없음** |
| `world_seed` | int | `0` | 절차 비주얼 시드. `ProceduralSeed(world_seed, run_id, 1)` |
| `phase` | String | `"first_frame"` | `first_frame` → `playing` → `transition` → `ending` → `finished` |
| `stratum_index` | int | `0` | 0..5 |
| `stratum_id` | String | `"stratum_roots"` | 현재 층 |
| `facts` | Array[String] | `[]` | 획득한 사실 ID. 순서 보존, 중복 불가 |
| `mass` | int | `0` | 운반 질량 합계. 0..4 |
| `carried` | Array[MatterItem] | `[]` | 운반 중. **맨 앞 = `carried[0]`** |
| `consumed` | Array[Dictionary] | `[]` | `{matter, site, stratum}` 소비 기록 |
| `position` | Array[2] float | `[320.0, 96.0]` | `[x, y]` |
| `velocity` | Array[2] float | `[0.0, 0.0]` | `[vx, vy]` |
| `facing` | int | `1` | `1` 오른쪽, `-1` 왼쪽 |
| `integrity` | int | `3` | 0..3. 0이 되면 `downed` |
| `invulnerable_for` | float | `0.0` | 남은 무적 초 |
| `surge_cooldown_for` | float | `0.0` | 남은 대시 쿨다운 초 |
| `surge_active_for` | float | `0.0` | 남은 대시 지속 초 |
| `downed_for` | float | `0.0` | `downed` 경과 초. 1.4 |
| `anchors_taken` | Array[String] | `[]` | `"<stratum_id>#<anchor_id>"` |
| `sites_done` | Array[String] | `[]` | 완료한 `sites[].id` |
| `routes_opened` | Array[String] | `[]` | 통과에 사용한 `routes[].id` |
| `open_bristles` | Array[String] | `[]` | 파괴된 brittle 벽 ID. 재생성되면 사라진다 |
| `checkpoint` | Dictionary | `{}` | `{stratum_id, anchor_id, position, mass, facts, carried}`. 앵커에서만 갱신 |
| `ending_id` | String | `""` | 결말 확정되면 해당 `ending.*` |
| `elapsed_play` | float | `0.0` | `playing`에서만 증가. **판정 미사용** |
| `transition_pending` | bool | `false` | 다음 층 로드 대기 |
| `transition_to` | String | `""` | 다음 층 ID |

### 6.2 범주: runtime / transient

- **transient(저장 금지)**: `velocity`는 저장하지 않는다(§6.4). `invulnerable_for`, `surge_cooldown_for`, `surge_active_for`, `downed_for`, `transition_pending`, `transition_to`는 저장하지 않는다. 로드 직전 0으로 초기화된다. `open_bristles`도 저장하지 않는다(§6.4).
- **runtime(저장)**: 나머지 전부.
- **존재하지 않는 필드 (구현자가 추가하지 않는다):** `down_count` / `death_count` / `score` / `progress` / `elapsed_useful` 등 **모든 누적 카운터.** 죽음 횟수조차 들지 않는다. §0.2-2와 §17 참조. `elapsed_play` 만 예외인데 이것도 **표시·판정 미사용**이고 저장에서 제외해도 된다(디버깅 편의로만 저장).

### 6.3 상태 전이

```
first_frame ──(0.15s 후 자동)──> playing
playing ──(route trigger)──> transition ──(veil 완료)──> playing(next stratum)
playing ──(마지막 층 각문 도달)──> ending ──(1.6s 후 자동)──> finished
playing ──(integrity 0)──> downed(1.4s 암전)──> playing(checkpoint)
```

- `downed`는 `phase`가 아니라 `integrity == 0 and downed_for < 1.4`로 판정한다. 별도 phase를 만들지 않는다.
- `finished`에서 `finished(ModuleResult)`를 emit한다. 그 뒤 입력 잠금.

### 6.4 저장 규칙

- `Vector2`를 **절대** 넣지 않는다. `[x, y]` 배열로 넣는다. (`docs/MODULE_CONTRACT.md` §저장 금지 항목 `Vector 자체`)
- `MatterItem`는 저장 시 `to_dictionary()`로 평탄화. `procedural.gd`·`body_part.gd` 같은 표현 객체는 넣지 않는다.
- `open_bristles`는 **저장하지 않는다.** brittle 벽은 재진입 시 전부 서 있는 상태로 시작한다(진행에 영향이 없다). 저장하면 층 안에서 죽었다 왔을 때 벽 상태가 어긋난다.
- `elapsed_play`, `velocity`, 쿨다운/무적 타이머는 **저장하지 않는다.**

### 6.5 실제 저장 JSON 예시 (구간 3 도달, `tag:"seed"`를 가진 채로)

```json
{
  "schema": 1,
  "module_id": "descent_exploration",
  "run_id": "r-9f3a1c",
  "world_seed": 90210,
  "phase": "playing",
  "stratum_index": 3,
  "stratum_id": "stratum_nursery",
  "facts": ["current_lies", "vent_above"],
  "mass": 2,
  "carried": [
    { "id": "matter_seed_vial", "size": 1, "verb": "feed", "tag": "seed", "source_stratum": "stratum_teeth" },
    { "id": "matter_iron_rib", "size": 1, "verb": "weigh", "tag": "iron", "source_stratum": "stratum_nursery" }
  ],
  "consumed": [
    { "matter": "matter_brine_cap", "site": "site_teeth_membrane", "stratum": "stratum_teeth" }
  ],
  "position": [176.0, 402.0],
  "facing": 1,
  "integrity": 2,
  "anchors_taken": ["stratum_roots#a1", "stratum_halls#a1", "stratum_teeth#a1", "stratum_nursery#a1"],
  "sites_done": ["site_roots_plaque", "site_nursery_plaque"],
  "routes_opened": ["exit_roots", "exit_halls", "exit_teeth_sink", "exit_nursery"],
  "checkpoint": {
    "stratum_id": "stratum_nursery",
    "anchor_id": "a1",
    "position": [176.0, 402.0],
    "mass": 2,
    "facts": ["current_lies", "vent_above"],
    "carried": [
      { "id": "matter_seed_vial", "size": 1, "verb": "feed", "tag": "seed", "source_stratum": "stratum_teeth" }
    ]
  },
  "ending_id": "",
  "elapsed_play": 431.5
}
```

**JSON-safe 검사**: string / number / bool / array / Dictionary 만. `NaN`/`Inf` 0건. Node/Resource/Callable/Vector 0건.

### 6.6 invalid / stale 처리

| 상황 | 처리 |
|---|---|
| `schema`가 1이 아님 | `migrate_save(old, data)`가 1로 되돌린 뒤 로드. 실패하면 `{schema:1}`로 리셋하고 `first_frame`부터 |
| `stratum_id`가 authored 디렉터리에 없음 | 층 로드를 거부하고 `index`가 가장 가까운 다음 층으로 대체. `push_warning` 1회. **게임이 멈추지 않는다** |
| `carried` 총 질량이 4 초과 | 뒤에서부터 버려 4로 맞춘다. 앞에서부터 자르지 않는다(맨 앞 물질이 소비 대상이므로) |
| `carried` 안 물질의 `verb`/`tag`가 스키마 밖 | 그 물질만 제거 |
| `facts`에 모르는 ID | **그대로 둔다.** 사라지면 이후 저장이 새로 만들어진다. 알고 있는 fact ID 목록을 Kit이 갖고 있지 않으므로 판정할 수 없다 |
| `checkpoint`가 비어 있음 | `stratum_index`의 첫 앵커로 복원. 앵커 없는 층이면 그 층 `spawn` |
| `carried`가 빈데 `consumed`이 있음 | 정상. 허용 |
| `ending_id`가 3종 밖 | `""`로 되돌림, `playing` 재개 |

### 6.7 읽기 전용 입력 — 세 축 (`body` / `creature` / `place`)

**세 축은 이 Kit의 필드가 아니다.** 위 §6.1 표에 `body`·`creature`·`place` 항목이 **없는 것이 정답**이며, 추가하면 규칙 위반이다. 이 Kit은 축을 **읽기만** 하고 어떤 값도 **저장하지 않으며**, 어떤 값도 **바꿀 수 없다.** (§13.6)

| 축 | 소유 | 이 Kit의 쓰기 | 이 Kit이 실제로 파생하는 값 |
|---|---|---|---|
| `body` | `sideview_ecosystem` | 요청만 | `limb_deficit`(0..4) · `hands_free`(0..2) · `has_wound(spec)` |
| `creature` | `sideview_ecosystem` | 요청만 | `remains` 배치 여부 1개 |
| `place` | authored content (런타임 불변) | **없음** | `requires_body` 자리 열림/닫힘 |

**`arrival["worldstate"]` 실제 JSON 예시** (이 Kit이 받는 뷰. 축 필드 이름은 `core/worldstate/CONTRACT.md` 가 정본이다):

```json
{
  "body": {
    "scale": 0.82,
    "missing": [
      { "part": "arm_left", "kind": "lost", "severity": 4, "permanent": true }
    ],
    "wounds": [
      { "part": "face", "kind": "crack", "severity": 3, "permanent": true },
      { "part": "torso", "kind": "shard", "severity": 1, "permanent": true }
    ]
  },
  "creature": {
    "fix.gardener": {
      "id": "fix.gardener",
      "archetype": "gardener",
      "stage": 2,
      "state": "dead",
      "den": "place.ruined_garden"
    },
    "fix.butler": {
      "id": "fix.butler",
      "archetype": "butler",
      "stage": 3,
      "state": "alive",
      "den": "place.tea_stair"
    }
  },
  "place": {
    "place.ruined_garden": { "id": "place.ruined_garden", "region_id": "region_hollow", "tags": [], "requires_body": {} },
    "place.tea_stair": { "id": "place.tea_stair", "region_id": "region_hollow", "tags": [], "requires_body": { "scale_min": 0.7 } },
    "place.mirror_march": { "id": "place.mirror_march", "region_id": "region_hollow", "tags": [], "requires_body": { "wound": { "part": "face", "kind": "crack", "severity_min": 2, "permanent": true } } }
  }
}
```

위 예시에서 이 Kit이 실제로 뽑아내는 값은 **정확히 3개**다: `limb_deficit = 1`(arm_left 1개) · `hands_free = 2`(손 부재 0개) · `has_wound(face/crack/severity_min 2/permanent)` = 참(severity 3 ≥ 2). `archetype`·`stage`·`scale`·`tags` 는 **판정에 쓰지 않는다**(§13.6.3, §13.6.4).

**정규화 금지의 적용.** `body.scale` 0.82 를 0..1 로, `severity` 3 을 0..3 으로 **바꾸지 않는다.** `body` 가 준 값을 그대로 비교하거나, **개수만** 센다. `body` 키가 아예 없으면 파생값을 만들지 않고 그 규칙을 적용하지 않는다(§13.6.1).

**이 Kit의 저장은 VIEW 다 — 원본이 아니다.** (§13.6)
- 위 §6.5 JSON은 이 Kit의 **뷰**이며 **원본이 아니다.** 원본은 `core/worldstate` 의 저장 **한 벌**이고, 이 Kit의 세이브는 그 중 `descent_exploration` 한 조각이다.
- 그래서 이 Kit의 세이브를 단독으로 읽어 world를 복원하지 않는다. 이 Kit은 자기 세이브를 **쓰고 읽기만** 한다.
- **`DescentState` 에 `body`·`creature`·`place` 을 캐시해 두지 않는다.** 뷰는 매 진입마다 `arrival`로 다시 받는다. 저장에도, 런타임 필드에도 축 사본이 남지 않는다.
- 원본과 이 뷰가 어긋나면 **이 Kit이 고치는 쪽이 아니다.** 복원 실패를 조용히 기본값으로 덮는 것도 이 Kit이 하지 않는다(§6.6, §7).
- `ax` 버전에 대한 **쓰기 코드는 이 Kit에 없다.** 정합 확인도 요청하지 않는다 — 요청은 §13.6.5의 brittle 1회뿐이고 그것은 `body` 상처다.

---

## 7. 프레임 처리 순서

**고정 스텝 1/120 s. 프레임당 최대 4 서브스텝.** 4회를 넘으면 나머지는 버린다(터널링 방지). 렌더는 프레임당 1회.

```
_PHYSICS (반복, 서브스텝당 1회)
  1  DescentClock.begin_frame(delta)                     # 누산, 서브스텝 개수 계산
  2  module.read_intent()  -> RunIntent                 # ModuleContext 만 사용
       - up / down / surge / consume 4개 bool. surge·consume는 pressed 순간만 true
  3  PlayerMotion.step(state, intent, state.mass, h)     # position/velocity 갱신
  4  DescentCollision.resolve(state)                     # X축 스윕 → Y축 스윕
       - brittle 벽 접촉 + surge 중이면 파괴, open_bristles에 추가
  5  HazardField.apply(state, h)                         # currents 가속도, membranes 판정
  6  MatterLoop.tick_pickup(state)                       # 반경 6px, 배낭 여유 있을 때만
  7  FaunaAgent.step_all(state, h) -> Array[Dictionary]  # pending_damage만 만든다(적용 금지)
  8  Vitality.apply(state, pending_damage, h)            # integrity 감소, 무적 시작, downed
  9  AnchorBook.check(state) -> bool                     # 앵커 진입. true면 checkpoint 갱신 + 저장 요청
 10  RouteResolver.evaluate(state)                       # requires 4종 재평가, routes_opened 기록
 11  MatterLoop.consume(state, intent.consume)           # atomic. 대상 반경 8px
 12  StratumRuntime.check_exit(state)                    # descent route trigger 접촉
 13  if transition_pending: break                        # 이하 서브스텝 중단, Veil로 이관
_RENDER (프레임당 1회)
 14  DescentView.sync(state)                             # 정수 줌 스냅, 카메라, draw
 15  BackdropRig.step(frame_delta)                       # ProceduralBackdropDynamics 5개 step
 16  SquishBackdrop.step(frame_delta)                    # ProceduralDeformField 5개 step
 17  PlayerFigure.draw / FaunaFigure.draw / MatterFigure.draw
 18  module.emit_audio_events(state)                     # AudioEventPlayer.play
```

**순서 의존성 규칙 (깨면 안 된다):**
- 4(충돌) → 5(위험): 벽에 막힌 상태에서 흐름이 적용되어야挤压이 생긴다. 반대로 하면 벽을 뚫는다.
- 7(피해 계산) → 8(피해 적용): 피해는 `pending_damage`에 쌓인다가 8에서 한꺼번에 적용. 7 안에서 `integrity`를 만지지 않는다.
- 9(앵커) → 10(routes): 앵커가 `sites_done`를 갱신할 수 있으므로, `opened` 조건이 앵커 뒤에 와야 한다.
- 11(consume) → 12(exit): 같은 서브스텝에서 물질을 먹고 층을 나갈 수 있다.
- **표현은 3~13의 어떤 것도 읽지 않는다.** 단 `state.mass`와 `state.position`만 읽는다.

**하강 입력이 0일 때**: 3~5는 계속 돈다(가라앉음). 그래서 10분 Reference Game에서 **대기 시간은 발생하지 않는다.** 정지 상태로 대기할 수 있는 유일한 경우는 `transition_pending` 0.9초와 `downed` 1.4초, 합쳐서 층당 최대 2.3초다. (§14 시간 예산에서 계산한다)

---

## 8. 상수표 (이 표가 정본이다. "튜닝으로" 금지)

### 8.1 공간 / 카메라

| 이름 | 값 | 단위 | 비고 |
|---|---|---|---|
| `DESIGN_W` | `640` | world unit | 1280×720에서 zoom 2.0 |
| `DESIGN_H` | `360` | world unit | 1920×1080에서 zoom 3.0, 2560×1440에서 zoom 4.0 |
| `GRID` | `16` | world unit | authored 좌표 스냅 단위 |
| `STRATUM_W` | `640` | world unit | 모든 층의 가로 동일 |
| `STRATUM_H` | `1024` | world unit | 모든 층의 세로 동일 |
| `CAMERA_LOOKAHEAD` | `24` | world unit | 수평은 `facing`, 수직은 속도 방향 |
| `CAMERA_LERP_PER_SEC` | `9.0` | 1/s | 지수 추종 |
| `ZOOM_STEPS` | `[2, 3, 4]` | | `floor(viewport.w / 640)` 을 2~4로 클램프 |
| `BASE_BOX` | `Vector2(9, 7)` | px | mass 0 몸 |
| `BOX_PER_MASS` | `Vector2(2, 2)` | px | mass 1당 가산 |

### 8.2 이동 (`PlayerMotion`)

| 이름 | 값 | 단위 |
|---|---|---|
| `FIXED_HZ` | `120.0` | 1/s |
| `MAX_SUBSTEPS` | `4` | — |
| `SWIM_UP_SPEED` | `70.0` | px/s |
| `SINK_ACCEL` | `22.0` | px/s² |
| `SINK_TERMINAL_BASE` | `30.0` | px/s |
| `SINK_PER_MASS` | `14.0` | px/s (mass 4 → 86) |
| `DIVE_ACCEL` | `46.0` | px/s² |
| `DIVE_TERMINAL_FACTOR` | `1.25` | 배 |
| `HORIZ_MAX_BASE` | `62.0` | px/s |
| `HORIZ_MAX_PER_MASS` | `3.0` | px/s 감소 (mass 4 → 50) |
| `HORIZ_ACCEL_BASE` | `240.0` | px/s² |
| `HORIZ_ACCEL_PER_MASS` | `28.0` | px/s² 감소 (mass 4 → 128) |
| `LINEAR_DRAG` | `1.6` | 1/s |
| `FACING_SWITCH_MIN` | `8.0` | px/s (이 속도 이상에서만 `facing` 반전) |
| `SURGE_SPEED_BASE` | `168.0` | px/s |
| `SURGE_SPEED_PER_MASS` | `20.0` | px/s 감소 (mass 4 → 88) |
| `SURGE_TIME` | `0.16` | s |
| `SURGE_COOLDOWN` | `0.45` | s |
| `SURGE_BREAKS_BRITTLE` | `true` | — |
| `MAX_CARRY_MASS` | `4` | — |
| `PICKUP_RADIUS` | `6.0` | px |
| `USE_RADIUS` | `8.0` | px |
| `REGROW_SECONDS` | `0.4` | s (brittle 벽 재생성) |

### 8.3 생명 / 저해

| 이름 | 값 | 단위 |
|---|---|---|
| `INTEGRITY_MAX` | `3` | — |
| `DAMAGE_PER_HIT` | `1` | — |
| `INVULNERABLE_TIME` | `1.20` | s |
| `DOWNED_BLACKOUT` | `1.40` | s |
| `DOWNED_FADE_IN` | `0.30` | s |
| `GRAZER_PATROL_SPEED` | `34.0` | px/s |
| `GRAZER_CHASE_SPEED` | `50.0` | px/s (mass 1의 수평 최대 59 < 50 아님 → 질 수 있다) |
| `GRAZER_FLEE_MASS` | `2` | 이 mass 이상이면 도망 |
| `GRAZER_LOSE_RADIUS` | `140.0` | px (이 거리 초과 시 순찰 복귀) |
| `WARDEN_IGNORE_TOP` | `240.0` | px (층 4 spawn 기준 위쪽 무효) |
| `WARDEN_CHASE_SPEED` | `56.0` | px/s (**mass 3의 수평 최대 53 < 56 → 추격을 벗어날 수 없다**) |
| `FAUNA_CONTACT_RADIUS` | `7.0` | px |
| `HEART_MELD_RADIUS` | `56.0` | px (`ending.swallow` 각문 앞) |
| `TIDE_MAIN_FLOW` | `[0.0, -62.0]` | px/s (구간 2. mass 2의 하강 58 < 62 → 통과 불가, mass 3의 72 > 62 → 통과) |
| `RETURN_FLOW` | `[0.0, -26.0]` | px/s (`mouth.above` 앞 화로. mass 0의 하강 30 > 26 → 올라갈 수 있다) |
| `RETURN_ASCENT_TIME` | `13.1` | s (화로 720px ÷ (`SWIM_UP_SPEED` 70 − 26) 44px/s) |
| `LIMB_PARTS` | `["arm_left", "arm_right", "leg_left", "leg_right"]` | `body.missing` 중 부력으로 **센다**는 part (§13.6.2) |
| `HAND_PARTS` | `["hand_left", "hand_right"]` | `body.missing` 중 `hands_min` 으로 **센다**는 part (§13.6.2) |
| `HANDS_TOTAL` | `2` | — |
| `BUOY_PER_LIMB` | `6.0` | px/s (부족한 팔다리 1개당 상승 보정. 흐름 안에서만 적용, free-fall 무영향) |
| `HEART_MELD_HANDS_MIN` | `1` | `heart_meld` 자리의 `place.requires_body.hands_min` (§13.6.2) |
| `WORLDSTATE_REQUEST_MAX_PER_RUN` | `1` | 이 Kit이 스토어에 요청하는 최대 횟수 (brittle 최초 파괴 1회) |

### 8.4 전환 / 시네마틱

| 이름 | 값 | 단위 |
|---|---|---|
| `FIRST_FRAME_HOLD` | `0.15` | s |
| `VEIL_TOTAL` | `0.90` | s |
| `VEIL_FADE_OUT` | `0.35` | s |
| `VEIL_FLASH_FRAMES` | `12` | 프레임 (단색 + 12프레임 축소) |
| `VEIL_FADE_IN` | `0.40` | s |
| `ENDING_HOLD` | `1.60` | s |
| `ANCHOR_FLASH` | `3.00` | s |

### 8.5 표현

| 이름 | 값 | 단위 |
|---|---|---|
| `LAYER_COUNT` | `5` | SKY/FAR/MID/NEAR/FOREGROUND |
| `BACKDROP_STIFFNESS` | `[40.0, 52.0, 64.0, 76.0, 88.0]` | 층별 |
| `BACKDROP_DAMPING` | `[0.85, 0.80, 0.75, 0.70, 0.65]` | 층별 |
| `BACKDROP_PARALLAX` | `[0.08, 0.20, 0.42, 0.70, 1.00]` | 층별 |
| `BACKDROP_FIELD_AMP` | `[2.0, 3.5, 5.0, 7.0, 9.0]` | px |
| `BACKDROP_PHASE_SPEED` | `12.0` | px/s (기본값) |
| `BACKDROP_WIND` | `[0.0, 6.0]` | px/s |
| `DEFORM_GRID` | `[[10,22],[8,20],[8,18],[6,16],[6,14]]` | 레이어별 grid (w,h) |
| `DEFORM_AMPLITUDE` | `[3.0, 4.5, 6.0, 8.0, 10.0]` | px |
| `DEFORM_STIFFNESS` | `[150.0, 140.0, 120.0, 100.0, 90.0]` | — |
| `DEFORM_DAMPING` | `[0.80, 0.75, 0.70, 0.65, 0.60]` | — |
| `SPRING_MASS_FOLLOW` | `120.0` | 표시 질량 추종 강성 |
| `SPRING_MASS_DAMPING` | `0.55` | — |
| `MASS_VISUAL_STEPS` | `16` | 정수 mass를 보간할 구간 수 |
| `ACCENT_FLASH_DECAY` | `0.55` | 1/s |

### 8.6 절차 비주얼 — 이 Kit이 쓰는 호출 (C1 동결 이름 그대로)

| 호출 | 용도 |
|---|---|
| `ProceduralSeed(world_seed, run_id, 1)` | 런 시드 |
| `.derive(stratum_id)` | 층별 시드 |
| `ProceduralPaletteScheme.new().build_named(seed, &"analogous", index % 4)` | 층 팔레트 |
| `ProceduralNoiseField(seed, &"shape" / &"flow" / &"squish")` | 배경 층 위상 |
| `ProceduralCanvas(640, 1024)` | 층 월드 래스터 |
| `ProceduralSdf.rounded_box / circle / capsule`, `.stamp_field`, `.stroke_field`, `.shadow_field` | 벽·흐름·막 래스터화 |
| `ProceduralBodyPart(id, kind).configure(dict)` → `.draw(canvas, palette, pose)` | 개체 실루엣 |
| `ProceduralDeformField(w, h).build_grid(w, h, rect)` → `.excite()` → `.step()` → `.get_offset(u,v)` / `.build_triangles()` | **배경 말랑말랑 변형** |
| `ProceduralBackdropDynamics(layer)` → `.add_anchor()`, `.configure()`, `.attach_field()`, `.set_view_offset()`, `.set_wind()`, `.pulse()`, `.step()`, `.get_offset(i)` | **배경 물리 운동** |
| `ProceduralSpring.critical(v, k)` / `.under_damped(v, k, r)` | 표시 질량·앵커 섬광 |

**이 Kit은 `procedural.gd` / `creature_builder.gd` / `squish_rig.gd`를 쓰지 않는다.** ROUND_PLAN C1은 이 세 파일의 경로만 동결하고 클래스명을 동결하지 않았다. 이 Kit은 클래스명이 확인된 파일만 쓴다. 그 세 파일이 나중에 생겨도 이 Kit은 수정하지 않는다.

---

## 9. Authored content 포맷

### 9.1 단위

**authored content 단위 = 하강 구간(stratum) 하나 = JSON 파일 1개.**
새 구간 추가 = `authored/strata/` 에 JSON 1개 추가 + loader가 `index`로 정렬. **core 수정 0.**

### 9.2 정확한 스키마

顶层 키 (모두 **필수**, 하나라도 없으면 로드 거부):

| 키 | 타입 | 제약 |
|---|---|---|
| `schema` | int | `== 1` |
| `id` | String | `^stratum_[a-z_]+$`, 파일명과 동일 |
| `index` | int | 0 이상. 전체에서 중복 불가. `load()` 후 오름차순 정렬 |
| `location` | String | `loc.*` 형식 |
| `display_name` | String | 비어 있지 않음. **화면에 표시되지 않는다** |
| `world_seed` | int | 0..2147483647 |
| `palette` | Dictionary | `scheme`(StringName), `base_hue`(0..1), `saturation`(0..1), `contrast`(0.2..2.0), `variant`(0..15) |
| `bounds` | Dictionary | `width == 640`, `height == 1024` |
| `spawn` | Dictionary | `position` `[x,y]` (0..640, 0..1024), `facing` ±1 |
| `solids` | Array[Dictionary] | `id`, `rect` `[x,y,w,h]`, `kind` ∈ `ground`/`wall`/`brittle`, `regrow_seconds`(brittle만, 기본 0.4) |
| `currents` | Array[Dictionary] | `id`, `rect`, `flow` `[fx,fy]` (둘 다 0 이면 무효. `fy > 0` 은 아래로 미는 힘) |
| `membranes` | Array[Dictionary] | `id`, `rect`, `tag`(String), `hold_seconds`(기본 0.5) |
| `routes` | Array[Dictionary] | §9.3 |
| `sites` | Array[Dictionary] | `id`, `kind` ∈ `plaque`, `position`, `radius`, `grants_fact`(String) |
| `matter` | Array[Dictionary] | `id`, `position`, `size`(1..3), `verb` ∈ `plug`/`feed`/`strike`/`weigh`, `tag`(String) |
| `anchors` | Array[Dictionary] | `id`, `position`, `radius`(기본 12) |
| `fauna` | Array[Dictionary] | `id`, `kind` ∈ `grazer`/`warden`, `position`, `patrol` `[y0,y1]`, `line_y`(warden만) |
| `backdrop` | Dictionary | `wind` `[x,y]`, `deform_grid` `[[w,h] × 5]`, `pulse_on` Array[String] (이 층의 `solids`/`fauna`/`matter` ID) |

모든 배열은 **0개여도 된다.** 단 `routes`에는 `kind: "descent"` 가 **정확히 1개** 있어야 하고, 그것의 `next`는 마지막 층이 아닐 경우 존재해야 한다.

### 9.3 route 객체

| 키 | 타입 | 의미 |
|---|---|---|
| `id` | String | `^exit_` 또는 `^mouth\.` 로 시작 |
| `kind` | String | `descent` (다음 층) / `site_route` (층 안 이동) / `ending` (결말) |
| `trigger` | `[x,y,w,h]` | 접촉 시 발동. `kind: "descent"`와 `kind: "ending"`는 필수, `site_route`는 없음 |
| `requires` | Array[Dictionary] | **OR** 조건. §9.5의 4종 |
| `blocks_tag` | Array[String] | 통과 시 이 tag 물질을 못 쓰게 함. `ending`에서만 사용 |
| `next` | String | `kind: "descent"`일 때 다음 층 ID |

### 9.4 검증 규칙 13개 (`content_validator.gd`, 하나라도 실패하면 층 로드 거부)

1. `schema == 1`
2. `id` == 파일명(`.json` 제거)
3. `index` >= 0
4. `bounds.width == 640 && bounds.height == 1024`
5. 모든 좌표가 `[0, 640] × [0, 1024]` 안에 있다 (경계 포함)
6. `solids` / `matter` / `anchors` / `fauna` / `sites` / `currents` / `membranes` 안의 `id` 가 층 내에서 중복 없음
7. `kind: "descent"` route 가 정확히 1개
8. `kind: "descent"` route 의 `next` 가 `authored/strata/` 에 존재하거나 빈 문자열(마지막 층)
9. `kind: "ending"` route 가 3개이고 그 id 가 `mouth.still` / `mouth.above` / `mouth.heart` 와 정확히 일치
10. `requires` 의 모든 항목이 §9.5의 5종 중 하나이고, `fact` 의 값이 앞 층의 `sites[].grants_fact` 에 존재하며, `opened` 의 `site_id` 가 앞 층의 `sites[].id` 에 존재
11. **모든 `descent` route 에 `clearance` 가 있으면 그 층에 `clearance`가 아닌 대체 `descent` route 가 1개 이상 있다** (순수 숫자 게이트 금지)
12. `fauna[].kind == "warden"` 인 층에는 `line_y` 가 있고, `kind == "grazer"` 인 층에는 `line_y` 가 없다
13. 어떤 `membranes[].rect` 도 `kind: "descent"` 또는 `kind: "ending"` 인 `trigger` 와 겹치지 않는다

**검증 실패 메시지는 어느 층의 어느 키 때문인지 문자열로만 남긴다**(`push_warning`). `push_error`를 호출해 루프를 멈추지 않는다. 단 11번이 실패하면 그 층은 **배포 불가**다(§9.6).

**예외 상수 1개 (이것만 존재한다):** `content_validator.gd` 의 `const PROBE_LAYER_EXEMPT_IDS: PackedStringArray = PackedStringArray(["stratum_extra_probe"])` — 이 ID의 층은 규칙 9(`ending` route 3개)를 적용받지 않는다. 그 외 **12개 예외를 추가하지 않는다.** 이 상수는 §14.4의 "새 content 추가 무수정" 증명 전용이며 Reference Game에는 `probe` 층을 포함하지 않는다.

### 9.5 `requires` 5종 (배열 안에서는 **OR**)

| kind | 필드 | 판정 | 누적? |
|---|---|---|---|
| `always` | — | 항상 참 | 아니오 |
| `fact` | `fact` | `FactLedger.has(fact)` | 아니오 (지식) |
| `clearance` | `mass`(1..4) | **그 문에 닿는 그 순간** `state.mass >= mass` | 아니오 (순간 물리량) |
| `tag_available` | `verb`, `tag` | `carried` 안에 `verb`과 `tag`가 모두 일치하는 물질이 있음 | 아니오 (소지) |
| `opened` | `site_id` | `sites_done` 에 `site_id` 가 있음 | 아니오 (해당 층 1회) |

### 9.6 작업 예시 1 — `stratum_roots.json` (구간 0, 입문)

```json
{
  "schema": 1,
  "id": "stratum_roots",
  "index": 0,
  "location": "loc.roots",
  "display_name": "뿌리층",
  "world_seed": 10427,
  "palette": { "scheme": "analogous", "base_hue": 0.31, "saturation": 0.38, "contrast": 0.92, "variant": 0 },
  "bounds": { "width": 640, "height": 1024 },
  "spawn": { "position": [320, 96], "facing": 1 },
  "solids": [
    { "id": "ground_roots", "rect": [0, 0, 640, 64], "kind": "ground" },
    { "id": "wall_left", "rect": [0, 64, 40, 960], "kind": "wall" },
    { "id": "wall_right", "rect": [600, 64, 40, 960], "kind": "wall" },
    { "id": "ledge_high", "rect": [400, 300, 200, 24], "kind": "wall" },
    { "id": "throat_left", "rect": [40, 640, 240, 200], "kind": "wall" },
    { "id": "throat_right", "rect": [360, 640, 240, 200], "kind": "wall" },
    { "id": "throat_wall", "rect": [280, 640, 80, 200], "kind": "brittle", "regrow_seconds": 0.4 }
  ],
  "currents": [],
  "membranes": [],
  "routes": [
    {
      "id": "exit_roots",
      "kind": "descent",
      "trigger": [280, 928, 80, 80],
      "requires": [{ "kind": "always" }],
      "next": "stratum_halls"
    }
  ],
  "sites": [
    { "id": "site_roots_plaque", "kind": "plaque", "position": [128, 512], "radius": 14, "grants_fact": "current_lies" }
  ],
  "matter": [
    { "id": "matter_roots_bead", "position": [452, 276], "size": 1, "verb": "weigh", "tag": "bead" }
  ],
  "anchors": [
    { "id": "a1", "position": [200, 600], "radius": 12 }
  ],
  "fauna": [],
  "backdrop": {
    "wind": [0.0, 6.0],
    "deform_grid": [[10, 22], [8, 20], [8, 18], [6, 16], [6, 14]],
    "pulse_on": ["matter_roots_bead", "throat_wall"]
  }
}
```

### 9.7 작업 예시 2 — `stratum_teeth.json` (구간 2, 첫 분기 — 이 Kit의 핵심 층)

```json
{
  "schema": 1,
  "id": "stratum_teeth",
  "index": 2,
  "location": "loc.teeth",
  "display_name": "이빨층",
  "world_seed": 22188,
  "palette": { "scheme": "split_complementary", "base_hue": 0.06, "saturation": 0.52, "contrast": 1.08, "variant": 2 },
  "bounds": { "width": 640, "height": 1024 },
  "spawn": { "position": [120, 96], "facing": 1 },
  "solids": [
    { "id": "ground_teeth", "rect": [0, 0, 640, 64], "kind": "ground" },
    { "id": "wall_left", "rect": [0, 64, 40, 960], "kind": "wall" },
    { "id": "wall_right", "rect": [600, 64, 40, 960], "kind": "wall" },
    { "id": "cap_ledge", "rect": [80, 240, 176, 24], "kind": "wall" },
    { "id": "seam_ledge", "rect": [440, 560, 160, 24], "kind": "wall" },
    { "id": "silt_ridge", "rect": [120, 840, 200, 24], "kind": "wall" }
  ],
  "currents": [
    { "id": "tide_main", "rect": [40, 928, 560, 80], "flow": [0.0, -62.0] }
  ],
  "membranes": [
    { "id": "membrane_brine", "rect": [400, 968, 200, 40], "tag": "brine", "hold_seconds": 0.6 }
  ],
  "routes": [
    {
      "id": "exit_teeth_sink",
      "kind": "descent",
      "trigger": [40, 976, 240, 32],
      "requires": [{ "kind": "clearance", "mass": 3 }],
      "next": "stratum_nursery"
    },
    {
      "id": "exit_teeth_plug",
      "kind": "descent",
      "trigger": [400, 976, 200, 32],
      "requires": [{ "kind": "always" }],
      "next": "stratum_nursery"
    }
  ],
  "sites": [],
  "matter": [
    { "id": "matter_seed_vial", "position": [148, 216], "size": 1, "verb": "feed", "tag": "seed" },
    { "id": "matter_brine_plug", "position": [520, 536], "size": 3, "verb": "plug", "tag": "brine" },
    { "id": "matter_teeth_shard", "position": [220, 816], "size": 1, "verb": "strike", "tag": "shard" }
  ],
  "anchors": [
    { "id": "a1", "position": [200, 120], "radius": 12 }
  ],
  "fauna": [],
  "backdrop": {
    "wind": [-4.0, 9.0],
    "deform_grid": [[10, 22], [8, 20], [8, 18], [6, 16], [6, 14]],
    "pulse_on": ["matter_seed_vial", "matter_brine_plug", "tide_main", "membrane_brine"]
  }
}
```

**이 층이 §0.2-3의 논리 장치다. 세 결과가 정확히 세 개로 갈린다:**

| 가지고 있던 것 | 결과 | 이유 |
|---|---|---|
| `matter_roots_bead`(1) + `matter_teeth_shard`(1) + `matter_seed_vial`(1) = **mass 3** | `exit_teeth_sink` 통과, `seed`를 들고 내려간다 | 하강 72 > 물살 62. `ending.swallow`이 이번 런에서 가능하다 |
| `matter_roots_bead`(1) + `matter_brine_plug`(3) = **mass 4** | `membrane_brine` 에 plug 소비(→ mass 1) 후 `exit_teeth_plug` 통과 | 물살이 막고 있는 오른쪽이 뚫린다. `seed`를 못 얻었으니 `ending.swallow`은 불가능 |
| `matter_roots_bead`(1) + `matter_seed_vial`(1) = **mass 2** | **두 경로 모두 막힘** | 하강 58 < 물살 62. plug나 shard 중 하나를 더 얻으러 되돌아가야 한다 |

- `matter_teeth_shard`는 `matter_teeth_stone`이 아니다. **이 층에 `weigh` 물질이 없다.** 무게는 구간 0의 `matter_roots_bead`가 유일한 공급원이다. 그러므로 구간 0의 구슬을 건너뛴 런은 **mass 3에 도달할 수 없고, plug를 얻어 이 층을 통과할 수도 없다**(`seed` 1 + `shard` 1 = 2 < 3, plug 3 + seed 1 = 4지만 그럼 `seed`를 들고 `mass 4`로 물살을 뚫을 수는 있다). 이 함정은 **authored가 의도한 회복 가능 상태**이며, 되돌아가 `silt_ridge` 위로 올라가 `matter_brine_plug`을 집으면 반드시 열린다. **무한정 막히지 않는다.**
- `matter_brine_plug`의 `size: 3`은 계산된 값이 아니다. **1이면 mass 2에 plug를 더해도 3이라 두 경로가 동선이 되고, 4이면 `seed`를 같이 들 수 없다.** 3이 유일하게 `clearance: 3` 경로와 상호배타를 만드는 값이다.

### 9.8 작업 예시 3 — `stratum_nursery.json` (구간 3)

```json
{
  "schema": 1,
  "id": "stratum_nursery",
  "index": 3,
  "location": "loc.nursery",
  "display_name": "육자층",
  "world_seed": 30877,
  "palette": { "scheme": "analogous", "base_hue": 0.94, "saturation": 0.30, "contrast": 0.86, "variant": 3 },
  "bounds": { "width": 640, "height": 1024 },
  "spawn": { "position": [80, 96], "facing": 1 },
  "solids": [
    { "id": "ground_nursery", "rect": [0, 0, 640, 64], "kind": "ground" },
    { "id": "wall_left", "rect": [0, 64, 40, 960], "kind": "wall" },
    { "id": "wall_right", "rect": [600, 64, 40, 960], "kind": "wall" },
    { "id": "nest_ledge", "rect": [360, 320, 240, 24], "kind": "wall" },
    { "id": "plaque_ceiling", "rect": [470, 440, 130, 16], "kind": "wall" },
    { "id": "plaque_floor", "rect": [470, 520, 130, 16], "kind": "wall" },
    { "id": "plaque_back", "rect": [584, 456, 16, 64], "kind": "wall" },
    { "id": "plaque_wall", "rect": [470, 456, 16, 64], "kind": "brittle", "regrow_seconds": 0.4 },
    { "id": "rib_pocket", "rect": [40, 640, 200, 24], "kind": "wall" }
  ],
  "currents": [],
  "membranes": [],
  "routes": [
    {
      "id": "exit_nursery",
      "kind": "descent",
      "trigger": [280, 960, 80, 64],
      "requires": [{ "kind": "always" }],
      "next": "stratum_gallery"
    }
  ],
  "sites": [
    { "id": "site_nursery_plaque", "kind": "plaque", "position": [540, 488], "radius": 14, "grants_fact": "vent_above" }
  ],
  "matter": [
    { "id": "matter_nursery_rib", "position": [140, 616], "size": 1, "verb": "weigh", "tag": "rib" }
  ],
  "anchors": [
    { "id": "a1", "position": [80, 300], "radius": 12 }
  ],
  "fauna": [
    { "id": "fauna_nursery_grazer", "kind": "grazer", "position": [320, 500], "patrol": [200, 820] }
  ],
  "backdrop": {
    "wind": [3.0, 4.0],
    "deform_grid": [[10, 22], [8, 20], [8, 18], [6, 16], [6, 14]],
    "pulse_on": ["fauna_nursery_grazer", "plaque_wall", "site_nursery_plaque", "matter_nursery_rib"]
  }
}
```

- `site_nursery_plaque`는 **상자 안에 갇혀 있다.** `plaque_ceiling`(y 440~456) / `plaque_floor`(y 520~536) / `plaque_back`(x 584~600) / `plaque_wall`(x 470~486, brittle)가 감싸고 **유일한 입구는 brittle 벽 하나**다. plaque 반경 14이므로 `x 470` 밖에서는 닿을 수 없다. **따라서 `vent_above`는 "우연히 얻는 사실"이 아니라 "brittle 벽을 부수는 대가를 내고 얻는 지식"이다.** `plaque_wall`은 `regrow_seconds: 0.4` 이므로 들어갔다 나오면 다시 막힌다.
- `matter_nursery_rib`(weigh 1)는 `rib_pocket` 위에 있다. **mass 1로 들어온 플레이어가 grazer를 피하려면 이것을 먹어야 mass 2가 된다.** 이것이 §4.5의 난이도 호의 물리적 구현이다.
- `matter_roots_bead`(weigh 1)와 합치면 `weigh`가 2개 쌓인다. `weigh` verb는 목표가 없으므로 **어디에도 소비되지 않는다.** 이것은 허용이다(`weigh`는 무게만 파는 물질이라는 정의). 2개를 들고 구간 4에 가면 warden를 절대 못 피한다. **그것이 `weigh`의 대가다.**

### 9.9 작업 예시 4 — `stratum_gallery.json` (구간 4)

```json
{
  "schema": 1,
  "id": "stratum_gallery",
  "index": 4,
  "location": "loc.gallery",
  "display_name": "전시층",
  "world_seed": 41190,
  "palette": { "scheme": "tetradic", "base_hue": 0.74, "saturation": 0.24, "contrast": 1.12, "variant": 1 },
  "bounds": { "width": 640, "height": 1024 },
  "spawn": { "position": [320, 64], "facing": 1 },
  "solids": [
    { "id": "wall_left", "rect": [0, 0, 40, 1024], "kind": "wall" },
    { "id": "wall_right", "rect": [600, 0, 40, 1024], "kind": "wall" },
    { "id": "gallery_deck_a", "rect": [400, 200, 200, 24], "kind": "wall" },
    { "id": "gallery_deck_b", "rect": [280, 400, 200, 24], "kind": "wall" },
    { "id": "vault_ceiling", "rect": [470, 520, 130, 16], "kind": "wall" },
    { "id": "vault_floor", "rect": [470, 584, 130, 16], "kind": "wall" },
    { "id": "vault_back", "rect": [584, 536, 16, 48], "kind": "wall" },
    { "id": "vault_wall", "rect": [470, 536, 16, 48], "kind": "brittle", "regrow_seconds": 0.4 },
    { "id": "gallery_floor", "rect": [0, 1010, 640, 14], "kind": "ground" }
  ],
  "currents": [],
  "membranes": [],
  "routes": [
    {
      "id": "exit_gallery",
      "kind": "descent",
      "trigger": [280, 960, 80, 50],
      "requires": [{ "kind": "always" }],
      "next": "stratum_floor"
    },
    {
      "id": "gallery_vault",
      "kind": "site_route",
      "requires": [{ "kind": "opened", "site_id": "site_nursery_plaque" }],
      "next": ""
    }
  ],
  "sites": [],
  "matter": [
    { "id": "matter_gallery_hammer", "position": [540, 560], "size": 1, "verb": "strike", "tag": "iron" }
  ],
  "anchors": [
    { "id": "a1", "position": [80, 176], "radius": 12 }
  ],
  "fauna": [
    { "id": "fauna_gallery_warden", "kind": "warden", "position": [320, 480], "patrol": [960, 480], "line_y": 240 }
  ],
  "backdrop": {
    "wind": [0.0, 2.0],
    "deform_grid": [[10, 22], [8, 20], [8, 18], [6, 16], [6, 14]],
    "pulse_on": ["fauna_gallery_warden", "vault_wall", "matter_gallery_hammer", "gallery_floor"]
  }
}
```

- `line_y: 240`이므로 **y < 240 (위쪽 240px)에서는 warden가 존재하지 않는다.** `gallery_deck_a`(y 200~224)가 그 안전지대다. 위쪽에서 마음껏 호흡하고, `gallery_deck_b`(y 400~424)로 내려갈지 결정한다.
- warden는 56px/s. mass 0의 플레이어 최대 62 → **달아난다.** mass 3의 최대 53 → **못 달아난다.** `matter_gallery_hammer`(strike)를 미리 먹었으면 1회로 버틸 수 있다.
- `matter_gallery_hammer`는 `vault_ceiling`/`vault_floor`/`vault_back`/`vault_wall`(brittle)로 **상자 안에 갇혀 있다**(`site_nursery_plaque`와 같은 구조). 유효한 입구는 brittle 벽 하나뿐이다. 그러므로 **`gallery_vault`의 `opened: site_nursery_plaque` 조건이 실제로 물리적 봉인이 된다** — 조건이 없으면 hammer는 아무도 못 얻고 `strike` 소비 경로가 죽는다.
- `gallery_vault`는 `kind: "site_route"`이고 `next`를 갖지 않는다(§9.3). 이 route의 효과는 **통과 가능 상태를 만드는 것** 하나이며, 그 상태는 **`sites_done` 에 `gallery_vault` 로 기록된다** (`routes_opened` 가 아니다). `id`는 `exit_`/`mouth.` 접두사를 쓰지 않으므로 §9.3 접두사 규칙에도 예외가 아니다.

### 9.10 작업 예시 5 — `stratum_floor.json` (구간 5, 결말 3개)

```json
{
  "schema": 1,
  "id": "stratum_floor",
  "index": 5,
  "location": "loc.floor",
  "display_name": "바닥",
  "world_seed": 33301,
  "palette": { "scheme": "complementary", "base_hue": 0.52, "saturation": 0.44, "contrast": 1.15, "variant": 1 },
  "bounds": { "width": 640, "height": 1024 },
  "spawn": { "position": [320, 96], "facing": 1 },
  "solids": [
    { "id": "floor_left", "rect": [0, 940, 280, 84], "kind": "ground" },
    { "id": "floor_right", "rect": [360, 940, 280, 84], "kind": "ground" },
    { "id": "wall_left", "rect": [0, 64, 40, 960], "kind": "wall" },
    { "id": "wall_right", "rect": [600, 64, 40, 960], "kind": "wall" },
    { "id": "heart_plinth", "rect": [288, 848, 64, 32], "kind": "wall" },
    { "id": "chimney_right", "rect": [168, 200, 16, 600], "kind": "wall" }
  ],
  "currents": [
    { "id": "return_flow", "rect": [48, 200, 120, 600], "flow": [0.0, -26.0] }
  ],
  "membranes": [
    { "id": "heart_meld", "rect": [232, 780, 176, 60], "tag": "seed", "hold_seconds": 0.9 }
  ],
  "routes": [
    {
      "id": "exit_floor",
      "kind": "descent",
      "trigger": [280, 940, 80, 84],
      "requires": [{ "kind": "always" }],
      "next": ""
    },
    {
      "id": "mouth.still",
      "kind": "ending",
      "trigger": [120, 880, 96, 60],
      "requires": [{ "kind": "always" }],
      "next": "ending.hollow"
    },
    {
      "id": "mouth.above",
      "kind": "ending",
      "trigger": [48, 160, 120, 40],
      "requires": [{ "kind": "fact", "fact": "vent_above" }],
      "blocks_tag": ["seed"],
      "next": "ending.return"
    },
    {
      "id": "mouth.heart",
      "kind": "ending",
      "trigger": [280, 792, 80, 56],
      "requires": [{ "kind": "tag_available", "verb": "feed", "tag": "seed" }],
      "next": "ending.swallow"
    }
  ],
  "sites": [],
  "matter": [],
  "anchors": [
    { "id": "a1", "position": [320, 120], "radius": 12 }
  ],
  "fauna": [
    { "id": "fauna_warden_floor", "kind": "warden", "position": [560, 300], "patrol": [900, 200], "line_y": 240 }
  ],
  "backdrop": {
    "wind": [0.0, 3.0],
    "deform_grid": [[10, 22], [8, 20], [8, 18], [6, 16], [6, 14]],
    "pulse_on": ["heart_plinth", "fauna_warden_floor", "mouth.heart"]
  }
}
```

**이 층의 기하 (구현자가 임의로 바꾸면 안 되는 부분):**
- 바닥은 **80px 폭의 구덩이 한 개**로 나뉜다: `floor_left` x 0~280, `floor_right` x 360~640. `exit_floor` 트리거가 그 구덩이 자체다. 다음 층이 없으므로(`next: ""`) 여기 들어가면 `ending` phase로 간다.
- `heart_plinth`은 구덩이 바로 위(x 288~352, y 848~880)에 있는 받침이다. `mouth.heart` 트리거(y 792~848)가 그 위에 있다. 즉 **심장 각문은 구덩이 위로만 열리고**, 구덩이 아래로는 못 간다.
- `heart_meld` 막(x 232~408, y 780~840)은 `mouth.heart` 접근로만 덮는다. **구덩이(`exit_floor`)와 `mouth.still`은 막 밖에 있으므로 `ending.swallow`을 노리지 않는 플레이어는 막을 건드릴 필요가 없다.** 막은 통과를 막는 반고체다(§4.5 참조). `tag:"seed"` 물질을 `USE_RADIUS` 안에서 소비해야 `hold_seconds` 0.9초 뒤 영구히 열린다.
- 좌측 `chimney_right` 벽(x 168~184, y 200~800)이 `return_flow` 화로를 바깥과 분리한다. 화로 안(x 48~168, y 200~800)에는 26px/s 오르막이 있고, **아래에서부터 y=800 지점으로만 들어간다** (위가 막혀 있으므로 진입 방향이 하나뿐). 화로 안 y<240 구간은 `thing.warden`의 `line_y: 240` 위쪽이므로 **안전하다.**
- `mouth.above` 트리거는 화로 꼭대기(y 160~200)다. 720px를 44px/s로 오른다 = 13.1초.
- `mouth.still` 트리거(x 120~216, y 880~940)는 `floor_left` 위에 놓인 아무 데나 있다. **항상 열린다.**

**설계 메모 (구현자가 바꿔야 한다고 생각하면 안 되는 부분):**
- 세 각문의 `requires`는 `always` / `fact:vent_above` / `tag_available(feed, seed)` 이다. 세 근거의 **종류가 서로 다르다**가 이 Kit의 핵심이고, 어느 하나를 `clearance`로 쓰지 않았다. 그래서 **숫자 하나만으로 결말이 열리지 않는다.**
- `mouth.above`의 `blocks_tag: ["seed"]`가 `ending.return`과 `ending.swallow`을 **물리적으로 배타**로 만든다. `tag:"seed"`를 들고 귀환할 수 없다.
- `exit_floor`는 `next: ""`인 하강 트리거다. 다음 층이 없으면 즉시 `ending` phase로 간다. **`ending`이 하나도 열리지 않으면 `ending.hollow`로 떨어진다** — 무조건 열린 각문은 `mouth.still`뿐이므로 이 성질은 항상 성립한다.
- 이 층에 `matter`가 0개, `sites`가 0개인 것은 의도적이다. 마지막 층에서 제공되는 것은 **선택지뿐**이고, 새로운 지식이 아니다.

---

## 10. Presentation — `core/procedural/`만 쓴다

### 10.1 화면의 주인공

- **플레이어가 첫 1초에 봐야 하는 것**: 자기 몸의 실루엣, 그리고 그 몸에 붙어 있는 물질. 그것이 곧 HUD 대체물이다.
- **UI보다 우선하는 world element**: 층의 하단 방향(더 어두워지는 색), 얕은 물결의 흐름 방향, brittle 벽의 균열 무늬.
- **상시 표시가 정말 필요한 정보**: **없다.** 0개. 근거는 `SWALLOW_THE_SEA_RESEARCH.md` §5 (Store/리뷰 어디에도 HUD 기술이 없고, 인게임 타이머조차 토글이다).
- **호출할 때만 보이는 정보**: 전환 베일(0.9초), 앵커 섬광(3초, 색만), `downed` 암전(1.4초), 결말 화면(1.6초).

### 10.2 화면이 **절대** 하면 안 되는 것

> **[WT-2 · 2026-09-26 확정]** 아래 금지 목록은 예시가 아니라 **닫힌 화이트리스트의 반대쪽**이다. 화면에 나가는 문자열은 §10.9 표의 4개 값뿐이고, 그 밖의 문자열은 어떤 형태로도 나가지 않는다.

| 금지 | 적용 위치 |
|---|---|
| 상시 HUD | `DescentView` 의 draw 목록에 HUD 노드가 아예 없다 |
| 좌상단 공간명 / 자동저장 표시 / 키설명 뭉치 | 없음. `display_name`은 JSON에 있으나 **한 곳에서도 그리지 않는다** (§10.9 `T1`) |
| 우상단 Menu / Journal 버튼 | 없음. Esc는 Shell 소관. **Journal 버튼을 새로 만드는 것도 금지** (§10.10 PF-02) |
| 카운터 (섭취량, 산소, 남은 물질 개수) | 물질 개수는 `carried.size()`여도 그리지 않는다. 실루엣으로만 |
| 긴 조작 설명 overlay | 없음 |
| 플레이어 노출 텍스트 중 화이트리스트 밖 값 | **없음.** §10.9 `T1`~`T4` 외 문자열 0개. 검사: §15.2 `test_no_player_text_outside_whitelist` |
| 디버그 문자열 | `push_warning`은 로그에만. 화면에 그리는 문자열은 **결말 화면의 화면 이름 1줄**(`presentation/descent_view.gd` 1곳)뿐이며 그 값은 §4.7의 `표기` 3개 중 하나다. **12자 상한 유지, 요약문 금지** |
| placeholder ColorRect/Label | 월드 오브젝트용 `ColorRect`/`Label` **생성 금지.** 모든 월드 픽셀은 `ProceduralCanvas`에서 나온다 |
| 마우스 커서 게임 | `MOUSE_MODE` 변경 없음 |
| 물리 키 문자 표시 | Input Bubble는 전환층 소관. 이 Kit은 키를 그리지 않는다. **이 Kit의 플레이어 노출 문자열에 물리 키 심볼조차 없다**(§10.9) |

### 10.3 draw order (고정, 뒤→앞)

```
0  SKY        (pal.sky_far)        배경 대부분
1  FAR        (pal.sky_near)       원경 구조
2  MID        (pal.ground)         벽/흐름/막 래스터
3  NEAR       (pal.fog)            근경 막힌 구조 + 앵커 섬광
4  물질 (픽업 전 world 물질)
5  개체 (fauna)
6  개체 (player + 운반 물질 부착)
7  FOREGROUND (pal.ink, 알파 0.55) 전경 실루엣
8  CanvasLayer: transition_veil
```

### 10.4 배경이 물리법칙으로 말랑말랑 움직인다 (사용자 확정 요구)

**두 겹의 물리를 겹친다.** 하나만 넣으면 "말랑말랑"이 아니라 "떨림"이 된다.

**층 1 — 요소 이동 (`ProceduralBackdropDynamics`, 레이어 5개)**

- `add_anchor(rest_world_position)` 으로 레이어당 최소 6개, 최대 12개의 앵커를 만든다. 위치는 `ProceduralSeed(stratum_id).range_i(-320, 960)` 로 **층 시드에서 결정론적으로** 뽑는다. (§11 참조 규칙: 같은 시드 = 같은 배경)
- `configure(parallax, field_amplitude, stiffness, damping_ratio)` — 값은 §8.5 `BACKDROP_*`
- `attach_field(ProceduralNoiseField, BACKDROP_PHASE_SPEED)` — `field`는 `&"shape"`(SKY/FAR) 또는 `&"flow"`(MID/NEAR/FOREGROUND)
- 매 렌더 프레임 `set_view_offset(camera.position)` 후 `step(delta)`
- `set_wind(stratum.backdrop.wind, 1.0)` — 층마다 다름
- `pulse(strength)` 를 `backdrop.pulse_on` 에 적힌 ID 의 이벤트가 날 때마다 호출. 값 `9.0`
- 그리기: `rest_position + get_offset(i)`

**층 2 — 메시 변형 (`ProceduralDeformField`, 레이어 5개)**

- 레이어당 `build_grid(gw, gh, Rect2(-320, cam.y - 180, 1280, 720))` — 카메라 y에 맞춰 **매 층 진입 시 1회만** 재구축한다(매 프레임 재구축 금지)
- `configure(DEFORM_AMPLITUDE[i], DEFORM_STIFFNESS[i], DEFORM_DAMPING[i])`
- `bind_noise(ProceduralNoiseField(seed, &"squish"))`
- `excite(pulse, radius, center)` 를 다음 4가지에 호출: ① `surge` 순간 ② brittle 벽 파괴 ③ `pulse_on` ID 접촉 ④ 층 진입 0.0초
  - `surge`: `pulse = 26.0`, `radius = 200.0`, `center = 플레이어 위치`
  - 벽 파괴: `pulse = 34.0`, `radius = 240.0`, `center = 벽 중심`
  - 층 진입: `pulse = 40.0`, `radius = 1280.0`, `center = 뷰포트 중심`
- 매 렌더 프레임 `step(delta)` 후 `get_offset(u, v)` 로 정점을 밀고 `build_triangles()` 로 삼각형을 그린다
- **FOREGROUND 레이어만 `pulse` 를 1.6배로 증폭**한다. 전경이 크게 흔들려야 중경이 "말랑말랑"으로 읽힌다.

**절대 금지**: 백그라운드를 카메라 오프셋에 붙여 그리기(가짜 물리), 정점 없이 텍스처 스크롤로 대체, tween 으로 흉내.

### 10.5 개체 실루엣 (`ProceduralBodyPart`)

- 플레이어: `kind` 순서 `TAIL → TORSO → HEAD → EYE × 1 → FIN × 2`, `joint`는 `ROOT/MIDDLE/TIP`, `shade`는 `VOLUMETRIC`(TORSO/HEAD) + `INK`(EYE/FIN). `base_radius`는 `BASE_BOX`/2에서 시작해 `mass` 0..4에 대해 `4.5 + mass * 1.1` px.
- **운반 물질은 `player_figure.gd` 안에서 `carried` 순서대로 `HEAD` 뒤쪽 관절에 부착**된다. 크기는 `size`(1..3)에 비례. 이것이 "인벤토리 UI"의 대체물이고 동시에 §0.2-2의 유일한 능력 표시다.
- 물질 소비 순간: 부착된 파트가 0.25초에 걸쳐 `ProceduralSpring`으로 접혀 사라진다.
- `mass`가 바뀌면 `SPRING_MASS_FOLLOW` / `SPRING_MASS_DAMPING`으로 0.3초 안에 새 크기로 간다. **규칙은 정수 mass, 표현만 연속.**
- 방어력/체력/레벨을 그리기 위한 파트는 **추가하지 않는다.** 눈은 1개다.

### 10.6 앵커 / 흐름 / 막의 표현 규칙

| 대상 | 표현 |
|---|---|
| 앵커 | 반경 12 영역 안쪽 3px 테두리만 `pal.accent`으로. 들어오면 그 레이어의 `ProceduralBackdropDynamics.pulse(6.0)` + 3초 `pal.shade` 1단계 상승 후 `ACCENT_FLASH_DECAY`로 복귀 |
| 흐름 | `currents[].rect` 를 `ProceduralSdf` stroke_field 로 2px 스트로크. 내부에 `ProceduralNoiseField(..., &"flow")` 1줄. **화살표·눈금을 그리지 않는다** |
| 막 | `membranes[].rect` 를 `ProceduralSdf` stamp_field 로 채우고 상단에 1px `pal.danger` 하이라이트. **태그 이름을 쓰지 않는다** |
| brittle 벽 | 파괴 전: `pal.shade` 채움 + 균열 3줄. 파괴 후 0.4초간 사라지고, `regrow_seconds` 후 `pal.shade`로 0.2초 페이드인 복귀 |

### 10.7 카메라

- `Camera2D` 1개. 목표 위치 = `player.position + CAMERA_LOOKAHEAD` 방향 벡터, `facing`이 수평, `velocity.y`가 수직(±1로 클램프).
- 추종: `pos += (target - pos) * (1 - exp(-CAMERA_LERP_PER_SEC * delta))` — 프레임레이트 독립.
- 클램프: 층 `bounds` 안으로. x는 `[DESIGN_W/2, STRATUM_W - DESIGN_W/2]`, y는 `[DESIGN_H/2, STRATUM_H - DESIGN_H/2]`.
- 줌: `zoom = ZOOM_STEPS` 중 `floor(viewport_size.x / DESIGN_W)` 에 가장 가까운 값(최소 2, 최대 4). `view_size` 연결에서만 재계산. **1 texel = 1 world unit를 유지한다.**

### 10.8 해상도

| 해상도 | zoom | 가시 월드 | 판정 |
|---|---|---|---|
| 1280×720 | 2 | 640×360 | 기준 |
| 1920×1080 | 3 | 640×360 | 동일한 프레이밍. 잘림 0 |
| 2560×1440 | 4 | 640×360 | 동일 |

세 해상도에서 **보이는 월드 범위가 동일**하므로 레이아웃 재계산이 필요 없다. UI는 `Control` + `Container/anchor`만 쓰고 월드 좌표와 섞지 않는다. (기준 뷰포트는 `project.godot`의 1280×720이며 이 Kit은 그것을 수정하지 않는다.)

### 10.9 플레이어 노출 텍스트 — 닫힌 화이트리스트

**정본:** `docs/research/round_2026_09_26/ROUND_PLAN.md` §11.3. 이 절이 그 3개 규칙을 이 Kit에 집행하는 형태이며, **§10.9·§10.10이 이 기획서 안의 다른 절과 충돌하면 이 절이 이긴다.**

| # | 승인 규칙 (원문 요지) | 이 Kit에서의 집행 수단 |
|---|---|---|
| WT-1 | 세계관 문서는 **제작 전용 정본**이다. 인용은 `제작 전용` 표시가 있는 절 안에서만 | §10.9-1. §0.3·§4.7에 `> **[제작 전용]**` 배너를 넣었다 |
| WT-2 | 플레이어 노출 텍스트는 **세 종류뿐** — 화면 이름 · 버튼 라벨 · 단수 명사 하나. **설명문 0개** | §10.9-2. **화이트리스트 4슬롯(값 4개).** 표에 없는 문자열은 금지 |
| WT-3 | **삭제한 설명을 되채우는 장치를 만들지 않는다.** 도감·저널·해설 NPC·엔딩 요약 | §10.10. §15.2 `test_no_refilling_lore_device`가 식별자 0건을 검사 |

**WT-2가 이 Kit에서 뜻하는 것:** 이 Kit의 플레이 중 화면 문자열은 **0개**다(§10.2). 남는 것은 `ending` 페이즈 1.6초에 그리는 **화면 이름 1줄**뿐이다. 그 1줄조차 세 값 중 하나이고, "무슨 일이 있었는가"를 담은 문장이 아니다.

#### 10.9-1 제작 전용 — 이 Kit의 제작 정본

세계관 정본은 `docs/world/**`(W1 소유, 동시 개정 중)다. **이 Kit은 `docs/world/**`를 읽지 않는다**(§0.3). `docs/world/**`를 `load`/`preload`/`ResourceLoader` 인자로 쓰는 코드 **0건**을 유지한다(§15.2 `test_no_refilling_lore_device` 규칙 ④).

| 분류 | 이 Kit에서의 위치 | 플레이어 노출 |
|---|---|---|
| 세계관 정본 | `docs/world/**` | **없음** |
| 층 `display_name` 6(+1)개 | `authored/strata/*.json` (§9.2) | **없음.** §9.2가 "화면에 표시되지 않는다"고 이미 명시 |
| 층 `location` `loc.*` · `thing.*` ID | `authored/strata/*.json` | **없음** |
| 사실 ID `fact.current_lies` `fact.vent_above` | `domain/fact_ledger.gd` | **없음.** §4.4 "화면에 글자가 한 줄도 뜨지 않는다" |
| `sites[].id` `routes[].id` `membranes[].tag` `matter[].verb` `matter[].tag` | `authored/strata/*.json` | **없음.** §10.6 "태그 이름을 쓰지 않는다" |
| 물질 `verb` `plug` `feed` `strike` `weigh` | `domain/matter_item.gd` | **없음.** `desc_denied` 사운드가 존재 사실만 말한다 |
| 원작 이름 `Orro` `Borrus` `Vobble` `Ubb` `Nooty` `Gump Sucker` `Ouroboros` `Sororicide` `nursery wall` `Swallow the Sea` | §1.3 | **없음.** 코드·데이터·문서 어디에도 없음 |
| `creature` 축 값 `fix.gardener` 등 | `domain/worldstate_view.gd` | **없음.** §13.6.3 `remains` 도 이름 없이 배치만 된다 |

#### 10.9-2 화이트리스트 — 닫힌 목록 (4슬롯 / 4값)

**이 표가 전부다.** 표에 없는 문자열이 화면에 1개라도 뜨면 구현 실패이며 §15.2 `test_no_player_text_outside_whitelist`가 잡는다. 슬롯을 늘리려면 **이 표를 먼저 고친다.**

| # | 문자열 | 화면 | 분류 | 나오는 곳 | 이게 말하는 것 / 말하지 않는 것 |
|---:|---|---|---|---|---|
| T1 | `하강` | 셸 소유 모듈 목록 · Esc 메뉴 | **화면 이름** | `module_manifest.tres`의 `display_name` | **이 Kit은 스스로 그리지 않는다.** `presentation/`·`systems/`·`domain/`에 이 리터럴 0건. 셸이 그릴 때만 1회 |
| T2 | `정지` | `ending` 페이즈 1.6초 | **화면 이름** | `ending.hollow` → §4.7 `표기` 값. `presentation/descent_view.gd` 1곳 | 결말의 이름만 말한다. **이 결말에 도달한 경로·얻은 사실·남은 물질·사망 횟수는 쓰지 않는다** |
| T3 | `귀환` | `ending` 페이즈 1.6초 | **화면 이름** | `ending.return` → §4.7 `표기` 값 | 〃 |
| T4 | `삼키다` | `ending` 페이즈 1.6초 | **화면 이름** | `ending.swallow` → §4.7 `표기` 값 | 〃 |

**버튼 라벨 사용 횟수: 0회.** 이 Kit의 UI 버튼은 Esc 메뉴(Shell 소유)뿐이라서 (§2 `menu / detail`, §10.2) 라벨이 없다. **이 Kit이 직접 `Button`을 만들어 라벨을 붙이는 것은 금지** — 라벨을 그 순간 WT-2의 분류 2 자리를 새로 열게 되고, 그 자리가 세계관 해설로 채워질 위험이 가장 크다. 라벨이 필요해지면 Shell에 요청한다.

**단수 명사 하나(분류 3) 사용 횟수: 0회.** 이 Kit은 그 자리를 비워 둔다. 셀이 쓰는 단수 명사는 셸의 것이지 이 Kit의 것이 아니다.

**값의 출처 규칙:** T2~T4는 **오직 `ending_id` → 화면 이름 매핑 3건에서만** 나온다. `ending_id`가 3종 밖이면 §6.6대로 `""`로 되돌아가 화면을 띄우지 않는다. `ending_id` 문자열 자체(`ending.hollow` 등)는 그리지 않는다 — 매핑 테이블이 이를 번역한다.

#### 10.9-3 화이트리스트에 **없는** 것 (이 Kit이 절대로 그리지 않는다)

"안 되지만 아직 아무도 안 물어본" 항목을 미리 못 박는다. **전부 금지이며 화이트리스트에 추가하지 않는다.**

| tempting 대상 | 어디에 있나 | 왜 금지인가 |
|---|---|---|
| 층 `display_name` 6(+1)개 | `authored/strata/*.json` | §9.2, §10.2. 층 이름은 공간의 색·흐름·저해가 말한다 |
| `loc.*` `thing.*` ID | `authored/strata/*.json` | 축 계산용 |
| 층 번호 · `stratum_index` | `domain/descent_state.gd` | "몇 층째인가"를 숫자로 말하면 진행도가 카운터가 된다 (§17) |
| 사실 이름 (`current_lies` `vent_above` 의 한국어 표기) | `domain/fact_ledger.gd` | §4.4. `plaque`는 만지면 사실이 쌓일 뿐 읽히지 않는다 |
| `plaque`의 **읽을 수 있는 글자** | `presentation/world_raster.gd` | `sites[].kind: "plaque"`는 물리적으로 만지는 물체이지 설명 문서가 **아니다**. 명판·각인·읽기 UI를 얹는 순간 §10.10 PF-03이 된다 |
| `membranes[].tag` (`brine` `seed` 등) | `authored/strata/*.json` | §10.6 "태그 이름을 쓰지 않는다" |
| 물질 `verb` 이름 | `domain/matter_item.gd` | `desc_consume` `desc_denied` 사운드가 존재만 말한다 |
| `ending_id` 원문 (`ending.hollow` 등) | `domain/descent_state.gd` | `ModuleResult`와 셸로만 나간다 |
| `run_id` `world_seed` `consumed` `sites_done` `routes_opened` `anchors_taken` | `domain/descent_state.gd` | §6.1·§6.5. 전부 저장용 |
| `mass` `integrity` `downed_for` `carried.size()` | `domain/descent_state.gd` | §10.2 카운터 금지. 몸 실루엣과 부착된 물질이 말한다 |
| 원작 이름 10종 | §1.3 | 0-copy |
| 조작법·튜토리얼·툴팁 힌트 | 없음 | §10.2, §12.3 |
| `docs/world/**` 인용문 | W1 정본 | WT-1. 읽는 코드조차 0건 |

### 10.10 설명을 되채우는 장치 — 금지

`AGENTS.md` "세계관의 제작과 게임 내 전달"이 이미 전 Kit에 건 금지를, **이 Kit이 실제로 만들기 쉬운 장치 단위로** 다시 써서 못 박는다. 아래 "금지되는 행동"이 구현자가 실제로 쓰려는 코드다.

| # | 장치 | 이 Kit에서 금지되는 구체 행동 |
|---|---|---|
| DF-01 | **도감(codex)** | 획득한 사실 목록(`facts`)을 보여주는 화면·패널·토글을 만들지 않는다. 층 6개를 "방문한 층" 목록으로 보여주는 UI도 금지 — 물질 목록 UI와 같은 축이다. 진실은 §4.6의 앵커(무표시)와 §13.3의 `facts` 유지다 |
| DF-02 | **저널(journal)** | `consumed` `sites_done` `routes_opened` `anchors_taken` `run_id` `elapsed_play` 를 읽어 쓰는 기록 화면·탭·토글을 만들지 않는다. `finished(ModuleResult)` 페이로드는 셸 것이고 이 Kit은 그 안에 문자열을 넣지 않는다(§10.9 `T1`) |
| DF-03 | **해설 NPC(lore NPC)** | `fauna[]`(`grazer` `warden`)에게 말을 걸거나 설명을 주는 행동을 붙이지 않는다. §4.5가 이미 "`thing.warden`을 죽이거나 진정시키는 authored 이벤트를 만들지 않는다"고 금지한다. **`plaque`에 읽을 수 있는 글자를 얹는 것도 이 항목에 속한다** — `desc_fact` 사운드는 사실이 쌓였다는 **신호**일 뿐 내용 통로가 아니다 |
| DF-04 | **엔딩 요약(ending summary)** | 결말 화면은 **이름 1줄**이다. 거기에 "이렇게 끝났다"-류 요약, 경로 회상, 획득 사실 나열, 남은/놓친 것 내역, 달성률을 추가하지 않는다. 종료는 `finished` emit + §13.1 저장 3곳만이고 화면 문자는 T2~T4 셋 중 하나다 |
| DF-05 | **오디오 해설** | `Voice` 버스 이벤트 0개(§11 표는 `SFX`/`Music`만). 사실이 쌓였을 때 나레이션을 넣지 않는다. `desc_fact`는 이미 있는 신호다 |
| DF-06 | **안내 배너** | 특정 막이 안 열릴 때 이유를 알려주는 힌트·배너·툴팁을 만들지 않는다. `RequiresBodyGate`의 실패 사유 `Dictionary`(§5.3)는 `push_warning`과 오디오로만 말한다 |
| DF-07 | **명찰** | 층·막·물질·사실·개체 위에 이름표를 붙이지 않는다. `display_name` `tag` `verb` `id` 를 그리는 코드 0건 |
| DF-08 | **Shell 화면 확장** | 이 Kit이 `requested` 페이로드에 화면용 문자열을 넣어 셸이 그려지게 하지 않는다. 표시가 필요하면 §19 OQ-9로 요청한다 |

---

## 11. 오디오 이벤트 표 (ROUND_PLAN C2 형태)

`modules/descent_exploration/audio_manifest.json` — **아래 13줄이 전부다.** 다른 이벤트를 추가하지 않는다.

```json
{
  "id_prefix": "desc",
  "events": [
    { "id": "desc_swim",     "file": "res://modules/descent_exploration/audio/swim.wav",     "bus": "SFX",  "max_polyphony": 3, "volume_db": -14.0, "min_interval_seconds": 0.35 },
    { "id": "desc_surge",    "file": "res://modules/descent_exploration/audio/surge.wav",    "bus": "SFX",  "max_polyphony": 1, "volume_db":  -6.0, "min_interval_seconds": 0.00 },
    { "id": "desc_land",     "file": "res://modules/descent_exploration/audio/land.wav",     "bus": "SFX",  "max_polyphony": 2, "volume_db": -10.0, "min_interval_seconds": 0.10 },
    { "id": "desc_pickup",   "file": "res://modules/descent_exploration/audio/pickup.wav",   "bus": "SFX",  "max_polyphony": 1, "volume_db":  -8.0, "min_interval_seconds": 0.00 },
    { "id": "desc_denied",   "file": "res://modules/descent_exploration/audio/denied.wav",   "bus": "SFX",  "max_polyphony": 2, "volume_db": -12.0, "min_interval_seconds": 0.20 },
    { "id": "desc_consume",  "file": "res://modules/descent_exploration/audio/consume.wav",  "bus": "SFX",  "max_polyphony": 1, "volume_db":  -6.0, "min_interval_seconds": 0.00 },
    { "id": "desc_bristle",  "file": "res://modules/descent_exploration/audio/bristle.wav",  "bus": "SFX",  "max_polyphony": 2, "volume_db":  -5.0, "min_interval_seconds": 0.05 },
    { "id": "desc_anchor",   "file": "res://modules/descent_exploration/audio/anchor.wav",   "bus": "SFX",  "max_polyphony": 1, "volume_db":  -9.0, "min_interval_seconds": 0.00 },
    { "id": "desc_fact",     "file": "res://modules/descent_exploration/audio/fact.wav",     "bus": "SFX",  "max_polyphony": 1, "volume_db": -10.0, "min_interval_seconds": 0.00 },
    { "id": "desc_hurt",     "file": "res://modules/descent_exploration/audio/hurt.wav",     "bus": "SFX",  "max_polyphony": 1, "volume_db":  -4.0, "min_interval_seconds": 0.00 },
    { "id": "desc_downed",   "file": "res://modules/descent_exploration/audio/downed.wav",   "bus": "SFX",  "max_polyphony": 1, "volume_db":  -2.0, "min_interval_seconds": 0.00 },
    { "id": "desc_descend",  "file": "res://modules/descent_exploration/audio/descend.wav",  "bus": "SFX",  "max_polyphony": 1, "volume_db":  -8.0, "min_interval_seconds": 0.00 },
    { "id": "desc_ambience", "file": "res://modules/descent_exploration/audio/ambience.wav", "bus": "Music", "max_polyphony": 1, "volume_db": -18.0, "min_interval_seconds": 0.00 }
  ]
}
```

| id | bus | polyphony | dB | 쿨다운 | 발동 조건 (모두 `module.gd`가 판정) |
|---|---|---|---|---|---|
| `desc_swim` | SFX | 3 | -14.0 | 0.35 | (`up` 또는 `down` 홀딩) and `abs(velocity.y) > 6.0` |
| `desc_surge` | SFX | 1 | -6.0 | — | `surge` 입력 승인 순간 (쿨다운 통과) |
| `desc_land` | SFX | 2 | -10.0 | 0.10 | 충돌 해결에서 `velocity.y` 가 0이 되었고 직전 `velocity.y < 20.0` |
| `desc_pickup` | SFX | 1 | -8.0 | — | 픽업 성공 |
| `desc_denied` | SFX | 2 | -12.0 | 0.20 | (배낭 가득 픽업 실패) or (`consume` 입력인데 반경 8px 밖에 대상) or (`requires` 미충족 문에 접촉) |
| `desc_consume` | SFX | 1 | -6.0 | — | 물질 소비 성공 (반환값 `true`) |
| `desc_bristle` | SFX | 2 | -5.0 | 0.05 | brittle 벽 파괴 |
| `desc_anchor` | SFX | 1 | -9.0 | — | 앵커 **최초** 진입 (`anchor.entered == false`일 때만) |
| `desc_fact` | SFX | 1 | -10.0 | — | 사실 1개가 **새로** 획득될 때 |
| `desc_hurt` | SFX | 1 | -4.0 | — | `Vitality.apply` 가 `integrity` 를 실제로 감소시킨 프레임 |
| `desc_downed` | SFX | 1 | -2.0 | — | `integrity` 가 양수에서 0이 되는 프레임 **1회** |
| `desc_descend` | SFX | 1 | -8.0 | — | `transition_pending` 이 false에서 true로 바뀌는 프레임 |
| `desc_ambience` | Music | 1 | -18.0 | — | `enter_stratum()` 에서 1회 |

**Music은 1종뿐이다.** `AudioEventPlayer` 에 특정 이벤트의 재생을 멈추는 API가 없다(W3 소유). 따라서 층별 Music 6종을 두면 겹쳐서 `max_polyphony: 1`이 무의미해진다. **층 인덱스는 사운드를 바꾸지 않는다.** 소리의 층 구분은 §10.4 배경 물리와 `desc_ambience`의 연속 재생이 담당한다. Music 채널 solo/stop이 필요해지면 §19 OQ-6에 요청한다.

**`AudioManifest.validate()`는 `file` 이 `ResourceLoader.exists()` 여야 통과한다.** 따라서 오디오 테스트는 W3가 `.wav` 13개를 렌더하기 전까지 실패한다. 그 상태는 허용되지만 **Kit 완료를 선언할 수 없다.**

`modules/descent_exploration/audio/README.md`에는 아래를 적는다 (wav 생성은 W3 소관, 이 Kit은 만들지 않는다):

```
nkido render res://modules/descent_exploration/audio/patches/<name>.akkado \
  -o modules/descent_exploration/audio/<name>.wav \
  --seconds 1.2 --rate 48000 --no-default-bank
```

13개 이름: `swim surge land pickup denied consume bristle anchor fact hurt downed descend ambience`

---

## 12. Input

### 12.1 Game actions — 4개, 그리고 **새 InputMap 액션 0개**

| intent | InputMap action | 물리 키 | gameplay 의미 |
|---|---|---|---|
| `up` | `descent_exploration_up` | `↑` | 상승. 놓으면 가라앉기 시작 |
| `down` | `descent_exploration_down` | `↓` | 다이브 가속 / 흐름에서 미세 조정 |
| `surge` | `descent_exploration_confirm` | `Z` | 돌진. brittle 벽 파괴. 쿨다운 0.45s |
| `consume` | `descent_exploration_cancel` | `X` | 범위 안 유효 목표 물질 1개 사용 |

- **물리 키는 화살표 `↑ ↓` 와 `Z X` 이다. `W`/`S` 는 아니다.** `app/app_root.gd`의 `_configure_module_actions()` 는 `NORMAL_IDS`의 각 id에 대해 `<id>_up → KEY_UP`, `<id>_down → KEY_DOWN`, `<id>_confirm → KEY_Z`, `<id>_cancel → KEY_X` 를 등록한다. `W`는 `rule_rewriting_up` 에만 별도로 묶여 있고 **다른 id에는 묶여 있지 않다.** (`rule_rewriting_up: [KEY_W]` 예외 참조) 따라서 이 Kit의 기본 물리 키는 화살표가 된다.
- `W`/`S` 도 함께 묶으려면 W0가 `_configure_module_actions()` 의 `bindings` 딕셔너리에 `descent_exploration_up: [KEY_W, KEY_UP]`, `descent_exploration_down: [KEY_S, KEY_DOWN]` 두 줄을 추가해야 한다. **이 Kit은 그 파일을 수정하지 않는다.** §19 OQ-9 요청 1번.
- `left` / `right` action도 같은 루프로 등록되지만 **이 Kit은 사용하지 않는다.** 수평은 `velocity.x`의 감쇠로 만들어진다. `ModuleManifest.input_actions`에는 **4개만** 적는다. 6개를 다 적으면 구현자가 `left/right`를 "써야 하는 줄 알고" 이동을 두 축으로 만들 수 있다.
- `module_manifest.tres`:

```gdscript
[gd_resource type="Resource" script_class="ModuleManifest" load_steps=2 format=3]

[ext_resource type="Script" path="res://core/contracts/module_manifest.gd" id="1"]

[resource]
script = ExtResource("1")
id = &"descent_exploration"
display_name = "하강"
entry_scene = "res://modules/descent_exploration/entry.tscn"
save_version = 1
input_actions = PackedStringArray("descent_exploration_up", "descent_exploration_down", "descent_exploration_confirm", "descent_exploration_cancel")
```

### 12.2 물리 키가 4개인 이유

원작은 마우스 좌클릭 이동 + 우클릭 대시다. `docs/KIT_WORKFLOW.md` §7의 Input Bubble은 **가상 격자의 각 셀이 물리 키 하나와 안정적으로 대응**해야 한다. 마우스 버튼은 키가 아니고 개수가 고정되지도 않으므로 칸에 앉힐 수 없다. 그래서 키보드로 닫고, 4개로 줄였다. `↑ ↓ Z X` 는 `app_root.gd`가 이미 물고 있는 키라 **W0 수정 0줄로** 동작한다.

### 12.3 Input Bubble — required key set

| 항목 | 값 |
|---|---|
| 이 구간의 required physical keys | `↑`(up), `↓`(down), `Z`(surge), `X`(consume) = **4칸** |
| `rising` bubble | 이 구간에 처음 필요한 키 = 4개 전부 (직전 구간에 같은 4칸이 더 필요한 경우가 아니라는 전제 없음 — §19 OQ-3) |
| `restoring` bubble | 직전 구간의 required key 집합과 **교집합** = `app_root`가 넘겨준 `previous` 배열과 `↑ ↓ Z X` 의 교집합. 비어 있으면 0칸 |
| `popped` 흔적으로 남는 bubble | `previous`에만 있는 키. `popped` 유지 |
| bubble 완료 조건 | 4칸 전부 `intact` 가 되고, 그 4칸이 한 번 이상 눌려 `popped` 가 되었을 때 |
| 설명문 | **없음.** 어떤 문장으로도 키 기능을 설명하지 않는다 |
| 리바인딩 | 이 Kit은 물리 키를 그리지 않으므로 리바인딩 표시 책임은 전환층에 있다 |
| 격자 열 수 | 4칸 = 2×2. `modules/first_entry` 의 `GRID_COLUMNS = 3` 규칙을 이 Kit이 따르지 않으므로 격자 레이아웃도 전환층 책임이다 |

`module.gd`가 노출해야 하는 진입점:

```gdscript
func set_key_profile(profile: Variant, previous: Variant = null) -> bool
func get_input_bubble_state() -> Dictionary
```

전환층이 보내는 payload(`modules/first_entry/first_entry.gd`의 `execute_command`가 받는 형태와 동일):

```gdscript
requested.emit(&"input_profile", {
    "required_keys": ["descent_exploration_up", "descent_exploration_down",
                      "descent_exploration_confirm", "descent_exploration_cancel"],
    "previous": ["<직전 구간 required_keys 배열>"]
})
```

`module.gd`는 이 payload를 받아 4개 slot의 상태(`intact`/`popped`/`rising`/`restoring`)와 진행률을 **자신의 도메인 상태로만 저장**한다. **버블을 그리는 노드는 없다** — `modules/first_entry`의 presentation이 이 Kit의 캔버스를 그린다. 이 Kit은 `requested(&"input_profile", ...)`를 **포워드할 뿐**이다. → §19 OQ-3이 이 소유권 문제를 다룬다.

### 12.4 input gate 규칙

- `_can_process()` 는 아래를 **모두** 만족할 때만 true: `context != null and context.input_enabled and phase in ["playing", "first_frame"] and not downed and not transition_pending`.
- `surge` / `consume` 는 `pressed` 순간만 true. 홀딩 반복 금지.
- `exit()`에서 `context.input_enabled = false` 후 내부 타이머/시그널 정리. (`docs/MODULE_CONTRACT.md`)

---

## 13. Save / Load / Death / Recovery

### 13.1 저장 시점 (3곳 **뿐**)

| 시점 | 저장 내용 | 경로 |
|---|---|---|
| 앵커 최초 진입 | §6.5 전체 | `context.arrival["persist_checkpoint"]` 가 유효한 `Callable` 이면 `call(module_id, save_state())` |
| `exit()` | `save_state()` 반환 (AppRoot가 캡처) | `GameModule.save_state` |
| `finished` emit 직전 | `ending_id` 포함 전체 | `save_state()` |

**저장하지 않는 것**: 전환 도중, 픽업 직후, 소비 직후, 피해 직후. **규칙 위반이다.** 앵커가 저장 경계다.

### 13.2 `persist_checkpoint` 훅

`ModuleContext.arrival` 는 `Dictionary` 다. (`docs/MODULE_CONTRACT.md`) 이 Kit은 이 딕셔너리에서 `persist_checkpoint` 를 **읽기만** 한다. `Callable` 이 없으면(앱이 아직 안 넘겼으면) 저장을 조용히 건너뛴다 — **게임은 절대 멈추지 않는다.** 이것이 §19 OQ-9의 W0 요청 1번이다.

### 13.3 Death / downed

```
integrity -= 1 (DamagePerHit)
integrity == 0 이면:
  t = 0
  downed_for 동안: 암전(opacity 0→1, DOWNED_BLACKOUT 0.90s까지)
  downed_for >= DOWNED_BLACKOUT(1.4):
     carried 를 전부 버린다 (consumed 로 옮기지 않는다. drop 목록도 만들지 않는다)
     integrity = INTEGRITY_MAX
     position = checkpoint.position, stratum = checkpoint.stratum_id, mass = checkpoint.mass
     facts = checkpoint.facts (유지)
     carried = checkpoint.carried (체크포인트 시점 상태로 복원)
     -> 이게 "물질을 잃지만 지식은 남는다"의 구현이다
  무적 시간은 복귀 직후 0으로 두지 않는다. DOWNED_FADE_IN 0.30s 동안 invulnerable_for = 0.30
```

- **핵심**: 체크포인트가 앵커 시점의 `carried` 를 **스냅샷으로** 가지고 있으므로, 죽으면 그 시점의 짐으로 돌아간다. 앵커 이후 얻은 물질과 소비한 물질은 잃는다. `facts`는 체크포인트와 별개로 **런 전체에서 절대 잃지 않는다.**
- 체크포인트가 비어 있으면(§6.6 규칙대로) `stratum_index` 층의 첫 앵커로 복원, 없으면 `spawn`으로 복원.

### 13.4 load sanitize

`load_state(state)` 순서 (고정):

1. `data = migrate_save(state.get("schema", 1), state.duplicate(true))`
2. 스키마가 1이 아니면 `{schema:1}` 리셋, `first_frame`로 복귀 — **부분 로드를 시도하지 않는다**
3. 필드별 클램프: `mass` 0..4, `integrity` 0..3, `stratum_index` 0..5, `facing` ±1
4. `carried` 검증: `verb` ∈ 4종, `size` 1..3, `tag` 비어있지 않음. 위반 물질만 제거. 합이 4 초과면 뒤에서부터 제거.
5. `stratum_id` 로드 시도. 실패 시 `index` 기준으로 다음 authored 층으로 대체 (`§6.6`)
6. `anchor` / `site` / `route` / `brittle` ID들을 `StratumRuntime` 의 `entered`/`done`/`opened`/`broken` 플래그에 반영
7. `velocity`, 쿨다운, 무적, 전환 플래그 전부 0/false로 초기화
8. `phase = "first_frame"` (재생성이 아니라 시작 프레임 hold로 이어진다)

`enter()` 안에서 `_ready()`에서 게임을 시작하지 않는다. (`docs/MODULE_CONTRACT.md`)

### 13.5 reset

`execute_command(&"reset", {})` → `load_state({})` + `world_seed` 재생성. `execute_command(&"retry", {})` → `load_state(save_state())` 로 체크포인트 복귀(즉시 사망, 앵커 재시도). `execute_command(&"input_profile", {...})` → §12.3. 그 외 command는 `false`.

### 13.6 몸통 상태 인계 — `body` / `creature` / `place`

이 Kit은 세 축의 **소유자가 아니다.** `body` 와 `creature` 는 `sideview_ecosystem`이 소유하고, `place` 는 authored content가 소유하며 런타임에 **불변**이다. 이 Kit은 셋을 **읽기만** 하고, 쓰기는 **요청**한다. 판정은 스토어가 한다. (`core/worldstate/DESIGN_DECISION.md` §6 매트릭스)

| 축 | 이 Kit의 위치 | 판정 주체 |
|---|---|---|
| `body` | 읽기 O / 쓰기 **요청** | 스토어(소유 Kit의 규칙으로) |
| `creature` | 읽기 O / 쓰기 **요청** | 스토어(소유 Kit의 규칙으로) |
| `place` | 읽기 O / 쓰기 **X — 요청조차 하지 않는다** | 무조건 거부 |

**이 Kit이 소유하는 것은 저장은 1벌뿐이고 그것도 뷰다.** (§6.7)

### 13.6.1 인계 방식 — `ModuleContext.arrival` 하나뿐

- `arrival["worldstate"]` 로 **읽기 전용 뷰**가 도착한다. 값 복사가 아니라 **참조**다(설계 §3). 이 Kit은 그 뷰에서 읽기만 하며, 뷰를 수정하지 않는다.
- `arrival["request_mutation"]` 가 유효한 `Callable` 이면 이 Kit이 **유일하게** 쓰는 쓰기 경로다. 부재하면 **조용히 쓰기를 포기한다** (§13.2와 같은 강도 — 게임은 절대 멈추지 않는다).
- 이 Kit은 스토어 노드를 찾지 않는다. `/root` 를 보지 않는다. 다른 모듈을 보지 않는다. `core/worldstate/**` 을 `load` 하지 않는다. **뷰는 오직 `arrival`로만 온다.**
- 정확한 키 이름과 시그니처는 `core/worldstate/CONTRACT.md` 가 정본이다. 이 절의 이름들은 그 계약이 확정되기 전까지 **설계 문서에서 도출한 이름**이고, 계약이 다르면 계약에 맞춘다. **이 Kit은 `request_mutation` 외의 쓰기 경로를 만들지 않는다.**
- `arrival["worldstate"]` 에 `body` 키가 **아예 없으면** 이 Kit은 그 런에서 `body` 규칙을 **적용하지 않는다.** 부력을 보정하지 않고 `requires_body` 자리도 닫지 않는다 — 판단할 근거가 없으므로 판단하지 않는다. `push_warning` 1회. **값이 없을 때 0으로 만드는 것은 정규화다**(설계 §4).

### 13.6.2 `body` — 이 Kit의 하강에 남기는 두 가지

이 Kit이 `body` 에서 **이는 값은 셋뿐**이다. 성격·기억·카르마식 값은 **읽지 않는다.** 읽어서 통과 조건으로 쓰면 그것은 카운터다(§0.2-2, §17).

| 파생값 | 계산 | 범위 |
|---|---|---|
| `limb_deficit` (`d`) | `body.missing` 중 `part` ∈ `LIMB_PARTS` 의 **개수** | 0..4 |
| `hands_free` | `HANDS_TOTAL`(2) − `body.missing` 중 `part` ∈ `HAND_PARTS` 의 개수 | 0..2 |
| `has_wound(spec)` | `body.wounds` 배열에 `spec` 을 **만족하는 원소가 1개라도 있으면** 참 | bool |

- `body.missing` 의 원소가 `{part, kind, severity, permanent}` 모양이 아니면 **그 원소를 세지 않는다.** 모양을 추측해 채우지 않는다.
- **`d` 와 `hands_free` 는 이 Kit의 해석이지 축 값의 변환이 아니다.** `severity = 7` 인 상처를 0..4로, `scale = 1.9` 인 몸을 0..1로 환산하지 않는다. **개수를 세는 것과 값을 바꾸는 것은 다르다.**

**(1) 부력 — 하강에서 물리적으로 측정되는 흔적**

```
currents[] 안에서만:  flow_effective = flow - ( BUOY_PER_LIMB * d )      # BUOY_PER_LIMB = 6.0
흐름 밖(free-fall):  변화 없음. PlayerMotion 은 body 를 모른다.
```

| `d` | 부력 보정 | `tide_main`(-62) 통과에 필요한 mass | `return_flow`(-26) 상승 속도(mass 0) |
|---:|---:|---|---:|
| 0 | 0 | **3** (72 > 62) | 26 |
| 1 | −6 | **3** (66 > 62) | 32 |
| 2 | −12 | **4** (86−12=74 > 62. mass 3의 60 은 통과 불가) | 38 |
| 3 | −18 | **4** (68 > 62) | 44 |
| 4 | −24 | **불가** (mass 4의 62 는 62 보다 크지 않다) | 50 |

- **팔다리 4개가 모두 없으면 어떤 mass 로도 `tide_main` 을 뚫지 못한다.** 그래서 우회구는 `requires_body` 없이 **항상** 열려 있어야 한다. `stratum_teeth` 의 `membrane_brine` 우회구(§4.5)가 정확히 그것이고, `d` 0..4 어느 값에서도 구간 3에 도달한다. **소프트락 0개.**
- 이것이 "`body` 의 부재가 이 Kit의 하강을 바꾼다"의 **정확한 수치**다. **레퍼런스 충실도가 아니라 본 Kit 결정**이다.
- `d` 는 `mass` 를 바꾸지 않는다. `PlayerMotion` 의 어떤 상수도 손대지 않는다. 따라서 §4.8의 "질량계수 변화 지점은 1·2·3·4 네 곳" 불변식과 `test_descent_exploration_systems.gd` 의 기존 단언이 그대로 성립한다.

**(2) 손 — 결말 판정에 남기는 흔적**

`stratum_floor` 의 `heart_meld`(`HEART_MELD_RADIUS 56`, `verb:"feed"`, `tag:"seed"`, `hold_seconds 0.9`)에 `place.requires_body = {"hands_min": 1}` 이 얹힌다.

| `hands_free` | `heart_meld` | `ending.swallow` |
|---:|---|---|
| 2 | 열린다 | 가능 |
| 1 | 열린다 | 가능 |
| 0 (양손 부재) | **닫힌다** — `hold_seconds` 진행도 0에서 시작, `desc_denied` 1회, atomic | **불가능** |

- 양손을 잃은 몸은 `ending.swallow` 를 **잃는다.** `ending.hollow`(항상 열림)와 `ending.return`(§4.7)은 그대로다. **결말이 오염되지 않는다 — 하나가 닫힐 뿐이고, 항상 하나는 열린다.**
- 닫힌 자리는 열린 자리와 **똑같이 조용하다.** 별도 안내 문구·시각·오디오를 추가하지 않는다.
- `MAX_CARRY_MASS 4` 는 **손 상태와 무관한 정적 상수**다(§13.6.6).

### 13.6.3 `creature` — 죽은 개체를 이 Kit 자신의 방식으로 그린다

이 Kit이 `creature` 에서 읽는 키는 `id` / `state` / `den` **셋뿐**이다. `stage`·`traits`·`memory` 는 **읽지 않는다.** 읽어 통과 조건으로 쓰면 카운터가 된다.

| `creature` 뷰의 상태 | 이 Kit의 authored 렌더링 |
|---|---|
| `id` 가 `fauna[].id` 와 같고 `state == "dead"` | **`remains`(잔해)** 를 `fauna[].remains_at` 에 정적 배치 |
| `id` 가 같고 `state` 가 `"dead"` 가 아닌 다른 authored 값 | 배치 **없음** + `push_warning` 1회. 이 Kit은 `state` 값 목록을 모른다. 모르는 값에 해석을 붙이지 않는다 |
| `id` 가 같고 `den` 의 지역이 이 층의 지역이 아님 | 배치 없음. `push_warning` 없음(정상) |
| `id` 가 아예 없음 | 배치 없음 + `push_warning` 1회 |

**`remains` 의 계약 — 아래는 전부 "없음"이다.**

- `pending_damage` 를 **만들지 않는다.** (`FaunaAgent.step_all` 이 `pending_damage` 를 0건 반환)
- `solids` 가 아니다 — **충돌이 없다.**
- `consume` 대상이 아니다. `USE_RADIUS` 판정을 받지 않는다.
- 이동 없다. `line_y` 판정 없다. 순찰·추격·도망 상태기계에 **어떤 상태도 없다.**
- 오디오 이벤트 **0건.** §11의 13종 표에 14번째를 추가하지 않는다.
- `facts`·`sites_done`·`routes_opened`·`ending` 판정에 **영향 0.** `elapsed_play` 에도 넣지 않는다.
- `FaunaAgent` 의 **유일한 예외 상태**다. 그래서 구간 0의 "저해 없음"(§4.5) 불변식이 깨지지 않는다 — `remains` 는 저해가 **아니다.**

`remains_at` 은 **선택 키**다. 없으면 `remains` 를 그리지 않는다(기본 = 안 그린다 = 저해 0건). **validator 규칙을 새로 추가하지 않는다** — 좌표 범위 규칙(§15.2 `모든 좌표가 [0,640]×[0,1024] 안`)만 자동으로 적용된다. 신규 검증 규칙 0개.

첫 배치: `stratum_roots.fauna[]` 에 `id = "fix.gardener"`, `remains_at = [96, 872]`. 스토어가 준 `state` 가 `"dead"` 이면 구간 0 정원에 **조용한 자리 하나**가 있다. Kit A에서 죽은 개체가 이 Kit에서 무엇으로 보일지에 대한 이 Kit의 답이 이것이다 — 시체도 잔해도 빈자리도 아닌, **부력을 1개 잃은 자리**로.

### 13.6.4 `place` — 세 장면 인계표

`place` 는 authored 지형이고 런타임에서 불변이다. 이 Kit은 `region_id`(장면 수용 판정)와 `requires_body`(자격 조건)만 읽고 **쓰기를 요청하지 않는다.** 요청해도 스토어가 무조건 거부한다.

| 장면 | 이 Kit의 지형 authored 여부 | 읽는 것 | 이 Kit이 정하는 수치 | 상태 |
|---|---|---|---|---|
| `place.ruined_garden` | **있다** — 구간 0 `stratum_roots` 가 이 장면의 `descent` 축 렌더링이다. 읽기만 | `body`(`d`, `hands_free`) · `creature`(`fix.gardener`) · `place.requires_body`(비어 있음) | `d` 0 → `tide_main` 필요 mass **3**; `d` 2 → **4**; `d` 4 → **불가**(우회구로만). `fix.gardener.state == "dead"` 이면 `[96, 872]` 에 `remains` 1기 | 수치 = **본 Kit 결정** (레퍼런스 충실도 아님) |
| `place.tea_stair` | **없다** — 이 Kit은 이 장면의 지형을 authored 하지 않는다. 읽기만 | `place.requires_body.scale_min` · `creature`(`fix.butler`)의 `state` | `requires_body = {"scale_min": 0.7}`. `body.scale >= 0.7` 이면 통과, **미만이거나 키가 없으면 통과 불가.** `body.scale` 을 0..1로 **정규화하지 않고** 0.7과 그대로 비교한다. `fix.butler` 가 `state != "dead"` 이면 통과를 **막지 않는다**(경비 = 통과 허용). `state == "dead"` 이면 통과 가능. `fix.butler.memory` 는 **읽지 않는다** — 이 Kit은 이 장면의 지형도 authored 하지 않으므로 기억을 통과 조건으로 쓸 근거가 없다 | 수치 = **본 Kit 결정** (설계 문서는 `scale_min` 을 예시로만 제시) |
| `place.mirror_march` | **없다** — 읽기만 | `place.requires_body` 의 상처 조건 · `body.wounds` | `requires_body = {"wound": {"part": "face", "kind": "crack", "severity_min": 2, "permanent": true}}`. `body.wounds` 에 이 조건을 **만족하는 사실이 1개라도 있으면** 통과, **없으면 통과 불가.** 요약값으로 바꾸지 않는다. `severity` 는 `body` 가 준 정수와 그대로 비교한다 | 수치 = **본 Kit 결정** (설계 문서가 값을 열었다) |

- `tea_stair`·`mirror_march` 로 라우팅된 경우 이 Kit은 §6.6의 "authored 디렉터리에 없는 `stratum_id`" 규칙이 그대로 적용된다(다음 authored 층으로 대체 + `push_warning` 1회 + **게임이 멈추지 않는다**). **이 Kit은 이 두 장면의 지형 소유자가 아니다.**
- 지역 충돌 하나: `region_hollow` 의 시작이 "지상의 무너진 정원"인지에 대해 `docs/world/11_CONFLICTS_WITH_PLANS.md` §1이 별도 충돌로 등록해 있다. **그건 W1/W0의 소유이며 이 Kit이 임의로 정하지 않는다.** 위 표는 "이 장면이 이 Kit의 구간 0에 해당한다"는 이 Kit의 **현재** 매핑을 그대로 적은 것이다.

### 13.6.5 쓰기 요청과 거부 처리

이 Kit이 요청하는 쓰기는 **한 종류뿐**이고 **best-effort** 다.

| 시점 | 요청 | 거부 시 |
|---|---|---|
| brittle 벽을 **런에서 처음** 깼을 때 (`WORLDSTATE_REQUEST_MAX_PER_RUN` 1회) | `request_mutation("body", {"wounds": [{"part": "torso", "kind": "shard", "severity": 1, "permanent": true}]})` | `push_warning(reason)` **1회**. `integrity` 에 **반영하지 않는다**(중복 계상 금지). 게임 계속 |

- `creature` 쓰기는 이 Kit이 **하지 않는다.** `place` 쓰기도 **요청하지 않는다.** 무조건 거부될 것을 알면서 requesting 하는 것은 코드가 아니라 기도다.
- **거부 처리 4줄로 고정:**
  1. 반환값이 거부면 `push_warning` **1회**만 낸다. 2회 이상 내지 않는다.
  2. **이 Kit의 로컬 상태는 요청과 무관하게 이미 결정되어 있다.** `body` 요청이 거부되어도 `integrity` 는 이미 깎였고 **되돌리지 않는다.** 부분 적용을 시도하지 않는다.
  3. 요청과 거부의 사유는 이 Kit 저장에 **남기지 않는다.** `consumed`·`checkpoint`·어떤 필드에도 넣지 않는다. 거부가 쌓이면 새 카운터가 된다.
  4. **프레임을 멈추지 않는다.** 예외를 삼키지 않는다 — 호출이 실패해도 루프를 중단시키지 않는다. `request_mutation` 이 `null` 이거나 `Callable` 이 아니면 **호출조차 하지 않는다.**
- 반환 키 이름(`accepted` / `reason`)은 `core/worldstate/CONTRACT.md` 가 정본이다. 이 절의 이름은 설계 문서에서 도출한 것이며 계약이 다르면 계약에 맞춘다.

### 13.6.6 버림 충돌 — 이 Kit이 채택한 판정

**충돌의 실체.** 이 Kit은 원문 line 179 / 198 / 1643에서 "물질이 사라지는 경로는 `consume` 성공 하나뿐, 버리기 없음"이라고 적었다. 반면 세계 헌법 쪽은 버림을 **장소**로 기술한다 — `docs/world/04_DISTRICTS.md` 14(`loc.tear_pool`, "무게를 버리는 유일한 자리")와 17(`loc.hollow_keyhole`, "C는 버릴 물질이 있어야 넣을 수 있다" · "물건을 넣을 수 있는 손"). 손이 있어야 넣을 수 있으므로 **버림은 `body` 를 요구한다.**

> 위 인용은 **설계 시점의 문서 대조**다. §0.3 규약대로 **런타임 코드(`modules/descent_exploration/**`)는 `docs/world/**` 를 읽지 않는다.** `loc.tear_pool`·`loc.hollow_keyhole` 문자열조차 이 Kit의 코드에 나타나지 않는다.

**채택한 판정 — `docs/world` 쪽이 이긴다. 단 입력이 아니라 자리로.**

1. **버림은 입력이 아니다.** `docs/world/00_CONSTITUTION.md` 불변식 10이 "버리기 없음, 되찾기 없음"이라고 명시한다. 그러므로 **`drop` action·키·버튼은 추가하지 않는다.** §17의 금지 항목은 그대로 살아 있다.
2. **버림은 장소다.** 그 장소의 "손" 요구는 이 Kit에서 **자격 조건**으로 표현한다 — 권한 게이트가 아니라 능력 조건이며, 그것이 `place.requires_body` 다(설계 §2.3). "손이 있다"는 **버릴 수 있다**가 아니라 **`requires_body` 자리가 열린다**는 뜻이다.
3. **`carried` 에서 물질이 빠지는 경로는 정확히 3개다.**

| # | 경로 | 조건 | 되찾기 |
|---:|---|---|---|
| 1 | `consume` 성공 (§4.3) | `requires_body` 없음 — 무조건 | 불가 |
| 2 | **`requires_body` 성에린 `consume` 자리** (§13.6.2) | `hands_free >= 1` | 불가 |
| 3 | `downed` — 체크포인트 스냅샷으로 교체 (§13.3) | 무조건 | 앵커 시점 상태로 |

4. **`MAX_CARRY_MASS 4` 는 정적 상수다.** 몸 상태로 한도를 낮추지 않는다. 낮추면 `tide_main` 통과 mass 조건(§4.5)이 저절로 닫혀 **몸 상태가 authored 를 바꾸게 되고**, 그건 §9.4의 13개 검증 규칙을 다시 고치는 일이다. 이 Kit은 그 문에 들어가지 않는다.

**그래서 고친 줄 3곳.** 원문은 3경로를 1개로 적어 `downed`(§13.3)와 자기 자신과 모순됐다.

| 위치 | 원문 | 바뀐 문장 |
|---|---|---|
| §4.2 | "운반 한도는 4이고, 물질은 `consume` 성공으로만 사라진다(버리기 없음, §4.3)" | "운반 한도는 **4로 정적**이고(`body` 상태와 무관, §13.6.6), `carried` 에서 물질이 빠지는 경로는 `consume` 성공 / `requires_body` 성에린 `consume` 자리 / `downed` 스냅샷 교체 **3개**다(§13.6.6). 되찾기는 **어느 경로에도 없다.**" |
| §4.3 | "물질이 사라지는 경로는 `consume` 성공 **하나뿐**이다." | "`carried` 에서 물질이 빠지는 경로는 **3개**다 — `consume` 성공, `requires_body` 성에린 `consume` 자리(§13.6.2), `downed` 스냅샷 교체(§13.3). **②는 새 입력이 아니다.**" |
| §17 | "물질이 사라지는 경로는 `consume` 성공 하나뿐이다." | "`carried` 에서 물질이 빠지는 경로는 §13.6.6 표의 **3개**뿐이다. **`drop` action·키·버튼은 여전히 금지**이고, `requires_body` 는 새 입력이 아니라 **기존 `consume` 자리에 얹히는 조건**이다." |

**고치지 않은 잔여 위험 — 이 Kit이 감수하고 W0에 알린다.**

`pick_up` 이 자동(§4.3)이고 `mouth.above` 가 `blocks_tag: ["seed"]`(§4.7)이므로, `matter_seed_vial` 을 이미 주운 런은 `ending.return` 을 열 수 없다. 그런데 `requires_body` 성긴 자리는 **구간 5의 `heart_meld` 하나뿐**이라 층 2에서는 되돌릴 수 없다. 즉 `ending.return` 이 층 2의 물리적 선택이 아니라 **그 물질을 줍지 않았는지에 달린 상태**가 된다. `ending.hollow` 가 항상 열려 있으므로 **소프트락은 없다.** 다만 결말 1/3이 운에 의존할 수 있다.

> **미결 — 이 Kit은 지금 placement 를 바꾸지 않는다.** §19.1 규칙 2에 따라. 판정 근거는 실측이다: §14.3 루트 3을 플레이해 "`tag: "seed"` 물질을 주운 뒤 `ending.return` 이 닫혔다"가 관찰되면 그때 §6.5 예시 저장과 §9.7 `stratum_teeth` 배치를 **함께** 고치고 §19 에 OQ를 추가한다. 관찰되지 않으면 유지한다. 어느 쪽이든 **OQ 가 열려 있는 동안 `authored` 를 건드리지 않는다.**

---

## 14. Reference Game — 10분+ 플레이 흐름

### 14.1 authored content 단위

**하강 구간(stratum) 하나.** 파일 1개 = 단위 1개.

### 14.2 왜 6개 구간이 10분을 "합법적으로" 채우는가

사용자 제약: 대기·긴 이동·반복 동일 입력·대사 패딩·숫자 부풀리기로 10분을 채우지 않는다.

**대기 시간이 구조적으로 불가능하다.** 아무 키도 안 누르면 §4.1에 따라 계속 가라앉고, 그 결과 §4.5의 저해 중 하나에 반드시 닿는다. 층 안의 정지 상태는 물리적으로 존재하지 않는다. 층당 유일한 무입력 구간은 전환 0.9초 + `downed` 1.4초다.

**시간 예산 (실측 목표, 강제 아님):**

| 구간 | 도착→해결 | authored 선택 | 저해 해소 | 소계 |
|---|---|---|---|---|
| 0 `stratum_roots` | 55s | 15s (plaque, 구슬) | 20s (brittle 1개) | **1:30** |
| 1 `stratum_halls` | 70s | 0s | 55s (brittle 3개 순서) | **2:05** |
| 2 `stratum_teeth` | 70s | 35s (경로 택1) | 55s (물살 또는 막) | **2:40** |
| 3 `stratum_nursery` | 65s | 25s (plaque, 벽 파괴) | 50s (grazer 회피) | **2:20** |
| 4 `stratum_gallery` | 60s | 20s (hammer, vault) | 70s (`line_y` + strike) | **2:30** |
| 5 `stratum_floor` | 50s | 40s (각문 결정) | 55s (warden 회피 + 화로 13s) | **2:25** |
| 전환 5회 | | | | 0:45 |
| 결말 | | | | 0:30 |
| | | | **합계** | **≈ 14:45** |

- 첫 통과는 11~15분, 위치를 아는 재플레이는 8~10분. **10분+ Reference Game 요건을 첫 통과로 만족한다.**
- 상한 규칙: **어떤 구간도 150초를 넘기지 않는다.** 넘으면 authored 좌표/저해가 과한 것이므로 그 구간 JSON을 고친다. core는 건드리지 않는다.
- 하한 규칙: 어느 구간도 40초 미만 분량을 목표로 하지 않는다. 40초는 6개 authored 저해 중 2개를 건너뛴 경우다.

### 14.3 비트 시트 (플레이 순서, 그대로 따라 하면 된다)

**선택 A — "돌아오기" 루트 (`ending.return`) — **첫 런에서는 성립하지 않는다**

`ending.return`의 조건은 `fact:vent_above` + `tag:"seed"` 미보유다. `vent_above`는 구간 3의 brittle 벽 뒤에서만 나오고, `matter_seed_vial`은 구간 2의 `cap_ledge`에 있다. 그러니 이 루트에는 구간 2에서 `seed`를 **전혀 얻지 않은 상태로** 통과해야 한다.

| 층 | 이 루트의 진행 | 질량 수학 |
|---:|---|---|
| 0 roots | `matter_roots_bead`(weigh 1)를 먹지 않고 plaque만 접촉 | 0 |
| 1 halls | brittle 3개 통과 | 0 |
| 2 teeth | `matter_teeth_shard`(strike 1) + `matter_brine_plug`(plug 3) = **mass 4**. `exit_teeth_plug`(막 소비) 사용 → 소비 후 **mass 1** | 4 → 1 |
| 3 nursery | `matter_nursery_rib`는 먹지 않는다(먹으면 mass 2가 되어 아무 의미가 없다). `plaque_wall` 파괴 → `site_nursery_plaque` → **`vent_above` 획득** | 1 |
| 4 gallery | `matter_gallery_hammer`를 먹지 않는다. `line_y` 위쪽(`line_y: 240`)에서만 움직여 warden와 **만나지 않는다** | 1 |
| 5 floor | `mass 1`이면 화로의 `-26` 오르막을 44px/s로 13.1초 올라 `mouth.above` 도달. `tag:"seed"` 미보유 → `blocks_tag`에 안 걸림 | 1 |

**이 루트가 첫 런에 막히는 지점은 딱 한 곳이다:** 구간 2의 `exit_teeth_sink`가 `clearance: 3`을 요구하는데 이 루트는 `mass 4`까지는 갈 수 있다 — **실제로는 `exit_teeth_plug`를 쓰므로 통과한다.** 즉 A 루트는 **수학적으로 가능하다.** 막히는 지점은 **구간 4**다. `mass 1`이면 warden 56px/s를 59px/s로 피할 수 있으나, `line_y` 아래로 한 번이라도 내려가면 `gallery_deck_b`에서 반드시 한 번 걸린다. 그러니 A 루트는 **첫 런에서 체해를 1~2회 맞고** 통과한다. 그게 Reference Game의 1회차 본성이고, 앵커가 있으므로 그 자리에서 바로 재개한다. **재개하면 지식이 남으므로 두 번째 시도에서 `vent_above`를 이미 가진 상태로 루트를 다시 연다.** 이것이 §14.3의 존재 이유다.

**선택 B — "삼키기" 루트 (`ending.swallow`, Reference Game 정본)**

`ending.swallow`의 도달 조건을 질량 수학으로 먼저 확정한다.

```
구간 0 : matter_roots_bead(weigh 1) 획득                     → mass 1
구간 1 : brittle 3개 통과                                     → mass 1
구간 2 : matter_seed_vial(feed 1) 획득                        → mass 2
         matter_teeth_shard(strike 1) 획득                    → mass 3
         exit_teeth_sink 통과 (clearance: 3 만족, 하강 72 > 물살 62)
구간 3 : mass 3 >= GRAZER_FLEE_MASS(2) 이므로 grazer 가 도망   → 통과 용이 (이게 값이다)
         site_nursery_plaque 는 건드리지 않는다 (vent_above 를 얻으면 선택지가 늘어난다)
         matter_nursery_rib 도 먹지 않는다 (mass 4 가 되면 gallery 가 불가능해진다)
구간 4 : mass 3 의 수평 최대 53 < warden 56 이므로 **달아날 수 없다**
         matter_gallery_hammer(strike 1) 획득                  → mass 4
         strike 1회로 warden 를 버티고 line_y 위로 복귀
         site_nursery_plaque 미보유 이므로 gallery_vault 는 열리지 않는다
구간 5 : mass 4, tag:"seed" 보유
         heart_meld(tag seed) 에 feed → hold 0.9s → 열림
         mouth.above 는 blocks_tag("seed") 로 닫혀 있다
         mouth.heart → ending.swallow
```

| 층 | 하는 일 | 검증 |
|---:|---|---|
| 0 | bead 획득 + plaque 접촉 + `throat_wall` 파괴 | `mass 1` 이동, 사실 획득 |
| 1 | brittle 3개 통과 (mass 1) | `regrow_seconds` |
| 2 | seed(1) → shard(1) = mass 3. **plub(3) 는 건드리지 않는다** (mass 4 가 되고 배낭이 잠긴다) | `clearance: 3` 순간 판정, 배낭 여유 |
| 3 | grazer 도망. plaque/rib 건드리지 않음 | `GRAZER_FLEE_MASS` 경계 1↔2 |
| 4 | warden 출현 → hammer 획득 → strike 1회 → `line_y` 위 복귀 | `WARDEN_CHASE_SPEED 56` vs `HORIZ_MAX 53`, `line_y` |
| 5 | `heart_meld` 에 feed 0.9s → `ending.swallow` | `tag_available` + `hold_seconds` + `blocks_tag` |

**이 루트가 10분을 정당하게 채우는 이유:** 6개 층 전부 통과, 3번의 서로 다른 저해(brittle / 물살+막 / warden) 를 각각 다른 방식으로 해결, 4개 verb 중 3개를 실제로 소비(`weigh` `feed` `strike`), 2개 결말 문(`mouth.heart` 열림, `mouth.above` 닫힘)을 **보면서** 끝낸다.

**선택 C — "정지" 루트 (`ending.hollow`)**: 어느 길로든 바닥에 닿은 뒤 `mouth.still`로 간다. 항상 열림. **"끝까지 못 내려간" 사람의 루트이며, 어떤 런이든 최종적으로 도달 가능하다.**

**선택 A 재개 — "돌아오기" 루트 (`ending.return`)**

`downed` 는 지식을 지우지 않는다. 그러므로 선택 A에서 체해를 맞고 앵커에서 재개하면, `vent_above`를 이미 가진 상태로 루트를 다시 연다. 구슬을 먹지 않은 상태로 구간 2를 `exit_teeth_plug`로 통과하고, gallery에서 `line_y` 위쪽만으로 내려간 뒤, 바닥에서 `mouth.above`로 13.1초 올라 `ending.return`을 얻는다. **`seed`를 한 번도 먹지 않았으므로 `blocks_tag`에 걸리지 않는다.**

**이것이 §14.3의 존재 이유다:** 10분을 한 번에 못 끝내도, 지식이 남으므로 두 번째 시도에서 **다른 authored 분기**를 연다. 이것이 "기다림·반복 입력으로 10분을 채우지 않는다"는 사용자 제약을 지키면서 10분+ Reference Game을 만들 수 있는 유일한 구조다.

### 14.4 하드코딩 방지량 (검증 가능하게)

| 항목 | 수치 |
|---|---|
| 서로 다른 authored 단위 | **6** (구간 JSON 6개) |
| 같은 subsystem을 다른 조건으로 재사용한 횟수 | 이동 6회 / 흐름 2회(`tide_main` `return_flow`) / brittle 5개(`throat_wall` `plaque_wall` `vault_wall` 포함) / `requires` 5종 **전부 실제 사용**(`always`·`fact:vent_above`·`clearance:3`·`tag_available`·`opened:site_nursery_plaque`) / `FaunaAgent` 2종(grazer 1, warden 2) / `MatterLoop` verb **4종 전부 실제 사용**(`weigh`·`plug`·`feed`·`strike`) / 결말 3종 |
| 마지막 증명 | `authored/strata/stratum_extra_probe.json` 1개를 **추가해서** `test_descent_exploration_content.gd` 가 통과하고 Reference Game이 7번째 층으로 내려갈 수 있음을 보이면 끝. 그 층은 **저해를 `currents` 1개 + `membranes` 1개만** 쓰고 `requires` 는 `opened` 1개로 authored **기존 ID 재사용**(`site_roots_plaque`)하게 한다 — 새 content가 기존 core와 기존 ID를 그대로 쓴다는 증거. **core 파일 0개 수정.** 이 파일은 검증 후 **삭제하지 않는다** — Proof로 남긴다 |
| `probe` 층이 지켜야 할 것 | `index: 6`, `location: "loc.probe"`, `next: ""`, `descent` route 1개, `ending` route 0개(§9.4 규칙 9는 6개 정본 층에만 적용하고 probe에는 적용하지 않는다 — 이 예외를 **`content_validator.gd` 의 `PROBE_LAYER_EXEMPT_IDS` 상수로 명시**한다) |

### 14.4.1 셋을 다 도달시키는 런 (검증 시 필수)

`ending.hollow` 는 항상 열리므로 셋 중 하나는 **무조건** 열린다. 나머지 둘은 authored 경로가 다른 런에서만 열린다. 검수자는 다음 3가지 런을 각각 실행한다.

| 런 | opens | 닫힘 | 준비 |
|---|---|---|---|
| R1 (§14.3-B) | `mouth.heart` | `mouth.above` (`blocks_tag`) | 구슬 O, seed O, plug X, rib X, plaque(nursery) X, hammer O |
| R2 (§14.3-A 재개) | `mouth.above` | `mouth.heart` (seed 미보유 → `tag_available` 실패) | 구슬 X, seed X, plug O, rib X, plaque(nursery) **O**, hammer X |
| R3 | `mouth.still` | 나머지 둘 | 어느 루트로든 바닥 도착 후 `mouth.still` |

`EndingResolver` 는 **동시에 둘 이상을 열지 않는다** 것을 단언해야 한다(§15.2).

### 14.5 다른 Kit과의 공유 검증

`region_hollow` / `loc.*` / `thing.*` ID가 이 Kit 밖에서 같은 문자열로 쓰이는지는 W1과 W0의 확인 대상이다. 이 Kit은 그 확인이 없어도 동작한다. (§19 OQ-4)

---

## 15. 자동 테스트

### 15.1 테스트 파일 (전체)

| 경로 | 담당 |
|---|---|
| `tests/core/test_descent_exploration_domain.gd` | `DescentState` 불변식, `FactLedger`, `MatterItem` |
| `tests/core/test_descent_exploration_systems.gd` | 11개 시스템 |
| `tests/core/test_descent_exploration_content.gd` | 로더 + validator 12규칙 + 6개 층 |
| `tests/core/test_descent_exploration_save.gd` | round-trip / stale / 클램프 |
| `tests/core/test_descent_exploration_module.gd` | `GameModule` 계약, `execute_command`, `input_profile`, 격리 |
| `tests/core/test_descent_exploration_audio.gd` | 매니페스트 13줄 파싱 + bus/중복/file 존재 |
| `tests/core/test_descent_exploration_worldstate.gd` | 몸통 인계: 축 읽기·쓰기 요청·정규화 금지·지식 유지·거부 처리 (§13.6) |

### 15.2 파일별 단언 (전부 적는다)

**`test_descent_exploration_domain.gd`**
- `new_state()` 기본값이 §6.1 표와 **필드별로** 일치 (`mass == 0`, `integrity == 3`, `phase == "first_frame"`, `facts.is_empty()`, `carried.is_empty()`, `elapsed_play == 0.0`)
- `grant_fact("x")` 2회 → `facts.size() == 1`
- `grant_fact` 는 `sites_done` 에 아무것도 추가하지 않음
- `pick_up(item)` 5번째(size 1 5개) → `false`, `carried.size() == 4`, 반환값이 배치 않은 **4개**
- `pick_up` 이 성공하면 `mass` 가 `size` 만큼 증가
- `consume(0)` → `carried[0]` 제거, `mass -= size`, `consumed.size() == 1`, 기록에 `matter`/`site`/`stratum` 3키
- `consume` 가 `false` 를 반환하면 `carried` / `mass` / `consumed` **셋 다 무변경** (atomic)
- `apply_damage(1)` × 3 → `integrity == 0`, `downed_for == 0.0`
- `apply_damage` 은 `invulnerable_for > 0` 일 때 `integrity` 를 줄이지 않음
- `to_save()` 결과에 `Vector2`/`Node`/`Resource` 가 없음을 재귀 검사 (depth 6)
- `to_save()` 에 `down_count` 키가 **없고** `down` 으로 시작하는 키가 하나도 없다
- `to_save()` 에 `open_bristles` 키가 **없다**
- `from_save(to_save())` 후 모든 필드가 원본과 동일

**`test_descent_exploration_systems.gd`**
- `PlayerMotion`: `intent` 전부 false를 1.0초 → `velocity.y > 25.0` (가라앉음 확인), `up` 홀딩 0.5초 → `velocity.y > 60.0`
- `PlayerMotion`: mass 0 vs mass 4 로 0.5초 스윕 후 하강 거리 비교 → mass 4가 **엄격히 더 큼**
- `PlayerMotion`: `surge` 후 `velocity` 가 `SURGE_SPEED_BASE - SURGE_SPEED_PER_MASS*mass` 로 **덮어써짐**(가산 아님). mass 0 → 168, mass 4 → 88
- `PlayerMotion`: `SURGE_COOLDOWN` 안의 두 번째 surge는 무시
- `DescentCollision`: 벽에 위에서 낙하 → `position.y` 가 벽 상단 - `BASE_BOX.y/2` 를 넘지 않음
- `DescentCollision`: X축이 Y축보다 먼저 해결됨 (수평 틈으로 들어가는 각도가 성립)
- `DescentCollision`: `surge_active_for > 0` 인 상태에서 brittle 접촉 → 벽 파괴 + `open_bristles` 추가
- `HazardField`: `tide_main` 안에서 `mass 2`(하강 58)일 때 1.0초 후 `velocity.y > 0` (아래로 못 내려감, 위로 떠오름)
- `HazardField`: 같은 영역에서 `mass 3`(하강 72)일 때 0.5초 후 `velocity.y > 0` (아래로 통과)
- `HazardField`: `return_flow`(-26) 안에서 `mass 0`일 때 1.0초 후 `velocity.y < 0` (위로 통과)
- `MatterLoop.consume`: `verb` 일치하지만 `tag` 불일치(`feed` 필요, `tag: "iron"` 보유) → `false`
- `MatterLoop.consume`: `weigh` 물질은 어떤 목표에도 일치하지 않으므로 **절대 소비되지 않는다**
- `MatterLoop.consume`: `carried[0]`이 목표가 없고 `carried[1]`이 목표가 있으면 **`carried[1]`이 소비된다** (앞에 쓸모없는 물질이 있어도 막히지 않는다)
- `MatterLoop.consume`: 유효한 목표가 하나도 없으면 `false` + `carried` 크기·내용 **무변경** (버리기 없음)
- `MatterLoop.pick_up`: `mass + size > MAX_CARRY_MASS` 면 `false`, `carried` 무변경
- `RouteResolver`: `requires: [{"kind":"clearance","mass":3}]` 에 mass 2 → 닫힘, mass 3 → 열림
- `RouteResolver`: `requires: [{"kind":"clearance","mass":3}]` 에 mass 4 → 열림 (2와 3 사이가 경계)
- `RouteResolver`: `fact` 조건은 `facts` 비면 닫힘, `site_nursery_plaque` 획득 후면 열림
- `RouteResolver`: `tag_available` 조건은 `carried` 에 `verb==feed and tag==seed` 있으면 열림, 없으면 닫힘
- `RouteResolver`: `opened` 조건은 `sites_done` 에 `site_nursery_plaque` 있으면 열림
- `RouteResolver`: `requires` 배열 2항목이면 **OR** (하나만 만족해도 열림)
- `RouteResolver`: `blocks_tag` 이 걸린 각문은 `carried` 에 그 tag 물질이 있으면 **닫힘으로 판정**한다
- `AnchorBook`: 재진입(같은 앵커 2회) → 체크포인트 갱신 **안 함**, `anchors_taken` 길이 불변
- `AnchorBook`: 앵커 진입 → `checkpoint` 의 `facts`/`carried`/`mass` 가 **진입 시점** 스냅샷
- `Vitality`: 3피 → `downed`, 복귀 후 `carried` 는 체크포인트 스냅샷, `facts` 는 **런 전체 값 유지**
- `FaunaAgent`: mass 1 → grazer 추격 / mass 2 → grazer 도망 / 141px 초과 → 순찰 복귀
- `FaunaAgent`: `warden` 는 `line_y` 위쪽 240px 안에서 `pending_damage` 를 **어디에도 내지 않는다** (존재하지 않음)
- `FaunaAgent`: `step_all` 은 `integrity` 를 직접 바꾸지 않음 (pending 만 반환)
- `EndingResolver`: `facts == []` + `carried` 없음 → `ending.hollow`
- `EndingResolver`: `facts` 에 `vent_above` + `carried` 없음 → 열린 각문은 `mouth.above` **하나뿐**, `mouth.heart` 는 닫힘
- `EndingResolver`: `carried` 에 feed/seed 있음 + `vent_above` 있음 → 열린 각문은 `mouth.heart` 하나뿐, `mouth.above` 는 `blocks_tag` 로 닫힘
- `EndingResolver`: **어떤 `carried` / `facts` 조합에서도 열린 각문이 2개 이상인 경우는 없다** (R1·R2·R3 전수)
- `EndingResolver`: `ending_id` 는 `ending.hollow` / `ending.return` / `ending.swallow` 3개 중 하나이며, 그 외 값이 나올 수 없다
- `DescentClock`: 0.1초 delta를 한 번 주면 서브스텝 **12개**가 아니라 **4개**만 돈다

**`test_descent_exploration_content.gd`**
- 정본 6개 층 파일 모두 `validate()` 오류 0건. `authored/strata/stratum_extra_probe.json` 이 존재하면 그것도 0건
- `load()` 결과 정본만 6개, probe 포함 시 7개. `index` 오름차순 `0..N-1`
- `exit_roots.next == "stratum_halls"`, `exit_floor.next == ""`
- `exit_teeth_sink.requires[0].mass == 3` 이고 `exit_teeth_plug.requires[0].kind == "always"`
- 13개 검증 규칙 각각을 **깨뜨린 최소 JSON**으로 해당 규칙이 실패를 낸다 (음성 테스트 13개)
- 규칙 11 위반 층: `descent` route 2개가 **둘 다** `clearance`만 쓰면 실패
- 규칙 9 위반 층: `ending` route 3개 중 id가 `mouth.heart`가 아니면 실패
- 규칙 13 위반 층: `membranes[].rect` 가 `exit_*` 또는 `mouth.*` 의 `trigger` 와 겹치면 실패
- `PROBE_LAYER_EXEMPT_IDS` 에 든 층은 규칙 9만 건너뛰고 나머지 12개는 그대로 적용된다
- 6개 층에 **중복 `id` 0개** (전 층 합산)
- 모든 좌표가 `[0,640]×[0,1024]` 안 (경계 포함)
- `descend` route 의 `trigger` 가 층 bounds 안이면서 **어떤 `solids` 의 내부와 겹치지 않는다** (접촉 불가능한 트리거 0건)
- authored JSON 전체를 `JSON.parse_string` 로 다시 파싱했을 때 오류 0건

**`test_descent_exploration_save.gd`**
- `save_state()` → `load_state()` → `save_state()` 결과 **deep equal** (JSON 직렬화 후 비교)
- `schema: 999` 로 `load_state` → `schema == 1`, `phase == "first_frame"`, `stratum_index == 0`
- `carried` 에 `verb: "nope"` 항목 → 로드 후 그 항목만 제거, 나머지 유지
- `carried` 합 6 → 로드 후 4 (앞 4개 유지)
- `facts: ["unknown_fact"]` → 로드 후 **그대로 유지** (사라지지 않음)
- `stratum_id: "stratum_nope"` → 로드 후 `stratum_teeth` 로 대체, `push_warning` 경로 통과
- `checkpoint: {}` → `stratum_roots#a1` 로 복원
- `velocity` 가 저장 dict에 **없음** (키 자체가 없음)
- `open_bristles` 가 저장 dict에 **없음**
- `down_count` 가 저장 dict에 **없음** (`to_save()` 결과 키 목록에 `down` 이 들어가지 않는다)
- `migrate_save(1, data) == data`

**`test_descent_exploration_module.gd`**
- `module_manifest.tres` 가 `load` 되고 `id == &"descent_exploration"`, `save_version == 1`, `input_actions.size() == 4`
- `input_actions` 가 `up`/`down`/`confirm`/`cancel` 4개만 포함 (`left`, `right` 없음)
- `enter(context)` 후 `context.input_enabled == true`
- `exit()` 후 `context.input_enabled == false`
- `execute_command(&"reset", {})` → `stratum_index == 0`, `mass == 0`, `facts.is_empty()`
- `execute_command(&"retry", {})` → 체크포인트 층/위치 복원
- `execute_command(&"input_profile", {"required_keys": [...4], "previous": []})` → `true`
- `execute_command(&"input_profile", {})` (키 없음) → `false`
- `execute_command(&"존재하지_않는_명령", {})` → `false`
- `input_enabled == false` 상태에서 아무 입력 intent도 시스템에 반영되지 않음
- 이 module이 **다른 module 노드를 찾지 않는다**: `get_tree().get_nodes_in_group("module")` 결과에 이 module이 접근한 흔적 없음 (코드 grep 기반 보조 assertion)
- **부정 검사 1 — `test_no_player_text_outside_whitelist`** (§10.9). `res://modules/descent_exploration/` 아래 `.gd .tscn .tres .json` 을 `DirAccess` 재귀 순회해 `FileAccess.get_as_text()`로 읽고, **R1**: `presentation/`·`domain/`·`systems/`·`module.gd` 본문에서 `text` `tooltip_text` `title` `placeholder_text` 속성과 `draw_string` 인자에 쓰인 문자열 리터럴을 전부 뽑아, 그 값이 §10.9-2의 `T1`~`T4` 중 하나와 완전 일치하지 않으면 실패(실패 메시지에 파일·줄·문자열). **R2**: `presentation/`·`domain/`·`systems/`·`module.gd`에 `하강` 리터럴 0건(T1은 `module_manifest.tres` 한 곳에만 존재). **R3**: `presentation/` 안 `draw_string` 호출이 **1건뿐**이고 그 인자가 `ending_id` → 화면 이름 매핑 결과인지 단언(하드코딩 리터럴 0건). **R4**: `authored/strata/*.json` 전체에 `title` `text` `desc` `description` `caption` `hint` `subtitle` `lore` `note` `memo` `summary` 키 0건(`display_name`은 허용되되 R1의 대상이 되지 않아야 한다). **R5**: 결말 화면 문자열이 `ending.hollow`→`정지` `ending.return`→`귀환` `ending.swallow`→`삼키다` 3쌍 외 값으로 나가지 않음. 주석은 판정 대상이 아니다
- **부정 검사 2 — `test_no_refilling_lore_device`** (§10.10). 위 `get_nodes_in_group` grep 보조 assertion과 **같은 방식**(코드 텍스트를 읽어 식별자 0건)이고 판정 대상만 다르다. `res://modules/descent_exploration/**` 의 모든 `.gd .tscn .tres .json` 본문을 읽어, **① 주석(`#`~줄 끝)과 문자열 리터럴 내용물을 제거한 뒤** 대소문자 무시 부분 일치로 `codex` `journal` `diary` `lore` `chronicle` `bestiary` `logbook` `encyclopedia` `recap` `epilogue` `afterword` `ending_summary` `ending_text` `story` `history` `exposition` `narration` `caption` `subtitle` `dialog` `dialogue` `speech` `monologue` `memo` `letter` `read_note` `unlock_note` `plaque_text` `tutorial` `hint_text` `explain` 가 **0건**이다(노드명·클래스명·함수명·시그널명·사전 키에 걸리면 실패). ② `presentation/` 아래 파일명·씬 이름에 위 토큰 0건. ③ `audio_manifest.json`에 `bus == "Voice"` 이벤트 0건(§11). ④ `docs/world` 문자열이 `load`/`preload`/`ResourceLoader` 인자로 쓰인 곳 0건. **주석을 먼저 제거하는 이유:** 이 Kit의 코드 주석과 계획에는 "도감", "기록", "설명"이 정당하게 나오므로 주석까지 매칭하면 판정이 아니라 잡음이 된다

**`test_descent_exploration_audio.gd`**
- `AudioManifest.from_file("res://modules/descent_exploration/audio_manifest.json")` 파싱 성공
- `manifest.id_prefix == &"desc"`
- `manifest.events.size() == 13`
- `manifest.validate()` 결과가 **빈 배열** (W3 렌더 전에는 실패해도 된다 — §19 OQ-6)
- 모든 이벤트의 `bus` ∈ `Music`/`SFX`/`UI`/`Voice`
- 모든 이벤트의 id가 `desc_` 접두사로 시작하고 중복 0
- 13개 id가 §11 표와 **이름·볼륨·폴리포니·쿨다운까지** 일치

**`test_descent_exploration_worldstate.gd`** — §13.6 전체를 검증하는 7개 파일 중 마지막. 여기의 실패는 3개 Kit 중 하나가 다른 모듈을 보고 있다는 뜻이다.

*인계 (hand-over)*
- `enter()` 전 `context.arrival["worldstate"]` 로 `body`/`creature`/`place` 3축이 모두 들어온 상태에서 `DescentWorldstateView` 가 3개를 모두 들고 있다
- `arrival["worldstate"]` 에 **`body` 키가 없으면** `limb_deficit` 를 만들지 않고 부력 보정을 적용하지 않으며 `push_warning` 을 **1회만** 낸다. `hands_min` 자리를 닫지도 연다
- 이 모듈이 `core/worldstate` 를 `load` 하거나 스토어 노드를 찾는 **코드 경로 0개** (`grep -rn "worldstate" modules/descent_exploration/` 결과가 `domain/worldstate_view.gd`·`systems/body_read.gd`·`systems/requires_body.gd`·테스트·본 plan 참조 외 0건, `get_node`·`get_tree().root` 인자 0건)
- `DescentWorldstateView` 를 **저장 dict에 넣으면 실패** — `to_save()` 결과에 `body`/`creature`/`place`/`limb_deficit`/`hands_free` 키가 **없다** (§6.7)

*정규화 금지*
- `body.missing` 에 `arm_left` 1개가 있고 `wounds` 의 `severity` 가 7인 상처가 있어도 `limb_deficit == 1` 이다. **7이 0..4로 환산되지 않는다**
- `body.scale` 이 1.9 여도 `RequiresBodyGate` 는 그 값을 0..1 로 바꾸지 않고 주어진 `scale_min` 과 **원래 값으로** 비교한다. `1.9 >= 0.7` 이고 `0.62 >= 0.7` 은 거짓이다
- `body.missing` 원소가 `{part, kind, severity, permanent}` 모양이 아니면 **세지 않는다.** `limb_deficit` 는 0 이고 `push_warning` 은 없다
- `body.missing` 키가 아예 없으면 `limb_deficit` 를 0 으로 **만들지 않는다**(§13.6.1). 회귀하면 이 단언이 잡는다
- 같은 입력으로 두 번 돌린 결과가 **바이트 단위로 동일**하다 (시드·시간 의존 없음)

*지식 유지 (knowledge persistence)*
- `facts` 에 `current_lies` 와 `vent_above` 가 있는 상태에서 3피 → `downed` → 복귀 후에도 `facts.size() == 2` 이다. **죽음은 지식을 지우지 않는다** (§13.3)
- 체크포인트 갱신 → `load_state()` → `facts` 2개가 **그대로** 돌아온다. 체크포인트는 앵커 시점 `facts` 를 **스냅샷으로** 가지므로 (§4.6) 새 앵커가 **기존 사실을 지우지 않는다**
- `creature.state` 가 `"dead"` 인 `fix.gardener` 로 `stratum_roots` 에 진입해도 `facts` 는 **늘지도 줄지도 않는다** — `remains` 는 사실이 아니다 (§13.6.3)
- `has_wound(spec)` 로 통과 조건을 만족해도 그 사실을 `facts` 에 **추가하지 않는다**. `body` 값은 `body` 축에 남고 이 Kit의 장부에 남지 않는다
- §6.1 표에 `down_count` / `death_count` / `known_total` 류 키가 없고, `to_save()` 키 목록 전체에 `creature` / `body` / `place` / `worldstate` 가 없다

*거부 처리 (refusal)*
- `request_mutation` 가 `{"accepted": false, "reason": "axis owner absent"}` 를 반환하면 `body` 요청이 **거부**되었고, 그 뒤에도 `integrity`·`carried`·`mass`·`facts` 가 **요청 직전과 동일**하다 (부분 적용 0건)
- 거부 시 `push_warning` 이 **1회**만 난다. 같은 장면에서 두 번째 요청은 아예 나가지 않는다 (`WORLDSTATE_REQUEST_MAX_PER_RUN == 1`)
- `request_mutation` 가 **`null`** 이거나 `Callable` 이 아니면 **호출되지 않는다** (호출 횟수 카운터 0). 게임이 계속되고 `desc_denied` 뿐이다
- 요청이 `raise` 하더라도 `_process` / 서브스텝 루프가 **중단되지 않는다** (§7 순서 1~11이 끝까지 돔)
- `arrival["request_mutation"]` 가 아예 없는 상태로 `enter()` 해도 진입이 성공하고 층 0이 로드된다
- 이 Kit은 `place` 축 쓰기를 **요청하지 않는다** — `request_mutation` 호출 인자의 axis 문자열을 수집해 **`"place"` 가 0건**임을 단언한다

*부력 (§13.6.2 수치 그대로)*
- `HazardField`: `tide_main` 안에서 `d == 0`, `mass 3` → 1.0초 후 `velocity.y > 0` (72 > 62)
- `HazardField`: `tide_main` 안에서 `d == 1`, `mass 3` → 1.0초 후 `velocity.y > 0` (72−6 = 66 > 62)
- `HazardField`: `tide_main` 안에서 `d == 2`, `mass 3` → 1.0초 후 `velocity.y < 0` (72−12 = 60 < 62, **불가**)
- `HazardField`: `tide_main` 안에서 `d == 2`, `mass 4` → 1.0초 후 `velocity.y > 0` (86−12 = 74 > 62)
- `HazardField`: `tide_main` 안에서 `d == 4`, `mass 4` → 1.0초 후 `velocity.y < 0` (86−24 = 62, **62 보다 크지 않다**)
- 흐름 밖(free-fall)에서 `d` 가 0이든 4든 `PlayerMotion` 결과가 **동일**하다 — 부력은 `currents[]` 안에만 있다
- `return_flow` 안에서 `d == 4`, `mass 0` 상승 속도가 `d == 0` 보다 **정확히 24 px/s 크다**

*`remains` (§13.6.3)*
- `fix.gardener.state == "dead"` + `remains_at` 이 있으면 `FaunaAgent.step_all` 의 `pending_damage` 가 **0건**이다
- 같은 `fauna` 항목에 `remains_at` 이 **없으면** 배치 자체가 없고 `pending_damage` 도 0건이다
- `state` 가 `"dead"` 가 아닌 값이면 `push_warning` **1회** 후 배치 0건
- `den` 이 다른 지역이면 `push_warning` **0회** (정상 경로)
- `remains` 는 `solids` 에 들어가지 않는다 — `DescentCollision` 스윕이 그 위치를 통과한다
- 구간 0에서 `remains` 가 있어도 `step_all` 이 반환하는 `pending_damage` 총합이 **여전히 0**이다 (§4.5 "저해 없는 층이 정확히 1개" 유지)

*`RequiresBodyGate` (§13.6.2)*
- `heart_meld` + `hands_free == 2` → `hold_seconds 0.9` 경과 후 **열림**, `ending.swallow` 가능
- `heart_meld` + `hands_free == 1` → **열림**, `ending.swallow` 가능
- `heart_meld` + `hands_free == 0` → **닫힘**. `hold_seconds` 진행도가 0이고 `carried`/`mass`/`consumed` **셋 다 무변경** (atomic), `ending.swallow` 판정 불가
- `hands_free == 0` 이어도 `ending.hollow` 는 열리고 `ending.return` 판정은 `blocks_tag` 로만 결정된다 — **닫힌 자리가 다른 결말을 닫지 않는다**
- `MAX_CARRY_MASS` 가 `hands_free` 값에 따라 달라지지 않는다 — 0이든 2이든 **4**다

*`place` 표 (§13.6.4)*
- `requires_body` 가 `{}` 인 `place.ruined_garden` 는 어떤 `body` 에서도 **닫히지 않는다**
- `place.tea_stair` 는 이 Kit의 `stratum` 목록에 없으므로 `stratum_id` 로 들어오면 §6.6 규칙(다음 authored 층 대체 + `push_warning` 1회 + **게임 정지 없음**)을 탄다
- `place.mirror_march` 도 동일하게 §6.6 규칙을 탄다

### 15.3 명령 (복사해 그대로 실행, 기대 ExitCode 0)

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'
$proj = 'C:\projects\TINProject'

$p = Start-Process -FilePath $GodotExe -ArgumentList "--headless --path $proj --editor --import" -NoNewWindow -Wait -PassThru
"import exit=$($p.ExitCode)"

$p = Start-Process -FilePath $GodotExe -ArgumentList "--headless --path $proj --script res://tests/run_tests.gd" -NoNewWindow -Wait -PassThru
"run_tests exit=$($p.ExitCode)"

$p = Start-Process -FilePath $GodotExe -ArgumentList "--headless --path $proj --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gexit" -NoNewWindow -Wait -PassThru
"gut_all exit=$($p.ExitCode)"

foreach ($t in @('domain','systems','content','save','module','worldstate','audio')) {
  $p = Start-Process -FilePath $GodotExe -ArgumentList "--headless --path $proj --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gtest=res://tests/core/test_descent_exploration_$t.gd -gexit" -NoNewWindow -Wait -PassThru
  "gut_$t exit=$($p.ExitCode)"
}

$p = Start-Process -FilePath $GodotExe -ArgumentList "--headless --path $proj --quit-after 180 --fixed-fps 60" -NoNewWindow -Wait -PassThru
"smoke exit=$($p.ExitCode)"
```

| 명령 | 기대 |
|---|---|
| `import` | `exit=0`. `.godot/`에 새 스크립트 import가 생김 |
| `run_tests` | `exit=0` |
| `gut_all` | `exit=0`, 실패 0 |
| `gut_domain` ~ `gut_worldstate` | 각 `exit=0` |
| `gut_audio` | W3 렌더 전 `exit≠0` 가능. **Kit 완료 시에는 무조건 0** |
| `smoke` | `exit=0`, `ERROR`/`SCRIPT ERROR` 0건 |

### 15.4 이미지 0개 자체 확인 (W0 게이트 보조)

```powershell
$bad = Get-ChildItem -Recurse -File 'C:\projects\TINProject\modules\descent_exploration' |
  Where-Object { $_.Extension -in '.png','.jpg','.jpeg','.webp','.bmp','.svg','.ttf','.otf','.aseprite','.kra' }
"binary_assets=$($bad.Count)"
```

기대 `binary_assets=0`. `.wav` 는 이 필터에 없다.

---

## 16. 수동 플레이 과제와 수용 기준

플레이어에게 설명하지 않는다. 아래 9개를 그대로 시킨다.

| # | 과제 | 관찰 대상 | 수용 기준 |
|---:|---|---|---|
| 1 | 앱을 켜고 아무 설명 없이 3분 플레이 | 첫 meaningful action까지 시간 | **8초 이내.** 3분 안에 층 1의 brittle 벽을 깨고 층 2에 닿음 |
| 2 | 1번 이어서 "엄청 내려가고 싶어" | 오조작 | `W` 를 3초 이상 눌렀는지, `S` 를 눌러 아무 일도 안 일어나는지 |
| 3 | "내려가고 싶은데 뭘 먹어야 하지" (스스로 해보기) | 잘못 읽은 affordance | 물질에 닿으면 **자동 획득**임을 1회 안에 인지. 인벤토리 UI를 찾지 않음 |
| 4 | 층 2에서 두 갈래 중 하나를 고르게 하기 | 선택의 인과 | 두 갈래가 **성질이 다름**을 인지(무거운 몸 vs 이미 아는 길). 같은 결과로 수렴하면 실패 |
| 5 | 일부러 체해를 맞게 하기 | failure에서 회복 | death 후 **앵커 위치에서** 복귀하고 **지식(`fact`)이 남아 있음**을 스스로 확인. 10초 안에 다시 움직임 |
| 6 | Esc를 눌러 보고 닫기 | focus 상실 | Esc 메뉴가 Shell 것. 닫은 뒤 즉시 재개. 게임 화면에 키 설명이 없음 |
| 7 | 12분 안에 아무 결말 하나에 도달 | 실패에서 회복 / 도움 필요 | **12분 이내.** 도움 요청이 나오지 않음 |
| 8 | 세 해상도에서 30초씩 | UI 겹침/잘림 | §16.1 |
| 9 | 세 Kit을 차례로 한 번씩 | 인계 | `place.ruined_garden` 를 `body.missing` 이 있는 상태로 세 Kit을 차례로 방문하고, **그 사실이 세 번 모두 화면에 살아있음**을 기록 (설계 §5 장면 A 판정 테스트) |

추가 관찰 항목: focus 표시 유지 / 월드 플레이 영역 유지 / 격자형 비율 유지(해당 없음) / 긴 문자열(해당 없음 — 이 Kit의 UI 문자열은 **결말 화면의 화면 이름 1줄뿐**이며 §10.9 `T2`~`T4` 중 하나다) / 메뉴 open/close 복귀 / **§10.9 화이트리스트 4슬롯 외 문자열 0건** / **§10.10 금지 장치 8종 0건** / **플레이 중 화면 문자열 0개**

### 16.1 해상도 수용 기준

| 해상도 | zoom | 캡처 | [ ] |
|---|---|---|---|
| 1280×720 | 2 | `docs/research/swallow_the_sea/capture_1280x720.png` | [ ] 플레이 영역 640×360 유지, 잘림 0, 안개 레이어가 UI를 가리지 않음 |
| 1920×1080 | 3 | `.../capture_1920x1080.png` | [ ] **가시 월드 범위가 1280×720과 픽셀 동일** (확대만 다름) |
| 2560×1440 | 4 | `.../capture_2560x1440.png` | [ ] 동일. 텍스처 필터링으로 흐려지지 않음 (가장 가까운 필터) |

**720p 캡처에는 1280×720 프레임만 있어야 한다** (letterbox 여백 없음). 여백이 보이면 zoom 스냅이 깨진 것이다.

**캡처 파일 위치 규칙:** 캡처는 `modules/descent_exploration/` **밖**에 둔다. ROUND_PLAN §5의 이미지 0개 게이트는 Kit 폴더(`modules/<id>/`)를 대상으로 하므로, 캡처를 그 안에 넣으면 게이트가 실패한다. 위 표의 `docs/research/swallow_the_sea/` 경로가 정답이다.

---

## 17. 금지 Shortcut

이 Kit에서 에이전트가 가장 싸게 도망갈 수 있는 구현을 전부 적는다. 하나라도 발견되면 그 구현을 폐기한다.

- [ ] **이미지 1개라도 만든다.** `modules/descent_exploration/` 아래 이미지/폰트/aseprite 파일 → 즉시 실패. 시각은 `core/procedural/` 만으로 만든다
- [ ] **카운터를 넣는다.** `int eaten_count`, `progress`, `score`, `biomass_total` 같은 누적값을 만들고 통과 조건으로 쓴다. §0.2-2 위반. `desc_count` 저장 금지
- [ ] **10분을 기다림·긴 이동·반복 입력으로 채운다.** 무입력 정지 상태를 만들면 안 된다. 같은 벽을 5번 두드리게 만들면 안 된다. 대사/문자열을 늘려 채우면 안 된다
- [ ] **placeholder `ColorRect`/`Label`을 월드 오브젝트로 쓴다.** 벽·흐름·개체는 전부 `ProceduralCanvas` 픽셀이어야 한다
- [ ] **화면에 나가는 문자열을 §10.9 화이트리스트(4슬롯) 밖에서 추가한다.** `정지` `귀환` `삼키다` `하강` 외 값 0개. 직접 `Button`을 만들어 라벨을 붙이는 것도 금지다
- [ ] **이 Kit이 직접 만든 `Button`에 라벨을 붙인다.** 버튼은 Esc 메뉴(Shell 소유)뿐이다
- [ ] **`plaque`에 읽을 수 있는 글자(명판·각인·읽기 UI)를 얹는다.** `sites[].kind: "plaque"`는 만지면 사실이 쌓이는 물체이지 설명 문서가 아니다
- [ ] **결말 화면을 1줄 이름에서 늘린다.** 요약·경로 회상·획득 사실 나열·달성률을 붙이면 §10.10 PF-04 위반이다
- [ ] **`Voice` 버스 이벤트나 대사·내레이션을 추가한다.** `desc_fact`는 이미 있는 신호다
- [ ] **도감·저널·해설 NPC·엔딩 요약 중 무엇 하나라도 만든다.** 획득 사실 목록, 방문 층 목록, "아직 못 본 것" 목록도 도감이다
- [ ] **`requested` 페이로드에 화면용 문자열을 넣어 셸이 그려지게 한다.** 표시가 필요하면 §19 OQ-9로 요청한다
- [ ] **상시 HUD를 추가한다.** 물질 개수·깊이 표시·현재 층 이름·자동저장 표시
- [ ] **긴 조작 설명 overlay / 튜토리얼 문장**을 넣는다
- [ ] **버튼 목록으로 월드 상호작용을 대체한다.** 개체 선택 목록을 UI로 만든다
- [ ] **콘텐츠 ID별 `if`/`match`를 `player_motion` / `route_resolver` / `matter_loop` / `collision` / `fauna_agent` 안에 쓴다.** `if stratum_id == "stratum_teeth"` 금지. 저해는 데이터다
- [ ] **`clearance`를 통과 조건의 유일한 수단으로 만든다.** 규칙 11이 이를 막는다. 순수 숫자 게이트 금지
- [ ] **물질을 버리는 동작(드롭)을 만든다.** `drop` action·키·버튼을 추가하지 않는다. `carried` 에서 물질이 빠지는 경로는 §13.6.6 표의 **3개**뿐이다. `requires_body` 는 새 입력이 아니라 **기존 `consume` 자리에 얹히는 조건**이다
- [ ] **축 값을 정규화한다.** `body.scale` 을 0..1 로, `severity` 를 0..3 으로, `creature.stage` 를 등급으로 바꾼다. **개수를 세는 것**과 **값을 바꾸는 것**은 다르다 (§13.6.2)
- [ ] **없는 축 값에 기본값을 만들어 넣는다.** `arrival` 에 `body` 키가 없으면 `limb_deficit = 0`, `hands_free = 2` 로 채워 넣지 않는다. **없음은 그대로 없음**이다 (§13.6.1, §6.7)
- [ ] **다른 Kit의 모듈을 직접 참조한다.** `sideview_ecosystem` / `physics_puzzle_platformer` 의 노드·리소스·씬·스크립트를 찾거나 `preload` 한다. 축 뷰는 오직 `ModuleContext.arrival` 이다 (§13.6.1)
- [ ] **스토어에 직접 쓴다.** `core/worldstate` 노드를 찾거나 `save_state()` 에 축을 끼워 넣는다. 쓰기는 `request_mutation(axis, patch)` 뿐이고, 그 밖의 경로를 만들지 않는다 (§6.7, §13.6.5)
- [ ] **플레이어가 이미 알아낸 사실을 `body`·`creature`·`place` 어느 축에도 넣는다.** 플레이어 지식은 **어떤 축도 아니다**(설계 §4). `facts`(`FactLedger`)는 이 Kit 안에만 산다. 죽음도 앵커도 체크포인트도 그 사실을 지우지 못한다 (§15 `test_descent_exploration_worldstate.gd` 지식 유지)
- [ ] **숫자 하나만으로 결말을 열게 만든다.** 세 결말의 근거는 각각 `always` / `fact` / `tag_available` 이다. `clearance` 를 `ending` route 에 쓰지 않는다
- [ ] **물자를 버리려고 §8 상수를 바꾼다.** `TIDE_MAIN_FLOW -62` 와 `SINK_TERMINAL_BASE 30 + SINK_PER_MASS 14` 의 관계( mass 2 = 58 < 62, mass 3 = 72 > 62 )는 §14.3 전체의 근거다. 바꾸면 Reference Game이 성립하지 않는다
- [ ] **체크포인트를 전 층 자동 배치로 만든다.** 앵커는 authored다
- [ ] **사망 시 앵커가 아니라 층 시작점으로 되돌린다.** 앵커가 무의미해진다
- [ ] **세이브 payload에 `Vector2` / `Node` / `Resource`를 넣는다**
- [ ] **전환 중에 저장한다.** 저장 경계는 앵커뿐이다
- [ ] **`run_id`나 층 `display_name`을 화면에 그린다**
- [ ] **레퍼런스 미확인 항목을 보고 "원작은 이렇다"고 적는다.** `SWALLOW_THE_SEA_RESEARCH.md` §10 의 N1~N16은 미확인이다
- [ ] **점프스커어를 넣는다** (깜빡임, 급사 사운드, sudden loud noise)
- [ ] **원작 이름(`Orro`, `Borrus`, `Vobble`, `Ouroboros` 등)을 코드·데이터·문서에 쓴다**
- [ ] **자동 테스트 통과만으로 Kit 완료를 선언한다.** §18을 통과하기 전에는 "검토 준비 완료"가 최대다
- [ ] **`app/app_root.gd` / `project.godot` / `core/**` / `addons/**` 를 수정한다.** 요청만 한다 (§19 OQ-9)
- [ ] **Kit 전용 에디터 툴을 만든다**

---

## 18. 완료 증거

구현 완료 보고에 아래를 **모두** 첨부/기록한다. 하나라도 비면 "완료"가 아니다.

- [ ] **Primary Reference 상태별 비교** — `SWALLOW_THE_SEA_RESEARCH.md` §2 표의 10개 상태 각각에 대해, TIN이 무엇을 따랐는지/왜 안 따라갔는지 한 줄씩. 미확인 상태는 "미확인 유지 + TIN 자체 결정 + 수치"로 적는다
- [ ] **10분+ 실측 Reference Game** — §14.3 세 루트 각각의 실측 시간. 최소 하나는 10분 이상. 어느 루트인지 명시
- [ ] **authored content 추가가 core 무수정** — `stratum_extra_probe.json` 추가 전후 `git diff --stat` 가 `core/` `systems/` `domain/` `presentation/` **0줄**임을 캡처
- [ ] **720p/FHD/QHD 캡처 3장** — §16.1 경로
- [ ] **자동 테스트 결과** — §15.3 의 7개 `gut_*` exit code 전부
- [ ] **이미지 0개** — §15.4 `binary_assets=0`
- [ ] **save/load/retry 검수** — 앵커 저장 → 앱 종료 → 재실행 → `load_state` 로 앵커 층·위치·물질이 복원되는 것을 기록. `downed` 후 앵커 복귀 + `facts` 유지 기록
- [ ] **몸통 인계 검수 (§13.6)** — `d = 0 / 1 / 2 / 4` 와 `hands_free = 2 / 0` 를 각각 `arrival["worldstate"]` 에 주입해 부력 표(§13.6.2)의 5개 수치가 **실측으로 재현됨**을 기록. `hands_free = 0` 에서 `ending.swallow` 이 닫히고 `ending.hollow` 가 열려 있음을 기록. `request_mutation` 이 거부되었을 때 `push_warning` 1회 + 상태 무변경 + 프레임 계속을 기록
- [ ] **축 격리 증명 (§13.6.1)** — `grep -rn "worldstate\|/root\|get_nodes_in_group" modules/descent_exploration/` 결과에 스토어 접근 0건, 다른 `modules/*` 참조 0건임을 캡처
- [ ] **상시 Shell HUD 없음** — 캡처 3장에 HUD 요소 0
- [ ] **Input Bubble** — 전환 시 4칸이 `rising → intact`, 실제 키 입력 시 `popped` 되는 영상 또는 스크린샷
- [ ] **Audio 이벤트 13종 발동 로그** — 각 이벤트가 한 번 이상 실제로 재생되었음을 기록
- [ ] **placeholder/HUD/설명문 검색 결과** — `grep -rn "ColorRect\|Label" modules/descent_exploration/presentation/` 결과가 주석/테스트 외 0건, `grep -rn "draw_string" modules/descent_exploration/` 결과가 `presentation/transition_veil.gd` 1건과 `presentation/descent_view.gd` 1건(결말 화면 이름 1줄) **합계 2건뿐**
- [ ] **화이트리스트 대조 (§10.9)** — 화면 문자열이 `정지` `귀환` `삼키다` `하강` 4값뿐임을 캡처. `test_no_player_text_outside_whitelist` 로그 첨부
- [ ] **되채움 장치 0건 (§10.10)** — 도감·저널·해설 NPC·엔딩 요약 0건. `test_no_refilling_lore_device` 로그 첨부
- [ ] **사용자 플레이 검토 준비 완료** — 그 전에는 "완성"이라 쓰지 않는다

---

## 19. Open Questions — 구현은 여기서 멈춘다

각 항목은 **추천안이 있다.** 추천안이 승인되면 그대로 구현하고, 거부되면 W0가 다른 값을 plan에 기록한다. **판단이 없으면 구현하지 않는다. 임의로 정하지 않는다.** (`docs/research/rain_world/GRILLING_STATE.md` §2.1-9)

| ID | 질문 | 추천안 | 닫히기 전까지 멈추는 것 |
|---|---|---|---|
| **OQ-1** | 레퍼런스의 카메라 프레이밍·팔레트·성장 스프라이트 규칙이 미확인이다. `SWALLOW_THE_SEA_RESEARCH.md` §12의 Steam 스크린샷 5장과 트레일러를 **사람이** 열어 본 뒤 §10의 수치를 확정할 것인가, §10 수치를 TIN 자의로 확정할 것인가 | **사용자가 스크린샷 5장을 직접 보고 §10.1~§10.7을 확정해 준다.** 자의 확정 금지 (`AGENTS.md` Primary Reference 규칙) | `presentation/` 전체 |
| **OQ-2** | `ending.return`(귀환)이 `fact:vent_above` 만으로 열리면 "물리 운반" 결말처럼 보인다. 질량 조건을 추가할까 | **추가하지 않는다.** `blocks_tag` + `return_flow` 로 이미 물리적 제약이 있다. 숫자를 넣으면 카운터 게이트 smell이 난다 | `ending` 판정 |
| **OQ-3** | Input Bubble를 **누가 그리는가.** `modules/first_entry` 의 presentation이 이 Kit의 캔버스를 그려야 하는데, 그 Kit은 `descent_exploration`를 모르는 모듈이다 | **W0가 전환층에 공통 버블 presentation을 두고, `first_entry`와 이 Kit은 `input_profile` payload만 주고 받는다.** 이 Kit은 `requested(&"input_profile", ...)` 포워드와 상태 저장만 한다. 버블 노드를 이 Kit 안에 만들지 않는다 | `module.gd`의 `set_key_profile` 연결 |
| **OQ-4** | `region_hollow` / `loc.*` / `thing.*` ID가 W1의 `docs/world/**` 문서와 같은 문자열로 맞는지 | **W1에게 9개 ID 목록을 전달하고 매핑표를 받는다.** 불일치하면 이 Kit의 ID를 바꾼다(저장 스키마 1이므로 마이그레이션 필요) | 최종 완료 선언. 구현은 ID가 있는 상태로 진행 가능 |
| **OQ-5** | 층 수를 6개로 확정할 것인가. 7~8개로 늘리면 10분 초과, 5개면 10분 미달 위험 | **6개 확정.** 5개면 실측 후 층 1개 추가, 7개면 §14.2 상한(150초/층)을 지키며 재측정 | §14.2 실측 |
| **OQ-6** | 오디오 `.wav` 13개가 아직 없다. `AudioManifest.validate()`가 `ResourceLoader.exists()`를 요구하므로 `gut_audio`가 실패한다 | **W3가 §11 표대로 13개를 렌더할 때까지 `gut_audio` 실패를 허용하고, 나머지 5개 `gut_*`를 완료 증거로 쓴다.** Kit 완료에는 `gut_audio` 0이 필수 | Kit 완료 선언 |
| **OQ-7** | `persist_checkpoint` 훅을 `ModuleContext.arrival`로만 받는 것이 충분한가. W0가 안 넘기면 앵커 저장이 영영 안 된다 | **W0 요청.** `arrival`에 `persist_checkpoint: Callable` 를 넣는다. 안 넣으면 앵커는 메모리 체크포인트로만 동작하고 재실행 시 소실 — 그 상태를 명시하고 기록한다 | §13.1 저장 3곳 |
| **OQ-8** | 6개 층이 3개 Kit 중 **유일하게** 수직 스크롤이다. Kit A(사이드뷰)와 시점 충돌 여부 | **충돌 없음으로 판단.** 앱 전환은 ModuleDirector가 하고 각 모듈이 자기 카메라를 가진다. 시점 연속성은 TIN의 게임 구간 전환에서 별개 문제 | 전환 연출 §4.9 |
| **OQ-9** | W0 소유 파일 변경 요청 4건 | (1) `app/app_root.gd`: `NORMAL_IDS`에 `descent_exploration` 추가 → §12.1의 4개 action이 자동 등록됨. **선택:** 물리 키를 `W`/`S` 로 바꾸려면 같은 함수의 `bindings` 딕셔너리에 `descent_exploration_up: [KEY_W, KEY_UP]`, `descent_exploration_down: [KEY_S, KEY_DOWN]` 두 줄 추가. **기본값은 화살표 `↑ ↓` 로 확정**하고 이건 하지 않는다. (2) `arrival`에 `persist_checkpoint` Callable 주입. (3) `app_root` 전환 흐름에서 이 Kit에 `input_profile` payload 전달. (4) `persist_checkpoint` 가 없을 때의 fallback 문서화(§13.2) | Kit 완전 등록 |

### 19.1 멈춤 규칙 (구체적)

1. 위 표의 "멈추는 것" 칸에 해당하는 파일을 **쓰기 전에** OQ 상태를 확인한다.
2. OQ가 열려 있고 추천안이 승인되지 않았으면, 그 파일을 만들지 않는다. placeholders로 채우지 않는다. TODO 주석을 남기지 않는다 (`AGENTS.md`: 요청 없는 코드 주석 금지).
3. OQ가 닫히면 **plan을 먼저 고친다** (§19 표의 추천안을 정본으로 옮기고 해당 §의 수치를 갱신한다). 그 다음 구현한다.
4. 도중에 §8 상수나 §9 스키마를 바꾸고 싶어지면 **바꾸지 말고** W0에 요청한다. 변경은 plan diff로만 한다.

---



