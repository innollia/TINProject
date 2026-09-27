"""대화 묶음에서 '판단 사건'을 뽑는다. 끊겨도 이어서 한다(이미 뽑은 묶음은 건너뜀).

  python extract.py --split train --workers 6
  python extract.py --split gold  --workers 6
출력: raw/events/<split>/<chunk id>.json  (사건 목록, 없으면 빈 목록)
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "..", "raw")
MODEL = os.environ.get("AVATAR_EXTRACT_MODEL", "claude-sonnet-4.6")
ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")

PROMPT = """아래는 디스코드 대화다. '나'가 innollia 본인이다.
'나'가 무언가를 고르거나, 평가하거나, 남의 해석을 고쳐 준 장면만 '판단 사건'으로 뽑아라.
잡담, 단순 감상, 정보 전달은 뽑지 않는다. 없으면 빈 목록.
특히 '나'가 "아니 그게 아니라"처럼 남이나 AI의 해석을 바로잡은 장면은 꼭 뽑고 correction=true로 표시한다.

사건마다 아래 칸을 채운다. 대화에 없는 내용은 지어내지 말고 "" 로 둔다.
- situation: 당시 상황(선택지가 무엇이었는지 알 수 있게, 결론은 쓰지 않음)
- conflict: 무엇과 무엇이 부딪혔나 (예: 수면 vs 드문 기회)
- options: 가능했던 선택지 목록
- choice: 실제로 고른 것 / 내린 평가
- reason: '나'가 말한 이유 (말하지 않았으면 "")
- aftermath: 나중에 느낀 문제나 뒤집힘 (없으면 "")
- correction: 남의 해석을 바로잡은 장면이면 true
- quote: 판단이 드러난 '나'의 원문 한 줄(그대로, 80자 이내)
- time: 그 원문의 [시:분]
- domain: 게임|그림|글·이야기|도구·개발|생활·시간|관계|돈|공부|기타 중 하나

출력은 JSON 배열 하나만. 다른 글은 쓰지 않는다.

[대화 {ref}]
{body}
"""


def call(prompt):
    out = subprocess.run(["kiro-cli", "chat", "--no-interactive", "--model", MODEL,
                          "--trust-tools=", prompt],
                         capture_output=True, timeout=400, encoding="utf-8", errors="replace")
    raw = ANSI.sub("", (out.stdout or "") + "\n" + (out.stderr or ""))
    return "\n".join(l for l in raw.splitlines() if not l.startswith(("[warn]", "[tool]")))


def parse(raw):
    s, e = raw.find("["), raw.rfind("]")
    while s != -1 and e > s:
        try:
            v = json.loads(raw[s:e + 1])
            if isinstance(v, list):
                return v
        except ValueError:
            pass
        s = raw.find("[", s + 1)
    return None


def work(path, outdir):
    chunk = json.load(open(path, encoding="utf-8"))
    dst = os.path.join(outdir, chunk["id"] + ".json")
    if os.path.exists(dst):
        return "skip"
    prompt = PROMPT.format(ref=chunk["ref"], body="\n".join(chunk["lines"]))
    for _ in range(3):
        try:
            ev = parse(call(prompt))
        except subprocess.TimeoutExpired:
            ev = None
        if ev is not None:
            ev = [e for e in ev if isinstance(e, dict)]
            for i, e in enumerate(ev):
                e["chunk"] = chunk["id"]
                e["ref"] = chunk["ref"]
                e["eid"] = f"{chunk['id']}-{i}"
            with open(dst, "w", encoding="utf-8") as f:
                json.dump(ev, f, ensure_ascii=False)
            return len(ev)
    return "fail"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--split", required=True, choices=["train", "gold"])
    ap.add_argument("--workers", type=int, default=6)
    ap.add_argument("--limit", type=int, default=0)
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    outdir = os.path.join(RAW, "events", a.split)
    os.makedirs(outdir, exist_ok=True)
    paths = sorted(glob.glob(os.path.join(RAW, "chunks", a.split, "*.json")))
    if a.limit:
        paths = paths[:a.limit]
    done = fail = events = 0
    with ThreadPoolExecutor(a.workers) as ex:
        for r in ex.map(lambda p: work(p, outdir), paths):
            if r == "fail":
                fail += 1
            elif r != "skip":
                done += 1
                events += r
    print(f"{a.split}: 새로 {done}묶음, 사건 {events}개, 실패 {fail}, 전체 {len(paths)}")


if __name__ == "__main__":
    main()
