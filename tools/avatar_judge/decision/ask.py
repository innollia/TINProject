"""분신이 자기 약한 곳을 보고 형님께 A/B 질문을 만든다.

  python ask.py --n 10              # 질문 만들기 → questions.md
  python ask.py --record 3 A "이유" # 형님 답 기록 → answers.jsonl (다음 build_model.py 때 가장 강한 근거)

만드는 법
  1. judgment_model.json에서 서로 부딪히는 규칙 쌍, 약한 규칙(강도 1), 사건이 적은 분야를 고른다.
  2. 두 가설이 서로 다른 답을 내는 구체적 상황을 만든다(A / B / 상황에 따라).
  3. 답이 한쪽으로 쏠릴 것 같은 질문은 버린다(정보가 적음).
  4. 질문마다 경계를 찌르는 후속 질문을 하나 붙인다("무엇이 바뀌면 반대로 고름?").
"""
import argparse
import json
import os
import re
import sys

from extract import call

HERE = os.path.dirname(os.path.abspath(__file__))
QPATH = os.path.join(HERE, "questions.json")

PROMPT = """너는 innollia(형님)의 판단 모델에서 가장 불확실한 곳을 찾아 질문을 만든다.
아래 [부딪히는 규칙]과 [약한 규칙]을 보고, 두 가설이 서로 다른 답을 내놓는 구체적 상황을 {n}개 만든다.
- 질문은 쉬운 한국어 한두 문장. 형님이 3초 안에 A/B로 답할 수 있게.
- A와 B는 실제로 갈등하는 두 선택이어야 한다. 답이 뻔한 질문은 버린다.
- 이미 형님이 직접 답한 내용([이미 받은 답])은 다시 묻지 않는다.
- follow_up: 답을 받은 뒤 경계를 찌를 한 줄 질문(예: "완성 가능성이 30%라면?").
- hypotheses: 이 질문이 가르는 두 가설(규칙 id 포함).
출력은 JSON 배열 하나만:
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


def make(n):
    model = json.load(open(os.path.join(HERE, "judgment_model.json"), encoding="utf-8"))
    all_rules = {str(r.get("id")): r for rs in model.values() for r in rs}
    conflicts, weak = [], []
    for r in all_rules.values():
        for c in r.get("conflicts_with", []) or []:
            if str(c) in all_rules:
                conflicts.append(rule_line(r) + "  ⟷  " + rule_line(all_rules[str(c)]))
        if r.get("strength", 1) <= 1:
            weak.append(rule_line(r))
    ans_path = os.path.join(HERE, "answers.jsonl")
    answered = [json.loads(l)["question"] for l in open(ans_path, encoding="utf-8")] if os.path.exists(ans_path) else []
    raw = call(PROMPT.format(n=n, conflicts="\n".join(conflicts[:60]) or "(없음)",
                             weak="\n".join(weak[:60]) or "(없음)", answered="\n".join(answered) or "(없음)"))
    s, e = raw.find("["), raw.rfind("]")
    qs = []
    while s != -1 and e > s:
        try:
            qs = json.loads(raw[s:e + 1])
            break
        except ValueError:
            s = raw.find("[", s + 1)
    json.dump(qs, open(QPATH, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    out = ["# 분신이 여쭙는 것", "", "번호 + A/B/상황에 따라 로 답해 주시면 됩니다. 이유는 한 줄이면 충분합니다.", ""]
    for i, q in enumerate(qs, 1):
        out += [f"{i}. {q['question']}", f"   - A: {q['A']}", f"   - B: {q['B']}",
                f"   - 답하시면 이어서: {q['follow_up']}", ""]
    open(os.path.join(HERE, "questions.md"), "w", encoding="utf-8").write("\n".join(out))
    print("\n".join(out))


def record(num, answer, reason, flip):
    q = json.load(open(QPATH, encoding="utf-8"))[num - 1]
    pick = {"A": q["A"], "B": q["B"]}.get(answer.upper(), answer)
    row = {"question": q["question"], "options": [q["A"], q["B"]], "answer": pick,
           "reason": reason, "flip": flip, "domain": q.get("domain", "기타"), "hypotheses": q.get("hypotheses")}
    with open(os.path.join(HERE, "answers.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(row, ensure_ascii=False) + "\n")
    print("기록:", row["question"], "→", pick)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=10)
    ap.add_argument("--record", nargs="+", metavar=("번호", "답"))
    ap.add_argument("--flip", default="")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    if a.record:
        record(int(a.record[0]), a.record[1], " ".join(a.record[2:]), a.flip)
    else:
        make(a.n)


if __name__ == "__main__":
    main()
