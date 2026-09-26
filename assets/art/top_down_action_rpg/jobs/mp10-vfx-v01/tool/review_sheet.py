"""Review sheet: lay rendered PNGs out on the floor colour at several scales.

    py -3 -B review_sheet.py --out ../preview/sheet_player.png ../output/player/*.png
    py -3 -B review_sheet.py --scales 2,1,0.5 --bg "#b3a8b7" --out sheet.png a.png b.png

Each row is one scale (0.5 = the in-game 1280x720 size of a 2x source).  Files
ending in _shadow.png are drawn under their sprite, not as separate cells.

mp10 additions:
    --emit            also draw each image's <name>_emit.png additively (review only:
                      the game adds the emission layer itself); files ending in
                      _emit.png are never cells of their own
    --label-color     label colour (default dark; use a light one on a dark --bg)
    --cols N          wrap cells into rows of N (each scale block repeats the wrap)
"""

from __future__ import annotations

import argparse
import glob
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont


def font(size: int):
    for name in ("arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def add_emit(base: Image.Image, emit: Image.Image, pos) -> None:
    """Additive composite of a straight-alpha emission layer onto an RGBA sheet."""
    x, y = pos
    region = base.crop((x, y, x + emit.width, y + emit.height))
    b = np.asarray(region, dtype=np.float32) / 255.0
    e = np.asarray(emit, dtype=np.float32) / 255.0
    b[..., :3] = np.clip(b[..., :3] + e[..., :3] * e[..., 3:4], 0.0, 1.0)
    base.paste(Image.fromarray((b * 255.0 + 0.5).astype(np.uint8), "RGBA"), (x, y))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--scales", default="1,0.5")
    ap.add_argument("--bg", default="#b3a8b7")
    ap.add_argument("--gap", type=int, default=16)
    ap.add_argument("--emit", action="store_true")
    ap.add_argument("--label-color", default="#2a1a2e")
    ap.add_argument("--cols", type=int, default=0)
    args = ap.parse_args()

    paths = []
    for pattern in args.files:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    paths = [Path(p) for p in paths if not (p.endswith("_shadow.png") or p.endswith("_emit.png"))]
    scales = [float(s) for s in args.scales.split(",")]
    images = [Image.open(p).convert("RGBA") for p in paths]
    shadows, emits = [], []
    for p in paths:
        sp = p.with_name(p.stem + "_shadow.png")
        shadows.append(Image.open(sp).convert("RGBA") if sp.exists() else None)
        ep = p.with_name(p.stem + "_emit.png")
        emits.append(Image.open(ep).convert("RGBA") if (args.emit and ep.exists()) else None)
    label_font = font(13)
    gap = args.gap
    cols = args.cols if args.cols > 0 else len(images)
    nrows = (len(images) + cols - 1) // cols
    cell_w = max(max(int(im.width * max(scales)), 90) + gap for im in images)
    blocks = []
    for s in scales:
        rh = int(max(im.height for im in images) * s) + gap + 18
        blocks.append((s, rh))
    width = cols * cell_w + gap
    height = sum(rh * nrows for _, rh in blocks) + gap
    sheet = Image.new("RGBA", (width, height), args.bg)
    draw = ImageDraw.Draw(sheet)
    y0 = gap
    for s, rh in blocks:
        for idx, (im, sh, em, p) in enumerate(zip(images, shadows, emits, paths)):
            r, c = divmod(idx, cols)
            x, y = gap + c * cell_w, y0 + r * rh
            size = (max(1, int(im.width * s)), max(1, int(im.height * s)))
            resample = Image.Resampling.NEAREST if s >= 2 else Image.Resampling.LANCZOS
            if sh is not None:
                sheet.alpha_composite(sh.resize(size, resample), (x, y))
            sheet.alpha_composite(im.resize(size, resample), (x, y))
            if em is not None:
                add_emit(sheet, em.resize(size, resample), (x, y))
            label = f"{p.stem} x{s:g}" + (" +emit" if em is not None else "")
            draw.text((x, y + size[1] + 2), label, fill=args.label_color, font=label_font)
        y0 += rh * nrows
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
