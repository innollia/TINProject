import json
import os

from eval_gold import RUNS, load_gold, options_of

pred = {}
with open(os.path.join(RUNS, "v2-llm.jsonl"), encoding="utf-8") as f:
    for line in f:
        if line.strip():
            r = json.loads(line)
            pred[r["eid"]] = r["예측"]
llm_opts, opts_only = {}, {}
for e in load_gold(80):
    opts = [{"answer": o, "reason": ""} for o in options_of(e)]
    if len(opts) >= 2:
        opts_only[e["eid"]] = opts
    p = pred.get(e["eid"]) or {}
    first = [{"answer": str(p.get("선택", "")).strip(), "reason": ""}]
    both = [c for c in first if c["answer"]] + [o for o in opts if o["answer"] != first[0]["answer"]]
    if len(both) >= 2:
        llm_opts[e["eid"]] = both[:12]
for name, d in (("candidates3", llm_opts), ("candidates4", opts_only)):
    with open(os.path.join(RUNS, name + ".json"), "w", encoding="utf-8") as f:
        json.dump(d, f, ensure_ascii=False, indent=1)
    print(name, len(d))
