# 상황 → 사건 매핑

**이 파일은 사람이 읽는 도우미다. 어떤 프로그램도 읽지 않는다.**
유일한 기계 입력은 `../audio_events.json` 이고, 유효한 사운드 목록은 거기 있는 것뿐이다.
여기에 값을 추가해도 렌더는 바뀌지 않는다. `../audio_events.json` 을 고친다.

## 왜 상황 단위로 나누는지

사운드 목록을 파일 이름이나 시스템 이름으로 나누지 않는다.
`footstep_01.wav`, `hit_sound.wav` 같은 이름은 6개월 뒤 아무도 못 찾는다.
`creature_attack` 는 언제 어느 상황에서 필요한지 알려 주는 이름이다.
그러니 각 항목에는 언제 필요한 상황이 적혀 있어야 하고, 그 상황이 곧 그 소드의 존재 이유다.

각 사건의 `description` 은 한 줄짜리 의도다. 나중에 고칠 때
"무엇을 고치는가"가 아니라 "왜 이 소리가 있었는가"부터 보게 하려고 쓴다.

## 세 Kit은 같은 축을 공유하지 않는다

같은 소리 문제를 세 Kit이 서로 다르게 소유한다. 그래서 이벤트 수와 길이가 다르다.

| Kit | 신호 축 | 총 길이 | 판단 기준 |
|---|---|---|---|
| A `sideview_ecosystem` | 신체의 통과 가능성 | 짧다. 많아도 2.4초 | 발과 착지는 발음, 경계는 긴장 |
| B `physics_puzzle_platformer` | 조합 | 중간 | 접촉, 마찰, 확인 |
| C `descent_exploration` | 지식과 선택 | 제일 길다 | 아래로 간다, 공기, 분기 |

Kit A는 게이트가 없으므로 실패 순간이 없다. 그래서 `frustration_unsolvable` 가 없다.
Kit C는 지식이 쌓이므로 수집과 소모가 서로 다른 소리로 갈라져야 한다.
Kit B는 물체가 손에 있으므로 접두/해제/충돌이 삼중으로 갈라진다.

## Kit A — `sideview_ecosystem` (16)

| 상황 | 사건 |
|---|---|
| 발이 닿는 표면이 다르다 | `footstep_stone`, `footstep_mud`, `footstep_shallow_water`, `footstep_wood` |
| 몸 전체가 착지한다 | `body_land` |
| 무언가 나를 본다 | `creature_alert` |
| 무언가가 나를 때린다 | `creature_attack` |
| 무언가가 죽는다 | `creature_death` |
| 내가 들킨다 | `player_noticed` |
| 나는 안 들켰다 | `player_ignored` |
| 쉼터에 들어간다 | `shelter_enter` |
| 잠든다 | `sleep` |
| 깬다 | `wake` |
| 물에 들어간다 | `water_enter` |
| 물에서 나온다 | `water_exit` |
| 비가 온다 | `rain_onset` |

가장 중요한 짝은 `player_noticed` / `player_ignored` 다.
이 게임에서 무서운 것은 들킨 순간이므로, 안 들킨 쪽은 소리를 거의 내지 않는다.
`player_ignored` 를 진짜 무음에 가깝게 두면, `player_noticed` 가 충격이 된다.
둘은 같은 밴드로 만들지 않는다.

`water_enter` / `water_exit` 는 방향이 있어야 하므로 길이를 일부러 다르게 뒀다(0.8 / 0.7).

## Kit B — `physics_puzzle_platformer` (13)

| 상황 | 사건 |
|---|---|
| 물체를 잡는다 | `object_grab` |
| 물체를 놓는다 | `object_release` |
| 부딪힌다 | `impact_soft`, `impact_medium`, `impact_hard` |
| 도구를 쓴다 | `tool_use_strike`, `tool_use_scrape`, `tool_use_insert` |
| 조건이 만족된다 | `goal_satisfied` |
| 출구가 열린다 | `portal_open` |
| 더 이상 손이 없다 | `frustration_unsolvable` |
| 레벨이 시작된다 | `level_start` |
| 레벨이 끝난다 | `level_clear` |

`impact_*` 3종은 물성 축이다. 강도를 뒤에 붙인 이름이라 판정이 아니라 결과다.
Kit이 authored object마다 강도 티어를 붙이면 그-tier 소리를 고른다.

`tool_use_*` 3종은 **도구 이름이 아니라 물리적 작용**이다(strike / scrape / insert).
도구 이름으로.patch를 늘리면 안 된다. 도구가 늘어도 이 3개면 커버된다.
어떤 도구를 어느 작용에 넣을지는 Kit B가 정한다.

`frustration_unsolvable` 는 힌트로 들리지 않아야 한다.
`min_interval_seconds` 가 4초라서 폭탄처럼 반복되지 않는다.

## Kit C — `descent_exploration` (9)

| 상황 | 사건 |
|---|---|
| 한 층 내려간다 | `descent_step` |
| 크게 떨어진다 | `descent_deep` |
| 무언가를 얻는다 | `resource_collect` |
| 무언가를 쓴다 | `resource_spend` |
| 공기가 거의 없다 | `breath_critical` |
| 분기 A / B / C | `ending_a`, `ending_b`, `ending_c` |
| 지상으로 올라온다 | `surface_return` |

`ending_a/b/c` 는 **같은 길이, 같은 포락선, 다른 음높이 중심**이다.
이렇게 해야 듣는 사람이 글자를 읽지 않고 셋을 나열할 수 있다.
길이를 다르게 하면 순서와 중요도가 섞여서 Compare가 아니라 순위처럼 들린다.

`descent_step` 은 가장 자주 나올 사건이다. 0.4초를 넘기지 않는다.
여기가 아니라면 게임이 30분 안에 지루해진다.

## shared / UI (5)

| 상황 | 사건 |
|---|---|
| 메뉴가 열린다 | `menu_open` |
| 메뉴가 닫힌다 | `menu_close` |
| 확정한다 | `confirm` |
| 되돌린다 | `cancel` |
| 포커스가 옮겨간다 | `focus_move` |

`menu_open` / `menu_close`, `confirm` / `cancel` 은 각각 **같은 길이에서 반대 방향**으로 만든다.
한 개의 작동처럼 느껴져야 하는 쌍이기 때문이다.

`focus_move` 는 프로젝트에서 가장 조용한 사건이다(-16 dB, 0.14초).
포커스가 자주 움직이는 곳에서 이 소리가 시끄러우면 UI 전체가 시끄러워진다.
