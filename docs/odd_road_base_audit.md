# ODD_ROAD_ADVENTURE 베이스 감사

작성: 2026-09-21

## 결론

이번 수직 슬라이스에는 외부 코드를 복사하지 않는다. TIN의 `GameModule`·`ModuleContext`·`SaveService` 계약과 현재 모듈의 입력/저장 패턴이 더 작고, autoload·전역 이벤트·전투 의존성이 없어 직접 구현이 가장 낮은 포팅 비용이다.

| 후보 | 고정 기준 | 라이선스 | Godot | 확인한 장점 | 버릴 것 | 포팅 난도 | 판정 |
|---|---|---|---|---|---|---|---|
| `gdquest-demos/godot-open-rpg` | tag `0.4.0`, commit `ff4f907d71385d459e64383f799700e998518153` | MIT | 4.4+ 계획 기준, 현재 README는 4.6.2 요구 | 이동·상호작용 구조 참고 | 전투·Gameboard·전역 이벤트 | 중간 | 구조 참고만 |
| `miskatonicstudio/goat` | HEAD `82c92e7eb494eb59cc885e06e1e0b9b022f9e6ca` | MIT | 4.3 stable | 인벤토리·대상 상호작용·대화 아이디어 | 플러그인/전역 구조·3D 자산·음성 | 높음 | 구조 참고만 |
| `Happy-Ferret-Entertainment/Adventure-Godot` | HEAD `15643ca471272e5f7999140dbee781630ba4c83b` | LICENSE 파일 확인, 정확한 조건은 복사 전 재확인 | Godot 4 계열 | 대화·인벤토리·2D 탐색 구성 참고 | `global.gd`·NavigationSystem·씬 구조 | 높음 | 코드 복사 금지, 구조 참고만 |

## TIN에 가져오지 않은 이유

- 외부 후보는 각자 플레이어/월드/대화 전역 구조를 전제로 한다.
- TIN은 모듈마다 새 `ModuleContext`를 주입하고, 상태를 모듈 소유 JSON으로 저장해야 한다.
- 첫 구현은 이동·조사·NPC·아이템·지식·지역 전환을 하나의 모듈 로컬 상태로 검증하는 편이 짧고 검증 가능하다.

## 이번 작업에서 새로 작성한 범위

- `modules/odd_road_adventure/module.gd`: 공통 조사 문법, 4개 지역, 인벤토리/기록, NPC·사건·지식 상태, JSON 정규화
- `modules/odd_road_adventure/entry.tscn`
- `modules/odd_road_adventure/module_manifest.tres`
- `tests/core/test_odd_road_adventure.gd`

원본 저장소는 코드나 자산을 vendoring하지 않았으므로 별도 저작권 고지 파일을 추가하지 않았다. 다음 외부 재조사는 새 이동/대화/콘텐츠 편집 subsystem을 실제로 추가할 때 다시 수행한다.
