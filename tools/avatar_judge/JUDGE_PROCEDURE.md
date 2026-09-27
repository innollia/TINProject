# 분신 검수관 사용법 (JUDGE_PROCEDURE)

## 스크립트로 판정하기

파이썬: `C:\Users\fixme\AppData\Local\Programs\Python\Python312\python.exe`
모델 호출: `kiro-cli chat --no-interactive`(기본 모델 claude-sonnet-5, 환경변수 `AVATAR_JUDGE_MODEL`로 변경)

```powershell
cd C:\Users\fixme\Desktop\TINProject-avatar-judge\tools\avatar_judge
$P = 'C:\Users\fixme\AppData\Local\Programs\Python\Python312\python.exe'
& $P judge.py --image C:\path\shot.png --desc "07 물리 퍼즐 플랫포머 레벨 캡처"
& $P judge.py --text "새 기획안: 검색창이 곧 세계인 게임"
& $P judge.py --file C:\path\plan.md
```

출력(JSON 한 줄): `{"한줄평": "...", "판정": "통과|퇴짜", "점수": 0~100, "근거규칙": [...]}`
이미지를 못 열면 `"이미지": "못 봄..."`이 붙는다. 그 판정은 믿지 말고 다시 돌린다.

## 대상 설명 쓰는 법

분신은 게임을 직접 플레이하지 못한다. 설명에 보이는 사실을 적는다.
- 무엇인지(Kit 번호와 짧은 이름, 캡처인지 기획인지 선택 질문인지)
- 실제로 되는 것과 안 되는 것(입력이 바로 되나, 마우스만·키보드만 되나)
- 움직임(연속 프레임에서 걸음·끌림·휨이 보이나)
- 레퍼런스에서 무엇을 가져왔나(시스템, 그림체, 세계관)
판정 결론("딱딱하다", "좋다")은 설명에 넣지 않는다.

## 스크립트를 못 쓸 때 에이전트가 따라 하는 절차

1. `taste_profile.md` 전체와 `judgments.jsonl`을 읽는다.
2. 대상이 완성물·기획·작은 선택 질문 중 무엇인지 가른다.
3. 이미지면 직접 연다. 연속 프레임이 있으면 여러 장을 본다.
4. 규칙서를 위에서부터 대 보고 가장 큰 문제 하나를 고른다. 좋은 점은 따로 챙긴다.
5. 점수 기준(70점 이상 통과, 규칙 1·3·5 위반은 최대 40점)으로 점수를 정한다.
6. 형님 말투로 한 줄 평을 쓴다. 짧게, 존댓말 없이, 해당 없는 말버릇 없이.
7. 위 JSON 형식으로 적는다.

## 일치율 다시 재기

```powershell
& $P eval.py --round 6
```
가려 둔 판정 13개를 새로 판정시키고 판정 일치, 이유 일치, 무조건 퇴짜 기준선을 보여 준다. 결과는 `eval_runs\round_6.jsonl`.

## 판정 늘리기

작업자는 캡처를 형님께 올리기 전에 분신을 먼저 돌린다. 통과한 것과 퇴짜 받은 것을 모두 형님께 보여 준다. 분신이 틀렸는지 형님이 봐야 고칠 수 있다.

형님이 새 판정을 내리면 `judgments.jsonl`에 한 줄 더한다. 대상 설명에는 판정 결론을 넣지 않는다.
