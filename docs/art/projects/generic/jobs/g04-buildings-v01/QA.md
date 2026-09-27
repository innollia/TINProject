# g04-buildings-v01 QA

전부 candidate. 승인·반려는 사용자만 한다.

## 모아 보기 시트 (자산 폴더 preview)
- `assets\art\generic\jobs\g04-buildings-v01\preview\sheet_A_1.png`
- `assets\art\generic\jobs\g04-buildings-v01\preview\sheet_B_1.png`
- `assets\art\generic\jobs\g04-buildings-v01\preview\sheet_B_2.png`
- 배치 확인(오브젝트만, 평평한 바닥): `assets\art\generic\jobs\g04-buildings-v01\preview\lineup_buildings.png`

## 확인한 것 (read 도구로 직접 봄, 자산당 수정 최대 2번)
- A: 중세 집 1차: 용마루가 동서로 뻗은 집은 60도 정면에서 앞 지붕면만 크게 보여 '지붕 판'처럼 읽혔다 → 박공이 정면을 보는 구조로 다시 만듦(양쪽 경사면이 보이고 동쪽 면은 그늘, 박공 창, 굴뚝은 동쪽 경사 위). 2차 결과 통과.
- B: B 6개 시트 2장(0.35배)을 직접 봄. 수정: 중세 가게(지붕이 건물의 절반 이상을 덮음 → 경사 높이 170 → 110 px; 뒷면 지붕에도 기와 줄). 마법사 탑·고딕 교회·헛간·풍차·동양 기와집은 1회로 통과. 교회와 헛간은 박공에 목재 틀 대신 돌·판자 박공을 쓰도록 도우미에 옵션 추가.

## 아쉬운 점
- 정면 시점이라 건물 옆벽은 보이지 않는다(RPG Maker식 정면 구성).
- 건물 한 장을 그리는 데 20~80초가 걸린다(교회가 가장 느림).
- 동양 기와집 지붕은 기와 골이 세로 줄무늬로만 보이고 처마 곡선이 약하다.
