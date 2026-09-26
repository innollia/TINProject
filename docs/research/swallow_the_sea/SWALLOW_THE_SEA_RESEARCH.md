# Swallow the Sea — 레퍼런스 조사 (2026-09-26)

조사자: W6 (Kit C `descent_exploration` 담당)
조사 대상: **Swallow the Sea** (2020-04 itch.io 최초 공개 / 2021-09-03 Steam 출시)
문서 상태: **부분 확인**. 텍스트로 확인 가능한 사실은 확인했고, 화면에서만 보이는 것은 미확인으로 남긴다.

## 0. 조사 방법과 그 한계

- 도구: `fetch` 전용. 브라우저/Playwright는 이 환경에서 공유 브라우저 잠금 deadlock이 발생하므로 **한 번도 쓰지 않았다.**
- 검색: `https://lite.duckduckgo.com/lite/?q=...`
- 원문 페이지 직접 페치에 실패한 곳:
  - `gamicus.fandom.com/wiki/Swallow_The_Sea` — robots.txt 403
  - `tvtropes.org/pmwiki/pmwiki.php/VideoGame/SwallowTheSea` — robots.txt 403
  - `mobygames.com/game/171602/swallow-the-sea/` — robots.txt 403
  - `swallow-the-sea.en.softonic.com` — 봇 차단(.Client Challenge) 본문 미열람
  - `gamejolt.com/games/swallow-the-sea/1030070` — 본문 미추출
- **시각 자료는 이 조사자가 볼 수 없다.** Steam 스크린샷 5장과 트레일러 1편의 URL은 [§12](#12-화면-증거-사람이-확인해야-하는-곳)에 그대로 적어 두었지만, 이미지 픽셀을 읽지 않았다. 따라서 팔레트 값, 카메라 프레이밍, UI 좌표, 메뉴 화면 구성은 전부 `미확인`이다.
- 이 문서의 `확인`은 "텍스트 출처에 그 문장이 있다"는 뜻이다. **플레이어의 체감은 아니다.**

### 표기 규칙

| 표기 | 뜻 |
|---|---|
| `개발자 진술` | 개발자/퍼블리셔가 직접 쓴 글(itch 코멘트, 데브로그, 스토어 문구) |
| `출처 기술` | 공식 문서·PRESS·Achievements·가이드가 기술한 내용 |
| `community` | 플레이어·팬 해석. 사실이 아니라 someone's reading |
| `추론` | 출처에서 직접 나오지 않고 나거나 다른 출처를 조합한 판단 |
| `미확인` | 확인하지 못함. **값을 지어내지 않는다** |

---

## 1. 개발 / 발매 / 플랫폼

| 항목 | 값 | 근거 | 종류 |
|---|---|---|---|
| 개발자 | Talia bob Mair, Nicolás Delgado | [U1] Steam appdetails `developers` | 출처 기술 |
| 발매자 | ItsTheTalia | [U1] `publishers` | 출처 기술 |
| itch 저자 표기 | ItsTheTalia, Kondorriano | [U3] itch 페이지 `Authors` | 출처 기술 |
| 개발사 별칭 | Maceo / ItsTheMaceo. 개발자는 스스로를 "Maceo (Game Designer / Game Artist)"로 서명한다 | [U3] itch 코멘트 서명, [U12] RPS 본문 "devs Maceo Bob Mair and Nicolás Delgado" | 개발자 진술 |
| Steam 출시일 | **2021-09-03** | [U1] `release_date.date = "Sep 3, 2021"`, [U6] 데브로그 제목 | 출처 기술 |
| itch 최초 공개 | **2020-04 경** | [U4] "1 Year Anniversary of Swallow the Sea" 게시일이 2021-04-24이고 본문이 "1 year ago we released the Swallow the Sea" | 추론(게시물 본문 미열람) |
| itch 최신 빌드 | v1_2 (v1_1 파일명이 목록에 남은 불일치 있음) | [U3] 다운로드 목록 `SwallowTheSea_v1_2_*.zip` / 본문 실행 안내는 `v1_1` | 출처 기술 |
| 플랫폼 | Windows, macOS, Linux (Steam) | [U1] `pc/mac/linux_requirements`, [U3] `Platforms` | 출처 기술 |
| macOS | itch 배포본 존재, macOS 10.11 최소 | [U3], [U1] `mac_requirements` | 출처 기술 |
| 모바일 | **출的计划 없음.** "Swallow the Sea is not currently planned to be ported to any other future platforms." | [U3] 개발자 코멘트 | 개발자 진술 |
| 가격 | Free (itch 이름값 지정, Steam Free To Play) | [U3] "Name your own price", [U1] `is_free: true` | 출처 기술 |
| 저장 용량 | 300 MB | [U1] 요구사항 | 출처 기술 |
| 언어 | English only | [U1] `supported_languages`, [U3] `Languages` | 출처 기술 |
| 부속 / DLC | `dlc: [1913180]` = 동일 팀의 후속작 **Brutal Orchestra** (턴제어 로그라이크) | [U1] `dlc`, [U6] 데브로그 본문 | 출처 기술 |
| 확장 콘텐츠 | **없음.** "Unfortunately there will not be any additional content added to Swallow the Sea." | [U6] 데브로그 코멘트 | 개발자 진술 |

### 엔진 — **확정됨**

| 항목 | 값 | 근거 | 종류 |
|---|---|---|---|
| 엔진 | **Unity** | [U3] itch `Made with: Unity, Aseprite`, [U3] 태그 `unity` | 출처 기술 |
| 아트 도구 | **Aseprite** | [U3] 동일 필드 | 출처 기술 |
| 자체 개발 여부 | **모두 자체 작성.** 같은 팀의 이전 게임도 자체 3D 엔진("Made with Our Own Engine"이 `Perfect Vermin` 쪽에 표기) | [U3] 다른 게임 페이지 요약은 이번 조사에서 미열람 | `미확인` |

`추론` — 게임 규모(2인, 텍스트 없는 8~15분)와 Unity 채택 조합은 "작은 규모의 자체 제작asset 파이프라인"을 전제한다. 하지만 이것은 추론이며 기획서의 근거로 쓰지 않는다.

---

## 2. 총 플레이 길이

| 값 | 근거 | 종류 |
|---|---|---|
| **8~15분** | [U1] Steam `about_the_game`: "Swallow the Sea is a 8-15 minute 2D survival exploration game" | 출처 기술(퍼블리셔 자체 문구) |
| **약 10분** | [U1] Steam 리뷰 인용(Alpha Beta Gamer): "Taking around 10 minutes to play through" | 출처 기술(리뷰 인용) |
| **4분 미만 = 스피드런 성취 조건** | [U8] Steam Achievements `Flashes Before Your Eyes — Complete Swallow the Sea in under four minutes` | 출처 기술 |
| itch "평균 세션" 약 30분 | [U3] `Average session: About a half-hour` | 출처 기술( itch 자동값, 플레이 길이와 다름) |
| 데모/게임 내부 타이머 | QoL 업데이트로 **토글 가능한 인게임 타이머** 추가 (스피드런용) | [U6] 개발자 진술 |

`추론` — Store가 공개한 8~15분은 실패 재시도 1회 포함 수치로 읽는 게 자연스럽다. 4분 스피드런 성취가 존재한다는 사실은 "숙련 루트는 4분, 일반 첫 통과는 그 2~3배"라는 분포를 함의한다.

**TINCHK_WORKFLOW 기준 10분+ Reference Game은 이 원작의 8~15분 구간 안에 들어온다. TIN은 10분 이상을 목표로 한다.**

---

## 3. 플레이 가능한 구간, 순서와 길이

아래 순서는 Steam Community 가이드(원저 YouGotHitByGunner)의 구간 제목 순서 그대로다. [U10][U11][U9]

| # | 구간 이름(가이드 표기) | 이 구간에서 규칙적으로 일어나는 것 | 길이 |
|---|---|---|---|
| 1 | **First Gate** | "Eat at least 1 worm and 9 orbs to open the next area. Dash in the gate on the right to break it." | `미확인` |
| 2 | **Second Gate** | "Eat at least 5 worms and 13 orbs to open the next area. Swim up and dash in the gate." | `미확인` |
| 3 | **The Monster** | "Eat at least 8 worms, 3 blue orbs, and 15 orbs to open the next area." 우측 문 뒤에 추격자가 대기 | `미확인` |
| 3.5 | **Gentle Kisses** | Orro에게 키스를 맞은 이벤트가 발생하는 지점(성취 `Gentle Kisses`) | `미확인` |
| 4 | **The Walls** | 부서뜨릴 수 있는 벽들을 대시로 모두 깨야 통과. "The next step seems to be random" | `미확인` |
| 5 | **The Womb** | 뼈(`bones`)를 하나씩 부수고 그 안을 먹는다. 마지막 뼈를 끝내면 다음 구역으로 갈 만큼 성장 | `미확인` |
| 6 | **Last Area – The Baby** | 왼쪽 위 게이트에 숨은 큰 구슬을 먹어야 종결 가능. 우측에 보라 문(purple gate) → 보라 아이를 먹으면 게임 종료 | `미확인` |

**구간 수 = 6** (`추론`, 위 표에서 "Gentle Kisses"를 별도 구간이 아닌 3→4 전환 중 이벤트로 센 결과).

길이 관련해서 확인 가능한 것은 **두 개의 타임스탬프뿐**이다. [U10][U11]
- 스피드런 **1:30** — The Monster 구간 벽 붙어 대기 테크닉이 나오는 지점
- 스피드런 **1:50** — The Walls 구간 통과 지점
- 4:00 — 클리어

`추론` — 이 두 지점 사이가 약 20초이고, 4분 클리어가 fastest run이라는 사실을 합치면 "구간 6개를 4~15분에 통과"이라는 범위가 나온다. **개별 구간의 분량 표는 만들지 않는다.**

### 3.1 descent / 수직 이동에 대해 — **원작에 "내려가기" 구조는 없다**

`출처 기술` — 방향성 요약:
- "You are a lowly egg cell on a journey through a swollen sea" ... "growing larger and stronger to **perhaps someday be born**." [U1][U3]
- RPS: "as you drift further into the caves", "the ever-narrowing passages" [U12]

`출처 기술` — 수직 이동이 존재한다는 증거:
- "**Swim up** and dash in the gate." (Second Gate) [U10]
- "move towards the **upper wall**, wait there" (The Monster) [U10]
- "Go **upwards**, you'll see a gate there." (Last Area) [U10]

**결론**: 원작은 2D 자유 수영(가로 지배적)이고, 목표는 바깥으로 **태어나는 것**이다. 하강(구덩이 쪽으로 계속 내려가는 것)이 원작의 진행 축이 아니다. Kit C가 `descent_exploration`이라는 이름으로 **하강을 축으로 삼는 것은 원작에 대한 의도적 이탈**이며, 기획서에서 이 이탈을 명시하고 정당화해야 한다. [Kit 계획 §1.2]

### 3.2 카메라 — `미확인`

`추론` — 가이드가 "upper wall", "right side", "left side"를 공간 표현으로만 쓰고, 스크린샷을 못 보므로 **프레이밍·줌·월드 경계가 카메라를 따라가는지 고정인지는 확정할 수 없다.** 이 Kit은 자체 결정한다. [Kit 계획 §8 상수표]

---

## 4. 시스템 (이름 붙은 것만)

### 4.1 이동 / 대시

| 시스템 | 확인된 내용 | 근거 | 종류 |
|---|---|---|---|
| 이동 | 마우스 좌클릭 **홀드**로 이동 | [U14] 검색 스니펫: "you hold your left mouse button to move" (원문 페이지 봇 차단) + [U3] itch `Inputs: Mouse` | `추론(부분)` |
| 대시 | 마우스 우클릭. "Use Right Click (dash)" | [U10][U11] 가이드 본문 | 출처 기술 |
| 대시 용도 1 | 이동 가속 (스피드런 루트의 핵심) | [U10] | 출처 기술 |
| 대시 용도 2 | **crumbly/brittle 벽 파괴** — "smash through certain crumbly walls" | [U14] 스니펫, [U10] "Dash in the gate, to break it" | 출처 기술 |
| 컨트롤러 | Steam **Full controller support**. QoL 업데이트가 컨트롤러/키보드 지원을 추가 | [U1] `controller_support: "full"`, [U6] | 출처 기술 |
| 키보드 | 존재. **정확한 키 배분은 `미확인`** | [U6] "Controller and keyboard support" | 출처 기술 |
| 플레이어 회전 | "Made the player's rotation slow down faster so I don't get dizzy" | [U5] 개발자 진술 | 개발자 진술 |
| 능력 해금 | **없음.** 리뷰어: "It would be nice if you unlocked a few abilities as you evolved, but even as it stands it's a lot of fun" | [U1] Steam 리뷰 인용 | 출처 기술(리뷰) |
| 리바인딩 | `미확인` | — | 미확인 |

### 4.2 자원 수집과 소비

| 시스템 | 확인된 내용 | 근거 | 종류 |
|---|---|---|---|
| 먹기 성장 | 작은 것을 먹어 커지고, 이전의 위협을 먹게 된다 | [U1] "eat and grow combat", [U12] "Start out small and nippy, eating away until you grow and can take on the big boys you used to fear" | 출처 기술 |
| 먹을 수 없는 것 | "The first one is roaming in this area, but **you're too small to eat it right now**." | [U10] | 출처 기술 |
| 먹으면 느려지는 것 | "Avoid the **blue worms**, they **considerably slow you down**." | [U10][U9] | 출처 기술 |
| 먹으면 커지는 것 | "Eating the big orb that hides there will make you big enough to end the game, and also enables you to eat everything in the area." | [U10] | 출처 기술 |
| 껍질을 깬 것을 먹기 | 뼈를 부수고 안의 것을 먹는다. "Go straight for the 'bones', smash each one, and eat whatever is inside of them." | [U10] | 출처 기술 |
| 먹으면 튀는 것(제거됨) | "**Removed the bounce that the Ubb does when you eat it.** It was fun but confusing for players." | [U5] 개발자 진술 | 개발자 진술 |
| 크기 게이트 | 먹기 게이트가 **개수 카운터**로 구현되어 있다: "Eat at least 1 worm and 9 orbs", "5 worms and 13 orbs", "8 worms, 3 blue orbs, and 15 orbs" | [U10][U11][U9] | 출처 기술 |
| 자산 종류(가이드가 부르는 이름) | `worm`(기본 먹이), `Vobble`(빨간 지렁이), `blue worm`(감속), `orb`, `blue orb`, `bones`, `big orb`, `purple baby`, `Orro`, `the monster` | [U10] | 출처 기술 |
| 자산 이름(평판) | `Ubb`, `Nooty`, `Orro`, `Gump Sucker` | [U12], [U5] | 출처 기술 |
| 개체 수 | Vobble 총 **11마리** (2구간 1 + 3구간 6 + 마지막 구간 5, 단 2구간 개체는 3구간으로 따라온다) | [U10], [U9] | 출처 기술 |
| 자원이 **다 소비되고 끝나면** | Womb 구간 "ignore all food from the surroundings, those don't help you at all" | [U10] | 출처 기술 |

**TIN에의 직접 영향**: 원작의 진행 게이트는 전부 "N개를 먹어라"라는 **누적 카운터**다. TIN은 카르마식 누적 게이트를 금지하므로(AGENTS.md) 이 부분은 **의도적으로 폐기**한다. 대신 크기/무게라는 물리량과 "무엇을 가지고 있는가"가 통과를 정하게 한다. [Kit 계획 §1.2, §4.3]

### 4.3 목표 변형 (런마다 달라지는가) — `미확인`

- 가이드가 "The next step seems to be random"이라 쓴 것은 **The Walls 구간에서 어느 벽을 먼저 깰지 플레이어 선택**을 가리킨 것으로 보인다. [U10]
- **레이아웃이 런마다 재생성되는지에 대한 출처가 없다.** "are the areas the same every playthrough" 류의 질문을 여러 검색으로 돌렸고 결정적인 답을 얻지 못했다. → `미확인`
- `추론` — 게임잼성 8~15분 아케이디비的结构이고 에셋 파이프라인이 자체 Aseprite라, 런마다 레이아웃을 절차 생성할 여력은 거의 없었을 가능성이 높다. **근거가 없으므로 TIN은 authored 고정으로 결정한다.** [Kit 계획 §4.2]

### 4.4 압력 / 저해 / 장애물 행동

| 요소 | 확인된 내용 | 근거 | 종류 |
|---|---|---|---|
| 추격자 `The Monster` / `Orro` | "Like Resident Evil 2's Mr X, he's a constant presence - unstoppable, unavoidable, a persistent thumping of bone against tooth tailing you through ever-narrowing passages." | [U12] | 출처 기술 |
| 추격자 첫 등장 | "Orro, a menacing deep-sea Nidhogg introduced at the unlikeliest moment. With a grin and a turn, he vanishes briefly, before making a truly menacing return." | [U12] | 출처 기술 |
| 문 뒤 대기 | "There's a monster behind the gate on the right. Prepare yourself." | [U10] | 출처 기술 |
| 속도 조절 트릭 | "DON'T run away, move towards the upper wall, wait there until the monster clears the way" — 즉 **추격자는 공간을 돌아다닌다** | [U10] | 출처 기술 |
| 죽음 판정 | "If the monster catches up to you and hits you **two times**, restart the game." | [U10] | 출처 기술 |
| 피격 넉백 | "Gave the **Gump Sucker** more muscles to increase the force it does when the player gets hit." | [U5] | 개발자 진술 |
| 마지막 구간의 추가 위협 | "a red orb with a blue worm coming out of his eye, and the monster" | [U10] | 출처 기술 |
| 소생 벽 | "**Increased the first nursery wall collision.** The wall breaks easier" / "**Removed the possibility of a premature evolution in the nursery.**" | [U5] | 개발자 진술 |
| 죽음 = 리스타트 | "restart the game" (위 두 번 피격 뒤) | [U10] | 출처 기술 |
| **압력/산소/타이머 죽음** | **없음.** 어떤 출처에도 카운트다운 압력 수치가 없다 | 전수 검색 | `미확인`(부재 확인) |

### 4.5 세 개의 결말

Steam Achievements 목록(공식 10개)이 결말 3개를 직접 증명한다. [U8]

| 결말 | 성취 이름 | 공식 설명 | 발동 조건(가이드) | 성취률 |
|---|---|---|---|---|
| A | **Ouroboros** | "Complete Swallow the Sea." | 마지막 구간 우측 **보라 문**에 대시해서 들어가 **보라 아이(purple baby)** 를 먹는다 | 76.1% |
| B | **Mercy** | "Consume the Orro." | Orro(큰 보라 지렁이)를 **최종 형태 그대로** 먹는다. 보라 아이보다 먼저. 단 Orro가 있는 벽은 대시로 부숴야 한다 | 66.7% |
| C | **Sororicide** | "Become an only child." | "Eat the monster." (영문 가이드) / 폴란드어 번역본은 "내 종의 모든 배아를 먹어라" | 66.9% |
| (추가) | Gentle Kisses | "Get kissed by the Orro." | Orro가 키스하는 연출 직후 그의 입으로 대시 | 11.4% |

`출처 충돌 — 미해결` — Sororicide의 정확한 트리거가 **두 출처에서 다르다.**
- 영어 가이드/공식 성취 설명: "Become an only child / **Eat the monster**" [U8][U10]
- 같은 가이드의 폴란드어 번역: "Zjedz wszystkie embriony swojego gatunku. Ten ostatni znajdziesz w tunelu w lewym dolnym rogu za ścianą do zniszczenia w ostatnim obszarze." (= "내 종의 배아를 모두 먹어라. 마지막 하나는 마지막 구역 왼쪽 아래 통로에 부서뜨릴 벽 뒤에 있다.") [U9]

**TIN은 어느 쪽도 따르지 않는다.** TIN의 결말 3개는 성취 이름·조건·연출을 복제하지 않고, 세 개의 **다른 종류의 근거**(아무것도 필요 없음 / 지식 / 물질)로 만든다. [Kit 계획 §4.7]

`community` (사실 아님): "Nature, raw and cruel, the one who adapts survive... THE MACHINE breaks the natural order" — 유저 해석. [U13] lore 정본으로 쓰지 않는다.

### 4.6 저장 / 체크포인트

| 항목 | 값 | 근거 | 종류 |
|---|---|---|---|
| 세이브 파일 | `LocalLow/Swallow the Sea/SaveGames` 등 | [U16] | **신뢰 불가** |
| 판정 | [U16]은 `games-manuals.com`의 **전 게임 공통 자동 생성 템플릿 페이지**다. Local/LocalLow/Roaming/Steam/Documents를 일괄 나열하는 상투 문장("All information is sourced from Steam")이며, 이 게임의 실제 세이브 파일이 존재한다는 증거가 아니다. **출처 목록에서 제외한다.** | 자체 판정 | — |
| 런 중간 체크포인트 | **확인된 출처 없음.** 가이드는 두 번 피격 시 "restart the game"을 권한다 | [U10] | `추론` |
| 체크포인트가 없다는 뜻인가 | 아니오. 부재를 증명한 것이 아니라 **출처가 없다** | — | `미확인` |
| 진행 기록 | Steam Achievements 10개가 런 간 메타 진행으로 남는다. Steam cloud/로컬 achievement stats | [U8] | 출처 기술 |

**TIN 결정**: 체크포인트는 **런 안의 authored 앵커**다. 원작이 없는지 있는지도 확정되지 않았으므로, TIN은 10분 Reference Game이 매번 0부터 시작하면 검증이 무의미해진다는 판단으로 앵커를 넣되, 앵커는 물리적 지점이고 UI 표시를 갖지 않는다. [Kit 계획 §4.6, §13]

### 4.7 실패 상태

| 항목 | 값 | 근거 | 종류 |
|---|---|---|---|
| HP 개념 | UI·수치 공개 없음. 두 번 피격 = death | [U10] | 출처 기술 |
| 데스처 | "Swallowed by the Sea — It happens to the best of us." / "You'll unlock this if you die at any point." | [U8] | 출처 기술 |
| 데스처 통계 | 성취 보유자 96.6% → 사실상 전원이 한 번 이상 죽는다 | [U8] | 출처 기술 |
| 사망률 0 클리어 | "All of My Organs — Complete Swallow the Sea without dying." 11.4% | [U8] | 출처 기술 |
| 무피격 클리어 | "Prime Cut — Complete Swallow the Sea without taking damage." 4.6% | [U8] | 출처 기술 |
| 사망 화면 구성 | `미확인` | — | 미확인 |
| 게임 오버 후 | 런 재시작(체크포인트 귀환 아님, 가이드 근거) | [U10] | `추론` |

**TIN이 이death 규칙을 그대로 따르지 않는 이유**: 무피격/무사망 성취가 각각 11.4% / 4.6%이고 데스처가 96.6%다. 즉 원작은 **매번 0부터 다시 시작하는 것이 정상적인 루프**다. 10분 Reference Game을 사용자 플레이 검토용으로 만들 때 매번 0부터 다시 시작하면 검증 자체가 느려진다. TIN은 **체크포인트 귀환 + 지식 영구 유지**로 바꾼다. [Kit 계획 §13]

---

## 5. 화면 상태

`docs/KIT_WORKFLOW.md` §2가 요구하는 상태 목록으로 정렬한다. **텍스트로 확인되는 것과 화면에서만 보이는 것을 분리했다.**

| 상태 | 확인된 것 | TIN이 가져갈 것 | 판정 |
|---|---|---|---|
| opening / 첫 플레이 화면 | 존재/구성 `미확인`. 스크린샷을 볼 수 없음 | 없음 (TIN은 별도 타이틀 화면을 두지 않는다) | 미확인 |
| normal play | 무압착 플레이. Store·리뷰 어디에도 HUD 설명이 없음. QoL의 타이머가 **"toggleable"** 이므로 기본은 꺼짐 | **상시 HUD 없음** | `추론(강함)` + 미확인 |
| focus / selection / 직접 조작 | **커서/선택 개념 없음.** 플레이어는 자신의 몸만 조작한다. "Ubb의 튐은 혼란을 줘서 제거했다" [U5]가 "간접 조작 피험"의 유일한 사례 | 마우스 커서 게임 금지 | `추론` + 미확인 |
| 핵심 시스템 변화 직후 | 성장 순간. "growing larger and stronger"; "but still, you eat away. Then, all of a sudden, **you are born**" [U1][U12] | 몸의 실루엣이 바뀌는 것만으로 표현 | `추론` |
| unavailable / failure | 피격 → 사망 → 런 재시작 [U10] | 실패는 앵커로 귀환 | `추론` |
| success / completion | 결말 3종 [U8] | 결말 3종(단 조건은 전부 교체) | 출처 기술(결말 개수만) |
| menu | **pause menu 존재.** QoL 업데이트가 "An **improved pause menu**" 를 추가 | Esc 메뉴는 Shell이 소유. Kit은 아무것도 띄우지 않는다 | 출처 기술(존재) / 미확인(구성) |
| 레벨/장면 전환 | 6개 구간과 문(gate). 문은 대시로 부순다 [U10] | 층 전환. 화면 문법은 TIN이 정한다 | 출처 기술(존재) / 미확인(연출) |
| 게임 내 타이머 | 토글 가능, 기본값 `미확인` | **만들지 않는다** | 출처 기술 |

### 5.1 화면에서 반드시 확인해야 하는데 확인 못 한 것 — 구현 착수 금지 항목

이 항목들은 `미확인`이며, Kit 계획이 **어떤 것을 따르고 어떤 것을 버리는지**를 §1.2에 명시했다. 화면 구현 전에 사람이 스크린샷/영상을 봐야 한다. [Kit 계획 §19 OQ-1]

1. 카메라가 고정인가 추적인가, 플레이어 기준 화면 비율은 얼마인가
2. 팔레트 값(배경/전경/플레이어/위험색)
3. 성장할 때 스프라이트가 언제 어떻게 바뀌는가 (프레임 아트가 여러 장인가)
4. 메뉴 화면 구성과 포커스 표시 방식
5. 사망 화면 구성
6. 구간 전환 연출의 길이와 방식

---

## 6. 입력 (정확한 것만)

| 사실 | 근거 | 종류 |
|---|---|---|
| itch 메타데이터 `Inputs: Mouse` | [U3] | 출처 기술 |
| Steam `Full controller support` | [U1] | 출처 技术 |
| QoL가 "Controller **and keyboard** support" 추가 | [U6] | 개발자 진술 |
| 이동 = 좌클릭 홀드, 대시 = 우클릭 | [U14] 검색 스니펫만(원문 봇 차단) | `추론(부분)` |
| 대시 = 우클릭 | [U10][U11][U9] 3개 출처 일치 | 출처 기술 |
| **물리 키 배분 전체** | `미확인` | 미확인 |
| 리바인딩 UI 존재 여부 | `미확인` | 미확인 |

**TIN 결정**: 원작의 마우스 2버튼은 그대로 따라가지 않는다. TIN은 키보드 4키(W/S/Z/X)로 닫는다. 이유는 (a) Input Bubble은 **물리 키**를 세는 계약이고 마우스 버튼은 격자 칸에 앉힐 수 없다. [Kit 계획 §12]

---

## 7. 아트 기술 / 팔레트 / 오디오

### 7.1 아트

| 항목 | 값 | 근거 | 종류 |
|---|---|---|---|
| 매체 | 2D 픽셀 아트 | [U3] 태그 `Pixel Art`, [U1] 리뷰 "the pixel art animation is superb" | 출처 기술 |
| 제작 도구 | Aseprite | [U3] `Made with` | 출처 기술 |
| 엔진 내 렌더 | Unity (2D) | [U3] | 출처 기술 |
| 애니메이션 | 스프라이트 기반 프레임 애니메이션. 리뷰가 "pixel art animation"을 호평 | [U1] | `추론(강함)` |
| 절차적/생성 비주얼 | **사용하지 않음** (자체 수제 애셋) | [U3] `Made with Aseprite` | `추론(강함)` |
| 팔레트 값 | `미확인` — 이미지 미열람 | — | 미확인 |
| 진행에 따른 색 변화 | 텍스트로만: "the passages **tinge red with rotten flotsam and foul vents**" (깊이 들어갈수록 부패가 심해진다) | [U12] | 출처 기술(정성) |
| 분위기 전환 | "It ain't all bad under the sea" → "the world is dying" | [U12] | 출처 기술(정성) |
| 원작 고유 요소 | 보라 아이, Orro, Ubb, Nooty, Gump Sucker, Vobble 이름, 밴드camp OST | [U8][U12][U5] | — |

### 7.2 오디오

| 항목 | 값 | 근거 | 종류 |
|---|---|---|---|
| 사운드 디자인 | Pato Flores, Chris Dang | [U1][U3] | 출처 기술 |
| 작곡 | Publio Delgado | [U1][U3] | 출처 기술 |
| OST 배포 | Bandcamp + YouTube | [U3] "Swallow The Sea OST" | 출처 기술 |
| 오디오 언어 | "Interface: **Full audio**" (폴란드어 번역본 메타데이터) | [U9] | 출처 기술 |
| 사운드 디자인 철학 | `미확인` | — | 미확인 |
| 개별 효과음 목록 | `미확인` | — | 미확인 |
| music bus 구조 | `미확인` | — | 미확인 |

**TIN 결정**: TIN은 이 라운드에서 오디오를 nkido로 **사전에 생성**한다(ROUND_PLAN C2). 원작의 사운드 디자인을 따라가는 대신, 위에서 확인된 정성 정보("공포는 점프스케어 없이 압박감으로 온다")를 **이벤트 설계 원칙**으로만 가져간다. [Kit 계획 §11]

### 7.3 개발자가 직접 말한 공포 규칙 (개발자 진술 — 그대로 따라간다)

> "Swallow the Sea contains **no jump scares**. Swallow the Sea's 'horror' elements come from the games **oppressive atmosphere and dark themes**."
> — ItsTheTalia, itch 코멘트, 서명 "Maceo (Game Designer/ Game Art)" [U3]

**TIN 금지 조항으로 승격**: 이 Kit에는 점프스케어·급사 이벤트·깜빡임 현기를 넣지 않는다.

---

## 8. Authored content 단위

`추론` — 원작의 authored 단위는 **구간(area) 하나 + 그 안의 먹이 배치**로 보인다. 근거:
- 6개 구간에 이름이 붙어 있고 이름이 성취/가이드 헤딩과 일치한다. [U10]
- 자리의 개별 배치가 튜토리얼 변경 로그에서 언급된다("the **first nursery** wall"). [U5]
- 런마다 절차 생성된다는 출처가 없다. [§4.3]

**TIN authored 단위 = 하강 구간(stratum) 하나.** 구간 JSON 1개 추가 = 신규 공간 1개. [Kit 계획 §9]

---

## 9. 개발 과정

| 사실 | 근거 | 종류 |
|---|---|---|
| 2인 개발. Talia(Maceo) + Nicolás(Kondorriano / "Nico") | [U1][U3] | 출처 기술 |
| 역할 | Maceo: "Game Designer / Game Artist" 자기 서명 [U3]. Nico는 버그 수정·플레이어 회전·리눅스 빌드를 직접 기술 [U5][U4] | 개발자 진술 |
| 기술 스택 | Unity + Aseprite [U3] | 출처 기술 |
| 오디오 외주 | 사운드 디자인 2인 + 작곡 1인 **외부** [U1] | 출처 기술 |
| 최초 공개 → Steam | 2020-04경 itch 공개 → 2021-09-03 Steam. 17개월 [U4][U1] | 추론 |
| itch 무료 공개 | 이름값 지정 [U3] | 출처 기술 |
| 반복 공개 | 2020-05 리눅스, 2020-05 사운드트랙+수정, 2021-07 QoL(컨트롤러/키보드, 개선된 일시정지 메뉴, 타이머, 10개 성취), 2021-09 Steam [U4][U5][U6] | 출처 기술 |
| 팀의 다른 작품 | Perfect Vermin(자체 3D), Brutal Orchestra(턴제어 로그라이크) [U6] | 출처 기술 |
| 프로젝트 관리 방식, 일정, 인건비 | `미확인` | 미확인 |
| 엔진 커스텀 도구 | `미확인` | 미확인 |

`추론` — 캐주얼 브라우저 다운로드가 유료 전환 장치였고( itch 이름값 지정 ), SteamQoL 업데이트에서 컨트롤러·일시정지 메뉴를 "기능"으로 팔았다. 즉 **콘텐츠 추가가 아니라 접근성/편리성으로 유저를 늘린 구조**다. 이것이 TIN의 10분 분량 전략과 정확히 같은 방향이다. [Kit 계획 §14]

---

## 10. NOT VERIFIED — 구현에 쓰면 안 되는 목록

아래는 전부 `미확인`이다. **기획서도 이 목록에 의존해서는 안 된다.**

| # | 미확인 항목 | 왜 미확인인지 | TIN 처리 |
|---|---|---|---|
| N1 | 세그먼트별 길이(초) | 가이드에 타임스탬프 2개(1:30, 1:50)만 있음 | TIN 자체 수치를 정한다 |
| N2 | 카메라 고정/추적, 화면 프레이밍, 줌 | 스크린샷 미열람 | TIN 자체 결정 |
| N3 | 팔레트 값, 명암 구조, 스프라이트 규격 | 이미지 미열람 | TIN `core/procedural` 파레토 값 사용 |
| N4 | 성장 단계 수, 성장 시 스프라이트 교체 규칙 | 이미지 미열람 + "크기"는 서술로만 존재 | TIN은 **지속 연속 물리량(질량)** 으로 대체 |
| N5 | 물리 키 전체 배분, 리바인딩 | 키보드 지원 진술만 있음 | TIN 4키 확정 |
| N6 | 런마다 레이아웃/목표가 바뀌는가 | 결정적 출처 없음 | TIN은 authored 고정 |
| N7 | 체크포인트 존재 여부, 세이브 스키마 | 유효한 출처 없음 | TIN 자체 앵커 모델 |
| N8 | 사망 화면 / 게임 오버 화면 구성 | 이미지 미열람 | TIN 자체 정의 |
| N9 | opening 화면 구성 | 이미지 미열람 | TIN은 타이틀 화면을 두지 않는다 |
| N10 | pause menu 항목 구성 | "improved pause menu" 진술만 있음 | TIN은 Shell Esc 메뉴 사용 |
| N11 | 개별 효과음 목록, 사운드 디자인 원칙 | 미기록 | TIN nkido 생성 |
| N12 | 전환 연출 | 이미지·영상 미열람 | TIN 자체 정의 |
| N13 | 정확 조작(어떤 먹이를 언제 먹어야 배가 차는지) | 이미 먹으면 통과한다는 것 외 수치 없음 | TIN은 카운터 폐기 |
| N14 | 파티클/포스트 이펙트 | 미기록 | TIN은 배경 physics 위주 |
| N15 | 원작의 실패-중간 상태 복구 | 미기록 | TIN 자체 정의 |
| N16 | 이 팀의 게임 개발 도구/에디터 | 미기록 | TIN은 전용 에디터 금지 |

### 10.1 출처 충돌 2건 (해결하지 않고 기록만)

1. **Sororicide 조건**: 영어 "Eat the monster" [U8][U10] vs 폴란드어 "내 종의 배아 전부" [U9]. → TIN은 **둘 다 따르지 않는다.**
2. **itch 저자/빌드 표기**: `Authors: ItsTheTalia, Kondorriano` [U3] vs 다운로드 `v1_2` vs 실행 안내 `v1_1`. → 버전 표기에 의존하지 않는다.

---

## 11. TIN이 실제로 가져가는 것 / 버리는 것 (요약)

**가져간다**
- 먹고 커져서 이전의 위협을 먹는 **물리적 성장** [U12]
- 무게/크기가 이동을 바꾼다 [U10]
- 소모성 자원이 있어서 "이걸 지금 쓸까"가 매 순간 성립 [U10]
- 구간이 바뀔수록 세계가 더 나빠지는 **환경escalation** [U12]
- 하나는 항상 뒤따르는 **추격자** [U12]
- **결말 3개** [U8]
- 대시가 **부서지는 벽**을 깬다 [U10][U14]
- **점프스케어 금지** [U3]
- 무료/짧은 배포를 전제로 한 **10분 클리어** 계약 [U1][U3]

**버린다**
- "N개를 먹어라" 누적 카운터 게이트 [U10] → TIN은 **금지**. 통과는 물리량과 지식으로
- Orro/Mr X식 **추격자 1인 고정 패턴** [U12] → TIN은 층마다 다른 저해 규칙
- 보라 아이 / Orro / Vobble / Ubb / Nooty / Gump Sucker 등 **고유 존재** [U8][U12][U5]
- 마우스 2버튼 조작 [U14] → TIN은 키보드 4키 (Input Bubble 계약)
- 4분 스피드런 성취 [U8] → TIN은 시간 압박을 성취 조건으로 쓰지 않는다 (10분을 대기/반복으로 채우지 말라는 사용자 제약)

---

## 12. 화면 증거 — 사람이 확인해야 하는 곳

아래 URL은 조사가 확인한 **공식 스크린샷·트레일러 경로**다. 이 조사자는 이미지 픽셀을 읽지 못했다. [U1]

| # | 용도 | URL |
|---|---|---|
| S1 | 스크린샷 1 (1920x1080) | `https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1511860/ss_f3569f655de8bfcc82bb4990eff76602863661b0.1920x1080.jpg` |
| S2 | 스크린샷 2 | `https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1511860/ss_4a996d30c03d3807141dff917b17d352023807aa.1920x1080.jpg` |
| S3 | 스크린샷 3 | `https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1511860/ss_2bac3259f01ee641c8b0a5b9f260e2499afdf463.1920x1080.jpg` |
| S4 | 스크린샷 4 | `https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1511860/ss_75e4d3adf20d4a98819bf60b244c14d7fd3df3be.1920x1080.jpg` |
| S5 | 스크린샷 5 | `https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1511860/ss_9b09d619c067573142a24cb8e6227ebf61b487e6.1920x1080.jpg` |
| M1 | 트레일러 "Take a Short Surreal Swim" (movie id `256841158`) | Steam `appdetails` 의 `movies[0]` |
| M2 | RPS가 실은 릴리스 트레일러 임베드 | [U12] |

**가이드를 다시 쓰지 않는다.** 이 Kit의 스크린샷은 위 5장에서 나열한 미확인 항목(N2·N3·N4·N8·N9·N10·N12)을 채우는 유일한 경로이며, [Kit 계획 §19 OQ-1]이 화면 구현의 차단 조건으로 두고 있다.

---

## SOURCES

| ID | URL | 읽은 범위 | 상태 |
|---|---|---|---|
| U1 | `https://store.steampowered.com/api/appdetails?appids=1511860&l=english&cc=us` | 개발자/퍼블리셔/장르/출시일/스크린샷 목록/콘텐츠 디스크립터/약한 요구사항/리뷰 인용 | 전문 페치 성공 |
| U2 | `https://store.steampowered.com/app/1511860/Swallow_the_Sea/` | 스토어 전면 | 시도, 앱 오염(다른 앱 페이지가 반환) → U1로 대체 |
| U3 | `https://itsthemaceo.itch.io/swallow-the-sea` | 게임 메타데이터, `Made with`, 다운로드 목록, 개발자 코멘트 다수, "평균 세션", `Inputs: Mouse` | 전문 페치 성공 |
| U4 | `https://itsthemaceo.itch.io/swallow-the-sea/devlog` | 데브로그 목록과 요약 문구 | 목록만 페치 성공 |
| U5 | `https://itsthemaceo.itch.io/swallow-the-sea/devlog/144678/minor-update-and-soundtrack` | Nicolás의 2020-05-08 변경 목록 | 전문 페치 성공 |
| U6 | `https://itsthemaceo.itch.io/swallow-the-sea/devlog/273848/swallow-the-sea-qol-update-and-steam-release-sept-3rd` | QoL 항목 4개, Steam 성취 10개, "추가 콘텐츠 없음" 코멘트 | 전문 페치 성공 |
| U7 | `https://itsthemaceo.itch.io/swallow-the-sea/devlog` (2021-04-24 항목) | 1년 기념 | **목록 요약만 확인. 게시물 본문 미열람** |
| U8 | `https://steamcommunity.com/stats/1511860/achievements` | 공식 성취 10개 이름·설명·글로벌 성취률 | 페치 성공 (본문 텍스트 확인) |
| U9 | `https://steamcommunity.com/sharedfiles/filedetails/?id=2856765649` | 가이드 색인 + 폴란드어 번역 전문(Sororicide·Mercy·Uroboros 서술) | 페치 성공 |
| U10 | `https://steamah.com/swallow-the-sea-100-walkthrough-achievement-guide/` | YouGotHitByGunner 원문 가이드 영어 전문 (구간·게이트 수치·대시·추격자·결말) | 페치 성공 |
| U11 | `https://gamepretty.com/swallow-the-sea-walkthrough-achievement-guide/` | U10과 동일한 원문 가이드의 미러. 교차 확인용 | 페치 성공 |
| U12 | `https://www.rockpapershotgun.com/swallow-the-sea-is-a-short-free-tale-of-birth-hunger-and-gnawing-teeth` | Natalie Clayton, 2020-05-03. Agar.io 비유, Ubb/Nooty/Orro, Mr X 비유, 부패 색 변화 | 페치 성공 |
| U13 | `https://steamcommunity.com/app/1511860/discussions/0/3274689286951136264/` | 유저의 엔딩 해석 | 페치 성공. **`community` — 사실 아님** |
| U14 | `https://lite.duckduckgo.com/lite/?q=%22Swallow+the+Sea%22+controls+mouse+click+gameplay` 에서 softonic 발췌문 | "hold your left mouse button to move and then click your right mouse button to dash" | **검색 스니펫만.** 원문 `swallow-the-sea.en.softonic.com` 은 봇 차단으로 본문 미열람 |
| U15 | `https://lite.duckduckgo.com/lite/?q=Swallow+the+Sea+game` 에서 Codex Gamicus 발췌문 | "freeware action-adventure", "Maceo bob Mair", "around 10..." | **검색 스니펫만.** 원문은 robots.txt 403 |
| U16 | `https://www.games-manuals.com/save-game-location-backup-installation/swallow-the-sea-1511860` | 세이브 경로 purportedly | **신뢰 불가 — 출처 목록에서 제외.** 전 게임 공통 템플릿 |
| — | `https://gamicus.fandom.com/wiki/Swallow_The_Sea` | — | 접근 실패 (robots 403) |
| — | `https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/SwallowTheSea` | — | 접근 실패 (robots 403) |
| — | `https://www.mobygames.com/game/171602/swallow-the-sea/` | — | 접근 실패 (robots 403) |
| — | `https://gamejolt.com/games/swallow-the-sea/1030070` | — | 본문 미추출 |
