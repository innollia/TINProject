"""형님이 직접 정한 것을 기록한다. 다음 판정부터 가장 강한 근거가 된다.

  python record.py answer.json      (객체 하나 또는 배열)
게임 개발 결정(멈춘 AI가 물은 것) → <데이터 폴더>/decision/gamedev_decisions.jsonl
  칸: question, options(선택지 목록), choice(형님이 고른 번호, 0부터) 필수
      context, recommended(AI 추천 번호), kind("asked"|"corrected"), quote(형님 원문), reason, category, source 선택
그 밖의 A/B 답 → <데이터 폴더>/decision/answers.jsonl
  칸: question, answer 필수 / options, reason, flip, domain 선택
"""
import datetime
import hashlib
import json
import os
import sys

import jevlib

ANSWER_KEYS = ("question", "options", "answer", "reason", "flip", "domain", "hypotheses")
DECISION_KEYS = ("question", "context", "options", "choice", "recommended", "kind", "quote", "reason",
                 "category", "source")


def _append(path, rows):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    lead = ""
    if os.path.exists(path) and os.path.getsize(path):
        with open(path, "rb") as f:
            f.seek(-1, os.SEEK_END)
            lead = "" if f.read(1) == b"\n" else "\n"
    with open(path, "a", encoding="utf-8") as f:
        f.write(lead)
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")


def _is_decision(r):
    opts = r.get("options")
    return isinstance(opts, list) and len(opts) >= 2 and isinstance(r.get("choice"), int) \
        and 0 <= r["choice"] < len(opts)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    if len(sys.argv) < 2:
        print("usage: python record.py answer.json")
        sys.exit(2)
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
    rows = data if isinstance(data, list) else [data]
    today = datetime.date.today().isoformat()
    decisions, answers = [], []
    for r in rows:
        if not str(r.get("question", "")).strip():
            continue
        if _is_decision(r):
            d = {"kind": "asked", "recommended": None, "quote": "", "reason": "", "context": "",
                 "category": "creative", "source": "record.py"}
            d.update({k: r[k] for k in DECISION_KEYS if k in r})
            d["date"] = r.get("date", today)
            d["id"] = "G" + hashlib.sha1(d["question"].encode("utf-8")).hexdigest()[:8]
            decisions.append(d)
        elif str(r.get("answer", "")).strip():
            a = {"options": [], "reason": "", "flip": "", "domain": "기타"}
            a.update({k: r[k] for k in ANSWER_KEYS if k in r})
            a["date"] = r.get("date", today)
            answers.append(a)
    base = jevlib.data_dir()
    if decisions:
        _append(os.path.join(base, "decision", "gamedev_decisions.jsonl"), decisions)
    if answers:
        _append(os.path.join(base, "decision", "answers.jsonl"), answers)
    print(f"recorded decisions {len(decisions)}, answers {len(answers)} (of {len(rows)}) -> {base}")


if __name__ == "__main__":
    main()
