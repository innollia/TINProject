# Godot 통합 팩 — legacy candidate

이 문서는 `addons/tin_integrations/`에 이미 존재하는 내부 통합 코드의 provenance와 범위를 기록한다.

**중요:** 이 팩은 새 Kit가 자동으로 써야 하는 공용 프레임워크가 아니다. 과거에 여러 기능을 한꺼번에 추상화한 코드이므로, 현재의 “두 실제 사용처 이후 shared 추출” 원칙 아래에서는 **legacy candidate**로 취급한다.

## 사용 원칙

새 Kit가 dialogue/inventory/quest/timeline/evidence 등 기능을 필요로 하면:

1. Kit의 Primary Reference와 계획에서 실제 요구를 먼저 정의한다.
2. module-local로 필요한 계약을 적는다.
3. `addons/tin_integrations/`의 기존 구현이 그 계약과 맞는지 코드 단위로 확인한다.
4. 맞는 작은 부분만 채택한다.
5. 맞지 않으면 기존 팩에 맞춰 Kit를 비틀지 않는다.
6. 두 실제 사용처에서 동일 계약이 확인되기 전에는 새 shared abstraction을 추가하지 않는다.

`TinIntegrationKit` 전체를 dependency로 끌어오는 것은 기본값이 아니다.

## 기존 조사 provenance

과거 팩은 다음 자료/기능 방향을 조사해 내부 코드로 재작성했다.

- Godot 공식 입력/국제화/오디오/scene/plugin 기능
- Dialog System Addon
- Dialogue Manager 3
- Popochiu
- Game State Saver Plugin
- GUT 9.7.1

외부 애드온 코드를 라이선스 확인 없이 복사하지 않는 원칙은 유지한다.

## 현재 상태 해석

기존 코드가 존재하거나 테스트가 통과했다는 사실은:
- 현재 Kit 요구에 적합함
- shared로 승인됨
- Reference Game의 UX에 맞음
을 의미하지 않는다.

새 작업에서 채택하려면 해당 Kit 계획과 코드 감사가 필요하다.

## 금지

- “이미 통합 팩에 inventory가 있으니 모든 Kit가 쓴다”
- “대화 API가 있으니 Primary Reference의 대화 구조를 그 API에 맞춘다”
- 사용처 없는 service 추가
- autoload/EventBus로 승격
- 기존 legacy API를 지키기 위해 장르별 domain을 왜곡

## 참고 출처

- https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html
- https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html
- https://docs.godotengine.org/en/stable/about/list_of_features.html
- https://godotengine.org/asset-library/asset/4854
- https://godotengine.org/asset-library/asset/3654
- https://godotengine.org/asset-library/asset/1556
- https://godotengine.org/asset-library/asset/3181
