# 원문 01 — Stone Story RPG 위키 덤프 + 스크린샷 10장 (2026-09-26)

用户提供原문。이 파일은 **수정 없이 보관한다.** 해석은 `../01_stone_story_rpg/`에 따로 쓴다.

제공자: 사용자
제공 형식: 위키 본문 붙여넣기 + 스크린샷 10장 (채팅 첨부, 저장소 파일 없음)

---

## 사용자 accompany note (원문 그대로)

```
askii게임이지만 우리는 절차적 생성으로 할거라 askii는 금지. ena dream bbq의 분위기를 따라갈거야.
이 스크린샷들이 모든 자료는 아니지만 방향성을 확인하기엔 충분하다고 봐. 일단 이거 가지고 기획하고 있어봐.
ena 가져올게.

목표 해상도 16:9
1. 네이티브 해상도 및 기본 픽셀 비율
레인 월드는 모니터 해상도에 맞춰 화면을 다시 그리는 방식이 아닌, 가로/세로 픽셀이 고정된 그래픽을 늘려서 표현하는 방식을 취합니다.
16:9 비율 기준: 내부 기본 해상도는 1366 x 768 픽셀입니다.
4:3 비율 기준: 내부 기본 해상도는 1024 x 768 픽셀입니다.
게임 내 물리 연산이나 맵 데이터 또한 이 내부 픽셀(Per-pixel) 단위 로직을 완벽하게 따릅니다.
2. 고해상도 모니터에서의 흐릿함(Bilinear Scaling) 원인
표준 FHD(1920x1080)나 QHD(2560x1440) 등의 모니터에서 게임을 전체 화면으로 실행하면, 시스템이 768p 해상도를 모니터 크기에 맞춰 강제로 늘리는 과정(Bilinear 필터링)을 거칩니다. 이 때문에 도트의 경계면이 딱 떨어지지 않고 뿌옇거나 흐릿하게 뭉개지는 현상이 발생합니다.
3. 칼 같은 픽셀(Pixel Perfect)을 얻는 해결 방법
도트 고유의 픽셀 밀도와 선명함을 고스란히 체감하고 싶다면 유저 커뮤니티에서 주로 사용하는 다음 모드나 외부 프로그램을 이용해야 합니다.
Sharpener 모드: 게임 내 모드 설정을 통해 기본 업스케일러를 개선하거나 네이티브 해상도 렌더링 모드를 활성화하여 화면을 선명하게 만들어 줍니다.
정수 스케일링(Integer Scaling) 프로그램 이용: 스팀의 Lossless Scaling이나 무료 도구인 Magpie 등을 사용해 화면비 크롭 후 2배, 3배 등의 정수배로 늘려주면 모니터에서 칼 같은 도트 픽셀을 볼 수 있습니다.

kit는 새로운 슬롯 만들기. 지금 우리는 새로운 키트 하나를 만들고 그 키트 내부에서만 작업할거야. 다른거 수정금지야.
완료 기준은 내가 새로 말한 stone story 규모. stone story rpg로 시스템 기반을 닦아둔 후에 그 위에 다크소울을 얹어서 짝퉁이 되지 않으려고 하는거야. stone story rpg 구조를 먼저 잡자
```

---

## 스크린샷 10장 (파일 미보관 — 채팅 첨부 이미지)

저장소에 이미지로 존재하지 않는다. 아래는 관찰 가능한 사실만 옮긴 기록이다. 해석 문서는 `../01_stone_story_rpg/`에 있다.

| # | 관찰 |
|---|---|
| 1 | 메인 메뉴. `풀레이`, `설정`, `종료`. 상단에 원거리/근거리 두 줄 카운터(`0 11`, `_ 20`). 배경에 벽/이끼/구름 음영의 절차적 점묘. 우상단 `((` 아이콘. 좌측에 구 획선 오닉스 프레임. |
| 2 | 존 선택. 좌측에 `장소` 섹션, 중앙 우측에 `( ooooooooo )` 풍선 오닉스 박스. 최하단에 `◀ ≡` 리턴 아이콘. |
| 3 | 존 진입 텍스트 + 스킵 불가 컷신. `능반에서 알반으로 옮겨다니는 중...` 그리고 `└───` 리전 전환 표현. 중앙 하단에 `○` 와 `바위 고원`. |
| 4 | 발견 컷신 + 확인 모달. `험곡에서 절벽의 토대에 있는 동굴을 발견했습니다.` + `계속하기` 버튼(컬럼 폭에 맞춘 Rect). 모달 배경에 어두운 오닉스 프레임. |
| 5 | 보스 방(1). 상단 `○ 11` 좌상단, `_ 20` 상단 우측. 넓은 단일 화면. 상단은 세로선majesty 벽면, 중간은 검은 평지, 하단은 대시/물결 지면 텍스처. 우측에 다리형 구조물. 중앙에 플레이어 `○` + 오각형 바닥 데칼. 좌하단 `\/O/ 19/20`. 우측에 상자 아이콘. |
| 6 | 보스 방(2). 상동 + 중앙 상단에 `영Chuck라!` 데미지 팝업 (Thin Rect, 중앙 상단). 플레이어 옆에 흰 칩(■) = 투사체. |
| 7 | 보물 상자(Chest) 개방. `보물 상자` 타이틀. 대형 Rect 안에 중앙 chest 아이콘, 좌우에 세로 Tick 마커 바(계기판). 상단 좌우에 `()} ` 형태의 잠금/상자 프레임. 우측에 `+` 크로스 아이템(체력?)과 `\_o`, `\|<(` 겹친 오닉스. 좌상단 `<) \|` 아이콘(인벤토리). |
| 8 | 인벤토리/작업실. 좌측에 `장소` / `작업실` / `아이템` 세 섹션 + 획선 오닉스 프레임 + 초록색 `1` 배지. 우측 상단 3개 슬롯(가로 `ㅏ` 무기, 중앙 `+` 칼 든 플레이어 실루엣, `<) \|` 방패). 중앙에 5열 그리드(상자, `~ \°` 우산형, `I U` 활, `\|--- \|` 견인, `-\<◇\>-\` 둥근 오닉스). 각 칸 하단에 `☐` 배터리 게이지. 중앙 하단에 흰 칩(커서). 좌하단 `≡ ^ ^` 메뉴. |
| 9 | 보스 방(3). 상단 `_ 36`. 하단에 대형 버튼 2개 `나가기` / `아이템` (박스형, 중앙 하단 정렬). 좌하단 `≡ ^ ^`. 우하단 `0/3 거래한 모기` 퀘스트 카운터 + 흰 칩 2개 우측 변위. |
| 10 | 사망/부활 컷신. 상단 `♠ 336` / `_ 899` / `≈ 136` / `@21`. 중앙에 커다란 오닉스 돌상. 좌측에 `◀ 뒤로` 버튼. 중앙에 5열 그리드(상단: `ㅏ` 무기, 플레이어+`\<)` 실루엣, `\<◇\>` 둥근), 2행(하트, 우산, 점선 프레임 `\<)` 박스, `I U` 활, `⌐\_` , `\_/\_\` 3단), 3행 중앙에 점선 Rect. 좌하단 `데드우드 현공`. 하단에 `ㅏ` 무기, `|_/\` `Σ` 오닉스, `|-..| |` 스트랩. 우하단 로고. |

---

## 위키 본문 (원문)

### Locations (Part 1)

#### Combat

Rocky Plateau · Deadwood Canyon · Caves of Fear · Mushroom Forest · Haunted Halls · Boiling Mine · Icy Ridge · Temple

#### Shops & Games

Mushroom Shop · Haunted Gate · Hotspring Shop

---

Locations are where the player goes to.

They can be subdivided into two main categories. The first category are "combat locations", which are composed of enemies and a Boss (as well as a Miniboss at yellow Difficulty and above).

The second category are the "non-combat locations", which serve multiple purposes. The first purpose is for transitioning from one point to the other or as a scene. The second purpose is for shops, which may be seasonal (meaning they only appear when certain Events are active). The third is for other uses for gameplay.

Part 1 of Stone Story RPG (which revolves around the overworld of the dark world) features 8 main combat locations, 3 main non-combat locations along with 4 transitional locations. It also has 4 seasonal shops. Part 2 of the game is featured in Acropolis, and is planned to have 6 locations and bosses.

#### List of Locations

Below is the list of all the main locations regularly accessible at any time:

Rocky Plateau
Deadwood Canyon
Caves of Fear
Mushroom Forest
Mushroom Shop
Haunted Gate
Haunted Halls
Boiling Mine
Icy Ridge
Temple
Hotspring Shop

Below are the seasonal shops, activated in Spring, Summer, Halloween, and the Holiday season respectively:

Balloon Shop
Warm Stone Shop
Candy Shop
Hot Beverage Shop

#### Rocky Plateau

Rocky Plateau
{{{size}}}px

| | |
|---|---|
| Boss | Dysangelos |
| Miniboss | Acronian Scout |
| Collected Resource | Ki, Stone |
| Elemental Drops | Mixed |
| Location ID | rocky_plateau |

##### Navigation

Rocky Plateau ▶ Deadwood Canyon

Rocky Plateau is the first and last location the player will travel to in SSRPG. This location is where the player gets both the Sight Stone and The Moondial... Stone. The player meets Dysangelos in this location and also chooses their name. This location also houses one of the three anvil pieces.

The boss of this location is Dysangelos, while the miniboss is Acronian Scout. This location features two enemies, being the Acronian Soldier and the Acronian Warcaster. Rocky Plateau's main resource is stone, dropped from boulders or picked up from the ground.

##### Contents

1. Enemies
   1.1 Dysangelos
   1.2 Acronian Scout
   1.3 Acronian Soldier
   1.4 Acronian Warcaster
2. Treasure Drops
3. Gallery

##### Enemies

The enemies that appear in Rocky Plateau are from Acropolis. The location is mainly a boss fight against Dysangelos, with obstacles appearing between the player and the boss appearing in 11\* above. Regular foes do not appear until 16\*.

Dysangelos
Main Page: Dysangelos

The main boss of Rocky Plateau. He has three phases and has the most health of all the bosses in Stone Story RPG. While tanky, using the correct strategies will make him easy to beat.

Acronian Scout
Main Page: Acronian Scout

The miniboss of Rocky Plateau. Coming from acropolis, the scout uses a spear in order to damage the player. Stunnable, and has no weaknesses.

Acronian Soldier
Main page: Rocky Plateau § Acronian Soldier

A knight from Acropolis that appears in a group. Wields a sword and a shield and has armour.

Acronian Warcaster
Main page: Rocky Plateau § Acronian Warcaster

A spellcaster from Acropolis that summons lobbed orbs to damage the player.

##### Treasure Drops

These are the drops for the Treasures of Rocky Plateau, starting from 5\*. When Offlined, the main drop is a mix of all the runes.

| Level | 5\* | 6\* - 10\* | 11\* - 15\* | 16\* - 20\* |
|---|---|---|---|---|
| Common | 74.00% | 17.25% | 14.50% | 11.75% |
| Giant | 22.00% | 70.00% | 70.00% | 70.00% |
| Omega | 3.00% | 10.10% | 12.70% | 15.30% |
| Delta | 1.00% | 2.65% | 2.80% | 2.95% |
| Emerald Egg | - | - | - | 0.5% |

> 원문 표의 셀 배열이 열 수와 맞지 않아 수치는 **미검증**이다. 비율 존재와 스타 레벨별 이동만 확인했다.

#### Mushroom Shop

Mushroom Shop
{{{size}}}px

| | |
|---|---|
| Location ID | mushroom_shop |

Mushroom Shop is a location found within the Mushroom Forest. It is a shop run by Hans. Everyday, it sells a collection of items and chests for ki. The shop has 3 rows, and 2 columns of items.

Sometimes, it also sells special, nametagged items, only for mobile players. Ki prices are different for the chests based for mobile players.

The following Items can be sold by Hans in the mushroom shop:

Sword
Shield
Crossbow
Stone Wand
Quarterstaff
Heavy Crossbow
Big Sword
War Hammer
Dashing Shield
Stone Sword
Stone Shield
Stone Staff
Runestone
Rune Shield
Rune Sword
Rune Staff

The following Chests are sold by Hans:

Giant Chest
Omega Chest
Delta Chest

The following Bundles can be bought in the mushroom shop on mobile, replacing the Giant Chest:

The Ghost Slayer!
Ashenguard
Oblivion Maul
Coldsnap Arbalest
Poisons' Edge

As well as the Golden Skin of the Blade of the Fallen God.

##### Pricing

The menu inside the Mushroom Shop.
The following table is the prices for each of the items in the mushroom shop. Rows refers to the row the item will show up in. For every one purchase of an item, the items' price will increase.

On mobile, "Appears in rows 1 & 2" doesn't apply to the 2nd column of the 2nd row. A 20@ item is there instead. Also, 20@ items can't appear in the third row on mobile.

| Item | Stock | Price | Increase | Maximum | Rows |
|---|---|---|---|---|---|
| Sword | 20 | 10@ | 1@ | 29@ | 1-2 |
| Shield | 20 | 10@ | 1@ | 29@ | 1-2 |
| Crossbow | 20 | 10@ | 1@ | 29@ | 1-2 |
| Stone Wand | 20 | 10@ | 1@ | 29@ | 1-2 |
| Quarterstaff | 10 | 20@ | 2@ | 38@ | 3 |
| Heavy Crossbow | 10 | 20@ | 2@ | 38@ | 3 |
| Big Sword | 10 | 20@ | 2@ | 38@ | 3 |
| War Hammer | 10 | 20@ | 2@ | 38@ | 3 |
| Dashing Shield | 10 | 20@ | 2@ | 38@ | 3 |
| Stone Sword | 10 | 20@ | 2@ | 38@ | 3 |
| Stone Shield | 10 | 20@ | 2@ | 38@ | 3 |
| Stone Staff | 10 | 20@ | 2@ | 38@ | 3 |
| Runestone | 10 | 30@ | 2@ | 48@ | 3 |
| Rune Sword | 10 | 50@ | 4@ | 86@ | 3 |
| Rune Shield | 10 | 50@ | 4@ | 86@ | 3 |
| Rune Staff | 10 | 50@ | 4@ | 86@ | 3 |

And this table shows the prices for the chests:

| Chest | PC Price | Mobile Price | Cash Price |
|---|---|---|---|
| Giant | 200@ | 300@ | 0.1$ |
| Omega | 1000@ | 1200@ | 0.4$ |
| Delta | 4000@ | 4000@ | 0.99$ |

#### Bosses

Bosses

Part 1
Dysangelos · Xyloalgia · Bolesh · Angry Shroom · Pallas · Bronze Guardian · Hrímnir · Nagaraja

Bosses refer to the enemies at the very end of a Location.

These enemies are at the end of the level and follow attack patterns. They usually serve as the final challenge in the location and tend to have the most amount of health of any other enemy in the location.

They start appearing at 3\* Difficulty, however Dysangelos doesn't start fighting you up until you collect the Mind Stone from the Temple. His full fight starts at 5\*.

They all have the Foe Tag phase1, but this tag changes depending on what phase the boss is in. Some bosses (like Xyloalgia or Angry Shroom) feature two phases and thus once the second phase is met will shift their tag to phase2, while some (specifically Dysangelos) has a third phase, which has its own unique tag phase3.

Every boss also has the tag boss which makes them immune to Unmaking.

##### List of Bosses

There are currently 8 unique bosses in the game, listed below:

Dysangelos, Bearer of Stones
Xyloalgia
Bolesh, The Cunning
Angry Shroom
Pallas, The Skinless
Bronze Guardian
Hrímnir
Nagaraja

There are also four bosses which feature a second phase, listed below:

Bearer ⇒ One With The Elements
Xyloalgia ⇒ Poena, Mistress of Punishment
Angry Shroom ⇒ Morel, The Sporeadic & Enoki, Fungi To Be With
Pallas ⇒ Pallas, The Legless

Finally, only one boss has a third phase, being

Bearer ⇒ Elementalist ⇒ Dysangelos Perfected

##### Dysangelos

Dysangelos
{{{size}}}px

| | |
|---|---|
| Element | Ph1: Stone / Ph2: Random / Ph3: All |
| Immunities | All: Stun, Unmake, Push |
| Resistances | Ph3: One element (∞♥\*❄φ) |
| Tags | ranged |

| | |
|---|---|
| Foe ID | Ph1: dysangelos_bearer / Ph2: dysangelos_elementalist / Ph3: dysangelos_perfected |

Dysangelos is a unique Acropolite who delivers urgent messages within the cloud city and occasionally elsewhere in the dark world. When not working Dysangelos enjoys stargazing, alchemy and stone skipping.
― Sight Stone

Dysangelos is a character in SSRPG. He serves as the boss of Rocky Plateau and is currently the final boss of the main story. He drops The Moondial... Stone, and allows the player to paint the Star Stone and Ouroboros Stone.

As a character in the game, he likes to stargaze, stone skip, and alchemy. He is described as the "bearer of bad news", and is a messenger from Acropolis.

##### Contents

1. Bossfight
   1.1 Phase 1
   1.2 Phase 2
   1.3 Phase 3
2. Dialogue
3. Stats
   3.1 Foe States
   3.2 Phase 1
   3.3 Phase 2
   3.4 Phase 3
4. Trivia
5. Gallery

##### Bossfight

For a detailed guide to defeating this boss, see Dysangelos/Strategy.

Dysangelos evolved after acquiring 9 powerful Soul Stones. Once a Messenger to Acropolis, Dysangelos aims to establish sole rule of the cloud city after the tenth and final Soul Stone is assimilated.
― Sight Stone

Dysangelos has three main phases, the most of all the other bosses in SSRPG. He only has one phase at 3\*, two phases at 4\*, and all three phases at 5\* and above. His fight revolves around the use of elements and is overall one of the more difficult fights in the early game. While Stonescript is not required to beat this fight, it is recommended in order to easily finish this fight, especially in phase 2.

Phase 1

Phase 1 of Dysangelos is the most simple phase of the three. Dysangelos cycles through his five arms, each dealing some amount of damage. After the fifth arm is used (cycled 3 times in 11\* and above), Dysangelos' eye pops out and shoots a large laser at the player, doing a lot more damage than the five arms. This phase of Dysangelos has no elemental weaknesses, although high DPS Weapons such as runed swords should still be used.

Phase 2

Phase 2 of Dysangelos is the phase which uses the most elements. Dysangelos has his five arms but this time they are marked with each of the five elements, Poison, Vigor, Aether, Fire, and Ice. Dysangelos chooses at random which arm he fires, signalled by his eye changing. If his eye has the symbol of poison (∞), then he will use the poison arm. Each arm has a separate debuff or buff that it inflicts on itself or the player. Each debuff is shown in the table below:

| Element | Debuff / Buff |
|---|---|
| Poison (∞) | Player gains poison debuff, lowering damage output |
| Vigor (♥) | Dysangelos gains immunity to debuffs and heals some amount of hp |
| Aether (\*) | Deals half of the player's current HP and Armor in damage. |
| Fire (φ) | Player gains dot debuff, causing damage over time |
| Ice (❄) | Player gains chill debuff, lowering attack speed |

In order to not get debuffed, the player must use the correct element depending on what arm he is going to use. For example, if Dysangelos is going to use poison, the player must respond with ice (poison's weakness) in order to not get debuffed. Countering the elements will prevent most debuffs from happening, such as dysangelos healing or having chill, dot, or poison, but dysangelos will still gain immunity to debuffs even if countered.

Phase 3

Phase 3 of Dysangelos is one of the only phases where all five elements are strong. He starts by firing a beam from his arms twice. He will then cross his arms and slash, gaining armor. Everytime Dysangelos shields up, the element which did the most damage will show up, and he will gain resistance to that element. For example, if the player uses fire element swords and does the most damage using fire, Dysangelos will shield up and will gain resistance to fire, where the player should switch to a different element. If the element still deals the most damage by the time he shields up, he will gain another stack of resistance to that element, taking even less damage. When another element has dealt the most damage, he will drop all stacks of resistances and gain a new one to that element. The only exception is with Stone Element. If Stone has dealt the most damage when he shields up, he does not gain nor drop any resistance, only gaining armor. He will also deal 1 damage and stun the player if they are standing too close when he shields up.

After shielding up, he enters a cooldown state for a period of time. After finishing his cooldown, he returns to his main attack and fires another 2 beams at the player. He will then prepare his biggest attack. This is one of the most dangerous attacks in the game, where Dysangelos has one of his energy orbs float up and follow the player. After some time following, the orb shoots out a large beam and if not dodged, the beam will almost certainly cause death. In order to dodge the beam, it is recommended to use the Mind Stone's dashing ability, where you can dash backward when equipped. After he performs this attack, he restarts his attack cycle.

##### Dialogue

Dysangelos also has dialogue for different stages of progression, seen in this page: Dysangelos § Transcript

##### Stats

These are the stats of Dysangelos.

Foe States

For a detailed list of foe.state and foe.time values, see Dysangelos § States.

Phase 1

For Dysangelos, Bearer of Stones:

| | 3\* - 5\* | 6\* - 10\* | 11\* - 15\* | 16\* - 20\* |
|---|---|---|---|---|
| Health | 2000 | 1000 | 1500 | 3000 | 3380 | 3760 | 4140 | 4250 | 4500 | 5100 | 5700 | 6300 | 6900 | 13800 | 15000 | 16200 | 17400 | 18600 |
| Damage | 2 | 3 | 4 | 5 | 6 | 7 | 6 | 7 | 8 |
| Special | 10 | 13 | 16 | 19 | 22 | 25 | 24 | 27 | 30 | 33 | 36 | 39 | 42 | 45 | 48 | 51 |

Phase 2

For One With the Elements:

| | 4\* - 5\* | 6\* - 10\* | 11\* - 15\* | 16\* - 20\* |
|---|---|---|---|---|
| Health | 2000 | 1200 | 10000 | 11125 | 12250 | 13375 | 14500 | 13200 | 14650 | 16100 | 17550 | 19000 | 38000 | 40900 | 43800 | 46700 | 49600 |
| Damage | 2 | 3 |
| Weaken Amount | 1 | 1 | 2 | 2 |
| Vigor Heal | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 1000 | 1100 | 1200 | 1300 | 1400 | 1500 | 1600 | 1700 |
| Burn Duration | 10s | 10s | 12s | 14s | 16s | 18s | 20s | 22s | 24s | 26s | 28s | 30s |
| Chill Duration | 16s | 24s | 26s | 28s | 30s | 32s | 34s | 36s | 38s | 40s | 42s | 44s | 46s | 48s | 50s | 52s |

Phase 3

For Dysangelos Perfected:

| | 5\* | 6\* - 10\* | 11\* - 15\* | 16\* - 20\* |
|---|---|---|---|---|
| Health | 2000 | 16000 | 17500 | 19000 | 20500 | 22000 | 18000 | 21000 | 24000 | 27000 | 30000 | 60000 | 66000 | 72000 | 78000 | 84000 |
| Armor | 500 | 1840 | 2005 | 2170 | 2335 | 2500 | 3300 | 3725 | 4150 | 4575 | 5000 | 5425 | 5850 | 6275 | 6700 | 7125 |
| Damage | 3 | 4 | 5 | 6 | 7 | 8 | 10 | 12 | 14 | 16 | 18 |
| Stun Duration | 1s | 1.5s | 2s | 2.5s | 3s | 3.67s | 4s | 4.67s | 5s | 5.5s | 6s |
| Special | 25 | 20 | 25 | 30 | 35 | 40 | 80 | 100 | 120 | 140 | 160 | 180 | 200 | 220 | 240 | 260 |

##### Trivia

His name comes from "δυσ-" ("dus"), meaning bad, hard or unfortunate, and "ἄγγελος" ("angelos"), meaning messenger and later angel. Literally, his name means what his description suggests: the messenger / bearer of bad news.

For phase 1:
His eye laser can't have their damage lowered by Weaken or Feeble.

For phase 2:
When beginning this phase, he starts off with Stone element, but only for a brief moment as he immediately switches to a random element when he attacks.
While in Stone element, he is vulnerable to Stone elemented items.
If the player uses an unmake weapon while he uses his fire arm, his arm is unmade, dealing about 2% of his health and meaning he can't use it anymore.
In 6\* and above, using Vigor elemented items against his poison arm actually doubles the amount of poison debuffs received.
His Æther arm will always have a base damage of 2 throughout all difficulties.
Additionally, some alternatives to stop the Æther arm from destroying half of your total hitpoints and armor is by applying a damage penalty debuff such as Weaken or Feeble (with Weaken having at least -2 penalty) if he does not have Protection active, or using a Towering Shield with at least -2 damage reduction enchanted.

For phase 3:
If the player does a critical attack to Dysangelos's third phase while he is casting the big energy orb, it deals 1.5x more damage than usual.
His energy orb can't have their damage lowered by Weaken or Feeble.

##### Xyloalgia

Xyloalgia
{{{size}}}px

| | |
|---|---|
| Element | All: Stone |
| Immunities | All: Unmake, Push |
| Tags | ranged |

| | |
|---|---|
| Foe ID | Ph1: tree_boss / Ph2: poena |

| | |
|---|---|
| Phase 1 | Stun |
| Phase 2 | Stun, after 6 stuns (>15★) |

Xyloalgia is a character in SSRPG. She serves as the boss of Deadwood Canyon and drops the Experience Stone.

They are characterized as being the residue of Leuce, meaning they are the remnants or waste of Leuce.

##### Contents

1. Bossfight
   1.1 Phase 1
   1.2 Phase 2
2. Stats
   2.1 Foe States
   2.2 Phase 1
   2.3 Phase 2
   2.4 Attacking Attributes
3. Trivia

##### Bossfight

For a detailed guide to defeating this boss, see Xyloalgia/Strategy.

Xyloalgia has two main phases, She has only one phase at 3-5\*, and two phases at 6\* and above. Her fight is one of the most simple fights in the game, as since they have no element and their attack is also quite basic in phase 1. In phase 2, things get a lot more interesting.

Phase 1

Phase 1 of Xyloalgia is very simple: All Xyloalgia does is have her roots grow up and hit the player, stunning them for a little bit. Since they have no weaknesses, nor no strengths, this phase is simply just using your best weapons and best strategy in order to defeat Xyloalgia as fast as possible.

Phase 2

Poena, Mistress of Punishment
{{{size}}}px

| | |
|---|---|
| Element | Stone |
| Tags | humanoid |

Mirror: Debuffs applied to Poena are applied back to the source. Poena also gains power when attacked.
― Sight Stone

Phase 2 of Xyloalgia, named Poena, Mistress of Punishment, is more interesting. When Poena holds up her mirror, she gains the mirror buff, which does the following effects:

Any debuffs the player does onto Poena are done onto the player
Any crits the player does onto Poena allows Poena to crit themselves, increasing their damage immensely
Any attack the player casts that heals them, such as Lifesteal (aL & dL) or with Vampiric Potion buff, Poena will heal more than the player gained.

For 11\* and above, for every attack the player does, Poena will have their damage increased by one
Trying to unmake her will lead to you being unmade.
These effects are symbolized by the buff resembling the female sign (♀). When her mirror is down, she attacks the player, and quickly puts it up (much quicker in 11\* and above). Also, she is not immune to any debuffs, including stun.

##### Stats

These are the stats of Xyloalgia.

Foe States

For a detailed list of foe.state and foe.time values, see Xyloalgia § States.

Phase 1

For Xyloalgia, Residue of Leuce:

| | 3\* - 5\* | 6\* - 10\* | 11\* - 15\* | 16\* - 20\* |
|---|---|---|---|---|
| Health | 230 | 300 | 400 | 550 | 750 | 950 | 1150 | 1350 | 1200 | 1600 | 2000 | 2400 | 2800 | 5600 | 6400 | 7200 | 8000 | 8800 |
| Damage | 4 | 5 | 7 | 9 | 12 | 14 | 17 | 19 | 9 | 12 | 14 | 16 | 19 | 19 |

Phase 2

For Poena, Mistress of Punishment:

| | 6\* - 10\* | 11\* - 15\* | 16\* - 20\* |
|---|---|---|---|
| Health | 1200 | 1375 | 1550 | 1725 | 1900 | 3200 | 3650 | 4100 | 4550 | 5000 | 10000 | 10900 | 11800 | 12700 | 13600 |
| Damage | 9 | 12 | 14 | 17 | 19 | 22 | 24 | 27 | 29 | 32 | 32 |
| Heal Multiplier | 10x | 11x | 12x | 13x | 14x | 15x | 16x | 17x | 18x | 19x | 20x | 21x | 22x | 23x | 24x |

Attacking Attributes

This table holds attacking attributes for the Xyloalgia & Poena. Casting Range, Attack Reach, Velocity (Ph1), and Knockback/Push (Ph1) is measured in foe.distance, where it determines how close the enemy has to be to attack, how far their attack can reach, how fast the "bullet" travels, and how far the attack moves the player back. Lifetime and Stun Duration (Ph1) determines how long the "bullet" exists, and how long the debuff lasts since it is on a fixed timer, measured in frames.

This table is for Xyloalgia.

| Level | 3\*+ |
|---|---|
| Casting Range | 24 |
| Attack Reach | 24 |
| Velocity | 1 |
| Knockback/Push | 5 |
| Lifetime | 23f |
| Evadable | Yes |
| Stun Duration | 15f |

This table is for Poena.

| Level | 6-10\* | 11\*+ |
|---|---|---|
| Casting Range | 24 |
| Attack Reach | 22 | 25 |
| Lifetime | 0f |
| Evadable | Yes |

Trivia

Xyloalgia's name comes from the Greek Xylo-, meaning wood, and -algia, meaning pain.
Poena's name comes from mythology.
The Hatchet on Xyloalgia deals three more damage than usual.

#### Minibosses

Minibosses

Part 1
Acronian Scout · Wasp Nest · Ceiling Decorator · Mr. Puff · R.I.Pieces · Bomb Cart · Giant Ice Elemental · Acronian Cultist

Minibosses refer to the enemies found in 11\* Difficulty and above.

They all have a lot of health and have a special gimmick to combat the players. In yellow stars, they are found at the near end of the area by themselves before encountering the boss. In green stars, they are found at the beginning of the level alongside some foes to serve as a challenge. There are currently 8 different minibosses.

Unlike bosses, they do not have the Foe Tag phase. While most of them do have the tag boss, Wasp Nest in particular doesn't, which makes it vulnerable to Unmaking.

##### List of Minibosses

There are currently 8 unique minibosses ingame:

Acronian Scout
Wasp Nest
Ceiling Decorator
Mr. Puff
R.I.Pieces
Bomb Cart
Giant Ice Elemental
Acronian Cultist

##### Acronian Scout

Acronian Scout
{{{size}}}px

| | |
|---|---|
| Element | Stone |
| Immunities | Unmake, Push |
| Tags | humanoid flying |

| | |
|---|---|
| Foe ID | acronian_scout |

Since the fall of Pallas and the dissolution of the Frost Torch Guild, Acropolis has stood uncontested. Its army, once grandiose, diminished into a force for internal order. The scouts play a vital role in connecting the capital's interests to the greater dark world and have been preserved. They are obedient to the chain of command, but still loyal to Leuce.
― Sight Stone

The Acronian Scout is a miniboss that appears in Rocky Plateau in 11\* and above.

The Acronian Scout attacks the player by stabbing them with their spear. From 12\* onwards, the scout will also gain a new ability. After 5 attacks, the Acronian Scout will start to flap his wings, pushing back the player and charge up a more powerful spear attack. After that, the Acronian Scout will continue to stab you until defeated. He has no elemental weaknesses and can be stunned. He drops 5@ upon defeat. When encountered at Rocky Plateau's 11\*, it does not contain the flying tag.

##### Stats

These are the stats of the Acronian Scout.

| Level | 11\* - 15\* | 16\* - 20\* |
|---|---|---|
| Health | 1550 | 1950 | 2350 | 2750 | 3150 | 6300 | 7100 | 7900 | 8700 | 9500 |
| Damage | 2 | 3 | 4 |
| Special | - | 8 | 10 |

This table holds attacking attributes for the Acronian Scout. Casting Range, Attack Reach, and Max Knockback/Push is measured in foe.distance, where it determines how close the player has to be to attack, how far their attack can reach, and how far the player can be pushed back the furthest. Lifetime and Knockback/Push Timing determines how long the "bullet" exists, and how long it takes to push the player back during its special attack, measured in frames.

| Level | 11\*+ |
|---|---|
| Casting Range | 11 |
| Attack Reach | 11 |
| Max Knockback/Push | 10 |
| Lifetime | 0f |
| Knockback/Push Timing | 2f |
| Evadable | Yes |

##### Dialogue

When entering Rocky Plateau 11\*, an unskippable cutscene will play, before and after fighting him: Acronian Scout § Transcript

##### Foe States

This table holds a list of values for foe.state along with how long each state lasts (in frames, which may be used along with foe.time) for the Acronian Scout. This list does not account for chill, which increases the amount of time a state lasts for.

The name of each state is the internal name of the state (if there is no internal name, just a name which describes the state). Note that while the time starts at 0, so if you are checking for when the state ends, get the time and subtract one from it.

| Behavior | State | Name | Time (f) | Notes |
|---|---|---|---|---|
| 1 | Awakenings | 60 | Wakes up at foe.distance 25 |
| | Casting | 15 | +105f after the 5th attack for special attack |
| | Performing | 6 | |
| 2 | Cooldown | 0 | There is no cooldown |

This table shows the walkspeed of the Acronian Scout; this is measured in frames; its walking state uses foe.state 2.

| Walkspeed | | |
|---|---|---|
| Variant | Time (f) | Movement/Sec |
| All | 3 | 10 |

##### Bomb Cart

Bomb Cart
{{{size}}}px

| | |
|---|---|
| Element | Fire |
| Immunities | Unmake, Push |
| Resistances | Magic (0.5x) |
| Tags | humanoid melee slow explode |

| | |
|---|---|
| Foe ID | bomb_cart |

Explodes upon contact or if defeated.
Takes half damage from magic.
― Sight Stone

Bomb Cart is a miniboss that appears in Boiling Mine in 11\* and above. It features a cart with a large bomb on it being pushed by a controller with unique horns that are different to that of a normal Controller. It will explode when the player gets too close or when it's defeated. Applying Weaken to it will not do anything as explosive enemies ignores any damage status effects.

##### Stats

These are the stats of the Bomb Cart. Similar to Mr. Puff and Pallas the Skinless, the damage stats shown by the Sight Stone are false.

| Level | 11\* - 15\* | 16\* - 20\* |
|---|---|---|
| Health | 700 | 850 | 1000 | 1150 | 1300 | 2600 | 2900 | 3200 | 3500 | 3800 |
| Damage | 60 | 65 | 70 | 75 | 80 | 85 | 90 | 95 | 100 | 105 |

This table holds explosion attributes for the Bomb Cart. Detonate Range and Explosion Reach is measured in foe.distance, which determines how close the player has to be to explode, and how far their explosion can reach. Damage Delay determines how long the "explosion" takes to deal damage, measured in frames.

| Level | 11+* |
|---|---|
| Detonate Range | 4 |
| Explosion Reach | 4 |
| Explosion Delay | 5f |
| Evadable | No |

##### Foe States

The Bomb Cart can only move forward.

| Behavior | State | Name | Time (f) | Notes |
|---|---|---|---|---|
| 1 | Awakenings | 0 | Wakes up immediately at foe.distance 24 |

This table shows the walkspeed of the Bomb Cart; this is measured in frames; its walking state uses foe.state 2.

| Walkspeed | | |
|---|---|---|
| Variant | Time (f) | Movement/Sec |
| All | 15 | 2 |

#### Legends

Legends

Part 1
Croaked · Stone-Head: A Roof Overhead · Remnants of Five · Ascension · Throwing Stones · Mr. Pallas' Wild Ride · Guild of Smack-Hammer · Titanic Accord · The Initiate · Bad Business · The Cauldron Collective · Blowing Steam · Head over Heels · Transmutable Trials · Burnout
Unused
titanic_accord_event_end

Legends are special Quests which are unlocked after gaining the Quest Stone. These legends may unlock new, special Locations, Lost Items, or other items such as the Grappling Hook's upgrades.

These serve as the main way to get the Lost Items, specifically the lost items other than the Lollipop Wand and the Bashing Shield. It also unlocks the Research and Development quest for that specific Lost Item when the legend quest for it has been done.

##### List of Legends

There are currently 15 legends, with a planned 16th coming soon.

Croaked
Stone-Head: A Roof Overhead
Remnants of Five
Ascension
Throwing Stones
Mr. Pallas' Wild Ride
Guild of Smack-Hammer
Titanic Accord
The Initiate
Bad Business
The Cauldron Collective
Blowing Steam
Head over Heels
Transmutable Trials
Burnout

##### Navigation

When dealing with legends, the players have choices. In this wiki, the choices are classified as following:

▶ This choice is wrong; it may make the quest harder, forfeit the quest, or make it much longer than it needs to be.
▶ This choice is right; it is the best option.
▶ This choice is neutral; nothing bad will happen.

##### Croaked

Croaked

| | |
|---|---|
| Requirement | Obtain the Quest Stone |

| | |
|---|---|
| Navigation | ◀ - / Stone-Head: A Roof Overhead ▶ |

Croaked is the first legend the player will play through normally.

This legend is accessible immediately after getting the Quest Stone. Upon completion, the player unlocks Stone-Head: A Roof Overhead.

##### Contents

1. Plot
2. Endings
   2.1 Ending 1: Leaving
   2.2 Ending 2: Hatchet
   2.3 Ending 3: Shovel
3. Rewards
4. Transcript
5. External Links

##### Plot

From the Deadwood Canyon, a symphony of croaks dance across the water, led by a conductor of annoyed moans.
-Details

Gilbert has called the player over to the Deadwood Canyon, where something is annoying them. He is stuck with three frogs; however he is more annoyed by the constant ribbiting. Gilbert then asks the player if they can deal with them.

▶ If the player chooses to Return Later, the player leaves the location, while Gilbert scolds them.
▶ If the player chooses to Offer Help, the legend continues.

Gilbert then tasks the player to get rid of Soprano, the first of the three frogs, by getting them to eat mosquitos in the Rocky Plateau; exactly 40 of them. After doing so, the player returns to Gilbert and once again tells them to get rid of Kevin, telling them they like "hard-shelled" objects.

After getting rid of Kevin via feeding them 12 snails in the Mushroom Forest, the player returns once again to get rid of Bandleader, telling them they like "hard-shelled" objects.

After dispatching Bandleader by feeding them 50 spiders (which might also include Bolesh), the player then returns to the canyon, however something has gone very wrong: The entire canyon is filled with frogs. Gilbert notices that they have no escape from the "intimate dancing" of the frogs, they hand over the enchantment. At this point, the player can choose from 1 of 3 endings:

▶ The player can choose to get the enchantment, leaving gilbert.
▶ The player can choose to use the Hatchet, chopping gilbert.
▶ The player can choose to use the Shovel, whisking away gilbert down the river.

Endings

This quest has three possible endings.

Ending 1: Leaving

In an act of repentance for his past behavior, Gilbert has accepted his seat at the forefront of frog-love. Could you maybe have done something to alter this fate? You don't think about that as you stare at the glimmer of your new enchantment. As you depart, you take a look back and notice that some of the frogs begin to climb Gilbert, enlivened by the vibrations their voices create against his trunk.
-Details

The player may choose to just take the enchantment and leave.

Ending 2: Hatchet

After chopping down gilbert...

You don't stop swinging until Gilbert is nothing but a ragged stump. It became easier once his mouth was gone and the wailing stopped. What you did here should be considered a kindness. If it's hard to see it that way, which it probably is, just realize that you have a surplus of wood to accompany your shiny new enchantment. So... that's there! In some odd way of honoring Gilbert, you toss a small branch (no good for use anyway) into the river and watch it float away. You shed no tears.
-Details

The player has chopped down gilbert into wood.

Ending 3: Shovel

After defiling gilbert...

You've saved Gilbert from a life of documenting nature in its most stimulated state. He will continue his odious existence at the edge of Deadwood Waterfall, no better a tree than he was when you first met him.
-Details

The player has dug up gilbert and somehow landed on the bank of the Deadwood Waterfall. He will stay there, even after the quest is done.

Rewards

Upon completing this quest, the player gets a +1 Enchantment.

##### Guild of Smack-Hammer

Guild of Smack-Hammer
100%
100%

| | |
|---|---|
| Navigation | ◀ Mr. Pallas' Wild Ride / Titanic Accord ▶ |

Guild of Smack-Hammer is the seventh legend the player will play through normally.

Upon completion, the player unlocks Titanic Accord.

##### Contents

1. Plot
2. Endings
   2.1 Ending 1: Burning the Letter
   2.2 Ending 2: Lament
3. Rewards
4. Transcript
5. External Links

##### Plot

Things rarely change in your shelter, so you're quick to spot the folded parchment that rests on your trusted anvil. It's worth investigating── if only to find out who's entered your home.
-Details

A letter mysteriously has ended up on your workstation, from the "Guild of Smack-Hammer". It comes from an elite group of forgers, and asks if you want to join. You can either burn the letter or accept the challenge within.

▶ If the player chooses to Burn the Letter, the legend ends immediately.
▶ If the player chooses to Accept the Challenge, the legend will continue.

The first challenge is to make a 3\* shield and use it to survive 5 hits from a mighty foe, or a boss. You can use a Compound Shield and a boss with a weak attack. At this point, the guild congratulates you and asks you to either give the shield away, or burn the letter, remarking that "you're selfish".
▶ If the player chooses to Burn the Letter, the legend ends immediately.
▶ If the player chooses to Give the Shield, the legend will continue.

The second challenge is to make a 3\* sword and use it to kill 20 enemies without dying. You can use Rune Swords on effective, weak enemies such as those in Caves of Fear or Mushroom Forest. The player then has to choose whether to accept it or burn the letter.
▶ If the player chooses to Burn the Letter, the legend ends immediately.
▶ If the player chooses to Give the Shield, the legend will continue.

The final challenge is to make a weapon capable of killing a boss in one hit. This can be done with Bardiche's ability, or a Rune Crossbow with ice element on Bolesh 3\*, as she only has 76 hp. Of this to complete this humungous task, the player finds out that they've been scammed; the guild was fake and was only for gaining powerful items from stoneheads. The Bureau gives back all the items and also a Giant Treasure for you to lament.

Endings

This quest has two possible endings.

Ending 1: Burning the Letter

Something doesn't smell right about the Guild of Smack-Hammer. You've kindly rejected the opportunity by means of the flame.
-Details

Nothing happens with this ending, but at least you didn't lose anything important.

Ending 2: Lament

You've been duped out of all your hard work, but there has been recompense. Fool me once...
-Details

You've sadly been scammed. This ending unlocks Titanic Accord.

Rewards

Assuming the player has gone through all three tasks, the player gets a Giant Treasure along with all their items they've sacrificed.

#### Soulstones

Soulstones refer to the ten stones the player gains in the game.

##### Contents

1. List of Soulstones
   1.1 Sight Stone
   1.2 Star Stone
   1.3 Experience Stone
   1.4 Ki Stone
   1.5 Quest Stone
   1.6 Ouroboros Stone
   1.7 Fissure Stone
   1.8 Triskelion Stone
   1.9 Mind Stone
   1.10 The Moondial... Stone
2. Gallery

##### List of Soulstones

Each soulstone has a different use.

Sight Stone
Main Page: Sight Stone

The first stone the player gains, from Rocky Plateau. The main use of this stone is to gain information about enemies in the Beastiary.

Star Stone
Main Page: Star Stone

The second stone the player gains, from Caves of Fear. This stone pulls Resources towards the player when held, like a magnet. Also allows for the player to choose star level. When upgraded, unlocks cyan, yellow and green stars respectively.

Experience Stone
Main Page: Experience Stone

The third or fourth stone the player gains, from Deadwood Canyon. This stone allows the player to level up, increasing hp and chest count. Gives extra exp when held.

Ki Stone
Main Page: Ki Stone

The third or fourth stone the player gains, from Caves of Fear. This stone allows the player to gain Ki, a resource used in painting among other things, such as rerolling. Gives extra ki when held.

Quest Stone
Main page: Quest Stone

The fifth stone the player gains, from Mushroom Forest. This stone allows the player to get Quests, and also allows to do Legends.

Ouroboros Stone
Main Page: Ouroboros Stone

The sixth stone the player gains, from Haunted Halls. This stone allows the player to loop back when reaching the end of a completed location, allowing for infinite playtime of one location without having to do any inputs. Passively heals when held.

Fissure Stone
Main Page: Fissure Stone

The seventh stone the player gains, from Boiling Mine. This stone allows the player to break apart items into their basic components and also to break off Enchantments.

Triskelion Stone
Main Page: Triskelion Stone

The eighth stone the player gains, from Icy Ridge. This stone allows the player to Fuse Enchantments together and also apply Enchanting in a different way. Also gives a walkspeed boost when held.

Mind Stone
Main Page: Mind Stone

The ninth stone the player gains, from Temple. This stone allows the player to use Stonescript, a powerful tool in making runs. When held, it dashes the player backwards, you can also dodge attacks with it.

The Moondial... Stone
Main Page: The Moondial... Stone

The tenth and final stone the player gains, from Rocky Plateau. Allows the player to reroll enchants more easily and Mutation. When held, it increases attack speed by 5.

##### Experience Stone

Experience Stone
{{{size}}}px

| | |
|---|---|
| Equippable | Yes |
| Handedness | One-Handed |
| Element | Stone |
| Stonescript ID | xp_stone |
| Tags | magic |

Earn XP by defeating foes.
Bonus XP when equipped
-Details

The Experience Stone is the third or fourth soulstone depending on which one the player gets first, with the other stone being the Ki Stone. This stone is dropped in Deadwood Canyon 3\*, from Xyloalgia. It allows the player to gain Experience, which allows leveling up. Increasing your level increases your total health and the maximum amount of chests the player can have. When equipped, it increases experience gained by one.

The number in the middle changes depending on the player's level.

##### Stats

The Experience Stone shares the same stats with the Ki Stone, having 3 damage, 2 dps, and 18 range.

| Damage | DPS | Attack Speed | Range |
|---|---|---|---|
| 3 | 2 | 1.5s or 45f | 18 |

Item States

This table shows the Item States of the weapon, based on the attack speed; this is measured in frames.

| Cast | Perf | Cooldown |
|---|---|---|
| 16 | 14 | 15 |

#### Crafting

Crafting
90%

Creating a fire sword.
“Making smithy hammer…
Fusing metal chunks…„
― Narration

Crafting refers to creating a new item from two different items or upgrading an item. This is done in the Workbench.

The workbench can be created by finding three metal chunks; one from Rocky Plateau, and two from Deadwood Canyon. When combined, the player creates the Smithy Hammer for 5 stones and 1 wood, and then crafts the anvil.

When in the crafting menu, the player sees their inventory (most of it) at the bottom of the screen, which can be scrolled. The player can see the Enchantments they have and their Items. When clicked, the first item fills up the left slot and the second item fills up the right slot. After that, the Fuse button shows up, and allows the item to be fused.

This serves as the main way the player can improve their weapon's stats, and also how the player obtains new weapons.

##### Contents

1. Uses
   1.1 Upgrading
   1.2 Crafting
   1.3 Enchanting
   1.4 Boosting
2. Recipes
   2.1 Recipe List
   2.2 Item Upgrade

##### Uses

Crafting
90%
Crafting menu.

There are three main uses for the workbench:

Upgrading
Crafting
Enchanting

Along with a use for Lost Items;

Boosting
Upgrading

When two of the same items are placed into the workbench, with the same star level, the player can choose to upgrade them, increasing the star level by one. The amount of items needed to upgrade increase exponentially, capping off at star level 10, which requires 2^10 items, or 1024 items in total. The table below shows the amount needed per star level:

| Star Level | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| No. of Items | 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512 | 1024 |

While upgrading Lost Items, the player can upgrade it if they have enough copies of the Lost item. For example, a 7\* lost item needs 4 copies of the lost item, while a 10\* lost item needs 32 copies. The table below shows the amounts needed:

| Star Level | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|
| No. of Items | 1 | 2 | 4 | 8 | 16 | 32 |

When crafting with Affixes, the item on the right determines the affix.

Crafting

When putting two different objects into the workbench, there is a chance that the two objects can be crafted into a new object. For example, placing a Sword and a Shield into the workbench creates a War Hammer.

When crafting with runed weapons, the affix depends on which side the rune item is in; if its on the right, it becomes D/A, while if its on the left, it becomes dX/ax.

When crafting with one enchanted object and one mundane object, for example a Sword +1 and a Poison Wand D, the result may have a different enchanted stat even though the enchantment's internal seed hasn't changed.

Enchanting

When placing an item on the workbench, the player can also put an enchantment on it, fusing it onto the item. This can also be done with lost items, however the 2nd slot is hidden by the Boost and Upgrade buttons.

When putting an enchanted item onto the workbench and attempting to fuse it with another enchant, a warning box pops up saying it will discard the weaker enchantment.

Boosting

When placing a lost item on the workbench, the player might have the option to boost; giving a copy of the lost item. The amount needed to boost 1 time is 12500, for the 2nd time its 25000, 3rd is 37500, and so on. A lost item can be boosted 8 times; once for 5-7\*, twice for 8\*, and thrice for 9\*. The total cost of boosting all 8 times is 450000 item value. The value of an item depends on what is being used to boost:

Crossbow - 2
Shield - 3
Sword - 3
Quarterstaff - 4
Stone Wand - 5
Poison Runestones - 5
Vigor Runestones - 5
Aether Runestones - 7
Fire Runestones - 9
Ice Runestones - 10

Recipes

“Für meine new customers, with the purchase of any two items you get this free Crafting Booklet.„
― Hans

This lists all 40 recipes which lead to a successful craft; the Crafting Booklet holds all of these, placed in the player's inventory. The sections are cut by pages.

##### Recipe List

| Result | Recipe |
|---|---|
| War Hammer | Sword + Shield => War Hammer |
| Heavy Crossbow | Sword + Crossbow => Heavy Crossbow |
| Big Sword | Sword + Quarterstaff => Big Sword |
| Stone Sword | Sword + Stone Wand => Stone Sword |
| Stone Shield | Shield + Stone Wand => Stone Shield |
| Stone Staff | Quarterstaff + Stone Wand => Stone Staff |
| Rune Wand | Stone Wand + Runestone => Rune Wand |
| Stone Hammer | War Hammer + Stone Wand => Stone Hammer / Sword + Stone Shield => Stone Hammer / Shield + Stone Sword => Stone Hammer |
| Repeating Crossbow | Heavy Crossbow + Crossbow => Repeating Crossbow |
| Dashing Shield | Shield + Crossbow => Dashing Shield |
| Compound Shield | Shield + Dashing Shield => Compound Shield |
| Towering Shield | Shield + Quarterstaff => Towering Shield |
| Rune Sword | Stone Sword + Runestone => Rune Sword / Sword + Rune Wand => Rune Sword |
| Rune Shield | Stone Shield + Runestone => Rune Shield / Shield + Rune Wand => Rune Shield |
| Rune Staff | Stone Staff + Runestone => Rune Staff / Quarterstaff + Rune Wand => Rune Staff |
| Stone Crossbow | Heavy Crossbow + Stone Wand => Stone Crossbow / Crossbow + Stone Sword => Stone Crossbow |
| Rune Crossbow | Stone Crossbow + Runestone => Rune Crossbow / Heavy Crossbow + Rune Wand => Rune Crossbow / Crossbow + Rune Sword => Rune Crossbow |
| Big Stone Sword | Big Sword + Stone Wand => Big Stone Sword / Sword + Stone Staff => Big Stone Sword / Stone Sword + Quarterstaff => Big Stone Sword |
| Big Rune Sword | Big Stone Sword + Runestone => Big Rune Sword / Big Sword + Rune Wand => Big Rune Sword / Sword + Rune Staff => Big Rune Sword / Quarterstaff + Rune Sword => Big Rune Sword |
| Bardiche | Shield + Big Sword => Bardiche / Sword + Towering Shield => Bardiche |
| Heavy Hammer | War Hammer + Quarterstaff => Heavy Hammer |

Item Upgrade

The crafting booklet also lists one recipe as upgrading, or

| | |
|---|---|
| Item Upgrade | Same Item + Same Item => Same Item 1\* |

---

## Stonescript (위키에서 언급만 확인, 상세 미수집)

- 스크립트 언어로 러을 자동 조작한다. (`Stonescript ID`, `Stonescript` 페이지 존재)
- 상세 문법·명령·시스템 변수는 **미수집**. 별도 요청 대상.
