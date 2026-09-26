"""Zoomed icon sheets with a 0..16 unit grid, for writing precise recipe cuts.

    py -3 -B inspect_icons.py --icons bell,umbrella,ring --out sheet.png [--cell 200]

Grid lines every 2 units (labelled 0, 4, 8, 12, 16) so ``crop`` / ``keep`` /
``poly`` values can be read straight off the picture.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from iconkit.icons import IconLibrary, find_project_root  # noqa: E402


def font(size: int):
    for name in ("arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--icons", required=True, help="comma separated icon names")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--cell", type=int, default=200)
    parser.add_argument("--cols", type=int, default=8)
    args = parser.parse_args()

    root = find_project_root(Path(__file__).resolve())
    lib = IconLibrary(root / "addons" / "at-icons" / "node2d")
    names = [n.strip() for n in args.icons.split(",") if n.strip()]
    cell, cols = args.cell, args.cols
    pad, label_h = 22, 20
    rows = (len(names) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * (cell + pad), rows * (cell + pad + label_h) + 4), "#ece7df")
    draw = ImageDraw.Draw(sheet)
    small, big = font(11), font(15)
    for i, name in enumerate(names):
        ox = (i % cols) * (cell + pad) + pad - 4
        oy = (i // cols) * (cell + pad + label_h) + label_h
        draw.rectangle((ox, oy, ox + cell, oy + cell), fill="#faf8f4")
        mask = lib.image(name, record=False).resize((cell, cell), Image.Resampling.LANCZOS)
        sheet.paste(Image.new("RGB", (cell, cell), "#3a2340"), (ox, oy), mask)
        for u in range(0, 17, 2):
            p = round(u * cell / 16)
            color = "#d35f5f" if u % 8 == 0 else "#9fb8d8"
            draw.line((ox + p, oy, ox + p, oy + cell), fill=color, width=1)
            draw.line((ox, oy + p, ox + cell, oy + p), fill=color, width=1)
            if u % 4 == 0:
                draw.text((ox + p - 3, oy + cell + 1), str(u), fill="#6b5f6f", font=small)
                draw.text((ox - 17, oy + p - 6), str(u), fill="#6b5f6f", font=small)
        draw.text((ox, oy - label_h + 2), name, fill="#2a1a2e", font=big)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.out)
    print(args.out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
