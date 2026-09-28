"""모델·네트워크 호출 없이 판단 엔진과 Jev 경로를 확인한다.

  python -X utf8 test_offline.py
이 컴퓨터의 judgment_model.json과 raw/memory_index.json이 있어야 한다.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import decide  # noqa: E402
import extract  # noqa: E402
import jev  # noqa: E402


def fake_answers(state, qs, **kw):
    a = {k: {"type": "noul", "noul": 0.9 if k == "fit0" else 0.2} for k in qs if k.startswith("fit")}
    if "pick" in qs:
        opts = list(qs["pick"]["criteria"])
        a["pick"] = {"type": "choice", "choice": opts[1],
                     "probabilities": {opts[0]: 0.3, opts[1]: 0.7}, "confidence": 0.6}
    if "verdict" in qs:
        a["verdict"] = {"type": "noul", "noul": 0.8}
        a["score"] = {"type": "score", "score": 3.0, "confidence": 0.7}
    return a


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    model = decide.load_model()
    assert all(isinstance(r, dict) and r.get("condition") for rs in model.values() for r in rs)
    s = 'x [1, 2] {"a": 1} [{"condition": "c1"}, {"condition": "c2"}, "e-1"] [{"condition": "only"}] tail'
    assert len(extract.best_list(s, "condition")) == 2
    assert jev.read_verdict({"verdict": {"noul": 0.2}, "score": {"score": 4.0}})["점수"] == 100

    jev.KEY, jev._rejected = "test", False
    jev.ask = fake_answers
    d = decide.decide("밤새 코딩할까 잘까", ["코딩", "수면"])
    assert d["_engine"] == "jev" and d["선택"] == "수면" and d["확신도"] == 0.6 and d["쓴_규칙"], d
    v = decide.decide("회색 상자 시제품인데 핵심 동사가 새로움", verdict=True)
    assert v["_engine"] == "jev" and v["선택"] == "통과" and v["점수"] == 75, v
    jev.ask = lambda *a, **k: None
    rules, events = decide.retrieve("아무 상황", [])
    assert decide._decide_jev("아무 상황", ["A", "B"], rules, events, False) is None
    print(f"통과: 규칙 {sum(len(r) for r in model.values())}개, Jev 선택지·결과물 판정·실패 경로")


if __name__ == "__main__":
    main()
