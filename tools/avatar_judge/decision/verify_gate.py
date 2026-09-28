"""LLM이 판단하고 Jev가 검증하는 방식을 저장된 결과로 계산한다. 새 호출은 없다.

  python verify_gate.py            → raw/gold_runs/verify_gate.txt
v2-llm-jg: LLM 판단(형님 기록을 읽고 답함)을 Jev 채점기로 채점한 결과
v3c-llmopts-jg: 후보 = [LLM 답] + 실제 선택지들, 그중 Jev가 고른 결과
Jev가 LLM 답을 골랐으면 '동의'. 동의할 때만 LLM 답을 쓰고, 아니면 형님께 묻는다고 치고 센다.
"""
import json
import os
import sys

from eval_gold import RUNS


def load(name):
    with open(os.path.join(RUNS, name + ".jsonl"), encoding="utf-8") as f:
        return {r["eid"]: r for r in (json.loads(x) for x in f if x.strip())}


def pct(a, b):
    return f"{a}/{b} ({a / b:.0%})" if b else "0/0"


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    llm, jev = load("v2-llm-jg"), load("v3c-llmopts-jg")
    with open(os.path.join(RUNS, "candidates3.json"), encoding="utf-8") as f:
        cands = json.load(f)
    rows = []
    for eid, r in llm.items():
        j = jev.get(eid)
        ok = r["채점"].get("선택")
        if j is None or ok is None or str(j["예측"].get("선택", "")).startswith("(") or eid not in cands:
            continue
        agree = j["예측"].get("선택") == cands[eid][0]["answer"]
        rows.append((agree, float(j["예측"].get("확신도") or 0), int(ok)))
    n = len(rows)
    lines = [f"사건 {n}개. LLM 혼자: {pct(sum(o for *_, o in rows), n)}"]
    ag = [o for a, _, o in rows if a]
    dis = [o for a, _, o in rows if not a]
    lines.append(f"Jev가 LLM 답에 동의: {len(ag)}건, 그때 LLM 적중 {pct(sum(ag), len(ag))}")
    lines.append(f"Jev가 다른 답을 고름: {len(dis)}건, 그때 LLM 적중 {pct(sum(dis), len(dis))}")
    for th in (0.0, 0.5, 0.7):
        keep = [o for a, c, o in rows if a and c >= th]
        lines.append(f"동의하고 Jev 확신도 {th} 이상이면 그대로 씀: {len(keep)}건 적중 {pct(sum(keep), len(keep))}, "
                     f"형님께 물을 것 {n - len(keep)}건({(n - len(keep)) / n:.0%})")
    out = os.path.join(RUNS, "verify_gate.txt")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
