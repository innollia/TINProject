"""TIN 문서에서 게임 개발 AI가 멈추고 물은 결정(또는 형님이 AI 방향을 바로잡은 기록)과 형님 답을 모은다.

  python harvest_decisions.py --root C:/Users/fixme/Desktop/TINProject
출력: raw/gamedev/decisions.json, decision/gamedev_decisions.jsonl(판단 근거로 씀)
문서 전체가 아니라 결정 기록이 있는 줄 주변만 잘라 모델 호출 한 번에 여러 파일씩 묶는다.
"""
import argparse
import glob
import hashlib
import json
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor

from extract import RAW, best_list, call

HERE = os.path.dirname(os.path.abspath(__file__))
MARK = re.compile(r"사용자 (답|결정|원문|확인|정정|지시|선택|반려)|이미 이렇게 진행함|형님 (답|원문)|원문[:：]|반려 원문|사용자:")
SKIP = ("archive", "golden_idol_story", os.sep + "jobs" + os.sep, "tools" + os.sep + "avatar_judge", ".git")
WIN, CAP, BATCH = 10, 3500, 14000

PROMPT = """아래는 TINProject(한 게임 안에서 장르가 바뀌는 게임) 개발 문서 조각이다. 게임 개발 AI가 작업하다 멈추고 사용자(innollia, 형님)에게 결정을 물은 기록과, 사용자가 AI의 방향을 바로잡은 기록을 모두 뽑는다.
- 게임 개발 결정만 뽑는다: 창작 방향, 생물·인물 생김새와 움직임, 세계관·스토리·콘텐츠, 화면 구성·조작, Kit 범위, 레퍼런스 해석, 그림·에셋 제작 방식, 작업 진행 방식. 일상 이야기는 뺀다.
- 사용자가 실제로 정한 것만 뽑는다. '사용자 확인 대기'처럼 답이 없는 것은 뺀다.
- 기록 하나마다
  - question: AI가 멈춰서 물을 법한 질문 한 문장. 결론은 쓰지 않는다
  - context: 어느 Kit·작업에서 무엇을 하던 중이었는지 한 줄
  - options: AI가 내놓았을 선택지 2~4개. 문서에 선택지가 있으면 그대로 쓴다. 없으면 AI가 하려던 방향과 사용자가 정한 방향을 넣고, 그럴 법한 다른 선택지를 하나까지 더한다. 선택지끼리 길이를 비슷하게, 사용자 쪽을 더 자세히 쓰지 않는다
  - choice: 사용자가 고른 선택지 번호(0부터)
  - recommended: AI가 추천한(또는 하려던) 선택지 번호. 알 수 없으면 null
  - kind: "asked"(AI가 물었고 사용자가 답함) 또는 "corrected"(사용자가 AI 방향을 바로잡음)
  - quote: 사용자 원문이 있으면 그대로, 없으면 ""
  - reason: 사용자가 그렇게 정한 이유 한 줄
  - category: creative, visual, creature, ui, scope, reference, world, production, workflow 중 하나
  - date: 보이면 YYYY-MM-DD, 없으면 ""
  - source: 조각 머리의 파일 경로
- 같은 결정이 여러 조각에 나오면 한 번만 뽑는다.
- 파일을 만들거나 도구를 쓰지 말고, 답 본문에 JSON 배열만 출력한다.
출력: [{{"question": "...", "context": "...", "options": ["...", "..."], "choice": 0, "recommended": null, "kind": "asked", "quote": "", "reason": "...", "category": "creative", "date": "", "source": "..."}}]

[문서 조각]
{chunks}
"""


def snippets(root):
    out = []
    for path in sorted(glob.glob(os.path.join(root, "**", "*.md"), recursive=True)):
        rel = os.path.relpath(path, root)
        if any(s in os.sep + rel for s in SKIP):
            continue
        try:
            lines = open(path, encoding="utf-8").read().splitlines()
        except (OSError, UnicodeDecodeError):
            continue
        hits = [i for i, l in enumerate(lines) if MARK.search(l)]
        if not hits:
            continue
        keep, text = set(), []
        for i in hits:
            keep.update(range(max(0, i - WIN), min(len(lines), i + WIN + 1)))
        prev = -2
        for i in sorted(keep):
            if i != prev + 1:
                text.append("…")
            text.append(lines[i])
            prev = i
        body = "\n".join(text)[:CAP]
        out.append((len(hits), f"### {rel}\n{body}"))
    out.sort(key=lambda t: -t[0])
    return [s for _, s in out]


def batches(chunks):
    cur, size = [], 0
    for c in chunks:
        if cur and size + len(c) > BATCH:
            yield cur
            cur, size = [], 0
        cur.append(c)
        size += len(c)
    if cur:
        yield cur


def valid(d):
    opts = d.get("options")
    ok = isinstance(opts, list) and 2 <= len(opts) <= 6 and all(str(o).strip() for o in opts)
    try:
        ch = int(d.get("choice"))
    except (TypeError, ValueError):
        return False
    return ok and 0 <= ch < len(opts) and str(d.get("question", "")).strip()


def tokens(s):
    return set(re.findall(r"[가-힣A-Za-z0-9]{2,}", s or ""))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    parts = list(batches(snippets(a.root)))
    with ThreadPoolExecutor(4) as ex:
        found = [d for got in ex.map(lambda p: best_list(call(PROMPT.format(chunks="\n\n".join(p))), "question"), parts)
                 for d in got if valid(d)]
    kept = []
    for d in found:  # 같은 결정이 여러 문서에 적힌 것은 하나만
        key = tokens(d["question"] + " " + str(d["options"][int(d["choice"])]))
        if any(len(key & k) / max(1, len(key | k)) > 0.5 for k, _ in kept):
            continue
        d["choice"] = int(d["choice"])
        rec = d.get("recommended")
        d["recommended"] = int(rec) if isinstance(rec, (int, float)) and 0 <= int(rec) < len(d["options"]) else None
        d["id"] = "G" + hashlib.sha1(d["question"].encode("utf-8")).hexdigest()[:8]
        kept.append((key, d))
    rows = [d for _, d in kept]
    os.makedirs(os.path.join(RAW, "gamedev"), exist_ok=True)
    with open(os.path.join(RAW, "gamedev", "decisions.json"), "w", encoding="utf-8") as f:
        json.dump(rows, f, ensure_ascii=False, indent=1)
    with open(os.path.join(HERE, "gamedev_decisions.jsonl"), "w", encoding="utf-8") as f:
        for d in rows:
            f.write(json.dumps(d, ensure_ascii=False) + "\n")
    kinds = {}
    for d in rows:
        kinds[d.get("kind", "?")] = kinds.get(d.get("kind", "?"), 0) + 1
    print(f"조각 묶음 {len(parts)}개(모델 호출 {len(parts)}번) → 뽑음 {len(found)}, 중복 뺀 뒤 {len(rows)} {kinds}, "
          f"추천 기록 있음 {sum(d['recommended'] is not None for d in rows)}")


if __name__ == "__main__":
    main()
