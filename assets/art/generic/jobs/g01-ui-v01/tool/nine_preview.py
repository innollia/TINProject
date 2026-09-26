"""9-slice check: draw each 9-slice UI frame at its own size and stretched (added in g01).

    py -3 -B nine_preview.py --out ../preview/nine_A.png [--only ui_a,ui_b] [--bg "#2a2430"]

Reads meta.nine_slice [left, top, right, bottom] and meta.preview_size from the recipe.
Corners stay fixed, edges stretch along their length, the centre stretches both ways,
the same rule a NinePatchRect uses in stretch mode.  Preview only (not a game asset).
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


def nine(im: Image.Image, margins, size) -> Image.Image:
    l, t, r, b = margins
    W, H = im.size
    w, h = size
    xs_src, ys_src = [0, l, W - r, W], [0, t, H - b, H]
    xs_dst, ys_dst = [0, l, w - r, w], [0, t, h - b, h]
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for i in range(3):
        for j in range(3):
            sx0, sx1, sy0, sy1 = xs_src[i], xs_src[i + 1], ys_src[j], ys_src[j + 1]
            dx0, dx1, dy0, dy1 = xs_dst[i], xs_dst[i + 1], ys_dst[j], ys_dst[j + 1]
            if sx1 <= sx0 or sy1 <= sy0 or dx1 <= dx0 or dy1 <= dy0:
                continue
            part = im.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.Resampling.BILINEAR)
            out.alpha_composite(part, (dx0, dy0))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--only", default="")
    ap.add_argument("--bg", default="#2a2430")
    args = ap.parse_args()
    only = {s.strip() for s in args.only.split(",") if s.strip()}
    rows = []
    for rp in sorted((JOB / "recipes").glob("*.json")):
        if rp.name.startswith(("_", "palette_")):
            continue
        rec = json.loads(rp.read_text(encoding="utf-8"))
        meta = rec.get("meta") or {}
        if "nine_slice" not in meta:
            continue
        asset = rec["asset"]
        if only and asset not in only:
            continue
        names = [f["name"] for f in rec.get("frames") or [{"name": asset}]]
        for name in names:
            png = JOB / "output" / asset / f"{name}.png"
            if png.exists():
                im = Image.open(png).convert("RGBA")
                rows.append((name, im, nine(im, meta["nine_slice"], tuple(meta.get("preview_size", [480, 200])))))
    if not rows:
        print("nothing to preview")
        return 1
    gap, label = 16, 16
    width = max(a.width + b.width for _, a, b in rows) + 3 * gap
    height = sum(max(a.height, b.height) + label + gap for _, a, b in rows) + gap
    sheet = Image.new("RGBA", (width, height), args.bg)
    draw = ImageDraw.Draw(sheet)
    f = font(12)
    y = gap
    for name, a, b in rows:
        draw.text((gap, y), f"{name}  (left: source, right: stretched)", fill="#d8d0e0", font=f)
        y += label
        sheet.alpha_composite(a, (gap, y))
        sheet.alpha_composite(b, (2 * gap + a.width, y))
        y += max(a.height, b.height) + gap
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size, len(rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
