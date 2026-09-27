"""판단 엔진: 상황을 넣으면 형님이 고를 선택을 예측한다(말투 없음, JSON만).

  python decide.py --situation "..." --options "A안" "B안"
출력: {"선택", "근거", "확신도"(0~1), "반대로_고를_조건", "쓴_규칙", "쓴_사건"}
기억은 세 층으로 읽는다: 판단 규칙(요약) → 분야별 사건 목록(중간) → 원문 묶음(세부, 필요할 때만).
"""
import argparse
import json
import os
import re
import sys

from extract import RAW, call

HERE = os.path.dirname(os.path.abspath(__file__))
TOP_EVENTS = 25

PROMPT = """너는 innollia(형님)의 판단을 예측하는 엔진이다. 말투는 흉내 내지 않는다.
아래 [판단 규칙]과 [비슷한 과거 사건]만 근거로, [상황]에서 형님이 무엇을 고를지 예측한다.
- 규칙끼리 부딪히면 어느 쪽이 이 상황에 더 맞는지 따지고, 확신도를 낮춘다.
- 근거가 약하거나 없으면 확신도를 0.5 아래로 적고 추측이라고 밝힌다.
- 반대로_고를_조건: 무엇이 바뀌면 형님이 반대를 고를지 구체적으로(경계값이 있으면 숫자로).
출력은 JSON 한 줄만:
{{"선택": "...", "근거": "...", "확신도": 0.0~1.0, "반대로_고를_조건": "...", "쓴_규칙": [...], "쓴_사건": [...]}}

[판단 규칙]
{rules}

[비슷한 과거 사건]
{events}

[상황]
{situation}
선택지: {options}
"""


def tokens(s):
    return {t for t in re.findall(r"[가-힣A-Za-z0-9]{2,}", s or "")}


def retrieve(situation, options):
    model = json.load(open(os.path.join(HERE, "judgment_model.json"), encoding="utf-8"))
    index = json.load(open(os.path.join(RAW, "memory_index.json"), encoding="utf-8"))
    q = tokens(situation + " " + " ".join(options))
    scored = []
    for d, evs in index.items():
        for e in evs:
            scored.append((len(q & tokens(e["s"] + " " + e["c"])), d, e))
    scored.sort(key=lambda x: -x[0])
    top = [x for x in scored[:TOP_EVENTS] if x[0] > 0]
    domains = {d for _, d, _ in top} or set(model)
    top_ids = {e["eid"] for _, _, e in top}
    rules = []
    for d in domains:
        for r in model.get(d, []):
            hit = top_ids & set(map(str, r.get("evidence", [])))
            rules.append((len(hit), r.get("strength", 1), d, r))
    rules.sort(key=lambda x: (-x[0], -x[1]))
    return [r for *_, r in rules[:40]], [e for _, _, e in top]


def decide(situation, options=()):
    rules, events = retrieve(situation, list(options))
    prompt = PROMPT.format(
        rules="\n".join(f"{r.get('id')}: {r.get('condition')} → {r.get('tendency')} "
                        f"(예외: {r.get('exception')}; 뒤집힘: {r.get('flip')})" for r in rules),
        events="\n".join(f"{e['eid']}: {e['s']} → {e['c']} (이유: {e['r']})" for e in events) or "(없음)",
        situation=situation, options=" / ".join(options) or "(자유 선택)")
    for _ in range(3):
        raw = call(prompt)
        for m in reversed(list(re.finditer(r"\{.*\"선택\".*\}", raw))):
            try:
                d = json.loads(m.group(0))
                d["확신도"] = float(d.get("확신도", 0))
                return d
            except (ValueError, TypeError):
                continue
    return {"선택": "(예측 실패)", "근거": "", "확신도": 0.0, "반대로_고를_조건": "", "쓴_규칙": [], "쓴_사건": []}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--situation", required=True)
    ap.add_argument("--options", nargs="*", default=[])
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    print(json.dumps(decide(a.situation, a.options), ensure_ascii=False))


if __name__ == "__main__":
    main()
