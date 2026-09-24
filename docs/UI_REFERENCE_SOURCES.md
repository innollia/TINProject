# UI 레퍼런스 출처 정본

이 문서는 사용자가 제공한 「고도엔진 기반 바이브코딩 게임 UI 심층 연구 보고서」에서 **본문에 URL로 직접 적힌 웹사이트 주소**를 옮긴 단일 정본이다. 특히 Dead Space, Destiny, Persona 5, Metaphor: ReFantazio의 실제 UI 사례 주소를 최우선으로 보존한다.

## 보존 규칙

- 아래 URL은 보고서에 적힌 문자열 그대로 옮겼다. 축약·정규화·대체·정정하지 않는다.
- 보고서 설명은 보고서가 제시한 요약이다. 이 문서 작성 과정에서 페이지의 현재 내용, 접근 가능성, 원작 화면과의 일치 여부를 새로 확인하지 않았다.
- 계획서에서 보고서 출처를 사용할 때는 해당 항목을 먼저 읽고 원 URL을 그대로 기록한다. 실제로 비교한 게임 화면/상태 URL이나 캡처 증거는 별도 필드에 남긴다. 둘은 서로 대체하지 않는다.
- 원보고서의 `cite...` 표식은 대화 안에서만 의미가 있는 인용 ID이며 URL이 아니다. URL로 복원하거나 비슷한 주소로 바꾸지 않는다.
- 보고서는 Godot-MCP도 언급하지만 본문에 직접 쓴 URL을 제공하지 않았다. 이 정본에서는 그 주소를 추측하지 않는다.

## 최우선: 실제 게임 UI 사례

### Dead Space

- 보고서 제목: **Dead Space UI GDC 요약**
- 우선도/유형: A+ · 사례 연구
- 보고서 요약: RIG를 통해 체력·인벤토리·무기 선택·locator를 게임 세계와 행동에 결합한 UI 사례.
- 보고서 원 URL: [https://www.gamedeveloper.com/design/video-designing-i-dead-space-i-s-immersive-user-interface](https://www.gamedeveloper.com/design/video-designing-i-dead-space-i-s-immersive-user-interface)
- TIN 적용 경계: [UI 레퍼런스 사용 규칙](UI_REFERENCE_ADAPTATIONS.md)

### Destiny

- 보고서 제목: **Destiny — Tenacious Design and the Interface**
- 우선도/유형: A+ · GDC 원자료
- 보고서 요약: 초보자에게는 단순성을, 숙련자에게는 깊이와 빠른 접근을 제공하는 인터페이스. free cursor, time-gated interactions, localization, icon creation pipeline, Director를 다룬다고 소개한다.
- 보고서 원 URL: [https://gdcvault.com/play/1023460/Tenacious-Design-and-The-Interface](https://gdcvault.com/play/1023460/Tenacious-Design-and-The-Interface)
- TIN 적용 경계: [UI 레퍼런스 사용 규칙](UI_REFERENCE_ADAPTATIONS.md)

### Persona 5

- 보고서 제목: **Persona 5 UI 개발 사례**
- 우선도/유형: A+ · 개발자 패널 정리
- 보고서 요약: 선·명도·레이아웃과 각도를 시선 및 위치 인식에 연결하고, UI 정체성·해상도·메모리 고려를 다룬다.
- 보고서 원 URL: [https://personacentral.com/persona-5-panel-concept-development-ui/](https://personacentral.com/persona-5-panel-concept-development-ui/)
- TIN 적용 경계: [UI 레퍼런스 사용 규칙](UI_REFERENCE_ADAPTATIONS.md)

### Metaphor ReFantazio

- 보고서 제목: **Metaphor: ReFantazio UI 인터뷰**
- 우선도/유형: A · 사례 인터뷰
- 보고서 요약: UI 애니메이션을 감정 증폭에 사용하되, 가독성·기능성과 충돌하면 반복 조정하는 사례.
- 보고서 원 URL: [https://www.theverge.com/games/636243/metaphor-refantazio-ui-menu-interview-koji-ise](https://www.theverge.com/games/636243/metaphor-refantazio-ui-menu-interview-koji-ise)
- TIN 적용 경계: [UI 레퍼런스 사용 규칙](UI_REFERENCE_ADAPTATIONS.md)

## 공식 문서와 도구

| 보고서 제목 | 우선도/유형 | 보고서에서 제시한 쓰임 | 보고서 원 URL |
|---|---|---|---|
| 고도엔진 — 컨테이너 사용하기 | S · 공식 문서, 한국어 | 수동 좌표보다 Container 기반 레이아웃을 우선하는 근거 | [https://docs.godotengine.org/ko/4.x/tutorials/ui/gui_containers.html](https://docs.godotengine.org/ko/4.x/tutorials/ui/gui_containers.html) |
| 고도엔진 — 키보드/컨트롤러 탐색 및 포커스 | S · 공식 문서, 한국어 | UI 포커스 탐색 및 keyboard/controller 경로 | [https://docs.godotengine.org/ko/4.x/tutorials/ui/gui_navigation.html](https://docs.godotengine.org/ko/4.x/tutorials/ui/gui_navigation.html) |
| 고도엔진 — 다양한 해상도 | S · 공식 문서, 한국어 | 기준 해상도·stretch·화면 비율 처리 | [https://docs.godotengine.org/ko/4.x/tutorials/rendering/multiple_resolutions.html](https://docs.godotengine.org/ko/4.x/tutorials/rendering/multiple_resolutions.html) |
| 고도엔진 공식 Demo Projects | S · 공식 오픈소스 | Control Gallery, Input Mapping GUI, Multiple Resolutions, Pseudolocalization, GUI Theme 예제 | [https://github.com/godotengine/godot-demo-projects](https://github.com/godotengine/godot-demo-projects) |
| Cursor 공식 Docs | S · 바이브코딩 도구 공식 문서 | 프로젝트 Rules와 컨텍스트 관리 | [https://cursor.com/docs](https://cursor.com/docs) |
| Claude Code — Project Memory | S · 바이브코딩 도구 공식 문서 | `CLAUDE.md`/`AGENTS.md`와 지속 프로젝트 문맥 | [https://code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory) |
| Xbox Accessibility Guidelines | A · 공식 접근성 가이드 | 게임 UI 접근성 설계와 검수 | [https://learn.microsoft.com/en-us/xbox/accessibility/guidelines](https://learn.microsoft.com/en-us/xbox/accessibility/guidelines) |

## 학술 논문

| 보고서 제목 | 우선도/유형 | 보고서에서 제시한 쓰임 | 보고서 원 URL |
|---|---|---|---|
| Pinelle et al., Heuristic Evaluation for Games | A · 학술 논문 원문 | 여러 장르 게임의 usability 문제를 바탕으로 게임 특화 휴리스틱을 제시 | [https://dl.acm.org/doi/10.1145/1357054.1357282](https://dl.acm.org/doi/10.1145/1357054.1357282) |
| Desurvire et al., Using Heuristics to Evaluate the Playability of Games | A · 학술 논문 원문 | 초기 프로토타입 playability 휴리스틱 평가 | [https://dl.acm.org/doi/10.1145/985921.986102](https://dl.acm.org/doi/10.1145/985921.986102) |

## 오픈소스 구현과 포럼 사례

| 보고서 제목 | 우선도/유형 | 보고서에서 제시한 쓰임 | 보고서 원 URL |
|---|---|---|---|
| GdUnit4 | A · 오픈소스 테스트 | Godot 4의 GDScript/C# 및 scene testing 참고 | [https://github.com/godot-gdunit-labs/gdUnit4](https://github.com/godot-gdunit-labs/gdUnit4) |
| Godot Forum — Box Container Separation | B · 포럼 | Container 간격과 theme constant override 사례 | [https://forum.godotengine.org/t/box-container-separation/61607](https://forum.godotengine.org/t/box-container-separation/61607) |
| Godot Forum — Card Tooltip UI | B · 포럼 | 여러 대상에 재사용하는 tooltip scene 사례 | [https://forum.godotengine.org/t/card-tooltip-ui/77934](https://forum.godotengine.org/t/card-tooltip-ui/77934) |

포럼 글과 오픈소스 주소는 구현 채택 승인이나 현재 버전 호환성 인증이 아니다. 외부 코드를 가져올 때는 `AGENTS.md`의 commit/tag, license, 버전, 파일, 의존성 감사를 별도로 수행한다.
