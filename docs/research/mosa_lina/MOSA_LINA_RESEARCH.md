# Mosa Lina 조사 (2026-09-26)

조사 대상: **Mosa Lina** (Steam appid `2477090`)
목적: Kit B의 Primary Reference로 쓸 수 있도록 시스템과 UX 문법을 추출한다.

조사 방법: Steam 스토어 페이지 직접 조회. 위키·개발자 인터뷰는 **미조사**다. 아래에서 미확인이라고 한 항목은 추측하지 않는다.

## 1. 정체성 (확인 — Steam 스토어 페이지)

| 항목 | 값 |
|---|---|
| 개발 | **Stuffed Wombat, Silkersoft, Lukke, Rollin'Barrel** (4인 표기) |
| 퍼블리셔 | Stuffed Wombat |
| 발매 | **2023-10-17** |
| 가격 | ₩8,900 / 사운드트랙 번들 ₩13,050 |
| 리뷰 | Overwhelmingly Positive **95%** (1,721개, 영문) |
| 장르 태그 | Co-op, 2D Platformer, Puzzle Platformer, Immersive Sim, Simulation, Roguelike, Sandbox, Side Scroller, Minimalist, Colorful, **Pixel Graphics** |
| 기능 | 싱글플레이, 온라인/LAN 코-op, 분할 화면 코-op, **Steam Workshop**, **레벨 에디터 내장**, Steam Cloud |
| 한국어 | 지원 |

> 주의: Nintendo eShop 페이지에는 개발자가 "Accidently Awesome"로 표기되어 있었다. Steam은 4인 개발자 명단을 제시한다. 어느 쪽이 정확한지는 **미확인**이며, 기획서에는 Steam 표기를 쓴다.

## 2. 개발자가 직접 밝힌 설계 철학 (확인 — 스토어 설명 원문)

### 2.1 자기 설명

> "a hostile interpretation of the immersive sim, where nothing is planned, and everything works"

한국어판: "이머시브 심에 대한 적대적인 해석입니다. 아무 것도 계획되지 않았고, 뭘로 해도 다 됩니다."

### 2.2 무엇에 대한 반응인가 (확인)

> "A response to the current trend of Immersive Sim design, where every ability is perfectly suited to solve a specific problem in the game. In order to counter this 'Lock and Key' philosophy, Mosa Lina is aggressively random."

즉 게임이 **반대 فعل것을 명시한다**: 능력을 특정 문제에 딱 맞게 만들지 않는다.

### 2.3 절차 생성이 아니다 (확인 — 결정적으로 중요)

> "**This does NOT mean that the game has proc-gen. Tools and Levels are handmade, they are just randomly selected and sometimes slightly modified!**"

- 도구와 레벨은 **handmade**다.
- 변하는 것은 **선택**이며, **가끔 약간의 변형**이다.
- 따라서 이 게임의 authored content 단위는 **handmade 레벨 1개 + handmade 도구 1개**이고, 런타임은 그 중 무엇을 제시할지만 정한다.

> "It's literally impossible for me to check if all levels are beatable with all combinations of tools. This is what makes it so satisfying: **There is no premeditated solution for you to follow.** You're forced to get creative."

- **전수 조합 검증이 불가능하다고 개발자가 인정**한다. 밸런스 보증 대신 무한 해석을 택했다.
- 이 선언을 그대로 받아들이면, 이 Kit도 "모든 authored 조합이 해결 가능하다"를 보장하면 안 된다.

### 2.4 Raw Random (확인)

> "There are no safeguards here. You might get the same item ten times in a row. You might beat the game without seeing it at all. Every playthrough contains only a fraction of the total levels. They're also selected randomly. Nobody knows what'll happen."

- **안전장치가 없다.** 같은 아이템이 10연속 나올 수 있다.
- 한 번의 플레이는 전체 레벨의 **일부**만 본다.
- 클리어해도 전체를 못 볼 수 있다.
- 따라서 반복 방지(pity), 슬롯머신형 보정, 등장률 가중 **금지**.

> "it's this reckless abandon of predictability that allows you to stop worrying about 'winning' and frees you to enjoy the experimentation. **Fun things happen more often if you don't force them.**"

설계 철학: 이기려 하지 말고 실험하게 만들어야 재미가 산다.

### 2.5 물리 구동 퍼즐 플랫포밍 (확인)

> "The player, tiles, items and obstacles are all parsed through **the same physics-engine**. Everything interacts with everything else."

- **플레이어, 타일, 아이템, 장애물이 전부 같은 물리 엔진에 들어간다.**
- "Sure, all you do is collect fruits to open the portal, but **HOW** you do that is up to you entirely."
- 개발자 자기 발언: "even the most straightforward design is powerless against the endless creativity of players."

이것이 이 Kit의 핵심 시스템이다. **모든 것이 서로 반응하는 단일 물리 세계.** 개체는 아이템을 던질 수 있고, 아이템은 개체를 밀 수 있다.

### 2.6 레벨 에디터와 Workshop (확인)

- 내장 레벨 에디터로 레벨 팩을 만들 수 있다.
- Steam Workshop으로 커뮤니티 레벨 팩을 배포한다.

> **TIN 규칙과의 충돌**: `PROJECT_DECISIONS.md` §6과 `docs/KIT_WORKFLOW.md` §4는 "전용 에디터는 Kit 완료조건이 아니다"고 정한다. 원작은 에디터를 기능으로 출시한다. **결정 필요** — 아래 4절 참조.

## 3. 이 Kit이 따라갈 시스템 축 (사용자 확정과 함께 확정됨)

사용자 확정(2026-09-26): 맵은 handmade, Kamar마 계열 게이트 금지, 앨리스 포스트아포칼립스 세계관, 이미지 0개, 단순하면서 세련.

| 축 | 내용 |
|---|---|
| 진행 방식 | **조합.** 누적 수치 게이트 없음. 잠금-열쇠 금지. |
| authored 단위 | handmade 레벨 + handmade 도구. 런타임 선택기가 무엇을 제시할지만 결정 |
| 물리 | 단일 물리 엔진. 플레이어/타일/아이템/장애물이 전부 동일 파이프라인 |
| 표현 | 미니멀·컬러풀·픽셀 그래픽·사이드 스크롤. **이미지 0개 절차 생성으로 재현 가능.** |
| UI | 런타임 상태는 도구 상태를 실루엣으로만. 별도 인벤토리 없음 |

### 이미지 0개와 가장 잘 맞는 이유 (판단)

Rain World는 스프라이트 생물 개체 수가 많아 표현 대체 비용이 크다. Mosa Lina는 **미니멀 + 컬러풀 + 픽셀**이라 평면 색면과 기하 도형으로 재현할 가능성이 가장 높다. 3개 레퍼런스 중 이 Kit이 절차 비주얼 부담이 가장 가볍다.

### 세계관 연결

`축구공을 모아야 포털이 열린다`는 목표 구조는, 앨리스 세계관에서 **잃어버린 질서를 되찾는 것**으로 그대로 옮길 수 있다. 목표의 정체만 바꾸면 시스템은 그대로 재사용된다.

## 4. 미확인 (조사 필요)

1. **입력 스킴.** 이동·점프·상호작용·도구 사용의 정확한 키 배분. 미확인.
2. **코-op의 정확성 모델.** 두 플레이어가 같은 물리 세계를 어떻게 공유하는지, 호스트 권한인지 롤백인지. 미확인.
3. **런타임 선택 알고리즘.** 레벨과 도구를 뽑는 규칙. "raw random" 외에 제약이 있는지. 미확인.
4. **도구 목록과 물성.** 도구가 무엇을 하고 어떤 물리 계수를 갖는지. 미확인.
5. **레벨 구조.** 한 레벨이 몇 오브젝트로 구성되고, 목표(portal 등)가 어떻게 배치되는지. 미확인.
6. **레벨 에디터를 따라갈 것인가.** TIN 규칙은 완료조건으로 강요하지 않는다. 미결.
7. **난이도/진행 구조.** 클리어 조건, 엔딩 개수. 미확인.
8. **오디오.** 사운드 디자인, 도구, OST. 미확인.
9. **개발 과정.** 4인 개발 규모와 작업 기간. 미확인.
10. **카메라.** 고정/추적, 화면비, 줌. 미확인.

## 5. 금지 (이 Kit에 plan에 들어갈 조항)

- 자물쇠-열쇠 설계. 도구 A는 문 A만 열어야 한다 → 금지
- 등장률 가중, pity(연속 방지), 슬롯머신 보정 → 금지
- "전부 해결 가능" 보장 요구 → 금지. 개발자도 불가능하다고 인정했다
- 절차 생성 레벨 → 금지. 레벨은 handmade다. 변하는 것은 선택뿐
- 이미지 파일 → 금지

## 6. 소스

- Steam 스토어: https://store.steampowered.com/app/2477090/
- DDG 검색(한국어 명칭 확인): https://lite.duckduckgo.com/lite/?q="모사 리나" 게임
