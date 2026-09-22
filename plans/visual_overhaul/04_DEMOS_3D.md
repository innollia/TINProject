# 배치 04 — 데모 3종 / 3D 표현

대상:
- click_counter
- box_mover
- room_3d

데모는 우선순위가 낮지만 플레이어가 접근 가능한 동안에는 개발 placeholder처럼 보이지 않게 한다.

## click_counter
레퍼런스: There Is No Game: Wrong Dimension
- 숫자와 버튼만 있는 테스트 UI라면 작은 기묘한 월드 오브젝트 하나를 조작하는 장면으로 변환
- click icon 금지
- 숫자는 텍스트로 허용

## box_mover
레퍼런스: Baba Is You + Mosa Lina
- 상자/플레이어/벽을 plain ColorRect에서 at-icons collage silhouette로 교체
- HUD icon 없음
- 밀기 전/후가 형태와 움직임으로 읽혀야 함

## room_3d
레퍼런스: The Stanley Parable의 단순하지만 장소성이 분명한 방 staging
- primitive-only 방을 최종으로 두지 않음
- at-icons를 Sprite3D/평면 cutout/벽 장식/가구 texture 조각으로 재구성
- 3D 공간에서 billboard UI icon 금지
- 상호작용 대상은 배치, 조명, 움직임으로 구분

## 완료
각 데모 entry / interaction / result를 1152×720로 확인한다.
