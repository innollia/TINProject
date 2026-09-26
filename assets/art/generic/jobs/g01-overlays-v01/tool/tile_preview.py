"""Overlay check sheet (added in g01): tileable overlays drawn 2 x 2 so seams would
show, lights and masks drawn over a dark checker so their alpha falloff is visible.

    py -3 -B tile_preview.py --out ../preview/overlays_A.png [--only ov_a,ov_b] [--cell 360]

Preview only (not a game asset).  Every image is scaled so one tile is ``cell`` px.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

JOB = Path(__file__).resolve().parents[1]


def font(size):
    for name in ("arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def backdrop(w, h, step=24):
    """Dark checker + a pale bar so both dark and light overlays read."""
    im = Image.new("RGBA", (w, h), "#2a2430")
    d = ImageDraw.Draw(im)
    for y in range(0, h, step):
        for x in range(0, w, step):
            if (x // step + y // step) % 2:
                d.rectangle((x, y, x + step - 1, y + step - 1), fill="#3a3342")
    d.rectangle((0, h // 2 - step, w, h // 2 + step), fill="#8a8298")
    return im


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--only", default="")
    ap.add_argument("--cell", type=int, default=360)
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    cells = []
    for rp in sorted((JOB / "recipes").glob("*.json")):
        if rp.name.startswith(("_", "palette_")):
            continue
        rec = json.loads(rp.read_text(encoding="utf-8"))
        asset = rec["asset"]
        if only and asset not in only:
            continue
        meta = rec.get("meta") or {}
        for fr in rec.get("frames") or [{"name": asset}]:
            png = JOB / "output" / asset / f"{fr['name']}.png"
            if not png.exists():
                continue
            im = Image.open(png).convert("RGBA")
            if meta.get("tileable"):
                s = args.cell / im.width
                t = im.resize((args.cell, max(1, int(im.height * s))), Image.Resampling.LANCZOS)
                bd = backdrop(t.width * 2, t.height * 2)
                for i in range(2):
                    for j in range(2):
                        bd.alpha_composite(t, (i * t.width, j * t.height))
                cells.append((fr["name"] + " (2x2 tiled)", bd))
            else:
                s = min(args.cell * 2 / im.width, args.cell * 2 / im.height, 1.0)
                t = im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))), Image.Resampling.LANCZOS)
                bd = backdrop(t.width, t.height)
                bd.alpha_composite(t, (0, 0))
                cells.append((fr["name"], bd))
    if not cells:
        print("nothing to preview")
        return 1
    gap, label = 12, 16
    cols = 3
    rows = [cells[i:i + cols] for i in range(0, len(cells), cols)]
    width = max(sum(c.width for _, c in r) + gap * (len(r) + 1) for r in rows)
    height = sum(max(c.height for _, c in r) + label + gap for r in rows) + gap
    sheet = Image.new("RGBA", (width, height), "#16121a")
    d = ImageDraw.Draw(sheet)
    f = font(12)
    y = gap
    for r in rows:
        x = gap
        for name, c in r:
            d.text((x, y), name, fill="#d8d0e0", font=f)
            sheet.alpha_composite(c, (x, y + label))
            x += c.width + gap
        y += max(c.height for _, c in r) + label + gap
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size, len(cells))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
