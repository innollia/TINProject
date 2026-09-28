"""가려 둔 판정(HOLDOUT)을 분신에게 새로 판정시켜 형님 실제 판정과의 일치율을 잰다.

  python eval.py --round 1            # 판정 + 채점
  python eval.py --round 1 --regrade  # 저장된 판정을 다시 채점만

지표
  판정 일치: 통과/퇴짜가 같은 비율
  이유 일치: 분신 한 줄 평이 형님 원문과 같은 핵심 이유를 짚었는지(채점 모델이 0/1)
  종합: 판정과 이유가 둘 다 맞은 비율
  기준선: 무조건 퇴짜만 냈을 때의 판정 일치
"""
import argparse
import json
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor

from judge import HERE, call_model, is_holdout, judge, load_judgments

GRADE_PROMPT = """두 평가가 같은 핵심 이유를 짚었는지 채점한다.
대상: {target}
실제 평가(형님 원문): {real}
예측 평가: {pred}
예측이 실제 평가의 핵심 이유(무엇이 좋고 무엇이 문제인지)를 짚었으면 1, 다른 이유를 대거나 핵심을 놓쳤으면 0.
판정(통과/퇴짜) 자체가 같은지는 보지 않는다. 이유만 본다.
출력은 JSON 한 줄만: {{"이유일치": 0 또는 1, "설명": "짧게"}}"""


def grade(row):
    raw = call_model(GRADE_PROMPT.format(
        target=row["target"], real=row["형님"]["원문"],
        pred=row["분신"].get("한줄평", "")))
    for m in reversed(list(re.finditer(r"\{[^{}]*\"이유일치\"[^{}]*\}", raw))):
        try:
            d = json.loads(m.group(0))
            return int(d["이유일치"]), d.get("설명", "")
        except (ValueError, KeyError, TypeError):
            continue
    return 0, "(채점 실패)"


def run_one(j):
    got = judge(j["target"], j.get("capture"))
    want = "통과" if j["verdict"] == "pass" else "퇴짜"
    return {
        "id": j["id"],
        "target": j["target"],
        "형님": {"판정": want, "원문": j["quote"]},
        "분신": got,
        "일치": got.get("판정") == want,
    }


def with_grade(row):
    row["이유일치"], row["채점설명"] = grade(row)
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--round", type=int, required=True)
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--regrade", action="store_true")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    os.makedirs(os.path.join(HERE, "eval_runs"), exist_ok=True)
    path = os.path.join(HERE, "eval_runs", f"round_{a.round}.jsonl")
    if a.regrade:
        with open(path, encoding="utf-8") as f:
            rows = [json.loads(l) for l in f if l.strip()]
    else:
        items = [j for j in load_judgments() if is_holdout(j["id"])]
        with ThreadPoolExecutor(a.workers) as ex:
            rows = list(ex.map(run_one, items))
    with ThreadPoolExecutor(a.workers) as ex:
        rows = list(ex.map(with_grade, rows))
    with open(path, "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    n = len(rows)
    v = sum(r["일치"] for r in rows)
    why = sum(r["이유일치"] for r in rows)
    both = sum(r["일치"] and r["이유일치"] for r in rows)
    base = sum(r["형님"]["판정"] == "퇴짜" for r in rows)
    print(f"round {a.round}: 판정 {v}/{n} ({v/n:.0%}) | 이유 {why}/{n} ({why/n:.0%}) "
          f"| 종합 {both}/{n} ({both/n:.0%}) | 기준선(무조건 퇴짜) {base}/{n} ({base/n:.0%})")
    for r in rows:
        print(f"{'O' if r['일치'] else 'X'}{'O' if r['이유일치'] else 'X'} {r['id']} "
              f"형님={r['형님']['판정']} 분신={r['분신'].get('판정')}({r['분신'].get('점수')}) "
              f"{r['분신'].get('한줄평')} // {r['채점설명']}")


if __name__ == "__main__":
    main()
