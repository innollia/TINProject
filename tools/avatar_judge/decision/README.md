# 분신 v2: 판단기 (decision/)

v1(`../taste_profile.md`)은 "형님이 어떤 사람인가"를 설명하는 규칙서였다. v2는 형님이 없을 때 대신 고르는 판단기다.

## 흐름

디스코드 원문 → 판단 사건 추출 → 판단 규칙(조건·경향·예외·뒤집힘) → 상황별로 기억 찾기 → 선택 예측 → 확신이 낮으면 A/B 질문 → 답으로 규칙 갱신

| 단계 | 파일 | 하는 일 |
|---|---|---|
| 1 | `prep.py` | 디스코드 로그를 채널·날짜 묶음으로 자른다. 묶음의 20%는 시험지(gold)로 먼저 봉인한다 |
| 2 | `extract.py` | 묶음마다 판단 사건을 뽑는다(상황, 충돌, 선택지, 고른 것, 이유, 나중의 뒤집힘, 남의 해석을 바로잡았는지) |
| 3 | `build_model.py` | 기억용 사건과 형님 직접 답(`answers.jsonl`)으로 분야별 판단 규칙을 만든다. 부딪히는 규칙은 둘 다 남기고 근거 사건 id를 단다. `--domains 그림`처럼 한 분야만 다시 만들 수 있다 |
| 4 | `decide.py` | 판단 엔진. 상황을 넣으면 선택, 근거, 확신도, 반대로 고를 조건을 JSON으로 낸다. 말투 없음. `--verdict`는 결과물 통과/퇴짜 판정 |
| - | `jev.py` | Jev(TypeSafe System One) 어댑터. 아래 'Jev' 절 참고 |
| 5 | `voice.py` | 말투 층. 판단 결과를 형님 말투 한 줄로만 바꾼다 |
| 6 | `ask.py` | 분신이 부딪히는 규칙과 약한 규칙을 보고 A/B 질문을 만든다. 형님 답은 `--record`로 기록한다 |
| 7 | `eval_gold.py` | 시험지 채점. 당시 상황만 주고 실제 선택을 맞히게 한다. 선택·이유·확신도·뒤집힘 조건 4가지를 본다 |
| - | `compare_runs.py` | 채점 두 번을 같은 사건끼리 비교한다(숫자만 낸다) |
| - | `_bg.py`, `_pipeline.py` | 오래 걸리는 작업을 뒤에서 돌린다. 로그는 `raw/<태그>.log`·`.err`, 끝나면 `raw/<태그>.done`에 종료 코드 |
| - | `stop_bg.py` | `_bg.py`로 띄운 작업만 골라 프로세스 트리째 끈다(kiro-cli 모델 호출 포함). 결과는 `raw/_stop.txt` |
| - | `test_offline.py` | 모델·네트워크 없이 판단 엔진과 Jev 경로를 시험한다 |

## 기억의 세 층

1. 판단 규칙(`judgment_model.json`): 가장 요약된 층
2. 분야별 사건 목록(`raw/memory_index.json`): 중간 층
3. 원문 묶음(`raw/chunks/train/`): 세부 층, 필요할 때만

## 지키는 것

- 시험지 묶음은 규칙을 만들 때 읽지 않는다. `build_model.py`는 `raw/events/train`만 읽는다.
- 말투·유행어는 판단 근거가 아니다. 판단 엔진과 말투 층을 나눴다.
- 원문·사건·시험지 결과는 개인 대화라 `raw/`에만 두고 저장소에 올리지 않는다.
- 모델은 `raw/model_strays`에서 돌린다. 모델이 답 대신 파일을 만들어도 저장소에 섞이지 않는다.

## 실행

```powershell
cd C:\Users\fixme\Desktop\TINProject-avatar-judge\tools\avatar_judge\decision
$P = 'C:\Users\fixme\AppData\Local\Programs\Python\Python312\python.exe'
& $P -X utf8 prep.py
& $P -X utf8 extract.py --split train
& $P -X utf8 extract.py --split gold
& $P -X utf8 build_model.py
& $P -X utf8 build_model.py --domains 그림
& $P -X utf8 eval_gold.py --name v2-llm
& $P -X utf8 compare_runs.py v1 v2-llm
& $P -X utf8 ask.py --n 10
& $P -X utf8 ask.py --record 3 A "이유 한 줄" --flip "무엇이 바뀌면 반대"
& $P -X utf8 test_offline.py
& $P _bg.py _pipeline.py pipe    # 그림 규칙 → 질문 → 채점 → 비교를 뒤에서 차례로
```

## Jev(System One)

Jev는 글을 만들지 않는다. state(판단 근거와 상황을 담은 글)와 타입 질문을 받아 확률만 낸다.

- noul: 예일 확률(0~1)
- choice: 정해 준 선택지 중 하나, 선택지별 확률, 확신도
- score: 순서 있는 단계(2~10개) 위의 위치, 확신도

분신에서 Jev가 맡는 곳
- 선택지가 2개 이상인 판단(`decide.py --options`, 시험지 채점): choice로 고른다.
- 결과물 판정(`judge.py`, `decide.py --verdict`): noul로 통과 확률을 받고, score 5단계를 0~100점으로 편다.
- 같은 호출에서 후보 규칙 8개마다 '이 상황에 들어맞나'(noul)를 묻는다. 들어맞는 규칙 문장으로 근거와 뒤집힘 조건을 채운다. Jev는 글을 못 쓰므로 근거는 규칙 문장 그대로다.
- 선택지 없는 자유 선택, 한 줄 평(말투), 이미지 묘사는 LLM이 맡는다.
- Jev가 없거나 키가 거절되면 LLM이 같은 모양으로 답한다. 결과의 `_engine`(judge.py는 `엔진`)에 누가 답했는지 남는다.

키
- 자리: `raw/jev_key.txt`(git에 안 올라감). 환경변수 `TYPESAFE_API_KEY`가 있으면 그게 먼저다. 새 키를 받으면 이 파일 내용만 바꾸면 된다.
- 확인: `& $P -X utf8 jev.py` → `키 됨: jev-latest, ...` 또는 `키 안 됨: HTTP 401 ...`. 모델 목록만 묻기 때문에 판정할 내용은 보내지 않는다.
- 중개 서비스(OpenRouter, Vercel 등) 키면 `$env:JEV_BASE_URL`로 주소를, `$env:JEV_MODEL`로 모델 이름을 바꾼다. 기본은 `https://api.typesafe.ai`, `jev-latest`.
- `$env:JEV_DISABLE = '1'`이면 키가 있어도 LLM만 쓴다(LLM과 Jev를 같은 시험지로 비교할 때).

형식 근거는 [TypeSafe API 문서](https://docs.typesafe.ai/api)다. 입력 100만 토큰당 $0.042이고 출력은 무료다. 문서에 따르면 영어가 가장 정확하고 다른 언어는 조금 떨어진다. 분신의 규칙과 사건은 한국어라 이 점을 채점으로 확인해야 한다.
