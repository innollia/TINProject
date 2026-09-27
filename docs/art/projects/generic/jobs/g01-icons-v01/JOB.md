# g01-icons-v01 — 판타지 계열·장르 없는 아이콘 (아이템·장비·스킬·상태)

상태: **candidate.** 승인·반려는 사용자만 한다. 게임 코드·씬에는 연결하지 않았다.

## 근거

- 규칙: `docs/art/mass_production/GENERIC.md`(g01 담당: BS2 목록 보강 + 판타지 계열·장르 없는 아이콘·UI·효과·겹침 무늬), `COMMON.md`(그리는 규칙, 크기 통일, V1 기준 도구·팔레트).
- 목록: `docs/art/projects/generic/catalog/g01_list.md`(A → B → C).
- BS2: 이 컴퓨터에 BLACK SOULS II가 없어 보강은 건너뛰었다. `g01_bs2_inventory.md`의 g01 몫(아이콘 세트, 창틀·게이지 바탕·커서·감정 말풍선·전투 시작 전환, 칼·화살·소환·불꽃놀이·선 긋기·특수기·마법진, 안개·잡음·낙엽·거품·햇살·빛 원·시야 밖 어둠)은 전부 목록에 넣었다.
- 그림은 at-icons 모양을 잘라 겹친 조합으로만 만들었다. 글자·숫자·워터마크·원작 고유 요소 없음.

## 규격

| 항목 | 값 |
|---|---|
| 캔버스 | 128×128 투명 PNG 한 장씩, 평면 시점(무기는 대각선으로 눕힘) |
| 시트 | `output/_sheet/g01_icons_sheet.png` 한 줄 16개, 칸 128 + `g01_icons_sheet.json`(칸 번호 → 자산) |
| 화풍 | V1 도구의 윤곽선·명암·붓자국 그대로. 스타일 `icon`(3배 슈퍼샘플, 테두리 1.5px) |
| 그림 재료 | at-icons 모양 조각만: 원, 채운 사각형을 다각형·날카로운 사각형으로 자른 것, 물방울, 초승달, `stars`에서 떼어 낸 반짝별, 구름 등. 아이콘 하나를 통째로 그림으로 쓰지 않는다 |
| 스킬·상태 구분 | 스킬 = 청동 테 사각 판 + 종류색 바탕, 상태 = 은 테 원판 + 종류색 바탕 |
| 글자 | 없음(수면은 Z 대신 초승달·반짝별) |
| 색 | `recipes/palette_g01.json` = V1 `palette_h0_mood.json`의 모든 항목 그대로 + g01 추가 재질·색·스타일(금속, 물약, 보석, 음식, 천, 판 색, 효과 빛) |

## 자산

| 단계 | 자산 | 크기·프레임 | 설명 | 상태 |
|---|---|---|---|---|
| A | `icon_antidote` | 128×128 | Green antidote in a squat square bottle: paper label with two herb leaves, string at the neck. | 완료 |
| A | `icon_battle_axe` | 128×128 | Bearded battle axe: crescent steel head with back spike, iron socket with rivets, leather-wrapped haft. | 완료 |
| A | `icon_bread` | 128×128 | Crusty bread loaf with three light score marks and a small roll in front. | 완료 |
| A | `icon_breastplate` | 128×128 | Steel breastplate: centre ridge, bronze neck trim, iron pauldrons, leather belt with bronze buckle. | 완료 |
| A | `icon_coins_gold` | 128×128 | Gold coins: two short stacks (coin edges from the block extrusion) and one standing coin with a star mark. | 완료 |
| A | `icon_dagger` | 128×128 | Leaf-bladed dagger on the diagonal: ridge line, short bronze guard, wrapped grip, diamond pommel. | 완료 |
| A | `icon_helm_iron` | 128×128 | Closed iron helm: dome with steel crest, bronze brow band with rivets, eye slits and breathing holes. | 완료 |
| A | `icon_key_iron` | 128×128 | Old rusted iron key, trefoil bow, two collars, notched bit; lies diagonally. | 완료 |
| A | `icon_longbow` | 128×128 | Longbow on the diagonal: crescent wooden limb, taut string, leather grip, bone tips. | 완료 |
| A | `icon_longsword` | 128×128 | Longsword on the diagonal: pointed steel blade with fuller and edge light, bronze guard, wrapped grip, gem pommel. | 완료 |
| A | `icon_potion_blue` | 128×128 | Blue mana potion in a teardrop flask with a silver band and sparkles in the liquid. | 완료 |
| A | `icon_potion_red` | 128×128 | Round red healing potion: dark glass flask, cork, bronze neck band, liquid level and glint. | 완료 |
| A | `icon_scroll_sealed` | 128×128 | Rolled parchment scroll with a wine ribbon and a red wax seal hanging below. | 완료 |
| A | `icon_shield_round` | 128×128 | Round wooden shield: plank seams, faded wine bend, iron rim with bronze rivets, steel boss. | 완료 |
| A | `icon_skill_fireball` | 128×128 | Skill tile: fireball flying to the lower left, flame tongues trailing up-right, embers. | 완료 |
| A | `icon_skill_heal` | 128×128 | Skill tile: glowing green cross of light, two herb leaves, sparkles. | 완료 |
| A | `icon_skill_lightning` | 128×128 | Skill tile: zigzag lightning bolt falling from a dark cloud, pale core, sparks. | 완료 |
| A | `icon_skill_slash` | 128×128 | Skill tile: a bright steel crescent slash with two fainter trailing arcs and sparks. | 완료 |
| A | `icon_staff_orb` | 128×128 | Wooden mage staff: violet orb held by a bronze claw, arcane halo, cloth wrap, iron foot. | 완료 |
| A | `icon_status_burn` | 128×128 | Status badge: three flame tongues with a hot core and embers. | 완료 |
| A | `icon_status_freeze` | 128×128 | Status badge: ice crystal snowflake built from six ticked arms and a hexagon core. | 완료 |
| A | `icon_status_poison` | 128×128 | Status badge: green poison drop with a small bone skull, rising bubbles. | 완료 |
| A | `icon_status_sleep` | 128×128 | Status badge: pale crescent moon with sparkles (no letters). | 완료 |
| A | `icon_status_stun` | 128×128 | Status badge: three gold stars circling on a faint orbit, a small swirl below. | 완료 |
| B | `icon_amulet` | 128×128 | Dark iron amulet: teardrop pendant with a red stone and small spikes, on a silver chain. | 완료 |
| B | `icon_bomb` | 128×128 | Round black bomb: iron sphere with highlight, bronze cap, curled fuse with a burning spark. | 완료 |
| B | `icon_boots` | 128×128 | Pair of leather boots: tall shafts with buckled straps, dark soles, one boot slightly behind. | 완료 |
| B | `icon_crossbow` | 128×128 | Crossbow: wooden stock, curved steel prod with string, loaded bolt, iron trigger. | 완료 |
| B | `icon_elixir` | 128×128 | Golden elixir: round flask in a thin gold cage, glowing gold liquid with sparkles, crowned gold stopper with a garnet. | 완료 |
| B | `icon_gem_red` | 128×128 | Cut red gem: crown and pavilion facets in three tones, table highlight, sparkle. | 완료 |
| B | `icon_gloves` | 128×128 | Leather glove, palm facing out: four fingers, thumb, flared cuff with a bronze stud, stitch lines. | 완료 |
| B | `icon_herb_bundle` | 128×128 | Bundle of healing herbs: four leafy stems and a violet bud, tied with brown twine. | 완료 |
| B | `icon_meat_roast` | 128×128 | Roast drumstick: glazed browned meat with grill marks and a bone end. | 완료 |
| B | `icon_phoenix_feather` | 128×128 | Revival feather: long flame-coloured feather with notched vane, bone quill and a warm glow. | 완료 |
| B | `icon_ring_gem` | 128×128 | Gold ring with a blue gem held by prongs, sparkle. | 완료 |
| B | `icon_robe` | 128×128 | Mage robe: violet body flaring to the hem, wide sleeves, gold trim, wine sash with a gem clasp. | 완료 |
| B | `icon_shield_kite` | 128×128 | Kite shield: dark blue field, gold cross, steel rim, a few rivets. | 완료 |
| B | `icon_skill_guard` | 128×128 | Skill tile: steel heater shield in front of a pale protective arc. | 완료 |
| B | `icon_skill_ice` | 128×128 | Skill tile: an ice spear flying up to the right, frost shards and sparkles. | 완료 |
| B | `icon_skill_shadow` | 128×128 | Skill tile: void orb ringed by violet crescents and motes. | 완료 |
| B | `icon_spear` | 128×128 | Spear on the diagonal: leaf-shaped steel head, iron socket with a wine tassel, long wooden shaft. | 완료 |
| B | `icon_spellbook` | 128×128 | Closed spellbook: violet cloth cover, gold corner guards, arcane ring emblem with glow, bronze clasp, page edges. | 완료 |
| B | `icon_status_atk_up` | 128×128 | Status badge: small sword with a glowing red-orange up arrow. | 완료 |
| B | `icon_status_curse` | 128×128 | Status badge: a pale cursed eye with a violet slit iris and dripping shadow. | 완료 |
| B | `icon_status_def_up` | 128×128 | Status badge: small heater shield with a glowing blue up arrow. | 완료 |
| B | `icon_status_silence` | 128×128 | Status badge: speech bubble crossed by a red bar (no letters). | 완료 |
| B | `icon_warhammer` | 128×128 | War hammer: square iron head with a back spike, bronze bands, leather-wrapped haft. | 완료 |
| C | `icon_bone_material` | 128×128 | Two old crossed bones (crafting material), yellowed with grime. | 완료 |
| C | `icon_cloak` | 128×128 | Hooded travelling cloak: dark green wool with a deep hood, fold lines, bronze clasp. | 완료 |
| C | `icon_coin_pouch` | 128×128 | Leather coin pouch tied with a wine cord, frilled neck, silver coins spilling in front. | 완료 |
| C | `icon_crown` | 128×128 | Gold crown: band with five points tipped with pearls, red and blue gems on the band. | 완료 |
| C | `icon_crystal_ball` | 128×128 | Crystal ball: violet sphere with a pale inner swirl and glow, on a bronze stand with three claw feet. | 완료 |
| C | `icon_empty_bottle` | 128×128 | Empty tall glass bottle with a long neck, dust at the bottom and a bright glint. | 완료 |
| C | `icon_hourglass` | 128×128 | Hourglass: wooden top and bottom plates with posts, two glass bulbs, sand falling into the lower bulb. | 완료 |
| C | `icon_jade_pendant` | 128×128 | Eastern jade ornament: pale green jade disc with a centre hole, tied wine knot above, long silk tassel below. | 완료 |
| C | `icon_katana` | 128×128 | Eastern single-edged sword: long gently curved blade with a pale temper line, round dark guard, diamond-wrapped hilt. | 완료 |
| C | `icon_scimitar` | 128×128 | Scimitar on the diagonal: broad curved steel blade, short bronze guard, wrapped grip, round pommel. | 완료 |
| C | `icon_scythe` | 128×128 | Great scythe: long dark wooden snath with bone grips and a huge blackened crescent blade. | 완료 |
| C | `icon_skill_drain` | 128×128 | Skill tile: red life motes spiralling into a dark violet vortex. | 완료 |
| C | `icon_skill_earth` | 128×128 | Skill tile: ground splitting with jagged rock slabs thrown up and dust. | 완료 |
| C | `icon_skill_holy` | 128×128 | Skill tile: radiant golden eight-point star inside a halo ring with thin rays. | 완료 |
| C | `icon_status_confuse` | 128×128 | Status badge: three nested pink-violet crescents turning in a swirl with small sparkles. | 완료 |
| C | `icon_status_haste` | 128×128 | Status badge: double chevron pointing right with speed streaks (faster). | 완료 |
| C | `icon_status_regen` | 128×128 | Status badge: two green leaves inside a looping arrow (healing over time). | 완료 |
| C | `icon_treasure_map` | 128×128 | Treasure map: parchment sheet with rolled ends, coastline, little mountains, a dashed route and a red ring target (no letters). | 완료 |
| C | `icon_war_fan` | 128×128 | Iron war fan, half open: wine-red silk between iron ribs, gold edge, pivot rivet with a tassel. | 완료 |

## 결과 파일

- `assets/art/generic/jobs/g01-icons-v01/output/<asset>/<frame>.png` + `<frame>.json`(manifest: status candidate, 쓴 아이콘과 SHA-256, meta).
- 여러 프레임 자산은 `<asset>_sheet.png`(한 줄) + `<asset>_sheet.json`.
- `assets/art/generic/jobs/g01-icons-v01/output/_sheet/g01_icons_sheet.png`
- 확인용 모아 보기: `assets/art/generic/jobs/g01-icons-v01/preview/`

## 도구

V1 `h0-icon-mood-v02/tool` 전체(__pycache__ 제외)와 `palette_h0_mood.json`을 복사했다. 바꾼 점:

- `iconkit/icons.py`: `prefetch` 기본 workers 8 → 2 (세션 규칙: 도구 workers 2 이하). 그림 결과는 같다.
- `build.py`: 레시피의 `meta`(9칸 여백, 핫스팟, 이음 여부, 단계)를 manifest에 그대로 넣는다.
- `review_sheet.py`: `--label`(어두운 바탕용 글자색), `--wrap N`(N개마다 줄 바꿈).
- 추가 `g01kit.py`: 레시피 작성 도우미(원·날카로운 사각형·다각형·물방울·반짝별 조각, 묶음 회전·확대, 부채꼴, 꺾은선, 반지름 일정한 둥근 사각형, 프레임 태그) + `palette_g01.json` 생성. 렌더러는 그대로다.
- 추가 `g01_docs.py`: 이 문서들과 목록 상태 칸을 레시피·결과에서 다시 쓴다.
- 추가 `icon_sheet.py`: 한 줄 16개 아이콘 시트 + 칸 번호표.

다시 만들기(`tool` 폴더에서):

```
py -3 -B gen_icons.py --stage all
py -3 -B build.py --all
py -3 -B icon_sheet.py
```

## 진행

- [x] A 단계 (24개 레시피)
- [x] B 단계 (23개 레시피)
- [x] C 단계 (19개 레시피)
