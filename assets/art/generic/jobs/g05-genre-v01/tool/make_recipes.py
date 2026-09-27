"""Write recipes/<asset>.json from the Python creature definitions in g05kit/<module>.py.

    py -3 -B make_recipes.py fantasy                 # every creature in g05kit/fantasy.py
    py -3 -B make_recipes.py fantasy --only slime,orc
    py -3 -B make_recipes.py fantasy --list

A recipe is only rewritten when its content changed, so build.py's resume
check (recipe hash in the build key) keeps finished frames.
"""

from __future__ import annotations

import argparse
import importlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from g05kit import kit  # noqa: E402

JOB = Path(__file__).resolve().parents[1]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("module", help="g05kit module name, e.g. fantasy")
    ap.add_argument("--only", default="", help="comma separated asset ids")
    ap.add_argument("--priority", default="", help="only these priorities, e.g. A or B,C")
    ap.add_argument("--list", action="store_true")
    args = ap.parse_args()
    importlib.import_module(f"g05kit.{args.module}")
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    pris = {s.strip() for s in args.priority.split(",") if s.strip()}
    out_dir = JOB / "recipes"
    out_dir.mkdir(parents=True, exist_ok=True)
    for asset, (fn, pri) in kit.REGISTRY.items():
        if only and asset not in only:
            continue
        if pris and pri not in pris:
            continue
        if args.list:
            print(pri, asset)
            continue
        c = fn()
        rec = c.recipe()
        rec["g05"]["priority"] = pri
        text = json.dumps(rec, indent=1, ensure_ascii=False) + "\n"
        path = out_dir / f"{asset}.json"
        if path.exists() and path.read_text(encoding="utf-8") == text:
            print("same ", path.name)
            continue
        path.write_text(text, encoding="utf-8")
        print("wrote", path.name, f"forms={len(rec['forms'])} frames={len(rec['frames'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
