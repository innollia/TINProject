# g04-dungeon-v01 QA

전부 candidate. 승인·반려는 사용자만 한다.

## 모아 보기 시트 (자산 폴더 preview)
- `assets\art\generic\jobs\g04-dungeon-v01\preview\sheet_A_1.png`
- `assets\art\generic\jobs\g04-dungeon-v01\preview\sheet_A_2.png`
- `assets\art\generic\jobs\g04-dungeon-v01\preview\sheet_B_1.png`
- `assets\art\generic\jobs\g04-dungeon-v01\preview\sheet_B_2.png`
- `assets\art\generic\jobs\g04-dungeon-v01\preview\sheet_C_1.png`
- 배치 확인(오브젝트만, 평평한 바닥): `assets\art\generic\jobs\g04-dungeon-v01\preview\lineup_dungeon.png`

## 확인한 것 (read 도구로 직접 봄, 자산당 수정 최대 2번)
- A: A 10개 시트 2장(sheet_A_1, sheet_A_2)을 직접 봄. 수정: 보물상자 열림(뚜껑이 떠 보임 → 몸통 뒤 가장자리에 붙임), 나무 통(테 4개가 줄무늬처럼 보임 → 3개, 널 이음 진하게; 부서짐의 떨어진 테 굵게), 횃불대·벽 횃불(머리의 번개 모양 금 → 감은 천 띠). 관·쇠창살 문·레버·나무 문·상자·화로는 1회로 통과.
- B: B 9개 시트 2장(sheet_B_1, sheet_B_2)을 직접 봄. 큰 술통·꽃병·선물 상자·제단·석상·성문·책장 비밀 문·바닥 뚜껑·발코니 문 모두 1회로 통과(수정 없음).
- C: C 7개 시트(sheet_C_1, 0.75배)를 직접 봄. 단두대·교수대·철의 처녀·톱날 함정·이상한 문·벽 족쇄·큰 새장 모두 1회로 통과(수정 없음). 신체·피는 넣지 않고 빈 기구만 그렸다.

## 아쉬운 점
- 부서진 통의 떨어진 테가 윤곽선 고리처럼 가늘게 보인다.
- 불꽃이 없는 켜짐 그림(횃불·화로·제단 촛불)은 g01·g02 불꽃 효과를 anchors에 얹어야 완성된다.
- 책장 비밀 문의 열림 그림은 돌아간 책장이 판자처럼만 보여 책장이라는 게 덜 읽힌다.
- 교수대 옆 계단이 정면 시점이라 세로로 쌓인 상자처럼 보인다.
- 톱날 함정의 톱날은 톱니바퀴 아이콘 모양이 남아 있다.
