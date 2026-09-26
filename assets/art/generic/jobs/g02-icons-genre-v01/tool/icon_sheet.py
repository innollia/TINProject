"""Pack icons into an RPG-Maker style icon sheet: 16 icons per row, 128 px cells.

    py -3 -B icon_sheet.py --out ../output/iconset_g02_genre.png [--preview ../preview/iconset_on_dark.png] ids...

Writes the transparent sheet plus <out>.json (index -> asset id, row, column).
Missing icons leave an empty cell so indices stay stable.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

JOB = Path(__file__).resolve().parents[1]
CELL, COLS = 128, 16


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("ids", nargs="+")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--preview", type=Path, default=None)
    ap.add_argument("--bg", default="#3b3542")
    args = ap.parse_args()
    rows = (len(args.ids) + COLS - 1) // COLS
    sheet = Image.new("RGBA", (COLS * CELL, rows * CELL), (0, 0, 0, 0))
    index = []
    for i, iid in enumerate(args.ids):
        png = JOB / "output" / iid / f"{iid}.png"
        r, c = divmod(i, COLS)
        entry = {"index": i, "id": iid, "row": r, "col": c, "present": png.exists()}
        if png.exists():
            sheet.alpha_composite(Image.open(png).convert("RGBA"), (c * CELL, r * CELL))
        index.append(entry)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.out)
    meta = {"cell": CELL, "columns": COLS, "status": "candidate", "icons": index}
    args.out.with_suffix(".json").write_text(json.dumps(meta, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    if args.preview:
        bg = Image.new("RGBA", sheet.size, args.bg)
        bg.alpha_composite(sheet)
        args.preview.parent.mkdir(parents=True, exist_ok=True)
        bg.convert("RGB").save(args.preview)
    print(args.out, sheet.size, sum(e["present"] for e in index), "icons")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
