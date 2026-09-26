# 외부 코드·의존성 결정

## godot-jrpg

조사: `https://github.com/kuryart/godot-jrpg`  
감사 HEAD: `6d62e6e75d9533240eddc289a991607f39ef5780`  
라이선스: MIT

결정: 전체 addon/framework/dependency로 채택하지 않는다.

이유:

- README가 action RPG와 complex battle system을 비목표로 명시한다.
- WIP plugin version `0.1`이다.
- autoload/GameManager/EventBus가 TIN module boundary와 충돌한다.
- scene-swap battle shell이 ModuleHost lifecycle과 충돌한다.
- Resource save가 TIN JSON-safe save와 충돌한다.
- fixed speed action order는 BS2-style scheduler와 다르다.
- third-party dependency와 mixed art license를 별도 승인해야 한다.

재사용하는 것은 개념뿐이다.

- domain/presentation 분리
- intent 후 atomic resolution
- Resource-based authored data
- modifier re-computation
- controller/command 분리
- event command authoring

구현은 `modules/top_down_action_rpg/`가 직접 한다.

## Exact file reuse 조건

향후 필요할 때만 다음을 모두 만족하는 single file을 검토한다.

- exact path와 commit SHA 고정
- MIT 범위 확인
- Godot 4.7.2 parse/run 확인
- dependency zero 또는 별도 승인
- TIN module contract 준수
- file 외 architecture 변경 없음
- dedicated test 존재
- file-level provenance 기록

전체 framework import는 허용하지 않는다.

## 이미지

현행 제작 방향은 GPT image 기반이다. at-icons는 현재 제작 기준으로 채택하지 않는다. 이번 one-shot에서 이미지 생성/editing은 asset request가 있을 때만 실행한다.

계획은 필요한 asset family와 `docs/IMAGE_ASSET_WORKFLOW.md` brief를 먼저 작성하되, candidate를 자동 Gold Standard로 승격하지 않는다.
