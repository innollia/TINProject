# g04 목록 — 모든 장르의 오브젝트(배경 위에 따로 놓는 물건)

세션 g04 담당(GENERIC.md): 나무·풀·꽃·바위, 건물 한 채, 가구·상자·통·등불·울타리·간판처럼 놓는 물건. 전부 candidate이고 승인은 사용자만 한다. 아이콘 조합으로만 그린다(at-icons 모양을 잘라 겹침).

- BS2 목록(`g01_bs2_inventory.md`)의 g04 몫은 전부 넣었다('출처' 칸의 BS2). 신체 훼손·시체가 드러나는 모습은 넣지 않는다(단두대·교수대·철의 처녀는 빈 기구만).
- 경계: 들고 다닐 수 있는 물건은 아이콘(g01·g02)이라 넣지 않았다. 벽·바닥·계단·고정 구조는 g03. 횃불·화로·모닥불·벽난로는 물건만 그리고 불꽃 효과는 그리지 않는다(켜짐 그림은 빛나는 숯·심지만 `_emit.png`로, 불꽃 놓을 자리는 manifest `anchors.flame_anchor`). 얼굴 있는 나무 같은 생물은 g05.
- 형식: 오브젝트 = 투명 PNG(원본 2배) + `_shadow.png`(바닥 그림자) + 빛나는 부분 `_emit.png`, 60도 탑다운, 바닥 접촉 피벗(벽에 붙는 것은 붙는 자리 피벗). 상태 그림은 같은 캔버스·피벗의 프레임으로 만든다. 게임 코드용 빛 `"light": {color, radius, at}`은 묶음별 `recipes\scene_<묶음>_lineup.json`과 프레임 manifest `game_light`에 있다.
- 크기(작성자 설계): 폭 180 px/m, 바닥 깊이 156 px/m(×0.866), 높이 105 px/m(플레이어 그림 약 180 px = 1.7 m). 자세한 규칙은 각 묶음 JOB.md.
- 작업 폴더: `assets\art\generic\jobs\g04-<묶음>-v01` + `docs\art\projects\generic\jobs\g04-<묶음>-v01` (묶음: nature 자연물, dungeon 던전·문·어두운 판타지, interior 실내, exterior 바깥, buildings 건물, genre 장르별).
- 상태: 대기 / 완료 / 건너뜀.

## A — 꼭 있어야 할 기본·클리셰 (42)

| # | 이름 | 자산 ID | 장르 | 우선순위 | 형식·상태 그림 | 묶음 | 출처 | 상태 |
|---|---|---|---|---|---|---|---|---|
| 1 | 둥근 활엽수(참나무) | obj_tree_oak | 중세 | A | 오브젝트 | g04-nature-v01 |  | 완료 |
| 2 | 전나무 | obj_tree_fir | 중세 | A | 오브젝트 | g04-nature-v01 |  | 완료 |
| 3 | 마른 나무 | obj_tree_dead | 다크 | A | 오브젝트 | g04-nature-v01 |  | 완료 |
| 4 | 덤불 | obj_bush | 중세 | A | 오브젝트 | g04-nature-v01 |  | 완료 |
| 5 | 풀 무더기 | obj_grass_tuft | 중세 | A | 오브젝트 | g04-nature-v01 |  | 완료 |
| 6 | 들꽃 무리 | obj_flowers | 중세 | A | 오브젝트 | g04-nature-v01 |  | 완료 |
| 7 | 버섯 무리 | obj_mushrooms | 중세 | A | 오브젝트 | g04-nature-v01 | BS2 버섯 | 완료 |
| 8 | 큰 바위 | obj_rock_large | 중세 | A | 오브젝트 | g04-nature-v01 |  | 완료 |
| 9 | 쓰러진 통나무 | obj_log_fallen | 중세 | A | 오브젝트 | g04-nature-v01 |  | 완료 |
| 10 | 나무 상자 | obj_crate | 중세 | A | 오브젝트 (보통·부서짐) | g04-dungeon-v01 |  | 완료 |
| 11 | 보물상자 | obj_chest | 중세 | A | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 보물상자 | 완료 |
| 12 | 나무 통 | obj_barrel | 중세 | A | 오브젝트 (보통·부서짐) | g04-dungeon-v01 |  | 완료 |
| 13 | 횃불대 | obj_torch_stand | 다크 | A | 오브젝트 (꺼짐·켜짐) | g04-dungeon-v01 |  | 완료 |
| 14 | 벽 횃불 | obj_torch_wall | 다크 | A | 오브젝트 (꺼짐·켜짐, 벽 피벗) | g04-dungeon-v01 |  | 완료 |
| 15 | 화로 | obj_brazier | 다크 | A | 오브젝트 (꺼짐·켜짐) | g04-dungeon-v01 |  | 완료 |
| 16 | 관 | obj_coffin | 고딕 | A | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 관 | 완료 |
| 17 | 쇠창살 문 | obj_bar_door | 다크 | A | 오브젝트 (닫힘·열림) | g04-dungeon-v01 |  | 완료 |
| 18 | 바닥 레버 | obj_lever | 공통 | A | 오브젝트 (올림·내림) | g04-dungeon-v01 | BS2 스위치·레버 | 완료 |
| 19 | 나무 문 | obj_door_wood | 중세 | A | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 나무 문 | 완료 |
| 20 | 책상 | obj_desk | 중세 | A | 오브젝트 | g04-interior-v01 |  | 완료 |
| 21 | 의자 | obj_chair | 중세 | A | 오브젝트 | g04-interior-v01 |  | 완료 |
| 22 | 침대 | obj_bed | 중세 | A | 오브젝트 | g04-interior-v01 |  | 완료 |
| 23 | 책장 | obj_bookshelf | 중세 | A | 오브젝트 | g04-interior-v01 | BS2 책장 | 완료 |
| 24 | 수납 선반 | obj_shelf | 중세 | A | 오브젝트 (가득·빔) | g04-interior-v01 |  | 완료 |
| 25 | 옷장 | obj_wardrobe | 중세 | A | 오브젝트 (닫힘·열림) | g04-interior-v01 |  | 완료 |
| 26 | 긴 식탁 | obj_dining_table | 중세 | A | 오브젝트 | g04-interior-v01 |  | 완료 |
| 27 | 무쇠 난로 | obj_stove_iron | 중세 | A | 오브젝트 (꺼짐·켜짐) | g04-interior-v01 |  | 완료 |
| 28 | 벽난로 | obj_fireplace | 중세 | A | 오브젝트 (꺼짐·켜짐) | g04-interior-v01 | BS2 벽난로 | 완료 |
| 29 | 나무 울타리(가로·세로) | obj_fence_wood | 중세 | A | 오브젝트 (보통·부서짐 + 세로 칸(obj_fence_wood_v)) | g04-exterior-v01 |  | 완료 |
| 30 | 우물 | obj_well | 중세 | A | 오브젝트 | g04-exterior-v01 | BS2 우물 | 완료 |
| 31 | 가로등 | obj_street_lamp | 중세 | A | 오브젝트 (꺼짐·켜짐) | g04-exterior-v01 |  | 완료 |
| 32 | 걸린 간판(글자 없음) | obj_sign_hanging | 중세 | A | 오브젝트 (빈 판·여관·대장간·물약, 벽 피벗) | g04-exterior-v01 | BS2 간판 | 완료 |
| 33 | 손수레 | obj_handcart | 중세 | A | 오브젝트 | g04-exterior-v01 |  | 완료 |
| 34 | 벤치 | obj_bench | 중세 | A | 오브젝트 | g04-exterior-v01 |  | 완료 |
| 35 | 묘비 | obj_gravestone | 다크 | A | 오브젝트 (아치·십자·부서짐) | g04-exterior-v01 |  | 완료 |
| 36 | 모닥불 | obj_campfire | 중세 | A | 오브젝트 (꺼짐·켜짐) | g04-exterior-v01 | BS2 화톳불 | 완료 |
| 37 | 중세 집 | obj_house_medieval | 중세 | A | 오브젝트 (낮·밤(창 불빛)) | g04-buildings-v01 |  | 완료 |
| 38 | 자판기 | obj_vending_machine | 현대 | A | 오브젝트 (꺼짐·켜짐) | g04-genre-v01 |  | 완료 |
| 39 | 자동차 | obj_car | 현대 | A | 오브젝트 | g04-genre-v01 |  | 완료 |
| 40 | SF 조종 콘솔 | obj_sf_console | SF | A | 오브젝트 (꺼짐·켜짐) | g04-genre-v01 |  | 완료 |
| 41 | 냉동 캡슐 | obj_sf_capsule | SF | A | 오브젝트 (닫힘·열림) | g04-genre-v01 |  | 완료 |
| 42 | 증기 보일러 | obj_steam_boiler | 스팀펑크 | A | 오브젝트 (꺼짐·켜짐) | g04-genre-v01 |  | 완료 |

## B — 흔히 쓰는 것 (44)

| # | 이름 | 자산 ID | 장르 | 우선순위 | 형식·상태 그림 | 묶음 | 출처 | 상태 |
|---|---|---|---|---|---|---|---|---|
| 43 | 그루터기 | obj_stump | 중세 | B | 오브젝트 | g04-nature-v01 |  | 완료 |
| 44 | 과일 나무 | obj_tree_fruit | 중세 | B | 오브젝트 | g04-nature-v01 | BS2 과일 나무 | 완료 |
| 45 | 저주받은 나무(얼굴 없음) | obj_tree_cursed | 다크 | B | 오브젝트 | g04-nature-v01 | BS2 저주받은 나무 | 완료 |
| 46 | 대나무 덤불 | obj_bamboo | 동양 | B | 오브젝트 | g04-nature-v01 |  | 완료 |
| 47 | 선인장 | obj_cactus | 서부 | B | 오브젝트 | g04-nature-v01 |  | 완료 |
| 48 | 야자수 | obj_palm | 해적·바다 | B | 오브젝트 | g04-nature-v01 |  | 완료 |
| 49 | 큰 술통(받침대) | obj_wine_cask | 중세 | B | 오브젝트 | g04-dungeon-v01 | BS2 술통 | 완료 |
| 50 | 큰 꽃병 | obj_vase | 중세 | B | 오브젝트 (보통·깨짐) | g04-dungeon-v01 | BS2 깨지는 꽃병 | 완료 |
| 51 | 선물 상자 | obj_gift_box | 공통 | B | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 선물 상자 | 완료 |
| 52 | 제단 | obj_altar | 다크 | B | 오브젝트 (꺼짐·켜짐(촛불 자리)) | g04-dungeon-v01 |  | 완료 |
| 53 | 석상 | obj_statue | 다크 | B | 오브젝트 (보통·부서짐) | g04-dungeon-v01 | 무너진 석상 | 완료 |
| 54 | 성문 | obj_gate_castle | 중세 | B | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 성문 | 완료 |
| 55 | 비밀 문(책장 문) | obj_door_secret | 고딕 | B | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 비밀 문 | 완료 |
| 56 | 비밀 통로 입구(바닥 뚜껑) | obj_trapdoor | 다크 | B | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 비밀 통로 입구 | 완료 |
| 57 | 발코니 문 | obj_door_balcony | 고딕 | B | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 발코니 문 | 완료 |
| 58 | 샹들리에 | obj_chandelier | 고딕 | B | 오브젝트 (꺼짐·켜짐) | g04-interior-v01 | BS2 샹들리에 | 완료 |
| 59 | 스탠드 램프 | obj_lamp_floor | 고딕 | B | 오브젝트 (꺼짐·켜짐) | g04-interior-v01 | BS2 램프 | 완료 |
| 60 | 벽 등 | obj_lantern_wall | 중세 | B | 오브젝트 (꺼짐·켜짐, 벽 피벗) | g04-interior-v01 | BS2 등 | 완료 |
| 61 | 괘종시계 | obj_clock_grandfather | 고딕 | B | 오브젝트 | g04-interior-v01 | BS2 시계 | 완료 |
| 62 | 전신 거울 | obj_mirror_standing | 고딕 | B | 오브젝트 (보통·깨짐) | g04-interior-v01 | BS2 거울 | 완료 |
| 63 | 가게 계산대 | obj_counter_shop | 중세 | B | 오브젝트 | g04-interior-v01 |  | 완료 |
| 64 | 소파 | obj_sofa | 고딕 | B | 오브젝트 | g04-interior-v01 |  | 완료 |
| 65 | 피아노 | obj_piano | 고딕 | B | 오브젝트 (닫힘·열림(건반 뚜껑)) | g04-interior-v01 |  | 완료 |
| 66 | 분수 | obj_fountain | 중세 | B | 오브젝트 | g04-exterior-v01 | BS2 분수 | 완료 |
| 67 | 배수구 덮개 | obj_drain_cover | 다크 | B | 오브젝트 (바닥 레이어) | g04-exterior-v01 | BS2 하수구 | 완료 |
| 68 | 시장 가판대 | obj_market_stall | 중세 | B | 오브젝트 | g04-exterior-v01 |  | 완료 |
| 69 | 파라솔 탁자 | obj_parasol | 공통 | B | 오브젝트 | g04-exterior-v01 | BS2 파라솔 | 완료 |
| 70 | 짐마차 | obj_wagon | 중세 | B | 오브젝트 | g04-exterior-v01 | BS2 짐마차 | 완료 |
| 71 | 대포 | obj_cannon | 해적·바다 | B | 오브젝트 | g04-exterior-v01 | BS2 대포 | 완료 |
| 72 | 나룻배 | obj_rowboat | 해적·바다 | B | 오브젝트 | g04-exterior-v01 | BS2 보트 | 완료 |
| 73 | 길 안내 기둥(글자 없음) | obj_signpost | 중세 | B | 오브젝트 | g04-exterior-v01 |  | 완료 |
| 74 | 고딕 쇠 울타리 | obj_fence_iron | 고딕 | B | 오브젝트 (보통·부서짐) | g04-exterior-v01 |  | 완료 |
| 75 | 눈사람 | obj_snowman | 공통 | B | 오브젝트 | g04-exterior-v01 | BS2 눈사람 | 완료 |
| 76 | 중세 가게 | obj_shop_medieval | 중세 | B | 오브젝트 (낮·밤) | g04-buildings-v01 |  | 완료 |
| 77 | 마법사 탑 | obj_tower_mage | 중세 | B | 오브젝트 (낮·밤) | g04-buildings-v01 |  | 완료 |
| 78 | 고딕 교회 | obj_church_gothic | 고딕 | B | 오브젝트 (낮·밤) | g04-buildings-v01 |  | 완료 |
| 79 | 헛간 창고 | obj_barn | 중세 | B | 오브젝트 (닫힘·열림) | g04-buildings-v01 |  | 완료 |
| 80 | 풍차 | obj_windmill | 중세 | B | 오브젝트 | g04-buildings-v01 | BS2 풍차 | 완료 |
| 81 | 동양 기와집 | obj_house_east | 동양 | B | 오브젝트 (낮·밤) | g04-buildings-v01 |  | 완료 |
| 82 | 신호등 | obj_traffic_light | 현대 | B | 오브젝트 (빨강·초록·꺼짐) | g04-genre-v01 |  | 완료 |
| 83 | 네온 간판(글자 없음) | obj_neon_sign | 사이버펑크 | B | 오브젝트 (꺼짐·켜짐, 벽 피벗) | g04-genre-v01 |  | 완료 |
| 84 | 드럼통 | obj_oil_drum | 포스트아포칼립스 | B | 오브젝트 (보통·찌그러짐) | g04-genre-v01 |  | 완료 |
| 85 | 바리케이드 | obj_barricade | 포스트아포칼립스 | B | 오브젝트 | g04-genre-v01 |  | 완료 |
| 86 | 석등 | obj_stone_lantern | 동양 | B | 오브젝트 (꺼짐·켜짐) | g04-genre-v01 |  | 완료 |

## C — 있으면 좋은 것 (37)

| # | 이름 | 자산 ID | 장르 | 우선순위 | 형식·상태 그림 | 묶음 | 출처 | 상태 |
|---|---|---|---|---|---|---|---|---|
| 87 | 갈대 | obj_reeds | 중세 | C | 오브젝트 | g04-nature-v01 |  | 대기 |
| 88 | 작은 돌 무더기 | obj_rocks_small | 중세 | C | 오브젝트 | g04-nature-v01 |  | 대기 |
| 89 | 작은 폭포 바위 | obj_waterfall_rock | 중세 | C | 오브젝트 | g04-nature-v01 | BS2 폭포 | 대기 |
| 90 | 벚나무 | obj_tree_cherry | 동양 | C | 오브젝트 | g04-nature-v01 |  | 대기 |
| 91 | 수정 바위 | obj_crystal_rock | 중세 | C | 오브젝트 (꺼짐·켜짐(빛남)) | g04-nature-v01 |  | 대기 |
| 92 | 단두대 | obj_guillotine | 다크 | C | 오브젝트 | g04-dungeon-v01 | BS2 단두대 | 대기 |
| 93 | 교수대 | obj_gallows | 다크 | C | 오브젝트 | g04-dungeon-v01 | BS2 교수대 | 대기 |
| 94 | 철의 처녀 | obj_iron_maiden | 다크 | C | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 철의 처녀 | 대기 |
| 95 | 톱날 함정 | obj_saw_trap | 다크 | C | 오브젝트 (숨음·나옴) | g04-dungeon-v01 | BS2 톱날 함정 | 대기 |
| 96 | 이상한 문 | obj_door_strange | 다크 | C | 오브젝트 (닫힘·열림) | g04-dungeon-v01 | BS2 이상한 문 | 대기 |
| 97 | 벽 족쇄 | obj_wall_shackles | 다크 | C | 오브젝트 (벽 피벗) | g04-dungeon-v01 |  | 대기 |
| 98 | 큰 새장 | obj_cage_large | 다크 | C | 오브젝트 (닫힘·열림) | g04-dungeon-v01 |  | 대기 |
| 99 | 큰 진자 | obj_pendulum | 고딕 | C | 오브젝트 | g04-interior-v01 | BS2 진자 | 대기 |
| 100 | 축음기 | obj_phonograph | 고딕 | C | 오브젝트 | g04-interior-v01 | BS2 축음기 | 대기 |
| 101 | 브라운관 텔레비전 | obj_tv_crt | 현대 | C | 오브젝트 (꺼짐·켜짐) | g04-interior-v01 | BS2 텔레비전 | 대기 |
| 102 | 휠체어 | obj_wheelchair | 호러·오컬트 | C | 오브젝트 | g04-interior-v01 | BS2 휠체어 | 대기 |
| 103 | 떠다니는 책 | obj_floating_book | 중세 | C | 오브젝트 | g04-interior-v01 | BS2 떠다니는 책 | 대기 |
| 104 | 풍선 다발 | obj_balloons | 공통 | C | 오브젝트 | g04-interior-v01 | BS2 풍선 | 대기 |
| 105 | 큰 인형(앉은 장식) | obj_doll_large | 호러·오컬트 | C | 오브젝트 | g04-interior-v01 | BS2 인형 | 대기 |
| 106 | 톱니바퀴 장치 | obj_gear_machine | 스팀펑크 | C | 오브젝트 | g04-interior-v01 | BS2 톱니바퀴 | 대기 |
| 107 | 복고양이 장식상 | obj_lucky_cat | 동양 | C | 오브젝트 | g04-interior-v01 | BS2 복고양이 장식상 | 대기 |
| 108 | 물레방아 집 | obj_watermill | 중세 | C | 오브젝트 | g04-buildings-v01 | BS2 물레방아 | 대기 |
| 109 | 서부 술집 | obj_saloon | 서부 | C | 오브젝트 (낮·밤) | g04-buildings-v01 |  | 대기 |
| 110 | 폐허 판잣집 | obj_shack | 포스트아포칼립스 | C | 오브젝트 | g04-buildings-v01 |  | 대기 |
| 111 | SF 거주 모듈 | obj_sf_habitat | SF | C | 오브젝트 (낮·밤) | g04-buildings-v01 |  | 대기 |
| 112 | 등대 | obj_lighthouse | 해적·바다 | C | 오브젝트 (꺼짐·켜짐) | g04-buildings-v01 |  | 대기 |
| 113 | 공중전화 부스 | obj_phone_booth | 현대 | C | 오브젝트 (꺼짐·켜짐) | g04-genre-v01 |  | 대기 |
| 114 | 쓰레기통 | obj_trash_can | 현대 | C | 오브젝트 | g04-genre-v01 |  | 대기 |
| 115 | 말 매는 말뚝 | obj_hitching_post | 서부 | C | 오브젝트 | g04-genre-v01 |  | 대기 |
| 116 | 물탱크 | obj_water_tower | 서부 | C | 오브젝트 | g04-genre-v01 |  | 대기 |
| 117 | 도리이(신사 문) | obj_torii | 동양 | C | 오브젝트 | g04-genre-v01 |  | 대기 |
| 118 | 큰 닻 | obj_anchor_large | 해적·바다 | C | 오브젝트 | g04-genre-v01 |  | 대기 |
| 119 | 불탄 차 | obj_car_burnt | 포스트아포칼립스 | C | 오브젝트 | g04-genre-v01 |  | 대기 |
| 120 | 거리 단말기 | obj_street_terminal | 사이버펑크 | C | 오브젝트 (꺼짐·켜짐) | g04-genre-v01 |  | 대기 |
| 121 | 철도 신호기 | obj_rail_signal | 스팀펑크 | C | 오브젝트 (빨강·초록) | g04-genre-v01 | BS2 증기기관차 부품(신호기) | 대기 |
| 122 | 증기 굴뚝 | obj_steam_chimney | 스팀펑크 | C | 오브젝트 | g04-genre-v01 | BS2 증기기관차 부품(굴뚝) | 대기 |
| 123 | 승강기(철창 리프트) | obj_cage_lift | 스팀펑크 | C | 오브젝트 (위·아래) | g04-genre-v01 | BS2 승강기 | 대기 |

합계 123개 (A 42 · B 44 · C 37).
