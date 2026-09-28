"""Contact sheets, so quality can be judged by looking rather than by guessing.

Two outputs matter while authoring:
  * a strip  - consecutive frames, the only way to see whether a walk reads
  * a sheet   - many creatures at once, so a bad silhouette is obvious next to
                a good one instead of hiding inside one PNG
"""

from __future__ import annotations

import math

import numpy as np
from PIL import Image, ImageDraw

from .canvas import Canvas

# Two mid greys, so a shape reads against both its own dark rim and its light
# belly.  A checker the size of the sprite would become part of the drawing.
CHECK = 16


def checker(size: tuple, a=(58, 58, 62, 255), b=(74, 74, 78, 255)) -> Image.Image:
    img = Image.new("RGBA", size, a)
    draw = ImageDraw.Draw(img)
    for y in range(0, size[1], CHECK):
        for x in range(0, size[0], CHECK):
            if (x // CHECK + y // CHECK) % 2:
                draw.rectangle([x, y, x + CHECK - 1, y + CHECK - 1], fill=b)
    return img


def compose(frames, columns: int, pad: int = 8, background=None, labels=None,
            label_h: int = 14) -> Image.Image:
    """Tile Canvas objects (or PIL images) into one sheet."""
    images = [(f.to_image() if isinstance(f, Canvas) else f) for f in frames]
    if not images:
        raise ValueError("no frames")
    cell_w = max(i.width for i in images) + pad * 2
    cell_h = max(i.height for i in images) + pad * 2 + (label_h if labels else 0)
    rows = max(1, math.ceil(len(images) / columns))
    sheet = Image.new("RGBA", (cell_w * columns, cell_h * rows), background or (24, 24, 27, 255))
    for i, img in enumerate(images):
        cx = (i % columns) * cell_w + (cell_w - img.width) // 2
        cy = (i // columns) * cell_h + (cell_h - img.height) // 2
        if background is None:
            under = checker((img.width + pad * 2, img.height + pad * 2))
            sheet.alpha_composite(under, (cx - pad, cy - pad))
        sheet.alpha_composite(img, (cx, cy))
    if labels:
        draw = ImageDraw.Draw(sheet)
        for i, text in enumerate(labels):
            if i >= len(images) or not text:
                continue
            x = (i % columns) * cell_w + pad
            y = (i // columns) * cell_h + cell_h - label_h
            draw.text((x, y), str(text), fill=(150, 150, 158, 255))
    return sheet


def strip(frames, pad: int = 6, background=(24, 24, 27, 255)) -> Image.Image:
    return compose(frames, columns=len(frames), pad=pad, background=background)


def strip_on_checker(frames, pad: int = 6) -> Image.Image:
    return compose(frames, columns=len(frames), pad=pad, background=None)


def scale_image(img: Image.Image, factor: float) -> Image.Image:
    if abs(factor - 1.0) < 1e-6:
        return img
    w = max(1, int(round(img.width * factor)))
    h = max(1, int(round(img.height * factor)))
    return img.resize((w, h), Image.Resampling.NEAREST if factor >= 2 else Image.Resampling.LANCZOS)


def trim(img: Image.Image, pad: int = 2) -> Image.Image:
    """Cut to the opaque pixels plus a small margin, so a sheet packs tight."""
    alpha = img.split()[3]
    box = alpha.getbbox()
    if not box:
        return img
    x0 = max(0, box[0] - pad)
    y0 = max(0, box[1] - pad)
    x1 = min(img.width, box[2] + pad)
    y1 = min(img.height, box[3] + pad)
    return img.crop((x0, y0, x1, y1))


def scale_factor(img: Image.Image, target_h: int) -> float:
    return max(target_h / max(img.height, 1), 0.05)
