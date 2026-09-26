# 13 — Layered Environment Production

## 0. 상태와 목적

이 문서는 Top-down Action-RPG Kit의 **환경 배경 production 계약**이다. 게임플레이와 이미지 제작을 분리하되, 배경이 world protocol과 route를 설명하도록 만든다.

현재 상태:

- Project Art Layer: 존재
- H0 environment brief: 존재
- H0 candidate: 존재하나 사용자/스타일 판정에서 승인되지 않음
- approved/Gold Standard: 없음
- 자동 생성·Gold Standard 자동 승격: 금지

## 1. 제작 단위

```text
master_composite
base_clean
prop_<name>
foreground_<name>
preview_reassembled
```

- `master_composite`: 화면 전체 기준 합성본. runtime base로 중복 사용하지 않는다.
- `base_clean`: 고정 건축·우물·바닥·벽만 남긴 배경.
- `prop_*`: 직접 상호작용 후보 오브젝트. alpha와 contact pivot을 기록한다.
- `foreground_*`: 시야를 가리지 않는 전경 가림 구조.
- `preview_reassembled`: 레이어 재합성 검수 이미지. 납품 증거일 뿐 runtime asset이 아니다.

## 2. H0 brief

정본은 `docs/art/projects/top_down_action_rpg/asset_briefs/h0_layered_environment_pilot.md`다.

- 화면: 2560×1440 기준, 논리 H0 1280×720
- 카메라: 정사영 top-down, 지면 기준 하향각 60°, 방위 고정
- 중심: dry central shelf, circular Arrival Well, four-direction passages, counter, empty Crown Well
- 정보 등급: Arrival Well/통로는 `길찾기·상황 이해`, counter는 `직접 상호작용 후보`, 마모는 `분위기`
- 사람·적·시체·눈·식물·왕관·혈흔·읽을 수 있는 글자 금지
- UI/focus/dialogue/HUD를 배경에 구우지 않는다
- 원작 Alice/BLACK SOULS 고유 지형·상징 복제 금지

## 3. 정보 우선순위

배경 제작은 분위기 우선이 아니다.

1. 현재 region과 route가 읽히는가
2. 다음 이동 방향이 읽히는가
3. 상호작용 후보가 우연히 배경 위와 분리되는가
4. combat/dialogue/document layer가 배경 위에서 읽히는가
5. 분위기 밀도가 정보 위계를 침범하지 않는가

배경 오브젝트에 임의의 evidence/interaction 의미를 추가하지 않는다. brief가 세 단계 중 하나를 명시하지 않은 오브젝트는 정보 오브젝트가 아니라 분위기 오브젝트로만 취급한다.

## 4. Style 적용

- `docs/art/PERSONAL_STYLE_CORE.md`의 현재 A 중심 규칙을 사용한다.
- A: 중앙 구조선, 큰 명암 면, 재질별 내부 붓결, 머리카락 큰 밝기 덩어리.
- B: 새 생성 입력에서 완전히 제외한다. B 유래 크롭·배경 문법도 새 필수 기준으로 승격하지 않는다.
- 특정 얼굴형, 헤어스타일, 의상, 색, 장식, 식물/하트/별/눈은 복제하지 않는다.
- 같은 texture를 모든 표면에 덮지 않는다. 바닥, 벽, 금속 기능 부품, 종이는 다른 재질 번역을 가진다.

## 5. Layer 분리 규칙

- layer를 자른 뒤 비운 자리는 base_clean에서 복원한다.
- 배경 건축, Arrival Well 위치, 통로 폭이 drift하면 반려한다.
- foreground가 주 통로나 counter를 가리면 반려한다.
- alpha 가장자리, contact shadow, crop 여백을 각 layer에서 검증한다.
- 분리된 layer는 같은 canvas/pivot 규칙으로 재조립한다.

## 6. 하드 게이트

다음 중 하나라도 실패하면 candidate를 `approved`나 Gold Standard로 옮기지 않는다.

- 2560×1440/sRGB/alpha 규격 불일치
- contact pivot 또는 안전 여백 불일치
- H0 route/Arrival Well/counter 정보 우선순위 붕괴
- 원작 고유 모티프·문자·watermark
- A Style Fidelity Gate 실패
- 일반 던전 렌더 또는 photo-real 얼굴로 수렴
- 빈 이미지/placeholder/임의 UI 굽기
- master/base/prop 좌표 drift

## 7. 승인 흐름

```text
brief
→ candidate 생성
→ mechanical hard gate
→ project/style gate
→ 실제 게임 화면 배치
→ 1280×720 / 1920×1080 / 2560×1440 검수
→ 사용자 명시적 승인
→ approved
→ Gold Standard manifest 기록
```

생성 도구 호출, candidate 보존, 재생성, 승인, Gold Standard 승격은 서로 다른 상태다. 이 문서의 존재는 이미지 제작 승인이나 최종 화면 완료를 의미하지 않는다.

## 8. 현재 Kit 연결

- `09_PRESENTATION_ART_AND_AUDIO.md`는 art key와 화면 projection을 소유한다.
- `06_AUTHORED_CONTENT_AND_DATA.md`는 content가 art key 문자열만持有하도록 한다.
- `modules/top_down_action_rpg/`는 `art_key`를 runtime 경로·색으로 해석하지 않는다.
- 현재 화면은 vector presentation으로 동작 가능하지만, 최종 Gold Standard 배경이 승인되기 전까지 이를 최종 아트 완료로 기록하지 않는다.
