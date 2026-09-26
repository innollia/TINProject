> 2026-09-26 사용자 결정: 이 문서의 코딩 금지(스크립트·코드로 아이콘을 조합·생성하는 것 금지, 편집기 전용)는 해제됐다. 현재 허용 범위는 04 Top-down Action-RPG Kit이며 `docs/IMAGE_ASSET_WORKFLOW.md` §1을 따른다. 본문은 과거 기록이다.

# Archived AGENTS.md at-icons production rules

Archived verbatim from the project instructions on 2026-09-25, when the user retired the icon-based image asset direction. This is kept as a separate historical rules document and is not active guidance.

## at-icons

`res://addons/at-icons/`는 모든 Kit Reference Game의 월드 아트 기본 재료다.

- UI 아이콘 사용 금지.
- 원래 pictogram 의미 그대로 사용 금지.
- 주요 오브젝트는 여러 조각을 조합.
- 배치/색 전환/회전/미러/크기 조절/늘리기/겹침 변형을 사용한다.
- 원본의 일부를 자르거나 크롭·클리핑·마스킹하지 않는다.
- 대상과 같은 의미의 원본을 같은 역할로 쓰지 않는다. 예: `tree`를 나무 몸체로, `leaf`를 나뭇잎으로 사용하지 않는다.
- 3D Kit에서도 Sprite3D/plane/cutout 등 장르에 맞게 사용 가능.

원본 asset은 덮어쓰지 않는다.

at-icons를 직접 조립하는 작업은 `docs/AT_ICONS_INKSCAPE_WORKFLOW.md`를 따른다.

- 로컬 Inkscape 제어는 Computer Use의 `@oai/sky` 연결로 진입한다.
- 618개 `node2d` 원본을 등록한 Inkscape Symbols 패널에서 작업 도중 필요한 아이콘을 고른다.
- 작업 전에 별도 아이콘 풀을 정하거나 아이콘을 캔버스에 한꺼번에 올리지 않는다.
- 작은 구조 단위로 추가하고, 매 단계 화면을 확인한 뒤 다음 아이콘을 선택한다.
- 첫 조각의 원래 의미가 대상에 그대로 쓰이면 즉시 교체한다. 이름만 바꾼 SVG를 `candidate`로 승격하지 않는다.
- 후보 초안은 `tools/check_at_icons_candidate.py`로 직전 단계와 비교한다. 검사 실패 시 후보로 보고하지 않으며, 통과해도 실제 화면에서 형태를 판정한다.
- 편집기 접근 실패를 생성 이미지나 코드 생성형 아트로 우회하지 않는다.

이 금지는 `at-icons` 조합 실험에도 적용한다. 아이콘 조합은 실제 SVG 원본을 편집기에서 배치한 결과여야 하며, 생성 모델이 아이콘을 재해석한 래스터 이미지는 조합 실험 결과가 아니다.
