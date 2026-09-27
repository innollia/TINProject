"""Check every built cell: size, transparency, clipping and empty corners.

    py -3 -B tool/check_cells.py

For each frame: reads the manifest, verifies the png size matches it, reports
the alpha bounding box, flags pixels painted within 3 px of a cell edge
(art cut off by the frame) and reports how much of each of the four corner
quadrants is painted.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

JOB = Path(__file__).resolve().parents[1]
OUT = JOB / "output"
EDGE = 3          # px of the cell edge treated as "touching the frame"
CORNER = 0.15     # corner quadrant as a fraction of the cell


def main() -> int:
    bad = 0
    for asset_dir in sorted(p for p in OUT.iterdir() if p.is_dir()):
        if asset_dir.name == "sheets":
            continue
        rows = []
        for png in sorted(asset_dir.glob("f*.png")):
            if png.name.endswith(("_emit.png", "_shadow.png")):
                continue
            man = json.loads((asset_dir / f"{png.stem}.json").read_text(encoding="utf-8"))
            im = Image.open(png)
            a = np.asarray(im.convert("RGBA"), dtype=np.uint8)[:, :, 3]
            size = list(im.size)
            if size != man["size"]:
                print(f"  !! {asset_dir.name}/{png.stem}: png {size} != manifest {man['size']}")
                bad += 1
            if im.mode != "RGBA":
                print(f"  !! {asset_dir.name}/{png.stem}: mode {im.mode}, expected RGBA")
                bad += 1
            ys, xs = np.nonzero(a > 4)
            if len(xs) == 0:
                print(f"  !! {asset_dir.name}/{png.stem}: empty cell")
                bad += 1
                continue
            h, w = a.shape
            box = (int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max()))
            touch = [n for n, ok in (("L", box[0] < EDGE), ("T", box[1] < EDGE),
                                     ("R", box[2] > w - 1 - EDGE), ("B", box[3] > h - 1 - EDGE)) if ok]
            cw, ch = int(w * CORNER), int(h * CORNER)
            cover = {}
            for name, sl in (("TL", (slice(0, ch), slice(0, cw))), ("TR", (slice(0, ch), slice(w - cw, w))),
                             ("BL", (slice(h - ch, h), slice(0, cw))), ("BR", (slice(h - ch, h), slice(w - cw, w)))):
                blk = a[sl]
                cover[name] = float((blk > 16).mean())
            corner_hit = [k for k, v in cover.items() if v > 0.06]
            rows.append((png.stem, size, box, touch, corner_hit,
                         float(a.max()) / 255.0, man.get("emit_file")))
        if not rows:
            continue
        name = asset_dir.name
        n = len(rows)
        sizes = {tuple(r[1]) for r in rows}
        emits = sum(1 for r in rows if r[6])
        touch_all = {k for r in rows for k in r[3]}
        corner_all = {k for r in rows for k in r[4]}
        print(f"{name:22s} {n} frames {sorted(sizes)} emit={emits}")
        for r in rows:
            flags = []
            if r[3]:
                flags.append("edge:" + "".join(r[3]))
            if r[4]:
                flags.append("corner:" + ",".join(r[4]))
            if flags:
                print(f"    {r[0]}: bbox={r[2]} {' '.join(flags)}")
    print("problems:", bad)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
