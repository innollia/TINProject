"""형님이 결과물에 내린 판정(judgments.jsonl)으로 Jev 통과/퇴짜 판정을 잰다. 모델(LLM) 호출은 없다.

  python eval_verdicts.py   → raw/gold_runs/verdicts_jev.txt
판정할 항목 자신은 근거(his_past_verdicts)에서 뺀다. J33 이후는 형님 A/B 답(answers.jsonl)과 겹쳐서 제외한다.
"""
import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor

from eval_gold import RUNS, SKILL_SCRIPTS

sys.path.insert(0, SKILL_SCRIPTS)
import choose  # noqa: E402
import evidence  # noqa: E402
import jevlib  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def pct(a, b):
    return f"{a}/{b} ({a / b:.0%})" if b else "0/0"


def one(args):
    j, ev = args
    ev = dict(ev, verdicts=[v for v in ev["verdicts"] if v.get("id") != j["id"]])
    case = j["target"]
    sel = evidence.pick(ev, case)
    qs = {"verdict": {"type": "noul", "instructions": "Would innollia approve the work described in `case`?",
                      "criteria": {"true": "he approves it", "false": "he rejects it"}},
          "score": {"type": "score", "instructions": "Where does the work in `case` sit on innollia's scale?",
                    "criteria": choose.LEVELS}}
    try:
        ans, _ = jevlib.ask(evidence.state(sel, case), qs)
    except jevlib.JevError as e:
        return j, None, None, str(e)
    p = float((ans.get("verdict") or {}).get("noul", 0.0))
    s = ans.get("score") or {}
    pts = round(float(s["score"]) / (len(choose.LEVELS) - 1) * 100) if "score" in s else None
    return j, p, pts, ""


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ev = evidence.load()
    items = [v for v in ev["verdicts"] if v.get("verdict") in ("pass", "fail")
             and str(v.get("id", "J99"))[1:].isdigit() and int(str(v["id"])[1:]) <= 32]
    with ThreadPoolExecutor(6) as ex:
        res = list(ex.map(one, [(j, ev) for j in items]))
    ok = [(j, p, s) for j, p, s, err in res if p is not None]
    n = len(ok)
    hit = sum((p >= 0.5) == (j["verdict"] == "pass") for j, p, s in ok)
    passes = [(j, p, s) for j, p, s in ok if j["verdict"] == "pass"]
    fails = [(j, p, s) for j, p, s in ok if j["verdict"] == "fail"]
    by_score = sum(((s or 0) >= 70) == (j["verdict"] == "pass") for j, p, s in ok)
    conf = [(max(p, 1 - p), (p >= 0.5) == (j["verdict"] == "pass")) for j, p, s in ok]
    hi = [c for x, c in conf if x >= 0.7]
    lo = [c for x, c in conf if x < 0.7]
    lines = [
        f"판정 {n}건(통과 {len(passes)}, 퇴짜 {len(fails)}), Jev 오류 {len(res) - n}건",
        f"통과 확률 0.5 기준 일치: {pct(hit, n)} (전부 퇴짜라고 하면 {pct(len(fails), n)})",
        f"점수 70 기준 일치: {pct(by_score, n)}",
        f"통과 맞힘: {pct(sum(p >= 0.5 for j, p, s in passes), len(passes))}, "
        f"퇴짜 맞힘: {pct(sum(p < 0.5 for j, p, s in fails), len(fails))}",
        f"확신 높음(0.7 이상) 일치: {pct(sum(hi), len(hi))}, 낮음: {pct(sum(lo), len(lo))}",
    ]
    lines += [f"  {j['id']} 실제 {j['verdict']} → 통과확률 {p:.2f} 점수 {s}" for j, p, s in ok]
    out = os.path.join(RUNS, "verdicts_jev.txt")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("\n".join(lines[:5]))


if __name__ == "__main__":
    main()
