"""Review sheet: lay rendered PNGs out on the floor colour at several scales.

    py -3 -B review_sheet.py --out ../preview/sheet_player.png ../output/player/*.png
    py -3 -B review_sheet.py --scales 2,1,0.5 --bg "#b3a8b7" --out sheet.png a.png b.png
    py -3 -B review_sheet.py --cols 6 --label parent --scales 0.5 --out sheet.png ../output/*/idle.png

Each row is one scale (0.5 = the in-game 1280x720 size of a 2x source).  Files
ending in _shadow.png are drawn under their sprite, not as separate cells.
Files ending in _emit.png are skipped (the emission layer is already inside the
sprite).

g05 additions: ``--cols N`` wraps the cells into a grid of N columns (one grid
per scale, stacked), and ``--label parent`` writes "<folder>/<file>" under each
cell so frames that share a name (idle, attack, hit) can be told apart.
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


def label_of(p: Path, mode: str) -> str:
    return f"{p.parent.name}/{p.stem}" if mode == "parent" else p.stem


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--scales", default="1,0.5")
    ap.add_argument("--bg", default="#b3a8b7")
    ap.add_argument("--gap", type=int, default=16)
    ap.add_argument("--cols", type=int, default=0, help="grid columns (0 = one row per scale)")
    ap.add_argument("--label", default="stem", choices=("stem", "parent"))
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

    # one block per scale; a block is a grid of `cols` columns
    blocks = []
    for s in scales:
        rows = [list(range(i, min(i + cols, len(images)))) for i in range(0, len(images), cols)]
        col_w = [0] * cols
        for r in rows:
            for c, idx in enumerate(r):
                col_w[c] = max(col_w[c], max(int(images[idx].width * s), 90) + gap)
        row_h = [max(int(images[idx].height * s) for idx in r) + gap + 18 for r in rows]
        blocks.append((s, rows, col_w, row_h))
    width = max(sum(b[2]) for b in blocks) + gap
    height = sum(sum(b[3]) for b in blocks) + gap
    sheet = Image.new("RGBA", (width, height), args.bg)
    draw = ImageDraw.Draw(sheet)
    y = gap
    for s, rows, col_w, row_h in blocks:
        for r, rh in zip(rows, row_h):
            x = gap
            for c, idx in enumerate(r):
                im, sh, p = images[idx], shadows[idx], paths[idx]
                size = (max(1, int(im.width * s)), max(1, int(im.height * s)))
                resample = Image.Resampling.NEAREST if s >= 2 else Image.Resampling.LANCZOS
                if sh is not None:
                    sheet.alpha_composite(sh.resize(size, resample), (x, y))
                sheet.alpha_composite(im.resize(size, resample), (x, y))
                draw.text((x, y + size[1] + 2), f"{label_of(p, args.label)} x{s:g}", fill="#2a1a2e", font=label_font)
                x += col_w[c]
            y += rh
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
