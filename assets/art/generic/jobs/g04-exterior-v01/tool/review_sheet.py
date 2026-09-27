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
    ap.add_argument("--cols", type=int, default=0, help="g04: wrap cells into rows of N")
    args = ap.parse_args()

    paths = []
    for pattern in args.files:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    paths = [Path(p) for p in paths if not p.endswith(("_shadow.png", "_emit.png"))]
    scales = [float(s) for s in args.scales.split(",")]
    images = [Image.open(p).convert("RGBA") for p in paths]
    shadows = []
    for p in paths:
        sp = p.with_name(p.stem + "_shadow.png")
        shadows.append(Image.open(sp).convert("RGBA") if sp.exists() else None)
    label_font = font(13)
    gap = args.gap
    cols = args.cols if args.cols > 0 else len(images)
    groups = [list(range(i, min(i + cols, len(images)))) for i in range(0, len(images), cols)]
    col_w = [max(int(im.width * max(scales)), 90) + gap for im in images]
    blocks = []  # (scale, group) rows
    for grp in groups:
        for s in scales:
            blocks.append((s, grp, int(max(images[i].height for i in grp) * s) + gap + 18))
    width = max(sum(col_w[i] for i in grp) for grp in groups) + gap
    sheet = Image.new("RGBA", (width, sum(b[2] for b in blocks) + gap), args.bg)
    draw = ImageDraw.Draw(sheet)
    y = gap
    for s, grp, rh in blocks:
        x = gap
        for i in grp:
            im, sh, p, cw = images[i], shadows[i], paths[i], col_w[i]
            size = (max(1, int(im.width * s)), max(1, int(im.height * s)))
            resample = Image.Resampling.NEAREST if s >= 2 else Image.Resampling.LANCZOS
            if sh is not None:
                sheet.alpha_composite(sh.resize(size, resample), (x, y))
            sheet.alpha_composite(im.resize(size, resample), (x, y))
            draw.text((x, y + size[1] + 2), f"{p.parent.name}/{p.stem} x{s:g}", fill="#2a1a2e", font=label_font)
            x += cw
        y += rh
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
