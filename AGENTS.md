# 작업자 지침

## 환경

- Godot **4.7.2 stable**, typed GDScript, GL Compatibility.
- 프로젝트: `C:\projects\TINProject\project.godot`
- 메인 씬: `app/app_root.tscn`
- GUT 9.7.1 고정.
- Ponytail이 활성 상태면 코딩 작업에 사다리(ladder)를 적용하되, 아래 TIN 경계·검증·계획 게이트를 줄이지 않는다.

## 가장 먼저 읽기

설계 인터뷰, 계획, Kit 또는 게임 화면 작업 전:
1. `CONTEXT.md`
2. `PROJECT_DECISIONS.md`
3. `docs/GRILLING_STATE.md`
4. `docs/DESIGN_PHILOSOPHY.md`
5. `docs/KIT_WORKFLOW.md`
6. `docs/VISUAL_DIRECTION.md`
7. `docs/IMAGE_ASSET_WORKFLOW.md`
8. `docs/UI_WORKFLOW.md`
9. `docs/UI_REFERENCE_SOURCES.md`와 `docs/UI_REFERENCE_ADAPTATIONS.md`
10. 해당 `plans/kits/*.md`

### Grilling bootstrap

`docs/GRILLING_STATE.md`의 상태가 ACTIVE이면:
- Settled 항목을 다시 묻지 않는다.
- Rejected 항목을 새 정보 없이 다시 제안하지 않는다.
- 질문은 Current Frontier에서만 시작한다.
- 사실/코드 상태는 에이전트가 조사하고, 설계 선택만 사용자에게 묻는다.
- 새 결정이 나오면 해당 라운드 안에서 state 문서와 정본 문서에 반영한다.
- project-wide grilling 종료와 사용자 shared-understanding 확인 전에는 기존 `plans/kits/`를 수정하거나 새 Kit 계획서를 작성하지 않는다.

문서 간 모순을 발견하면 전체 결정을 재질문하지 말고 충돌한 항목만 정확히 제시한다.

런타임 계약 변경이면 추가:
- `docs/ARCHITECTURE.md`
- `docs/MODULE_CONTRACT.md`

## 프로젝트 해석

TINProject는 여러 독립 게임의 모음이 아니다. **한 게임 안에서 장르가 바뀌는 게임**이다.

`Kit`는 장르 시스템 계획 단위다.  
`GameModule`은 런타임 교체 단위다.

모듈 수/사이클 수/신규 게임 수를 성과로 세지 않는다.

## 현재 whitelist

새 작업의 기반 후보:
- `modules/first_entry/**` — 시작/입력 학습 로직
- `modules/rule_rewriting/**` — 규칙 시스템 기반
- `modules/odd_road_adventure/**` — 어드벤처 시스템 기반
- `modules/game_library/**` — 개발/탐색용 목록 UI

그 외 기존 플레이 모듈은 **Retired Prototype**이다.

Retired Prototype에서:
- 아이디어를 재사용하지 않는다.
- 대사를 재사용하지 않는다.
- UI를 참고하지 않는다.
- “이미 구현돼 있으니 고친다”를 기본값으로 삼지 않는다.
- 새 Kit에 필요한 subsystem이 있을 때만 코드 단위로 재검증한다.

Git 이력이 보존 역할을 한다. 박물관 폴더를 새로 만들지 않는다.

## 계획 게이트

**계획서가 완성되기 전에는 Kit 구현을 시작하지 않는다.**

계획서는 `docs/KIT_WORKFLOW.md`의 필수 항목을 모두 가져야 한다.

각 Kit 계획에는 톤앤매너와 실제 제작할 이미지 자산의 생성·편집 명세를 포함한다. 길면 `plans/kits/`의 별도 시각 명세로 분리해 계획서에서 링크한다. 필수 입력 문서나 레퍼런스를 읽을 수 없어 내용이 불분명하면 이미지를 추측해 생성하지 않는다.

특히:
- Primary Reference 하나
- 실제 화면/플레이 출처
- 따라갈 시스템/UX
- 10분+ Reference Game
- authored content 단위
- 상태/데이터 모델
- 입력/저장/복구
- 720p/FHD/QHD
- 수동 플레이 과제
- 금지 shortcut
- 완료 증거

`알아서`, `게임답게`, `레퍼런스 느낌으로`, `적당히` 같은 문장이 구현 결정을 대신하면 계획 미완성이다.

## Primary Reference 규칙

Kit마다 Primary Reference는 정확히 하나다.

구현 전에 실제 화면과 플레이를 확인한다. 작품명을 알고 있다는 이유로 기억에서 구현하지 않는다.

레퍼런스가 필요한데 외부 자료를 확인하지 못했으면:
- 임의로 채우지 않는다.
- 화면 구현을 시작하지 않는다.
- 확인이 필요한 상태를 계획에 남긴다.

여러 게임의 UI/시스템을 평균내지 않는다. Secondary Reference는 사용자가 명시적으로 허용한 특정 확장점에만 쓴다.

## Reference Game

각 Kit는 최소 10분 이상 플레이 가능한 Reference Game으로 검증한다.

10분을 다음으로 채우지 않는다:
- 긴 이동
- 대기
- 같은 입력 반복
- 대사만 늘리기
- 적 HP만 늘리기

같은 Kit 시스템에 서로 다른 authored content를 여러 번 넣어야 한다.

새 콘텐츠 추가 때문에 parser/combat/save/registry 등 core system을 반복 수정하면 Kit 미완성이다.

전용 에디터 툴은 완료조건이 아니다.

## 시스템 경계

- AppRoot는 유지하고 ModuleHost 자식만 교체한다.
- 모듈끼리는 서로의 존재를 모른다.
- core는 구체 modules/app/meta 구현을 참조하지 않는다.
- 모듈은 필요한 core/contracts와 주입된 ModuleContext만 사용한다.
- `/root` 탐색, 서비스 로케이터, 범용 EventBus, 승인 없는 autoload 추가 금지.
- 입력 폴링은 ModuleContext를 사용한다.
- 저장은 버전 있는 JSON-safe 상태다.
- 두 번째 실제 사용처 전에는 shared 추상화를 만들지 않는다.
- 외부 코드 때문에 TIN 전체 아키텍처를 바꾸지 않는다.

Kit 전체를 안정된 외부용 공개 API로 만들지 않는다.

## 화면과 UI

기본값은 **아무것도 띄우지 않는 것**이다.

상시 HUD를 추가하려면 Primary Reference와 게임 상태에서 항상 필요한 정보라는 근거가 있어야 한다.

금지:
- 좌상단 공간/자동저장/키설명 뭉치
- 우상단 Menu/Journal 버튼
- 개발 툴바
- debug label의 release 노출
- 장문 조작 설명
- placeholder ColorRect/Label을 월드 오브젝트로 완료 처리
- 버튼 목록으로 월드 플레이를 대체
- 무엇을 선택 중인지 알 수 없는 focus

Shell은 호출 전까지 시각적 존재감 0. Esc 메뉴는 Esc를 누를 때만 보인다.

## Input Bubble

새 장르 구간에서 필요한 물리 키가 달라질 때 `docs/KIT_WORKFLOW.md`의 Input Bubble 계약을 따른다.

핵심:
- 움직이는 무늬 배경
- 키마다 고정된 가상 grid cell
- 새 키는 아래에서 올라와 정착
- 다음 구간에서도 필요한 터진 키는 복구
- 필요 없는 키는 터진 흔적으로 유지
- 실제 키를 누르면 해당 방울이 터짐
- 설명문으로 기능을 해설하지 않음
- 리바인딩 시 실제 바인딩 표시

`first_entry`를 보존한다는 뜻은 현재 설명문/presentation을 그대로 보존한다는 뜻이 아니다. 시작 로직만 whitelist다.

## 이미지 자산 방향 전환

아이콘 기반 이미지 제작 문서와 실험 자료는 `archive/icon_based_image_assets/`에 보관한다. 이미 만들어진 SVG/PNG 및 기타 이미지 파일은 기존 위치와 내용 그대로 둔다. 아카이브 자료는 과거 기록이며 현재 제작 기준이 아니다.

## GPT 이미지 제작 권한과 경계

2026-09-25 사용자 결정으로 기존 생성 이미지 절대 금지를 해제했다. `image_gen`, GPT Image 및 사용자가 허용한 생성형 이미지 도구로 TIN 이미지 자산을 제작·편집할 수 있다.

- 문서 정리, 계획, 검토만 요청받은 상태에서 이미지를 임의로 생성하지 않는다. 현재 요청이 구체적인 이미지 자산의 제작·편집을 포함할 때 실행한다.
- 권한 충돌은 `최신 사용자 결정 → 프로젝트 아트 층 → 개인 화풍 코어 → 역할이 제한된 A/B Style Reference → 해당 자산군 Gold Standard` 순서로 해소한다.
- A/B는 영구 Style Reference다. A는 얼굴 구조·명암 면·내부 붓결, B는 선 강약·의상 구조·실루엣·밀도 대비·배경 콜라주성에만 사용하며 인물, 의상, 모티프, 정확한 색 조합을 복제하지 않는다.
- Gold Standard는 환경/배경, 게임플레이 스프라이트, UI, 리깅용 전신 파츠, 비주얼노벨 전신·초상, 조사 화면의 자산군별 묶음으로 관리한다. 프로젝트에 필요한 묶음만 활성화한다.
- 이미지 제작 파일 구조, 독립 작업 입력, Gold Standard 승인 절차, 제작 단위와 검수 게이트는 `docs/IMAGE_ASSET_WORKFLOW.md`를 따른다.
- 배경 제작 brief는 오브젝트를 `증거·직접 상호작용`, `길찾기·상황 이해`, `분위기`의 3단계로 명시한다. 모델이나 작업자가 중요도를 임의 추론하거나 승격하지 않는다.
- GPT 출력은 최종 그림이다. 사람의 재작화, 수동 선 보정, 자산별 색칠 보정은 제작 공정에 넣지 않는다.
- 허용하는 기계적 후처리는 투명화/배경 분리, 크롭, 캔버스·피벗 정렬, 레이어 분리, 리사이즈, 아틀라스 패킹, 색 프로파일 변환, 결정론적 알파 매트·가장자리 정리다.
- 기계적 후처리로 고칠 수 없는 오류는 GPT 국소 편집 또는 재생성으로 되돌린다. 에이전트가 오류를 발견해도 현재 사용자 요청에 이미지 편집·재생성이 포함되지 않았다면 실행하지 않는다.
- 최종 판정은 고립된 이미지가 아니라 실제 게임 화면의 정보 계층, 일관성, 입력 상태, 지원 해상도에서 한다.

## UI 보고서 적용

사용자가 제공한 UI 연구 보고서의 핵심을 적용한다:
- 정보 우선순위와 상호작용 규칙을 외형보다 우선
- 상태와 표현 분리
- focus를 첫 클래스 상태로 취급
- Container/anchor 기반 반응형
- 입력 장치와 해상도 검수
- AI 생성 UI를 자동 테스트 + 실제 실행으로 검증

그러나 보고서의 예시 컴포넌트/서비스/게임 사례 목록을 자동 구현 목록으로 승격하지 않는다. Kit의 Primary Reference가 구체 화면 문법의 우선권을 가진다.

보고서에 직접 적힌 URL을 인용할 때는 `docs/UI_REFERENCE_SOURCES.md`의 문자열을 그대로 보존한다. 실제 비교한 화면 URL/캡처는 별도로 기록한다.

## 해상도

필수 수동 검수:
- 1280×720
- 1920×1080
- 2560×1440

현재 `project.godot`의 과거 1152×720 설정은 지원 완료 근거가 아니다.

검수:
- UI 겹침/잘림 없음
- focus 표시 유지
- 월드 플레이 영역 유지
- 격자형 게임은 셀 비율 유지
- 긴 문자열/최대 데이터
- 메뉴 open/close 복귀

## 외부 subsystem

Adopt → Adapt → Build:
1. 현재 TIN 내부 구현 확인
2. 공개 GitHub / Godot Asset Library / 공식 demo 조사
3. license/version/global dependency 확인
4. 맞으면 필요한 subsystem만 채택
5. 맞지 않으면 구조만 참고
6. 그래도 없으면 직접 구현

LICENSE가 확인되지 않는 코드는 복사하지 않는다.

## 작업 소유권

- 한 작업자는 한 소유 범위.
- 같은 파일 동시 수정 금지.
- 무관한 폴더 리팩터링 금지.
- 승인 없는 패키지 추가 금지.
- 요청 없는 커밋 금지.
- 요청 없는 코드 주석 추가 금지.
- `.godot/` 제외, 소스 `.uid` 보존.

## 완료 전 자동 검증

PowerShell에서 순서대로:

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait -PassThru
$p.ExitCode
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/run_tests.gd' -NoNewWindow -Wait -PassThru
$p.ExitCode
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gexit' -NoNewWindow -Wait -PassThru
$p.ExitCode
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --quit-after 180 --fixed-fps 60' -NoNewWindow -Wait -PassThru
$p.ExitCode
```

실패 시 멈추고 기존 실패와 신규 회귀를 구분한다.

## Kit 완료 전 수동 검증

자동 검증 뒤:
1. Primary Reference 상태별 화면과 비교
2. Reference Game을 처음부터 끝까지 플레이
3. 실측 플레이타임 확인
4. authored content 추가 시 core 무수정 확인
5. 720p/FHD/QHD 실행 캡처
6. 입력 전/후, 실패/성공, save/load/reset 확인
7. placeholder/상시 HUD/설명문 검색
8. 새 이미지 자산 기반과 출처/라이선스 준수 확인

사용자 직접 플레이 검토 전에는 **검토 준비 완료**까지만 선언한다.

## 문서 작업

문서만 변경한 작업은:
- 링크 무결성
- active 문서 간 용어 일치
- Retired Prototype이 다시 구현 입력으로 노출되지 않는지
- 계획 경로가 `plans/kits/`로 정리됐는지
를 확인한다.

문서 변경만 했으면서 게임 실행/시각 검수를 완료했다고 쓰지 않는다.
