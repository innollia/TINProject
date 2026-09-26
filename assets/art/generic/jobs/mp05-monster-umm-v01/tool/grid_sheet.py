"""mp05 addition: lay many sprites out in a grid (one cell each), centred on their pivots.

    py -3 -B grid_sheet.py --cols 4 --scale 0.5 --out ../preview/sheet_all_0.5x.png ../output/*/*.png

Cells are sized to the largest canvas; each sprite's pivot (from its .json) sits on the
cell centre, with its _shadow.png underneath. Captions (file names) are review labels only.
"""

from __future__ import annotations

import argparse
import glob
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def font(size: int):
    for name in ("malgun.ttf", "arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--cols", type=int, default=4)
    ap.add_argument("--scale", type=float, default=0.5)
    ap.add_argument("--bg", default="#57505c")
    args = ap.parse_args()
    paths = []
    for pattern in args.files:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    paths = [Path(p) for p in paths if not p.endswith(("_shadow.png", "_emit.png"))]
    s = args.scale
    images = [Image.open(p).convert("RGBA") for p in paths]
    cw = int(max(im.width for im in images) * s) + 16
    ch = int(max(im.height for im in images) * s) + 8
    cap = int(22 * max(s, 0.5) / 0.5)
    rows = (len(images) + args.cols - 1) // args.cols
    sheet = Image.new("RGBA", (args.cols * cw + 16, rows * (ch + cap) + 16), args.bg)
    draw = ImageDraw.Draw(sheet)
    f = font(int(13 * max(s, 0.5) / 0.5))
    for i, (p, im) in enumerate(zip(paths, images)):
        x0, y0 = 8 + (i % args.cols) * cw, 8 + (i // args.cols) * (ch + cap)
        man = p.with_suffix(".json")
        pivot = json.loads(man.read_text(encoding="utf-8")).get("pivot") if man.exists() else None
        px, py = pivot or (im.width / 2.0, im.height / 2.0)
        size = (max(1, round(im.width * s)), max(1, round(im.height * s)))
        pos = (round(x0 + cw / 2.0 - px * s), round(y0 + ch / 2.0 - py * s))
        shadow = p.with_name(p.stem + "_shadow.png")
        if shadow.exists():
            sheet.alpha_composite(Image.open(shadow).convert("RGBA").resize(size, Image.Resampling.LANCZOS), pos)
        sheet.alpha_composite(im.resize(size, Image.Resampling.LANCZOS), pos)
        draw.text((x0 + cw / 2.0, y0 + ch + cap / 2.0 - 2), p.stem, fill="#ddd4e2", font=f, anchor="mm")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
