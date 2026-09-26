"""Review sheet: lay rendered PNGs out on the floor colour at several scales.

    py -3 -B review_sheet.py --out ../preview/sheet_player.png ../output/player/*.png
    py -3 -B review_sheet.py --scales 2,1,0.5 --bg "#b3a8b7" --out sheet.png a.png b.png
    py -3 -B review_sheet.py --wrap 2 --bg "#1c1822" --label "#d8d0e0" --out s.png ../output/*/*_sheet.png

Each row is one scale (0.5 = the in-game 1280x720 size of a 2x source).  Files
ending in _shadow.png are drawn under their sprite, not as separate cells.
g01 additions: --label (label colour for dark backgrounds) and --wrap N (start a
new block of rows every N files, so long effect sheets stay readable).
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


def block(images, shadows, paths, scales, gap, bg, label, label_font):
    row_h = [int(max(im.height for im in images) * s) + gap + 18 for s in scales]
    col_w = [max(int(im.width * max(scales)), 90) + gap for im in images]
    sheet = Image.new("RGBA", (sum(col_w) + gap, sum(row_h) + gap), bg)
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
            draw.text((x, y + size[1] + 2), f"{p.stem} x{s:g}", fill=label, font=label_font)
            x += cw
        y += rh
    return sheet


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--scales", default="1,0.5")
    ap.add_argument("--bg", default="#b3a8b7")
    ap.add_argument("--gap", type=int, default=16)
    ap.add_argument("--label", default="#2a1a2e", help="label colour (use a light one on a dark --bg)")
    ap.add_argument("--wrap", type=int, default=0, help="files per block row (0 = all in one row)")
    args = ap.parse_args()

    paths = []
    for pattern in args.files:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    paths = [Path(p) for p in paths if not str(p).endswith("_shadow.png")]
    scales = [float(s) for s in args.scales.split(",")]
    images = [Image.open(p).convert("RGBA") for p in paths]
    shadows = []
    for p in paths:
        sp = p.with_name(p.stem + "_shadow.png")
        shadows.append(Image.open(sp).convert("RGBA") if sp.exists() else None)
    label_font = font(13)
    n = args.wrap if args.wrap > 0 else len(images)
    blocks = [block(images[i:i + n], shadows[i:i + n], paths[i:i + n], scales, args.gap, args.bg, args.label,
                    label_font) for i in range(0, len(images), n)]
    sheet = Image.new("RGBA", (max(b.width for b in blocks), sum(b.height for b in blocks)), args.bg)
    y = 0
    for b in blocks:
        sheet.alpha_composite(b, (0, y))
        y += b.height
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
