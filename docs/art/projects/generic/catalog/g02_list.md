# g02 목록 — 모든 장르의 사람 + 판타지 밖 장르의 아이콘·UI·효과

세션 g02(범용 에셋). 규칙: `docs\art\mass_production\COMMON.md` + `GENERIC.md`. 결과는 전부 candidate이고 승인은 사용자만 한다. 아이콘 조합으로만 만든다.

- 합계 129개: A 42 / B 45 / C 42.
- 장르별 개수: 다크 판타지·고딕 14, 중세 판타지 15, 동양 판타지 14, 현대·도시 13, 호러·오컬트 13, SF·우주 11, 사이버펑크 10, 스팀펑크 9, 포스트아포칼립스 10, 해적·바다 10, 서부 10. 판타지 계열(43개)이 가장 두껍다. 판타지 계열의 아이콘·UI·효과는 g01 담당이라 판타지 쪽은 사람만 있다.
- 사람이 아닌 것(고블린·수인·흡혈귀·유령·안드로이드 등)은 g05 담당이라 넣지 않았다. 못 드는 물건은 g04, 판타지·장르 없는 소지품은 g01이 맡는다.
- BS2 목록(`g01_bs2_inventory.md`)의 g02 몫 26명은 전부 넣었고 비고에 BS2라고 적었다.

## 형식

| 표시 | 뜻 |
|---|---|
| 초상+전투3 | 초상화 320×320(3/4 흉상, 얼굴 위치 고정) + 전투 그림 정면(캔버스 320×384, 사람 크기, 기본·공격·피격 3장) |
| 초상+전투1 | 초상화 320×320 + 전투 그림 정면 기본 1장 |
| 아이콘 | 128×128 평면 한 장 + 한 줄 16칸 시트에 모음 |
| UI 9-slice | 글자 없는 창틀 192×192(모서리 48px) + 9조각 + 늘린 확인 그림 |
| 효과 5칸 | 192×192 칸, 한 줄 5칸 시트(+ 빛나는 부분 `_emit` 시트) |

맵에서 걷는 8방향 스프라이트는 COMMON.md의 '캐릭터 스프라이트 형식'이 '확정'되기 전까지 만들지 않는다. 모든 사람 항목에 공통으로 '8방향 대기'다.

## 묶음 (작업 폴더)

`assets\art\generic\jobs\<묶음>\` + `docs\art\projects\generic\jobs\<묶음>\`

| 묶음 | 내용 |
|---|---|
| g02-people-fantasy-v01 | 다크 판타지·고딕, 중세 판타지, 동양 판타지 사람 |
| g02-people-modern-v01 | 현대·도시, 호러·오컬트 사람 |
| g02-people-future-v01 | SF·우주, 사이버펑크, 포스트아포칼립스 사람 |
| g02-people-frontier-v01 | 스팀펑크, 해적·바다, 서부 사람 |
| g02-icons-genre-v01 | 판타지 밖 8장르 소지품 아이콘 |
| g02-ui-genre-v01 | 판타지 밖 8장르 창틀 |
| g02-fx-genre-v01 | 판타지 밖 8장르 효과 |

상태: 대기 / 완료 / 건너뜀

## A — 꼭 있어야 할 기본·클리셰 (42)

| ID | 이름 | 장르 | 우선순위 | 형식 | 묶음 | 상태 | 비고 |
|---|---|---|---|---|---|---|---|
| df_monster_hunter | 괴물 사냥꾼 | 다크 판타지·고딕 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | BS2 사냥꾼 |
| df_crusader | 십자군 기사 | 다크 판타지·고딕 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | BS2 |
| df_priest | 사제 | 다크 판타지·고딕 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | BS2 |
| df_noble_lady | 귀족 부인 | 다크 판타지·고딕 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | BS2 |
| mf_farmer | 농부 | 중세 판타지 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | |
| mf_knight | 기사 | 중세 판타지 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | |
| mf_mage | 마법사 | 중세 판타지 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | BS2 |
| mf_guard | 경비병 | 중세 판타지 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | BS2 |
| mf_soldier | 병사 | 중세 판타지 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | BS2 |
| ef_samurai | 사무라이(무사) | 동양 판타지 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | |
| ef_monk | 승려 | 동양 판타지 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | |
| ef_ninja | 닌자 | 동양 판타지 | A | 초상+전투3 | g02-people-fantasy-v01 | 완료 | |
| mo_student | 학생 | 현대·도시 | A | 초상+전투3 | g02-people-modern-v01 | 완료 | BS2 |
| mo_police | 경찰 | 현대·도시 | A | 초상+전투3 | g02-people-modern-v01 | 완료 | |
| mo_surgeon | 외과의(의사) | 현대·도시 | A | 초상+전투3 | g02-people-modern-v01 | 완료 | BS2 외과의 |
| mo_nurse | 간호사 | 현대·도시 | A | 초상+전투3 | g02-people-modern-v01 | 완료 | BS2 |
| ho_cultist | 광신도 | 호러·오컬트 | A | 초상+전투3 | g02-people-modern-v01 | 완료 | BS2 |
| sf_astronaut | 우주비행사 | SF·우주 | A | 초상+전투3 | g02-people-future-v01 | 완료 | |
| cp_hacker | 해커 | 사이버펑크 | A | 초상+전투3 | g02-people-future-v01 | 완료 | |
| pa_survivor | 생존자 | 포스트아포칼립스 | A | 초상+전투3 | g02-people-future-v01 | 완료 | |
| sp_inventor | 발명가 | 스팀펑크 | A | 초상+전투3 | g02-people-frontier-v01 | 완료 | |
| pi_captain | 해적 선장 | 해적·바다 | A | 초상+전투3 | g02-people-frontier-v01 | 완료 | |
| pi_pirate | 해적 | 해적·바다 | A | 초상+전투3 | g02-people-frontier-v01 | 완료 | BS2 |
| we_sheriff | 보안관 | 서부 | A | 초상+전투3 | g02-people-frontier-v01 | 완료 | |
| we_gunslinger | 총잡이 | 서부 | A | 초상+전투3 | g02-people-frontier-v01 | 완료 | BS2 |
| icon_mo_pistol | 권총 | 현대·도시 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_mo_smartphone | 스마트폰 | 현대·도시 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_ho_planchette | 위자 플랑셰트 | 호러·오컬트 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_sf_ray_gun | 광선총 | SF·우주 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_cp_cyberdeck | 사이버덱 | 사이버펑크 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_sp_pocket_watch | 톱니 회중시계 | 스팀펑크 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_pa_gas_mask | 방독면 | 포스트아포칼립스 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_pi_flintlock | 부싯돌 권총 | 해적·바다 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_we_revolver | 리볼버 | 서부 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| icon_we_sheriff_star | 보안관 별 배지 | 서부 | A | 아이콘 | g02-icons-genre-v01 | 완료 | |
| ui_mo_panel | 현대 알림 창틀 | 현대·도시 | A | UI 9-slice | g02-ui-genre-v01 | 완료 | |
| ui_sf_panel | SF 홀로 창틀 | SF·우주 | A | UI 9-slice | g02-ui-genre-v01 | 완료 | |
| ui_we_panel | 서부 나무판 창틀 | 서부 | A | UI 9-slice | g02-ui-genre-v01 | 완료 | |
| fx_mo_muzzle_flash | 총구 섬광 | 현대·도시 | A | 효과 5칸 | g02-fx-genre-v01 | 완료 | |
| fx_ho_possession | 빙의 검은 연기 | 호러·오컬트 | A | 효과 5칸 | g02-fx-genre-v01 | 완료 | |
| fx_sf_laser_hit | 레이저 적중 | SF·우주 | A | 효과 5칸 | g02-fx-genre-v01 | 완료 | |
| fx_sp_steam_burst | 증기 분출 | 스팀펑크 | A | 효과 5칸 | g02-fx-genre-v01 | 완료 | |

## B — 흔히 쓰는 것 (45)

| ID | 이름 | 장르 | 우선순위 | 형식 | 묶음 | 상태 | 비고 |
|---|---|---|---|---|---|---|---|
| df_gentleman | 신사 | 다크 판타지·고딕 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | BS2 |
| df_maid | 하녀(시종) | 다크 판타지·고딕 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | BS2 시종 |
| df_detective | 탐정(빅토리아풍) | 다크 판타지·고딕 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | BS2 탐정 |
| df_plague_doctor | 역병 의사 | 다크 판타지·고딕 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| df_nun | 수녀 | 다크 판타지·고딕 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_merchant | 상인 | 중세 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_blacksmith | 대장장이 | 중세 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_archer | 궁수 | 중세 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_cook | 요리사 | 중세 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | BS2 |
| mf_winter_mage | 겨울 마법사 | 중세 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | BS2 |
| ef_shrine_maiden | 무녀 | 동양 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_swordsman | 협객(무협 검객) | 동양 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_taoist | 도사 | 동양 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_constable | 포졸 | 동양 판타지 | B | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mo_detective | 형사 | 현대·도시 | B | 초상+전투1 | g02-people-modern-v01 | 대기 | BS2 |
| mo_principal | 교장 | 현대·도시 | B | 초상+전투1 | g02-people-modern-v01 | 대기 | BS2 |
| ho_patient | 환자 | 호러·오컬트 | B | 초상+전투1 | g02-people-modern-v01 | 대기 | BS2 |
| ho_clown | 광대 | 호러·오컬트 | B | 초상+전투1 | g02-people-modern-v01 | 대기 | BS2 |
| sf_captain | 우주 함장 | SF·우주 | B | 초상+전투1 | g02-people-future-v01 | 대기 | |
| sf_scientist | 과학자 | SF·우주 | B | 초상+전투1 | g02-people-future-v01 | 대기 | |
| cp_merc | 사이버 용병 | 사이버펑크 | B | 초상+전투1 | g02-people-future-v01 | 대기 | |
| pa_raider | 약탈자 | 포스트아포칼립스 | B | 초상+전투1 | g02-people-future-v01 | 대기 | |
| sp_airship_captain | 비행선 선장 | 스팀펑크 | B | 초상+전투1 | g02-people-frontier-v01 | 대기 | |
| pi_sailor | 선원 | 해적·바다 | B | 초상+전투1 | g02-people-frontier-v01 | 대기 | BS2 |
| we_cowboy | 카우보이 | 서부 | B | 초상+전투1 | g02-people-frontier-v01 | 대기 | |
| icon_mo_police_badge | 경찰 배지 | 현대·도시 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_ho_camcorder | 심령 캠코더 | 호러·오컬트 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_ho_emf | 유령 탐지기(EMF) | 호러·오컬트 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_sf_energy_cell | 에너지 셀 | SF·우주 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_sf_scanner | 휴대 스캐너 | SF·우주 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_cp_neural_chip | 신경 칩 | 사이버펑크 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_sp_goggles | 황동 고글 | 스팀펑크 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_sp_steam_pistol | 증기 권총 | 스팀펑크 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_pa_canned_food | 찌그러진 통조림 | 포스트아포칼립스 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_pa_geiger | 방사능 측정기 | 포스트아포칼립스 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_pi_spyglass | 망원경 | 해적·바다 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_pi_treasure_map | 보물 지도 | 해적·바다 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_we_lasso | 올가미 밧줄 | 서부 | B | 아이콘 | g02-icons-genre-v01 | 대기 | |
| ui_ho_panel | 호러 긁힌 창틀 | 호러·오컬트 | B | UI 9-slice | g02-ui-genre-v01 | 대기 | |
| ui_cp_panel | 사이버펑크 네온 창틀 | 사이버펑크 | B | UI 9-slice | g02-ui-genre-v01 | 대기 | |
| ui_pi_panel | 해적 밧줄 창틀 | 해적·바다 | B | UI 9-slice | g02-ui-genre-v01 | 대기 | |
| fx_cp_glitch | 해킹 글리치 | 사이버펑크 | B | 효과 5칸 | g02-fx-genre-v01 | 대기 | |
| fx_pa_radiation | 방사능 파동 | 포스트아포칼립스 | B | 효과 5칸 | g02-fx-genre-v01 | 대기 | |
| fx_pi_cannon_smoke | 대포 연기 | 해적·바다 | B | 효과 5칸 | g02-fx-genre-v01 | 대기 | |
| fx_we_dust | 흙먼지 | 서부 | B | 효과 5칸 | g02-fx-genre-v01 | 대기 | |

## C — 있으면 좋은 것 (42)

| ID | 이름 | 장르 | 우선순위 | 형식 | 묶음 | 상태 | 비고 |
|---|---|---|---|---|---|---|---|
| df_gravedigger | 묘지기 | 다크 판타지·고딕 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| df_witch | 마녀 | 다크 판타지·고딕 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | 사람 마녀 |
| df_black_knight | 흑기사 | 다크 판타지·고딕 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| df_executioner | 사형 집행인 | 다크 판타지·고딕 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | 두건, 피 없음 |
| df_butler | 집사 | 다크 판타지·고딕 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_thief | 도적 | 중세 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_king | 왕 | 중세 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_princess | 공주 | 중세 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_lord | 귀족 영주 | 중세 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mf_bard | 음유시인 | 중세 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_martial_artist | 권법가 | 동양 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_scholar | 선비 | 동양 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_general | 장군 | 동양 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_court_lady | 궁중 여인 | 동양 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_wanderer | 삿갓 나그네 | 동양 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_shaman | 무당 | 동양 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| ef_herbalist | 약초꾼 | 동양 판타지 | C | 초상+전투1 | g02-people-fantasy-v01 | 대기 | |
| mo_santa | 산타 | 현대·도시 | C | 초상+전투1 | g02-people-modern-v01 | 대기 | BS2 |
| mo_baby | 아기 | 현대·도시 | C | 초상+전투1 | g02-people-modern-v01 | 대기 | BS2, 앉은 자세 |
| ho_exorcist | 퇴마사 | 호러·오컬트 | C | 초상+전투1 | g02-people-modern-v01 | 대기 | |
| ho_butcher | 도살자 | 호러·오컬트 | C | 초상+전투1 | g02-people-modern-v01 | 대기 | BS2, 피 없음 |
| ho_medium | 영매 | 호러·오컬트 | C | 초상+전투1 | g02-people-modern-v01 | 대기 | |
| sf_marine | 우주 해병 | SF·우주 | C | 초상+전투1 | g02-people-future-v01 | 대기 | |
| cp_agent | 기업 요원 | 사이버펑크 | C | 초상+전투1 | g02-people-future-v01 | 대기 | |
| cp_ripperdoc | 거리 의사 | 사이버펑크 | C | 초상+전투1 | g02-people-future-v01 | 대기 | |
| pa_scout | 방독면 정찰병 | 포스트아포칼립스 | C | 초상+전투1 | g02-people-future-v01 | 대기 | |
| sp_engineer | 기관사 | 스팀펑크 | C | 초상+전투1 | g02-people-frontier-v01 | 대기 | |
| pi_navy_officer | 해군 장교 | 해적·바다 | C | 초상+전투1 | g02-people-frontier-v01 | 대기 | |
| we_bounty_hunter | 현상금 사냥꾼 | 서부 | C | 초상+전투1 | g02-people-frontier-v01 | 대기 | |
| icon_ho_cassette | 카세트 녹음기 | 호러·오컬트 | C | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_sf_oxygen_tank | 산소통 | SF·우주 | C | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_cp_cred_chip | 크레딧 칩 | 사이버펑크 | C | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_cp_mono_blade | 단분자 칼 | 사이버펑크 | C | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_sp_clockwork_key | 태엽 열쇠 | 스팀펑크 | C | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_pa_jerrycan | 연료통 | 포스트아포칼립스 | C | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_pi_rum | 럼주 병 | 해적·바다 | C | 아이콘 | g02-icons-genre-v01 | 대기 | |
| icon_we_dynamite | 다이너마이트 | 서부 | C | 아이콘 | g02-icons-genre-v01 | 대기 | |
| ui_sp_panel | 황동 리벳 창틀 | 스팀펑크 | C | UI 9-slice | g02-ui-genre-v01 | 대기 | |
| ui_pa_panel | 녹슨 철판 창틀 | 포스트아포칼립스 | C | UI 9-slice | g02-ui-genre-v01 | 대기 | |
| fx_ho_wail | 비명 파동 | 호러·오컬트 | C | 효과 5칸 | g02-fx-genre-v01 | 대기 | |
| fx_sf_plasma_burst | 플라스마 폭발 | SF·우주 | C | 효과 5칸 | g02-fx-genre-v01 | 대기 | |
| fx_pa_shrapnel | 고철 파편 튀김 | 포스트아포칼립스 | C | 효과 5칸 | g02-fx-genre-v01 | 대기 | |

## A 뒤 추가 (g01_bs2_inventory.md 재확인)

A 단계가 끝나면 `g01_bs2_inventory.md`를 다시 확인해서 새로 생긴 g02 몫을 여기에 더한다.
