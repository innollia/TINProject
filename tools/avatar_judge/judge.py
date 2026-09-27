"""형님 분신 검수관: 이미지나 글을 넣으면 한 줄 평 + 통과/퇴짜 + 점수를 낸다.

사용 예
  python judge.py --image C:/path/shot.png --desc "07 레벨 캡처"
  python judge.py --text "새 기획안: ..."
  python judge.py --file plan.md
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
MODEL = os.environ.get("AVATAR_JUDGE_MODEL", "claude-sonnet-5")
KIRO = os.environ.get("KIRO_CLI", "kiro-cli")
ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")


def load_judgments():
    with open(os.path.join(HERE, "judgments.jsonl"), encoding="utf-8") as f:
        return [json.loads(line) for line in f if line.strip()]


def is_holdout(jid):
    return int(hashlib.sha1(jid.encode()).hexdigest(), 16) % 8 < 3


def format_example(j):
    word = "통과" if j["verdict"] == "pass" else "퇴짜"
    return f"- 대상: {j['target']}\n  형님: \"{j['quote']}\" → {word} ({j['reason']})"


def build_prompt(target, exclude_ids=()):
    with open(os.path.join(HERE, "judge_prompt.md"), encoding="utf-8") as f:
        template = f.read()
    with open(os.path.join(HERE, "taste_profile.md"), encoding="utf-8") as f:
        profile = f.read()
    examples = [
        format_example(j)
        for j in load_judgments()
        if not is_holdout(j["id"]) and j["id"] not in exclude_ids
    ]
    return (
        template.replace("{{PROFILE}}", profile)
        .replace("{{EXAMPLES}}", "\n".join(examples))
        .replace("{{TARGET}}", target)
    )


def call_model(prompt, timeout=300):
    cmd = [KIRO, "chat", "--no-interactive", "--model", MODEL,
           "--trust-tools=fs_read,read", prompt]
    out = subprocess.run(cmd, capture_output=True, timeout=timeout,
                         encoding="utf-8", errors="replace")
    return ANSI.sub("", (out.stdout or "") + "\n" + (out.stderr or ""))


def parse(raw):
    for m in reversed(list(re.finditer(r"\{[^{}]*\"판정\"[^{}]*\}", raw))):
        try:
            d = json.loads(m.group(0))
            d["점수"] = int(d.get("점수", 0))
            return d
        except (ValueError, TypeError):
            continue
    return {"한줄평": "(해석 실패)", "판정": "퇴짜", "점수": 0, "raw": raw[-500:]}


def judge(target_text, image=None, exclude_ids=()):
    target = target_text or ""
    if image:
        target += f"\n이미지 경로(직접 열어 볼 것): {image}"
    prompt = build_prompt(target, exclude_ids)
    for _ in range(2):
        got = parse(call_model(prompt))
        if "raw" not in got:
            return got
    if image:
        got = parse(call_model(build_prompt(target_text or "", exclude_ids)))
        got["이미지"] = "못 봄(모델 오류로 글 설명만 보고 판정)"
    return got


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
    print(json.dumps(judge(text, a.image), ensure_ascii=False))


if __name__ == "__main__":
    main()
