"""Review sheet: lay rendered PNGs out on the floor colour at several scales.

    py -3 -B review_sheet.py --out ../preview/sheet_player.png ../output/player/*.png
    py -3 -B review_sheet.py --scales 2,1,0.5 --bg "#b3a8b7" --out sheet.png a.png b.png
    py -3 -B review_sheet.py --cols 8 --scales 0.5 --out sheet.png ../output/*/*.png   (g02: grid)

Each row is one scale (0.5 = the in-game 1280x720 size of a 2x source).  Files
ending in _shadow.png are drawn under their sprite, not as separate cells;
_emit.png files are skipped (they are a separate game layer).
g02 addition: ``--cols N`` wraps the cells into rows of N (one block per scale),
so 5-10 characters with several frames fit on one readable sheet.
"""

from __future__ import annotations

import argparse
import glob
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def font(size: int):
    for name in ("arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--scales", default="1,0.5")
    ap.add_argument("--bg", default="#b3a8b7")
    ap.add_argument("--gap", type=int, default=16)
    ap.add_argument("--cols", type=int, default=0)
    ap.add_argument("--label", default="#2a1a2e")
    args = ap.parse_args()

    paths = []
    for pattern in args.files:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    paths = [Path(p) for p in paths if not (p.endswith("_shadow.png") or p.endswith("_emit.png"))]
    scales = [float(s) for s in args.scales.split(",")]
    images = [Image.open(p).convert("RGBA") for p in paths]
    shadows = []
    for p in paths:
        sp = p.with_name(p.stem + "_shadow.png")
        shadows.append(Image.open(sp).convert("RGBA") if sp.exists() else None)
    label_font = font(13)
    gap = args.gap
    cols = args.cols if args.cols > 0 else len(images)
    rows = (len(images) + cols - 1) // cols
    smax = max(scales)
    cell_w = max(max(int(im.width * smax), 90) for im in images) + gap
    blocks = []
    for s in scales:
        cell_h = int(max(im.height for im in images) * s) + gap + 18
        blocks.append((s, cell_h))
    width = cols * cell_w + gap if args.cols > 0 else sum(max(int(im.width * smax), 90) + gap for im in images) + gap
    height = sum(rows * ch for _, ch in blocks) + gap
    sheet = Image.new("RGBA", (width, height), args.bg)
    draw = ImageDraw.Draw(sheet)
    y0 = gap
    for s, ch in blocks:
        x = gap
        for i, (im, sh, p) in enumerate(zip(images, shadows, paths)):
            if args.cols > 0:
                x = gap + (i % cols) * cell_w
                y = y0 + (i // cols) * ch
            else:
                y = y0
            size = (max(1, int(im.width * s)), max(1, int(im.height * s)))
            resample = Image.Resampling.NEAREST if s >= 2 else Image.Resampling.LANCZOS
            if sh is not None:
                sheet.alpha_composite(sh.resize(size, resample), (x, y))
            sheet.alpha_composite(im.resize(size, resample), (x, y))
            name = p.stem if p.parent.name in p.stem else f"{p.parent.name}/{p.stem}"
            draw.text((x, y + size[1] + 2), f"{name} x{s:g}", fill=args.label, font=label_font)
            if args.cols <= 0:
                x += max(int(im.width * smax), 90) + gap
        y0 += rows * ch if args.cols > 0 else ch
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
