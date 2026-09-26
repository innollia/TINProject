"""mp05 addition: report how close each sprite's painted pixels come to the canvas edge.

    py -3 -B check_edges.py ../output/enemy_*/*.png

Prints size, alpha bbox and the smallest margin per file; ``CUT`` when paint touches
the edge (margin 0), ``TIGHT`` when a margin is under --safe px (default 32).
Files ending in _shadow.png / _emit.png are skipped.
"""

from __future__ import annotations

import argparse
import glob
from pathlib import Path

from PIL import Image


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--safe", type=int, default=32)
    args = ap.parse_args()
    paths = []
    for pattern in args.files:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    bad = 0
    for p in paths:
        if p.endswith(("_shadow.png", "_emit.png")):
            continue
        im = Image.open(p).convert("RGBA")
        box = im.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
        if box is None:
            print(f"EMPTY {p}")
            bad += 1
            continue
        w, h = im.size
        margins = {"left": box[0], "top": box[1], "right": w - box[2], "bottom": h - box[3]}
        low = min(margins.values())
        flag = "CUT  " if low <= 0 else ("TIGHT" if low < args.safe else "ok   ")
        bad += flag != "ok   "
        print(f"{flag} {Path(p).parent.name}/{Path(p).name} {w}x{h} bbox={box} margins={margins}")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
