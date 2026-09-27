"""Stack output/sheets/<asset>.png vertically into one contact sheet, with labels.

    py -3 -B tool/stack_strips.py --out preview/review_fx-01_strips.png

Each animation sheet keeps its own height, so this shows the loops as they will
actually animate.  The background is the palette floor colour at 0.5 value so
pale water still reads.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

JOB = Path(__file__).resolve().parents[1]
SHEETS = JOB / "output" / "sheets"


def font(size: int):
    for name in ("arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--bg", default="#2f2b36")
    ap.add_argument("--label_w", type=int, default=150)
    ap.add_argument("--pad", type=int, default=14)
    args = ap.parse_args()
    paths = sorted(p for p in SHEETS.glob("*.png"))
    if not paths:
        raise SystemExit("no sheets - run pack_strip.py first")
    imgs = [(p, Image.open(p).convert("RGBA")) for p in paths]
    label_f = font(15)
    pad = args.pad
    width = args.label_w + pad * 2 + max(i.width for _p, i in imgs)
    height = pad * 2 + sum(i.height + pad for _p, i in imgs)
    sheet = Image.new("RGBA", (width, height), args.bg)
    draw = ImageDraw.Draw(sheet)
    y = pad
    for p, im in imgs:
        sheet.alpha_composite(im, (args.label_w + pad, y))
        draw.text((pad, y + im.height // 2 - 9), p.stem, fill="#cbc3d2", font=label_f)
        y += im.height + pad
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
