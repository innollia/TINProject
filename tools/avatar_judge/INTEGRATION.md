# TIN 작업자 지침 연결 제안

분신이 실제로 쓰이려면 게임 개발 AI가 '중요한 결정'에서 멈추기 전에 분신을 돌려야 한다. 그 순서는 `AGENTS.md`의 "중요한 결정은 사용자에게 묻는다" 절이 정한다. `AGENTS.md`는 여러 작업 세션이 같이 쓰는 공용 문서라 이 작업(분신 검수관)에서는 고치지 않았다. 형님이 허락하면 아래 문단을 그 절 끝에 넣는다.

```markdown
- 질문을 올리기 전에 `avatar-jev` 스킬을 돌린다(설치 위치: Codex `~/.agents/skills/avatar-jev`, Kiro `~/.kiro/crew/skills/avatar-jev`, 원본 `tools/avatar_judge/skill/avatar-jev` 브랜치 feat/avatar-judge). 선택지는 쓴 그대로 넣고 추천 번호는 `recommended`로 따로 준다.
  - 결과 `gate`가 `accept`면 묻지 않고 분신이 고른 것으로 진행한다. 보고에 "분신 판정으로 진행: <선택> (확신 0.xx)" 한 줄을 남긴다.
  - `weak`·`ask`면 분신이 고른 것으로 진행하고, 질문은 '이미 이렇게 진행함'을 밝혀 형님께 올린다. 분신이 고른 것과 AI 원래 추천을 함께 적는다.
  - Kit 범위(scope) 결정은 분신이 확신해도 확인 질문으로 올린다.
  - 형님이 답하면 `record.py`로 기록한다.
  - 분신이 오류를 내면 지금 규칙대로 추천안으로 진행하고 형님께 묻는다.
```

근거: TIN 문서의 게임 개발 결정 150건에서 분신 83%, AI 추천대로 56%(추천이 기록된 54건), 분신이 확신한 101건은 93% (`skill/avatar-jev/references/method.md`).
