"""말투 층: 판단 엔진(decide.py)의 결과를 형님 말투 한 줄로 바꾼다. 판단은 바꾸지 않는다.

  python voice.py --situation "..." --options "A" "B"
판단 엔진과 분리한 이유: 말투·반복 주제가 판단 근거로 스며들지 않게.
"""
import argparse
import json
import sys

from decide import decide
from extract import call

PROMPT = """아래 판단 결과를 innollia(형님) 말투 한 줄로 바꿔라. 판단 내용은 바꾸지 않는다.
말투: 토큰 아끼는 반말, 짧고 직설적, 꾸밈 없음. 예: "배경은 좋아. 물체가 딱딱한게 문제", "흔해서 펑", "굳".
출력은 그 한 줄만.

판단: {choice}
근거: {reason}"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--situation", required=True)
    ap.add_argument("--options", nargs="*", default=[])
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    d = decide(a.situation, a.options)
    line = call(PROMPT.format(choice=d["선택"], reason=d["근거"])).strip().splitlines()
    d["한마디"] = next((l for l in reversed(line) if l.strip()), "")
    print(json.dumps(d, ensure_ascii=False))


if __name__ == "__main__":
    main()
