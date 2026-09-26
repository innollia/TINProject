"""Icon sheet: every built icon, 16 per row, in list order (added in g01).

    py -3 -B icon_sheet.py [--cols 16] [--cell 128]

Writes ../output/_sheet/g01_icons_sheet.png (transparent, cell x cell per icon) and
g01_icons_sheet.json (cell index -> asset, stage).  Order = gen_icons.ICONS.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from gen_icons import ICONS  # noqa: E402

JOB = Path(__file__).resolve().parents[1]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--cols", type=int, default=16)
    ap.add_argument("--cell", type=int, default=128)
    args = ap.parse_args()
    items = []
    for stage, asset, _note, _fn in ICONS:
        png = JOB / "output" / asset / f"{asset}.png"
        if png.exists():
            items.append((stage, asset, png))
    if not items:
        print("no icons built yet")
        return 1
    cols, cell = args.cols, args.cell
    rows = (len(items) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * cell, rows * cell), (0, 0, 0, 0))
    index = []
    for i, (stage, asset, png) in enumerate(items):
        im = Image.open(png).convert("RGBA")
        if im.size != (cell, cell):
            im = im.resize((cell, cell), Image.Resampling.LANCZOS)
        x, y = (i % cols) * cell, (i // cols) * cell
        sheet.alpha_composite(im, (x, y))
        index.append({"cell": i, "col": i % cols, "row": i // cols, "asset": asset, "stage": stage})
    out = JOB / "output" / "_sheet"
    out.mkdir(parents=True, exist_ok=True)
    sheet.save(out / "g01_icons_sheet.png")
    meta = {"status": "candidate", "approval": "not approved - only the user approves", "cell": [cell, cell],
            "cols": cols, "rows": rows, "count": len(items), "cells": index}
    (out / "g01_icons_sheet.json").write_text(json.dumps(meta, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(out / "g01_icons_sheet.png", sheet.size, len(items))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
