"""스킬 폴더를 에이전트의 스킬 위치로 복사하고, 데이터 폴더 위치를 data_dir.txt에 적는다.

  python install.py --codex        → ~/.agents/skills/avatar-jev   (Codex 사용자 스킬 위치)
  python install.py --codex-old    → $CODEX_HOME/skills/avatar-jev (예전 Codex, 기본 ~/.codex/skills)
  python install.py --kiro         → ~/.kiro/crew/skills/avatar-jev
  python install.py --dest <폴더>  → <폴더>/avatar-jev
  --data <경로>                     데이터 폴더(기본: 지금 이 스킬이 찾은 곳)
같은 이름 폴더가 있으면 파일을 덮어쓴다(지우지 않는다). 스킬을 고친 뒤에는 다시 돌린다.
"""
import argparse
import os
import shutil
import sys

import jevlib

HOME = os.path.expanduser("~")
TARGETS = {
    "codex": os.path.join(HOME, ".agents", "skills"),
    "codex_old": os.path.join(os.environ.get("CODEX_HOME", os.path.join(HOME, ".codex")), "skills"),
    "kiro": os.path.join(HOME, ".kiro", "crew", "skills"),
}
IGNORE = shutil.ignore_patterns("__pycache__", "*.result.json", "data_dir.txt", ".gitignore")


def install(root, data):
    dst = os.path.join(root, os.path.basename(jevlib.SKILL))
    if os.path.abspath(dst) == os.path.abspath(jevlib.SKILL):
        return dst + " (원본 폴더라 건너뜀)"
    shutil.copytree(jevlib.SKILL, dst, ignore=IGNORE, dirs_exist_ok=True)
    with open(os.path.join(dst, "data_dir.txt"), "w", encoding="utf-8") as f:
        f.write(data)
    return dst


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("--codex", action="store_true")
    ap.add_argument("--codex-old", action="store_true")
    ap.add_argument("--kiro", action="store_true")
    ap.add_argument("--dest")
    ap.add_argument("--data", default=None)
    a = ap.parse_args()
    data = os.path.abspath(a.data or jevlib.data_dir())
    if not os.path.exists(os.path.join(data, "decision", "judgment_model.json")):
        print("warning: no decision/judgment_model.json in", data)
    roots = [TARGETS[k] for k in ("codex", "codex_old", "kiro") if getattr(a, k)]
    if a.dest:
        roots.append(a.dest)
    if not roots:
        ap.error("--codex, --codex-old, --kiro, --dest 중 하나 이상")
    for root in roots:
        print("installed:", install(root, data))
    print("data dir:", data)


if __name__ == "__main__":
    main()
