# g04-dungeon-v01 QA

전부 candidate. 승인·반려는 사용자만 한다.

## 모아 보기 시트 (자산 폴더 preview)
- `assets\art\generic\jobs\g04-dungeon-v01\preview\sheet_A_1.png`
- `assets\art\generic\jobs\g04-dungeon-v01\preview\sheet_A_2.png`
- 배치 확인(오브젝트만, 평평한 바닥): `assets\art\generic\jobs\g04-dungeon-v01\preview\lineup_dungeon.png`

## 확인한 것 (read 도구로 직접 봄, 자산당 수정 최대 2번)
- A: A 10개 시트 2장(sheet_A_1, sheet_A_2)을 직접 봄. 수정: 보물상자 열림(뚜껑이 떠 보임 → 몸통 뒤 가장자리에 붙임), 나무 통(테 4개가 줄무늬처럼 보임 → 3개, 널 이음 진하게; 부서짐의 떨어진 테 굵게), 횃불대·벽 횃불(머리의 번개 모양 금 → 감은 천 띠). 관·쇠창살 문·레버·나무 문·상자·화로는 1회로 통과.

## 아쉬운 점
- 부서진 통의 떨어진 테가 윤곽선 고리처럼 가늘게 보인다.
- 불꽃이 없는 켜짐 그림은 g01·g02 불꽃 효과를 anchors.flame_anchor에 얹어야 완성된다.
