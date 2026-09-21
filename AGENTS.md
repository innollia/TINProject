# 작업자 지침

## 환경

- Godot **4.7.2 stable**, typed GDScript, GL Compatibility. 엔진 변경은 승인받는다.
- 실행 파일: `C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`
- 프로젝트: `C:\projects\TINProject\project.godot`. 메인 씬은 `app/app_root.tscn`이다.
- GUT **9.7.1**을 `addons/gut`에 고정했다. 원본 tag `v9.7.1`, commit `aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605`. 테스트 의존성이며 게임 실행에 필요하지 않다.
- Ponytail 스킬을 `.opencode/skills/ponytail/`에 고정했다. 원본 https://github.com/dietrichgebert/ponytail commit `e3ba2aa6f1e6f0bc4d69eb09c9f0d0a93af56156`, MIT. 이 스킬은 opencode가 자동 로드한다.

## 작업 경계

- Ponytail이 활성 상태면 코딩 작업에 사다리(ladder)를 적용한다. 이 프로젝트의 경계는 사다리보다 우선한다: 모듈 격리, 계약, 검증 명령은 줄이지 않는다. 검증·저장·입력 안전망은 ponytail이 줄여도 되는 것이 아니다.
- AppRoot는 유지하고 ModuleHost 자식만 교체한다. 모듈끼리는 서로의 존재를 몰라야 한다.
- core는 modules/app/meta 구현을 참조하지 않는다. 모듈은 core/contracts와 실제 필요한 shared/domain만 참조한다.
- `/root` 탐색, 서비스 로케이터, 전역 EventBus, 승인 없는 autoload 추가를 금지한다.
- 필요한 외부 기능은 ModuleContext로 명시적으로 주입한다. 현재 컨텍스트에는 모듈 ID와 입력만 있다. 필요하지 않은 서비스 참조를 미리 추가하지 않는다.
- 입력 폴링은 컨텍스트를 사용한다. 버튼 콜백도 input_enabled를 확인한다. 자식 process_mode는 INHERIT를 유지한다.
- 저장은 버전 있는 불투명 JSON이다. 상태 의미와 이관은 모듈 소유다.
- 두 번째 실제 재사용 사례가 생기기 전에는 shared 추상화를 만들지 않는다.
- 한 작업자는 한 소유 범위를 맡고, 같은 파일을 동시에 수정하지 않는다. API 변경은 조율한다.
- 무관한 폴더 수정·리팩터링, 승인 없는 패키지 추가, 요청 없는 커밋을 하지 않는다.
- 요청 없는 코드 주석을 추가하지 않는다. `.godot/`는 제외하고 소스 `.uid`는 보존한다.

## 설계 원칙

게임/콘텐츠 설계 철학의 단일 출처는 `docs/DESIGN_PHILOSOPHY.md`다.

게임형 모듈 계획·콘텐츠 확장·레퍼런스 선택 전에 먼저 읽는다.  
이 파일에는 철학을 중복 기록하지 않고 작업 절차만 둔다.


---

## 작업 방식

- "이어서 작업"처럼 범위가 열린 요청은 `HANDOVER.md`와 계획서를 후보 목록으로 사용하되, **사용자 확정 설계를 과거라는 이유로 폐기하지 않는다**. 현재 코드·테스트에서 이미 구현됐는지 확인한 뒤 미완료 산출물을 정한다.
- 설계 질의(`/grill`류) 전에 `PROJECT_DECISIONS.md`와 관련 계획서를 대조한다. 이미 사용자 답이 있는 질문은 반복하지 않는다. 현재 사용자의 `몰라/모름`은 명시적 철회가 아닌 이상 기존 사용자 확정값을 취소하지 않는다.
- 문서에서 **사용자 확정 / AI 기본값 / 구현 기록 / 미정**의 출처를 구분한다. AI가 임의로 만든 이름·라우트·수치를 사용자 설정으로 재서술하지 않는다.
- 변경 전에 관련 테스트를 먼저 실행해 기준선을 남긴다. 기존 실패와 새 회귀를 구분하고, 기존 실패를 발견하면 원인을 확인하기 전까지 새 기능 범위를 넓히지 않는다.
- Antigravity나 서브에이전트에는 소유 파일, 산출물, 금지 범위, 검증 명령이 포함된 하나의 독립 작업만 맡긴다. 같은 파일을 주 작업자와 동시에 수정하지 않는다.
- 위임 도구의 성공 상태만으로 작업 완료를 판단하지 않는다. 응답 본문, 실제 파일 변경, 테스트 결과 중 확인 가능한 산출물이 없으면 위임 결과는 없는 것으로 본다. 빈 결과는 범위를 좁혀 한 번만 재시도하고, 다시 비면 로컬 작업으로 전환한다.
- 게임형 모듈 설계는 `docs/DESIGN_PHILOSOPHY.md`를 따른다.
- 구현 계획은 해당 모듈 고유 시스템·파일·상태·테스트만 기록하고 공통 설계 철학을 반복하지 않는다.
- 외부 subsystem은 `docs/DESIGN_PHILOSOPHY.md`의 Adopt → Adapt → Build 원칙을 따르고, 계획서에는 실제 조사 결과만 기록한다.
- 새 모듈은 실제 인디게임 하나를 기준 레퍼런스로 먼저 지정하고, `PROJECT_DECISIONS.md` 또는 해당 계획서에 레퍼런스명·가져올 핵심 루프·우리 게임의 변형 경계를 기록한다. 원작의 자산·문구·고유 캐릭터는 복제하지 않는다.
- **게임형 모듈은 콘텐츠보다 시스템을 먼저 완성한다.** 샘플 레벨·사건·루프는 시스템 검증용 최소 콘텐츠로 취급하고, 이후 30분~8시간 규모 authored content를 데이터 추가로 확장할 수 있는 상태 모델·데이터 형식·입력·저장·reset·테스트를 우선한다.
- **Adopt → Adapt → Build 순서를 강제한다.** 어려운 subsystem을 처음부터 새로 만들기 전에 현재 TIN 내부 구현, 공개 GitHub, Godot Asset Library를 조사한다. permissive license와 구조가 적합하면 vendoring/포팅하고, 구조가 안 맞으면 필요한 subsystem만 추출하며, 사용할 수 없을 때만 직접 구현한다.
- 외부 베이스 조사 시 최소 repository/commit 또는 tag/license/Godot version/가져올 파일/버릴 파일/autoload·global dependency/포팅 난도를 계획서에 기록한다. **LICENSE가 확인되지 않는 코드는 복사하지 않는다.**
- 외부 코드 때문에 TIN 전체 아키텍처를 바꾸지 않는다. autoload, EventBus, 전역 저장, Input singleton 의존은 모듈 로컬 계약으로 걷어내고 외부 코드를 TIN 계약 안에 가둔다.
- 상세 게임형 모듈 계획은 `plans/game_modules/INDEX.md`와 개별 계획서를 따른다. 작업 모델은 자기 계획 파일과 필수 계약 문서만 읽고 구현할 수 있을 정도로 파일·상태·API·실패 경로·테스트를 구체화한다.
- 단순 3선택·단일 순서 입력·정답 하나만 맞히는 일회성 퍼즐은 새 모듈의 완료 기준으로 삼지 않는다. 레퍼런스의 규칙 학습, 상태 변화, 복수 판정 또는 상호작용하는 하위 시스템을 구현하고, 오답·재검토·저장 복원 경로까지 테스트한다.
- 인계 문서의 수치와 구현 설명은 현재 코드·테스트보다 우선하지 않는다. 불일치를 발견하면 코드 계약과 사용자 의도를 기준으로 판정하고, 완료 시 관련 인계 문서의 상태·테스트 수치도 함께 갱신한다.
- `/goal`은 검증 가능한 산출물 단위로 운영한다. 필수 검증이나 시각 확인이 남았으면 완료 처리하지 않고, 확인 불가 사유와 남은 확인 항목을 명시한다.

## 완료 전 검증

PowerShell에서 아래를 순서대로 실행한다. GUI 실행 파일이므로 반드시 `Start-Process -Wait -PassThru`로 종료를 기다린다. 실패 시 멈추고 출력의 SCRIPT ERROR/ERROR도 확인한다. 엔진 import가 GDScript 파싱·타입 검사이며 별도 외부 lint 도구는 도입하지 않았다.

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

영향받은 씬도 실행하고 변경 내용을 검토한다. 저장 테스트는 고유한 `user://tin_tests_*` 파일만 생성·정리하며 실제 save.json을 덮어쓰지 않는다. 테스트 통과는 목표 저사양 PC의 프레임 예산이나 화면 품질을 보증하지 않는다. 새 장르 추가 시 계약 테스트와 해당 장르 입력·상태 테스트를 함께 확장한다.

## 시각 구현 절차 — 필수

시각 작업과 신규 모듈 작업은 docs/VISUAL_DIRECTION.md를 함께 따른다.

### 구현 전에
1. 계획서에 적힌 상용 게임 레퍼런스의 실제 화면을 확인한다. 작품명만 알고 기억으로 구현하지 않는다.
2. 현재 TIN 화면을 1152×720 기준으로 캡처해 baseline을 남긴다.
3. 구현할 화면마다 플레이어가 처음 보는 장면, 1차 초점, 월드/UI 경계, 입력 전·후, focus/선택, 실패/성공/전환 상태를 확인한다.
4. res://addons/at-icons/를 사용하는 작업은 실제 checkout에 경로와 MIT 라이선스 원문이 있는지 확인한다. 없으면 다른 아이콘 세트를 임의로 대체하지 않는다.

### at-icons 사용
- UI에 사용 금지.
- 원래 의미의 픽토그램으로 사용 금지.
- 캐릭터, 건물, 가구, 배경, 기계, 생물 등 월드 아트의 콜라주 재료로 사용.
- 소스 에셋 자체는 덮어쓰기보다 모듈 로컬 scene에서 조합.
- 반복 조합이 두 번째 실제 사례에서 확인되기 전에는 공용 composer를 만들지 않는다.

### UI
- 버튼/탭/상태/입력 힌트는 텍스트와 레이아웃으로 해결한다.
- 개발 도구 같은 상단 툴바, 의미 없는 박스 나열, 아이콘 버튼 행을 기본 UI로 만들지 않는다.
- 플레이 공간보다 UI가 먼저 보이면 계획서의 레퍼런스 화면과 다시 비교한다.
- 디버그용 라벨과 상태 텍스트는 release 화면에서 제거한다.

### 시각 완료 검증
기존 import → 통합 러너 → GUT → smoke 검증 뒤에 다음을 추가한다.

1. 영향받은 모든 주요 화면을 1152×720로 직접 실행
2. 계획서의 레퍼런스와 나란히 놓고 정보 계층·여백·초점·월드 밀도 비교
3. 입력 전/후, 실패/성공, 전환 상태 확인
4. placeholder ColorRect/Label이 세계 오브젝트 역할로 남았는지 검색
5. UI에 아이콘이 들어갔는지 확인
6. at-icons 원본 하나가 원래 뜻 그대로 읽히는 사용이 있는지 확인

테스트가 통과해도 위 시각 검증이 남아 있으면 완료가 아니다.
