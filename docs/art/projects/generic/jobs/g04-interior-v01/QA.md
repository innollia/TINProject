# g04-interior-v01 QA

전부 candidate. 승인·반려는 사용자만 한다.

## 모아 보기 시트 (자산 폴더 preview)
- `assets\art\generic\jobs\g04-interior-v01\preview\sheet_A_1.png`
- `assets\art\generic\jobs\g04-interior-v01\preview\sheet_A_2.png`
- `assets\art\generic\jobs\g04-interior-v01\preview\sheet_B_1.png`
- `assets\art\generic\jobs\g04-interior-v01\preview\sheet_B_2.png`
- `assets\art\generic\jobs\g04-interior-v01\preview\sheet_C_1.png`
- 배치 확인(오브젝트만, 평평한 바닥): `assets\art\generic\jobs\g04-interior-v01\preview\lineup_interior.png`

## 확인한 것 (read 도구로 직접 봄, 자산당 수정 최대 2번)
- A: A 9개 시트 2장을 직접 봄. 수정: 수납 선반(60도에서는 위 칸 판이 아래 칸 물건을 가려서, 책장처럼 앞면 도면식으로 다시 구성; 바구니가 빗처럼 보여 엮은 통으로 교체), 무쇠 난로(연통을 몸통 위에 그리게 순서 변경), 벽난로(선반 깊이 0.59 → 0.3 m, 굴뚝 몸체를 선반 뒤로). 나머지는 1회로 통과.
- B: B 8개 시트 2장을 직접 봄. 수정: 전신 거울 깨짐(번개 모양 금이 그대로 읽힘 → 충격점에서 퍼지는 금), 가게 계산대(윗면이 검은 판처럼 보임 → 밝은 나무, 덮개 경첩선이 윗면 밖으로 나감 → 안으로). 샹들리에·램프·벽 등·괘종시계·소파·피아노는 1회로 통과.
- C: C 9개 시트(sheet_C_1)를 직접 봄. 수정: 휠체어(먼 쪽 바퀴가 검은 원반처럼 뜸 → 속이 빈 테와 바퀴살), 톱니바퀴 장치(위에 뜬 고리가 후광처럼 보임 → 축에 달린 조속기). 진자·축음기·TV·떠다니는 책·풍선·큰 인형·복고양이는 1회로 통과.

## 아쉬운 점
- 책장·옷장처럼 키 큰 가구는 60도 시점이라 윗면이 크게 보인다.
- 의자·벤치·소파는 아래(남쪽)를 보는 한 방향만 만들었다.
- 샹들리에는 머리 위 레이어(layer_hint overhead)라 게임에서 캐릭터 위에 그려야 한다.
- 휠체어는 동쪽을 보는 옆모습 한 방향만 있다.
- 복고양이 머리는 고양이 아이콘 모양이 그대로 읽힌다(알아보기 쉽게 일부러 남김).
