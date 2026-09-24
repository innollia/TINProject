# Rule Rewrite Kit — Baba Is You 모드 생태계 조사

- 조사 기준일: 2026-09-24
- 범위: 공개 모드 저장소·모딩 안내·위키/커뮤니티 문서·레벨팩 소개의 기능, 버전, 출처와 라이선스 상태
- 작업 한계: 조사와 새 보고서 작성만 수행했다. 게임을 실행하거나 모드를 설치하지 않았고, 사용자가 제공한 캡처의 UI를 해석하지 않았다.
- 관련 TIN 상태: [Rule Rewrite 실제 레퍼런스 조사 보고서](RULE_REWRITE_REFERENCE_REPORT.md), [Grilling State](../GRILLING_STATE.md)의 확정된 METRIX 요구를 비교 기준으로 삼았다.

## 핵심 결과

1. **TIN의 METRIX 요구와 정확히 일치하는 공개 구현은 조사 범위에서 찾지 못했다.** 공개 사례에는 주변 이웃 판정, 같은 종류의 단위 이동 결합, HOLD, 레벨 간 지속, 재귀 메타텍스트 등이 각각 있지만, 닫힌 BOX 경계 인식·내부 물건 소유·경계만의 외부 충돌·이동 방향 안쪽 벽에 내부 물건을 붙이는 동작을 통합한 구현은 확인하지 못했다.
2. 파서와 모드 훅 사례는 구조 참고 자료다. Plasma 모드팩은 477c, Better Metatext는 478F, 공식 게임은 481d를 명시한다. 이 간격을 건너뛴 호환성은 확인되지 않았다. [Plasma 모드팩](https://github.com/PlasmaFlare/plasma-baba-mods), [Better Metatext](https://github.com/EmilyEmmi/Baba-Is-You---Metatext-Mod), [공식 481d 업데이트](https://hempuli.itch.io/baba/devlog/1285463/version-481d)
3. **코드 라이선스가 확인되지 않은 모드는 채택 후보가 아니다.** 조사한 저장소 중 Patashu Pata Redux는 README에 출처표기 조건의 사용·수정 허가를 명시한다. 나머지 다수는 저장소/배포 페이지에서 라이선스 허가를 확인하지 못했다. 이는 “자유 사용”을 뜻하지 않는다. [Pata Redux README](https://github.com/Patashu/Baba-is-You-Pata-Redux-Mods)
4. 이 문서는 화면·메뉴·HUD를 판단하지 않는다. 사용자가 제공한 UI 캡처 판독은 사용자 지정 범위에 남긴다.

## 증거 수준과 범위

- **코드/README 확인**: 공개 저장소의 코드 또는 저자가 쓴 README가 해당 구조·기능을 명시한다. 특정 빌드에서 실행해 재현했다는 뜻은 아니다.
- **공식 업데이트**: 개발자 배포 노트가 기능·버전·모드 API 추가를 명시한다. 업데이트 노트가 밝히지 않은 동작 의미는 추정하지 않는다.
- **커뮤니티 설명**: Fandom, 일본어 위키, 영상·레벨팩 소개의 설명이다. 버전별 실행 파일 검증을 대신하지 않는다.
- **미확인**: 배포 소스·게임 버전·라이선스·런타임 세이브 계약을 자료에서 확정하지 못한 부분이다.

Baba Is You Fandom Wiki는 커뮤니티 문서이며 페이지별 예외가 없는 한 CC BY-SA로 표시한다. [Fandom 라이선스](https://www.fandom.com/licensing), [Baba Is You Wiki](https://babaiswiki.fandom.com/wiki/Baba_Is_You_Wiki). 이 조사에서는 규칙을 요약·인용하고 위키 문장/이미지를 복제하지 않았다.

오브젝트·단어·문법의 범위는 개별 업데이트 노트만으로 한정하지 않았다. [Nouns](https://babaiswiki.fandom.com/wiki/Category:Nouns), [Properties](https://babaiswiki.fandom.com/wiki/Category:Properties), [Operators](https://babaiswiki.fandom.com/wiki/Category:Operators), [Conditions](https://babaiswiki.fandom.com/wiki/Category:Conditions), [Word Templates](https://babaiswiki.fandom.com/wiki/Category:Word_Templates), [Rule](https://babaiswiki.fandom.com/wiki/Rule), [WORD](https://babaiswiki.fandom.com/wiki/WORD), [Level Data](https://babaiswiki.fandom.com/wiki/Level_Data), [Removed/Unused Content](https://babaiswiki.fandom.com/wiki/Unused_and_Removed_Content) 카테고리와 문서를 교차 확인했다. 위키 인덱스에는 본편, New Adventures, 사용자 레벨팩, 에디터 전용, 내부·미사용·제거 항목이 섞여 있으므로 이를 전부 현행 기본 캠페인 어휘로 합치지 않는다. 전체 어휘 토큰과 구분 기준은 위의 [실제 레퍼런스 조사 보고서](RULE_REWRITE_REFERENCE_REPORT.md) S9–S26 및 “재조사: 오브젝트·단어 인벤토리와 문장 문법” 절에 정리되어 있다.

문법 축은 명사/오브젝트 텍스트, 속성, 동사·연산자, AND/NOT, prefix·infix 조건, 수평·수직 문장 방향 및 중첩 텍스트를 포함한다. 위키의 Operators 문서는 본편과 New Adventures 단어를 별도 구분하고, Conditions 문서는 조건의 위치·결합 범위를 별도 색인한다. [Operators](https://babaiswiki.fandom.com/wiki/Category:Operators), [Conditions](https://babaiswiki.fandom.com/wiki/Category:Conditions). 공식 481d는 새 오브젝트 Bean/Fox/Chili/Hotdog/Brain/Rook/Bone/Cactus/Palm/Yes/No와 새 단어 Become/Facedby/Hold/Happy/Angry를 명시한다. [공식 481d](https://hempuli.itch.io/baba/devlog/1285463/version-481d)

## 모드·자료 목록

| 항목 / 출처 | 확인 상태 및 게임·모드 버전 | 라이선스 상태 | 기능과 TIN에 참고할 점 |
|---|---|---|---|
| [PlasmaFlare baba-modding-guide](https://github.com/PlasmaFlare/baba-modding-guide), [Parsing overview](https://github.com/PlasmaFlare/baba-modding-guide/blob/master/references/parsing.md), [Lua files overview](https://github.com/PlasmaFlare/baba-modding-guide/blob/master/references/lua%20files.md) | README와 파서 문서 확인. 특정 게임 빌드 번호는 문서에 고정되지 않음. 저자가 안내를 불완전한 개요라고 명시 | 저장소에서 명시 라이선스 확인 못함 | Lua 파일 역할, 유닛/규칙/undo와 파서의 길잡이. 코드 구조 탐색에 참고하되 정식 사양이나 복사 허가로 읽지 않는다. |
| [Plasma merged modpack](https://github.com/PlasmaFlare/plasma-baba-mods), [STABLE 설명](https://github.com/PlasmaFlare/plasma-baba-mods/blob/master/docs/stable.md) | README에 PC 477c 호환 표시. 이후 버전에서는 완전 호환을 보장하지 않는다고 경고 | 저장소에서 명시 라이선스 확인 못함 | Arrow Properties Plus/Turning Text, Omni/Pivot, Filler Text, THIS, CUT/PACK, STABLE, GUARD. 속성·텍스트 방향/연결 및 규칙 변경에 반응하는 특수 상태 사례. TIN에는 기능 경계를 분리해 참고할 수 있음. |
| [Plasma Mega Modpack](https://github.com/PlasmaFlare/baba-mega-modpack) | PC 478f 표기. README가 여러 독립 모드 통합에 따른 버그 가능성과 실험 성격을 알림. 저장소 이력의 1.3.4는 2024-06-09 릴리스로 확인됨 | 다중 저자 통합 저장소. 일괄 라이선스 확인 못함 | Plasma·Patashu·Persist·Past·Stringwords(STARTS/CONTAINS/ENDS)·Word Salad 등 통합. `NOUNDO`, `LOCAL`, `OFFSET`, `NUHUH` 등 문법 확장 다양성은 보여 주지만, 합본이므로 개별 모듈 라이선스·호환성을 따로 확인해야 한다. |
| [Patashu original mods](https://github.com/Patashu/Baba-Is-You-Patashu-s-Mods) | README에 최종판이며 치명적 버그 수정 외 추가 계획 없음. 명시된 정확한 BIY 빌드 번호는 확인 못함. 구형 modloader 의존 안내 있음 | README의 범용 사용·수정 허가는 확인 못함. 라이선스 미확인 | `SINGLET/CAPPED/STRAIGHT/CORNER/EDGE/INNER`, `SLIDE`, `STUCK`, `TOPPLE`, `PHASE`, `COLLECT`, `SEND/RECEIVE/RESEND` 등. 지역 조건·이동·레벨 간 규칙 전달 사례. |
| [Patashu Pata Redux](https://github.com/Patashu/Baba-is-You-Pata-Redux-Mods), [movement source](https://github.com/Patashu/Baba-is-You-Pata-Redux-Mods/blob/master/Lua/movement.lua) | README/소스 확인. 정확한 BIY 빌드 번호 미표기 | README에 “모드팩 또는 커스텀 월드에서 출처표기와 함께 사용/수정 가능”이라고 명시. 별도 OSI 라이선스는 확인 못함. 원 구현자(lily, cg5) 감사표기 포함 | `STICKY`, `SLIDE`, `ZOOM`, `NOUNDO/NORESET`, 조건부 상호작용 등. STICKY는 같은 이름·같은 float의 STICKY 유닛이 하나의 덩어리로 이동하고 구성원 하나라도 막히면 이동이 실패한다. TIN의 통합 이동 참고는 가능하지만 폐곡선 인식·내부 소유·경계 충돌은 구현하지 않는다. |
| [Better Metatext](https://github.com/EmilyEmmi/Baba-Is-You---Metatext-Mod) | README가 BIY 478F를 최신 지원 버전으로 명시. 일부 이전 버전도 작동한다고 주장. 481d 호환 확인 안 됨 | 저장소에서 라이선스 허가 확인 못함 | `text_text_(name)`, `text_text_text_(name)`, `TEXT_` 및 런타임 메타텍스트처럼 텍스트를 재귀적으로 참조. 재귀 문법과 파서 변경의 규모 참고. 메타텍스트는 소유 인벤토리가 아니다. |
| [Persistence levelpack](https://therandomiser.github.io/TheRandomiser/) | 저자 페이지에서 커스텀 `Persist` 속성 레벨팩 확인. BIY 버전 미기재 | 코드/레벨팩 라이선스 미확인 | 오브젝트와 규칙을 다음 레벨로 가져가는 레벨 간 지속을 소개. 한 레벨 내에서 BOX가 내부 물건을 소유·운반하는 TIN 계약과 다르다. |
| [Build Mod](https://dizzyandy.itch.io/build-mod-baba-is-you) | 배포 페이지에서 478f, 개발 중으로 소개된 버전 기록. 현행 호환 여부 확인 안 됨 | 페이지에서 라이선스 확인 못함 | BUILD/Collapse 관련 객체·구조 생성. 조립이라는 표면 유사성은 있지만 BOX 폐곡선에서 인벤토리를 추출하는 기능은 확인되지 않음. |
| [Extrem Logic Parser](https://extremthedeveloper.itch.io/baba-is-you-logic-parser) | 배포 페이지가 중단/미완성 상태를 알림. 정확한 현행 BIY 버전 미확인 | 라이선스 미확인 | 대체 파서 실험 사례. TIN 파서의 동작 보증이나 채택 근거로 사용하지 않는다. |
| [Extrem Position Conditions](https://extremthedeveloper.itch.io/position-conditions) | 배포 페이지상 Released, 파일명 1.0. 게임 빌드 번호 미기재 | 라이선스 미확인 | 위치 기반 prefix 조건 모음. 인접 판정/상대 위치 어휘의 확장 사례. |
| [Extrem Clear Conditions Mod](https://extremthedeveloper.itch.io/baba-is-you-clear-conditions-mod) | 배포 페이지의 V5.1 다운로드 및 Released 표기 확인. 게임 빌드 번호 미기재 | 라이선스 미확인 | `conds.lua`로 레벨별 clear condition을 조정하는 모드라고 저자가 설명한다. 규칙/클리어 조건 확장 사례. |
| [Extrem’s Mods Deluxe](https://extremthedeveloper.itch.io/baba-is-you-mod-extrems-mods-deluxe) | 배포 페이지 버전 1.3. 게임 빌드 호환 표기 미확인 | 라이선스 미확인 | ACT/RELOAD/RETURN/UPDATE 등 새 규칙·동작 확장 사례. |
| [Very Practical Mod](https://redpipe.itch.io/very-practical-baba-mod) | 배포 페이지 v2.0, 2025-06 표기. 현행 481d 호환 확인 안 됨 | 라이선스 미확인 | 단어 변형·효과·카운터/명사 계열을 추가하는 모드. |
| [Script Mod](https://ocean2153.itch.io/script-mod) | “Rescripted” 기능 추가 배포 페이지 확인. 게임 빌드 미기재 | 라이선스 미확인 | 기존 문법·기능의 재구성과 추가 규칙 사례. |
| [Baba Is You: 3D property](https://babaiswiki.fandom.com/wiki/3D) | 공식 기본 게임 속성에 대한 커뮤니티 설명. 별도 모드 버전 아님 | 위키 문서의 CC BY-SA 계열 안내 적용 여부는 페이지별 확인 필요; 본문은 참고·요약만 사용 | 3D는 시점을 3D식 투영으로 전환하고 3D 대상의 조작을 바꾸는 속성으로 설명된다. 복수 3D 대상도 가능하다. 소유 인벤토리 계약은 문서화되어 있지 않다. |
| [Trida Is You](https://hedgehogpunk.itch.io/trida-is-you) | itch 페이지에서 3D 재해석, 개발 중 및 v0.2 배포를 확인. 현행 여부 미확인 | 페이지에서 라이선스 확인 못함 | 3차원 격자 공간으로의 재해석. TIN 요구의 소유 인벤토리·폐곡선 내부 인식 구현 사례는 확인되지 않음. |
| [TAKING INVENTORY 시연](https://www.youtube.com/watch?v=CMxU3S1j7F8) | 영상 설명/시연을 근거로 한 확인만 기록. 원본 다운로드, 소스 코드, BIY 버전 미확인 | 라이선스 미확인 | 설명에서 Esc/E 인벤토리 및 YOU 옆/위 칸에 놓는 동작을 시연한다고 확인. 기능의 내부 구현·저장·범용성은 판단하지 않는다. |
| [Baba Is 2048 언급 사례](https://www.reddit.com/r/BabaIsYou/comments/lddjwv) | 커뮤니티 게시글의 레벨 구현 언급. 원본 레벨팩/다운로드·버전 미확인 | 라이선스 미확인 | 2048식 퍼즐이 Baba의 특정 레벨 문법으로 구현된 사례라는 범위만 참고. 재사용 가능한 인벤토리/합성 subsystem으로 보지 않는다. |
| [Baba Is You itch 모드 카탈로그](https://itch.io/game-mods/tag-baba-is-you), [GameBanana 허브](https://gamebanana.com/games/7097) | 동적·부분 카탈로그. 항목 구성과 활동성 변동 | 항목별 상이, 일괄 확인 불가 | 생태계 검색의 보조 색인. 레벨팩과 코드 모드를 섞어 나열할 수 있으므로 개별 원출처·버전·라이선스를 재확인해야 한다. |

### 481d의 모드 지원 범위

공식 481d는 `MF_documentation.txt`, `MF_getlist_*`, `MF_getlist_system`, 레벨 전환 보조 함수, 마우스/키보드 입력 hook, 사용자 정의 undo event 등 모드 API를 추가했다고 기록한다. 이는 공식적으로 modding 접점이 확장됐다는 근거다. 단, 기존 477c/478f 모드가 자동 호환된다는 뜻은 아니다. [공식 481d 노트](https://hempuli.itch.io/baba/devlog/1285463/version-481d)

## 파서·턴 처리·undo·저장 관찰

### 파싱 개요

[Plasma parsing overview](https://github.com/PlasmaFlare/baba-modding-guide/blob/master/references/parsing.md)는 `code()` 시작 시 전역 `updatecode == 1`이면 규칙 관련 테이블을 비우고 재파싱하며, 아니면 기존 결과를 유지한다고 설명한다. 텍스트 이동·생성·파괴 등 규칙에 영향을 줄 변화가 `updatecode`를 세운다. 이 설명은 작성자가 불완전한 개요라며 세부는 Lua 소스로 대조하라고 경고한다.

문서가 설명하는 `docode()` 흐름은 firstwords 후보를 받아 수평/수직 텍스트 경로를 만들고, 한 칸에 쌓인 텍스트의 가능한 조합을 펼친 뒤, 문법 검사와 rule object 구성을 수행하여 `addoption()`을 통해 `featureindex`에 넣는 순서다. 유효하지 않은 긴 문자열 중간에도 유효 하위 문장이 있으면 후보를 `firstwords`에 재삽입해 다시 검사한다. 이후 특수 규칙 처리는 `subrules()`(ALL/MIMIC), `grouprules()`, `postrules()`에서 이어진다고 안내한다. 이는 모딩 가이드가 정리한 파서 흐름이며 엔진의 모든 분기·예외를 완전하게 기술하지 않는다. [Parsing overview](https://github.com/PlasmaFlare/baba-modding-guide/blob/master/references/parsing.md)

확인 가능한 `rules.lua` 파서 사본에서 읽은 순서 기록은 **기본 규칙 삽입 → `docode()` → `subrules()`/`grouprules()` → `postrules()`**다. 근거는 Patashu 계열이 보관한 규칙 코드다. [Patashu rules_pata.lua](https://github.com/Patashu/Baba-Is-You-Mega-Mod-Pack/blob/master/Scripts/rules_pata.lua). **이는 코드 사본에서 관찰한 순서이지 TIN이 보장해야 할 순서 계약이 아니며, 원작의 모든 481d 경로를 대변한다고 볼 수 없다.**

일본어 커뮤니티 위키는 WORD 자기참조 계열의 INFINITE LOOP 조건으로 같은 구문 200회 파싱을 기록하고, FEELING 80회 등 별개의 한계도 함께 열거한다. 따라서 200은 “레벨당 규칙 수 제한” 일반값이 아니라 특정 재귀/루프 안전장치 사례로만 기록한다. [일본어 위키: Infinite Loop](https://w.atwiki.jp/babais/pages/42.html) (문서 내 `INFINITE LOOP` 절)

### 턴 호출 경로·이동 모드 차이

코드 추적 기록에는 `command → movecommand → doupdate → moveblock → MF_update`가 관찰된 호출 순서로 남아 있다. 출처 코드: [Plasma movement.lua](https://github.com/PlasmaFlare/plasma-baba-mods/blob/master/Lua/movement.lua), [Plasma modsupport.lua](https://github.com/PlasmaFlare/plasma-baba-mods/blob/master/Lua/modsupport.lua). 이 추적은 특정 코드판에서 읽은 실행 경로 메모일 뿐이며, 모드 hook·입력 유형·버전에 관계없는 완전한 게임 턴 스케줄이라고 주장하지 않는다. 공식 업데이트가 “턴 도중 여러 지점의 hook”을 더 추가한 것도 호출 경로가 확장될 수 있음을 뒷받침한다. [481d 노트](https://hempuli.itch.io/baba/devlog/1285463/version-481d)

Plasma 계열은 방향 속성·텍스트 방향·특수 파서/룰 효과를 추가하는 쪽이 두드러진다. Pata Redux는 별도의 movement 구현에서 `STICKY` 그룹 이동, `SLIDE`의 진입 후 추가 이동, `ZOOM`의 막힐 때까지 연속 이동을 정의한다. 두 구현의 함수 분할과 처리 시점은 같다고 볼 수 없다. [Plasma movement.lua](https://github.com/PlasmaFlare/plasma-baba-mods/blob/master/Lua/movement.lua), [Pata Redux movement.lua](https://github.com/Patashu/Baba-is-You-Pata-Redux-Mods/blob/master/Lua/movement.lua), [Pata Redux README](https://github.com/Patashu/Baba-is-You-Pata-Redux-Mods)

### STABLE, undo 및 캐시

Plasma STABLE 문서는 오브젝트가 STABLE이 된 시점에 적용된 속성 집합을 보존하고, STABLE인 동안 새 규칙 문장 생성/파기로 속성이 추가·제거되지 않으며 STABLE이 끝나면 보존 집합을 잃는다고 정의한다. [STABLE 설명](https://github.com/PlasmaFlare/plasma-baba-mods/blob/master/docs/stable.md)

같은 모드의 `stablestate.lua`는 stable unit/rule 관계 및 캐시를 관리한다. 규칙 재파싱이 일어나도 STABLE이 고정한 속성 집합은 별도 상태로 유지되며, 주석상 캐시는 undo 후에도 남고 레벨 재시작·퇴장·진입에서 재설정된다. 모드 `undo.lua`는 기본 undo에 stable 전용 전후 처리를 덧붙여 이 상태를 조정한다. 이는 **그 모드의 구현**이며 바닐라 게임의 전역 캐시 정책으로 일반화하지 않는다. [STABLE state code](https://github.com/PlasmaFlare/plasma-baba-mods/blob/master/Lua/modules/stable/stablestate.lua), [Plasma undo.lua](https://github.com/PlasmaFlare/plasma-baba-mods/blob/master/Lua/undo.lua)

모딩 가이드의 [Undo System](https://github.com/PlasmaFlare/baba-modding-guide/blob/master/references/undo%20system.md)은 `undobuffer`를 undo delta/이벤트 기록으로 설명하고 `newundo`·`addundo`·`undo` 흐름을 소개한다. 481d는 사용자 정의 undo event 지원을 공식 추가했다. [481d 노트](https://hempuli.itch.io/baba/devlog/1285463/version-481d). Mega Modpack의 변경 기록에도 STABLE unit 파괴를 undo할 때의 Lua 오류 수정이 있어 캐시와 되감기 경계가 실제 통합 이슈가 될 수 있음을 보여 준다. [Mega Modpack](https://github.com/PlasmaFlare/baba-mega-modpack)

**런타임 파서 상태의 저장 계약은 미확인이다.** 모딩 가이드의 [Units](https://github.com/PlasmaFlare/baba-modding-guide/blob/master/references/units.md) 문서는 유닛과 텍스트 상태를 설명하지만, `firstwords`/`featureindex` 또는 활성 규칙 캐시가 세이브에 직렬화되는지, 로드 시 재계산되는지 보장하지 않는다. 조사 결과만으로 이를 추정하지 않는다.

## METRIX와 가까운 기능 비교

TIN의 기준 요구는 실제 BOX로 속 빈 폐곡선 테두리를 만들고, 유효한 모든 테두리를 복합 오브젝트로 인식하며, 구성 조각 하나를 밀어도 전체가 이동하고, 내부 물건은 함께 운반되어 이동 방향 쪽 안쪽 벽에 붙고, 외부 충돌은 경계만 검사하는 것이다. 인벤토리/보드는 같은 상태를 표현하며, YOU 소유·활성 인벤토리·소유 관계는 규칙으로 바꿀 수 있어야 한다. [Grilling State](../GRILLING_STATE.md)

| 기능 | 확인된 공개 사례 | METRIX와 같은 점 / 한계 |
|---|---|---|
| 국소 이웃 판정 | Patashu `SINGLET/CAPPED/STRAIGHT/CORNER/EDGE/INNER`는 대상 주변 0/1/2 직선/2 코너/3/4 방향에 같은 오브젝트가 있는지 판정한다. [Patashu README](https://github.com/Patashu/Baba-Is-You-Patashu-s-Mods) | 로컬 4방향 이웃 모양 판정이다. 임의 크기 폐곡선을 탐색하거나 내부/외부를 flood fill하는 기능이 아니다. |
| 여러 타일의 원자 이동 | Pata Redux `STICKY`는 같은 이름·같은 float인 STICKY 단위를 한 덩어리로 이동시키며 하나라도 막히면 전체 이동이 실패한다. [Pata Redux README](https://github.com/Patashu/Baba-is-You-Pata-Redux-Mods) | 구성원 동시 이동의 가장 가까운 사례. 그룹 구성은 같은 이름/float/STICKY 조건이지 폐곡선 내부 소유권이 아니다. |
| 붙잡기 | 공식 481d에서 HOLD 단어가 추가됐다. Fandom 설명은 HOLD 위의 다른 오브젝트가 그곳에서 이동해 나가지 못하게 하는 속성으로 기술한다. [공식 481d](https://hempuli.itch.io/baba/devlog/1285463/version-481d), [Properties](https://babaiswiki.fandom.com/wiki/Category:Properties) | 단일 타일 위의 오브젝트 이동 제한 관계다. 내부 물건을 가진 경계와의 집합 관계/인벤토리가 아니다. |
| Esc/E 인벤토리 배치 시연 | `TAKING INVENTORY` 영상 설명/시연은 Esc/E 인벤토리와 YOU 옆 또는 위에 물건을 배치하는 범위로만 기록한다. [영상](https://www.youtube.com/watch?v=CMxU3S1j7F8) | 화면 시연 근거만 있다. 내려받을 수 있는 원본, 소스, 게임 버전, 라이선스, 저장/소유 계약은 미확인. 코드 채택 불가. |
| 레벨 간 지속 | Randomiser `Persistence`는 오브젝트와 규칙을 다음 레벨로 가져오는 속성을 소개한다. [저자 모드 페이지](https://therandomiser.github.io/TheRandomiser/) | 단계 간 carry-over다. 한 레벨 내부의 상자·폐곡선·내용물 운반은 아니다. |
| 메타 규칙/재귀 텍스트 | Better Metatext는 텍스트가 다른 텍스트를 가리키는 재귀 표현을 제공한다. [Better Metatext](https://github.com/EmilyEmmi/Baba-Is-You---Metatext-Mod) | 규칙 텍스트를 참조하는 파서 확장. 물체 소유 인벤토리가 아니다. |
| 숫자 합성 퍼즐 | “Baba Is 2048”은 특정 커뮤니티 레벨/구현 언급으로 확인된다. [게시글](https://www.reddit.com/r/BabaIsYou/comments/lddjwv) | 레벨 저작 사례로만 볼 수 있다. 범용 아이템 인벤토리 모듈로 확인되지 않는다. |
| 3D 이동·제어 | 공식 3D 속성은 3D 투영과 대상 조작을 바꾸는 것으로 위키에 설명된다. Trida Is You도 3D 공간 재해석이다. [공식 속성 설명](https://babaiswiki.fandom.com/wiki/3D), [Trida Is You](https://hedgehogpunk.itch.io/trida-is-you) | 공간 차원 또는 카메라·제어 변화다. 두 자료에서 소유 인벤토리 계약은 확인하지 못했다. |
| YOU / YOU2 | Properties 위키는 YOU와 YOU2를 각각 기본 및 두 번째 입력 세트로 조종하는 속성으로 정의한다. [Properties](https://babaiswiki.fandom.com/wiki/Category:Properties) | 조작 주체/입력 설정이지 오브젝트 소유 인벤토리 모델로 설명되지 않는다. |

그러므로 현재 근거에서 가장 가까운 조합은 **(a) BOX 주변 구성 판정, (b) Pata STICKY의 원자 이동, (c) HOLD 같은 점유/이동 제약, (d) Persistence의 상태 전달, (e) Metatext의 재귀 규칙 참조**다. 각 요소만으로 METRIX를 구성할 수 있다고 단정하지 않는다. 특히 폐곡선 검출과 내부 영역 판정, 여러 경계별 별도 인벤토리, 인벤토리와 보드의 단일 상태, 내부 물체를 이동 방향 쪽 안쪽 벽에 정렬, 외부 충돌의 경계 한정은 공개 사례에서 확인되지 않아 **TIN이 직접 정의·구현해야 하는 영역**으로 남는다.

## Adopt / Adapt / Build 후보

| 경로 | 후보 | 적용 전제 및 한계 |
|---|---|---|
| **Adopt 검토 가능** | Patashu Pata Redux의 좁은 STICKY/undo 메커니즘 | README의 사용·수정 허가는 출처표기 조건이다. 실제 채택 전 해당 파일·원 구현자 표기·의존 modloader·사용할 스프라이트의 권리를 별도 확인해야 한다. 전체 모드팩을 통째로 가져오라는 권고가 아니다. |
| **Adopt 불가(현 상태)** | Plasma guide/모드팩, Mega Modpack, Better Metatext, itch 모드, TAKING INVENTORY | 저장소/페이지에서 코드 사용 라이선스가 확인되지 않았거나 영상만 존재한다. 라이선스 미확인 코드는 Adopt 대상에서 제외한다. 기능 설명·구조 관찰에만 사용한다. |
| **Adapt 조사 후보** | `updatecode` 기반 재평가, `featureindex`, stacked text 조합과 하위 규칙 처리 | 파서 설계 원리로 참고하되 Baba 내부 자료구조·처리 순서를 TIN 계약으로 그대로 복사하지 않는다. 요구 문법 범위와 되돌리기/세이브 계약을 별도로 확정해야 한다. |
| **Adapt 조사 후보** | Pata STICKY의 “전체 그룹 가능성 검사 후 원자 이동” 패턴; Plasma STABLE의 재평가·undo 조정 | 동작 개념의 범위 참고. 라이선스가 확인되지 않은 소스는 코드 복사 불가. 그룹 구성, 충돌, 구성 변화, undo 시점은 TIN 요구로 다시 정의해야 한다. |
| **Build 필요성 높음** | 폐곡선/내부 영역 인식, 복합 경계 개체, 내부 물건 소유·정렬·경계 충돌, 인벤토리-보드 단일 상태 및 규칙에 따른 활성·소유 전환 | 조사한 공개 사례에서 요구 통합 구현을 찾지 못했다. 이 보고서는 구현 방식이나 제품 결정을 지정하지 않는다. 설계 계획에서 상태/경계/실패/undo 계약을 구체화할 때 이 공백을 반영한다. |

## 조사 한계와 남은 확인

- 저장소 기본 브랜치/README에 적힌 버전 외에 각 모드의 실제 동작을 설치·실행 검증하지 않았다. 481d용 호환성은 확인하지 못했다.
- 여러 배포 페이지에 소스 다운로드는 있지만, 다운로드와 라이선스는 별개다. 라이선스 불명은 미확인으로 유지한다.
- Fandom·커뮤니티 설명은 규칙/기능 범위를 찾는 인덱스로 활용했다. 세부 예외는 실제 게임 코드 또는 특정 버전 재현으로 확정해야 한다.
- `TAKING INVENTORY`는 전달된 YouTube 링크의 영상 설명/시연 범위에 한정했다. 원본 패키지·버전·라이선스는 미확인이다.
- **UI 및 사용자가 제공한 화면 캡처에 관한 평가는 하지 않았다.**
