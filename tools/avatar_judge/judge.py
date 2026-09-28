"""형님 분신 검수관: 이미지나 글을 넣으면 한 줄 평 + 통과/퇴짜 + 점수를 낸다.

새 구조(형님 제안 5번: 판단 엔진과 말투 층 분리, Jev 지원):
  이미지/글 → (이미지면) LLM 묘사 → decide.py(Jev 있으면 Jev, 없으면 LLM 판정)
            → voice.py 말투 한 줄
Jev(TypeSafe System One)는 글을 못 만들므로 통과/퇴짜/점수만 맡고, 말투는 LLM이 붙인다.
이미지는 Jev가 state로 텍스트만 받으므로, 먼저 LLM으로 그림을 묘사해 넣는다.

사용 예
  python judge.py --image C:/path/shot.png --desc "07 레벨 캡처"
  python judge.py --text "새 기획안: ..."
  python judge.py --file plan.md
"""
import argparse
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "decision"))
from decide import decide          # noqa: E402  Jev 우선, 없으면 LLM
from extract import call           # noqa: E402
import jev                         # noqa: E402

DESCRIBE = """아래 이미지를 판정용으로 객관 묘사만 해라. 좋다/나쁘다 평가는 하지 마라.
- 무엇이 그려졌나(생물이면 몸 구조·다리 수·실루엣, 화면이면 오브젝트·배경·UI)
- 움직임 단서(정지 캡처면 도형처럼 딱딱한지 / 관절·물리가 보이는지)
- 색·구도·완성도
이미지 경로(직접 열어 볼 것): {image}
추가 설명: {desc}
출력은 묘사 문단 하나."""

VOICE = """아래 판단 결과를 innollia(형님) 말투 한 줄로 바꿔라. 판단 내용은 바꾸지 않는다.
말투: 토큰 아끼는 반말, 짧고 직설적. 예: "배경은 좋아. 물체가 딱딱한게 문제", "흔해서 펑", "굳".
출력은 그 한 줄만.
판단: {choice}
근거: {reason}"""


def voice_line(choice, reason):
    lines = call(VOICE.format(choice=choice, reason=reason)).strip().splitlines()
    return next((l for l in reversed(lines) if l.strip()), "")


def judge(target_text, image=None, desc=""):
    target = target_text or ""
    if image:
        # Jev도 LLM 판정도 이미지 자체는 텍스트 state가 필요하므로 먼저 묘사한다.
        target = (call(DESCRIBE.format(image=image, desc=desc or target_text or "")).strip()
                  + (f"\n(원래 설명: {target_text})" if target_text else ""))
    d = decide(target, verdict=True)
    verdict = "통과" if d.get("선택") == "통과" else "퇴짜"
    score = d.get("점수")
    if score is None:  # LLM 폴백 경로는 점수를 따로 안 냄 → 확신도로 대략 환산
        score = int(round(d.get("확신도", 0) * 100)) if verdict == "통과" else int(round((1 - d.get("확신도", 0)) * 40))
    return {
        "한줄평": voice_line(d.get("선택", verdict), d.get("근거", "")),
        "판정": verdict,
        "점수": score,
        "확신도": d.get("확신도"),
        "엔진": d.get("_engine", "jev" if jev.available() else "llm"),
        "반대로_고를_조건": d.get("반대로_고를_조건", ""),
        "쓴_규칙": d.get("쓴_규칙", []),
        "쓴_사건": d.get("쓴_사건", []),
        "묘사": target if image else None,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image")
    ap.add_argument("--desc", default="")
    ap.add_argument("--text")
    ap.add_argument("--file")
    a = ap.parse_args()
    text = a.text or a.desc
    if a.file:
        with open(a.file, encoding="utf-8") as f:
            text = (text + "\n" if text else "") + f.read()
    if not text and not a.image:
        ap.error("--image, --text, --file 중 하나는 필요하다")
    sys.stdout.reconfigure(encoding="utf-8")
    print(json.dumps(judge(text, a.image, a.desc), ensure_ascii=False))


if __name__ == "__main__":
    main()
