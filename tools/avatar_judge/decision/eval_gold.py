"""시험지(gold) 채점: 분신에게 당시 상황까지만 주고 형님의 실제 선택을 예측하게 한다.

  python eval_gold.py --name v1 --n 80
  python eval_gold.py --name v2-jev-jg --n 80 --with-options --grader jev   # Jev로 예측·채점
  python eval_gold.py --regrade v2-llm --grader jev                           # 저장된 예측을 다시 채점 → v2-llm-jg
지표 4개
  선택 일치    예측 선택이 실제 선택과 같은 쪽인가(채점기 0/1)
  이유 일치    예측 근거가 실제 이유의 핵심을 짚었나(실제 이유가 없는 사건은 제외)
  확신도 보정  확신도 0.7 이상일 때의 선택 일치율 vs 0.5 미만일 때
  뒤집힘 조건  예측한 '반대로 고를 조건'이 실제 나중의 뒤집힘(aftermath)과 맞나(aftermath 있는 사건만)
채점기: llm(기본) 또는 jev(Jev noul 질문, LLM 토큰을 안 씀). 채점기가 다른 두 판은 숫자를 바로 비교하지 않는다.
--with-options: 뽑은 80건 중 선택지가 2개 이상인 사건만 남긴다(Jev가 고를 수 있는 사건).
출력: raw/gold_runs/<name>.jsonl (시험지 내용이 들어 있어 저장소에 안 올림), 화면 요약
"""
import argparse
import glob
import json
import os
import random
import re
import sys
from concurrent.futures import ThreadPoolExecutor

from decide import decide
from extract import RAW, call
import jev

RUNS = os.path.join(RAW, "gold_runs")

GRADE = """형님의 실제 판단과 분신의 예측을 비교해 채점한다.
상황: {situation}
실제 선택: {choice}
실제 이유: {reason}
나중에 뒤집힌 점: {aftermath}
예측 선택: {p_choice}
예측 근거: {p_reason}
예측한 반대 조건: {p_flip}
각 항목 1(맞음)/0(틀림)/null(실제 쪽 정보가 없어 채점 불가):
- 선택: 예측 선택이 실제 선택과 같은 방향인가
- 이유: 예측 근거가 실제 이유의 핵심을 짚었나(실제 이유가 비었으면 null)
- 뒤집힘: 예측한 반대 조건이 '나중에 뒤집힌 점'과 통하나(비었으면 null)
출력은 JSON 한 줄만: {{"선택": 0|1, "이유": 0|1|null, "뒤집힘": 0|1|null}}"""


def grade_llm(e, p):
    raw = call(GRADE.format(situation=e.get("situation", ""), choice=e.get("choice", ""),
                            reason=e.get("reason", "") or "(없음)", aftermath=e.get("aftermath", "") or "(없음)",
                            p_choice=p.get("선택", ""), p_reason=p.get("근거", ""),
                            p_flip=p.get("반대로_고를_조건", "")))
    for m in reversed(list(re.finditer(r"\{[^{}]*\"선택\"[^{}]*\}", raw))):
        try:
            return json.loads(m.group(0))
        except ValueError:
            continue
    return {"선택": 0, "이유": None, "뒤집힘": None}


def grade_jev(e, p):
    """같은 세 항목을 Jev noul 질문으로 채점한다. Jev가 실패하면 채점 불가(None)."""
    state = {"situation": e.get("situation", ""), "actual_choice": e.get("choice", "") or "",
             "actual_reason": e.get("reason", "") or "", "later_reversal": e.get("aftermath", "") or "",
             "predicted_choice": p.get("선택", ""), "predicted_reason": p.get("근거", ""),
             "predicted_flip_condition": p.get("반대로_고를_조건", "")}
    qs = {"sel": {"type": "noul",
                  "instructions": "Does `predicted_choice` pick the same option or direction as `actual_choice`?"}}
    if state["actual_reason"]:
        qs["why"] = {"type": "noul",
                     "instructions": "Does `predicted_reason` capture the core of `actual_reason`?"}
    if state["later_reversal"]:
        qs["flip"] = {"type": "noul",
                      "instructions": "Does `predicted_flip_condition` match what `later_reversal` says changed later?"}
    ans = jev.ask(state, qs)
    if not ans:
        return {"선택": None, "이유": None, "뒤집힘": None, "_jev_error": jev.LAST_ERROR}

    def yes(k):
        a = ans.get(k) or {}
        return int(float(a["noul"]) >= 0.5) if "noul" in a else None
    return {"선택": yes("sel"), "이유": yes("why"), "뒤집힘": yes("flip")}


GRADERS = {"llm": grade_llm, "jev": grade_jev}


def options_of(e):
    o = e.get("options")
    return [s for s in dict.fromkeys(str(x).strip() for x in o) if s] if isinstance(o, list) else []


SKILL_SCRIPTS = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                             "skill", "avatar-jev", "scripts")


def load_gold(n, with_options=False):
    """봉인한 시험지에서 늘 같은 n건을 뽑는다(섞는 씨앗 7)."""
    ev = []
    for f in sorted(glob.glob(os.path.join(RAW, "events", "gold", "*.json"))):
        ev += [e for e in json.load(open(f, encoding="utf-8")) if e.get("choice") and e.get("situation")]
    random.Random(7).shuffle(ev)
    ev = ev[:n]
    if with_options:
        ev = [e for e in ev if len(options_of(e)) >= 2]
    return ev


def rate(xs):
    xs = [x for x in xs if x is not None]
    return (sum(xs), len(xs))


def pct(t):
    return f"{t[0]}/{t[1]} ({t[0] / t[1]:.0%})" if t[1] else "0/0"


def save(name, rows):
    os.makedirs(RUNS, exist_ok=True)
    with open(os.path.join(RUNS, name + ".jsonl"), "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")


def summarize(name, rows):
    g = [r["채점"] for r in rows]
    conf = [float(r["예측"].get("확신도") or 0) for r in rows]
    fails = sum(1 for r in rows if str(r["예측"].get("선택", "")).startswith("("))
    print(f"{name}: 선택 {pct(rate([x.get('선택') for x in g]))} | 이유 {pct(rate([x.get('이유') for x in g]))} | "
          f"뒤집힘 {pct(rate([x.get('뒤집힘') for x in g]))} | "
          f"확신 높음(≥0.7) 선택 {pct(rate([x.get('선택') for x, c in zip(g, conf) if c >= 0.7]))} | "
          f"확신 낮음(<0.5) 선택 {pct(rate([x.get('선택') for x, c in zip(g, conf) if c < 0.5]))} | "
          f"예측 실패 {fails}건")
    by = {}
    for r in rows:
        by.setdefault(r["domain"], []).append(r["채점"].get("선택"))
    print("분야별 선택:", {d: pct(rate(v)) for d, v in by.items()})
    gates = {}
    for r in rows:
        if r["예측"].get("gate"):
            gates.setdefault(r["예측"]["gate"], []).append(r["채점"].get("선택"))
    if gates:
        print("판정 문별 선택:", {k: pct(rate(v)) for k, v in sorted(gates.items())})


def regrade(src, grader, workers):
    with open(os.path.join(RUNS, src + ".jsonl"), encoding="utf-8") as f:
        rows = [json.loads(line) for line in f if line.strip()]

    def again(r):
        e = {"situation": r.get("situation", ""), "choice": r["실제"].get("선택"),
             "reason": r["실제"].get("이유"), "aftermath": r["실제"].get("나중")}
        return dict(r, 채점=GRADERS[grader](e, r["예측"]), 채점_원래=r.get("채점"))
    with ThreadPoolExecutor(workers) as ex:
        new = list(ex.map(again, rows))
    name = f"{src}-{'jg' if grader == 'jev' else 'lg'}"
    save(name, new)
    summarize(name, new)
    agree = []
    for k in ("선택", "이유", "뒤집힘"):
        pairs = [(r["채점_원래"].get(k), r["채점"].get(k)) for r in new if r.get("채점_원래")]
        pairs = [(int(a), int(b)) for a, b in pairs if a is not None and b is not None]
        agree.append(f"{k} {sum(a == b for a, b in pairs)}/{len(pairs)}")
    print("원래 채점과 같은 판정:", " | ".join(agree))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--name")
    ap.add_argument("--n", type=int, default=80)
    ap.add_argument("--workers", type=int, default=6)
    ap.add_argument("--grader", choices=sorted(GRADERS), default="llm")
    ap.add_argument("--with-options", action="store_true")
    ap.add_argument("--regrade", help="저장된 채점 이름. 예측은 그대로 두고 채점만 다시 한다")
    ap.add_argument("--candidates", help="에이전트 후보 파일(gen_candidates.py). 주면 스킬 본체(choose.py)로 Jev가 고른다")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    if a.regrade:
        regrade(a.regrade, a.grader, a.workers)
        return
    if not a.name:
        ap.error("--name 또는 --regrade가 필요하다")
    ev = load_gold(a.n, a.with_options)
    grader = GRADERS[a.grader]
    cands = None
    if a.candidates:
        path = a.candidates if os.path.exists(a.candidates) else os.path.join(RUNS, a.candidates + ".json")
        with open(path, encoding="utf-8") as f:
            cands = json.load(f)
        sys.path.insert(0, SKILL_SCRIPTS)
        import choose as agent_choose
        import evidence as agent_evidence
        agent_ev = agent_evidence.load()
        ev = [e for e in ev if len(cands.get(e["eid"], [])) >= 2]

    def predict(e):
        if cands is None:
            return decide(e.get("situation", ""), options_of(e))
        r = agent_choose.run({"case": e.get("situation", ""), "candidates": cands[e["eid"]]}, ev=agent_ev)
        return {"선택": r["answer"], "근거": r["reason"], "반대로_고를_조건": " / ".join(r["flip_if"]),
                "확신도": r["confidence"], "gate": r["gate"], "stable": r["stable"],
                "_engine": "agent+jev", "_probs": r["probabilities"]}

    def one(e):
        try:
            p = predict(e)
            g = grader(e, p)
        except Exception as ex:  # 사건 하나가 실패해도 나머지 채점은 살린다
            p = {"선택": "(오류)", "확신도": 0.0, "_error": repr(ex)[:300]}
            g = {"선택": None, "이유": None, "뒤집힘": None}
        return {"eid": e["eid"], "domain": e.get("domain"), "situation": e.get("situation"),
                "실제": {"선택": e.get("choice"), "이유": e.get("reason"), "나중": e.get("aftermath")},
                "예측": p, "채점": g}
    with ThreadPoolExecutor(a.workers) as ex:
        rows = list(ex.map(one, ev))
    save(a.name, rows)
    summarize(a.name, rows)


if __name__ == "__main__":
    main()
