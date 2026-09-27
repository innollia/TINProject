"""Side-by-side comparison sheet of previews (v02).

    py -3 -B compare_sheet.py --out ../preview/compare_v01_v1_v2_v3.png --cols 2 --width 960 \
        "v01=..\\..\\h0-icon-collage-v01\\preview\\preview_h0_1280x720.png" "V1=..\\preview\\preview_h0_v1_1280x720.png"

Each argument is ``label=path``.  Labels may be Korean (Malgun Gothic is used when
present).  Images are only read; the sheet is a review aid, not a runtime asset.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def font(size: int):
    for name in ("malgun.ttf", "malgunbd.ttf", "arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("items", nargs="+", help="label=path")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--cols", type=int, default=2)
    ap.add_argument("--width", type=int, default=960, help="cell width in px")
    ap.add_argument("--title", default="")
    args = ap.parse_args()

    pairs = []
    for spec in args.items:
        label, _, path = spec.partition("=")
        pairs.append((label, Image.open(path).convert("RGB")))
    cw = args.width
    ch = max(int(round(im.height * cw / im.width)) for _, im in pairs)
    label_h, gap = 40, 14
    title_h = 46 if args.title else 0
    rows = (len(pairs) + args.cols - 1) // args.cols
    sheet = Image.new("RGB", (args.cols * (cw + gap) + gap, title_h + rows * (ch + label_h + gap) + gap), "#141116")
    draw = ImageDraw.Draw(sheet)
    if args.title:
        draw.text((gap, 10), args.title, fill="#e8e0d4", font=font(24))
    f = font(22)
    for i, (label, im) in enumerate(pairs):
        x = gap + (i % args.cols) * (cw + gap)
        y = title_h + gap + (i // args.cols) * (ch + label_h + gap)
        draw.text((x, y + 4), label, fill="#e8e0d4", font=f)
        sheet.paste(im.resize((cw, int(round(im.height * cw / im.width))), Image.Resampling.LANCZOS), (x, y + label_h))
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.out)
    print(args.out, sheet.size)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
