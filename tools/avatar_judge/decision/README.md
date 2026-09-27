# 분신 v2: 판단기 (decision/)

v1(`../taste_profile.md`)은 "형님이 어떤 사람인가"를 설명하는 규칙서였다. v2는 형님이 없을 때 대신 고르는 판단기다.

## 흐름

디스코드 원문 → 판단 사건 추출 → 판단 규칙(조건·경향·예외·뒤집힘) → 상황별로 기억 찾기 → 선택 예측 → 확신이 낮으면 A/B 질문 → 답으로 규칙 갱신

| 단계 | 파일 | 하는 일 |
|---|---|---|
| 1 | `prep.py` | 디스코드 로그를 채널·날짜 묶음으로 자른다. 묶음의 20%는 시험지(gold)로 먼저 봉인한다 |
| 2 | `extract.py` | 묶음마다 판단 사건을 뽑는다(상황, 충돌, 선택지, 고른 것, 이유, 나중의 뒤집힘, 남의 해석을 바로잡았는지) |
| 3 | `build_model.py` | 기억용 사건과 형님 직접 답(`answers.jsonl`)으로 분야별 판단 규칙을 만든다. 부딪히는 규칙은 둘 다 남긴다. 근거 사건 id를 단다 |
| 4 | `decide.py` | 판단 엔진. 상황을 넣으면 선택, 근거, 확신도, 반대로 고를 조건을 JSON으로 낸다. 말투 없음 |
| 5 | `voice.py` | 말투 층. 판단 결과를 형님 말투 한 줄로만 바꾼다 |
| 6 | `ask.py` | 분신이 부딪히는 규칙과 약한 규칙을 보고 A/B 질문을 만든다. 형님 답은 `--record`로 기록한다 |
| 7 | `eval_gold.py` | 시험지 채점. 당시 상황만 주고 실제 선택을 맞히게 한다. 선택·이유·확신도·뒤집힘 조건 4가지를 본다 |

## 기억의 세 층

1. 판단 규칙(`judgment_model.json`): 가장 요약된 층
2. 분야별 사건 목록(`raw/memory_index.json`): 중간 층
3. 원문 묶음(`raw/chunks/train/`): 세부 층, 필요할 때만

## 지키는 것

- 시험지 묶음은 규칙을 만들 때 읽지 않는다. `build_model.py`는 `raw/events/train`만 읽는다.
- 말투·유행어는 판단 근거가 아니다. 판단 엔진과 말투 층을 나눴다.
- 원문·사건·시험지 결과는 개인 대화라 `raw/`에만 두고 저장소에 올리지 않는다.

## 실행

```powershell
cd C:\Users\fixme\Desktop\TINProject-avatar-judge\tools\avatar_judge\decision
$P = 'C:\Users\fixme\AppData\Local\Programs\Python\Python312\python.exe'
& $P -X utf8 prep.py
& $P -X utf8 extract.py --split train
& $P -X utf8 extract.py --split gold
& $P -X utf8 build_model.py
& $P -X utf8 eval_gold.py --name v1
& $P -X utf8 ask.py --n 10
& $P -X utf8 ask.py --record 3 A "이유 한 줄" --flip "무엇이 바뀌면 반대"
```
