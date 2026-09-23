# 작업자 지침

## 환경

- Godot **4.7.2 stable**, typed GDScript, GL Compatibility.
- 프로젝트: `C:\projects\TINProject\project.godot`
- 메인 씬: `app/app_root.tscn`
- GUT 9.7.1 고정.
- Ponytail이 활성 상태면 코딩 작업에 사다리(ladder)를 적용하되, 아래 TIN 경계·검증·계획 게이트를 줄이지 않는다.

## 가장 먼저 읽기

Kit 또는 게임 화면 작업 전:
1. `CONTEXT.md`
2. `PROJECT_DECISIONS.md`
3. `docs/DESIGN_PHILOSOPHY.md`
4. `docs/KIT_WORKFLOW.md`
5. `docs/VISUAL_DIRECTION.md`
6. `docs/UI_WORKFLOW.md`
7. 해당 `plans/kits/*.md`

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

## at-icons

`res://addons/at-icons/`는 모든 Kit Reference Game의 월드 아트 기본 재료다.

- UI 아이콘 사용 금지.
- 원래 pictogram 의미 그대로 사용 금지.
- 주요 오브젝트는 여러 조각을 조합.
- crop/rotation/mirror/non-uniform scale/overlap/color 변형 적극 사용.
- 3D Kit에서도 Sprite3D/plane/cutout 등 장르에 맞게 사용 가능.

원본 asset은 덮어쓰지 않는다.

## UI 보고서 적용

사용자가 제공한 UI 연구 보고서의 핵심을 적용한다:
- 정보 우선순위와 상호작용 규칙을 외형보다 우선
- 상태와 표현 분리
- focus를 첫 클래스 상태로 취급
- Container/anchor 기반 반응형
- 입력 장치와 해상도 검수
- AI 생성 UI를 자동 테스트 + 실제 실행으로 검증

그러나 보고서의 예시 컴포넌트/서비스/게임 사례 목록을 자동 구현 목록으로 승격하지 않는다. Kit의 Primary Reference가 구체 화면 문법의 우선권을 가진다.

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
8. at-icons가 원래 pictogram으로 읽히는 사용 검색

사용자 직접 플레이 검토 전에는 **검토 준비 완료**까지만 선언한다.

## 문서 작업

문서만 변경한 작업은:
- 링크 무결성
- active 문서 간 용어 일치
- Retired Prototype이 다시 구현 입력으로 노출되지 않는지
- 계획 경로가 `plans/kits/`로 정리됐는지
를 확인한다.

문서 변경만 했으면서 게임 실행/시각 검수를 완료했다고 쓰지 않는다.
