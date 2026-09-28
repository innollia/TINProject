"""형님이 직접 한 답을 <데이터 폴더>/decision/answers.jsonl에 더한다. 다음 판정부터 가장 강한 근거가 된다.

  python record.py answer.json      (객체 하나 또는 배열)
칸: question, answer (필수) / options, reason, flip, domain, hypotheses (선택)
"""
import datetime
import json
import os
import sys

import jevlib

KEYS = ("question", "options", "answer", "reason", "flip", "domain", "hypotheses")


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    if len(sys.argv) < 2:
        print("usage: python record.py answer.json")
        sys.exit(2)
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
    rows = data if isinstance(data, list) else [data]
    good = [r for r in rows if str(r.get("question", "")).strip() and str(r.get("answer", "")).strip()]
    path = os.path.join(jevlib.data_dir(), "decision", "answers.jsonl")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    lead = ""
    if os.path.exists(path) and os.path.getsize(path):
        with open(path, "rb") as f:
            f.seek(-1, os.SEEK_END)
            lead = "" if f.read(1) == b"\n" else "\n"
    today = datetime.date.today().isoformat()
    with open(path, "a", encoding="utf-8") as f:
        f.write(lead)
        for r in good:
            row = {"options": [], "reason": "", "flip": "", "domain": "기타"}
            row.update({k: r[k] for k in KEYS if k in r})
            row["date"] = r.get("date", today)
            f.write(json.dumps(row, ensure_ascii=False) + "\n")
    print(f"recorded {len(good)}/{len(rows)} -> {path}")


if __name__ == "__main__":
    main()
