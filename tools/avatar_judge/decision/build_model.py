"""판단 사건(train)에서 판단 규칙을 만든다. 시험지(gold)는 읽지 않는다.

  python build_model.py                  # 전 분야를 새로 만든다
  python build_model.py --domains 그림   # 이 분야만 다시 만들어 기존 규칙에 합친다
입력: raw/events/train/*.json, answers.jsonl(형님 A/B 답, 가장 강한 근거)
출력:
  judgment_model.json / judgment_model.md  분야별 규칙(조건 → 경향 → 예외 → 뒤집히는 조건, 근거 사건 id)
  raw/memory_index.json                     분야 → 사건 요약 목록(여러 해상도 기억의 중간 층, 전 분야 모드에서만 새로 쓴다)
"""
import argparse
import glob
import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor

from extract import RAW, best_list, call

HERE = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(HERE, "judgment_model.json")
BATCH = 120

PROMPT = """아래는 innollia(형님)의 실제 판단 사건들이다. 분야: {domain}
성격 형용사로 요약하지 말고 '판단 규칙'을 뽑아라. 규칙마다:
- condition: 어떤 상황에서
- tendency: 어느 쪽을 고르는 경향인가
- exception: 예외(그래도 반대로 가는 경우)
- flip: 무엇이 바뀌면 선택이 뒤집히나(경계값이 보이면 구체적으로)
- evidence: 근거 사건 eid 목록(2개 이상이면 좋음, 1개도 허용)
- strength: 근거 수와 일관성으로 본 강도 1~3
서로 부딪히는 규칙은 하나로 뭉개지 말고 둘 다 남기고, conflicts_with에 상대 규칙 번호를 적는다.
[형님 직접 답]으로 표시된 사건은 다른 사건보다 강한 근거다.
말투·반복 주제·유행어는 판단 근거가 아니다. 무엇을 골랐고 왜 골랐는지만 본다.
파일을 만들거나 도구를 쓰지 말고, 답 본문에 JSON 배열만 출력한다.
출력은 JSON 배열 하나만: [{{"id": "{prefix}-1", "condition": "...", "tendency": "...", "exception": "...", "flip": "...", "evidence": [...], "strength": 2, "conflicts_with": []}}]

[사건]
{events}
"""


def load_events():
    ev = []
    for f in sorted(glob.glob(os.path.join(RAW, "events", "train", "*.json"))):
        ev += [e for e in json.load(open(f, encoding="utf-8")) if e.get("choice")]
    ans = os.path.join(HERE, "answers.jsonl")
    if os.path.exists(ans):
        for i, line in enumerate(open(ans, encoding="utf-8")):
            if not line.strip():
                continue
            a = json.loads(line)
            ev.append({"eid": f"answer-{i}", "domain": a.get("domain", "기타"),
                       "situation": a["question"], "options": a.get("options", []),
                       "choice": "[형님 직접 답] " + a["answer"], "reason": a.get("reason", ""),
                       "flip": a.get("flip", "")})
    return ev


def short(e):
    return (f"{e['eid']} | 상황: {e.get('situation','')} | 충돌: {e.get('conflict','')} | "
            f"고름: {e.get('choice','')} | 이유: {e.get('reason','')} | 나중: {e.get('aftermath','')}"
            f"{' | 남의 해석을 바로잡음' if e.get('correction') else ''}")


def as_list(v):
    if not v:
        return []
    return v if isinstance(v, list) else [v]


def build_domain(item):
    domain, evs = item
    rules = []
    for b in range(0, len(evs), BATCH):
        part = evs[b:b + BATCH]
        prefix = f"{domain}{b // BATCH + 1}"
        for _ in range(3):
            got = best_list(call(PROMPT.format(domain=domain, prefix=prefix,
                                               events="\n".join(short(e) for e in part))), "condition")
            if got:
                rules += got
                break
    return domain, rules


def write_md(model, by, n_ev):
    lines = ["# 형님 판단 모델 (자동 생성, build_model.py)", "",
             f"근거: 기억용 판단 사건 {n_ev}개. 시험지 사건은 쓰지 않았다.", ""]
    for d, rules in model.items():
        rules = [r for r in rules if isinstance(r, dict) and r.get("condition")]
        lines += [f"## {d} ({len(by.get(d, []))}개 사건, 규칙 {len(rules)}개)", ""]
        for r in rules:
            cw = ", ".join(map(str, as_list(r.get("conflicts_with"))))
            lines += [f"- **{r.get('id')}** {r.get('condition')} → {r.get('tendency')}",
                      f"  - 예외: {r.get('exception') or '-'}",
                      f"  - 뒤집히는 조건: {r.get('flip') or '-'}",
                      f"  - 강도 {r.get('strength')} · 근거 {', '.join(map(str, as_list(r.get('evidence'))))}"
                      + (f" · 충돌 {cw}" if cw else "")]
        lines.append("")
    open(os.path.join(HERE, "judgment_model.md"), "w", encoding="utf-8").write("\n".join(lines))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--domains", nargs="*", default=None, help="이 분야만 다시 만들어 기존 규칙에 합친다")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    ev = load_events()
    by = {}
    for e in ev:
        by.setdefault(e.get("domain") or "기타", []).append(e)
    if a.domains:
        model = json.load(open(MODEL_PATH, encoding="utf-8"))
        todo = [(d, by.get(d, [])) for d in a.domains]
    else:
        index = {d: [{"eid": e["eid"], "s": e.get("situation", "")[:120], "c": e.get("choice", "")[:120],
                      "r": e.get("reason", "")[:120], "ref": e.get("ref", "")} for e in es]
                 for d, es in by.items()}
        json.dump(index, open(os.path.join(RAW, "memory_index.json"), "w", encoding="utf-8"), ensure_ascii=False)
        model = {}
        todo = sorted(by.items())
    with ThreadPoolExecutor(6) as ex:
        for d, rules in ex.map(build_domain, todo):
            if rules or not a.domains:
                model[d] = rules
            else:
                print(f"{d}: 새 규칙을 못 받아 기존 규칙을 그대로 둠")
    json.dump(model, open(MODEL_PATH, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    write_md(model, by, len(ev))
    print({d: len(r) for d, r in model.items()}, "사건", len(ev))


if __name__ == "__main__":
    main()
