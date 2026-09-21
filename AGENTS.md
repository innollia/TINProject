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

## 설계 사고 기준 — 사용자와 같은 곳을 볼 것

이 프로젝트의 게임 설계에서는 **정리된 장르 문법보다 사용자가 재미있어 한 순간·상황·이미지의 맛을 먼저 보존한다.**

### 기본 사고 순서

금지되는 기본 순서:

```text
설정
→ 장르 선택
→ 유명 게임 레퍼런스 선택
→ 코어 루프 정의
→ 설정을 그 루프 안에 밀어 넣기
```

기본 순서:

```text
사용자가 보고 싶어 한 순간 / 상황 / 이상한 발상 수집
→ 각각 왜 재밌는지 한 문장으로만 식별
→ 그 순간을 실제 플레이로 성립시키는 최소 행동을 설계
→ 여러 순간에서 실제로 반복되는 요구가 확인되면 그때 시스템화
→ 필요하면 장면마다 플레이 방식이 달라도 허용
```

### 핵심 원칙

- **장르를 먼저 정하지 않는다.** 사용자가 "이건 이런 게임"이라고 정하지 않은 이상 RPG, 이머시브심, 샌드박스, VN, 로그라이크 등으로 먼저 분류하지 않는다.
- **유명 게임은 설명용 참고일 뿐 설계 틀이 아니다.** 레퍼런스의 코어 루프를 사용자 아이디어 위에 덮어씌우지 않는다.
- **사용자가 좋아한 것은 상황 자체일 수 있다.** 공룡이 나온다고 공룡 시스템을 중심으로 키우지 않고, 환생자가 나온다고 회귀 시스템을 중심으로 키우지 않는다.
- **한 게임형 모듈 안에서 플레이 방식이 바뀌어도 된다.** 서로 다른 장면이 탐색, 규칙 퍼즐, 조작, 추리, 짧은 액션, UI 놀이 등 서로 다른 문법을 요구할 수 있다.
- **통일감보다 변칙성과 발견 밀도가 우선할 수 있다.** 시스템 통일 때문에 아이디어가 평범해지면 아이디어를 살리고 시스템을 버린다.
- **설명해서 정리하지 않는다.** 이상한 설정은 플레이어가 겪는 동안 이상한 채로 존재할 수 있다. 세계관 해설이 재미를 대체하면 실패다.
- **사용자 아이디어를 '게임답게' 교정하지 않는다.** 먼저 그 아이디어에서 실제로 보고 싶은 순간이 무엇인지 보존한다.
- **AI가 넣은 구조는 언제든 폐기 가능한 제안이다.** 사용자 원재료보다 우선하지 않는다.

### 계획서 작성 순서

새 콘텐츠/게임형 모듈 계획은 가능하면 아래 순서로 쓴다.

1. **USER MOMENTS** — 사용자가 직접 준, 실제로 보고 싶은 순간/상황/이미지
2. **WHY IT HITS** — 그 순간의 재미가 어디 있는지 짧게 식별
3. **PLAYABLE FORM** — 그 순간을 관람이 아니라 플레이로 만들기 위해 필요한 최소 행동
4. **VARIATION** — 같은 방식 반복을 피하기 위한 변형
5. **ONLY THEN SYSTEMS** — 실제 여러 순간에서 공통으로 필요한 것만 시스템화
6. **CONTENT DENSITY** — 다음 순간이 충분히 빨리 오도록 authored content를 배치
7. **IMPLEMENTATION** — 파일/API/저장/테스트

### 기존 '시스템 우선' 규칙과의 관계

게임형 모듈의 구현 단계에서는 여전히 **견고한 시스템 기반을 먼저 구현**한다.  
하지만 **무슨 시스템을 만들지 결정하는 설계 단계**에서는 사용자 순간과 콘텐츠 요구가 먼저다.

즉:

```text
설계: moment → playable form → repeated need → system
구현: system foundation → authored content
```

"시스템 우선"을 이유로 콘텐츠의 맛을 먼저 일반화하거나 장르를 고정하지 않는다.

---

## 작업 방식

- "이어서 작업"처럼 범위가 열린 요청은 `HANDOVER.md`와 계획서를 후보 목록으로 사용하되, **사용자 확정 설계를 과거라는 이유로 폐기하지 않는다**. 현재 코드·테스트에서 이미 구현됐는지 확인한 뒤 미완료 산출물을 정한다.
- 설계 질의(`/grill`류) 전에 `PROJECT_DECISIONS.md`와 관련 계획서를 대조한다. 이미 사용자 답이 있는 질문은 반복하지 않는다. 현재 사용자의 `몰라/모름`은 명시적 철회가 아닌 이상 기존 사용자 확정값을 취소하지 않는다.
- 문서에서 **사용자 확정 / AI 기본값 / 구현 기록 / 미정**의 출처를 구분한다. AI가 임의로 만든 이름·라우트·수치를 사용자 설정으로 재서술하지 않는다.
- 변경 전에 관련 테스트를 먼저 실행해 기준선을 남긴다. 기존 실패와 새 회귀를 구분하고, 기존 실패를 발견하면 원인을 확인하기 전까지 새 기능 범위를 넓히지 않는다.
- Antigravity나 서브에이전트에는 소유 파일, 산출물, 금지 범위, 검증 명령이 포함된 하나의 독립 작업만 맡긴다. 같은 파일을 주 작업자와 동시에 수정하지 않는다.
- 위임 도구의 성공 상태만으로 작업 완료를 판단하지 않는다. 응답 본문, 실제 파일 변경, 테스트 결과 중 확인 가능한 산출물이 없으면 위임 결과는 없는 것으로 본다. 빈 결과는 범위를 좁혀 한 번만 재시도하고, 다시 비면 로컬 작업으로 전환한다.
- 새 모듈 설계에서 **레퍼런스를 먼저 고르지 않는다.** 먼저 사용자 순간과 `PLAYABLE FORM`을 정리한다. 그 뒤 실제 구현상 도움이 되는 인디게임/오픈소스가 있을 때만 레퍼런스를 붙이고, 가져올 구체 요소와 변형 경계를 기록한다. 레퍼런스의 코어 루프를 모듈 전체에 강제하지 않으며 원작 자산·문구·고유 캐릭터를 복제하지 않는다.
- **게임형 모듈의 구현 단계에서는 필요한 시스템 기반을 먼저 완성한다.** 단, 어떤 시스템을 만들지는 사용자 순간과 구체 콘텐츠 요구를 먼저 본 뒤 결정한다. `moment → playable form → 반복되는 필요 → system` 순서로 설계하고, 구현에 들어간 뒤 상태·입력·저장·reset·테스트 기반을 세운다. 콘텐츠를 미리 일반화해 하나의 코어 루프에 밀어 넣지 않는다.
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
