"""게임 개발 AI가 '중요한 결정'이라며 멈췄을 때, 그 선택지 중 형님이 고를 것을 Jev가 고른다.

  python choose.py case.json     → case.result.json을 쓰고, 화면에는 영어 한 줄 요약
입력  {"case": "무엇을 정하는지 + 어느 Kit·작업 중인지 + 화면·플레이가 어떻게 달라지는지",
       "mode": "choice"|"verdict",
       "candidates": ["선택지", ...] 또는 [{"answer": "선택지 또는 형님 말투 한 줄 평", "reason": "왜"}, ...],
       "recommended": 멈춘 AI가 추천한 선택지 번호(0부터, 없으면 생략)}
출력  pick(0부터 번호), answer, reason, confidence, stable, gate(accept|weak|ask), probabilities,
      agrees_with_recommendation, applied_rules, flip_if, ask(gate가 ask일 때 형님께 물을 것),
      evidence(gate가 accept가 아닐 때 에이전트가 읽을 형님 기록), verdict(mode가 verdict일 때)
Jev는 두 번 부른다. 두 번째는 후보 순서를 뒤집어 같은 답이 나오는지 본다. 멈춘 AI의 추천은 Jev에게 보여 주지 않는다.
"""
import json
import os
import re
import sys

import evidence
import jevlib

HEDGE = re.compile(r"따라 (갈|달라|다르)|에 따라|경우에 따라|상황에 따라|갈린다|케이스 ?바이|depends", re.I)
ACCEPT = float(os.environ.get("AVATAR_ACCEPT", 0.7))
ASK = float(os.environ.get("AVATAR_ASK", 0.5))
FIT = 8
PICK = ("Which option would innollia himself pick for `case`? Weigh `his_gamedev_decisions` most, then "
        "`his_direct_answers`, `his_past_verdicts`, `his_rules` and `similar_past_decisions`.")
LEVELS = [
    "clear reject: common, stiff, a knockoff of a reference, or mass-produced",
    "leaning reject: only one or two parts are good",
    "borderline: neither a pass nor a reject",
    "leaning pass: the core is new but needs polish",
    "clear pass: a never-seen core verb or structure, soft and springy motion",
]


def _cands(inp):
    raw = inp.get("candidates") or inp.get("options") or []
    out = []
    for c in raw:
        if isinstance(c, dict) and str(c.get("answer", "")).strip():
            out.append({"answer": str(c["answer"]).strip(), "reason": str(c.get("reason", "")).strip()})
        elif isinstance(c, str) and c.strip():
            out.append({"answer": c.strip(), "reason": ""})
    return out


def run(inp, ev=None):
    case = str(inp.get("case", "")).strip()
    cands = _cands(inp)
    if not case or not 2 <= len(cands) <= 12:
        raise ValueError("need a case and 2-12 candidates")
    labels = [chr(65 + i) for i in range(len(cands))]
    crit = {lb: c["answer"] + (f" — {c['reason']}" if c["reason"] else "") for lb, c in zip(labels, cands)}
    ev = ev or evidence.load()
    sel = evidence.pick(ev, case + " " + " ".join(crit.values()))
    st = evidence.state(sel, case)
    rules = sel["rules"][:FIT]
    qs = {"pick": {"type": "choice", "instructions": PICK, "criteria": crit}}
    for i, r in enumerate(rules):
        qs[f"fit{i}"] = {"type": "noul", "instructions": "Does this rule of his apply to `case`? Rule: "
                                                          f"When {r.get('condition')} → {r.get('tendency')}"}
    verdict = inp.get("mode") == "verdict"
    if verdict:
        qs["verdict"] = {"type": "noul", "instructions": "Would innollia approve the work described in `case`?",
                         "criteria": {"true": "he approves it", "false": "he rejects it"}}
        qs["score"] = {"type": "score", "instructions": "Where does the work in `case` sit on innollia's scale?",
                       "criteria": LEVELS}
    ans, model = jevlib.ask(st, qs)
    back, _ = jevlib.ask(st, {"pick": {"type": "choice", "instructions": PICK,
                                       "criteria": dict(reversed(list(crit.items())))}})
    p1, p2 = ans.get("pick") or {}, back.get("pick") or {}
    pr1, pr2 = p1.get("probabilities") or {}, p2.get("probabilities") or {}
    probs = {lb: round((float(pr1.get(lb, 0)) + float(pr2.get(lb, 0))) / 2, 3) for lb in labels}
    best = p1.get("choice") if p1.get("choice") in crit else max(probs, key=probs.get)
    stable = p1.get("choice") == p2.get("choice")
    conf = float(p1.get("confidence", 0.0))
    gate = "ask" if (not stable or conf < ASK) else ("weak" if conf < ACCEPT else "accept")
    fits = sorted(((float((ans.get(f"fit{i}") or {}).get("noul", 0.0)), r) for i, r in enumerate(rules)),
                  key=lambda t: -t[0])
    applied = [r for p, r in fits if p >= 0.5][:3]
    top2 = sorted(labels, key=lambda lb: -probs[lb])[:2]
    i = labels.index(best)
    rec = inp.get("recommended")
    rec = int(rec) if isinstance(rec, (int, float)) and 0 <= int(rec) < len(cands) else None
    res = {
        "pick": i, "label": best, "answer": cands[i]["answer"], "reason": cands[i]["reason"],
        "confidence": round(conf, 3), "stable": stable, "gate": gate, "probabilities": probs,
        "recommended": rec, "agrees_with_recommendation": None if rec is None else rec == i,
        "candidates": crit,
        "applied_rules": [f"{r.get('condition')} → {r.get('tendency')}" for r in applied],
        "flip_if": [r.get("flip") for r in applied if r.get("flip")],
        "ask": ({"question": case, "A": crit[top2[0]], "B": crit[top2[1]],
                 "follow_up": "무엇이 바뀌면 반대로 고르시나요?"} if gate == "ask" else None),
        "hedge_candidates": [lb for lb in labels if HEDGE.search(crit[lb])],
        "model": model,
        "evidence_used": {k: len(v) for k, v in sel.items()},
    }
    if verdict:
        v, s = ans.get("verdict") or {}, ans.get("score") or {}
        res["verdict"] = {"pass_prob": round(float(v.get("noul", 0.0)), 3),
                          "score": round(float(s["score"]) / (len(LEVELS) - 1) * 100) if "score" in s else None,
                          "score_confidence": s.get("confidence")}
    if gate != "accept":  # 에이전트가 형님 기록을 읽고 직접 판단할 재료
        res["evidence"] = {k: st[k] for k in ("his_gamedev_decisions", "his_direct_answers", "his_past_verdicts",
                                              "his_rules", "similar_past_decisions")}
    return res


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    if len(sys.argv) < 2:
        print("usage: python choose.py case.json")
        sys.exit(2)
    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        inp = json.load(f)
    out = os.path.splitext(path)[0] + ".result.json"
    try:
        res = run(inp)
        line = f"pick={res['pick']} conf={res['confidence']} stable={res['stable']} gate={res['gate']}"
        if res["recommended"] is not None:
            line += f" agrees_with_recommendation={res['agrees_with_recommendation']}"
        if res.get("verdict"):
            line += f" pass_prob={res['verdict']['pass_prob']} score={res['verdict']['score']}"
    except (jevlib.JevError, ValueError) as e:
        res, line = {"error": str(e)}, f"error: {e}"
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, ensure_ascii=False, indent=1)
    print(line + " -> " + out)


if __name__ == "__main__":
    main()
