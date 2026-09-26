"""Review sheet: lay rendered PNGs out on the floor colour at several scales.

    py -3 -B review_sheet.py --out ../preview/sheet_player.png ../output/player/*.png
    py -3 -B review_sheet.py --scales 2,1,0.5 --bg "#b3a8b7" --out sheet.png a.png b.png

Each row is one scale (0.5 = the in-game 1280x720 size of a 2x source).  Files
ending in _shadow.png are drawn under their sprite, not as separate cells.

mp03 additions (without them the layout is the original one):
    --cols N             wrap the cells of each scale into rows of N (one grid per scale)
    --crop x0,y0,x1,y1   cut the same source-px box out of every image and shadow first
    --label-parent       prefix each label with the PNG's folder name (the NPC id)
    --anchor NAME        draw a thin cross at the manifest's anchors[NAME] (review only)
"""

from __future__ import annotations

import argparse
import glob
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def font(size: int):
    for name in ("arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def parse_box(text: str):
    if not text:
        return None
    vals = [int(round(float(v))) for v in text.split(",")]
    if len(vals) != 4 or vals[2] <= vals[0] or vals[3] <= vals[1]:
        raise SystemExit("--crop needs x0,y0,x1,y1 with x1 > x0 and y1 > y0")
    return tuple(vals)


def anchor_of(png: Path, name: str):
    man = png.with_suffix(".json")
    if not name or not man.exists():
        return None
    point = (json.loads(man.read_text(encoding="utf-8")).get("anchors") or {}).get(name)
    return [float(point[0]), float(point[1])] if point else None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--scales", default="1,0.5")
    ap.add_argument("--bg", default="#b3a8b7")
    ap.add_argument("--gap", type=int, default=16)
    ap.add_argument("--cols", type=int, default=0)
    ap.add_argument("--crop", default="")
    ap.add_argument("--label-parent", action="store_true")
    ap.add_argument("--anchor", default="")
    args = ap.parse_args()

    paths = []
    for pattern in args.files:
        paths.extend(sorted(glob.glob(pattern)) or [pattern])
    paths = [Path(p) for p in paths if not p.endswith("_shadow.png")]
    if not paths:
        raise SystemExit("no images matched")
    scales = [float(s) for s in args.scales.split(",")]
    box = parse_box(args.crop)
    images, shadows, anchors = [], [], []
    for p in paths:
        im = Image.open(p).convert("RGBA")
        sp = p.with_name(p.stem + "_shadow.png")
        sh = Image.open(sp).convert("RGBA") if sp.exists() else None
        anchor = anchor_of(p, args.anchor)
        if box:
            im = im.crop(box)
            sh = sh.crop(box) if sh is not None else None
            if anchor:
                anchor = [anchor[0] - box[0], anchor[1] - box[1]]
        images.append(im)
        shadows.append(sh)
        anchors.append(anchor)
    labels = [f"{p.parent.name}/{p.stem}" if args.label_parent else p.stem for p in paths]

    label_font = font(13)
    gap = args.gap
    n = len(images)
    cols = args.cols if args.cols > 0 else n
    rows_per_scale = (n + cols - 1) // cols
    smax = max(scales)
    if args.cols > 0:
        cell_w = max(max(int(im.width * smax), 90) for im in images) + gap
        col_w = [cell_w] * cols
    else:
        col_w = [max(int(im.width * smax), 90) + gap for im in images]
    row_h = [int(max(im.height for im in images) * s) + gap + 18 for s in scales]
    sheet = Image.new("RGBA", (sum(col_w) + gap, sum(h * rows_per_scale for h in row_h) + gap), args.bg)
    draw = ImageDraw.Draw(sheet)
    y = gap
    for s, rh in zip(scales, row_h):
        for r in range(rows_per_scale):
            x = gap
            for c in range(cols):
                i = r * cols + c
                if i >= n:
                    break
                im, sh = images[i], shadows[i]
                size = (max(1, int(im.width * s)), max(1, int(im.height * s)))
                resample = Image.Resampling.NEAREST if s >= 2 else Image.Resampling.LANCZOS
                if sh is not None:
                    sheet.alpha_composite(sh.resize(size, resample), (x, y))
                sheet.alpha_composite(im.resize(size, resample), (x, y))
                if anchors[i]:
                    ax, ay = x + anchors[i][0] * s, y + anchors[i][1] * s
                    draw.line((ax - 7, ay, ax + 7, ay), fill="#c8282a", width=1)
                    draw.line((ax, ay - 7, ax, ay + 7), fill="#c8282a", width=1)
                draw.text((x, y + size[1] + 2), f"{labels[i]} x{s:g}", fill="#2a1a2e", font=label_font)
                x += col_w[c]
            y += rh
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
