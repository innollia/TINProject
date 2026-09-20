# Godot 통합 팩

이 문서는 Godot 4.7.2 프로젝트에 적용한 내부 통합 계층의 출처와 범위를 기록한다. 외부 애드온의 코드를 그대로 복사하지 않고, 공개 문서·Asset Library의 기능 방향만 확인한 뒤 TINProject의 모듈 계약과 저장 규칙에 맞는 작은 런타임 어댑터로 이식한다. 전역 오토로드와 전역 이벤트 버스는 사용하지 않는다.

## 조사 기준

- Godot 공식 문서의 에디터 플러그인, 씬 인스턴스, 입력, 국제화, 오디오, 내비게이션 기능
- Godot Asset Library의 Dialog System Addon, Dialogue Manager 3, Popochiu, Game State Saver Plugin
- 기존 프로젝트의 GUT 9.7.1 고정 테스트 방식

공식 안내상 에디터 플러그인은 `addons/` 아래 `plugin.cfg`와 `EditorPlugin` 스크립트를 사용하며, 커뮤니티 애드온은 안정 tag와 라이선스를 확인한 뒤 설치해야 한다. 이 프로젝트에서는 버전 충돌과 전역 상태 오염을 피하기 위해 기능 계약만 내부 코드로 재작성한다.

## 이식 목록

| 번호 | 조사한 플러그인·템플릿·Godot 기능 | 내부 이식 지점 | 상태 |
|---:|---|---|---|
| 1 | Dialog System Addon — 대화 스크립트·분기 | `dialogue_begin`, `dialogue_next`, `dialogue_choose` | 완료 |
| 2 | Dialogue Manager 3 — 비선형 대화·변이 | `TinVisualNovelTemplate`, 대화 기록 | 완료 |
| 3 | Popochiu — 방·핫스팟·인벤토리·대화 | `scene_push`, `hotspot_visit`, `inventory_*` | 완료 |
| 4 | Game State Saver Plugin — 장면 상태·체크포인트 | `checkpoint_save/load`, `capture/restore` | 완료 |
| 5 | GUT — 자동화 테스트 | `addons/gut` 9.7.1 및 `tests/core` | 기존 적용 |
| 6 | Godot EditorPlugin — 커스텀 노드 등록 | `addons/tin_integrations/plugin.gd` | 완료 |
| 7 | 씬 인스턴싱 템플릿 | `scene_push`, `scene_pop` | 완료 |
| 8 | 버전 있는 Resource/JSON 저장 | `encode_save_slot`, `decode_save_slot` | 완료 |
| 9 | InputMap 재매핑 | `rebind`, `rebound_key` | 완료 |
| 10 | 국제화·fallback locale | `localize` | 완료 |
| 11 | VN typewriter 텍스트 | `typewriter_visible` | 완료 |
| 12 | 대화 로그·히스토리 | `dialogue_history` | 완료 |
| 13 | 선택지 그래프 | `dialogue_choose`와 현재 line 계약 | 완료 |
| 14 | 인벤토리 템플릿 | `inventory_add/remove` | 완료 |
| 15 | 퀘스트 로그 | `quest_set`, `quest_status` | 완료 |
| 16 | 관계도 수치 | `relationship_adjust` | 완료 |
| 17 | 타임라인·스토리 플래그 | `timeline_mark/has` | 완료 |
| 18 | 추리 증거 보드 | `evidence_add`, `evidence_has_all` | 완료 |
| 19 | 업적·발견 기록 | `achievement_unlock/has` | 완료 |
| 20 | 씬 라우터 스택 | `scene_push/pop` | 완료 |
| 21 | 화면 전환 상태 | `transition_begin/complete` | 완료 |
| 22 | 오디오 큐·볼륨 제한 | `audio_queue_cue`, `audio_drain` | 완료 |
| 23 | 카메라 셰이크 파라미터 | `camera_shake` | 완료 |
| 24 | 상호작용 핫스팟 방문 수 | `hotspot_visit` | 완료 |
| 25 | 모듈 범위 이벤트 큐 | `emit_event`, `drain_events` | 완료 |
| 26 | 설정 키-값 저장 | `setting_set/get` | 완료 |

## 사용 규칙

`TinIntegrationKit`은 `RefCounted`라서 모듈이나 테스트가 필요한 범위에서 직접 생성한다. `AppRoot`의 모듈 라우팅·저장·기록 소유권을 빼앗지 않으며, 모듈 간 공유가 필요해질 때는 `ModuleContext`를 통해 필요한 기능만 주입한다. `TinVisualNovelTemplate`은 대화 화면의 데이터 흐름만 제공하고, 실제 UI 스타일은 모듈이 소유한다.

## 출처

- [Godot — Installing plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)
- [Godot — Nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html)
- [Godot — List of features](https://docs.godotengine.org/en/stable/about/list_of_features.html)
- [Dialog System Addon, Asset Library #4854](https://godotengine.org/asset-library/asset/4854)
- [Dialogue Manager 3, Asset Library #3654](https://godotengine.org/asset-library/asset/3654)
- [Popochiu, Asset Library #1556](https://godotengine.org/asset-library/asset/1556)
- [Game State Saver Plugin, Asset Library #3181](https://godotengine.org/asset-library/asset/3181)
