"""분신이 자기 약한 곳을 보고 형님께 A/B 질문을 만든다. 게임 개발 결정만 묻는다(일상 질문은 안 만든다).

  python ask.py --n 10              # 질문 만들기 → questions.md
  python ask.py --record 3 A "이유" # 형님 답 기록 → answers.jsonl (다음 판정부터 가장 강한 근거)

만드는 법
  1. 게임 분야(게임·그림·글·이야기·도구·개발·만화) 규칙 중 서로 부딪히는 쌍과 약한 규칙을 고른다.
  2. 게임 개발 AI가 TIN 작업 중 멈추고 물을 법한 결정으로 바꾼다(창작 방향, 생물 생김새·움직임, 세계관, 화면·조작, Kit 범위, 레퍼런스 해석, 그림 제작 방식).
  3. 이미 기록된 게임 개발 결정(gamedev_decisions.jsonl)과 형님 답은 다시 묻지 않는다.
  4. 질문마다 경계를 찌르는 후속 질문을 하나 붙인다("무엇이 바뀌면 반대로 고름?").
"""
import argparse
import json
import os
import sys

from decide import load_model
from extract import best_list, call

HERE = os.path.dirname(os.path.abspath(__file__))
QPATH = os.path.join(HERE, "questions.json")
GAME = ("게임", "그림", "글·이야기", "도구·개발", "만화")

PROMPT = """너는 innollia(형님)의 판단 모델에서 가장 불확실한 곳을 찾아 질문을 만든다.
쓰임: TINProject(한 게임 안에서 장르가 바뀌는 게임)를 만드는 게임 개발 AI가 작업하다 '중요한 결정'이라며 멈출 때, 분신이 형님 대신 고른다. 그래서 질문도 그런 결정이어야 한다.
- 게임 개발 결정만 만든다: 창작 방향, 생물·인물 생김새와 움직임, 세계관·스토리, 화면 구성·조작, Kit 범위, 레퍼런스에서 무엇을 따르고 바꿀지, 그림·에셋 제작 방식. 일상·인간관계 질문은 만들지 않는다.
- 아래 [부딪히는 규칙]과 [약한 규칙]에서 두 가설이 서로 다른 답을 내놓는 구체적 상황을 {n}개 만든다.
- 질문은 쉬운 한국어 한두 문장. 어느 Kit·작업에서 무엇을 정하는지 적는다. 형님이 3초 안에 A/B로 답할 수 있게.
- A와 B는 실제로 갈등하는 두 선택이고, 각각 화면·플레이가 어떻게 달라지는지 짧게 적는다. 답이 뻔한 질문은 버린다.
- [이미 받은 답]과 겹치는 질문은 만들지 않는다.
- follow_up: 답을 받은 뒤 경계를 찌를 한 줄 질문.
- hypotheses: 이 질문이 가르는 두 가설(규칙 id 포함).
파일을 만들거나 도구를 쓰지 말고, 답 본문에 JSON 배열만 출력한다.
[{{"question": "...", "A": "...", "B": "...", "follow_up": "...", "hypotheses": ["...", "..."], "domain": "..."}}]

[부딪히는 규칙]
{conflicts}

[약한 규칙]
{weak}

[이미 받은 답]
{answered}
"""


def rule_line(r):
    return f"{r.get('id')}: {r.get('condition')} → {r.get('tendency')} (뒤집힘: {r.get('flip')})"


def _jsonl(path):
    if not os.path.exists(path):
        return []
    with open(path, encoding="utf-8") as f:
        return [json.loads(l) for l in f if l.strip()]


def make(n):
    model = {d: rs for d, rs in load_model().items() if d in GAME}
    all_rules = {str(r.get("id")): r for rs in model.values() for r in rs}
    conflicts, weak = [], []
    for r in all_rules.values():
        for c in r["conflicts_with"]:
            if str(c) in all_rules:
                conflicts.append(rule_line(r) + "  ⟷  " + rule_line(all_rules[str(c)]))
        if r["strength"] <= 1:
            weak.append(rule_line(r))
    conflicts = list(dict.fromkeys(conflicts))
    answered = [a["question"] for a in _jsonl(os.path.join(HERE, "answers.jsonl")) if a.get("domain") in GAME]
    answered += [d["question"] for d in _jsonl(os.path.join(HERE, "gamedev_decisions.jsonl"))]
    qs = []
    for _ in range(3):
        raw = call(PROMPT.format(n=n, conflicts="\n".join(conflicts[:60]) or "(없음)",
                                 weak="\n".join(weak[:60]) or "(없음)", answered="\n".join(answered[-120:]) or "(없음)"))
        qs = [q for q in best_list(raw, "question") if q.get("A") and q.get("B")]
        if qs:
            break
    json.dump(qs, open(QPATH, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    out = ["# 분신이 여쭙는 것 (게임 개발 결정)", "",
           "번호 + A/B/상황에 따라 로 답해 주시면 됩니다. 이유는 한 줄이면 충분합니다.", ""]
    for i, q in enumerate(qs, 1):
        out += [f"{i}. {q['question']}", f"   - A: {q['A']}", f"   - B: {q['B']}",
                f"   - 답하시면 이어서: {q.get('follow_up', '')}", ""]
    open(os.path.join(HERE, "questions.md"), "w", encoding="utf-8").write("\n".join(out))
    print(f"질문 {len(qs)}개 → questions.md")


def record(num, answer, reason, flip):
    q = json.load(open(QPATH, encoding="utf-8"))[num - 1]
    pick = {"A": q["A"], "B": q["B"]}.get(answer.upper(), answer)
    row = {"question": q["question"], "options": [q["A"], q["B"]], "answer": pick,
           "reason": reason, "flip": flip, "domain": q.get("domain", "게임"), "hypotheses": q.get("hypotheses")}
    with open(os.path.join(HERE, "answers.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(row, ensure_ascii=False) + "\n")
    print("기록:", row["question"], "→", pick)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=10)
    ap.add_argument("--record", nargs="+", metavar=("번호", "답"))
    ap.add_argument("--flip", default="")
    ap.add_argument("--invent", action="store_true", help="(쓰지 않음) 규칙 충돌에서 가상 질문 만들기")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    if a.record:
        record(int(a.record[0]), a.record[1], " ".join(a.record[2:]), a.flip)
    elif a.invent:
        make(a.n)
    else:
        print("질문 지어내기는 쓰지 않는다: 맥락이 잘려 답이 쓸모없다(2026-09-28 형님). "
              "질문은 실제로 멈춘 결정에서 분신 확신이 낮을 때만 올린다. skill/avatar-jev/SKILL.md '계속 보완하는 법'.")


if __name__ == "__main__":
    main()
