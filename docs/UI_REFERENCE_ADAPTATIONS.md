# UI 연구 보고서 — 구체 패턴과 TIN 적용 지도

2026-09-22 사용자가 제공한 보고서 전체의 게임 분석·장르 패턴·구현 사례를 대조한 문서다. **보고서 내용**과 **아래 계획의 TIN 설계안**을 구분한다. 이번 작업은 제공된 보고서의 재적용이며 외부 원문/실제 화면의 신규 조사 기록이 아니다. 구현 전 실제 화면 확인은 기존 VISUAL_DIRECTION 게이트를 따른다. 링크는 그 확인 진입점이다.

사용자 확정 방향은 구체 UI 구조를 적극 채택하는 것이다. 개별 배치·시간·동작은 이 방향에 따른 AI 설계안이며 구현 완료 기록이 아니다. 기존 계획과 중복되는 화면은 아래 연결된 상세 적용 절을 우선하여 구체화하고, 서로 다른 설계안 두 개를 동시에 구현하지 않는다.

추가 요청의 신규 적용처: [유령 저택의 밤 행렬](../plans/game_modules/06_GHOST_PROCESSION.md). 사용자 메모에서 선택한 탐험 게임의 시선/은신 상태에는 Dead Space, 지도·시간표·위장 물건에는 Destiny, 선택→읽기 면에는 Persona 5, 발견·실패·복귀에는 Metaphor 패턴을 구체화했다. 이 신규 계획의 인디게임/외부 코드 후보 초기 조사는 계획 1·8절에 따로 기록한다.

## 네 게임의 분석을 보존한다

### Dead Space — RIG·무기·인벤토리·locator의 문맥

보고서는 체력·인벤토리·무기 선택·locator를 세계와 행동에 결합해 플레이와 UI 사이 단절을 줄인다고 분석한다. TIN에 가져올 구조는 **상태를 대상 가까이 읽기 → 상호작용할 때 필요한 조작 펼치기 → 끝나면 장면만 남기기**다. 체력바나 SF 홀로그램을 이식하는 것은 아니다.

- [물리 도구](../plans/game_modules/03_PHYSICS_TOOLBOX.md): 선택 물체 옆 도구명·실행 가능성, 대상 변경 시 안내 이동, 작용 후 물체 반응으로 판정 읽기.
- [시간 루프](../plans/game_modules/04_TIME_LOOP.md): 현재 박자를 장치 변화로 읽고 관찰할 때만 짧은 설명, 기억은 별도로 요청.
- [기존 조작대](../plans/visual_overhaul/02_ROUTE_SETS.md): 전체 장치의 상태판 대신 선택 장치의 실제 판독부와 조작 위치에 안내.
- locator의 “요청할 때 안내”는 셸의 현재 위치/복귀 맥락에 적용한다. 숨은 출구를 가리키는 길찾기 화살표로 이식하지 않는다. 세계 표현만으로 못 읽는 정보는 같은 내용을 담은 정적인 텍스트 보충 경로를 제공한다.

출처 진입점: [Dead Space UI 제작 발표 요약](https://www.gamedeveloper.com/design/video-designing-i-dead-space-i-s-immersive-user-interface).

### Destiny — 초보자와 숙련자의 정보 깊이, item management와 Director

보고서가 소개한 발표 항목은 free cursor, time-gated interaction, localization, icon pipeline, Director 및 아이템 관리다. 보고서의 `철검/공격력 → focus에서 속도·행동 → 상세에서 비교·특성·출처`는 이를 번역한 **보고서의 설계 예시**이며 Destiny 실제 화면의 정확한 필드/배치라고 주장하지 않는다.

- [로드](../plans/game_modules/05_ODD_ROAD_ADVENTURE.md): 아이템 이름/보유 상태 → 선택 시 관찰 요약·사용/상세 → 전문·획득 맥락. 비교는 수치 성장 대신 이미 관찰한 성질/현재 사용 대상에 관한 사실을 나란히 놓는다.
- [추리](../plans/game_modules/02_DEDUCTION_CASEWORK.md): 현장 사물 → 조사 요약 → 증거 전문, 사건 목록 → 해당 사건의 현장/추론 위치로 복귀.
- [셸·기록](../plans/implementation_improvements/02_SHELL_AND_VISUAL_ACCEPTANCE.md): 목록 HOME/전체 목록의 위치 유지, 목록과 읽기 면을 연결한 기록 탐색.
- free cursor는 마우스로 공간의 항목을 직접 고르는 경로로 보존하고 컨트롤러는 같은 대상의 논리적 focus를 사용한다. 가상 커서를 필수로 강요하지 않는다. time-gating은 기존 입력 홀드의 다음 화면 유출 방지와 위험한 reset의 명시적 확인에 대응한다. 모든 선택에 지연을 넣거나 긴 홀드를 요구하지 않는다.
- localization은 선택 면의 긴 제목/본문 확장으로, icon pipeline은 TIN의 텍스트 상태·선택 테두리 일관성으로 변형한다. UI 아이콘 금지가 정보 깊이나 navigation 구조의 생략 이유가 되지 않는다.

출처 진입점: [Destiny — Tenacious Design and the Interface](https://gdcvault.com/play/1023460/Tenacious-Design-and-The-Interface).

### Persona 5 — 선·명도·레이아웃이 선택 위치를 전달

보고서는 선을 시선 기준점으로 쓰고 중요/비중요 영역의 밝기를 나누며 레이아웃·각도 변화로 위치 인식을 돕는다고 설명한다. TIN에서는 **선택된 행/단어 → 짧은 연결선/같은 정렬축 → 읽을 본문이나 반응 영역**이라는 흐름을 사용한다.

- [규칙 보드](../plans/game_modules/01_RULE_REWRITE.md): 성립한 문장의 기준선과 해당 턴에 바뀐 객체의 순차 강조. 해답 문장을 제안하는 선은 금지.
- [추론 문서](../plans/game_modules/02_DEDUCTION_CASEWORK.md): 현재 어휘/슬롯을 가장 높은 대비로, 문서의 비선택 부분은 읽을 수 있는 낮은 위계로 유지.
- [셸](../plans/implementation_improvements/02_SHELL_AND_VISUAL_ACCEPTANCE.md): 선택 제목·본문 면의 연결과 focus 이동 방향, 상세를 닫을 때 목록 위치 복원.
- 사선 컷아웃·고유 빨강/검정·폰트·장식 콜라주는 채택하지 않는다. TIN의 직선·여백·기존 서체로 동일한 시선 경로를 만든다. 밝기 감소로 작은 글자 가독성을 없애지 않는다. 보고서의 해상도/메모리 고려는 여러 해상도용 장식 이미지를 늘리는 대신 같은 레이아웃/Theme 자료를 재사용하고 실측하는 것으로 적용한다.

출처 진입점: [Persona 5 개발 패널 정리](https://personacentral.com/persona-5-panel-concept-development-ui/).

### Metaphor: ReFantazio — 감정과 사건 중요도에 맞춘 motion hierarchy

보고서는 UI와 애니메이션을 순간의 감정을 증폭하는 수단으로 쓰되 이해가 어려워지면 기능성과 다시 조정했다고 설명한다. 보고서의 60–120ms focus와 아래 TIN 시간은 원작에서 측정한 수치가 아니다.

TIN의 **시작 튜닝값**: 일반 focus 80ms(테두리/밑줄), 확정 140ms(선택 영역 고정), 중요한 발견/규칙 변화 220ms(관련 영역 순차 강조), rewind/모듈 내 주요 전환 300ms(이전/이후 장면 연결). 실제 모듈의 반복 조작으로 조정하며 이 시간을 domain 대기시간으로 쓰지 않는다. 장식은 다음 입력에 중단/최종 상태로 합류 가능해야 한다. 기존 first_entry의 사용자 확정 시간은 바꾸지 않는다.

- [규칙](../plans/game_modules/01_RULE_REWRITE.md): focus < 문장 성립 < 실제 세계 변화, 실패는 긴 화면 흔들기 대신 막힌 위치와 undo 경로.
- [루프](../plans/game_modules/04_TIME_LOOP.md): 일반 관찰 < 새 기억 < rewind, 유지되는 기억과 초기화되는 공간을 서로 다르게 움직임.
- [로드](../plans/game_modules/05_ODD_ROAD_ADVENTURE.md): 선택 < 사용 확정 < NPC/지역 변화, 반복 대사는 작은 피드백.
- [소규모 장면·VN](../plans/visual_overhaul/03_CYCLE3.md): 독서 속도를 연출이 강제하지 않게 하고 방송 실패는 해당 장면 반응으로 표현.

Reduced Motion에서는 위치 이동 대신 같은 순서의 정적 테두리·명도/텍스트 교체로 원인과 결과를 구분한다. 성공/실패 텍스트는 보충이며 실제 세계 반응을 대체하지 않는다.

출처 진입점: [Metaphor UI 디자이너 인터뷰](https://www.theverge.com/games/636243/metaphor-refantazio-ui-menu-interview-koji-ise).

## 보고서의 장르·컴포넌트 사례 전체 대조

이 표는 새 장르 제작 목록이 아니다. 유사한 정보 문제를 가진 실제 TIN 화면으로 옮기거나 비대상 근거를 남긴다.

| 보고서의 구체 패턴 | 적용 위치 / 변형 |
|---|---|
| 액션/FPS minimal HUD·context prompt·quick-select·자원/쿨다운·피해 방향 | 물리 도구의 대상 옆 안내·도구 선택. HP/탄약/피해 방향은 해당 시스템이 없어 비대상. |
| 액션 RPG quick slot·상태효과·loot comparison·compact/expanded/detail | 로드의 보유 물건 선택/상세/사용. 전투 버프·장비 수치·희귀도 경제를 새로 넣지 않는다. |
| RPG 탭·party strip·인벤토리·비교·breadcrumb | 로드 지역/물건/대화와 셸 기록의 탐색 복귀. party strip은 파티 관리가 없어 비대상. |
| 퍼즐 문맥 힌트·undo/reset·상태 강조·직접 조작 | 규칙 보드의 문장 변화/undo, 추리 어휘→슬롯, 오답 후 수정. 정답 힌트와 조작 설명을 분리. |
| 전략 selection inspector·command palette·필터·alert·drill-down·minimap | 진료의 환자→검사→기록, 셸 기록 필터/상세. 다중 유닛 명령·minimap은 비대상. |
| 카드/덱빌딩 focus·keyword tooltip·drag/drop·target indicator | 추리의 어휘 선택/슬롯 대상 표시/설명, 같은 정보의 마우스와 focus 경로. 카드 게임 자체는 만들지 않는다. |
| 시뮬레이션 값/변화량/원인/조치·status chip·sparkline | 진료의 전/후 관찰·원인 미확정·다음 검사, 루프의 현재 관찰/기억 분리. 근거 없는 수치/추세 그래프는 만들지 않는다. |
| 생존/제작 recipe requirement·부족 이유·quick craft | 로드에서 이미 알려진 사용 조건의 현재/필요 비교 행. 제작 시스템이나 숨은 해법 목록은 비대상. |
| 내러티브 dialogue·choice·history·속도/자동 진행 | lost_signal_vn과 로드 대화. 대사/선택/기록의 위치와 반환 동작은 해당 계획에 명시. |
| 혼합 장르 문맥 HUD + 공통 행동 계약 | 셸→모듈, 동일한 취소 복귀와 텍스트 입력 안내. 게임별 미술/화면 구조는 유지. |
| ResourceBar / ItemSlot / StatDelta / RequirementRow | 로드·진료의 의미 있는 값/성질만 사용. 체력바·성장 수치가 없는 모듈에는 만들지 않는다. |
| Tooltip / Tabs / Modal / Toast / ListRow / CommandButton / InputGlyph | 로컬 상세 면·기록 탭·reset 확인·저장 결과·목록 행·현재 대상 행동·텍스트 바인딩 안내. 구체 흐름은 셸/로드/추리 계획에 배치. |
| 카드 tooltip 하나를 여러 대상에 바인딩 | 추리와 로드에서 각각 로컬 상세 면 하나를 대상별로 갱신. 전역 TooltipService 불필요. 이전 대상의 연결/본문/스크롤 잔존 검증. |

보고서의 Tooltip 포럼 사례는 특정 상용 게임 분석이 아닌 구현 참고다. [Card Tooltip 사례](https://forum.godotengine.org/t/card-tooltip-ui/77934), [Container 간격 사례](https://forum.godotengine.org/t/box-container-separation/61607), [Godot 공식 데모](https://github.com/godotengine/godot-demo-projects)는 채택 파일·API 확인 단계에서 사용한다. 이 문서 작성만으로 외부 코드 채택이나 호환성 확인을 했다고 기록하지 않는다.

학술 휴리스틱·접근성·반응형·성능·AI 작업 루프는 기존 [UI_WORKFLOW](UI_WORKFLOW.md)에 유지한다. 이번 구체화의 검수는 그 매트릭스에서 각 계획의 선택→상세→취소/실패→복구 과제를 실행하는 것이다.
