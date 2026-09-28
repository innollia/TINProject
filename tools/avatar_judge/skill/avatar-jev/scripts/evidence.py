"""형님 판단 근거를 데이터 폴더에서 읽고, 상황에 맞는 것만 골라 Jev state로 만든다.

근거 네 가지(있는 것만 쓴다)
  decision/answers.jsonl        형님이 A/B 질문에 직접 한 답. 가장 강한 근거
  decision/judgment_model.json  디스코드 판단 사건에서 뽑은 판단 규칙(조건 → 경향 → 예외 → 뒤집힘)
  judgments.jsonl               형님이 결과물에 내린 판정(원문 인용 포함)
  raw/memory_index.json         비슷한 과거 판단 사건 요약
고르는 법은 낱말 겹침이다. 모델을 부르지 않는다.
"""
import json
import os
import re

from jevlib import data_dir

PERSON = ("innollia, called 형님. Predict what HE would choose or say from his own record below, "
          "not what is generally best. He answers decisively and concretely; he almost never takes an "
          "'it depends' or 'both sides have a point' position.")


def _tokens(s):
    return set(re.findall(r"[가-힣A-Za-z0-9]{2,}", s or ""))


def _jsonl(path):
    rows = []
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            for line in f:
                try:
                    rows.append(json.loads(line))
                except ValueError:
                    pass
    return rows


def _num(x, default=1.0):
    try:
        return float(x)
    except (TypeError, ValueError):
        return default


def load(base=None):
    base = base or data_dir()
    rules, events = [], []
    path = os.path.join(base, "decision", "judgment_model.json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            for domain, rs in json.load(f).items():
                rules += [dict(r, domain=domain) for r in rs if isinstance(r, dict) and r.get("condition")]
    path = os.path.join(base, "raw", "memory_index.json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            for domain, es in json.load(f).items():
                events += [dict(e, domain=domain) for e in es if not str(e.get("eid", "")).startswith("answer-")]
    answers = [a for a in _jsonl(os.path.join(base, "decision", "answers.jsonl")) if a.get("answer")]
    verdicts = [v for v in _jsonl(os.path.join(base, "judgments.jsonl")) if v.get("target")]
    return {"base": base, "rules": rules, "events": events, "answers": answers, "verdicts": verdicts}


def _top(q, items, text, k):
    scored = sorted(((len(q & _tokens(text(x))), i) for i, x in enumerate(items)), key=lambda t: (-t[0], t[1]))
    return [items[i] for s, i in scored[:k] if s > 0]


def pick(ev, text, k_rules=12, k_answers=6, k_events=12, k_verdicts=5):
    """상황 글(text)과 낱말이 겹치는 근거만 고른다. 규칙은 비슷한 사건의 근거로 쓰인 것에 가산점을 준다."""
    q = _tokens(text)
    events = _top(q, ev["events"], lambda e: f"{e.get('s', '')} {e.get('c', '')}", k_events)
    hit = {str(e.get("eid")) for e in events}

    def rule_score(r):
        ids = r.get("evidence") or []
        ids = ids if isinstance(ids, list) else [ids]
        words = _tokens(" ".join(str(r.get(k, "")) for k in ("condition", "tendency", "exception", "flip")))
        return len(q & words) + 2 * len(hit & set(map(str, ids))) + _num(r.get("strength")) / 3

    return {
        "rules": sorted(ev["rules"], key=rule_score, reverse=True)[:k_rules],
        "answers": _top(q, ev["answers"],
                        lambda a: " ".join(str(a.get(k, "")) for k in ("question", "answer", "reason", "flip")),
                        k_answers),
        "events": events,
        "verdicts": _top(q, ev["verdicts"],
                         lambda v: " ".join(str(v.get(k, "")) for k in ("target", "quote", "reason")), k_verdicts),
    }


def state(sel, case):
    """이름 붙인 칸으로 나눈 state. Jev 지시문에서 `칸이름`으로 가리킨다."""
    def rule(r):
        s = f"When {r.get('condition')} → {r.get('tendency')}"
        if r.get("exception"):
            s += f"; except {r.get('exception')}"
        if r.get("flip"):
            s += f"; flips if {r.get('flip')}"
        return s

    def answer(a):
        s = f"Q: {a.get('question')} → he answered: {a.get('answer')}"
        if a.get("reason"):
            s += f" (why: {a.get('reason')})"
        if a.get("flip"):
            s += f" (would flip if: {a.get('flip')})"
        return s

    verdict = {"pass": "approved", "fail": "rejected"}
    return {
        "person": PERSON,
        "his_direct_answers": [answer(a) for a in sel["answers"]],
        "his_rules": [rule(r) for r in sel["rules"]],
        "his_past_verdicts": [f"{v.get('target')} → {verdict.get(str(v.get('verdict')), v.get('verdict'))}: "
                              f"\"{v.get('quote', '')}\"" for v in sel["verdicts"]],
        "similar_past_decisions": [f"{e.get('s')} → chose: {e.get('c')}" + (f" (why: {e.get('r')})" if e.get("r") else "")
                                   for e in sel["events"]],
        "case": case,
    }
