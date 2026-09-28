"""형님 판단 근거를 데이터 폴더에서 읽고, 상황에 맞는 것만 골라 Jev state로 만든다.

기본은 게임 개발 결정용이다(게임 개발 AI가 '중요한 결정'이라며 멈췄을 때).
근거(있는 것만 쓴다, 앞일수록 강하다)
  decision/gamedev_decisions.jsonl  게임 개발 AI가 물은 결정과 형님이 실제로 고른 답, 형님이 AI 방향을 바로잡은 기록
  decision/answers.jsonl            형님이 A/B 질문에 직접 한 답
  judgments.jsonl                   형님이 결과물에 내린 판정(원문 인용 포함)
  decision/judgment_model.json      디스코드 판단 사건에서 뽑은 판단 규칙
  raw/memory_index.json             비슷한 과거 판단 사건 요약
answers·규칙·사건은 GAME 분야만 쓴다. 다른 분야까지 쓰려면 load(domains=None).
고르는 법은 낱말 겹침이다. 모델을 부르지 않는다.
"""
import json
import os
import re

from jevlib import data_dir

GAME = ("게임", "그림", "글·이야기", "도구·개발", "만화")
PERSON = ("innollia, called 형님, the director of TINProject (one game whose genre keeps changing). "
          "A game-dev AI stopped at a decision it calls important. Predict what HE would pick from his own "
          "record below, not what is generally best or safest. He answers decisively; he rejects common, "
          "stiff or knockoff results and wants never-seen core verbs, soft springy motion and minimal text.")


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


def load(base=None, domains=GAME):
    base = base or data_dir()
    ok = (lambda d: True) if domains is None else (lambda d: d in domains)
    rules, events = [], []
    path = os.path.join(base, "decision", "judgment_model.json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            for domain, rs in json.load(f).items():
                if ok(domain):
                    rules += [dict(r, domain=domain) for r in rs if isinstance(r, dict) and r.get("condition")]
    path = os.path.join(base, "raw", "memory_index.json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            for domain, es in json.load(f).items():
                if ok(domain):
                    events += [dict(e, domain=domain) for e in es if not str(e.get("eid", "")).startswith("answer-")]
    answers = [a for a in _jsonl(os.path.join(base, "decision", "answers.jsonl"))
               if a.get("answer") and ok(a.get("domain", "기타"))]
    verdicts = [v for v in _jsonl(os.path.join(base, "judgments.jsonl")) if v.get("target")]
    decisions = [d for d in _jsonl(os.path.join(base, "decision", "gamedev_decisions.jsonl"))
                 if d.get("question") and isinstance(d.get("options"), list)]
    return {"base": base, "decisions": decisions, "answers": answers, "verdicts": verdicts,
            "rules": rules, "events": events}


def without(ev, **drop):
    """평가용: 판정할 항목 자신을 근거에서 뺀 사본. 예) without(ev, decisions={"G1234"}, verdicts={"J05"})"""
    out = dict(ev)
    if "decisions" in drop:
        out["decisions"] = [d for d in ev["decisions"] if d.get("id") not in drop["decisions"]]
    if "verdicts" in drop:
        out["verdicts"] = [v for v in ev["verdicts"] if v.get("id") not in drop["verdicts"]]
    return out


def _top(q, items, text, k):
    scored = sorted(((len(q & _tokens(text(x))), i) for i, x in enumerate(items)), key=lambda t: (-t[0], t[1]))
    return [items[i] for s, i in scored[:k] if s > 0]


def _dec_text(d):
    return " ".join([str(d.get("question", "")), str(d.get("context", "")), " ".join(map(str, d.get("options", []))),
                     str(d.get("reason", "")), str(d.get("quote", ""))])


def pick(ev, text, k_dec=8, k_rules=10, k_answers=6, k_events=8, k_verdicts=6):
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
        "decisions": _top(q, ev["decisions"], _dec_text, k_dec),
        "answers": _top(q, ev["answers"],
                        lambda a: " ".join(str(a.get(k, "")) for k in ("question", "answer", "reason", "flip")),
                        k_answers),
        "verdicts": _top(q, ev["verdicts"],
                         lambda v: " ".join(str(v.get(k, "")) for k in ("target", "quote", "reason")), k_verdicts),
        "rules": sorted(ev["rules"], key=rule_score, reverse=True)[:k_rules],
        "events": events,
    }


def state(sel, case):
    """이름 붙인 칸으로 나눈 state. Jev 지시문에서 `칸이름`으로 가리킨다."""
    def decision(d):
        opts = [str(o) for o in d.get("options", [])]
        try:
            chosen = opts[int(d.get("choice"))]
        except (TypeError, ValueError, IndexError):
            chosen = "?"
        s = f"{d.get('question')} options: {' / '.join(opts)} → he chose: {chosen}"
        if d.get("reason"):
            s += f" (why: {d.get('reason')})"
        if d.get("quote"):
            s += f" (his words: \"{d.get('quote')}\")"
        return s

    def answer(a):
        s = f"Q: {a.get('question')} → he answered: {a.get('answer')}"
        if a.get("reason"):
            s += f" (why: {a.get('reason')})"
        if a.get("flip"):
            s += f" (would flip if: {a.get('flip')})"
        return s

    def rule(r):
        s = f"When {r.get('condition')} → {r.get('tendency')}"
        if r.get("exception"):
            s += f"; except {r.get('exception')}"
        if r.get("flip"):
            s += f"; flips if {r.get('flip')}"
        return s

    verdict = {"pass": "approved", "fail": "rejected"}
    return {
        "person": PERSON,
        "his_gamedev_decisions": [decision(d) for d in sel["decisions"]],
        "his_direct_answers": [answer(a) for a in sel["answers"]],
        "his_past_verdicts": [f"{v.get('target')} → {verdict.get(str(v.get('verdict')), v.get('verdict'))}: "
                              f"\"{v.get('quote', '')}\"" for v in sel["verdicts"]],
        "his_rules": [rule(r) for r in sel["rules"]],
        "similar_past_decisions": [f"{e.get('s')} → chose: {e.get('c')}" + (f" (why: {e.get('r')})" if e.get("r") else "")
                                   for e in sel["events"]],
        "case": case,
    }
