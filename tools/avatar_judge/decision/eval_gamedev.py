"""게임 개발 AI가 물은 결정(harvest_decisions.py로 모음)으로 분신을 잰다. 모델(LLM) 호출은 없다.

  python eval_gamedev.py [--name gd1]   → raw/gold_runs/<name>.jsonl, raw/gold_runs/<name>.txt
결정마다 그 결정 자신과, 낱말이 많이 겹치는 기록(같은 결정이 다른 문서·판정에 적힌 것)은 근거에서 뺀다.
비교: 멈춘 AI의 추천을 그대로 따랐을 때(형님이 답 안 하면 추천대로 가는 지금 규칙) vs 분신(Jev).
"""
import argparse
import json
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor

from eval_gold import RUNS, SKILL_SCRIPTS

sys.path.insert(0, SKILL_SCRIPTS)
import choose  # noqa: E402
import evidence  # noqa: E402
import jevlib  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
NEAR = 0.35


def tok(s):
    return set(re.findall(r"[가-힣A-Za-z0-9]{2,}", s or ""))


def jac(a, b):
    return len(a & b) / max(1, len(a | b))


def pct(a, b):
    return f"{a}/{b} ({a / b:.0%})" if b else "0/0"


def strip_near(ev, d):
    """d와 같은 결정으로 보이는 근거를 모두 뺀다(평가 누수 방지)."""
    key = tok(d["question"] + " " + " ".join(map(str, d["options"])) + " " + str(d.get("quote", "")))
    out = dict(ev)
    out["decisions"] = [x for x in ev["decisions"] if x.get("id") != d.get("id") and jac(key, tok(
        x["question"] + " " + " ".join(map(str, x["options"])) + " " + str(x.get("quote", "")))) < NEAR]
    out["verdicts"] = [v for v in ev["verdicts"] if jac(key, tok(
        f"{v.get('target', '')} {v.get('quote', '')} {v.get('reason', '')}")) < NEAR]
    out["answers"] = [a for a in ev["answers"] if jac(key, tok(
        f"{a.get('question', '')} {a.get('answer', '')} {' '.join(map(str, a.get('options', [])))}")) < NEAR]
    return out


def one(args):
    d, ev = args
    case = d["question"] + (f"\n상황: {d['context']}" if d.get("context") else "")
    try:
        r = choose.run({"case": case, "candidates": d["options"], "recommended": d.get("recommended")},
                       ev=strip_near(ev, d))
    except (jevlib.JevError, ValueError) as e:
        return {"id": d["id"], "error": str(e)[:200]}
    return {"id": d["id"], "kind": d.get("kind"), "category": d.get("category"), "n_options": len(d["options"]),
            "choice": d["choice"], "recommended": d.get("recommended"), "pick": r["pick"],
            "confidence": r["confidence"], "stable": r["stable"], "gate": r["gate"],
            "hit": int(r["pick"] == d["choice"])}


def main():
    global NEAR
    ap = argparse.ArgumentParser()
    ap.add_argument("--name", default="gd1")
    ap.add_argument("--near", type=float, default=NEAR, help="이 이상 겹치는 기록은 같은 결정으로 보고 근거에서 뺀다")
    ap.add_argument("--no-decisions", action="store_true", help="게임 개발 결정 기록을 근거에서 모두 뺀다")
    ap.add_argument("--blind", action="store_true", help="대조군: 형님 기록 없이 설명 한 줄만")
    ap.add_argument("--generic", action="store_true", help="대조군: 형님 기록도 설명도 없이 일반 게임 디렉터로")
    a = ap.parse_args()
    NEAR = a.near
    sys.stdout.reconfigure(encoding="utf-8")
    ev = evidence.load()
    items = ev["decisions"]
    if a.no_decisions or a.blind or a.generic:
        ev = dict(ev, decisions=[])
    if a.blind or a.generic:
        ev = dict(ev, answers=[], verdicts=[], rules=[], events=[])
    if a.generic:
        evidence.PERSON = "A game director. Predict which option he would pick."
        choose.PICK = "Which option would the director pick for `case`?"
    with ThreadPoolExecutor(6) as ex:
        rows = list(ex.map(one, [(d, ev) for d in items]))
    ok = [r for r in rows if "error" not in r]
    os.makedirs(RUNS, exist_ok=True)
    with open(os.path.join(RUNS, a.name + ".jsonl"), "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    chance = sum(1 / r["n_options"] for r in ok)
    lines = [f"결정 {len(items)}건, Jev 오류 {len(rows) - len(ok)}건",
             f"분신(Jev) 맞힘: {pct(sum(r['hit'] for r in ok), len(ok))} (찍기 기댓값 {chance / max(1, len(ok)):.0%})"]
    for kind, label in (("asked", "AI가 묻고 형님이 답한 것"), ("corrected", "형님이 AI 방향을 바로잡은 것")):
        ks = [r for r in ok if r.get("kind") == kind]
        lines.append(f"{label}: {len(ks)}건, 분신 {pct(sum(r['hit'] for r in ks), len(ks))}")
    wr = [r for r in ok if r.get("recommended") is not None]
    if wr:
        lines.append(f"AI 추천이 기록된 {len(wr)}건: 추천대로 {pct(sum(r['recommended'] == r['choice'] for r in wr), len(wr))}"
                     f" vs 분신 {pct(sum(r['hit'] for r in wr), len(wr))}")
        dis = [r for r in wr if r["pick"] != r["recommended"]]
        lines.append(f"  분신이 추천과 다르게 고른 {len(dis)}건 중 분신이 맞은 것 {pct(sum(r['hit'] for r in dis), len(dis))}")
        acc = [r for r in wr if r["gate"] == "accept"]
        mixed = sum((r["hit"] if r["gate"] == "accept" else int(r["recommended"] == r["choice"])) for r in wr)
        lines.append(f"  분신이 확신(accept)할 때만 분신, 아니면 추천: {pct(mixed, len(wr))} (분신 확신 {len(acc)}건)")
    for g in ("accept", "weak", "ask"):
        gs = [r for r in ok if r["gate"] == g]
        lines.append(f"판정 문 {g}: {len(gs)}건, 맞힘 {pct(sum(r['hit'] for r in gs), len(gs))}")
    cats = {}
    for r in ok:
        cats.setdefault(r.get("category") or "?", []).append(r["hit"])
    lines.append("분야별: " + ", ".join(f"{c} {pct(sum(v), len(v))}" for c, v in sorted(cats.items())))
    with open(os.path.join(RUNS, a.name + ".txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
