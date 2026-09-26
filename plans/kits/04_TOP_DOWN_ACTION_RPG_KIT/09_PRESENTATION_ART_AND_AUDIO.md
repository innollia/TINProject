# 09 — Presentation, Art and Audio

상태: Top-down Action-RPG Kit의 presentation 실행 계약.  
대상 모듈: `modules/top_down_action_rpg/`  
유일한 Primary Reference: **BLACK SOULS 2**  
기준 화면: 사용자 실제 플레이 캡처 A~H와 TIN의 16:9 지원 해상도.  
현재 상태: 계획 문서만 작성하는 run. 이미지 생성·편집, 오디오 제작, 코드 구현, 게임 실행은 수행하지 않는다.

## 0. 문서 경계와 결정

이 문서는 `plans/kits/04_TOP_DOWN_ACTION_RPG_KIT/README.md`가 지정한 presentation 책임만 소유한다. world/state/combat/content의 진실은 domain과 authored data에 있고, 이 문서는 그 상태를 화면과 소리로 투영하는 방법을 고정한다.

우선순위는 다음과 같다.

1. `docs/research/top_down_action_rpg/USER_PLAY_REFERENCE_2026-09-25.md`의 A~H 직접 관찰
2. `docs/research/top_down_action_rpg/BLACK_SOULS_2_RESEARCH.md`의 시스템 문법
3. `docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md`의 TIN 세계 규칙
4. `docs/VISUAL_DIRECTION.md`와 `docs/IMAGE_ASSET_WORKFLOW.md`의 현행 이미지 제작 경계
5. `docs/UI_WORKFLOW.md`의 정보 우선순위·focus·반응형 규칙

Primary Reference의 화면 문법을 따라가되, 원작의 고유 자산·문구·캐릭터·이름·지도 배치·서식·수치·아이콘은 복제하지 않는다. 앨리스와 앨리스 원작 요소도 사용하지 않는다.

A~H는 **읽기 전용 evidence**다. 8장 모두 960×720이며 최종 화면 해상도가 아니다. 캡처를 게임 배경으로 사용하거나 crop·redraw·generative edit으로 world asset으로 변환하지 않는다.

### TIN 확정한 presentation 원칙

- field와 combat는 서로 다른 문법이다. field 이동 화면을 combat HUD로 덮지 않고, combat는 별도 authored transition으로 들어간다.
- dialogue는 world를 유지한다. document는 world 위에 별도 reading layer를 얹는다. aftermath는 clean menu가 아니라 변경된 같은 world를 보여 준다.
- 플레이 중 상시 Shell HUD는 없다. AppRoot와 Shell은 기술적으로 살아 있을 수 있지만 시각적 존재감은 0이다.
- 색은 보조 channel이다. focus, selection, unavailable, danger/extreme은 색만으로 구분하지 않는다.
- presentation node가 HP, clock, choice availability, corruption state, combat scheduler를 계산하거나 진실로 삼지 않는다.
- 이미지 생성 결과는 이 run의 증거가 아니다. 실제 자산 제작 요청이 있을 때만 candidate를 만들고, 사용자가 명시적으로 승인한 뒤에만 approved와 Gold Standard를 갱신한다.

### 0.1 중앙 해석과 소유권

이 Kit 계획 문서 간 충돌은 중앙 해석으로 해소되며, presentation slice에서 그 해석이 지정한 owner는 다음과 같다. 이 절과 어긋나는 문장은 아래 owner를 따른다.

- **Focus owner.** `01` §6.2와 §14.2가 focus rule의 owner다. disabled/unavailable도 focusable이고 자동 skip하지 않으며 focus와 disabled state를 별도로 표시한다. 이 문서의 3.2, 3.3, 4.2, 4.4, 6.2, 6.3, 8.4, 9절은 그 rule의 projection만 고정한다.
- **Combat band/bar owner.** `01` §15.2~§15.4가 combat presentation의 owner다. combat에 두는 bar는 green timing bar과 `target_hp_or_condition` 두 개뿐이다. `AP` label/resource와 generic red bar는 만들지 않는다. 이 문서의 4.1, 4.3, 14절은 이 이름만 쓴다.
- **Document page cap owner.** 한 page는 9줄을 넘지 않는다. `06` §5.14의 `reading.max_lines_per_page` 상한 9가 정본이고 overflow는 validation error다. 이 문서의 7.1, 7.2, 12.6 geometry는 9줄 예산에 맞춘다.
- **Recovery enum owner.** recovery type은 7개인 `checkpoint`, `respawn`, `clone`, `reincarnation`, `loop`, `immortality`, `institutional_reentry`다. `08`이 소유하고 `crown_alignment`는 recovery type이 아니라 world write다. presentation은 recovery type을 이름·버튼 variant·결과 화면 수로 만들지 않는다.
- **Content identity와 art key owner.** canonical content record는 `06`의 module-local JSON catalog entry다. art key 해석, 활성 Gold Standard 등록, asset brief는 이 문서가 소유한다(11, 12절). content는 이미지 경로, 색, opacity를 갖지 않는다.

`presentation_class`의 canonical enum은 `neutral`, `official`, `confidential`, `hostile`, `extreme`, `narration`, `unavailable`, `result`다. choice surface는 `neutral|extreme|unavailable|result`만 사용하고 document/verb는 나머지 category를 사용한다. 이 문서는 색을 다시 정의하지 않고 class를 projection으로만 다룬다.

## 1. Presentation layer와 상태 투영

화면은 다음 순서로 구성한다.

| Layer | 책임 | 표시 조건 |
|---|---|---|
| World | field camera, actor, prop, route, lighting, aftermath state | 해당 module의 world가 active일 때 |
| Field focus | 현재 직접 상호작용 가능한 대상과 상태 | field에서 focus가 존재할 때 |
| World narration band | 짧은 사건 진행과 결과 확인 | narration/aftermath beat 동안 |
| Dialogue surface | portrait, speaker, 현재 page | conversation active일 때 |
| Choice surface | vertical choice list와 focus | choice set이 active일 때 |
| Document reading layer | 페이지 텍스트와 corruption presentation | document active일 때 |
| Combat surface | command, target, green timing, `target_hp_or_condition`, player resource band | combat active일 때 |
| Recovery | authored recovery surface의 world 변화와 safe focus 복귀 | recovery mode일 때. 전용 결과 화면을 두지 않는다 |
| Shell | 저장·설정·전환 메뉴 등 호출형 UI | 사용자가 Esc 등으로 호출했을 때만 |

각 layer는 domain snapshot을 읽어 표현한다. layer가 닫힐 때는 이전 semantic focus를 복원하거나, 대상이 사라진 경우 명시된 안전한 다음 focus로 이동한다. focus와 hover는 presentation-only이며, gameplay semantic을 대신하지 않는다. disabled/unavailable도 focusable하게 남기며, layer는 focus와 disabled를 서로 다른 표시 channel로 그린다.

## 2. 공통 논리 해상도와 960×720 source adaptation

### 2.1 논리 기준

- TIN의 presentation logical base는 **1280×720**이다.
- 1920×1080은 logical base의 1.5배, 2560×1440은 2.0배로 검수한다.
- 화면 비율은 16:9를 기준으로 한다. 4:3 letterbox, 비균일 가로 늘리기, 960×720 캡처의 단순 stretch는 금지한다.
- Control의 큰 경계는 anchor와 Container로 계산한다. 아래 좌표는 1280×720 기준의 composition target이며, world/camera 좌표와 UI 좌표를 같은 방식으로 고정하지 않는다.
- 1280×720 기준 외부 safe margin은 24 logical px이다. FHD/QHD에서는 같은 logical margin이 1.5/2.0배로 변환된다.
- raster art는 필요한 경우 2× source로 제작하고, logical frame으로 축소·배치한다. text와 focus 선은 vector/native rendering을 우선한다.

### 2.2 A~H 4:3 화면을 16:9로 옮기는 규칙

| Source 상태 | 16:9 TIN adaptation | 고정할 상대 우선순위 |
|---|---|---|
| field/world | world viewport를 16:9로 넓히고 camera framing을 다시 계산한다. actor의 logical scale과 route readability는 유지한다 | world > actor > interactable > decoration |
| dialogue/choice | 하단 dialogue band의 logical 높이를 유지하고, 우측 choice rail은 16:9의 추가 폭을 사용한다. 원본 4:3 화면을 늘려 복제하지 않는다 | speaker/text > choice > world detail |
| combat | 좌측 command rail, 중앙 enemy, enemy 하단 timing bar, 하단 player band의 관계를 유지한다. 추가 폭은 enemy stage와 여백에 사용한다 | enemy/action state > command focus > resource readouts |
| document | world dimming을 유지하면서 text safe width를 넓힌다. page 수는 authored content의 9줄 cap으로 다시 계산하고 기존 4:3 line break를 늘이지 않는다 | document text > page affordance > dimmed world |
| narration/aftermath | world를 넓게 유지하고 하단 band만 일정 높이로 둔다. 추가 폭은 변경된 prop와 대상을 보여 주는 데 쓴다 | changed world evidence > narration |
| recovery | 전용 결과 화면을 두지 않는다. 재구성된 같은 world를 16:9에 다시 배치하고 world 변경 surface에 여백을 준다 | changed world evidence > recovery surface > narration band |

A~H에서 960×720의 절대 좌표를 그대로 옮기지 않는다. source는 관계와 우선순위의 evidence이며, TIN의 1280×720 base와 세 target resolution에서 다시 배치한다.

## 3. Field presentation

### 3.1 Field camera와 world composition

TIN field presentation은 다음으로 고정한다.

- camera는 rotation이 고정된 orthographic top-down이다. 원작의 특정 pixel camera를 복제하지 않는다.
- logical viewport 전체를 world가 사용한다. field의 letterbox, minimap, location title, persistent resource band는 두지 않는다.
- player anchor는 viewport의 `(50%, 58%)`를 기본으로 한다. 즉 1280×720에서는 `(640, 418)`이다. player가 화면 중앙보다 약간 아래에 있어 위쪽 route와 주변 interactable이 읽히게 한다.
- camera는 player와 immediate passage를 동시에 보여 준다. field 상태에서 combat stage로 camera를 확대해 HUD를 미리 보여 주지 않는다.
- world prop의 collision, depth ordering, interactable 범위는 gameplay data가 소유한다. 화면상의 glow나 ring은 그 query의 projection이다.
- 4:3 source의 여백은 world art를 늘려 채우는 것이 아니라 16:9 camera framing과 route composition으로 다시 결정한다.

### 3.2 Field focus와 selection

field에서 선택 가능한 대상은 `field_interactable` focus state를 가진다.

- focus 대상은 in-world outline 또는 작은 geometric marker를 보여 준다. floating label, `Press E`, 상시 icon, top-left text를 사용하지 않는다.
- focus 표시는 2 logical px의 유색 구조선과 작은 diamond/arc marker를 함께 사용한다. 색만으로 focus를 전달하지 않는다.
- 선택 확정 전에는 대상의 색·밝기·위치를 바꾸지 않는다. 확정 시 짧은 in-world response와 audio cue가 난다.
- interaction이 불가능한 target은 focus 순회에서 제외하지 않는다. authored `availability_condition`을 만족하지 않는 대상도 focusable disabled로 남기고, confirm은 world state를 바꾸지 않는다. authored obstruction, NPC refusal, closed passage 자체를 world state로 보여 준다.
- focus 대상이 삭제·사망·제거되면 다음 순서로 이동한다: 현재 대상이 여전히 유효하면 유지, 아니면 가장 가까운 유효 interactable, 다음은 현재 passage/exit, 마지막은 `none`. 이 fallback은 focus 대상이 사라진 뒤의 복원 규칙이며 navigation 중 disabled를 건너뛰는 규칙이 아니다.
- `field_interactable`이 열리면 이동 input을 lock한다. 닫힌 뒤에는 이전 field focus를 복원하고, 유효하지 않으면 위 fallback을 적용한다.
- focus는 mouse hover 없이 keyboard/gamepad로 도달 가능해야 한다. mouse click은 보조 입력이다.

### 3.3 Field state presentation

| State | 화면 표현 | 입력 결과 |
|---|---|---|
| `normal` | world와 actor만 표시한다. persistent UI 없음 | 이동·상호작용 가능 |
| `focus` | 대상 주변에 구조선과 marker가 나타난다 | interact intent만 대기 |
| `selected/active` | focus보다 강한 내부 brush fill과 짧은 response가 나타난다 | conversation/document/event를 시작 |
| `disabled/unavailable` | target 자체가 막힌 상태를 authored world로 보여 준다. focus 표시와 disabled 표시를 두 channel로 분리한다. 별도 debug label 없음 | interact intent는 focus에 머무르고 state를 바꾸지 않음 |
| `success` | world prop/NPC/route의 실제 변경과 짧은 audio cue | 다음 field focus로 이동 |
| `failure` | refusal, closed passage, unavailable target의 authored result | focus를 안전한 대상으로 유지 또는 fallback |

field에서 HP/MP band, `target_hp_or_condition`, action gauge, combat command, quest tracker, menu button을 복제하지 않는다. combat resource가 field에서 필요해지면 별도 world object 또는 authored scene state로 표현하며, 상시 UI를 추가하지 않는다.

### 3.4 Field transition

- field → combat은 world와 encounter trigger를 먼저 확정한 뒤 authored transition으로 들어간다. combat HUD를 field 위에 미리 켜 두지 않는다.
- transition은 world dimming, short hold, combat stage reveal의 순서를 사용한다. 긴 이동이나 설명 modal로 시간을 채우지 않는다.
- combat → field는 result와 world projection이 확정된 뒤 반환한다. 전투 결과가 dialogue flag만 남고 world prop/NPC/route에 반영되지 않은 상태를 presentation 완료로 보지 않는다.
- transition duration은 reference playback으로 튜닝할 수 있는 cheap tuning 값이다. 그래도 상태 순서와 focus 복귀는 고정이다.

## 4. Combat presentation

### 4.1 Combat screen composition

B의 관계를 1280×720 logical base에 옮긴 TIN composition은 다음과 같다.

| Element | 1280×720 composition target | 책임 |
|---|---:|---|
| command rail | x=24, y=72, w=224, h=432 | top-level command와 focus |
| enemy stage | x=280, y=32, w=960, h=520 | enemy visual, target, action state |
| enemy focal point | 약 (760, 290) | combat의 1차 시각 초점 |
| green timing bar | x=520, y=464, w=480, h=12 | next enemy action window |
| target_hp_or_condition | x=520, y=486, w=480, h=8 | focused/primary enemy의 HP 또는 condition projection |
| player combat band | x=0, y=576, w=1280, h=144 | combat-only portrait/status/resource |

- combat bar는 위 두 개뿐이다. `AP` label, `AP` resource, generic red bar를 추가하지 않는다.
- command rail은 좌측에 유지하고 enemy stage와 24 px 이상의 separation을 둔다.
- enemy stage와 player band는 겹치지 않는다. 긴 enemy silhouette이나 charge effect가 rail·band를 침범하지 않도록 stage bounds 안에서 crop/scale한다.
- command와 resource band의 큰 경계는 Container/anchor로 계산한다. 위 좌표는 FHD/QHD에서 1.5/2.0배가 되는 logical composition이다.
- combat field에는 world exploration HUD를 복제하지 않는다. player band는 combat active 동안만 나타난다.

### 4.2 Command list

top-level command는 아래 순서로 고정한다.

1. `Attack`
2. `Skill/Magic`
3. `Defend`
4. `Item`
5. `Escape`
6. `Equipment`
7. `End Turn`

각 row는 한 줄 label을 사용한다. 긴 문자열을 ellipsis로 숨기지 않으며, content validation에서 한 줄 안에 들어가지 않으면 label을 수정하거나 해당 action을 별도 submenu로 authored content에서 분리한다.

- `End Turn`은 action이 아니고 목록의 마지막 control이다. up/down focus 순서에서 `Equipment` 다음에 오며 wrap하지 않는다.
- 초기 focus는 `Attack`이다. unavailable이거나 focusable disabled인 command도 목록 위치를 유지하며 focus에서 건너뛰지 않는다. 모든 command가 unavailable이어도 `End Turn` control이 남으므로 임의의 `none` focus를 만들지 않는다.
- disabled/focusable command에 confirm하면 action validation을 실행하지 않고 authored unavailable reason만 갱신한다. focus 표시와 disabled 표시를 같은 channel로 처리하지 않는다.
- 위/아래 이동은 command focus만 바꾼다. resource, HP, target, clock은 선택 navigation 중 바뀌지 않는다.
- `Skill/Magic`, `Item`, `Equipment`는 같은 combat-local list 문법으로 submenu를 연다.
- submenu의 back/cancel은 parent command row로 focus를 돌려놓는다. field menu나 global inventory로 이동하지 않는다.
- `Equipment`는 combat-local equipment/action command surface를 열고 같은 combat command focus로 돌아온다. 전역 inventory framework을 만들지 않는다.
- focus row는 밝은 내부 brush fill, 2 logical px 구조선, 왼쪽 focus marker를 함께 사용한다. 색 변화만으로 선택을 표시하지 않는다.

### 4.3 Action timing과 `target_hp_or_condition`

- combat에 두는 bar의 name은 green timing bar과 `target_hp_or_condition` 두 개뿐이다. combat presentation의 owner는 `01` §15.2~§15.4다.
- 사용자가 설명한 B의 green bar는 **next enemy action window**로 고정한다. UI는 scheduler의 projection을 표시할 뿐 다음 행동을 추측하지 않는다.
- `target_hp_or_condition`은 B에 남아 있던 두 번째 bar 자리에 두고 focused enemy 또는 encounter primary enemy의 HP/condition projection으로 읽는다. 수치·잔량·advance cadence는 combat domain이 소유하고 presentation은 그 projection만 그린다. 이 이름과 의미는 TIN combat binding이지 BLACK SOULS 2 semantics에 대한 사실 주장이 아니다.
- `AP` label, `AP` resource, generic red bar, `condition_exposure` 같은 두 번째 alias는 만들지 않는다. 의미가 확인되지 않은 display를 보수적으로 재현하지 않는다.
- player combat band에는 HP, MP, authored status만 둔다. action slot은 전용 bar나 AP imitation 대신 combat command footer의 `행동 n` text로 표현한다.
- 두 bar는 combat active 동안만 나타난다. dialogue, document, field, aftermath에 복제하지 않는다.

### 4.4 Target selection

A~H에는 target focus/cancel 화면이 없으므로 다음 TIN 규칙으로 고정한다.

- enemy가 하나이면 별도 target list를 열지 않고 command confirm 뒤 바로 target intent를 만든다.
- enemy가 둘 이상이면 enemy stage 위에 focus 가능한 target marker를 띄운다.
- target focus 순서는 encounter `encounter_slot` 순서이며 wrap하지 않는다. HP, 화면 거리, drawing order로 정렬하지 않는다.
- target mode 진입 시 이전 valid target focus를 복원한다. 이전 대상이 없거나 유효하지 않으면 첫 valid slot으로 간다. encounter data의 primary target은 previous focus가 없을 때의 시작점으로만 쓴다.
- keyboard/gamepad navigation은 target marker 사이의 논리 순서를 따른다. mouse hover-only target selection은 금지한다.
- target focus는 outline 두께, 작은 internal fill, position marker로 표시한다. enemy tint만 바꾸지 않는다.
- focusable이되 유효하지 않은 대상은 marker와 disabled 표시를 분리해 남기고, confirm은 state를 바꾸지 않는다. dead/flee/remove된 대상만 focus 순서에서 빠진다.
- confirm은 validated target intent를 만들고, cancel은 command focus로 돌아간다. cancel은 HP/MP, action slot, scheduler state를 소비하지 않는다.
- target이 resolve 전에 dead가 되면 invalid intent를 버리고, `01` §7.2에 따라 다음 slot, 이전 slot 순서로 첫 valid actor를 찾는다. valid actor가 없으면 target mode를 취소하고 action list로 돌아간다. stale enemy pointer를 유지하지 않는다.

### 4.5 Action resolution과 feedback

- command → optional submenu → target intent → queued action → domain resolution → result projection 순서를 고정한다.
- command navigation과 target selection 중에는 combat mutation을 하지 않는다.
- action queue는 action object와 target/resource cost를 먼저 만들고, resolution 단계에서만 world state를 변경한다.
- hit, miss, critical, guard, dodge, break, status application, resource change, phase transition은 actor와 combat band의 짧은 visual/audio feedback으로 표시한다.
- hit flash, miss cue, critical emphasis, break pulse, status token은 서로 다른 channel을 사용한다. 한 visual effect가 모든 결과를 대신하지 않는다.
- combat log를 상시 화면에 만들지 않는다. 긴 결과 기록이 필요한 action은 combat-local result beat으로 authored한다.
- victory는 combat band와 enemy state가 결과를 보여준 뒤 field/aftermath로 전환한다. failure는 전투를 되돌리는 animation 없이 8.4의 recovery presentation으로 전환하며, recovery type 선택과 death semantics는 `08`이 소유하고 이 문서에서 새로 만들지 않는다.

## 5. Dialogue presentation

### 5.1 World-preserving dialogue band

dialogue는 world를 축소한 full-screen menu가 아니다. player, NPC, nearby world object의 위치를 유지한 채 하단 band를 띄운다.

1280×720 기준 composition target은 다음과 같다.

| Element | Logical bounds | Rule |
|---|---:|---|
| dialogue band | x=0, y=552, w=1280, h=168 | world를 가리지 않는 dark translucent band |
| portrait | x=28, y=572, w=88, h=88 | speaker를 빠르게 판별하는 보조 asset |
| speaker name | x=136, y=568, w=420, h=32 | portrait/text와 같은 reading order |
| dialogue body | x=136, y=602, w=820, h=96 | 최대 3 lines, line height 30 |
| advance affordance | x=1188, y=680 | 다음 text/page 존재 시 나타나는 down triangle |

- choice가 없을 때 body width는 1080 logical px까지 확장할 수 있다. choice가 있으면 choice rail과 겹치지 않도록 820 px를 넘기지 않는다.
- band는 어두운 유색 내부면과 얇은 구조선을 사용한다. 테두리 마모 효과를 넓은 정보면에 일괄 적용하지 않는다.
- body text는 밝은 저채도 paper/ink 대비를 사용한다. speaker name은 한 줄로 authored content가 보장되어야 한다.
- portrait는 gameplay identity를 보조하지만 NPC domain truth가 아니다. portrait가 없는 actor도 dialogue를 진행할 수 있다.
- dialogue page가 끝나면 down triangle이 한 번 pulse하고, 다음 input을 기다린다. `Z` 같은 긴 설명문이나 key hint를 표시하지 않는다.
- dialogue active 동안 field movement와 combat command를 잠근다. dialogue close 뒤에는 이전 field focus로 돌아간다.

### 5.2 Dialogue state

| State | 화면과 focus | 입력 |
|---|---|---|
| `entering` | band가 나타나되 world focus는 잠시 유지 | 입력을 짧게 대기 |
| `normal` | speaker와 현재 page 표시 | advance/cancel 가능 |
| `waiting_advance` | down triangle 표시 | advance가 다음 page로 이동 |
| `choice` | dialogue body와 우측 choice rail 표시 | choice navigation/confirm/cancel |
| `closing` | band와 world를 원래 상태로 복귀 | 입력을 소비하지 않음 |
| `returned` | field focus 복원 | field input 재개 |

- dialogue close는 speaker/NPC 상태를 바꾸지 않는다. 실제 consequence는 별도 authored result beat에서 적용한다.
- portrait, name, text는 page content에서 분리된다. portrait 변경이 dialogue state를 덮어쓰지 않는다.

## 6. Choice presentation

### 6.1 Choice rail

choice는 dialogue right rail에 vertical list로 표시한다. world-preserving dialogue의 관계를 유지하되 16:9 추가 폭을 사용한다.

1280×720 기준:

- panel: x=968, y=64, w=280, h=464
- row start: x=988, y=104
- row height: 48 logical px
- visible rows: 최대 6개
- row gap: 0
- one-line label, bottom margin 16

`ChoiceSet`은 한 panel에 들어가는 최대 6개의 선택을 authored content로 제한한다. 더 많은 선택은 authored page로 나누며, focus가 offscreen으로 사라지지 않게 한다.

### 6.2 Semantic과 presentation class 분리

- `semantic_tags`는 domain/authored data가 소유한다. `presentation_class`는 그 의미를 색이나 모양으로 번역하는 별도 field다.
- `presentation_class` canonical enum은 `neutral`, `official`, `confidential`, `hostile`, `extreme`, `narration`, `unavailable`, `result`다. choice는 `neutral|extreme|unavailable|result`만 사용하고, unavailable은 class가 아니라 `availability=false`의 별도 state다.
- A~H에서 확인된 빨간 선택은 `extreme` presentation class로 기록한다. `extreme`는 `danger`, `unavailable`, `irreversible`을 자동으로 뜻하지 않는다.
- `extreme` row는 red text와 narrow red vertical rule을 사용한다. focus를 추가할 때 bright internal fill과 focus marker가 함께 나타나므로 red-only가 아니다.
- 그 밖의 class는 paper/ink와 중립 구조선을 사용한다. danger나 성적 의미를 색 이름으로 추측하지 않는다.
- unavailable은 presentation class가 아니라 `availability`가 false인 별도 state다. 낮은 명도, horizontal rule, 짧은 reason text로 표시하고 focus navigation에서 건너뛰지 않는다. focusable이지만 confirm은 world/NPC/relationship/inventory를 바꾸지 않는다. reason은 floating tooltip이 아니라 row 안의 text/shape로 읽힌다.
- disabled와 focused를 같은 opacity/line state로 만들지 않는다.

### 6.3 Focus, confirm, cancel, result

- choice panel이 열리면 authored 순서의 첫 row에 focus를 둔다. unavailable row도 그 자리에 focusable disabled로 남는다. 이전 conversation page가 있으면 그 page의 `return_focus`를 우선한다.
- 위/아래 navigation은 선택 intent만 바꾼다. available condition, immediate result, delayed result는 confirm 전에 실행하지 않는다.
- confirm은 choice를 validated command로 만든 뒤 domain result를 적용한다.
- cancel은 선택을 소비하지 않고 이전 dialogue page로 돌아간다. 이전 page가 없으면 conversation을 닫고 field focus를 복원한다.
- `irreversibility_class`가 irreversible인 choice는 authored confirmation beat을 가질 수 있다. 이 beat은 generic warning이 아니라 해당 choice의 authored consequence를 보여 준다.
- result 뒤에는 stale choice row에 focus를 남기지 않는다. 다음 dialogue beat, aftermath band, field target, 안전한 no-focus 중 하나를 명시적으로 선택한다.
- choice 결과는 dialogue 한 줄만 바꾸지 않는다. NPC, quest, relationship, clock, world prop, route 중 실제 변경 surface가 presentation에 투영되어야 한다.

## 7. Document presentation

### 7.1 Reading layer

D~F는 world 위에 어두운 reading layer와 큰 흰 글자를 사용한다. TIN은 text를 이미지에 구워 넣지 않고 authored page data와 native text rendering으로 만든다.

1280×720 기준:

- outer reading surface: x=128, y=64, w=1024, h=592
- inner text safe area: x=184, y=120, w=912, h=480
- body size: 24 logical px
- line height: 32 logical px
- maximum body lines: 9
- title이 있으면 title size 32 logical px, line height 40, body line budget을 8줄로 만든다. 이 축소는 layout 규칙이며 content cap 9줄은 바꾸지 않는다.
- 9줄은 1280×720에서 16:9로 재튜닝한 page 예산의 상한이다(`06` §5.14 `reading.max_lines_per_page`). 9줄 body는 9 × 32 = 288 logical px로 inner safe area 안에 남고 title까지 넣어도 하단 page affordance와 겹치지 않는다.
- page advance affordance: reading surface 하단 중앙의 down triangle
- 기본 page counter는 표시하지 않는다. authored content가 page position을 필요로 할 때만 별도 text field를 추가한다.

- world는 surface 주변에 남겨 두며 55~70% dimming으로 silhouette와 위치 관계를 유지한다. document가 시작된 뒤에도 field movement, combat command, global menu는 잠긴다.
- `DocumentDefinition.pages[]`가 text와 page intent의 진실이다. UI의 자동 overflow를 page 분할로 사용하지 않는다.
- page가 끝나면 advance로 다음 page에 간다. 마지막 page의 close/next action은 authored return focus를 따른다.
- document close는 이전 field focus와 world state projection으로 돌아간다. close가 document availability를 제거했다면 안전한 field fallback을 적용한다.

### 7.2 Page pacing

- 한 page는 현재 logical 기준 9줄을 넘지 않도록 authored content에서 검증한다. `pages[].lines`가 9를 넘으면 `06` §5.14의 `document_page_overflow` validation error다.
- 긴 문서는 semantic page 단위로 나누고, page count를 늘리는 이유가 독해 pacing인지 information hierarchy인지 content brief에 기록한다.
- 자동 pagination, random line wrap, player-entered name의 overflow를 runtime의 첫 fallback으로 삼지 않는다. 9줄 초과를 화면에서 잘라내거나 다음 page로 넘겨 처리하지 않는다.
- dialogue와 document의 down triangle은 같은 advance affordance 문법을 공유할 수 있지만, 서로 다른 content type과 close policy를 가진다.

### 7.3 Corruption presentation

G의 corruption은 별도 authored `CorruptionRule`로 만든다. 매번 random typo를 생성하지 않는다.

| Corruption state | 표현 |
|---|---|
| normal | 안정된 line break와 밝은 본문 |
| red span | authored token span의 red treatment와 narrow rule |
| glyph break | authored token의 intentional glyph replacement/offset |
| line split | authored line boundary의 비정상적 분할 |
| combined | 위 효과를 authored 순서와 token 범위에 따라 결합 |

- corruption state는 document content와 presentation effect를 분리한다. domain은 `document_id`, `page_id`, `corruption_rule_id`, state transition만 저장한다.
- pagination은 corruption 전후에도 유지한다. 깨진 문자 때문에 다음 page로 넘어갈 수 없게 하지 않는다.
- red-only communication을 금지한다. 색 변화와 함께 rule, glyph, line, spacing 중 하나가 바뀐다.
- reduced-motion/accessibility mode가 제공되면 의미 변화와 pagination은 유지하면서 shake, flicker, rapid replacement만 줄인다.
- 원작의 exact glitch sequence, corruption string, page text는 복제하지 않는다.

## 8. World narration과 aftermath presentation

C의 world narration과 H의 aftermath는 같은 world 위의 어두운 band를 사용하지만 authoring semantics가 다르다.

### 8.1 Narration beat

- band: x=0, y=560, w=1280, h=160
- text: x=80, y=596, w=1120, h=88
- portrait 없음
- choice 없음
- body 최대 2 lines; 더 긴 정보는 authored page sequence로 처리
- player, NPC, target은 band 뒤 world에 계속 보인다.

Narration은 사건의 현재 state를 설명하거나 unpack한다. narration node가 event ID, choice consequence, world mutation을 소유하지 않는다.

### 8.2 Aftermath

aftermath는 사건 결과가 world state에 적용된 뒤 같은 장소에서 보여 준다.

- player와 target이 같은 field frame에 남는다.
- blood, trace, damaged prop, absent body, opened route, changed NPC presence는 world object 또는 authored encounter state로 표시한다.
- clean quest log, menu, result summary로 바꾸지 않는다.
- narration band는 결과를 한 번 확인시키는 beat이며, aftermath world state를 대신하지 않는다.
- target이 사라졌거나 route가 바뀌면 same region의 authored revisit variant를 보여 준다. 오래 이동해서 consequence를 설명하지 않는다.
- irreversible event는 dialogue flag만 남기지 않는다. 실제 변경된 world/NPC/object/relationship surface가 field와 revisit presentation에 나타난다.

### 8.3 Aftermath focus와 return

- aftermath가 끝나면 target이 유효하면 target, 아니면 event origin, 다음으로 nearest interactable, 마지막으로 no focus 순으로 복귀한다.
- removed target의 stale portrait, choice row, interaction ring을 남기지 않는다.
- 재방문 시 초기 world state가 아니라 authored aftermath state를 우선한다.
- aftermath audio sting이 끝난 뒤 region ambience로 복귀한다. combat loop나 dialogue voice를 다음 field state에 누출시키지 않는다.

### 8.4 Recovery presentation

death와 recovery의 결정은 `08_SAVE_DEATH_AND_RECOVERY.md`가 소유한다. presentation은 recovery type별로 다른 화면, 버튼 목록, 결과 summary를 만들지 않는다.

- canonical recovery type은 7개다: `checkpoint`, `respawn`, `clone`, `reincarnation`, `loop`, `immortality`, `institutional_reentry`. `crown_alignment`는 recovery type이 아니라 world write다.
- recovery 결과는 전용 결과 화면 대신 **변경된 같은 world**로 보여 준다: 새 continuity에 속한 actor, filed record, 새 route/surface, 남은 debt가 실제 world에 투영된다.
- 7개 type이 남기는 continuity 차이는 NPC presence, dialogue revision, revisit variant, document availability, route 표면의 차이로 읽힌다. presentation이 continuity layer를 직접 계산하거나 이름 붙인 요약을 띄우지 않는다.
- `recovery_unavailable`은 임의 respawn으로 바꾸지 않는다. world institution의 실패 surface를 보여 주고 authored reset affordance만 제공한다.
- recovery 진입과 복귀는 gameplay input을 잠갔다가 safe focus를 정확히 한 번 활성화한다. 전투를 되돌리는 animation으로 결과를 설명하지 않는다.
- recovery audio는 `combat_failure` sting과 region ambience 복귀만 담당하고 recovery type별 theme을 붙이지 않는다.

## 9. Focus와 selection 통합 계약

| Focus state | 표시 | navigation | return rule |
|---|---|---|---|
| `field_interactable` | in-world outline + marker | nearest/authored order, disabled도 focusable | close 시 semantic target 복원 |
| `dialogue_page` | current page + advance affordance | next/cancel | previous page 또는 field focus |
| `choice` | internal fill + structure line + marker | up/down, confirm, cancel, unavailable도 focusable | result beat 또는 dialogue page |
| `document_page` | text block + page affordance | next/close | previous field focus |
| `combat_command` | command row의 fill/line/marker | up/down, confirm, back, disabled도 focusable | parent command 또는 combat root |
| `combat_target` | target outline + marker + position | encounter slot order, confirm, cancel | originating command |
| `combat_action` | queued action state + result projection | resolution 동안 input lock | command focus |
| `aftermath_origin` | changed prop/target marker가 남을 때만 표시 | normal field navigation | nearest valid focus |
| `recovery_surface` | authored recovery surface의 world 변화 | normal field navigation | nearest valid focus |

모든 선택 가능한 화면은 다음을 만족한다.

- 현재 focus가 무엇인지 색·위치·형태·선 중 최소 두 channel로 읽힌다.
- disabled/unavailable도 focusable이고 navigation에서 건너뛰지 않는다. focus와 disabled를 두 channel로 분리해 읽힌다.
- mouse hover가 없어도 keyboard/gamepad로 같은 대상에 접근할 수 있다.
- navigation 순서가 screen type마다 고정되어 있고 wrap하지 않는다.
- focus 대상이 삭제·사망·제거되어 focus가 invalid가 되었을 때 안전한 다음 focus가 정의되어 있다. 이 복원 규칙과 disabled 자동 skip 금지는 서로 다른 규칙이다.
- focus가 단순히 색이 조금 달라지는 상태로만 구현되지 않는다.
- red/extreme presentation class와 focus presentation class를 혼동하지 않는다.

## 10. Persistent Shell HUD 금지

다음은 field, dialogue, document, combat 어느 상태에서도 상시 표시하지 않는다.

- 좌상단 현재 공간명·자동저장·진행 상태
- 우상단 Menu/Journal 버튼
- 상시 key hint 또는 조작법 문장
- debug label, authoring status, file path
- 개발 toolbar
- combat resource band의 field 복제본
- 빈 `ColorRect`/`Label`을 world object의 대체로 사용하는 presentation

Shell은 사용자가 Esc 등으로 호출했을 때만 나타난다. Shell을 닫으면 Top-down Action-RPG module의 마지막 유효 focus와 field/combat/doc state로 복귀한다. Shell의 기술적 영속성은 화면 HUD 계약이 아니다.

## 11. 현재 GPT 이미지 자산 경계

### 11.1 현행 제작 모델

현재 제작 기준은 다음 순서의 독립 작업이다.

1. `docs/art/PERSONAL_STYLE_CORE.md`
2. `docs/art/projects/top_down_action_rpg/PROJECT_ART_LAYER.md`
3. 해당 자산군 brief
4. 해당 자산군의 active Gold Standard manifest
5. 편집 작업이면 원본과 유지할 영역
6. 실제 게임 화면 검수와 사용자 승인

현재 저장소의 `docs/art/` 구조나 `assets/art/top_down_action_rpg/` 디렉터리를 이 run에서 만들지 않는다. 실제 Kit 제작 시 해당 자산군을 처음 사용할 때 workflow가 정한 경로에 brief와 manifest를 만든다.

### 11.2 Style Reference의 권한

- `docs/research/visual_reference/user_style_A.png`와 `user_style_B.png`는 영구 Style Reference다.
- A는 안면 능선, 얼굴 명암 면, 피부·큰 색면의 내부 붓결, 머리카락 덩어리의 밝기 변화에만 사용한다.
- B는 선 강약, 의상 구조선, 실루엣 정리, 인물/배경 밀도 대비, 배경 덩어리의 콜라주성에만 사용한다.
- A/B의 얼굴형, 헤어스타일, 구체 모티프, 의상 디자인, pose, 배경, 정확한 색 조합은 복제하지 않는다.
- `user_fps_C.png`는 Rule Rewrite의 1인칭 camera reference이므로 이 Kit의 presentation source로 사용하지 않는다.
- A~H 캡처는 gameplay screen grammar evidence이지 art source나 Gold Standard가 아니다.

### 11.3 GPT와 후처리 경계

- GPT Image, `image_gen`, 사용자가 허용한 생성형 도구는 구체적인 이미지 제작·편집을 요구하는 별도 run에서만 호출한다.
- 이 run에서는 이미지 생성, 편집, 재생성, 후보 보존, approved 복사를 하지 않는다.
- GPT output은 최종 그림이다. 사람의 재작화, 수동 선 보정, 자산별 색칠 보정은 제작 공정에 넣지 않는다.
- 허용된 기계적 후처리는 투명화/배경 분리, crop, canvas/pivot 정렬, layer 분리, resize, atlas packing, color profile 변환, 결정론적 alpha matte와 edge 정리로 한정한다.
- 정체성과 구도가 맞지만 국소 오류인 후보는 사용자 요청 뒤 GPT 국소 편집으로 처리하고, 전체 시각 문법이 틀린 후보는 사용자 요청 뒤 재생성한다.
- 생성 결과는 언제나 candidate다. agent/model은 Gold Standard를 승격하지 않는다. 승격·교체·폐기는 사용자의 명시적 승인과 manifest 기록이 필요하다.
- 출처, 모델/도구, 입력 reference, prompt 또는 작업 파일, 생성일, license/사용 권리, 후처리를 manifest와 함께 기록한다.
- 원작 UI, font, portrait, sprite, frame, checker pattern, 문구, watermark를 asset으로 가져오지 않는다.

## 12. Asset family briefs

아래는 이 Kit에서 활성화할 자산군의 **미래 brief 내용**이다. 이 절은 brief 파일이나 asset 파일을 생성하지 않는다. 각 brief는 `docs/IMAGE_ASSET_WORKFLOW.md`의 필수 필드를 모두 가져야 하며, 빠진 필드가 있는 상태로 생성 요청을 열지 않는다.

공통 필수 필드는 다음과 같다.

- asset ID와 실제 game state/use
- output size, file format, alpha, pivot, safety margin, layer 분리
- silhouette, pose, camera, lighting
- information priority와 focal point
- 유지할 요소와 변형할 요소
- source reference와 active Gold Standard
- 금지 요소
- 실제 게임 화면 검수 장면과 1280×720/1920×1080/2560×1440 acceptance
- background object를 쓴 경우 `증거·직접 상호작용`, `길찾기·상황 이해`, `분위기`의 명시 분류

### 12.1 `environment_background`

- **Use:** field hub, authored region, route, transition background, aftermath의 같은 world.
- **Production:** 2560×1440 opaque PNG, sRGB, 16:9. parallax가 필요하면 opaque base와 transparent layer를 별도 family file로 만든다.
- **Camera/composition:** orthographic top-down, fixed rotation, player route가 먼저 읽히고 상단 여백이 다음 destination을 설명한다. horizon/perspective distortion을 넣지 않는다.
- **Information priority:** 모든 주요 object를 위 세 단계 중 하나로 명시한다. evidence/direct interaction object는 실루엣과 경계를 우선하고, atmosphere object는 대비를 낮춘다. 모델이 importance를 추론하지 않는다.
- **Keep/transform:** A/B의 brush, value separation, density contrast만 참고한다. TIN의 recovery/recognition/authority protocol 공간을 새로 authored한다. BLACK SOULS 2의 landmark, interior, map, symbol은 사용하지 않는다.
- **Forbidden:** baked text, HUD, menu frame, readable logo, character portrait, original checker/frame, watermark, unknowable evidence object, excessive line density that hides route.
- **QA:** field normal/focus, combat transition, aftermath/revisit, long route, three target resolutions. 16:9에서 world focal point와 interactable hierarchy가 유지되어야 한다.

### 12.2 `gameplay_sprites`

- **Use:** player, neutral NPC, institution actor, interactable prop의 field presentation.
- **Production:** transparent PNG, source 2× logical size, stable foot/contact pivot, 32 logical px safety margin. player baseline display height는 96 logical px로 시작한다. NPC/prop의 footprint와 pivot은 각 brief에 고정한다.
- **Direction/action contract:** Reference Game actor는 네 cardinal facing의 idle/walk/interact set을 가지며, missing direction은 placeholder로 채우지 않는다. NPC와 prop는 authored footprint를 따른다. dialogue portrait와 field sprite는 별도 asset이다.
- **Render translation:** 큰 일러스트를 축소하지 않는다. 구조선 수를 줄이고 2단 명암과 최소 brush detail을 사용한다. small text/icon은 sprite에 넣지 않는다.
- **Keep/transform:** A의 얼굴/큰 면 brush와 B의 silhouette/density만 제한적으로 사용한다. character identity, clothing, motif, exact palette는 TIN project layer가 새로 정한다.
- **Forbidden:** original sprite, baked labels, 8-direction assumption without authored brief, mismatched pivot, contact shadow that changes collision, placeholder rectangle/label.
- **QA:** field focus, dialogue world position, interact success/failure, 4 facing transitions, animation-safe contact, 720p/FHD/QHD.

### 12.3 `enemy_encounter`

- **Use:** positionless combat enemy, signature action, charge/tell, phase variant, break/exposure silhouette.
- **Production:** transparent PNG, source 2× logical size, center/ground-contact pivot, fixed combat camera. field cardinal facing set을 복제하지 않는다.
- **State contract:** baseline, signature action, telegraph, break/exposure, phase change를 서로 식별 가능한 state 또는 별도 layer로 만든다. UI bar가 enemy truth를 계산하지 않게 silhouette와 bar는 같은 domain projection을 사용한다.
- **Keep/transform:** silhouette clarity, stateful body opening/closing, role prop, motion signature를 새 enemy role에 적용한다. appearance-only weirdness는 금지한다.
- **Forbidden:** original enemy, copied charge animation, text/symbol in sprite, impossible pivot, effect that hides command rail, one universal break answer.
- **QA:** target focus, baseline/signature/phase, charge tell, break success/failure, victory/aftermath, three resolutions.

### 12.4 `combat_vfx`

- **Use:** hit, miss, guard, dodge, break, status, charge, resource change, target confirmation.
- **Production:** transparent PNG or native Godot effect, source 2× when raster, effect-origin pivot, 32 logical px safety margin, additive/normal layer metadata.
- **Information priority:** action result가 actor와 command state보다 먼저 읽히되, enemy body와 gauge를 가리지 않는다. decorative particles는 information object보다 뒤에 둔다.
- **Keep/transform:** TIN protocol/recovery/recognition vocabulary를 사용한다. original VFX, copied timing, screen-filling spectacle은 사용하지 않는다.
- **Forbidden:** baked damage numbers as the only result, permanent screen tint, unreadable flash, random confetti, effect that blocks world/command focus.
- **QA:** normal/hit/miss/critical/status/break/charge, reduced motion, repeated resolution, three target resolutions.

### 12.5 `portrait_dialogue`

- **Use:** conversation speaker identification, one-off state/reveal portrait where authored.
- **Production:** transparent PNG, 320×320 source, displayed 88×88 logical px in the standard dialogue band, 3/4 bust or authored equivalent, stable face anchor.
- **State contract:** identity portrait and optional expression state are authored. portrait variant가 domain state를 덮어쓰지 않는다.
- **Keep/transform:** A의 안면 능선/3단 명암, B의 hair mass/silhouette density를 제한적으로 사용한다. face type, hairstyle, costume, age, exact palette는 project layer가 정한다.
- **Forbidden:** baked name/dialogue, watermark, portrait copied from reference, unreadable low-resolution face, expression that falsely claims a domain fact.
- **QA:** dialogue at 1280 base, speaker identification without color, long name, portrait absent, return from choice/document.

### 12.6 `document_surface`

- **Use:** D~F reading layer의 paper/ink/edge surface, optional artifact material, post-read page transition.
- **Production:** 2560×1440 16:9 surface PNG if a raster surface is approved; text itself is native authored text, not baked. deterministic alpha/edge processing only.
- **Page/camera:** inner text safe area and 9-line page cap을 7.1의 document geometry와 일치시킨다. world dimming은 surface 안팎에서 일정해야 한다.
- **Corruption:** corruption rules own token span, red treatment, glyph break, line split. random text mutation, baked corruption string, unreadable final font는 금지한다.
- **Keep/transform:** TIN artifact가 institution/recognition/recovery protocol을 문서화하는 방식을 새로 authored한다. original letter, seal, page text, checker background는 사용하지 않는다.
- **Forbidden:** generated text, original document, random red-only span, pagination overflow, image that makes the page impossible to localize/read.
- **QA:** normal page 1/2/last, maximum line budget, corrupted page, close/reopen, all three resolutions, reduced motion/accessibility.

### 12.7 `ui_surface`

- **Use:** dialogue band, choice rail, world narration band, command rail, combat resource band, focus/selection surface.
- **Production:** native Godot Control/Theme와 vector shape first. raster가 필요하면 2× broad surface만 허용하고, text·focus marker·gauge를 image에 구워 넣지 않는다.
- **Render contract:** dark translucent internal surface, selective internal brush fill, clean small text, strong dark ink structure line, no universal worn border. broad information surface와 small glyph를 같은 brush로 칠하지 않는다.
- **Focus contract:** shape, line weight, fill, position marker, short motion 중 최소 두 channel을 함께 사용한다. red는 extreme class에만 쓰고 focus와 danger를 대신하지 않는다.
- **Keep/transform:** 개인 화풍 코어의 UI 렌더 문법과 project layer의 screen grammar을 사용한다. BLACK SOULS 2 frame, font, icon, exact panel shape는 복제하지 않는다.
- **Forbidden:** global RPG UI framework, default icon set, baked text, debug label, persistent shell, unreadable decorative brush, panel that becomes a button list.
- **QA:** initial/normal/focus/selected/disabled/closing, keyboard/gamepad, long text, 16:9, three resolutions, Shell open/close return.

### 12.8 `aftermath_prop`

- **Use:** H의 blood/trace, damaged object, missing/present actor, opened/closed route, revisit variant.
- **Production:** transparent PNG, source 2× logical size, stable world pivot, explicit `normal/trace/damaged/absent` state variant, 32 logical px safety margin.
- **State contract:** prop의 variant는 authored aftermath state에서 결정된다. post-read 또는 choice consequence가 domain을 바꾸기 전에 prop을 미리 보이지 않는다.
- **Keep/transform:** TIN world의 body/institution trace를 새 consequence로 authored한다. spectacle, copied blood placement, original event staging은 사용하지 않는다.
- **Forbidden:** permanent gore filter, random decal, visual-only consequence, prop that lies about route/NPC state, effect that obscures focus.
- **QA:** immediate aftermath, route/NPC state change, revisit, absence, long route, three resolutions.

### 12.9 비활성 자산군

- `rigging_full_body_parts`는 mixed cutout/message deformation을 실제로 선택하고 brief를 승인하기 전에는 만들지 않는다. 빈 디렉터리나 placeholder rig를 미리 생성하지 않는다.
- `investigation_screen`는 이 Kit의 첫 presentation slice에서 별도 investigation mode를 확정하지 않았으므로 활성화하지 않는다.
- UI icon family, stock photo collage, at-icons composition은 현재 제작 family가 아니다.

### 12.10 Art key registry and Gold Standard gate

`06`의 content는 art key 문자열만 보유하고 경로·색을 읽지 않는다. 이 Kit의 초기 art key registry는 다음과 같다.

```text
art_world_h0_undersign
art_world_r1_returning_kiln
art_world_r2_siltglass_commons
art_world_r3_bellhouse_hospice
art_world_r4_crownwell_archive
art_world_r5_glasswing_ordinal
art_world_r6_gristmarket_ward
art_world_r7_hollow_orchard
art_world_r8_folding_school
art_player_field
art_npc_core_portrait
art_npc_support_portrait
art_prop_route_marker
art_prop_recovery_anchor
art_prop_magic_concentration_device
art_effect_charge_tell
art_effect_break_window
art_effect_document_corruption
art_effect_portal_void_cut
art_effect_aftermath_trace
art_ui_brush_fill
art_ui_focus_marker
```

- 위 key는 asset ID가 아니라 presentation lookup key다.
- active Gold Standard는 이 run에서 생성하거나 승인하지 않는다.
- 실제 asset brief와 candidate가 없으면 presentation 구현은 해당 key를 `missing_art_asset`으로 명시적으로 보고한다. 임의의 placeholder image path를 생성하지 않는다.
- 유저가 asset 제작을 요청하면 `docs/IMAGE_ASSET_WORKFLOW.md` 순서로 brief → candidate → 실제 화면 검수 → 명시적 승인을 거친다.
- `art_ui_*`는 UI icon이 아니라 broad information fill/focus rule을 위한 visual language key다.

## 13. Module-local audio

### 13.1 소유권과 lifecycle

audio는 `modules/top_down_action_rpg/`가 소유하는 module-local presentation/audio surface에서 관리한다.

- module-local `AudioStreamPlayer2D` 또는 같은 module-local playback node를 사용한다.
- 새 global AudioManager, autoload, service locator, EventBus를 만들지 않는다.
- 이미 존재하는 host audio bus를 사용할 경우에는 기존 계약을 재검증하고, module-local bus를 새로 전역 등록하지 않는다.
- module exit 시 module-local loop, oneshot, timer, signal을 정리한다. 다음 module로 audio가 새지 않는다.
- audio stream의 source, license, 저자, attribution, tool provenance를 module-local manifest 또는 approved asset record에 남긴다.
- 이 run에서는 audio file을 생성·복사·구매·추가하지 않는다.

### 13.2 State별 audio mapping

| State/event | Audio behavior | 복귀 |
|---|---|---|
| `field_region_enter` | region ambience loop를 crossfade | field에서 loop 유지 |
| `field_focus_changed` | 짧고 반복하지 않는 focus marker cue | 다음 focus에서 새 cue |
| `field_interact_success` | interaction-specific response | dialogue/document/event로 |
| `dialogue_enter` | field ambience를 -6 dB duck하고 short cue | dialogue close 시 원래 level |
| `dialogue_page_advance` | page/turn cue; text 자체의 source of truth는 아님 | 다음 page |
| `choice_focus_changed` | 낮고 짧은 selection cue | 다음 row |
| `choice_commit` | 선택 class에 따른 distinct cue | result beat |
| `document_enter` | field ambience -9 dB duck, reading onset cue | document close |
| `document_page_advance` | page cue | 다음 page |
| `document_corrupt` | authored corruption onset cue | stable corrupted state |
| `combat_enter` | combat ambience/music transition, enemy arrival cue | combat |
| `combat_command_focus_changed` | category-specific short cue | next command |
| `combat_target_focus_changed` | target marker cue | next target |
| `combat_action_queued` | action identity와 cost를 보조하는 cue | resolution |
| `combat_resolution` | hit/miss/critical/status/break별 distinct cue | next command |
| `combat_victory` | result sting | aftermath/field |
| `combat_failure` | failure sting, recovery type별 theme 없음 | recovery surface |
| `recovery_applied` | rebuild된 field의 region ambience로 복귀, type별 theme 없음 | field focus |
| `aftermath_state_applied` | consequence sting 후 region ambience 복귀 | field/revisit |

- field와 combat ambience는 동시에 무한 재생하지 않는다. combat 시작 시 field loop를 crossfade/stop하고, combat 종료 후 aftermath를 거쳐 field loop를 복구한다.
- dialogue/document의 duck 값은 초기 mix tuning 값이다. critical information을 audio-only로 만들지 않으며 visual/text channel을 항상 유지한다.
- focus cue는 navigation마다 긴 loop를 만들지 않는다. 같은 focus에서 반복 재생하지 않고 state transition에만 한 번 재생한다.
- voiceover는 presentation 선택 사항이다. voice가 없어도 dialogue, choice, document, combat, aftermath가 완결되어야 한다.
- dialogue text, choice semantic, document corruption, combat result, recovery type의 source of truth는 audio가 아니다.

### 13.3 Audio acceptance

- module-local exit 후 loop, oneshot, duck가 남지 않는다.
- field→dialogue→document→field, field→combat→aftermath→field, combat failure→recovery→module exit를 각각 재생한다.
- canonical recovery type 7개 모두에서 ambience 복귀와 field focus 복귀 순서가 같고, type을 구분하는 theme이나 voice를 붙이지 않는다.
- audio off/mute 상태에서도 모든 정보와 focus가 visual/text로 판독된다.
- focus navigation, choice confirm, page advance, charge/break, hit/miss, aftermath에서 cue가 domain state와 어긋나지 않는다.
- 세 target resolution에서 audio cue timing과 visual state의 order가 유지된다.

## 14. Visual acceptance

### 14.1 필수 capture matrix

아래 상태를 1280×720, 1920×1080, 2560×1440에서 실제 캡처한다. isolated image만으로 PASS를 판정하지 않는다.

| Surface | Required states |
|---|---|
| field | normal, focus, focusable disabled/unavailable, interaction success, interaction failure, route/revisit |
| dialogue | entering, normal page, waiting advance, long page, closing, returned focus |
| choice | normal, neutral focus, extreme focus, focusable unavailable, confirm, cancel, result return |
| document | normal page, 9줄 최대 page, last page, corrupted page, close/reopen |
| combat | command normal/focus, focusable disabled command, submenu, `End Turn`, target normal/focus/cancel, queued action, hit, miss, critical/status, guard/dodge/break, victory, failure |
| aftermath | immediate trace/prop change, narration band, removed target, route change, revisit variant |
| recovery | failure intent, authored recovery surface, rebuilt field, safe focus return |
| shell | Esc open, Shell visible, close, return to prior module focus |

### 14.2 공통 PASS 조건

각 capture는 다음을 만족해야 한다.

- world focal point가 UI 장식보다 먼저 읽힌다.
- field에서 상시 Shell HUD가 보이지 않는다.
- dialogue와 document가 world 위치를 완전히 버리지 않는다.
- combat의 enemy, command focus, green timing, `target_hp_or_condition`, player band가 서로 겹치지 않는다.
- combat bar가 green timing과 `target_hp_or_condition` 두 개뿐이고, `AP` label과 generic red bar가 없다.
- focus/selection은 mouse hover 없이 찾을 수 있고, 색만으로 전달되지 않는다.
- disabled/unavailable이 focusable한 상태로 남아 있고, focus navigation이 이를 건너뛰지 않는다.
- extreme red choice와 focus, disabled, danger semantic이 혼합되지 않는다.
- long speaker name, long choice label, 9줄 최대 document page, corrupted text가 잘리지 않는다.
- document page가 9줄을 넘지 않고, 9줄 초과 content가 화면에서 자동 분할·잘림으로 처리되지 않는다.
- 16:9 adaptation에서 불필요한 letterbox나 비균일 scale이 없다.
- 1280×720에서 composition target이 유지되고, FHD/QHD에서 1.5/2.0배 logical geometry로 자연스럽게 확대된다.
- QHD에서 raster background와 sprite가 시각적으로 부족하지 않다. 필요하면 2× source를 사용한다.
- placeholder ColorRect/Label, world text stand-in, original asset, watermark, debug label이 없다.
- image family candidate는 hard gate를 통과했고, actual screen에서 user approval 전에는 Gold Standard로 기록하지 않는다.
- audio off 상태도 정보 전달과 focus 판독이 가능하다.
- gameplay domain state와 presentation-only focus/hover/tween을 save state에 섞지 않는다.

### 14.3 수동 visual play task

검수는 다음 순서로 수행한다.

1. field에서 shell을 호출하지 않고 현재 상호작용 대상을 찾는다.
2. field에서 focusable disabled 대상을 찾아 focus가 그 자리에 머무는지, confirm이 world state를 바꾸지 않는지 확인한다.
3. NPC를 열어 dialogue page와 choice focus를 이동한다.
4. neutral와 extreme choice를 각각 확인하고 cancel로 원래 dialogue page에 돌아온다.
5. unavailable choice에 focus가 닿을 때 건너뛰지 않고, focus와 disabled가 구분되며, confirm이 아무것도 바꾸지 않는지 확인한다.
6. choice를 confirm한 뒤 NPC, world prop, route 또는 relationship의 실제 변화를 재방문으로 확인한다.
7. document를 끝까지 읽고 9줄 최대 page, corrupted page, close/reopen state를 확인한다.
8. combat에서 command→target→resolution을 수행하고 green timing, `target_hp_or_condition`, player band, target focus, hit/miss/status/break를 확인한다. `AP` label과 두 번째 bar가 없는 것도 확인한다.
9. unavailable command에 focus가 닿을 때 건너뛰지 않는지, confirm이 unavailable reason만 바꾸는지 확인한다.
10. victory 또는 failure 뒤 aftermath/recovery에서 world state와 focus 복귀를 확인하고, failure가 canonical recovery type 7개 중 authored된 하나로 기록되었는지 확인한다.
11. 동일 task를 1280×720, 1920×1080, 2560×1440에서 반복한다.
12. audio를 mute한 뒤 위 task의 정보 전달과 focus를 다시 확인한다.
13. placeholder, persistent shell HUD, debug label, source asset, 승인되지 않은 Gold Standard candidate를 검색한다.

### 14.4 완료 증거와 현재 한계

완료 증거는 다음 산출물을 한 묶음으로 보관한다.

- A~H와 나란히 비교한 상태별 capture 목록
- 3개 해상도의 field/combat/dialogue/choice/document/aftermath/recovery capture
- focus, focusable disabled, cancel, return, long text, 9줄 page, corruption, revisit capture
- module-local audio event/mix/lifecycle 기록
- 각 asset family의 brief, candidate hard-gate 기록, provenance/license 기록
- 사용자가 실제 화면에서 최종 승인한 asset manifest

이 문서 작성 run은 위 capture, 구현, asset 생성, visual approval을 수행하지 않았다. 따라서 현재 상태는 **presentation contract written / asset production not started / user play review not started**이다. 자동 테스트나 계획 문서만으로 visual completion을 주장하지 않는다.

## 15. 금지 shortcut

- A~H 캡처를 world asset으로 사용하거나 원작 frame을 복제한다.
- 960×720 화면을 가로로 늘려 16:9를 만든다.
- field에 상시 HP/MP/`target_hp_or_condition`/HUD를 복제한다.
- dialogue/document/aftermath를 버튼 목록이나 full-screen modal로 대체한다.
- red를 focus, danger, unavailable semantic으로 재사용한다.
- domain node의 Label/ColorRect 값을 combat/choice/document의 source of truth로 삼는다.
- automatic pagination, random corruption, random consequence를 사용한다.
- document page를 9줄보다 길게 authored하거나 runtime에서 자동 분할·잘림으로 처리한다.
- focus navigation에서 disabled/unavailable을 건너뛴다.
- `AP` label이나 `AP` resource, generic red bar, 두 번째 bar alias를 만든다.
- recovery type을 버튼 목록, 결과 화면, type 이름 표기로 만든다.
- placeholder ColorRect/Label/ASCII로 world와 actor를 완성 처리한다.
- at-icons, Retired Prototype, original UI/asset을 현재 제작 기준으로 승격한다.
- 빈 asset family, 빈 Gold Standard, 빈 rig directory를 미리 만든다.
- image 생성/editing을 계획 문서 작성 권한으로 간주한다.
- GPT output을 사람이 다시 그려 완성한다.
- global audio manager, autoload, service locator, EventBus를 만든다.
- Shell을 상시 HUD로 만든다.
- focus 없는 클릭-only 선택을 만든다.
- support resolution capture 없이 presentation 완료를 선언한다.
- 사용자 play review 전 `final complete`을 선언한다.

## 16. 관련 정본

- [AGENTS.md](../../../AGENTS.md)
- [CONTEXT.md](../../../CONTEXT.md)
- [PROJECT_DECISIONS.md](../../../PROJECT_DECISIONS.md)
- [01 System / UX](01_SYSTEM_UX.md)
- [06 Authored Content and Data](06_AUTHORED_CONTENT_AND_DATA.md)
- [08 Save, Death and Recovery](08_SAVE_DEATH_AND_RECOVERY.md)
- [10 Tests and Acceptance](10_TESTS_AND_ACCEPTANCE.md)
- [World Constitution](../../../docs/research/top_down_action_rpg/WORLD_CONSTITUTION.md)
- [사용자 A~H evidence](../../../docs/research/top_down_action_rpg/USER_PLAY_REFERENCE_2026-09-25.md)
- [BLACK SOULS 2 통합 조사](../../../docs/research/top_down_action_rpg/BLACK_SOULS_2_RESEARCH.md)
- [Visual Direction](../../../docs/VISUAL_DIRECTION.md)
- [Image Asset Workflow](../../../docs/IMAGE_ASSET_WORKFLOW.md)
- [UI Workflow](../../../docs/UI_WORKFLOW.md)
- [Style and Camera Reference](../../../docs/research/visual_reference/STYLE_AND_CAMERA_REFERENCE.md)
- [GPT Image Game Art Pipeline Report](../../../docs/research/visual_reference/GPT_IMAGE_GAME_ART_PIPELINE_REPORT.md)
