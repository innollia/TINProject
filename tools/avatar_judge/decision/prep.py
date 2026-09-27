"""디스코드 로그를 대화 묶음(채널·날짜)으로 자르고, 시험지(gold) 20%를 먼저 봉인한다.

  python prep.py
출력(raw/, 저장소에 안 올림)
  raw/chunks/train/<id>.json   분신 기억을 만드는 데 쓰는 묶음
  raw/chunks/gold/<id>.json    시험지. 기억 만들기에 절대 쓰지 않는다
"""
import glob
import hashlib
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.environ.get("COGNI_DIR", r"C:\Users\fixme\Downloads\Cognipotato")
OUT = os.path.join(HERE, "..", "raw", "chunks")
ME = {"innollia", "이놀아안"}
HEAD = re.compile(r"^### (.+?) · (\d{4}-\d{2}-\d{2}) (\d{2}:\d{2})\s*$")
MIN_MINE = 6
MAX_CHARS = 12000


def parse(path):
    text = open(path, encoding="utf-8").read()
    chan = re.search(r'^channel: "(.*)"', text, re.M)
    chan = chan.group(1) if chan else os.path.basename(os.path.dirname(path))
    msgs, cur = [], None
    for line in text.splitlines():
        m = HEAD.match(line)
        if m:
            cur = {"who": m.group(1), "date": m.group(2), "time": m.group(3), "text": ""}
            msgs.append(cur)
        elif cur is not None and line.strip():
            cur["text"] += (" " if cur["text"] else "") + line.strip()
    thread = os.path.splitext(os.path.basename(path))[0]
    return chan, thread, msgs


def is_gold(key):
    return int(hashlib.sha1(key.encode()).hexdigest(), 16) % 5 == 0


def main():
    for split in ("train", "gold"):
        os.makedirs(os.path.join(OUT, split), exist_ok=True)
    stats = {"train": 0, "gold": 0}
    for path in sorted(glob.glob(os.path.join(SRC, "**", "*.md"), recursive=True)):
        chan, thread, msgs = parse(path)
        by_day = {}
        for m in msgs:
            by_day.setdefault(m["date"], []).append(m)
        for day, ms in by_day.items():
            if sum(m["who"] in ME for m in ms) < MIN_MINE:
                continue
            key = f"{chan}/{thread}/{day}"
            split = "gold" if is_gold(key) else "train"
            part, buf, size = 0, [], 0
            for m in ms + [None]:
                line = None if m is None else f"[{m['time']}] {'나' if m['who'] in ME else m['who']}: {m['text']}"
                if m is None or size + len(line) > MAX_CHARS:
                    if buf and any(b.split(": ", 1)[0].endswith("나") for b in buf):
                        cid = hashlib.sha1(f"{key}#{part}".encode()).hexdigest()[:12]
                        with open(os.path.join(OUT, split, cid + ".json"), "w", encoding="utf-8") as f:
                            json.dump({"id": cid, "ref": f"{key}#{part}", "lines": buf}, f, ensure_ascii=False)
                        stats[split] += 1
                        part += 1
                    buf, size = [], 0
                if m is not None:
                    buf.append(line)
                    size += len(line)
    print(stats)


if __name__ == "__main__":
    main()
