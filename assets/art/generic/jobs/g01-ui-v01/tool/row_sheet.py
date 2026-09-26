"""Row sheets: frames of one asset side by side, in recipe frame order (added in g01).

    py -3 -B row_sheet.py [--only asset_a,asset_b]

For every recipe in ../recipes with two or more frames, writes
../output/<asset>/<asset>_sheet.png (transparent, one row, frame size cells) and
<asset>_sheet.json (cell -> frame).  An _emit sheet is written too when frames have one.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]
SKIP = ("_", "palette_", "scene_")


def row(paths, size):
    sheet = Image.new("RGBA", (size[0] * len(paths), size[1]), (0, 0, 0, 0))
    for i, p in enumerate(paths):
        if p is not None and p.exists():
            sheet.alpha_composite(Image.open(p).convert("RGBA"), (i * size[0], 0))
    return sheet


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    for rp in sorted((JOB / "recipes").glob("*.json")):
        if rp.name.startswith(SKIP):
            continue
        rec = json.loads(rp.read_text(encoding="utf-8"))
        asset = rec.get("asset", rp.stem)
        frames = rec.get("frames") or []
        if len(frames) < 2 or (only and asset not in only):
            continue
        out = JOB / "output" / asset
        pngs = [out / f"{f['name']}.png" for f in frames]
        if not all(p.exists() for p in pngs):
            print(f"skip {asset}: not all frames built")
            continue
        size = tuple(rec["canvas"])
        row(pngs, size).save(out / f"{asset}_sheet.png")
        emits = [out / f"{f['name']}_emit.png" for f in frames]
        if any(p.exists() for p in emits):
            row(emits, size).save(out / f"{asset}_sheet_emit.png")
        meta = {"asset": asset, "status": "candidate", "approval": "not approved - only the user approves",
                "cell": list(size), "count": len(frames), "cells": [f["name"] for f in frames]}
        (out / f"{asset}_sheet.json").write_text(json.dumps(meta, indent=1) + "\n", encoding="utf-8")
        print(f"sheet {asset} {len(frames)} x {size}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
