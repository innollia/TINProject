"""Labelled contact sheets of every at-icons shape, for choosing recipe pieces.

    py -3 catalog.py --out <folder> [--per-page 160] [--cell 96]

Icons are drawn as plain dark silhouettes on light cells with their file name
so a recipe author can pick shapes by geometry rather than by meaning.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from iconkit.icons import IconLibrary, find_project_root  # noqa: E402


def font(size: int) -> ImageFont.ImageFont:
    for name in ("arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--per-page", type=int, default=160)
    parser.add_argument("--cell", type=int, default=96)
    parser.add_argument("--cols", type=int, default=16)
    parser.add_argument("--cache", type=Path, default=None)
    args = parser.parse_args()

    root = find_project_root(Path(__file__).resolve())
    lib = IconLibrary(root / "addons" / "at-icons" / "node2d", args.cache)
    names = lib.names()
    lib.prefetch(names)
    args.out.mkdir(parents=True, exist_ok=True)
    label_font = font(11)
    cell, cols = args.cell, args.cols
    pages = [names[i:i + args.per_page] for i in range(0, len(names), args.per_page)]
    for page_index, page in enumerate(pages, start=1):
        rows = (len(page) + cols - 1) // cols
        sheet = Image.new("RGB", (cols * cell, rows * (cell + 16)), "#e9e4dc")
        draw = ImageDraw.Draw(sheet)
        for i, name in enumerate(page):
            x, y = (i % cols) * cell, (i // cols) * (cell + 16)
            draw.rectangle((x + 2, y + 2, x + cell - 3, y + cell - 3), fill="#f7f4ee")
            mask = lib.image(name, record=False).resize((cell - 16, cell - 16), Image.Resampling.LANCZOS)
            lib.forget(name)
            ink = Image.new("RGB", mask.size, "#2e1b2f")
            sheet.paste(ink, (x + 8, y + 8), mask)
            text = name if len(name) <= 15 else name[:14] + "~"
            draw.text((x + 3, y + cell - 1), text, fill="#3c3040", font=label_font)
        path = args.out / f"at_icons_node2d_catalog_p{page_index}.png"
        sheet.save(path)
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
