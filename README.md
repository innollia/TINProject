# TINProject

There Is No Game: Wrong Dimension 스타일의 장르 혼합 메타 게임 프로토타입. Godot 4.7.2 / GDScript.

## 무엇이 있나

- 영속 AppRoot 셸 + ModuleHost의 현재 모듈만 교체
- 데모 모듈 3개: `click_counter`, `box_mover`, `room_3d`
- 코어 서비스: 저장(불투명 JSON 봉투), 입력 라우팅, 화면 전환, 설정, 오디오
- 통합 테스트 러너(639 checks) + GUT 9.7.1 코어 계약 테스트
- AI 작업 규칙: `AGENTS.md`, `docs/`

## 실행

Godot 4.7.2로 `project.godot` 열고 F5. 창 1152×720.

## 테스트

`AGENTS.md`의 검증 명령 참고. 핵심은:

```powershell
$GodotExe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'
$p = Start-Process -FilePath $GodotExe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/run_tests.gd' -NoNewWindow -Wait -PassThru
$p.ExitCode
```

## 구조

```
app/     영속 셸 조립, 카탈록, 전역 UI
core/    contracts(계약) + services(저장/입력/전환/설정/오디오/director)
meta/    진행도, 내레이터 문구
modules/<id>/  독립 장르 모듈. 서로 참조 금지
tests/   통합 러너 + GUT 코어 계약 테스트
docs/    ARCHITECTURE, MODULE_CONTRACT, CODE_STYLE, decisions
```

## 새 모듈 추가

1. `modules/<id>/`에 `module_manifest.tres`, `entry.tscn`, `module.gd` 생성(`tests`의 기존 모듈 참고)
2. `app/app_root.tscn`의 카탈로그에 manifest 추가, 전용 키가 필요하면 앱 입력 바인딩에 추가
3. 기존 모듈과 core는 수정하지 않는다. 계약은 `docs/MODULE_CONTRACT.md`

## 라이선스 및 서드파티

- 게임 코드: 프로젝트 자체 코드(라이선스 미정)
- `addons/gut`: GUT 9.7.1 (MIT, github.com/bitwes/Gut)
- `.opencode/skills/ponytail`: Ponytail 스킬 (MIT, github.com/dietrichgebert/ponytail, commit e3ba2aa)
