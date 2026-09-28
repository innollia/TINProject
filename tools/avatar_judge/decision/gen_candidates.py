"""시험지 사건마다 에이전트(LLM)가 답 후보를 4개씩 만든다. 형님의 실제 선택은 보여 주지 않는다.

  python gen_candidates.py --n 80   → raw/gold_runs/candidates.json  {eid: [{"answer", "reason"}, ...]}
사건 20개를 모델 호출 한 번에 묶어 LLM 토큰을 아낀다(80건이면 호출 4번).
"""
import argparse
import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor

from eval_gold import RUNS, load_gold, options_of
from extract import best_list, call

PROMPT = """아래 상황마다 innollia가 고를 법한 답 후보를 3~4개씩 만든다. 그가 실제로 무엇을 골랐는지는 모른다.
- 후보마다 딱 잘라 말하는 하나의 입장이어야 한다. 서로 방향이 달라야 한다.
- "상황에 따라 다르다", "~에 따라 갈린다", "둘 다 일리 있다" 같은 조건부·얼버무리는 후보는 쓰지 않는다.
- 가능했던 선택지가 적혀 있으면 그 선택지들은 후보에 꼭 넣는다.
- answer: 고를 행동이나 입장 한 줄. reason: 그렇게 고르는 이유 한 줄.
- 어느 후보가 맞을지 편들지 않는다. 후보들의 길이와 말투를 비슷하게 맞춘다.
- 파일을 만들거나 도구를 쓰지 말고, 답 본문에 JSON 배열만 출력한다.
출력: [{{"eid": "...", "candidates": [{{"answer": "...", "reason": "..."}}]}}]

[상황]
{cases}
"""


def line(e):
    s = f"eid: {e['eid']} | 상황: {e.get('situation', '')}"
    if e.get("conflict"):
        s += f" | 부딪힌 것: {e['conflict']}"
    opts = options_of(e)
    if opts:
        s += " | 가능했던 선택지: " + " / ".join(opts)
    return s


def batch(part):
    got = best_list(call(PROMPT.format(cases="\n".join(line(e) for e in part))), "eid")
    out = {}
    for g in got:
        cs = [c for c in (g.get("candidates") or []) if isinstance(c, dict) and str(c.get("answer", "")).strip()]
        if len(cs) >= 2:
            out[str(g["eid"])] = cs[:6]
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=80)
    ap.add_argument("--size", type=int, default=20)
    ap.add_argument("--out", default="candidates")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    ev = load_gold(a.n)
    want = {e["eid"] for e in ev}
    res, calls = {}, 0
    for _ in range(2):  # 빠진 사건만 한 번 더
        todo = [e for e in ev if e["eid"] not in res]
        if not todo:
            break
        parts = [todo[i:i + a.size] for i in range(0, len(todo), a.size)]
        calls += len(parts)
        with ThreadPoolExecutor(4) as ex:
            for d in ex.map(batch, parts):
                res.update({k: v for k, v in d.items() if k in want})
    os.makedirs(RUNS, exist_ok=True)
    with open(os.path.join(RUNS, a.out + ".json"), "w", encoding="utf-8") as f:
        json.dump(res, f, ensure_ascii=False, indent=1)
    print(f"후보: {len(res)}/{len(ev)}건, 모델 호출 {calls}번")


if __name__ == "__main__":
    main()
