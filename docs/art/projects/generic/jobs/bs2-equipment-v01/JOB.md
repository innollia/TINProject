# bs2-equipment-v01 — BLACK SOULS 계열 장비/소품 에셋 공장

- 작업자: 그림 에셋 담당 (opencode 세션)
- 저장소: `C:\projects\TINProject`, 브랜치 `kit/05-stone-story-rpg` (커밋/푸시 안 함)
- 소유 경로: `assets/art/generic/jobs/bs2-equipment-v01/**`, `docs/art/projects/generic/jobs/bs2-equipment-v01/JOB.md`
- 파이프라인: `tool/build.py` (수정 안 함) + `recipes/*.json` → `output/<asset>/<asset>.png`
- 팔레트: `recipes/palette_h0_mood.json` (materials만 사용)
- 상태: 전부 `candidate`. 승인은 사용자만.
- 도구: 레시피는 `_gen/*.py`가 JSON으로 내보낸다. 내용물은 손으로 쓴 데이터.

## 규칙 요약
- 장비/문장/보물 canvas `[512,512]` pivot `[256,256]`, 문서 canvas `[1024,1024]` pivot `[512,512]`
- 가장자리에서 32px 이상 안쪽
- 아이콘 1장 그대로 금지 → 2~5개 crop 겹침
- 녹·때 = `kind:"wash"` + `blend:"multiply"`
- 글자/숫자 없음. 앨리스 계열 없음. BS2 게임 폴더 안 열람.
- 몸 조각: 병에 든 눈알, 이빨, 뼈까지만

## A. 무기 (1–36)
- [x] 1 녹슨 장검 `eq_w01_rusted_longsword`
- [x] 이 빠진 장검 `eq_w02_chipped_longsword`
- [x] 기사단 장검 `eq_w03_crusader_longsword`
- [x] 처형인 대검 `eq_w04_executioner_greatsword`
- [x] 검은 대검 `eq_w05_black_greatsword`
- [x] 곡도 `eq_w06_scimitar`
- [x] 단검 `eq_w07_dagger`
- [x] 의식용 단검 `eq_w08_rite_dagger`
- [x] 톱날 칼 `eq_w09_saw_knife`
- [x] 도살 칼 `eq_w10_butcher_knife`
- [x] 손도끼 `eq_w11_hand_axe`
- [x] 전투 도끼 `eq_w12_battle_axe`
- [x] 양날 도끼 `eq_w13_double_axe`
- [x] 철퇴 `eq_w14_iron_club`
- [x] 가시 곤봉 `eq_w15_spiked_club`
- [x] 전쟁 망치 `eq_w16_war_hammer`
- [x] 큰 쇠망치 `eq_w17_great_sledgehammer`
- [x] 곡괭이 `eq_w18_pickaxe`
- [x] 창 `eq_w19_spear`
- [x] 미늘창 `eq_w20_glaive`
- [x] 낫 `eq_w21_sickle`
- [x] 큰 낫 `eq_w22_great_scythe`
- [x] 쇠사슬 도리깨 `eq_w23_iron_flail`
- [x] 짧은 활 `eq_w24_short_bow`
- [x] 장궁 `eq_w25_longbow`
- [x] 석궁 `eq_w26_crossbow`
- [x] 화살 묶음 `eq_w27_arrow_bundle`
- [x] 부싯돌 권총 `eq_w28_flintlock_pistol`
- [x] 부싯돌 장총 `eq_w29_flintlock_rifle`
- [x] 나무 지팡이 `eq_w30_wooden_staff`
- [x] 해골 지팡이 `eq_w31_skull_staff`
- [x] 보석 지팡이 `eq_w32_gem_staff`
- [x] 마법서 `eq_w33_spellbook`
- [x] 저주받은 마법서 `eq_w34_cursed_book`
- [x] 성물 십자가 `eq_w35_relic_cross`
- [x] 흔들 향로 `eq_w36_swinging_censer`

## B. 방어구 (37–52)
- [x] 녹슨 투구 `eq_a01_rusted_helm`
- [x] 기사 투구 `eq_a02_knight_helm`
- [x] 가죽 두건 `eq_a03_leather_hood`
- [x] 철가면 `eq_a04_iron_mask`
- [x] 광대 가면 `eq_a05_jester_mask`
- [x] 사슬 갑옷 `eq_a06_chainmail`
- [x] 판금 갑옷 `eq_a07_plate_mail`
- [x] 가죽 갑옷 `eq_a08_leather_mail`
- [x] 누더기 로브 `eq_a09_ragged_robe`
- [x] 교단 로브 `eq_a10_cult_robe`
- [x] 망토 `eq_a11_cape`
- [x] 가죽 장갑 `eq_a12_leather_glove`
- [x] 쇠 장갑 `eq_a13_iron_glove`
- [x] 가죽 장화 `eq_a14_leather_boot`
- [x] 쇠 장화 `eq_a15_iron_boot`
- [x] 팔 보호대 `eq_a16_bracer`

## C. 방패 (53–58)
- [x] 둥근 나무 방패 `eq_s01_round_wood_shield`
- [x] 연 모양 방패 `eq_s02_kite_shield`
- [x] 큰 탑 방패 `eq_s03_tower_shield`
- [x] 녹슨 작은 방패 `eq_s04_rusted_buckler`
- [x] 문장 방패 `eq_s05_heraldic_shield`
- [x] 가시 방패 `eq_s06_spiked_shield`

## D. 장신구 (59–72)
- [x] 녹슨 반지 `eq_j01_rusted_ring`
- [x] 보석 반지 `eq_j02_gem_ring`
- [x] 해골 반지 `eq_j03_skull_ring`
- [x] 뱀 반지 `eq_j04_snake_ring`
- [x] 펜던트 목걸이 `eq_j05_pendant_necklace`
- [x] 로켓 목걸이 `eq_j06_rocket_charm`
- [x] 부적 `eq_j07_charm_tag`
- [x] 묵주 `eq_j08_prayer_beads`
- [x] 뼈 부적 `eq_j09_bone_charm`
- [x] 깃털 부적 `eq_j10_feather_charm`
- [x] 눈알 부적 `eq_j11_eye_charm`
- [x] 저주받은 보석 `eq_j12_cursed_gem`
- [x] 열쇠 목걸이 `eq_j13_key_necklace`
- [x] 달 부적 `eq_j14_moon_charm`

## E. 문서·종이 (73–87, canvas 1024)
- [ ] 73 편지 `eq_d01_letter`
- [ ] 74 밀랍 봉인 편지 `eq_d02_sealed_letter`
- [ ] 75 쪽지 `eq_d03_note`
- [ ] 76 찢어진 쪽지 `eq_d04_torn_note`
- [ ] 77 닫힌 일기장 `eq_d05_closed_journal`
- [ ] 78 펼친 일기장 `eq_d06_open_journal`
- [ ] 79 수배지 `eq_d07_wanted_poster`
- [ ] 80 펼친 지도 `eq_d08_map`
- [ ] 81 말린 두루마리 `eq_d09_rolled_scroll`
- [ ] 82 펼친 두루마리 `eq_d10_unrolled_scroll`
- [ ] 83 계약서 `eq_d11_contract`
- [ ] 84 교단 포고문 `eq_d12_cult_proclamation`
- [ ] 85 악보 `eq_d13_sheet_music`
- [ ] 86 신문 조각 `eq_d14_newspaper`
- [ ] 87 책 한 페이지 `eq_d15_book_page`

## F. 문장·깃발 (88–99)
- [ ] 88 기사단 문장 `eq_h01_knight_heraldry`
- [ ] 89 교단 문장 `eq_h02_cult_heraldry`
- [ ] 90 왕가 문장 `eq_h03_royal_heraldry`
- [ ] 91 해골 문장 `eq_h04_skull_heraldry`
- [ ] 92 달 문장 `eq_h05_moon_heraldry`
- [ ] 93 뱀 문장 `eq_h06_snake_heraldry`
- [ ] 94 세로 깃발 `eq_h07_vertical_banner`
- [ ] 95 삼각 깃발 `eq_h08_pennant`
- [ ] 96 찢어진 깃발 `eq_h09_torn_banner`
- [ ] 97 인장 도장 `eq_h10_seal_stamp`
- [ ] 98 밀랍 봉인 `eq_h11_wax_seal`
- [ ] 99 방패 문양 `eq_h12_shield_device`

## G. 보물·유물 (100–112)
- [ ] 100 금화 더미 `eq_t01_gold_coin_pile`
- [ ] 101 은화 `eq_t02_silver_coin`
- [ ] 102 보석 원석 `eq_t03_gem_rough`
- [ ] 103 왕관 `eq_t04_crown`
- [ ] 104 성배 `eq_t05_chalice`
- [ ] 105 황금 우상 `eq_t06_golden_idol`
- [ ] 106 해골 잔 `eq_t07_skull_cup`
- [ ] 107 금 촛대 `eq_t08_gold_candelabra`
- [ ] 108 성유물함 `eq_t09_reliquary_chest`
- [ ] 109 보석 달린 열쇠 `eq_t10_jeweled_key`
- [ ] 110 저울 `eq_t11_scales`
- [ ] 111 모래시계 `eq_t12_hourglass`
- [ ] 112 뿔 나팔 `eq_t13_horn`

## H. 광기·병원 도구 (113–121)
- [ ] 113 녹슨 수술칼 `eq_c01_rusted_scalpel`
- [ ] 114 뼈톱 `eq_c02_bone_saw`
- [ ] 115 거대한 주사기 `eq_c03_giant_syringe`
- [ ] 116 수술용 집게 `eq_c04_surgical_forceps`
- [ ] 117 구속복 `eq_c05_straitjacket`
- [ ] 118 역병 의사 부리 가면 `eq_c06_plague_beak_mask`
- [ ] 119 라벨 없는 약병 `eq_c07_unlabelled_vial`
- [ ] 120 전기 충격 지팡이 `eq_c08_shock_staff`
- [ ] 121 족쇄 달린 환자 팔찌 `eq_c09_shackled_patient_wristband`

## I. 무기가 된 생활 도구 (122–133)
- [ ] 122 식칼 `eq_d1_kitchen_knife`
- [ ] 123 큰 재단 가위 `eq_d2_tailors_shears`
- [ ] 124 목수 톱 `eq_d3_saw`
- [ ] 125 쇠스랑 `eq_d4_rake`
- [ ] 126 우산 칼 `eq_d5_umbrella_sword`
- [ ] 127 촛대 곤봉 `eq_d6_candlestick_club`
- [ ] 128 삽 `eq_d7_shovel`
- [ ] 129 부지깽이 `eq_d8_ice_pick`
- [ ] 130 거대한 재봉 바늘 `eq_d9_giant_needle`
- [ ] 131 신사 지팡이 칼 `eq_d10_cane_sword`
- [ ] 132 고기 걸이 갈고리 `eq_d11_meat_hook`
- [ ] 133 벽난로 삽 `eq_d12_fireplace_poker`

## J. 뒤틀린 동화 (134–145, 앨리스 제외)
- [ ] 134 깨진 유리 구두 `eq_f01_broken_glass_slipper`
- [ ] 135 독사과 `eq_f02_poison_apple`
- [ ] 136 물레 가락 `eq_f03_distaff`
- [ ] 137 찢어진 빨간 두건 망토 `eq_f04_torn_red_hood`
- [ ] 138 쥐를 부르는 피리 `eq_f05_rat_whistle`
- [ ] 139 늑대 가죽 망토 `eq_f06_wolf_pelt_cloak`
- [ ] 140 마녀의 거울 조각 `eq_f07_witch_mirror_shard`
- [ ] 141 성냥 다발 `eq_f08_match_bundle`
- [ ] 142 인어 비늘 단검 `eq_f09_mermaid_dagger`
- [ ] 143 푸른 수염의 검붉은 열쇠 `eq_f10_blue_beard_key`
- [ ] 144 뒤틀린 과자 집 조각 `eq_f11_candy_house_shard`
- [ ] 145 나무 인형 팔 곤봉 `eq_f12_doll_arm_club`

## K. 심해·이름 없는 신 (146–155)
- [ ] 146 작살 `eq_k01_harpoon`
- [ ] 147 녹슨 닻 도끼 `eq_k02_anchored_axe`
- [ ] 148 해초 감긴 삼지창 `eq_k03_kelp_trident`
- [ ] 149 물고기 비늘 갑옷 `eq_k04_scale_armor`
- [ ] 150 촉수 달린 마법서 `eq_k05_tentacle_book`
- [ ] 151 촉수 달린 우상 `eq_k06_tentacle_idol`
- [ ] 152 진주 눈알 목걸이 `eq_k07_pearl_eye_necklace`
- [ ] 153 심연 조개 부적 `eq_k08_abyss_shell_charm`
- [ ] 154 별 모양 봉인석 `eq_k09_star_seal_stone`
- [ ] 155 눈이 여러 개인 가면 `eq_k10_many_eyed_mask`

## L. 교단·저주·희생 (156–167)
- [ ] 156 가시 면류관 `eq_x01_thorn_circlet`
- [ ] 157 순교자의 쇠사슬 `eq_x02_martyr_chain`
- [ ] 158 참회자의 가시 채찍 `eq_x03_penitent_rod`
- [ ] 159 금 간 성표 `eq_x04_cracked_reliquary`
- [ ] 160 검붉게 물든 성배 `eq_x05_bloodstained_chalice`
- [ ] 161 눈 없는 성상 `eq_x06_faceless_statue`
- [ ] 162 바늘 꽂힌 헝겊 인형 `eq_x07_pinned_rag_doll`
- [ ] 163 영혼을 담은 등불 `eq_x08_soul_lantern`
- [ ] 164 희미한 영혼 불꽃 `eq_x09_faint_soul_flame`
- [ ] 165 화톳불 재 한 줌 `eq_x10_hearth_ashes`
- [ ] 166 제물용 은쟁반 `eq_x11_offering_silver_tray`
- [ ] 167 교단 가면 `eq_x12_cult_mask`

## M. 처형 (168–173)
- [ ] 168 처형인 두건 `eq_e01_executioner_hood`
- [ ] 169 단두대 날 대검 `eq_e02_headsman_blade`
- [ ] 170 족쇄 사슬 무기 `eq_e03_shackle_chain_weapon`
- [ ] 171 낙인 인두 `eq_e04_branding_iron`
- [ ] 172 넓은 날 처형 도끼 `eq_e05_wide_execution_axe`
- [ ] 173 목에 차는 형틀 `eq_e06_guillotine_blade`

## N. 망가진 장난감·아이 방 (174–182)
- [ ] 174 태엽 인형 `eq_n01_clockwork_doll`
- [ ] 175 망가진 곰 인형 `eq_n02_broken_teddy`
- [ ] 176 오르골 `eq_n03_music_box`
- [ ] 177 깜짝 상자 `eq_n04_jump_box`
- [ ] 178 꼭두각시 십자 막대와 줄 `eq_n05_tin_cross_stick`
- [ ] 179 나무 목마 장난감 `eq_n06_wooden_hobby_horse`
- [ ] 180 유리 구슬 `eq_n07_glass_marble`
- [ ] 181 딸랑이 `eq_n08_rattle`
- [ ] 182 팔 빠진 도자기 인형 `eq_n09_armless_china_doll`

## O. 빅토리아 시대 신사·도시 (183–191)
- [ ] 183 회중시계 `eq_v01_pocket_watch`
- [ ] 184 실크해트 `eq_v02_top_hat`
- [ ] 185 단안경 `eq_v03_monocle`
- [ ] 186 가스 랜턴 `eq_v04_gas_lantern`
- [ ] 187 향수병 `eq_v05_perfume_bottle`
- [ ] 188 편지칼 `eq_v06_letter_opener`
- [ ] 189 신사 장갑 `eq_v07_mens_glove`
- [ ] 190 은 성냥갑 `eq_v08_silver_matchbox`
- [ ] 191 톱니 달린 증기 팔 보호대 `eq_v09_steam_bracer`

## P. 몸과 광기 (192–199)
- [ ] 192 병에 담긴 눈알 `eq_b01_eye_in_jar`
- [ ] 193 이빨 목걸이 `eq_b02_tooth_necklace`
- [ ] 194 뼈 피리 `eq_b03_bone_whistle`
- [ ] 195 심장 모양 저주 보석 `eq_b04_heart_curse_gem`
- [ ] 196 머리카락 묶음 부적 `eq_b05_hair_charm`
- [ ] 197 척추뼈 채찍 `eq_b06_spine_whip`
- [ ] 198 두개골 랜턴 `eq_b07_skull_lantern`
- [ ] 199 갈비뼈 방패 `eq_b08_rib_shield`

## Q. 색 변형 (_v2)
> A~D, H~P 중 장비 레시피 복사 → iron→bronze, leather→cloth_wine, 파일명 끝 `_v2`
- [ ] Q 색 변형 `_v2` 세트

## 모아 보기 시트
- `preview/sheet_1.png` — A 무기 1–36
- `preview/sheet_2.png` — B 갑옷 / C 방패 / D 장신구
- `preview/sheet_icon128_A_D.png` — 1–72 전부 128px 축소 검수
- `output/*/**_icon128.png` (72개 생성됨)

## 로그
- 셋업 완료, tool/palette 복사됨.
- 예시 레시피(eq_w01) 빌드 확인 — 파이프라인 정상.
- 레시피는 `_gen/gen_a.py`(A) `_gen/gen_bcd.py`(B/C/D)가 JSON으로 내보낸다. 좌표는 손으로 쓴 데이터.
- 1–36 전량 빌드 → 시트 검수 → 표면 합성·손잡이·아이콘 크롭 위치 수정 후 재빌드.
- 37–72 전량 빌드 → 갑옷/방패/장신구 시트 검수 후 재빌드.

## 도구에서 확인한 사실 (다음 작업에도 적용)
- `slice`의 `border`/`corner`는 픽셀이 아니라 0~8 아이콘 그리드 값이다. 30을 넣으면 몸통이 통째로 사라진다.
- `crop`을 쓰면 그 조각의 `size`는 **잘라낸 영역**의 크기다. 전체 아이콘 크기가 아니다. 380x420 방패에 `crop:[2,1,14,3.4]` + `size:[380,420]`을 주면 테두리가 방패 전체를 덮는다. `size`는 잘라낸 영역에 맞게 줄이고 `at`도 그 영역의 중심으로 옮긴다.
- `op:"sub"`는 같은 form 안에서만 동작한다. 구멍은 같은 form의 조각으로 넣는다.
- `repeat`는 `line` / `grid` / `ellipse`(orient) / `points` 를 지원하고 `jitter`를 붙일 수 있다. 톱니·리벳·비늘·사슬에 썼다.
- `*_emit.png`는 본체와 별도 레이어다. 모아 보기 시트 glob에 `*.png`를 쓰면 emit이 별도 칸으로 잡힌다. 본체만 모으려면 `<asset>.png`를 명시할 것.

## 이 작업에서 검증한 비법
- **halo**: 형체의 조각을 `stone_cap`(near-black)으로 pad 13~15px 키워 뒤에 깔면 실루엣이 서로 분리된다. 512px에서 어두운 배경 위의 갑옷·방패가 한 덩어리로 뭉개지는 문제의 해법이었다.头盔은 실루엣 자체를 못 만들어서 `tragedy_mask` 위에 돔·코대를 얹었다.
- **tarnish 크기 축소**: `iron` 재질에 이미 grime 스탬프가 들어 있다. 여기에 `wash`+`multiply` 를 0.6 이상으로 올리면 갈색 구름이 겹쳐서 판독을 해친다. 스탬프를 0.5배로 줄이고 opacity 0.34 전후로 두는 편이 옳다.
- **wash 밖의 sub**: 512px 검토 시트에서 `_emit.png`가 별도 칸으로 보여 "떠 있는 다이아몬드"처럼 보인 것이 emit 레이어였다. 실수는 아니었다.

## 남은 것 (중단 지시로 시작 안 함)
- E 문서(73–87) / F 문장(88–99) / G 보물(100–112) / H(113–121) / I(122–133) / J(134–145) / K(146–155) / L(156–167) / M(168–173) / N(174–182) / O(183–191) / P(192–199) / Q 색변형(_v2)
- 도전 라운드 3종: ①초기 6개 재검수 ②아이콘 더 쓴 대형 버전 ③최소 아이콘 구현
- E는 canvas 1024를 써야 하므로 위 좌표 체계를 다시 잡아야 한다.
