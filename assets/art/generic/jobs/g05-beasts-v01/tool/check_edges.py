"""Check rendered frames for edge clipping and report their painted bounds.

    py -3 -B check_edges.py                # every output/<asset>/<frame>.png
    py -3 -B check_edges.py slime orc      # only these assets

A frame FAILS when painted pixels (alpha > 8) touch the outer ``--margin`` px
of the canvas (head, tail or wing cut off).  Shadow and emit layers are checked
the same way.  Exit code 1 when anything fails.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image

JOB = Path(__file__).resolve().parents[1]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("assets", nargs="*")
    ap.add_argument("--margin", type=int, default=3)
    args = ap.parse_args()
    out = JOB / "output"
    dirs = [out / a for a in args.assets] if args.assets else sorted(p for p in out.iterdir() if p.is_dir())
    bad = 0
    for d in dirs:
        for png in sorted(d.glob("*.png")):
            a = np.asarray(Image.open(png).convert("RGBA"))[..., 3]
            ys, xs = np.nonzero(a > 8)
            if len(xs) == 0:
                print(f"EMPTY {d.name}/{png.name}")
                bad += 1
                continue
            h, w = a.shape
            x0, y0, x1, y1 = xs.min(), ys.min(), xs.max(), ys.max()
            m = args.margin
            edge = [n for n, hit in (("left", x0 < m), ("top", y0 < m), ("right", x1 >= w - m), ("bottom", y1 >= h - m)) if hit]
            status = "EDGE " + ",".join(edge) if edge else "ok"
            if edge:
                bad += 1
            print(f"{status:<18} {d.name}/{png.name} canvas={w}x{h} bbox=({x0},{y0})-({x1},{y1})")
    print("failed:", bad)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
