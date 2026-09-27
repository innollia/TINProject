"""시험지(gold) 채점: 분신에게 당시 상황까지만 주고 형님의 실제 선택을 예측하게 한다.

  python eval_gold.py --name v1 --n 80
지표 4개
  선택 일치    예측 선택이 실제 선택과 같은 쪽인가(채점 모델 0/1)
  이유 일치    예측 근거가 실제 이유의 핵심을 짚었나(실제 이유가 없는 사건은 제외)
  확신도 보정  확신도 0.7 이상일 때의 선택 일치율 vs 0.5 미만일 때
  뒤집힘 조건  예측한 '반대로 고를 조건'이 실제 나중의 뒤집힘(aftermath)과 맞나(aftermath 있는 사건만)
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


def grade(e, p):
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


def one(e):
    p = decide(e.get("situation", ""), e.get("options", []))
    g = grade(e, p)
    return {"eid": e["eid"], "domain": e.get("domain"), "situation": e.get("situation"),
            "실제": {"선택": e.get("choice"), "이유": e.get("reason"), "나중": e.get("aftermath")},
            "예측": p, "채점": g}


def rate(xs):
    xs = [x for x in xs if x is not None]
    return (sum(xs), len(xs))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--name", required=True)
    ap.add_argument("--n", type=int, default=80)
    ap.add_argument("--workers", type=int, default=6)
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    ev = []
    for f in sorted(glob.glob(os.path.join(RAW, "events", "gold", "*.json"))):
        ev += [e for e in json.load(open(f, encoding="utf-8")) if e.get("choice") and e.get("situation")]
    random.Random(7).shuffle(ev)
    ev = ev[:a.n]
    with ThreadPoolExecutor(a.workers) as ex:
        rows = list(ex.map(one, ev))
    os.makedirs(os.path.join(RAW, "gold_runs"), exist_ok=True)
    with open(os.path.join(RAW, "gold_runs", a.name + ".jsonl"), "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    c = rate([r["채점"].get("선택") for r in rows])
    w = rate([r["채점"].get("이유") for r in rows])
    fl = rate([r["채점"].get("뒤집힘") for r in rows])
    hi = rate([r["채점"].get("선택") for r in rows if r["예측"].get("확신도", 0) >= 0.7])
    lo = rate([r["채점"].get("선택") for r in rows if r["예측"].get("확신도", 0) < 0.5])
    pct = lambda t: f"{t[0]}/{t[1]} ({t[0] / t[1]:.0%})" if t[1] else "0/0"
    print(f"{a.name}: 선택 {pct(c)} | 이유 {pct(w)} | 뒤집힘 {pct(fl)} | "
          f"확신 높음(≥0.7) 선택 {pct(hi)} | 확신 낮음(<0.5) 선택 {pct(lo)}")
    by = {}
    for r in rows:
        by.setdefault(r["domain"], []).append(r["채점"].get("선택"))
    print("분야별 선택:", {d: pct(rate(v)) for d, v in by.items()})


if __name__ == "__main__":
    main()
