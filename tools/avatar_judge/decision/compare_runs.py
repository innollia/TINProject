"""두 시험지 채점 결과를 같은 사건끼리 비교한다. 숫자만 낸다(사건 내용은 안 씀).

  python compare_runs.py v1 v2-llm   → 화면 + raw/gold_runs/compare_v1_v2-llm.txt
"""
import json
import os
import sys

from extract import RAW


def load(name):
    rows = {}
    with open(os.path.join(RAW, "gold_runs", name + ".jsonl"), encoding="utf-8") as f:
        for line in f:
            if line.strip():
                r = json.loads(line)
                rows[r["eid"]] = r
    return rows


def rate(xs):
    xs = [1 if x in (1, True, "1") else 0 for x in xs if x is not None]
    return sum(xs), len(xs)


def pct(t):
    return f"{t[0]}/{t[1]} ({t[0] / t[1]:.0%})" if t[1] else "0/0"


def summary(rows):
    g = [r.get("채점") or {} for r in rows]
    conf = []
    for r in rows:
        try:
            conf.append(float(r["예측"].get("확신도") or 0))
        except (TypeError, ValueError):
            conf.append(0.0)
    eng = {}
    for r in rows:
        k = r["예측"].get("_engine", "llm")
        eng[k] = eng.get(k, 0) + 1
    return [
        ("선택", pct(rate([x.get("선택") for x in g]))),
        ("이유", pct(rate([x.get("이유") for x in g]))),
        ("뒤집힘", pct(rate([x.get("뒤집힘") for x in g]))),
        ("확신 높음(≥0.7) 선택", pct(rate([x.get("선택") for x, c in zip(g, conf) if c >= 0.7]))),
        ("확신 낮음(<0.5) 선택", pct(rate([x.get("선택") for x, c in zip(g, conf) if c < 0.5]))),
        ("엔진", json.dumps(eng, ensure_ascii=False)),
    ]


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    a, b = sys.argv[1], sys.argv[2]
    ra, rb = load(a), load(b)
    common = sorted(set(ra) & set(rb))
    lines = [f"같은 사건 {len(common)}개 비교 ({a} {len(ra)}개, {b} {len(rb)}개)"]
    for name, rows in ((a, ra), (b, rb)):
        lines.append(f"{name}: " + " | ".join(f"{k} {v}" for k, v in summary([rows[e] for e in common])))
    lines.append("분야별 선택 일치:")
    for d in sorted({ra[e].get("domain") or "기타" for e in common}):
        ids = [e for e in common if (ra[e].get("domain") or "기타") == d]
        lines.append(f"  {d} ({len(ids)}건): {a} {pct(rate([ra[e]['채점'].get('선택') for e in ids]))}"
                     f" → {b} {pct(rate([rb[e]['채점'].get('선택') for e in ids]))}")
    out = os.path.join(RAW, "gold_runs", f"compare_{a}_{b}.txt")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
