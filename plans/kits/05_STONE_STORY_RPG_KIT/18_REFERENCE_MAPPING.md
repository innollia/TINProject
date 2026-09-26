# 18 — Primary Reference 실증 매핑

`docs/KIT_WORKFLOW.md` §11-3, §2 의 요구를 닫는다.
"레퍼런스 확인함" 체크박스로 두지 않는다. **상태마다 무엇을 따라갈지**를 적는다.

원본: [../../../docs/research/stone_story_rpg/00_user_dumps/2026-09-26_01_wiki_and_screenshots.md](../../../docs/research/stone_story_rpg/00_user_dumps/2026-09-26_01_wiki_and_screenshots.md)

---

## 1. 스크린샷 번호 규칙

사용자가 제공한 스크린샷은 두 묶음이다.

| 묶음 | 번호 | 출처 |
|---|---|---|
| Stone Story RPG | **SS-1 ~ SS-10** | [00_user_dumps](../../../docs/research/stone_story_rpg/00_user_dumps/2026-09-26_01_wiki_and_screenshots.md) 스크린샷 1~10 |
| Ena: Dream BBQ | **EN-1 ~ EN-9** | [../../docs/research/stone_story_rpg/02_ena_dream_bbq/00_user_dumps/2026-09-26_01_essay_and_screenshots.md](../../../docs/research/stone_story_rpg/02_ena_dream_bbq/00_user_dumps/2026-09-26_01_essay_and_screenshots.md) |

- **시각 기준은 SS 만 쓴다.** EN 은 분위기·기법의 source 다. (`README` §5)
- 아래 표에서 "따라갈 것"이 없으면 그 화면은 **만들지 않는다.**

---

## 2. 화면 매핑 (12개 화면 전부)

| 화면 | Reference state | 출처 | 따라갈 것 | 복제하지 않을 것 | 계획 위치 |
|---|---|---|---|---|---|
| `title` | 메인 메뉴 | SS-1 | 중앙 위 제목 14px / 중앙 아래 `계속` 1줄 / focus 시 점선 밑줄 / HUD 없음 / 배경은 절차 텍스처만 | `풀레이` `설정` `종료` 문구, 상단 `((` 아이콘 | `10` §5.1 |
| `region_select` | 지역 선택 | SS-2 | 좌측 얇은 섹션 목록 / 우측 대형 오닉스 패널 / 최하단 `◀ ≡` 리턴 / 섹션 라벨은 12px | `장소` 문구, 풍선 오닉스 프레임 | `10` §5.2 |
| `cutscene` | 지역 전환 | SS-3 | 텍스트 라인 중앙 정렬 12px / 스킵 불가 / `--` 프레임으로 전환 표시 | `능반에서 알반으로 옮겨다니는 中...` | `10` §5.3 |
| `cutscene` (확인 모달) | 발견 컷신 | SS-4 | 중앙 1px 박스 + 단일 버튼 `계속하기` / 박스 폭은 텍스트에 맞춰 / 모달 위에 어두운 오닉스 | `험곡에서 절벽의 토대에 있는 동굴을 발견했습니다` | `10` §5.3 |
| `field` | 보스 방(1) | SS-5 | **단일 고정 카메라** / 상단 원근 수직 벽면 / 중단 빈 바닥 / 하단 대시 지면 대역 / 3영역 대역 비율 / 좌하단 생명 3~5 glyph | `○ 11` `_ 20` 수치, 다리 구조물 | `10` §5.4 `01` §4.2 |
| `combat` | 보스 방(2) | SS-6 | 데미지 팝업이 **중앙 상단**, 1px 박스 / 투사체는 흰 1×1 칩 / 팝업은 1회성 | `영Chuck라!` | `10` §5.4 `01` §4.4 |
| `combat` (후퇴) | 보스 방(3) | SS-9 | 하단 중앙 2버튼 `나가기` `아이템` / 좌하단 `≡` / 우하단 퀘스트 카운터 `0/3` | `데드우드 현공` | `10` §5.4 |
| `chest` | 보물 상자 | SS-7 | 대형 박스 / 중앙 상자 아이콘 / 좌우 **세로 tick 마커 바** / 개방 진행도가 좌우 바로 표현 / 타이틀은 좌상 | `보물 상자` 문구 | `10` §5.6 |
| `inventory` | 인벤토리/작업실 | SS-8 | 좌측 3섹션(라벨+획선 프레임) / 상단 3슬롯(주무기·매체·방패) / 중앙 5열 그리드 / 각 칸 하단 게이지 / 중앙 하단 흰 칩 커서 | `장소` `작업실` `아이템` 문구, 초록 `1` 배지 | `10` §5.7 |
| `workbench` | 제작/상점 | SS-10 | 상단 3슬롯 / 중앙 그리드 / 각 칸에 **별(★) 개수** / 하단 슬롯 줄 / 좌측 `◀ 뒤로` 박스 버튼 / 좌상 `♠` 우상 `_` `≈` `@` 4개 수치 | `데드우드 현공`, 각 아이템 아이콘 | `10` §5.8 §5.9 |
| `shop` | 상점 | SS-10 | 3행 2열 그리드 / 각 칸 아이콘 + 우하단 가격 / 좌측 상점명 / 좌하 `◀ 뒤로` | 한정售价 표 | `10` §5.9 |
| `status` | 스탯 화면 | SS-8 (좌측 섹션) | 3×3 그리드 + 확정 버튼 / 장비 4칸 | 스탬 화면 원본 | `10` §5.11 |
| `legend` | — | **없음** | 원작에 전설 **화면** 이 없다. 전설은 지역 선택에서 목록 + 본문 2영역으로 TIN이 설계 | — | `10` §5.10 |
| `beastiary` | — | **없음** | `stone_of_sight`(원작 Sight Stone) 는 도감 정보를 준다고만 기술. 화면은 TIN이 설계 | — | `10` §5.5 |

**레퍼런스에 화면이 없는 3개는 TIN 설계다.** Primary Reference 의 화면 문법
(선 1px / 무채색 / 채움 없음 / 모서리 스파스 / 점선 focus)을 그대로 적용한다.

---

## 3. 시스템 매핑 (위키 근거)

| 시스템 | 출처 | 따라갈 규칙 | 계획 위치 |
|---|---|---|---|
| 자동 전투 | 위키 개요 "A.I. does all the exploring, combat and looting" | 플레이어가 직접 공격하지 않는다 | `05` §1 |
| 물약/능력 타이밍 | 위키 개요 "maximized by good timing" | AI는 최적이 아닌 타이밍에 사용. 개입으로 개선 | `05` §6 |
| 보스 패턴 교체 | 위키 개요 "quick item swaps if the boss changes patterns" | 페이즈 전환 시 약점 속성 변경 | `06` §4.2 |
| 월드 단위 | 위키 "measured in foe.distance" | 좌표 = distance 정수 단위, 픽셀 아님 | `02` §8 `01` §2 |
| 시간 단위 | 위키 "measured in frames" | 30Hz 정수 틱, 초 저장 금지 | `03` §1 |
| 적 행동 | 위키 Foe States 표 | `behavior 1/2` + `state_time` + 0프레임 상태 | `03` §3 |
| 사거리 | 위키 Attacking Attributes | casting/reach/velocity/knockback/lifetime/stun 전부 프레임·거리 단위 | `02` §8.1 |
| 기상 거리 | 위키 "Wakes up at foe.distance 25" / "Awakenings 0f" | `wake_distance` 0 이면 즉시, 크면 거리 내 진입 | `03` §3.2A |
| 이동 제약 | 위키 "can only move forward" | `fixed_direction` 태그 | `03` §3.3 |
| 시간 배율 | 위키 "chill increases the amount of time a state lasts" | 25% 확률 스킵 (이산, 결정론 유지) | `03` §3.6 |
| 스타 레벨 | 위키 3*/5*/11*/16* 게이트 | 게이트는 데이터 선언 | `06` §2 |
| 밴드 스케일 | 위키 밴드별 표 | 밴드 내 선형 / 경계 불연속 | `06` §1.1 |
| 보스 페이즈 | 위키 Foe ID 3종 | 페이즈마다 별도 `foe_id`, `min_star` 로 스킵 | `06` §4 |
| 적응형 저항 | 위키 Dysangelos Ph3 | 최다 피해 속성에 스택 / 다른 속성이면 전부 폐기 / `physical` 예외 | `06` §4.1 |
| 드랍 테이블 | 위키 Treasure Drops 표 | 밴드별 확률 테이블 | `13` §3 `04` §12 |
| 상점 가격 | 위키 Item Prices 표 | 구매마다 증가, 상한 | `08` §2.2 |
| 제작 4동사 | 위키 Uses 4종 | upgrade/craft/enchant/boost | `07` §6 |
| 분해/융합 | 위키 Fissure / Triskelion | 돌 7 / 돌 8 | `07` §7 |
| 인벤토리 상한 | 위키 "increasing your level increases the maximum amount of chests" | `chest_cap = f(level)` | `07` §5 |
| 어펙스 방향 | 위키 "the item on the right determines the affix" | 오른쪽 슬롯 우선 | `04` §11.6 `07` §4 |
| 전설 선택/엔딩 | 위키 Croaked / Guild of Smack-Hammer | 3분류 선택 / 복수 엔딩 / 보상 1회 | `08` §4 |
| 전설 = 기존 시스템 | 위키 "make a 3* shield and use it to survive 5 hits" | 별도 미니게임 금지 | `08` §4.2 |
| 루프 | 위키 Ouroboros | 클리어 지점 무한 반복 | `09` §3.6 `12` §3.4 |
| 오프라인 | 위키 "When Offlined..." | **Phase 1 미구현** | `17` Q6 |

---

## 4. 의도적으로 따라가지 않는 것

| 항목 | 이유 |
|---|---|
| ASCII 문자 렌더링 | 사용자 확정 금지. 절차 도트로 대체 |
| 원작 지명 8개, NPC/보스명, 소울스톤명 | 복제 금지. `13` §1 ID 규칙 |
| 6속성(돌/독/생기/以太/화/氷) 상성 | 사용자 확정: 다크소울식으로. 5타입 + 3상태 |
| `2^N(1024)` 강화 표 | TIN 은 피보나치, 총 143 |
| 보정 단계 `S/A/B/C/D/E` 문자열 | TIN 은 0.00~1.00 실수 |
| `aL` `dL` `D/A` `dX/ax` 표기 | 위키 표기법. TIN 은 어펙스 스키마 |
| 원작 스탯 이름 (생명력/집중력/근력/…) | TIN 자체 이름 |
| 양손 1.5배 | TIN 은 2.0배 divisor |
| 가드 0.35 / 대시 12프레임 등 수치 | 전부 `04` §10 tuning |
| 매일 상점 재고 리셋 | 날짜가 없는 TIN. 지역 재진입 = 1회 |
| 크라야/3D/고채도 (EN) | 시각 층위 분리. 초현실은 규칙 층위 |

---

## 5. 상태별 근거 없는 부분 (명시)

| 항목 | 상태 |
|---|---|
| SS-10 `데드우드 현공` 화면의 정체 | 사망 화면으로 해석했으나 확정 아님. `17` Q11 |
| EN 스크린샷 9장(2인승 마법사/분신)의 규칙적 등가 | 없음. `R5` 두 자아가相近 개념이나 직접 대응 아님 |
| `stone_of_thought`(스크립트) 의 실제 화면 | 없음. Phase 2 |
| 어댑션/`art` 사용 화면 | SS 에 없음. TIN 설계. `10` §5.8 아님 |
| 상점 계절 상점 화면 | SS-10 에 1개만. 나머지 3개 TIN 설계 |
