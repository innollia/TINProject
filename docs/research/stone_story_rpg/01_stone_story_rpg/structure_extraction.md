# Stone Story RPG — 구조 추출

원본: [../00_user_dumps/2026-09-26_01_wiki_and_screenshots.md](../00_user_dumps/2026-09-26_01_wiki_and_screenshots.md)

이 문서는 **참고된 사실**과 **TIN이 정한 결정**을 분리한다.
 사실 항목은 `사실`, TIN 결정은 `결정`, 아직 없는 것은 `미수집`으로 표기한다.

---

## 1. 렌더·비주얼 계약 (스크린샷 10장 기준)

### 1.1 사실 — 관찰된 것

- 순수 검정 배경. 채면 채운 면(filled area)이 **하나도 없다.** 전부 선(線)이다.
- 선은 전부 헤어라인(논리 1px). 곡선은 꺾인 선분(`/\`, `\_`, `(){}`)으로 표현한다.
- 색은 무채색이 원칙. 강조색은 극소량(초록 `1` 배지, 빨강 로고)뿐이고 화면 1~2개 소모.
- 텍스트는 **ASCII/기호가 아니라 실제 폰트로 렌더된 한·영 문자**다. (`풀레이`, `보물 상자`, `계속하기`)
- 게임플레이 HUD는 4개 모서리에 2~3글자씩만 있다: `○ 11`(ki), `_ 20`, `\/O/ 19/20`(hp), `0/3 거래한 모기`.
- HUD에 박스·프레임·배경이 없다. 전경선만.
- UI 패널은 얇은 1px 외곽선 + 내부 빈 공간. 좌측 라벨(`장소`/`작업실`/`아이템`)이 섹션을 연다.
- 커서는 흰 칩(■) 1개. 위치 표시가 아니라 **선택 위치 표시**로 쓰인다.
- 포커스 표시는 색이 아니라 **점선 테두리**(파선 사각형)로 한다.
- 보스 방은 단일 고정 카메라의 넓은 화면. 세로선 벽면 + 빈 바닥 + 하단 지면 텍스처 대역.
- 대사창은 화면 중앙~하단 横长 박스 + `<)` 계속 글리프.
- 씬 전환은 텍스트 라인(``능반에서 알반으로 옮겨다니는 중...``) + 오닉스 프레임으로 표시한다.
- 발견 컷신은 스킵 불가 모달 + 중앙 `계속하기` 버튼(박스).
- 상점/보물창/작업대는 우측 정렬 대형 패널. 좌측에 얇은 목록.
- 상점·보물창·인벤토리는 **오닉스 프레임(획선 사각형)** 을 장식 프레임으로 쓴다.

### 1.2 결정 — TIN 비주얼 방향

ASCII 문자 렌더링은 **금지**다. (`PROJECT_DECISIONS.md` §21)
대신 위의 시각 규칙(순수 검정, 1px 헤어라인, 무채색, 채움 없음, 커스텀 폰트 텍스트,
모서리 스파스 HUD, 점선 포커스, 흰 칩 커서)을 **절차적 드로잉으로 재현**한다.

목표는 "픽셀 아트처럼 보인다"가 아니라 **"픽셀 아트보다 더极少한 픽셀 단위 선화"** 다.
资产的 밀도를 낮춰서 얻는 빈 화면이 곧 이 Kit의 정체성이다.

### 1.3 미수집

- 보스 방 외 전투 방의 카메라 이동 규칙
- 지역 간 전환 연출 (-location 이동) 의 실제 화면
- 컷씬 스킵 불가 해제 조건
- 오닉스 프레임의 등장 조건과 종류

---

## 2. 시뮬레이션 단위 (사실)

### 2.1 거리 단위 = `foe.distance`

위키는 모든 사거리·도달·속도·넉백을 `foe.distance` 단위로 표기한다.

| 항목 | 값 예시 |
|---|---|
| Xyloalgia Ph1 Casting Range | 24 |
| Xyloalgia Ph1 Attack Reach | 24 |
| Xyloalgia Ph1 Knockback | 5 |
| Acronian Scout Casting Range / Reach | 11 / 11 |
| Acronian Scout Max Knockback | 10 |
| Bomb Cart Detonate Range / Reach | 4 / 4 |
| Acronian Scout Awakenings | `foe.distance 25`에서 기상 |
| Bomb Cart Awakenings | `foe.distance 24`에서 즉시 기상 |

→ **사거리 값은 픽셀이 아니다.** 월드 좌표는 별도의 내부 단위다.

### 2.2 시간 단위 = 프레임

모든 지속·타이밍이 `f` 단위다.

| 항목 | 값 |
|---|---|
| Xyloalgia Ph1 projec Lifetime | 23f |
| Xyloalgia Ph1 Stun Duration | 15f |
| Acronian Scout Awakenings | 60f |
| Acronian Scout Casting | 15f |
| Acronian Scout Performing | 6f |
| Acronian Scout Cooldown | 0f |
| Bomb Cart Explosion Delay | 5f |
| Experience Stone Attack Speed | 1.5s = 45f |
| Experience Stone Cast/Perf/Cooldown | 16 / 14 / 15 f |

### 2.3 보행 속도 → 시뮬레이션 주파수 (유도)

위키 표: Walkspeed `Time(f) 3`, `Movement/Sec 10` (Acronian Scout), Bomb Cart `Time(f) 15`, `Movement/Sec 2`.

```text
1 거리 단위 = 3 프레임  (Scout: 10 unit/s)
1 거리 단위 = 15 프레임 (Bomb Cart: 2 unit/s)
=> 프레임 레이트 = 10 × 3 = 30 fps  (검증: 2 × 15 = 30)
```

두 표가 독립적으로 30을 내므로 **시뮬레이션은 30Hz 고정 스텝**이라고 봐야 한다.
> 근거 수준: 유도. 사용자 확인 요청 대상.

### 2.4 결정 — TIN 시뮬레이션 계약

- 시뮬레이션: **고정 30Hz 정수 틱**. `randf()` 금지. 시드 기반 결정론.
- 렌더: 디스플레이 주파수에 무관. 시뮬 상태에서 현재 보간값으로 그린다.
- 월드 좌표: `distance` 정수 단위 내부 좌표. 렌더 시 내부 버퍼 픽셀로 매핑.
- 프레임 값(`cast_f`, `stun_f`, `lifetime_f`)은 **그대로 정수 프레임 수로 저장.** 초 변환 금지.

---

## 3. 스타 레벨 (사실) — 최상위 난이도 축

### 3.1 레벨 표기

`1*` `2*` `3*` `4*` `5*` `6*-10*` `11*-15*` `16*-20*`
색 구분: white < cyan < **yellow** < green (miniboss 배치 규칙에서 명명).

### 3.2 스타 레벨이 바꾸는 것

| 대상 | 규칙 |
|---|---|
| 보스 등장 | `3*`부터 |
| Dysangelos 실전투 | `5*`부터 (단, Mind Stone 획득 전에는 비활성) |
| Xyloalgia 페이즈 2 | `6*`부터 |
| Poena 데미지 누적 | `11*`+ |
| Xyloalgia 추가 페이즈 | `15*`+ (6스턴 후) |
| Miniboss 등장 | `11*`+ |
| 일반 적 등장 (Rocky Plateau) | `16*`+ |
| 장애물 등장 (Rocky Plateau) | `11*`+ |
| Acronian Scout 날개 태그 | `12*`부터 |
| Acronian Scout 특수공격 (5타 후) | `12*`부터 |
| Chest 드랍 테이블 | `5*`부터 (오프라인 시 룬 혼합) |

### 3.3 수치 스케일

각 밴드별 `health`, `damage`, `special`, `armor`, `stun`, `heal` 표가 위키에 존재.
밴드 경계마다 값이 불연속으로 튄다(예: Xyloalgia Ph1 health `3*-5*: 230 → 6*-10*: 300`).

### 3.4 결정 — TIN 계약

- 스타 레벨은 **런 파라미터**다. `(location_id, star_level, run_seed)` 3_tuple이 런을 결정한다.
- 레벨이 `content gate`를 연다. 게이트는 데이터로 선언한다(`min_star`).
- 밴드별 수치는 **밴드 테이블**로 저장한다. 밴드 내에서는 보간하지 않는다(원작이 불연속).
- 플레이어는 Star Stone로 레벨을 직접 고른다. 강제 상승 없음.

---

## 4. 적 상태 기계 (사실)

### 4.1 상태 표 구조

| Behavior | State | Name | Time (f) | Notes |
|---|---|---|---|---|
| 1 | | Awakenings | 60 | Wakes up at foe.distance 25 |
|  | | Casting | 15 | +105f after the 5th attack |
|  | | Performing | 6 | |
| 2 | | Cooldown | 0 | There is no cooldown |

- `foe.state` = 행동 번호(1=주기 행동, 2=이동).
- `foe.time` = 그 상태에 진입한 뒤 지난 프레임.
- 상태 종료 판정: `foe.time >= Time(f) - 1`.
- `chill` debuff는 모든 상태 시간을 늘린다(위키 명시). **시간 배율 debuff.**

### 4.2 행동 속성 (위키 "Attacking Attributes")

| 속성 | 단위 |
|---|---|
| Casting Range | foe.distance |
| Attack Reach | foe.distance |
| Velocity | projectile 이동/frame |
| Knockback / Push | foe.distance |
| Lifetime | frame |
| Stun Duration | frame |
| Evadable | bool |
| Damage Delay | frame (폭발 등) |

### 4.3 이동 제약

- Bomb Cart: "can only move forward" — 방향 고정 AI 제약.
- Flying 태그: Acronian Scout는 `11*`에서 flying 없음, `12*`+에서 획득.

### 4.4 태그

`humanoid` `ranged` `flying` `melee` `slow` `explode` `boss` `phase1` `phase2` `phase3`

- `boss` 태그 → Unmaking 면역.
- `phaseN` 태그 → 페이즈별 교체. miniboss는 phase 태그를 **갖지 않는다**.

### 4.5 면역·저항

- Immunities: `Stun`, `Unmake`, `Push` (전 boss 공통 "All: Stun, Unmake, Push")
- Resistances: 속성별 배율. `Magic (0.5x)`, `Ph3: One element`
- 폭발 적은 **damage status effect를 전부 무시** (Weaken 무효).

### 4.6 결정 — TIN 계약

- `foe.state`/`foe.time`을 그대로 존. 상태는 **데이터 테이블**(이름, 프레임, 전이).
- 전이 그래프는 데이터. `cooldown: 0` 같은 0프레임 상태도 정상.
- debuff는 `상태 시간 배율`(`chill`)과 `쿨다운 증감` 두 종류를 우선 지원.
- 태그는 개방 문자열 집합. core가 특정 태그 이름을 하드코딩하지 않는다.

---

## 5. 보스 (사실)

### 5.1 페이즈 체인

- 페이즈 1~3. 페이즈마다 **별도 `Foe ID`** 가 있다.
  `dysangelos_bearer` → `dysangelos_elementalist` → `dysangelos_perfected`
- 페이즈마다 `Element`, `Immunities`, `Resistances`, `Tags`가 바뀐다.
- 페이즈 전환 조건: HP 임계값(수치 미수집).

### 5.2 페이즈 유형

**(a) 무결交替** — Xyloalgia: 무기(Stun) → 페인(거울 반사, stun 면역 아님).
**(b) 소수 랜덤 속성** — Dysangelos Ph2: 눈 모양이 다음 팔을 예고. 속성 카운터 안 맞으면 debuff.
**(c) 적응형 저항** — Dysangelos Ph3: 매번 방어 시 "그때까지 가장 많은 피해를 낸 속성"에 저항 스택. 다른 속성이 앞서면 스택 전부 버리고 새로 획득. **단 Stone 속성은 예외** — 저항을 얻지도 버리지도 않고 armor만 증가.
**(d) 자기 증식/반사** — Poena: 미러 버프 중 디버프 반사, 크itical 반사(vl jugador 증가), 힐 반사(초과 회복).

### 5.3 보스 공통 규칙

- 마지막(또는 끝 근처)에 배치. 패턴 공격.
- `3*`부터 등장. 단, 특정 보스는 특정 Stone 획득 전까지 "전투를 시작하지 않는다" (Dysangelos는 Mind Stone).
- 첫 조우 시 **스킵 불가 컷신** (Acronian Scout는 전후 2회).
- Miniboss: yellow는 끝 근처 단독, green은 시작 지점 일반 적과 함께.

### 5.4 미수집

- 페이즈 전환 HP 임계값 전부
- 각 보스의 실제 공격 패턴 목록
- 보스 방 지형/장애물 규칙
- 보스 전용 컷씬 텍스트

---

## 6. 소울스톤 = 동사 해금 (사실) — 핵심 진행 구조

10개의 돌이 각각 **새로운 동사**를 연다. 스탯 강화가 아니다.

| # | 돌 |gry는 동사 | 근거 |
|---|---|---|---|
| 1 | Sight | **관찰** (Beastiary 정보 해금) | 적 정보 조회 |
| 2 | Star | **난이도 선택** + 자원 자동 흡수(자석) | star level 선택, cyan/yellow/green 해금 |
| 3 | Experience | **레벨업** (hp↑, chest 개수↑) | max chest 수 증가 |
| 4 | Ki | **경험/통화 획득** + 리롤 | Ki = 제작·리롤 자원 |
| 5 | Quest | **퀘스트/전설** | Legends 해금 |
| 6 | Ouroboros | **루프** (완료 지역 끝에서 되돌아감) | 무입력 무한 플레이, 패시브 회복 |
| 7 | Fissure | **분해** (기본 성분으로, 인챈트 분리) | |
| 8 | Triskelion | **인챈트 융합** + 다른 인챈트 방식 + 보행속도 | |
| 9 | Mind | **스크립트** + 후방 대시 + 회피 | Stonescript, dash backward |
| 10 | Moondial | **리롤/변이** + 공격속도+5 | 마지막. Dispatch 전투가 필요(Ph3) |

### 6.1 결정 — TIN 계약

**진행 = 숫자가 아니라 동사의 해금 목록이다.** 이 Kit의 progression UI는 스탯 화면이 아니라 "지금 무엇을 할 수 있느냐" 목록이다.

돌은 `Equippable`이고 **착용 중이면 패시브가 붙는다.** (경험+1, Ki+1, 보행속도, 공격속도+5, 패시브 회복)
So 동일한 돌이라도착용 여부가 다른 빌드가 된다.

---

## 7. 아이템·인벤토리·화제 (사실)

### 7.1 아이템 스탯

| 스탯 | 단위 |
|---|---|
| Damage | 정수 |
| DPS | 정수 |
| Attack Speed | frame (`1.5s or 45f`) |
| Range | 거리 단위 (18) |
| Cast / Perf / Cooldown | frame (16/14/15) |
| Element | Stone / Poison / Vigor / Aether / Fire / Ice |
| Handedness | One-Handed / Two-Handed |
| Tags | magic 등 |
| Star level | 0~10 |

### 7.2 인챈트

- 어펙스 표기: `aL` `dL` `D/A` `dX/ax` — 대/소문자가 상위/하위 Seems 구분.
- 어펙스 방향성: 제작 시 **오른쪽 슬롯이 어펙스를 결정.**
- 인챈트에 **내부 시드**가 있다. 같은 시드라도 결과 인챈트 스탯이 달라질 수 있다.
- 인챈트 위에 인챈트를 붙이면 **약한 것을 버린다** 경고 박스.

### 7.3 Chest

- 레벨이 올라가면 **보유 가능한 chest 최대 수가 증가** (Experience Stone).
- Chest 등급: Common / Giant / Omega / Delta / Emerald Egg.
- 드랍은 스타 레벨별 확률 테이블.
- 오프라인 시 주 드랍은 **모든 룬의 혼합.**

### 7.4 결정 — TIN 계약

- 인벤토리 상한은 `chest_cap = f(player_level)` 파생값. UI가 아니라 **도메인 제약**으로 둔다.
- 인챈트 결과는 `(base_seed, slot_side, input_ids)` 로 결정론적 파생. `randf()` 없음.
- Chest 등급 확률은 데이터 테이블. authored.

---

## 8. 제작 (사실) — 동사 4개

Workbench(대장장이) 에서. 3개 금속 조각(로키 1 + 데드우드 2) → Smithy Hammer → Anvil.

### 8.1 네 가지 용도

| 용도 | 입력 | 규칙 |
|---|---|---|
| **Upgrading** | 같은 아이템 × 2 (같은 스타) | 스타 +1. 필요 수량 `2^n`. 상한 10 → 1024개 |
| **Crafting** | 다른 아이템 A + B | 40개 레시피. **성공 확률 있음** |
| **Enchanting** | 아이템 + 인챈트 | 인챈트 융합. Lost Item은 2슬롯이 Boost/Upgrade 버튼에 가려짐 |
| **Boosting** | Lost Item + 복제본 | 12500 × n. 최대 8회. 5-7*는 1회, 8*는 2회, 9*는 3회 |

Lost Item 업그레이드 필요 수량은 별도 표 (5*:1, 6*:2, 7*:4, 8*:8, 9*:16, 10*:32).

### 8.2 제작 결정성

- 레시피는 저널(Crafting Booklet)에 전부 수록. 인벤토리에 들어 있음.
- **오른쪽 슬롯이 어펙스를 결정.** 룬 아이템은 어느 쪽에느냐에 따라 `D/A` vs `dX/ax` 로 갈림.
- 인챈트 아이템 + 비인챈트 아이템 → 결과 인챈트 스탯이 **달라질 수 있음** (시드는 동일).
- 인스탄트 크래프트가 아니라 **확률 시드** 기반.

### 8.3 미수집

- 40개 레시피 외의 실패/부분 성공 결과
- 제작 시UFFS(Polish) 계층
- Smithy Hammer / Anvil 자체의 기능 범위

---

## 9. 전설(Legends) (사실) — 스토리·선택 구조

Quest Stone 획득 시 해금. 15개(+1 예정).

### 9.1 구조

```text
Requirement (돌 획득)
  → Plot 노드열
      각 노드에 선택지
        ▶ wrong  : 퀘스트를 더 어렵게 / 포기 / 불필요하게 길게
        ▶ right  : 최선
        ▶ neutral: 나쁜 일 없음
  → Endings (1~3개)
  → Rewards
  → Navigation: 다음 Legend 해금
```

### 9.2 Croaked (구체 사례)

1. 제阶段 선택: `Return Later`(종료, 게일버트가 질책) / `Offer Help`(진행)
2. 개구리 3마리 제거: 모기 40마리 → 달팽이 12마리 → 거미 50마리
3. 협곡이 개구리로 가득 찬다. Sight Stone으로 진실 판독.
4. **엔딩 3개:**
   - `Leaving` — 인챈트 받고 떠남
   - `Hatchet` — 게일버트를 도끼로 절단
   - `Shovel` — 삽으로掘어 물가에
5. 보상: `+1 Enchantment`

### 9.3 Guild of Smack-Hammer (절차형 과제)

3단계 과제를 순서대로, 각 단계마다 `태우기 / 건네주기` 분기:

1. 3* 방패 만들고 5타 생존
2. 3* 검 만들고 죽지 않고 20명 처치
3. 보스를 1타로 죽이는 무기

최종: guild은 **사기**였음. 전액 환불 + Giant Treasure 보상.
→ **과제 = 기존 시스템(제작/전투/아이템)의 조합 시험.** 별도 미니게임 없음.

### 9.4 결정 — TIN 계약

- 전설은 **별도 미니게임 금지.** 항상 기존 시스템 위의 과제 조합이다.
- 선택지는 도메인 결과로 해석되어야 한다. 전설 스크립트가 아이템을 직접 만들지 않는다.
- 엔딩은 `n`개이며 보상이 다르다. 마지막 선택 노드가 엔딩 분기다.

---

## 10. 절차 생성 (사실 + 결정)

### 10.1 사실

사이트 소개: "8+ hours of main story gameplay, **in addition to procedurally generated content**".
→ 저작 메인 스토리 외에 ** 절차 생성 콘텐츠 층이 따로 존재한다.**

결정적 근거 (위키에서 확인):
- 스타 레벨이 오를 때마다 로케이션의 **적 구성·장애물·miniboss 존재·드랍 테이블**이 바뀐다.
- 상점 재고/가격은 구매 횟수에 따라 변한다.
- 크래프팅은 시드 기반 확률.
- 상점은 **매일** 재고가 바뀐다고 명시("Everyday, it sells a collection of items").

### 10.2 결정 — TIN 절차 생성 분할

| 층 | authored | generated |
|---|---|---|
| 로케이션 | 지형 골격, 出입구, 상점 위치, 보스 방 | 적 배치·수량, 장애물 배치, 드랍 |
| 적 | 스탯 테이블, 상태 기계, 패턴 | 스폰 위치·개체 |
| 보스 | 페이즈 체인, 속성, 패턴, 컷씬 | 없음 (항상 authored) |
| 아이템 | 아이템 정의, 레시피, 어펙스 풀 | 루트 시트, 인챈트 시드 |
| 상점 | 판매 목록, 가격 규칙, 행 배치 | 재고, 계절 변화 |
| 전설 | 전체 | 없음 (항상 authored) |

**금지:** 생성기가 authored 콘텐츠 ID를 하드코딩하지 않는다. 생성기는 `(location, star_level, seed)` → 배치만 만든다.

---

## 11. 상점 (사실)

- 3행 × 2열. `Rows` 속성이 어떤 행에 뜨는지 지정.
- 재고/가격/증가폭/최저/최고가 데이터 보유.
  예: `Sword stock 20, price 10@, +1@, max 29@, rows 1-2`
- 구매할 때마다 가격 증가.
- Chest는 별도 가격표(PC / Mobile / Cash).
- 계절 상점 4종: 봄/여름/할로윈/연말.

---

## 12. 미수집 목록 (요약)

**전투**
- 페이즈 전환 HP 임계값 전부
- 각 보스/적의 실제 공격 패턴
- 돌/방패/활 등 무기 종류별 행동 규칙
- 투사체 시각·속도 곡선
- `Unmake` 가 정확히 무엇인지 (아이템 파괴? 관통?)

**아이템**
- 어펙스 `aL` `dL` `D/A` `dX` `ax` 의 정확한 의미
- 인챈트 풀 전체
- Lost Item 목록과 R&D 퀘스트
- `Polish`, `Mutation` 정의

**제작**
- 실패/부분 성공 결과
- Smithy Hammer / Anvil 기능

** progresses**
- Ki 획득량 곡선
- 오프라인 진행의 정확한 규칙
- Reincarnation / Shop 재고 리셋 주기

**스크립트**
- Stonescript 문법 전체 (별도 위키 페이지 존재)

**미수집이 구조를 막는 것**
- 위 목록이 채워져야 필드 전투 루프와 제작 루프의 세부 수치를 확정할 수 있다.
- 그 전까지는 스켈레톤 수치로 진행 가능하나, **밸런스 수치를 확정하지 않는다.**

