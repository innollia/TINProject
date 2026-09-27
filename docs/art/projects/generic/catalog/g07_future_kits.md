# g07 목록 — 앞으로 나올 법한 키트와 그 키트가 쓸 범용 에셋

세션 g07(범용 에셋, 이 컴퓨터에서 직접 작업). 규칙: `docs\art\mass_production\COMMON.md` + `GENERIC.md`. 그림은 at-icons 모양을 잘라 겹친 조합으로만 만들고, 결과는 전부 candidate다. 승인은 사용자만 한다. 글자·숫자·워터마크는 넣지 않는다(주사위 눈, 점, 기호 도형은 도형으로 조립).

## 맡은 종류 (GENERIC.md '그 밖의 종류' 규칙에 따라 먼저 적음)

사장님 지시(2026-09-27): "이 프로젝트 전체를 둘러보고 통찰력으로 판단해. '이런 키트가 나올 수도 있겠군. 그러면 이런 에셋이 필요하겠지?'"

- g07이 맡는 것: 장르별 전용 장치(교환대, 검색대, 등대 렌즈, 해치 같은 60도 오브젝트), 계기판·조작 부품(계기, 바늘, 스위치, 레버, 잭), 특수 화면 UI(탐지 화면, 파형, 레트로 OS, 리듬 레인, 도장 자국, 뷰파인더), 협업·보드게임 조각(말, 주사위, 카드 틀, 증거 게시판), 시뮬 오브젝트(컨베이어, 컨테이너, 채굴 바위, 파편 더미).
- 겹치지 않게 뺀 것: 판타지 아이콘·UI·효과(g01), 사람과 판타지 밖 장르 소지품·창틀·효과(g02), 바닥·벽·전투 배경(g03), g04 목록에 있는 오브젝트 전부(자판기, SF 조종 콘솔, 냉동 캡슐, 증기 보일러, 신호등, 네온 간판, 브라운관 TV, 공중전화, 거리 단말기, 철도 신호기, 철창 승강기, 등대 건물, 계산대, 톱니바퀴 장치 등), 생물(g05), 03 키트 그림(g06). 효과 애니메이션(빛줄기, 섬광, 연기)은 그리지 않고, 게임이 돌리거나 켜는 UI 부품과 `_emit`만 둔다.
- GENERIC.md의 g07 기본 담당(판타지 장비 상세 그림, 편지·지도 같은 문서 종이 그림, 메뉴·타이틀·로딩 배경)은 이번 지시 범위가 아니라서 만들지 않았다. 다른 세션이 그 담당을 해도 겹치지 않게 종이 문서류와 메뉴 배경은 이 목록에 넣지 않았다.

## 조사 요약 (무엇을 보고 판단했나)

- 키트 계획서: `plans\kits\INDEX.md`와 01~08, 05 Query World, 44 Stacking Descent. 뭉탱이 계획 `plans\bundles\01_THE_LOST_WORD.md`(질의 세계 ↔ 추리 ↔ 규칙), `02_STACK_AND_FALL.md`(쌓기 ↔ 하강).
- 조사 문서: `docs\research\novel_genre\GENRE_INVENTION_SURVEY_2026-09-26.md`(Gnorp Apologue, NEEDY STREAMER OVERLOAD, Legal Dungeon, ENA), `AWARD_IDEA_CATALOG_2026-09-26.md`(Her Story, Hypnospace Outlaw, Cart Life, Keep Talking and Nobody Explodes, Spaceteam, Exit 8, Blaseball), `QUERY_WORLD_KIT_DIRECTION_2026-09-27.md`, `round_2026_09_26\ROUND_PLAN.md`.
- 모듈 42개: 이름과 코드 안의 안내 문구를 훑었다. 같은 모티프가 여러 모듈에 되풀이된다 — 주파수 90·100·110과 회선 연결(signal_desk, switchboard_choir, relay_quay, return_cradle, lost_signal_vn, after_signal), 배달·주소·우편함(signal_desk, return_address, after_signal), 도장과 통과표(memory_customs), 기상 송출(wrong_weather, quiet_locker), 등대와 선착장(paper_lighthouse, shadow_ferry), 수조 관찰·증상 진찰(afterimage_aquarium, paper_moon_clinic), 계산대 순서(receipt_orchard), 세 박자·세 음(time_loop, switchboard_choir), 용의자×수단×동기 판정(violet_case, dedution_casework), 층 이동·정비 점검판·힘 전달(rain_lift, maintenance_cut, physics_toolbox, box_mover), 가짜 타이틀·메뉴 위를 걷기(borrowed_title, last_echo), 바퀴 세기·클릭 세기(teacup_orbit, click_counter), 파편 쌓기(stacking_descent).
- 판단: 작은 모듈들은 새 키트의 씨앗이다. 이 씨앗이 키트로 커지면 공통으로 "장치를 조작하는 화면"이 필요한데, 지금 범용 목록(g01~g06)에는 계기·스위치·잭·탐지 화면·리듬 레인·레트로 OS·보드게임 조각·시뮬 장치가 하나도 없다.

## 앞으로 나올 법한 키트 12종

| 코드 | 키트(가칭) | 근거(모듈·조사) | 핵심 장면 | g07 에셋 | 같이 쓸 기존 에셋(다른 세션) |
|---|---|---|---|---|---|
| K1 | 교환대·무전실 | switchboard_choir, signal_desk, relay_quay, lost_signal_vn, after_signal / Spaceteam·KTANE(말로 하는 협동) | 잭을 꽂아 회선을 잇고, 주파수를 맞추고, 신호 세기를 보며 교신 | 계기·바늘·토글·버튼·표시등·손잡이·잭·코드, 파형·탐지 화면, 주파수 창, 다이얼, 키패드, 교환대, 무전 책상, 전신기, 안테나 | g04 obj_desk·obj_chair, g02 icon_ho_cassette |
| K2 | 우편·세관 창구 | signal_desk(배달국), return_address, after_signal(우편함), memory_customs(도장), quiet_locker / Legal Dungeon·Papers Please형 서류 노동 | 소포를 분류하고, 엑스선으로 들여다보고, 통과·반려 도장을 찍는다 | 도장 자국, 엑스선 판독 틀, 분류 칸 선반, 엑스선 검색대, 개찰구, 검문 부스, 사물함 벽, 소포 저울, 행낭 수레, 미끄럼틀, 컨베이어 | g04 obj_shelf·obj_crate·obj_counter_shop |
| K3 | 기상 방송국 | wrong_weather(틀린 일기예보 송출), quiet_locker(기상 방송실), glasshouse_return, rain_lift | 창밖 현상을 보고 예보 기호를 골라 송출한다 | 예보 기호 10종(위로 내리는 비, 실내만 눈 포함), 일기도 전선 띠, 방송 하단 띠, 온도 계기, 풍향·풍속계, 우량계, 방송 카메라, 송출 표시등, 안테나 | g01 ov_rain·ov_snow·ov_fog_light, g04 obj_tv_crt |
| K4 | 안개 등대지기 | paper_lighthouse(세 등대의 빛), shadow_ferry(선착장), return_cradle(정박지) | 렌즈를 돌리고 무적을 울려 안개 속 배를 선착장으로 부른다 | 등대 렌즈, 무적, 종 부표, 수로 부표, 계류 기둥, 크랭크, 탐지 화면, 수심계 | g04 obj_lighthouse·obj_rowboat·obj_anchor_large |
| K5 | 잠수함 심해 생존 | descent_exploration(바다 하강 허용, 08 Swallow the Sea 유사), stacking_descent(하강), afterimage_aquarium | 압력·산소 계기를 보며 밸브를 돌리고 해치를 닫고 소나로 길을 찾는다 | 원형·세로·반원 계기, 밀대 레버, 비상 버튼, 탐지 화면, 잠망경 시야, 해치, 밸브 핸들, 잠망경, 격벽 문, 둥근 창, 경고 줄무늬 | g04 obj_sf_capsule, g02 icon_sf_oxygen_tank |
| K6 | 철도·항구 물류 | relay_quay(부품 배달), rain_lift(층 이동), maintenance_cut(정비 점검판), physics_toolbox·box_mover(힘 전달·밀기) | 컨베이어와 기중기로 화물을 옮기고, 전령기로 배를 대고, 선로를 바꾼다 | 컨베이어 칸, 컨테이너, 팔레트, 기중기 갈고리, 화물 차량, 선로 칸, 기관 전령기, 속도계, 선택 손잡이, 출발 안내판 틀 | g04 obj_rail_signal·obj_cage_lift·obj_crate·obj_barrel |
| K7 | 가게·노점 경영 | receipt_orchard(계산대 순서) / Cart Life(노점 생계) | 물건을 진열하고, 무게를 달고, 계산하고, 서랍을 연다 | 금전 등록기, 진열 유리장, 소포 저울 | g04 obj_counter_shop·obj_market_stall, g01 icon_coins_gold |
| K8 | 리듬·합창 | switchboard_choir(세 음 연결), time_loop(세 박자), teacup_orbit(일곱 바퀴), glyph_gallery(낮은 종) | 레인을 내려오는 노트를 판정선에서 맞히고 종을 울린다 | 리듬 레인·판정선, 노트, 판정 과녁, 박자 점, 신호 세기 막대, 음 종 받침대, 보면대 | g04 obj_piano·obj_phonograph, g01 ui_balloon_note |
| K9 | 탐정 보드게임 | violet_case(용의자·수단·동기), dedution_casework(판정표) / Clue형 | 말을 옮기고 주사위를 굴리고 카드로 추리하고 게시판에 실을 잇는다 | 말 6색, 주사위 6면, 표식 칩, 카드 틀·뒷면, 증거 게시판 | g04 obj_desk, g01 icon_hourglass |
| K10 | 이상 현상 관찰(유령 탐방·진료소·수족관) | afterimage_aquarium(잔상), paper_moon_clinic(증상 진찰), time_loop / Exit 8(이상 찾기), Streamer Screamer | 캠코더로 이상한 점을 찍고, 모니터를 보고, 수조를 관찰한다 | 뷰파인더 테, 교령회 탁자, 유령 포획 장치, 소금 원, 심장 박동 모니터, 관찰 수조, 파형 화면 | g02 icon_ho_emf·icon_ho_camcorder·icon_ho_planchette, g04 obj_mirror_standing |
| K11 | 데스크톱 OS 세계 | query_world(조회 단말), borrowed_title·last_echo(가짜 메뉴 위 걷기) / NEEDY STREAMER OVERLOAD, Hypnospace Outlaw, Her Story | 창을 열고 아이콘을 누르고 메신저로 대화하고 방송한다 | OS 창틀·창 버튼·커서·진행 막대·툴팁·작업 표시줄, 데스크톱 아이콘 11종, 조회 단말·파편 카드, 말풍선, 원형 진행 | g02 ui_mo_panel·icon_mo_smartphone, g04 obj_tv_crt |
| K12 | 시각적 인크리멘털(채굴·쌓기) | click_counter, teacup_orbit, stacking_descent(파편) / Gnorp Apologue(대량 시뮬레이션이 보이는 인크리멘털) | 바위를 깨서 파편 더미를 키우고 업그레이드 마디를 산다 | 채굴 바위 4상태, 파편 더미 3단계, 광차, 업그레이드 마디, 점수판 틀, 진행 막대, 주사위 | g04 obj_rocks_small·obj_crystal_rock, g01 icon_gem_red |

## 형식

| 표시 | 뜻 |
|---|---|
| 계기 192 / 계기 384 | 정면 평면 UI 부품, 투명 PNG 192×192(또는 384×384). 게임이 돌리거나 움직이는 부분(바늘, 손잡이, 커서)은 따로 그리고 회전 중심·접점을 manifest `pivot`에 적는다. 켜진 불빛은 `_emit.png` |
| 9칸 | 글자 없는 9-slice. 192×192(모서리 48)가 기본, 크기가 다르면 칸에 적음. 9조각 PNG + `_9s.json` + 늘린 확인 그림 |
| 이음 띠 | 가로로 끝없이 이어지는 띠(좌우 끝이 맞물림) |
| 화면 가림 2560 | 2560×1440 투명 PNG 화면 틀(UI 가림막). 글자·캐릭터 없음 |
| 아이콘 | 128×128 평면 한 장 + 한 줄 16칸 시트 |
| 오브젝트 | 60도 탑다운 투명 PNG(원본 2배), 바닥 접촉 피벗(벽에 붙는 것은 붙는 자리), 그림자 `_shadow.png`, 빛 `_emit.png`, 상태 그림은 같은 캔버스·피벗의 프레임 |
| 타일 192 | 192 칸 크기로 이어 까는 오브젝트 칸(60도, 이웃 칸과 맞물림) |

크기(오브젝트, g04와 같게): 폭 180 px/m, 바닥 깊이 156 px/m(×0.866), 높이 105 px/m.

묶음(작업 폴더 `assets\art\generic\jobs\<묶음>\` + `docs\art\projects\generic\jobs\<묶음>\`): g07-controls-v01 계기·조작 부품 / g07-screens-v01 화면·특수 UI / g07-icons-v01 특수 아이콘 / g07-devices-v01 장르 전용 장치 / g07-sim-v01 시뮬·채굴 오브젝트.

상태: 대기 / 완료 / 건너뜀.

## A — 꼭 있어야 할 기본 (42)

| # | 이름 | 자산 ID | 근거 키트 | 형식 | 묶음 | 상태 |
|---|---|---|---|---|---|---|
| 1 | 원형 계기판(눈금·빨간 구간) | ui_ctl_gauge_round | K1 K4 K5 K6 | 계기 192 | g07-controls-v01 | 완료 |
| 2 | 계기 바늘 2종(가는·화살) | ui_ctl_needle | K1 K4 K5 K6 | 계기 192, 회전 중심 피벗 | g07-controls-v01 | 완료 |
| 3 | 토글 스위치(내림·올림) | ui_ctl_toggle | K1 K5 K6 | 계기 192, 2상태 | g07-controls-v01 | 완료 |
| 4 | 누름 버튼 3색(꺼짐·켜짐) | ui_ctl_button | K1 K5 K10 K11 | 계기 192, 6상태 | g07-controls-v01 | 완료 |
| 5 | 보호망 표시등 4색(꺼짐·켜짐) | ui_ctl_lamp | 전 키트 | 계기 192, 8상태 | g07-controls-v01 | 완료 |
| 6 | 회전 손잡이(눈금판·손잡이 따로) | ui_ctl_knob | K1 K3 K8 | 계기 192, 2장 | g07-controls-v01 | 완료 |
| 7 | 밀대 레버(홈판·손잡이 따로) | ui_ctl_throttle | K5 K6 | 계기 192×384 + 192 | g07-controls-v01 | 완료 |
| 8 | 덮개 달린 비상 버튼(닫힘·열림·눌림) | ui_ctl_emergency | K1 K5 K10 | 계기 192, 3상태 | g07-controls-v01 | 완료 |
| 9 | 교환대 잭(빈 구멍·꽂힘·플러그) | ui_ctl_jack | K1 | 계기 192, 3상태 | g07-controls-v01 | 완료 |
| 10 | 패치 코드 줄 3색 | ui_ctl_cable | K1 | 이음 띠 192×48 | g07-controls-v01 | 완료 |
| 11 | 원형 탐지 화면 + 훑는 부채꼴 + 점 | ui_scr_sonar | K1 K4 K5 | 계기 384 + 384 + 192 | g07-screens-v01 | 완료 |
| 12 | 파형 화면 + 파형 띠 3종 | ui_scr_wave | K1 K8 K10 | 576×384 + 이음 띠 480×128 | g07-screens-v01 | 완료 |
| 13 | 레트로 OS 창틀(활성·비활성) | ui_os_window | K11 | 9칸 | g07-screens-v01 | 완료 |
| 14 | OS 창 버튼 3종(보통·누름) | ui_os_titlebtn | K11 | 128, 6상태 | g07-screens-v01 | 완료 |
| 15 | 레트로 커서 4종(화살·기다림·손·글자 막대) | ui_os_cursor | K11 | 128, 4종, 핫스팟 manifest | g07-screens-v01 | 완료 |
| 16 | 진행 막대 틀 + 채움 칸 3색 | ui_os_progress | K11 K12 | 9칸 192×48 + 칸 48 | g07-screens-v01 | 완료 |
| 17 | 도장 자국 4종 × 잉크 2색 | ui_stamp_mark | K2 | 192, 8종 | g07-screens-v01 | 완료 |
| 18 | 리듬 레인 + 판정선 | ui_rhythm_lane | K8 | 9칸 | g07-screens-v01 | 완료 |
| 19 | 리듬 노트(탭 2색·홀드 머리·몸·꼬리) | ui_rhythm_note | K8 | 192, 5종 | g07-screens-v01 | 완료 |
| 20 | 판정 과녁(대기·맞음·놓침) | ui_rhythm_target | K8 | 192, 3상태 | g07-screens-v01 | 완료 |
| 21 | 캠코더 뷰파인더 테(녹화·대기) | ui_scr_viewfinder | K10 K11 | 화면 가림 2560 | g07-screens-v01 | 완료 |
| 22 | 예보 기호: 맑음 | icon_fc_sun | K3 | 아이콘 | g07-icons-v01 | 완료 |
| 23 | 예보 기호: 흐림 | icon_fc_cloud | K3 | 아이콘 | g07-icons-v01 | 완료 |
| 24 | 예보 기호: 비 | icon_fc_rain | K3 | 아이콘 | g07-icons-v01 | 완료 |
| 25 | 예보 기호: 위로 내리는 비 | icon_fc_rain_up | K3 | 아이콘 | g07-icons-v01 | 완료 |
| 26 | 데스크톱 아이콘: 폴더 | icon_os_folder | K11 | 아이콘 | g07-icons-v01 | 완료 |
| 27 | 데스크톱 아이콘: 휴지통 | icon_os_trash | K11 | 아이콘 | g07-icons-v01 | 완료 |
| 28 | 데스크톱 아이콘: 파일 | icon_os_file | K11 | 아이콘 | g07-icons-v01 | 완료 |
| 29 | 데스크톱 아이콘: 메신저 | icon_os_chat | K11 | 아이콘 | g07-icons-v01 | 완료 |
| 30 | 보드게임 말 6색 | icon_bg_pawn | K9 | 아이콘, 6색 | g07-icons-v01 | 완료 |
| 31 | 주사위 눈 1~6 | icon_bg_die | K9 K12 | 아이콘, 6면 | g07-icons-v01 | 완료 |
| 32 | 전화 교환대(쉼·통화 중) | obj_switchboard | K1 | 오브젝트, 2상태 | g07-devices-v01 | 완료 |
| 33 | 무전 송수신기 책상(꺼짐·켜짐) | obj_radio_desk | K1 K3 | 오브젝트, 2상태 | g07-devices-v01 | 완료 |
| 34 | 우편 분류 칸 선반(빔·가득) | obj_sorting_rack | K2 | 오브젝트, 2상태 | g07-devices-v01 | 완료 |
| 35 | 엑스선 수하물 검색대(꺼짐·켜짐) | obj_xray_scanner | K2 | 오브젝트, 2상태 | g07-devices-v01 | 완료 |
| 36 | 회전식 개찰구(잠김·열림) | obj_turnstile | K2 K6 | 오브젝트, 2상태 | g07-devices-v01 | 완료 |
| 37 | 등대 렌즈 장치(꺼짐·켜짐) | obj_lighthouse_lens | K4 | 오브젝트, 2상태 | g07-devices-v01 | 완료 |
| 38 | 잠수함 원형 해치(닫힘·열림) | obj_sub_hatch | K5 | 오브젝트(바닥), 2상태 | g07-devices-v01 | 완료 |
| 39 | 금전 등록기(닫힘·열림) | obj_cash_register | K7 | 오브젝트(카운터 위), 2상태 | g07-devices-v01 | 완료 |
| 40 | 증거 게시판(빈 판·핀과 실) | obj_evidence_board | K9 K10 | 오브젝트, 2상태 | g07-devices-v01 | 완료 |
| 41 | 컨베이어 벨트 칸(가로·세로 × 움직임 3칸) | obj_conveyor | K2 K6 K12 | 타일 192, 6프레임 | g07-sim-v01 | 완료 |
| 42 | 채굴 바위(멀쩡·금 1·금 2·부서짐) | obj_ore_rock | K12 | 오브젝트, 4상태 | g07-sim-v01 | 완료 |

## B — 흔히 쓰는 것 (44)

| # | 이름 | 자산 ID | 근거 키트 | 형식 | 묶음 | 상태 |
|---|---|---|---|---|---|---|
| 43 | 세로 수심계(눈금관·표시 막대 따로) | ui_ctl_gauge_depth | K5 K4 | 계기 192×384 + 192 | g07-controls-v01 | 대기 |
| 44 | 온도 기둥 계기(유리관·채움 따로) | ui_ctl_gauge_thermo | K3 K5 | 계기 192×384 + 이음 채움 | g07-controls-v01 | 대기 |
| 45 | 반원 잔량 계기(연료·산소) | ui_ctl_gauge_half | K5 K6 | 계기 192 | g07-controls-v01 | 대기 |
| 46 | 기관 전령기(원판·손잡이 따로) | ui_ctl_telegraph | K6 K5 | 계기 384 | g07-controls-v01 | 대기 |
| 47 | 주파수 눈금창 + 선 커서 | ui_ctl_tuner | K1 K2 | 384×192 + 192 | g07-controls-v01 | 대기 |
| 48 | 신호 세기 칸 막대(0~5칸) | ui_ctl_meter | K1 K8 | 192, 6상태 | g07-controls-v01 | 대기 |
| 49 | 기호 키패드(숫자 없음) | ui_ctl_keypad | K1 K10 | 계기 384 | g07-controls-v01 | 대기 |
| 50 | 회전식 전화 다이얼(받침·구멍판 따로) | ui_ctl_dial | K1 | 계기 384 | g07-controls-v01 | 대기 |
| 51 | 3단 선택 손잡이 | ui_ctl_selector | K1 K6 | 192, 3상태 | g07-controls-v01 | 대기 |
| 52 | 계기판 바탕 판(리벳) | ui_ctl_panel | 공통 | 9칸 | g07-controls-v01 | 대기 |
| 53 | 조회 단말 틀 + 입력칸 | ui_scr_terminal | K11 | 9칸 2종 | g07-screens-v01 | 대기 |
| 54 | 파편 카드 틀(찢긴 가장자리) | ui_scr_fragment | K11 | 9칸 | g07-screens-v01 | 대기 |
| 55 | 메신저 말풍선(왼쪽·오른쪽) | ui_os_bubble | K11 | 9칸 2종 | g07-screens-v01 | 대기 |
| 56 | 잠망경 시야 틀 | ui_scr_periscope | K5 | 화면 가림 2560 | g07-screens-v01 | 대기 |
| 57 | 방송 하단 띠 + 송출 표식 | ui_scr_broadcast | K3 | 9칸 + 192 | g07-screens-v01 | 대기 |
| 58 | 일기도 전선 띠(온난·한랭) | ui_scr_front | K3 | 이음 띠 384×96 | g07-screens-v01 | 대기 |
| 59 | 엑스선 판독 틀 + 훑는 선 | ui_scr_xray | K2 | 9칸 + 192 | g07-screens-v01 | 대기 |
| 60 | 업그레이드 마디(잠김·열림·삼) + 잇는 선 | ui_upgrade_node | K12 | 192, 3상태 + 이음 띠 | g07-screens-v01 | 대기 |
| 61 | 보드게임 카드 틀 3색 + 뒷면 | ui_bg_card | K9 | 256×384, 4종 | g07-screens-v01 | 대기 |
| 62 | 예보 기호: 눈 | icon_fc_snow | K3 | 아이콘 | g07-icons-v01 | 대기 |
| 63 | 예보 기호: 폭풍 | icon_fc_storm | K3 | 아이콘 | g07-icons-v01 | 대기 |
| 64 | 예보 기호: 안개 | icon_fc_fog | K3 K4 | 아이콘 | g07-icons-v01 | 대기 |
| 65 | 예보 기호: 실내만 눈 | icon_fc_snow_indoor | K3 | 아이콘 | g07-icons-v01 | 대기 |
| 66 | 데스크톱 아이콘: 우편함 | icon_os_mail | K11 K2 | 아이콘 | g07-icons-v01 | 대기 |
| 67 | 데스크톱 아이콘: 웹 둘러보기 | icon_os_web | K11 | 아이콘 | g07-icons-v01 | 대기 |
| 68 | 데스크톱 아이콘: 설정 | icon_os_settings | K11 | 아이콘 | g07-icons-v01 | 대기 |
| 69 | 데스크톱 아이콘: 명령창 | icon_os_terminal | K11 | 아이콘 | g07-icons-v01 | 대기 |
| 70 | 데스크톱 아이콘: 방송 캠 | icon_os_webcam | K11 | 아이콘 | g07-icons-v01 | 대기 |
| 71 | 전신기 책상 | obj_telegraph_desk | K1 | 오브젝트 | g07-devices-v01 | 대기 |
| 72 | 안테나 탑(등 꺼짐·켜짐) | obj_antenna_mast | K1 K3 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 73 | 소포 저울 | obj_parcel_scale | K2 K7 | 오브젝트 | g07-devices-v01 | 대기 |
| 74 | 검문 부스(차단봉 내림·올림) | obj_checkpoint_booth | K2 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 75 | 사물함 벽(닫힘·열림) | obj_locker_bank | K2 K10 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 76 | 풍향·풍속계 기둥 | obj_weather_mast | K3 | 오브젝트 | g07-devices-v01 | 대기 |
| 77 | 방송 카메라(꺼짐·켜짐) | obj_studio_camera | K3 K11 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 78 | 무적(안개 나팔) | obj_fog_horn | K4 | 오브젝트 | g07-devices-v01 | 대기 |
| 79 | 종 부표 | obj_bell_buoy | K4 K6 | 오브젝트(물 위) | g07-devices-v01 | 대기 |
| 80 | 밸브 핸들(벽) | obj_valve_wheel | K5 K6 | 오브젝트(벽 피벗) | g07-devices-v01 | 대기 |
| 81 | 잠망경 기둥(내림·올림) | obj_periscope | K5 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 82 | 진열 유리장(빔·가득) | obj_display_case | K7 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 83 | 교령회 탁자(촛불 꺼짐·켜짐) | obj_seance_table | K10 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 84 | 음 종 받침대 | obj_bell_rack | K8 | 오브젝트 | g07-devices-v01 | 대기 |
| 85 | 화물 컨테이너(닫힘·열림) | obj_container | K6 | 오브젝트, 2상태 | g07-sim-v01 | 대기 |
| 86 | 파편 더미(작음·중간·큼) | obj_shard_pile | K12 | 오브젝트, 3단계 | g07-sim-v01 | 대기 |

## C — 있으면 좋은 것 (34)

| # | 이름 | 자산 ID | 근거 키트 | 형식 | 묶음 | 상태 |
|---|---|---|---|---|---|---|
| 87 | 크랭크 손잡이(회전) | ui_ctl_crank | K4 K1 | 계기 192 | g07-controls-v01 | 대기 |
| 88 | 경고 줄무늬 테 | ui_ctl_hazard | K5 K6 | 9칸 | g07-controls-v01 | 대기 |
| 89 | 큰 속도계 | ui_ctl_speedo | K6 | 계기 384 | g07-controls-v01 | 대기 |
| 90 | 출발 안내판 틀 + 빈 판 조각 | ui_scr_flapboard | K6 | 9칸 + 96 칸 | g07-screens-v01 | 대기 |
| 91 | 툴팁 틀 | ui_os_tooltip | K11 | 9칸 | g07-screens-v01 | 대기 |
| 92 | 작업 표시줄 | ui_os_taskbar | K11 | 9칸 192×64 | g07-screens-v01 | 대기 |
| 93 | 박자 점 3개 | ui_rhythm_beat | K8 | 192, 4상태 | g07-screens-v01 | 대기 |
| 94 | 원형 진행 링(8칸) | ui_progress_ring | K11 K12 | 192, 9상태 | g07-screens-v01 | 대기 |
| 95 | 점수판 틀(숫자 칸 비움) | ui_scr_tally | K12 K8 | 9칸 | g07-screens-v01 | 대기 |
| 96 | 예보 기호: 바람 | icon_fc_wind | K3 | 아이콘 | g07-icons-v01 | 대기 |
| 97 | 예보 기호: 맑은 밤 | icon_fc_night | K3 | 아이콘 | g07-icons-v01 | 대기 |
| 98 | 데스크톱 아이콘: 음악 | icon_os_music | K11 K8 | 아이콘 | g07-icons-v01 | 대기 |
| 99 | 데스크톱 아이콘: 좋아요 | icon_os_heart | K11 | 아이콘 | g07-icons-v01 | 대기 |
| 100 | 데스크톱 아이콘: 따르는 사람 | icon_os_follower | K11 | 아이콘 | g07-icons-v01 | 대기 |
| 101 | 보드게임 표식 칩 3종(원·별·해골) | icon_bg_token | K9 K12 | 아이콘, 3종 | g07-icons-v01 | 대기 |
| 102 | 우편 행낭 수레 | obj_mail_cart | K2 | 오브젝트 | g07-devices-v01 | 대기 |
| 103 | 소포 미끄럼틀 | obj_parcel_chute | K2 K6 | 오브젝트 | g07-devices-v01 | 대기 |
| 104 | 우량계 | obj_rain_gauge | K3 | 오브젝트 | g07-devices-v01 | 대기 |
| 105 | 송출 표시등(벽) | obj_onair_lamp | K3 | 오브젝트(벽 피벗), 2상태 | g07-devices-v01 | 대기 |
| 106 | 계류 기둥 | obj_bollard | K4 K6 | 오브젝트 | g07-devices-v01 | 대기 |
| 107 | 수로 표지 부표(붉은·푸른) | obj_marker_buoy | K4 K6 | 오브젝트(물 위), 2종 | g07-devices-v01 | 대기 |
| 108 | 격벽 문(닫힘·열림) | obj_bulkhead_door | K5 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 109 | 둥근 창(벽) | obj_porthole | K5 | 오브젝트(벽 피벗) | g07-devices-v01 | 대기 |
| 110 | 보면대 | obj_music_stand | K8 | 오브젝트 | g07-devices-v01 | 대기 |
| 111 | 유령 포획 장치(닫힘·열림) | obj_ghost_trap | K10 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 112 | 소금 원(바닥) | obj_salt_circle | K10 | 오브젝트(바닥 레이어) | g07-devices-v01 | 대기 |
| 113 | 심장 박동 모니터(꺼짐·켜짐) | obj_heart_monitor | K10 | 오브젝트, 2상태 | g07-devices-v01 | 대기 |
| 114 | 관찰 수조 | obj_specimen_tank | K10 | 오브젝트 | g07-devices-v01 | 대기 |
| 115 | 짐 팔레트 | obj_pallet_stack | K6 | 오브젝트 | g07-sim-v01 | 대기 |
| 116 | 화물 차량 | obj_freight_wagon | K6 | 오브젝트 | g07-sim-v01 | 대기 |
| 117 | 선로 칸(직선·굽음) | obj_rail_tile | K6 | 타일 192 | g07-sim-v01 | 대기 |
| 118 | 광차(빈·가득) | obj_mine_cart | K12 | 오브젝트, 2상태 | g07-sim-v01 | 대기 |
| 119 | 컨베이어 끝·모퉁이 칸 | obj_conveyor_end | K2 K6 | 타일 192 | g07-sim-v01 | 대기 |
| 120 | 기중기 갈고리(빈·짐) | obj_crane_hook | K6 | 오브젝트(매달림 피벗), 2상태 | g07-sim-v01 | 대기 |

합계 120개 (A 42 · B 44 · C 34).
