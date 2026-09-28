"""판단 엔진: 상황을 넣으면 형님이 고를 선택을 예측한다(말투 없음, JSON만).

  python decide.py --situation "..." --options "A안" "B안"
  python decide.py --verdict --situation "결과물 설명"      # 결과물 통과/퇴짜 판정
출력: {"선택", "근거", "확신도"(0~1), "반대로_고를_조건", "쓴_규칙", "쓴_사건", "_engine"}
기억은 세 층으로 읽는다: 판단 규칙(요약) → 분야별 사건 목록(중간) → 원문 묶음(세부, 필요할 때만).

Jev 키가 먹히면 Jev 한 번 호출로 판정한다.
  선택지가 2개 이상: choice로 선택지를 고르고 확률을 받는다.
  결과물 판정(verdict): noul로 통과 확률, score로 5단계 점수(0~100으로 폄).
  같은 호출에 '이 규칙이 이 상황에 들어맞나'(noul)를 규칙마다 붙이고, 들어맞는 규칙으로 근거와 뒤집힘 조건을 채운다.
선택지 없는 자유 선택은 Jev가 못 하므로 LLM이 맡는다. Jev가 없거나 실패해도 LLM이 같은 모양으로 답한다.
어느 쪽이 답했는지는 _engine에 남는다.
"""
import argparse
import json
import os
import re
import sys

from extract import RAW, call
import jev

HERE = os.path.dirname(os.path.abspath(__file__))
TOP_EVENTS = 25
FIT_RULES = 8


def load_model():
    """판단 규칙을 읽는다. 모델이 규칙 대신 사건 id 같은 글을 넣은 줄은 버리고, 강도·근거·충돌 칸 모양을 맞춘다."""
    m = json.load(open(os.path.join(HERE, "judgment_model.json"), encoding="utf-8"))
    out = {}
    for d, rs in m.items():
        keep = []
        for r in rs:
            if not (isinstance(r, dict) and r.get("condition")):
                continue
            try:
                r["strength"] = float(r.get("strength", 1))
            except (TypeError, ValueError):
                r["strength"] = 1.0
            for k in ("evidence", "conflicts_with"):
                v = r.get(k) or []
                r[k] = v if isinstance(v, list) else [v]
            keep.append(r)
        out[d] = keep
    return out


def _state_text(situation, options, rules, events):
    """Jev에 넘길 판단 근거 state를 한 덩어리 글로 만든다."""
    parts = ["[형님 판단 규칙]"]
    parts += [f"- {r.get('condition')} → {r.get('tendency')} "
              f"(예외: {r.get('exception') or '-'}; 뒤집힘: {r.get('flip') or '-'})" for r in rules]
    parts += ["", "[비슷한 과거 판정]"]
    parts += [f"- {e['s']} → {e['c']} (이유: {e['r']})" for e in events] or ["- (없음)"]
    parts += ["", "[판정할 대상/상황]", situation]
    if options:
        parts += ["선택지: " + " / ".join(options)]
    return "\n".join(parts)


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
    model = load_model()
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
            hit = top_ids & set(map(str, r["evidence"]))
            rules.append((len(hit), r["strength"], d, r))
    rules.sort(key=lambda x: (-x[0], -x[1]))
    return [r for *_, r in rules[:40]], [e for _, _, e in top]


def _decide_jev(situation, options, rules, events, verdict):
    """Jev 한 번 호출로 선택(또는 통과/점수)과 '어느 규칙이 들어맞나'를 함께 묻는다. 실패하면 None."""
    cand = rules[:FIT_RULES]
    qs = {f"fit{i}": {"type": "noul",
                      "instructions": "이 판단 규칙이 [판정할 대상/상황]에 들어맞나? 규칙: "
                                      f"{r.get('condition')} → {r.get('tendency')}"}
          for i, r in enumerate(cand)}
    if len(options) >= 2:
        qs["pick"] = {"type": "choice",
                      "instructions": "innollia(형님)가 [판정할 대상/상황]에서 고를 선택지. "
                                      "[형님 판단 규칙]과 [비슷한 과거 판정]을 근거로 고른다.",
                      "criteria": {o: None for o in options}}
    else:
        qs.update(jev.VERDICT_QUESTIONS)
    ans = jev.ask(_state_text(situation, options, rules, events), qs)
    if not ans:
        return None
    fits = sorted(((float((ans.get(f"fit{i}") or {}).get("noul", 0.0)), r) for i, r in enumerate(cand)),
                  key=lambda x: -x[0])
    used = [r for p, r in fits if p >= 0.5][:3] or [r for _, r in fits[:1]]
    out = {
        "근거": " / ".join(f"{r.get('condition')} → {r.get('tendency')}" for r in used),
        "반대로_고를_조건": " / ".join(r.get("flip") for r in used if r.get("flip")),
        "쓴_규칙": [r.get("id") for r in used],
        "쓴_사건": [e["eid"] for e in events[:10]],
        "_engine": "jev",
        "_jev_fit": [[r.get("id"), round(p, 3)] for p, r in fits],
    }
    if "pick" in qs:
        pk = ans.get("pick") or {}
        out.update({"선택": pk.get("choice", ""), "확신도": float(pk.get("confidence", 0.0)),
                    "_jev_probs": pk.get("probabilities", {})})
    else:
        out.update(jev.read_verdict(ans))
    return out


def decide(situation, options=(), verdict=False):
    options = [o for o in dict.fromkeys(str(o).strip() for o in options) if o]
    rules, events = retrieve(situation, options)
    tried_jev = jev.available() and (len(options) >= 2 or verdict)
    if tried_jev:
        d = _decide_jev(situation, options, rules, events, verdict)
        if d:
            return d
    prompt = PROMPT.format(
        rules="\n".join(f"{r.get('id')}: {r.get('condition')} → {r.get('tendency')} "
                        f"(예외: {r.get('exception')}; 뒤집힘: {r.get('flip')})" for r in rules),
        events="\n".join(f"{e['eid']}: {e['s']} → {e['c']} (이유: {e['r']})" for e in events) or "(없음)",
        situation=situation,
        options=" / ".join(options) or ("통과 / 퇴짜" if verdict else "(자유 선택)"))
    for _ in range(3):
        raw = call(prompt)
        for m in reversed(list(re.finditer(r"\{.*\"선택\".*\}", raw))):
            try:
                d = json.loads(m.group(0))
                d["확신도"] = float(d.get("확신도", 0))
            except (ValueError, TypeError):
                continue
            d["_engine"] = "llm"
            if tried_jev and jev.LAST_ERROR:
                d["_jev_error"] = jev.LAST_ERROR
            return d
    return {"선택": "(예측 실패)", "근거": "", "확신도": 0.0, "반대로_고를_조건": "", "쓴_규칙": [], "쓴_사건": [],
            "_engine": "llm"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--situation", required=True)
    ap.add_argument("--options", nargs="*", default=[])
    ap.add_argument("--verdict", action="store_true", help="결과물 통과/퇴짜 판정")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    print(json.dumps(decide(a.situation, a.options, a.verdict), ensure_ascii=False))


if __name__ == "__main__":
    main()
