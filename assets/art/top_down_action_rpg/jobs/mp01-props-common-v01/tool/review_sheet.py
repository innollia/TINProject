"""Review sheet: lay rendered PNGs out on the floor colour at several scales.

    py -3 -B review_sheet.py --out ../preview/sheet_player.png ../output/player/*.png
    py -3 -B review_sheet.py --scales 2,1,0.5 --bg "#b3a8b7" --out sheet.png a.png b.png

Each row is one scale (0.5 = the in-game 1280x720 size of a 2x source).  Files
ending in _shadow.png are drawn under their sprite, not as separate cells.
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
    args = ap.parse_args()

    paths = []
    for pattern in args.files:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    paths = [Path(p) for p in paths if not p.endswith("_shadow.png")]
    scales = [float(s) for s in args.scales.split(",")]
    images = [Image.open(p).convert("RGBA") for p in paths]
    shadows = []
    for p in paths:
        sp = p.with_name(p.stem + "_shadow.png")
        shadows.append(Image.open(sp).convert("RGBA") if sp.exists() else None)
    label_font = font(13)
    gap = args.gap
    row_h = [int(max(im.height for im in images) * s) + gap + 18 for s in scales]
    measure = ImageDraw.Draw(Image.new("RGB", (1, 1)))  # mp01: columns wide enough for their labels
    col_w = [max(int(im.width * max(scales)), 90,
                 max(int(measure.textlength(f"{p.stem} x{s:g}", font=label_font)) + 6 for s in scales)) + gap
             for im, p in zip(images, paths)]
    sheet = Image.new("RGBA", (sum(col_w) + gap, sum(row_h) + gap), args.bg)
    draw = ImageDraw.Draw(sheet)
    y = gap
    for s, rh in zip(scales, row_h):
        x = gap
        for im, sh, p, cw in zip(images, shadows, paths, col_w):
            size = (max(1, int(im.width * s)), max(1, int(im.height * s)))
            resample = Image.Resampling.NEAREST if s >= 2 else Image.Resampling.LANCZOS
            if sh is not None:
                sheet.alpha_composite(sh.resize(size, resample), (x, y))
            sheet.alpha_composite(im.resize(size, resample), (x, y))
            draw.text((x, y + size[1] + 2), f"{p.stem} x{s:g}", fill="#2a1a2e", font=label_font)
            x += cw
        y += rh
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
